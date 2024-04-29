--------------------------------------------------------
--  DDL for Package AP_APXINROH_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_APXINROH_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: APXINROHS.pls 120.0 2007/12/27 08:02:58 vjaganat noship $ */
	P_DEBUG_SWITCH	varchar2(1);
	P_CONC_REQUEST_ID	number;
	P_MIN_PRECISION	number;
	P_FLEXDATA	varchar2(600);
	P_SET_OF_BOOKS_ID	number;
	P_ORDER_BY	varchar2(30);
	P_SUBTOTAL_FLAG	varchar2(40);
	P_HOLD_CODE	varchar2(40);
	P_START_CREATION_DATE	date;
	P_END_CREATION_DATE	date;
	LP_START_CREATION_DATE	varchar2(11);
	LP_END_CREATION_DATE	varchar2(11);
	P_START_DUE_DATE	date;
	P_END_DUE_DATE	date;
	P_START_DISCOUNT_DATE	date;
	P_END_DISCOUNT_DATE	date;
	P_PARTY_ID	number;
	P_DATE_PAR	varchar2(30);
	P_START_DATE	date;
	P_END_DATE	date;
	LP_START_DATE	varchar2(11);
	LP_END_DATE	varchar2(11);
	SORT_BY_ALTERNATE	varchar2(5);
	P_HOLD_DESC_FLAG	varchar2(1);
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
	C_NLS_NA	varchar2(80);
	C_NLS_NO_DESCRIPTION	varchar2(80);
	C_NLS_END_OF_REPORT	varchar2(100);
	CP_PARTY_NAME	varchar2(100);
	CP_ORDER_BY	varchar2(80);
	CP_HOLD_PERIOD_OPTION	varchar2(80);
	CP_INCLUDE_HOLD_DESC	varchar2(80);
	CP_DUE_OR_DISCOUNT	varchar2(80);
	FUNCTION  get_base_curr_data  RETURN BOOLEAN  ;
	FUNCTION  custom_init         RETURN BOOLEAN  ;
	FUNCTION  get_cover_page_values   RETURN BOOLEAN  ;
	FUNCTION  get_nls_strings     RETURN BOOLEAN  ;
	function BeforeReport return boolean ;
	function AfterReport return boolean  ;
	FUNCTION  get_company_name    RETURN BOOLEAN  ;
	FUNCTION get_flexdata RETURN BOOLEAN  ;
	function C_ORDER_BYFormula return VARCHAR2  ;
	function C_ORDER_BY1Formula return VARCHAR2  ;
	FUNCTION GET_PARAMETER_DISP_VALUE RETURN BOOLEAN  ;
	function c_rep_total_countformula(c_total_count in number, c_pay_on_hold_count in number, c_sites_on_hold_count in number, c_total_count1 in number) return number  ;
	function c_rep_total_remainingformula(c_total_remaining in number, c_ph_total_remaining in number, c_sh_total_remaining in number, c_total_remaining1 in number) return number  ;
	function c_rep_total_originalformula(c_total_original in number, c_ph_total_original in number, c_sh_total_original in number, c_total_original1 in number) return number  ;
	function C_vendor_clauseFormula return Char  ;
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
	Function C_NLS_NA_p return varchar2;
	Function C_NLS_NO_DESCRIPTION_p return varchar2;
	Function C_NLS_END_OF_REPORT_p return varchar2;
	Function CP_PARTY_NAME_p return varchar2;
	Function CP_ORDER_BY_p return varchar2;
	Function CP_HOLD_PERIOD_OPTION_p return varchar2;
	Function CP_INCLUDE_HOLD_DESC_p return varchar2;
	Function CP_DUE_OR_DISCOUNT_p return varchar2;
END AP_APXINROH_XMLP_PKG;


/
