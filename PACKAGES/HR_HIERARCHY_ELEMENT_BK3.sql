--------------------------------------------------------
--  DDL for Package HR_HIERARCHY_ELEMENT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_HIERARCHY_ELEMENT_BK3" AUTHID CURRENT_USER as
/* $Header: peoseapi.pkh 120.1 2005/10/02 02:19:08 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_hierarchy_element_a >-------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_hierarchy_element_a
  (p_org_structure_element_id      in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_hierarchy_element_b >-------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_hierarchy_element_b
  (p_org_structure_element_id      in     number
  ,p_object_version_number         in     number
  );
--
end hr_hierarchy_element_bk3;

 

/
