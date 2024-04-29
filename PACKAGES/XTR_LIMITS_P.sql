--------------------------------------------------------
--  DDL for Package XTR_LIMITS_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XTR_LIMITS_P" AUTHID CURRENT_USER as
/* $Header: xtrlmtss.pls 120.1 2005/06/29 10:28:37 badiredd ship $ */
----------------------------------------------------------------------------------------------------------------
FUNCTION WEIGHTED_USAGE(p_deal_type    VARCHAR2,
                        p_deal_subtype VARCHAR2,
                        p_amount_date  DATE,
                        p_hce_amount   NUMBER) RETURN NUMBER;
-- Calculate amount utilised for this limit code, by this cparty/company combination.
FUNCTION CONVERT_TO_HCE_AMOUNT(p_amount_to_convert NUMBER,
                               p_currency          VARCHAR2,
                               p_company_code      VARCHAR2) RETURN NUMBER;
-- Calculate home-currency-equivalent for p_amount_to_convert
FUNCTION GET_HCE_AMOUNT(p_amount_to_convert NUMBER,
                               p_currency          VARCHAR2) RETURN NUMBER;
-- Calculate home-currency-equivalent for p_amount_to_convert
FUNCTION LOG_FULL_LIMITS_CHECK (
                         p_DEAL_NUMBER        NUMBER,
                         p_TRANSACTION_NUMBER NUMBER,
                         p_COMPANY_CODE       VARCHAR2,
                         p_DEAL_TYPE          VARCHAR2,
                         p_DEAL_SUBTYPE       VARCHAR2,
                         p_CPARTY_CODE        VARCHAR2,
                         p_PRODUCT_TYPE       VARCHAR2,
                         p_LIMIT_CODE         VARCHAR2,
                         p_LIMIT_PARTY        VARCHAR2,
                         p_AMOUNT_DATE        DATE,
                         p_AMOUNT             NUMBER,
                         p_DEALER_CODE        VARCHAR2,
                         p_CURRENCY           VARCHAR2,
                         p_CURRENCY_SECOND    VARCHAR2 DEFAULT NULL) return number;
-- Second currency and amount incase of FX deals added for bug 1289530
-- Update limit excess log
PROCEDURE UPDATE_LIMIT_EXCESS_LOG ( p_deal_no      NUMBER,
                                    p_trans_no     NUMBER,
                                    p_user         VARCHAR2,
                                    p_log_id       NUMBER);
-- Recalculate all limit hce amts / weightings
PROCEDURE CALC_ALL_MIRROR_DDA_LIMIT_ROW(p_auto_recalc VARCHAR2);
-- Cover routine so CALC_ALL_MIRROR_DDA_LIMIT can be called as a concurrent
--   program.
PROCEDURE update_weightings (
	errbuf                  OUT NOCOPY VARCHAR2,
	retcode                 OUT NOCOPY NUMBER);
-- Calculate the utilised_amount field for all dda mirror rows.
PROCEDURE MIRROR_DDA_LIMIT_ROW_PROC (
            p_action                   VARCHAR2,
            p_old_LIMIT_CODE           VARCHAR2,
            p_old_DEAL_NUMBER          NUMBER,
            p_old_TRANSACTION_NUMBER   NUMBER,
            p_new_product_type         VARCHAR2,
            p_new_COMPANY_CODE         VARCHAR2,
            p_new_LIMIT_PARTY          VARCHAR2,
            p_new_LIMIT_CODE           VARCHAR2,
            p_new_AMOUNT_DATE          DATE,
            p_new_AMOUNT               NUMBER,
            p_new_HCE_AMOUNT           NUMBER,
            p_new_DEALER_CODE          VARCHAR2,
            p_new_DEAL_NUMBER          NUMBER,
            p_new_DEAL_TYPE            VARCHAR2,
            p_new_TRANSACTION_NUMBER   NUMBER,
            p_new_DEAL_SUBTYPE         VARCHAR2,
            p_new_PORTFOLIO_CODE       VARCHAR2,
            p_new_STATUS_CODE          VARCHAR2,
            p_new_currency             VARCHAR2,
	      p_amount_type		   VARCHAR2,
 		p_transaction_rate	   NUMBER,
		p_currency_combination     VARCHAR2,
            p_account_no		   VARCHAR2,
            p_commence_date            DATE);
-- This procedure is called by a DB trigger on table DDA whenever a DDA record is
-- UPDATED/DELETED/INSERTED. This procedure has two purposes:
-- 1) maintain a mirror of the non-null-limit-code DDA records in table mirror_dda_limit_row.
-- 2) calculate and store the current limit usage amount for each mirror record whenever a
--    mirror row is inserted/updated.
PROCEDURE GET_LIM_GLOBAL ( p_deal_no      NUMBER,
                           p_company_code VARCHAR2,
                           p_limit_code   VARCHAR2,
                           p_limit_amt    OUT NOCOPY number,
                           p_util_amt     OUT NOCOPY number,
                           p_err_code     OUT NOCOPY varchar2);
PROCEDURE GET_LIM_GROUP  ( p_deal_no      NUMBER,
                           p_company_code VARCHAR2,
                           p_limit_type   VARCHAR2,
                           p_group_party  VARCHAR2,
                           p_limit_amt    OUT NOCOPY number,
                           p_util_amt     OUT NOCOPY number,
                           p_err_code     OUT NOCOPY varchar2);
PROCEDURE GET_LIM_SOVEREIGN ( p_deal_no      NUMBER,
                              p_company_code VARCHAR2,
                              p_country_code VARCHAR2,
                              p_limit_amt    OUT NOCOPY number,
                              p_util_amt     OUT NOCOPY number,
                              p_err_code     OUT NOCOPY varchar2);
PROCEDURE GET_LIM_DEALER_DEAL ( p_deal_no      NUMBER,
                                p_dealer_code  VARCHAR2,
                                p_deal_type    VARCHAR2,
                                p_product_type VARCHAR2,
                                p_limit_amt    OUT NOCOPY number,
                                p_err_code     OUT NOCOPY varchar2);
PROCEDURE GET_LIM_INTRA_DAY ( p_deal_no      NUMBER,
                              p_dealer_code  VARCHAR2,
                              p_deal_type    VARCHAR2,
                              p_limit_amt    OUT NOCOPY number,
                              p_util_amt     OUT NOCOPY number,
                              p_err_code     OUT NOCOPY varchar2);
PROCEDURE GET_LIM_CPARTY ( p_deal_no       NUMBER,
                           p_company_code  VARCHAR2,
                           p_cparty_code   VARCHAR2,
                           p_limit_code    VARCHAR2,
                           p_limit_amt     OUT NOCOPY number,
                           p_util_amt      OUT NOCOPY number,
                           p_err_code      OUT NOCOPY varchar2);
PROCEDURE GET_ACTUAL_SETTLE_EXCESS ( p_deal_no       NUMBER,
                           p_company_code  VARCHAR2,
                           p_limit_party   VARCHAR2,
                           p_amount_date   DATE,
                           p_limit_amt     OUT NOCOPY number,
                           p_util_amt      OUT NOCOPY number,
                           p_err_code      OUT NOCOPY varchar2);
PROCEDURE GET_LIM_SETTLE ( p_deal_no       NUMBER,
                           p_company_code  VARCHAR2,
                           p_limit_party   VARCHAR2,
                           p_amount_date   DATE,
                           p_limit_amt     OUT NOCOPY number,
                           p_util_amt      OUT NOCOPY number,
                           p_err_code      OUT NOCOPY varchar2);
PROCEDURE GET_LIM_CCY ( p_deal_no      NUMBER,
                        p_currency     VARCHAR2,
                        p_limit_amt    OUT NOCOPY number,
                        p_util_amt     OUT NOCOPY number,
                        p_err_code     OUT NOCOPY varchar2);
PROCEDURE MAINTAIN_EXCESS_LOG( p_log_id  NUMBER,
                               p_action  VARCHAR2,
                               p_user    VARCHAR2);
-- Procedure to update all limits table with the most up-to-date information
--   from XTR_MIRROR_DDA_LIMIT_ROW_V
PROCEDURE reinitialize_limits (
	errbuf                  OUT NOCOPY VARCHAR2,
	retcode                 OUT NOCOPY NUMBER);
--------------------------------------------------------------------------------------------------------------------
end XTR_LIMITS_P;

 

/
