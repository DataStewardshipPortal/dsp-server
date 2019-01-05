module Specs.API.Package.List_POST
  ( list_post
  ) where

import Control.Lens ((^.), (&), (.~))
import Data.Aeson (encode)
import Network.HTTP.Types
import Network.Wai (Application)
import Test.Hspec
import Test.Hspec.Wai hiding (shouldRespondWith)
import qualified Test.Hspec.Wai.JSON as HJ
import Test.Hspec.Wai.Matcher

import Api.Resource.Error.ErrorDTO ()
import Api.Resource.KnowledgeModelBundle.KnowledgeModelBundleJM ()
import Database.DAO.Package.PackageDAO
import Database.Migration.Development.KnowledgeModelBundle.Data.KnowledgeModelBundles
import Database.Migration.Development.Package.Data.Packages
import LensesConfig
import Localization
import Model.Context.AppContext
import Model.Error.ErrorHelpers
import Service.KnowledgeModelBundle.KnowledgeModelBundleMapper
import Service.Package.PackageMapper

import Specs.API.Common
import Specs.API.Package.Common
import Specs.Common

-- ------------------------------------------------------------------------
-- POST /packages
-- ------------------------------------------------------------------------
list_post :: AppContext -> SpecWith Application
list_post appContext =
  describe "POST /packages" $ do
    test_201_req_all_db_all appContext
    test_201_req_all_db_no appContext
    test_201_req_no_db_all appContext
    test_201_req_one_db_rest appContext
    test_400 appContext
    test_400_main_package_duplication appContext
    test_400_missing_parent_package appContext
    test_400_bad_package_coordinates appContext
    test_401 appContext
    test_403 appContext

-- ----------------------------------------------------
-- ----------------------------------------------------
-- ----------------------------------------------------
reqMethod = methodPost

reqUrl = "/packages"

reqHeaders = [reqAuthHeader, reqCtHeader]

reqDto = toDTO elixirNlPackage2DtoKMBudle

reqBody = encode reqDto

-- ----------------------------------------------------
-- ----------------------------------------------------
-- ----------------------------------------------------
test_201_req_all_db_all appContext = do
  it "HTTP 201 CREATED - In request: all parent packages, in DB: all parent packages" $
     -- GIVEN: Prepare expectation
   do
    let expStatus = 201
    let expHeaders = [resCtHeader] ++ resCorsHeaders
    let expDto = packageWithEventsToDTO <$> [elixirNlPackage2Dto]
    let expBody = encode expDto
     -- AND: Run migrations
    runInContextIO deletePackages appContext
    runInContextIO (insertPackage baseElixirPackageDto) appContext
    runInContextIO (insertPackage elixirNlPackageDto) appContext
     -- WHEN: Call API
    response <- request reqMethod reqUrl reqHeaders reqBody
     -- THEN: Compare response with expectation
    let responseMatcher =
          ResponseMatcher {matchHeaders = expHeaders, matchStatus = expStatus, matchBody = bodyEquals expBody}
    response `shouldRespondWith` responseMatcher
     -- AND: Find result in DB and compare with expectation state
    assertCountInDB findPackages appContext 3
    assertExistenceOfPackageInDB appContext ((reqDto ^. packages) !! 0)
    assertExistenceOfPackageInDB appContext ((reqDto ^. packages) !! 1)
    assertExistenceOfPackageInDB appContext ((reqDto ^. packages) !! 2)

-- ----------------------------------------------------
-- ----------------------------------------------------
-- ----------------------------------------------------
test_201_req_all_db_no appContext = do
  it "HTTP 201 CREATED - In request: all parent packages, in DB: no parent packages" $
     -- GIVEN: Prepare expectation
   do
    let expStatus = 201
    let expHeaders = [resCtHeader] ++ resCorsHeaders
    let expDto = packageWithEventsToDTO <$> [baseElixirPackageDto, elixirNlPackageDto, elixirNlPackage2Dto]
    let expBody = encode expDto
     -- AND: Run migrations
    runInContextIO deletePackages appContext
     -- WHEN: Call API
    response <- request reqMethod reqUrl reqHeaders reqBody
     -- THEN: Compare response with expectation
    let responseMatcher =
          ResponseMatcher {matchHeaders = expHeaders, matchStatus = expStatus, matchBody = bodyEquals expBody}
    response `shouldRespondWith` responseMatcher
     -- AND: Find result in DB and compare with expectation state
    assertCountInDB findPackages appContext 3
    assertExistenceOfPackageInDB appContext (baseElixirPackageDto)
    assertExistenceOfPackageInDB appContext (elixirNlPackageDto)
    assertExistenceOfPackageInDB appContext (elixirNlPackage2Dto)

-- ----------------------------------------------------
-- ----------------------------------------------------
-- ----------------------------------------------------
test_201_req_no_db_all appContext = do
  it "HTTP 201 CREATED - In request: no parent packages, in DB: all parent packages" $
     -- GIVEN: Prepare request
   do
    let reqDto = toDTO (elixirNlPackage2DtoKMBudle & packages .~ [elixirNlPackage2Dto])
    let reqBody = encode reqDto
     -- AND: Prepare expectation
    let expStatus = 201
    let expHeaders = [resCtHeader] ++ resCorsHeaders
    let expDto = packageWithEventsToDTO <$> [elixirNlPackage2Dto]
    let expBody = encode expDto
     -- AND: Run migrations
    runInContextIO deletePackages appContext
    runInContextIO (insertPackage baseElixirPackageDto) appContext
    runInContextIO (insertPackage elixirNlPackageDto) appContext
     -- WHEN: Call API
    response <- request reqMethod reqUrl reqHeaders reqBody
     -- THEN: Compare response with expectation
    let responseMatcher =
          ResponseMatcher {matchHeaders = expHeaders, matchStatus = expStatus, matchBody = bodyEquals expBody}
    response `shouldRespondWith` responseMatcher
     -- AND: Find result in DB and compare with expectation state
    assertCountInDB findPackages appContext 3
    assertExistenceOfPackageInDB appContext (baseElixirPackageDto)
    assertExistenceOfPackageInDB appContext (elixirNlPackageDto)
    assertExistenceOfPackageInDB appContext (elixirNlPackage2Dto)

-- ----------------------------------------------------
-- ----------------------------------------------------
-- ----------------------------------------------------
test_201_req_one_db_rest appContext = do
  it "HTTP 201 CREATED - In request: one parent package, in DB: rest of parent packages" $
     -- GIVEN: Prepare request
   do
    let reqDto = toDTO (elixirNlPackage2DtoKMBudle & packages .~ [elixirNlPackageDto, elixirNlPackage2Dto])
    let reqBody = encode reqDto
     -- AND: Prepare expectation
    let expStatus = 201
    let expHeaders = [resCtHeader] ++ resCorsHeaders
    let expDto = packageWithEventsToDTO <$> [elixirNlPackageDto, elixirNlPackage2Dto]
    let expBody = encode expDto
     -- AND: Run migrations
    runInContextIO deletePackages appContext
    runInContextIO (insertPackage baseElixirPackageDto) appContext
     -- WHEN: Call API
    response <- request reqMethod reqUrl reqHeaders reqBody
     -- THEN: Compare response with expectation
    let responseMatcher =
          ResponseMatcher {matchHeaders = expHeaders, matchStatus = expStatus, matchBody = bodyEquals expBody}
    response `shouldRespondWith` responseMatcher
     -- AND: Find result in DB and compare with expectation state
    assertCountInDB findPackages appContext 3
    assertExistenceOfPackageInDB appContext (baseElixirPackageDto)
    assertExistenceOfPackageInDB appContext (elixirNlPackageDto)
    assertExistenceOfPackageInDB appContext (elixirNlPackage2Dto)

-- ----------------------------------------------------
-- ----------------------------------------------------
-- ----------------------------------------------------
test_400 appContext = createInvalidJsonTest reqMethod reqUrl [HJ.json| { name: "Common Package" } |] "id"

-- ----------------------------------------------------
-- ----------------------------------------------------
-- ----------------------------------------------------
test_400_main_package_duplication appContext = do
  it "HTTP 400 BAD REQUEST when main package already exists" $
     -- GIVEN: Prepare expectation
   do
    let expStatus = 400
    let expHeaders = [resCtHeader] ++ resCorsHeaders
    let expDto = createErrorWithErrorMessage $ _ERROR_VALIDATION__PKG_ID_UNIQUENESS (elixirNlPackage2Dto ^. pId)
    let expBody = encode expDto
     -- AND: Run migrations
    runInContextIO deletePackages appContext
    runInContextIO (insertPackage baseElixirPackageDto) appContext
    runInContextIO (insertPackage elixirNlPackageDto) appContext
    runInContextIO (insertPackage elixirNlPackage2Dto) appContext
     -- WHEN: Call API
    response <- request reqMethod reqUrl reqHeaders reqBody
     -- THEN: Compare response with expectation
    let responseMatcher =
          ResponseMatcher {matchHeaders = expHeaders, matchStatus = expStatus, matchBody = bodyEquals expBody}
    response `shouldRespondWith` responseMatcher
     -- AND: Find result in DB and compare with expectation state
    assertCountInDB findPackages appContext 3

test_400_missing_parent_package appContext = do
  it "HTTP 400 BAD REQUEST when main package already exists" $
     -- GIVEN: Prepare request
   do
    let reqDto = toDTO (elixirNlPackage2DtoKMBudle & packages .~ [elixirNlPackage2Dto])
    let reqBody = encode reqDto
     -- AND: Prepare expectation
    let expStatus = 400
    let expHeaders = [resCtHeader] ++ resCorsHeaders
    let expDto = createErrorWithErrorMessage $ _ERROR_SERVICE_PKG__IMPORT_PARENT_PKG_AT_FIRST (elixirNlPackageDto ^. pId) (elixirNlPackage2Dto ^. pId)
    let expBody = encode expDto
     -- AND: Run migrations
    runInContextIO deletePackages appContext
    runInContextIO (insertPackage baseElixirPackageDto) appContext
     -- WHEN: Call API
    response <- request reqMethod reqUrl reqHeaders reqBody
     -- THEN: Compare response with expectation
    let responseMatcher =
          ResponseMatcher {matchHeaders = expHeaders, matchStatus = expStatus, matchBody = bodyEquals expBody}
    response `shouldRespondWith` responseMatcher
     -- AND: Find result in DB and compare with expectation state
    assertCountInDB findPackages appContext 1
    assertExistenceOfPackageInDB appContext (baseElixirPackageDto)

test_400_bad_package_coordinates appContext =
  it "HTTP 400 BAD REQUEST when package ID doesn't match with package coordinates" $
     -- GIVEN: Prepare request
   do
    let editedElixirNlPackageDto = elixirNlPackageDto & kmId .~ ((elixirNlPackageDto ^. kmId) ++ "-2")
    let reqDto = toDTO (elixirNlPackage2DtoKMBudle & packages .~ [editedElixirNlPackageDto, elixirNlPackage2Dto])
    let reqBody = encode reqDto
     -- AND: Prepare expectation
    let expStatus = 400
    let expHeaders = [resCtHeader] ++ resCorsHeaders
    let expDto = createErrorWithErrorMessage $ _ERROR_SERVICE_PKG__PKG_ID_MISMATCH (elixirNlPackageDto ^. pId)
    let expBody = encode expDto
     -- AND: Run migrations
    runInContextIO deletePackages appContext
    runInContextIO (insertPackage baseElixirPackageDto) appContext
     -- WHEN: Call API
    response <- request reqMethod reqUrl reqHeaders reqBody
     -- THEN: Compare response with expectation
    let responseMatcher =
          ResponseMatcher {matchHeaders = expHeaders, matchStatus = expStatus, matchBody = bodyEquals expBody}
    response `shouldRespondWith` responseMatcher
     -- AND: Find result in DB and compare with expectation state
    assertCountInDB findPackages appContext 1

-- ----------------------------------------------------
-- ----------------------------------------------------
-- ----------------------------------------------------
test_401 appContext = createAuthTest reqMethod reqUrl [] reqBody

-- ----------------------------------------------------
-- ----------------------------------------------------
-- ----------------------------------------------------
test_403 appContext = createNoPermissionTest (appContext ^. config) reqMethod reqUrl [] "" "PM_WRITE_PERM"
