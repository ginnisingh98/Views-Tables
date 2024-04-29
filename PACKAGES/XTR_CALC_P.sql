--------------------------------------------------------
--  DDL for Package XTR_CALC_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XTR_CALC_P" AUTHID CURRENT_USER as
/* $Header: xtrcalcs.pls 120.4.12000000.3 2007/10/24 08:24:46 srsampat ship $ */
----------------------------------------------------------------------------------------------------------------
-- Calculate over a Year Basis and Number of Days ased on different calc methods
PROCEDURE CALC_DAYS_RUN_C(start_date IN DATE,
                          end_date   IN DATE,
                          method     IN VARCHAR2,
                          frequency  IN NUMBER,
                          num_days   IN OUT NOCOPY NUMBER,
                          year_basis IN OUT NOCOPY NUMBER,
                          fwd_adjust IN NUMBER DEFAULT NULL,
			  day_count_type IN VARCHAR2 DEFAULT NULL,
			  first_trans_flag IN VARCHAR2 DEFAULT NULL);

PROCEDURE CALC_DAYS_RUN_B(start_date IN DATE,
                          end_date   IN DATE,
                          method     IN VARCHAR2,
                          frequency  IN NUMBER,
                          num_days   IN OUT NOCOPY NUMBER,
                          year_basis IN OUT NOCOPY NUMBER);

PROCEDURE CALC_DAYS_RUN(start_date IN DATE,
                        end_date   IN DATE,
                        method     IN VARCHAR2,
                        num_days   IN OUT NOCOPY NUMBER,
                        year_basis IN OUT NOCOPY NUMBER,
                        fwd_adjust IN NUMBER DEFAULT NULL,
			day_count_type IN VARCHAR2 DEFAULT NULL,
			first_trans_flag IN VARCHAR2 DEFAULT NULL);

PROCEDURE CALCULATE_BOND_PRICE_YIELD(p_bond_issue_code        	IN VARCHAR2,
			             p_settlement_date        	IN DATE,
				     p_ex_cum_next_coupon    	IN VARCHAR2,-- EX,CUM
				     p_calculate_yield_or_price	IN VARCHAR2,-- Y,P
				     p_yield                  	IN OUT NOCOPY NUMBER,
				     p_accrued_interest    	IN OUT NOCOPY NUMBER,
				     p_clean_price            	IN OUT NOCOPY NUMBER,
				     p_dirty_price           	IN OUT NOCOPY NUMBER,
				     p_input_or_calculator	IN VARCHAR2, -- C,I
				     p_commence_date		IN DATE,
				     p_maturity_date		IN DATE,
			             p_prev_coupon_date        	IN DATE,
			             p_next_coupon_date        	IN DATE,
				     p_calc_type		IN VARCHAR2,
				     p_year_calc_type		IN VARCHAR2,
				     p_accrued_int_calc_basis	IN VARCHAR2,
				     p_coupon_freq		IN NUMBER,
                                     p_calc_rounding            IN NUMBER,
                                     p_price_rounding           IN NUMBER,
                                     p_price_round_type         IN VARCHAR2,
				     p_yield_rounding		IN NUMBER,
				     p_yield_round_type         IN VARCHAR2,
				     p_coupon_rate		IN NUMBER,
				     p_num_coupons_remain	IN NUMBER,
                                     p_day_count_type	        IN VARCHAR2 DEFAULT null,
                                     p_first_trans_flag		IN VARCHAR2 DEFAULT null,
				     p_deal_subtype		IN VARCHAR2 DEFAULT null,
				     p_currency          	IN VARCHAR2 DEFAULT null,
				     p_face_value  		IN NUMBER   DEFAULT null,
				     p_consideration	        IN NUMBER   DEFAULT null,
				     p_rounding_type	        IN VARCHAR2 DEFAULT null);

PROCEDURE Calculate_Bond_Coupon_Amounts (
		p_bond_issue_code        	IN VARCHAR2,
		p_next_coupon_date		IN DATE,
		p_settlement_date        	IN DATE,
		p_deal_number			IN NUMBER,
		p_deal_date			IN DATE,
		p_company_code			IN VARCHAR2,
		p_cparty_code			IN VARCHAR2,
		p_dealer_code			IN VARCHAR2,
		p_status_code			IN VARCHAR2,
		p_client_code			IN VARCHAR2,
		p_acceptor_code			IN VARCHAR2,
		p_maturity_account_number	IN VARCHAR2,
		p_maturity_amount		IN NUMBER,
		p_deal_subtype			IN VARCHAR2,
		p_product_type			IN VARCHAR2,
	        p_portfolio_code		IN VARCHAR2,
 	        p_rounding_type                 IN VARCHAR2 DEFAULT NULL,
		p_day_count_type                IN VARCHAR2 DEFAULT NULL,
		p_income_tax_ref		IN VARCHAR2 DEFAULT NULL,
		p_income_tax_rate		IN OUT NOCOPY NUMBER,
		p_income_tax_settled_ref	IN OUT NOCOPY NUMBER);


PROCEDURE RECALC_DT_DETAILS (
                             l_deal_no        		IN NUMBER,
                             l_least_inserted 		IN VARCHAR2,
                             l_ref_date       		IN DATE,
                             l_trans_num      		IN NUMBER,
                             l_last_row       		IN VARCHAR2,
			     g_chk_bal        		IN VARCHAR2,
                             g_expected_balance_bf 	IN OUT NOCOPY NUMBER,
                             g_balance_out_bf		IN OUT NOCOPY NUMBER,
                             g_accum_interest_bf       	IN OUT NOCOPY NUMBER,
                             g_principal_adjust	       	IN OUT NOCOPY NUMBER,
			     c_principal_action		IN VARCHAR2,
			     c_principal_amount_type	IN VARCHAR2,
			     c_principal_adjust		IN NUMBER,
			     c_writoff_int		IN NUMBER,
			     c_increase_effective_from  IN DATE,
			     --Add Interest Override
			     l_rounding_type IN VARCHAR2 DEFAULT null,
			     l_day_count_type IN VARCHAR2 DEFAULT null);

-- bug 5349167
PROCEDURE CALC_DAYS_RUN_IG(start_date IN DATE,
                        end_date   IN DATE,
                        method     IN VARCHAR2,
                        num_days   IN OUT NOCOPY NUMBER,
                        year_basis IN OUT NOCOPY NUMBER,
                        fwd_adjust IN NUMBER DEFAULT NULL,
                        day_count_type IN VARCHAR2 DEFAULT NULL,
                        first_trans_flag IN VARCHAR2 DEFAULT NULL);


end XTR_CALC_P;

 

/
