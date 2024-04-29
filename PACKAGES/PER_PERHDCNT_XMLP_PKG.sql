--------------------------------------------------------
--  DDL for Package PER_PERHDCNT_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PERHDCNT_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PERHDCNTS.pls 120.1 2007/12/06 11:27:10 amakrish noship $ */
	P_REPORT_DATE_FROM	date;
	P_REPORT_DATE_TO	date;
	P_TOP_ORGANIZATION_ID	number;
	P_ORGANIZATION_STRUCTURE_ID	number;
	P_BUSINESS_GROUP_ID	number;
	P_REPORT_DATE	date;
	P_ROLL_UP	varchar2(32767);
	P_BUDGET	varchar2(32767);
	P_JOB_CATEGORY	varchar2(32767);
	P_INCLUDE_TOP_ORG	varchar2(32767);
	P_INCLUDE_ASG_TYPE	varchar2(32767);
	P_DAYS_PRIOR_TO_END_DATE	number;
	P_WORKER_TYPE	varchar2(32767);
	P_CONC_REQUEST_ID	number;
	CP_BUSINESS_GROUP_NAME	varchar2(240);
	CP_TOP_ORG_NAME	varchar2(240);
	CP_ORGANIZATION_HIERARCHY_NAME	varchar2(60);
	CP_NULL	number;
	CP_TERM	varchar2(20);
	CP_NH	varchar2(30);
	CP_NH1	varchar2(20);
	CP_TERM1	varchar2(20);
	CP_WORKER_TYPE	varchar2(50);
	function BeforeReport return boolean  ;
	function cf_rev_vol_termformula(cs_rev_vol_term in number, Sumrev_start_valPerorg_structu in number) return number  ;
	function cf_nonrev_vol_termformula(cs_nonrev_vol_term in number, Sumnonrev_start_valPerorg_stru in number) return number  ;
	function cf_rev_invol_termformula(cs_nonrev_invol_term in number, Sumnonrev_start_valPerorg_stru in number) return number  ;
	function cf_rev_invol_termformula0017(cs_rev_invol_term in number, Sumrev_start_valPerorg_structu in number) return number  ;
	function cf_rev_cur_termformula(cs_rev_cur_term in number, Sumrev_start_valPerorg_structu in number) return number  ;
	function cf_nonrev_cur_termformula(cs_nonrev_cur_term in number, Sumnonrev_start_valPerorg_stru in number) return number  ;
	function cf_rev_pct_changeformula(Sumrev_start_valPerorg_structu in number, Sumrev_end_valPerorg_Structure in number) return number  ;
	function cf_nonrev_pct_changeformula(Sumnonrev_start_valPerorg_stru in number, Sumnonrev_end_valPerorg_Struct in number) return number  ;
	function cf_days_betweenformula(date_to in date, date_from in date) return number  ;
	function AfterReport return boolean  ;
	Function CP_BUSINESS_GROUP_NAME_p return varchar2;
	Function CP_TOP_ORG_NAME_p return varchar2;
	Function CP_ORGANIZATION_HIERARCHY_NAM return varchar2;
	Function CP_NULL_p return number;
	Function CP_TERM_p return varchar2;
	Function CP_NH_p return varchar2;
	Function CP_NH1_p return varchar2;
	Function CP_TERM1_p return varchar2;
	Function CP_WORKER_TYPE_p return varchar2;
END PER_PERHDCNT_XMLP_PKG;

/
