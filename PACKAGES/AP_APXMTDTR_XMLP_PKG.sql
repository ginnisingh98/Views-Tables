--------------------------------------------------------
--  DDL for Package AP_APXMTDTR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_APXMTDTR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: APXMTDTRS.pls 120.0 2007/12/27 08:14:51 vjaganat noship $ */
	P_DEBUG_SWITCH	varchar2(1);
	P_CONC_REQUEST_ID	number;
	P_MIN_PRECISION	number;
	P_FLEXDATA	varchar2(1000);
	P_SET_OF_BOOKS_ID	number;
	P_TRACE_SWITCH	varchar2(1);
	P_INVOICE_ID	varchar2(40);
	P_FLEXDATA2	varchar2(1000);
	P_FLEXDATA3	varchar2(1000);
	P_PO_HEADER_ID	varchar2(40);
	P_SHIPMENT_HEADER_ID	varchar2(40);
	P_FLEXDATA4	varchar2(1000);
	P_PO_RELEASE_ID	number;
	LP_PO_RELEASE_ID	varchar2(200);
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
	FUNCTION  get_base_curr_data  RETURN BOOLEAN  ;
	FUNCTION  custom_init         RETURN BOOLEAN  ;
	FUNCTION  get_cover_page_values   RETURN BOOLEAN  ;
	FUNCTION  get_nls_strings     RETURN BOOLEAN  ;
	function BeforeReport return boolean ;
	function AfterReport return boolean  ;
	FUNCTION  get_company_name    RETURN BOOLEAN  ;
	FUNCTION get_flexdata RETURN BOOLEAN  ;
	FUNCTION get_flexdata3 RETURN BOOLEAN  ;
	FUNCTION get_flexdata4 RETURN BOOLEAN  ;
	function c_po_price_roundformula(C_PO_PRICE in number, C_CURRENCY_CODE in varchar2) return number  ;
	function c_po_price1_roundformula(C_PO_PRICE1 in number, C_PO_CURRENCY_CODE in varchar2) return number  ;
	function cf_exchange_rate_type_desc_inv(c_exchange_rate_type in varchar2) return char  ;
	function cf_rate_type_desc_poformula(c_rate_type in varchar2) return char  ;
	function cf_exchange_rate_type_desc_rec(c_exchange_rate_type1 in varchar2) return char  ;
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
END AP_APXMTDTR_XMLP_PKG;


/
