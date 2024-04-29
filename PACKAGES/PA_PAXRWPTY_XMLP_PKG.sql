--------------------------------------------------------
--  DDL for Package PA_PAXRWPTY_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PAXRWPTY_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAXRWPTYS.pls 120.0 2008/01/02 12:14:35 krreddy noship $ */
	PROJECT_TYPE	varchar2(40);
	P_costing	varchar2(3);
	P_CONC_REQUEST_ID	number;
	C_Company_Name_Header	varchar2(40);
	C_no_data_found	varchar2(132);
	FUNCTION  get_company_name    RETURN BOOLEAN  ;
	function BeforeReport return boolean  ;
	Function NO_DATA_FOUND_FUNC RETURN BOOLEAN  ;
	function c_desc1formula(cbemc in varchar2) return varchar2  ;
	Function get_budget_code_desc (code in VARCHAR2) return VARCHAR2  ;
	function c_desc2formula(rbemc in varchar2) return varchar2  ;
	function get_resource_name (list_id number) return VARCHAR2  ;
	function c_desc3formula(cbrld in number) return varchar2  ;
	function c_desc4formula(rbrld in number) return varchar2  ;
	function c_desc5formula(drli in number) return varchar2  ;
	function get_meaning (type in VARCHAR2,code in VARCHAR2) return VARCHAR2  ;
	function c_desc6formula(ptcc in varchar2) return varchar2  ;
	function c_desc7formula(cctc in varchar2) return varchar2  ;
	function c_desc8formula(cgmc in varchar2) return varchar2  ;
	function c_desc9formula(icaf in varchar2) return varchar2  ;
	function cf_dest_project_idformula(burden_sum_dest_project_id in number) return varchar2  ;
	function cf_dest_task_nameformula(burden_sum_dest_task_id in number) return varchar2  ;
	function cf_burden_acc_flagformula(burden_account_flag in varchar2) return varchar2  ;
	function cf_bur_amt_disp_methformula(burden_amt_display_method in varchar2) return varchar2  ;
	function CF_CURRENCY_CODEFormula return Char  ;
	function AfterReport return boolean  ;
	function cf_baseline_fiunding_flagformu(baseline_funding_flag in varchar2) return char  ;
	function cf_revaluate_funding_flagformu(revaluate_funding_flag in varchar2) return char  ;
	function cf_include_gains_losses_flagfo(include_gains_losses_flag in varchar2) return char  ;
	Function C_Company_Name_Header_p return varchar2;
	Function C_no_data_found_p return varchar2;
END PA_PAXRWPTY_XMLP_PKG;

/
