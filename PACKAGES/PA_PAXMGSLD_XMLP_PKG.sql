--------------------------------------------------------
--  DDL for Package PA_PAXMGSLD_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PAXMGSLD_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAXMGSLDS.pls 120.2 2008/01/03 12:13:57 krreddy noship $ */
	P_rule_optimizer	varchar2(3);
	P_debug_mode	varchar2(3);
	P_CONC_REQUEST_ID	number;
	P_TO_GL_DATE	date;
	P_FROM_GL_DATE	date;
	P_FROM_PROJECT	varchar2(100);
	P_FROM_TASK	varchar2(100);
	P_TO_TASK	varchar2(100);
	P_TO_PROJECT	varchar2(100);
	P_EXP_TYPE	varchar2(100);
	P_SORT_TYPE	varchar2(1);
	P_COA_ID	number:=101;
	P_PROJECT_ID	number;
	P_FROM_ACCOUNT	varchar2(1000);
	P_TO_ACCOUNT	varchar2(1000);
	p_ca_set_of_books_id	number;
	C_COMPANY_NAME_HEADER	varchar2(50);
	C_no_data_found	varchar2(80);
	C_dummy_data	number;
	C_where	varchar2(4000) := '''1''=''1''' ;
       	C_FLEXDATA2	varchar2(2000);
	C_FLEXDATA1	varchar2(2000);
	CP_from_date_1 varchar2(30);
	CP_to_date_1 varchar2(30);
	FUNCTION  get_cover_page_values   RETURN BOOLEAN  ;
	function BeforeReport return boolean  ;
	FUNCTION  get_company_name    RETURN BOOLEAN  ;
	function cf_account_idformula(code_combination_id in number) return varchar2  ;
	function cf_account_id1formula(code_combination_id1 in number) return varchar2  ;
	function CP_from_dateFormula return Date  ;
	function CP_to_dateFormula return Date  ;
	function CF_CURR_CODEFormula return VARCHAR2  ;
	function AfterReport return boolean  ;
	function AfterPForm return boolean  ;
	Function C_COMPANY_NAME_HEADER_p return varchar2;
	Function C_no_data_found_p return varchar2;
	Function C_dummy_data_p return number;
	Function C_where_p return varchar2;
	Function C_FLEXDATA2_p return varchar2;
	Function C_FLEXDATA1_p return varchar2;
END PA_PAXMGSLD_XMLP_PKG;

/
