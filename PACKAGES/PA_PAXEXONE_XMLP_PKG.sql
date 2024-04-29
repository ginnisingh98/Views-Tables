--------------------------------------------------------
--  DDL for Package PA_PAXEXONE_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PAXEXONE_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAXEXONES.pls 120.0 2008/01/02 11:31:42 krreddy noship $ */
	EMPLOYEE_ID	number;
	DATE_LOW	date;
	DATE_HIGH	date;
	INCURRED_ORG	number;
	INC_ROUTING_HISTORY	varchar2(40);
	P_CONC_REQUEST_ID	number;
	P_debug_mode	varchar2(3);
	P_rule_optimizer	varchar2(3);
	EXP_ID	number;
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
	lp_pa_ei_denorm_v	varchar2(50):='pa_ei_denorm_v';
	lp_ap_invoice_dist	varchar2(50):='ap_invoice_distributions';
	lp_pa_cost_xfer_audit	varchar2(50);
	C_COMPANY_NAME_HEADER	varchar2(50);
	C_employee_name	varchar2(80);
	c_no_data_found	varchar2(80);
	c_incurred_org	varchar2(32);
	FUNCTION  get_cover_page_values RETURN BOOLEAN  ;
	function BeforeReport return boolean  ;
	FUNCTION  get_company_name    RETURN BOOLEAN  ;
	function c_billable_expensesformula(c_total_expenses in number, c_total_billable_expenses in number) return number  ;
	function AfterReport return boolean  ;
	function c_display_total_bill_expformul(c_total_billable_expenses in number) return varchar2  ;
	function c_display_total_expformula(c_total_expenses in number) return varchar2  ;
	function c_display_bill_expformula(c_billable_expenses in number) return varchar2  ;
	function c_expensesformula(expenses in number) return varchar2  ;
	function c_billable_expformula(billable_expenses in number) return varchar2  ;
	function c_disp_rep_expensesformula(c_rep_expenses in number) return varchar2  ;
	function c_amountformula(amount in number) return char  ;
	function c_amount1formula(sse_amount in number) return char  ;
	function c_dis_sum_invoiceformula(c_sum_invoice in number) return char  ;
	function c_disp_sum_sseformula(c_sum_sse in number) return char  ;
	function c_dis_sum_invoice1formula(c_sum_invoice1 in number) return char  ;
	function c_disp_sum_sse1formula(c_sum_sse1 in number) return char  ;
	function c_bill_pctformula(c_sum_invoice in number, c_sum_invoice1 in number) return char  ;
	function AfterPForm return boolean  ;
	Function C_COMPANY_NAME_HEADER_p return varchar2;
	Function C_employee_name_p return varchar2;
	Function c_no_data_found_p return varchar2;
	Function c_incurred_org_p return varchar2;
END PA_PAXEXONE_XMLP_PKG;

/
