--------------------------------------------------------
--  DDL for Package FA_FASRREV_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_FASRREV_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: FASRREVS.pls 120.0.12010000.1 2008/07/28 13:17:29 appldev ship $ */
	P_BOOK	varchar2(15);
	P_PERIOD1	varchar2(15);
	P_CONC_REQUEST_ID	number;
	P_PERIOD2	varchar2(15);
	P_MIN_PRECISION	number;
	ACCT_BAL_APROMPT	varchar2(222);
	ACCT_CC_APROMPT	varchar2(222);
	Period1_POD	date;
	Period1_PCD	date;
	Period1_FY	number;
	Period2_POD	date;
	Period2_PCD	date;
	Period2_FY	number;
	RP_COMPANY_NAME	varchar2(30);
	RP_REPORT_NAME	varchar2(80);
	RP_BAL_LPROMPT	varchar2(222);
	function report_nameformula(Company_Name in varchar2) return varchar2  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function Period1_PCFormula return Number  ;
	function Period2_PCFormula return Number  ;
	Function ACCT_BAL_APROMPT_p return varchar2;
	Function ACCT_CC_APROMPT_p return varchar2;
	Function Period1_POD_p return date;
	Function Period1_PCD_p return date;
	Function Period1_FY_p return number;
	Function Period2_POD_p return date;
	Function Period2_PCD_p return date;
	Function Period2_FY_p return number;
	Function RP_COMPANY_NAME_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
	Function RP_BAL_LPROMPT_p return varchar2;
	--added by valli--
	function RP_BAL_LPROMPTFormula(ACCT_BAL_LPROMPT in varchar2) return VARCHAR2;
END FA_FASRREV_XMLP_PKG;


/
