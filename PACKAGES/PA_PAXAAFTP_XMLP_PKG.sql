--------------------------------------------------------
--  DDL for Package PA_PAXAAFTP_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PAXAAFTP_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAXAAFTPS.pls 120.0 2008/01/02 11:07:32 krreddy noship $ */
	P_FUNCTION_CODE	varchar2(40);
	P_debug_mode	varchar2(3);
	P_CONC_REQUEST_ID	number;
	P_rule_optimizer	varchar2(3);
	C_COMPANY_NAME_HEADER	varchar2(50);
	c_no_data_found	varchar2(80);
	C_function_code	varchar2(40);
	FUNCTION  get_cover_page_values   RETURN BOOLEAN  ;
	function BeforeReport return boolean  ;
	FUNCTION  get_company_name    RETURN BOOLEAN  ;
	FUNCTION NO_DATA_FOUND_FUNC RETURN BOOLEAN  ;
	function AfterReport return boolean  ;
	Function C_COMPANY_NAME_HEADER_p return varchar2;
	Function c_no_data_found_p return varchar2;
	Function C_function_code_p return varchar2;
END PA_PAXAAFTP_XMLP_PKG;

/
