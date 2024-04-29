--------------------------------------------------------
--  DDL for Package PQH_ROUTING_CATEGORIES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_ROUTING_CATEGORIES_API" AUTHID CURRENT_USER as
/* $Header: pqrctapi.pkh 120.1 2005/10/02 02:27:11 aroussel $ */
/*#
 * This package contains routing category APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Routing Category
*/
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_routing_category >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a routing category which identifies which routing
 * list/position hierarchy/supervisory hierarchy a transaction must be routed
 * to.
 *
 * If a routing category is created as the default routing category, all
 * transactions that do not satisfy any routing rules for a transaction type,
 * will be routed to the default routing category.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The transaction type for which the routing category is created must already
 * exist. The routing list or position hierarchy to which the transaction will
 * be routed must already exist. The override assignment/position/role/user
 * defined for the routing category must already exist.
 *
 * <p><b>Post Success</b><br>
 * The routing category is successfully created in the database.
 *
 * <p><b>Post Failure</b><br>
 * The routing category is not created and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_routing_category_id If p_validate is false, then this uniquely
 * identifies the routing category created. If p_validate is true, then set to
 * null.
 * @param p_transaction_category_id {@rep:casecolumn
 * PQH_ROUTING_CATEGORIES.TRANSACTION_CATEGORY_ID}
 * @param p_enable_flag Indicates if the routing category is enabled/disabled.
 * Valid values are defined by 'YES_NO' lookup_type.
 * @param p_default_flag Indicates if the routing category is the default
 * routing category for the transaction type. Valid values are defined by
 * 'YES_NO' lookup_type.
 * @param p_delete_flag Indicates if the routing category is marked for
 * deletion. Valid values are defined by 'YES_NO' lookup_type.
 * @param p_routing_list_id {@rep:casecolumn
 * PQH_ROUTING_CATEGORIES.ROUTING_LIST_ID}
 * @param p_position_structure_id {@rep:casecolumn
 * PQH_ROUTING_CATEGORIES.POSITION_STRUCTURE_ID}
 * @param p_override_position_id Identifies the position selected as override
 * approver for the transaction category.
 * @param p_override_assignment_id {@rep:casecolumn
 * PQH_ROUTING_CATEGORIES.OVERRIDE_ASSIGNMENT_ID}
 * @param p_override_role_id {@rep:casecolumn
 * PQH_ROUTING_CATEGORIES.OVERRIDE_ROLE_ID}
 * @param p_override_user_id {@rep:casecolumn
 * PQH_ROUTING_CATEGORIES.OVERRIDE_USER_ID}
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created routing category. If p_validate is true, then
 * the value will be null.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @rep:displayname Create Routing Category
 * @rep:category BUSINESS_ENTITY PQH_POS_CTRL_ROUTING
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_ROUTING_CATEGORY
(
   p_validate                       in boolean    default false
  ,p_routing_category_id            out nocopy number
  ,p_transaction_category_id        in  number    default null
  ,p_enable_flag                    in  varchar2  default 'Y'
  ,p_default_flag                   in  varchar2  default null
  ,p_delete_flag                   in  varchar2  default null
  ,p_routing_list_id                in  number    default null
  ,p_position_structure_id          in  number    default null
  ,p_override_position_id           in  number    default null
  ,p_override_assignment_id         in  number    default null
  ,p_override_role_id             in  number    default null
  ,p_override_user_id             in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date

 );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_routing_category >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates routing category details.
 *
 * The transaction type of a routing category cannot be updated.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The routing category to be updated must already exist. The transaction type
 * to which this routing category belongs, must be in an unfrozen status.
 *
 * <p><b>Post Success</b><br>
 * The routing category will be successfully updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The routing category will not be updated and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_routing_category_id Identifies the routing category record to be
 * modified.
 * @param p_transaction_category_id {@rep:casecolumn
 * PQH_ROUTING_CATEGORIES.TRANSACTION_CATEGORY_ID}
 * @param p_enable_flag Indicates if the routing category is enabled/disabled.
 * Valid values are defined by 'YES_NO' lookup_type.
 * @param p_default_flag Indicates if the routing category is the default
 * routing category for the transaction type. Valid values are defined by
 * 'YES_NO' lookup_type.
 * @param p_delete_flag Indicates if the routing category is marked for
 * deletion. Valid values are defined by 'YES_NO' lookup_type.
 * @param p_routing_list_id {@rep:casecolumn
 * PQH_ROUTING_CATEGORIES.ROUTING_LIST_ID}
 * @param p_position_structure_id {@rep:casecolumn
 * PQH_ROUTING_CATEGORIES.POSITION_STRUCTURE_ID}
 * @param p_override_position_id Position selected as override approver for the
 * transaction category.
 * @param p_override_assignment_id {@rep:casecolumn
 * PQH_ROUTING_CATEGORIES.OVERRIDE_ASSIGNMENT_ID}
 * @param p_override_role_id {@rep:casecolumn
 * PQH_ROUTING_CATEGORIES.OVERRIDE_ROLE_ID}
 * @param p_override_user_id {@rep:casecolumn
 * PQH_ROUTING_CATEGORIES.OVERRIDE_USER_ID}
 * @param p_object_version_number Pass in the current version number of the
 * routing category to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated routing
 * category. If p_validate is true will be set to the same value which was
 * passed in.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @rep:displayname Update Routing Category
 * @rep:category BUSINESS_ENTITY PQH_POS_CTRL_ROUTING
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_ROUTING_CATEGORY
  (
   p_validate                       in boolean    default false
  ,p_routing_category_id            in  number
  ,p_transaction_category_id        in  number    default hr_api.g_number
  ,p_enable_flag                    in  varchar2  default hr_api.g_varchar2
  ,p_default_flag                    in  varchar2  default hr_api.g_varchar2
  ,p_delete_flag                    in  varchar2  default hr_api.g_varchar2
  ,p_routing_list_id                in  number    default hr_api.g_number
  ,p_position_structure_id          in  number    default hr_api.g_number
  ,p_override_position_id           in  number    default hr_api.g_number
  ,p_override_assignment_id         in  number    default hr_api.g_number
  ,p_override_role_id             in  number    default hr_api.g_number
  ,p_override_user_id             in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_routing_category >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes routing category.
 *
 * A routing category cannot be deleted if routing history exists for it. If
 * the routing category is no longer needed, the alternate option to deleting
 * it is to disable it.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The routing category that is to be deleted must already exist. There must be
 * no routing or approval rules associated with the routing category. The
 * routing category must not have been previously used to route transactions.
 *
 * <p><b>Post Success</b><br>
 * The routing category is successfully deleted from the database.
 *
 * <p><b>Post Failure</b><br>
 * The routing category will not be deleted and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_routing_category_id Identifies the routing category record to be
 * deleted.
 * @param p_object_version_number Current version number of the routing
 * category to be deleted.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @rep:displayname Delete Routing Category
 * @rep:category BUSINESS_ENTITY PQH_POS_CTRL_ROUTING
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_ROUTING_CATEGORY
  (
   p_validate                       in boolean        default false
  ,p_routing_category_id            in number
  ,p_object_version_number          in number
  ,p_effective_date                 in  date
  );
--
--
Procedure disable_routing_categories
(p_transaction_category_id in pqh_transaction_categories.transaction_category_id%type,
 p_routing_type            in pqh_transaction_categories.member_cd%type);
--
--
end pqh_ROUTING_CATEGORIES_api;

 

/
