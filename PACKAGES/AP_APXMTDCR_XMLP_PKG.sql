--------------------------------------------------------
--  DDL for Package AP_APXMTDCR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_APXMTDCR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: APXMTDCRS.pls 120.0 2007/12/27 08:13:22 vjaganat noship $ */
	P_FLEXDATA	varchar2(800);
	P_CONC_REQUEST_ID	number;
	P_MINPRECISION	number;
	P_DEBUG_SWITCH	varchar2(1);
	P_SOB_ID	number;
	P_START_DATE	date;
	CP_START_DATE	varchar2(25);
	P_END_DATE	date;
	CP_END_DATE	varchar2(25);
	P_ADDR_OPTION	varchar2(4);
	P_MINIMUM_PRECISION	number;
	P_PAYMENT_TYPE	varchar2(1);
	--C_BASE_CURRENCY_CODE	varchar2(32767) := := '$$$' ;
	C_BASE_CURRENCY_CODE	varchar2(32767) :=  '$$$' ;
	C_BASE_PRECISION	number := 2 ;
	C_BASE_MIN_ACCT_UNIT	number;
	--C_NLS_YES	varchar2(80) := := 'Yes' ;
	C_NLS_YES	varchar2(80) :=  'Yes' ;
	--C_NLS_NO	varchar2(80) := := 'No' ;
	C_NLS_NO	varchar2(80) :=  'No' ;
	C_NLS_ACTIVE	varchar2(80);
	--C_COMPANY_NAME_HEADER	varchar2(30) := := 'No Company Name' ;
	C_COMPANY_NAME_HEADER	varchar2(30) :=  'No Company Name' ;
	C_CHART_OF_ACCOUNTS_ID	number;
	C_NLS_INACTIVE	varchar2(80);
	C_NLS_NO_DATA_EXISTS	varchar2(80);
	C_NLS_VOID_PAYMENT_NOT_INCL	varchar2(100);
	C_CURRENCY	varchar2(5);
	C_CURRENCY_FLAG	varchar2(15);
	C_PAY_CURRENCY_FLAG	varchar2(15);
	C_PLACE_FLAG	varchar2(32767);
	C_VOIDED_FLAG	varchar2(1);
	C_NLS_PAYMENT_TYPE	varchar2(80);
	C_NLS_ALL	varchar2(80);
	C_NLS_END_OF_REPORT	varchar2(100);
	C_NLS_ADDR_OPTION	varchar2(80);
	C_NLS_NONE_EP	varchar2(30);
	function BeforeReport return boolean ;
	function AfterReport return boolean  ;
	FUNCTION  get_base_curr_data  RETURN BOOLEAN  ;
	FUNCTION  get_company_name    RETURN BOOLEAN  ;
	FUNCTION  get_nls_strings     RETURN BOOLEAN  ;
	function  get_currency    (currency_code_1 in varchar2, pay_currency_code in varchar2) return boolean  ;
	function check_flag(C_CURRENCY_CODE in varchar2, C_PAY_CURRENCY_CODE in varchar2) return varchar2  ;
	function c_currency_descformula(c_currency_code in varchar2) return varchar2  ;
	function c_pay_currency_descformula(c_pay_currency_code in varchar2) return varchar2  ;
	Function C_BASE_CURRENCY_CODE_p return varchar2;
	Function C_BASE_PRECISION_p return number;
	Function C_BASE_MIN_ACCT_UNIT_p return number;
	Function C_NLS_YES_p return varchar2;
	Function C_NLS_NO_p return varchar2;
	Function C_NLS_ACTIVE_p return varchar2;
	Function C_COMPANY_NAME_HEADER_p return varchar2;
	Function C_CHART_OF_ACCOUNTS_ID_p return number;
	Function C_NLS_INACTIVE_p return varchar2;
	Function C_NLS_NO_DATA_EXISTS_p return varchar2;
	Function C_NLS_VOID_PAYMENT_NOT_INCL_p return varchar2;
	Function C_CURRENCY_p return varchar2;
	Function C_CURRENCY_FLAG_p return varchar2;
	Function C_PAY_CURRENCY_FLAG_p return varchar2;
	Function C_PLACE_FLAG_p return varchar2;
	Function C_VOIDED_FLAG_p return varchar2;
	Function C_NLS_PAYMENT_TYPE_p return varchar2;
	Function C_NLS_ALL_p return varchar2;
	Function C_NLS_END_OF_REPORT_p return varchar2;
	Function C_NLS_ADDR_OPTION_p return varchar2;
	Function C_NLS_NONE_EP_p return varchar2;
END AP_APXMTDCR_XMLP_PKG;


/
