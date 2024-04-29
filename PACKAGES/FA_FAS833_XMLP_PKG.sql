--------------------------------------------------------
--  DDL for Package FA_FAS833_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_FAS833_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: FAS833S.pls 120.0.12010000.1 2008/07/28 13:15:56 appldev ship $ */
	P_BOOK	varchar2(15);
	P_CONC_REQUEST_ID	number;
	P_MIN_PRECISION	number;
	Accounting_Flex_Structure	number;
	Currency_Code	varchar2(15);
	RP_COMPANY_NAME	varchar2(30);
	RP_REPORT_NAME	varchar2(80);
	RP_DATA_FOUND	varchar2(3);
	function BookFormula return VARCHAR2  ;
	function report_nameformula(Company_Name in varchar2) return varchar2  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function d_statusformula(STATUS in varchar2) return varchar2  ;
	Function Accounting_Flex_Structure_p return number;
	Function Currency_Code_p return varchar2;
	Function RP_COMPANY_NAME_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
	Function RP_DATA_FOUND_p return varchar2;
--Added during DT Fixes
        function D_COSTFormula return VARCHAR2;
--End of DT Fixes
END FA_FAS833_XMLP_PKG;


/
