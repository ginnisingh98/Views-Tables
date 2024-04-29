--------------------------------------------------------
--  DDL for Package GCS_LEX_MAP_STRUCTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_LEX_MAP_STRUCTS_PKG" AUTHID CURRENT_USER AS
/* $Header: gcslxmss.pls 115.2 2003/08/13 17:54:41 mikeward noship $ */
--
-- Package
--   gcs_lex_map_structs_pkg
-- Purpose
--   Package procedures for Lexical Mapping Structures
-- History
--   23-JUN-03	M Ward		Created
--   28-JUL-03	M Ward		Added translate_row
--

  --
  -- Procedure
  --   Insert_Row
  -- Purpose
  --   Inserts a row into the gcs_lex_map_structs table.
  -- Arguments
  --   row_id			Row ID of the inserted row.
  --   structure_name		Name of the structure.
  --   description		Description of the structure.
  --   table_use_type_code	Whether this is a lookup or staging table.
  --   last_update_date		Last time the structure was updated.
  --   last_updated_by		User last updating this structure.
  --   last_update_login	Login of person last updating this structure.
  --   creation_date		Time this structure was created.
  --   created_by		User who created this structure.
  -- Example
  --   GCS_LEX_MAP_STRUCTS_PKG.Insert_Row(...);
  -- Notes
  --
  PROCEDURE Insert_Row(	row_id	IN OUT NOCOPY	VARCHAR2,
			structure_name		VARCHAR2,
			description		VARCHAR2,
			table_use_type_code	VARCHAR2,
			last_update_date	DATE,
			last_updated_by		NUMBER,
			last_update_login	NUMBER,
			creation_date		DATE,
			created_by		NUMBER);

  --
  -- Procedure
  --   Update_Row
  -- Purpose
  --   Updates a row in the gcs_lex_map_structs table.
  -- Arguments
  --   structure_name		Name of the structure.
  --   description		Description of the structure.
  --   table_use_type_code	Whether this is a lookup or staging table.
  --   last_update_date		Last time the structure was updated.
  --   last_updated_by		User last updating this structure.
  --   last_update_login	Login of person last updating this structure.
  -- Example
  --   GCS_LEX_MAP_STRUCTS_PKG.Update_Row(...);
  -- Notes
  --
  PROCEDURE Update_Row(	structure_name		VARCHAR2,
			description		VARCHAR2,
			table_use_type_code	VARCHAR2,
			last_update_date	DATE,
			last_updated_by		NUMBER,
			last_update_login	NUMBER);

  --
  -- Procedure
  --   Load_Row
  -- Purpose
  --   Loads a row into the gcs_lex_map_structs table.
  -- Arguments
  --   structure_name		Name of the structure.
  --   owner			Whether this is custom or seed data.
  --   last_update_date		Last time the structure was updated.
  --   description		Description of the structure.
  --   table_use_type_code	Whether this is a lookup or staging table.
  --   custom_mode		Whether or not to force a load.
  -- Example
  --   GCS_LEX_MAP_STRUCTS_PKG.Load_Row(...);
  -- Notes
  --
  PROCEDURE Load_Row(	structure_name		VARCHAR2,
			owner			VARCHAR2,
			last_update_date	VARCHAR2,
			description		VARCHAR2,
			table_use_type_code	VARCHAR2,
			custom_mode		VARCHAR2);

  --
  -- Procedure
  --   Translate_Row
  -- Purpose
  --   Updates translated infromation for a row in the
  --   gcs_lex_map_structs table.
  -- Arguments
  --   structure_name		Name of the structure.
  --   owner			Whether this is custom or seed data.
  --   last_update_date		Last time the structure was updated.
  --   custom_mode		Whether or not to force a load.
  -- Example
  --   GCS_LEX_MAP_STRUCTS_PKG.Translate_Row(...);
  -- Notes
  --
  PROCEDURE Translate_Row(	structure_name		VARCHAR2,
				owner			VARCHAR2,
				last_update_date	VARCHAR2,
				custom_mode		VARCHAR2);

END GCS_LEX_MAP_STRUCTS_PKG;

 

/
