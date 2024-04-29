--------------------------------------------------------
--  DDL for Package PA_PAXEMRAO_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PAXEMRAO_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAXEMRAOS.pls 120.0 2008/01/02 11:27:09 krreddy noship $ */
	START_ORG_ID	number;
	DATE_LO	date;
	DATE_HI	date;
	CP_DATE_LO VARCHAR2(20);
	CP_DATE_HI VARCHAR2(20);
	DISPLAY_DETAIL	varchar2(40);
	P_PERSON_ID	number;
	P_debug_mode	varchar2(3);
	P_CONC_REQUEST_ID	number;
	P_rule_optimizer	varchar2(3);
	C_COMPANY_NAME_HEADER	varchar2(50);
	C_org_name	varchar2(40);
	C_employee_name	varchar2(50);
	C_no_data_found	varchar2(80);
	C_display_details	varchar2(40);
	FUNCTION  get_cover_page_values   RETURN BOOLEAN  ;
	function BeforeReport return boolean  ;
	FUNCTION  get_company_name    RETURN BOOLEAN  ;
	FUNCTION get_start_org RETURN BOOLEAN  ;
	function G_projectGroupFilter return boolean  ;
	function c_utilizationformula(total_hours in number, billable_hours in number) return number  ;
	Function cal_util return NUMBER  ;
	function c_project_utilizationformula(c_project_tot_hours in number, c_project_tot_billable in number) return number  ;
	function cal_project_util return NUMBER  ;
	function cal_org_util return NUMBER  ;
	function c_org_utilizationformula(c_org_tot_hours in number, c_org_tot_billable in number) return number  ;
	function AfterReport return boolean  ;
	Function no_data_found_func return boolean  ;
	function G_emp_detGroupFilter return boolean  ;
	function G_emp_detailGroupFilter return boolean  ;
	Function C_COMPANY_NAME_HEADER_p return varchar2;
	Function C_org_name_p return varchar2;
	Function C_employee_name_p return varchar2;
	Function C_no_data_found_p return varchar2;
	Function C_display_details_p return varchar2;
END PA_PAXEMRAO_XMLP_PKG;

/
