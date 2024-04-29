--------------------------------------------------------
--  DDL for Package PSP_PSPRCPGD_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_PSPRCPGD_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PSPRCPGDS.pls 120.4 2007/10/29 07:27:38 amakrish noship $ */
	P_source_code	varchar2(30);
	P_SOURCE_CODE_1	varchar2(30);
	P_source_type	varchar2(1);
	P_time_period_id	number;
	P_batch_name	varchar2(30);
	P_BATCH_NAME_1	varchar2(30);
	P_CONC_REQUEST_ID	number;
	P_payroll_id	number;
	P_START_DATE	date;
	P_SET_OF_BOOKS_ID	number;
	CP_suspense	varchar2(500);
	CP_credit_amount_pgdl	number;
--	function cf_assignment_numberformula(assignment_id in number) return varchar2  ;
        function cf_assignment_numberformula(v_assignment_id in number) return varchar2;
--	function cf_person_nameformula(person_id in number) return varchar2  ;
        function cf_person_nameformula(v_person_id in number) return varchar2;
	function AfterPForm return boolean  ;
	function cf_mismatch_eltformula(cf_amt_dl_d in number, sl_debit_amount in number, cf_amt_sl_c in number) return varchar2  ;
	function cf_mismatch_assgformula(sum_dl_d_assg in number, sum_sl_d_assg in number, sum_dl_c_assg in number, sum_sl_c_assg in number) return varchar2  ;
	function cf_mismatch_personformula(sum_dl_d_person in number, sum_sl_d_person in number, sum_dl_c_person in number, sum_sl_c_person in number) return varchar2  ;
	function cf_mismatch_reportformula(sum_dl_d_total in number, sum_sl_d_total in number, sum_dl_c_total in number, sum_sl_c_total in number) return varchar2  ;
	function cf_amt_sl_cformula(gl_code_combination_id in number, sl_credit_amount in number) return number  ;
	--function cf_amt_dl_dformula(gl_code_combination_id in number) return number  ;
        function cf_amt_dl_dformula(v_person_id in number, v_assignment_id in number, v_gl_code_combination_id in number, v_project_id in number, v_task_id in number, v_award_id in number,
        v_expenditure_type in varchar2, v_expenditure_organization_id in number) return number;
	function CF_org_reportFormula return VARCHAR2  ;
	function BeforeReport return boolean  ;
	function CF_source_typeFormula return VARCHAR2  ;
	function CF_time_periodFormula return VARCHAR2  ;
--	function cf_charging_instructionsformu(project_id in number, task_id in number, award_id in number, expenditure_organization_id in number, gl_code_combination_id in number) return char  ;
        function cf_charging_instructionsformu(v_project_id in number, v_task_id in number, v_award_id in number, v_expenditure_organization_id in number, v_gl_code_combination_id in number, v_expenditure_type in varchar2) return char;
	function cf_currency_codeformula(currency_code in varchar2) return char  ;
	function cf_currency_formatformula(currency_code in varchar2) return char  ;
	function cf_sum_sl_d_total_dspformula(cs_sum_sl_d_total in number, cf_currency_format in varchar2) return char  ;
	function cf_sum_sl_c_total_dspformula(cs_sum_sl_c_total in number, cf_currency_format in varchar2) return char  ;
	function cf_sum_dl_d_total_dspformula(cs_sum_dl_d_total in number, cf_currency_format in varchar2) return char  ;
	function cf_sum_dl_c_total_dspformula(cs_sum_dl_c_total in number, cf_currency_format in varchar2) return char  ;
	function cf_mismatch_currency_totalform(cs_sum_dl_d_total in number, cs_sum_sl_d_total in number, cs_sum_dl_c_total in number, cs_sum_sl_c_total in number) return char  ;
	function cf_sum_sl_d_person_dspformula(sum_sl_d_person in number, cf_currency_format in varchar2) return char  ;
	function cf_sum_sl_c_person_dspformula(sum_sl_c_person in number, cf_currency_format in varchar2) return char  ;
	function cf_sum_dl_d_person_dspformula(sum_dl_d_person in number, cf_currency_format in varchar2) return char  ;
	function cf_sum_dl_c_person_dspformula(sum_dl_c_person in number, cf_currency_format in varchar2) return char  ;
	function cf_sum_sl_d_assg_dspformula(sum_sl_d_assg in number, cf_currency_format in varchar2) return char  ;
	function cf_sum_sl_c_assg_dspformula(sum_sl_c_assg in number, cf_currency_format in varchar2) return char  ;
	function cf_sum_dl_d_assg_dspformula(sum_dl_d_assg in number, cf_currency_format in varchar2) return char  ;
	function cf_sum_dl_c_assg_dspformula(sum_dl_c_assg in number, cf_currency_format in varchar2) return char  ;
	function cf_amt_dl_d_dspformula(cf_amt_dl_d in number, cf_currency_format in varchar2) return char  ;
	function cf_sl_debit_amount_dspformula(sl_debit_amount in number, cf_currency_format in varchar2) return char  ;
	function cf_amt_sl_c_dspformula(cf_amt_sl_c in number, cf_currency_format in varchar2) return char  ;
	function cf_credit_amount_pgdl_dspformu(cf_currency_format in varchar2) return char  ;
	function AfterReport return boolean  ;
	Function CP_suspense_p return varchar2;
	Function CP_credit_amount_pgdl_p return number;
END PSP_PSPRCPGD_XMLP_PKG;

/
