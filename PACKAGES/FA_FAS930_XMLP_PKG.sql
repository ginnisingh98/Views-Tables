--------------------------------------------------------
--  DDL for Package FA_FAS930_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_FAS930_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: FAS930S.pls 120.0.12010000.1 2008/07/28 13:16:07 appldev ship $ */
	P_BOOK	varchar2(15);
	P_CONC_REQUEST_ID	number;
	P_MIN_PRECISION	number;
	ACCT_BAL_APROMPT	varchar2(222);
	ACCT_CC_APROMPT	varchar2(222);
	CAT_MAJ_RPROMPT	varchar2(222);
	RP_COMPANY_NAME	varchar2(30);
	RP_REPORT_NAME	varchar2(80);
	RP_BAL_LPROMPT	varchar2(222);
	RP_CAT_LPROMPT	varchar2(222);
	RP_CURRENCY_CODE	varchar2(32767);
	function report_nameformula(Company_Name in varchar2, CURRENCY_CODE in varchar2) return varchar2  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	Function ACCT_BAL_APROMPT_p return varchar2;
	Function ACCT_CC_APROMPT_p return varchar2;
	Function CAT_MAJ_RPROMPT_p return varchar2;
	Function RP_COMPANY_NAME_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
	--Function RP_BAL_LPROMPT_p return varchar2;
	 Function RP_BAL_LPROMPT_p(ACCT_BAL_LPROMPT varchar2)return varchar2;
	Function RP_CAT_LPROMPT_p return varchar2;
	Function RP_CURRENCY_CODE_p return varchar2;
END FA_FAS930_XMLP_PKG;


/