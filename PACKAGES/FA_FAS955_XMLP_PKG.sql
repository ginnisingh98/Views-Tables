--------------------------------------------------------
--  DDL for Package FA_FAS955_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_FAS955_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: FAS955S.pls 120.0.12010000.1 2008/07/28 13:16:09 appldev ship $ */
	P_BOOK	varchar2(15);
	P_PERIOD1	varchar2(15);
	P_CONC_REQUEST_ID	number;
	P_MIN_PRECISION	number;
	ACCT_BAL_APROMPT	varchar2(222);
	ACCT_CC_APROMPT	varchar2(222);
	CAT_MAJ_RPROMPT	varchar2(222);
	Period1_POD	date;
	Period1_PCD	date;
	Period1_FY	number;
	PERIOD_NUM	number;
	QUARTER_NUM	number;
	RP_COMPANY_NAME	varchar2(30);
	RP_REPORT_NAME	varchar2(80);
	function report_nameformula(Company_Name in varchar2) return varchar2  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function period1_pcformula(Distribution_Source_Book in varchar2) return number  ;
	function cat_pdevformula(CAT_PB_COST in number, CAT_PA_COST in number, precision in number) return number  ;
	function cat_qdevformula(CAT_QB_COST in number, CAT_QA_COST in number, precision in number) return number  ;
	function cat_ydevformula(CAT_YB_COST in number, CAT_YA_COST in number, precision in number) return number  ;
	function rp_ydevformula(RP_YB_COST in number, RP_YA_COST in number, prec_glob in varchar2) return number  ;
	function rp_qdevformula(RP_QB_COST in number, RP_QA_COST in number, prec_glob in varchar2) return number  ;
	function rp_pdevformula(RP_PB_COST in number, RP_PA_COST in number, prec_glob in varchar2) return number  ;
	function cc_pdevformula(CC_PB_COST in number, CC_PA_COST in number, precision in number) return number  ;
	function cc_qdevformula(CC_QB_COST in number, CC_QA_COST in number, precision in number) return number  ;
	function cc_ydevformula(CC_YB_COST in number, CC_YA_COST in number, precision in number) return number  ;
	function bd_pdevformula(BD_PB_COST in number, BD_PA_COST in number, precision in number) return number  ;
	function bd_qdevformula(BD_QB_COST in number, BD_QA_COST in number) return number  ;
	function bd_ydevformula(BD_YB_COST in number, BD_YA_COST in number, precision in number) return number  ;
	function bal_pdevformula(BAL_PB_COST in number, BAL_PA_COST in number, precision in number) return number  ;
	function bal_ydevformula(BAL_YB_COST in number, BAL_YA_COST in number, precision in number) return number  ;
	function bal_qdevformula(BAL_QB_COST in number, BAL_QA_COST in number, precision in number) return number  ;
	Function ACCT_BAL_APROMPT_p return varchar2;
	Function ACCT_CC_APROMPT_p return varchar2;
	Function CAT_MAJ_RPROMPT_p return varchar2;
	Function Period1_POD_p return date;
	Function Period1_PCD_p return date;
	Function Period1_FY_p return number;
	Function PERIOD_NUM_p return number;
	Function QUARTER_NUM_p return number;
	Function RP_COMPANY_NAME_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
END FA_FAS955_XMLP_PKG;


/
