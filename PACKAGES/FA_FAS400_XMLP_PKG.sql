--------------------------------------------------------
--  DDL for Package FA_FAS400_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_FAS400_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: FAS400S.pls 120.0.12010000.1 2008/07/28 13:14:10 appldev ship $ */
	P_BOOK	varchar2(15);
	P_PERIOD1	varchar2(15);
	P_CONC_REQUEST_ID	number;
	P_MIN_PRECISION	number;
	p_ca_set_of_books_id	number;
	p_ca_org_id	number;
	p_mrcsobtype	varchar2(10);
	lp_currency_code	varchar2(15);
	lp_fa_deprn_summary	varchar2(50);
	Accounting_Flex_Structure	number;
	ACCT_CC_APROMPT	varchar2(600) := 'cc.segment2||cc.segment2||cc.segment2||cc.segment2||cc.segment2||cc.segment2||cc.segment2||cc.segment2||cc.segment2||cc.segment2||cc.segment2||cc.segment2||cc.segment2||cc.segment2||cc.segment2||cc.segment2
		||cc.segment2||cc.segment2||cc.segment2||cc.segment2||cc.segment2||cc.segment2||cc.segment2||cc.segment2||cc.segment2||cc.segment2||cc.segment2||cc.segment2||cc.segment2||cc.segment2||cc.segment2||cc.segment2||cc.segment2||cc.segment2' ;
	CAT_MAJ_APROMPT	varchar2(600) := 'cat.segment1||cat.segment1||cat.segment1||cat.segment1||cat.segment1||cat.segment1||cat.segment1||cat.segment1||cat.segment1||cat.segment1||cat.segment1||cat.segment1||cat.segment1||cat.segment1||cat.segment1
		||cat.segment1||cat.segment1||cat.segment1||cat.segment1||cat.segment1||cat.segment1||cat.segment1||cat.segment1||cat.segment1||cat.segment1||cat.segment1||cat.segment1||cat.segment1||cat.segment1||cat.segment1||cat.segment1||
		cat.segment1||cat.segment1||cat.segment1||cat.segment1||cat.segment1' ;
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
	function BookFormula return VARCHAR2  ;
	function Period1Formula return VARCHAR2  ;
	function Report_NameFormula return VARCHAR2  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function c_do_insertformula(Book in varchar2, Period1 in varchar2) return number  ;
	function d_lifeformula(LIFE in number, ADJ_RATE in number, BONUS_RATE in number, PROD in number) return varchar2  ;
	function ACCT_CC_APROMPTFormula return VARCHAR2  ;
	function Period_ClosedFormula return VARCHAR2  ;
	function Currency_CodeFormula return VARCHAR2  ;
	function AfterPForm return boolean  ;
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
FUNCTION fadolif(life NUMBER,
		adj_rate NUMBER,
		bonus_rate NUMBER,
		prod NUMBER)
RETURN CHAR ;
procedure FA_RSVLDG
       (book            in  varchar2,
        period          in  varchar2,
        errbuf          out NOCOPY varchar2 ,
        retcode         out NOCOPY number);
END FA_FAS400_XMLP_PKG;



/
