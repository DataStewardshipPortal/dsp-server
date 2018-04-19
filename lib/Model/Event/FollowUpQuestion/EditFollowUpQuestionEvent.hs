module Model.Event.FollowUpQuestion.EditFollowUpQuestionEvent where

import Control.Lens
import Data.UUID
import GHC.Generics

import LensesConfig
import Model.Common
import Model.KnowledgeModel.KnowledgeModel

data EditFollowUpQuestionEvent = EditFollowUpQuestionEvent
  { _efuqUuid :: UUID
  , _efuqKmUuid :: UUID
  , _efuqChapterUuid :: UUID
  , _efuqAnswerUuid :: UUID
  , _efuqQuestionUuid :: UUID
  , _efuqShortQuestionUuid :: Maybe (Maybe String)
  , _efuqType :: Maybe QuestionType
  , _efuqTitle :: Maybe String
  , _efuqText :: Maybe String
  , _efuqAnswerIds :: Maybe [UUID]
  , _efuqExpertIds :: Maybe [UUID]
  , _efuqReferenceIds :: Maybe [UUID]
  } deriving (Show, Eq, Generic)

makeLenses ''EditFollowUpQuestionEvent

instance SameUuid EditFollowUpQuestionEvent Chapter where
  equalsUuid e ch = ch ^. uuid == e ^. efuqChapterUuid

instance SameUuid EditFollowUpQuestionEvent Question where
  equalsUuid e q = q ^. uuid == e ^. efuqQuestionUuid

instance SameUuid EditFollowUpQuestionEvent Answer where
  equalsUuid e ans = ans ^. uuid == e ^. efuqAnswerUuid