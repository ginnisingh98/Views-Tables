--------------------------------------------------------
--  DDL for Package AR_ARXINVAD_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_ARXINVAD_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: ARXINVADS.pls 120.0 2007/12/27 13:54:23 abraghun noship $ */
	P_DEBUG_SWITCH	varchar2(1);
	P_CONC_REQUEST_ID	number;
	P_MIN_PRECISION	number;
	P_SET_OF_BOOKS_ID	number;
	P_sequence_id	number;
	P_sequence_from	number;
	P_sequence_to	number;
	P_TYPE	varchar2(32767);
	C_last_value	number  ;
	C_BASE_CURRENCY_CODE	varchar2(15);
	C_BASE_PRECISION	number;
	C_BASE_MIN_ACCT_UNIT	number;
	C_BASE_DESCRIPTION	varchar2(240);
	C_COMPANY_NAME_HEADER	varchar2(50);
	C_REPORT_START_DATE	date;
	C_NLS_NO_DATA_EXISTS	varchar2(2010);
	C_CHART_OF_ACCOUNTS_ID	number;
	C_sequence_name	varchar2(30);
	C_sequence_method	varchar2(80);
	C_report_type	varchar2(80);
	FUNCTION  get_cover_page_values   RETURN BOOLEAN  ;
	FUNCTION  get_nls_strings     RETURN BOOLEAN  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	FUNCTION  get_company_name    RETURN BOOLEAN  ;
	function C_enteredFormula return VARCHAR2  ;
	function C_deletedFormula return VARCHAR2  ;
	function c_new_recordsformula(doc_sequence_value in number) return number  ;
	function C_not_enteredFormula return VARCHAR2  ;
	FUNCTION  get_base_curr_data  RETURN BOOLEAN  ;
	FUNCTION  get_report_type    RETURN BOOLEAN  ;
	Function C_last_value_p return number;
	Function C_BASE_CURRENCY_CODE_p return varchar2;
	Function C_BASE_PRECISION_p return number;
	Function C_BASE_MIN_ACCT_UNIT_p return number;
	Function C_BASE_DESCRIPTION_p return varchar2;
	Function C_COMPANY_NAME_HEADER_p return varchar2;
	Function C_REPORT_START_DATE_p return date;
	Function C_NLS_NO_DATA_EXISTS_p return varchar2;
	Function C_CHART_OF_ACCOUNTS_ID_p return number;
	Function C_sequence_name_p return varchar2;
	Function C_sequence_method_p return varchar2;
	Function C_report_type_p return varchar2;
END AR_ARXINVAD_XMLP_PKG;


/
