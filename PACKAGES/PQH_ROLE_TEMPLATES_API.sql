--------------------------------------------------------
--  DDL for Package PQH_ROLE_TEMPLATES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_ROLE_TEMPLATES_API" AUTHID CURRENT_USER as
/* $Header: pqrtmapi.pkh 120.1 2005/10/02 02:27:52 aroussel $ */
/*#
 * This package contains role template APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Role Template
*/
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_role_template >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API allows one or more role templates to be associated to a given role.
 *
 * The role templates associated to a role establish the maximum set of
 * permissions for that role, for a particular transaction type. Once the role
 * templates are setup, the application automatically applies the appropriate
 * role template when users initiate a transaction or open a routed
 * transaction.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * There are no prereqs for this API.
 *
 * <p><b>Post Success</b><br>
 * The role template associating the selected template and role is created
 * successfully in the database.
 *
 * <p><b>Post Failure</b><br>
 * The role template is not created and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_role_template_id If p_validate is false, then this uniquely
 * identifies the role template created. If p_validate is true, then set to
 * null.
 * @param p_role_id Identifies the role for which you create the role template
 * record.
 * @param p_transaction_category_id Identifies the transaction type for which
 * the role template is created.
 * @param p_template_id Identifies the transaction template associated with the
 * role.
 * @param p_enable_flag Indicates if the role template is enabled/disabled.
 * Valid values are defined by 'YES_NO' lookup_type
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created role template. If p_validate is true, then the
 * value will be null
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @rep:displayname Create Role Template
 * @rep:category BUSINESS_ENTITY HR_ROLE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_role_template
(
   p_validate                       in boolean    default false
  ,p_role_template_id               out nocopy number
  ,p_role_id                        in  number    default null
  ,p_transaction_category_id        in  number    default null
  ,p_template_id                    in  number    default null
  ,p_enable_flag                    in  varchar2  default  'Y'
  ,p_object_version_number          out nocopy number
  ,p_effective_date            in  date
 );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_role_template >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the role template associated to a given role.
 *
 * The role template cannot be enabled if the role to which it is associated is
 * disabled. Different role template can be associated to the role, thus
 * changing role permissions.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The role template which is to be updated must already exist. The Transaction
 * template that is attached to the role must be enabled and frozen.
 *
 * <p><b>Post Success</b><br>
 * The role template is updated successfully in the database.
 *
 * <p><b>Post Failure</b><br>
 * The role template is not updated and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_role_template_id If p_validate is false, then this uniquely
 * identifies the updated role template. If p_validate is true, then set to
 * null.
 * @param p_role_id Identifies the role with which a transaction template is
 * associated.
 * @param p_template_id Identifies the transaction template associated with the
 * role.
 * @param p_enable_flag Indicates if the role template is enabled/disabled.
 * Valid values are defined by 'YES_NO' lookup_type
 * @param p_object_version_number Pass in the current version number of the
 * role template to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated role template. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @rep:displayname Update Role Template
 * @rep:category BUSINESS_ENTITY HR_ROLE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_role_template
  (
   p_validate                       in boolean    default false
  ,p_role_template_id               in  number
  ,p_role_id                        in  number    default hr_api.g_number
  -- ,p_transaction_category_id        in  number    default hr_api.g_number
  ,p_template_id                    in  number    default hr_api.g_number
  ,p_enable_flag                    in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date            in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_role_template >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a role template from a given role.
 *
 * A role must have at least one role template attached to it for the user to
 * be able to work on a position transaction.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The role template to be deleted must already exist.
 *
 * <p><b>Post Success</b><br>
 * The role template is deleted successfully from the database.
 *
 * <p><b>Post Failure</b><br>
 * The role template is not deleted and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_role_template_id If p_validate is false, then this uniquely
 * identifies the role template created. If p_validate is true, then set to
 * null.
 * @param p_object_version_number Current version of the role template to be
 * deleted.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @rep:displayname Delete Role Template
 * @rep:category BUSINESS_ENTITY HR_ROLE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_role_template
  (
   p_validate                       in boolean        default false
  ,p_role_template_id               in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date            in date
  );
--
--
end PQH_ROLE_TEMPLATES_api;

 

/
