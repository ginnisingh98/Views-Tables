--------------------------------------------------------
--  DDL for Package AR_ARXAPRCL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_ARXAPRCL_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: ARXAPRCLS.pls 120.0 2007/12/27 13:29:59 abraghun noship $ */
	P_CONC_REQUEST_ID	number;
	P_Set_of_Books_Id	number;
	P_REMIT_ACCOUNT	varchar2(200);
	P_REMIT_METHOD	varchar2(200);
	P_PMT_METHOD	varchar2(200);
	P_MATURITY_DATE_LOW	date;
	P_MATURITY_DATE_HIGH	date;
	P_REMIT_AMOUNT_LOW	number;
	P_REMIT_AMOUNT_HIGH	number;
	P_CURRENCY	varchar2(200);
	LP_REMIT_ACCOUNT	varchar2(200):=' ';
	LP_REMIT_METHOD	varchar2(200):=' ';
	LP_PMT_METHOD	varchar2(200):=' ';
	LP_MATURITY_DATE	varchar2(200):=' ';
	LP_REMIT_AMOUNT	varchar2(200):=' ';
	LP_CURRENCY	varchar2(200):=' ';
	P_SORT_BY	varchar2(200);
	COUNTER	number := 1 ;
	RP_COMPANY_NAME	varchar2(50);
	RP_REPORT_NAME	varchar2(80);
	RP_SUB_TITLE	varchar2(80);
	RP_DATA_FOUND	varchar2(300);
	RP_BANK_NAME	varchar2(60);

		P_MATURITY_DATE_LOW_T varchar2(50);
		P_MATURITY_DATE_HIGH_T varchar2(50);

	function report_nameformula(Company_Name in varchar2) return varchar2  ;
	function BeforeReport return boolean  ;
	function Sub_TitleFormula return VARCHAR2  ;
	function AfterReport return boolean  ;
	function AfterPForm return boolean  ;
	function RP_DISP_SORT_BYFormula return VARCHAR2  ;
	function RP_DISP_REMIT_METHODFormula return VARCHAR2  ;
	function RP_ACCOUNT_NAMEFormula return Char  ;
	Function COUNTER_p return number;
	Function RP_COMPANY_NAME_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
	Function RP_SUB_TITLE_p return varchar2;
	Function RP_DATA_FOUND_p return varchar2;
	Function RP_BANK_NAME_p return varchar2;
	function D_SUM_AMOUNT_CURRFormula return VARCHAR2;
END AR_ARXAPRCL_XMLP_PKG;


/
