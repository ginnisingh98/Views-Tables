--------------------------------------------------------
--  DDL for Package FA_FASAAMTD_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_FASAAMTD_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: FASAAMTDS.pls 120.0.12010000.1 2008/07/28 13:16:14 appldev ship $ */
	P_FED_BOOK	varchar2(15);
	P_CONC_REQUEST_ID	number;
	P_MIN_PRECISION	number;
	P_AMT_BOOK	varchar2(15);
	P_PERIOD1	varchar2(15);
	P_FROM_ACCT	varchar2(32767);
	P_TO_ACCT	varchar2(32767);
	P_ADJUSTED	varchar2(32767);
	Period1_POD	date;
	Period1_PCD	date;
	Period1_FY	number;
	FED_END_PERIOD_PC	number;
	AMT_START_PERIOD_PC	number;
	AMT_END_PERIOD_PC	number;
	RP_COMPANY_NAME	varchar2(30);
	RP_REPORT_NAME	varchar2(80);
	RP_BAL_LPROMPT	varchar2(222);
	function report_nameformula(Company_Name in varchar2) return varchar2  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function Period1_PCFormula return Number  ;
	function FED_START_PERIOD_PCFormula return Number  ;
	function diff_deprnformula(FED_DEPRN in number, AMT_DEPRN in number) return number  ;
	function amt_deprnformula(AMT_DD in number, AMT_ADJUST in number) return number  ;
	function fed_deprnformula(FED_DD in number, FED_ADJUST in number) return number  ;
	Function Period1_POD_p return date;
	Function Period1_PCD_p return date;
	Function Period1_FY_p return number;
	Function FED_END_PERIOD_PC_p return number;
	Function AMT_START_PERIOD_PC_p return number;
	Function AMT_END_PERIOD_PC_p return number;
	Function RP_COMPANY_NAME_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
	Function RP_BAL_LPROMPT_p return varchar2;
END FA_FASAAMTD_XMLP_PKG;


/
