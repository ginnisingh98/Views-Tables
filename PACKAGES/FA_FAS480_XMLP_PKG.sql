--------------------------------------------------------
--  DDL for Package FA_FAS480_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_FAS480_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: FAS480S.pls 120.0.12010000.1 2008/07/28 13:14:58 appldev ship $ */
	P_BOOK	varchar2(15);
	P_PERIOD1	varchar2(15);
	P_CONC_REQUEST_ID	number;
	P_MIN_PRECISION	number;
	lp_currency_code	varchar2(30);
	lp_fa_deprn_summary	varchar2(50);
	P_MRCSOBTYPE	varchar2(32767);
	p_ca_set_of_books_id	number;
	Accounting_Flex_Structure	number;
	ACCT_BAL_APROMPT	varchar2(500);
	Fiscal_Year_Name	varchar2(30);
	Currency_Code	varchar2(15);
	Book_Class	varchar2(15);
	Distribution_Source_Book	varchar2(15);
	Period1_PCD	date;
	Period1_POD	date;
	Period1_FY	number;
	C_ERRBUF	varchar2(250);
	C_RETCODE	number;
	RP_COMPANY_NAME	varchar2(30);
	RP_REPORT_NAME	varchar2(80);
	RP_ACCT_BAL_LPROMPT	varchar2(32767);
	--C_Period_Closed	varchar2(32767) := := 'YES' ;
	C_Period_Closed	varchar2(32767) :=  'YES' ;
	RP_BAL_LPROMPT	varchar2(500);
	C_INSERTION_MESSAGE	varchar2(250);
	function BookFormula return VARCHAR2  ;
	function report_nameformula(ACCT_BAL_LPROMPT in varchar2, Company_Name in varchar2) return varchar2  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function Period1_PCFormula return Number  ;
	function d_lifeformula(LIFE in number, ADJ_RATE in number, BONUS_RATE in number, PROD in number) return varchar2  ;
	function C_DO_INSERTFormula return Number  ;
	function AfterPForm return boolean  ;
	Function Accounting_Flex_Structure_p return number;
	Function ACCT_BAL_APROMPT_p return varchar2;
	Function Fiscal_Year_Name_p return varchar2;
	Function Currency_Code_p return varchar2;
	Function Book_Class_p return varchar2;
	Function Distribution_Source_Book_p return varchar2;
	Function Period1_PCD_p return date;
	Function Period1_POD_p return date;
	Function Period1_FY_p return number;
	Function C_ERRBUF_p return varchar2;
	Function C_RETCODE_p return number;
	Function RP_COMPANY_NAME_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
	Function RP_ACCT_BAL_LPROMPT_p return varchar2;
	Function C_Period_Closed_p return varchar2;
	Function RP_BAL_LPROMPT_p return varchar2;
	Function C_INSERTION_MESSAGE_p return varchar2;
	FUNCTION fadolif(life NUMBER,
			adj_rate NUMBER,
			bonus_rate NUMBER,
			prod NUMBER) RETURN CHAR;
        procedure FA_RSVLDG
       (book            in  varchar2,
        period          in  varchar2,
        errbuf          out NOCOPY varchar2,
        retcode         out NOCOPY number);
END FA_FAS480_XMLP_PKG;



/
