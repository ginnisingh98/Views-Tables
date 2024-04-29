--------------------------------------------------------
--  DDL for Package FA_FAS443_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_FAS443_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: FAS443S.pls 120.0.12010000.1 2008/07/28 13:14:40 appldev ship $ */
	P_BOOK	varchar2(15);
	P_PERIOD1	varchar2(15);
	P_CONC_REQUEST_ID	number;
	P_PERIOD2	varchar2(15);
	P_MIN_PRECISION	number;
	Accounting_Flex_Structure	number;
	ACCT_BAL_APROMPT	varchar2(222);
	ACCT_CC_APROMPT	varchar2(222);
	CAT_MAJ_APROMPT	varchar2(222);
	Currency_Code	varchar2(15);
	PRINT_DEBUG	varchar2(32767);
	PRECISION	number;
	Book_Class	varchar2(15);
	Distribution_Source_Book	varchar2(15);
	Period1_PC	varchar2(15);
	Period1_PCD	date;
	Period1_POD	date;
	Period1_FY	number;
	Period2_FY	number;
	Period2_PCD	date;
	Period2_POD	date;
	Period2_PC	varchar2(15);
	d_ord_income_1962	number;
	d_cap_gain_1962	number;
	RP_COMPANY_NAME	varchar2(30);
	RP_REPORT_NAME	varchar2(80);
	RP_BAL_LPROMPT	varchar2(222);
	function BookFormula return VARCHAR2  ;
	function Period1Formula return VARCHAR2  ;
	function report_nameformula(Company_Name in varchar2) return varchar2  ;
	function Period2Formula return VARCHAR2  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function GAIN_NLSFormula return VARCHAR2  ;
	function LOSS_NLSFormula return VARCHAR2  ;
	function d_gain_1962formula (book in varchar2, asset_id in number, reserve in number, gain in number, ord_income in number, cap_gain in number) return number  ;
	function d_ord_income_1962Formula return Number  ;
	Function Accounting_Flex_Structure_p return number;
	Function ACCT_BAL_APROMPT_p return varchar2;
	Function ACCT_CC_APROMPT_p return varchar2;
	Function CAT_MAJ_APROMPT_p return varchar2;
	Function Currency_Code_p return varchar2;
	Function PRINT_DEBUG_p return varchar2;
	Function PRECISION_p return number;
	Function Book_Class_p return varchar2;
	Function Distribution_Source_Book_p return varchar2;
	Function Period1_PC_p return varchar2;
	Function Period1_PCD_p return date;
	Function Period1_POD_p return date;
	Function Period1_FY_p return number;
	Function Period2_FY_p return number;
	Function Period2_PCD_p return date;
	Function Period2_POD_p return date;
	Function Period2_PC_p return varchar2;
	Function d_ord_income_1962_p return number;
	Function d_cap_gain_1962_p return number;
	Function RP_COMPANY_NAME_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
	Function RP_BAL_LPROMPT_p return varchar2;
END FA_FAS443_XMLP_PKG;


/
