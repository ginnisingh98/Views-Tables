--------------------------------------------------------
--  DDL for Package HR_POS_HIERARCHY_ELE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_POS_HIERARCHY_ELE_BK1" AUTHID CURRENT_USER as
/* $Header: pepseapi.pkh 120.1.12000000.1 2007/01/22 02:04:37 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_pos_hierarchy_ele_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_pos_hierarchy_ele_b
  (p_parent_position_id        in     number
  ,p_pos_structure_version_id  in     number
  ,p_subordinate_position_id   in     number
  ,p_business_group_id         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_pos_hierarchy_ele_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_pos_hierarchy_ele_a
  (p_parent_position_id        in     number
  ,p_pos_structure_version_id  in     number
  ,p_subordinate_position_id   in     number
  ,p_business_group_id         in     number
  );
--
end hr_pos_hierarchy_ele_bk1;

 

/
