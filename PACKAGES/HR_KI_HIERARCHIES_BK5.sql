--------------------------------------------------------
--  DDL for Package HR_KI_HIERARCHIES_BK5
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_KI_HIERARCHIES_BK5" AUTHID CURRENT_USER as
/* $Header: hrhrcapi.pkh 120.1 2005/10/02 02:02:57 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |------------------< create_ui_hierarchy_map_b >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ui_hierarchy_map_b
  (
   p_hierarchy_id                 in     number
  ,p_user_interface_id            in     number

  );
--
-- ----------------------------------------------------------------------------
-- |-------------------< create_ui_hierarchy_map_a >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ui_hierarchy_map_a
  (
   p_hierarchy_id                 in     number
  ,p_user_interface_id            in     number
  ,p_hierarchy_node_map_id        in     number
  ,p_object_version_number        in     number
  );
--
end hr_ki_hierarchies_bk5;

 

/
