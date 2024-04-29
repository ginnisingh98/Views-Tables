--------------------------------------------------------
--  DDL for Package GL_CONS_WRK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_CONS_WRK_PKG" AUTHID CURRENT_USER AS
/* $Header: glcowrks.pls 120.5 2005/05/05 02:02:57 kvora ship $ */
--
-- Package
--   GL_CONS_WRK_pkg
-- Purpose
--   To contain database functions needed in Consolidation Workbench form
-- History
--   04-03-97   Kevin Chen	Created

--
-- PUBLIC VARIABLES
--
	period			VARCHAR2(15);
	access_set_id		NUMBER;

  --
  -- Procedure
  -- set_data
  --  PURPOSE sets ALL the package (global) variables
  -- History: 04-03-97 Kevin Chen Created
  --          07-18-02 Michael Ward changed sob_id to ledger_id
  --          01-09-03 Michael Ward changed ledger_id to access_set_id
  -- Arguments: All the global values of this package
  -- Notes:

    PROCEDURE set_data (X_period     	VARCHAR2,
			X_access_set_id	NUMBER);

  --
  -- Procedure
  -- get_period
  --  PURPOSE get period name
  -- History: 04-03-97 Kevin Chen Created
  -- Arguments: None
  -- Notes:

    FUNCTION get_period RETURN VARCHAR2;
    PRAGMA 		RESTRICT_REFERENCES(get_period,WNDS,WNPS);

  --
  -- Procedure
  -- get_access_set_id
  --  PURPOSE get access set id
  -- History: 04-03-97 Kevin Chen Created
  --          07-18-02 Michael Ward Changed sob_id to ledger_id
  --          01-09-03 Michael Ward Changed ledger_id to access_set_id
  -- Arguments: None
  -- Notes:

    FUNCTION get_access_set_id RETURN NUMBER;
    PRAGMA 		RESTRICT_REFERENCES(get_access_set_id,WNDS,WNPS);

  --
  -- Procedure
  -- submit_request
  --  PURPOSE to submit concurrent request
  -- History: 04-03-97 Kevin Chen Created
  --          07-18-02 Michael Ward Changed sob_id to ledger_id
  --          05-07-03 Michael Ward Added parameters
  -- Arguments:
  --	average_translation_flag VARCHAR2(1),
  --	ledger_id		 NUMBER,
  --	currency_code		 VARCHAR2(15),
  -- 	period			 VARCHAR2(15),
  --	balancing_segment_value	 VARCHAR2(25),
  --	source_budget_version_id NUMBER,
  --	target_budget_version_id NUMBER,
  --	access_set_id		 NUMBER,
  --    chart_of_accounts_id	 NUMBER,
  --	avg_rate_type		 VARCHAR2(30),
  --    eop_rate_type		 VARCHAR2(30),
  --	ledger_short_name	 VARCHAR2(20)
  -- Notes:

    FUNCTION submit_request (
	X_average_translation_flag 	VARCHAR2,
	X_ledger_id			NUMBER,
	X_currency_code		 	VARCHAR2,
	X_period			VARCHAR2,
	X_balance_type			VARCHAR2,
	X_balancing_segment_value	VARCHAR2,
	X_source_budget_version_id 	NUMBER,
	X_target_budget_version_id 	NUMBER,
	X_access_set_id			NUMBER,
	X_chart_of_accounts_id		NUMBER,
	X_avg_rate_type			VARCHAR2,
	X_eop_rate_type			VARCHAR2,
	X_ledger_short_name		VARCHAR2) RETURN NUMBER;

  --
  -- Function
  -- get_translation_status
  --  PURPOSE to get translation status of a consolidation
  -- History: 06-06-97 Kevin Chen Created
  --          07-18-02 Michael Ward Changed sob_id to ledger_id
  -- Arguments:
  --	ledger_id		 NUMBER,
  --    period_name   		 VARCHAR2(15),
  --	currency_code		 VARCHAR2(15),
  -- 	actual_flag		 VARCHAR2(1)
  -- Notes:
   FUNCTION get_translation_status (
	X_ledger_id		 NUMBER,
        X_period_name   		 VARCHAR2,
  	X_currency_code		 VARCHAR2,
   	X_actual_flag		 VARCHAR2) RETURN VARCHAR2;

END GL_CONS_WRK_PKG;

 

/
