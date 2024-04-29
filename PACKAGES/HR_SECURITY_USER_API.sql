--------------------------------------------------------
--  DDL for Package HR_SECURITY_USER_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_SECURITY_USER_API" AUTHID CURRENT_USER as
/* $Header: hrseuapi.pkh 120.5.12000000.1 2007/01/21 18:29:10 appldev ship $ */
/*#
 * This package contains user based security maintenance
 * @rep:scope public
 * @rep:product per
 * @rep:displayname User Security Maintenance
*/
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_security_user >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API adds the specified user into the list of static users for
 * whom security permissions should be re-evalulated during a Security List
 * Maintenance run and stored in static lists.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * User must be valid and should exist in application.
 *
 * <p><b>Post Success</b><br>
 * The user is successfully added into this security profile's static list
 * of users:
 *
 * <p><b>Post Failure</b><br>
 * The user will not be added to the security profile's list of static
 * users and an error message will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and
 * the database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date The effective date used for validation.
 * @param p_user_id The user to add in the static users list.
 * @param p_security_profile_id The security profile to add the user into.
 * @param p_process_in_next_run_flag The flag used for Static User Processing -
 * indicates whether user should have slm run if slm is to be run for only
 * 'process in next run' users.
 * @param p_security_user_id The primary key identifier for this unique
 * user/security profile association.
 * @param p_object_version_number This is set to the version number of the
 * created list entry.
 * @rep:displayname Create Security User
 * @rep:category BUSINESS_ENTITY PER_SECURITY_PROFILE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_security_user
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_user_id                       in     number
  ,p_security_profile_id           in     number
  ,p_process_in_next_run_flag      in     varchar2 default 'Y'
  ,p_security_user_id                 out nocopy number
  ,p_object_version_number            out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_security_user >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a particular user / security profile association.
 * This API allows the user, or the security profile, or both to be
 * changed in this association.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * None.
 *
 * <p><b>Post Success</b><br>
 * The user/security profile association is successfully updated.
 *
 * <p><b>Post Failure</b><br>
 * The user / security profile association will not be updated and an
 * error message will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and
 * the database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date The effective date used for validation.
 * @param p_security_user_id The primary key identifier for this unique user
 * security profile association.
 * @param p_user_id The user to include in the static users list.
 * @param p_security_profile_id Security profile for which this user is in
 * @param p_process_in_next_run_flag The flag used for Static User Processing -
 * indicates whether user should have slm run if slm is to be run for only
 * 'process in next run' users. Will be updated from 'Y' to 'N' after processing.
 * @param p_object_version_number This is set to the the version number of
 * the updated entry.
 * @param p_del_static_lists_warning If set to true, existing security
 * permissions in the static lists will be deleted upon commiting because they
 * are redundant as a result of this update. If set to false, either the
 * permissions in the static lists remain correct, or the user does not have
 * any rows in the static permission lists.
 * @rep:displayname Update Security User
 * @rep:category BUSINESS_ENTITY PER_SECURITY_PROFILE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
 */
--
-- {End Of Comments}
--
procedure update_security_user
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_security_user_id              in     number
  ,p_user_id                       in     number   default hr_api.g_number
  ,p_security_profile_id           in     number   default hr_api.g_number
  ,p_process_in_next_run_flag      in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy number
  ,p_del_static_lists_warning         out nocopy boolean
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_security_user >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * Deletes this particular user / security profile association.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * None.
 *
 * <p><b>Post Success</b><br>
 * The user is successfully deleted from this security profile's static
 * list of users.
 *
 * <p><b>Post Failure</b><br>
 * The user is not deleted from this security profile's static list of
 * users and an error message will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and
 * the database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_security_user_id The primary key identifier for this unique
 * user / security profile association.
 * @param p_object_version_number The version number of the entry being
 * deleted.
 * @param p_del_static_lists_warning If set to true, existing security
 * permissions in the static lists will be deleted upon commiting because they
 * are redundant as a result of this delete.If set to false, either the
 * permissions in the static lists remain correct, or the user does
 * not have any rows in the static permission lists.
 * @rep:displayname Delete Security User
 * @rep:category BUSINESS_ENTITY PER_SECURITY_PROFILE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
 */
--
-- {End Of Comments}
--
procedure delete_security_user
  (p_validate                      in     boolean  default false
  ,p_security_user_id              in     number
  ,p_object_version_number         in     number
  ,p_del_static_lists_warning         out nocopy boolean
  );
--
end hr_security_user_api;

 

/
