--------------------------------------------------------
--  DDL for Package AP_APXT7INE_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_APXT7INE_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: APXT7INES.pls 120.0 2007/12/27 08:37:25 vjaganat noship $ */
	P_DEBUG_SWITCH	varchar2(1);
	P_CONC_REQUEST_ID	number;
	P_MIN_PRECISION	number;
	P_FLEXDATA	varchar2(600);
	P_SET_OF_BOOKS_ID	number;
	P_TRACE_SWITCH	varchar2(1);
	P_BALANCING_SEGMENT_COLUMN	varchar2(40);
	P_START_DATE	date;
	P_END_DATE	date;
	LP_START_DATE	varchar2(11);
	LP_END_DATE	varchar2(11);
	P_Entity_Name	varchar2(30);
	P_REP_ENTITY_ID	number;
	p_query_driver	varchar2(32767);
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
	C_COMBINED_FILING	varchar2(1) := 'N' ;
	FUNCTION  get_base_curr_data  RETURN BOOLEAN  ;
	FUNCTION  custom_init         RETURN BOOLEAN  ;
	FUNCTION  get_cover_page_values   RETURN BOOLEAN  ;
	FUNCTION  get_nls_strings     RETURN BOOLEAN  ;
	function BeforeReport return boolean ;
	function AfterReport return boolean  ;
	FUNCTION  get_company_name    RETURN BOOLEAN  ;
	FUNCTION get_flexdata RETURN BOOLEAN  ;
	Function Get_Balancing_segment_column Return BOOLEAN  ;
	Function Get_Entity_name Return BOOLEAN  ;
	function c_count_invoice_exceptionformu(c_count_no_type in number, c_count_non_1099 in number, c_count_null_region in number) return number  ;
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
	Function C_COMBINED_FILING_p return varchar2;
END AP_APXT7INE_XMLP_PKG;


/
