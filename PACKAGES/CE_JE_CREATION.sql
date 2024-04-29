--------------------------------------------------------
--  DDL for Package CE_JE_CREATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CE_JE_CREATION" AUTHID CURRENT_USER AS
/* $Header: cejecrns.pls 120.5 2006/01/18 21:44:48 lkwan noship $ */
--

G_spec_revision 	VARCHAR2(1000) := '$Revision: 120.5 $';

-- Statement header variables
csh_statement_header_id number(10);--CE_STATEMENT_HEADERS_ALL.statement_header_id%TYPE;
csh_bank_account_id		CE_STATEMENT_HEADERS.bank_account_id%TYPE;
csh_bank_account_ccid	CE_GL_ACCOUNTS_CCID.ASSET_CODE_COMBINATION_ID%TYPE;
csh_currency_code		FND_CURRENCIES.currency_code%TYPE;
csh_statement_date		DATE;
csh_statement_gl_date	DATE;
ba_currency_code		FND_CURRENCIES.currency_code%TYPE;

-- added for R12
ba_legal_entity_id		NUMBER(15);

--
-- Statement Lines
--

csl_rowid			VARCHAR2(100);
csl_statement_line_id		CE_STATEMENT_LINES.statement_line_id%TYPE;
csl_trx_date			CE_STATEMENT_LINES.trx_date%TYPE;
csl_trx_type			CE_STATEMENT_LINES.trx_type%TYPE;
csl_effective_date			CE_STATEMENT_LINES.effective_date%TYPE;
csl_trx_code_id			CE_STATEMENT_LINES.trx_code_id%TYPE;
csl_amount			CE_STATEMENT_LINES.amount%TYPE;
csl_currency_code		FND_CURRENCIES.currency_code%TYPE;
csl_exchange_rate_type		GL_DAILY_RATES.conversion_type%TYPE;
csl_exchange_rate_date		GL_DAILY_RATES.conversion_date%TYPE;
csl_exchange_rate		GL_DAILY_RATES.conversion_rate%TYPE;
csl_match_found			FND_LOOKUP_VALUES.lookup_code%TYPE;
csl_original_amount		CE_STATEMENT_LINES.original_amount%TYPE;
csl_status			CE_STATEMENT_LINES.status%TYPE;
csl_je_status_flag 		CE_STATEMENT_LINES.je_status_flag%TYPE;
csl_trx_text 			CE_STATEMENT_LINES.trx_text%TYPE;
csl_accounting_date		DATE;

-- added for R12
csl_bank_trx_number		CE_STATEMENT_LINES.bank_trx_number%TYPE;
csl_bank_account_text		CE_STATEMENT_LINES.bank_account_text%TYPE;
csl_customer_text		CE_STATEMENT_LINES.customer_text%TYPE;
csl_cashflow_id			NUMBER(15);


--
-- Journal Entry Mappings
--
jem_je_mapping_id	 CE_JE_MAPPINGS.je_mapping_id%TYPE;
jem_trx_code_id 		CE_TRANSACTION_CODES.transaction_code_id%TYPE;
jem_search_string_txt	 CE_JE_MAPPINGS.search_string_txt%TYPE;
jem_gl_account_ccid	 CE_JE_MAPPINGS.gl_account_ccid%TYPE;
jem_reference_txt	CE_JE_MAPPINGS.REFERENCE_TXT%TYPE;
jem_exchange_rate_type GL_DAILY_RATES.conversion_type%TYPE;
jem_exchange_rate_date GL_DAILY_RATES.conversion_date%TYPE;

-- added for R12
jem_trxn_subtype_code_id	CE_JE_MAPPINGS.trxn_subtype_code_id%TYPE;

--
-- SLA event id
--
sla_event_id		NUMBER(15);

--
-- CE system parameters variables
--
sys_currency_code FND_CURRENCIES.currency_code%TYPE;
sys_exchange_rate_type GL_DAILY_RATES.conversion_type%TYPE;
sys_exchange_rate_date VARCHAR2(10); --CE_SYSTEM_PARAMETERS.exchange_rate_date%TYPE;
sys_sob_id GL_SETS_OF_BOOKS.set_of_books_id%TYPE;

--
-- Cashflow variables
--
cf_ledger_id		CE_SYSTEM_PARAMETERS.set_of_books_id%TYPE;
cf_legal_entity_id	NUMBER(15);
cf_bank_account_id	NUMBER(15);
cf_direction		CE_CASHFLOWS.cashflow_direction%TYPE;
cf_currency_code	CE_CASHFLOWS.cashflow_currency_code%TYPE;
cf_cashflow_date 	DATE;
cf_cashflow_amount	CE_CASHFLOWS.cashflow_amount%TYPE;
cf_description		CE_CASHFLOWS.description%TYPE;
cf_trxn_reference_number	CE_CASHFLOWS.trxn_reference_number%TYPE;
cf_bank_trxn_number	CE_CASHFLOWS.bank_trxn_number%TYPE;
cf_source_trxn_type	CE_CASHFLOWS.source_trxn_type%TYPE;
cf_statement_line_id	CE_CASHFLOWS.statement_line_id%TYPE;
cf_actual_value_date	CE_CASHFLOWS.actual_value_date%TYPE;
cf_offset_ccid		CE_CASHFLOWS.offset_ccid%TYPE;
cf_status_code		CE_CASHFLOWS.cashflow_status_code%TYPE;
cf_cleared_date		CE_CASHFLOWS.cleared_date%TYPE;
cf_cleared_amount	CE_CASHFLOWS.cleared_amount%TYPE;
cf_cleared_exchange_rate	CE_CASHFLOWS.cleared_exchange_rate%TYPE;
cf_cleared_exchange_date	CE_CASHFLOWS.cleared_exchange_date%TYPE;
cf_cleared_exchange_rate_type	CE_CASHFLOWS.cleared_exchange_rate_type%TYPE;
cf_base_amount		CE_CASHFLOWS.base_amount%TYPE;
cf_reference_text	CE_CASHFLOWS.reference_text%TYPE;
cf_source_trxn_subtype_code_id	CE_CASHFLOWS.source_trxn_subtype_code_id%TYPE;
cf_bank_account_text	CE_CASHFLOWS.bank_account_text%TYPE;
cf_customer_text	CE_CASHFLOWS.customer_text%TYPE;





/*
je_sob_id 		CE_SYSTEM_PARAMETERS.set_of_books_id%TYPE;
je_accounting_date	DATE;
je_currency_code	FND_CURRENCIES.currency_code%TYPE;
je_date_created		DATE;
je_created_by		NUMBER;
je_code_combination_id	GL_CODE_COMBINATIONS.code_combination_id%TYPE;
je_user_curr_conversion_type	GL_DAILY_RATES.conversion_type%TYPE;
je_curr_conversion_date			GL_DAILY_RATES.conversion_date%TYPE;
je_curr_conversion_rate			GL_DAILY_RATES.conversion_rate%TYPE;
je_entered_cr		CE_STATEMENT_LINES.amount%TYPE;
je_entered_dr		CE_STATEMENT_LINES.amount%TYPE;
je_accounted_cr		CE_STATEMENT_LINES.amount%TYPE;
je_accounted_dr		CE_STATEMENT_LINES.amount%TYPE;
je_reference6		GL_INTERFACE.reference6%TYPE;
je_reference10		GL_INTERFACE.reference10%TYPE;
je_reference21		GL_INTERFACE.reference21%TYPE;
je_accounted_amt   	CE_STATEMENT_LINES.amount%TYPE;
je_entered_amt 	        CE_STATEMENT_LINES.amount%TYPE;
*/

procedure create_journal(	errbuf	OUT NOCOPY    VARCHAR2,
	        retcode OUT NOCOPY    NUMBER,
		p_bank_branch_id 	NUMBER,
		p_bank_account_id	NUMBER,
		p_statement_number_from      VARCHAR2,
		p_statement_number_to        VARCHAR2,
		p_statement_date_from        VARCHAR2,
		p_statement_date_to          VARCHAR2);
		--p_gl_date VARCHAR2,
		--p_report_mode VARCHAR2);
FUNCTION  spec_revision RETURN VARCHAR2;
FUNCTION  body_revision RETURN VARCHAR2;

PROCEDURE log(p_msg varchar2);

END;

 

/
