--------------------------------------------------------
--  DDL for Package FA_FAS440_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_FAS440_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: FAS440S.pls 120.0.12010000.1 2008/07/28 13:14:33 appldev ship $ */
	P_BOOK	varchar2(15);
	P_PERIOD1	varchar2(15);
	P_CONC_REQUEST_ID	number;
	P_PERIOD2	varchar2(15);
	P_MIN_PRECISION	number;
	PRECISION	varchar2(40);
	P_ca_set_of_books_id	number;
	P_mrcsobtype	varchar2(10);
	lp_currency_code	varchar2(15);
	lp_fa_book_controls	varchar2(50);
	lp_fa_books	varchar2(50);
	lp_fa_adjustments	varchar2(50);
	lp_fa_retirements	varchar2(50);
	ACCT_BAL_APROMPT	varchar2(200);
	ACCT_CC_APROMPT	varchar2(200);
	CAT_MAJ_RPROMPT	varchar2(200);
	Period1_POD	date;
	Period1_PCD	date;
	Period1_FY	number;
	Period2_POD	date;
	Period2_PCD	date;
	Period2_FY	number;
	RP_COMPANY_NAME	varchar2(30);
	RP_REPORT_NAME	varchar2(80);
	PERIOD_FROM	varchar2(20);
	PERIOD_TO	varchar2(20);
	function report_nameformula(Company_Name in varchar2) return varchar2  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function Period1_PCFormula return Number  ;
	function Period2_PCFormula return Number  ;
	function gain_lossformula(nbv in number, proceeds in number, removal in number, reval_rsv_ret in number) return number  ;
	function AfterPForm return boolean  ;
	Function ACCT_BAL_APROMPT_p return varchar2;
	Function ACCT_CC_APROMPT_p return varchar2;
	Function CAT_MAJ_RPROMPT_p return varchar2;
	Function Period1_POD_p return date;
	Function Period1_PCD_p return date;
	Function Period1_FY_p return number;
	Function Period2_POD_p return date;
	Function Period2_PCD_p return date;
	Function Period2_FY_p return number;
	Function RP_COMPANY_NAME_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
	Function PERIOD_FROM_p return varchar2;
	Function PERIOD_TO_p return varchar2;
END FA_FAS440_XMLP_PKG;


/
