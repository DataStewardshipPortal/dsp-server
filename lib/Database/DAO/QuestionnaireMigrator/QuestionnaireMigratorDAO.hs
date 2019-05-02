module Database.DAO.QuestionnaireMigrator.QuestionnaireMigratorDAO
  ( createQuestionnaireMigratorState
  , findQuestionnaireMigratorStateByQuestionnaireId
  , deleteQuestionnaireMigratorStateByQuestionnaireId
  , updateQuestionnareMigratorStateByQuestionnaireId
  ) where

import Control.Lens ((^.))
import Data.Bson
import Data.Bson.Generic
import Database.MongoDB
       ((=:), delete, fetch, findOne, insert, merge, save, select)

import Database.BSON.QuestionnaireMigrator.QuestionnaireMigratorState
       ()
import Database.DAO.Common
import LensesConfig
import Model.Context.AppContext
import Model.Error.Error
import Model.QuestionnaireMigrator.QuestionnaireMigratorState

qtnmCollection = "questionnaireMigrations"

createQuestionnaireMigratorState :: QuestionnaireMigratorState -> AppContextM Value
createQuestionnaireMigratorState state = do
  let action = insert qtnmCollection (toBSON state)
  runDB action

findQuestionnaireMigratorStateByQuestionnaireId :: String -> AppContextM (Either AppError QuestionnaireMigratorState)
findQuestionnaireMigratorStateByQuestionnaireId qtnUuid = do
  let action = findOne $ select ["questionnaire.uuid" =: qtnUuid] qtnmCollection
  maybeState <- runDB action
  return . deserializeMaybeEntity $ maybeState

deleteQuestionnaireMigratorStateByQuestionnaireId :: String -> AppContextM ()
deleteQuestionnaireMigratorStateByQuestionnaireId qtnUuid = do
  let action = delete $ select ["questionnaire.uuid" =: qtnUuid] qtnmCollection
  runDB action

updateQuestionnareMigratorStateByQuestionnaireId :: QuestionnaireMigratorState -> AppContextM ()
updateQuestionnareMigratorStateByQuestionnaireId state = do
  let action =
        fetch (select ["questionnaire.uuid" =: (state ^. questionnaire ^. uuid)] qtnmCollection) >>=
        save qtnmCollection . merge (toBSON state)
  runDB action
