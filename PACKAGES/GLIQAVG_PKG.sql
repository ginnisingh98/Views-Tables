--------------------------------------------------------
--  DDL for Package GLIQAVG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GLIQAVG_PKG" AUTHID CURRENT_USER AS
/* $Header: gliqavgs.pls 120.2 2005/05/05 01:19:01 kvora ship $ */
--
-- Package
--   GLIQAVG_pkg
-- Purpose
--   To contain database functions needed in Average Balance Inquiry form
-- History
--   01-10-96   Kevin CHEN	Created

--
-- PUBLIC VARIABLES
--
	code_combination_id		NUMBER;
	template_id			NUMBER;
	factor				NUMBER := 1;

--
-- PUBLIC PROCEDURES
--

  --
  -- Procedure
  -- 	set_ccid
  -- PURPOSE
  --	sets the code_combination_id for ar drill down
  -- History:
  --	01-10-96 Kevin CHEN Created
  -- Arguments:
  --	All the global values of this package
  -- Notes:
  --
    	PROCEDURE set_ccid (X_code_combination_id     	NUMBER);

  --
  -- Procedure
  -- 	set_template_id
  -- PURPOSE
  --	sets the template_id for ar drill down
  -- History:
  --	01-10-96 Kevin CHEN Created
  -- Arguments:
  --	All the global values of this package
  -- Notes:
  --
    	PROCEDURE set_template_id (X_template_id     	NUMBER);

  --
  -- Procedure
  -- 	set_factor
  -- PURPOSE
  --	sets the factor for drill down amounts
  -- History:
  --	01-12-96 Kevin CHEN Created
  -- Arguments:
  --	All the global values of this package
  -- Notes:
  --
    	PROCEDURE set_factor (X_factor     	NUMBER);

  --
  -- Procedure
  --  	get_ccid
  -- PURPOSE
  --	gets the package (global) variable, USED in base view's where part
  -- History:
  -- 	01-10-96  Kevin CHEN Created
  -- Notes
  --
	FUNCTION	get_ccid	RETURN NUMBER;
	PRAGMA 		RESTRICT_REFERENCES(get_ccid,WNDS,WNPS);

  --
  -- Procedure
  --  	get_template_id
  -- PURPOSE
  --	gets the package (global) variable, USED in base view's where part
  -- History:
  -- 	01-10-96  Kevin CHEN Created
  -- Notes
  --
	FUNCTION	get_template_id	RETURN NUMBER;
	PRAGMA 		RESTRICT_REFERENCES(get_template_id,WNDS,WNPS);

  --
  -- Procedure
  --  	get_factor
  -- PURPOSE
  --	gets the package (global) variable, USED in base view's where part
  -- History:
  -- 	01-12-96  Kevin CHEN Created
  -- Notes
  --
	FUNCTION	get_factor	RETURN NUMBER;
	PRAGMA 		RESTRICT_REFERENCES(get_factor,WNDS,WNPS);

END GLIQAVG_PKG;

 

/
