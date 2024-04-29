--------------------------------------------------------
--  DDL for Package PA_PAXAASRP_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PAXAASRP_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAXAASRPS.pls 120.0 2008/01/02 11:08:57 krreddy noship $ */
	P_FUNCTION_CODE	varchar2(40);
	P_debug_mode	varchar2(3);
	P_CONC_REQUEST_ID	number;
	P_rule_optimizer	varchar2(3);
	C_COMPANY_NAME_HEADER	varchar2(50);
	C_function_name	varchar2(40);
	FUNCTION  get_cover_page_values   RETURN BOOLEAN  ;
	function BeforeReport return boolean  ;
	FUNCTION  get_company_name    RETURN BOOLEAN  ;
	function AfterReport return boolean  ;
	Function C_COMPANY_NAME_HEADER_p return varchar2;
	Function C_function_name_p return varchar2;
END PA_PAXAASRP_XMLP_PKG;

/
