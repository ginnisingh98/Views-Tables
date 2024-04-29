--------------------------------------------------------
--  DDL for Package FA_FAS445_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_FAS445_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: FAS445S.pls 120.0.12010000.1 2008/07/28 13:14:44 appldev ship $ */
	P_BOOK	varchar2(15);
	P_PERIOD1	varchar2(15);
	P_CONC_REQUEST_ID	number;
	P_PERIOD2	varchar2(15);
	P_MIN_PRECISION	number;
	PRECISION	number;
	PRINT_DEBUG	varchar2(32767);
	ACCT_BAL_APROMPT	varchar2(222);
	ACCT_CC_APROMPT	varchar2(222);
	CAT_MAJ_RPROMPT	varchar2(222);
	Period1_POD	date;
	Period1_PCD	date;
	Period1_FY	number;
	Period2_POD	date;
	Period2_PCD	date;
	Period2_FY	number;
	P_SECTION_1231_GAIN_1962	number;
	P_ORDINARY_INCOME_1962	number;
	P_EXCESS_1969_HIDE	number;
	P_EXCESS_1969	number;
	RP_COMPANY_NAME	varchar2(30);
	RP_REPORT_NAME	varchar2(80);
	RP_DATA_FOUND	varchar2(3);
	RP_ACCT_BAL_LPROMPT	varchar2(222);
	function report_nameformula(Company_Name in varchar2) return varchar2  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function Period1_PCFormula return Number  ;
	function Period2_PCFormula return Number  ;
	function PRECFormula return VARCHAR2  ;
	function GAIN_NLSFormula return VARCHAR2  ;
	function LOSS_NLSFormula return VARCHAR2  ;
	function d_excess_1962formula(book in varchar2, asset_id in number, book_class in varchar2, cost in number, nbvr in number, gla in number, cgain in number, ord_inc in number) return number  ;
	--function d_excess_1969formula(book in varchar2, asset_id in number, book_class in varchar2, xcess in number) return number  ;
	function d_excess_1969formula(book in varchar2, asset_id in number, book_class in varchar2, xcess in number, cost in number, nbvr in number) return number  ;
	Function PRECISION_p return number;
	Function PRINT_DEBUG_p return varchar2;
	Function ACCT_BAL_APROMPT_p return varchar2;
	Function ACCT_CC_APROMPT_p return varchar2;
	Function CAT_MAJ_RPROMPT_p return varchar2;
	Function Period1_POD_p return date;
	Function Period1_PCD_p return date;
	Function Period1_FY_p return number;
	Function Period2_POD_p return date;
	Function Period2_PCD_p return date;
	Function Period2_FY_p return number;
	Function P_SECTION_1231_GAIN_1962_p return number;
	Function P_ORDINARY_INCOME_1962_p return number;
	Function P_EXCESS_1969_HIDE_p return number;
	Function P_EXCESS_1969_p return number;
	Function RP_COMPANY_NAME_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
	Function RP_DATA_FOUND_p return varchar2;
	Function RP_ACCT_BAL_LPROMPT_p return varchar2;
END FA_FAS445_XMLP_PKG;


/
