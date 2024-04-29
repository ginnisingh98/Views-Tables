--------------------------------------------------------
--  DDL for Package XTR_FPS1_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XTR_FPS1_P" AUTHID CURRENT_USER as
/* $Header: xtrfps1s.pls 120.1 2005/06/29 07:20:41 badiredd ship $ */
----------------------------------------------------------------------------------------------------------------
PROCEDURE ADVICE_LETTERS (l_deal_type  IN VARCHAR2,
                                            l_product    IN VARCHAR2,
                                            l_cparty     IN VARCHAR2,
                                            l_client     IN VARCHAR2,
                                            l_cparty_adv IN OUT NOCOPY VARCHAR2,
                                            l_client_adv IN OUT NOCOPY VARCHAR2);
PROCEDURE CAL_BOND_PRICE (num_full_cpn_remain      IN NUMBER,
                                 annual_yield             IN NUMBER,
                                 days_settle_to_nxt_cpn   IN NUMBER,
                                 days_last_cpn_to_nxt_cpn IN NUMBER,
                                 annual_cpn               IN NUMBER,
                                 l_vol_chg_ann_yield      IN NUMBER,
                                 cum_price                IN OUT NOCOPY NUMBER,
                                 ex_price                 IN OUT NOCOPY NUMBER,
                                 vol_price                IN OUT NOCOPY NUMBER);
PROCEDURE CALC_OPTION_PRICE (l_expiry      IN DATE,
                             l_volatility  IN NUMBER,
                             l_counter_ccy IN CHAR,
                             l_market_rate IN NUMBER,
                             l_strike_rate IN NUMBER,
                             l_spot_rate   IN NUMBER,
                             l_subtype     IN CHAR,
                             l_int_rate    IN NUMBER,
                             l_ref_amount  IN NUMBER,
                             l_put_call    IN CHAR,
                             l_reval_amt   IN OUT NOCOPY NUMBER,
                             l_end_date    IN DATE);

PROCEDURE CALC_TAX_BROKERAGE(l_deal_type    IN VARCHAR2,
                             l_deal_date    IN DATE,
                             l_tax_ref      IN VARCHAR2,
                             l_bkge_ref     IN VARCHAR2,
			     l_ccy	    IN VARCHAR2,
                             l_yr_basis     IN NUMBER,
                             l_num_days     IN NUMBER,
                             l_tax_amt_type IN VARCHAR2,
                             l_tax_amt      IN NUMBER,
                             l_tax_rate     IN OUT NOCOPY NUMBER,
                             l_bkr_amt_type IN VARCHAR2,
                             l_bkr_amt      IN NUMBER,
                             l_bkr_rate     IN OUT NOCOPY NUMBER,
                             l_tax_out      IN OUT NOCOPY NUMBER,
                             l_tax_out_hce  IN OUT NOCOPY NUMBER,
                             l_bkge_out     IN OUT NOCOPY NUMBER,
                             l_bkge_out_hce IN OUT NOCOPY NUMBER,
                             l_err_code        OUT NOCOPY NUMBER,
                             l_level           OUT NOCOPY VARCHAR2);

PROCEDURE CALC_TAX_AMOUNT (l_deal_type IN VARCHAR2,
			   l_deal_date IN DATE,
			   l_prin_tax_ref   IN VARCHAR2,
			   l_income_tax_ref IN VARCHAR2,
  			   l_ccy_buy   IN VARCHAR2, -- ccy for MM deals
			   l_ccy_sell  IN VARCHAR2 DEFAULT NULL,
			   l_year_basis  IN NUMBER,
			   l_num_days    IN NUMBER,
			   l_prin_tax_amount    IN NUMBER,
			   l_prin_tax_rate	IN OUT	NOCOPY NUMBER,
			   l_income_tax_amount  IN NUMBER,
			   l_income_tax_rate    IN OUT NOCOPY 	NUMBER,
			   l_prin_tax_out	IN OUT NOCOPY  NUMBER,
			   l_income_tax_out     IN OUT NOCOPY  NUMBER,
			   l_err_code		   OUT NOCOPY  NUMBER,
			   l_level		   OUT NOCOPY  VARCHAR2);

FUNCTION GET_TAX_SETTLE_METHOD (l_tax_ref VARCHAR2) RETURN VARCHAR2;


FUNCTION GET_TAX_ROUND_FACTOR(l_rounding_precision VARCHAR2,
			      l_ccy VARCHAR2) RETURN NUMBER;


PROCEDURE CHK_CCY_CODE (l_currency    IN VARCHAR2,
                        l_ccy_name    IN OUT NOCOPY VARCHAR2,
                        l_yr_basis    IN OUT NOCOPY NUMBER,
                        l_round       IN OUT NOCOPY NUMBER,
                        l_err_code         OUT NOCOPY NUMBER,
                        l_level                OUT NOCOPY VARCHAR2);
PROCEDURE CHK_CLIENT_CODE (l_client_code IN VARCHAR2,
                           l_client_name IN OUT NOCOPY VARCHAR2,
                           l_query       IN VARCHAR2,
                           l_err_code         OUT NOCOPY NUMBER,
                           l_level                OUT NOCOPY VARCHAR2);
PROCEDURE CHK_COMPANY_CODE (l_company_code IN VARCHAR2,
                            l_company_name IN OUT NOCOPY VARCHAR2,
                            l_query       IN VARCHAR2,
                            l_err_code         OUT NOCOPY NUMBER,
                            l_level                OUT NOCOPY VARCHAR2);
PROCEDURE CHK_CPARTY_ACCOUNT (l_cparty_code    IN VARCHAR2,
                              l_cparty_ref     IN VARCHAR2,
                              l_currency       IN VARCHAR2,
                              l_cparty_account IN OUT NOCOPY VARCHAR2,
                              l_err_code         OUT NOCOPY NUMBER,
                              l_level                OUT NOCOPY VARCHAR2);
PROCEDURE CHK_CPARTY_CODE (l_cparty_code IN VARCHAR2,
                           l_cparty_name IN OUT NOCOPY VARCHAR2,
                           l_query       IN VARCHAR2,
                           l_err_code         OUT NOCOPY NUMBER,
                           l_level                OUT NOCOPY VARCHAR2);
PROCEDURE CHK_CPARTY_LIMIT (l_cparty_code  IN VARCHAR2,
                            l_company_code IN VARCHAR2,
                            l_limit_code   IN VARCHAR2,
                            l_err_code         OUT NOCOPY NUMBER,
                            l_level                OUT NOCOPY VARCHAR2);
PROCEDURE CHK_DEALER_CODE (l_dealer_code IN VARCHAR2,
                                                        l_err_code         OUT NOCOPY NUMBER,
                                                        l_level                OUT NOCOPY VARCHAR2);
PROCEDURE CHK_DEAL_STATUS (l_deal_number IN NUMBER,
                                                       l_err_code         OUT NOCOPY NUMBER,
                                                       l_level                OUT NOCOPY VARCHAR2);
----------------------------------------------------------------------------------------------------------------
end XTR_FPS1_P;

 

/
