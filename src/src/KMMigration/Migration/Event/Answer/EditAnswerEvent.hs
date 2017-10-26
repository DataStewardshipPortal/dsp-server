module KMMigration.Migration.Event.Answer.EditAnswerEvent where

import Control.Lens

import KMMigration.Migration.Event.Common
import KMMigration.Model.Common
import KMMigration.Model.KnowledgeModel

data EditAnswerEvent = EditAnswerEvent
  { _eansUuid :: UUID
  , _eansKmUuid :: UUID
  , _eansChapterUuid :: UUID
  , _eansQuestionUuid :: UUID
  , _eansAnswerUuid :: UUID
  , _eansLabel :: Maybe String
  , _eansAdvice :: Maybe (Maybe String)
  , _eansFollowingIds :: Maybe [UUID]
  }

makeLenses ''EditAnswerEvent

instance SameUuid EditAnswerEvent Chapter where
  equalsUuid e ch = ch ^. chUuid == e ^. eansChapterUuid

instance SameUuid EditAnswerEvent Question where
  equalsUuid e q = q ^. qUuid == e ^. eansQuestionUuid

instance SameUuid EditAnswerEvent Answer where
  equalsUuid e ans = ans ^. ansUuid == e ^. eansAnswerUuid
