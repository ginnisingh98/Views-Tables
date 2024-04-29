--------------------------------------------------------
--  DDL for Package AP_APXINVTC_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_APXINVTC_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: APXINVTCS.pls 120.0 2007/12/27 08:08:21 vjaganat noship $ */
	P_DEBUG_SWITCH	varchar2(1);
	P_CONC_REQUEST_ID	number;
	P_MIN_PRECISION	number;
	CP_START_UPDATE_DATE varchar2(25);
	CP_END_UPDATE_DATE varchar2(25);
	P_FLEXDATA	varchar2(600);
	P_SET_OF_BOOKS_ID	number;
	P_TRACE_SWITCH	varchar2(1);
	P_START_UPDATE_DATE	date;
	P_END_UPDATE_DATE	date;
	P_SUPPLIER_NAME	varchar2(240);
	P_UPDATED_BY	varchar2(100);
	P_INVOICE_TYPE	varchar2(25);
	C_NLS_YES	varchar2(80);
	C_NLS_NO	varchar2(80);
	C_NLS_ALL	varchar2(80);
	C_NLS_NO_DATA_EXISTS	varchar2(240);
	C_NLS_VOID	varchar2(80);
	C_NLS_NA	varchar2(80);
	C_NLS_END_OF_REPORT	varchar2(100);
	C_REPORT_START_DATE	date;
	C_COMPANY_NAME_HEADER	varchar2(50);
	C_BASE_CURRENCY_CODE	varchar2(15);
	C_BASE_PRECISION	number;
	C_BASE_MIN_ACCT_UNIT	number;
	C_BASE_DESCRIPTION	varchar2(240);
	C_CHART_OF_ACCOUNTS_ID	number;
	--Applications Template Report	varchar2(1);
	Applications_Template_Report	varchar2(1);
	--H_ACCT_SEGS	varchar2(600) := := 'GCC.SEGMENT1' ;
	H_ACCT_SEGS	varchar2(600) :=  'GCC.SEGMENT1' ;
	--H_SORT_BY_ALTERNATE	varchar2(5) := := 'N' ;
	H_SORT_BY_ALTERNATE	varchar2(5) :=  'N' ;
	H_CHART_OF_ACCOUNTS_ID	varchar2(15);
	H_SET_OF_BOOKS_NAME	varchar2(30);
	H_CURRENCY	varchar2(15);
	H_CURRENCY_PRECISION	number;
	H_INVOICE_WHERE	varchar2(200);
	H_CURRENCY_DIST	varchar2(15);
	H_CURRENCY_DIST_PRECISION	number;
	H_CURRENCY_PAY	varchar2(15);
	H_CURRENCY_PAY_PRECISION	number;
	H_DATEFORMAT	varchar2(30);
	C_EXPENSE_ACCT_SEGS_COPY	varchar2(600);
	C_INVOICE_ACCT_SEGS_COPY	varchar2(600);
	FUNCTION  get_base_curr_data  RETURN BOOLEAN  ;
	FUNCTION  custom_init         RETURN BOOLEAN  ;
	FUNCTION  get_cover_page_values   RETURN BOOLEAN  ;
	FUNCTION  get_nls_strings     RETURN BOOLEAN  ;
	function BeforeReport return boolean ;
	function AfterReport return boolean  ;
	FUNCTION  get_company_name    RETURN BOOLEAN  ;
	FUNCTION get_flexdata RETURN BOOLEAN  ;
	FUNCTION create_where RETURN BOOLEAN  ;
	FUNCTION get_profile RETURN boolean  ;
	FUNCTION get_acc_segs RETURN boolean  ;
	Function C_NLS_YES_p return varchar2;
	Function C_NLS_NO_p return varchar2;
	Function C_NLS_ALL_p return varchar2;
	Function C_NLS_NO_DATA_EXISTS_p return varchar2;
	Function C_NLS_VOID_p return varchar2;
	Function C_NLS_NA_p return varchar2;
	Function C_NLS_END_OF_REPORT_p return varchar2;
	Function C_REPORT_START_DATE_p return date;
	Function C_COMPANY_NAME_HEADER_p return varchar2;
	Function C_BASE_CURRENCY_CODE_p return varchar2;
	Function C_BASE_PRECISION_p return number;
	Function C_BASE_MIN_ACCT_UNIT_p return number;
	Function C_BASE_DESCRIPTION_p return varchar2;
	Function C_CHART_OF_ACCOUNTS_ID_p return number;
	--Function Applications Template Report_p return varchar2;
	Function Applications_Template_Report_p return varchar2;
	Function H_ACCT_SEGS_p return varchar2;
	Function H_SORT_BY_ALTERNATE_p return varchar2;
	Function H_CHART_OF_ACCOUNTS_ID_p return varchar2;
	Function H_SET_OF_BOOKS_NAME_p return varchar2;
	Function H_CURRENCY_p return varchar2;
	Function H_CURRENCY_PRECISION_p return number;
	Function H_INVOICE_WHERE_p return varchar2;
	Function H_CURRENCY_DIST_p return varchar2;
	Function H_CURRENCY_DIST_PRECISION_p return number;
	Function H_CURRENCY_PAY_p return varchar2;
	Function H_CURRENCY_PAY_PRECISION_p return number;
	Function H_DATEFORMAT_p return varchar2;
	Function C_EXPENSE_ACCT_SEGS_COPY_p return varchar2;
	Function C_INVOICE_ACCT_SEGS_COPY_p return varchar2;
END AP_APXINVTC_XMLP_PKG;


/
