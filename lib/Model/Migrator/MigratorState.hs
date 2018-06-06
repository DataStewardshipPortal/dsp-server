module Model.Migrator.MigratorState where

import qualified Data.UUID as U
import GHC.Generics

import Common.Error
import Model.Event.Event
import Model.KnowledgeModel.KnowledgeModel

data MigrationState
  = RunningState
  | ConflictState Conflict
  | ErrorState AppError
  | CompletedState
  deriving (Show, Eq, Generic)

data Conflict =
  CorrectorConflict Event
  deriving (Show, Eq, Generic)

data MigrationConflictAction
  = MCAApply
  | MCAEdited
  | MCAReject
  deriving (Show, Eq, Generic)

data MigratorState = MigratorState
  { _migratorStateBranchUuid :: U.UUID
  , _migratorStateMigrationState :: MigrationState
  , _migratorStateBranchParentId :: String
  , _migratorStateTargetPackageId :: String
  , _migratorStateBranchEvents :: [Event]
  , _migratorStateTargetPackageEvents :: [Event]
  , _migratorStateResultEvents :: [Event]
  , _migratorStateCurrentKnowledgeModel :: Maybe KnowledgeModel
  } deriving (Show, Eq)
