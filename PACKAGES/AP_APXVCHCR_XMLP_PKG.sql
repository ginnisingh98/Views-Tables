--------------------------------------------------------
--  DDL for Package AP_APXVCHCR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_APXVCHCR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: APXVCHCRS.pls 120.0 2007/12/27 08:44:00 vjaganat noship $ */
	P_DEBUG_SWITCH	varchar2(1);
	P_CONC_REQUEST_ID	number;
	P_MIN_PRECISION	number;
	P_FLEXDATA	varchar2(600);
	P_SET_OF_BOOKS_ID	number;
	P_WHERE1	varchar2(2000);
	P_INCLUDE_ZEROS	varchar2(1);
	P_ADDRS_OPTION	varchar2(1);
	P_DATE_OPTION	varchar2(15);
	P_TRACE_SWITCH	varchar2(1);
	P_START_DATE	date;
	P_END_DATE	date;
	LP_START_DATE	varchar2(11);
	LP_END_DATE	varchar2(11);
	WHERE1	varchar2(40);
	P_HERE1	varchar2(40);
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
	C_FIRST_REC	varchar2(1);
	C_OLD_BANK_CURR_CODE	varchar2(30);
	--C_CURR_CODE_CHANGE_FLAG	varchar2(1) := := 'N' ;
	C_CURR_CODE_CHANGE_FLAG	varchar2(1) := 'N' ;
	C_NLS_END_OF_REPORT	varchar2(100);
	C_NLS_ADDR_OPTION	varchar2(80);
	C_NLS_ZERO_AMT_OPTION	varchar2(80);
	C_DATE_OPTION	varchar2(80);
	C_nls_none_ep	varchar2(30);
	FUNCTION  get_base_curr_data  RETURN BOOLEAN  ;
	FUNCTION  custom_init         RETURN BOOLEAN  ;
	FUNCTION  get_cover_page_values   RETURN BOOLEAN  ;
	FUNCTION  get_nls_strings     RETURN BOOLEAN  ;
	function BeforeReport return boolean ;
	function AfterReport return boolean  ;
	FUNCTION  get_company_name    RETURN BOOLEAN  ;
	FUNCTION get_flexdata RETURN BOOLEAN  ;
	FUNCTION calculate_run_time RETURN BOOLEAN  ;
	function c_pay_curr_nameformula(C_PAY_CURR_CODE in varchar2) return varchar2  ;
	function c_bank_curr_nameformula(C_BANK_CURR_CODE in varchar2) return varchar2  ;
	FUNCTION GET_DATE_OPTION RETURN BOOLEAN  ;
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
	Function C_FIRST_REC_p return varchar2;
	Function C_OLD_BANK_CURR_CODE_p return varchar2;
	Function C_CURR_CODE_CHANGE_FLAG_p return varchar2;
	Function C_NLS_END_OF_REPORT_p return varchar2;
	Function C_NLS_ADDR_OPTION_p return varchar2;
	Function C_NLS_ZERO_AMT_OPTION_p return varchar2;
	Function C_DATE_OPTION_p return varchar2;
	Function C_nls_none_ep_p return varchar2;
END AP_APXVCHCR_XMLP_PKG;


/
