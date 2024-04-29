--------------------------------------------------------
--  DDL for Package AP_APXINDUP_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_APXINDUP_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: APXINDUPS.pls 120.0 2007/12/27 07:53:36 vjaganat noship $ */
	P_DEBUG_SWITCH	varchar2(1);
	P_CONC_REQUEST_ID	number;
	P_MIN_PRECISION	number;
	P_FLEXDATA	varchar2(600);
	P_SET_OF_BOOKS_ID	number;
	P_MATCH_LENGTH	number;
	P_AUDIT_BEGIN	date;
	P_AUDIT_END	date;
	P_INV_DATE_COMP	varchar2(1);
	P_COMPARE_BEGIN	date;
	P_COMPARE_END	date;
	P_AUDIT_BEGIN_1	varchar2(10);
	P_AUDIT_END_1	varchar2(10);
	P_COMPARE_BEGIN_1	varchar2(10);
	P_COMPARE_END_1	varchar2(10);
	P_VENDOR_TYPE	varchar2(25);
	P_VENDOR_NAME	number;
	P_VENDOR_NAME_OUT	varchar2(80);
	P_ORG_COND	varchar2(240) := ' ';
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
	C_CHART_OF_ACCOUNTS_ID	number;
	C_NLS_END_OF_REPORT	varchar2(100);
	C_ORG_ID	number;
	FUNCTION  get_base_curr_data  RETURN BOOLEAN  ;
	FUNCTION  custom_init         RETURN BOOLEAN  ;
	FUNCTION  get_cover_page_values   RETURN BOOLEAN  ;
	FUNCTION  get_nls_strings     RETURN BOOLEAN  ;
	function BeforeReport return boolean ;
	function AfterReport return boolean  ;
	FUNCTION  get_company_name    RETURN BOOLEAN  ;
	FUNCTION get_flexdata RETURN BOOLEAN  ;
	function C_VENDOR_TYPE_PREDICATEFormula return VARCHAR2  ;
	function C_VENDOR_NAME_PREDICATEFormula return VARCHAR2  ;
	function CF_INV_DATE_COMPFormula return Char  ;
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
	Function C_CHART_OF_ACCOUNTS_ID_p return number;
	Function C_NLS_END_OF_REPORT_p return varchar2;
	Function C_ORG_ID_p return number;
END AP_APXINDUP_XMLP_PKG;



/
