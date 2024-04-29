--------------------------------------------------------
--  DDL for Package GCS_ENTITIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_ENTITIES_PKG" AUTHID CURRENT_USER AS
/* $Header: gcsentts.pls 120.1 2005/10/30 05:18:12 appldev noship $ */
--
-- Package
--   gcs_entities_pkg
-- Purpose
--   Package procedures for Consolidation Hierarchies
-- History
--   06-MAR-05	M Ward		Created
--

  --
  -- Procedure
  --   Add_To_Summary_Table
  -- Purpose
  --   Inserts rows into the gcs_entity_cctr_orgs table.
  -- Arguments
  --   p_entity_id		Entity for which the logic must be performed
  -- Example
  --   GCS_ENTITIES_PKG.Add_To_Summary_Table(...);
  -- Notes
  --
  PROCEDURE Add_To_Summary_Table(p_entity_id NUMBER);

  --
  -- Procedure
  --   Load_Entities
  -- Purpose
  --   Loads the entities listed in the clob
  -- Arguments
  --   p_file_id	ID from gcs_xml_files for the clob
  -- Example
  --   GCS_ENTITIES_PKG.Load_Entities(myclob);
  -- Notes
  --
  PROCEDURE Load_Entities(	x_errbuf	OUT NOCOPY VARCHAR2,
				x_retcode	OUT NOCOPY VARCHAR2,
				p_file_id	NUMBER);

  --
  -- Procedure
  --   Update_Entity_Orgs
  -- Purpose
  --   Updates the list of orgs for all entities.
  -- Example
  --   GCS_ENTITIES_PKG.Update_Entity_Orgs(entity_id);
  -- Notes
  --
  PROCEDURE Update_Entity_Orgs(	x_errbuf	OUT NOCOPY VARCHAR2,
				x_retcode	OUT NOCOPY VARCHAR2);


END GCS_ENTITIES_PKG;

 

/
