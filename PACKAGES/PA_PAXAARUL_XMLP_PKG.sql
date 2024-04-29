--------------------------------------------------------
--  DDL for Package PA_PAXAARUL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PAXAARUL_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAXAARULS.pls 120.0 2008/01/02 11:08:15 krreddy noship $ */
	P_rule_optimizer	varchar2(3);
	P_debug_mode	varchar2(3);
	P_CONC_REQUEST_ID	number;
	P_RULE_ID	varchar2(40);
	C_COMPANY_NAME_HEADER	varchar2(50);
	C_no_data_found	varchar2(80);
	C_dummy_data	number;
	C_rule_name	varchar2(60);
	FUNCTION  get_cover_page_values   RETURN BOOLEAN  ;
	function BeforeReport return boolean  ;
	FUNCTION  get_company_name    RETURN BOOLEAN  ;
	function AfterReport return boolean  ;
	Function C_COMPANY_NAME_HEADER_p return varchar2;
	Function C_no_data_found_p return varchar2;
	Function C_dummy_data_p return number;
	Function C_rule_name_p return varchar2;
END PA_PAXAARUL_XMLP_PKG;

/
