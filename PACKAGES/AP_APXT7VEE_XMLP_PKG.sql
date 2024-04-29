--------------------------------------------------------
--  DDL for Package AP_APXT7VEE_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_APXT7VEE_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: APXT7VEES.pls 120.0 2007/12/27 08:39:16 vjaganat noship $ */
	P_DEBUG_SWITCH	varchar2(1);
	P_CONC_REQUEST_ID	number;
	P_MIN_PRECISION	number;
	P_FLEXDATA	varchar2(600);
	P_SET_OF_BOOKS_ID	number;
	P_TRACE_SWITCH	varchar2(1);
	P_REP_ENTITY_ID	number;
	P_START_DATE	date;
	P_END_DATE	date;
	P_Query_driver	varchar2(32767);
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
	C_BALANCING_SEGMENT	varchar2(30);
	C_REP_ENTITY_NAME	varchar2(250);
	C_REPORTABLE_ONLY	varchar2(20);
	C_DYNAMIC_SQL	varchar2(200);
	C_MISC_TOTAL	varchar2(2000);
	CP_Payment_Date	varchar2(2000);
	FUNCTION  get_base_curr_data  RETURN BOOLEAN  ;
	FUNCTION  custom_init         RETURN BOOLEAN  ;
	FUNCTION  get_cover_page_values   RETURN BOOLEAN  ;
	FUNCTION  get_nls_strings     RETURN BOOLEAN  ;
	function BeforeReport return boolean ;
	function AfterReport return boolean  ;
	FUNCTION  get_company_name    RETURN BOOLEAN  ;
	FUNCTION get_flexdata RETURN BOOLEAN  ;
	FUNCTION Get_Balancing_Segment RETURN BOOLEAN ;
	FUNCTION Get_Entity_Name RETURN BOOLEAN ;
	FUNCTION GET_MISC_TOTAL RETURN BOOLEAN ;
	FUNCTION GET_PAYMENT_EXISTS RETURN BOOLEAN ;
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
	Function C_BALANCING_SEGMENT_p return varchar2;
	Function C_REP_ENTITY_NAME_p return varchar2;
	Function C_REPORTABLE_ONLY_p return varchar2;
	Function C_DYNAMIC_SQL_p return varchar2;
	Function C_MISC_TOTAL_p return varchar2;
	Function CP_Payment_Date_p return varchar2;
END AP_APXT7VEE_XMLP_PKG;


/
