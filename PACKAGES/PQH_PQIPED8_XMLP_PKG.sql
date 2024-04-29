--------------------------------------------------------
--  DDL for Package PQH_PQIPED8_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_PQIPED8_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PQIPED8S.pls 120.2 2007/12/21 17:28:13 vjaganat noship $ */
	P_BUSINESS_GROUP_ID	varchar2(40);
	P_CONC_REQUEST_ID	number;
	P_REPORT_DATE	date;
	CP_FR	varchar2(2000);
	CP_FT	varchar2(2000);
	CP_PR	varchar2(2000);
	CP_PT	varchar2(2000);
	CP_REPORT_DATE varchar2(20);
	line_num	number := 78 ;
	CP_LineNumRepTot	number := 99 ;
	CP_RepTotTitle	varchar2(77) := 'Total Faculty (sum of lines 84,91 and 98)' ;
	function BeforeReport return boolean  ;
	function CF_1Formula return Number  ;
	function cf_grouplinenumformula(TenStat in varchar2) return number  ;
	function CF_GroupTotTitleFormula(TenStat in varchar2) return Char  ;
	function AfterReport return boolean  ;
	Function CP_FR_p return varchar2;
	Function CP_FT_p return varchar2;
	Function CP_PR_p return varchar2;
	Function CP_PT_p return varchar2;
	Function line_num_p return number;
	Function CP_LineNumRepTot_p return number;
	Function CP_RepTotTitle_p return varchar2;
END PQH_PQIPED8_XMLP_PKG;

/
