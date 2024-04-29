--------------------------------------------------------
--  DDL for Package PA_PAXEXCPD_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PAXEXCPD_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAXEXCPDS.pls 120.1 2008/01/03 11:13:45 krreddy noship $ */
	P_rule_optimizer	varchar2(3);
	P_debug_mode	varchar2(3);
	P_CONC_REQUEST_ID	number;
	Start_Date	date;
	End_Date	date;
	Exception_Type	varchar2(40);
	P_Exception_Reason	varchar2(2000);
	across_ous	varchar2(2);
	calling_mode	varchar2(32767);
	START_PERIOD	varchar2(30);
	END_PERIOD	varchar2(30);
	ORG_ID1	number;
	PA_NEW_GL_DATE	varchar2(40);
	C_COMPANY_NAME_HEADER	varchar2(50);
	C_no_data_found	varchar2(80);
	C_dummy_data	number;
	CP_OU_Name	varchar2(60);
	FUNCTION  get_cover_page_values   RETURN BOOLEAN  ;
	function BeforeReport return boolean  ;
	FUNCTION  get_company_name    RETURN BOOLEAN  ;
	FUNCTION  get_exception_type  RETURN BOOLEAN  ;
	function CF_acct_curr_codeFormula return VARCHAR2  ;
	function AfterReport return boolean  ;
	FUNCTION get_ou_name RETURN boolean  ;
	function cf_inv_ou_nameformula(inv_org_id in number) return char  ;
	function cf_cst_ou_nameformula(cst_org_id in number) return char  ;
	function cf_mfg_ou_nameformula(org_id_pmg in number) return char  ;
	function cf_rev_ou_nameformula(rev_org_id in number) return char  ;
	function cf_cc_ou_nameformula(cc_org_id in number) return char  ;
	function cf_mrc_ou_nameformula(mrc_org_id in number) return char  ;
	FUNCTION get_ou_name1 RETURN varchar2  ;
	function cf_uncst_sob_nameformula(uncst_sob in number) return char  ;
	function cf_rec_book_nameformula(receipt_books in number) return char  ;
	function cf_project_numformula(project_id in number) return varchar2  ;
	function cf_task_numformula(task_id in number) return varchar2  ;
	Function C_COMPANY_NAME_HEADER_p return varchar2;
	Function C_no_data_found_p return varchar2;
	Function C_dummy_data_p return number;
	Function CP_OU_Name_p return varchar2;
END PA_PAXEXCPD_XMLP_PKG;

/
