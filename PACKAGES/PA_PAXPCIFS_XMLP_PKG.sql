--------------------------------------------------------
--  DDL for Package PA_PAXPCIFS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PAXPCIFS_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAXPCIFSS.pls 120.0 2008/01/02 11:42:40 krreddy noship $ */
	p_start_organization_id	number;
	CREATION_DATE_FROM	date;
	CREATION_DATE_TO	date;
	CREATION_DATE_FROM_1	varchar2(25);
	CREATION_DATE_TO_1	varchar2(25);
	PROJECT_ROLE_TYPE	varchar2(40);
	PROJECT_MEMBER	number;
	P_debug_mode	varchar2(3);
	P_CONC_REQUEST_ID	number;
	P_rule_optimizer	varchar2(3);
	C_COMPANY_NAME_HEADER	varchar2(50);
	C_start_org	varchar2(240);
	C_project_member	varchar2(240);
	C_role_type	varchar2(80);
	C_enter	varchar2(80);
	bucket1_low	number;
	bucket1_high	number;
	bucket2_low	number;
	bucket2_high	number;
	bucket3_low	number;
	bucket3_high	number;
	C_no_data_found	varchar2(80);
	C_dummy_data	number :=0; --Initialised to 0
	C_currency	varchar2(15);
	FUNCTION  get_cover_page_values   RETURN BOOLEAN  ;
	function BeforeReport return boolean  ;
	FUNCTION  get_company_name    RETURN BOOLEAN  ;
	FUNCTION get_start_org RETURN BOOLEAN  ;
	function c_amountformula(C_amount1 in number, C_amount2 in number, C_amount3 in number) return number  ;
	function c_countformula(c_count1 in number, c_count2 in number, c_count3 in number) return number  ;
	function G_project_orgGroupFilter return boolean  ;
	function AfterReport return boolean  ;
	function c_inv_amountformula(C_inv_amount1 in number, C_inv_amount2 in number, C_inv_amount3 in number) return number  ;
	function c_inv_countformula(c_inv_count1 in number, c_inv_count2 in number, c_inv_count3 in number) return number  ;
	function CF_CURRENCY_CODEFormula return VARCHAR2  ;
	Function C_COMPANY_NAME_HEADER_p return varchar2;
	Function C_start_org_p return varchar2;
	Function C_project_member_p return varchar2;
	Function C_role_type_p return varchar2;
	Function C_enter_p return varchar2;
	Function bucket1_low_p return number;
	Function bucket1_high_p return number;
	Function bucket2_low_p return number;
	Function bucket2_high_p return number;
	Function bucket3_low_p return number;
	Function bucket3_high_p return number;
	Function C_no_data_found_p return varchar2;
	Function C_dummy_data_p return number;
	Function C_currency_p return varchar2;
END PA_PAXPCIFS_XMLP_PKG;

/
