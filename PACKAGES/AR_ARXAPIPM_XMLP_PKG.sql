--------------------------------------------------------
--  DDL for Package AR_ARXAPIPM_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_ARXAPIPM_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: ARXAPIPMS.pls 120.0 2007/12/27 13:27:21 abraghun noship $ */
	P_CONC_REQUEST_ID	number;
	P_Set_of_Books_Id	number;
	P_SORT_BY	varchar2(30);
	P_STATUS	varchar2(30);
	P_INV_DATE_HIGH	date;
	P_INV_DATE_LOW	date;
	P_DUE_DATE_HIGH	date;
	P_DUE_DATE_LOW	date;
	P_PMT_MTD	varchar2(100);
	P_CUST_NAME	varchar2(100);
	P_CUST_NUMBER	varchar2(32767);
	P_INV_NUM_HIGH	varchar2(100);
	P_INV_NUM_LOW	varchar2(100);
	P_INV_TYPE	varchar2(100);
	P_CURRENCY	varchar2(300);
	LP_CURRENCY	varchar2(200):=' ';
	LP_STATUS	varchar2(200):=' ';
	LP_INV_DATE	varchar2(200):=' ';
	LP_DUE_DATE	varchar2(200):=' ';
	LP_PMT_METHOD	varchar2(200):=' ';
	LP_CUST_NAME	varchar2(200):=' ';
	LP_CUST_NUM	varchar2(200):=' ';
	LP_INV_NUM	varchar2(200):=' ';
	LP_INV_TYPE	varchar2(200):=' ';
	P_SUMMARIZE	varchar2(200);
	RP_SUMMARIZE	varchar2(32767):='NO';
	LP_GROUP_BY	varchar2(1000):=' ';
	LP_SUM_COLUMN	varchar2(800):='nvl(pays.amount_due_remaining, 0)';
	RP_COMPANY_NAME	varchar2(50);
	RP_REPORT_NAME	varchar2(80);
	RP_SUB_TITLE1	varchar2(80);
	RP_SUB_TITLE2	varchar2(300);
	RP_DATA_FOUND	varchar2(300);
	RP_FUNCTIONAL_CURRENCY	varchar2(200);
	--ADDED AS FIX
	P_INV_DATE_LOW_T VARCHAR2(60);
	P_INV_DATE_HIGH_T VARCHAR2(60);
	P_DUE_DATE_LOW_T VARCHAR2(60);
	P_DUE_DATE_HIGH_T VARCHAR2(60);
	--FIX ENDS
	function report_nameformula(Company_Name in varchar2, functional_currency in varchar2) return varchar2  ;
	function BeforeReport return boolean  ;
	function Sub_TitleFormula return VARCHAR2  ;
	function AfterReport return boolean  ;
	function AfterPForm return boolean  ;
	function RP_DSP_SORT_BYFormula return VARCHAR2  ;
	function RP_DSP_SUMMARIZEFormula return VARCHAR2  ;
	function RP_DSP_STATUSFormula return VARCHAR2  ;
	function CF_report_dateFormula return Char  ;
	Function RP_COMPANY_NAME_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
	Function RP_SUB_TITLE1_p return varchar2;
	Function RP_SUB_TITLE2_p return varchar2;
	Function RP_DATA_FOUND_p return varchar2;
	Function RP_FUNCTIONAL_CURRENCY_p return varchar2;
	Function D_SUM_AMOUNT_DUE_CURRFormula return varchar2;
END AR_ARXAPIPM_XMLP_PKG;


/
