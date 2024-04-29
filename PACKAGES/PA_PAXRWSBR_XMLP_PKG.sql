--------------------------------------------------------
--  DDL for Package PA_PAXRWSBR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PAXRWSBR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAXRWSBRS.pls 120.0 2008/01/02 12:16:54 krreddy noship $ */
	ORGANIZATION_ID	number;
	STD_BILL_RATE_SCHEDULE	varchar2(40);
	EFFECTIVE_DATE	date;
	P_rule_optimizer	varchar2(3);
	P_CONC_REQUEST_ID	number;
	C_COMPANY_NAME_HEADER	varchar2(50);
	C_org_name	varchar2(240);
	EFFECTIVE_DATE1 varchar2(25);
	FUNCTION  get_cover_page_values   RETURN BOOLEAN  ;
	function BeforeReport return boolean  ;
	FUNCTION  get_company_name    RETURN BOOLEAN  ;
	function CF_ACCT_CURRENCY_CODEFormula return varchar2  ;
	function AfterReport return boolean  ;
	Function C_COMPANY_NAME_HEADER_p return varchar2;
	Function C_org_name_p return varchar2;
END PA_PAXRWSBR_XMLP_PKG;

/
