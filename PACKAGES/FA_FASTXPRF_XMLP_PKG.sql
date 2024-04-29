--------------------------------------------------------
--  DDL for Package FA_FASTXPRF_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_FASTXPRF_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: FASTXPRFS.pls 120.0.12010000.1 2008/07/28 13:17:45 appldev ship $ */
	P_BOOK	varchar2(15);
	P_PERIOD1	varchar2(15);
	P_CONC_REQUEST_ID	number;
	P_MIN_PRECISION	number;
	P_FROM_ACCT	varchar2(40);
	P_TO_ACCT	varchar2(40);
	ACCT_BAL_APROMPT	varchar2(50);
	CAT_MAJ_RPROMPT	varchar2(50);
	CORP_END_PC	number;
	Period1_POD	date;
	Period1_PCD	date;
	Period1_FY	number;
	min_fed_pc	number;
	max_fed_pc	number;
	min_corp_pc	number;
	RP_COMPANY_NAME	varchar2(30);
	RP_REPORT_NAME	varchar2(80);
	RP_BAL_LPROMPT	varchar2(50);
	function report_nameformula(Company_Name in varchar2) return varchar2  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function period1_pcformula(DISTRIBUTION_SOURCE_BOOK in varchar2) return number  ;
	function c_do_insertformula(period1_pc in number, DISTRIBUTION_SOURCE_BOOK in varchar2, acct_flex_bal_seg in varchar2) return number  ;
	Function ACCT_BAL_APROMPT_p return varchar2;
	Function CAT_MAJ_RPROMPT_p return varchar2;
	Function CORP_END_PC_p return number;
	Function Period1_POD_p return date;
	Function Period1_PCD_p return date;
	Function Period1_FY_p return number;
	Function min_fed_pc_p return number;
	Function max_fed_pc_p return number;
	Function min_corp_pc_p return number;
	Function RP_COMPANY_NAME_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
	Function RP_BAL_LPROMPT_p return varchar2;
END FA_FASTXPRF_XMLP_PKG;


/
