--------------------------------------------------------
--  DDL for Package HR_KI_HIERARCHIES_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_KI_HIERARCHIES_BK3" AUTHID CURRENT_USER as
/* $Header: hrhrcapi.pkh 120.1 2005/10/02 02:02:57 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_hierarchy_node_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_hierarchy_node_b
  (
   p_hierarchy_id                  in     number
  ,p_object_version_number         in     number

  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_hierarchy_node_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_hierarchy_node_a
  (
   p_hierarchy_id                  in     number
  ,p_object_version_number         in     number
  );
--
end hr_ki_hierarchies_bk3;

 

/
