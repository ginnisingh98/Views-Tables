--------------------------------------------------------
--  DDL for Package CE_AUTO_BANK_MATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CE_AUTO_BANK_MATCH" AUTHID CURRENT_USER AS
/* $Header: ceabrmas.pls 120.16 2008/01/23 13:20:22 kbabu ship $ */
--
-- Global variables
--
ar_accounting_method		AR_SYSTEM_PARAMETERS_ALL.accounting_method%TYPE;

av_101_inserted_flag                   VARCHAR2(1) DEFAULT 'N';
av_200_inserted_flag                   VARCHAR2(1) DEFAULT 'N';
av_222_inserted_flag                   VARCHAR2(1) DEFAULT 'N';
av_260_inserted_flag                   VARCHAR2(1) DEFAULT 'N';
av_260_cf_inserted_flag                VARCHAR2(1) DEFAULT 'N';
av_801_inserted_flag                   VARCHAR2(1) DEFAULT 'N';
av_801_eft_inserted_flag               VARCHAR2(1) DEFAULT 'N';
av_999_inserted_flag                   VARCHAR2(1) DEFAULT 'N';
av_185_inserted_flag                   VARCHAR2(1) DEFAULT 'N';

gt_seq_id	NUMBER(15);
gt_seq_id2      NUMBER(15);



-- Statement headers
--
csh_rowid			VARCHAR2(100);
csh_statement_header_id		CE_STATEMENT_HEADERS.statement_header_id%TYPE;
csh_statement_date		CE_STATEMENT_HEADERS.statement_date%TYPE;
csh_statement_gl_date		CE_STATEMENT_HEADERS.gl_date%TYPE;
csh_check_digits	        CE_STATEMENT_HEADERS.check_digits%TYPE;
csh_bank_account_id		CE_STATEMENT_HEADERS.bank_account_id%TYPE;
csh_statement_number		CE_STATEMENT_HEADERS.statement_number%TYPE;
csh_statement_complete_flag	CE_STATEMENT_HEADERS.statement_complete_flag%TYPE;

--
-- Bank Accounts/Bank Account Uses
--
aba_bank_currency		CE_BANK_ACCOUNTS.currency_code%TYPE;
aba_asset_code_combination_id	number; /*for JEC --AP_BANK_ACCOUNTS_ALL.asset_code_combination_id*/
aba_multi_currency_flag		CE_BANK_ACCOUNTS.MULTI_CURRENCY_ALLOWED_FLAG%TYPE;
aba_check_digits		CE_BANK_ACCOUNTS.check_digits%TYPE;
ba_ap_amount_tolerance		CE_BANK_ACCOUNTS.ap_amount_tolerance%TYPE;
ba_ap_percent_tolerance		CE_BANK_ACCOUNTS.ap_percent_tolerance%TYPE;
ba_ar_amount_tolerance		CE_BANK_ACCOUNTS.ar_amount_tolerance%TYPE;
ba_ar_percent_tolerance		CE_BANK_ACCOUNTS.ar_percent_tolerance%TYPE;
ba_ce_amount_tolerance		CE_BANK_ACCOUNTS.ce_amount_tolerance%TYPE;
ba_ce_percent_tolerance		CE_BANK_ACCOUNTS.ce_percent_tolerance%TYPE;
/*ba_xtr_amount_tolerance	CE_BANK_ACCOUNTS.xtr_amount_tolerance%TYPE;
ba_xtr_percent_tolerance	CE_BANK_ACCOUNTS.xtr_percent_tolerance%TYPE;
ba_pay_amount_tolerance		CE_BANK_ACCOUNTS.pay_amount_tolerance%TYPE;
ba_pay_percent_tolerance	CE_BANK_ACCOUNTS.pay_percent_tolerance%TYPE;
*/
 BA_ROWID			VARCHAR2(100);
 BA_OWNER_LE_ID			  NUMBER;

 BA_RECON_OI_AMOUNT_TOLERANCE	  NUMBER;
 BA_RECON_OI_PERCENT_TOLERANCE	  NUMBER;
 BA_RECON_AP_FX_DIFF_HANDLING 	  VARCHAR2(30);
 BA_RECON_AR_FX_DIFF_HANDLING 	  VARCHAR2(30);
 BA_RECON_CE_FX_DIFF_HANDLING 	  VARCHAR2(30);

-- FROM CE_BANK_ACCT_USES_ALL

BAU_ROWID			VARCHAR2(100);
bau_bank_acct_use_id		CE_BANK_ACCT_USES_ALL.bank_acct_use_id%TYPE;
bau_ap_use_enable_flag   	CE_BANK_ACCT_USES_ALL.ap_use_enable_flag%TYPE;
bau_ar_use_enable_flag   	CE_BANK_ACCT_USES_ALL.ar_use_enable_flag%TYPE;
bau_xtr_use_enable_flag   	CE_BANK_ACCT_USES_ALL.xtr_use_enable_flag%TYPE;
bau_pay_use_enable_flag   	CE_BANK_ACCT_USES_ALL.pay_use_enable_flag%TYPE;
bau_org_id			CE_BANK_ACCT_USES_ALL.org_id%TYPE;
bau_legal_entity_id		CE_BANK_ACCT_USES_ALL.legal_entity_id%TYPE;

trx_bank_acct_use_id		CE_BANK_ACCT_USES_ALL.bank_acct_use_id%TYPE;

G_receivables_trx_id		NUMBER(15);
G_receivables_trx_dsp		VARCHAR2(100);


-- LE global values
/*
G_le_fx_difference_handling  	VARCHAR2(30);
G_le_amount_tolerance		NUMBER;
G_le_percent_tolerance		NUMBER;
*/
--
-- Statement Lines
--
csl_rowid			VARCHAR2(100);
csl_statement_line_id		CE_STATEMENT_LINES.statement_line_id%TYPE;
csl_line_number			CE_STATEMENT_LINES.line_number%TYPE;
csl_trx_date			CE_STATEMENT_LINES.trx_date%TYPE;
csl_trx_type			CE_STATEMENT_LINES.trx_type%TYPE;
csl_trx_code_id			CE_STATEMENT_LINES.trx_code_id%TYPE;
csl_bank_trx_number		CE_STATEMENT_LINES.bank_trx_number%TYPE;
csl_invoice_text		CE_STATEMENT_LINES.invoice_text%TYPE;
csl_bank_account_text		CE_STATEMENT_LINES.bank_account_text%TYPE;
csl_amount			CE_STATEMENT_LINES.amount%TYPE;
csl_charges_amount		CE_STATEMENT_LINES.charges_amount%TYPE;
corr_csl_amount			CE_STATEMENT_LINES.amount%TYPE;
calc_csl_amount			CE_STATEMENT_LINES.amount%TYPE;
csl_receivables_trx_id		CE_TRANSACTION_CODES.receivables_trx_id%TYPE;
csl_receipt_method_id		CE_TRANSACTION_CODES.receipt_method_id%TYPE;
csl_create_misc_trx_flag	CE_TRANSACTION_CODES.create_misc_trx_flag%TYPE;
csl_matching_against		CE_TRANSACTION_CODES.matching_against%TYPE;
csl_correction_method		CE_TRANSACTION_CODES.correction_method%TYPE;
csl_reconcile_flag		CE_TRANSACTION_CODES.reconcile_flag%TYPE;
csl_receipt_method_name		AR_RECEIPT_METHODS.name%TYPE;
csl_currency_code		FND_CURRENCIES.currency_code%TYPE;
csl_line_trx_type	        CE_STATEMENT_LINES.trx_type%TYPE;
csl_exchange_rate_type		GL_DAILY_RATES.conversion_type%TYPE;
csl_exchange_rate_date		GL_DAILY_RATES.conversion_date%TYPE;
csl_exchange_rate		GL_DAILY_RATES.conversion_rate%TYPE;
csl_match_found			FND_LOOKUP_VALUES.lookup_code%TYPE;
csl_original_amount		CE_STATEMENT_LINES.original_amount%TYPE;
csl_payroll_payment_format	PAY_PAYMENT_TYPES.payment_type_name%TYPE;
csl_clearing_trx_type		FND_LOOKUP_VALUES.lookup_code%TYPE;
csl_customer_text		CE_STATEMENT_LINES.customer_text%TYPE;
csl_effective_date		CE_STATEMENT_LINES.effective_date%TYPE;
csl_je_status_flag 		CE_STATEMENT_LINES.je_status_flag%TYPE;
csl_accounting_date 		CE_STATEMENT_LINES.accounting_date%TYPE;
csl_cashflow_id 		CE_STATEMENT_LINES.cashflow_id%TYPE;

reconcile_to_statement_flag	CE_STATEMENT_LINES.reconcile_to_statement_flag%TYPE;
foreign_exchange_defaulted	VARCHAR2(1) DEFAULT 'N';
csl_event_id			NUMBER(15);

--
-- Transactions
--
trx_id				AR_CASH_RECEIPT_HISTORY_ALL.cash_receipt_history_id%TYPE;
trx_cash_receipt_id		AR_CASH_RECEIPT_HISTORY_ALL.cash_receipt_id%TYPE;
trx_rowid			VARCHAR2(100);
trx_date			DATE;
trx_currency_code		FND_CURRENCIES.currency_code%TYPE;
trx_amount			AR_CASH_RECEIPT_HISTORY_ALL.amount%TYPE;
trx_base_amount			AR_CASH_RECEIPT_HISTORY_ALL.acctd_amount%TYPE;
trx_cleared_amount		AR_CASH_RECEIPT_HISTORY_ALL.amount%TYPE;
trx_curr_amount			AR_CASH_RECEIPT_HISTORY_ALL.amount%TYPE;
trx_currency_type		FND_LOOKUP_VALUES.lookup_code%TYPE;
trx_status			AR_CASH_RECEIPT_HISTORY_ALL.status%TYPE;
trx_errors_amount		CE_STATEMENT_LINES.amount%TYPE;
trx_charges_amount		CE_STATEMENT_LINES.amount%TYPE;
trx_prorate_amount		CE_STATEMENT_LINES.amount%TYPE;
trx_exchange_rate_type		GL_DAILY_RATES.conversion_type%TYPE;
trx_exchange_rate_date		GL_DAILY_RATES.conversion_date%TYPE;
trx_exchange_rate		GL_DAILY_RATES.conversion_rate%TYPE;
trx_customer_id			NUMBER; --RA_CUSTOMERS.customer_id%TYPE;
reversed_receipt_flag           VARCHAR2(1);
trx_gl_date                     DATE;
trx_group			VARCHAR2(100);
trx_count			NUMBER;
trx_org_id			NUMBER;
trx_legal_entity_id		NUMBER;
trx_reference_type		VARCHAR2(60);
trx_value_date                  DATE;
trx_cleared_date                DATE;
trx_deposit_date                DATE;
LOGICAL_GROUP_REFERENCE         IBY_PAYMENTS_ALL.LOGICAL_GROUP_REFERENCE%type;  -- FOR SEPA ER 6700007
--
-- Adjustment Statement lines
--
trx_id2				CE_STATEMENT_LINES.statement_line_id%TYPE;
trx_rowid2			VARCHAR2(100);
trx_date2			DATE;
trx_currency_code2		FND_CURRENCIES.currency_code%TYPE;
trx_amount2			AR_CASH_RECEIPT_HISTORY_ALL.amount%TYPE;
trx_base_amount2		AR_CASH_RECEIPT_HISTORY_ALL.acctd_amount%TYPE;
trx_cleared_amount2		AR_CASH_RECEIPT_HISTORY_ALL.amount%TYPE;
trx_curr_amount2		AR_CASH_RECEIPT_HISTORY_ALL.amount%TYPE;
trx_currency_type2		FND_LOOKUP_VALUES.lookup_code%TYPE;
trx_status2			AR_CASH_RECEIPT_HISTORY_ALL.status%TYPE;
trx_errors_amount2		CE_STATEMENT_LINES.amount%TYPE;
trx_charges_amount2		CE_STATEMENT_LINES.amount%TYPE;
trx_prorate_amount2		CE_STATEMENT_LINES.amount%TYPE;
trx_exchange_rate_type2		GL_DAILY_RATES.conversion_type%TYPE;
trx_exchange_rate_date2		GL_DAILY_RATES.conversion_date%TYPE;
trx_type2			FND_LOOKUP_VALUES.lookup_code%TYPE;
trx_exchange_rate2		GL_DAILY_RATES.conversion_rate%TYPE;
--
-- csl_match_type is blank when there is no matching transaction
-- it is one of the following when the match is found:
--
--
csl_match_type			FND_LOOKUP_VALUES.lookup_code%TYPE;
csl_match_type2			FND_LOOKUP_VALUES.lookup_code%TYPE;
trx_match_type			FND_LOOKUP_VALUES.lookup_code%TYPE;
csl_match_correction_type	FND_LOOKUP_VALUES.lookup_code%TYPE;
reconciled_this_run		VARCHAR2(1);
tolerance_amount		CE_STATEMENT_LINES.amount%TYPE;
acctd_exchange_rate		CE_STATEMENT_LINES.exchange_rate%TYPE;
nsf_info_flag                   VARCHAR2(1) DEFAULT 'N';
trx_clr_flag                    VARCHAR2(1) DEFAULT 'N';

--
-- Original transaction info
--
batch_exchange_rate_type	AP_INV_SELECTION_CRITERIA_ALL.exchange_rate_type%TYPE;
batch_exchange_rate		AP_INV_SELECTION_CRITERIA_ALL.exchange_rate%TYPE;
batch_exchange_rate_date	AP_INV_SELECTION_CRITERIA_ALL.exchange_date%TYPE;

--
-- Variables required for SQL functions
--
yes_101 			NUMBER DEFAULT 0;
yes_200 			NUMBER DEFAULT 0;
yes_200_GROUP 			NUMBER DEFAULT 0;  -- FOR SEPA ER 6700007
yes_222 			NUMBER DEFAULT 0;
yes_260 			NUMBER DEFAULT 0;
yes_801 			NUMBER DEFAULT 0;
yes_999 			NUMBER DEFAULT 0;
display_inverse_rate		VARCHAR2(1) DEFAULT 'N';

G_spec_revision 	VARCHAR2(1000) := '$Revision: 120.16 $';


--
-- Functions/procedures required for SQL functions
--
FUNCTION  spec_revision RETURN VARCHAR2;
FUNCTION  body_revision RETURN VARCHAR2;
PROCEDURE set_101;
PROCEDURE set_200;
PROCEDURE set_200_group; -- FOR SEPA ER 6700007
PROCEDURE set_222;
PROCEDURE set_260;
PROCEDURE set_801;
PROCEDURE set_999;
PROCEDURE set_all;

PROCEDURE unset_101;
PROCEDURE unset_200;
PROCEDURE unset_200_group; -- FOR SEPA ER 6700007
PROCEDURE unset_222;
PROCEDURE unset_260;
PROCEDURE unset_801;
PROCEDURE unset_999;
PROCEDURE unset_all;

FUNCTION get_101 RETURN NUMBER;
PRAGMA   RESTRICT_REFERENCES(get_101,WNDS,WNPS);

FUNCTION get_200 RETURN NUMBER;
PRAGMA   RESTRICT_REFERENCES(get_200,WNDS,WNPS);

FUNCTION get_200_group RETURN NUMBER;  -- FOR SEPA ER 6700007
PRAGMA   RESTRICT_REFERENCES(get_200,WNDS,WNPS);

FUNCTION get_222 RETURN NUMBER;
PRAGMA   RESTRICT_REFERENCES(get_222,WNDS,WNPS);

FUNCTION get_260 RETURN NUMBER;
PRAGMA   RESTRICT_REFERENCES(get_260,WNDS,WNPS);

FUNCTION get_801 RETURN NUMBER;
PRAGMA   RESTRICT_REFERENCES(get_801,WNDS,WNPS);

FUNCTION get_999 RETURN NUMBER;
PRAGMA   RESTRICT_REFERENCES(get_999,WNDS,WNPS);
--
-- Function to return value of account type, based on payroll security profile
--
FUNCTION get_security_account_type(p_account_type VARCHAR2) RETURN VARCHAR2;
PRAGMA   RESTRICT_REFERENCES(get_security_account_type,WNDS,WNPS);
--
-- Function to return the value for the
-- DISPLAY_INVERSE_RATE
--
PROCEDURE set_inverse_rate(inverse_rate		VARCHAR2);

FUNCTION get_inverse_rate RETURN VARCHAR2;
PRAGMA   RESTRICT_REFERENCES(get_inverse_rate,WNDS,WNPS);

--FUNCTION  get_vat_tax_id RETURN NUMBER;
PROCEDURE get_vat_tax_id (X_pass_mode	VARCHAR2,
			  l_vat_tax_id OUT NOCOPY NUMBER,
			  X_tax_rate OUT NOCOPY NUMBER);

FUNCTION  convert_amount_tolerance (amount_to_convert NUMBER)  RETURN NUMBER;

FUNCTION  validate_payment_method RETURN BOOLEAN;

FUNCTION trx_validation (no_of_currencies        NUMBER) RETURN BOOLEAN;

PROCEDURE calc_actual_tolerance;

PROCEDURE match_process;

/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE							|
|       populate_available_gt						|
|                                                                       |
|  DESCRIPTION                                                          |
|       populate ce_available_transactions_tmp for auto reconciliation	|
|									|
|  CALLED BY                                                            |
|       match_process                                                   |
|                                                                       |
|  HISTORY                                                              |
|       11-MAY-2006        Xin Wang 	Created				|
 --------------------------------------------------------------------- */
PROCEDURE populate_available_gt (p_bank_account_id 	NUMBER);

/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE                                                     |
|       update_gt_reconciled_status					|
|                                                                       |
|  DESCRIPTION                                                          |
|       update the reconciled_status_flag of table			|
|	ce_available_transactions_tmp 					|
|	mainly used to update the status to 'Y'				|
|                                                                       |
|  CALLED BY                                                            |
|       match_process                                                   |
|	match_stmt_line_JE						|
|	CE_AUTO_BANK_CLEAR1.reconcile_pbatch				|
|	CE_AUTO_BANK_CLEAR1.reconcile_rbatch				|
|	CE_AUTO_BANK_CLEAR1.reconcile_pay_eft				|
|                                                                       |
|  HISTORY                                                              |
|       11-MAY-2006        Xin Wang     Created                         |
 --------------------------------------------------------------------- */
PROCEDURE update_gt_reconciled_status(p_seq_id  NUMBER,
                                      p_status  VARCHAR2);

/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE                                                     |
|       update_gt_reconciled_status                                     |
|                                                                       |
|  DESCRIPTION                                                          |
|       update the reconciled_status_flag of table                      |
|       ce_available_transactions_tmp                                   |
|	mainly used to update the status to 'N' during unreconciliation	|
|                                                                       |
|  CALLED BY                                                            |
|       CE_AUTO_BANK_CLEAR1.unclear_process				|
|                                                                       |
|  HISTORY                                                              |
|       11-MAY-2006        Xin Wang     Created                         |
 --------------------------------------------------------------------- */
PROCEDURE update_gt_reconciled_status(p_application_id  	NUMBER,
				      p_trx_id			NUMBER,
                                      p_reconciled_status  	VARCHAR2);

/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE                                                     |
|       update_gt_reconciled_status                                     |
|                                                                       |
|  DESCRIPTION                                                          |
|       update the reconciled_status_flag of table                      |
|       ce_available_transactions_tmp                                   |
|       mainly used to update the status to 'N' during                  |
|       auto unreconciliation                                           |
|                                                                       |
|  CALLED BY                                                            |
|       CE_AUTO_BANK_CLEAR1.unclear_process                             |
|                                                                       |
|  HISTORY                                                              |
|       11-MAY-2006        Xin Wang     Created                         |
 --------------------------------------------------------------------- */
PROCEDURE update_gt_reconciled_status(p_reconciled_status       VARCHAR2);

PROCEDURE lock_transaction (    X_RECONCILE_FLAG	VARCHAR2,
				X_CALL_MODE		VARCHAR2,
				X_TRX_TYPE              VARCHAR2,
                                X_CLEARING_TRX_TYPE     VARCHAR2,
                                X_TRX_ROWID             VARCHAR2,
				X_BATCH_BA_AMOUNT	NUMBER,
				X_MATCH_CORRECTION_TYPE	VARCHAR2 DEFAULT NULL,
				X_LOGICAL_GROUP_REFERENCE VARCHAR2 DEFAULT NULL);


END CE_AUTO_BANK_MATCH;

/
