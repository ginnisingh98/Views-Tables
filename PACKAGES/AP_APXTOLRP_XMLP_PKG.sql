--------------------------------------------------------
--  DDL for Package AP_APXTOLRP_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_APXTOLRP_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: APXTOLRPS.pls 120.0 2007/12/27 08:40:13 vjaganat noship $ */
	P_DEBUG_SWITCH	varchar2(1);
	P_TRACE_SWITCH	varchar2(1);
	P_CONC_REQUEST_ID	number;
	C_NLS_YES	varchar2(80);
	C_NLS_NO	varchar2(80);
	C_NLS_ALL	varchar2(80);
	C_NLS_NO_DATA_EXISTS	varchar2(240);
	C_NLS_VOID	varchar2(80);
	C_NLS_NA	varchar2(80);
	C_NLS_END_OF_REPORT	varchar2(100);
	C_REPORT_START_DATE	date;
	C_COMPANY_NAME_HEADER	varchar2(50);
	--Applications Template Report	varchar2(1);
	Applications_Template_Report	varchar2(1);
	FUNCTION  get_base_curr_data  RETURN BOOLEAN  ;
	FUNCTION  custom_init         RETURN BOOLEAN  ;
	FUNCTION  get_cover_page_values   RETURN BOOLEAN  ;
	FUNCTION  get_nls_strings     RETURN BOOLEAN  ;
	function BeforeReport return boolean ;
	FUNCTION tolerance_hold_names RETURN BOOLEAN  ;
	function AfterReport return boolean  ;
	Function C_NLS_YES_p return varchar2;
	Function C_NLS_NO_p return varchar2;
	Function C_NLS_ALL_p return varchar2;
	Function C_NLS_NO_DATA_EXISTS_p return varchar2;
	Function C_NLS_VOID_p return varchar2;
	Function C_NLS_NA_p return varchar2;
	Function C_NLS_END_OF_REPORT_p return varchar2;
	Function C_REPORT_START_DATE_p return date;
	Function C_COMPANY_NAME_HEADER_p return varchar2;
	--Function Applications Template Report_p return varchar2;
	Function Applications_Template_Report_p return varchar2;
END AP_APXTOLRP_XMLP_PKG;


/
