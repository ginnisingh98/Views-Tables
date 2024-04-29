--------------------------------------------------------
--  DDL for Package PQH_ATTRIBUTE_RANGES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_ATTRIBUTE_RANGES_API" AUTHID CURRENT_USER as
/* $Header: pqrngapi.pkh 120.1 2005/10/02 02:27:43 aroussel $ */
/*#
 * This package contains attribute range APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Attribute Range
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_attribute_range >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates an attribute range that makes up an approval or routing
 * rule.
 *
 * A routing or approval rule consists of one or more conditions that must all
 * be met for the rule to be satisfied. Attribute range makes up one condition.
 * The user enters the from and to values when creating the attribute range,
 * that a transaction attribute must satisfy, to be routed to a particular
 * routing category or approver.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The user must have selected one or more transaction category attributes as
 * routing and approval attributes. The position hierarchy/supervisory
 * hierarchy/routing list for which routing rules are defined must already
 * exist. The position/assignment/routing list member for which the approval
 * rules are defined must already exist.
 *
 * <p><b>Post Success</b><br>
 * The attribute range is created successfully in the database.
 *
 * <p><b>Post Failure</b><br>
 * The attribute range is not created and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_attribute_range_id If p_validate is false, then this uniquely
 * identifies the attribute range created. If p_validate is true, then set to
 * null.
 * @param p_approver_flag Identifies if rule is an approval rule. Valid values
 * are defined by 'YES_NO' lookup_type.
 * @param p_enable_flag Identifies if rule is enabled/disabled. Valid values
 * are defined by 'YES_NO' lookup_type.
 * @param p_delete_flag Identifies if rule is marked for deletion. Valid values
 * are defined by 'YES_NO' lookup_type.
 * @param p_assignment_id Identifies the assignment for which the approval rule
 * is defined.
 * @param p_attribute_id Identifies the attribute for which the range of values
 * are entered.
 * @param p_from_char Starting varchar2 value of the range.
 * @param p_from_date Starting date value of the range.
 * @param p_from_number Starting number value of the range.
 * @param p_position_id Identifies the position for which the approval rule is
 * defined.
 * @param p_range_name Rule name.
 * @param p_routing_category_id Identifies the routing category for which
 * routing rules are defined.
 * @param p_routing_list_member_id Identifies the routing list member for which
 * the approval rule is defined.
 * @param p_to_char Ending varchar2 value of the range.
 * @param p_to_date Ending date value of the range.
 * @param p_to_number Ending number value of the range.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created attribute range. If p_validate is true, then
 * the value will be null.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @rep:displayname Create Attribute Range
 * @rep:category BUSINESS_ENTITY PQH_POS_CTRL_ROUTING
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_ATTRIBUTE_RANGE
(
   p_validate                       in boolean    default false
  ,p_attribute_range_id             out nocopy number
  ,p_approver_flag                  in  varchar2  default null
  ,p_enable_flag                    in  varchar2  default 'Y'
  ,p_delete_flag                    in  varchar2  default null
  ,p_assignment_id                  in  number    default null
  ,p_attribute_id                   in  number    default null
  ,p_from_char                      in  varchar2  default null
  ,p_from_date                      in  date      default null
  ,p_from_number                    in  number    default null
  ,p_position_id                    in  number    default null
  ,p_range_name                     in  varchar2
  ,p_routing_category_id            in  number
  ,p_routing_list_member_id         in  number    default null
  ,p_to_char                        in  varchar2  default null
  ,p_to_date                        in  date      default null
  ,p_to_number                      in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
 );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_attribute_range >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates attribute range values.
 *
 * When an attribute range values are updated, the application does not
 * validate the conditions entered in the from/to value fields. It is up to the
 * user to ensure that values entered are valid, as defined by the
 * organization's unique implementation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The attribute range to be updated must already exist. Updating an attribute
 * range values must not cause routing rules for a transaction type to overlap.
 * Updating an attribute range values must not cause approval rules for an
 * approver to overlap.
 *
 * <p><b>Post Success</b><br>
 * The attribute range is updated successfully in the database.
 *
 * <p><b>Post Failure</b><br>
 * The attribute range is not updated and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_attribute_range_id Identifies uniquely the attribute range to be
 * modified.
 * @param p_approver_flag Identifies if rule is an approval rule. Valid values
 * are defined by 'YES_NO' lookup_type.
 * @param p_enable_flag Identifies if rule is enabled/disabled. Valid values
 * are defined by 'YES_NO' lookup_type.
 * @param p_delete_flag Identifies if rule is marked for deletion. Valid values
 * are defined by 'YES_NO' lookup_type.
 * @param p_assignment_id Identifies the assignment for which the approval rule
 * is defined.
 * @param p_attribute_id Identifies the attribute for which the range of values
 * are entered.
 * @param p_from_char Starting varchar2 value of the range.
 * @param p_from_date Starting date value of the range.
 * @param p_from_number Starting number value of the range.
 * @param p_position_id Identifies the position for which the approval rule is
 * defined..
 * @param p_range_name Rule name.
 * @param p_routing_category_id Identifies the routing category for which
 * routing rules are defined.
 * @param p_routing_list_member_id Identifies the routing list member for which
 * the approval rule is defined.
 * @param p_to_char Ending varchar2 value of the range.
 * @param p_to_date Ending date value of the range.
 * @param p_to_number Ending number value of the range.
 * @param p_object_version_number Pass in the current version number of the
 * attribute range to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated attribute range.
 * If p_validate is true will be set to the same value which was passed in.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @rep:displayname Update Attribute Range
 * @rep:category BUSINESS_ENTITY PQH_POS_CTRL_ROUTING
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_ATTRIBUTE_RANGE
  (
   p_validate                       in boolean    default false
  ,p_attribute_range_id             in  number
  ,p_approver_flag                  in  varchar2  default hr_api.g_varchar2
  ,p_enable_flag                  in  varchar2  default hr_api.g_varchar2
  ,p_delete_flag                  in  varchar2  default hr_api.g_varchar2
  ,p_assignment_id                  in  number    default hr_api.g_number
  ,p_attribute_id                   in  number    default hr_api.g_number
  ,p_from_char                      in  varchar2  default hr_api.g_varchar2
  ,p_from_date                      in  date      default hr_api.g_date
  ,p_from_number                    in  number    default hr_api.g_number
  ,p_position_id                    in  number    default hr_api.g_number
  ,p_range_name                     in  varchar2  default hr_api.g_varchar2
  ,p_routing_category_id            in  number    default hr_api.g_number
  ,p_routing_list_member_id         in  number    default hr_api.g_number
  ,p_to_char                        in  varchar2  default hr_api.g_varchar2
  ,p_to_date                        in  date      default hr_api.g_date
  ,p_to_number                      in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date            in  date
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_attribute_range >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes an attribute range record.
 *
 * Deleting an attribute range removes a condition that makes up the routing or
 * approval rule.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The attribute range to be deleted must already exist. Deleting an attribute
 * range must not cause routing rules for a transaction type to overlap.
 * Deleting an attribute range must not cause approval rules for an approver to
 * overlap. The routing/approval rule must not have already been used to route
 * transactions.
 *
 * <p><b>Post Success</b><br>
 * The attribute range is deleted successfully from the database.
 *
 * <p><b>Post Failure</b><br>
 * The attribute range is not deleted and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_attribute_range_id Identifies uniquely the attribute range to be
 * deleted.
 * @param p_object_version_number Current version number of the attribute range
 * to be deleted.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @rep:displayname Delete Attribute Range
 * @rep:category BUSINESS_ENTITY PQH_POS_CTRL_ROUTING
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_ATTRIBUTE_RANGE
  (
   p_validate                       in boolean        default false
  ,p_attribute_range_id             in number
  ,p_object_version_number          in number
  ,p_effective_date                 in date
  );
--
--
end pqh_ATTRIBUTE_RANGES_api;

 

/
