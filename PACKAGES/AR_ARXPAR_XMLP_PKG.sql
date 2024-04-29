--------------------------------------------------------
--  DDL for Package AR_ARXPAR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_ARXPAR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: ARXPARS.pls 120.0 2007/12/27 13:58:40 abraghun noship $ */
	P_Set_of_Books_Id	number;
	P_conc_request_id	number;
	RP_COMPANY_NAME	varchar2(30);
	RP_REPORT_NAME	varchar2(240);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function report_nameformula(Company_Name in varchar2) return varchar2  ;
	function NLS_YESFormula return VARCHAR2  ;
	function NLS_NOFormula return VARCHAR2  ;
	Function RP_COMPANY_NAME_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
END AR_ARXPAR_XMLP_PKG;


/
