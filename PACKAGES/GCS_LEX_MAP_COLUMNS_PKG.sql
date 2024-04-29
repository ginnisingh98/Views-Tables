--------------------------------------------------------
--  DDL for Package GCS_LEX_MAP_COLUMNS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_LEX_MAP_COLUMNS_PKG" AUTHID CURRENT_USER AS
/* $Header: gcslxmcs.pls 115.2 2003/08/13 17:54:55 mikeward noship $ */
--
-- Package
--   gcs_lex_map_columns_pkg
-- Purpose
--   Package procedures for Lexical Mapping Columns
-- History
--   23-JUN-03	M Ward		Created
--   28-JUL-03	M Ward		Added translate_row
--

  --
  -- Procedure
  --   Insert_Row
  -- Purpose
  --   Inserts a row into the gcs_lex_map_columns table.
  -- Arguments
  --   row_id			Row ID of the inserted row.
  --   structure_id		ID of the structure.
  --   column_name		Name of the column.
  --   column_type_code		Type of column (V, N, D).
  --   write_flag		Read-only or read-write.
  --   error_code_column_flag	Whether or not this is an error code column.
  --   last_update_date		Last time the column was updated.
  --   last_updated_by		User last updating this column.
  --   last_update_login	Login of the person last updating this column.
  --   creation_date		Time this column was created.
  --   created_by		User who created this column.
  -- Example
  --   GCS_LEX_MAP_COLUMNS_PKG.Insert_Row(...);
  -- Notes
  --
  PROCEDURE Insert_Row(	row_id	IN OUT NOCOPY	VARCHAR2,
			structure_id		NUMBER,
			column_name		VARCHAR2,
			column_type_code	VARCHAR2,
			write_flag		VARCHAR2,
			error_code_column_flag	VARCHAR2,
			last_update_date	DATE,
			last_updated_by		NUMBER,
			last_update_login	NUMBER,
			creation_date		DATE,
			created_by		NUMBER);

  --
  -- Procedure
  --   Update_Row
  -- Purpose
  --   Updates a row in the gcs_lex_map_columns table.
  -- Arguments
  --   structure_id		ID of the structure.
  --   column_name		Name of the column.
  --   column_type_code		Type of column (V, N, D).
  --   write_flag		Read-only or read-write.
  --   error_code_column_flag	Whether or not this is an error code column.
  --   last_update_date		Last time the column was updated.
  --   last_updated_by		User last updating this column.
  --   last_update_login	Login of the person last updating this column.
  -- Example
  --   GCS_LEX_MAP_COLUMNS_PKG.Update_Row(...);
  -- Notes
  --
  PROCEDURE Update_Row(	structure_id		NUMBER,
			column_name		VARCHAR2,
			column_type_code	VARCHAR2,
			write_flag		VARCHAR2,
			error_code_column_flag	VARCHAR2,
			last_update_date	DATE,
			last_updated_by		NUMBER,
			last_update_login	NUMBER);

  --
  -- Procedure
  --   Load_Row
  -- Purpose
  --   Loads a row into the gcs_lex_map_columns table.
  -- Arguments
  --   structure_name		Name of the structure.
  --   column_name		Name of the column.
  --   owner			Whether this is custom or seed data.
  --   last_update_date		Last time the column was updated.
  --   column_type_code		Type of column (V, N, D).
  --   write_flag		Read-only or read-write.
  --   error_code_column_flag	Whether or not this is an error code column.
  --   custom_mode		Whether or not to force a load.
  -- Example
  --   GCS_LEX_MAP_COLUMNS_PKG.Load_Row(...);
  -- Notes
  --
  PROCEDURE Load_Row(	structure_name		VARCHAR2,
			column_name		VARCHAR2,
			owner			VARCHAR2,
			last_update_date	VARCHAR2,
			column_type_code	VARCHAR2,
			write_flag		VARCHAR2,
			error_code_column_flag	VARCHAR2,
			custom_mode		VARCHAR2);

  --
  -- Procedure
  --   Translate_Row
  -- Purpose
  --   Updates translated infromation for a row in the
  --   gcs_lex_map_columns table.
  -- Arguments
  --   structure_name		Name of the structure.
  --   column_name		Name of the column.
  --   owner			Whether this is custom or seed data.
  --   last_update_date		Last time the column was updated.
  --   custom_mode		Whether or not to force a load.
  -- Example
  --   GCS_LEX_MAP_COLUMNS_PKG.Translate_Row(...);
  -- Notes
  --
  PROCEDURE Translate_Row(	structure_name		VARCHAR2,
				column_name		VARCHAR2,
				owner			VARCHAR2,
				last_update_date	VARCHAR2,
				custom_mode		VARCHAR2);

END GCS_LEX_MAP_COLUMNS_PKG;

 

/
