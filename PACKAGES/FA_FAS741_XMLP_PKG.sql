--------------------------------------------------------
--  DDL for Package FA_FAS741_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_FAS741_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: FAS741S.pls 120.0.12010000.1 2008/07/28 13:15:25 appldev ship $ */
	P_BOOK	varchar2(15);
	P_PERIOD1	varchar2(15);
	P_CONC_REQUEST_ID	number;
	P_PERIOD2	varchar2(15);
	P_MIN_PRECISION	number;
	Accounting_Flex_Structure	number;
	ACCT_CC_LPROMPT	varchar2(222);
	Currency_Code	varchar2(15);
	Distribution_Source_Book	varchar2(15);
	Period1_POD	date;
	Period2_PCD	date;
	function BookFormula return VARCHAR2  ;
	function Period1Formula return VARCHAR2  ;
	function Report_NameFormula return VARCHAR2  ;
	function Period2Formula return VARCHAR2  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function MEANING_CIPFormula return VARCHAR2  ;
	function MEANING_CAPFormula return VARCHAR2  ;
	function MEANING_EXPFormula return VARCHAR2  ;
	Function Accounting_Flex_Structure_p return number;
	Function ACCT_CC_LPROMPT_p return varchar2;
	Function Currency_Code_p return varchar2;
	Function Distribution_Source_Book_p return varchar2;
	Function Period1_POD_p return date;
	Function Period2_PCD_p return date;
END FA_FAS741_XMLP_PKG;


/
