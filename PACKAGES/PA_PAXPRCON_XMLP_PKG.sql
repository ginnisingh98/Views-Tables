--------------------------------------------------------
--  DDL for Package PA_PAXPRCON_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PAXPRCON_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAXPRCONS.pls 120.0 2008/01/02 11:50:01 krreddy noship $ */
	P_PROJECT_ID	number;
	P_CONC_REQUEST_ID	number;
	P_debug_mode	varchar2(3);
	P_rule_optimizer	varchar2(3);
	P_costing	varchar2(3);
	p_ca_set_of_books_id	number;
	p_ca_org_id	number;
	p_mrcsobtype	varchar2(10);
	lp_pa_implementations	varchar2(50);
	lp_pa_implementations_all	varchar2(50);
	lp_pa_expenditure_items	varchar2(50);
	lp_pa_expenditure_items_all	varchar2(50);
	lp_pa_cost_dist_lines	varchar2(50);
	lp_pa_cost_dist_lines_all	varchar2(50);
	lp_pa_expenditures	varchar2(50);
	lp_pa_expenditures_all	varchar2(50);
	lp_pa_proj_expend_view	varchar2(50);
	lp_pa_ei_denorm_v	varchar2(50);
	lp_ap_invoice_dist	varchar2(50);
	lp_pa_cost_xfer_audit	varchar2(50);
	lp_pa_cc_cost_xfer_audit	varchar2(50);
	lp_pa_events	varchar2(50):='pa_events';
	C_COMPANY_NAME_HEADER	varchar2(50);
	C_project_name	varchar2(30);
	C_project_number	varchar2(30);
	C_no_data_found	varchar2(80) := 'NO DATA FOUND' ;
	CP_bill_name	varchar2(30);
	FUNCTION  get_cover_page_values   RETURN BOOLEAN  ;
	function BeforeReport return boolean  ;
	FUNCTION  get_company_name    RETURN BOOLEAN  ;
	Function NO_DATA_FOUND_FUNC RETURN BOOLEAN  ;
	function AfterReport return boolean  ;
	function g_rev_billgroupfilter(ptcc in varchar2) return boolean  ;
	function g_job_bill_ratesgroupfilter(ptcc in varchar2) return boolean  ;
	function g_emp_bill_ratesgroupfilter(ptcc in varchar2) return boolean  ;
	function g_nl_bill_ratesgroupfilter(ptcc in varchar2) return boolean  ;
	function g_job_title_orgroupfilter(ptcc in varchar2) return boolean  ;
	function g_job_assgn_orgroupfilter(ptcc in varchar2) return boolean  ;
	function g_labor_multipliersgroupfilter(ptcc in varchar2) return boolean  ;
	function G_customerGroupFilter return boolean  ;
	function G_contactsGroupFilter return boolean  ;
	function g_project_assetgroupfilter(ptcc in varchar2) return boolean  ;
	function cf_baselineformula(baseline_funding_flag in varchar2) return char  ;
	function cf_revaluateformula(revaluate_funding_flag in varchar2) return char  ;
	function cf_includeformula(include_gains_losses_flag in varchar2) return char  ;
	function cf_emp_reasonformula(emp_disc_reason in varchar2) return char  ;
	function cf_nl_reasonformula(nl_disc_reason in varchar2) return char  ;
	function cf_job_reasonformula(job_disc_reason in varchar2) return char  ;
	function AfterPForm return boolean  ;
	function cf_bill_to_customerformula(bill_to_customer_id in number) return char  ;
	function cf_ship_to_customerformula(ship_to_customer_id in number) return char  ;
	function cf_bill_to_cust_noformula(bill_to_customer_id in number) return char  ;
	function cf_ship_to_cust_noformula(ship_to_customer_id in number) return char  ;
	function cf_customerformula(enable_top_task_customer_flag in varchar2, project_id_1 in number) return char  ;
	function cf_inv_methodformula(enable_top_task_inv_mth_flag in varchar2, project_id_1 in number) return char  ;
	function cf_rev_acc_mthformula(revenue_accrual_method in varchar2, project_id_1 in number) return char  ;
	function cf_inv_mthformula(invoice_method in varchar2, project_id_1 in number) return char  ;
	Function C_COMPANY_NAME_HEADER_p return varchar2;
	Function C_project_name_p return varchar2;
	Function C_project_number_p return varchar2;
	Function C_no_data_found_p return varchar2;
	Function CP_bill_name_p return varchar2;
END PA_PAXPRCON_XMLP_PKG;

/
