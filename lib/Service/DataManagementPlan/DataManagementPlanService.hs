module Service.DataManagementPlan.DataManagementPlanService where

import Control.Lens ((^.))
import Control.Monad.Reader (asks, liftIO)
import Data.Aeson (encode)
import qualified Data.ByteString.Lazy as BS
import Data.Time
import qualified Data.UUID as U

import Api.Resource.DataManagementPlan.DataManagementPlanDTO
import Database.DAO.Level.LevelDAO
import Database.DAO.Metric.MetricDAO
import Database.DAO.Organization.OrganizationDAO
import Database.DAO.Package.PackageDAO
import Database.DAO.Questionnaire.QuestionnaireDAO
import Database.DAO.User.UserDAO
import LensesConfig
import Model.Context.AppContext
import Model.DataManagementPlan.DataManagementPlan
import Model.Error.Error
import Model.KnowledgeModel.KnowledgeModel
import Model.Questionnaire.QuestionnaireReply
import Service.DataManagementPlan.DataManagementPlanMapper
import Service.Document.DocumentService
import Service.KnowledgeModel.KnowledgeModelService
import Service.Report.ReportGenerator
import Service.Template.TemplateService
import Util.Uuid

createDataManagementPlan :: String -> AppContextM (Either AppError DataManagementPlanDTO)
createDataManagementPlan qtnUuid =
  heFindQuestionnaireById qtnUuid $ \qtn ->
    heFindPackageById (qtn ^. packageId) $ \package ->
      heFindMetrics $ \dmpMetrics ->
        heFindLevels $ \dmpLevels ->
          heFindOrganization $ \organization ->
            heCompileKnowledgeModel [] (Just $ qtn ^. packageId) (qtn ^. selectedTagUuids) $ \knowledgeModel ->
              heCreatedBy (qtn ^. ownerUuid) $ \mCreatedBy -> do
                dswConfig <- asks _appContextAppConfig
                dmpUuid <- liftIO generateUuid
                now <- liftIO getCurrentTime
                let dmpLevel =
                      if dswConfig ^. general . levelsEnabled
                        then qtn ^. level
                        else 9999
                dmpReport <- generateReport dmpLevel dmpMetrics knowledgeModel (qtn ^. replies)
                let dmp =
                      DataManagementPlan
                      { _dataManagementPlanUuid = dmpUuid
                      , _dataManagementPlanConfig =
                          DataManagementPlanConfig
                          { _dataManagementPlanConfigLevelsEnabled = dswConfig ^. general . levelsEnabled
                          , _dataManagementPlanConfigItemTitleEnabled = dswConfig ^. general . itemTitleEnabled
                          }
                      , _dataManagementPlanQuestionnaireUuid = qtnUuid
                      , _dataManagementPlanQuestionnaireName = qtn ^. name
                      , _dataManagementPlanQuestionnaireReplies = qtn ^. replies
                      , _dataManagementPlanLevel = dmpLevel
                      , _dataManagementPlanKnowledgeModel = knowledgeModel
                      , _dataManagementPlanMetrics = dmpMetrics
                      , _dataManagementPlanLevels = dmpLevels
                      , _dataManagementPlanReport = dmpReport
                      , _dataManagementPlanPackage = package
                      , _dataManagementPlanOrganization = organization
                      , _dataManagementPlanCreatedBy = mCreatedBy
                      , _dataManagementPlanCreatedAt = now
                      , _dataManagementPlanUpdatedAt = now
                      }
                return . Right . toDataManagementPlanDTO $ dmp
  where
    heCreatedBy mOwnerUuid callback =
      case mOwnerUuid of
        Just ownerUuid -> heFindUserById (U.toString ownerUuid) $ \createdBy -> callback . Just $ createdBy
        Nothing -> callback Nothing

exportDataManagementPlan ::
     String -> Maybe String -> DataManagementPlanFormat -> AppContextM (Either AppError BS.ByteString)
exportDataManagementPlan qtnUuid mTemplateUuid format = do
  heCreateDataManagementPlan qtnUuid $ \dmp ->
    case format of
      JSON -> return . Right . encode $ dmp
      otherFormat ->
        heGetTemplateByUuidOrFirst mTemplateUuid $ \template -> generateDocumentInFormat otherFormat template dmp

-- --------------------------------
-- HELPERS
-- --------------------------------
heCreateDataManagementPlan qtnUuid callback = do
  eDmp <- createDataManagementPlan qtnUuid
  case eDmp of
    Right dmp -> callback dmp
    Left error -> return . Left $ error
