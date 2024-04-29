--------------------------------------------------------
--  DDL for Package HR_HIERARCHY_ELEMENT_INTERNAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_HIERARCHY_ELEMENT_INTERNAL" AUTHID CURRENT_USER as
/* $Header: peosebsi.pkh 115.4 2002/12/06 16:21:11 pkakar noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------<  create_hier_element_internal >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This business support process calls the business process to creates a
--   new parent-child element in an organization hierarchy. When called from
--   here, p_validate is always set to false.
--
-- Prerequisites:
--   Parent Organization must be active from the Hierarchy Version date
--
-- In Parameters:
--  Name                           Reqd Type     Description
--
--  p_organization_id_parent       yes  number   fk to hr_all_organization_units
--  p_org_structure_version_id     yes  number   fk to per_org_structure_versions
--  p_organization_id_child        yes  number   fk to hr_all_organization_units
--  p_business_group_id            yes  number   business group context
--  p_date_from                    yes  DATE     required to check parent org is
--                                               active for hierarchy version
--  p_security_profile_id          yes  NUMBER   used to add orgs in hierarchy
--                                               to per_organization_list
--  p_view_all_orgs                yes  VARCHAR2 flag used to define if
--                                               per_organization_list should
--                                               be populated (secure_user)
--  p_end_of_time                  yes  DATE     end of time
--  p_hr_installed                 yes  VARCHAR2 check fnd_product_installations
--                                               set to 'I' if installed
--  p_pa_installed                 yes  VARCHAR2 check fnd_product_installations
--                                               set to 'I' if installed
--  p_warning_raised                no  VARCHAR2 flag if org is not active from
--                                               Hierarchy Version date
--
--
-- Post Success:
--  row is created
--
--
-- Post Failure:
--
--   The procedure will raise an error.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure create_hier_element_internal
  (p_organization_id_parent        in     number
  ,p_org_structure_version_id      in     number
  ,p_organization_id_child         in     number
  ,p_business_group_id             in     number   default null
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
--
-- ----------------------------------------------------------------------------
-- |----------------<  update_hier_element_internal >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This business support process calls the business process to update a
--   parent-child element in an organization hierarchy. When called from
--   here, p_validate is always set to false.
--
-- Prerequisites:
--   none
--
-- In Parameters:
--  Name                           Reqd Type     Description
--
--  p_org_structure_element_id     yes  number   primary key
--  p_organization_id_parent       yes  number   fk to hr_all_organization_units
--  p_organization_id_child        yes  number   fk to hr_all_organization_units
--  p_object_version_number        yes  number   object version number
--
--
-- Post Success:
--  row is updated
--
--
-- Post Failure:
--
--   The procedure will raise an error.
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure update_hier_element_internal
  (p_org_structure_element_id      in     number
  ,p_effective_date                in     date
  ,p_organization_id_parent        in     number   default hr_api.g_number
  ,p_organization_id_child         in     number   default hr_api.g_number
  ,p_pos_control_enabled_flag      in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy number
  );
--
--
-- ----------------------------------------------------------------------------
-- |----------------<  delete_hier_element_internal >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This business support process calls the business process to remove a
--   parent-child element from an organization hierarchy. When called from
--   here, p_validate is always set to false.
--
-- Prerequisites:
--   element cannot be deleted if children exist.
-- If the child org in the element = top org in an
-- security_profile and hierarchies are the same
-- then cannot delete it.
-- Similarly if the parent_org in the element = top org in a
-- security_profile and hierarchies are the same
-- then you cannot delete it if it is the parent of no other
-- org_structure_element for this version.
-- If an Org structure has been specified for
-- PA use then it should not be allowed to be deleted.
--
--
-- In Parameters:
--  Name                           Reqd Type     Description
--
--  p_org_structure_element_id     yes  number   primary key
--  p_object_version_number        yes  number   object version number
--  p_hr_installed                 yes  VARCHAR2 check fnd_product_installations
--                                               set to 'I' if installed
--  p_pa_installed                 yes  VARCHAR2 check fnd_product_installations
--                                               set to 'I' if installed
--  p_exists_in_hierarchy          yes  VARCHAR2 set in value to 'Y'
--                                               is set to 'Y' if the child org is
--                                               present in the hierarchy after
--                                               the delete, else set to 'N'
--
--
-- Post Success:
--  row is deleted
--
--
-- Post Failure:
--
--   The procedure will raise an error.
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure delete_hier_element_internal
  (p_org_structure_element_id      in     number
  ,p_object_version_number         in     number
  ,p_hr_installed                  in     VARCHAR2
  ,p_pa_installed                  in     VARCHAR2
  ,p_exists_in_hierarchy           in out nocopy VARCHAR2
  );
--
end hr_hierarchy_element_internal;

 

/
