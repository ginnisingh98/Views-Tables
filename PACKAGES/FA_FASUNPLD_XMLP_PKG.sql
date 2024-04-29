--------------------------------------------------------
--  DDL for Package FA_FASUNPLD_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_FASUNPLD_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: FASUNPLDS.pls 120.0.12010000.1 2008/07/28 13:17:49 appldev ship $ */
	P_DEBUG_SWITCH	varchar2(1);
	P_CONC_REQUEST_ID	number;
	P_MIN_PRECISION	number;
	P_FLEXDATA	varchar2(600);
	P_SET_OF_BOOKS_ID	number;
	P_DEPRN_TYPE	varchar2(32767);
	--added
	P_DEPRN_TYPE_1 varchar2(32767);
	P_ASSET_BOOK_TYPE	varchar2(40);
	P_PERIOD_END_NAME	varchar2(40);
	P_PERIOD_START_NAME	varchar2(40);
	C_base_currency_code	varchar2(15);
	C_BASE_PRECISION	number;
	C_BASE_MIN_ACCT_UNIT	number;
	C_BASE_DESCRIPTION	varchar2(240);
	C_COMPANY_NAME_HEADER	varchar2(50);
	C_REPORT_START_DATE	date;
	C_NLS_YES	varchar2(80);
	C_NLS_NO	varchar2(80);
	C_NLS_ALL	varchar2(25);
	C_NLS_NO_DATA_EXISTS	varchar2(240);
	C_CHART_OF_ACCOUNTS_ID	number;
	C_NLS_VOID	varchar2(25);
	C_NLS_NA	varchar2(25);
	C_NLS_END_OF_REPORT	varchar2(100);
	C_Last_Open	varchar2(20);
	FUNCTION  get_base_curr_data  RETURN BOOLEAN  ;
	FUNCTION  custom_init         RETURN BOOLEAN  ;
	FUNCTION  get_cover_page_values   RETURN BOOLEAN  ;
	FUNCTION  get_nls_strings     RETURN BOOLEAN  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	FUNCTION  get_company_name    RETURN BOOLEAN  ;
	function P_DEPRN_TYPEValidTrigger return boolean  ;
	Function C_base_currency_code_p return varchar2;
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
	Function C_NLS_VOID_p return varchar2;
	Function C_NLS_NA_p return varchar2;
	Function C_NLS_END_OF_REPORT_p return varchar2;
	Function C_Last_Open_p return varchar2;
END FA_FASUNPLD_XMLP_PKG;


/
