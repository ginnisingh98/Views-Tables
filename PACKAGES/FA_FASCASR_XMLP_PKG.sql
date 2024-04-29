--------------------------------------------------------
--  DDL for Package FA_FASCASR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_FASCASR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: FASCASRS.pls 120.0.12010000.1 2008/07/28 13:16:27 appldev ship $ */
	P_BOOK	varchar2(15);
	P_PERIOD1	varchar2(15);
	P_CONC_REQUEST_ID	number;
	P_PERIOD2	varchar2(15);
	P_MIN_PRECISION	number;
	Accounting_Flex_Structure	number;
	Currency_Code	varchar2(15);
	Period1_POD	date;
	Period2_PCD	date;
	PRECISION	number;
	RP_REPORT_NAME	varchar2(80);
	function BookFormula return VARCHAR2  ;
	function Period1Formula return VARCHAR2  ;
	function Report_NameFormula return VARCHAR2  ;
	function Period2Formula return VARCHAR2  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function out_of_balanceformula(ASSET_ADJ in number, INVOICE_ADJ in number, IS_INV_TRANS in varchar2) return varchar2  ;
	Function Accounting_Flex_Structure_p return number;
	Function Currency_Code_p return varchar2;
	Function Period1_POD_p return date;
	Function Period2_PCD_p return date;
	Function PRECISION_p return number;
	Function RP_REPORT_NAME_p return varchar2;
END FA_FASCASR_XMLP_PKG;


/
