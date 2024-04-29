--------------------------------------------------------
--  DDL for Package FA_FASCAPSP_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_FASCAPSP_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: FASCAPSPS.pls 120.0.12010000.1 2008/07/28 13:16:25 appldev ship $ */
	P_BUDGET_BOOK	varchar2(15);
	P_DPIS	date;

	T_DPIS varchar2(20);
/*	T_END_DATE varchar2(20);*/

	P_CONC_REQUEST_ID	number;
	P_MIN_PRECISION	number;
	P_TAX_BOOK	varchar2(15);
	ACCT_BAL_APROMPT	varchar2(222);
	ACCT_CC_APROMPT	varchar2(222);
	CAT_MAJ_RPROMPT	varchar2(222);
	END_DATE	date;
	FISCAL_YEAR	number;
	RP_COMPANY_NAME	varchar2(30);
	RP_REPORT_NAME	varchar2(80);
	RP_BAL_LPROMPT	varchar2(222);
	function report_nameformula(Company_Name in varchar2) return varchar2  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function PERIOD_NUMFormula return Number  ;
	function per_add_beforeformula(ADD_COST in number, ADDB_COST in number) return varchar2  ;
	function per_bud_beforeformula(BUD_COST_SUM in number, BUDB_COST_SUM in number) return varchar2  ;
	function per_add_budformula(BUD_COST_SUM in number, ADD_COST in number) return varchar2  ;
	function meth_per_add_beforeformula(METH_ADD_COST in number, METH_ADDB_COST in number) return varchar2  ;
	function meth_per_bud_beforeformula(METH_BUD_COST in number, METH_BUDB_COST in number) return varchar2  ;
	function meth_per_add_budformula(METH_BUD_COST in number, METH_ADD_COST in number) return varchar2  ;
	Function ACCT_BAL_APROMPT_p return varchar2;
	Function ACCT_CC_APROMPT_p return varchar2;
	Function CAT_MAJ_RPROMPT_p return varchar2;
	Function END_DATE_p return date;
	Function FISCAL_YEAR_p return number;
	Function RP_COMPANY_NAME_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
	Function RP_BAL_LPROMPT_p return varchar2;

/*	Function DATEFORMAT(OrigDate in date) return varchar2;*/

END FA_FASCAPSP_XMLP_PKG;


/
