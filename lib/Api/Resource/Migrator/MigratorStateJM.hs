module Api.Resource.Migrator.MigratorStateJM where

import Control.Monad
import Data.Aeson

import Api.Resource.Migrator.Common ()
import Api.Resource.Migrator.MigratorStateDTO

instance FromJSON MigratorStateDTO where
  parseJSON (Object o) = do
    _migratorStateDTOBranchUuid <- o .: "branchUuid"
    _migratorStateDTOMigrationState <- o .: "migrationState"
    _migratorStateDTOBranchParentId <- o .: "branchParentId"
    _migratorStateDTOTargetPackageId <- o .: "targetPackageId"
    _migratorStateDTOCurrentKnowledgeModel <- o .: "currentKnowledgeModel"
    return MigratorStateDTO {..}
  parseJSON _ = mzero

instance ToJSON MigratorStateDTO where
  toJSON MigratorStateDTO {..} =
    object
      [ "branchUuid" .= _migratorStateDTOBranchUuid
      , "migrationState" .= _migratorStateDTOMigrationState
      , "branchParentId" .= _migratorStateDTOBranchParentId
      , "targetPackageId" .= _migratorStateDTOTargetPackageId
      , "currentKnowledgeModel" .= _migratorStateDTOCurrentKnowledgeModel
      ]
