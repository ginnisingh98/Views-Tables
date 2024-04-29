--------------------------------------------------------
--  DDL for Package CN_DIM_HIERARCHY_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_DIM_HIERARCHY_UTILITIES" AUTHID CURRENT_USER AS
-- $Header: cnutilss.pls 120.0 2005/06/06 17:38:59 appldev noship $


  --+
  -- Procedure Name
  --   node_exist
  -- Purpose
  --   Test whether a node already exists in the hierarchy.
  --+
  FUNCTION node_exist(
	X_dim_hierarchy_id	cn_hierarchy_nodes.dim_hierarchy_id%type,
	X_value_id		cn_hierarchy_nodes.value_id%type)
	RETURN 			varchar2;

END cn_dim_hierarchy_utilities;
 

/
