--------------------------------------------------------
--  DDL for Package Body CN_DIM_HIERARCHY_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_DIM_HIERARCHY_UTILITIES" AS
-- $Header: cnutilsb.pls 120.0 2005/06/06 17:46:35 appldev noship $

  --+
  -- Procedure Name
  --   node_exist
  -- Purpose
  --   Test whether a node already exists in the hierarchy.
  --+
  FUNCTION node_exist(
	X_dim_hierarchy_id	cn_hierarchy_nodes.dim_hierarchy_id%type,
	X_value_id		cn_hierarchy_nodes.value_id%type)
	RETURN 			varchar2 IS

    exist	varchar2(1) := 'N';

  BEGIN

    SELECT 'Y'
      INTO exist
      FROM sys.dual
     WHERE EXISTS (SELECT value_id
		     FROM cn_dim_explosion
		    WHERE value_id 	   = X_value_id
		      AND dim_hierarchy_id = X_dim_hierarchy_id);

    RETURN exist;

  EXCEPTION

    WHEN NO_DATA_FOUND THEN
      RETURN exist;

  END node_exist;

END cn_dim_hierarchy_utilities;

/
