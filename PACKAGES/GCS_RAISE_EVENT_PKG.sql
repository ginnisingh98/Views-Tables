--------------------------------------------------------
--  DDL for Package GCS_RAISE_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_RAISE_EVENT_PKG" AUTHID CURRENT_USER as
/* $Header: gcs_raise_events.pls 120.5 2007/12/05 14:37:20 rthati noship $ */

  --
  -- Procedure
  --   raise_hierarchy_alt_event()
  -- Purpose
  --   Raised by the Hierarchy UI, during the update flow
  -- Arguments
  --	p_pre_cons_relationship_id	NUMBER
  --	p_post_cons_relationship_id	NUMBER
  -- 	p_trx_type_code			VARCHAR2
  --    p_trx_date_day			NUMBER
  --	p_trx_date_month		NUMBER
  --	p_trx_date_year			NUMBER
  --	p_hidden_flag			VARCHAR2
  --	p_intermediate_trtmnt_id	NUMBER
  --    p_intermediate_pct_owned	NUMBER

  PROCEDURE	raise_hierarchy_alt_event	(p_pre_cons_relationship_id	IN	NUMBER,
  						 p_post_cons_relationship_id	IN	NUMBER,
  						 p_trx_type_code		IN	VARCHAR2,
  						 p_trx_date_day			IN	NUMBER,
  						 p_trx_date_month		IN	NUMBER,
  						 p_trx_date_year		IN	NUMBER,
  						 p_hidden_flag			IN	VARCHAR2,
  						 p_intermediate_trtmnt_id	IN	NUMBER,
  						 p_intermediate_pct_owned	IN	NUMBER);

  --
  -- Procedure
  --   raise_execute_eng_event()
  -- Purpose
  --   Raised by the Consolidation Monitor UI to submit a consolidation
  -- Arguments
  --	p_consolidation_hierarchy	NUMBER
  -- 	p_consolidation_entity		NUMBER
  --	p_run_identifier		NUMBER
  --	p_cal_period_id			VARCHAR2
  --	p_balance_type_code		VARCHAR2
  --	p_process_method                VARCHAR2

  PROCEDURE	raise_execute_eng_event		(p_consolidation_hierarchy	IN	NUMBER,
  						 p_consolidation_entity		IN	NUMBER,
  						 p_run_identifier		IN	VARCHAR2,
  						 p_cal_period_id		IN	VARCHAR2,
  						 p_balance_type_code		IN	VARCHAR2,
  						 p_process_method		IN	VARCHAR2);

  -- bugfix: 5569522 Added p_analysis_cycle_id
  -- Procedure
  --   raise_execute_eng_event()
  -- Purpose
  --   Raised by the Consolidation Monitor UI to submit a consolidation
  -- Arguments
  --	p_consolidation_hierarchy NUMBER
  -- 	p_consolidation_entity	  NUMBER
  --	p_run_identifier		  NUMBER
  --	p_cal_period_id			  VARCHAR2
  --	p_balance_type_code		  VARCHAR2
  --	p_process_method          VARCHAR2
  --    p_analysis_cycle_id       NUMBER

  PROCEDURE	raise_execute_eng_event		(p_consolidation_hierarchy	IN	NUMBER,
  						 p_consolidation_entity	IN	NUMBER,
  						 p_run_identifier		IN	VARCHAR2,
  						 p_cal_period_id		IN	VARCHAR2,
  						 p_balance_type_code	IN	VARCHAR2,
  						 p_process_method		IN	VARCHAR2,
  						 p_request_id			OUT	NOCOPY NUMBER,
                         p_analysis_cycle_id    IN  NUMBER);


  -- bugfix: 5569522 - Added p_analysis_cycle_id
  -- Procedure
  --   execute_consolidation()
  -- Purpose
  --   Execute Consolidation
  -- Arguments
  --	x_retcode			VARCHAR2
  --    x_errbuf			VARCHAR2
  --    p_consolidation_hierarchy       NUMBER
  --    p_consolidation_entity          NUMBER
  --    p_run_identifier                NUMBER
  --    p_cal_period_id                 VARCHAR2
  --    p_balance_type_code             VARCHAR2
  --    p_process_method                VARCHAR2
  --    p_analysis_cycle_id             NUMBER

  PROCEDURE execute_consolidation (x_retcode  OUT	NOCOPY VARCHAR2,
              					   x_errbuf	  OUT	NOCOPY VARCHAR2,
        						   p_run_identifier 	      IN OUT NOCOPY VARCHAR2,
						           p_consolidation_hierarchy  IN  NUMBER,
                                   p_consolidation_entity     IN  NUMBER,
                                   p_cal_period_id            IN  VARCHAR2,
                                   p_balance_type_code        IN  VARCHAR2,
                                   p_process_method           IN  VARCHAR2,
           						   p_called_via_srs		      IN  VARCHAR2 DEFAULT 'Y',
                                   p_analysis_cycle_id        IN  NUMBER);

END;




/
