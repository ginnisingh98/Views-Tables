--------------------------------------------------------
--  DDL for Package PQH_PQHWSOPS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_PQHWSOPS_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PQHWSOPSS.pls 120.1 2007/12/07 07:02:03 vjaganat noship $ */
	P_BUSINESS_GROUP_ID	number;
	p_business_group_id_1   number;
	P_SESSION_DATE	date;
        P_SESSION_DATE_1	date;
	P_REPORT_TITLE	varchar2(80);
	P_CONC_REQUEST_ID	number;
	P_START_DATE	date;
        P_START_DATE_1	date;
	P_END_DATE	date;
        P_END_DATE_1	date;
	P_ORGANIZATION_ID	number;
	P_ORGANIZATION_ID_1	number;
	P_POSITION_TYPE	varchar2(40);
	P_VARIANCE_PERCENT	number;
	P_currency_code	varchar2(15);
	P_EFFECTIVE_DATE	date;
	p_effective_date_1 date;
	C_REPORT_SUBTITLE	varchar2(60);
	CP_organization_name	varchar2(240);
	CP_position_type	varchar2(80);
	CP_currency	varchar2(80);
	C_BUSINESS_GROUP_NAME	varchar2(240);
	cp_session_dt	date;
	function BeforeReport return boolean  ;
	function cf_1formula(Budget_Unit_id1 in number, actual_amt in number, committed_amt in number) return number  ;
	function cf_def_ex_amtformula(budgeted_amt in number, cf_projected_exp in number) return number  ;
	function BeforePForm return boolean  ;
	function cf_act_performula(budgeted_amt in number, actual_amt in number) return number  ;
	function cf_com_performula(budgeted_amt in number, committed_amt in number) return number  ;
	function cf_proj_performula(budgeted_amt in number, cf_projected_exp in number) return number  ;
	function cf_def_ex_performula(budgeted_amt in number, cf_def_ex_amt in number) return number  ;
	function cf_org_budgeted_amtformula(organization_id1 in number, budget_unit_id in number) return number  ;
	function cf_org_actual_amtformula(organization_id1 in number, budget_unit_id in number) return number  ;
	function cf_org_act_performula(cf_org_budgeted_amt in number, cf_org_actual_amt in number) return number  ;
	function cf_org_committed_amtformula(organization_id1 in number, budget_unit_id in number) return number  ;
	function cf_org_com_performula(cf_org_budgeted_amt in number, cf_org_committed_amt in number) return number  ;
	function cf_org_projected_expformula(Budget_Unit_id in number, cf_org_actual_amt in number, cf_org_committed_amt in number) return number  ;
	function cf_org_proj_performula(cf_org_budgeted_amt in number, cf_org_projected_exp in number) return number  ;
	function cf_org_def_ex_amtformula(cf_org_budgeted_amt in number, cf_org_projected_exp in number) return number  ;
	function cf_org_def_ex_performula(cf_org_budgeted_amt in number, cf_org_def_ex_amt in number) return number  ;
	function cf_format_mask1(budget_unit_id in number) return char  ;
	function cf_format_mask2(budget_unit_id1 in number) return char  ;
	function AfterReport return boolean  ;
	Function C_REPORT_SUBTITLE_p return varchar2;
	Function CP_organization_name_p return varchar2;
	Function CP_position_type_p return varchar2;
	Function CP_currency_p return varchar2;
	Function C_BUSINESS_GROUP_NAME_p return varchar2;
	Function cp_session_dt_p return date;
END PQH_PQHWSOPS_XMLP_PKG;

/
