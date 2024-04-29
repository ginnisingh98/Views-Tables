--------------------------------------------------------
--  DDL for Package AP_APXPAYSC_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_APXPAYSC_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: APXPAYSCS.pls 120.0 2007/12/27 08:21:43 vjaganat noship $ */
	P_DEBUG_SWITCH	varchar2(1);
	P_CONC_REQUEST_ID	number;
	P_MIN_PRECISION	number;
	P_FLEXDATA	varchar2(600);
	P_SET_OF_BOOKS_ID	number;
	P_TRACE_SWITCH	varchar2(1);
CP_END_DUE_DATE varchar2(25);
	P_END_DUE_DATE	date;
	P_PAYMENT_CURRENCY	varchar2(15);
	P_PAYMENT_METHOD	varchar2(25);
	P_PAY_GROUP	varchar2(25);
	P_priority_range_high	number;
	P_priority_range_low	number;
	P_supplier_name	varchar2(15);
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
	H_CURRENCY	varchar2(15);
	H_CURRENCY_PRECISION	number;
	H_CHART_OF_ACCOUNTS_ID	varchar2(15);
	H_SET_OF_BOOKS_NAME	varchar2(30);
	H_SORT_BY_ALTERNATE	varchar2(5);
	H_DATEFORMAT	varchar2(30);
	FUNCTION  get_base_curr_data  RETURN BOOLEAN  ;
	FUNCTION  custom_init         RETURN BOOLEAN  ;
	FUNCTION  get_cover_page_values   RETURN BOOLEAN  ;
	FUNCTION  get_nls_strings     RETURN BOOLEAN  ;
	function BeforeReport return boolean ;
	function AfterReport return boolean  ;
	FUNCTION  get_company_name    RETURN BOOLEAN  ;
	FUNCTION get_flexdata RETURN BOOLEAN  ;
	FUNCTION get_report_curr_data RETURN boolean  ;
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
	Function H_CURRENCY_p return varchar2;
	Function H_CURRENCY_PRECISION_p return number;
	Function H_CHART_OF_ACCOUNTS_ID_p return varchar2;
	Function H_SET_OF_BOOKS_NAME_p return varchar2;
	Function H_SORT_BY_ALTERNATE_p return varchar2;
	Function H_DATEFORMAT_p return varchar2;
END AP_APXPAYSC_XMLP_PKG;


/
