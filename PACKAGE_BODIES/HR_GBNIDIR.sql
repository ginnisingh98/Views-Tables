--------------------------------------------------------
--  DDL for Package Body HR_GBNIDIR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_GBNIDIR" as
/* $Header: pygbnicd.pkb 120.2.12010000.5 2010/03/26 07:06:30 pbalu ship $ */
--------------------------------------------------------------------------------
--
g_defined_director_set boolean := FALSE;
g_defined_ptd_set boolean := FALSE;
g_assignment_id number;
g_effective_date date;
g_catpen varchar2(80);
g_assignment_action_id number;
g_statutory_period_start_date date;
g_ni_element_type_id number;
g_cat_input_id number;
g_pen_input_id number;
g_comp_min_ees number;
g_comp_min_ers number;
g_ni_a_employee number;
g_ni_b_employee number;
g_ni_c_employee number;
g_ni_d_employee number;
g_ni_e_employee number;
g_ni_f_employee number;
g_ni_g_employee number;
g_ni_j_employee number;
g_ni_l_employee number;
g_ni_l_employee_not number;
g_ni_s_employee number;
g_ni_s_employee_not number;
g_ni_a_employer number;
g_ni_b_employer number;
g_ni_c_employer number;
g_ni_d_employer number;
g_ni_e_employer number;
g_ni_f_employer number;
g_ni_g_employer number;
g_ni_j_employer number;
g_ni_l_employer number;
g_ni_s_employer number;
g_ni_a_able number;
g_ni_b_able number;
g_ni_c_able number;
g_ni_co_able number;
g_ni_d_able number;
g_ni_e_able number;
g_ni_f_able number;
g_ni_g_able number;
g_ni_j_able number;
g_ni_l_able number;
g_ni_s_able number;
g_ni_c_co_able number;
g_ni_d_co_able number;
g_ni_e_co_able number;
g_ni_f_co_able number;
g_ni_g_co_able number;
g_ni_s_co_able number;
g_ni_c_co number;
g_ni_d_co number;
g_ni_e_co number;
g_ni_f_co number;
g_ni_g_co number;
g_ni_s_co number;
g_ni_able_id number;
g_ni_a_able_lel number;
g_ni_a_able_uap number;  --EOY 08/09
g_ni_a_able_uel number;
g_ni_a_able_et number;
g_ni_a_able_auel number;
g_ni_a_ee_auel number;
g_ni_b_able_lel number;
g_ni_b_able_uap number;  --EOY 08/09
g_ni_b_able_uel number;
g_ni_b_able_et number;
g_ni_b_able_auel number;
g_ni_b_ee_auel number;
g_ni_c_able_lel number;
g_ni_c_able_uap number;  --EOY 08/09
g_ni_c_able_uel number;
g_ni_c_able_et number;
g_ni_c_able_auel number;
g_ni_c_ee_auel number;
g_ni_d_able_lel number;
g_ni_d_able_uap number;  --EOY 08/09
g_ni_d_able_uel number;
g_ni_d_able_et number;
g_ni_d_able_auel number;
g_ni_d_ee_auel number;
g_ni_e_able_lel number;
g_ni_e_able_uap number;  --EOY 08/09
g_ni_e_able_uel number;
g_ni_e_able_et number;
g_ni_e_able_auel number;
g_ni_e_ee_auel number;
g_ni_f_able_lel number;
g_ni_f_able_uap number;  --EOY 08/09
g_ni_f_able_uel number;
g_ni_f_able_et number;
g_ni_f_able_auel number;
g_ni_f_ee_auel number;
g_ni_g_able_lel number;
g_ni_g_able_uap number;  --EOY 08/09
g_ni_g_able_uel number;
g_ni_g_able_et number;
g_ni_g_able_auel number;
g_ni_g_ee_auel number;
g_ni_j_able_lel number;
g_ni_j_able_uap number;  --EOY 08/09
g_ni_j_able_uel number;
g_ni_j_able_et number;
g_ni_j_able_auel number;
g_ni_j_ee_auel number;
g_ni_l_able_lel number;
g_ni_l_able_uap number;  --EOY 08/9
g_ni_l_able_uel number;
g_ni_l_able_et number;
g_ni_l_able_auel number;
g_ni_l_ee_auel number;
g_ni_s_able_lel number;
g_ni_s_able_uap number;  --EOY 08/09
g_ni_s_able_uel number;
g_ni_s_able_et number;
g_ni_s_able_auel number;
g_ni_s_ee_auel number;
g_st_ni_a_able number;
g_st_ni_ap_able number;
g_st_ni_b_able number;
g_st_ni_bp_able number;
g_st_ni_c_able number;
g_st_ni_co_able number;
g_st_ni_d_able number;
g_st_ni_e_able number;
g_st_ni_f_able number;
g_st_ni_g_able number;
g_st_ni_j_able number;
g_st_ni_jp_able number;
g_st_ni_l_able number;
g_st_ni_s_able number;
g_ni_c_ers_rebate number;
g_ni_d_ers_rebate number;
g_ni_d_ees_rebate number;
g_ni_e_ers_rebate number;
g_ni_f_ers_rebate number;
g_ni_f_ees_rebate number;
g_ni_g_ers_rebate number;
g_ni_s_ers_rebate number;
g_comp_min_ees_defbal number;
g_comp_min_ers_defbal number;
g_ni_a_employee_defbal number;
g_ni_b_employee_defbal number;
g_ni_c_employee_defbal number;
g_ni_d_employee_defbal number;
g_ni_e_employee_defbal number;
g_ni_f_employee_defbal number;
g_ni_g_employee_defbal number;
g_ni_j_employee_defbal number;
g_ni_l_employee_defbal number;
g_ni_l_employee_not_defbal number;
g_ni_s_employee_defbal number;
g_ni_s_employee_not_defbal number;
g_ni_a_employer_defbal number;
g_ni_b_employer_defbal number;
g_ni_c_employer_defbal number;
g_ni_d_employer_defbal number;
g_ni_e_employer_defbal number;
g_ni_f_employer_defbal number;
g_ni_g_employer_defbal number;
g_ni_j_employer_defbal number;
g_ni_l_employer_defbal number;
g_ni_s_employer_defbal number;
g_ni_a_able_defbal number;
g_ni_b_able_defbal number;
g_ni_c_able_defbal number;
g_ni_d_able_defbal number;
g_ni_e_able_defbal number;
g_ni_f_able_defbal number;
g_ni_g_able_defbal number;
g_ni_j_able_defbal number;
g_ni_l_able_defbal number;
g_ni_s_able_defbal number;
g_ni_c_co_able_defbal number;
g_ni_d_co_able_defbal number;
g_ni_e_co_able_defbal number;
g_ni_f_co_able_defbal number;
g_ni_g_co_able_defbal number;
g_ni_s_co_able_defbal number;
g_ni_a_able_lel_defbal number;
g_ni_a_able_uap_defbal number;  --EOY 08/09
g_ni_a_able_uel_defbal number;
g_ni_a_able_et_defbal number;
g_ni_a_able_auel_defbal number;
g_ni_a_ee_auel_defbal number;
g_ni_b_able_lel_defbal number;
g_ni_b_able_uap_defbal number;  --EOY 08/09
g_ni_b_able_uel_defbal number;
g_ni_b_able_et_defbal number;
g_ni_b_able_auel_defbal number;
g_ni_b_ee_auel_defbal number;
g_ni_c_able_lel_defbal number;
g_ni_c_able_uap_defbal number;  --EOY 08/09
g_ni_c_able_uel_defbal number;
g_ni_c_able_et_defbal number;
g_ni_c_able_auel_defbal number;
g_ni_c_ee_auel_defbal number;
g_ni_d_able_lel_defbal number;
g_ni_d_able_uap_defbal number;  --EOY 08/09
g_ni_d_able_uel_defbal number;
g_ni_d_able_et_defbal number;
g_ni_d_able_auel_defbal number;
g_ni_d_ee_auel_defbal number;
g_ni_e_able_lel_defbal number;
g_ni_e_able_uap_defbal number;  --EOY 08/09
g_ni_e_able_uel_defbal number;
g_ni_e_able_et_defbal number;
g_ni_e_able_auel_defbal number;
g_ni_e_ee_auel_defbal number;
g_ni_f_able_lel_defbal number;
g_ni_f_able_uap_defbal number;  --EOY 08/09
g_ni_f_able_uel_defbal number;
g_ni_f_able_et_defbal number;
g_ni_f_able_auel_defbal number;
g_ni_f_ee_auel_defbal number;
g_ni_g_able_lel_defbal number;
g_ni_g_able_uap_defbal number;  --EOY 08/09
g_ni_g_able_uel_defbal number;
g_ni_g_able_et_defbal number;
g_ni_g_able_auel_defbal number;
g_ni_g_ee_auel_defbal number;
g_ni_j_able_lel_defbal number;
g_ni_j_able_uap_defbal number;  --EOY 08/09
g_ni_j_able_uel_defbal number;
g_ni_j_able_et_defbal number;
g_ni_j_able_auel_defbal number;
g_ni_j_ee_auel_defbal number;
g_ni_l_able_lel_defbal number;
g_ni_l_able_uap_defbal number;  --EOY 08/09
g_ni_l_able_uel_defbal number;
g_ni_l_able_et_defbal number;
g_ni_l_able_auel_defbal number;
g_ni_l_ee_auel_defbal number;
g_ni_s_able_lel_defbal number;
g_ni_s_able_uap_defbal number;  --EOY 08/09
g_ni_s_able_uel_defbal number;
g_ni_s_able_et_defbal number;
g_ni_s_able_auel_defbal number;
g_ni_s_ee_auel_defbal number;
g_ni_c_ers_rebate_defbal number;
g_ni_d_ers_rebate_defbal number;
g_ni_d_ees_rebate_defbal number;
g_ni_e_ers_rebate_defbal number;
g_ni_f_ers_rebate_defbal number;
g_ni_f_ees_rebate_defbal number;
g_ni_g_ers_rebate_defbal number;
g_ni_s_ers_rebate_defbal number;
--------------------------------------------------------------------------------
--    GET_PLSQL_GLOBAL
--    retrieve a PLSQL global from the session
  function GET_PLSQL_GLOBAL
       ( P_global_name in varchar2 )
      return number is
--
l_value number;
--
Begin
--
l_value := 0;

--
  if p_global_name = 'a_employee' then l_value := g_ni_a_employee;
  elsif p_global_name = 'b_employee' then l_value := g_ni_b_employee;
  elsif p_global_name = 'c_employee' then l_value := g_ni_c_employee;
  elsif p_global_name = 'd_employee' then l_value := g_ni_d_employee;
  elsif p_global_name = 'e_employee' then l_value := g_ni_e_employee;
  elsif p_global_name = 'f_employee' then l_value := g_ni_f_employee;
  elsif p_global_name = 'g_employee' then l_value := g_ni_g_employee;
  elsif p_global_name = 'j_employee' then l_value := g_ni_j_employee;
  elsif p_global_name = 'l_employee' then l_value := g_ni_l_employee;
  elsif p_global_name = 'l_employee_not' then l_value := g_ni_l_employee_not;
  elsif p_global_name = 's_employee' then l_value := g_ni_s_employee;
  elsif p_global_name = 's_employee_not' then l_value := g_ni_s_employee_not;
  elsif p_global_name = 'a_employer' then l_value := g_ni_a_employer;
  elsif p_global_name = 'b_employer' then l_value := g_ni_b_employer;
  elsif p_global_name = 'c_employer' then l_value := g_ni_c_employer;
  elsif p_global_name = 'd_employer' then l_value := g_ni_d_employer;
  elsif p_global_name = 'e_employer' then l_value := g_ni_e_employer;
  elsif p_global_name = 'f_employer' then l_value := g_ni_f_employer;
  elsif p_global_name = 'g_employer' then l_value := g_ni_g_employer;
  elsif p_global_name = 'j_employer' then l_value := g_ni_j_employer;
  elsif p_global_name = 'l_employer' then l_value := g_ni_l_employer;
  elsif p_global_name = 's_employer' then l_value := g_ni_s_employer;
  elsif p_global_name = 'a_able' then l_value := g_ni_a_able;
  elsif p_global_name = 'b_able' then l_value := g_ni_b_able;
  elsif p_global_name = 'c_able' then l_value := g_ni_c_able;
  elsif p_global_name = 'co_able' then l_value := g_ni_co_able;
  elsif p_global_name = 'd_able' then l_value := g_ni_d_able;
  elsif p_global_name = 'e_able' then l_value := g_ni_e_able;
  elsif p_global_name = 'f_able' then l_value := g_ni_f_able;
  elsif p_global_name = 'g_able' then l_value := g_ni_g_able;
  elsif p_global_name = 'j_able' then l_value := g_ni_j_able;
  elsif p_global_name = 'l_able' then l_value := g_ni_l_able;
  elsif p_global_name = 's_able' then l_value := g_ni_s_able;
  elsif p_global_name = 'c_co_able' then l_value := g_ni_c_co_able;
  elsif p_global_name = 'd_co_able' then l_value := g_ni_d_co_able;
  elsif p_global_name = 'e_co_able' then l_value := g_ni_e_co_able;
  elsif p_global_name = 'f_co_able' then l_value := g_ni_f_co_able;
  elsif p_global_name = 'g_co_able' then l_value := g_ni_g_co_able;
  elsif p_global_name = 's_co_able' then l_value := g_ni_s_co_able;
  elsif p_global_name = 'c_ers_rebate' then l_value := g_ni_c_ers_rebate;
  elsif p_global_name = 'd_ers_rebate' then l_value := g_ni_d_ers_rebate;
  elsif p_global_name = 'e_ers_rebate' then l_value := g_ni_e_ers_rebate;
  elsif p_global_name = 'f_ers_rebate' then l_value := g_ni_f_ers_rebate;
  elsif p_global_name = 'g_ers_rebate' then l_value := g_ni_g_ers_rebate;
  elsif p_global_name = 's_ers_rebate' then l_value := g_ni_s_ers_rebate;
  elsif p_global_name = 'd_ees_rebate' then l_value := g_ni_d_ees_rebate;
  elsif p_global_name = 'f_ees_rebate' then l_value := g_ni_f_ees_rebate;
  elsif p_global_name = 'a_able_lel' then l_value := g_ni_a_able_lel;
  elsif p_global_name = 'a_able_uap' then l_value := g_ni_a_able_uap;  --EOY 08/09
  elsif p_global_name = 'a_able_uel' then l_value := g_ni_a_able_uel;
  elsif p_global_name = 'a_able_et' then l_value := g_ni_a_able_et;
  elsif p_global_name = 'a_able_auel' then l_value := g_ni_a_able_auel;
  elsif p_global_name = 'a_ee_auel' then l_value := g_ni_a_ee_auel;
  elsif p_global_name = 'b_able_lel' then l_value := g_ni_b_able_lel;
  elsif p_global_name = 'b_able_uap' then l_value := g_ni_b_able_uap;  --EOY 08/09
  elsif p_global_name = 'b_able_uel' then l_value := g_ni_b_able_uel;
  elsif p_global_name = 'b_able_et' then l_value := g_ni_b_able_et;
  elsif p_global_name = 'b_able_auel' then l_value := g_ni_b_able_auel;
  elsif p_global_name = 'b_ee_auel' then l_value := g_ni_b_ee_auel;
  elsif p_global_name = 'c_able_lel' then l_value := g_ni_c_able_lel;
  elsif p_global_name = 'c_able_uap' then l_value := g_ni_c_able_uap;  --EOY 08/09
  elsif p_global_name = 'c_able_uel' then l_value := g_ni_c_able_uel;
  elsif p_global_name = 'c_able_et' then l_value := g_ni_c_able_et;
  elsif p_global_name = 'c_able_auel' then l_value := g_ni_c_able_auel;
  elsif p_global_name = 'c_ee_auel' then l_value := g_ni_c_ee_auel;
  elsif p_global_name = 'd_able_lel' then l_value := g_ni_d_able_lel;
  elsif p_global_name = 'd_able_uap' then l_value := g_ni_d_able_uap;  --EOY 08/09
  elsif p_global_name = 'd_able_uel' then l_value := g_ni_d_able_uel;
  elsif p_global_name = 'd_able_et' then l_value := g_ni_d_able_et;
  elsif p_global_name = 'd_able_auel' then l_value := g_ni_d_able_auel;
  elsif p_global_name = 'd_ee_auel' then l_value := g_ni_d_ee_auel;
  elsif p_global_name = 'e_able_lel' then l_value := g_ni_e_able_lel;
  elsif p_global_name = 'e_able_uap' then l_value := g_ni_e_able_uap;  --EOY 08/09
  elsif p_global_name = 'e_able_uel' then l_value := g_ni_e_able_uel;
  elsif p_global_name = 'e_able_et' then l_value := g_ni_e_able_et;
  elsif p_global_name = 'e_able_auel' then l_value := g_ni_e_able_auel;
  elsif p_global_name = 'e_ee_auel' then l_value := g_ni_e_ee_auel;
  elsif p_global_name = 'f_able_lel' then l_value := g_ni_f_able_lel;
  elsif p_global_name = 'f_able_uap' then l_value := g_ni_f_able_uap;  --EOY 08/09
  elsif p_global_name = 'f_able_uel' then l_value := g_ni_f_able_uel;
  elsif p_global_name = 'f_able_et' then l_value := g_ni_f_able_et;
  elsif p_global_name = 'f_able_auel' then l_value := g_ni_f_able_auel;
  elsif p_global_name = 'f_ee_auel' then l_value := g_ni_f_ee_auel;
  elsif p_global_name = 'g_able_lel' then l_value := g_ni_g_able_lel;
  elsif p_global_name = 'g_able_uap' then l_value := g_ni_g_able_uap;  --EOY 08/09
  elsif p_global_name = 'g_able_uel' then l_value := g_ni_g_able_uel;
  elsif p_global_name = 'g_able_et' then l_value := g_ni_g_able_et;
  elsif p_global_name = 'g_able_auel' then l_value := g_ni_g_able_auel;
  elsif p_global_name = 'g_ee_auel' then l_value := g_ni_g_ee_auel;
  elsif p_global_name = 's_able_lel' then l_value := g_ni_s_able_lel;
  elsif p_global_name = 's_able_uap' then l_value := g_ni_s_able_uap;  --EOY 08/09
  elsif p_global_name = 's_able_uel' then l_value := g_ni_s_able_uel;
  elsif p_global_name = 's_able_et' then l_value := g_ni_s_able_et;
  elsif p_global_name = 's_able_auel' then l_value := g_ni_s_able_auel;
  elsif p_global_name = 's_ee_auel' then l_value := g_ni_s_ee_auel;
  elsif p_global_name = 'st_a_able' then l_value := g_st_ni_a_able;
  elsif p_global_name = 'st_ap_able' then l_value := g_st_ni_ap_able;
  elsif p_global_name = 'st_b_able' then l_value := g_st_ni_b_able;
  elsif p_global_name = 'st_bp_able' then l_value := g_st_ni_bp_able;
  elsif p_global_name = 'st_c_able' then l_value := g_st_ni_c_able;
  elsif p_global_name = 'st_co_able' then l_value := g_st_ni_co_able;
  elsif p_global_name = 'st_d_able' then l_value := g_st_ni_d_able;
  elsif p_global_name = 'st_e_able' then l_value := g_st_ni_e_able;
  elsif p_global_name = 'st_f_able' then l_value := g_st_ni_f_able;
  elsif p_global_name = 'st_g_able' then l_value := g_st_ni_g_able;
  elsif p_global_name = 'st_j_able' then l_value := g_st_ni_j_able;
  elsif p_global_name = 'st_jp_able' then l_value := g_st_ni_jp_able;
  elsif p_global_name = 'st_l_able' then l_value := g_st_ni_l_able;
  elsif p_global_name = 'st_s_able' then l_value := g_st_ni_s_able;
  elsif p_global_name = 'comp_min_ees' then l_value := g_comp_min_ees;
  elsif p_global_name = 'comp_min_ers' then l_value := g_comp_min_ers;
  --9509806 Begin  - Missed values are added
  elsif p_global_name = 'j_able_lel' then l_value := g_ni_j_able_lel;
  elsif p_global_name = 'j_able_uap' then l_value := g_ni_j_able_uap;  --EOY 08/09
  elsif p_global_name = 'j_able_uel' then l_value := g_ni_j_able_uel;
  elsif p_global_name = 'j_able_et' then l_value := g_ni_j_able_et;
  elsif p_global_name = 'j_able_auel' then l_value := g_ni_j_able_auel;
  elsif p_global_name = 'j_ee_auel' then l_value := g_ni_j_ee_auel;
  elsif p_global_name = 'l_able_lel' then l_value := g_ni_l_able_lel;
  elsif p_global_name = 'l_able_uap' then l_value := g_ni_l_able_uap;  --EOY 08/09
  elsif p_global_name = 'l_able_uel' then l_value := g_ni_l_able_uel;
  elsif p_global_name = 'l_able_et' then l_value := g_ni_l_able_et;
  elsif p_global_name = 'l_able_auel' then l_value := g_ni_l_able_auel;
  elsif p_global_name = 'l_ee_auel' then l_value := g_ni_l_ee_auel;
  --9509806 End
end if;
--
        RETURN l_value ;
--
  end GET_PLSQL_GLOBAL;
--------------------------------------------------------------------------------
-- Procedure: set_defined_balances
-- Description: This procedure sets all the defined balances that are
--              needed for NI calculation, and stores them in global
--              variables so should only be called once per session. This
--              sets a global flag to denote that they have been set.
--------------------------------------------------------------------------------

 procedure set_defined_balances (p_database_item_suffix in varchar2) is
 --
 begin
    select
    max(decode(BTYPE.balance_name,'NI A Employee',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI B Employee',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI C Employee',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI D Employee',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI E Employee',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI F Employee',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI G Employee',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI J Employee',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI L Employee',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI L Employee Notional',
                                           DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI S Employee',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI S Employee Notional',
                                           DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI A Employer',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI B Employer',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI C Employer',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI D Employer',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI E Employer',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI F Employer',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI G Employer',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI J Employer',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI L Employer',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI S Employer',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI A Able',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI A Able LEL',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI A Able UAP',DEFBAL.Defined_balance_id)) --EOY 08/09
   ,max(decode(BTYPE.balance_name,'NI A Able UEL',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI A Able ET',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI A Able AUEL',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI A EE AUEL',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI B Able',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI B Able LEL',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI B Able UAP',DEFBAL.Defined_balance_id)) --EOY 08/09
   ,max(decode(BTYPE.balance_name,'NI B Able UEL',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI B Able ET',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI B Able AUEL',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI B EE AUEL',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI C Able',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI C Able LEL',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI C Able UAP',DEFBAL.Defined_balance_id)) --EOY 08/09
   ,max(decode(BTYPE.balance_name,'NI C Able UEL',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI C Able ET',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI C Able AUEL',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI C EE AUEL',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI D Able',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI D Able LEL',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI D Able UAP',DEFBAL.Defined_balance_id)) --EOY 08/09
   ,max(decode(BTYPE.balance_name,'NI D Able UEL',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI D Able ET',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI D Able AUEL',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI D EE AUEL',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI E Able',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI E Able LEL',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI E Able UAP',DEFBAL.Defined_balance_id)) --EOY 08/09
   ,max(decode(BTYPE.balance_name,'NI E Able UEL',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI E Able ET',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI E Able AUEL',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI E EE AUEL',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI F Able',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI F Able LEL',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI F Able UAP',DEFBAL.Defined_balance_id)) --EOY 08/09
   ,max(decode(BTYPE.balance_name,'NI F Able UEL',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI F Able ET',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI F Able AUEL',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI F EE AUEL',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI G Able',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI G Able LEL',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI G Able UAP',DEFBAL.Defined_balance_id)) --EOY 08/09
   ,max(decode(BTYPE.balance_name,'NI G Able UEL',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI G Able ET',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI G Able AUEL',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI G EE AUEL',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI J Able',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI J Able LEL',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI J Able UAP',DEFBAL.Defined_balance_id)) --EOY 08/09
   ,max(decode(BTYPE.balance_name,'NI J Able UEL',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI J Able ET',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI J Able AUEL',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI J EE AUEL',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI L Able',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI L Able LEL',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI L Able UAP',DEFBAL.Defined_balance_id)) --EOY 08/09
   ,max(decode(BTYPE.balance_name,'NI L Able UEL',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI L Able ET',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI L Able AUEL',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI L EE AUEL',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI S Able',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI S Able LEL',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI S Able UAP',DEFBAL.Defined_balance_id)) --EOY 08/09
   ,max(decode(BTYPE.balance_name,'NI S Able UEL',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI S Able ET',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI S Able AUEL',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI S EE AUEL',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI C CO Able',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI D CO Able',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI E CO Able',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI F CO Able',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI G CO Able',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI S CO Able',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI C Ers Rebate',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI D Ers Rebate',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI E Ers Rebate',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI F Ers Rebate',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI G Ers Rebate',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI S Ers Rebate',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI D Ees Rebate',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'NI F Ees Rebate',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'Employee COMP Min Payment',DEFBAL.Defined_balance_id))
   ,max(decode(BTYPE.balance_name,'Employer COMP Min Payment',DEFBAL.Defined_balance_id))
    into
   g_ni_a_employee_defbal ,g_ni_b_employee_defbal ,g_ni_c_employee_defbal ,g_ni_d_employee_defbal ,g_ni_e_employee_defbal
 ,g_ni_f_employee_defbal ,g_ni_g_employee_defbal ,g_ni_j_employee_defbal, g_ni_l_employee_defbal, g_ni_l_employee_not_defbal
 ,g_ni_s_employee_defbal ,g_ni_s_employee_not_defbal
 ,g_ni_a_employer_defbal ,g_ni_b_employer_defbal ,g_ni_c_employer_defbal ,g_ni_d_employer_defbal ,g_ni_e_employer_defbal
 ,g_ni_f_employer_defbal ,g_ni_g_employer_defbal, g_ni_j_employer_defbal, g_ni_l_employer_defbal ,g_ni_s_employer_defbal
 ,g_ni_a_able_defbal ,g_ni_a_able_lel_defbal, g_ni_a_able_uap_defbal, g_ni_a_able_uel_defbal, g_ni_a_able_et_defbal, g_ni_a_able_auel_defbal,
  g_ni_a_ee_auel_defbal
 ,g_ni_b_able_defbal ,g_ni_b_able_lel_defbal, g_ni_b_able_uap_defbal, g_ni_b_able_uel_defbal, g_ni_b_able_et_defbal, g_ni_b_able_auel_defbal,
  g_ni_b_ee_auel_defbal
 ,g_ni_c_able_defbal ,g_ni_c_able_lel_defbal, g_ni_c_able_uap_defbal, g_ni_c_able_uel_defbal, g_ni_c_able_et_defbal, g_ni_c_able_auel_defbal,
  g_ni_c_ee_auel_defbal
 ,g_ni_d_able_defbal ,g_ni_d_able_lel_defbal, g_ni_d_able_uap_defbal, g_ni_d_able_uel_defbal, g_ni_d_able_et_defbal, g_ni_d_able_auel_defbal,
  g_ni_d_ee_auel_defbal
 ,g_ni_e_able_defbal ,g_ni_e_able_lel_defbal, g_ni_e_able_uap_defbal, g_ni_e_able_uel_defbal, g_ni_e_able_et_defbal, g_ni_e_able_auel_defbal,
  g_ni_e_ee_auel_defbal
 ,g_ni_f_able_defbal ,g_ni_f_able_lel_defbal, g_ni_f_able_uap_defbal, g_ni_f_able_uel_defbal, g_ni_f_able_et_defbal, g_ni_f_able_auel_defbal,
  g_ni_f_ee_auel_defbal
 ,g_ni_g_able_defbal ,g_ni_g_able_lel_defbal, g_ni_g_able_uap_defbal, g_ni_g_able_uel_defbal, g_ni_g_able_et_defbal, g_ni_g_able_auel_defbal,
  g_ni_g_ee_auel_defbal
 ,g_ni_j_able_defbal ,g_ni_j_able_lel_defbal, g_ni_j_able_uap_defbal, g_ni_j_able_uel_defbal, g_ni_j_able_et_defbal, g_ni_j_able_auel_defbal,
  g_ni_j_ee_auel_defbal
 ,g_ni_l_able_defbal ,g_ni_l_able_lel_defbal, g_ni_l_able_uap_defbal, g_ni_l_able_uel_defbal, g_ni_l_able_et_defbal, g_ni_l_able_auel_defbal,
  g_ni_l_ee_auel_defbal
 ,g_ni_s_able_defbal ,g_ni_s_able_lel_defbal, g_ni_s_able_uap_defbal, g_ni_s_able_uel_defbal, g_ni_s_able_et_defbal, g_ni_s_able_auel_defbal,
  g_ni_s_ee_auel_defbal
 ,g_ni_c_co_able_defbal ,g_ni_d_co_able_defbal ,g_ni_e_co_able_defbal
 ,g_ni_f_co_able_defbal ,g_ni_g_co_able_defbal ,g_ni_s_co_able_defbal
 ,g_ni_c_ers_rebate_defbal ,g_ni_d_ers_rebate_defbal ,g_ni_e_ers_rebate_defbal
 ,g_ni_f_ers_rebate_defbal ,g_ni_g_ers_rebate_defbal ,g_ni_s_ers_rebate_defbal
 ,g_ni_d_ees_rebate_defbal ,g_ni_f_ees_rebate_defbal , g_comp_min_ees_defbal,
  g_comp_min_ers_defbal
    from
  pay_balance_types        BTYPE,
  pay_defined_balances DEFBAL,
  pay_balance_dimensions DIM
  where DEFBAL.balance_dimension_id = DIM.balance_dimension_id
  and DIM.database_item_suffix = p_database_item_suffix
  and DIM.legislation_code = 'GB'
  and DEFBAL.legislation_code = 'GB'
  and defbal.balance_type_id = btype.balance_type_id
  and BTYPE.legislation_code = 'GB';
  --
  if p_database_item_suffix = '_PER_TD_DIR_YTD' then
       g_defined_director_set := TRUE;
       g_defined_ptd_set := FALSE;
  elsif p_database_item_suffix = '_PER_NI_PTD' then
       g_defined_ptd_set := TRUE;
       g_defined_director_set := FALSE;
  end if;
--
end set_defined_balances;
--------------------------------------------------------------------------------
-- Procedure: set_balance_table
-- Description: Set up the balance list table with all the defined balance ids
-- that have been stored in the global variables.
-- This is so that the list is in the correct layout for Core BUE call.
------------------------------------------------------------------------------
--
procedure set_balance_table(p_balance_list in out nocopy pay_balance_pkg.t_balance_value_tab)
--
  is
begin
p_balance_list.delete;
--
p_balance_list(1).defined_balance_id := g_comp_min_ees_defbal;
p_balance_list(2).defined_balance_id := g_comp_min_ers_defbal;
p_balance_list(3).defined_balance_id := g_ni_a_employee_defbal;
p_balance_list(4).defined_balance_id := g_ni_b_employee_defbal;
p_balance_list(5).defined_balance_id := g_ni_c_employee_defbal;
p_balance_list(6).defined_balance_id := g_ni_d_employee_defbal;
p_balance_list(7).defined_balance_id := g_ni_e_employee_defbal;
p_balance_list(8).defined_balance_id := g_ni_f_employee_defbal;
p_balance_list(9).defined_balance_id := g_ni_g_employee_defbal;
p_balance_list(10).defined_balance_id := g_ni_j_employee_defbal;
p_balance_list(11).defined_balance_id := g_ni_l_employee_defbal;
p_balance_list(12).defined_balance_id := g_ni_l_employee_not_defbal;
p_balance_list(13).defined_balance_id := g_ni_s_employee_defbal;
p_balance_list(14).defined_balance_id := g_ni_s_employee_not_defbal;
p_balance_list(15).defined_balance_id := g_ni_a_employer_defbal;
p_balance_list(16).defined_balance_id := g_ni_b_employer_defbal;
p_balance_list(17).defined_balance_id := g_ni_c_employer_defbal;
p_balance_list(18).defined_balance_id := g_ni_d_employer_defbal;
p_balance_list(19).defined_balance_id := g_ni_e_employer_defbal;
p_balance_list(20).defined_balance_id := g_ni_f_employer_defbal;
p_balance_list(21).defined_balance_id := g_ni_g_employer_defbal;
p_balance_list(22).defined_balance_id := g_ni_j_employer_defbal;
p_balance_list(23).defined_balance_id := g_ni_l_employer_defbal;
p_balance_list(24).defined_balance_id := g_ni_s_employer_defbal;
p_balance_list(25).defined_balance_id := g_ni_a_able_defbal;
p_balance_list(26).defined_balance_id := g_ni_b_able_defbal;
p_balance_list(27).defined_balance_id := g_ni_c_able_defbal;
p_balance_list(28).defined_balance_id := g_ni_d_able_defbal;
p_balance_list(29).defined_balance_id := g_ni_e_able_defbal;
p_balance_list(30).defined_balance_id := g_ni_f_able_defbal;
p_balance_list(31).defined_balance_id := g_ni_g_able_defbal;
p_balance_list(32).defined_balance_id := g_ni_j_able_defbal;
p_balance_list(33).defined_balance_id := g_ni_l_able_defbal;
p_balance_list(34).defined_balance_id := g_ni_s_able_defbal;
p_balance_list(35).defined_balance_id := g_ni_c_co_able_defbal;
p_balance_list(36).defined_balance_id := g_ni_d_co_able_defbal;
p_balance_list(37).defined_balance_id := g_ni_e_co_able_defbal;
p_balance_list(38).defined_balance_id := g_ni_f_co_able_defbal;
p_balance_list(39).defined_balance_id := g_ni_g_co_able_defbal;
p_balance_list(40).defined_balance_id := g_ni_s_co_able_defbal;
p_balance_list(41).defined_balance_id := g_ni_a_able_lel_defbal;
p_balance_list(42).defined_balance_id := g_ni_a_able_uel_defbal;
p_balance_list(43).defined_balance_id := g_ni_a_able_et_defbal;
p_balance_list(44).defined_balance_id := g_ni_a_able_auel_defbal;
p_balance_list(45).defined_balance_id := g_ni_a_ee_auel_defbal;
p_balance_list(46).defined_balance_id := g_ni_b_able_lel_defbal;
p_balance_list(47).defined_balance_id := g_ni_b_able_uel_defbal;
p_balance_list(48).defined_balance_id := g_ni_b_able_et_defbal;
p_balance_list(49).defined_balance_id := g_ni_b_able_auel_defbal;
p_balance_list(50).defined_balance_id := g_ni_b_ee_auel_defbal;
p_balance_list(51).defined_balance_id := g_ni_c_able_lel_defbal;
p_balance_list(52).defined_balance_id := g_ni_c_able_uel_defbal;
p_balance_list(53).defined_balance_id := g_ni_c_able_et_defbal;
p_balance_list(54).defined_balance_id := g_ni_c_able_auel_defbal;
p_balance_list(55).defined_balance_id := g_ni_c_ee_auel_defbal;
p_balance_list(56).defined_balance_id := g_ni_d_able_lel_defbal;
p_balance_list(57).defined_balance_id := g_ni_d_able_uel_defbal;
p_balance_list(58).defined_balance_id := g_ni_d_able_et_defbal;
p_balance_list(59).defined_balance_id := g_ni_d_able_auel_defbal;
p_balance_list(60).defined_balance_id := g_ni_d_ee_auel_defbal;
p_balance_list(61).defined_balance_id := g_ni_e_able_lel_defbal;
p_balance_list(62).defined_balance_id := g_ni_e_able_uel_defbal;
p_balance_list(63).defined_balance_id := g_ni_e_able_et_defbal;
p_balance_list(64).defined_balance_id := g_ni_e_able_auel_defbal;
p_balance_list(65).defined_balance_id := g_ni_e_ee_auel_defbal;
p_balance_list(66).defined_balance_id := g_ni_f_able_lel_defbal;
p_balance_list(67).defined_balance_id := g_ni_f_able_uel_defbal;
p_balance_list(68).defined_balance_id := g_ni_f_able_et_defbal;
p_balance_list(69).defined_balance_id := g_ni_f_able_auel_defbal;
p_balance_list(70).defined_balance_id := g_ni_f_ee_auel_defbal;
p_balance_list(71).defined_balance_id := g_ni_g_able_lel_defbal;
p_balance_list(72).defined_balance_id := g_ni_g_able_uel_defbal;
p_balance_list(73).defined_balance_id := g_ni_g_able_et_defbal;
p_balance_list(74).defined_balance_id := g_ni_g_able_auel_defbal;
p_balance_list(75).defined_balance_id := g_ni_g_ee_auel_defbal;
p_balance_list(76).defined_balance_id := g_ni_j_able_lel_defbal;
p_balance_list(77).defined_balance_id := g_ni_j_able_uel_defbal;
p_balance_list(78).defined_balance_id := g_ni_j_able_et_defbal;
p_balance_list(79).defined_balance_id := g_ni_j_able_auel_defbal;
p_balance_list(80).defined_balance_id := g_ni_j_ee_auel_defbal;
p_balance_list(81).defined_balance_id := g_ni_l_able_lel_defbal;
p_balance_list(82).defined_balance_id := g_ni_l_able_uel_defbal;
p_balance_list(83).defined_balance_id := g_ni_l_able_et_defbal;
p_balance_list(84).defined_balance_id := g_ni_l_able_auel_defbal;
p_balance_list(85).defined_balance_id := g_ni_l_ee_auel_defbal;
p_balance_list(86).defined_balance_id := g_ni_s_able_lel_defbal;
p_balance_list(87).defined_balance_id := g_ni_s_able_uel_defbal;
p_balance_list(88).defined_balance_id := g_ni_s_able_et_defbal;
p_balance_list(89).defined_balance_id := g_ni_s_able_auel_defbal;
p_balance_list(90).defined_balance_id := g_ni_s_ee_auel_defbal;
p_balance_list(91).defined_balance_id := g_ni_c_ers_rebate_defbal;
p_balance_list(92).defined_balance_id := g_ni_d_ers_rebate_defbal;
p_balance_list(93).defined_balance_id := g_ni_d_ees_rebate_defbal;
p_balance_list(94).defined_balance_id := g_ni_e_ers_rebate_defbal;
p_balance_list(95).defined_balance_id := g_ni_f_ers_rebate_defbal;
p_balance_list(96).defined_balance_id := g_ni_f_ees_rebate_defbal;
p_balance_list(97).defined_balance_id := g_ni_g_ers_rebate_defbal;
p_balance_list(98).defined_balance_id := g_ni_s_ers_rebate_defbal;
--EOY 08/09 Begin
p_balance_list(99).defined_balance_id := g_ni_a_able_uap_defbal;
p_balance_list(100).defined_balance_id := g_ni_b_able_uap_defbal;
p_balance_list(101).defined_balance_id := g_ni_c_able_uap_defbal;
p_balance_list(102).defined_balance_id := g_ni_d_able_uap_defbal;
p_balance_list(103).defined_balance_id := g_ni_e_able_uap_defbal;
p_balance_list(104).defined_balance_id := g_ni_f_able_uap_defbal;
p_balance_list(105).defined_balance_id := g_ni_g_able_uap_defbal;
p_balance_list(106).defined_balance_id := g_ni_j_able_uap_defbal;
p_balance_list(107).defined_balance_id := g_ni_l_able_uap_defbal;
p_balance_list(108).defined_balance_id := g_ni_s_able_uap_defbal;
--EOY 08/09 End

end set_balance_table;
------------------------------------------------------------------------------
-- Procedure: set_balance_values
-- Description: set the global balance values from the balance table
-- after the table has been returned by the batch-mode call to core BUE.
------------------------------------------------------------------------------
procedure set_balance_values(p_balance_list in pay_balance_pkg.t_balance_value_tab)
  is
begin
g_comp_min_ees := p_balance_list(1).balance_value;
g_comp_min_ers := p_balance_list(2).balance_value;
g_ni_a_employee := p_balance_list(3).balance_value;
g_ni_b_employee := p_balance_list(4).balance_value;
g_ni_c_employee := p_balance_list(5).balance_value;
g_ni_d_employee := p_balance_list(6).balance_value;
g_ni_e_employee := p_balance_list(7).balance_value;
g_ni_f_employee := p_balance_list(8).balance_value;
g_ni_g_employee := p_balance_list(9).balance_value;
g_ni_j_employee := p_balance_list(10).balance_value;
g_ni_l_employee := p_balance_list(11).balance_value;
g_ni_l_employee_not := p_balance_list(12).balance_value;
g_ni_s_employee := p_balance_list(13).balance_value;
g_ni_s_employee_not := p_balance_list(14).balance_value;
g_ni_a_employer := p_balance_list(15).balance_value;
g_ni_b_employer := p_balance_list(16).balance_value;
g_ni_c_employer := p_balance_list(17).balance_value;
g_ni_d_employer := p_balance_list(18).balance_value;
g_ni_e_employer := p_balance_list(19).balance_value;
g_ni_f_employer := p_balance_list(20).balance_value;
g_ni_g_employer := p_balance_list(21).balance_value;
g_ni_j_employer := p_balance_list(22).balance_value;
g_ni_l_employer := p_balance_list(23).balance_value;
g_ni_s_employer := p_balance_list(24).balance_value;
g_ni_a_able := p_balance_list(25).balance_value;
g_ni_b_able := p_balance_list(26).balance_value;
g_ni_c_able := p_balance_list(27).balance_value;
g_ni_d_able := p_balance_list(28).balance_value;
g_ni_e_able := p_balance_list(29).balance_value;
g_ni_f_able := p_balance_list(30).balance_value;
g_ni_g_able := p_balance_list(31).balance_value;
g_ni_j_able := p_balance_list(32).balance_value;
g_ni_l_able := p_balance_list(33).balance_value;
g_ni_s_able := p_balance_list(34).balance_value;
g_ni_c_co_able := p_balance_list(35).balance_value;
g_ni_d_co_able := p_balance_list(36).balance_value;
g_ni_e_co_able := p_balance_list(37).balance_value;
g_ni_f_co_able := p_balance_list(38).balance_value;
g_ni_g_co_able := p_balance_list(39).balance_value;
g_ni_s_co_able := p_balance_list(40).balance_value;
g_ni_a_able_lel := p_balance_list(41).balance_value;
g_ni_a_able_uel := p_balance_list(42).balance_value;
g_ni_a_able_et := p_balance_list(43).balance_value;
g_ni_a_able_auel := p_balance_list(44).balance_value;
g_ni_a_ee_auel := p_balance_list(45).balance_value;
g_ni_b_able_lel := p_balance_list(46).balance_value;
g_ni_b_able_uel := p_balance_list(47).balance_value;
g_ni_b_able_et := p_balance_list(48).balance_value;
g_ni_b_able_auel := p_balance_list(49).balance_value;
g_ni_b_ee_auel := p_balance_list(50).balance_value;
g_ni_c_able_lel := p_balance_list(51).balance_value;
g_ni_c_able_uel := p_balance_list(52).balance_value;
g_ni_c_able_et := p_balance_list(53).balance_value;
g_ni_c_able_auel := p_balance_list(54).balance_value;
g_ni_c_ee_auel := p_balance_list(55).balance_value;
g_ni_d_able_lel := p_balance_list(56).balance_value;
g_ni_d_able_uel := p_balance_list(57).balance_value;
g_ni_d_able_et := p_balance_list(58).balance_value;
g_ni_d_able_auel := p_balance_list(59).balance_value;
g_ni_d_ee_auel := p_balance_list(60).balance_value;
g_ni_e_able_lel := p_balance_list(61).balance_value;
g_ni_e_able_uel := p_balance_list(62).balance_value;
g_ni_e_able_et := p_balance_list(63).balance_value;
g_ni_e_able_auel := p_balance_list(64).balance_value;
g_ni_e_ee_auel := p_balance_list(65).balance_value;
g_ni_f_able_lel := p_balance_list(66).balance_value;
g_ni_f_able_uel := p_balance_list(67).balance_value;
g_ni_f_able_et := p_balance_list(68).balance_value;
g_ni_f_able_auel := p_balance_list(69).balance_value;
g_ni_f_ee_auel := p_balance_list(70).balance_value;
g_ni_g_able_lel := p_balance_list(71).balance_value;
g_ni_g_able_uel := p_balance_list(72).balance_value;
g_ni_g_able_et := p_balance_list(73).balance_value;
g_ni_g_able_auel := p_balance_list(74).balance_value;
g_ni_g_ee_auel := p_balance_list(75).balance_value;
g_ni_j_able_lel := p_balance_list(76).balance_value;
g_ni_j_able_uel := p_balance_list(77).balance_value;
g_ni_j_able_et := p_balance_list(78).balance_value;
g_ni_j_able_auel := p_balance_list(79).balance_value;
g_ni_j_ee_auel := p_balance_list(80).balance_value;
g_ni_l_able_lel := p_balance_list(81).balance_value;
g_ni_l_able_uel := p_balance_list(82).balance_value;
g_ni_l_able_et := p_balance_list(83).balance_value;
g_ni_l_able_auel := p_balance_list(84).balance_value;
g_ni_l_ee_auel := p_balance_list(85).balance_value;
g_ni_s_able_lel := p_balance_list(86).balance_value;
g_ni_s_able_uel := p_balance_list(87).balance_value;
g_ni_s_able_et := p_balance_list(88).balance_value;
g_ni_s_able_auel := p_balance_list(89).balance_value;
g_ni_s_ee_auel := p_balance_list(90).balance_value;
g_ni_c_ers_rebate := p_balance_list(91).balance_value;
g_ni_d_ers_rebate := p_balance_list(92).balance_value;
g_ni_d_ees_rebate := p_balance_list(93).balance_value;
g_ni_e_ers_rebate := p_balance_list(94).balance_value;
g_ni_f_ers_rebate := p_balance_list(95).balance_value;
g_ni_f_ees_rebate := p_balance_list(96).balance_value;
g_ni_g_ers_rebate := p_balance_list(97).balance_value;
g_ni_s_ers_rebate := p_balance_list(98).balance_value;
--EOY 08/09 Begin
g_ni_a_able_uap := p_balance_list(99).balance_value;
g_ni_b_able_uap := p_balance_list(100).balance_value;
g_ni_c_able_uap := p_balance_list(101).balance_value;
g_ni_d_able_uap := p_balance_list(102).balance_value;
g_ni_e_able_uap := p_balance_list(103).balance_value;
g_ni_f_able_uap := p_balance_list(104).balance_value;
g_ni_g_able_uap := p_balance_list(105).balance_value;
g_ni_j_able_uap := p_balance_list(106).balance_value;
g_ni_l_able_uap := p_balance_list(107).balance_value;
g_ni_s_able_uap := p_balance_list(108).balance_value;
--EOY 08/09 End
--
end set_balance_values;

------------------------------------------------------------------------------
--                          NI_ABLE_DIR_YTD                                   --
-- find the NIable Pay balance for a particular category for director
-- This function is now obsolete so blanked out, and zero returned. This
-- is not called by any UK formula, package, report or form. The values
-- here can be obtained using ni_balances_per_dir_td_ytd.
--
--------------------------------------------------------------------------------

  function ni_able_dir_ytd
     (
      p_assignment_action_id   IN    number ,
      p_category    IN     varchar2 ,
      p_pension          IN          varchar2
     )
      return number is
begin
--
    RETURN 0;
--
end ni_able_dir_ytd;
--
--------------------------------------------------------------------------------
--                          NI_BALANCES_PER_DIR_TD_YTD                                   --
--  get all of the NI balances for an assignment in one select
--
--------------------------------------------------------------------------------
--

  function NI_BALANCES_PER_DIR_TD_YTD
     (
      p_assignment_action_id   IN    number,
      p_global_name            IN    varchar2
     )
      return number is
--
-- N.B. When called from FastFormula, p_assignment_action_id
-- provided via context-set variables.
--
        l_stat_period_start       date;
        l_start_director          date;
  l_bact_effective_date     date;
        l_assignment_id           number;
  l_balance_value           number;
        l_balance_list  pay_balance_pkg.t_balance_value_tab;
--
Begin
--
  -- Set up the defined balances for all NI balances _PER_TD_DIR_YTD
  if g_defined_director_set = FALSE then
     hr_utility.trace('Calling set_defined_balances');
     set_defined_balances('_PER_TD_DIR_YTD');
  end if;
  hr_utility.trace('example defbal:'||to_char(g_comp_min_ers_defbal));
  --
  if g_ni_able_id is null then
        select balance_type_id
        into    g_ni_able_id
        from pay_balance_types
        where balance_name = 'NIable Pay';
--
        select element_type_id
             into    g_ni_element_type_id
             from pay_element_types_f
             where element_name = 'NI'
             and sysdate between effective_start_date
                             and effective_end_date;
--
        select input_value_id
             into    g_cat_input_id
             from pay_input_values_f
             where name = 'Category'
             and   element_type_id = g_ni_element_type_id
             and sysdate between effective_start_date
                             and effective_end_date;
--
        select input_value_id
             into    g_pen_input_id
             from pay_input_values_f
             where name = 'Pension'
             and   element_type_id = g_ni_element_type_id
             and sysdate between effective_start_date
                             and effective_end_date;
  end if;
--
--       find the start of the financial year and the start of the directorship
         select BACT.effective_date, BAL_ASSACT.assignment_id
                into l_bact_effective_date, l_assignment_id
                from pay_payroll_actions BACT,
                     pay_assignment_actions BAL_ASSACT
                where BAL_ASSACT.assignment_action_id = p_assignment_action_id
                and   BAL_ASSACT.payroll_action_id = BACT.payroll_action_id;

         l_stat_period_start := hr_gbbal.span_start(l_bact_effective_date, 1, '06-04-');
         l_start_director    := hr_gbbal.start_director(l_assignment_id,
                    l_stat_period_start,
              l_bact_effective_date);
--
-- if the assignment_action_id has changed from the last call or is null,
-- calculate the balances via route-code before calling the global function.
-- Added JN and LC for 2003 Legislation.
--
-- NI ABLE CURSOR, USE THIS RATHER THAN CORE BUE DUE TO DIFFERING ROUTE ETC.
--
   IF g_assignment_action_id <> p_assignment_action_id
      OR g_assignment_action_id is null then
              select /*+ ORDERED INDEX(BAL_ASSACT PAY_ASSIGNMENT_ACTIONS_PK,
                                       BACT PAY_PAYROLL_ACTIONS_PK,
                                       BPTP PER_TIME_PERIODS_PK,
                                       START_ASS PER_ASSIGNMENTS_F_PK,
                                       ASS PER_ASSIGNMENTS_F_N12,
                                       ASSACT PAY_ASSIGNMENT_ACTIONS_N51,
                                       PACT PAY_PAYROLL_ACTIONS_PK,
                                       PPTP PER_TIME_PERIODS_PK ,
                                       RR PAY_RUN_RESULTS_N50,
                                       TARGET PAY_RUN_RESULT_VALUES_PK,
                                       FEED PAY_BALANCE_FEEDS_F_UK2 )
                        USE_NL(BAL_ASSACT,BACT,BPTP,START_ASS,ASS,ASSACT,PACT,PPTP,RR,TARGET,FEED) +*/
        nvl(sum(decode(hr_gbnidir.NI_ELEMENT_ENTRY_VALUE(ASSACT.assignment_id, PACT.effective_date),
              'AN',fnd_number.canonical_to_number(TARGET.result_value) * FEED.scale,0)),0)
        ,nvl(sum(decode(hr_gbnidir.NI_ELEMENT_ENTRY_VALUE(ASSACT.assignment_id, PACT.effective_date),
              'AA',fnd_number.canonical_to_number(TARGET.result_value) * FEED.scale,0)),0)
        ,nvl(sum(decode(hr_gbnidir.NI_ELEMENT_ENTRY_VALUE(ASSACT.assignment_id, PACT.effective_date),
              'BN',fnd_number.canonical_to_number(TARGET.result_value) * FEED.scale,0)),0)
        ,nvl(sum(decode(hr_gbnidir.NI_ELEMENT_ENTRY_VALUE(ASSACT.assignment_id, PACT.effective_date),
              'BA',fnd_number.canonical_to_number(TARGET.result_value) * FEED.scale,0)),0)
        ,nvl(sum(decode(hr_gbnidir.NI_ELEMENT_ENTRY_VALUE(ASSACT.assignment_id, PACT.effective_date),
              'CN',fnd_number.canonical_to_number(TARGET.result_value) * FEED.scale,0)),0)
        ,nvl(sum(decode(hr_gbnidir.NI_ELEMENT_ENTRY_VALUE(ASSACT.assignment_id, PACT.effective_date),
              'CC',fnd_number.canonical_to_number(TARGET.result_value) * FEED.scale,0)),0)
        ,nvl(sum(decode(hr_gbnidir.NI_ELEMENT_ENTRY_VALUE(ASSACT.assignment_id, PACT.effective_date),
              'DC',fnd_number.canonical_to_number(TARGET.result_value) * FEED.scale,0)),0)
        ,nvl(sum(decode(hr_gbnidir.NI_ELEMENT_ENTRY_VALUE(ASSACT.assignment_id, PACT.effective_date),
              'EC',fnd_number.canonical_to_number(TARGET.result_value) * FEED.scale,0)),0)
        ,nvl(sum(decode(hr_gbnidir.NI_ELEMENT_ENTRY_VALUE(ASSACT.assignment_id, PACT.effective_date),
              'FM',fnd_number.canonical_to_number(TARGET.result_value) * FEED.scale,0)),0)
        ,nvl(sum(decode(hr_gbnidir.NI_ELEMENT_ENTRY_VALUE(ASSACT.assignment_id, PACT.effective_date),
              'GM',fnd_number.canonical_to_number(TARGET.result_value) * FEED.scale,0)),0)
        ,nvl(sum(decode(hr_gbnidir.NI_ELEMENT_ENTRY_VALUE(ASSACT.assignment_id, PACT.effective_date),
              'JN',fnd_number.canonical_to_number(TARGET.result_value) * FEED.scale,0)),0)
        ,nvl(sum(decode(hr_gbnidir.NI_ELEMENT_ENTRY_VALUE(ASSACT.assignment_id, PACT.effective_date),
              'JA',fnd_number.canonical_to_number(TARGET.result_value) * FEED.scale,0)),0)
        ,nvl(sum(decode(hr_gbnidir.NI_ELEMENT_ENTRY_VALUE(ASSACT.assignment_id, PACT.effective_date),
              'LC',fnd_number.canonical_to_number(TARGET.result_value) * FEED.scale,0)),0)
        ,nvl(sum(decode(hr_gbnidir.NI_ELEMENT_ENTRY_VALUE(ASSACT.assignment_id, PACT.effective_date),
              'SM',fnd_number.canonical_to_number(TARGET.result_value) * FEED.scale,0)),0)
        into g_st_ni_a_able , g_st_ni_ap_able , g_st_ni_b_able ,
             g_st_ni_bp_able, g_st_ni_c_able , g_st_ni_co_able ,
             g_st_ni_d_able , g_st_ni_e_able , g_st_ni_f_able ,
             g_st_ni_g_able , g_st_ni_j_able, g_st_ni_jp_able,
             g_st_ni_l_able, g_st_ni_s_able
        from
        pay_assignment_actions   BAL_ASSACT
       ,pay_payroll_actions      BACT
       ,per_time_periods         BPTP
       ,per_all_assignments_f    START_ASS
       ,per_all_assignments_f    ASS
       ,pay_assignment_actions   ASSACT
       ,pay_payroll_actions      PACT
       ,per_time_periods         PPTP
       ,pay_run_results          RR
       ,pay_run_result_values    TARGET
       ,pay_balance_feeds_f     FEED
where  BAL_ASSACT.assignment_action_id = p_assignment_action_id
and    BAL_ASSACT.payroll_action_id = BACT.payroll_action_id
and    FEED.balance_type_id    = g_ni_able_id + decode(RR.run_result_id, null, 0, 0)
and    nvl(TARGET.result_value,'0') <> '0'
and    FEED.input_value_id     = TARGET.input_value_id
and    TARGET.run_result_id    = RR.run_result_id
and    RR.assignment_action_id = ASSACT.assignment_action_id
and    ASSACT.payroll_action_id = PACT.payroll_action_id
and    PACT.effective_date between
          FEED.effective_start_date and FEED.effective_end_date
and    RR.status in ('P','PA')
and    BPTP.time_period_id = BACT.time_period_id
and    PPTP.time_period_id = PACT.time_period_id
and    START_ASS.assignment_id   = BAL_ASSACT.assignment_id
      and    ASS.person_id = START_ASS.person_id /* person level not pos */
      and    ASSACT.assignment_id = ASS.assignment_id
      and    BACT.effective_date between
           START_ASS.effective_start_date and START_ASS.effective_end_date
      and    PACT.effective_date between
           ASS.effective_start_date and ASS.effective_end_date
      and    PACT.effective_date >=
       /* find the latest td payroll transfer date - compare each of the */
       /* assignment rows with its predecessor looking for the payroll   */
       /* that had a different tax district at that date */
       ( select /*+ ORDERED INDEX (NASS PER_ASSIGNMENTS_F_PK,
                                   PASS PER_ASSIGNMENTS_F_PK,
                                   ROLL PAY_PAYROLLS_F_PK,
                                   FLEX HR_SOFT_CODING_KEYFLEX_PK,
                                   PROLL PAY_PAYROLLS_F_PK,
                                   PFLEX HR_SOFT_CODING_KEYFLEX_PK)
               USE_NL(NASS,PASS,ROLL,FLEX,PROLL,PFLEX) +*/
        nvl(max(NASS.effective_start_date), to_date('01-01-0001','DD-MM-YYYY'))
        from per_all_assignments_f  NASS
        ,per_all_assignments_f  PASS
        ,pay_all_payrolls_f     ROLL
        ,hr_soft_coding_keyflex FLEX
        ,pay_all_payrolls_f     PROLL
        ,hr_soft_coding_keyflex PFLEX
        where NASS.assignment_id = ASS.assignment_id
        and ROLL.payroll_id = NASS.payroll_id
        and NASS.effective_start_date between
                ROLL.effective_start_date and ROLL.effective_end_date
        and ROLL.soft_coding_keyflex_id = FLEX.soft_coding_keyflex_id
        and NASS.assignment_id = PASS.assignment_id
        and PASS.effective_end_date = (NASS.effective_start_date - 1)
        and NASS.effective_start_date <= BACT.effective_date
        and PROLL.payroll_id = PASS.payroll_id
        and NASS.effective_start_date between
                PROLL.effective_start_date and PROLL.effective_end_date
        and PROLL.soft_coding_keyflex_id = PFLEX.soft_coding_keyflex_id
        and NASS.payroll_id <> PASS.payroll_id
        and FLEX.segment1 <> PFLEX.segment1
                 )
      and exists ( select null from
           /* check that the current assignment tax districts match */
           pay_all_payrolls_f      BROLL
           ,hr_soft_coding_keyflex BFLEX
           ,pay_all_payrolls_f     PROLL
           ,hr_soft_coding_keyflex PFLEX
           where BACT.payroll_id = BROLL.payroll_id
           and   PACT.payroll_id = PROLL.payroll_id
           and   BFLEX.soft_coding_keyflex_id = BROLL.soft_coding_keyflex_id
           and   PFLEX.soft_coding_keyflex_id = PROLL.soft_coding_keyflex_id
           and   BACT.effective_date between
                      BROLL.effective_start_date and BROLL.effective_end_date
           and   BACT.effective_date between
                      PROLL.effective_start_date and PROLL.effective_end_date
           and   BFLEX.segment1 = PFLEX.segment1
           )
      and    PPTP.regular_payment_date >= l_stat_period_start
      and    PACT.effective_date >= l_start_director
      and    ASSACT.action_sequence <= BAL_ASSACT.action_sequence;
      --
      -- MAIN NI SELECTION, USE CORE BUE
      -- Set the l_balance_list table (once per assignment action) for this
      -- assignment action, then call the core BUE in batch mode.
      -- Then set the global balance values so that they remain the same for the
      -- current assignment. This uses the in out param l_balance_list.
      --
      set_balance_table(l_balance_list);
      --
      -- Call the Core BUE in BATCH MODE with the above set of defined balances,
      -- the resulting values will be stored in the globals as before.
      -- Exception handle this in case of NO DATA FOUND, which can be invoked
      -- by this call only if the Defined balance id is not found. These are
      -- all seeded.
      --
      BEGIN
         pay_balance_pkg.get_value(p_assignment_action_id => p_assignment_action_id,
                                   p_defined_balance_lst  => l_balance_list);
      EXCEPTION WHEN NO_DATA_FOUND THEN
         hr_utility.trace('No data found on call to pay_balance_pkg');
         null;
      END;
      --
      -- Set the Global variables to the values just retrieved from the bulk call to
      -- Core BUE.
      set_balance_values(l_balance_list);
      --
      -- Set the global assignment action for the next call
      --
      g_assignment_action_id := p_assignment_action_id;
   --
   END IF;
--
-- Calculate the value from the global-retrieval function
-- passing in the global name. This function is called
-- in all cases, as at this point all globals are set.
--
   l_balance_value := get_plsql_global(p_global_name);
--
   RETURN l_balance_value;
--
end NI_BALANCES_PER_DIR_TD_YTD;
--
--------------------------------------------------------------------------------
--
--                          DIRECTOR_WEEKS                                    --
--  fin how many weeks this assignment has been a director
--  1) since start of directorship
--  2) since tax district transfer
--  3) since the start of payroll year
--
--------------------------------------------------------------------------------
--

  function director_weeks
     (
      p_assignment_id  IN             number
     )
      return number is
--
-- N.B. When called from FastFormula, p_assignment_id
-- provided via context-set variables.
     l_start_of_director_date   date;
     l_weeks                    number;
     l_tax_year_start           date;
     l_effective_date           date;
--
Begin
--
  select effective_date
        into   l_effective_date
        from fnd_sessions
        where  session_id = userenv('sessionid');
--
--  find the previous 6-Apr
select to_date('06-04-' || to_char( to_number(
          to_char( l_effective_date,'YYYY'))
             +  decode(sign( l_effective_date - to_date('06-04-'
                 || to_char(l_effective_date,'YYYY'),'DD-MM-YYYY')),
           -1,-1,0)),'DD-MM-YYYY') finyear
    into l_tax_year_start
                from dual;
--
/* has this person been a director this financial year */

        select nvl(min(p.effective_start_date)
                  ,to_date('31-12-4712','dd-mm-yyyy'))
                  into l_start_of_director_date
                   from per_people_f p,
                        per_assignments_f ASS
                   where p.per_information2 = 'Y'
                   and ASS.assignment_id = p_assignment_id
                   and l_effective_date between
                         ASS.effective_start_date and ASS.effective_end_date
                   and ASS.person_id = P.person_id
                   and P.effective_start_date <= l_effective_date
                   and p.effective_end_date >= l_tax_year_start  ;
--
--  calculate number of weeks of directorship
select 52 - greatest(0,least(52,trunc(( l_start_of_director_date
                   - l_tax_year_start)/7)))
       into l_weeks
       from dual;
--
--
    RETURN l_weeks;
--
  end director_weeks;
--
-------------------------------------------------------------------------------
--  VALIDATE_USER_VALUE
--  check that a value is in the user table
  function validate_user_value
     ( p_user_table    IN             varchar2,
       p_user_column   IN             varchar2,
       p_user_value    IN             varchar2
     )
      return number is
--
        l_valid number        ;
Begin
--
--
-- initialize flag that indicates a valid value entered
-- l_valid := 0;
select nvl(max(1),0) into l_valid
  from pay_user_column_instances        CINST
        ,       pay_user_columns                   C
        ,       pay_user_rows                    R
        ,       pay_user_tables                    TAB
        where   TAB.user_table_name              = p_user_table
        and     C.user_column_name               = p_user_column
        and     fnd_number.canonical_to_number(CINST.value)
                     = fnd_number.canonical_to_number(p_user_value)
        and     C.user_table_id                  = TAB.user_table_id
        and     CINST.user_column_id             = C.user_column_id
        and     R.user_table_id                  = TAB.user_table_id
        and     TAB.user_key_units               = 'N'
        and     CINST.user_row_id                = R.user_row_id;
--
    RETURN l_valid;
--
  end validate_user_value;
--
-------------------------------------------------------------------------------
-- USER_VALUE_BY_LABEL
-- find a value from a user table by keying on the label column
--
  function user_value_by_label
     ( p_user_table    IN             varchar2,
       p_user_column   IN             varchar2,
       p_label         IN             varchar2
     )
      return number is
--
      l_value number;
Begin
l_value := 0;
begin
select fnd_number.canonical_to_number(CINST.value) into l_value from
  pay_user_column_instances        CINST
        , pay_user_column_instances       LABEL
        ,       pay_user_columns                CLABEL
        ,       pay_user_columns                   C
        ,       pay_user_rows                    R
        ,       pay_user_tables                    TAB
        where   TAB.user_table_name          = p_user_table
        and     C.user_column_name           = p_user_column
        and     C.user_table_id                  = TAB.user_table_id
        and     CINST.user_column_id             = C.user_column_id
        and     R.user_table_id                  = TAB.user_table_id
        and     TAB.user_key_units               = 'N'
        and     CINST.user_row_id                = R.user_row_id
        and     LABEL.value                  = p_label
        and     CLABEL.user_column_name          = 'LABEL'
        and     CLABEL.user_column_id            = LABEL.user_column_id
        and     CLABEL.user_table_id     = TAB.user_table_id
        and     LABEL.user_row_id                = R.user_row_id;
--
                exception when NO_DATA_FOUND then
                l_value := null;
end;

    RETURN l_value ;
--
  end user_value_by_label;
--
-------------------------------------------------------------------------------
--    USER_RANGE_BY_LABEL
--    find the high or low of the row identified by the LABEL
  function user_range_by_label
     ( p_user_table    IN             varchar2,
       p_high_or_low   IN             varchar2,
       p_label         IN             varchar2)
      return number is
--
      l_value number;
Begin
l_value := 0;
--
begin
select decode(substr(p_high_or_low,1,1),
         'H',fnd_number.canonical_to_number(R.ROW_HIGH_RANGE),
         fnd_number.canonical_to_number(R.row_low_range_or_name))
       into l_value from
          pay_user_column_instances       LABEL
        ,       pay_user_columns                CLABEL
        ,       pay_user_rows                    R
        ,       pay_user_tables                    TAB
        where   TAB.user_table_name              = p_user_table
        and     R.user_table_id                  = TAB.user_table_id
        and     TAB.user_key_units               = 'N'
        and     LABEL.value                      = p_label
        and     CLABEL.user_column_name          = 'LABEL'
        and     CLABEL.user_column_id            = LABEL.user_column_id
        and     CLABEL.user_table_id     = TAB.user_table_id
        and     LABEL.user_row_id                = R.user_row_id;
--
                exception when NO_DATA_FOUND then
                l_value := null;
end;
--
  RETURN l_value ;
--
  end user_range_by_label;
--
--
-------------------------------------------------------------------------------
--    NI_CO_RATE_FROM_CI_RATE
--    given the contracted in rate find the contracted out rate
  function ni_co_rate_from_ci_rate
       ( p_ci_rate         IN             number)
      return number is
--
      l_value number;
Begin
l_value := 0;
--
select min(fnd_number.canonical_to_number(CINST.value))
       into l_value from
  pay_user_column_instances        CINST
        , pay_user_column_instances       LABEL
        ,       pay_user_columns                CLABEL
        ,       pay_user_columns                   C
        ,       pay_user_rows                    R
        ,       pay_user_tables                    TAB
        where   upper(TAB.user_table_name)       = 'NI_ERS_WEEKLY'
        and     C.user_column_name               = 'C_ERS_RATE_CO'
        and     C.user_table_id                  = TAB.user_table_id
        and     CINST.user_column_id             = C.user_column_id
        and     R.user_table_id                  = TAB.user_table_id
        and     TAB.user_key_units               = 'N'
        and     CINST.user_row_id                = R.user_row_id
        and     fnd_number.canonical_to_number(LABEL.value)
                        = fnd_number.canonical_to_number(p_ci_rate)
        and     CLABEL.user_column_name          = 'C_ERS_RATE_CI'
        and     CLABEL.user_column_id            = LABEL.user_column_id
        and     CLABEL.user_table_id     = TAB.user_table_id
        and     LABEL.user_row_id                = R.user_row_id;
--
  RETURN l_value ;
--
  end ni_co_rate_from_ci_rate;
-------------------------------------------------------------------------------
--    NI_CM_RATE_FROM_CI_RATE
--    given the contracted in rate find the contracted out comp rate
  function ni_cm_rate_from_ci_rate
       ( p_ci_rate         IN             number)
      return number is
--
      l_value number;
Begin
l_value := 0;
--
select min(fnd_number.canonical_to_number(CINST.value))
       into l_value from
  pay_user_column_instances        CINST
        , pay_user_column_instances       LABEL
        ,       pay_user_columns                CLABEL
        ,       pay_user_columns                   C
        ,       pay_user_rows                    R
        ,       pay_user_tables                    TAB
        where   upper(TAB.user_table_name)       = 'NI_ERS_WEEKLY'
        and     C.user_column_name               = 'C_ERS_RATE_CM'
        and     C.user_table_id                  = TAB.user_table_id
        and     CINST.user_column_id             = C.user_column_id
        and     R.user_table_id                  = TAB.user_table_id
        and     TAB.user_key_units               = 'N'
        and     CINST.user_row_id                = R.user_row_id
        and     fnd_number.canonical_to_number(LABEL.value)           = fnd_number.canonical_to_number(p_ci_rate)
        and     CLABEL.user_column_name          = 'C_ERS_RATE_CI'
        and     CLABEL.user_column_id            = LABEL.user_column_id
        and     CLABEL.user_table_id     = TAB.user_table_id
        and     LABEL.user_row_id                = R.user_row_id;
--
  RETURN l_value ;
--
  end ni_cm_rate_from_ci_rate;
--
-------------------------------------------------------------------------------
--    STATUTORY_PERIOD_START_DATE ELEMENT
--    find the start of the statutory period for a assignment action
--      1) check the period type on the element entry
--      2) if not fornd get the period type of the payroll
--      3) find the statutory period start date
  function STATUTORY_PERIOD_START_DATE
       ( p_assignment_action_id IN number )
      return date is
--
        l_date                     date ;
        l_tax_year_start           date;
        f_year                     number(4);
        f_start_dd_mon             varchar2(7) := '06-04-';
        l_freq         number;
        l_effective_date           date;
        l_assignment_id            number;
        l_element_type_id          number;
        l_period_type_id           number;
        l_payroll_period_type      varchar2(30);
        l_period_type              varchar2(30);

-- Start bug#7670451

cursor csr_get_asg_period_type ( c_period_type_id number
                                ,c_assignment_id number
				,c_element_type_id number
				,c_effective_date date)
IS
        select ENT_PT.screen_entry_value
                from   pay_element_entry_values_f ENT_PT
                       ,pay_element_entries_f    ENT
                       ,pay_element_links_f      EL
                where ENT_PT.input_value_id + 0 = c_period_type_id
                and   ENT_PT.element_entry_id = ENT.element_entry_id
                and   ENT.assignment_id = c_assignment_id
                and   EL.element_type_id = c_element_type_id
                and   EL.element_link_id = ENT.element_link_id
                and   c_effective_date between
                      EL.effective_start_date and EL.effective_end_date
                and   c_effective_date between
                       ENT_PT.effective_start_date and ENT_PT.effective_end_date
                and   c_effective_date between
                      ENT.effective_start_date and ENT.effective_end_date;
-- End bug#7670451

Begin
if g_assignment_action_id = p_assignment_action_id then
        l_date := g_statutory_period_start_date;
          else
-- find the assignment, effective_date and payroll period type
  select    act.assignment_id,
      ptp.regular_payment_date,
                  ptp.period_type
             into l_assignment_id,
      l_effective_date,
      l_payroll_period_type
             from pay_assignment_actions act,
                pay_payroll_actions pact,
          per_time_periods ptp
             where   act.assignment_action_id = p_assignment_action_id
         and   pact.payroll_action_id = act.payroll_action_id
         and   ptp.time_period_id = pact.time_period_id;
--
-- Get the id's of the NI startup data
  select element_type_id
       into    l_element_type_id
       from pay_element_types_f
       where element_name = 'NI'
               and l_effective_date between
                             effective_start_date and effective_end_date;
--
  select input_value_id
       into    l_period_type_id
       from pay_input_values_f
       where name = 'Priority Period Type'
             and   element_type_id = l_element_type_id
             and l_effective_date between
                      effective_start_date and effective_end_date;
--
--
-- find the assignments period type
/*        select ENT_PT.screen_entry_value
                into l_period_type
                from   pay_element_entry_values_f ENT_PT
                       ,pay_element_entries_f    ENT
                       ,pay_element_links_f      EL
                where ENT_PT.input_value_id + 0 = l_period_type_id
                and   ENT_PT.element_entry_id = ENT.element_entry_id
                and   ENT.assignment_id = l_assignment_id
                and   EL.element_type_id = l_element_type_id
                and   EL.element_link_id = ENT.element_link_id
                and   l_effective_date between
                      EL.effective_start_date and EL.effective_end_date
                and   l_effective_date between
                       ENT_PT.effective_start_date and ENT_PT.effective_end_date
                and   l_effective_date between
                        ENT.effective_start_date and ENT.effective_end_date;*/
-- Start bug#7670451
-- Modified select query to cursor to avoid No data found error.
open csr_get_asg_period_type ( l_period_type_id
                              ,l_assignment_id
			      ,l_element_type_id
			      ,l_effective_date );

fetch csr_get_asg_period_type into l_period_type;
if csr_get_asg_period_type%notfound then
l_period_type := l_payroll_period_type;
end if;
close csr_get_asg_period_type;

-- End bug#7670451
--
  select ptpt.NUMBER_PER_FISCAL_YEAR
       into l_freq
       from
       per_time_period_types ptpt
       where   ptpt.period_type = nvl(l_period_type,l_payroll_period_type);
  --
  --
  -- Find the statutory start date
  --
  l_date := hr_gbbal.span_start(p_input_date  => l_effective_date,
                                p_frequency   => l_freq,
                                p_start_dd_mm => '06-04');
end if;
  --
RETURN l_date ;
--
--
end STATUTORY_PERIOD_START_DATE;
--
-------------------------------------------------------------------------------
--    STATUTORY_PERIOD_NUMBER
--    given a date find the statutory period
  function STATUTORY_PERIOD_NUMBER
       ( p_date in date ,
         p_period_type in varchar2 )
      return number is
--
        l_tax_year_start           date;
        f_year                     number(4);
        l_period                   number(2);
        f_start_dd_mon             varchar2(7) := '06-04-';

Begin
--
    f_year := to_number(to_char(p_date,'YYYY'));
--
   if p_date >= to_date(f_start_dd_mon||to_char(f_year),'DD-MM-YYYY')
    then
  l_tax_year_start := to_date(f_start_dd_mon||to_char(f_year),'DD-MM-YYYY');
    else
  l_tax_year_start := to_date(f_start_dd_mon||to_char(f_year -1),'DD-MM-YYYY');
    end if;
--
l_period := 0;
--
if p_period_type = 'W' then
   l_period := trunc((p_date - l_tax_year_start)/7) + 1;
   end if;
if p_period_type = 'CM' then
   l_period := trunc(months_between(p_date,l_tax_year_start))+ 1;
   end if;
--
  RETURN l_period ;
--
  end STATUTORY_PERIOD_NUMBER;
--
--------------------------------------------------------------------------------
--                          NI_ABLE_PER_PTD                                   --
--  find the NIable Pay balance for a particular category
--  This function is now obsolete so blanked out, and zero returned. This
--  is not called by any UK formula, package, report or form. The values
--  here can be obtained using ni_balances_per_ni_ptd.
--
--------------------------------------------------------------------------------
--

  function ni_able_per_ptd
     (
      p_assignment_action_id   IN    number ,
      p_category    IN     varchar2 ,
      p_pension          IN          varchar2
     )
      return number is
--
  begin
--
    RETURN 0;
--
  end ni_able_per_ptd;
--
--------------------------------------------------------------------------------
--
--                          Multiple Assignments                                --
--  How many assignments has this person got
--
--------------------------------------------------------------------------------
--

  function count_assignments
     (
      p_assignment_id  IN             number
     )
      return number is
--
-- N.B. When called from FastFormula, p_assignment_id
-- provided via context-set variables.
     l_effective_date           date;
     l_count                    number;
     l_person_id                number;
--
Begin
--
        select person_id
          into l_person_id
          from per_assignments
          where assignment_id = p_assignment_id;
--
        select count(1) into l_count
        from per_assignments a
        where a.person_id = l_person_id
        and a.payroll_id is not null;
--
--
    RETURN l_count;
--
  end count_assignments;
--
--------------------------------------------------------------------------------
--    COUNT_ASSIGNMENTS_ON_PAYROLL
--    count the number of live payroll assignments on a date
  function COUNT_ASSIGNMENTS_ON_PAYROLL
       ( p_date in date ,
         p_payroll_id in number )
      return number is
--
l_count number;

Begin
--
l_count := 0;

select count(1) into l_count
from per_assignments_f a, per_assignment_status_types st
where st.assignment_status_type_id = a.assignment_status_type_id
and p_date between a.effective_start_date and a.effective_end_date
and a.payroll_id = p_payroll_id
and st.pay_system_status = 'P';
--
--
  RETURN l_count ;
--
  end COUNT_ASSIGNMENTS_ON_PAYROLL;
--
-------------------------------------------------------------------------------
--    PERIOD_TYPE_CHECK
--    check that all the assignments are on the same period type
  function PERIOD_TYPE_CHECK
       ( p_assignment_id number )
      return number is
--
        l_count          number := 0;
        l_person_id      number;
        l_tax_reference  varchar2(20);
        l_effective_date   date;

Begin
--
        select effective_date
        into   l_effective_date
        from fnd_sessions
        where  session_id = userenv('sessionid');

--
begin
  select FLEX.segment1,a.person_id
                into l_tax_reference, l_person_id
                from  pay_payrolls_f p,
                per_assignments_f a,
                hr_soft_coding_keyflex FLEX
                where a.assignment_id = p_assignment_id
                and a.payroll_id = p.payroll_id
                and l_effective_date
                    between a.effective_start_date and a.effective_end_date
                and l_effective_date
                    between p.effective_start_date and p.effective_end_date
                and FLEX.soft_coding_keyflex_id = p.soft_coding_keyflex_id;
                exception when NO_DATA_FOUND then
                l_count := 0; return l_count;
end;
--
-- check how many period types you have for this person excluding those
-- reported and calculated under a different tax reference
begin
  select count(distinct ptpt.NUMBER_PER_FISCAL_YEAR)  into l_count
    from pay_payrolls_f p,
          per_assignments_f a,
          hr_soft_coding_keyflex FLEX,
                per_time_period_types ptpt
    where a.person_id = l_person_id
                and a.assignment_type = 'E'
    and a.payroll_id = p.payroll_id
                and nvl(hr_gbnidir.element_entry_value(
                      a.assignment_id, l_effective_date,
                     'NI','Priority Period Type') ,p.period_type)
                                       = ptpt.period_type
                and l_effective_date
                    between a.effective_start_date and a.effective_end_date
                and l_effective_date
                    between p.effective_start_date and p.effective_end_date
          and FLEX.soft_coding_keyflex_id = p.soft_coding_keyflex_id
          and FLEX.segment1 = l_tax_reference;
--
                exception when NO_DATA_FOUND then
                l_count := 0;
end;

  Return l_count;
--
--
  end PERIOD_TYPE_CHECK;
--
-------------------------------------------------------------------------------
--    PAYE_STAT_PERIOD_START_DATE
--    find the longest period that this person is on
  function PAYE_STAT_PERIOD_START_DATE
       ( p_assignment_action_id number )
      return date is
--
        l_assignment_id  number;
        l_person_id      number;
        l_tax_reference  varchar2(20);
        l_effective_date   date;
        l_date                     date ;
        l_tax_year_start           date;
        f_year                     number(4);
        f_start_dd_mon             varchar2(7) := '06-04-';
        l_freq         number;

Begin
--      find the effective date and assignment for this action
        select assignment_id,effective_date
        into   l_assignment_id,l_effective_date
        from   pay_assignment_actions BASSACT,
               pay_payroll_actions    BACT
        where  BASSACT.assignment_action_id = p_assignment_action_id
        and    BACT.payroll_action_id = BASSACT.payroll_action_id;
--
begin
-- 5907448
--      find the tax reference and person for this assignment
    select
    /*+
    ordered
    use_nl(a p flex)
    index(a per_assignments_f_pk)
    index(p pay_payrolls_f_pk)
    index(flex hr_soft_coding_keyflex_pk)
    */
          FLEX.segment1,a.person_id into l_tax_reference, l_person_id
    from  per_all_assignments_f a,
          pay_all_payrolls_f p,
          hr_soft_coding_keyflex FLEX
    where a.assignment_id = l_assignment_id
    and   a.payroll_id = p.payroll_id
    and   l_effective_date between a.effective_start_date and a.effective_end_date
    and   l_effective_date between p.effective_start_date and p.effective_end_date
    and   FLEX.soft_coding_keyflex_id(+) = p.soft_coding_keyflex_id;
end;
--
-- find the longest period you have for this person excluding those
-- reported and calculated under a different tax reference, unless
-- there is a priority period type, in which case use this frequency.
--
begin
-- 5907448
  select
  /*+
  ordered
  use_nl(a p flex ptpt)
  index(a per_assignments_f_n12)
  index(p pay_payrolls_f_pk)
  index(flex hr_soft_coding_keyflex_pk)
  index(ptpt per_time_period_types_pk)
  */
         min(ptpt.NUMBER_PER_FISCAL_YEAR) into l_freq
  from   per_all_assignments_f a,
         pay_all_payrolls_f p,
         hr_soft_coding_keyflex FLEX,
         per_time_period_types ptpt
  where a.person_id = l_person_id
  and   a.payroll_id = p.payroll_id
  and   nvl(hr_gbnidir.element_entry_value(a.assignment_id,
            l_effective_date,'NI','Priority Period Type'),
            p.period_type) = ptpt.period_type
  and   l_effective_date between a.effective_start_date and a.effective_end_date
  and   l_effective_date between p.effective_start_date and p.effective_end_date
  and   FLEX.soft_coding_keyflex_id = p.soft_coding_keyflex_id
  and   FLEX.segment1 = l_tax_reference;
--
                exception when NO_DATA_FOUND then
                l_freq := 52;
end;

Begin
--
    f_year := to_number(to_char(l_effective_date,'YYYY'));
--
   if l_effective_date >= to_date(f_start_dd_mon||to_char(f_year),'DD-MM-YYYY')
    then
  l_tax_year_start := to_date(f_start_dd_mon||to_char(f_year),'DD-MM-YYYY');
    else
  l_tax_year_start := to_date(f_start_dd_mon||to_char(f_year -1),'DD-MM-YYYY');
    end if;
--
l_date := l_effective_date;
-- if its weekly, fortnightly or lunar work out the offset in days
if l_freq in (52,26,13) then
   if l_freq = 52 then
       l_date := l_effective_date -  mod(l_effective_date - l_tax_year_start,7);
                  end if;
   if l_freq = 26 then
      l_date := l_effective_date -  mod(l_effective_date - l_tax_year_start,14);
                  end if;
   if l_freq = 13 then
      l_date := l_effective_date -  mod(l_effective_date - l_tax_year_start,28);
                  end if;
               else
-- for monthly based go back to the previous 6th Apr
 l_date := to_date('06-'||to_char(l_effective_date-5,'mm-yyyy'),'dd-mm-yyyy');
--
-- for quaters go back to the start of the quarter
        if l_freq = 4 then
          l_date := add_months(l_date,-
                    mod(months_between(l_date, l_tax_year_start),3));
                      end if;
-- for half year go back to the start of the half year
        if l_freq = 2 then
          l_date := add_months(l_date,-
                    mod(months_between(l_date, l_tax_year_start),6));
                      end if;
--
--
-- for annual period go back to the start of year
        if l_freq = 1 then
          l_date := l_tax_year_start;
                      end if;
               end if;

  Return l_date;
--
  end;
--
  end PAYE_STAT_PERIOD_START_DATE;
-------------------------------------------------------------------------------
--    ELEMENT_ENTRY_VALUE
  function ELEMENT_ENTRY_VALUE
       ( p_assignment_id number,
         p_effective_date date,
         p_element_name varchar2,
         p_input_name varchar2)
      return varchar2 is
--
        l_element_type_id          number;
        l_input_id                 number;
        l_value              varchar2(80);

Begin
--
-- Get the id's of the setup data
--
        SELECT  type_tl.element_type_id
        INTO    l_element_type_id
        FROM    pay_element_types_f_tl type_tl
        WHERE   EXISTS
        (SELECT  1
         FROM    pay_element_types_f type
         WHERE   type.element_type_id = type_tl.element_type_id
         AND     p_effective_date BETWEEN
                       type.effective_start_date AND type.effective_end_date)
         AND     type_tl.language = USERENV ('LANG')
         AND     type_tl.element_name = p_element_name;
--
  select iv.input_value_id
       into l_input_id
       from pay_input_values_f_tl IV_TL,
                  pay_input_values_f IV
       where iv_tl.input_value_id = iv.input_value_id
             and userenv('LANG') = iv_tl.language
             and iv_tl.name = p_input_name
             and iv.element_type_id = l_element_type_id
             and p_effective_date between
                      iv.effective_start_date and iv.effective_end_date;
--
--
-- find the assignments period type
        select max(ENT_PT.screen_entry_value)
                into l_value
                from   pay_element_entry_values_f ENT_PT
                       ,pay_element_entries_f    ENT
                       ,pay_element_links_f      EL
                where ENT_PT.input_value_id + 0 = l_input_id
                and   ENT_PT.element_entry_id = ENT.element_entry_id
                and   ENT.assignment_id = p_assignment_id
                and   EL.element_type_id = l_element_type_id
                and   EL.element_link_id = ENT.element_link_id
                and   p_effective_date between
                      EL.effective_start_date and EL.effective_end_date
                and   p_effective_date between
                       ENT_PT.effective_start_date and ENT_PT.effective_end_date
                and   p_effective_date between
                        ENT.effective_start_date and ENT.effective_end_date;
        return l_value;
  end ELEMENT_ENTRY_VALUE;
-------------------------------------------------------------------------------
--    NI_ELEMENT_ENTRY_VALUE
  function NI_ELEMENT_ENTRY_VALUE
       ( p_assignment_id number,
         p_effective_date date )
      return varchar2 is
--
        l_element_type_id          number;
        l_cat_input_id             number;
        l_pen_input_id             number;
        l_category              varchar2(80);
        l_pension               varchar2(80);
        l_value                 varchar2(80);

Begin
--
-- check if the assignments category has already been fetched otherwise fetch
if ( p_assignment_id <> nvl(g_assignment_id,-1) ) or
   ( p_effective_date <> nvl(g_effective_date,to_date('31-12-4712','dd-mm-yyyy')))
   then
--
-- Get the id's of the setup data
if g_ni_element_type_id is null then
  select element_type_id
       into    l_element_type_id
       from pay_element_types_f
       where element_name = 'NI'
               and p_effective_date between
                             effective_start_date and effective_end_date;
--
  select input_value_id
       into    l_cat_input_id
       from pay_input_values_f
       where name = 'Category'
             and   element_type_id = l_element_type_id
             and p_effective_date between
                      effective_start_date and effective_end_date;
--
  select input_value_id
       into    l_pen_input_id
       from pay_input_values_f
       where name = 'Pension'
             and   element_type_id = l_element_type_id
             and p_effective_date between
                      effective_start_date and effective_end_date;
    else
        l_element_type_id := g_ni_element_type_id;
        l_cat_input_id := g_cat_input_id;
  l_pen_input_id := g_pen_input_id;
    end if;
--
-- find the assignments category and pension
-- Match Element Entry Value start and end dates with
-- Element Entry start and end dates, as always the same.
-- (Performance fix).
        select max(decode(ENT_PT.input_value_id,l_cat_input_id,ENT_PT.screen_entry_value,null)),
               max(decode(ENT_PT.input_value_id,l_pen_input_id,ENT_PT.screen_entry_value,null))
                into l_category, l_pension
                from   pay_element_entry_values_f ENT_PT
                       ,pay_element_entries_f    ENT
                       ,pay_element_links_f      EL
                where ENT_PT.element_entry_id = ENT.element_entry_id
                and   ENT.assignment_id = p_assignment_id
                and   EL.element_type_id = l_element_type_id
                and   EL.element_link_id = ENT.element_link_id
                and   p_effective_date between
                      EL.effective_start_date and EL.effective_end_date
                and   p_effective_date between
                        ENT.effective_start_date and ENT.effective_end_date
                and   ENT.effective_start_date = ENT_PT.effective_start_date
                and   ENT.effective_end_date = ENT_PT.effective_end_date;
        --
        if l_category is null then l_category := ' ';
           end if;
        if l_pension is null then l_pension := ' ';
           end if;
-- filter out invalid category / pension combinations
        g_catpen := l_category||l_pension;
  g_assignment_id := p_assignment_id;
        g_effective_date := p_effective_date;
  end if;
  return g_catpen;

  end NI_ELEMENT_ENTRY_VALUE;
--------------------------------------------------------------------------------
--                          NI_BALANCES_PER_NI_PTD                                   --
--  get all of the NI balances for an assignment in one select
--
--------------------------------------------------------------------------------
--

  function NI_BALANCES_PER_NI_PTD
     (
      p_assignment_action_id   IN    number,
      p_global_name            IN    varchar2
     )
      return number is
--
-- N.B. When called from FastFormula, p_assignment_action_id
-- provided via context-set variables.
--
        l_effective_date          date;
        l_balance_type_id         number;
        l_element_type_id         number;
        l_category_input_id       number;
        l_pension_input_id        number;
        l_niable                  number;
        l_stat_period_start       date;
        l_balance_value           number;
        l_balance_list  pay_balance_pkg.t_balance_value_tab;
--
Begin
--
-- Set up the defined balances for all NI balances _PER_NI_PTD
  if g_defined_ptd_set = FALSE then
     hr_utility.trace('Calling set_defined_balances');
     set_defined_balances('_PER_NI_PTD');
  end if;
  hr_utility.trace('example defbal:'||to_char(g_comp_min_ers_defbal));
--
   if g_ni_able_id is null then
        select balance_type_id
        into    g_ni_able_id
        from pay_balance_types
        where balance_name = 'NIable Pay';
--
        select element_type_id
             into    g_ni_element_type_id
             from pay_element_types_f
             where element_name = 'NI'
             and sysdate between effective_start_date
                             and effective_end_date;
--
        select input_value_id
             into    g_cat_input_id
             from pay_input_values_f
             where name = 'Category'
             and   element_type_id = g_ni_element_type_id
             and sysdate between effective_start_date
                             and effective_end_date;
--
        select input_value_id
             into    g_pen_input_id
             from pay_input_values_f
             where name = 'Pension'
             and   element_type_id = g_ni_element_type_id
             and sysdate between effective_start_date
                             and effective_end_date;
   end if;
--
   IF g_assignment_action_id = p_assignment_action_id then
      l_stat_period_start := g_statutory_period_start_date;
   ELSE
      -- The assignment_action_id has changed from the last call or is null,
      -- calculate the balances via route-code before calling the global function.
      --
      l_stat_period_start := hr_gbnidir.STATUTORY_PERIOD_START_DATE(p_assignment_action_id);
      g_statutory_period_start_date := l_stat_period_start;
      g_assignment_action_id := p_assignment_action_id;
      hr_utility.trace('Assignment Action: '||to_char(g_assignment_action_id));
      --
      /* NI ABLE CURSOR  WHICH REMAINS DUE TO USING VARIANT ROUTE AND STYLE */
      /* OF SELECTION FROM BALANCE TABLES. */
        select /*+ ORDERED INDEX(BAL_ASSACT PAY_ASSIGNMENT_ACTIONS_PK,
                                       BACT PAY_PAYROLL_ACTIONS_PK,
                                       BPTP PER_TIME_PERIODS_PK,
                                       START_ASS PER_ASSIGNMENTS_F_PK,
                                       ASS PER_ASSIGNMENTS_N4,
                                       ASSACT PAY_ASSIGNMENT_ACTIONS_N51,
                                       PACT PAY_PAYROLL_ACTIONS_PK,
                                       PPTP PER_TIME_PERIODS_PK ,
                                       RR PAY_RUN_RESULTS_N50,
                                       TARGET PAY_RUN_RESULT_VALUES_PK,
                                       FEED PAY_BALANCE_FEEDS_F_UK2)
                    USE_NL(BAL_ASSACT,BACT,BPTP,START_ASS,ASS,ASSACT,PACT,PPTP,RR,TARGET,FEED) +*/
        nvl(sum(decode(hr_gbnidir.NI_ELEMENT_ENTRY_VALUE(ASSACT.assignment_id, PACT.effective_date),
              'AN',fnd_number.canonical_to_number(TARGET.result_value) * FEED.scale,0)),0)
        ,nvl(sum(decode(hr_gbnidir.NI_ELEMENT_ENTRY_VALUE(ASSACT.assignment_id, PACT.effective_date),
              'AA',fnd_number.canonical_to_number(TARGET.result_value) * FEED.scale,0)),0)
        ,nvl(sum(decode(hr_gbnidir.NI_ELEMENT_ENTRY_VALUE(ASSACT.assignment_id, PACT.effective_date),
              'BN',fnd_number.canonical_to_number(TARGET.result_value) * FEED.scale,0)),0)
        ,nvl(sum(decode(hr_gbnidir.NI_ELEMENT_ENTRY_VALUE(ASSACT.assignment_id, PACT.effective_date),
              'BA',fnd_number.canonical_to_number(TARGET.result_value) * FEED.scale,0)),0)
        ,nvl(sum(decode(hr_gbnidir.NI_ELEMENT_ENTRY_VALUE(ASSACT.assignment_id, PACT.effective_date),
              'CN',fnd_number.canonical_to_number(TARGET.result_value) * FEED.scale,0)),0)
        ,nvl(sum(decode(hr_gbnidir.NI_ELEMENT_ENTRY_VALUE(ASSACT.assignment_id, PACT.effective_date),
              'CC',fnd_number.canonical_to_number(TARGET.result_value) * FEED.scale,0)),0)
        ,nvl(sum(decode(hr_gbnidir.NI_ELEMENT_ENTRY_VALUE(ASSACT.assignment_id, PACT.effective_date),
              'DC',fnd_number.canonical_to_number(TARGET.result_value) * FEED.scale,0)),0)
        ,nvl(sum(decode(hr_gbnidir.NI_ELEMENT_ENTRY_VALUE(ASSACT.assignment_id, PACT.effective_date),
              'EC',fnd_number.canonical_to_number(TARGET.result_value) * FEED.scale,0)),0)
        ,nvl(sum(decode(hr_gbnidir.NI_ELEMENT_ENTRY_VALUE(ASSACT.assignment_id, PACT.effective_date),
              'FM',fnd_number.canonical_to_number(TARGET.result_value) * FEED.scale,0)),0)
        ,nvl(sum(decode(hr_gbnidir.NI_ELEMENT_ENTRY_VALUE(ASSACT.assignment_id, PACT.effective_date),
              'GM',fnd_number.canonical_to_number(TARGET.result_value) * FEED.scale,0)),0)
        ,nvl(sum(decode(hr_gbnidir.NI_ELEMENT_ENTRY_VALUE(ASSACT.assignment_id, PACT.effective_date),
              'JN',fnd_number.canonical_to_number(TARGET.result_value) * FEED.scale,0)),0)
        ,nvl(sum(decode(hr_gbnidir.NI_ELEMENT_ENTRY_VALUE(ASSACT.assignment_id, PACT.effective_date),
              'JA',fnd_number.canonical_to_number(TARGET.result_value) * FEED.scale,0)),0)
        ,nvl(sum(decode(hr_gbnidir.NI_ELEMENT_ENTRY_VALUE(ASSACT.assignment_id, PACT.effective_date),
              'LC',fnd_number.canonical_to_number(TARGET.result_value) * FEED.scale,0)),0)
        ,nvl(sum(decode(hr_gbnidir.NI_ELEMENT_ENTRY_VALUE(ASSACT.assignment_id, PACT.effective_date),
              'SM',fnd_number.canonical_to_number(TARGET.result_value) * FEED.scale,0)),0)
        into g_st_ni_a_able , g_st_ni_ap_able, g_st_ni_b_able ,
             g_st_ni_bp_able, g_st_ni_c_able , g_st_ni_co_able ,
             g_st_ni_d_able , g_st_ni_e_able , g_st_ni_f_able ,
             g_st_ni_g_able , g_st_ni_j_able, g_st_ni_jp_able,
             g_st_ni_l_able, g_st_ni_s_able
        from
        pay_assignment_actions   BAL_ASSACT
       ,pay_payroll_actions      BACT
       ,per_time_periods         BPTP
       ,per_all_assignments_f    START_ASS
       ,per_all_assignments_f    ASS
       ,pay_assignment_actions   ASSACT
       ,pay_payroll_actions      PACT
       ,per_time_periods         PPTP
       ,pay_run_results          RR
       ,pay_run_result_values    TARGET
       ,pay_balance_feeds_f     FEED
      where  BAL_ASSACT.assignment_action_id = p_assignment_action_id
      and    BAL_ASSACT.payroll_action_id = BACT.payroll_action_id
      and    FEED.balance_type_id    = g_ni_able_id + decode(RR.run_result_id, null, 0, 0)
      and    nvl(TARGET.result_value,'0') <> '0'
      and    FEED.input_value_id     = TARGET.input_value_id
      and    TARGET.run_result_id    = RR.run_result_id
      and    RR.assignment_action_id = ASSACT.assignment_action_id
      and    ASSACT.payroll_action_id = PACT.payroll_action_id
      and    PACT.effective_date between
          FEED.effective_start_date and FEED.effective_end_date
      and    RR.status in ('P','PA')
      and    BPTP.time_period_id = BACT.time_period_id
      and    PPTP.time_period_id = PACT.time_period_id
      and    START_ASS.assignment_id   = BAL_ASSACT.assignment_id
      and    ASS.period_of_service_id = START_ASS.period_of_service_id
      and    ASSACT.assignment_id = ASS.assignment_id
      and    BACT.effective_date between
           START_ASS.effective_start_date and START_ASS.effective_end_date
      and    PACT.effective_date between
           ASS.effective_start_date and ASS.effective_end_date
      and    PACT.effective_date >=
       /* find the latest td payroll transfer date - compare each of the */
       /* assignment rows with its predecessor looking for the payroll   */
       /* that had a different tax district at that date */
       ( select /*+ ORDERED INDEX (NASS PER_ASSIGNMENTS_F_PK,
                                   PASS PER_ASSIGNMENTS_F_PK,
                                   ROLL PAY_PAYROLLS_F_PK,
                                   FLEX HR_SOFT_CODING_KEYFLEX_PK,
                                   PROLL PAY_PAYROLLS_F_PK,
                                   PFLEX HR_SOFT_CODING_KEYFLEX_PK)
               USE_NL(NASS,PASS,ROLL,FLEX,PROLL,PFLEX) +*/
        nvl(max(NASS.effective_start_date), to_date('01-01-0001','DD-MM-YYYY'))
        from per_all_assignments_f  NASS
        ,per_all_assignments_f  PASS
        ,pay_all_payrolls_f     ROLL
        ,hr_soft_coding_keyflex FLEX
        ,pay_all_payrolls_f     PROLL
        ,hr_soft_coding_keyflex PFLEX
        where NASS.assignment_id = ASS.assignment_id
        and ROLL.payroll_id = NASS.payroll_id
        and NASS.effective_start_date between
                ROLL.effective_start_date and ROLL.effective_end_date
        and ROLL.soft_coding_keyflex_id = FLEX.soft_coding_keyflex_id
        and NASS.assignment_id = PASS.assignment_id
        and PASS.effective_end_date = (NASS.effective_start_date - 1)
        and NASS.effective_start_date <= BACT.effective_date
        and PROLL.payroll_id = PASS.payroll_id
        and NASS.effective_start_date between
                PROLL.effective_start_date and PROLL.effective_end_date
        and PROLL.soft_coding_keyflex_id = PFLEX.soft_coding_keyflex_id
        and NASS.payroll_id <> PASS.payroll_id
        and FLEX.segment1 <> PFLEX.segment1
                 )
      and exists ( select null from
           /* check that the current assignment tax districts match */
           pay_all_payrolls_f      BROLL
           ,hr_soft_coding_keyflex BFLEX
           ,pay_all_payrolls_f     PROLL
           ,hr_soft_coding_keyflex PFLEX
           where BACT.payroll_id = BROLL.payroll_id
           and   PACT.payroll_id = PROLL.payroll_id
           and   BFLEX.soft_coding_keyflex_id = BROLL.soft_coding_keyflex_id
           and   PFLEX.soft_coding_keyflex_id = PROLL.soft_coding_keyflex_id
           and   BACT.effective_date between
                      BROLL.effective_start_date and BROLL.effective_end_date
           and   BACT.effective_date between
                      PROLL.effective_start_date and PROLL.effective_end_date
           and   BFLEX.segment1 = PFLEX.segment1
           )
      and    PPTP.regular_payment_date >= l_stat_period_start
      and    ASSACT.action_sequence <= BAL_ASSACT.action_sequence;
      --
      -- MAIN NI SELECTION, USE CORE BUE
      -- Set the l_balance_list table (once per assignment action) for this
      -- assignment action, then call the core BUE in batch mode.
      -- Then set the global balance values so that they remain the same for the
      -- current assignment. This uses the in out param l_balance_list, which
      -- stores the defined balances for all NI PER_NI_PTD balances.
      --
      set_balance_table(l_balance_list);
      --
      -- Call the Core BUE in BATCH MODE with the above set of defined balances,
      -- the resulting values will be stored in the globals as before.
      -- Exception handle this in case of NO DATA FOUND, which can be invoked
      -- by this call only if the Defined balance id is not found. These are
      -- all seeded so the exception should not happen but placed as a precaution.
      --
      BEGIN
         pay_balance_pkg.get_value(p_assignment_action_id => p_assignment_action_id,
                                   p_defined_balance_lst  => l_balance_list);
      EXCEPTION WHEN NO_DATA_FOUND THEN
         hr_utility.trace('No data found on call to pay_balance_pkg');
         null;
      END;
      --
      -- Set the Global variables to the values just retrieved from the bulk
      -- call to Core BUE.
      set_balance_values(l_balance_list);
--
  END IF;
--
-- Calculate the value from the global-retrieval function
-- passing in the global name. This function is called
-- in all cases, as at this point all globals are set.
--
   l_balance_value := get_plsql_global(p_global_name);
--
--
   RETURN l_balance_value;
--
end NI_BALANCES_PER_NI_PTD;
--
----------------------------------------------------------------------------
-- Function STATUTORY_PERIOD_DATE_MODE.
-- Description: This function takes in an assignment ID
--              and effective date from a Date Mode query
--    on a Person level Period to Date balance.
-- The steps are: 1. Find the start of the statutory period for
--                   the assignment as at the effective date.
--                2. Check the period type on the element entry
--                3. If not found get the period type of the payroll
--                4. Return the statutory period end date.
--
----------------------------------------------------------------------------
--
function statutory_period_date_mode (p_assignment_id  IN NUMBER,
             p_effective_date IN DATE) RETURN DATE IS
--
  l_period_regular_payment_date date;
  l_time_period_type varchar2(30);
  l_time_period_start_date date;
  l_time_period_end_date date;
  l_element_type_id number;
  l_input_value_id number;
  l_asg_period_type varchar2(30);
  l_frequency number;
  l_f_year number;
  l_f_start_dd_mon             varchar2(7) := '06-04-';
  l_tax_year_start date;
  l_date date;
--
  cursor get_time_period_info (c_assignment_id number,
             c_effective_date date) is
  select ptp.regular_payment_date,
   ptp.period_type,
   ptp.start_date,
   ptp.end_date
  from per_assignments_f   paf,
       per_time_periods ptp
  where paf.assignment_id = c_assignment_id
  and   ptp.payroll_id = paf.payroll_id
  and   c_effective_date between
        ptp.start_date and ptp.end_date
  and   c_effective_date between
  paf.effective_start_date and paf.effective_end_date;
--
  cursor ni_element_type (c_effective_date date) is
  select pet.element_type_id,
   piv.input_value_id
  from pay_input_values_f piv,
       pay_element_types_f pet
  where pet.element_name = 'NI'
  and c_effective_date between
      pet.effective_start_date and pet.effective_end_date
  and piv.element_type_id = pet.element_type_id
  and piv.name = 'Priority Period Type'
  and c_effective_date between
      piv.effective_start_date and piv.effective_end_date;

  cursor get_asg_period_type (c_period_type_id number,
            c_assignment_id number,
            c_element_type_id number,
            c_effective_date date) is
  select ENT_PT.screen_entry_value
  from   pay_element_entry_values_f ENT_PT
        ,pay_element_entries_f    ENT
        ,pay_element_links_f      EL
  where ENT_PT.input_value_id + 0 = c_period_type_id
  and   ENT_PT.element_entry_id = ENT.element_entry_id
  and   ENT.assignment_id  = c_assignment_id
  and   EL.element_type_id = c_element_type_id
  and   EL.element_link_id = ENT.element_link_id
  and   c_effective_date between
        EL.effective_start_date and EL.effective_end_date
  and   c_effective_date between
        ENT_PT.effective_start_date and ENT_PT.effective_end_date
  and   c_effective_date between
        ENT.effective_start_date and ENT.effective_end_date;
--
  cursor get_frequency (c_asg_period_type varchar2,
      c_payroll_period_type varchar2) is
  select ptpt.number_per_fiscal_year
  from   per_time_period_types ptpt
  where  ptpt.period_type = nvl(c_asg_period_type, c_payroll_period_type);
--
begin
--
-- fetch the time period info for the assignment
-- as at the effective date
--
  open get_time_period_info(p_assignment_id,
          p_effective_date);
  fetch get_time_period_info into l_period_regular_payment_date,
          l_time_period_type,
          l_time_period_start_date,
          l_time_period_end_date;
  close get_time_period_info;
--
-- Get the element type ID of NI element as at the
-- regular payment date of the time period above.
--
  open ni_element_type(l_period_regular_payment_date);
  fetch ni_element_type into l_element_type_id, l_input_value_id;
  close ni_element_type;
--
-- Get the assignment period type from the date effective
-- element tables as at the obtained regular payment date of the
-- time period.
--
  open get_asg_period_type(l_input_value_id,
                           p_assignment_id,
         l_element_type_id,
         l_period_regular_payment_date);
  fetch get_asg_period_type into l_asg_period_type;
  close get_asg_period_type;
--
-- Get the frequency from the number per fiscal year of the time
-- period, using an nvl of the assignment period type and (payroll)
-- time period type.
--
  open get_frequency(l_asg_period_type, l_time_period_type);
  fetch get_frequency into l_frequency;
  close get_frequency;
  --
  --
  -- Find the statutory end date
  --
  l_date := hr_gbbal.span_end(p_input_date  => l_period_regular_payment_date,
                  p_frequency   => l_frequency,
                  p_start_dd_mm => '06-04-');
--
--
-- Note: This function is used for date mode expiry checking
--       of person level PTD balances, so the end of the statutory
--       time period is returned so that it can be checked against the
--       effective date of the query.
--
RETURN l_date;
--
end statutory_period_date_mode;
--
----------------------------------------------------------------------------
-- Function NIABLE_BANDS.
-- Description: Code externalized from NI_PERSON and NI_DIRECTOR formulas
--              to save source text space in those.
--              It takes in the NIABLE thresholds, Niable for the Person and
--              NI Able for the Person within this category.
--              Outputs the NIABLE within each band
--              As the EET is obsolete from 6th April 2001, the formula
--              will pass in a zero for the EET value from the Global,
--              and return a zero for the out param. This does not affect
--              the running of the function and will be removed in
--              April 2002.
--              Sep 02 - Removed all EET calculations.
--
----------------------------------------------------------------------------
--
  function niable_bands (L_NIABLE      IN NUMBER,
                         L_NI_CAT_ABLE IN NUMBER,
                         L_TOT_NIABLE  IN NUMBER,
                         L_LEL         IN NUMBER,
                         L_EET         IN NUMBER,
                         L_ET          IN NUMBER,
                         L_UEL         IN NUMBER,
                         NI_ABLE_LEL   IN OUT NOCOPY NUMBER,
                         NI_ABLE_EET   IN OUT NOCOPY NUMBER,
                         NI_ABLE_ET    IN OUT NOCOPY NUMBER,
                         NI_ABLE_UEL   IN OUT NOCOPY NUMBER,
                         NI_UPPER      IN OUT NOCOPY NUMBER,
                         NI_LOWER      IN OUT NOCOPY NUMBER
                                       ) RETURN NUMBER IS

-- L_NIABLE: earnings subject to NI for the current category and higher priority categories
-- L_NI_CAT_ABLE: earnings subject to NI for the current category
-- L_TOT_NIABLE:  total earnings subject to NI
-- L_LEL: lower earnings threshold for the period (period in this case may be Annual or pro-rated
--        annual for directors.  Priority Processing Period for multiple assignments.
-- L_ET:  employers earnings threshold for the period.
-- L_UEL: upper earnings threshold
NI_ABLE NUMBER;
begin
 hr_utility.set_location('hr_gbnidir.niable_bands', 10);
NI_ABLE      := 0; -- niable up to the UEL for current category
NI_ABLE_LEL  := 0; -- niable up to the LEL for current category if niable is >LEL
NI_ABLE_EET  := 0; -- Now obsolete, set to zero.
NI_ABLE_ET   := 0; -- niable between the LEL and the ET for category
NI_ABLE_UEL  := 0; -- niable bwteen the ET and UEL for category
NI_UPPER     := 0; -- earnings above the UEL for category, ie Above UEL (AUEL).
NI_LOWER     := 0; -- earnings below the LEL for category
if l_ni_cat_able > 0 then
        hr_utility.set_location('hr_gbnidir.niable_bands', 20);
        NI_LOWER  := greatest(0,(least(l_lel,l_niable)
                   - (l_niable - l_ni_cat_able)));
--  if Employees total earnings subject to NI is over the Lower Earnings limit
--  work out how much of those LEL earnings are for Niable for the category
--  being calculated.  Each Category is calculated in priority order so the
--  highest priority category will attract the LEL earnings.  Subsequent
--  categories start their calculating at higher thresholds as NIABLE already
--  calculated is taken into account.
  if  l_tot_niable > l_lel then
        hr_utility.set_location('hr_gbnidir.niable_bands', 20);
    ni_able_lel := ni_lower;
    --
    ni_able_et  := greatest(0,((least(l_et,l_niable)) -
                    (greatest(l_lel,(l_niable - l_ni_cat_able)))));
    --
    ni_able_uel := greatest(0,((least(l_uel,l_niable)) -
               (greatest(l_et,(l_niable - l_ni_cat_able)))));
    ni_upper    := greatest(0,(l_niable - (greatest(l_uel,
                                    (l_niable - l_ni_cat_able)))));
    ni_able     := ni_able_lel + ni_able_et + ni_able_uel;
    hr_utility.trace('NIABLE_BANDS  ni_able_lel='||to_char(ni_able_lel)||
                                  ' ni_able_et='||to_char(ni_able_et)||
                                  ' ni_able_uel='||to_char(ni_able_uel)||
                                  ' ni_upper='||to_char(ni_upper)||
                                  ' ni_lower='||to_char(ni_lower)||
                                  ' ni_able='||to_char(ni_able));
  end if;
end if;

return NI_ABLE;
--
end niable_bands;

--
----------------------------------------------------------------------------
-- Function NIABLE_BANDS.
-- Description: Over Loaded function Added for UAP EOY 08/09
-- Bug 7312374
----------------------------------------------------------------------------
  function niable_bands (L_NIABLE      IN NUMBER,
                         L_NI_CAT_ABLE IN NUMBER,
                         L_TOT_NIABLE  IN NUMBER,
                         L_LEL         IN NUMBER,
                         L_EET         IN NUMBER,
                         L_ET          IN NUMBER,
                         L_UAP         IN NUMBER, -- EOY 08/09
                         L_UEL         IN NUMBER,
                         NI_ABLE_LEL   IN OUT NOCOPY NUMBER,
                         NI_ABLE_EET   IN OUT NOCOPY NUMBER,
                         NI_ABLE_ET    IN OUT NOCOPY NUMBER,
                         NI_ABLE_UAP   IN OUT NOCOPY NUMBER, -- EOY 08/09
                         NI_ABLE_UEL   IN OUT NOCOPY NUMBER,
                         NI_UPPER      IN OUT NOCOPY NUMBER,
                         NI_LOWER      IN OUT NOCOPY NUMBER
                                       ) RETURN NUMBER IS

-- L_NIABLE: earnings subject to NI for the current category and higher priority categories
-- L_NI_CAT_ABLE: earnings subject to NI for the current category
-- L_TOT_NIABLE:  total earnings subject to NI
-- L_LEL: lower earnings threshold for the period (period in this case may be Annual or pro-rated
--        annual for directors.  Priority Processing Period for multiple assignments.
-- L_ET:  employers earnings threshold for the period.
-- L_UEL: upper earnings threshold
-- L_UAP: upper accrual point

NI_ABLE NUMBER;
begin
 hr_utility.set_location('hr_gbnidir.niable_bands', 10);
NI_ABLE      := 0; -- niable up to the UEL for current category
NI_ABLE_LEL  := 0; -- niable up to the LEL for current category if niable is >LEL
NI_ABLE_EET  := 0; -- Now obsolete, set to zero.
NI_ABLE_ET   := 0; -- niable between the LEL and the ET for category
NI_ABLE_UAP  := 0; -- niable between the ET and the UAP for category
NI_ABLE_UEL  := 0; -- niable between the UAP and UEL for category
NI_UPPER     := 0; -- earnings above the UEL for category, ie Above UEL (AUEL).
NI_LOWER     := 0; -- earnings below the LEL for category
if l_ni_cat_able > 0 then
        hr_utility.set_location('hr_gbnidir.niable_bands', 20);
        NI_LOWER  := greatest(0,(least(l_lel,l_niable)
                   - (l_niable - l_ni_cat_able)));
--  if Employees total earnings subject to NI is over the Lower Earnings limit
--  work out how much of those LEL earnings are for Niable for the category
--  being calculated.  Each Category is calculated in priority order so the
--  highest priority category will attract the LEL earnings.  Subsequent
--  categories start their calculating at higher thresholds as NIABLE already
--  calculated is taken into account.
  if  l_tot_niable > l_lel then
        hr_utility.set_location('hr_gbnidir.niable_bands', 20);
    ni_able_lel := ni_lower;
    --
    ni_able_et  := greatest(0,((least(l_et,l_niable)) -
                    (greatest(l_lel,(l_niable - l_ni_cat_able)))));
    --
    --EOY 08/09 Begin
    ni_able_uap := greatest(0,((least(l_uap,l_niable)) -
               (greatest(l_et,(l_niable - l_ni_cat_able)))));

    ni_able_uel := greatest(0,((least(l_uel,l_niable)) -
               (greatest(l_uap,(l_niable - l_ni_cat_able)))));
    --EOY 08/09 End
    ni_upper    := greatest(0,(l_niable - (greatest(l_uel,
                                    (l_niable - l_ni_cat_able)))));
    --EOY 08/09 Begin
    --ni_able     := ni_able_lel + ni_able_et + ni_able_uel;
    ni_able     := ni_able_lel + ni_able_et + ni_able_uap + ni_able_uel;
    --EOY 08/09 End
    hr_utility.trace('NIABLE_BANDS  ni_able_lel='||to_char(ni_able_lel)||
                                  ' ni_able_et='||to_char(ni_able_et)||
                                  ' ni_able_uap='||to_char(ni_able_uap)||
                                  ' ni_able_uel='||to_char(ni_able_uel)||
                                  ' ni_upper='||to_char(ni_upper)||
                                  ' ni_lower='||to_char(ni_lower)||
                                  ' ni_able='||to_char(ni_able));
  end if;
end if;

return NI_ABLE;
--
end niable_bands;

end hr_gbnidir;

/
