--------------------------------------------------------
--  DDL for Package PAY_PAYJPBON_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PAYJPBON_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAYJPBONS.pls 120.0 2007/12/13 11:59:26 amakrish noship $ */
	p_sort_order	varchar2(30);
	p_business_group_id	number;
	p_organization_id	number;
	p_output_flag	varchar2(30);
	p_reported_date	date;
	p_organization_context	varchar2(40);
	p_si_submit_type	number;
	p_payroll_action_id	number;
	p_bon_wp_std_prem_ele_id	number;
	p_bon_hi_std_prem_ele_id	number;
	p_bon_wp_prem_iv_id	number;
	p_bon_hi_prem_iv_id	number;
	p_payment_date	date;
	p_scheduled_payment_yyyymm	varchar2(32767);
	p_where_clause_for_assid	varchar2(150) := ' ';
	p_assignment_id1	number;
	p_assignment_id2	number;
	p_assignment_id3	number;
	p_assignment_id4	number;
	p_assignment_id5	number;
	p_assignment_id6	number;
	p_assignment_id7	number;
	p_assignment_id8	number;
	p_assignment_id9	number;
	p_assignment_id10	number;
	P_CONC_REQUEST_ID	number;
	cp_full_name	varchar2(310);
	cp_birth_date_era	varchar2(5);
	cp_d_birth_date_era	varchar2(80);
	cp_birth_date_yy	varchar2(5);
	cp_birth_date_mm	varchar2(5);
	cp_birth_date_dd	varchar2(5);
	cp_birth_date_erayymmdd	varchar2(15);
	cp_si_sex_code	varchar2(5);
	cp_bon_payment_date	date;
	cp_bon_payment_date_yy	varchar2(5);
	cp_bon_payment_date_mm	varchar2(5);
	cp_bon_payment_date_dd	varchar2(5);
	cp_bon_payment_date_yymmdd	varchar2(32767);
	cp_bon_comp	varchar2(60);
	cp_bon_mtr_comp	varchar2(60);
	cp_bon_comp_total	varchar2(60);
	cp_d_bon_comp_total	varchar2(60);
	cp_hi_only	varchar2(80);
	cp_wp_only	varchar2(80);
	cp_exclude	varchar2(80);
	cp_emp_failure_item	varchar2(2000);
	cp_error_message	varchar2(2000);
	cp_payment_date_yy	varchar2(2);
	cp_payment_date_mm	varchar2(2);
	cp_payment_date_dd	varchar2(2);
	cp_scheduled_payment_yy	varchar2(2);
	cp_scheduled_payment_mm	varchar2(2);
	cp_reported_date_yy	varchar2(2);
	cp_reported_date_mm	varchar2(2);
	cp_reported_date_dd	varchar2(2);
	cp_payment_date_yymmdd	varchar2(32767);
	cp_scheduled_payment_yymm	varchar2(32767);
	cp_reported_date_yymmdd	varchar2(32767);
	function BeforeReport return boolean  ;
	function cf_dataformula(sort_order in varchar2, si_type in number,date_of_birth in date,
	effective_date in date,
	 ASSIGNMENT_ACTION_ID in number,assignment_id in number,
	LAST_NAME in varchar2, FIRST_NAME in varchar2, ins_number in number, last_name_kana in varchar2, first_name_kana in varchar2) return number ;
	function AfterPForm return boolean  ;

	function  validate_output(
            p_qualified_date_iv_id in number,
            p_disqualified_date_iv_id in number, ASSIGNMENT_ID in number, EFFECTIVE_DATE in date) return varchar2 ;

	function AfterReport return boolean  ;
	Function cp_full_name_p return varchar2;
	Function cp_birth_date_era_p return varchar2;
	Function cp_d_birth_date_era_p return varchar2;
	Function cp_birth_date_yy_p return varchar2;
	Function cp_birth_date_mm_p return varchar2;
	Function cp_birth_date_dd_p return varchar2;
	Function cp_birth_date_erayymmdd_p return varchar2;
	Function cp_si_sex_code_p return varchar2;
	Function cp_bon_payment_date_p return date;
	Function cp_bon_payment_date_yy_p return varchar2;
	Function cp_bon_payment_date_mm_p return varchar2;
	Function cp_bon_payment_date_dd_p return varchar2;
	Function cp_bon_payment_date_yymmdd_p return varchar2;
	Function cp_bon_comp_p return varchar2;
	Function cp_bon_mtr_comp_p return varchar2;
	Function cp_bon_comp_total_p return varchar2;
	Function cp_d_bon_comp_total_p return varchar2;
	Function cp_hi_only_p return varchar2;
	Function cp_wp_only_p return varchar2;
	Function cp_exclude_p return varchar2;
	Function cp_emp_failure_item_p return varchar2;
	Function cp_error_message_p return varchar2;
	Function cp_payment_date_yy_p return varchar2;
	Function cp_payment_date_mm_p return varchar2;
	Function cp_payment_date_dd_p return varchar2;
	Function cp_scheduled_payment_yy_p return varchar2;
	Function cp_scheduled_payment_mm_p return varchar2;
	Function cp_reported_date_yy_p return varchar2;
	Function cp_reported_date_mm_p return varchar2;
	Function cp_reported_date_dd_p return varchar2;
	Function cp_payment_date_yymmdd_p return varchar2;
	Function cp_scheduled_payment_yymm_p return varchar2;
	Function cp_reported_date_yymmdd_p return varchar2;


        g_rec_cnt												number;
	g_sot														date := fnd_date.canonical_to_date('0001/01/01');
	g_eot														date := fnd_date.canonical_to_date('4712/12/31');

		g_hi_qualified_date_iv_id				number;
	g_hi_disqualified_date_iv_id		number;
	g_wp_qualified_date_iv_id				number;
	g_wp_disqualified_date_iv_id		number;
	g_wpf_qualified_date_iv_id			number;
	g_wpf_disqualified_date_iv_id		number;
		g_si_sex_iv_id									number;
									g_bon_hi_std_prem_elm_id					number;
	g_earn_sj_hi_prem_iv_id						number;
	g_earn_kind_sj_hi_prem_iv_id			number;
	g_bon_wp_std_prem_elm_id					number;
	g_earn_sj_wp_prem_iv_id						number;
	g_earn_kind_sj_wp_prem_iv_id			number;


END PAY_PAYJPBON_XMLP_PKG;

/
