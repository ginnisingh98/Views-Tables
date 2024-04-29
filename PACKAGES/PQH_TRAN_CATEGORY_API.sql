--------------------------------------------------------
--  DDL for Package PQH_TRAN_CATEGORY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_TRAN_CATEGORY_API" AUTHID CURRENT_USER as
/* $Header: pqtctapi.pkh 120.1 2005/10/02 02:28:26 aroussel $ */
/*#
 * This package contains transaction category API.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Transaction Category
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_TRAN_CATEGORY >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--   p_custom_wf_process_name       No   varchar2
--   p_custom_workflow_name         No   varchar2
--   p_form_name                    Yes  varchar2
--   p_freeze_status_cd             No   varchar2
--   p_future_action_cd             Yes  varchar2
--   p_member_cd                    Yes  varchar2
--   p_name                         Yes  varchar2
--   p_short_name                         Yes  varchar2
--   p_post_style_cd                Yes  varchar2
--   p_post_txn_function            Yes  varchar2
--   p_route_validated_txn_flag     Yes  varchar2
--   p_workflow_enable_flag         Yes  varchar2
--   p_enable_flag         Yes  varchar2
--   p_timeout_days                 No   number
--   p_consolidated_table_route_id  Yes  number
--   p_master_table_route_id  Yes  number
--   p_effective_date           Yes  date      Session Date.
--   p_language_code                     Yes  language   For translation
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_transaction_category_id      Yes  number    PK of record
--   p_object_version_number        Yes  number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_TRAN_CATEGORY
(
   p_validate                       in boolean    default false
  ,p_transaction_category_id        out nocopy number
  ,p_custom_wf_process_name         in  varchar2  default null
  ,p_custom_workflow_name           in  varchar2  default null
  ,p_form_name                      in  varchar2
  ,p_freeze_status_cd               in  varchar2  default null
  ,p_future_action_cd               in  varchar2
  ,p_member_cd                      in  varchar2
  ,p_name                           in  varchar2
  ,p_short_name                     in  varchar2
  ,p_post_style_cd                  in  varchar2
  ,p_post_txn_function              in  varchar2
  ,p_route_validated_txn_flag       in  varchar2
  ,p_prevent_approver_skip          in  varchar2  default null
  ,p_workflow_enable_flag           in  varchar2  default null
  ,p_enable_flag                    in  varchar2  default 'Y'
  ,p_timeout_days                   in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_consolidated_table_route_id    in  number
  ,p_business_group_id              in  number    default null
  ,p_setup_type_cd                  in  varchar2  default null
  ,p_master_table_route_id          in  number    default null
  ,p_effective_date            in  date
  ,p_language_code                  in  varchar2  default hr_api.userenv_lang
 );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_tran_category >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates transaction type details.
 *
 * The transaction type setup defines how the related transactions will be
 * routed. The routing style of a transaction type cannot be changed if there
 * are pending transactions routed to that transaction type.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * If the transaction type is for a specific business group, the business group
 * must already exist. The routing style of the transaction category can be
 * updated only if there are no pending transactions for the transaction type.
 *
 * <p><b>Post Success</b><br>
 * The transaction type details are successfully updated.
 *
 * <p><b>Post Failure</b><br>
 * The transaction type details will not be updated and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_transaction_category_id Identifies the transaction type record to
 * be modified.
 * @param p_custom_wf_process_name {@rep:casecolumn
 * PQH_TRANSACTION_CATEGORIES.CUSTOM_WF_PROCESS_NAME}
 * @param p_custom_workflow_name {@rep:casecolumn
 * PQH_TRANSACTION_CATEGORIES.CUSTOM_WORKFLOW_NAME}
 * @param p_form_name {@rep:casecolumn PQH_TRANSACTION_CATEGORIES.FORM_NAME}
 * @param p_freeze_status_cd Transaction type setup status. Valid values are
 * defined by 'PQH_CATEGORY_FREEZE_STATUS' lookup type.
 * @param p_future_action_cd Future Action values. Valid values are defined by
 * 'PQH_FUTURE_ACTION' lookup type.
 * @param p_member_cd Transaction routing style. Valid values are defined by
 * 'PQH_MEMBER_CD' lookup type.
 * @param p_name Transaction type name.
 * @param p_short_name {@rep:casecolumn PQH_TRANSACTION_CATEGORIES.SHORT_NAME}
 * @param p_post_style_cd Transaction posting style. Valid values are defined
 * by 'PQH_POST_STYLE' lookup type.
 * @param p_post_txn_function {@rep:casecolumn
 * PQH_TRANSACTION_CATEGORIES.POST_TXN_FUNCTION}
 * @param p_route_validated_txn_flag Used to check if routed transaction must
 * be validated. Valid values are defined by 'YES_NO' lookup type.
 * @param p_prevent_approver_skip Identifies if bypass of approvers is allowed.
 * Valid values are defined by 'YES_NO' lookup_type. Default Value is 'N'.
 * @param p_workflow_enable_flag Used to enable workflow for transaction
 * routing. Valid values are defined by 'YES_NO' lookup type.
 * @param p_enable_flag Used to enable or disable transaction type. Valid
 * values are defined by 'YES_NO' lookup type.
 * @param p_timeout_days Number of days after which the transaction would be
 * returned to the initiator if no response has been made.
 * @param p_object_version_number Pass in the current version number of the
 * transaction type to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated transaction
 * type. If p_validate is true will be set to the same value which was passed
 * in.
 * @param p_consolidated_table_route_id {@rep:casecolumn
 * PQH_TRANSACTION_CATEGORIES.CONSOLIDATED_TABLE_ROUTE_ID}
 * @param p_business_group_id {@rep:casecolumn
 * PQH_TRANSACTION_CATEGORIES.BUSINESS_GROUP_ID}
 * @param p_setup_type_cd The setup level of the transaction type. Valid values
 * are defined by 'PQH_TXN_CAT_SETUP_TYPE' lookup type.
 * @param p_master_table_route_id {@rep:casecolumn
 * PQH_TRANSACTION_CATEGORIES.MASTER_TABLE_ROUTE_ID}
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @rep:displayname Update Transaction Category
 * @rep:category BUSINESS_ENTITY PQH_POS_CTRL_ROUTING
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_TRAN_CATEGORY
  (
   p_validate                       in boolean    default false
  ,p_transaction_category_id        in  number
  ,p_custom_wf_process_name         in  varchar2  default hr_api.g_varchar2
  ,p_custom_workflow_name           in  varchar2  default hr_api.g_varchar2
  ,p_form_name                      in  varchar2  default hr_api.g_varchar2
  ,p_freeze_status_cd               in  varchar2  default hr_api.g_varchar2
  ,p_future_action_cd               in  varchar2  default hr_api.g_varchar2
  ,p_member_cd                      in  varchar2  default hr_api.g_varchar2
  ,p_name                           in  varchar2  default hr_api.g_varchar2
  ,p_short_name                     in  varchar2  default hr_api.g_varchar2
  ,p_post_style_cd                  in  varchar2  default hr_api.g_varchar2
  ,p_post_txn_function              in  varchar2  default hr_api.g_varchar2
  ,p_route_validated_txn_flag       in  varchar2  default hr_api.g_varchar2
  ,p_prevent_approver_skip          in  varchar2  default hr_api.g_varchar2
  ,p_workflow_enable_flag           in  varchar2  default hr_api.g_varchar2
  ,p_enable_flag                    in  varchar2  default hr_api.g_varchar2
  ,p_timeout_days                   in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_consolidated_table_route_id    in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_setup_type_cd                  in  varchar2  default hr_api.g_varchar2
  ,p_master_table_route_id    in  number    default hr_api.g_number
  ,p_effective_date            in  date
  ,p_language_code                  in  varchar2  default hr_api.userenv_lang
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_TRAN_CATEGORY >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--   p_transaction_category_id      Yes  number    PK of record
--   p_effective_date          Yes  date     Session Date.
--
-- Post Success:
--
--   Name                           Type     Description
--   p_object_version_number        Yes  number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_TRAN_CATEGORY
  (
   p_validate                       in boolean        default false
  ,p_transaction_category_id        in number
  ,p_object_version_number          in number
  ,p_effective_date                 in date
  );
--
end pqh_TRAN_CATEGORY_api;

 

/
