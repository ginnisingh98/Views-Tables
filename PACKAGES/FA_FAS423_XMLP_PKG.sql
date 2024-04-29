--------------------------------------------------------
--  DDL for Package FA_FAS423_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_FAS423_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: FAS423S.pls 120.0.12010000.1 2008/07/28 13:14:25 appldev ship $ */
	P_BOOK	varchar2(15);
	P_PERIOD1	varchar2(15);
	P_CONC_REQUEST_ID	number;
	P_PERIOD2	varchar2(15);
	P_MIN_PRECISION	number;
	Accounting_Flex_Structure	number;
	ACCT_BAL_APROMPT	varchar2(200);
	ACCT_CC_APROMPT	varchar2(200);
	CAT_MAJ_APROMPT	varchar2(200);
	Currency_Code	varchar2(15);
	Book_Class	varchar2(15);
	Distribution_Source_Book	varchar2(15);
	Period1_PC	number;
	Period1_PCD	date;
	Period1_POD	date;
	Period1_FY	number;
	Period2_FY	number;
	Period2_PCD	date;
	Period2_POD	date;
	Period2_PC	number;
	RP_COMPANY_NAME	varchar2(30);
	RP_REPORT_NAME	varchar2(80);
	RP_PERIOD_RANGE	varchar2(60);
	function BookFormula return VARCHAR2  ;
	function Period1Formula return VARCHAR2  ;
	function report_nameformula(Company_Name in varchar2) return varchar2  ;
	function Period2Formula return VARCHAR2  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function d_lifeformula(life in number, adj_rate in number, bonus_rate in number, prod in number) return varchar2  ;
	FUNCTION do_life77(life NUMBER,
		adj_rate NUMBER,
		bonus_rate NUMBER,
		prod NUMBER)
RETURN VARCHAR2  ;
	Function Accounting_Flex_Structure_p return number;
	Function ACCT_BAL_APROMPT_p return varchar2;
	Function ACCT_CC_APROMPT_p return varchar2;
	Function CAT_MAJ_APROMPT_p return varchar2;
	Function Currency_Code_p return varchar2;
	Function Book_Class_p return varchar2;
	Function Distribution_Source_Book_p return varchar2;
	Function Period1_PC_p return number;
	Function Period1_PCD_p return date;
	Function Period1_POD_p return date;
	Function Period1_FY_p return number;
	Function Period2_FY_p return number;
	Function Period2_PCD_p return date;
	Function Period2_POD_p return date;
	Function Period2_PC_p return number;
	Function RP_COMPANY_NAME_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
	Function RP_PERIOD_RANGE_p return varchar2;
FUNCTION fadolif(life NUMBER,
		adj_rate NUMBER,
		bonus_rate NUMBER,
		prod NUMBER)
RETURN CHAR;
END FA_FAS423_XMLP_PKG;


/
