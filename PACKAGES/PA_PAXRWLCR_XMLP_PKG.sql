--------------------------------------------------------
--  DDL for Package PA_PAXRWLCR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PAXRWLCR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAXRWLCRS.pls 120.0 2008/01/02 11:59:44 krreddy noship $ */
	EFFECTIVE_DATE	date;
	P_COMPENSATION_RULE_SET	varchar2(40);
	JOB_LEVEL	varchar2(60);
	JOB_DISCIPLINE	varchar2(60);
	SORT_BY	varchar2(40);
	P_conc_request_id	number;
	C_Company_Name_Header	varchar2(40);
	C_Sort_by_Name	varchar2(60);
	FUNCTION  get_company_name    RETURN BOOLEAN  ;
	function BeforeReport return boolean  ;
	function AfterPForm return boolean  ;
	function BetweenPage return boolean  ;
	function AfterReport return boolean  ;
	function CF_Currency_CodeFormula return Char  ;
	Function C_Company_Name_Header_p return varchar2;
	Function C_Sort_by_Name_p return varchar2;
END PA_PAXRWLCR_XMLP_PKG;

/
