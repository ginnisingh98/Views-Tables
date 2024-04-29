--------------------------------------------------------
--  DDL for Package PA_PAXPRWBS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PAXPRWBS_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAXPRWBSS.pls 120.0 2008/01/02 11:53:14 krreddy noship $ */
	TOP_TASK_ID	varchar2(17);
	PROJ	number;
	P_CONC_REQUEST_ID	number;
	P_debug_mode	varchar2(3);
	P_rule_optimizer	varchar2(3);
	C_COMPANY_NAME_HEADER	varchar2(50);
	c_no_data_found	varchar2(80);
	C_top_task_number	varchar2(40);
	C_top_task_name	varchar2(40);
	C_project_number	varchar2(40);
	c_project_name	varchar2(40);
	TOP_TASK_ID1 varchar2(17);
	FUNCTION  get_cover_page_values   RETURN BOOLEAN  ;
	function BeforeReport return boolean  ;
	FUNCTION  get_company_name    RETURN BOOLEAN  ;
	FUNCTION NO_DATA_FOUND_FUNC RETURN BOOLEAN  ;
	function AfterReport return boolean  ;
	Function C_COMPANY_NAME_HEADER_p return varchar2;
	Function c_no_data_found_p return varchar2;
	Function C_top_task_number_p return varchar2;
	Function C_top_task_name_p return varchar2;
	Function C_project_number_p return varchar2;
	Function c_project_name_p return varchar2;
END PA_PAXPRWBS_XMLP_PKG;

/
