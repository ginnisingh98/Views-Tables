--------------------------------------------------------
--  DDL for Package QRM_CALCULATORS_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QRM_CALCULATORS_P" AUTHID CURRENT_USER AS
/* $Header: qrmcalcs.pls 115.18 2003/11/22 00:36:17 prafiuly ship $ */


e_no_rate_curve EXCEPTION;
e_no_int_rates EXCEPTION;
e_no_spot_rates EXCEPTION;
e_no_vol_rates EXCEPTION;

--bug 3236479
g_debug_level NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
g_proc_level NUMBER := FND_LOG.LEVEL_PROCEDURE;
g_error_level NUMBER := FND_LOG.LEVEL_ERROR;

/*
NI_CALCULATOR
Cover procedure for the Discounted Securities Calculator
p_indicator = 'C'=to calculate consideration,'M'=to calculate maturity
p_rate_type = 'DR'=discount rate,'Y'=yield rate
*/
PROCEDURE ni_calculator (p_settlement_date DATE,
			 p_maturity_date DATE,
			 p_day_count_basis VARCHAR2,

			 p_indicator VARCHAR2,
			 p_ref_amt NUMBER,
			 p_rate_type VARCHAR2,

			 p_rate NUMBER,
			 p_consideration OUT NOCOPY NUMBER,
			 p_int_amt OUT NOCOPY NUMBER,
			 p_mat_amt OUT NOCOPY NUMBER,
			 p_price OUT NOCOPY NUMBER,
			 p_hold_prd OUT NOCOPY NUMBER,
			 p_adj_hold_prd OUT NOCOPY NUMBER,
			 p_conv_rate OUT NOCOPY NUMBER,
			 p_duration OUT NOCOPY NUMBER,
			 p_mod_dur OUT NOCOPY NUMBER,
			 p_bpv_y OUT NOCOPY NUMBER,
			 p_bpv_d OUT NOCOPY NUMBER,
			 p_dol_dur_y OUT NOCOPY NUMBER,
			 p_dol_dur_d OUT NOCOPY NUMBER,
			 p_convexity OUT NOCOPY NUMBER,
			 p_ccy IN OUT NOCOPY VARCHAR2);

PROCEDURE fx_calculator(p_date_args    IN     SYSTEM.QRM_DATE_TABLE,
			p_varchar_args IN OUT NOCOPY SYSTEM.QRM_VARCHAR_TABLE,
			p_num_args     IN OUT NOCOPY xtr_md_num_table);


FUNCTION get_curves_from_base 	  (p_curve_types SYSTEM.QRM_VARCHAR_TABLE,
				   p_base_currencies SYSTEM.QRM_VARCHAR_TABLE,
				   p_contra_currencies SYSTEM.QRM_VARCHAR_TABLE)
	RETURN SYSTEM.QRM_VARCHAR_TABLE;


FUNCTION get_rates_from_curves 	(p_rate_types SYSTEM.QRM_VARCHAR_TABLE,
				 p_curve_codes SYSTEM.QRM_VARCHAR_TABLE,
				 p_base_currencies SYSTEM.QRM_VARCHAR_TABLE,
				 p_contra_currencies SYSTEM.QRM_VARCHAR_TABLE,
				 p_quote_bases SYSTEM.QRM_VARCHAR_TABLE,
				 p_interp_methods SYSTEM.QRM_VARCHAR_TABLE,
				 p_data_sides SYSTEM.QRM_VARCHAR_TABLE,
				 p_day_count_bases SYSTEM.QRM_VARCHAR_TABLE,
				 p_interest_quote_basis VARCHAR2,
			         p_currency_quote_basis VARCHAR2,
				 p_spot_date DATE,
				 p_future_date DATE)
	RETURN xtr_md_num_table;


FUNCTION get_rates_from_base  	  (p_rate_types SYSTEM.QRM_VARCHAR_TABLE,
				   p_base_currencies SYSTEM.QRM_VARCHAR_TABLE,
				   p_contra_currencies SYSTEM.QRM_VARCHAR_TABLE,
				   p_quote_bases  SYSTEM.QRM_VARCHAR_TABLE,
				   p_interp_methods SYSTEM.QRM_VARCHAR_TABLE,
				   p_data_sides SYSTEM.QRM_VARCHAR_TABLE,
				   p_day_count_bases SYSTEM.QRM_VARCHAR_TABLE,
				   p_interest_quote_basis VARCHAR2,
				   p_currency_quote_basis VARCHAR2,
			    	   p_spot_date DATE,
				   p_future_date DATE)
	RETURN xtr_md_num_table;


FUNCTION get_spot_quotation_basis(p_base_currency IN VARCHAR2,
                                  p_contra_currency IN VARCHAR2,
                                  p_overwrite_sys IN BOOLEAN)
        RETURN SYSTEM.QRM_VARCHAR_TABLE;



--added by sankim 10/2/01
PROCEDURE fra_pricing(p_indicator IN VARCHAR2,
		      p_settlement_date IN DATE,
                      p_maturity_date IN DATE,
                      p_day_count_basis IN VARCHAR2,
                      p_spot_date IN DATE,
                      p_rate_curve IN OUT NOCOPY VARCHAR2,
                      p_quote_basis IN VARCHAR2,
                      p_interpolation IN VARCHAR2,
                      p_ss_bid IN OUT NOCOPY NUMBER,
                      p_ss_ask IN OUT NOCOPY NUMBER,
                      p_sm_bid IN OUT NOCOPY NUMBER,
                      p_sm_ask IN OUT NOCOPY NUMBER,
                      p_holding_period OUT NOCOPY NUMBER,
                      p_adjusted_holding_period OUT NOCOPY NUMBER,
	              p_contract_rate_bid OUT NOCOPY NUMBER,
		      p_contract_rate_ask OUT NOCOPY NUMBER);

--added by sankim 10/16/01
PROCEDURE fra_settlement(p_indicator IN VARCHAR2,
			 p_settlement_date IN DATE,
                         p_maturity_date IN DATE,
                         p_face_value IN NUMBER,
			 p_currency IN OUT NOCOPY VARCHAR2,
			 p_contract_rate IN OUT NOCOPY NUMBER,
			 p_day_count_basis IN VARCHAR2,
			 p_deal_subtype IN VARCHAR2,
			 p_calculation_method IN VARCHAR2,
                         p_rate_curve IN OUT NOCOPY VARCHAR2,
                         p_quote_basis IN VARCHAR2,
                         p_interpolation IN VARCHAR2,
                         p_settlement_rate IN OUT NOCOPY NUMBER,
                         p_holding_period OUT NOCOPY NUMBER,
                         p_adjusted_holding_period OUT NOCOPY NUMBER,
			 p_action OUT NOCOPY VARCHAR2,
			 p_settlement_amount OUT NOCOPY NUMBER,
			 p_duration OUT NOCOPY NUMBER,
			 p_convexity OUT NOCOPY NUMBER,
			 p_basis_point_value OUT NOCOPY NUMBER);

--added by jbrodsky 11/02/01
PROCEDURE fxo_calculator(p_date_args    IN     SYSTEM.QRM_DATE_TABLE,
			p_varchar_args IN OUT NOCOPY SYSTEM.QRM_VARCHAR_TABLE,
			p_num_args     IN OUT NOCOPY xtr_md_num_table);


END QRM_CALCULATORS_P;

 

/
