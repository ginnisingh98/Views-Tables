--------------------------------------------------------
--  DDL for Package HR_KI_HIERARCHIES_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_KI_HIERARCHIES_BK1" AUTHID CURRENT_USER as
/* $Header: hrhrcapi.pkh 120.1 2005/10/02 02:02:57 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_hierarchy_node_b >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_hierarchy_node_b
  (
   p_language_code                 in     varchar2
  ,p_hierarchy_key                 in     varchar2
  ,p_parent_hierarchy_id           in     number
  ,p_name                          in     varchar2
  ,p_description                   in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_hierarchy_node_a >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_hierarchy_node_a
  (
   p_language_code                 in     varchar2
  ,p_hierarchy_key                 in     varchar2
  ,p_parent_hierarchy_id           in     number
  ,p_name                          in     varchar2
  ,p_description                   in     varchar2
  ,p_hierarchy_id                  in     number
  ,p_object_version_number         in     number
  );
--
end hr_ki_hierarchies_bk1;

 

/
