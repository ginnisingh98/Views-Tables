--------------------------------------------------------
--  DDL for Package Body PAY_PAYJPBON_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAYJPBON_XMLP_PKG" AS
/* $Header: PAYJPBONB.pls 120.0 2007/12/13 12:17:37 amakrish noship $ */

function BeforeReport return boolean is
	l_date							date;
	l_date_era_code			number;
	l_date_yyyy					number;
	l_date_yy						number;
	l_date_mm						number;
	l_date_dd						number;
	l_legislation_code	per_business_groups_perf.legislation_code%type;
	l_element_type_id		number;
begin
 -- hr_standard.event('BEFORE REPORT');

	g_rec_cnt := 0;


	pay_jp_report_pkg.to_era(p_payment_date,
		l_date_era_code,
		l_date_yyyy,
		l_date_mm,
		l_date_dd);
	l_date_yy := l_date_yyyy - trunc(l_date_yyyy,-2);
		cp_payment_date_yy := lpad(to_char(l_date_yy),2,'0');
	cp_payment_date_mm := lpad(to_char(l_date_mm),2,'0');
	cp_payment_date_dd := lpad(to_char(l_date_dd),2,'0');
	cp_payment_date_yymmdd := cp_payment_date_yy||'.'||cp_payment_date_mm||'.'||cp_payment_date_dd;

  l_date := to_date(p_scheduled_payment_yyyymm||'01','YYYYMMDD');
	pay_jp_report_pkg.to_era(l_date,
		l_date_era_code,
		l_date_yyyy,
		l_date_mm,
		l_date_dd);
	l_date_yy := l_date_yyyy - trunc(l_date_yyyy,-2);
		cp_scheduled_payment_yy := lpad(to_char(l_date_yy),2,'0');
	cp_scheduled_payment_mm := lpad(to_char(l_date_mm),2,'0');
	cp_scheduled_payment_yymm := cp_scheduled_payment_yy||'.'||cp_scheduled_payment_mm;

	pay_jp_report_pkg.to_era(p_reported_date,
		l_date_era_code,
		l_date_yyyy,
		l_date_mm,
		l_date_dd);
	l_date_yy := l_date_yyyy - trunc(l_date_yyyy,-2);
		cp_reported_date_yy := lpad(to_char(l_date_yy),2,'0');
	cp_reported_date_mm := lpad(to_char(l_date_mm),2,'0');
	cp_reported_date_dd := lpad(to_char(l_date_dd),2,'0');
	cp_reported_date_yymmdd := cp_reported_date_yy||'.'||cp_reported_date_mm||'.'||cp_reported_date_dd;


	l_legislation_code := pay_jp_balance_pkg.get_legislation_code(p_business_group_id);
		l_element_type_id := pay_jp_balance_pkg.get_element_type_id('COM_HI_QUALIFY_INFO',p_business_group_id,l_legislation_code);
	g_hi_qualified_date_iv_id := pay_jp_balance_pkg.get_input_value_id(l_element_type_id,'QUALIFY_DATE');
	g_hi_disqualified_date_iv_id := pay_jp_balance_pkg.get_input_value_id(l_element_type_id,'DISQUALIFY_DATE');
			l_element_type_id := pay_jp_balance_pkg.get_element_type_id('COM_WP_QUALIFY_INFO',p_business_group_id,l_legislation_code);
	g_wp_qualified_date_iv_id := pay_jp_balance_pkg.get_input_value_id(l_element_type_id,'QUALIFY_DATE');
	g_wp_disqualified_date_iv_id := pay_jp_balance_pkg.get_input_value_id(l_element_type_id,'DISQUALIFY_DATE');
			l_element_type_id := pay_jp_balance_pkg.get_element_type_id('COM_WPF_QUALIFY_INFO',p_business_group_id,l_legislation_code);
	g_wpf_qualified_date_iv_id := pay_jp_balance_pkg.get_input_value_id(l_element_type_id,'QUALIFY_DATE');
	g_wpf_disqualified_date_iv_id := pay_jp_balance_pkg.get_input_value_id(l_element_type_id,'DISQUALIFY_DATE');
			l_element_type_id := pay_jp_balance_pkg.get_element_type_id('COM_SI_INFO',p_business_group_id,l_legislation_code);
	g_si_sex_iv_id := pay_jp_balance_pkg.get_input_value_id(l_element_type_id,'SI_SEX');
        g_bon_hi_std_prem_elm_id := pay_jp_balance_pkg.get_element_type_id('BON_HI_STD_BON',p_business_group_id,l_legislation_code);
	g_earn_sj_hi_prem_iv_id := pay_jp_balance_pkg.get_input_value_id(g_bon_hi_std_prem_elm_id,'ERN_MONEY');
	g_earn_kind_sj_hi_prem_iv_id := pay_jp_balance_pkg.get_input_value_id(g_bon_hi_std_prem_elm_id,'ERN_KIND');
			g_bon_wp_std_prem_elm_id := pay_jp_balance_pkg.get_element_type_id('BON_WP_STD_BON',p_business_group_id,l_legislation_code);
	g_earn_sj_wp_prem_iv_id := pay_jp_balance_pkg.get_input_value_id(g_bon_wp_std_prem_elm_id,'ERN_MONEY');
	g_earn_kind_sj_wp_prem_iv_id := pay_jp_balance_pkg.get_input_value_id(g_bon_wp_std_prem_elm_id,'ERN_KIND');
	  return (TRUE);
end;

function cf_dataformula(sort_order in varchar2, si_type in number,date_of_birth in date,
	effective_date in date,
	 ASSIGNMENT_ACTION_ID in number,assignment_id in number,
	LAST_NAME in varchar2, FIRST_NAME in varchar2, ins_number in number, last_name_kana in varchar2, first_name_kana in varchar2) return number is
	l_date_era_code		number;
	l_date_yyyy		number;
	l_date_yy		number;
	l_date_mm		number;
	l_date_dd		number;
		l_exclude		varchar2(1);
	l_wp_only		varchar2(1);
	l_hi_only		varchar2(1);
		l_bon_comp		number;
	l_bon_mtr_comp		number;
	l_bon_comp_total	number;
		l_emp_failure_item	varchar2(100);
	l_emp_error_message	varchar2(1000);
begin
  g_rec_cnt := g_rec_cnt + 1;


			if sort_order = 'HI_NUMBER' then
		l_exclude := validate_output(g_hi_qualified_date_iv_id, g_hi_disqualified_date_iv_id,assignment_id,effective_date) ;
	else
   	if si_type = 4 then
	  	l_exclude := validate_output(g_wpf_qualified_date_iv_id, g_wpf_disqualified_date_iv_id,assignment_id,effective_date) ;
    else
		  l_exclude := validate_output(g_wp_qualified_date_iv_id,g_wp_disqualified_date_iv_id,assignment_id,effective_date) ;
    end if;
	end if;
	 	if l_exclude = 'Y' then
 		cp_exclude := hr_general.decode_lookup('YES_NO',l_exclude);
 	else
 		cp_exclude := '';
 	end if;

	pay_jp_report_pkg.to_era(date_of_birth,
		l_date_era_code,
		l_date_yyyy,
		l_date_mm,
		l_date_dd);
	l_date_yy := l_date_yyyy - trunc(l_date_yyyy,-2);
		cp_birth_date_era := lpad(to_char(l_date_era_code),2,'0');
		cp_birth_date_yy := lpad(to_char(l_date_yy),2,'0');
	cp_birth_date_mm := lpad(to_char(l_date_mm),2,'0');
	cp_birth_date_dd := lpad(to_char(l_date_dd),2,'0');
	cp_birth_date_erayymmdd := cp_birth_date_era||'.'||cp_birth_date_yy||'.'||cp_birth_date_mm||'.'||cp_birth_date_dd;

	  if trunc(effective_date,'DD') <> trunc(p_payment_date,'DD') then
  	pay_jp_report_pkg.to_era(effective_date,
	  	l_date_era_code,
		  l_date_yyyy,
		  l_date_mm,
		  l_date_dd);
	  l_date_yy := l_date_yyyy - trunc(l_date_yyyy,-2);
	  	  cp_bon_payment_date_yy := lpad(to_char(l_date_yy),2,'0');
	  cp_bon_payment_date_mm := lpad(to_char(l_date_mm),2,'0');
	  cp_bon_payment_date_dd := lpad(to_char(l_date_dd),2,'0');
	  cp_bon_payment_date_yymmdd := cp_bon_payment_date_yy||'.'||cp_bon_payment_date_mm||'.'||cp_bon_payment_date_dd;
  else
    cp_bon_payment_date_yy := null;
    cp_bon_payment_date_mm := null;
    cp_bon_payment_date_dd := null;
	  cp_bon_payment_date_yymmdd := null;
  end if;

	if sort_order = 'HI_NUMBER' then
			l_bon_comp := pay_jp_balance_pkg.get_result_value_number(g_bon_hi_std_prem_elm_id,g_earn_sj_hi_prem_iv_id,assignment_action_id);
		l_bon_mtr_comp := pay_jp_balance_pkg.get_result_value_number(g_bon_hi_std_prem_elm_id,g_earn_kind_sj_hi_prem_iv_id,assignment_action_id);
	else
		l_bon_comp := pay_jp_balance_pkg.get_result_value_number(g_bon_wp_std_prem_elm_id,g_earn_sj_wp_prem_iv_id,assignment_action_id);
		l_bon_mtr_comp := pay_jp_balance_pkg.get_result_value_number(g_bon_wp_std_prem_elm_id,g_earn_kind_sj_wp_prem_iv_id,assignment_action_id);
	end if;
	cp_bon_comp := to_char(l_bon_comp);
	cp_bon_mtr_comp := to_char(l_bon_mtr_comp);

	l_bon_comp_total := nvl(l_bon_comp,0) + nvl(l_bon_mtr_comp,0);
	cp_bon_comp_total := to_char(l_bon_comp_total);
  if l_bon_comp_total < 10000000 then
  	cp_d_bon_comp_total := lpad(to_char(floor(l_bon_comp_total/1000)),4,'0');
  else
  	cp_d_bon_comp_total := to_char(floor(l_bon_comp_total/1000));
  end if;

		cp_si_sex_code := pay_jp_balance_pkg.get_entry_value_char(g_si_sex_iv_id,assignment_id,effective_date);

	cp_full_name := last_name||' '||first_name;


				cp_emp_failure_item := l_emp_failure_item;
	cp_error_message := l_emp_error_message;
  return('');
end;

function AfterPForm return boolean is
		l_where_clause_for_assid	varchar2(150);
	l_legislation_code				per_business_groups_perf.legislation_code%type;
	begin
				l_legislation_code := pay_jp_balance_pkg.get_legislation_code(p_business_group_id);

		l_where_clause_for_assid := pay_jp_report_pkg.get_concatenated_numbers(
						to_number(p_assignment_id1),
						to_number(p_assignment_id2),
						to_number(p_assignment_id3),
						to_number(p_assignment_id4),
						to_number(p_assignment_id5),
						to_number(p_assignment_id6),
						to_number(p_assignment_id7),
						to_number(p_assignment_id8),
						to_number(p_assignment_id9),
						to_number(p_assignment_id10));
		if l_where_clause_for_assid is not NULL then
		p_where_clause_for_assid := 'and pjsbp.assignment_id in (' || l_where_clause_for_assid || ')';
	end if;
	  return (TRUE);
end;

function  validate_output(p_qualified_date_iv_id in number, p_disqualified_date_iv_id in number, ASSIGNMENT_ID in number, EFFECTIVE_DATE in date) return varchar2 is
	l_exclude varchar2(1) := 'N';
	l_qualified_date date;
	l_disqualified_date date;

	begin

        l_qualified_date := pay_jp_balance_pkg.get_entry_value_date(p_qualified_date_iv_id,assignment_id,effective_date);
  	l_disqualified_date := pay_jp_balance_pkg.get_entry_value_date(p_disqualified_date_iv_id,assignment_id,effective_date);

	if l_qualified_date is null then
  	 if l_disqualified_date is null then
  	 l_qualified_date := g_eot;
  	 l_disqualified_date := g_sot;
  	 else
  	 l_qualified_date := g_eot;
        end if;
  	else
  	if l_disqualified_date is null then
  	l_disqualified_date := g_eot;
  	end if;
  	end if;
	if effective_date < l_qualified_date then
  	l_exclude := 'Y';
  	else
  	if trunc(l_disqualified_date,'MM') <= effective_date then
  	if effective_date <= last_day(l_qualified_date) then
  	null;
  	else
  	l_exclude := 'Y';
  	end if;
  	end if;
  	end if;
	return l_exclude;
end validate_output;

/*(
            p_disqualified_date_iv_id,
            p_qualified_date_iv_id,assignment_id,effective_date)*/

function AfterReport return boolean is
begin
--  hr_standard.event('AFTER REPORT');
  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function cp_full_name_p return varchar2 is
	Begin
	 return cp_full_name;
	 END;
 Function cp_birth_date_era_p return varchar2 is
	Begin
	 return cp_birth_date_era;
	 END;
 Function cp_d_birth_date_era_p return varchar2 is
	Begin
	 return cp_d_birth_date_era;
	 END;
 Function cp_birth_date_yy_p return varchar2 is
	Begin
	 return cp_birth_date_yy;
	 END;
 Function cp_birth_date_mm_p return varchar2 is
	Begin
	 return cp_birth_date_mm;
	 END;
 Function cp_birth_date_dd_p return varchar2 is
	Begin
	 return cp_birth_date_dd;
	 END;
 Function cp_birth_date_erayymmdd_p return varchar2 is
	Begin
	 return cp_birth_date_erayymmdd;
	 END;
 Function cp_si_sex_code_p return varchar2 is
	Begin
	 return cp_si_sex_code;
	 END;
 Function cp_bon_payment_date_p return date is
	Begin
	 return cp_bon_payment_date;
	 END;
 Function cp_bon_payment_date_yy_p return varchar2 is
	Begin
	 return cp_bon_payment_date_yy;
	 END;
 Function cp_bon_payment_date_mm_p return varchar2 is
	Begin
	 return cp_bon_payment_date_mm;
	 END;
 Function cp_bon_payment_date_dd_p return varchar2 is
	Begin
	 return cp_bon_payment_date_dd;
	 END;
 Function cp_bon_payment_date_yymmdd_p return varchar2 is
	Begin
	 return cp_bon_payment_date_yymmdd;
	 END;
 Function cp_bon_comp_p return varchar2 is
	Begin
	 return cp_bon_comp;
	 END;
 Function cp_bon_mtr_comp_p return varchar2 is
	Begin
	 return cp_bon_mtr_comp;
	 END;
 Function cp_bon_comp_total_p return varchar2 is
	Begin
	 return cp_bon_comp_total;
	 END;
 Function cp_d_bon_comp_total_p return varchar2 is
	Begin
	 return cp_d_bon_comp_total;
	 END;
 Function cp_hi_only_p return varchar2 is
	Begin
	 return cp_hi_only;
	 END;
 Function cp_wp_only_p return varchar2 is
	Begin
	 return cp_wp_only;
	 END;
 Function cp_exclude_p return varchar2 is
	Begin
	 return cp_exclude;
	 END;
 Function cp_emp_failure_item_p return varchar2 is
	Begin
	 return cp_emp_failure_item;
	 END;
 Function cp_error_message_p return varchar2 is
	Begin
	 return cp_error_message;
	 END;
 Function cp_payment_date_yy_p return varchar2 is
	Begin
	 return cp_payment_date_yy;
	 END;
 Function cp_payment_date_mm_p return varchar2 is
	Begin
	 return cp_payment_date_mm;
	 END;
 Function cp_payment_date_dd_p return varchar2 is
	Begin
	 return cp_payment_date_dd;
	 END;
 Function cp_scheduled_payment_yy_p return varchar2 is
	Begin
	 return cp_scheduled_payment_yy;
	 END;
 Function cp_scheduled_payment_mm_p return varchar2 is
	Begin
	 return cp_scheduled_payment_mm;
	 END;
 Function cp_reported_date_yy_p return varchar2 is
	Begin
	 return cp_reported_date_yy;
	 END;
 Function cp_reported_date_mm_p return varchar2 is
	Begin
	 return cp_reported_date_mm;
	 END;
 Function cp_reported_date_dd_p return varchar2 is
	Begin
	 return cp_reported_date_dd;
	 END;
 Function cp_payment_date_yymmdd_p return varchar2 is
	Begin
	 return cp_payment_date_yymmdd;
	 END;
 Function cp_scheduled_payment_yymm_p return varchar2 is
	Begin
	 return cp_scheduled_payment_yymm;
	 END;
 Function cp_reported_date_yymmdd_p return varchar2 is
	Begin
	 return cp_reported_date_yymmdd;
	 END;
END PAY_PAYJPBON_XMLP_PKG ;

/
