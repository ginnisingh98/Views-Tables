--------------------------------------------------------
--  DDL for Package AP_APXINDTL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_APXINDTL_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: APXINDTLS.pls 120.0 2007/12/27 07:52:26 vjaganat noship $ */
	P_DEBUG_SWITCH	varchar2(1);
	P_CONC_REQUEST_ID	number;
	P_MIN_PRECISION	number;
	P_SET_OF_BOOKS_ID	number;
	P_START_DATE	date;
	P_END_DATE	date;
	P_START_DATE1	varchar2(15);
	P_END_DATE1	varchar2(15);
	P_VENDOR_TYPE_LOOKUP_CODE	varchar2(25);
	P_VENDOR_ID	varchar2(15);
	P_SUMMARY_OPTION	varchar2(1);
	C_VENDOR_ID_PRED	varchar2(40):='and 1=1';
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
	C_CHART_OF_ACCOUNTS_ID	number := 50105 ;
	C_NLS_VNDR_TYPE_LKUP_CODE	varchar2(80);
	C_NO_RATE_COUNT_SAME_CURR	number := 0 ;
	C_NLS_END_OF_REPORT	varchar2(100);
	P_VENDOR_TYPE_LOOKUP_CODE_1 varchar2(25);
	FUNCTION  get_base_curr_data  RETURN BOOLEAN  ;
	FUNCTION  custom_init         RETURN BOOLEAN  ;
	FUNCTION  get_cover_page_values   RETURN BOOLEAN  ;
	FUNCTION  get_nls_strings     RETURN BOOLEAN  ;
	function BeforeReport return boolean ;
	function AfterReport return boolean  ;
	FUNCTION  get_company_name    RETURN BOOLEAN  ;
	FUNCTION get_flexdata RETURN BOOLEAN  ;
	FUNCTION  get_nls_vendor_type  RETURN BOOLEAN  ;
	function c_allcurr_dscnt_amt_tknformula(C_SMRY_CURRENCY in varchar2, C_SMRY_DSCNT_AMT_TAKEN in number, C_SMRY_BASE_CURR_DTKN in number) return number  ;
	function c_allcurr_inv_amtformula(C_SMRY_CURRENCY in varchar2, C_SMRY_INVOICE_AMOUNT in number, C_SMRY_BASE_CURR_AMT in number) return number  ;
	function c_allcurr_dscnt_amt_lostformul(C_SMRY_CURRENCY in varchar2, C_SMRY_DSCNT_AMT_LOST in number, C_SMRY_BASE_CURR_DLST in number) return number  ;
	function c_allcurr_no_rate_cntformula(C_SMRY_CURRENCY in varchar2, C_SMRY_NO_RATE_COUNT in number) return number  ;
	function c_m_allcurr_inv_amtformula(C_CURRENCY in varchar2, C_INVOICE_AMOUNT in number, C_BASE_CURRENCY_AMOUNT in number) return number  ;
	function c_m_allcurr_dtkn_amtformula(C_CURRENCY in varchar2, C_DISCOUNT_AMOUNT_TAKEN in number, C_BASE_CURR_DISCNT_TAKEN in number) return number  ;
	function c_m_allcurr_dlst_amtformula(C_CURRENCY in varchar2, C_DISCOUNT_AMOUNT_LOST in number, C_BASE_CURR_DISCNT_LOST in number) return number  ;
	function c_m_allcurr_no_rate_cntformula(C_CURRENCY in varchar2, C_NO_RATE_COUNT in number) return number  ;
	FUNCTION SET_DYNAMIC_WHERE RETURN BOOLEAN  ;
	FUNCTION SET_QUERY RETURN BOOLEAN  ;
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
	Function C_NLS_VNDR_TYPE_LKUP_CODE_p return varchar2;
	Function C_NO_RATE_COUNT_SAME_CURR_p return number;
	Function C_NLS_END_OF_REPORT_p return varchar2;
END AP_APXINDTL_XMLP_PKG;


/
