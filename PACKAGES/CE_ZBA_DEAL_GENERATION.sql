--------------------------------------------------------
--  DDL for Package CE_ZBA_DEAL_GENERATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CE_ZBA_DEAL_GENERATION" AUTHID CURRENT_USER AS
/* $Header: cezdgens.pls 120.3 2005/08/05 10:08:12 sspoonen noship $ */
--
-- Global variables
--


-- Statement headers
--
csh_rowid			VARCHAR2(100);
csh_statement_header_id		CE_STATEMENT_HEADERS.statement_header_id%TYPE;
csh_statement_date		CE_STATEMENT_HEADERS.statement_date%TYPE;
csh_statement_gl_date		CE_STATEMENT_HEADERS.gl_date%TYPE;
csh_check_digits	        CE_STATEMENT_HEADERS.check_digits%TYPE;
csh_bank_account_id		CE_STATEMENT_HEADERS.bank_account_id%TYPE;
cba_bank_currency		CE_BANK_ACCOUNTS.currency_code%TYPE;
cba_multi_currency_flag		CE_BANK_ACCOUNTS.multi_currency_allowed_flag%TYPE;
cba_check_digits		CE_BANK_ACCOUNTS.check_digits%TYPE;
csh_statement_number		CE_STATEMENT_HEADERS.statement_number%TYPE;
csh_statement_complete_flag	CE_STATEMENT_HEADERS.statement_complete_flag%TYPE;
csh_org_id                      CE_STATEMENT_HEADERS.org_id%TYPE;
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
reconcile_to_statement_flag	CE_STATEMENT_LINES.reconcile_to_statement_flag%TYPE;
csl_match_type			FND_LOOKUP_VALUES.lookup_code%TYPE;
--
-- Passed as parameters
--

G_bank_branch_id		CE_BANK_ACCOUNTS.bank_branch_id%TYPE;
G_bank_account_id   		CE_BANK_ACCOUNTS.bank_account_id%TYPE;
G_statement_number_from		CE_STATEMENT_HEADERS.statement_number%TYPE;
G_statement_number_to		CE_STATEMENT_HEADERS.statement_number%TYPE;
G_statement_date_from		CE_STATEMENT_HEADERS.statement_date%TYPE;
G_statement_date_to		CE_STATEMENT_HEADERS.statement_date%TYPE;
G_display_debug			FND_LOOKUP_VALUES.lookup_code%TYPE;
G_debug_path			VARCHAR(100);
G_debug_file			VARCHAR(100);
G_sweep_flag			BOOLEAN DEFAULT FALSE;

p_offset_bank_account_id	CE_STATEMENT_HEADERS.bank_account_id%TYPE;
p_cashpool_id			NUMBER;
p_from_bank_account_id		CE_STATEMENT_HEADERS.bank_account_id%TYPE;
p_to_bank_account_id		CE_STATEMENT_HEADERS.bank_account_id%TYPE;

G_spec_revision 	VARCHAR2(1000) := '$Revision: 120.3 $';


--
-- Functions/procedures required for SQL functions
--
FUNCTION body_revision RETURN VARCHAR2;

FUNCTION spec_revision RETURN VARCHAR2;

FUNCTION get_security_account_type(p_account_type VARCHAR2) RETURN VARCHAR2;

PROCEDURE  xtr_shared_account(X_ACCOUNT_RESULT OUT NOCOPY VARCHAR2);

FUNCTION lock_statement(lockhandle IN OUT NOCOPY VARCHAR2) RETURN BOOLEAN;

FUNCTION lock_statement_line RETURN BOOLEAN;

FUNCTION get_min_statement_line_id RETURN NUMBER;

PROCEDURE set_parameters(p_bank_branch_id		NUMBER,
			 p_bank_account_id            	NUMBER,
			 p_statement_number_from      	VARCHAR2,
			 p_statement_number_to        	VARCHAR2,
			 p_statement_date_from	     	VARCHAR2,
			 p_statement_date_to	     	VARCHAR2,
			 p_display_debug	   	VARCHAR2,
			 p_debug_path			VARCHAR2,
			 p_debug_file			VARCHAR2);

FUNCTION break_bank_link(p_ap_bank_account_id NUMBER) RETURN BOOLEAN;

PROCEDURE zba_generation (errbuf        OUT NOCOPY     VARCHAR2,
                      	retcode       OUT NOCOPY     NUMBER,
                        p_bank_branch_id 	     NUMBER,
			p_bank_account_id            NUMBER,
			p_statement_number_from      VARCHAR2,
			p_statement_number_to        VARCHAR2,
			p_statement_date_from        VARCHAR2,
			p_statement_date_to          VARCHAR2,
                        p_display_debug		     VARCHAR2,
			p_debug_path		     VARCHAR2,
			p_debug_file		     VARCHAR2);

END CE_ZBA_DEAL_GENERATION;

 

/
