--------------------------------------------------------
--  DDL for Package PER_HIERARCHY_NODES_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_HIERARCHY_NODES_BK3" AUTHID CURRENT_USER as
/* $Header: pepgnapi.pkh 120.2 2005/10/22 01:24:34 aroussel noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_hierarchy_nodes_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_hierarchy_nodes_b
  (
   p_hierarchy_node_id              in  number
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_hierarchy_nodes_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_hierarchy_nodes_a
  (
   p_hierarchy_node_id              in  number
  ,p_object_version_number          in  number
  );
--
end per_hierarchy_nodes_bk3;

 

/
