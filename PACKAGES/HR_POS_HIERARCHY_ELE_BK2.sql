--------------------------------------------------------
--  DDL for Package HR_POS_HIERARCHY_ELE_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_POS_HIERARCHY_ELE_BK2" AUTHID CURRENT_USER as
/* $Header: pepseapi.pkh 120.1.12000000.1 2007/01/22 02:04:37 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_pos_hierarchy_ele_a >-------------------|
-- ----------------------------------------------------------------------------
--
procedure update_pos_hierarchy_ele_a
  (p_pos_structure_element_id  in     number
  ,p_parent_position_id        in     number
  ,p_subordinate_position_id   in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_pos_hierarchy_ele_b >-------------------|
-- ----------------------------------------------------------------------------
--
procedure update_pos_hierarchy_ele_b
  (p_pos_structure_element_id  in     number
  ,p_parent_position_id        in     number
  ,p_subordinate_position_id   in     number
  );
--
end hr_pos_hierarchy_ele_bk2;

 

/
