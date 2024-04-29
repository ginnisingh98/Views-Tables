--------------------------------------------------------
--  DDL for Package PA_PAXAUVIT_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PAXAUVIT_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAXAUVITS.pls 120.0 2008/01/02 11:19:41 krreddy noship $ */
	P_rule_optimizer	varchar2(3);
	P_debug_mode	varchar2(3);
	P_CONC_REQUEST_ID	number;
	P_Report_Type	varchar2(3);
	P_FROM_TRANSFER_DATE	date;
	P_TO_TRANSFER_DATE	date;
	P_FROM_GL_DATE	date;
	P_TO_GL_DATE	date;
	P_FROM_TRANSFER_DATE1	varchar2(15);
	P_TO_TRANSFER_DATE1	varchar2(15);
	P_FROM_GL_DATE1	varchar2(15);
	P_TO_GL_DATE1	varchar2(15);
	P_sob_id	number;
	P_coa_id	number;
	P_from_account	varchar2(240);
	P_TO_ACCOUNT	varchar2(240);
	C_select_clause	varchar2(2000);
	C_from_clause	varchar2(2000);
	C_where_clause	varchar2(2000);
	C_where	varchar2(2000);
	C_COMPANY_NAME_HEADER	varchar2(50);
	C_no_data_found	varchar2(80);
	C_dummy_data	number;
	C_WHERE_CC	varchar2(4000) := '1=1' ;
	QTY_PRECISION varchar2(100);
	function get_precision(qty_precision number)return varchar2 ;
	FUNCTION  get_cover_page_values   RETURN BOOLEAN  ;
	FUNCTION  get_company_name    RETURN BOOLEAN  ;
	function BeforeReport return boolean  ;
	function account_idformula(dr_code_combination_id in number) return char  ;
	function account_flex_idformula(dr_code_combination_id1 in number) return char  ;
	procedure get_precision (id IN NUMBER)  ;
	function AfterReport return boolean  ;
	Function C_COMPANY_NAME_HEADER_p return varchar2;
	Function C_no_data_found_p return varchar2;
	Function C_dummy_data_p return number;
	Function C_WHERE_CC_p return varchar2;
END PA_PAXAUVIT_XMLP_PKG;

/
