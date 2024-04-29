--------------------------------------------------------
--  DDL for Package FA_FAS441_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_FAS441_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: FAS441S.pls 120.0.12010000.1 2008/07/28 13:14:35 appldev ship $ */
	P_BOOK	varchar2(15);
	P_PERIOD1	varchar2(15);
	P_CONC_REQUEST_ID	number;
	P_MIN_PRECISION	number;
	P_START_CC	varchar2(40);
	P_END_CC	varchar2(40);
	PRECISION	number;
	ACCT_BAL_APROMPT	varchar2(200);
	ACCT_CC_APROMPT	varchar2(200);
	CAT_MAJ_RPROMPT	varchar2(200);
	Period1_POD	date;
	Period1_PCD	date;
	Period1_FY	number;
	RP_COMPANY_NAME	varchar2(30);
	RP_REPORT_NAME	varchar2(80);
	function report_nameformula(Company_Name in varchar2) return varchar2  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function Period1_PCFormula return Number  ;
	function PRECFormula return VARCHAR2  ;
	Function PRECISION_p return number;
	Function ACCT_BAL_APROMPT_p return varchar2;
	Function ACCT_CC_APROMPT_p return varchar2;
	Function CAT_MAJ_RPROMPT_p return varchar2;
	Function Period1_POD_p return date;
	Function Period1_PCD_p return date;
	Function Period1_FY_p return number;
	Function RP_COMPANY_NAME_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
END FA_FAS441_XMLP_PKG;


/
