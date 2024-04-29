--------------------------------------------------------
--  DDL for Package FA_FAS540_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_FAS540_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: FAS540S.pls 120.0.12010000.1 2008/07/28 13:15:12 appldev ship $ */
	P_BOOK	varchar2(40);
	P_CONC_REQUEST_ID	number;
	P_PERIOD1	varchar2(15);
	P_PERIOD2	varchar2(15);
	P_MIN_PRECISION	number;
	DIST_BOOK	varchar2(15);
	CURRENCY_CODE	varchar2(15);
	FISCAL_YEAR_NAME	varchar2(30);
	ACCOUNTING_FLEX_STRUCTURE	number;
	PERIOD1_PC	number;
	PERIOD2_PC	number;
	RP_COMPANY_NAME	varchar2(30);
	RP_REPORT_NAME	varchar2(80);
	RP_BAL_LPROMPT	varchar2(500);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function report_nameformula(Company_Name in varchar2) return varchar2  ;
	function BOOKFormula return VARCHAR2  ;
	function PERIOD1Formula return VARCHAR2  ;
	function PERIOD2Formula return VARCHAR2  ;
	function d_lifeformula(life in number, adj_rate in number, bonus_rate in number, prod in number) return varchar2  ;
	Function DIST_BOOK_p return varchar2;
	Function CURRENCY_CODE_p return varchar2;
	Function FISCAL_YEAR_NAME_p return varchar2;
	Function ACCOUNTING_FLEX_STRUCTURE_p return number;
	Function PERIOD1_PC_p return number;
	Function PERIOD2_PC_p return number;
	Function RP_COMPANY_NAME_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
	Function RP_BAL_LPROMPT_p return varchar2;
FUNCTION fadolif(life NUMBER,
		adj_rate NUMBER,
		bonus_rate NUMBER,
		prod NUMBER)
RETURN CHAR;
--ADDED
function ACCT_BAL_LPROMPTFormula(ACCT_BAL_LPROMPT VARCHAR2) return VARCHAR2 ;
END FA_FAS540_XMLP_PKG;


/
