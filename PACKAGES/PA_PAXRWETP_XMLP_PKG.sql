--------------------------------------------------------
--  DDL for Package PA_PAXRWETP_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PAXRWETP_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAXRWETPS.pls 120.2 2008/01/03 12:23:58 krreddy noship $ */
	EXPENDITURE_CATEGORY	varchar2(30);
	EFFECTIVE_DATE	date;
	P_CONC_REQUEST_ID	number;
	P_debug_mode	varchar2(3);
	P_rule_optimizer	varchar2(3);
	C_COMPANY_NAME_HEADER	varchar2(50);
	c_no_data_found	varchar2(80);
	FUNCTION  get_cover_page_values   RETURN BOOLEAN  ;
	function BeforeReport return boolean  ;
	FUNCTION  get_company_name    RETURN BOOLEAN  ;
	FUNCTION NO_DATA_FOUND_FUNC RETURN BOOLEAN  ;
	function AfterReport return boolean  ;
	Function C_COMPANY_NAME_HEADER_p return varchar2;
	Function c_no_data_found_p return varchar2;
END PA_PAXRWETP_XMLP_PKG;

/
