--------------------------------------------------------
--  DDL for Package PQH_PQIPED1_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_PQIPED1_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PQIPED1S.pls 120.1 2007/12/21 17:27:23 vjaganat noship $ */
	P_REPORT_DATE	date;
        P_REPORT_DATE_T	VARCHAR2(40);
	P_BUSINESS_GROUP_ID	varchar2(40);
	P_CONC_REQUEST_ID	number;
	line_num	number := 2 ;
	CP_FT	varchar2(2000);
	CP_FR	varchar2(2000);
	CP_PT	varchar2(2000);
	CP_pr	varchar2(2000);
	function lineFormula return Number  ;
	function CF_TotTitleFormula(orgCode in varchar2) return Char  ;
	function CF_dispNameFormula(orgCode in varchar2) return Char  ;
	function BeforePForm return boolean  ;
	function BeforeReport return boolean  ;
	function cf_sumfacultyformula(SumFacultyTenured in number, SumFacultyOnTenure in number, SumFacultyNotOnTenure in number) return number  ;
	function AfterReport return boolean  ;
	Function line_num_p return number;
	Function CP_FT_p return varchar2;
	Function CP_FR_p return varchar2;
	Function CP_PT_p return varchar2;
	Function CP_pr_p return varchar2;
END PQH_PQIPED1_XMLP_PKG;

/
