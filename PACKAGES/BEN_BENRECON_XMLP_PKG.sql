--------------------------------------------------------
--  DDL for Package BEN_BENRECON_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BENRECON_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: BENRECONS.pls 120.1 2007/12/10 08:38:16 vjaganat noship $ */
	P_PL_ID	varchar2(40);
	P_PGM_ID	varchar2(40);
	P_BUSINESS_GROUP_ID	varchar2(40);
	P_RUN_DATE	date;
	P_PERSON_ID	varchar2(40);
	P_PER_SEL_RULE	varchar2(40);
	P_BENEFIT_ACTION_ID	varchar2(40);
	P_NTL_IDENTIFIER	varchar2(40);
	P_PREM_TYPE	varchar2(40);
	P_REPORT_START_DATE	date;
	P_PAYROLL_ID	varchar2(40);
	P_REPORT_END_DATE	date;
	P_ORGANIZATION_ID	varchar2(40);
	P_LOCATION_ID	varchar2(40);
	P_BENFTS_GRP_ID	varchar2(40);
	P_RPTG_GRP_ID	varchar2(40);
	P_plan_recn_rep_header	varchar2(3000) := 'Reconciliation for';
	P_PERIOD_TOT	varchar2(30);
	P_ACTUAL_TOT	varchar2(30);
	P_PLAN_PRTT_SUBTOTAL_NAME	varchar2(500);
	P_plan_disc_rep_header	varchar2(3000) := 'Discrepancies for';
	P_LFE_REP_HEADER	varchar2(3000) := 'Life Events Affecting Premiums for';
	P_PLAN_PRTT_REP_HEADER	varchar2(3000) := 'Plan Participant Details for';

	P_DSPLY_PL_RECN_REP	varchar2(30);
	P_DSPLY_PL_DISC_REP	varchar2(30);
	P_DSPLY_PL_PRTT_REP	varchar2(30);
	P_DSPLY_LFE_REP		varchar2(30);

	T_DSPLY_PL_RECN_REP	varchar2(30);
	T_DSPLY_PL_DISC_REP	varchar2(30);
	T_DSPLY_PL_PRTT_REP	varchar2(30);
	T_DSPLY_LFE_REP		varchar2(30);




	P_DSPLY_PRTT_REPS	varchar2(30);
	P_EMP_NAME_FORMAT	varchar2(40);
	P_conc_request_id	number;
	P_MON_YEAR	varchar2(32767);
	P_DSPLY_DISC	varchar2(32767) := 'Y';
	P_DSPLY_RECN	varchar2(32767) := 'Y';
	P_DSPLY_LFE	varchar2(32767) := 'Y';
	P_DSPLY_PL_PRTT	varchar2(32767) := 'Y';
	P_OUTPUT_TYP	varchar2(32767);
	P_op_file_name	varchar2(200);
	P_REP_ST_DT	date;
	P_REP_END_DT	date;
	Pl_uom	varchar2(32767);
	P_ERROR	varchar2(4000);
	P_DATE_FORMAT	varchar2(32767);
	CP_PL_RECN_PRTT_COUNT	number := 0 ;
	CP_PL_PRTT_COUNT	number := 0 ;
	CP_LFE_PRTT_COUNT	number := 0 ;
	CP_DISC_PRTT_COUNT	number := 0 ;
	CP_DSPLY_RECN	varchar2(20) := 'Y' ;
	CP_DSPLY_DISC	varchar2(20) := 'Y' ;
	CP_DSPLY_LFE	varchar2(20) := 'Y' ;
	CP_DSPLY_PL_PRTT	varchar2(20) := 'Y' ;
	CP_PERSON	varchar2(300);
	CP_LOCATION	varchar2(300);
	CP_BENFTS_GRP	varchar2(300);
	CP_RPTG_GRP	varchar2(300);
	CP_PREM_TYPE	varchar2(300);
	CP_OUTPUT_TYP	varchar2(300);
	CP_EMP_NAME_FORMAT	varchar2(300);
	CP_PGM	varchar2(300);
	CP_PL	varchar2(300);
	CP_PER_SEL_RULE	varchar2(300);
	CP_BUSINESS_GROUP	varchar2(300);
	CP_ORGANIZATION	varchar2(300);
	CP_PAYROLL	varchar2(300);
	CP_NTL_IDENTIFIER	varchar2(50);
	function Format_Mask(p_uom varchar2) return varchar2  ;
	function AfterPForm return boolean  ;
	function cf_levelformula(levels in varchar2) return number  ;
	function cf_uomformula(pl_sql_uom in varchar2) return number  ;
	function CF_LFE_PRTT_COUNTFormula return Number  ;
	function cf_1formula(uom2 in varchar2) return number  ;
	function cf_dsicrepencyformula(pay_perd_total1 in number, actual_total1 in number, pl_prem_val1 in number, pl_sql_uom1 in varchar2) return char  ;
	function CF_DISC_PRTT_COUNTFormula return Number  ;
	function CF_headerFormula return Number  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	Function CP_PL_RECN_PRTT_COUNT_p return number;
	Function CP_PL_PRTT_COUNT_p return number;
	Function CP_LFE_PRTT_COUNT_p return number;
	Function CP_DISC_PRTT_COUNT_p return number;
	Function CP_DSPLY_RECN_p return varchar2;
	Function CP_DSPLY_DISC_p return varchar2;
	Function CP_DSPLY_LFE_p return varchar2;
	Function CP_DSPLY_PL_PRTT_p return varchar2;
	Function CP_PERSON_p return varchar2;
	Function CP_LOCATION_p return varchar2;
	Function CP_BENFTS_GRP_p return varchar2;
	Function CP_RPTG_GRP_p return varchar2;
	Function CP_PREM_TYPE_p return varchar2;
	Function CP_OUTPUT_TYP_p return varchar2;
	Function CP_EMP_NAME_FORMAT_p return varchar2;
	Function CP_PGM_p return varchar2;
	Function CP_PL_p return varchar2;
	Function CP_PER_SEL_RULE_p return varchar2;
	Function CP_BUSINESS_GROUP_p return varchar2;
	Function CP_ORGANIZATION_p return varchar2;
	Function CP_PAYROLL_p return varchar2;
	Function CP_NTL_IDENTIFIER_p return varchar2;
END BEN_BENRECON_XMLP_PKG;

/
