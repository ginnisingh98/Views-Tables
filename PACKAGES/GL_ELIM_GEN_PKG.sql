--------------------------------------------------------
--  DDL for Package GL_ELIM_GEN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_ELIM_GEN_PKG" AUTHID CURRENT_USER AS
/* $Header: glelgens.pls 120.4 2005/05/05 02:03:48 kvora ship $ */
--
-- Package
--   GL_ELIM_GEN_pkg
-- Purpose
--   To contain database functions needed in Generate Elimination Sets form
-- History
--

--
-- PUBLIC VARIABLES
--
	period_start_date	DATE;
	period_end_date		DATE;

  --
  -- Procedure
  -- 	set_data
  -- PURPOSE
  --	sets ALL the package (global) variables
  -- History
  --	05-NOV-98	Maria Hui	Created
  -- Arguments
  --	All the global values of this package
  -- Notes
  --

    PROCEDURE set_data (	X_period_start 	DATE,
				X_period_end 	DATE);

  --
  -- Procedure
  -- 	get_period_start_date
  -- PURPOSE
  --	get the start date of the period
  -- History
  --	05-NOV-98	Maria Hui	Created
  -- Arguments
  --	None
  -- Notes
  --

    FUNCTION get_period_start_date RETURN DATE;
    PRAGMA RESTRICT_REFERENCES(get_period_start_date,WNDS,WNPS);


  --
  -- Procedure
  -- 	get_period_end_date
  -- PURPOSE
  --	get the end date of the period
  -- History
  --	05-NOV-98	Maria Hui	Created
  -- Arguments
  --	None
  -- Notes
  --

    FUNCTION get_period_end_date RETURN DATE;
    PRAGMA RESTRICT_REFERENCES(get_period_end_date,WNDS,WNPS);


  --
  -- Procedure
  -- 	insert_elim_history
  -- PURPOSE
  --	to create default rows for the generated elimination sets in
  --	GL_ELIMINATION_HISTORY
  -- History
  --	10-NOV-98	Maria Hui	Created
  --    05-NOV-02	Jane Huang	replaced set_of_books_id with ledger_id
  -- Arguments
  --	None
  -- Notes
  --

    PROCEDURE insert_elim_history(
		X_request_id		NUMBER,
		X_elimination_set_id	NUMBER,
		X_ledger_id		NUMBER,
		X_period_name		VARCHAR2
	);


  --
  -- Procedure
  -- 	save_to_elim_hist
  -- PURPOSE
  --	to commit changes made to GL_ELIMINATION_HISTORY
  -- History
  --	12-NOV-98	Maria Hui	Created
  -- Arguments
  --	None
  -- Notes
  --

    PROCEDURE save_to_elim_hist;

----------------------------------------------------------------------------
  --
  -- Procedure
  -- submit_request
  --  PURPOSE to submit concurrent request
  -- History:
  -- 04-03-97 Kevin Chen Created
  -- Arguments:
  --	average_translation_flag VARCHAR2(1),
  --	set_of_books_id		 NUMBER,
  --	currency_code		 VARCHAR2(15),
  -- 	period			 VARCHAR2(15),
  --	balancing_segment_value	 VARCHAR2(25),
  --	source_budget_version_id NUMBER,
  --	target_budget_version_id NUMBER
  -- Notes:

--      FUNCTION submit_request (
--	X_average_translation_flag 	VARCHAR2,
--	X_set_of_books_id		NUMBER,
--	X_currency_code		 	VARCHAR2,
--	X_period			VARCHAR2,
--	X_balance_type			VARCHAR2,
--	X_balancing_segment_value	VARCHAR2,
--	X_source_budget_version_id 	NUMBER,
--	X_target_budget_version_id 	NUMBER) RETURN NUMBER;

END GL_ELIM_GEN_PKG;

 

/
