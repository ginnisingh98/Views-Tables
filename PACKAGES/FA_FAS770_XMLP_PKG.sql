--------------------------------------------------------
--  DDL for Package FA_FAS770_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_FAS770_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: FAS770S.pls 120.0.12010000.1 2008/07/28 13:15:30 appldev ship $ */
	P_BOOK	varchar2(15);
	P_CONC_REQUEST_ID	number;
	P_MIN_PRECISION	number;
	P_FISCAL_YEAR	number;
	P_ADJUSTED	varchar2(40);
	Accounting_Flex_Structure	number;
	ACCT_BAL_APROMPT	varchar2(222);
	Currency_Code	varchar2(15);
	Book_Class	varchar2(15);
	Distribution_Source_Book	varchar2(15);
	RP_COMPANY_NAME	varchar2(30);
	RP_REPORT_NAME	varchar2(80);
	C_BAL_LPROMPT	varchar2(222);
	function BookFormula return VARCHAR2  ;
	function report_nameformula(Company_Name in varchar2, ACCT_BAL_LPROMPT in varchar2) return varchar2  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function report_period_close_dateformul(end_period_counter in number) return varchar2  ;
	function d_lifeformula(life_in_months in number, adj_rate in number, bonus_rate in number, prod in number) return varchar2  ;
	Function Accounting_Flex_Structure_p return number;
	Function ACCT_BAL_APROMPT_p return varchar2;
	Function Currency_Code_p return varchar2;
	Function Book_Class_p return varchar2;
	Function Distribution_Source_Book_p return varchar2;
	Function RP_COMPANY_NAME_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
	Function C_BAL_LPROMPT_p return varchar2;
FUNCTION fadolif(life NUMBER,
		adj_rate NUMBER,
		bonus_rate NUMBER,
		prod NUMBER)
RETURN CHAR;
END FA_FAS770_XMLP_PKG;


/
