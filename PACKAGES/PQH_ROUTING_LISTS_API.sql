--------------------------------------------------------
--  DDL for Package PQH_ROUTING_LISTS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_ROUTING_LISTS_API" AUTHID CURRENT_USER as
/* $Header: pqrltapi.pkh 120.1 2005/10/02 02:27:40 aroussel $ */
/*#
 * This package contains routing list APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Routing List
*/
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_routing_list >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a routing list which is a sequence of destinations for
 * routing a transaction.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A routing list with duplicate name should not exist.
 *
 * <p><b>Post Success</b><br>
 * The routing list is successfully created in the database.
 *
 * <p><b>Post Failure</b><br>
 * The routing list is not created and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_routing_list_id If p_validate is false, then this uniquely
 * identifies the routing list created. If p_validate is true, then set to
 * null.
 * @param p_routing_list_name Unique routing list name.
 * @param p_enable_flag Indicates if the routing list is enabled/disabled.
 * Valid values are defined by 'PQH_YES_NO' lookup_type.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created routing list. If p_validate is true, then the
 * value will be null.
 * @rep:displayname Create Routing List
 * @rep:category BUSINESS_ENTITY PQH_POS_CTRL_ROUTING
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_routing_list
(
   p_validate                       in boolean    default false
  ,p_routing_list_id                out nocopy number
  ,p_routing_list_name              in  varchar2
  ,p_enable_flag		    in  varchar2  default 'Y'
  ,p_object_version_number          out nocopy number
 );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_routing_list >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates routing list details.
 *
 * A routing list that is enabled, cannot be disabled if transactions have been
 * routed to it and these transactions have approval pending.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The routing list that is updated must already exist.
 *
 * <p><b>Post Success</b><br>
 * The routing list is updated successfully in the database.
 *
 * <p><b>Post Failure</b><br>
 * The routing list is not updated and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_routing_list_id Identifies the routing list record to be modified.
 * @param p_routing_list_name Unique routing list name.
 * @param p_enable_flag Indicates if the routing list is enabled/disabled.
 * Valid values are defined by 'PQH_YES_NO' lookup_type.
 * @param p_object_version_number Pass in the current version number of the
 * routing list to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated routing list. If
 * p_validate is true will be set to the same value which was passed in.
 * @rep:displayname Update Routing List
 * @rep:category BUSINESS_ENTITY PQH_POS_CTRL_ROUTING
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_routing_list
  (
   p_validate                       in boolean    default false
  ,p_routing_list_id                in  number
  ,p_routing_list_name              in  varchar2  default hr_api.g_varchar2
  ,p_enable_flag		    in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_routing_list >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a routing list.
 *
 * Alternatively, the routing list can be disabled if it is no longer in use.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The routing list that is to be deleted must already exist. It must not have
 * any routing list members attached. The routing list cannot be deleted if it
 * is used for routing transactions in a transaction type and the transactions
 * are pending approval.
 *
 * <p><b>Post Success</b><br>
 * The routing list is successfully deleted from the database.
 *
 * <p><b>Post Failure</b><br>
 * The routing list is not deleted and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_routing_list_id Identifies the routing list to be deleted.
 * @param p_object_version_number Current version number of the routing list to
 * be deleted.
 * @rep:displayname Delete Routing List
 * @rep:category BUSINESS_ENTITY PQH_POS_CTRL_ROUTING
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_routing_list
  (
   p_validate                       in boolean        default false
  ,p_routing_list_id                in  number
  ,p_object_version_number          in out nocopy number
  );
--
--
end PQH_ROUTING_LISTS_api;

 

/
