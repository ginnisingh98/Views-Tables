--------------------------------------------------------
--  DDL for Package Body PAY_JP_ISDF_ARCHIVE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_JP_ISDF_ARCHIVE_PKG" as
/* $Header: pyjpisfc.pkb 120.8.12010000.5 2009/06/01 10:38:11 spattem ship $ */
--
c_package                  constant varchar2(31) := 'pay_jp_isdf_archive_pkg.';
c_org_iv_name              constant ff_database_items.user_name%type := 'COM_ITX_INFO_WITHHOLD_AGENT_ENTRY_VALUE';
c_tax_type_iv_name         constant ff_database_items.user_name%type := 'COM_ITX_INFO_ITX_TYPE_ENTRY_VALUE';
--
c_com_calc_dpnt_elm_id     constant number := hr_jp_id_pkg.element_type_id('YEA_DEP_EXM_PROC', null, 'JP');
c_sp_type_iv_id            constant number := hr_jp_id_pkg.input_value_id(c_com_calc_dpnt_elm_id, 'SPOUSE_TYPE');
c_widow_type_iv_id         constant number := hr_jp_id_pkg.input_value_id(c_com_calc_dpnt_elm_id, 'WIDOW_TYPE');
--
c_com_itax_info_elm_id     constant number := hr_jp_id_pkg.element_type_id('COM_ITX_INFO', null, 'JP');
c_tax_type_iv_id           constant number := hr_jp_id_pkg.input_value_id(c_com_itax_info_elm_id, 'ITX_TYPE');
--
c_isdf_ins_elm_id          constant number := hr_jp_id_pkg.element_type_id('YEA_INS_PREM_EXM_DECLARE_INFO', null, 'JP');
c_life_gen_iv_id           constant number := hr_jp_id_pkg.input_value_id(c_isdf_ins_elm_id, 'GEN_LIFE_INS_PREM');
c_life_pens_iv_id          constant number := hr_jp_id_pkg.input_value_id(c_isdf_ins_elm_id, 'INDIVIDUAL_PENSION_PREM');
c_nonlife_long_iv_id       constant number := hr_jp_id_pkg.input_value_id(c_isdf_ins_elm_id, 'LONG_TERM_NONLIFE_INS_PREM');
c_nonlife_short_iv_id      constant number := hr_jp_id_pkg.input_value_id(c_isdf_ins_elm_id, 'SHORT_TERM_NONLIFE_INS_PREM');
c_earthquake_iv_id         constant number := hr_jp_id_pkg.input_value_id(c_isdf_ins_elm_id, 'EARTHQUAKE_INS_PREM');
--
c_isdf_is_elm_id           constant number := hr_jp_id_pkg.element_type_id('YEA_INS_PREM_SPOUSE_SP_EXM_INFO', null, 'JP');
c_social_iv_id             constant number := hr_jp_id_pkg.input_value_id(c_isdf_is_elm_id, 'DECLARE_SI_PREM');
c_mutual_aid_iv_id         constant number := hr_jp_id_pkg.input_value_id(c_isdf_is_elm_id, 'SMALL_COMPANY_MUTUAL_AID_PREM');
c_spouse_iv_id             constant number := hr_jp_id_pkg.input_value_id(c_isdf_is_elm_id, 'SPOUSE_INCOME');
c_sp_dct_exclude_iv_id     constant number := hr_jp_id_pkg.input_value_id(c_isdf_is_elm_id, 'SPOUSE_SP_EXM_EXCLUDE_FLAG');
c_national_pens_iv_id      constant number := hr_jp_id_pkg.input_value_id(c_isdf_is_elm_id, 'NATIONAL_PENSION_PREM');
--
c_st_upd_date_2007         constant date := to_date('2007/01/01','YYYY/MM/DD');
--
g_debug                    boolean := hr_utility.debug_enabled;
g_business_group_id        number;
g_legislation_code         per_business_groups_perf.legislation_code%type;
g_payroll_action_id        number;
g_assignment_action_id     number;
g_assignment_id            number;
g_effective_date           date;
g_payroll_id               number;
g_organization_id          number;
g_assignment_set_id        number;
g_process_assignments_flag varchar2(1);
g_bg_itax_dpnt_ref_type    varchar2(150);
g_asg_rec                  hr_jp_ast_utility_pkg.t_asg_rec;
--
type t_number_tbl is table of number index by binary_integer;
--
-- sequence of process.
-- 1. range_cursor/deinitialization_code (inc. init_pact, archive_pact) <= deinitialization_code is invoked in mark-for-retry instead of range_cursor
-- 2. assignment_action_creation (inc. init_pact) <= invoked by each population, reset global variable in case of multiple threads.
-- 3. archinit     (inc. init_pact) <= invoked by end process of each threads)
-- 4. archive_data (inc. init_assact, archive_assact, post_assact) <= invoked by each population
-- -------------------------------------------------------------------------
-- init_pact
-- -------------------------------------------------------------------------
procedure init_pact(
  p_payroll_action_id in number)
is
--
  l_proc varchar2(80) := c_package||'init_pact';
--
  cursor csr_action
  is
  select /*+ ORDERED */
         ppa.business_group_id,
         ppa.effective_date,
         ppa.legislative_parameters,
         pbg.legislation_code
  from   pay_payroll_actions ppa,
         per_business_groups_perf pbg
  where  ppa.payroll_action_id = p_payroll_action_id
  and    pbg.business_group_id = ppa.business_group_id;
--
  cursor csr_bg_itax_dpnt_ref_type
  is
  select /*+ ORDERED */
         nvl(nvl(pp.prl_information1, hoi.org_information2),'CTR_EE')
  from   /* Payroll and Business Group details */
         pay_all_payrolls_f          pp,
         hr_organization_information hoi
  where  pp.payroll_id = g_payroll_id
  and    g_effective_date
         between pp.effective_start_date and pp.effective_end_date
  and    hoi.organization_id(+) = pp.business_group_id
  and    hoi.org_information_context(+) = 'JP_BUSINESS_GROUP_INFO';
--
  l_csr_action csr_action%rowtype;
--
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  if g_payroll_action_id is null
  or g_payroll_action_id <> p_payroll_action_id then
  --
    if g_debug then
      hr_utility.set_location(l_proc,10);
      hr_utility.trace('no cache : g_pact_id('||g_payroll_action_id||'),p_pact_id('||p_payroll_action_id||')');
    end if;
    --
    open csr_action;
    fetch csr_action into l_csr_action;
    if csr_action%notfound then
      close csr_action;
      fnd_message.set_name('PAY','PAY_34985_INVALID_PAY_ACTION');
      fnd_message.raise_error;
    end if;
    close csr_action;
  --
    g_payroll_action_id := p_payroll_action_id;
    g_effective_date := l_csr_action.effective_date;
    g_business_group_id := l_csr_action.business_group_id;
    g_legislation_code := l_csr_action.legislation_code;
    g_payroll_id := fnd_number.canonical_to_number(pay_core_utils.get_parameter('PAYROLL_ID',l_csr_action.legislative_parameters));
    g_organization_id := fnd_number.canonical_to_number(pay_core_utils.get_parameter('ORGANIZATION_ID',l_csr_action.legislative_parameters));
    g_assignment_set_id := fnd_number.canonical_to_number(pay_core_utils.get_parameter('ASSIGNMENT_SET_ID',l_csr_action.legislative_parameters));
    g_process_assignments_flag := pay_core_utils.get_parameter('PROCESS_ASSIGNMENTS_FLAG',l_csr_action.legislative_parameters);
    g_archive_default_flag := pay_core_utils.get_parameter('ARCHIVE_DEFAULT_FLAG',l_csr_action.legislative_parameters);
    g_copy_archive_pact_id := fnd_number.canonical_to_number(pay_core_utils.get_parameter('COPY_ARCHIVE_PACT_ID',l_csr_action.legislative_parameters));
  --
    open csr_bg_itax_dpnt_ref_type;
    fetch csr_bg_itax_dpnt_ref_type into g_bg_itax_dpnt_ref_type;
    close csr_bg_itax_dpnt_ref_type;
  --
    if g_assignment_set_id is not null then
    --
      if g_debug then
        hr_utility.set_location(l_proc,20);
        hr_utility.trace('assignment set : '||g_assignment_set_id);
      end if;
    --
      hr_jp_ast_utility_pkg.pay_asgs(
        p_payroll_id        => g_payroll_id,
        p_effective_date    => g_effective_date,
        p_start_date        => g_effective_date,
        p_end_date          => g_effective_date,
        p_assignment_set_id => g_assignment_set_id,
        p_asg_rec           => g_asg_rec);
    --
      if g_debug then
        hr_utility.set_location(l_proc,30);
        hr_utility.trace('inclusive assignment count : '||g_asg_rec.assignment_id_tbl.count);
      end if;
    --
    end if;
  --
  end if;
  --
  if g_debug then
    hr_utility.trace('payroll_action_id        : '||g_payroll_action_id);
    hr_utility.trace('business_group_id        : '||g_business_group_id);
    hr_utility.trace('effective_date           : '||g_effective_date);
    hr_utility.trace('legislation_code         : '||g_legislation_code);
    hr_utility.trace('payroll_id               : '||g_payroll_id);
    hr_utility.trace('organization_id          : '||g_organization_id);
    hr_utility.trace('assignment_set_id        : '||g_assignment_set_id);
    hr_utility.trace('process_assignments_flag : '||g_process_assignments_flag);
    hr_utility.trace('archive_default_flag     : '||g_archive_default_flag);
    hr_utility.trace('copy_archive_pact_id     : '||g_copy_archive_pact_id);
    hr_utility.trace('bg_itax_dpnt_ref_type    : '||g_bg_itax_dpnt_ref_type);
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
end init_pact;
--
-- -------------------------------------------------------------------------
-- archive_pact
-- -------------------------------------------------------------------------
procedure archive_pact(
  p_payroll_action_id in number)
is
--
  l_proc varchar2(80) := c_package||'archive_pact';
--
  l_object_version_number number;
  l_validate_pact varchar2(1);
--
  cursor csr_validate_pact
  is
  select 'Y'
  from   pay_jp_isdf_pact_v
  where  payroll_action_id = p_payroll_action_id;
--
  cursor csr_org
  is
  select /*+ ORDERED */
         hoi2.org_information1 tax_office_name,
         hoi1.org_information1 salary_payer_name,
         hoi1.org_information6||hoi1.org_information7||hoi1.org_information8 salary_payer_address
  from   hr_all_organization_units hou,
         hr_organization_information hoi1,
         hr_organization_information hoi2
  where  hou.organization_id = g_organization_id
  and    hoi1.organization_id(+) = hou.organization_id
  and    hoi1.org_information_context(+) = 'JP_TAX_SWOT_INFO'
  and    hoi2.organization_id(+) = hou.organization_id
  and    hoi2.org_information_context(+) = 'JP_ITAX_WITHHELD_INFO';
--
  l_csr_org csr_org%rowtype;
--
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  -- no create pact in mark for retry.
  --
  open csr_validate_pact;
  fetch csr_validate_pact into l_validate_pact;
  --
  if csr_validate_pact%notfound then
  --
    if g_debug then
      hr_utility.set_location(l_proc,10);
    end if;
    --
    open csr_org;
    fetch csr_org into l_csr_org;
    --
    if csr_org%notfound then
      fnd_message.set_name('PAY','PAY_JP_INVALID_SWOT');
      fnd_message.raise_error;
    end if;
    --
    close csr_org;
    --
    if g_debug then
      hr_utility.set_location(l_proc,20);
      hr_utility.trace('tax_office_name      : '||l_csr_org.tax_office_name);
      hr_utility.trace('salary_payer_name    : '||l_csr_org.salary_payer_name);
      hr_utility.trace('salary_payer_address : '||l_csr_org.salary_payer_address);
      hr_utility.trace('start create_pact');
    end if;
    --
    pay_jp_isdf_dml_pkg.create_pact(
      p_action_information_id       => pay_jp_isdf_dml_pkg.next_action_information_id,
      p_payroll_action_id           => p_payroll_action_id,
      p_action_context_type         => 'PA',
      p_effective_date              => g_effective_date,
      p_action_information_category => 'JP_ISDF_PACT',
      p_payroll_id                  => g_payroll_id,
      p_organization_id             => g_organization_id,
      p_assignment_set_id           => g_assignment_set_id,
      p_submission_period_status    => 'C',
      p_submission_start_date       => null,
      p_submission_end_date         => null,
      p_tax_office_name             => l_csr_org.tax_office_name,
      p_salary_payer_name           => l_csr_org.salary_payer_name,
      p_salary_payer_address        => l_csr_org.salary_payer_address,
      p_object_version_number       => l_object_version_number);
  --
    if g_debug then
      hr_utility.trace('end create_pact');
      hr_utility.set_location(l_proc,30);
    end if;
  --
  end if;
  close csr_validate_pact;
--
  if g_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
end archive_pact;
--
-- -------------------------------------------------------------------------
-- range_cursor
-- -------------------------------------------------------------------------
procedure range_cursor(
  p_payroll_action_id in number,
  p_sqlstr            out nocopy varchar2)
is
--
  l_proc varchar2(80) := c_package||'range_cursor';
--
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  init_pact(p_payroll_action_id);
--
  if g_debug then
    hr_utility.set_location(l_proc,10);
  end if;
--
  archive_pact(p_payroll_action_id);
--
  if g_debug then
    hr_utility.set_location(l_proc,20);
  end if;
--
  -- no create assact when process assignments flag is set.
  --
  if g_process_assignments_flag = 'N' then
  --
    if g_debug then
      hr_utility.set_location(l_proc,30);
    end if;
  --
    p_sqlstr :=
      'select 1
       from   dual
       where  :payroll_action_id < 0';
  --
  else
  --
    if g_debug then
      hr_utility.set_location(l_proc,40);
    end if;
  --
    p_sqlstr :=
      'select /*+ ORDERED */
              distinct pp.person_id
       from   pay_payroll_actions ppa,
              per_all_people_f pp
       where  ppa.payroll_action_id = :payroll_action_id
       and    pp.business_group_id = ppa.business_group_id + 0
       order by pp.person_id';
  --
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
end range_cursor;
--
-- -------------------------------------------------------------------------
-- assignment_action_creation
-- -------------------------------------------------------------------------
procedure assignment_action_creation(
  p_payroll_action_id in number,
  p_start_person_id   in number,
  p_end_person_id     in number,
  p_chunk_number      in number)
is
--
  l_proc varchar2(80) := c_package||'assignment_action_creation';
  l_debug_cnt number := 0;
--
  l_tax_type pay_element_entry_values_f.screen_entry_value%type;
  l_organization_id number;
  l_assignment_action_id number;
  l_assignment_id number;
--
  cursor csr_proc_ass
  is
  select /*+ ORDERED */
         pa.assignment_id
  from   per_periods_of_service ppos,
         per_all_assignments_f pa
  where  ppos.person_id
         between p_start_person_id and p_end_person_id
  and    ppos.business_group_id + 0 = g_business_group_id
  and    g_effective_date
         between ppos.date_start and nvl(ppos.final_process_date,g_effective_date)
  and    pa.period_of_service_id = ppos.period_of_service_id
  and    pa.primary_flag        = 'Y' /*Added by JSAJJA as per Bug No 8435426*/
  and    g_effective_date
         between pa.effective_start_date and pa.effective_end_date
  and    pa.payroll_id + 0 = g_payroll_id;
--
  l_csr_proc_ass csr_proc_ass%rowtype;
--
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  -- Reset global variable in case of multiple threads.
  init_pact(p_payroll_action_id);
--
  if g_debug then
    hr_utility.set_location(l_proc,10);
  end if;
--
  open csr_proc_ass;
  loop
  --
    fetch csr_proc_ass into l_csr_proc_ass;
    exit when csr_proc_ass%notfound;
  --
    l_assignment_id := null;
    if g_assignment_set_id is not null then
    --
      if g_debug then
        hr_utility.set_location(l_proc,20);
        hr_utility.trace('assignment set : '||g_assignment_set_id);
      end if;
    --
      <<ass_exist>>
      for i in 1..g_asg_rec.assignment_id_tbl.count loop
      --
        if l_csr_proc_ass.assignment_id = g_asg_rec.assignment_id_tbl(i) then
          l_assignment_id := l_csr_proc_ass.assignment_id;
          exit ass_exist;
        end if;
      --
      end loop ass_exist;
    --
      if g_debug then
        hr_utility.set_location(l_proc,30);
        hr_utility.trace('assignment id : '||l_assignment_id);
      end if;
    --
    else
    --
      l_assignment_id := l_csr_proc_ass.assignment_id;
    --
      if g_debug then
        hr_utility.set_location(l_proc,40);
        hr_utility.trace('assignment id : '||l_assignment_id);
      end if;
    --
    end if;
  --
    if l_assignment_id is not null then
    --
      if g_debug then
        hr_utility.set_location(l_proc,50);
      end if;
    --
      pay_balance_pkg.set_context('DATE_EARNED',fnd_date.date_to_canonical(g_effective_date));
      pay_balance_pkg.set_context('ASSIGNMENT_ID',fnd_number.number_to_canonical(l_assignment_id));
      l_organization_id := pay_balance_pkg.run_db_item(c_org_iv_name,g_business_group_id,g_legislation_code);
    --
      if g_debug and l_debug_cnt < 1 then
        l_debug_cnt := l_debug_cnt + 1;
        hr_utility.set_location(l_proc,60);
        hr_utility.trace('diff org : g_org_id('||g_organization_id||'),l_org_id('||l_organization_id||')');
      end if;
    --
      if l_organization_id = g_organization_id then
      --
        l_tax_type := pay_balance_pkg.run_db_item(c_tax_type_iv_name,g_business_group_id,g_legislation_code);
      --
        if g_debug then
          hr_utility.set_location(l_proc,70);
          hr_utility.trace('tax type : '||l_tax_type);
        end if;
      --
      -- target only kou by legislative rule.
        if l_tax_type in ('M_KOU','D_KOU') then
        --
          if g_debug then
            hr_utility.set_location(l_proc,80);
            hr_utility.trace('assignment_id : '||l_assignment_id);
          end if;
        --
          select pay_assignment_actions_s.nextval
          into   l_assignment_action_id
          from   dual;
        --
          hr_nonrun_asact.insact(
            lockingactid => l_assignment_action_id,
            assignid     => l_assignment_id,
            pactid       => p_payroll_action_id,
            chunk        => p_chunk_number,
            greid        => null);
        --
          if g_debug then
            hr_utility.set_location(l_proc,90);
            hr_utility.trace('assignment_action_id : '||l_assignment_action_id);
          end if;
        --
        end if;
      --
      end if;
    --
    end if;
  --
  end loop;
  close csr_proc_ass;
--
  if g_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
end assignment_action_creation;
--
-- -------------------------------------------------------------------------
-- archinit
-- -------------------------------------------------------------------------
procedure archinit(
  p_payroll_action_id in number)
is
  l_proc varchar2(80) := c_package||'archinit';
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  init_pact(p_payroll_action_id);
--
  if g_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
end archinit;
--
-- -------------------------------------------------------------------------
-- init_assact
-- -------------------------------------------------------------------------
procedure init_assact(
  p_assignment_action_id in number,
  p_assignment_id        in number)
is
--
  l_proc varchar2(80) := c_package||'init_assact';
--
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  if g_assignment_action_id is null
  or g_assignment_action_id <> p_assignment_action_id then
  --
    if g_debug then
      hr_utility.set_location(l_proc,10);
      hr_utility.trace('no cache : g_assact_id('||g_assignment_action_id||'),p_assact_id('||p_assignment_action_id||')');
    end if;
  --
    g_assignment_action_id := p_assignment_action_id;
    g_assignment_id := p_assignment_id;
  --
  end if;
  --
  if g_debug then
    hr_utility.trace('assignment_action_id : '||g_assignment_action_id);
    hr_utility.trace('assignment_id        : '||g_assignment_id);
    hr_utility.set_location(l_proc,1000);
  end if;
--
end init_assact;
--
-- -------------------------------------------------------------------------
-- calc_li_annual_prem
-- -------------------------------------------------------------------------
procedure calc_li_annual_prem(
  p_ins_info_rec in t_li_info_rec,
  p_lig_prem     out nocopy number,
  p_lip_prem     out nocopy number,
  p_message      out nocopy varchar2)
is
--
  l_proc varchar2(80) := c_package||'calc_li_annual_prem';
--
  l_inputs ff_exec.inputs_t;
  l_outputs ff_exec.outputs_t;
  l_formula_id number;
--
  cursor csr_ff
  is
  select ff.formula_id
  from   ff_formulas_f ff
  where  ff.formula_name = p_ins_info_rec.calc_prem_ff
  and    nvl(ff.business_group_id,g_business_group_id) = g_business_group_id
  and    nvl(ff.legislation_code,g_legislation_code) = g_legislation_code
  and    g_effective_date
         between ff.effective_start_date and ff.effective_end_date;
--
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  open csr_ff;
  fetch csr_ff into l_formula_id;
  close csr_ff;
--
  if g_debug then
    hr_utility.set_location(l_proc,10);
    hr_utility.trace('formula_id : '||l_formula_id);
  end if;
--
  if l_formula_id is not null then
  --
    ff_exec.init_formula
      (p_formula_id     => l_formula_id,
       p_effective_date => g_effective_date,
       p_inputs         => l_inputs,
       p_outputs        => l_outputs);
  --
    if g_debug then
      hr_utility.set_location(l_proc,20);
    end if;
  --
    if l_inputs.count > 1 then
    --
      for i in l_inputs.first..l_inputs.last loop
      --
        if l_inputs(i).name = 'BUSINESS_GROUP_ID' then
          l_inputs(i).value := fnd_number.number_to_canonical(g_business_group_id);
        elsif l_inputs(i).name = 'PAYROLL_ID' then
          l_inputs(i).value := fnd_number.number_to_canonical(g_payroll_id);
        elsif l_inputs(i).name = 'PAYROLL_ACTION_ID' then
          l_inputs(i).value := fnd_number.number_to_canonical(g_payroll_action_id);
        elsif l_inputs(i).name = 'ASSIGNMENT_ID' then
          l_inputs(i).value := fnd_number.number_to_canonical(g_assignment_id);
        elsif l_inputs(i).name = 'ASSIGNMENT_ACTION_ID' then
          l_inputs(i).value := fnd_number.number_to_canonical(g_assignment_action_id);
        elsif l_inputs(i).name = 'DATE_EARNED' then
          l_inputs(i).value := fnd_date.date_to_canonical(g_effective_date);
      --
        elsif l_inputs(i).name = 'I_ASSIGNMENT_ID' then
          l_inputs(i).value := fnd_number.number_to_canonical(g_assignment_id);
        elsif l_inputs(i).name = 'I_ASSIGNMENT_ACTION_ID' then
          l_inputs(i).value := fnd_number.number_to_canonical(g_assignment_action_id);
        elsif l_inputs(i).name = 'I_INFO_TYPE' then
          l_inputs(i).value := p_ins_info_rec.info_type;
        elsif l_inputs(i).name = 'I_INS_CLASS' then
          l_inputs(i).value := p_ins_info_rec.ins_class;
        elsif l_inputs(i).name = 'I_INS_COMP_CODE' then
          l_inputs(i).value := p_ins_info_rec.ins_comp_code;
        elsif l_inputs(i).name = 'I_LIG_PREM_BAL' then
          l_inputs(i).value := p_ins_info_rec.lig_prem_bal;
        elsif l_inputs(i).name = 'I_LIG_PREM_MTH_ELE' then
          l_inputs(i).value := p_ins_info_rec.lig_prem_mth_ele;
        elsif l_inputs(i).name = 'I_LIG_PREM_BON_ELE' then
          l_inputs(i).value := p_ins_info_rec.lig_prem_bon_ele;
        elsif l_inputs(i).name = 'I_LIP_PREM_BAL' then
          l_inputs(i).value := p_ins_info_rec.lip_prem_bal;
        elsif l_inputs(i).name = 'I_LIP_PREM_MTH_ELE' then
          l_inputs(i).value := p_ins_info_rec.lip_prem_mth_ele;
        elsif l_inputs(i).name = 'I_LIP_PREM_BON_ELE' then
          l_inputs(i).value := p_ins_info_rec.lip_prem_bon_ele;
        elsif l_inputs(i).name = 'I_LINC_PREM' then
          l_inputs(i).value := fnd_number.number_to_canonical(p_ins_info_rec.linc_prem);
        end if;
      --
      end loop;
    --
      if g_debug then
        hr_utility.set_location(l_proc,30);
        hr_utility.trace('business_group_id    : '||g_business_group_id);
        hr_utility.trace('payroll_id           : '||g_payroll_id);
        hr_utility.trace('payroll_action_id    : '||g_payroll_action_id);
        hr_utility.trace('assignment_id        : '||g_assignment_id);
        hr_utility.trace('assignment_action_id : '||g_assignment_action_id);
        hr_utility.trace('effective_date       : '||fnd_date.date_to_canonical(g_effective_date));
        hr_utility.trace('i_info_type          : '||p_ins_info_rec.info_type);
        hr_utility.trace('i_ins_class          : '||p_ins_info_rec.ins_class);
        hr_utility.trace('i_ins_comp_code      : '||p_ins_info_rec.ins_comp_code);
        hr_utility.trace('i_lig_prem_bal       : '||p_ins_info_rec.lig_prem_bal);
        hr_utility.trace('i_lig_prem_mth_ele   : '||p_ins_info_rec.lig_prem_mth_ele);
        hr_utility.trace('i_lig_prem_bon_ele   : '||p_ins_info_rec.lig_prem_bon_ele);
        hr_utility.trace('i_lip_prem_bal       : '||p_ins_info_rec.lip_prem_bal);
        hr_utility.trace('i_lip_prem_mth_ele   : '||p_ins_info_rec.lip_prem_mth_ele);
        hr_utility.trace('i_lip_prem_bon_ele   : '||p_ins_info_rec.lip_prem_bon_ele);
        hr_utility.trace('i_linc_prem          : '||p_ins_info_rec.linc_prem);
      end if;
    --
    end if;
  --
    ff_exec.run_formula(
      p_inputs  => l_inputs,
      p_outputs => l_outputs);
  --
    if g_debug then
      hr_utility.set_location(l_proc,40);
    end if;
  --
    if l_outputs.count > 1 then
    --
      for j in l_outputs.first..l_outputs.last loop
      --
        if l_outputs(j).name = 'O_LIG_PREM' then
          p_lig_prem := fnd_number.canonical_to_number(ltrim(rtrim(l_outputs(j).value)));
        elsif l_outputs(j).name = 'O_LIP_PREM' then
          p_lip_prem := fnd_number.canonical_to_number(ltrim(rtrim(l_outputs(j).value)));
        elsif l_outputs(j).name = 'O_MESSAGE' then
          p_message := ltrim(rtrim(l_outputs(j).value));
        end if;
      --
      end loop;
    --
      if g_debug then
        hr_utility.set_location(l_proc,50);
        hr_utility.trace('lig_prem : '||p_lig_prem);
        hr_utility.trace('lip_prem : '||p_lip_prem);
        hr_utility.trace('message  : '||substrb(p_message,1,300));
      end if;
    --
      if p_message is not null then
      --
        if g_debug then
          hr_utility.set_location(l_proc,60);
        end if;
      --
        fnd_file.put_line(fnd_file.output,'Assignment Id : '||fnd_number.number_to_canonical(g_assignment_id));
        fnd_file.put_line(fnd_file.output,'----------------------------------------------------------------------------------------------------');
        fnd_file.put_line(fnd_file.output,p_message);
        fnd_file.put_line(fnd_file.output,' ');
      --
        if g_debug then
          hr_utility.set_location(l_proc,70);
        end if;
      --
      end if;
    --
    end if;
  --
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
end calc_li_annual_prem;
--
-- -------------------------------------------------------------------------
-- calc_ai_annual_prem
-- -------------------------------------------------------------------------
procedure calc_ai_annual_prem(
  p_ins_info_rec in t_ai_info_rec,
  p_eqi_prem     out nocopy number,
  p_ai_prem      out nocopy number,
  p_message      out nocopy varchar2)
is
--
  l_proc varchar2(80) := c_package||'calc_ai_annual_prem';
--
  l_inputs     ff_exec.inputs_t;
  l_outputs    ff_exec.outputs_t;
  l_formula_id number;
--
  cursor csr_ff
  is
  select ff.formula_id
  from   ff_formulas_f ff
  where  ff.formula_name = p_ins_info_rec.calc_prem_ff
  and    nvl(ff.business_group_id,g_business_group_id) = g_business_group_id
  and    nvl(ff.legislation_code,g_legislation_code) = g_legislation_code
  and    g_effective_date
         between ff.effective_start_date and ff.effective_end_date;
--
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  open csr_ff;
  fetch csr_ff into l_formula_id;
  close csr_ff;
--
  if g_debug then
    hr_utility.set_location(l_proc,10);
    hr_utility.trace('formula_id : '||l_formula_id);
  end if;
--
  if l_formula_id is not null then
  --
    ff_exec.init_formula
      (p_formula_id     => l_formula_id,
       p_effective_date => g_effective_date,
       p_inputs         => l_inputs,
       p_outputs        => l_outputs);
  --
    if g_debug then
      hr_utility.set_location(l_proc,20);
    end if;
  --
    if l_inputs.count > 1 then
    --
      for i in l_inputs.first..l_inputs.last loop
      --
        if l_inputs(i).name = 'BUSINESS_GROUP_ID' then
          l_inputs(i).value := fnd_number.number_to_canonical(g_business_group_id);
        elsif l_inputs(i).name = 'PAYROLL_ID' then
          l_inputs(i).value := fnd_number.number_to_canonical(g_payroll_id);
        elsif l_inputs(i).name = 'PAYROLL_ACTION_ID' then
          l_inputs(i).value := fnd_number.number_to_canonical(g_payroll_action_id);
        elsif l_inputs(i).name = 'ASSIGNMENT_ID' then
          l_inputs(i).value := fnd_number.number_to_canonical(g_assignment_id);
        elsif l_inputs(i).name = 'ASSIGNMENT_ACTION_ID' then
          l_inputs(i).value := fnd_number.number_to_canonical(g_assignment_action_id);
        elsif l_inputs(i).name = 'DATE_EARNED' then
          l_inputs(i).value := fnd_date.date_to_canonical(g_effective_date);
      --
        elsif l_inputs(i).name = 'I_ASSIGNMENT_ID' then
          l_inputs(i).value := fnd_number.number_to_canonical(g_assignment_id);
        elsif l_inputs(i).name = 'I_ASSIGNMENT_ACTION_ID' then
          l_inputs(i).value := fnd_number.number_to_canonical(g_assignment_action_id);
        elsif l_inputs(i).name = 'I_INFO_TYPE' then
          l_inputs(i).value := p_ins_info_rec.info_type;
        elsif l_inputs(i).name = 'I_INS_CLASS' then
          l_inputs(i).value := p_ins_info_rec.ins_class;
        elsif l_inputs(i).name = 'I_INS_TERM_TYPE' then
          l_inputs(i).value := p_ins_info_rec.ins_term_type;
        elsif l_inputs(i).name = 'I_INS_COMP_CODE' then
          l_inputs(i).value := p_ins_info_rec.ins_comp_code;
        elsif l_inputs(i).name = 'I_EQI_PREM_BAL' then
          l_inputs(i).value := p_ins_info_rec.eqi_prem_bal;
        elsif l_inputs(i).name = 'I_EQI_PREM_MTH_ELE' then
          l_inputs(i).value := p_ins_info_rec.eqi_prem_mth_ele;
        elsif l_inputs(i).name = 'I_EQI_PREM_BON_ELE' then
          l_inputs(i).value := p_ins_info_rec.eqi_prem_bon_ele;
        elsif l_inputs(i).name = 'I_AI_PREM_BAL' then
          l_inputs(i).value := p_ins_info_rec.ai_prem_bal;
        elsif l_inputs(i).name = 'I_AI_PREM_MTH_ELE' then
          l_inputs(i).value := p_ins_info_rec.ai_prem_mth_ele;
        elsif l_inputs(i).name = 'I_AI_PREM_BON_ELE' then
          l_inputs(i).value := p_ins_info_rec.ai_prem_bon_ele;
        elsif l_inputs(i).name = 'I_AI_PREM' then
          l_inputs(i).value := fnd_number.number_to_canonical(p_ins_info_rec.annual_prem);
        end if;
      --
      end loop;
    --
      if g_debug then
        hr_utility.set_location(l_proc,30);
        hr_utility.trace('business_group_id    : '||g_business_group_id);
        hr_utility.trace('payroll_id           : '||g_payroll_id);
        hr_utility.trace('payroll_action_id    : '||g_payroll_action_id);
        hr_utility.trace('assignment_id        : '||g_assignment_id);
        hr_utility.trace('assignment_action_id : '||g_assignment_action_id);
        hr_utility.trace('effective_date       : '||fnd_date.date_to_canonical(g_effective_date));
        hr_utility.trace('i_ins_class          : '||p_ins_info_rec.ins_class);
        hr_utility.trace('i_ins_term_type      : '||p_ins_info_rec.ins_term_type);
        hr_utility.trace('i_ins_comp_code      : '||p_ins_info_rec.ins_comp_code);
        hr_utility.trace('i_eqi_prem_bal       : '||p_ins_info_rec.eqi_prem_bal);
        hr_utility.trace('i_eqi_prem_mth_ele   : '||p_ins_info_rec.eqi_prem_mth_ele);
        hr_utility.trace('i_eqi_prem_bon_ele   : '||p_ins_info_rec.eqi_prem_bon_ele);
        hr_utility.trace('i_ai_prem_bal        : '||p_ins_info_rec.ai_prem_bal);
        hr_utility.trace('i_ai_prem_mth_ele    : '||p_ins_info_rec.ai_prem_mth_ele);
        hr_utility.trace('i_ai_prem_bon_ele    : '||p_ins_info_rec.ai_prem_bon_ele);
        hr_utility.trace('i_ai_prem            : '||p_ins_info_rec.annual_prem);
      end if;
    --
    end if;
  --
    ff_exec.run_formula(
      p_inputs  => l_inputs,
      p_outputs => l_outputs);
  --
    if g_debug then
      hr_utility.set_location(l_proc,40);
    end if;
  --
    if l_outputs.count >= 1 then
    --
      for j in l_outputs.first..l_outputs.last loop
      --
        if l_outputs(j).name = 'O_EQI_PREM' then
          p_eqi_prem := fnd_number.canonical_to_number(ltrim(rtrim(l_outputs(j).value)));
        elsif l_outputs(j).name = 'O_AI_PREM' then
          p_ai_prem := fnd_number.canonical_to_number(ltrim(rtrim(l_outputs(j).value)));
        elsif l_outputs(j).name = 'O_MESSAGE' then
          p_message := ltrim(rtrim(l_outputs(j).value));
        end if;
      --
      end loop;
    --
      if g_debug then
        hr_utility.set_location(l_proc,50);
        hr_utility.trace('eqi_prem : '||p_eqi_prem);
        hr_utility.trace('ai_prem  : '||p_ai_prem);
        hr_utility.trace('message  : '||substrb(p_message,1,300));
      end if;
    --
      if p_message is not null then
      --
        if g_debug then
          hr_utility.set_location(l_proc,60);
        end if;
      --
        fnd_file.put_line(fnd_file.output,'Assignment Id : '||fnd_number.number_to_canonical(g_assignment_id));
        fnd_file.put_line(fnd_file.output,'----------------------------------------------------------------------------------------------------');
        fnd_file.put_line(fnd_file.output,p_message);
        fnd_file.put_line(fnd_file.output,' ');
      --
        if g_debug then
          hr_utility.set_location(l_proc,70);
        end if;
      --
      end if;
    --
    end if;
  --
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
end calc_ai_annual_prem;
--
-- -------------------------------------------------------------------------
-- ee_datetrack_update_mode (for non-reccurring)
-- -------------------------------------------------------------------------
function ee_datetrack_update_mode(
  p_element_entry_id     in number,
  p_effective_start_date in date,
  p_effective_end_date   in date,
  p_effective_date       in date)
return varchar2
--
is
--
  l_datetrack_mode varchar2(30);
  l_exists         varchar2(1);
--
  --cursor csr_future_exists
  --is
  --select 'Y'
  --from   dual
  --where  exists(
  --         select null
  --         from   pay_element_entries_f
  --         where  element_entry_id = p_element_entry_id
  --         and    effective_start_date = p_effective_end_date + 1);
--
begin
--
  -- always CORRECTION in case of non-recurring.
  if p_effective_start_date = trunc(p_effective_date,'MM') then
    l_datetrack_mode := 'CORRECTION';
  end if;
--
  --if p_effective_start_date = p_effective_date then
  --  l_datetrack_mode := 'CORRECTION';
  --else
  ----
  --  open csr_future_exists;
  --  fetch csr_future_exists into l_exists;
  ----
  --  if csr_future_exists%notfound then
  --    l_datetrack_mode := 'UPDATE';
  --  else
  --    l_datetrack_mode := 'UPDATE_CHANGE_INSERT';
  --  end if;
  ----
  --end if;
--
return l_datetrack_mode;
--
end ee_datetrack_update_mode;
--
-- -------------------------------------------------------------------------
-- fetch_entry
-- -------------------------------------------------------------------------
procedure fetch_entry(
  p_assignment_id     in number,
  p_business_group_id in number,
  p_effective_date    in date,
  p_entry_rec         out nocopy t_entry_rec)
is
--
  l_proc varchar2(80) := c_package||'fetch_entry';
--
  cursor csr_entry(p_element_type_id in number)
  is
  select /*+ ORDERED */
         pee.element_entry_id,
         pee.effective_start_date,
         pee.effective_end_date,
         pee.object_version_number,
         peev.input_value_id,
         peev.screen_entry_value
  from   pay_element_links_f        pel,
         pay_element_entries_f      pee,
         pay_element_entry_values_f peev
  where  pel.element_type_id = p_element_type_id
  and    pel.business_group_id + 0 = p_business_group_id
  and    p_effective_date
         between pel.effective_start_date and pel.effective_end_date
  and    pee.assignment_id = p_assignment_id
  and    pee.element_link_id = pel.element_link_id
  and    p_effective_date
         between pee.effective_start_date and pee.effective_end_date
  and    pee.entry_type = 'E'
  and    peev.element_entry_id = pee.element_entry_id
  and    peev.effective_start_date = pee.effective_start_date
  and    peev.effective_end_date = pee.effective_end_date;
--
  l_csr_entry csr_entry%rowtype;
--
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  p_entry_rec.ins_entry_cnt := 0;
  p_entry_rec.ins_datetrack_update_mode    := null;
  p_entry_rec.ins_element_entry_id         := null;
  p_entry_rec.ins_ee_object_version_number := null;
  p_entry_rec.life_gen_ins_prem            := null;
  p_entry_rec.life_pens_ins_prem           := null;
  p_entry_rec.nonlife_long_ins_prem        := null;
  p_entry_rec.nonlife_short_ins_prem       := null;
  p_entry_rec.earthquake_ins_prem          := null;
  p_entry_rec.is_entry_cnt := 0;
  p_entry_rec.is_datetrack_update_mode     := null;
  p_entry_rec.is_element_entry_id          := null;
  p_entry_rec.is_ee_object_version_number  := null;
  p_entry_rec.social_ins_prem              := null;
  p_entry_rec.mutual_aid_prem              := null;
  p_entry_rec.spouse_income                := null;
  p_entry_rec.sp_dct_exclude               := null;
  p_entry_rec.national_pens_ins_prem       := null;
--
  open  csr_entry(c_isdf_ins_elm_id);
  loop
  --
    fetch csr_entry into l_csr_entry;
    exit when csr_entry%notfound;
  --
    if csr_entry%rowcount = 1 then
      p_entry_rec.ins_datetrack_update_mode    := ee_datetrack_update_mode(l_csr_entry.element_entry_id,l_csr_entry.effective_start_date,l_csr_entry.effective_end_date,p_effective_date);
      p_entry_rec.ins_element_entry_id         := l_csr_entry.element_entry_id;
      p_entry_rec.ins_ee_object_version_number := l_csr_entry.object_version_number;
      p_entry_rec.ins_entry_cnt := p_entry_rec.ins_entry_cnt + 1;
    end if;
  --
    if l_csr_entry.input_value_id = c_life_gen_iv_id then
    --
      p_entry_rec.life_gen_ins_prem := fnd_number.canonical_to_number(l_csr_entry.screen_entry_value);
    --
    elsif l_csr_entry.input_value_id = c_life_pens_iv_id then
    --
      p_entry_rec.life_pens_ins_prem := fnd_number.canonical_to_number(l_csr_entry.screen_entry_value);
    --
    elsif l_csr_entry.input_value_id = c_nonlife_long_iv_id then
    --
      p_entry_rec.nonlife_long_ins_prem := fnd_number.canonical_to_number(l_csr_entry.screen_entry_value);
    --
    elsif l_csr_entry.input_value_id = c_nonlife_short_iv_id then
    --
      p_entry_rec.nonlife_short_ins_prem := fnd_number.canonical_to_number(l_csr_entry.screen_entry_value);
    --
    elsif l_csr_entry.input_value_id = c_earthquake_iv_id then
    --
      p_entry_rec.earthquake_ins_prem := fnd_number.canonical_to_number(l_csr_entry.screen_entry_value);
    --
    end if;
  --
  end loop;
  close csr_entry;
  --
--
  open csr_entry(c_isdf_is_elm_id);
  loop
  --
    fetch csr_entry into l_csr_entry;
    exit when csr_entry%notfound;
  --
    if csr_entry%rowcount = 1 then
      p_entry_rec.is_datetrack_update_mode    := ee_datetrack_update_mode(l_csr_entry.element_entry_id,l_csr_entry.effective_start_date,l_csr_entry.effective_end_date,p_effective_date);
      p_entry_rec.is_element_entry_id         := l_csr_entry.element_entry_id;
      p_entry_rec.is_ee_object_version_number := l_csr_entry.object_version_number;
      p_entry_rec.is_entry_cnt := p_entry_rec.is_entry_cnt + 1;
    end if;
  --
    if l_csr_entry.input_value_id = c_social_iv_id then
    --
      p_entry_rec.social_ins_prem := fnd_number.canonical_to_number(l_csr_entry.screen_entry_value);
    --
    elsif l_csr_entry.input_value_id = c_mutual_aid_iv_id then
    --
      p_entry_rec.mutual_aid_prem := fnd_number.canonical_to_number(l_csr_entry.screen_entry_value);
    --
    elsif l_csr_entry.input_value_id = c_spouse_iv_id then
    --
      p_entry_rec.spouse_income := fnd_number.canonical_to_number(l_csr_entry.screen_entry_value);
    --
    elsif l_csr_entry.input_value_id = c_sp_dct_exclude_iv_id then
    --
      p_entry_rec.sp_dct_exclude := l_csr_entry.screen_entry_value;
    --
    elsif l_csr_entry.input_value_id = c_national_pens_iv_id then
    --
      p_entry_rec.national_pens_ins_prem := fnd_number.canonical_to_number(l_csr_entry.screen_entry_value);
    --
    end if;
  --
  end loop;
  close csr_entry;
--
  if g_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
end fetch_entry;
--
-- -------------------------------------------------------------------------
-- archive_assact
-- -------------------------------------------------------------------------
procedure archive_assact(
  p_assignment_action_id in number,
  p_assignment_id        in number)
is
--
  l_proc varchar2(80) := c_package||'archive_assact';
--
  l_lig_prem number;
  l_lip_prem number;
  l_ai_prem  number;
--
  l_eqi_prem number;
  l_nli_prem number;
--
  l_message varchar2(2000);
  l_object_version_number number;
--
  l_li_info_rec t_li_info_rec;
  l_ai_info_rec t_ai_info_rec;
  l_spouse_rec t_spouse_rec;
--
  l_entry_rec t_entry_rec;
  l_tax_type pay_element_entry_values_f.screen_entry_value%type;
--
  l_copy_archive_assact_id number;
--
  cursor csr_emp
  is
  select /*+ ORDERED */
         pp.person_id,
         pp.business_group_id,
         pp.employee_number employee_number,
         pp.last_name last_name_kana,
         pp.first_name first_name_kana,
         pp.per_information18 last_name,
         pp.per_information19 first_name,
         pp.per_information18||' '||pp.per_information19 full_name,
         decode(par.address_id,null,pac.postal_code,par.postal_code) postal_code,
         trim(substrb(decode(par.address_id,null,
           pac.address_line1||pac.address_line2||pac.address_line3,
           par.address_line1||par.address_line2||par.address_line3),1,240)) address
  from   per_all_assignments_f pa,
         per_all_people_f pp,
         per_addresses par,
         per_addresses pac
  where  pa.assignment_id = p_assignment_id
  and    g_effective_date
         between pa.effective_start_date and pa.effective_end_date
  and    pp.person_id = pa.person_id
  and    g_effective_date
         between pp.effective_start_date and pp.effective_end_date
  and    par.person_id(+) = pp.person_id
  and    par.address_type(+) = 'JP_R'
  and    g_effective_date
         between par.date_from(+) and nvl(par.date_to(+),g_effective_date)
  and    pac.person_id(+) = pp.person_id
  and    pac.address_type(+) = 'JP_C'
  and    g_effective_date
         between pac.date_from(+) and nvl(pac.date_to(+),g_effective_date);
--
  cursor csr_gen
  is
  select /*+ ORDERED */
         paei.assignment_extra_info_id,
         paei.object_version_number aei_object_version_number,
         paei.information_type info_type,
         paei.aei_information1 gen_ins_class,
         paei.aei_information2 gen_ins_company_code,
         hoi.org_information2 ins_company_name,
         hoi.org_information3 calc_prem_ff,
         hoi.org_information4 lig_prem_bal,
         hoi.org_information5 lig_prem_mth_ele,
         hoi.org_information6 lig_prem_bon_ele,
         null lip_prem_bal,
         null lip_prem_mth_ele,
         null lip_prem_bon_ele,
         fnd_date.canonical_to_date(paei.aei_information3) start_date,
         fnd_date.canonical_to_date(paei.aei_information4) end_date,
         paei.aei_information5  ins_type,
         null ins_period_start_date,
         paei.aei_information6  ins_period,
         paei.aei_information7  contractor_name,
         paei.aei_information8  beneficiary_name,
         paei.aei_information9  beneficiary_relship,
         fnd_number.canonical_to_number(paei.aei_information10) linc_prem
  from   per_assignment_extra_info paei,
         hr_organization_information hoi
  where  paei.assignment_id = p_assignment_id
  and    paei.information_type = 'JP_ASS_LIG_INFO'
  -- include PC for customized valuset
  --and    paei.aei_information1 in ('GIP','LINC')
  and    g_effective_date
         between nvl(fnd_date.canonical_to_date(paei.aei_information3),nvl(fnd_date.canonical_to_date(paei.aei_information4)+1,hr_api.g_sot))
         and nvl(fnd_date.canonical_to_date(paei.aei_information4),hr_api.g_eot)
  and    hoi.org_information1 = paei.aei_information2
  and    hoi.org_information_context
         = decode(paei.aei_information1,'GIP','JP_LI_GIP_INFO','LINC','JP_LI_LINC_INFO','X')
  and    hoi.organization_id = g_organization_id
  -- irregular case for duplicate org
  and    not exists(
           select null
           from   hr_organization_information hoi2
           where  hoi2.org_information1 = hoi.org_information1
           and    hoi2.org_information_context = hoi.org_information_context
           and    hoi2.organization_id = hoi.organization_id
           and    hoi2.org_information_id < hoi.org_information_id)
  order by
    decode(paei.aei_information1,'GIP',1,2),
    paei.aei_information2;
--
  cursor csr_pens
  is
  select /*+ ORDERED */
         paei.assignment_extra_info_id,
         paei.object_version_number aei_object_version_number,
         paei.information_type info_type,
         paei.aei_information1 pens_ins_class,
         paei.aei_information2 pens_ins_company_code,
         hoi.org_information2 ins_company_name,
         hoi.org_information3 calc_prem_ff,
         null lig_prem_bal,
         null lig_prem_mth_ele,
         null lig_prem_bon_ele,
         hoi.org_information7 lip_prem_bal,
         hoi.org_information8 lip_prem_mth_ele,
         hoi.org_information9 lip_prem_bon_ele,
         fnd_date.canonical_to_date(paei.aei_information3) start_date,
         fnd_date.canonical_to_date(paei.aei_information4) end_date,
         paei.aei_information5  ins_type,
         fnd_date.canonical_to_date(paei.aei_information6)  ins_period_start_date,
         paei.aei_information7  ins_period,
         paei.aei_information8  contractor_name,
         paei.aei_information9  beneficiary_name,
         paei.aei_information10  beneficiary_relship,
         fnd_number.canonical_to_number(paei.aei_information11) linc_prem
  from   per_assignment_extra_info paei,
         hr_organization_information hoi
  where  paei.assignment_id = p_assignment_id
  and    paei.information_type = 'JP_ASS_LIP_INFO'
  -- include PC for customized valuset
  --and    paei.aei_information1 in ('GIP','LINC')
  and    g_effective_date
         between nvl(fnd_date.canonical_to_date(paei.aei_information3),nvl(fnd_date.canonical_to_date(paei.aei_information4)+1,hr_api.g_sot))
         and nvl(fnd_date.canonical_to_date(paei.aei_information4),hr_api.g_eot)
  and    hoi.org_information1 = paei.aei_information2
  and    hoi.org_information_context
         = decode(paei.aei_information1,'GIP','JP_LI_GIP_INFO','LINC','JP_LI_LINC_INFO','X')
  and    hoi.organization_id = g_organization_id
  -- irregular case for duplicate org
  and    not exists(
           select null
           from   hr_organization_information hoi2
           where  hoi2.org_information1 = hoi.org_information1
           and    hoi2.org_information_context = hoi.org_information_context
           and    hoi2.organization_id = hoi.organization_id
           and    hoi2.org_information_id < hoi.org_information_id)
  order by
    decode(paei.aei_information1,'GIP',1,2),
    paei.aei_information2;
--
  cursor csr_nonlife
  is
  select /*+ ORDERED */
         paei.assignment_extra_info_id,
         paei.object_version_number aei_object_version_number,
         paei.information_type info_type,
         paei.aei_information13 nonlife_ins_class,
         paei.aei_information1 nonlife_ins_term_type,
         paei.aei_information2 nonlife_ins_company_code,
         hoi.org_information2 ins_company_name,
         hoi.org_information3 calc_prem_ff,
         hoi.org_information7 eqi_prem_bal,
         hoi.org_information8 eqi_prem_mth_ele,
         hoi.org_information9 eqi_prem_bon_ele,
         hoi.org_information4 ai_prem_bal,
         hoi.org_information5 ai_prem_mth_ele,
         hoi.org_information6 ai_prem_bon_ele,
         fnd_date.canonical_to_date(paei.aei_information3) start_date,
         fnd_date.canonical_to_date(paei.aei_information4) end_date,
         paei.aei_information5  ins_type,
         paei.aei_information6  ins_period,
         paei.aei_information7  contractor_name,
         paei.aei_information8  beneficiary_name,
         paei.aei_information9  beneficiary_relship,
         decode(to_char(sign(g_effective_date - c_st_upd_date_2007)),'-1',paei.aei_information10,null) maturity_repayment,
         fnd_number.canonical_to_number(paei.aei_information11) annual_prem
  from   per_assignment_extra_info paei,
         hr_organization_information hoi
  where  paei.assignment_id = p_assignment_id
  and    paei.information_type = 'JP_ASS_AI_INFO'
  -- include PC for customized valuset
  --and    paei.aei_information13 = 'AP'
  and    paei.aei_information1 <> decode(to_char(sign(g_effective_date - c_st_upd_date_2007)),'-1','EQ','S')
  and    g_effective_date
         between nvl(fnd_date.canonical_to_date(paei.aei_information3),nvl(fnd_date.canonical_to_date(paei.aei_information4)+1,hr_api.g_sot))
         and nvl(fnd_date.canonical_to_date(paei.aei_information4),hr_api.g_eot)
  and    hoi.org_information1 = paei.aei_information2
  and    hoi.org_information_context = 'JP_ACCIDENT_INS_INFO'
  and    hoi.organization_id = g_organization_id
  -- irregular case for duplicate org
  and    not exists(
           select null
           from   hr_organization_information hoi2
           where  hoi2.org_information1 = hoi.org_information1
           and    hoi2.org_information_context = hoi.org_information_context
           and    hoi2.organization_id = hoi.organization_id
           and    hoi2.org_information_id < hoi.org_information_id)
  order by paei.aei_information13,
           decode(paei.aei_information1,'EQ',1,'L',2,3),
           paei.aei_information2;
--
  cursor csr_copy_assact
  is
  select /*+ ORDERED */
         assact.assignment_action_id
  from   pay_assignment_actions paa,
         pay_jp_isdf_assact_v   assact
  where  paa.payroll_action_id = g_copy_archive_pact_id
  and    paa.assignment_id = p_assignment_id
  and    paa.action_status = 'C'
  and    assact.assignment_action_id = paa.assignment_action_id
  and    assact.transfer_status <> 'E'
  and    assact.transaction_status in ('A','F');
--
  cursor csr_copy_life_gen
  is
  select *
  from   pay_jp_isdf_life_gen_v
  where  assignment_action_id = l_copy_archive_assact_id
  and    status <> 'D';
--
  cursor csr_copy_life_pens
  is
  select *
  from   pay_jp_isdf_life_pens_v
  where  assignment_action_id = l_copy_archive_assact_id
  and    status <> 'D';
--
  cursor csr_copy_nonlife
  is
  select *
  from   pay_jp_isdf_nonlife_v
  where  assignment_action_id = l_copy_archive_assact_id
  and    status <> 'D';
--
  cursor csr_copy_social
  is
  select *
  from   pay_jp_isdf_social_v
  where  assignment_action_id = l_copy_archive_assact_id
  and    status <> 'D';
--
  cursor csr_copy_mutual_aid
  is
  select *
  from   pay_jp_isdf_mutual_aid_v
  where  assignment_action_id = l_copy_archive_assact_id
  and    status <> 'D';
--
  cursor csr_copy_spouse
  is
  select *
  from   pay_jp_isdf_spouse_v
  where  assignment_action_id = l_copy_archive_assact_id
  and    status <> 'D';
--
  cursor csr_copy_spouse_inc
  is
  select *
  from   pay_jp_isdf_spouse_inc_v
  where  assignment_action_id = l_copy_archive_assact_id
  and    status <> 'D';
--
  l_csr_emp csr_emp%rowtype;
--
  l_csr_copy_life_gen   csr_copy_life_gen%rowtype;
  l_csr_copy_life_pens  csr_copy_life_pens%rowtype;
  l_csr_copy_nonlife    csr_copy_nonlife%rowtype;
  l_csr_copy_social     csr_copy_social%rowtype;
  l_csr_copy_mutual_aid csr_copy_mutual_aid%rowtype;
  l_csr_copy_spouse     csr_copy_spouse%rowtype;
  l_csr_copy_spouse_inc csr_copy_spouse_inc%rowtype;
--
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  if g_archive_default_flag = 'Y' then
  --
    if g_debug then
      hr_utility.set_location(l_proc,10);
    end if;
  --
    open csr_emp;
    fetch csr_emp into l_csr_emp;
    close csr_emp;
  --
    if g_debug then
      hr_utility.set_location(l_proc,20);
      hr_utility.trace('employee_number : '||l_csr_emp.employee_number);
      hr_utility.trace('last_name_kana  : '||l_csr_emp.last_name_kana);
      hr_utility.trace('first_name_kana : '||l_csr_emp.first_name_kana);
      hr_utility.trace('last_name       : '||l_csr_emp.last_name);
      hr_utility.trace('first_name      : '||l_csr_emp.first_name);
      hr_utility.trace('full_name       : '||l_csr_emp.full_name);
      hr_utility.trace('postal_code     : '||l_csr_emp.postal_code);
      hr_utility.trace('address         : '||l_csr_emp.address);
    end if;
  --
    if g_debug then
      hr_utility.trace('start create_emp');
    end if;
  --
    pay_jp_isdf_dml_pkg.create_emp(
      p_action_information_id       => pay_jp_isdf_dml_pkg.next_action_information_id,
      p_assignment_action_id        => p_assignment_action_id,
      p_action_context_type         => 'AAP',
      p_assignment_id               => p_assignment_id,
      p_effective_date              => g_effective_date,
      p_action_information_category => 'JP_ISDF_EMP',
      p_employee_number             => l_csr_emp.employee_number,
      p_last_name_kana              => l_csr_emp.last_name_kana,
      p_first_name_kana             => l_csr_emp.first_name_kana,
      p_last_name                   => l_csr_emp.last_name,
      p_first_name                  => l_csr_emp.first_name,
      p_postal_code                 => l_csr_emp.postal_code,
      p_address                     => l_csr_emp.address,
      p_object_version_number       => l_object_version_number);
  --
    if g_debug then
      hr_utility.trace('end create_emp');
      hr_utility.set_location(l_proc,30);
      hr_utility.trace('start create_entry');
    end if;
  --
    -- jp_isdf_entry is fetched in the transfer process since transfer date can be specified as different from archive date,
    -- archive data in this archive time will be meaningless in the transfer time.
    -- However, finalize action is to fix all entry data except for _o prefex columns,
    -- so whatever, this make jp_isdf_entry archive.
    --
    fetch_entry(
      p_assignment_id     => p_assignment_id,
      p_business_group_id => g_business_group_id,
      p_effective_date    => g_effective_date,
      p_entry_rec         => l_entry_rec);
  --
    if l_entry_rec.ins_entry_cnt + l_entry_rec.is_entry_cnt > 0 then
    --
      pay_jp_isdf_dml_pkg.create_entry(
        p_action_information_id        => pay_jp_isdf_dml_pkg.next_action_information_id,
        p_assignment_action_id         => p_assignment_action_id,
        p_action_context_type          => 'AAP',
        p_assignment_id                => p_assignment_id,
        p_effective_date               => g_effective_date,
        p_action_information_category  => 'JP_ISDF_ENTRY',
        p_status                       => 'Q',
        p_ins_datetrack_update_mode    => l_entry_rec.ins_datetrack_update_mode,
        p_ins_element_entry_id         => l_entry_rec.ins_element_entry_id,
        p_ins_ee_object_version_number => l_entry_rec.ins_ee_object_version_number,
        p_life_gen_ins_prem            => l_entry_rec.life_gen_ins_prem,
        p_life_gen_ins_prem_o          => null,
        p_life_pens_ins_prem           => l_entry_rec.life_pens_ins_prem,
        p_life_pens_ins_prem_o         => null,
        p_nonlife_long_ins_prem        => l_entry_rec.nonlife_long_ins_prem,
        p_nonlife_long_ins_prem_o      => null,
        p_nonlife_short_ins_prem       => l_entry_rec.nonlife_short_ins_prem,
        p_nonlife_short_ins_prem_o     => null,
        p_earthquake_ins_prem          => l_entry_rec.earthquake_ins_prem,
        p_earthquake_ins_prem_o        => null,
        p_is_datetrack_update_mode     => l_entry_rec.is_datetrack_update_mode,
        p_is_element_entry_id          => l_entry_rec.is_element_entry_id,
        p_is_ee_object_version_number  => l_entry_rec.is_ee_object_version_number,
        p_social_ins_prem              => l_entry_rec.social_ins_prem,
        p_social_ins_prem_o            => null,
        p_mutual_aid_prem              => l_entry_rec.mutual_aid_prem,
        p_mutual_aid_prem_o            => null,
        p_spouse_income                => l_entry_rec.spouse_income,
        p_spouse_income_o              => null,
        p_national_pens_ins_prem       => l_entry_rec.national_pens_ins_prem,
        p_national_pens_ins_prem_o     => null,
        p_object_version_number        => l_object_version_number);
    --
    end if;
  --
    if g_debug then
      hr_utility.trace('end create_entry');
      hr_utility.set_location(l_proc,40);
    end if;
  --
    if g_copy_archive_pact_id is null then
    --
      if g_debug then
        hr_utility.trace('start create_life_gen');
        hr_utility.set_location(l_proc,50);
      end if;
    --
      open csr_gen;
      loop
      --
        fetch csr_gen into l_li_info_rec;
        exit when csr_gen%notfound;
      --
        if g_debug then
          hr_utility.set_location(l_proc,60);
          hr_utility.trace('assignment_extra_info_id  : '||l_li_info_rec.assignment_extra_info_id);
          hr_utility.trace('aei_object_version_number : '||l_li_info_rec.aei_object_version_number);
          hr_utility.trace('info_type                 : '||l_li_info_rec.info_type);
          hr_utility.trace('gen_ins_class             : '||l_li_info_rec.ins_class);
          hr_utility.trace('gen_ins_company_code      : '||l_li_info_rec.ins_comp_code);
          hr_utility.trace('ins_company_name          : '||l_li_info_rec.ins_comp_name);
          hr_utility.trace('calc_prem_ff              : '||l_li_info_rec.calc_prem_ff);
          hr_utility.trace('lig_prem_bal              : '||l_li_info_rec.lig_prem_bal);
          hr_utility.trace('lig_prem_mth_ele          : '||l_li_info_rec.lig_prem_mth_ele);
          hr_utility.trace('lig_prem_bon_ele          : '||l_li_info_rec.lig_prem_bon_ele);
          hr_utility.trace('start_date                : '||fnd_date.date_to_canonical(l_li_info_rec.start_date));
          hr_utility.trace('end_date                  : '||fnd_date.date_to_canonical(l_li_info_rec.end_date));
          hr_utility.trace('ins_type                  : '||l_li_info_rec.ins_type);
          hr_utility.trace('ins_period_start_date     : '||fnd_date.date_to_canonical(l_li_info_rec.ins_period_start_date));
          hr_utility.trace('ins_period                : '||l_li_info_rec.ins_period);
          hr_utility.trace('contractor_name           : '||l_li_info_rec.contractor_name);
          hr_utility.trace('beneficiary_name          : '||l_li_info_rec.beneficiary_name);
          hr_utility.trace('beneficiary_relship       : '||l_li_info_rec.beneficiary_relship);
          hr_utility.trace('linc_prem                 : '||fnd_number.number_to_canonical(l_li_info_rec.linc_prem));
        end if;
      --
        l_lig_prem := null;
      --
        if l_li_info_rec.ins_class <> 'PC' then
        --
          calc_li_annual_prem(
            p_ins_info_rec => l_li_info_rec,
            p_lig_prem     => l_lig_prem,
            p_lip_prem     => l_lip_prem,
            p_message      => l_message);
        --
        end if;
      --
        if g_debug then
          hr_utility.set_location(l_proc,70);
          hr_utility.trace('annual_prem : '||l_lig_prem);
        end if;
      --
        pay_jp_isdf_dml_pkg.create_life_gen(
          p_action_information_id       => pay_jp_isdf_dml_pkg.next_action_information_id,
          p_assignment_action_id        => p_assignment_action_id,
          p_action_context_type         => 'AAP',
          p_assignment_id               => p_assignment_id,
          p_effective_date              => g_effective_date,
          p_action_information_category => 'JP_ISDF_LIFE_GEN',
          p_status                      => 'Q',
          p_assignment_extra_info_id    => l_li_info_rec.assignment_extra_info_id,
          p_aei_object_version_number   => l_li_info_rec.aei_object_version_number,
          p_gen_ins_class               => l_li_info_rec.ins_class,
          p_gen_ins_company_code        => l_li_info_rec.ins_comp_code,
          p_ins_company_name            => l_li_info_rec.ins_comp_name,
          p_ins_type                    => l_li_info_rec.ins_type,
          p_ins_period                  => l_li_info_rec.ins_period,
          p_contractor_name             => l_li_info_rec.contractor_name,
          p_beneficiary_name            => l_li_info_rec.beneficiary_name,
          p_beneficiary_relship         => l_li_info_rec.beneficiary_relship,
          p_annual_prem                 => l_lig_prem,
          p_object_version_number       => l_object_version_number);
      --
        if g_debug then
          hr_utility.set_location(l_proc,80);
        end if;
      --
      end loop;
      close csr_gen;
    --
      if g_debug then
        hr_utility.trace('end create_life_gen');
        hr_utility.set_location(l_proc,90);
        hr_utility.trace('start create_life_pens');
      end if;
    --
      open csr_pens;
      loop
      --
        fetch csr_pens into l_li_info_rec;
        exit when csr_pens%notfound;
      --
        if g_debug then
          hr_utility.set_location(l_proc,100);
          hr_utility.trace('assignment_extra_info_id  : '||l_li_info_rec.assignment_extra_info_id);
          hr_utility.trace('aei_object_version_number : '||l_li_info_rec.aei_object_version_number);
          hr_utility.trace('info_type                 : '||l_li_info_rec.info_type);
          hr_utility.trace('pens_ins_class            : '||l_li_info_rec.ins_class);
          hr_utility.trace('pens_ins_company_code     : '||l_li_info_rec.ins_comp_code);
          hr_utility.trace('ins_company_name          : '||l_li_info_rec.ins_comp_name);
          hr_utility.trace('calc_prem_ff              : '||l_li_info_rec.calc_prem_ff);
          hr_utility.trace('lip_prem_bal              : '||l_li_info_rec.lip_prem_bal);
          hr_utility.trace('lip_prem_mth_ele          : '||l_li_info_rec.lip_prem_mth_ele);
          hr_utility.trace('lip_prem_bon_ele          : '||l_li_info_rec.lip_prem_bon_ele);
          hr_utility.trace('start_date                : '||fnd_date.date_to_canonical(l_li_info_rec.start_date));
          hr_utility.trace('end_date                  : '||fnd_date.date_to_canonical(l_li_info_rec.end_date));
          hr_utility.trace('ins_type                  : '||l_li_info_rec.ins_type);
          hr_utility.trace('ins_period_start_date     : '||fnd_date.date_to_canonical(l_li_info_rec.ins_period_start_date));
          hr_utility.trace('ins_period                : '||l_li_info_rec.ins_period);
          hr_utility.trace('contractor_name           : '||l_li_info_rec.contractor_name);
          hr_utility.trace('beneficiary_name          : '||l_li_info_rec.beneficiary_name);
          hr_utility.trace('beneficiary_relship       : '||l_li_info_rec.beneficiary_relship);
          hr_utility.trace('linc_prem                 : '||fnd_number.number_to_canonical(l_li_info_rec.linc_prem));
        end if;
      --
        l_lip_prem := null;
      --
        if l_li_info_rec.ins_class <> 'PC' then
        --
          calc_li_annual_prem(
            p_ins_info_rec => l_li_info_rec,
            p_lig_prem     => l_lig_prem,
            p_lip_prem     => l_lip_prem,
            p_message      => l_message);
        --
        end if;
      --
        if g_debug then
          hr_utility.set_location(l_proc,110);
          hr_utility.trace('annual_prem : '||l_lip_prem);
        end if;
      --
        pay_jp_isdf_dml_pkg.create_life_pens(
          p_action_information_id       => pay_jp_isdf_dml_pkg.next_action_information_id,
          p_assignment_action_id        => p_assignment_action_id,
          p_action_context_type         => 'AAP',
          p_assignment_id               => p_assignment_id,
          p_effective_date              => g_effective_date,
          p_action_information_category => 'JP_ISDF_LIFE_PENS',
          p_status                      => 'Q',
          p_assignment_extra_info_id    => l_li_info_rec.assignment_extra_info_id,
          p_aei_object_version_number   => l_li_info_rec.aei_object_version_number,
          p_pens_ins_class              => l_li_info_rec.ins_class,
          p_pens_ins_company_code       => l_li_info_rec.ins_comp_code,
          p_ins_company_name            => l_li_info_rec.ins_comp_name,
          p_ins_type                    => l_li_info_rec.ins_type,
          p_ins_period_start_date       => l_li_info_rec.ins_period_start_date,
          p_ins_period                  => l_li_info_rec.ins_period,
          p_contractor_name             => l_li_info_rec.contractor_name,
          p_beneficiary_name            => l_li_info_rec.beneficiary_name,
          p_beneficiary_relship         => l_li_info_rec.beneficiary_relship,
          p_annual_prem                 => l_lip_prem,
          p_object_version_number       => l_object_version_number);
       --
        if g_debug then
          hr_utility.set_location(l_proc,120);
        end if;
      --
      end loop;
      close csr_pens;
    --
      if g_debug then
        hr_utility.trace('end create_life_pens');
        hr_utility.set_location(l_proc,130);
        hr_utility.trace('start create_nonlife');
      end if;
    --
      open csr_nonlife;
      loop
      --
        fetch csr_nonlife into l_ai_info_rec;
        exit when csr_nonlife%notfound;
      --
        if g_debug then
          hr_utility.set_location(l_proc,140);
          hr_utility.trace('assignment_extra_info_id  : '||l_ai_info_rec.assignment_extra_info_id);
          hr_utility.trace('aei_object_version_number : '||l_ai_info_rec.aei_object_version_number);
          hr_utility.trace('info_type                 : '||l_ai_info_rec.info_type);
          hr_utility.trace('nonlife_ins_class         : '||l_ai_info_rec.ins_class);
          hr_utility.trace('nonlife_term_type         : '||l_ai_info_rec.ins_term_type);
          hr_utility.trace('nonlife_ins_company_code  : '||l_ai_info_rec.ins_comp_code);
          hr_utility.trace('ins_company_name          : '||l_ai_info_rec.ins_comp_name);
          hr_utility.trace('calc_prem_ff              : '||l_ai_info_rec.calc_prem_ff);
          hr_utility.trace('eqi_prem_bal              : '||l_ai_info_rec.eqi_prem_bal);
          hr_utility.trace('eqi_prem_mth_ele          : '||l_ai_info_rec.eqi_prem_mth_ele);
          hr_utility.trace('eqi_prem_bon_ele          : '||l_ai_info_rec.eqi_prem_bon_ele);
          hr_utility.trace('ai_prem_bal               : '||l_ai_info_rec.ai_prem_bal);
          hr_utility.trace('ai_prem_mth_ele           : '||l_ai_info_rec.ai_prem_mth_ele);
          hr_utility.trace('ai_prem_bon_ele           : '||l_ai_info_rec.ai_prem_bon_ele);
          hr_utility.trace('start_date                : '||fnd_date.date_to_canonical(l_ai_info_rec.start_date));
          hr_utility.trace('end_date                  : '||fnd_date.date_to_canonical(l_ai_info_rec.end_date));
          hr_utility.trace('ins_type                  : '||l_ai_info_rec.ins_type);
          hr_utility.trace('ins_period                : '||l_ai_info_rec.ins_period);
          hr_utility.trace('contractor_name           : '||l_ai_info_rec.contractor_name);
          hr_utility.trace('beneficiary_name          : '||l_ai_info_rec.beneficiary_name);
          hr_utility.trace('beneficiary_relship       : '||l_ai_info_rec.beneficiary_relship);
          hr_utility.trace('maturity_repayment        : '||l_ai_info_rec.maturity_repayment);
          hr_utility.trace('annual_prem               : '||fnd_number.number_to_canonical(l_ai_info_rec.annual_prem));
        end if;
      --
        l_ai_prem  := null;
        l_eqi_prem := null;
        l_nli_prem := null;
      --
        if l_ai_info_rec.ins_class <> 'PC' then
        --
          calc_ai_annual_prem(
            p_ins_info_rec => l_ai_info_rec,
            p_eqi_prem     => l_eqi_prem,
            p_ai_prem      => l_nli_prem,
            p_message      => l_message);
        --
          if l_ai_info_rec.ins_term_type = 'EQ' then
            l_ai_prem := l_eqi_prem;
          else
            l_ai_prem := l_nli_prem;
          end if;
        --
        end if;
      --
        if g_debug then
          hr_utility.set_location(l_proc,150);
          hr_utility.trace('ai annual_prem  : '||l_ai_prem);
          hr_utility.trace('eqi annual_prem : '||l_eqi_prem);
          hr_utility.trace('nli annual_prem : '||l_nli_prem);
        end if;
      --
        pay_jp_isdf_dml_pkg.create_nonlife(
          p_action_information_id         => pay_jp_isdf_dml_pkg.next_action_information_id,
          p_assignment_action_id          => p_assignment_action_id,
          p_action_context_type           => 'AAP',
          p_assignment_id                 => p_assignment_id,
          p_effective_date                => g_effective_date,
          p_action_information_category   => 'JP_ISDF_NONLIFE',
          p_status                        => 'Q',
          p_assignment_extra_info_id      => l_ai_info_rec.assignment_extra_info_id,
          p_aei_object_version_number     => l_ai_info_rec.aei_object_version_number,
          p_nonlife_ins_class             => l_ai_info_rec.ins_class,
          p_nonlife_ins_term_type         => l_ai_info_rec.ins_term_type,
          p_nonlife_ins_company_code      => l_ai_info_rec.ins_comp_code,
          p_ins_company_name              => l_ai_info_rec.ins_comp_name,
          p_ins_type                      => l_ai_info_rec.ins_type,
          p_ins_period                    => l_ai_info_rec.ins_period,
          p_contractor_name               => l_ai_info_rec.contractor_name,
          p_beneficiary_name              => l_ai_info_rec.beneficiary_name,
          p_beneficiary_relship           => l_ai_info_rec.beneficiary_relship,
          p_maturity_repayment            => l_ai_info_rec.maturity_repayment,
          p_annual_prem                   => l_ai_prem,
          p_object_version_number         => l_object_version_number);
       --
        if g_debug then
          hr_utility.set_location(l_proc,160);
        end if;
      --
      end loop;
      close csr_nonlife;
    --
      if g_debug then
        hr_utility.trace('end create_nonlife');
        hr_utility.set_location(l_proc,170);
        hr_utility.trace('start create_spouse');
      end if;
    --
      l_spouse_rec.spouse_type         := null;
      l_spouse_rec.widow_type          := null;
      l_spouse_rec.spouse_dct_exclude  := null;
      l_spouse_rec.spouse_income_entry := null;
    --
      l_spouse_rec.spouse_income_entry := l_entry_rec.spouse_income;
    --  l_spouse_rec.spouse_income_entry := pay_jp_balance_pkg.get_entry_value_number(c_spouse_iv_id,p_assignment_id,g_effective_date);
    --
      if l_spouse_rec.spouse_income_entry is not null then
      --
        l_spouse_rec.widow_type          := pay_jp_balance_pkg.get_entry_value_char(c_widow_type_iv_id,p_assignment_id,g_effective_date);
        l_spouse_rec.spouse_type         := pay_jp_balance_pkg.get_entry_value_char(c_sp_type_iv_id,p_assignment_id,g_effective_date);
        l_spouse_rec.spouse_dct_exclude  := l_entry_rec.sp_dct_exclude;
      --  l_spouse_rec.spouse_dct_exclude  := pay_jp_balance_pkg.get_entry_value_char(c_sp_dct_exclude_iv_id,p_assignment_id,g_effective_date);
      --
        if l_spouse_rec.spouse_type is null then
        --
          if g_bg_itax_dpnt_ref_type = 'CEI' then
          --
            l_tax_type := pay_jp_balance_pkg.get_entry_value_char(c_tax_type_iv_id,p_assignment_id,g_effective_date);
            l_spouse_rec.spouse_type := per_jp_ctr_utility_pkg.get_itax_spouse_type(p_assignment_id,l_tax_type,g_effective_date);
          --
          end if;
        --
        end if;
      --
        pay_jp_isdf_dml_pkg.create_spouse(
          p_action_information_id       => pay_jp_isdf_dml_pkg.next_action_information_id,
          p_assignment_action_id        => p_assignment_action_id,
          p_action_context_type         => 'AAP',
          p_assignment_id               => p_assignment_id,
          p_effective_date              => g_effective_date,
          p_action_information_category => 'JP_ISDF_SPOUSE',
          p_status                      => 'Q',
          p_full_name_kana              => null,
          --p_last_name_kana            => null,
          --p_first_name_kana           => null,
          p_full_name                   => null,
          --p_last_name                 => null,
          --p_first_name                => null,
          p_postal_code                 => null,
          p_address                     => null,
          p_emp_income                  => null,
          p_spouse_type                 => l_spouse_rec.spouse_type,
          p_widow_type                  => l_spouse_rec.widow_type,
          p_spouse_dct_exclude          => l_spouse_rec.spouse_dct_exclude,
          p_spouse_income_entry         => l_spouse_rec.spouse_income_entry,
          p_object_version_number       => l_object_version_number);
      --
      end if;
    --
      if g_debug then
        hr_utility.trace('end create_spouse');
        hr_utility.set_location(l_proc,180);
      end if;
    --
    -- copy previous archive information to current archive
    -- this function will be useful in case of re-yea
    -- rather than remaking personal (revised) data by ss employee.
    --
    else
    --
      if g_debug then
        hr_utility.set_location(l_proc,190);
        hr_utility.trace('copy pact id : '||g_copy_archive_pact_id);
      end if;
    --
      open csr_copy_assact;
      fetch csr_copy_assact into l_copy_archive_assact_id;
      close csr_copy_assact;
    --
      if g_debug then
        hr_utility.set_location(l_proc,200);
        hr_utility.trace('copy assact id : '||l_copy_archive_assact_id);
      end if;
    --
      if l_copy_archive_assact_id is not null then
      --
        if g_debug then
          hr_utility.set_location(l_proc,210);
          hr_utility.trace('start copy life_gen');
        end if;
      --
        open csr_copy_life_gen;
        loop
        --
          fetch csr_copy_life_gen into l_csr_copy_life_gen;
          exit when csr_copy_life_gen%notfound;
        --
          pay_jp_isdf_dml_pkg.create_life_gen(
            p_action_information_id       => pay_jp_isdf_dml_pkg.next_action_information_id,
            p_assignment_action_id        => p_assignment_action_id,
            p_action_context_type         => 'AAP',
            p_assignment_id               => p_assignment_id,
            p_effective_date              => g_effective_date,
            p_action_information_category => 'JP_ISDF_LIFE_GEN',
            p_status                      => l_csr_copy_life_gen.status,
            p_assignment_extra_info_id    => l_csr_copy_life_gen.assignment_extra_info_id,
            p_aei_object_version_number   => l_csr_copy_life_gen.aei_object_version_number,
            p_gen_ins_class               => l_csr_copy_life_gen.gen_ins_class,
            p_gen_ins_company_code        => l_csr_copy_life_gen.gen_ins_company_code,
            p_ins_company_name            => l_csr_copy_life_gen.ins_company_name,
            p_ins_type                    => l_csr_copy_life_gen.ins_type,
            p_ins_period                  => l_csr_copy_life_gen.ins_period,
            p_contractor_name             => l_csr_copy_life_gen.contractor_name,
            p_beneficiary_name            => l_csr_copy_life_gen.beneficiary_name,
            p_beneficiary_relship         => l_csr_copy_life_gen.beneficiary_relship,
            p_annual_prem                 => l_csr_copy_life_gen.annual_prem,
            p_object_version_number       => l_object_version_number);
        --
        end loop;
        close csr_copy_life_gen;
      --
        if g_debug then
          hr_utility.trace('end copy life_gen');
          hr_utility.set_location(l_proc,220);
          hr_utility.trace('start copy life_pens');
        end if;
      --
        open csr_copy_life_pens;
        loop
        --
          fetch csr_copy_life_pens into l_csr_copy_life_pens;
          exit when csr_copy_life_pens%notfound;
        --
          pay_jp_isdf_dml_pkg.create_life_pens(
            p_action_information_id       => pay_jp_isdf_dml_pkg.next_action_information_id,
            p_assignment_action_id        => p_assignment_action_id,
            p_action_context_type         => 'AAP',
            p_assignment_id               => p_assignment_id,
            p_effective_date              => g_effective_date,
            p_action_information_category => 'JP_ISDF_LIFE_PENS',
            p_status                      => l_csr_copy_life_pens.status,
            p_assignment_extra_info_id    => l_csr_copy_life_pens.assignment_extra_info_id,
            p_aei_object_version_number   => l_csr_copy_life_pens.aei_object_version_number,
            p_pens_ins_class              => l_csr_copy_life_pens.pens_ins_class,
            p_pens_ins_company_code       => l_csr_copy_life_pens.pens_ins_company_code,
            p_ins_company_name            => l_csr_copy_life_pens.ins_company_name,
            p_ins_type                    => l_csr_copy_life_pens.ins_type,
            p_ins_period_start_date       => l_csr_copy_life_pens.ins_period_start_date,
            p_ins_period                  => l_csr_copy_life_pens.ins_period,
            p_contractor_name             => l_csr_copy_life_pens.contractor_name,
            p_beneficiary_name            => l_csr_copy_life_pens.beneficiary_name,
            p_beneficiary_relship         => l_csr_copy_life_pens.beneficiary_relship,
            p_annual_prem                 => l_csr_copy_life_pens.annual_prem,
            p_object_version_number       => l_object_version_number);
        --
        end loop;
        close csr_copy_life_pens;
      --
        if g_debug then
          hr_utility.trace('end copy life_pens');
          hr_utility.set_location(l_proc,230);
          hr_utility.trace('start copy nonlife');
        end if;
      --
        open csr_copy_nonlife;
        loop
        --
          fetch csr_copy_nonlife into l_csr_copy_nonlife;
          exit when csr_copy_nonlife%notfound;
        --
          pay_jp_isdf_dml_pkg.create_nonlife(
            p_action_information_id       => pay_jp_isdf_dml_pkg.next_action_information_id,
            p_assignment_action_id        => p_assignment_action_id,
            p_action_context_type         => 'AAP',
            p_assignment_id               => p_assignment_id,
            p_effective_date              => g_effective_date,
            p_action_information_category => 'JP_ISDF_NONLIFE',
            p_status                      => l_csr_copy_nonlife.status,
            p_assignment_extra_info_id    => l_csr_copy_nonlife.assignment_extra_info_id,
            p_aei_object_version_number   => l_csr_copy_nonlife.aei_object_version_number,
            p_nonlife_ins_class           => l_csr_copy_nonlife.nonlife_ins_class,
            p_nonlife_ins_term_type       => l_csr_copy_nonlife.nonlife_ins_term_type,
            p_nonlife_ins_company_code    => l_csr_copy_nonlife.nonlife_ins_company_code,
            p_ins_company_name            => l_csr_copy_nonlife.ins_company_name,
            p_ins_type                    => l_csr_copy_nonlife.ins_type,
            p_ins_period                  => l_csr_copy_nonlife.ins_period,
            p_contractor_name             => l_csr_copy_nonlife.contractor_name,
            p_beneficiary_name            => l_csr_copy_nonlife.beneficiary_name,
            p_beneficiary_relship         => l_csr_copy_nonlife.beneficiary_relship,
            p_maturity_repayment          => l_csr_copy_nonlife.maturity_repayment,
            p_annual_prem                 => l_csr_copy_nonlife.annual_prem,
            p_object_version_number       => l_object_version_number);
        --
        end loop;
        close csr_copy_nonlife;
      --
        if g_debug then
          hr_utility.trace('end copy nonlife');
          hr_utility.set_location(l_proc,240);
          hr_utility.trace('start copy social');
        end if;
      --
        open csr_copy_social;
        loop
        --
          fetch csr_copy_social into l_csr_copy_social;
          exit when csr_copy_social%notfound;
        --
          pay_jp_isdf_dml_pkg.create_social(
            p_action_information_id       => pay_jp_isdf_dml_pkg.next_action_information_id,
            p_assignment_action_id        => p_assignment_action_id,
            p_action_context_type         => 'AAP',
            p_assignment_id               => p_assignment_id,
            p_effective_date              => g_effective_date,
            p_action_information_category => 'JP_ISDF_SOCIAL',
            p_status                      => l_csr_copy_social.status,
            p_ins_type                    => l_csr_copy_social.ins_type,
            p_ins_payee_name              => l_csr_copy_social.ins_payee_name,
            p_debtor_name                 => l_csr_copy_social.debtor_name,
            p_beneficiary_relship         => l_csr_copy_social.beneficiary_relship,
            p_annual_prem                 => l_csr_copy_social.annual_prem,
            p_national_pens_flag          => l_csr_copy_social.national_pens_flag,
            p_object_version_number       => l_object_version_number);
        --
        end loop;
        close csr_copy_social;
      --
        if g_debug then
          hr_utility.trace('end copy social');
          hr_utility.set_location(l_proc,250);
          hr_utility.trace('start copy mutual_aid');
        end if;
      --
        open csr_copy_mutual_aid;
        loop
        --
          fetch csr_copy_mutual_aid into l_csr_copy_mutual_aid;
          exit when csr_copy_mutual_aid%notfound;
        --
          pay_jp_isdf_dml_pkg.create_mutual_aid(
            p_action_information_id       => pay_jp_isdf_dml_pkg.next_action_information_id,
            p_assignment_action_id        => p_assignment_action_id,
            p_action_context_type         => 'AAP',
            p_assignment_id               => p_assignment_id,
            p_effective_date              => g_effective_date,
            p_action_information_category => 'JP_ISDF_MUTUAL_AID',
            p_status                      => l_csr_copy_mutual_aid.status,
            p_enterprise_contract_prem    => l_csr_copy_mutual_aid.enterprise_contract_prem,
            p_pension_prem                => l_csr_copy_mutual_aid.pension_prem,
            p_disable_sup_contract_prem   => l_csr_copy_mutual_aid.disable_sup_contract_prem,
            p_object_version_number       => l_object_version_number);
        --
        end loop;
        close csr_copy_mutual_aid;
      --
        if g_debug then
          hr_utility.trace('end copy mutual_aid');
          hr_utility.set_location(l_proc,260);
          hr_utility.trace('start copy spouse');
        end if;
      --
        open csr_copy_spouse;
        loop
        --
          fetch csr_copy_spouse into l_csr_copy_spouse;
          exit when csr_copy_spouse%notfound;
        --
          pay_jp_isdf_dml_pkg.create_spouse(
            p_action_information_id       => pay_jp_isdf_dml_pkg.next_action_information_id,
            p_assignment_action_id        => p_assignment_action_id,
            p_action_context_type         => 'AAP',
            p_assignment_id               => p_assignment_id,
            p_effective_date              => g_effective_date,
            p_action_information_category => 'JP_ISDF_SPOUSE',
            p_status                      => l_csr_copy_spouse.status,
            p_full_name_kana              => l_csr_copy_spouse.full_name_kana,
            p_full_name                   => l_csr_copy_spouse.full_name,
            p_postal_code                 => l_csr_copy_spouse.postal_code,
            p_address                     => l_csr_copy_spouse.address,
            p_emp_income                  => l_csr_copy_spouse.emp_income,
            p_spouse_type                 => l_csr_copy_spouse.spouse_type,
            p_widow_type                  => l_csr_copy_spouse.widow_type,
            p_spouse_dct_exclude          => l_csr_copy_spouse.spouse_dct_exclude,
            p_spouse_income_entry         => l_csr_copy_spouse.spouse_income_entry,
            p_object_version_number       => l_object_version_number);
        --
        end loop;
        close csr_copy_spouse;
      --
        if g_debug then
          hr_utility.trace('end copy spouse');
          hr_utility.set_location(l_proc,270);
          hr_utility.trace('start copy spouse_inc');
        end if;
      --
        open csr_copy_spouse_inc;
        loop
        --
          fetch csr_copy_spouse_inc into l_csr_copy_spouse_inc;
          exit when csr_copy_spouse_inc%notfound;
        --
          pay_jp_isdf_dml_pkg.create_spouse_inc(
            p_action_information_id       => pay_jp_isdf_dml_pkg.next_action_information_id,
            p_assignment_action_id        => p_assignment_action_id,
            p_action_context_type         => 'AAP',
            p_assignment_id               => p_assignment_id,
            p_effective_date              => g_effective_date,
            p_action_information_category => 'JP_ISDF_SPOUSE_INC',
            p_status                      => l_csr_copy_spouse_inc.status,
            p_sp_earned_income            => l_csr_copy_spouse_inc.sp_earned_income,
            p_sp_earned_income_exp        => l_csr_copy_spouse_inc.sp_earned_income_exp,
            p_sp_business_income          => l_csr_copy_spouse_inc.sp_business_income,
            p_sp_business_income_exp      => l_csr_copy_spouse_inc.sp_business_income_exp,
            p_sp_miscellaneous_income     => l_csr_copy_spouse_inc.sp_miscellaneous_income,
            p_sp_miscellaneous_income_exp => l_csr_copy_spouse_inc.sp_miscellaneous_income_exp,
            p_sp_dividend_income          => l_csr_copy_spouse_inc.sp_dividend_income,
            p_sp_dividend_income_exp      => l_csr_copy_spouse_inc.sp_dividend_income_exp,
            p_sp_real_estate_income       => l_csr_copy_spouse_inc.sp_real_estate_income,
            p_sp_real_estate_income_exp   => l_csr_copy_spouse_inc.sp_real_estate_income_exp,
            p_sp_retirement_income        => l_csr_copy_spouse_inc.sp_retirement_income,
            p_sp_retirement_income_exp    => l_csr_copy_spouse_inc.sp_retirement_income_exp,
            p_sp_other_income             => l_csr_copy_spouse_inc.sp_other_income,
            p_sp_other_income_exp         => l_csr_copy_spouse_inc.sp_other_income_exp,
            p_sp_other_income_exp_dct     => l_csr_copy_spouse_inc.sp_other_income_exp_dct,
            p_sp_other_income_exp_temp    => l_csr_copy_spouse_inc.sp_other_income_exp_temp,
            p_sp_other_income_exp_temp_exp=> l_csr_copy_spouse_inc.sp_other_income_exp_temp_exp,
            p_object_version_number       => l_object_version_number);
        --
        end loop;
        close csr_copy_spouse_inc;
      --
        if g_debug then
          hr_utility.trace('end copy spouse_inc');
          hr_utility.set_location(l_proc,280);
        end if;
      --
      end if;
    --
      if g_debug then
        hr_utility.set_location(l_proc,290);
      end if;
    --
    end if;
  --
    if g_debug then
      hr_utility.set_location(l_proc,300);
    end if;
  --
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
end archive_assact;
--
-- -------------------------------------------------------------------------
-- post_assact
-- -------------------------------------------------------------------------
procedure post_assact(
  p_action_information_id in number,
  p_object_version_number in out nocopy number)
is
--
  l_proc varchar2(80) := c_package||'post_assact';
--
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  if g_archive_default_flag = 'Y' then
  --
    if g_debug then
      hr_utility.set_location(l_proc,10);
      hr_utility.trace('action_information_id : '||p_action_information_id);
      hr_utility.trace('object_version_number : '||p_object_version_number);
    end if;
  --
  -- include lock assact (only transaction,ovn will be changed, others same as new condition)
    pay_jp_isdf_dml_pkg.update_assact(
      p_action_information_id => p_action_information_id,
      p_object_version_number => p_object_version_number,
      p_transaction_status    => 'N',
      p_finalized_date        => null,
      p_finalized_by          => null,
      p_user_comments         => null,
      p_admin_comments        => null,
      p_transfer_status       => 'U',
      p_transfer_date         => null,
      p_expiry_date           => null);
  --
    if g_debug then
      hr_utility.set_location(l_proc,20);
    end if;
  --
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
end post_assact;
--
-- -------------------------------------------------------------------------
-- archive_data
-- -------------------------------------------------------------------------
procedure archive_data(
  p_assignment_action_id in number,
  p_effective_date       in date)
is
--
  l_proc varchar2(80) := c_package||'archive_data';
--
  l_assignment_id number;
  l_tax_type pay_element_entry_values_f.screen_entry_value%type;
--
  l_action_information_id number;
  l_object_version_number number;
--
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  select assignment_id
  into   l_assignment_id
  from   pay_assignment_actions
  where  assignment_action_id = p_assignment_action_id;
--
  if g_debug then
    hr_utility.set_location(l_proc,10);
  end if;
--
-- set context.
  pay_balance_pkg.set_context('DATE_EARNED',fnd_date.date_to_canonical(p_effective_date));
  pay_balance_pkg.set_context('ASSIGNMENT_ID',fnd_number.number_to_canonical(l_assignment_id));
  l_tax_type := pay_balance_pkg.run_db_item(c_tax_type_iv_name,g_business_group_id,g_legislation_code);
--
  if g_debug then
    hr_utility.set_location(l_proc,20);
    hr_utility.trace('date_earned   : '||fnd_date.date_to_canonical(p_effective_date));
    hr_utility.trace('assignment_id : '||l_assignment_id);
    hr_utility.trace('tax_type      : '||l_tax_type);
  end if;
--
  if l_tax_type not in ('M_KOU','D_KOU') then
  --
    fnd_message.set_name('PAY','PAY_JP_INVALID_TAX_TYPE');
    fnd_message.raise_error;
  --
  else
  --
    if g_debug then
      hr_utility.set_location(l_proc,30);
      hr_utility.trace('start create_assact');
    end if;
  --
    l_action_information_id := pay_jp_isdf_dml_pkg.next_action_information_id;
  --
    pay_jp_isdf_dml_pkg.create_assact(
      p_action_information_id       => l_action_information_id,
      p_assignment_action_id        => p_assignment_action_id,
      p_action_context_type         => 'AAP',
      p_assignment_id               => l_assignment_id,
      p_effective_date              => p_effective_date,
      p_action_information_category => 'JP_ISDF_ASSACT',
      p_tax_type                    => l_tax_type,
      p_transaction_status          => 'U',
      p_finalized_date              => null,
      p_finalized_by                => null,
      p_user_comments               => null,
      p_admin_comments              => null,
      p_transfer_status             => 'U',
      p_transfer_date               => null,
      p_expiry_date                 => null,
      p_object_version_number       => l_object_version_number);
  --
    if g_debug then
      hr_utility.trace('end create_assact');
      hr_utility.set_location(l_proc,40);
    end if;
  --
    init_assact(
      p_assignment_action_id => p_assignment_action_id,
      p_assignment_id        => l_assignment_id);
  --
    if g_debug then
      hr_utility.set_location(l_proc,50);
    end if;
  --
    archive_assact(
      p_assignment_action_id => p_assignment_action_id,
      p_assignment_id        => l_assignment_id);
  --
    if g_debug then
      hr_utility.set_location(l_proc,60);
      hr_utility.trace('assignment_action_id  : '||p_assignment_action_id);
      hr_utility.trace('action_information_id : '||l_action_information_id);
      hr_utility.trace('object_version_number : '||l_object_version_number);
    end if;
  --
  -- update transaction status from U to N because archive has been made.
    post_assact(
      p_action_information_id => l_action_information_id,
      p_object_version_number => l_object_version_number);
  --
    if g_debug then
      hr_utility.set_location(l_proc,70);
    end if;
  --
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
end archive_data;
--
-- -------------------------------------------------------------------------
-- deinitialize_code
-- -------------------------------------------------------------------------
procedure deinitialize_code(
  p_payroll_action_id in number)
is
--
  l_proc varchar2(80) := c_package||'deinitialize_code';
--
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  -- invoke in case of mark for retry.
  init_pact(p_payroll_action_id);
--
  if g_debug then
    hr_utility.set_location(l_proc,10);
  end if;
--
  archive_pact(p_payroll_action_id);
--
  if g_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
end deinitialize_code;
--
end pay_jp_isdf_archive_pkg;

/
