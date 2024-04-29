--------------------------------------------------------
--  DDL for Package FA_FAS430_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_FAS430_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: FAS430S.pls 120.0.12010000.1 2008/07/28 13:14:28 appldev ship $ */
	P_BOOK	varchar2(15);
	P_PERIOD1	varchar2(15);
	P_CONC_REQUEST_ID	number;
	P_MASS_REF_ID	number;
	Accounting_Flex_Structure	number;
	Currency_Code	varchar2(15);
	Period1_PC	number;
	Period1_PCD	date;
	Period1_POD	date;
	RP_COMPANY_NAME	varchar2(30);
	RP_REPORT_NAME	varchar2(80);
	RP_DATA_FOUND	varchar2(3);
	RP_BAL_APROMPT	varchar2(200);
	RP_CC_APROMPT	varchar2(200);
	RP_CURRENCY_CODE	varchar2(15);
	function BookFormula return VARCHAR2  ;
	function Period1Formula return VARCHAR2  ;
	function report_nameformula(Company_Name in varchar2, ACCT_BAL_APROMPT in varchar2, ACCT_CC_APROMPT in varchar2) return varchar2  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	Function Accounting_Flex_Structure_p return number;
	Function Currency_Code_p return varchar2;
	Function Period1_PC_p return number;
	Function Period1_PCD_p return date;
	Function Period1_POD_p return date;
	Function RP_COMPANY_NAME_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
	Function RP_DATA_FOUND_p return varchar2;
	Function RP_BAL_APROMPT_p return varchar2;
	Function RP_CC_APROMPT_p return varchar2;
	Function RP_CURRENCY_CODE_p return varchar2;
--Added during DT Fix
        function D_AS_COSTFormula return VARCHAR2;
--End of DT Fix
END FA_FAS430_XMLP_PKG;


/
