--------------------------------------------------------
--  DDL for Package AR_ARXGRL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_ARXGRL_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: ARXGRLS.pls 120.0 2007/12/27 13:52:34 abraghun noship $ */
	P_CONC_REQUEST_ID	number;
	P_Set_of_Books_Id	number;
	P_RUN_ORDERING	varchar2(32767);
	P_RUN_GROUPING	varchar2(32767);
	P_ORDERING_NAME_LOW	varchar2(200);
	P_ORDERING_NAME_HIGH	varchar2(200);
	P_GROUPING_NAME_LOW	varchar2(200);
	P_GROUPING_NAME_HIGH	varchar2(200);
	LP_ORDERING_LOW	varchar2(200) := ' ';
	LP_ORDERING_HIGH	varchar2(200):= ' ';
	LP_GROUPING_LOW	varchar2(200):= ' ';
	LP_GROUPING_HIGH	varchar2(200):= ' ';
	--	LP_ORDERING_LOW	varchar2(200);
	--	LP_ORDERING_HIGH	varchar2(200);
	--	LP_GROUPING_LOW	varchar2(200);
	--	LP_GROUPING_HIGH	varchar2(200);
	P_RUN_ORDERING_MEANING	varchar2(50);
	P_RUN_GROUPING_MEANING	varchar2(50);
	Acct_Bal_Aprompt	varchar2(50);
	RP_COMPANY_NAME	varchar2(50);
	RP_REPORT_NAME	varchar2(80);
	RP_DATA_FOUND	varchar2(300);
	RP_SUB_TITLE	varchar2(80);
	function report_nameformula(Company_Name in varchar2) return varchar2  ;
	function BeforeReport return boolean  ;
	function Sub_TitleFormula return VARCHAR2  ;
	function AfterReport return boolean  ;
	function org_idFormula return VARCHAR2  ;
	function tax_acct_seg_numformula(location_structure_id in number) return number  ;
	function AfterPForm return boolean  ;
	Function Acct_Bal_Aprompt_p return varchar2;
	Function RP_COMPANY_NAME_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
	Function RP_DATA_FOUND_p return varchar2;
	Function RP_SUB_TITLE_p return varchar2;
END AR_ARXGRL_XMLP_PKG;


/
