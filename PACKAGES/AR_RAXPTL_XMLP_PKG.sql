--------------------------------------------------------
--  DDL for Package AR_RAXPTL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_RAXPTL_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: RAXPTLS.pls 120.0 2007/12/27 14:32:42 abraghun noship $ */
	P_CONC_REQUEST_ID	number;
	RP_COMPANY_NAME	varchar2(50);
	RP_REPORT_NAME	varchar2(80);
	RP_DATA_FOUND	varchar2(300);
	RP_SUB_TITLE	varchar2(80);
	function report_nameformula(Company_Name in varchar2) return varchar2  ;
	function BeforeReport return boolean  ;
	function Sub_TitleFormula return VARCHAR2  ;
	function AfterReport return boolean  ;
	Function RP_COMPANY_NAME_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
	Function RP_DATA_FOUND_p return varchar2;
	Function RP_SUB_TITLE_p return varchar2;
	function D_Relative_AmountFormula return VARCHAR2;
END AR_RAXPTL_XMLP_PKG;


/
