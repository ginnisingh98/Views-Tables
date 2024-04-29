--------------------------------------------------------
--  DDL for Package GCS_CONS_ENG_RUNS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_CONS_ENG_RUNS_PKG" AUTHID CURRENT_USER AS
/* $Header: gcs_eng_runs.pls 120.1 2005/10/30 05:18:04 appldev noship $ */
  --
  -- Procedure
  --   insert_row()
  -- Purpose
  --   Inserts a row in gcs_cons_eng_runs
  -- Arguments
  --	p_run_name		VARCHAR2
  --	p_hierarchy_id		NUMBER
  --	p_run_entity_id		NUMBER
  --	p_cal_period_id		NUMBER
  --	p_balance_type_code	VARCHAR2
  --    p_parent_entity_id      NUMBER
  --    p_item_key		VARCHAR2
  --    p_request_id		NUMBER

  PROCEDURE	insert_row	(	p_run_name		IN VARCHAR2,
  					p_hierarchy_id		IN NUMBER,
  					p_process_method_code	IN VARCHAR2,
  					p_run_entity_id		IN NUMBER,
  					p_cal_period_id		IN NUMBER,
  					p_balance_type_code	IN VARCHAR2,
  					p_parent_entity_id	IN NUMBER,
  					p_item_key		IN VARCHAR2,
					p_request_id		IN NUMBER);
  --
  -- Procedure
  --   update_status()
  -- Purpose
  --   Updates run_status appropriately
  -- Arguments
  --    p_run_name              VARCHAR2
  --    p_most_recent_flag	VARCHAR2
  --    p_run_entity_id         NUMBER
  --	p_end_time		DATE

  PROCEDURE	update_status	(	p_run_name		IN VARCHAR2,
  					p_most_recent_flag	IN VARCHAR2,
  					p_status_code		IN VARCHAR2,
  					p_run_entity_id		IN NUMBER,
  -- Bugfix 3692336 : Support Adding an END_TIME for the Consolidation Run
					p_end_time		IN DATE DEFAULT NULL);


END GCS_CONS_ENG_RUNS_PKG;

 

/
