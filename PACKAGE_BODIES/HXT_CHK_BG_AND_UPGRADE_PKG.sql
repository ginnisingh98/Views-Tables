--------------------------------------------------------
--  DDL for Package Body HXT_CHK_BG_AND_UPGRADE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXT_CHK_BG_AND_UPGRADE_PKG" as
/* $Header: hxtbgupg.pkb 120.0 2005/05/29 06:00:46 appldev noship $ */

-------------------------------------------------------------------------------
PROCEDURE hxt_bg_message_insert(
  P_PHASE  IN  VARCHAR2,
  P_TEXT   IN  VARCHAR2        ) IS
--
PRAGMA AUTONOMOUS_TRANSACTION;
--
sql_insert  VARCHAR2(300);
--
Begin
  sql_insert := 'INSERT INTO HXT_UPGRADE_BG_MESSAGES VALUES (:1, :2)';
  EXECUTE IMMEDIATE sql_insert USING p_phase, p_text;
--
  COMMIT;
--
End;
-------------------------------------------------------------------------------
FUNCTION hxt_bg_checker RETURN boolean IS
--
-- Declare global variables
--
g_valid      boolean := True;
g_sub_valid  boolean := True;
g_sub_bg     number  := -1;
g_token      varchar2(150);
--
-- Declare cursors
--
-- cursor to get all Workplans.
--
CURSOR c_get_workplans IS
  SELECT DISTINCT
         wws.id
  ,      wws.name
  FROM   hxt_weekly_work_schedules  wws;
--
-- cursor to get all rotation plans.
--
CURSOR c_get_rotation_plans IS
  SELECT DISTINCT
         rtp.id
  ,      rtp.name
  from   hxt_rotation_plans         rtp;
--
-- cursor to get all Earning Groups.
--
CURSOR c_get_earn_groups IS
  SELECT DISTINCT
         egt.id
  ,      egt.name
  FROM   hxt_earn_group_types        egt;
--
-- cursor to get all Premium Eligibility Policies.
--
CURSOR c_get_peps IS
  SELECT DISTINCT
         pep.id
  ,      pep.name
  FROM   hxt_prem_eligblty_policies  pep;
--
-- cursor to get all Premium Interaction Policies.
--
CURSOR c_get_pips IS
  SELECT DISTINCT
         pip.id
  ,      pip.name
  FROM   hxt_prem_interact_policies  pip;
--
-- cursor to get all Holiday Calendars.
--
CURSOR c_get_hol_cals IS
  SELECT DISTINCT
         hcl.id
  ,      hcl.name
  FROM   hxt_holiday_calendars       hcl;
--
-- cursor to get all Earning Policies
--
CURSOR c_get_earn_pols IS
  SELECT DISTINCT
         hep.id
  ,      hep.name
  ,      hep.hcl_id
  ,      hep.pip_id
  ,      hep.pep_id
  ,      hep.egt_id
  ,      nvl(hep.business_group_id,-1) bg_id
  FROM   hxt_earning_policies          hep;
--
-- cursor to get all Shift Differential Policies.
--
CURSOR c_get_shift_diffs IS
  SELECT DISTINCT
         sdp.id
  ,      sdp.name
  FROM   hxt_shift_diff_policies  sdp;
--
-- cursor to get all Additional Assignment Info.
--
CURSOR c_get_add_ass_info IS
  SELECT DISTINCT
         aai.id                         id
  ,      aai.assignment_id              ass_id
  ,      aai.rotation_plan              rp_id
  ,      aai.earning_policy             ep_id
  ,      epg.hcl_id                     ep_hcl
  ,      epg.pip_id                     ep_pip
  ,      epg.pep_id                     ep_pep
  ,      epg.egt_id                     ep_egt
  ,      nvl(epg.business_group_id,-1)  ep_bg
  ,      aai.shift_differential_policy  sdp_id
  ,      ass.business_group_id          ass_bg
  ,      nvl(hdp.business_group_id,-1)  hdp_bg
  FROM   hxt_add_assign_info_f        aai
  ,      hxt_rotation_plans           rpl
  ,      hxt_earning_policies         epg
  ,      hxt_shift_diff_policies      sdp
  ,      hxt_hour_deduct_policies     hdp
  ,      per_assignments_f            ass
  WHERE  aai.assignment_id              = ass.assignment_id
  AND    aai.rotation_plan              = rpl.id (+)
  AND    aai.earning_policy             = epg.id
  AND    aai.shift_differential_policy  = sdp.id (+)
  AND    aai.hour_deduction_policy      = hdp.id (+);
--
-- cursor to get all Timecards.
--
CURSOR c_get_timecards IS
  SELECT DISTINCT
         tim.id                         id
  ,      ptp.period_name                period
  ,      ppf.business_group_id          per_bg
  ,      nvl(pbh.business_group_id,-1)  batch_bg
  ,      ppr.business_group_id          pay_bg
  FROM   hxt_timecards          tim
  ,      per_people_f           ppf
  ,      pay_payrolls           ppr
  ,      pay_batch_headers      pbh
  ,      per_time_periods       ptp
  WHERE  tim.for_person_id      = ppf.person_id
  AND    tim.batch_id           = pbh.batch_id (+)
  AND    tim.payroll_id         = ppr.payroll_id
  AND    tim.time_period_id     = ptp.time_period_id;
--
-- Declare local procedures
--
-- Workplans Validation Procedure.
--
PROCEDURE chk_workplans
  (p_wp_id   IN     number
  ,p_wp_name IN     varchar2
  ,p_wp_bg      OUT NOCOPY number
  ,p_valid      OUT NOCOPY boolean
  ) IS
--
CURSOR c_wp_bg_check IS
  SELECT DISTINCT(pet.business_group_id) bg
  FROM   hxt_work_shifts      wsh
  ,      pay_element_types_f  pet
  WHERE  wsh.tws_id              = p_wp_id
  AND    wsh.shift_diff_ovrrd_id = pet.element_type_id
  AND    pet.business_group_id   is not null
  UNION
  SELECT DISTINCT(pet.business_group_id) bg
  FROM   hxt_work_shifts     ws
  ,      pay_element_types_f pet
  WHERE  ws.tws_id             = p_wp_id
  AND    ws.off_shift_prem_id  = pet.element_type_id
  AND    pet.business_group_id is not null
  UNION
  SELECT business_group_id
  FROM   hxt_weekly_work_schedules
  WHERE  id                = p_wp_id
  AND    business_group_id is not null;
--
  l_count  number  := 0;
  l_valid  boolean := True;
  l_bg     number  := -1;
--
Begin
  for wpbg in c_wp_bg_check loop
    l_count := l_count +1;
    if l_count > 1 then
      hxt_bg_message_insert('V','Workplan '||p_wp_name||' Is Invalid');
      l_valid := False;
      l_bg := -1;
    else
      l_bg := wpbg.bg;
    end if;
  end loop;
--
p_valid	:= l_valid;
p_wp_bg	:= l_bg;
--
End chk_workplans;
--
-- Rotation Plans Validation Procedure.
--
Procedure chk_rotplans
  (p_rp_id   IN     number
  ,p_rp_name IN     varchar2
  ,p_rp_bg      OUT NOCOPY number
  ,p_valid      OUT NOCOPY boolean
  ) is
--
CURSOR c_rp_bg_check is
  select distinct(pet.business_group_id) bg
  from   hxt_rotation_schedules          rts
  ,      hxt_weekly_work_schedules       wws
  ,      hxt_work_shifts                 wsh
  ,      pay_element_types_f             pet
  where  wws.id                = rts.tws_id
  and    rts.rtp_id            = p_rp_id
  and    wsh.tws_id            = wws.id
  and    wsh.off_shift_prem_id = pet.element_type_id
  and    pet.business_group_id is not null
  union
  select distinct(pet.business_group_id) bg
  from   hxt_rotation_schedules          rts
  ,      hxt_weekly_work_schedules       wws
  ,      hxt_work_shifts                 wsh
  ,      pay_element_types_f             pet
  where  wws.id                  = rts.tws_id
  and    rts.rtp_id              = p_rp_id
  and    wsh.tws_id              = wws.id
  and    wsh.shift_diff_ovrrd_id = pet.element_type_id
  and    pet.business_group_id	 is not null
  union
  select distinct
         wws.business_group_id
  from   hxt_weekly_work_schedules wws
  ,      hxt_rotation_schedules    rts
  where  wws.id                = rts.tws_id
  and    rts.rtp_id            = p_rp_id
  and    wws.business_group_id is not null;
--
  l_bg     number   := -1;
  l_valid  boolean  := True;
  l_count  number   := 0;
--
Begin
  for rpbg in c_rp_bg_check loop
    l_count := l_count +1;
    if l_count > 1 then
      hxt_bg_message_insert('V','Rotation Plan '||p_rp_name||' Is Invalid');
      l_valid := False;
      l_bg    := -1;
    else
      l_bg := rpbg.bg;
    end if;
  end loop;
--
p_valid	:= l_valid;
p_rp_bg	:= l_bg;
--
End chk_rotplans;
--
-- Earning Groups Validation Procedure.
--
Procedure chk_earn_groups
  (p_eg_id   IN     number
  ,p_eg_name IN     varchar2
  ,p_eg_bg      OUT NOCOPY number
  ,p_valid      OUT NOCOPY boolean
  ) is
--
CURSOR c_eg_bg_check is
  select distinct(pet.business_group_id) bg
  from 	 hxt_earn_groups                 egr
  , 	 pay_element_types_f             pet
  where  egr.egt_id            = p_eg_id
  and    egr.element_type_id   = pet.element_type_id
  and    pet.business_group_id is not null;
--
  l_bg     number   := -1;
  l_valid  boolean  := True;
  l_count  number   := 0;
--
Begin
  for earns in c_eg_bg_check loop
    l_count := l_count +1;
    if l_count > 1 then
      hxt_bg_message_insert('V','Earning Group '||p_eg_name||' Is Invalid');
      l_valid := False;
      l_bg    := -1;
    else
      l_bg := earns.bg;
    end if;
  end loop;
--
p_valid	:= l_valid;
p_eg_bg	:= l_bg;
--
End chk_earn_groups;
--
-- Premium Eligibility Policies Validation Procedure.
--
Procedure chk_prem_elig_pols
  (p_pep_id   IN     number
  ,p_pep_name IN     varchar2
  ,p_pep_bg      OUT NOCOPY number
  ,p_valid       OUT NOCOPY boolean
  ) is
--
CURSOR c_pep_bg_check is
  select distinct(pet.business_group_id) bg
  from 	 hxt_prem_eligblty_pol_rules     epr
  , 	 pay_element_types_f             pet
  where  epr.pep_id      = p_pep_id
  and    epr.elt_base_id = pet.element_type_id
  union
  select distinct(pet.business_group_id) bg
  from   hxt_prem_eligblty_rules         elr
  ,      pay_element_types_f             pet
  where  elr.pep_id      = p_pep_id
  and    elr.elt_base_id = pet.element_type_id
  union
  select distinct(pet.business_group_id) bg
  from   hxt_prem_eligblty_rules         elr
  ,      pay_element_types_f             pet
  where  elr.pep_id         = p_pep_id
  and    elr.elt_premium_id = pet.element_type_id;
--
  l_bg    number  := -1;
  l_valid boolean := True;
  l_count number  := 0;
--
Begin
  for pepbg in c_pep_bg_check loop
    l_count := l_count +1;
    if l_count > 1 then
      hxt_bg_message_insert('V','Premium Eligibility Policy '||p_pep_name||' Is Invalid');
      l_valid := False;
      l_bg    := -1;
    else
      l_bg := pepbg.bg;
    end if;
  end loop;
--
p_valid	 := l_valid;
p_pep_bg := l_bg;
--
End chk_prem_elig_pols;
--
-- Premium Interaction Policies Validation Procedure
--
Procedure chk_prem_inter_pols
  (p_pip_id   IN     number
  ,p_pip_name IN     varchar2
  ,p_pip_bg      OUT NOCOPY number
  ,p_valid       OUT NOCOPY boolean
  ) is
--
CURSOR c_pip_bg_check is
  select distinct(pet.business_group_id) bg
  from   hxt_prem_interact_rules         itr
  ,      pay_element_types_f             pet
  where  itr.pip_id            = p_pip_id
  and    itr.elt_prior_prem_id = pet.element_type_id
  union
  select distinct(pet.business_group_id) bg
  from   hxt_prem_interact_rules         itr
  ,      pay_element_types_f             pet
  where  itr.pip_id             = p_pip_id
  and    itr.elt_earned_prem_id = pet.element_type_id
  union
  select distinct(pet.business_group_id) bg
  from   hxt_prem_interact_pol_rules     ipr
  ,      pay_element_types_f             pet
  where  ipr.pip_id             = p_pip_id
  and    ipr.elt_earned_prem_id = pet.element_type_id;
--
  l_bg     number   := -1;
  l_valid  boolean  := True;
  l_count  number   := 0;
--
Begin
  for pipbg in c_pip_bg_check loop
    l_count := l_count +1;
    if l_count > 1 then
      hxt_bg_message_insert('V','Premium Interaction Policy '||p_pip_name||' Is Invalid');
      l_valid := False;
      l_bg    := -1;
    else
      l_bg := pipbg.bg;
    end if;
  end loop;
--
p_valid	 := l_valid;
p_pip_bg := l_bg;
--
End chk_prem_inter_pols;
--
-- Holiday Calendars Validation Procedure.
--
Procedure chk_holiday_cals
  (p_hcl_id   IN     number
  ,p_hcl_name IN     varchar2
  ,p_hcl_bg      OUT NOCOPY number
  ,p_valid       OUT NOCOPY boolean
  ) is
--
CURSOR c_hcl_bg_check is
  select distinct(pet.business_group_id) bg
  from   hxt_holiday_calendars           hcl
  ,      pay_element_types_f             pet
  where  hcl.id                = p_hcl_id
  and    hcl.element_type_id   = pet.element_type_id
  and    pet.business_group_id is not null
  union
  select distinct(hou.business_group_id) bg
  from   hxt_holiday_calendars           hcl
  ,      hr_organization_units           hou
  where  hcl.id                = p_hcl_id
  and    hcl.organization_id   = hou.organization_id
  and    hou.business_group_id is not null;
--
  l_count  number  := 0;
  l_valid  boolean := True;
  l_bg     number  := -1;
--
Begin
  for holcal in c_hcl_bg_check loop
    l_count := l_count +1;
    if l_count > 1 then
      hxt_bg_message_insert('V','Holiday Calendar '||p_hcl_name||' Is Invalid');
      l_valid := False;
      l_bg := -1;
    else
      l_bg := holcal.bg;
    end if;
  end loop;
--
p_valid	 := l_valid;
p_hcl_bg := l_bg;
--
End chk_holiday_cals;
--
-- Earning Rules Validation Procedure.
--
Procedure chk_earn_rules
  (p_epr_id   IN     number
  ,p_epr_name IN     varchar2
  ,p_epr_bg      OUT NOCOPY number
  ,p_valid       OUT NOCOPY boolean
  ) is
--
CURSOR c_eprules_bg_check is
  select distinct(pet.business_group_id) bg
  from   hxt_earning_rules               her
  ,      pay_element_types_f             pet
  where  her.egp_id            = p_epr_id
  and    her.element_type_id   = pet.element_type_id
  and    pet.business_group_id is not null;
--
  l_count  number  := 0;
  l_valid  boolean := True;
  l_bg     number  := -1;
--
Begin
  for eprules in c_eprules_bg_check loop
    l_count := l_count +1;
    if l_count > 1 then
      hxt_bg_message_insert('V','Earning Policy '||p_epr_name||' Has Invalid Rules');
      l_valid := False;
      l_bg := -1;
    else
      l_bg := eprules.bg;
    end if;
  end loop;
--
p_valid	 := l_valid;
p_epr_bg := l_bg;
--
End chk_earn_rules;
--
-- Earnings Policy Validation Procedure.
--
Procedure chk_earn_pols
  (p_egp_id   IN     number
  ,p_egp_name IN     varchar2
  ,p_hcl_id   IN     number
  ,p_pip_id   IN     number
  ,p_pep_id   IN     number
  ,p_egt_id   IN     number
  ,p_in_bg    IN     number
  ,p_egp_bg      OUT NOCOPY number
  ,p_valid       OUT NOCOPY boolean
  ) is
--
  l_valid     boolean  := True;
  l_ret_valid boolean  := True;
  l_hcl_bg    number   := -1;
  l_pip_bg    number   := -1;
  l_pep_bg    number   := -1;
  l_egt_bg    number   := -1;
  l_epr_bg    number   := -1;
  l_bg        number   := -1;
--
Begin
--
  l_bg  := p_in_bg;
--
  chk_earn_rules(p_egp_id, g_token, l_epr_bg, l_valid);
  if not l_valid then
    l_ret_valid := False;
  elsif l_bg = -1 and l_epr_bg <> -1 then
    l_bg := l_epr_bg;
  elsif l_bg <> -1 and l_epr_bg <> -1 and l_bg <> l_epr_bg then
    l_ret_valid := False;
    hxt_bg_message_insert('V','Earnings Policy '||p_egp_name||' References Conflicting Business Groups. Ref: EPR');
  end if;
--
  chk_holiday_cals(p_hcl_id, g_token, l_hcl_bg, l_valid);
  if not l_valid then
    l_ret_valid := False;
  elsif l_bg = -1 and l_hcl_bg <> -1 then
    l_bg := l_hcl_bg;
  elsif l_bg <> -1 and l_hcl_bg <> -1 and l_bg <> l_hcl_bg then
    l_ret_valid := False;
    hxt_bg_message_insert('V','Earnings Policy '||p_egp_name||' References Conflicting Business Groups. Ref: HCL');
  end if;
--
  if p_pip_id is not null then
    chk_prem_inter_pols(p_pip_id, g_token, l_pip_bg, l_valid);
    if not l_valid then
      l_ret_valid := False;
    elsif l_bg = -1 and l_pip_bg <> -1 then
      l_bg := l_pip_bg;
    elsif l_bg <> -1 and l_pip_bg <> -1 and l_bg <> l_pip_bg then
      l_ret_valid := False;
      hxt_bg_message_insert('V','Earnings Policy '||p_egp_name||' References Conflicting Business Groups. Ref: PIP');
    end if;
  end if;
--
  if p_pep_id is not null then
    chk_prem_elig_pols(p_pep_id, g_token, l_pep_bg, l_valid);
    if not l_valid then
      l_ret_valid := False;
    elsif l_bg = -1 and l_pep_bg <> -1 then
      l_bg := l_pep_bg;
    elsif l_bg <> -1 and l_pep_bg <> -1 and l_bg <> l_pep_bg then
      l_ret_valid := False;
      hxt_bg_message_insert('V','Earnings Policy '||p_egp_name||' References Conflicting Business Groups. Ref: PEP');
    end if;
  end if;
--
  if p_egt_id is not null then
    chk_earn_groups(p_egt_id, g_token, l_egt_bg, l_valid);
    if not l_valid then
      l_ret_valid := False;
    elsif l_bg = -1 and l_egt_bg <> -1 then
      l_bg := l_egt_bg;
    elsif l_bg <> -1 and l_egt_bg <> -1 and l_bg <> l_egt_bg then
      l_ret_valid := False;
      hxt_bg_message_insert('V','Earnings Policy '||p_egp_name||' References Conflicting Business Groups. Ref: EGT');
    end if;
  end if;
--
  if l_ret_valid = False then
    hxt_bg_message_insert('V','Earnings Policy '||p_egp_name||' Has Invalid References');
  end if;
--
p_valid	 := l_ret_valid;
p_egp_bg := l_bg;
--
End chk_earn_pols;
--
-- Shift Differential Policies Validation Procedure.
--
Procedure chk_shift_diffs
  (p_sdp_id   IN     number
  ,p_sdp_name IN     varchar2
  ,p_sdp_bg      OUT NOCOPY number
  ,p_valid       OUT NOCOPY boolean
  ) is
--
CURSOR c_sdp_bg_check is
  select distinct(pet.business_group_id) bg
  from   hxt_shift_diff_rules            sdr
  ,      pay_element_types_f             pet
  where  sdr.sdp_id            = p_sdp_id
  and    sdr.element_type_id   = pet.element_type_id
  and    pet.business_group_id is not null;
--
  l_bg    number  := -1;
  l_valid boolean := True;
  l_count number  := 0;
--
Begin
  for diffs in c_sdp_bg_check loop
    l_count := l_count +1;
    if l_count > 1 then
      hxt_bg_message_insert('V','Shift Differential Policy '||p_sdp_name||' Is Invalid');
      l_valid := False;
      l_bg    := -1;
    else
      l_bg := diffs.bg;
    end if;
  end loop;
--
p_valid	 := l_valid;
p_sdp_bg := l_bg;
--
End chk_shift_diffs;
--
-- Additional Assignment Info Validation Procedure.
--
Procedure chk_add_assign_info
  (p_aai_id   IN     number
  ,p_ass_id   IN     number
  ,p_rp_id    IN     number
  ,p_ep_id    IN     number
  ,p_ep_hcl   IN     number
  ,p_ep_pip   IN     number
  ,p_ep_pep   IN     number
  ,p_ep_egt   IN     number
  ,p_ep_bg    IN     number
  ,p_sdp_id   IN     number
  ,p_ass_bg   IN     number
  ,p_hdp_bg   IN     number
  ,p_valid       OUT NOCOPY boolean
  ) is
--
  l_valid     boolean  := True;
  l_ret_valid boolean  := True;
  l_rp_bg     number   := -1;
  l_ep_bg     number   := -1;
  l_sdp_bg    number   := -1;
  l_hdp_bg    number   := -1;
  l_ass_bg    number   := -1;
  l_bg        number   := -1;
--
Begin
  l_ass_bg := p_ass_bg;
  l_hdp_bg := p_hdp_bg;
  l_bg     := l_ass_bg;
--
  if l_hdp_bg <> -1 and l_hdp_bg <> l_bg then
    l_ret_valid := False;
    hxt_bg_message_insert('V','Assisgnment ID '||p_ass_id||' References Conflicting Business Groups. Ref: HDP');
  end if;
--
  if p_rp_id is not null then
    chk_rotplans(p_rp_id, g_token, l_rp_bg, l_valid);
    if not l_valid then
      l_ret_valid := False;
    elsif l_rp_bg <> -1 and l_rp_bg <> l_bg then
      l_ret_valid := False;
      hxt_bg_message_insert('V','Assisgnment ID '||p_ass_id||' References Conflicting Business Groups. Ref: RP');
    end if;
  end if;
--
  if p_sdp_id is not null then
    chk_shift_diffs(p_sdp_id, g_token, l_sdp_bg, l_valid);
    if not l_valid then
      l_ret_valid := False;
    elsif l_sdp_bg <> -1 and l_bg <> l_sdp_bg then
      l_ret_valid := False;
      hxt_bg_message_insert('V','Assisgnment ID '||p_ass_id||' References Conflicting Business Groups. Ref: SDP');
    end if;
  end if;
--
  chk_earn_pols(p_ep_id, g_token, p_ep_hcl, p_ep_pip, p_ep_pep, p_ep_egt, p_ep_bg, l_ep_bg, l_valid);
  if not l_valid then
    l_ret_valid := False;
  elsif l_ep_bg <> -1 and l_bg <> l_ep_bg then
    l_ret_valid := False;
    hxt_bg_message_insert('V','Assisgnment ID '||p_ass_id||' References Conflicting Business Groups. Ref: EP');
  end if;
--
  if l_ret_valid = False then
    hxt_bg_message_insert('V','Assignment ID '||p_ass_id||' Has Invalid References');
  end if;
--
p_valid	 := l_ret_valid;
--
End chk_add_assign_info;
--
-- Sum Hours Worked Validation Procedure.
--
Procedure chk_sum_hours
  (p_tim_id   IN     number
  ,p_period   IN     varchar2
  ,p_sum_bg      OUT NOCOPY number
  ,p_valid       OUT NOCOPY boolean
  ) is
--
CURSOR c_shw_bg_check is
  select distinct(pet.business_group_id) bg
  from   hxt_sum_hours_worked_f          shw
  ,      pay_element_types_f             pet
  where  shw.tim_id            = p_tim_id
  and    shw.element_type_id   = pet.element_type_id
  and    pet.business_group_id is not null
  union
  select distinct(ass.business_group_id) bg
  from   hxt_sum_hours_worked_f          shw
  ,      per_assignments_f               ass
  where  shw.tim_id        = p_tim_id
  and    shw.assignment_id = ass.assignment_id;
--
  l_count  number  := 0;
  l_valid  boolean := True;
  l_bg     number  := -1;
--
Begin
  for sumhrs in c_shw_bg_check loop
    l_count := l_count +1;
    if l_count > 1 then
      hxt_bg_message_insert('V','Timecard ID '||p_tim_id||' Has Invalid Summary Hours References');
      l_valid := False;
      l_bg := -1;
    else
      l_bg := sumhrs.bg;
    end if;
  end loop;
--
p_valid	 := l_valid;
p_sum_bg := l_bg;
--
End chk_sum_hours;
--
-- Det Hours Worked Validation Procedure.
--
Procedure chk_det_hours
  (p_tim_id   IN     number
  ,p_period   IN     varchar2
  ,p_det_bg      OUT NOCOPY number
  ,p_valid       OUT NOCOPY boolean
  ) is
--
CURSOR c_dhw_bg_check is
  select distinct(pet.business_group_id) bg
  from   hxt_det_hours_worked_f   dhw
  ,      pay_element_types_f      pet
  where  dhw.tim_id            = p_tim_id
  and    dhw.element_type_id   = pet.element_type_id
  and    pet.business_group_id is not null
  union
  select distinct(ass.business_group_id) bg
  from   hxt_det_hours_worked_f   dhw
  ,      per_assignments_f        ass
  where  dhw.tim_id         = p_tim_id
  and    dhw.assignment_id  = ass.assignment_id;
--
  l_count  number  := 0;
  l_valid  boolean := True;
  l_bg     number  := -1;
--
Begin
  for dethrs in c_dhw_bg_check loop
    l_count := l_count +1;
    if l_count > 1 then
      hxt_bg_message_insert('V','Timecard ID '||p_tim_id||' Has Invalid Det Hours References');
      l_valid := False;
      l_bg := -1;
    else
      l_bg := dethrs.bg;
    end if;
  end loop;
--
p_valid	 := l_valid;
p_det_bg := l_bg;
--
End chk_det_hours;
--
-- Timecards Validation Procedure.
--
Procedure chk_timecards
  (p_tim_id   IN     number
  ,p_period   IN     varchar2
  ,p_per_bg  IN     number
  ,p_batch_bg IN     number
  ,p_pay_bg   IN     number
  ,p_valid       OUT NOCOPY boolean
  ) is
--
  l_valid     boolean := True;
  l_ret_valid boolean := True;
  l_per_bg    number  := -1;
  l_batch_bg  number  := -1;
  l_pay_bg    number  := -1;
  l_sum_bg    number  := -1;
  l_det_bg    number  := -1;
  l_bg        number  := -1;
--
Begin
  l_per_bg   := p_per_bg;
  l_batch_bg := p_batch_bg;
  l_pay_bg   := p_pay_bg;
  l_bg       := l_per_bg;
--
  if l_batch_bg <> -1 and l_batch_bg <> l_bg then
    l_ret_valid := False;
    hxt_bg_message_insert('V','Timecard ID '||p_tim_id||' For Period '||p_period||' Pay Batch Is Invalid');
  end if;
--
  if l_pay_bg <> -1 and l_pay_bg <> l_bg then
    l_ret_valid := False;
    hxt_bg_message_insert('V','Timecard ID '||p_tim_id||' For Period '||p_period||' Payroll Is Invalid');
  end if;
--
  chk_sum_hours(p_tim_id, p_period, l_sum_bg, l_valid);
  if not l_valid then
    l_ret_valid := False;
  elsif l_sum_bg <> -1 and l_sum_bg <> l_bg then
    l_ret_valid := False;
    hxt_bg_message_insert('V','Timecard ID '||p_tim_id||' For Period '||p_period||' Summary Information References Invalid Business Group');
  end if;
--
  chk_det_hours(p_tim_id, p_period, l_det_bg, l_valid);
  if not l_valid then
    l_ret_valid := False;
  elsif l_det_bg <> -1 and l_det_bg <> l_bg then
    l_ret_valid := False;
    hxt_bg_message_insert('V','Timecard ID '||p_tim_id||' For Period '||p_period||' Detail Information References Invalid Business Group');
  end if;
--
  if l_ret_valid = False then
    hxt_bg_message_insert('V','Timecard ID '||p_tim_id||' For Period '||p_period||' Has Invalid References.');
  end if;
--
p_valid	 := l_ret_valid;
--
End chk_timecards;
--
-- Begin main function processing
--
Begin
--
--
  --
  -- Check workplans.
  --
  for wkplans in c_get_workplans loop
    chk_workplans(wkplans.id, wkplans.name, g_sub_bg, g_sub_valid);
    if g_sub_valid = False then
      g_valid := False;
    end if;
  end loop;
  --
  -- Check rotation plans.
  --
  for rotplans in c_get_rotation_plans loop
    chk_rotplans(rotplans.id, rotplans.name, g_sub_bg, g_sub_valid);
    if g_sub_valid = False then
      g_valid := False;
    end if;
  end loop;
  --
  -- Check earning groups.
  --
  for earngrps in c_get_earn_groups loop
    chk_earn_groups(earngrps.id, earngrps.name, g_sub_bg, g_sub_valid);
    if g_sub_valid = False then
      g_valid := False;
    end if;
  end loop;
  --
  -- Check premium eligibility policies.
  --
  for peps in c_get_peps loop
    chk_prem_elig_pols(peps.id, peps.name, g_sub_bg, g_sub_valid);
    if g_sub_valid = False then
      g_valid := False;
    end if;
  end loop;
  --
  -- Check premium interaction policies.
  --
  for pips in c_get_pips loop
    chk_prem_inter_pols(pips.id, pips.name, g_sub_bg, g_sub_valid);
    if g_sub_valid = False then
      g_valid := False;
    end if;
  end loop;
  --
  -- Check holiday calendars.
  --
  for hols in c_get_hol_cals loop
    chk_holiday_cals(hols.id, hols.name, g_sub_bg, g_sub_valid);
    if g_sub_valid = False then
      g_valid := False;
    end if;
  end loop;
  --
  -- Check earning policies.
  --
  for epols in c_get_earn_pols loop
    g_token := 'For Earnings Policy '||epols.name;
    chk_earn_pols(epols.id, epols.name, epols.hcl_id, epols.pip_id, epols.pep_id, epols.egt_id, epols.bg_id, g_sub_bg, g_sub_valid);
    if g_sub_valid = False then
      g_valid := False;
    end if;
  end loop;
  --
  -- Check shift differential policies.
  --
  for sdiffs in c_get_shift_diffs loop
    chk_shift_diffs(sdiffs.id, sdiffs.name, g_sub_bg, g_sub_valid);
    if g_sub_valid = False then
      g_valid := False;
    end if;
  end loop;
  --
  -- Check additional assignment information.
  --
  for addass in c_get_add_ass_info loop
    g_token := 'For Assignment ID '||addass.ass_id;
    chk_add_assign_info(addass.id, addass.ass_id, addass.rp_id, addass.ep_id, addass.ep_hcl, addass.ep_pip, addass.ep_pep,
                        addass.ep_egt, addass.ep_bg, addass.sdp_id, addass.ass_bg, addass.hdp_bg, g_sub_valid);
    if g_sub_valid = False then
      g_valid := False;
    end if;
  end loop;
  --
  -- Check timecards.
  --
  for times in c_get_timecards loop
    chk_timecards(times.id, times.period, times.per_bg, times.batch_bg, times.pay_bg, g_sub_valid);
    if g_sub_valid = False then
      g_valid := False;
    end if;
  end loop;
--
--
-- Return Validation Status
--
return(g_valid);
--
End;
-------------------------------------------------------------------------------
PROCEDURE hxt_bg_workplans_update IS
--
g_rp_bg      number   := 0;
g_ass_bg     number   := 0;
g_rp_counter number   := 0;
--
CURSOR c_bg_workplans IS
  select distinct
         wsh.tws_id                 id
  ,      pet.business_group_id      bg
  from   hxt_weekly_work_schedules  wws
  ,      hxt_work_shifts            wsh
  ,      pay_element_types_f        pet
  where  wws.business_group_id    is null
  and    wws.id                   = wsh.tws_id
  and    ((wsh.off_shift_prem_id  = pet.element_type_id
  and    pet.business_group_id    is not null)
  or     (wsh.shift_diff_ovrrd_id = pet.element_type_id
  and    pet.business_group_id    is not null));
--
CURSOR c_global_workplans is
  select distinct
         wws.id                     wp_id
  ,      rp_sub.rp_count            rp_cnt
  ,      ass_sub.ass_count          ass_cnt
  from   hxt_weekly_work_schedules         wws
  ,      (select tws_id             wp_id
         ,       count(rtp_id)      rp_count
         from    hxt_rotation_schedules
         group by tws_id)                  rp_sub
  ,      (select rts.tws_id         wp_id
         ,       count(distinct(ass.business_group_id)) ass_count
         from    per_assignments_f         ass
         ,       hxt_add_assign_info_f     aai
         ,       hxt_rotation_plans        rtp
         ,       hxt_rotation_schedules    rts
         where   ass.assignment_id = aai.assignment_id
         and     aai.rotation_plan = rtp.id
         and     rtp.id            = rts.rtp_id
         group by rts.tws_id)              ass_sub
  where  wws.business_group_id is null
  and    wws.id                = ass_sub.wp_id (+)
  and    wws.id                = rp_sub.wp_id (+)
  and    not exists(select 'X'
                    from   hxt_work_shifts      wsh
                    ,      pay_element_types_f  pet
                    where  wws.id                   = wsh.tws_id
                    and    ((wsh.off_shift_prem_id  = pet.element_type_id
                    and    pet.business_group_id    is not null)
                    or     (wsh.shift_diff_ovrrd_id = pet.element_type_id
                    and    pet.business_group_id    is not null)));
--
CURSOR c_get_rp_bg(p_wp_id number) is
  select distinct(pet.business_group_id) rp_bg
  from    hxt_rotation_schedules         rts
  ,       hxt_weekly_work_schedules      wws
  ,       hxt_work_shifts                wsh
  ,       pay_element_types_f            pet
  where   rts.tws_id               = wws.id
  and     wws.id                   = wsh.tws_id
  and     ((wsh.off_shift_prem_id  = pet.element_type_id
  and     pet.business_group_id is not null)
  or      (wsh.shift_diff_ovrrd_id = pet.element_type_id
  and     pet.business_group_id    is not null))
  and     rts.rtp_id               IN (select sub.rtp_id
                                       from   hxt_rotation_schedules sub
                                       where  sub.tws_id = p_wp_id)
  union
  select distinct(wws.business_group_id) rp_bg
  from    hxt_rotation_schedules         rts
  ,       hxt_weekly_work_schedules      wws
  where   rts.tws_id               = wws.id
  and     wws.business_group_id    is not null
  and     rts.rtp_id               IN (select sub.rtp_id
                                       from   hxt_rotation_schedules sub
                                       where  sub.tws_id = p_wp_id);
--
CURSOR c_get_ass_bg(p_wp_id number) is
  select distinct(ass.business_group_id) ass_bg
  from    per_assignments_f              ass
  ,       hxt_add_assign_info_f          aai
  ,       hxt_rotation_plans             rtp
  ,       hxt_rotation_schedules         rts
  where   ass.assignment_id  = aai.assignment_id
  and     aai.rotation_plan  = rtp.id
  and     rtp.id             = rts.rtp_id
  and     rts.tws_id         = p_wp_id;
--
-- Workplan Update Procedure.
--
Procedure update_workplans
  (p_wp_id  IN  number
  ,p_bg_id  IN  number
  ) is
--
l_wp_id number;
l_bg_id number;
--
Begin
  l_wp_id := p_wp_id;
  l_bg_id := p_bg_id;
--
  UPDATE hxt_weekly_work_schedules
  SET    business_group_id = l_bg_id
  WHERE  id = l_wp_id;
--
hxt_bg_message_insert('U','Updating Workplan ID '||l_wp_id||' With Business Group '||l_bg_id);
--
End update_workplans;
--
--  Rotation Plan References Update Procedure.
--
Procedure update_rp_refs
  (p_bg     IN  number
  ,p_old_id IN  number
  ,p_new_id IN  number
  ) is
--
l_new_id   number;
l_aai_id   number;
l_ass_id   number;
l_aai_esd  date;
l_aai_eed  date;
--
CURSOR c_get_ass_info is
  select  aai.id                    id
  ,       aai.assignment_id         ass_id
  ,       aai.effective_start_date  esd
  ,       aai.effective_end_date    eed
  from    hxt_add_assign_info_f  aai
  ,       per_assignments_f      ass
  where   ass.business_group_id = p_bg
  and     ass.assignment_id     = aai.assignment_id
  and     aai.rotation_plan     = p_old_id;
--
Begin
  l_new_id := p_new_id;
--
  For assign in c_get_ass_info loop
--
  l_aai_id   := assign.id;
  l_ass_id   := assign.ass_id;
  l_aai_esd  := assign.esd;
  l_aai_eed  := assign.eed;
--
  update hxt_add_assign_info_f
  set    rotation_plan = l_new_id
  where  id                   = l_aai_id
  and    effective_start_date = l_aai_esd
  and    effective_end_date   = l_aai_eed;
--
hxt_bg_message_insert('U','Updating Assignment ID '||l_ass_id||' To Reference Rotation Plan ID '||l_new_id);
--
  end loop;
--
End update_rp_refs;
--
--  Workplan Duplication Procedure.
--
Procedure duplicate_workplans (p_wp_id IN number) is
--
l_id  number;
--
CURSOR c_all_bg is
  select distinct
         pbg.business_group_id          id
  ,      to_char(pbg.business_group_id) name
  from   per_business_groups   pbg;
--
CURSOR c_seqno is
  select hxt_seqno.nextval
  from   dual;
--
CURSOR c_workplan_rec is
  select name
  ,      start_day
  ,      date_from
  ,      description
  ,      date_to
  from   hxt_weekly_work_schedules
  where  id = p_wp_id;
--
CURSOR c_workshift_rec is
  select sht_id
  ,      week_day
  ,      seq_no
  ,      early_start
  ,      late_stop
  ,      off_shift_prem_id
  ,      shift_diff_ovrrd_id
  from   hxt_work_shifts
  where  tws_id = p_wp_id;
--
Begin
--
hxt_bg_message_insert('U','Duplicating Workplan ID '||p_wp_id||' Across All Business Groups');
--
  For busg in c_all_bg loop
--
    For r_workplan_rec in c_workplan_rec loop
--
      l_id := 0;
--
      open   c_seqno;
      fetch  c_seqno into l_id;
      close  c_seqno;
--
      Insert Into hxt_weekly_work_schedules
      (  id
      ,  name
      ,  start_day
      ,  date_from
      ,  description
      ,  date_to
      ,  created_by
      ,  creation_date
      ,  last_updated_by
      ,  last_update_date
      ,  last_update_login
      ,  business_group_id
      )
      Values
      (  l_id
      ,  r_workplan_rec.name||'-'||busg.name
      ,  r_workplan_rec.start_day
      ,  r_workplan_rec.date_from
      ,  r_workplan_rec.description
      ,  r_workplan_rec.date_to
      ,  -1
      ,  sysdate
      ,  -1
      ,  sysdate
      ,  -1
      ,  busg.id
      );
--
      For shifts in c_workshift_rec loop
        Insert into hxt_work_shifts
        (  sht_id
        ,  tws_id
        ,  week_day
        ,  seq_no
        ,  early_start
        ,  late_stop
        ,  created_by
        ,  creation_date
        ,  last_updated_by
        ,  last_update_date
        ,  last_update_login
        ,  off_shift_prem_id
        ,  shift_diff_ovrrd_id
        )
        Values
        (  shifts.sht_id
        ,  l_id
        ,  shifts.week_day
        ,  shifts.seq_no
        ,  shifts.early_start
        ,  shifts.late_stop
        ,  -1
        ,  sysdate
        ,  -1
        ,  sysdate
        ,  -1
        ,  shifts.off_shift_prem_id
        ,  shifts.shift_diff_ovrrd_id
        );
      end loop;
--
    end loop;
--
  end loop;
--
  delete from hxt_work_shifts
  where tws_id = p_wp_id;
--
  delete from hxt_weekly_work_schedules
  where id = p_wp_id;
--
End duplicate_workplans;
--
--  Rotation Plan Duplication Procedure.
--
Procedure duplicate_rotation_plans
  (p_wp_id  IN  number
  ,p_refs   IN  varchar2
  ) is
--
l_wp_id       number;
l_rp_id       number;
l_rp_counter  number  := 0;
--
TYPE t_delete_recs is table of NUMBER INDEX BY BINARY_INTEGER;
--
l_delete_wp t_delete_recs;
l_delete_rp t_delete_recs;
--
CURSOR c_all_bg is
  select distinct
         pbg.business_group_id          id
  ,      to_char(pbg.business_group_id) name
  from   per_business_groups   pbg;
--
CURSOR c_seqno is
  select hxt_seqno.nextval
  from   dual;
--
CURSOR c_workplan_rec(p_rp_id number) is
  select distinct
         wws.id
  ,      wws.name
  ,      wws.start_day
  ,      wws.date_from
  ,      wws.description
  ,      wws.date_to
  from   hxt_weekly_work_schedules  wws
  ,      hxt_rotation_schedules     rts
  where  wws.id     = rts.tws_id
  and    rts.rtp_id = p_rp_id;
--
CURSOR c_workshift_rec(p_wp_id number) is
  select distinct
         sht_id
  ,      week_day
  ,      seq_no
  ,      early_start
  ,      late_stop
  ,      off_shift_prem_id
  ,      shift_diff_ovrrd_id
  from   hxt_work_shifts
  where  tws_id = p_wp_id;
--
CURSOR c_rotplan_rec is
  select distinct
         rtp.id
  ,      rtp.name
  ,      rtp.date_from
  ,      rtp.description
  ,      rtp.date_to
  from   hxt_rotation_plans     rtp
  ,      hxt_rotation_schedules rts
  where  rtp.id     = rts.rtp_id
  and    rts.tws_id = p_wp_id;
--
CURSOR c_rotschedule_rec(p_wp_id number, p_rp_id number) is
  select start_date
  from   hxt_rotation_schedules
  where  tws_id = p_wp_id
  and    rtp_id = p_rp_id;
--
CURSOR c_dup_check(p_bg_id number, p_name varchar2) is
  select id
  from   hxt_weekly_work_schedules
  where  business_group_id = p_bg_id
  and    name              = p_name;
--
Begin
--
hxt_bg_message_insert('U','Duplicating Rotation Plans For Workplan ID '||p_wp_id||' Across All Business Groups');
--
  For busg in c_all_bg loop
--
    For rotplans in c_rotplan_rec loop
--
      l_rp_id := 0;
--
      open   c_seqno;
      fetch  c_seqno into l_rp_id;
      close  c_seqno;
--
      Insert into hxt_rotation_plans
      (  id
      ,  name
      ,  date_from
      ,  description
      ,  date_to
      ,  created_by
      ,  creation_date
      ,  last_updated_by
      ,  last_update_date
      ,  last_update_login
      )
      Values
      (  l_rp_id
      ,  rotplans.name||'-'||busg.name
      ,  rotplans.date_from
      ,  rotplans.description
      ,  rotplans.date_to
      ,  -1
      ,  sysdate
      ,  -1
      ,  sysdate
      ,  -1
      );
--
      For r_workplan_rec in c_workplan_rec(rotplans.id) loop
--
        open   c_dup_check(busg.id, r_workplan_rec.name||'-'||busg.name);
        fetch  c_dup_check into l_wp_id;
        if c_dup_check%notfound then
        close c_dup_check;

        open   c_seqno;
        fetch  c_seqno into l_wp_id;
        close  c_seqno;
--
        Insert Into hxt_weekly_work_schedules
        (  id
        ,  name
        ,  start_day
        ,  date_from
        ,  description
        ,  date_to
        ,  created_by
        ,  creation_date
        ,  last_updated_by
        ,  last_update_date
        ,  last_update_login
        ,  business_group_id
        )
        Values
        (  l_wp_id
        ,  r_workplan_rec.name||'-'||busg.name
        ,  r_workplan_rec.start_day
        ,  r_workplan_rec.date_from
        ,  r_workplan_rec.description
        ,  r_workplan_rec.date_to
        ,  -1
        ,  sysdate
        ,  -1
        ,  sysdate
        ,  -1
        ,  busg.id
        );
--
        For shifts in c_workshift_rec(r_workplan_rec.id) loop
          Insert into hxt_work_shifts
          (  sht_id
          ,  tws_id
          ,  week_day
          ,  seq_no
          ,  early_start
          ,  late_stop
          ,  created_by
          ,  creation_date
          ,  last_updated_by
          ,  last_update_date
          ,  last_update_login
          ,  off_shift_prem_id
          ,  shift_diff_ovrrd_id
          )
          Values
          (  shifts.sht_id
          ,  l_wp_id
          ,  shifts.week_day
          ,  shifts.seq_no
          ,  shifts.early_start
          ,  shifts.late_stop
          ,  -1
          ,  sysdate
          ,  -1
          ,  sysdate
          ,  -1
          ,  shifts.off_shift_prem_id
          ,  shifts.shift_diff_ovrrd_id
          );
        end loop;
--
      else close c_dup_check;
      end if;
--
      For rotsched in c_rotschedule_rec(r_workplan_rec.id, rotplans.id) loop
        Insert into hxt_rotation_schedules
        (  rtp_id
        ,  tws_id
        ,  start_date
        ,  created_by
        ,  creation_date
        ,  last_updated_by
        ,  last_update_date
        ,  last_update_login
        )
        Values
        (  l_rp_id
        ,  l_wp_id
        ,  rotsched.start_date
        ,  -1
        ,  sysdate
        ,  -1
        ,  sysdate
        ,  -1
        );
      end loop;
--
      end loop;
--
      if p_refs = 'Y' then
        update_rp_refs(busg.id, rotplans.id, l_rp_id);
      end if;
--
    end loop;
--
  end loop;
--
  For delete_rp in c_rotplan_rec loop
    l_rp_counter := l_rp_counter+1;
    l_delete_rp(l_rp_counter) := delete_rp.id;
  end loop;
--
  For i in 1..l_rp_counter loop
    delete from hxt_rotation_schedules
    where rtp_id = l_delete_rp(i);
  end loop;
--
  For i in 1..l_rp_counter loop
    delete from hxt_rotation_plans
    where id = l_delete_rp(i);
  end loop;
--
  delete from hxt_work_shifts
  where tws_id = p_wp_id;
--
  delete from hxt_weekly_work_schedules
  where id = p_wp_id;
--
End duplicate_rotation_plans;
--
--  Begin Main Processing.
--
Begin
--
--
  For wpbg in c_bg_workplans loop
    update_workplans(wpbg.id, wpbg.bg);
  end loop;
  --
  For global in c_global_workplans loop
  --
    g_rp_bg      := 0;
    g_ass_bg     := 0;
    g_rp_counter := 0;
  --
    if global.rp_cnt is null then
    --
      duplicate_workplans(global.wp_id);
    --
    elsif global.rp_cnt = 1 and global.ass_cnt is null then
    --
      open c_get_rp_bg(global.wp_id);
      fetch c_get_rp_bg into g_rp_bg;
        if c_get_rp_bg%notfound then
          duplicate_rotation_plans(global.wp_id,'N');
        else
          update_workplans(global.wp_id, g_rp_bg);
        end if;
      close c_get_rp_bg;
    --
    elsif global.rp_cnt = 1 and global.ass_cnt = 1 then
    --
      open c_get_ass_bg(global.wp_id);
      fetch c_get_ass_bg into g_ass_bg;
        update_workplans(global.wp_id, g_ass_bg);
      close c_get_ass_bg;
    --
    elsif global.rp_cnt = 1 and global.ass_cnt > 1 then
    --
      duplicate_rotation_plans(global.wp_id,'Y');
    --
    elsif global.rp_cnt > 1 and global.ass_cnt is null then
    --
      for rotplans in c_get_rp_bg(global.wp_id) loop
        g_rp_counter := g_rp_counter +1;
        g_rp_bg      := rotplans.rp_bg;
      end loop;
        if g_rp_counter = 0 then
          duplicate_rotation_plans(global.wp_id,'N');
        elsif g_rp_counter = 1 then
          update_workplans(global.wp_id, g_rp_bg);
        else
          duplicate_rotation_plans(global.wp_id,'N');
        end if;
    --
    elsif global.rp_cnt > 1 and global.ass_cnt = 1 then
    --
      for rotplans in c_get_rp_bg(global.wp_id) loop
        g_rp_counter := g_rp_counter +1;
        g_rp_bg      := rotplans.rp_bg;
      end loop;
      open c_get_ass_bg(global.wp_id);
      fetch c_get_ass_bg into g_ass_bg;
      close c_get_ass_bg;
        if g_rp_counter = 0 then
          update_workplans(global.wp_id, g_ass_bg);
        elsif g_rp_counter = 1 and g_rp_bg = g_ass_bg then
          update_workplans(global.wp_id, g_ass_bg);
        else
          duplicate_rotation_plans(global.wp_id,'Y');
        end if;
    --
    elsif global.rp_cnt > 1 and global.ass_cnt > 1 then
    --
      duplicate_rotation_plans(global.wp_id,'Y');
    --
    end if;
    --
  end loop;
  --
--
End;
-------------------------------------------------------------------------------
PROCEDURE hxt_bg_earnings_update IS
--
g_ass_bg     number;
g_nonass_bg  number;
--
CURSOR c_get_ass_epols is
  select distinct
         hep.id                                 ep_id
  ,      count(distinct(ass.business_group_id)) count_bg
  from   hxt_earning_policies    hep
  ,      hxt_add_assign_info_f   aai
  ,      per_assignments_f       ass
  where  hep.id                = aai.earning_policy
  and    aai.assignment_id     = ass.assignment_id
  and    hep.business_group_id is null
  group by hep.id;
--
CURSOR c_get_nonass_epols is
  select hep.id                ep_id
  ,      hep.hcl_id            hcl_id
  ,      hep.pip_id            pip_id
  ,      hep.pep_id            pep_id
  ,      hep.egt_id            egt_id
  from   hxt_earning_policies  hep
  where  hep.business_group_id is null
  and    not exists(select 'X'
                    from   hxt_add_assign_info_f   aai
                    where  aai.earning_policy = hep.id);
--
CURSOR c_get_ass_bg(p_id number) is
  select distinct
         ass.business_group_id  bg_id
  from   hxt_add_assign_info_f  aai
  ,      per_assignments_f      ass
  where  aai.assignment_id  = ass.assignment_id
  and    aai.earning_policy = p_id;
--
CURSOR c_get_egt_bg(p_id number) is
  select distinct
         pet.business_group_id bg_id
  from 	 hxt_earn_groups       egr
  ,      hxt_earn_group_types  egt
  , 	 pay_element_types_f   pet
  where  egt.id                = p_id
  and    egt.id                = egr.egt_id
  and    egr.element_type_id   = pet.element_type_id
  and    pet.business_group_id is not null;
--
CURSOR c_get_pep_bg(p_id number) is
  select distinct
         pet.business_group_id       bg_id
  from   hxt_prem_eligblty_policies  pep
  ,      hxt_prem_eligblty_pol_rules epr
  , 	 pay_element_types_f         pet
  where  pep.id                = p_id
  and    pep.id                = epr.pep_id
  and    epr.elt_base_id       = pet.element_type_id
  and    pet.business_group_id is not null
  union
  select distinct
         pet.business_group_id       bg_id
  from   hxt_prem_eligblty_policies  pep
  ,      hxt_prem_eligblty_rules     elr
  ,      pay_element_types_f         pet
  where  pep.id                = p_id
  and    pep.id                = elr.pep_id
  and    ((elr.elt_base_id     = pet.element_type_id
  and    pet.business_group_id is not null)
  or    (elr.elt_premium_id    = pet.element_type_id
  and    pet.business_group_id is not null));
--
CURSOR c_get_pip_bg(p_id number) is
  select distinct
         pet.business_group_id       bg_id
  from 	 hxt_prem_interact_policies  pip
  ,      hxt_prem_interact_rules     itr
  ,      pay_element_types_f         pet
  where  pip.id                   = p_id
  and    pip.id                   = itr.pip_id
  and    ((itr.elt_prior_prem_id  = pet.element_type_id
  and    pet.business_group_id    is not null)
  or     (itr.elt_earned_prem_id  = pet.element_type_id
  and    pet.business_group_id    is not null))
  union
  select distinct
         pet.business_group_id        bg_id
  from   hxt_prem_interact_policies   pip
  ,      hxt_prem_interact_pol_rules  ipr
  ,      pay_element_types_f          pet
  where  pip.id                 = p_id
  and    pip.id                 = ipr.pip_id
  and    ipr.elt_earned_prem_id = pet.element_type_id
  and    pet.business_group_id  is not null;
--
CURSOR c_get_hcl_bg(p_id number) is
  select distinct
         pet.business_group_id  bg_id
  from   hxt_holiday_calendars  hcl
  ,      pay_element_types_f    pet
  where  hcl.id                 = p_id
  and    hcl.element_type_id    = pet.element_type_id
  and    pet.business_group_id  is not null
  union
  select distinct
         hou.business_group_id  bg_id
  from   hxt_holiday_calendars  hcl
  ,      hr_organization_units  hou
  where  hcl.id                 = p_id
  and    hcl.organization_id    = hou.organization_id
  and    hou.business_group_id  is not null;
--
CURSOR c_get_epr_bg(p_id number) is
  select distinct
         pet.business_group_id  bg_id
  from   hxt_earning_rules      epr
  ,      pay_element_types_f    pet
  where  epr.egp_id             = p_id
  and    epr.element_type_id    = pet.element_type_id
  and    pet.business_group_id  is not null;
--
-- Update Earning Policies Procedure.
--
Procedure update_earn_policies
  (p_ep_id  IN  number
  ,p_bg_id  IN  number
  ) is
--
l_ep_id number;
l_bg_id number;
--
Begin
  l_ep_id := p_ep_id;
  l_bg_id := p_bg_id;
--
  UPDATE hxt_earning_policies
  SET    business_group_id = l_bg_id
  WHERE  id = l_ep_id;
--
hxt_bg_message_insert('U','Updating Earning Policy ID '||l_ep_id||' With Business Group ID '||l_bg_id);
--
End update_earn_policies;
--
--  Earnings Policy References Update Procedure.
--
Procedure update_ep_refs
  (p_bg     IN  number
  ,p_old_id IN  number
  ,p_new_id IN  number
  ) is
--
l_new_id     number;
l_aai_id     number;
l_ass_id     number;
l_aai_esd    date;
l_aai_eed    date;
--
CURSOR c_get_ass_info is
  select  aai.id                    id
  ,       aai.assignment_id         ass_id
  ,       aai.effective_start_date  esd
  ,       aai.effective_end_date    eed
  from    hxt_add_assign_info_f     aai
  ,       per_assignments_f         ass
  where   ass.business_group_id     = p_bg
  and     ass.assignment_id         = aai.assignment_id
  and     aai.earning_policy        = p_old_id;
--
Begin
  l_new_id := p_new_id;
--
  For assign in c_get_ass_info loop
--
    l_aai_id   := assign.id;
    l_ass_id   := assign.ass_id;
    l_aai_esd  := assign.esd;
    l_aai_eed  := assign.eed;
--
    update hxt_add_assign_info_f
    set    earning_policy       = l_new_id
    where  id                   = l_aai_id
    and    effective_start_date = l_aai_esd
    and    effective_end_date   = l_aai_eed;
--
hxt_bg_message_insert('U','Updating Assignment ID '||l_ass_id||' To Reference Earning Policy ID '||l_new_id);
--
  end loop;
--
End update_ep_refs;
--
--  Earning Policies Duplication Procedure.
--
Procedure duplicate_earn_policies
  (p_ep_id IN number
  ,p_refs  IN varchar2
  ) is
--
l_ep_id   number;
l_er_id   number;
l_counter number := 0;
l_name    varchar2(100);
--
CURSOR c_all_bg is
  select distinct
         pbg.business_group_id          id
  ,      to_char(pbg.business_group_id) name
  from   per_business_groups   pbg;
--
CURSOR c_seqno is
  select hxt_seqno.nextval
  from   dual;
--
CURSOR c_earnpol_rec is
  select hcl_id
  ,      fcl_earn_type
  ,      name
  ,      effective_start_date
  ,      pip_id
  ,      pep_id
  ,      egt_id
  ,      description
  ,      effective_end_date
  ,      organization_id
  ,      round_up
  ,      min_tcard_intvl
  from   hxt_earning_policies
  where  id = p_ep_id;
--
CURSOR c_earnrule_rec is
  select element_type_id
  ,      seq_no
  ,      name
  ,      egr_type
  ,      hours
  ,      effective_start_date
  ,      days
  ,      effective_end_date
  from   hxt_earning_rules
  where  egp_id = p_ep_id;
--
Begin
--
  For busg in c_all_bg loop
--
  l_ep_id   := 0;
  l_er_id   := 0;
  l_counter := 0;
--
  open   c_seqno;
  fetch  c_seqno into l_ep_id;
  close  c_seqno;
--
    For earnpols in c_earnpol_rec loop
--
      l_counter := l_counter +1;
--
      Insert into hxt_earning_policies
      (  id
      ,  hcl_id
      ,  fcl_earn_type
      ,  name
      ,  effective_start_date
      ,  pip_id
      ,  pep_id
      ,  egt_id
      ,  description
      ,  effective_end_date
      ,  created_by
      ,  creation_date
      ,  last_updated_by
      ,  last_update_date
      ,  last_update_login
      ,  organization_id
      ,  round_up
      ,  min_tcard_intvl
      ,  business_group_id
      )
      Values
      (  l_ep_id
      ,  earnpols.hcl_id
      ,  earnpols.fcl_earn_type
      ,  earnpols.name||'-'||busg.name
      ,  earnpols.effective_start_date
      ,  earnpols.pip_id
      ,  earnpols.pep_id
      ,  earnpols.egt_id
      ,  earnpols.description
      ,  earnpols.effective_end_date
      ,  -1
      ,  sysdate
      ,  -1
      ,  sysdate
      ,  -1
      ,  earnpols.organization_id
      ,  earnpols.round_up
      ,  earnpols.min_tcard_intvl
      ,  busg.id
      );
--
      if l_counter = 1 then
      For rules in c_earnrule_rec loop
--
        open   c_seqno;
        fetch  c_seqno into l_er_id;
        close  c_seqno;
--
        Insert into hxt_earning_rules
        (  id
        ,  element_type_id
        ,  egp_id
        ,  seq_no
        ,  name
        ,  egr_type
        ,  hours
        ,  effective_start_date
        ,  days
        ,  effective_end_date
        ,  created_by
        ,  creation_date
        ,  last_updated_by
        ,  last_update_date
        ,  last_update_login
        )
        Values
        (  l_er_id
        ,  rules.element_type_id
        ,  l_ep_id
        ,  rules.seq_no
        ,  rules.name
        ,  rules.egr_type
        ,  rules.hours
        ,  rules.effective_start_date
        ,  rules.days
        ,  rules.effective_end_date
        ,  -1
        ,  sysdate
        ,  -1
        ,  sysdate
        ,  -1
        );
--
      end loop;
--
      end if;
--
    l_name := earnpols.name;
--
    end loop;
--
    if p_refs = 'Y' then
      update_ep_refs(busg.id, p_ep_id, l_ep_id);
    end if;
--
  end loop;
--
hxt_bg_message_insert('U','Duplicating Earning Policy '||l_name||' Across All Business Groups');
--
  delete from hxt_earning_rules
  where egp_id = p_ep_id;
--
  delete from hxt_earning_policies
  where id = p_ep_id;
--
End duplicate_earn_policies;
--
-- Begin Main Processing.
--
BEGIN
--
  For epols in c_get_ass_epols loop
--
    g_ass_bg := -1;
--
    if epols.count_bg = 1 then
      open  c_get_ass_bg(epols.ep_id);
      fetch c_get_ass_bg into g_ass_bg;
      close c_get_ass_bg;
      update_earn_policies(epols.ep_id, g_ass_bg);
    else
      duplicate_earn_policies(epols.ep_id,'Y');
    end if;
--
  end loop;
--
  For earpols in c_get_nonass_epols loop
--
  g_nonass_bg := -1;
--
    open  c_get_hcl_bg(earpols.hcl_id);
    fetch c_get_hcl_bg into g_nonass_bg;
      if c_get_hcl_bg%FOUND then
        update_earn_policies(earpols.ep_id, g_nonass_bg);
        close c_get_hcl_bg;
      else
        close c_get_hcl_bg;
        open c_get_egt_bg(earpols.egt_id);
        fetch c_get_egt_bg into g_nonass_bg;
          if c_get_egt_bg%FOUND then
            update_earn_policies(earpols.ep_id, g_nonass_bg);
            close c_get_egt_bg;
          else
            close c_get_egt_bg;
            open c_get_pep_bg(earpols.pep_id);
            fetch c_get_pep_bg into g_nonass_bg;
              if c_get_pep_bg%FOUND then
                update_earn_policies(earpols.ep_id, g_nonass_bg);
                close c_get_pep_bg;
              else
                close c_get_pep_bg;
                open c_get_pip_bg(earpols.pip_id);
                fetch c_get_pip_bg into g_nonass_bg;
                  if c_get_pip_bg%FOUND then
                    update_earn_policies(earpols.ep_id, g_nonass_bg);
                    close c_get_pip_bg;
                  else
                    close c_get_pip_bg;
                    open c_get_epr_bg(earpols.ep_id);
                    fetch c_get_epr_bg into g_nonass_bg;
                      if c_get_epr_bg%FOUND then
                        update_earn_policies(earpols.ep_id, g_nonass_bg);
                        close c_get_epr_bg;
                      else
                        close c_get_epr_bg;
                        duplicate_earn_policies(earpols.ep_id,'N');
                      end if;
                  end if;
              end if;
          end if;
      end if;
--
  end loop;
--
--
End;
-------------------------------------------------------------------------------
end HXT_CHK_BG_AND_UPGRADE_PKG;

/
