--------------------------------------------------------
--  DDL for Package PQH_PQIPED3_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_PQIPED3_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PQIPED3S.pls 120.2 2007/12/21 17:26:54 vjaganat noship $ */
	P_BUSINESS_GROUP_ID	varchar2(40);
	P_REPORT_DAY_MONTH	varchar2(40);
	P_CONC_REQUEST_ID	number;
	P_REPORT_DATE	date;
	CP_REPORT_DATE	varchar2(20);
	line_num	number := 1  ;
	CP_TotTitlePerReport	varchar2(120) := 'Total Instruction Combined with Research and/or  Public Service Employees' ;
	CP_PT	varchar2(2000);
	CP_PR	varchar2(2000);
	CP_FT	varchar2(2000);
	CP_FR	varchar2(2000);
	ReportTotLineNo	number := 15 ;
	function lineFormula return Number  ;
	function CF_GroupTotTitleFormula(genCode in varchar2) return char  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	Function line_num_p return number;
	Function CP_TotTitlePerReport_p return varchar2;
	Function CP_PT_p return varchar2;
	Function CP_PR_p return varchar2;
	Function CP_FT_p return varchar2;
	Function CP_FR_p return varchar2;
	Function ReportTotLineNo_p return number;
END PQH_PQIPED3_XMLP_PKG;

/
