--------------------------------------------------------
--  DDL for Package PA_PACRCBDT_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PACRCBDT_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PACRCBDTS.pls 120.0 2008/01/02 10:57:52 krreddy noship $ */
	P_PROJECT_ID	number;
	P_PROJECT_TYPE	varchar2(32767);
	P_EVENT_PERIOD	varchar2(40);
	P_ORG_ID	varchar2(40);
	P_CLASS_CATEGORY	varchar2(30);
	P_CLASS_CODE	varchar2(40);
	P_DEBUG_MODE	varchar2(3);
	P_SHOW_DETAIL	varchar2(1);
	P_CONC_REQUEST_ID	number;
	P_PROJECT_NUMBER	varchar2(25);
	p_project_number_parameter varchar2(25);
	P_ORG_NAME	varchar2(200);
	CP_line_type	varchar2(1);
	CP_capital_cost_type_flag	varchar2(1);
	cp_company_name	varchar2(100);
	function cf_total_costformula(p_project_id in number, capital_event_id in number) return number  ;
	function cf_project_setupformula(project_id in number) return char  ;
	function cf_locationformula(location_id in number) return char  ;
	function cf_categoryformula(asset_category_id in number) return char  ;
	FUNCTION  get_company_name    RETURN BOOLEAN  ;
	function BeforeReport return boolean  ;
	function CF_currency_CodeFormula return Char  ;
	function AfterReport return boolean  ;
	function project_asset_type_dispformula(project_asset_type in varchar2) return char  ;
	function event_type_dspformula(event_type in varchar2) return char  ;
	function organization_dspformula(CARRYING_OUT_ORGANIZATION_ID in number) return char  ;
    function b_capital_event_number1formatt(capital_event_id in number) return boolean  ;
	function b_project_type3formattrigger(no_rec in number) return boolean  ;
	function b_sumcurrent_asset_costpercap2(sumcurrent_asset_costperasset in number) return boolean  ;
	function b_8formattrigger(capital_event_id in number) return boolean  ;
	function b_9formattrigger(capital_event_id in number) return boolean  ;
	Function CP_line_type_p return varchar2;
	Function CP_capital_cost_type_flag_p return varchar2;
	Function cp_company_name_p return varchar2;
	Function p_project_number_parameter_p return varchar2;
END PA_PACRCBDT_XMLP_PKG;

/
