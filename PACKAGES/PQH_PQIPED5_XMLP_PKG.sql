--------------------------------------------------------
--  DDL for Package PQH_PQIPED5_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_PQIPED5_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PQIPED5S.pls 120.1 2007/12/21 17:27:59 vjaganat noship $ */
	P_BUSINESS_GROUP_ID	varchar2(40);
	P_CONC_REQUEST_ID	number;
	P_REPORT_DATE	date;
	line_num	number := 2 ;
	CP_ReportTotTitle	varchar2(50) := 'Part A Total (sum of lines 1 ,9,17)' ;
	CP_lastLineNum	number := 18 ;
	CP_FT	varchar2(2000);
	CP_FR	varchar2(2000);
	CP_PT	varchar2(2000);
	CP_PR	varchar2(2000);
	function CF_1Formula return Number  ;
	function sumnrmenperreportformula(Sum_GT9_NRMen in number, Sum_LT9_NRMen in number) return number  ;
	function sumnrwmenperreportformula(Sum_GT9_NRWmen in number, Sum_Lt9_NRWmen in number) return number  ;
	function sumbnhmenperreportformula(Sum_GT9_BnHMen in number, Sum_LT9_BnhMen in number) return number  ;
	function sumbnhwmenperreportformula(Sum_GT9_BnHWmen in number, Sum_LT9_BnHWmen in number) return number  ;
	function sumam_almenperreportformula(Sum_GT9_Am_AlMen in number, Sum_LT9_Am_AlMen in number) return number  ;
	function sumam_alwmenperreportformula(Sum_GT9_Am_AlWmen in number, Sum_LT9_Am_AlWmen in number) return number  ;
	function sumapmenperreportformula(Sum_GT9_A_PMen in number, Sum_LT9_APMen in number) return number  ;
	function sumapwmenperreportformula(Sum_GT9_A_PWmen in number, Sum_LT9_APWmen in number) return number  ;
	function sumhmenperreportformula(Sum_GT9_HMen in number, Sum_Lt9_HMen in number) return number  ;
	function sumhwmenperreportformula(Sum_GT9_HWmen in number, Sum_LT9_HWmen in number) return number  ;
	function sumwnhmenperreportformula(Sum_GT9_WnHMen in number, Sum_LT9_WnHMen in number) return number  ;
	function sumwnhwmenperreportformula(Sum_GT9_WnHWmen in number, Sum_LT9_WnHWmen in number) return number  ;
	function sumurmenperreportformula(Sum_GT9_URMen in number, Sum_LT9_URMen in number) return number  ;
	function sumurwmenperreportformula(Sum_GT9_URWmen in number, Sum_LT9_URWmen in number) return number  ;
	function sumtotmenperreportformula(Sum_GT9_totMen in number, Sum_LT9_TotMen in number) return number  ;
	function sumtotwmenperreportformula(Sum_GT9_TotWmen in number, Sum_LT9_TotWmen in number) return number  ;
	function CF_GroupTotTitleFormula(SC in varchar2) return Char  ;
	function cf_linenogroupformula(SC in varchar2) return number  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	Function line_num_p return number;
	Function CP_ReportTotTitle_p return varchar2;
	Function CP_lastLineNum_p return number;
	Function CP_FT_p return varchar2;
	Function CP_FR_p return varchar2;
	Function CP_PT_p return varchar2;
	Function CP_PR_p return varchar2;
END PQH_PQIPED5_XMLP_PKG;

/
