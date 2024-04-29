--------------------------------------------------------
--  DDL for Package FA_FASASSBS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_FASASSBS_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: FASASSBSS.pls 120.0.12010000.1 2008/07/28 13:16:23 appldev ship $ */
	P_BOOK	varchar2(15);
	P_PERIOD1	varchar2(15);
	P_CONC_REQUEST_ID	number;
	P_PERIOD2	varchar2(15);
	P_MIN_PRECISION	number;
	Accounting_Flex_Structure	number;
	DISTRIBUTION_SOURCE_BOOK	varchar2(15);
	Precision	number;
	Currency_Code	varchar2(15);
	Period1_POD	date;
	PERIOD1_PC	number;
	Period2_PCD	date;
	PERIOD2_PC	number;
	function BookFormula return VARCHAR2  ;
	function Period1Formula return VARCHAR2  ;
	function Report_NameFormula return VARCHAR2  ;
	function Period2Formula return VARCHAR2  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function c_unbalformula(AS_INV_COST in number, AS_ASS_COST in number, ASSET_TYPE in varchar2) return varchar2  ;
	function c_cc_unbalformula(CC_INV_COST in number, CC_ASS_COST in number, ASSET_TYPE in varchar2) return varchar2  ;
	function c_ac_unbalformula(AC_INV_COST in number, AC_ASS_COST in number, ASSET_TYPE in varchar2) return varchar2  ;
	function c_at_unbalformula(AT_INV_COST in number, AT_ASS_COST in number, ASSET_TYPE in varchar2) return varchar2  ;
	Function Accounting_Flex_Structure_p return number;
	Function DISTRIBUTION_SOURCE_BOOK_p return varchar2;
	Function Precision_p return number;
	Function Currency_Code_p return varchar2;
	Function Period1_POD_p return date;
	Function PERIOD1_PC_p return number;
	Function Period2_PCD_p return date;
	Function PERIOD2_PC_p return number;
END FA_FASASSBS_XMLP_PKG;


/
