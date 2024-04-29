--------------------------------------------------------
--  DDL for Package AP_APXPPREM_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_APXPPREM_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: APXPPREMS.pls 120.0 2007/12/27 08:26:00 vjaganat noship $ */
	P_DEBUG_SWITCH	varchar2(1);
	P_CONC_REQUEST_ID	number;
	P_MIN_PRECISION	number;
	P_VENDOR_ID	number;
	P_INVOICE_ID	number;
	P_PREPAY_ID	number;
	P_START_DATE	date;
	P_END_DATE	date;
	P_NAME_SRS	varchar2(30);
	P_TITLE_SRS	varchar2(30);
	P_PHONE_SRS	varchar2(30);
	P_NAME_EXEC	varchar2(100);
	P_TITLE_EXEC	varchar2(100);
	P_PHONE_EXEC	varchar2(30);
	LP_LANGUAGE_WHERE	varchar2(200);
	C_BASE_CURRENCY_CODE	varchar2(15);
	C_BASE_PRECISION	number;
	C_BASE_MIN_ACCT_UNIT	number;
	C_BASE_DESCRIPTION	varchar2(240);
	C_COMPANY_NAME_HEADER	varchar2(50);
	C_REPORT_START_DATE	date;
	C_NLS_YES	varchar2(80);
	C_NLS_NO	varchar2(80);
	C_NLS_ALL	varchar2(80);
	C_NLS_NO_DATA_EXISTS	varchar2(240);
	C_REPORT_RUN_TIME	varchar2(8);
	C_CHART_OF_ACCOUNTS_ID	number := 50105 ;
	C_VENDOR_ID_PREDICATE	varchar2(120);
	C_INVOICE_ID_PREDICATE	varchar2(120);
	C_PREPAY_ID_PREDICATE	varchar2(120);
	C_START_DATE_PREDICATE	varchar2(120);
	C_END_DATE_PREDICATE	varchar2(120);
	C_START_INVOICE_DATE_PREDICATE	varchar2(120);
	C_END_INVOICE_DATE_PREDICATE	varchar2(120);
	FUNCTION  get_base_curr_data  RETURN BOOLEAN  ;
	function custom_init return boolean  ;
	FUNCTION  get_cover_page_values   RETURN BOOLEAN  ;
	FUNCTION  get_nls_strings     RETURN BOOLEAN  ;
	function BeforeReport return boolean ;
	function AfterReport return boolean  ;
	FUNCTION get_flexdata RETURN BOOLEAN  ;
	FUNCTION calculate_run_time RETURN BOOLEAN  ;
	function C_SENDER_NAMEFormula return VARCHAR2  ;
	function C_SENDER_TITLEFormula return VARCHAR2  ;
	function C_SENDER_PHONEFormula return VARCHAR2  ;
	function populate_mls_lexicals return boolean  ;
	Function C_BASE_CURRENCY_CODE_p return varchar2;
	Function C_BASE_PRECISION_p return number;
	Function C_BASE_MIN_ACCT_UNIT_p return number;
	Function C_BASE_DESCRIPTION_p return varchar2;
	Function C_COMPANY_NAME_HEADER_p return varchar2;
	Function C_REPORT_START_DATE_p return date;
	Function C_NLS_YES_p return varchar2;
	Function C_NLS_NO_p return varchar2;
	Function C_NLS_ALL_p return varchar2;
	Function C_NLS_NO_DATA_EXISTS_p return varchar2;
	Function C_REPORT_RUN_TIME_p return varchar2;
	Function C_CHART_OF_ACCOUNTS_ID_p return number;
	Function C_VENDOR_ID_PREDICATE_p return varchar2;
	Function C_INVOICE_ID_PREDICATE_p return varchar2;
	Function C_PREPAY_ID_PREDICATE_p return varchar2;
	Function C_START_DATE_PREDICATE_p return varchar2;
	Function C_END_DATE_PREDICATE_p return varchar2;
	Function C_START_INVOICE_DATE_PREDICAT return varchar2;
	Function C_END_INVOICE_DATE_PREDICATE_p return varchar2;
END AP_APXPPREM_XMLP_PKG;


/
