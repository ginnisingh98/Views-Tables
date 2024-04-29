--------------------------------------------------------
--  DDL for Package FA_FASRCOST_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_FASRCOST_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: FASRCOSTS.pls 120.0.12010000.1 2008/07/28 13:17:22 appldev ship $ */
	P_BOOK	varchar2(15);
	P_PERIOD1	varchar2(15);
	P_CONC_REQUEST_ID	number;
	P_MIN_PRECISION	number;
	ACCT_BAL_APROMPT	varchar2(222);
	Period1_POD	date;
	Period1_PCD	date;
	Period1_FY	number;
	Corp_Period_POD	date;
	Corp_Period_PCD	date;
	RP_COMPANY_NAME	varchar2(30);
	RP_REPORT_NAME	varchar2(80);
	RP_BAL_LPROMPT	varchar2(222);
	function report_nameformula(Company_Name in varchar2) return varchar2  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function Period1_PCFormula return Number  ;
	--function corp_period_pcformula(book_type_code in varchar2, distribution_source_book in varchar2) return number  ;
	function corp_period_pcformula(chg_book_type_code in varchar2, chg_distribution_source_book in varchar2) return number  ;
	Function ACCT_BAL_APROMPT_p return varchar2;
	Function Period1_POD_p return date;
	Function Period1_PCD_p return date;
	Function Period1_FY_p return number;
	Function Corp_Period_POD_p return date;
	Function Corp_Period_PCD_p return date;
	Function RP_COMPANY_NAME_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
	Function RP_BAL_LPROMPT_p return varchar2;
END FA_FASRCOST_XMLP_PKG;


/
