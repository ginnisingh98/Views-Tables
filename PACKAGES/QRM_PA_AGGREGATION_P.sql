--------------------------------------------------------
--  DDL for Package QRM_PA_AGGREGATION_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QRM_PA_AGGREGATION_P" AUTHID CURRENT_USER AS
/* $Header: qrmpaggs.pls 115.19 2003/11/22 00:36:15 prafiuly ship $ */

e_pagg_no_fxrate_found EXCEPTION;
e_pagg_no_timebuckets_found EXCEPTION;
e_pagg_update_total_fail EXCEPTION;
e_pagg_update_percent_fail EXCEPTION;
e_pagg_update_label_fail EXCEPTION;
e_pagg_update_agg_curr_fail EXCEPTION;
e_pagg_no_setting_found EXCEPTION;
e_pagg_update_tb_label_fail EXCEPTION;

--bug 3236479
g_debug_level NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
g_proc_level NUMBER := FND_LOG.LEVEL_PROCEDURE;
g_event_level NUMBER := FND_LOG.LEVEL_EVENT;
g_state_level NUMBER := FND_LOG.LEVEL_STATEMENT;
g_exception_level NUMBER := FND_LOG.LEVEL_EXCEPTION;
G_ERROR_LEVEL NUMBER :=FND_LOG.LEVEL_EXCEPTION;

FUNCTION transform_and_save (p_name VARCHAR2,
				p_ref_date DATE,
				p_caller_flag VARCHAR2)
				--'OA' if called from OA
				--'CONC' if called from Concurrent Program
	RETURN VARCHAR2; --'T' for success or 'F' for unsuccessful


FUNCTION calculate_relative_date(p_ref_date DATE,
				p_date_type VARCHAR2,
				p_as_of_date DATE,
				p_start_date_ref VARCHAR2,
				p_start_date_offset NUMBER,
				p_start_offset_type VARCHAR2,
				p_calendar_id NUMBER,
				p_business_week VARCHAR2)
	RETURN DATE;


PROCEDURE update_timebuckets (p_name VARCHAR2,
			p_ref_date DATE,
			p_tb_name VARCHAR2,
			p_tb_label VARCHAR2,
			p_as_of_date DATE,
                        p_start_date_ref VARCHAR2,
                        p_start_date_offset NUMBER,
			p_start_offset_type VARCHAR2,
			p_row_agg_no NUMBER,
			p_max_col_no OUT NOCOPY NUMBER,
                        p_date_type VARCHAR2,
                        p_calendar_id NUMBER,
                        p_business_week VARCHAR2,
			p_col_seq_no IN OUT NOCOPY XTR_MD_NUM_TABLE,
			p_col_seq_no_key IN OUT NOCOPY SYSTEM.QRM_VARCHAR_TABLE,
			p_col_name_map IN OUT NOCOPY SYSTEM.QRM_VARCHAR_TABLE,
			p_percent_col_name_map IN OUT NOCOPY SYSTEM.QRM_VARCHAR_TABLE,
			p_a1 IN OUT NOCOPY SYSTEM.QRM_VARCHAR_TABLE,
			p_col_type IN OUT NOCOPY XTR_MD_NUM_TABLE,
			p_col_hidden IN OUT NOCOPY SYSTEM.QRM_VARCHAR_TABLE,
  			p_start_date IN OUT NOCOPY SYSTEM.QRM_DATE_TABLE,
  			p_end_date IN OUT NOCOPY SYSTEM.QRM_DATE_TABLE,
			p_tb_label_arr IN OUT NOCOPY SYSTEM.QRM_VARCHAR_TABLE);


FUNCTION update_total (p_name VARCHAR2,
			p_ref_date DATE)
	RETURN BOOLEAN;


FUNCTION update_percent (p_name VARCHAR2,
			p_ref_date DATE)
	RETURN BOOLEAN;


FUNCTION update_percent (p_name VARCHAR2,
                        p_style VARCHAR2,
                        p_row_agg_no NUMBER,
                        p_max_col_no NUMBER,
			p_ref_date DATE,
			p_md_set_code VARCHAR2)
	RETURN BOOLEAN;


FUNCTION update_label(p_name VARCHAR2,
			p_agg IN OUT NOCOPY SYSTEM.QRM_VARCHAR240_TABLE,
			p_col_order IN OUT NOCOPY XTR_MD_NUM_TABLE,
			p_att_type IN OUT NOCOPY SYSTEM.QRM_VARCHAR_TABLE,
			p_ref_date DATE)
	RETURN BOOLEAN;


PROCEDURE calc_table_total_and_fxrate(p_name VARCHAR2,
				p_calc_total_ind VARCHAR2,--'Y'es or 'N'o
				p_curr_reporting VARCHAR2,
				p_currency_source VARCHAR2,
				p_last_run_date DATE,
				p_md_set_code VARCHAR2,
				p_dirty VARCHAR2,
				p_end_date_fix DATE,
				p_tot_avg SYSTEM.QRM_VARCHAR_TABLE,
				p_ccy_multiplier OUT NOCOPY NUMBER,
				p_att_name IN OUT NOCOPY SYSTEM.QRM_VARCHAR240_TABLE,
				p_total OUT NOCOPY XTR_MD_NUM_TABLE,
				p_table_col_curr OUT NOCOPY SYSTEM.QRM_VARCHAR_TABLE,
				p_sensitivity SYSTEM.QRM_VARCHAR_TABLE,
				p_analysis_type VARCHAR2,
				p_business_week VARCHAR2,
				p_amount SYSTEM.QRM_VARCHAR_TABLE);--17


FUNCTION update_aggregate_curr(p_name VARCHAR2,
			p_ref_date DATE,
                        p_ccy_case_flag NUMBER,
                        p_ccy_agg_flag NUMBER,
                        p_ccy_agg_level NUMBER,
                        p_row_agg_no NUMBER,
                        p_max_col_no NUMBER,
                        p_underlying_ccy VARCHAR2,
                        p_currency_source VARCHAR2,
                        p_curr_reporting VARCHAR2,
                        p_agg_col_curr IN OUT NOCOPY SYSTEM.QRM_VARCHAR_TABLE)
	RETURN BOOLEAN;

FUNCTION update_timebuckets_label(p_name VARCHAR2)
	RETURN BOOLEAN;

FUNCTION update_semidirty(p_name VARCHAR2, p_ref_date DATE)
	RETURN VARCHAR2;

FUNCTION get_fx_rate(p_md_set_code VARCHAR2,
			p_spot_date DATE,
			p_base_ccy VARCHAR2,
			p_contra_ccy VARCHAR2,
			p_side VARCHAR2)
	RETURN NUMBER;

PROCEDURE calc_tb_start_end_dates (p_name VARCHAR2,
                        p_ref_date DATE,
                        p_tb_name VARCHAR2,
                        p_tb_label VARCHAR2,
                        p_end_date IN OUT NOCOPY DATE,
                        p_end_date_ref IN OUT NOCOPY VARCHAR2,
                        p_end_date_offset IN OUT NOCOPY NUMBER,
                        p_end_offset_type IN OUT NOCOPY VARCHAR2,
                        p_date_type VARCHAR2,
                        p_calendar_id NUMBER,
                        p_business_week VARCHAR2,
			p_start_date IN OUT NOCOPY DATE,
                        p_start_date_ref IN OUT NOCOPY VARCHAR2,
                        p_start_date_offset IN OUT NOCOPY NUMBER,
                        p_start_offset_type IN OUT NOCOPY VARCHAR2,
			p_analysis_type VARCHAR2);

--FUNCTION translate_to_usd (p_name VARCHAR2,
--			p_ref_date DATE,
--			p_md_set_code VARCHAR2)
--	RETURN BOOLEAN;


END QRM_PA_AGGREGATION_P;

 

/
