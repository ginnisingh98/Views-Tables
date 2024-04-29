--------------------------------------------------------
--  DDL for Package PQH_PQIPED10_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_PQIPED10_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PQIPED10S.pls 120.1 2007/12/21 17:26:39 vjaganat noship $ */
	P_BUSINESS_GROUP_ID	varchar2(40);
	P_CONC_REQUEST_ID	number;
	P_REPORT_DATE	date;
	CP_FR	varchar2(2000);
	CP_FT	varchar2(2000);
	CP_PR	varchar2(2000);
	CP_PT	varchar2(2000);
	line_num	number := 2 ;
	LastLineNo	number := 10 ;
	totTitle	varchar2(52) := 'Total Full-Time Employees (sum of lines 1,3-9)' ;
	function cf_1formula(SUMNRMenNonInstr in number, Sum_Instr_NRMen in number) return number  ;
	function cf_2formula(SUMNRWMenNonInstr in number, Sum_Instr_NRWMen in number) return number  ;
	function cf_3formula(SUMBnHMenNonInstr in number, Sum_Instr_BnHMen in number) return number  ;
	function cf_4formula(SUMBnHWMenNonInstr in number, Sum_Instr_BnHWMen in number) return number  ;
	function cf_4formula0004(SUMAm_AlMenNonInstr in number, Sum_Instr_Am_AlMen in number) return number  ;
	function cf_sumam_alwmenformula(SUMAm_AlWMenNonInstr in number, Sum_Instr_Am_AlWMen in number) return number  ;
	function cf_sumapmenformula(SUMAPMenNonInstr in number, Sum_Instr_APMen in number) return number  ;
	function cf_sumapwmenformula(SUMAPWmenNonInstr in number, Sum_Instr_APWmen in number) return number  ;
	function cf_sumhmenformula(SUMHMenNonInstr in number, Sum_Instr_HMen in number) return number  ;
	function cf_sumhwmenformula(SUMHWMenNonInstr in number, Sum_Instr_HWMen in number) return number  ;
	function cf_sumwnhmenformula(SUMWnHMenNonInstr in number, Sum_Instr_WnHMen in number) return number  ;
	function cf_sumwnhwmenformula(SUMWnHWMenNonInstr in number, Sum_Instr_WnHWMen in number) return number  ;
	function cf_sumurmenformula(SUMURMenNonInstr in number, Sum_Instr_URMen in number) return number  ;
	function cf_sumurwmenformula(SUMURWMenNonInstr in number, Sum_Instr_URWMen in number) return number  ;
	function cf_totmenformula(SUMTotMenNonInstr in number, Sum_Instr_TotMen in number) return number  ;
	function cf_11formula(SUMTotWMenNonInstr in number, Sum_Instr_TotWMen in number) return number  ;
	function BeforeReport return boolean  ;
	function line_noFormula return Number  ;
	function AfterReport return boolean  ;
	Function CP_FR_p return varchar2;
	Function CP_FT_p return varchar2;
	Function CP_PR_p return varchar2;
	Function CP_PT_p return varchar2;
	Function line_num_p return number;
	Function LastLineNo_p return number;
	Function totTitle_p return varchar2;
END PQH_PQIPED10_XMLP_PKG;

/
