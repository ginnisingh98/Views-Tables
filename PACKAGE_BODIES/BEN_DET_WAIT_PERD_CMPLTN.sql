--------------------------------------------------------
--  DDL for Package Body BEN_DET_WAIT_PERD_CMPLTN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_DET_WAIT_PERD_CMPLTN" AS
/*$Header: benwtprc.pkb 120.1 2006/06/30 13:37:50 swjain ship $*/
/*
--------------------------------------------------------------------------------
Name
  Determine Waiting Period Completed Date
Purpose
  This package is used compute when the waiting period end date.
--------------------------------------------------------------------------------
History
-------
  Version Date       Author     Comment
  -------+----------+----------+------------------------------------------------
  115.0   14-May-99  bbulusu    Created.
  115.1   14-Jun-99  Tmathers   Fixed P1 nls to_date errors.
  115.2   23-JUN-98  G PERRY    Performance fixes.
  115.3   20-JUL-99  Gperry     genutils -> benutils package rename.
  115.4   10-AUG-99  Gperry     Removed reference to ben_manage_life_events
                                old cache routine. Added fnd_date.canonical
                                _to_date for formula calls.
  115.5   26-AUG-99  Gperry     Added call to benefits assignment cache when
                                employee assignment can not be found.
  115.6   18-JAN-00  pbodla     Fixed bug 4146(WWBUG 1120687)
                                p_business_group_id added to benutils.formula
                                call.
  115.7   26-JAN-00  pbodla     Fixed bug 4401; plan is fetched only if p_pl_id
                                is not null
  115.8   17-Feb-00  lmcdonal   Bugs 1178692, 1178674.  Benefit's assignment
                                data is in aei_information fields, not
                                aei_attribute fields.
  115.9   18-Feb-00  lmcdonal   Bug 1179550: get ptip waiting period data.
  115.10  22-Feb-00  lmcdonal   Bug 1187476: Inherit wtg perd codes.
  115.11  03-Mar-00  mhoyes   - Added parameter p_comp_obj_tree_row.
                              - Assigned env values to locals.
                              - Phased out nocopy ben_env_object comp object references.
  115.12  04-Apr-00  mmogel   - Added tokens to message calls so that the
                                messages are more meaningful to the user
  115.13  06-Apr-00  jcarpent - Changed get_ben_asg_dt to look at benefits ass
                                first then emp assignment.  1178674/4299
  115.14  20-Jun-99  mhoyes   - Added current ben_prtn_elig_f,ben_elig_to_prte_rsn_f
                                and ben_pl_f row parameters.
                              - Derived row variables from parameters rather than
                                cache calls.
  115.15  13-Jul-00  mhoyes   - Removed context parameters.
  115.16  16-Aug-01  pbodla   - Bug 1838055 : Code AED added in procedure
                                get_wtg_perd_end_date.
  115.17  27-Aug-01  pbodla   - bug:1949361 jurisdiction code is
                                derived inside benutils.formula.
  115.18  26-sep-01  tjesumic   wait_perd_Strt_dt added
  115.19  23-Dec-02  rpgupta  - Nocopy changes
  115.20  21-JUL-03  glingapp - Bug 3047147 While checking for max waiting period
				current code had a check, which restricted the max
       				waiting period check to plan level. Now even at
				option in plan level max waiting period is checked for
				and used to determine the actual waiting period.
  115.21  22-SEP-04  ikasire    Bug 3895120 fixes
                                Several Changes in get_per_svc_dt,get_ben_asg_dt and
                                get_wait_end_date functions. else clause for the
                                waiting period codes was never working right.
  115.22  20-OCT-04  swjain     Bug No 3954620 Added code in get_wait_end_date to handle
                                the null case in p_wait_perd_dt_to_use_cd 'EASDNASD'
  115.23  25-OCT-04  swjain     Bug No 3954620 Few modifications in the added code
  115.24  29-Jun-06  swjain     Bug 5331889 Added person_id param in call to
                                benutils.formula in procedure get_wait_end_date
--------------------------------------------------------------------------------
*/
--
g_package varchar2(80) := 'ben_det_wait_perd_cmpltn';
--
-- -----------------------------------------------------------------------------
-- |-------------------------< get_per_svc_dt >--------------------------------|
-- -----------------------------------------------------------------------------
--
function get_per_svc_dt(p_person_id in number,
                        p_date_code in varchar2) return date is
  --
  l_ovrid_svc_dt   date;
  l_adj_svc_dt     date;
  l_orig_hire_date date;
  l_hire_date      date;
  l_return_date    date;
  l_look_further   boolean := TRUE;
  l_proc           varchar2(80) := g_package||'.get_per_svc_dt';
  l_pps_rec        per_periods_of_service%rowtype;
  l_per_rec        per_all_people_f%rowtype;
  --
begin
  --
  hr_utility.set_location('Entering : ' || l_proc, 10);
  --
  ben_person_object.get_object(p_person_id => p_person_id,
                               p_rec       => l_per_rec);
  --
  ben_person_object.get_object(p_person_id => p_person_id,
                               p_rec       => l_pps_rec);
  --
  l_ovrid_svc_dt   := ben_derive_part_and_rate_facts.
                      g_cache_details.
                      ovrid_svc_dt;
  --
  l_adj_svc_dt     := l_pps_rec.adjusted_svc_date;
  --
  l_orig_hire_date := l_per_rec.original_date_of_hire;
  --
  l_hire_date      := l_pps_rec.date_start;
  --
  if p_date_code <> 'OHD' then
    --
    -- If the date being searched for is not the original hire date, look in
    -- the following order: OSD -> ASD -> DOH
    --
    if p_date_code = 'OSD' then
      --
      -- Overriden Service Date.
      --
      if l_ovrid_svc_dt is not null then
        --
        hr_utility.set_location('Using OSD', 10);
        --
        l_return_date := l_ovrid_svc_dt;
        --
        -- Set flag so that the search stops.
        --
        -- l_look_further := FALSE;
        --
      end if;
      --
    end if;
    --
    if p_date_code = 'ASD' then -- or
      -- l_look_further = TRUE then
      --
      -- Adjusted service date.
      --
      if l_adj_svc_dt is not null then
        --
        hr_utility.set_location('Using ASD', 10);
        --
        l_return_date := l_adj_svc_dt;
        --
        -- Set flag so that the search stops.
        --
        l_look_further := FALSE;
        --
      end if;
      --
    end if;
    --
    if p_date_code = 'DOH' then -- or
      -- l_look_further = TRUE then
      --
      -- Date of Hire.
      --
      if l_hire_date is not null then
        --
        hr_utility.set_location('Using DOH', 10);
        --
        l_return_date := l_hire_date;
        --
      end if;
      --
    end if;
    --
  else
    --
    -- Date code is Original Hire Date.
    --
    hr_utility.set_location('Using OHD', 10);
    --
    l_return_date := l_orig_hire_date;
    --
  end if;
  --
  /*
  if l_return_date is null then
    --
    hr_utility.set_location('ERROR. Unable to calculate service date : ' ||
                            p_date_code, 10);
    --
    fnd_message.set_name('BEN', 'BEN_92197_CANT_CALC_SVC_DATE');
    fnd_message.set_token('PERSON_ID',to_char(p_person_id));
    fnd_message.set_token('DATE_CODE',p_date_code);
    fnd_message.set_token('PROC',l_proc);
    raise ben_manage_life_events.g_record_error;
    --
  end if;
  */
  --
  hr_utility.set_location('Leaving : ' || l_proc, 10);
  --
  return l_return_date;
  --
end get_per_svc_dt;
--
-- -----------------------------------------------------------------------------
-- |--------------------------< get_ben_asg_dt >-------------------------------|
-- -----------------------------------------------------------------------------
--
function get_ben_asg_dt
  (p_person_id         in number,
   p_effective_date    in date,
   p_business_group_id in number,
   p_date_code         in varchar2) return date is
  --
  l_ovrid_svc_dt date;
  l_adj_svc_dt   date;
  l_orig_hire_dt date;
  l_return_date  date;
  l_look_further boolean := TRUE;
  l_ass_rec      per_all_assignments_f%rowtype;
  L_aei_rec      per_assignment_extra_info%rowtype;
  l_proc         varchar2(80) := g_package||'.get_ben_asg_dt';

begin
  hr_utility.set_location('Entering : ' || l_proc, 10);
  --
  -- Get the ovrid_svc_dt from the cache.
  --
  l_ovrid_svc_dt := ben_derive_part_and_rate_facts.
                    g_cache_details.
                    ovrid_svc_dt;
  --
  -- Get the other service dates from the per_assignment_extra_info table.
  --
  ben_person_object.get_benass_object(p_person_id => p_person_id,
                                      p_rec       => l_ass_rec);
  --
  if l_ass_rec.assignment_id is null then
    --
    ben_person_object.get_object(p_person_id => p_person_id,
                                 p_rec       => l_ass_rec);
    --
  end if;
  --
  ben_person_object.get_object(p_assignment_id => l_ass_rec.assignment_id,
                               p_rec           => l_aei_rec);
  --
  l_adj_svc_dt := fnd_date.canonical_to_date(l_aei_rec.aei_information2);
  l_orig_hire_dt := fnd_date.canonical_to_date(l_aei_rec.aei_information3);
  --
  -- Get the appropriate date based osn the date code passed in.
  --
  if p_date_code = 'OSD' then
    --
    if l_ovrid_svc_dt is not null then
      --
      l_return_date := l_ovrid_svc_dt;
      --
      -- Set the flag so that the process does not search any more.
      --
      -- l_look_further := FALSE;
      --
    end if;
    --
  end if;
  --
  if p_date_code = 'ASD' then -- or l_look_further = TRUE then
    --
    if l_adj_svc_dt is not null then
      --
      l_return_date := l_adj_svc_dt;
      --
      -- Set the flag so that the process does not search any more.
      --
      -- l_look_further := FALSE;
      --
    end if;
    --
  end if;
  --
  if p_date_code = 'OHD' or
    p_date_code = 'DOH' then -- or
    -- l_look_further = TRUE then
    --
    if l_orig_hire_dt is not null then
      --
      l_return_date := l_orig_hire_dt;
      --
    end if;
    --
  end if;
  --
  /*
  if l_return_date is null then
    --
    hr_utility.set_location('ERROR in ' || l_proc, 10);
    --
    fnd_message.set_name('BEN', 'BEN_92197_CANT_CALC_SVC_DATE');
    fnd_message.set_token('PERSON_ID',to_char(p_person_id));
    fnd_message.set_token('DATE_CODE',p_date_code);
    fnd_message.set_token('PROC',l_proc);
    raise ben_manage_life_events.g_record_error;
    --
  end if;
  */
  --
  hr_utility.set_location('Leaving : ' || l_proc, 10);
  --
  return l_return_date;
  --
end get_ben_asg_dt;
--
-- -----------------------------------------------------------------------------
-- |-------------------------< get_wait_end_date >-----------------------------|
-- -----------------------------------------------------------------------------
--
function get_wait_end_date
  (p_wait_perd_dt_to_use_cd in varchar2,
   p_wait_perd_dt_to_use_rl in number,
   p_wait_perd_rl           in number,
   p_wait_perd_uom          in varchar2,
   p_wait_perd_val          in number,
   p_lf_evt_ocrd_dt         in date,
   p_ntfn_dt                in date,
   p_person_id              in number,
   p_pgm_id                 in number,
   p_pl_id                  in number,
   p_oipl_id                in number,
   p_ler_id                 in number,
   p_effective_date         in date,
   p_business_group_id      in number,
   p_wait_perd_strt_dt      out nocopy date ) return date is
  --
  l_employee_flag boolean := FALSE;
  l_wait_st_date date;
  l_wait_end_date date;
  l_outputs ff_exec.outputs_t;
  l_wait_perd_uom varchar2(30);
  l_wait_perd_val number(15);
  l_oipl_rec ben_oipl_f%rowtype;
  l_loc_rec  hr_locations_all%rowtype;
  l_pln_rec ben_pl_f%rowtype;
  l_ass_rec per_all_assignments_f%rowtype;
  --
  l_proc varchar2(80) := g_package || '.get_wtg_perd_end_date';
  l_typ_rec ben_person_object.g_cache_typ_table;
  l_jurisdiction_code varchar2(30);
  --
begin
  --
  hr_utility.set_location('Entering : ' || l_proc, 10);
  --
  -- First determine if the person is an employee or not.
  --
  ben_person_object.get_object(p_person_id => p_person_id,
                               p_rec       => l_typ_rec);
  --
  if l_typ_rec(1).system_person_type = 'EMP' then
    l_employee_flag := TRUE;
    hr_utility.set_location('l_employee_flag ', 11);
  else
    l_employee_flag := FALSE;
    hr_utility.set_location('NOT l_employee_flag', 11);
    --for a in l_typ_rec.first..l_typ_rec.last loop
    --hr_utility.set_location(to_char(a)||' '||l_typ_rec(a).system_person_type, 11);
    --end loop;
  end if;
  --
  -- Determine the date from which the waiting period should calculated from.
  --
  if p_wait_perd_dt_to_use_cd = 'RL' and
    p_wait_perd_dt_to_use_rl is not null then
    --
    -- Use the rule to determine the waiting period date from.
    --
    if p_oipl_id is not null then
      ben_comp_object.get_object(p_oipl_id => p_oipl_id,
                                 p_rec     => l_oipl_rec);
    end if;
    --
    -- Initialize the fast formula to return l_date_from
    --
    if p_pl_id is not null then
      ben_comp_object.get_object(p_pl_id => p_pl_id,
                               p_rec   => l_pln_rec);
    end if;

    ben_person_object.get_object(p_person_id => p_person_id,
                                 p_rec       => l_ass_rec);
    if l_ass_rec.assignment_id is null then
      ben_person_object.get_benass_object(p_person_id => p_person_id,
                                          p_rec       => l_ass_rec);
    end if;

    if l_ass_rec.location_id is not null then
      ben_location_object.get_object(p_location_id => l_ass_rec.location_id,
                                     p_rec         => l_loc_rec);
      /*
      if l_loc_rec.region_2 is not null then
        l_jurisdiction_code :=
          pay_mag_utils.lookup_jurisdiction_code
            (p_state => l_loc_rec.region_2);
      end if;
      */
    end if;
    l_outputs := benutils.formula
      (p_formula_id        => p_wait_perd_dt_to_use_rl,
       p_effective_date    => p_effective_date,
       p_assignment_id     => l_ass_rec.assignment_id,
       p_organization_id   => l_ass_rec.organization_id,
       p_pgm_id            => p_pgm_id,
       p_pl_id             => p_pl_id,
       p_pl_typ_id         => l_pln_rec.pl_typ_id,
       p_opt_id            => l_oipl_rec.opt_id,
       p_ler_id            => p_ler_id,
       p_business_group_id => p_business_group_id,
       p_jurisdiction_code => l_jurisdiction_code,
       p_param1            => 'BEN_IV_PERSON_ID',           -- Bug 5331889
       p_param1_value      => to_char(p_person_id));
    --
    -- Now we have executed the formula.  We want to assign the output to
    -- l_date_from
    --
    begin
      l_wait_st_date := fnd_date.canonical_to_date
                           (l_outputs(l_outputs.first).value);
    exception
      when others then
        fnd_message.set_name('BEN','BEN_91329_FORMULA_RETURN');
        fnd_message.set_token('RL',
                         'wait_perd_dt_to_use_rl :'||p_wait_perd_dt_to_use_rl);
        fnd_message.set_token('PROC',l_proc);
        fnd_message.raise_error;
    end;

  elsif p_wait_perd_dt_to_use_cd = 'EOSDNOSD' then
    --
    -- IF EMPLOYEE USE THE OVERRIDE SERVICE DATE IF NOT OVERRIDE SERVICE DATE
    --
    if l_employee_flag = TRUE then
      l_wait_st_date := get_per_svc_dt(p_person_id => p_person_id,
                                       p_date_code => 'OSD');
    else
      --
      -- Person is not an employee. Find service dates from bnf asg.
      --
      l_wait_st_date := get_ben_asg_dt
                          (p_person_id         => p_person_id,
                           p_effective_date    => p_effective_date,
                           p_business_group_id => p_business_group_id,
                           p_date_code         => 'OSD');
    end if;

  elsif p_wait_perd_dt_to_use_cd = 'EOSDNLED' then
    --
    -- IF EMPLOYEE USE THE OVERRIDE SERVICE DATE IF NOT LIFE EVENT DATE
    --
    if l_employee_flag = TRUE then
      l_wait_st_date := get_per_svc_dt(p_person_id => p_person_id,
                                       p_date_code => 'OSD');
    else
    --  l_wait_st_date := p_lf_evt_ocrd_dt;
      l_wait_st_date := get_ben_asg_dt
                          (p_person_id         => p_person_id,
                           p_effective_date    => p_effective_date,
                           p_business_group_id => p_business_group_id,
                           p_date_code         => 'OSD');
    end if;
    --
    if l_wait_st_date IS NULL THEN
      l_wait_st_date := p_lf_evt_ocrd_dt;
    end if;
    --
  elsif p_wait_perd_dt_to_use_cd = 'EOSDNLLRD' then
    --
    -- IF EMPLOYEE USE THE OVERRIDE SERVICE DATE IF NOT LATER OF LIFE EVENT
    -- DATE OR NOTIFIED DATE
    --
    if l_employee_flag = TRUE then
      --
      l_wait_st_date := get_per_svc_dt(p_person_id => p_person_id,
                                       p_date_code => 'OSD');
    else
      --
      -- Not employee use later or life event or notification date.
      --
      l_wait_st_date := get_ben_asg_dt
                          (p_person_id         => p_person_id,
                           p_effective_date    => p_effective_date,
                           p_business_group_id => p_business_group_id,
                           p_date_code         => 'OSD');
      --
    end if;
    if l_wait_st_date is null then
      l_wait_st_date := greatest(p_lf_evt_ocrd_dt,nvl(p_ntfn_dt,hr_api.g_sot));
    end if;
    --
  elsif p_wait_perd_dt_to_use_cd = 'EASDNASD' then
    --
    -- IF EMPLOYEE USE THE ADJUSTED SERVICE DATE IF NOT ADJUSTED SERVICE DATE
    --
    if l_employee_flag = TRUE then
      l_wait_st_date := get_per_svc_dt(p_person_id => p_person_id,
                                       p_date_code => 'ASD');
    else
      --
      -- Person is not an employee. Find service dates from bnf asg.
      --
      l_wait_st_date := get_ben_asg_dt
                          (p_person_id         => p_person_id,
                           p_effective_date    => p_effective_date,
                           p_business_group_id => p_business_group_id,
                           p_date_code         => 'ASD');
    end if;
    --
    --Bug No: 3954620
    --
    if l_wait_st_date is null then
    --
    -- Use person's hire date
    --
      if l_employee_flag = TRUE then
          l_wait_st_date := get_per_svc_dt(p_person_id => p_person_id,
                                           p_date_code => 'DOH');
      else
      --
      -- Person is not an employee. Find service dates from bnf asg.
      --
          l_wait_st_date := get_ben_asg_dt
                          (p_person_id         => p_person_id,
                           p_effective_date    => p_effective_date,
                           p_business_group_id => p_business_group_id,
                           p_date_code         => 'DOH');
      end if;
      --
    end if;
  --
  elsif p_wait_perd_dt_to_use_cd = 'EASDNLED' then
    --
    -- IF EMPLOYEE USE THE ADJUSTED SERVICE DATE IF NOT LIFE EVENT DATE
    --
    if l_employee_flag = TRUE then
      l_wait_st_date := get_per_svc_dt(p_person_id => p_person_id,
                                       p_date_code => 'ASD');
    else
      -- Person is not an employee. Find service dates from bnf asg.
      --
      l_wait_st_date := get_ben_asg_dt
                          (p_person_id         => p_person_id,
                           p_effective_date    => p_effective_date,
                           p_business_group_id => p_business_group_id,
                           p_date_code         => 'ASD');
    end if;
    --
    if l_wait_st_date is null then
      l_wait_st_date := p_lf_evt_ocrd_dt;
    end if;

  elsif p_wait_perd_dt_to_use_cd = 'EASDNLRD' then
    --
    -- IF EMPLOYEE USE THE ADJUSTED SERVICE DATE IF NOT LATER OF LIFE EVENT
    -- DATE OR NOTIFIED DATE
    --
    if l_employee_flag = TRUE then
      l_wait_st_date := get_per_svc_dt(p_person_id => p_person_id,
                                       p_date_code => 'ASD');
    else
      --
      -- Not employee use later or life event or notification date.
      --
      l_wait_st_date := get_ben_asg_dt
                          (p_person_id         => p_person_id,
                           p_effective_date    => p_effective_date,
                           p_business_group_id => p_business_group_id,
                           p_date_code         => 'ASD');
    end if;
    --
    if l_wait_st_date is null then
      --
      l_wait_st_date := greatest(p_lf_evt_ocrd_dt,nvl(p_ntfn_dt,hr_api.g_sot));
    end if;
    --
  elsif p_wait_perd_dt_to_use_cd = 'EDOHNDOH' then
    --
    -- IF EMPLOYEE USE THE DATE OF HIRE IF NOT DATE OF HIRE
    --
    if l_employee_flag = TRUE then
      l_wait_st_date := get_per_svc_dt(p_person_id => p_person_id,
                                       p_date_code => 'DOH');
    else
      --
      -- Person is not an employee. Find service dates from bnf asg.
      l_wait_st_date := get_ben_asg_dt
                          (p_person_id         => p_person_id,
                           p_effective_date    => p_effective_date,
                           p_business_group_id => p_business_group_id,
                           p_date_code         => 'DOH');
    end if;

  elsif p_wait_perd_dt_to_use_cd = 'EDOHNLED' then
    --
    -- If employee use the Date Of Hire if not Life Event Date
    --
    if l_employee_flag = TRUE then
      l_wait_st_date := get_per_svc_dt(p_person_id => p_person_id,
                                       p_date_code => 'DOH');
    else
      -- Person is not an employee. Find service dates from bnf asg.
      l_wait_st_date := get_ben_asg_dt
                          (p_person_id         => p_person_id,
                           p_effective_date    => p_effective_date,
                           p_business_group_id => p_business_group_id,
                           p_date_code         => 'DOH');
    end if;
    --
    if l_wait_st_date is null then
      l_wait_st_date := p_lf_evt_ocrd_dt;
    end if;

  elsif p_wait_perd_dt_to_use_cd = 'EDOHNLRD' then
    --
    -- IF EMPLOYEE USE THE DATE OF HIRE IF NOT LATER OF LIFE EVENT DATE
    -- OR NOTIFIED DATE
    --
    if l_employee_flag = TRUE then
      l_wait_st_date := get_per_svc_dt(p_person_id => p_person_id,
                                       p_date_code => 'DOH');
    else
      l_wait_st_date := get_ben_asg_dt
                          (p_person_id         => p_person_id,
                           p_effective_date    => p_effective_date,
                           p_business_group_id => p_business_group_id,
                           p_date_code         => 'DOH');
    end if;
    --
    if l_wait_st_date is null then
      l_wait_st_date := greatest(p_lf_evt_ocrd_dt,nvl(p_ntfn_dt,hr_api.g_sot));
    end if;

  elsif p_wait_perd_dt_to_use_cd = 'EOHDNOHD' then
    --
    -- IF EMPLOYEE USE THE ORIGINAL HIRE DATE IF NOT ORIGINAL HIRE DATE
    --
    if l_employee_flag = TRUE then
      l_wait_st_date := get_per_svc_dt(p_person_id => p_person_id,
                                       p_date_code => 'OHD');
    else
      --
      -- Person is not an employee. Find service dates from bnf asg.
      --
      l_wait_st_date := get_ben_asg_dt
                          (p_person_id         => p_person_id,
                           p_effective_date    => p_effective_date,
                           p_business_group_id => p_business_group_id,
                           p_date_code         => 'DOH');
    end if;

  elsif p_wait_perd_dt_to_use_cd = 'EOHDNLED' then
    --
    -- IF EMPLOYEE USE THE ORIGINAL HIRE DATE IF NOT LIFE EVENT DATE
    --
    if l_employee_flag = TRUE then
      l_wait_st_date := get_per_svc_dt(p_person_id => p_person_id,
                                       p_date_code => 'OHD');
    else
      -- Person is not an employee. Find service dates from bnf asg.
      --
      l_wait_st_date := get_ben_asg_dt
                          (p_person_id         => p_person_id,
                           p_effective_date    => p_effective_date,
                           p_business_group_id => p_business_group_id,
                           p_date_code         => 'DOH');
    end if;
    --
    if l_wait_st_date is null then
      l_wait_st_date := p_lf_evt_ocrd_dt;
    end if;

  elsif p_wait_perd_dt_to_use_cd = 'EOHDNLRD' then
    --
    -- IF EMPLOYEE USE THE ORIGINAL HIRE DATE IF NOT LATER OF LIFE EVENT DATE
    -- OR NOTIFIED DATE

    if l_employee_flag = TRUE then
      l_wait_st_date := get_per_svc_dt(p_person_id => p_person_id,
                                       p_date_code => 'OHD');
    else
      l_wait_st_date := get_ben_asg_dt
                          (p_person_id         => p_person_id,
                           p_effective_date    => p_effective_date,
                           p_business_group_id => p_business_group_id,
                           p_date_code         => 'DOH');
    end if;
    --
    if l_wait_st_date is null then
      l_wait_st_date := greatest(p_lf_evt_ocrd_dt,nvl(p_ntfn_dt,hr_api.g_sot));
    end if;

  -- Bug 1838055 : Added code AED.
  elsif p_wait_perd_dt_to_use_cd in ('LED', 'AED') then
    --
    -- Use the Life Event Date
    --
    l_wait_st_date := p_lf_evt_ocrd_dt;
  elsif p_wait_perd_dt_to_use_cd = 'LRD' then
    --
    -- Use the Later or Life Event Date or Notified Date
    --
    l_wait_st_date := greatest(p_lf_evt_ocrd_dt,nvl(p_ntfn_dt,hr_api.g_sot));
  else
    --
    -- Defensive coding in case code is not known.
    --
    fnd_message.set_name('BEN','BEN_91342_UNKNOWN_CODE_1');
    fnd_message.set_token('PROC',l_proc);
    fnd_message.set_token('CODE1',p_wait_perd_dt_to_use_cd);
    raise ben_manage_life_events.g_record_error ;
  end if;
  --
  if p_wait_perd_dt_to_use_cd IS NOT NULL and l_wait_st_date IS NULL then
    --
    hr_utility.set_location('ERROR in ' || l_proc, 10);
    --
    fnd_message.set_name('BEN', 'BEN_92197_CANT_CALC_SVC_DATE');
    fnd_message.set_token('PERSON_ID',to_char(p_person_id));
    fnd_message.set_token('DATE_CODE',p_wait_perd_dt_to_use_cd);
    fnd_message.set_token('PROC',l_proc);
    raise ben_manage_life_events.g_record_error;
    --
  end if;
  --
  hr_utility.set_location('Wait start date ' || l_wait_st_date, 10);
  --
  -- Now calculate the waiting period end date.
  --
  if p_wait_perd_rl is not null and
    p_wait_perd_val is null and
    p_wait_perd_uom is null then
    --
    -- Execute the waiting period rule to determine the uom and value.
    --
    --
    -- Use the rule to determine the waiting period date from.
    --
    if p_oipl_id is not null then
      ben_comp_object.get_object(p_oipl_id => p_oipl_id,
                                 p_rec     => l_oipl_rec);
    end if;
    if p_pl_id is not null then
      ben_comp_object.get_object(p_pl_id => p_pl_id,
                               p_rec   => l_pln_rec);
    end if;
    ben_person_object.get_object(p_person_id => p_person_id,
                                 p_rec       => l_ass_rec);
    if l_ass_rec.assignment_id is null then
      ben_person_object.get_benass_object(p_person_id => p_person_id,
                                          p_rec       => l_ass_rec);
    end if;
    if l_ass_rec.location_id is not null then
      ben_location_object.get_object(p_location_id => l_ass_rec.location_id,
                                     p_rec         => l_loc_rec);
      /*
      if l_loc_rec.region_2 is not null then
        l_jurisdiction_code :=
          pay_mag_utils.lookup_jurisdiction_code
            (p_state => l_loc_rec.region_2);
      end if;
      */
    end if;
    --
    -- Initialize the fast formula to return l_date_from
    --
    l_outputs := benutils.formula
      (p_formula_id        => p_wait_perd_rl,
       p_effective_date    => p_effective_date,
       p_assignment_id     => l_ass_rec.assignment_id,
       p_organization_id   => l_ass_rec.organization_id,
       p_pgm_id            => p_pgm_id,
       p_pl_id             => p_pl_id,
       p_pl_typ_id         => l_pln_rec.pl_typ_id,
       p_opt_id            => l_oipl_rec.opt_id,
       p_ler_id            => p_ler_id,
       p_business_group_id => p_business_group_id,
       p_jurisdiction_code => l_jurisdiction_code,
       p_param1            => 'BEN_IV_PERSON_ID',           -- Bug 5331889
       p_param1_value      => to_char(p_person_id));
    --
    -- Loop through the returned table and make sure that the returned values
    -- have been found
    --
    for l_count in l_outputs.first..l_outputs.last loop
      if l_outputs(l_count).name = 'WAIT_PERD_VAL' then
        l_wait_perd_val := l_outputs(l_count).value;
      elsif l_outputs(l_count).name = 'WAIT_PERD_UOM' then
        l_wait_perd_uom := l_outputs(l_count).value;
      else
        fnd_message.set_name('BEN','BEN_91329_FORMULA_RETURN');
        fnd_message.set_token('RL',
                         'wait_perd_rl :'||p_wait_perd_rl);
        fnd_message.set_token('PROC',l_proc);
        fnd_message.raise_error;
      end if;
    end loop;
  else
    --
    -- There is no rule defined. Use the val and uom defined.
    --
    l_wait_perd_uom := p_wait_perd_uom;
    l_wait_perd_val := p_wait_perd_val;
  end if;
  --
  -- Use the wait_perd_uom and wait_perd_val to compute the wait end date.
  --
  if l_wait_perd_uom = 'DY' then
    l_wait_end_date := l_wait_st_date + l_wait_perd_val;
  elsif l_wait_perd_uom = 'WK' then
    l_wait_end_date := l_wait_st_date + (l_wait_perd_val * 7);
  elsif l_wait_perd_uom = 'MO' then
    l_wait_end_date := add_months(l_wait_st_date,l_wait_perd_val);
  elsif l_wait_perd_uom = 'QTR' then
    l_wait_end_date := add_months(l_wait_st_date,(3 * l_wait_perd_val));
  elsif l_wait_perd_uom = 'YR' then
    l_wait_end_date := add_months(l_wait_st_date,(12 * l_wait_perd_val));
  end if;
  p_wait_perd_strt_dt := l_wait_st_date ;
  hr_utility.set_location('Leaving : ' || l_proc, 10);

  return l_wait_end_date;

end get_wait_end_date;
--
-- -----------------------------------------------------------------------------
-- |------------------------------< main >-------------------------------------|
-- -----------------------------------------------------------------------------
--
-- This is the main procedure that is called to compute the waiting period end
-- date for a plan.
--
procedure main
  (p_comp_obj_tree_row in     ben_manage_life_events.g_cache_proc_objects_rec
  ,p_person_id         in     number
  ,p_effective_date    in     date
  ,p_business_group_id in     number
  ,p_ler_id            in     number
  ,p_oipl_id           in     number
  ,p_pl_id             in     number
  ,p_pgm_id            in     number
  ,p_plip_id           in     number
  ,p_ptip_id           in     number
  ,p_lf_evt_ocrd_dt    in     date
  ,p_ntfn_dt           in     date
  ,p_return_date          out nocopy date
  ,p_wait_perd_strt_dt    out nocopy date
  )
is
  --
  l_dummy_num number;
  l_wait_perd_dt_to_use_cd varchar2(80);
  l_wait_perd_dt_to_use_rl number(15);
  l_wait_perd_rl number(15);
  l_wait_perd_uom varchar2(80);
  l_wait_perd_val number(15);
  l_wait_end_date date;
  l_max_wait_end_date date;
  l_pln_rec ben_pl_f%rowtype;
  l_plip_id number(15);
  l_wait_data_found  boolean      := FALSE;
  l_env_rec ben_env_object.g_global_env_rec_type;
  l_prtn_rec ben_prtn_elig_f%rowtype;
  l_elig_rec ben_elig_to_prte_rsn_f%rowtype;
  --
  l_proc varchar2(80) := g_package || '.main';
  --
  l_envpgm_id  number;
  l_envptip_id number;
  l_envplip_id number;
  l_envpl_id   number;
  --
begin
  hr_utility.set_location('Entering : ' || l_proc, 10);
  hr_utility.set_location('p_pgm_id   -> ' ||p_pgm_id ,10);
  hr_utility.set_location('p_ptip_id  -> ' ||p_ptip_id,10);
  hr_utility.set_location('p_plip_id  -> ' ||p_plip_id,10);
  hr_utility.set_location('p_pl_id    -> ' ||p_pl_id  ,10);
  hr_utility.set_location('p_oipl_id  -> ' ||p_oipl_id,10);

  ben_env_object.get(p_rec => l_env_rec);
  --
  -- Assign comp object locals
  --
  l_envpgm_id  := p_comp_obj_tree_row.par_pgm_id;
  l_envptip_id := p_comp_obj_tree_row.par_ptip_id;
  l_envplip_id := p_comp_obj_tree_row.par_plip_id;
  l_envpl_id   := p_comp_obj_tree_row.par_pl_id;
  --
  -- Look for waiting period attributes at the appropriate level based on the
  -- comp object being processed.
  if p_pgm_id is not null then
    -- The comp object being passed in is a pgm. Get wtg data at pgm level.
    if ben_cobj_cache.g_pgmprel_currow.wait_perd_dt_to_use_cd is null then
      if ben_cobj_cache.g_pgmetpr_currow.wait_perd_dt_to_use_cd is null then
        l_wait_data_found := false;
      else
        l_wait_perd_dt_to_use_cd := ben_cobj_cache.g_pgmetpr_currow.wait_perd_dt_to_use_cd;
        l_wait_perd_dt_to_use_rl := ben_cobj_cache.g_pgmetpr_currow.wait_perd_dt_to_use_rl;
        l_wait_perd_rl := ben_cobj_cache.g_pgmetpr_currow.wait_perd_rl;
        l_wait_perd_uom := ben_cobj_cache.g_pgmetpr_currow.wait_perd_uom;
        l_wait_perd_val := ben_cobj_cache.g_pgmetpr_currow.wait_perd_val;
        l_wait_data_found := true;
      end if;
    else
      l_wait_perd_dt_to_use_cd := ben_cobj_cache.g_pgmprel_currow.wait_perd_dt_to_use_cd;
      l_wait_perd_dt_to_use_rl := ben_cobj_cache.g_pgmprel_currow.wait_perd_dt_to_use_rl;
      l_wait_perd_rl := ben_cobj_cache.g_pgmprel_currow.wait_perd_rl;
      l_wait_perd_uom := ben_cobj_cache.g_pgmprel_currow.wait_perd_uom;
      l_wait_perd_val := ben_cobj_cache.g_pgmprel_currow.wait_perd_val;
      l_wait_data_found := true;
    end if;
  end if;  -- if pgm

  if p_oipl_id is not null then
    -- The comp object being evaluated is a OIPL. Get details at OIPL level.
    if ben_cobj_cache.g_oiplprel_currow.wait_perd_dt_to_use_cd is null then
      if ben_cobj_cache.g_oipletpr_currow.wait_perd_dt_to_use_cd is null then
        l_wait_data_found := false;
      else
        l_wait_perd_dt_to_use_cd := ben_cobj_cache.g_oipletpr_currow.wait_perd_dt_to_use_cd;
        l_wait_perd_dt_to_use_rl := ben_cobj_cache.g_oipletpr_currow.wait_perd_dt_to_use_rl;
        l_wait_perd_rl := ben_cobj_cache.g_oipletpr_currow.wait_perd_rl;
        l_wait_perd_uom := ben_cobj_cache.g_oipletpr_currow.wait_perd_uom;
        l_wait_perd_val := ben_cobj_cache.g_oipletpr_currow.wait_perd_val;
        l_wait_data_found := true;
      end if;
    else
      l_wait_perd_dt_to_use_cd := ben_cobj_cache.g_oiplprel_currow.wait_perd_dt_to_use_cd;
      l_wait_perd_dt_to_use_rl := ben_cobj_cache.g_oiplprel_currow.wait_perd_dt_to_use_rl;
      l_wait_perd_rl := ben_cobj_cache.g_oiplprel_currow.wait_perd_rl;
      l_wait_perd_uom := ben_cobj_cache.g_oiplprel_currow.wait_perd_uom;
      l_wait_perd_val := ben_cobj_cache.g_oiplprel_currow.wait_perd_val;
      l_wait_data_found := true;
    end if;
  end if;  -- if oipl

  if p_pl_id is not null or (p_oipl_id is not null and l_wait_data_found = FALSE)
    or p_plip_id is not null then
    -- The comp object being evaluated is a plan.
    if l_envplip_id is not null then
      -- The plan belongs to a program. Try to get anything defined at the
      -- plip level first.
      if ben_cobj_cache.g_plipprel_currow.wait_perd_dt_to_use_cd is null then
        if ben_cobj_cache.g_plipetpr_currow.wait_perd_dt_to_use_cd is null then
          l_wait_data_found := false;
        else
          l_wait_perd_dt_to_use_cd := ben_cobj_cache.g_plipetpr_currow.wait_perd_dt_to_use_cd;
          l_wait_perd_dt_to_use_rl := ben_cobj_cache.g_plipetpr_currow.wait_perd_dt_to_use_rl;
          l_wait_perd_rl := ben_cobj_cache.g_plipetpr_currow.wait_perd_rl;
          l_wait_perd_uom := ben_cobj_cache.g_plipetpr_currow.wait_perd_uom;
          l_wait_perd_val := ben_cobj_cache.g_plipetpr_currow.wait_perd_val;
          l_wait_data_found := true;
        end if;
      else
        l_wait_perd_dt_to_use_cd := ben_cobj_cache.g_plipprel_currow.wait_perd_dt_to_use_cd;
        l_wait_perd_dt_to_use_rl := ben_cobj_cache.g_plipprel_currow.wait_perd_dt_to_use_rl;
        l_wait_perd_rl := ben_cobj_cache.g_plipprel_currow.wait_perd_rl;
        l_wait_perd_uom := ben_cobj_cache.g_plipprel_currow.wait_perd_uom;
        l_wait_perd_val := ben_cobj_cache.g_plipprel_currow.wait_perd_val;
        l_wait_data_found := true;
      end if;
    end if; -- if plip_id is not null
    --
    -- If nothing was found at the PLIP level above, then search at the PL level
    --
    if l_wait_data_found = FALSE and (p_pl_id is not null or p_oipl_id is not null) then
      if ben_cobj_cache.g_plprel_currow.wait_perd_dt_to_use_cd is null then
        if ben_cobj_cache.g_pletpr_currow.wait_perd_dt_to_use_cd is null then
          l_wait_data_found := false;
        else
          l_wait_perd_dt_to_use_cd := ben_cobj_cache.g_pletpr_currow.wait_perd_dt_to_use_cd;
          l_wait_perd_dt_to_use_rl := ben_cobj_cache.g_pletpr_currow.wait_perd_dt_to_use_rl;
          l_wait_perd_rl := ben_cobj_cache.g_pletpr_currow.wait_perd_rl;
          l_wait_perd_uom := ben_cobj_cache.g_pletpr_currow.wait_perd_uom;
          l_wait_perd_val := ben_cobj_cache.g_pletpr_currow.wait_perd_val;
          l_wait_data_found := true;
        end if;
      else
        l_wait_perd_dt_to_use_cd := ben_cobj_cache.g_plprel_currow.wait_perd_dt_to_use_cd;
        l_wait_perd_dt_to_use_rl := ben_cobj_cache.g_plprel_currow.wait_perd_dt_to_use_rl;
        l_wait_perd_rl := ben_cobj_cache.g_plprel_currow.wait_perd_rl;
        l_wait_perd_uom := ben_cobj_cache.g_plprel_currow.wait_perd_uom;
        l_wait_perd_val := ben_cobj_cache.g_plprel_currow.wait_perd_val;
        l_wait_data_found := true;
      end if;
    end if;  -- wait_data_found=false
  end if;  -- if plan or oipl(and didn't find oipl level)

  -- If no wait period data was found for plip, pl or oipl records, or we
  -- are working with a ptip, look for ptip
  if l_wait_data_found =FALSE and l_envptip_id is not null and
     (p_pl_id is not null or p_oipl_id is not null or p_ptip_id is not null
      or p_plip_id is not null) then
    if ben_cobj_cache.g_ptipprel_currow.wait_perd_dt_to_use_cd is null then
      if ben_cobj_cache.g_ptipetpr_currow.wait_perd_dt_to_use_cd is null then
        -- Look at pgm level
        if ben_cobj_cache.g_pgmetpr_currow.wait_perd_dt_to_use_cd is null then
          if ben_cobj_cache.g_pgmprel_currow.wait_perd_dt_to_use_cd is null then
            l_wait_data_found := false;
          else
            l_wait_perd_dt_to_use_cd := ben_cobj_cache.g_pgmprel_currow.wait_perd_dt_to_use_cd;
            l_wait_perd_dt_to_use_rl := ben_cobj_cache.g_pgmprel_currow.wait_perd_dt_to_use_rl;
            l_wait_perd_rl := ben_cobj_cache.g_pgmprel_currow.wait_perd_rl;
            l_wait_perd_uom := ben_cobj_cache.g_pgmprel_currow.wait_perd_uom;
            l_wait_perd_val := ben_cobj_cache.g_pgmprel_currow.wait_perd_val;
            l_wait_data_found := true;
          end if;
        else
          l_wait_perd_dt_to_use_cd := ben_cobj_cache.g_pgmetpr_currow.wait_perd_dt_to_use_cd;
          l_wait_perd_dt_to_use_rl := ben_cobj_cache.g_pgmetpr_currow.wait_perd_dt_to_use_rl;
          l_wait_perd_rl := ben_cobj_cache.g_pgmetpr_currow.wait_perd_rl;
          l_wait_perd_uom := ben_cobj_cache.g_pgmetpr_currow.wait_perd_uom;
          l_wait_perd_val := ben_cobj_cache.g_pgmetpr_currow.wait_perd_val;
          l_wait_data_found := true;
        end if;
      else
        l_wait_perd_dt_to_use_cd := ben_cobj_cache.g_ptipetpr_currow.wait_perd_dt_to_use_cd;
        l_wait_perd_dt_to_use_rl := ben_cobj_cache.g_ptipetpr_currow.wait_perd_dt_to_use_rl;
        l_wait_perd_rl := ben_cobj_cache.g_ptipetpr_currow.wait_perd_rl;
        l_wait_perd_uom := ben_cobj_cache.g_ptipetpr_currow.wait_perd_uom;
        l_wait_perd_val := ben_cobj_cache.g_ptipetpr_currow.wait_perd_val;
        l_wait_data_found := true;
      end if;
    else
      l_wait_perd_dt_to_use_cd := ben_cobj_cache.g_ptipprel_currow.wait_perd_dt_to_use_cd;
      l_wait_perd_dt_to_use_rl := ben_cobj_cache.g_ptipprel_currow.wait_perd_dt_to_use_rl;
      l_wait_perd_rl := ben_cobj_cache.g_ptipprel_currow.wait_perd_rl;
      l_wait_perd_uom := ben_cobj_cache.g_ptipprel_currow.wait_perd_uom;
      l_wait_perd_val := ben_cobj_cache.g_ptipprel_currow.wait_perd_val;
      l_wait_data_found := true;
    end if;

  end if;
  if l_wait_data_found = TRUE then
    --
    -- Waiting period data was found. Continue with processing.
    --
    hr_utility.set_location('Waiting period data found. Continuing', 60);
    -- Calculate the date when the waiting period will end.
    l_wait_end_date := get_wait_end_date
                        (p_wait_perd_dt_to_use_cd => l_wait_perd_dt_to_use_cd,
                         p_wait_perd_dt_to_use_rl => l_wait_perd_dt_to_use_rl,
                         p_wait_perd_rl           => l_wait_perd_rl,
                         p_wait_perd_uom          => l_wait_perd_uom,
                         p_wait_perd_val          => l_wait_perd_val,
                         p_lf_evt_ocrd_dt         => p_lf_evt_ocrd_dt,
                         p_ntfn_dt                => p_ntfn_dt,
                         p_person_id              => p_person_id,
                         p_pgm_id                 => p_pgm_id,
                         p_pl_id                  => p_pl_id,
                         p_oipl_id                => p_oipl_id,
                         p_ler_id                 => p_ler_id,
                         p_effective_date         => p_effective_date,
                         p_business_group_id      => p_business_group_id,
                         p_wait_perd_strt_dt      => p_wait_perd_strt_dt );
    hr_utility.set_location('Wait end date : ' ||
                            nvl(to_char(l_wait_end_date, 'DD-MON-YYYY')
                               ,'NULL'), 62);
    --
    -- Get the plan's max waiting perd attibutes form the cache.
    --
    if p_pl_id is not null or p_oipl_id is not null then  /*Bug 3047147 chk for p_oipl_id also*/
      --
      -- Get the plan related data from the cache.
      --
      l_wait_perd_dt_to_use_cd := ben_cobj_cache.g_pl_currow.mx_wtg_dt_to_use_cd;
      l_wait_perd_dt_to_use_rl := ben_cobj_cache.g_pl_currow.mx_wtg_dt_to_use_rl;
      l_wait_perd_rl           := ben_cobj_cache.g_pl_currow.mx_wtg_perd_rl;
      l_wait_perd_uom          := ben_cobj_cache.g_pl_currow.mx_wtg_perd_prte_uom;
      l_wait_perd_val          := ben_cobj_cache.g_pl_currow.mx_wtg_perd_prte_val;
      --
      -- Now calculate the maximum waiting period end date if one is defined.
      --
      if l_wait_perd_dt_to_use_cd is not null then
        --
        l_max_wait_end_date :=
          get_wait_end_date
            (p_wait_perd_dt_to_use_cd => l_wait_perd_dt_to_use_cd,
             p_wait_perd_dt_to_use_rl => l_wait_perd_dt_to_use_rl,
             p_wait_perd_rl           => l_wait_perd_rl,
             p_wait_perd_uom          => l_wait_perd_uom,
             p_wait_perd_val          => l_wait_perd_val,
             p_lf_evt_ocrd_dt         => p_lf_evt_ocrd_dt,
             p_ntfn_dt                => p_ntfn_dt,
             p_person_id              => p_person_id,
             p_pgm_id                 => p_pgm_id,
             p_pl_id                  => p_pl_id,
             p_oipl_id                => p_oipl_id,
             p_ler_id                 => p_ler_id,
             p_effective_date         => p_effective_date,
             p_business_group_id      => p_business_group_id,
             p_wait_perd_strt_dt      => p_wait_perd_strt_dt );
        hr_utility.set_location('Max wait end date : ' ||
                                to_char(l_max_wait_end_date, 'DD-MON-YYYY'), 70);
      end if;
    end if;

    if l_max_wait_end_date is not null then
      --
      -- Compare the waiting period end date to the max_wait_end_date. If it is
      -- greater than the max wait end date then return the max wait end date.
      -- If not then return the wait_end_date.
      --
      if l_wait_end_date > l_max_wait_end_date then
        p_return_date := l_max_wait_end_date;
      else
        p_return_date := l_wait_end_date;
      end if;
    else
      -- There is no maximum wait for the plan. Just return the wait_end_date.
      p_return_date := l_wait_end_date;
    end if;
  else
    -- l_wait_data_found is FALSE. Exit the procedure
    hr_utility.set_location('Waiting period data not found.', 90);
    p_return_date := NULL;
  end if;

  hr_utility.set_location('Leaving : ' || l_proc, 99);
end main;
--
end ben_det_wait_perd_cmpltn;

/
