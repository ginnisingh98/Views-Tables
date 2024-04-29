--------------------------------------------------------
--  DDL for Package HR_SECURITY_ORGANIZATION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_SECURITY_ORGANIZATION_API" AUTHID CURRENT_USER as
/* $Header: pepsoapi.pkh 120.2.12010000.2 2008/08/06 09:30:10 ubhat ship $ */
/*#
 * This package contains apis for organization level security maintenance.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Organization Security
*/
-- ----------------------------------------------------------------------------
-- |-------------------< create_security_organization >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API is used to include or exclude an organization from a security
 * Profile.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The security profile id and organization id must already exist.
 *
 * <p><b>Post Success</b><br>
 * Includes or Excludes the organization .
 *
 * <p><b>Post Failure</b><br>
 * The API doesn't include or exclude an organization from the security
 * Profile.
 *
 * @param p_validate If true, then validation alone will be performed and
 * the database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_security_profile_id Security profile id.
 * @param p_organization_id Organization id.
 * @param p_entry_type If entry type is I, then the organization is included
 * into the security profile. If E then the organization will be excluded
 * from the security profile.
 * @param p_security_organization_id Security Organization id.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the security organization created. If p_validate is true,
 * then set to null.
 * @rep:displayname Create Organization Security
 * @rep:category BUSINESS_ENTITY PER_SECURITY_PROFILE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
--
procedure create_security_organization
  ( p_validate                  in  boolean  default false
  , p_security_profile_id       in  number
  , p_organization_id           in  number
  , p_entry_type                in  varchar2
  , p_security_organization_id  out nocopy number
  , p_object_version_number     out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------< update_security_organization >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the organization security.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The security profile id,security organization id and organization id
 * must already exist.
 *
 * <p><b>Post Success</b><br>
 * Updates the organization security
 *
 * <p><b>Post Failure</b><br>
 * The API doesn't update the organization security.
 *
 * @param p_validate If true, then validation alone will be performed and
 * the database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_security_profile_id Security profile id.
 * @param p_organization_id Organization id.
 * @param p_entry_type If entry type is I, then the organization is included
 * into the security profile .If E then the organization will be excluded
 * from the security profile.
 * @param p_security_organization_id Security organization id.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the security organization updated. If p_validate is true,
 * then set to null.
 * @rep:displayname Update Organization Security
 * @rep:category BUSINESS_ENTITY PER_SECURITY_PROFILE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
--

procedure update_security_organization
  (
    p_validate                  in  boolean  default false
  , p_security_profile_id	in number    default hr_api.g_number
  , p_organization_id		in number    default hr_api.g_number
  , p_entry_type 		in varchar2  default hr_api.g_varchar2
  , p_security_organization_id  in  number
  , p_object_version_number  in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------< delete_security_organization >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes the organization security.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Security organization id must already exist.
 *
 * <p><b>Post Success</b><br>
 * Deletes the organization from the security profile.
 *
 * <p><b>Post Failure</b><br>
 * Doesn't delete the organization from the security profile.
 *
 * @param p_validate If true, then validation alone will be performed and
 * the database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_security_organization_id Security organization id
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the security organization deleted. If p_validate is true,
 * then set to null.
 * @rep:displayname Delete Organization Security
 * @rep:category BUSINESS_ENTITY PER_SECURITY_PROFILE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--

procedure delete_security_organization
  (
    p_validate                  in  boolean  default false
  , p_security_organization_id  in  number
  , p_object_version_number     in  number
  );
--
end HR_SECURITY_ORGANIZATION_API;

/
