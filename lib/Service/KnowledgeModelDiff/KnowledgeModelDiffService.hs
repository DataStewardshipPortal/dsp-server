module Service.KnowledgeModelDiff.KnowledgeModelDiffService
  ( diffKnowledgeModelsById
  , heDiffKnowledgeModelsById
  ) where

import Model.Context.AppContext
import Model.Error.Error
import Model.Event.Event
import Model.KnowledgeModelDiff.KnowledgeModelDiff
import Service.KnowledgeModel.KnowledgeModelService
       (heCompileKnowledgeModel)
import Service.Migration.KnowledgeModel.Applicator.Applicator
import Service.Package.PackageService
       (heGetAllPreviousEventsSincePackageId,
        heGetAllPreviousEventsSincePackageIdAndUntilPackageId)

-- Creates new knowledgemodel-like diff tree and diff events between
-- an old knowledgemodel and a new knowledgemodel.
diffKnowledgeModelsById :: String -> String -> AppContextM (Either AppError KnowledgeModelDiff)
diffKnowledgeModelsById prevKmId newKmId =
  heGetAllPreviousEventsSincePackageId prevKmId $ \prevKmEvents ->
    heCompileKnowledgeModel prevKmEvents Nothing [] $ \prevKm ->
      heGetAllPreviousEventsSincePackageIdAndUntilPackageId newKmId prevKmId $ \newKmEvents ->
        case runDiffApplicator (Just prevKm) newKmEvents of
          Left error -> return . Left $ error
          Right km ->
            return . Right $
            KnowledgeModelDiff
            { _knowledgeModelDiffDiffKnowledgeModel = km
            , _knowledgeModelDiffDiffEvents = cleanUpDiffEvents newKmEvents
            , _knowledgeModelDiffPreviousKnowledgeModel = prevKm
            }

-- Cleans up redundant diff events and preservers first edit event only.
cleanUpDiffEvents :: [Event] -> [Event]
cleanUpDiffEvents = id

-- --------------------------------
-- HELPERS
-- --------------------------------
-- Helper knowledgemodel diffing function. Creates diff between old knowledgemodel
-- and new knowledgemodel. Calls given callback on success.
heDiffKnowledgeModelsById ::
     String -> String -> (KnowledgeModelDiff -> AppContextM (Either AppError a)) -> AppContextM (Either AppError a)
heDiffKnowledgeModelsById oldKmId newKmId callback = do
  eitherDiff <- diffKnowledgeModelsById oldKmId newKmId
  case eitherDiff of
    Left error -> return . Left $ error
    Right kmDiff -> callback kmDiff
