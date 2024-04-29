--------------------------------------------------------
--  DDL for Package XTR_FPS2_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XTR_FPS2_P" AUTHID CURRENT_USER as
/* $Header: xtrfps2s.pls 120.5 2005/09/15 04:37:26 badiredd ship $ */
-----------------------------------------------------------------------------------------------------
PROCEDURE CALC_CROSS_RATE(quoted_1st IN varchar2,
                                                       start_date IN date);
PROCEDURE CALC_REVALS ( p_start_date     IN date,
                        p_end_date       IN date,
                        p_sysdate        IN date,
                        p_user           IN varchar2,
                        p_company_code   IN varchar2,
                        p_deal_type      IN varchar2,
                        p_deal_subtype   IN varchar2,
                        p_product_type   IN varchar2,
                        p_portfolio_code IN varchar2);
PROCEDURE CALCULATE_FRA_PRICE (t            IN NUMBER,
                               T1           IN NUMBER,
                               Rt           IN NUMBER,
                               Rt1          IN NUMBER,
                               l_year_basis IN NUMBER,
                               fra_rate     IN OUT NOCOPY NUMBER);
PROCEDURE DEAL_EXISTS (l_date    IN DATE,
                              l_company IN VARCHAR2,
                              l_d_type  IN VARCHAR2,
                              l_d_subty IN VARCHAR2,
                              l_dealer  IN VARCHAR2,
                              l_exists  IN OUT NOCOPY VARCHAR2);
PROCEDURE DEFAULTS (l_comp      IN OUT NOCOPY VARCHAR2,
                    l_comp_name IN OUT NOCOPY VARCHAR2,
                    l_ccy       IN OUT NOCOPY VARCHAR2,
                    l_ccy_name  IN OUT NOCOPY VARCHAR2,
                    l_port      IN OUT NOCOPY VARCHAR2);
/* Bug 1708946
PROCEDURE DEFAULT_CCY (l_pty      IN VARCHAR2,
                       l_ccy      IN OUT NOCOPY VARCHAR2,
                       l_ccy_name IN OUT NOCOPY VARCHAR2);
*/
PROCEDURE DEFAULT_COMP_ACCT (l_company  IN VARCHAR2,
                             l_currency IN VARCHAR2,
                             l_acct_nos IN OUT NOCOPY VARCHAR2);
PROCEDURE DEFAULT_SPOT_DATE (l_sysdate IN DATE,
                             l_ccy1    IN VARCHAR2,
                             l_ccy2    IN VARCHAR2,
                             out_date  IN OUT NOCOPY DATE);
PROCEDURE DISCOUNT_INTEREST_CALC(days_in_year IN NUMBER,
                                 amount       IN NUMBER,
                                 rate         IN NUMBER,
                                 no_of_days   IN NUMBER,
                                 round_factor IN NUMBER,
                                 interest     IN OUT NOCOPY NUMBER,
                                 rounding_type IN VARCHAR2 default NULL);
PROCEDURE EXTRAPOLATE_FROM_YIELD_CURVE(l_ccy         IN CHAR,
                           l_days        IN NUMBER,
                           l_yield_curve IN VARCHAR2,
                           l_rate  IN OUT NOCOPY NUMBER);
PROCEDURE EXTRAPOLATE_FROM_MARKET_PRICES(l_ccy         IN CHAR,
                           l_days        IN NUMBER,
                           l_rate  IN OUT NOCOPY NUMBER);
PROCEDURE EXTRAPOLATE_RATE(l_company     IN VARCHAR2,
                           l_period_from IN DATE,
                           l_period_to   IN DATE,
                           l_ccy         IN VARCHAR2,
                           l_days        IN NUMBER,
                           l_reval_rate  IN OUT NOCOPY NUMBER);
PROCEDURE INTEREST_CALCULATOR (days_in_year IN NUMBER,
                               amount       IN NUMBER,
                               rate         IN NUMBER,
                               no_of_days   IN NUMBER,
                               round_factor IN NUMBER,
                               interest     IN OUT NOCOPY NUMBER,
			       round_type   IN VARCHAR2 DEFAULT NULL);
PROCEDURE SET_DEFAULTS (l_company_code IN OUT NOCOPY VARCHAR2,
                        l_company_name IN OUT NOCOPY VARCHAR2);
PROCEDURE SET_DEFAULTS_PDA (l_company_code   IN VARCHAR2,
                            l_portfolio_code IN OUT NOCOPY VARCHAR2,
                            l_portfolio_name IN OUT NOCOPY VARCHAR2);
PROCEDURE DEFAULT_PORTFOLIO (l_company_code IN VARCHAR2,
                             l_portfolio_code IN OUT NOCOPY VARCHAR2);
PROCEDURE STANDING_SETTLEMENTS (l_party       IN VARCHAR2,
                                l_ccy         IN VARCHAR2,
                                l_deal_type   IN VARCHAR2,
                                l_subtype     IN VARCHAR2,
                                l_product     IN VARCHAR2,
                                l_amount_type IN VARCHAR2,
                                l_cparty_ref  IN OUT NOCOPY VARCHAR2,
                                l_account     IN OUT NOCOPY VARCHAR2);


PROCEDURE TAX_BROKERAGE_DEFAULTS(l_deal_type       IN VARCHAR2,
                                 l_subtype         IN VARCHAR2,
                                 l_product         IN VARCHAR2,
                                 l_ref_party       IN VARCHAR2,
                                 l_prin_settled_by IN OUT NOCOPY VARCHAR2,
                                 l_bkr_ref         IN OUT NOCOPY VARCHAR2,
                                 l_tax_ref         IN OUT NOCOPY VARCHAR2,
                                 l_int_settled_by  IN OUT NOCOPY VARCHAR2,
                                 l_int_freq        IN OUT NOCOPY VARCHAR2,
                                 l_bkr_amt_type    IN OUT NOCOPY VARCHAR2,
                                 l_tax_amt_type    IN OUT NOCOPY VARCHAR2);

PROCEDURE TAX_BROKERAGE_DEFAULTING(l_deal_type       IN VARCHAR2,
                                 l_subtype         IN VARCHAR2,
                                 l_product         IN VARCHAR2,
                                 l_ref_party       IN VARCHAR2,
                                 l_prin_settled_by IN OUT NOCOPY VARCHAR2,
                                 l_bkr_ref         IN OUT NOCOPY VARCHAR2,
                                 l_prin_tax_ref    IN OUT NOCOPY VARCHAR2,
				 l_income_tax_ref  IN OUT NOCOPY VARCHAR2,
				 -- for FX deals, inputted as buy ccy
				 -- outputted as tax ccy
				 l_ccy	   	   IN OUT NOCOPY VARCHAR2,
				 l_sell_ccy	   IN VARCHAR2 DEFAULT NULL,
                                 l_int_settled_by  IN OUT NOCOPY VARCHAR2,
                                 l_int_freq        IN OUT NOCOPY VARCHAR2,
                                 l_bkr_amt_type    IN OUT NOCOPY VARCHAR2);


PROCEDURE TAX_BROKERAGE_AMT_TYPE(l_deal_type       IN VARCHAR2,
                                 l_bkr_ref         IN VARCHAR2,
                                 l_tax_ref         IN VARCHAR2,
                                 l_bkr_amt_type    IN OUT NOCOPY VARCHAR2,
                                 l_tax_amt_type    IN OUT NOCOPY VARCHAR2);
PROCEDURE UPDATE_JOURNALS (l_deal_nos  IN NUMBER,
                           l_trans_nos IN NUMBER,
                           l_deal_type IN VARCHAR2);

PROCEDURE PRESENT_VALUE_CALC(days_in_year IN NUMBER,
                             amount       IN NUMBER,
                             rate         IN NUMBER,
                             no_of_days   IN NUMBER,
                             round_factor IN NUMBER,
                           present_value  IN OUT NOCOPY NUMBER);

PROCEDURE PRESENT_VALUE_COMPOUND(days_in_year IN NUMBER,
                             amount       IN NUMBER,
                             rate         IN NUMBER,
                             no_of_days   IN NUMBER,
                             round_factor IN NUMBER,
                           present_value  IN OUT NOCOPY NUMBER);

PROCEDURE RESET_FLOATING_RATES(errbuf           OUT NOCOPY VARCHAR2,
                               retcode          OUT NOCOPY NUMBER,
			       p_rateset_from 	    IN VARCHAR2,
			       p_rateset_to	        IN VARCHAR2,
			       p_rateset_adj	IN NUMBER,
			       p_deal_type	IN VARCHAR2,
			       p_company	IN VARCHAR2,
			       p_cparty		IN VARCHAR2,
			       p_portfolio	IN VARCHAR2,
			       p_currency	IN VARCHAR2,
		 	       p_ric_code	IN VARCHAR2,
			       p_source		IN VARCHAR2);

PROCEDURE VALIDATE_TRANSACTION(p_company	IN VARCHAR2,
			       p_deal_no	IN NUMBER,
			       p_deal_type	IN VARCHAR2,
			       p_start_date	IN DATE,
			       p_valid_ok	OUT NOCOPY BOOLEAN,
			       p_error		OUT NOCOPY NUMBER);

PROCEDURE GET_BENCHMARK_RATE(p_ric_code		IN VARCHAR2,
			     p_rate_date	IN DATE,
			     p_rateset_adj	IN NUMBER,
			     p_rate		OUT NOCOPY NUMBER);

PROCEDURE UPDATE_RATE_ONE_TRANSACTION(p_deal_no	IN NUMBER,
				  p_trans_no	IN NUMBER,
				  p_deal_type	IN VARCHAR2,
			          p_start_date  IN DATE,
				  p_new_rate    IN NUMBER);

PROCEDURE UPDATE_RATE_SEQ_TRANSACTION(p_deal_no IN NUMBER,
                                  p_trans_no    IN NUMBER,
                                  p_deal_type   IN VARCHAR2,
                                  p_start_date  IN DATE,
				      p_new_rate    IN NUMBER);
FUNCTION ROUNDUP(p_amount NUMBER,
		 p_round_factor NUMBER) RETURN NUMBER;
FUNCTION INTEREST_ROUND
                (p_amount NUMBER,
		 p_round_factor NUMBER,
		 p_rounding_type VARCHAR2 DEFAULT NULL
		) RETURN NUMBER;

PROCEDURE CURRENCY_CROSS_RATE (p_currency_from IN VARCHAR2,
			       p_currency_to   IN VARCHAR2,
			       p_rate          OUT NOCOPY NUMBER);

TYPE one_step_rec_type is record  (p_source Varchar2(20) DEFAULT 'TAX',
                                   p_schedule_code  Xtr_Tax_Brokerage_Setup.Reference_Code%Type,
                                   p_currency Xtr_Deals.Currency%Type,
                                   p_amount Number,
                                   p_settlement_date Date,
                                   p_settlement_account  Xtr_Deals.settle_account_no%type,
                                   p_company_code  Xtr_Deals.Company_Code%type,
                                   p_cparty_code  Xtr_Deals.Cparty_Code%type,
                                   p_cparty_account_no  Xtr_Deals.Cparty_Account_No%type,
                                   p_error  Varchar2(40),
                                   p_settle_method  Xtr_tax_brokerage_setup.tax_settle_method%type,
                                   p_exp_number  Xtr_Exposure_Transactions.Transaction_Number%Type
                                   );

Procedure One_Step_Settlement(p_one_step_rec IN OUT NOCOPY one_step_rec_type);

  PROCEDURE GET_SETTLE_METHOD (p_prncpl_tax     IN VARCHAR2,
                               p_prncpl_ctype   OUT NOCOPY VARCHAR2,
                               p_prncpl_method  OUT NOCOPY VARCHAR2,
                               p_income_tax     IN VARCHAR2,
                               p_income_ctype   OUT NOCOPY VARCHAR2,
                               p_income_method  OUT NOCOPY VARCHAR2);


  PROCEDURE CALC_TMM_TAX (p_prncpl_ctype  IN VARCHAR2,
                          p_prncpl_method IN VARCHAR2,
                          p_income_ctype  IN VARCHAR2,
                          p_income_method IN VARCHAR2,
                          p_settle_acct   IN VARCHAR2,
                          p_last_tran     IN VARCHAR2,
                          p_RT            IN OUT NOCOPY  XTR_ROLLOVER_TRANSACTIONS_V%ROWTYPE);

  PROCEDURE CALC_TMM_ONE_STEP (p_tax_type      IN VARCHAR2,
                               p_deal_no       IN NUMBER,
                               p_tran_no       IN NUMBER,
                               p_amt_hce       IN NUMBER,
                               p_prncpl_ref    IN NUMBER,
                               p_prncpl_method IN VARCHAR2,
                               p_income_ref    IN NUMBER,
                               p_income_method IN VARCHAR2,
                               p_one_step      IN OUT NOCOPY ONE_STEP_REC_TYPE);


PROCEDURE DELETE_TAX_EXPOSURE(p_deal_no     IN NUMBER,
                         p_trans_no    IN NUMBER default null);

PROCEDURE DELETE_TAX_EXP_AND_UPDATE(p_tax_settle_no IN NUMBER);

--Bug 2804548
PROCEDURE UPDATE_TAX_EXP (p_exp_number NUMBER,
			p_amount NUMBER);

--Bug 2804548
PROCEDURE UPDATE_TAX_DDA (p_exp_number NUMBER,
			p_amount NUMBER);

----------------------------------------------------------------------------------------
end XTR_FPS2_P;

 

/
