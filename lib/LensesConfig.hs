module LensesConfig where

import Control.Lens (makeFields)

import Api.Resource.ActionKey.ActionKeyDTO
import Api.Resource.BookReference.BookReferenceDTO
import Api.Resource.Branch.BranchDTO
import Api.Resource.Branch.BranchWithStateDTO
import Api.Resource.DataManagementPlan.DataManagementPlanDTO
import Api.Resource.Event.EventDTO
import Api.Resource.Event.EventPathDTO
import Api.Resource.Feedback.FeedbackCreateDTO
import Api.Resource.Feedback.FeedbackDTO
import Api.Resource.FilledKnowledgeModel.FilledKnowledgeModelDTO
import Api.Resource.Info.InfoDTO
import Api.Resource.KnowledgeModel.KnowledgeModelDTO
import Api.Resource.Migrator.MigratorConflictDTO
import Api.Resource.Migrator.MigratorStateCreateDTO
import Api.Resource.Migrator.MigratorStateDTO
import Api.Resource.Organization.OrganizationChangeDTO
import Api.Resource.Organization.OrganizationDTO
import Api.Resource.Package.PackageDTO
import Api.Resource.Package.PackageSimpleDTO
import Api.Resource.Package.PackageWithEventsDTO
import Api.Resource.Questionnaire.QuestionnaireCreateDTO
import Api.Resource.Questionnaire.QuestionnaireDTO
import Api.Resource.Questionnaire.QuestionnaireDetailDTO
import Api.Resource.Token.TokenCreateDTO
import Api.Resource.Token.TokenDTO
import Api.Resource.User.UserChangeDTO
import Api.Resource.User.UserCreateDTO
import Api.Resource.User.UserDTO
import Api.Resource.User.UserPasswordDTO
import Api.Resource.User.UserProfileChangeDTO
import Api.Resource.User.UserStateDTO
import Api.Resource.Version.VersionDTO
import Model.ActionKey.ActionKey
import Model.BookReference.BookReference
import Model.Branch.Branch
import Model.Config.DSWConfig
import Model.Context.AppContext
import Model.DataManagementPlan.DataManagementPlan
import Model.Event.Answer.AnswerEvent
import Model.Event.Chapter.ChapterEvent
import Model.Event.EventField
import Model.Event.EventPath
import Model.Event.Expert.ExpertEvent
import Model.Event.KnowledgeModel.KnowledgeModelEvent
import Model.Event.Question.QuestionEvent
import Model.Event.Reference.ReferenceEvent
import Model.Feedback.Feedback
import Model.FilledKnowledgeModel.FilledKnowledgeModel
import Model.KnowledgeModel.KnowledgeModel
import Model.Migrator.MigratorState
import Model.Organization.Organization
import Model.Package.Package
import Model.Questionnaire.Questionnaire
import Model.User.User

-- -------------------------------------
-- Model
-- -------------------------------------
-- Model / ActionKey
makeFields ''ActionKey

-- Model / BookReference
makeFields ''BookReference

-- Model / Branch
makeFields ''Branch

makeFields ''BranchWithEvents

makeFields ''BranchWithKM

-- Model / Config
makeFields ''AppConfigEnvironment

makeFields ''AppConfigClient

makeFields ''AppConfigWeb

makeFields ''AppConfigDatabase

makeFields ''AppConfigJwt

makeFields ''AppConfigRoles

makeFields ''AppConfigMail

makeFields ''AppConfigAnalytics

makeFields ''AppConfigFeedback

makeFields ''BuildInfo

makeFields ''DSWConfig

-- Model / Context
makeFields ''AppContext

-- Model / DataManagementPlan
makeFields ''DataManagementPlan

-- Model / Event
makeFields ''EventField

makeFields ''EventPathItem

makeFields ''AddKnowledgeModelEvent

makeFields ''EditKnowledgeModelEvent

makeFields ''AddChapterEvent

makeFields ''EditChapterEvent

makeFields ''DeleteChapterEvent

makeFields ''AddQuestionEvent

makeFields ''EditQuestionEvent

makeFields ''DeleteQuestionEvent

makeFields ''AddAnswerEvent

makeFields ''EditAnswerEvent

makeFields ''DeleteAnswerEvent

makeFields ''AddExpertEvent

makeFields ''EditExpertEvent

makeFields ''DeleteExpertEvent

makeFields ''AddReferenceEvent

makeFields ''EditReferenceEvent

makeFields ''DeleteReferenceEvent

-- Model / Feedback
makeFields ''Feedback

-- Model / FilledKnowledgeModel
makeFields ''FilledKnowledgeModel

makeFields ''FilledChapter

makeFields ''FilledQuestion

makeFields ''FilledAnswer

makeFields ''FilledAnswerItem

-- Model / KnowledgeModel
makeFields ''KnowledgeModel

makeFields ''Chapter

makeFields ''Question

makeFields ''Answer

makeFields ''AnswerItemTemplate

makeFields ''AnswerItemTemplatePlain

makeFields ''AnswerItemTemplatePlainWithIds

makeFields ''Expert

makeFields ''Reference

-- Model / Migrator
makeFields ''MigratorConflictDTO

makeFields ''MigratorStateCreateDTO

makeFields ''MigratorStateDTO

-- Model / Organization
makeFields ''Organization

-- Model / Package
makeFields ''Package

makeFields ''PackageWithEvents

-- Model / Questionnaire
makeFields ''Questionnaire

makeFields ''QuestionnaireReply

-- Model / User
makeFields ''User

-- -------------------------------------
-- Api / Resource
-- -------------------------------------
-- Api / Resource / ActionKey
makeFields ''ActionKeyDTO

-- Api / Resource / BookReference
makeFields ''BookReferenceDTO

-- Api / Resource / Branch
makeFields ''BranchDTO

makeFields ''BranchWithStateDTO

-- Api / Resource / DataManagementPlan
makeFields ''DataManagementPlanDTO

-- Api / Resource / Event
makeFields ''EventPathItemDTO

makeFields ''AddKnowledgeModelEventDTO

makeFields ''EditKnowledgeModelEventDTO

makeFields ''AddChapterEventDTO

makeFields ''EditChapterEventDTO

makeFields ''DeleteChapterEventDTO

makeFields ''AddQuestionEventDTO

makeFields ''EditQuestionEventDTO

makeFields ''DeleteQuestionEventDTO

makeFields ''AddAnswerEventDTO

makeFields ''EditAnswerEventDTO

makeFields ''DeleteAnswerEventDTO

makeFields ''AddExpertEventDTO

makeFields ''EditExpertEventDTO

makeFields ''DeleteExpertEventDTO

makeFields ''AddReferenceEventDTO

makeFields ''EditReferenceEventDTO

makeFields ''DeleteReferenceEventDTO

-- Api / Resource / Feedback
makeFields ''FeedbackDTO

makeFields ''FeedbackCreateDTO

-- Api / Resource / FilledKnowledgeModel
makeFields ''FilledKnowledgeModelDTO

makeFields ''FilledChapterDTO

makeFields ''FilledQuestionDTO

makeFields ''FilledAnswerDTO

makeFields ''FilledAnswerItemDTO

-- Api / Resource / Info
makeFields ''InfoDTO

-- Api / Resource / KnowledgeModel
makeFields ''KnowledgeModelDTO

makeFields ''ChapterDTO

makeFields ''QuestionDTO

makeFields ''AnswerDTO

makeFields ''AnswerItemTemplateDTO

makeFields ''AnswerItemTemplatePlainDTO

makeFields ''AnswerItemTemplatePlainWithIdsDTO

makeFields ''ExpertDTO

makeFields ''ReferenceDTO

-- Api / Resource / Migrator
makeFields ''MigratorState

-- Api / Resource / Organization
makeFields ''OrganizationDTO

makeFields ''OrganizationChangeDTO

-- Api / Resource / Package
makeFields ''PackageDTO

makeFields ''PackageSimpleDTO

makeFields ''PackageWithEventsDTO

-- Api / Resource / Questionnaire
makeFields ''QuestionnaireCreateDTO

makeFields ''QuestionnaireDTO

makeFields ''QuestionnaireReplyDTO

makeFields ''QuestionnaireDetailDTO

-- Api / Resource / Token
makeFields ''TokenDTO

makeFields ''TokenCreateDTO

-- Api / Resource / User
makeFields ''UserChangeDTO

makeFields ''UserCreateDTO

makeFields ''UserDTO

makeFields ''UserPasswordDTO

makeFields ''UserProfileChangeDTO

makeFields ''UserStateDTO

-- Api / Resource / Version
makeFields ''VersionDTO
