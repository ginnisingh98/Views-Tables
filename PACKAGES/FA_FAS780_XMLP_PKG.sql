--------------------------------------------------------
--  DDL for Package FA_FAS780_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_FAS780_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: FAS780S.pls 120.0.12010000.1 2008/07/28 13:15:35 appldev ship $ */
	P_BOOK	varchar2(15);
	P_CONC_REQUEST_ID	number;
	P_MIN_PRECISION	number;
	P_CATEGORY_ID	varchar2(40);
	Accounting_Flex_Structure	number;
	ACCT_BAL_APROMPT	varchar2(222);
	Currency_Code	varchar2(15);
	Book_Class	varchar2(15);
	Distribution_Source_Book	varchar2(15);
	RP_COMPANY_NAME	varchar2(30);
	RP_REPORT_NAME	varchar2(80);
	RP_ACCT_BAL_LPROMPT	varchar2(222);
	function BookFormula return VARCHAR2  ;
	function report_nameformula(Company_Name in varchar2) return varchar2  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	Function Accounting_Flex_Structure_p return number;
	Function ACCT_BAL_APROMPT_p return varchar2;
	Function Currency_Code_p return varchar2;
	Function Book_Class_p return varchar2;
	Function Distribution_Source_Book_p return varchar2;
	Function RP_COMPANY_NAME_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
	--modified
	Function RP_ACCT_BAL_LPROMPT_p(acct_bal_lprompt varchar2) return varchar2;
END FA_FAS780_XMLP_PKG;


/
