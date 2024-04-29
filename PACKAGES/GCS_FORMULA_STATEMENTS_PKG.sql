--------------------------------------------------------
--  DDL for Package GCS_FORMULA_STATEMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_FORMULA_STATEMENTS_PKG" AUTHID CURRENT_USER AS
/* $Header: gcserfss.pls 120.1 2005/10/30 05:18:18 appldev noship $ */
--
-- Package
--   gcs_formula_statements_pkg
-- Purpose
--   Package procedures for GCS formula statements table
-- History
--	27-APR-04	J Huang		Created
--

  --
  -- Procedure
  --   Insert_Row
  -- Purpose
  --   Inserts a row into the gcs_formula_statements table.
  -- Arguments
  --   row_id			Row ID of the inserted row.
  --   statement_num		Numeric value of the sql statement
  --   rule_type_code           Whether the variable is intended for use
  --                            in A&D or Consolidation, or both, formulas.
  --   statement_text      	Sql statement text.
  --   compiled_variables   	Comma delimited list of names of bind variables
  --                            used in this sql statement.
  --   last_update_date		Last time the structure was updated.
  --   last_updated_by		User last updating this structure.
  --   last_update_login	Login of person last updating this structure.
  --   creation_date		Time this structure was created.
  --   created_by		User who created this structure.
  -- Example
  --   GCS_FORMULA_STATEMENTS_PKG.Insert_Row(...);
  -- Notes
  --
  PROCEDURE Insert_Row(	row_id	IN OUT NOCOPY	VARCHAR2,
			statement_num		VARCHAR2,
			rule_type_code		VARCHAR2,
			statement_text 		VARCHAR2,
			compiled_variables	VARCHAR2,
			last_update_date	DATE,
			last_updated_by		NUMBER,
			last_update_login	NUMBER,
			creation_date		DATE,
			created_by		NUMBER);

  --
  -- Procedure
  --   Update_Row
  -- Purpose
  --   Updates a row in the gcs_formula_statements table.
  -- Arguments
  --   statement_num		Numeric value of the sql statement
  --   rule_type_code           Whether the variable is intended for use
  --                            in A&D or Consolidation, or both, formulas.
  --   statement_text      	Sql statement text.
  --   compiled_variables   	Comma delimited list of names of bind variables
  --                            used in this sql statement.
  --   last_update_date		Last time the structure was updated.
  --   last_updated_by		User last updating this structure.
  --   last_update_login	Login of person last updating this structure.
  -- Example
  --   GCS_FORMULA_STATEMENTS_PKG.Update_Row(...);
  -- Notes
  --
  PROCEDURE Update_Row(	statement_num		VARCHAR2,
			rule_type_code		VARCHAR2,
			statement_text 		VARCHAR2,
			compiled_variables	VARCHAR2,
			last_update_date	DATE,
			last_updated_by		NUMBER,
			last_update_login	NUMBER);

  --
  -- Procedure
  --   Load_Row
  -- Purpose
  --   Loads a row into the gcs_formula_statements table.
  -- Arguments
  --   statement_num	Name of the formual variable
  --   rule_type_code           Whether the variable is intended for use
  --                            in A&D or Consolidation, or both, formulas.
  --   owner			Whether this is custom or seed data.
  --   last_update_date		Last time the structure was updated.
  --   statement_text      Sql statement value assigned to the variable.
  --   compiled_variables   Bind variable name, when applicable.
  --              Sql expression
  --   custom_mode		Whether or not to force a load.
  -- Example
  --   GCS_FORMULA_STATEMENTS_PKG.Load_Row(...);
  -- Notes
  --
  PROCEDURE Load_Row(	statement_num		VARCHAR2,
			rule_type_code		VARCHAR2,
			owner			VARCHAR2,
			last_update_date	VARCHAR2,
			statement_text 		VARCHAR2,
			compiled_variables	VARCHAR2,
			custom_mode		VARCHAR2);

  --
  -- Procedure
  --   Translate_Row
  -- Purpose
  --   Updates translated infromation for a row in the
  --   gcs_formula_statements table.
  -- Arguments
  --   statement_num	Name of the formual variable
  --   rule_type_code           Whether the variable is intended for use
  --                            in A&D or Consolidation, or both, formulas.
  --   owner			Whether this is custom or seed data.
  --   last_update_date		Last time the structure was updated.
  --   custom_mode		Whether or not to force a load.
  -- Example
  --   GCS_FORMULA_STATEMENTS_PKG.Translate_Row(...);
  -- Notes
  --
  PROCEDURE Translate_Row(	statement_num		VARCHAR2,
				rule_type_code		VARCHAR2,
				owner			VARCHAR2,
				last_update_date	VARCHAR2,
				custom_mode		VARCHAR2);

END GCS_FORMULA_STATEMENTS_PKG;

 

/
