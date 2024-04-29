--------------------------------------------------------
--  DDL for Package AP_APXPAYAD_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_APXPAYAD_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: APXPAYADS.pls 120.0 2007/12/27 08:19:18 vjaganat noship $ */
	P_DEBUG_SWITCH	varchar2(1);
	P_CONC_REQUEST_ID	number;
	P_MIN_PRECISION	number;
	P_SET_OF_BOOKS_ID	number;
	P_sequence_name	varchar2(30);
	P_sequence_from	number;
	P_sequence_to	number;
	C_last_value	number := -1 ;
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
	C_doc_sequence_id	number;
	C_NLS_END_OF_REPORT	varchar2(100);
	FUNCTION  get_base_curr_data  RETURN BOOLEAN  ;
	FUNCTION  custom_init         RETURN BOOLEAN  ;
	FUNCTION  get_cover_page_values   RETURN BOOLEAN  ;
	FUNCTION  get_nls_strings     RETURN BOOLEAN  ;
	function BeforeReport return boolean ;
	function AfterReport return boolean  ;
	FUNCTION  get_company_name    RETURN BOOLEAN  ;
	FUNCTION get_flexdata RETURN BOOLEAN  ;
	function C_enteredFormula return VARCHAR2  ;
	function C_deletedFormula return VARCHAR2  ;
	function c_new_recordsformula(doc_sequence_value in number) return number  ;
	function C_not_enteredFormula return VARCHAR2  ;
	Function C_last_value_p return number;
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
	Function C_doc_sequence_id_p return number;
	Function C_NLS_END_OF_REPORT_p return varchar2;
END AP_APXPAYAD_XMLP_PKG;


/
