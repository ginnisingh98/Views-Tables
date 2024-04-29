--------------------------------------------------------
--  DDL for Package FA_FAS460_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_FAS460_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: FAS460S.pls 120.0.12010000.1 2008/07/28 13:14:55 appldev ship $ */
	P_END_DATE_ACQ	date;
	P_BOOK	varchar2(40);
	P_CONC_REQUEST_ID	number;
	P_STATE	varchar2(32767);
	P_PER_CTR	number;
	CURRENCY_CODE	varchar2(15);
	ACCOUNTING_FLEX_STRUCTURE	number;
	PRECISION	number := 2 ;
	RP_COMPANY_NAME	varchar2(30);
	RP_REPORT_NAME	varchar2(80);
	RP_BAL_LPROMPT	varchar2(50);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function BOOKFormula return VARCHAR2  ;
	function report_nameformula(Company_Name in varchar2, ACCT_BAL_LPROMPT in varchar2) return varchar2  ;
	Function CURRENCY_CODE_p return varchar2;
	Function ACCOUNTING_FLEX_STRUCTURE_p return number;
	Function PRECISION_p return number;
	Function RP_COMPANY_NAME_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
	--changed
	Function RP_BAL_LPROMPT_p(ACCT_BAL_LPROMPT VARCHAR2) return varchar2;
END FA_FAS460_XMLP_PKG;


/
