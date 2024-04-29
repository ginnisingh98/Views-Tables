--------------------------------------------------------
--  DDL for Package HR_POS_HIERARCHY_ELE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_POS_HIERARCHY_ELE_BK3" AUTHID CURRENT_USER as
/* $Header: pepseapi.pkh 120.1.12000000.1 2007/01/22 02:04:37 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_pos_hierarchy_ele_a >-------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_pos_hierarchy_ele_a
  (p_pos_structure_element_id      in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_pos_hierarchy_ele_b >-------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_pos_hierarchy_ele_b
  (p_pos_structure_element_id      in     number
  ,p_object_version_number         in     number
  );
--
end hr_pos_hierarchy_ele_bk3;

 

/
