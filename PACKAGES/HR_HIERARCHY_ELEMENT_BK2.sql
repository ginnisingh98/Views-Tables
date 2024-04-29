--------------------------------------------------------
--  DDL for Package HR_HIERARCHY_ELEMENT_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_HIERARCHY_ELEMENT_BK2" AUTHID CURRENT_USER as
/* $Header: peoseapi.pkh 120.1 2005/10/02 02:19:08 aroussel $ */
-- ----------------------------------------------------------------------------
-- |-------------------------< update_hierarchy_element_a >-------------------|
-- ----------------------------------------------------------------------------
--
procedure update_hierarchy_element_a
 ( p_effective_date                in     date      -- Bug 2879820
  ,p_org_structure_element_id      in     number
  ,p_organization_id_parent        in     number
  ,p_organization_id_child         in     number
  ,p_pos_control_enabled_flag      in     varchar2
  ,p_object_version_number         in     number   -- Bug 2879820
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_hierarchy_element_b >-------------------|
-- ----------------------------------------------------------------------------
--
procedure update_hierarchy_element_b
 ( p_effective_date                in     date      -- Bug 2879820
  ,p_org_structure_element_id      in     number
  ,p_organization_id_parent        in     number
  ,p_organization_id_child         in     number
  ,p_pos_control_enabled_flag      in     varchar2
  ,p_object_version_number         in     number    -- Bug 2879820
  );
--
end hr_hierarchy_element_bk2;

 

/
