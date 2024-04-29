--------------------------------------------------------
--  DDL for Package PA_PAXSMPRD_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PAXSMPRD_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAXSMPRDS.pls 120.0 2008/01/02 12:19:05 krreddy noship $ */
	P_rule_optimizer	varchar2(3);
	P_debug_mode	varchar2(3);
	P_CONC_REQUEST_ID	number;
	P_Period_name	varchar2(32767);
	C_COMPANY_NAME_HEADER	varchar2(50);
	C_no_data_found	varchar2(80);
	C_dummy_data	number;
	FUNCTION  get_cover_page_values   RETURN BOOLEAN  ;
	function BeforeReport return boolean  ;
	FUNCTION  get_company_name    RETURN BOOLEAN  ;
	function AfterReport return boolean  ;
	Function C_COMPANY_NAME_HEADER_p return varchar2;
	Function C_no_data_found_p return varchar2;
	Function C_dummy_data_p return number;
END PA_PAXSMPRD_XMLP_PKG;

/
