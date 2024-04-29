--------------------------------------------------------
--  DDL for Package PA_PAXMGPBS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PAXMGPBS_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAXMGPBSS.pls 120.1 2008/01/03 11:14:24 krreddy noship $ */
	p_start_organization_id	number;
	PROJECT_ROLE_TYPE	varchar2(40);
	PROJECT_MEMBER	number;
	DAYS_SINCE	varchar2(40);
	NEVER_BILLED	varchar2(1);
	BILLING_METHOD	varchar2(40);
	BILL_THRU_DATE	date;
	CP_BILL_THRU_DATE VARCHAR2(20);
	PROJECT	number;
	P_CONC_REQUEST_ID	number;
	P_debug_mode	varchar2(3);
	P_rule_optimizer	varchar2(3);
	C_COMPANY_NAME_HEADER	varchar2(50);
	C_start_org	varchar2(60);
	C_project_member	varchar2(240);
	C_role_type	varchar2(80);
	C_enter	varchar2(80);
	C_proj_number	varchar2(30);
	C_proj_name	varchar2(40);
	C_never_billed	varchar2(80);
	C_billing_method	varchar2(80);
	FUNCTION  get_cover_page_values   RETURN BOOLEAN  ;
	function BeforeReport return boolean  ;
	FUNCTION  get_company_name    RETURN BOOLEAN  ;
	FUNCTION get_start_org RETURN BOOLEAN  ;
	function AfterReport return boolean  ;
	function CF_CURRECNY_CODEFormula return VARCHAR2  ;
	function cf_ubrformula(projfunc_ubr_amount in number) return number  ;
	function cf_1formula(enable_top_task_inv_mth_flag in varchar2) return varchar2  ;
	Function C_COMPANY_NAME_HEADER_p return varchar2;
	Function C_start_org_p return varchar2;
	Function C_project_member_p return varchar2;
	Function C_role_type_p return varchar2;
	Function C_enter_p return varchar2;
	Function C_proj_number_p return varchar2;
	Function C_proj_name_p return varchar2;
	Function C_never_billed_p return varchar2;
	Function C_billing_method_p return varchar2;
END PA_PAXMGPBS_XMLP_PKG;

/
