--------------------------------------------------------
--  DDL for Package PQH_BUDGET_POOLS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_BUDGET_POOLS_API" AUTHID CURRENT_USER as
/* $Header: pqbplapi.pkh 120.1 2005/10/02 02:25:59 aroussel $ */
/*#
 * This package contains APIs to create, update or delete reallocation folders
 * and reallocation transactions.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Budget Pool
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_reallocation_folder >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates the reallocation folder.
 *
 * Reallocation pool for a budget version and for a specific budget measurement
 * unit is created.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Budget unit and budget version should already exist.
 *
 * <p><b>Post Success</b><br>
 * Reallocation folder will be inserted in the database.
 *
 * <p><b>Post Failure</b><br>
 * Reallocation folder will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_folder_id If p_validate is false, then this uniquely identifies the
 * reallocation folder created. If p_validate is true, then set to null.
 * @param p_name Identifies folder/transaction name.
 * @param p_budget_version_id Identifies Parent folder.
 * @param p_budget_unit_id Measurement unit of the budget version for which the
 * pool is created.
 * @param p_entity_type Identifies the budgeted entity. Valid values are
 * defined by 'PQH_BUDGET_ENTITY' lookup type.
 * @param p_approval_status Indicates the approval status. Valid values are
 * defined by 'PQH_REALLOC_TXN_STATUS' lookup type.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created reallocation folder. If p_validate is true,
 * then the value will be null.
 * @param p_business_group_id Identifies business group.
 * @param p_wf_transaction_category_id Workflow transaction category
 * identifier.
 * @rep:displayname Create Reallocation Folder
 * @rep:category BUSINESS_ENTITY HR_BUDGET
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_reallocation_folder
(
   p_validate                       in boolean    default false
  ,p_effective_date                 in  date
  ,p_folder_id                      out nocopy   number
  ,p_name                           in  varchar2
  ,p_budget_version_id              in  number
  ,p_budget_unit_id                 in  number
  ,p_entity_type                    in  varchar2
  ,p_approval_status                in  varchar2
  ,p_object_version_number          out  nocopy  number
  ,p_business_group_id              in  number
  ,p_wf_transaction_category_id     in number
 );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_reallocation_folder >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the reallocation folder.
 *
 * Reallocation pool for a budget version and for a specific budget measurement
 * unit is updated.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Reallocation folder to be updated should already exist. Budget version and
 * budget unit should already exist.
 *
 * <p><b>Post Success</b><br>
 * Reallocation folder will be updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * Reallocation folder will not be updated and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_folder_id Identifies the reallocation folder.
 * @param p_name Identifies folder/transaction name.
 * @param p_budget_version_id Identifies Parent folder.
 * @param p_budget_unit_id Measurement unit of the budget version for which the
 * pool is created.
 * @param p_entity_type Identifies the budgeted entity. Valid values are
 * defined by 'PQH_BUDGET_ENTITY' lookup type.
 * @param p_approval_status Indicates the approval status. Valid values are
 * defined by 'PQH_REALLOC_TXN_STATUS' lookup type.
 * @param p_object_version_number Pass in the current version number of the
 * reallocation folder to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated reallocation
 * folder. If p_validate is true will be set to the same value which was passed
 * in
 * @param p_business_group_id Identifies business group.
 * @param p_wf_transaction_category_id Workflow transaction category
 * identifier.
 * @rep:displayname Update Reallocation Folder
 * @rep:category BUSINESS_ENTITY HR_BUDGET
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_reallocation_folder
  (
   p_validate                       in boolean    default false
  ,p_effective_date                 in  date
  ,p_folder_id                      in  number
  ,p_name                           in  varchar2  default hr_api.g_varchar2
  ,p_budget_version_id              in  number    default hr_api.g_number
  ,p_budget_unit_id                 in  number    default hr_api.g_number
  ,p_entity_type                    in  varchar2  default hr_api.g_varchar2
  ,p_approval_status                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_business_group_id              in number
  ,p_wf_transaction_category_id     in number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_reallocation_folder >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes the reallocation folder.
 *
 * Reallocation pool for a budget version and for a specific budget measurement
 * unit is deleted.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The reallocation folder to be deleted should already exist.
 *
 * <p><b>Post Success</b><br>
 * Reallocation folder will be deleted from the database.
 *
 * <p><b>Post Failure</b><br>
 * Reallocation folder will not be deleted and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_folder_id This uniquely identifies the reallocation folder.
 * @param p_object_version_number Current version number of the reallocation
 * folder to be deleted.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @rep:displayname Delete Reallocation Folder
 * @rep:category BUSINESS_ENTITY HR_BUDGET
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_reallocation_folder
  (
   p_validate                       in boolean        default false
  ,p_folder_id                        in number
  ,p_object_version_number          in number
  ,p_effective_date                 in date
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_reallocation_txn >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates the reallocation transaction.
 *
 * Reallocation transaction is a placeholder for linking the reallocation
 * folder and the reallocation transaction detail. Reallocation transaction has
 * to be created before creating reallocation transaction details. A
 * reallocation transaction must be balanced for it to be approved.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Reallocation folder should already exist.
 *
 * <p><b>Post Success</b><br>
 * Reallocation transaction will be inserted in the database.
 *
 * <p><b>Post Failure</b><br>
 * Reallocation transaction will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_transaction_id If p_validate is false, then this uniquely
 * identifies the reallocation transaction created. If p_validate is true, then
 * set to null.
 * @param p_name {@rep:casecolumn PQH_BUDGET_POOLS.NAME}
 * @param p_parent_folder_id Identifies Parent folder.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created reallocation transaction. If p_validate is
 * true, then the value will be null.
 * @param p_business_group_id Identifies business group.
 * @rep:displayname Create Reallocation Transaction
 * @rep:category BUSINESS_ENTITY HR_BUDGET
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_reallocation_txn
(
   p_validate                       in boolean    default false
  ,p_effective_date                 in  date
  ,p_transaction_id                 out  nocopy  number
  ,p_name                           in  varchar2
  ,p_parent_folder_id               in  number
  ,p_object_version_number          out  nocopy  number
  ,p_business_group_id              in  number

 );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_reallocation_txn >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the reallocation transaction.
 *
 * Reallocation transaction is a placeholder for linking the reallocation
 * folder and the reallocation transaction detail. A reallocation transaction
 * must be balanced for it to be approved.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The reallocation transaction to be updated should already exist.
 * Reallocation folder should already exist.
 *
 * <p><b>Post Success</b><br>
 * Reallocation transaction will be updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * Reallocation transaction will not be updated and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_transaction_id Identifies the reallocation transaction.
 * @param p_name Identifies folder/transaction name.
 * @param p_parent_folder_id Identifies parent folder.
 * @param p_object_version_number Pass in the current version number of the
 * reallocation transaction to be updated. When the API completes if p_validate
 * is false, will be set to the new version number of the updated reallocation
 * transaction. If p_validate is true will be set to the same value which was
 * passed in.
 * @param p_business_group_id Identifies business group.
 * @rep:displayname Update Reallocation Transaction
 * @rep:category BUSINESS_ENTITY HR_BUDGET
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_reallocation_txn
  (
   p_validate                       in      boolean    default false
  ,p_effective_date                 in      date
  ,p_transaction_id                 in      number
  ,p_name                           in      varchar2   default hr_api.g_varchar2
  ,p_parent_folder_id               in      number     default hr_api.g_number
  ,p_object_version_number          in out nocopy  number
  ,p_business_group_id              in      number     default hr_api.g_number

  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_reallocation_txn >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes the reallocation transaction.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The reallocation transaction to be deleted should already exist.
 *
 * <p><b>Post Success</b><br>
 * Reallocation transaction will be deleted from the database.
 *
 * <p><b>Post Failure</b><br>
 * Reallocation transaction will not be deleted and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_transaction_id This uniquely identifies the reallocation
 * transaction
 * @param p_object_version_number Current version number of the reallocation
 * transaction to be deleted.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @rep:displayname Delete Reallocation Transaction
 * @rep:category BUSINESS_ENTITY HR_BUDGET
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_reallocation_txn
  (
   p_validate                       in boolean        default false
  ,p_transaction_id                 in number
  ,p_object_version_number          in number
  ,p_effective_date                 in date
  );
--
end pqh_budget_pools_api;

 

/
