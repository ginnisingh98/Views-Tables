--------------------------------------------------------
--  DDL for Package FA_FAS740_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_FAS740_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: FAS740S.pls 120.0.12010000.1 2008/07/28 13:15:23 appldev ship $ */
	P_BOOK	varchar2(15);
	P_PERIOD1	varchar2(15);
	P_CONC_REQUEST_ID	number;
	P_PERIOD2	varchar2(15);
	P_MIN_PRECISION	number;
	Accounting_Flex_Structure	number;
	Currency_Code	varchar2(15);
	DIST_SOURCE_BOOK	varchar2(15);
	RP_COMPANY_NAME	varchar2(30);
	RP_REPORT_NAME	varchar2(80);
	PERIOD_FROM	varchar2(20);
	PERIOD_TO	varchar2(20);
	function BookFormula return VARCHAR2  ;
	function report_nameformula(Company_Name in varchar2) return varchar2  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	Function Accounting_Flex_Structure_p return number;
	Function Currency_Code_p return varchar2;
	Function DIST_SOURCE_BOOK_p return varchar2;
	Function RP_COMPANY_NAME_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
	Function PERIOD_FROM_p return varchar2;
	Function PERIOD_TO_p return varchar2;
END FA_FAS740_XMLP_PKG;


/
