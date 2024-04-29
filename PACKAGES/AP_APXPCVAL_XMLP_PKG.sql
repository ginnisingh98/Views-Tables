--------------------------------------------------------
--  DDL for Package AP_APXPCVAL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_APXPCVAL_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: APXPCVALS.pls 120.0 2007/12/27 08:23:03 vjaganat noship $ */
	P_DEBUG_SWITCH	varchar2(1);
	P_CONC_REQUEST_ID	number:=0;
	P_MIN_PRECISION	number;
	P_FLEXDATA	varchar2(2000);
	P_TRACE_SWITCH	varchar2(1);
	P_CARD_PROGRAM_ID	number;
	P_START_DATE	date;
	P_END_DATE	date;
	C_BASE_CURRENCY_CODE	varchar2(15);
	C_BASE_PRECISION	number;
	C_BASE_MIN_ACCT_UNIT	number;
	C_BASE_DESCRIPTION	varchar2(240);
	C_COMPANY_NAME_HEADER	varchar2(50);
	C_REPORT_START_DATE	date;
	C_NLS_YES	varchar2(80);
	C_NLS_NO	varchar2(80);
	C_NLS_ALL	varchar2(25);
	C_NLS_NO_DATA_EXISTS	varchar2(240);
	C_REPORT_RUN_TIME	varchar2(8);
	C_CHART_OF_ACCOUNTS_ID	number := 50105 ;
	C_ALWAYS_NULL	varchar2(32767);
	C_NLS_END_OF_REPORT	varchar2(100);
	C_CARD_PROGRAM_NAME	varchar2(240);
	C_CARD_PROGRAM_CURRENCY_CODE	varchar2(15);
	FUNCTION  get_base_curr_data  RETURN BOOLEAN  ;
	FUNCTION  custom_init         RETURN BOOLEAN  ;
	FUNCTION  get_cover_page_values   RETURN BOOLEAN  ;
	FUNCTION  get_nls_strings     RETURN BOOLEAN  ;
	function BeforeReport return boolean ;
	function AfterReport return boolean  ;
	FUNCTION  get_company_name    RETURN BOOLEAN  ;
	FUNCTION get_flexdata RETURN BOOLEAN  ;
	FUNCTION calculate_run_time RETURN BOOLEAN  ;
	function C_NLS_END_OF_REPORTFormula return VARCHAR2  ;
	function BeforePForm return boolean  ;
	function BetweenPage return boolean  ;
	function AfterPForm return boolean  ;
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
	Function C_ALWAYS_NULL_p return varchar2;
	Function C_NLS_END_OF_REPORT_p return varchar2;
	Function C_CARD_PROGRAM_NAME_p return varchar2;
	Function C_CARD_PROGRAM_CURRENCY_CODE_p return varchar2;
END AP_APXPCVAL_XMLP_PKG;


/
