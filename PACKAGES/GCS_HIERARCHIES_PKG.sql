--------------------------------------------------------
--  DDL for Package GCS_HIERARCHIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_HIERARCHIES_PKG" AUTHID CURRENT_USER AS
/* $Header: gcshiers.pls 120.3 2006/05/22 12:36:56 smatam noship $ */
--
-- Package
--   gcs_hierarchies_pkg
-- Purpose
--   Package procedures for Consolidation Hierarchies
-- History
--   28-JUN-04	M Ward		Created
--

  --
  -- Procedure
  --   Insert_Row
  -- Purpose
  --   Inserts a row into the gcs_lex_map_structs table.
  -- Arguments
  --   row_id
  --   hierarchy_id
  --   top_entity_id
  --   start_date
  --   calendar_id
  --   dimension_group_id
  --   ie_by_org_code
  --   balance_by_org_flag
  --   enabled_flag
  --   threshold_amount
  --   threshold_currency
  --   fem_ledger_id
  --   column_name
  --   object_version_number
  --   hierarchy_name
  --   description
  --   last_update_date
  --   last_updated_by
  --   last_update_login
  --   creation_date
  --   created_by
  -- Example
  --   GCS_HIERARCHIES_PKG.Insert_Row(...);
  -- Notes
  --
  PROCEDURE Insert_Row(	row_id	IN OUT NOCOPY		VARCHAR2,
			hierarchy_id			VARCHAR2,
			top_entity_id			NUMBER,
			start_date			VARCHAR2,
			calendar_id			NUMBER,
			dimension_group_id		NUMBER,
			ie_by_org_code			VARCHAR2,
			balance_by_org_flag		VARCHAR2,
			enabled_flag			VARCHAR2,
			threshold_amount		NUMBER,
			threshold_currency		VARCHAR2,
			fem_ledger_id			NUMBER,
			column_name			VARCHAR2,
			object_version_number		NUMBER,
			hierarchy_name			VARCHAR2,
			description			VARCHAR2,
			last_update_date		DATE,
			last_updated_by			NUMBER,
			last_update_login		NUMBER,
			creation_date			DATE,
			created_by			NUMBER);

  --
  -- Procedure
  --   Update_Row
  -- Purpose
  --   Updates a row in the gcs_lex_map_structs table.
  -- Arguments
  --   hierarchy_id
  --   top_entity_id
  --   start_date
  --   calendar_id
  --   dimension_group_id
  --   ie_by_org_code
  --   balance_by_org_flag
  --   enabled_flag
  --   threshold_amount
  --   threshold_currency
  --   fem_ledger_id
  --   column_name
  --   object_version_number
  --   hierarchy_name
  --   description
  --   last_update_date
  --   last_udpated_by
  --   last_update_login
  -- Example
  --   GCS_HIERARCHIES_PKG.Update_Row(...);
  -- Notes
  --
  PROCEDURE Update_Row(	hierarchy_id			VARCHAR2,
			top_entity_id			NUMBER,
			start_date			VARCHAR2,
			calendar_id			NUMBER,
			dimension_group_id		NUMBER,
			ie_by_org_code			VARCHAR2,
			balance_by_org_flag		VARCHAR2,
			enabled_flag			VARCHAR2,
			threshold_amount		NUMBER,
			threshold_currency		VARCHAR2,
			fem_ledger_id			NUMBER,
			column_name			VARCHAR2,
			object_version_number		NUMBER,
			hierarchy_name			VARCHAR2,
			description			VARCHAR2,
			last_update_date		DATE,
			last_updated_by			NUMBER,
			last_update_login		NUMBER,
			creation_date			DATE,
			created_by			NUMBER);

  --
  -- Procedure
  --   Load_Row
  -- Purpose
  --   Loads a row into the gcs_lex_map_structs table.
  -- Arguments
  --   hierarchy_id
  --   owner
  --   last_update_date
  --   custom_mode
  --   top_entity_id
  --   start_date
  --   calendar_id
  --   dimension_group_id
  --   ie_by_org_code
  --   balance_by_org_flag
  --   enabled_flag
  --   threshold_amount
  --   threshold_currency
  --   fem_ledger_id
  --   column_name
  --   object_version_number
  --   hierarchy_name
  --   description
  -- Example
  --   GCS_HIERARCHIES_PKG.Load_Row(...);
  -- Notes
  --
  PROCEDURE Load_Row(	hierarchy_id			VARCHAR2,
			owner				VARCHAR2,
			last_update_date		VARCHAR2,
			custom_mode			VARCHAR2,
			top_entity_id			NUMBER,
			start_date			VARCHAR2,
			calendar_id			NUMBER,
			dimension_group_id		NUMBER,
			ie_by_org_code			VARCHAR2,
			balance_by_org_flag		VARCHAR2,
			enabled_flag			VARCHAR2,
			threshold_amount		NUMBER,
			threshold_currency		VARCHAR2,
			fem_ledger_id			NUMBER,
			column_name			VARCHAR2,
			object_version_number		NUMBER,
			hierarchy_name			VARCHAR2,
			description			VARCHAR2);

  --
  -- Procedure
  --   Translate_Row
  -- Purpose
  --   Updates translated infromation for a row in the
  --   gcs_hierarchies_tl table.
  -- Arguments
  --   hierarchy_id
  --   owner
  --   last_update_date
  --   custom_mode
  --   hierarchy_name
  --   description
  -- Example
  --   GCS_HIERARCHIES_PKG.Translate_Row(...);
  -- Notes
  --
  PROCEDURE Translate_Row(	hierarchy_id		NUMBER,
				owner			VARCHAR2,
				last_update_date	VARCHAR2,
				custom_mode		VARCHAR2,
				hierarchy_name		VARCHAR2,
				description		VARCHAR2);



  --
  -- Procedure
  --   ADD_LANGUAGE
  -- Purpose
  --
  -- Arguments
  --
  -- GCS_HIERARCHIES_PKG.ADD_LANGUAGE();
  -- Notes
  --
  PROCEDURE ADD_LANGUAGE ;

  --
  -- Procedure
  --   Calculate_Delta
  -- Purpose
  --   Calculates the delta ownership amounts for an entity and its children,
  --   and updates or creates the necessary gcs_cons_relationships row.
  -- Arguments
  --   p_hierarchy_id		Hierarchy for which the logic must be performed
  --   p_child_entity_id	Entity for which the logic must be performed
  --   p_effective_date		Start date for performing the logic
  -- Example
  --   GCS_HIERARCHIES_PKG.Calculate_Delta(...);
  -- Notes
  --
  PROCEDURE Calculate_Delta(	p_hierarchy_id		NUMBER,
				p_child_entity_id	NUMBER,
				p_effective_date	DATE);

  --
  -- Procedure
  --   Reciprocal_Exists
  -- Purpose
  --   See whether or not a cycle exists in the hierarchy. Search recursively
  --   for the child entity id, starting from the parent entity id, within the
  --   dates specified.
  -- Arguments
  --   p_hierarchy_id		Hierarchy for which the logic must be performed
  --   p_child_id		Entity we are searching for
  --   p_parent_id		Entity to start the search from
  --   p_start_date		Effective date range
  --   p_end_date		Effective date range
  -- Example
  --   GCS_HIERARCHIES_PKG.Reciprocal_Exists(...);
  -- Notes
  --
  FUNCTION Reciprocal_Exists(	p_hierarchy_id	NUMBER,
				p_child_id	NUMBER,
				p_parent_id	NUMBER,
				p_start_date	DATE,
				p_end_date	DATE) RETURN VARCHAR2;

  --
  -- Procedure
  --   Set_Dominance
  -- Purpose
  --   Set the dominant parent flag for a relationship after an add or update
  --   entity in the update flow.
  -- Arguments
  --   p_rel_id               New relationship identifier
  -- Example
  --   GCS_HIERARCHIES_PKG.Set_Dominance(123, 'ADD');
  -- Notes
  --
  PROCEDURE Set_Dominance(    p_rel_id        NUMBER);

  --
  -- Procedure
  --   Handle_Remove
  -- Purpose
  --   Handle removal of an entity in the update flow.
  -- Arguments
  --   p_hier_id               Hierarchy identifier
  --   p_removal_date          Date of the removal
  -- Example
  --   GCS_HIERARCHIES_PKG.Set_Dominance(123, 'ADD');
  -- Notes
  --
  PROCEDURE Handle_Remove(	p_hier_id	NUMBER,
                                p_removal_date	DATE);

  --
  -- Procedure
  --   Handle_Datatypes
  -- Purpose
  --   Creating FEM,GCS data sets, when a new hierarchy is created.
  -- Arguments
  --   p_hier_id               Hierarchy identifier
  -- Example
  --   GCS_HIERARCHIES_PKG.Handle_Datatypes(123 );
  -- Notes
  --
  PROCEDURE Handle_Datatypes (	p_hierarchy_id	NUMBER );

   --
  -- Procedure
  --   Update_Hierarchies_Datatype
 -- Purpose
  --   Creating FEM,GCS data sets, when a new data type is created.
  -- Arguments
  --   p_data_type_code         Data Type Code identifier
  -- Example
  --   GCS_HIERARCHIES_PKG.Handle_Hierarchies('TEST' );
  -- Notes
  --
  PROCEDURE Update_Hierarchies_Datatype(p_data_type_code VARCHAR2);

  --
  -- Procedure
  --   Handle_Datasets_Ledger
  -- Purpose
  --   Updates the Dataset name/desc and Ledger Name/Desc when Hierarchy Name is changed.
  -- Arguments
  --   p_hier_id               Hierarchy identifier
  -- Example
  --   GCS_HIERARCHIES_PKG.Handle_Datasets_Ledger(hierarchyId );
  -- Notes
  --
  PROCEDURE Handle_Datasets_Ledger(p_hierarchy_id NUMBER);

END GCS_HIERARCHIES_PKG;

 

/
