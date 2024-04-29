--------------------------------------------------------
--  DDL for Package QRM_PA_CALCULATION_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QRM_PA_CALCULATION_P" AUTHID CURRENT_USER AS
/* $Header: qrmpacas.pls 115.11 2003/11/22 00:36:13 prafiuly ship $ */

e_no_setting_found EXCEPTION;
e_analysis_in_progress EXCEPTION;
e_invalid_date EXCEPTION;

--bug 3236479
g_debug_level NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
g_proc_level NUMBER := FND_LOG.LEVEL_PROCEDURE;
g_event_level NUMBER := FND_LOG.LEVEL_EVENT;
g_state_level NUMBER := FND_LOG.LEVEL_STATEMENT;
g_error_level NUMBER := FND_LOG.LEVEL_ERROR;

PROCEDURE run_analysis_cp (errbuf		OUT NOCOPY	VARCHAR2,
			   retcode		OUT NOCOPY	VARCHAR2,
			   p_source		IN	VARCHAR2,
			   p_analysis_name	IN	VARCHAR2,
			   p_date		IN	VARCHAR2);


PROCEDURE run_analysis_am (p_analysis_names IN	SYSTEM.QRM_VARCHAR_TABLE,
			   p_ref_datetime   IN	DATE DEFAULT SYSDATE);


PROCEDURE run_analysis (retcode		OUT NOCOPY	VARCHAR2,
			p_source	IN	VARCHAR2,
			p_analysis_name IN	VARCHAR2,
			p_ref_datetime	IN	DATE DEFAULT SYSDATE);


PROCEDURE remove_expired_deals(p_ref_date DATE DEFAULT SYSDATE);



FUNCTION get_threshold_date (p_ref_datetime DATE,
		   p_threshold_num NUMBER,
		   p_threshold_type VARCHAR2)
	RETURN DATE;

FUNCTION get_gap_date 	(p_deal_no		IN	NUMBER,
			 p_deal_type		IN	VARCHAR2,
			 p_initial_basis	IN	VARCHAR2,
			 p_ref_date		IN	DATE)
	RETURN DATE;

FUNCTION get_signed_amount  (p_amount	NUMBER,
			     p_deal_type VARCHAR2,
			     p_deal_subtype VARCHAR2,
			     p_action VARCHAR2)
	RETURN NUMBER;

PROCEDURE convert_amounts(p_mds		IN	VARCHAR2,
			  p_ref_date	IN	DATE,
			  p_from_ccy	IN	VARCHAR2,
			  p_to_ccy	IN	VARCHAR2,
			  p_from_amount	IN	NUMBER,
			  p_to_amount	OUT NOCOPY	NUMBER);


FUNCTION filter_measure(p_style VARCHAR2,
			p_analysis_name VARCHAR2,
			p_market_type_table_alias VARCHAR2)
	RETURN VARCHAR2;



END QRM_PA_CALCULATION_P;

 

/
