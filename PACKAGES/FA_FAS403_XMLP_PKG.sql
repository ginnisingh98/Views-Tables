--------------------------------------------------------
--  DDL for Package FA_FAS403_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_FAS403_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: FAS403S.pls 120.0.12010000.1 2008/07/28 13:14:16 appldev ship $ */
	P_BOOK	varchar2(15);
	P_PERIOD1	varchar2(15);
	P_CONC_REQUEST_ID	number;
	P_MIN_PRECISION	number;
	Accounting_Flex_Structure	number;
	ACCT_CC_APROMPT	varchar2(200);
	CAT_MAJ_APROMPT	varchar2(100);
	Currency_Code	varchar2(15);
	Book_Class	varchar2(15);
	Distribution_Source_Book	varchar2(15);
	Period1_PC	number;
	Period1_PCD	date;
	Period1_POD	date;
	Period1_FY	number;
	Period_Closed	varchar2(32767);
	C_Errbuf	varchar2(250);
	C_RetCode	number;
	RP_COMPANY_NAME	varchar2(100);
	RP_REPORT_NAME	varchar2(80);
	C_Insertion_Message	varchar2(250);
	--C_Bal_LPrompt	varchar2(100) := := 'Company' ;
	C_Bal_LPrompt	varchar2(100) :=  'Company' ;
	C_Co_Value	varchar2(30);
	C_CC_LPrompt	varchar2(100);
	C_CC_APrompt	varchar2(100);
	--C_Closed	varchar2(32767) := := 'YES' ;
	C_Closed	varchar2(32767) := 'YES' ;
	function BookFormula return VARCHAR2  ;
	function Period1Formula return VARCHAR2  ;
	function report_nameformula(Company_Name in varchar2) return varchar2  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function c_do_insertformula(Book in varchar2, Period1 in varchar2) return number  ;
	function d_cost_centerformula(Acct_CC_LPrompt in varchar2, Cost_Center in varchar2) return varchar2  ;
	function d_lifeformula(LIFE in number, ADJ_RATE in number, BONUS_RATE in number, PROD in number) return varchar2  ;
	Function Accounting_Flex_Structure_p return number;
	Function ACCT_CC_APROMPT_p return varchar2;
	Function CAT_MAJ_APROMPT_p return varchar2;
	Function Currency_Code_p return varchar2;
	Function Book_Class_p return varchar2;
	Function Distribution_Source_Book_p return varchar2;
	Function Period1_PC_p return number;
	Function Period1_PCD_p return date;
	Function Period1_POD_p return date;
	Function Period1_FY_p return number;
	Function Period_Closed_p return varchar2;
	Function C_Errbuf_p return varchar2;
	Function C_RetCode_p return number;
	Function RP_COMPANY_NAME_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
	Function C_Insertion_Message_p return varchar2;
	Function C_Bal_LPrompt_p return varchar2;
	Function C_Co_Value_p return varchar2;
	Function C_CC_LPrompt_p return varchar2;
	Function C_CC_APrompt_p return varchar2;
	Function C_Closed_p return varchar2;
	FUNCTION fadolif(life NUMBER,
			adj_rate NUMBER,
			bonus_rate NUMBER,
			prod NUMBER) RETURN CHAR;
        procedure FA_RSVLDG
       (book            in  varchar2,
        period          in  varchar2,
        errbuf          out NOCOPY varchar2,
        retcode         out NOCOPY number);
END FA_FAS403_XMLP_PKG;



/
