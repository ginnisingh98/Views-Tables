--------------------------------------------------------
--  DDL for Package HR_KI_HIERARCHIES_BK7
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_KI_HIERARCHIES_BK7" AUTHID CURRENT_USER as
/* $Header: hrhrcapi.pkh 120.1 2005/10/02 02:02:57 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |------------------< update_hierarchy_node_map_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_hierarchy_node_map_b
  (
   p_topic_id                     in     number
  ,p_hierarchy_id                 in     number
  ,p_user_interface_id            in     number
  ,p_hierarchy_node_map_id        in     number
  ,p_object_version_number        in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------< update_hierarchy_node_map_a >------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_hierarchy_node_map_a
  (
   p_topic_id                     in     number
  ,p_hierarchy_id                 in     number
  ,p_user_interface_id            in     number
  ,p_hierarchy_node_map_id        in     number
  ,p_object_version_number        in     number
  );
--
end hr_ki_hierarchies_bk7;

 

/
