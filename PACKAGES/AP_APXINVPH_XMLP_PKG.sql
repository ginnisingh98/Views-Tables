--------------------------------------------------------
--  DDL for Package AP_APXINVPH_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_APXINVPH_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: APXINVPHS.pls 120.0 2007/12/27 08:07:16 vjaganat noship $ */
	P_DEBUG_SWITCH	varchar2(1);
	P_CONC_REQUEST_ID	number;
	P_MIN_PRECISION	number;
	P_FLEXDATA	varchar2(600);
	P_SET_OF_BOOKS_ID	number;
	P_START_DATE	date;
	P_END_DATE	date;
	LP_START_DATE	varchar2(11);
	LP_END_DATE	varchar2(11);
	P_VENDOR_TYPE_LOOKUP_CODE	varchar2(25);
	P_VENDOR_ID	number;
	P_MIN_AMOUNT	number;
	P_SUMMARY_OPTION	varchar2(40);
	P_ORDER_BY	varchar2(32767);
	P_VENDOR_ID_SQL	varchar2(100) := ' ';
	SORT_BY_ALTERNATE	varchar2(5);
	--created by raj
	SORT_BY_ALTERNATE_m	varchar2(15);
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
	C_CHART_OF_ACCOUNTS_ID	number;
	C_NLS_VOID	varchar2(80);
	C_NLS_NA	varchar2(80);
	C_NLS_VENDOR_TYPE	varchar2(80);
	C_NLS_END_OF_REPORT	varchar2(100);
	FUNCTION  get_base_curr_data  RETURN BOOLEAN  ;
	FUNCTION  custom_init         RETURN BOOLEAN  ;
	FUNCTION  get_cover_page_values   RETURN BOOLEAN  ;
	FUNCTION  get_nls_strings     RETURN BOOLEAN  ;
	function BeforeReport return boolean ;
	function AfterReport return boolean  ;
	FUNCTION  get_company_name    RETURN BOOLEAN  ;
	FUNCTION get_flexdata RETURN BOOLEAN  ;
	FUNCTION calculate_run_time RETURN BOOLEAN  ;
	function C_DYNAMIC_DESCFormula return VARCHAR2  ;
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
	Function C_NLS_VOID_p return varchar2;
	Function C_NLS_NA_p return varchar2;
	Function C_NLS_VENDOR_TYPE_p return varchar2;
	Function C_NLS_END_OF_REPORT_p return varchar2;
END AP_APXINVPH_XMLP_PKG;


/
