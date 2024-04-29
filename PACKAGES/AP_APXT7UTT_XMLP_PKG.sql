--------------------------------------------------------
--  DDL for Package AP_APXT7UTT_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_APXT7UTT_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: APXT7UTTS.pls 120.0 2007/12/27 08:38:17 vjaganat noship $ */
	P_DEBUG_SWITCH	varchar2(1);
	P_CONC_REQUEST_ID	number;
	P_MIN_PRECISION	number;
	P_FLEXDATA	varchar2(600);
	P_SET_OF_BOOKS_ID	number;
	P_TRACE_SWITCH	varchar2(1);
	P_vendor_option	number;
	P_start_date	date;
	P_end_date	date;
	LP_start_date	varchar2(11);
	LP_end_date	varchar2(11);
	P_update_misc	varchar2(10);
	P_update_region	varchar2(10);
	P_region_code	varchar2(25);
	C_NLS_YES	varchar2(80);
	C_NLS_NO	varchar2(80);
	C_NLS_ALL	varchar2(80);
	C_NLS_NO_DATA_EXISTS	varchar2(240);
	C_NLS_VOID	varchar2(80);
	C_NLS_NA	varchar2(80);
	C_NLS_END_OF_REPORT	varchar2(100);
	C_REPORT_START_DATE	date;
	C_BASE_CURRENCY_CODE	varchar2(15);
	C_BASE_PRECISION	number;
	C_BASE_MIN_ACCT_UNIT	number;
	C_BASE_DESCRIPTION	varchar2(240);
	C_CHART_OF_ACCOUNTS_ID	number;
	--Applications Template Report	varchar2(1);
	Applications_Template_Report	varchar2(1);
	C_COMPANY_NAME	varchar2(30);
	C_curdate	varchar2(15);
	FUNCTION  get_base_curr_data  RETURN BOOLEAN  ;
	FUNCTION  custom_init         RETURN BOOLEAN  ;
	FUNCTION  get_cover_page_values   RETURN BOOLEAN  ;
	FUNCTION  get_nls_strings     RETURN BOOLEAN  ;
	function BeforeReport return boolean ;
	function afterreport(C_tot_vendor in number, C_tot_vendor_R in number) return boolean  ;
	FUNCTION  get_company_name    RETURN BOOLEAN  ;
	FUNCTION get_flexdata RETURN BOOLEAN  ;
	function c_update_miscsformula(type_1099 in varchar2, vendor_id in number) return varchar2  ;
	function c_update_regionsformula(region_R in varchar2, vendor_id_R in number, site_id_R in number) return varchar2  ;
	Function C_NLS_YES_p return varchar2;
	Function C_NLS_NO_p return varchar2;
	Function C_NLS_ALL_p return varchar2;
	Function C_NLS_NO_DATA_EXISTS_p return varchar2;
	Function C_NLS_VOID_p return varchar2;
	Function C_NLS_NA_p return varchar2;
	Function C_NLS_END_OF_REPORT_p return varchar2;
	Function C_REPORT_START_DATE_p return date;
	Function C_BASE_CURRENCY_CODE_p return varchar2;
	Function C_BASE_PRECISION_p return number;
	Function C_BASE_MIN_ACCT_UNIT_p return number;
	Function C_BASE_DESCRIPTION_p return varchar2;
	Function C_CHART_OF_ACCOUNTS_ID_p return number;
	--Function Applications Template Report_p return varchar2;
	Function Applications_Template_Report_p return varchar2;
	Function C_COMPANY_NAME_p return varchar2;
	Function C_curdate_p return varchar2;
END AP_APXT7UTT_XMLP_PKG;


/
