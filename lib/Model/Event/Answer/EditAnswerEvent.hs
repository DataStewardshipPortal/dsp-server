module Model.Event.Answer.EditAnswerEvent where

import Control.Lens
import Data.UUID
import GHC.Generics

import LensesConfig
import Model.Common
import Model.KnowledgeModel.KnowledgeModel

data EditAnswerEvent = EditAnswerEvent
  { _eansUuid :: UUID
  , _eansKmUuid :: UUID
  , _eansChapterUuid :: UUID
  , _eansQuestionUuid :: UUID
  , _eansAnswerUuid :: UUID
  , _eansLabel :: Maybe String
  , _eansAdvice :: Maybe (Maybe String)
  , _eansFollowUpIds :: Maybe [UUID]
  } deriving (Show, Eq, Generic)

makeLenses ''EditAnswerEvent

instance SameUuid EditAnswerEvent Chapter where
  equalsUuid e ch = ch ^. uuid == e ^. eansChapterUuid

instance SameUuid EditAnswerEvent Question where
  equalsUuid e q = q ^. uuid == e ^. eansQuestionUuid

instance SameUuid EditAnswerEvent Answer where
  equalsUuid e ans = ans ^. uuid == e ^. eansAnswerUuid