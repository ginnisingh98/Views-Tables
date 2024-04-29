--------------------------------------------------------
--  DDL for Package Body BENUTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BENUTILS" as
/* $Header: benutils.pkb 120.20 2008/01/24 07:00:12 sallumwa ship $ */
--
g_package   varchar2(80) := 'benutils';

type t_pkey_table is table of varchar2(30) index by binary_integer;
--
g_part_of_pkey      t_pkey_table;
g_primary_key_count number(9);
g_batch_elig_table_count number := 0;
g_batch_ler_table_count number := 0;
g_batch_action_table_count number := 0;
g_batch_elctbl_table_count number := 0;
g_batch_rate_table_count number := 0;
g_batch_dpnt_table_count number := 0;
g_batch_commu_table_count number := 0;
g_report_table_count number := 0;
g_batch_elig_table_object g_batch_elig_table := g_batch_elig_table();
g_batch_ler_table_object g_batch_ler_table := g_batch_ler_table();
g_batch_elctbl_table_object g_batch_elctbl_table := g_batch_elctbl_table();
g_batch_rate_table_object g_batch_rate_table := g_batch_rate_table();
g_batch_dpnt_table_object g_batch_dpnt_table := g_batch_dpnt_table();
--
----------------------------------------------------------------------------
--  rt_typ_calc
----------------------------------------------------------------------------
PROCEDURE rt_typ_calc
      (p_val              IN number,
       p_val_2            IN number,
       p_rt_typ_cd        IN varchar2,
       p_calculated_val   OUT NOCOPY number) is
  --
  l_package varchar2(80) := g_package||'.rt_typ_calc';
  --
BEGIN
  --
--  hr_utility.set_location ('Entering '||l_package,10);
  --
  if p_val is null /*or p_val = 0 commented for 3497676*/then
    --
--    hr_utility.set_location ('Leaving '||l_package,1);
    return;
    --
  end if;
  --
  if p_val_2 is null /*or p_val_2 = 0 commented for 3497676*/then
    --
--    hr_utility.set_location ('Leaving '||l_package,2);
    return;
    --
  end if;
  --
  if p_rt_typ_cd = 'MLT' then
    --
    p_calculated_val := p_val * p_val_2;
    --
  elsif p_rt_typ_cd in ('PCT','PERHNDRD') then
    --
    p_calculated_val := (p_val/100) * p_val_2;
    --
  elsif p_rt_typ_cd = 'PERTEN' then
    --
    p_calculated_val := (p_val/10) * p_val_2;
    --
  elsif p_rt_typ_cd = 'PERTHSND' then
    --
    p_calculated_val := (p_val/1000) * p_val_2;
    --
  elsif p_rt_typ_cd = 'PERTTHSND' then
    --
    p_calculated_val := (p_val/10000) * p_val_2;
    --
  else
      fnd_message.set_name('BEN','BEN_91342_UNKNOWN_CODE_1');
      fnd_message.set_token('PROC',l_package);
      fnd_message.set_token('CODE1',p_rt_typ_cd);
      fnd_message.raise_error;
  end if;
  --
--  hr_utility.set_location ('Leaving '||l_package,10);
  --
END rt_typ_calc;
--
------------------------------------------------------------------------
--  limit_checks
------------------------------------------------------------------------
--
PROCEDURE limit_checks (p_lwr_lmt_val       in number,
                     p_lwr_lmt_calc_rl   in number,
                     p_upr_lmt_val       in number,
                     p_upr_lmt_calc_rl   in number,
                     p_effective_date    in date,
                     p_assignment_id     in number,
                     p_organization_id   in number,
                     p_business_group_id in number,
                     p_pgm_id            in number,
                     p_pl_id             in number,
                     p_pl_typ_id         in number,
                     p_opt_id            in number,
                     p_ler_id            in number,
                     p_acty_base_rt_id   in number ,
                     p_elig_per_elctbl_chc_id   in number ,
                     p_val               in out nocopy number,
                     p_state             in varchar2) is
  --
  l_lwr_outputs  ff_exec.outputs_t;
  l_upr_outputs  ff_exec.outputs_t;
  l_package varchar2(80) := g_package||'.limit_checks';
  l_jurisdiction PAY_CA_EMP_PROV_TAX_INFO_F.JURISDICTION_CODE%type := null;
  --
BEGIN
  --
  hr_utility.set_location('Entering '||l_package,20);
  --
  hr_utility.set_location('Floor/Ceiling Rule Checking'||l_package,30);
  --
  -- Bug 1949361 : jurisdiction code is fetched inside formula function
  -- call.
  --
  /*
  if p_state is not null then
     l_jurisdiction := pay_mag_utils.lookup_jurisdiction_code
                               (p_state => p_state);
  end if;
  */
  --
  if p_lwr_lmt_calc_rl is not NULL then
    --
    l_lwr_outputs := benutils.formula
                 (p_formula_id        => p_lwr_lmt_calc_rl,
                  p_effective_date    => p_effective_date,
                  p_assignment_id     => p_assignment_id,
                  p_organization_id   => p_organization_id,
                  p_business_group_id => p_business_group_id,
                  p_pgm_id            => p_pgm_id,
                  p_pl_id             => p_pl_id,
                  p_pl_typ_id         => p_pl_typ_id,
                  p_opt_id            => p_opt_id,
                  p_ler_id            => p_ler_id,
                  p_acty_base_rt_id   => p_acty_base_rt_id,
                  p_elig_per_elctbl_chc_id   => p_elig_per_elctbl_chc_id,
                  -- FONM
                  p_param1             => 'BEN_IV_RT_STRT_DT',
                  p_param1_value       => fnd_date.date_to_canonical(ben_manage_life_events.g_fonm_rt_strt_dt),
                  p_param2             => 'BEN_IV_CVG_STRT_DT',
                  p_param2_value       => fnd_date.date_to_canonical(ben_manage_life_events.g_fonm_cvg_strt_dt),
                  p_jurisdiction_code => l_jurisdiction);
    --
  end if;
  --
  if p_upr_lmt_calc_rl is not NULL then
    --
    l_upr_outputs := benutils.formula
                 (p_formula_id        => p_upr_lmt_calc_rl,
                  p_effective_date    => p_effective_date,
                  p_assignment_id     => p_assignment_id,
                  p_organization_id   => p_organization_id,
                  p_business_group_id => p_business_group_id,
                  p_pgm_id            => p_pgm_id,
                  p_pl_id             => p_pl_id,
                  p_pl_typ_id         => p_pl_typ_id,
                  p_opt_id            => p_opt_id,
                  p_ler_id            => p_ler_id,
                  p_acty_base_rt_id   => p_acty_base_rt_id,
                  p_elig_per_elctbl_chc_id   => p_elig_per_elctbl_chc_id,
                  -- FONM
                  p_param1             => 'BEN_IV_RT_STRT_DT',
                  p_param1_value       => fnd_date.date_to_canonical(ben_manage_life_events.g_fonm_rt_strt_dt),
                  p_param2             => 'BEN_IV_CVG_STRT_DT',
                  p_param2_value       => fnd_date.date_to_canonical(ben_manage_life_events.g_fonm_cvg_strt_dt),
                  p_jurisdiction_code => l_jurisdiction);
    --
  end if;
  --
  hr_utility.set_location('Floor/Ceiling Val Checking'||l_package,40);
  --
  if p_val > nvl(p_upr_lmt_val,p_val+1) then
    --
    p_val := p_upr_lmt_val;
    --
  elsif (p_upr_lmt_calc_rl is not NULL) and p_val >
    nvl(l_upr_outputs(l_upr_outputs.first).value,p_val+1) then
    --
    p_val := l_upr_outputs(l_upr_outputs.first).value;
    --
  elsif p_val < nvl(p_lwr_lmt_val,p_val-1) then
    --
    p_val := p_lwr_lmt_val;
    --
  elsif (p_lwr_lmt_calc_rl is not NULL) and p_val <
    nvl(l_lwr_outputs(l_lwr_outputs.first).value,p_val-1) then
    --
    p_val := l_lwr_outputs(l_lwr_outputs.first).value;
    --
  end if;
  --
  hr_utility.set_location('Leaving '||l_package,20);
  --
END limit_checks;

------------------------------------------------------------------------
--  init_lookups
------------------------------------------------------------------------
procedure init_lookups(p_lookup_type_1  in varchar2 ,
                       p_lookup_type_2  in varchar2 ,
                       p_lookup_type_3  in varchar2 ,
                       p_lookup_type_4  in varchar2 ,
                       p_lookup_type_5  in varchar2 ,
                       p_lookup_type_6  in varchar2 ,
                       p_lookup_type_7  in varchar2 ,
                       p_lookup_type_8  in varchar2 ,
                       p_lookup_type_9  in varchar2 ,
                       p_lookup_type_10 in varchar2 ,
                       p_effective_date in date) is
  --
  l_proc   varchar2(80) := 'benutils.init_lookups';
  l_count  number := 0;
  --
  cursor c_lookups is
    select lookup_type,
           lookup_code
    from   hr_lookups
    where  lookup_type in (nvl(p_lookup_type_1,'DUMMY_VALUE'),
                           nvl(p_lookup_type_2,'DUMMY_VALUE'),
                           nvl(p_lookup_type_3,'DUMMY_VALUE'),
                           nvl(p_lookup_type_4,'DUMMY_VALUE'),
                           nvl(p_lookup_type_5,'DUMMY_VALUE'),
                           nvl(p_lookup_type_6,'DUMMY_VALUE'),
                           nvl(p_lookup_type_7,'DUMMY_VALUE'),
                           nvl(p_lookup_type_8,'DUMMY_VALUE'),
                           nvl(p_lookup_type_9,'DUMMY_VALUE'),
                           nvl(p_lookup_type_10,'DUMMY_VALUE'))
    and    enabled_flag = 'Y'
    and    p_effective_date
           between nvl(start_date_active,p_effective_date)
           and     nvl(end_date_active, p_effective_date);
  --
  l_lookups c_lookups%rowtype;
  --
begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- First clear old cache
  --
  g_cache_lookup_object.delete;
  --
  -- Now load cache structure
  --
  open c_lookups;
  --
  hr_utility.set_location('open c_lookups: '||l_proc, 10);
    --
    loop
      --
      fetch c_lookups into l_lookups;
      exit when c_lookups%notfound;
      --
      -- Load cache structure
      --
      l_count := l_count + 1;
      g_cache_lookup_object(l_count).lookup_type := l_lookups.lookup_type;
      g_cache_lookup_object(l_count).lookup_code := l_lookups.lookup_code;
      --
    end loop;
    --
  close c_lookups;
  --
  hr_utility.set_location('Leaving:'||l_proc, 5);
  --
end init_lookups;

------------------------------------------------------------------------
--  get_lf_evt_ocrd_dt
------------------------------------------------------------------------
function get_lf_evt_ocrd_dt(p_person_id         in number,
                            p_business_group_id in number,
                            p_ler_id            in number ,
                            p_effective_date    in date) return date is
  --
  l_proc           varchar2(80) := 'benutils.get_lf_evt_ocrd_dt';
  l_lf_evt_ocrd_dt date;
  --
  cursor c_lf_evt_ocrd_dt is
    select pil.lf_evt_ocrd_dt
    from   ben_per_in_ler pil
    where  pil.person_id = p_person_id
    and    pil.business_group_id + 0 = p_business_group_id
    and    pil.ler_id = nvl(p_ler_id,pil.ler_id)
    and    pil.per_in_ler_stat_cd = 'STRTD';
  --
begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open c_lf_evt_ocrd_dt;
    --
    fetch c_lf_evt_ocrd_dt into l_lf_evt_ocrd_dt;
    --
  close c_lf_evt_ocrd_dt;
  --
  hr_utility.set_location('Leaving:'||l_proc, 5);
  --
  return l_lf_evt_ocrd_dt;
  --
end get_lf_evt_ocrd_dt;
--
------------------------------------------------------------------------
--  get_per_in_ler_id
--  returns active non-unrestricted life event
--  function is called only in benauten.pkb and which is applicable only
--  'L' or 'C' modes of benmnlge
------------------------------------------------------------------------
function get_per_in_ler_id(p_person_id         in number,
                           p_business_group_id in number,
                           p_ler_id            in number ,
                           p_effective_date    in date) return number is
  --
  l_proc           varchar2(80) := 'benutils.get_per_in_ler_id';
  l_per_in_ler_id  number;
  --
  cursor c_per_in_ler_id is
    select pil.per_in_ler_id
    from   ben_per_in_ler pil,
           ben_ler_f ler
    where  pil.person_id = p_person_id
    and    pil.ler_id = nvl(p_ler_id,pil.ler_id)
    and    pil.ler_id = ler.ler_id
    and    pil.per_in_ler_stat_cd = 'STRTD'
    and    ler.typ_cd <> 'SCHEDDU'
    and    p_effective_date between
           ler.effective_start_date and ler.effective_end_date;
  --
begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open c_per_in_ler_id;
    --
    fetch c_per_in_ler_id into l_per_in_ler_id;
    --
  close c_per_in_ler_id;
  --
  hr_utility.set_location('Leaving:'||l_proc, 5);
  --
  return l_per_in_ler_id;
  --
end get_per_in_ler_id;

------------------------------------------------------------------------
--  CWB Changes
--  get_active_life_event
--  returns compensation type active life event
------------------------------------------------------------------------
procedure get_active_life_event(p_person_id         in  number,
                                p_business_group_id in  number,
                                p_effective_date    in  date,
                                p_lf_evt_ocrd_dt    in  date,
                                p_ler_id            in number,
                                p_rec               out nocopy g_active_life_event) is
  --
  l_proc           varchar2(80) := 'benutils.get_active_life_event';
  --
  cursor c_active_life_event is
    select pil.per_in_ler_id,
           pil.lf_evt_ocrd_dt,
           pil.ntfn_dt,
           pil.ler_id,
           ler.name,
           ler.typ_cd,
           ler.ovridg_le_flag,
           ler.ptnl_ler_trtmt_cd,
           pil.object_version_number,
           pil.ptnl_ler_for_per_id,
           ler.qualg_evt_flag
    from   ben_per_in_ler pil,
           ben_ler_f ler
    where  pil.person_id = p_person_id
    and    ler.ler_id = pil.ler_id
    and    ler.ler_id = p_ler_id
    and    p_effective_date
      between ler.effective_start_date
           and     ler.effective_end_date
    and    pil.lf_evt_ocrd_dt = p_lf_evt_ocrd_dt
    and    pil.per_in_ler_stat_cd = 'STRTD'
    and    ler.typ_cd = 'COMP';
  --
begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open c_active_life_event;
    --
    fetch c_active_life_event into p_rec;
    --
  close c_active_life_event;
  --
  hr_utility.set_location('Leaving:'||l_proc, 5);
  --
end get_active_life_event;
-----------------------------------------------------------------------
--  get_per_in_ler_id
--  returns active unrestricted life event
------------------------------------------------------------------------
function get_per_in_ler_id(p_person_id         in number,
                           p_business_group_id in number,
                           p_ler_id            in number ,
                           p_lf_event_mode       in varchar2 ,
                           p_effective_date    in date) return number is
  --
  l_proc           varchar2(80) := 'benutils.get_per_in_ler_id_u';
  l_per_in_ler_id  number;
  --
  cursor c_per_in_ler_id is
    select pil.per_in_ler_id
    from   ben_per_in_ler pil,
           ben_ler_f ler
    where  pil.person_id = p_person_id
    and    pil.business_group_id = p_business_group_id
    and    pil.ler_id = nvl(p_ler_id,pil.ler_id)
    and    pil.ler_id = ler.ler_id
    and    pil.per_in_ler_stat_cd = 'STRTD'
    and    ler.typ_cd = 'SCHEDDU'
    and    p_effective_date between
           ler.effective_start_date and ler.effective_end_date;
  --
begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open c_per_in_ler_id;
    --
    fetch c_per_in_ler_id into l_per_in_ler_id;
    --
  close c_per_in_ler_id;
  --
  hr_utility.set_location('Leaving:'||l_proc, 5);
  return l_per_in_ler_id;
  --
end get_per_in_ler_id;
------------------------------------------------------------------------
--  get_active_life_event
--  returns non-unrestricted active life event
------------------------------------------------------------------------
procedure get_active_life_event(p_person_id         in  number,
                                p_business_group_id in  number,
                                p_effective_date    in  date,
                                p_rec               out nocopy g_active_life_event) is
  --
  l_proc           varchar2(80) := 'benutils.get_active_life_event';
  --
  cursor c_active_life_event is
    select pil.per_in_ler_id,
           pil.lf_evt_ocrd_dt,
           pil.ntfn_dt,
           pil.ler_id,
           ler.name,
           ler.typ_cd,
           ler.ovridg_le_flag,
           ler.ptnl_ler_trtmt_cd,
           pil.object_version_number,
           pil.ptnl_ler_for_per_id,
           ler.qualg_evt_flag
    from   ben_per_in_ler pil,
           ben_ler_f ler
    where  pil.person_id = p_person_id
    and    ler.ler_id = pil.ler_id
    and    p_effective_date
      between ler.effective_start_date
           and     ler.effective_end_date
    and    pil.per_in_ler_stat_cd = 'STRTD'
    --
    -- CWB Changes GRADE - added 2 more values.
    -- iRec Added mode iRecruitment (I)
    and    ler.typ_cd not in ('SCHEDDU', 'COMP', 'GSP', 'ABS', 'IREC');
  --
begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open c_active_life_event;
    --
    fetch c_active_life_event into p_rec;
    --
  close c_active_life_event;
  --
  hr_utility.set_location('Leaving:'||l_proc, 5);
  --
end get_active_life_event;

------------------------------------------------------------------------
--  get_active_life_event - overloaded with life_event_mode parameter
--  returns active unrestricted life event
------------------------------------------------------------------------
procedure get_active_life_event(p_person_id         in  number,
                                p_business_group_id in  number,
                                p_effective_date    in  date,
                                p_lf_event_mode     in  varchar2 ,
                                p_rec               out nocopy g_active_life_event) is
  --
  l_proc           varchar2(80) := 'benutils.get_active_life_event';
  --
  cursor c_active_life_event is
    select pil.per_in_ler_id,
           pil.lf_evt_ocrd_dt,
           pil.ntfn_dt,
           pil.ler_id,
           ler.name,
           ler.typ_cd,
           ler.ovridg_le_flag,
           ler.ptnl_ler_trtmt_cd,
           pil.object_version_number,
           pil.ptnl_ler_for_per_id,
           ler.qualg_evt_flag
    from   ben_per_in_ler pil,
           ben_ler_f ler
    where  pil.person_id = p_person_id
    and    pil.business_group_id = p_business_group_id
    and    ler.ler_id = pil.ler_id
    and    ler.business_group_id = pil.business_group_id
    and    p_effective_date
           between ler.effective_start_date
           and     ler.effective_end_date
    and    pil.per_in_ler_stat_cd = 'STRTD'
    -- GSP : make use of the same function for GSP
    and    ((p_lf_event_mode in ('U','D') and ler.typ_cd = 'SCHEDDU') or -- ICM Change
            (p_lf_event_mode = 'M' and ler.typ_cd = 'ABS') or
            (p_lf_event_mode = 'G' and ler.typ_cd = 'GSP') or
	    (p_lf_event_mode = 'I' and ler.typ_cd = 'IREC'
	     and pil.assignment_id = ben_manage_life_events.g_irec_ass_rec.assignment_id) );  -- iRec
--
begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open c_active_life_event;
    --
    fetch c_active_life_event into p_rec;
    --
  close c_active_life_event;
  --
  hr_utility.set_location('Leaving:'||l_proc, 5);
  --
end get_active_life_event;


------------------------------------------------------------------------
--  get_ler
------------------------------------------------------------------------
procedure get_ler(p_business_group_id in  number,
                  p_ler_id            in  number,
                  p_effective_date    in  date,
                  p_rec               out nocopy g_ler) is
  --
  l_proc           varchar2(80) := 'benutils.get_ler';
  --
  cursor c_ler is
    select ler.ler_id,
           ler.ler_eval_rl,
           ler.name
    from   ben_ler_f ler
    where  ler.business_group_id = p_business_group_id
    and    ler.ler_id = p_ler_id
    and    p_effective_date
           between ler.effective_start_date
           and     ler.effective_end_date;
  --
begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open c_ler;
    --
    fetch c_ler into p_rec;
    --
  close c_ler;
  --
  hr_utility.set_location('Leaving:'||l_proc, 5);
  --
end get_ler;
--
procedure get_ler(p_business_group_id in  number,
                  p_typ_cd            in  varchar2,
                  p_effective_date    in  date,
                  p_lf_evt_oper_cd    in  varchar2 default null,   /* GSP Rate Sync */
                  p_rec               out nocopy g_ler) is
  --
  l_proc           varchar2(80) := 'benutils.get_ler';
  --
  cursor c_ler is
    select ler.ler_id,
           ler.ler_eval_rl,
           ler.name
    from   ben_ler_f ler
    where  ler.business_group_id = p_business_group_id
    and    ler.typ_cd = p_typ_cd
    and    p_effective_date
           between ler.effective_start_date
           and     ler.effective_end_date
    and    (    p_typ_cd <> 'GSP'                                                                           /* GSP Rate Sync */
            or  ( p_typ_cd = 'GSP' and nvl(ler.lf_evt_oper_cd, 'PROG') = nvl(p_lf_evt_oper_cd, 'PROG') )    /* GSP Rate Sync */
            );

  --
begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_utility.set_location('ACE p_typ_cd : ' || p_typ_cd, 5);
  hr_utility.set_location('ACE p_lf_evt_oper_cd : ' || p_lf_evt_oper_cd, 5);
  --
  open c_ler;
    --
    fetch c_ler into p_rec;
    --
  close c_ler;
  --
  hr_utility.set_location('ACE p_rec.name : ' || p_rec.name, 5);
  hr_utility.set_location('Leaving:'||l_proc, 5);
  --
end get_ler;

------------------------------------------------------------------------
--  get_ptnl_ler
------------------------------------------------------------------------
procedure get_ptnl_ler(p_business_group_id in  number,
                       p_person_id         in  number,
                       p_ler_id            in  number,
                       p_effective_date    in  date,
                       p_rec               out nocopy g_ptnl_ler) is
  --
  l_proc           varchar2(80) := 'benutils.get_ptnl_ler';
  --
  cursor c_ptnl is
    select ptnl_ler_for_per_id,
           object_version_number
    from   ben_ptnl_ler_for_per ptn
    where  ptn.business_group_id  = p_business_group_id
    and    ptn.person_id = p_person_id
    and    ptn.ler_id = p_ler_id
    and    ptn.lf_evt_ocrd_dt = p_effective_date;
  --
begin
  --
  hr_utility.set_location('Leaving:'||l_proc, 5);
  --
  open c_ptnl;
    --
    fetch c_ptnl into p_rec;
    --
  close c_ptnl;
  --
  hr_utility.set_location('Leaving:'||l_proc, 5);
  --
end get_ptnl_ler;

------------------------------------------------------------------------
--  get_assignment_id
------------------------------------------------------------------------
function get_assignment_id(p_person_id         in number,
                           p_business_group_id in number,
                           p_effective_date    in date) return number is
  --
  l_proc          varchar2(80) := 'benutils.get_assignment_id';
  l_assignment_id number;
  --
  cursor c_assignment is
    select paf.assignment_id
    from   per_all_assignments_f paf, per_assignment_status_types pat
    where  paf.primary_flag = 'Y'
    and    paf.assignment_type <> 'C'
    and    paf.business_group_id = p_business_group_id
    and    paf.person_id = p_person_id
    and    paf.assignment_status_type_id = pat.assignment_status_type_id(+)
    and    pat.per_system_status(+) = 'ACTIVE_ASSIGN'
    and    p_effective_date between paf.effective_start_date and paf.effective_end_date
    and    hr_security.show_record ('PER_ALL_ASSIGNMENTS_F',
                                        paf.assignment_id,
                                        paf.person_id,
                                        paf.assignment_type
                                    )
                   = 'TRUE'
    order by assignment_type desc, effective_start_date desc;
  --
  cursor c_all_assignment is
    select paf.assignment_id
    from   per_all_assignments_f paf, per_assignment_status_types pat
    where  paf.primary_flag = 'Y'
    and    paf.assignment_type <> 'C'
    and    paf.business_group_id = p_business_group_id
    and    paf.person_id = p_person_id
    and    paf.assignment_status_type_id = pat.assignment_status_type_id(+)
    and    pat.per_system_status(+) = 'ACTIVE_ASSIGN'
    and    p_effective_date between paf.effective_start_date and paf.effective_end_date
    order by assignment_type desc, effective_start_date desc;
   --
begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  -- Perf changes
  if  hr_security.view_all =  'Y' and hr_general.get_xbg_profile = 'Y'
  then
      open c_all_assignment;
      --
      fetch c_all_assignment into l_assignment_id;
      --
      close c_all_assignment;
  else
      open c_assignment;
      --
      fetch c_assignment into l_assignment_id;
      --
      close c_assignment;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 5);
  --
  return l_assignment_id;
  --
end get_assignment_id;

------------------------------------------------------------------------
--  not_exists_in_hr_lookups
------------------------------------------------------------------------
function not_exists_in_hr_lookups(p_lookup_type in varchar2,
                                  p_lookup_code in varchar2) return boolean is
  --
  l_proc   varchar2(80) := 'benutils.not_exists_in_hr_lookups';
  --
begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Check if lookup type and lookup code can be found in cache structure
  --
  for l_count in g_cache_lookup_object.first..g_cache_lookup_object.last loop
    --
    if g_cache_lookup_object(l_count).lookup_type = p_lookup_type and
       g_cache_lookup_object(l_count).lookup_code = p_lookup_code then
      --
      hr_utility.set_location('Leaving:'||l_proc, 3);
      return false;
      --
    end if;
    --
  end loop;
  --
  hr_utility.set_location('Leaving:'||l_proc, 5);
  return true;
  --
end not_exists_in_hr_lookups;

------------------------------------------------------------------------
--  formula_exists
------------------------------------------------------------------------
function formula_exists(p_formula_id        in number,
                        p_formula_type_id   in number,
                        p_business_group_id in number,
                        p_effective_date    in date) return boolean is
  --
  l_proc   varchar2(80) := 'benutils.formula_exists';
  l_dummy  varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff,
           per_business_groups pbg
    where  ff.formula_id = p_formula_id
    and    ff.formula_type_id = p_formula_type_id
    and    pbg.business_group_id = p_business_group_id
    and    nvl(ff.business_group_id,p_business_group_id) =
           p_business_group_id
    and    nvl(ff.legislation_code,pbg.legislation_code) =
           pbg.legislation_code
    and    p_effective_date
           between ff.effective_start_date
           and     ff.effective_end_date;
  --
begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open c1;
    --
    fetch c1 into l_dummy;
    if c1%notfound then
      --
      close c1;
      hr_utility.set_location('Leaving:'||l_proc, 3);
      return false;
      --
    end if;
    --
  close c1;
  --
  hr_utility.set_location('Leaving:'||l_proc, 5);
  return true;
  --
end formula_exists;

------------------------------------------------------------------------
--  get_ler_name
------------------------------------------------------------------------
function get_ler_name(p_typ_cd            in varchar2,
                      p_business_group_id in number) return varchar2 is
  --
  cursor c1 is
    select ler.name
    from   ben_ler_f ler
    where  ler.business_group_id = p_business_group_id
    and    ler.typ_cd = p_typ_cd
    and    sysdate
           between ler.effective_start_date
           and     ler.effective_end_date;
  --
  l_name ben_ler_f.name%type; -- UTF8 Change Bug 2254683
begin
  --
  open c1;
    --
    fetch c1 into l_name;
    --
  close c1;
  --
  return l_name;
  --
end get_ler_name;

------------------------------------------------------------------------
--  set_cache_record_position
------------------------------------------------------------------------
procedure set_cache_record_position is
  --
  l_proc varchar2(80) := 'benutils.set_cache_record_position';
  --
begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);

  --  Set '_count' parms to indicate the last global record written
  -- to each global table for a particular person.

  g_report_table_count := nvl(g_report_table_object.count,0);
  g_batch_elig_table_count := nvl(g_batch_elig_table_object.count,0);
  g_batch_rate_table_count := nvl(g_batch_rate_table_object.count,0);
  g_batch_dpnt_table_count := nvl(g_batch_dpnt_table_object.count,0);
  g_batch_ler_table_count := nvl(g_batch_ler_table_object.count,0);
  g_batch_action_table_count := nvl(g_batch_action_table_object.count,0);
  g_batch_elctbl_table_count := nvl(g_batch_elctbl_table_object.count,0);
  g_batch_commu_table_count  := nvl(g_batch_commu_table_object.count,0);

  ben_warnings.g_oab_warnings_count := nvl(ben_warnings.g_oab_warnings.count, 0);
  --
  hr_utility.set_location('Leaving:'||l_proc, 5);
  --
end set_cache_record_position;

------------------------------------------------------------------------
--  rollback_cache
------------------------------------------------------------------------
procedure rollback_cache is
  --
  l_proc varchar2(80) := 'benutils.rollback_cache';
  --
begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  -- The '_count' parms are set in set_cache_record_position above each
  -- time we finish with a person.  It indicates the last record written
  -- for a person.
  -- The '.count' function returns the last record written.  We esentially
  -- are rolling back the global records to the last record written for the
  -- last person that didn't error.
  --
  if g_batch_elig_table_count > 0 then
    --
    g_batch_elig_table_object.trim(g_batch_elig_table_object.count-
                                   g_batch_elig_table_count+1);
    --
  end if;
  --
  if g_batch_ler_table_count > 0 then
    --
    g_batch_ler_table_object.trim(g_batch_ler_table_object.count-
                                  g_batch_ler_table_count);
    --
  end if;
  --
  if g_batch_action_table_count > 0 then
    --
    g_batch_action_table_object.trim(g_batch_action_table_object.count-
                                     g_batch_action_table_count);
    --
  end if;
  --
  if g_batch_elctbl_table_count > 0 then
    --
    g_batch_elctbl_table_object.trim(g_batch_elctbl_table_object.count-
                                     g_batch_elctbl_table_count);
    --
  end if;
  --
  if g_batch_rate_table_count > 0 then
    --
    g_batch_rate_table_object.trim(g_batch_rate_table_object.count-
                                   g_batch_rate_table_count);
    --
  end if;
  --
  if g_batch_dpnt_table_count > 0 then
    --
    g_batch_dpnt_table_object.trim(g_batch_dpnt_table_object.count-
                                   g_batch_dpnt_table_count);
    --
  end if;
  --
  if g_batch_commu_table_count > 0 then
    --
    g_batch_commu_table_object.trim(g_batch_commu_table_object.count-
                                    g_batch_commu_table_count);
    --
  end if;

  if ben_warnings.g_oab_warnings_count > 0 then
     ben_warnings.trim_warnings
                (ben_warnings.g_oab_warnings.count-
                 ben_warnings.g_oab_warnings_count);
  end if;

  hr_utility.set_location('Leaving:'||l_proc, 5);
end rollback_cache;
--
procedure clear_down_cache is
  --
begin
  --
  g_report_table_object.delete;
  g_batch_elig_table_object.delete;
  g_batch_ler_table_object.delete;
  g_batch_proc_table_object.delete;
  g_batch_action_table_object.delete;
  g_batch_elctbl_table_object.delete;
  g_batch_rate_table_object.delete;
  g_batch_dpnt_table_object.delete;
  g_batch_commu_table_object.delete;
  --
end clear_down_cache;
------------------------------------------------------------------------
--  write_table_and_file
------------------------------------------------------------------------
procedure write_table_and_file(p_table          in boolean ,
                               p_file           in boolean ) is
  --
  l_proc       varchar2(80) := 'benutils.write_table_and_file';
  l_num1_col   g_number_table := g_number_table();
  l_num2_col   g_number_table := g_number_table();
  l_num3_col   g_number_table := g_number_table();
  l_num4_col   g_number_table := g_number_table();
  l_num5_col   g_number_table := g_number_table();
  l_num6_col   g_number_table := g_number_table();
  l_num7_col   g_number_table := g_number_table();
  l_num8_col   g_number_table := g_number_table();
  l_num9_col   g_number_table := g_number_table();
  l_num10_col  g_number_table := g_number_table();
  l_num11_col  g_number_table := g_number_table();
  l_num12_col  g_number_table := g_number_table();
  l_num13_col  g_number_table := g_number_table();
  l_num14_col  g_number_table := g_number_table();
  l_num15_col  g_number_table := g_number_table();
  l_num16_col  g_number_table := g_number_table();
  l_num17_col  g_number_table := g_number_table();
  l_num18_col  g_number_table := g_number_table();
  l_var1_col   g_varchar2_table := g_varchar2_table();
  l_var2_col   g_varchar2_table := g_varchar2_table();
  l_var3_col   g_varchar2_table := g_varchar2_table();
  l_var4_col   g_varchar2_table := g_varchar2_table();
  l_var5_col   g_varchar2_table := g_varchar2_table();
  l_var6_col   g_varchar2_table := g_varchar2_table();
  l_var7_col   g_varchar2_table := g_varchar2_table();
  l_var8_col   g_varchar2_table := g_varchar2_table();
  l_var9_col   g_varchar2_table := g_varchar2_table();
  l_var10_col  g_varchar2_table := g_varchar2_table();
  l_var11_col  g_varchar2_table := g_varchar2_table();
  l_var12_col  g_varchar2_table := g_varchar2_table();
  l_dat1_col   g_date_table := g_date_table();
  l_dat2_col   g_date_table := g_date_table();
  l_dat3_col   g_date_table := g_date_table();
  l_dat4_col   g_date_table := g_date_table();
  l_dat5_col   g_date_table := g_date_table();
  l_num_recs   number;
  l_table_name varchar2(30);
  --
  --
  table_full EXCEPTION;
  index_full EXCEPTION;
  --
  pragma exception_init(table_full,-1653);
  pragma exception_init(index_full,-1654);
begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Loop through cache routine and write to ben_reporting table and
  -- to the output file
  --
  if p_table = false and
     p_file = false then
    --
    hr_utility.set_location('Leaving:'||l_proc, 2);
    return;
    --
  end if;

  ben_warnings.write_warnings_batch ;

  if nvl(g_report_table_object.count,0) > 0 then
    --
    l_num_recs := g_report_table_object.count;
    --
    for l_count in 1..l_num_recs loop
      --
      if fnd_global.conc_request_id <> -1 and p_file then
        --
        fnd_file.put_line
           (which => fnd_file.log,
            buff  => g_report_table_object(l_count).text);
        --
      end if;
      --
      if p_table then
        --
        -- Copy all varray to single column varrays.
        --
        l_num1_col.extend(1);
        --
        select ben_reporting_s.nextval into
        l_num1_col(l_count)
        from sys.dual;
/*
        l_num1_col(l_count) :=
          g_report_table_object(l_count).reporting_id;
*/
        l_num2_col.extend(1);
        l_num2_col(l_count) :=
          g_report_table_object(l_count).benefit_action_id;
        l_num3_col.extend(1);
        l_num3_col(l_count) :=
          g_report_table_object(l_count).thread_id;
        l_num4_col.extend(1);
        l_num4_col(l_count) :=
          g_report_table_object(l_count).sequence;
        l_var1_col.extend(1);
        l_var1_col(l_count) :=
          g_report_table_object(l_count).text;
        l_num5_col.extend(1);
        l_num5_col(l_count) :=
          g_report_table_object(l_count).object_version_number;
        l_var2_col.extend(1);
        l_var2_col(l_count) :=
          g_report_table_object(l_count).rep_typ_cd;
        l_var3_col.extend(1);
        l_var3_col(l_count) :=
          g_report_table_object(l_count).error_message_code;
        l_var4_col.extend(1);
        l_var4_col(l_count) :=
          g_report_table_object(l_count).national_identifier;
        l_num6_col.extend(1);
        l_num6_col(l_count) :=
          g_report_table_object(l_count).related_person_ler_id;
        l_num7_col.extend(1);
        l_num7_col(l_count) :=
          g_report_table_object(l_count).temporal_ler_id;
        l_num8_col.extend(1);
        l_num8_col(l_count) :=
          g_report_table_object(l_count).ler_id;
        l_num9_col.extend(1);
        l_num9_col(l_count) :=
          g_report_table_object(l_count).person_id;
        l_num10_col.extend(1);
        l_num10_col(l_count) :=
          g_report_table_object(l_count).pgm_id;
        l_num11_col.extend(1);
        l_num11_col(l_count) :=
          g_report_table_object(l_count).pl_id;
        l_num12_col.extend(1);
        l_num12_col(l_count) :=
          g_report_table_object(l_count).related_person_id;
        l_num13_col.extend(1);
        l_num13_col(l_count) :=
          g_report_table_object(l_count).oipl_id;
        l_num14_col.extend(1);
        l_num14_col(l_count) :=
          g_report_table_object(l_count).pl_typ_id;
        l_num15_col.extend(1);
        l_num15_col(l_count) :=
          g_report_table_object(l_count).actl_prem_id;
        l_num16_col.extend(1);
        l_num16_col(l_count) :=
          g_report_table_object(l_count).val;
        l_num17_col.extend(1);
        l_num17_col(l_count) :=
          g_report_table_object(l_count).mo_num;
        l_num18_col.extend(1);
        l_num18_col(l_count) :=
          g_report_table_object(l_count).yr_num;
        --
      end if;
      --
    end loop;
    --
    if p_table then
      --
      hr_utility.set_location('BEN_REP Ins: '||l_proc, 6);
      l_table_name := 'BEN_REPORTING';
      forall l_count in 1..l_num_recs
        insert into ben_reporting
          (reporting_id,
           benefit_action_id,
           thread_id,
           sequence,
           text,
           object_version_number,
           rep_typ_cd,
           error_message_code,
           national_identifier,
           related_person_ler_id,
           temporal_ler_id,
           ler_id,
           person_id,
           pgm_id,
           pl_id,
           related_person_id,
           oipl_id,
           pl_typ_id,
           actl_prem_id,
           val,
           mo_num,
           yr_num)
         values
          (l_num1_col(l_count),
           l_num2_col(l_count),
           l_num3_col(l_count),
           l_num4_col(l_count),
           l_var1_col(l_count),
           l_num5_col(l_count),
           l_var2_col(l_count),
           l_var3_col(l_count),
           l_var4_col(l_count),
           l_num6_col(l_count),
           l_num7_col(l_count),
           l_num8_col(l_count),
           l_num9_col(l_count),
           l_num10_col(l_count),
           l_num11_col(l_count),
           l_num12_col(l_count),
           l_num13_col(l_count),
           l_num14_col(l_count),
           l_num15_col(l_count),
           l_num16_col(l_count),
           l_num17_col(l_count),
           l_num18_col(l_count));
      hr_utility.set_location('Dn BEN_REP Ins: '||l_proc, 7);
      --
    end if;
    --
    g_report_table_object.delete;
    --
  end if;
  --
  --
  hr_utility.set_location(l_proc||' Elig: ', 10);
  if nvl(g_batch_elig_table_object.count,0) > 0 then
    --
    if p_table then
      --
      -- Clear any existing host varrays
      --
      l_num1_col.delete;
      l_num2_col.delete;
      l_num3_col.delete;
      l_num4_col.delete;
      l_num5_col.delete;
      l_num6_col.delete;
      l_num7_col.delete;
      l_num8_col.delete;
      l_var1_col.delete;
      l_var2_col.delete;
      l_num_recs := g_batch_elig_table_object.count;
      --
      for l_count in 1..l_num_recs loop
        --
        -- Copy varrays to singular varrays
        --
        l_num1_col.extend(1);
        l_num1_col(l_count) :=
          g_batch_elig_table_object(l_count).batch_elig_id;
        l_num2_col.extend(1);
        l_num2_col(l_count) :=
          g_batch_elig_table_object(l_count).benefit_action_id;
        l_num3_col.extend(1);
        l_num3_col(l_count) :=
          g_batch_elig_table_object(l_count).person_id;
        l_num4_col.extend(1);
        l_num4_col(l_count) :=
          g_batch_elig_table_object(l_count).pgm_id;
        l_num5_col.extend(1);
        l_num5_col(l_count) :=
          g_batch_elig_table_object(l_count).pl_id;
        l_num6_col.extend(1);
        l_num6_col(l_count) :=
          g_batch_elig_table_object(l_count).oipl_id;
        l_var1_col.extend(1);
        l_var1_col(l_count) :=
          g_batch_elig_table_object(l_count).elig_flag;
        l_var2_col.extend(1);
        l_var2_col(l_count) :=
          g_batch_elig_table_object(l_count).inelig_text;
        l_num7_col.extend(1);
        l_num7_col(l_count) :=
          g_batch_elig_table_object(l_count).business_group_id;
        l_num8_col.extend(1);
        l_num8_col(l_count) :=
          g_batch_elig_table_object(l_count).object_version_number;
        --
      end loop;
      --
      -- Bind and populate table
      --
      l_table_name :='BEN_BATCH_ELIG_INFO';
      forall l_count in 1..l_num_recs
        --
        insert into ben_batch_elig_info
          (batch_elig_id,
           benefit_action_id,
           person_id,
           pgm_id,
           pl_id,
           oipl_id,
           elig_flag,
           inelig_text,
           business_group_id,
           object_version_number)
        values
          (l_num1_col(l_count),
           l_num2_col(l_count),
           l_num3_col(l_count),
           l_num4_col(l_count),
           l_num5_col(l_count),
           l_num6_col(l_count),
           l_var1_col(l_count),
           l_var2_col(l_count),
           l_num7_col(l_count),
           l_num8_col(l_count));
      --
    end if;
    --
    g_batch_elig_table_object.delete;
    --
  end if;
  --
  hr_utility.set_location(l_proc||' Ler: ', 20);
  if nvl(g_batch_ler_table_object.count,0) > 0 then
    --
    if p_table then
      --
      l_num1_col.delete;
      l_num2_col.delete;
      l_num3_col.delete;
      l_num4_col.delete;
      l_num5_col.delete;
      l_num6_col.delete;
      l_num7_col.delete;
      l_var1_col.delete;
      l_var2_col.delete;
      l_var3_col.delete;
      l_var4_col.delete;
      l_var5_col.delete;
      l_var6_col.delete;
      l_var7_col.delete;
      l_var8_col.delete;
      l_var9_col.delete;
      l_var10_col.delete;
      l_var11_col.delete;
      l_var12_col.delete;
      l_dat1_col.delete;
      l_num_recs := g_batch_ler_table_object.count;
      --
      for l_count in 1..l_num_recs loop
        --
        l_num1_col.extend(1);
        l_num1_col(l_count) :=
          g_batch_ler_table_object(l_count).batch_ler_id;
        l_num2_col.extend(1);
        l_num2_col(l_count) :=
          g_batch_ler_table_object(l_count).benefit_action_id;
        l_num3_col.extend(1);
        l_num3_col(l_count) :=
          g_batch_ler_table_object(l_count).person_id;
        l_num4_col.extend(1);
        l_num4_col(l_count) :=
          g_batch_ler_table_object(l_count).ler_id;
        l_dat1_col.extend(1);
        l_dat1_col(l_count) :=
          g_batch_ler_table_object(l_count).lf_evt_ocrd_dt;
        l_var1_col.extend(1);
        l_var1_col(l_count) :=
          g_batch_ler_table_object(l_count).replcd_flag;
        l_var2_col.extend(1);
        l_var2_col(l_count) :=
          g_batch_ler_table_object(l_count).crtd_flag;
        l_var3_col.extend(1);
        l_var3_col(l_count) :=
          g_batch_ler_table_object(l_count).tmprl_flag;
        l_var4_col.extend(1);
        l_var4_col(l_count) :=
          g_batch_ler_table_object(l_count).dltd_flag;
        l_var5_col.extend(1);
        l_var5_col(l_count) :=
          g_batch_ler_table_object(l_count).open_and_clsd_flag;
        l_var6_col.extend(1);
        l_var6_col(l_count) :=
          g_batch_ler_table_object(l_count).not_crtd_flag;
        l_var7_col.extend(1);
        l_var7_col(l_count) :=
          g_batch_ler_table_object(l_count).stl_actv_flag;
        l_var8_col.extend(1);
        l_var8_col(l_count) :=
          g_batch_ler_table_object(l_count).clsd_flag;
        l_var9_col.extend(1);
        l_var9_col(l_count) :=
          g_batch_ler_table_object(l_count).clpsd_flag;
        l_var10_col.extend(1);
        l_var10_col(l_count) :=
          g_batch_ler_table_object(l_count).clsn_flag;
        l_var11_col.extend(1);
        l_var11_col(l_count) :=
          g_batch_ler_table_object(l_count).no_effect_flag;
        l_var12_col.extend(1);
        l_var12_col(l_count) :=
          g_batch_ler_table_object(l_count).cvrge_rt_prem_flag;
        l_num5_col.extend(1);
        l_num5_col(l_count) :=
          g_batch_ler_table_object(l_count).per_in_ler_id;
        l_num6_col.extend(1);
        l_num6_col(l_count) :=
          g_batch_ler_table_object(l_count).business_group_id;
        l_num7_col.extend(1);
        l_num7_col(l_count) :=
          g_batch_ler_table_object(l_count).object_version_number;
        --
      end loop;
      --
      -- Bulk bind and insert
      --
      l_table_name :='BEN_BATCH_LER_INFO';
      forall l_count in 1..l_num_recs
        --
        insert into ben_batch_ler_info
          (batch_ler_id,
           benefit_action_id,
           person_id,
           ler_id,
           lf_evt_ocrd_dt,
           replcd_flag,
           crtd_flag,
           tmprl_flag,
           dltd_flag,
           open_and_clsd_flag,
           not_crtd_flag,
           stl_actv_flag,
           clsd_flag,
           clpsd_flag,
           clsn_flag,
           no_effect_flag,
           cvrge_rt_prem_flag,
           per_in_ler_id,
           business_group_id,
           object_version_number)
        values
          (l_num1_col(l_count),
           l_num2_col(l_count),
           l_num3_col(l_count),
           l_num4_col(l_count),
           l_dat1_col(l_count),
           l_var1_col(l_count),
           l_var2_col(l_count),
           l_var3_col(l_count),
           l_var4_col(l_count),
           l_var5_col(l_count),
           l_var6_col(l_count),
           l_var7_col(l_count),
           l_var8_col(l_count),
           l_var9_col(l_count),
           l_var10_col(l_count),
           l_var11_col(l_count),
           l_var12_col(l_count),
           l_num5_col(l_count),
           l_num6_col(l_count),
           l_num7_col(l_count));
      --
    end if;
    --
    g_batch_ler_table_object.delete;
    --
  end if;
  --
  hr_utility.set_location(l_proc||' Action: ', 30);
  if nvl(g_batch_action_table_object.count,0) > 0 then
    --
    if p_table then
      --
      l_num1_col.delete;
      l_var1_col.delete;
      l_num2_col.delete;
      l_num_recs := g_batch_action_table_object.count;
      --
      for l_count in 1..l_num_recs loop
        --
        l_num1_col.extend(1);
        l_num1_col(l_count) :=
          g_batch_action_table_object(l_count).person_action_id;
        l_var1_col.extend(1);
        l_var1_col(l_count) :=
          g_batch_action_table_object(l_count).action_status_cd;
        l_num2_col.extend(1);
        l_num2_col(l_count) :=
          g_batch_action_table_object(l_count).object_version_number+1;
        --
      end loop;
      --
      forall l_count in 1..l_num_recs
        --
        update ben_person_actions
        set   action_status_cd = l_var1_col(l_count),
              object_version_number = l_num2_col(l_count)
        where person_action_id = l_num1_col(l_count);
        --
    end if;
    --
    g_batch_action_table_object.delete;
    --
  end if;
  --
  hr_utility.set_location(l_proc||' elctbl: ', 40);
  if nvl(g_batch_elctbl_table_object.count,0) > 0 then
    --
    if p_table then
      --
      l_num1_col.delete;
      l_num2_col.delete;
      l_num3_col.delete;
      l_num4_col.delete;
      l_num5_col.delete;
      l_num6_col.delete;
      l_num7_col.delete;
      l_num8_col.delete;
      l_var1_col.delete;
      l_var2_col.delete;
      l_var3_col.delete;
      l_var4_col.delete;
      l_dat1_col.delete;
      l_dat2_col.delete;
      l_dat3_col.delete;
      l_dat4_col.delete;
      l_dat5_col.delete;
      l_num_recs := g_batch_elctbl_table_object.count;
      --
      for l_count in 1..l_num_recs loop
        --
        l_num1_col.extend(1);
        l_num1_col(l_count) :=
          g_batch_elctbl_table_object(l_count).batch_elctbl_id;
        l_num2_col.extend(1);
        l_num2_col(l_count) :=
          g_batch_elctbl_table_object(l_count).benefit_action_id;
        l_num3_col.extend(1);
        l_num3_col(l_count) :=
          g_batch_elctbl_table_object(l_count).person_id;
        l_num4_col.extend(1);
        l_num4_col(l_count) :=
          g_batch_elctbl_table_object(l_count).pgm_id;
        l_num5_col.extend(1);
        l_num5_col(l_count) :=
          g_batch_elctbl_table_object(l_count).pl_id;
        l_num6_col.extend(1);
        l_num6_col(l_count) :=
          g_batch_elctbl_table_object(l_count).oipl_id;
        l_dat1_col.extend(1);
        l_dat1_col(l_count) :=
          g_batch_elctbl_table_object(l_count).enrt_cvg_strt_dt;
        l_dat2_col.extend(1);
        l_dat2_col(l_count) :=
          g_batch_elctbl_table_object(l_count).enrt_perd_strt_dt;
        l_dat3_col.extend(1);
        l_dat3_col(l_count) :=
          g_batch_elctbl_table_object(l_count).enrt_perd_end_dt;
        l_dat4_col.extend(1);
        l_dat4_col(l_count) :=
          g_batch_elctbl_table_object(l_count).erlst_deenrt_dt;
        l_dat5_col.extend(1);
        l_dat5_col(l_count) :=
          g_batch_elctbl_table_object(l_count).dflt_enrt_dt;
        l_var1_col.extend(1);
        l_var1_col(l_count) :=
          g_batch_elctbl_table_object(l_count).enrt_typ_cycl_cd;
        l_var2_col.extend(1);
        l_var2_col(l_count) :=
          g_batch_elctbl_table_object(l_count).comp_lvl_cd;
        l_var3_col.extend(1);
        l_var3_col(l_count) :=
          g_batch_elctbl_table_object(l_count).mndtry_flag;
        l_var4_col.extend(1);
        l_var4_col(l_count) :=
          g_batch_elctbl_table_object(l_count).dflt_flag;
        l_num7_col.extend(1);
        l_num7_col(l_count) :=
          g_batch_elctbl_table_object(l_count).business_group_id;
        l_num8_col.extend(1);
        l_num8_col(l_count) :=
          g_batch_elctbl_table_object(l_count).object_version_number;
        --
      end loop;
      --
      l_table_name := 'BEN_BATCH_ELCTBL_CHC_INFO';
      forall l_count in 1..l_num_recs
        --
        insert into ben_batch_elctbl_chc_info
          (batch_elctbl_id,
           benefit_action_id,
           person_id,
           pgm_id,
           pl_id,
           oipl_id,
           enrt_cvg_strt_dt,
           enrt_perd_strt_dt,
           enrt_perd_end_dt,
           erlst_deenrt_dt,
           dflt_enrt_dt,
           enrt_typ_cycl_cd,
           comp_lvl_cd,
           mndtry_flag,
           dflt_flag,
           business_group_id,
           object_version_number)
        values
          (l_num1_col(l_count),
           l_num2_col(l_count),
           l_num3_col(l_count),
           l_num4_col(l_count),
           l_num5_col(l_count),
           l_num6_col(l_count),
           l_dat1_col(l_count),
           l_dat2_col(l_count),
           l_dat3_col(l_count),
           l_dat4_col(l_count),
           l_dat5_col(l_count),
           l_var1_col(l_count),
           l_var2_col(l_count),
           l_var3_col(l_count),
           l_var4_col(l_count),
           l_num7_col(l_count),
           l_num8_col(l_count));
        --
    end if;
    --
    g_batch_elctbl_table_object.delete;
    --
  end if;
  --
  hr_utility.set_location(l_proc||' rate: ', 50);
  if nvl(g_batch_rate_table_object.count,0) > 0 then
    --
    if p_table then
      --
      l_num1_col.delete;
      l_num2_col.delete;
      l_num3_col.delete;
      l_num4_col.delete;
      l_num5_col.delete;
      l_num6_col.delete;
      l_num7_col.delete;
      l_num8_col.delete;
      l_num9_col.delete;
      l_num10_col.delete;
      l_num11_col.delete;
      l_num12_col.delete;
      l_num13_col.delete;
      l_num14_col.delete;
      l_var1_col.delete;
      l_var2_col.delete;
      l_var3_col.delete;
      l_var4_col.delete;
      l_var5_col.delete;
      l_dat1_col.delete;
      l_dat2_col.delete;
      l_dat3_col.delete;
      l_dat4_col.delete;
      l_num_recs := g_batch_rate_table_object.count;
      --
      hr_utility.set_location('batch rate'||l_num_recs,3333);
      for l_count in 1..l_num_recs loop
        --
        l_num1_col.extend(1);
        l_num1_col(l_count) :=
          g_batch_rate_table_object(l_count).batch_rt_id;
        l_num2_col.extend(1);
        l_num2_col(l_count) :=
          g_batch_rate_table_object(l_count).benefit_action_id;
        l_num3_col.extend(1);
        l_num3_col(l_count) :=
          g_batch_rate_table_object(l_count).person_id;
        l_num4_col.extend(1);
        l_num4_col(l_count) :=
          g_batch_rate_table_object(l_count).pgm_id;
        l_num5_col.extend(1);
        l_num5_col(l_count) :=
          g_batch_rate_table_object(l_count).pl_id;
        l_num6_col.extend(1);
        l_num6_col(l_count) :=
          g_batch_rate_table_object(l_count).oipl_id;
        l_var1_col.extend(1);
        l_var1_col(l_count) :=
          g_batch_rate_table_object(l_count).bnft_rt_typ_cd;
        l_var2_col.extend(1);
        l_var2_col(l_count) :=
          g_batch_rate_table_object(l_count).dflt_flag;
        l_num7_col.extend(1);
        l_num7_col(l_count) :=
          g_batch_rate_table_object(l_count).val;
        l_var3_col.extend(1);
        l_var3_col(l_count) :=
          g_batch_rate_table_object(l_count).tx_typ_cd;
        l_var4_col.extend(1);
        l_var4_col(l_count) :=
          g_batch_rate_table_object(l_count).acty_typ_cd;
        l_num8_col.extend(1);
        l_num8_col(l_count) :=
          g_batch_rate_table_object(l_count).mn_elcn_val;
        l_num9_col.extend(1);
        l_num9_col(l_count) :=
          g_batch_rate_table_object(l_count).mx_elcn_val;
        l_num10_col.extend(1);
        l_num10_col(l_count) :=
          g_batch_rate_table_object(l_count).incrmt_elcn_val;
        l_num11_col.extend(1);
        l_num11_col(l_count) :=
          g_batch_rate_table_object(l_count).dflt_val;
        l_dat1_col.extend(1);
        l_dat1_col(l_count) :=
          g_batch_rate_table_object(l_count).rt_strt_dt;
        l_dat2_col.extend(1);
        l_dat2_col(l_count) :=
          g_batch_rate_table_object(l_count).enrt_cvg_strt_dt;
        l_dat3_col.extend(1);
        l_dat3_col(l_count) :=
          g_batch_rate_table_object(l_count).enrt_cvg_thru_dt;
        l_var5_col.extend(1);
        l_var5_col(l_count) :=
          g_batch_rate_table_object(l_count).actn_cd;
        l_dat4_col.extend(1);
        l_dat4_col(l_count) :=
          g_batch_rate_table_object(l_count).close_actn_itm_dt;
        l_num12_col.extend(1);
        l_num12_col(l_count) :=
          g_batch_rate_table_object(l_count).business_group_id;
        l_num13_col.extend(1);
        l_num13_col(l_count) :=
          g_batch_rate_table_object(l_count).object_version_number;
        l_num14_col.extend(1);
        l_num14_col(l_count) :=
          g_batch_rate_table_object(l_count).old_val;
        --
       hr_utility.set_location(l_proc||' rate: ' ||
                               g_batch_rate_table_object(l_count).old_val, 1111);
      end loop;
      --
      l_table_name :='BEN_BATCH_RATE_INFO';
      forall l_count in 1..l_num_recs
        --
        insert into ben_batch_rate_info
          (batch_rt_id,
           benefit_action_id,
           person_id,
           pgm_id,
           pl_id,
           oipl_id,
           bnft_rt_typ_cd,
           dflt_flag,
           val,
           tx_typ_cd,
           acty_typ_cd,
           mn_elcn_val,
           mx_elcn_val,
           incrmt_elcn_val,
           dflt_val,
           rt_strt_dt,
           enrt_cvg_strt_dt,
           enrt_cvg_thru_dt,
           actn_cd,
           close_actn_itm_dt,
           business_group_id,
           object_version_number,
           old_val)
        values
          (l_num1_col(l_count),
           l_num2_col(l_count),
           l_num3_col(l_count),
           l_num4_col(l_count),
           l_num5_col(l_count),
           l_num6_col(l_count),
           l_var1_col(l_count),
           l_var2_col(l_count),
           l_num7_col(l_count),
           l_var3_col(l_count),
           l_var4_col(l_count),
           l_num8_col(l_count),
           l_num9_col(l_count),
           l_num10_col(l_count),
           l_num11_col(l_count),
           l_dat1_col(l_count),
           l_dat2_col(l_count),
           l_dat3_col(l_count),
           l_var5_col(l_count),
           l_dat4_col(l_count),
           l_num12_col(l_count),
           l_num13_col(l_count),
           l_num14_col(l_count));
      --
    end if;
    --
    g_batch_rate_table_object.delete;
    --
  end if;
  --
  hr_utility.set_location(l_proc||' dpnt: ', 60);
  if nvl(g_batch_dpnt_table_object.count,0) > 0 then
    --
    if p_table then
      --
      l_num1_col.delete;
      l_num2_col.delete;
      l_num3_col.delete;
      l_num4_col.delete;
      l_num5_col.delete;
      l_num6_col.delete;
      l_num7_col.delete;
      l_num8_col.delete;
      l_num9_col.delete;
      l_var1_col.delete;
      l_var2_col.delete;
      l_dat1_col.delete;
      l_dat2_col.delete;
      --
      for l_count in g_batch_dpnt_table_object.first..
                     g_batch_dpnt_table_object.last loop
        --
        l_num1_col.extend(1);
        l_num1_col(l_count) :=
          g_batch_dpnt_table_object(l_count).batch_dpnt_id;
        l_num2_col.extend(1);
        l_num2_col(l_count) :=
          g_batch_dpnt_table_object(l_count).benefit_action_id;
        l_num3_col.extend(1);
        l_num3_col(l_count) :=
          g_batch_dpnt_table_object(l_count).person_id;
        l_num4_col.extend(1);
        l_num4_col(l_count) :=
          g_batch_dpnt_table_object(l_count).pgm_id;
        l_num5_col.extend(1);
        l_num5_col(l_count) :=
          g_batch_dpnt_table_object(l_count).pl_id;
        l_num6_col.extend(1);
        l_num6_col(l_count) :=
          g_batch_dpnt_table_object(l_count).oipl_id;
        l_var1_col.extend(1);
        l_var1_col(l_count) :=
          g_batch_dpnt_table_object(l_count).contact_typ_cd;
        l_num7_col.extend(1);
        l_num7_col(l_count) :=
          g_batch_dpnt_table_object(l_count).dpnt_person_id;
        l_dat1_col.extend(1);
        l_dat1_col(l_count) :=
          g_batch_dpnt_table_object(l_count).enrt_cvg_strt_dt;
        l_dat2_col.extend(1);
        l_dat2_col(l_count) :=
          g_batch_dpnt_table_object(l_count).enrt_cvg_thru_dt;
        l_var2_col.extend(1);
        l_var2_col(l_count) :=
          g_batch_dpnt_table_object(l_count).actn_cd;
        l_num8_col.extend(1);
        l_num8_col(l_count) :=
          g_batch_dpnt_table_object(l_count).business_group_id;
        l_num9_col.extend(1);
        l_num9_col(l_count) :=
          g_batch_dpnt_table_object(l_count).object_version_number;
        --
      end loop;
      --
      l_table_name :='BEN_BATCH_DPNT_INFO';
      forall l_count in g_batch_dpnt_table_object.first..
                        g_batch_dpnt_table_object.last
        --
        insert into ben_batch_dpnt_info
          (batch_dpnt_id,
           benefit_action_id,
           person_id,
           pgm_id,
           pl_id,
           oipl_id,
           contact_typ_cd,
           dpnt_person_id,
           enrt_cvg_strt_dt,
           enrt_cvg_thru_dt,
           actn_cd,
           business_group_id,
           object_version_number)
        values
          (l_num1_col(l_count),
           l_num2_col(l_count),
           l_num3_col(l_count),
           l_num4_col(l_count),
           l_num5_col(l_count),
           l_num6_col(l_count),
           l_var1_col(l_count),
           l_num7_col(l_count),
           l_dat1_col(l_count),
           l_dat2_col(l_count),
           l_var2_col(l_count),
           l_num8_col(l_count),
           l_num9_col(l_count));
      --
    end if;
    --
    g_batch_dpnt_table_object.delete;
    --
  end if;
  --
  hr_utility.set_location(l_proc||' commu: ', 70);
  if nvl(g_batch_commu_table_object.count,0) > 0 then
    --
    if p_table then
      --
      l_num1_col.delete;
      l_num2_col.delete;
      l_num3_col.delete;
      l_num4_col.delete;
      l_num5_col.delete;
      l_num6_col.delete;
      l_dat1_col.delete;
      l_num7_col.delete;
      l_num8_col.delete;
      --
      for l_count in g_batch_commu_table_object.first..
                     g_batch_commu_table_object.last loop
        --
        l_num1_col.extend(1);
        l_num1_col(l_count) :=
          g_batch_commu_table_object(l_count).batch_commu_id;
        l_num2_col.extend(1);
        l_num2_col(l_count) :=
          g_batch_commu_table_object(l_count).benefit_action_id;
        l_num3_col.extend(1);
        l_num3_col(l_count) :=
          g_batch_commu_table_object(l_count).person_id;
        l_num4_col.extend(1);
        l_num4_col(l_count) :=
          g_batch_commu_table_object(l_count).per_cm_id;
        l_num5_col.extend(1);
        l_num5_col(l_count) :=
          g_batch_commu_table_object(l_count).cm_typ_id;
        l_num6_col.extend(1);
        l_num6_col(l_count) :=
          g_batch_commu_table_object(l_count).per_cm_prvdd_id;
        l_dat1_col.extend(1);
        l_dat1_col(l_count) :=
          g_batch_commu_table_object(l_count).to_be_sent_dt;
        l_num7_col.extend(1);
        l_num7_col(l_count) :=
          g_batch_commu_table_object(l_count).business_group_id;
        l_num8_col.extend(1);
        l_num8_col(l_count) :=
          g_batch_commu_table_object(l_count).object_version_number;
        --
      end loop;
      --
      l_table_name :='BEN_BATCH_COMMU_INFO';
      forall l_count in g_batch_commu_table_object.first..
                        g_batch_commu_table_object.last
        --
        insert into ben_batch_commu_info
          (batch_commu_id,
           benefit_action_id,
           person_id,
           per_cm_id,
           cm_typ_id,
           per_cm_prvdd_id,
           to_be_sent_dt,
           business_group_id,
           object_version_number)
        values
          (l_num1_col(l_count),
           l_num2_col(l_count),
           l_num3_col(l_count),
           l_num4_col(l_count),
           l_num5_col(l_count),
           l_num6_col(l_count),
           l_dat1_col(l_count),
           l_num7_col(l_count),
           l_num8_col(l_count));
      --
    end if;
    --
    g_batch_commu_table_object.delete;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 5);
  --
  exception
    when table_full then
        fnd_message.set_name('BEN','BEN_92651_LOG_TABLE_FULL');
        fnd_message.set_token('TABLE_NAME',l_table_name);
        raise;
    when index_full then
        fnd_message.set_name('BEN','BEN_92652_LOG_INDEX_FULL');
        fnd_message.set_token('INDEX_NAME',l_table_name);
        raise;
    when others then
        raise;
end write_table_and_file;

------------------------------------------------------------------------
--  write
------------------------------------------------------------------------
procedure write(p_rec in out nocopy ben_type.g_report_rec) is
  --
  l_reporting_id          number(38);
  l_object_version_number number(38);
  l_proc                  varchar2(80) := 'benutils.write 1';
  l_rec                   ben_type.g_report_rec;
  l_count                 number := 1;
  --
begin
  --
--  hr_utility.set_location('Entering:'||l_proc, 5);
--  hr_utility.set_location(substr(p_rec.text,1,100),10);
  --
  g_sequence := g_sequence +1;
  --
  g_report_table_object.extend(1);
  l_count := g_report_table_object.count;
/*
  select ben_reporting_s.nextval into
  g_report_table_object(l_count).reporting_id
  from sys.dual;
*/
  g_report_table_object(l_count).reporting_id := null;
  g_report_table_object(l_count).benefit_action_id := g_benefit_action_id;
  g_report_table_object(l_count).thread_id := g_thread_id;
  g_report_table_object(l_count).sequence := g_sequence;
  g_report_table_object(l_count).text := p_rec.text;
  g_report_table_object(l_count).rep_typ_cd := p_rec.rep_typ_cd;
  g_report_table_object(l_count).error_message_code := p_rec.error_message_code;
  g_report_table_object(l_count).national_identifier := p_rec.national_identifier;
  g_report_table_object(l_count).related_person_ler_id := p_rec.related_person_ler_id;
  g_report_table_object(l_count).temporal_ler_id := p_rec.temporal_ler_id;
  g_report_table_object(l_count).ler_id := p_rec.ler_id;
  g_report_table_object(l_count).person_id := p_rec.person_id;
  g_report_table_object(l_count).pgm_id := p_rec.pgm_id;
  g_report_table_object(l_count).pl_id := p_rec.pl_id;
  g_report_table_object(l_count).related_person_id := p_rec.related_person_id;
  g_report_table_object(l_count).oipl_id := p_rec.oipl_id;
  g_report_table_object(l_count).pl_typ_id := p_rec.pl_typ_id;
  g_report_table_object(l_count).object_version_number := 1;
  g_report_table_object(l_count).actl_prem_id := p_rec.actl_prem_id;
  g_report_table_object(l_count).val := p_rec.val;
  g_report_table_object(l_count).mo_num := p_rec.mo_num;
  g_report_table_object(l_count).yr_num := p_rec.yr_num;
  --
  -- Reset p_rec to null
  --
  p_rec := l_rec;
  --
--  hr_utility.set_location('Leaving:'||l_proc, 40);
  --
end write;
------------------------------------------------------------------------
--  get_batch_parameters
------------------------------------------------------------------------
procedure get_batch_parameters(p_benefit_action_id in number,
                               p_rec               in out nocopy g_batch_param_rec) is
  --
  l_proc                  varchar2(80) := 'benutils.get_batch_parameters';
  --
  cursor c1 is
    select PROCESS_DATE,
           MODE_CD,
           DERIVABLE_FACTORS_FLAG,
           VALIDATE_FLAG,
           PERSON_ID,
           PERSON_TYPE_ID,
           PGM_ID,
           BUSINESS_GROUP_ID,
           PL_ID,
           POPL_ENRT_TYP_CYCL_ID,
           NO_PROGRAMS_FLAG,
           NO_PLANS_FLAG,
           COMP_SELECTION_RL,
           PERSON_SELECTION_RL,
           LER_ID,
           ORGANIZATION_ID,
           BENFTS_GRP_ID,
           LOCATION_ID,
           PSTL_ZIP_RNG_ID,
           RPTG_GRP_ID,
           PL_TYP_ID,
           OPT_ID,
           ELIGY_PRFL_ID,
           VRBL_RT_PRFL_ID,
           LEGAL_ENTITY_ID,
           PAYROLL_ID,
           CM_TRGR_TYP_CD,
           DEBUG_MESSAGES_FLAG,
           CM_TYP_ID,
           AGE_FCTR_ID,
           MIN_AGE,
           MAX_AGE,
           LOS_FCTR_ID,
           MIN_LOS,
           MAX_LOS,
           CMBN_AGE_LOS_FCTR_ID,
           MIN_CMBN,
           MAX_CMBN,
           DATE_FROM,
           ELIG_ENROL_CD,
           ACTN_TYP_ID,
           AUDIT_LOG_FLAG,
           LF_EVT_OCRD_DT,
           LMT_PRPNIP_BY_ORG_FLAG,
           INELG_ACTION_CD
    from   ben_benefit_actions
    where  benefit_action_id = p_benefit_action_id;
  --
begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if not g_batch_param_table_object.exists(1) then
    --
    open c1;
      --
      fetch c1 into g_batch_param_table_object(1);
      --
      --Bug 4998406
      if c1%found
      then
       --
       p_rec := g_batch_param_table_object(1);
       --
      end if;
      --
      --Bug 4998406
    close c1;
    --
  else
    --
    p_rec := g_batch_param_table_object(1);    /* Bug 5009662 */
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 5);
  --
end get_batch_parameters;

------------------------------------------------------------------------
--  write
------------------------------------------------------------------------
procedure write(p_rec in out nocopy g_batch_elig_rec) is
  --
  l_batch_elig_id         number(38);
  l_object_version_number number(38);
  l_proc                  varchar2(80) := 'benutils.write 2';
  l_rec                   g_batch_elig_rec;
  l_count                 number := 1;
  l_oipl_rec              ben_oipl_f%rowtype;
  l_params                g_batch_param_rec;
  --
begin
  --
--  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if g_benefit_action_id is null then
    return;
  end if;
  --
  get_batch_parameters(p_benefit_action_id => g_benefit_action_id,
                       p_rec               => l_params);
  --
  if l_params.audit_log_flag <> 'Y' then
    --
--  hr_utility.set_location('Leaving:'||l_proc, 4);
    return;
    --
  end if;
  --
  --
  g_batch_elig_table_object.extend(1);
  l_count := g_batch_elig_table_object.count;
  select ben_batch_elig_info_s.nextval into
  g_batch_elig_table_object(l_count).batch_elig_id
  from sys.dual;
  --
  g_batch_elig_table_object(l_count).benefit_action_id := g_benefit_action_id;
  g_batch_elig_table_object(l_count).person_id := p_rec.person_id;
  g_batch_elig_table_object(l_count).pgm_id := p_rec.pgm_id;
  if p_rec.pgm_id is null then
    --
    g_batch_elig_table_object(l_count).pgm_id := ben_manage_life_events.
                                                 g_last_pgm_id;
    --
  end if;
  g_batch_elig_table_object(l_count).pl_id := p_rec.pl_id;
  if p_rec.oipl_id is not null then
    --
    ben_comp_object.get_object(p_oipl_id => p_rec.oipl_id,
                               p_rec     => l_oipl_rec);
    --
    g_batch_elig_table_object(l_count).pl_id := l_oipl_rec.pl_id;
    --
  end if;
  g_batch_elig_table_object(l_count).oipl_id := p_rec.oipl_id;
  g_batch_elig_table_object(l_count).elig_flag := p_rec.elig_flag;
  g_batch_elig_table_object(l_count).inelig_text := p_rec.inelig_text;
  g_batch_elig_table_object(l_count).business_group_id := p_rec.business_group_id;
  g_batch_elig_table_object(l_count).effective_date := p_rec.effective_date;
  g_batch_elig_table_object(l_count).object_version_number := 1;
  --
  -- Reset p_rec to null
  --
  p_rec := l_rec;
  --
--  hr_utility.set_location('Leaving:'||l_proc, 40);
  --
end write;
--
procedure write(p_rec in out nocopy ben_type.g_batch_action_rec) is
  --
  l_proc                  varchar2(80) := 'benutils.write 3';
  l_rec                   ben_type.g_batch_action_rec;
  l_count                 number := 1;
  --
begin
  --
--  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  g_batch_action_table_object.extend(1);
  l_count := g_batch_action_table_object.count;
  --
  g_batch_action_table_object(l_count).person_action_id := p_rec.person_action_id;
  g_batch_action_table_object(l_count).object_version_number := p_rec.object_version_number;
  g_batch_action_table_object(l_count).ler_id := p_rec.ler_id;
  g_batch_action_table_object(l_count).action_status_cd := p_rec.action_status_cd;
  g_batch_action_table_object(l_count).effective_date := p_rec.effective_date;
  --
  -- Reset p_rec to null
  --
  p_rec := l_rec;
  --
--  hr_utility.set_location('Leaving:'||l_proc, 40);
  --
end write;
--
procedure write(p_rec in out nocopy g_batch_elctbl_rec) is
  --
  l_proc                  varchar2(80) := 'benutils.write 4';
  l_rec                   g_batch_elctbl_rec;
  l_count                 number := 1;
  l_params                g_batch_param_rec;
  --
begin
  --
--  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if g_benefit_action_id is null then
    return;
  end if;
  --
  get_batch_parameters(p_benefit_action_id => g_benefit_action_id,
                       p_rec               => l_params);
  --
  if l_params.audit_log_flag <> 'Y' then
--  hr_utility.set_location('Leaving:'||l_proc, 3);
    --
    return;
    --
  end if;
  --
  --
  g_batch_elctbl_table_object.extend(1);
  l_count := g_batch_elctbl_table_object.count;
  select ben_batch_elctbl_chc_info_s.nextval into
  g_batch_elctbl_table_object(l_count).batch_elctbl_id
  from sys.dual;
  --
  g_batch_elctbl_table_object(l_count).benefit_action_id := g_benefit_action_id;
  g_batch_elctbl_table_object(l_count).person_id := p_rec.person_id;
  g_batch_elctbl_table_object(l_count).pgm_id := p_rec.pgm_id;
  g_batch_elctbl_table_object(l_count).pl_id := p_rec.pl_id;
  g_batch_elctbl_table_object(l_count).oipl_id := p_rec.oipl_id;
  g_batch_elctbl_table_object(l_count).enrt_cvg_strt_dt := p_rec.enrt_cvg_strt_dt;
  g_batch_elctbl_table_object(l_count).enrt_perd_strt_dt := p_rec.enrt_perd_strt_dt;
  g_batch_elctbl_table_object(l_count).enrt_perd_end_dt := p_rec.enrt_perd_end_dt;
  g_batch_elctbl_table_object(l_count).erlst_deenrt_dt := p_rec.erlst_deenrt_dt;
  g_batch_elctbl_table_object(l_count).dflt_enrt_dt := p_rec.dflt_enrt_dt;
  g_batch_elctbl_table_object(l_count).enrt_typ_cycl_cd := p_rec.enrt_typ_cycl_cd;
  g_batch_elctbl_table_object(l_count).comp_lvl_cd := p_rec.comp_lvl_cd;
  g_batch_elctbl_table_object(l_count).mndtry_flag := p_rec.mndtry_flag;
  g_batch_elctbl_table_object(l_count).dflt_flag := p_rec.dflt_flag;
  g_batch_elctbl_table_object(l_count).business_group_id := p_rec.business_group_id;
  g_batch_elctbl_table_object(l_count).effective_date := p_rec.effective_date;
  g_batch_elctbl_table_object(l_count).object_version_number := 1;
  --
  -- Reset p_rec to null
  --
  p_rec := l_rec;
  --
--  hr_utility.set_location('Leaving:'||l_proc, 40);
  --
end write;
--
procedure write(p_rec in out nocopy g_batch_rate_rec) is
  --
  l_proc                  varchar2(80) := 'benutils.write 5';
  l_rec                   g_batch_rate_rec;
  l_count                 number := 1;
  l_params                g_batch_param_rec;
  --
begin
  --
--  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if g_benefit_action_id is null then
    return;
  end if;
  --
  get_batch_parameters(p_benefit_action_id => g_benefit_action_id,
                       p_rec               => l_params);
  --
  if l_params.audit_log_flag <> 'Y' then
    --
--  hr_utility.set_location('Entering:'||l_proc, 3);
    return;
    --
  end if;
  --
--  hr_utility.set_location('Writing Rate Record:'||l_proc, 5);
  --
  g_batch_rate_table_object.extend(1);
  l_count := g_batch_rate_table_object.count;
  select ben_batch_rate_info_s.nextval into
  g_batch_rate_table_object(l_count).batch_rt_id
  from sys.dual;
  --
  g_batch_rate_table_object(l_count).benefit_action_id := g_benefit_action_id;
  g_batch_rate_table_object(l_count).person_id := p_rec.person_id;
  g_batch_rate_table_object(l_count).pgm_id := p_rec.pgm_id;
  g_batch_rate_table_object(l_count).pl_id := p_rec.pl_id;
  g_batch_rate_table_object(l_count).oipl_id := p_rec.oipl_id;
  g_batch_rate_table_object(l_count).bnft_rt_typ_cd := p_rec.bnft_rt_typ_cd;
  g_batch_rate_table_object(l_count).dflt_flag := p_rec.dflt_flag;
  g_batch_rate_table_object(l_count).val := p_rec.val;
  g_batch_rate_table_object(l_count).old_val := p_rec.old_val;
  g_batch_rate_table_object(l_count).tx_typ_cd := p_rec.tx_typ_cd;
  g_batch_rate_table_object(l_count).acty_typ_cd := p_rec.acty_typ_cd;
  g_batch_rate_table_object(l_count).mn_elcn_val := p_rec.mn_elcn_val;
  g_batch_rate_table_object(l_count).mx_elcn_val := p_rec.mx_elcn_val;
  g_batch_rate_table_object(l_count).incrmt_elcn_val := p_rec.incrmt_elcn_val;
  g_batch_rate_table_object(l_count).dflt_val := p_rec.dflt_val;
  g_batch_rate_table_object(l_count).rt_strt_dt := p_rec.rt_strt_dt;
  g_batch_rate_table_object(l_count).business_group_id := p_rec.business_group_id;
  g_batch_rate_table_object(l_count).enrt_cvg_strt_dt := p_rec.enrt_cvg_strt_dt;
  g_batch_rate_table_object(l_count).enrt_cvg_thru_dt := p_rec.enrt_cvg_thru_dt;
  g_batch_rate_table_object(l_count).actn_cd := p_rec.actn_cd;
  g_batch_rate_table_object(l_count).close_actn_itm_dt := p_rec.close_actn_itm_dt;
  g_batch_rate_table_object(l_count).effective_date := p_rec.effective_date;
  g_batch_rate_table_object(l_count).object_version_number := 1;
  --
  -- Reset p_rec to null
  --
  p_rec := l_rec;
  --
--  hr_utility.set_location('Leaving:'||l_proc, 40);
--  hr_utility.set_location('Number of Rate Records:'||g_batch_rate_table_object.count,5);
  --
end write;
--
procedure write(p_rec in out nocopy g_batch_dpnt_rec) is
  --
  l_proc                  varchar2(80) := 'benutils.write 6';
  l_rec                   g_batch_dpnt_rec;
  l_count                 number := 1;
  l_params                g_batch_param_rec;
  --
begin
  --
--  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if g_benefit_action_id is null then
    return;
  end if;
  --
  get_batch_parameters(p_benefit_action_id => g_benefit_action_id,
                       p_rec               => l_params);
  --
  if l_params.audit_log_flag <> 'Y' then
    --
--  hr_utility.set_location('Leaving:'||l_proc, 3);
    return;
    --
  end if;
  --
  --
  g_batch_dpnt_table_object.extend(1);
  l_count := g_batch_dpnt_table_object.count;
  select ben_batch_dpnt_info_s.nextval into
  g_batch_dpnt_table_object(l_count).batch_dpnt_id
  from sys.dual;
  --
  g_batch_dpnt_table_object(l_count).benefit_action_id := g_benefit_action_id;
  g_batch_dpnt_table_object(l_count).person_id := p_rec.person_id;
  g_batch_dpnt_table_object(l_count).pgm_id := p_rec.pgm_id;
  g_batch_dpnt_table_object(l_count).pl_id := p_rec.pl_id;
  g_batch_dpnt_table_object(l_count).oipl_id := p_rec.oipl_id;
  g_batch_dpnt_table_object(l_count).contact_typ_cd := p_rec.contact_typ_cd;
  g_batch_dpnt_table_object(l_count).dpnt_person_id := p_rec.dpnt_person_id;
  g_batch_dpnt_table_object(l_count).business_group_id := p_rec.business_group_id;
  g_batch_dpnt_table_object(l_count).enrt_cvg_strt_dt := p_rec.enrt_cvg_strt_dt;
  g_batch_dpnt_table_object(l_count).enrt_cvg_thru_dt := p_rec.enrt_cvg_thru_dt;
  g_batch_dpnt_table_object(l_count).actn_cd := p_rec.actn_cd;
  g_batch_dpnt_table_object(l_count).effective_date := p_rec.effective_date;
  g_batch_dpnt_table_object(l_count).object_version_number := 1;
  --
  -- Reset p_rec to null
  --
  p_rec := l_rec;
  --
--  hr_utility.set_location('Leaving:'||l_proc, 40);
  --
end write;
--
procedure write(p_rec in out nocopy ben_type.g_batch_commu_rec) is
  --
  l_proc                  varchar2(80) := 'benutils.write 7';
  l_rec                   ben_type.g_batch_commu_rec;
  l_count                 number := 1;
  --
begin
  --
--  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  g_batch_commu_table_object.extend(1);
  l_count := g_batch_commu_table_object.count;
  select ben_batch_commu_info_s.nextval into
  g_batch_commu_table_object(l_count).batch_commu_id
  from sys.dual;
  --
  g_batch_commu_table_object(l_count).benefit_action_id := g_benefit_action_id;
  g_batch_commu_table_object(l_count).person_id := p_rec.person_id;
  g_batch_commu_table_object(l_count).per_cm_id := p_rec.per_cm_id;
  g_batch_commu_table_object(l_count).cm_typ_id := p_rec.cm_typ_id;
  g_batch_commu_table_object(l_count).per_cm_prvdd_id := p_rec.per_cm_prvdd_id;
  g_batch_commu_table_object(l_count).business_group_id :=p_rec.business_group_id;
  g_batch_commu_table_object(l_count).to_be_sent_dt := p_rec.to_be_sent_dt;
  g_batch_commu_table_object(l_count).object_version_number := 1;
  --
  -- Reset p_rec to null
  --
  p_rec := l_rec;
  --
--  hr_utility.set_location('Leaving:'||l_proc, 40);
  --
end write;
--
procedure write(p_rec in out nocopy g_batch_ler_rec) is
  --
  l_batch_ler_id          number(38);
  l_object_version_number number(38);
  l_proc                  varchar2(80) := 'benutils.write 8';
  l_rec                   g_batch_ler_rec;
  l_count                 number := 1;
  l_params                g_batch_param_rec;
  --
begin
  --
--  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  g_batch_ler_table_object.extend(1);
  l_count := g_batch_ler_table_object.count;
  select ben_batch_ler_info_s.nextval into
  g_batch_ler_table_object(l_count).batch_ler_id
  from sys.dual;
  --
  g_batch_ler_table_object(l_count).benefit_action_id := g_benefit_action_id;
  g_batch_ler_table_object(l_count).person_id := p_rec.person_id;
  g_batch_ler_table_object(l_count).ler_id := p_rec.ler_id;
  g_batch_ler_table_object(l_count).lf_evt_ocrd_dt := p_rec.lf_evt_ocrd_dt;
  g_batch_ler_table_object(l_count).replcd_flag := p_rec.replcd_flag;
  g_batch_ler_table_object(l_count).crtd_flag := p_rec.crtd_flag;
  g_batch_ler_table_object(l_count).tmprl_flag := p_rec.tmprl_flag;
  g_batch_ler_table_object(l_count).dltd_flag := p_rec.dltd_flag;
  g_batch_ler_table_object(l_count).open_and_clsd_flag := p_rec.open_and_clsd_flag;
  g_batch_ler_table_object(l_count).clsd_flag := p_rec.clsd_flag;
  g_batch_ler_table_object(l_count).clpsd_flag := p_rec.clpsd_flag;
  g_batch_ler_table_object(l_count).clsn_flag := p_rec.clsn_flag;
  g_batch_ler_table_object(l_count).no_effect_flag := p_rec.no_effect_flag;
  g_batch_ler_table_object(l_count).cvrge_rt_prem_flag := p_rec.cvrge_rt_prem_flag;
  g_batch_ler_table_object(l_count).not_crtd_flag := p_rec.not_crtd_flag;
  g_batch_ler_table_object(l_count).stl_actv_flag := p_rec.stl_actv_flag;
  g_batch_ler_table_object(l_count).per_in_ler_id := p_rec.per_in_ler_id;
  g_batch_ler_table_object(l_count).business_group_id := p_rec.business_group_id;
  g_batch_ler_table_object(l_count).effective_date := p_rec.effective_date;
  g_batch_ler_table_object(l_count).object_version_number := 1;
  --
  -- Reset p_rec to null
  --
  p_rec := l_rec;
  --
--  hr_utility.set_location('Leaving:'||l_proc, 40);
  --
end write;
--
procedure write(p_rec in out nocopy ben_type.g_batch_proc_rec) is
  --
  l_batch_proc_id         number(38);
  l_object_version_number number(38);
  l_proc                  varchar2(80) := 'benutils.write 9';
  l_rec                   ben_type.g_batch_proc_rec;
  l_count                 number := 1;
  --
begin
  --
--  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  ben_batch_proc_info_api.create_batch_proc_info
    (p_validate                       => false
    ,p_batch_proc_id                  => l_batch_proc_id
    ,p_benefit_action_id              => g_benefit_action_id
    ,p_strt_dt                        => p_rec.strt_dt
    ,p_end_dt                         => p_rec.end_dt
    ,p_strt_tm                        => p_rec.strt_tm
    ,p_end_tm                         => p_rec.end_tm
    ,p_elpsd_tm                       => p_rec.elpsd_tm
    ,p_per_slctd                      => p_rec.per_slctd
    ,p_per_proc                       => p_rec.per_proc
    ,p_per_unproc                     => p_rec.per_unproc
    ,p_per_proc_succ                  => p_rec.per_proc_succ
    ,p_per_err                        => p_rec.per_err
    ,p_business_group_id              => p_rec.business_group_id
    ,p_object_version_number          => l_object_version_number);
  --
  -- Reset p_rec to null
  --
  p_rec := l_rec;
  --
--  hr_utility.set_location('Leaving:'||l_proc, 40);
  --
end write;
--
procedure write(p_text     in varchar2,
                p_validate in boolean ) is
  --
  l_reporting_id number(38);
  l_object_version_number number(38);
  l_proc   varchar2(80) := 'benutils.write 10';
  l_count number := 1;
  --
begin
  --
  -- Check if the audit flag is set and is N. Do not
  -- log when N.
  --
  if g_batch_param_table_object.exists(1)
  then
    --
    if g_batch_param_table_object(1).audit_log_flag = 'N' then
      --
      return;
      --
    end if;
    --
  end if;
  --
  if g_benefit_action_id = -1 or g_benefit_action_id is null
  then
    --
    -- Assume no logging required
    --
--  hr_utility.set_location('Leaving:'||l_proc, 4);
    return;
    --
  end if;
  --
  g_sequence := g_sequence +1;
  --
--  hr_utility.set_location('Report Varray:'||l_proc, 5);
  g_report_table_object.extend(1);
  l_count := g_report_table_object.count;
/*
  select ben_reporting_s.nextval into
  g_report_table_object(l_count).reporting_id
  from sys.dual;
*/
  g_report_table_object(l_count).reporting_id := null;
  g_report_table_object(l_count).benefit_action_id := g_benefit_action_id;
  g_report_table_object(l_count).thread_id := g_thread_id;
  g_report_table_object(l_count).sequence := g_sequence;
  g_report_table_object(l_count).text := p_text;
  g_report_table_object(l_count).rep_typ_cd := null;
  g_report_table_object(l_count).error_message_code := null;
  g_report_table_object(l_count).national_identifier := null;
  g_report_table_object(l_count).related_person_ler_id := null;
  g_report_table_object(l_count).temporal_ler_id := null;
  g_report_table_object(l_count).ler_id := null;
  g_report_table_object(l_count).person_id := null;
  g_report_table_object(l_count).pgm_id := null;
  g_report_table_object(l_count).pl_id := null;
  g_report_table_object(l_count).related_person_id := null;
  g_report_table_object(l_count).oipl_id := null;
  g_report_table_object(l_count).pl_typ_id := null;
  g_report_table_object(l_count).object_version_number := 1;
  g_report_table_object(l_count).actl_prem_id := null;
  g_report_table_object(l_count).val := null;
  g_report_table_object(l_count).mo_num := null;
  g_report_table_object(l_count).yr_num := null;
  --
--  hr_utility.set_location('Leaving:'||l_proc, 40);
  --
end write;

------------------------------------------------------------------------
--  update_life_event_cache
------------------------------------------------------------------------
procedure update_life_event_cache
  (p_open_and_closed in varchar2 ) is
  --
  l_proc   varchar2(80) := 'benutils.update_life_event_cache';
  --
begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Special case where we have to update the open_and_clsd_flag if the
  -- life event was created and not replaced
  --
  if g_batch_ler_table_object.count > 0 then
    --
    g_batch_ler_table_object(g_batch_ler_table_object.last).crtd_flag := 'N';
    g_batch_ler_table_object(g_batch_ler_table_object.last).open_and_clsd_flag := 'Y';
    --
    if p_open_and_closed = 'Y' then
      --
      -- Update the open and closed flag to Y and set the created flag to N
      --
      g_batch_ler_table_object(g_batch_ler_table_object.last).no_effect_flag := 'Y';
      --
    else
      --
      g_batch_ler_table_object(g_batch_ler_table_object.last).cvrge_rt_prem_flag := 'Y';
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
end update_life_event_cache;

------------------------------------------------------------------------
--  get_parameter
------------------------------------------------------------------------
procedure get_parameter(p_business_group_id in  number,
                        p_batch_exe_cd      in  varchar2,
                        p_threads           out nocopy number,
                        p_chunk_size        out nocopy number,
                        p_max_errors        out nocopy number) is
  --
  l_proc   varchar2(80) := 'benutils.get_parameter';
  --
  cursor c1 is
    select nvl(bbp.thread_cnt_num,
                decode(p_batch_exe_cd,'BENGCMOD',1,3)),
           nvl(bbp.chunk_size,10),
           nvl(bbp.max_err_num,20)
    from   ben_batch_parameter bbp
    where  bbp.batch_exe_cd = p_batch_exe_cd
    and    bbp.business_group_id = p_business_group_id;
  --
begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open c1;
    --
    fetch c1 into p_threads,
                  p_chunk_size,
                  p_max_errors;
    if c1%notfound then
      --
      -- Default all values
      --
      -- 5504516. For CWB Participation process, the default threads
      -- is 1. For others it is 3.
      -- If the customer defines a record, use the value from there.
      --
      if p_batch_exe_cd = 'BENGCMOD' then
        p_threads := 1;
      else
        p_threads := 3;
      end if;
      p_chunk_size := 10;
      p_max_errors := 20;
      --
    end if;
    --
  close c1;
  --
  hr_utility.set_location(l_proc||'p_threads : '||p_threads, 5);
  hr_utility.set_location('Leaving:'||l_proc, 5);
  --
end get_parameter;

------------------------------------------------------------------------
--  iftrue
------------------------------------------------------------------------
function iftrue(p_expression in boolean,
                p_true       in varchar2,
                p_false      in varchar2) return varchar2 is
  --
  l_proc   varchar2(80) := 'benutils.iftrue';
  --
begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_expression then
    --
    --hr_utility.set_location('Leaving:'||l_proc, 4);
    return p_true;
    --
  else
    --
    --hr_utility.set_location('Leaving:'||l_proc, 5);
    return p_false;
    --
  end if;
  --
end iftrue;

------------------------------------------------------------------------
--  zero_to_null
------------------------------------------------------------------------
function zero_to_null(p_value in number) return number is
  --
  l_value number;
  l_proc   varchar2(80) := 'benutils.zero_to_null';
  --
begin
  --
  --hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_value := iftrue(p_expression => p_value = 0,
                    p_true       => null,
                    p_false      => p_value);
  --
  --hr_utility.set_location('Leaving:'||l_proc, 5);
  return l_value;
  --
  --
end zero_to_null;

------------------------------------------------------------------------
--  get_bp_name
------------------------------------------------------------------------
function get_bp_name (p_tablename in varchar2) return varchar2 is
  --
  l_status			varchar2(1);
  l_industry			varchar2(1);
  l_application_short_name	varchar2(30);
  l_oracle_schema		varchar2(30);
  l_return                    boolean;
  --
  cursor c1(l_oracle_schema in varchar2) is
    select a.comments
    from   all_tab_comments a
    where  a.table_name = p_tablename
    and    a.owner = upper(l_oracle_schema);
  --
  l_comments varchar2(2000);
  l_start number(9) := 0;
  l_end number(9) := 0;
  l_proc   varchar2(80) := 'benutils.get_bp_name';
  --
begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Bug 3431740 Parameter l_oracle_schema added to cursor c1, the value is got by the
  -- following call
  l_return := fnd_installation.get_app_info(application_short_name => l_application_short_name,
              		                    status                 => l_status,
                          	            industry               => l_industry,
                                	    oracle_schema          => l_oracle_schema);



  open c1(l_oracle_schema);
    --
    fetch c1 into l_comments;
    if c1%found then
      --
      -- strip out bp name from string
      --
      l_start := instr(l_comments,'<<');
      l_end := instr(l_comments,'>>');
      l_comments := substr(l_comments,l_start+2,l_end-(l_start+2));
      --
    end if;
    --
  close c1;
  --
  if l_comments is null then
    --
    l_comments := 'BP_NOT_FOUND';
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 5);
  return l_comments;
  --
  --
end get_bp_name;

------------------------------------------------------------------------
--  part_of_pkey
------------------------------------------------------------------------
function part_of_pkey(p_column_name in varchar2) return boolean is
  --
  l_proc   varchar2(80) := 'benutils.part_of_pkey';
  --
begin
  --
  --hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Check if a column is part of the Primary Key
  --
  for l_counter in 1..g_primary_key_count loop
    --
    if p_column_name = g_part_of_pkey(l_counter) then
      --
      --hr_utility.set_location('Leaving:'||l_proc, 3);
      return true;
      --
    end if;
    --
  end loop;
  --
  --hr_utility.set_location('Leaving:'||l_proc, 5);
  return false;
  --
end part_of_pkey;

------------------------------------------------------------------------
--  define_primary_key
------------------------------------------------------------------------
procedure define_primary_key(p_tablename in varchar2) is
  --
  l_status			varchar2(1);
  l_industry			varchar2(1);
  l_application_short_name	varchar2(30);
  l_oracle_schema		varchar2(30);
  l_return                    boolean;
  --
  cursor c1(l_oracle_schema in varchar2) is
    select t.column_name
    from   all_tab_columns  t,
           all_cons_columns c,
           all_constraints  a
    where  a.constraint_type = 'P'
    and    a.table_name = p_tablename
    and    a.constraint_name = c.constraint_name
    and    t.table_name = c.table_name
    and    t.column_name = c.column_name
    and    t.table_name = a.table_name
    and    t.owner = upper(l_oracle_schema)
    and    c.owner = upper(l_oracle_schema)
    and    a.owner = upper(l_oracle_schema)
    order by c.position;
  --
  l_column varchar2(30);
  l_number_of_columns number(9) := 0;
  l_proc   varchar2(80) := 'benutils.define_primary_key';
  --
begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Get the column if is part of the primary key.
  --
  -- Bug 3431740 Parameter l_oracle_schema added to cursor c1, the value is got by the
  -- following call
  l_return := fnd_installation.get_app_info(application_short_name => l_application_short_name,
              		                    status                 => l_status,
                          	            industry               => l_industry,
                                	    oracle_schema          => l_oracle_schema);
  --
  open c1(l_oracle_schema);
    --
    loop
      --
      fetch c1 into l_column;
      exit when c1%notfound;
      --
      if c1%found then
        --
        l_number_of_columns := l_number_of_columns+1;
        g_part_of_pkey(l_number_of_columns) := l_column;
        --
      end if;
      --
    end loop;
    --
  close c1;
  --
  g_primary_key_count := l_number_of_columns;
  --
  hr_utility.set_location('Leaving:'||l_proc, 5);
  --
end define_primary_key;

------------------------------------------------------------------------
--  lookups_exist
------------------------------------------------------------------------
function lookups_exist(p_tablename in varchar2) return boolean is
  --
  l_status			varchar2(1);
  l_industry			varchar2(1);
  l_application_short_name	varchar2(30);
  l_oracle_schema		varchar2(30);
  l_return                    boolean;
  --
  cursor c1(l_oracle_schema in varchar2) is
    select null
    from   all_tab_columns t
    where  t.table_name = p_tablename
    and (substr(t.column_name,length(t.column_name)-2,3) = '_CD'
         or substr(t.column_name,length(t.column_name)-3,4) = '_IND'
         or substr(t.column_name,length(t.column_name)-3,4) = '_UOM'
         or substr(t.column_name,length(t.column_name)-2,3) = '_RL'
         or substr(t.column_name,length(t.column_name)-4,5) = '_FLAG')
    and t.owner = upper(l_oracle_schema);
  --
  l_dummy varchar2(1);
  l_proc   varchar2(80) := 'benutils.lookups_exist';
  --
begin
  --
  --hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Bug 3431740 Parameter l_oracle_schema added to cursor c1, the value is got by the
  -- following call
  l_return := fnd_installation.get_app_info(application_short_name => l_application_short_name,
              		                    status                 => l_status,
                          	            industry               => l_industry,
                                	    oracle_schema          => l_oracle_schema);
  open c1(l_oracle_schema);
    --
    fetch c1 into l_dummy;
    if c1%found then
      --
      close c1;
      --hr_utility.set_location('Leaving:'||l_proc, 3);
      return true;
      --
    end if;
    --
  close c1;
  --
  --hr_utility.set_location('Leaving:'||l_proc, 5);
  return false;
  --
end lookups_exist;

------------------------------------------------------------------------
--  get_primary_key
------------------------------------------------------------------------
function get_primary_key(p_tablename in varchar2) return varchar2 is
  --
  l_primary_key all_cons_columns.column_name%type;
  l_proc   varchar2(80) := 'benutils.get_primary_key';
  l_status			varchar2(1);
  l_industry			varchar2(1);
  l_application_short_name	varchar2(30);
  l_oracle_schema		varchar2(30);
  l_return                    boolean;
  --
  cursor c1(l_oracle_schema in varchar2) is
    select c.column_name
    from   all_tab_columns  t,
           all_cons_columns c,
           all_constraints  a
    where  a.constraint_type = 'P'
    and    a.table_name = p_tablename
    and    a.constraint_name = c.constraint_name
    and    t.column_name = c.column_name
    and    t.table_name = a.table_name
    and    t.owner = upper(l_oracle_schema)
    and    c.owner = upper(l_oracle_schema)
    and    a.owner = upper(l_oracle_schema)
    order by c.position;
  --
begin
  --
  --hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Get the Primary Key for the table.
  --
  -- Bug 3431740 Parameter l_oracle_schema added to cursor c1, the value is got by the
  -- following call
  l_return := fnd_installation.get_app_info(application_short_name => l_application_short_name,
              		                    status                 => l_status,
                          	            industry               => l_industry,
                                	    oracle_schema          => l_oracle_schema);
  --
  open c1(l_oracle_schema);
    --
    fetch c1 into l_primary_key;
    --
  close c1;
  --
  --hr_utility.set_location('Leaving:'||l_proc, 5);
  return l_primary_key;
  --
end get_primary_key;

------------------------------------------------------------------------
--  business_group_exists
------------------------------------------------------------------------
function business_group_exists(p_tablename in varchar2) return boolean is
  --
  l_status			varchar2(1);
  l_industry			varchar2(1);
  l_application_short_name	varchar2(30);
  l_oracle_schema		varchar2(30);
  l_return                    boolean;
  --
  cursor c1(l_oracle_schema in varchar2) is
    select null
    from   all_tab_columns a
    where  a.column_name = 'BUSINESS_GROUP_ID'
    and    a.table_name = p_tablename
    and    a.owner = upper(l_oracle_schema);
  --
  l_dummy varchar2(1);
  l_result boolean := false;
  l_proc   varchar2(80) := 'benutils.business_group_exists';
  --
begin
  --
  --hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Bug 3431740 Parameter l_oracle_schema added to cursor c1, the value is got by the
  -- following call
  l_return := fnd_installation.get_app_info(application_short_name => l_application_short_name,
              		                    status                 => l_status,
                          	            industry               => l_industry,
                                	    oracle_schema          => l_oracle_schema);
  --
  open c1(l_oracle_schema);
    --
    fetch c1 into l_dummy;
    --
    if c1%found then
      --
      l_result := true;
      --
    end if;
    --
  close c1;
  --
  --hr_utility.set_location('Leaving:'||l_proc, 5);
  return l_result;
  --
end business_group_exists;

------------------------------------------------------------------------
--  table_datetracked
------------------------------------------------------------------------
function table_datetracked(p_tablename in varchar2) return boolean is
  --
  l_proc   varchar2(80) := 'benutils.table_datetracked';
  --
begin
  --
  --hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if substr(p_tablename,length(p_tablename)-1,2) = '_F' then
    --hr_utility.set_location('Leaving:'||l_proc, 3);
    return true;
  else
    --hr_utility.set_location('Leaving:'||l_proc, 5);
    return false;
  end if;
  --
end table_datetracked;

------------------------------------------------------------------------
--  attributes_exist
------------------------------------------------------------------------
function attributes_exist(p_tablename in varchar2) return boolean is
  --
  l_status			varchar2(1);
  l_industry			varchar2(1);
  l_application_short_name	varchar2(30);
  l_oracle_schema		varchar2(30);
  l_return                    boolean;
  --
  cursor c1(l_oracle_schema in varchar2) is
    select null
    from   all_tab_columns utc
    where  utc.table_name = p_tablename
    and    utc.column_name like '%ATTRIBUTE%'
    and    utc.owner = upper(l_oracle_schema);
  --
  l_dummy varchar2(1);
  l_found boolean := false;
  l_proc   varchar2(80) := 'benutils.attributes_exist';
  --
begin
  --
  --hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- See if attributes exist for the table
  --
  -- Bug 3431740 Parameter l_oracle_schema added to cursor c1, the value is got by the
  -- following call
  l_return := fnd_installation.get_app_info(application_short_name => l_application_short_name,
              		                    status                 => l_status,
                          	            industry               => l_industry,
                                	    oracle_schema          => l_oracle_schema);
  --
  open c1(l_oracle_schema);
    --
    fetch c1 into l_dummy;
    if c1%found then
      --
      l_found := true;
      --
    end if;
    --
  close c1;
  --
  --hr_utility.set_location('Leaving:'||l_proc, 5);
  return l_found;
  --
end attributes_exist;

------------------------------------------------------------------------
--  get_pk_constraint_name
------------------------------------------------------------------------
function get_pk_constraint_name(p_tablename in varchar2) return varchar2 is
  --
  l_status			varchar2(1);
  l_industry			varchar2(1);
  l_application_short_name	varchar2(30);
  l_oracle_schema		varchar2(30);
  l_return                    boolean;
  --
  cursor c1(l_oracle_schema in varchar2) is
    select con.constraint_name
    from   all_constraints con
    where  con.table_name = p_tablename
    and    con.constraint_type = 'P'
    and    con.owner = upper(l_oracle_schema);
  --
  l_constraint_name all_constraints.constraint_name%type;
  l_proc   varchar2(80) := 'benutils.get_pk_constraint_name';
  --
begin
  --
  --hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- get the Primary Key constraint name for the table
  --
  -- Bug 3431740 Parameter l_oracle_schema added to cursor c1, the value is got by the
  -- following call
  l_return := fnd_installation.get_app_info(application_short_name => l_application_short_name,
              		                    status                 => l_status,
                          	            industry               => l_industry,
                                	    oracle_schema          => l_oracle_schema);
  --
  open c1(l_oracle_schema);
    --
    fetch c1 into l_constraint_name;
    --
  close c1;
  --
  --hr_utility.set_location('Leaving:'||l_proc, 5);
  return l_constraint_name;
  --
end get_pk_constraint_name;
--
function column_changed(p_old_column in varchar2
                         ,p_new_column in varchar2
                         ,p_new_value in varchar2) return boolean is
begin
  if ((p_new_column = p_old_column)
      OR ((p_old_column IS NULL)
        AND (p_new_column IS NULL)))
  then
    hr_utility.set_location('FALSE',10);
    return FALSE;
  --
  -- Value MUST have changed
  -- so if any value chosen return true
  -- elsif specific value test for it
  -- being new value.
  elsif p_new_value = 'OABANY'
  then
    hr_utility.set_location('TRUE',10);
    return TRUE;
  elsif ((p_new_value = 'NULL')
        AND (p_new_column IS NULL)
         )
  then
    hr_utility.set_location('TRUE',10);
    return TRUE;
  elsif ((p_new_value = 'NULL')
        AND (p_new_column IS NOT NULL))
  then
    hr_utility.set_location('FALSE',10);
    return FALSE;
  elsif ((p_new_column IS NOT NULL)
         AND (p_new_column = p_new_value)
         )
  then
    hr_utility.set_location('TRUE',10);
    return TRUE;
  end if;
  hr_utility.set_location('FALSE',10);
  return FALSE;
end;

------------------------------------------------------------------------
--  column_changed
------------------------------------------------------------------------
function column_changed(p_old_column in date
                         ,p_new_column in date
                         ,p_new_value in varchar2) return boolean is
begin
  hr_utility.set_location('In routine',10);
  if ((p_new_column = p_old_column)
      OR ((p_old_column IS NULL)
        AND (p_new_column IS NULL)))
  then
    hr_utility.set_location('FALSE1',10);
    return FALSE;
  --
  -- Value MUST have changed
  -- so if any value chosen return true
  -- else if specific value test for it
  -- being new value.
  elsif p_new_value = 'OABANY'
  then
    -- Bug 1167917 Do not trigger date oabany's for null nor end of time.
    -- eot is a date that should work like null.
    -- Bug#2001857-null value must be treated differently as the condition above checks
    -- and both the values are null then false is returnedi-null condition masked
    if p_new_column = hr_api.g_eot then
       -- or p_new_column is null then
       hr_utility.set_location('FALSE2',10);
       return FALSE;
    else
       hr_utility.set_location('TRUE3',10);
       return TRUE;
    end if;
  elsif ((p_new_value = 'NULL')
        AND (p_new_column IS NULL or
           p_new_column = hr_api.g_eot)
         )
  then
    -- Bug 1167017, treat eot as null
    hr_utility.set_location('TRUE4',10);
    return TRUE;
  elsif ((p_new_value = 'NULL')
        AND (p_new_column IS NOT NULL) and
             p_new_column <> hr_api.g_eot)
  then
    hr_utility.set_location('FALSE5',10);
    return FALSE;
  elsif p_new_value = 'ENDTM' and p_new_column = hr_api.g_eot then
    hr_utility.set_location('TRUE5',10);
    return true;
  elsif ((p_new_column IS NOT NULL)
         AND (to_char(p_new_column) = p_new_value)
        )
  then
    hr_utility.set_location('TRUE6',10);
    return TRUE;
  end if;
  hr_utility.set_location('FALSE7',10);
  return FALSE;
end;
--
function column_changed(p_old_column in number
                         ,p_new_column in number
                         ,p_new_value in varchar2) return boolean is
begin
  if ((p_new_column = p_old_column)
      OR ((p_old_column IS NULL)
        AND (p_new_column IS NULL)))
  then
    return FALSE;
  --
  -- Value MUST have changed
  -- so if any value chosen return true
  -- elsif specific value test for it
  -- being new value.
  elsif p_new_value = 'OABANY'
  then
    return TRUE;
  elsif ((p_new_value = 'NULL')
        AND (p_new_column IS NULL)
         )
  then
    return TRUE;
  elsif ((p_new_value = 'NULL')
        AND (p_new_column IS NOT NULL))
  then
    return FALSE;
  elsif ((p_new_column IS NOT NULL)
         AND (p_new_column = p_new_value)
        )
  then
    return TRUE;
  end if;
  return FALSE;
end;

------------------------------------------------------------------------
--  do_rounding
------------------------------------------------------------------------
function do_rounding(p_rounding_cd    in varchar2,
                     p_rounding_rl    in number ,
                     p_assignment_id  in number ,
                     p_value          in number,
                     p_effective_date in date) return number is
  --
  l_proc         varchar2(72) := 'benutils.do_rounding';
  --
  l_rndg_fctr    number;
  l_rndg_type    varchar2(10);
  l_modulus      number;
  l_result       number;
  l_val_chg_flag varchar2(1) := 'N' ;
  l_value        number      := p_value   ;
  --
  -- Set up fast formula stuff
  --
  l_outputs  ff_exec.outputs_t;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_rounding_cd is null then
    --
    l_result := p_value;
    hr_utility.set_location('Leaving:'||l_proc, 5);
    return l_result;
    --
  elsif p_rounding_cd = 'RL' then
    --
    -- Call formula initialise routine
    --
    l_outputs := benutils.formula
     (p_formula_id     => p_rounding_rl,
      p_effective_date => p_effective_date,
      p_assignment_id  => p_assignment_id,
      p_param1         => 'VALUE',
      p_param1_value   => p_value,
      -- FONM
      p_param2             => 'BEN_IV_RT_STRT_DT',
      p_param2_value       => fnd_date.date_to_canonical(ben_manage_life_events.g_fonm_rt_strt_dt),
      p_param3             => 'BEN_IV_CVG_STRT_DT',
      p_param3_value       => fnd_date.date_to_canonical(ben_manage_life_events.g_fonm_cvg_strt_dt));
    --
    l_result := l_outputs(l_outputs.first).value;
    --
  else
    --
    -- default rounding type code will override if needed
    --
    l_rndg_type := 'UP-DOWN';
    --
    if p_rounding_cd = 'RUTNHND' then
      --
      l_rndg_fctr:=100;
      l_rndg_type:='UP';
      --
    elsif p_rounding_cd = 'RUTNFHND' then
      --
      l_rndg_fctr:=500;
      l_rndg_type:='UP';
      --
    elsif p_rounding_cd = 'RUTNTHO' then
      --
      l_rndg_fctr:=1000;
      l_rndg_type:='UP';
      --
    elsif p_rounding_cd = 'RUTNFTHO' then
      --
      l_rndg_fctr:=5000;
      l_rndg_type:='UP';
      --
    elsif p_rounding_cd = 'RTNRTHTH' then
      --
      l_rndg_fctr:=.001;
      ---bug 2083228
      if p_value < 0 then
         l_value := p_value * -1 ;
         l_val_chg_flag := 'Y' ;
      end if ;
      --
    elsif p_rounding_cd = 'RTNRHNTH' then
      --
      l_rndg_fctr:=.01;
      ---bug 2083228
      if p_value < 0 then
         l_value := p_value * -1 ;
         l_val_chg_flag := 'Y' ;
      end if ;
      --
    elsif p_rounding_cd = 'RTNRTNTH' then
      --
      l_rndg_fctr:=.1;
      ---bug 2083228
      if p_value < 0 then
         l_value := p_value * -1 ;
         l_val_chg_flag := 'Y' ;
      end if ;

      --
    elsif p_rounding_cd = 'RTNRONE' then
      --
      l_rndg_fctr:=1;
      --
    elsif p_rounding_cd = 'RTNRTEN' then
      --
      l_rndg_fctr:=10;
      --
    elsif p_rounding_cd = 'RTNRHND' then
      --
      l_rndg_fctr:=100;
      --
    elsif p_rounding_cd = 'RTNRTHO' then
      --
      l_rndg_fctr:=1000;
      --
    elsif p_rounding_cd = 'RTNRTTHO' then
      --
      l_rndg_fctr:=10000;
      --
    elsif p_rounding_cd = 'RTNRHTHO' then
      --
      l_rndg_fctr:=100000;
      --
    elsif p_rounding_cd = 'RTNRMLN' then
      --
      l_rndg_fctr:=1000000;
      --
    elsif p_rounding_cd = 'RDTNONE' then
      --
      l_rndg_fctr:=1;
      l_rndg_type:='DOWN';
      --
    else
      --
      -- Defensive programming
      --
      fnd_message.set_name('BEN','BEN_91342_UNKNOWN_CODE_1');
      fnd_message.set_token('PROC',l_proc);
      fnd_message.set_token('CODE1',p_rounding_cd);
      raise ben_manage_life_events.g_record_error;
      --
    end if;
    --
    l_modulus := mod(l_value,l_rndg_fctr);
    --
    if l_modulus <> 0 then
      --
      if l_rndg_type='UP' then
        --
        l_result:=l_value-l_modulus+l_rndg_fctr;
        --
      elsif l_rndg_type = 'DOWN' then
        --
        hr_utility.set_location('p_value:'||to_char(l_value), 5);
        hr_utility.set_location('l_modulus:'||to_char(l_modulus), 5);
        l_result:=l_value-l_modulus;
        hr_utility.set_location('l_result:'||l_result, 5);
        --
      else
        --
        -- go for nearest
        --
        if l_modulus >= (l_rndg_fctr/2) then
          --
          l_result:=l_value-l_modulus+l_rndg_fctr;
          --
        else
          --
          l_result:=l_value-l_modulus;
          --
        end if;
        --
      end if;
      --
    else
      --
      l_result:=l_value;
      --
    end if;
    --
  end if;

  ---bug 2083228
  if l_val_chg_flag = 'Y' then
     l_result:=l_result * -1 ;
     hr_utility.set_location(' negetive value ' || l_result, 199 );
  end if ;
  --
  hr_utility.set_location('Leaving:'||l_proc, 99);
  return l_result;
  --
end do_rounding;

------------------------------------------------------------------------
--  derive_date
------------------------------------------------------------------------
function derive_date(p_date    in date,
                     p_uom     in varchar2,
                     p_min     in number,
                     p_max     in number,
                     p_value   in varchar2,
                     p_decimal_level in  varchar2 ) return date is
  --
  l_proc         varchar2(72) := 'benutils.derive_date';
  l_value        date;
  l_val          number;
  l_fractional   number;
  --
begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_utility.set_location(' P_VALUE ' || p_value, 926);
  hr_utility.set_location(' P_max ' || p_max, 926);
  if p_value = 'LT_MIN' or
     p_value = 'GT_MIN' then
    --
    l_val := p_min;
    --
/**
  else
    --
    --bug : 1743925 if the call is for decide le_evt_date, whic is create because of
    --      breach of max_min   then apply the max + 1<
    if p_value  is not null then
       l_val := ceil(p_max + 0.001) ;
       if p_decimal_level = 'Y' then
          -- whne there is deimal and decima level is controlled
          -- add decimal maximum
          if  round( p_max,0) <>  p_max then
              l_val := (( p_max * 100)  + 1 ) / 100     ;
          end if ;
       end if ;
    else
       l_val := p_max;
    end if ;
    --
  end if;
*/
  elsif p_value = 'GT_MAX' then
    --
    if ( p_decimal_level = 'Y'
         OR p_min <> trunc(p_min)
         OR p_max <> trunc(p_max) ) then
      --
      l_val := p_max + 0.000000001 ;
      --
    else
      --
      l_val := p_max + 1 ;
      --
    end if;
    --
  else
    --
    l_val := p_max ;
    --
  end if;
 --
  hr_utility.set_location( p_value||'   '||l_val, 926);
  if p_uom = 'YR' then
    --
    l_value := add_months(p_date,l_val*12);
    --bug#4156125 - the add_months function takes only integer to add months
    --so the fraction of a month needs to be converted as days and added
    if l_val <> trunc(l_val) then
      --
      l_fractional := (l_val * 12) - trunc(l_val * 12);
      -- l_value := l_value + ceil((l_fractional * 365));
      -- Bug 5499177
      l_value := l_value + ceil((l_fractional * to_number(to_char(last_day(l_value), 'DD'))));
      --
    end if;
    --
  elsif p_uom = 'MO' then
    --
    l_value := add_months(p_date,l_val);
    --
  elsif p_uom = 'QTR' then
    --
    l_value := add_months(p_date,l_val*3);
    --
  elsif p_uom = 'WK' then
    --
    l_value := p_date+(l_val*7);
    --
  elsif p_uom = 'DY' then
    --
    l_value := p_date+l_val;
    --
  else
    --
    -- Defensive programming
    --
    fnd_message.set_name('BEN','BEN_91342_UNKNOWN_CODE_1');
    fnd_message.set_token('PROC',l_proc);
    fnd_message.set_token('CODE1',p_uom);
    raise ben_manage_life_events.g_record_error;
    --
  end if;
  --
  hr_utility.set_location(' calcualted return ' || l_value, 926);
  hr_utility.set_location('Leaving:'||l_proc, 99);
  return l_value;
  --
end derive_date;

------------------------------------------------------------------------
--  do_uom
------------------------------------------------------------------------
function do_uom(p_date1 in date,
                p_date2 in date,
                p_uom   in varchar2) return number is
  --
  l_value number;
  l_proc         varchar2(72) := 'benutils.do_uom';
  --
begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Calculate details based on UOM
  --
  -- All values expressed as days
  --
  if p_uom = 'YR' then
    --
    l_value := months_between(p_date1,p_date2) / 12;
    --
  elsif p_uom = 'MO' then
    --
    l_value := months_between(p_date1,p_date2);
    --
-- months_between fails when calculated between 29th Jan,30th Jan AND 28th Feb,
-- for months_between('28-Feb-RRRR','28-Jan-RRRR') it gives 1 but for months_between('28-Feb-RRRR','29/30-Jan-RRRR')
-- it gives < 1 and again as per functionality of months_between for months_between('28-Feb-RRRR','31-Jan-RRRR') it gives 1.
-- So code is made to work for this specific case.
 --Bug 5931412
    if substr(to_char(p_date1,'DD-MON-YYYY'),4,3) = 'FEB'
       and substr(to_char(p_date2,'DD-MON-YYYY'),1,2) > '28'
         and substr(to_char(p_date1,'DD-MON-YYYY'),1,2) in ('28','29') then
     --
        l_value := ceil(l_value);
     --
    end if;
     --
--Bug 5931412
  elsif p_uom = 'QTR' then
    --
    l_value := months_between(p_date1,p_date2) / 4;
    --
  elsif p_uom = 'WK' then
    --
    l_value := to_number(p_date1 - p_date2) / 7;
    --
  elsif p_uom = 'DY' then
    --
    l_value := to_number(p_date1 - p_date2);
    --
  else
    --
    -- Defensive programming
    --
    hr_utility.set_location('BEN_91342_UNKNOWN_CODE_1', 99);
    fnd_message.set_name('BEN','BEN_91342_UNKNOWN_CODE_1');
    fnd_message.set_token('PROC',l_proc);
    fnd_message.set_token('CODE1',p_uom);
    raise ben_manage_life_events.g_record_error;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 99);
  return l_value;
  --
end do_uom;

------------------------------------------------------------------------
--  id
------------------------------------------------------------------------
function id(p_value in number) return varchar2 is
  --
  l_value varchar2(30);
  l_proc   varchar2(80) := 'benutils.id';
  --
begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_value is null then
    --
    hr_utility.set_location('Leaving:'||l_proc, 3);
    return null;
    --
  end if;
  --
  l_value := ' ('||p_value||')';
  --
  hr_utility.set_location('Leaving:'||l_proc, 5);
  return l_value;
  --
end id;

------------------------------------------------------------------------
--  min_max_breach
-- This function returns the paramter  p_break  ( GT_MIN, LT_MIN, GT_MAX, LT_MAX )
-- which tells the actual boundary crossing.
-- returns true only when there is a breach.
------------------------------------------------------------------------
function min_max_breach(p_min_value     in number,
                        p_max_value     in number,
                        p_old_value     in number,
                        p_new_value     in number,
                        p_break         out nocopy varchar2,
                        p_decimal_level in  varchar2  ) return boolean is
  --
  l_package   varchar2(80) := 'benutils.min_max_breach';
  --
  l_return    boolean      := false;
  l_min_value number;
  l_max_value number;
  l_old_value number := p_old_value ;
  l_new_value number := p_new_value ;
  --
begin
  --
--  hr_utility.set_location ('Entering '||l_package,10);
--  hr_utility.set_location ('Min '||p_min_value,10);
--  hr_utility.set_location ('Max '||p_max_value,10);
--  hr_utility.set_location ('Old Value '||p_old_value,10);
--  hr_utility.set_location ('New Value '||p_new_value,10);
  --
  p_break := 'NONE';
  --
  if p_min_value is null then
    --
    l_min_value := 0;
    --
  else
    --
    l_min_value := p_min_value;
    --
  end if;
  --
  if p_max_value is null then
    --
    l_max_value := 999999999;
    --
  else
    --
    l_max_value := p_max_value;
    --
  end if;
  --- bug :  1540610
  --- if  1  to  20   it should contol  1 to 20.99
  --- if  .1 to  .2   it shound control .1  to .29
/**
  if p_decimal_level = 'Y' then
     if  round(l_max_value,0) <>  l_max_value then
         l_max_value := ( l_max_value * 100)  + 1      ;
         l_min_value := ( l_min_value * 100)           ;
         l_old_value := ( nvl(l_old_value,0) * 100)    ;
         l_new_value := ( nvl(l_new_value,0) * 100)    ;
     else
         l_max_value := ceil(l_max_value + 0.001) ;
     end if ;
  else
      l_max_value := ceil(l_max_value + 0.001) ;
  end if ;
*/
  --Bug 2101937 Assumption here is, if the user uses a decimal value in his min/max definition,
  --he has to use proper rounding code to round the value to the appropriately to get it in their
  --desired range.
  --- if  1  to  20   it should control  1 to < 21
  --- if  .1 to  .2   it shound control .1  to .2 ONLY
  -- if the old or new value is .225, then the rounding code should get the value in the
  -- appropriate band.
  --
  -- Bug 239011: Corrected typo, comparing l_min_value with trunc(l_min_value)
  --
  if ( p_decimal_level = 'Y'
         OR l_max_value <> trunc(l_max_value)
         OR l_min_value <> trunc(l_min_value) ) then
    --
    l_max_value := l_max_value + 0.000000001 ;
    --
  else
    --
    l_max_value := l_max_value + 1 ;
    --
  end if;

  --
  if p_old_value = p_new_value then
    --
    -- Values are same, so no boundary is crossed.
    --
    p_break  := 'NONE';
    l_return := false;
    --
  elsif p_new_value is null then
    --
    p_break  := 'NONE';
    l_return := false;
    --
  elsif p_old_value is null then
    --
    -- (maagrawa 12/20/99 Bug 4140) No breach when the old value is null.
    --
    p_break  := 'NONE';
    l_return := false;
    --
  elsif l_old_value >= l_min_value and l_old_value < l_max_value then
    --
    -- Old value lies in the range.
    --
    if l_new_value >= l_min_value and l_new_value < l_max_value then
      --
      -- New value also in the range, so no crossing.
      --
      p_break  := 'NONE';
      l_return := false;
      --
    elsif l_new_value >= l_max_value then
      --
      -- New value has crossed the maximum value.
      --
      p_break  := 'GT_MAX';
      l_return := true;
      --
    elsif l_new_value < l_min_value then
      --
      -- New value has gone below the minimum, so minimum value crossing.
      --
      p_break  := 'LT_MIN';
      l_return := true;
      --
    end if;
    --
  elsif l_old_value >= l_max_value then
    --
    -- Old value is above the maximum.
    --
    if l_new_value >= l_min_value and l_new_value < l_max_value then
      --
      -- New value returns within range, so maximum border is crossed.
      --
      p_break  := 'LT_MAX';
      l_return := true;
      --
    else
      --
      -- Still not in range.
      --
      p_break  := 'NONE';
      l_return := false;
      --
    end if;
    --
  elsif l_old_value < l_min_value then
    --
    -- Old value is below the minimum value.
    --
    if l_new_value >= l_min_value and l_new_value < l_max_value then
      --
      -- New value is in range, so we have crossed the minimum border.
      --
      p_break  := 'GT_MIN';
      l_return := true;
      --
    else
      --
      -- Still not in range, so no crossing.
      --
      p_break  := 'NONE';
      l_return := false;
      --
    end if;
    --
  end if;
  --
--  hr_utility.set_location ('Leaving '||l_package,10);
  --
  return l_return;
  --
end min_max_breach;

------------------------------------------------------------------------
--  eot_to_null
------------------------------------------------------------------------
function eot_to_null(p_date in date) return date is
  --
  l_date     date         := null;
  l_package  varchar2(80) := 'benutils.eot_to_null';
  --
begin
  --
  hr_utility.set_location ('Entering '||l_package,10);
  --
  if p_date = hr_api.g_eot then
     --
     l_date := null;
     --
  else
     --
     l_date := p_date;
     --
  end if;
  --
  hr_utility.set_location ('Leaving '||l_package,10);
  return(l_date);
  --
end eot_to_null;
--
function eot_to_null(p_date in varchar2) return varchar2 is
  --
  l_date     date         := null;
  l_package  varchar2(80) := 'benutils.eot_to_null';
  --
begin
  --
  hr_utility.set_location ('Entering '||l_package,5);
  --
  l_date   := benutils.eot_to_null(to_date(p_date,'DD/MM/YYYY'));
  --
  hr_utility.set_location ('Leaving '||l_package,5);
  return(to_char(l_date,'DD/MM/YYYY'));
  --
end eot_to_null;
--
--
function get_message_name return varchar2 is
  --
  l_message      varchar2(600);
  l_message_name varchar2(240);
  l_app_name     varchar2(240);
  --
begin
  --
  l_message := fnd_message.get_encoded;
  fnd_message.set_encoded(l_message);
  --
  fnd_message.parse_encoded(encoded_message => l_message,
                            app_short_name  => l_app_name,
                            message_name    => l_message_name);
  --
  return(l_message_name);
  --
end get_message_name;
--
------------------------------------------------------------------------
--  set_to_oct1_prev_year
------------------------------------------------------------------------
function set_to_oct1_prev_year(p_date in date) return date is
  --
  l_package          varchar2(80) := 'set_to_oct1_prev_year';
  l_date             date;
  l_months           number := 12;
  --
begin
  --
  hr_utility.set_location ('Entering '||l_package,10);
  --
  -- Set to prev year
  --
  l_months := to_number(to_char(p_date,'MM'))+3;
  --
  l_date := add_months(p_date,-l_months);
  --
  -- Set to first of month of October
  --
  l_date := last_day(l_date)+1;
  --
  hr_utility.set_location ('Leaving '||l_package,10);
  return l_date;
  --
end set_to_oct1_prev_year;

------------------------------------------------------------------------
--  formula
------------------------------------------------------------------------
function formula(p_formula_id            in number,
                 p_business_group_id     in number   ,
                 p_payroll_id            in number   ,
                 p_payroll_action_id     in number   ,
                 p_assignment_id         in number   ,
                 p_assignment_action_id  in number   ,
                 p_org_pay_method_id     in number   ,
                 p_per_pay_method_id     in number   ,
                 p_organization_id       in number   ,
                 p_tax_unit_id           in number   ,
                 p_jurisdiction_code     in varchar2 ,
                 p_balance_date          in date     ,
                 p_element_entry_id      in number   ,
                 p_element_type_id       in number   ,
                 p_original_entry_id     in number   ,
                 p_tax_group             in number   ,
                 p_pgm_id                in number   ,
                 p_pl_id                 in number   ,
                 p_pl_typ_id             in number   ,
                 p_opt_id                in number   ,
                 p_ler_id                in number   ,
                 p_communication_type_id in number   ,
                 p_action_type_id        in number   ,
                 p_acty_base_rt_id       in number   ,
                 p_elig_per_elctbl_chc_id in number  ,
                 p_enrt_bnft_id          in number   ,
                 p_regn_id               in number   ,
                 p_rptg_grp_id           in number   ,
                 p_cm_dlvry_mthd_cd      in varchar2 ,
                 p_crt_ordr_typ_cd       in varchar2 ,
                 p_enrt_ctfn_typ_cd      in varchar2 ,
                 p_bnfts_bal_id          in number   ,
                 p_elig_per_id           in number   ,
                 p_per_cm_id             in number   ,
                 p_prtt_enrt_actn_id     in number   ,
                 p_effective_date        in date,
                 p_param1                in varchar2 ,
                 p_param1_value          in varchar2 ,
                 p_param2                in varchar2 ,
                 p_param2_value          in varchar2 ,
                 p_param3                in varchar2 ,
                 p_param3_value          in varchar2 ,
                 p_param4                in varchar2 ,
                 p_param4_value          in varchar2 ,
                 p_param5                in varchar2 ,
                 p_param5_value          in varchar2 ,
                 p_param6                in varchar2 ,
                 p_param6_value          in varchar2 ,
                 p_param7                in varchar2 ,
                 p_param7_value          in varchar2 ,
                 p_param8                in varchar2 ,
                 p_param8_value          in varchar2 ,
                 p_param9                in varchar2 ,
                 p_param9_value          in varchar2 ,
                 p_param10               in varchar2 ,
                 p_param10_value         in varchar2 ,
                 p_param11               in varchar2 ,
                 p_param11_value         in varchar2 ,
                 p_param12               in varchar2 ,
                 p_param12_value         in varchar2 ,
                 p_param13               in varchar2 ,
                 p_param13_value         in varchar2 ,
                 p_param14               in varchar2 ,
                 p_param14_value         in varchar2 ,
                 p_param15               in varchar2 ,
                 p_param15_value         in varchar2 ,
                 p_param16               in varchar2 ,
                 p_param16_value         in varchar2 ,
                 p_param17               in varchar2 ,
                 p_param17_value         in varchar2 ,
                 p_param18               in varchar2 ,
                 p_param18_value         in varchar2 ,
                 p_param19               in varchar2 ,
                 p_param19_value         in varchar2 ,
                 p_param20              in varchar2 ,
                 p_param20_value        in varchar2 ,
                 p_param21              in varchar2 ,
                 p_param21_value        in varchar2 ,
                 p_param22              in varchar2 ,
                 p_param22_value        in varchar2 ,
                 p_param23              in varchar2 ,
                 p_param23_value        in varchar2 ,
                 p_param24              in varchar2 ,
                 p_param24_value        in varchar2 ,
                 p_param25              in varchar2 ,
                 p_param25_value        in varchar2 ,
                 p_param26              in varchar2 ,
                 p_param26_value        in varchar2 ,
                 p_param27              in varchar2 ,
                 p_param27_value        in varchar2 ,
                 p_param28              in varchar2 ,
                 p_param28_value        in varchar2 ,
                 p_param29              in varchar2 ,
                 p_param29_value        in varchar2 ,
                 p_param30              in varchar2 ,
                 p_param30_value        in varchar2 ,
                 p_param31              in varchar2 ,
                 p_param31_value        in varchar2 ,
                 p_param32              in varchar2 ,
                 p_param32_value        in varchar2 ,
                 p_param33              in varchar2 ,
                 p_param33_value        in varchar2 ,
                 p_param34              in varchar2 ,
                 p_param34_value        in varchar2 ,
                 p_param35              in varchar2 ,
                 p_param35_value        in varchar2 ,
                 p_param_tab            in ff_exec.outputs_t
)
    return ff_exec.outputs_t is
  --
  l_package   varchar2(80) := 'formula';
  l_inputs    ff_exec.inputs_t;
  l_outputs   ff_exec.outputs_t;
  j int;
  l_param_tab_count number;
  --
  -- Bug 1949361 : Jurisdiction code should be fetched only for
  -- US legislation code.
  --
  cursor c_asg is
    select asg.assignment_id,asg.organization_id,loc.region_2
    from   per_all_assignments_f asg,hr_locations_all loc
    where  asg.assignment_id = p_assignment_id
    and    asg.primary_flag = 'Y'
    and    asg.location_id  = loc.location_id(+)
    and    p_effective_date
           between asg.effective_start_date
           and     asg.effective_end_date;
  --
  l_asg c_asg%rowtype;
  --
/*  cursor c_leg is
    select bg.legislation_code
    from   per_business_groups bg
    where  bg.business_group_id = p_business_group_id;
*/
--
 cursor c_leg is
 SELECT O3.ORG_INFORMATION9
 FROM HR_ALL_ORGANIZATION_UNITS O ,
     HR_ORGANIZATION_INFORMATION O3
 where O.ORGANIZATION_ID = O3.ORGANIZATION_ID
 and   O3.ORG_INFORMATION_CONTEXT = 'Business Group Information'
 and o.ORGANIZATION_ID = p_business_group_id
 and o.business_group_id = p_business_group_id;
--
  l_legislation_code  varchar2(150);
  l_jurisdiction_code varchar2(150);
--
begin
  --
--  hr_utility.set_location ('Entering '||l_package,10);
  --
--  hr_utility.set_location ('Before Init Formula '||l_package,10);
  --
  -- Bug 1949361 : Get the jurisdiction code for US legislation only.
  --
  open c_leg;
    fetch c_leg into l_legislation_code;
  close c_leg;
  --
  --
  -- Enhancement only do this if they are in US using vertex validation
  -- for addresses.
  -- allows US business group to be used for a Global instance
  --
  if l_legislation_code = 'US' then
   if hr_general.chk_maintain_tax_records = 'Y' then
     --
     open c_asg;
     fetch c_asg into l_asg;
     close c_asg;
     --
     if l_asg.region_2 is not null then

       l_jurisdiction_code :=
         pay_mag_utils.lookup_jurisdiction_code
           (p_state => l_asg.region_2);

     end if; -- region 2 check
  --
   end if; -- Tax records check
  --
  end if; -- US Legislation check
  ff_exec.init_formula
       (p_formula_id     => p_formula_id,
        p_effective_date => p_effective_date,
        p_inputs         => l_inputs,
        p_outputs        => l_outputs);
--  hr_utility.set_location ('After Init Formula '||l_package,10);
  --
  -- NOTE that we use special parameter values in order to state which
  -- array locations we put the values into, this is because of the caching
  -- mechanism that formula uses.
  --
--  hr_utility.set_location ('First Position'||l_inputs.first,10);
--  hr_utility.set_location ('Last Position'||l_inputs.last,10);
  l_param_tab_count := p_param_tab.count;
  --
  -- Account for case where formula has no contexts or inputs
  --
  for l_count in nvl(l_inputs.first,0)..nvl(l_inputs.last,-1) loop
    --
--    hr_utility.set_location ('Current Context'||l_inputs(l_count).name,10);
    --
    if l_inputs(l_count).name = 'BUSINESS_GROUP_ID' then
      --
      l_inputs(l_count).value := nvl(p_business_group_id, -1);
      --
    elsif l_inputs(l_count).name = 'PAYROLL_ID' then
      --
      l_inputs(l_count).value := nvl(p_bnfts_bal_id, nvl(p_rptg_grp_id, nvl(p_payroll_id,-1)));
      --
    elsif l_inputs(l_count).name = 'PAYROLL_ACTION_ID' then
      --
      l_inputs(l_count).value := nvl(p_acty_base_rt_id, nvl(p_payroll_action_id, -1));
      --
    elsif l_inputs(l_count).name = 'ASSIGNMENT_ID' then
      --
      l_inputs(l_count).value := nvl(p_assignment_id, -1);
      --
    elsif l_inputs(l_count).name = 'ASSIGNMENT_ACTION_ID' then
      --
      l_inputs(l_count).value := nvl(p_assignment_action_id, -1);
      --
    elsif l_inputs(l_count).name = 'ORG_PAY_METHOD_ID' then
      --
      l_inputs(l_count).value := nvl(p_per_cm_id,nvl(p_prtt_enrt_actn_id, nvl(p_enrt_bnft_id, nvl(p_org_pay_method_id, -1))));
      --
    elsif l_inputs(l_count).name = 'PER_PAY_METHOD_ID' then
      --
      l_inputs(l_count).value := nvl(p_elig_per_id, nvl(p_regn_id, nvl(p_per_pay_method_id, -1)));
      --
    elsif l_inputs(l_count).name = 'ORGANIZATION_ID' then
      --
      l_inputs(l_count).value := nvl(p_elig_per_elctbl_chc_id, nvl(p_organization_id, -1));
      --
    elsif l_inputs(l_count).name = 'TAX_UNIT_ID' then
      --
      l_inputs(l_count).value := nvl(p_tax_unit_id, -1);
      --
    elsif l_inputs(l_count).name = 'JURISDICTION_CODE' then
      --
      l_inputs(l_count).value := nvl(p_cm_dlvry_mthd_cd, nvl(p_crt_ordr_typ_cd,nvl(l_jurisdiction_code, 'xx')));
      --
    elsif l_inputs(l_count).name = 'SOURCE_TEXT' then
      --
      l_inputs(l_count).value := nvl(p_enrt_ctfn_typ_cd, 'xx');
      --
    elsif l_inputs(l_count).name = 'BALANCE_DATE' then
      --
      l_inputs(l_count).value := fnd_date.date_to_canonical(p_balance_date);
      --
    elsif l_inputs(l_count).name = 'ELEMENT_ENTRY_ID' then
      --
      l_inputs(l_count).value := nvl(p_element_entry_id, -1);
      --
    elsif l_inputs(l_count).name = 'ORIGINAL_ENTRY_ID' then
      --
      l_inputs(l_count).value := nvl(p_original_entry_id, -1);
      --
    elsif l_inputs(l_count).name = 'TAX_GROUP' then
      --
      l_inputs(l_count).value := p_tax_group;
      --
    elsif l_inputs(l_count).name = 'PGM_ID' then
      --
      l_inputs(l_count).value := nvl(p_pgm_id,-1);
      --
    elsif l_inputs(l_count).name = 'PL_ID' then
      --
      l_inputs(l_count).value := nvl(p_pl_id,-1);
      --
    elsif l_inputs(l_count).name = 'PL_TYP_ID' then
      --
      l_inputs(l_count).value := nvl(p_pl_typ_id,-1);
      --
    elsif l_inputs(l_count).name = 'OPT_ID' then
      --
      l_inputs(l_count).value := nvl(p_opt_id,-1);
      --
    elsif l_inputs(l_count).name = 'LER_ID' then
      --
      l_inputs(l_count).value := nvl(p_ler_id,-1);
      --
    elsif l_inputs(l_count).name = 'COMM_TYP_ID' then
      --
      l_inputs(l_count).value := nvl(p_communication_type_id,-1);
      --
    elsif l_inputs(l_count).name = 'ACT_TYP_ID' then
      --
      l_inputs(l_count).value := nvl(p_action_type_id,-1);
      --
    elsif l_inputs(l_count).name = 'DATE_EARNED' then
      --
      -- Note that you must pass the date as a string, that is because
      -- of the canonical date change of 11.5
      --
      -- hr_utility.set_location ('Date Earned '||to_char(p_effective_date),10);
      -- Still the fast formula does't accept the full canonical form.
      -- l_inputs(l_count).value := fnd_date.date_to_canonical(p_effective_date);
      l_inputs(l_count).value := to_char(p_effective_date, 'YYYY/MM/DD');
      --
    -- Bug 6676772
   /* elsif l_param_tab_count >0 then
         for j in 1..l_param_tab_count
         loop
            if l_inputs(l_count).name = p_param_tab(j).name then
               l_inputs(l_count).value := p_param_tab(j).value;
	       exit;
            end if;
         end loop;*/
    -- Bug 6676772
    elsif l_inputs(l_count).name = p_param1 then
      --
      l_inputs(l_count).value := p_param1_value;
      --
    elsif l_inputs(l_count).name = p_param2 then
      --
      l_inputs(l_count).value := p_param2_value;
      --
    elsif l_inputs(l_count).name = p_param3 then
      --
      l_inputs(l_count).value := p_param3_value;
      --
    elsif l_inputs(l_count).name = p_param4 then
      --
      l_inputs(l_count).value := p_param4_value;
      --
    elsif l_inputs(l_count).name = p_param5 then
      --
      l_inputs(l_count).value := p_param5_value;
      --
    elsif l_inputs(l_count).name = p_param6 then
      --
      l_inputs(l_count).value := p_param6_value;
      --
    elsif l_inputs(l_count).name = p_param7 then
      --
      l_inputs(l_count).value := p_param7_value;
      --
    elsif l_inputs(l_count).name = p_param8 then
      --
      l_inputs(l_count).value := p_param8_value;
      --
    elsif l_inputs(l_count).name = p_param9 then
      --
      l_inputs(l_count).value := p_param9_value;
      --
    elsif l_inputs(l_count).name = p_param10 then
      --
      l_inputs(l_count).value := p_param10_value;
      --
    elsif l_inputs(l_count).name = p_param11 then
      --
      l_inputs(l_count).value := p_param11_value;
      --
    elsif l_inputs(l_count).name = p_param12 then
      --
      l_inputs(l_count).value := p_param12_value;
      --
    elsif l_inputs(l_count).name = p_param13 then
      --
      l_inputs(l_count).value := p_param13_value;
      --
    elsif l_inputs(l_count).name = p_param14 then
      --
      l_inputs(l_count).value := p_param14_value;
      --
    elsif l_inputs(l_count).name = p_param15 then
      --
      l_inputs(l_count).value := p_param15_value;
      --
    elsif l_inputs(l_count).name = p_param16 then
      --
      l_inputs(l_count).value := p_param16_value;
      --
    elsif l_inputs(l_count).name = p_param17 then
      --
      l_inputs(l_count).value := p_param17_value;
      --
    elsif l_inputs(l_count).name = p_param18 then
      --
      l_inputs(l_count).value := p_param18_value;
      --
    elsif l_inputs(l_count).name = p_param19 then
      --
      l_inputs(l_count).value := p_param19_value;
      --
    elsif l_inputs(l_count).name = p_param20 then
      --
      l_inputs(l_count).value := p_param20_value;
      --
    elsif l_inputs(l_count).name = p_param21 then
      --
      l_inputs(l_count).value := p_param21_value;
      --
    elsif l_inputs(l_count).name = p_param22 then
      --
      l_inputs(l_count).value := p_param22_value;
      --
    elsif l_inputs(l_count).name = p_param23 then
      --
      l_inputs(l_count).value := p_param23_value;
      --
    elsif l_inputs(l_count).name = p_param24 then
      --
      l_inputs(l_count).value := p_param24_value;
      --
    elsif l_inputs(l_count).name = p_param25 then
      --
      l_inputs(l_count).value := p_param25_value;
      --
    elsif l_inputs(l_count).name = p_param26 then
      --
      l_inputs(l_count).value := p_param26_value;
      --
    elsif l_inputs(l_count).name = p_param27 then
      --
      l_inputs(l_count).value := p_param27_value;
      --
    elsif l_inputs(l_count).name = p_param28 then
      --
      l_inputs(l_count).value := p_param28_value;
      --
    elsif l_inputs(l_count).name = p_param29 then
      --
      l_inputs(l_count).value := p_param29_value;
      --
    elsif l_inputs(l_count).name = p_param30 then
      --
      l_inputs(l_count).value := p_param30_value;
      --
    elsif l_inputs(l_count).name = p_param31 then
      --
      l_inputs(l_count).value := p_param31_value;
      --
    elsif l_inputs(l_count).name = p_param32 then
      --
      l_inputs(l_count).value := p_param32_value;
      --
    elsif l_inputs(l_count).name = p_param33 then
      --
      l_inputs(l_count).value := p_param33_value;
      --
    elsif l_inputs(l_count).name = p_param34 then
      --
      l_inputs(l_count).value := p_param34_value;
      --
    elsif l_inputs(l_count).name = p_param35 then
      --
      l_inputs(l_count).value := p_param35_value;
      --
    -- Bug 6676772
    elsif l_param_tab_count >0 then
         for j in 1..l_param_tab_count
         loop
            if l_inputs(l_count).name = p_param_tab(j).name then
               l_inputs(l_count).value := p_param_tab(j).value;
	       exit;
            end if;
         end loop;
   -- Bug 6676772
   --
    end if;
    --
  end loop;
  --
  -- Ok we have loaded the input record now run the formula.
  --
  ff_exec.run_formula(p_inputs  => l_inputs,
                      p_outputs => l_outputs,
                      p_use_dbi_cache => false); -- bug# 2430017
  --
  --  hr_utility.set_location ('Leaving '||l_package,10);
  return l_outputs;
  --
end formula;
--
-- This procedure is used to execute the rule : per_info_chg_cs_ler_rl
-- This procedure is called from the trigger packages like
-- ben_add_ler.
--
procedure exec_rule(
             p_formula_id        in  number,
             p_effective_date    in  date,
             p_lf_evt_ocrd_dt    in  date,
             p_business_group_id in  number,
             p_person_id         in  number ,
             p_new_value         in  varchar2 ,
             p_old_value         in  varchar2 ,
             p_column_name       in  varchar2 ,
             p_pk_id             in  varchar2 ,
             p_param5            in varchar2 ,
             p_param5_value      in varchar2 ,
             p_param6            in varchar2 ,
             p_param6_value      in varchar2 ,
             p_param7            in varchar2 ,
             p_param7_value      in varchar2 ,
             p_param8            in varchar2 ,
             p_param8_value      in varchar2 ,
             p_param9            in varchar2 ,
             p_param9_value      in varchar2 ,
             p_param10           in varchar2 ,
             p_param10_value     in varchar2 ,
             p_param11            in varchar2 ,
             p_param11_value      in varchar2 ,
             p_param12            in varchar2 ,
             p_param12_value      in varchar2 ,
             p_param13            in varchar2 ,
             p_param13_value      in varchar2 ,
             p_param14            in varchar2 ,
             p_param14_value      in varchar2 ,
             p_param15            in varchar2 ,
             p_param15_value      in varchar2 ,
             p_param16            in varchar2 ,
             p_param16_value      in varchar2 ,
             p_param17            in varchar2 ,
             p_param17_value      in varchar2 ,
             p_param18            in varchar2 ,
             p_param18_value      in varchar2 ,
             p_param19            in varchar2 ,
             p_param19_value      in varchar2 ,
             p_param20           in varchar2 ,
             p_param20_value     in varchar2 ,
             p_param21           in varchar2 ,
             p_param21_value     in varchar2 ,
             p_param22           in varchar2 ,
             p_param22_value     in varchar2 ,
             p_param23           in varchar2 ,
             p_param23_value     in varchar2 ,
             p_param24           in varchar2 ,
             p_param24_value     in varchar2 ,
             p_param25           in varchar2 ,
             p_param25_value     in varchar2 ,
             p_param26           in varchar2 ,
             p_param26_value     in varchar2 ,
             p_param27           in varchar2 ,
             p_param27_value     in varchar2 ,
             p_param28           in varchar2 ,
             p_param28_value     in varchar2 ,
             p_param29           in varchar2 ,
             p_param29_value     in varchar2 ,
             p_param30           in varchar2 ,
             p_param30_value     in varchar2 ,
             p_param31           in varchar2 ,
             p_param31_value     in varchar2 ,
             p_param32           in varchar2 ,
             p_param32_value     in varchar2 ,
             p_param33           in varchar2 ,
             p_param33_value     in varchar2 ,
             p_param34           in varchar2 ,
             p_param34_value     in varchar2 ,
             p_param35           in varchar2 ,
             p_param35_value     in varchar2 ,
             p_param_tab         in ff_exec.outputs_t ,
             p_ret_val           out nocopy varchar2) is
         --

  l_package            varchar2(80) := g_package||'.run_rule';
  l_outputs            ff_exec.outputs_t;
  l_loc_rec            hr_locations_all%rowtype;
  l_ass_rec            per_all_assignments_f%rowtype;
  l_jurisdiction_code  varchar2(30);
  l_env                ben_env_object.g_global_env_rec_type;
  --
begin
    --
    hr_utility.set_location ('Entering '||l_package,10);
    --
    -- Bug : 1656320  : context assignment id is not available.
    -- Add environment init procedure
    -- Work out if we are being called from a concurrent program
    -- otherwise we need to initialize the environment to set the business_goup_id
    -- and effective_date in the cache, so that assignment get_object
    -- routines work fine.
    --
    hr_utility.set_location('p_ff_date '||p_effective_date ||
                            ' p_leod ' || p_lf_evt_ocrd_dt,11);
    --
    -- if fnd_global.conc_request_id = -1 then
    -- bug 4947096
    if ben_env_object.g_global_env_rec.business_group_id is NULL
    then
       --
       -- This makes sense for the calls made from the forms.
       --
       ben_env_object.init(p_business_group_id  => p_business_group_id,
                        p_effective_date     => p_effective_date,
                        p_thread_id          => 1,
                        p_chunk_size         => 1,
                        p_threads            => 1,
                        p_max_errors         => 1,
                        p_benefit_action_id  => null);
       --
    end if;
    --
    -- Call formula initialise routine
    --
    if p_person_id is not null then
       ben_person_object.get_object(p_person_id => p_person_id,
                                 p_rec       => l_ass_rec);
    end if;
    --
    if p_person_id is not null and l_ass_rec.assignment_id is null then
      --
      ben_person_object.get_benass_object(p_person_id => p_person_id,
                                          p_rec       => l_ass_rec);
      --
    end if;
    --
    -- Bug 1949361 : jurisdiction_code is fetched inside the
    -- benutils.formula call.
    --
    /*
    if l_ass_rec.location_id is not null then
      --
      ben_location_object.get_object(p_location_id => l_ass_rec.location_id,
                                     p_rec         => l_loc_rec);
      --
      if l_loc_rec.region_2 is not null then
        --
        l_jurisdiction_code :=
           pay_mag_utils.lookup_jurisdiction_code
            (p_state => l_loc_rec.region_2);
        --
      end if;
      --
    end if;
    */
    --
    hr_utility.set_location('assignment_id '||l_ass_rec.assignment_id , 13);
    l_outputs := benutils.formula
      (p_formula_id        => p_formula_id,
       p_effective_date    => nvl(p_lf_evt_ocrd_dt,p_effective_date),
       p_assignment_id     => l_ass_rec.assignment_id,
       p_organization_id   => l_ass_rec.organization_id,
       p_business_group_id => p_business_group_id,
       p_param1            => 'NEW_VAL',
       p_param1_value      => p_new_value,
       p_param2            => 'OLD_VAL',
       p_param2_value      => p_old_value,
       p_param3            => 'COLUMN',
       p_param3_value      => p_column_name,
       p_param4            => 'PK_ID',
       p_param4_value      => p_pk_id,
       p_param5            => p_param5,
       p_param5_value      => p_param5_value,
       p_param6            => p_param6,
       p_param6_value      => p_param6_value,
       p_param7            => p_param7,
       p_param7_value      => p_param7_value,
       p_param8            => p_param8,
       p_param8_value      => p_param8_value,
       p_param9            => p_param9,
       p_param9_value      => p_param9_value,
       p_param10           => p_param10,
       p_param10_value     => p_param10_value,
       p_param11           => p_param11,
       p_param11_value     => p_param11_value,
       p_param12           => p_param12,
       p_param12_value     => p_param12_value,
       p_param13           => p_param13,
       p_param13_value     => p_param13_value,
       p_param14           => p_param14,
       p_param14_value     => p_param14_value,
       p_param15           => p_param15,
       p_param15_value     => p_param15_value,
       p_param16           => p_param16,
       p_param16_value     => p_param16_value,
       p_param17           => p_param17,
       p_param17_value     => p_param17_value,
       p_param18           => p_param18,
       p_param18_value     => p_param18_value,
       p_param19           => p_param19,
       p_param19_value     => p_param19_value,
       p_param20           => p_param20,
       p_param20_value     => p_param20_value,
       p_param21           => p_param21,
       p_param21_value     => p_param21_value,
       p_param22           => p_param22,
       p_param22_value     => p_param22_value,
       p_param23           => p_param23,
       p_param23_value     => p_param23_value,
       p_param24           => p_param24,
       p_param24_value     => p_param24_value,
       p_param25           => p_param25,
       p_param25_value     => p_param25_value,
       p_param26           => p_param26,
       p_param26_value     => p_param26_value,
       p_param27           => p_param27,
       p_param27_value     => p_param27_value,
       p_param28           => p_param28,
       p_param28_value     => p_param28_value,
       p_param29           => p_param29,
       p_param29_value     => p_param29_value,
       p_param30           => p_param30,
       p_param30_value     => p_param30_value,
       p_param31           => p_param31,
       p_param31_value     => p_param31_value,
       p_param32           => p_param32,
       p_param32_value     => p_param32_value,
       p_param33           => p_param33,
       p_param33_value     => p_param33_value,
       p_param34           => p_param34,
       p_param34_value     => p_param34_value,
       --
       -- Bug 1656320 : As so many params are not used and person_id is
       -- a good input value just pass it.
       --
       p_param35           => 'PERSON_ID', -- p_param35,
       p_param35_value     => to_char(p_person_id), -- p_param35_value,
       p_param_tab         => p_param_tab,
       p_jurisdiction_code => l_jurisdiction_code);
    --
    p_ret_val := l_outputs(l_outputs.first).value;
    --
    if p_ret_val <> 'Y' and p_ret_val <> 'N' then
       --
       -- Defensive coding : If formula returns other than Y/N then
       -- ptnl is created based on old val and new val.
       --
       p_ret_val := 'Y';
       --
    end if;
    --
    hr_utility.set_location ('Leaving '||l_package,10);
    --
end exec_rule;
--
--
function get_rt_val(p_per_in_ler_id  in number,
                     p_prtt_rt_val_id in number,
  		      p_effective_date in date)
return number is
  -- 4710155 : Old cursor prior to non-recurring rate fix 4460101
  cursor c_prv1 is
   select nvl(prv.cmcd_rt_val,0)
   from   ben_prtt_rt_val prv
   where  prv.prtt_rt_val_id = p_prtt_rt_val_id
   and    prv.per_in_ler_id  = p_per_in_ler_id
   and    prv.prtt_rt_val_stat_cd is null    -- Added for Bug 6048854
   and    prv.rt_strt_dt <= prv.rt_end_dt;
      --Commented for Bug 6048854
   --and    prv.rt_end_dt = hr_api.g_eot;
  --
  --

  /* Commented for Bug 6048854
   cursor c_prv2 is
   select nvl(prv.cmcd_rt_val,0)
   from   ben_prtt_rt_val prv
   where  prv.prtt_rt_val_id = p_prtt_rt_val_id
   and    prv.per_in_ler_id  = p_per_in_ler_id
    Bug 5376185 : Pick the latest non-recurring rate
   and    prv.rt_strt_dt = prv.rt_end_dt
   and    prv.rt_end_dt <> hr_api.g_eot;
  */
  --
  l_rt_val   number       := null;
  --
begin
  --
  if p_per_in_ler_id is not null and p_prtt_rt_val_id is not null then
    -- 4710155 : Fetch the rate from old cursor first
    open c_prv1;
    fetch c_prv1 into l_rt_val;
    close c_prv1;

    /* Commented for Bug 6048854
    --
		-- 4710155 : If the old cursor does not fetch rate then
		-- get the rate using new cursor
		if l_rt_val is null then
			open c_prv2;
			fetch c_prv2 into l_rt_val;
			close c_prv2;
		end if;
    --
    */
  end if;
  --
  return l_rt_val;
  --
end get_rt_val;
--

--
function get_ann_rt_val(p_per_in_ler_id  in number,
                    p_prtt_rt_val_id in number,
										p_effective_date in date)
return number is
  -- 4710155 : Old cursor prior to non-recurring rate fix 4460101
  cursor c_prv1 is
   select nvl(prv.ann_rt_val,0)
   from   ben_prtt_rt_val prv
   where  prv.prtt_rt_val_id = p_prtt_rt_val_id
   and    prv.per_in_ler_id  = p_per_in_ler_id
   and    prv.prtt_rt_val_stat_cd is null    -- Added for Bug 6048854
   and    prv.rt_strt_dt <= prv.rt_end_dt;
      --Commented for Bug 6048854
   --and    prv.rt_end_dt = hr_api.g_eot;
  --
  --
  /* Commented for Bug 6048854
  cursor c_prv2 is
   select nvl(prv.ann_rt_val,0)
   from   ben_prtt_rt_val prv
   where  prv.prtt_rt_val_id = p_prtt_rt_val_id
   and    prv.per_in_ler_id  = p_per_in_ler_id
   Bug 5376185 : Pick the latest non-recurring rate
   and    prv.rt_strt_dt = prv.rt_end_dt
   and    prv.rt_end_dt <> hr_api.g_eot;
   */
  --
  l_rt_val   number       := null;
  --
begin
  --
  if p_per_in_ler_id is not null and p_prtt_rt_val_id is not null then
    -- 4710155 : Fetch the rate from old cursor first
    open c_prv1;
    fetch c_prv1 into l_rt_val;
    close c_prv1;
    --
		/* Commented for Bug 6048854
		-- 4710155 : If the old cursor does not fetch rate then
		-- get the rate using new cursor
		if l_rt_val is null then
			open c_prv2;
			fetch c_prv2 into l_rt_val;
			close c_prv2;
		end if;
		*/
    --
  end if;
  --
  return l_rt_val;
  --
end get_ann_rt_val;
--
--
function get_concat_val(p_per_in_ler_id  in number,
                    p_prtt_rt_val_id in number)
return varchar2 is
  --
  cursor c_prv is
   select to_char(nvl(prv.ann_rt_val,0))||'^'|| to_char(nvl(prv.cmcd_rt_val,0))||'^'||to_char(nvl(prv.rt_val,0))
   from   ben_prtt_rt_val prv
   where  prv.prtt_rt_val_id = p_prtt_rt_val_id
   and    prv.per_in_ler_id  = p_per_in_ler_id
   and    prv.rt_end_dt = hr_api.g_eot;
  --
  l_rt_val   varchar2(100) := null;
  --
begin
  --
  if p_per_in_ler_id is not null and p_prtt_rt_val_id is not null then
    --
    open c_prv;
    fetch c_prv into l_rt_val;
    close c_prv;
    --
  end if;
  --
  return l_rt_val;
  --
end get_concat_val;

--The column in the table which gives the value of val is rt_val but the name is already
-- being used by the function which gets value from the cmcd_rt_val hence name get_val.
function get_val(p_per_in_ler_id  in number,
                    p_prtt_rt_val_id in number,
										p_effective_date in date)
return number is
  -- 4710155 : Old cursor prior to non-recurring rate fix 4460101
  cursor c_prv1 is
   select nvl(prv.rt_val,0)
   from   ben_prtt_rt_val prv
   where  prv.prtt_rt_val_id = p_prtt_rt_val_id
   and    prv.per_in_ler_id  = p_per_in_ler_id
   and    prv.prtt_rt_val_stat_cd is null    -- Added for Bug 6048854
   and    prv.rt_strt_dt <= prv.rt_end_dt;
   --Commented for Bug 6048854
   --and    prv.rt_end_dt = hr_api.g_eot;
  --
  --
  /*Commented for Bug 6048854
  cursor c_prv2 is
   select nvl(prv.rt_val,0)
   from   ben_prtt_rt_val prv
   where  prv.prtt_rt_val_id = p_prtt_rt_val_id
   and    prv.per_in_ler_id  = p_per_in_ler_id
   Bug 5376185 : Pick the latest non-recurring rate
   and    prv.rt_strt_dt = prv.rt_end_dt
   and    prv.rt_end_dt <> hr_api.g_eot;
   */
  --
  l_rt_val   number       := null;
  --
begin
  --
  if p_per_in_ler_id is not null and p_prtt_rt_val_id is not null then
    -- 4710155 : Fetch the rate from old cursor first
    open c_prv1;
    fetch c_prv1 into l_rt_val;
    close c_prv1;
    --
		/*Commented for Bug 6048854
		-- 4710155 : If the old cursor does not fetch rate then
		-- get the rate using new cursor
		if l_rt_val is null then
			open c_prv2;
			fetch c_prv2 into l_rt_val;
			close c_prv2;
		end if;
		*/
    --
  end if;
  --
  return l_rt_val;
  --
end get_val;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------< get_post_enrt_cvg_and_rt_val >---------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- Procedure to retrieve the Coverage amount and Rate Amount values for
-- those coverage and rates whose Calculation method is 'Post-Enrollment
-- Calculation Rule'
--
-- Pre-conditions: Specifically written for self-service and should be used
-- only after Election Information and Post-Process is called.
--
-- In Arguments: choice id, bnft id, and rt ids.
--
-- Post Success: returns all relevant amounts.
--
-- Post Failure: returns null
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-----------------------------------------------------------------------------
--
procedure get_post_enrt_cvg_and_rt_val
      (p_elig_per_elctbl_chc_id in number,
       p_enrt_bnft_id           in number default null,
       p_effective_date         in date,
       p_enrt_rt_id             in number default null,
       p_enrt_rt_id2            in number default null,
       p_enrt_rt_id3            in number default null,
       p_enrt_rt_id4            in number default null,
       p_bnft_amt               out nocopy number,
       p_val                    out nocopy number,
       p_rt_val                 out nocopy number,
       p_ann_rt_val             out nocopy number,
       p_val2                   out nocopy number,
       p_rt_val2                out nocopy number,
       p_ann_rt_val2            out nocopy number,
       p_val3                   out nocopy number,
       p_rt_val3                out nocopy number,
       p_ann_rt_val3            out nocopy number,
       p_val4                   out nocopy number,
       p_rt_val4                out nocopy number,
       p_ann_rt_val4            out nocopy number)
is
  --
  --l_package varchar2(80) := g_package||'.get_post_enrt_cvg_and_rt_val';
  --
  cursor c_pen_bnft_amt is
    select pen.bnft_amt
      from ben_prtt_enrt_rslt_f    pen,
         ben_elig_per_elctbl_chc epe,
         ben_enrt_bnft           enb
     where epe.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id
       and enb.enrt_bnft_id           = p_enrt_bnft_id
       and epe.elig_per_elctbl_chc_id = enb.elig_per_elctbl_chc_id
       -- and enb.mx_wo_ctfn_flag        = 'N'
       -- and enb.cvg_mlt_cd = 'ERL'
       -- commented, so that we retrieve SAAEAR cvgs based on ERL rates.
       and nvl(epe.prtt_enrt_rslt_id,
             enb.prtt_enrt_rslt_id) = pen.prtt_enrt_rslt_id
       and p_effective_date between
        pen.effective_start_date and pen.effective_end_date
       and pen.prtt_enrt_rslt_stat_cd is null
       and pen.enrt_cvg_thru_dt <= pen.effective_end_date;
  --
  l_bnft_amt number;
  cursor c_enrt_rt_val is
    select enrt_rt_id,
         nvl(prv.rt_val, 0)      val,
           nvl(prv.cmcd_rt_val, 0) rt_val,
           nvl(prv.ann_rt_val, 0)  ann_rt_val
      from ben_prtt_rt_val prv,
           ben_enrt_rt ecr
     where prv.prtt_rt_val_id = ecr.prtt_rt_val_id
       and ecr.enrt_rt_id in (p_enrt_rt_id, p_enrt_rt_id2,
            p_enrt_rt_id3, p_enrt_rt_id4);
       --and ecr.rt_mlt_cd = 'ERL';
       -- commented, so that we retrieve CVG rates based on ERL coverages.
  --
  --
begin
  --
  --hr_utility.set_location('Entering ' ||l_package, 10);
  --hr_utility.set_location('p_elig_per_elctbl_chc_id ' || to_char(p_elig_per_elctbl_chc_id ), 20);
  --hr_utility.set_location('p_enrt_bnft_id           ' || to_char(p_enrt_bnft_id           ), 20);
  --hr_utility.set_location('p_effective_date         ' || to_char(p_effective_date         ), 20);
  --hr_utility.set_location('p_enrt_rt_id             ' || to_char(p_enrt_rt_id             ), 20);
  --hr_utility.set_location('p_enrt_rt_id2            ' || to_char(p_enrt_rt_id2            ), 20);
  --hr_utility.set_location('p_enrt_rt_id3            ' || to_char(p_enrt_rt_id3            ), 20);
  --hr_utility.set_location('p_enrt_rt_id4            ' || to_char(p_enrt_rt_id4            ), 20);
  --
  open c_pen_bnft_amt;
  fetch c_pen_bnft_amt into l_bnft_amt;
  if c_pen_bnft_amt%found then
    --
    --hr_utility.set_location(' bnft amt found ' || to_char(l_bnft_amt), 30);
    p_bnft_amt := l_bnft_amt ;
    --
  end if;
  close c_pen_bnft_amt;
  --
  --
  for l_enrt_rt_val_rec in c_enrt_rt_val
  loop
    --
    if l_enrt_rt_val_rec.enrt_rt_id = p_enrt_rt_id then
      --
      p_val        := l_enrt_rt_val_rec.val;
      p_rt_val     := l_enrt_rt_val_rec.rt_val;
      p_ann_rt_val := l_enrt_rt_val_rec.ann_rt_val;
      --
    elsif l_enrt_rt_val_rec.enrt_rt_id = p_enrt_rt_id2 then
      --
      p_val2       := l_enrt_rt_val_rec.val;
      p_rt_val2    := l_enrt_rt_val_rec.rt_val;
      p_ann_rt_val2:= l_enrt_rt_val_rec.ann_rt_val;
      --
    elsif l_enrt_rt_val_rec.enrt_rt_id = p_enrt_rt_id3 then
      --
      p_val3       := l_enrt_rt_val_rec.val;
      p_rt_val3    := l_enrt_rt_val_rec.rt_val;
      p_ann_rt_val3:= l_enrt_rt_val_rec.ann_rt_val;
      --
    elsif l_enrt_rt_val_rec.enrt_rt_id = p_enrt_rt_id4 then
      --
      p_val4       := l_enrt_rt_val_rec.val;
      p_rt_val4    := l_enrt_rt_val_rec.rt_val;
      p_ann_rt_val4:= l_enrt_rt_val_rec.ann_rt_val;
      --
    end if;
    --
  end loop;
  --
  --hr_utility.set_location('Entering ' ||l_package, 10);
  --
exception
  --
  when others then
    --
    p_bnft_amt    := null;
    p_val         := null;
    p_rt_val      := null;
    p_ann_rt_val  := null;
    p_val2        := null;
    p_rt_val2     := null;
    p_ann_rt_val2 := null;
    p_val3        := null;
    p_rt_val3     := null;
    p_ann_rt_val3 := null;
    p_val4        := null;
    p_rt_val4     := null;
    p_ann_rt_val4 := null;
    --
    raise;
end get_post_enrt_cvg_and_rt_val;
--
function get_choice_status(p_elig_per_elctbl_chc_id in number)
return varchar2 is
  --
  cursor c_pending is
   select 'Y'
   from  wf_item_activity_statuses    process
        ,wf_item_attribute_values     choice_attribute
        ,wf_item_attribute_values     submit_attribute
        ,wf_process_activities        activity
        ,hr_api_transaction_steps     step
   where activity.activity_name      = 'HR_INDIVIDUAL_COMP_PRC'
   and   activity.process_item_type  = activity.activity_item_type
   and   activity.instance_id        = process.process_activity
   and   process.activity_status     = 'ACTIVE'
   and   process.item_key            = choice_attribute.item_key
   and   choice_attribute.item_type  = process.item_type
   and   choice_attribute.name       = 'COMP_CHOICE_ID'
   and   choice_attribute.text_value = p_elig_per_elctbl_chc_id
   and   submit_attribute.item_key   = process.item_key
   and   submit_attribute.item_type  = process.item_type
   and   submit_attribute.name       = 'TRAN_SUBMIT'
   and   submit_attribute.text_value = 'Y'
   and   step.item_type              = choice_attribute.item_type
   and   choice_attribute.item_key   = step.item_key
   and   step.api_name               = 'BEN_PROCESS_COMPENSATION_W.PROCESS_API';
  --
  l_return  varchar2(30) := 'N';
  --
begin
  --
  if p_elig_per_elctbl_chc_id is not null then
    --
    open  c_pending;
    fetch c_pending into l_return;
    close c_pending;
    --
  end if;
  --
  return l_return;
  --
end get_choice_status;
--
function in_workflow(p_person_id in number)
return varchar2 is
--
cursor in_wf(p_person_id NUMBER) is
      -- maagrawa (23/Sep/2005)
      -- re-wrote query for performance in case this function is used.
      select 'Y'
      from wf_item_activity_statuses process ,
           wf_process_activities activity ,
           hr_api_transactions txn,
           hr_api_transaction_steps step ,
           wf_item_attribute_values submit_attribute
      where activity.process_name = 'ROOT'
      and activity.process_item_type = activity.activity_item_type
      and activity.instance_id = process.process_activity
      and process.activity_status = 'ACTIVE'
      and txn.item_type = process.item_type
      and txn.item_key  = process.item_key
      and txn.selected_person_id = p_person_id
      and txn.transaction_id = step.transaction_id
      and step.api_name = 'BEN_PROCESS_COMPENSATION_W.PROCESS_API'
      and submit_attribute.text_value = 'Y'
      and txn.item_type = submit_attribute.item_type
      and txn.item_key = submit_attribute.item_key
      and submit_attribute.name = 'TRAN_SUBMIT';

l_return VARCHAR2(1) :='N';
begin
  --
  -- Bug 3116433 : This function's output is not used on the
  -- form. It is causing querying person on miscellaneous form
  -- to take too long.
  -- In case above cusror is needed the tuned sql is put in place
  -- above.
  /*
  open in_wf(p_person_id);
  --
  fetch in_wf into l_return;
  --
  close in_wf;
  --
  */
  return l_return;
end in_workflow;
--
--
-- Bug No 2258174
--
function basis_to_plan_conversion(p_pl_id          in number,
                                  p_effective_date in date,
                                  p_amount         in number,
                                  p_assignment_id  in number
                                 ) return number  is
 --
 -- Local variable declaration
 --
    l_ret_amount   NUMBER;
    l_precision    NUMBER;
    l_ref_perd_cd  VARCHAR2(30);
    l_factor       NUMBER;
 --
 -- Cursors declaration.
 --
  CURSOR c_ref_perd_cd IS
     select  pl.nip_acty_ref_perd_cd
            ,nvl(cur.precision,2)
       from  ben_pl_f pl
            ,fnd_currencies cur
      where pl.pl_id = p_pl_id
        and p_effective_date between pl.effective_start_date
        and pl.effective_end_date
        and cur.CURRENCY_CODE(+) = pl.nip_pl_uom
         ;
  CURSOR c_pay_basis IS
     select ppb.pay_annualization_factor
      from  per_all_assignments_f asg
           ,per_pay_bases ppb
      where asg.assignment_id = p_assignment_id
        and p_effective_date between asg.effective_start_date
        and asg.effective_end_date
        and ppb.pay_basis_id = asg.pay_basis_id
          ;

 --
 l_pay_annualization_factor number;
 --
BEGIN
  --
  OPEN  c_ref_perd_cd;
    FETCH c_ref_perd_cd into l_ref_perd_cd,l_precision;
    IF c_ref_perd_Cd%NOTFOUND THEN
      l_ref_perd_cd := 'NOVAL';
    END IF;
  CLOSE c_ref_perd_cd;
  --
  OPEN c_pay_basis;
    FETCH c_pay_basis into l_factor;
    IF l_factor is null THEN
      l_factor  := 1;
    END IF;
  CLOSE c_pay_basis;
  --
  IF l_ref_perd_cd = 'PWK' THEN
    l_ret_amount := (p_amount*l_factor)/52;
  ELSIF l_ref_perd_cd = 'BWK' THEN
    l_ret_amount := (p_amount*l_factor)/26;
  ELSIF l_ref_perd_cd = 'SMO' THEN
    l_ret_amount := (p_amount*l_factor)/24;
  ELSIF l_ref_perd_cd = 'PQU' THEN
    l_ret_amount := (p_amount*l_factor)/4;
  ELSIF l_ref_perd_cd = 'PYR' THEN
    l_ret_amount := (p_amount*l_factor)/1;
  ELSIF l_ref_perd_cd = 'SAN' THEN
    l_ret_amount := (p_amount*l_factor)/2;
  ELSIF l_ref_perd_cd = 'MO' THEN
    l_ret_amount := (p_amount*l_factor)/12;
  ELSIF l_ref_perd_cd = 'NOVAL' THEN
    l_ret_amount := (p_amount*l_factor)/1;
  ELSIF l_ref_perd_cd = 'PHR' then
    --
    l_pay_annualization_factor := to_number(fnd_profile.value('BEN_HRLY_ANAL_FCTR'));
    if l_pay_annualization_factor is null then
      l_pay_annualization_factor := 2080;
    end if;
    --
    l_ret_amount := (p_amount*l_factor)/l_pay_annualization_factor;
    --
  ELSE
    l_ret_amount := (p_amount*l_factor)/1;
  END IF;
  --
  RETURN round(l_ret_amount,l_precision);
 END basis_to_plan_conversion;
--
function plan_to_basis_conversion(p_pl_id          in number,
                                  p_effective_date in date,
                                  p_amount         in number,
                                  p_assignment_id  in number
                                 ) return number  is
 --
 -- Local variable declaration
 --
    l_ret_amount   NUMBER;
    l_precision    NUMBER;
    l_ref_perd_cd  VARCHAR2(30);
    l_factor       NUMBER;
 --
 -- Cursors declaration.
 --
  CURSOR c_ref_perd_cd IS
     select  pl.nip_acty_ref_perd_cd
            ,nvl(cur.precision,2)
       from  ben_pl_f pl
            ,fnd_currencies cur
      where pl.pl_id = p_pl_id
        and p_effective_date between pl.effective_start_date
        and pl.effective_end_date
        and cur.CURRENCY_CODE(+) = pl.nip_pl_uom
         ;
  CURSOR c_pay_basis IS
     select ppb.pay_annualization_factor
      from  per_all_assignments_f asg
           ,per_pay_bases ppb
      where asg.assignment_id = p_assignment_id
        and p_effective_date between asg.effective_start_date
        and asg.effective_end_date
        and ppb.pay_basis_id = asg.pay_basis_id
          ;
 --
 l_pay_annualization_factor number;
 --
BEGIN
  --
  OPEN  c_ref_perd_cd;
    FETCH c_ref_perd_cd into l_ref_perd_cd,l_precision;
    IF c_ref_perd_Cd%NOTFOUND THEN
      l_ref_perd_cd := 'NOVAL';
    END IF;
  CLOSE c_ref_perd_cd;
  --
  OPEN c_pay_basis;
    FETCH c_pay_basis into l_factor;
    IF l_factor is null THEN
      l_factor := 1;
    END IF;
  CLOSE c_pay_basis;
  --
  IF l_ref_perd_cd = 'PWK' THEN
    l_ret_amount := (p_amount*52)/l_factor;
  ELSIF l_ref_perd_cd = 'BWK' THEN
    l_ret_amount := (p_amount*26)/l_factor;
  ELSIF l_ref_perd_cd = 'SMO' THEN
    l_ret_amount := (p_amount*24)/l_factor;
  ELSIF l_ref_perd_cd = 'PQU' THEN
    l_ret_amount := (p_amount*4)/l_factor;
  ELSIF l_ref_perd_cd = 'PYR' THEN
    l_ret_amount := (p_amount*1)/l_factor;
  ELSIF l_ref_perd_cd = 'SAN' THEN
    l_ret_amount := (p_amount*2)/l_factor;
  ELSIF l_ref_perd_cd = 'MO' THEN
    l_ret_amount := (p_amount*12)/l_factor;
  ELSIF l_ref_perd_cd = 'NOVAL' THEN
    l_ret_amount := (p_amount*1)/l_factor;
  ELSIF l_ref_perd_cd = 'PHR' then
    --
    l_pay_annualization_factor := to_number(fnd_profile.value('BEN_HRLY_ANAL_FCTR'));
    if l_pay_annualization_factor is null then
      l_pay_annualization_factor := 2080;
    end if;
    --
    l_ret_amount := (p_amount * l_pay_annualization_factor)/l_factor;
    --
  ELSE
    l_ret_amount := (p_amount*1)/l_factor;
  END IF;
  --
  RETURN round(l_ret_amount,l_precision);
 END plan_to_basis_conversion;
--
--
--
 function get_pl_annualization_factor(p_acty_ref_perd_cd in varchar2) return number is
   l_factor number := 1;
 begin
  if p_acty_ref_perd_cd = 'PWK' THEN
    l_factor := 52;
  elsif p_acty_ref_perd_cd = 'BWK' THEN
    l_factor := 26;
  elsif p_acty_ref_perd_cd = 'SMO' THEN
    l_factor := 24;
  elsif p_acty_ref_perd_cd = 'PQU' THEN
    l_factor := 4;
  elsif p_acty_ref_perd_cd = 'SAN' THEN
    l_factor := 2;
  elsif p_acty_ref_perd_cd = 'MO' THEN
    l_factor := 12;
  elsif p_acty_ref_perd_cd = 'PHR' then
    l_factor := nvl(to_number(fnd_profile.value('BEN_HRLY_ANAL_FCTR')),2080);
  else
    -- 'NOVAL', 'PYR', null , or anything else
    l_factor := 1;
  end if;
  --
  return l_factor;
  --
 END get_pl_annualization_factor;
--
--
-- Bug 2016857
procedure set_data_migrator_mode
is
  --
  l_proc        varchar2(72):=g_package||'set_data_migrator_mode';
  --
  cursor c_mode is
  select upper(substr(pap.parameter_value,1,1))
  from   pay_action_parameters pap
  where  pap.parameter_name = 'DATA_MIGRATOR_MODE';
  --
  l_mode varchar2(30) := 'N';
  --
  cursor c_pap_mode (p_pap_grp_id number ) is
  select upper(substr(pap.parameter_value,1,1))
  from   pay_action_parameter_values pap
  where  pap.parameter_name = 'DATA_MIGRATOR_MODE'
  and    pap.ACTION_PARAMETER_GROUP_ID = p_pap_grp_id ;
  --
  l_profile_value number ;
  l_defined   Boolean ;
  --
begin
  hr_utility.set_location('Entering '||l_proc, 999);
  --
  -- check if the profile is set with PAP group
  --
  fnd_profile.get_specific(  name_z              => 'ACTION_PARAMETER_GROUPS'
     		            ,user_id_z           => fnd_global.user_id
     		            ,responsibility_id_z => fnd_global.resp_id
                            ,application_id_z    => fnd_global.resp_appl_id
                            ,val_z               => l_profile_value
                            ,defined_z           => l_defined );

  hr_utility.set_location('l_profile_value '||l_profile_value, 999);
  --
  -- If the profile is not set with PAP group then look for default
  --
  if (l_profile_value is null  or  l_defined = FALSE )
  then
      open c_mode;
      fetch c_mode into l_mode;
      close c_mode;
      --
      hr_utility.set_location('l_profile_value not defined '||l_mode, 999);
  elsif ( l_profile_value is not null or  l_defined = TRUE  ) then
       --
       open c_pap_mode(l_profile_value );
       fetch c_pap_mode into l_mode;
       close c_pap_mode;
       --
      hr_utility.set_location('l_profile_value defined '||l_mode, 999);
  end if ;
  --
  if l_mode not in ('P','Y','N') then
  --
     hr_general.g_data_migrator_mode := 'N';
  --
  else
      hr_general.g_data_migrator_mode := l_mode ;
  end if;
  --
  hr_utility.set_location('successful '||hr_general.g_data_migrator_mode, 999);
  hr_utility.set_location('Leaving '||l_proc, 999);
exception
    --
    when others then
      --
      hr_general.g_data_migrator_mode := 'N';
      --
      hr_utility.set_location('when others value '||hr_general.g_data_migrator_mode, 999);
end set_data_migrator_mode;
--
-- Bug 2016857
--
-- Bug 2428672
Function ben_get_abp_plan_opt_names
  (p_bnft_prvdr_pool_id IN ben_bnft_prvdr_pool_f.bnft_prvdr_pool_id%TYPE,
   p_business_group_id  IN ben_acty_base_rt_f.business_group_id%TYPE,
   p_acty_base_rt_id    IN ben_acty_base_rt_f.acty_base_rt_id%TYPE,
   p_session_id     IN fnd_sessions.session_id%TYPE,
   ret_flag         IN varchar2)
Return Varchar2
Is
  lv_pgm_id ben_bnft_prvdr_pool_f.pgm_id%TYPE;
  lv_pl_name  ben_pl_f.name%TYPE;
  lv_opt_name ben_opt_f.name%TYPE;
  lv_abr_name ben_acty_base_rt_f.name%TYPE;
  lv_meaning  Varchar2(60);

Begin
  Begin
    Select bpp.pgm_id
      Into lv_pgm_id
      From ben_bnft_prvdr_pool_f bpp,
           fnd_sessions se
     Where se.session_id = p_session_id
       And bpp.bnft_prvdr_pool_id = p_bnft_prvdr_pool_id
       And se.effective_date Between bpp.effective_start_date And bpp.effective_End_date;

    Select bpp.pl_name, bpp.opt_name, bpp.abr_name, bpp.meaning
      Into lv_pl_name, lv_opt_name, lv_abr_name, lv_meaning
      From
        (Select plip.pgm_id pgm_id, abr.acty_base_rt_id acty_base_rt_id,
            abr.business_group_id business_group_id,
            pl.name pl_name,  Null opt_name,  abr.name abr_name,
            substr(hr_general.decode_lookup('BEN_TX_TYP',abr.tx_typ_cd),1,60) meaning
           From ben_acty_base_rt_f abr,
            ben_plip_f plip,
            ben_pl_f pl,
            fnd_sessions se
          Where se.session_id = p_session_id
          And plip.pgm_id = lv_pgm_id
          And plip.pl_id = pl.pl_id
          And abr.pl_id = pl.pl_id
          And abr.acty_base_rt_id = p_acty_base_rt_id
            /* And pl.invk_dcln_prtn_pl_flag = 'N' */
          And pl.invk_flx_cr_pl_flag = 'N'
          And pl.imptd_incm_calc_cd is Null
          And abr.rt_usg_cd = 'STD'
          And abr.asn_on_enrt_flag = 'Y'
          And abr.business_group_id = p_business_group_id
          And se.effective_date Between abr.effective_start_date And abr.effective_End_date
          And se.effective_date Between plip.effective_start_date And plip.effective_End_date
          And se.effective_date Between pl.effective_start_date And pl.effective_End_date
          Union
         Select plip.pgm_id pgm_id, abr.acty_base_rt_id acty_base_rt_id,
            abr.business_group_id,
            pl.name pl_name, Null opt_name, abr.name abr_name,
            substr(hr_general.decode_lookup('BEN_TX_TYP',abr.tx_typ_cd),1,60) meaning
           From ben_acty_base_rt_f abr,
            ben_plip_f plip,
            ben_pl_f pl,
            fnd_sessions se
           Where se.session_id = p_session_id
           And plip.pgm_id = lv_pgm_id
           And plip.pl_id = pl.pl_id
           And abr.plip_id = plip.plip_id
           And abr.acty_base_rt_id = p_acty_base_rt_id
             /* And   pl.invk_dcln_prtn_pl_flag = 'N' */
           And pl.invk_flx_cr_pl_flag = 'N'
           And pl.imptd_incm_calc_cd is Null
           And abr.rt_usg_cd = 'STD'
           And abr.asn_on_enrt_flag = 'Y'
           And abr.business_group_id = p_business_group_id
           And se.effective_date Between abr.effective_start_date And abr.effective_End_date
           And se.effective_date Between plip.effective_start_date And plip.effective_End_date
           And se.effective_date Between pl.effective_start_date And pl.effective_End_date
           Union
          Select  plip.pgm_id pgm_id, abr.acty_base_rt_id acty_base_rt_id,
              abr.business_group_id,
              pl.name pl_name, opt.name opt_name, abr.name abr_name,
              substr(hr_general.decode_lookup('BEN_TX_TYP',abr.tx_typ_cd),1,60) meaning
           From ben_acty_base_rt_f abr,
              ben_plip_f plip,
              ben_pl_f pl,
              ben_oipl_f oipl,
              ben_opt_f opt,
              fnd_sessions se
          Where se.session_id = p_session_id
            And plip.pgm_id = lv_pgm_id
            And plip.pl_id = pl.pl_id
            And oipl.pl_id = pl.pl_id
            And abr.oipl_id = oipl.oipl_id
            And abr.acty_base_rt_id = p_acty_base_rt_id
            And oipl.opt_id = opt.opt_id
              /* And pl.invk_dcln_prtn_pl_flag = 'N' */
            And pl.invk_flx_cr_pl_flag = 'N'
            And pl.imptd_incm_calc_cd is Null
            And abr.rt_usg_cd = 'STD'
            And abr.asn_on_enrt_flag = 'Y'
            And abr.business_group_id = p_business_group_id
            And se.effective_date Between abr.effective_start_date And abr.effective_End_date
            And se.effective_date Between plip.effective_start_date And plip.effective_End_date
            And se.effective_date Between pl.effective_start_date And pl.effective_End_date
            And se.effective_date Between oipl.effective_start_date And oipl.effective_End_date
            And se.effective_date Between opt.effective_start_date And opt.effective_End_date
          Union
           Select plip.pgm_id pgm_id, abr.acty_base_rt_id acty_base_rt_id,
              abr.business_group_id,
              pl.name pl_name, opt.name opt_name, abr.name abr_name,
              substr(hr_general.decode_lookup('BEN_TX_TYP',abr.tx_typ_cd),1,60) meaning
           From ben_acty_base_rt_f abr,
              ben_plip_f plip,
              ben_pl_f pl,
              ben_oipl_f oipl,
              ben_oiplip_f oiplip,
              ben_opt_f opt,
              fnd_sessions se
          Where se.session_id = p_session_id
            And plip.pgm_id = lv_pgm_id
            And plip.pl_id = pl.pl_id
            And oipl.pl_id = pl.pl_id
            And abr.oiplip_id = oiplip.oiplip_id
            And abr.acty_base_rt_id = p_acty_base_rt_id
            And oiplip.oipl_id = oipl.oipl_id
            And oipl.opt_id = opt.opt_id
            And plip.plip_id = oiplip.plip_id
              /* And pl.invk_dcln_prtn_pl_flag = 'N' */
            And pl.invk_flx_cr_pl_flag = 'N'
            And pl.imptd_incm_calc_cd is Null
            And abr.rt_usg_cd = 'STD'
            And abr.asn_on_enrt_flag = 'Y'
            And abr.business_group_id = p_business_group_id
            And se.effective_date Between abr.effective_start_date And abr.effective_End_date
            And se.effective_date Between plip.effective_start_date And plip.effective_End_date
            And se.effective_date Between pl.effective_start_date And pl.effective_End_date
            And se.effective_date Between oipl.effective_start_date And oipl.effective_End_date
            And se.effective_date Between opt.effective_start_date And opt.effective_End_date
            And se.effective_date Between oiplip.effective_start_date And oiplip.effective_End_date
        ) BPP;

    Exception
      When Others Then
        Return Null;
    End;

    If (ret_flag = 'PLAN') Then
      Return lv_pl_name;
    Elsif (ret_flag = 'OPTION') Then
      Return lv_opt_name;
    Elsif (ret_flag = 'ACTIVITY') Then
      Return lv_abr_name;
    Elsif (ret_flag = 'TAXABILITY') Then
      Return lv_meaning;
    Else
      Return Null;
    End If;
Exception
  When Others Then
    Return Null;
End ben_get_abp_plan_opt_names;
-- Bug 2428672

--
-- ----------------------------------------------------------------------------
-- |---------------------< return_concat_kf_segments >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Returns the display concatenated string for the segments1..30.
--   The function calls hr_api.return_concat_kf_segments to get the
--   concatenated segments.
--   This function has been added to benutils as part of fix for bug 2599034
--   Since there is a package HR_API present in PLD library and backend, it is
--   conflicting with each other when we try to use the backend package from
--   form. But hard-coding Apps.<package name> is not a good practice.
--   Hence creating a wrapper for the hr_api.return_concat_kf_segments in
--   benutils to accomplish the same.
--
-- Pre-conditions:
--   The id_flex_num and segments have been fully validated.
--
-- In Arguments:
--   p_rec
--
-- Post Success:
--
-- Post Failure:
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
function return_concat_kf_segments
           (p_id_flex_num    in number,
            p_application_id in number,
            p_id_flex_code   in varchar2,
            p_segment1       in varchar2 ,
            p_segment2       in varchar2 ,
            p_segment3       in varchar2 ,
            p_segment4       in varchar2 ,
            p_segment5       in varchar2 ,
            p_segment6       in varchar2 ,
            p_segment7       in varchar2 ,
            p_segment8       in varchar2 ,
            p_segment9       in varchar2 ,
            p_segment10      in varchar2 ,
            p_segment11      in varchar2 ,
            p_segment12      in varchar2 ,
            p_segment13      in varchar2 ,
            p_segment14      in varchar2 ,
            p_segment15      in varchar2 ,
            p_segment16      in varchar2 ,
            p_segment17      in varchar2 ,
            p_segment18      in varchar2 ,
            p_segment19      in varchar2 ,
            p_segment20      in varchar2 ,
            p_segment21      in varchar2 ,
            p_segment22      in varchar2 ,
            p_segment23      in varchar2 ,
            p_segment24      in varchar2 ,
            p_segment25      in varchar2 ,
            p_segment26      in varchar2 ,
            p_segment27      in varchar2 ,
            p_segment28      in varchar2 ,
            p_segment29      in varchar2 ,
            p_segment30      in varchar2 )
Return Varchar2
is
begin
--
  return hr_api.return_concat_kf_segments
           (p_id_flex_num,
            p_application_id,
            p_id_flex_code,
            p_segment1,
            p_segment2,
            p_segment3,
            p_segment4,
            p_segment5,
            p_segment6,
            p_segment7,
            p_segment8,
            p_segment9,
            p_segment10,
            p_segment11,
            p_segment12,
            p_segment13,
            p_segment14,
            p_segment15,
            p_segment16,
            p_segment17,
            p_segment18,
            p_segment19,
            p_segment20,
            p_segment21,
            p_segment22,
            p_segment23,
            p_segment24,
            p_segment25,
            p_segment26,
            p_segment27,
            p_segment28,
            p_segment29,
            p_segment30);
--
end return_concat_kf_segments;

--
-- ----------------------------------------------------------------------------
-- |---------------------< get_comp_obj_disp_dt >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- Function to return effective_date based on which the compensation object names
-- can be retrieved. The function reads the profile value for BEN_DSPL_NAME_BASIS
-- and based on the profile, return the correct date. Based on this date all
-- Compensation Object name should be fetched.
--
-- Profile Value       Return
-- SESSION             Will return the session date. All comp objects names
--                     displayed will be effective of session date
-- LEOD                Will return the Life Event Occured Date. All comp objects names
--                     displayed will be effective of the Life Event Occurred Date
-- MXLECVG             Will return the greatest of Life Event Occurred Date or the Coverage
--                     Start Date. All comp objects names displayed will be effective this date
--
--
-- Pre-conditions:
--
-- In Arguments:
--
-- Post Success:
--
-- Post Failure:
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
FUNCTION get_comp_obj_disp_dt
    (p_session_date     date  default null,
     p_lf_evt_ocrd_dt   date  default null,
     p_cvg_strt_dt      date  default null)
return date is
--
     cursor c_session_date is
     select  se.effective_date
     from    fnd_sessions se
     where   session_id = userenv('SESSIONID');
--
     l_session_date date := p_session_date;
--
begin
   --
   if benutils.g_ben_dspl_name_basis is null then
      benutils.g_ben_dspl_name_basis := fnd_profile.value('BEN_DSPL_NAME_BASIS');
   end if;
   --
   if l_session_date is null then
      open c_session_date;
      fetch c_session_date into l_session_date;
      close c_session_date;
   end if;
   --
   if benutils.g_ben_dspl_name_basis = 'SESSION' then
      return l_session_date;
   elsif benutils.g_ben_dspl_name_basis = 'LEOD' then
      return nvl(p_lf_evt_ocrd_dt,l_session_date);
   elsif benutils.g_ben_dspl_name_basis = 'MXLECVG' then
      -- return greatest(nvl(p_cvg_strt_dt,l_session_date),nvl(p_lf_evt_ocrd_dt,l_session_date));
      return l_session_date;
   else
      return l_session_date;
   end if;
   --
end get_comp_obj_disp_dt;
--

--
-- Overloaded Function
--
FUNCTION get_comp_obj_disp_dt
    (p_session_date     date    default null,
     p_per_in_ler_id    number,
     p_cvg_strt_dt      date    default null)
return date is
     --
     cursor c_per_in_ler is
     select  pil.lf_evt_ocrd_dt
     from    ben_per_in_ler pil
     where   per_in_ler_id = p_per_in_ler_id;
     --
     l_lf_evt_ocrd_dt date;
     l_comp_obj_disp_dt date;
     --
begin
   --
   if p_per_in_ler_id is not null then
      open c_per_in_ler;
      fetch c_per_in_ler into l_lf_evt_ocrd_dt;
      close c_per_in_ler;
   end if;
   --
   l_comp_obj_disp_dt := benutils.get_comp_obj_disp_dt(
                    p_session_date     => p_session_date,
              p_lf_evt_ocrd_dt   => l_lf_evt_ocrd_dt,
              p_cvg_strt_dt      => p_cvg_strt_dt);
   --
   return l_comp_obj_disp_dt;
   --
end get_comp_obj_disp_dt;
--

function run_osb_benmngle_flag( p_person_id          in number,
                                p_business_group_id  in number,
                                p_effective_date     in date) return boolean is
  --
  l_proc   varchar2(80) := 'benutils.run_osb_benmngle_flag';
  l_per_last_upd_date  date;
  l_pil_last_upd_date  date;
  l_pil_lf_evt_ocrd_dt date;
  l_run_benmngle boolean := false;
  --
  cursor c_per_last_upd_date(p_pil_last_upd_date date) is
  select max(last_update_date)
    from (select max(nvl(last_update_date,p_pil_last_upd_date)) last_update_date
            from per_addresses
           where person_id = p_person_id
             and business_group_id = p_business_group_id
          union
          select max(nvl(last_update_date,p_pil_last_upd_date)) last_update_date
            from per_all_assignments_f
           where person_id = p_person_id
             and business_group_id = p_business_group_id
          union
          select max(nvl(last_update_date,p_pil_last_upd_date)) last_update_date
            from per_all_people_f
           where person_id = p_person_id
             and business_group_id = p_business_group_id
          union
          select max(nvl(last_update_date,p_pil_last_upd_date)) last_update_date
            from per_contact_relationships
           where person_id = p_person_id
             and business_group_id = p_business_group_id
          union
          select max(nvl(psl.last_update_date,p_pil_last_upd_date)) last_update_date
            from per_pay_proposals psl, per_all_assignments_f asn
           where psl.assignment_id = asn.assignment_id
             and asn.person_id = p_person_id
             and asn.business_group_id = p_business_group_id
          union
          select max(nvl(last_update_date,p_pil_last_upd_date)) last_update_date
            from per_periods_of_service
           where person_id = p_person_id
             and business_group_id = p_business_group_id
          union
          select max(nvl(last_update_date,p_pil_last_upd_date)) last_update_date
            from per_qualifications
           where person_id = p_person_id
             and business_group_id = p_business_group_id
          union
          select max(nvl(last_update_date,p_pil_last_upd_date)) last_update_date
            from ben_per_bnfts_bal_f
           where person_id = p_person_id
             and business_group_id = p_business_group_id
          union
          select max(nvl(last_update_date,p_pil_last_upd_date)) last_update_date
            from per_absence_attendances
           where person_id = p_person_id
             and business_group_id = p_business_group_id
          union
          select max(nvl(last_update_date,p_pil_last_upd_date)) last_update_date
            from per_person_type_usages_f
           where person_id = p_person_id
         );

  cursor c_pil_last_upd_date is
  select pil.lf_evt_ocrd_dt lf_evt_ocrd_dt,
         pil.last_update_date last_update_date
    from ben_per_in_ler pil , ben_ler_f ler
   where pil.person_id = p_person_id
     and pil.business_group_id = p_business_group_id
     and pil.per_in_ler_stat_cd = 'STRTD'
     and ler.ler_id = pil.ler_id
     and ler.typ_cd = 'SCHEDDU'
     and p_effective_date between ler.effective_start_date and ler.effective_end_date;

  --
begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Get the last updated date from pil record for Unrestricted LE run
  --
  open c_pil_last_upd_date;
  fetch c_pil_last_upd_date into l_pil_lf_evt_ocrd_dt, l_pil_last_upd_date;
  if c_pil_last_upd_date%NOTFOUND then
    --
    -- If Unrestricted life event was never run yet, we need to run Unrestricted
    -- now even if ssProcessUnrestricted flag is 'N'
    --
    l_run_benmngle := true;
    --
  else
    if l_pil_lf_evt_ocrd_dt is not null then
      --
      if (p_effective_date > l_pil_lf_evt_ocrd_dt) then
        --
        -- If session date is farther than the last Unrestricted run date,
        -- then also we need to run Unrest even if ssProcessUnrestricted flag is 'N'
        --
        hr_utility.set_location('p_effective_date = '||p_effective_date, 999);
        hr_utility.set_location('l_pil_lf_evt_ocrd_dt is '||l_pil_lf_evt_ocrd_dt, 999);
        --
        l_run_benmngle := true;
        --
      elsif (p_effective_date = l_pil_lf_evt_ocrd_dt
             and l_pil_last_upd_date is not null) then
        --
        -- If session date is same as Unrest LEOD
        -- then get the last updated date for Person related data changes
        --
        open c_per_last_upd_date(l_pil_last_upd_date);
        fetch c_per_last_upd_date into l_per_last_upd_date;
        close c_per_last_upd_date;
        --
        hr_utility.set_location('l_per_last_upd_date is '||l_per_last_upd_date, 999);
        hr_utility.set_location('l_pil_last_upd_date is '||l_pil_last_upd_date, 999);
        --
        if (nvl(l_per_last_upd_date,l_pil_last_upd_date) > l_pil_last_upd_date) then
          --
          -- If Person data has changed since the last Unrest LEOD then run benmngle
          --
          l_run_benmngle := true;
        end if;
        --
      else
        --
        l_run_benmngle := false;
        --
      end if;
    end if;
    --
  end if;
  close c_pil_last_upd_date;
  --
  hr_utility.set_location('Leaving:'||l_proc, 5);
  return l_run_benmngle;
  --
end run_osb_benmngle_flag;
--
FUNCTION is_task_enabled
  	 (p_access_cd 		in varchar2,
	  p_population_cd 	in varchar2,
	  p_status_cd 		in varchar2,
	  p_dist_bdgt_iss_dt 	in date,
	  p_wksht_grp_cd	in varchar2)
return varchar2
is
begin

 if (p_wksht_grp_cd = 'BDGT')
 then
  if (p_dist_bdgt_iss_dt is null)
  then
   return 'D';
  elsif (nvl(p_access_cd,'NA') = 'RO' and p_population_cd is null) then
   return 'D';
  end if;
 elsif (p_wksht_grp_cd = 'RVW')
 then
   if (p_status_cd = 'NS')
   then
   return 'D';
   end if;
 end if;

 return 'Y';
 end is_task_enabled;
--
FUNCTION get_manager_name(p_emp_per_in_ler_id in number,
	                  p_level in number)
return varchar2
  is

  Cursor csr_mgr_name
  is
  Select bcpi.full_name,
	 	 bcpi.brief_name,
         bcpi.custom_name
    From ben_cwb_person_info bcpi,
         ben_cwb_group_hrchy bcgh
   where bcgh.emp_per_in_ler_id = p_emp_per_in_ler_id
     and bcgh.lvl_num = (select max(lvl_num) - p_level + 1
                           from ben_cwb_group_hrchy
                          where emp_per_in_ler_id = p_emp_per_in_ler_id)
     and bcgh.lvl_num > 0
     and bcgh.mgr_per_in_ler_id = bcpi.group_per_in_ler_id;

  name_profile varchar2(2000);
  manager_names csr_mgr_name%rowtype;

begin

   name_profile := get_profile ('BEN_DISPLAY_EMPLOYEE_NAME');

   open csr_mgr_name;
   fetch csr_mgr_name into manager_names;
   close csr_mgr_name;

   if('FN' = name_profile)
   then
    return manager_names.full_name;
   elsif ('BN' = name_profile)
   then
    return manager_names.brief_name;
   else
    return manager_names.custom_name;
   end if;

end get_manager_name;
--

FUNCTION get_profile(p_profile_name in varchar2)
return varchar2
is
name_profile varchar2(2000);
begin
    fnd_profile.get (p_profile_name, name_profile);
    return name_profile;
end get_profile;
--

--
FUNCTION get_dpnt_prev_cvrd_flag(p_prtt_enrt_rslt_id in number,
                                 p_efective_date date,
                                 p_dpnt_person_id number,
                                 p_elig_per_elctbl_chc_id number,
                                 p_elig_cvrd_dpnt_id number,
                                 p_elig_dpnt_id number,
                                 p_per_in_ler_id number )
return varchar2
is
  l_exists_prev                varchar2(30) := 'N';
  l_enrt_perd_strt_dt          date;
  --
  cursor c_epe is
     select epo.ENRT_PERD_STRT_DT
       from ben_elig_per_elctbl_chc epe,
            ben_pil_elctbl_chc_popl epo
      where epe.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id
        and epe.pil_elctbl_chc_popl_id = epo.pil_elctbl_chc_popl_id ;
  --
  cursor c_exists_prev is
     select 'Y'
     from   ben_elig_cvrd_dpnt_f pdp,
            ben_per_in_ler       pil
     where  pdp.elig_cvrd_dpnt_id = p_elig_cvrd_dpnt_id
     and    pdp.cvg_thru_dt       = hr_api.g_eot
     -- and    pdp.effective_end_date <> hr_api.g_eot In the unrestricted enrollment. may continue without per_in_ler update.why
     -- and    pdp.per_in_ler_id     = p_per_in_ler_id
     and    (l_enrt_perd_strt_dt -1 ) between
            pdp.effective_start_date and pdp.effective_end_date
     and    pdp.per_in_ler_id     = pil.per_in_ler_id
     and    pil.per_in_ler_stat_cd not in ('VOIDD', 'BCKDT');
   --
  cursor c_exists_prev_other_option is
    select 'Y'
    from dual where exists( select null
                            from    ben_elig_cvrd_dpnt_f pdp,
                                    ben_per_in_ler pil,
                                    ben_prtt_enrt_rslt_f pnr,
                                    ben_prtt_enrt_rslt_f pen
                            where pdp.dpnt_person_id = p_dpnt_person_id
                            --and    pdp.cvg_thru_dt =  hr_api.g_eot
                            and    pdp.effective_end_date = hr_api.g_eot
                            and    pdp.prtt_enrt_rslt_id = pnr.prtt_enrt_rslt_id
                            --and    (l_enrt_perd_strt_dt -1 ) between pdp.effective_start_date
                            --                                 and pdp.effective_end_date
                            and    pnr.pl_typ_id = pen.pl_typ_id
                            and    pnr.prtt_enrt_rslt_id <> pen.prtt_enrt_rslt_id
                            and    pnr.prtt_enrt_rslt_stat_cd IS NULL
                            --and    pen.prtt_enrt_rslt_stat_cd IS NULL
                            and    pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id -- epe.pen
                            and    pen.effective_end_date = hr_api.g_eot  --new pen
                            and    pnr.effective_end_date = hr_api.g_eot --old
                            --  and    pdp.per_in_ler_id = p_per_in_ler_id -- doesnot work for LE
                            and    pdp.per_in_ler_id = pil.per_in_ler_id
                            and    pil.per_in_ler_stat_cd not in ('VOIDD', 'BCKDT') );
  --
   begin
     --
     open c_epe;
       fetch c_epe into l_enrt_perd_strt_dt;
     close c_epe;
     --
     open c_exists_prev ;
       fetch c_exists_prev into l_exists_prev ;
     close c_exists_prev ;
     if l_exists_prev = 'N' then
       --
       open c_exists_prev_other_option ;
         fetch c_exists_prev_other_option into l_exists_prev ;
       close c_exists_prev_other_option ;
       --
     end if;
     --
     return l_exists_prev ;
     --
end get_dpnt_prev_cvrd_flag;
--
end benutils;

/
