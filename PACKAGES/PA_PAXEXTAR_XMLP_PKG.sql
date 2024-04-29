--------------------------------------------------------
--  DDL for Package PA_PAXEXTAR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PAXEXTAR_XMLP_PKG" AUTHID CURRENT_USER AS
  /* $Header: PAXEXTARS.pls 120.0 2008/01/02 11:32:27 krreddy noship $ */
	PROJECT	number;
	TASK	number;
	EXP_TYPE	varchar2(40);
	EMPLOYEE	number;
	P_CONC_REQUEST_ID	number;
	P_debug_mode	varchar2(3);
	P_rule_optimizer	varchar2(3);
	C_COMPANY_NAME_HEADER	varchar2(50);
	c_no_data_found	varchar2(80);
	C_project_name	varchar2(30);
	C_project_num	varchar2(25);
	C_task_name	varchar2(30);
	C_task_num	varchar2(25);
	FUNCTION  get_cover_page_values   RETURN BOOLEAN  ;
	function BeforeReport return boolean  ;
	FUNCTION  get_company_name    RETURN BOOLEAN  ;
	FUNCTION NO_DATA_FOUND_FUNC RETURN BOOLEAN  ;
	function  get_task(
	      t_id  number )return varchar2  ;
	function c_taskformula(t_id in number) return varchar2  ;
	function AfterReport return boolean  ;
	function get_project(
              t_id   NUMBER , level in number) return varchar2 ;
	function c_projectformula(t_id in number,level in number) return varchar2 ;
	function CF_ACCT_CURRENCY_CODEFormula return Varchar2  ;
	Function C_COMPANY_NAME_HEADER_p return varchar2;
	Function c_no_data_found_p return varchar2;
	Function C_project_name_p return varchar2;
	Function C_project_num_p return varchar2;
	Function C_task_name_p return varchar2;
	Function C_task_num_p return varchar2;
END PA_PAXEXTAR_XMLP_PKG;

/
