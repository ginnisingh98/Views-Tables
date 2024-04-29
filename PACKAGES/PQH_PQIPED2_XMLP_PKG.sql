--------------------------------------------------------
--  DDL for Package PQH_PQIPED2_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_PQIPED2_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PQIPED2S.pls 120.1 2007/12/21 17:27:09 vjaganat noship $ */
	P_REPORT_DATE	date;
        P_REPORT_DATE_T	VARCHAR2(40);
	P_BUSINESS_GROUP_ID	varchar2(40);
	P_CONC_REQUEST_ID	number;
	line_num	number := 26 ;
	CP_FR	varchar2(2000);
	CP_FT	varchar2(2000);
	CP_PR	varchar2(2000);
	CP_PT	varchar2(2002);
	tmp_var	number := 28 ;
	tmp_var1	number := 41 ;
	CP_NonFacInstr	number := 0 ;
	function lineFormula return Number  ;
	function CF_totTitleFormula(orgCode in varchar2) return Char  ;
	function BeforeReport return boolean  ;
	function CF_dispNameFormula(orgCode in varchar2) return Char  ;
	function cf_faculty_totformula(SumFacultyTenured in number, SumFacultyOnTen in number, SumFacultyNotOnTen in number) return number  ;
	function AfterReport return boolean  ;
	Function line_num_p return number;
	Function CP_FR_p return varchar2;
	Function CP_FT_p return varchar2;
	Function CP_PR_p return varchar2;
	Function CP_PT_p return varchar2;
	Function tmp_var_p return number;
	Function tmp_var1_p return number;
	Function CP_NonFacInstr_p return number;
END PQH_PQIPED2_XMLP_PKG;

/
