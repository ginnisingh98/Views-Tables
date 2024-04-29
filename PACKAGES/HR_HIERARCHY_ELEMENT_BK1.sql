--------------------------------------------------------
--  DDL for Package HR_HIERARCHY_ELEMENT_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_HIERARCHY_ELEMENT_BK1" AUTHID CURRENT_USER as
/* $Header: peoseapi.pkh 120.1 2005/10/02 02:19:08 aroussel $ */

-- ----------------------------------------------------------------------------
-- |-------------------------< create_hierarchy_element_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_hierarchy_element_b
  (p_effective_date                in     date      -- Bug 2879820
  ,p_organization_id_parent        in     number
  ,p_org_structure_version_id      in     number
  ,p_organization_id_child         in     number
  ,p_business_group_id             in     number
  ,p_pos_control_enabled_flag      in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_hierarchy_element_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_hierarchy_element_a
  (p_effective_date                in     date    -- Bug 2879820
  ,p_organization_id_parent        in     number
  ,p_org_structure_version_id      in     number
  ,p_organization_id_child         in     number
  ,p_business_group_id             in     number
  ,p_pos_control_enabled_flag      in     varchar2
  ,p_inactive_org_warning          in     boolean  -- Bug 2879820
  ,p_org_structure_element_id      in     number   -- Bug 2879820
  ,p_object_version_number         in     number   -- Bug 2879820
  );
--
end hr_hierarchy_element_bk1;

 

/
