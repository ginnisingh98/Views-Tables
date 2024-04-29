--------------------------------------------------------
--  DDL for Package PQH_TXN_CAT_ATTRIBUTES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_TXN_CAT_ATTRIBUTES_API" AUTHID CURRENT_USER as
/* $Header: pqtcaapi.pkh 120.1 2005/10/02 02:28:20 aroussel $ */
/*#
 * This package contains transaction category attribute API.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Transaction Category Attribute
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_TXN_CAT_ATTRIBUTE >------------------------|
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
--   p_attribute_id                 Yes  number    Descriptive Flexfield
--   p_transaction_category_id      Yes  number
--   p_value_set_id                 No   number
--   p_transaction_table_route_id   No   number
--   p_form_column_name             No   varchar2
--   p_identifier_flag              No   varchar2
--   p_list_identifying_flag        No   varchar2
--   p_member_identifying_flag      No   varchar2
--   p_refresh_flag                 No   varchar2
--   p_select_flag                  No   varchar2
--   p_value_style_cd               No   varchar2
--   p_effective_date           Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_txn_category_attribute_id    Yes  number    Descriptive Flexfield
--   p_object_version_number        Yes  number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_TXN_CAT_ATTRIBUTE
(
   p_validate                       in boolean    default false
  ,p_txn_category_attribute_id      out nocopy number
  ,p_attribute_id                   in  number
  ,p_transaction_category_id        in  number
  ,p_value_set_id                   in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_transaction_table_route_id     in  number    default null
  ,p_form_column_name               in  varchar2  default null
  ,p_identifier_flag                in  varchar2  default null
  ,p_list_identifying_flag          in  varchar2  default null
  ,p_member_identifying_flag        in  varchar2  default null
  ,p_refresh_flag                   in  varchar2  default null
  ,p_select_flag                    in  varchar2  default null
  ,p_value_style_cd                 in  varchar2
  ,p_effective_date            in  date
 );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_txn_cat_attribute >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API allows updating transaction category attribute details.
 *
 * Each transaction type has its own unique set of attributes available and the
 * details of these attributes can be updated. Some of these transaction
 * category attributes can be selected for defining routing and approval rules,
 * which are then applied to position, budget, or reallocation transactions.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The transaction type to which the attributes belong must be in unfrozen
 * status.
 *
 * <p><b>Post Success</b><br>
 * The transaction category attribute is successfully updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The transaction category attribute is not updated and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_txn_category_attribute_id Identifies the transaction category
 * attribute record to modify.
 * @param p_attribute_id Identifies the attribute which is associated with a
 * transaction type.
 * @param p_transaction_category_id Obsolete parameter, do not use.
 * @param p_value_set_id Identifies the value set against which values entered
 * for this attribute must be validated in routing and approval rules.
 * @param p_object_version_number Pass in the current version number of the
 * transaction category attribute to be updated. When the API completes if
 * p_validate is false, will be set to the new version number of the updated
 * transaction category attribute. If p_validate is true will be set to the
 * same value which was passed in.
 * @param p_transaction_table_route_id Identifies the table to which the
 * attribute belongs.
 * @param p_form_column_name Identifies the form field which maps to the
 * transaction category attribute.
 * @param p_identifier_flag Indicates if the attribute can be selected for
 * defining routing/approval rules. Valid values are defined by 'YES_NO' lookup
 * type.
 * @param p_list_identifying_flag Indicates if the attribute is used in the
 * transaction type for defining routing rules. Valid values are defined by
 * 'YES_NO' lookup type.
 * @param p_member_identifying_flag Indicates if the attribute is used in the
 * transaction type for defining approval rules. Valid values are defined by
 * 'YES_NO' lookup type.
 * @param p_refresh_flag Indicates if the attribute value should be refreshed
 * from the master record when the attribute value in the transaction is
 * different from the value in the master record and the attribute value was
 * not updated by a user in the transaction record. Valid values are defined by
 * 'YES_NO' lookup type.
 * @param p_select_flag Indicates if the attribute can be selected as a
 * template attribute. In case of Position copy and Mass Processes, this flag
 * indicates if the attribute is used processing. Valid values are defined by
 * 'YES_NO' lookup type.
 * @param p_value_style_cd Indicates if the attribute value should be entered
 * as a range or as an exact value.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_delete_attr_ranges_flag Indicates if the routing rules defined
 * using an attribute must be deleted, when this attribute is updated to be no
 * longer used as list identifier. Similarly, this flag indicates if the
 * approval rules defined using an attribute must be deleted, when this
 * attribute is updated to be no longer used as member identifier.
 * @rep:displayname Update Transaction Category Attribute
 * @rep:category BUSINESS_ENTITY PQH_POS_CTRL_ROUTING
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_TXN_CAT_ATTRIBUTE
  (
   p_validate                       in boolean    default false
  ,p_txn_category_attribute_id      in  number
  ,p_attribute_id                   in  number    default hr_api.g_number
  ,p_transaction_category_id        in  number    default hr_api.g_number
  ,p_value_set_id                   in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_transaction_table_route_id     in  number    default hr_api.g_number
  ,p_form_column_name               in  varchar2  default hr_api.g_varchar2
  ,p_identifier_flag                in  varchar2  default hr_api.g_varchar2
  ,p_list_identifying_flag          in  varchar2  default hr_api.g_varchar2
  ,p_member_identifying_flag        in  varchar2  default hr_api.g_varchar2
  ,p_refresh_flag                   in  varchar2  default hr_api.g_varchar2
  ,p_select_flag                    in  varchar2  default hr_api.g_varchar2
  ,p_value_style_cd                 in  varchar2
  ,p_effective_date                 in  date
  ,p_delete_attr_ranges_flag        in  varchar2  default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_TXN_CAT_ATTRIBUTE >------------------------|
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
--   p_txn_category_attribute_id    Yes  number    Descriptive Flexfield
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
procedure delete_TXN_CAT_ATTRIBUTE
  (
   p_validate                       in boolean        default false
  ,p_txn_category_attribute_id      in number
  ,p_object_version_number          in number
  ,p_effective_date                 in date
  );
--
--
end pqh_TXN_CAT_ATTRIBUTES_api;

 

/
