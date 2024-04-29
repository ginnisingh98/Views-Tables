--------------------------------------------------------
--  DDL for Package AP_APXINRIR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_APXINRIR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: APXINRIRS.pls 120.0 2007/12/27 08:01:46 vjaganat noship $ */
	P_FLEXDATA	varchar2(800);
	P_CONC_REQUEST_ID	number;
	P_MIN_PRECISION	number;
	P_DEBUG_SWITCH	varchar2(1);
	P_SOB_ID	number;
	P_FLEXDATA1	varchar2(800):='(GC2.SEGMENT1||''\n''||GC2.SEGMENT2||''\n''||GC2.SEGMENT3||''\n''||GC2.SEGMENT4||''\n''||GC2.SEGMENT5||''\n''||GC2.SEGMENT6||''\n''||GC2.SEGMENT7||''\n''||GC2.SEGMENT8||
	''\n''||GC2.SEGMENT9||''\n''||GC2.SEGMENT10||''\n''||GC2.SEGMENT11||''\n''||GC2.SEGMENT12||''\n''||GC2.SEGMENT13||''\n''||GC2.SEGMENT14||''\n''||GC2.SEGMENT15||''\n''||GC2.SEGMENT16||''\n''||GC2.SEGMENT17
	||''\n''||GC2.SEGMENT18||''\n''||GC2.SEGMENT19||''\n''||GC2.SEGMENT20||''\n''||GC2.SEGMENT21||''\n''||GC2.SEGMENT22||''\n''||GC2.SEGMENT23||''\n''||GC2.SEGMENT24||''\n''||GC2.SEGMENT25||''\n''||GC2.SEGMENT26||
	''\n''||GC2.SEGMENT27||''\n''||GC2.SEGMENT28||''\n''||GC2.SEGMENT29||''\n''||GC2.SEGMENT30)';
	P_BATCH	varchar2(50);
	P_ENTRY_PERSON	varchar2(50);
	P_START_DATE	date;
	CP_START_DATE	varchar2(25);
	P_END_DATE	date;
	CP_END_DATE	varchar2(25);
	P_ACCOUNTING_PERIOD	varchar2(15);
	P_CANCELLED_FLAG	varchar2(1);
	P_UNAPPROVE_FLAG	varchar2(1);
	p_unapprove_flag_1      varchar2(1);
	P_dynamic_batch_orderby	varchar2(32767):= 'NULL';
	P_invoice_amount	varchar2(240):='inv1.invoice_amount';
	P_gl_code_combinations2	varchar2(50):='gl_code_combinations GC2,';
	P_INVOICE_TYPE	varchar2(25);
	P_TRACE_SWITCH	varchar2(1);
	SORT_BY_ALTERNATE	varchar2(5);
	P_VENDOR_ID	number;
	--C_BASE_CURRENCY_CODE	varchar2(32767) := := '$$$' ;
	  C_BASE_CURRENCY_CODE	varchar2(32767) :=  '$$$' ;
	C_BASE_PRECISION	number := 2 ;
	C_BASE_MIN_ACCT_UNIT	number;
	--C_NLS_YES	varchar2(80) := := 'Yes' ;
	  C_NLS_YES	varchar2(80) :=  'Yes' ;
	--C_NLS_NO	varchar2(80) := := 'No' ;
	  C_NLS_NO	varchar2(80) :=  'No' ;
	C_NLS_ALL	varchar2(80);
	--C_COMPANY_NAME_HEADER	varchar2(30) := := 'No Company Name' ;
	  C_COMPANY_NAME_HEADER	varchar2(30) :=  'No Company Name' ;
	C_CHART_OF_ACCOUNTS_ID	number;
	C_NLS_NA	varchar2(80);
	C_NLS_NO_DATA_EXISTS	varchar2(240);
	C_SHOW_LIB_ACCT	varchar2(1);
	C_BATCH_FLAG	varchar2(1);
	C_BATCH_ID	varchar2(15);
	C_USER_ID	varchar2(14);
	C_liability_acct_flex	varchar2(240);
	C_batch_predicate	varchar2(240):= ' ';
	C_match_status_predicate	varchar2(240) := ' ';
	C_invoice_cancelled_predicate	varchar2(240);
	C_created_by_predicate	varchar2(240);
	C_start_date_predicate	varchar2(240);
	C_end_date_predicate	varchar2(240);
	C_gl_ccid2_predicate	varchar2(240);
	C_orderby_batch_id	varchar2(50);
	C_INV_TYPE_PRED	varchar2(240);
	C_NLS_END_OF_REPORT	varchar2(100);
	C_INVOICE_ID_PREDICATE	varchar2(240);
	C_ACCOUNTING_DATE_PREDICATE	varchar2(150);
	C_CANCELLED_INVOICES_ONLY	varchar2(20);
	C_UNAPPROVED_INVOICES_ONLY	varchar2(20);
	C_Supplier_Name	varchar2(240);
	C_INVOICE_TYPE1	varchar2(80);
	function BeforeReport return boolean ;
	function AfterReport return boolean  ;
	FUNCTION  custom_init         RETURN BOOLEAN  ;
	FUNCTION  get_base_curr_data  RETURN BOOLEAN  ;
	FUNCTION  get_company_name    RETURN BOOLEAN  ;
	FUNCTION  get_nls_strings     RETURN BOOLEAN  ;
	FUNCTION  get_flexdata     RETURN BOOLEAN  ;
	FUNCTION  set_p_where     RETURN BOOLEAN  ;
	FUNCTION GET_SUPPLIER_INVOICE_INFO RETURN BOOLEAN  ;
	Function C_BASE_CURRENCY_CODE_p return varchar2;
	Function C_BASE_PRECISION_p return number;
	Function C_BASE_MIN_ACCT_UNIT_p return number;
	Function C_NLS_YES_p return varchar2;
	Function C_NLS_NO_p return varchar2;
	Function C_NLS_ALL_p return varchar2;
	Function C_COMPANY_NAME_HEADER_p return varchar2;
	Function C_CHART_OF_ACCOUNTS_ID_p return number;
	Function C_NLS_NA_p return varchar2;
	Function C_NLS_NO_DATA_EXISTS_p return varchar2;
	Function C_SHOW_LIB_ACCT_p return varchar2;
	Function C_BATCH_FLAG_p return varchar2;
	Function C_BATCH_ID_p return varchar2;
	Function C_USER_ID_p return varchar2;
	Function C_liability_acct_flex_p return varchar2;
	Function C_batch_predicate_p return varchar2;
	Function C_match_status_predicate_p return varchar2;
	--Function C_invoice_cancelled_predicate return varchar2;
	  Function C_invoice_cancelled_pred_1 return varchar2;
	Function C_created_by_predicate_p return varchar2;
	Function C_start_date_predicate_p return varchar2;
	Function C_end_date_predicate_p return varchar2;
	Function C_gl_ccid2_predicate_p return varchar2;
	Function C_orderby_batch_id_p return varchar2;
	Function C_INV_TYPE_PRED_p return varchar2;
	Function C_NLS_END_OF_REPORT_p return varchar2;
	Function C_INVOICE_ID_PREDICATE_p return varchar2;
	Function C_ACCOUNTING_DATE_PREDICATE_p return varchar2;
	Function C_CANCELLED_INVOICES_ONLY_p return varchar2;
	Function C_UNAPPROVED_INVOICES_ONLY_p return varchar2;
	Function C_Supplier_Name_p return varchar2;
	Function C_INVOICE_TYPE1_p return varchar2;
END AP_APXINRIR_XMLP_PKG;



/
