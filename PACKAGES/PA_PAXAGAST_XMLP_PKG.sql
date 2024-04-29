--------------------------------------------------------
--  DDL for Package PA_PAXAGAST_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PAXAGAST_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAXAGASTS.pls 120.0 2008/01/02 11:13:44 krreddy noship $ */
	CUST	number;
	AGREE	varchar2(50);
	SORT	varchar2(40);
	P_debug_mode	varchar2(3);
	P_CONC_REQUEST_ID	number;
	P_rule_optimizer	varchar2(3);
	C_COMPANY_NAME_HEADER	varchar2(50);
	C_customer_name	varchar2(50);
	C_sort	varchar2(25);
	FUNCTION  get_cover_page_values   RETURN BOOLEAN  ;
	function BeforeReport return boolean  ;
	FUNCTION  get_company_name    RETURN BOOLEAN  ;
	function AfterReport return boolean  ;
	function CF_1Formula return VARCHAR2  ;
	Function C_COMPANY_NAME_HEADER_p return varchar2;
	Function C_customer_name_p return varchar2;
	Function C_sort_p return varchar2;
END PA_PAXAGAST_XMLP_PKG;

/
