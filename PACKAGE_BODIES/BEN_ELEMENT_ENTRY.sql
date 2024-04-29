--------------------------------------------------------
--  DDL for Package Body BEN_ELEMENT_ENTRY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ELEMENT_ENTRY" as
/* $Header: benelmen.pkb 120.33.12010000.21 2009/12/21 06:49:15 krupani ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
-- Package Variables
--
g_debug boolean := hr_utility.debug_enabled;
g_package  varchar2(33) := '  ben_element_entry.';  -- Global package name
g_skip_element varchar2(30);
--
g_hash_jump number     := ben_hash_utility.get_hash_jump;
--
g_msg_displayed number :=0; --2530582
g_acty_base_rt_name ben_acty_base_rt_f.name%type := null;
--

type g_get_link_row is record
  (assignment_id          number
  ,element_type_id        number
  ,session_date           date
  ,element_link_id        number
  );
--
type g_get_link_tbl is table of g_get_link_row
  index by binary_integer;
--
type abr_asg_rec is record
(person_id            number,
 assignment_id        number,
 payroll_id           number,
 organization_id      number,
 asmt_to_use_cd       varchar2(30),
 effective_start_date date,
 effective_end_date   date);

type per_pay_rec is record
(assignment_id        number,
 end_date             date,
 payroll_was_ever_run boolean);

g_ext_inpval_tab  ext_inpval_tab_typ;
g_outputs         ff_exec.outputs_t;
g_get_link_cache  g_get_link_tbl;
g_get_link_cached pls_integer := 0;
g_param_rec       benutils.g_batch_param_rec;
g_abr_asg_rec     abr_asg_rec;
g_per_pay_rec     per_pay_rec;
g_max_end_date    date := null;
  --
  -- Package cursors
  --
  cursor c_plan_year_end_for_pen
    (c_prtt_enrt_rslt_id    in     number
    ,c_rate_start_or_end_dt in     date
    ,c_effective_date       in     date
    )
  is
    select distinct
           yp.start_date,yp.end_date
    from   ben_prtt_enrt_rslt_f pen,
           ben_popl_yr_perd pyp,
           ben_yr_perd yp
    where  pen.prtt_enrt_rslt_id = c_prtt_enrt_rslt_id
    and    pen.prtt_enrt_rslt_stat_cd is null
    and    c_effective_date <= pen.effective_end_date
    and    pyp.pl_id=pen.pl_id
    and    yp.yr_perd_id=pyp.yr_perd_id
    and    c_rate_start_or_end_dt
      between yp.start_date and yp.end_date;
  --
  cursor c_plan_year_end_for_pl
    (c_pl_id                in     number
    ,c_rate_start_or_end_dt in     date
    )
  is
    select distinct
           yp.start_date,yp.end_date
    from   ben_popl_yr_perd pyp,
           ben_yr_perd yp
    where  pyp.pl_id=c_pl_id
    and    yp.yr_perd_id=pyp.yr_perd_id
    and    c_rate_start_or_end_dt
      between yp.start_date and yp.end_date;
  --
  -- current result info
  --
  cursor c_current_result_info
    (c_prtt_enrt_rslt_id  in     number
    )
  is
    select pen.prtt_enrt_rslt_id,
           pen.pl_id,
           opt.opt_id,
           pen.pgm_id,
           pen.ler_id,
           pen.pl_typ_id,
           pen.person_id,
           pen.effective_start_date,
           pen.effective_end_date,
	   pen.uom
    from   ben_prtt_enrt_rslt_f pen,
           ben_oipl_f opt
    where  pen.prtt_enrt_rslt_id = c_prtt_enrt_rslt_id
    and    pen.prtt_enrt_rslt_stat_cd is null
    and    opt.oipl_id(+)=pen.oipl_id
    and    pen.enrt_cvg_strt_dt between opt.effective_start_date(+)
    and    opt.effective_end_date(+)
    order by pen.effective_start_date desc;
  --
  g_result_rec c_current_result_info%rowtype;
  --
  -- prtt rt info
  --
  cursor c_get_prtt_rt_val
    (c_prtt_rt_val_id in number
    )
  is
    select prv.prtt_rt_val_id,
           prv.acty_base_rt_id,
           prv.prtt_enrt_rslt_id,
           prv.rt_strt_dt,
           prv.rt_end_dt,
           prv.business_group_id,
           prv.mlt_cd,
           prv.acty_ref_perd_cd,
           prv.rt_val,
           prv.cmcd_rt_val,
           prv.ann_rt_val,
           prv.per_in_ler_id,
           prv.element_entry_value_id,
           prv.prtt_reimbmt_rqst_id,
           prv.object_version_number
    from   ben_prtt_rt_val prv
    where  prtt_rt_val_id = c_prtt_rt_val_id;
  --
  l_prv_rec c_get_prtt_rt_val%ROWTYPE;
  --
  -- -------------------------------------------------------------
  -- This cursor determines if any payroll actions exist because
  -- of running payroll. Action type 'X' corresponds to payroll
  -- actions that are not a result of payroll run. This is a
  -- precursor to get_max_end_dt()
  -- -------------------------------------------------------------
  --
  cursor c_payroll_was_ever_run
    (c_assignment_id in number
    )
  is
    select 'Y'
    from pay_assignment_actions d,
         pay_payroll_actions e
   where d.assignment_id = c_assignment_id
     and d.payroll_action_id = e.payroll_action_id
     and e.action_type <> 'X';
--
-- This func replaces the cursor c_get_end_dt
--
-- ----------------------------------------------------------------------------
-- |-----------------------< get_max_end_dt  >----------------------------|
-- ----------------------------------------------------------------------------
--
function get_max_end_dt (
  p_assignment_id         number,
  p_payroll_id            number,
  p_element_type_id       number,
  p_effective_date        date)
return date is
--
  cursor c_asgact
    (c_assignment_id     in number
    ,c_payroll_id        in number
    ) is
 select d.assignment_action_id,
        g.end_date
   from pay_assignment_actions d,
        pay_payroll_actions e,
        per_time_periods g
  where d.assignment_id = c_assignment_id
    and g.payroll_id = c_payroll_id
    and g.payroll_id = e.payroll_id
    and d.payroll_action_id = e.payroll_action_id
    and e.action_type in ('R','Q')
    and e.time_period_id = g.time_period_id
    and e.date_earned between g.start_date and g.end_date
 order by g.end_date desc;

  cursor c_chk_pac
    (c_assignment_action_id   in number
    ,c_element_type_id        in number
    ) is
    select 'x'
      from pay_run_results h
     where h.element_type_id = c_element_type_id
       and h.assignment_action_id = c_assignment_action_id
       and h.status in ('P', 'PA')
       and h.source_type = 'E';

l_proc                     varchar2(72)  := g_package||'get_max_end_dt';
l_v2dummy                  varchar2(30);
l_assignment_action_id     number;
l_end_date                 date;
l_max_end_date             date;

begin
--
if g_debug then
  hr_utility.set_location('Entering: '||l_proc,5);
end if;
--
open c_asgact(p_assignment_id,
              p_payroll_id);
loop
   --
   fetch c_asgact into l_assignment_action_id,
                       l_end_date;
   if c_asgact%notfound then
      exit;
   end if;
   --
   open c_chk_pac(l_assignment_action_id,
                  p_element_type_id);
   fetch c_chk_pac into l_v2dummy;
   --
   if c_chk_pac%found then
      l_max_end_date := l_end_date;
      close c_chk_pac;
      exit;
   end if;
   --
   close c_chk_pac;
   --
end loop;
close c_asgact;
--
if g_debug then
  hr_utility.set_location('Leaving: '||l_proc,5);
end if;
--
return l_max_end_date;
--
end get_max_end_dt;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_ele_processed  >----------------------------|
-- ----------------------------------------------------------------------------
-- Returns 'Y' if the element entry has already been processed in a payroll
-- run.
--
function chk_ele_processed (
  p_element_entry_id      number,
  p_original_entry_id     number,
  p_processing_type       varchar2,
  p_entry_type            varchar2,
  p_business_group_id     number,
  p_effective_date        date)
return varchar2 is
--
--
-- Define how to determine if the entry is processed
--
cursor nonrecurring_entries (adjust_ee_source in varchar2) is
select  'Y'
  from  pay_run_results       prr,
        pay_element_entries_f pee
 where  pee.element_entry_id = p_element_entry_id
   and  p_effective_date between pee.effective_start_date
   and  pee.effective_end_date
   and  prr.source_id   = decode(pee.entry_type,
                                 'A', decode (adjust_ee_source,
                                              'T', pee.target_entry_id,
                                              pee.element_entry_id),
                                 'R', decode (adjust_ee_source,
                                              'T', pee.target_entry_id,
                                              pee.element_entry_id),
                                 pee.element_entry_id)
   and  prr.entry_type  = pee.entry_type
   and  prr.source_type = 'E'
   and  prr.status <> 'U'
   and  not exists
            (select 1
               from pay_run_results sub_rr
              where sub_rr.source_id = prr.run_result_id
                and sub_rr.source_type in ('R', 'V')) ;
--
-- Bug 522510, recurring entries are considered as processed in the Date Earned
-- period, not Date Paid period - where run results exists.
--

cursor recurring_entries is
select  'Y'
  from  pay_run_results         result,
        pay_assignment_actions  asgt_action,
        pay_payroll_actions     pay_action,
        per_time_periods        period
 where  result.source_id = nvl (p_original_entry_id, p_element_entry_id)
   and  result.status <> 'U'
   and  result.source_type = 'E'
   and  result.assignment_action_id     = asgt_action.assignment_action_id
   and  asgt_action.payroll_action_id   = pay_action.payroll_action_id
   and  pay_action.payroll_id = period.payroll_id
   and  pay_action.date_earned between period.start_date
   and  period.end_date
   and  not exists
        (select 1
           from pay_run_results rev_result
          where rev_result.source_id = result.run_result_id
            and rev_result.source_type in ('R', 'V'));
--
l_proc             varchar2(72)  := g_package||'chk_ele_processed';
l_processed        varchar2(1) := 'N';
l_adjust_ee_source varchar2(1);

begin
--
if g_debug then
  hr_utility.set_location('Entering: '||l_proc,5);
end if;
--
if (p_entry_type in ('S','D','A','R') or p_processing_type = 'N') then
  --
  begin
    --
    select plr.rule_mode
    into  l_adjust_ee_source
    from  pay_legislation_rules plr
    ,     per_business_groups_perf pbgf
    where plr.rule_type          = 'ADJUSTMENT_EE_SOURCE'
    and   pbgf.legislation_code  = plr.legislation_code
    and   pbgf.business_group_id = p_business_group_id;
     --
   exception
       when no_data_found then
          l_adjust_ee_source := 'A';
  end;
  --
  open nonrecurring_entries(l_adjust_ee_source);
  fetch nonrecurring_entries into l_processed;
  close nonrecurring_entries;
  --
else
  --
  open recurring_entries;
  fetch recurring_entries into l_processed;
  close recurring_entries;
  --
end if;
--
if g_debug then
  hr_utility.set_location('Leaving: '||l_proc,5);
end if;
--
return l_processed;
--
end chk_ele_processed;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< clear_ext_inpval_tab>----------------------------|
-- ----------------------------------------------------------------------------
--
procedure clear_ext_inpval_tab is
  l_proc    varchar2(72) ;
begin
  if g_debug then
  l_proc     := g_package||'clear_ext_inpval_tab';
    hr_utility.set_location('Entering: '||l_proc,5);
  end if;
  --
  -- Clear the pl/sql extra inputs cache
  --
  g_ext_inpval_tab.delete;

  -- Reset g_ext_inpval_tab to null
  for i in 1..14 loop
      g_ext_inpval_tab(i).extra_input_value_id := null;
      g_ext_inpval_tab(i).upd_when_ele_ended_cd := null;
      g_ext_inpval_tab(i).input_value_id := null;
      g_ext_inpval_tab(i).return_var_name := null;
      g_ext_inpval_tab(i).return_value := null;
  end loop;
  --
  if g_debug then
    hr_utility.set_location('Leaving: '||l_proc,5);
  end if;
end clear_ext_inpval_tab;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< get_extra_ele_inputs>----------------------------|
-- ----------------------------------------------------------------------------
--
procedure get_extra_ele_inputs
  (
   p_effective_date        in  date
  ,p_person_id             in  number
  ,p_business_group_id     in  number
  ,p_assignment_id         in  number
  ,p_element_link_id       in  number
  ,p_entry_type            in  varchar2
  ,p_input_value_id1       in  number
  ,p_entry_value1          in  varchar2
  ,p_element_entry_id      in  number
  ,p_acty_base_rt_id       in  number
  ,p_input_va_calc_rl      in  number
  ,p_abs_ler               in  boolean
  ,p_organization_id       in  number
  ,p_payroll_id            in  number
  ,p_pgm_id                in  number
  ,p_pl_id                 in  number
  ,p_pl_typ_id             in  number
  ,p_opt_id                in  number
  ,p_ler_id                in  number
  ,p_dml_typ               in  varchar2
  ,p_jurisdiction_code     in  varchar2
  ,p_ext_inpval_tab        out nocopy ext_inpval_tab_typ
  ,p_subpriority           out nocopy number
  ) is

  cursor c_ext_inpval
  is
    select eiv.extra_input_value_id,
           eiv.input_value_id,
           eiv.acty_base_rt_id,
           eiv.input_text,
           eiv.return_var_name,
           eiv.upd_when_ele_ended_cd
    from   ben_extra_input_values  eiv,
           pay_input_values_f piv
    where  eiv.acty_base_rt_id = p_acty_base_rt_id
      and  eiv.business_group_id = p_business_group_id
      and  piv.input_value_id = eiv.input_value_id
      and  p_effective_date between piv.effective_start_date
      and  piv.effective_end_date
    order by piv.display_sequence;
  --
  l_ext_inpval_rec c_ext_inpval%rowtype;
  --
  cursor c_abs_att is
   select
       aba.*, pil.per_in_ler_id
   from per_absence_attendances aba,
        ben_per_in_ler pil,
        ben_ler_f ler
   where aba.person_id = p_person_id
     and pil.person_id = p_person_id
     and aba.absence_attendance_id = pil.trgr_table_pk_id
     and pil.ler_id = ler.ler_id
     and ler.typ_cd = 'ABS'
     and pil.per_in_ler_stat_cd = 'STRTD'
     and p_effective_date between
           ler.effective_start_date and ler.effective_end_date;
  --
  cursor c_inp_name is
  select upper(replace(name,' ','_'))
    from pay_input_values_f
   where input_value_id = p_input_value_id1
     and p_effective_date between
           effective_start_date and effective_end_date;

  l_per_abs_att_rec         c_abs_att%rowtype;
  --
  l_param_tab               ff_exec.outputs_t;
  l_ext_inpval_tab          ext_inpval_tab_typ;
  l_counter                 number;
  l_inp_name                pay_input_values_f.name%type;
  l_proc                    varchar2(72) := g_package||' get_extra_ele_inputs';

procedure populate_param_tab
(p_name in varchar2,
 p_value in varchar2) is
  l_next_index number;
begin

  l_next_index := nvl(l_param_tab.count,0) + 1;
  l_param_tab(l_next_index).name := p_name;
  l_param_tab(l_next_index).value := p_value;

end;

begin
  if g_debug then
    hr_utility.set_location('Entering: '||l_proc,5);
    hr_utility.set_location('p_input_va_calc_rl : '||p_input_va_calc_rl ,5);
  end if;

  clear_ext_inpval_tab;

  if p_input_va_calc_rl is null
  then
     if p_input_value_id1 is not null and
        p_abs_ler then

        open c_inp_name;
        fetch c_inp_name into l_inp_name;
        close c_inp_name;

        g_outputs(nvl(g_outputs.count,0)+1).name :=
                                          nvl(l_inp_name,'LENGTH_OF_SERVICE');
        g_outputs(g_outputs.count).value := p_entry_value1;
     end if;
     if g_debug then
       hr_utility.set_location('Extra Input value RL not defined.Leaving ..',5);
     end if;
     return;
  else
    --
    --
    open c_abs_att;
    fetch c_abs_att into l_per_abs_att_rec;
    close c_abs_att;
    --
    -- Evaluate the formula and store the returned values into a pl/sql structure.
    --
    if g_debug then
      hr_utility.set_location('Before formula executing : ',5);
      hr_utility.set_location('Eff Date '||to_char(p_effective_date,'dd-mon-rrrr'),20);
    end if;

    populate_param_tab('BEN_ABS_IV_ABSENCE_ATTENDANCE_ID',
    to_char(l_per_abs_att_rec.ABSENCE_ATTENDANCE_ID));
    populate_param_tab('BEN_ABS_IV_PERSON_ID',to_char(l_per_abs_att_rec.PERSON_ID));
    populate_param_tab('BEN_ABS_IV_DATE_START', to_char(l_per_abs_att_rec.DATE_START, 'YYYY/MM/DD HH24:MI:SS'));
    populate_param_tab('BEN_ABS_IV_DATE_END', to_char(l_per_abs_att_rec.DATE_END, 'YYYY/MM/DD HH24:MI:SS'));
    populate_param_tab('BEN_ABS_IV_ABSENCE_ATTENDANCE_TYPE_ID',
    to_char(l_per_abs_att_rec.ABSENCE_ATTENDANCE_TYPE_ID));
    populate_param_tab('BEN_ABS_IV_ABS_ATTENDANCE_REASON_ID',
    to_char(l_per_abs_att_rec.ABS_ATTENDANCE_REASON_ID));
    populate_param_tab('BEN_ABS_IV_SICKNESS_START_DATE',
    to_char(l_per_abs_att_rec.SICKNESS_START_DATE, 'YYYY/MM/DD HH24:MI:SS'));
    populate_param_tab('BEN_ABS_IV_SICKNESS_END_DATE',
    to_char(l_per_abs_att_rec.SICKNESS_END_DATE, 'YYYY/MM/DD HH24:MI:SS'));
    populate_param_tab('BEN_ABS_IV_ABSENCE_DAYS', to_char(l_per_abs_att_rec.ABSENCE_DAYS));
    populate_param_tab('BEN_ABS_IV_ABSENCE_HOURS', to_char(l_per_abs_att_rec.ABSENCE_HOURS));
    populate_param_tab('BEN_ABS_IV_DATE_NOTIFICATION',
    to_char(l_per_abs_att_rec.DATE_NOTIFICATION, 'YYYY/MM/DD HH24:MI:SS'));
    populate_param_tab('BEN_ABS_IV_DATE_PROJECTED_END',
    to_char(l_per_abs_att_rec.DATE_PROJECTED_END, 'YYYY/MM/DD HH24:MI:SS'));
    populate_param_tab('BEN_ABS_IV_DATE_PROJECTED_START',
    to_char(l_per_abs_att_rec.DATE_PROJECTED_START, 'YYYY/MM/DD HH24:MI:SS'));
    populate_param_tab('BEN_ABS_IV_TIME_END', l_per_abs_att_rec.TIME_END);
    populate_param_tab('BEN_ABS_IV_TIME_PROJECTED_END', l_per_abs_att_rec.TIME_PROJECTED_END);
    populate_param_tab('BEN_ABS_IV_TIME_PROJECTED_START', l_per_abs_att_rec.TIME_PROJECTED_START);
    populate_param_tab('BEN_PIL_IV_PER_IN_LER_ID', to_char(l_per_abs_att_rec.PER_IN_LER_ID));
    populate_param_tab('BEN_ABS_IV_SSP1_ISSUED', l_per_abs_att_rec.SSP1_ISSUED);
    populate_param_tab('BEN_ABS_IV_LINKED_ABSENCE_ID',
    to_char(l_per_abs_att_rec.LINKED_ABSENCE_ID));
    populate_param_tab('BEN_ABS_IV_PREGNANCY_RELATED_ILLNESS',
    l_per_abs_att_rec.PREGNANCY_RELATED_ILLNESS);
    populate_param_tab('BEN_ABS_IV_MATERNITY_ID',to_char(l_per_abs_att_rec.MATERNITY_ID));
    populate_param_tab('BEN_ABS_IV_ABS_INFORMATION_CATEGORY', l_per_abs_att_rec.abs_information_category);
    populate_param_tab('BEN_ABS_IV_ABS_INFORMATION1', l_per_abs_att_rec.abs_information1);
    populate_param_tab('BEN_ABS_IV_ABS_INFORMATION2', l_per_abs_att_rec.abs_information2);
    populate_param_tab('BEN_ABS_IV_ABS_INFORMATION3', l_per_abs_att_rec.abs_information3);
    populate_param_tab('BEN_ABS_IV_ABS_INFORMATION4', l_per_abs_att_rec.abs_information4);
    populate_param_tab('BEN_ABS_IV_ABS_INFORMATION5', l_per_abs_att_rec.abs_information5);
    populate_param_tab('BEN_ABS_IV_ABS_INFORMATION6', l_per_abs_att_rec.abs_information6);
    populate_param_tab('BEN_ABS_IV_ABS_INFORMATION7', l_per_abs_att_rec.abs_information7);
    populate_param_tab('BEN_ABS_IV_ABS_INFORMATION8', l_per_abs_att_rec.abs_information8);
    populate_param_tab('BEN_ABS_IV_ABS_INFORMATION9', l_per_abs_att_rec.abs_information9);
    populate_param_tab('BEN_ABS_IV_ABS_INFORMATION10', l_per_abs_att_rec.abs_information10);
    populate_param_tab('BEN_ABS_IV_ABS_INFORMATION11', l_per_abs_att_rec.abs_information11);
    populate_param_tab('BEN_ABS_IV_ABS_INFORMATION12', l_per_abs_att_rec.abs_information12);
    populate_param_tab('BEN_ABS_IV_ABS_INFORMATION13', l_per_abs_att_rec.abs_information13);
    populate_param_tab('BEN_ABS_IV_ABS_INFORMATION14', l_per_abs_att_rec.abs_information14);
    populate_param_tab('BEN_ABS_IV_ABS_INFORMATION15', l_per_abs_att_rec.abs_information15);
    populate_param_tab('BEN_ABS_IV_ABS_INFORMATION16', l_per_abs_att_rec.abs_information16);
    populate_param_tab('BEN_ABS_IV_ABS_INFORMATION17', l_per_abs_att_rec.abs_information17);
    populate_param_tab('BEN_ABS_IV_ABS_INFORMATION18', l_per_abs_att_rec.abs_information18);
    populate_param_tab('BEN_ABS_IV_ABS_INFORMATION19', l_per_abs_att_rec.abs_information19);
    populate_param_tab('BEN_ABS_IV_ABS_INFORMATION20', l_per_abs_att_rec.abs_information20);
    populate_param_tab('BEN_ABS_IV_ABS_INFORMATION21', l_per_abs_att_rec.abs_information21);
    populate_param_tab('BEN_ABS_IV_ABS_INFORMATION22', l_per_abs_att_rec.abs_information22);
    populate_param_tab('BEN_ABS_IV_ABS_INFORMATION23', l_per_abs_att_rec.abs_information23);
    populate_param_tab('BEN_ABS_IV_ABS_INFORMATION24', l_per_abs_att_rec.abs_information24);
    populate_param_tab('BEN_ABS_IV_ABS_INFORMATION25', l_per_abs_att_rec.abs_information25);
    populate_param_tab('BEN_ABS_IV_ABS_INFORMATION26', l_per_abs_att_rec.abs_information26);
    populate_param_tab('BEN_ABS_IV_ABS_INFORMATION27', l_per_abs_att_rec.abs_information27);
    populate_param_tab('BEN_ABS_IV_ABS_INFORMATION28', l_per_abs_att_rec.abs_information28);
    populate_param_tab('BEN_ABS_IV_ABS_INFORMATION29', l_per_abs_att_rec.abs_information29);
    populate_param_tab('BEN_ABS_IV_ABS_INFORMATION30', l_per_abs_att_rec.abs_information30);
    populate_param_tab('BEN_ABS_IV_ATTRIBUTE_CATEGORY', l_per_abs_att_rec.attribute_category);
    populate_param_tab('BEN_ABS_IV_ATTRIBUTE1', l_per_abs_att_rec.attribute1);
    populate_param_tab('BEN_ABS_IV_ATTRIBUTE2', l_per_abs_att_rec.attribute2);
    populate_param_tab('BEN_ABS_IV_ATTRIBUTE3', l_per_abs_att_rec.attribute3);
    populate_param_tab('BEN_ABS_IV_ATTRIBUTE4', l_per_abs_att_rec.attribute4);
    populate_param_tab('BEN_ABS_IV_ATTRIBUTE5', l_per_abs_att_rec.attribute5);
    populate_param_tab('BEN_ABS_IV_ATTRIBUTE6', l_per_abs_att_rec.attribute6);
    populate_param_tab('BEN_ABS_IV_ATTRIBUTE7', l_per_abs_att_rec.attribute7);
    populate_param_tab('BEN_ABS_IV_ATTRIBUTE8', l_per_abs_att_rec.attribute8);
    populate_param_tab('BEN_ABS_IV_ATTRIBUTE9', l_per_abs_att_rec.attribute9);
    populate_param_tab('BEN_ABS_IV_ATTRIBUTE10', l_per_abs_att_rec.attribute10);
    populate_param_tab('BEN_ABS_IV_ATTRIBUTE11', l_per_abs_att_rec.attribute11);
    populate_param_tab('BEN_ABS_IV_ATTRIBUTE12', l_per_abs_att_rec.attribute12);
    populate_param_tab('BEN_ABS_IV_ATTRIBUTE13', l_per_abs_att_rec.attribute13);
    populate_param_tab('BEN_ABS_IV_ATTRIBUTE14', l_per_abs_att_rec.attribute14);
    populate_param_tab('BEN_ABS_IV_ATTRIBUTE15', l_per_abs_att_rec.attribute15);
    populate_param_tab('BEN_ABS_IV_ATTRIBUTE16', l_per_abs_att_rec.attribute16);
    populate_param_tab('BEN_ABS_IV_ATTRIBUTE17', l_per_abs_att_rec.attribute17);
    populate_param_tab('BEN_ABS_IV_ATTRIBUTE18', l_per_abs_att_rec.attribute18);
    populate_param_tab('BEN_ABS_IV_ATTRIBUTE19', l_per_abs_att_rec.attribute19);
    populate_param_tab('BEN_ABS_IV_ATTRIBUTE20', l_per_abs_att_rec.attribute20);

    g_outputs.delete;
    g_outputs := benutils.formula
      (p_formula_id            => p_input_va_calc_rl,
       p_effective_date        => p_effective_date,
       p_business_group_id     => p_business_group_id,
       p_ler_id                => p_ler_id,
       p_assignment_id         => p_assignment_id,
       p_organization_id       => p_organization_id,
       p_pgm_id                => p_pgm_id,
       p_pl_typ_id             => p_pl_typ_id,
       p_pl_id                 => p_pl_id,
       p_opt_id                => p_opt_id,
       p_acty_base_rt_id       => p_acty_base_rt_id,
       p_jurisdiction_code     => p_jurisdiction_code,
       p_param_tab             => l_param_tab);

    if g_debug then
      hr_utility.set_location('formula count  :'||g_outputs.count,5);
    end if;

    if p_input_value_id1 is not null and
       p_abs_ler then

       open c_inp_name;
       fetch c_inp_name into l_inp_name;
       close c_inp_name;

       g_outputs(nvl(g_outputs.count,0)+1).name :=
                                      nvl(l_inp_name,'LENGTH_OF_SERVICE');
       g_outputs(g_outputs.count).value := p_entry_value1;
    end if;

    if g_debug then
      hr_utility.set_location('After formula executing : ',5);
    end if;
    --
    --
    -- Loop through the returned table and make sure that the returned
    -- values have been found

    l_counter := 0;
    --
    for l_count in g_outputs.first..g_outputs.last loop
      --
      begin
        --
        -- order c_ext_inpval by pay_input_values.display_seq_number
        -- While updating the element entry need to update the proper
        -- input values. Ex., may be reuired to update 3, 8, 13th input's
        -- All other's should be defaulted to what is on api definition.
        --
        for l_ext_inpval_rec in c_ext_inpval loop
           --
           -- Loop through ben_ext_inpval table and map the
           -- formula output's to rows.
           --
           if g_outputs(l_count).name = l_ext_inpval_rec.return_var_name then
              if ((p_dml_typ = 'C') or
                 (p_dml_typ = l_ext_inpval_rec.upd_when_ele_ended_cd)) then
                 --
                 -- Put in a pl/sql structure for extra inputs cache.
                 --
                 l_counter := l_counter + 1;
                 if g_debug then
                   hr_utility.set_location('Before assign extra inputs cache',11);
                 end if;
                 --
                 l_ext_inpval_tab(l_counter).extra_input_value_id
                                          := l_ext_inpval_rec.extra_input_value_id;
                 l_ext_inpval_tab(l_counter).upd_when_ele_ended_cd
                                          := l_ext_inpval_rec.upd_when_ele_ended_cd;
                 l_ext_inpval_tab(l_counter).input_value_id
                                          := l_ext_inpval_rec.input_value_id;
                 l_ext_inpval_tab(l_counter).return_var_name
                                          := l_ext_inpval_rec.return_var_name;
                 l_ext_inpval_tab(l_counter).return_value
                                          := g_outputs(l_count).value;
              end if;
              --
           elsif g_outputs(l_count).name = 'SUBPRIORITY' then
             --
             p_subpriority := to_number(g_outputs(l_count).value);
             --
           end if;
        end loop;
      exception
        --
        when others then
          --
          fnd_message.set_name('BEN','BEN_92311_FORMULA_VAL_PARAM');
          fnd_message.set_token('PROC',l_proc);
          --fnd_message.set_token('FORMULA',l_input_va_calc_rl_rec.input_va_calc_rl);
          fnd_message.set_token('PARAMETER',g_outputs(l_count).name);
          fnd_message.raise_error;
        --
      end;
      --
    end loop;
    --
  end if;
  --
  p_ext_inpval_tab := l_ext_inpval_tab;

  for i in p_ext_inpval_tab.count+1..14
  loop
      p_ext_inpval_tab(i).extra_input_value_id := null;
      p_ext_inpval_tab(i).upd_when_ele_ended_cd := null;
      p_ext_inpval_tab(i).input_value_id := null;
      p_ext_inpval_tab(i).return_var_name := null;
      p_ext_inpval_tab(i).return_value := null;
  end loop;

  if g_debug then
    hr_utility.set_location('Leaving: '||l_proc,5);
  end if;
exception
--
when others then
     if g_debug then
       hr_utility.set_location('Error in get_extra_ele '||sqlerrm,5);
     end if;
     raise;

end get_extra_ele_inputs;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< get_legislation_code>----------------------------|
-- ----------------------------------------------------------------------------
--
-- Gets the legislation code for a bg
--
function get_legislation_code
(p_business_group_id in number)
return varchar2 is

  l_leg_code per_business_groups.legislation_code%type;
  cursor c_leg is
    select bg.legislation_code
    from   per_business_groups bg
    where  bg.business_group_id = p_business_group_id;

begin

  open c_leg;
  fetch c_leg into l_leg_code;
  close c_leg;

  return l_leg_code;

end;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< get_inpval_tab >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure get_inpval_tab
(p_element_entry_id   in number,
 p_effective_date     in date,
 p_inpval_tab         out nocopy inpval_tab_typ) is

/*
-- commented for bug 5721053
cursor c_inpval is
select input_value_id,
       screen_entry_value
  from pay_element_entry_values_f
 where element_entry_id = p_element_entry_id
   and p_effective_date between effective_start_date
   and effective_end_date;
*/
-- changed for bug 5721053
cursor c_inpval is
select peev.input_value_id,
       peev.screen_entry_value,
       piv.UOM
  from pay_element_entry_values_f peev, pay_input_values_f piv
 where peev.element_entry_id = p_element_entry_id
   and p_effective_date between peev.effective_start_date and peev.effective_end_date
   and piv.input_value_id = peev.input_value_id
   and p_effective_date between piv.effective_start_date and piv.effective_end_date;

type t_input_value_id is table of number(15);
type t_value is table of varchar2(60);
type t_uom is table of VARCHAR2(30);

l_input_value_id t_input_value_id;
l_value t_value;
l_uom t_uom;
l_canonical_date date;


begin


open c_inpval;
  fetch c_inpval bulk collect into l_input_value_id, l_value, l_uom;
close c_inpval;

for i in 1..l_input_value_id.count
loop
    p_inpval_tab(i).input_value_id := l_input_value_id(i);
    -- bug 5721053
    IF l_uom (i) = 'D' OR l_uom (i) = 'DATE'
    THEN
       l_canonical_date := fnd_date.canonical_to_date (l_value (i));
       p_inpval_tab (i).VALUE :=
                               fnd_date.date_to_displaydate (l_canonical_date);
-- Bug 6820098
    ELSE
     p_inpval_tab(i).value := l_value(i);
-- Bug 6820098
    END IF;
    -- end bug 5721053
end loop;

for i in (l_input_value_id.count + 1)..15
loop
    p_inpval_tab(i).input_value_id := null;
    p_inpval_tab(i).value := null;
end loop;

end get_inpval_tab;
-- ----------------------------------------------------------------------------
-- |---------------------------------< get_uom>-------------------------------|
-- ----------------------------------------------------------------------------
--
function get_uom
(p_business_group_id  in number,
 p_effective_date     in date)
return varchar2 is

cursor get_pgm_curr_code (c_pgm_id number,
                  c_effective_date date,
                  c_business_group_id number) is
select pgm_uom
  from ben_pgm_f
 where pgm_id = c_pgm_id
   and c_effective_date between effective_start_date
   and effective_end_date
   and business_group_id = c_business_group_id;

-- For plans not in progarms
cursor get_pl_curr_code (c_pl_id number,
                         c_effective_date date,
                         c_business_group_id number) is
select nip_pl_uom
  from ben_pl_f
 where pl_id = c_pl_id
   and c_effective_date between effective_start_date
   and effective_end_date
   and business_group_id = c_business_group_id;

  l_uom               varchar2(30);

begin

  if g_debug then
     hr_utility.set_location('g_result_rec.pgm_id='|| g_result_rec.pgm_id,5);
     hr_utility.set_location('g_result_rec.pl_id='|| g_result_rec.pl_id,5);
  end if;

  if g_result_rec.pgm_id is not null then

       open get_pgm_curr_code
         ( g_result_rec.pgm_id
          ,p_effective_date
          ,p_business_group_id);
       fetch get_pgm_curr_code into l_uom;
       close get_pgm_curr_code;

  elsif g_result_rec.pl_id is not null then

       open get_pl_curr_code
         ( g_result_rec.pl_id
          ,p_effective_date
          ,p_business_group_id);
       fetch get_pl_curr_code into l_uom;
       close get_pl_curr_code;

  end if;

  if g_debug then
     hr_utility.set_location('l_uom ='||l_uom,432);
  end if;

  return l_uom;

end;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< chkformat>--------------------------------|
-- ----------------------------------------------------------------------------
--
function chkformat(p_value     in varchar2
                  ,p_curr_code in varchar2)
return number is

  changed_val varchar2(60);
  nvalue      number;

begin

  nvalue := fnd_number.canonical_to_number(p_value);

  if p_curr_code is null then
     return to_number(p_value);
  end if;

  SELECT LTRIM
            ( TO_CHAR
              ( DECODE --round to min acct limits if available.
                ( fc.minimum_accountable_unit,
                  NULL, ROUND( nvalue, fc.precision ),
                  ROUND( nvalue / fc.minimum_accountable_unit ) * fc.minimum_accountable_unit
                )
              , CONCAT --construct NLS format mask.
                ( '99999999999999999990', --currencies formatted without NLS 'G'.
                  DECODE( fc.precision, 0, '', RPAD( 'D', fc.precision+1, '9' ) )
                )
              ), ' ' --left trim white space.
            )
    INTO changed_val
    FROM fnd_currencies fc
   WHERE fc.currency_code = p_curr_code;

   return to_number(changed_val);

exception
   when others then
        return to_number(p_value);

end chkformat;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< get_ele_dt_upd_mode>---------------------------|
-- ----------------------------------------------------------------------------
--
function get_ele_dt_upd_mode
(p_effective_date  in date,
 p_base_key_value  in number)
return varchar2 is

  l_correction                boolean;
  l_update                    boolean;
  l_update_override           boolean;
  l_update_change_insert      boolean;
  l_upd_mode                  varchar2(30);

begin

  dt_api.find_dt_upd_modes
 (p_effective_date       => p_effective_date,
  p_base_table_name      => 'PAY_ELEMENT_ENTRIES_F',
  p_base_key_column      => 'element_entry_id',
  p_base_key_value       => p_base_key_value,
  p_correction           => l_correction,
  p_update               => l_update,
  p_update_override      => l_update_override,
  p_update_change_insert => l_update_change_insert);

  if l_update then
     l_upd_mode := hr_api.g_update;
  elsif l_update_override then
     l_upd_mode := hr_api.g_update_override;
  else
     l_upd_mode :=  hr_api.g_correction;
  end if;

  return l_upd_mode;

end;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< cache_quick_pay_run>---------------------------|
-- ----------------------------------------------------------------------------
--
-- Retro pay process for Quick pay run
procedure cache_quick_pay_run
  (p_person_id number,
   p_element_type_id number,
   p_assignment_id number,
   p_element_entry_id number,
   p_effective_date date,
   p_start_date  date,
   p_end_date    date,
   p_payroll_id  number)
is
  --
  cursor c_quick_pay_inclusion (p_assignment_id number,
                                p_effective_date date,
                                p_element_type_id number) is
  select qi.assignment_action_id,
         qi.element_entry_id,
         tp.end_date
  from   pay_assignment_actions  aa,
         pay_payroll_actions     pa,
         pay_quickpay_inclusions qi,
         pay_element_links_f     el,
         pay_element_entries_f   ee,
         per_time_periods        tp
  where  aa.assignment_id = p_assignment_id
  and    pa.payroll_action_id = aa.payroll_action_id
  and    pa.action_type = 'Q'
  and    pa.time_period_id = tp.time_period_id
  and    p_effective_date between tp.start_date and tp.end_date
  and    aa.assignment_action_id = qi.assignment_action_id
  and    ee.element_entry_id = qi.element_entry_id
  and    aa.assignment_id = ee.assignment_id
  and    el.element_link_id = ee.element_link_id
  and    el.element_type_id = p_element_type_id
  and    pa.effective_date between el.effective_start_date and
         el.effective_end_date
  and    pa.effective_date between ee.effective_start_date and
         ee.effective_end_date;
  --
  cursor c_periods(v_payroll_id in number,
                   v_start_date in date,
                   v_end_date   in date) is
        select end_date
        from   per_time_periods ptp
        where  ptp.payroll_id     = v_payroll_id
        and    ptp.end_date between
               v_start_date and v_end_date;
  l_quick_pay_inclusion     c_quick_pay_inclusion%rowtype;
  l_end_date date;
  l_count    number;

--
begin
  --
  hr_utility.set_location('Enter : Cache quick pay',111);
  open c_periods (p_payroll_id, p_start_date,p_end_date);
  loop
    fetch c_periods into l_end_date;
    if c_periods%notfound then
       exit;
       --
    else
      --
     hr_utility.set_location('End date : '||l_end_date,112);
      open c_quick_pay_inclusion (p_assignment_id,
                                  l_end_date,
                                  p_element_type_id);
      fetch c_quick_pay_inclusion into l_quick_pay_inclusion;
      if c_quick_pay_inclusion%found then
         --pop cache
         if g_cache_quick_payrun_object.count > 0 then
             if g_cache_quick_payrun_object(1).person_id <> p_person_id then
               g_cache_quick_payrun_object.delete;
              hr_utility.set_location('Delete  : Cache quick pay',113);
             end if;
         end if;
         l_count := nvl(g_cache_quick_payrun_object.last,0) + 1;
         -- assign the values into cache
         g_cache_quick_payrun_object(l_count).person_id := p_person_id;
         g_cache_quick_payrun_object(l_count).element_type_id := p_element_type_id;
         g_cache_quick_payrun_object(l_count).assignment_id := p_assignment_id;
         g_cache_quick_payrun_object(l_count).assignment_action_id :=
                                           l_quick_pay_inclusion.assignment_action_id;
         g_cache_quick_payrun_object(l_count).payroll_end_date :=
                                           l_quick_pay_inclusion.end_date;
         hr_utility.set_location('Assignment Action id'||g_cache_quick_payrun_object(l_count).assignment_action_id, 113);
      end if;
      close c_quick_pay_inclusion;
    end if;
  end loop;
  close c_periods;
  --
end;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< insert_into_quick_pay>------------------------|
-- ----------------------------------------------------------------------------
--
procedure insert_into_quick_pay
     (p_person_id number,
      p_element_type_id number,
      p_assignment_id number,
      p_element_entry_id number,
      p_effective_date date,
      p_start_date  date,
      p_end_date    date,
      p_payroll_id  number) is
 --
  cursor c_periods(v_payroll_id in number,
                   v_start_date in date,
                   v_end_date   in date) is
        select end_date
        from   per_time_periods ptp
        where  ptp.payroll_id     = v_payroll_id
        and    ptp.end_date between
               v_start_date and v_end_date;
  l_end_date date;
  l_count    number;
 --
begin
  --
   hr_utility.set_location('Enter : insert into quick pay',111);
   open c_periods (p_payroll_id, p_start_date,p_end_date);
   loop
     fetch c_periods into l_end_date;
     if c_periods%notfound then
        --
        exit;
       --
     else
       --
       if g_cache_quick_payrun_object.count > 0 then
          for j in g_cache_quick_payrun_object.first .. g_cache_quick_payrun_object.last
            loop
              if g_cache_quick_payrun_object(j).person_id = p_person_id and
                 g_cache_quick_payrun_object(j).element_type_id = p_element_type_id and
                 g_cache_quick_payrun_object(j).payroll_end_date = l_end_date then
                  hr_utility.set_location('Insert quick pay'||p_element_entry_id,11);
                  hr_utility.set_location('Assignment action Id'||g_cache_quick_payrun_object(j).assignment_action_id, 12);
                  insert into pay_quickpay_inclusions (element_entry_id, assignment_action_id)
                  values (p_element_entry_id,g_cache_quick_payrun_object(j).assignment_action_id);
               end if;
             end loop;
       end if;
     end if;
   end loop;
   close c_periods;
End;

-- ----------------------------------------------------------------------------
-- |-----------------------< get_abr_assignment >-----------------------------|
-- ----------------------------------------------------------------------------
procedure get_abr_assignment
  (p_person_id       in     number
  ,p_effective_date  in     date
  ,p_acty_base_rt_id in     number
  ,p_organization_id    out nocopy number
  ,p_payroll_id         out nocopy number
  ,p_assignment_id      out nocopy number
  )
is
  --
  cursor get_asmt_to_use_cd
    (c_acty_base_rt_id in number
    ,c_effective_date  in date
    )
  is
    select abr.asmt_to_use_cd
    from   ben_acty_base_rt_f abr
    where  abr.acty_base_rt_id = c_acty_base_rt_id
      and  c_effective_date between
           abr.effective_start_date and abr.effective_end_date;
  --
  -- Cursor to get assignment_id
  --
      CURSOR get_assignment (
         c_person_id         IN   NUMBER,
         c_assignment_type   IN   VARCHAR2,
         c_effective_date    IN   DATE
      )
      IS
         SELECT   asg.assignment_id, asg.payroll_id, asg.organization_id,
                  asg.effective_start_date, asg.effective_end_date
             FROM per_all_assignments_f asg, per_assignment_status_types ast
            WHERE asg.person_id = c_person_id
              AND asg.assignment_type <> 'C'
              AND asg.primary_flag = 'Y'
              AND asg.assignment_status_type_id = ast.assignment_status_type_id
              -- AND ast.per_system_status <> 'TERM_ASSIGN'   /* Bug 5655933  */
              AND asg.assignment_type =
                                  NVL (c_assignment_type, asg.assignment_type)
              AND c_effective_date BETWEEN asg.effective_start_date
                                       AND asg.effective_end_date
         ORDER BY asg.assignment_type DESC ; -- Bug 4463077 : Look for employee assignment and then for benefits asg
  --
  l_effective_start_date    date;
  l_effective_end_date      date;
  l_asmt_to_use_cd          VARCHAR2(30);
  l_proc                    VARCHAR2(72) := g_package||'get_abr_assignment';
  --
begin
  --
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    hr_utility.set_location('Entering: '||l_proc,5);
    hr_utility.set_location('p_effective_date: '||p_effective_date,5);
  end if;
  --
  -- get assignment to use code.
  --
  open get_asmt_to_use_cd
    (c_acty_base_rt_id => p_acty_base_rt_id
    ,c_effective_date  => p_effective_date
    );
  fetch get_asmt_to_use_cd into l_asmt_to_use_cd;
  if get_asmt_to_use_cd%notfound then
    close get_asmt_to_use_cd;
    if g_debug then
      hr_utility.set_location('BEN_91723_NO_ENRT_RT_ABR_FOUND',30);
    end if;
    fnd_message.set_name('BEN','BEN_91723_NO_ENRT_RT_ABR_FOUND');
    fnd_message.set_token('PROC',l_proc);
    fnd_message.set_token('ACTY_BASE_RT_ID',to_char(p_acty_base_rt_id));
    fnd_message.set_token('EFFECTIVE_DATE',to_char(p_effective_date));
    fnd_message.raise_error;
  else
    close get_asmt_to_use_cd;
  end if;
  --
  -- check if this info is already cached
  --
  if g_abr_asg_rec.person_id = p_person_id and
     nvl(l_asmt_to_use_cd,'ETB') <> 'BTE' and --------Bug 8394662
     nvl(g_abr_asg_rec.asmt_to_use_cd,'ETB') = nvl(l_asmt_to_use_cd,'ETB') and
     (p_effective_date between g_abr_asg_rec.effective_start_date and
      g_abr_asg_rec.effective_end_date) then

     p_assignment_id   := g_abr_asg_rec.assignment_id;
     p_payroll_id      := g_abr_asg_rec.payroll_id;
     p_organization_id := g_abr_asg_rec.organization_id;

     if g_debug then
        hr_utility.set_location('asmt_to_use_cd: '||l_asmt_to_use_cd,5);
        hr_utility.set_location('organization_id: '||p_organization_id,5);
        hr_utility.set_location('payroll_id: '||p_payroll_id,5);
        hr_utility.set_location('assignment_id: '||p_assignment_id,5);
        hr_utility.set_location('Leaving: '||l_proc,5);
     end if;
     return;
  else
     g_abr_asg_rec.person_id            := null;
     g_abr_asg_rec.assignment_id        := null;
     g_abr_asg_rec.payroll_id           := null;
     g_abr_asg_rec.organization_id      := null;
     g_abr_asg_rec.effective_start_date := null;
     g_abr_asg_rec.effective_end_date   := null;
  end if;
  --
  --  Check the assigment to use code to get the assignment id
  --  for the element entry.
  --
  if (l_asmt_to_use_cd = 'EAO') then
    --
    --  Employee assignment only.
    --
    open get_assignment
      (c_person_id       => p_person_id
      ,c_assignment_type => 'E'
      ,c_effective_date  => p_effective_date
      );
    fetch get_assignment into p_assignment_id
                             ,p_payroll_id
                             ,p_organization_id
                             ,l_effective_start_date
                             ,l_effective_end_date;
    close get_assignment;
    --
  elsif l_asmt_to_use_cd = 'BAO' then
    --
    --  Benefit assignment only.
    --
    open get_assignment
      (c_person_id       => p_person_id
      ,c_assignment_type => 'B'
      ,c_effective_date  => p_effective_date
      );
    fetch get_assignment into p_assignment_id
                             ,p_payroll_id
                             ,p_organization_id
                             ,l_effective_start_date
                             ,l_effective_end_date;
    close get_assignment;
    --
  elsif l_asmt_to_use_cd = 'BTE' then
    --
    --  Benefit assignment then employee assignment.
    --
    open get_assignment
      (c_person_id       => p_person_id
      ,c_assignment_type => 'B'
      ,c_effective_date  => p_effective_date
      );
    fetch get_assignment into p_assignment_id
                             ,p_payroll_id
                             ,p_organization_id
                             ,l_effective_start_date
                             ,l_effective_end_date;
    if get_assignment%notfound then
      close get_assignment;
      if g_debug then
        hr_utility.set_location('Benefit assignment not found- BTE',5);
      end if;
      --
      --  Get employee assignment.
      --
      open get_assignment
        (c_person_id       => p_person_id
        ,c_assignment_type => 'E'
        ,c_effective_date  => p_effective_date
        );
      fetch get_assignment into p_assignment_id
                               ,p_payroll_id
                               ,p_organization_id
                               ,l_effective_start_date
                               ,l_effective_end_date;
      close get_assignment;
    else
      close get_assignment;
    end if;
    --
/*  elsif l_asmt_to_use_cd = 'ANY' then
    --
    --  Any assignment only.
    --
    open get_assignment
      (c_person_id       => p_person_id
      ,c_assignment_type => null
      ,c_effective_date  => p_effective_date
      );
    fetch get_assignment into p_assignment_id
                             ,p_payroll_id
                             ,p_organization_id
                             ,l_effective_start_date
                             ,l_effective_end_date;
    close get_assignment;
    --
*/
  elsif (l_asmt_to_use_cd = 'EBA' or l_asmt_to_use_cd = 'ANY' ) then
    --
    --  Employee assignment then benefit assignment.
    --
    open get_assignment
      (c_person_id       => p_person_id
      ,c_assignment_type => 'E'
      ,c_effective_date  => p_effective_date
      );
    fetch get_assignment into p_assignment_id
                             ,p_payroll_id
                             ,p_organization_id
                             ,l_effective_start_date
                             ,l_effective_end_date;
    if get_assignment%notfound then
      close get_assignment;
      --
      --  Get benefit assignment.
      --
      open get_assignment
        (c_person_id       => p_person_id
        ,c_assignment_type => 'B'
        ,c_effective_date  => p_effective_date
        );
      fetch get_assignment into p_assignment_id
                               ,p_payroll_id
                               ,p_organization_id
                               ,l_effective_start_date
                               ,l_effective_end_date;
      if get_assignment%notfound then
        close get_assignment;
        --
        --  Get applicant assignment.
        --
        open get_assignment
          (c_person_id       => p_person_id
          ,c_assignment_type => 'A'
          ,c_effective_date  => p_effective_date
          );
        fetch get_assignment into p_assignment_id
                                 ,p_payroll_id
                                 ,p_organization_id
                                 ,l_effective_start_date
                                 ,l_effective_end_date;
        close get_assignment;
      else
        close get_assignment;
      end if;
    else
      close get_assignment;
    end if;
    --
  elsif (l_asmt_to_use_cd = 'ETB' or l_asmt_to_use_cd is null) then
    --
    --  Employee assignment then benefit assignment. - Default
    --
    open get_assignment
      (c_person_id       => p_person_id
      ,c_assignment_type => 'E'
      ,c_effective_date  => p_effective_date
      );
    fetch get_assignment into p_assignment_id
                             ,p_payroll_id
                             ,p_organization_id
                             ,l_effective_start_date
                             ,l_effective_end_date;
    if get_assignment%notfound then
      if g_debug then
        hr_utility.set_location('Employee assignment not found- ETB',5);
      end if;
      close get_assignment;
      --
      --  Get benefit assignment.
      --
      open get_assignment
        (c_person_id       => p_person_id
        ,c_assignment_type => 'B'
        ,c_effective_date  => p_effective_date
        );
      fetch get_assignment into p_assignment_id
                               ,p_payroll_id
                               ,p_organization_id
                               ,l_effective_start_date
                               ,l_effective_end_date;
      close get_assignment;
    else
      close get_assignment;
    end if;
    --
  elsif l_asmt_to_use_cd = 'AAO' then
    --
    --  Applicant assignment only.
    --
    open get_assignment
      (c_person_id       => p_person_id
      ,c_assignment_type => 'A'
      ,c_effective_date  => p_effective_date
      );
    fetch get_assignment into p_assignment_id
                             ,p_payroll_id
                             ,p_organization_id
                             ,l_effective_start_date
                             ,l_effective_end_date;
    close get_assignment;
    --
  end if;
  --
  g_abr_asg_rec.person_id            := p_person_id;
  g_abr_asg_rec.assignment_id        := p_assignment_id;
  g_abr_asg_rec.payroll_id           := p_payroll_id;
  g_abr_asg_rec.organization_id      := p_organization_id;
  g_abr_asg_rec.effective_start_date := l_effective_start_date;
  g_abr_asg_rec.effective_end_date   := l_effective_end_date;
	-- added for bug 5909589
	g_abr_asg_rec.asmt_to_use_cd       := l_asmt_to_use_cd;

  if g_debug then
    hr_utility.set_location('asmt_to_use_cd: '||l_asmt_to_use_cd,60);
    hr_utility.set_location('organization_id: '||p_organization_id,60);
    hr_utility.set_location('payroll_id: '||p_payroll_id,60);
    hr_utility.set_location('assignment_id: '||p_assignment_id,60);
    hr_utility.set_location('Leaving: '||l_proc,60);
  end if;
 --
end get_abr_assignment;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< get_default_payroll >----------------------------|
-- ----------------------------------------------------------------------------
--
function get_default_payroll
  (p_business_group_id in number
  ,p_effective_date    in date
  ) return number
is
  --
  l_payroll_id  number;
  l_proc        varchar2(72) := g_package||'get_default_payroll';
  --
  cursor c_get_default_payroll
    (c_business_group_id in number
    ,c_effective_date    in date
    )
  is
    select payroll_id
    from pay_payrolls_f
    where business_group_id = c_business_group_id
    and   period_type       = 'Calendar Month'
    and   c_effective_date
      between effective_start_date and effective_end_date;
  --
begin

  if g_debug then
    hr_utility.set_location('Entering:' ||l_proc,5);
  end if;

  open c_get_default_payroll
  (c_business_group_id => p_business_group_id
  ,c_effective_date    => p_effective_date
  );
  fetch c_get_default_payroll into l_payroll_id;
  close c_get_default_payroll;

  if g_debug then
    hr_utility.set_location('Leaving:' ||l_proc,5);
  end if;

  return l_payroll_id;

end get_default_payroll;

-- ----------------------------------------------------------------------------
-- |-----------------------< chk_assign_exists >-----------------------------|
-- ----------------------------------------------------------------------------
-- This Function checks the existence of a current
-- Employee or Benefits assignment
-- and returns the assignment_id and payroll_id
--
function chk_assign_exists
  (p_person_id         IN NUMBER
  ,p_business_group_id IN NUMBER
  ,p_effective_date    IN DATE
  ,p_rate_date         IN DATE
  ,p_acty_base_rt_id   IN number
  ,p_assignment_id     IN OUT NOCOPY NUMBER
  ,p_organization_id   in out nocopy number
  ,p_payroll_id        IN OUT NOCOPY NUMBER
  ) RETURN BOOLEAN
is
  --
  l_proc        varchar2(72) := g_package||'chk_assign_exists';
  --
  cursor c1 is
    select nvl(abr.ele_entry_val_cd,'PP') ele_entry_val_cd,
           abr.name
    from   ben_acty_base_rt_f abr
    where  abr.acty_base_rt_id = p_acty_base_rt_id
      and  p_rate_date between abr.effective_start_date
                           and abr.effective_end_date;
  --
  l_ele_entry_val_cd  varchar2(30);
  l_name              ben_acty_base_rt_f.name%TYPE ;
  --
begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    hr_utility.set_location('Entering:' ||l_proc,5);
  end if;

  -- First look for an assignment based on the date the rate is being
  -- started or ended.  We need to do this so that we pick up the correct
  -- assignment that the EE should be attached to.  For example:  if we are
  -- processing a termination event on 5/15 and we want to end a person's
  -- EE from prior enrollments, we need to pick up the Employee assignment
  -- that exists on 5/14 (rate end date), not the benefit's assignment that
  -- is created on 5/15.

  if g_debug then
    hr_utility.set_location('p_assignment_id:' ||p_assignment_id,5);
  end if;
  get_abr_assignment (p_person_id       => p_person_id
                     ,p_effective_date  => p_rate_date
                     ,p_acty_base_rt_id => p_acty_base_rt_id
                     ,p_organization_id => p_organization_id
                     ,p_payroll_id      => p_payroll_id
                     ,p_assignment_id   => p_assignment_id);
  if g_debug then
    hr_utility.set_location('p_assignment_id:' ||p_assignment_id,10);
  end if;
  --Bug 3151737 and 3063518
  open c1 ;
    fetch c1 into l_ele_entry_val_cd,l_name ;
  close c1 ;
  --
  if p_assignment_id is NOT NULL then
    --
    --  Bug 3151737 and 3063518 Why we do we care this for non EPP / PP cases.
    --  User needs explicitly mention communicated or defined value in the value passed
    --  to payroll if they are not using the payroll .
    --  Then we don't need to care for payroll and also we don't need to compute
    --  the pp amount using the bendisrt routines
    --
    if l_ele_entry_val_cd = 'PP' or
       l_ele_entry_val_cd = 'EPP' then
      --
      if p_payroll_id is null then
         /*
         if g_debug then
           hr_utility.set_location('BEN_92458_NO_ASG_PAYROLL PERSON:'|| to_char(p_person_id),5);
         end if;
         fnd_message.set_name('BEN', 'BEN_92458_NO_ASG_PAYROLL');
         fnd_message.set_token('PROC',l_proc);
         fnd_message.set_token('PERSON_ID',to_char(p_person_id));
         fnd_message.set_token('ASSIGNMENT_ID',to_char(p_assignment_id));
         fnd_message.raise_error;
         */
         if g_debug then
           hr_utility.set_location('BEN_93606_NO_ASG_PAYROLL PERSON:'|| to_char(p_person_id),5);
         end if;
         fnd_message.set_name('BEN', 'BEN_93606_NO_ASG_PAYROLL');
         fnd_message.set_token('ABR_NAME', l_name);
         fnd_message.set_token('PROC',l_proc);
         fnd_message.set_token('PERSON_ID',to_char(p_person_id));
         fnd_message.set_token('ASSIGNMENT_ID',to_char(p_assignment_id));
         fnd_message.raise_error;
      end if;
      --
    end if;
    --
    return TRUE;
  else

    -- If there is no assignment on the date the rate is to be started or ended,
    -- look for an assignment on the effective date.  Example:  A new hire event
    -- is processsed on 5/15, enrollments are made.  On 5/18, the enrollment is
    -- changed, the new enrollment is started on 5/15 (as of event date),
    -- the old one is ended on 5/14 (one day before event date), there is no
    -- assignment on 5/14 (because it was a new hire on 5/15).
    --
    get_abr_assignment (p_person_id       => p_person_id
                       ,p_effective_date  => p_effective_date
                       ,p_acty_base_rt_id => p_acty_base_rt_id
                       ,p_organization_id => p_organization_id
                       ,p_payroll_id      => p_payroll_id
                       ,p_assignment_id   => p_assignment_id);
    if p_assignment_id is NOT NULL then
      --
      if l_ele_entry_val_cd = 'PP' or
         l_ele_entry_val_cd = 'EPP' then
        --
        if p_payroll_id is null then
         /*
           if g_debug then
             hr_utility.set_location('BEN_92458_NO_ASG_PAYROLL PERSON:'|| to_char(p_person_id),5);
           end if;
           fnd_message.set_name('BEN', 'BEN_92458_NO_ASG_PAYROLL');
           fnd_message.set_token('PROC',l_proc);
           fnd_message.set_token('PERSON_ID',to_char(p_person_id));
           fnd_message.set_token('ASSIGNMENT_ID',to_char(p_assignment_id));
           fnd_message.raise_error;
         */
         if g_debug then
           hr_utility.set_location('BEN_93606_NO_ASG_PAYROLL PERSON:'|| to_char(p_person_id),5);
         end if;
         fnd_message.set_name('BEN', 'BEN_93606_NO_ASG_PAYROLL');
         fnd_message.set_token('ABR_NAME', l_name);
         fnd_message.set_token('PROC',l_proc);
         fnd_message.set_token('PERSON_ID',to_char(p_person_id));
         fnd_message.set_token('ASSIGNMENT_ID',to_char(p_assignment_id));
         fnd_message.raise_error;
        end if;
      end if;
      return TRUE;
      --
    else

      p_payroll_id := get_default_payroll
        (p_business_group_id => p_business_group_id
        ,p_effective_date    => p_effective_date
        );
      if p_payroll_id is null then
        if g_debug then
          hr_utility.set_location('BEN_92347_NO_DFLT_PAYROLL',25);
        end if;
        fnd_message.set_name('BEN', 'BEN_92347_NO_DFLT_PAYROLL');
         fnd_message.set_token('PROC',l_proc);
         fnd_message.set_token('PERSON_ID',to_char(p_person_id));
         fnd_message.set_token('EFFECTIVE_DATE',to_char(p_effective_date));
         fnd_message.set_token('BG_ID',to_char(p_business_group_id));
        fnd_message.raise_error;
      else
        if g_debug then
          hr_utility.set_location('Leaving-returning false:' ||l_proc,5);
        end if;
        return FALSE;
      end if;
    end if;
  end if;
  if g_debug then
    hr_utility.set_location('Leaving:' ||l_proc,5);
  end if;
end chk_assign_exists;

-- ----------------------------------------------------------------------------
-- |---------------< create_benefits_assignment >-----------------------------|
-- ----------------------------------------------------------------------------
-- This Procedure creates a benefits assignments
-- If the participant record being enrolled does not
-- have an assignment.

procedure create_benefits_assignment(p_person_id IN NUMBER
                                    ,p_payroll_id IN NUMBER
                                    ,p_assignment_id IN OUT NOCOPY NUMBER
                                    ,p_business_group_id IN NUMBER
                                    ,p_organization_id in out nocopy number
                                    ,p_effective_date IN DATE) is
--
l_assignment_id NUMBER;             -- Assignment ID.
l_effective_start_date DATE;        -- Effective Start Date.
l_effective_end_date DATE;          -- Effective End Date.
l_assignment_extra_info_id NUMBER;  -- Assignment Extra Info ID.
l_object_version_number NUMBER;     -- Object version number.
l_aei_object_version_number NUMBER; -- AEI Object version number.
l_proc varchar2(75);
begin
   g_debug := hr_utility.debug_enabled;
  if g_debug then
  l_proc  := ' Create_Benefits_Assignment';
    hr_utility.set_location('Entering:' ||l_proc,5);
  end if;
    BEN_assignment_API.create_ben_asg
        (p_effective_date => p_effective_date
        ,p_PERSON_ID => p_person_id
        ,p_ORGANIZATION_ID => p_business_group_id
        ,p_PAYROLL_ID => p_payroll_id
--        ,p_ASSIGNMENT_TYPE =>'A'
--        ,p_PRIMARY_FLAG =>'Y'
        ,p_ASSIGNMENT_STATUS_TYPE_ID => 1
        ,p_ASSIGNMENT_ID => l_assignment_id
        ,p_OBJECT_VERSION_NUMBER => l_object_version_number
        ,p_EFFECTIVE_START_DATE => l_effective_start_date
        ,p_EFFECTIVE_END_DATE => l_effective_end_date
        ,p_ASSIGNMENT_EXTRA_INFO_ID => l_assignment_extra_info_id
        ,p_AEI_OBJECT_VERSION_NUMBER => l_aei_object_version_number);
    p_organization_id:=p_business_group_id;
  if g_debug then
    hr_utility.set_location('Leaving:' ||l_proc,5);
  end if;
end create_benefits_assignment;
--
-- ----------------------------------------------------------------------------
-- |---------------------< prorate_amount >-----------------------------|
-- ----------------------------------------------------------------------------
function prorate_amount(p_amt IN NUMBER --per month amount
                       ,p_acty_base_rt_id IN NUMBER
                       ,p_actl_prem_id in number
                       ,p_cvg_amt_calc_mthd_id in number
                       ,p_person_id in number
                       ,p_rndg_cd in varchar2
                       ,p_rndg_rl in number
                       ,p_pgm_id in number
                       ,p_pl_typ_id in number
                       ,p_pl_id in number
                       ,p_opt_id in number
                       ,p_ler_id in number
                       ,p_prorate_flag IN OUT NOCOPY VARCHAR2
                       ,p_effective_date in DATE
                       ,p_start_or_stop_cd in varchar2
                       ,p_start_or_stop_date in date
                       ,p_business_group_id in number
                       ,p_assignment_id in number
                       ,p_organization_id in number
                       ,p_jurisdiction_code in varchar2
                       ,p_wsh_rl_dy_mo_num in number
                       ,p_prtl_mo_det_mthd_cd in out nocopy varchar2
                       ,p_prtl_mo_det_mthd_rl in number)
         RETURN NUMBER
IS  --prorated per month amount
  --
  cursor get_prtn_row
    (c_acty_base_rt_id      in number
    ,c_actl_prem_id         in number
    ,c_cvg_amt_calc_mthd_id in number
    ,c_effective_date       in date
    ,c_start_or_stop_date   in date
    ,c_start_or_stop_cd     in varchar2
    )
  is
    select *
    from BEN_PRTL_MO_RT_PRTN_VAL_F
    where (acty_base_rt_id      = p_acty_base_rt_id or
           actl_prem_id         = p_actl_prem_id or
           cvg_amt_calc_mthd_id = p_cvg_amt_calc_mthd_id
          )
    and c_effective_date
      between effective_start_date and effective_end_date
    and to_number(to_char(c_start_or_stop_date,'DD'))
      between from_dy_mo_num and to_dy_mo_num
    and (num_days_month = to_number(to_char(last_day(c_start_or_stop_date),'DD')) or
           num_days_month is null)
      and c_start_or_stop_cd=
            decode(nvl(strt_r_stp_cvg_cd,'ETHR'),'ETHR',c_start_or_stop_cd,strt_r_stp_cvg_cd);
  --
  --
   cursor get_prtn_method
    (c_acty_base_rt_id      in number
    ,c_actl_prem_id         in number
    ,c_cvg_amt_calc_mthd_id in number
    ,c_effective_date       in date)
   is
     select 'Y'
     from BEN_PRTL_MO_RT_PRTN_VAL_F
     where (acty_base_rt_id      = p_acty_base_rt_id or
            actl_prem_id         = p_actl_prem_id or
            cvg_amt_calc_mthd_id = p_cvg_amt_calc_mthd_id
           )
     and prorate_by_day_to_mon_flag = 'Y'
     and c_effective_date
      between effective_start_date and effective_end_date;
  --
  l_rounded_value         number;
  l_prorated_amt          number;
  l_pct_val               number;
  p_rec                   BEN_PRTL_MO_RT_PRTN_VAL_F%ROWTYPE;
  l_proc                  varchar2(75) := ' Prorate_amount';
  l_result_amt            number;
  l_outputs               ff_exec.outputs_t;
  l_return_amt            number;
  l_jurisdiction_code     varchar2(30);
  l_was_rounded           boolean:=false;
  l_prtn_method           varchar2(30);
  --
begin
  --
  if g_debug then
    hr_utility.set_location('Entering:' ||l_proc,5);
  end if;
  --
  if p_prtl_mo_det_mthd_cd='RL' and
     p_prtl_mo_det_mthd_rl is not null then
    --
    l_outputs:=benutils.formula
              (p_opt_id               =>p_opt_id,
               p_pl_id                =>p_pl_id,
               p_pgm_id               =>p_pgm_id,
               p_formula_id           =>p_prtl_mo_det_mthd_rl,
               p_ler_id               =>p_ler_id,
               p_pl_typ_id            =>p_pl_typ_id,
               p_assignment_id        =>p_assignment_id,
               p_acty_base_rt_id      =>p_acty_base_rt_id,
               p_business_group_id    =>p_business_group_id,
               p_organization_id      =>p_organization_id,
               p_jurisdiction_code    =>p_jurisdiction_code,
               p_effective_date       =>p_effective_date);
    --
    begin
      --
      -- convert return value to code
      --
      p_prtl_mo_det_mthd_cd:=l_outputs(l_outputs.first).value;
      --
    exception
      --
      when others then
        if g_debug then
          hr_utility.set_location('BEN_92311_FORMULA_VAL_PARAM',5);
        end if;
        fnd_message.set_name('BEN','BEN_92311_FORMULA_VAL_PARAM');
        fnd_message.set_token('PROC',l_proc);
        fnd_message.set_token('FORMULA',p_prtl_mo_det_mthd_rl);
        fnd_message.set_token('PARAMETER',l_outputs(l_outputs.first).name);
        fnd_message.raise_error;
      --
    end;
  end if;
  --
  if p_prtl_mo_det_mthd_cd is null
    or p_prtl_mo_det_mthd_cd = 'ALL'
  then
    p_prorate_flag:='N';
    l_return_amt:=p_amt;
  elsif p_prtl_mo_det_mthd_cd='NONE' then
    p_prorate_flag:='Y';
    l_return_amt:=0;
  elsif p_prtl_mo_det_mthd_cd='PRTVAL' then
    if g_debug then
      hr_utility.set_location('p_start_or_stop_cd '||p_start_or_stop_cd,5);
    end if;
    --
     -- find proration method
    open get_prtn_method
      (c_acty_base_rt_id      => p_acty_base_rt_id
      ,c_actl_prem_id         => p_actl_prem_id
      ,c_cvg_amt_calc_mthd_id => p_cvg_amt_calc_mthd_id
      ,c_effective_date       => p_effective_date);
    fetch get_prtn_method into l_prtn_method;
    close get_prtn_method;
    --
    if l_prtn_method = 'Y' then
      --
      hr_utility.set_location ('Proration by day to month',111);
      if p_start_or_stop_cd = 'STRT' then
        --
        l_pct_val := (to_number(to_char(last_day(p_start_or_stop_date),'DD')) -
                            to_number(to_char(p_start_or_stop_date,'DD')) + 1 )  /
                             to_number(to_char(last_day(p_start_or_stop_date),'DD'));
      elsif p_start_or_stop_cd = 'STP' then
        --
        l_pct_val := to_number(to_char(p_start_or_stop_date,'DD'))  /
                           to_number(to_char(last_day(p_start_or_stop_date),'DD'));
      end if;
      hr_utility.set_location ('Percentage value'||l_pct_val,112);
      if l_pct_val = 100 then
        --
        p_prorate_flag := 'N';
        l_return_amt:=p_amt;
        --
      else
        --
        l_prorated_amt := l_pct_val * p_amt;
        --
        -- Now we have the prorated value, do the rounding
        --
        if (p_rec.rndg_cd is not null or
            p_rec.rndg_rl is not null) and
           l_prorated_amt is not null then
         --
         l_return_amt := benutils.do_rounding
          (p_rounding_cd    => p_rec.rndg_cd,
           p_rounding_rl    => p_rec.rndg_rl,
           p_value          => l_prorated_amt,
           p_effective_date => p_effective_date);
         --
        elsif p_amt<>0 and
              p_amt is not null then
          --
          -- for now later do based on currency precision.
          --
          l_return_amt:=round(l_prorated_amt,2);
        else
          l_return_amt:=nvl(l_prorated_amt,0);
        end if;
        l_was_rounded:=true;
        p_prorate_flag:='Y';
      end if;
      --
    else -- proration method is N - old setup
      -- Get the correct ben_prtl_mo_rt_prtn_val_f
      --
      open get_prtn_row
        (c_acty_base_rt_id      => p_acty_base_rt_id
        ,c_actl_prem_id         => p_actl_prem_id
        ,c_cvg_amt_calc_mthd_id => p_cvg_amt_calc_mthd_id
        ,c_effective_date       => p_effective_date
        ,c_start_or_stop_date   => p_start_or_stop_date
        ,c_start_or_stop_cd     => p_start_or_stop_cd
        );
      fetch get_prtn_row into p_rec;
      if get_prtn_row%notfound
      then
        if g_debug then
          hr_utility.set_location('prtn not found ',5);
        end if;
        close get_prtn_row;
        p_prorate_flag := 'N';
        l_return_amt:=p_amt;
      else
        close get_prtn_row;
        --
        -- If the pct_val is null then it may be a rule
        -- if neither error
        --
        if p_rec.pct_val is null then
          if p_rec.prtl_mo_prortn_rl is null then
            --
            -- Neither, error
            --
            if g_debug then
              hr_utility.set_location('BEN_92343_NO_PCT_VAL_OR_RL',5);
            end if;
            fnd_message.set_name('BEN', 'BEN_92343_NO_PCT_VAL_OR_RL');
            fnd_message.set_token('PROC',l_proc);
            fnd_message.set_token('PRTL_MO_RT_PRTN_VAL_ID',
                                   to_char(p_rec.prtl_mo_rt_prtn_val_id));
            fnd_message.set_token('ACTY_BASE_RT_ID',to_char(p_acty_base_rt_id));
            fnd_message.set_token('ACTL_PREM_ID',to_char(p_actl_prem_id));
            fnd_message.set_token('CVG_AMT_CALC_MTHD_ID',
                                   to_char(p_cvg_amt_calc_mthd_id));
            fnd_message.raise_error;
          else
            --
            -- Get pct_val from rule execution.
            --
            l_outputs:=benutils.formula
                      (p_opt_id               =>p_opt_id,
                       p_pl_id                =>p_pl_id,
                       p_pgm_id               =>p_pgm_id,
                       p_formula_id           =>p_rec.prtl_mo_prortn_rl,
                       p_ler_id               =>p_ler_id,
                       p_pl_typ_id            =>p_pl_typ_id,
                       p_assignment_id        =>p_assignment_id,
                       p_acty_base_rt_id      =>p_acty_base_rt_id,
                       p_business_group_id    =>p_business_group_id,
                       p_organization_id      =>p_organization_id,
                       p_jurisdiction_code    =>p_jurisdiction_code,
                       p_effective_date       =>p_effective_date);
            --
            begin
              --
              -- convert return value to code
              --
              l_pct_val:=l_outputs(l_outputs.first).value;
              --
            exception
              --
              when others then
                if g_debug then
                  hr_utility.set_location('BEN_92311_FORMULA_VAL_PARAM',15);
                end if;
                fnd_message.set_name('BEN','BEN_92311_FORMULA_VAL_PARAM');
                fnd_message.set_token('PROC',l_proc);
                fnd_message.set_token('FORMULA',p_rec.prtl_mo_prortn_rl);
                fnd_message.set_token('PARAMETER',
                                      l_outputs(l_outputs.first).name);
                fnd_message.raise_error;
              --
            end;
            --
          end if;
        else
          l_pct_val:=p_rec.pct_val;
        end if;
        --
        -- Now we have the pct_val compute the amount.
        --
        if g_debug then
          hr_utility.set_location('l_pct_val '||l_pct_val,5);
        end if;
        if g_debug then
          hr_utility.set_location('p_amt '||p_amt,5);
        end if;
        if l_pct_val = 100 then
         --
          p_prorate_flag := 'N';
          l_return_amt:=p_amt;
          --
        else
         --
          l_prorated_amt:=p_amt*l_pct_val/100;
        if g_debug then
          hr_utility.set_location('l_prorated_amt '||l_prorated_amt,5);
        end if;
      --
      --end if;
      -- Now we have the prorated value, do the rounding
      --
        if (p_rec.rndg_cd is not null or
            p_rec.rndg_rl is not null) and
           l_prorated_amt is not null then
         --
         l_return_amt := benutils.do_rounding
          (p_rounding_cd    => p_rec.rndg_cd,
           p_rounding_rl    => p_rec.rndg_rl,
           p_value          => l_prorated_amt,
           p_effective_date => p_effective_date);
         --
        elsif p_amt<>0 and
              p_amt is not null then
          --
          -- for now later do based on currency precision.
          --
          l_return_amt:=round(l_prorated_amt,2);
        else
          l_return_amt:=nvl(l_prorated_amt,0);
        end if;
        l_was_rounded:=true;
        p_prorate_flag:='Y';
        --
        end if; -- pct_val = 100 -- Bug 5515166
      end if; --proration not found
      --
    end if; -- prorate method
  elsif p_prtl_mo_det_mthd_cd='WASHRULE' then
    if (  p_start_or_stop_cd='STRT' and
          to_number(to_char(p_start_or_stop_date,'DD')) > p_wsh_rl_dy_mo_num)
       or
       (  p_start_or_stop_cd='STP' and
          to_number(to_char(p_start_or_stop_date,'DD')) < p_wsh_rl_dy_mo_num)
    then
      p_prorate_flag := 'Y';
      l_return_amt:=0;
    else
      p_prorate_flag := 'Y';
      l_return_amt:=p_amt;
    end if;
    if g_debug then
      hr_utility.set_location('p_start_or_stop_cd '||p_start_or_stop_cd,5);
      hr_utility.set_location('p_start_or_stop_date '||p_start_or_stop_date,5);
      hr_utility.set_location('p_wsh_rl_dy_mo_num '||p_wsh_rl_dy_mo_num,5);
      hr_utility.set_location('p_prorate_flag '||p_prorate_flag,5);
      hr_utility.set_location('l_return_amt '||l_return_amt,5);
    end if;
  else
    --
    -- unsupported code error out
    --
    if g_debug then
      hr_utility.set_location('BEN_92348_UNKNOWN_PRTN_DET_CD',15);
    end if;
    fnd_message.set_name('BEN', 'BEN_92348_UNKNOWN_PRTN_DET_CD');
    fnd_message.set_token('PROC',l_proc);
    fnd_message.set_token('PRTL_MO_DET_MTHD_CD',p_prtl_mo_det_mthd_cd);
    fnd_message.raise_error;
  end if;
  --
  if (p_rndg_cd is not null or
     p_rndg_rl is not null) and
     l_was_rounded=false and
     l_return_amt<>0 and
     l_return_amt is not null then
    --
    l_return_amt := benutils.do_rounding
     (p_rounding_cd    => p_rndg_cd,
      p_rounding_rl    => p_rndg_rl,
      p_value          => l_return_amt,
      p_effective_date => p_effective_date);
  end if;
  if g_debug then
    hr_utility.set_location('Leaving:' ||l_proc,80);
  end if;
  --
  -- just to be neat, always exit here
  --
  return l_return_amt;
  --
end prorate_amount;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< get_link >--------------------------------|
-- ----------------------------------------------------------------------------
-- This is the process that gets the Element link for the EE contribution
-- of the element for which the acty_base_rt is for.
--
procedure get_link
  (p_assignment_id     in number
  ,p_element_type_id   in number
  ,p_business_group_id in number
  ,p_input_value_id    in number
  ,p_effective_date    in date
  --
  ,p_element_link_id   out nocopy number
  )
is
  --
  l_proc           varchar2(75) := g_package || 'Get_link';
  --
  l_hv             pls_integer;
  --
  l_elk_count      pls_integer;
  --
  l_link_count     pls_integer;
  --
  l_joincond       boolean;
  --
  l_dummy          varchar2(1);
  --
  cursor c_getasgdets
    (c_asg_id   number
    ,c_eff_date date
    )
  is
     select asg.business_group_id,
            asg.payroll_id,
            asg.job_id,
            asg.grade_id,
            asg.position_id,
            asg.organization_id,
            asg.location_id,
            asg.pay_basis_id,
            asg.employment_category
     from per_all_assignments_f asg
     where asg.assignment_id = c_asg_id
     and   c_eff_date
       between asg.effective_start_date and asg.effective_end_date;
  --
  l_getasgdets c_getasgdets%rowtype;
  --
  cursor c_getelkdets
    (c_elt_id   number
    ,c_eff_date date
    )
  is
     select elk.element_link_id,
            elk.business_group_id,
            elk.element_type_id,
            elk.payroll_id,
            elk.link_to_all_payrolls_flag,
            elk.job_id,
            elk.grade_id,
            elk.position_id,
            elk.organization_id,
            elk.location_id,
            elk.pay_basis_id,
            elk.employment_category,
            elk.people_group_id
     from pay_element_links_f elk
     where elk.element_type_id = c_elt_id
     and   c_eff_date
       between elk.effective_start_date and elk.effective_end_date;
  --
  cursor c_chkalu
    (c_asg_id   number
    ,c_elk_id   number
    ,c_eff_date date
    )
  is
    select null
    from   pay_assignment_link_usages_f alu
    where  alu.assignment_id = c_asg_id
    and  alu.element_link_id = c_elk_id
    and  c_eff_date
      between alu.effective_start_date and alu.effective_end_date;
  --
  cursor c_getelk
    (c_asg_id   number
    ,c_elt_id   number
    ,c_eff_date date
    )
  is
     select el.element_link_id
     from   per_all_assignments_f asg,
            pay_element_links_f el
     where  asg.assignment_id = c_asg_id
       and  el.business_group_id = asg.business_group_id
       and  el.element_type_id   = c_elt_id
       and  c_eff_date
         between asg.effective_start_date and asg.effective_end_date
       and  c_eff_date
         between el.effective_start_date and el.effective_end_date
       and
            (
            (el.payroll_id is not null and
              el.payroll_id = asg.payroll_id)
        or  (el.link_to_all_payrolls_flag = 'Y' and
              asg.payroll_id is not null)
        or  (el.payroll_id is null and
              el.link_to_all_payrolls_flag = 'N')
            )
       and  (el.job_id is null or
             el.job_id = asg.job_id)
       and  (el.grade_id is null or
             el.grade_id = asg.grade_id)
       and  (el.position_id is null or
             el.position_id = asg.position_id)
       and  (el.organization_id is null or
             el.organization_id = asg.organization_id)
       and  (el.location_id is null or
             el.location_id = asg.location_id)
       and  (el.pay_basis_id is null or
             el.pay_basis_id = asg.pay_basis_id)
       and  (el.employment_category is null or
             el.employment_category = asg.employment_category)
       and  (el.people_group_id is null or exists
               (select null
                from   pay_assignment_link_usages_f alu
                where  alu.assignment_id = asg.assignment_id
                  and  alu.element_link_id = el.element_link_id
                  and  c_eff_date between alu.effective_start_date
                                          and alu.effective_end_date)
            )
;

begin
  --
  g_debug := hr_utility.debug_enabled;
  if g_debug then
  --
    hr_utility.set_location('Entering:' ||l_proc,5);
    hr_utility.set_location('p_assignment_id:' ||p_assignment_id,44333);
    hr_utility.set_location('p_element_type_id:' ||p_element_type_id,44333);
    hr_utility.set_location('p_business_group_id:' ||p_business_group_id,44333);
    hr_utility.set_location('p_input_value_id:' ||p_input_value_id,44333);
    hr_utility.set_location('p_effective_date:' ||p_effective_date,44333);
    --
  end if;
  --
  if g_get_link_cached > 0 then
    --
    begin
      --
      l_hv := mod(nvl(p_assignment_id,1)
                 +nvl(p_element_type_id,2)
                 +nvl(p_effective_date-hr_api.g_sot,3)
                 ,ben_hash_utility.get_hash_key);
      --
      if nvl(g_get_link_cache(l_hv).assignment_id,-1) = nvl(p_assignment_id,-1)
        and nvl(g_get_link_cache(l_hv).element_type_id,-1) = nvl(p_element_type_id,-1)
        and nvl(g_get_link_cache(l_hv).session_date,hr_api.g_sot) = nvl(p_effective_date,hr_api.g_sot)
      then
        --
        p_element_link_id := g_get_link_cache(l_hv).element_link_id;
        return;
        --
      else
        --
        l_hv := l_hv+g_hash_jump;
        --
        loop
          --
          if nvl(g_get_link_cache(l_hv).assignment_id,-1) = nvl(p_assignment_id,-1)
            and nvl(g_get_link_cache(l_hv).element_type_id,-1) = nvl(p_element_type_id,-1)
            and nvl(g_get_link_cache(l_hv).session_date,hr_api.g_sot) = nvl(p_effective_date,hr_api.g_sot)
          then
            --
            exit;
            --
          else
            --
            l_hv := l_hv+g_hash_jump;
            --
          end if;
          --
        end loop;
        --
      end if;
      --
    exception
      when no_data_found then
        --
        l_hv := null;
        --
    end;
    --
  end if;
  --
  -- Initialize the out parameter.
  --
  p_element_link_id := null;
  --
  open c_getasgdets
    (c_asg_id   => p_assignment_id
    ,c_eff_date => p_effective_date
    );
  fetch c_getasgdets into l_getasgdets;
  if c_getasgdets%notfound then
    --
    close c_getasgdets;
    --
    fnd_message.set_name('BEN', 'BEN_93289_ASG_ABR_NOT_FOUND');
    fnd_message.set_token('ACTY_BASE_RT_NAME',g_acty_base_rt_name);
    fnd_message.set_token('EFFECTIVE_DATE',to_char(p_effective_date));
    if g_debug then
      hr_utility.set_location('ASG: BEN_93289_ASG_ABR_NOT_FOUND',5); -- 2105656
    end if;
    fnd_message.raise_error;
    --
  end if;
  if g_debug then
    hr_utility.set_location('c_getasgdets is not null',999);
  end if;
  close c_getasgdets;
  --
  l_elk_count := 0;
  l_joincond  := false;
  l_link_count := 0;
  --
  for elkrow in c_getelkdets
    (c_elt_id   => p_element_type_id
    ,c_eff_date => p_effective_date
    )
  loop
    --
    l_link_count := c_getelkdets%rowcount; -- bug 2105656
    --
    if l_getasgdets.business_group_id = elkrow.business_group_id
      and ((elkrow.payroll_id is not null and elkrow.payroll_id = l_getasgdets.payroll_id)
          or (elkrow.link_to_all_payrolls_flag = 'Y' and l_getasgdets.payroll_id is not null)
          or (elkrow.payroll_id is null and elkrow.link_to_all_payrolls_flag = 'N')
          )
      and
        (elkrow.job_id is null
        or elkrow.job_id = l_getasgdets.job_id
        )
      and
        (elkrow.grade_id is null
        or elkrow.grade_id = l_getasgdets.grade_id
        )
      and
        (elkrow.position_id is null
        or elkrow.position_id = l_getasgdets.position_id
        )
      and
        (elkrow.organization_id is null
        or elkrow.organization_id = l_getasgdets.organization_id
        )
      and
        (elkrow.location_id is null
        or elkrow.location_id = l_getasgdets.location_id
        )
      and
        (elkrow.pay_basis_id is null
        or elkrow.pay_basis_id = l_getasgdets.pay_basis_id
        )
      and
        (elkrow.employment_category is null
        or elkrow.employment_category = l_getasgdets.employment_category
        )
    then
      --
      l_joincond := true;
      --
    else
      --
      l_joincond := false;
      --
    end if;
    --
    if  (elkrow.people_group_id is null
        )
      and l_joincond
    then
      --
      l_joincond := true;
      --
    elsif l_joincond
    then
      --
      open c_chkalu
        (c_asg_id   => p_assignment_id
        ,c_elk_id   => elkrow.element_link_id
        ,c_eff_date => p_effective_date
        );
      fetch c_chkalu into l_dummy;
      if c_chkalu%found then
        --
        l_joincond := true;
        --
      else
        --
        l_joincond := false;
        --
      end if;
      close c_chkalu;
      --
    else
      --
      l_joincond := false;
      --
    end if;
    --
    if l_joincond then
      --
      p_element_link_id := elkrow.element_link_id;
      l_elk_count := l_elk_count+1;
      exit;
      --
    end if;
    --
  end loop;
  --
  if l_link_count = 0 then
    --
    fnd_message.set_name('BEN', 'BEN_92344_NO_ELEMENT_LINK');
    fnd_message.set_token('PROC',l_proc);
    fnd_message.set_token('ASSIGNMENT_ID',to_char(p_assignment_id));
    fnd_message.set_token('ELEMENT_TYPE_ID',to_char(p_element_type_id));
    fnd_message.set_token('EFFECTIVE_DATE',to_char(p_effective_date));
    if g_debug then
      hr_utility.set_location('ELK: BEN_92344_NO_ELEMENT_LINK',5);
    end if;
    --
  elsif l_elk_count = 0 then -- bug 2105656
    --
    fnd_message.set_name('BEN', 'BEN_93288_ASG_ELEM_LNK_INELIG');
    fnd_message.set_token('ASSIGNMENT_ID',to_char(p_assignment_id));
    fnd_message.set_token('ELEMENT_TYPE_ID',to_char(p_element_type_id));
    fnd_message.set_token('EFFECTIVE_DATE',to_char(p_effective_date));
    if g_debug then
      hr_utility.set_location('ELK: BEN_93288_ASG_ELEM_LNK_INELIG',6);
    end if;
    --
  elsif g_get_link_cached > 0 then
    --
    -- Only store the
    --
    l_hv := mod(nvl(p_assignment_id,1)
               +nvl(p_element_type_id,2)
               +nvl(p_effective_date-hr_api.g_sot,3)
               ,ben_hash_utility.get_hash_key
               );
    --
    while g_get_link_cache.exists(l_hv)
    loop
      --
      l_hv := l_hv+g_hash_jump;
      --
    end loop;
    --
    g_get_link_cache(l_hv).assignment_id   := p_assignment_id;
    g_get_link_cache(l_hv).element_type_id := p_element_type_id;
    g_get_link_cache(l_hv).session_date    := p_effective_date;
    g_get_link_cache(l_hv).element_link_id := p_element_link_id;
    --
  end if;
  --
  if g_debug then
    hr_utility.set_location('Leaving:' ||l_proc,5);
  end if;
  --
end get_link;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_future_entries >----------------------------|
-- ----------------------------------------------------------------------------
procedure chk_future_entries
(p_validate              in boolean,
 p_person_id             in number,
 p_assignment_id         in number,
 p_enrt_rslt_id          in number,
 p_element_type_id       in number,
 p_multiple_entries_flag in varchar2,
 p_effective_date        in date) is

  cursor c_future_ee
    (p_element_type_id in number
    ,p_assignment_id   in number
    ,p_effective_date  in date
    ) is
    select distinct
           elt.element_name,
           ele.element_entry_id,
           ele.effective_start_date,
           ele.effective_end_date,
           ele.object_version_number,
           ele.creator_id,
           ele.creator_type
     from  pay_element_entries_f ele,
           pay_element_links_f elk,
           pay_element_types_f elt
    where  ele.effective_start_date = (select min(ele2.effective_start_date)
                                       from pay_element_entries_f ele2
                                       where ele2.element_entry_id
                                    =  ele.element_entry_id)
      and  ele.effective_start_date > p_effective_date
      and  ele.assignment_id   = p_assignment_id
      and  nvl(ele.creator_id,-1) <> p_enrt_rslt_id
      and  ele.entry_type = 'E'
      and  ele.element_link_id = elk.element_link_id
      and  ele.effective_start_date between elk.effective_start_date
      and  elk.effective_end_date
      and  elk.element_type_id = p_element_type_id
      and  elt.element_type_id = elk.element_type_id
      and  elk.effective_start_date between elt.effective_start_date
      and  elt.effective_end_date
    order by ele.effective_start_date desc;
  l_future_ee_rec c_future_ee%rowtype;

  cursor c_chk_rt(p_person_id number,
                  p_element_entry_id  number) is
  select abr.name rt_name,
         prv.rt_strt_dt
    from ben_prtt_enrt_rslt_f pen,
         ben_prtt_rt_val prv,
         ben_acty_base_rt_f abr
   where pen.person_id = p_person_id
     and pen.prtt_enrt_rslt_id = prv.prtt_enrt_rslt_id
     and prv.prtt_rt_val_stat_cd is null
     and pen.prtt_enrt_rslt_stat_cd is null
     and abr.acty_base_rt_id = prv.acty_base_rt_id
     and prv.rt_strt_dt between abr.effective_start_date
     and abr.effective_end_date
     and prv.element_entry_value_id in
           (select elv.element_entry_value_id
              from pay_element_entry_values_f elv
             where elv.element_entry_id = p_element_entry_id);
  l_rt_rec c_chk_rt%rowtype;

  l_effective_start_date  date;
  l_effective_end_date    date;
  l_delete_warning        boolean;
  l_proc                  varchar2(72) := g_package||'chk_future_entries';

begin

  if g_debug then
    hr_utility.set_location('Entering:' ||l_proc,5);
  end if;
  --
  open c_future_ee(p_element_type_id,
                   p_assignment_id,
                   p_effective_date);
  loop
       fetch c_future_ee into l_future_ee_rec;
       if c_future_ee%notfound then
          exit;
       end if;

       if g_debug then
          hr_utility.set_location('future ee:'||l_future_ee_rec.element_entry_id,6);
          hr_utility.set_location('creator type:'||l_future_ee_rec.creator_type,6);
          hr_utility.set_location('creator id:'||l_future_ee_rec.creator_id,6);
       end if;

       if l_future_ee_rec.creator_type ='F' and
          l_future_ee_rec.creator_id is not null then
          --
          -- BEN entry in the future. Something is not right.
          -- If there is a valid prtt rt, throw error. otherwise zap the
          -- entry
          --
          open c_chk_rt(p_person_id,
                        l_future_ee_rec.element_entry_id);
          fetch c_chk_rt into l_rt_rec;
          if c_chk_rt%found then
             --
             close c_future_ee;
             close c_chk_rt;
             fnd_message.set_name('BEN','BEN_93448_FUTURE_BEN_ENTRY');
             fnd_message.set_token('P_RATE',l_rt_rec.rt_name);
             fnd_message.set_token('P_DATE',to_char(l_future_ee_rec.effective_start_date));
             fnd_message.raise_error;
             --
          end if;
          close c_chk_rt;
    py_element_entry_api.delete_element_entry
          (p_validate              =>p_validate
          ,p_datetrack_delete_mode =>hr_api.g_zap
          ,p_effective_date        =>l_future_ee_rec.effective_end_date
          ,p_element_entry_id      =>l_future_ee_rec.element_entry_id
          ,p_object_version_number =>l_future_ee_rec.object_version_number
          ,p_effective_start_date  =>l_effective_start_date
          ,p_effective_end_date    =>l_effective_end_date
          ,p_delete_warning        =>l_delete_warning);

       else
         --
         -- User created entry. Throw error
         --
         if p_multiple_entries_flag ='N' then
            close c_future_ee;
            fnd_message.set_name('BEN','BEN_93447_FUTURE_USER_ENTRY');
            fnd_message.set_token('P_DATE',to_char(l_future_ee_rec.effective_start_date));
            fnd_message.set_token('P_ELEMENT',l_future_ee_rec.element_name);
            fnd_message.raise_error;
         end if;
       end if;

  end loop;
  close c_future_ee;

  if g_debug then
    hr_utility.set_location('Leaving:' ||l_proc,10);
  end if;
  --
end chk_future_entries;
--
-- --------------------------------------------------------------------------
-- |------------------< create_enrollment_element >-------------------------|
-- --------------------------------------------------------------------------
-- This procedure is used for both creating and updating element entries
--
procedure create_enrollment_element
  (p_validate                  in     boolean default false
  ,p_calculate_only_mode       in     boolean default false
  ,p_person_id                 in     number
  ,p_acty_base_rt_id           in     number
  ,p_acty_ref_perd             in     varchar2
  ,p_rt_start_date             in     date
  ,p_rt                        in     number
  ,p_business_group_id         in     number
  ,p_effective_date            in     date
  ,p_cmncd_rt                  in     number  default null
  ,p_ann_rt                    in     number  default null
  ,p_prtt_rt_val_id            in     number  default null
  ,p_enrt_rslt_id              in     number  default null
  ,p_input_value_id            in     number  default null
  ,p_element_type_id           in     number  default null
  ,p_pl_id                     in     number  default null
  ,p_prv_object_version_number in out nocopy number
  ,p_element_entry_value_id   out nocopy number
  ,p_eev_screen_entry_value   out nocopy number
  )
is
  --
  cursor get_abr_info
    (c_acty_base_rt_id in number
    ,c_effective_date  in date
    )
  is
    select abr.prtl_mo_det_mthd_cd,
           abr.prtl_mo_det_mthd_rl,
           abr.wsh_rl_dy_mo_num,
           abr.prtl_mo_eff_dt_det_cd,
           abr.prtl_mo_eff_dt_det_rl,
           abr.rndg_cd,
           abr.rndg_rl,
           abr.ele_rqd_flag,
           abr.one_ann_pymt_cd,
           abr.entr_ann_val_flag,
           abr.use_calc_acty_bs_rt_flag,
           abr.acty_typ_cd,
           abr.input_va_calc_rl,
           abr.rt_typ_cd,
           abr.element_type_id,
           abr.input_value_id,
           abr.ele_entry_val_cd,
           abr.rt_mlt_cd,
           abr.parnt_chld_cd,
           abr.rcrrg_cd,
           abr.name
           -- bug 6441505
           ,abr.element_det_rl
    from   ben_acty_base_rt_f abr
    where  abr.acty_base_rt_id=c_acty_base_rt_id
      and  c_effective_date between abr.effective_start_date
      and abr.effective_end_date;
  --
  l_get_abr_info get_abr_info%rowtype;
  --
  cursor get_element_entry(p_element_link_id         in number
                          ,p_assignment_id           in number
                          ,p_enrt_rslt_id            in number
                          ,p_input_value_id          in number
                          ,p_element_entry_id        in number
                          ,p_effective_date  in date) is
    select ele.element_entry_id,
           ele.effective_start_date,
           ele.effective_end_date,
           ele.object_version_number,
           elv.element_entry_value_id
      from pay_element_entries_f ele,
           pay_element_entry_values_f elv
     where ele.element_link_id = p_element_link_id
       and ele.assignment_id   = p_assignment_id
       and (p_enrt_rslt_id is null or
            p_enrt_rslt_id = ele.creator_id)
       and (p_element_entry_id is null or
            p_element_entry_id = ele.element_entry_id)
       and p_effective_date between ele.effective_start_date
       and ele.effective_end_date
       and ele.entry_type = 'E'
       and elv.element_entry_id = ele.element_entry_id
       and elv.effective_start_date between ele.effective_start_date
       and ele.effective_end_date
       and elv.input_value_id = p_input_value_id;
  --
  cursor get_element_entry_v(p_element_entry_value_id in number
                            ,p_effective_date         in date) is
    select ele.element_entry_id,
           ele.effective_start_date,
           ele.effective_end_date,
           ele.object_version_number,
           elv.element_entry_value_id
      from pay_element_entries_f ele,
           pay_element_entry_values_f elv
     where p_effective_date between ele.effective_start_date
       and ele.effective_end_date
       and elv.element_entry_id = ele.element_entry_id
       and elv.element_entry_value_id = p_element_entry_value_id
       and elv.effective_start_date between ele.effective_start_date
       and ele.effective_end_date;
  --
  -- 5229941: Fetch MAX end_date of the Element Entry.
  cursor get_max_ee_end_dt(p_element_entry_id in number) is
    select max(ele.effective_end_date) max_ee_end_date
      from pay_element_entries_f ele
     where ele.element_entry_id = p_element_entry_id;
  --
  --
  cursor get_current_value
    (p_element_entry_id in number
    ,p_input_value_id   in number
    ,p_effective_date   in date
    )
  is
    select eev.screen_entry_value,
           ee.object_version_number,
           ee.creator_id,
           ee.creator_type,
           ee.effective_start_date,
           ee.effective_end_date
    from   pay_element_entry_values_f eev,
           pay_element_entries_f ee
    where  eev.element_entry_id = p_element_entry_id
    and    eev.input_value_id   = p_input_value_id
    and    p_effective_date between eev.effective_start_date
    and    eev.effective_end_date
    and    ee.element_entry_id=eev.element_entry_id
    and    p_effective_date between ee.effective_start_date
    and    ee.effective_end_date;
  --
  cursor c_ele_info(p_element_type_id  in number,
                   p_effective_date   in date) is
     select pet.element_name,
            pet.multiple_entries_allowed_flag,
            pet.processing_type
       from pay_element_types_f pet
      where pet.element_type_id = p_element_type_id
        and p_effective_date between pet.effective_start_date
            and pet.effective_end_date;
--
  cursor c_dup_prv(p_element_entry_value_id number,
                   p_rt_strt_dt  date) is
    select abr.name
      from ben_prtt_enrt_rslt_f pen,
           ben_acty_base_rt_f abr,
           ben_prtt_rt_val prv
     where prv.acty_base_rt_id <> p_acty_base_rt_id
       and prv.element_entry_value_id = p_element_entry_value_id
       and prv.prtt_rt_val_stat_cd is null
       and abr.acty_base_rt_id = prv.acty_base_rt_id
       and prv.rt_strt_dt between abr.effective_start_date
       and abr.effective_end_date
       --bug# 3307450 added rt end dt condition to take care of element fix script
       and prv.rt_end_dt > p_rt_strt_dt
       and pen.prtt_enrt_rslt_id = prv.prtt_enrt_rslt_id
       and pen.prtt_enrt_rslt_stat_cd is null
       and pen.person_id = p_person_id;
  --
  cursor c_dup_rslt(p_element_entry_id number,
                    p_rt_strt_dt       date) is
    select abr1.name
      from ben_prtt_enrt_rslt_f pen1,
           ben_prtt_enrt_rslt_f pen2,
           ben_acty_base_rt_f abr1,
           ben_prtt_rt_val prv1
     where pen2.prtt_enrt_rslt_id = p_enrt_rslt_id
       and pen1.prtt_enrt_rslt_id <> pen2.prtt_enrt_rslt_id
       and pen1.person_id = pen2.person_id
       and pen1.prtt_enrt_rslt_stat_cd is null
       and (nvl(pen1.pgm_id,-1) <> nvl(pen2.pgm_id,-1) or
            nvl(pen1.pl_id,-1) <> nvl(pen2.pl_id,-1) or
            nvl(pen1.oipl_id,-1) <> nvl(pen2.oipl_id,-1))
       and pen1.prtt_enrt_rslt_id = prv1.prtt_enrt_rslt_id
       and abr1.acty_base_rt_id = prv1.acty_base_rt_id
       and prv1.rt_strt_dt between abr1.effective_start_date
       and abr1.effective_end_date
       and p_rt_strt_dt between prv1.rt_strt_dt
       and prv1.rt_end_dt
       and prv1.prtt_rt_val_stat_cd is null
       and prv1.element_entry_value_id in
           (select pev.element_entry_value_id
              from pay_element_entry_values_f pev
             where pev.element_entry_id = p_element_entry_id);

  cursor c_future_ee
    (p_element_entry_id in number
    ,p_element_type_id  in number
    ,p_input_value_id   in number
    ,p_assignment_id    in number
    ,p_effective_date   in date
    ) is
    select ele.element_entry_id,
           ele.element_link_id,
           ele.effective_start_date,
           ele.effective_end_date,
           ele.object_version_number,
           elv.screen_entry_value
     from  pay_element_entries_f ele,
           pay_element_entry_values_f elv,
           pay_element_links_f elk
    where  ele.creator_id = p_enrt_rslt_id
      and  ele.creator_type = 'F'
      and  ele.entry_type = 'E'
      and  ele.effective_start_date > p_effective_date
      and  ele.element_entry_id <> p_element_entry_id
      and  elv.element_entry_id = ele.element_entry_id
      and  elv.input_value_id = p_input_value_id
      and  elv.effective_start_date between ele.effective_start_date
      and  ele.effective_end_date
      and  ele.assignment_id   = p_assignment_id
      and  ele.element_link_id = elk.element_link_id
      and  ele.effective_start_date between elk.effective_start_date
      and  elk.effective_end_date
      and  elk.element_type_id = p_element_type_id
    order by ele.effective_start_date asc;
  l_future_ee_rec c_future_ee%rowtype;
  --
  -- Bug 2386380 fix - added default value to decode function
  --
  cursor c_next_pay_periods
    (p_start_date in date
    ,p_end_date in date
    ,p_prtl_mo_eff_dt_det_cd in varchar2
    ,p_payroll_id in number
    )
  is
    select start_date,end_date
    from   per_time_periods
    where  payroll_id     = p_payroll_id
    and    decode(p_prtl_mo_eff_dt_det_cd,'DTPD',regular_payment_date,
                                          'PPED',end_date,
                                          'DTERND',regular_payment_date,
                                           end_date)
                 <= p_end_date
    and    decode(p_prtl_mo_eff_dt_det_cd,'DTPD',regular_payment_date,
                                          'PPED',end_date,
                                          'DTERND',regular_payment_date,
                                           end_date)
                  >= p_start_date
    order by start_date desc;
  --
  -- Bug 2386380 fix - Handling if p_prtl_mo_eff_dt_det_cd is DTERND
  --
  cursor c_pps_next_month
    (p_end_date in date
    ,p_prtl_mo_eff_dt_det_cd in varchar2
    ,p_payroll_id in number
    )
  is
    select start_date,end_date
    from   per_time_periods
    where  payroll_id     = p_payroll_id
    and    decode(p_prtl_mo_eff_dt_det_cd,'DTPD',regular_payment_date,
                                          'DTERND',regular_payment_date,
                                          'PPED',end_date,
                                           end_date)
                 > p_end_date
    order by start_date;
  --
  cursor c_last_pp_of_cal_year
    (p_payroll_id    in number
    ,p_rt_start_date in date
    )
  is
    select ptp.start_date,ptp.end_date
    from   per_time_periods ptp
    where  ptp.payroll_id = p_payroll_id
      and  ptp.end_date<=add_months(trunc(p_rt_start_date,'YYYY'),
                                    12)-1
    order by ptp.end_date desc;
  --
  cursor c_first_pp_after_start
    (p_payroll_id    in number
    ,p_rt_start_date in date
    )
  is
    select ptp.start_date,
           ptp.end_date
    from   per_time_periods ptp
    where  ptp.payroll_id = p_payroll_id
      and  ptp.start_date >  p_rt_start_date
    order by ptp.end_date asc;
  --
  cursor c_chk_abs_ler (c_per_in_ler_id  number,
                        c_effective_date date)  is
  select pil.per_in_ler_id,
         pil.lf_evt_ocrd_dt,
         pil.trgr_table_pk_id,
         ler.ler_id,
         ler.typ_cd
    from ben_per_in_ler pil,
         ben_ler_f ler
   where pil.per_in_ler_id = c_per_in_ler_id
     and ler.ler_id = pil.ler_id
     and c_effective_date between
         ler.effective_start_date and ler.effective_end_date;
  -- Parent rate information
  cursor c_abr2
    (c_effective_date in date,
     c_acty_base_rt_id in number
    )
  is
    select abr2.rt_mlt_cd,
           abr2.entr_ann_val_flag
    from   ben_acty_base_rt_f abr,
           ben_acty_base_rt_f abr2
    where  abr.acty_base_rt_id = c_acty_base_rt_id
    and    abr2.acty_base_rt_id = abr.parnt_acty_base_rt_id
    and    abr2.parnt_chld_cd = 'PARNT'
    and    c_effective_date
           between abr.effective_start_date
           and     abr.effective_end_date
    and    c_effective_date
           between abr2.effective_start_date
           and  abr2.effective_end_date;
  --
  cursor c_current_pp_end
    (p_payroll_id    in number
    ,p_rt_start_date in date
    )
  is
    select ptp.end_date
    from   per_time_periods ptp
    where  ptp.payroll_id = p_payroll_id
      and  p_rt_start_date between
            ptp.start_date and ptp.end_date ;
  --
  cursor c_current_fsa_pp_end
    (p_payroll_id    in number
    ,p_rt_start_date in date
    )
  is
    select nvl(ptp.regular_payment_date,ptp.end_date) end_date
           ,ptp.end_date ptp_end_date -- Bug 8985608
    from   per_time_periods ptp
    where  ptp.payroll_id = p_payroll_id
      and  p_rt_start_date between
            ptp.start_date and ptp.end_date ;

  l_ptp_end_date date; -- Bug 8985608

  --
  l_current_pp_end_date date ;
  --
  l_prnt_abr      c_abr2%rowtype ;
  --
  -- Bug 6834340
  -- to pass correct ler_id to the prorate_amount when subsequent life event
  -- offers no electability to the existing enrollments but rates get updated.
  --

  cursor c_ler_with_current_prv
    (p_prtt_rt_val_id in number
     , p_rt_start_date in date
     )
  is
     select ler.name name, ler.ler_id ler_id
     from   ben_prtt_rt_val prv,
	    ben_per_in_ler    pil,
	    ben_ler_f         ler
     where  prv.per_in_ler_id = pil.per_in_ler_id
     and    pil.ler_id = ler.ler_id
     and    prv.prtt_rt_val_id = p_prtt_rt_val_id
     and    prv.rt_strt_dt = p_rt_start_date;

   l_ler_with_current_prv c_ler_with_current_prv%rowtype;

   -- Bug 6834340
   --
   ----Bug 7196470
   cursor c_enrt_rt
   is
   SELECT ecr.enrt_rt_id
     FROM ben_enrt_rt ecr,
          ben_prtt_rt_val prv,
          ben_acty_base_rt_f abr
    WHERE prv.prtt_rt_val_id = ecr.prtt_rt_val_id
      AND prv.prtt_rt_val_stat_cd is NULL
      AND abr.acty_base_rt_id = prv.acty_base_rt_id
      AND ecr.acty_base_rt_id = prv.acty_base_rt_id
      AND prv.rt_strt_dt between abr.effective_start_date
      AND abr.effective_end_date
      AND prv.rt_end_dt > prv.rt_strt_dt
      AND ecr.business_group_id = p_business_group_id
      AND ecr.prtt_rt_val_id = p_prtt_rt_val_id
      AND ecr.acty_base_rt_id = p_acty_base_rt_id;
   l_enrt_rt_id         ben_enrt_rt.enrt_rt_id%type;

  ------------------Bug 8872583
  cursor c_chk_pay_periods(p_payroll_id number,p_date date)
  is
  SELECT *
    FROM per_time_periods ptp
   WHERE payroll_id = p_payroll_id
     AND p_date BETWEEN ptp.start_date AND ptp.end_date ;

  l_chk_pay_periods  c_chk_pay_periods%rowtype;
  l_bal_flag         varchar2(10) := 'N';
  ------------------Bug 8872583
  l_proc                  varchar2(72) := g_package||'create_enrollment_element';
  l_start_date            date;
  l_end_date              date;
  l_amt                   NUMBER;
  l_curr_val              NUMBER;
  l_curr_val_char         VARCHAR2(60);
  l_new_val               NUMBER;
  l_new_date              DATE;
  l_temp_val              NUMBER;
  l_assignment_id         NUMBER;
  l_payroll_id            NUMBER;
  l_element_entry_id      NUMBER;
  l_entry_value_id        NUMBER;
  l_element_link_id       NUMBER;
  l_old_element_link_id   number;
  l_ext_chg_evt_log_id    NUMBER;
  l_object_version_number NUMBER;
  l_ext_object_version_number NUMBER;
  l_prtn_flag             VARCHAR2(1):='N';
  l_effective_start_date  DATE;
  l_ee_effective_start_date DATE;
  l_ee_effective_end_date DATE;
  l_upd_mode              VARCHAR2(30);
  l_delete_warning        BOOLEAN;
  l_create_warning        BOOLEAN;
  l_update_warning        BOOLEAN;
  l_per_month_amt         number;
  l_per_pay_amt           number;
  l_prorated_monthly_amt  number;
  l_update_ee             boolean;
  l_zero_pp_date          date;
  l_special_pp_date       date;
  l_normal_pp_date        date;
  l_normal_pp_end_date    date;
  l_special_amt           number;
  l_outputs               ff_exec.outputs_t;
  l_organization_id       number;
  l_remainder             number;
  l_number_in_month       number;
  l_old_normal_pp_date    date;
  l_jurisdiction_code     varchar2(30);
  l_effective_end_date    date;
  l_last_pp_strt_dt       date;
  l_last_pp_end_dt        date;
  l_range_start           date;
  l_tmp_bool              boolean;
  l_pay_periods           number;
  l_first_pp_adjustment   number;
  l_rt_strt_dt            date := p_rt_start_date;
  l_real_num_periods      number;
  l_mlt_cd                varchar2(30);
  l_creee_calc_vals       g_calculated_values;
  l_v2dummy               varchar2(30);
  l_perd_cd               varchar2(30) := 'PP';
  l_annual_target         boolean      ;
  l_uom               varchar2(30);
  l_element_name          varchar2(80);
  l_processing_type       varchar2(30);
  l_multiple_entries_flag varchar2(1);
  l_recurring_entry       boolean := false;
  l_dummy_varchar2        varchar2(30) := hr_api.g_varchar2;
  l_creator_id            number;
  l_creator_type          varchar2(30);
  l_dummy_date            date;
  l_new_element_link_id   number;
  l_effective_date        date;
  l_element_term_rule_date date;
  l_element_link_end_date  date;
  l_out_date_not_required  date;
  l_encoded_message   varchar2(2000);
  l_app_short_name    varchar2(2000);
  l_message_name      varchar2(2000);
  l_per_in_ler_id         number;
  l_ler_id                number;
  l_absence_attendance_id number;
  l_subpriority           number;
  l_dummy                 varchar2(30);
  l_abs_ler               boolean := false;
  l_override_user_ent_chk varchar2(30) := 'N';
  l_string                varchar2(4000);
  l_err_code              varchar2(10);
  l_err_mesg              varchar2(2000);
  l_input_value_id1       number;
  l_sarec_dont_create     boolean := false ;
  l_calculate_only_mode   boolean := p_calculate_only_mode;
  l_prnt_ann_rt           varchar2(1):= 'N';
  l_abr_name              varchar2(240);
  l_inpval_tab            inpval_tab_typ;
  l_element_type_id       number;
  l_input_value_id        number;
  l_pl_id                 number;
  l_lf_evt_ocrd_dt        date;
  l_ler_typ_cd            varchar2(30);
  l_old_assignment_id     number;
  l_non_recurring_ee_id   number;
  l_max_ee_end_dt         DATE;
  l_ele_entry_val_cd      VARCHAR2(30);    -- Bug 5575402
  l_dummy_number	  number;
  l_old_asgn_id           number; -- for bug 6450363
  --
  -- Bug 2675486 to skip computation for SAREC when there is
  -- no change in the amount and within the same plan year
  --
  function keep_same_element(p_person_id         number,
                               p_assignment_id     number,
                               p_prtt_enrt_rslt_id number,
                               p_prtt_rt_val_id    number,
                               p_acty_base_rt_id   number,
                               p_ann_rt_val        number,
                               p_cmcd_rt_val       number,
                               p_rt_val            number,
                               p_rt_start_date     date,
                               p_mlt_cd            varchar2,
                               p_element_type_id   number, -- 5401779
                               p_input_value_id    number, -- 5401779
                               p_ele_entry_val_cd  varchar2) -- Bug 5575402
			       /*p_input_va_calc_rl  number,    --6716202
			       p_organization_id   number default null, -- 6716202
			       p_payroll_id        number default null)	-- 6716202 */
  return boolean is

     l_return         boolean := false ;
     l_yp_start_date  date;
     l_max_strt_dt    date;
     l_ee_id          number;
     l_old_assignment_id  number;
     l_fsa_ee_effective_end_date  date;
     l_fsa_element_entry_id       number;
     l_fsa_ovn                    number;
     l_effective_end_date    date;
-- Bug 6716202
    /* l_ext_inpval_tab              ben_element_entry.ext_inpval_tab_typ;
     l_inpval_tab                  ben_element_entry.inpval_tab_typ;
     l_jurisdiction_code           varchar2(30);
     l_subpriority                 number;*/
-- Bug 6716202
     cursor c_pen is
       select pgm_id,pl_id,oipl_id--,pl_typ_id,ler_id -- 6716202
       from ben_prtt_enrt_rslt_f pen
       where pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
       and   pen.prtt_enrt_rslt_stat_cd is null
       and   rownum = 1 ;
     l_pen       c_pen%rowtype;
     --
     cursor c_pl_popl_yr_period_current(cv_pl_id number,
                                        cv_effective_date date ) IS
      select   distinct yp.start_date
      from     ben_popl_yr_perd pyp, ben_yr_perd yp
      where    pyp.pl_id = cv_pl_id
      and      pyp.yr_perd_id = yp.yr_perd_id
      and      pyp.business_group_id = p_business_group_id
      and      cv_effective_date BETWEEN yp.start_date AND yp.end_date
      and      yp.business_group_id = p_business_group_id ;
     --
     cursor c_max_prv is
       select
       max(prv.rt_strt_dt) max_strt_dt
       from  ben_prtt_enrt_rslt_f pen,
             ben_prtt_rt_val prv
       where pen.person_id = p_person_id
       and   pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
       and   pen.prtt_enrt_rslt_stat_cd is null
       and   pen.prtt_enrt_rslt_id = prv.prtt_enrt_rslt_id
       and   prv.acty_base_rt_id   = p_acty_base_rt_id
       and   prv.prtt_rt_val_id    <> p_prtt_rt_val_id
       and   (p_mlt_cd <>  'SAREC' OR (p_mlt_cd = 'SAREC' and prv.rt_strt_dt   >= l_yp_start_date))
       and   prv.rt_end_dt    <  p_rt_start_date
       and   prv.prtt_rt_val_stat_cd is null ;
     --
     --sshetty: added this cursor to check if there are any
     -- mutliple rates with same element type
     --Reason for doing this check again here is to skip
     --this package totally as end enrollment call would
     --have updated the element entry with new temp (0)value
     --Skipping this call will ensure the right value in the
     --EE input value

     cursor c_dup_prv_chk (c_element_entry_id  number,
                 c_effective_date    date) is
   select  count(prv.prtt_enrt_rslt_id)
    from ben_prtt_rt_val prv
   where prv.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and prv.acty_base_rt_id <> p_acty_base_rt_id
     and prv.rt_end_dt > c_effective_date
     and prv.prtt_rt_val_stat_cd is null
     and prv.element_entry_value_id in
         (select pev.element_entry_value_id
            from pay_element_entry_values_f pev
           where pev.element_entry_id = c_element_entry_id);

     cursor c_prv is
       select pev.element_entry_value_id
       from  ben_prtt_enrt_rslt_f pen,
             ben_prtt_rt_val prv,
             pay_element_entry_values_f pev
       where pen.person_id = p_person_id
       and   pen.prtt_enrt_rslt_stat_cd is null
       and   pen.prtt_enrt_rslt_id = prv.prtt_enrt_rslt_id
       and   pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
       and   prv.mlt_cd            = 'SAREC'
       and   prv.acty_base_rt_id   = p_acty_base_rt_id
       and   prv.prtt_rt_val_id    <> p_prtt_rt_val_id
       and   prv.rt_strt_dt   = l_max_strt_dt
       and   prv.rt_end_dt    <  p_rt_start_date
       and   prv.prtt_rt_val_stat_cd is null
       and   prv.ann_rt_val = p_ann_rt_val
       and   pev.element_entry_value_id = prv.element_entry_value_id
       and   p_rt_start_date between pev.effective_start_date
       and   pev.effective_end_date ;
     --
     --BUG 3878539
     -- non fsa type rates.
     --
     cursor c_non_fsa_prv is
       select pev.element_entry_value_id
       from  ben_prtt_enrt_rslt_f pen,
             ben_prtt_rt_val prv,
             pay_element_entry_values_f pev
       where pen.person_id = p_person_id
       and   pen.prtt_enrt_rslt_stat_cd is null
       and   pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
       and   pen.prtt_enrt_rslt_id = prv.prtt_enrt_rslt_id
       and   prv.acty_base_rt_id   = p_acty_base_rt_id
       and   prv.prtt_rt_val_id    <> p_prtt_rt_val_id
       and   prv.rt_strt_dt   = l_max_strt_dt
       and   prv.rt_end_dt    <  p_rt_start_date
       and   prv.prtt_rt_val_stat_cd is null
       and   prv.ann_rt_val = p_ann_rt_val
       and   prv.rt_val     = p_rt_val
       and   prv.cmcd_rt_val = p_cmcd_rt_val
       and   pev.element_entry_value_id = prv.element_entry_value_id
       and   p_rt_start_date between pev.effective_start_date
       and   pev.effective_end_date ;
     --
     --bug#3364910
     --
     cursor c_old_asg is
     select pee.element_entry_id,
            pee.effective_end_date,
            pee.object_version_number,
            pee.assignment_id,
            pee.element_type_id,
            pev.input_value_id,
            abr.ele_entry_val_cd                -- Bug 5575402
      from pay_element_entries_f pee,
            pay_element_entry_values_f pev,
            ben_acty_base_rt_f abr
      where pev.element_entry_value_id = l_ee_id
        and pee.element_entry_id = pev.element_entry_id
        and pev.effective_start_date between pee.effective_start_date
        and pee.effective_end_date
        and abr.acty_base_rt_id = p_acty_base_rt_id
        and pev.effective_start_date between abr.effective_start_date
        and abr.effective_end_date
        and abr.element_type_id = pee.element_type_id
        and abr.input_value_id = pev.input_value_id
     order by pee.effective_end_date desc;

     cursor c_payroll_type_changed(
            cp_person_id number,
            cp_business_group_id number,
            cp_effective_date date,
            cp_orig_effective_date date
            ) is
        select pay.period_type
        from   per_all_assignments_f asg,
               pay_payrolls_f pay,
               per_all_assignments_f asg2,
               pay_payrolls_f pay2
        where  asg.person_id = cp_person_id
           and   asg.assignment_type <> 'C'
           and asg.business_group_id = cp_business_group_id
           and asg.primary_flag = 'Y'
           and cp_effective_date between
               asg.effective_start_date and asg.effective_end_date
           and pay.payroll_id=asg.payroll_id
           and pay.business_group_id = asg.business_group_id
           and cp_effective_date between
               pay.effective_start_date and pay.effective_end_date
           and asg2.person_id = cp_person_id
           and   asg2.assignment_type <> 'C'
           and asg2.business_group_id = cp_business_group_id
           and asg2.primary_flag = 'Y'
           and cp_orig_effective_date between
               asg2.effective_start_date and asg2.effective_end_date
           and pay2.payroll_id=asg2.payroll_id
           and pay2.business_group_id = asg2.business_group_id
           and cp_orig_effective_date between
               pay2.effective_start_date and pay2.effective_end_date
           and pay2.period_type<>pay.period_type
           and asg.assignment_type = asg2.assignment_type ;
    --
    l_period_type varchar2(300);
    l_old_element_type_id NUMBER; -- 5401779
    l_old_input_value_id NUMBER; -- 5401779
    l_old_ele_entry_val_cd varchar2(30);     -- Bug 5575402
    l_dup_rslt_num number;
    --

    -- Bug 6716202
    /*cursor c_element_entry_values(p_input_value_id number, p_element_entry_value_id number) is
       select  screen_entry_value,element_entry_value_id
         from  pay_element_entry_values_f pev
        where  pev.input_value_id = p_input_value_id
          and  pev.element_entry_value_id = p_element_entry_value_id
          and  p_rt_start_date between pev.effective_start_date
          and  pev.effective_end_date ;
      l_element_entry_values c_element_entry_values%ROWTYPE;

      cursor  c_get_input_value(p_prtt_rt_val_id number, p_rt_start_date date) is
      select  rt_val
        from  ben_prtt_rt_val prv
   	 where  prv.prtt_rt_val_id = p_prtt_rt_val_id
 	      and  p_rt_start_date between prv.rt_strt_dt
			and  prv.rt_end_dt;

      l_get_input_value NUMBER;*/

    -- Bug 6716202

    cursor c_element_entry_v(p_input_value_id number) is
      --
        select element_entry_id
         from  pay_element_entry_values_f pev
        where  pev.input_value_id = p_input_value_id
          and  l_max_strt_dt between pev.effective_start_date
          and  pev.effective_end_date ;
      --
	l_ext_inp_changed             boolean;
        l_element_entry_id	      pay_element_entry_values_f.element_entry_id%TYPE;
  begin
     --
     if g_debug then
       hr_utility.set_location('IN SAREC p_rt_start_date'||p_rt_start_date,122);
       hr_utility.set_location(' p_ann_rt_val '||p_ann_rt_val,122);
     end if;

     open c_pen ;
       fetch c_pen into l_pen;
     close c_pen;
     --
     open c_pl_popl_yr_period_current(l_pen.pl_id,p_rt_start_date);
       fetch c_pl_popl_yr_period_current into l_yp_start_date ;
     close c_pl_popl_yr_period_current ;
     --
     open c_max_prv ;
       fetch c_max_prv into l_max_strt_dt ;
     close c_max_prv ;
     --
     if g_debug then
       hr_utility.set_location('l_max_strt_dt '||l_max_strt_dt,122);
     end if;
     if p_mlt_cd = 'SAREC' then
       --
       open c_prv ;
       fetch c_prv into l_ee_id ;
       if c_prv%found then
          --
          --bug#3364910
          l_period_type:=null;
          open c_payroll_type_changed(
                     cp_person_id           =>p_person_id,
                     cp_business_group_id   =>p_business_group_id,
                     cp_effective_date      =>p_rt_start_date,
                     cp_orig_effective_date =>l_max_strt_dt);
          fetch c_payroll_type_changed into l_period_type;
          close c_payroll_type_changed;
          -- no change in payroll then update

          if l_ee_id is not null then
             open c_old_asg;
             fetch c_old_asg into
               l_fsa_element_entry_id,
               l_fsa_ee_effective_end_date,
               l_fsa_ovn,
               l_old_assignment_id,
               l_old_element_type_id,
               l_old_input_value_id,
               l_old_ele_entry_val_cd;     -- Bug 5575402
             close c_old_asg;

          end if;

          if l_ee_id is not null
           and l_period_type is null and
             nvl(p_assignment_id,-1) = nvl(l_old_assignment_id,-1)
             -- 5401779 : Return False if element_type or input_value changes
             and NVL(p_element_type_id, -1) = nvl(l_old_element_type_id,-1)
             and NVL(p_input_value_id, -1) = nvl(l_old_input_value_id, -1)
             and NVL(p_ele_entry_val_cd,'PP') = nvl(l_old_ele_entry_val_cd, 'PP')  -- Bug 5575402
             then
-- Bug 6716202

             -- We also need to check whether the input value has been changed or not,this was not supported before
             -- if input value has been changed in subsequent LE,the input value wont be updated from Std Rate which
             -- is not proper,so if input value has been changed then we should recompute
				 /*open c_element_entry_values(p_input_value_id,l_ee_id);
					fetch c_element_entry_values into l_element_entry_values;
				 close c_element_entry_values;

				 hr_utility.set_location('screen_entry_value '|| l_element_entry_values.screen_entry_value,34534);

				 open c_get_input_value(p_prtt_rt_val_id,p_rt_start_date);
				   fetch c_get_input_value into l_get_input_value;
				 close c_get_input_value;
				 --
				 hr_utility.set_location('l_get_input_value '|| l_get_input_value,34534);

	          if nvl(l_element_entry_values.screen_entry_value,-1) <> nvl(l_get_input_value,-1) then
	            return false;
	          end if;
             -- We should also need to check whether any extra input values have been changed or not,this was not supported before
             -- if input value has been changed in subsequent LE,the input value wont be updated from Rule which
             -- is not proper,so if extra input values have been changed then we should recompute

	          if p_input_va_calc_rl is not null then

	            ben_element_entry.get_extra_ele_inputs
						(p_effective_date         => p_rt_start_date
						,p_person_id              => p_person_id
						,p_business_group_id      => p_business_group_id
						,p_assignment_id          => p_assignment_id
						,p_element_link_id        => null
						,p_entry_type             => 'E'
						,p_input_value_id1        => null
						,p_entry_value1           => null
						,p_element_entry_id       => null
						,p_acty_base_rt_id        => p_acty_base_rt_id
						,p_input_va_calc_rl       => p_input_va_calc_rl
						,p_abs_ler                => null
						,p_organization_id        => p_organization_id
						,p_payroll_id             => p_payroll_id
						,p_pgm_id                 => l_pen.pgm_id
						,p_pl_id                  => l_pen.pl_id
						,p_pl_typ_id              => l_pen.pl_typ_id
						,p_opt_id                 => null
						,p_ler_id                 => l_pen.ler_id
						,p_dml_typ                => 'C'
						,p_jurisdiction_code      => l_jurisdiction_code
						,p_ext_inpval_tab         => l_ext_inpval_tab
						,p_subpriority            => l_subpriority
						);

               open c_element_entry_v (l_ext_inpval_tab(1).input_value_id);
                 fetch c_element_entry_v into l_element_entry_id;
               close c_element_entry_v;

               ben_element_entry.get_inpval_tab
                   (p_element_entry_id   => l_element_entry_id
                   ,p_effective_date     => l_max_strt_dt
                   ,p_inpval_tab         => l_inpval_tab);

               l_ext_inp_changed := false;

               for i in 1..l_ext_inpval_tab.count
                 loop
                   for j in 1..l_inpval_tab.count
                     loop
                       if (l_ext_inpval_tab(i).input_value_id =
                           l_inpval_tab(j).input_value_id) and
                            (nvl(l_ext_inpval_tab(i).return_value,'-1')  <>
                             nvl(l_inpval_tab(j).value,'-1')) then
                             l_ext_inp_changed := true;
                             exit;
                       end if;
                     end loop;
                     if l_ext_inp_changed then
                       exit;
                     end if;
                 end loop;

               if l_ext_inp_changed then
                 return not l_ext_inp_changed;
               end if;
             end if;*/

 -- Bug 6716202
            open c_dup_prv_chk (l_fsa_element_entry_id,
                           p_rt_start_date);
            fetch c_dup_prv_chk into l_dup_rslt_num;
            close c_dup_prv_chk;

            if l_dup_rslt_num > 0 then
             return false;
            end if;

            --
            p_prv_object_version_number := nvl(p_prv_object_version_number,
                                               l_prv_rec.object_version_number);

            ben_prtt_rt_val_api.update_prtt_rt_val
            (p_validate                => p_validate
            ,p_person_id               => p_person_id
            ,p_prtt_rt_val_id          => p_prtt_rt_val_id
            ,p_business_group_id       => p_business_group_id
            ,p_element_entry_value_id  => l_ee_id
            ,p_input_value_id          => p_input_value_id
            ,p_object_version_number   => p_prv_object_version_number
            ,p_effective_date          => p_rt_start_date
            );
            --
            l_return := true ;
            --
            -- reopen the entry if already ended
            --
            if l_fsa_element_entry_id is not null and
               l_fsa_ee_effective_end_date <> hr_api.g_eot and
               l_fsa_ee_effective_end_date <> l_element_term_rule_date and
               l_fsa_ee_effective_end_date <> l_element_link_end_date then

               begin

                 py_element_entry_api.delete_element_entry
                 (p_validate              =>p_validate
                 ,p_datetrack_delete_mode =>'FUTURE_CHANGE'
                 ,p_effective_date        =>l_fsa_ee_effective_end_date
                 ,p_element_entry_id      =>l_fsa_element_entry_id
                 ,p_object_version_number =>l_fsa_ovn
                 ,p_effective_start_date  =>l_effective_start_date
                 ,p_effective_end_date    =>l_effective_end_date
                 ,p_delete_warning        =>l_delete_warning);

              exception
                  when others then
                    ben_on_line_lf_evt.get_ser_message(l_encoded_message,
                                               l_app_short_name,
                                               l_message_name);
                    l_encoded_message := fnd_message.get;
                    --
                    if l_message_name like '%HR_6284_ELE_ENTRY_DT_ASG_DEL%' or
                       l_message_name like '%HR_7187_DT_CANNOT_EXTEND_END%' then
                       -- assignment is not eligible for link beyond this date.
                       -- Further reopening is not possible.
                       --
                       null;
                    else
                       if l_app_short_name is not null then
                          fnd_message.set_name(l_app_short_name,l_message_name);
                          fnd_message.raise_error;
                       else
                          raise;
                       end if;
                    end if;
              end;
            end if;
          end if;
          --
       end if;
       close c_prv ;
     else  -- NON SAREC case -- normal recurring elements
       hr_utility.set_location('Non SAREC else part before opening cursor ',545);
       open c_non_fsa_prv ;
       fetch c_non_fsa_prv into l_ee_id ;
       if c_non_fsa_prv%found then
          --
       --hr_utility.set_location('p_input_value_id '|| p_input_value_id,3453411);
          --bug#3364910
          l_period_type:=null;
          open c_payroll_type_changed(
                     cp_person_id           =>p_person_id,
                     cp_business_group_id   =>p_business_group_id,
                     cp_effective_date      =>p_rt_start_date,
                     cp_orig_effective_date =>l_max_strt_dt);
          fetch c_payroll_type_changed into l_period_type;
          close c_payroll_type_changed;
          -- no change in payroll then update

          if l_ee_id is not null then
             open c_old_asg;
             fetch c_old_asg into
               l_fsa_element_entry_id,
               l_fsa_ee_effective_end_date,
               l_fsa_ovn,
               l_old_assignment_id,
               l_old_element_type_id,
               l_old_input_value_id,
               l_old_ele_entry_val_cd;     -- Bug 5575402
             close c_old_asg;

          end if;

          if l_ee_id is not null
           and l_period_type is null and
             nvl(p_assignment_id,-1) = nvl(l_old_assignment_id,-1)
             -- 5401779 : Return False if element_type or input_value changes
             and NVL(p_element_type_id, -1) = nvl(l_old_element_type_id,-1)
             and NVL(p_input_value_id, -1) = nvl(l_old_input_value_id, -1)
             and NVL(p_ele_entry_val_cd,'PP') = nvl(l_old_ele_entry_val_cd, 'PP')  -- Bug 5575402
             then

          -- Bug 6716202
          --
          -- We also need to check whether the input value has been changed or not,this was not supported before
          -- if input value has been changed in subsequent LE,the input value wont be updated from Std Rate which
          -- is not proper,so if input value has been changed then we should recompute
	         /* open c_element_entry_values(p_input_value_id,l_ee_id);
	            fetch c_element_entry_values into l_element_entry_values;
	          close c_element_entry_values;

             hr_utility.set_location('screen_entry_value '|| l_element_entry_values.screen_entry_value,34534);

             open c_get_input_value(p_prtt_rt_val_id,p_rt_start_date);
	            fetch c_get_input_value into l_get_input_value;
	          close c_get_input_value;

          	 hr_utility.set_location('l_get_input_value '|| l_get_input_value,34534);

	          if nvl(l_element_entry_values.screen_entry_value,-1) <> nvl(l_get_input_value,-1) then
	            return false;
	          end if;
             -- We should also need to check whether any extra input values have been changed or not,this was not supported before
             -- if input value has been changed in subsequent LE,the input value wont be updated from Rule which
             -- is not proper,so if extra input values have been changed then we should recompute

	          if p_input_va_calc_rl is not null then

	            ben_element_entry.get_extra_ele_inputs
						(p_effective_date         => p_rt_start_date
						,p_person_id              => p_person_id
						,p_business_group_id      => p_business_group_id
						,p_assignment_id          => p_assignment_id
						,p_element_link_id        => null
						,p_entry_type             => 'E'
						,p_input_value_id1        => null
						,p_entry_value1           => null
						,p_element_entry_id       => null
						,p_acty_base_rt_id        => p_acty_base_rt_id
						,p_input_va_calc_rl       => p_input_va_calc_rl
						,p_abs_ler                => null
						,p_organization_id        => p_organization_id
						,p_payroll_id             => p_payroll_id
						,p_pgm_id                 => l_pen.pgm_id
						,p_pl_id                  => l_pen.pl_id
						,p_pl_typ_id              => l_pen.pl_typ_id
						,p_opt_id                 => null
						,p_ler_id                 => l_pen.ler_id
						,p_dml_typ                => 'C'
						,p_jurisdiction_code      => l_jurisdiction_code
						,p_ext_inpval_tab         => l_ext_inpval_tab
						,p_subpriority            => l_subpriority
						);

               open c_element_entry_v (l_ext_inpval_tab(1).input_value_id);
                 fetch c_element_entry_v into l_element_entry_id;
               close c_element_entry_v;

               ben_element_entry.get_inpval_tab
                   (p_element_entry_id   => l_element_entry_id
                   ,p_effective_date     => l_max_strt_dt
                   ,p_inpval_tab         => l_inpval_tab);

               l_ext_inp_changed := false;

					for i in 1..l_ext_inpval_tab.count
						loop
						  for j in 1..l_inpval_tab.count
						    loop

						      if (l_ext_inpval_tab(i).input_value_id =
								  l_inpval_tab(j).input_value_id) and
									(nvl(l_ext_inpval_tab(i).return_value,'-1')  <>
									 nvl(l_inpval_tab(j).value,'-1')) then
									   l_ext_inp_changed := true;
										exit;
								end if;
							 end loop;
							 if l_ext_inp_changed then
								exit;
							 end if;
						end loop;

               if l_ext_inp_changed then
                 return not l_ext_inp_changed;
               end if;
             end if;*/

             -- Bug 6716202

            open c_dup_prv_chk (l_fsa_element_entry_id,
                           p_rt_start_date);
            fetch c_dup_prv_chk into l_dup_rslt_num;
            close c_dup_prv_chk;

            if l_dup_rslt_num > 0 then
             return false;
            end if;
            --
            p_prv_object_version_number := nvl(p_prv_object_version_number,
                                               l_prv_rec.object_version_number);

            ben_prtt_rt_val_api.update_prtt_rt_val
            (p_validate                => p_validate
            ,p_person_id               => p_person_id
            ,p_prtt_rt_val_id          => p_prtt_rt_val_id
            ,p_business_group_id       => p_business_group_id
            ,p_element_entry_value_id  => l_ee_id
            ,p_input_value_id          => p_input_value_id
            ,p_object_version_number   => p_prv_object_version_number
            ,p_effective_date          => p_rt_start_date
            );
            --
            l_return := true ;
            --
            -- reopen the entry if already ended
            --
            if l_fsa_element_entry_id is not null and
               l_fsa_ee_effective_end_date <> hr_api.g_eot and
               l_fsa_ee_effective_end_date <> l_element_term_rule_date and
               l_fsa_ee_effective_end_date <> l_element_link_end_date then

               begin

                 py_element_entry_api.delete_element_entry
                 (p_validate              =>p_validate
                 ,p_datetrack_delete_mode =>'FUTURE_CHANGE'
                 ,p_effective_date        =>l_fsa_ee_effective_end_date
                 ,p_element_entry_id      =>l_fsa_element_entry_id
                 ,p_object_version_number =>l_fsa_ovn
                 ,p_effective_start_date  =>l_effective_start_date
                 ,p_effective_end_date    =>l_effective_end_date
                 ,p_delete_warning        =>l_delete_warning);

              exception
                  when others then
                    ben_on_line_lf_evt.get_ser_message(l_encoded_message,
                                               l_app_short_name,
                                               l_message_name);
                    l_encoded_message := fnd_message.get;
                    --
                    if l_message_name like '%HR_6284_ELE_ENTRY_DT_ASG_DEL%' or
                       l_message_name like '%HR_7187_DT_CANNOT_EXTEND_END%' then
                       -- assignment is not eligible for link beyond this date.
                       -- Further reopening is not possible.
                       --
                       null;
                    else
                       if l_app_short_name is not null then
                          fnd_message.set_name(l_app_short_name,l_message_name);
                          fnd_message.raise_error;
                       else
                          raise;
                       end if;
                    end if;
              end;
            end if;
          end if;
          --
       end if;
       close c_non_fsa_prv;
     end if;
     --
     return l_return ;
     --
  exception when others then
     if g_debug then
       hr_utility.set_location('in the exception ',122);
     end if;
     return false ;
  end keep_same_element ;
   --
begin
   g_debug := hr_utility.debug_enabled;
  if g_debug then
     hr_utility.set_location('Entering:' ||l_proc,5);
     hr_utility.set_location('p_prtt_rt_val_id=' ||p_prtt_rt_val_id,5);
     hr_utility.set_location('p_rt_start_date=' ||p_rt_start_date,5);
     hr_utility.set_location('p_enrt_rslt_id=' ||p_enrt_rslt_id,5);
     hr_utility.set_location('p_rt=' ||p_rt,5);
     hr_utility.set_location('p_element_type_id=' ||p_element_type_id,5);
     hr_utility.set_location('p_input_value_id=' ||p_input_value_id,5);
     hr_utility.set_location('p_acty_base_rt_id=' ||p_acty_base_rt_id,5);
     hr_utility.set_location('p_effective_date=' ||p_effective_date,5);
  end if;
  --BUG 3167959 We need to intialize the pl/sql table
  clear_ext_inpval_tab ;
  --
  g_creee_calc_vals := l_creee_calc_vals;
  l_amt := p_rt;
  --
  -- get prtt rt information
  --
  if p_prtt_rt_val_id is not null then
     open c_get_prtt_rt_val
       (c_prtt_rt_val_id => p_prtt_rt_val_id
       );
     fetch c_get_prtt_rt_val into l_prv_rec;
     if c_get_prtt_rt_val%notfound
     then
       --
       if g_debug then
         hr_utility.set_location('BEN_92103_NO_PRTT_RT_VAL',170);
       end if;
       close c_get_prtt_rt_val;
       --
       fnd_message.set_name('BEN', 'BEN_92103_NO_PRTT_RT_VAL');
       fnd_message.set_token('PROC',l_proc);
       fnd_message.set_token('PRTT_RT_VAL',to_char(p_prtt_rt_val_id));
       fnd_message.raise_error;
       --
     end if;
     close c_get_prtt_rt_val;
  end if;
  --
  -- check if abs ler
  --
  open c_chk_abs_ler
  (c_per_in_ler_id  => l_prv_rec.per_in_ler_id
  ,c_effective_date => p_effective_date
  );
  fetch c_chk_abs_ler into
    l_per_in_ler_id,
    l_lf_evt_ocrd_dt,
    l_absence_attendance_id,
    l_ler_id,
    l_ler_typ_cd;
  close c_chk_abs_ler;
  l_abs_ler := (nvl(l_ler_typ_cd,'xx') = 'ABS');
  --
  -- get activity base rate information
  --
  open get_abr_info
    (c_acty_base_rt_id => p_acty_base_rt_id
    ,c_effective_date  => greatest(nvl(l_lf_evt_ocrd_dt,l_rt_strt_dt),l_rt_strt_dt)
    );
  fetch get_abr_info into l_get_abr_info;
  if get_abr_info%notfound then
    close get_abr_info;
    if g_debug then
      hr_utility.set_location('BEN_91723_NO_ENRT_RT_ABR_FOUND',5);
    end if;
    fnd_message.set_name('BEN','BEN_91723_NO_ENRT_RT_ABR_FOUND');
    fnd_message.set_token('PROC',l_proc);
    fnd_message.set_token('ACTY_BASE_RT_ID',to_char(p_acty_base_rt_id));
    fnd_message.set_token('EFFECTIVE_DATE',to_char(p_effective_date));
    fnd_message.raise_error;
  end if;
  close get_abr_info;

  g_acty_base_rt_name := l_get_abr_info.name;
  l_element_type_id := nvl(p_element_type_id,l_get_abr_info.element_type_id);
  l_input_value_id := nvl(p_input_value_id,l_get_abr_info.input_value_id);
  l_ele_entry_val_cd := l_get_abr_info.ele_entry_val_cd;   -- Bug 5575402
  --
  -- For absences, for loading historical absence balances
  -- we need to continue in calculate_only_mode if an ele and inp val
  -- are attached.  inelg_action_cd stores the flag to decide historical
  -- load or not
  --
  if l_abs_ler and
     l_get_abr_info.element_type_id is not null and
     l_get_abr_info.input_value_id is not null then

     if g_param_rec.inelg_action_cd is null and
        benutils.g_benefit_action_id is not null then
        benutils.get_batch_parameters
        (benutils.g_benefit_action_id,
         g_param_rec);
     end if;

     if  nvl(g_param_rec.inelg_action_cd,'N') = 'N' then
         g_param_rec.inelg_action_cd := 'N';
         if l_get_abr_info.ele_rqd_flag='N' then
            if g_debug then
               hr_utility.set_location('Not historical abs loading ',124);
               hr_utility.set_location('Leaving: '||l_proc,124);
            end if;
            return;
         end if;
     else
         hr_utility.set_location('Historical abs loading ',124);
         l_calculate_only_mode := true;
     end if;
  elsif (l_get_abr_info.ele_rqd_flag='N' AND l_get_abr_info.element_det_rl is null) OR
        -- l_get_abr_info.element_type_id is null or
        -- l_get_abr_info.input_value_id is null then
        -- bug 6441505
        l_element_type_id is null or
        l_input_value_id is null then
     if g_debug then
        hr_utility.set_location('ele_rqd_flag=N',124);
        hr_utility.set_location('Leaving: '||l_proc,124);
     end if;
     return;
  end if;
  --
  -- Check for Current Assignment.
  --
  if  NOT (chk_assign_exists
             (p_person_id         => p_person_id
             ,p_business_group_id => p_business_group_id
             ,p_effective_date    => p_effective_date
             ,p_rate_date         => l_rt_strt_dt
             ,p_acty_base_rt_id   => p_acty_base_rt_id
             ,p_assignment_id     => l_assignment_id
             ,p_organization_id   => l_organization_id
             ,p_payroll_id        => l_payroll_id
             ))
  then
    --
    if g_debug then
      hr_utility.set_location('Create Benefits Assignment ',10);
    end if;
    --
    if not l_calculate_only_mode then
      --
      create_benefits_assignment
        (p_person_id         => p_person_id
        ,p_payroll_id        => l_payroll_id
        ,p_assignment_id     => l_assignment_id
        ,p_business_group_id => p_business_group_id
        ,p_organization_id   => l_organization_id
        ,p_effective_date    => l_rt_strt_dt
        );
      --
    end if;
    --
    -- After create get values back
    --
    l_tmp_bool:=chk_assign_exists
                  (p_person_id         => p_person_id
                  ,p_business_group_id => p_business_group_id
                  ,p_effective_date    => p_effective_date
                  ,p_rate_date         => l_rt_strt_dt
                  ,p_acty_base_rt_id   => p_acty_base_rt_id
                  ,p_assignment_id     => l_assignment_id
                  ,p_organization_id   => l_organization_id
                  ,p_payroll_id        => l_payroll_id
                  );
  --
  end if;
  if g_debug then
    hr_utility.set_location('l_assignment_id:'||l_assignment_id,50);
    hr_utility.set_location('l_payroll_id:'||l_payroll_id,50);
  end if;
  --
  -- Bug 2675486 For SAREC Code if the enrollment benefit amount has not
  -- changed and the old rate start is in the current yr period NO need
  -- to compute the element entries.
  --
  --
  -- get the eligible element link for the assignment and element type
  --
  get_link(p_assignment_id     => l_assignment_id
          ,p_element_type_id   => l_element_type_id
          ,p_business_group_id => p_business_group_id
          ,p_input_value_id    => l_input_value_id
          ,p_effective_date    => l_rt_strt_dt
          ,p_element_link_id   => l_element_link_id
          );
  if l_element_link_id is null then
     --
     -- error message already set on stack.
     --
     fnd_message.raise_error;
  end if;

  l_old_element_link_id := l_element_link_id;

  --
  -- determine if recurring entry or not
  --
  open c_ele_info(l_get_abr_info.element_type_id,l_rt_strt_dt);
  fetch c_ele_info into
    l_element_name,
    l_multiple_entries_flag,
    l_processing_type;
  close c_ele_info;

  l_recurring_entry := (nvl(l_processing_type,l_dummy_varchar2) <> 'N' and
      nvl(l_get_abr_info.rcrrg_cd,l_dummy_varchar2) <> 'ONCE');
  --
  -- get the term rule date and link end date for use later on
  --
  hr_entry.entry_asg_pay_link_dates (l_assignment_id,
                                     l_element_link_id,
                                     l_rt_strt_dt,
                                     l_element_term_rule_date,
                                     l_out_date_not_required,
                                     l_element_link_end_date,
                                     l_out_date_not_required,
                                     l_out_date_not_required);
  --
  -- if assignment not terminated, l_element_term_rule_date is
  -- populated with eot
  --
  -- Get the element entry id if it exists.
  -- If not found then that's ok. We will create a new one.
  -- If found, we will update provided it passes validation checks
  --

  -- Moved this code intentionally here.
  -- This is to address data corruption in an earlier version
  --
  l_mlt_cd := nvl(l_prv_rec.mlt_cd,l_get_abr_info.rt_mlt_cd);
  --
  -- Bug 5075200 - Rate with enter annual value is case similar to SAREC
  --               where we should not recreate element entries unless
  --               the annual value changes.
  --
-- if l_mlt_cd  = 'SAREC' OR
--     l_get_abr_info.entr_ann_val_flag = 'Y' /* Bug 5075200 */
--  then
 -- 5401779 - Can retain same element for both fsa and non_fsa plans, if the rt_val is same
 -- and the element_type and input_value are same.

  if g_debug then
    hr_utility.set_location('l_processing_type = '|| l_processing_type,8085);
  end if;

  --6643665 : Skip keep_same_element call for non-recurring element
  if l_processing_type <> 'N' then
     if keep_same_element(p_person_id       =>  p_person_id,
                          p_assignment_id    =>  l_assignment_id,
                          p_prtt_enrt_rslt_id=>  p_enrt_rslt_id,
                          p_prtt_rt_val_id   =>  p_prtt_rt_val_id,
                          p_acty_base_rt_id  =>  p_acty_base_rt_id,
                          p_ann_rt_val       =>  l_prv_rec.ann_rt_val,
                          p_cmcd_rt_val      =>  l_prv_rec.cmcd_rt_val,
                          p_rt_val           =>  p_rt,
                          p_rt_start_date    =>  l_rt_strt_dt,
                          p_mlt_cd           =>  l_mlt_cd,
                          p_element_type_id  =>  p_element_type_id,
                          p_input_value_id   =>  p_input_value_id,
                          p_ele_entry_val_cd =>  l_ele_entry_val_cd)   -- Bug 5575402
					  		     /*p_input_va_calc_rl =>  l_get_abr_info.input_va_calc_rl,
								  p_payroll_id       =>  l_payroll_id,
								  p_organization_id  =>  l_organization_id)*/
			   then
        --
        if g_debug then
          hr_utility.set_location('Leaving: Dont need to create the ee',123);
        end if;

        return;
        --
     end if ;
  end if; --6643665

--end if;
  --
  if l_prv_rec.element_entry_value_id is not null then

     open get_element_entry_v(l_prv_rec.element_entry_value_id
                         ,l_rt_strt_dt);
     fetch get_element_entry_v into
       l_element_entry_id,
       l_ee_effective_start_date,
       l_ee_effective_end_date,
       l_object_version_number,
       l_entry_value_id;
     close get_element_entry_v;
     --
     if g_debug then
       hr_utility.set_location('l_element_enrty_id='||l_element_entry_id,50);
       hr_utility.set_location('l_ee start_date='||l_ee_effective_start_date,50);
       hr_utility.set_location('l_ee end date='||l_ee_effective_end_date,50);
       hr_utility.set_location('l_entry_value_id='||l_entry_value_id,50);
     end if;

  end if;

  if not l_abs_ler or
     (l_abs_ler and l_multiple_entries_flag <> 'Y') then
     --
     if l_element_entry_id is null and
        l_recurring_entry then

        open get_element_entry(l_element_link_id
                              ,l_assignment_id
                              ,null
                              ,l_input_value_id
                              ,null
                              ,l_rt_strt_dt);
        fetch get_element_entry into
          l_element_entry_id,
          l_ee_effective_start_date,
          l_ee_effective_end_date,
          l_object_version_number,
          l_entry_value_id;
        close get_element_entry;
        --
        if g_debug then
          hr_utility.set_location('l_element_enrty_id='||l_element_entry_id,50);
          hr_utility.set_location('l_ee start_date='||l_ee_effective_start_date,50);
          hr_utility.set_location('l_ee end date='||l_ee_effective_end_date,50);
          hr_utility.set_location('l_entry_value_id='||l_entry_value_id,50);
        end if;

     end if;
     --
  end if;
  --
  -- Validate the entry to be used
  --
  if l_element_entry_id is not null then

     l_effective_start_date := l_ee_effective_start_date;
     l_effective_end_date := l_ee_effective_end_date;
     --
     --Check if entry value is already used by another prtt rt
     --
     open c_dup_prv(l_entry_value_id, l_rt_strt_dt);
     fetch c_dup_prv into l_abr_name;
     if c_dup_prv%found then
       --
       close c_dup_prv;
       fnd_message.set_name('BEN','BEN_92690_ELMNT_ALRDY_USD');
       fnd_message.set_token('P_RATE1',l_abr_name);
       fnd_message.set_token('P_RATE2',g_acty_base_rt_name);
       fnd_message.raise_error;
       --
     end if;
     close c_dup_prv;
     --
     --Check if entry is already used by another enrt rslt
     --
     open c_dup_rslt (l_element_entry_id,l_rt_strt_dt);
     fetch c_dup_rslt into l_abr_name;
     if c_dup_rslt%found then
       --
       close c_dup_rslt;
       fnd_message.set_name('BEN','BEN_93450_ELE_MULTIPLE_RSLT');
       fnd_message.set_token('P_RATE1',l_abr_name);
       fnd_message.set_token('P_RATE2',g_acty_base_rt_name);
       fnd_message.raise_error;
       --
     end if;
     close c_dup_rslt;

  end if;
  --
  -- handle any future entries
  --
  if not l_abs_ler and
     l_recurring_entry then
     chk_future_entries
    (p_validate              => p_validate,
     p_person_id             => p_person_id,
     p_assignment_id         => l_assignment_id,
     p_enrt_rslt_id          => p_enrt_rslt_id,
     p_element_type_id       => l_element_type_id,
     p_multiple_entries_flag => l_multiple_entries_flag,
     p_effective_date        => l_rt_strt_dt);
  end if;
  --
  -- reopen the entry if already ended
  --
  l_max_ee_end_dt := null;
  --
  -- 5229941 : Multiple Rates may update same Element, but different Input values.
  -- If the max ee end-date <> EOT, then dont delete EE in FUTURE_CHANGE mode
  -- as we want to retain the special/normal adjustment amounts of the first Input Value
  -- when we calculate the special/normal adjustment amounts for the second Input Value.
  --
  open get_max_ee_end_dt(l_element_entry_id);
  fetch get_max_ee_end_dt into l_max_ee_end_dt;
  close get_max_ee_end_dt;

  hr_utility.set_location('Max EE End Date '|| l_max_ee_end_dt, 9999);
  --
  if l_element_entry_id is not null and
     l_max_ee_end_dt <> hr_api.g_eot and -- 5229941
     l_ee_effective_end_date <> l_element_term_rule_date and
     l_ee_effective_end_date <> l_element_link_end_date then

     begin
     --
      hr_utility.set_location(' Deleting All Future Rows ', 9999);
      --
       py_element_entry_api.delete_element_entry
       (p_validate              =>p_validate
       ,p_datetrack_delete_mode =>'FUTURE_CHANGE'
       ,p_effective_date        =>l_ee_effective_end_date
       ,p_element_entry_id      =>l_element_entry_id
       ,p_object_version_number =>l_object_version_number
       ,p_effective_start_date  =>l_effective_start_date
       ,p_effective_end_date    =>l_effective_end_date
       ,p_delete_warning        =>l_delete_warning);

     exception
         when others then
           ben_on_line_lf_evt.get_ser_message(l_encoded_message,
                                      l_app_short_name,
                                      l_message_name);
           l_encoded_message := fnd_message.get;
           --
           if l_message_name like '%HR_6284_ELE_ENTRY_DT_ASG_DEL%' or
              l_message_name like '%HR_7187_DT_CANNOT_EXTEND_END%' then
              --
              -- assignment is not eligible for link beyond this date.
              -- Further reopening is not possible.
              --
              null;
           else
              if l_app_short_name is not null then
                 fnd_message.set_name(l_app_short_name,l_message_name);
                 fnd_message.raise_error;
              else
                 raise;
              end if;
           end if;
     end;

  end if;

  if l_get_abr_info.parnt_chld_cd = 'CHLD' then
     --
     open c_abr2 (p_effective_date, p_acty_base_rt_id);
     fetch c_abr2 into l_prnt_abr;
     if c_abr2%found then
       --
       if g_debug then
          hr_utility.set_location('parnt_chld_cd=CHLD',50);
          hr_utility.set_location('prnt rt mlt:'||l_prnt_abr.rt_mlt_cd,50);
          hr_utility.set_location('prnt entr ann:'||l_prnt_abr.entr_ann_val_flag,50);
       end if;
       if l_prnt_abr.rt_mlt_cd = 'SAREC' or
          l_prnt_abr.entr_ann_val_flag = 'Y' then
          l_prnt_ann_rt := 'Y';
       end if ;
       --
     end if;
     close c_abr2 ;
     --
  end if;
  --
  if nvl(g_result_rec.prtt_enrt_rslt_id,-1) <> p_enrt_rslt_id then
    open c_current_result_info
      (c_prtt_enrt_rslt_id  => p_enrt_rslt_id
      );
    fetch c_current_result_info into g_result_rec;
    close c_current_result_info;

    if g_debug then
      hr_utility.set_location('pen esd='||g_result_rec.effective_start_date,10);
      hr_utility.set_location('pen eed='||g_result_rec.effective_end_date,10);
    end if;

  end if;

  --
  -- Check the PRTL MONTH PRORATION rule
  -- against the effective date and payperiod
  -- of participants payroll.
  --
  -- ELE : By pass if the ele_entry_val_cd <> PP,EPP or null.
  --
  --
  if nvl(l_get_abr_info.ele_entry_val_cd, 'PP') = 'PP' or
         l_get_abr_info.ele_entry_val_cd = 'EPP' then
  --
  -- Get proper code from rule execution.
  --
    if l_get_abr_info.prtl_mo_eff_dt_det_cd = 'RL' and
       l_get_abr_info.prtl_mo_eff_dt_det_rl is not null then
      --
      -- exec rule and get code back
      --
      l_outputs:=benutils.formula
            (p_opt_id               => g_result_rec.opt_id,
             p_pl_id                => g_result_rec.pl_id,
             p_pgm_id               => g_result_rec.pgm_id,
             p_formula_id           => l_get_abr_info.prtl_mo_eff_dt_det_rl,
             p_ler_id               => g_result_rec.ler_id,
             p_pl_typ_id            => g_result_rec.pl_typ_id,
             p_assignment_id        => l_assignment_id,
             p_acty_base_rt_id      => p_acty_base_rt_id,
             p_business_group_id    => p_business_group_id,
             p_organization_id      => l_organization_id,
             p_jurisdiction_code    => l_jurisdiction_code,
             p_effective_date       => p_effective_date);
      --
      begin
        --
        -- convert return value to code
        --
        l_get_abr_info.prtl_mo_eff_dt_det_cd:=l_outputs(l_outputs.first).value;
        --
      exception
        --
        when others then
          if g_debug then
            hr_utility.set_location('BEN_92311_FORMULA_VAL_PARAM',30);
          end if;
          fnd_message.set_name('BEN','BEN_92311_FORMULA_VAL_PARAM');
          fnd_message.set_token('PROC',l_proc);
          fnd_message.set_token('FORMULA',l_get_abr_info.prtl_mo_det_mthd_rl);
          fnd_message.set_token('PARAMETER',
                               l_outputs(l_outputs.first).name);
          fnd_message.raise_error;
        --
      end;
    end if;
  -- ELE :
  end if;
  --
  -- ELE : By pass if the ele_entry_val_cd <> PP, EPP, or null.
  --
  if nvl(l_get_abr_info.ele_entry_val_cd, 'PP') = 'PP' or
         l_get_abr_info.ele_entry_val_cd = 'EPP' then
    --
    --
    -- When this flag is off, we do not annualize the rate value because it's
    -- just a 'multiple of' value.  Like the '3' in '3% of comp'
    --
    if l_get_abr_info.use_calc_acty_bs_rt_flag = 'N' then
      --
      if l_get_abr_info.rt_typ_cd = 'PERTEN' then
        -- divide the value by ten
        l_amt := l_amt/10;
      elsif l_get_abr_info.rt_typ_cd = 'PCT' or l_get_abr_info.rt_typ_cd = 'PERHNDRD' then
        -- divide the value by one hundred
        l_amt := l_amt/100;
      elsif l_get_abr_info.rt_typ_cd = 'PERTHSND' then
        -- divide by one thousand
        l_amt := l_amt/1000;
      elsif l_get_abr_info.rt_typ_cd = 'PERTTHSND' then
        -- divide by ten thousand
        l_amt := l_amt/10000;
      end if;  -- if MLT or null, leave value as is.
      --
      l_per_pay_amt := l_amt;
      --
    else
      --
      -- Annualize rate.
      --
      --  get plan year
      --
      if g_debug then
        hr_utility.set_location('Acty Ref Perd'||p_acty_ref_perd,10);
        hr_utility.set_location('prv_id= '|| p_prtt_rt_val_id,10);
        hr_utility.set_location('payroll= '|| l_payroll_id,10);
        hr_utility.set_location('bg= '|| p_business_group_id,10);
        hr_utility.set_location('rt_start= '|| l_rt_strt_dt,10);
      end if;
      --
      --Bug 3430334 we need to find the year period based on the
      --pay priod end date or check date to get the right plan
      --year period. Rate may start in the previous year period but
      --end of pay period may fall in the current pay period.
      --
      if l_get_abr_info.entr_ann_val_flag='Y' or
         l_prnt_ann_rt = 'Y' or
         l_mlt_cd = 'SAREC' then
        --
        open c_current_fsa_pp_end
          ( p_payroll_id   => l_payroll_id,
            p_rt_start_date=> l_rt_strt_dt );
        --
        fetch c_current_fsa_pp_end into l_current_pp_end_date,l_ptp_end_date;
        close c_current_fsa_pp_end ;
	hr_utility.set_location('l_current_pp_end_date '||l_current_pp_end_date,10);
	hr_utility.set_location('l_ptp_end_date '||l_ptp_end_date,10);

        /* Bug 8985608: If check payment date and pay period end date fall in different years
	   consider the greatest of the two values to get the plan year period*/
	if( trunc(l_current_pp_end_date,'YY') <> trunc(l_ptp_end_date,'YY') ) then
	  l_current_pp_end_date := greatest(l_current_pp_end_date,l_ptp_end_date);
	end if;
        --
      else
        --
        open c_current_pp_end
          ( p_payroll_id   => l_payroll_id,
            p_rt_start_date=> l_rt_strt_dt );
        fetch c_current_pp_end into l_current_pp_end_date ;
        close c_current_pp_end ;
        --
      end if;
      --
      if g_debug then
        hr_utility.set_location('l_current_pp_end_date '||l_current_pp_end_date,10);
      end if;
      l_pl_id := nvl(p_pl_id,g_result_rec.pl_id);
      if l_pl_id is not null then

         open c_plan_year_end_for_pl
           (c_pl_id                => l_pl_id
           ,c_rate_start_or_end_dt => nvl(l_current_pp_end_date,l_rt_strt_dt)
           );
         fetch  c_plan_year_end_for_pl into
                l_last_pp_strt_dt,
                l_last_pp_end_dt;
         close c_plan_year_end_for_pl;

      else
         open c_plan_year_end_for_pen
           (c_prtt_enrt_rslt_id    => p_enrt_rslt_id
           ,c_rate_start_or_end_dt => nvl(l_current_pp_end_date,l_rt_strt_dt)
           ,c_effective_date       => p_effective_date
           );
         fetch  c_plan_year_end_for_pen into
                  l_last_pp_strt_dt,
                  l_last_pp_end_dt;
         close c_plan_year_end_for_pen;

      end if;

      if l_get_abr_info.entr_ann_val_flag='Y' or
         l_prnt_ann_rt = 'Y' or
         l_mlt_cd = 'SAREC' then
        --l_range_start:=l_rt_strt_dt+1;
        --bug#2398448 and bug#2392732
        l_range_start:=l_rt_strt_dt;
      else
        --
        --Bug 3294702 We can safely take l_last_pp_strt_dt here.
        --
        --l_range_start:=add_months(l_last_pp_end_dt,-12) + 1;
        l_range_start:= l_last_pp_strt_dt ;
        --
      end if;
      --
      -- Bug2843979: Raising proper error if year period not found and
      -- elig_per_elctbl_chc_id is not populated in the ben_epe_cache
      --
      if l_last_pp_end_dt is null and
         ben_epe_cache.g_currepe_row.elig_per_elctbl_chc_id is null then
        --
        fnd_message.set_name('BEN','BEN_93368_DETERMINE_PAY_PERIOD');
        fnd_message.raise_error;
        --
      end if;
      --
      -- Bug 2149438
      if l_mlt_cd = 'SAREC' or
         l_prnt_ann_rt = 'Y' then
        --
	-----------Bug 8872583
	hr_utility.set_location('l_payroll_id : '|| l_payroll_id,20);
	l_bal_flag := 'N';
        open c_chk_pay_periods(l_payroll_id,l_lf_evt_ocrd_dt);
	fetch c_chk_pay_periods into l_chk_pay_periods;
	if c_chk_pay_periods%found then
	  hr_utility.set_location('l_chk_pay_periods.end_date : '|| l_chk_pay_periods.end_date,20);
	  if p_effective_date > l_chk_pay_periods.end_date then
	   ----Bug 7196470
	     open c_enrt_rt;
	     fetch c_enrt_rt into l_enrt_rt_id;
	     close c_enrt_rt;
	    l_bal_flag := 'Y';
          end if;
	end if;
	hr_utility.set_location('l_bal_flag : '|| l_bal_flag,20);
	-------------Bug 8872583
        l_amt:=ben_distribute_rates.period_to_annual
               (p_amount             => l_amt
	       ,p_enrt_rt_id         => l_enrt_rt_id--------Bug 7196470
               ,p_acty_ref_perd_cd   => p_acty_ref_perd
               ,p_business_group_id  => p_business_group_id
               ,p_effective_date     => l_rt_strt_dt
               ,p_complete_year_flag => 'N'
               ,p_use_balance_flag   => nvl(l_bal_flag,'N') ---Bug 8872583,'Y'-------'N'----Bug 7196470
               ,p_element_type_id    => l_element_type_id
               ,p_start_date         => l_range_start
               ,p_end_date           => l_last_pp_end_dt
               ,p_payroll_id         => l_payroll_id
               ,p_rounding_flag      => 'N'   --Bug 2149438
               );
        -- Moved the rounding from the bendisrt to handle differently.
        --
        l_amt := round(l_amt,4);
        --
      else
        --
        l_amt:=ben_distribute_rates.period_to_annual
               (p_amount             => l_amt
               ,p_acty_ref_perd_cd   => p_acty_ref_perd
               ,p_business_group_id  => p_business_group_id
               ,p_effective_date     => l_rt_strt_dt
               ,p_complete_year_flag => 'N'
               ,p_use_balance_flag   => 'N'
               ,p_element_type_id    => l_element_type_id
               ,p_start_date         => l_range_start
               ,p_end_date           => l_last_pp_end_dt
               ,p_payroll_id         => l_payroll_id
               );
        --
      end if;
      --
      -- Bug 2675486 To fix the temporary rounding issues not to get more than
      -- the annual amount
      --
      if g_debug then
        hr_utility.set_location('before l_amt '||l_amt,20);
      end if;
      --
      if (l_mlt_cd = 'SAREC' or l_prnt_ann_rt = 'Y') and
         l_amt > p_ann_rt then
         l_amt := p_ann_rt ;
      end if;
      --
      -- To do proration need monthly amount divide by 12.
      --
      l_per_month_amt := l_amt/12;
      if g_debug then
        hr_utility.set_location('p_ann_rt '||p_ann_rt,20);
        hr_utility.set_location('l_per_month_amt '||l_per_month_amt,20);
        hr_utility.set_location('l_amt '||l_amt,20);
      end if;
      --
      -- Compute per pay amt
      --
      if l_get_abr_info.ele_entry_val_cd = 'EPP' then
         l_perd_cd := 'EPP';
      end if;
      --
      if  l_get_abr_info.entr_ann_val_flag='Y' or
          l_mlt_cd = 'SAREC' or
          l_prnt_ann_rt = 'Y' then
          l_annual_target := true;
      end if;
      --
      l_per_pay_amt:=ben_distribute_rates.annual_to_period
                       (p_amount             =>l_amt
                       ,p_acty_ref_perd_cd   =>l_perd_cd
                       ,p_business_group_id  =>p_business_group_id
                       ,p_effective_date     =>l_rt_strt_dt
                       ,p_complete_year_flag =>'N'
                       ,p_use_balance_flag   =>'N'
                       ,p_element_type_id    => l_element_type_id
                       ,p_start_date         =>l_range_start
                       ,p_end_date           =>l_last_pp_end_dt
                       ,p_payroll_id         =>l_payroll_id
                       ,p_annual_target      =>l_annual_target
                       ,p_rounding_flag      =>'N'
                       );
      --
      if g_debug then
        hr_utility.set_location(' before rounding l_per_pay_amt '||l_per_pay_amt ,122);
      end if;
      if (l_get_abr_info.rndg_cd is not null
          or l_get_abr_info.rndg_rl is not null)
        and l_per_pay_amt is not null
      then
        --
        l_per_pay_amt := benutils.do_rounding
                           (p_rounding_cd    => l_get_abr_info.rndg_cd
                           ,p_rounding_rl    => l_get_abr_info.rndg_rl
                           ,p_value          => l_per_pay_amt
                           ,p_effective_date => l_rt_strt_dt
                           );
        --
      elsif l_per_pay_amt is not null
        and l_per_pay_amt<>0
      then
        --
        -- Do this for now: in future default to rounding for currency precision
        --
        l_per_pay_amt:=round(l_per_pay_amt,2);
        --
      end if;
      --
      if g_debug then
        hr_utility.set_location(' after round per_pay_periodamt '||l_per_pay_amt,103);
        hr_utility.set_location(' l_amt           ' || l_amt ,103);
        hr_utility.set_location(' entr_ann_val_flag ' || l_get_abr_info.entr_ann_val_flag,102);
      end if;
     -- bug#3443215 - rounding to annual amount is called for all the acty ref period
     /* if (l_get_abr_info.entr_ann_val_flag='Y' or
          p_acty_ref_perd = 'PYR' or
          l_mlt_cd = 'SAREC' or
          l_prnt_ann_rt = 'Y') and
     */
      if l_recurring_entry then

         if g_debug then
           hr_utility.set_location(' entrer in condition  ' ,102);
         end if;
        --
        -- need to match annual amount so adjust for
        -- rounding errors on annual basis by finding
        -- amount off and adding to first ee.
        -- Bug#2809677
        --
        if l_get_abr_info.entr_ann_val_flag='Y' or
           l_mlt_cd = 'SAREC' or
           l_prnt_ann_rt = 'Y' then
          --
          l_pay_periods:=ben_distribute_rates.get_periods_between(
                              p_acty_ref_perd_cd =>l_perd_cd --'PP'
                             ,p_start_date       =>l_range_start
                             ,p_end_date         =>l_last_pp_end_dt
                             ,p_payroll_id       =>l_payroll_id
                             ,p_business_group_id =>p_business_group_id
                             ,p_element_type_id  => l_element_type_id
                             ,p_effective_date   => p_effective_date
                             --bug#2556948
                             ,p_use_check_date    => true
                       );

        else
           --
           l_pay_periods:=ben_distribute_rates.get_periods_between(
                              p_acty_ref_perd_cd =>l_perd_cd --'PP'
                             ,p_start_date       =>l_range_start
                             ,p_end_date         =>l_last_pp_end_dt
                             ,p_payroll_id       =>l_payroll_id
                             ,p_business_group_id =>p_business_group_id
                             ,p_element_type_id  => l_element_type_id
                             ,p_effective_date   => p_effective_date
                              );
         end if;

        if g_debug then
          hr_utility.set_location(' l_pay_periods '||l_pay_periods ,122);
        end if;
        --
        -- Want amount we are under to be positive so we can
        -- add the amount to the first ee.
        --
        -- Bear in mind that this could be for acty_ref_perd = 'PYR' but
        -- entr_ann_val_flag = 'N' in which case the calculation needs
        -- to be adjusted.
        --
        if l_get_abr_info.entr_ann_val_flag = 'Y' or
           l_mlt_cd = 'SAREC' or
           l_prnt_ann_rt = 'Y' then
          --
          l_first_pp_adjustment:=l_amt - l_pay_periods * l_per_pay_amt;
          --
          if g_debug then
            hr_utility.set_location(' l_first_pp_adjustment '||l_first_pp_adjustment,122);
          end if;
          --
        else
          --
          -- Fix for WWBUG 1263111
          --
          -- We have to do a bit of adjusting here.
          --
          -- First get the real number of periods left.
          --
          if nvl(l_lf_evt_ocrd_dt,p_effective_date) < l_last_pp_end_dt then
            l_real_num_periods:=ben_distribute_rates.get_periods_between
              (p_acty_ref_perd_cd  =>l_perd_cd --PP'
              ,p_start_date        => l_rt_strt_dt --p_effective_date
              ,p_end_date          => l_last_pp_end_dt
              ,p_payroll_id        => l_payroll_id
              ,p_business_group_id => p_business_group_id
              ,p_element_type_id   => l_element_type_id
              ,p_effective_date    => nvl(l_lf_evt_ocrd_dt,p_effective_date));
          else
            l_real_num_periods:=ben_distribute_rates.get_periods_between
              (p_acty_ref_perd_cd  =>l_perd_cd --PP'
              ,p_start_date        => nvl(l_lf_evt_ocrd_dt,p_effective_date)
              ,p_payroll_id        => l_payroll_id
              ,p_business_group_id => p_business_group_id
              ,p_element_type_id   => l_element_type_id
              ,p_effective_date    => nvl(l_lf_evt_ocrd_dt,p_effective_date));
           end if;
          --
          l_first_pp_adjustment:= ((l_amt*l_real_num_periods)/l_pay_periods) - (l_real_num_periods * l_per_pay_amt);
          --
          -- End of Fix for WWBUG 1263111
          --
        end if;
        --
        if (l_get_abr_info.rndg_cd is not null or
           l_get_abr_info.rndg_rl is not null) and
           l_first_pp_adjustment is not null then
          l_first_pp_adjustment := benutils.do_rounding
           (p_rounding_cd    => l_get_abr_info.rndg_cd,
            p_rounding_rl    => l_get_abr_info.rndg_rl,
            p_value          => l_first_pp_adjustment,
            p_effective_date => l_rt_strt_dt);
        elsif l_first_pp_adjustment is not null and
              l_first_pp_adjustment<>0 then
          --
          -- Do this for now: in future default to rounding for currency precision
          --
          l_first_pp_adjustment:=round(l_first_pp_adjustment,2);
        end if;
        if g_debug then
          hr_utility.set_location('first pp adjustment='||l_first_pp_adjustment,10);
        end if;
        --
      end if;
      --
      if g_debug then
        hr_utility.set_location(' out nocopy of  condition  ' ,102);
      end if;
    end if;  -- use_calc_acty_base_rt_flag is 'Y'

    if l_get_abr_info.one_ann_pymt_cd is null
      and l_get_abr_info.use_calc_acty_bs_rt_flag = 'Y'
    then
      --
      if g_debug then
        hr_utility.set_location(' first  condition  ' ,102);
      end if;
      -- Prorate the rate, if necessary
      -- let prorate_amount function decide then either
      -- l_new_val is the same as l_amount, or not for proration.
      -- l_prtn_val will be set.
      --
      -- Don't prorate if it's 'one annual payment' or if we didn't calc rate yet.
      --
      if g_debug then
        hr_utility.set_location('Prorate the rate',20);
        hr_utility.set_location('l_per_month_amt '||l_per_month_amt,20);
      end if;
      --
      -- Bug 6834340
      open c_ler_with_current_prv(p_prtt_rt_val_id, p_rt_start_date);
      fetch c_ler_with_current_prv into l_ler_with_current_prv;
      close c_ler_with_current_prv;
      -- Bug 6834340
      --
      l_prorated_monthly_amt := prorate_amount
                                  (p_amt                   => l_per_month_amt
                                  ,p_acty_base_rt_id       => p_acty_base_rt_id
                                  ,p_prorate_flag          => l_prtn_flag
                                  ,p_effective_date        => l_rt_strt_dt
                                  ,p_start_or_stop_cd      => 'STRT'
                                  ,p_start_or_stop_date    => l_rt_strt_dt
                                  ,p_business_group_id     => p_business_group_id
                                  ,p_assignment_id         => l_assignment_id
                                  ,p_organization_id       => l_organization_id
                                  ,p_wsh_rl_dy_mo_num      => l_get_abr_info.wsh_rl_dy_mo_num
                                  ,p_prtl_mo_det_mthd_cd   => l_get_abr_info.prtl_mo_det_mthd_cd
                                  ,p_prtl_mo_det_mthd_rl   => l_get_abr_info.prtl_mo_det_mthd_rl
                                  ,p_person_id             => g_result_rec.person_id
                                  ,p_pgm_id                => g_result_rec.pgm_id
                                  ,p_pl_typ_id             => g_result_rec.pl_typ_id
                                  ,p_pl_id                 => g_result_rec.pl_id
                                  ,p_opt_id                => g_result_rec.opt_id
                                  ,p_ler_id                => l_ler_with_current_prv.ler_id  -- Bug 6834340
                                  ,p_jurisdiction_code     => l_jurisdiction_code
                                  ,p_rndg_cd               => l_get_abr_info.rndg_cd
                                  ,p_rndg_rl               => l_get_abr_info.rndg_rl
                                  );
      if g_debug then
        hr_utility.set_location('l_prorated_monthly_amt='||l_prorated_monthly_amt,123);
      end if;
      --
    else
       if g_debug then
         hr_utility.set_location(' else  condition  '|| l_get_abr_info.one_ann_pymt_cd  ,102);
       end if;
      l_prtn_flag:='N';
      if l_get_abr_info.one_ann_pymt_cd='LPPPYCFC' then
           l_normal_pp_date:=l_last_pp_strt_dt;
           l_normal_pp_end_date:=l_last_pp_end_dt;
      elsif l_get_abr_info.one_ann_pymt_cd='LPPCYCFC' then
          open c_last_pp_of_cal_year(l_payroll_id
                                    ,l_rt_strt_dt);
          loop
            fetch c_last_pp_of_cal_year into
              l_normal_pp_date,
              l_normal_pp_end_date;
            exit when c_last_pp_of_cal_year%notfound;
            hr_elements.check_element_freq(
              p_payroll_id           =>l_payroll_id,
              p_bg_id                =>p_business_group_id,
              p_pay_action_id        =>to_number(null),
              p_date_earned          =>l_normal_pp_date,
              p_ele_type_id          =>l_element_type_id,
              p_skip_element         =>g_skip_element
            );
            exit when g_skip_element='N';
          end loop;
          close c_last_pp_of_cal_year;
      elsif l_get_abr_info.one_ann_pymt_cd='FPPCFC' then
        open c_first_pp_after_start(l_payroll_id
                                   ,l_rt_strt_dt);
        loop
          fetch c_first_pp_after_start into
            l_normal_pp_date,
            l_normal_pp_end_date;
          exit when c_first_pp_after_start%notfound;
          hr_elements.check_element_freq(
            p_payroll_id           =>l_payroll_id,
            p_bg_id                =>p_business_group_id,
            p_pay_action_id        =>to_number(null),
            p_date_earned          =>l_normal_pp_date,
            p_ele_type_id          =>l_element_type_id,
            p_skip_element         =>g_skip_element
          );
          exit when g_skip_element='N';
        end loop;
        close c_first_pp_after_start;
      elsif l_get_abr_info.one_ann_pymt_cd is not null then
        --
        -- raise error as does not exist as lookup
        --
        if g_debug then
          hr_utility.set_location('BEN_91628_LOOKUP_TYPE_GENERIC',30);
        end if;
        fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
        fnd_message.set_token('FIELD','p_one_ann_pymt_cd');
        fnd_message.set_token('TYPE','BEN_ONE_ANN_PYMT');
        fnd_message.set_token('VALUE',l_get_abr_info.one_ann_pymt_cd);
        fnd_message.raise_error;
      end if;
    end if;

  -- ELE :
  end if;
  if g_debug then
    hr_utility.set_location(' out of if condition' ,102);
  end if;
  --
  -- Create the element entries
  --
  --
  -- Determine prorated first pay periods
  -- Where amount is not the normal per pay period amount
  --
  -- ELE : By pass if the ele_entry_val_cd <> PP, EPP, or null.
  --
  --
  if nvl(l_get_abr_info.ele_entry_val_cd, 'PP') = 'PP' or
         l_get_abr_info.ele_entry_val_cd = 'EPP' then
  --
    if l_prtn_flag = 'Y' then
      if g_debug then
        hr_utility.set_location('Determine proration ',40);
      end if;
      if g_debug then
        hr_utility.set_location('l_prorated_monthly_amt '||l_prorated_monthly_amt,40);
      end if;
      --
      -- Approach/algorithm to allocating payments:
      --
      -- In Starting a new rate there are three distinct rate stages
      -- 1) No pay periods - pay periods during which no rate should be in effect.
      -- 2) Special pay period - pay period during which a rate not equal to the normal rate
      --    is in effect.  Just one pay period.  Spreading them out is outside the scope
      --    of this version.
      -- 3) Normal pay periods - Periodic rate is in place.
      -----------------------------------------------------------
      --
      -- Want to find the pay periods from the start date
      -- ending at the last day of the month or earlier
      -- based on the date column specified by prtl_mo_eff_dt_det_cd
      --
      -- Go backwards and keep overwriting the dates with the most
      -- recent one to get the first date it changes to that rate.
      --
      l_remainder:=l_prorated_monthly_amt;
      l_number_in_month:=0;
      --
      for l_pay_periods in c_next_pay_periods(
          p_start_date            => l_rt_strt_dt,
          p_end_date              => add_months(
                                       trunc(l_rt_strt_dt,'mm'),1)-1,
          p_prtl_mo_eff_dt_det_cd => l_get_abr_info.prtl_mo_eff_dt_det_cd,
          p_payroll_id            => l_payroll_id) loop
          --
        hr_elements.check_element_freq(
          p_payroll_id           =>l_payroll_id,
          p_bg_id                =>p_business_group_id,
          p_pay_action_id        =>to_number(null),
          p_date_earned          =>l_pay_periods.start_date,
          p_ele_type_id          =>l_element_type_id,
          p_skip_element         =>g_skip_element
        );
        if g_debug then
          hr_utility.set_location('pay_start_date '||l_pay_periods.start_date,40);
          hr_utility.set_location('end_date '||l_pay_periods.end_date,40);
        end if;
        if g_skip_element='N' then
          l_number_in_month:=l_number_in_month+1;
          if l_remainder>l_per_pay_amt then
            if g_debug then
              hr_utility.set_location('l_per_pay_amt '||l_per_pay_amt,40);
            end if;
            --
            if l_rt_strt_dt > l_pay_periods.start_date then
              l_remainder := l_remainder-l_per_pay_amt;
              l_old_normal_pp_date:=l_normal_pp_date;
              l_normal_pp_date:=l_rt_strt_dt;
              exit;
            else
              --
              -- Normal pay period, may not be if have remainder left over
              --   In this case will revise date after loop is done
              --
              l_remainder:=l_remainder-l_per_pay_amt;
              l_old_normal_pp_date:=l_normal_pp_date;
              l_normal_pp_date:=l_pay_periods.start_date;
            end if;
          elsif l_remainder=0 then
            --
            -- Free pay period, no charge
            --
            l_zero_pp_date:=l_rt_strt_dt;
          else
            --
            -- Special small pay period, from here on it's free.
            --
            /* if l_zero_pp_date is null then
              l_special_pp_date:=l_rt_strt_dt;
            else */
            if l_rt_strt_dt <= l_pay_periods.start_date then
              l_special_pp_date:=l_pay_periods.start_date;
            else
              l_special_pp_date:=l_rt_strt_dt;
            end if;
            -- end if;
            if g_debug then
              hr_utility.set_location('l_special_pp_date '||l_special_pp_date,40);
              hr_utility.set_location('l_remainder '||l_remainder,40);
            end if;
            --
            l_special_amt:=l_remainder;
            l_remainder:=0;
          end if;
        end if;
      end loop;
      --
      -- Now check if loop was not entered
      --
      if l_number_in_month=0 then
        --
        -- This is the Large amount case
        -- where the full amount gets added to the first pp of next month
        --
        if g_debug then
          hr_utility.set_location('p_payroll_id'||l_payroll_id,10);
        end if;
        --
        open c_pps_next_month(
             p_end_date              => add_months(
                                        trunc(l_rt_strt_dt,'mm'),1)-1,
             p_prtl_mo_eff_dt_det_cd => l_get_abr_info.prtl_mo_eff_dt_det_cd,
             p_payroll_id            => l_payroll_id);
        loop
          fetch c_pps_next_month into l_start_date,l_end_date;
          if c_pps_next_month%notfound then
            close c_pps_next_month;
            if g_debug then
              hr_utility.set_location('BEN_92346_PAYROLL_NOT_DEFINED',30);
            end if;
            fnd_message.set_name('BEN', 'BEN_92346_PAYROLL_NOT_DEFINED');
            fnd_message.set_token('PROC',l_proc);
            fnd_message.raise_error;
          end if;
          hr_elements.check_element_freq(
            p_payroll_id           =>l_payroll_id,
            p_bg_id                =>p_business_group_id,
            p_pay_action_id        =>to_number(null),
            p_date_earned          =>l_start_date,
            p_ele_type_id          =>l_element_type_id,
            p_skip_element         =>g_skip_element
          );
          exit when g_skip_element='N';
        end loop;

	--Bug 5259022 Added the below validation
	--element entries overlap if the below validation is absent

	if l_start_date <= l_rt_strt_dt then
	    l_special_pp_date:= l_rt_strt_dt;
	else
	    l_special_pp_date:= l_start_date;
	end if;
	--End Bug 5259022

        l_special_amt:=l_remainder+l_per_pay_amt;
        --
        loop
          fetch c_pps_next_month into l_start_date,l_end_date;
          if c_pps_next_month%notfound then
            close c_pps_next_month;
            if g_debug then
              hr_utility.set_location('BEN_92346_PAYROLL_NOT_DEFINED',32);
            end if;
            fnd_message.set_name('BEN', 'BEN_92346_PAYROLL_NOT_DEFINED');
            fnd_message.set_token('PROC',l_proc);
            fnd_message.raise_error;
          end if;
          hr_elements.check_element_freq(
            p_payroll_id           =>l_payroll_id,
            p_bg_id                =>p_business_group_id,
            p_pay_action_id        =>to_number(null),
            p_date_earned          =>l_start_date,
            p_ele_type_id          =>l_element_type_id,
            p_skip_element         =>g_skip_element
          );
          exit when g_skip_element='N';
        end loop;
        close c_pps_next_month;
        l_normal_pp_date:= l_start_date;
       --
      elsif l_remainder>0 then
        --
        -- This is case where the first pp of the current month
        -- should be bigger because the prorated amount could
        -- not fit in the month with amounts <= per_pay_amt
        -- In this case there will be no zero pay periods
        -- The first normal pp is moved forward to the second one
        -- The special pp is set to the first normal one
        --
        l_special_pp_date:=l_normal_pp_date;
        l_special_amt:=l_remainder+l_per_pay_amt;
        l_normal_pp_date:=l_old_normal_pp_date;
      end if;
      --
      -- In the cases where a normal pp was not found then it
      -- must be the first pp of the next month
      --
      if l_normal_pp_date is null then
        open c_pps_next_month(
               p_end_date              => add_months(
                                          trunc(l_rt_strt_dt,'mm'),1)-1,
               p_prtl_mo_eff_dt_det_cd => l_get_abr_info.prtl_mo_eff_dt_det_cd,
               p_payroll_id            => l_payroll_id);
        loop
          fetch c_pps_next_month into l_start_date,l_end_date;
          if c_pps_next_month%notfound then
            close c_pps_next_month;
            if g_debug then
              hr_utility.set_location('BEN_92346_PAYROLL_NOT_DEFINED',34);
            end if;
            fnd_message.set_name('BEN', 'BEN_92346_PAYROLL_NOT_DEFINED');
            fnd_message.set_token('PROC',l_proc);
            fnd_message.raise_error;
          end if;
          hr_elements.check_element_freq(
            p_payroll_id           => l_payroll_id,
            p_bg_id                => p_business_group_id,
            p_pay_action_id        => to_number(null),
            p_date_earned          => l_start_date,
            p_ele_type_id          => l_element_type_id,
            p_skip_element         => g_skip_element
          );
          exit when g_skip_element='N';
        end loop;
        close c_pps_next_month;
        l_normal_pp_date:=l_start_date;
      end if;
    elsif l_normal_pp_date is null then
      if nvl(l_first_pp_adjustment,0) <> 0 then
        --
        l_special_amt:=l_per_pay_amt + l_first_pp_adjustment;
        --
        -- get first pp
        --
        l_special_pp_date := l_rt_strt_dt;
        --
        --
        -- BEGIN OF FIX FOR WWBUG 1402696
        --
        /*
        loop
          fetch c_first_pp_after_start into
            l_special_pp_date,
            l_dummy_date;
          exit when c_first_pp_after_start%notfound;
          hr_elements.check_element_freq(
            p_payroll_id           =>l_payroll_id,
            p_bg_id                =>p_business_group_id,
            p_pay_action_id        =>to_number(null),
            p_date_earned          =>l_normal_pp_date,
            p_ele_type_id          =>l_element_type_id,
            p_skip_element         =>g_skip_element
          );
          exit when g_skip_element='N';
        end loop;
        --
        */
        --
        -- END OF FIX FOR WWBUG 1402696
        --
        -- get second pp to start normal amounts
        --
        open c_first_pp_after_start(l_payroll_id
                                   ,l_rt_strt_dt);
        loop
          fetch c_first_pp_after_start into
            l_normal_pp_date,
            l_dummy_date;
          exit when c_first_pp_after_start%notfound;
          hr_elements.check_element_freq(
            p_payroll_id           =>l_payroll_id,
            p_bg_id                =>p_business_group_id,
            p_pay_action_id        =>to_number(null),
            p_date_earned          =>l_normal_pp_date,
            p_ele_type_id          =>l_element_type_id,
            p_skip_element         =>g_skip_element
          );
          exit when g_skip_element='N';
        end loop;
        close c_first_pp_after_start;
      else
        l_normal_pp_date:=l_rt_strt_dt;
      end if;
    end if;
  -- ELE :
  end if;

  -- Don't make unnecessary changes: compare old value to new one
  -- if ee already exists, if not compare to impossible number
  --
  if l_element_entry_id is not null then
    if g_debug then
      hr_utility.set_location('Updating if the rate has changed ',90);
    end if;
    l_update_ee:=true;
  else
    if g_debug then
      hr_utility.set_location('inserting mode ',90);
    end if;
    l_update_ee:=false;
    l_curr_val:=hr_api.g_number;
  end if;
  --
  -- Do the actual creates/updates to element entry
  --
  if g_debug then
    hr_utility.set_location('Determined rate changes ',41);
    hr_utility.set_location(' pp date  '|| l_zero_pp_date ,41);
  end if;

  if l_calculate_only_mode then
     if g_debug then
       hr_utility.set_location(' calc mode true '  ,41);
     end if;
  end if ;
  --
  -- ELE : By pass if the ele_entry_val_cd <> PP , EPP or null.
  --
  if nvl(l_get_abr_info.ele_entry_val_cd, 'PP') = 'PP'  or
          l_get_abr_info.ele_entry_val_cd = 'EPP' then
  --
    if l_zero_pp_date is not null
      and l_calculate_only_mode
    then
      --
      -- Set screen entry value out parameter to the special value
      --
      if g_debug then
        hr_utility.set_location('set secreen entry value ' ,42);
      end if;

      p_eev_screen_entry_value := l_per_pay_amt;
      --
    elsif l_zero_pp_date is not null and
          l_zero_pp_date <= least(l_element_term_rule_date,l_element_link_end_date)
    then
      --
      if g_debug then
        hr_utility.set_location('Determined rate changes ',41);
      end if;

      get_extra_ele_inputs
      (p_effective_date         => l_zero_pp_date
       ,p_person_id              => p_person_id
       ,p_business_group_id      => p_business_group_id
       ,p_assignment_id          => l_assignment_id
       ,p_element_link_id        => l_element_link_id
       ,p_entry_type             => 'E'
       ,p_input_value_id1        => null
       ,p_entry_value1           => 0
       ,p_element_entry_id       => null
       ,p_acty_base_rt_id        => p_acty_base_rt_id
       ,p_input_va_calc_rl       => l_get_abr_info.input_va_calc_rl
       ,p_abs_ler                => l_abs_ler
       ,p_organization_id        => l_organization_id
       ,p_payroll_id             => l_payroll_id
       ,p_pgm_id                 => g_result_rec.pgm_id
       ,p_pl_id                  => NVL(g_result_rec.pl_id,p_pl_id)
       ,p_pl_typ_id              => g_result_rec.pl_typ_id
       ,p_opt_id                 => g_result_rec.opt_id
       ,p_ler_id                 => l_ler_id
       ,p_dml_typ                => 'C'
       ,p_jurisdiction_code      => l_jurisdiction_code
       ,p_ext_inpval_tab         => g_ext_inpval_tab
       ,p_subpriority            => l_subpriority
       );

      --
      -- If free pay periods exist start/create ee
      --
      if l_update_ee then
        open get_current_value(l_element_entry_id,l_input_value_id,
                               l_zero_pp_date);
        --
        if g_debug then
          hr_utility.set_location('l_element_entry_id '||l_element_entry_id,10);
          hr_utility.set_location('l_input_value_id '||l_input_value_id,10);
          hr_utility.set_location('l_zero_pp_date '||l_zero_pp_date,10);
        end if;
        --
        fetch get_current_value into
          l_curr_val,
          l_object_version_number,
          l_creator_id,
          l_creator_type,
          l_ee_effective_start_date,
          l_ee_effective_end_date;
        if get_current_value%notfound then
          close get_current_value;
          if g_debug then
            hr_utility.set_location('BEN_92101_NO_RATE ',90);
          end if;
          fnd_message.set_name('BEN', 'BEN_92101_NO_RATE');
          fnd_message.set_token('PROC',l_proc);
          fnd_message.set_token('ELEMENT_ENTRY_ID',to_char(l_element_entry_id));
          fnd_message.set_token('INPUT_VALUE_ID',to_char(l_input_value_id));
          fnd_message.set_token('EFFECTIVE_DATE',to_char(l_zero_pp_date));
          fnd_message.set_token('ABR_NAME',l_get_abr_info.name); -- Bug 2519349
          fnd_message.raise_error;
        end if;
        close get_current_value;

          --
        if nvl(l_curr_val,0)<>0 then
          /*
             Before :-
               02-JAN-1994
                   |-A----------------------------------------------------->
                                                     ED

             After :-
               02-JAN-1994                    15-JUL-1994
                   |-A----------------------------|-B---------------------->
                                                     ED
          */
          l_upd_mode := get_ele_dt_upd_mode(l_zero_pp_date,
                                            l_element_entry_id);
          py_element_entry_api.update_element_entry
            (p_validate                      =>p_validate
            ,p_override_user_ent_chk         =>'Y'
            ,p_datetrack_update_mode         =>l_upd_mode
            ,p_effective_date                =>l_zero_pp_date
            ,p_business_group_id             =>p_business_group_id
            ,p_element_entry_id              =>l_element_entry_id
            ,p_object_version_number         =>l_object_version_number
            ,p_creator_type                  =>'F'
            ,p_creator_id                    =>p_enrt_rslt_id
            ,p_input_value_id1               =>g_ext_inpval_tab(1).input_value_id
            ,p_entry_value1                  =>g_ext_inpval_tab(1).return_value
            ,p_input_value_id2               =>g_ext_inpval_tab(2).input_value_id
            ,p_entry_value2                  =>g_ext_inpval_tab(2).return_value
            ,p_input_value_id3               =>g_ext_inpval_tab(3).input_value_id
            ,p_entry_value3                  =>g_ext_inpval_tab(3).return_value
            ,p_input_value_id4               =>g_ext_inpval_tab(4).input_value_id
            ,p_entry_value4                  =>g_ext_inpval_tab(4).return_value
            ,p_input_value_id5               =>g_ext_inpval_tab(5).input_value_id
            ,p_entry_value5                  =>g_ext_inpval_tab(5).return_value
            ,p_input_value_id6               =>g_ext_inpval_tab(6).input_value_id
            ,p_entry_value6                  =>g_ext_inpval_tab(6).return_value
            ,p_input_value_id7               =>g_ext_inpval_tab(7).input_value_id
            ,p_entry_value7                  =>g_ext_inpval_tab(7).return_value
            ,p_input_value_id8               =>g_ext_inpval_tab(8).input_value_id
            ,p_entry_value8                  =>g_ext_inpval_tab(8).return_value
            ,p_input_value_id9               =>g_ext_inpval_tab(9).input_value_id
            ,p_entry_value9                  =>g_ext_inpval_tab(9).return_value
            ,p_input_value_id10              =>g_ext_inpval_tab(10).input_value_id
            ,p_entry_value10                 =>g_ext_inpval_tab(10).return_value
            ,p_input_value_id11              =>g_ext_inpval_tab(11).input_value_id
            ,p_entry_value11                 =>g_ext_inpval_tab(11).return_value
            ,p_input_value_id12              =>g_ext_inpval_tab(12).input_value_id
            ,p_entry_value12                 =>g_ext_inpval_tab(12).return_value
            ,p_input_value_id13              =>g_ext_inpval_tab(13).input_value_id
            ,p_entry_value13                 =>g_ext_inpval_tab(13).return_value
            ,p_input_value_id14              =>g_ext_inpval_tab(14).input_value_id
            ,p_entry_value14                 =>g_ext_inpval_tab(14).return_value
            ,p_input_value_id15              =>l_input_value_id
            ,p_entry_value15                 =>0
            ,p_effective_start_date          =>l_effective_start_date
            ,p_effective_end_date            =>l_effective_end_date
            ,p_update_warning                =>l_update_warning
            );
          --
          -- write to the change event log
          --
          ben_ext_chlg.log_element_chg
            (p_action               => l_upd_mode
            ,p_amt                  => 0
            ,p_old_amt              => l_curr_val
            ,p_input_value_id       => l_input_value_id
            ,p_element_entry_id     => l_element_entry_id
            ,p_person_id            => p_person_id
            ,p_business_group_id    => p_business_group_id
            ,p_effective_date       => l_zero_pp_date
            );
          --
          -- update curr val to prevent unnecessary updates
          --
          l_curr_val:=0;
          l_creator_id := p_enrt_rslt_id;
          l_creator_type := 'F';
          --
        elsif nvl(l_creator_id,-1) <> p_enrt_rslt_id or
              nvl(l_creator_type,'-1') <> 'F' then

              l_upd_mode :=get_ele_dt_upd_mode(l_zero_pp_date,
                                               l_element_entry_id);
              py_element_entry_api.update_element_entry
                (p_validate                      =>p_validate
                ,p_datetrack_update_mode         =>l_upd_mode
                ,p_effective_date                =>l_zero_pp_date
                ,p_business_group_id             =>p_business_group_id
                ,p_element_entry_id              =>l_element_entry_id
                ,p_object_version_number         =>l_object_version_number
                ,p_override_user_ent_chk         => 'Y'
                ,p_creator_type                  =>'F'
                ,p_creator_id                    =>p_enrt_rslt_id
                ,p_input_value_id1               =>g_ext_inpval_tab(1).input_value_id
                ,p_entry_value1                  =>g_ext_inpval_tab(1).return_value
                ,p_input_value_id2               =>g_ext_inpval_tab(2).input_value_id
                ,p_entry_value2                  =>g_ext_inpval_tab(2).return_value
                ,p_input_value_id3               =>g_ext_inpval_tab(3).input_value_id
                ,p_entry_value3                  =>g_ext_inpval_tab(3).return_value
                ,p_input_value_id4               =>g_ext_inpval_tab(4).input_value_id
                ,p_entry_value4                  =>g_ext_inpval_tab(4).return_value
                ,p_input_value_id5               =>g_ext_inpval_tab(5).input_value_id
                ,p_entry_value5                  =>g_ext_inpval_tab(5).return_value
                ,p_input_value_id6               =>g_ext_inpval_tab(6).input_value_id
                ,p_entry_value6                  =>g_ext_inpval_tab(6).return_value
                ,p_input_value_id7               =>g_ext_inpval_tab(7).input_value_id
                ,p_entry_value7                  =>g_ext_inpval_tab(7).return_value
                ,p_input_value_id8               =>g_ext_inpval_tab(8).input_value_id
                ,p_entry_value8                  =>g_ext_inpval_tab(8).return_value
                ,p_input_value_id9               =>g_ext_inpval_tab(9).input_value_id
                ,p_entry_value9                  =>g_ext_inpval_tab(9).return_value
                ,p_input_value_id10              =>g_ext_inpval_tab(10).input_value_id
                ,p_entry_value10                 =>g_ext_inpval_tab(10).return_value
                ,p_input_value_id11              =>g_ext_inpval_tab(11).input_value_id
                ,p_entry_value11                 =>g_ext_inpval_tab(11).return_value
                ,p_input_value_id12              =>g_ext_inpval_tab(12).input_value_id
                ,p_entry_value12                 =>g_ext_inpval_tab(12).return_value
                ,p_input_value_id13              =>g_ext_inpval_tab(13).input_value_id
                ,p_entry_value13                 =>g_ext_inpval_tab(13).return_value
                ,p_input_value_id14              =>g_ext_inpval_tab(14).input_value_id
                ,p_entry_value14                 =>g_ext_inpval_tab(14).return_value
                ,p_effective_start_date          =>l_effective_start_date
                ,p_effective_end_date            =>l_effective_end_date
                ,p_update_warning                =>l_update_warning
                );

                l_creator_id := p_enrt_rslt_id;
                l_creator_type := 'F';
        end if;
      else
        --
        -- create ee since there were no zero pay periods
        --
        /*
           02-JAN-1994
           |-A----------------------------------------------------->
                                          ED
        */
        --
        if g_debug then
          hr_utility.set_location('calling  create ' , 2293);
        end if;
        py_element_entry_api.create_element_entry
          (p_validate              =>p_validate
          ,p_effective_date        =>l_zero_pp_date
          ,p_business_group_id     =>p_business_group_id
          ,p_assignment_id         =>l_assignment_id
          ,p_element_link_id       =>l_element_link_id
          ,p_entry_type            =>'E'
          ,p_override_user_ent_chk =>'Y'
          ,p_input_value_id1       =>g_ext_inpval_tab(1).input_value_id
          ,p_entry_value1          =>g_ext_inpval_tab(1).return_value
          ,p_input_value_id2       =>g_ext_inpval_tab(2).input_value_id
          ,p_entry_value2          =>g_ext_inpval_tab(2).return_value
          ,p_input_value_id3       =>g_ext_inpval_tab(3).input_value_id
          ,p_entry_value3          =>g_ext_inpval_tab(3).return_value
          ,p_input_value_id4       =>g_ext_inpval_tab(4).input_value_id
          ,p_entry_value4          =>g_ext_inpval_tab(4).return_value
          ,p_input_value_id5       =>g_ext_inpval_tab(5).input_value_id
          ,p_entry_value5          =>g_ext_inpval_tab(5).return_value
          ,p_input_value_id6       =>g_ext_inpval_tab(6).input_value_id
          ,p_entry_value6          =>g_ext_inpval_tab(6).return_value
          ,p_input_value_id7       =>g_ext_inpval_tab(7).input_value_id
          ,p_entry_value7          =>g_ext_inpval_tab(7).return_value
          ,p_input_value_id8       =>g_ext_inpval_tab(8).input_value_id
          ,p_entry_value8          =>g_ext_inpval_tab(8).return_value
          ,p_input_value_id9       =>g_ext_inpval_tab(9).input_value_id
          ,p_entry_value9          =>g_ext_inpval_tab(9).return_value
          ,p_input_value_id10      =>g_ext_inpval_tab(10).input_value_id
          ,p_entry_value10         =>g_ext_inpval_tab(10).return_value
          ,p_input_value_id11      =>g_ext_inpval_tab(11).input_value_id
          ,p_entry_value11         =>g_ext_inpval_tab(11).return_value
          ,p_input_value_id12      =>g_ext_inpval_tab(12).input_value_id
          ,p_entry_value12         =>g_ext_inpval_tab(12).return_value
          ,p_input_value_id13      =>g_ext_inpval_tab(13).input_value_id
          ,p_entry_value13         =>g_ext_inpval_tab(13).return_value
          ,p_input_value_id14      =>g_ext_inpval_tab(14).input_value_id
          ,p_entry_value14         =>g_ext_inpval_tab(14).return_value
          ,p_input_value_id15      =>l_input_value_id
          ,p_entry_value15         =>0
          ,p_effective_start_date  =>l_effective_start_date
          ,p_effective_end_date    =>l_effective_end_date
          ,p_element_entry_id      =>l_element_entry_id
          ,p_object_version_number =>l_object_version_number
          ,p_create_warning        =>l_create_warning
          );
        --
        --  Tell next steps to update instead of create
        --
        l_update_ee:=true;
        --
        -- write to the change event log
        --
        ben_ext_chlg.log_element_chg
          (p_action               => 'CREATE'
          ,p_amt                  => 0
          ,p_input_value_id       => l_input_value_id
          ,p_element_entry_id     => l_element_entry_id
          ,p_person_id            => p_person_id
          ,p_business_group_id    => p_business_group_id
          ,p_effective_date       => l_zero_pp_date
          );
        --
        -- Change the creator type and id from the default
        --
        if g_debug then
          hr_utility.set_location('Change creator type and id ',50);
        end if;
        /*
          Before:-
              02-JAN-1994
                 |-A----------------------------------------------------->
                                                  ED
          After:-
              02-JAN-1994
                 |-A----------------------------------------------------->
                                                  ED
        */
        py_element_entry_api.update_element_entry
          (p_validate              => p_validate
          ,p_datetrack_update_mode => hr_api.g_correction
          ,p_effective_date        => l_zero_pp_date
          ,p_business_group_id     => p_business_group_id
          ,p_element_entry_id      => l_element_entry_id
          ,p_override_user_ent_chk =>'Y'
          ,p_object_version_number => l_object_version_number
          ,p_creator_type          => 'F'
          ,p_creator_id            => p_enrt_rslt_id
          ,p_effective_start_date  => l_effective_start_date
          ,p_effective_end_date    => l_effective_end_date
          ,p_update_warning        => l_update_warning
          );
        --
        -- update curr val to prevent unnecessary updates
        --
        l_curr_val:=0;
        l_creator_id := p_enrt_rslt_id;
        l_creator_type := 'F';
        --
      end if;
    end if;
    --
    -- Done with zero value pay periods, now do special one
    --
    -- Check for calculate only mode
    --
    if g_debug then
      hr_utility.set_location('l_special_pp_date '||l_special_pp_date , 2293);
    end if;
    if l_special_pp_date is not null
      and l_calculate_only_mode
    then
      --
      -- Set screen entry value out parameter to the special value
      --
      p_eev_screen_entry_value := l_special_amt;
      --
    elsif l_special_pp_date is not null and
          l_special_pp_date <= least(l_element_term_rule_date,l_element_link_end_date)
    then
      --
      get_extra_ele_inputs
      (p_effective_date         => l_special_pp_date
      ,p_person_id              => p_person_id
      ,p_business_group_id      => p_business_group_id
      ,p_assignment_id          => l_assignment_id
      ,p_element_link_id        => l_element_link_id
      ,p_entry_type             => 'E'
      ,p_input_value_id1        => null
      ,p_entry_value1           => l_special_amt
      ,p_element_entry_id       => null
      ,p_acty_base_rt_id        => p_acty_base_rt_id
      ,p_input_va_calc_rl       => l_get_abr_info.input_va_calc_rl
      ,p_abs_ler                => l_abs_ler
      ,p_organization_id        => l_organization_id
      ,p_payroll_id             => l_payroll_id
      ,p_pgm_id                 => g_result_rec.pgm_id
      ,p_pl_id                  => NVL(g_result_rec.pl_id,p_pl_id)
      ,p_pl_typ_id              => g_result_rec.pl_typ_id
      ,p_opt_id                 => g_result_rec.opt_id
      ,p_ler_id                 => l_ler_id
      ,p_dml_typ                => 'C'
      ,p_jurisdiction_code      => l_jurisdiction_code
      ,p_ext_inpval_tab         => g_ext_inpval_tab
      ,p_subpriority            => l_subpriority
      );

      if l_update_ee then
        --
        open get_current_value(l_element_entry_id,l_input_value_id,
                               l_special_pp_date);
        --
        fetch get_current_value into
          l_curr_val_char,
          l_object_version_number,
          l_creator_id,
          l_creator_type,
          l_ee_effective_start_date,
          l_ee_effective_end_date;

        if get_current_value%notfound then
          close get_current_value;
          if g_debug then
            hr_utility.set_location('BEN_92101_NO_RATE ',92);
          end if;
          fnd_message.set_name('BEN', 'BEN_92101_NO_RATE');
          fnd_message.set_token('PROC',l_proc);
          fnd_message.set_token('ELEMENT_ENTRY_ID',to_char(l_element_entry_id));
          fnd_message.set_token('INPUT_VALUE_ID',to_char(l_input_value_id));
          fnd_message.set_token('EFFECTIVE_DATE',to_char(l_special_pp_date));
          fnd_message.set_token('ABR_NAME',l_get_abr_info.name); -- Bug 2519349
          fnd_message.raise_error;
        end if;
        close get_current_value;

        if l_uom is null then
           l_uom := get_uom(p_business_group_id,p_effective_date);
        end if;
        l_curr_val := chkformat(l_curr_val_char, l_uom);

        if g_debug then
           hr_utility.set_location('l_uom='|| l_uom ,432);
           hr_utility.set_location('aft frmt chg '||l_curr_val_char,432);
           hr_utility.set_location('converted no. value is '||l_curr_val,432);
        end if;

        if nvl(l_curr_val,hr_api.g_number) <>l_special_amt then
          /*
             Before :-
               02-JAN-1994
                   |-A----------------------------------------------------->
                                                     ED

             After :-
               02-JAN-1994                    15-JUL-1994
                   |-A----------------------------|-B---------------------->
                                                     ED
          */
          --
          l_upd_mode := get_ele_dt_upd_mode(l_special_pp_date,
                                            l_element_entry_id);
          py_element_entry_api.update_element_entry
            (p_validate                      =>p_validate
            ,p_datetrack_update_mode         =>l_upd_mode
            ,p_effective_date                =>l_special_pp_date
            ,p_business_group_id             =>p_business_group_id
            ,p_element_entry_id              =>l_element_entry_id
            ,p_override_user_ent_chk         =>'Y'
            ,p_object_version_number         =>l_object_version_number
            ,p_creator_type                  =>'F'
            ,p_creator_id                    =>p_enrt_rslt_id
            ,p_input_value_id1               =>g_ext_inpval_tab(1).input_value_id
            ,p_entry_value1                  =>g_ext_inpval_tab(1).return_value
            ,p_input_value_id2               =>g_ext_inpval_tab(2).input_value_id
            ,p_entry_value2                  =>g_ext_inpval_tab(2).return_value
            ,p_input_value_id3               =>g_ext_inpval_tab(3).input_value_id
            ,p_entry_value3                  =>g_ext_inpval_tab(3).return_value
            ,p_input_value_id4               =>g_ext_inpval_tab(4).input_value_id
            ,p_entry_value4                  =>g_ext_inpval_tab(4).return_value
            ,p_input_value_id5               =>g_ext_inpval_tab(5).input_value_id
            ,p_entry_value5                  =>g_ext_inpval_tab(5).return_value
            ,p_input_value_id6               =>g_ext_inpval_tab(6).input_value_id
            ,p_entry_value6                  =>g_ext_inpval_tab(6).return_value
            ,p_input_value_id7               =>g_ext_inpval_tab(7).input_value_id
            ,p_entry_value7                  =>g_ext_inpval_tab(7).return_value
            ,p_input_value_id8               =>g_ext_inpval_tab(8).input_value_id
            ,p_entry_value8                  =>g_ext_inpval_tab(8).return_value
            ,p_input_value_id9               =>g_ext_inpval_tab(9).input_value_id
            ,p_entry_value9                  =>g_ext_inpval_tab(9).return_value
            ,p_input_value_id10              =>g_ext_inpval_tab(10).input_value_id
            ,p_entry_value10                 =>g_ext_inpval_tab(10).return_value
            ,p_input_value_id11              =>g_ext_inpval_tab(11).input_value_id
            ,p_entry_value11                 =>g_ext_inpval_tab(11).return_value
            ,p_input_value_id12              =>g_ext_inpval_tab(12).input_value_id
            ,p_entry_value12                 =>g_ext_inpval_tab(12).return_value
            ,p_input_value_id13              =>g_ext_inpval_tab(13).input_value_id
            ,p_entry_value13                 =>g_ext_inpval_tab(13).return_value
            ,p_input_value_id14              =>g_ext_inpval_tab(14).input_value_id
            ,p_entry_value14                 =>g_ext_inpval_tab(14).return_value
            ,p_input_value_id15              =>l_input_value_id
            ,p_entry_value15                 =>l_special_amt
            ,p_effective_start_date          =>l_effective_start_date
            ,p_effective_end_date            =>l_effective_end_date
            ,p_update_warning                =>l_update_warning
            );
          --
          -- write to the change event log
          --
          ben_ext_chlg.log_element_chg
            (p_action               => l_upd_mode
            ,p_amt                  => l_special_amt
            ,p_old_amt              => l_curr_val
            ,p_input_value_id       => l_input_value_id
            ,p_element_entry_id     => l_element_entry_id
            ,p_person_id            => p_person_id
            ,p_business_group_id    => p_business_group_id
            ,p_effective_date       => l_special_pp_date
            );
          --
          -- update curr val to prevent unnecessary updates
          --
          l_curr_val:=l_special_amt;
          l_creator_id := p_enrt_rslt_id;
          l_creator_type := 'F';
          --
        elsif nvl(l_creator_id,-1) <> p_enrt_rslt_id or
              nvl(l_creator_type,'-1') <> 'F' then

              l_upd_mode :=get_ele_dt_upd_mode(l_special_pp_date,
                                               l_element_entry_id);
              py_element_entry_api.update_element_entry
                (p_validate                      =>p_validate
                ,p_datetrack_update_mode         =>l_upd_mode
                ,p_effective_date                =>l_special_pp_date
                ,p_business_group_id             =>p_business_group_id
                ,p_element_entry_id              =>l_element_entry_id
                ,p_override_user_ent_chk         =>'Y'
                ,p_object_version_number         =>l_object_version_number
                ,p_creator_type                  =>'F'
                ,p_creator_id                    =>p_enrt_rslt_id
                ,p_input_value_id1               =>g_ext_inpval_tab(1).input_value_id
                ,p_entry_value1                  =>g_ext_inpval_tab(1).return_value
                ,p_input_value_id2               =>g_ext_inpval_tab(2).input_value_id
                ,p_entry_value2                  =>g_ext_inpval_tab(2).return_value
                ,p_input_value_id3               =>g_ext_inpval_tab(3).input_value_id
                ,p_entry_value3                  =>g_ext_inpval_tab(3).return_value
                ,p_input_value_id4               =>g_ext_inpval_tab(4).input_value_id
                ,p_entry_value4                  =>g_ext_inpval_tab(4).return_value
                ,p_input_value_id5               =>g_ext_inpval_tab(5).input_value_id
                ,p_entry_value5                  =>g_ext_inpval_tab(5).return_value
                ,p_input_value_id6               =>g_ext_inpval_tab(6).input_value_id
                ,p_entry_value6                  =>g_ext_inpval_tab(6).return_value
                ,p_input_value_id7               =>g_ext_inpval_tab(7).input_value_id
                ,p_entry_value7                  =>g_ext_inpval_tab(7).return_value
                ,p_input_value_id8               =>g_ext_inpval_tab(8).input_value_id
                ,p_entry_value8                  =>g_ext_inpval_tab(8).return_value
                ,p_input_value_id9               =>g_ext_inpval_tab(9).input_value_id
                ,p_entry_value9                  =>g_ext_inpval_tab(9).return_value
                ,p_input_value_id10              =>g_ext_inpval_tab(10).input_value_id
                ,p_entry_value10                 =>g_ext_inpval_tab(10).return_value
                ,p_input_value_id11              =>g_ext_inpval_tab(11).input_value_id
                ,p_entry_value11                 =>g_ext_inpval_tab(11).return_value
                ,p_input_value_id12              =>g_ext_inpval_tab(12).input_value_id
                ,p_entry_value12                 =>g_ext_inpval_tab(12).return_value
                ,p_input_value_id13              =>g_ext_inpval_tab(13).input_value_id
                ,p_entry_value13                 =>g_ext_inpval_tab(13).return_value
                ,p_input_value_id14              =>g_ext_inpval_tab(14).input_value_id
                ,p_entry_value14                 =>g_ext_inpval_tab(14).return_value
                ,p_effective_start_date          =>l_effective_start_date
                ,p_effective_end_date            =>l_effective_end_date
                ,p_update_warning                =>l_update_warning
                );
                l_creator_id := p_enrt_rslt_id;
                l_creator_type := 'F';
        end if;
        --
      else
        --
        -- create ee since there were no zero pay periods
        --
        /*
           02-JAN-1994
           |-A----------------------------------------------------->
                                          ED
        */
        --
        if g_debug then
          hr_utility.set_location('l_special_amt='||l_special_amt,433);
        end if;

        py_element_entry_api.create_element_entry
          (p_validate              =>p_validate
          ,p_effective_date        =>l_special_pp_date
          ,p_business_group_id     =>p_business_group_id
          ,p_assignment_id         =>l_assignment_id
          ,p_element_link_id       =>l_element_link_id
          ,p_entry_type            =>'E'
          ,p_override_user_ent_chk =>'Y'
          ,p_input_value_id1       =>g_ext_inpval_tab(1).input_value_id
          ,p_entry_value1          =>g_ext_inpval_tab(1).return_value
          ,p_input_value_id2       =>g_ext_inpval_tab(2).input_value_id
          ,p_entry_value2          =>g_ext_inpval_tab(2).return_value
          ,p_input_value_id3       =>g_ext_inpval_tab(3).input_value_id
          ,p_entry_value3          =>g_ext_inpval_tab(3).return_value
          ,p_input_value_id4       =>g_ext_inpval_tab(4).input_value_id
          ,p_entry_value4          =>g_ext_inpval_tab(4).return_value
          ,p_input_value_id5       =>g_ext_inpval_tab(5).input_value_id
          ,p_entry_value5          =>g_ext_inpval_tab(5).return_value
          ,p_input_value_id6       =>g_ext_inpval_tab(6).input_value_id
          ,p_entry_value6          =>g_ext_inpval_tab(6).return_value
          ,p_input_value_id7       =>g_ext_inpval_tab(7).input_value_id
          ,p_entry_value7          =>g_ext_inpval_tab(7).return_value
          ,p_input_value_id8       =>g_ext_inpval_tab(8).input_value_id
          ,p_entry_value8          =>g_ext_inpval_tab(8).return_value
          ,p_input_value_id9       =>g_ext_inpval_tab(9).input_value_id
          ,p_entry_value9          =>g_ext_inpval_tab(9).return_value
          ,p_input_value_id10      =>g_ext_inpval_tab(10).input_value_id
          ,p_entry_value10         =>g_ext_inpval_tab(10).return_value
          ,p_input_value_id11      =>g_ext_inpval_tab(11).input_value_id
          ,p_entry_value11         =>g_ext_inpval_tab(11).return_value
          ,p_input_value_id12      =>g_ext_inpval_tab(12).input_value_id
          ,p_entry_value12         =>g_ext_inpval_tab(12).return_value
          ,p_input_value_id13      =>g_ext_inpval_tab(13).input_value_id
          ,p_entry_value13         =>g_ext_inpval_tab(13).return_value
          ,p_input_value_id14      =>g_ext_inpval_tab(14).input_value_id
          ,p_entry_value14         =>g_ext_inpval_tab(14).return_value
          ,p_input_value_id15      =>l_input_value_id
          ,p_entry_value15         =>l_special_amt
          ,p_effective_start_date  =>l_effective_start_date
          ,p_effective_end_date    =>l_effective_end_date
          ,p_element_entry_id      =>l_element_entry_id
          ,p_object_version_number =>l_object_version_number
          ,p_create_warning        =>l_create_warning
          );
        --
        --  Tell next steps to update instead of create
        --
        l_update_ee:=true;
        --
        -- write to the change event log
        --
        ben_ext_chlg.log_element_chg
          (p_action               => 'CREATE'
          ,p_amt                  => l_special_amt
          ,p_input_value_id       => l_input_value_id
          ,p_element_entry_id     => l_element_entry_id
          ,p_person_id            => p_person_id
          ,p_business_group_id    => p_business_group_id
          ,p_effective_date       => l_special_pp_date
          );
        --
        -- Change the creator type and id from the default
        --
        if g_debug then
          hr_utility.set_location('Change creator type and id ',50);
        end if;
        /*
          Before:-
              02-JAN-1994
                 |-A----------------------------------------------------->
                                                  ED
          After:-
              02-JAN-1994
                 |-A----------------------------------------------------->
                                                  ED
        */
        py_element_entry_api.update_element_entry
          (p_validate                      => p_validate
          ,p_datetrack_update_mode         => hr_api.g_correction
          ,p_effective_date                => l_special_pp_date
          ,p_business_group_id             => p_business_group_id
          ,p_element_entry_id              => l_element_entry_id
          ,p_override_user_ent_chk         =>'Y'
          ,p_object_version_number         => l_object_version_number
          ,p_creator_type                  => 'F'
          ,p_creator_id                    => p_enrt_rslt_id
          ,p_effective_start_date          => l_effective_start_date
          ,p_effective_end_date            => l_effective_end_date
          ,p_update_warning                => l_update_warning
          );
        --
        -- update curr val to prevent unnecessary updates
        --
        l_curr_val:=l_special_amt;
        l_creator_id := p_enrt_rslt_id;
        l_creator_type := 'F';
        --
      end if;
      --
    end if;
  -- ELE :
  end if;
  --
  -- Get entry value id.
  --
  if g_debug then
    hr_utility.set_location('not p_calculate_only_mode ' ,41);
    hr_utility.set_location('normal pp date  '|| l_normal_pp_date ,41);
  end if;
  --
  -- Done with special value pay period, now do normal one
  --
  -- ELE : By pass if the ele_entry_val_cd <> PP , EPP or null.
  --
  if nvl(l_get_abr_info.ele_entry_val_cd, 'PP') not in ('PP', 'EPP') then
     --
     l_normal_pp_date := l_rt_strt_dt;
     l_zero_pp_date   := null;
     l_special_pp_date := null;
     --
    if l_get_abr_info.ele_entry_val_cd = 'DFND' then
       --
       l_per_pay_amt := p_rt;
       --
    elsif l_get_abr_info.ele_entry_val_cd = 'CMCD' then
       --
       l_per_pay_amt := p_cmncd_rt;
       --
    elsif l_get_abr_info.ele_entry_val_cd = 'PYR' then
       --
       l_per_pay_amt := p_ann_rt;
       --
    end if;
  end if;
  --
  if l_abs_ler  then
     l_input_value_id1 := l_input_value_id;
  else
     l_input_value_id1 := null;
  end if;
  --
  get_extra_ele_inputs
  (p_effective_date         => l_normal_pp_date
  ,p_person_id              => p_person_id
  ,p_business_group_id      => p_business_group_id
  ,p_assignment_id          => l_assignment_id
  ,p_element_link_id        => l_element_link_id
  ,p_entry_type             => 'E'
  ,p_input_value_id1        => l_input_value_id1
  ,p_entry_value1           => l_per_pay_amt
  ,p_element_entry_id       => null
  ,p_acty_base_rt_id        => p_acty_base_rt_id
  ,p_input_va_calc_rl       => l_get_abr_info.input_va_calc_rl
  ,p_abs_ler                => l_abs_ler
  ,p_organization_id        => l_organization_id
  ,p_payroll_id             => l_payroll_id
  ,p_pgm_id                 => g_result_rec.pgm_id
  ,p_pl_id                  => NVL(g_result_rec.pl_id,p_pl_id)
  ,p_pl_typ_id              => g_result_rec.pl_typ_id
  ,p_opt_id                 => g_result_rec.opt_id
  ,p_ler_id                 => l_ler_id
  ,p_dml_typ                => 'C'
  ,p_jurisdiction_code      => l_jurisdiction_code
  ,p_ext_inpval_tab         => g_ext_inpval_tab
  ,p_subpriority            => l_subpriority
  );

  if g_debug then
     hr_utility.set_location( 'ext inp count '|| g_ext_inpval_tab.count , 30);
  end if;

  --
  -- Check for calculate only mode
  --
  if not l_calculate_only_mode then
    --
    if l_normal_pp_date is not null and
       l_normal_pp_date <= least(l_element_term_rule_date,l_element_link_end_date) then
      if l_update_ee then
        open get_current_value(l_element_entry_id,
                               l_input_value_id,
                               l_normal_pp_date);
        --
        fetch get_current_value into
          l_curr_val_char,
          l_object_version_number,
          l_creator_id,
          l_creator_type,
          l_ee_effective_start_date,
          l_ee_effective_end_date;

          if g_debug then
            hr_utility.set_location('fetched all values' ,432);
          end if;

        if get_current_value%notfound then
          close get_current_value;
          if g_debug then
            hr_utility.set_location('BEN_92101_NO_RATE ',94);
          end if;
          fnd_message.set_name('BEN', 'BEN_92101_NO_RATE');
          fnd_message.set_token('PROC',l_proc);
          fnd_message.set_token('ELEMENT_ENTRY_ID',to_char(l_element_entry_id));
          fnd_message.set_token('INPUT_VALUE_ID',to_char(l_input_value_id));
          fnd_message.set_token('EFFECTIVE_DATE',to_char(l_normal_pp_date));
          fnd_message.set_token('ABR_NAME',l_get_abr_info.name); -- Bug 2519349
          fnd_message.raise_error;
        end if;
        close get_current_value;
        --
        if l_uom is null then
           l_uom := get_uom(p_business_group_id,p_effective_date);
        end if;
        l_curr_val := chkformat(l_curr_val_char, l_uom);

        if g_debug then
           hr_utility.set_location('l_uom='|| l_uom ,432);
           hr_utility.set_location('aft frmt chg '||l_curr_val_char,432);
           hr_utility.set_location('converted no. value is '||l_curr_val,432);
        end if;

        if nvl(l_curr_val,hr_api.g_number) <>l_per_pay_amt then
          /*
             Before :-
               02-JAN-1994
                   |-A----------------------------------------------------->
                                                     ED

             After :-
               02-JAN-1994                    15-JUL-1994
                   |-A----------------------------|-B---------------------->
                                                     ED
          */
          --
          l_upd_mode :=get_ele_dt_upd_mode(l_normal_pp_date,
                                           l_element_entry_id);
          --
          py_element_entry_api.update_element_entry
            (p_validate                      =>p_validate
            ,p_datetrack_update_mode         =>l_upd_mode
            ,p_effective_date                =>l_normal_pp_date
            ,p_business_group_id             =>p_business_group_id
            ,p_element_entry_id              =>l_element_entry_id
            ,p_override_user_ent_chk         =>'Y'
            ,p_object_version_number         =>l_object_version_number
            ,p_creator_type                  =>'F'
            ,p_creator_id                    =>p_enrt_rslt_id
            ,p_input_value_id1               =>g_ext_inpval_tab(1).input_value_id
            ,p_entry_value1                  =>g_ext_inpval_tab(1).return_value
            ,p_input_value_id2               =>g_ext_inpval_tab(2).input_value_id
            ,p_entry_value2                  =>g_ext_inpval_tab(2).return_value
            ,p_input_value_id3               =>g_ext_inpval_tab(3).input_value_id
            ,p_entry_value3                  =>g_ext_inpval_tab(3).return_value
            ,p_input_value_id4               =>g_ext_inpval_tab(4).input_value_id
            ,p_entry_value4                  =>g_ext_inpval_tab(4).return_value
            ,p_input_value_id5               =>g_ext_inpval_tab(5).input_value_id
            ,p_entry_value5                  =>g_ext_inpval_tab(5).return_value
            ,p_input_value_id6               =>g_ext_inpval_tab(6).input_value_id
            ,p_entry_value6                  =>g_ext_inpval_tab(6).return_value
            ,p_input_value_id7               =>g_ext_inpval_tab(7).input_value_id
            ,p_entry_value7                  =>g_ext_inpval_tab(7).return_value
            ,p_input_value_id8               =>g_ext_inpval_tab(8).input_value_id
            ,p_entry_value8                  =>g_ext_inpval_tab(8).return_value
            ,p_input_value_id9               =>g_ext_inpval_tab(9).input_value_id
            ,p_entry_value9                  =>g_ext_inpval_tab(9).return_value
            ,p_input_value_id10              =>g_ext_inpval_tab(10).input_value_id
            ,p_entry_value10                 =>g_ext_inpval_tab(10).return_value
            ,p_input_value_id11              =>g_ext_inpval_tab(11).input_value_id
            ,p_entry_value11                 =>g_ext_inpval_tab(11).return_value
            ,p_input_value_id12              =>g_ext_inpval_tab(12).input_value_id
            ,p_entry_value12                 =>g_ext_inpval_tab(12).return_value
            ,p_input_value_id13              =>g_ext_inpval_tab(13).input_value_id
            ,p_entry_value13                 =>g_ext_inpval_tab(13).return_value
            ,p_input_value_id14              =>g_ext_inpval_tab(14).input_value_id
            ,p_entry_value14                 =>g_ext_inpval_tab(14).return_value
            ,p_input_value_id15              =>l_input_value_id
            ,p_entry_value15                 =>l_per_pay_amt
            ,p_effective_start_date          =>l_effective_start_date
            ,p_effective_end_date            =>l_effective_end_date
            ,p_update_warning                =>l_update_warning
            );
          --
          -- write to the change event log
          --
          ben_ext_chlg.log_element_chg
            (p_action               => l_upd_mode
            ,p_amt                  => l_per_pay_amt
            ,p_old_amt              => l_curr_val
            ,p_input_value_id       => l_input_value_id
            ,p_element_entry_id     => l_element_entry_id
            ,p_person_id            => p_person_id
            ,p_business_group_id    => p_business_group_id
            ,p_effective_date       => l_normal_pp_date
            );
          --
          l_ee_effective_end_date := l_effective_end_date;
          l_creator_id := p_enrt_rslt_id;
          l_creator_type := 'F';

        elsif nvl(l_creator_id,-1) <> p_enrt_rslt_id or
              nvl(l_creator_type,'-1') <> 'F' then

              l_upd_mode :=get_ele_dt_upd_mode(l_normal_pp_date,
                                               l_element_entry_id);
              py_element_entry_api.update_element_entry
                (p_validate                      =>p_validate
                ,p_datetrack_update_mode         =>l_upd_mode
                ,p_effective_date                =>l_normal_pp_date
                ,p_business_group_id             =>p_business_group_id
                ,p_element_entry_id              =>l_element_entry_id
                ,p_override_user_ent_chk         =>'Y'
                ,p_object_version_number         =>l_object_version_number
                ,p_creator_type                  =>'F'
                ,p_creator_id                    =>p_enrt_rslt_id
                ,p_input_value_id1               =>g_ext_inpval_tab(1).input_value_id
                ,p_entry_value1                  =>g_ext_inpval_tab(1).return_value
                ,p_input_value_id2               =>g_ext_inpval_tab(2).input_value_id
                ,p_entry_value2                  =>g_ext_inpval_tab(2).return_value
                ,p_input_value_id3               =>g_ext_inpval_tab(3).input_value_id
                ,p_entry_value3                  =>g_ext_inpval_tab(3).return_value
                ,p_input_value_id4               =>g_ext_inpval_tab(4).input_value_id
                ,p_entry_value4                  =>g_ext_inpval_tab(4).return_value
                ,p_input_value_id5               =>g_ext_inpval_tab(5).input_value_id
                ,p_entry_value5                  =>g_ext_inpval_tab(5).return_value
                ,p_input_value_id6               =>g_ext_inpval_tab(6).input_value_id
                ,p_entry_value6                  =>g_ext_inpval_tab(6).return_value
                ,p_input_value_id7               =>g_ext_inpval_tab(7).input_value_id
                ,p_entry_value7                  =>g_ext_inpval_tab(7).return_value
                ,p_input_value_id8               =>g_ext_inpval_tab(8).input_value_id
                ,p_entry_value8                  =>g_ext_inpval_tab(8).return_value
                ,p_input_value_id9               =>g_ext_inpval_tab(9).input_value_id
                ,p_entry_value9                  =>g_ext_inpval_tab(9).return_value
                ,p_input_value_id10              =>g_ext_inpval_tab(10).input_value_id
                ,p_entry_value10                 =>g_ext_inpval_tab(10).return_value
                ,p_input_value_id11              =>g_ext_inpval_tab(11).input_value_id
                ,p_entry_value11                 =>g_ext_inpval_tab(11).return_value
                ,p_input_value_id12              =>g_ext_inpval_tab(12).input_value_id
                ,p_entry_value12                 =>g_ext_inpval_tab(12).return_value
                ,p_input_value_id13              =>g_ext_inpval_tab(13).input_value_id
                ,p_entry_value13                 =>g_ext_inpval_tab(13).return_value
                ,p_input_value_id14              =>g_ext_inpval_tab(14).input_value_id
                ,p_entry_value14                 =>g_ext_inpval_tab(14).return_value
                ,p_effective_start_date          =>l_effective_start_date
                ,p_effective_end_date            =>l_effective_end_date
                ,p_update_warning                =>l_update_warning
                );
                l_creator_id := p_enrt_rslt_id;
                l_creator_type := 'F';
        end if;
        --

      else
        --
        -- create ee since there were no zero pay periods
        --
        /*
           02-JAN-1994
           |-A----------------------------------------------------->
                                          ED
        */
        if g_debug then
          hr_utility.set_location( 'entering', 30.2);
          hr_utility.set_location( 'amout '|| l_amt , 30.2);
        end if;

        py_element_entry_api.create_element_entry
        (p_validate              =>p_validate
        ,p_effective_date        =>l_normal_pp_date
        ,p_business_group_id     =>p_business_group_id
        ,p_assignment_id         =>l_assignment_id
        ,p_element_link_id       =>l_element_link_id
        ,p_entry_type            =>'E'
        ,p_override_user_ent_chk =>'Y'
        ,p_subpriority           =>l_subpriority
        ,p_input_value_id1       =>g_ext_inpval_tab(1).input_value_id
        ,p_entry_value1          =>g_ext_inpval_tab(1).return_value
        ,p_input_value_id2       =>g_ext_inpval_tab(2).input_value_id
        ,p_entry_value2          =>g_ext_inpval_tab(2).return_value
        ,p_input_value_id3       =>g_ext_inpval_tab(3).input_value_id
        ,p_entry_value3          =>g_ext_inpval_tab(3).return_value
        ,p_input_value_id4       =>g_ext_inpval_tab(4).input_value_id
        ,p_entry_value4          =>g_ext_inpval_tab(4).return_value
        ,p_input_value_id5       =>g_ext_inpval_tab(5).input_value_id
        ,p_entry_value5          =>g_ext_inpval_tab(5).return_value
        ,p_input_value_id6       =>g_ext_inpval_tab(6).input_value_id
        ,p_entry_value6          =>g_ext_inpval_tab(6).return_value
        ,p_input_value_id7       =>g_ext_inpval_tab(7).input_value_id
        ,p_entry_value7          =>g_ext_inpval_tab(7).return_value
        ,p_input_value_id8       =>g_ext_inpval_tab(8).input_value_id
        ,p_entry_value8          =>g_ext_inpval_tab(8).return_value
        ,p_input_value_id9       =>g_ext_inpval_tab(9).input_value_id
        ,p_entry_value9          =>g_ext_inpval_tab(9).return_value
        ,p_input_value_id10      =>g_ext_inpval_tab(10).input_value_id
        ,p_entry_value10         =>g_ext_inpval_tab(10).return_value
        ,p_input_value_id11      =>g_ext_inpval_tab(11).input_value_id
        ,p_entry_value11         =>g_ext_inpval_tab(11).return_value
        ,p_input_value_id12      =>g_ext_inpval_tab(12).input_value_id
        ,p_entry_value12         =>g_ext_inpval_tab(12).return_value
        ,p_input_value_id13      =>g_ext_inpval_tab(13).input_value_id
        ,p_entry_value13         =>g_ext_inpval_tab(13).return_value
        ,p_input_value_id14      =>g_ext_inpval_tab(14).input_value_id
        ,p_entry_value14         =>g_ext_inpval_tab(14).return_value
        ,p_input_value_id15      =>l_input_value_id
        ,p_entry_value15         =>l_per_pay_amt
        ,p_effective_start_date  =>l_effective_start_date
        ,p_effective_end_date    =>l_effective_end_date
        ,p_element_entry_id      =>l_element_entry_id
        ,p_object_version_number =>l_object_version_number
        ,p_create_warning        =>l_create_warning
        );
         --
	 hr_utility.set_location('l_effective_end_date after pay.create_element_entry '||l_effective_end_date,44333);
        --
	--
        --  Tell next steps to update instead of create
        --

        l_update_ee:=true;
        --
        -- write to the change event log
        --
        ben_ext_chlg.log_element_chg
        (p_action               => 'CREATE'
        ,p_amt                  => l_per_pay_amt
        ,p_input_value_id       => l_input_value_id
        ,p_element_entry_id     => l_element_entry_id
        ,p_person_id            => p_person_id
        ,p_business_group_id    => p_business_group_id
        ,p_effective_date       => l_normal_pp_date
        );
        --
        -- Change the creator type and id from the default
        --
        if g_debug then
           hr_utility.set_location('Change creator type and id ',50);
        end if;
        /*
           Before:-
               02-JAN-1994
                  |-A----------------------------------------------------->
                                                   ED
           After:-
               02-JAN-1994
                  |-A----------------------------------------------------->
                                                     ED
        */
        py_element_entry_api.update_element_entry
        (p_validate                      =>p_validate
        ,p_datetrack_update_mode         =>hr_api.g_correction
        ,p_effective_date                =>l_normal_pp_date
        ,p_business_group_id             =>p_business_group_id
        ,p_element_entry_id              =>l_element_entry_id
        ,p_override_user_ent_chk         =>'Y'
        ,p_object_version_number         =>l_object_version_number
        ,p_creator_type                  =>'F'
        ,p_creator_id                    =>p_enrt_rslt_id
        ,p_effective_start_date          =>l_effective_start_date
        ,p_effective_end_date            =>l_effective_end_date
        ,p_update_warning                =>l_update_warning
        );
        --
        l_ee_effective_end_date := l_effective_end_date;
        l_creator_id := p_enrt_rslt_id;
        l_creator_type := 'F';

	     hr_utility.set_location('l_ee_effective_end_date '||l_ee_effective_end_date,44333);
	     hr_utility.set_location('l_creator_id '||l_creator_id,44333);
	     hr_utility.set_location('l_creator_type '||l_creator_type,44333);
      end if;
      --
    end if;

    if l_normal_pp_date is not null then
       --
       hr_utility.set_location('if l_normal_pp_date is not null then ',44333);
       --
       if l_ee_effective_end_date < l_element_term_rule_date then
       --
       hr_utility.set_location('if l_ee_effective_end_date < l_element_term_rule_date then ',44333);
       --

       open c_future_ee(l_element_entry_id,
                        l_element_type_id,
                        l_input_value_id,
                        l_assignment_id,
                        l_normal_pp_date);
			 loop
				fetch c_future_ee into l_future_ee_rec;

				if c_future_ee%notfound then
				  --
				  hr_utility.set_location('if c_future_ee%notfound then ',44333);
				  --
				  exit;
				end if;

				l_element_link_id := l_future_ee_rec.element_link_id;
				l_effective_start_date := l_future_ee_rec.effective_start_date;
				l_effective_end_date := l_future_ee_rec.effective_end_date;

				l_curr_val :=chkformat(l_future_ee_rec.screen_entry_value,l_uom);

				if g_debug then
				  hr_utility.set_location('future ee='||l_future_ee_rec.element_entry_id ,433);
				  hr_utility.set_location('l_curr_val_char='||l_future_ee_rec.screen_entry_value ,433);
				  hr_utility.set_location('l_curr_val='||l_curr_val ,433);
				  hr_utility.set_location('l_per_pay_amt='||l_per_pay_amt ,433);
				end if;

				if nvl(l_per_pay_amt,0) <> nvl(l_curr_val,0) then
				  --
				  hr_utility.set_location('if nvl(l_per_pay_amt,0) <> nvl(l_curr_val,0) then',44333);
				  --
				  py_element_entry_api.update_element_entry
						 (p_validate              =>p_validate
						 ,p_datetrack_update_mode =>hr_api.g_correction
						 ,p_effective_date        =>l_future_ee_rec.effective_start_date
						 ,p_business_group_id     =>p_business_group_id
						 ,p_element_entry_id      =>l_future_ee_rec.element_entry_id
						 ,p_override_user_ent_chk =>'Y'
						 ,p_object_version_number =>l_future_ee_rec.object_version_number
						 ,p_input_value_id1       =>l_input_value_id
						 ,p_entry_value1          =>l_per_pay_amt
						 ,p_effective_start_date  =>l_effective_start_date
						 ,p_effective_end_date    =>l_effective_end_date
						 ,p_update_warning        =>l_update_warning
						 );
				end if;
			 end loop;
	    close c_future_ee;
    end if;

    loop
      --
      -- created till max possible date. exit now
      --
      if l_effective_end_date=l_element_term_rule_date then
	     --
	     hr_utility.set_location('if l_effective_end_date=l_element_term_rule_date then',44333);
	     --
        exit;
      end if;

      l_effective_date  := l_effective_end_date + 1;
	   --
	   if g_debug then
	     hr_utility.set_location('l_effective_date '||l_effective_date,44333);
	     hr_utility.set_location('l_effective_end_date '||l_effective_end_date,44333);
	   end if;
      --
      -- get the next eligible element link for the assignment and elt
      --
	   -- added here for bug 6450363
      if l_abs_ler then -- bug # 7383673, 7390204
         -- bug # 7383673, 7390204 -- restricting bug 6450363 fix only for absences
			l_old_asgn_id := l_assignment_id;
			hr_utility.set_location('l_old_asgn_id '||l_old_asgn_id,44333);
			 --
				get_abr_assignment (p_person_id       => p_person_id
									,p_effective_date  => l_effective_date
									,p_acty_base_rt_id => l_prv_rec.acty_base_rt_id
									,p_organization_id => l_dummy_number
									,p_payroll_id      => l_payroll_id
									,p_assignment_id   => l_assignment_id);
				--
				 hr_utility.set_location('l_assignment_id'||l_assignment_id,44333);
			if l_old_asgn_id = l_assignment_id then
			--
			  hr_utility.set_location('if l_old_asgn_id = l_assignment_id then',44333);
			--
			  get_link(p_assignment_id     => l_assignment_id
							 ,p_element_type_id   => l_element_type_id
							 ,p_business_group_id => p_business_group_id
							 ,p_input_value_id    => l_input_value_id
							 ,p_effective_date    => l_effective_date
							 ,p_element_link_id   => l_new_element_link_id
							 );
			else
			  --
			  hr_utility.set_location('if l_old_asgn_id = l_assignment_id then',44333);
			  --
			  l_assignment_id := l_old_asgn_id;
			  --
						  get_link(p_assignment_id     => l_assignment_id
							 ,p_element_type_id   => l_element_type_id
							 ,p_business_group_id => p_business_group_id
							 ,p_input_value_id    => l_input_value_id
							 ,p_effective_date    => l_effective_end_date
							 ,p_element_link_id   => l_new_element_link_id
							 );
			end if;
		   --added till here for bug 6450363
      else
              get_link(p_assignment_id     => l_assignment_id
							 ,p_element_type_id   => l_element_type_id
							 ,p_business_group_id => p_business_group_id
							 ,p_input_value_id    => l_input_value_id
							 ,p_effective_date    => l_effective_date
							 ,p_element_link_id   => l_new_element_link_id
							 );

      end if;

	   if g_debug then
		   hr_utility.set_location('new_elk='||l_new_element_link_id,50);
	   end if;

	   if l_new_element_link_id = l_element_link_id or
		  l_new_element_link_id is null then
		  --
		  -- No new link found. Get out of the loop
		  --
		  exit;
	   end if;

	   l_element_link_id := l_new_element_link_id;

	   if nvl(l_inpval_tab.count,0) = 0 then
		  get_inpval_tab(l_element_entry_id,
							  l_effective_start_date,
							  l_inpval_tab);
	   end if;
      --
	   hr_utility.set_location('again before pay.create_element',44333);
	   --
           py_element_entry_api.create_element_entry
           (p_validate              =>p_validate
           ,p_effective_date        =>l_effective_date
           ,p_business_group_id     =>p_business_group_id
           ,p_assignment_id         =>l_assignment_id
           ,p_element_link_id       =>l_element_link_id
           ,p_entry_type            =>'E'
           ,p_override_user_ent_chk =>'Y'
           ,p_subpriority           =>l_subpriority
           ,p_input_value_id1       =>l_inpval_tab(1).input_value_id
           ,p_entry_value1          =>l_inpval_tab(1).value
           ,p_input_value_id2       =>l_inpval_tab(2).input_value_id
           ,p_entry_value2          =>l_inpval_tab(2).value
           ,p_input_value_id3       =>l_inpval_tab(3).input_value_id
           ,p_entry_value3          =>l_inpval_tab(3).value
           ,p_input_value_id4       =>l_inpval_tab(4).input_value_id
           ,p_entry_value4          =>l_inpval_tab(4).value
           ,p_input_value_id5       =>l_inpval_tab(5).input_value_id
           ,p_entry_value5          =>l_inpval_tab(5).value
           ,p_input_value_id6       =>l_inpval_tab(6).input_value_id
           ,p_entry_value6          =>l_inpval_tab(6).value
           ,p_input_value_id7       =>l_inpval_tab(7).input_value_id
           ,p_entry_value7          =>l_inpval_tab(7).value
           ,p_input_value_id8       =>l_inpval_tab(8).input_value_id
           ,p_entry_value8          =>l_inpval_tab(8).value
           ,p_input_value_id9       =>l_inpval_tab(9).input_value_id
           ,p_entry_value9          =>l_inpval_tab(9).value
           ,p_input_value_id10      =>l_inpval_tab(10).input_value_id
           ,p_entry_value10         =>l_inpval_tab(10).value
           ,p_input_value_id11      =>l_inpval_tab(11).input_value_id
           ,p_entry_value11         =>l_inpval_tab(11).value
           ,p_input_value_id12      =>l_inpval_tab(12).input_value_id
           ,p_entry_value12         =>l_inpval_tab(12).value
           ,p_input_value_id13      =>l_inpval_tab(13).input_value_id
           ,p_entry_value13         =>l_inpval_tab(13).value
           ,p_input_value_id14      =>l_inpval_tab(14).input_value_id
           ,p_entry_value14         =>l_inpval_tab(14).value
           ,p_input_value_id15      =>l_inpval_tab(15).input_value_id
           ,p_entry_value15         =>l_inpval_tab(15).value
           ,p_effective_start_date  =>l_effective_start_date
           ,p_effective_end_date    =>l_effective_end_date
           ,p_element_entry_id      =>l_element_entry_id
           ,p_object_version_number =>l_object_version_number
           ,p_create_warning        =>l_create_warning
           );
           --
	--
           -- write to the change event log
           --
           ben_ext_chlg.log_element_chg
             (p_action               => 'CREATE'
             ,p_amt                  => l_per_pay_amt
             ,p_input_value_id       => l_input_value_id
             ,p_element_entry_id     => l_element_entry_id
             ,p_person_id            => p_person_id
             ,p_business_group_id    => p_business_group_id
             ,p_effective_date       => l_effective_date
             );
           --
           -- Change the creator type and id from the default
           --
           py_element_entry_api.update_element_entry
           (p_validate                      =>p_validate
           ,p_datetrack_update_mode         =>hr_api.g_correction
           ,p_effective_date                =>l_effective_date
           ,p_business_group_id             =>p_business_group_id
           ,p_element_entry_id              =>l_element_entry_id
           ,p_override_user_ent_chk         =>'Y'
           ,p_object_version_number         =>l_object_version_number
           ,p_creator_type                  =>'F'
           ,p_creator_id                    =>p_enrt_rslt_id
           ,p_effective_start_date          =>l_effective_start_date
           ,p_effective_end_date            =>l_effective_end_date
           ,p_update_warning                =>l_update_warning
           );

       end loop;

    end if;

    if l_effective_end_date <> hr_api.g_eot and
       l_recurring_entry then

       if l_effective_end_date < l_element_term_rule_date then
          l_message_name := 'BEN_93454_NO_ELK_TILL_EOT';
       else
          l_message_name := 'BEN_93449_NO_ELE_TILL_EOT';
       end if;
       --
       ben_warnings.load_warning
       (p_application_short_name  => 'BEN',
        p_message_name            => l_message_name,
        p_parma => l_element_name,
        p_parmb => to_char(l_effective_end_date),
        p_person_id => p_person_id);
        --
       if fnd_global.conc_request_id not in ( 0,-1) then
           --
           fnd_message.set_name('BEN',l_message_name);
           fnd_message.set_token('PARMA',l_element_name);
           fnd_message.set_token('PARMB',to_char(l_effective_end_date));
           l_string       := fnd_message.get;
           benutils.write(p_text => l_string);
           --
       end if;
       --
    end if;
    --
    -- get the fudged start date to use for the requery
    --
    if l_zero_pp_date is not null then
      l_rt_strt_dt:=l_zero_pp_date;
    elsif l_special_pp_date is not null then
      l_rt_strt_dt:=l_special_pp_date;
    elsif l_normal_pp_date is not null then
      l_rt_strt_dt:=l_normal_pp_date;
    end if;
    --
    if not l_recurring_entry then
       l_non_recurring_ee_id := l_element_entry_id;
    end if;

    open get_element_entry(l_old_element_link_id
                          ,l_assignment_id
                          ,p_enrt_rslt_id
                          ,l_input_value_id
                          ,l_non_recurring_ee_id
                          ,l_rt_strt_dt);
    fetch get_element_entry into
       l_element_entry_id,
       l_ee_effective_start_date,
       l_ee_effective_end_date,
       l_object_version_number,
       l_entry_value_id;
    if get_element_entry%notfound then
      --
      if g_debug then
        hr_utility.set_location('no entry created',140);
      end if;
      close get_element_entry;
      --
      if g_debug then
        hr_utility.set_location('BEN_92102_NO_ENTRY_CREATED',140);
      end if;
      fnd_message.set_name('BEN', 'BEN_92102_NO_ENTRY_CREATED');
      fnd_message.set_token('PROC',l_proc);
      fnd_message.set_token('ELEMENT_ENTRY_ID',to_char(l_old_element_link_id));
      fnd_message.set_token('INPUT_VALUE_ID',to_char(l_input_value_id));
      fnd_message.set_token('EFFECTIVE_DATE',to_char(l_rt_strt_dt));
      fnd_message.raise_error;
      --
    end if;
    close get_element_entry;
    --
    -- If it was a one time rate, i.e. not recurring end it
    --
    if g_debug then
      hr_utility.set_location ('normal_pp_end_date'||l_normal_pp_end_date,293.9);
    end if;
    if l_normal_pp_end_date is not null then
      --
      py_element_entry_api.delete_element_entry
        (p_validate              => p_validate
        ,p_datetrack_delete_mode => hr_api.g_delete
        ,p_effective_date        => l_normal_pp_end_date
        ,p_element_entry_id      => l_element_entry_id
        ,p_object_version_number => l_object_version_number
        ,p_effective_start_date  => l_effective_start_date
        ,p_effective_end_date    => l_effective_end_date
        ,p_delete_warning        => l_delete_warning
        );
      --
      -- write to the change event log
      --
      ben_ext_chlg.log_element_chg
        (p_action               => hr_api.g_delete
        ,p_old_amt              => l_per_pay_amt
        ,p_input_value_id       => l_input_value_id
        ,p_element_entry_id     => l_element_entry_id
        ,p_person_id            => p_person_id
        ,p_business_group_id    => p_business_group_id
        ,p_effective_date       => l_normal_pp_end_date
        );
      --
    end if;
    --
    -- reset l_rt_strt_dt
    --
    l_rt_strt_dt := p_rt_start_date;
    --
    g_max_end_date := null;
    --
    --Bug 3151737 and 3063518 if there is no payroll for the assignment and if
    --it is not required we dont need to compute this.
    --
    if l_payroll_id is null and
       nvl(l_get_abr_info.ele_entry_val_cd, 'PP') not in ('PP', 'EPP') then
      --
       null;
      --
    else
      --
       if nvl(g_per_pay_rec.assignment_id,-1) <> l_assignment_id then
          --
          open c_payroll_was_ever_run
          (c_assignment_id => l_assignment_id
          );
          fetch c_payroll_was_ever_run into l_v2dummy;
          g_per_pay_rec.assignment_id := l_assignment_id;
          g_per_pay_rec.payroll_was_ever_run := c_payroll_was_ever_run%found;
          close c_payroll_was_ever_run;
          --
       end if;
       --
       if g_per_pay_rec.payroll_was_ever_run and
          g_per_pay_rec.end_date is null then
          --
          g_max_end_date :=
              get_max_end_dt (
              p_assignment_id         => l_assignment_id,
              p_payroll_id            => l_payroll_id,
              p_element_type_id       => l_element_type_id,
              p_effective_date        => l_rt_strt_dt);
           g_per_pay_rec.end_date := g_max_end_date;
         --
       elsif g_per_pay_rec.end_date is not null then
          g_max_end_date := g_per_pay_rec.end_date;
       end if;
      --
    end if;
    --
    --
    -- even if there are any run results the entry start date
    -- should be same as rate start date. Payroll retro process will take care
    --
    if g_max_end_date is not null and (g_max_end_date +1) > l_rt_strt_dt
     and not (l_abs_ler) then
     --
     if (g_msg_displayed <>1 )
       -- added for bug: 5607214
       OR fnd_global.conc_request_id not in ( 0,-1)
       then -- 2530582
       --
       -- Issue a warning to the user.  These will display on the enrt forms.
       ben_warnings.load_warning
        (p_application_short_name  => 'BEN',
         p_message_name            => 'BEN_92455_STRT_RUN_RESULTS',
         p_parma     => fnd_date.date_to_chardate(g_max_end_date),
         p_person_id => p_person_id);

       if fnd_global.conc_request_id in ( 0,-1) then
          --
          fnd_message.set_name('BEN','BEN_92455_STRT_RUN_RESULTS');
          fnd_message.set_token('PARMA', fnd_date.date_to_chardate(g_max_end_date));
          l_string       := fnd_message.get;
          benutils.write(p_text => l_string);
          --
       end if;
       g_msg_displayed := 1;
     end if;

     insert_into_quick_pay
        (p_person_id        => p_person_id,
         p_element_type_id  => l_element_type_id,
         p_assignment_id    => l_assignment_id,
         p_element_entry_id => l_element_entry_id,
         p_effective_date   => l_rt_strt_dt,
         p_start_date       => l_rt_strt_dt,
         p_end_date         => g_max_end_date,
         p_payroll_id       => l_payroll_id);
       --
    end if;
    --
    -- Update prtt_rt_val with the new element entry value id
    --
    if g_debug then
      hr_utility.set_location('update prtt_rt_val',180);
    end if;
    --
    if p_prtt_rt_val_id is not null then
       p_prv_object_version_number := nvl(p_prv_object_version_number,
                                          l_prv_rec.object_version_number);
       ben_prtt_rt_val_api.update_prtt_rt_val
      (p_validate                => p_validate
      ,p_business_group_id       => l_prv_rec.business_group_id
      ,p_prtt_rt_val_id          => l_prv_rec.prtt_rt_val_id
      ,p_element_entry_value_id  => l_entry_value_id
      ,p_object_version_number   => p_prv_object_version_number
      ,p_effective_date          => l_rt_strt_dt
      );
    --
    end if;
  end if;
  --
  -- call pqp routine for updating absence balances
  --
  if l_normal_pp_date is not null and
     l_abs_ler then
     if g_debug then
       hr_utility.set_location('Calling pqp_absence_plan_process ',189);
     end if;
     pqp_absence_plan_process.create_absence_plan_details
     (p_person_id               => p_person_id
     ,p_assignment_id           => l_assignment_id
     ,p_business_group_id       => p_business_group_id
     ,p_legislation_code        => get_legislation_code(p_business_group_id)
     ,p_effective_date          => p_effective_date
     ,p_element_type_id         => l_element_type_id
     ,p_pl_id                   => g_result_rec.pl_id
     ,p_pl_typ_id               => g_result_rec.pl_typ_id
     ,p_ler_id                  => l_ler_id
     ,p_per_in_ler_id           => l_per_in_ler_id
     ,p_absence_attendance_id   => l_absence_attendance_id
     ,p_effective_start_date    => l_effective_start_date
     ,p_effective_end_date      => nvl(l_effective_end_date,hr_api.g_eot)
     ,p_formula_outputs         => g_outputs
     ,p_error_code              => l_err_code
     ,p_error_message           => l_err_mesg
     );
  end if;
  --
  if g_debug then
    hr_utility.set_location('element_entry_id='||l_element_entry_id,189);
    hr_utility.set_location('Leaving: '||l_proc,190);
  end if;
  --

  p_element_entry_value_id              := l_entry_value_id;
  g_creee_calc_vals.element_entry_id    := l_element_entry_id;
  g_creee_calc_vals.zero_pp_date        := l_zero_pp_date;
  g_creee_calc_vals.special_pp_date     := l_special_pp_date;
  g_creee_calc_vals.special_amt         := l_special_amt;
  g_creee_calc_vals.normal_pp_date      := l_normal_pp_date;
  g_creee_calc_vals.normal_amt          := l_per_pay_amt;
  g_creee_calc_vals.normal_pp_end_date  := l_normal_pp_end_date;
  g_creee_calc_vals.prtn_flag           := l_prtn_flag;
  g_creee_calc_vals.first_pp_adjustment := l_first_pp_adjustment;
  g_creee_calc_vals.rt_strt_dt          := l_rt_strt_dt;
  g_creee_calc_vals.range_start         := l_range_start;
  g_creee_calc_vals.last_pp_end_dt      := l_last_pp_end_dt;
  g_creee_calc_vals.payroll_id          := l_payroll_id;
  --
end create_enrollment_element;
--
-- ----------------------------------------------------------------------------
-- |-------------------< reopen_closed_enrollment >--------------------------|
-- ----------------------------------------------------------------------------
procedure reopen_closed_enrollment
(p_validate                in boolean
,p_business_group_id       in number
,p_person_id               in number
,p_acty_base_rt_id         in number
,p_element_type_id         in number
,p_prtt_rt_val_id          in number
,p_input_value_id          in number
,p_rt                      in number
,p_rt_start_date           in date
,p_effective_date          in date
) is

cursor get_abr_info (p_acty_base_rt_id in number,
                     p_effective_date date) is
  select abr.ele_rqd_flag,
         abr.input_va_calc_rl,
         abr.element_type_id,
         abr.input_value_id,
         abr.prtl_mo_det_mthd_cd
    from ben_acty_base_rt_f abr
   where abr.acty_base_rt_id=p_acty_base_rt_id
     and p_effective_date between
         abr.effective_start_date and abr.effective_end_date;
--
l_abr_info get_abr_info%rowtype;
--
cursor c_ele_info (p_person_id              in number,
                   p_prtt_enrt_rslt_id      in number,
                   p_element_entry_value_id in number) is
  select pee.element_entry_id,
         asg.assignment_id,
         asg.payroll_id,
         pet.element_name,
         pet.multiple_entries_allowed_flag,
         pel.element_type_id,
         pev.input_value_id
    from per_all_assignments_f asg,
         pay_element_links_f pel,
         pay_element_types_f pet,
         pay_element_entries_f pee,
         pay_element_entry_values_f pev
   where asg.person_id = p_person_id
     and asg.assignment_id = pee.assignment_id
     and pee.effective_start_date between asg.effective_start_date
     and asg.effective_end_date
     and pev.element_entry_value_id = p_element_entry_value_id
     and pee.element_entry_id = pev.element_entry_id
     and pee.creator_id = p_prtt_enrt_rslt_id
     and pee.creator_type = 'F'
     and pee.entry_type = 'E'
     and pev.effective_start_date between pee.effective_start_date
     and pee.effective_end_date
     and pel.element_link_id = pee.element_link_id
     and pee.effective_start_date between pel.effective_start_date
     and pel.effective_end_date
     and pet.element_type_id = pel.element_type_id
     and pel.effective_start_date between pet.effective_start_date
     and pet.effective_end_date;
--
-- Cursor to get the entry to be reopened
--
cursor get_last_element_entry
  (p_element_type_id   in number
  ,p_input_value_id    in number
  ,p_assignment_id     in number
  ,p_prtt_enrt_rslt_id in number
  ,p_effective_date    in date
  )
is
  select ele.element_entry_id,
         ele.element_link_id,
         ele.effective_start_date,
         ele.effective_end_date,
         pev.screen_entry_value,
         ele.object_version_number
  from   pay_element_entries_f ele,
         pay_element_entry_values_f pev,
         pay_element_links_f elk
  where  ele.creator_id = p_prtt_enrt_rslt_id
  and    ele.creator_type = 'F'
  and    ele.entry_type = 'E'
  and    ele.assignment_id   = p_assignment_id
  and    ele.element_link_id = elk.element_link_id
  and    ele.effective_start_date between elk.effective_start_date
  and    elk.effective_end_date
  and    elk.element_type_id = p_element_type_id
  and    pev.element_entry_id = ele.element_entry_id
  and    pev.input_value_id = p_input_value_id
  and    pev.effective_start_date between ele.effective_start_date
  and    ele.effective_end_date
  order by ele.effective_start_date desc;
--
cursor c_current_ee
  (p_element_type_id in number
  ,p_prtt_enrt_rslt_id in number
  ,p_assignment_id in number
  ,p_effective_date in date
  ) is
  select ele.element_entry_id,
         ele.effective_start_date,
         ele.effective_end_date,
         ele.object_version_number
  from   pay_element_entries_f ele,
         pay_element_links_f elk
  where  p_effective_date between ele.effective_start_date
  and    ele.effective_end_date
  and    ele.assignment_id   = p_assignment_id
  and    ele.element_link_id = elk.element_link_id
  and    ele.effective_start_date between elk.effective_start_date
  and    elk.effective_end_date
  and    elk.element_type_id = p_element_type_id
  and    ele.creator_type ='F'
  and    ele.entry_type = 'E'
  and    nvl(ele.creator_id,-1) <> p_prtt_enrt_rslt_id
  order by ele.effective_start_date desc;
l_current_ee_rec c_current_ee%rowtype;
--
cursor c_min_max_dt(p_element_entry_id number) is
select min(effective_start_date),
       max(effective_end_date)
  from pay_element_entries_f
 where element_entry_id = p_element_entry_id;
--
cursor c_chk_abs_ler (c_per_in_ler_id  number,
                      c_effective_date date)  is
select pil.per_in_ler_id,
       pil.trgr_table_pk_id,
       ler.ler_id
  from ben_per_in_ler pil,
       ben_ler_f ler
 where pil.per_in_ler_id = c_per_in_ler_id
   and ler.ler_id = pil.ler_id
   and ler.typ_cd ='ABS'
   and c_effective_date between
       ler.effective_start_date and ler.effective_end_date;
--
-- bug 7206471
--
Cursor c_adjust_exists is
select leclr.*
from ben_le_clsn_n_rstr leclr
     ,ben_prtt_rt_val prv
     ,ben_acty_base_rt_f abr
where bkup_tbl_typ_cd = 'BEN_PRTT_RT_VAL_ADJ'
and   bkup_tbl_id = prv.prtt_rt_val_id
and   prv.acty_base_rt_id = abr.acty_base_rt_id
and   abr.element_type_id = p_element_type_id;
--
l_adjust_exists ben_le_clsn_n_rstr%rowtype;
--
-- -- bug 7206471
--
l_prtt_enrt_rslt_id number;
l_absence_attendance_id number;
l_per_in_ler_id number;
l_ler_id number;
l_abs_ler       boolean := false;
l_input_value_id number;
l_input_va_calc_rl number;
l_element_entry_id NUMBER;
l_screen_entry_value NUMBER;
l_ext_chg_evt_log_id NUMBER;
l_ext_object_version_number NUMBER;
l_object_version_number NUMBER;
l_effective_start_date DATE;
l_effective_end_date DATE;
l_effective_date DATE;
l_assignment_id  NUMBER;
l_organization_id NUMBER;
l_payroll_id NUMBER;
l_delete_warning BOOLEAN;
l_dummy_number   number;
l_ele_rqd_flag   VARCHAR2(30);
l_jurisdiction_code  varchar2(30);
l_subpriority    number;
l_err_code       varchar2(10);
l_err_mesg       varchar2(2000);
l_update_warning boolean;
l_create_ee                  boolean  := false;
l_create_warning             boolean;
l_dummy_date                 date;
l_out_date_not_required      date;
l_asg_max_eligibility_date   date;
l_element_term_rule_date     date;
l_element_link_end_date      date;
l_element_name               varchar2(80);
l_recurring_end_date         date;
l_element_link_id            number;
l_element_type_id            number;
l_multiple_entries_flag varchar2(1);
l_new_element_link_id   number;
l_encoded_message   varchar2(2000);
l_app_short_name    varchar2(2000);
l_message_name      varchar2(2000);
l_dt_del_mode       varchar2(30);
l_prv_ovn           number;
l_inpval_tab        inpval_tab_typ;
l_string                varchar2(4000);
l_min_start_date            date;
l_max_end_date              date;
l_proc        VARCHAR2(72) := g_package||'reopen_closed_enrollment';

-- 3266166
l_uom				varchar2(30);
l_screen_entry_value_var	varchar2(60);
l_recompute_proration           boolean := false;
l_v2dummy                       varchar2(30);
l_date				date;
--


begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    hr_utility.set_location('Entering: '||l_proc,5);
    hr_utility.set_location('p_eff_dt: '||to_char(p_effective_date),5);
    hr_utility.set_location('p_prtt_rt_val_id: '||p_prtt_rt_val_id,5);
  end if;
  --
  --BUG 3167959 We need to intialize the pl/sql table
  clear_ext_inpval_tab ;
  --
  -- get prv info
  --
  open c_get_prtt_rt_val
    (c_prtt_rt_val_id => p_prtt_rt_val_id
    );
  fetch c_get_prtt_rt_val into l_prv_rec;
  if c_get_prtt_rt_val%notfound
  then
    --
    if g_debug then
      hr_utility.set_location('BEN_92103_NO_PRTT_RT_VAL',170);
    end if;
    close c_get_prtt_rt_val;
    --
    fnd_message.set_name('BEN', 'BEN_92103_NO_PRTT_RT_VAL');
    fnd_message.set_token('PROC',l_proc);
    fnd_message.set_token('PRTT_RT_VAL',to_char(p_prtt_rt_val_id));
    fnd_message.raise_error;
    --
  end if;
  close c_get_prtt_rt_val;
  --
  -- if no element entry was created to start with, just return
  --
  if l_prv_rec.element_entry_value_id is null then
     if g_debug then
        hr_utility.set_location('No entry. Leaving: '||l_proc,60);
     end if;
     return;
  end if;
  --
  -- get activity base rate information
  --
  open get_abr_info(l_prv_rec.acty_base_rt_id,
                    l_prv_rec.rt_strt_dt);
  fetch get_abr_info into l_abr_info;
  if get_abr_info%notfound then
    close get_abr_info;
    if g_debug then
      hr_utility.set_location('BEN_91723_NO_ENRT_RT_ABR_FOUND',30);
    end if;
    fnd_message.set_name('BEN','BEN_91723_NO_ENRT_RT_ABR_FOUND');
    fnd_message.set_token('PROC',l_proc);
    fnd_message.set_token('ACTY_BASE_RT_ID',to_char(p_acty_base_rt_id));
    fnd_message.set_token('EFFECTIVE_DATE',to_char(p_effective_date));
    fnd_message.raise_error;
  end if;
  close get_abr_info;
  --
  -- get the element type and input value based on entry value attached to
  -- prtt rt. Do NOT get them from abr for reopening
  --
  hr_utility.set_location('p_person_id: '||p_person_id,5);
  hr_utility.set_location('prtt_enrt_rslt_id: '||l_prv_rec.prtt_enrt_rslt_id,5);
  hr_utility.set_location('l_prv_rec.element_entry_value_id: '||l_prv_rec.element_entry_value_id,5);

  open c_ele_info(p_person_id,
                  l_prv_rec.prtt_enrt_rslt_id,
                  l_prv_rec.element_entry_value_id);
  fetch c_ele_info into
    l_element_entry_id,
    l_assignment_id,
    l_payroll_id,
    l_element_name,
    l_multiple_entries_flag,
    l_element_type_id,
    l_input_value_id;
  close c_ele_info;

  if g_debug then
    hr_utility.set_location(' l_asg_id: '||l_assignment_id,50);
    hr_utility.set_location(' p_elt_id: '||l_element_type_id,50);
    hr_utility.set_location(' p_inp_val: '||l_input_value_id,50);
    hr_utility.set_location(' l_ele_id: '||l_element_entry_id,50);
    hr_utility.set_location(' l_ele_id: '||l_element_entry_id,50);
  end if;
  --
  -- If the abr has proration defined we will need to recompute
  -- the prorated amounts
  --
  -- This still does not address the case, where there is a special pp
  -- because of rounding. Will address that issue in a future version
  --
  hr_utility.set_location('prtl_mo_det_mthd_cd: '||l_abr_info.prtl_mo_det_mthd_cd,50);
  if nvl(l_abr_info.prtl_mo_det_mthd_cd,'NONE') <> 'NONE' then
     l_recompute_proration := true;
  end if;

  -- <ELE>
  if l_element_entry_id is null or
     l_recompute_proration then
     --
     -- This is for the case when the entry attached to prtt rt got zapped.
     -- Possible 1) prior to FP C when ct. could delete the entries
     --          2) prior to retro pay changes
     --
     -- Also for the case when we need to recompute prorated amounts
     --
     get_abr_assignment (p_person_id       => p_person_id
                        ,p_effective_date  => l_prv_rec.rt_strt_dt
                        ,p_acty_base_rt_id => l_prv_rec.acty_base_rt_id
                        ,p_organization_id => l_dummy_number
                        ,p_payroll_id      => l_payroll_id
                        ,p_assignment_id   => l_assignment_id);

     open c_current_ee(l_abr_info.element_type_id,
                       l_prv_rec.prtt_enrt_rslt_id,
                       l_assignment_id,
                       l_prv_rec.rt_strt_dt);
     fetch c_current_ee into l_current_ee_rec;
     close c_current_ee;
     --
     if l_element_entry_id is null and
        l_current_ee_rec.element_entry_id is not null then
        --
        -- Determine dt track mode.
        --
        open c_min_max_dt(l_current_ee_rec.element_entry_id);
        fetch c_min_max_dt into l_min_start_date,l_max_end_date;
        close c_min_max_dt;

        if l_prv_rec.rt_strt_dt-1 < l_min_start_date then
           l_dt_del_mode := hr_api.g_zap;
        else
           l_dt_del_mode := hr_api.g_delete;
        end if;

        l_effective_date :=
          greatest(l_current_ee_rec.effective_start_date,l_prv_rec.rt_strt_dt -1);

        py_element_entry_api.delete_element_entry
        (p_validate                  =>p_validate
        ,p_datetrack_delete_mode     =>l_dt_del_mode
        ,p_effective_date            =>l_effective_date
        ,p_element_entry_id          =>l_current_ee_rec.element_entry_id
        ,p_object_version_number     =>l_current_ee_rec.object_version_number
        ,p_effective_start_date      =>l_dummy_date
        ,p_effective_end_date        =>l_dummy_date
        ,p_delete_warning            =>l_delete_warning);
       --
       -- write to the change event log
       --
       ben_ext_chlg.log_element_chg(
       p_action               => hr_api.g_delete,
       p_old_amt              => null,
       p_input_value_id       => l_abr_info.input_value_id,
       p_element_entry_id     => l_current_ee_rec.element_entry_id,
       p_person_id            => p_person_id,
       p_business_group_id    => p_business_group_id,
       p_effective_date       => l_prv_rec.rt_strt_dt -1 );

     end if;
     --
     create_enrollment_element
     (p_business_group_id        => p_business_group_id
     ,p_prtt_rt_val_id           => p_prtt_rt_val_id
     ,p_person_id                => p_person_id
     ,p_acty_ref_perd            => l_prv_rec.acty_ref_perd_cd
     ,p_acty_base_rt_id          => l_prv_rec.acty_base_rt_id
     ,p_enrt_rslt_id             => l_prv_rec.prtt_enrt_rslt_id
     ,p_rt_start_date            => l_prv_rec.rt_strt_dt
     ,p_rt                       => l_prv_rec.rt_val
     ,p_cmncd_rt                 => l_prv_rec.cmcd_rt_val
     ,p_ann_rt                   => l_prv_rec.ann_rt_val
     ,p_input_value_id           => l_abr_info.input_value_id
     ,p_element_type_id          => l_abr_info.element_type_id
     ,p_prv_object_version_number=> l_prv_ovn
     ,p_effective_date           => l_prv_rec.rt_strt_dt
     ,p_eev_screen_entry_value   => l_dummy_number
     ,p_element_entry_value_id   => l_dummy_number
     );
  else
     --
     -- get the element entry that needs to be reopened. This entry could be
     -- different from what is attached to prtt rt
     --
     if g_debug then
        hr_utility.set_location('enrt_rslt_id='||l_prv_rec.prtt_enrt_rslt_id,10);
        hr_utility.set_location('rt_strt_dt='||l_prv_rec.rt_strt_dt,10);
     end if;

     open get_last_element_entry(l_element_type_id,
                                 l_input_value_id,
                                 l_assignment_id,
                                 l_prv_rec.prtt_enrt_rslt_id,
                                 l_prv_rec.rt_strt_dt);
     fetch get_last_element_entry into
       l_element_entry_id
      ,l_element_link_id
      ,l_effective_start_date
      ,l_effective_end_date
      ,l_screen_entry_value_var
      ,l_object_version_number;

     -- 3266166
     hr_utility.set_location('l_screen_entry_value_var='||l_screen_entry_value_var,10);
     --
     if l_uom is null then
       if nvl(g_result_rec.prtt_enrt_rslt_id,-1)<>l_prv_rec.prtt_enrt_rslt_id
       then
           open c_current_result_info (c_prtt_enrt_rslt_id  => l_prv_rec.prtt_enrt_rslt_id);
           fetch c_current_result_info into g_result_rec;
           close c_current_result_info;
       end if;
       --
       if g_result_rec.uom is not null
       then
           l_uom := g_result_rec.uom;
       else
           l_uom := get_uom(p_business_group_id,p_effective_date);
       end if;
     end if;
     --
     l_screen_entry_value := chkformat(l_screen_entry_value_var, l_uom);
     hr_utility.set_location('l_screen_entry_value='||l_screen_entry_value,10);
     --
     if get_last_element_entry%notfound
     then
       if g_debug then
         hr_utility.set_location('BEN_92105_NO_PRIOR_ENROLLMENT',40);
       end if;
       close get_last_element_entry;
       fnd_message.set_name('BEN', 'BEN_92105_NO_PRIOR_ENROLLMENT');
       fnd_message.set_token('PROC',l_proc);
       fnd_message.set_token('ELEMENT_TYPE_ID',to_char(l_element_type_id));
       fnd_message.set_token('ASSGN_ID',to_char(l_assignment_id));
       fnd_message.set_token('PRTT_RT_VAL_ID',to_char(p_prtt_rt_val_id));
       fnd_message.raise_error;
       --
     end if;
     close get_last_element_entry;

     if g_debug then
        hr_utility.set_location(' l_ele_id: '||l_element_entry_id,50);
        hr_utility.set_location(' l_esd: '||l_effective_start_date,50);
        hr_utility.set_location(' l_eed: '||l_effective_end_date,50);
     end if;

     l_effective_date := l_effective_end_date;
     g_max_end_date := null;
     --
     -- for quick pay fix
     --
     --Bug 3151737 and 3063518 we need to do this if payroll exists for the
     --assignment else skip this part.
     --
     if l_payroll_id is not null then
        --
        if nvl(g_per_pay_rec.assignment_id,-1) <> l_assignment_id then
           --
           open c_payroll_was_ever_run
           (c_assignment_id => l_assignment_id
           );
           fetch c_payroll_was_ever_run into l_v2dummy;
           g_per_pay_rec.assignment_id := l_assignment_id;
           g_per_pay_rec.payroll_was_ever_run := c_payroll_was_ever_run%found;
           close c_payroll_was_ever_run;
           --
        end if;
        --
        if g_per_pay_rec.payroll_was_ever_run and
           g_per_pay_rec.end_date is null then
           --
           g_max_end_date :=
              get_max_end_dt (
              p_assignment_id         => l_assignment_id,
              p_payroll_id            => l_payroll_id,
              p_element_type_id       => l_element_type_id,
              p_effective_date        => l_effective_date);
           --
           g_per_pay_rec.end_date := g_max_end_date;
           --
        elsif g_per_pay_rec.end_date is not null then
            g_max_end_date := g_per_pay_rec.end_date;
        end if;

        if g_max_end_date > l_effective_date then
           -- insert rows into pay_quickpay_inclusions
           insert_into_quick_pay
           (p_person_id => p_person_id,
           p_element_type_id => l_element_type_id,
           p_assignment_id => l_assignment_id,
           p_element_entry_id => l_element_entry_id,
           p_effective_date => l_effective_date,
           p_start_date  => l_effective_date,
           p_end_date   => g_max_end_date,
           p_payroll_id  => l_payroll_id);
           --
        end if;
        --
     end if ; -- l_payroll_id
     --
     hr_entry.entry_asg_pay_link_dates (l_assignment_id,
                                        l_element_link_id,
                                        l_effective_start_date,
                                        l_element_term_rule_date,
                                        l_out_date_not_required,
                                        l_element_link_end_date,
                                        l_out_date_not_required,
                                        l_out_date_not_required);

     --
     --
     if g_debug then
     hr_utility.set_location('l_element_term_rule_date '||l_element_term_rule_date,44333);
     hr_utility.set_location('l_element_link_end_date '||l_element_link_end_date,44333);
     hr_utility.set_location('l_effective_date '||l_effective_date,44333);
     end if;
     -- Call update
     --
   /*
      Before :-
         02-JAN-1994  05-FEB-1994              08-AUG-1995
             |-A----------|-B----------------------|
                                       ED
      After :-
         02-JAN-1994  05-FEB-1994
             |-A----------|-E------------------------------------------------->
                                       ED
   */
     if g_debug then
       hr_utility.set_location(' l_element_entry_id: '||l_element_entry_id,50);
       hr_utility.set_location(' l_effective_date: '||l_effective_date,50);
       hr_utility.set_location(' l_ovn: '||l_object_version_number,50);
     end if;
     --

     -- <REOPEN>
     if l_effective_date <> hr_api.g_eot then
          --
          -- check if abs ler
          --
          open c_chk_abs_ler
          (c_per_in_ler_id  => l_prv_rec.per_in_ler_id
          ,c_effective_date => p_effective_date
          );
          fetch c_chk_abs_ler into
            l_per_in_ler_id,
            l_absence_attendance_id,
            l_ler_id;
          l_abs_ler := c_chk_abs_ler%found;
          close c_chk_abs_ler;

          --
          -- handle any future entries
          --
	  open c_adjust_exists; -- bug 7206471
	  fetch c_adjust_exists into l_adjust_exists; -- bug 7206471
	  if c_adjust_exists%notfound then -- bug 7206471
          if not l_abs_ler then
             chk_future_entries
            (p_validate              => p_validate,
             p_person_id             => p_person_id,
             p_assignment_id         => l_assignment_id,
             p_enrt_rslt_id          => l_prv_rec.prtt_enrt_rslt_id,
             p_element_type_id       => l_element_type_id,
             p_multiple_entries_flag => l_multiple_entries_flag,
             p_effective_date        => l_effective_date);
          end if;
	  end if; -- bug 7206471
	  close c_adjust_exists; -- bug 7206471

          if l_element_link_end_date <> l_effective_date and
             l_element_term_rule_date <> l_effective_date then

             begin
                --
                hr_utility.set_location('before pay.delete l_effective_date '||l_effective_date,44333);
		--
                py_element_entry_api.delete_element_entry
                (p_validate              =>p_validate
                ,p_datetrack_delete_mode =>'FUTURE_CHANGE'
                ,p_effective_date        =>l_effective_date
                ,p_element_entry_id      =>l_element_entry_id
                ,p_object_version_number =>l_object_version_number
                ,p_effective_start_date  =>l_effective_start_date
                ,p_effective_end_date    =>l_effective_end_date
                ,p_delete_warning        =>l_delete_warning);
		--
		hr_utility.set_location('after pay.delete l_effective_date '||l_effective_date,44333);
                hr_utility.set_location('l_effective_end_date '||l_effective_end_date,44333);
		--
                l_effective_date := l_effective_end_date;
                --
                -- write to the change event log
                --
                ben_ext_chlg.log_element_chg(
                p_action               => hr_api.g_delete,
                p_old_amt              => null,
                p_input_value_id       => l_input_value_id,
                p_element_entry_id     => l_element_entry_id,
                p_person_id            => p_person_id,
                p_business_group_id    => p_business_group_id,
                p_effective_date       => l_effective_date);
                --
             exception
                 when others then
                   ben_on_line_lf_evt.get_ser_message(l_encoded_message,
                                              l_app_short_name,
                                              l_message_name);
                   l_encoded_message := fnd_message.get;
                   --
                   if l_message_name like '%HR_6284_ELE_ENTRY_DT_ASG_DEL%'  or
                      l_message_name like '%HR_7187_DT_CANNOT_EXTEND_END%' then
                      --
                      --asg is not eligible for link beyond l_effective_date
                      --
                      null;
                   else
                      if l_app_short_name is not null then
                         fnd_message.set_name(l_app_short_name,l_message_name);
                         fnd_message.raise_error;
                      else
                         raise;
                      end if;
                   end if;
             end;
          end if;
          --
          loop

              if l_effective_date = l_element_term_rule_date then
                --
                -- Element entry created till the max possible date.
                --
                exit;
              end if;

              if l_abs_ler then
              -- bug # 7383673, 7390204 -- restricting bug 6450363 fix only for absences

                -- added here for bug 6450363

	             l_date := l_effective_date + 1;
	             if g_debug then
                  hr_utility.set_location('l_effective_date '||l_effective_date,44333);
	               hr_utility.set_location('l_effective_date + 1 '||l_date,44333);
	             end if;

	             get_abr_assignment (p_person_id       => p_person_id
                        ,p_effective_date  => l_effective_date + 1
                        ,p_acty_base_rt_id => l_prv_rec.acty_base_rt_id
                        ,p_organization_id => l_dummy_number
                        ,p_payroll_id      => l_payroll_id
                        ,p_assignment_id   => l_assignment_id);

                --added till here for bug 6450363
              end if;

              get_link
              (p_assignment_id     => l_assignment_id
              ,p_element_type_id   => l_element_type_id
              ,p_business_group_id => p_business_group_id
              ,p_input_value_id    => l_input_value_id
              ,p_effective_date    => l_effective_date + 1
              ,p_element_link_id   => l_new_element_link_id);

               if l_new_element_link_id = l_element_link_id or
                  l_new_element_link_id is null then
                  --
                  -- No new link found. Get out of the loop
                  --
                  exit;
               end if;

               if nvl(l_inpval_tab.count,0) = 0 then
                  get_inpval_tab(l_element_entry_id,
                                 l_effective_date,
                                 l_inpval_tab);
               end if;

               l_element_link_id := l_new_element_link_id;
               l_effective_date := l_effective_date + 1;

               py_element_entry_api.create_element_entry
               (p_validate              =>p_validate
               ,p_effective_date        =>l_effective_date
               ,p_business_group_id     =>p_business_group_id
               ,p_assignment_id         =>l_assignment_id
               ,p_element_link_id       =>l_element_link_id
               ,p_entry_type            =>'E'
               ,p_override_user_ent_chk =>'Y'
               ,p_subpriority           =>l_subpriority
               ,p_input_value_id1       =>l_inpval_tab(1).input_value_id
               ,p_entry_value1          =>l_inpval_tab(1).value
               ,p_input_value_id2       =>l_inpval_tab(2).input_value_id
               ,p_entry_value2          =>l_inpval_tab(2).value
               ,p_input_value_id3       =>l_inpval_tab(3).input_value_id
               ,p_entry_value3          =>l_inpval_tab(3).value
               ,p_input_value_id4       =>l_inpval_tab(4).input_value_id
               ,p_entry_value4          =>l_inpval_tab(4).value
               ,p_input_value_id5       =>l_inpval_tab(5).input_value_id
               ,p_entry_value5          =>l_inpval_tab(5).value
               ,p_input_value_id6       =>l_inpval_tab(6).input_value_id
               ,p_entry_value6          =>l_inpval_tab(6).value
               ,p_input_value_id7       =>l_inpval_tab(7).input_value_id
               ,p_entry_value7          =>l_inpval_tab(7).value
               ,p_input_value_id8       =>l_inpval_tab(8).input_value_id
               ,p_entry_value8          =>l_inpval_tab(8).value
               ,p_input_value_id9       =>l_inpval_tab(9).input_value_id
               ,p_entry_value9          =>l_inpval_tab(9).value
               ,p_input_value_id10      =>l_inpval_tab(10).input_value_id
               ,p_entry_value10         =>l_inpval_tab(10).value
               ,p_input_value_id11      =>l_inpval_tab(11).input_value_id
               ,p_entry_value11         =>l_inpval_tab(11).value
               ,p_input_value_id12      =>l_inpval_tab(12).input_value_id
               ,p_entry_value12         =>l_inpval_tab(12).value
               ,p_input_value_id13      =>l_inpval_tab(13).input_value_id
               ,p_entry_value13         =>l_inpval_tab(13).value
               ,p_input_value_id14      =>l_inpval_tab(14).input_value_id
               ,p_entry_value14         =>l_inpval_tab(14).value
               ,p_input_value_id15      =>l_inpval_tab(15).input_value_id
               ,p_entry_value15         =>l_inpval_tab(15).value
               ,p_effective_start_date  =>l_effective_start_date
               ,p_effective_end_date    =>l_effective_end_date
               ,p_element_entry_id      =>l_element_entry_id
               ,p_object_version_number =>l_object_version_number
               ,p_create_warning        =>l_create_warning
               );

               py_element_entry_api.update_element_entry
               (p_validate              =>p_validate
               ,p_datetrack_update_mode =>hr_api.g_correction
               ,p_effective_date        =>l_effective_date
               ,p_business_group_id     =>p_business_group_id
               ,p_element_entry_id      =>l_element_entry_id
               ,p_override_user_ent_chk =>'Y'
               ,p_object_version_number =>l_object_version_number
               ,p_creator_type          =>'F'
               ,p_creator_id            =>l_prv_rec.prtt_enrt_rslt_id
               ,p_effective_start_date  =>l_effective_start_date
               ,p_effective_end_date    =>l_effective_end_date
               ,p_update_warning        =>l_update_warning
               );
               --
               -- write to the change event log
               --
               ben_ext_chlg.log_element_chg(
               p_action               => 'CREATE',
               p_amt                  => l_screen_entry_value,
               p_input_value_id       => l_input_value_id,
               p_element_entry_id     => l_element_entry_id,
               p_person_id            => p_person_id,
               p_business_group_id    => p_business_group_id,
               p_effective_date       => l_effective_date);
               --

               l_effective_date := l_effective_end_date;

          end loop;

          if l_effective_date <> hr_api.g_eot then

             if l_effective_date < l_element_term_rule_date then
                l_message_name := 'BEN_93454_NO_ELK_TILL_EOT';
             else
                l_message_name := 'BEN_93449_NO_ELE_TILL_EOT';
             end if;

             --
             ben_warnings.load_warning
             (p_application_short_name  => 'BEN',
             p_message_name            => l_message_name,
             p_parma => l_element_name,
             p_parmb => to_char(l_effective_date),
             p_person_id => p_person_id);
                --
             if fnd_global.conc_request_id in ( 0,-1) then
                --
                fnd_message.set_name('BEN',l_message_name);
                fnd_message.set_token('PARMA',l_element_name);
                fnd_message.set_token('PARMB',to_char(l_effective_date));
                l_string       := fnd_message.get;
                benutils.write(p_text => l_string);
                --
             end if;

          end if;
          -- <ABS>
          if l_abs_ler then

             if nvl(g_result_rec.prtt_enrt_rslt_id,-1)<>l_prv_rec.prtt_enrt_rslt_id then
               open c_current_result_info
                 (c_prtt_enrt_rslt_id  => l_prv_rec.prtt_enrt_rslt_id
                 );
               fetch c_current_result_info into g_result_rec;
               close c_current_result_info;
             end if;

             get_extra_ele_inputs
             (p_effective_date         => l_effective_date
             ,p_person_id              => p_person_id
             ,p_business_group_id      => p_business_group_id
             ,p_assignment_id          => l_assignment_id
             ,p_element_link_id        => null
             ,p_entry_type             => 'E'
             ,p_input_value_id1        => l_input_value_id
             ,p_entry_value1           => l_screen_entry_value
             ,p_element_entry_id       => l_element_entry_id
             ,p_acty_base_rt_id        => p_acty_base_rt_id
             ,p_input_va_calc_rl       => l_abr_info.input_va_calc_rl
             ,p_abs_ler                => l_abs_ler
             ,p_organization_id        => l_organization_id
             ,p_payroll_id             => l_payroll_id
             ,p_pgm_id                 => g_result_rec.pgm_id
             ,p_pl_id                  => g_result_rec.pl_id
             ,p_pl_typ_id              => g_result_rec.pl_typ_id
             ,p_opt_id                 => g_result_rec.opt_id
             ,p_ler_id                 => l_ler_id
             ,p_dml_typ                => 'U'
             ,p_jurisdiction_code      => l_jurisdiction_code
             ,p_ext_inpval_tab         => g_ext_inpval_tab
             ,p_subpriority            => l_subpriority
             );

             py_element_entry_api.update_element_entry
             (p_validate               =>p_validate
             ,p_datetrack_update_mode  =>hr_api.g_correction
             ,p_effective_date         =>l_effective_date
             ,p_business_group_id      =>p_business_group_id
             ,p_element_entry_id       =>l_element_entry_id
             ,p_object_version_number  =>l_object_version_number
             ,p_creator_type           =>'F'
             ,p_creator_id             =>l_prv_rec.prtt_enrt_rslt_id
             ,p_subpriority            =>l_subpriority
             ,p_override_user_ent_chk  =>'Y'
             ,p_input_value_id1        =>g_ext_inpval_tab(1).input_value_id
             ,p_entry_value1           =>g_ext_inpval_tab(1).return_value
             ,p_input_value_id2        =>g_ext_inpval_tab(2).input_value_id
             ,p_entry_value2           =>g_ext_inpval_tab(2).return_value
             ,p_input_value_id3        =>g_ext_inpval_tab(3).input_value_id
             ,p_entry_value3           =>g_ext_inpval_tab(3).return_value
             ,p_input_value_id4        =>g_ext_inpval_tab(4).input_value_id
             ,p_entry_value4           =>g_ext_inpval_tab(4).return_value
             ,p_input_value_id5        =>g_ext_inpval_tab(5).input_value_id
             ,p_entry_value5           =>g_ext_inpval_tab(5).return_value
             ,p_input_value_id6        =>g_ext_inpval_tab(6).input_value_id
             ,p_entry_value6           =>g_ext_inpval_tab(6).return_value
             ,p_input_value_id7        =>g_ext_inpval_tab(7).input_value_id
             ,p_entry_value7           =>g_ext_inpval_tab(7).return_value
             ,p_input_value_id8        =>g_ext_inpval_tab(8).input_value_id
             ,p_entry_value8           =>g_ext_inpval_tab(8).return_value
             ,p_input_value_id9        =>g_ext_inpval_tab(9).input_value_id
             ,p_entry_value9           =>g_ext_inpval_tab(9).return_value
             ,p_input_value_id10       =>g_ext_inpval_tab(10).input_value_id
             ,p_entry_value10          =>g_ext_inpval_tab(10).return_value
             ,p_input_value_id11       =>g_ext_inpval_tab(11).input_value_id
             ,p_entry_value11          =>g_ext_inpval_tab(11).return_value
             ,p_input_value_id12       =>g_ext_inpval_tab(12).input_value_id
             ,p_entry_value12          =>g_ext_inpval_tab(12).return_value
             ,p_input_value_id13       =>g_ext_inpval_tab(13).input_value_id
             ,p_entry_value13          =>g_ext_inpval_tab(13).return_value
             ,p_input_value_id14       =>g_ext_inpval_tab(14).input_value_id
             ,p_entry_value14          =>g_ext_inpval_tab(14).return_value
             ,p_effective_start_date   =>l_effective_start_date
             ,p_effective_end_date     =>l_effective_end_date
             ,p_update_warning         =>l_update_warning
             );

             pqp_absence_plan_process.update_absence_plan_details
             (p_person_id               => p_person_id
             ,p_assignment_id           => l_assignment_id
             ,p_business_group_id       => p_business_group_id
             ,p_legislation_code        => get_legislation_code(p_business_group_id)
             ,p_effective_date          => l_effective_date
             ,p_element_type_id         => l_element_type_id
             ,p_pl_id                   => g_result_rec.pl_id
             ,p_pl_typ_id               => g_result_rec.pl_typ_id
             ,p_ler_id                  => l_ler_id
             ,p_per_in_ler_id           => l_per_in_ler_id
             ,p_absence_attendance_id   => l_absence_attendance_id
             ,p_effective_start_date    => l_effective_start_date
             ,p_effective_end_date      => l_effective_end_date
             ,p_formula_outputs         => g_outputs
             ,p_error_code              => l_err_code
             ,p_error_message           => l_err_mesg
             );
          end if; -- <ABS>
     end if; -- <REOPEN>
  end if; -- <ELE>
  --
  if g_debug then
    hr_utility.set_location('Leaving: '||l_proc,60);
  end if;
  --
end reopen_closed_enrollment;
--
-- ----------------------------------------------------------------------------
-- |----------------------< recreate_enrollment_element >----------------------|
-- ----------------------------------------------------------------------------
procedure recreate_enrollment_element(p_validate IN BOOLEAN default FALSE
                                ,p_business_group_id IN NUMBER
                                ,p_person_id IN NUMBER
                                ,p_enrt_rslt_id IN NUMBER
                                ,p_acty_ref_perd in varchar2
                                ,p_acty_base_rt_id in number
                                ,p_element_entry_id IN NUMBER
                                ,p_element_link_id IN NUMBER
                                ,p_input_value_id IN NUMBER
                                ,p_prtt_rt_val_id in number
                                ,p_input_va_calc_rl in number
                                ,p_abs_ler in boolean
                                ,p_rt_strt_date in date
                                ,p_rt_end_date IN DATE
                                ,p_effective_date IN DATE
                                ,p_amt in number
                                ,p_object_version_number IN NUMBER) is
cursor get_abr_info is
  select abr.prtl_mo_det_mthd_cd,
         abr.prtl_mo_det_mthd_rl,
         abr.wsh_rl_dy_mo_num,
         abr.prtl_mo_eff_dt_det_cd,
         abr.prtl_mo_eff_dt_det_rl,
         abr.acty_typ_cd,
         abr.element_type_id,
         abr.input_value_id,
         abr.input_va_calc_rl,
         abr.rndg_cd,
         abr.rndg_rl,
         abr.ele_rqd_flag,
         abr.one_ann_pymt_cd,
         abr.entr_ann_val_flag,
         abr.ele_entry_val_cd
  from   ben_acty_base_rt_f abr
  where  abr.acty_base_rt_id=p_acty_base_rt_id
    and  abr.business_group_id=p_business_group_id
    and  p_effective_date between
         abr.effective_start_date and abr.effective_end_date;
  --
  -- Get created element_entry_value_id
  --
  cursor get_created_entry_value
    (p_element_entry_id IN NUMBER
    ,p_input_value_id   IN NUMBER
    ,p_effective_date   IN DATE
    )
  is
    select element_entry_value_id
    from   pay_element_entry_values_f
    where  element_entry_id = p_element_entry_id
    and    input_value_id   = p_input_value_id
    and    p_effective_date between effective_start_date
    and    effective_end_date;

-- bug 5768050
   CURSOR c_ee_ovn (v_element_entry_id IN NUMBER)
   IS
      SELECT object_version_number
        FROM pay_element_entries_f
       WHERE element_entry_id = v_element_entry_id
         AND p_effective_date BETWEEN effective_start_date AND effective_end_date;

   l_ovn   pay_element_entries_f.object_version_number%TYPE;

-- end bug 5768050

l_per_month_amt                    number;
l_assignment_id                    number;
l_payroll_id                       number;
l_element_entry_id                 number;
l_ext_chg_evt_log_id               number;
l_input_value_id                   number;
l_input_va_calc_rl                 number;
l_screen_entry_value               varchar2(60);
l_prv_object_version_number        number;
l_object_version_number            number;
l_ext_object_version_number        number;
l_rt                               number;
l_effective_start_date             date;
l_effective_end_date               date;
l_rt_end_dt                        date;
l_delete_warning                   boolean;
l_proc                             varchar2(72) := g_package||'recreate_enrollment_element';
l_organization_id                  number;
l_immediate_end                    boolean:=false;
l_prtl_mo_det_mthd_cd              varchar2(30);
l_prtl_mo_det_mthd_rl              number;
l_wsh_rl_dy_mo_num                 number;
l_prtl_mo_eff_dt_det_cd            varchar2(30);
l_prtl_mo_eff_dt_det_rl            number;
l_per_pay_amt                      number;
l_prorated_monthly_amt             number;
l_amt                              number;
l_prtn_flag                        varchar2(1);
l_acty_typ_cd                      varchar2(30);
l_element_type_id                  number;
l_outputs                          ff_exec.outputs_t;
l_remainder                        number;
l_number_in_month                  number;
l_old_normal_pp_date               date;
l_normal_pp_date                   date;
l_special_pp_date                  date;
l_old_normal_pp_end_date           date;
l_normal_pp_end_date               date;
l_special_pp_end_date              date;
l_zero_pp_date                     date default null;
l_special_amt                      number;
l_element_link_id                  number;
l_entry_value_id                   number;
l_start_date                       date;
l_end_date                         date;
l_update_ee                        boolean;
l_curr_val                         number;
l_new_date                         date;
l_end_of_time                      date;
l_create_warning                   boolean;
l_update_warning                   boolean;
l_jurisdiction_code                varchar2(30);
l_abr_rndg_cd                      varchar2(30);
l_abr_rndg_rl                      number;
l_ele_rqd_flag                     varchar2(30);
l_one_ann_pymt_cd                  varchar2(30);
l_entr_ann_val_flag                varchar2(30);
l_ele_entry_val_cd                 varchar2(30);
l_last_pp_strt_dt                  date;
l_last_pp_end_dt                   date;
l_range_start                      date;
l_ee_start_date                    date;
l_cnt                              number;
l_correction                       boolean;
l_update                           boolean;
l_update_override                  boolean;
l_update_change_insert             boolean;
l_dt_upd_mode                      varchar2(30);
l_element_entry_start_date         date;
l_perd_cd                          varchar2(30) := 'PP';
l_subpriority                      number;
l_override_user_ent_chk            varchar2(30) := 'N';

begin
  if g_debug then
    hr_utility.set_location('Entering :'||l_proc,5);
  end if;

  l_object_version_number := p_object_version_number;
  --
  if  NOT (chk_assign_exists(p_person_id,      p_business_group_id,
                             p_effective_date, p_rt_end_date,
                             p_acty_base_rt_id,
                             l_assignment_id,  l_organization_id,
                             l_payroll_id)) then

    if g_debug then
      hr_utility.set_location('BEN_92106_PRTT_NO_ASGN',5);
    end if;
    fnd_message.set_name('BEN', 'BEN_92106_PRTT_NO_ASGN');
    fnd_message.set_token('PROC',l_proc);
    fnd_message.set_token('PERSON_ID',to_char(p_person_id));
    fnd_message.set_token('EFFECTIVE_DATE',to_char(p_effective_date));
    fnd_message.raise_error;

  end if;
  if g_debug then
    hr_utility.set_location('l_assignment_id='||l_assignment_id,6);
  end if;
  --
  -- get activity base rate information
  --
  open get_abr_info;
  fetch get_abr_info into l_prtl_mo_det_mthd_cd,
                          l_prtl_mo_det_mthd_rl,
                          l_wsh_rl_dy_mo_num,
                          l_prtl_mo_eff_dt_det_cd,
                          l_prtl_mo_eff_dt_det_rl,
                          l_acty_typ_cd,
                          l_element_type_id,
                          l_input_value_id,
                          l_input_va_calc_rl,
                          l_abr_rndg_cd,
                          l_abr_rndg_rl,
                          l_ele_rqd_flag,
                          l_one_ann_pymt_cd,
                          l_entr_ann_val_flag,
                          l_ele_entry_val_cd;
  if get_abr_info%notfound then
    close get_abr_info;
    if g_debug then
      hr_utility.set_location('BEN_91723_NO_ENRT_RT_ABR_FOUND',40);
    end if;
    fnd_message.set_name('BEN','BEN_91723_NO_ENRT_RT_ABR_FOUND');
    fnd_message.set_token('PROC',l_proc);
    fnd_message.set_token('ACTY_BASE_RT_ID',to_char(p_acty_base_rt_id));
    fnd_message.set_token('EFFECTIVE_DATE',to_char(p_effective_date));
    fnd_message.raise_error;
  end if;
  close get_abr_info;
  l_rt_end_dt := p_rt_end_date;

  --
  -- ZAP the element entries
  --
  if g_debug then
    hr_utility.set_location('ZAP mode',10);
  end if;

  py_element_entry_api.delete_element_entry
  (p_validate => p_validate
  ,p_datetrack_delete_mode => hr_api.g_zap
  ,p_effective_date        => p_rt_strt_date
  ,p_element_entry_id      => p_element_entry_id
  ,p_object_version_number => l_object_version_number
  ,p_effective_start_date  => l_effective_start_date    -- out parm
  ,p_effective_end_date    => l_effective_end_date      -- out parm
  ,p_delete_warning        => l_delete_warning
  );
  -- write to the change event log
  --
  ben_ext_chlg.log_element_chg(
  p_action               => hr_api.g_zap,
  p_old_amt              => p_amt,
  p_input_value_id       => p_input_value_id,
  p_element_entry_id     => p_element_entry_id,
  p_person_id            => p_person_id,
  p_business_group_id    => p_business_group_id,
  p_effective_date       => p_rt_strt_date);
  --
  -- recreate the element
  --
  get_extra_ele_inputs
  (p_effective_date         => p_effective_date
  ,p_person_id              => p_person_id
  ,p_business_group_id      => p_business_group_id
  ,p_assignment_id          => l_assignment_id
  ,p_element_link_id        => p_element_link_id
  ,p_entry_type             => 'E'
  ,p_input_value_id1        => p_input_value_id
  ,p_entry_value1           => p_amt
  ,p_element_entry_id       => p_element_entry_id
  ,p_acty_base_rt_id        => p_acty_base_rt_id
  ,p_input_va_calc_rl       => p_input_va_calc_rl
  ,p_abs_ler                => p_abs_ler
  ,p_organization_id        => l_organization_id
  ,p_payroll_id             => l_payroll_id
  ,p_pgm_id                 => g_result_rec.pgm_id
  ,p_pl_id                  => g_result_rec.pl_id
  ,p_pl_typ_id              => g_result_rec.pl_typ_id
  ,p_opt_id                 => g_result_rec.opt_id
  ,p_ler_id                 => g_result_rec.ler_id
  ,p_dml_typ                => 'C'
  ,p_jurisdiction_code      => null
  ,p_ext_inpval_tab         => g_ext_inpval_tab
  ,p_subpriority            => l_subpriority
  );

  if g_debug then
    hr_utility.set_location('Hits'||g_ext_inpval_tab.count,30);
  end if;

  py_element_entry_api.create_element_entry
   (p_validate              =>p_validate
   ,p_effective_date        =>p_rt_strt_date
   ,p_business_group_id     =>p_business_group_id
   ,p_assignment_id         =>l_assignment_id
   ,p_element_link_id       =>p_element_link_id
   ,p_entry_type            =>'E'
   ,p_subpriority           =>l_subpriority
   ,p_override_user_ent_chk =>'Y'
   ,p_input_value_id1       =>g_ext_inpval_tab(1).input_value_id
   ,p_entry_value1          =>g_ext_inpval_tab(1).return_value
   ,p_input_value_id2       =>g_ext_inpval_tab(2).input_value_id
   ,p_entry_value2          =>g_ext_inpval_tab(2).return_value
   ,p_input_value_id3       =>g_ext_inpval_tab(3).input_value_id
   ,p_entry_value3          =>g_ext_inpval_tab(3).return_value
   ,p_input_value_id4       =>g_ext_inpval_tab(4).input_value_id
   ,p_entry_value4          =>g_ext_inpval_tab(4).return_value
   ,p_input_value_id5       =>g_ext_inpval_tab(5).input_value_id
   ,p_entry_value5          =>g_ext_inpval_tab(5).return_value
   ,p_input_value_id6       =>g_ext_inpval_tab(6).input_value_id
   ,p_entry_value6          =>g_ext_inpval_tab(6).return_value
   ,p_input_value_id7       =>g_ext_inpval_tab(7).input_value_id
   ,p_entry_value7          =>g_ext_inpval_tab(7).return_value
   ,p_input_value_id8       =>g_ext_inpval_tab(8).input_value_id
   ,p_entry_value8          =>g_ext_inpval_tab(8).return_value
   ,p_input_value_id9       =>g_ext_inpval_tab(9).input_value_id
   ,p_entry_value9          =>g_ext_inpval_tab(9).return_value
   ,p_input_value_id10      =>g_ext_inpval_tab(10).input_value_id
   ,p_entry_value10         =>g_ext_inpval_tab(10).return_value
   ,p_input_value_id11      =>g_ext_inpval_tab(11).input_value_id
   ,p_entry_value11         =>g_ext_inpval_tab(11).return_value
   ,p_input_value_id12      =>g_ext_inpval_tab(12).input_value_id
   ,p_entry_value12         =>g_ext_inpval_tab(12).return_value
   ,p_input_value_id13      =>g_ext_inpval_tab(13).input_value_id
   ,p_entry_value13         =>g_ext_inpval_tab(13).return_value
   ,p_input_value_id14      =>g_ext_inpval_tab(14).input_value_id
   ,p_entry_value14         =>g_ext_inpval_tab(14).return_value
   ,p_input_value_id15      =>p_input_value_id
   ,p_entry_value15         =>p_amt
   ,p_effective_start_date  =>l_effective_start_date
   ,p_effective_end_date    =>l_effective_end_date
   ,p_element_entry_id      =>l_element_entry_id
   ,p_object_version_number =>l_object_version_number
   ,p_create_warning        =>l_create_warning
   );

   py_element_entry_api.update_element_entry
   (p_validate                      =>p_validate
   ,p_datetrack_update_mode         =>hr_api.g_correction
   ,p_effective_date                =>p_rt_strt_date
   ,p_business_group_id             =>p_business_group_id
   ,p_element_entry_id              =>l_element_entry_id
   ,p_object_version_number         =>l_object_version_number
   ,p_override_user_ent_chk         =>'Y'
   ,p_creator_type                  =>'F'
   ,p_creator_id                    =>p_enrt_rslt_id
   ,p_effective_start_date          =>l_effective_start_date
   ,p_effective_end_date            =>l_effective_end_date
   ,p_update_warning                =>l_update_warning
   );

   if g_debug then
     hr_utility.set_location('Element  entry Id '||l_element_entry_id,30);
     hr_utility.set_location('ee start date '||to_char(l_effective_start_date),30);
     hr_utility.set_location('ee end date '||to_char(l_effective_end_date),30);
   end if;

   open get_created_entry_value(l_element_entry_id,p_input_value_id,
                                p_rt_strt_date);
   --
   fetch get_created_entry_value into l_entry_value_id;
   --
   if get_created_entry_value%notfound then
      --
      if g_debug then
        hr_utility.set_location('no entry created',140);
      end if;
      close get_created_entry_value;
      --
      if g_debug then
        hr_utility.set_location('BEN_92102_NO_ENTRY_CREATED',140);
      end if;
      fnd_message.set_name('BEN', 'BEN_92102_NO_ENTRY_CREATED');
      fnd_message.set_token('PROC',l_proc);
      fnd_message.set_token('ELEMENT_ENTRY_ID',to_char(l_element_entry_id));
      fnd_message.set_token('INPUT_VALUE_ID',to_char(p_input_value_id));
      fnd_message.set_token('EFFECTIVE_DATE',to_char(p_rt_strt_date));
      fnd_message.raise_error;
      --
   end if;
   close get_created_entry_value;
   if g_debug then
     hr_utility.set_location('Element entry value Id '||l_entry_value_id,30);
   end if;

   open c_get_prtt_rt_val
   (c_prtt_rt_val_id => p_prtt_rt_val_id
    );
   fetch c_get_prtt_rt_val into l_prv_rec;
   if c_get_prtt_rt_val%notfound
   then
     --
     if g_debug then
       hr_utility.set_location('BEN_92103_NO_PRTT_RT_VAL',170);
     end if;
     close c_get_prtt_rt_val;
     --
     fnd_message.set_name('BEN', 'BEN_92103_NO_PRTT_RT_VAL');
     fnd_message.set_token('PROC',l_proc);
     fnd_message.set_token('PRTT_RT_VAL',to_char(p_prtt_rt_val_id));
     fnd_message.raise_error;
   --
   end if;
   close c_get_prtt_rt_val;
   --
   l_prv_object_version_number := l_prv_rec.object_version_number;

   -- update the prv with the new element_entry_id
   --
   ben_prtt_rt_val_api.update_prtt_rt_val
   (p_validate                => p_validate
   ,p_person_id               => p_person_id
   ,p_prtt_rt_val_id          => l_prv_rec.prtt_rt_val_id
   ,p_business_group_id       => l_prv_rec.business_group_id
   ,p_element_entry_value_id  => l_entry_value_id
   ,p_input_value_id          => p_input_value_id
   ,p_object_version_number   => l_prv_object_version_number
   ,p_effective_date          => p_rt_strt_date
   );
   --
  if g_debug then
    hr_utility.set_location('rt end dt '||to_char(p_rt_end_date),30);
  end if;
  if (p_rt_end_date is not null)
  then
     -- end date the element entry
		 -- bug 5768050
    OPEN c_ee_ovn (l_element_entry_id);

    FETCH c_ee_ovn
    INTO l_ovn;

    IF c_ee_ovn%FOUND
    THEN
      hr_utility.set_location ('ovn found ending element', 121);
     py_element_entry_api.delete_element_entry
     (p_validate => p_validate
     ,p_datetrack_delete_mode => hr_api.g_delete
     ,p_effective_date        => p_rt_end_date
     ,p_element_entry_id      => l_element_entry_id
     -- ,p_object_version_number => l_object_version_number
		 ,p_object_version_number => l_ovn
     ,p_effective_start_date  => l_effective_start_date    -- out parm
     ,p_effective_end_date    => l_effective_end_date      -- out parm
     ,p_delete_warning        => l_delete_warning
     );
		end if;
		close c_ee_ovn;
		 -- end bug 5768050
   if g_debug then
     hr_utility.set_location('ee start date '||to_char(l_effective_start_date),30);
   end if;
   if g_debug then
     hr_utility.set_location('ee end date '||to_char(l_effective_end_date),30);
   end if;
     -- write to the change event log
     --
     ben_ext_chlg.log_element_chg(
     p_action               => hr_api.g_delete,
     p_old_amt              => p_amt,
     p_input_value_id       => p_input_value_id,
     p_element_entry_id     => p_element_entry_id,
     p_person_id            => p_person_id,
     p_business_group_id    => p_business_group_id,
     p_effective_date       => p_effective_date);
  end if;
  if g_debug then
    hr_utility.set_location('Leaving :'||l_proc,5);
  end if;
  --
end recreate_enrollment_element;
-- ----------------------------------------------------------------------------
-- |----------------------< end_enrollment_element >--------------------------|
-- ----------------------------------------------------------------------------
procedure end_enrollment_element(p_validate IN BOOLEAN
                                ,p_business_group_id IN NUMBER
                                ,p_person_id IN NUMBER
                                ,p_enrt_rslt_id IN NUMBER
                                ,p_acty_ref_perd in varchar2
                                ,p_acty_base_rt_id in number
                                ,p_element_link_id IN NUMBER
                                ,p_prtt_rt_val_id in number
                                ,p_rt_end_date IN DATE
                                ,p_effective_date IN DATE
                                ,p_dt_delete_mode IN VARCHAR2
                                ,p_amt in number) is
--
-- Bug 2386380 fix - added default value to decode function
--
cursor c_pps_prev_month(p_end_date in date,
                          p_prtl_mo_eff_dt_det_cd in varchar2,
                          p_payroll_id in number) is
 select start_date,end_date
 from   per_time_periods
 where  payroll_id     = p_payroll_id
 and    decode(p_prtl_mo_eff_dt_det_cd,'DTPD',regular_payment_date,
                                       'PPED',end_date,
                                       'DTERND',regular_payment_date,
                                        end_date)
               < p_end_date
        order by start_date desc;
--
-- Bug 2386380 fix - added default value to decode function
--
cursor c_get_current_pp(p_end_date in date
                        ,p_prtl_mo_eff_dt_det_cd in varchar2
                        ,p_payroll_id in number) is
  select start_date,end_date
  from   per_time_periods
  where  payroll_id = p_payroll_id
  and    p_end_date between
         start_date
         and decode(p_prtl_mo_eff_dt_det_cd,'DTPD',regular_payment_date
                                           ,'PPED',end_date
                                           ,'DTERND',regular_payment_date
                                           ,end_date);
--
-- Bug 2386380 fix - added default value to decode function
--
cursor c_last_pay_periods(p_start_date in date,
                          p_end_date in date,
                          p_prtl_mo_eff_dt_det_cd in varchar2,
                          p_payroll_id in number) is
 select start_date,end_date
 from   per_time_periods
 where  payroll_id     = p_payroll_id
 and    decode(p_prtl_mo_eff_dt_det_cd,'DTPD',regular_payment_date,
                                       'PPED',end_date,
                                       'DTERND',regular_payment_date,
                                        end_date)
               <= p_end_date
        and    decode(p_prtl_mo_eff_dt_det_cd,'DTPD',regular_payment_date,
                                              'PPED',end_date,
                                              'DTERND',regular_payment_date,
                                               end_date)
                >= p_start_date
        order by start_date asc;
--
cursor get_abr_info(p_effective_date in date) is
  select abr.prtl_mo_det_mthd_cd,
         abr.prtl_mo_det_mthd_rl,
         abr.wsh_rl_dy_mo_num,
         abr.prtl_mo_eff_dt_det_cd,
         abr.prtl_mo_eff_dt_det_rl,
         abr.input_va_calc_rl,
         abr.rndg_cd,
         abr.rndg_rl,
         abr.rcrrg_cd,
         abr.ele_rqd_flag,
         abr.one_ann_pymt_cd,
         abr.entr_ann_val_flag,
         abr.ele_entry_val_cd,
         abr.name
  from   ben_acty_base_rt_f abr
  where  abr.acty_base_rt_id=p_acty_base_rt_id
    and  abr.business_group_id=p_business_group_id
    and  p_effective_date between
         abr.effective_start_date and abr.effective_end_date;
--
cursor c_ele_info(p_element_entry_value_id number) is
  select pel.element_link_id,
         pel.element_type_id,
         pev.input_value_id,
         pet.element_name,
         pet.processing_type
    from pay_element_types_f pet,
         pay_element_links_f pel,
         pay_element_entries_f pee,
         pay_element_entry_values_f pev
   where pev.element_entry_value_id = p_element_entry_value_id
     and pee.element_entry_id = pev.element_entry_id
     and pev.effective_start_date between pee.effective_start_date
     and pee.effective_end_date
     and pel.element_link_id = pee.element_link_id
     and pee.effective_start_date between pel.effective_start_date
     and pel.effective_end_date
     and pet.element_type_id = pel.element_type_id
     and pel.effective_start_date between pet.effective_start_date
     and pet.effective_end_date;
--
-- Get element entry ID
--
cursor get_element_entry_id (p_enrt_rslt_id            in number
                            ,p_element_type_id         in number
                            ,p_input_value_id          in number
                            ,p_element_entry_value_id  in number
                            ,p_effective_date          in date)
is
select asg.assignment_id,
       asg.payroll_id,
       pee.element_entry_id,
       pee.effective_start_date,
       pee.effective_end_date,
       pee.object_version_number,
       pee.original_entry_id,
       pee.entry_type,
       pee.element_link_id,
       pev.screen_entry_value
from   per_all_assignments_f asg,
       pay_element_links_f pel,
       pay_element_entries_f pee,
       pay_element_entry_values_f pev
where  asg.person_id = p_person_id
and    pee.assignment_id = asg.assignment_id
and    p_effective_date between asg.effective_start_date
and    asg.effective_end_date
and    pee.creator_id   = p_enrt_rslt_id
and    pee.creator_type = 'F'
and    pee.entry_type = 'E'
and    p_effective_date <= pee.effective_end_date
and    pel.element_link_id = pee.element_link_id
and    pee.effective_start_date between pel.effective_start_date
and    pel.effective_end_date
and    pel.element_type_id = p_element_type_id
and    pev.element_entry_id = pee.element_entry_id
and    pev.input_value_id = p_input_value_id
and    (p_element_entry_value_id is null or
        pev.element_entry_value_id = p_element_entry_value_id)
and    pev.effective_start_date between pee.effective_start_date
and    pee.effective_end_date
order by pee.effective_start_date ;

cursor get_future_element_entry (p_enrt_rslt_id    IN NUMBER
                            ,p_assignment_id   in number
                            ,p_element_type_id in number
                            ,p_effective_date  in date) is
select pee.element_entry_id,
       pee.effective_start_date,
       pee.effective_end_date,
       pee.object_version_number
from   pay_element_entries_f pee,
       pay_element_links_f pel
where  pee.assignment_id = p_assignment_id
and    pee.creator_id   = p_enrt_rslt_id
and    pee.creator_type = 'F'
and    pee.entry_type = 'E'
and    pee.effective_start_date > p_effective_date
and    pel.element_link_id = pee.element_link_id
and    pee.effective_start_date between pel.effective_start_date
and    pel.effective_end_date
and    pel.element_type_id = p_element_type_id
and    pee.effective_start_date
          = (select min(pee2.effective_start_date)
               from pay_element_entries_f pee2
              where pee2.element_entry_id = pee.element_entry_id);
l_future_ee_rec get_future_element_entry%rowtype;

/* Bug 7597154: Commented the existing cursor c_dup_prv
--
--Added prv.rt_strt_dt <=c_effective_date condition
--to fix bug 6132571. To filter our rates that are
--already processed.
cursor c_dup_prv(c_element_entry_id  number,
                 c_effective_date    date) is
  select 'x'
    from ben_prtt_rt_val prv
   where prv.prtt_enrt_rslt_id = p_enrt_rslt_id
     and prv.acty_base_rt_id <> p_acty_base_rt_id
     and prv.rt_end_dt > c_effective_date
    -- and prv.rt_strt_dt <=c_effective_date
     and prv.prtt_rt_val_stat_cd is null
     and prv.element_entry_value_id in
         (select pev.element_entry_value_id
            from pay_element_entry_values_f pev
           where pev.element_entry_id = c_element_entry_id);
--

*/

-- Bug 7597154: Modified cursor c_dup_prv
cursor c_dup_prv(c_element_type_id  number,
                 c_effective_date    date) is
  select 'x'
    from ben_prtt_rt_val prv
   where prv.prtt_enrt_rslt_id = p_enrt_rslt_id
     and prv.acty_base_rt_id <> p_acty_base_rt_id
     and prv.rt_end_dt > c_effective_date
    -- and prv.rt_strt_dt <=c_effective_date
     and prv.prtt_rt_val_stat_cd is null
     and prv.acty_base_rt_id in
         (select abr.acty_base_rt_id
            from ben_acty_base_rt_f abr
           where abr.acty_base_rt_id = prv.acty_base_rt_id
	     and abr.element_type_id = c_element_type_id
	     and c_effective_date between abr.effective_start_date
	                and abr.effective_end_date);

-- Bug 7597154

-- Bug 9148303

cursor c_ass_type (c_assignment_id number,
                   c_effective_date date) is
select paa.primary_flag
from   per_all_assignments_f paa
where  paa.assignment_id = c_assignment_id
and    c_effective_date between paa.effective_start_date and paa.effective_end_date;

l_ass_type c_ass_type%rowtype;

-- Bug 9148303

cursor c_chk_abs_ler (c_prtt_rt_val_id number,
                      c_effective_date date)  is
select pil.lf_evt_ocrd_dt,
       pil.trgr_table_pk_id,
       pil.per_in_ler_id,
       ler.ler_id
  from ben_prtt_rt_val prt,
       ben_per_in_ler pil,
       ben_ler_f ler
 where prt.prtt_rt_val_id = c_prtt_rt_val_id
   -- ended_per_in_ler_id may be null in case of back out
   and pil.per_in_ler_id = nvl(prt.ended_per_in_ler_id,prt.per_in_ler_id)
   and ler.ler_id = pil.ler_id
   and ler.typ_cd ='ABS'
   and c_effective_date between
       ler.effective_start_date and ler.effective_end_date;
--
cursor c_min_max_dt(p_element_entry_id number) is
select min(effective_start_date),
       max(effective_end_date)
  from pay_element_entries_f
 where element_entry_id = p_element_entry_id;
--
cursor c_element_ovn(p_element_entry_id number,
                     p_effective_date date) is
select object_version_number
  from pay_element_entries_f pee
 where pee.element_entry_id = p_element_entry_id
   and p_effective_date between pee.effective_start_date
   and pee.effective_end_date;

--
 -- Bug 6834340
  -- to pass correct ler_id to the prorate_amount when subsequent life event
  -- offers no electability to the existing enrollments but rates get updated.
  --

  cursor c_ler_with_ended_prv
    (p_prtt_rt_val_id in number
     , p_rt_end_date in date
     )
  is
     select ler.name name, ler.ler_id ler_id
     from   ben_prtt_rt_val prv,
	    ben_per_in_ler    pil,
	    ben_ler_f         ler
     where  prv.per_in_ler_id = pil.per_in_ler_id
     and    pil.ler_id = ler.ler_id
     and    prv.prtt_rt_val_id = p_prtt_rt_val_id
     and    prv.rt_end_dt = p_rt_end_date;

   l_ler_with_ended_prv c_ler_with_ended_prv%rowtype;

   -- Bug 6834340
   --
   ---------srav
   cursor c_chk_payroll_chg(p_rt_end_date date,p_payroll_id number)is
   select pay2.payroll_id old_payroll_id,pay.payroll_id new_payroll_id
        from   per_all_assignments_f asg,
               pay_payrolls_f pay,
               per_all_assignments_f asg2,
               pay_payrolls_f pay2
         where asg.person_id = p_person_id
           and asg.business_group_id = p_business_group_id
           and asg.primary_flag = 'Y'
           and p_rt_end_date between
               asg.effective_start_date and asg.effective_end_date
           and pay.payroll_id=asg.payroll_id
           and pay.business_group_id = asg.business_group_id
           and p_rt_end_date between
               pay.effective_start_date and pay.effective_end_date
           AND asg.assignment_id <> asg2.assignment_id
           and asg2.person_id = p_person_id
           and asg2.business_group_id = p_business_group_id
           and asg2.primary_flag = 'Y'
           and p_rt_end_date between
               asg2.effective_start_date and asg2.effective_end_date
           and pay2.payroll_id=asg2.payroll_id
           and pay2.business_group_id = asg2.business_group_id
           and p_rt_end_date between
               pay2.effective_start_date and pay2.effective_end_date
           and pay2.payroll_id<>pay.payroll_id
           AND pay2.payroll_id = p_payroll_id ;
   l_chk_payroll_chg  c_chk_payroll_chg%rowtype;

   cursor c_days_in_pp(p_payroll_id number,p_rt_end_date date) is
   SELECT ((end_date - START_DATE) + 1)
    FROM per_time_periods
   WHERE payroll_id = p_payroll_id
     AND p_rt_end_date BETWEEN start_date AND end_date;

   l_old_pp_days  number;
   l_new_pp_days  number;

   cursor c_get_prev_ele(p_rt_end_date date) is
   SELECT pev.*
  FROM pay_element_entry_values_f pev,
       ben_prtt_rt_val prv
 WHERE prv.prtt_rt_val_id = p_prtt_rt_val_id
   AND prv.rt_end_dt = p_rt_end_date
   AND prv.element_entry_value_id = pev.element_entry_value_id
   and p_rt_end_date between pev.effective_start_date and pev.effective_end_date;

   l_get_prev_ele   c_get_prev_ele%rowtype;
   l_prev_entry_val number;
   --------srav
--
--
l_per_month_amt         number;
l_assignment_id         NUMBER;
l_payroll_id            NUMBER;
l_element_entry_id      NUMBER;
l_ext_chg_evt_log_id    NUMBER;
l_input_value_id        NUMBER;
l_abr_input_value_id    NUMBER;
l_object_version_number NUMBER;
l_ext_object_version_number NUMBER;
l_effective_start_date  DATE;
l_effective_end_date    DATE;
l_rt_end_dt             DATE := p_rt_end_date;
l_delete_warning        BOOLEAN;
l_proc                  VARCHAR2(72) := g_package||'end_enrollment_element';
l_organization_id       number;
l_immediate_end         boolean:=false;
l_prtl_mo_det_mthd_cd   varchar2(30);
l_prtl_mo_det_mthd_rl   number;
l_wsh_rl_dy_mo_num      number;
l_prtl_mo_eff_dt_det_cd varchar2(30);
l_prtl_mo_eff_dt_det_rl number;
l_per_pay_amt           number;
l_prorated_monthly_amt  number;
l_amt                   number;
l_prtn_flag             varchar2(1);
l_element_type_id       number;
l_abr_element_type_id   number;
l_outputs               ff_exec.outputs_t;
l_remainder             number;
l_number_in_month       number;
l_old_normal_pp_date    date;
l_normal_pp_date        date;
l_special_pp_date       date;
l_old_normal_pp_end_date date;
l_normal_pp_end_date    date;
l_special_pp_end_date   date;
l_zero_pp_date          date default null;
l_dt_to_use             date;
l_special_amt           number;
l_element_link_id       number;
l_start_date            date;
l_end_date              date;
l_update_ee             boolean;
l_curr_val              number;
l_new_date              date;
l_end_of_time           date;
l_create_warning        BOOLEAN;
l_update_warning        BOOLEAN;
l_jurisdiction_code     varchar2(30);
l_abr_rndg_cd           varchar2(30);
l_abr_rndg_rl           number;
l_ele_rqd_flag          varchar2(30);
l_one_ann_pymt_cd       varchar2(30);
l_entr_ann_val_flag     varchar2(30);
l_ele_entry_val_cd      varchar2(30);
l_last_pp_strt_dt       date;
l_last_pp_end_dt        date;
l_range_start           date;
l_dt_delete_mode        varchar2(80);
l_cnt                   number;
l_absence_attendance_id number;
l_per_in_ler_id number;
l_ler_id        number;
l_input_va_calc_rl     number;
l_subpriority          number;
l_original_entry_id    number;
l_entry_type           varchar2(30);
l_processing_type      varchar2(30);
l_lf_evt_ocrd_dt       date;
l_abs_ler              boolean := false;
l_recreate             boolean := false;
l_ele_processed        varchar2(1);
l_err_code             varchar2(10);
l_err_mesg             varchar2(2000);
l_dummy                varchar2(30);
l_curr_val_char        varchar2 (60);
l_uom              varchar2(30);
l_correction               boolean;
l_update                   boolean;
l_update_override          boolean;
l_update_change_insert     boolean;
l_dt_upd_mode              varchar2(30);
l_element_entry_start_date date;
l_element_entry_end_date   date;
l_string                   varchar2(4000);
l_abr_name                 varchar2(240); -- 2519349
l_effective_date           date;
l_rt_strt_dt               date;
l_perd_cd       varchar2(30) := 'PP';
l_element_name              varchar2(80);
l_object_version_number2    number;
l_another_prv_exists        boolean := false;
l_min_start_date            date;
l_max_end_date              date;
l_non_recurring_entry       boolean := false;
l_abr_rcrrg_cd              varchar2(30);
l_element_entry_value_id    number;
l_v2dummy                   varchar2(30);
--
begin
   g_debug := hr_utility.debug_enabled;
  if g_debug then
    hr_utility.set_location('Entering :'||l_proc,5);
    hr_utility.set_location('Element_link_id='||to_char(p_element_link_id),6);
    hr_utility.set_location('Effective_date='||to_char(p_effective_date),6);
    hr_utility.set_location('p_prtt_rt_val_id='||p_prtt_rt_val_id,6);
    hr_utility.set_location('p_enrt_rslt_id='||p_enrt_rslt_id,6);
    hr_utility.set_location('p_rt_end_date='||to_char(p_rt_end_date),6);
  end if;
  --
  --BUG 3167959 We need to intialize the pl/sql table
  clear_ext_inpval_tab ;
  --
  -- get prv info
  --
  open c_get_prtt_rt_val
    (c_prtt_rt_val_id => p_prtt_rt_val_id
    );
  fetch c_get_prtt_rt_val into l_prv_rec;
  if c_get_prtt_rt_val%notfound
  then
    --
    if g_debug then
      hr_utility.set_location('BEN_92103_NO_PRTT_RT_VAL',170);
    end if;
    close c_get_prtt_rt_val;
    --
    fnd_message.set_name('BEN', 'BEN_92103_NO_PRTT_RT_VAL');
    fnd_message.set_token('PROC',l_proc);
    fnd_message.set_token('PRTT_RT_VAL',to_char(p_prtt_rt_val_id));
    fnd_message.raise_error;
    --
  end if;
  close c_get_prtt_rt_val;
  --
  -- if no element entry was created to start with, return
  --
  if l_prv_rec.element_entry_value_id is null then
     hr_utility.set_location('no element entry '||l_proc,7);
     hr_utility.set_location('Leaving: '||l_proc,7);
     return;
  end if;
  --
  -- find the element type and input value based on element_entry_value_id
  -- attached to prtt rt.
  --
  open c_ele_info(l_prv_rec.element_entry_value_id);
  fetch c_ele_info into
    l_element_link_id,
    l_element_type_id,
    l_input_value_id,
    l_element_name,
    l_processing_type;
  --
  if c_ele_info%notfound then
    close c_ele_info;
    if g_debug then
      --
      -- entry_value_id attached to prtt rt does not exist. This is possible
      -- prior to FP C when ct. could delete the entries
      --
      hr_utility.set_location('Leaving: '||l_proc,7);
    end if;
    return;
  end if;
  close c_ele_info;
  --
  -- This is for the case when prtt rt is ended one day before start dt
  --
  l_effective_date := greatest(l_prv_rec.rt_strt_dt,l_rt_end_dt);

  if g_debug then
    hr_utility.set_location('ele type='||l_element_type_id,7);
    hr_utility.set_location('inp val='||l_input_value_id,7);
    hr_utility.set_location('l_effective_date='||l_effective_date,7);
  end if;
  --
  -- get abr info
  --
  open get_abr_info(l_effective_date);
  fetch get_abr_info into l_prtl_mo_det_mthd_cd,
                          l_prtl_mo_det_mthd_rl,
                          l_wsh_rl_dy_mo_num,
                          l_prtl_mo_eff_dt_det_cd,
                          l_prtl_mo_eff_dt_det_rl,
                          l_input_va_calc_rl,
                          l_abr_rndg_cd,
                          l_abr_rndg_rl,
                          l_abr_rcrrg_cd,
                          l_ele_rqd_flag,
                          l_one_ann_pymt_cd,
                          l_entr_ann_val_flag,
                          l_ele_entry_val_cd,
                          l_abr_name;
  if get_abr_info%notfound then
    close get_abr_info;
    if g_debug then
      hr_utility.set_location('BEN_91723_NO_ENRT_RT_ABR_FOUND',40);
    end if;
    fnd_message.set_name('BEN','BEN_91723_NO_ENRT_RT_ABR_FOUND');
    fnd_message.set_token('PROC',l_proc);
    fnd_message.set_token('ACTY_BASE_RT_ID',to_char(p_acty_base_rt_id));
    fnd_message.set_token('EFFECTIVE_DATE',to_char(p_effective_date));
    fnd_message.raise_error;
  end if;
  close get_abr_info;

  hr_utility.set_location('l_abr_rcrrg_cd '||l_abr_rcrrg_cd,40);
  hr_utility.set_location('l_processing_type '||l_processing_type,40);
  l_non_recurring_entry := ((l_abr_rcrrg_cd = 'ONCE') or (l_processing_type='N'));
  if l_non_recurring_entry then
     l_element_entry_value_id := l_prv_rec.element_entry_value_id;
  end if;
  hr_utility.set_location('l_element_entry_value_id '||l_element_entry_value_id,40);

  --
  -- find the element entry that needs to be deleted.
  -- This could be different from what is attached to prtt rt
  --
  open get_element_entry_id(p_enrt_rslt_id
                           ,l_element_type_id
                           ,l_input_value_id
                           ,l_element_entry_value_id
                           ,l_effective_date);
  fetch get_element_entry_id into
    l_assignment_id,
    l_payroll_id,
    l_element_entry_id,
    l_element_entry_start_date,
    l_element_entry_end_date,
    l_object_version_number,
    l_original_entry_id,
    l_entry_type,
    l_element_link_id,
    l_curr_val_char;
  --
  if get_element_entry_id%notfound then
    close get_element_entry_id;
    if g_debug then
      -- element entry already ended.
      hr_utility.set_location('element entry already ended',8);
      hr_utility.set_location('Leaving: '||l_proc,7);
    end if;

     --
    ben_warnings.load_warning
     (p_application_short_name  => 'BEN',
      p_message_name            => 'BEN_93455_ELE_ALREADY_ENDED',
      p_parma => l_element_name,
      p_parmb => to_char(l_effective_date),
      p_person_id => p_person_id);
      --
    if fnd_global.conc_request_id in ( 0,-1) then
         --
         fnd_message.set_name('BEN','BEN_93455_ELE_ALREADY_ENDED');
         fnd_message.set_token('PARMA',l_element_name);
         fnd_message.set_token('PARMB',to_char(l_effective_date));
         l_string       := fnd_message.get;
         benutils.write(p_text => l_string);
         --
    end if;
    --
    return;
    --
  end if;
  close get_element_entry_id;

  if g_debug then
    hr_utility.set_location('ee id='||l_element_entry_id,9);
    hr_utility.set_location('ee strtdt ='||l_element_entry_start_date,9);
    hr_utility.set_location('ee end dt='||l_element_entry_end_date,9);
    hr_utility.set_location('l_ovn='||l_object_version_number,9);
    hr_utility.set_location('l_payroll_id='||l_payroll_id,9);
    hr_utility.set_location('l_assignment_id='||l_assignment_id,9);
  end if;
  --
  -- get prtt enrt rslt info
  --
  if nvl(g_result_rec.prtt_enrt_rslt_id,-1)<>p_enrt_rslt_id then
    open c_current_result_info
      (c_prtt_enrt_rslt_id  => p_enrt_rslt_id
      );
    fetch c_current_result_info into g_result_rec;
    close c_current_result_info;
  end if;
  --
  -- check if abs ler
  --
  open c_chk_abs_ler
  (c_prtt_rt_val_id => p_prtt_rt_val_id
  ,c_effective_date => l_effective_date
  );
  fetch c_chk_abs_ler into
  l_lf_evt_ocrd_dt,
  l_absence_attendance_id,
  l_per_in_ler_id,
  l_ler_id;
  l_abs_ler := c_chk_abs_ler%found;
  close c_chk_abs_ler;
  --
  -- Get the latest payroll run date
  --
  g_max_end_date := null;
  --
  --Bug 3151737and 3063518  if there is no payroll_id on assignment means
  --customer might not be using the payroll so we don't need to determine
  --the g_max_end_date .
  --
  if l_payroll_id is not null then
     --
     if nvl(g_per_pay_rec.assignment_id,-1) <> l_assignment_id then
        --
        open c_payroll_was_ever_run
        (c_assignment_id => l_assignment_id
        );
        fetch c_payroll_was_ever_run into l_v2dummy;
        g_per_pay_rec.assignment_id := l_assignment_id;
        g_per_pay_rec.payroll_was_ever_run := c_payroll_was_ever_run%found;
        close c_payroll_was_ever_run;
        --
     end if;
     --
     if g_per_pay_rec.payroll_was_ever_run and
        g_per_pay_rec.end_date is null then
        --
        g_max_end_date :=
            get_max_end_dt (
            p_assignment_id         => l_assignment_id,
            p_payroll_id            => l_payroll_id,
            p_element_type_id       => l_element_type_id,
            p_effective_date        => l_effective_date);
        --
        g_per_pay_rec.end_date := g_max_end_date;
        --
     elsif g_per_pay_rec.end_date is not null then
         g_max_end_date := g_per_pay_rec.end_date;
     end if;
     --
  end if;
  --
  if g_debug then
    hr_utility.set_location('g_max_end_date='||g_max_end_date,10);
  end if;
  --
  -- If the entry has already been processed in the pay period
  -- in which it is going to be ended, show a warning
  --
  if not (l_abs_ler) and
     g_max_end_date is not null and
     g_max_end_date > l_rt_end_dt
  then
    if (g_msg_displayed <>1)
        -- added for bug: 5607214
	or fnd_global.conc_request_id not in ( 0,-1)
	then
     --l_immediate_end:=true;
     -- Issue a warning to the user.  These will display on the enrt forms.
      ben_warnings.load_warning
      (p_application_short_name  => 'BEN',
      p_message_name            => 'BEN_92456_END_RUN_RESULTS',
      p_parma     => fnd_date.date_to_chardate(g_max_end_date),
      p_person_id => p_person_id);

      if fnd_global.conc_request_id not in ( 0,-1) then
        --
        fnd_message.set_name('BEN','BEN_92456_END_RUN_RESULTS');
        fnd_message.set_token('PARMA',fnd_date.date_to_chardate(g_max_end_date));
        l_string       := fnd_message.get;
        benutils.write(p_text => l_string);
        --
      end if;
    g_msg_displayed :=1;
    end if;
    --
    -- cache quickpay run entries
    --
    cache_quick_pay_run
          (p_person_id => p_person_id,
           p_element_type_id => l_element_type_id,
           p_assignment_id => l_assignment_id,
           p_element_entry_id => l_element_entry_id,
           p_effective_date => l_rt_end_dt + 1,
           p_start_date  => l_rt_end_dt + 1,
           p_end_date    => g_max_end_date,
           p_payroll_id  => l_payroll_id);
  end if;
  --
  -- Determine dt track mode.
  --
  open c_min_max_dt(l_element_entry_id);
  fetch c_min_max_dt into l_min_start_date,l_max_end_date;
  close c_min_max_dt;

  if l_rt_end_dt < l_min_start_date then
     l_dt_delete_mode :=  hr_api.g_zap;
  elsif l_rt_end_dt < l_max_end_date then
     l_dt_delete_mode :=  hr_api.g_delete;
  end if;
  --
  -- if the entry is to be ended on l_rt_end_dt (or)
  -- has already been ended on l_rt_end_dt, then update the extra input vales
  --
  if l_rt_end_dt >= l_element_entry_start_date and
     l_rt_end_dt <= l_max_end_date then
     get_extra_ele_inputs
     (p_effective_date         => p_effective_date
     ,p_person_id              => p_person_id
     ,p_business_group_id      => p_business_group_id
     ,p_assignment_id          => l_assignment_id
     ,p_element_link_id        => l_element_link_id
     ,p_entry_type             => 'E'
     ,p_input_value_id1        => l_input_value_id
     ,p_entry_value1           => l_curr_val_char
     ,p_element_entry_id       => l_element_entry_id
     ,p_acty_base_rt_id        => p_acty_base_rt_id
     ,p_input_va_calc_rl       => l_input_va_calc_rl
     ,p_abs_ler                => l_abs_ler
     ,p_organization_id        => l_organization_id
     ,p_payroll_id             => l_payroll_id
     ,p_pgm_id                 => g_result_rec.pgm_id
     ,p_pl_id                  => g_result_rec.pl_id
     ,p_pl_typ_id              => g_result_rec.pl_typ_id
     ,p_opt_id                 => g_result_rec.opt_id
     ,p_ler_id                 => l_ler_id
     ,p_dml_typ                => 'U'
     ,p_jurisdiction_code      => l_jurisdiction_code
     ,p_ext_inpval_tab         => g_ext_inpval_tab
     ,p_subpriority            => l_subpriority
     );

     if g_ext_inpval_tab.count > 0 and
          /* Bug 3890546: When previous payroll periods are closed,
             the below update_element_entry errors out. So, restricting this call
             to only when atleast one extra input_value_id NOT NULL */
         ( g_ext_inpval_tab(1).input_value_id IS NOT NULL
        OR g_ext_inpval_tab(2).input_value_id IS NOT NULL
        OR g_ext_inpval_tab(3).input_value_id IS NOT NULL
        OR g_ext_inpval_tab(4).input_value_id IS NOT NULL
        OR g_ext_inpval_tab(5).input_value_id IS NOT NULL
        OR g_ext_inpval_tab(6).input_value_id IS NOT NULL
        OR g_ext_inpval_tab(7).input_value_id IS NOT NULL
        OR g_ext_inpval_tab(8).input_value_id IS NOT NULL
        OR g_ext_inpval_tab(9).input_value_id IS NOT NULL
        OR g_ext_inpval_tab(10).input_value_id IS NOT NULL
        OR g_ext_inpval_tab(11).input_value_id IS NOT NULL
        OR g_ext_inpval_tab(12).input_value_id IS NOT NULL
        OR g_ext_inpval_tab(13).input_value_id IS NOT NULL
        OR g_ext_inpval_tab(14).input_value_id IS NOT NULL)
       then
        pay_element_entry_api.update_element_entry
        (p_validate                      =>p_validate
        ,p_datetrack_update_mode         =>hr_api.g_correction
        ,p_effective_date                =>l_element_entry_start_date
        ,p_business_group_id             =>p_business_group_id
        ,p_element_entry_id              =>l_element_entry_id
        ,p_object_version_number         =>l_object_version_number
        ,p_subpriority                   =>l_subpriority
        ,p_override_user_ent_chk         =>'Y'
        ,p_input_value_id1               =>g_ext_inpval_tab(1).input_value_id
        ,p_entry_value1                  =>g_ext_inpval_tab(1).return_value
        ,p_input_value_id2               =>g_ext_inpval_tab(2).input_value_id
        ,p_entry_value2                  =>g_ext_inpval_tab(2).return_value
        ,p_input_value_id3               =>g_ext_inpval_tab(3).input_value_id
        ,p_entry_value3                  =>g_ext_inpval_tab(3).return_value
        ,p_input_value_id4               =>g_ext_inpval_tab(4).input_value_id
        ,p_entry_value4                  =>g_ext_inpval_tab(4).return_value
        ,p_input_value_id5               =>g_ext_inpval_tab(5).input_value_id
        ,p_entry_value5                  =>g_ext_inpval_tab(5).return_value
        ,p_input_value_id6               =>g_ext_inpval_tab(6).input_value_id
        ,p_entry_value6                  =>g_ext_inpval_tab(6).return_value
        ,p_input_value_id7               =>g_ext_inpval_tab(7).input_value_id
        ,p_entry_value7                  =>g_ext_inpval_tab(7).return_value
        ,p_input_value_id8               =>g_ext_inpval_tab(8).input_value_id
        ,p_entry_value8                  =>g_ext_inpval_tab(8).return_value
        ,p_input_value_id9               =>g_ext_inpval_tab(9).input_value_id
        ,p_entry_value9                  =>g_ext_inpval_tab(9).return_value
        ,p_input_value_id10              =>g_ext_inpval_tab(10).input_value_id
        ,p_entry_value10                 =>g_ext_inpval_tab(10).return_value
        ,p_input_value_id11              =>g_ext_inpval_tab(11).input_value_id
        ,p_entry_value11                 =>g_ext_inpval_tab(11).return_value
        ,p_input_value_id12              =>g_ext_inpval_tab(12).input_value_id
        ,p_entry_value12                 =>g_ext_inpval_tab(12).return_value
        ,p_input_value_id13              =>g_ext_inpval_tab(13).input_value_id
        ,p_entry_value13                 =>g_ext_inpval_tab(13).return_value
        ,p_input_value_id14              =>g_ext_inpval_tab(14).input_value_id
        ,p_entry_value14                 =>g_ext_inpval_tab(14).return_value
        ,p_effective_start_date          =>l_effective_start_date
        ,p_effective_end_date            =>l_effective_end_date
        ,p_update_warning                =>l_update_warning
        );
     end if;

     if l_abs_ler then
        pqp_absence_plan_process.update_absence_plan_details
        (p_person_id               => p_person_id
        ,p_assignment_id           => l_assignment_id
        ,p_business_group_id       => p_business_group_id
        ,p_legislation_code        => get_legislation_code(p_business_group_id)
        ,p_effective_date          => p_effective_date
        ,p_element_type_id         => l_element_type_id
        ,p_pl_id                   => g_result_rec.pl_id
        ,p_pl_typ_id               => g_result_rec.pl_typ_id
        ,p_ler_id                  => l_ler_id
        ,p_per_in_ler_id           => l_per_in_ler_id
        ,p_absence_attendance_id   => l_absence_attendance_id
        ,p_effective_start_date    => l_effective_start_date
        ,p_effective_end_date      => l_effective_end_date
        ,p_formula_outputs         => g_outputs
        ,p_error_code              => l_err_code
        ,p_error_message           => l_err_mesg
        );
     end if;

  end if;

  if l_abs_ler and
     l_dt_delete_mode = hr_api.g_delete then
     --
     -- ABSENCES: ZAP and recreate the element entry if the absence
     -- was processed in a payroll and is currently end dated in a
     -- period for which payroll has already been run.
     --
     -- This needs to be eventually merged with c_get_end_dt cursor
     --
     l_ele_processed := chk_ele_processed
                        (p_element_entry_id => l_element_entry_id
                        ,p_original_entry_id=> l_original_entry_id
                        ,p_processing_type  => l_processing_type
                        ,p_entry_type       => l_entry_type
                        ,p_business_group_id => p_business_group_id
                        ,p_effective_date   => p_effective_date);

     if l_ele_processed = 'Y' and
        l_lf_evt_ocrd_dt < g_max_end_date then
        l_recreate := true;
     end if;

  end if;
  --
  --Check if entry is used by another prv. This info is used further down
  --
  hr_utility.set_location('l_rt_end_dt '||l_rt_end_dt,1100);
  open c_dup_prv(l_element_type_id,
                 l_rt_end_dt);
  fetch c_dup_prv into l_dummy;
  l_another_prv_exists := c_dup_prv%found;
  close c_dup_prv;
  --
  -- Delete the element entries
  --
  if (l_recreate) then
       --
       -- this part is called only in case of Absence processing
       --
      recreate_enrollment_element
      (p_validate => false
      ,p_business_group_id => p_business_group_id
      ,p_person_id => p_person_id
      ,p_enrt_rslt_id => p_enrt_rslt_id
      ,p_acty_ref_perd => p_acty_ref_perd
      ,p_acty_base_rt_id => p_acty_base_rt_id
      ,p_element_entry_id => l_element_entry_id
      ,p_element_link_id => l_element_link_id
      ,p_input_value_id => l_input_value_id
      ,p_prtt_rt_val_id => p_prtt_rt_val_id
      ,p_input_va_calc_rl => l_input_va_calc_rl
      ,p_abs_ler => l_abs_ler
      ,p_rt_strt_date => l_element_entry_start_date
      ,p_rt_end_date => l_rt_end_dt
      ,p_effective_date => p_effective_date
      ,p_amt =>l_curr_val_char
      ,p_object_version_number => l_object_version_number);

      pqp_absence_plan_process.update_absence_plan_details
      (p_person_id               => p_person_id
      ,p_assignment_id           => l_assignment_id
      ,p_business_group_id       => p_business_group_id
      ,p_legislation_code        => get_legislation_code(p_business_group_id)
      ,p_effective_date          => p_effective_date
      ,p_element_type_id         => l_element_type_id
      ,p_pl_id                   => g_result_rec.pl_id
      ,p_pl_typ_id               => g_result_rec.pl_typ_id
      ,p_ler_id                  => l_ler_id
      ,p_per_in_ler_id           => l_per_in_ler_id
      ,p_absence_attendance_id   => l_absence_attendance_id
      ,p_effective_start_date    => l_effective_start_date
      ,p_effective_end_date      => l_rt_end_dt
      ,p_formula_outputs         => g_outputs
      ,p_error_code              => l_err_code
      ,p_error_message           => l_err_mesg
      );

  elsif l_dt_delete_mode = hr_api.g_zap then
        if g_debug then
          hr_utility.set_location('ZAP mode',11);
        end if;
      /*
      Before :-
        02-JAN-1994      05-FEB-1994
            |-A--------------|-B--------------------------------------->
                                              ED

      After :-

      */
        py_element_entry_api.delete_element_entry
        (p_validate => p_validate
        ,p_datetrack_delete_mode => hr_api.g_zap
        ,p_effective_date        => l_element_entry_start_date
        ,p_element_entry_id      => l_element_entry_id
        ,p_object_version_number => l_object_version_number
        ,p_effective_start_date  => l_effective_start_date
        ,p_effective_end_date    => l_effective_end_date
        ,p_delete_warning        => l_delete_warning
        );
        -- write to the change event log
        --

        ben_ext_chlg.log_element_chg(
        p_action               => 'DELETE',
        p_old_amt              => fnd_number.canonical_to_number(l_curr_val_char),
        p_input_value_id       => l_input_value_id,
        p_element_entry_id     => l_element_entry_id,
        p_person_id            => p_person_id,
        p_business_group_id    => p_business_group_id,
        p_effective_date       => p_effective_date);
        --
        if l_abs_ler then
           pqp_absence_plan_process.delete_absence_plan_details
           (p_assignment_id           => l_assignment_id
           ,p_business_group_id       => p_business_group_id
           ,p_legislation_code        => get_legislation_code(p_business_group_id)
           ,p_effective_date          => p_effective_date
           ,p_pl_id                   => g_result_rec.pl_id
           ,p_pl_typ_id               => g_result_rec.pl_typ_id
           ,p_ler_id                  => l_ler_id
           ,p_per_in_ler_id           => l_per_in_ler_id
           ,p_absence_attendance_id   => l_absence_attendance_id
           ,p_effective_start_date    => l_effective_start_date
           ,p_effective_end_date      => l_effective_end_date
           ,p_formula_outputs         => g_outputs
           ,p_error_code              => l_err_code
           ,p_error_message           => l_err_mesg
           );
        end if;

  elsif l_dt_delete_mode = hr_api.g_delete then
   if g_debug then
      hr_utility.set_location('DELETE mode',11);
   end if;
   --
   -- End date as of the pre-calculated rate end date.
   --
   if g_debug then
      hr_utility.set_location('pre-calc rate end date',12);
   end if;
/*
   Before :-
     02-JAN-1994      05-FEB-1994
         |-A--------------|-B--------------------------------------->
                                           ED

   After :-
     02-JAN-1994      05-FEB-1994           15-JUL-1994
         |-A--------------|-B-------------------|
                                           ED

*/
   if l_immediate_end=false then
      --
      -- Annualize the rate
      --
      if g_debug then
        hr_utility.set_location('prv_id= '|| p_prtt_rt_val_id,10);
        hr_utility.set_location('payroll= '|| l_payroll_id,10);
        hr_utility.set_location('bg= '|| p_business_group_id,10);
        hr_utility.set_location('rt_end= '|| l_rt_end_dt,10);
        hr_utility.set_location('effective_date= '|| p_effective_date,10);
      end if;
      --
      -- ELE : By pass if the ele_entry_val_cd <> PP , EPP or null.
      --
      if nvl(l_ele_entry_val_cd, 'PP') = 'PP' or
             l_ele_entry_val_cd = 'EPP' then
      --
        open c_plan_year_end_for_pen
          (c_prtt_enrt_rslt_id    => p_enrt_rslt_id
          ,c_rate_start_or_end_dt => l_rt_end_dt
          ,c_effective_date       => p_effective_date
          );
        fetch c_plan_year_end_for_pen into l_last_pp_strt_dt, l_last_pp_end_dt;
        close c_plan_year_end_for_pen;
        --
        -- For ending always do full year processing
        --
        --l_range_start:=add_months(l_last_pp_end_dt,-12)+1;
        --
        --BUG 3294702
        --l_range_start:=add_months(l_last_pp_end_dt,-12)+1;
        l_range_start:=l_last_pp_strt_dt ;
        --
        if g_debug then
          hr_utility.set_location('range start= '|| l_range_start,10);
          hr_utility.set_location('range end  = '|| l_last_pp_end_dt,10);
          hr_utility.set_location('p_amt='||p_amt,100);
        end if;
        l_amt:=ben_distribute_rates.period_to_annual(
            p_amount                   =>p_amt
           ,p_acty_ref_perd_cd         =>p_acty_ref_perd
           ,p_business_group_id        =>p_business_group_id
           ,p_effective_date           =>p_effective_date
           ,p_complete_year_flag       =>'N' -- done using start
           ,p_use_balance_flag         =>'N'
           ,p_element_type_id          => l_element_type_id
           ,p_start_date               =>l_range_start
           ,p_end_date                 =>l_last_pp_end_dt
           ,p_payroll_id               =>l_payroll_id
           ,p_rounding_flag            =>'N'
        );
        --
        -- to do proration need monthly amount divide by 12.
        --
        l_per_month_amt := l_amt/12;
        if g_debug then
          hr_utility.set_location('l_per_month_amt='||l_per_month_amt,100);
          hr_utility.set_location('l_amt='||l_amt,100);
        end if;
        --
        -- Compute per pay amt
        --
        if l_ele_entry_val_cd = 'EPP' then
           l_perd_cd := 'EPP';
        end if;
        l_per_pay_amt:=ben_distribute_rates.annual_to_period(
            p_amount                   =>l_amt
           ,p_acty_ref_perd_cd         =>l_perd_cd --'PP' -- per pay period
           ,p_business_group_id        =>p_business_group_id
           ,p_effective_date           =>p_effective_date
           ,p_complete_year_flag       =>'N'
           ,p_use_balance_flag         =>'N'
           ,p_element_type_id          => l_element_type_id
           ,p_start_date               =>l_range_start
           ,p_end_date                 =>l_last_pp_end_dt
           ,p_payroll_id               =>l_payroll_id
        );
        if g_debug then
          hr_utility.set_location('l_per_pay_amt'||l_per_pay_amt,293.1);
        end if;
        --
        if (l_abr_rndg_cd is not null or
           l_abr_rndg_rl is not null) and
           l_per_pay_amt is not null then
          --
          l_per_pay_amt := benutils.do_rounding
           (p_rounding_cd  => l_abr_rndg_cd,
            p_rounding_rl  => l_abr_rndg_rl,
            p_value        => l_per_pay_amt,
            p_effective_date => p_effective_date);
        elsif l_per_pay_amt is not null and
              l_per_pay_amt<>0 then
          --
          -- Do this for now: in future default to rounding for currency prec
          --
          l_per_pay_amt:=round(l_per_pay_amt,2);
        end if;
        --
        -- Prorate the rate, if necessary
        -- let prorate_amount function decide then either
        -- l_new_val is the same as l_amount, or not for proration.
        -- l_prtn_val will be set.
        --
        if g_debug then
          hr_utility.set_location('Prorate the rate',20);
          hr_utility.set_location('l_per_month_amt '||l_per_month_amt,20);
        end if;
	--
	-- Bug 6834340
	open c_ler_with_ended_prv(p_prtt_rt_val_id, p_rt_end_date);
        fetch c_ler_with_ended_prv into l_ler_with_ended_prv;
        close c_ler_with_ended_prv;
	-- Bug 6834340
	--
	-----------Bug 7687104
	hr_utility.set_location('l_per_month_amt : '|| l_per_month_amt,20);
	open c_chk_payroll_chg(l_rt_end_dt,l_payroll_id);
	fetch c_chk_payroll_chg into l_chk_payroll_chg;
	if c_chk_payroll_chg%found then
          open c_days_in_pp(l_chk_payroll_chg.old_payroll_id,l_rt_end_dt);
	  fetch c_days_in_pp into l_old_pp_days;
	  close c_days_in_pp;
          hr_utility.set_location('l_old_pp_days : '|| l_old_pp_days,20);
	  open c_days_in_pp(l_chk_payroll_chg.new_payroll_id,l_rt_end_dt);
	  fetch c_days_in_pp into l_new_pp_days;
	  close c_days_in_pp;
          hr_utility.set_location('l_new_pp_days : '|| l_new_pp_days,20);
	  if l_old_pp_days > l_new_pp_days then
	     open c_get_prev_ele(l_rt_end_dt);
	     fetch c_get_prev_ele into l_get_prev_ele;
	     if c_get_prev_ele%found then
	        hr_utility.set_location('prev_ele.screen_value : '|| l_get_prev_ele.screen_entry_value,20);
	        l_prev_entry_val := l_get_prev_ele.screen_entry_value;
	     end if;
	     close c_get_prev_ele;
	  end if;
	end if;
	close c_chk_payroll_chg;
	-----------Bug 7687104
        l_prorated_monthly_amt := prorate_amount(
                                  p_amt                   =>nvl(l_prev_entry_val,l_per_month_amt)  --------Bug 7687104
                                 ,p_acty_base_rt_id       =>p_acty_base_rt_id
                                 ,p_prorate_flag          =>l_prtn_flag
                                 ,p_effective_date        =>p_effective_date
                                 ,p_start_or_stop_cd      =>'STP'
                                 ,p_start_or_stop_date    =>l_rt_end_dt
                                 ,p_business_group_id     =>p_business_group_id
                                 ,p_assignment_id         =>l_assignment_id
                                 ,p_organization_id       =>l_organization_id
                                 ,p_wsh_rl_dy_mo_num      =>l_wsh_rl_dy_mo_num
                                 ,p_prtl_mo_det_mthd_cd   =>l_prtl_mo_det_mthd_cd
                                 ,p_prtl_mo_det_mthd_rl   =>l_prtl_mo_det_mthd_rl
                                 -- new parms below
                                 ,p_person_id             =>g_result_rec.person_id
                                 ,p_pgm_id                =>g_result_rec.pgm_id
                                 ,p_pl_typ_id             =>g_result_rec.pl_typ_id
                                 ,p_pl_id                 =>g_result_rec.pl_id
                                 ,p_opt_id                =>g_result_rec.opt_id
                                 ,p_ler_id                =>l_ler_with_ended_prv.ler_id  -- Bug 6834340
                                 ,p_jurisdiction_code     =>l_jurisdiction_code
                                 ,p_rndg_cd               =>l_abr_rndg_cd
                                 ,p_rndg_rl               =>l_abr_rndg_rl
        );
        --
      -- ELE :
      end if;
      -- already have the element_entry_id
      --
      -- Check the PRTL MONTH PRORATION rule
      -- against the effective date and payperiod
      -- of participants payroll.
      --
      -- Get the Element Link ID
      -- and the Input value id for EE Contr.
      --
      -- ELE : By pass if the ele_entry_val_cd <> PP , EPP or null.
      --
      if nvl(l_ele_entry_val_cd, 'PP') not in ('PP','EPP') then
         l_prtn_flag := 'N';
         l_special_pp_date := null;
      end if;
      --
      -- Determine prorated first pay periods
      -- Where amount is not the normal per pay period amount
      --
      if l_prtn_flag = 'Y' then
        if g_debug then
          hr_utility.set_location('Determine proration ',40);
        end if;
        if l_prtl_mo_eff_dt_det_cd = 'RL' and
           l_prtl_mo_eff_dt_det_rl is not null then
          --
          -- exec rule and get code back
          --
          l_outputs:=benutils.formula
                (p_opt_id               =>g_result_rec.opt_id,
                 p_pl_id                =>g_result_rec.pl_id,
                 p_pgm_id               =>g_result_rec.pgm_id,
                 p_formula_id           =>l_prtl_mo_eff_dt_det_rl,
                 p_ler_id               =>g_result_rec.ler_id,
                 p_pl_typ_id            =>g_result_rec.pl_typ_id,
                 p_assignment_id        =>l_assignment_id,
                 p_acty_base_rt_id      =>p_acty_base_rt_id,
                 p_business_group_id    =>p_business_group_id,
                 p_organization_id      =>l_organization_id,
                 p_jurisdiction_code    =>l_jurisdiction_code,
                 p_effective_date       =>l_rt_end_dt);
          --
          begin
            --
            -- convert return value to code
            --
            l_prtl_mo_eff_dt_det_cd:=l_outputs(l_outputs.first).value;
            --
          exception
            --
            when others then
              if g_debug then
                hr_utility.set_location('BEN_92311_FORMULA_VAL_PARAM',46);
              end if;
              fnd_message.set_name('BEN','BEN_92311_FORMULA_VAL_PARAM');
              fnd_message.set_token('PROC',l_proc);
              fnd_message.set_token('FORMULA',l_prtl_mo_det_mthd_rl);
              fnd_message.set_token('PARAMETER',
                                   l_outputs(l_outputs.first).name);
              fnd_message.raise_error;
            --
          end;
        end if;
        --
        -- Approach/algorithm to allocating payments:
        --
        -- In ending a rate there are three distinct rate stages
        -- 1) Normal pay periods - Periodic rate is still in place.
        -- 2) Special pay period - pay period during which a rate not equal to the normal rate
        --    is in effect.  Just one pay period.  Spreading them out is outside the scope
        --    of this version.
        -- 3) No pay periods - pay periods during which no rate should be in effect.
        -----------------------------------------------------------
        --
        -- Want to find the pay periods from the start date
        -- ending at the last day of the month or earlier
        -- based on the date column specified by prtl_mo_eff_dt_det_cd
        --
        -- Go backwards and keep overwriting the dates with the most
        -- recent one to get the first date it changes to that rate.
        --
        l_remainder:=l_prorated_monthly_amt;
        l_number_in_month:=0;
        for l_pay_periods in c_last_pay_periods(
            p_start_date            => trunc(l_rt_end_dt,'mm'),
            p_end_date              => add_months(
                                       trunc(l_rt_end_dt,'mm'),1)-1,
            p_prtl_mo_eff_dt_det_cd => l_prtl_mo_eff_dt_det_cd,
            p_payroll_id            => l_payroll_id) loop
          --
          exit when l_pay_periods.start_date > l_rt_end_dt;
          --
          hr_elements.check_element_freq(
            p_payroll_id           =>l_payroll_id,
            p_bg_id                =>p_business_group_id,
            p_pay_action_id        =>to_number(null),
            p_date_earned          =>l_pay_periods.start_date,
            p_ele_type_id          =>l_element_type_id,
            p_skip_element         =>g_skip_element
          );
          if g_skip_element='N' then
            l_number_in_month:=l_number_in_month+1;
              if g_debug then
                hr_utility.set_location('l_zero_pp_date'||l_pay_periods.start_date,293.1);
                hr_utility.set_location('l_remainder'||l_remainder,293.1);
                hr_utility.set_location('l_pay_periods.end_date'||l_pay_periods.end_date,293.1);
                hr_utility.set_location('l_per_pay_amt'||l_per_pay_amt,293.1);
                hr_utility.set_location('l_rt_end_dt'||l_rt_end_dt,293.1);
              end if;
            if (l_remainder>l_per_pay_amt and
                 l_rt_end_dt > l_pay_periods.end_date) then
              --
              -- Normal pay period, may not be if have remainder left over
              --   In this case will revise date after loop is done
              --
              l_remainder:=l_remainder-l_per_pay_amt;
              l_old_normal_pp_date:=l_normal_pp_date;
              l_old_normal_pp_end_date:=l_normal_pp_end_date;
              l_normal_pp_end_date:=l_pay_periods.end_date;
              l_normal_pp_date:=l_pay_periods.start_date;
              if g_debug then
                hr_utility.set_location('normal end date'||l_normal_pp_end_date,293.1);
              end if;
              if g_debug then
                hr_utility.set_location('l_per_pay_amt'||l_per_pay_amt,293.1);
              end if;
            elsif l_remainder=0 then
              --
              -- Free pay period, no charge
              --
              l_zero_pp_date := l_pay_periods.start_date;
              if g_debug then
                hr_utility.set_location('l_zero_pp_date'||l_pay_periods.start_date,293.1);
              end if;
              exit;
            else
              --
              -- Special small pay period, from here on it's free.
              --
              l_special_pp_end_date:=l_pay_periods.end_date;
              l_special_pp_date:=l_pay_periods.start_date;
              l_special_amt:=l_remainder;
              l_remainder:=0;
            end if;
          end if;
        end loop;
        --
        -- Now check if loop was not entered
        --
        if l_remainder > 0 then
          --
          --  This is the Large amount case where the full amount gets added
          --  to the last pp of prev month
          --
          --
          --  The remaining amount is added to the current pay period.
          --
          open c_get_current_pp
           (p_end_date              => l_rt_end_dt
           ,p_prtl_mo_eff_dt_det_cd => l_prtl_mo_eff_dt_det_cd
           ,p_payroll_id            => l_payroll_id
           );
          fetch c_get_current_pp into l_start_date,l_end_date;
          if c_get_current_pp%notfound then
            close c_get_current_pp;
            if g_debug then
              hr_utility.set_location('BEN_92346_PAYROLL_NOT_DEFINED',48);
            end if;
            fnd_message.set_name('BEN', 'BEN_92346_PAYROLL_NOT_DEFINED');
            fnd_message.set_token('PROC',l_proc);
            fnd_message.raise_error;
          end if;
          --
          close c_get_current_pp;
            --
            --  Prorate for the current pay period.
            --
            --  If it is a skip period, do not prorate.
            --
            hr_elements.check_element_freq(
              p_payroll_id           =>l_payroll_id,
              p_bg_id                =>p_business_group_id,
              p_pay_action_id        =>to_number(null),
              p_date_earned          =>l_start_date,
              p_ele_type_id          =>l_element_type_id,
              p_skip_element         =>g_skip_element
            );
            --
            if g_skip_element = 'N' then
              l_special_pp_end_date:= l_end_date;
              l_special_pp_date:= l_start_date;
              if (l_number_in_month = 0 or
                  l_end_date = l_rt_end_dt) then
                l_special_amt:=l_remainder + l_per_pay_amt;
              else
                l_special_amt := l_remainder;
              end if;
            else
              --
              --  If skip element then display a informational message
              --  indicating that there is no proration and user will need
              --  to manually process a deduction.
              --
              ben_warnings.load_warning
               (p_application_short_name  => 'BEN',
                p_message_name            => 'BEN_92939_NO_PRORATION',
                p_person_id               => p_person_id);
              --
              fnd_message.set_name('BEN', 'BEN_92939_NO_PRORATION');
              if fnd_global.conc_request_id <> -1 then
                benutils.write(fnd_message.get);
              end if;
                     --
              l_immediate_end := true;
            end if;
          elsif (l_remainder = 0 and
                 l_rt_end_dt > l_special_pp_end_date
                 and l_zero_pp_date is null) then
            --
            --  The remaining amount is added to the current pay period.
            --
            open c_get_current_pp
             (p_end_date              => l_rt_end_dt
             ,p_prtl_mo_eff_dt_det_cd => l_prtl_mo_eff_dt_det_cd
             ,p_payroll_id            => l_payroll_id
             );
            fetch c_get_current_pp into l_zero_pp_date,l_end_date;
            if c_get_current_pp%notfound then
              close c_get_current_pp;
              if g_debug then
                hr_utility.set_location('BEN_92346_PAYROLL_NOT_DEFINED',48);
              end if;
              fnd_message.set_name('BEN', 'BEN_92346_PAYROLL_NOT_DEFINED');
              fnd_message.set_token('PROC',l_proc);
              fnd_message.raise_error;
            end if;
            --
            close c_get_current_pp;
          end if; -- l_remainder > 0
          --
        --
        -- In the cases where a normal pp was not found then it
        -- must be the last pp of the previous month but
        --
        --
        if l_normal_pp_date is null then
          open c_pps_prev_month(
                 p_end_date              => trunc(l_rt_end_dt,'mm'),
                 p_prtl_mo_eff_dt_det_cd => l_prtl_mo_eff_dt_det_cd,
                 p_payroll_id            => l_payroll_id);
          loop
            fetch c_pps_prev_month into l_start_date,l_end_date;
            if c_pps_prev_month%notfound then
              close c_pps_prev_month;
              if g_debug then
                hr_utility.set_location('BEN_92346_PAYROLL_NOT_DEFINED',50);
              end if;
              fnd_message.set_name('BEN', 'BEN_92346_PAYROLL_NOT_DEFINED');
              fnd_message.set_token('PROC',l_proc);
              fnd_message.raise_error;
            end if;
            hr_elements.check_element_freq(
              p_payroll_id           =>l_payroll_id,
              p_bg_id                =>p_business_group_id,
              p_pay_action_id        =>to_number(null),
              p_date_earned          =>l_start_date,
              p_ele_type_id          =>l_element_type_id,
              p_skip_element         =>g_skip_element
            );
            exit when g_skip_element='N';
          end loop;
          close c_pps_prev_month;
          l_normal_pp_end_date:=l_end_date;
          l_normal_pp_date:=l_start_date;
          if g_debug then
            hr_utility.set_location('normal end date'||l_normal_pp_end_date,293.1);
          end if;
        end if;
      else
        --
        -- No proration end on rt_end date.
        --
        l_immediate_end:=true;
        --
      end if;
      --
      -- Don't make unnecessary changes: compare old value to new one
      --
      -- Do special pay period.
      --
      if g_debug then
         hr_utility.set_location('l_special_pp_date '||l_special_pp_date,20);
         hr_utility.set_location('l_special_amt '||l_special_amt,20);
      end if;

      if l_special_pp_date is not null and
         l_immediate_end=false then
         --
         -- bug 2651153 get the currency of the program

         --
         -- changes the format of the screen entry value as per the session
         --

         if l_uom is null then
            l_uom := get_uom(p_business_group_id,p_effective_date);
         end if;
         l_curr_val := chkformat(l_curr_val_char, l_uom);

         if g_debug then
           hr_utility.set_location('l_uom='|| l_uom ,432);
           hr_utility.set_location('aft frmt chg '||l_curr_val_char,432);
           hr_utility.set_location('converted no. value is '||l_curr_val,432);
         end if;

         if nvl(l_curr_val,hr_api.g_number) <>l_special_amt then
        /*
           Before :-
             02-JAN-1994
                 |-A----------------------------------------------------->
                                                   ED

           After :-
             02-JAN-1994                    15-JUL-1994
                 |-A----------------------------|-B---------------------->
                                                   ED
        */

           -- Bug 2331574 start
           -- To handle cases where the element entry start date >
           -- special pay period start date
           if g_debug then
             hr_utility.set_location('Updating if the rate has changed ',90);
             hr_utility.set_location('l_immediate_end=false ',20);
           end if;

           if l_special_pp_date < l_element_entry_start_date then
             l_special_pp_date := l_element_entry_start_date;
           end if;

           -- Determine the Date track update mode for calling
           -- py_element_entry_api.update_element_entry

           l_dt_upd_mode := get_ele_dt_upd_mode(l_special_pp_date,l_element_entry_id);
           --
           open c_element_ovn (l_element_entry_id, l_special_pp_date);
           fetch c_element_ovn into l_object_version_number;
           close c_element_ovn;
           --
           if g_debug then
             hr_utility.set_location('Obj No.'||l_object_version_number,111);
             hr_utility.set_location('Special PP'||l_special_pp_date,112);
             hr_utility.set_location('Datetrack Mode'||l_dt_upd_mode,113);
           end if;

           py_element_entry_api.update_element_entry
             (p_validate                      =>p_validate
             ,p_datetrack_update_mode         =>l_dt_upd_mode
             ,p_effective_date                =>l_special_pp_date
             ,p_business_group_id             =>p_business_group_id
             ,p_element_entry_id              =>l_element_entry_id
             ,p_object_version_number         =>l_object_version_number
             ,p_creator_type                  =>'F'
             ,p_creator_id                    =>p_enrt_rslt_id
             ,p_override_user_ent_chk         =>'Y'
             ,p_input_value_id1               =>l_input_value_id
             ,p_entry_value1                  =>l_special_amt
             ,p_effective_start_date          =>l_new_date
             ,p_effective_end_date            =>l_end_of_time
             ,p_update_warning                =>l_update_warning
           );
           --
           --
           -- write to the change event log
           --
           ben_ext_chlg.log_element_chg(
           p_action               => l_dt_upd_mode,
           p_amt                  => l_special_amt,
           p_old_amt              => l_curr_val,
           p_input_value_id       => l_input_value_id,
           p_element_entry_id     => l_element_entry_id,
           p_person_id            => p_person_id,
           p_business_group_id    => p_business_group_id,
           p_effective_date       => l_special_pp_date);
           --
           --
           -- Set the rate end date to the earlier of the
           -- rate_end_date or the period end date
           --
        end if;
      end if;
      --
      -- Bug:2730801 - Moved the following code out from the
      -- special pay periods if condition.
      -- Because this is executing only for the special pay periods.
      --
      /*
           Example: When rate has a wash role as 15 days. If a employee
                    terminated 14th of the month then he should not get charged
                    from 1st to 14th of the month, that pay period will be
                    zero pay period.
           Before :-
             02-JAN-1994
                 |-A----------------------------------------------------->
                                                   ED

           After :-
             02-JAN-1994          01-JUL-94   14-JUL-1994
                 |-A------------------|----------|-B---------------------->
                                        zero pp   ED
      */
      if l_zero_pp_date is not null and
         l_immediate_end=false then
          --
          l_curr_val := l_special_amt;
          if g_debug then
            hr_utility.set_location('l_zero_pp_date '||l_zero_pp_date,20);
          end if;

          l_dt_to_use := greatest(l_prv_rec.rt_strt_dt,l_zero_pp_date);
          open c_element_ovn (l_element_entry_id, l_dt_to_use);
          fetch c_element_ovn into l_object_version_number;
          close c_element_ovn;
          --
          l_dt_upd_mode := get_ele_dt_upd_mode(l_dt_to_use,l_element_entry_id);

          py_element_entry_api.update_element_entry
            (p_validate                      =>p_validate
            ,p_datetrack_update_mode         =>l_dt_upd_mode
            ,p_effective_date                =>l_dt_to_use
            ,p_business_group_id             =>p_business_group_id
            ,p_element_entry_id              =>l_element_entry_id
            ,p_object_version_number         =>l_object_version_number
            ,p_override_user_ent_chk         =>'Y'
            ,p_creator_type                  =>'F'
            ,p_creator_id                    =>p_enrt_rslt_id
            ,p_input_value_id1               =>l_input_value_id
            ,p_entry_value1                  =>0
            ,p_effective_start_date          =>l_new_date
            ,p_effective_end_date            =>l_end_of_time
            ,p_update_warning                =>l_update_warning
            );
          --
          -- write to the change event log
          --
          ben_ext_chlg.log_element_chg
            (p_action               => hr_api.g_update
            ,p_amt                  => 0
            ,p_old_amt              => l_curr_val
            ,p_input_value_id       => l_input_value_id
            ,p_element_entry_id     => l_element_entry_id
            ,p_person_id            => p_person_id
            ,p_business_group_id    => p_business_group_id
            ,p_effective_date       => l_dt_to_use
            );
      end if;
   end if;
   --
   -- Done with special value pay period, now end rate
   --
   if g_debug then
      hr_utility.set_location('DT Delete mode '||l_dt_delete_mode,30);
   end if;
   --
   -- bug 9148303 : update only if the element entry is attached to primary assignment
   -- and another prv exists

   open c_ass_type (l_assignment_id, l_rt_end_dt+1);
   fetch c_ass_type into l_ass_type;
   close c_ass_type;

   if l_another_prv_exists and nvl(l_ass_type.primary_flag,'N') = 'Y' then
      --
      l_dt_upd_mode := get_ele_dt_upd_mode(l_rt_end_dt+1,l_element_entry_id);
      --
      -- get the ovn
      --
      open c_element_ovn (l_element_entry_id, l_rt_end_dt+1);
      fetch c_element_ovn into l_object_version_number;
      close c_element_ovn;
      --
      py_element_entry_api.update_element_entry
        (p_validate                      =>p_validate
        ,p_datetrack_update_mode         =>l_dt_upd_mode
        ,p_effective_date                =>l_rt_end_dt + 1
        ,p_business_group_id             =>p_business_group_id
        ,p_element_entry_id              =>l_element_entry_id
        ,p_override_user_ent_chk         =>'Y'
        ,p_object_version_number         =>l_object_version_number
        ,p_input_value_id1               =>l_input_value_id
        ,p_entry_value1                  =>0
        ,p_effective_start_date          =>l_effective_start_date
        ,p_effective_end_date            =>l_effective_end_date
        ,p_update_warning                =>l_update_warning
        );
      --
      -- write to the change event log
      --
      ben_ext_chlg.log_element_chg
        (p_action           => 'UPDATE'
        ,p_amt              => 0
        ,p_old_amt          => fnd_number.canonical_to_number(l_curr_val_char)
        ,p_input_value_id   => l_input_value_id
        ,p_element_entry_id => l_element_entry_id
        ,p_person_id        => p_person_id
        ,p_business_group_id=> p_business_group_id
        ,p_effective_date   => l_rt_end_dt + 1
        );
      --
   else
      --
      -- get the ovn
      --
      open c_element_ovn (l_element_entry_id, l_rt_end_dt);
      fetch c_element_ovn into l_object_version_number;
      close c_element_ovn;
      --
      py_element_entry_api.delete_element_entry
        (p_validate              => p_validate
        ,p_datetrack_delete_mode => l_dt_delete_mode
        ,p_effective_date        => l_rt_end_dt
        ,p_element_entry_id      => l_element_entry_id
        ,p_object_version_number => l_object_version_number
        ,p_effective_start_date  => l_effective_start_date
        ,p_effective_end_date    => l_effective_end_date
        ,p_delete_warning        => l_delete_warning);
      --
      -- write to the change event log
      --
      ben_ext_chlg.log_element_chg(
      p_action               => hr_api.g_delete,
      p_old_amt              => fnd_number.canonical_to_number(l_curr_val_char),
      p_input_value_id       => l_input_value_id,
      p_element_entry_id     => l_element_entry_id,
      p_person_id            => p_person_id,
      p_business_group_id    => p_business_group_id,
      p_effective_date       => l_rt_end_dt);
      --
   end if;

   if l_abs_ler then
        pqp_absence_plan_process.update_absence_plan_details
        (p_person_id               => p_person_id
        ,p_assignment_id           => l_assignment_id
        ,p_business_group_id       => p_business_group_id
        ,p_legislation_code        => get_legislation_code(p_business_group_id)
        ,p_effective_date          => p_effective_date
        ,p_element_type_id         => l_element_type_id
        ,p_pl_id                   => g_result_rec.pl_id
        ,p_pl_typ_id               => g_result_rec.pl_typ_id
        ,p_ler_id                  => l_ler_id
        ,p_per_in_ler_id           => l_per_in_ler_id
        ,p_absence_attendance_id   => l_absence_attendance_id
        ,p_effective_start_date    => l_effective_start_date
        ,p_effective_end_date      => l_effective_end_date
        ,p_formula_outputs         => g_outputs
        ,p_error_code              => l_err_code
        ,p_error_message           => l_err_mesg
        );
   end if;
   --
  end if;
  --
  -- delete/update any future entries for the same enrt result.
  -- Future entries could exist if there was an update to assignment
  -- that affected link eligibility
  --
  open get_future_element_entry
 (p_enrt_rslt_id
  ,l_assignment_id
  ,l_element_type_id
  ,l_effective_date);
  loop
       fetch get_future_element_entry into l_future_ee_rec;
       if get_future_element_entry%notfound then
          exit;
       end if;

       if l_another_prv_exists then
          --
          l_dt_upd_mode := get_ele_dt_upd_mode
                           (l_future_ee_rec.effective_end_date,
                            l_future_ee_rec.element_entry_id);
          --
          py_element_entry_api.update_element_entry
            (p_validate               =>p_validate
            ,p_datetrack_update_mode  =>l_dt_upd_mode
            ,p_effective_date         =>l_future_ee_rec.effective_end_date
            ,p_business_group_id      =>p_business_group_id
            ,p_element_entry_id       =>l_future_ee_rec.element_entry_id
            ,p_override_user_ent_chk  =>'Y'
            ,p_object_version_number  =>l_future_ee_rec.object_version_number
            ,p_input_value_id1        =>l_input_value_id
            ,p_entry_value1           =>0
            ,p_effective_start_date   =>l_effective_start_date
            ,p_effective_end_date     =>l_effective_end_date
            ,p_update_warning         =>l_update_warning
            );
          --
          -- write to the change event log
          --
          ben_ext_chlg.log_element_chg
            (p_action           => l_dt_upd_mode
            ,p_amt              => 0
            ,p_old_amt          => fnd_number.canonical_to_number(l_curr_val_char)
            ,p_input_value_id   => l_input_value_id
            ,p_element_entry_id => l_future_ee_rec.element_entry_id
            ,p_person_id        => p_person_id
            ,p_business_group_id=> p_business_group_id
            ,p_effective_date   => p_effective_date);
          --
       else
          py_element_entry_api.delete_element_entry
          (p_validate => p_validate
          ,p_datetrack_delete_mode => hr_api.g_zap
          ,p_effective_date        => l_future_ee_rec.effective_start_date
          ,p_element_entry_id      => l_future_ee_rec.element_entry_id
          ,p_object_version_number => l_future_ee_rec.object_version_number
          ,p_effective_start_date  => l_effective_start_date
          ,p_effective_end_date    => l_effective_end_date
          ,p_delete_warning        => l_delete_warning
          );
          --
          -- write to the change event log
          --
          ben_ext_chlg.log_element_chg(
          p_action            => 'DELETE',
          p_old_amt         => fnd_number.canonical_to_number(l_curr_val_char),
          p_input_value_id    => l_input_value_id,
          p_element_entry_id  => l_future_ee_rec.element_entry_id,
          p_person_id         => p_person_id,
          p_business_group_id => p_business_group_id,
          p_effective_date    => p_effective_date);
          --
       end if;
       --
  end loop;
  close get_future_element_entry;

  if g_debug then
    hr_utility.set_location('Leaving :'||l_proc,5);
  end if;

end end_enrollment_element;
--
-- 0 - Always refresh
-- 1 - Initialise cache
-- 2 - Cache hit
--
procedure clear_down_cache
is

begin
  --
  g_get_link_cache.delete;
  g_get_link_cached := 1;
  g_abr_asg_rec := null;
  g_per_pay_rec := null;
  --
end clear_down_cache;
--
procedure set_no_cache_context
is

begin
  --
  g_get_link_cache.delete;
  g_get_link_cached := 0;
  --
end set_no_cache_context;
--
procedure reset_msg_displayed --bug 2530582
is
begin
g_msg_displayed := 0;
end reset_msg_displayed;
--
procedure create_reimburse_element
  (p_validate                  in     boolean default false
  ,p_person_id                 in     number
  ,p_acty_base_rt_id           in     number
  ,p_amt                       in     number
  ,p_business_group_id         in     number
  ,p_effective_date            in     date
  ,p_prtt_reimbmt_rqst_id      in     number  default null
  ,p_input_value_id            in     number  default null
  ,p_element_type_id           in     number  default null
  ,p_pl_id                     in     number  default null
  ,p_prtt_rmt_aprvd_fr_pymt_id in     number
  ,p_object_version_number     in out nocopy number
  )  is
 --
  cursor c_element_entry (p_element_entry_id number,
                          p_input_value_id  number) is
    select element_entry_value_id
    from pay_element_entry_values_f
    where ELEMENT_ENTRY_ID = p_element_entry_id
    and   input_value_id  = p_input_value_id;
  --
  cursor c_ety is
    select processing_type
    from pay_element_types_f
    where element_type_id = p_element_type_id
    and p_effective_date between effective_start_date
    and effective_end_date ;
  --
  l_tmp_bool boolean;
  l_assignment_id  number;
  l_organization_id  number;
  l_payroll_id       number;
  l_create_warning        BOOLEAN;
  l_update_warning        BOOLEAN;
  l_effective_start_date  date;
  l_effective_end_Date    date;
  l_object_version_number  number;
  l_element_link_id       NUMBER;
  l_input_value_id        number;
  L_ELEMENT_ENTRY_ID      number;
  l_element_entry_value_id  number;
  l_processing_type         varchar2(300);
  l_delete_warning         boolean;
  --

begin
  --
  if g_debug then
    hr_utility.set_location('Entering : create_reimburse_element',50);
  end if;
  l_tmp_bool:=chk_assign_exists
                  (p_person_id         => p_person_id
                  ,p_business_group_id => p_business_group_id
                  ,p_effective_date    => p_effective_date
                  ,p_rate_date         => p_effective_date
                  ,p_acty_base_rt_id   => p_acty_base_rt_id
                  ,p_assignment_id     => l_assignment_id
                  ,p_organization_id   => l_organization_id
                  ,p_payroll_id        => l_payroll_id
                  );
  --
  --
  if g_debug then
    hr_utility.set_location('l_assignment_id:'||l_assignment_id,50);
    hr_utility.set_location('l_payroll_id:'||l_payroll_id,50);
  end if;
  --
   get_link(p_assignment_id     => l_assignment_id
          ,p_element_type_id   => p_element_type_id
          ,p_business_group_id => p_business_group_id
          ,p_input_value_id    => l_input_value_id
          ,p_effective_date    => p_effective_date
          ,p_element_link_id   => l_element_link_id
          );
  if l_element_link_id is null then
     --
     -- error message already set on stack.
     --
     fnd_message.raise_error;
  end if;
  hr_utility.set_location( 'entering', 30.2);
  py_element_entry_api.create_element_entry
          (p_validate              =>p_validate
          ,p_effective_date        =>p_effective_date
          ,p_business_group_id     =>p_business_group_id
          ,p_assignment_id         =>l_assignment_id
          ,p_element_link_id       =>l_element_link_id
          ,p_entry_type            =>'E'
          ,p_input_value_id1       =>p_input_value_id
          ,p_entry_value1          =>p_amt
          ,p_effective_start_date  =>l_effective_start_date
          ,p_effective_end_date    =>l_effective_end_Date
          ,p_element_entry_id      =>l_element_entry_id
          ,p_object_version_number =>l_object_version_number
          ,p_create_warning        =>l_create_warning
          );
        --
        --
  hr_utility.set_location('Change creator type and id ',50);
  py_element_entry_api.update_element_entry
          (p_validate                      =>p_validate
          ,p_datetrack_update_mode         =>'CORRECTION'
          ,p_effective_date                =>p_effective_date
          ,p_business_group_id             =>p_business_group_id
          ,p_element_entry_id              =>l_element_entry_id
          ,p_object_version_number         =>l_object_version_number
          ,p_creator_type                  =>'F'
          ,p_creator_id                    =>p_prtt_reimbmt_rqst_id
          ,p_input_value_id1               =>p_input_value_id
          ,p_entry_value1                  =>p_amt
          ,p_effective_start_date          =>l_effective_start_date
          ,p_effective_end_date            =>l_effective_end_Date
          ,p_update_warning                =>l_update_warning
          );
        --
  --
  open c_ety;
  fetch c_ety into l_processing_type;
  if l_processing_type = 'R' then
    -- the element should be end dated
    py_element_entry_api.delete_element_entry
        (p_validate              => p_validate
        ,p_datetrack_delete_mode => hr_api.g_delete
        ,p_effective_date        => p_effective_date
        ,p_element_entry_id      => l_element_entry_id
        ,p_object_version_number => l_object_version_number
        ,p_effective_start_date  => l_effective_start_date
        ,p_effective_end_date    => l_effective_end_date
        ,p_delete_warning        => l_delete_warning
        );
      --

  end if;
  close c_ety;
  --
  open c_element_entry (l_element_entry_id,p_input_value_id);
  fetch c_element_entry into l_element_entry_value_id;
  close c_element_entry;
  --
  if l_element_entry_value_id is null then
    --
      if g_debug then
        hr_utility.set_location('BEN_92102_NO_ENTRY_CREATED',140);
      end if;
      fnd_message.set_name('BEN', 'BEN_92102_NO_ENTRY_CREATED');
      fnd_message.set_token('PROC','Create_reimburse_element');
      fnd_message.set_token('ELEMENT_ENTRY_ID',to_char(l_element_link_id));
      fnd_message.set_token('INPUT_VALUE_ID',to_char(l_input_value_id));
      fnd_message.set_token('EFFECTIVE_DATE',to_char(p_effective_date));
      fnd_message.raise_error;
  else
    --
    ben_prtt_rmt_aprvd_pymt_api.update_prtt_rmt_aprvd_pymt
     (p_prtt_rmt_aprvd_fr_pymt_id => p_prtt_rmt_aprvd_fr_pymt_id,
      p_effective_start_date => l_effective_start_date,
      p_effective_end_date   => l_effective_end_date,
      p_element_entry_value_id => l_element_entry_value_id,
      p_object_version_number => p_object_version_number,
      p_effective_date => p_effective_date,
      p_aprvd_fr_pymt_amt => p_amt,
      p_datetrack_mode => 'CORRECTION');
    --
  end if;


  hr_utility.set_location('Leaving : Create_reimburse_element',51);
  --
end ;
--
procedure end_reimburse_element(p_validate IN BOOLEAN default FALSE
                                ,p_business_group_id IN NUMBER
                                ,p_person_id IN NUMBER
                                ,p_prtt_reimbmt_rqst_id IN NUMBER
                                ,p_element_link_id IN NUMBER
                                ,p_prtt_rmt_aprvd_fr_pymt_id in number
                                ,p_effective_date IN DATE
                                ,p_dt_delete_mode IN VARCHAR2
                                ,p_element_entry_value_id  in number) is
--
 cursor c_ele_info (p_element_entry_value_id number) is
   select ele.element_entry_id,
          ele.entry_type,
          ele.original_entry_id,
          elt.processing_type,
          elk.element_type_id,
          elk.effective_end_date
     from pay_element_entry_values_f elv,
          pay_element_entries_f ele,
          pay_element_links_f elk,
          pay_element_types_f elt
    where elv.element_entry_value_id  = p_element_entry_value_id
      and elv.element_entry_id = ele.element_entry_id
      and elv.effective_start_date between ele.effective_start_date
      and ele.effective_end_date
      and ele.element_link_id   = elk.element_link_id
      and ele.effective_start_date between elk.effective_start_date
      and elk.effective_end_date
      and elk.element_type_id = elt.element_type_id
      and elk.effective_start_date between elt.effective_start_date
      and elt.effective_end_date ;
  --
  l_ele_rec                c_ele_info%rowtype;
  --
 cursor c_element_entry (p_element_entry_id  number) is
   select object_version_number
   from pay_element_entries_f
   where element_entry_id = p_element_entry_id;
 --
 l_object_version_number   number;
 l_element_entry_id        number;
 l_effective_start_date    date;
 l_effective_end_date      date;
 l_delete_warning          boolean;
 l_processed_flag          varchar2(300);

begin
--
 open c_ele_info(p_element_entry_value_id);
 fetch c_ele_info into l_ele_rec;
 --
 if c_ele_info%notfound then
   close c_ele_info;
 if g_debug then
    --
    hr_utility.set_location('Leaving:  End reimburse element',7);
 end if;
   return;
 end if;
 close c_ele_info;
 --
 l_processed_flag := substr(pay_paywsmee_pkg.processed(
                                   l_ele_rec.element_entry_id,
                                   l_ele_rec.original_entry_id,
                                   l_ele_rec.processing_type,
                                   l_ele_rec.entry_type,
                                   p_effective_date), 1,1) ;
        --
 if l_processed_flag = 'Y' then
   --
    fnd_message.set_name ('BEN','BEN_93341_PRCCSD_IN_PAYROLL');
    fnd_message.raise_error;
    --
 end if;
 --
 open c_element_entry (l_ele_rec.element_entry_id);
 fetch c_element_entry into l_object_version_number;
 close c_element_entry;
 --
 py_element_entry_api.delete_element_entry
        (p_validate => p_validate
        ,p_datetrack_delete_mode => hr_api.g_zap
        ,p_effective_date        => p_effective_date
        ,p_element_entry_id      => l_ele_rec.element_entry_id
        ,p_object_version_number => l_object_version_number
        ,p_effective_start_date  => l_effective_start_date
        ,p_effective_end_date    => l_effective_end_date
        ,p_delete_warning        => l_delete_warning
        );

    hr_utility.set_location('Leaving:  End reimburse element',7);
end;

--
end ben_element_entry;

/
