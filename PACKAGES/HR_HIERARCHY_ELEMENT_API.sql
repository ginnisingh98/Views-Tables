--------------------------------------------------------
--  DDL for Package HR_HIERARCHY_ELEMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_HIERARCHY_ELEMENT_API" AUTHID CURRENT_USER as
/* $Header: peoseapi.pkh 120.1 2005/10/02 02:19:08 aroussel $ */
/*#
 * This package contains APIs that create and maintain hierarchy elements.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Organization Hierarchy Element
*/
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_hierarchy_element >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates an organization hierarchy element record.
 *
 * If a child element of the same name already exists in the hierarchy, the
 * process deletes it and creates the child element the process specifies. If
 * the organization hierarchy restricts the user's security profile, the
 * process adds new organizations to 'PER_ORGANIZATION_LIST'. Note: This is the
 * new recommended overloaded procedure for 'create_hierarchy_element'. The
 * parameters p_date_from, p_security_profile_id, p_view_all_orgs,
 * p_end_of_time, p_hr_installed, p_pa_installed are now obsolete.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * Parent and child organizations should exist.
 *
 * <p><b>Post Success</b><br>
 * Organization hierarchy element is created.
 *
 * <p><b>Post Failure</b><br>
 * Organization hierarchy element is not created and error is returned.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_organization_id_parent Uniquely identifies the parent organization
 * associated with the organization hierarchy element.
 * @param p_org_structure_version_id Uniquely identifies the organization
 * hierarchy version.
 * @param p_organization_id_child Uniqely identifies the child organization
 * associated with the organization hierarchy element.
 * @param p_business_group_id Uniquely identifies the business group associated
 * with the organization hierarchy.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_pos_control_enabled_flag Flag that specifies if position control is
 * enabled.
 * @param p_inactive_org_warning Warning parameter is set to TRUE if the
 * organization, identified by p_organization_id_child, does not exist for the
 * duration of the structure version, identified by p_org_structure_version_id.
 * Otherwise it is set to FALSE.
 * @param p_org_structure_element_id If p_validate is false, then this uniquely
 * identifies the organization hierarchy element created. If p_validate is
 * true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created Organization Hierarchy Element. If p_validate
 * is true, then the value will be null.
 * @rep:displayname Create Organization Hierarchy Element
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
procedure create_hierarchy_element
  (p_validate                      in     boolean   default false
  ,p_effective_date                in     DATE
  ,p_organization_id_parent        in     number
  ,p_org_structure_version_id      in     number
  ,p_organization_id_child         in     number
  ,p_business_group_id             in     number    default null
  ,p_pos_control_enabled_flag      in     varchar2
  ,p_inactive_org_warning             out nocopy boolean
  ,p_org_structure_element_id         out nocopy number
  ,p_object_version_number            out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_hierarchy_element >---------------------|
-- ----------------------------------------------------------------------------
--
-- This version of the API is now out-of-date however it has been provided to
-- you for backward compatibility support and will be removed in the future.
-- Oracle recommends you to modify existing calling programs in advance of the
-- support being withdrawn thus avoiding any potential disruption.
--
procedure create_hierarchy_element
  (p_validate                      in     boolean   default false
  ,p_organization_id_parent        in     number
  ,p_org_structure_version_id      in     number
  ,p_organization_id_child         in     number
  ,p_business_group_id             in     number    default null
  ,p_effective_date                in     DATE
  ,p_date_from                     in     DATE
  ,p_security_profile_id           in     NUMBER
  ,p_view_all_orgs                 in     VARCHAR2
  ,p_end_of_time                   in     DATE
  ,p_hr_installed                  in     VARCHAR2
  ,p_pa_installed                  in     VARCHAR2
  ,p_pos_control_enabled_flag      in     varchar2
  ,p_warning_raised                IN OUT NOCOPY VARCHAR2
  ,p_org_structure_element_id         out nocopy number
  ,p_object_version_number            out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_hierarchy_element >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an organization hierarchy element record.
 *
 * This API updates a parent to a new child or a child to a new parent.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * Organization hierarchy element should exist.
 *
 * <p><b>Post Success</b><br>
 * Organization hierarchy element is updated.
 *
 * <p><b>Post Failure</b><br>
 * Organization hierarchy element is not updated and error is returned.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_org_structure_element_id Uniquely identifies the organization
 * hierarchy element record to modify.
 * @param p_organization_id_parent Uniquely identifies the parent organization
 * associated with the organization hierarchy element.
 * @param p_organization_id_child Uniquely identifies the child organization
 * associated with the organization hierarchy element.
 * @param p_pos_control_enabled_flag Flag that specifies if position control is
 * enabled.
 * @param p_object_version_number Pass in the current version number of the
 * organization hierarchy element to be updated. When the API completes if
 * p_validate is false, will be set to the new version number of the updated
 * organization hierarchy element. If p_validate is true will be set to the
 * same value which was passed in.
 * @rep:displayname Update Organization Hierarchy Element
 * @rep:category BUSINESS_ENTITY PER_ORGANIZATION_HIERARCHY
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_hierarchy_element
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_org_structure_element_id      in     number
  ,p_organization_id_parent        in     number   default hr_api.g_number
  ,p_organization_id_child         in     number   default hr_api.g_number
  ,p_pos_control_enabled_flag      in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_hierarchy_element >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes organization hierarchy element.
 *
 * Note: This is the new recommended overloaded procedure for
 * 'delete_hierarchy_element'. HRMS will desupport the obsoleted procedure in a
 * future release. HRMS has obsoleted the parameters p_hr_installed,
 * p_pa_installed, and removed the parameter p_exists_in_hierarchy.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * Organization hierarchy element should exist.
 *
 * <p><b>Post Success</b><br>
 * Organization hierarchy element is deleted.
 *
 * <p><b>Post Failure</b><br>
 * Organization hierarchy element is not deleted and error is returned.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_org_structure_element_id Uniquely identifies the organization
 * hierarchy element record to delete.
 * @param p_object_version_number Current version number of the Organization
 * Hierarchy Element record to be deleted.
 * @rep:displayname Delete Organization Hierarchy Element
 * @rep:category BUSINESS_ENTITY PER_ORGANIZATION_HIERARCHY
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_hierarchy_element
  (p_validate                      in     boolean  default false
  ,p_org_structure_element_id      in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_hierarchy_element >---------------------|
-- ----------------------------------------------------------------------------
--
-- This version of the API is now out-of-date however it has been provided to
-- you for backward compatibility support and will be removed in the future.
-- Oracle recommends you to modify existing calling programs in advance of the
-- support being withdrawn thus avoiding any potential disruption.
--
procedure delete_hierarchy_element
  (p_validate                      in     boolean  default false
  ,p_org_structure_element_id      in     number
  ,p_object_version_number         in     number
  ,p_hr_installed                  in     VARCHAR2
  ,p_pa_installed                  in     VARCHAR2
  ,p_exists_in_hierarchy           in out nocopy VARCHAR2
  );
--
end hr_hierarchy_element_api;

 

/
