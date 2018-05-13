module Database.DAO.User.UserDAO where

import Control.Lens ((^.))
import Data.Bson
import Data.Bson.Generic
import Data.Time
import Database.MongoDB
       ((=:), delete, deleteOne, fetch, find, findOne, insert, merge,
        modify, rest, save, select)
import Database.Persist.MongoDB (runMongoDBPoolDef)

import Common.Context
import Common.Error
import Common.Types
import Database.BSON.User.User ()
import Database.DAO.Common
import LensesConfig
import Model.User.User

userCollection = "users"

findUsers :: Context -> IO (Either AppError [User])
findUsers context = do
  let action = rest =<< find (select [] userCollection)
  usersS <- runMongoDBPoolDef action (context ^. ctxDbPool)
  return . deserializeEntities $ usersS

findUserById :: Context -> String -> IO (Either AppError User)
findUserById context userUuid = do
  let action = findOne $ select ["uuid" =: userUuid] userCollection
  maybeUserS <- runMongoDBPoolDef action (context ^. ctxDbPool)
  return . deserializeMaybeEntity $ maybeUserS

findUserByEmail :: Context -> Email -> IO (Either AppError User)
findUserByEmail context userEmail = do
  let action = findOne $ select ["email" =: userEmail] userCollection
  maybeUserS <- runMongoDBPoolDef action (context ^. ctxDbPool)
  return . deserializeMaybeEntity $ maybeUserS

insertUser :: Context -> User -> IO Value
insertUser context user = do
  let action = insert userCollection (toBSON user)
  runMongoDBPoolDef action (context ^. ctxDbPool)

updateUserById :: Context -> User -> IO ()
updateUserById context user = do
  let action = fetch (select ["uuid" =: (user ^. uuid)] userCollection) >>= save userCollection . merge (toBSON user)
  runMongoDBPoolDef action (context ^. ctxDbPool)

updateUserPasswordById :: Context -> String -> String -> UTCTime -> IO ()
updateUserPasswordById context userUuid password uUpdatedAt = do
  let action =
        modify
          (select ["uuid" =: userUuid] userCollection)
          ["$set" =: ["passwordHash" =: password, "updatedAt" =: uUpdatedAt]]
  runMongoDBPoolDef action (context ^. ctxDbPool)

deleteUsers :: Context -> IO ()
deleteUsers context = do
  let action = delete $ select [] userCollection
  runMongoDBPoolDef action (context ^. ctxDbPool)

deleteUserById :: Context -> String -> IO ()
deleteUserById context userUuid = do
  let action = deleteOne $ select ["uuid" =: userUuid] userCollection
  runMongoDBPoolDef action (context ^. ctxDbPool)

-- --------------------------------
-- HELPERS
-- --------------------------------
heFindUsers context callback = do
  eitherUser <- findUsers context
  case eitherUser of
    Right user -> callback user
    Left error -> return . Left $ error

-- -----------------------------------------------------
heFindUserById context userUuid callback = do
  eitherUser <- findUserById context userUuid
  case eitherUser of
    Right user -> callback user
    Left error -> return . Left $ error

hmFindUserById context userUuid callback = do
  eitherUser <- findUserById context userUuid
  case eitherUser of
    Right user -> callback user
    Left error -> return . Just $ error

-- -----------------------------------------------------
heFindUserByEmail context userEmail callback = do
  eitherUser <- findUserByEmail context userEmail
  case eitherUser of
    Right user -> callback user
    Left error -> return . Left $ error

hmFindUserByEmail context userEmail callback = do
  eitherUser <- findUserByEmail context userEmail
  case eitherUser of
    Right user -> callback user
    Left error -> return . Just $ error
