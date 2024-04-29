--------------------------------------------------------
--  DDL for Package CE_AUTO_BANK_IMPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CE_AUTO_BANK_IMPORT" AUTHID CURRENT_USER AS
/* $Header: ceabrims.pls 120.10.12010000.2 2009/09/30 11:30:49 ckansara ship $ */
--
-- GLOBAL variables
--

G_cshi_control_total_dr		CE_STATEMENT_HEADERS.control_total_dr%TYPE;
G_cshi_control_total_cr		CE_STATEMENT_HEADERS.control_total_cr%TYPE;
G_cshi_control_dr_line_count	CE_STATEMENT_HEADERS.control_dr_line_count%TYPE;
G_cshi_control_cr_line_count	CE_STATEMENT_HEADERS.control_cr_line_count%TYPE;
G_cshi_control_line_count	CE_STATEMENT_HEADERS.control_cr_line_count%TYPE;
G_cshi_control_begin_balance	CE_STATEMENT_HEADERS.control_begin_balance%TYPE;
G_cshi_control_end_balance	CE_STATEMENT_HEADERS.control_end_balance%TYPE;
G_cshi_cashflow_balance		CE_STATEMENT_HEADERS.cashflow_balance%TYPE;
G_cshi_int_calc_balance		CE_STATEMENT_HEADERS.int_calc_balance%TYPE;
G_cshi_close_ledger_mtd 			CE_BANK_ACCT_BALANCES.average_close_ledger_mtd%TYPE;
G_cshi_close_ledger_ytd 			CE_BANK_ACCT_BALANCES.average_close_ledger_ytd%TYPE;
G_cshi_close_available_mtd 			CE_BANK_ACCT_BALANCES.average_close_available_mtd%TYPE;
G_cshi_close_available_ytd 			CE_BANK_ACCT_BALANCES.average_close_available_ytd%TYPE;
G_cshi_one_day_float		CE_STATEMENT_HEADERS.one_day_float%TYPE;
G_cshi_two_day_float		CE_STATEMENT_HEADERS.two_day_float%TYPE;
G_cshi_intra_day_flag				VARCHAR2(1);
G_cshi_subsidiary_flag				VARCHAR2(1);
G_cshi_attribute_category       CE_STATEMENT_HEADERS_INT.attribute_category%TYPE;
G_cshi_attribute1               CE_STATEMENT_HEADERS_INT.attribute1%TYPE;
G_cshi_attribute2               CE_STATEMENT_HEADERS_INT.attribute2%TYPE;
G_cshi_attribute3               CE_STATEMENT_HEADERS_INT.attribute3%TYPE;
G_cshi_attribute4               CE_STATEMENT_HEADERS_INT.attribute4%TYPE;
G_cshi_attribute5               CE_STATEMENT_HEADERS_INT.attribute5%TYPE;
G_cshi_attribute6               CE_STATEMENT_HEADERS_INT.attribute6%TYPE;
G_cshi_attribute7               CE_STATEMENT_HEADERS_INT.attribute7%TYPE;
G_cshi_attribute8               CE_STATEMENT_HEADERS_INT.attribute8%TYPE;
G_cshi_attribute9               CE_STATEMENT_HEADERS_INT.attribute9%TYPE;
G_cshi_attribute10              CE_STATEMENT_HEADERS_INT.attribute10%TYPE;
G_cshi_attribute11              CE_STATEMENT_HEADERS_INT.attribute11%TYPE;
G_cshi_attribute12              CE_STATEMENT_HEADERS_INT.attribute12%TYPE;
G_cshi_attribute13              CE_STATEMENT_HEADERS_INT.attribute13%TYPE;
G_cshi_attribute14              CE_STATEMENT_HEADERS_INT.attribute14%TYPE;
G_cshi_attribute15              CE_STATEMENT_HEADERS_INT.attribute15%TYPE;
G_cshi_statement_date		CE_STATEMENT_HEADERS_INT.statement_date%TYPE;
G_cshi_bank_branch_name	        CE_STATEMENT_HEADERS_INT.bank_branch_name%TYPE;
G_cshi_bank_name	        CE_STATEMENT_HEADERS_INT.bank_name%TYPE;
G_cshi_currency_code		CE_STATEMENT_HEADERS_INT.currency_code%TYPE;
G_cshi_statement_number		CE_STATEMENT_HEADERS_INT.statement_number%TYPE;
G_cshi_bank_account_num		CE_STATEMENT_HEADERS_INT.bank_account_num%TYPE;
G_cshi_check_digits 		CE_STATEMENT_HEADERS_INT.check_digits%TYPE;
G_cshi_statement_header_id	CE_STATEMENT_HEADERS.statement_header_id%TYPE;
G_trx_recon_seq_id        CE_TRANSACTION_CODES.reconciliation_sequence%TYPE;  -- bug 8965556
G_cshi_org_id			NUMBER;
G_cshi_rowid			VARCHAR2(100);
G_dr_sum			NUMBER;
G_cr_sum			NUMBER;
G_dr_count			NUMBER;
G_cr_count			NUMBER;
G_total_count			NUMBER;
G_bank_account_id               NUMBER;
G_spec_revision 	VARCHAR2(1000) := '$Revision: 120.10.12010000.2 $';

G_xtr_use_allowed_flag		VARCHAR2(1);
G_pay_use_allowed_flag		VARCHAR2(1);
BA_OWNER_LE_ID			  NUMBER;

FUNCTION spec_revision RETURN VARCHAR2;

FUNCTION body_revision RETURN VARCHAR2;

PROCEDURE import_process;

PROCEDURE update_header_status(p_status               	VARCHAR2);

FUNCTION header_error (error_name VARCHAR2) RETURN BOOLEAN;

FUNCTION get_sequence_info (app_id		IN NUMBER,
			    category_code	IN VARCHAR2,
			    set_of_books_id	IN NUMBER,
			    entry_method	IN CHAR,
			    trx_date		IN DATE,
			    seq_name	IN OUT NOCOPY	   VARCHAR2,
			    seq_id	IN OUT NOCOPY     NUMBER,
			    seq_value	IN OUT NOCOPY     NUMBER) RETURN BOOLEAN;
END CE_AUTO_BANK_IMPORT;

/
