--------------------------------------------------------
--  DDL for Package Body PAY_JP_ISDF_SS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_JP_ISDF_SS_PKG" as
/* $Header: pyjpisfs.pkb 120.9.12010000.2 2009/10/14 13:38:13 keyazawa ship $ */
--
c_package  constant varchar2(30) := 'pay_jp_isdf_ss_pkg.';
g_debug    boolean := hr_utility.debug_enabled;
--
c_isdf_ins_elm          constant varchar2(80) := 'YEA_INS_PREM_EXM_DECLARE_INFO';
c_isdf_ins_elm_id       constant number := hr_jp_id_pkg.element_type_id(c_isdf_ins_elm, null, 'JP');
c_life_gen_iv_id        constant number := hr_jp_id_pkg.input_value_id(c_isdf_ins_elm_id, 'GEN_LIFE_INS_PREM');
c_life_pens_iv_id       constant number := hr_jp_id_pkg.input_value_id(c_isdf_ins_elm_id, 'INDIVIDUAL_PENSION_PREM');
c_nonlife_long_iv_id    constant number := hr_jp_id_pkg.input_value_id(c_isdf_ins_elm_id, 'LONG_TERM_NONLIFE_INS_PREM');
c_nonlife_short_iv_id   constant number := hr_jp_id_pkg.input_value_id(c_isdf_ins_elm_id, 'SHORT_TERM_NONLIFE_INS_PREM');
c_earthquake_iv_id      constant number := hr_jp_id_pkg.input_value_id(c_isdf_ins_elm_id, 'EARTHQUAKE_INS_PREM');
--
c_isdf_is_elm           constant varchar2(80) := 'YEA_INS_PREM_SPOUSE_SP_EXM_INFO';
c_isdf_is_elm_id        constant number := hr_jp_id_pkg.element_type_id(c_isdf_is_elm, null, 'JP');
c_social_iv_id          constant number := hr_jp_id_pkg.input_value_id(c_isdf_is_elm_id, 'DECLARE_SI_PREM');
c_mutual_aid_iv_id      constant number := hr_jp_id_pkg.input_value_id(c_isdf_is_elm_id, 'SMALL_COMPANY_MUTUAL_AID_PREM');
c_spouse_iv_id          constant number := hr_jp_id_pkg.input_value_id(c_isdf_is_elm_id, 'SPOUSE_INCOME');
c_national_pens_iv_id   constant number := hr_jp_id_pkg.input_value_id(c_isdf_is_elm_id, 'NATIONAL_PENSION_PREM');
--
c_com_calc_dpnt_elm_id  constant number := hr_jp_id_pkg.element_type_id('YEA_DEP_EXM_PROC', null, 'JP');
c_sp_type_iv_id         constant number := hr_jp_id_pkg.input_value_id(c_com_calc_dpnt_elm_id, 'SPOUSE_TYPE');
c_widow_type_iv_id      constant number := hr_jp_id_pkg.input_value_id(c_com_calc_dpnt_elm_id, 'WIDOW_TYPE');
--
c_com_itax_info_elm_id  constant number := hr_jp_id_pkg.element_type_id('COM_ITX_INFO', null, 'JP');
c_tax_type_iv_id        constant number := hr_jp_id_pkg.input_value_id(c_com_itax_info_elm_id, 'ITX_TYPE');
--
c_st_upd_date_2007      constant date := to_date('2007/01/01','YYYY/MM/DD');
--
-- -------------------------------------------------------------------------
-- check_submission_period
-- -------------------------------------------------------------------------
function check_submission_period(
  p_action_information_id in number)
return date
is
--
  l_submission_date date;
--
  cursor csr_pact
  is
  select /*+ ORDERED */
         pact.submission_period_status,
         pact.submission_start_date,
         pact.submission_end_date
  from   pay_jp_isdf_assact_v assact,
         pay_assignment_actions paa,
         pay_jp_isdf_pact_v pact
  where  assact.action_information_id = p_action_information_id
  and    paa.assignment_action_id = assact.assignment_action_id
  and    pact.payroll_action_id = paa.payroll_action_id;
--
  l_csr_pact csr_pact%rowtype;
--
begin
--
  open csr_pact;
  fetch csr_pact into l_csr_pact;
  close csr_pact;
--
  if l_csr_pact.submission_period_status = 'C' then
    fnd_message.set_name('PAY','PAY_JP_DEF_PERIOD_CLOSED');
    fnd_message.raise_error;
  end if;
--
  l_submission_date := sysdate;
--
  if l_submission_date < nvl(l_csr_pact.submission_start_date,l_submission_date) then
    fnd_message.set_name('PAY','PAY_JP_DEF_PERIOD_NOT_STARTED');
    fnd_message.raise_error;
  end if;
--
  if l_submission_date > nvl(l_csr_pact.submission_end_date,l_submission_date) then
    fnd_message.set_name('PAY','PAY_JP_DEF_PERIOD_EXPIRED');
    fnd_message.raise_error;
  end if;
--
return l_submission_date;
--
end check_submission_period;
--
-- -------------------------------------------------------------------------
-- get_spouse_type
-- -------------------------------------------------------------------------
function get_spouse_type(
  p_assignment_id        in number,
  p_effective_date       in date,
  p_payroll_id           in number)
return varchar2
is
--
  l_spouse_type pay_element_entry_values_f.screen_entry_value%type;
  l_tax_type pay_element_entry_values_f.screen_entry_value%type;
  l_bg_itax_dpnt_ref_type varchar2(150);
--
  cursor csr_bg_itax_dpnt_ref_type
  is
  select /*+ ORDERED */
         nvl(nvl(pp.prl_information1, hoi.org_information2),'CTR_EE')
  from   pay_all_payrolls_f          pp,
         hr_organization_information hoi
  where  pp.payroll_id = p_payroll_id
  and    p_effective_date
         between pp.effective_start_date and pp.effective_end_date
  and    hoi.organization_id(+) = pp.business_group_id
  and    hoi.org_information_context(+) = 'JP_BUSINESS_GROUP_INFO';
--
begin
--
  l_spouse_type := pay_jp_balance_pkg.get_entry_value_char(c_sp_type_iv_id,p_assignment_id,p_effective_date);
--
  if l_spouse_type is null then
  --
    open csr_bg_itax_dpnt_ref_type;
    fetch csr_bg_itax_dpnt_ref_type into l_bg_itax_dpnt_ref_type;
    close csr_bg_itax_dpnt_ref_type;
  --
    if l_bg_itax_dpnt_ref_type = 'CEI' then
     --
      l_tax_type := pay_jp_balance_pkg.get_entry_value_char(c_tax_type_iv_id,p_assignment_id,p_effective_date);
      l_spouse_type := per_jp_ctr_utility_pkg.get_itax_spouse_type(p_assignment_id,l_tax_type,p_effective_date);
     --
    end if;
  --
  end if;
--
return l_spouse_type;
--
end get_spouse_type;
--
-- -------------------------------------------------------------------------
-- get_widow_type
-- -------------------------------------------------------------------------
function get_widow_type(
  p_assignment_id        in number,
  p_effective_date       in date)
return varchar2
is
  l_widow_type pay_element_entry_values_f.screen_entry_value%type;
begin
--
  l_widow_type := pay_jp_balance_pkg.get_entry_value_char(c_widow_type_iv_id,p_assignment_id,p_effective_date);
--
return l_widow_type;
--
end get_widow_type;
--
-- -------------------------------------------------------------------------
-- set_form_pg_prompt
-- -------------------------------------------------------------------------
procedure set_form_pg_prompt(
  p_action_information_id in number)
is
--
  l_proc varchar2(80) := c_package||'get_formpg_prompt';
--
  l_payroll_action_id number;
  l_business_group_id number;
  l_effective_date date;
--
  l_legislation_code varchar2(2);
  l_rate    pay_user_column_instances_f.value%type;
  l_add_adj pay_user_column_instances_f.value%type;
  l_lnonlife_calc3 pay_user_column_instances_f.value%type;
  l_snonlife_calc3 pay_user_column_instances_f.value%type;
  l_sp_calc_other_inc_calc_rate pay_user_column_instances_f.value%type;
  l_dct_cnt number := 0;
  l_nonlife_max pay_user_column_instances_f.value%type;
  l_nonlife_max_2007 pay_user_column_instances_f.value%type;
--
  type t_sp_calc_rec is record(
    range_a pay_user_rows_f.row_low_range_or_name%type,
    range_b pay_user_rows_f.row_low_range_or_name%type,
    val     pay_user_column_instances_f.value%type);
  type t_sp_calc_tbl is table of t_sp_calc_rec index by binary_integer;
  l_sp_calc_tbl t_sp_calc_tbl;
--
  cursor csr_pact
  is
  select /* +ORDERED */
         ppa.payroll_action_id,
         ppa.business_group_id,
         ppa.effective_date
  from   pay_jp_isdf_assact_v pjia,
         pay_assignment_actions paa,
         pay_payroll_actions ppa
  where  pjia.action_information_id = p_action_information_id
  and    paa.assignment_action_id = pjia.assignment_action_id
  and    ppa.payroll_action_id = paa.payroll_action_id;
--
  cursor csr_udt_row(
           p_udt_name       in varchar2,
           p_effective_date in date)
  is
  select /* +ORDERED */
         put.user_table_id,
         pur.user_row_id,
         pur.display_sequence,
         pur.row_low_range_or_name,
         pur.row_high_range
  from   pay_user_tables put,
         pay_user_rows_f pur
  where  put.user_table_name = p_udt_name
  and    nvl(put.legislation_code,'X') = nvl(l_legislation_code,nvl(put.legislation_code,'X'))
  and    pur.user_table_id = put.user_table_id
  and    p_effective_date
         between pur.effective_start_date and pur.effective_end_date
  order by 3, fnd_number.canonical_to_number(pur.row_low_range_or_name);
--
  cursor csr_udt_val(
           p_user_table_id  in number,
           p_row_id         in number,
           p_effective_date in date)
  is
  select /* +ORDERED */
         puc.user_column_name,
         puci.value
  from   pay_user_columns puc,
         pay_user_column_instances_f puci
  where  puc.user_table_id = p_user_table_id
  and    puci.user_column_id = puc.user_column_id
  and    puci.user_row_id = p_row_id
  and    p_effective_date
         between puci.effective_start_date and puci.effective_end_date
  order by 1;
--
  l_csr_udt_row csr_udt_row%rowtype;
  l_csr_udt_val csr_udt_val%rowtype;
--
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  open csr_pact;
  fetch csr_pact into l_payroll_action_id, l_business_group_id, l_effective_date;
  close csr_pact;
--
  -- cache in case payroll_action_id is same.
  if g_payroll_action_id is null
  or (g_payroll_action_id <> l_payroll_action_id
     and l_payroll_action_id is not null) then
  --
    g_payroll_action_id := l_payroll_action_id;
    g_business_group_id := l_business_group_id;
    g_effective_date  := l_effective_date;
  --
    l_legislation_code := hr_jp_id_pkg.legislation_code(g_business_group_id);
  --
    --
    -- life_ins prompt fetch
    --
    l_effective_date := g_effective_date;
    --
    open csr_udt_row(c_life_gen_calc_udt,l_effective_date);
    loop
    --
      fetch csr_udt_row into l_csr_udt_row;
      exit when csr_udt_row%notfound;
    --
      if csr_udt_row%rowcount = 1 then
      --
        g_life_range1b := l_csr_udt_row.row_high_range;
        g_life_range1b := to_char(to_number(g_life_range1b),fnd_currency.get_format_mask('JPY',40));
      --
      elsif csr_udt_row%rowcount = 2 then
      --
        g_life_range2a := l_csr_udt_row.row_low_range_or_name;
        g_life_range2b := l_csr_udt_row.row_high_range;
        g_life_range2a := to_char(to_number(g_life_range2a),fnd_currency.get_format_mask('JPY',40));
        g_life_range2b := to_char(to_number(g_life_range2b),fnd_currency.get_format_mask('JPY',40));
      --
        open csr_udt_val(l_csr_udt_row.user_table_id,l_csr_udt_row.user_row_id,l_effective_date);
        loop
        --
          fetch csr_udt_val into l_csr_udt_val;
          exit when csr_udt_val%notfound;
        --
          if l_csr_udt_val.user_column_name = c_add_adj_udtcol then
            l_add_adj := l_csr_udt_val.value;
          elsif l_csr_udt_val.user_column_name = c_rate_udtcol then
            l_rate := l_csr_udt_val.value;
          end if;
        --
        end loop;
        close csr_udt_val;
      --
        if fnd_number.canonical_to_number(l_rate) = 0.5 then
          l_rate := '1/2';
        elsif fnd_number.canonical_to_number(l_rate) = 0.25 then
          l_rate := '1/4';
        end if;
      --
        g_life_calc2 := 'x '||l_rate||' + '||to_char(to_number(l_add_adj),fnd_currency.get_format_mask('JPY',40));
      --
      elsif csr_udt_row%rowcount = 3 then
      --
        g_life_range3a := l_csr_udt_row.row_low_range_or_name;
        g_life_range3b := l_csr_udt_row.row_high_range;
        g_life_range3a := to_char(to_number(g_life_range3a),fnd_currency.get_format_mask('JPY',40));
        g_life_range3b := to_char(to_number(g_life_range3b),fnd_currency.get_format_mask('JPY',40));
      --
        open csr_udt_val(l_csr_udt_row.user_table_id,l_csr_udt_row.user_row_id,l_effective_date);
        loop
        --
          fetch csr_udt_val into l_csr_udt_val;
          exit when csr_udt_val%notfound;
        --
          if l_csr_udt_val.user_column_name = c_add_adj_udtcol then
            l_add_adj := l_csr_udt_val.value;
          elsif l_csr_udt_val.user_column_name = c_rate_udtcol then
            l_rate := l_csr_udt_val.value;
          end if;
        --
        end loop;
        close csr_udt_val;
      --
        if fnd_number.canonical_to_number(l_rate) = 0.5 then
          l_rate := '1/2';
        elsif fnd_number.canonical_to_number(l_rate) = 0.25 then
          l_rate := '1/4';
        end if;
      --
        g_life_calc3 := 'x '||l_rate||' + '||to_char(to_number(l_add_adj),fnd_currency.get_format_mask('JPY',40));
      --
      elsif csr_udt_row%rowcount = 4 then
      --
        g_life_range4a := l_csr_udt_row.row_low_range_or_name;
        g_life_range4a := to_char(to_number(g_life_range4a),fnd_currency.get_format_mask('JPY',40));
      --
        open csr_udt_val(l_csr_udt_row.user_table_id,l_csr_udt_row.user_row_id,l_effective_date);
        loop
        --
          fetch csr_udt_val into l_csr_udt_val;
          exit when csr_udt_val%notfound;
        --
          if l_csr_udt_val.user_column_name = c_add_adj_udtcol then
            l_add_adj := l_csr_udt_val.value;
          end if;
        --
        end loop;
        close csr_udt_val;
      --
        g_life_calc4 := l_add_adj;
      --
      end if;
    --
    end loop;
    close csr_udt_row;
  --
    g_life_gen_max := g_life_calc4;
    g_life_pens_max := g_life_calc4;
    g_life_ins_max := to_char(to_number(g_life_gen_max) + to_number(g_life_pens_max));
  --
    g_life_calc4 := to_char(to_number(g_life_calc4),fnd_currency.get_format_mask('JPY',40));
    g_life_gen_max := to_char(to_number(g_life_gen_max),fnd_currency.get_format_mask('JPY',40));
    g_life_pens_max := to_char(to_number(g_life_pens_max),fnd_currency.get_format_mask('JPY',40));
    g_life_ins_max := to_char(to_number(g_life_ins_max),fnd_currency.get_format_mask('JPY',40));
  --
    --
    -- nonlife_ins prompt fetch
    --
    --  + long term
    --
    l_effective_date := g_effective_date;
    --
    open csr_udt_row(c_nonlife_long_calc_udt,l_effective_date);
    loop
    --
      fetch csr_udt_row into l_csr_udt_row;
      exit when csr_udt_row%notfound;
    --
      if csr_udt_row%rowcount = 1 then
      --
        g_lnonlife_range1b := l_csr_udt_row.row_high_range;
        g_lnonlife_range1b := to_char(to_number(g_lnonlife_range1b),fnd_currency.get_format_mask('JPY',40));
      --
      elsif csr_udt_row%rowcount = 2 then
      --
        open csr_udt_val(l_csr_udt_row.user_table_id,l_csr_udt_row.user_row_id,l_effective_date);
        loop
        --
          fetch csr_udt_val into l_csr_udt_val;
          exit when csr_udt_val%notfound;
        --
          if l_csr_udt_val.user_column_name = c_add_adj_udtcol then
            l_add_adj := l_csr_udt_val.value;
          elsif l_csr_udt_val.user_column_name = c_rate_udtcol then
            l_rate := l_csr_udt_val.value;
          end if;
        --
        end loop;
        close csr_udt_val;
      --
        if fnd_number.canonical_to_number(l_rate) = 0.5 then
          l_rate := '1/2';
        elsif fnd_number.canonical_to_number(l_rate) = 0.25 then
          l_rate := '1/4';
        end if;
      --
        g_lnonlife_calc2 := 'x '||l_rate||' + '||to_char(to_number(l_add_adj),fnd_currency.get_format_mask('JPY',40));
      --
      elsif csr_udt_row%rowcount = 3 then
      --
        open csr_udt_val(l_csr_udt_row.user_table_id,l_csr_udt_row.user_row_id,l_effective_date);
        loop
        --
          fetch csr_udt_val into l_csr_udt_val;
          exit when csr_udt_val%notfound;
        --
          if l_csr_udt_val.user_column_name = c_add_adj_udtcol then
            l_add_adj := l_csr_udt_val.value;
          end if;
        --
        end loop;
        close csr_udt_val;
      --
        l_lnonlife_calc3 := l_add_adj;
      --
      end if;
    --
    end loop;
    close csr_udt_row;
    --
    --  + short term
    --
    -- value always should be fetched.
    if g_effective_date >= c_st_upd_date_2007 then
    --
      l_effective_date := c_st_upd_date_2007 - 1;
    --
    else
    --
      l_effective_date := g_effective_date;
    --
    end if;
    --
    open csr_udt_row(c_nonlife_short_calc_udt,l_effective_date);
    loop
    --
      fetch csr_udt_row into l_csr_udt_row;
      exit when csr_udt_row%notfound;
    --
      if csr_udt_row%rowcount = 1 then
      --
        g_snonlife_range1b := l_csr_udt_row.row_high_range;
        g_snonlife_range1b := to_char(to_number(g_snonlife_range1b),fnd_currency.get_format_mask('JPY',40));
      --
      elsif csr_udt_row%rowcount = 2 then
      --
        open csr_udt_val(l_csr_udt_row.user_table_id,l_csr_udt_row.user_row_id,l_effective_date);
        loop
        --
          fetch csr_udt_val into l_csr_udt_val;
          exit when csr_udt_val%notfound;
        --
          if l_csr_udt_val.user_column_name = c_add_adj_udtcol then
            l_add_adj := l_csr_udt_val.value;
          elsif l_csr_udt_val.user_column_name = c_rate_udtcol then
            l_rate := l_csr_udt_val.value;
          end if;
        --
        end loop;
        close csr_udt_val;
      --
        if fnd_number.canonical_to_number(l_rate) = 0.5 then
          l_rate := '1/2';
        elsif fnd_number.canonical_to_number(l_rate) = 0.25 then
          l_rate := '1/4';
        end if;
      --
        g_snonlife_calc2 := 'x '||l_rate||' + '||to_char(to_number(l_add_adj),fnd_currency.get_format_mask('JPY',40));
      --
      elsif csr_udt_row%rowcount = 3 then
      --
        open csr_udt_val(l_csr_udt_row.user_table_id,l_csr_udt_row.user_row_id,l_effective_date);
        loop
        --
          fetch csr_udt_val into l_csr_udt_val;
          exit when csr_udt_val%notfound;
        --
          if l_csr_udt_val.user_column_name = c_add_adj_udtcol then
            l_add_adj := l_csr_udt_val.value;
          end if;
        --
        end loop;
        close csr_udt_val;
      --
        l_snonlife_calc3 := l_add_adj;
      --
      end if;
    --
    end loop;
    close csr_udt_row;
    --
    --  + earthquake
    --
    if g_effective_date >= c_st_upd_date_2007 then
    --
      l_effective_date := g_effective_date;
    --
    -- value always should be fetched.
    else
    --
      l_effective_date := c_st_upd_date_2007;
    --
    end if;
    --
    if c_earthquake_max is null then
      c_earthquake_max := to_number(hruserdt.get_table_value(
                                     g_business_group_id,
                                     c_yea_calc_max_udt,
                                     c_max_udtcol,
                                     c_earthquake_udtrow,
                                     l_effective_date));
    end if;
    --
    g_earthquake_max := c_earthquake_max;
    g_earthquake_max := to_char(to_number(g_earthquake_max),fnd_currency.get_format_mask('JPY',40));
    --
    g_lnonlife_year := to_char(c_nonlife_long_year);
    g_lnonlife_max := l_lnonlife_calc3;
    g_snonlife_max := l_snonlife_calc3;
    g_lnonlife_max := to_char(to_number(g_lnonlife_max),fnd_currency.get_format_mask('JPY',40));
    g_snonlife_max := to_char(to_number(g_snonlife_max),fnd_currency.get_format_mask('JPY',40));
    --
    --  + nonlife dct
    --
    -- value always should be fetched.
    if g_effective_date >= c_st_upd_date_2007 then
    --
      l_effective_date := c_st_upd_date_2007 - 1;
    --
    else
    --
      l_effective_date := g_effective_date;
    --
    end if;
    --
    l_nonlife_max := to_number(hruserdt.get_table_value(
                                 g_business_group_id,
                                 c_yea_calc_max_udt,
                                 c_max_udtcol,
                                 c_nonlife_udtrow,
                                 l_effective_date));
    --
    -- value always should be fetched.
    if g_effective_date >= c_st_upd_date_2007 then
    --
      l_effective_date := g_effective_date;
    --
    else
    --
      l_effective_date := c_st_upd_date_2007 - 1;
    --
    end if;
    --
    l_nonlife_max_2007 := to_number(hruserdt.get_table_value(
                                      g_business_group_id,
                                      c_yea_calc_max_udt,
                                      c_max_udtcol,
                                      c_nonlife_udtrow,
                                      l_effective_date));
    --
    -- need always reset for each time
    if g_effective_date >= c_st_upd_date_2007 then
    --
      c_nonlife_max := l_nonlife_max_2007;
    --
    else
    --
      c_nonlife_max := l_nonlife_max;
    --
    end if;
    --
    g_nonlife_max := l_nonlife_max;
    g_nonlife_max_2007 := l_nonlife_max_2007;
    g_nonlife_max := to_char(to_number(g_nonlife_max),fnd_currency.get_format_mask('JPY',40));
    g_nonlife_max_2007 := to_char(to_number(g_nonlife_max_2007),fnd_currency.get_format_mask('JPY',40));
  --
    --
    -- spouse prompt fetch
    --
    g_sp_calc_unit := c_sp_calc_unit;
    --
    l_effective_date := g_effective_date;
    --
    if c_emp_income_max is null then
    --
      c_emp_income_max := to_number(hruserdt.get_table_value(
                                      g_business_group_id,
                                      c_yea_calc_max_udt,
                                      c_max_udtcol,
                                      c_sp_emp_income_udtrow,
                                      l_effective_date));
    end if;
    --
    g_sp_emp_inc_max := c_emp_income_max/c_sp_calc_unit;
    g_sp_emp_inc_max := to_char(to_number(g_sp_emp_inc_max),fnd_currency.get_format_mask('JPY',40));
  --
    l_effective_date := g_effective_date;
    --
    if c_inc_spouse_dct_max is null then
    --
      c_inc_spouse_dct_max := to_number(hruserdt.get_table_value(
                                         g_business_group_id,
                                         c_yea_calc_max_udt,
                                         c_max_udtcol,
                                         c_sp_dctable_sp_income_udtrow,
                                         l_effective_date));
    end if;
    --
    g_sp_spdct_max := c_inc_spouse_dct_max/c_sp_calc_unit;
    g_sp_spdct_max := to_char(to_number(g_sp_spdct_max),fnd_currency.get_format_mask('JPY',40));
    --
    l_effective_date := g_effective_date;
    --
    if c_spouse_income_max is null then
      c_spouse_income_max := to_number(hruserdt.get_table_value(
                                         g_business_group_id,
                                         c_yea_calc_max_udt,
                                         c_max_udtcol,
                                         c_sp_spouse_income_udtrow,
                                         l_effective_date));
    end if;
    --
    g_sp_spinc_max := c_spouse_income_max/c_sp_calc_unit;
    g_sp_spinc_max := to_char(to_number(g_sp_spinc_max),fnd_currency.get_format_mask('JPY',40));
  --
    --
    -- spouse_calc prompt fetch
    --
    g_sp_calc_exp1b := c_sp_earned_inc_exp;
    g_sp_calc_exp1b_fmt := to_char(g_sp_calc_exp1b);
    g_sp_calc_exp1b_fmt := to_char(to_number(g_sp_calc_exp1b_fmt),fnd_currency.get_format_mask('JPY',40));
    g_sp_calc_cal1 := to_char(c_sp_calc_earned_inc_calc1);
    --
    if fnd_number.canonical_to_number(c_sp_calc_other_inc_calc_rate) = 0.5 then
      l_sp_calc_other_inc_calc_rate := '1/2';
    elsif fnd_number.canonical_to_number(c_sp_calc_other_inc_calc_rate) = 0.25 then
      l_sp_calc_other_inc_calc_rate := '1/4';
    end if;
    --
    g_sp_calc_cal6 := 'x '||l_sp_calc_other_inc_calc_rate;
  --
    l_effective_date := g_effective_date;
    --
    open csr_udt_row(c_spouse_calc_udt,l_effective_date);
    loop
    --
      fetch csr_udt_row into l_csr_udt_row;
      exit when csr_udt_row%notfound;
    --
      if fnd_number.canonical_to_number(l_csr_udt_row.row_low_range_or_name) > c_inc_spouse_dct_max then
      --
        l_dct_cnt := l_dct_cnt + 1;
        l_sp_calc_tbl(l_dct_cnt).range_a := l_csr_udt_row.row_low_range_or_name;
        l_sp_calc_tbl(l_dct_cnt).range_b := l_csr_udt_row.row_high_range;
      --
        open csr_udt_val(l_csr_udt_row.user_table_id,l_csr_udt_row.user_row_id,l_effective_date);
        loop
        --
          fetch csr_udt_val into l_csr_udt_val;
          exit when csr_udt_val%notfound;
        --
          if l_csr_udt_val.user_column_name = c_dct_udtcol then
            --l_sp_calc_tbl(l_dct_cnt).val := to_char(fnd_number.canonical_to_number(l_csr_udt_val.value)/c_sp_calc_unit);
            l_sp_calc_tbl(l_dct_cnt).val := l_csr_udt_val.value;
          end if;
        --
        end loop;
        close csr_udt_val;
      --
      end if;
    --
    end loop;
    close csr_udt_row;
  --
    if l_sp_calc_tbl.count >= 9 then
    --
      g_sp_calc_dct_range1a := l_sp_calc_tbl(1).range_a;
      g_sp_calc_dct_range1b := l_sp_calc_tbl(1).range_b;
      g_sp_calc_dct1        := l_sp_calc_tbl(1).val;
      g_sp_calc_dct_range2a := l_sp_calc_tbl(2).range_a;
      g_sp_calc_dct_range2b := l_sp_calc_tbl(2).range_b;
      g_sp_calc_dct2        := l_sp_calc_tbl(2).val;
      g_sp_calc_dct_range3a := l_sp_calc_tbl(3).range_a;
      g_sp_calc_dct_range3b := l_sp_calc_tbl(3).range_b;
      g_sp_calc_dct3        := l_sp_calc_tbl(3).val;
      g_sp_calc_dct_range4a := l_sp_calc_tbl(4).range_a;
      g_sp_calc_dct_range4b := l_sp_calc_tbl(4).range_b;
      g_sp_calc_dct4        := l_sp_calc_tbl(4).val;
      g_sp_calc_dct_range5a := l_sp_calc_tbl(5).range_a;
      g_sp_calc_dct_range5b := l_sp_calc_tbl(5).range_b;
      g_sp_calc_dct5        := l_sp_calc_tbl(5).val;
      g_sp_calc_dct_range6a := l_sp_calc_tbl(6).range_a;
      g_sp_calc_dct_range6b := l_sp_calc_tbl(6).range_b;
      g_sp_calc_dct6        := l_sp_calc_tbl(6).val;
      g_sp_calc_dct_range7a := l_sp_calc_tbl(7).range_a;
      g_sp_calc_dct_range7b := l_sp_calc_tbl(7).range_b;
      g_sp_calc_dct7        := l_sp_calc_tbl(7).val;
      g_sp_calc_dct_range8a := l_sp_calc_tbl(8).range_a;
      g_sp_calc_dct_range8b := l_sp_calc_tbl(8).range_b;
      g_sp_calc_dct8        := l_sp_calc_tbl(8).val;
      g_sp_calc_dct_range9a := l_sp_calc_tbl(9).range_a;
      g_sp_calc_dct_range9b := l_sp_calc_tbl(9).range_b;
      g_sp_calc_dct9        := l_sp_calc_tbl(9).val;
    --
      g_sp_calc_dct_range1a := to_char(to_number(g_sp_calc_dct_range1a),fnd_currency.get_format_mask('JPY',40));
      g_sp_calc_dct_range1b := to_char(to_number(g_sp_calc_dct_range1b),fnd_currency.get_format_mask('JPY',40));
      g_sp_calc_dct1        := to_char(to_number(g_sp_calc_dct1),fnd_currency.get_format_mask('JPY',40));
      g_sp_calc_dct_range2a := to_char(to_number(g_sp_calc_dct_range2a),fnd_currency.get_format_mask('JPY',40));
      g_sp_calc_dct_range2b := to_char(to_number(g_sp_calc_dct_range2b),fnd_currency.get_format_mask('JPY',40));
      g_sp_calc_dct2        := to_char(to_number(g_sp_calc_dct2),fnd_currency.get_format_mask('JPY',40));
      g_sp_calc_dct_range3a := to_char(to_number(g_sp_calc_dct_range3a),fnd_currency.get_format_mask('JPY',40));
      g_sp_calc_dct_range3b := to_char(to_number(g_sp_calc_dct_range3b),fnd_currency.get_format_mask('JPY',40));
      g_sp_calc_dct3        := to_char(to_number(g_sp_calc_dct3),fnd_currency.get_format_mask('JPY',40));
      g_sp_calc_dct_range4a := to_char(to_number(g_sp_calc_dct_range4a),fnd_currency.get_format_mask('JPY',40));
      g_sp_calc_dct_range4b := to_char(to_number(g_sp_calc_dct_range4b),fnd_currency.get_format_mask('JPY',40));
      g_sp_calc_dct4        := to_char(to_number(g_sp_calc_dct4),fnd_currency.get_format_mask('JPY',40));
      g_sp_calc_dct_range5a := to_char(to_number(g_sp_calc_dct_range5a),fnd_currency.get_format_mask('JPY',40));
      g_sp_calc_dct_range5b := to_char(to_number(g_sp_calc_dct_range5b),fnd_currency.get_format_mask('JPY',40));
      g_sp_calc_dct5        := to_char(to_number(g_sp_calc_dct5),fnd_currency.get_format_mask('JPY',40));
      g_sp_calc_dct_range6a := to_char(to_number(g_sp_calc_dct_range6a),fnd_currency.get_format_mask('JPY',40));
      g_sp_calc_dct_range6b := to_char(to_number(g_sp_calc_dct_range6b),fnd_currency.get_format_mask('JPY',40));
      g_sp_calc_dct6        := to_char(to_number(g_sp_calc_dct6),fnd_currency.get_format_mask('JPY',40));
      g_sp_calc_dct_range7a := to_char(to_number(g_sp_calc_dct_range7a),fnd_currency.get_format_mask('JPY',40));
      g_sp_calc_dct_range7b := to_char(to_number(g_sp_calc_dct_range7b),fnd_currency.get_format_mask('JPY',40));
      g_sp_calc_dct7        := to_char(to_number(g_sp_calc_dct7),fnd_currency.get_format_mask('JPY',40));
      g_sp_calc_dct_range8a := to_char(to_number(g_sp_calc_dct_range8a),fnd_currency.get_format_mask('JPY',40));
      g_sp_calc_dct_range8b := to_char(to_number(g_sp_calc_dct_range8b),fnd_currency.get_format_mask('JPY',40));
      g_sp_calc_dct8        := to_char(to_number(g_sp_calc_dct8),fnd_currency.get_format_mask('JPY',40));
      g_sp_calc_dct_range9a := to_char(to_number(g_sp_calc_dct_range9a),fnd_currency.get_format_mask('JPY',40));
      g_sp_calc_dct_range9b := to_char(to_number(g_sp_calc_dct_range9b),fnd_currency.get_format_mask('JPY',40));
      g_sp_calc_dct9        := to_char(to_number(g_sp_calc_dct9),fnd_currency.get_format_mask('JPY',40));
    --
    end if;
  --
    fnd_message.set_name('PAY','PAY_JP_ISDF_P_LIFE_RANGE_FIRST');
    fnd_message.set_token('RANGE_B',g_life_range1b);
    g_msg_life_range1 := fnd_message.get;
  --
    fnd_message.set_name('PAY','PAY_JP_ISDF_P_LIFE_RANGE_MID');
    fnd_message.set_token('RANGE_A',g_life_range2a);
    fnd_message.set_token('RANGE_B',g_life_range2b);
    g_msg_life_range2 := fnd_message.get;
  --
    fnd_message.set_name('PAY','PAY_JP_ISDF_P_LIFE_RANGE_MID');
    fnd_message.set_token('RANGE_A',g_life_range3a);
    fnd_message.set_token('RANGE_B',g_life_range3b);
    g_msg_life_range3 := fnd_message.get;
  --
    fnd_message.set_name('PAY','PAY_JP_ISDF_P_LIFE_RANGE_LAST');
    fnd_message.set_token('RANGE_A',g_life_range4a);
    g_msg_life_range4 := fnd_message.get;
  --
    fnd_message.set_name('PAY','PAY_JP_ISDF_P_LIFE_DCT_MID');
    fnd_message.set_token('CALC',g_life_calc2);
    g_msg_life_calc2 := fnd_message.get;
  --
    fnd_message.set_name('PAY','PAY_JP_ISDF_P_LIFE_DCT_MID');
    fnd_message.set_token('CALC',g_life_calc3);
    g_msg_life_calc3 := fnd_message.get;
  --
    fnd_message.set_name('PAY','PAY_JP_ISDF_P_LIFE_DCT_LAST');
    fnd_message.set_token('CALC',g_life_calc4);
    g_msg_life_calc4 := fnd_message.get;
  --
    fnd_message.set_name('PAY','PAY_JP_ISDF_P_MAX');
    fnd_message.set_token('MAX_VAL',g_life_gen_max);
    g_msg_life_gen_max := fnd_message.get;
  --
    fnd_message.set_name('PAY','PAY_JP_ISDF_P_MAX');
    fnd_message.set_token('MAX_VAL',g_life_pens_max);
    g_msg_life_pens_max := fnd_message.get;
  --
    fnd_message.set_name('PAY','PAY_JP_ISDF_P_MAX');
    fnd_message.set_token('MAX_VAL',g_life_ins_max);
    g_msg_life_ins_max := fnd_message.get;
  --
    fnd_message.set_name('PAY','PAY_JP_ISDF_P_NONLIFE_2007');
    g_msg_nonlife_2007 := fnd_message.get;
  --
    fnd_message.set_name('PAY','PAY_JP_ISDF_P_NONLIFE_AP_2007');
    g_msg_nonlife_ap_2007 := fnd_message.get;
  --
    fnd_message.set_name('PAY','PAY_JP_ISDF_P_EQNONLIFE_S_2007');
    g_msg_eqnonlife_s_2007 := fnd_message.get;
  --
    fnd_message.set_name('PAY','PAY_JP_ISDF_P_LNONLIFE_S_2007');
    g_msg_lnonlife_s_2007 := fnd_message.get;
  --
    fnd_message.set_name('PAY','PAY_JP_ISDF_P_LNONLIFE');
    fnd_message.set_token('YEAR',g_lnonlife_year);
    g_msg_lnonlife := fnd_message.get;
  --
    fnd_message.set_name('PAY','PAY_JP_ISDF_P_EQNONLIFE_2007');
    g_msg_eqnonlife_2007 := fnd_message.get;
  --
    fnd_message.set_name('PAY','PAY_JP_ISDF_P_LNONLIFE_2007');
    g_msg_lnonlife_2007 := fnd_message.get;
  --
    fnd_message.set_name('PAY','PAY_JP_ISDF_P_LNONLIFE_DCT');
    fnd_message.set_token('RANGE_B',g_lnonlife_range1b);
    fnd_message.set_token('CALC',g_lnonlife_calc2);
    g_msg_lnonlife_dct := fnd_message.get;
  --
    fnd_message.set_name('PAY','PAY_JP_ISDF_P_SNONLIFE_DCT');
    fnd_message.set_token('RANGE_B',g_snonlife_range1b);
    fnd_message.set_token('CALC',g_snonlife_calc2);
    g_msg_snonlife_dct := fnd_message.get;
  --
    fnd_message.set_name('PAY','PAY_JP_ISDF_P_LNONL_DCT_2007');
    fnd_message.set_token('RANGE_B',g_lnonlife_range1b);
    fnd_message.set_token('CALC',g_lnonlife_calc2);
    g_msg_lnonlife_dct_2007 := fnd_message.get;
  --
    fnd_message.set_name('PAY','PAY_JP_ISDF_P_MAX');
    fnd_message.set_token('MAX_VAL',g_earthquake_max);
    g_msg_earthquake_max := fnd_message.get;
  --
    fnd_message.set_name('PAY','PAY_JP_ISDF_P_MAX');
    fnd_message.set_token('MAX_VAL',g_lnonlife_max);
    g_msg_nonlife_long_max := fnd_message.get;
  --
    fnd_message.set_name('PAY','PAY_JP_ISDF_P_MAX');
    fnd_message.set_token('MAX_VAL',g_snonlife_max);
    g_msg_nonlife_short_max := fnd_message.get;
  --
    fnd_message.set_name('PAY','PAY_JP_ISDF_P_MAX');
    fnd_message.set_token('MAX_VAL',g_nonlife_max);
    	g_msg_nonlife_ins_max := fnd_message.get;
  --
    fnd_message.set_name('PAY','PAY_JP_ISDF_P_MAX');
    fnd_message.set_token('MAX_VAL',g_nonlife_max_2007);
    g_msg_nonlife_ins_max_2007 := fnd_message.get;
  --
    fnd_message.set_name('PAY','PAY_JP_ISDF_P_SP_EMP_INC_MAX');
    fnd_message.set_token('EMP_INC_MAX',g_sp_emp_inc_max);
    g_msg_sp_emp_inc_max := fnd_message.get;
  --
    fnd_message.set_name('PAY','PAY_JP_ISDF_P_SP_SP_INC_MAX');
    fnd_message.set_token('SP_DCT_MAX',g_sp_spdct_max);
    fnd_message.set_token('SP_INC_MAX',g_sp_spinc_max);
    g_msg_sp_sp_inc_max := fnd_message.get;
  --
    fnd_message.set_name('PAY','PAY_JP_ISDF_P_SP_CALC_EXP1');
    fnd_message.set_token('SP_CALC_EXP1',g_sp_calc_cal1);
    g_msg_sp_calc_cal1 := fnd_message.get;
  --
    fnd_message.set_name('PAY','PAY_JP_ISDF_P_SP_CALC_EXP6');
    fnd_message.set_token('SP_CALC_EXP6',g_sp_calc_cal6);
    g_msg_sp_calc_cal6 := fnd_message.get;
  --
    fnd_message.set_name('PAY','PAY_JP_ISDF_P_SP_DCT_RANGE');
    fnd_message.set_token('RANGE_A',g_sp_calc_dct_range1a);
    fnd_message.set_token('RANGE_B',g_sp_calc_dct_range1b);
    g_msg_sp_calc_dct_range1 := fnd_message.get;
  --
    fnd_message.set_name('PAY','PAY_JP_ISDF_P_SP_DCT_RANGE');
    fnd_message.set_token('RANGE_A',g_sp_calc_dct_range2a);
    fnd_message.set_token('RANGE_B',g_sp_calc_dct_range2b);
    g_msg_sp_calc_dct_range2 := fnd_message.get;
  --
    fnd_message.set_name('PAY','PAY_JP_ISDF_P_SP_DCT_RANGE');
    fnd_message.set_token('RANGE_A',g_sp_calc_dct_range3a);
    fnd_message.set_token('RANGE_B',g_sp_calc_dct_range3b);
    g_msg_sp_calc_dct_range3 := fnd_message.get;
  --
    fnd_message.set_name('PAY','PAY_JP_ISDF_P_SP_DCT_RANGE');
    fnd_message.set_token('RANGE_A',g_sp_calc_dct_range4a);
    fnd_message.set_token('RANGE_B',g_sp_calc_dct_range4b);
    g_msg_sp_calc_dct_range4 := fnd_message.get;
  --
    fnd_message.set_name('PAY','PAY_JP_ISDF_P_SP_DCT_RANGE');
    fnd_message.set_token('RANGE_A',g_sp_calc_dct_range5a);
    fnd_message.set_token('RANGE_B',g_sp_calc_dct_range5b);
    g_msg_sp_calc_dct_range5 := fnd_message.get;
  --
    fnd_message.set_name('PAY','PAY_JP_ISDF_P_SP_DCT_RANGE');
    fnd_message.set_token('RANGE_A',g_sp_calc_dct_range6a);
    fnd_message.set_token('RANGE_B',g_sp_calc_dct_range6b);
    g_msg_sp_calc_dct_range6 := fnd_message.get;
  --
    fnd_message.set_name('PAY','PAY_JP_ISDF_P_SP_DCT_RANGE');
    fnd_message.set_token('RANGE_A',g_sp_calc_dct_range7a);
    fnd_message.set_token('RANGE_B',g_sp_calc_dct_range7b);
    g_msg_sp_calc_dct_range7 := fnd_message.get;
  --
    fnd_message.set_name('PAY','PAY_JP_ISDF_P_SP_DCT_RANGE');
    fnd_message.set_token('RANGE_A',g_sp_calc_dct_range8a);
    fnd_message.set_token('RANGE_B',g_sp_calc_dct_range8b);
    g_msg_sp_calc_dct_range8 := fnd_message.get;
  --
    fnd_message.set_name('PAY','PAY_JP_ISDF_P_SP_DCT_RANGE');
    fnd_message.set_token('RANGE_A',g_sp_calc_dct_range9a);
    fnd_message.set_token('RANGE_B',g_sp_calc_dct_range9b);
    g_msg_sp_calc_dct_range9 := fnd_message.get;
  --
    --fnd_message.set_name('PAY','PAY_JP_ISDF_P_SP_DCT');
    --fnd_message.set_token('DCT',g_sp_calc_dct1);
    --g_msg_sp_calc_dct1 := fnd_message.get;
    g_msg_sp_calc_dct1 := g_sp_calc_dct1;
  --
    --fnd_message.set_name('PAY','PAY_JP_ISDF_P_SP_DCT');
    --fnd_message.set_token('DCT',g_sp_calc_dct2);
    --g_msg_sp_calc_dct2 := fnd_message.get;
    g_msg_sp_calc_dct2 := g_sp_calc_dct2;
  --
    --fnd_message.set_name('PAY','PAY_JP_ISDF_P_SP_DCT');
    --fnd_message.set_token('DCT',g_sp_calc_dct3);
    --g_msg_sp_calc_dct3 := fnd_message.get;
    g_msg_sp_calc_dct3 := g_sp_calc_dct3;
  --
    --fnd_message.set_name('PAY','PAY_JP_ISDF_P_SP_DCT');
    --fnd_message.set_token('DCT',g_sp_calc_dct4);
    --g_msg_sp_calc_dct4 := fnd_message.get;
    g_msg_sp_calc_dct4 := g_sp_calc_dct4;
  --
    --fnd_message.set_name('PAY','PAY_JP_ISDF_P_SP_DCT');
    --fnd_message.set_token('DCT',g_sp_calc_dct5);
    --g_msg_sp_calc_dct5 := fnd_message.get;
    g_msg_sp_calc_dct5 := g_sp_calc_dct5;
  --
    --fnd_message.set_name('PAY','PAY_JP_ISDF_P_SP_DCT');
    --fnd_message.set_token('DCT',g_sp_calc_dct6);
    --g_msg_sp_calc_dct6 := fnd_message.get;
    g_msg_sp_calc_dct6 := g_sp_calc_dct6;
  --
    --fnd_message.set_name('PAY','PAY_JP_ISDF_P_SP_DCT');
    --fnd_message.set_token('DCT',g_sp_calc_dct7);
    --g_msg_sp_calc_dct7 := fnd_message.get;
    g_msg_sp_calc_dct7 := g_sp_calc_dct7;
  --
    --fnd_message.set_name('PAY','PAY_JP_ISDF_P_SP_DCT');
    --fnd_message.set_token('DCT',g_sp_calc_dct8);
    --g_msg_sp_calc_dct8 := fnd_message.get;
    g_msg_sp_calc_dct8 := g_sp_calc_dct8;
  --
    --fnd_message.set_name('PAY','PAY_JP_ISDF_P_SP_DCT');
    --fnd_message.set_token('DCT',g_sp_calc_dct9);
    --g_msg_sp_calc_dct9 := fnd_message.get;
    g_msg_sp_calc_dct9 := g_sp_calc_dct9;
  --
  end if;
--
  if g_debug then
    hr_utility.trace('g_life_range1b        : '||g_life_range1b);
    hr_utility.trace('g_life_range2a        : '||g_life_range2a);
    hr_utility.trace('g_life_range2b        : '||g_life_range2b);
    hr_utility.trace('g_life_range3a        : '||g_life_range3a);
    hr_utility.trace('g_life_range3b        : '||g_life_range3b);
    hr_utility.trace('g_life_range4a        : '||g_life_range4a);
    hr_utility.trace('g_life_calc2          : '||g_life_calc2);
    hr_utility.trace('g_life_calc3          : '||g_life_calc3);
    hr_utility.trace('g_life_calc4          : '||g_life_calc4);
    hr_utility.trace('g_life_gen_max        : '||g_life_gen_max);
    hr_utility.trace('g_life_pens_max       : '||g_life_pens_max);
    hr_utility.trace('g_life_ins_max        : '||g_life_ins_max);
    hr_utility.trace('g_earthquake_max      : '||g_earthquake_max);
    hr_utility.trace('g_lnonlife_range1b    : '||g_lnonlife_range1b);
    hr_utility.trace('g_lnonlife_calc2      : '||g_lnonlife_calc2);
    hr_utility.trace('g_lnonlife_year       : '||g_lnonlife_year);
    hr_utility.trace('g_snonlife_range1b    : '||g_snonlife_range1b);
    hr_utility.trace('g_snonlife_calc2      : '||g_snonlife_calc2);
    hr_utility.trace('g_lnonlife_max        : '||g_lnonlife_max);
    hr_utility.trace('g_snonlife_max        : '||g_snonlife_max);
    hr_utility.trace('g_nonlife_max         : '||g_nonlife_max);
    hr_utility.trace('g_sp_calc_unit        : '||g_sp_calc_unit);
    hr_utility.trace('g_sp_emp_inc_max      : '||g_sp_emp_inc_max);
    hr_utility.trace('g_sp_spdct_max        : '||g_sp_spdct_max);
    hr_utility.trace('g_sp_spinc_max        : '||g_sp_spinc_max);
    hr_utility.trace('g_sp_calc_exp1b       : '||g_sp_calc_exp1b);
    hr_utility.trace('g_sp_calc_exp1b_fmt   : '||g_sp_calc_exp1b_fmt);
    hr_utility.trace('g_sp_calc_cal1        : '||g_sp_calc_cal1);
    hr_utility.trace('g_sp_calc_cal6        : '||g_sp_calc_cal6);
    hr_utility.trace('g_sp_calc_dct_range1a : '||g_sp_calc_dct_range1a);
    hr_utility.trace('g_sp_calc_dct_range1b : '||g_sp_calc_dct_range1b);
    hr_utility.trace('g_sp_calc_dct1        : '||g_sp_calc_dct1);
    hr_utility.trace('g_sp_calc_dct_range2a : '||g_sp_calc_dct_range2a);
    hr_utility.trace('g_sp_calc_dct_range2b : '||g_sp_calc_dct_range2b);
    hr_utility.trace('g_sp_calc_dct2        : '||g_sp_calc_dct2);
    hr_utility.trace('g_sp_calc_dct_range3a : '||g_sp_calc_dct_range3a);
    hr_utility.trace('g_sp_calc_dct_range3b : '||g_sp_calc_dct_range3b);
    hr_utility.trace('g_sp_calc_dct3        : '||g_sp_calc_dct3);
    hr_utility.trace('g_sp_calc_dct_range4a : '||g_sp_calc_dct_range4a);
    hr_utility.trace('g_sp_calc_dct_range4b : '||g_sp_calc_dct_range4b);
    hr_utility.trace('g_sp_calc_dct4        : '||g_sp_calc_dct4);
    hr_utility.trace('g_sp_calc_dct_range5a : '||g_sp_calc_dct_range5a);
    hr_utility.trace('g_sp_calc_dct_range5b : '||g_sp_calc_dct_range5b);
    hr_utility.trace('g_sp_calc_dct5        : '||g_sp_calc_dct5);
    hr_utility.trace('g_sp_calc_dct_range6a : '||g_sp_calc_dct_range6a);
    hr_utility.trace('g_sp_calc_dct_range6b : '||g_sp_calc_dct_range6b);
    hr_utility.trace('g_sp_calc_dct6        : '||g_sp_calc_dct6);
    hr_utility.trace('g_sp_calc_dct_range7a : '||g_sp_calc_dct_range7a);
    hr_utility.trace('g_sp_calc_dct_range7b : '||g_sp_calc_dct_range7b);
    hr_utility.trace('g_sp_calc_dct7        : '||g_sp_calc_dct7);
    hr_utility.trace('g_sp_calc_dct_range8a : '||g_sp_calc_dct_range8a);
    hr_utility.trace('g_sp_calc_dct_range8b : '||g_sp_calc_dct_range8b);
    hr_utility.trace('g_sp_calc_dct8        : '||g_sp_calc_dct8);
    hr_utility.trace('g_sp_calc_dct_range9a : '||g_sp_calc_dct_range9a);
    hr_utility.trace('g_sp_calc_dct_range9b : '||g_sp_calc_dct_range9b);
    hr_utility.trace('g_sp_calc_dct9        : '||g_sp_calc_dct9);
  end if;
--
  if g_debug then
    hr_utility.trace('g_msg_life_range1          : '||g_msg_life_range1);
    hr_utility.trace('g_msg_life_range2          : '||g_msg_life_range2);
    hr_utility.trace('g_msg_life_range3          : '||g_msg_life_range3);
    hr_utility.trace('g_msg_life_range4          : '||g_msg_life_range4);
    hr_utility.trace('g_msg_life_calc2           : '||g_msg_life_calc2);
    hr_utility.trace('g_msg_life_calc3           : '||g_msg_life_calc3);
    hr_utility.trace('g_msg_life_calc4           : '||g_msg_life_calc4);
    hr_utility.trace('g_msg_life_gen_max         : '||g_msg_life_gen_max);
    hr_utility.trace('g_msg_life_pens_max        : '||g_msg_life_pens_max);
    hr_utility.trace('g_msg_life_ins_max         : '||g_msg_life_ins_max);
    hr_utility.trace('g_msg_nonlife_2007         : '||g_msg_nonlife_2007);
    hr_utility.trace('g_msg_nonlife_ap_2007      : '||g_msg_nonlife_ap_2007);
    hr_utility.trace('g_msg_eqnonlife_s_2007     : '||g_msg_eqnonlife_s_2007);
    hr_utility.trace('g_msg_lnonlife_s_2007      : '||g_msg_lnonlife_s_2007);
    hr_utility.trace('g_msg_lnonlife             : '||g_msg_lnonlife);
    hr_utility.trace('g_msg_eqnonlife_2007       : '||g_msg_eqnonlife_2007);
    hr_utility.trace('g_msg_lnonlife_2007        : '||g_msg_lnonlife_2007);
    hr_utility.trace('g_msg_lnonlife_dct         : '||g_msg_lnonlife_dct);
    hr_utility.trace('g_msg_snonlife_dct         : '||g_msg_snonlife_dct);
    hr_utility.trace('g_msg_lnonlife_dct_2007    : '||g_msg_lnonlife_dct_2007);
    hr_utility.trace('g_msg_earthquake_max       : '||g_msg_earthquake_max);
    hr_utility.trace('g_msg_nonlife_long_max     : '||g_msg_nonlife_long_max);
    hr_utility.trace('g_msg_nonlife_short_max    : '||g_msg_nonlife_short_max);
    hr_utility.trace('g_msg_nonlife_ins_max      : '||g_msg_nonlife_ins_max);
    hr_utility.trace('g_msg_nonlife_ins_max_2007 : '||g_msg_nonlife_ins_max_2007);
    hr_utility.trace('g_msg_sp_emp_inc_max       : '||g_msg_sp_emp_inc_max);
    hr_utility.trace('g_msg_sp_sp_inc_max        : '||g_msg_sp_sp_inc_max);
    hr_utility.trace('g_msg_sp_calc_cal1         : '||g_msg_sp_calc_cal1);
    hr_utility.trace('g_msg_sp_calc_cal6         : '||g_msg_sp_calc_cal6);
    hr_utility.trace('g_msg_sp_calc_dct_range1   : '||g_msg_sp_calc_dct_range1);
    hr_utility.trace('g_msg_sp_calc_dct_range2   : '||g_msg_sp_calc_dct_range2);
    hr_utility.trace('g_msg_sp_calc_dct_range3   : '||g_msg_sp_calc_dct_range3);
    hr_utility.trace('g_msg_sp_calc_dct_range4   : '||g_msg_sp_calc_dct_range4);
    hr_utility.trace('g_msg_sp_calc_dct_range5   : '||g_msg_sp_calc_dct_range5);
    hr_utility.trace('g_msg_sp_calc_dct_range6   : '||g_msg_sp_calc_dct_range6);
    hr_utility.trace('g_msg_sp_calc_dct_range7   : '||g_msg_sp_calc_dct_range7);
    hr_utility.trace('g_msg_sp_calc_dct_range8   : '||g_msg_sp_calc_dct_range8);
    hr_utility.trace('g_msg_sp_calc_dct_range9   : '||g_msg_sp_calc_dct_range9);
    hr_utility.trace('g_msg_sp_calc_dct1         : '||g_msg_sp_calc_dct1);
    hr_utility.trace('g_msg_sp_calc_dct2         : '||g_msg_sp_calc_dct2);
    hr_utility.trace('g_msg_sp_calc_dct3         : '||g_msg_sp_calc_dct3);
    hr_utility.trace('g_msg_sp_calc_dct4         : '||g_msg_sp_calc_dct4);
    hr_utility.trace('g_msg_sp_calc_dct5         : '||g_msg_sp_calc_dct5);
    hr_utility.trace('g_msg_sp_calc_dct6         : '||g_msg_sp_calc_dct6);
    hr_utility.trace('g_msg_sp_calc_dct7         : '||g_msg_sp_calc_dct7);
    hr_utility.trace('g_msg_sp_calc_dct8         : '||g_msg_sp_calc_dct8);
    hr_utility.trace('g_msg_sp_calc_dct9         : '||g_msg_sp_calc_dct9);
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
end set_form_pg_prompt;
--
-- -------------------------------------------------------------------------
-- do_new
-- -------------------------------------------------------------------------
procedure do_new(
  p_action_information_id in number,
  p_object_version_number in out nocopy number)
is
--
  l_proc varchar2(80) := c_package||'do_new';
  l_submission_date date;
  l_assact_rec pay_jp_isdf_assact_v%rowtype;
  l_payroll_action_id number;
--
  cursor csr_pact
  is
  select paa.payroll_action_id
  from   pay_assignment_actions paa
  where  paa.assignment_action_id = l_assact_rec.assignment_action_id;
--
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  l_submission_date := check_submission_period(p_action_information_id);
--
  if g_debug then
    hr_utility.set_location(l_proc,10);
    hr_utility.trace('submission_date  : '||fnd_date.date_to_canonical(l_submission_date));
  end if;
--
  pay_jp_isdf_dml_pkg.lock_assact(p_action_information_id, p_object_version_number, l_assact_rec);
--
  if l_assact_rec.transaction_status not in ('U', 'N') then
    fnd_message.set_name('PAY','PAY_JP_DEF_INVALID_TXN_STATUS');
    fnd_message.raise_error;
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,20);
    hr_utility.trace('action_information_id  : '||p_action_information_id);
    hr_utility.trace('object_version_number  : '||p_object_version_number);
    hr_utility.trace('assignment_action_id   : '||l_assact_rec.assignment_action_id);
    hr_utility.trace('start delete preset archive');
  end if;
--
-- recreate archive data (available for existing data of transaction_status N or U)
--
  delete
  from  pay_action_information
  where action_context_id = l_assact_rec.assignment_action_id
  and   action_context_type = 'AAP'
  and   action_information_category <> 'JP_ISDF_ASSACT';
--
  if g_debug then
    hr_utility.trace('end delete preset archive');
    hr_utility.set_location(l_proc,30);
    hr_utility.trace('start archive_assact');
  end if;
--
  -- set global argument of pact in pay_jp_isdf_archive_pkg
  open csr_pact;
  fetch csr_pact into l_payroll_action_id;
  close csr_pact;
--
  if g_debug then
    hr_utility.set_location(l_proc,40);
  end if;
--
  pay_jp_isdf_archive_pkg.init_pact(
    p_payroll_action_id => l_payroll_action_id);
  --
  -- reset to force archive because of concurrent parameter might be N
  pay_jp_isdf_archive_pkg.g_archive_default_flag := 'Y';
--
  if g_debug then
    hr_utility.set_location(l_proc,50);
  end if;
--
  -- set global argument of assact in pay_jp_isdf_archive_pkg
  pay_jp_isdf_archive_pkg.init_assact(
    p_assignment_action_id => l_assact_rec.assignment_action_id,
    p_assignment_id        => l_assact_rec.assignment_id);
--
  if g_debug then
    hr_utility.set_location(l_proc,60);
  end if;
--
  pay_jp_isdf_archive_pkg.archive_assact(
    p_assignment_action_id => l_assact_rec.assignment_action_id,
    p_assignment_id        => l_assact_rec.assignment_id);
--
  if g_debug then
    hr_utility.trace('end archive_assact');
    hr_utility.set_location(l_proc,70);
    hr_utility.trace('start update_assact');
  end if;
--
  p_object_version_number := l_assact_rec.object_version_number + 1;
--
  --api is disable because assact has been locked.
  --pay_jp_isdf_dml_pkg.update_assact(
  --  p_action_information_id => l_assact_rec.assignment_action_id,
  --  p_object_version_number => p_object_version_number,
  --  p_transaction_status    => 'N',
  --  p_finalized_date        => l_assact_rec.finalized_date,
  --  p_finalized_by          => l_assact_rec.finalized_by,
  --  p_user_comments         => l_assact_rec.user_comments,
  --  p_admin_comments        => l_assact_rec.admin_comments,
  --  p_transfer_status       => l_assact_rec.transfer_status,
  --  p_transfer_date         => l_assact_rec.transfer_date,
  --  p_expiry_date           => l_assact_rec.expiry_date);
  update pay_jp_isdf_assact_dml_v
  set    object_version_number = p_object_version_number,
         transaction_status    = 'N'
  where  row_id = l_assact_rec.row_id;
--
  if g_debug then
    hr_utility.trace('end update_assact');
    hr_utility.set_location(l_proc,1000);
  end if;
--
end do_new;
--
-- -------------------------------------------------------------------------
-- do_apply
-- -------------------------------------------------------------------------
procedure do_apply(
  p_action_information_id in number,
  p_object_version_number in out nocopy number)
is
  l_proc varchar2(80) := c_package||'do_apply';
  l_submission_date date;
  l_assact_rec pay_jp_isdf_assact_v%rowtype;
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  l_submission_date := check_submission_period(p_action_information_id);
--
  if g_debug then
    hr_utility.set_location(l_proc,10);
    hr_utility.trace('submission_date  : '||fnd_date.date_to_canonical(l_submission_date));
  end if;
--
  pay_jp_isdf_dml_pkg.lock_assact(p_action_information_id, p_object_version_number, l_assact_rec);
--
  if l_assact_rec.transaction_status <> 'N' then
    fnd_message.set_name('PAY','PAY_JP_DEF_INVALID_TXN_STATUS');
    fnd_message.raise_error;
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,20);
    hr_utility.set_location(l_proc,20);
    hr_utility.trace('action_information_id  : '||p_action_information_id);
    hr_utility.trace('object_version_number  : '||p_object_version_number);
    hr_utility.trace('assignment_action_id   : '||l_assact_rec.assignment_action_id);
    hr_utility.trace('start update_assact');
  end if;
--
  p_object_version_number := l_assact_rec.object_version_number + 1;
--
  --api is disable because assact has been locked.
  --pay_jp_isdf_dml_pkg.update_assact(
  --  p_action_information_id => l_assact_rec.assignment_action_id,
  --  p_object_version_number => p_object_version_number,
  --  p_transaction_status    => l_assact_rec.transaction_status,
  --  p_finalized_date        => l_assact_rec.finalized_date,
  --  p_finalized_by          => l_assact_rec.finalized_by,
  --  p_user_comments         => l_assact_rec.user_comments,
  --  p_admin_comments        => l_assact_rec.admin_comments,
  --  p_transfer_status       => l_assact_rec.transfer_status,
  --  p_transfer_date         => l_assact_rec.transfer_date,
  --  p_expiry_date           => l_assact_rec.expiry_date);
  update pay_jp_isdf_assact_dml_v
  set    object_version_number = p_object_version_number
  where  row_id = l_assact_rec.row_id;
--
  if g_debug then
    hr_utility.trace('end update_assact');
    hr_utility.set_location(l_proc,1000);
  end if;
--
end do_apply;
--
-- -------------------------------------------------------------------------
-- calc_total
-- -------------------------------------------------------------------------
procedure calc_total(
  p_assignment_action_id in number,
  p_calc_total_rec out nocopy t_calc_total_rec)
is
--
  l_proc varchar2(80) := c_package||'calc_total';
  l_action_info_tbl t_action_info_tbl;
--
  l_archive_cnt number := 0;
--
  cursor csr_archive_data
  is
  select action_information_id,
         action_context_id,
         action_context_type,
         object_version_number,
         action_information_category,
         action_information1,
         action_information2,
         action_information3,
         action_information4,
         action_information5,
         action_information6,
         action_information7,
         action_information8,
         action_information9,
         action_information10,
         action_information11,
         action_information12,
         action_information13,
         action_information14,
         action_information15,
         action_information16,
         action_information17,
         action_information18,
         action_information19,
         action_information20,
         action_information21,
         action_information22,
         action_information23,
         action_information24,
         action_information25,
         action_information26,
         action_information27,
         action_information28,
         action_information29,
         action_information30,
         effective_date,
         assignment_id
  from   pay_action_information pai
  where  pai.action_context_id = p_assignment_action_id
  and    pai.action_context_type = 'AAP'
  and    pai.action_information_category in ('JP_ISDF_LIFE_GEN',
                                             'JP_ISDF_LIFE_PENS',
                                             'JP_ISDF_NONLIFE',
                                             'JP_ISDF_SOCIAL',
                                             'JP_ISDF_MUTUAL_AID',
                                             'JP_ISDF_SPOUSE',
                                             'JP_ISDF_SPOUSE_INC')
  and    pai.action_information1 <> 'D';
--
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
    hr_utility.trace('csr_archive_data bulk collect start');
  end if;
--
  -- #2243411 bulk collect bug fix is available from 9.2
  open csr_archive_data;
  --fetch csr_archive_data bulk collect into l_action_info_tbl;
  loop
  --
    l_archive_cnt := l_archive_cnt + 1;
  --
    fetch csr_archive_data into l_action_info_tbl(l_archive_cnt);
    exit when csr_archive_data%notfound;
  --
  end loop;
  close csr_archive_data;
--
  if g_debug then
    hr_utility.set_location(l_proc,10);
    hr_utility.trace('csr_archive_data bulk collect end');
    hr_utility.trace('csr_archive_data count : '||l_action_info_tbl.count);
  end if;
--
  p_calc_total_rec.life_gen := 0;
  p_calc_total_rec.life_pens := 0;
  p_calc_total_rec.earthquake := 0;
  p_calc_total_rec.nonlife_long := 0;
  p_calc_total_rec.nonlife_short := 0;
  p_calc_total_rec.national_pens := 0;
  p_calc_total_rec.social := 0;
  p_calc_total_rec.mutual_aid_ec := 0;
  p_calc_total_rec.mutual_aid_p := 0;
  p_calc_total_rec.mutual_aid_dsc := 0;
  p_calc_total_rec.sp_emp_inc := 0;
  p_calc_total_rec.sp_spouse_inc := 0;
  p_calc_total_rec.sp_sp_type := null;
  p_calc_total_rec.sp_wid_type := null;
  p_calc_total_rec.sp_dct_exc := null;
  p_calc_total_rec.sp_inc_cnt := 0;
  p_calc_total_rec.sp_earned_inc := 0;
  p_calc_total_rec.sp_earned_inc_exp := 0;
  p_calc_total_rec.sp_business_inc := 0;
  p_calc_total_rec.sp_business_inc_exp := 0;
  p_calc_total_rec.sp_miscellaneous_inc := 0;
  p_calc_total_rec.sp_miscellaneous_inc_exp := 0;
  p_calc_total_rec.sp_dividend_inc := 0;
  p_calc_total_rec.sp_dividend_inc_exp := 0;
  p_calc_total_rec.sp_real_estate_inc := 0;
  p_calc_total_rec.sp_real_estate_inc_exp := 0;
  p_calc_total_rec.sp_retirement_inc := 0;
  p_calc_total_rec.sp_retirement_inc_exp := 0;
  p_calc_total_rec.sp_other_inc := 0;
  p_calc_total_rec.sp_other_inc_exp := 0;
  p_calc_total_rec.sp_other_inc_exp_dct := 0;
  p_calc_total_rec.sp_other_inc_exp_tmp := 0;
  p_calc_total_rec.sp_other_inc_exp_tmp_exp := 0;
--
  if g_debug then
    hr_utility.set_location(l_proc,20);
   end if;
--
  for i in 1..l_action_info_tbl.count loop
  --
    if l_action_info_tbl(i).action_information_category = 'JP_ISDF_LIFE_GEN' then
    --
      p_calc_total_rec.life_gen := nvl(p_calc_total_rec.life_gen,0) + nvl(fnd_number.canonical_to_number(l_action_info_tbl(i).action_information12),0);
    --
    elsif l_action_info_tbl(i).action_information_category = 'JP_ISDF_LIFE_PENS' then
    --
      p_calc_total_rec.life_pens := nvl(p_calc_total_rec.life_pens,0) + nvl(fnd_number.canonical_to_number(l_action_info_tbl(i).action_information13),0);
    --
    elsif l_action_info_tbl(i).action_information_category = 'JP_ISDF_NONLIFE' then
    --
      -- non support calc for negative amount since deduction from multiple type is acceptable, it is not feasible in system.
      if nvl(fnd_number.canonical_to_number(l_action_info_tbl(i).action_information10),0) > 0 then
      --
        if l_action_info_tbl(i).action_information2 = 'EQ' then
          p_calc_total_rec.earthquake := nvl(p_calc_total_rec.earthquake,0) + nvl(fnd_number.canonical_to_number(l_action_info_tbl(i).action_information10),0);
        elsif l_action_info_tbl(i).action_information2 = 'L' then
          p_calc_total_rec.nonlife_long := nvl(p_calc_total_rec.nonlife_long,0) + nvl(fnd_number.canonical_to_number(l_action_info_tbl(i).action_information10),0);
        elsif l_action_info_tbl(i).action_information2 = 'S' then
          p_calc_total_rec.nonlife_short := nvl(p_calc_total_rec.nonlife_short,0) + nvl(fnd_number.canonical_to_number(l_action_info_tbl(i).action_information10),0);
        end if;
      --
      end if;
    --
    elsif l_action_info_tbl(i).action_information_category = 'JP_ISDF_SOCIAL' then
    --
      if l_action_info_tbl(i).action_information7 = 'Y' then
        p_calc_total_rec.national_pens := nvl(p_calc_total_rec.national_pens,0) + nvl(fnd_number.canonical_to_number(l_action_info_tbl(i).action_information6),0);
      end if;
    --
      p_calc_total_rec.social := nvl(p_calc_total_rec.social,0) + nvl(fnd_number.canonical_to_number(l_action_info_tbl(i).action_information6),0);
    --
    elsif l_action_info_tbl(i).action_information_category = 'JP_ISDF_MUTUAL_AID' then
    --
      p_calc_total_rec.mutual_aid_ec := nvl(fnd_number.canonical_to_number(l_action_info_tbl(i).action_information2),0);
      p_calc_total_rec.mutual_aid_p := nvl(fnd_number.canonical_to_number(l_action_info_tbl(i).action_information3),0);
      p_calc_total_rec.mutual_aid_dsc := nvl(fnd_number.canonical_to_number(l_action_info_tbl(i).action_information4),0);
    --
    elsif l_action_info_tbl(i).action_information_category = 'JP_ISDF_SPOUSE' then
    --
      p_calc_total_rec.sp_emp_inc := nvl(fnd_number.canonical_to_number(l_action_info_tbl(i).action_information6),0);
      p_calc_total_rec.sp_spouse_inc := nvl(fnd_number.canonical_to_number(l_action_info_tbl(i).action_information10),0);
      p_calc_total_rec.sp_sp_type := l_action_info_tbl(i).action_information7;
      p_calc_total_rec.sp_wid_type := l_action_info_tbl(i).action_information8;
      p_calc_total_rec.sp_dct_exc := l_action_info_tbl(i).action_information9;
    --
    elsif l_action_info_tbl(i).action_information_category = 'JP_ISDF_SPOUSE_INC' then
    --
      p_calc_total_rec.sp_inc_cnt := p_calc_total_rec.sp_inc_cnt + 1;
      p_calc_total_rec.sp_earned_inc := nvl(fnd_number.canonical_to_number(l_action_info_tbl(i).action_information2),0);
      p_calc_total_rec.sp_earned_inc_exp := nvl(fnd_number.canonical_to_number(l_action_info_tbl(i).action_information3),c_sp_earned_inc_exp);
      p_calc_total_rec.sp_business_inc := nvl(fnd_number.canonical_to_number(l_action_info_tbl(i).action_information4),0);
      p_calc_total_rec.sp_business_inc_exp := nvl(fnd_number.canonical_to_number(l_action_info_tbl(i).action_information5),0);
      p_calc_total_rec.sp_miscellaneous_inc := nvl(fnd_number.canonical_to_number(l_action_info_tbl(i).action_information6),0);
      p_calc_total_rec.sp_miscellaneous_inc_exp := nvl(fnd_number.canonical_to_number(l_action_info_tbl(i).action_information7),0);
      p_calc_total_rec.sp_dividend_inc := nvl(fnd_number.canonical_to_number(l_action_info_tbl(i).action_information8),0);
      p_calc_total_rec.sp_dividend_inc_exp := nvl(fnd_number.canonical_to_number(l_action_info_tbl(i).action_information9),0);
      p_calc_total_rec.sp_real_estate_inc := nvl(fnd_number.canonical_to_number(l_action_info_tbl(i).action_information10),0);
      p_calc_total_rec.sp_real_estate_inc_exp := nvl(fnd_number.canonical_to_number(l_action_info_tbl(i).action_information11),0);
      p_calc_total_rec.sp_retirement_inc := nvl(fnd_number.canonical_to_number(l_action_info_tbl(i).action_information12),0);
      p_calc_total_rec.sp_retirement_inc_exp := nvl(fnd_number.canonical_to_number(l_action_info_tbl(i).action_information13),0);
      p_calc_total_rec.sp_other_inc := nvl(fnd_number.canonical_to_number(l_action_info_tbl(i).action_information14),0);
      p_calc_total_rec.sp_other_inc_exp := nvl(fnd_number.canonical_to_number(l_action_info_tbl(i).action_information15),0);
      p_calc_total_rec.sp_other_inc_exp_dct := nvl(fnd_number.canonical_to_number(l_action_info_tbl(i).action_information16),0);
      p_calc_total_rec.sp_other_inc_exp_tmp := nvl(fnd_number.canonical_to_number(l_action_info_tbl(i).action_information17),0);
      p_calc_total_rec.sp_other_inc_exp_tmp_exp := nvl(fnd_number.canonical_to_number(l_action_info_tbl(i).action_information18),0);
    --
    end if;
  --
  end loop;
--
  if g_debug then
    hr_utility.trace('life_gen                 : '||to_char(p_calc_total_rec.life_gen));
    hr_utility.trace('life_pens                : '||to_char(p_calc_total_rec.life_pens));
    hr_utility.trace('earthquake               : '||to_char(p_calc_total_rec.earthquake));
    hr_utility.trace('nonlife_long             : '||to_char(p_calc_total_rec.nonlife_long));
    hr_utility.trace('nonlife_short            : '||to_char(p_calc_total_rec.nonlife_short));
    hr_utility.trace('national_pens            : '||to_char(p_calc_total_rec.national_pens));
    hr_utility.trace('social                   : '||to_char(p_calc_total_rec.social));
    hr_utility.trace('mutual_aid_ec            : '||to_char(p_calc_total_rec.mutual_aid_ec));
    hr_utility.trace('mutual_aid_p             : '||to_char(p_calc_total_rec.mutual_aid_p));
    hr_utility.trace('mutual_aid_dsc           : '||to_char(p_calc_total_rec.mutual_aid_dsc));
    hr_utility.trace('sp_emp_inc               : '||to_char(p_calc_total_rec.sp_emp_inc));
    hr_utility.trace('sp_spouse_inc            : '||to_char(p_calc_total_rec.sp_spouse_inc));
    hr_utility.trace('sp_type                  : '||p_calc_total_rec.sp_sp_type);
    hr_utility.trace('sp_wid_type              : '||p_calc_total_rec.sp_wid_type);
    hr_utility.trace('sp_dct_exc               : '||p_calc_total_rec.sp_dct_exc);
    hr_utility.trace('sp_inc_cnt               : '||to_char(p_calc_total_rec.sp_inc_cnt));
    hr_utility.trace('sp_earned_inc            : '||to_char(p_calc_total_rec.sp_earned_inc));
    hr_utility.trace('sp_earned_inc_exp        : '||to_char(p_calc_total_rec.sp_earned_inc_exp));
    hr_utility.trace('sp_business_inc          : '||to_char(p_calc_total_rec.sp_business_inc));
    hr_utility.trace('sp_business_inc_exp      : '||to_char(p_calc_total_rec.sp_business_inc_exp));
    hr_utility.trace('sp_miscellaneous_inc     : '||to_char(p_calc_total_rec.sp_miscellaneous_inc));
    hr_utility.trace('sp_miscellaneous_inc_exp : '||to_char(p_calc_total_rec.sp_miscellaneous_inc_exp));
    hr_utility.trace('sp_dividend_inc          : '||to_char(p_calc_total_rec.sp_dividend_inc));
    hr_utility.trace('sp_dividend_inc_exp      : '||to_char(p_calc_total_rec.sp_dividend_inc_exp));
    hr_utility.trace('sp_real_estate_inc       : '||to_char(p_calc_total_rec.sp_real_estate_inc));
    hr_utility.trace('sp_real_estate_inc_exp   : '||to_char(p_calc_total_rec.sp_real_estate_inc_exp));
    hr_utility.trace('sp_retirement_inc        : '||to_char(p_calc_total_rec.sp_retirement_inc));
    hr_utility.trace('sp_retirement_inc_exp    : '||to_char(p_calc_total_rec.sp_retirement_inc_exp));
    hr_utility.trace('sp_other_inc             : '||to_char(p_calc_total_rec.sp_other_inc));
    hr_utility.trace('sp_other_inc_exp         : '||to_char(p_calc_total_rec.sp_other_inc_exp));
    hr_utility.trace('sp_other_inc_exp_dct     : '||to_char(p_calc_total_rec.sp_other_inc_exp_dct));
    hr_utility.trace('sp_other_inc_exp_tmp     : '||to_char(p_calc_total_rec.sp_other_inc_exp_tmp));
    hr_utility.trace('sp_other_inc_exp_tmp_exp : '||to_char(p_calc_total_rec.sp_other_inc_exp_tmp_exp));
    hr_utility.set_location(l_proc,1000);
   end if;
--
end calc_total;
--
-- -------------------------------------------------------------------------
-- calc_life_ins_dct
-- -------------------------------------------------------------------------
procedure calc_life_ins_dct(
  p_life_gen_i        in number,
  p_life_pens_i       in number,
  p_business_group_id in number,
  p_effective_date    in date,
  p_life_ins_dct_o    out nocopy number,
  p_life_gen_o        out nocopy number,
  p_life_pens_o       out nocopy number)
is
--
  l_proc varchar2(80) := c_package||'calc_total';
  i_life_gen number := nvl(p_life_gen_i,0);
  i_life_pens number := nvl(p_life_pens_i,0);
  o_life_pens number := 0;
  o_life_gen number := 0;
--
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
    hr_utility.trace('p_life_gen_i        : '||to_char(p_life_gen_i));
    hr_utility.trace('p_life_pens_i       : '||to_char(p_life_pens_i));
    hr_utility.trace('p_business_group_id : '||to_char(p_business_group_id));
    hr_utility.trace('p_effective_date    : '||to_char(p_effective_date,'YYYY/MM/DD'));
    hr_utility.trace('i_life_gen          : '||to_char(i_life_gen));
    hr_utility.trace('i_life_pens         : '||to_char(i_life_pens));
  end if;
--
  -- formula datetrack
  if (p_effective_date >= hr_api.g_sot
     and p_effective_date <= hr_api.g_eot) then
  --
    if g_debug then
      hr_utility.set_location(l_proc,10);
    end if;
  --
    if i_life_gen > 0 then
    --
      if g_debug then
        hr_utility.set_location(l_proc,20);
      end if;
    --
      -- udt satisfy validation of max value
      o_life_gen := round(i_life_gen
                             * to_number(hruserdt.get_table_value(
                                           p_business_group_id,
                                           c_life_gen_calc_udt,
                                           c_rate_udtcol,
                                           to_char(i_life_gen),
                                           p_effective_date))
                             + to_number(hruserdt.get_table_value(
                                           p_business_group_id,
                                           c_life_gen_calc_udt,
                                           c_add_adj_udtcol,
                                           to_char(i_life_gen),
                                           p_effective_date)));
    --
      if g_debug then
        hr_utility.set_location(l_proc,30);
      end if;
    --
    end if;
  --
    if g_debug then
      hr_utility.set_location(l_proc,40);
    end if;
  --
    if i_life_pens > 0 then
    --
      if g_debug then
        hr_utility.set_location(l_proc,50);
      end if;
    --
      -- udt satisfy validation of max value
      o_life_pens := round(i_life_pens
                             * to_number(hruserdt.get_table_value(
                                           p_business_group_id,
                                           c_life_pens_calc_udt,
                                           c_rate_udtcol,
                                           to_char(i_life_pens),
                                           p_effective_date))
                             + to_number(hruserdt.get_table_value(
                                           p_business_group_id,
                                           c_life_pens_calc_udt,
                                           c_add_adj_udtcol,
                                           to_char(i_life_pens),
                                           p_effective_date)));
    --
      if g_debug then
        hr_utility.set_location(l_proc,60);
      end if;
    --
    end if;
  --
  end if;
--
  p_life_gen_o     := o_life_gen;
  p_life_pens_o    := o_life_pens;
  p_life_ins_dct_o := o_life_gen + o_life_pens;
--
  if g_debug then
    hr_utility.trace('o_life_gen       : '||to_char(o_life_gen));
    hr_utility.trace('o_life_pens      : '||to_char(o_life_pens));
    hr_utility.trace('p_life_gen_o     : '||to_char(p_life_gen_o));
    hr_utility.trace('p_life_pens_o    : '||to_char(p_life_pens_o));
    hr_utility.trace('p_life_ins_dct_o : '||to_char(p_life_ins_dct_o));
    hr_utility.set_location(l_proc,1000);
  end if;
--
end calc_life_ins_dct;
--
-- -------------------------------------------------------------------------
-- calc_nonlife
-- -------------------------------------------------------------------------
procedure calc_nonlife_dct(
  p_earthquake_i      in number,
  p_nonlife_long_i    in number,
  p_nonlife_short_i   in number,
  p_business_group_id in number,
  p_effective_date    in date,
  p_nonlife_dct_o     out nocopy number,
  p_earthquake_o      out nocopy number,
  p_nonlife_long_o    out nocopy number,
  p_nonlife_short_o   out nocopy number)
is
--
  l_proc varchar2(80) := c_package||'calc_total';
  i_earthquake number := nvl(p_earthquake_i,0);
  i_nonlife_long number := nvl(p_nonlife_long_i,0);
  i_nonlife_short number := nvl(p_nonlife_short_i,0);
  o_earthquake number := 0;
  o_nonlife_long number := 0;
  o_nonlife_short number := 0;
  o_nonlife_dct number;
--
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
    hr_utility.trace('p_earthquake_i      : '||to_char(p_earthquake_i));
    hr_utility.trace('p_nonlife_long_i    : '||to_char(p_nonlife_long_i));
    hr_utility.trace('p_nonlife_long_i    : '||to_char(p_nonlife_short_i));
    hr_utility.trace('p_business_group_id : '||to_char(p_business_group_id));
    hr_utility.trace('p_effective_date    : '||to_char(p_effective_date,'YYYY/MM/DD'));
    hr_utility.trace('i_earthquake        : '||to_char(i_earthquake));
    hr_utility.trace('i_nonlife_long      : '||to_char(i_nonlife_long));
    hr_utility.trace('i_nonlife_short     : '||to_char(i_nonlife_short));
  end if;
--
  -- formula datetrack
  if (p_effective_date >= hr_api.g_sot
     and p_effective_date < c_st_upd_date_2007) then
  --
    if g_debug then
      hr_utility.set_location(l_proc,10);
    end if;
  --
    o_earthquake := null;
  --
    if i_nonlife_long > 0 then
    --
      if g_debug then
        hr_utility.set_location(l_proc,20);
      end if;
    --
      -- udt satisfy validation of max value
      o_nonlife_long := round(i_nonlife_long
                             * to_number(hruserdt.get_table_value(
                                           p_business_group_id,
                                           c_nonlife_long_calc_udt,
                                           c_rate_udtcol,
                                           to_char(i_nonlife_long),
                                           p_effective_date))
                             + to_number(hruserdt.get_table_value(
                                           p_business_group_id,
                                           c_nonlife_long_calc_udt,
                                           c_add_adj_udtcol,
                                           to_char(i_nonlife_long),
                                           p_effective_date)));
    --
      if g_debug then
        hr_utility.set_location(l_proc,30);
      end if;
    --
    end if;
  --
    if g_debug then
      hr_utility.set_location(l_proc,40);
    end if;
  --
    if i_nonlife_short > 0 then
    --
      if g_debug then
        hr_utility.set_location(l_proc,50);
      end if;
    --
      -- udt satisfy validation of max value
      o_nonlife_short := round(i_nonlife_short
                             * to_number(hruserdt.get_table_value(
                                           p_business_group_id,
                                           c_nonlife_short_calc_udt,
                                           c_rate_udtcol,
                                           to_char(i_nonlife_short),
                                           p_effective_date))
                             + to_number(hruserdt.get_table_value(
                                           p_business_group_id,
                                           c_nonlife_short_calc_udt,
                                           c_add_adj_udtcol,
                                           to_char(i_nonlife_short),
                                           p_effective_date)));
    --
      if g_debug then
        hr_utility.set_location(l_proc,60);
      end if;
    --
    end if;
  --
    o_nonlife_dct := o_nonlife_long + o_nonlife_short;
    --
    if g_effective_date <> p_effective_date
    or g_effective_date is null
    or c_nonlife_max is null then
    --
      -- need always reset cache has problem in case date is switched between 2006 and 2007.
      c_nonlife_max := to_number(hruserdt.get_table_value(
                                   p_business_group_id,
                                   c_yea_calc_max_udt,
                                   c_max_udtcol,
                                   c_nonlife_udtrow,
                                   p_effective_date));
    --
    end if;
    --
    if g_debug then
      hr_utility.set_location(l_proc,70);
      hr_utility.trace('o_nonlife_dct : '||to_char(o_nonlife_dct));
      hr_utility.trace('c_nonlife_max : '||to_char(c_nonlife_max));
    end if;
  --
    if o_nonlife_dct > c_nonlife_max then
      o_nonlife_dct := c_nonlife_max;
    end if;
  --
    if g_debug then
      hr_utility.set_location(l_proc,80);
    end if;
  --
  elsif (p_effective_date >= c_st_upd_date_2007
          and p_effective_date <= hr_api.g_eot) then
  --
    if g_debug then
      hr_utility.set_location(l_proc,90);
    end if;
  --
    o_nonlife_short := null;
  --
    if i_earthquake > 0 then
    --
      if g_debug then
        hr_utility.set_location(l_proc,100);
      end if;
    --
      o_earthquake := round(i_earthquake);
      if c_earthquake_max is null then
        c_earthquake_max := to_number(hruserdt.get_table_value(
                                     p_business_group_id,
                                     c_yea_calc_max_udt,
                                     c_max_udtcol,
                                     c_earthquake_udtrow,
                                     p_effective_date));
      end if;
    --
      if g_debug then
        hr_utility.set_location(l_proc,110);
        hr_utility.trace('o_earthquake     : '||to_char(o_earthquake));
        hr_utility.trace('c_earthquake_max : '||to_char(c_earthquake_max));
      end if;
    --
      if o_earthquake > c_earthquake_max then
        o_earthquake := c_earthquake_max;
      end if;
    --
      if g_debug then
        hr_utility.set_location(l_proc,120);
      end if;
    --
    end if;
  --
    if i_nonlife_long > 0 then
    --
      if g_debug then
        hr_utility.set_location(l_proc,130);
      end if;
    --
      -- udt satisfy validation of max value
      o_nonlife_long := round(i_nonlife_long
                             * to_number(hruserdt.get_table_value(
                                           p_business_group_id,
                                           c_nonlife_long_calc_udt,
                                           c_rate_udtcol,
                                           to_char(i_nonlife_long),
                                           p_effective_date))
                             + to_number(hruserdt.get_table_value(
                                           p_business_group_id,
                                           c_nonlife_long_calc_udt,
                                           c_add_adj_udtcol,
                                           to_char(i_nonlife_long),
                                           p_effective_date)));
    --
      if g_debug then
        hr_utility.set_location(l_proc,140);
      end if;
    --
    end if;
  --
    if g_debug then
      hr_utility.set_location(l_proc,150);
    end if;
  --
    o_nonlife_dct := o_earthquake + o_nonlife_long;
    --
    if g_effective_date <> p_effective_date
    or g_effective_date is null
    or c_nonlife_max is null then
    --
      -- need always reset cache has problem in case date is switched between 2006 and 2007.
      c_nonlife_max := to_number(hruserdt.get_table_value(
                                   p_business_group_id,
                                   c_yea_calc_max_udt,
                                   c_max_udtcol,
                                   c_nonlife_udtrow,
                                   p_effective_date));
    --
    end if;
    --
    if g_debug then
      hr_utility.set_location(l_proc,160);
      hr_utility.trace('o_nonlife_dct : '||to_char(o_nonlife_dct));
      hr_utility.trace('c_nonlife_max : '||to_char(c_nonlife_max));
    end if;
  --
    if o_nonlife_dct > c_nonlife_max then
      o_nonlife_dct := c_nonlife_max;
    end if;
  --
    if g_debug then
      hr_utility.set_location(l_proc,170);
    end if;
  --
  end if;
--
  p_earthquake_o    := o_earthquake;
  p_nonlife_long_o  := o_nonlife_long;
  p_nonlife_short_o := o_nonlife_short;
  p_nonlife_dct_o   := o_nonlife_dct;
--
  if g_debug then
    hr_utility.trace('p_earthquake_o    : '||to_char(p_earthquake_o));
    hr_utility.trace('p_nonlife_long_o  : '||to_char(p_nonlife_long_o));
    hr_utility.trace('p_nonlife_short_o : '||to_char(p_nonlife_short_o));
    hr_utility.trace('p_nonlife_dct_o   : '||to_char(p_nonlife_dct_o));
    hr_utility.trace('o_nonlife_long    : '||to_char(o_nonlife_long));
    hr_utility.trace('o_nonlife_short   : '||to_char(o_nonlife_short));
    hr_utility.trace('o_nonlife_dct     : '||to_char(o_nonlife_dct));
    hr_utility.set_location(l_proc,1000);
  end if;
--
end calc_nonlife_dct;
--
-- -------------------------------------------------------------------------
-- calc_nonlife_dct
-- -------------------------------------------------------------------------
--  wrapper, activate since 2007 statutory update
procedure calc_nonlife_dct(
  p_earthquake_i      in number,
  p_nonlife_long_i    in number,
  p_business_group_id in number,
  p_effective_date    in date,
  p_nonlife_dct_o     out nocopy number,
  p_earthquake_o      out nocopy number,
  p_nonlife_long_o    out nocopy number)
is
--
  l_proc varchar2(80) := c_package||'calc_nonlife_dct';
  o_earthquake number;
  o_nonlife_long number;
  o_nonlife_short number;
  o_nonlife_dct number;
--
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
    hr_utility.trace('calc_nonlife_dct wrapper');
  end if;
--
  if (p_effective_date >= hr_api.g_sot
     and p_effective_date < c_st_upd_date_2007) then
  --
    if g_debug then
      hr_utility.set_location(l_proc,10);
    end if;
  --
    calc_nonlife_dct(
      p_earthquake_i      => p_earthquake_i,
      p_nonlife_long_i    => p_nonlife_long_i,
      p_nonlife_short_i   => null,
      p_business_group_id => p_business_group_id,
      p_effective_date    => p_effective_date,
      p_nonlife_dct_o     => o_nonlife_dct,
      p_earthquake_o      => o_earthquake,
      p_nonlife_long_o    => o_nonlife_long,
      p_nonlife_short_o   => o_nonlife_short);
  --
  end if;
--
  p_earthquake_o    := o_earthquake;
  p_nonlife_long_o  := o_nonlife_long;
  p_nonlife_dct_o   := o_nonlife_dct;
--
  if g_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
end calc_nonlife_dct;
--
-- -------------------------------------------------------------------------
-- calc_social_dct
-- -------------------------------------------------------------------------
procedure calc_social_dct(
  p_social_i          in number,
  p_business_group_id in number,
  p_effective_date    in date,
  p_social_dct_o      out nocopy number)
is
--
  l_proc varchar2(80) := c_package||'calc_total';
  i_social number := nvl(p_social_i,0);
  o_social_dct number;
--
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
    hr_utility.trace('p_social_i          : '||to_char(p_social_i));
    hr_utility.trace('p_business_group_id : '||to_char(p_business_group_id));
    hr_utility.trace('p_effective_date    : '||to_char(p_effective_date,'YYYY/MM/DD'));
    hr_utility.trace('i_social            : '||to_char(i_social));
  end if;
--
  -- formula datetrack
  if (p_effective_date >= hr_api.g_sot
     and p_effective_date <= hr_api.g_eot) then
  --
    if g_debug then
      hr_utility.set_location(l_proc,10);
    end if;
  --
    if i_social < 0 then
    --
      if g_debug then
        hr_utility.set_location(l_proc,20);
      end if;
    --
      o_social_dct := 0;
    --
    else
    --
      o_social_dct := round(i_social);
    --
      if g_debug then
        hr_utility.set_location(l_proc,30);
      end if;
    --
    end if;
  --
  end if;
--
  p_social_dct_o := o_social_dct;
--
  if g_debug then
    hr_utility.trace('p_social_dct_o : '||to_char(p_social_dct_o));
    hr_utility.trace('o_social_dct   : '||to_char(o_social_dct));
    hr_utility.set_location(l_proc,1000);
  end if;
--
end calc_social_dct;
--
-- -------------------------------------------------------------------------
-- calc_mutual_aid_dct
-- -------------------------------------------------------------------------
procedure calc_mutual_aid_dct(
  p_mutual_aid_ec_i   in number,
  p_mutual_aid_p_i    in number,
  p_mutual_aid_dsc_i  in number,
  p_business_group_id in number,
  p_effective_date    in date,
  p_mutual_aid_dct_o  out nocopy number)
is
--
  l_proc varchar2(80) := c_package||'calc_total';
  i_mutual_aid_ec number := nvl(p_mutual_aid_ec_i,0);
  i_mutual_aid_p number := nvl(p_mutual_aid_p_i,0);
  i_mutual_aid_dsc number := nvl(p_mutual_aid_dsc_i,0);
  o_mutual_aid_dct number;
--
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
    hr_utility.trace('p_mutual_aid_ec_i   : '||to_char(p_mutual_aid_ec_i));
    hr_utility.trace('p_mutual_aid_p_i    : '||to_char(p_mutual_aid_p_i));
    hr_utility.trace('p_mutual_aid_dsc_i  : '||to_char(p_mutual_aid_dsc_i));
    hr_utility.trace('p_business_group_id : '||to_char(p_business_group_id));
    hr_utility.trace('p_effective_date    : '||to_char(p_effective_date,'YYYY/MM/DD'));
    hr_utility.trace('i_mutual_aid_ec     : '||to_char(i_mutual_aid_ec));
    hr_utility.trace('i_mutual_aid_p      : '||to_char(i_mutual_aid_p));
    hr_utility.trace('i_mutual_aid_dsc    : '||to_char(i_mutual_aid_dsc));
  end if;
--
  -- formula datetrack
  if (p_effective_date >= hr_api.g_sot
     and p_effective_date <= hr_api.g_eot) then
  --
    if g_debug then
      hr_utility.set_location(l_proc,10);
    end if;
  --
    o_mutual_aid_dct := round(i_mutual_aid_ec + i_mutual_aid_p + i_mutual_aid_dsc);
  --
  end if;
--
  p_mutual_aid_dct_o := o_mutual_aid_dct;
--
  if g_debug then
    hr_utility.trace('p_mutual_aid_dct_o : '||to_char(p_mutual_aid_dct_o));
    hr_utility.trace('o_mutual_aid_dct   : '||to_char(o_mutual_aid_dct));
    hr_utility.set_location(l_proc,1000);
  end if;
--
end calc_mutual_aid_dct;
--
-- -------------------------------------------------------------------------
-- calc_spouse_dct
-- -------------------------------------------------------------------------
procedure calc_spouse_dct(
  p_spouse_income_i   in number,
  p_emp_income_i      in number,
  p_sp_type_i         in varchar2,
  p_wid_type_i        in varchar2,
  p_dct_exc_i         in varchar2,
  p_business_group_id in number,
  p_effective_date    in date,
  p_spouse_dct_o      out nocopy number)
is
--
  l_proc varchar2(80) := c_package||'calc_total';
  i_spouse_income number := nvl(p_spouse_income_i,0);
  i_emp_income number := nvl(p_emp_income_i,0);
  o_spouse_dct number := 0;
--
  l_bg_itax_dpnt_ref_type varchar2(150);
  c_emp_income_max number;
  c_inc_spouse_dct_ma number;
--
begin
--
-- spouse_type validation is unnecessary. (just show it on form for confirmation)
-- employer can distinguish the data validity between ss entry data and source data
-- because employer can see archived spouse_type (source data) with ss entry data.
-- spouse_type is fetched yea non-recurring entry so that it might not be setup
-- data at the time when employer make archive data.
-- spouse deduction on form will be calculated by based on ss entry data
-- without message, even if ss entry data is not matched with source data,
-- because employee cannot change spouse_type (source data) by themselves,
-- specially in case when spouse_type is derived from eev (contact data can be changed).
-- this might cause inconsistence between pay run result and form data,
-- though employer should reject(ask employee to amend) ss entry data before pay run.
--
-- However, in this calculation, the calculated deduction is just information
-- but as much as possible result should be same with actual yea run result,
-- additionally spouse_type and widow_type are stored in recurring element,
-- (dct_exc_flag is in non-recurring element), it means they probably will not be changed at yea run time
-- and employer might has already setup the transferred override element for this ss form by manual,
-- (actually this step is not desired.).
-- finally the spouse_type, widow_type(set when spouse is inserted newly from ss
-- or eev has been existed), dct_exc_flag(only case eev has been existed)
-- their conditions are now included in current calculation logic like yea run formula.
-- (At the calculated time, system cannot know final eev data at the yea runtime,
-- so the result by this calculation might be different from final yea run result.)
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
    hr_utility.trace('p_spouse_income_i   : '||to_char(p_spouse_income_i));
    hr_utility.trace('p_emp_income_i      : '||to_char(p_emp_income_i));
    hr_utility.trace('p_business_group_id : '||to_char(p_business_group_id));
    hr_utility.trace('p_effective_date    : '||to_char(p_effective_date,'YYYY/MM/DD'));
    hr_utility.trace('i_spouse_income     : '||to_char(i_spouse_income));
    hr_utility.trace('i_emp_income        : '||to_char(i_emp_income));
    hr_utility.trace('following are just information');
    hr_utility.trace('p_sp_type_i         : '||p_sp_type_i);
    hr_utility.trace('p_wid_type_i        : '||p_wid_type_i);
    hr_utility.trace('p_dct_exc_i         : '||p_dct_exc_i);
  end if;
--
  -- formula datetrack
  if (p_effective_date >= hr_api.g_sot
     and p_effective_date <= hr_api.g_eot) then
  --
    if g_debug then
      hr_utility.set_location(l_proc,10);
    end if;
  --
    if nvl(p_spouse_income_i,0) > 0
    and nvl(p_dct_exc_i,'N') = 'N' then
    --
      if g_debug then
        hr_utility.set_location(l_proc,20);
      end if;
    --
      if c_emp_income_max is null then
      --
        c_emp_income_max := to_number(hruserdt.get_table_value(
                                       p_business_group_id,
                                       c_yea_calc_max_udt,
                                       c_max_udtcol,
                                       c_sp_emp_income_udtrow,
                                       p_effective_date));
      --
        if g_debug then
          hr_utility.set_location(l_proc,30);
          hr_utility.trace('c_emp_income_max : '||to_char(c_emp_income_max));
          hr_utility.trace('i_emp_income     : '||to_char(i_emp_income));
        end if;
      --
      end if;
    --
      if i_emp_income <= c_emp_income_max
      and nvl(p_wid_type_i,'0') = '0'
      -- calculate when sp_type is null since eev might be set in future.
      and nvl(p_sp_type_i,'1') <> '0' then
      --
        if g_debug then
          hr_utility.set_location(l_proc,40);
        end if;
      --
        if c_inc_spouse_dct_max is null then
        --
          c_inc_spouse_dct_max := to_number(hruserdt.get_table_value(
                                             p_business_group_id,
                                             c_yea_calc_max_udt,
                                             c_max_udtcol,
                                             c_sp_dctable_sp_income_udtrow,
                                             p_effective_date));
        --
          if g_debug then
            hr_utility.set_location(l_proc,50);
            hr_utility.trace('c_inc_spouse_dct_max : '||to_char(c_inc_spouse_dct_max));
            hr_utility.trace('i_spouse_income      : '||to_char(i_spouse_income));
          end if;
        --
        end if;
      --
        -- even spouse_type is 2,3, if over inc_spouse_dct_max, they can be deductive for sp_spouse_dct.
        if i_spouse_income > c_inc_spouse_dct_max then
        --
          if g_debug then
            hr_utility.set_location(l_proc,60);
          end if;
        --
          if c_spouse_income_max is null then
          --
            c_spouse_income_max := to_number(hruserdt.get_table_value(
                                              p_business_group_id,
                                              c_yea_calc_max_udt,
                                              c_max_udtcol,
                                              c_sp_spouse_income_udtrow,
                                              p_effective_date));
          --
          end if;
          --
          if g_debug then
            hr_utility.set_location(l_proc,70);
            hr_utility.trace('c_spouse_income_max : '||to_char(c_spouse_income_max));
            hr_utility.trace('i_spouse_income     : '||to_char(i_spouse_income));
          end if;
          --
          if i_spouse_income < c_spouse_income_max then
          --
            o_spouse_dct := round(to_number(hruserdt.get_table_value(
                                        p_business_group_id,
                                        c_spouse_calc_udt,
                                        c_dct_udtcol,
                                        to_char(i_spouse_income),
                                        p_effective_date)));
          --
            if g_debug then
              hr_utility.set_location(l_proc,80);
              hr_utility.trace('o_spouse_dct : '||to_char(o_spouse_dct));
            end if;
          --
          end if;
        --
        end if;
      --
      end if;
    --
    end if;
  --
  end if;
--
  p_spouse_dct_o := o_spouse_dct;
--
  if g_debug then
    hr_utility.trace('p_spouse_dct_o : '||to_char(p_spouse_dct_o));
    hr_utility.trace('o_spouse_dct   : '||to_char(o_spouse_dct));
    hr_utility.set_location(l_proc,1000);
  end if;
--
end calc_spouse_dct;
--
-- -------------------------------------------------------------------------
-- calc_spouse_inc
-- -------------------------------------------------------------------------
procedure calc_spouse_inc(
  p_sp_earned_inc_i            in number,
  p_sp_earned_inc_exp_i        in number,
  p_sp_business_inc_i          in number,
  p_sp_business_inc_exp_i      in number,
  p_sp_miscellaneous_inc_i     in number,
  p_sp_miscellaneous_inc_exp_i in number,
  p_sp_dividend_inc_i          in number,
  p_sp_dividend_inc_exp_i      in number,
  p_sp_real_estate_inc_i       in number,
  p_sp_real_estate_inc_exp_i   in number,
  p_sp_retirement_inc_i        in number,
  p_sp_retirement_inc_exp_i    in number,
  p_sp_other_inc_i             in number,
  p_sp_other_inc_exp_i         in number,
  p_sp_other_inc_exp_dct_i     in number,
  p_sp_other_inc_exp_tmp_i     in number,
  p_sp_other_inc_exp_tmp_exp_i in number,
  p_sp_inc_cnt_i               in number,
  p_ent_spouse_inc_i           in number,
  p_business_group_id          in number,
  p_effective_date             in date,
  p_calc_spouse_inc_rec        out nocopy t_calc_spouse_inc_rec,
  p_spouse_inc_o               out nocopy number)
is
--
  l_proc varchar2(80) := c_package||'calc_total';
  o_spouse_inc number := 0;
--
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
    hr_utility.trace('p_sp_earned_inc_i            : '||to_char(p_sp_earned_inc_i));
    hr_utility.trace('p_sp_earned_inc_exp_i        : '||to_char(p_sp_earned_inc_exp_i));
    hr_utility.trace('p_sp_business_inc_i          : '||to_char(p_sp_business_inc_i));
    hr_utility.trace('p_sp_business_inc_exp_i      : '||to_char(p_sp_business_inc_exp_i));
    hr_utility.trace('p_sp_miscellaneous_inc_i     : '||to_char(p_sp_miscellaneous_inc_i));
    hr_utility.trace('p_sp_miscellaneous_inc_exp_i : '||to_char(p_sp_miscellaneous_inc_exp_i));
    hr_utility.trace('p_sp_dividend_inc_i          : '||to_char(p_sp_dividend_inc_i));
    hr_utility.trace('p_sp_dividend_inc_exp_i      : '||to_char(p_sp_dividend_inc_exp_i));
    hr_utility.trace('p_sp_real_estate_inc_i       : '||to_char(p_sp_real_estate_inc_i));
    hr_utility.trace('p_sp_real_estate_inc_exp_i   : '||to_char(p_sp_real_estate_inc_exp_i));
    hr_utility.trace('p_sp_retirement_inc_i        : '||to_char(p_sp_retirement_inc_i));
    hr_utility.trace('p_sp_retirement_inc_exp_i    : '||to_char(p_sp_retirement_inc_exp_i));
    hr_utility.trace('p_sp_other_inc_i             : '||to_char(p_sp_other_inc_i));
    hr_utility.trace('p_sp_other_inc_exp_i         : '||to_char(p_sp_other_inc_exp_i));
    hr_utility.trace('p_sp_other_inc_exp_dct_i     : '||to_char(p_sp_other_inc_exp_dct_i));
    hr_utility.trace('p_sp_other_inc_exp_tmp_i     : '||to_char(p_sp_other_inc_exp_tmp_i));
    hr_utility.trace('p_sp_other_inc_exp_tmp_exp_i : '||to_char(p_sp_other_inc_exp_tmp_exp_i));
    hr_utility.trace('p_sp_inc_cnt_i               : '||to_char(p_sp_inc_cnt_i));
    hr_utility.trace('p_ent_spouse_inc_i           : '||to_char(p_ent_spouse_inc_i));
  end if;
--
  p_calc_spouse_inc_rec.sp_earned_inc_calc := 0;
  p_calc_spouse_inc_rec.sp_business_inc_calc := 0;
  p_calc_spouse_inc_rec.sp_miscellaneous_inc_calc := 0;
  p_calc_spouse_inc_rec.sp_dividend_inc_calc := 0;
  p_calc_spouse_inc_rec.sp_real_estate_inc_calc := 0;
  p_calc_spouse_inc_rec.sp_retirement_inc_calc := 0;
  p_calc_spouse_inc_rec.sp_other_inc_calc := 0;
  p_calc_spouse_inc_rec.sp_inc_calc := 0;
--
  -- formula datetrack
  if (p_effective_date >= hr_api.g_sot
     and p_effective_date <= hr_api.g_eot) then
  --
    p_calc_spouse_inc_rec.sp_earned_inc_calc := p_sp_earned_inc_i - p_sp_earned_inc_exp_i;
    if p_calc_spouse_inc_rec.sp_earned_inc_calc < 0 then
      p_calc_spouse_inc_rec.sp_earned_inc_calc := 0;
    end if;
  --
    p_calc_spouse_inc_rec.sp_business_inc_calc := p_sp_business_inc_i - p_sp_business_inc_exp_i;
    -- basically this case is not happened.
    if p_calc_spouse_inc_rec.sp_business_inc_calc < 0 then
      p_calc_spouse_inc_rec.sp_business_inc_calc := 0;
    end if;
  --
    p_calc_spouse_inc_rec.sp_miscellaneous_inc_calc := p_sp_miscellaneous_inc_i - p_sp_miscellaneous_inc_exp_i;
    -- basically this case is not happened.
    if p_calc_spouse_inc_rec.sp_miscellaneous_inc_calc < 0 then
      p_calc_spouse_inc_rec.sp_miscellaneous_inc_calc := 0;
    end if;
  --
    p_calc_spouse_inc_rec.sp_dividend_inc_calc := p_sp_dividend_inc_i - p_sp_dividend_inc_exp_i;
    -- basically this case is not happened.
    if p_calc_spouse_inc_rec.sp_dividend_inc_calc < 0 then
      p_calc_spouse_inc_rec.sp_dividend_inc_calc := 0;
    end if;
  --
    p_calc_spouse_inc_rec.sp_real_estate_inc_calc := p_sp_real_estate_inc_i - p_sp_real_estate_inc_exp_i;
    -- basically this case is not happened.
    if p_calc_spouse_inc_rec.sp_real_estate_inc_calc < 0 then
      p_calc_spouse_inc_rec.sp_real_estate_inc_calc := 0;
    end if;
  --
    p_calc_spouse_inc_rec.sp_retirement_inc_calc := trunc((p_sp_retirement_inc_i - p_sp_retirement_inc_exp_i) / 2);
    -- basically this case is not happened.
    if p_calc_spouse_inc_rec.sp_retirement_inc_calc < 0 then
      p_calc_spouse_inc_rec.sp_retirement_inc_calc := 0;
    end if;
  --
  -- currently sp_other_inc_exp_tmp_i and sp_other_inc_exp_tmp_exp is not supported on FormPG.
    if (p_sp_other_inc_exp_tmp_i - p_sp_other_inc_exp_tmp_exp_i) / 2 < 0 then
      p_calc_spouse_inc_rec.sp_other_inc_calc := p_sp_other_inc_i - p_sp_other_inc_exp_i;
    else
      if p_sp_other_inc_i - p_sp_other_inc_exp_tmp_i < 0 then
        p_calc_spouse_inc_rec.sp_other_inc_calc := 0;
      else
        if p_sp_other_inc_exp_i - p_sp_other_inc_exp_tmp_exp_i < 0 then
          p_calc_spouse_inc_rec.sp_other_inc_calc := 0;
        else
          p_calc_spouse_inc_rec.sp_other_inc_calc := ((p_sp_other_inc_i - p_sp_other_inc_exp_tmp_i)
                                                      - (p_sp_other_inc_exp_i - p_sp_other_inc_exp_tmp_exp_i))
                                                     + trunc((p_sp_other_inc_exp_tmp_i - p_sp_other_inc_exp_tmp_exp_i) / 2);
        end if;
      end if;
    end if;
    if p_calc_spouse_inc_rec.sp_other_inc_calc < 0 then
      p_calc_spouse_inc_rec.sp_other_inc_calc := 0;
    end if;
  --
    p_calc_spouse_inc_rec.sp_inc_calc := p_calc_spouse_inc_rec.sp_earned_inc_calc
                                         + p_calc_spouse_inc_rec.sp_business_inc_calc
                                         + p_calc_spouse_inc_rec.sp_miscellaneous_inc_calc
                                         + p_calc_spouse_inc_rec.sp_dividend_inc_calc
                                         + p_calc_spouse_inc_rec.sp_real_estate_inc_calc
                                         + p_calc_spouse_inc_rec.sp_retirement_inc_calc
                                         + p_calc_spouse_inc_rec.sp_other_inc_calc;
  --
  end if;
--
  -- basically use the calculated spouse inc, but use entry spouse inc if no record of sp_inc
  if p_sp_inc_cnt_i > 0 then
  --
    o_spouse_inc := p_calc_spouse_inc_rec.sp_inc_calc;
  --
  else
  --
    o_spouse_inc := p_ent_spouse_inc_i;
  --
  end if;
--
  if g_debug then
    hr_utility.trace('p_calc_spouse_inc_rec.sp_earned_inc_calc        : '||to_char(p_calc_spouse_inc_rec.sp_earned_inc_calc));
    hr_utility.trace('p_calc_spouse_inc_rec.sp_business_inc_calc      : '||to_char(p_calc_spouse_inc_rec.sp_business_inc_calc));
    hr_utility.trace('p_calc_spouse_inc_rec.sp_miscellaneous_inc_calc : '||to_char(p_calc_spouse_inc_rec.sp_miscellaneous_inc_calc));
    hr_utility.trace('p_calc_spouse_inc_rec.sp_dividend_inc_calc      : '||to_char(p_calc_spouse_inc_rec.sp_dividend_inc_calc));
    hr_utility.trace('p_calc_spouse_inc_rec.sp_real_estate_inc_calc   : '||to_char(p_calc_spouse_inc_rec.sp_real_estate_inc_calc));
    hr_utility.trace('p_calc_spouse_inc_rec.sp_retirement_inc_calc    : '||to_char(p_calc_spouse_inc_rec.sp_retirement_inc_calc));
    hr_utility.trace('p_calc_spouse_inc_rec.sp_other_inc_calc         : '||to_char(p_calc_spouse_inc_rec.sp_other_inc_calc));
    hr_utility.trace('p_sp_inc_cnt_i                                  : '||to_char(p_sp_inc_cnt_i));
    hr_utility.trace('p_calc_spouse_inc_rec.sp_inc_calc               : '||to_char(p_calc_spouse_inc_rec.sp_inc_calc));
    hr_utility.trace('p_ent_spouse_inc_i                              : '||to_char(p_ent_spouse_inc_i));
    hr_utility.trace('o_spouse_inc                                    : '||to_char(o_spouse_inc));
    hr_utility.set_location(l_proc,1000);
  end if;
--
  p_spouse_inc_o := o_spouse_inc;
--
end calc_spouse_inc;
--
-- -------------------------------------------------------------------------
-- calc_dct
-- -------------------------------------------------------------------------
procedure calc_dct(
  p_assignment_action_id in number,
  p_calc_dct_rec         out nocopy t_calc_dct_rec)
is
--
  l_proc varchar2(80) := c_package||'calc_ins';
  l_calc_total_rec t_calc_total_rec;
  l_calc_spouse_inc_rec t_calc_spouse_inc_rec;
--
  l_payroll_action_id number;
  l_business_group_id number;
  l_effective_date date;
--
  cursor csr_pact
  is
  select /* +ORDERED */
         ppa.payroll_action_id,
         ppa.business_group_id,
         ppa.effective_date
  from   pay_assignment_actions paa,
         pay_payroll_actions ppa
  where  paa.assignment_action_id = p_assignment_action_id
  and    ppa.payroll_action_id = paa.payroll_action_id;
--
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  calc_total(
    p_assignment_action_id => p_assignment_action_id,
    p_calc_total_rec       => l_calc_total_rec);
--
  p_calc_dct_rec.life_gen_ins_prem      := l_calc_total_rec.life_gen;
  p_calc_dct_rec.life_pens_ins_prem     := l_calc_total_rec.life_pens;
  p_calc_dct_rec.earthquake_ins_prem    := l_calc_total_rec.earthquake;
  p_calc_dct_rec.nonlife_long_ins_prem  := l_calc_total_rec.nonlife_long;
  p_calc_dct_rec.nonlife_short_ins_prem := l_calc_total_rec.nonlife_short;
  p_calc_dct_rec.national_pens_ins_prem := l_calc_total_rec.national_pens;
  p_calc_dct_rec.social_ins_prem        := l_calc_total_rec.social;
--
  open csr_pact;
  fetch csr_pact into l_payroll_action_id, l_business_group_id, l_effective_date;
  close csr_pact;
--
  calc_spouse_inc(
    p_sp_earned_inc_i            => l_calc_total_rec.sp_earned_inc,
    p_sp_earned_inc_exp_i        => l_calc_total_rec.sp_earned_inc_exp,
    p_sp_business_inc_i          => l_calc_total_rec.sp_business_inc,
    p_sp_business_inc_exp_i      => l_calc_total_rec.sp_business_inc_exp,
    p_sp_miscellaneous_inc_i     => l_calc_total_rec.sp_miscellaneous_inc,
    p_sp_miscellaneous_inc_exp_i => l_calc_total_rec.sp_miscellaneous_inc_exp,
    p_sp_dividend_inc_i          => l_calc_total_rec.sp_dividend_inc,
    p_sp_dividend_inc_exp_i      => l_calc_total_rec.sp_dividend_inc_exp,
    p_sp_real_estate_inc_i       => l_calc_total_rec.sp_real_estate_inc,
    p_sp_real_estate_inc_exp_i   => l_calc_total_rec.sp_real_estate_inc_exp,
    p_sp_retirement_inc_i        => l_calc_total_rec.sp_retirement_inc,
    p_sp_retirement_inc_exp_i    => l_calc_total_rec.sp_retirement_inc_exp,
    p_sp_other_inc_i             => l_calc_total_rec.sp_other_inc,
    p_sp_other_inc_exp_i         => l_calc_total_rec.sp_other_inc_exp,
    p_sp_other_inc_exp_dct_i     => l_calc_total_rec.sp_other_inc_exp_dct,
    p_sp_other_inc_exp_tmp_i     => l_calc_total_rec.sp_other_inc_exp_tmp,
    p_sp_other_inc_exp_tmp_exp_i => l_calc_total_rec.sp_other_inc_exp_tmp_exp,
    p_business_group_id          => l_business_group_id,
    p_effective_date             => l_effective_date,
    p_sp_inc_cnt_i               => l_calc_total_rec.sp_inc_cnt,
    p_ent_spouse_inc_i           => l_calc_total_rec.sp_spouse_inc,
    p_calc_spouse_inc_rec        => l_calc_spouse_inc_rec,
    p_spouse_inc_o               => p_calc_dct_rec.spouse_inc);
--
  p_calc_dct_rec.sp_earned_inc_calc := l_calc_spouse_inc_rec.sp_earned_inc_calc;
  p_calc_dct_rec.sp_business_inc_calc := l_calc_spouse_inc_rec.sp_business_inc_calc;
  p_calc_dct_rec.sp_miscellaneous_inc_calc := l_calc_spouse_inc_rec.sp_miscellaneous_inc_calc;
  p_calc_dct_rec.sp_dividend_inc_calc := l_calc_spouse_inc_rec.sp_dividend_inc_calc;
  p_calc_dct_rec.sp_real_estate_inc_calc := l_calc_spouse_inc_rec.sp_real_estate_inc_calc;
  p_calc_dct_rec.sp_retirement_inc_calc := l_calc_spouse_inc_rec.sp_retirement_inc_calc;
  p_calc_dct_rec.sp_other_inc_calc := l_calc_spouse_inc_rec.sp_other_inc_calc;
  p_calc_dct_rec.sp_inc_calc := l_calc_spouse_inc_rec.sp_inc_calc;
--
  calc_life_ins_dct(
    p_life_gen_i        => l_calc_total_rec.life_gen,
    p_life_pens_i       => l_calc_total_rec.life_pens,
    p_business_group_id => l_business_group_id,
    p_effective_date    => l_effective_date,
    p_life_ins_dct_o    => p_calc_dct_rec.life_ins_deduction,
    p_life_gen_o        => p_calc_dct_rec.life_gen_ins_calc_prem,
    p_life_pens_o       => p_calc_dct_rec.life_pens_ins_calc_prem);
--
  calc_nonlife_dct(
    p_earthquake_i      => l_calc_total_rec.earthquake,
    p_nonlife_long_i    => l_calc_total_rec.nonlife_long,
    p_nonlife_short_i   => l_calc_total_rec.nonlife_short,
    p_business_group_id => l_business_group_id,
    p_effective_date    => l_effective_date,
    p_nonlife_dct_o     => p_calc_dct_rec.nonlife_ins_deduction,
    p_earthquake_o      => p_calc_dct_rec.earthquake_ins_calc_prem,
    p_nonlife_long_o    => p_calc_dct_rec.nonlife_long_ins_calc_prem,
    p_nonlife_short_o   => p_calc_dct_rec.nonlife_short_ins_calc_prem);
--
  calc_social_dct(
    p_social_i          => l_calc_total_rec.social,
    p_business_group_id => l_business_group_id,
    p_effective_date    => l_effective_date,
    p_social_dct_o      => p_calc_dct_rec.social_ins_deduction);
--
  calc_mutual_aid_dct(
    p_mutual_aid_ec_i   => l_calc_total_rec.mutual_aid_ec,
    p_mutual_aid_p_i    => l_calc_total_rec.mutual_aid_p,
    p_mutual_aid_dsc_i  => l_calc_total_rec.mutual_aid_dsc,
    p_business_group_id => l_business_group_id,
    p_effective_date    => l_effective_date,
    p_mutual_aid_dct_o  => p_calc_dct_rec.mutual_aid_deduction);
--
  calc_spouse_dct(
    p_spouse_income_i   => p_calc_dct_rec.spouse_inc,
    p_emp_income_i      => l_calc_total_rec.sp_emp_inc,
    p_sp_type_i         => l_calc_total_rec.sp_sp_type,
    p_wid_type_i        => l_calc_total_rec.sp_wid_type,
    p_dct_exc_i         => l_calc_total_rec.sp_dct_exc,
    p_business_group_id => l_business_group_id,
    p_effective_date    => l_effective_date,
    p_spouse_dct_o      => p_calc_dct_rec.spouse_deduction);
--
  -- cache in case payroll_action_id is same.
  if g_payroll_action_id is null
  or (g_payroll_action_id <> l_payroll_action_id
     and l_payroll_action_id is not null) then
  --
    g_payroll_action_id := l_payroll_action_id;
    g_business_group_id := l_business_group_id;
    g_effective_date  := l_effective_date;
  --
  end if;
--
  if g_debug then
    hr_utility.trace('end update_assact');
    hr_utility.set_location(l_proc,1000);
  end if;
--
end calc_dct;
--
-- -------------------------------------------------------------------------
-- do_calculate
-- -------------------------------------------------------------------------
procedure do_calculate(
  p_action_information_id in number,
  p_object_version_number in out nocopy number)
is
--
  l_proc varchar2(80) := c_package||'do_calculate';
  l_submission_date date;
  l_assact_rec pay_jp_isdf_assact_v%rowtype;
  l_calc_dct_rec t_calc_dct_rec;
  l_action_information_id number;
  l_object_version_number number;
--
  cursor csr_calc_dct
  is
  select *
  from   pay_jp_isdf_calc_dct_v
  where  assignment_action_id = l_assact_rec.assignment_action_id
  and    action_context_type = 'AAP'
  and    action_information_category = 'JP_ISDF_CALC_DCT'
  and    status <> 'D';
--
  l_csr_calc_dct csr_calc_dct%rowtype;
--
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  l_submission_date := check_submission_period(p_action_information_id);
--
  if g_debug then
    hr_utility.set_location(l_proc,10);
    hr_utility.trace('submission_date  : '||fnd_date.date_to_canonical(l_submission_date));
  end if;
--
  -- unnecessary to lock
  select *
  into   l_assact_rec
  from   pay_jp_isdf_assact_v
  where  action_information_id = p_action_information_id;
--
  if l_assact_rec.transaction_status <> 'N' then
    fnd_message.set_name('PAY','PAY_JP_DEF_INVALID_TXN_STATUS');
    fnd_message.raise_error;
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,20);
    hr_utility.trace('action_information_id  : '||p_action_information_id);
    hr_utility.trace('object_version_number  : '||p_object_version_number);
    hr_utility.trace('assignment_action_id   : '||l_assact_rec.assignment_action_id);
    hr_utility.trace('start calc_ins');
  end if;
--
  calc_dct(
    p_assignment_action_id => l_assact_rec.assignment_action_id,
    p_calc_dct_rec         => l_calc_dct_rec);
--
  open csr_calc_dct;
  fetch csr_calc_dct into l_csr_calc_dct;
  close csr_calc_dct;
--
  if l_csr_calc_dct.action_information_id is null then
  --
    select pay_action_information_s.nextval
    into   l_action_information_id
    from   dual;
  --
    pay_jp_isdf_dml_pkg.create_calc_dct(
      p_action_information_id        => l_action_information_id,
      p_assignment_action_id         => l_assact_rec.assignment_action_id,
      p_action_context_type          => 'AAP',
      p_assignment_id                => l_assact_rec.assignment_id,
      p_effective_date               => l_assact_rec.effective_date,
      p_action_information_category  => 'JP_ISDF_CALC_DCT',
      p_status                       => 'I',
      p_life_gen_ins_prem            => l_calc_dct_rec.life_gen_ins_prem,
      p_life_pens_ins_prem           => l_calc_dct_rec.life_pens_ins_prem,
      p_life_gen_ins_calc_prem       => l_calc_dct_rec.life_gen_ins_calc_prem,
      p_life_pens_ins_calc_prem      => l_calc_dct_rec.life_pens_ins_calc_prem,
      p_life_ins_deduction           => l_calc_dct_rec.life_ins_deduction,
      p_nonlife_long_ins_prem        => l_calc_dct_rec.nonlife_long_ins_prem,
      p_nonlife_short_ins_prem       => l_calc_dct_rec.nonlife_short_ins_prem,
      p_earthquake_ins_prem          => l_calc_dct_rec.earthquake_ins_prem,
      p_nonlife_long_ins_calc_prem   => l_calc_dct_rec.nonlife_long_ins_calc_prem,
      p_nonlife_short_ins_calc_prem  => l_calc_dct_rec.nonlife_short_ins_calc_prem,
      p_earthquake_ins_calc_prem     => l_calc_dct_rec.earthquake_ins_calc_prem,
      p_nonlife_ins_deduction        => l_calc_dct_rec.nonlife_ins_deduction,
      p_national_pens_ins_prem       => l_calc_dct_rec.national_pens_ins_prem,
      p_social_ins_deduction         => l_calc_dct_rec.social_ins_deduction,
      p_mutual_aid_deduction         => l_calc_dct_rec.mutual_aid_deduction,
      p_sp_earned_income_calc        => l_calc_dct_rec.sp_earned_inc_calc,
      p_sp_business_income_calc      => l_calc_dct_rec.sp_business_inc_calc,
      p_sp_miscellaneous_income_calc => l_calc_dct_rec.sp_miscellaneous_inc_calc,
      p_sp_dividend_income_calc      => l_calc_dct_rec.sp_dividend_inc_calc,
      p_sp_real_estate_income_calc   => l_calc_dct_rec.sp_real_estate_inc_calc,
      p_sp_retirement_income_calc    => l_calc_dct_rec.sp_retirement_inc_calc,
      p_sp_other_income_calc         => l_calc_dct_rec.sp_other_inc_calc,
      p_sp_income_calc               => l_calc_dct_rec.sp_inc_calc,
      p_spouse_income                => l_calc_dct_rec.spouse_inc,
      p_spouse_deduction             => l_calc_dct_rec.spouse_deduction,
      p_object_version_number        => l_object_version_number);
  --
  else
  --
    l_action_information_id := l_csr_calc_dct.action_information_id;
    l_object_version_number := l_csr_calc_dct.object_version_number;
  --
  -- calc_dct is always insert mode because no initial archive data.
    pay_jp_isdf_dml_pkg.update_calc_dct(
      p_action_information_id        => l_action_information_id,
      p_object_version_number        => l_object_version_number,
      p_status                       => 'I',
      p_life_gen_ins_prem            => l_calc_dct_rec.life_gen_ins_prem,
      p_life_pens_ins_prem           => l_calc_dct_rec.life_pens_ins_prem,
      p_life_gen_ins_calc_prem       => l_calc_dct_rec.life_gen_ins_calc_prem,
      p_life_pens_ins_calc_prem      => l_calc_dct_rec.life_pens_ins_calc_prem,
      p_life_ins_deduction           => l_calc_dct_rec.life_ins_deduction,
      p_nonlife_long_ins_prem        => l_calc_dct_rec.nonlife_long_ins_prem,
      p_nonlife_short_ins_prem       => l_calc_dct_rec.nonlife_short_ins_prem,
      p_earthquake_ins_prem          => l_calc_dct_rec.earthquake_ins_prem,
      p_nonlife_long_ins_calc_prem   => l_calc_dct_rec.nonlife_long_ins_calc_prem,
      p_nonlife_short_ins_calc_prem  => l_calc_dct_rec.nonlife_short_ins_calc_prem,
      p_earthquake_ins_calc_prem     => l_calc_dct_rec.earthquake_ins_calc_prem,
      p_nonlife_ins_deduction        => l_calc_dct_rec.nonlife_ins_deduction,
      p_national_pens_ins_prem       => l_calc_dct_rec.national_pens_ins_prem,
      p_social_ins_deduction         => l_calc_dct_rec.social_ins_deduction,
      p_mutual_aid_deduction         => l_calc_dct_rec.mutual_aid_deduction,
      p_sp_earned_income_calc        => l_calc_dct_rec.sp_earned_inc_calc,
      p_sp_business_income_calc      => l_calc_dct_rec.sp_business_inc_calc,
      p_sp_miscellaneous_income_calc => l_calc_dct_rec.sp_miscellaneous_inc_calc,
      p_sp_dividend_income_calc      => l_calc_dct_rec.sp_dividend_inc_calc,
      p_sp_real_estate_income_calc   => l_calc_dct_rec.sp_real_estate_inc_calc,
      p_sp_retirement_income_calc    => l_calc_dct_rec.sp_retirement_inc_calc,
      p_sp_other_income_calc         => l_calc_dct_rec.sp_other_inc_calc,
      p_sp_income_calc               => l_calc_dct_rec.sp_inc_calc,
      p_spouse_income                => l_calc_dct_rec.spouse_inc,
      p_spouse_deduction             => l_calc_dct_rec.spouse_deduction);
  --
  end if;
--
  if g_debug then
    hr_utility.trace('end update_assact');
    hr_utility.set_location(l_proc,1000);
  end if;
--
end do_calculate;
--
-- -------------------------------------------------------------------------
-- do_finalize
-- -------------------------------------------------------------------------
procedure do_finalize(
  p_action_information_id in number,
  p_object_version_number in out nocopy number,
  p_user_comments         in varchar2)
is
--
  l_proc varchar2(80) := c_package||'do_finalize';
  l_submission_date date;
  l_assact_rec pay_jp_isdf_assact_v%rowtype;
  l_calc_dct_rec t_calc_dct_rec;
  l_action_information_id number;
  l_object_version_number number;
--
  cursor csr_calc_dct
  is
  select *
  from   pay_jp_isdf_calc_dct_v
  where  assignment_action_id = l_assact_rec.assignment_action_id
  and    action_context_type = 'AAP'
  and    action_information_category = 'JP_ISDF_CALC_DCT'
  and    status <> 'D';
--
  l_csr_calc_dct csr_calc_dct%rowtype;
--
  cursor csr_entry
  is
  select *
  from   pay_jp_isdf_entry_v
  where  assignment_action_id = l_assact_rec.assignment_action_id
  and    action_context_type = 'AAP'
  and    action_information_category = 'JP_ISDF_ENTRY'
  and    status <> 'D';
--
  l_csr_entry csr_entry%rowtype;
--
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  l_submission_date := check_submission_period(p_action_information_id);
--
  if g_debug then
    hr_utility.set_location(l_proc,10);
    hr_utility.trace('submission_date  : '||fnd_date.date_to_canonical(l_submission_date));
  end if;
--
  pay_jp_isdf_dml_pkg.lock_assact(p_action_information_id, p_object_version_number, l_assact_rec);
--
  if l_assact_rec.transaction_status <> 'N' then
    fnd_message.set_name('PAY','PAY_JP_DEF_INVALID_TXN_STATUS');
    fnd_message.raise_error;
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,20);
    hr_utility.trace('action_information_id  : '||p_action_information_id);
    hr_utility.trace('object_version_number  : '||p_object_version_number);
    hr_utility.trace('assignment_action_id   : '||l_assact_rec.assignment_action_id);
    hr_utility.trace('start calc_dct before finalize');
  end if;
--
  calc_dct(
    p_assignment_action_id => l_assact_rec.assignment_action_id,
    p_calc_dct_rec         => l_calc_dct_rec);
--
  open csr_calc_dct;
  fetch csr_calc_dct into l_csr_calc_dct;
  close csr_calc_dct;
--
  if l_csr_calc_dct.action_information_id is null then
  --
    select pay_action_information_s.nextval
    into   l_action_information_id
    from   dual;
  --
    pay_jp_isdf_dml_pkg.create_calc_dct(
      p_action_information_id        => l_action_information_id,
      p_assignment_action_id         => l_assact_rec.assignment_action_id,
      p_action_context_type          => 'AAP',
      p_assignment_id                => l_assact_rec.assignment_id,
      p_effective_date               => l_assact_rec.effective_date,
      p_action_information_category  => 'JP_ISDF_CALC_DCT',
      p_status                       => 'I',
      p_life_gen_ins_prem            => l_calc_dct_rec.life_gen_ins_prem,
      p_life_pens_ins_prem           => l_calc_dct_rec.life_pens_ins_prem,
      p_life_gen_ins_calc_prem       => l_calc_dct_rec.life_gen_ins_calc_prem,
      p_life_pens_ins_calc_prem      => l_calc_dct_rec.life_pens_ins_calc_prem,
      p_life_ins_deduction           => l_calc_dct_rec.life_ins_deduction,
      p_nonlife_long_ins_prem        => l_calc_dct_rec.nonlife_long_ins_prem,
      p_nonlife_short_ins_prem       => l_calc_dct_rec.nonlife_short_ins_prem,
      p_earthquake_ins_prem          => l_calc_dct_rec.earthquake_ins_prem,
      p_nonlife_long_ins_calc_prem   => l_calc_dct_rec.nonlife_long_ins_calc_prem,
      p_nonlife_short_ins_calc_prem  => l_calc_dct_rec.nonlife_short_ins_calc_prem,
      p_earthquake_ins_calc_prem     => l_calc_dct_rec.earthquake_ins_calc_prem,
      p_nonlife_ins_deduction        => l_calc_dct_rec.nonlife_ins_deduction,
      p_national_pens_ins_prem       => l_calc_dct_rec.national_pens_ins_prem,
      p_social_ins_deduction         => l_calc_dct_rec.social_ins_deduction,
      p_mutual_aid_deduction         => l_calc_dct_rec.mutual_aid_deduction,
      p_sp_earned_income_calc        => l_calc_dct_rec.sp_earned_inc_calc,
      p_sp_business_income_calc      => l_calc_dct_rec.sp_business_inc_calc,
      p_sp_miscellaneous_income_calc => l_calc_dct_rec.sp_miscellaneous_inc_calc,
      p_sp_dividend_income_calc      => l_calc_dct_rec.sp_dividend_inc_calc,
      p_sp_real_estate_income_calc   => l_calc_dct_rec.sp_real_estate_inc_calc,
      p_sp_retirement_income_calc    => l_calc_dct_rec.sp_retirement_inc_calc,
      p_sp_other_income_calc         => l_calc_dct_rec.sp_other_inc_calc,
      p_sp_income_calc               => l_calc_dct_rec.sp_inc_calc,
      p_spouse_income                => l_calc_dct_rec.spouse_inc,
      p_spouse_deduction             => l_calc_dct_rec.spouse_deduction,
      p_object_version_number        => l_object_version_number);
  --
  else
  --
    l_action_information_id := l_csr_calc_dct.action_information_id;
    l_object_version_number := l_csr_calc_dct.object_version_number;
  --
  -- calc_dct is always insert mode because no initial archive data.
    pay_jp_isdf_dml_pkg.update_calc_dct(
      p_action_information_id        => l_action_information_id,
      p_object_version_number        => l_object_version_number,
      p_status                       => 'I',
      p_life_gen_ins_prem            => l_calc_dct_rec.life_gen_ins_prem,
      p_life_pens_ins_prem           => l_calc_dct_rec.life_pens_ins_prem,
      p_life_gen_ins_calc_prem       => l_calc_dct_rec.life_gen_ins_calc_prem,
      p_life_pens_ins_calc_prem      => l_calc_dct_rec.life_pens_ins_calc_prem,
      p_life_ins_deduction           => l_calc_dct_rec.life_ins_deduction,
      p_nonlife_long_ins_prem        => l_calc_dct_rec.nonlife_long_ins_prem,
      p_nonlife_short_ins_prem       => l_calc_dct_rec.nonlife_short_ins_prem,
      p_earthquake_ins_prem          => l_calc_dct_rec.earthquake_ins_prem,
      p_nonlife_long_ins_calc_prem   => l_calc_dct_rec.nonlife_long_ins_calc_prem,
      p_nonlife_short_ins_calc_prem  => l_calc_dct_rec.nonlife_short_ins_calc_prem,
      p_earthquake_ins_calc_prem     => l_calc_dct_rec.earthquake_ins_calc_prem,
      p_nonlife_ins_deduction        => l_calc_dct_rec.nonlife_ins_deduction,
      p_national_pens_ins_prem       => l_calc_dct_rec.national_pens_ins_prem,
      p_social_ins_deduction         => l_calc_dct_rec.social_ins_deduction,
      p_mutual_aid_deduction         => l_calc_dct_rec.mutual_aid_deduction,
      p_sp_earned_income_calc        => l_calc_dct_rec.sp_earned_inc_calc,
      p_sp_business_income_calc      => l_calc_dct_rec.sp_business_inc_calc,
      p_sp_miscellaneous_income_calc => l_calc_dct_rec.sp_miscellaneous_inc_calc,
      p_sp_dividend_income_calc      => l_calc_dct_rec.sp_dividend_inc_calc,
      p_sp_real_estate_income_calc   => l_calc_dct_rec.sp_real_estate_inc_calc,
      p_sp_retirement_income_calc    => l_calc_dct_rec.sp_retirement_inc_calc,
      p_sp_other_income_calc         => l_calc_dct_rec.sp_other_inc_calc,
      p_sp_income_calc               => l_calc_dct_rec.sp_inc_calc,
      p_spouse_income                => l_calc_dct_rec.spouse_inc,
      p_spouse_deduction             => l_calc_dct_rec.spouse_deduction);
  --
  end if;
--
  -- Originally jp_isdf_entry should be made at the time of transfer
  -- because latest pre-set entry data in the transfer time is not same
  -- as the condition at the time of archive.
  -- However, finalize action is to fix all entry data except for _o prefex columns,
  -- so make jp_isdf_entry.
--
  open csr_entry;
  fetch csr_entry into l_csr_entry;
  close csr_entry;
--
  if l_csr_entry.action_information_id is null then
  --
    select pay_action_information_s.nextval
    into   l_action_information_id
    from   dual;
  --
    pay_jp_isdf_dml_pkg.create_entry(
      p_action_information_id        => l_action_information_id,
      p_assignment_action_id         => l_assact_rec.assignment_action_id,
      p_action_context_type          => 'AAP',
      p_assignment_id                => l_assact_rec.assignment_id,
      p_effective_date               => l_assact_rec.effective_date,
      p_action_information_category  => 'JP_ISDF_ENTRY',
      p_status                       => 'I',
      p_ins_datetrack_update_mode    => null,
      p_ins_element_entry_id         => null,
      p_ins_ee_object_version_number => null,
      p_life_gen_ins_prem            => l_calc_dct_rec.life_gen_ins_prem,
      p_life_gen_ins_prem_o          => null,
      p_life_pens_ins_prem           => l_calc_dct_rec.life_pens_ins_prem,
      p_life_pens_ins_prem_o         => null,
      p_nonlife_long_ins_prem        => l_calc_dct_rec.nonlife_long_ins_prem,
      p_nonlife_long_ins_prem_o      => null,
      p_nonlife_short_ins_prem       => l_calc_dct_rec.nonlife_short_ins_prem,
      p_nonlife_short_ins_prem_o     => null,
      p_earthquake_ins_prem          => l_calc_dct_rec.earthquake_ins_prem,
      p_earthquake_ins_prem_o        => null,
      p_is_datetrack_update_mode     => null,
      p_is_element_entry_id          => null,
      p_is_ee_object_version_number  => null,
      p_social_ins_prem              => l_calc_dct_rec.social_ins_deduction,
      p_social_ins_prem_o            => null,
      p_mutual_aid_prem              => l_calc_dct_rec.mutual_aid_deduction,
      p_mutual_aid_prem_o            => null,
      p_spouse_income                => l_calc_dct_rec.spouse_inc,
      p_spouse_income_o              => null,
      p_national_pens_ins_prem       => l_calc_dct_rec.national_pens_ins_prem,
      p_national_pens_ins_prem_o     => null,
      p_object_version_number        => l_object_version_number);
  --
  else
  --
    l_action_information_id := l_csr_entry.action_information_id;
    l_object_version_number := l_csr_entry.object_version_number;
  --
    -- if entry data was extracted from entry at the initial archive time,
    -- entry data has been set, otherwise, once the finalized entry data
    -- is changed to return status, then the data is finalized again in second time,
    -- it is not queried data and newly inserted in previous finalize time.
    -- so that the element_entry is not set, it means the previous finalized data.
    -- it can be overriden.
    --
    if l_csr_entry.ins_element_entry_id is not null
    or l_csr_entry.is_element_entry_id is not null then
    --
      pay_jp_isdf_dml_pkg.update_entry(
        p_action_information_id    => l_action_information_id,
        p_object_version_number    => l_object_version_number,
        p_status                   => 'Q',
        p_life_gen_ins_prem        => l_calc_dct_rec.life_gen_ins_prem,
        p_life_gen_ins_prem_o      => l_csr_entry.life_gen_ins_prem,
        p_life_pens_ins_prem       => l_calc_dct_rec.life_pens_ins_prem,
        p_life_pens_ins_prem_o     => l_csr_entry.life_pens_ins_prem,
        p_nonlife_long_ins_prem    => l_calc_dct_rec.nonlife_long_ins_prem,
        p_nonlife_long_ins_prem_o  => l_csr_entry.nonlife_long_ins_prem,
        p_nonlife_short_ins_prem   => l_calc_dct_rec.nonlife_short_ins_prem,
        p_nonlife_short_ins_prem_o => l_csr_entry.nonlife_short_ins_prem,
        p_earthquake_ins_prem      => l_calc_dct_rec.earthquake_ins_prem,
        p_earthquake_ins_prem_o    => l_csr_entry.earthquake_ins_prem,
        p_social_ins_prem          => l_calc_dct_rec.social_ins_deduction,
        p_social_ins_prem_o        => l_csr_entry.social_ins_prem,
        p_mutual_aid_prem          => l_calc_dct_rec.mutual_aid_deduction,
        p_mutual_aid_prem_o        => l_csr_entry.mutual_aid_prem,
        p_spouse_income            => l_calc_dct_rec.spouse_inc,
        p_spouse_income_o          => l_csr_entry.spouse_income,
        p_national_pens_ins_prem   => l_calc_dct_rec.national_pens_ins_prem,
        p_national_pens_ins_prem_o => l_csr_entry.national_pens_ins_prem);
    --
    else
    --
      pay_jp_isdf_dml_pkg.update_entry(
        p_action_information_id    => l_action_information_id,
        p_object_version_number    => l_object_version_number,
        p_status                   => 'I',
        p_life_gen_ins_prem        => l_calc_dct_rec.life_gen_ins_prem,
        p_life_gen_ins_prem_o      => null,
        p_life_pens_ins_prem       => l_calc_dct_rec.life_pens_ins_prem,
        p_life_pens_ins_prem_o     => null,
        p_nonlife_long_ins_prem    => l_calc_dct_rec.nonlife_long_ins_prem,
        p_nonlife_long_ins_prem_o  => null,
        p_nonlife_short_ins_prem   => l_calc_dct_rec.nonlife_short_ins_prem,
        p_nonlife_short_ins_prem_o => null,
        p_earthquake_ins_prem      => l_calc_dct_rec.earthquake_ins_prem,
        p_earthquake_ins_prem_o    => null,
        p_social_ins_prem          => l_calc_dct_rec.social_ins_deduction,
        p_social_ins_prem_o        => null,
        p_mutual_aid_prem          => l_calc_dct_rec.mutual_aid_deduction,
        p_mutual_aid_prem_o        => null,
        p_spouse_income            => l_calc_dct_rec.spouse_inc,
        p_spouse_income_o          => null,
        p_national_pens_ins_prem   => l_calc_dct_rec.national_pens_ins_prem,
        p_national_pens_ins_prem_o => null);
    --
    end if;
  --
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,20);
    hr_utility.trace('end calc_dct before finalize');
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,20);
    hr_utility.trace('action_information_id  : '||p_action_information_id);
    hr_utility.trace('object_version_number  : '||p_object_version_number);
    hr_utility.trace('assignment_action_id   : '||l_assact_rec.assignment_action_id);
    hr_utility.trace('start update_assact');
  end if;
--
  p_object_version_number := l_assact_rec.object_version_number + 1;
--
  --api is disable because assact has been locked.
  --pay_jp_isdf_dml_pkg.update_assact(
  --  p_action_information_id => l_assact_rec.assignment_action_id,
  --  p_object_version_number => p_object_version_number,
  --  p_transaction_status    => 'F',
  --  p_finalized_date        => fnd_date.date_to_canonical(l_submission_date),
  --  p_finalized_by          => fnd_number.number_to_canonical(fnd_global.user_id),
  --  p_user_comments         => p_user_comments,
  --  p_admin_comments        => l_assact_rec.admin_comments,
  --  p_transfer_status       => l_assact_rec.transfer_status,
  --  p_transfer_date         => l_assact_rec.transfer_date,
  --  p_expiry_date           => l_assact_rec.expiry_date);
  update pay_jp_isdf_assact_dml_v
  set    object_version_number = p_object_version_number,
         transaction_status    = 'F',
         finalized_date        = fnd_date.date_to_canonical(l_submission_date),
         finalized_by          = fnd_number.number_to_canonical(fnd_global.user_id),
         user_comments         = p_user_comments
  where  row_id = l_assact_rec.row_id;
--
  if g_debug then
    hr_utility.trace('end update_assact');
    hr_utility.set_location(l_proc,1000);
  end if;
--
end do_finalize;
--
-- -------------------------------------------------------------------------
-- do_reject
-- -------------------------------------------------------------------------
procedure do_reject(
  p_action_information_id in number,
  p_object_version_number in out nocopy number,
  p_admin_comments        in varchar2)
is
--
  l_proc varchar2(80) := c_package||'do_finalize';
  l_submission_date date;
  l_assact_rec pay_jp_isdf_assact_v%rowtype;
--
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  l_submission_date := check_submission_period(p_action_information_id);
--
  if g_debug then
    hr_utility.set_location(l_proc,10);
    hr_utility.trace('submission_date  : '||fnd_date.date_to_canonical(l_submission_date));
  end if;
--
  pay_jp_isdf_dml_pkg.lock_assact(p_action_information_id, p_object_version_number, l_assact_rec);
--
  if l_assact_rec.transaction_status not in ('F', 'A') then
    fnd_message.set_name('PAY', 'PAY_JP_DEF_INVALID_TXN_STATUS');
    fnd_message.raise_error;
  elsif l_assact_rec.transfer_status <> 'U' then
    fnd_message.set_name('PAY','PAY_JP_DEF_ALREADY_TRANSFERRED');
    fnd_message.raise_error;
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,20);
    hr_utility.trace('action_information_id  : '||p_action_information_id);
    hr_utility.trace('object_version_number  : '||p_object_version_number);
    hr_utility.trace('assignment_action_id   : '||l_assact_rec.assignment_action_id);
    hr_utility.trace('start calc_dct before finalize');
  end if;
--
  delete
  from  pay_action_information
  where action_context_id = l_assact_rec.assignment_action_id
  and   action_context_type = 'AAP'
  and   action_information_category <> 'JP_ISDF_ASSACT';
--
  if g_debug then
    hr_utility.set_location(l_proc,20);
    hr_utility.trace('action_information_id  : '||p_action_information_id);
    hr_utility.trace('object_version_number  : '||p_object_version_number);
    hr_utility.trace('assignment_action_id   : '||l_assact_rec.assignment_action_id);
    hr_utility.trace('start update_assact');
  end if;
--
  p_object_version_number := l_assact_rec.object_version_number + 1;
--
  --api is disable because assact has been locked.
  --pay_jp_isdf_dml_pkg.update_assact(
  --  p_action_information_id => l_assact_rec.assignment_action_id,
  --  p_object_version_number => p_object_version_number,
  --  p_transaction_status    => 'U',
  --  p_finalized_date        => null,
  --  p_finalized_by          => null,
  --  p_user_comments         => l_assact_rec.user_comments,
  --  p_admin_comments        => p_admin_comments,
  --  p_transfer_status       => l_assact_rec.transfer_status,
  --  p_transfer_date         => l_assact_rec.transfer_date,
  --  p_expiry_date           => l_assact_rec.expiry_date);
  update pay_jp_isdf_assact_dml_v
  set    object_version_number = p_object_version_number,
         transaction_status    = 'U',
         finalized_date        = null,
         finalized_by          = null,
         admin_comments        = p_admin_comments
  where  row_id = l_assact_rec.row_id;
--
  if g_debug then
    hr_utility.trace('end update_assact');
    hr_utility.set_location(l_proc,1000);
  end if;
--
end do_reject;
--
-- -------------------------------------------------------------------------
-- do_return
-- -------------------------------------------------------------------------
procedure do_return(
  p_action_information_id in number,
  p_object_version_number in out nocopy number,
  p_admin_comments        in varchar2)
is
--
  l_proc varchar2(80) := c_package||'do_return';
  l_submission_date date;
  l_assact_rec pay_jp_isdf_assact_v%rowtype;
--
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  l_submission_date := check_submission_period(p_action_information_id);
--
  if g_debug then
    hr_utility.set_location(l_proc,10);
    hr_utility.trace('submission_date  : '||fnd_date.date_to_canonical(l_submission_date));
  end if;
--
  pay_jp_isdf_dml_pkg.lock_assact(p_action_information_id, p_object_version_number, l_assact_rec);
--
  if l_assact_rec.transaction_status not in ('F', 'A') then
    fnd_message.set_name('PAY', 'PAY_JP_DEF_INVALID_TXN_STATUS');
    fnd_message.raise_error;
  elsif l_assact_rec.transfer_status <> 'U' then
    fnd_message.set_name('PAY','PAY_JP_DEF_ALREADY_TRANSFERRED');
    fnd_message.raise_error;
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,20);
    hr_utility.trace('action_information_id  : '||p_action_information_id);
    hr_utility.trace('object_version_number  : '||p_object_version_number);
    hr_utility.trace('assignment_action_id   : '||l_assact_rec.assignment_action_id);
    hr_utility.trace('start calc_dct before finalize');
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,20);
    hr_utility.trace('action_information_id  : '||p_action_information_id);
    hr_utility.trace('object_version_number  : '||p_object_version_number);
    hr_utility.trace('assignment_action_id   : '||l_assact_rec.assignment_action_id);
    hr_utility.trace('start update_assact');
  end if;
--
  p_object_version_number := l_assact_rec.object_version_number + 1;
--
  --api is disable because assact has been locked.
  --pay_jp_isdf_dml_pkg.update_assact(
  --  p_action_information_id => l_assact_rec.assignment_action_id,
  --  p_object_version_number => p_object_version_number,
  --  p_transaction_status    => 'N',
  --  p_finalized_date        => null,
  --  p_finalized_by          => null,
  --  p_user_comments         => l_assact_rec.user_comments,
  --  p_admin_comments        => p_admin_comments,
  --  p_transfer_status       => l_assact_rec.transfer_status,
  --  p_transfer_date         => l_assact_rec.transfer_date,
  --  p_expiry_date           => l_assact_rec.expiry_date);
  update pay_jp_isdf_assact_dml_v
  set    object_version_number = p_object_version_number,
         transaction_status    = 'N',
         finalized_date        = null,
         finalized_by          = null,
         admin_comments        = p_admin_comments
  where  row_id = l_assact_rec.row_id;
--
  if g_debug then
    hr_utility.trace('end update_assact');
    hr_utility.set_location(l_proc,1000);
  end if;
--
end do_return;
--
-- -------------------------------------------------------------------------
-- do_approve
-- -------------------------------------------------------------------------
procedure do_approve(
  p_action_information_id in number,
  p_object_version_number in out nocopy number)
is
--
  l_proc varchar2(80) := c_package||'do_approve';
  l_assact_rec pay_jp_isdf_assact_v%rowtype;
--
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  pay_jp_isdf_dml_pkg.lock_assact(p_action_information_id, p_object_version_number, l_assact_rec);
--
  if l_assact_rec.transaction_status <> 'F' then
    fnd_message.set_name('PAY', 'PAY_JP_DEF_INVALID_TXN_STATUS');
    fnd_message.raise_error;
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,20);
    hr_utility.trace('action_information_id  : '||p_action_information_id);
    hr_utility.trace('object_version_number  : '||p_object_version_number);
    hr_utility.trace('assignment_action_id   : '||l_assact_rec.assignment_action_id);
    hr_utility.trace('start calc_dct before finalize');
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,20);
    hr_utility.trace('action_information_id  : '||p_action_information_id);
    hr_utility.trace('object_version_number  : '||p_object_version_number);
    hr_utility.trace('assignment_action_id   : '||l_assact_rec.assignment_action_id);
    hr_utility.trace('start update_assact');
  end if;
--
  p_object_version_number := l_assact_rec.object_version_number + 1;
--
  --api is disable because assact has been locked.
  --pay_jp_isdf_dml_pkg.update_assact(
  --  p_action_information_id => l_assact_rec.assignment_action_id,
  --  p_object_version_number => p_object_version_number,
  --  p_transaction_status    => 'A',
  --  p_finalized_date        => l_assact_rec.finalized_date,
  --  p_finalized_by          => l_assact_rec.finalized_by,
  --  p_user_comments         => l_assact_rec.user_comments,
  --  p_admin_comments        => l_assact_rec.admin_comments,
  --  p_transfer_status       => l_assact_rec.transfer_status,
  --  p_transfer_date         => l_assact_rec.transfer_date,
  --  p_expiry_date           => l_assact_rec.expiry_date);
  update pay_jp_isdf_assact_dml_v
  set    object_version_number = p_object_version_number,
         transaction_status    = 'A'
  where  row_id = l_assact_rec.row_id;
--
  if g_debug then
    hr_utility.trace('end update_assact');
    hr_utility.set_location(l_proc,1000);
  end if;
--
end do_approve;
--
-- -------------------------------------------------------------------------
-- insert_session
-- -------------------------------------------------------------------------
procedure insert_session(
            p_effective_date in date)
is
--
  l_rowid rowid;
--
  cursor csr_session
  is
  select rowid
  from   fnd_sessions
  where  session_id = userenv('sessionid')
  for update nowait;
--
begin
--
  open csr_session;
  fetch csr_session into l_rowid;
  --
    if csr_session%notfound then
    --
      insert into fnd_sessions(
        session_id,
        effective_date)
      values(
        userenv('sessionid'),
        p_effective_date);
    --
    else
    --
      update fnd_sessions
      set    effective_date = p_effective_date
      where rowid = l_rowid;
    --
    end if;
  --
  close csr_session;
--
end insert_session;
--
-- -------------------------------------------------------------------------
-- delete_session
-- -------------------------------------------------------------------------
procedure delete_session
is
begin
--
  delete
  from  fnd_sessions
  where session_id = userenv('sessionid');
--
end delete_session;
--
-- -------------------------------------------------------------------------
-- changed
-- -------------------------------------------------------------------------
function changed(
  value1 in varchar2,
  value2 in varchar2)
return boolean
is
begin
--
  if nvl(value1, hr_api.g_varchar2) <> nvl(value2, hr_api.g_varchar2) then
    return true;
  else
    return false;
  end if;
--
end changed;
--
function changed(
  value1 in number,
  value2 in number)
return boolean
is
begin
--
  if nvl(value1, hr_api.g_number) <> nvl(value2, hr_api.g_number) then
    return true;
  else
    return false;
  end if;
--
end changed;
--
function changed(
  value1 in date,
  value2 in date)
return boolean
is
begin
--
  if nvl(value1, hr_api.g_date) <> nvl(value2, hr_api.g_date) then
    return true;
  else
    return false;
  end if;
--
end changed;
--
-- -------------------------------------------------------------------------
-- transfer_entry
-- -------------------------------------------------------------------------
procedure transfer_entry(
  p_rec in out nocopy pay_jp_isdf_entry_v%rowtype,
  p_effective_date in date,
  p_expire_after_transfer in varchar2)
is
--
  l_proc varchar2(80) := c_package||'transfer_entry';
--
  l_effective_date date;
  l_esd date;
  l_eed date;
  l_warning boolean;
  l_ins_element_link_id number;
  l_is_element_link_id number;
--
  l_ins_element_entry_id number;
  l_ins_ee_object_version_number number;
  l_ins_datetrack_update_mode pay_jp_isdf_entry_v.ins_datetrack_update_mode%type;
  l_is_element_entry_id number;
  l_is_ee_object_version_number number;
  l_is_datetrack_update_mode pay_jp_isdf_entry_v.is_datetrack_update_mode%type;
  l_status pay_jp_isdf_entry_v.status%type;
--
  l_entry_rec pay_jp_isdf_archive_pkg.t_entry_rec;
--
  cursor csr_pact
  is
  select /* +ORDERED */
         ppa.payroll_action_id,
         ppa.business_group_id,
         ppa.effective_date
  from   pay_assignment_actions paa,
         pay_payroll_actions ppa
  where  paa.assignment_action_id = p_rec.assignment_action_id
  and    ppa.payroll_action_id = paa.payroll_action_id;
--
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  if p_effective_date is null then
    l_effective_date := p_rec.effective_date;
  else
    l_effective_date := p_effective_date;
  end if;
--
  -- re-extract current entry data on transfer date
  -- since jp_isdf_entry data was extracted on archive date.
  --
  if g_business_group_id is null
  or g_effective_date is null
  or g_effective_date <> l_effective_date then
  --
    g_payroll_action_id := null;
    g_business_group_id := null;
    g_effective_date := null;
   --
    open csr_pact;
    fetch csr_pact into g_payroll_action_id, g_business_group_id, g_effective_date;
    close csr_pact;
  --
  end if;
  --
  pay_jp_isdf_archive_pkg.fetch_entry(
    p_assignment_id     => p_rec.assignment_id,
    p_business_group_id => g_business_group_id,
    p_effective_date    => l_effective_date,
    p_entry_rec         => l_entry_rec);
  --
  if p_rec.status = 'I' then
  --
    -- even if rec status is 'I', eev might setup by manually at transfer run time.
    -- when entry exists, use new ovn, update mode at transfer time instead of stored data.
    if l_entry_rec.ins_entry_cnt > 0 then
    --
      pay_element_entry_api.update_element_entry(
        p_validate              => false,
        p_effective_date        => l_effective_date,
        p_business_group_id     => g_business_group_id,
        p_datetrack_update_mode => l_entry_rec.ins_datetrack_update_mode,
        p_element_entry_id      => l_entry_rec.ins_element_entry_id,
        p_object_version_number => l_entry_rec.ins_ee_object_version_number,
        p_input_value_id1       => c_life_gen_iv_id,
        p_input_value_id2       => c_life_pens_iv_id,
        p_input_value_id3       => c_nonlife_long_iv_id,
        p_input_value_id4       => c_nonlife_short_iv_id,
        p_input_value_id5       => c_earthquake_iv_id,
        p_entry_value1          => fnd_number.number_to_canonical(p_rec.life_gen_ins_prem),
        p_entry_value2          => fnd_number.number_to_canonical(p_rec.life_pens_ins_prem),
        p_entry_value3          => fnd_number.number_to_canonical(p_rec.nonlife_long_ins_prem),
        p_entry_value4          => fnd_number.number_to_canonical(p_rec.nonlife_short_ins_prem),
        p_entry_value5          => fnd_number.number_to_canonical(p_rec.earthquake_ins_prem),
        p_effective_start_date  => l_esd,
        p_effective_end_date    => l_eed,
        p_update_warning        => l_warning);
    --
      p_rec.status := 'Q';
      l_ins_element_entry_id := l_entry_rec.ins_element_entry_id;
      l_ins_ee_object_version_number := l_entry_rec.ins_ee_object_version_number;
      l_ins_datetrack_update_mode := l_entry_rec.ins_datetrack_update_mode;
    --
    else
    --
      l_ins_element_link_id := hr_entry_api.get_link(
                                 p_assignment_id   => p_rec.assignment_id,
                                 p_element_type_id => c_isdf_ins_elm_id,
                                 p_session_date    => l_effective_date);
    --
      if l_ins_element_link_id is null then
        fnd_message.set_name('PAY', 'PAY_JP_ISDF_NO_ELE_LINK');
        fnd_message.set_token('ELE_NAME',c_isdf_ins_elm);
        fnd_message.raise_error;
      end if;
   --
      pay_element_entry_api.create_element_entry(
        p_validate              => false,
        p_effective_date        => l_effective_date,
        p_business_group_id     => g_business_group_id,
        p_assignment_id         => p_rec.assignment_id,
        p_element_link_id       => l_ins_element_link_id,
        p_entry_type            => 'E',
        p_input_value_id1       => c_life_gen_iv_id,
        p_input_value_id2       => c_life_pens_iv_id,
        p_input_value_id3       => c_nonlife_long_iv_id,
        p_input_value_id4       => c_nonlife_short_iv_id,
        p_input_value_id5       => c_earthquake_iv_id,
        p_entry_value1          => fnd_number.number_to_canonical(p_rec.life_gen_ins_prem),
        p_entry_value2          => fnd_number.number_to_canonical(p_rec.life_pens_ins_prem),
        p_entry_value3          => fnd_number.number_to_canonical(p_rec.nonlife_long_ins_prem),
        p_entry_value4          => fnd_number.number_to_canonical(p_rec.nonlife_short_ins_prem),
        p_entry_value5          => fnd_number.number_to_canonical(p_rec.earthquake_ins_prem),
        p_element_entry_id      => p_rec.ins_element_entry_id,
        p_object_version_number => p_rec.ins_ee_object_version_number,
        p_effective_start_date  => l_esd,
        p_effective_end_date    => l_eed,
        p_create_warning        => l_warning);
    --
      l_ins_element_entry_id := p_rec.ins_element_entry_id;
      l_ins_ee_object_version_number := p_rec.ins_ee_object_version_number;
      l_ins_datetrack_update_mode := pay_jp_isdf_archive_pkg.ee_datetrack_update_mode(p_rec.ins_element_entry_id,l_esd,l_eed,l_effective_date);
    --
    end if;
    --
    -- even if rec status is 'I', eev might setup by manually at transfer run time.
    -- when entry exists, use new ovn, update mode at transfer time instead of stored data.
    if l_entry_rec.is_entry_cnt > 0 then
    --
      pay_element_entry_api.update_element_entry(
        p_validate              => false,
        p_effective_date        => l_effective_date,
        p_business_group_id     => g_business_group_id,
        p_datetrack_update_mode => l_entry_rec.is_datetrack_update_mode,
        p_element_entry_id      => l_entry_rec.is_element_entry_id,
        p_object_version_number => l_entry_rec.is_ee_object_version_number,
        p_input_value_id5       => c_social_iv_id,
        p_input_value_id6       => c_mutual_aid_iv_id,
        p_input_value_id7       => c_spouse_iv_id,
        p_input_value_id9       => c_national_pens_iv_id,
        p_entry_value5          => fnd_number.number_to_canonical(p_rec.social_ins_prem),
        p_entry_value6          => fnd_number.number_to_canonical(p_rec.mutual_aid_prem),
        p_entry_value7          => fnd_number.number_to_canonical(p_rec.spouse_income),
        p_entry_value9          => fnd_number.number_to_canonical(p_rec.national_pens_ins_prem),
        p_effective_start_date  => l_esd,
        p_effective_end_date    => l_eed,
        p_update_warning        => l_warning);
    --
      p_rec.status := 'Q';
      l_is_element_entry_id := l_entry_rec.is_element_entry_id;
      l_is_ee_object_version_number := l_entry_rec.is_ee_object_version_number;
      l_is_datetrack_update_mode := l_entry_rec.is_datetrack_update_mode;
    --
    else
    --
      l_is_element_link_id := hr_entry_api.get_link(
                                p_assignment_id   => p_rec.assignment_id,
                                p_element_type_id => c_isdf_is_elm_id,
                                p_session_date    => l_effective_date);
    --
      if l_is_element_link_id is null then
        fnd_message.set_name('PAY', 'PAY_JP_ISDF_NO_ELE_LINK');
        fnd_message.set_token('ELE_NAME',c_isdf_is_elm);
        fnd_message.raise_error;
      end if;
    --
      pay_element_entry_api.create_element_entry(
        p_validate              => false,
        p_effective_date        => l_effective_date,
        p_business_group_id     => g_business_group_id,
        p_assignment_id         => p_rec.assignment_id,
        p_element_link_id       => l_is_element_link_id,
        p_entry_type            => 'E',
        p_input_value_id5       => c_social_iv_id,
        p_input_value_id6       => c_mutual_aid_iv_id,
        p_input_value_id7       => c_spouse_iv_id,
        p_input_value_id9       => c_national_pens_iv_id,
        p_entry_value5          => fnd_number.number_to_canonical(p_rec.social_ins_prem),
        p_entry_value6          => fnd_number.number_to_canonical(p_rec.mutual_aid_prem),
        p_entry_value7          => fnd_number.number_to_canonical(p_rec.spouse_income),
        p_entry_value9          => fnd_number.number_to_canonical(p_rec.national_pens_ins_prem),
        p_element_entry_id      => p_rec.is_element_entry_id,
        p_object_version_number => p_rec.is_ee_object_version_number,
        p_effective_start_date  => l_esd,
        p_effective_end_date    => l_eed,
        p_create_warning        => l_warning);
    --
      l_is_element_entry_id := p_rec.is_element_entry_id;
      l_is_ee_object_version_number := p_rec.is_ee_object_version_number;
      l_is_datetrack_update_mode := pay_jp_isdf_archive_pkg.ee_datetrack_update_mode(p_rec.is_element_entry_id,l_esd,l_eed,l_effective_date);
    --
    end if;
    --
    p_rec.object_version_number := p_rec.object_version_number + 1;
    --
    if p_expire_after_transfer = 'Y' then
      l_status := 'D';
    -- p_rec.status = 'I' or 'Q' is now 'Q' because eev exists.
    else
      l_status := 'Q';
    end if;
    --
    -- revised old data at archive time to the latest extracted data.
    if p_rec.status = 'Q' then
    --
      update pay_jp_isdf_entry_dml_v
      set    object_version_number = p_rec.object_version_number,
             status = l_status,
             ins_datetrack_update_mode = l_ins_datetrack_update_mode,
             ins_element_entry_id = fnd_number.number_to_canonical(l_ins_element_entry_id),
             ins_ee_object_version_number = fnd_number.number_to_canonical(l_ins_ee_object_version_number),
             life_gen_ins_prem_o = l_entry_rec.life_gen_ins_prem,
             life_pens_ins_prem_o = l_entry_rec.life_pens_ins_prem,
             nonlife_long_ins_prem_o = l_entry_rec.nonlife_long_ins_prem,
             nonlife_short_ins_prem_o = l_entry_rec.nonlife_short_ins_prem,
             earthquake_ins_prem_o = l_entry_rec.earthquake_ins_prem,
             is_datetrack_update_mode = l_is_datetrack_update_mode,
             is_element_entry_id = fnd_number.number_to_canonical(l_is_element_entry_id),
             is_ee_object_version_number = fnd_number.number_to_canonical(l_is_ee_object_version_number),
             social_ins_prem_o = l_entry_rec.social_ins_prem,
             mutual_aid_prem_o = l_entry_rec.mutual_aid_prem,
             spouse_income_o = l_entry_rec.spouse_income,
             national_pens_ins_prem_o = l_entry_rec.national_pens_ins_prem
      where  row_id = p_rec.row_id;
    --
    else
    --
      update pay_jp_isdf_entry_dml_v
      set    object_version_number = p_rec.object_version_number,
             status = l_status,
             ins_datetrack_update_mode = l_ins_datetrack_update_mode,
             is_datetrack_update_mode = l_is_datetrack_update_mode,
             ins_element_entry_id = fnd_number.number_to_canonical(l_ins_element_entry_id),
             is_element_entry_id = fnd_number.number_to_canonical(l_is_element_entry_id),
             ins_ee_object_version_number = fnd_number.number_to_canonical(l_ins_ee_object_version_number),
             is_ee_object_version_number = fnd_number.number_to_canonical(l_is_ee_object_version_number)
      where row_id = p_rec.row_id;
    --
    end if;
  --
  elsif p_rec.status = 'Q' then
  --
    -- even if rec status is 'Q', eev might removed. specially if archive time is
    -- before december, the eev might not be set on december, transfer time.
    -- when entry exists, use new ovn, update mode at transfer time instead of stored data.
    if l_entry_rec.ins_entry_cnt > 0 then
    --
      if changed(p_rec.life_gen_ins_prem,l_entry_rec.life_gen_ins_prem)
      or changed(p_rec.life_pens_ins_prem,l_entry_rec.life_pens_ins_prem)
      or changed(p_rec.nonlife_long_ins_prem,l_entry_rec.nonlife_long_ins_prem)
      or ((l_effective_date < c_st_upd_date_2007 and changed(p_rec.nonlife_short_ins_prem,l_entry_rec.nonlife_short_ins_prem))
         or (l_effective_date >= c_st_upd_date_2007 and changed(p_rec.earthquake_ins_prem,l_entry_rec.earthquake_ins_prem))) then
      --
        pay_element_entry_api.update_element_entry(
          p_validate              => false,
          p_effective_date        => l_effective_date,
          p_business_group_id     => g_business_group_id,
          p_datetrack_update_mode => l_entry_rec.ins_datetrack_update_mode,
          p_element_entry_id      => l_entry_rec.ins_element_entry_id,
          p_object_version_number => l_entry_rec.ins_ee_object_version_number,
          p_input_value_id1       => c_life_gen_iv_id,
          p_input_value_id2       => c_life_pens_iv_id,
          p_input_value_id3       => c_nonlife_long_iv_id,
          p_input_value_id4       => c_nonlife_short_iv_id,
          p_input_value_id5       => c_earthquake_iv_id,
          p_entry_value1          => fnd_number.number_to_canonical(p_rec.life_gen_ins_prem),
          p_entry_value2          => fnd_number.number_to_canonical(p_rec.life_pens_ins_prem),
          p_entry_value3          => fnd_number.number_to_canonical(p_rec.nonlife_long_ins_prem),
          p_entry_value4          => fnd_number.number_to_canonical(p_rec.nonlife_short_ins_prem),
          p_entry_value5          => fnd_number.number_to_canonical(p_rec.earthquake_ins_prem),
          p_effective_start_date  => l_esd,
          p_effective_end_date    => l_eed,
          p_update_warning        => l_warning);
      --
      end if;
    --
      l_ins_element_entry_id := l_entry_rec.ins_element_entry_id;
      l_ins_ee_object_version_number := l_entry_rec.ins_ee_object_version_number;
      l_ins_datetrack_update_mode := l_entry_rec.ins_datetrack_update_mode;
    --
    else
    --
      -- this status soonly will be changed to 'Q' after insert.
      p_rec.status := 'I';
    --
      l_ins_element_link_id := hr_entry_api.get_link(
                                 p_assignment_id   => p_rec.assignment_id,
                                 p_element_type_id => c_isdf_ins_elm_id,
                                 p_session_date    => l_effective_date);
    --
      if l_ins_element_link_id is null then
        fnd_message.set_name('PAY', 'PAY_JP_ISDF_NO_ELE_LINK');
        fnd_message.set_token('ELE_NAME',c_isdf_ins_elm);
        fnd_message.raise_error;
      end if;
    --
      pay_element_entry_api.create_element_entry(
        p_validate              => false,
        p_effective_date        => l_effective_date,
        p_business_group_id     => g_business_group_id,
        p_assignment_id         => p_rec.assignment_id,
        p_element_link_id       => l_ins_element_link_id,
        p_entry_type            => 'E',
        p_input_value_id1       => c_life_gen_iv_id,
        p_input_value_id2       => c_life_pens_iv_id,
        p_input_value_id3       => c_nonlife_long_iv_id,
        p_input_value_id4       => c_nonlife_short_iv_id,
        p_input_value_id5       => c_earthquake_iv_id,
        p_entry_value1          => fnd_number.number_to_canonical(p_rec.life_gen_ins_prem),
        p_entry_value2          => fnd_number.number_to_canonical(p_rec.life_pens_ins_prem),
        p_entry_value3          => fnd_number.number_to_canonical(p_rec.nonlife_long_ins_prem),
        p_entry_value4          => fnd_number.number_to_canonical(p_rec.nonlife_short_ins_prem),
        p_entry_value5          => fnd_number.number_to_canonical(p_rec.earthquake_ins_prem),
        p_element_entry_id      => p_rec.ins_element_entry_id,
        p_object_version_number => p_rec.ins_ee_object_version_number,
        p_effective_start_date  => l_esd,
        p_effective_end_date    => l_eed,
        p_create_warning        => l_warning);
    --
      l_ins_element_entry_id := p_rec.ins_element_entry_id;
      l_ins_ee_object_version_number := p_rec.ins_ee_object_version_number;
      l_ins_datetrack_update_mode := pay_jp_isdf_archive_pkg.ee_datetrack_update_mode(p_rec.ins_element_entry_id,l_esd,l_eed,l_effective_date);
    --
    end if;
    --
    -- even if rec status is 'Q', eev might removed. specially if archive time is
    -- before december, the eev might not be set on december, transfer time.
    -- when entry exists, use new ovn, update mode at transfer time instead of stored data.
    if l_entry_rec.is_entry_cnt > 0 then
    --
      if changed(p_rec.social_ins_prem,l_entry_rec.social_ins_prem)
      or changed(p_rec.mutual_aid_prem,l_entry_rec.mutual_aid_prem)
      or changed(p_rec.spouse_income,l_entry_rec.spouse_income)
      or changed(p_rec.national_pens_ins_prem,l_entry_rec.national_pens_ins_prem) then
      --
        pay_element_entry_api.update_element_entry(
          p_validate              => false,
          p_effective_date        => l_effective_date,
          p_business_group_id     => g_business_group_id,
          p_datetrack_update_mode => l_entry_rec.is_datetrack_update_mode,
          p_element_entry_id      => l_entry_rec.is_element_entry_id,
          p_object_version_number => l_entry_rec.is_ee_object_version_number,
          p_input_value_id5       => c_social_iv_id,
          p_input_value_id6       => c_mutual_aid_iv_id,
          p_input_value_id7       => c_spouse_iv_id,
          p_input_value_id9       => c_national_pens_iv_id,
          p_entry_value5          => fnd_number.number_to_canonical(p_rec.social_ins_prem),
          p_entry_value6          => fnd_number.number_to_canonical(p_rec.mutual_aid_prem),
          p_entry_value7          => fnd_number.number_to_canonical(p_rec.spouse_income),
          p_entry_value9          => fnd_number.number_to_canonical(p_rec.national_pens_ins_prem),
          p_effective_start_date  => l_esd,
          p_effective_end_date    => l_eed,
          p_update_warning        => l_warning);
      --
      end if;
    --
      l_is_element_entry_id := l_entry_rec.is_element_entry_id;
      l_is_ee_object_version_number := l_entry_rec.is_ee_object_version_number;
      l_is_datetrack_update_mode := l_entry_rec.is_datetrack_update_mode;
    --
    else
    --
      -- this status soonly will be changed to 'Q' after insert.
      p_rec.status := 'I';
    --
      l_is_element_link_id := hr_entry_api.get_link(
                                p_assignment_id   => p_rec.assignment_id,
                                p_element_type_id => c_isdf_is_elm_id,
                                p_session_date    => l_effective_date);
    --
      if l_is_element_link_id is null then
        fnd_message.set_name('PAY', 'PAY_JP_ISDF_NO_ELE_LINK');
        fnd_message.set_token('ELE_NAME',c_isdf_is_elm);
        fnd_message.raise_error;
      end if;
    --
      pay_element_entry_api.create_element_entry(
        p_validate              => false,
        p_effective_date        => l_effective_date,
        p_business_group_id     => g_business_group_id,
        p_assignment_id         => p_rec.assignment_id,
        p_element_link_id       => l_is_element_link_id,
        p_entry_type            => 'E',
        p_input_value_id5       => c_social_iv_id,
        p_input_value_id6       => c_mutual_aid_iv_id,
        p_input_value_id7       => c_spouse_iv_id,
        p_input_value_id9       => c_national_pens_iv_id,
        p_entry_value5          => fnd_number.number_to_canonical(p_rec.social_ins_prem),
        p_entry_value6          => fnd_number.number_to_canonical(p_rec.mutual_aid_prem),
        p_entry_value7          => fnd_number.number_to_canonical(p_rec.spouse_income),
        p_entry_value9          => fnd_number.number_to_canonical(p_rec.national_pens_ins_prem),
        p_element_entry_id      => p_rec.is_element_entry_id,
        p_object_version_number => p_rec.is_ee_object_version_number,
        p_effective_start_date  => l_esd,
        p_effective_end_date    => l_eed,
        p_create_warning        => l_warning);
    --
      l_is_element_entry_id := p_rec.is_element_entry_id;
      l_is_ee_object_version_number := p_rec.is_ee_object_version_number;
      l_is_datetrack_update_mode := pay_jp_isdf_archive_pkg.ee_datetrack_update_mode(p_rec.is_element_entry_id,l_esd,l_eed,l_effective_date);
    --
    end if;
    --
    p_rec.object_version_number := p_rec.object_version_number + 1;
    --
    if p_expire_after_transfer = 'Y' then
      l_status := 'D';
    else
    -- p_rec.status = 'I' or 'Q' is now 'Q' because eev exists.
      l_status := 'Q';
    end if;
    --
    -- revised old data at archive time to the latest extracted data.
    if p_rec.status = 'Q' then
    --
      update pay_jp_isdf_entry_dml_v
      set    object_version_number = p_rec.object_version_number,
             status = l_status,
             ins_datetrack_update_mode = l_ins_datetrack_update_mode,
             ins_element_entry_id = fnd_number.number_to_canonical(l_ins_element_entry_id),
             ins_ee_object_version_number = fnd_number.number_to_canonical(l_ins_ee_object_version_number),
             life_gen_ins_prem_o = l_entry_rec.life_gen_ins_prem,
             life_pens_ins_prem_o = l_entry_rec.life_pens_ins_prem,
             nonlife_long_ins_prem_o = l_entry_rec.nonlife_long_ins_prem,
             nonlife_short_ins_prem_o = l_entry_rec.nonlife_short_ins_prem,
             earthquake_ins_prem_o = l_entry_rec.earthquake_ins_prem,
             is_datetrack_update_mode = l_is_datetrack_update_mode,
             is_element_entry_id = fnd_number.number_to_canonical(l_is_element_entry_id),
             is_ee_object_version_number = fnd_number.number_to_canonical(l_is_ee_object_version_number),
             social_ins_prem_o = l_entry_rec.social_ins_prem,
             mutual_aid_prem_o = l_entry_rec.mutual_aid_prem,
             spouse_income_o = l_entry_rec.spouse_income,
             national_pens_ins_prem_o = l_entry_rec.national_pens_ins_prem
      where  row_id = p_rec.row_id;
    --
    else
    --
      update pay_jp_isdf_entry_dml_v
      set    object_version_number = p_rec.object_version_number,
             status = l_status,
             ins_datetrack_update_mode = l_ins_datetrack_update_mode,
             ins_element_entry_id = fnd_number.number_to_canonical(l_ins_element_entry_id),
             ins_ee_object_version_number = fnd_number.number_to_canonical(l_ins_ee_object_version_number),
             life_gen_ins_prem_o = null,
             life_pens_ins_prem_o = null,
             nonlife_long_ins_prem_o = null,
             nonlife_short_ins_prem_o = null,
             earthquake_ins_prem_o = null,
             is_datetrack_update_mode = l_is_datetrack_update_mode,
             is_element_entry_id = fnd_number.number_to_canonical(l_is_element_entry_id),
             is_ee_object_version_number = fnd_number.number_to_canonical(l_is_ee_object_version_number),
             social_ins_prem_o = null,
             mutual_aid_prem_o = null,
             spouse_income_o = null,
             national_pens_ins_prem_o = null
      where row_id = p_rec.row_id;
    --
    end if;
  --
  end if;
--
  if g_debug then
    hr_utility.trace('end update_assact');
    hr_utility.set_location(l_proc,1000);
  end if;
--
end transfer_entry;
--
-- -------------------------------------------------------------------------
-- transfer_life_gen
-- -------------------------------------------------------------------------
procedure transfer_life_gen(
  p_rec in out nocopy pay_jp_isdf_life_gen_v%rowtype,
  p_effective_date in date,
  p_expire_after_transfer in varchar2)
is
--
  l_proc varchar2(80) := c_package||'transfer_entry';
--
  cursor csr_aei
  is
  select *
  from   per_assignment_extra_info
  where  assignment_extra_info_id = p_rec.assignment_extra_info_id;
--
  l_csr_aei csr_aei%rowtype;
  l_effective_date date;
--
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  if p_effective_date is null then
    l_effective_date := p_rec.effective_date;
  else
    l_effective_date := p_effective_date;
  end if;
--
  -- currently this is not supported that newly inserted data can be transfered.
  if p_rec.status = 'I' then
  --
    -- validation is required
    -- to disable insert ins_class and comp_code into action table
    -- because those are managed in master Org DF and
    -- to disable to insert annual prem even ins_class is LINC
    -- because the column should be derived from LINC loading data
    -- the field is not for override basically.
    hr_assignment_extra_info_api.create_assignment_extra_info(
      p_validate                 => false,
      p_assignment_id            => p_rec.assignment_id,
      p_information_type         => 'JP_ASS_LIG_INFO',
      p_aei_information_category => 'JP_ASS_LIG_INFO',
      p_aei_information1         => p_rec.gen_ins_class,
      p_aei_information2         => p_rec.gen_ins_company_code,
      p_aei_information3         => fnd_date.date_to_canonical(l_effective_date),
      p_aei_information4         => '',
      p_aei_information5         => p_rec.ins_type,
      p_aei_information6         => p_rec.ins_period,
      p_aei_information7         => p_rec.contractor_name,
      p_aei_information8         => p_rec.beneficiary_name,
      p_aei_information9         => p_rec.beneficiary_relship,
      p_aei_information10        => '',
      p_assignment_extra_info_id => p_rec.assignment_extra_info_id,
      p_object_version_number    => p_rec.aei_object_version_number);
  --
    p_rec.object_version_number := p_rec.object_version_number + 1;
  --
    if p_expire_after_transfer = 'Y' then
      p_rec.status := 'D';
    end if;
  --
    update pay_jp_isdf_life_gen_dml_v
    set    object_version_number = p_rec.object_version_number,
           status = p_rec.status,
           assignment_extra_info_id = fnd_number.number_to_canonical(p_rec.assignment_extra_info_id),
           aei_object_version_number = fnd_number.number_to_canonical(p_rec.aei_object_version_number)
    where  row_id = p_rec.row_id;
  --
  -- currently only support case of update entry data (except for amendment of ins_class and code)
  -- additionally not support if eit has been removed at the transferred time
  -- even if the eit existed at the archive time.
  elsif p_rec.status = 'Q' then
  --
    open csr_aei;
    fetch csr_aei into l_csr_aei;
    close csr_aei;
    --
    -- support only update in case eit exists at the transfer time.
    if l_csr_aei.assignment_extra_info_id is not null then
      --
      if changed(p_rec.ins_type,l_csr_aei.aei_information5)
      or changed(p_rec.ins_period,l_csr_aei.aei_information6)
      or changed(p_rec.contractor_name,l_csr_aei.aei_information7)
      or changed(p_rec.beneficiary_name,l_csr_aei.aei_information8)
      or changed(p_rec.beneficiary_relship,l_csr_aei.aei_information9) then
      --
        -- validation is required
        -- to disable update ins_class and comp_code into action table
        -- because those are managed in master Org DF and
        -- to disable to update annual prem even ins_class is LINC
        -- because the column should be derived from LINC loading data
        -- the field is not for override basically.
        --
        hr_assignment_extra_info_api.update_assignment_extra_info(
          p_validate                 => false,
          p_assignment_extra_info_id => l_csr_aei.assignment_extra_info_id,
          p_object_version_number    => l_csr_aei.object_version_number,
          p_aei_information_category => 'JP_ASS_LIG_INFO',
          p_aei_information1         => l_csr_aei.aei_information1,
          p_aei_information2         => l_csr_aei.aei_information2,
          p_aei_information3         => l_csr_aei.aei_information3,
          p_aei_information4         => l_csr_aei.aei_information4,
          p_aei_information5         => p_rec.ins_type,
          p_aei_information6         => p_rec.ins_period,
          p_aei_information7         => p_rec.contractor_name,
          p_aei_information8         => p_rec.beneficiary_name,
          p_aei_information9         => p_rec.beneficiary_relship,
          p_aei_information10        => l_csr_aei.aei_information10);
      --
        p_rec.object_version_number := p_rec.object_version_number + 1;
      --
        if p_expire_after_transfer = 'Y' then
          p_rec.status := 'D';
        end if;
      --
        -- since no storage for old eit data in view, unnecessary to change like entry.
        update pay_jp_isdf_life_gen_dml_v
        set    object_version_number = p_rec.object_version_number,
               status = p_rec.status,
               aei_object_version_number = fnd_number.number_to_canonical(l_csr_aei.object_version_number)
        where  row_id = p_rec.row_id;
      --
      end if;
    --
    end if;
  --
  elsif p_rec.status = 'D' then
  --
    --if p_rec.delete_mode = 'ZAP' then
    --  hr_assignment_extra_info_api.delete_assignment_extra_info(
    --    p_validate                 => false,
    --    p_assignment_extra_info_id => p_rec.assignment_extra_info_id,
    --    p_object_version_number    => p_rec.aei_object_version_number);
    --else
    --
      open csr_aei;
      fetch csr_aei into l_csr_aei;
      close csr_aei;
    --
    if l_csr_aei.assignment_extra_info_id is not null then
    --
      hr_assignment_extra_info_api.update_assignment_extra_info(
        p_validate                 => false,
        p_assignment_extra_info_id => l_csr_aei.assignment_extra_info_id,
        p_object_version_number    => l_csr_aei.object_version_number,
        p_aei_information_category => 'JP_ASS_LIG_INFO',
        p_aei_information1         => l_csr_aei.aei_information1,
        p_aei_information2         => l_csr_aei.aei_information2,
        p_aei_information3         => l_csr_aei.aei_information3,
        p_aei_information4         => fnd_date.date_to_canonical(l_effective_date-1),
        p_aei_information5         => p_rec.ins_type,
        p_aei_information6         => p_rec.ins_period,
        p_aei_information7         => p_rec.contractor_name,
        p_aei_information8         => p_rec.beneficiary_name,
        p_aei_information9         => p_rec.beneficiary_relship,
        p_aei_information10        => l_csr_aei.aei_information10);
    --
      p_rec.object_version_number := p_rec.object_version_number + 1;
    --
      -- since no storage for old eit data in view, unnecessary to change like entry.
      update pay_jp_isdf_life_gen_dml_v
      set    object_version_number = p_rec.object_version_number,
             aei_object_version_number = fnd_number.number_to_canonical(l_csr_aei.object_version_number)
      where  row_id = p_rec.row_id;
    --
    end if;
  --
  end if;
--
  if g_debug then
    hr_utility.trace('end update_assact');
    hr_utility.set_location(l_proc,1000);
  end if;
--
end transfer_life_gen;
--
-- -------------------------------------------------------------------------
-- transfer_life_pens
-- -------------------------------------------------------------------------
procedure transfer_life_pens(
  p_rec in out nocopy pay_jp_isdf_life_pens_v%rowtype,
  p_effective_date in date,
  p_expire_after_transfer in varchar2)
is
--
  l_proc varchar2(80) := c_package||'transfer_entry';
  l_effective_date date;
--
  cursor csr_aei
  is
  select *
  from   per_assignment_extra_info
  where  assignment_extra_info_id = p_rec.assignment_extra_info_id;
--
  l_csr_aei csr_aei%rowtype;
--
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  if p_effective_date is null then
    l_effective_date := p_rec.effective_date;
  else
    l_effective_date := p_effective_date;
  end if;
--
  -- currently this is not supported that newly inserted data can be transfered.
  if p_rec.status = 'I' then
  --
    -- validation is required
    -- to disable insert ins_class and comp_code into action table
    -- because those are managed in master Org DF and
    -- to disable to insert annual prem even ins_class is LINC
    -- because the column should be derived from LINC loading data
    -- the field is not for override basically.
    hr_assignment_extra_info_api.create_assignment_extra_info(
      p_validate                 => false,
      p_assignment_id            => p_rec.assignment_id,
      p_information_type         => 'JP_ASS_LIP_INFO',
      p_aei_information_category => 'JP_ASS_LIP_INFO',
      p_aei_information1         => p_rec.pens_ins_class,
      p_aei_information2         => p_rec.pens_ins_company_code,
      p_aei_information3         => fnd_date.date_to_canonical(l_effective_date),
      p_aei_information4         => '',
      p_aei_information5         => p_rec.ins_type,
      p_aei_information6         => fnd_date.date_to_canonical(p_rec.ins_period_start_date),
      p_aei_information7         => p_rec.ins_period,
      p_aei_information8         => p_rec.contractor_name,
      p_aei_information9         => p_rec.beneficiary_name,
      p_aei_information10        => p_rec.beneficiary_relship,
      p_aei_information11        => '',
      p_assignment_extra_info_id => p_rec.assignment_extra_info_id,
      p_object_version_number    => p_rec.aei_object_version_number);
  --
    p_rec.object_version_number := p_rec.object_version_number + 1;
  --
    if p_expire_after_transfer = 'Y' then
      p_rec.status := 'D';
    end if;
  --
    update pay_jp_isdf_life_pens_dml_v
    set    object_version_number = p_rec.object_version_number,
           status = p_rec.status,
           assignment_extra_info_id = fnd_number.number_to_canonical(p_rec.assignment_extra_info_id),
           aei_object_version_number = fnd_number.number_to_canonical(p_rec.aei_object_version_number)
    where  row_id = p_rec.row_id;
  --
  -- currently only support case of update entry data (except for amendment of ins_class and code)
  -- additionally not support if eit has been removed at the transferred time
  -- even if the eit existed at the archive time.
  elsif p_rec.status = 'Q' then
  --
    open csr_aei;
    fetch csr_aei into l_csr_aei;
    close csr_aei;
    --
    -- support only update in case eit exists at the transfer time.
    if l_csr_aei.assignment_extra_info_id is not null then
      --
      if changed(p_rec.ins_type,l_csr_aei.aei_information5)
      or changed(fnd_date.date_to_canonical(p_rec.ins_period_start_date),l_csr_aei.aei_information6)
      or changed(p_rec.ins_period,l_csr_aei.aei_information7)
      or changed(p_rec.contractor_name,l_csr_aei.aei_information8)
      or changed(p_rec.beneficiary_name,l_csr_aei.aei_information9)
      or changed(p_rec.beneficiary_relship,l_csr_aei.aei_information10) then
      --
        -- validation is required
        -- to disable update ins_class and comp_code into action table
        -- because those are managed in master Org DF and
        -- to disable to update annual prem even ins_class is LINC
        -- because the column should be derived from LINC loading data
        -- the field is not for override basically.
        hr_assignment_extra_info_api.update_assignment_extra_info(
          p_validate                 => false,
          p_assignment_extra_info_id => l_csr_aei.assignment_extra_info_id,
          p_object_version_number    => l_csr_aei.object_version_number,
          p_aei_information_category => 'JP_ASS_LIP_INFO',
          p_aei_information1         => l_csr_aei.aei_information1,
          p_aei_information2         => l_csr_aei.aei_information2,
          p_aei_information3         => l_csr_aei.aei_information3,
          p_aei_information4         => l_csr_aei.aei_information4,
          p_aei_information5         => p_rec.ins_type,
          p_aei_information6         => fnd_date.date_to_canonical(p_rec.ins_period_start_date),
          p_aei_information7         => p_rec.ins_period,
          p_aei_information8         => p_rec.contractor_name,
          p_aei_information9         => p_rec.beneficiary_name,
          p_aei_information10        => p_rec.beneficiary_relship,
          p_aei_information11        => l_csr_aei.aei_information11);
        --
        p_rec.object_version_number := p_rec.object_version_number + 1;
        --
        if p_expire_after_transfer = 'Y' then
          p_rec.status := 'D';
        end if;
        --
        -- since no storage for old eit data in view, unnecessary to change like entry.
        update pay_jp_isdf_life_pens_dml_v
        set    object_version_number = p_rec.object_version_number,
               status = p_rec.status,
               aei_object_version_number = fnd_number.number_to_canonical(p_rec.aei_object_version_number)
        where  row_id = p_rec.row_id;
      --
      end if;
    --
    end if;
  --
  elsif p_rec.status = 'D' then
  --
    --if p_rec.delete_mode = 'ZAP' then
    --  hr_assignment_extra_info_api.delete_assignment_extra_info(
    --    p_validate                 => false,
    --    p_assignment_extra_info_id => p_rec.assignment_extra_info_id,
    --    p_object_version_number    => p_rec.aei_object_version_number);
    --else
    --
      open csr_aei;
      fetch csr_aei into l_csr_aei;
      close csr_aei;
    --
    if l_csr_aei.assignment_extra_info_id is not null then
    --
      hr_assignment_extra_info_api.update_assignment_extra_info(
        p_validate                 => false,
        p_assignment_extra_info_id => l_csr_aei.assignment_extra_info_id,
        p_object_version_number    => l_csr_aei.object_version_number,
        p_aei_information_category => 'JP_ASS_LIP_INFO',
        p_aei_information1         => l_csr_aei.aei_information1,
        p_aei_information2         => l_csr_aei.aei_information2,
        p_aei_information3         => l_csr_aei.aei_information3,
        p_aei_information4         => fnd_date.date_to_canonical(l_effective_date-1),
        p_aei_information5         => p_rec.ins_type,
        p_aei_information6         => fnd_date.date_to_canonical(p_rec.ins_period_start_date),
        p_aei_information7         => p_rec.ins_period,
        p_aei_information8         => p_rec.contractor_name,
        p_aei_information9         => p_rec.beneficiary_name,
        p_aei_information10        => p_rec.beneficiary_relship,
        p_aei_information11        => l_csr_aei.aei_information11);
    --
      p_rec.object_version_number := p_rec.object_version_number + 1;
    --
    -- since no storage for old eit data in view, unnecessary to change like entry.
      update pay_jp_isdf_life_pens_dml_v
      set    object_version_number = p_rec.object_version_number,
             aei_object_version_number = fnd_number.number_to_canonical(l_csr_aei.object_version_number)
      where  row_id = p_rec.row_id;
    --
    end if;
  --
  end if;
--
  if g_debug then
    hr_utility.trace('end update_assact');
    hr_utility.set_location(l_proc,1000);
  end if;
--
end transfer_life_pens;
--
-- -------------------------------------------------------------------------
-- transfer_nonlife
-- -------------------------------------------------------------------------
procedure transfer_nonlife(
  p_rec in out nocopy pay_jp_isdf_nonlife_v%rowtype,
  p_effective_date in date,
  p_expire_after_transfer in varchar2)
is
--
  l_proc varchar2(80) := c_package||'transfer_entry';
  l_effective_date date;
--
  cursor csr_aei
  is
  select *
  from   per_assignment_extra_info
  where  assignment_extra_info_id = p_rec.assignment_extra_info_id;
--
  l_csr_aei csr_aei%rowtype;
--
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  if p_effective_date is null then
    l_effective_date := p_rec.effective_date;
  else
    l_effective_date := p_effective_date;
  end if;
--
  -- currently this is not supported that newly inserted data can be transfered.
  if p_rec.status = 'I' then
  --
    -- validation is required
    -- to disable insert ins_class and comp_code into action table
    -- because those are managed in master Org DF and
    -- to disable to insert annual prem
    -- because the column should be derived from customer loading data
    -- the field is not for override basically.
    hr_assignment_extra_info_api.create_assignment_extra_info(
      p_validate                 => false,
      p_assignment_id            => p_rec.assignment_id,
      p_information_type         => 'JP_ASS_AI_INFO',
      p_aei_information_category => 'JP_ASS_AI_INFO',
      p_aei_information1         => p_rec.nonlife_ins_term_type,
      p_aei_information2         => p_rec.nonlife_ins_company_code,
      p_aei_information3         => fnd_date.date_to_canonical(l_effective_date),
      p_aei_information4         => '',
      p_aei_information5         => p_rec.ins_type,
      p_aei_information6         => p_rec.ins_period,
      p_aei_information7         => p_rec.contractor_name,
      p_aei_information8         => p_rec.beneficiary_name,
      p_aei_information9         => p_rec.beneficiary_relship,
      p_aei_information10        => p_rec.maturity_repayment,
      p_aei_information11        => '',
      p_aei_information13        => p_rec.nonlife_ins_class,
      p_assignment_extra_info_id => p_rec.assignment_extra_info_id,
      p_object_version_number    => p_rec.aei_object_version_number);
  --
    p_rec.object_version_number := p_rec.object_version_number + 1;
  --
    if p_expire_after_transfer = 'Y' then
      p_rec.status := 'D';
    end if;
  --
    update pay_jp_isdf_nonlife_dml_v
    set    object_version_number = p_rec.object_version_number,
           status = p_rec.status,
           assignment_extra_info_id = fnd_number.number_to_canonical(p_rec.assignment_extra_info_id),
           aei_object_version_number = fnd_number.number_to_canonical(p_rec.aei_object_version_number)
    where  row_id = p_rec.row_id;
  --
  -- currently only support case of update entry data (except for amendment of ins_class and code)
  -- additionally not support if eit has been removed at the transferred time
  -- even if the eit existed at the archive time.
  elsif p_rec.status = 'Q' then
  --
    open csr_aei;
    fetch csr_aei into l_csr_aei;
    close csr_aei;
    --
    -- support only update in case eit exists at the transfer time.
    if l_csr_aei.assignment_extra_info_id is not null then
      --
      if changed(p_rec.ins_type,l_csr_aei.aei_information5)
      or changed(p_rec.ins_period,l_csr_aei.aei_information6)
      or changed(p_rec.contractor_name,l_csr_aei.aei_information7)
      or changed(p_rec.beneficiary_name,l_csr_aei.aei_information8)
      or changed(p_rec.beneficiary_relship,l_csr_aei.aei_information9)
      or (l_effective_date < c_st_upd_date_2007 and changed(p_rec.maturity_repayment,l_csr_aei.aei_information10)) then
      --
        -- validation is required
        -- to disable update ins_class and comp_code into action table
        -- because those are managed in master Org DF and
        -- to disable to update annual prem even ins_class is LINC
        -- because the column should be derived from LINC loading data
        -- the field is not for override basically.
        hr_assignment_extra_info_api.update_assignment_extra_info(
          p_validate                 => false,
          p_assignment_extra_info_id => l_csr_aei.assignment_extra_info_id,
          p_object_version_number    => l_csr_aei.object_version_number,
          p_aei_information_category => 'JP_ASS_AI_INFO',
          p_aei_information1         => l_csr_aei.aei_information1,
          p_aei_information2         => l_csr_aei.aei_information2,
          p_aei_information3         => l_csr_aei.aei_information3,
          p_aei_information4         => l_csr_aei.aei_information4,
          p_aei_information5         => p_rec.ins_type,
          p_aei_information6         => p_rec.ins_period,
          p_aei_information7         => p_rec.contractor_name,
          p_aei_information8         => p_rec.beneficiary_name,
          p_aei_information9         => p_rec.beneficiary_relship,
          p_aei_information10        => p_rec.maturity_repayment,
          p_aei_information11        => l_csr_aei.aei_information11,
          p_aei_information13        => l_csr_aei.aei_information13);
        --
        p_rec.object_version_number := p_rec.object_version_number + 1;
        --
        if p_expire_after_transfer = 'Y' then
          p_rec.status := 'D';
        end if;
        --
        -- since no storage for old eit data in view, unnecessary to change like entry.
        update pay_jp_isdf_nonlife_dml_v
        set    object_version_number = p_rec.object_version_number,
               status = p_rec.status,
               aei_object_version_number = fnd_number.number_to_canonical(p_rec.aei_object_version_number)
        where  row_id = p_rec.row_id;
      --
      end if;
    --
    end if;
  --
  elsif p_rec.status = 'D' then
  --
    --if p_rec.delete_mode = 'ZAP' then
    --  hr_assignment_extra_info_api.delete_assignment_extra_info(
    --    p_validate                 => false,
    --    p_assignment_extra_info_id => p_rec.assignment_extra_info_id,
    --    p_object_version_number    => p_rec.aei_object_version_number);
    --else
    --
      open csr_aei;
      fetch csr_aei into l_csr_aei;
      close csr_aei;
    --
    if l_csr_aei.assignment_extra_info_id is not null then
    --
      hr_assignment_extra_info_api.update_assignment_extra_info(
        p_validate                 => false,
        p_assignment_extra_info_id => l_csr_aei.assignment_extra_info_id,
        p_object_version_number    => l_csr_aei.object_version_number,
        p_aei_information_category => 'JP_ASS_AI_INFO',
        p_aei_information1         => l_csr_aei.aei_information1,
        p_aei_information2         => l_csr_aei.aei_information2,
        p_aei_information3         => l_csr_aei.aei_information3,
        p_aei_information4         => fnd_date.date_to_canonical(l_effective_date-1),
        p_aei_information5         => p_rec.ins_type,
        p_aei_information6         => p_rec.ins_period,
        p_aei_information7         => p_rec.contractor_name,
        p_aei_information8         => p_rec.beneficiary_name,
        p_aei_information9         => p_rec.beneficiary_relship,
        p_aei_information10        => p_rec.maturity_repayment,
        p_aei_information11        => l_csr_aei.aei_information11,
        p_aei_information13        => l_csr_aei.aei_information13);
    --
      p_rec.object_version_number := p_rec.object_version_number + 1;
    --
    -- since no storage for old eit data in view, unnecessary to change like entry.
      update pay_jp_isdf_nonlife_dml_v
      set    object_version_number = p_rec.object_version_number,
             aei_object_version_number = fnd_number.number_to_canonical(l_csr_aei.object_version_number)
      where  row_id = p_rec.row_id;
    --
    end if;
  --
  end if;
--
  if g_debug then
    hr_utility.trace('end update_assact');
    hr_utility.set_location(l_proc,1000);
  end if;
--
end transfer_nonlife;
--
-- -------------------------------------------------------------------------
-- do_transfer
-- -------------------------------------------------------------------------
procedure do_transfer(
  p_action_information_id in number,
  p_object_version_number in out nocopy number,
  p_transfer_date         in date,
  p_create_session        in boolean default true,
  p_expire_after_transfer in varchar2 default 'N')
is
--
  l_proc varchar2(80) := c_package||'do_transfer';
  l_assact_rec pay_jp_isdf_assact_v%rowtype;
  l_effective_date date;
  l_year_end_date date;
  l_dec_first_date date;
--
  cursor csr_entry
  is
  select *
  from   pay_jp_isdf_entry_v
  where  assignment_action_id = l_assact_rec.assignment_action_id
  and    status <> 'D'
  for update nowait;
--
  -- ass eit exclude PC data, take only GIP/LINC
  cursor csr_life_gen_del
  is
  select *
  from   pay_jp_isdf_life_gen_v
  where  assignment_action_id = l_assact_rec.assignment_action_id
  and    gen_ins_class <> 'PC'
  and    status = 'D'
  for update nowait;
--
  -- status U is only case when archive was transfered
  cursor csr_life_gen_upd
  is
  select *
  from   pay_jp_isdf_life_gen_v
  where  assignment_action_id = l_assact_rec.assignment_action_id
  and    gen_ins_class <> 'PC'
  and    status = 'Q'
  for update nowait;
--
  cursor csr_life_gen_ins
  is
  select *
  from   pay_jp_isdf_life_gen_v
  where  assignment_action_id = l_assact_rec.assignment_action_id
  and    gen_ins_class <> 'PC'
  and    status = 'I'
  for update nowait;
--
  -- ass eit exclude PC data, take only GIP/LINC
  cursor csr_life_pens_del
  is
  select *
  from   pay_jp_isdf_life_pens_v
  where  assignment_action_id = l_assact_rec.assignment_action_id
  and    pens_ins_class <> 'PC'
  and    status = 'D'
  for update nowait;
--
  -- status U is only case when archive was transfered
  cursor csr_life_pens_upd
  is
  select *
  from   pay_jp_isdf_life_pens_v
  where  assignment_action_id = l_assact_rec.assignment_action_id
  and    pens_ins_class <> 'PC'
  and    status = 'Q'
  for update nowait;
--
  cursor csr_life_pens_ins
  is
  select *
  from   pay_jp_isdf_life_pens_v
  where  assignment_action_id = l_assact_rec.assignment_action_id
  and    pens_ins_class <> 'PC'
  and    status = 'I'
  for update nowait;
--
  -- ass eit exclude PC data, take only AP
  cursor csr_nonlife_del
  is
  select *
  from   pay_jp_isdf_nonlife_v
  where  assignment_action_id = l_assact_rec.assignment_action_id
  and    nonlife_ins_class <> 'PC'
  and    status = 'D'
  for update nowait;
--
  -- status U is only case when archive was transfered
  cursor csr_nonlife_upd
  is
  select *
  from   pay_jp_isdf_nonlife_v
  where  assignment_action_id = l_assact_rec.assignment_action_id
  and    nonlife_ins_class <> 'PC'
  and    status = 'Q'
  for update nowait;
--
  cursor csr_nonlife_ins
  is
  select *
  from   pay_jp_isdf_nonlife_v
  where  assignment_action_id = l_assact_rec.assignment_action_id
  and    nonlife_ins_class <> 'PC'
  and    status = 'I'
  for update nowait;
--
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  hr_api.mandatory_arg_error(l_proc, 'transfer_date', p_transfer_date);
--
  pay_jp_isdf_dml_pkg.lock_assact(p_action_information_id, p_object_version_number, l_assact_rec);
--
  if l_assact_rec.transaction_status <> 'A' then
    fnd_message.set_name('PAY', 'PAY_JP_DEF_INVALID_TXN_STATUS');
    fnd_message.raise_error;
  elsif l_assact_rec.transfer_status <> 'U' then
    fnd_message.set_name('PAY', 'PAY_JP_DEF_ALREADY_TRANSFERRED');
    fnd_message.raise_error;
  end if;
--
  l_year_end_date := add_months(trunc(l_assact_rec.effective_date, 'YYYY'), 12) - 1;
  l_dec_first_date := trunc(l_year_end_date,'MM');
--
  if p_transfer_date is null then
    l_effective_date := l_assact_rec.effective_date;
  else
    l_effective_date := p_transfer_date;
  end if;
--
  -- actually if l_dec_first_date <= p_transfer_date <= l_year_end_date,
  -- insert is ok because nonrecurring element (unnecessary to validate transfer_date < effective_date)
  -- but basically transfer should be done after archive process date.
  if l_effective_date < l_assact_rec.effective_date
  or l_effective_date < l_dec_first_date
  or l_effective_date > l_year_end_date then
    fnd_message.set_name('PAY', 'PAY_JP_ISDF_INVALID_TRANS_DATE');
    fnd_message.set_token('EFFECTIVE_DATE', fnd_date.date_to_chardate(l_assact_rec.effective_date));
    fnd_message.set_token('DEC_FIRST_DATE', fnd_date.date_to_chardate(l_dec_first_date));
    fnd_message.set_token('YEAR_END_DATE',  fnd_date.date_to_chardate(l_year_end_date));
    fnd_message.raise_error;
  end if;
--
  -- for api use
  if p_create_session then
    insert_session(l_effective_date);
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,20);
    hr_utility.trace('action_information_id  : '||p_action_information_id);
    hr_utility.trace('object_version_number  : '||p_object_version_number);
    hr_utility.trace('assignment_action_id   : '||l_assact_rec.assignment_action_id);
    hr_utility.trace('start calc_dct before finalize');
  end if;
--
  -- Transfer the followings.
  --
  -- Transfer JP_ISDF_ENTRY to PAY_ELEMENT_ENTRIES_F
  --
  for l_rec in csr_entry loop
  -- boolean is not supported in jrad.
    transfer_entry(l_rec,l_effective_date,p_expire_after_transfer);
  end loop;
--
  -- Transfer the followings.
  --
  -- Transfer JP_ISDF_LIFE_GEN.GEN_INS_CLASS=GIP/LINC to PER_ASSIGNMENT_EXTRA_INFO.JP_ASS_LIG_INFO
  -- Transfer JP_ISDF_LIFE_PENS.PENS_INS_CLASS=GIP/LINC to PER_ASSIGNMENT_EXTRA_INFO.JP_ASS_LIP_INFO
--
  -- Disable to delete
  -- because GIP and LINC data are relevant to deducted monthly element entry
  -- which is used in custom formula for monthly salary
  -- so that employer needs to care dependency for deletion of EIT with custom element entry setup.
  -- But we allow to delete GIP/LINC archive data on FormPG,
  -- it means that makes inconsistence between Report data and EIT data.
  -- employee can exclude LINC/GIP data from subjection of deduction,
  -- but this action is not same to remove LING/GIP from EIT.
  -- delete phase
  --for l_life_gen_rec in csr_life_gen_del loop
  --  transfer_life_gen(l_life_gen_rec,l_effective_date,p_expire_after_transfer);
  --end loop;
  --
  --for l_life_pens_rec in csr_life_pens_del loop
  --  transfer_life_pens(l_life_pens_rec,l_effective_date,p_expire_after_transfer);
  --end loop;
  --
  --for l_nonlife_rec in csr_nonlife_del loop
  --  transfer_nonlife(l_nonlife_rec,l_effective_date,p_expire_after_transfer);
  --end loop;
--
  -- update phase
  for l_life_gen_rec in csr_life_gen_upd loop
    transfer_life_gen(l_life_gen_rec,l_effective_date,p_expire_after_transfer);
  end loop;
  --
  for l_life_pens_rec in csr_life_pens_upd loop
    transfer_life_pens(l_life_pens_rec,l_effective_date,p_expire_after_transfer);
  end loop;
  --
  for l_nonlife_rec in csr_nonlife_upd loop
    transfer_nonlife(l_nonlife_rec,l_effective_date,p_expire_after_transfer);
  end loop;
--
  -- Disable to insert
  -- because GIP and LINC data are relevant to deducted monthly element entry
  -- which is used in custom formula for monthly salary
  -- so that employer needs to care dependency for insertion of EIT with custom element entry setup.
  -- insert phase
  --for l_life_gen_rec in csr_life_gen_ins loop
  --  transfer_life_gen(l_life_gen_rec,l_effective_date,p_expire_after_transfer);
  --end loop;
  --
  --for l_life_pens_rec in csr_life_pens_ins loop
  --  transfer_life_pens(l_life_pens_rec,l_effective_date,p_expire_after_transfer);
  --end loop;
  --
  --for l_nonlife_rec in csr_nonlife_ins loop
  --  transfer_nonlife(l_nonlife_rec,l_effective_date,p_expire_after_transfer);
  --end loop;
--
  if p_create_session then
    delete_session;
  end if;
--
  p_object_version_number := l_assact_rec.object_version_number + 1;
--
  --api is disable because assact has been locked.
  --pay_jp_isdf_dml_pkg.update_assact(
  --  p_action_information_id => l_assact_rec.assignment_action_id,
  --  p_object_version_number => p_object_version_number,
  --  p_transaction_status    => l_assact_rec.transaction_status,
  --  p_finalized_date        => l_assact_rec.finalized_date,
  --  p_finalized_by          => l_assact_rec.finalized_by,
  --  p_user_comments         => l_assact_rec.user_comments,
  --  p_admin_comments        => l_assact_rec.admin_comments,
  --  p_transfer_status       => 'T',
  --  p_transfer_date         => fnd_date.date_to_canonical(l_effective_date),
  --  p_expiry_date           => l_assact_rec.expiry_date);
  update pay_jp_isdf_assact_dml_v
  set    object_version_number = p_object_version_number,
         transfer_status    = 'T',
         transfer_date         = fnd_date.date_to_canonical(l_effective_date)
  where  row_id = l_assact_rec.row_id;
--
  if g_debug then
    hr_utility.trace('end update_assact');
    hr_utility.set_location(l_proc,1000);
  end if;
--
end do_transfer;
--
-- -------------------------------------------------------------------------
-- do_expire
-- -------------------------------------------------------------------------
procedure do_expire(
  p_action_information_id in number,
  p_object_version_number in out nocopy number,
  p_expiry_date           in date,
  p_create_session        in boolean default true,
  p_mode                  in varchar2 default null)
is
--
-- p_mode: DELETE: change archive status to D
--         ZAP   : remove archive data of status D
--         N/A   : nothing to do. (original)
--
  l_proc varchar2(80) := c_package||'do_expire';
  l_assact_rec pay_jp_isdf_assact_v%rowtype;
  l_effective_date date;
  l_dec_first_date date;
  l_year_end_date date;
  l_esd date;
  l_eed date;
  l_warning boolean;
  l_object_version_number number;
--
  cursor csr_entry
  is
  select *
  from   pay_jp_isdf_entry_v
  where  assignment_action_id = l_assact_rec.assignment_action_id
  for update nowait;
--
  l_csr_entry csr_entry%rowtype;
--
  cursor csr_del
  is
  select rowid row_id,
         action_information_id,
         object_version_number,
         action_information_category
  from   pay_action_information
  where  action_context_id = l_assact_rec.assignment_action_id
  and    action_context_type = 'AAP'
  and    action_information_category <> 'JP_ISDF_ASSACT'
  and    action_information1 <> 'D';
--
  l_csr_del csr_del%rowtype;
--
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  hr_api.mandatory_arg_error(l_proc,'expiry_date',p_expiry_date);
--
  pay_jp_isdf_dml_pkg.lock_assact(p_action_information_id, p_object_version_number, l_assact_rec);
--
  if l_assact_rec.transaction_status = 'U' then
    fnd_message.set_name('PAY', 'PAY_JP_DEF_NOT_TRANSFERRED_YET');
    fnd_message.raise_error;
  elsif l_assact_rec.transfer_status = 'E' then
    fnd_message.set_name('PAY', 'PAY_JP_DEF_ALREADY_EXPIRED');
    fnd_message.raise_error;
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,20);
    hr_utility.trace('action_information_id  : '||p_action_information_id);
    hr_utility.trace('object_version_number  : '||p_object_version_number);
    hr_utility.trace('assignment_action_id   : '||l_assact_rec.assignment_action_id);
    hr_utility.trace('start calc_dct before finalize');
  end if;
--
  l_year_end_date := add_months(trunc(l_assact_rec.effective_date, 'YYYY'), 12) - 1;
  l_dec_first_date := trunc(l_year_end_date,'MM');
--
  -- actually if l_dec_first_date (first day of l_transfer_date) <= p_expiry_date <= l_year_end_date,
  -- delete is ok because nonrecurring element (unnecessary to validate expiry_date < transfer_date)
  -- but basically expiry should be done after transfer process date.
  -- (transfer_date is always set since transfer_status check has been done)
  if p_expiry_date < l_assact_rec.effective_date
  or p_expiry_date < l_assact_rec.transfer_date
  or p_expiry_date > l_year_end_date then
    fnd_message.set_name('PAY', 'PAY_JP_ISDF_INVALID_EXP_DATE');
    fnd_message.set_token('TRANSFER_DATE', fnd_date.date_to_chardate(l_assact_rec.transfer_date));
    fnd_message.set_token('YEAR_END_DATE', fnd_date.date_to_chardate(l_year_end_date));
    fnd_message.raise_error;
  end if;
--
  -- l_dec_first_date or effective_date <= l_transfer_date <= l_year_end_date
  -- l_transfer_date <= l_expirty_date <= l_year_end_date
  -- since delete mode is not allowed to delete on the same day of last eev eed,
  -- if l_expiry_date is end period of transffered date (= l_year_end_date),
  -- set delete validation start_date (p_effective_date) to l_year_end_date - 1.
  if p_expiry_date = l_year_end_date then
    l_effective_date := l_year_end_date - 1;
  else
    l_effective_date := p_expiry_date;
  end if;
--
  -- for api use.
  if p_create_session then
    insert_session(l_effective_date);
  end if;
--
  open csr_entry;
  loop
    fetch csr_entry into l_csr_entry;
    exit when csr_entry%notfound;
  --
    pay_element_entry_api.delete_element_entry(
      p_validate              => false,
      p_effective_date        => l_effective_date,
      p_datetrack_delete_mode => 'DELETE',
      p_element_entry_id      => l_csr_entry.ins_element_entry_id,
      p_object_version_number => l_csr_entry.ins_ee_object_version_number,
      p_effective_start_date  => l_esd,
      p_effective_end_date    => l_eed,
      p_delete_warning        => l_warning);
  --
    pay_element_entry_api.delete_element_entry(
      p_validate              => false,
      p_effective_date        => l_effective_date,
      p_datetrack_delete_mode => 'DELETE',
      p_element_entry_id      => l_csr_entry.is_element_entry_id,
      p_object_version_number => l_csr_entry.is_ee_object_version_number,
      p_effective_start_date  => l_esd,
      p_effective_end_date    => l_eed,
      p_delete_warning        => l_warning);
  --
    update pay_jp_isdf_entry_dml_v
    set    object_version_number        = l_csr_entry.object_version_number + 1,
           ins_ee_object_version_number = fnd_number.number_to_canonical(l_csr_entry.ins_ee_object_version_number),
           is_ee_object_version_number  = fnd_number.number_to_canonical(l_csr_entry.is_ee_object_version_number)
    where  row_id = l_csr_entry.row_id;
  --
  end loop;
  close csr_entry;
--
  if p_mode = 'ZAP' then
  --
    delete
    from  pay_action_information
    where action_context_id = l_assact_rec.assignment_action_id
    and   action_context_type = 'AAP'
    and   action_information_category <> 'JP_ISDF_ASSACT';
  --
  elsif p_mode = 'DELETE' then
  --
    open csr_del;
    loop
    --
      fetch csr_del into l_csr_del;
      exit when csr_del%notfound;
    --
      -- ovn already updated above.
      if l_csr_del.action_information_category = 'JP_ISDF_ENTRY' then
        l_object_version_number := l_csr_del.object_version_number;
      else
        l_object_version_number := l_csr_del.object_version_number + 1;
      end if;
    --
      update pay_action_information
      set    object_version_number = l_object_version_number,
             action_information1 = 'D'
      where  rowid = l_csr_del.row_id;
    --
    end loop;
    close csr_del;
  --
  end if;
--
  if p_create_session then
    delete_session;
  end if;
--
  p_object_version_number := l_assact_rec.object_version_number + 1;
--
  --api is disable because assact has been locked.
  --pay_jp_isdf_dml_pkg.update_assact(
  --  p_action_information_id => l_assact_rec.assignment_action_id,
  --  p_object_version_number => p_object_version_number,
  --  p_transaction_status    => l_assact_rec.transaction_status,
  --  p_finalized_date        => l_assact_rec.finalized_date,
  --  p_finalized_by          => l_assact_rec.finalized_by,
  --  p_user_comments         => l_assact_rec.user_comments,
  --  p_admin_comments        => l_assact_rec.admin_comments,
  --  p_transfer_status       => 'E',
  --  p_transfer_date         => l_assact_rec.transfer_date,
  --  p_expiry_date           => fnd_date.date_to_canonical(p_expiry_date));
  update pay_jp_isdf_assact_dml_v
  set    object_version_number = p_object_version_number,
         transfer_status    = 'E',
         expiry_date           = fnd_date.date_to_canonical(p_expiry_date)
  where  row_id = l_assact_rec.row_id;
--
  if g_debug then
    hr_utility.trace('end update_assact');
    hr_utility.set_location(l_proc,1000);
  end if;
--
end do_expire;
--
 -- -------------------------------------------------------------------------
-- get_sqlerrm (use multiple transaction)
-- -------------------------------------------------------------------------
function get_sqlerrm
return varchar2
is
begin
--
  if sqlcode = -20001 then
  --
    declare
      l_sqlerrm varchar2(2000) := fnd_message.get;
    begin
      if l_sqlerrm is not null then
        return l_sqlerrm;
      else
        return sqlerrm;
      end if;
    end;
  --
  else
    return sqlerrm;
  end if;
--
end get_sqlerrm;
--
 -- -------------------------------------------------------------------------
-- do_finalize (Multiple Transaction for internal use only)
-- -------------------------------------------------------------------------
procedure do_finalize(
  errbuf  out nocopy varchar2,
  retcode out nocopy varchar2,
  p_payroll_action_id in number,
  p_user_comments in varchar2)
is
--
  l_effective_date date;
--
  cursor csr_assact
  is
  select /*+ ORDERED */
         assact.action_information_id,
         assact.object_version_number,
         pp.full_name,
         pa.assignment_number
  from   pay_assignment_actions paa,
         pay_jp_isdf_assact_v   assact,
         per_all_assignments_f  pa,
         per_all_people_f       pp
  where  paa.payroll_action_id = p_payroll_action_id
  and    paa.action_status = 'C'
  and    assact.assignment_action_id = paa.assignment_action_id
  and    assact.transaction_status = 'N'
  and    pa.assignment_id = assact.assignment_id
  and    assact.effective_date
         between pa.effective_start_date and pa.effective_end_date
  and    pp.person_id = pa.person_id
  and    assact.effective_date
         between pp.effective_start_date and pp.effective_end_date
  order by lpad(pa.assignment_number,10,' '),
           pp.full_name;
--
begin
--
  select effective_date
  into   l_effective_date
  from   pay_jp_isdf_pact_v
  where  payroll_action_id = p_payroll_action_id;
--
  insert_session(l_effective_date);
  commit;
--
  fnd_file.put_line(fnd_file.output, 'Full Name                                Assignment Number');
  fnd_file.put_line(fnd_file.output, '---------------------------------------- ------------------------------');
  fnd_file.put_line(fnd_file.log,    'Full Name                                Assignment Number');
  fnd_file.put_line(fnd_file.log,    '---------------------------------------- ------------------------------');
--
  for l_rec in csr_assact loop
  --
    begin
    --
      do_finalize(
        p_action_information_id => l_rec.action_information_id,
        p_object_version_number => l_rec.object_version_number,
        p_user_comments         => p_user_comments);
    --
      commit;
    --
      fnd_file.put_line(fnd_file.output, rpad(l_rec.full_name, 40) || ' ' || rpad(l_rec.assignment_number, 30));
    --
    exception
    when others then
    --
      fnd_file.put_line(fnd_file.log, rpad(l_rec.full_name, 40) || ' ' || rpad(l_rec.assignment_number, 30));
      fnd_file.put_line(fnd_file.log, get_sqlerrm);
    --
    end;
  --
  end loop;
--
  delete_session;
  commit;
--
  -- retcode
  -- 0 : Success
  -- 1 : Warning
  -- 2 : Error
  --
  retcode := 0;
--
end do_finalize;
--
 -- -------------------------------------------------------------------------
-- do_approve (Multiple Transaction)
-- -------------------------------------------------------------------------
procedure do_approve(
  errbuf  out nocopy varchar2,
  retcode out nocopy varchar2,
  p_payroll_action_id in number)
is
--
  l_effective_date date;
--
  cursor csr_assact
  is
  select /*+ ORDERED */
         assact.action_information_id,
         assact.object_version_number,
         pp.full_name,
         pa.assignment_number
  from   pay_assignment_actions paa,
         pay_jp_isdf_assact_v   assact,
         per_all_assignments_f  pa,
         per_all_people_f       pp
  where  paa.payroll_action_id = p_payroll_action_id
  and    paa.action_status = 'C'
  and    assact.assignment_action_id = paa.assignment_action_id
  and    assact.transaction_status = 'F'
  and    pa.assignment_id = assact.assignment_id
  and    assact.effective_date
         between pa.effective_start_date and pa.effective_end_date
  and    pp.person_id = pa.person_id
  and    assact.effective_date
         between pp.effective_start_date and pp.effective_end_date
  order by lpad(pa.assignment_number,10,' '),
           pp.full_name;
--
begin
--
  select effective_date
  into   l_effective_date
  from   pay_jp_isdf_pact_v
  where  payroll_action_id = p_payroll_action_id;
--
  insert_session(l_effective_date);
  commit;
--
  fnd_file.put_line(fnd_file.output, 'Full Name                                Assignment Number');
  fnd_file.put_line(fnd_file.output, '---------------------------------------- ------------------------------');
  fnd_file.put_line(fnd_file.log,    'Full Name                                Assignment Number');
  fnd_file.put_line(fnd_file.log,    '---------------------------------------- ------------------------------');
--
  for l_rec in csr_assact loop
  --
    begin
    --
      do_approve(
        p_action_information_id => l_rec.action_information_id,
        p_object_version_number => l_rec.object_version_number);
    --
      commit;
    --
      fnd_file.put_line(fnd_file.output, rpad(l_rec.full_name, 40) || ' ' || rpad(l_rec.assignment_number, 30));
    --
    exception
    when others then
    --
      fnd_file.put_line(fnd_file.log, rpad(l_rec.full_name, 40) || ' ' || rpad(l_rec.assignment_number, 30));
      fnd_file.put_line(fnd_file.log, get_sqlerrm);
    --
    end;
  --
  end loop;
--
  delete_session;
  commit;
--
  -- retcode
  -- 0 : Success
  -- 1 : Warning
  -- 2 : Error
  --
  retcode := 0;
--
end do_approve;
--
-- -------------------------------------------------------------------------
-- do_transfer (Multiple Transaction)
-- -------------------------------------------------------------------------
procedure do_transfer(
  errbuf  out nocopy varchar2,
  retcode out nocopy varchar2,
  p_payroll_action_id in number,
  p_transfer_date         in varchar2,
  p_expire_after_transfer in varchar2 default 'N')
is
--
  l_effective_date date;
--
  cursor csr_assact
  is
  select /*+ ORDERED */
         assact.action_information_id,
         assact.object_version_number,
         pp.full_name,
         pa.assignment_number
  from   pay_assignment_actions paa,
         pay_jp_isdf_assact_v   assact,
         per_all_assignments_f  pa,
         per_all_people_f       pp
  where  paa.payroll_action_id = p_payroll_action_id
  and    paa.action_status = 'C'
  and    assact.assignment_action_id = paa.assignment_action_id
  and    assact.transaction_status = 'A'
  and    assact.transfer_status = 'U'
  and    pa.assignment_id = assact.assignment_id
  and    assact.effective_date
         between pa.effective_start_date and pa.effective_end_date
  and    pp.person_id = pa.person_id
  and    assact.effective_date
         between pp.effective_start_date and pp.effective_end_date
  order by lpad(pa.assignment_number,10,' '),
           pp.full_name;
--
begin
--
  select effective_date
  into   l_effective_date
  from   pay_jp_isdf_pact_v
  where  payroll_action_id = p_payroll_action_id;
--
  if p_transfer_date is not null then
    l_effective_date := fnd_date.canonical_to_date(p_transfer_date);
  end if;
--
  insert_session(l_effective_date);
  commit;
--
  fnd_file.put_line(fnd_file.output, 'Full Name                                Assignment Number');
  fnd_file.put_line(fnd_file.output, '---------------------------------------- ------------------------------');
  fnd_file.put_line(fnd_file.log,    'Full Name                                Assignment Number');
  fnd_file.put_line(fnd_file.log,    '---------------------------------------- ------------------------------');
--
  for l_rec in csr_assact loop
  --
    begin
    --
      do_transfer(
        p_action_information_id => l_rec.action_information_id,
        p_object_version_number => l_rec.object_version_number,
        p_transfer_date         => l_effective_date,
        p_create_session        => false,
        p_expire_after_transfer => p_expire_after_transfer);
    --
      commit;
    --
      fnd_file.put_line(fnd_file.output, rpad(l_rec.full_name, 40) || ' ' || rpad(l_rec.assignment_number, 30));
    --
    exception
    when others then
    --
      fnd_file.put_line(fnd_file.log, rpad(l_rec.full_name, 40) || ' ' || rpad(l_rec.assignment_number, 30));
      fnd_file.put_line(fnd_file.log, get_sqlerrm);
    --
    end;
  --
  end loop;
--
  delete_session;
  commit;
--
  -- retcode
  -- 0 : Success
  -- 1 : Warning
  -- 2 : Error
  --
  retcode := 0;
--
end do_transfer;
--
-- -------------------------------------------------------------------------
-- do_expire (Multiple Transaction)
-- -------------------------------------------------------------------------
procedure do_expire(
  errbuf  out nocopy varchar2,
  retcode out nocopy varchar2,
  p_payroll_action_id in number,
  p_expiry_date       in varchar2,
  p_mode              in varchar2 default null)
is
--
  l_effective_date date;
--
  cursor csr_assact
  is
  select /*+ ORDERED */
         assact.action_information_id,
         assact.object_version_number,
         pp.full_name,
         pa.assignment_number
  from   pay_assignment_actions paa,
         pay_jp_isdf_assact_v   assact,
         per_all_assignments_f  pa,
         per_all_people_f       pp
  where  paa.payroll_action_id = p_payroll_action_id
  and    paa.action_status = 'C'
  and    assact.assignment_action_id = paa.assignment_action_id
  and    assact.transaction_status = 'A'
  and    assact.transfer_status = 'T'
  and    pa.assignment_id = assact.assignment_id
  and    assact.effective_date
         between pa.effective_start_date and pa.effective_end_date
  and    pp.person_id = pa.person_id
  and    assact.effective_date
         between pp.effective_start_date and pp.effective_end_date
  order by lpad(pa.assignment_number,10,' '),
           pp.full_name;
--
begin
--
  select effective_date
  into   l_effective_date
  from   pay_jp_isdf_pact_v
  where  payroll_action_id = p_payroll_action_id;
--
  if p_expiry_date is not null then
    l_effective_date := fnd_date.canonical_to_date(p_expiry_date);
  end if;
--
  insert_session(l_effective_date);
  commit;
--
  fnd_file.put_line(fnd_file.output, 'Full Name                                Assignment Number');
  fnd_file.put_line(fnd_file.output, '---------------------------------------- ------------------------------');
  fnd_file.put_line(fnd_file.log,    'Full Name                                Assignment Number');
  fnd_file.put_line(fnd_file.log,    '---------------------------------------- ------------------------------');
--
  for l_rec in csr_assact loop
  --
    begin
    --
      do_expire(
        p_action_information_id => l_rec.action_information_id,
        p_object_version_number => l_rec.object_version_number,
        p_expiry_date           => l_effective_date,
        p_create_session        => false,
        p_mode                  => p_mode);
    --
      commit;
    --
      fnd_file.put_line(fnd_file.output, rpad(l_rec.full_name, 40) || ' ' || rpad(l_rec.assignment_number, 30));
    --
    exception
    when others then
    --
      fnd_file.put_line(fnd_file.log, rpad(l_rec.full_name, 40) || ' ' || rpad(l_rec.assignment_number, 30));
      fnd_file.put_line(fnd_file.log, get_sqlerrm);
    --
    end;
  --
  end loop;
--
  delete_session;
  commit;
--
  -- retcode
  -- 0 : Success
  -- 1 : Warning
  -- 2 : Error
  --
  retcode := 0;
--
end do_expire;
--
end pay_jp_isdf_ss_pkg;

/
