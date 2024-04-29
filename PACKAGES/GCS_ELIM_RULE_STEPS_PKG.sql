--------------------------------------------------------
--  DDL for Package GCS_ELIM_RULE_STEPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_ELIM_RULE_STEPS_PKG" AUTHID CURRENT_USER AS
/* $Header: gcs_rule_steps.pls 120.1 2005/10/30 05:19:04 appldev noship $ */

  -- Procedure
  --   Insert_Row
  -- Purpose
  --   Inserts a row into the gcs_elim_rule_steps_b table and  gcs_elim_rule_steps_b_tl
  -- Arguments
  --	 row_id
  --	 RULE_ID
  --	 RULE_STEP_ID
  --	 STEP_SEQ
  --	 FORMULA_TEXT
  --	 PARSED_FORMULA
  --	 COMPILED_VARIABLES
  --	 SQL_STATEMENT_NUM
  --	 OBJECT_VERSION_NUMBER
  --	 LAST_UPDATE_DATE
  --	 LAST_UPDATED_BY
  --	 CREATION_DATE
  --	 CREATED_BY
  --	 LAST_UPDATE_LOGIN
  --	 STEP_NAME

  -- Example
  --   GCS_ELIM_RULE_STEPS_PKG.Insert_Row(...);
  -- Notes
  --


 PROCEDURE Insert_Row
 (
	 row_id	IN OUT NOCOPY		VARCHAR2,
	 RULE_ID			NUMBER,
	 RULE_STEP_ID			NUMBER,
	 STEP_SEQ			NUMBER,
	 FORMULA_TEXT			VARCHAR2,
	 PARSED_FORMULA			VARCHAR2,
	 COMPILED_VARIABLES		VARCHAR2,
	 SQL_STATEMENT_NUM		NUMBER,
	 OBJECT_VERSION_NUMBER		NUMBER,
	 LAST_UPDATE_DATE		DATE,
	 LAST_UPDATED_BY		NUMBER,
	 CREATION_DATE			DATE,
	 CREATED_BY			NUMBER,
	 LAST_UPDATE_LOGIN		NUMBER,
	 STEP_NAME			VARCHAR2
 );


  -- Procedure
  --   Update_Row
  -- Purpose
  --   Updates a row into the gcs_elim_rule_steps_b table.
  -- Arguments
	-- row_id
	-- RULE_ID
	-- RULE_STEP_ID
	-- STEP_SEQ
	-- FORMULA_TEXT
	-- PARSED_FORMULA
	-- COMPILED_VARIABLES
	-- SQL_STATEMENT_NUM
	-- OBJECT_VERSION_NUMBER
	-- LAST_UPDATE_DATE
	-- LAST_UPDATED_BY
	-- CREATION_DATE
	-- CREATED_BY
	-- LAST_UPDATE_LOGIN
	-- STEP_NAME

  -- Example
  --   GCS_ELIM_RULE_STEPS_PKG.Update_Row(...);
  -- Notes
  --


 PROCEDURE Update_Row
 (
	 row_id	IN OUT NOCOPY		VARCHAR2,
	 RULE_ID			NUMBER,
	 RULE_STEP_ID			NUMBER,
	 STEP_SEQ			NUMBER,
	 FORMULA_TEXT			VARCHAR2,
	 PARSED_FORMULA			VARCHAR2,
	 COMPILED_VARIABLES		VARCHAR2,
	 SQL_STATEMENT_NUM		NUMBER,
	 OBJECT_VERSION_NUMBER		NUMBER,
	 LAST_UPDATE_DATE		DATE,
	 LAST_UPDATED_BY		NUMBER,
	 CREATION_DATE			DATE,
	 CREATED_BY			NUMBER,
	 LAST_UPDATE_LOGIN		NUMBER,
	 STEP_NAME			VARCHAR2
);

-- Procedure
  --   Load_Row
  -- Purpose
  --   Loads a row into the gcs_elim_rule_steps_b table.
  -- Arguments
	-- row_id
	-- RULE_ID
	-- RULE_STEP_ID
	-- STEP_SEQ
	-- FORMULA_TEXT
	-- PARSED_FORMULA
	-- COMPILED_VARIABLES
	-- SQL_STATEMENT_NUM
	-- OBJECT_VERSION_NUMBER
	-- LAST_UPDATE_DATE
	-- LAST_UPDATED_BY
	-- CREATION_DATE
	-- CREATED_BY
	-- LAST_UPDATE_LOGIN
	-- owner
	-- custom_mode
	-- STEP_NAME

  -- Example
  --   GCS_ELIM_RULE_STEPS_PKG.Load_Row(...);
  -- Notes
  --


 PROCEDURE Load_Row
 (
	 row_id	IN OUT NOCOPY		VARCHAR2,
	 RULE_ID			NUMBER,
	 RULE_STEP_ID			NUMBER,
	 STEP_SEQ			NUMBER,
	 FORMULA_TEXT			VARCHAR2,
	 PARSED_FORMULA			VARCHAR2,
	 COMPILED_VARIABLES		VARCHAR2,
	 SQL_STATEMENT_NUM		NUMBER,
	 OBJECT_VERSION_NUMBER		NUMBER,
	 LAST_UPDATE_DATE		DATE,
	 LAST_UPDATED_BY		NUMBER,
	 CREATION_DATE			DATE,
	 CREATED_BY			NUMBER,
	 LAST_UPDATE_LOGIN		NUMBER,
	 owner				VARCHAR2,
	 custom_mode			varchar2,
	 STEP_NAME			VARCHAR2
);


  -- Procedure
  --   Translate_Row
  -- Purpose
  --   Updates translated infromation for a row in the
  --   gcs_elim_rule_steps_tl table.
  -- Arguments
  --	 RULE_STEP_ID
  --	 LANGUAGE
  --	 SOURCE_LANG
  --	 STEP_NAME
  --	 LAST_UPDATE_DATE
  --	 LAST_UPDATED_BY
  --	 CREATION_DATE
  --	 CREATED_BY
  --	 LAST_UPDATE_LOGIN
  --	 owner
  --	 custom_mode

  -- Example
  --   GCS_ELIM_RULE_STEPS_PKG.Translate_Row(...);
  -- Notes

 PROCEDURE Translate_Row
 (
	 RULE_STEP_ID			NUMBER,
	 STEP_NAME			VARCHAR2,
	 LAST_UPDATE_DATE		DATE,
	 LAST_UPDATED_BY		NUMBER,
	 CREATION_DATE			DATE,
	 CREATED_BY			NUMBER,
	 LAST_UPDATE_LOGIN		NUMBER,
	 owner				varchar2,
	 custom_mode			varchar2
 );

procedure ADD_LANGUAGE ;


END GCS_ELIM_RULE_STEPS_PKG;

 

/
