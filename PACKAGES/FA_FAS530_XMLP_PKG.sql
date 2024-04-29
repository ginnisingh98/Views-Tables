--------------------------------------------------------
--  DDL for Package FA_FAS530_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_FAS530_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: FAS530S.pls 120.0.12010000.1 2008/07/28 13:15:09 appldev ship $ */
	P_BOOK	varchar2(15);
	P_CONC_REQUEST_ID	number;
	P_MIN_PRECISION	number;
	P_START_ASSET	varchar2(30);
	P_END_ASSET	varchar2(30);
	Accounting_Flex_Structure	number;
	Currency_Code	varchar2(15);
	Book_Class	varchar2(15);
	Distribution_Source_Book	varchar2(15);
	RP_COMPANY_NAME	varchar2(30);
	RP_REPORT_NAME	varchar2(80);
	FROM_ASSET_PARAM	varchar2(30);
	TO_ASSET_PARAM	varchar2(30);
	function BookFormula return VARCHAR2  ;
	function report_nameformula(Company_Name in varchar2) return varchar2  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	Function Accounting_Flex_Structure_p return number;
	Function Currency_Code_p return varchar2;
	Function Book_Class_p return varchar2;
	Function Distribution_Source_Book_p return varchar2;
	Function RP_COMPANY_NAME_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
	Function FROM_ASSET_PARAM_p return varchar2;
	Function TO_ASSET_PARAM_p return varchar2;
END FA_FAS530_XMLP_PKG;


/
