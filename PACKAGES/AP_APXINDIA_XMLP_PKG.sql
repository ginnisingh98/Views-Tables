--------------------------------------------------------
--  DDL for Package AP_APXINDIA_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_APXINDIA_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: APXINDIAS.pls 120.0 2007/12/27 07:49:44 vjaganat noship $ */
	P_SOB_ID	number;
	P_CONC_REQUEST_ID	number;
	P_DEBUG_SWITCH	varchar2(1);
	P_VEN_ID	varchar2(15) := 'All';
	P_VENDOR_TYPE	varchar2(25) := 'All';
	P_PAY_GROUP	varchar2(25) := 'All';
	P_MIN_DISC_AMOUNT	number;
	P_MIN_INV_AMOUNT	number;
	P_DISC_THRU_DATE	date;
	P_DISC_THRU_DATE_p	varchar2(15);
	P_MIN_PRECISION	number;
	C_BASE_MIN_ACCT_UNIT	number;
	C_VEN_NAME	varchar2(240);
	--C_BASE_CURRENCY_CODE	varchar2(15) := := '$$$' ;
	C_BASE_CURRENCY_CODE	varchar2(15) := '$$$' ;
	C_TEST_DATE	varchar2(9);
	C_BASE_PRECISION	number := 2 ;
	--C_NLS_ALL	varchar2(80) := := 'All' ;
	C_NLS_ALL	varchar2(80) := 'All' ;
	C_PAY_GROUP	varchar2(80);
	C_NLS_NO_DATA_EXISTS	varchar2(240);
	C_VENDOR_TYPE	varchar2(80);
	--C_COMPANY_NAME_HEADER	varchar2(30) := := 'No Company Name' ;
	C_COMPANY_NAME_HEADER	varchar2(30) := 'No Company Name' ;
	C_REPORT_START_DATE	date;
	C_REPORT_RUN_TIME	varchar2(32767);
	C_NLS_END_OF_REPORT	varchar2(100);
	function BeforeReport return boolean ;
	FUNCTION  get_nls_strings     RETURN BOOLEAN  ;
	FUNCTION  get_base_curr_data  RETURN BOOLEAN  ;
	FUNCTION  get_company_name    RETURN BOOLEAN  ;
	function AfterReport return boolean  ;
	FUNCTION  custom_init         RETURN BOOLEAN  ;
	FUNCTION  get_header_values   RETURN BOOLEAN  ;
	Function C_BASE_MIN_ACCT_UNIT_p return number;
	Function C_VEN_NAME_p return varchar2;
	Function C_BASE_CURRENCY_CODE_p return varchar2;
	Function C_TEST_DATE_p return varchar2;
	Function C_BASE_PRECISION_p return number;
	Function C_NLS_ALL_p return varchar2;
	Function C_PAY_GROUP_p return varchar2;
	Function C_NLS_NO_DATA_EXISTS_p return varchar2;
	Function C_VENDOR_TYPE_p return varchar2;
	Function C_COMPANY_NAME_HEADER_p return varchar2;
	Function C_REPORT_START_DATE_p return date;
	Function C_REPORT_RUN_TIME_p return varchar2;
	Function C_NLS_END_OF_REPORT_p return varchar2;
END AP_APXINDIA_XMLP_PKG;


/
