module Service.Migrator.MigratorService where

import Control.Lens ((^.))
import Control.Monad.Reader (liftIO)
import Data.Maybe
import qualified Data.Text as T

import Api.Resource.Migrator.MigratorConflictDTO
import Api.Resource.Migrator.MigratorStateCreateDTO
import Api.Resource.Migrator.MigratorStateDTO
import Database.DAO.KnowledgeModel.KnowledgeModelDAO
import Database.DAO.Migrator.MigratorDAO
import Database.DAO.Package.PackageDAO
import LensesConfig
import Localization
import Model.Context.AppContext
import Model.Error.Error
import Model.Event.EventAccessors
import Model.Migrator.MigratorState
import Service.Migrator.Migrator
import Service.Migrator.MigratorMapper
import Service.Package.PackageService
import Service.Package.PackageUtils
import Service.Package.PackageValidation

getCurrentMigration :: String -> AppContextM (Either AppError MigratorStateDTO)
getCurrentMigration branchUuid = heFindMigratorStateByBranchUuid branchUuid $ \ms -> return . Right . toDTO $ ms

createMigration :: String -> MigratorStateCreateDTO -> AppContextM (Either AppError MigratorStateDTO)
createMigration branchUuid mscDto = do
  let msTargetPackageId = mscDto ^. targetPackageId
  getBranch branchUuid $ \branch ->
    validateIfMigrationAlreadyExist $
    getParentPackageId branch $ \branchParentId ->
      validateIfTargetPackageVersionIsHigher branch msTargetPackageId $
      getTargetParentPackage msTargetPackageId $ \targetParentPackage ->
        getBranchEvents branch $ \branchEvents ->
          getTargetParentEvents msTargetPackageId branch $ \targetPackageEvents -> do
            let ms =
                  MigratorState
                  { _migratorStateBranchUuid = branch ^. uuid
                  , _migratorStateMigrationState = RunningState
                  , _migratorStateBranchParentId = branchParentId
                  , _migratorStateTargetPackageId = msTargetPackageId
                  , _migratorStateBranchEvents = branchEvents
                  , _migratorStateTargetPackageEvents = targetPackageEvents
                  , _migratorStateResultEvents = []
                  , _migratorStateCurrentKnowledgeModel = branch ^. knowledgeModel
                  }
            insertMigratorState ms
            migratedMs <- migrateState ms
            return . Right . toDTO $ migratedMs
  where
    getBranch branchUuid callback = do
      eitherBranch <- findBranchWithKMByBranchId branchUuid
      case eitherBranch of
        Right branch -> callback branch
        Left (NotExistsError _) -> return . Left . MigratorError $ _ERROR_MT_VALIDATION_MIGRATOR__SOURCE_BRANCH_ABSENCE
        Left error -> return . Left $ error
    validateIfMigrationAlreadyExist callback = do
      eitherMigratorState <- findMigratorStateByBranchUuid branchUuid
      case eitherMigratorState of
        Right migrationState -> return . Left . MigratorError $ _ERROR_MT_VALIDATION_MIGRATOR__MIGRATION_UNIQUENESS
        Left (NotExistsError _) -> callback
        Left error -> return . Left $ error
    validateIfTargetPackageVersionIsHigher branch msTargetPackageId callback =
      getLastAppliedParentPackageId branch $ \lastAppliedParentPackageId -> do
        let targetPackageVersion = T.unpack $ splitPackageId msTargetPackageId !! 2
        let lastAppliedParentPackageVersion = T.unpack $ splitPackageId lastAppliedParentPackageId !! 2
        if isNothing $ validateIsVersionHigher targetPackageVersion lastAppliedParentPackageVersion
          then callback
          else return . Left . MigratorError $ _ERROR_MT_MIGRATOR__TARGET_PKG_IS_NOT_HIGHER
    getTargetParentPackage msTargetPackageId callback = do
      eitherTargetParentPackage <- findPackageWithEventsById msTargetPackageId
      case eitherTargetParentPackage of
        Right targetParentPackage -> callback targetParentPackage
        Left (NotExistsError _) ->
          return . Left . MigratorError $ _ERROR_MT_VALIDATION_MIGRATOR__TARGET_PARENT_PKG_ABSENCE
        Left error -> return . Left $ error
    getBranchEvents branch callback =
      getParentPackageId branch $ \parentPackageId ->
        getLastMergeCheckpointPackageId branch $ \lastMergeCheckpointPackageId -> do
          let since = parentPackageId
          let until = lastMergeCheckpointPackageId
          heGetAllPreviousEventsSincePackageIdAndUntilPackageId since until $ \events -> callback events
    getParentPackageId branch callback =
      case branch ^. parentPackageId of
        Just parentPackageId -> callback parentPackageId
        Nothing -> return . Left . MigratorError $ _ERROR_MT_VALIDATION_MIGRATOR__BRANCH_PARENT_ABSENCE
    getLastMergeCheckpointPackageId branch callback =
      case branch ^. lastMergeCheckpointPackageId of
        Just lastMergeCheckpointPackageId -> callback lastMergeCheckpointPackageId
        Nothing -> return . Left . MigratorError $ _ERROR_MT_MIGRATOR__BRANCH_HAS_TO_HAVE_MERGE_CHECKPOINT
    getTargetParentEvents msTargetPackageId branch callback =
      getLastAppliedParentPackageId branch $ \lastAppliedParentPackageId -> do
        let since = msTargetPackageId
        let until = lastAppliedParentPackageId
        heGetAllPreviousEventsSincePackageIdAndUntilPackageId since until $ \events -> callback events
    getLastAppliedParentPackageId branch callback =
      case branch ^. lastAppliedParentPackageId of
        Just lastAppliedParentPackageId -> callback lastAppliedParentPackageId
        Nothing ->
          return . Left . MigratorError $ _ERROR_MT_MIGRATOR__BRANCH_HAS_TO_HAVE_CHECKPOINT_ABOUT_LAST_MERGED_PARENT_PKG

deleteCurrentMigration :: String -> AppContextM (Maybe AppError)
deleteCurrentMigration branchUuid =
  hmFindMigratorStateByBranchUuid branchUuid $ \_ -> do
    deleteMigratorStateByBranchUuid branchUuid
    return Nothing

solveConflictAndMigrate :: String -> MigratorConflictDTO -> AppContextM (Maybe AppError)
solveConflictAndMigrate branchUuid reqDto =
  hmFindMigratorStateByBranchUuid branchUuid $ \ms ->
    validateMigrationState ms $
    validateTargetPackageEvent ms $
    validateReqDto (ms ^. migrationState) reqDto $ do
      let stateWithSolvedConflicts = solveConflict ms reqDto
      migrateState stateWithSolvedConflicts
      return Nothing
  where
    validateMigrationState ms callback =
      case ms ^. migrationState of
        ConflictState (CorrectorConflict _) -> callback
        _ -> return . Just . MigratorError $ _ERROR_MT_MIGRATOR__NO_CONFLICTS_TO_SOLVE
    validateTargetPackageEvent ms callback =
      case length (ms ^. targetPackageEvents) of
        0 -> return . Just . MigratorError $ _ERROR_MT_MIGRATOR__NO_EVENTS_IN_TARGET_PKG_EVENT_QUEUE
        _ -> callback
    validateReqDto (ConflictState (CorrectorConflict e)) reqDto callback =
      if getEventUuid' e == reqDto ^. originalEventUuid
        then if reqDto ^. action == MCAEdited && isNothing (reqDto ^. event)
               then return . Just . MigratorError $ _ERROR_MT_MIGRATOR__EDIT_ACTION_HAS_TO_PROVIDE_TARGET_EVENT
               else callback
        else return . Just . MigratorError $
             _ERROR_MT_MIGRATOR__ORIGINAL_EVENT_UUID_DOES_NOT_MARCH_WITH_CURRENT_TARGET_EVENT

migrateState :: MigratorState -> AppContextM MigratorState
migrateState ms = do
  migratedMs <- liftIO $ migrate ms
  updateMigratorState migratedMs
  return migratedMs
