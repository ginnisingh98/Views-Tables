--------------------------------------------------------
--  DDL for Package FA_FASCC_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_FASCC_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: FASCCS.pls 120.0.12010000.1 2008/07/28 13:16:30 appldev ship $ */
	P_BOOK	varchar2(15);
	P_PERIOD1	varchar2(15);
	P_CONC_REQUEST_ID	number;
	P_MIN_PRECISION	number;
	P_ca_set_of_books_id	number;
	P_mrcsobtype	varchar2(10);
	LP_fa_book_controls	varchar2(50);
	LP_CURRENCY_CODE	varchar2(15);
	lp_fa_asset_invoices	varchar2(50);
	LP_FA_BOOKS_BAS	varchar2(50);
	LP_FA_BOOKS	varchar2(50);
	LP_FA_ASSET_INVOICES_BAS	varchar2(50);
	Accounting_Flex_Structure	number;
	ACCT_BAL_APROMPT	varchar2(222);
	ACCT_CC_APROMPT	varchar2(222);
	Currency_Code	varchar2(15);
	Period1_PC	number;
	Period1_PCD	date;
	Period1_POD	date;
	Precision	number;
	RP_COMPANY_NAME	varchar2(30);
	RP_REPORT_NAME	varchar2(80);
	RP_DATA_FOUND	varchar2(3);
	function BookFormula return VARCHAR2  ;
	function Period1Formula return VARCHAR2  ;
	function report_nameformula(Company_Name in varchar2) return varchar2  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function AfterPForm return boolean  ;
	function lp_fa_asset_invoicesValidTrigg return boolean  ;
	Function Accounting_Flex_Structure_p return number;
	Function ACCT_BAL_APROMPT_p return varchar2;
	Function ACCT_CC_APROMPT_p return varchar2;
	Function Currency_Code_p return varchar2;
	Function Period1_PC_p return number;
	Function Period1_PCD_p return date;
	Function Period1_POD_p return date;
	Function Precision_p return number;
	Function RP_COMPANY_NAME_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
	Function RP_DATA_FOUND_p return varchar2;
END FA_FASCC_XMLP_PKG;


/
