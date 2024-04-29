--------------------------------------------------------
--  DDL for Package AP_APXCMINV_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_APXCMINV_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: APXCMINVS.pls 120.0 2007/12/27 07:37:07 vjaganat noship $ */
	P_VENDOR_FROM	varchar2(240);
	P_VENDOR_TO	varchar2(240);
	P_DATE_FROM	date;
	P_DATE_TO	date;
	LP_DATE_FROM	VARCHAR2(25);
	LP_DATE_TO	VARCHAR2(25);
	P_NAME	varchar2(30);
	P_SET_OF_BOOKS_ID	number;
	P_CHART_OF_ACCOUNTS_ID	number;
	P_MIN_PRECISION	number;
	P_CONC_REQUEST_ID	number;
	P_DEBUG_SWITCH	varchar2(1);
	P_TRACE_SWITCH	varchar2(1);
	C_VENDOR	varchar2(240);
	C_DATE	varchar2(240);
	C_BASE_CURRENCY_CODE	varchar2(15);
	C_BASE_MIN_ACCT_UNIT	number;
	C_BASE_PRECISION	number;
	C_BASE_DESCRIPTION	varchar2(240);
	function BeforeReport return boolean ;
	FUNCTION  get_base_curr_data  RETURN BOOLEAN  ;
	function AfterReport return boolean  ;
	Function C_VENDOR_p return varchar2;
	Function C_DATE_p return varchar2;
	Function C_BASE_CURRENCY_CODE_p return varchar2;
	Function C_BASE_MIN_ACCT_UNIT_p return number;
	Function C_BASE_PRECISION_p return number;
	Function C_BASE_DESCRIPTION_p return varchar2;
END AP_APXCMINV_XMLP_PKG;


/
