--------------------------------------------------------
--  DDL for Package AP_APXINMHD_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_APXINMHD_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: APXINMHDS.pls 120.0 2007/12/27 07:58:10 vjaganat noship $ */
	P_CONC_REQUEST_ID	number;
	P_MINPRECISION	number;
	P_DEBUG_SWITCH	varchar2(1);
	P_SOB_ID	number;
	P_WHERE	varchar2(5000):='where 1=1';
	P_MATCH_TYPE	varchar2(32767);
	P_TEST_VENDOR_ID	varchar2(15);
	P_HOLD_DETAIL_TYPE	varchar2(13);
	P_START_ACTIVITY_DATE	date;
	P_END_ACTIVITY_DATE	date;
	P_FLEXDATA	varchar2(800);
	P_ITEM_STRUCT_NUM	number;
	--C_BASE_CURRENCY_CODE	varchar2(32767) := := '$$$' ;
        C_BASE_CURRENCY_CODE	varchar2(32767) :=  '$$$' ;
	C_BASE_PRECISION	number := 2 ;
	C_BASE_MIN_ACCT_UNIT	number;
	--C_NLS_YES	varchar2(80) := := 'Yes' ;
	C_NLS_YES	varchar2(80) :=  'Yes' ;
        --C_NLS_NO	varchar2(80) := := 'No' ;
	C_NLS_NO	varchar2(80) :=  'No' ;
	C_NLS_ALL	varchar2(80);
	--C_COMPANY_NAME_HEADER	varchar2(30) := := 'No Company Name' ;
	C_COMPANY_NAME_HEADER	varchar2(30) :=  'No Company Name' ;
	C_CHART_OF_ACCOUNTS_ID	number;
	C_NLS_RELEASED	varchar2(80);
	C_NLS_HELD	varchar2(80);
	C_NLS_NO_DATA_EXISTS	varchar2(240);
	C_REPORT_START_DATE	date;
	C_NLS_END_OF_REPORT	varchar2(100);
	C_NLS_NA	varchar2(20);
	function BeforeReport return boolean ;
	function AfterReport return boolean  ;
	FUNCTION  custom_init         RETURN BOOLEAN  ;
	FUNCTION  get_base_curr_data  RETURN BOOLEAN  ;
	FUNCTION  get_company_name    RETURN BOOLEAN  ;
	FUNCTION  get_nls_strings     RETURN BOOLEAN  ;
	FUNCTION  get_nls_released_held    RETURN BOOLEAN  ;
	FUNCTION get_flexdata RETURN BOOLEAN  ;
	--function c_accepted_fmtformula(C_MATCHING_BASIS ;
	function c_accepted_fmtformula(C_MATCHING_BASIS in varchar2, C_ACCEPTED in varchar2) return varchar2 ;
	Function C_BASE_CURRENCY_CODE_p return varchar2;
	Function C_BASE_PRECISION_p return number;
	Function C_BASE_MIN_ACCT_UNIT_p return number;
	Function C_NLS_YES_p return varchar2;
	Function C_NLS_NO_p return varchar2;
	Function C_NLS_ALL_p return varchar2;
	Function C_COMPANY_NAME_HEADER_p return varchar2;
	Function C_CHART_OF_ACCOUNTS_ID_p return number;
	Function C_NLS_RELEASED_p return varchar2;
	Function C_NLS_HELD_p return varchar2;
	Function C_NLS_NO_DATA_EXISTS_p return varchar2;
	Function C_REPORT_START_DATE_p return date;
	Function C_NLS_END_OF_REPORT_p return varchar2;
	Function C_NLS_NA_p return varchar2;
END AP_APXINMHD_XMLP_PKG;


/
