--------------------------------------------------------
--  DDL for Package FA_FAS402_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_FAS402_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: FAS402S.pls 120.0.12010000.1 2008/07/28 13:14:14 appldev ship $ */
	P_BOOK	varchar2(15);
	P_PERIOD1	varchar2(15);
	P_CONC_REQUEST_ID	number;
	P_PERIOD2	varchar2(15);
	P_MIN_PRECISION	number;
	P_ca_set_of_books_id	number;
	P_mrcsobtype	varchar2(10);
	LP_currency_code	varchar2(15);
	LP_fa_deprn_summary	varchar2(50);
	LP_FA_DEPRN_PERIODS	varchar2(50);
	LP_FA_BOOKS	varchar2(50);
	LP_fa_book_controls	varchar2(50);
	LP_FA_DEPRN_DETAIL	varchar2(50);
	Accounting_Flex_Structure	number;
	Currency_Code	varchar2(15);
	Period1_PC	number;
	Period2_PC	number;
	RP_COMPANY_NAME	varchar2(30);
	RP_REPORT_NAME	varchar2(80);
	RP_BAL_LPROMPT	varchar2(200);
	function BookFormula return VARCHAR2  ;
	function Period1Formula return VARCHAR2  ;
	function report_nameformula(Company_Name in varchar2) return varchar2  ;
	function Period2Formula return VARCHAR2  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function d_lifeformula(LIFE in number, ADJ_RATE in number, BONUS_RATE in number, PROD in number) return varchar2  ;
	function AfterPForm return boolean  ;
	Function Accounting_Flex_Structure_p return number;
	Function Currency_Code_p return varchar2;
	Function Period1_PC_p return number;
	Function Period2_PC_p return number;
	Function RP_COMPANY_NAME_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
	Function RP_BAL_LPROMPT_p return varchar2;
	FUNCTION fadolif(life NUMBER,
			adj_rate NUMBER,
			bonus_rate NUMBER,
			prod NUMBER)
RETURN CHAR;
END FA_FAS402_XMLP_PKG;


/
