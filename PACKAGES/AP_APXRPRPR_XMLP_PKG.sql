--------------------------------------------------------
--  DDL for Package AP_APXRPRPR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_APXRPRPR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: APXRPRPRS.pls 120.0 2007/12/27 08:29:45 vjaganat noship $ */
	P_DEBUG_SWITCH	varchar2(1);
	P_CONC_REQUEST_ID	number;
	P_MIN_PRECISION	number;
	P_SET_OF_BOOKS_ID	number;
	P_WHERE	varchar2(20000):= 'WHERE 1=1';
	P_ORDERBY	varchar2(20000):= 'REC_PAY_PERIOD_TYPE';
	P_START_DATE	date;
	P_END_DATE	date;
	P_START_DATE1	varchar2(25);
	P_END_DATE1	varchar2(25);
	P_SELECT_OPTION	varchar2(3);
	P_ORDER_BY_OPTION	varchar2(25);
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
	C_REPORT_RUN_TIME	varchar2(17);
	C_CHART_OF_ACCOUNTS_ID	number;
	C_NLS_END_OF_REPORT	varchar2(100);
	FUNCTION  get_base_curr_data  RETURN BOOLEAN  ;
	FUNCTION  custom_init         RETURN BOOLEAN  ;
	FUNCTION  get_cover_page_values   RETURN BOOLEAN  ;
	FUNCTION  get_nls_strings     RETURN BOOLEAN  ;
	function BeforeReport return boolean ;
	function AfterReport return boolean  ;
	FUNCTION  get_company_name    RETURN BOOLEAN  ;
	FUNCTION get_flexdata RETURN BOOLEAN  ;
	function P_END_DATEValidTrigger return boolean  ;
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
	Function C_NLS_END_OF_REPORT_p return varchar2;
END AP_APXRPRPR_XMLP_PKG;



/
