--------------------------------------------------------
--  DDL for Package PA_PAXINGEN_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PAXINGEN_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAXINGENS.pls 120.0.12010000.3 2008/12/12 09:28:24 dbudhwar ship $ */
	p_start_organization_id	number;
	PROJECT_ROLE_TYPE	varchar2(40);
	PROJECT_MEMBER	number;
	BILL_THRU_DATE	varchar2(40);
	PROJECT_ID	number;
	/* added for bug 7115649 */
	from_project_number varchar2(40);
	to_project_number varchar2(40);
	project_status varchar2(40);
	project_closed_after date;
	/* added for bug 7115649 */
	INVOICE_STATUS	varchar2(40);
	DRAFT_INVOICE	number;
	DISPLAY_UNBILLED_ITEMS	varchar2(40);
	DISPLAY_DETAILS	varchar2(40);
	P_CONC_REQUEST_ID	number;
	P_debug_mode	varchar2(3);
	P_rule_optimizer	varchar2(3);
	P_MIN_PRECISION	number;
	C_ubr_uer_label	varchar2(85);
	C_COMPANY_NAME_HEADER	varchar2(50);
	C_start_org	varchar2(40);
	C_project_member	varchar2(40);
	C_role_type	varchar2(40);
	C_enter	varchar2(80);
	C_invoice_status	varchar2(30);
	C_project_status  varchar2(130);   /* added for bug 7115649 */
	C_pca_date date;                  /* added for bug 7115649 */
	C_project_num	varchar2(30);
	C_project_name	varchar2(30);
	C_display_details	varchar2(30);
	C_display_unbilled	varchar2(30);
	C_draft_invoice	varchar2(30);
	FUNCTION  get_cover_page_values   RETURN BOOLEAN  ;
	function BeforeReport return boolean  ;
	FUNCTION  get_company_name    RETURN BOOLEAN  ;
	FUNCTION get_start_org RETURN BOOLEAN  ;
	function G_project_hdrGroupFilter return boolean  ;
	function g_item_infogroupfilter(invoice_amount in number) return boolean  ;
	function g_item_detailsgroupfilter(bill_amount in number) return boolean  ;
	function g_unbilled_detailsgroupfilter(items_unbilled in number) return boolean  ;
	function g_unbilled_eventsgroupfilter(event_amount_unbilled in number) return boolean  ;
	function g_invoicegroupfilter(invoice_amount in number) return boolean  ;
	function g_unbilled_infogroupfilter(items_unbilled in number, event_amount_unbilled in number) return boolean  ;
	function AfterReport return boolean  ;
	function CF_CURENCY_CODEFormula return VARCHAR2  ;
	function cf_cc_proj_labelformula(cc_project_number in varchar2) return char  ;
	function g_retn_invoicegroupfilter(retention_invoice in varchar2) return boolean  ;
	function c_invproc_curr_typeformula(invproc_currency_type in varchar2) return char  ;
	function c_credit_memo_reasonformula(credit_memo_reason_code in varchar2, invoice_date in date) return char  ;
	function c_ubr_uerformula(unbilled_receivable in number) return number  ;
	Function C_ubr_uer_label_p return varchar2;
	Function C_COMPANY_NAME_HEADER_p return varchar2;
	Function C_start_org_p return varchar2;
	Function C_project_member_p return varchar2;
	Function C_role_type_p return varchar2;
	Function C_enter_p return varchar2;
	Function C_invoice_status_p return varchar2;
	Function C_project_status_p return varchar2;     /* added for bug 7115649 */
	Function C_pca_date_p return date;  	   /* added for bug 7115649 */
	Function C_project_num_p return varchar2;
	Function C_project_name_p return varchar2;
	Function C_display_details_p return varchar2;
	Function C_display_unbilled_p return varchar2;
	Function C_draft_invoice_p return varchar2;
	function CF_PROJECT_CURRENCYFormula(project_id2 number) return VARCHAR2;
END PA_PAXINGEN_XMLP_PKG;

/
