--------------------------------------------------------
--  DDL for Package HR_KI_HIERARCHIES_BK4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_KI_HIERARCHIES_BK4" AUTHID CURRENT_USER as
/* $Header: hrhrcapi.pkh 120.1 2005/10/02 02:02:57 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |------------------< create_topic_hierarchy_map_b >------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_topic_hierarchy_map_b
  (
   p_hierarchy_id                 in     number
  ,p_topic_id                     in     number

  );
--
-- ----------------------------------------------------------------------------
-- |-------------------< create_topic_hierarchy_map_a >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_topic_hierarchy_map_a
  (
   p_hierarchy_id                 in     number
  ,p_topic_id                     in     number
  ,p_hierarchy_node_map_id        in     number
  ,p_object_version_number        in     number
  );
--
end hr_ki_hierarchies_bk4;

 

/
