--------------------------------------------------------
--  DDL for Package XTR_COF_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XTR_COF_P" AUTHID CURRENT_USER as
/* $Header: xtrcosts.pls 120.3 2005/06/29 06:12:35 badiredd ship $ */

/*
XTR_POSITION_HISTORY holds a daily record of balances and rates for all instuments
that were current at that time. Essentially it is a snapshot of xtr_mirror_dda_limit_row.
It is maintained automatically through calling package xtr_maintain_history from the relevant
table triggers on tables(xtr_Deals,xtr_Rollover_Transactions, xtr_Intergroup_Transfers
and xtr_Bank_Balances)

All backdating of deals (both updates and new records) are handled and records
in xtr_position_history are  table trigger on xtr_position_history calls package
xtr_maintain_cost_of_funds to maintain XTR_COST_OF_FUNDS. This table holds summarized information
grouped by Company, Deal Type, Deal Subtype, Product Type, Portfolio, Cparty, Currency and
Currency Combination.

Note: For bugs 2855289 and 3062129 for both speed and accuracy global variables
have been added.
For IG there is G_IG_CURR_DEAL_NUMBER, G_IG_CURR_TRANSACTION_NUMBER and G_IG_CURR_MATURITY_DATE,
and for CA there is G_CA_DEAL_NUMBER, G_CA_CURR_TRANSACTION_NUMBER, and G_CA_CURR_MATURITY_DATE.
If the deal number and transaction number match the current deal being processed then the value
stored in the maturity date is used as the maturity date.  This prevents the position table
from populating too far because these deal types do not have a column in their respective tables
to receive the maturity date.  SET/GET_CURR_DEAL_ADDITIONAL_DETAILS are helper functions to set these values.
You can only hold one deal at a time per deal type, and once the deal information is used it is cleared.
*/

G_IG_CURR_DEAL_NUMBER		XTR_INTERGROUP_TRANSFERS.DEAL_NUMBER%TYPE;
G_IG_CURR_TRANSACTION_NUMBER	XTR_INTERGROUP_TRANSFERS.TRANSACTION_NUMBER%TYPE;
G_IG_CURR_MATURITY_DATE		DATE;

PROCEDURE SET_CURR_IG_DEAL_DETAILS(
 P_DEAL_NUMBER		IN XTR_INTERGROUP_TRANSFERS.DEAL_NUMBER%TYPE,
 P_TRANSACTION_NUMBER	IN XTR_INTERGROUP_TRANSFERS.TRANSACTION_NUMBER%TYPE,
 P_MATURITY_DATE	IN DATE);

PROCEDURE GET_CURR_IG_DEAL_DETAILS(
 P_DEAL_NUMBER		IN XTR_INTERGROUP_TRANSFERS.DEAL_NUMBER%TYPE,
 P_TRANSACTION_NUMBER	IN XTR_INTERGROUP_TRANSFERS.TRANSACTION_NUMBER%TYPE,
 P_MATURITY_DATE	OUT NOCOPY DATE);

PROCEDURE MAINTAIN_POSITION_HISTORY(
 P_START_DATE                   IN DATE,
 P_MATURITY_DATE                IN DATE,
 P_OTHER_DATE                   IN DATE,
 P_DEAL_NUMBER                  IN NUMBER,
 P_TRANSACTION_NUMBER           IN NUMBER,
 P_COMPANY_CODE                 IN VARCHAR2,
 P_CURRENCY                     IN VARCHAR2,
 P_DEAL_TYPE                    IN VARCHAR2,
 P_DEAL_SUBTYPE                 IN VARCHAR2,
 P_PRODUCT_TYPE                 IN VARCHAR2,
 P_PORTFOLIO_CODE               IN VARCHAR2,
 P_CPARTY_CODE                  IN VARCHAR2,
 P_CONTRA_CCY                   IN VARCHAR2,
 P_CURRENCY_COMBINATION         IN VARCHAR2,
 P_ACCOUNT_NO                   IN VARCHAR2,
 P_TRANSACTION_RATE             IN NUMBER,
 P_YEAR_CALC_TYPE               IN VARCHAR2,
 P_BASE_REF_AMOUNT              IN NUMBER,
 P_BASE_RATE                    IN NUMBER,
 P_STATUS_CODE                  IN VARCHAR2,
 P_INTEREST			IN NUMBER,
 P_MATURITY_AMOUNT		IN NUMBER,
 P_START_AMOUNT			IN NUMBER,
 P_CALC_BASIS			IN VARCHAR2,
 P_CALC_TYPE			IN VARCHAR2,
 P_ACTION                       IN VARCHAR2,
 P_DAY_COUNT_TYPE               IN VARCHAR2 DEFAULT NULL,
 P_FIRST_TRANS_FLAG             IN VARCHAR2 DEFAULT NULL
  );

PROCEDURE SNAPSHOT_POSITION_HISTORY(
 P_AS_AT_DATE                   IN DATE,
 P_DEAL_NUMBER                  IN NUMBER,
 P_TRANSACTION_NUMBER           IN NUMBER,
 P_COMPANY_CODE                 IN VARCHAR2,
 P_CURRENCY                     IN VARCHAR2,
 P_DEAL_TYPE                    IN VARCHAR2,
 P_DEAL_SUBTYPE                 IN VARCHAR2,
 P_PRODUCT_TYPE                 IN VARCHAR2,
 P_PORTFOLIO_CODE               IN VARCHAR2,
 P_CPARTY_CODE                  IN VARCHAR2,
 P_CONTRA_CCY                   IN VARCHAR2,
 P_CURRENCY_COMBINATION         IN VARCHAR2,
 P_ACCOUNT_NO                   IN VARCHAR2,
 P_TRANSACTION_RATE             IN NUMBER,
 P_YEAR_CALC_TYPE               IN VARCHAR2,
 P_BASE_REF_AMOUNT              IN NUMBER,
 P_BASE_RATE                    IN NUMBER,
 P_STATUS_CODE                  IN VARCHAR2,
 P_START_DATE			IN DATE,
 P_MATURITY_DATE		IN DATE,
 P_INTEREST                     IN NUMBER,
 P_MATURITY_AMOUNT              IN NUMBER,
 P_START_AMOUNT                 IN NUMBER,
 P_CALC_BASIS                   IN VARCHAR2,
 P_CALC_TYPE			IN VARCHAR2,
 P_DAY_COUNT_TYPE               IN VARCHAR2 DEFAULT NULL,
 P_FIRST_TRANS_FLAG             IN VARCHAR2 DEFAULT NULL
);

PROCEDURE MAINTAIN_COST_OF_FUND(
 OLD_AS_AT_DATE                 IN date,
 OLD_COMPANY_CODE               IN VARCHAR2,
 OLD_CURRENCY                   IN VARCHAR2,
 OLD_DEAL_TYPE                  IN VARCHAR2,
 OLD_DEAL_SUBTYPE               IN VARCHAR2,
 OLD_PRODUCT_TYPE               IN VARCHAR2,
 OLD_PORTFOLIO_CODE             IN VARCHAR2,
 OLD_CPARTY_CODE                IN VARCHAR2,
 OLD_CONTRA_CCY                 IN VARCHAR2,
 OLD_CURRENCY_COMBINATION       IN VARCHAR2,
 OLD_ACCOUNT_NO                 IN VARCHAR2,
 OLD_TRANSACTION_RATE           IN NUMBER,
 OLD_YEAR_CALC_TYPE             IN VARCHAR2,
 OLD_BASE_REF_AMOUNT            IN NUMBER,
 OLD_HCE_BASE_REF_AMOUNT        IN NUMBER,
 OLD_BASE_RATE                  IN NUMBER,
 OLD_INTEREST                   IN NUMBER,
 OLD_HCE_INTEREST               IN NUMBER,
 NEW_AS_AT_DATE                 IN date,
 NEW_COMPANY_CODE               IN VARCHAR2,
 NEW_CURRENCY                   IN VARCHAR2,
 NEW_DEAL_TYPE                  IN VARCHAR2,
 NEW_DEAL_SUBTYPE               IN VARCHAR2,
 NEW_PRODUCT_TYPE               IN VARCHAR2,
 NEW_PORTFOLIO_CODE             IN VARCHAR2,
 NEW_CPARTY_CODE                IN VARCHAR2,
 NEW_CONTRA_CCY                 IN VARCHAR2,
 NEW_CURRENCY_COMBINATION       IN VARCHAR2,
 NEW_ACCOUNT_NO                 IN VARCHAR2,
 NEW_TRANSACTION_RATE           IN NUMBER,
 NEW_YEAR_CALC_TYPE             IN VARCHAR2,
 NEW_BASE_REF_AMOUNT            IN NUMBER,
 NEW_HCE_BASE_REF_AMOUNT        IN NUMBER,
 NEW_BASE_RATE                  IN NUMBER,
 NEW_INTEREST                   IN NUMBER,
 NEW_HCE_INTEREST               IN NUMBER,
 P_ACTION                       IN VARCHAR2);

PROCEDURE SNAPSHOT_COST_OF_FUNDS(errbuf   OUT NOCOPY VARCHAR2,
                                retcode OUT NOCOPY NUMBER);

PROCEDURE CALCULATE_BOND_RATE(
	p_deal_no		IN NUMBER,
	p_maturity_amt		IN NUMBER,
	p_consideration		IN NUMBER,
	p_coupon_rate		IN NUMBER,
	p_start_date		IN DATE,
	p_maturity_date		IN DATE,
	p_calc_type		IN VARCHAR2,
        p_daily_int             OUT NOCOPY NUMBER,
	p_yield_rate		OUT NOCOPY NUMBER,
        p_day_count_type        IN VARCHAR2 DEFAULT NULL);

PROCEDURE UPLOAD_AVG_RATES_RESULTS(
	p_batch_id		IN NUMBER,
	p_group_type		IN VARCHAR2,
	p_date_from		IN DATE,
	p_date_to		IN DATE,
	p_company_code		IN VARCHAR2,
	p_deal_type		IN VARCHAR2,
	p_currency		IN VARCHAR2,
	p_contra_ccy		IN VARCHAR2,
	p_cparty_code		IN VARCHAR2,
	p_product_type		IN VARCHAR2,
	p_portfolio_code	IN VARCHAR2,
	p_group_by_month 	IN VARCHAR2,
	p_group_by_year		IN VARCHAR2,
	p_group_by_company 	IN VARCHAR2,
	p_group_by_deal		IN VARCHAR2,
	p_group_by_currency	IN VARCHAR2,
	p_group_by_cparty	IN VARCHAR2,
	p_group_by_product	IN VARCHAR2,
	p_group_by_portfolio	IN VARCHAR2);

end XTR_COF_P;

 

/
