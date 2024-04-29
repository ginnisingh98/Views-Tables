--------------------------------------------------------
--  DDL for Package XTR_EXP_SUMM_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XTR_EXP_SUMM_P" AUTHID CURRENT_USER as
/* $Header: xtrexpos.pls 120.1 2005/06/29 06:29:38 badiredd ship $ */
----------------------------------------------------------------------------------------------------------------
PROCEDURE CALC_HEDGE_DETAILS
                      (ref_number     IN NUMBER,
                       sel_ccy           IN VARCHAR2,
                       l_base_ccy      IN VARCHAR2,
                       l_company       IN VARCHAR2,
                       incl_options      IN VARCHAR2,
                       incl_indic_exp   IN VARCHAR2,
                       l_portfolio          IN VARCHAR2,
                       perspective       IN VARCHAR2,
                       l_yield_curve     IN VARCHAR2,
                       l_year_basis     IN NUMBER,
                       l_dflt_disc_rate  IN NUMBER,
                       l_rounding         IN NUMBER,
                       l_wk_mth      IN VARCHAR2);
------------------------------------------------------------------------------------------------
PROCEDURE CALC_TRADING_DETAILS
                      (ref_number     IN NUMBER,
                       l_ccy_a         IN VARCHAR2,
                       l_ccy_b         IN VARCHAR2,
                       l_company      IN VARCHAR2,
                       incl_options   IN VARCHAR2,
                       l_portfolio    IN VARCHAR2,
                       perspective    IN VARCHAR2,
                       l_year_basis   IN NUMBER,
                       l_rounding     IN NUMBER);
------------------------------------------------------------------------------------------------
PROCEDURE CALC_FX_FWD_RATE
                     (l_ccya         IN VARCHAR2,
                      l_ccyb         IN VARCHAR2,
                      l_company_code IN VARCHAR2,
                      l_yr_basis     IN NUMBER,
                      l_end_date     IN DATE,
                      l_base_ccy     IN VARCHAR2,
                      l_answer       IN OUT NOCOPY NUMBER);
------------------------------------------------------------------------------------------------
PROCEDURE CALC_ALL_CCY_EXPOSURES
                      (ref_number     IN NUMBER,
                       p_sel_ccy        IN VARCHAR2,
                       l_base_ccy      IN VARCHAR2,
                       l_company       IN VARCHAR2,
                       incl_options      IN VARCHAR2,
                       incl_indic_exp   IN VARCHAR2,
                       l_portfolio          IN VARCHAR2,
                       perspective       IN VARCHAR2,
                       l_yield_curve     IN VARCHAR2,
                       p_year_basis     IN NUMBER,
                       l_dflt_disc_rate  IN NUMBER,
                       p_rounding         IN NUMBER,
                       p_count_months_from IN DATE);
------------------------------------------------------------------------------------------------
FUNCTION GET_SPOT_RATE(p_base_ccy    VARCHAR2,
                       p_contra_ccy  VARCHAR2,
                       p_date        DATE) RETURN NUMBER ;

------------------------------------------------------------------------------------------------
FUNCTION GET_HCE_RATE(p_base_ccy    VARCHAR2,
                       p_date        DATE) RETURN NUMBER ;
------------------------------------------------------------------------------------------------
PROCEDURE SUMMARY_COST_OF_FUNDS(errbuf	OUT NOCOPY VARCHAR2,
				retcode OUT NOCOPY NUMBER);
------------------------------------------------------------------------------------------------
PROCEDURE MAINTAIN_COST_OF_FUNDS(
 L_REF_DATE			IN date,
 L_COMPANY_CODE		IN VARCHAR2,
 L_CURRENCY			IN VARCHAR2,
 L_DEAL_TYPE		IN VARCHAR2,
 L_DEAL_SUBTYPE		IN VARCHAR2,
 L_PRODUCT_TYPE		IN VARCHAR2,
 L_PORTFOLIO_CODE		IN VARCHAR2,
 L_PARTY_CODE		IN VARCHAR2,
 L_CONTRA_CCY		IN VARCHAR2,
 L_CURRENCY_COMBINATION	IN VARCHAR2,
 L_ACCOUNT			IN VARCHAR2,
 L_AMOUNT_DATE	      IN DATE,
 L_TRANSACTION_RATE	IN NUMBER,
 L_AMOUNT			IN NUMBER,
 L_AMOUNT_INDIC		IN NUMBER,
 L_ACTION_INDIC		IN NUMBER);
------------------------------------------------------------------------------------------------
end XTR_EXP_SUMM_P;

 

/
