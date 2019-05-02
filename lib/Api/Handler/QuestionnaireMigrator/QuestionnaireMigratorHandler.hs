module Api.Handler.QuestionnaireMigrator.QuestionnaireMigratorHandler where

import qualified Data.Text as T
import Network.HTTP.Types.Status (created201, noContent204)
import Web.Scotty.Trans (json, param, status)

import Api.Handler.Common
import Api.Resource.QuestionnaireMigrator.QuestionnaireMigratorStateCreateJM
       ()
import Api.Resource.QuestionnaireMigrator.QuestionnaireMigratorStateJM
       ()
import Service.QuestionnaireMigrator.QuestionnaireMigratorService

-- Endpoint for creating questionnaire migration to newer (target) knowledgemodel
-- which fails when migration is already in progress.
postQuestionnaireMigrationsCurrentA :: Endpoint
postQuestionnaireMigrationsCurrentA =
  checkPermission "QTN_PERM" $
  getAuthServiceExecutor $ \runInAuthService ->
    getReqDto $ \reqDto -> do
      qtnUuid <- param "qtnUuid"
      eitherMigrationDto <- runInAuthService $ createQuestionnaireMigration qtnUuid reqDto
      case eitherMigrationDto of
        Right _ -> status created201
        Left error -> sendError error

-- Gets questionnaire migrator state for given questionnaire or fails
-- if no migration exists.
getQuestionnaireMigrationsCurrentA :: Endpoint
getQuestionnaireMigrationsCurrentA =
  checkPermission "QTN_PERM" $
  getAuthServiceExecutor $ \runInAuthService -> do
    qtnUuid <- param "qtnUuid"
    eitherMigrationDto <- runInAuthService $ getQuestionnaireMigration qtnUuid
    case eitherMigrationDto of
      Right resDto -> json resDto
      Left error -> sendError error

-- Endpoint for canceling questionnaire migration.
deleteQuestionnaireMigrationsCurrentA :: Endpoint
deleteQuestionnaireMigrationsCurrentA =
  checkPermission "QTN_PERM" $
  getAuthServiceExecutor $ \runInAuthService -> do
    qtnUuid <- param "qtnUuid"
    result <- runInAuthService $ cancelQuestionnaireMigration qtnUuid
    case result of
      Nothing -> status noContent204
      Just error -> sendError error

putQuestionnaireMigrationsCurrentA :: Endpoint
putQuestionnaireMigrationsCurrentA =
  checkPermission "QTN_PERM" $
  getAuthServiceExecutor $ \runInAuthService -> do
    qtnUuid <- param "qtnUuid"
    result <- runInAuthService $ completeQuestionnairemigration qtnUuid
    case result of
      Nothing -> status noContent204
      Just error -> sendError error

-- --------------
-- Question Flags
-- --------------
putQuestionnaireMigrationsQuestionFlagA :: Endpoint
putQuestionnaireMigrationsQuestionFlagA =
  checkPermission "QTN_PERM" $
  getAuthServiceExecutor $ \runInAuthService ->
    getReqDto $ \flagDto -> do
      qtnUuid <- param "qtnUuid"
      result <- runInAuthService $ resolveQuestionnaireQuestionChange qtnUuid flagDto
      case result of
        Nothing -> status noContent204
        Just error -> sendError error
