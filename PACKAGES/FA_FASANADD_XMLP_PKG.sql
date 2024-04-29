--------------------------------------------------------
--  DDL for Package FA_FASANADD_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_FASANADD_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: FASANADDS.pls 120.0.12010000.1 2008/07/28 13:16:18 appldev ship $ */
	P_BOOK	varchar2(15);
	P_CONC_REQUEST_ID	number;
	P_MIN_PRECISION	number;
	P_START_DATE	date;
	P_END_DATE	date;
	P_START_DATE1	varchar2(20);
	P_END_DATE1	varchar2(20);
	ACCT_BAL_APROMPT	varchar2(222);
	RP_COMPANY_NAME	varchar2(30);
	RP_REPORT_NAME	varchar2(80);
	RP_BAL_LPROMPT	varchar2(222);
	function report_nameformula(Company_Name in varchar2) return varchar2  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	Function ACCT_BAL_APROMPT_p return varchar2;
	Function RP_COMPANY_NAME_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
	--Function RP_BAL_LPROMPT_p return varchar2;
		Function RP_BAL_LPROMPT_p(ACCT_BAL_LPROMPT VARCHAR2) return varchar2;
END FA_FASANADD_XMLP_PKG;


/
