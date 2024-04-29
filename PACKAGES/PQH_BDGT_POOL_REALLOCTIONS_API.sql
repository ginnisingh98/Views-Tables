--------------------------------------------------------
--  DDL for Package PQH_BDGT_POOL_REALLOCTIONS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_BDGT_POOL_REALLOCTIONS_API" AUTHID CURRENT_USER as
/* $Header: pqbreapi.pkh 120.1 2005/10/02 02:26:09 aroussel $ */
/*#
 * This API creates the budget pool reallocation transaction detail.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Budget Pool Reallocation
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_realloc_txn_dtl >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates the budget pool reallocation transaction detail.
 *
 * The period details for an existing donor and receiver entity details are
 * created. One donor can have multiple receivers but one receiver cannot have
 * multiple donors. Budget version of a controlled budget must already exist
 * for the donor transaction details.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Budget reallocation transaction should already exist.
 *
 * <p><b>Post Success</b><br>
 * Budget reallocation transaction detail will be successfully inserted in the
 * database.
 *
 * <p><b>Post Failure</b><br>
 * Budget reallocation transaction detail will not be created and an error will
 * be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_transaction_id Identifies the reallocation pool.
 * @param p_transaction_type Indicates the reallocation transaction type. Valid
 * values are defined by 'PQH_REALLOC_RECORD_TYPE' lookup type. Valid lookup
 * codes are 'D' and 'R'.
 * @param p_entity_id {@rep:casecolumn PQH_BDGT_POOL_REALLOCTIONS.ENTITY_ID}
 * @param p_budget_detail_id Budget detail identifier.
 * @param p_txn_detail_id This uniquely identifies the reallocation transaction
 * detail.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created reallocation pool transaction detail. If
 * p_validate is true, then the value will be null.
 * @rep:displayname Create Reallocation Pool Transaction Detail
 * @rep:category BUSINESS_ENTITY HR_BUDGET
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_realloc_txn_dtl
(
   p_validate                       in  boolean    default false
  ,p_effective_date                 in  date
  ,p_transaction_id                 in  number
  ,p_transaction_type               in  varchar2
  ,p_entity_id                      in  number  default null
  ,p_budget_detail_id               in  number  default null
  ,p_txn_detail_id            out nocopy number
  ,p_object_version_number          out nocopy number
 );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_realloc_txn_dtl >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the budget pool reallocation transaction detail.
 *
 * The period details for an existing donor and receiver entity details are
 * updated. One donor can have multiple receivers but one receiver cannot have
 * multiple donors. Budget version of a controlled budget should already exist
 * for the donor transaction details.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The reallocation transaction detail to be updated should already exist.
 *
 * <p><b>Post Success</b><br>
 * The reallocation transaction detail will be successfully updated.
 *
 * <p><b>Post Failure</b><br>
 * The reallocation transaction detail will not be updated and an error will be
 * raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_transaction_id Identifies the reallocation pool.
 * @param p_transaction_type Indicates the reallocation transaction type. Valid
 * values are defined by 'PQH_REALLOC_RECORD_TYPE' lookup type. Valid lookup
 * codes are 'D' and 'R'.
 * @param p_entity_id {@rep:casecolumn PQH_BDGT_POOL_REALLOCTIONS.ENTITY_ID}
 * @param p_budget_detail_id Budget detail identifier.
 * @param p_txn_detail_id This uniquely identifies the reallocation transaction
 * detail.
 * @param p_object_version_number Pass in the current version number of the
 * reallocation transaction detail to be updated. When the API completes if
 * p_validate is false, will be set to the new version number of the updated
 * reallocation transaction. If p_validate is true will be set to the same
 * value which was passed in.
 * @rep:displayname Update Reallocation Pool Transaction Detail
 * @rep:category BUSINESS_ENTITY HR_BUDGET
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_realloc_txn_dtl
(
   p_validate                       in  boolean    default false
  ,p_effective_date                 in  date
  ,p_transaction_id                 in  number  default hr_api.g_number
  ,p_transaction_type               in  varchar2 default hr_api.g_varchar2
  ,p_entity_id                      in  number  default hr_api.g_number
  ,p_budget_detail_id               in  number  default hr_api.g_number
  ,p_txn_detail_id            in  number
  ,p_object_version_number          in  out nocopy number
 );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_realloc_txn_dtl >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes the budget pool reallocation transaction detail.
 *
 * The donor and receiver entity details are deleted.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The reallocation transaction to be deleted should already exist.
 *
 * <p><b>Post Success</b><br>
 * Reallocation transaction detail for a budget will be successfully deleted
 * from the database.
 *
 * <p><b>Post Failure</b><br>
 * Reallocation transaction detail for a budget will not be deleted and an
 * error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_txn_detail_id This uniquely identifies the reallocation transaction
 * detail.
 * @param p_object_version_number Current version number of the reallocation
 * transaction detail to be deleted.
 * @rep:displayname Delete Reallocation Pool Transaction Detail
 * @rep:category BUSINESS_ENTITY HR_BUDGET
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_realloc_txn_dtl
  (
   p_validate                       in boolean        default false
  ,p_txn_detail_id            in number
  ,p_object_version_number          in number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_realloc_txn_period >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates transaction periods for reallocation.
 *
 * The period details for a existing donor or receiver is created. The values
 * entered should correspond to the existing budget units.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Budget pool reallocation detail should already exist.
 *
 * <p><b>Post Success</b><br>
 * Budget reallocation transaction period will be successfully inserted in the
 * database.
 *
 * <p><b>Post Failure</b><br>
 * Budget reallocation transaction period will not be created and an error will
 * be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_txn_detail_id Identifies the folder transaction.
 * @param p_transaction_type Indicates the reallocation transaction type. Valid
 * values are defined by 'PQH_REALLOC_RECORD_TYPE' lookup type.
 * @param p_entity_id {@rep:casecolumn PQH_BDGT_POOL_REALLOCTIONS.ENTITY_ID}
 * @param p_budget_period_id Budget period identifier.
 * @param p_start_date Period start date.
 * @param p_end_date Period end date.
 * @param p_reallocation_amt {@rep:casecolumn
 * PQH_BDGT_POOL_REALLOCTIONS.REALLOCATION_AMT}
 * @param p_reserved_amt {@rep:casecolumn
 * PQH_BDGT_POOL_REALLOCTIONS.RESERVED_AMT}
 * @param p_reallocation_period_id This uniquely identifies the reallocation
 * transaction period.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created reallocation period. If p_validate is true,
 * then the value will be null.
 * @rep:displayname Create Reallocation Transaction Period
 * @rep:category BUSINESS_ENTITY HR_BUDGET
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_realloc_txn_period
(
   p_validate                       in  boolean    default false
  ,p_effective_date                 in  date
  ,p_txn_detail_id            in  number
  ,p_transaction_type               in  varchar2
  ,p_entity_id                      in  number  default null
  ,p_budget_period_id               in  number  default null
  ,p_start_date                     in  date    default null
  ,p_end_date                       in  date    default null
  ,p_reallocation_amt               in  number
  ,p_reserved_amt                   in  number  default null
  ,p_reallocation_period_id            out nocopy number
  ,p_object_version_number          out nocopy number
 );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_realloc_txn_period >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates transaction periods for reallocation.
 *
 * The period details for an existing donor or receiver is updated. The values
 * entered should correspond to the existing budget units.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Reallocation period to be updated should exist.
 *
 * <p><b>Post Success</b><br>
 * Budget reallocation transaction period will be successfully updated in the
 * database.
 *
 * <p><b>Post Failure</b><br>
 * Budget reallocation transaction period will not be updated and an error will
 * be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_txn_detail_id Identifies the folder transaction.
 * @param p_transaction_type Indicates the reallocation transaction type. Valid
 * values are defined by 'PQH_REALLOC_RECORD_TYPE' lookup type.
 * @param p_entity_id {@rep:casecolumn PQH_BDGT_POOL_REALLOCTIONS.ENTITY_ID}
 * @param p_budget_period_id Budget period identifier.
 * @param p_start_date Period start date.
 * @param p_end_date Period end date.
 * @param p_reallocation_amt {@rep:casecolumn
 * PQH_BDGT_POOL_REALLOCTIONS.REALLOCATION_AMT}
 * @param p_reserved_amt {@rep:casecolumn
 * PQH_BDGT_POOL_REALLOCTIONS.RESERVED_AMT}
 * @param p_reallocation_period_id This uniquely identifies the reallocation
 * transaction period.
 * @param p_object_version_number Pass in the current version number of the
 * reallocation period to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated reallocation
 * period. If p_validate is true will be set to the same value which was passed
 * in.
 * @rep:displayname Update Reallocation Transaction Period
 * @rep:category BUSINESS_ENTITY HR_BUDGET
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_realloc_txn_period
(
   p_validate                       in  boolean    default false
  ,p_effective_date                 in  date
  ,p_txn_detail_id            in  number   default hr_api.g_number
  ,p_transaction_type               in  varchar2 default hr_api.g_varchar2
  ,p_entity_id                      in  number  default hr_api.g_number
  ,p_budget_period_id               in  number  default hr_api.g_number
  ,p_start_date                     in  date    default hr_api.g_date
  ,p_end_date                       in  date    default hr_api.g_date
  ,p_reallocation_amt               in  number  default hr_api.g_number
  ,p_reserved_amt                   in  number  default hr_api.g_number
  ,p_reallocation_period_id               in  number
  ,p_object_version_number          in out nocopy number
 );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_realloc_txn_period >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This deletes the reallocation transaction period.
 *
 * Period details for a existing donor or receiver is deleted.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Reallocation period to be deleted should exist.
 *
 * <p><b>Post Success</b><br>
 * Budget reallocation transaction period will be successfully deleted in the
 * database.
 *
 * <p><b>Post Failure</b><br>
 * Budget reallocation transaction period will not be deleted and an error will
 * be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_reallocation_period_id This uniquely identifies the reallocation
 * transaction period.
 * @param p_object_version_number Current version number of the reallocation
 * transaction period to be deleted.
 * @rep:displayname Delete Reallocation Transaction Period
 * @rep:category BUSINESS_ENTITY HR_BUDGET
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_realloc_txn_period
  (
   p_validate                       in boolean        default false
  ,p_reallocation_period_id            in number
  ,p_object_version_number          in number
  );
--
--
end pqh_BDGT_POOL_REALLOCTIONS_api;

 

/
