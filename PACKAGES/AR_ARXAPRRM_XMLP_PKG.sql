--------------------------------------------------------
--  DDL for Package AR_ARXAPRRM_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_ARXAPRRM_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: ARXAPRRMS.pls 120.0 2007/12/27 13:32:49 abraghun noship $ */
	P_CONC_REQUEST_ID	number;
	P_Set_of_Books_Id	number;
	P_SORT_BY	varchar2(40):='Maturity Date';
	P_SUMMARIZE	varchar2(200);
	P_STATUS	varchar2(200);
	P_REMIT_ACCOUNT	varchar2(200);
	P_REMIT_METHOD	varchar2(200);
	P_PMT_METHOD	varchar2(200);
	P_MATURITY_DATE_LOW	date;
	P_MATURITY_DATE_HIGH	date;
	P_MATURITY_DATE_LOW1	varchar2(10);
	P_MATURITY_DATE_HIGH1	varchar2(10);
	P_REMIT_AMOUNT_LOW	varchar2(41);
	P_REMIT_AMOUNT_HIGH	varchar2(41);
	P_CURRENCY	varchar2(200);
	LP_STATUS	varchar2(200):=' ';
	LP_REMIT_ACCOUNT	varchar2(200):=' ';
	LP_REMIT_METHOD	varchar2(200):=' ';
	LP_PMT_METHOD	varchar2(200):=' ';
	LP_MATURITY_DATE	varchar2(200):=' ';
	LP_REMIT_AMOUNT	varchar2(200):=' ';
	LP_CURRENCY	varchar2(200):=' ';
	RP_SUMMARIZE	varchar2(32767):='NO';
	RP_SUM_COL_AMOUNT	varchar2(200):='cr.amount';
	RP_SUM_COL_CHARGES	varchar2(200):='cr.factor_discount_amount';
	RP_GROUP_BY	varchar2(800):=' ';
	COUNTER	number := 1 ;
	RP_COMPANY_NAME	varchar2(50);
	RP_REPORT_NAME	varchar2(240);
	RP_SUB_TITLE	varchar2(80);
	RP_DATA_FOUND	varchar2(300);
	RP_FUNCTIONAL_CURRENCY	varchar2(15);
	function report_nameformula(Company_Name in varchar2, functional_currency in varchar2) return varchar2  ;
	function BeforeReport return boolean  ;
	function Sub_TitleFormula return VARCHAR2  ;
	function AfterReport return boolean  ;
	function COUNTERFormula return Number  ;
	function AfterPForm return boolean  ;
	function RP_DISP_SUMMARIZEFormula return VARCHAR2  ;
	function RP_DISP_SORT_BYFormula return VARCHAR2  ;
	function RP_DISP_STATUSFormula return VARCHAR2  ;
	function RP_DISP_REMIT_METHODFormula return VARCHAR2  ;
	Function COUNTER_p return number;
	Function RP_COMPANY_NAME_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
	Function RP_SUB_TITLE_p return varchar2;
	Function RP_DATA_FOUND_p return varchar2;
	Function RP_FUNCTIONAL_CURRENCY_p return varchar2;
	function D_SUM_AMOUNT_CURRFormula return VARCHAR2;
END AR_ARXAPRRM_XMLP_PKG;


/
