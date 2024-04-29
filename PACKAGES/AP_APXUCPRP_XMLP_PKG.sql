--------------------------------------------------------
--  DDL for Package AP_APXUCPRP_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_APXUCPRP_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: APXUCPRPS.pls 120.0 2007/12/27 08:43:05 vjaganat noship $ */
	P_DEBUG_SWITCH	varchar2(1);
	P_CONC_REQUEST_ID	number;
	P_MIN_PRECISION	number;
	P_SET_OF_BOOKS_ID	number;
	P_TRACE_SWITCH	varchar2(1);
	P_BANK_ACCOUNT_ID	number;
	P_ENTITY_NAME	varchar2(240);
	P_FROM_CHECK_DATE	date;
	P_FROM_CHECK_DATE_v varchar2(100);
	F_LEDGER_PARTIAL_OU varchar2(100);
	P_TO_CHECK_DATE_v varchar2(100);
	P_LEVEL_NAME	varchar2(200);
	P_ORG_WHERE_AC	varchar2(2000);
	P_ORG_WHERE_ASP	varchar2(2000);
	P_PMT_METHOD	varchar2(25);
	P_REPORTING_ENTITY_ID	number;
	P_REPORTING_LEVEL	varchar2(30);
	P_STATE	varchar2(150);
	P_TO_CHECK_DATE	date;
	P_VNDR_TYPE	varchar2(25);
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
	Applications_Template_Report	varchar2(1);
	C_MULTI_ORG_WHERE	varchar2(2002) := 'AND 1=1' ;
	C_ORG_FROM_TABLES	varchar2(2000) := 'SYS.DUAL' ;
	C_SELECT_LE	varchar2(100) := 'Legal Entity' ;
	C_SELECT_OU	varchar2(100) := 'Operating Unit' ;
	CP_PAYMENT_METHOD	varchar2(20);
	CP_BANK_ACCOUNT_NAME	varchar2(80);
	C_LEDGER_PARTIAL_OU	varchar2(240);
	FUNCTION  get_base_curr_data  RETURN BOOLEAN  ;
	FUNCTION  get_nls_strings     RETURN BOOLEAN  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	FUNCTION  get_company_name    RETURN BOOLEAN  ;
	FUNCTION GET_ORG_PLACEHOLDERS RETURN BOOLEAN  ;
	function AfterPForm return boolean  ;
	FUNCTION GET_BANK_ACCOUNT_INFO
   RETURN BOOLEAN  ;
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
	Function Applications_Template_Rep_p return varchar2;
	Function C_MULTI_ORG_WHERE_p return varchar2;
	Function C_ORG_FROM_TABLES_p return varchar2;
	Function C_SELECT_LE_p return varchar2;
	Function C_SELECT_OU_p return varchar2;
	Function CP_PAYMENT_METHOD_p return varchar2;
	Function CP_BANK_ACCOUNT_NAME_p return varchar2;
	Function C_LEDGER_PARTIAL_OU_p return varchar2;
END AP_APXUCPRP_XMLP_PKG;


/
