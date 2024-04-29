--------------------------------------------------------
--  DDL for Package FA_FASWIPCR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_FASWIPCR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: FASWIPCRS.pls 120.0.12010000.1 2008/07/28 13:17:54 appldev ship $ */
	P_BOOK	varchar2(15);
	P_PERIOD1	varchar2(15);
	P_CONC_REQUEST_ID	number;
	P_PERIOD2	varchar2(15);
	P_MIN_PRECISION	number;
	Accounting_Flex_Structure	number;
	ACCT_BAL_APROMPT	varchar2(222);
	ACCT_CC_APROMPT	varchar2(222);
	Currency_Code	varchar2(15);
	Period1_PC	number;
	Period1_PCD	varchar2(21);
	Period1_POD	varchar2(21);
	Period1_FY	number;
	Period2_FY	number;
	Period2_PCD	varchar2(21);
	Period2_POD	varchar2(21);
	Period2_PC	number;
	Precision	number;
	RP_COMPANY_NAME	varchar2(30);
	RP_REPORT_NAME	varchar2(80);
	RP_BAL_LPROMPT	varchar2(222);
	RP_CC_LPROMPT	varchar2(222);
	function BookFormula return VARCHAR2  ;
	function Period1Formula return VARCHAR2  ;
	function report_nameformula(Company_Name in varchar2) return varchar2  ;
	function Period2Formula return VARCHAR2  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function d_lifeformula(life in number, adj_rate in number, capacity in number) return varchar2  ;
	Function Accounting_Flex_Structure_p return number;
	Function ACCT_BAL_APROMPT_p return varchar2;
	Function ACCT_CC_APROMPT_p return varchar2;
	Function Currency_Code_p return varchar2;
	Function Period1_PC_p return number;
	Function Period1_PCD_p return varchar2;
	Function Period1_POD_p return varchar2;
	Function Period1_FY_p return number;
	Function Period2_FY_p return number;
	Function Period2_PCD_p return varchar2;
	Function Period2_POD_p return varchar2;
	Function Period2_PC_p return number;
	Function Precision_p return number;
	Function RP_COMPANY_NAME_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
	--Function RP_BAL_LPROMPT_p return varchar2;
	 Function RP_BAL_LPROMPT_p(ACCT_BAL_LPROMPT VARCHAR2) return varchar2 ;
	--Function RP_CC_LPROMPT_p return varchar2;
	 Function RP_CC_LPROMPT_p(ACCT_CC_LPROMPT VARCHAR2) return varchar2 ;

	--added
	FUNCTION fadolif(life NUMBER,
		adj_rate NUMBER,
		bonus_rate NUMBER,
		prod NUMBER)
RETURN CHAR ;
END FA_FASWIPCR_XMLP_PKG;


/
