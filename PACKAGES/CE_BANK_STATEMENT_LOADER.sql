--------------------------------------------------------
--  DDL for Package CE_BANK_STATEMENT_LOADER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CE_BANK_STATEMENT_LOADER" AUTHID CURRENT_USER AS
/*$Header: cebsldrs.pls 120.8.12010000.2 2009/07/28 09:42:16 rtumati ship $ 	*/

/* 2421690 Added the variable below. */

  G_spec_revision	VARCHAR2(1000) := '$Revision: 120.8.12010000.2 $';

  G_request_id		NUMBER;
  G_total_dr		NUMBER;
  G_total_cr		NUMBER;
  G_map_id		NUMBER;
  G_precision   	NUMBER;
  G_date_format 	VARCHAR2(30);
  G_data_file_name	VARCHAR2(80);
  G_rec_no		NUMBER;
  G_include_indicator	VARCHAR2(1);
  G_predefined_format   VARCHAR2(150);
  G_concatenate_format_flag	VARCHAR2(1);

  G_bank_account_id	NUMBER;
  G_bank_branch_id	NUMBER;
  G_sub_account_id	NUMBER;
  G_sub_branch_id	NUMBER;
  G_process_option	VARCHAR2(30);
  G_gl_date             DATE;

  -- added for Intra-Day project
  G_intra_day_flag	VARCHAR2(1);
  G_timestamp_format	VARCHAR2(20);

  -- added for subsidiary bank accounts
  G_subsidiary_flag		VARCHAR2(1);

  -- added for p2p
  G_gl_date_source      VARCHAR2(50);
  G_receivables_trx_id	NUMBER;
  G_payment_method_id   NUMBER;
  G_nsf_handling        VARCHAR2(50);
  G_display_debug	VARCHAR2(50);
  G_debug_path		VARCHAR2(50);
  G_debug_file	     	VARCHAR2(50);

  G_total_hdr_deleted	NUMBER	:= 0;
  G_total_line_deleted	NUMBER	:= 0;
  G_format_type		VARCHAR2(30);

  --Header columns
  G_statement_number 		VARCHAR2(50);
  G_bank_account_num 		VARCHAR2(30);
  G_statement_date 		DATE;
  G_bank_name 			VARCHAR2(60);
  G_bank_branch_name 		VARCHAR2(60);
  G_control_begin_balance 	NUMBER;
  G_control_end_balance 	NUMBER;
  G_cashflow_balance	 	NUMBER;
  G_int_calc_balance 		NUMBER;
  G_average_close_ledger_mtd	NUMBER;
  G_average_close_ledger_ytd	NUMBER;
  G_average_close_available_mtd	NUMBER;
  G_average_close_available_ytd	NUMBER;
  G_one_day_float 		NUMBER;
  G_two_day_float 		NUMBER;
  G_control_total_dr 		NUMBER;
  G_control_total_cr 		NUMBER;
  G_control_dr_line_count 	NUMBER;
  G_control_cr_line_count 	NUMBER;
  G_control_line_count 		NUMBER;
  G_hdr_currency_code 		VARCHAR2(15);
  G_check_digits		VARCHAR2(30);
  G_hdr_precision		NUMBER;
  G_org_id			VARCHAR2(30);
  G_user_id			NUMBER;

  -- Line columns
  G_line_number			NUMBER;
  G_trx_date 			DATE;
  G_trx_code 			VARCHAR2(30);
  G_effective_date 		DATE;
  G_trx_text 			VARCHAR2(255);
  G_invoice_text		VARCHAR2(70);  --Edifact ER  Altered the size from 30 chars to 70 chars
  G_amount	 		NUMBER;
  G_line_currency_code 		VARCHAR2(15);
  G_exchange_rate		NUMBER;
  G_bank_trx_number 		VARCHAR2(240);
  G_customer_text 		VARCHAR2(80);
  G_user_exchange_rate_type 	VARCHAR2(30);
  G_exchange_rate_date		DATE;
  G_original_amount		NUMBER;
  G_charges_amount		NUMBER;
  G_bank_account_text		VARCHAR2(30);
  G_line_precision		NUMBER;

  G_last_val1 VARCHAR2(30); -- bug 3771128

  G_rec_id VARCHAR2(2); --Edifact ER To hold current record id
  G_prev_rec_id VARCHAR2(2); --Edifact ER To hold Preiously processed record id


/* 2421690 Added the two functions below. */

FUNCTION spec_revision RETURN VARCHAR2;

FUNCTION body_revision RETURN VARCHAR2;

PROCEDURE Load_Bank_Statement(errbuf		OUT NOCOPY 	VARCHAR2,
			      retcode		OUT NOCOPY 	NUMBER,
			      X_MAP_ID			NUMBER,
			      X_REQUEST_ID		NUMBER,
			      X_data_file		VARCHAR2,
  			      X_process_option		VARCHAR2,
  			      X_gl_date			VARCHAR2,
  			      X_org_id			VARCHAR2,
 			      X_receivables_trx_id	NUMBER,
  			      X_payment_method_id	NUMBER,
  			      X_nsf_handling		VARCHAR2,
  			      X_display_debug		VARCHAR2,
  			      X_debug_path		VARCHAR2,
  			      X_debug_file		VARCHAR2,
  			      X_bank_branch_id		NUMBER,
  			      X_bank_account_id		NUMBER,
			      X_intra_day_flag		VARCHAR2 DEFAULT 'N',
                              X_gl_date_source          VARCHAR2 DEFAULT NULL);

FUNCTION Find_Formatted_String(X_format VARCHAR2,
			       X_trx_text varchar2) RETURN VARCHAR2;

FUNCTION Is_numeric(str IN VARCHAR2)     --Edifact ER  To check the amount is numeric or not
RETURN NUMBER;

FUNCTION covert_amt_edifact(amount IN VARCHAR2)  --Edifact ER To Decode the Non numeric characters and to convert the amount
RETURN NUMBER;

END CE_BANK_STATEMENT_LOADER;

/
