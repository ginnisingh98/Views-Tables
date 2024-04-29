--------------------------------------------------------
--  DDL for Package GCS_CONS_ENG_RUN_DTLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_CONS_ENG_RUN_DTLS_PKG" AUTHID CURRENT_USER AS
/* $Header: gcs_eng_run_dtls.pls 120.2 2005/12/07 02:23:35 skamdar noship $ */
  --
  -- Procedure
  --   insert_row()
  -- Purpose
  --   Inserts a row in gcs_cons_eng_run_dtls
  -- Arguments
  --	p_run_name				VARCHAR2
  --	p_consolidation_entity_id		NUMBER
  --	p_process_code				NUMBER
  --	p_child_entity_id			NUMBER
  --	p_contra_child_entity_id		VARCHAR2
  --	p_rule_id				VARCHAR2
  --	p_entry_id				NUMBER
  --	p_request_error_code			VARCHAR2
  --	p_bp_request_error_code			VARCHAR2
  --	p_pre_prop_entry_id			NUMBER
  --	p_pre_prop_stat_entry_id		NUMBER


  PROCEDURE	insert_row	(	p_run_detail_id			OUT NOCOPY NUMBER,
  					p_run_name			IN VARCHAR2,
  					p_consolidation_entity_id	IN NUMBER,
  					p_category_code			IN VARCHAR2,
  					p_child_entity_id		IN NUMBER	DEFAULT NULL,
  					p_contra_child_entity_id	IN NUMBER	DEFAULT NULL,
  					p_rule_id			IN NUMBER	DEFAULT NULL,
  					p_entry_id			IN NUMBER	DEFAULT NULL,
  					p_stat_entry_id			IN NUMBER	DEFAULT NULL,
  					p_request_error_code		IN VARCHAR2	DEFAULT NULL,
  					p_bp_request_error_code		IN VARCHAR2	DEFAULT NULL,
  					p_pre_prop_entry_id		IN NUMBER	DEFAULT NULL,
  					p_pre_prop_stat_entry_id	IN NUMBER	DEFAULT NULL,
  					p_cons_relationship_id		IN NUMBER	DEFAULT NULL);

  --
  -- Procedure
  --   update_entry_headers()
  -- Purpose
  --   Updates the status of a particular run
  -- Arguments
  --	p_run_detail_id			NUMBER
  --	p_entry_id			NUMBER
  --	p_stat_entry_id			NUMBER
  --	p_pre_prop_entry_id		NUMBER
  --	p_pre_prop_stat_entry_id	NUMBER

  PROCEDURE	update_entry_headers(	p_run_detail_id			IN NUMBER,
  					p_entry_id			IN NUMBER	DEFAULT NULL,
  					p_stat_entry_id			IN NUMBER 	DEFAULT NULL,
  					p_pre_prop_entry_id		IN NUMBER	DEFAULT NULL,
  					p_pre_prop_stat_entry_id	IN NUMBER	DEFAULT NULL,
  					p_request_error_code		IN VARCHAR2	DEFAULT NULL,
  					p_bp_request_error_code		IN VARCHAR2	DEFAULT NULL
  					);

  --
  -- Procedure
  --   update_entry_headers_async()
  -- Purpose
  --   Updates the status of a particular run
  -- Arguments
  --	p_run_detail_id			NUMBER
  --	p_entry_id			NUMBER
  --	p_stat_entry_id			NUMBER
  --	p_pre_prop_entry_id		NUMBER
  --	p_pre_prop_stat_entry_id	NUMBER

  PROCEDURE	update_entry_headers_async(	p_run_detail_id			IN NUMBER,
  						p_entry_id			IN NUMBER	DEFAULT NULL,
  						p_stat_entry_id			IN NUMBER 	DEFAULT NULL,
  						p_pre_prop_entry_id		IN NUMBER	DEFAULT NULL,
  						p_pre_prop_stat_entry_id	IN NUMBER	DEFAULT NULL,
  						p_request_error_code		IN VARCHAR2	DEFAULT NULL,
  						p_bp_request_error_code		IN VARCHAR2	DEFAULT NULL
  						);

  --
  -- Procedure
  --   update_category_status()
  -- Purpose
  --   Updates the status of a particular run
  -- Arguments
  --	p_run_detail_id			NUMBER
  --	p_entry_id			NUMBER
  --	p_stat_entry_id			NUMBER
  --	p_pre_prop_entry_id		NUMBER
  --	p_pre_prop_stat_entry_id	NUMBER

  PROCEDURE	update_category_status(	p_run_name			IN VARCHAR2,
  					p_consolidation_entity_id	IN NUMBER,
  					p_category_code			IN VARCHAR2,
  					p_status			IN VARCHAR2);


  --
  -- Procedure
  --   update_detail_requests()
  -- Purpose
  --   Updates gcs_cons_eng_run_dtls appropriately
  -- Arguments
  --	p_run_detail_id			NUMBER,
  --	p_run_process_code		VARCHAR2,

  PROCEDURE	update_detail_requests(	p_run_detail_id			IN NUMBER,
  					p_run_process_code		IN VARCHAR2
  					);

  --
  -- Procedure
  --   copy_prior_run_dtls()
  -- Purpose
  --   Copies details from a prior run to current run
  -- Arguments
  --    p_prior_run_name		VARCHAR2,
  --    p_current_run_name		VARCHAR2,
  --    p_itemtype			VARCHAR2
  --    p_entity_id			NUMBER

  PROCEDURE	copy_prior_run_dtls(   p_prior_run_name			IN VARCHAR2,
				       p_current_run_name		IN VARCHAR2,
				       p_itemtype			IN VARCHAR2,
				       p_entity_id			IN NUMBER);

END GCS_CONS_ENG_RUN_DTLS_PKG;


 

/
