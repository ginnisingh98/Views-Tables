--------------------------------------------------------
--  DDL for Package GCS_FEM_HIER_SYNC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_FEM_HIER_SYNC_PKG" AUTHID CURRENT_USER AS
/* $Header: gcs_hier_syncs.pls 120.1 2005/10/30 05:18:35 appldev noship $ */

  --
  -- Procedure
  --   synchronize_hierarchy()
  -- Purpose
  --   To load the hierarchy from GCS to FEM
  -- Arguments
  -- p_hierarchy_id	Hierarchy to be pushed on to FEM
  -- x_errbuf		error buffer
  -- x_retcode		E-mail Text
  --

   PROCEDURE synchronize_hierarchy
     (  p_hierarchy_id 	 	IN NUMBER,
        x_errbuf         	OUT NOCOPY      VARCHAR2,
        x_retcode        	OUT NOCOPY      VARCHAR2);

  --
  -- Procedure
  --   entity_added()
  -- Purpose
  --   Accounts for the addition of an entity
  -- Arguments
  -- p_hierarchy_id						Hierarchy Identifier
  -- p_cons_relationship_id		Consolidation Relationship

   PROCEDURE entity_added
     (  p_hierarchy_id 		IN NUMBER,
	p_cons_relationship_id	IN NUMBER);


END GCS_FEM_HIER_SYNC_PKG;


 

/
