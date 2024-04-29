--------------------------------------------------------
--  DDL for Package FA_FAS490_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_FAS490_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: FAS490S.pls 120.0.12010000.1 2008/07/28 13:15:00 appldev ship $ */
	P_BOOK	varchar2(15);
	P_PERIOD1	varchar2(15);
	P_CONC_REQUEST_ID	number;
	P_START_CC	varchar2(15);
	P_END_CC	varchar2(15);
	P_MIN_PRECISION	number;
	PRECISION	number;
	Accounting_Flex_Structure	number;
	Currency_Code	varchar2(15);
	Book_Class	varchar2(15);
	Distribution_Source_Book	varchar2(15);
	Period1_PC	number;
	Period1_PCD	date;
	Period1_POD	date;
	Period1_FY	number;
	ACCT_BAL_APROMPT	number;
	ACCT_COST_APROMPT	varchar2(222);
	RP_ACCT_COST_APROMPT	varchar2(222);
	function BookFormula return VARCHAR2  ;
	function Period1Formula return VARCHAR2  ;
	function Report_NameFormula return VARCHAR2  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function d_lifeformula(books_life in number, adj_rate in number, bonus_rate in number, prod in number) return varchar2  ;
	function nbvformula(AS_COST in number, AS_RESERVE in number) return number  ;
	Function PRECISION_p return number;
	Function Accounting_Flex_Structure_p return number;
	Function Currency_Code_p return varchar2;
	Function Book_Class_p return varchar2;
	Function Distribution_Source_Book_p return varchar2;
	Function Period1_PC_p return number;
	Function Period1_PCD_p return date;
	Function Period1_POD_p return date;
	Function Period1_FY_p return number;
	Function ACCT_BAL_APROMPT_p return number;
	Function ACCT_COST_APROMPT_p return varchar2;
	Function RP_ACCT_COST_APROMPT_p return varchar2;
--Added during DT Fix
        FUNCTION fadolif(life NUMBER, adj_rate NUMBER, bonus_rate NUMBER, prod NUMBER) RETURN CHAR ;
--End of DT Fix
END FA_FAS490_XMLP_PKG;


/
