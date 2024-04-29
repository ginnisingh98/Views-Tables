--------------------------------------------------------
--  DDL for Package FA_FAS840_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_FAS840_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: FAS840S.pls 120.0.12010000.1 2008/07/28 13:15:58 appldev ship $ */
	P_BOOK	varchar2(15);
	P_PERIOD1	varchar2(15);
	P_CONC_REQUEST_ID	number;
	P_PERIOD2	varchar2(15);
	P_MIN_PRECISION	number;
	lp_currency_code	varchar2(15);
	p_ca_org_id	number;
	p_ca_set_of_books_id	number;
	p_mrcsobtype	varchar2(10);
	lp_fa_books	varchar2(50):='FA_BOOKS';
	lp_fa_deprn_periods	varchar2(50):='FA_DEPRN_PERIODS';
	PRECISION	number;
	Accounting_Flex_Structure	number;
	Currency_Code	varchar2(15);
	Distribution_Source_Book	varchar2(15);
	Period1_PC	number;
	Period2_PC	number;
	RP_REPORT_NAME	varchar2(80);
	function BookFormula return VARCHAR2  ;
	function Period1Formula return VARCHAR2  ;
	function Report_NameFormula return VARCHAR2  ;
	function Period2Formula return VARCHAR2  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function AfterPForm return boolean  ;
	Function PRECISION_p return number;
	Function Accounting_Flex_Structure_p return number;
	Function Currency_Code_p return varchar2;
	Function Distribution_Source_Book_p return varchar2;
	Function Period1_PC_p return number;
	Function Period2_PC_p return number;
	Function RP_REPORT_NAME_p return varchar2;
END FA_FAS840_XMLP_PKG;


/
