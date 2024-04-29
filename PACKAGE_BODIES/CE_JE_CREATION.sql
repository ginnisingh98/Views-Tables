--------------------------------------------------------
--  DDL for Package Body CE_JE_CREATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_JE_CREATION" AS
/* $Header: cejecrnb.pls 120.24.12010000.2 2008/08/10 14:27:49 csutaria ship $ */

--
-- Global Variables
--
--g_p_gl_date VARCHAR2(40);
g_p_report_mode CE_LOOKUPS.lookup_code%TYPE;
g_request_id NUMBER(15);
g_p_bank_branch_id	NUMBER(15);
g_p_bank_account_id NUMBER(15);
g_p_statement_number_from CE_STATEMENT_HEADERS.statement_number%TYPE;
g_p_statement_number_to CE_STATEMENT_HEADERS.statement_number%TYPE;
g_p_statement_date_from CE_STATEMENT_HEADERS.statement_date%TYPE;
g_p_statement_date_to CE_STATEMENT_HEADERS.statement_date%TYPE;
g_multi_currency      CE_BANK_ACCOUNTS.multi_currency_allowed_flag%TYPE;

-- Main cursors
--
-- Cursor for bank accounts as per the
-- submitted bank branch parameter
--
CURSOR bank_branch_cursor (p_bank_branch_id	NUMBER,
			   p_bank_account_id	NUMBER)IS
	SELECT
		ba.bank_account_id,
		ba.account_owner_org_id
	FROM	ce_bank_accounts ba
	WHERE
		ba.bank_branch_id = p_bank_branch_id
	AND ba.bank_account_id = NVL(p_bank_account_id, ba.bank_account_id);
--	AND ba.account_type =
--	    CE_AUTO_BANK_MATCH.get_security_account_type(ba.account_type);

--
-- Cursor for statement headers as per the
-- submitted statement numbers and statement
-- dates
--
CURSOR statement_headers_cursor (p_bank_account_id NUMBER,
						p_statement_number_from VARCHAR2,
						p_statement_number_to 	VARCHAR2,
						p_statement_date_from	DATE,
						p_statement_date_to		DATE) IS
	SELECT
		csh.statement_header_id
	FROM
		ce_bank_accounts ba,
		ce_statement_headers csh
	WHERE
		ba.bank_account_id = NVL(p_bank_account_id,ba.bank_account_id)
	AND	csh.bank_account_id = ba.bank_account_id
	AND	csh.statement_number BETWEEN
		NVL(p_statement_number_from,csh.statement_number) AND
		 NVL(p_statement_number_to,csh.statement_number)
	AND	csh.statement_date BETWEEN
		NVL(p_statement_date_from,csh.statement_date) AND
		 NVL(p_statement_date_to,csh.statement_date);

--
-- Cursor for statement lines
--
CURSOR statement_lines_cursor (p_statement_header_id NUMBER) IS
	SELECT
		sl.rowid,
		sl.statement_line_id,
		sl.trx_code_id,
		sl.amount,
		sl.status,
		sl.currency_code,
		NVL(ba.currency_code, sh.currency_code),
		sh.statement_date,
		sh.gl_date,
		ba.currency_code,
		sl.effective_date,
		sl.trx_date,
		sl.trx_type,
		sl.original_amount,
		sl.exchange_rate_type,
		sl.exchange_rate,
		sl.exchange_rate_date,
		--sl.je_status_flag,
		sl.trx_text,
		sh.statement_header_id,
		sh.bank_account_id,
		jem.gl_account_ccid,
		jem.search_string_txt,
		jem.reference_txt,
		--cc.asset_code_combination_id,
		sl.bank_trx_number,
		sl.bank_account_text,
		sl.customer_text,
		sl.cashflow_id,
		-- ba.asset_code_combination_id
		ba.multi_currency_allowed_flag,
		jem.trxn_subtype_code_id
	FROM
		ce_statement_lines sl,
		ce_statement_headers sh,
		-- ap_bank_accounts ba,
		ce_bank_accounts ba,
		ce_je_mappings_v jem
                --ce_bank_acct_uses_all use,
		--ce_gl_accounts_ccid cc
	WHERE
		sh.statement_header_id = p_statement_header_id AND
		sl.statement_header_id = sh.statement_header_id AND
		NVL(sh.statement_complete_flag,'N') = 'N' AND
		ba.bank_account_id = sh.bank_account_id AND
		-- ba.account_type = 'INTERNAL' AND
		jem.bank_account_id = sh.bank_account_id AND
		--cc.bank_acct_use_id = use.bank_acct_use_id AND
 		--use.bank_account_id = sh.bank_account_id AND
		--use.ce_use_enabled_flag = 'Y' AND
		sl.trx_code = jem.trx_code AND
		sl.status = 'UNRECONCILED' AND
		--NVL(sl.je_status_flag,'S') <> 'C' AND
		(sl.trx_text like jem.search_string_txt OR
		 jem.search_string_txt is null)
	ORDER BY
		sl.statement_line_id, jem.trx_code_id, jem.search_string_txt;



  FUNCTION body_revision RETURN VARCHAR2 IS
  BEGIN
	RETURN '$Revision: 120.24.12010000.2 $';
  END body_revision;

  FUNCTION spec_revision RETURN VARCHAR2 IS
  BEGIN
	RETURN G_spec_revision;
  END spec_revision;


  PROCEDURE log(p_msg varchar2) is
  BEGIN
--  FND_FILE.PUT_LINE(FND_FILE.LOG,p_msg);
  cep_standard.debug(p_msg);
  END log;

/* --------------------------------------------------------------------
|  PRIVATE FUNCITON                                                     |
|       valid_accounting_date
|  DESCRIPTION															|
|	This function returns true if the accouting date
|	falls in an open or future-enterable period in GL				|
|                                                                       |
|  HISTORY                                                              |
|       16-SEP-2004        Shaik Vali		Created                 	|
 --------------------------------------------------------------------- */
  FUNCTION valid_accounting_date (p_accounting_date IN DATE)
  RETURN BOOLEAN IS
	  l_count NUMBER;
  BEGIN
	log('>>valid_accounting_date');
	SELECT  count(*)
	INTO	l_count
	FROM	gl_period_statuses glp,
	    	ce_system_parameters sys
	WHERE	glp.set_of_books_id = sys.set_of_books_id
	AND     sys.legal_entity_id = CE_JE_CREATION.ba_legal_entity_id
	AND	glp.closing_status in ('O','F')
	AND	glp.application_id = 101
	AND	glp.adjustment_period_flag = 'N'
	AND	to_char(p_accounting_date,'YYYY/MM/DD') BETWEEN
		to_char(glp.start_date,'YYYY/MM/DD') AND to_char(glp.end_date,'YYYY/MM/DD');

	IF l_count > 0 THEN
		RETURN true;
	END IF;
	log('<<valid_accounting_date');
	RETURN FALSE;

  END valid_accounting_date;

/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       Determine_cleared_date						|
|  DESCRIPTION								|
|       This procedure determines the cleared_date, which is used	|
|	as the accounting date when creating accounting event.		|
|       The cleared_date is determined as				|
|       1) statement line Effective_date or				|
|       2) statement line Trx_date					|
|	If the date is not in an open or future period, raise an error	|
|                                                                       |
|  HISTORY                                                              |
|       28-JUL-2004        xxwang 	Created                         |
 --------------------------------------------------------------------- */
  PROCEDURE Determine_cleared_date (p_result IN OUT NOCOPY VARCHAR2) IS
  BEGIN
        log('>>Determine_cleared_date');
        IF CE_JE_CREATION.csl_effective_date IS NOT NULL THEN
	   CE_JE_CREATION.cf_cleared_date := CE_JE_CREATION.csl_effective_date;
           log('cleared date sl effective date: ' || CE_JE_CREATION.cf_cleared_date);
	ELSE
	   CE_JE_CREATION.cf_cleared_date := CE_JE_CREATION.csl_trx_date;
	   log('cleared date sl trx date: ' || CE_JE_CREATION.cf_cleared_date);
  	END IF;

	IF valid_accounting_date(CE_JE_CREATION.cf_cleared_date) THEN
	   p_result := 'S';
	   log('cleared date is in a open or future period');
	ELSE
	   p_result := 'F';
	   log('cleared date is not in an open or future period');
	END IF;
        log('<<Determine_cleared_date');
  EXCEPTION
  WHEN OTHERS THEN
        log('Exception in Determine_cleared_date');
	RAISE;
  END Determine_cleared_date;


/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       Valid_GL_account
|  DESCRIPTION															|
|	This procedure validates that the GL account is valid.
|                                                                       |
|  HISTORY                                                              |
|       16-SEP-2004        Shaik Vali		Created                 	|
 --------------------------------------------------------------------- */
  PROCEDURE Validate_GL_account(p_gl_account_ccid IN NUMBER,
						p_result IN OUT NOCOPY VARCHAR2) IS
	l_enabled_flag CHAR(1);
	l_detail_posting_allowed_flag CHAR(1);
	l_start_date_active DATE;
	l_end_date_active DATE;
	l_count NUMBER;
  BEGIN
	p_result := 'S';
	log('>>Validate_GL_account');
	SELECT count(1)
	INTO	l_count
	FROM
		gl_code_combinations
	WHERE
		code_combination_id = p_gl_account_ccid;
	IF l_count =1 THEN
		p_result := 'S';
	ELSE
		p_result := 'E';
	END IF;
	log('<<Validate_GL_account');
  EXCEPTION
  WHEN OTHERS THEN
	p_result := 'E';
	log('Exception Validate_GL_account');
	log(SQLCODE || substr(SQLERRM, 1, 100));
	RAISE;
  END Validate_GL_account;

/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                   |
|       Initialize_CF_data
|  DESCRIPTION															|
|	This procedure sets the CF variables to NULL
|                                                                       |
|  HISTORY                                                              |
|       16-SEP-2004        Shaik Vali		Created                 	|
 --------------------------------------------------------------------- */
  PROCEDURE Initialize_CF_data IS
  BEGIN
	CE_JE_CREATION.cf_ledger_id := NULL;
	CE_JE_CREATION.cf_legal_entity_id := NULL;
	CE_JE_CREATION.cf_bank_account_id := NULL;
	CE_JE_CREATION.cf_direction := NULL;
	CE_JE_CREATION.cf_currency_code := NULL;
	CE_JE_CREATION.cf_cashflow_date := NULL;
	CE_JE_CREATION.cf_cashflow_amount := NULL;
	CE_JE_CREATION.cf_description := NULL;
	CE_JE_CREATION.cf_trxn_reference_number := NULL;
	CE_JE_CREATION.cf_bank_trxn_number := NULL;
	CE_JE_CREATION.cf_source_trxn_type := NULL;
	CE_JE_CREATION.cf_statement_line_id := NULL;
	CE_JE_CREATION.cf_actual_value_date := NULL;
	CE_JE_CREATION.cf_offset_ccid := NULL;
	CE_JE_CREATION.cf_status_code := NULL;
	CE_JE_CREATION.cf_cleared_date := NULL;
	CE_JE_CREATION.cf_cleared_amount := NULL;
	CE_JE_CREATION.cf_cleared_exchange_rate := NULL;
	CE_JE_CREATION.cf_cleared_exchange_date := NULL;
	CE_JE_CREATION.cf_cleared_exchange_rate_type := NULL;
	CE_JE_CREATION.cf_base_amount := NULL;
	CE_JE_CREATION.cf_reference_text := NULL;
	CE_JE_CREATION.cf_source_trxn_subtype_code_id := NULL;
	CE_JE_CREATION.cf_bank_account_text := NULL;
	CE_JE_CREATION.cf_customer_text := NULL;

  END Initialize_CF_data;


/* ---------------------------------------------------------------------|
|  PRIVATE FUNCTION							|
|       Currency_type							|
|  DESCRIPTION                                                          |
|       This function returns the currency type: 			|
|       DOMESTIC, INTERNATIONAL, FOREIGN.                               |
|                                                                       |
|  HISTORY                                                              |
|       28-JUL-2004        xxwang       Created                         |
 --------------------------------------------------------------------- */
  FUNCTION Currency_type RETURN VARCHAR2 IS
	l_type VARCHAR2(30);
  BEGIN
        log('>> Currency_type');

	IF (CE_JE_CREATION.sys_currency_code = CE_JE_CREATION.ba_currency_code) THEN
	   IF (CE_JE_CREATION.ba_currency_code = NVL(CE_JE_CREATION.csl_currency_code, CE_JE_CREATION.csh_currency_code)) THEN
	      l_type := 'DOMESTIC';
	   ELSE
	      l_type := 'INTERNATIONAL';
 	   END IF;
  	ELSE
	   l_type := 'FOREIGN';
	END IF;
	return l_type;
	log('<< Currency_type');

  END Currency_type;

/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       Validate_Multi_Currency
|  DESCRIPTION								|
|	This procedure validates that if statement line currency is
|       different from bank account currency which is also functional   |
|       currency then bank account should be multi currency enabled     |
|  HISTORY                                                              |
|       31-May-2006       Jinesh Kumar		Created                 	|
 --------------------------------------------------------------------- */
PROCEDURE Validate_Multi_Currency(p_result IN OUT NOCOPY VARCHAR2) IS
	l_multi	VARCHAR2(1);
BEGIN
	p_result := 'S';
	IF (Currency_Type = 'INTERNATIONAL') THEN
	   IF (nvl(g_multi_currency,'N') = 'Y') THEN
		p_result := 'S';
	   ELSE
		p_result := 'E';
	   END IF;
	END IF;
EXCEPTION
	WHEN OTHERS THEN
	 p_result := 'E';
	 RAISE;
END Validate_Multi_Currency;

/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       Determine_exchnage_info						|
|  DESCRIPTION                                                          |
|       This procedure determines the cleared exchange info as follows: |
|	1) Domestic and International:					|
|	    these fields are null;					|
|	2) Foreign:							|
|	    i)  use stmt line exchange info;				|
|	    ii) if stmt line has no exchange info, get type and date  	|
|	        from sys param, and calculate rate			|
|                                                                       |
|  HISTORY                                                              |
|       28-JUL-2004        xxwang       Created                         |
 --------------------------------------------------------------------- */
  PROCEDURE Determine_exchange_info (p_result  IN OUT NOCOPY VARCHAR2) IS
  	l_xchange_rate_date VARCHAR2(10); --CE_SYSTEM_PARAMETERS.exchange_rate_date%TYPE;
        l_xchange_rate_type GL_DAILY_RATES.conversion_type%TYPE;
        l_xchange_rate GL_DAILY_RATES.conversion_rate%TYPE;
	precision			NUMBER;
	ext_precision			NUMBER;
	min_acct_unit			NUMBER;
  BEGIN

	p_result := 'S';

	IF (Currency_type = 'FOREIGN') THEN
	   IF CE_JE_CREATION.csl_exchange_rate is NOT NULL THEN
	      CE_JE_CREATION.cf_cleared_exchange_rate := CE_JE_CREATION.csl_exchange_rate;
	      CE_JE_CREATION.cf_cleared_exchange_date := CE_JE_CREATION.csl_exchange_rate_date;
	      CE_JE_CREATION.cf_cleared_exchange_rate_type := CE_JE_CREATION.csl_exchange_rate_type;
	      -- Bug 6980331: Cashflow amount was not being set for FOREIGN
	      -- currency_type when the exchange rate was given manually.
	      CE_JE_CREATION.cf_cashflow_amount := CE_JE_CREATION.csl_amount;
	   ELSE
	      l_xchange_rate_date := CE_JE_CREATION.sys_exchange_rate_date;
	      log('sys xchange_rate_date='||l_xchange_rate_date);
              CE_JE_CREATION.cf_cleared_exchange_rate_type := CE_JE_CREATION.sys_exchange_rate_type;
              IF (l_xchange_rate_date = 'CFD') THEN
                CE_JE_CREATION.cf_cleared_exchange_date :=
		  CE_JE_CREATION.csl_trx_date;
              ELSIF (l_xchange_rate_date = 'BSG') THEN
                CE_JE_CREATION.cf_cleared_exchange_date :=
		  CE_JE_CREATION.cf_cleared_date;
              ELSIF (l_xchange_rate_date = 'CLD') THEN
                CE_JE_CREATION.cf_cleared_exchange_date :=
		  CE_JE_CREATION.cf_cleared_date;    -- CE_JE_CREATION.cf_cleared_date has already been
						     -- determined at this point.
              ELSIF (l_xchange_rate_date = 'BSD') THEN
                CE_JE_CREATION.cf_cleared_exchange_date :=
                CE_JE_CREATION.csh_statement_date;
              ELSE
                -- error: exchange date cannot be determined
                p_result := 'F';
              END IF;

	      IF (p_result <> 'F') THEN
		log('calling gl_currency_api');
        log('>>Determine_exchange_info');
	log('ba_curr='||ce_je_Creation.ba_currency_code);
	log('sys_curr='||ce_je_creation.sys_currency_code);
	log('cf_clared_ex_date='||ce_je_creation.cf_cleared_exchange_date);
	log('stmt_line_id='||ce_je_creation.csl_statement_line_id);
      log('cf_cleared_ex_type='||ce_je_creation.cf_cleared_exchange_rate_type);

	        CE_JE_CREATION.cf_cleared_exchange_rate :=
			gl_currency_api.get_rate(CE_JE_CREATION.ba_currency_code,
					 	 CE_JE_CREATION.sys_currency_code,
					 	 CE_JE_CREATION.cf_cleared_exchange_date,
					 	 CE_JE_CREATION.cf_cleared_exchange_rate_type);
	        CE_JE_CREATION.cf_cashflow_amount := CE_JE_CREATION.csl_amount;
	      END IF;
	   END IF;
  	ELSE -- domestic and international
	   CE_JE_CREATION.cf_cleared_exchange_rate := null;
	   CE_JE_CREATION.cf_cleared_exchange_date := null;
	   CE_JE_CREATION.cf_cleared_exchange_rate_type := null;
	--Bug 5016835
        IF (currency_type = 'INTERNATIONAL') THEN
           CE_JE_CREATION.cf_cashflow_amount :=
			CE_JE_CREATION.csl_original_amount;
	  IF (CE_JE_CREATION.cf_Cashflow_amount is null) then
	      IF (CE_JE_CREATION.csl_exchange_rate IS NOT NULL) THEN

		--bug5328385
		If (CE_JE_CREATION.csl_exchange_rate_type <> 'User') THEN
		   CE_JE_CREATION.cf_cashflow_amount:= gl_currency_api.convert_amount(
							  CE_JE_CREATION.sys_currency_code,
							  CE_JE_CREATION.csl_currency_code,
							  nvl(CE_JE_CREATION.csl_exchange_rate_date,
							      CE_JE_CREATION.csl_trx_date),
							  CE_JE_CREATION.csl_exchange_rate_type,
							  CE_JE_CREATION.csl_amount);
		ELSE
    		  fnd_currency.get_info(CE_JE_CREATION.csl_currency_code,
		      precision, ext_precision, min_acct_unit);
		  CE_JE_CREATION.cf_cashflow_amount :=
   	  	  		round(CE_JE_CREATION.csl_amount/CE_JE_CREATION.csl_exchange_rate,precision);
		END IF;
	      ELSE
		p_result := 'F';
	      END IF;
	  END IF;
        ELSE
           CE_JE_CREATION.cf_cashflow_amount := CE_JE_CREATION.csl_amount;
        END IF;
        END IF;
	log('<<Determine_exchange_info');
  EXCEPTION
        WHEN OTHERS THEN
        log('EXCEPTION in Determine_exchange_info');
        log(SQLCODE || substr(SQLERRM, 1, 100));
	RAISE;
  END Determine_exchange_info;


/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       Determine_base_amount						|
|  DESCRIPTION                                                          |
|       This procedure determines the base amount as follows: 		|
|       1) Domestic and International:                                    |
|           statement_lines.amount;                                     |
|       2) Foreign:                                                     |
|	    statement_lines.amount/exchange_rate
|                                                                       |
|  HISTORY                                                              |
|       28-JUL-2004        xxwang       Created                         |
 --------------------------------------------------------------------- */
  PROCEDURE Determine_base_amount IS
  BEGIN
        log('>>Determine_base_amount');
	IF Currency_type = 'FOREIGN' THEN
	   CE_JE_CREATION.cf_base_amount :=
		CE_JE_CREATION.csl_amount / CE_JE_CREATION.cf_cleared_exchange_rate;
	ELSE
	   CE_JE_CREATION.cf_base_amount := CE_JE_CREATION.csl_amount;
	END IF;
        log('>>Determine_base_amount');
  END Determine_base_amount;


/* ---------------------------------------------------------------------|
|  PRIVATE PROCEDURE                                                    |
|       Populate_CF_data						|
|  DESCRIPTION								|
|       This procedure gathers the data required to put into            |
|       the CE_CASHFLOWS table. 					|
|                                                                       |
|  HISTORY                                                              |
|       28-JUL-2004        xxwang	Created                         |
 --------------------------------------------------------------------- */
  PROCEDURE Populate_CF_data IS
  BEGIN
	log('>> Populate_CF_data');
	CE_JE_CREATION.cf_ledger_id := CE_JE_CREATION.sys_sob_id;
	CE_JE_CREATION.cf_legal_entity_id := CE_JE_CREATION.ba_legal_entity_id;
	CE_JE_CREATION.cf_bank_account_id := CE_JE_CREATION.csh_bank_account_id;
	IF (CE_JE_CREATION.csl_trx_type = 'CREDIT') or
	   (CE_JE_CREATION.csl_trx_type = 'MISC_CREDIT') THEN
	   CE_JE_CREATION.cf_direction := 'RECEIPT';
        ELSIF (CE_JE_CREATION.csl_trx_type = 'DEBIT') or
	      (CE_JE_CREATION.csl_trx_type = 'MISC_DEBIT') THEN
	   CE_JE_CREATION.cf_direction := 'PAYMENT';
	END IF;
	IF currency_type = 'INTERNATIONAL' THEN
	   CE_JE_CREATION.cf_currency_code := CE_JE_CREATION.csl_currency_code;
	ELSE
	   CE_JE_CREATION.cf_currency_code := CE_JE_CREATION.csh_currency_code;
	END IF;
	CE_JE_CREATION.cf_cashflow_date := CE_JE_CREATION.csl_trx_date;
	CE_JE_CREATION.cf_description := CE_JE_CREATION.csl_trx_text;
	CE_JE_CREATION.cf_bank_trxn_number := CE_JE_CREATION.csl_bank_trx_number;
	CE_JE_CREATION.cf_source_trxn_type := 'STMT';
	CE_JE_CREATION.cf_statement_line_id := CE_JE_CREATION.csl_statement_line_id;
	CE_JE_CREATION.cf_actual_value_date := NVL(CE_JE_CREATION.csl_effective_date,
						   CE_JE_CREATION.csl_trx_date);
	CE_JE_CREATION.cf_offset_ccid := CE_JE_CREATION.jem_gl_account_ccid;
	CE_JE_CREATION.cf_status_code := 'CLEARED';
	CE_JE_CREATION.cf_cleared_amount := CE_JE_CREATION.csl_amount;
	CE_JE_CREATION.cf_source_trxn_subtype_code_id := CE_JE_CREATION.jem_trxn_subtype_code_id;
	CE_JE_CREATION.cf_reference_text := CE_JE_CREATION.jem_reference_txt;
	CE_JE_CREATION.cf_bank_account_text := CE_JE_CREATION.csl_bank_account_text;
	CE_JE_CREATION.cf_customer_text := CE_JE_CREATION.csl_customer_text;

	log('<< Populate_CF_data');
  EXCEPTION
        WHEN OTHERS THEN
        log('EXCEPTION is Populate_CF_data');
        log(SQLCODE || substr(SQLERRM, 1, 100));
	RAISE;
  END Populate_CF_data;


/* ---------------------------------------------------------------------|
|  PRIVATE PROCEDURE                                                    |
|       Populate_CF_table                                               |
|  DESCRIPTION                                                          |
|       This procedure inserts data into CE_CASHFLOWS table		|
|                                                                       |
|  HISTORY                                                              |
|       29-JUL-2004        xxwang       Created                         |
 --------------------------------------------------------------------- */
  PROCEDURE Populate_CF_table (x_cashflow_id  OUT NOCOPY NUMBER) IS
	x_rowid		VARCHAR2(1000);
  BEGIN
        log('>> Populate_CF_table');
	CE_CASHFLOWS_PKG.insert_row (
				x_rowid,
				x_cashflow_id,
				CE_JE_CREATION.cf_ledger_id,
				CE_JE_CREATION.cf_legal_entity_id,
                                CE_JE_CREATION.cf_bank_account_id,
                                CE_JE_CREATION.cf_direction,
                                CE_JE_CREATION.cf_currency_code,
                                CE_JE_CREATION.cf_cashflow_date,
                                CE_JE_CREATION.cf_cashflow_amount,
                                CE_JE_CREATION.cf_base_amount,
                                CE_JE_CREATION.cf_description,
                                null,   -- cashflow_exchange_rate
                                null,   -- cashflow_exchange_date
                                null,   -- cashflow_exchange_rate_type
                                CE_JE_CREATION.cf_trxn_reference_number,
                                CE_JE_CREATION.cf_bank_trxn_number,
                                CE_JE_CREATION.cf_source_trxn_type,
                                CE_JE_CREATION.cf_source_trxn_subtype_code_id,
                                CE_JE_CREATION.cf_statement_line_id,
                                CE_JE_CREATION.cf_actual_value_date,
                                null,   -- counterparty_party_id
                                null,   -- counterparty_bank_account_id
                                CE_JE_CREATION.cf_offset_ccid,
                                CE_JE_CREATION.cf_status_code,
                                CE_JE_CREATION.cf_cleared_date,
                                CE_JE_CREATION.cf_cleared_amount,
                                CE_JE_CREATION.cf_cleared_exchange_rate,
                                CE_JE_CREATION.cf_cleared_exchange_date,
                                CE_JE_CREATION.cf_cleared_exchange_rate_type,
                                null,   -- clearing_charges_amount
                                null,   -- clearing_error_amount
                                null,   -- cleared_by_flag
                                CE_JE_CREATION.cf_reference_text,
                                CE_JE_CREATION.cf_bank_account_text,
                                CE_JE_CREATION.cf_customer_text,
				NVL(FND_GLOBAL.user_id,-1),
                        	sysdate,
                                NVL(FND_GLOBAL.user_id,-1),
                        	sysdate,
                        	NVL(FND_GLOBAL.user_id,-1));
	log('<<Populate_CF_table');
  EXCEPTION
  WHEN OTHERS THEN
   log('Exception in Populate_CF_table');
   log(SQLCODE || substr(SQLERRM, 1, 100));
   RAISE;
  END Populate_CF_table;



/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE 													|
|	lock_statement_line												|
|									 							|
|  DESCRIPTION															|
|	Lock the statement line before processing						|
|                                                                       |
|  HISTORY                                                              |
|       26-SEP-2004        Shaik Vali		Created                 	|
|--------------------------------------------------------------------- */
  FUNCTION lock_statement_line RETURN BOOLEAN IS
	l_dummy NUMBER;
  BEGIN
	log('>>lock_statement_line');
	SELECT 1
	INTO	l_dummy
	FROM
		ce_statement_lines
	WHERE	rowid = CE_JE_CREATION.csl_rowid
	FOR UPDATE OF je_status_flag NOWAIT;

	RETURN true;
	log('<<lock_statement_line');
  EXCEPTION
  WHEN OTHERS THEN
	log('Exception in lock_statement_line');
	log(SQLCODE || substr(SQLERRM, 1, 100));
	RETURN false;
  END;


/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       Update_statement_line
|  DESCRIPTION
|	This procedure updates the cashflow_id
|                                                                       |
|  HISTORY                                                              |
|       16-SEP-2004        Shaik Vali		Created                 	|
 --------------------------------------------------------------------- */
  PROCEDURE Update_statement_line(p_statement_line_id IN NUMBER,
				  p_cashflow_id	      IN NUMBER,
				  p_je_status_flag IN VARCHAR2) IS
  BEGIN
	UPDATE  ce_statement_lines
	SET	cashflow_id = p_cashflow_id,
		je_status_flag = p_je_status_flag
	WHERE   statement_line_id = p_statement_line_id;
  END Update_statement_line;


/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       Process_statement_line 											|
|  DESCRIPTION															|
|	This procedure processes each statement line:					|
|	1)Validate and Identify accounting date							|
|	2)Validate the GL account										|
|	3)If PREVIEW mode then only gether the JE data.					|
|	4)IF ACTUAL mode then gather JE data and also populate			|
|	  the gl interface. 											|
|	5)update the statement line										|
|                                                                       |
|  HISTORY                                                              |
|       21-SEP-2004        Shaik Vali		Created                 	|
 --------------------------------------------------------------------- */
  PROCEDURE Process_statement_line IS
  	l_result VARCHAR2(50);
	l_cashflow_id	NUMBER;
  BEGIN
	log('>>Process_statement_line');
	Initialize_cf_data;
	Determine_cleared_date(l_result);
	IF (l_result = 'S') THEN
	  Determine_exchange_info(l_result);
	  IF(l_result = 'S') THEN
	   Validate_Multi_Currency(l_result);
	   IF (l_result = 'S') THEN
	    Validate_GL_account(CE_JE_CREATION.jem_gl_account_ccid,l_result);
	    IF(l_result = 'S') THEN
		Determine_base_amount;
		--
		-- validations are done. now
		-- Gather the data for the JE from
		-- the stmt line.
	 	Populate_CF_data;
	     	Populate_CF_table(l_cashflow_id);
                -- insert cashflow_id into statement_line table
		Update_statement_line(CE_JE_CREATION.csl_statement_line_id,
					l_cashflow_id,'S');
		-- create accounting event
		CE_XLA_ACCT_EVENTS_PKG.create_event(l_cashflow_id,
						    'CE_STMT_RECORDED',
						    null);
		/* Bug 4997215 -- populated error messages table even for
		   successes with a dummy error message.*/
	 	CE_JE_CREATION_ERRORS_PKG.insert_row(
			CE_JE_CREATION.csh_statement_header_id,
			CE_JE_CREATION.csl_statement_line_id,
			'DUMMY',
			NVL(FND_GLOBAL.user_id,-1),
			sysdate,
			sysdate,
			NVL(FND_GLOBAL.user_id,-1),
			NVL(FND_GLOBAL.user_id,-1),
			g_request_id);

 	    ELSE -- Invalid gl account
 		 Update_statement_line(CE_JE_CREATION.csl_statement_line_id,
					null,'E');
	 	CE_JE_CREATION_ERRORS_PKG.insert_row(
			CE_JE_CREATION.csh_statement_header_id,
			CE_JE_CREATION.csl_statement_line_id,
			'CE_INVALID_GL_ACCOUNT',
			NVL(FND_GLOBAL.user_id,-1),
			sysdate,
			sysdate,
			NVL(FND_GLOBAL.user_id,-1),
			NVL(FND_GLOBAL.user_id,-1),
			g_request_id);
		log('invalid gl account');
	    END IF;
	   ELSE  --bank account not multi currency enabled
		Update_statement_line(CE_JE_CREATION.csl_statement_line_id,
                                        null,'E');
                CE_JE_CREATION_ERRORS_PKG.insert_row(
                        CE_JE_CREATION.csh_statement_header_id,
                        CE_JE_CREATION.csl_statement_line_id,
                        'CE_NOT_MULTI_CURR',
                        NVL(FND_GLOBAL.user_id,-1),
                        sysdate,
                        sysdate,
                        NVL(FND_GLOBAL.user_id,-1),
                        NVL(FND_GLOBAL.user_id,-1),
                        g_request_id);
	   END IF;
	  ELSE -- exchange info cannot be determined
	 	 Update_statement_line(CE_JE_CREATION.csl_statement_line_id,
			 null,'E');
	         CE_JE_CREATION_ERRORS_PKG.insert_row(
                        CE_JE_CREATION.csh_statement_header_id,
                        CE_JE_CREATION.csl_statement_line_id,
                        'CE_MISSING_USER_RATE',
                        NVL(FND_GLOBAL.user_id,-1),
                        sysdate,
                        sysdate,
                        NVL(FND_GLOBAL.user_id,-1),
                        NVL(FND_GLOBAL.user_id,-1),
                        g_request_id);
            log('Exchange info cannot be determined.');
	  END IF;
	ELSE -- invalid cleared date
	          Update_statement_line(CE_JE_CREATION.csl_statement_line_id,
				null,'E');
		   CE_JE_CREATION_ERRORS_PKG.insert_row(
			CE_JE_CREATION.csh_statement_header_id,
			CE_JE_CREATION.csl_statement_line_id,
			'CE_INVALID_CLEARED_DATE',
			NVL(FND_GLOBAL.user_id,-1),
			sysdate,
			sysdate,
			NVL(FND_GLOBAL.user_id,-1),
			NVL(FND_GLOBAL.user_id,-1),
			g_request_id);
	  log('invalid accounting date');
	END IF;
	log('<<Process_statement_line');
  EXCEPTION
  WHEN OTHERS THEN
	log('EXCEPTION in processing statement line');
	log(SQLCODE || substr(SQLERRM, 1, 100));
	RAISE;
  END Process_statement_line;




/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       create_journal													|
|                                                                       |
|  HISTORY                                                              |
|       20-SEP-2004        Shaik Vali		Created                		|
 --------------------------------------------------------------------- */
  PROCEDURE create_journal (
		errbuf	OUT NOCOPY    VARCHAR2,
	        retcode OUT NOCOPY    NUMBER,
		p_bank_branch_id 	NUMBER,
		p_bank_account_id	NUMBER,
		p_statement_number_from      VARCHAR2,
		p_statement_number_to        VARCHAR2,
		p_statement_date_from        VARCHAR2,
		p_statement_date_to          VARCHAR2) IS
		--p_gl_date VARCHAR2,
		--p_report_mode VARCHAR2) IS
  	l_last_statement_line_id CE_STATEMENT_LINES.statement_line_id%TYPE := -1;
	l_statement_header_id CE_STATEMENT_HEADERS.statement_header_id%TYPE;
	l_bank_account_id	CE_BANK_ACCOUNTS.bank_account_id%TYPE;
	l_result	VARCHAR2(50);
	l_req_id NUMBER;
  BEGIN
	log('>> create_journal');

  -- populate ce_security_profiles_gt table with ce_security_procfiles_v
  CEP_STANDARD.init_security;

	g_p_bank_branch_id := p_bank_branch_id;
	g_p_bank_account_id := p_bank_account_id;
	g_p_statement_number_from := p_statement_number_from;
	g_p_statement_number_to	  := p_statement_number_to;
	g_p_statement_date_from	:= to_date(p_statement_date_from,'YYYY/MM/DD HH24:MI:SS');
	g_p_statement_date_to	:= to_date(p_statement_date_to,'YYYY/MM/DD HH24:MI:SS');
	--g_p_gl_date := to_char(to_date(p_gl_date,'YYYY/MM/DD HH24:MI:SS'));
	--g_p_report_mode := p_report_mode;
	g_request_id := FND_GLOBAL.CONC_REQUEST_ID;

	--
	-- fetch the bank accounts for the submitted
	-- bank branch (and) bank account
	--
	OPEN bank_branch_cursor(g_p_bank_branch_id,g_p_bank_account_id);
	LOOP
	FETCH bank_branch_cursor
	INTO  l_bank_account_id,
	      CE_JE_CREATION.ba_legal_entity_id;
	EXIT WHEN bank_branch_cursor%NOTFOUND OR
		  bank_branch_cursor%NOTFOUND IS NULL;
            BEGIN
		SELECT  sob.currency_code,
			sys.bsc_exchange_date_type,
			sys.cashflow_exchange_rate_type,
			--xle.ledger_id
			sys.set_of_books_id
		INTO
			CE_JE_CREATION.sys_currency_code,
			CE_JE_CREATION.sys_exchange_rate_date,
			CE_JE_CREATION.sys_exchange_rate_type,
			CE_JE_CREATION.sys_sob_id
		FROM
			ce_system_parameters sys,   -- change to base table per BH's request
			gl_sets_of_books sob,
			ce_bank_accounts ba
			--xle_fp_ou_ledger_v xle
		WHERE
			sys.set_of_books_id = sob.set_of_books_id
		AND	sys.legal_entity_id = ba.account_owner_org_id
		AND	ba.bank_account_id = l_bank_account_id;
	    EXCEPTION
    		WHEN NO_DATA_FOUND THEN
		  cep_standard.debug('Legal enityt is not set up in System parameters');
            END;

		--
		-- fetch the statement headers the bank account
		-- from the bank cursor and submitted stmt
		-- numbers and statement dates

	    OPEN statement_headers_cursor(l_bank_account_id,
							  g_p_statement_number_from,
							  g_p_statement_number_to,
						  	  g_p_statement_date_from,
							  g_p_statement_date_to);
   	    LOOP
	    FETCH statement_headers_cursor INTO l_statement_header_id;
	    EXIT WHEN statement_headers_cursor%NOTFOUND OR
			  statement_headers_cursor%NOTFOUND IS NULL;

		--
		-- fetch the statement lines for the header
		-- from the headers cursor
		--
		OPEN statement_lines_cursor(l_statement_header_id);
		LOOP
		FETCH statement_lines_cursor INTO
			CE_JE_CREATION.csl_rowid,
			CE_JE_CREATION.csl_statement_line_id,
			CE_JE_CREATION.csl_trx_code_id,
			CE_JE_CREATION.csl_amount,
			CE_JE_CREATION.csl_status,
			CE_JE_CREATION.csl_currency_code,
			CE_JE_CREATION.csh_currency_code,
			CE_JE_CREATION.csh_statement_date,
			CE_JE_CREATION.csh_statement_gl_date,
			CE_JE_CREATION.ba_currency_code,
			CE_JE_CREATION.csl_effective_date,
			CE_JE_CREATION.csl_trx_date,
			CE_JE_CREATION.csl_trx_type,
			CE_JE_CREATION.csl_original_amount,
			CE_JE_CREATION.csl_exchange_rate_type,
			CE_JE_CREATION.csl_exchange_rate,
			CE_JE_CREATION.csl_exchange_rate_date,
			--CE_JE_CREATION.csl_je_status_flag,
			CE_JE_CREATION.csl_trx_text,
			CE_JE_CREATION.csh_statement_header_id,
			CE_JE_CREATION.csh_bank_account_id,
			CE_JE_CREATION.jem_gl_account_ccid,
			CE_JE_CREATION.jem_search_string_txt,
			CE_JE_CREATION.jem_reference_txt,
			--CE_JE_CREATION.csh_bank_account_ccid,
			CE_JE_CREATION.csl_bank_trx_number,
			CE_JE_CREATION.csl_bank_account_text,
			CE_JE_CREATION.csl_customer_text,
			CE_JE_CREATION.csl_cashflow_id,
			g_multi_currency,
			CE_JE_CREATION.jem_trxn_subtype_code_id;
		EXIT WHEN statement_lines_cursor%NOTFOUND or
		statement_lines_cursor%NOTFOUND IS NULL;


		IF CE_JE_CREATION.csl_cashflow_id IS NULL THEN

		IF CE_JE_CREATION.sys_sob_id IS NULL THEN
	        	CE_JE_CREATION_ERRORS_PKG.insert_row(
				CE_JE_CREATION.csh_statement_header_id,
				CE_JE_CREATION.csl_statement_line_id,
				'CE_NO_BA_LE_IN_SYS',
			NVL(FND_GLOBAL.user_id,-1),
			sysdate,
			sysdate,
			NVL(FND_GLOBAL.user_id,-1),
			NVL(FND_GLOBAL.user_id,-1),
			g_request_id);
			EXIT;
		END IF;
		--
		-- do not process the same statement line again
		-- if it matches more than one JE mapping. its
		-- difficult and performance intensive if we put
		-- this logic in the sql stmt
		--
		IF l_last_statement_line_id <> CE_JE_CREATION.csl_statement_line_id THEN
		IF(lock_statement_line) THEN
			Process_statement_line;
		ELSE
			CE_JE_CREATION_ERRORS_PKG.insert_row(
				CE_JE_CREATION.csh_statement_header_id,
				CE_JE_CREATION.csl_statement_line_id,
				'CE_LINE_LOCKED',
			NVL(FND_GLOBAL.user_id,-1),
			sysdate,
			sysdate,
			NVL(FND_GLOBAL.user_id,-1),
			NVL(FND_GLOBAL.user_id,-1),
			g_request_id);
		END IF;
		l_last_statement_line_id := CE_JE_CREATION.csl_statement_line_id;
	    	END IF;
	      END IF;
   	        END LOOP; -- statement_lines_cursor
		CLOSE statement_lines_cursor;
	     END LOOP; -- statement_headers_cursor
	     CLOSE statement_headers_cursor;
	END LOOP; -- bank_branches_cursor
	CLOSE bank_branch_cursor;

	l_req_id := FND_REQUEST.SUBMIT_REQUEST('CE',
			          'CEJEEXER',
				 	   NULL,
				  	   to_char(sysdate,'YYYY/MM/DD'),
			           FALSE,
					   'P_REQUEST_ID=' || g_request_id,
						'P_BANK_BRANCH_ID=' || g_p_bank_branch_id,
						'P_BANK_ACCOUNT_ID=' || g_p_bank_account_id,
						'P_STAT_NUMBER_FROM=' || g_p_statement_number_from,
						'P_STAT_NUMBER_TO='||g_p_statement_number_to,
						'P_STAT_DATE_FROM=' || g_p_statement_date_from,
						'P_STAT_DATE_TO=' || g_p_statement_date_to);

	COMMIT;
  log('<< create_journal');
  EXCEPTION
  WHEN OTHERS THEN
	log('Exception in create_journal');
	log(SQLCODE || substr(SQLERRM, 1, 100));
	RAISE;
  END create_journal;


END CE_JE_CREATION;

/
