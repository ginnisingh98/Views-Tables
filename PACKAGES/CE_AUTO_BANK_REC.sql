--------------------------------------------------------
--  DDL for Package CE_AUTO_BANK_REC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CE_AUTO_BANK_REC" AUTHID CURRENT_USER AS
/*$Header: ceabrdrs.pls 120.10 2008/01/23 13:19:01 kbabu ship $	*/

--
-- GLOBAL variables
--
-- From CE_SYSTEM_PARAMETERS
--
G_rowid				VARCHAR2(100);
G_chart_of_accounts_id		GL_SETS_OF_BOOKS.chart_of_accounts_id%TYPE;
G_set_of_books_id		CE_SYSTEM_PARAMETERS.set_of_books_id%TYPE;
G_create_misc_flag		VARCHAR2(1);
G_cashbook_begin_date		CE_SYSTEM_PARAMETERS.cashbook_begin_date%TYPE;
G_show_cleared_flag		CE_SYSTEM_PARAMETERS.show_cleared_flag%TYPE;
G_show_void_payment_flag        CE_SYSTEM_PARAMETERS.show_void_payment_flag%TYPE;
G_cr_vat_tax_code		VARCHAR2(50);
G_dr_vat_tax_code		VARCHAR2(50);
G_lines_per_commit		CE_SYSTEM_PARAMETERS.lines_per_commit%TYPE;
G_functional_currency		GL_SETS_OF_BOOKS.currency_code%TYPE;
G_sob_short_name		VARCHAR2(100);
G_account_period_type		VARCHAR2(100);
G_user_exchange_rate_type	VARCHAR2(100);

-- FROM CE_BANK_ACCOUNTS
/* bug 4914608 system parameters move to acct and uses
  move variable to  ceabrmas.pls
G_amount_tolerance		NUMBER;
G_percent_tolerance		NUMBER;*/

G_differences_account		VARCHAR2(30);
--G_foreign_difference_handling  	VARCHAR2(30);

G_open_interface_flag		VARCHAR2(1);
G_interface_purge_flag		VARCHAR2(1);
G_interface_archive_flag 	VARCHAR2(1);
G_line_autocreation_flag 	VARCHAR2(1);
G_ap_matching_order		VARCHAR2(10);
G_ap_matching_order2		VARCHAR2(10);-- FOR SEPA ER 6700007
G_ar_matching_order		VARCHAR2(10);
G_exchange_rate_type		VARCHAR2(30);
G_exchange_rate_date	VARCHAR2(10);
G_float_handling_flag		VARCHAR2(1);
G_open_interface_float_status   VARCHAR2(30);
G_open_interface_clear_status   VARCHAR2(30);
G_open_interface_matching_code  VARCHAR2(30);

-- FROM CE_BANK_ACCT_USES_ALL

G_receivables_trx_id		NUMBER(15);
G_receivables_trx_dsp		VARCHAR2(100);


--
-- Passed as parameters
--
G_option			FND_LOOKUP_VALUES.lookup_code%TYPE;
G_bank_branch_id		CE_BANK_ACCOUNTS.bank_branch_id%TYPE;
G_bank_account_id   		CE_BANK_ACCOUNTS.bank_account_id%TYPE;
G_statement_number_from		CE_STATEMENT_HEADERS.statement_number%TYPE;
G_statement_number_to		CE_STATEMENT_HEADERS.statement_number%TYPE;
G_statement_date_from		CE_STATEMENT_HEADERS.statement_date%TYPE;
G_statement_date_to		CE_STATEMENT_HEADERS.statement_date%TYPE;
G_gl_date			CE_SYSTEM_PARAMETERS.cashbook_begin_date%TYPE;
G_gl_date_original		CE_SYSTEM_PARAMETERS.cashbook_begin_date%TYPE;
G_payment_method_id		NUMBER;
G_nsf_handling			FND_LOOKUP_VALUES.lookup_code%TYPE;
G_display_debug			FND_LOOKUP_VALUES.lookup_code%TYPE;
G_debug_path			VARCHAR(100);
G_debug_file			VARCHAR(100);
G_payment_method_name		AR_RECEIPT_METHODS.name%TYPE;
G_intra_day_flag		VARCHAR2(1);
G_ce_debug_flag         VARCHAR2(1); /* Bug 3364143 added this variable */
G_org_id			NUMBER;
G_legal_entity_id		NUMBER;

-- bug 4436028 BAT

G_CE_DIFFERENCES_ACCOUNT 	VARCHAR2(30);
G_CASHFLOW_EXCHANGE_RATE_TYPE	VARCHAR2(30);
G_AUTHORIZATION_BAT		VARCHAR2(30);

-- bug 4572139
G_BSC_EXCHANGE_DATE_TYPE	VARCHAR2(10);
G_BAT_EXCHANGE_DATE_TYPE	VARCHAR2(10);

--
-- Tables storing the open and future enterable periods of ap and ar
--
TYPE period_type IS TABLE OF GL_PERIOD_STATUSES.period_name%TYPE
	INDEX BY BINARY_INTEGER;
TYPE date_type  IS TABLE OF GL_PERIOD_STATUSES.start_date%TYPE
	INDEX BY BINARY_INTEGER;

--
-- Profile options
--
G_sequence_numbering	VARCHAR2(1);
G_inverse_rate		VARCHAR2(1);
--
-- Misc needed stuff
--
G_spec_revision 	VARCHAR2(1000) := '$Revision: 120.10 $';

/* $Header: ceabrdrs.pls 120.10 2008/01/23 13:19:01 kbabu ship $ */

FUNCTION find_gl_period (p_date DATE, p_app_id NUMBER) RETURN BOOLEAN;

FUNCTION spec_revision RETURN VARCHAR2;

FUNCTION body_revision RETURN VARCHAR2;

PROCEDURE statement (	errbuf		     OUT NOCOPY     VARCHAR2,
			retcode		     OUT NOCOPY     NUMBER,
			p_option                     VARCHAR2,
                        p_bank_branch_id	     NUMBER,
			p_bank_account_id            NUMBER,
			p_statement_number_from      VARCHAR2,
			p_statement_number_to        VARCHAR2,
		 	p_statement_date_from	     VARCHAR2,
			p_statement_date_to	     VARCHAR2,
			p_gl_date                    VARCHAR2,
                        p_org_id		     VARCHAR2 DEFAULT NULL,
			p_legal_entity_id	     VARCHAR2 DEFAULT NULL,
                        p_receivables_trx_id         NUMBER,
                        p_payment_method_id          NUMBER,
			p_nsf_handling               VARCHAR2,
			p_display_debug		     VARCHAR2,
			p_debug_path		     VARCHAR2,
			p_debug_file		     VARCHAR2,
			p_intra_day_flag	     VARCHAR2 DEFAULT 'N');

PROCEDURE set_parameters (p_option                   VARCHAR2,
                          p_bank_branch_id	     NUMBER,
			  p_bank_account_id          NUMBER,
			  p_statement_number_from    VARCHAR2,
			  p_statement_number_to      VARCHAR2,
		 	  p_statement_date_from	     VARCHAR2,
			  p_statement_date_to	     VARCHAR2,
			  p_gl_date                  VARCHAR2,
                          p_receivables_trx_id       NUMBER,
                          p_payment_method_id        NUMBER,
			  p_nsf_handling             VARCHAR2,
			  p_display_debug	     VARCHAR2,
			  p_debug_path		     VARCHAR2,
			  p_debug_file               VARCHAR2,
			  p_intra_day_flag	     VARCHAR2,
			  p_org_id		     NUMBER,
			  p_legal_entity_id	     NUMBER);

PROCEDURE show_parameters;

END CE_AUTO_BANK_REC;

/
