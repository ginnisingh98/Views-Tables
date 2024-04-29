--------------------------------------------------------
--  DDL for Package PQH_PQIPED6_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_PQIPED6_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PQIPED6S.pls 120.2 2007/12/21 17:27:44 vjaganat noship $ */
	P_BUSINESS_GROUP_ID	varchar2(40);
	P_CONC_REQUEST_ID	number;
	P_REPORT_DATE	date;
	LP_REPORT_DATE varchar2(20);
	line_num	number  :=19 ;
	CP_FR	varchar2(2000);
	CP_FT	varchar2(2000);
	CP_PR	varchar2(2000);
	CP_PT	varchar2(2000);
	CP_lastLineNo	number := 67 ;
	CP_ReportTotTitle	varchar2(79) := 'Total All Full-Time Employees (sum of lines 18, 26, 34, 42, 48, 54, 60 and 66)' ;
	tmp_var	number := 49 ;
	tmp_var1	number := 54 ;
	tmp_var2	number := 61 ;
	function line1Formula return Number  ;
	function CF_GroupTotTitleFormula(JobCode in number) return Char  ;
	function cf_group_linenoformula(JobCode in number) return number  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	Function line_num_p return number;
	Function CP_FR_p return varchar2;
	Function CP_FT_p return varchar2;
	Function CP_PR_p return varchar2;
	Function CP_PT_p return varchar2;
	Function CP_lastLineNo_p return number;
	Function CP_ReportTotTitle_p return varchar2;
	Function tmp_var_p return number;
	Function tmp_var1_p return number;
	Function tmp_var2_p return number;
END PQH_PQIPED6_XMLP_PKG;

/
