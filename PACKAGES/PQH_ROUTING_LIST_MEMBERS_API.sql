--------------------------------------------------------
--  DDL for Package PQH_ROUTING_LIST_MEMBERS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_ROUTING_LIST_MEMBERS_API" AUTHID CURRENT_USER as
/* $Header: pqrlmapi.pkh 120.1 2005/10/02 02:27:30 aroussel $ */
/*#
 * This package contains routing list members APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Routing List Member
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_routing_list_member >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a routing list member to whom a transaction can be routed
 * in a routing list.
 *
 * A routing list member is a destination for routing a transaction. By
 * selecting a role, a group of people can be selected as a routing list
 * member. A specific person can be selected as routing list member by
 * selecting a user.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The role and user selected as routing list member must already exist.
 *
 * <p><b>Post Success</b><br>
 * The routing list member is successfully created in the database.
 *
 * <p><b>Post Failure</b><br>
 * The routing list member is not created and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_role_id {@rep:casecolumn PQH_ROUTING_LIST_MEMBERS.ROLE_ID}
 * @param p_routing_list_id {@rep:casecolumn
 * PQH_ROUTING_LIST_MEMBERS.ROUTING_LIST_ID}
 * @param p_routing_list_member_id If p_validate is false, then this uniquely
 * identifies the routing list member created. If p_validate is true, then set
 * to null.
 * @param p_seq_no Sequential number order of members within routing list.
 * @param p_approver_flag Identifies if the routing list member is an approver
 * or not for this associated routing list. Valid values are defined by
 * 'YES_NO' lookup type.
 * @param p_enable_flag Identifies if the routing list member is
 * enabled/disabled. Valid values are defined by 'YES_NO' lookup type.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created routing list member. If p_validate is true,
 * then the value will be null.
 * @param p_user_id User identifier.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @rep:displayname Create Routing List Member
 * @rep:category BUSINESS_ENTITY PQH_POS_CTRL_ROUTING
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_routing_list_member
(
   p_validate                       in boolean    default false
  ,p_role_id                        in  number    default null
  ,p_routing_list_id                in  number    default null
  ,p_routing_list_member_id         out nocopy number
  ,p_seq_no                         in  number    default null
  ,p_approver_flag                  in  varchar2  default null
  ,p_enable_flag		    in  varchar2  default 'Y'
  ,p_object_version_number          out nocopy number
  ,p_user_id                        in  number    default null
  ,p_effective_date            in  date
 );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_routing_list_member >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates routing list member details.
 *
 * The routing list member can be set up as an approver for the routing list.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The routing list member to be updated must already exist.
 *
 * <p><b>Post Success</b><br>
 * The routing list member is successfully updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The routing list member is not updated and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_role_id {@rep:casecolumn PQH_ROUTING_LIST_MEMBERS.ROLE_ID}
 * @param p_routing_list_id {@rep:casecolumn
 * PQH_ROUTING_LIST_MEMBERS.ROUTING_LIST_ID}
 * @param p_routing_list_member_id Identifies the routing list member to be
 * modified.
 * @param p_seq_no Sequential number order of members within routing list.
 * @param p_approver_flag Identifies if the routing list member is an approver
 * or not for this associated routing list. Valid values are defined by
 * 'YES_NO' lookup type.
 * @param p_enable_flag Identifies if the routing list member is
 * enabled/disabled. Valid values are defined by 'YES_NO' lookup type.
 * @param p_object_version_number Pass in the current version number of the
 * routing list member to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated routing list
 * member. If p_validate is true will be set to the same value which was passed
 * in.
 * @param p_user_id User identifier.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @rep:displayname Update Routing List Member
 * @rep:category BUSINESS_ENTITY PQH_POS_CTRL_ROUTING
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_routing_list_member
  (
   p_validate                       in boolean    default false
  ,p_role_id                        in  number    default hr_api.g_number
  ,p_routing_list_id                in  number    default hr_api.g_number
  ,p_routing_list_member_id         in  number
  ,p_seq_no                         in  number    default hr_api.g_number
  ,p_approver_flag                  in  varchar2  default hr_api.g_varchar2
  ,p_enable_flag                    in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_user_id                        in  number    default hr_api.g_number
  ,p_effective_date            in  date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_routing_list_member >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a routing list member.
 *
 * If the routing list member cannot be deleted because previous routing
 * history exists for it, then it can be disabled.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The routing list member to be deleted must already exist. The routing list
 * member cannot be deleted if a transaction has been routed to the routing
 * list containing the member and the transaction is pending approval.
 *
 * <p><b>Post Success</b><br>
 * The routing list member is successfully deleted from the database.
 *
 * <p><b>Post Failure</b><br>
 * The routing list member is not deleted and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_routing_list_member_id Identifies the routing list member to be
 * deleted.
 * @param p_object_version_number Current version number of the routing list
 * member to be deleted.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @rep:displayname Delete Routing List Member
 * @rep:category BUSINESS_ENTITY PQH_POS_CTRL_ROUTING
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_routing_list_member
  (
   p_validate                       in boolean        default false
  ,p_routing_list_member_id         in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date            in date
  );
--
--
end PQH_ROUTING_LIST_MEMBERS_api;

 

/
