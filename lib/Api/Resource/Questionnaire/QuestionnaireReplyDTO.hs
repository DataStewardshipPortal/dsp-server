module Api.Resource.Questionnaire.QuestionnaireReplyDTO where

import qualified Data.UUID as U

data ReplyDTO = ReplyDTO
  { _replyDTOPath :: String
  , _replyDTOValue :: ReplyValueDTO
  } deriving (Show, Eq)

data ReplyValueDTO
  = StringReplyDTO { _stringReplyDTOValue :: String }
  | AnswerReplyDTO { _answerReplyDTOValue :: U.UUID }
  | ItemListReplyDTO { _itemListReplyDTOValue :: Int }
  | IntegrationReplyDTO { _integrationReplyDTOValue :: IntegrationReplyValueDTO }
  deriving (Show, Eq)

data IntegrationReplyValueDTO =
  FairsharingIntegrationReplyDTO' FairsharingIntegrationReplyDTO
  deriving (Show, Eq)

data FairsharingIntegrationReplyDTO = FairsharingIntegrationReplyDTO
  { _fairsharingIntegrationReplyDTOIntId :: String
  , _fairsharingIntegrationReplyDTOName :: String
  } deriving (Show, Eq)