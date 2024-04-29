--------------------------------------------------------
--  DDL for Package PSP_PSPRCLSL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_PSPRCLSL_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PSPRCLSLS.pls 120.4 2007/10/29 07:27:21 amakrish noship $ */
	P_source_code	varchar2(30);
	P_source_type	varchar2(1);
	P_time_period_id	number;
	P_batch_name	varchar2(30);
	P_CONC_REQUEST_ID	number;
	P_payroll_id	number;
	P_start_date	date;
	CP_credit_amount_sl	number;
	function cf_assignment_numberformula(assignment_id_1 in number) return varchar2  ;
	function CF_element_nameFormula return VARCHAR2  ;
	function cf_person_nameformula(person_id_1 in number) return varchar2  ;
	function cf_amt_sl_dformula(person_id_1 in number, assignment_id_1 in number, element_type_id_1 in number, currency_code_1 in varchar2) return number  ;
	function AfterPForm return boolean  ;
	function cf_mismatch_eltformula(l_debit_amount in number, cf_amt_sl_d in number, l_credit_amount in number) return varchar2  ;
	function cf_mismatch_assgformula(sum_l_d_assg in number, sum_sl_d_assg in number, sum_l_c_assg in number, sum_sl_c_assg in number) return varchar2  ;
	function cf_mismatch_personformula(sum_l_d_person in number, sum_sl_d_person in number, sum_l_c_person in number, sum_sl_c_person in number) return varchar2  ;
	function cf_mismatch_reportformula(sum_l_d_total in number, sum_sl_d_total in number, sum_l_c_total in number, sum_sl_c_total in number) return varchar2  ;
	function CF_amt_sl_cFormula return Number  ;
	function CF_amt_l_cFormula return Number  ;
	function CF_amt_l_dFormula return Number  ;
	function CF_orgFormula return VARCHAR2  ;
	function CF_source_typeFormula return VARCHAR2  ;
	function CF_time_periodFormula return VARCHAR2  ;
	function BeforeReport return boolean  ;
	function cf_currency_formatformula(currency_code in varchar2) return char  ;
	function cf_currency_codeformula(currency_code in varchar2) return char  ;
	function cf_l_debit_amount_dspformula(l_debit_amount in number, cf_currency_format in varchar2) return char  ;
	function cf_l_credit_amount_dspformula(l_credit_amount in number, cf_currency_format in varchar2) return char  ;
	function cf_mismatch_currencyformula(cs_sum_l_d_total in number, cs_sum_sl_d_total in number, cs_sum_l_c_total in number, cs_sum_sl_c_total in number) return char  ;
	function CP_credit_amount_slFormula return Number  ;
	function cf_amt_sl_d_dspformula(cf_amt_sl_d in number, cf_currency_format in varchar2) return char  ;
	function cf_credit_amount_sl_dspformula(cf_currency_format in varchar2) return char  ;
	function cf_sum_l_d_assg_dspformula(sum_l_d_assg in number, cf_currency_format in varchar2) return char  ;
	function cf_sum_l_c_assg_dspformula(sum_l_c_assg in number, cf_currency_format in varchar2) return char  ;
	function cf_sum_sl_d_assg_dspformula(sum_sl_d_assg in number, cf_currency_format in varchar2) return char  ;
	function cf_sum_sl_c_assg_dspformula(sum_sl_c_assg in number, cf_currency_format in varchar2) return char  ;
	function cf_sum_l_d_person_dspformula(sum_l_d_person in number, cf_currency_format in varchar2) return char  ;
	function cf_sum_l_c_person_dspformula(sum_l_c_person in number, cf_currency_format in varchar2) return char  ;
	function cf_sum_sl_d_person_dspformula(sum_sl_d_person in number, cf_currency_format in varchar2) return char  ;
	function cf_sum_sl_c_person_dspformula(sum_sl_c_person in number, cf_currency_format in varchar2) return char  ;
	function cf_sum_l_d_total_dspformula(cs_sum_l_d_total in number, cf_currency_format in varchar2) return char  ;
	function cf_sum_sl_d_total_dspformula(cs_sum_sl_d_total in number, cf_currency_format in varchar2) return char  ;
	function cf_sum_sl_c_total_dspformula(cs_sum_sl_c_total in number, cf_currency_format in varchar2) return char  ;
	function cf_sum_l_c_total_dspformula(cs_sum_l_c_total in number, cf_currency_format in varchar2) return char  ;
	function AfterReport return boolean  ;
	Function CP_credit_amount_sl_p return number;
END PSP_PSPRCLSL_XMLP_PKG;

/
