--------------------------------------------------------
--  DDL for Package FA_FAS410_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_FAS410_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: FAS410S.pls 120.0.12010000.1 2008/07/28 13:14:19 appldev ship $ */
	P_BOOK	varchar2(15);
	P_CONC_REQUEST_ID	number;
	P_START_CC	varchar2(25);
	P_END_CC	varchar2(25);
	P_FROM_DATE	date;
	P_TO_DATE	date;
	P_MIN_PRECISION	number;
	Accounting_Flex_Structure	number;
	Currency_Code	varchar2(15);
	Book_Class	varchar2(15);
	Distribution_Source_Book	varchar2(15);
	Cur_Period_PC	number;
	function BookFormula return VARCHAR2  ;
	function Report_NameFormula return VARCHAR2  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function cur_periodformula(Book in varchar2) return varchar2  ;
	function as_nbvformula(as_cost in number, as_reserve in number) return number  ;
	Function Accounting_Flex_Structure_p return number;
	Function Currency_Code_p return varchar2;
	Function Book_Class_p return varchar2;
	Function Distribution_Source_Book_p return varchar2;
	Function Cur_Period_PC_p return number;
END FA_FAS410_XMLP_PKG;


/
