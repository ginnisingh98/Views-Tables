--------------------------------------------------------
--  DDL for Package PER_ORG_STRUCTURE_VERSION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ORG_STRUCTURE_VERSION_API" AUTHID CURRENT_USER AS
/* $Header: peosvapi.pkh 120.2 2005/10/22 01:24:23 aroussel noship $ */
/*#
 * This package contains APIs that create and maintain organization hierarchy
 * versions.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Organization Hierarchy Version
*/
 g_package            VARCHAR2(33) := '  per_org_structure_version_api.';
--
--------------------------------------------------------------------------------
g_dummy number(1);      -- Dummy for cursor returns which are not needed
g_business_group_id number(15); -- For validating translation;
g_legislation_code varchar2(150); -- For validating translation;
--------------------------------------------------------------------------------
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_org_structure_version >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API create an Organization Hierarchy Version.
 *
 * It creates an organization hierarchy version for a given organization
 * hierarchy. The process initializes the version number to 1.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid organization structure must exist.
 *
 * <p><b>Post Success</b><br>
 * On successful completion creates an organization hierarchy version for a
 * given organization hierarchy. Returns organization structure version Id and
 * object version number.
 *
 * <p><b>Post Failure</b><br>
 * Organization hierarchy version will not be created and an error will raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_organization_structure_id Uniquely identifies the organization
 * hierarchy for which the process creates a version.
 * @param p_date_from The date the organization hierarchy version takes effect.
 * @param p_version_number The user-enterable version number of the
 * organization hierarchy. Version numbers do not have to be sequential.
 * @param p_copy_structure_version_id Uniquely identifies a previously existing
 * organization hierarchy version (if any) the process copies as the basis for
 * the created version.
 * @param p_date_to The date this organization hierarchy version is no longer
 * in effect.
 * @param p_request_id When the API is executed from a concurrent program set
 * to the concurrent request identifier.
 * @param p_program_application_id When the API is executed from a concurrent
 * program set to the program's Application.
 * @param p_program_id When the API is executed from a concurrent program set
 * to the program's identifier.
 * @param p_program_update_date When the API is executed from a concurrent
 * program set to when the program was ran.
 * @param p_topnode_pos_ctrl_enabled_fla Flag specifying if the hierarchy
 * associated with the created hierarchy version is a top node position
 * controlled hierarchy.
 * @param p_org_structure_version_id If p_validate is false, then this uniquely
 * identifies the organization hierarchy version created. If p_validate is
 * true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created organization hierarchy version. If p_validate
 * is true, then the value will be null.
 * @param p_gap_warning The process sets to 'true' if there is a gap between
 * the effective date ranges of hierarchy versions.
 * @rep:displayname Create Organization Hierarchy Version
 * @rep:category BUSINESS_ENTITY PER_ORGANIZATION_HIERARCHY
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE create_org_structure_version
  (p_validate                      in     boolean  default false
  ,p_effective_date                 in     date
  ,p_organization_structure_id      in     number
  ,p_date_from                      in     date
  ,p_version_number                 in     number
  ,p_copy_structure_version_id      in     number   default null
  ,p_date_to                        in     date     default null
  ,p_request_id                     in     number   default null
  ,p_program_application_id         in     number   default null
  ,p_program_id                     in     number   default null
  ,p_program_update_date            in     date     default null
  ,p_topnode_pos_ctrl_enabled_fla   in     varchar2 default 'N'
  ,p_org_structure_version_id          out nocopy number
  ,p_object_version_number             out nocopy number
  ,p_gap_warning                       out nocopy boolean
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_org_structure_version >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an Organization Hierarchy Version.
 *
 * This procedure will update the organization hierarchy version for a given
 * organization hierarchy. The system generates a version number for each new
 * row, which Increments by one with each update.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid organization structure version must be existing.
 *
 * <p><b>Post Success</b><br>
 * On successful completion updates the organization structure version for a
 * given organization structure version id and returns organization structure
 * object version number.
 *
 * <p><b>Post Failure</b><br>
 * Organization structure version will not be updated and an error will raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_date_from The date the created hierarchy version takes effect.
 * @param p_version_number The user-enterable version number of the hierarchy
 * version. Version numbers do not have to be sequential.
 * @param p_copy_structure_version_id Uniquely identifies a previously existing
 * organization hierarchy version (if any) the process copies as the basis for
 * the created version.
 * @param p_date_to The date the created hierarchy version is no longer in
 * effect.
 * @param p_request_id When the API is executed from a concurrent program set
 * to the concurrent request identifier.
 * @param p_program_application_id When the API is executed from a concurrent
 * program set to the program's Application.
 * @param p_program_id When the API is executed from a concurrent program set
 * to the program's identifier.
 * @param p_program_update_date When the API is executed from a concurrent
 * program set to when the program was ran.
 * @param p_topnode_pos_ctrl_enabled_fla Flag specifying if the hierarchy
 * associated with the created hierarchy version is a top node position
 * controlled hierarchy.
 * @param p_org_structure_version_id Uniquely identifies the organization
 * hierarchy version the process updates.
 * @param p_object_version_number Pass in the current version number of the
 * Organization Hierarchy Version to be updated. When the API completes if
 * p_validate is false, will be set to the new version number of the updated
 * Organization Hierarchy Version. If p_validate is true will be set to the
 * same value which was passed in.
 * @param p_gap_warning The process sets to 'true' if there is a gap between
 * the effective date ranges of hierarchy versions.
 * @rep:displayname Update Organization Hierarchy Version
 * @rep:category BUSINESS_ENTITY PER_ORGANIZATION_HIERARCHY
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE update_org_structure_version
  (p_validate                      in     boolean  default false
  ,p_effective_date                 in     date
  ,p_date_from                      in     date
  ,p_version_number                 in     number
  ,p_copy_structure_version_id      in     number   default hr_api.g_number
  ,p_date_to                        in     date     default hr_api.g_date
  ,p_request_id                     in     number   default hr_api.g_number
  ,p_program_application_id         in     number   default hr_api.g_number
  ,p_program_id                     in     number   default hr_api.g_number
  ,p_program_update_date            in     date     default hr_api.g_date
  ,p_topnode_pos_ctrl_enabled_fla   in     varchar2 default hr_api.g_varchar2
  ,p_org_structure_version_id       in     number
  ,p_object_version_number          in out nocopy number
  ,p_gap_warning                       out nocopy boolean);
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_org_structure_version >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This procedure deletes an organization hierarchy version for a given
 * organization hierarchy.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid organization hierarchy version must exist.
 *
 * <p><b>Post Success</b><br>
 * The organization hierarchy version record will be deleted.
 *
 * <p><b>Post Failure</b><br>
 * Organization hierarchy version will not be deleted and an error will raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_org_structure_version_id Uniquely identifies the organization
 * hierarchy version the process deletes.
 * @param p_object_version_number Current version number of the organization
 * hierarchy version record to be deleted.
 * @rep:displayname Delete Organization Hierarchy Version
 * @rep:category BUSINESS_ENTITY PER_ORGANIZATION_HIERARCHY
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE delete_org_structure_version
   (  p_validate                     IN BOOLEAN     default false
     ,p_org_structure_version_id     IN number
     ,p_object_version_number        IN number );

--
--
END per_org_structure_version_api;

 

/
