--------------------------------------------------------
--  DDL for Package AR_ARXAPRMB_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_ARXAPRMB_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: ARXAPRMBS.pls 120.0 2007/12/27 13:31:50 abraghun noship $ */
	P_CONC_REQUEST_ID	number;
	P_Set_of_Books_Id	number;
	P_STATUS	varchar2(200);
	LP_STATUS	varchar2(200):=' ';
	P_SORT_BY	varchar2(200):='REMITTANCE ACCOUNT';
	P_SORT_BY_T	varchar2(1200):='REMITTANCE ACCOUNT';
	P_REM_DATE_FROM	date;
	P_REM_DATE_TO	date;
	P_REM_DATE_FROM_T varchar2(200);
	P_REM_DATE_TO_T varchar2(200);
	P_DEPNO_LOW	varchar2(23);
	P_DEPNO_HIGH	varchar2(30);
	P_REMIT_BANK_ACCOUNT	varchar2(40);
	P_REMIT_BANK_BRANCH	varchar2(30);
	P_BATCH_NAME_LOW	varchar2(32767);
	P_SUMMARY_OR_DETAILED	varchar2(32767);
	P_BATCH_NAME_HIGH	varchar2(32767);
	P_REMITTANCE_METHOD	varchar2(40);
	P_REMIT_BANK	varchar2(40);
	P_INCLUDE_FORMATTED	varchar2(32767);
	RP_COMPANY_NAME	varchar2(50);
	RP_REPORT_NAME	varchar2(240);
	RP_SUB_TITLE	varchar2(80);
	RP_DATA_FOUND	varchar2(300);
	function report_nameformula(Company_Name in varchar2) return varchar2  ;
	function BeforeReport return boolean  ;
	function Sub_TitleFormula return VARCHAR2  ;
	function AfterReport return boolean  ;
	function AfterPForm return boolean  ;
	function RP_DSP_SORT_BYFormula return VARCHAR2  ;
	function RP_DSP_STATUSFormula return VARCHAR2  ;
	function amountformula(status_code in varchar2, p_batch_id in number) return number  ;
	function DISP_REMIT_METHODFormula return VARCHAR2  ;
	function DISP_REMIT_ACCOUNTFormula return VARCHAR2  ;
	function DISP_INC_FORMATTEDFormula return VARCHAR2  ;
	function DISP_SUM_OR_DETFormula return VARCHAR2  ;
	function det_batch_statusformula(batch_status in varchar2) return varchar2  ;
	Function RP_COMPANY_NAME_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
	Function RP_SUB_TITLE_p return varchar2;
	Function RP_DATA_FOUND_p return varchar2;
END AR_ARXAPRMB_XMLP_PKG;


/
