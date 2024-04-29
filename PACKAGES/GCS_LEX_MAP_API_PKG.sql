--------------------------------------------------------
--  DDL for Package GCS_LEX_MAP_API_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_LEX_MAP_API_PKG" AUTHID CURRENT_USER AS
/* $Header: gcslmaps.pls 120.1 2005/10/30 05:16:04 appldev noship $ */
--
-- Package
--   gcs_lex_map_api_pkg
-- Purpose
--   Package procedures for Lexical Mapping API
-- History
--   03-APR-03	M Ward		Created
--

  TYPE error_record_type IS record(
    error_code	VARCHAR2(4),
    rule_id	NUMBER,
    deriv_num	NUMBER,
    row_id	rowid
  );
  TYPE error_table_type IS TABLE OF error_record_type INDEX BY BINARY_INTEGER;

  -- Global PL/SQL table to store error information
  error_table	error_table_type;

  --
  -- Procedure
  --   Create_Map_Functions
  -- Purpose
  --   Creates a PL/SQL function for each rule of a lexical mapping.
  --   Each function will contain the code to return the appropriate
  --   target value given the input values necessary for that lexical
  --   mapping rule.
  -- Arguments
  --   p_rule_set_id		ID of the Lexical Mapping for which the
  --				packages should be created.
  -- Example
  --   GL_LEX_MAP_PKG.Create_Map_Functions(111)
  -- Notes
  --
  PROCEDURE Create_Map_Functions(
	p_init_msg_list			VARCHAR2 DEFAULT NULL,
	x_return_status	OUT NOCOPY	VARCHAR2,
	x_msg_count	OUT NOCOPY	NUMBER,
	x_msg_data	OUT NOCOPY	VARCHAR2,
	p_rule_set_id			NUMBER);

  --
  -- Procedure
  --   Apply_Map
  -- Purpose
  --   Applies the mapping specified to the staging table specified, only
  --   affecting those rows that pass the filter criteria given. It is
  --   assumed that Create_Map_Package() has already been called for this
  --   lexical mapping prior to Apply_Map() being called.
  -- Arguments
  --   p_rule_set_id		ID of the Lexical Mapping to apply.
  --   p_staging_table_name	Name of the staging table to which this
  --				mapping should be applied.
  --   p_debug_mode		Whether or not debug information should be
  --				written to the log file.
  --   p_filter_column_name1	Name of one column to check for filtering.
  --   p_filter_column_value1	Value that the first filter column should be
  --				for the mapping to be applied to that row.
  --   ...
  --   ...
  --
  -- Example
  --   GL_LEX_MAP_PKG.Apply_Map(111, 'gl_interface', 'Y', 'group_id', '123')
  -- Notes
  --
  PROCEDURE Apply_Map(
	p_api_version		NUMBER,
	p_init_msg_list		VARCHAR2 DEFAULT NULL,
	p_commit		VARCHAR2 DEFAULT NULL,
	p_validation_level	NUMBER   DEFAULT NULL,
	x_return_status	OUT NOCOPY	VARCHAR2,
	x_msg_count	OUT NOCOPY	NUMBER,
	x_msg_data	OUT NOCOPY	VARCHAR2,
	p_rule_set_id		NUMBER,
	p_staging_table_name	VARCHAR2,
	p_debug_mode		VARCHAR2 DEFAULT NULL,
	p_filter_column_name1	VARCHAR2 DEFAULT NULL,
	p_filter_column_value1	VARCHAR2 DEFAULT NULL,
	p_filter_column_name2	VARCHAR2 DEFAULT NULL,
	p_filter_column_value2	VARCHAR2 DEFAULT NULL,
	p_filter_column_name3	VARCHAR2 DEFAULT NULL,
	p_filter_column_value3	VARCHAR2 DEFAULT NULL,
	p_filter_column_name4	VARCHAR2 DEFAULT NULL,
	p_filter_column_value4	VARCHAR2 DEFAULT NULL,
	p_filter_column_name5	VARCHAR2 DEFAULT NULL,
	p_filter_column_value5	VARCHAR2 DEFAULT NULL,
	p_filter_column_name6	VARCHAR2 DEFAULT NULL,
	p_filter_column_value6	VARCHAR2 DEFAULT NULL,
	p_filter_column_name7	VARCHAR2 DEFAULT NULL,
	p_filter_column_value7	VARCHAR2 DEFAULT NULL,
	p_filter_column_name8	VARCHAR2 DEFAULT NULL,
	p_filter_column_value8	VARCHAR2 DEFAULT NULL,
	p_filter_column_name9	VARCHAR2 DEFAULT NULL,
	p_filter_column_value9	VARCHAR2 DEFAULT NULL,
	p_filter_column_name10	VARCHAR2 DEFAULT NULL,
	p_filter_column_value10	VARCHAR2 DEFAULT NULL);

  --
  -- Procedure
  --   Create_Validation_Functions
  -- Purpose
  --   Creates a PL/SQL function for each rule of a validation rule set. Each
  --   function will contain the code to return a status code based on the
  --   success of the validation.
  -- Arguments
  --   p_rule_set_id		ID of the Validation Rule Set
  -- Example
  --   GL_LEX_MAP_PKG.Create_Validation_Functions(111)
  -- Notes
  --
  PROCEDURE Create_Validation_Functions(
	p_init_msg_list			VARCHAR2 DEFAULT NULL,
	x_return_status	OUT NOCOPY	VARCHAR2,
	x_msg_count	OUT NOCOPY	NUMBER,
	x_msg_data	OUT NOCOPY	VARCHAR2,
	p_rule_set_id			NUMBER);

  --
  -- Procedure
  --   Apply_Validation
  -- Purpose
  --   Applies the validation specified to the staging table specified, only
  --   affecting those rows that pass the filter criteria given. It is
  --   assumed that Create_Validation_Functions() has already been called for
  --   this validation rule set
  -- Arguments
  --   p_rule_set_id		ID of the Validation Rule Set to apply.
  --   p_staging_table_name	Name of the staging table to which this
  --				mapping should be applied.
  --   p_debug_mode		Whether or not debug information should be
  --				written to the log file.
  --   p_filter_column_name1	Name of one column to check for filtering.
  --   p_filter_column_value1	Value that the first filter column should be
  --				for the mapping to be applied to that row.
  --   ...
  --   ...
  --
  -- Example
  --   GL_LEX_MAP_PKG.Apply_Validation(1, 'gl_interface', 'Y', 'group_id', '3')
  -- Notes
  --
  PROCEDURE Apply_Validation(
	p_api_version		NUMBER,
	p_init_msg_list		VARCHAR2 DEFAULT NULL,
	p_commit		VARCHAR2 DEFAULT NULL,
	p_validation_level	NUMBER   DEFAULT NULL,
	x_return_status	OUT NOCOPY	VARCHAR2,
	x_msg_count	OUT NOCOPY	NUMBER,
	x_msg_data	OUT NOCOPY	VARCHAR2,
	p_rule_set_id		NUMBER,
	p_staging_table_name	VARCHAR2,
	p_debug_mode		VARCHAR2 DEFAULT NULL,
	p_filter_column_name1	VARCHAR2 DEFAULT NULL,
	p_filter_column_value1	VARCHAR2 DEFAULT NULL,
	p_filter_column_name2	VARCHAR2 DEFAULT NULL,
	p_filter_column_value2	VARCHAR2 DEFAULT NULL,
	p_filter_column_name3	VARCHAR2 DEFAULT NULL,
	p_filter_column_value3	VARCHAR2 DEFAULT NULL,
	p_filter_column_name4	VARCHAR2 DEFAULT NULL,
	p_filter_column_value4	VARCHAR2 DEFAULT NULL,
	p_filter_column_name5	VARCHAR2 DEFAULT NULL,
	p_filter_column_value5	VARCHAR2 DEFAULT NULL,
	p_filter_column_name6	VARCHAR2 DEFAULT NULL,
	p_filter_column_value6	VARCHAR2 DEFAULT NULL,
	p_filter_column_name7	VARCHAR2 DEFAULT NULL,
	p_filter_column_value7	VARCHAR2 DEFAULT NULL,
	p_filter_column_name8	VARCHAR2 DEFAULT NULL,
	p_filter_column_value8	VARCHAR2 DEFAULT NULL,
	p_filter_column_name9	VARCHAR2 DEFAULT NULL,
	p_filter_column_value9	VARCHAR2 DEFAULT NULL,
	p_filter_column_name10	VARCHAR2 DEFAULT NULL,
	p_filter_column_value10	VARCHAR2 DEFAULT NULL);

  --
  -- Procedure
  --   After_FEM_Refresh
  -- Purpose
  --   Populates new associated_object_id's for gcs_lex_map_rule_sets.
  -- Example
  --   GL_LEX_MAP_PKG.After_FEM_Refresh
  -- Notes
  --
  PROCEDURE After_FEM_Refresh;

END GCS_LEX_MAP_API_PKG;

 

/
