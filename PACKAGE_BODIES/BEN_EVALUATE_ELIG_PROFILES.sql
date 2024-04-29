--------------------------------------------------------
--  DDL for Package Body BEN_EVALUATE_ELIG_PROFILES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EVALUATE_ELIG_PROFILES" as
/* $Header: benevlpr.pkb 120.10.12010000.8 2009/09/25 06:46:09 stee ship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|                       Copyright (c) 1997 Oracle Corporation                  |
|                          Redwood Shores, California, USA                     |
|                               All rights reserved.                           |
+==============================================================================+

Name
        Profile Evaluation Package
Purpose
        This package is used to determine if a person satisfies eligiblity
        profiles or not. Created by moving the criteria evaluation logic from
        bendetel.pkb Will be called from both elpro and vapro
History
  Date       Who         Version    What?
  ---------  ----------- -------    --------------------------------------------
  18 May 03  mmudigon    115.0      Original version
  10 Oct 03  mmudigon    115.1      Fixes in check_person_ben_bal and
                                    check_person_balance for Vapros
  23-nov-03  nhunur      115.2      changed exception handling part.
  02-feb-03  pbodla      115.3      Bug 3450533 : pass life event occured date
                                    to rule (check_rule_elig).
  22-mar-04  Hariram     115.5      Bug 3520054 - Cached plip/ptip records were
                                    unavailable since the code was moved from
                                    bendetel to benevlpr.
  17-Apr-04  ikasire     115.6      FONM changes
  18-Apr-04  mmudigon    115.7      Universal Eligibility
  11-Jun-04  mmudigon    115.8      FONM : now populating l_fonm_cvg_strt_dt
                                    in function eligible
  13-aug-04  tjesumic    115.9      FONM : fonm date passed as parameter
  17-aug-04  tjesumic    115.10     FONM : intialise the global
  13-Sep-04  tjesumic    115.12     FONM : reset the person cache if the date is not within effective dates
  29-Sep-04  tjesumic    115.13     FONM : clearing cache call asg
  14-Dec-04  abparekh    115.14     Bug 4031314 : Modified logic in check_perf_rtng_elig
                                    not to compare Event Type when ELPRO criteria has
                                    Performance Type as -1
                                    Modified check_qua_in_gr_elig to fetch approved pay proposal
  21-Dec-04  abparekh    115.15     Bug 4031314 : In check_perf_rtng_elig consider only latest
                                    Performance Rating
  06-Feb-05  mmudigon    115.16     RBC changes
  24-Feb-05  tjesumic    115.17     fonm-4204020 after determining date adjustment of cvrd/enrol in another
                                    criteria using fonm  date, the calcualted date isreplace by fonm date
                                    this is fixed by removing  l_date_to_use := NVL(l_fonm_cvg_strt_dt,l_date_to_use)
  08-Mar-05  nhunur      115.18     GSI - NL issue. check legal entity for US legislation only.
  18-Apr-05  mmudigon    115.19     RBC changes continued.
  26-Apr-05  mmudigon    115.20     Score and Weight
  14-Jun-05  abparekh    115.21     Bug 4429071 : For derived factors use this formula :
                                    Score + (Criteria Value * Weightage )
  23-Jun-05  abparekh    115.22     Bug 4449229 : Fix for AGE LOS Combination derived factors
                                                  Score calculation
  27-Jun-05  abparekh    115.23     Bug 4454878 : Reset g_per_eligible before processing ELPROs
  24-jan-06  ssarkar     115.24     Bug 4958846 : Eligibilty fix for only IREC.
  20-Apr-06  bmanyam     115.25     Bug 5173693 : Numeric Value error in benmngle.g_output string.
                                                  Truncated the string
  09-May-06  gsehgal     115.26     Bug 4558945 : change get_quartile to ben_cwb_person_info_pkg.get_grd_quartile
  27-Jun-06  swjain      115.27     Bug 5331889 : Added person_id in call to benutils.formula in procedure check_rule_elig
  25-Sep-06  stee        115.28     Bug 5550851 : Fix check_elig_dpnt_cvrd_othr_pgm cursor
                                                  to use the calculated date to determine
                                                  eligibility instead of the fonm date.
  07-Sep-07  rtagarra    115.29     Bug 6399423 : Used proper variable for Assignment checking for FONM case.
  22-Oct-07  rtagarra    115.30     Bug 6509099 : Handled code for Irec case.
  14-Jan-07  rtagarra    115.31     Bug 6747807 : Modified cursor c1 in procedures check_elig_dpnt_cvrd_othr_pl
						  ,check_elig_dpnt_cvrd_othr_plip,check_elig_dpnt_cvrd_othr_ptip,check_elig_dpnt_cvrd_othr_pgm
  07-Oct-08  krupani     115.34     Bug 7411918 : Moved 'Leaving Reason' eligibility criteria out of cobra if condition
                                                  so that, it can be used for plan not in program too
  13-May-09  stee        115.35     Bug 8463981 : Change check_elig_cbr_quald_bnf to select
                                                  the latest quald bnf row.
  07-Sep-09  krupani     115.36     Bug 8872046 : Corrected the cursor c1 in check_prtt_in_anthr_pl_elig
  24-Sep-09  stee        115.37     Bug 8685338 : Removed the exception handling when a rule fails.
*/
--------------------------------------------------------------------------------
--
g_package varchar2(30) := 'ben_evaluate_elig_profiles.';
g_score_compute_mode     boolean := false;
g_trk_scr_for_inelg_flag boolean := false;
g_per_eligible           boolean;
--
l_fonm_cvg_strt_dt  date ;
--
procedure write(p_score_tab         in out nocopy scoreTab,
                p_eligy_prfl_id     number,
                p_tab_short_name    varchar2,
                p_pk_id             number,
                p_computed_score    number) is

l_count   number := 0;
l_proc    varchar2(100):= g_package||'write';
begin
   hr_utility.set_location('Entering: '||l_proc,10);

   l_count := p_score_tab.count +1;
   p_score_tab(l_count).eligy_prfl_id       := p_eligy_prfl_id;
   p_score_tab(l_count).crit_tab_short_name := p_tab_short_name;
   p_score_tab(l_count).crit_tab_pk_id      := p_pk_id;
   p_score_tab(l_count).computed_score      := p_computed_score;
   p_score_tab(l_count).benefit_action_id   := benutils.g_benefit_action_id;

   hr_utility.set_location('Leaving: '||l_proc,10);

end write;

procedure write(p_profile_score_tab     in out nocopy scoreTab,
                p_crit_score_tab        in scoreTab) is
l_proc    varchar2(100):= g_package||'write';
begin

   hr_utility.set_location('Entering: '||l_proc,10);
   if p_crit_score_tab.count > 0
   then
      for i in 1..p_crit_score_tab.count
      loop
         p_profile_score_tab(p_profile_score_tab.count+1) := p_crit_score_tab(i);
      end loop;
   end if;
   hr_utility.set_location('Leaving: '||l_proc,10);

end write;

function is_ok (p_val number
               ,p_max number
               ,p_min number
               ,p_max_flag varchar2 default null
               ,p_min_flag varchar2 default null
               ,p_pct_value varchar2 default 'N' )
               return boolean is
l_min number:=-999999999999999999999999999999999999999;
l_max number:= 999999999999999999999999999999999999999;
begin
   -- Bug 2101937 fixes
   -- We deal Decimals and Whole numbers in two different ways not to changes the
   -- existing functionality with the customers.
   -- In case of decimal is used in min or max limit, user needs to handle the
   -- the p_val to make sure that it falls in one of the ranges using the
   -- rounding code. To get this we are using (p_max + 0.000000001) as the upper
   -- boundary. So we check for p_val < (p_max + 0.000000001).
   -- In case of whole numbers, we always take the p_max + 1 in the upper boundary
   -- to make sure that the p_val is less than < (p_max + 1 ).
   --
   if p_max is not null then
      --
      if ( nvl(p_pct_value,'N') = 'Y' OR
           p_max <> trunc(p_max) OR
           p_min <> trunc(p_min) )  then
        --
        -- Decimal Case
        l_max  := p_max + 0.000000001 ;
        --
      else
        -- Whole number
        l_max  := p_max + 1 ;
        --
      end if;
      --
   end if;
   --
   return (nvl(p_val,0) >= nvl(p_min,l_min) and
           nvl(p_val,0) < l_max )
          or
          (nvl(p_min_flag,'N') = 'Y' and
           nvl(p_max_flag,'N') = 'Y')
          or
          (nvl(p_min_flag,'N') = 'Y' and
           nvl(p_val,0) < l_max )
          or
          (nvl(p_max_flag,'N') = 'Y' and
           nvl(p_val,0) >= nvl(p_min,l_min));
   --
end;
--
-- --------------------------------------------------------------------
--  Hours worked in a period
-- --------------------------------------------------------------------
--
function get_rt_hrs_wkd
  (p_person_id              in number
  ,p_business_group_id      in number
  ,p_effective_date         in date
  ,p_opt_id                 in number default null
  ,p_plip_id                in number default null
  ,p_pl_id                  in number default null
  ,p_pgm_id                 in number default null)
return number is
  --
  l_rt_hrs_wkd_val     ben_elig_per_f.rt_hrs_wkd_val%type;
  --

  cursor c_hrs_wkd  is
  select bep.rt_hrs_wkd_val
    from ben_elig_per_f bep,
         ben_per_in_ler pil
   where bep.person_id = p_person_id
     and nvl(bep.pgm_id,-1) = nvl(p_pgm_id,-1)
     and nvl(bep.pl_id,-1) = nvl(p_pl_id,-1)
     and nvl(l_fonm_cvg_strt_dt,p_effective_date) between bep.effective_start_date
                              and bep.effective_end_date
     and pil.per_in_ler_id(+)=bep.per_in_ler_id
     and pil.business_group_id(+)=bep.business_group_id
     and (pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT') -- found row condition
      or  pil.per_in_ler_stat_cd is null);                -- outer join condition

  cursor c_hrs_wkd_opt  is
  select epo.rt_hrs_wkd_val
    from ben_elig_per_f bep, ben_elig_per_opt_f epo,
         ben_per_in_ler pil
   where bep.person_id = p_person_id
     and bep.elig_per_id = epo.elig_per_id
     and epo.opt_id = p_opt_id
     and nvl(bep.pgm_id,-1) = nvl(p_pgm_id,-1)
     and nvl(bep.pl_id,-1) = nvl(p_pl_id,-1)
     and nvl(l_fonm_cvg_strt_dt,p_effective_date) between epo.effective_start_date
                              and epo.effective_end_date
     and nvl(l_fonm_cvg_strt_dt,p_effective_date) between bep.effective_start_date
                              and bep.effective_end_date
     and pil.per_in_ler_id(+)=bep.per_in_ler_id
     and pil.business_group_id(+)=bep.business_group_id
     and (pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT') -- found row condition
      or  pil.per_in_ler_stat_cd is null);                -- outer join condition

  cursor c_hrs_wkd_plip  is
  select epo.rt_hrs_wkd_val
    from ben_elig_per_f bep, ben_elig_per_opt_f epo,
         ben_per_in_ler pil
   where bep.person_id = p_person_id
     and bep.elig_per_id = epo.elig_per_id
     and epo.opt_id = p_opt_id
     and nvl(bep.pgm_id,-1) = nvl(p_pgm_id,-1)
     and nvl(bep.plip_id,-1) = nvl(p_plip_id,-1)
     and nvl(l_fonm_cvg_strt_dt,p_effective_date) between epo.effective_start_date
                              and epo.effective_end_date
     and nvl(l_fonm_cvg_strt_dt,p_effective_date) between bep.effective_start_date
                              and bep.effective_end_date
     and pil.per_in_ler_id(+)=bep.per_in_ler_id
     and pil.business_group_id(+)=bep.business_group_id
     and (pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT') -- found row condition
      or  pil.per_in_ler_stat_cd is null);                -- outer join condition

begin

  if p_opt_id is not null then
    -- Look for oiplip first.  oiplip elig_per_opt rows hang off plip elig_per
    -- records.
    if p_plip_id is not null then
      open c_hrs_wkd_plip;
      fetch c_hrs_wkd_plip into l_rt_hrs_wkd_val;
      hr_utility.set_location ('oiplip '||to_char(l_rt_hrs_wkd_val),01);
      close c_hrs_wkd_plip;
    end if;

    -- If there is no oiplip, check for oipl
    if l_rt_hrs_wkd_val is null then
      open c_hrs_wkd_opt;
      fetch c_hrs_wkd_opt into l_rt_hrs_wkd_val;
      hr_utility.set_location ('oipl '||to_char(l_rt_hrs_wkd_val),01);
      close c_hrs_wkd_opt;
    end if;
  else
     -- just look for pl elig per record.
     open c_hrs_wkd;
     fetch c_hrs_wkd into l_rt_hrs_wkd_val;
      hr_utility.set_location ('pl '||to_char(l_rt_hrs_wkd_val),01);
     close c_hrs_wkd;
  end if;

  return l_rt_hrs_wkd_val;

end get_rt_hrs_wkd;
--
-- -----------------------------------------------------------------
--  percent fulltime.
-- -----------------------------------------------------------------
--
function get_rt_pct_fltm
  (p_person_id              in number
  ,p_business_group_id      in number
  ,p_effective_date         in date
  ,p_opt_id                 in number default null
  ,p_plip_id                in number default null
  ,p_pl_id                  in number default null
  ,p_pgm_id                 in number default null)
return number is
  --
  cursor c_pct_ft is
    select bep.rt_pct_fl_tm_val
    from   ben_elig_per_f bep,
           ben_per_in_ler pil
    where  bep.person_id = p_person_id
    and nvl(bep.pgm_id,-1) = nvl(p_pgm_id,-1)
    and nvl(bep.pl_id,-1) = nvl(p_pl_id,-1)
    and    p_effective_date
           between bep.effective_start_date
           and     bep.effective_end_date
    and pil.per_in_ler_id(+)=bep.per_in_ler_id
    and pil.business_group_id(+)=bep.business_group_id+0
    and (pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT') -- found row condition
     or pil.per_in_ler_stat_cd is null                  -- outer join condition
    );

  cursor c_pct_ft_opt  is
  select epo.rt_pct_fl_tm_val
    from ben_elig_per_f bep, ben_elig_per_opt_f epo,
         ben_per_in_ler pil
   where bep.person_id = p_person_id
     and bep.elig_per_id = epo.elig_per_id
     and epo.opt_id = p_opt_id
     and nvl(bep.pgm_id,-1) = nvl(p_pgm_id,-1)
     and nvl(bep.pl_id,-1) = nvl(p_pl_id,-1)
     and p_effective_date between epo.effective_start_date
                              and epo.effective_end_date
     and p_effective_date between bep.effective_start_date
                              and bep.effective_end_date
     and pil.per_in_ler_id(+)=bep.per_in_ler_id
     and pil.business_group_id(+)=bep.business_group_id
     and (pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT') -- found row condition
      or  pil.per_in_ler_stat_cd is null);                -- outer join condition

  cursor c_pct_ft_plip  is
  select epo.rt_pct_fl_tm_val
    from ben_elig_per_f bep, ben_elig_per_opt_f epo,
         ben_per_in_ler pil
   where bep.person_id = p_person_id
     and bep.elig_per_id = epo.elig_per_id
     and epo.opt_id = p_opt_id
     and nvl(bep.pgm_id,-1) = nvl(p_pgm_id,-1)
     and nvl(bep.plip_id,-1) = nvl(p_plip_id,-1)
     and p_effective_date between epo.effective_start_date
                              and epo.effective_end_date
     and p_effective_date between bep.effective_start_date
                              and bep.effective_end_date
     and pil.per_in_ler_id(+)=bep.per_in_ler_id
     and pil.business_group_id(+)=bep.business_group_id
     and (pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT') -- found row condition
      or  pil.per_in_ler_stat_cd is null);                -- outer join condition

  l_per_pct_ft_val     number;
  --
begin
  --
  if p_opt_id is not null then
     -- Look for oiplip first.  oiplip elig_per_opt rows hang off plip elig_per
     -- records.
     if p_plip_id is not null then
       open c_pct_ft_plip;
       fetch c_pct_ft_plip into l_per_pct_ft_val;
       hr_utility.set_location ('oiplip '||to_char(l_per_pct_ft_val),01);
       close c_pct_ft_plip;
     end if;

     -- If there is no oiplip, check for oipl
     if l_per_pct_ft_val is null then
       open c_pct_ft_opt;
       fetch c_pct_ft_opt into l_per_pct_ft_val;
       hr_utility.set_location ('oipl '||to_char(l_per_pct_ft_val),01);
       close c_pct_ft_opt;
     end if;
   else
      -- just look for pl elig per record.
      open c_pct_ft;
      fetch c_pct_ft into l_per_pct_ft_val;
      hr_utility.set_location ('pl '||to_char(l_per_pct_ft_val),01);
      close c_pct_ft;
   end if;
   --
   return l_per_pct_ft_val;

end get_rt_pct_fltm;
--
-- -----------------------------------------------------
--  This procedure determines eligibility based on LOS.
-- -----------------------------------------------------
--
procedure check_los_elig(p_eligy_prfl_id     in number,
                         p_business_group_id in number,
                         p_effective_date    in date,
                         p_person_id         in number,
                         p_per_los           in number,
                         p_eval_typ          in varchar2,
                         p_comp_obj_mode     in boolean,
                         p_currepe_row       in ben_determine_rates.g_curr_epe_rec,
                         p_lf_evt_ocrd_dt    in date,
                         p_score_compute_mode in boolean default false,
                         p_profile_score_tab in out nocopy scoreTab,
                         p_per_in_ler_id     in number default null,
                         p_pl_id             in number default null,
                         p_pgm_id            in number default null,
                         p_oipl_id           in number default null,
                         p_plip_id           in number default null,
                         p_opt_id            in number default null) is
  --
  l_proc              varchar2(100):= g_package||'check_los_elig';
  l_inst_dets ben_elp_cache.g_cache_elpels_instor;
  l_inst_count number;
  l_insttorrw_num binary_integer;
  l_ok                boolean := false;
  l_rows_found        boolean := false;
  l_pl_id          number;
  l_pgm_id         number;
  l_per_in_ler_id  number;
  l_oipl_id        number;
  l_per_los        number := p_per_los;
  l_dummy_date     date;
  l_prtn_ovridn_flag  varchar2(30);
  l_prtn_ovridn_thru_dt date;
  l_epo_row         ben_derive_part_and_rate_facts.g_cache_structure;
  l_crit_passed     boolean;
  l_score_tab       scoreTab;
  --
begin
  --
  hr_utility.set_location('Entering: '||l_proc,10);
  --
  -- Getting eligibility profile length of service by eligibility profile
  --
  ben_elp_cache.elpels_getcacdets
    (p_effective_date    => nvl(l_fonm_cvg_strt_dt,p_effective_date)
    ,p_business_group_id => p_business_group_id
    ,p_eligy_prfl_id     => p_eligy_prfl_id
    ,p_inst_set          => l_inst_dets
    ,p_inst_count        => l_inst_count);
  --
  if l_inst_count > 0 then
    --
    if p_eval_typ <> 'E' then
        --
        -- plan in program is overriden, capture the data from cache by
        -- passing plip_id
        --
        if p_opt_id is null and p_pgm_id is not null then
           ben_pep_cache.get_pilpep_dets(
                p_person_id         => p_person_id,
                p_business_group_id => p_business_group_id,
                p_effective_date    => nvl(l_fonm_cvg_strt_dt,p_effective_date),
                p_pgm_id            => p_pgm_id,
                p_plip_id           => p_plip_id,
                p_inst_row          => l_epo_row);
                l_prtn_ovridn_flag    := l_epo_row.prtn_ovridn_flag;
                l_prtn_ovridn_thru_dt := l_epo_row.prtn_ovridn_thru_dt;
                l_per_los             := l_epo_row.rt_los_val;
        elsif p_opt_id is not null and p_pgm_id is not null then
                ben_pep_cache.get_pilepo_dets(
                p_person_id         => p_person_id,
                p_business_group_id => p_business_group_id,
                p_effective_date    => nvl(l_fonm_cvg_strt_dt,p_effective_date),
                p_pgm_id            => p_pgm_id,
                p_plip_id           => p_plip_id,
                p_opt_id            => p_opt_id,
                p_inst_row          => l_epo_row);
                l_prtn_ovridn_flag    := l_epo_row.prtn_ovridn_flag;
                l_prtn_ovridn_thru_dt := l_epo_row.prtn_ovridn_thru_dt;
                l_per_los             := l_epo_row.rt_los_val;
        else
              hr_utility.set_location('Plan not in Program',10);
               l_prtn_ovridn_flag    := p_currepe_row.prtn_ovridn_flag;
               l_prtn_ovridn_thru_dt := p_currepe_row.prtn_ovridn_thru_dt;
               l_per_los             := p_currepe_row.rt_los_val;
        end if;
    end if;

    for l_insttorrw_num in l_inst_dets.first .. l_inst_dets.last loop
      --
      if not p_comp_obj_mode or
         (p_eval_typ <> 'E' and
          not (nvl(l_prtn_ovridn_flag,'N') = 'Y' and
               nvl(l_prtn_ovridn_thru_dt,hr_api.g_eot) > nvl(l_fonm_cvg_strt_dt,p_effective_date))
         ) then
        --
        ben_derive_factors.determine_los
        (p_person_id            => p_person_id
        ,p_los_fctr_id          => l_inst_dets(l_insttorrw_num).los_fctr_id
        ,p_pgm_id               => p_pgm_id
        ,p_pl_id                => p_pl_id
        ,p_oipl_id              => p_oipl_id
        ,p_per_in_ler_id        => p_per_in_ler_id
        ,p_comp_obj_mode        => p_comp_obj_mode
        ,p_effective_date       => p_effective_date
        ,p_lf_evt_ocrd_dt       => p_lf_evt_ocrd_dt
        ,p_business_group_id    => p_business_group_id
        ,p_perform_rounding_flg => TRUE
        ,p_value                => l_per_los
        ,p_start_date           => l_dummy_date
        ,p_fonm_cvg_strt_dt     => l_fonm_cvg_strt_dt );
      --
      end if;

      l_ok := is_ok(l_per_los
                   ,l_inst_dets(l_insttorrw_num).mx_los_num
                   ,l_inst_dets(l_insttorrw_num).mn_los_num
                   ,l_inst_dets(l_insttorrw_num).no_mx_los_num_apls_flag
                   ,l_inst_dets(l_insttorrw_num).no_mn_los_num_apls_flag
                   );
      hr_utility.set_location('l_per_los '||l_per_los,20);
      hr_utility.set_location('ACE Score = ' || l_inst_dets(l_insttorrw_num).criteria_score, 20);
      hr_utility.set_location('ACE Weight = ' || l_inst_dets(l_insttorrw_num).criteria_weight, 20);
      hr_utility.set_location('ACE Value = ' || to_char(( l_per_los * nvl(l_inst_dets(l_insttorrw_num).criteria_weight, 0) ) + nvl(l_inst_dets(l_insttorrw_num).criteria_score, 0)), 20);
      --
      if l_per_los is null then
        --
        l_ok := false;
        --
      end if;
      --
      if l_ok and l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
        --
        if p_score_compute_mode then
           if l_crit_passed is null then
              l_crit_passed := true;
           end if;
           write(l_score_tab,
                 l_inst_dets(l_insttorrw_num).eligy_prfl_id,
                 l_inst_dets(l_insttorrw_num).short_code,
                 l_inst_dets(l_insttorrw_num).pk_id,
                 ( l_per_los * nvl(l_inst_dets(l_insttorrw_num).criteria_weight, 0) ) +
                 nvl(l_inst_dets(l_insttorrw_num).criteria_score, 0)      /* Bug 4429071 */
                 );
        else
           exit;
        end if;
        --
      elsif l_ok and l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := false;
        exit;
        --
      elsif (not l_ok) and l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := true;
        if p_score_compute_mode then
           write(l_score_tab,
                 l_inst_dets(l_insttorrw_num).eligy_prfl_id,
                 l_inst_dets(l_insttorrw_num).short_code,
                 l_inst_dets(l_insttorrw_num).pk_id,
                 ( l_per_los * nvl(l_inst_dets(l_insttorrw_num).criteria_weight, 0) ) +
                 nvl(l_inst_dets(l_insttorrw_num).criteria_score, 0)    /* Bug 4429071 */
                 );
        end if;
        --exit ;
        --
      elsif l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
        --
        l_rows_found := true;
        --
      end if;
      --
    end loop;
    --
  end if;
  --
  if l_crit_passed is null
  then
     if l_rows_found and
        not l_ok then
       --
       l_score_tab.delete;
       g_inelg_rsn_cd := 'LOS';
       fnd_message.set_name('BEN','BEN_91669_LOS_PRFL_FAIL');
       hr_utility.set_location('Criteria Failed: '||l_proc,20);
       raise g_criteria_failed;
       --
     end if;
  end if;
  --
  if p_score_compute_mode
  then
     hr_utility.set_location('count '||l_score_tab.count,20);
     write(p_profile_score_tab,l_score_tab);
  end if;
  hr_utility.set_location('Leaving: '||l_proc,20);
  --
end check_los_elig;
--
-- ----------------------------------------------------
--  This procedure determines eligibility based on age.
-- ----------------------------------------------------
--
procedure check_age_elig(p_eligy_prfl_id          in number,
                         p_person_id              in number,
                         p_business_group_id      in number,
                         p_effective_date         in date,
                         p_per_age                in number,
                         p_per_dob                in date,
                         p_eval_typ               in varchar2,
                         p_comp_obj_mode          in boolean,
                         p_currepe_row            in ben_determine_rates.g_curr_epe_rec,
                         p_lf_evt_ocrd_dt         in date,
                         p_score_compute_mode in boolean default false,
                         p_profile_score_tab in out nocopy scoreTab,
                         p_per_in_ler_id          in number default null,
                         p_pl_id                  in number default null,
                         p_pgm_id                 in number default null,
                         p_oipl_id                in number default null,
                         p_plip_id                in number default null,
                         p_opt_id                 in number default null) is
  --
  l_proc           varchar2(100):= g_package||'check_age_elig';
  l_dob            date:=p_per_dob;
  l_ok             boolean := false;
  l_rows_found     boolean := false;
  l_pl_id          number;
  l_pgm_id         number;
  l_per_in_ler_id  number;
  l_oipl_id        number;
  l_per_age        number := p_per_age;
  l_dummy_date     date;
  l_prtn_ovridn_flag  varchar2(30);
  l_prtn_ovridn_thru_dt date;
  l_epo_row         ben_derive_part_and_rate_facts.g_cache_structure;
  l_inst_dets       ben_elp_cache.g_cache_elpeap_instor;
  l_inst_count      number;
  l_insttorrw_num   binary_integer;
  l_crit_passed     boolean;
  l_score_tab       scoreTab;
  --
begin
  --
  hr_utility.set_location('Entering :'||l_proc, 10);
  --
  -- Getting eligibility profile age details by eligibility profile
  --
  ben_elp_cache.elpeap_getcacdets
    (p_effective_date    => nvl(l_fonm_cvg_strt_dt,p_effective_date)
    ,p_business_group_id => p_business_group_id
    ,p_eligy_prfl_id     => p_eligy_prfl_id
    ,p_inst_set          => l_inst_dets
    ,p_inst_count        => l_inst_count);
  --
  hr_utility.set_location('Age :'||l_per_age, 10);
  if l_inst_count > 0 then

    if p_eval_typ <> 'E' then
        --
        -- plan in program is overriden, capture the data from cache by
        -- passing plip_id
        --
        if p_opt_id is null and p_pgm_id is not null then
           ben_pep_cache.get_pilpep_dets(
                p_person_id         => p_person_id,
                p_business_group_id => p_business_group_id,
                p_effective_date    => nvl(l_fonm_cvg_strt_dt,p_effective_date),
                p_pgm_id            => p_pgm_id,
                p_plip_id           => p_plip_id,
                p_inst_row          => l_epo_row);
                l_prtn_ovridn_flag    := l_epo_row.prtn_ovridn_flag;
                l_prtn_ovridn_thru_dt := l_epo_row.prtn_ovridn_thru_dt;
                l_per_age             := l_epo_row.rt_age_val;
        elsif p_opt_id is not null and p_pgm_id is not null then
                ben_pep_cache.get_pilepo_dets(
                p_person_id         => p_person_id,
                p_business_group_id => p_business_group_id,
                p_effective_date    => nvl(l_fonm_cvg_strt_dt,p_effective_date),
                p_pgm_id            => p_pgm_id,
                p_plip_id           => p_plip_id,
                p_opt_id            => p_opt_id,
                p_inst_row          => l_epo_row);
                l_prtn_ovridn_flag    := l_epo_row.prtn_ovridn_flag;
                l_prtn_ovridn_thru_dt := l_epo_row.prtn_ovridn_thru_dt;
                l_per_age             := l_epo_row.rt_age_val;
        else
              hr_utility.set_location('Plan not in Program',10);
               l_prtn_ovridn_flag    := p_currepe_row.prtn_ovridn_flag;
               l_prtn_ovridn_thru_dt := p_currepe_row.prtn_ovridn_thru_dt;
               l_per_age             := p_currepe_row.rt_age_val;
        end if;
    end if;

    for l_insttorrw_num in l_inst_dets.first .. l_inst_dets.last loop
      --
      if not p_comp_obj_mode or
         (p_eval_typ <> 'E' and
          not (nvl(l_prtn_ovridn_flag,'N') = 'Y' and
               nvl(l_prtn_ovridn_thru_dt,hr_api.g_eot) > nvl(l_fonm_cvg_strt_dt,p_effective_date))
         ) then
        --
        ben_derive_factors.determine_age
        (p_person_id            => p_person_id
        ,p_per_dob              => l_dob
        ,p_age_fctr_id          => l_inst_dets(l_insttorrw_num).age_fctr_id
        ,p_pgm_id               => p_pgm_id
        ,p_pl_id                => p_pl_id
        ,p_oipl_id              => p_oipl_id
        ,p_per_in_ler_id        => p_per_in_ler_id
        ,p_comp_obj_mode        => p_comp_obj_mode
        ,p_effective_date       => p_effective_date
        ,p_lf_evt_ocrd_dt       => p_lf_evt_ocrd_dt
        ,p_business_group_id    => p_business_group_id
        ,p_perform_rounding_flg => TRUE
        ,p_value                => l_per_age
        ,p_change_date          => l_dummy_date
        ,p_fonm_cvg_strt_dt     => l_fonm_cvg_strt_dt );
      --
      end if;

      l_ok := is_ok(l_per_age
                   ,l_inst_dets(l_insttorrw_num).mx_age_num
                   ,l_inst_dets(l_insttorrw_num).mn_age_num
                   ,l_inst_dets(l_insttorrw_num).no_mx_age_flag
                   ,l_inst_dets(l_insttorrw_num).no_mn_age_flag
                   );
      if l_per_age is null then
        --
        l_ok := false;
        --
      end if;
      --
      if l_ok and l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
        --
        if p_score_compute_mode then
           if l_crit_passed is null then
              l_crit_passed := true;
           end if;
           write(l_score_tab,
                 l_inst_dets(l_insttorrw_num).eligy_prfl_id,
                 l_inst_dets(l_insttorrw_num).short_code,
                 l_inst_dets(l_insttorrw_num).pk_id,
                 ( l_per_age * nvl(l_inst_dets(l_insttorrw_num).criteria_weight, 0) ) +
                 nvl(l_inst_dets(l_insttorrw_num).criteria_score, 0)    /* Bug 4429071 */
                 );
        else
           exit;
        end if;
        --
      elsif l_ok and l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := false;
        exit;
        --
      elsif (not l_ok) and l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := true;
        if p_score_compute_mode then
           write(l_score_tab,
                 l_inst_dets(l_insttorrw_num).eligy_prfl_id,
                 l_inst_dets(l_insttorrw_num).short_code,
                 l_inst_dets(l_insttorrw_num).pk_id,
                 ( l_per_age * nvl(l_inst_dets(l_insttorrw_num).criteria_weight, 0) ) +
                 nvl(l_inst_dets(l_insttorrw_num).criteria_score, 0)    /* Bug 4429071 */
                 );
        end if;
        --exit ;
        --
      elsif l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
        --
        l_rows_found := true;
        --
      end if;
      --
    end loop;
    --
  end if;
  --
  --
  if l_crit_passed is null
  then
     if l_rows_found and
       not l_ok then
       --
       g_inelg_rsn_cd := 'AGE';
       fnd_message.set_name('BEN','BEN_91670_AGE_PRFL_FAIL');
       hr_utility.set_location('Criteria Failed: '||l_proc,20);
       raise g_criteria_failed;
       --
     end if;
  end if;
  --
  if p_score_compute_mode
  then
     hr_utility.set_location('count '||l_score_tab.count,20);
     write(p_profile_score_tab,l_score_tab);
  end if;
  hr_utility.set_location('Leaving :'||l_proc, 20);
  --
end check_age_elig;
--
-- --------------------------------------------------------------------
--  This procedure determines eligibility based on combination age/los.
-- --------------------------------------------------------------------
--
procedure check_age_los_elig(p_eligy_prfl_id     in number,
                             p_person_id         in number,
                             p_business_group_id in number,
                             p_effective_date    in date,
                             p_per_cmbn_age_los  in number,
                             p_per_cmbn_age      in number,
                             p_per_cmbn_los      in number,
                             p_dob               in date,
                             p_eval_typ          in varchar2,
                             p_comp_obj_mode     in boolean,
                             p_currepe_row       in ben_determine_rates.g_curr_epe_rec,
                             p_lf_evt_ocrd_dt    in date,
                             p_score_compute_mode in boolean default false,
                             p_profile_score_tab in out nocopy scoreTab,
                             p_per_in_ler_id     in number default null,
                             p_pl_id             in number default null,
                             p_pgm_id            in number default null,
                             p_oipl_id           in number default null,
                             p_plip_id           in number default null,
                             p_opt_id            in number default null) is
  --
  l_proc              varchar2(100):= g_package||'check_age_los_elig';
  l_inst_dets ben_elp_cache.g_cache_elpecp_instor;
  l_inst_count number;
  l_insttorrw_num binary_integer;
  l_ok                boolean := false;
  l_rows_found        boolean := false;
  l_age_fctr_id       number;
  l_los_fctr_id       number;
  l_age_check ben_agf_cache.g_cache_agf_instor;
  l_los_check ben_los_cache.g_cache_los_instor;
  l_dummy_date     date;
  l_pl_id          number;
  l_pgm_id         number;
  l_per_in_ler_id  number;
  l_oipl_id        number;
  l_dob            date   := p_dob;
  l_per_cmbn_age   number := p_per_cmbn_age;
  l_per_cmbn_los   number := p_per_cmbn_los;
  l_per_cmbn_age_los        number := p_per_cmbn_age_los;
  l_prtn_ovridn_flag  varchar2(30);
  l_prtn_ovridn_thru_dt date;
  l_epo_row         ben_derive_part_and_rate_facts.g_cache_structure;
  l_crit_passed     boolean;
  l_score_tab       scoreTab;
  --
begin
  --
  hr_utility.set_location('Entering :'||l_proc,10);
  --
  -- Getting eligibility profile age/los combination by eligibility profile
  --
  ben_elp_cache.elpecp_getcacdets
    (p_effective_date    => nvl(l_fonm_cvg_strt_dt,p_effective_date)
    ,p_business_group_id => p_business_group_id
    ,p_eligy_prfl_id     => p_eligy_prfl_id
    ,p_inst_set          => l_inst_dets
    ,p_inst_count        => l_inst_count);
  --
  if l_inst_count > 0 then
    --
    if p_eval_typ <> 'E' then
        --
        -- plan in program is overriden, capture the data from cache by
        -- passing plip_id
        --
        if p_opt_id is null and p_pgm_id is not null then
           ben_pep_cache.get_pilpep_dets(
                p_person_id         => p_person_id,
                p_business_group_id => p_business_group_id,
                p_effective_date    => nvl(l_fonm_cvg_strt_dt,p_effective_date),
                p_pgm_id            => p_pgm_id,
                p_plip_id           => p_plip_id,
                p_inst_row          => l_epo_row);
                l_prtn_ovridn_flag    := l_epo_row.prtn_ovridn_flag;
                l_prtn_ovridn_thru_dt := l_epo_row.prtn_ovridn_thru_dt;
                l_per_cmbn_age_los    := l_epo_row.rt_cmbn_age_n_los_val;
        elsif p_opt_id is not null and p_pgm_id is not null then
                ben_pep_cache.get_pilepo_dets(
                p_person_id         => p_person_id,
                p_business_group_id => p_business_group_id,
                p_effective_date    => nvl(l_fonm_cvg_strt_dt,p_effective_date),
                p_pgm_id            => p_pgm_id,
                p_plip_id           => p_plip_id,
                p_opt_id            => p_opt_id,
                p_inst_row          => l_epo_row);
                l_prtn_ovridn_flag    := l_epo_row.prtn_ovridn_flag;
                l_prtn_ovridn_thru_dt := l_epo_row.prtn_ovridn_thru_dt;
                l_per_cmbn_age_los    := l_epo_row.rt_cmbn_age_n_los_val;
        else
              hr_utility.set_location('Plan not in Program',10);
               l_prtn_ovridn_flag    := p_currepe_row.prtn_ovridn_flag;
               l_prtn_ovridn_thru_dt := p_currepe_row.prtn_ovridn_thru_dt;
               l_per_cmbn_age_los    := p_currepe_row.rt_cmbn_age_n_los_val;
        end if;
    end if;
    --
    for l_insttorrw_num in l_inst_dets.first .. l_inst_dets.last loop
      --
      l_los_fctr_id := l_inst_dets(l_insttorrw_num).los_fctr_id;
      l_age_fctr_id := l_inst_dets(l_insttorrw_num).age_fctr_id;
      --
      if not p_comp_obj_mode or
         (p_eval_typ <> 'E' and
          not (nvl(l_prtn_ovridn_flag,'N') = 'Y' and
               nvl(l_prtn_ovridn_thru_dt,hr_api.g_eot) > nvl(l_fonm_cvg_strt_dt,p_effective_date))
         ) then
        --
        ben_derive_factors.determine_los
          (p_person_id            => p_person_id,
           p_los_fctr_id          => l_los_fctr_id,
           p_pgm_id               => p_pgm_id ,
           p_pl_id                => p_pl_id ,
           p_oipl_id              => p_oipl_id ,
           p_per_in_ler_id        => p_per_in_ler_id ,
           p_comp_obj_mode        => p_comp_obj_mode ,
           p_effective_date       => p_effective_date,
           p_lf_evt_ocrd_dt       => p_lf_evt_ocrd_dt,
           p_business_group_id    => p_business_group_id ,
           p_perform_rounding_flg => TRUE ,
           p_value                => l_per_cmbn_los,
           p_start_date           => l_dummy_date,
           p_fonm_cvg_strt_dt     => l_fonm_cvg_strt_dt );
        --
        ben_derive_factors.determine_age
          (p_person_id            => p_person_id,
           p_per_dob              => l_dob,
           p_age_fctr_id          => l_age_fctr_id,
           p_pgm_id               => p_pgm_id ,
           p_pl_id                => p_pl_id ,
           p_oipl_id              => p_oipl_id ,
           p_per_in_ler_id        => p_per_in_ler_id ,
           p_comp_obj_mode        => p_comp_obj_mode ,
           p_effective_date       => p_effective_date,
           p_lf_evt_ocrd_dt       => p_lf_evt_ocrd_dt,
           p_business_group_id    => p_business_group_id ,
           p_perform_rounding_flg => TRUE,
           p_value                => l_per_cmbn_age,
           p_change_date          => l_dummy_date,
           p_fonm_cvg_strt_dt     => l_fonm_cvg_strt_dt );
        --
        l_per_cmbn_age_los := l_per_cmbn_age + l_per_cmbn_los;
        --
      end if;
      --
      -- Combo passes, now check if components pass
      --
      l_ok := is_ok(l_per_cmbn_age_los
                   ,l_inst_dets(l_insttorrw_num).cmbnd_max_val
                   ,l_inst_dets(l_insttorrw_num).cmbnd_min_val
                   );
      --
      hr_utility.set_location('TOTAL ='||l_per_cmbn_age_los,10);
      hr_utility.set_location('MIN ='||l_inst_dets(l_insttorrw_num).cmbnd_min_val,10);
      hr_utility.set_location('MAX ='||l_inst_dets(l_insttorrw_num).cmbnd_max_val,10);
      if l_per_cmbn_age_los is null then
        --
        l_ok := false;
        --
      end if;
      --
      if not l_ok then
        --
        hr_utility.set_location('Failed cmbn',10);
        --
      elsif l_ok then
        --
        -- Getting length of service factor
        --
        ben_los_cache.los_getcacdets
          (p_effective_date    => nvl(l_fonm_cvg_strt_dt,p_effective_date)
          ,p_business_group_id => p_business_group_id
          ,p_los_fctr_id       => l_los_fctr_id
          ,p_inst_set          => l_los_check
          ,p_inst_count        => l_inst_count);
        --
        l_ok := is_ok(l_per_cmbn_los
                     ,l_los_check(0).mx_los_num
                     ,l_los_check(0).mn_los_num
                     ,l_los_check(0).no_mx_los_num_apls_flag
                     ,l_los_check(0).no_mn_los_num_apls_flag
                     );
        if l_per_cmbn_los is null then
          --
          l_ok := false;
          --
        end if;
        --
      end if;
      --
      if not l_ok then
        --
        hr_utility.set_location('Failed los',10);
        --
      elsif l_ok then
        --
        -- Check if age passes
        --
        -- Getting age factor
        --
        ben_agf_cache.agf_getcacdets
        (p_effective_date => nvl(l_fonm_cvg_strt_dt,p_effective_date)
        ,p_business_group_id => p_business_group_id
        ,p_age_fctr_id => l_age_fctr_id
        --
        ,p_inst_set => l_age_check
        ,p_inst_count => l_inst_count);
        --
        l_ok := is_ok(l_per_cmbn_age
                     ,l_age_check(0).mx_age_num
                     ,l_age_check(0).mn_age_num
                     ,l_age_check(0).no_mx_age_flag
                     ,l_age_check(0).no_mn_age_flag
                     );
        --
        if l_per_cmbn_age is null then
          --
          l_ok := false;
          --
        end if;
        --
      end if;
      --
      if l_ok and l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
        --
        if p_score_compute_mode then
           if l_crit_passed is null then
              l_crit_passed := true;
           end if;
           write(l_score_tab,
                 l_inst_dets(l_insttorrw_num).eligy_prfl_id,
                 l_inst_dets(l_insttorrw_num).short_code,
                 l_inst_dets(l_insttorrw_num).pk_id,
                 ( l_per_cmbn_age_los * nvl(l_inst_dets(l_insttorrw_num).criteria_weight, 0) ) +
                 nvl(l_inst_dets(l_insttorrw_num).criteria_score, 0)    /* Bug 4449229 */
                 );
        else
           exit;
        end if;
        --
      elsif l_ok and l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := false;
        exit;
        --
      elsif (not l_ok) and l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := true;
        if p_score_compute_mode then
           write(l_score_tab,
                 l_inst_dets(l_insttorrw_num).eligy_prfl_id,
                 l_inst_dets(l_insttorrw_num).short_code,
                 l_inst_dets(l_insttorrw_num).pk_id,
                 ( l_per_cmbn_age_los * nvl(l_inst_dets(l_insttorrw_num).criteria_weight, 0) ) +
                 nvl(l_inst_dets(l_insttorrw_num).criteria_score, 0)    /* Bug 4449229 */
                 );
        end if;
        --exit ;
        --
      elsif l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
        --
        l_rows_found := true;
        --
      end if;
      --
    end loop;
    --
  end if;
  --
  if l_crit_passed is null
  then
     if l_rows_found and
       not l_ok then
       --
       hr_utility.set_location('Failed Elig ',10);
       g_inelg_rsn_cd := 'AGL';
       fnd_message.set_name('BEN','BEN_91671_AGE_LOS_PRFL_FAIL');
       raise g_criteria_failed;
       --
     end if;
  end if;
  --
  if p_score_compute_mode
  then
     hr_utility.set_location('count '||l_score_tab.count,20);
     write(p_profile_score_tab,l_score_tab);
  end if;
  hr_utility.set_location('Leaving :'||l_proc,20);
  --
end check_age_los_elig;
--
-- -----------------------------------------------------------
--  This procedure determines eligibility based on comp level.
-- -----------------------------------------------------------
--
procedure check_comp_level_rl_elig(p_eligy_prfl_id     in number,
                                   p_person_id         in number,
                                   p_business_group_id in number,
                                   p_effective_date    in date,
                                   p_per_comp_val      in number,
                                   p_eval_typ          in varchar2,
                                   p_comp_obj_mode     in boolean,
                                   p_lf_evt_ocrd_dt    in date,
                                   p_score_compute_mode in boolean default false,
                                   p_profile_score_tab in out nocopy scoreTab,
                                   p_per_in_ler_id     in number default null,
                                   p_pl_id             in number default null,
                                   p_pgm_id            in number default null,
                                   p_oipl_id           in number default null,
                                   p_plip_id           in number default null,
                                   p_opt_id            in number default null) is
  --
  l_proc             varchar2(100):=g_package||'check_comp_level_rl_elig';
  l_inst_dets ben_elp_cache.g_cache_elpecl_instor;
  l_inst_count number;
  l_insttorrw_num binary_integer;
  l_ok               boolean := false;
  l_rows_found       boolean := false;
  l_pl_id          number;
  l_pgm_id         number;
  l_per_in_ler_id  number;
  l_oipl_id        number;
  l_per_comp_val   number := p_per_comp_val;
  l_crit_passed     boolean;
  l_score_tab       scoreTab;
  --
begin
  --
  hr_utility.set_location('Entering: '||l_proc, 10);
  --
  -- Getting eligibility profile compensation level by eligibility profile
  --
  ben_elp_cache.elpecl_getcacdets
    (p_effective_date    => nvl(l_fonm_cvg_strt_dt,p_effective_date)
    ,p_business_group_id => p_business_group_id
    ,p_comp_src_cd       => 'RL'
    ,p_eligy_prfl_id     => p_eligy_prfl_id
    ,p_inst_set          => l_inst_dets
    ,p_inst_count        => l_inst_count);
  --
  if l_inst_count > 0 then
    --
    for l_insttorrw_num in l_inst_dets.first .. l_inst_dets.last loop
      --
      if not p_comp_obj_mode or
         p_eval_typ <> 'E' then
        --
        ben_derive_factors.determine_compensation
        (p_person_id            => p_person_id
        ,p_comp_lvl_fctr_id     => l_inst_dets(l_insttorrw_num).comp_lvl_fctr_id
        ,p_pgm_id               => p_pgm_id
        ,p_pl_id                => p_pl_id
        ,p_oipl_id              => p_oipl_id
        ,p_per_in_ler_id        => p_per_in_ler_id
        ,p_comp_obj_mode        => p_comp_obj_mode
        ,p_perform_rounding_flg => true
        ,p_effective_date       => p_effective_date
        ,p_lf_evt_ocrd_dt       => p_lf_evt_ocrd_dt
        ,p_business_group_id    => p_business_group_id
        ,p_value                => l_per_comp_val
        ,p_fonm_cvg_strt_dt     => l_fonm_cvg_strt_dt );
      --
      end if;
      --
      l_ok := is_ok(l_per_comp_val
                   ,l_inst_dets(l_insttorrw_num).mx_comp_val
                   ,l_inst_dets(l_insttorrw_num).mn_comp_val
                   ,l_inst_dets(l_insttorrw_num).no_mx_comp_flag
                   ,l_inst_dets(l_insttorrw_num).no_mn_comp_flag
                   );
      --
      if l_per_comp_val is null then
        --
        l_ok := false;
        --
      end if;
      --
      if l_ok and l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
        --
        if p_score_compute_mode then
           if l_crit_passed is null then
              l_crit_passed := true;
           end if;
           write(l_score_tab,
                 l_inst_dets(l_insttorrw_num).eligy_prfl_id,
                 l_inst_dets(l_insttorrw_num).short_code,
                 l_inst_dets(l_insttorrw_num).pk_id,
                 ( l_per_comp_val * nvl(l_inst_dets(l_insttorrw_num).criteria_weight, 0) ) +
                 nvl(l_inst_dets(l_insttorrw_num).criteria_score, 0)    /* Bug 4429071 */
                 );
        else
           exit;
        end if;
        --
      elsif l_ok and l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := false;
        exit;
        --
      elsif (not l_ok) and l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := true;
        if p_score_compute_mode then
           write(l_score_tab,
                 l_inst_dets(l_insttorrw_num).eligy_prfl_id,
                 l_inst_dets(l_insttorrw_num).short_code,
                 l_inst_dets(l_insttorrw_num).pk_id,
                 ( l_per_comp_val * nvl(l_inst_dets(l_insttorrw_num).criteria_weight, 0) ) +
                 nvl(l_inst_dets(l_insttorrw_num).criteria_score, 0)    /* Bug 4429071 */
                 );
        end if;
        --exit ;
        --
      elsif l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
        --
        l_rows_found := true;
        --
      end if;
      --
    end loop;
    --
  end if;
  --
  if l_crit_passed is null
  then
     if l_rows_found and
       not l_ok then
       --
       g_inelg_rsn_cd := 'CMP';
       fnd_message.set_name('BEN','BEN_91672_COMP_LVL_PRFL_FAIL');
       hr_utility.set_location('Criteria Failed: '||l_proc,20);
       raise g_criteria_failed;
       --
     end if;
  end if;
  --
  hr_utility.set_location('Leaving :'||l_proc,20);
  --
  if p_score_compute_mode
  then
     hr_utility.set_location('count '||l_score_tab.count,20);
     write(p_profile_score_tab,l_score_tab);
  end if;
end check_comp_level_rl_elig;
--
-- -----------------------------------------------------------
--  This procedure determines eligibility based on comp level.
-- -----------------------------------------------------------
--
procedure check_comp_level_elig(p_eligy_prfl_id     in number,
                                p_business_group_id in number,
                                p_effective_date    in date,
                                p_comp_obj_mode     in boolean,
                                p_pgm_id            in number,
                                p_pl_id             in number,
                                p_oipl_id           in number,
                                p_per_in_ler_id     in number,
                                p_score_compute_mode in boolean default false,
                                p_profile_score_tab in out nocopy scoreTab,
                                p_person_id         in number,
                                p_per_comp_val      in number) is
  --
  l_proc             varchar2(100):=g_package||'check_comp_level_elig';
  l_inst_dets ben_elp_cache.g_cache_elpecl_instor;
  l_inst_count number;
  l_insttorrw_num binary_integer;
  l_ok               boolean := false;
  l_rows_found       boolean := false;
  l_per_comp_val     number;
  l_crit_passed     boolean;
  l_score_tab       scoreTab;
  --
begin
  --
  hr_utility.set_location('Entering: '||l_proc, 10);
  --
  -- Getting eligibility profile compensation level by eligibility profile
  --
  ben_elp_cache.elpecl_getcacdets
    (p_effective_date    => nvl(l_fonm_cvg_strt_dt,p_effective_date)
    ,p_business_group_id => p_business_group_id
    ,p_comp_src_cd       => 'STTDCOMP'
    ,p_eligy_prfl_id     => p_eligy_prfl_id
    ,p_inst_set          => l_inst_dets
    ,p_inst_count        => l_inst_count);
  --
  if l_inst_count > 0 then
    --
    for l_insttorrw_num in l_inst_dets.first .. l_inst_dets.last loop
      --
      --if p_per_comp_val is null then
        --
        --fnd_message.set_name('BEN','BEN_91767_DERIVABLE_NO_EXIST');
        --raise ben_manage_life_events.g_record_error;
        --
      --end if;
      --
      -- as the derived factor may have periodicity, we need to compute the compensation
      -- based on periodicity before comparing for min and max value
      -- bug#2015717
      ben_derive_factors.determine_compensation
              (p_comp_lvl_fctr_id     => l_inst_dets(l_insttorrw_num).comp_lvl_fctr_id,
               p_person_id            => p_person_id,
               p_pgm_id               => p_pgm_id,
               p_pl_id                => p_pl_id,
               p_oipl_id              => p_oipl_id,
               p_per_in_ler_id        => p_per_in_ler_id,
               p_comp_obj_mode        => p_comp_obj_mode,
               p_business_group_id    => p_business_group_id,
               p_effective_date       => p_effective_date,
               p_value                => l_per_comp_val,
               p_fonm_cvg_strt_dt     => l_fonm_cvg_strt_dt);
      --
      l_ok := is_ok(l_per_comp_val
                   ,l_inst_dets(l_insttorrw_num).mx_comp_val
                   ,l_inst_dets(l_insttorrw_num).mn_comp_val
                   ,l_inst_dets(l_insttorrw_num).no_mx_comp_flag
                   ,l_inst_dets(l_insttorrw_num).no_mn_comp_flag
                   );
      --
      if l_per_comp_val is null then
        --
        l_ok := false;
        --
      end if;
      --
      if l_ok and l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
        if p_score_compute_mode then
           if l_crit_passed is null then
              l_crit_passed := true;
           end if;
           write(l_score_tab,
                 l_inst_dets(l_insttorrw_num).eligy_prfl_id,
                 l_inst_dets(l_insttorrw_num).short_code,
                 l_inst_dets(l_insttorrw_num).pk_id,
                 ( l_per_comp_val * nvl(l_inst_dets(l_insttorrw_num).criteria_weight, 0) ) +
                 nvl(l_inst_dets(l_insttorrw_num).criteria_score, 0)    /* Bug 4429071 */
                 );
        else
           exit;
        end if;
        --
      elsif l_ok and l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := false;
        exit;
        --
      elsif (not l_ok) and l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := true;
        if p_score_compute_mode then
           write(l_score_tab,
                 l_inst_dets(l_insttorrw_num).eligy_prfl_id,
                 l_inst_dets(l_insttorrw_num).short_code,
                 l_inst_dets(l_insttorrw_num).pk_id,
                 ( l_per_comp_val * nvl(l_inst_dets(l_insttorrw_num).criteria_weight, 0) ) +
                 nvl(l_inst_dets(l_insttorrw_num).criteria_score, 0)    /* Bug 4429071 */
                 );
        end if;
        --exit ;
        --
      elsif l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
        --
        l_rows_found := true;
        --
      end if;
      --
    end loop;
    --
  end if;
  --
  if l_crit_passed is null
  then
     if l_rows_found and
       not l_ok then
       --
       g_inelg_rsn_cd := 'CMP';
       fnd_message.set_name('BEN','BEN_91672_COMP_LVL_PRFL_FAIL');
       hr_utility.set_location('Criteria Failed: '||l_proc,20);
       raise g_criteria_failed;
       --
     end if;
  end if;
  --
  hr_utility.set_location('Leaving :'||l_proc,20);
  --
  if p_score_compute_mode
  then
     hr_utility.set_location('count '||l_score_tab.count,20);
     write(p_profile_score_tab,l_score_tab);
  end if;
end check_comp_level_elig;
--
-- --------------------------------------------------------------------
--  This procedure determines eligibility based on hours wkd benefits
--  balance.
-- --------------------------------------------------------------------
--
procedure check_hrs_wkd_ben_bal(p_person_id         in number,
                                p_assignment_id     in number,
                                p_eligy_prfl_id     in number,
                                p_once_r_cntug_cd   in varchar2,
                                p_elig_flag         in varchar2,
                                p_business_group_id in number,
                                p_comp_obj_mode     in boolean,
                                p_lf_evt_ocrd_dt    in date,
                                p_score_compute_mode in boolean default false,
                                p_profile_score_tab in out nocopy scoreTab,
                                p_effective_date    in date,
                                p_per_hrs_wkd       in number) is
  --
  l_proc               varchar2(100):= g_package||'check_hrs_wkd_ben_bal';
  l_inst_dets          ben_elp_cache.g_cache_elpehw_instor;
  l_inst_count         number;
  l_insttorrw_num      binary_integer;
  l_ok                 boolean := false;
  l_rows_found         boolean := false;
  l_per_hrs_wkd        number := p_per_hrs_wkd;
  l_crit_passed     boolean;
  l_score_tab       scoreTab;
  --
begin
  --
  hr_utility.set_location('Entering :'||l_proc,10);
  --
  -- Check if we need to test this business rule at all
  --
  hr_utility.set_location('Elig Flag :'||p_elig_flag,10);
  hr_utility.set_location('Once r Cntug Cd :'||p_once_r_cntug_cd,10);
  --
  if p_elig_flag = 'Y' and
    nvl(p_once_r_cntug_cd,'-1') = 'ONCE' then
    --
    return;
    --
  end if;
  --
  -- Getting hours worked profile information
  --
  ben_elp_cache.elpehw_getcacdets
    (p_effective_date    => p_effective_date
    ,p_business_group_id => p_business_group_id
    ,p_hrs_src_cd        => 'BNFTBALTYP'
    ,p_eligy_prfl_id     => p_eligy_prfl_id
    ,p_inst_set          => l_inst_dets
    ,p_inst_count        => l_inst_count);
  --
  hr_utility.set_location('Inst Count :'||l_inst_count,10);
  --
  if l_inst_count > 0 then
    --

    for l_insttorrw_num in l_inst_dets.first .. l_inst_dets.last loop
      --
      --if p_per_hrs_wkd is null then
        --
        --fnd_message.set_name('BEN','BEN_91767_DERIVABLE_NO_EXIST');
        --raise ben_manage_life_events.g_record_error;
        --
      --end if;
      --
      if not p_comp_obj_mode then
          ben_derive_factors.determine_hours_worked
           (p_person_id               => p_person_id,
            p_assignment_id           => p_assignment_id,
            p_hrs_wkd_in_perd_fctr_id =>
                           l_inst_dets(l_insttorrw_num).hrs_wkd_in_perd_fctr_id,
            p_comp_obj_mode           => p_comp_obj_mode,
            p_effective_date          => p_effective_date,
            p_lf_evt_ocrd_dt          => p_lf_evt_ocrd_dt,
            p_business_group_id       => p_business_group_id,
            p_value                   => l_per_hrs_wkd,
            p_fonm_cvg_strt_dt     => l_fonm_cvg_strt_dt );
      end if;

      l_ok := is_ok(l_per_hrs_wkd
                   ,l_inst_dets(l_insttorrw_num).mx_hrs_num
                   ,l_inst_dets(l_insttorrw_num).mn_hrs_num
                   ,l_inst_dets(l_insttorrw_num).no_mx_hrs_wkd_flag
                   ,l_inst_dets(l_insttorrw_num).no_mn_hrs_wkd_flag
                   );
      --
      if l_per_hrs_wkd is null then
        --
        l_ok := false;
        --
      end if;
      --
      if l_ok and l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
        --
        if p_score_compute_mode then
           if l_crit_passed is null then
              l_crit_passed := true;
           end if;
           write(l_score_tab,
                 l_inst_dets(l_insttorrw_num).eligy_prfl_id,
                 l_inst_dets(l_insttorrw_num).short_code,
                 l_inst_dets(l_insttorrw_num).pk_id,
                 ( l_per_hrs_wkd * nvl(l_inst_dets(l_insttorrw_num).criteria_weight, 0) ) +
                 nvl(l_inst_dets(l_insttorrw_num).criteria_score, 0)    /* Bug 4429071 */
                 );
        else
           exit;
        end if;
        --
      elsif l_ok and l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := false;
        exit;
        --
      elsif (not l_ok) and l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := true;
        if p_score_compute_mode then
           write(l_score_tab,
                 l_inst_dets(l_insttorrw_num).eligy_prfl_id,
                 l_inst_dets(l_insttorrw_num).short_code,
                 l_inst_dets(l_insttorrw_num).pk_id,
                 ( l_per_hrs_wkd * nvl(l_inst_dets(l_insttorrw_num).criteria_weight, 0) ) +
                 nvl(l_inst_dets(l_insttorrw_num).criteria_score, 0)    /* Bug 4429071 */
                 );
        end if;
        --exit ;
        --
      elsif l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
        --
        l_rows_found := true;
        --
      end if;
      --
    end loop;
    --
  end if;
  --
  if l_crit_passed is null
  then
     if l_rows_found and
        not l_ok then
       --
       g_inelg_rsn_cd := 'HRS';
       fnd_message.set_name('BEN','BEN_91673_HRS_WKD_PRFL_FAIL');
       hr_utility.set_location('Criteria Failed: '||l_proc,20);
       raise g_criteria_failed;
       --
     end if;
  end if;
  --
  hr_utility.set_location('Leaving :'||l_proc,20);
  --
  if p_score_compute_mode
  then
     hr_utility.set_location('count '||l_score_tab.count,20);
     write(p_profile_score_tab,l_score_tab);
  end if;
end check_hrs_wkd_ben_bal;
--
-- --------------------------------------------------------------------
--  This procedure determines eligibility based on hours wkd balance.
-- --------------------------------------------------------------------
--
procedure check_hrs_wkd_rl_balance(p_person_id         in number,
                                   p_assignment_id     in number,
                                   p_eligy_prfl_id     in number,
                                   p_once_r_cntug_cd   in varchar2,
                                   p_elig_flag         in varchar2,
                                   p_business_group_id in number,
                                   p_comp_obj_mode     in boolean,
                                   p_lf_evt_ocrd_dt    in date,
                                   p_score_compute_mode in boolean default false,
                                   p_profile_score_tab in out nocopy scoreTab,
                                   p_effective_date    in date,
                                   p_per_hrs_wkd       in number) is
  --
  l_proc               varchar2(100):= g_package||'check_hrs_wkd_balance';
  l_inst_dets          ben_elp_cache.g_cache_elpehw_instor;
  l_inst_count         number;
  l_insttorrw_num      binary_integer;
  l_ok                 boolean := false;
  l_rows_found         boolean := false;
  l_per_hrs_wkd        number := p_per_hrs_wkd;
  l_crit_passed     boolean;
  l_score_tab       scoreTab;
  --
begin
  --
  hr_utility.set_location('Entering :'||l_proc,10);
  --
  if p_elig_flag = 'Y' and
    nvl(p_once_r_cntug_cd,'-1') = 'ONCE' then
    --
    return;
    --
  end if;
  --
  -- Getting hours worked profile information
  --
  ben_elp_cache.elpehw_getcacdets
    (p_effective_date    => p_effective_date
    ,p_business_group_id => p_business_group_id
    ,p_hrs_src_cd        => 'RL'
    ,p_eligy_prfl_id     => p_eligy_prfl_id
    ,p_inst_set          => l_inst_dets
    ,p_inst_count        => l_inst_count);
  --
  if l_inst_count > 0 then
    --
    for l_insttorrw_num in l_inst_dets.first .. l_inst_dets.last loop
      --
      --if p_per_hrs_wkd is null then
        --
        --fnd_message.set_name('BEN','BEN_91767_DERIVABLE_NO_EXIST');
        --raise ben_manage_life_events.g_record_error;
        --
      --end if;
      --
      if not p_comp_obj_mode then
          ben_derive_factors.determine_hours_worked
           (p_person_id               => p_person_id,
            p_assignment_id           => p_assignment_id,
            p_hrs_wkd_in_perd_fctr_id =>
                           l_inst_dets(l_insttorrw_num).hrs_wkd_in_perd_fctr_id,
            p_comp_obj_mode           => p_comp_obj_mode,
            p_effective_date          => p_effective_date,
            p_lf_evt_ocrd_dt          => p_lf_evt_ocrd_dt,
            p_business_group_id       => p_business_group_id,
            p_value                   => l_per_hrs_wkd,
            p_fonm_cvg_strt_dt        => l_fonm_cvg_strt_dt );
      end if;
      l_ok := is_ok(l_per_hrs_wkd
                   ,l_inst_dets(l_insttorrw_num).mx_hrs_num
                   ,l_inst_dets(l_insttorrw_num).mn_hrs_num
                   ,l_inst_dets(l_insttorrw_num).no_mx_hrs_wkd_flag
                   ,l_inst_dets(l_insttorrw_num).no_mn_hrs_wkd_flag
                   );
      --
      if l_per_hrs_wkd is null then
        --
        l_ok := false;
        --
      end if;
      --
      if l_ok and l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
        --
        if p_score_compute_mode then
           if l_crit_passed is null then
              l_crit_passed := true;
           end if;
           write(l_score_tab,
                 l_inst_dets(l_insttorrw_num).eligy_prfl_id,
                 l_inst_dets(l_insttorrw_num).short_code,
                 l_inst_dets(l_insttorrw_num).pk_id,
                 ( l_per_hrs_wkd * nvl(l_inst_dets(l_insttorrw_num).criteria_weight, 0) ) +
                 nvl(l_inst_dets(l_insttorrw_num).criteria_score, 0)    /* Bug 4429071 */
                 );
        else
           exit;
        end if;
        --
      elsif l_ok and l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := false;
        exit;
        --
      elsif (not l_ok) and l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := true;
        if p_score_compute_mode then
           write(l_score_tab,
                 l_inst_dets(l_insttorrw_num).eligy_prfl_id,
                 l_inst_dets(l_insttorrw_num).short_code,
                 l_inst_dets(l_insttorrw_num).pk_id,
                 ( l_per_hrs_wkd * nvl(l_inst_dets(l_insttorrw_num).criteria_weight, 0) ) +
                 nvl(l_inst_dets(l_insttorrw_num).criteria_score, 0)    /* Bug 4429071 */
                 );
        end if;
        --exit ;
        --
      elsif l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
        --
        l_rows_found := true;
        --
      end if;
      --
    end loop;
    --
  end if;
  --
  if l_crit_passed is null
  then
     if l_rows_found and
       not l_ok then
       --
       g_inelg_rsn_cd := 'HRS';
       fnd_message.set_name('BEN','BEN_91673_HRS_WKD_PRFL_FAIL');
       hr_utility.set_location('Criteria Failed: '||l_proc,20);
       raise g_criteria_failed;
       --
     end if;
  end if;
  --
  if p_score_compute_mode
  then
     hr_utility.set_location('count '||l_score_tab.count,20);
     write(p_profile_score_tab,l_score_tab);
  end if;
  hr_utility.set_location('Leaving :'||l_proc,20);
  --
end check_hrs_wkd_rl_balance;
--
-- --------------------------------------------------------------------
--  This procedure determines eligibility based on hours wkd balance.
-- --------------------------------------------------------------------
--
procedure check_hrs_wkd_balance(p_person_id         in number,
                                p_assignment_id     in number,
                                p_eligy_prfl_id     in number,
                                p_once_r_cntug_cd   in varchar2,
                                p_elig_flag         in varchar2,
                                p_business_group_id in number,
                                p_comp_obj_mode     in boolean,
                                p_lf_evt_ocrd_dt    in date,
                                p_score_compute_mode in boolean default false,
                                p_profile_score_tab in out nocopy scoreTab,
                                p_effective_date    in date,
                                p_per_hrs_wkd       in number) is
  --
  l_proc               varchar2(100):= g_package||'check_hrs_wkd_balance';
  l_inst_dets          ben_elp_cache.g_cache_elpehw_instor;
  l_inst_count         number;
  l_insttorrw_num      binary_integer;
  l_ok                 boolean := false;
  l_rows_found         boolean := false;
  l_per_hrs_wkd        number := p_per_hrs_wkd;
  l_crit_passed     boolean;
  l_score_tab       scoreTab;
  --
begin
  --
  hr_utility.set_location('Entering :'||l_proc,10);
  --
  if p_elig_flag = 'Y' and
    nvl(p_once_r_cntug_cd,'-1') = 'ONCE' then
    --
    return;
    --
  end if;
  --
  -- Getting hours worked profile information
  --
  ben_elp_cache.elpehw_getcacdets
    (p_effective_date    => p_effective_date
    ,p_business_group_id => p_business_group_id
    ,p_hrs_src_cd        => 'BALTYP'
    ,p_eligy_prfl_id     => p_eligy_prfl_id
    ,p_inst_set          => l_inst_dets
    ,p_inst_count        => l_inst_count);
  --
  if l_inst_count > 0 then
    --
    for l_insttorrw_num in l_inst_dets.first .. l_inst_dets.last loop
      --
      --if p_per_hrs_wkd is null then
        --
        --fnd_message.set_name('BEN','BEN_91767_DERIVABLE_NO_EXIST');
        --raise ben_manage_life_events.g_record_error;
        --
      --end if;
      --
      if not p_comp_obj_mode then
          ben_derive_factors.determine_hours_worked
           (p_person_id               => p_person_id,
            p_assignment_id           => p_assignment_id,
            p_hrs_wkd_in_perd_fctr_id =>
                           l_inst_dets(l_insttorrw_num).hrs_wkd_in_perd_fctr_id,
            p_comp_obj_mode           => p_comp_obj_mode,
            p_effective_date          => p_effective_date,
            p_lf_evt_ocrd_dt          => p_lf_evt_ocrd_dt,
            p_business_group_id       => p_business_group_id,
            p_value                   => l_per_hrs_wkd,
            p_fonm_cvg_strt_dt        => l_fonm_cvg_strt_dt );
      end if;
      l_ok := is_ok(l_per_hrs_wkd
                   ,l_inst_dets(l_insttorrw_num).mx_hrs_num
                   ,l_inst_dets(l_insttorrw_num).mn_hrs_num
                   ,l_inst_dets(l_insttorrw_num).no_mx_hrs_wkd_flag
                   ,l_inst_dets(l_insttorrw_num).no_mn_hrs_wkd_flag
                   );
      --
      if l_per_hrs_wkd is null then
        --
        l_ok := false;
        --
      end if;
      --
      if l_ok and l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
        if p_score_compute_mode then
           if l_crit_passed is null then
              l_crit_passed := true;
           end if;
           write(l_score_tab,
                 l_inst_dets(l_insttorrw_num).eligy_prfl_id,
                 l_inst_dets(l_insttorrw_num).short_code,
                 l_inst_dets(l_insttorrw_num).pk_id,
                 ( l_per_hrs_wkd * nvl(l_inst_dets(l_insttorrw_num).criteria_weight, 0) ) +
                 nvl(l_inst_dets(l_insttorrw_num).criteria_score, 0)    /* Bug 4429071 */
                 );
        else
           exit;
        end if;
        --
      elsif l_ok and l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := false;
        exit;
        --
      elsif (not l_ok) and l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := true;
        if p_score_compute_mode then
           write(l_score_tab,
                 l_inst_dets(l_insttorrw_num).eligy_prfl_id,
                 l_inst_dets(l_insttorrw_num).short_code,
                 l_inst_dets(l_insttorrw_num).pk_id,
                 ( l_per_hrs_wkd * nvl(l_inst_dets(l_insttorrw_num).criteria_weight, 0) ) +
                 nvl(l_inst_dets(l_insttorrw_num).criteria_score, 0)    /* Bug 4429071 */
                 );
        end if;
        --exit ;
        --
      elsif l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
        --
        l_rows_found := true;
        --
      end if;
      --
    end loop;
    --
  end if;
  --
  if l_crit_passed is null
  then
     if l_rows_found and
       not l_ok then
       --
       g_inelg_rsn_cd := 'HRS';
       fnd_message.set_name('BEN','BEN_91673_HRS_WKD_PRFL_FAIL');
       hr_utility.set_location('Criteria Failed: '||l_proc,20);
       raise g_criteria_failed;
       --
     end if;
  end if;
  --
  if p_score_compute_mode
  then
     hr_utility.set_location('count '||l_score_tab.count,20);
     write(p_profile_score_tab,l_score_tab);
  end if;
  hr_utility.set_location('Leaving :'||l_proc,20);
  --
end check_hrs_wkd_balance;
--
-- -----------------------------------------------------------------
--  This procedure determines eligibility based on percent fulltime.
-- -----------------------------------------------------------------
--
procedure check_pct_fltm_elig(p_person_id         in number,
                              p_assignment_id     in number,
                              p_eligy_prfl_id     in number,
                              p_business_group_id in number,
                              p_evl_typ           in varchar2,
                              p_comp_obj_mode     in boolean,
                              p_lf_evt_ocrd_dt    in date,
                              p_score_compute_mode in boolean default false,
                              p_profile_score_tab in out nocopy scoreTab,
                              p_effective_date    in date,
                              p_per_pct_ft_val    in number) is
  --
  l_proc               varchar2(100):=g_package||'check_pct_fltm_elig';
  l_inst_dets ben_elp_cache.g_cache_elpepf_instor;
  l_inst_count number;
  l_insttorrw_num binary_integer;
  l_ok                 boolean := false;
  l_rows_found         boolean := false;
  l_per_pct_ft_val     number  := p_per_pct_ft_val;
  l_crit_passed     boolean;
  l_score_tab       scoreTab;
  --
begin
  --
  hr_utility.set_location('Entering :'||l_proc,10);
  --
  -- Getting eligibility profile full time by eligibility profile
  --
  ben_elp_cache.elpepf_getcacdets
    (p_effective_date    => p_effective_date
    ,p_business_group_id => p_business_group_id
    ,p_eligy_prfl_id     => p_eligy_prfl_id
    ,p_inst_set          => l_inst_dets
    ,p_inst_count        => l_inst_count);
  --
  if l_inst_count > 0 then
    --
    for l_insttorrw_num in l_inst_dets.first .. l_inst_dets.last loop
      --
      if not p_comp_obj_mode then
          ben_derive_factors.determine_pct_fulltime
           (p_person_id               => p_person_id,
            p_assignment_id           => p_assignment_id,
            p_pct_fl_tm_fctr_id =>
                           l_inst_dets(l_insttorrw_num).pct_fl_tm_fctr_id,
            p_comp_obj_mode           => p_comp_obj_mode,
            p_effective_date          => p_effective_date,
            p_lf_evt_ocrd_dt          => p_lf_evt_ocrd_dt,
            p_business_group_id       => p_business_group_id,
            p_value                   => l_per_pct_ft_val,
            p_fonm_cvg_strt_dt     => l_fonm_cvg_strt_dt );
      end if;
      --
      l_ok := is_ok(l_per_pct_ft_val
                   ,l_inst_dets(l_insttorrw_num).mx_pct_val
                   ,l_inst_dets(l_insttorrw_num).mn_pct_val
                   ,l_inst_dets(l_insttorrw_num).no_mx_pct_val_flag
                   ,l_inst_dets(l_insttorrw_num).no_mn_pct_val_flag
                   ,'Y'
                   );
      --
      if l_per_pct_ft_val is null then
        --
        l_ok := false;
        --
      end if;
      --
      if l_ok and l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
        --
        if p_score_compute_mode then
           if l_crit_passed is null then
              l_crit_passed := true;
           end if;
           write(l_score_tab,
                 l_inst_dets(l_insttorrw_num).eligy_prfl_id,
                 l_inst_dets(l_insttorrw_num).short_code,
                 l_inst_dets(l_insttorrw_num).pk_id,
                 ( l_per_pct_ft_val * nvl(l_inst_dets(l_insttorrw_num).criteria_weight, 0) ) +
                 nvl(l_inst_dets(l_insttorrw_num).criteria_score, 0)    /* Bug 4429071 */
                 );
        else
           exit;
        end if;
        --
      elsif l_ok and l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := false;
        exit;
        --
      elsif (not l_ok) and l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := true;
        if p_score_compute_mode then
           write(l_score_tab,
                 l_inst_dets(l_insttorrw_num).eligy_prfl_id,
                 l_inst_dets(l_insttorrw_num).short_code,
                 l_inst_dets(l_insttorrw_num).pk_id,
                 ( l_per_pct_ft_val * nvl(l_inst_dets(l_insttorrw_num).criteria_weight, 0) ) +
                 nvl(l_inst_dets(l_insttorrw_num).criteria_score, 0)    /* Bug 4429071 */
                 );
        end if;
        --exit ;
        --
      elsif l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
        --
        l_rows_found := true;
        --
      end if;
      --
    end loop;
    --
  end if;
  --
  if l_crit_passed is null
  then
     if l_rows_found and
        not l_ok then
       --
       g_inelg_rsn_cd := 'PFT';
       fnd_message.set_name('BEN','BEN_91674_PCT_FT_PRFL_FAIL');
       hr_utility.set_location('Criteria Failed: '||l_proc,20);
       raise g_criteria_failed;
       --
     end if;
  end if;
  --
  if p_score_compute_mode
  then
     hr_utility.set_location('count '||l_score_tab.count,20);
     write(p_profile_score_tab,l_score_tab);
  end if;
  hr_utility.set_location('Leaving :'||l_proc,20);
  --
end check_pct_fltm_elig;
--
-- ------------------------------------------------------
--  This procedure determines eligibility based on grade.
-- ------------------------------------------------------
--
procedure check_grade_elig(p_eligy_prfl_id     in number,
                           p_business_group_id in number,
                           p_score_compute_mode in boolean default false,
                           p_profile_score_tab in out nocopy scoreTab,
                           p_effective_date    in date,
                           p_grade_id          in number) is
  --
  l_proc         varchar2(100) := g_package||'check_grade_elig';
  l_inst_dets ben_elp_cache.g_cache_elpegr_instor;
  l_inst_count number;
  l_insttorrw_num binary_integer;
  l_ok           boolean := false;
  l_rows_found   boolean := false;
  l_crit_passed     boolean;
  l_score_tab       scoreTab;
  --
begin
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  -- Getting eligibility profile grade by eligibility profile
  --
  ben_elp_cache.elpegr_getcacdets
    (p_effective_date    => p_effective_date
    ,p_business_group_id => p_business_group_id
    ,p_eligy_prfl_id     => p_eligy_prfl_id
    ,p_inst_set          => l_inst_dets
    ,p_inst_count        => l_inst_count
    );
  --
  if l_inst_count > 0 then
    --
    for l_insttorrw_num in l_inst_dets.first .. l_inst_dets.last loop
      --
      hr_utility.set_location('GRADE'||p_grade_id,10);
      hr_utility.set_location('COMPARE GRADE'||l_inst_dets(l_insttorrw_num).grade_id,10);
      l_ok := nvl((nvl(p_grade_id,-1) = l_inst_dets(l_insttorrw_num).grade_id),FALSE);
      --if l_ok is null then
      --  l_ok:=false;
      --end if;
      --
      if l_ok and l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
        --
        if p_score_compute_mode then
           if l_crit_passed is null then
              l_crit_passed := true;
           end if;
           write(l_score_tab,
                 l_inst_dets(l_insttorrw_num).eligy_prfl_id,
                 l_inst_dets(l_insttorrw_num).short_code,
                 l_inst_dets(l_insttorrw_num).pk_id,
                 nvl(l_inst_dets(l_insttorrw_num).criteria_score,
                 l_inst_dets(l_insttorrw_num).criteria_weight));
        else
           exit;
        end if;
        --
      elsif l_ok and l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := false;
        exit;
        --
      elsif (not l_ok) and l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := true;
        if p_score_compute_mode then
           write(l_score_tab,
                 l_inst_dets(l_insttorrw_num).eligy_prfl_id,
                 l_inst_dets(l_insttorrw_num).short_code,
                 l_inst_dets(l_insttorrw_num).pk_id,
                 nvl(l_inst_dets(l_insttorrw_num).criteria_score,
                 l_inst_dets(l_insttorrw_num).criteria_weight));
        end if;
        --exit ;
        --
      elsif l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
        --
        l_rows_found := true;
        --
      end if;
      --
    end loop;
    --
  end if;
  --
  if l_crit_passed is null
  then
     if l_rows_found and
       not l_ok then
       --
       g_inelg_rsn_cd := 'GRD';
       fnd_message.set_name('BEN','BEN_91675_GRD_PRFL_FAIL');
       hr_utility.set_location('Criteria Failed: '||l_proc,20);
       raise g_criteria_failed;
       --
     end if;
  end if;
  --
  if p_score_compute_mode
  then
     hr_utility.set_location('count '||l_score_tab.count,20);
     write(p_profile_score_tab,l_score_tab);
  end if;
  hr_utility.set_location('Leaving: '||l_proc,20);
  --
end check_grade_elig;
--
-- ------------------------------------------------------
--  This procedure determines eligibility based on sex.
-- ------------------------------------------------------
--
procedure check_gender_elig(p_eligy_prfl_id     in number,
                           p_business_group_id in number,
                           p_score_compute_mode in boolean default false,
                           p_profile_score_tab in out nocopy scoreTab,
                           p_effective_date    in date,
                           p_sex               in varchar2) is
  --
  l_proc         varchar2(100) := g_package||'check_gender_elig';
  l_inst_dets ben_elp_cache.g_cache_elpegn_instor;
  l_inst_count number;
  l_insttorrw_num binary_integer;
  l_ok           boolean := false;
  l_rows_found   boolean := false;
  l_crit_passed     boolean;
  l_score_tab       scoreTab;
  --
begin
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  -- Getting eligibility profile sex by eligibility profile
  --
  ben_elp_cache.elpegn_getcacdets
    (p_effective_date    => p_effective_date
    ,p_business_group_id => p_business_group_id
    ,p_eligy_prfl_id     => p_eligy_prfl_id
    ,p_inst_set          => l_inst_dets
    ,p_inst_count        => l_inst_count
    );
  --
  if l_inst_count > 0 then
    --
    for l_insttorrw_num in l_inst_dets.first .. l_inst_dets.last loop
      --
      hr_utility.set_location('SEX'||p_sex,10);
      l_ok := nvl((nvl(p_sex,'zz') = l_inst_dets(l_insttorrw_num).sex),FALSE);
      --
      if l_ok and l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
        if p_score_compute_mode then
           if l_crit_passed is null then
              l_crit_passed := true;
           end if;
           write(l_score_tab,
                 l_inst_dets(l_insttorrw_num).eligy_prfl_id,
                 l_inst_dets(l_insttorrw_num).short_code,
                 l_inst_dets(l_insttorrw_num).pk_id,
                 nvl(l_inst_dets(l_insttorrw_num).criteria_score,
                 l_inst_dets(l_insttorrw_num).criteria_weight));
        else
           exit;
        end if;
        --
      elsif l_ok and l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := false;
        exit;
        --
      elsif (not l_ok) and l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := true;
        if p_score_compute_mode then
           write(l_score_tab,
                 l_inst_dets(l_insttorrw_num).eligy_prfl_id,
                 l_inst_dets(l_insttorrw_num).short_code,
                 l_inst_dets(l_insttorrw_num).pk_id,
                 nvl(l_inst_dets(l_insttorrw_num).criteria_score,
                 l_inst_dets(l_insttorrw_num).criteria_weight));
        end if;
        --exit ;
        --
      elsif l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
        --
        l_rows_found := true;
        --
      end if;
      --
    end loop;
    --
  end if;
  --
  if l_crit_passed is null
  then
     if l_rows_found and
       not l_ok then
       --
       g_inelg_rsn_cd := 'GND';
       fnd_message.set_name('BEN','BEN_91675_GND_PRFL_FAIL');
       hr_utility.set_location('Criteria Failed: '||l_proc,20);
       raise g_criteria_failed;
       --
     end if;
  end if;
  --
  if p_score_compute_mode
  then
     hr_utility.set_location('count '||l_score_tab.count,20);
     write(p_profile_score_tab,l_score_tab);
  end if;
  hr_utility.set_location('Leaving: '||l_proc,20);
  --
end check_gender_elig;
--
-- ------------------------------------------------------
--  This procedure determines eligibility based on rules.
-- ------------------------------------------------------
--
procedure check_rule_elig
  (p_person_id         in number
  ,p_business_group_id in number
  ,p_pgm_id            in number
  ,p_pl_id             in number
  ,p_oipl_id           in number
  -- Added ler_id to call RCHASE 17-JUL-2000 Bug#5392
  ,p_ler_id            in number
  ,p_eligy_prfl_id     in number
  ,p_effective_date    in date
  ,p_score_compute_mode in boolean default false
  ,p_profile_score_tab in out nocopy scoreTab
  ,p_assignment_id     in number
  -- Bug# 2424041
  ,p_pl_typ_id         in number
  ,p_organization_id   in number
  )
is
  --
  cursor c_ff_use_asg(cv_formula_id in number) is
     select 'Y'
     from ff_fdi_usages_f
     where FORMULA_ID = cv_formula_id
       and ITEM_NAME  = 'ASSIGNMENT_ID'
       and usage      = 'U';
  --
  l_proc          varchar2(100) := g_package||'check_rule_elig';
  l_inst_dets     ben_elp_cache.g_cache_elperl_instor;
  l_inst_count    number;
  l_insttorrw_num binary_integer;
  l_ok            boolean := false;
  l_rows_found    boolean := false;
  l_output        ff_exec.outputs_t;
  l_eligible      varchar2(30);
  l_oipl_rec      ben_cobj_cache.g_oipl_inst_row;
  l_ff_use_asg_id_flag varchar2(1);
  l_ben_elgy_prfl_rl_Cond  varchar2(30) := 'A' ;
  l_crit_passed     boolean;
  l_score_tab       scoreTab;
  --
begin
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  -- Getting eligibility profile rule by eligibility profile
  --

  ben_elp_cache.elperl_getcacdets
    (p_effective_date    => p_effective_date
    ,p_business_group_id => p_business_group_id
    ,p_eligy_prfl_id     => p_eligy_prfl_id
    ,p_inst_set          => l_inst_dets
    ,p_inst_count        => l_inst_count);
  --
  if l_inst_count > 0 then
    --find the profile value for  formul and/Or # 2508757\
    l_ben_elgy_prfl_rl_Cond :=     fnd_profile.value('BEN_ELGY_PRFL_RL_COND');
    --
    hr_utility.set_location('assignment_id='||p_assignment_id,1963);
    hr_utility.set_location('l_ben_elgy_prfl_rl_Cond='||l_ben_elgy_prfl_rl_Cond,1963);
    --
    if p_oipl_id is not null then
      --
      l_oipl_rec := ben_cobj_cache.g_oipl_currow;
      --
    end if;
    --
    for l_insttorrw_num in l_inst_dets.first .. l_inst_dets.last loop
      --
      -- Bug : 5059 : If the person have no assignment id, and formula
      -- uses data base items based on assignment id, then formula raises
      -- error like : A SQL SELECT statement, obtained from the application
      -- dictionary returned no rows. If assignement id is null and formula
      -- uses any DBI's which depend on it, make the person ineligible.
      --
      if p_assignment_id is null then
         --
         l_ff_use_asg_id_flag := 'N';
         open c_ff_use_asg(l_inst_dets(l_insttorrw_num).formula_id);
         fetch c_ff_use_asg into l_ff_use_asg_id_flag;
         close c_ff_use_asg;
         --
         if l_ff_use_asg_id_flag = 'Y'
         then
           --
           g_inelg_rsn_cd := 'ERL';
           fnd_message.set_name('BEN','BEN_92445_ERL_PRFL_FAIL');
           hr_utility.set_location('Criteria Failed: '||l_proc,19);
           raise g_criteria_failed;
           --
         end if;
         --
      end if;
      --
      -- New param1 added for bug # 2679854
      l_output :=
      benutils.formula
          (p_formula_id            => l_inst_dets(l_insttorrw_num).formula_id,
           p_assignment_id         => p_assignment_id,
           p_business_group_id     => p_business_group_id,
           p_pgm_id                => p_pgm_id,
           p_pl_id                 => p_pl_id,
           -- Added ler_id to call RCHASE 17-JUL-2000 Bug#5392
           p_ler_id                => p_ler_id,
           p_opt_id                => l_oipl_rec.opt_id,
           -- bug 2424041
           p_pl_typ_id             => p_pl_typ_id,
           p_organization_id       => p_organization_id,
           p_effective_date        => p_effective_date,
           p_param1                => 'BEN_ELP_I_ELIGY_PRFL_ID',
           p_param1_value          => to_char(nvl(p_eligy_prfl_id, -1)),
           p_param2                => 'BEN_IV_RT_STRT_DT',
           p_param2_value          => fnd_date.date_to_canonical(ben_manage_life_events.g_fonm_rt_strt_dt),
           p_param3                => 'BEN_IV_CVG_STRT_DT',
           p_param3_value          => fnd_date.date_to_canonical(l_fonm_cvg_strt_dt),
           p_param4                => 'BEN_IV_PERSON_ID',            -- Bug 5331889 : Added person_id param as well
           p_param4_value          => to_char(p_person_id)
          );

      --
      for l_count in l_output.first..l_output.last loop
        --
        begin
          --
          if l_output(l_count).name = 'ELIGIBLE' then
            --
            l_eligible := l_output(l_count).value;
            --
          else
            --
            -- Account for cases where formula returns an unknown
            -- variable name
            --
            fnd_message.set_name('BEN','BEN_92310_FORMULA_RET_PARAM_');
            fnd_message.set_token('PROC',l_proc);
            fnd_message.set_token('FORMULA', l_inst_dets(l_insttorrw_num).formula_id);
            fnd_message.set_token('PARAMETER',l_output(l_count).name);
            fnd_message.raise_error;
            --
          end if;
          --
          -- Code for type casting errors from formula return variables
          --
        exception
          --
          when others then
            --
            fnd_message.set_name('BEN','BEN_92311_FORMULA_VAL_PARAM');
            fnd_message.set_token('PROC',l_proc);
            fnd_message.set_token('FORMULA',
                                   l_inst_dets(l_insttorrw_num).formula_id);
            fnd_message.set_token('PARAMETER',l_output(l_count).name);
            fnd_message.raise_error;
          --
        end;
        --
      end loop;
      --if the condition is AND and fails go out 2508757
      hr_utility.set_location('l_eligible='||l_eligible,1963);
      if nvl(l_ben_elgy_prfl_rl_Cond,'A')  = 'A' then

           if l_eligible <> 'Y' then
              --
              g_inelg_rsn_cd := 'ERL';
              fnd_message.set_name('BEN','BEN_92445_ERL_PRFL_FAIL');
              hr_utility.set_location('Criteria Failed: '||l_proc,20);
              raise g_criteria_failed;
           End if ;
      Else   ---- if the condition is OR and pass then exit
           if l_eligible = 'Y' then
              if p_score_compute_mode then
                 if l_crit_passed is null then
                    l_crit_passed := true;
                 end if;
                 write(l_score_tab,
                       l_inst_dets(l_insttorrw_num).eligy_prfl_id,
                       l_inst_dets(l_insttorrw_num).short_code,
                       l_inst_dets(l_insttorrw_num).pk_id,
                       nvl(l_inst_dets(l_insttorrw_num).criteria_score,
                       l_inst_dets(l_insttorrw_num).criteria_weight));
              else
                 exit;
              end if;
           end if ;
      End if ;

      --
    end loop;
    --if the condition is OR and and exit the loop with 'N' throw error
    if l_crit_passed is null
    then
       if nvl(l_ben_elgy_prfl_rl_Cond,'A')  = 'O' and  l_eligible <> 'Y'  then
         hr_utility.set_location('erroring on OR and N ',1963);
           g_inelg_rsn_cd := 'ERL';
           fnd_message.set_name('BEN','BEN_92445_ERL_PRFL_FAIL');
           hr_utility.set_location('Criteria Failed: '||l_proc,20);
           raise g_criteria_failed;
       end if ;
    end if ;

  end if;
  --
  if p_score_compute_mode --999
  then
     hr_utility.set_location('count '||l_score_tab.count,20);
     write(p_profile_score_tab,l_score_tab);
  end if;
  hr_utility.set_location('Leaving: '||l_proc,20);
  --
end check_rule_elig;
-- --------------------------------------------------
--  This procedure determines elibility based on job.
-- --------------------------------------------------
procedure check_job_elig(p_eligy_prfl_id     in number,
                         p_business_group_id in number,
                         p_score_compute_mode in boolean default false,
                         p_profile_score_tab in out nocopy scoreTab,
                         p_effective_date    in date,
                         p_job_id            in number) is
  --
  l_proc       varchar2(100) := g_package||'check_job_elig';
  l_inst_dets ben_elp_cache.g_cache_elpejp_instor;
  l_inst_count number;
  l_insttorrw_num binary_integer;
  l_ok         boolean := false;
  l_rows_found boolean := false;
  l_crit_passed     boolean;
  l_score_tab       scoreTab;
  --
begin
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  -- Getting eligibility profile job by eligibility profile
  --
  ben_elp_cache.elpejp_getcacdets
    (p_effective_date    => p_effective_date
    ,p_business_group_id => p_business_group_id
    ,p_eligy_prfl_id     => p_eligy_prfl_id
    ,p_inst_set          => l_inst_dets
    ,p_inst_count        => l_inst_count);
  --
  if l_inst_count > 0 then
    --
    for l_insttorrw_num in l_inst_dets.first .. l_inst_dets.last loop
      --
      l_ok := nvl((nvl(p_job_id,-1) = l_inst_dets(l_insttorrw_num).job_id),FALSE);
      --if l_ok is null then
      --  l_ok:=false;
      --end if;
      --
      if l_ok and l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
        --
        if p_score_compute_mode then
           if l_crit_passed is null then
              l_crit_passed := true;
           end if;
           write(l_score_tab,
                 l_inst_dets(l_insttorrw_num).eligy_prfl_id,
                 l_inst_dets(l_insttorrw_num).short_code,
                 l_inst_dets(l_insttorrw_num).pk_id,
                 nvl(l_inst_dets(l_insttorrw_num).criteria_score,
                 l_inst_dets(l_insttorrw_num).criteria_weight));
        else
           exit;
        end if;
        --
      elsif l_ok and l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := false;
        exit;
        --
      elsif (not l_ok) and l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := true;
        if p_score_compute_mode then
           write(l_score_tab,
                 l_inst_dets(l_insttorrw_num).eligy_prfl_id,
                 l_inst_dets(l_insttorrw_num).short_code,
                 l_inst_dets(l_insttorrw_num).pk_id,
                 nvl(l_inst_dets(l_insttorrw_num).criteria_score,
                 l_inst_dets(l_insttorrw_num).criteria_weight));
        end if;
        -- exit ;
        --
      elsif l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
        --
        l_rows_found := true;
        --
      end if;
      --
    end loop;
    --
  end if;
  --
  if l_crit_passed is null
  then
     if l_rows_found and
        not l_ok then
       --
       g_inelg_rsn_cd := 'JOB';
       fnd_message.set_name('BEN','BEN_91676_JOB_PRFL_FAIL');
       hr_utility.set_location('Criteria Failed: '||l_proc,20);
       raise g_criteria_failed;
       --
     end if;
  end if;
  --
  if p_score_compute_mode
  then
     hr_utility.set_location('count '||l_score_tab.count,20);
     write(p_profile_score_tab,l_score_tab);
  end if;
  hr_utility.set_location('Leaving: '||l_proc,20);
  --
end check_job_elig;
--
-- -----------------------------------------------------------
-- This procedure determines eligibility based on person type.
-- -----------------------------------------------------------
--
procedure check_per_typ_elig(p_eligy_prfl_id     in number,
                             p_business_group_id in number,
                             p_score_compute_mode in boolean default false,
                             p_profile_score_tab in out nocopy scoreTab,
                             p_effective_date    in date,
                             p_per_per_typ       in ben_person_object.
                                                    g_cache_typ_table) is
  --
  l_proc              varchar2(100) := g_package||'check_per_typ_elig';
  --
  l_inst_dets ben_elp_cache.g_cache_elpept_instor;
  l_inst_count number;
  l_insttorrw_num binary_integer;
  --
  l_rows_found        boolean := false;
  l_ok                boolean := false;
  l_crit_passed     boolean;
  l_score_tab       scoreTab;
  --
begin
  --
  hr_utility.set_location('Entering :'||l_proc,10);
  --
  ben_elp_cache.elpept_getcacdets
    (p_effective_date    => p_effective_date
    ,p_business_group_id => p_business_group_id
    ,p_eligy_prfl_id     => p_eligy_prfl_id
    ,p_inst_set          => l_inst_dets
    ,p_inst_count        => l_inst_count);
  --
  -- loop thru all the person type criteria, checking the excludes first.
  --
  -- If any of the excludes matches a person's person type, fail the criteria
  -- Once we get to the non-excludes, one of the person's person
  -- types MUST match one of them (if non-exludes exist).
  --
  if l_inst_count > 0 then
    --
    <<outer>>
    for l_insttorrw_num in l_inst_dets.first .. l_inst_dets.last loop
      --
      l_rows_found := true;
      --
      for l_count in p_per_per_typ.first..p_per_per_typ.last loop
        --
        -- using person_type_id to support user created person
        -- person types.
        --
        /* l_ok := nvl((nvl(p_per_per_typ(l_count).system_person_type,'-1')
                    = l_inst_dets(l_insttorrw_num).per_typ_cd),FALSE); */
        l_ok := nvl((nvl(p_per_per_typ(l_count).person_type_id,'-1')
                   = l_inst_dets(l_insttorrw_num).person_type_id),FALSE);
        --if l_ok is null then
        --  l_ok:=false;
        --end if;
        --
        if l_ok and l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
          --
          if p_score_compute_mode then
           if l_crit_passed is null then
              l_crit_passed := true;
           end if;
           write(l_score_tab,
                 l_inst_dets(l_insttorrw_num).eligy_prfl_id,
                 l_inst_dets(l_insttorrw_num).short_code,
                 l_inst_dets(l_insttorrw_num).pk_id,
                 nvl(l_inst_dets(l_insttorrw_num).criteria_score,
                 l_inst_dets(l_insttorrw_num).criteria_weight));
          else
           exit outer;
          end if;
          --
        elsif l_ok and l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
          --
          l_rows_found := true;
          l_ok := false;
          exit outer;
          --
        elsif (not l_ok) and l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
          --
          l_rows_found := true;
          l_ok := true;
          if p_score_compute_mode then
             write(l_score_tab,
                   l_inst_dets(l_insttorrw_num).eligy_prfl_id,
                   l_inst_dets(l_insttorrw_num).short_code,
                   l_inst_dets(l_insttorrw_num).pk_id,
                   nvl(l_inst_dets(l_insttorrw_num).criteria_score,
                   l_inst_dets(l_insttorrw_num).criteria_weight));
          end if;
          --exit outer;
          --
        elsif l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
          --
          l_rows_found := true;
          --
        end if;
        --
      end loop;
      --
    end loop outer;
    --
  end if;
  --
  if l_crit_passed is null
  then
     if l_rows_found and
        not l_ok then
       --
       g_inelg_rsn_cd := 'PTP';
       fnd_message.set_name('BEN','BEN_91677_PER_TYPE_PRFL_FAIL');
       hr_utility.set_location('Criteria Failed: '||l_proc,20);
       raise g_criteria_failed;
       --
     end if;
  end if;
  --
  if p_score_compute_mode
  then
     hr_utility.set_location('count '||l_score_tab.count,20);
     write(p_profile_score_tab,l_score_tab);
  end if;
  hr_utility.set_location('Leaving: '||l_proc,20);
  --
end check_per_typ_elig;
-- ----------------------------------------------------------
--  This procedure determines eligibility based on pay basis.
-- ----------------------------------------------------------
procedure check_py_bss_elig(p_eligy_prfl_id     in number,
                            p_business_group_id in number,
                            p_score_compute_mode in boolean default false,
                            p_profile_score_tab in out nocopy scoreTab,
                            p_effective_date    in date,
                            p_pay_basis_id      in number) is
  --
  l_proc             varchar2(100) := g_package||'check_py_bss_elig';
  l_inst_dets ben_elp_cache.g_cache_elpepb_instor;
  l_inst_count number;
  l_insttorrw_num binary_integer;
  l_ok               boolean := false;
  l_rows_found       boolean := false;
  l_crit_passed     boolean;
  l_score_tab       scoreTab;
  --
begin
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  -- Getting eligibility profile pay basis by eligibility profile
  --
  ben_elp_cache.elpepb_getcacdets
    (p_effective_date    => p_effective_date
    ,p_business_group_id => p_business_group_id
    ,p_eligy_prfl_id     => p_eligy_prfl_id
    ,p_inst_set          => l_inst_dets
    ,p_inst_count        => l_inst_count);
  --
  if l_inst_count > 0 then
    --
    for l_insttorrw_num in l_inst_dets.first .. l_inst_dets.last loop
      --
      l_ok := nvl((l_inst_dets(l_insttorrw_num).pay_basis_id
                 = nvl(p_pay_basis_id,-1)),FALSE);
      --if l_ok is null then
      --  l_ok:=false;
      --end if;
      if l_ok then
        hr_utility.set_location('ok',10);
      else
        hr_utility.set_location('not ok',10);
      end if;
      hr_utility.set_location('pay_basis_id='||p_pay_basis_id,10);
      --
      if l_ok and l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
        hr_utility.set_location(l_proc,10);
        --
        if p_score_compute_mode then
           if l_crit_passed is null then
              l_crit_passed := true;
           end if;
           write(l_score_tab,
                 l_inst_dets(l_insttorrw_num).eligy_prfl_id,
                 l_inst_dets(l_insttorrw_num).short_code,
                 l_inst_dets(l_insttorrw_num).pk_id,
                 nvl(l_inst_dets(l_insttorrw_num).criteria_score,
                 l_inst_dets(l_insttorrw_num).criteria_weight));
        else
           exit;
        end if;
        --
      elsif l_ok and l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
        hr_utility.set_location(l_proc,20);
        --
        l_rows_found := true;
        l_ok := false;
        exit;
        --
      elsif (not l_ok) and l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
        hr_utility.set_location(l_proc,30);
        --
        l_rows_found := true;
        l_ok := true;
        if p_score_compute_mode then
           write(l_score_tab,
                 l_inst_dets(l_insttorrw_num).eligy_prfl_id,
                 l_inst_dets(l_insttorrw_num).short_code,
                 l_inst_dets(l_insttorrw_num).pk_id,
                 nvl(l_inst_dets(l_insttorrw_num).criteria_score,
                 l_inst_dets(l_insttorrw_num).criteria_weight));
        end if;
        -- exit;
        --
      elsif l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
        hr_utility.set_location(l_proc,40);
        --
        l_rows_found := true;
        --
      end if;
        hr_utility.set_location(l_proc,50);
      --
    end loop;
        hr_utility.set_location(l_proc,60);
    --
  end if;
  --
        hr_utility.set_location(l_proc,70);
      if l_ok then
        hr_utility.set_location('ok',10);
      else
        hr_utility.set_location('not ok',10);
      end if;
      if l_rows_found then
        hr_utility.set_location('found',10);
      else
        hr_utility.set_location('not found',10);
      end if;
      if l_rows_found is null then
        hr_utility.set_location('found is null',10);
      end if;
      if l_ok is null then
        hr_utility.set_location('ok is null',10);
      end if;

  if l_crit_passed is null
  then
     if l_rows_found and
        not l_ok then
       --
           hr_utility.set_location(l_proc,80);
       g_inelg_rsn_cd := 'PBS';
       fnd_message.set_name('BEN','BEN_91678_PY_BSS_PRFL_FAIL');
       hr_utility.set_location('Criteria Failed: '||l_proc,20);
       raise g_criteria_failed;
       --
     end if;
  end if;
  --
  if p_score_compute_mode
  then
     hr_utility.set_location('count '||l_score_tab.count,20);
     write(p_profile_score_tab,l_score_tab);
  end if;
  hr_utility.set_location('Leaving: '||l_proc,20);
  --
end check_py_bss_elig;
-- --------------------------------------------------------
--  This procedure determines eligibility based on payroll.
-- --------------------------------------------------------
procedure check_pyrl_elig(p_eligy_prfl_id     in number,
                          p_business_group_id in number,
                          p_score_compute_mode in boolean default false,
                          p_profile_score_tab in out nocopy scoreTab,
                          p_effective_date    in date,
                          p_payroll_id        in number) is
  --
  l_proc        varchar2(100) := g_package||'check_pyrl_elig';
  l_inst_dets ben_elp_cache.g_cache_elpepy_instor;
  l_inst_count number;
  l_insttorrw_num binary_integer;
  l_ok          boolean := false;
  l_rows_found  boolean := false;
  l_crit_passed     boolean;
  l_score_tab       scoreTab;
  --
begin
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  hr_utility.set_location('payroll id : '||p_payroll_id,10);
  --
  -- Getting eligibility profile payroll by eligibility profile
  --
  ben_elp_cache.elpepy_getcacdets
    (p_effective_date    => p_effective_date
    ,p_business_group_id => p_business_group_id
    ,p_eligy_prfl_id     => p_eligy_prfl_id
    ,p_inst_set          => l_inst_dets
    ,p_inst_count        => l_inst_count
    );
  --
  hr_utility.set_location('Inst Count : '||l_inst_count,10);
  if l_inst_count > 0 then
    --
    for l_insttorrw_num in l_inst_dets.first .. l_inst_dets.last loop
      --
      l_ok := nvl((l_inst_dets(l_insttorrw_num).payroll_id = nvl(p_payroll_id,-1)),FALSE);
      --if l_ok is null then
      --  l_ok:=false;
      --end if;
      --
      if l_ok and l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
        --
        if p_score_compute_mode then
           if l_crit_passed is null then
              l_crit_passed := true;
           end if;
           write(l_score_tab,
                 l_inst_dets(l_insttorrw_num).eligy_prfl_id,
                 l_inst_dets(l_insttorrw_num).short_code,
                 l_inst_dets(l_insttorrw_num).pk_id,
                 nvl(l_inst_dets(l_insttorrw_num).criteria_score,
                 l_inst_dets(l_insttorrw_num).criteria_weight));
        else
           exit;
        end if;
        --
      elsif l_ok and l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := false;
        exit;
        --
      elsif (not l_ok) and l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := true;
        if p_score_compute_mode then
           write(l_score_tab,
                 l_inst_dets(l_insttorrw_num).eligy_prfl_id,
                 l_inst_dets(l_insttorrw_num).short_code,
                 l_inst_dets(l_insttorrw_num).pk_id,
                 nvl(l_inst_dets(l_insttorrw_num).criteria_score,
                 l_inst_dets(l_insttorrw_num).criteria_weight));
        end if;
        --exit;
        --
      elsif l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
        --
        l_rows_found := true;
        --
      end if;
      --
    end loop;
    --
  end if;
  --
  if l_crit_passed is null
  then
     if l_rows_found and
        not l_ok then
       --
       g_inelg_rsn_cd := 'PYR';
       fnd_message.set_name('BEN','BEN_91679_PYRL_PRFL_FAIL');
       hr_utility.set_location('Criteria Failed: '||l_proc,20);
       raise g_criteria_failed;
       --
     end if;
  end if;
  --
  if p_score_compute_mode
  then
     hr_utility.set_location('count '||l_score_tab.count,20);
     write(p_profile_score_tab,l_score_tab);
  end if;
  hr_utility.set_location('Leaving: '||l_proc,20);
  --
end check_pyrl_elig;
-- ---------------------------------------------------------------
--  This procedure determines eligibility based on benefits group.
-- ---------------------------------------------------------------
procedure check_benefits_grp_elig(p_eligy_prfl_id     in number,
                                  p_business_group_id in number,
                                  p_score_compute_mode in boolean default false,
                                  p_profile_score_tab in out nocopy scoreTab,
                                  p_effective_date    in date,
                                  p_benefit_group_id  in number) is
  --
  l_proc              varchar2(100) := g_package||'check_benefits_grp_elig';
  l_inst_dets ben_elp_cache.g_cache_elpebn_instor;
  l_inst_count number;
  l_insttorrw_num binary_integer;
  l_ok                boolean := false;
  l_rows_found        boolean := false;
  l_crit_passed     boolean;
  l_score_tab       scoreTab;
  --
begin
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  -- Getting eligibility profile benefits group by eligibility profile
  --
  ben_elp_cache.elpebn_getcacdets
    (p_effective_date    => p_effective_date
    ,p_business_group_id => p_business_group_id
    ,p_eligy_prfl_id     => p_eligy_prfl_id
    ,p_inst_set          => l_inst_dets
    ,p_inst_count        => l_inst_count
    );
  --
  if l_inst_count > 0 then
    --
    for l_insttorrw_num in l_inst_dets.first .. l_inst_dets.last loop
      --
      l_ok := nvl((l_inst_dets(l_insttorrw_num).benfts_grp_id
                = nvl(p_benefit_group_id,-1)),FALSE);
      --if l_ok is null then
      --  l_ok:=false;
      --end if;
      --
      if l_ok and l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
        --
        if p_score_compute_mode then
           if l_crit_passed is null then
              l_crit_passed := true;
           end if;
           write(l_score_tab,
                 l_inst_dets(l_insttorrw_num).eligy_prfl_id,
                 l_inst_dets(l_insttorrw_num).short_code,
                 l_inst_dets(l_insttorrw_num).pk_id,
                 nvl(l_inst_dets(l_insttorrw_num).criteria_score,
                 l_inst_dets(l_insttorrw_num).criteria_weight));
        else
           exit;
        end if;
        --
      elsif l_ok and l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := false;
        exit;
        --
      elsif (not l_ok) and l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := true;
        if p_score_compute_mode then
           write(l_score_tab,
                 l_inst_dets(l_insttorrw_num).eligy_prfl_id,
                 l_inst_dets(l_insttorrw_num).short_code,
                 l_inst_dets(l_insttorrw_num).pk_id,
                 nvl(l_inst_dets(l_insttorrw_num).criteria_score,
                 l_inst_dets(l_insttorrw_num).criteria_weight));
        end if;
        --exit;
        --
      elsif l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
        --
        l_rows_found := true;
        --
      end if;
      --
    end loop;
    --
  end if;
  --
  if l_crit_passed is null
  then
     if l_rows_found and
       not l_ok then
       --
       g_inelg_rsn_cd := 'BGR';
       fnd_message.set_name('BEN','BEN_91680_BENFTS_GRP_PRFL_FAIL');
       hr_utility.set_location('Criteria Failed: '||l_proc,20);
       raise g_criteria_failed;
       --
     end if;
  end if;
  --
  if p_score_compute_mode
  then
     hr_utility.set_location('count '||l_score_tab.count,20);
     write(p_profile_score_tab,l_score_tab);
  end if;
  hr_utility.set_location('Leaving: '||l_proc,20);
  --
end check_benefits_grp_elig;
-- --------------------------------------------------------------
--  This procedure determines eligibility based on work location.
-- --------------------------------------------------------------
procedure check_wk_location_elig(p_eligy_prfl_id     in number,
                                 p_business_group_id in number,
                                 p_score_compute_mode in boolean default false,
                                 p_profile_score_tab in out nocopy scoreTab,
                                 p_effective_date    in date,
                                 p_location_id       in number) is
  --
  l_proc              varchar2(100) := g_package||'check_wk_location_elig';
  l_inst_dets ben_elp_cache.g_cache_elpewl_instor;
  l_inst_count number;
  l_insttorrw_num binary_integer;
  l_ok                boolean := false;
  l_rows_found        boolean := false;
  l_crit_passed     boolean;
  l_score_tab       scoreTab;
  --
begin
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  -- Getting eligibility profile location by eligibility profile
  --
  ben_elp_cache.elpewl_getcacdets
    (p_effective_date    => p_effective_date
    ,p_business_group_id => p_business_group_id
    ,p_eligy_prfl_id     => p_eligy_prfl_id
    ,p_inst_set          => l_inst_dets
    ,p_inst_count        => l_inst_count);
  --
  if l_inst_count > 0 then
    --
    for l_insttorrw_num in l_inst_dets.first .. l_inst_dets.last loop
      --
      l_ok := nvl((l_inst_dets(l_insttorrw_num).location_id = nvl(p_location_id,-1)),FALSE);
      --if l_ok is null then
      --  l_ok:=false;
      --end if;
      --
      if l_ok and l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
        --
        if p_score_compute_mode then
           if l_crit_passed is null then
              l_crit_passed := true;
           end if;
           write(l_score_tab,
                 l_inst_dets(l_insttorrw_num).eligy_prfl_id,
                 l_inst_dets(l_insttorrw_num).short_code,
                 l_inst_dets(l_insttorrw_num).pk_id,
                 nvl(l_inst_dets(l_insttorrw_num).criteria_score,
                 l_inst_dets(l_insttorrw_num).criteria_weight));
        else
           exit;
        end if;
        --
      elsif l_ok and l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := false;
        exit;
        --
      elsif (not l_ok) and l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := true;
        if p_score_compute_mode then
           write(l_score_tab,
                 l_inst_dets(l_insttorrw_num).eligy_prfl_id,
                 l_inst_dets(l_insttorrw_num).short_code,
                 l_inst_dets(l_insttorrw_num).pk_id,
                 nvl(l_inst_dets(l_insttorrw_num).criteria_score,
                 l_inst_dets(l_insttorrw_num).criteria_weight));
        end if;
        --exit;
        --
      elsif l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
        --
        l_rows_found := true;
        --
      end if;
      --
    end loop;
    --
  end if;
  --
  if l_crit_passed is null
  then
     if l_rows_found and
        not l_ok then
       --
       g_inelg_rsn_cd := 'LOC';
       fnd_message.set_name('BEN','BEN_91681_WK_LOC_PRFL_FAIL');
       hr_utility.set_location('Criteria Failed: '||l_proc,20);
       raise g_criteria_failed;
       --
     end if;
  end if;
  --
  if p_score_compute_mode
  then
     hr_utility.set_location('count '||l_score_tab.count,20);
     write(p_profile_score_tab,l_score_tab);
  end if;
  hr_utility.set_location('Leaving: '||l_proc,20);
  --
end check_wk_location_elig;
-- -------------------------------------------------------------
--  This procedure determines eligibility based on people group.
-- -------------------------------------------------------------
procedure check_people_group_elig(p_eligy_prfl_id     in number,
                                  p_business_group_id in number,
                                  p_score_compute_mode in boolean default false,
                                  p_profile_score_tab in out nocopy scoreTab,
                                  p_effective_date    in date,
                                  p_people_group_id   in number) is
  --
  l_proc              varchar2(100) := g_package||'check_people_group_elig';
  l_inst_dets ben_elp_cache.g_cache_elpepg_instor;
  l_inst_count number;
  l_insttorrw_num binary_integer;
  l_ok                boolean := false;
  l_rows_found        boolean := false;
  --
  l_seg_ok            boolean ;
  l_crit_passed     boolean;
  l_score_tab       scoreTab;
  --
  -- added for elpro enhancement of flexfield in ppl grp profile
  --
  cursor c_ppl_grp is
  select ppg.people_group_id,
	  ppg.segment1 ,
	  ppg.segment2 ,
	  ppg.segment3 ,
	  ppg.segment4 ,
	  ppg.segment5 ,
	  ppg.segment6 ,
	  ppg.segment7 ,
	  ppg.segment8 ,
	  ppg.segment9 ,
	  ppg.segment10,
	  ppg.segment11,
	  ppg.segment12,
	  ppg.segment13,
	  ppg.segment14,
	  ppg.segment15,
	  ppg.segment16,
	  ppg.segment17,
	  ppg.segment18,
	  ppg.segment19,
	  ppg.segment20,
	  ppg.segment21,
	  ppg.segment22,
	  ppg.segment23,
	  ppg.segment24,
	  ppg.segment25,
	  ppg.segment26,
	  ppg.segment27,
	  ppg.segment28,
	  ppg.segment29,
	  ppg.segment30
  from pay_people_groups ppg
  where ppg.people_group_id =  p_people_group_id ;
  --
  l_ppl_grp_rec  c_ppl_grp%ROWTYPE ;
  --
begin
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  -- Getting eligibility profile organization by eligibility profile
  --
  ben_elp_cache.elpepg_getcacdets
    (p_effective_date    => p_effective_date
    ,p_business_group_id => p_business_group_id
    ,p_eligy_prfl_id     => p_eligy_prfl_id
    ,p_inst_set          => l_inst_dets
    ,p_inst_count        => l_inst_count);
  --
  if l_inst_count > 0 then
    --
    for l_insttorrw_num in l_inst_dets.first .. l_inst_dets.last loop
      --
      l_rows_found := true;
      --
      l_ok := (l_inst_dets(l_insttorrw_num).people_group_id = nvl(p_people_group_id,-1));
      --
      if l_ok and l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
        if p_score_compute_mode then
           if l_crit_passed is null then
              l_crit_passed := true;
           end if;
           write(l_score_tab,
                 l_inst_dets(l_insttorrw_num).eligy_prfl_id,
                 l_inst_dets(l_insttorrw_num).short_code,
                 l_inst_dets(l_insttorrw_num).pk_id,
                 nvl(l_inst_dets(l_insttorrw_num).criteria_score,
                 l_inst_dets(l_insttorrw_num).criteria_weight));
        else
           exit;
        end if;
        --
      elsif l_ok and l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
        --
        l_ok := false;
        exit;
        --
      elsif (not l_ok) and l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
        --
        l_ok := true;
        if p_score_compute_mode then
           write(l_score_tab,
                 l_inst_dets(l_insttorrw_num).eligy_prfl_id,
                 l_inst_dets(l_insttorrw_num).short_code,
                 l_inst_dets(l_insttorrw_num).pk_id,
                 nvl(l_inst_dets(l_insttorrw_num).criteria_score,
                 l_inst_dets(l_insttorrw_num).criteria_weight));
        end if;
        --
      end if;
      --
      -- Once id matching is over, check for segment matching if id is not null
      --
      if p_people_group_id is not null then
        --
        open c_ppl_grp ;
          fetch c_ppl_grp into l_ppl_grp_rec ;
        close c_ppl_grp ;
        --
        l_seg_ok := true;
        --
        /* bug 2786772: remove nvl for boolean variables as it gives unpredictable results */
--
        if l_seg_ok and l_inst_dets(l_insttorrw_num).segment1 is not null then
	  if l_inst_dets(l_insttorrw_num).segment1 = l_ppl_grp_rec.segment1  then
	    l_seg_ok :=  true ;
	  else
	    l_seg_ok :=  false;
	  end if;
        end if ;
        --
         if l_seg_ok and l_inst_dets(l_insttorrw_num).segment2 is not null then
            if l_inst_dets(l_insttorrw_num).segment2 = l_ppl_grp_rec.segment2  then
       	      l_seg_ok :=  true ;
       	    else
       	      l_seg_ok :=  false;
             end if;
         end if ;
        --
         if l_seg_ok and l_inst_dets(l_insttorrw_num).segment3 is not null then
       	   if l_inst_dets(l_insttorrw_num).segment3 = l_ppl_grp_rec.segment3  then
       	       l_seg_ok :=  true ;
       	   else
       	       l_seg_ok :=  false;
           end if;
         end if ;

        --
       if l_seg_ok and l_inst_dets(l_insttorrw_num).segment4 is not null then
       	  if l_inst_dets(l_insttorrw_num).segment4 = l_ppl_grp_rec.segment4  then
       	       l_seg_ok :=  true ;
       	  else
       	       l_seg_ok :=  false;
          end if;
       end if ;

       if l_seg_ok and l_inst_dets(l_insttorrw_num).segment5 is not null then
          if l_inst_dets(l_insttorrw_num).segment5 = l_ppl_grp_rec.segment5  then
       	       l_seg_ok :=  true ;
       	  else
       	       l_seg_ok :=  false;
          end if;
       end if ;


       if l_seg_ok and l_inst_dets(l_insttorrw_num).segment6 is not null then
	  if l_inst_dets(l_insttorrw_num).segment6 = l_ppl_grp_rec.segment6  then
       	       l_seg_ok :=  true ;
       	  else
       	       l_seg_ok :=  false;
          end if;
       end if ;

       if l_seg_ok and l_inst_dets(l_insttorrw_num).segment7 is not null then
       	  if l_inst_dets(l_insttorrw_num).segment7 = l_ppl_grp_rec.segment7  then
       	       l_seg_ok :=  true ;
       	  else
       	       l_seg_ok :=  false;
          end if;
       end if ;

       if l_seg_ok and l_inst_dets(l_insttorrw_num).segment8 is not null then
          if l_inst_dets(l_insttorrw_num).segment8 = l_ppl_grp_rec.segment8  then
       	       l_seg_ok :=  true ;
       	  else
       	       l_seg_ok :=  false;
          end if;
       end if ;


       if l_seg_ok and l_inst_dets(l_insttorrw_num).segment9 is not null then
	  if l_inst_dets(l_insttorrw_num).segment9 = l_ppl_grp_rec.segment9  then
       	       l_seg_ok :=  true ;
       	  else
       	       l_seg_ok :=  false;
          end if;
       end if ;

       if l_seg_ok and l_inst_dets(l_insttorrw_num).segment10 is not null then
	 if l_inst_dets(l_insttorrw_num).segment10 = l_ppl_grp_rec.segment10  then
       	       l_seg_ok :=  true ;
       	  else
       	       l_seg_ok :=  false;
	 end if;
       end if ;

       if l_seg_ok and l_inst_dets(l_insttorrw_num).segment11 is not null then
           if l_inst_dets(l_insttorrw_num).segment11 = l_ppl_grp_rec.segment11  then
       	       l_seg_ok :=  true ;
       	  else
       	       l_seg_ok :=  false;
           end if;
       end if ;


       if l_seg_ok and l_inst_dets(l_insttorrw_num).segment12 is not null then
       	  if l_inst_dets(l_insttorrw_num).segment12 = l_ppl_grp_rec.segment12  then
       	       l_seg_ok :=  true ;
       	  else
       	       l_seg_ok :=  false;
          end if;
       end if ;


       if l_seg_ok and l_inst_dets(l_insttorrw_num).segment13 is not null then
       	  if l_inst_dets(l_insttorrw_num).segment13 = l_ppl_grp_rec.segment13  then
       	       l_seg_ok :=  true ;
       	  else
       	       l_seg_ok :=  false;
          end if;
       end if ;

       if l_seg_ok and l_inst_dets(l_insttorrw_num).segment14 is not null then
          if l_inst_dets(l_insttorrw_num).segment14 = l_ppl_grp_rec.segment14  then
       	       l_seg_ok :=  true ;
       	  else
       	       l_seg_ok :=  false;
          end if;
       end if ;


       if l_seg_ok and l_inst_dets(l_insttorrw_num).segment15 is not null then
	  if l_inst_dets(l_insttorrw_num).segment15 = l_ppl_grp_rec.segment15  then
       	       l_seg_ok :=  true ;
       	  else
       	       l_seg_ok :=  false;
          end if;
       end if ;


       if l_seg_ok and l_inst_dets(l_insttorrw_num).segment16 is not null then
       	  if l_inst_dets(l_insttorrw_num).segment16 = l_ppl_grp_rec.segment16  then
       	       l_seg_ok :=  true ;
       	  else
       	       l_seg_ok :=  false;
          end if;
       end if ;

       if l_seg_ok and l_inst_dets(l_insttorrw_num).segment17 is not null then
          if l_inst_dets(l_insttorrw_num).segment17 = l_ppl_grp_rec.segment17  then
       	       l_seg_ok :=  true ;
       	  else
       	       l_seg_ok :=  false;
          end if;
       end if ;


       if l_seg_ok and l_inst_dets(l_insttorrw_num).segment18 is not null then
	  if l_inst_dets(l_insttorrw_num).segment18 = l_ppl_grp_rec.segment18  then
       	       l_seg_ok :=  true ;
       	  else
       	       l_seg_ok :=  false;
          end if;
       end if ;

       if l_seg_ok and l_inst_dets(l_insttorrw_num).segment19 is not null then
       	  if l_inst_dets(l_insttorrw_num).segment19 = l_ppl_grp_rec.segment19  then
       	       l_seg_ok :=  true ;
       	  else
       	       l_seg_ok :=  false;
          end if;
       end if ;

       if l_seg_ok and l_inst_dets(l_insttorrw_num).segment20 is not null then
          if l_inst_dets(l_insttorrw_num).segment20 = l_ppl_grp_rec.segment20  then
       	       l_seg_ok :=  true ;
       	  else
       	       l_seg_ok :=  false;
          end if;
       end if ;


       if l_seg_ok and l_inst_dets(l_insttorrw_num).segment21 is not null then
	  if l_inst_dets(l_insttorrw_num).segment21 = l_ppl_grp_rec.segment21  then
       	       l_seg_ok :=  true ;
       	  else
       	       l_seg_ok :=  false;
          end if;
       end if ;

       if l_seg_ok and l_inst_dets(l_insttorrw_num).segment22 is not null then
	 if l_inst_dets(l_insttorrw_num).segment22 = l_ppl_grp_rec.segment22  then
       	       l_seg_ok :=  true ;
       	  else
       	       l_seg_ok :=  false;
	 end if;
       end if ;

       if l_seg_ok and l_inst_dets(l_insttorrw_num).segment23 is not null then
           if l_inst_dets(l_insttorrw_num).segment23 = l_ppl_grp_rec.segment23  then
       	       l_seg_ok :=  true ;
       	  else
       	       l_seg_ok :=  false;
           end if;
       end if ;


       if l_seg_ok and l_inst_dets(l_insttorrw_num).segment24 is not null then
       	  if l_inst_dets(l_insttorrw_num).segment24 = l_ppl_grp_rec.segment24  then
       	       l_seg_ok :=  true ;
       	  else
       	       l_seg_ok :=  false;
          end if;
       end if ;


       if l_seg_ok and l_inst_dets(l_insttorrw_num).segment25 is not null then
	  if l_inst_dets(l_insttorrw_num).segment25 = l_ppl_grp_rec.segment25  then
       	       l_seg_ok :=  true ;
       	  else
       	       l_seg_ok :=  false;
          end if;
       end if ;

       if l_seg_ok and l_inst_dets(l_insttorrw_num).segment26 is not null then
       	  if l_inst_dets(l_insttorrw_num).segment26 = l_ppl_grp_rec.segment26  then
       	       l_seg_ok := true ;
       	  else
       	       l_seg_ok := false;
          end if;
       end if ;

       if l_seg_ok and l_inst_dets(l_insttorrw_num).segment27 is not null then
          if l_inst_dets(l_insttorrw_num).segment27 = l_ppl_grp_rec.segment27  then
       	       l_seg_ok := true ;
       	  else
       	       l_seg_ok := false;
          end if;
       end if ;


       if l_seg_ok and l_inst_dets(l_insttorrw_num).segment28 is not null then
	  if l_inst_dets(l_insttorrw_num).segment28 = l_ppl_grp_rec.segment28  then
       	       l_seg_ok := true ;
       	  else
       	       l_seg_ok := false;
          end if;
       end if ;

       if l_seg_ok and l_inst_dets(l_insttorrw_num).segment29 is not null then
	 if l_inst_dets(l_insttorrw_num).segment29 = l_ppl_grp_rec.segment29  then
       	       l_seg_ok := true ;
       	  else
       	       l_seg_ok := false;
	 end if;
       end if ;

       if l_seg_ok and l_inst_dets(l_insttorrw_num).segment30 is not null then
           if l_inst_dets(l_insttorrw_num).segment30 = l_ppl_grp_rec.segment30  then
       	       l_seg_ok := true ;
       	  else
       	       l_seg_ok :=  false;
           end if;
       end if ;

--

        if l_seg_ok and l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
          --
          l_ok := FALSE;
          exit;
          --
        elsif l_seg_ok and l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
          --
          l_ok := TRUE;
          if p_score_compute_mode then
             if l_crit_passed is null then
                l_crit_passed := true;
             end if;
             write(l_score_tab,
                   l_inst_dets(l_insttorrw_num).eligy_prfl_id,
                   l_inst_dets(l_insttorrw_num).short_code,
                   l_inst_dets(l_insttorrw_num).pk_id,
                   nvl(l_inst_dets(l_insttorrw_num).criteria_score,
                   l_inst_dets(l_insttorrw_num).criteria_weight));
          else
             exit;
          end if;
          --
        end if;
        --
      end if;
      --
    end loop;
    --
  end if;
  --
  if l_crit_passed is null
  then
     if l_rows_found and
       not l_ok then
       --
       g_inelg_rsn_cd := 'PEO';
       fnd_message.set_name('BEN','BEN_92224_PEO_GROUP_PRFL_FAIL');
       hr_utility.set_location('Criteria Failed: '||l_proc,20);
       raise g_criteria_failed;
       --
     end if;
  end if;
  --
  if p_score_compute_mode
  then
     hr_utility.set_location('count '||l_score_tab.count,20);
     write(p_profile_score_tab,l_score_tab);
  end if;
  hr_utility.set_location('Leaving: '||l_proc,20);
  --
end check_people_group_elig;
-- ---------------------------------------------------------
--  This procedure determines eligibility based on org unit.
-- ---------------------------------------------------------
procedure check_org_unit_elig(p_eligy_prfl_id     in number,
                              p_business_group_id in number,
                              p_score_compute_mode in boolean default false,
                              p_profile_score_tab in out nocopy scoreTab,
                              p_effective_date    in date,
                              p_organization_id   in number) is
  --
  l_proc              varchar2(100) := g_package||'check_org_unit_elig';
  l_inst_dets ben_elp_cache.g_cache_elpeou_instor;
  l_inst_count number;
  l_insttorrw_num binary_integer;
  l_ok                boolean := false;
  l_rows_found        boolean := false;
  l_crit_passed     boolean;
  l_score_tab       scoreTab;
  --
begin
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  -- Getting eligibility profile organization by eligibility profile
  --
  ben_elp_cache.elpeou_getcacdets
    (p_effective_date    => p_effective_date
    ,p_business_group_id => p_business_group_id
    ,p_eligy_prfl_id     => p_eligy_prfl_id
    ,p_inst_set          => l_inst_dets
    ,p_inst_count        => l_inst_count);
  --
  if l_inst_count > 0 then
    --
    for l_insttorrw_num in l_inst_dets.first .. l_inst_dets.last loop
      --
      l_ok := nvl((l_inst_dets(l_insttorrw_num).organization_id = nvl(p_organization_id,-1)),FALSE);
      --if l_ok is null then
      --  l_ok:=false;
      --end if;
      --
      if l_ok and l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
        --
        if p_score_compute_mode then
           if l_crit_passed is null then
              l_crit_passed := true;
           end if;
           write(l_score_tab,
                 l_inst_dets(l_insttorrw_num).eligy_prfl_id,
                 l_inst_dets(l_insttorrw_num).short_code,
                 l_inst_dets(l_insttorrw_num).pk_id,
                 nvl(l_inst_dets(l_insttorrw_num).criteria_score,
                 l_inst_dets(l_insttorrw_num).criteria_weight));
        else
           exit;
        end if;
        --
      elsif l_ok and l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := false;
        exit;
        --
      elsif (not l_ok) and l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := true;
        if p_score_compute_mode then
           write(l_score_tab,
                 l_inst_dets(l_insttorrw_num).eligy_prfl_id,
                 l_inst_dets(l_insttorrw_num).short_code,
                 l_inst_dets(l_insttorrw_num).pk_id,
                 nvl(l_inst_dets(l_insttorrw_num).criteria_score,
                 l_inst_dets(l_insttorrw_num).criteria_weight));
        end if;
        --exit;
        --
      elsif l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
        --
        l_rows_found := true;
        --
      end if;
      --
    end loop;
    --
  end if;
  --
  if l_crit_passed is null
  then
     if l_rows_found and
       not l_ok then
       --
       g_inelg_rsn_cd := 'ORG';
       fnd_message.set_name('BEN','BEN_91682_ORG_UNIT_PRFL_FAIL');
       hr_utility.set_location('Criteria Failed: '||l_proc,20);
       raise g_criteria_failed;
       --
     end if;
  end if;
  --
  if p_score_compute_mode
  then
     hr_utility.set_location('count '||l_score_tab.count,20);
     write(p_profile_score_tab,l_score_tab);
  end if;
  hr_utility.set_location('Leaving: '||l_proc,20);
  --
end check_org_unit_elig;
-- --------------------------------------------------------------
--  This procedure determines eligibility based on pay frequency.
-- --------------------------------------------------------------
procedure check_py_freq_elig(p_eligy_prfl_id        in number,
                             p_business_group_id    in number,
                             p_score_compute_mode in boolean default false,
                             p_profile_score_tab in out nocopy scoreTab,
                             p_effective_date       in date,
                             p_hourly_salaried_code in varchar2) is
  --
  l_proc              varchar2(100) := g_package||'check_py_freq_elig';
  l_inst_dets ben_elp_cache.g_cache_elpehs_instor;
  l_inst_count number;
  l_insttorrw_num binary_integer;
  l_ok                boolean := false;
  l_rows_found        boolean := false;
  l_crit_passed     boolean;
  l_score_tab       scoreTab;
  --
begin
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  -- Getting eligibility profile pay frequency by eligibility profile
  --
  ben_elp_cache.elpehs_getcacdets
    (p_effective_date    => p_effective_date
    ,p_business_group_id => p_business_group_id
    ,p_eligy_prfl_id     => p_eligy_prfl_id
    ,p_inst_set          => l_inst_dets
    ,p_inst_count        => l_inst_count
    );
  --
  if l_inst_count > 0 then
    --
    for l_insttorrw_num in l_inst_dets.first .. l_inst_dets.last loop
      --
      l_ok := nvl((nvl(p_hourly_salaried_code,'-1') = l_inst_dets(l_insttorrw_num).hrly_slrd_cd),FALSE);
      --if l_ok is null then
      --  l_ok:=false;
      --end if;
      --
      if l_ok and l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
        --
        if p_score_compute_mode then
           if l_crit_passed is null then
              l_crit_passed := true;
           end if;
           write(l_score_tab,
                 l_inst_dets(l_insttorrw_num).eligy_prfl_id,
                 l_inst_dets(l_insttorrw_num).short_code,
                 l_inst_dets(l_insttorrw_num).pk_id,
                 nvl(l_inst_dets(l_insttorrw_num).criteria_score,
                 l_inst_dets(l_insttorrw_num).criteria_weight));
        else
           exit;
        end if;
        --
      elsif l_ok and l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := false;
        exit;
        --
      elsif (not l_ok) and l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := true;
        if p_score_compute_mode then
           write(l_score_tab,
                 l_inst_dets(l_insttorrw_num).eligy_prfl_id,
                 l_inst_dets(l_insttorrw_num).short_code,
                 l_inst_dets(l_insttorrw_num).pk_id,
                 nvl(l_inst_dets(l_insttorrw_num).criteria_score,
                 l_inst_dets(l_insttorrw_num).criteria_weight));
        end if;
        --exit;
        --
      elsif l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
        --
        l_rows_found := true;
        --
      end if;
      --
    end loop;
    --
  end if;
  --
  if l_crit_passed is null
  then
     if l_rows_found and
       not l_ok then
       --
       g_inelg_rsn_cd := 'PFQ';
       fnd_message.set_name('BEN','BEN_91683_PY_FREQ_PRFL_FAIL');
       hr_utility.set_location('Criteria Failed: '||l_proc,20);
       raise g_criteria_failed;
       --
     end if;
  end if;
  --
  if p_score_compute_mode
  then
     hr_utility.set_location('count '||l_score_tab.count,20);
     write(p_profile_score_tab,l_score_tab);
  end if;
  hr_utility.set_location('Leaving: '||l_proc,20);
  --
end check_py_freq_elig;
-- ---------------------------------------------------------------
--  This procedure determines eligibility based on service area.
-- ---------------------------------------------------------------
procedure check_service_area_elig
  (p_eligy_prfl_id     in number
  ,p_person_id         in number
  ,p_business_group_id in number
  ,p_score_compute_mode in boolean default false
  ,p_profile_score_tab in out nocopy scoreTab
  ,p_postal_code       in varchar2 default null
  ,p_effective_date    in date
  )
is
  --
  l_proc              varchar2(100) := g_package||'check_service_area_elig';
/*
  l_inst_dets ben_elp_cache.g_cache_elpesa_instor;
*/
  l_rows_found        boolean := false;
  l_pad_rec           per_addresses%rowtype;
  l_svc_area_id       number(15);
  l_excld_flag        varchar2(1);
  l_from_value        VARCHAR2(90);
  l_to_value          VARCHAR2(90);
  l_pk_id             number;
  l_criteria_score    number;
  l_criteria_weight   number;
  l_crit_passed     boolean;
  l_score_tab       scoreTab;
  --
  cursor get_elig_svc(p_eligy_prfl_id in number) is
  select elig_svc.elig_svc_area_prte_id,
         elig_svc.excld_flag,
         elig_svc.svc_area_id,
         elig_svc.criteria_score,
         elig_svc.criteria_weight
  from   ben_elig_svc_area_prte_f elig_svc
  where  eligy_prfl_id = p_eligy_prfl_id
  and    p_effective_date between effective_start_date
         and effective_end_date;
  --
  cursor get_zip_ranges(p_svc_area_id in number
                       ,p_zip_code in VARCHAR2) is
  select zip.from_value, zip.to_value
  from  ben_pstl_zip_rng_f zip
  where zip.pstl_zip_rng_id in (
  select pstl_zip_rng_id
  from   ben_svc_area_pstl_zip_rng_f rng
  where  rng.SVC_AREA_ID = p_svc_area_id
  and    p_effective_date between rng.effective_start_date
         and rng.effective_end_date)
  and    length(p_zip_code) >= length(zip.from_value)
  and    (substr( nvl(p_zip_code,'-1'),1,length(zip.from_value))
  between zip.from_value and nvl(zip.to_value,p_zip_code)
  or     nvl(p_zip_code,'-1') = zip.from_value
  or     nvl(p_zip_code,'-1') = zip.to_value)
  and    p_effective_date between zip.effective_start_date
         and zip.effective_end_date;
begin
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  if p_postal_code is null then
     ben_person_object.get_object(p_person_id => p_person_id,
                                  p_rec       => l_pad_rec);
  else
     l_pad_rec.postal_code := p_postal_code;
  end if;
  --
  -- Getting eligibility profile service area range by eligibility profile
  --
  --
  open get_elig_svc(p_eligy_prfl_id);
  <<range_loop>>
  loop
    fetch get_elig_svc into l_pk_id,
                            l_excld_flag,
                            l_svc_area_id,
                            l_criteria_score,
                            l_criteria_weight;
    exit when get_elig_svc%notfound;
    l_rows_found := false;
    --
    ben_saz_cache.SAZRZR_Exists
      (p_svc_area_id => l_svc_area_id
      ,p_zip_code    => l_pad_rec.postal_code
      ,p_eff_date    => p_effective_date
      --
      ,p_exists      => l_rows_found
      );
    --
    IF (l_rows_found AND l_excld_flag = 'N') then
       --
       l_rows_found := TRUE;
       if p_score_compute_mode then
          if l_crit_passed is null then
             l_crit_passed := true;
          end if;
          write(l_score_tab,
                p_eligy_prfl_id,
                'ESA',
                l_pk_id,
                nvl(l_criteria_score, l_criteria_weight));
       else
          exit;
       end if;
       hr_utility.set_location(' l_rows_found := TRUE ' ,99);
       --
    ELSIF (NOT l_rows_found AND l_excld_flag = 'Y' ) then
       --
       l_rows_found := TRUE;
       if p_score_compute_mode then
          write(l_score_tab,
                p_eligy_prfl_id,
                'ESA',
                l_pk_id,
                nvl(l_criteria_score, l_criteria_weight));
       end if;
       hr_utility.set_location(' l_rows_found := TRUE ' ,99);
       --
    ELSIF ( l_rows_found AND l_excld_flag = 'Y' ) then
       --
       g_inelg_rsn_cd := 'SVC';
       l_rows_found := FALSE ;
       fnd_message.set_name('BEN','BEN_92225_SVC_AREA_PRFL_FAIL');
       exit;
       --
    END IF;
  --
  end loop range_loop;
  close get_elig_svc;
  --
  if l_crit_passed is null
  then
     if NOT l_rows_found then
        --
        hr_utility.set_location(' g_profile_failed ',99);
        RAISE g_criteria_failed ;
        --
     End if;
  End if;
  --
  if p_score_compute_mode
  then
     hr_utility.set_location('count '||l_score_tab.count,20);
     write(p_profile_score_tab,l_score_tab);
  end if;
  hr_utility.set_location('Leaving: '||l_proc,20);
  --
end check_service_area_elig;
--
-- ---------------------------------------------------------------
--  This procedure determines eligibility based on zip code range.
-- ---------------------------------------------------------------
--
procedure check_zip_code_rng_elig(p_eligy_prfl_id     in number,
                                  p_person_id         in number,
                                  p_score_compute_mode in boolean default false,
                                  p_profile_score_tab in out nocopy scoreTab,
                                  p_postal_code       in varchar2 default null,
                                  p_business_group_id in number,
                                  p_effective_date    in date) is
  --
  l_proc              varchar2(100) := g_package||'check_zip_code_rng_elig';
  l_ok                boolean := false;
  l_rows_found        boolean := false;
  l_pad_rec           per_addresses%rowtype;
  l_pstl_zip_rng_id   number(15);
  l_excld_flag        varchar2(1);
  l_from_value        VARCHAR2(90);
  l_to_value          VARCHAR2(90);
  l_pk_id             number;
  l_criteria_score    number;
  l_criteria_weight   number;
  l_crit_passed     boolean;
  l_score_tab       scoreTab;
  --
  cursor get_elig_zip(p_eligy_prfl_id in number) is
  select elig_zip.elig_pstl_cd_r_rng_prte_id,
         elig_zip.excld_flag,
         elig_zip.pstl_zip_rng_id,
         elig_zip.criteria_score,
         elig_zip.criteria_weight
  from   ben_elig_pstl_cd_r_rng_prte_f elig_zip
  where  elig_zip.eligy_prfl_id = p_eligy_prfl_id
  and    p_effective_date between effective_start_date
         and effective_end_date;
  --
  cursor get_zip_ranges(p_pstl_zip_rng_id in number
                       ,p_zip_code in VARCHAR2) is
  select zip.from_value, zip.to_value
  from  ben_pstl_zip_rng_f zip
  where zip.pstl_zip_rng_id = p_pstl_zip_rng_id
  and    length(p_zip_code) >= length(zip.from_value)
  and    (substr( nvl(p_zip_code,'-1'),1,length(zip.from_value))
  between zip.from_value and nvl(zip.to_value,p_zip_code)
  or     nvl(p_zip_code,'-1') = zip.from_value
  or     nvl(p_zip_code,'-1') = zip.to_value)
  and    p_effective_date between zip.effective_start_date
         and zip.effective_end_date;
begin
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  -- Getting eligibility profile zip code range by eligibility profile
  --
  --
  if p_postal_code is null then
     ben_person_object.get_object(p_person_id => p_person_id,
                                  p_rec       => l_pad_rec);
  else
     l_pad_rec.postal_code := p_postal_code;
  end if;
  --

  open get_elig_zip(p_eligy_prfl_id);
  <<range_loop>>
  loop
    fetch get_elig_zip into l_pk_id,
                            l_excld_flag,
                            l_pstl_zip_rng_id,
                            l_criteria_score,
                            l_criteria_weight;
    exit when get_elig_zip%notfound;
    l_ok         := false;
    l_rows_found := false;
    open get_zip_ranges(l_pstl_zip_rng_id,l_pad_rec.postal_code);
    <<zip_loop>>
      loop
      fetch get_zip_ranges into l_from_value,l_to_value;
      exit when get_zip_ranges%NOTFOUND;
      --
       hr_utility.set_location('person zip '||l_pad_rec.postal_code ,2219.3);
       hr_utility.set_location('from zip '||l_from_value ,2219.3);
       hr_utility.set_location('to zip '||l_to_value ,2219.3);
      --
    l_rows_found := true;
      exit;
    end loop zip_loop;
    --
  IF (l_pad_rec.postal_code is null)
  OR (l_rows_found   AND l_excld_flag = 'N') then
    --
    close get_zip_ranges;
    l_rows_found := TRUE;
    if p_score_compute_mode then
       if l_crit_passed is null then
          l_crit_passed := true;
       end if;
       write(l_score_tab,
             p_eligy_prfl_id,
             'EPZ',
             l_pk_id,
             nvl(l_criteria_score, l_criteria_weight));
    else
       exit;
    end if;
    --
  ELSIF  (not l_rows_found  AND l_excld_flag = 'Y' ) THEN
    --
    l_rows_found := TRUE;
    --
    if p_score_compute_mode then
       write(l_score_tab,
             p_eligy_prfl_id,
             'EPZ',
             l_pk_id,
             nvl(l_criteria_score, l_criteria_weight));
    end if;
  ELSIF ( l_rows_found AND l_excld_flag = 'Y') THEN
    --
    l_rows_found := FALSE ;
    exit ;
    --
  END IF;
  --
  CLOSE get_zip_ranges;

  end loop range_loop;
  close get_elig_zip;
  --
  if l_crit_passed is null
  then
     if not l_rows_found then
       --
       g_inelg_rsn_cd := 'ZIP';
       RAISE g_criteria_failed ;
       --
     end if;
  end if;
  if p_score_compute_mode
  then
     hr_utility.set_location('count '||l_score_tab.count,20);
     write(p_profile_score_tab,l_score_tab);
  end if;
  hr_utility.set_location('Leaving: '||l_proc,20);
  --
end check_zip_code_rng_elig;
-- ---------------------------------------------------------
--  This procedure determines elig based on scheduled hours.
-- ---------------------------------------------------------
--
-- Range of Scheduled hours enhancement
--
procedure check_sched_hrs_elig(p_eligy_prfl_id     in number,
                               p_business_group_id in number,
                               p_effective_date    in date,
                               p_lf_evt_ocrd_dt    in date,
                               p_person_id	   in number,
                               p_pgm_id		   in number,
                               p_pl_id		   in number,
                               p_oipl_id	   in number,
                               p_pl_typ_id	   in number,
                               p_opt_id		   in number,
                               p_comp_obj_mode     in boolean default true,
                               p_per_in_ler_id	   in number,
                               p_score_compute_mode in boolean default false,
                               p_profile_score_tab in out nocopy scoreTab,
                               p_ler_id		   in number,
                               p_jurisdiction_code in varchar2,
                               p_assignment_id	   in number,
                               p_organization_id   in number) is
  --
  l_proc              varchar2(100) := g_package||'check_sched_hrs_elig';
  l_ok                boolean := false;
  l_rows_found        boolean := false;
  --
  l_inst_dets ben_elp_cache.g_cache_elpesh_instor;
  l_inst_count number;
  l_insttorrw_num binary_integer;
  --
  l_sched_effective_date date;
  -- l_fonm_cvg_strt_dt date;
  l_output ff_exec.outputs_t;
  l_pgm_use_all_asnts_elig_flag varchar2(30);
  l_pl_use_all_asnts_elig_flag varchar2(30);
  l_use_all_asnts_elig_flag varchar2(30);
  l_pl_rec   ben_pl_f%rowtype;
  l_pgm_rec  ben_pgm_f%rowtype;
  --
  l_min_hours number;
  l_max_hours number;
  l_freq_cd varchar2(30);
  l_normal_hours number;
  l_crit_passed     boolean;
  l_score_tab       scoreTab;
  --
  --  Cursor to grab sched hrs requirement
  --
  cursor c_normal_hours(p_frequency varchar2,
  			p_use_all_asnts_elig_flag varchar2) is
    select sum(normal_hours)
    from per_all_assignments_f asg
    where asg.person_id = p_person_id
    and asg.business_group_id = p_business_group_id
    and (
    	  (nvl(p_use_all_asnts_elig_flag,'N') = 'N' and asg.assignment_id = p_assignment_id)
          or
          (nvl(p_use_all_asnts_elig_flag,'N') = 'Y')
        )
    and l_sched_effective_date between asg.effective_start_date
    	and asg.effective_end_date
    and frequency = p_frequency ;
  --
begin
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --

  -- Getting eligibility profile scheduled hours by eligibility profile
  --

  ben_elp_cache.elpesh_getcacdets
    (p_effective_date    => nvl(l_fonm_cvg_strt_dt, p_effective_date)
    ,p_business_group_id => p_business_group_id
    ,p_eligy_prfl_id     => p_eligy_prfl_id
    ,p_inst_set          => l_inst_dets
    ,p_inst_count        => l_inst_count);
  --
  if l_inst_count > 0 then
    --
    -- Retreive the Use All Assignments for Eligibility flag from plan level
    -- or from program level
    --
    l_use_all_asnts_elig_flag := 'N' ;
    if p_pl_id is not null then
      --
      ben_comp_object.get_object(p_pl_id => p_pl_id
                                ,p_rec   => l_pl_rec);
      l_pl_use_all_asnts_elig_flag := l_pl_rec.use_all_asnts_elig_flag;
      --
    end if;
    if p_pgm_id is not null then
      --
      ben_comp_object.get_object(p_pgm_id => p_pgm_id
                                ,p_rec    => l_pgm_rec);
      l_pgm_use_all_asnts_elig_flag := l_pgm_rec.pgm_use_all_asnts_elig_flag;
      --
    end if;
    --
    -- looping thru each of the criteria
    --
    for l_insttorrw_num in l_inst_dets.first .. l_inst_dets.last loop
      --
      -- Now, we should check if there is a Rule given so that
      -- the min, max and frequency codes are to retrieved from the rule.
      --
      l_sched_effective_date := nvl(l_fonm_cvg_strt_dt,
                                    nvl(p_lf_evt_ocrd_dt,p_effective_date));
      --
      l_min_hours := null;
      l_max_hours := null;
      l_freq_cd   := null;
      --
      hr_utility.set_location('criteria #' || l_insttorrw_num,20);
      --
      if l_inst_dets(l_insttorrw_num).schedd_hrs_rl is not null then
      	 l_output := benutils.formula
	                 (p_formula_id        => l_inst_dets(l_insttorrw_num).schedd_hrs_rl
		         ,p_effective_date    => nvl(p_lf_evt_ocrd_dt,p_effective_date)
		         ,p_business_group_id => p_business_group_id
		         ,p_assignment_id     => p_assignment_id
		         ,p_organization_id   => p_organization_id
		         ,p_pgm_id            => p_pgm_id
		         ,p_pl_id             => p_pl_id
		         ,p_pl_typ_id         => p_pl_typ_id
		         ,p_opt_id            => p_opt_id
		         ,p_ler_id            => p_ler_id
                         ,p_param1            => 'BEN_IV_RT_STRT_DT'
                         ,p_param1_value      => fnd_date.date_to_canonical(ben_manage_life_events.g_fonm_rt_strt_dt)
                         ,p_param2            => 'BEN_IV_CVG_STRT_DT'
                         ,p_param2_value      => fnd_date.date_to_canonical(l_fonm_cvg_strt_dt)

		         ,p_jurisdiction_code => p_jurisdiction_code);

      	 --
         for l_count in l_output.first..l_output.last loop
           --
           declare
           	invalid_param exception;
           begin

            --
             if l_output(l_count).name = 'MIN_HOURS' then
                 --
                 l_min_hours := to_number(l_output(l_count).value);
                 --
             elsif l_output(l_count).name = 'MAX_HOURS' then
                 --
                 l_max_hours := to_number(l_output(l_count).value);
                 --
             elsif l_output(l_count).name = 'FREQUENCY' then
                 --
                 l_freq_cd := l_output(l_count).value;
                 --
             else
               --
               -- Account for cases where formula returns an unknown
               -- variable name


               fnd_message.set_name('BEN','BEN_92310_FORMULA_RET_PARAM_');
               fnd_message.set_token('PROC',l_proc);
               fnd_message.set_token('FORMULA', l_inst_dets(l_insttorrw_num).schedd_hrs_rl);
               fnd_message.set_token('PARAMETER',l_output(l_count).name);
               -- Handling this particular exception seperately.
               raise invalid_param;
               --
             end if;
             --
             -- Code for type casting errors from formula return variables
             --
           exception
             --
             -- Code appended for bug# 2620550
             when invalid_param then
             	fnd_message.raise_error;
             when others then
               --
               fnd_message.set_name('BEN','BEN_92311_FORMULA_VAL_PARAM');
               fnd_message.set_token('PROC',l_proc);
               fnd_message.set_token('FORMULA', l_inst_dets(l_insttorrw_num).schedd_hrs_rl);
               fnd_message.set_token('PARAMETER',l_output(l_count).name);
               fnd_message.raise_error;
             --
	   end;
      	 end loop;
      	 --
      	 if l_min_hours is null and l_max_hours is null then
 	       fnd_message.set_name('BEN','BEN_92310_FORMULA_RET_PARAM_');
               fnd_message.set_token('PROC',l_proc);
               fnd_message.set_token('FORMULA', l_inst_dets(l_insttorrw_num).schedd_hrs_rl);
               fnd_message.set_token('PARAMETER','MIN_HOURS');
               fnd_message.raise_error;
         end if;

      	 if l_freq_cd is null then
 	       fnd_message.set_name('BEN','BEN_92310_FORMULA_RET_PARAM_');
               fnd_message.set_token('PROC',l_proc);
               fnd_message.set_token('FORMULA', l_inst_dets(l_insttorrw_num).schedd_hrs_rl);
               fnd_message.set_token('PARAMETER','FREQUENCY');
               fnd_message.raise_error;
      	 end if;
      else
      	   l_min_hours := l_inst_dets(l_insttorrw_num).hrs_num;
      	   l_max_hours := l_inst_dets(l_insttorrw_num).max_hrs_num;
           l_freq_cd   := l_inst_dets(l_insttorrw_num).freq_cd;
      end if;
      --
      hr_utility.set_location('l_min_hours' || l_min_hours,30);
      hr_utility.set_location('l_max_hours' || l_max_hours,30);
      hr_utility.set_location('l_freq_cd  ' || l_freq_cd  ,30);
      --
      -- Use the determination code given in the criteria in ELPRO to arrive
      -- at the effective date to be used for retrieving Normal Hours of the person.
      --
      if l_inst_dets(l_insttorrw_num).determination_cd is not null then
        --
        --
        ben_determine_date.main
         (p_date_cd           => l_inst_dets(l_insttorrw_num).determination_cd,
          p_formula_id        => l_inst_dets(l_insttorrw_num).determination_rl,
          p_per_in_ler_id     => p_per_in_ler_id,
          p_person_id         => p_person_id,
          p_pgm_id            => p_pgm_id,
          p_pl_id             => p_pl_id,
          p_oipl_id           => p_oipl_id,
          p_comp_obj_mode     => p_comp_obj_mode,
          p_business_group_id => p_business_group_id,
          p_effective_date    => nvl(p_lf_evt_ocrd_dt,p_effective_date),
          p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
          p_fonm_cvg_strt_dt  => ben_manage_life_events.g_fonm_cvg_strt_dt,
          p_fonm_rt_strt_dt  => ben_manage_life_events.g_fonm_rt_strt_dt,
          p_returned_date     => l_sched_effective_date);
        --
      end if;
      --
      -- Get the persons Normal Hours which matches the frequency, or the sum of
      -- Normal Hours from all assignments which have the matching frequency when
      -- Use All assignments for eligibility flag is checked.
      --
      if l_pgm_use_all_asnts_elig_flag = 'Y' or l_pl_use_all_asnts_elig_flag = 'Y' then
        --
        l_use_all_asnts_elig_flag := 'Y';
        --
      end if;
      --
      hr_utility.set_location('asg eff. date ' || l_sched_effective_date ,40);
      hr_utility.set_location('l_use_all_asnts_elig_flag ' || l_use_all_asnts_elig_flag ,40);
      --
      open c_normal_hours (l_freq_cd,l_use_all_asnts_elig_flag) ;
      fetch c_normal_hours into l_normal_hours ;
      if c_normal_hours%found then
        --
        hr_utility.set_location('l_normal_hours ' || l_normal_hours ,50);
        close c_normal_hours ;
        --
        -- Before comparing the normal hours with the range , we have to perform
        -- the rounding
        --
        if (l_normal_hours is not null
            and l_inst_dets(l_insttorrw_num).rounding_cd is not null) then
          --
          l_normal_hours := benutils.do_rounding
                              (p_rounding_cd    => l_inst_dets(l_insttorrw_num).rounding_cd
                              ,p_rounding_rl    => l_inst_dets(l_insttorrw_num).rounding_rl
                              ,p_value          => l_normal_hours
                              ,p_effective_date => nvl(p_lf_evt_ocrd_dt
           			                 ,p_effective_date));
          --
        end if;
        --
        -- Now compare the normal hours with min and max values
        --
        if l_normal_hours is null then
          --
          l_ok := false;
          --
        else
          --
          if l_normal_hours between nvl(l_min_hours,0) and nvl(l_max_hours,999999999999999) then
            --
            l_ok := true;
            --
          else
            --
            l_ok := false;
            --
          end if;
          --
        end if;
        --
      else
        --
        close c_normal_hours ;
        l_ok := false;
        --
      end if;


      -- *********** start code prior to range of scheduled hours enhancement *********
      -- l_ok := nvl((nvl(p_normal_hrs,-1) = l_inst_dets(l_insttorrw_num).hrs_num and
      --        nvl(p_frequency,'-1') = l_inst_dets(l_insttorrw_num).freq_cd),FALSE);
      --if l_ok is null then
      --  l_ok:=false;
      --end if;
      --
      -- ************ end of code prior to range of scheduled hours enhancement *******

      if l_ok and l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
        --
        if p_score_compute_mode then
           if l_crit_passed is null then
              l_crit_passed := true;
           end if;
           write(l_score_tab,
                 l_inst_dets(l_insttorrw_num).eligy_prfl_id,
                 l_inst_dets(l_insttorrw_num).short_code,
                 l_inst_dets(l_insttorrw_num).pk_id,
                 nvl(l_inst_dets(l_insttorrw_num).criteria_score,
                 l_inst_dets(l_insttorrw_num).criteria_weight));
        else
           exit;
        end if;
        --
      elsif l_ok and l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := false;
        exit;
        --
      elsif (not l_ok) and l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := true;
        if p_score_compute_mode then
           write(l_score_tab,
                 l_inst_dets(l_insttorrw_num).eligy_prfl_id,
                 l_inst_dets(l_insttorrw_num).short_code,
                 l_inst_dets(l_insttorrw_num).pk_id,
                 nvl(l_inst_dets(l_insttorrw_num).criteria_score,
                 l_inst_dets(l_insttorrw_num).criteria_weight));
        end if;
        --exit;
        --
      elsif l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
        --
        l_rows_found := true;
        --
      end if;
      --
    end loop;
    --
  end if;
  --
  if l_crit_passed is null
  then
     if l_rows_found and
        not l_ok then
       --
       g_inelg_rsn_cd := 'SHR';
       fnd_message.set_name('BEN','BEN_91685_SCHED_HRS_PRFL_FAIL');
       hr_utility.set_location('Criteria Failed: '||l_proc,60);
       raise g_criteria_failed;
       --
     end if;
  end if;
  --
  if p_score_compute_mode
  then
     hr_utility.set_location('count '||l_score_tab.count,20);
     write(p_profile_score_tab,l_score_tab);
  end if;
  hr_utility.set_location('Leaving: '||l_proc,70);
  --
end check_sched_hrs_elig;
-- --------------------------------------------------
--  This procedure det elig based on bargaining unit.
-- --------------------------------------------------
procedure check_brgng_unit_elig(p_eligy_prfl_id        in number,
                                p_business_group_id    in number,
                                p_score_compute_mode in boolean default false,
                                p_profile_score_tab in out nocopy scoreTab,
                                p_effective_date       in date,
                                p_bargaining_unit_code in varchar2) is
  --
  l_proc                 varchar2(100) := g_package||'check_brg_unit_elig';
  l_inst_dets ben_elp_cache.g_cache_elpebu_instor;
  l_inst_count number;
  l_insttorrw_num binary_integer;
  l_ok                   boolean := false;
  l_rows_found           boolean := false;
  l_crit_passed     boolean;
  l_score_tab       scoreTab;
  --
begin
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  -- Getting eligibility profile bargaining unit by eligibility profile
  --
  ben_elp_cache.elpebu_getcacdets
    (p_effective_date    => p_effective_date
    ,p_business_group_id => p_business_group_id
    ,p_eligy_prfl_id     => p_eligy_prfl_id
    ,p_inst_set          => l_inst_dets
    ,p_inst_count        => l_inst_count);
  --
  if l_inst_count > 0 then
    --
    for l_insttorrw_num in l_inst_dets.first .. l_inst_dets.last loop
      --
      l_ok := nvl((nvl(p_bargaining_unit_code,'-1') = l_inst_dets(l_insttorrw_num).brgng_unit_cd),FALSE);
      --if l_ok is null then
      --  l_ok:=false;
      --end if;
      --
      if l_ok and l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
        --
        if p_score_compute_mode then
           if l_crit_passed is null then
              l_crit_passed := true;
           end if;
           write(l_score_tab,
                 l_inst_dets(l_insttorrw_num).eligy_prfl_id,
                 l_inst_dets(l_insttorrw_num).short_code,
                 l_inst_dets(l_insttorrw_num).pk_id,
                 nvl(l_inst_dets(l_insttorrw_num).criteria_score,
                 l_inst_dets(l_insttorrw_num).criteria_weight));
        else
           exit;
        end if;
        --
      elsif l_ok and l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := false;
        exit;
        --
      elsif (not l_ok) and l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := true;
        if p_score_compute_mode then
           write(l_score_tab,
                 l_inst_dets(l_insttorrw_num).eligy_prfl_id,
                 l_inst_dets(l_insttorrw_num).short_code,
                 l_inst_dets(l_insttorrw_num).pk_id,
                 nvl(l_inst_dets(l_insttorrw_num).criteria_score,
                 l_inst_dets(l_insttorrw_num).criteria_weight));
        end if;
        -- exit;
        --
      elsif l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
        --
        l_rows_found := true;
        --
      end if;
      --
    end loop;
    --
  end if;
  --
  if l_crit_passed is null
  then
     if l_rows_found and
       not l_ok then
       --
       g_inelg_rsn_cd := 'BRG';
       fnd_message.set_name('BEN','BEN_91686_BRGNG_UNIT_PRFL_FAIL');
       hr_utility.set_location('Criteria Failed: '||l_proc,20);
       raise g_criteria_failed;
       --
     end if;
  end if;
  --
  if p_score_compute_mode
  then
     hr_utility.set_location('count '||l_score_tab.count,20);
     write(p_profile_score_tab,l_score_tab);
  end if;
  hr_utility.set_location('Leaving: '||l_proc,20);
  --
end check_brgng_unit_elig;
-- ----------------------------------------------------------
--  This procedure det elig based on labour union membership.
-- ----------------------------------------------------------
procedure check_lbr_union_elig(p_eligy_prfl_id     in number,
                               p_business_group_id in number,
                               p_score_compute_mode in boolean default false,
                               p_profile_score_tab in out nocopy scoreTab,
                               p_effective_date    in date,
                               p_labour_union_member_flag in varchar2) is
  --
  l_proc                     varchar2(100) := g_package||'check_lbr_union_elig';
  l_inst_dets ben_elp_cache.g_cache_elpelu_instor;
  l_inst_count number;
  l_insttorrw_num binary_integer;
  l_ok                       boolean := false;
  l_rows_found               boolean := false;
  l_crit_passed     boolean;
  l_score_tab       scoreTab;
  --
begin
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  -- Getting eligibility profile labour union membership by eligibility profile
  --
  ben_elp_cache.elpelu_getcacdets
    (p_effective_date    => p_effective_date
    ,p_business_group_id => p_business_group_id
    ,p_eligy_prfl_id     => p_eligy_prfl_id
    ,p_inst_set          => l_inst_dets
    ,p_inst_count        => l_inst_count);
  --
  if l_inst_count > 0 then
    --
    for l_insttorrw_num in l_inst_dets.first .. l_inst_dets.last loop
      --
      l_ok := nvl((l_inst_dets(l_insttorrw_num).lbr_mmbr_flag = nvl(p_labour_union_member_flag,'-1')),FALSE);
      --if l_ok is null then
      --  l_ok:=false;
      --end if;
      --
      if l_ok and l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
        --
        if p_score_compute_mode then
           if l_crit_passed is null then
              l_crit_passed := true;
           end if;
           write(l_score_tab,
                 l_inst_dets(l_insttorrw_num).eligy_prfl_id,
                 l_inst_dets(l_insttorrw_num).short_code,
                 l_inst_dets(l_insttorrw_num).pk_id,
                 nvl(l_inst_dets(l_insttorrw_num).criteria_score,
                 l_inst_dets(l_insttorrw_num).criteria_weight));
        else
           exit;
        end if;
        --
      elsif l_ok and l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := false;
        exit;
        --
      elsif (not l_ok) and l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := true;
        if p_score_compute_mode then
           write(l_score_tab,
                 l_inst_dets(l_insttorrw_num).eligy_prfl_id,
                 l_inst_dets(l_insttorrw_num).short_code,
                 l_inst_dets(l_insttorrw_num).pk_id,
                 nvl(l_inst_dets(l_insttorrw_num).criteria_score,
                 l_inst_dets(l_insttorrw_num).criteria_weight));
        end if;
        -- exit;
        --
      elsif l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
        --
        l_rows_found := true;
        --
      end if;
      --
    end loop;
    --
  end if;
  --
  if l_crit_passed is null
  then
     if l_rows_found and
       not l_ok then
       --
       g_inelg_rsn_cd := 'LBR';
       fnd_message.set_name('BEN','BEN_91687_LBR_MMBR_PRFL_FAIL');
       hr_utility.set_location('Criteria Failed: '||l_proc,20);
       raise g_criteria_failed;
       --
     end if;
  end if;
  --
  if p_score_compute_mode
  then
     hr_utility.set_location('count '||l_score_tab.count,20);
     write(p_profile_score_tab,l_score_tab);
  end if;
  hr_utility.set_location('Leaving: '||l_proc,20);
  --
end check_lbr_union_elig;
-- --------------------------------------------------
--  This procedure det elig based on employee status.
-- --------------------------------------------------
procedure check_ee_stat_elig(p_eligy_prfl_id             in number,
                             p_business_group_id         in number,
                             p_score_compute_mode in boolean default false,
                             p_profile_score_tab in out nocopy scoreTab,
                             p_effective_date            in date,
                             p_assignment_status_type_id in number) is
  --
  l_proc                      varchar2(100) := g_package||'check_ee_stat_elig';
  --
  l_inst_dets ben_elp_cache.g_cache_elpees_instor;
  l_inst_count number;
  l_insttorrw_num binary_integer;
  --
  l_ok                        boolean := false;
  l_rows_found                boolean := false;
  l_crit_passed     boolean;
  l_score_tab       scoreTab;
  --
begin
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  -- Getting eligibility profile assignment status type by eligibility profile
  --
  ben_elp_cache.elpees_getcacdets
    (p_effective_date    => p_effective_date
    ,p_business_group_id => p_business_group_id
    ,p_eligy_prfl_id     => p_eligy_prfl_id
    ,p_inst_set          => l_inst_dets
    ,p_inst_count        => l_inst_count);
  --
  if l_inst_count > 0 then
    --
    for l_insttorrw_num in l_inst_dets.first .. l_inst_dets.last loop
      --
      l_ok := nvl((l_inst_dets(l_insttorrw_num).assignment_status_type_id =
              nvl(p_assignment_status_type_id,-1)),FALSE);
      --if l_ok is null then
      --  l_ok:=false;
      --end if;
      --
      if l_ok and l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
        --
        if p_score_compute_mode then
           if l_crit_passed is null then
              l_crit_passed := true;
           end if;
           write(l_score_tab,
                 l_inst_dets(l_insttorrw_num).eligy_prfl_id,
                 l_inst_dets(l_insttorrw_num).short_code,
                 l_inst_dets(l_insttorrw_num).pk_id,
                 nvl(l_inst_dets(l_insttorrw_num).criteria_score,
                 l_inst_dets(l_insttorrw_num).criteria_weight));
        else
           exit;
        end if;
        --
      elsif l_ok and l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := false;
        exit;
        --
      elsif (not l_ok) and l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := true;
        if p_score_compute_mode then
           write(l_score_tab,
                 l_inst_dets(l_insttorrw_num).eligy_prfl_id,
                 l_inst_dets(l_insttorrw_num).short_code,
                 l_inst_dets(l_insttorrw_num).pk_id,
                 nvl(l_inst_dets(l_insttorrw_num).criteria_score,
                 l_inst_dets(l_insttorrw_num).criteria_weight));
        end if;
        -- exit;
        --
      elsif l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
        --
        l_rows_found := true;
        --
      end if;
      --
    end loop;
    --
  end if;
  --
  if l_crit_passed is null
  then
     if l_rows_found and
       not l_ok then
       --
       g_inelg_rsn_cd := 'STA';
       fnd_message.set_name('BEN','BEN_91688_EE_STAT_PRFL_FAIL');
       hr_utility.set_location('Criteria Failed: '||l_proc,20);
       raise g_criteria_failed;
       --
     end if;
  end if;
  --
  if p_score_compute_mode
  then
     hr_utility.set_location('count '||l_score_tab.count,20);
     write(p_profile_score_tab,l_score_tab);
  end if;
  hr_utility.set_location('Leaving: '||l_proc,20);
  --
end check_ee_stat_elig;
-- ---------------------------------------------------
--  This procedure det elig based on leave of absence.
-- ---------------------------------------------------
procedure check_loa_rsn_elig
         (p_eligy_prfl_id                in number,
          p_person_id                    in number,
          p_business_group_id            in number,
          p_score_compute_mode in boolean default false,
          p_profile_score_tab in out nocopy scoreTab,
          p_assignment_id                in number,
          p_assignment_type              in varchar2,
          p_abs_attd_type_id             in varchar2 default null,
          p_abs_attd_reason_id           in varchar2 default null,
          p_effective_date               in date) is
  --
  l_proc       varchar2(100) := g_package||'check_loa_rsn_elig';
  l_inst_dets ben_elp_cache.g_cache_elpelr_instor;
  l_inst_count number;
  l_insttorrw_num binary_integer;
  l_ok         boolean := false;
  l_ok1         boolean := false;
  l_ok2        boolean := false;
  l_rows_found boolean := false;
  l_dummy      varchar2(1);
  l_ass_rec    per_all_assignments_f%rowtype;
  l_aei_rec    per_assignment_extra_info%rowtype;
  l_crit_passed     boolean;
  l_score_tab       scoreTab;
  --
  cursor c1(p_absence_attendance_type_id in number,
            p_abs_attendance_reason_id   in number) is
    select null
    from   per_absence_attendances abs
    where  abs.person_id = p_person_id
    and    abs.absence_attendance_type_id = p_absence_attendance_type_id
    and    nvl(abs.abs_attendance_reason_id,-1) =
           nvl(p_abs_attendance_reason_id,nvl(abs.abs_attendance_reason_id,-1))
    and    p_effective_date
           between nvl(abs.date_start,p_effective_date)
           and     nvl(abs.date_end, p_effective_date)
    and    abs.business_group_id  = p_business_group_id;
  --
begin
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  -- Getting eligibility profile leave of absence reason by eligibility profile
  --
  ben_elp_cache.elpelr_getcacdets
    (p_effective_date    => p_effective_date
    ,p_business_group_id => p_business_group_id
    ,p_eligy_prfl_id     => p_eligy_prfl_id
    ,p_inst_set          => l_inst_dets
    ,p_inst_count        => l_inst_count);
  --
  if l_inst_count > 0 then
    --
    for l_insttorrw_num in l_inst_dets.first .. l_inst_dets.last loop
      --
      l_rows_found := true;
      --
      if p_abs_attd_type_id is not null then
         if p_abs_attd_type_id = l_inst_dets(l_insttorrw_num).absence_attendance_type_id and
            nvl(p_abs_attd_reason_id,-1) = nvl(l_inst_dets(l_insttorrw_num).abs_attendance_reason_id,-1) then
            if l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
              --
              l_ok := true;
              if p_score_compute_mode then
                 if l_crit_passed is null then
                    l_crit_passed := true;
                 end if;
                 write(l_score_tab,
                       l_inst_dets(l_insttorrw_num).eligy_prfl_id,
                       l_inst_dets(l_insttorrw_num).short_code,
                       l_inst_dets(l_insttorrw_num).pk_id,
                       nvl(l_inst_dets(l_insttorrw_num).criteria_score,
                       l_inst_dets(l_insttorrw_num).criteria_weight));
              else
                 exit;
              end if;
              --
            elsif l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
              --
              l_ok := false;
              exit;
              --
            end if;

         elsif l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
           --
           l_ok := false;
           --
         elsif l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
           --
           l_ok := true;
           if p_score_compute_mode then
              write(l_score_tab,
                    l_inst_dets(l_insttorrw_num).eligy_prfl_id,
                    l_inst_dets(l_insttorrw_num).short_code,
                    l_inst_dets(l_insttorrw_num).pk_id,
                    nvl(l_inst_dets(l_insttorrw_num).criteria_score,
                    l_inst_dets(l_insttorrw_num).criteria_weight));
           end if;
           --
         end if;

      else
         if p_assignment_type <> 'B' then
           --
           open c1(l_inst_dets(l_insttorrw_num).absence_attendance_type_id,
                   l_inst_dets(l_insttorrw_num).abs_attendance_reason_id);
             --
             fetch c1 into l_dummy;
             --
             if c1%found then
               --
               if l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
                 --
                 l_ok := true;
                 if p_score_compute_mode then
                    if l_crit_passed is null then
                       l_crit_passed := true;
                    end if;
                    write(l_score_tab,
                          l_inst_dets(l_insttorrw_num).eligy_prfl_id,
                          l_inst_dets(l_insttorrw_num).short_code,
                          l_inst_dets(l_insttorrw_num).pk_id,
                          nvl(l_inst_dets(l_insttorrw_num).criteria_score,
                          l_inst_dets(l_insttorrw_num).criteria_weight));
                 else
                    exit;
                 end if;
                 --
               elsif l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
                 --
                 l_ok := false;
                 exit;
                 --
               end if;
               --
             elsif l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
               --
               l_ok := false;
               --
             elsif l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
               --
               l_ok := true;
               if p_score_compute_mode then
                  write(l_score_tab,
                        l_inst_dets(l_insttorrw_num).eligy_prfl_id,
                        l_inst_dets(l_insttorrw_num).short_code,
                        l_inst_dets(l_insttorrw_num).pk_id,
                        nvl(l_inst_dets(l_insttorrw_num).criteria_score,
                        l_inst_dets(l_insttorrw_num).criteria_weight));
               end if;
               --
             end if;
             --
           close c1;
           --
         else
           --
           /* Start of Changes for WWBUG: 2141209                  */
           if p_assignment_id is not null then
               ben_person_object.get_object(p_assignment_id => p_assignment_id,
                                            p_rec           => l_aei_rec);
               --
               l_ok1 := nvl((nvl(l_aei_rec.aei_information11,'-1') =
                        l_inst_dets(l_insttorrw_num).absence_attendance_type_id),FALSE);
               l_ok2 := nvl((nvl(l_aei_rec.aei_information12,'-1') =
                        l_inst_dets(l_insttorrw_num).abs_attendance_reason_id),FALSE);
           else l_ok := false;
                exit;
           end if;
           /*  End of Changes for WWBUG: 2141209                   */
           --
           if l_ok1 and
             l_ok2 and
             l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
             --
             l_ok := true;
             if p_score_compute_mode then
                if l_crit_passed is null then
                   l_crit_passed := true;
                end if;
                write(l_score_tab,
                      l_inst_dets(l_insttorrw_num).eligy_prfl_id,
                      l_inst_dets(l_insttorrw_num).short_code,
                      l_inst_dets(l_insttorrw_num).pk_id,
                      nvl(l_inst_dets(l_insttorrw_num).criteria_score,
                      l_inst_dets(l_insttorrw_num).criteria_weight));
             else
                exit;
             end if;
             --
           elsif l_ok1 and
             l_ok2 and
             l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
             --
             l_ok := false;
             exit;
             --
           elsif (not (l_ok1 and l_ok2)) and
             l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
             --
             l_ok := true;
             if p_score_compute_mode then
                write(l_score_tab,
                      l_inst_dets(l_insttorrw_num).eligy_prfl_id,
                      l_inst_dets(l_insttorrw_num).short_code,
                      l_inst_dets(l_insttorrw_num).pk_id,
                      nvl(l_inst_dets(l_insttorrw_num).criteria_score,
                      l_inst_dets(l_insttorrw_num).criteria_weight));
             end if;
             -- exit ;
             --
           elsif l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
             --
             l_ok := false;
             --
           end if;
           --
         end if;
      end if;
      --
    end loop;
    --
  end if;
  --
  if l_crit_passed is null
  then
     if l_rows_found and
       not l_ok then
       --
       g_inelg_rsn_cd := 'LOA';
       fnd_message.set_name('BEN','BEN_91689_PER_LOA_PRFL_FAIL');
       hr_utility.set_location('Criteria Failed: '||l_proc,20);
       raise g_criteria_failed;
       --
     end if;
  end if;
  --
  if p_score_compute_mode
  then
     hr_utility.set_location('count '||l_score_tab.count,20);
     write(p_profile_score_tab,l_score_tab);
  end if;
  hr_utility.set_location('Leaving: '||l_proc,20);
  --
end check_loa_rsn_elig;
-- -----------------------------------------------
--  This procedure det elig based on legal entity.
-- -----------------------------------------------
procedure check_lgl_enty_elig(p_eligy_prfl_id     in number,
                              p_business_group_id in number,
                              p_score_compute_mode in boolean default false,
                              p_profile_score_tab in out nocopy scoreTab,
                              p_effective_date    in date,
                              p_gre_name          in varchar2) is
  --
  l_proc          varchar2(100) := g_package||'check_lgl_ent_elig';
  l_inst_dets ben_elp_cache.g_cache_elpeln_instor;
  l_inst_count number;
  l_insttorrw_num binary_integer;
  l_ok            boolean := false;
  l_rows_found    boolean := false;
  l_crit_passed     boolean;
  l_score_tab       scoreTab;
  --
begin
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  -- Getting eligibility profile legal entity by eligibility profile
  --
  ben_elp_cache.elpeln_getcacdets
    (p_effective_date    => p_effective_date
    ,p_business_group_id => p_business_group_id
    ,p_eligy_prfl_id     => p_eligy_prfl_id
    ,p_inst_set          => l_inst_dets
    ,p_inst_count        => l_inst_count);
  --
  hr_utility.set_location('Got Profiles : '||l_proc,10);
  --
  if l_inst_count > 0 then
    --
    hr_utility.set_location('In Loop : '||l_proc,10);
    --
    for l_insttorrw_num in l_inst_dets.first .. l_inst_dets.last loop
      --
      l_ok := nvl((l_inst_dets(l_insttorrw_num).name = nvl(p_gre_name,'-1')),FALSE);
      --if l_ok is null then
      --  l_ok:=false;
      --end if;
      --
      if l_ok and l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
        --
        if p_score_compute_mode then
           if l_crit_passed is null then
              l_crit_passed := true;
           end if;
           write(l_score_tab,
                 l_inst_dets(l_insttorrw_num).eligy_prfl_id,
                 l_inst_dets(l_insttorrw_num).short_code,
                 l_inst_dets(l_insttorrw_num).pk_id,
                 nvl(l_inst_dets(l_insttorrw_num).criteria_score,
                 l_inst_dets(l_insttorrw_num).criteria_weight));
        else
           exit;
        end if;
        --
      elsif l_ok and l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := false;
        exit;
        --
      elsif (not l_ok) and l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := true;
        if p_score_compute_mode then
           write(l_score_tab,
                 l_inst_dets(l_insttorrw_num).eligy_prfl_id,
                 l_inst_dets(l_insttorrw_num).short_code,
                 l_inst_dets(l_insttorrw_num).pk_id,
                 nvl(l_inst_dets(l_insttorrw_num).criteria_score,
                 l_inst_dets(l_insttorrw_num).criteria_weight));
        end if;
        -- exit ;
        --
      elsif l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
        --
        l_rows_found := true;
        --
      end if;
      --
    end loop;
    --
  end if;
  --
  if l_crit_passed is null
  then
     if l_rows_found and
       not l_ok then
       --
       g_inelg_rsn_cd := 'LGL';
       fnd_message.set_name('BEN','BEN_91690_LGL_ENTY_PRFL_FAIL');
       hr_utility.set_location('Criteria Failed: '||l_proc,20);
       raise g_criteria_failed;
       --
     end if;
  end if;
  --
  if p_score_compute_mode
  then
     hr_utility.set_location('count '||l_score_tab.count,20);
     write(p_profile_score_tab,l_score_tab);
  end if;
  hr_utility.set_location('Copying gre cd : ',10);
  --
  hr_utility.set_location('Leaving : '||l_proc,10);
  --
end check_lgl_enty_elig;
-- ----------------------------------------------------------------
--  This procedure det elig based on participation in another plan.
-- ----------------------------------------------------------------
procedure check_prtt_in_anthr_pl_elig(p_eligy_prfl_id         in number,
                                      p_person_id             in number,
                                      p_business_group_id     in number,
                                      p_effective_date        in date,
                                      p_lf_evt_ocrd_dt        in date) is
  --
  l_proc                  varchar2(100) := g_package||
                                           'check_prtt_in_anthr_pl_elig';
  l_inst_dets ben_elp_cache.g_cache_elpepp_instor;
  l_inst_count number;
  l_insttorrw_num binary_integer;
  l_ok                    boolean := false;
  l_rows_found            boolean := false;
  l_dummy                 varchar2(1);
  l_pl_id                 ben_elig_prtt_anthr_pl_prte_f.pl_id%type;
  l_excld_flag            ben_elig_prtt_anthr_pl_prte_f.excld_flag%type;
  l_enrlt_pl_id           ben_prtt_enrt_rslt_f.pl_id%type;
  l_sspndd_flag           ben_prtt_enrt_rslt_f.sspndd_flag%type;
  l_prtt_is_cvrd_flag     ben_prtt_enrt_rslt_f.prtt_is_cvrd_flag%type;
  --
  cursor c1(p_pl_id in number) is
    select null
    from ben_elig_per_f epo,
         ben_per_in_ler pil
    where epo.person_id = p_person_id
    and epo.pl_id = p_pl_id
    and p_effective_date
    between epo.effective_start_date
    and     epo.effective_end_date
    and epo.business_group_id  = p_business_group_id
    and pil.per_in_ler_id(+)=epo.per_in_ler_id
    and epo.elig_flag = 'Y'                    /* 8872046 */
   -- and pil.business_group_id(+)=epo.business_group_id
    and (   pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT') -- found row condition
        or pil.per_in_ler_stat_cd is null                  -- outer join condition
        )
;

begin
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  -- Getting eligibility profile other plan by eligibility profile
  --
  ben_elp_cache.elpepp_getcacdets
    (p_effective_date    => nvl(p_lf_evt_ocrd_dt,p_effective_date)
    ,p_business_group_id => p_business_group_id
    ,p_eligy_prfl_id     => p_eligy_prfl_id
    ,p_inst_set          => l_inst_dets
    ,p_inst_count        => l_inst_count
    );
  --
  if l_inst_count > 0 then
    --
    for l_insttorrw_num in l_inst_dets.first .. l_inst_dets.last loop
      --
      l_rows_found := true;
      --
      open c1(l_inst_dets(l_insttorrw_num).pl_id);
      fetch c1 into l_dummy;
      if c1%found then
        --
        close c1;
        --
        if l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
          l_ok := true;
          exit;
        end if;
        --
        if l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
          l_ok := false;
          exit;
        end if;
        --
      else
        --
        close c1;
        --
        if l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
          l_ok := true;
          -- exit;
        end if;
      end if;
        --
    end loop;
      --
  end if;
  --
  if l_rows_found and
    not l_ok then
    --
    g_inelg_rsn_cd := 'PLN';
    fnd_message.set_name('BEN','BEN_91691_PRTN_PL_PRFL_FAIL');
    hr_utility.set_location('Criteria Failed: '||l_proc,20);
    raise g_criteria_failed;
    --
  end if;
  --
  hr_utility.set_location('Leaving: '||l_proc,20);
  --
end check_prtt_in_anthr_pl_elig;
-- ---------------------------------------------------------------
--  This procedure det elig based on full time/part time category.
-- ---------------------------------------------------------------
procedure check_fl_tm_pt_elig(p_eligy_prfl_id       in number,
                              p_business_group_id   in number,
                              p_score_compute_mode in boolean default false,
                              p_profile_score_tab in out nocopy scoreTab,
                              p_effective_date      in date,
                              p_employment_category in varchar2) is
  --
  l_proc                varchar2(100) := g_package||'check_fl_tm_pt_elig';
  l_inst_dets ben_elp_cache.g_cache_elpefp_instor;
  l_inst_count number;
  l_insttorrw_num binary_integer;
  l_rows_found          boolean := false;
  l_ok                  boolean := false;
  l_crit_passed     boolean;
  l_score_tab       scoreTab;
  --
begin
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  -- Getting eligibility profile full/part time by eligibility profile
  --
  ben_elp_cache.elpefp_getcacdets
    (p_effective_date    => p_effective_date
    ,p_business_group_id => p_business_group_id
    ,p_eligy_prfl_id     => p_eligy_prfl_id
    ,p_inst_set          => l_inst_dets
    ,p_inst_count        => l_inst_count);
  --
  if l_inst_count > 0 then
    --
    for l_insttorrw_num in l_inst_dets.first .. l_inst_dets.last loop
      --
      l_ok := nvl((nvl(p_employment_category,'-1') =
              l_inst_dets(l_insttorrw_num).fl_tm_pt_tm_cd),FALSE);
      --if l_ok is null then
      --  l_ok:=false;
      --end if;
      --
      if l_ok and l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
        --
        if p_score_compute_mode then
           if l_crit_passed is null then
              l_crit_passed := true;
           end if;
           write(l_score_tab,
                 l_inst_dets(l_insttorrw_num).eligy_prfl_id,
                 l_inst_dets(l_insttorrw_num).short_code,
                 l_inst_dets(l_insttorrw_num).pk_id,
                 nvl(l_inst_dets(l_insttorrw_num).criteria_score,
                 l_inst_dets(l_insttorrw_num).criteria_weight));
        else
           exit;
        end if;
        --
      elsif l_ok and l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := false;
        exit;
        --
      elsif (not l_ok) and l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := true;
        if p_score_compute_mode then
           write(l_score_tab,
                 l_inst_dets(l_insttorrw_num).eligy_prfl_id,
                 l_inst_dets(l_insttorrw_num).short_code,
                 l_inst_dets(l_insttorrw_num).pk_id,
                 nvl(l_inst_dets(l_insttorrw_num).criteria_score,
                 l_inst_dets(l_insttorrw_num).criteria_weight));
        end if;
        -- exit;
        --
      elsif l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
        --
        l_rows_found := true;
        --
      end if;
      --
    end loop;
    --
  end if;
  --
  if l_crit_passed is null
  then
     if l_rows_found and
       not l_ok then
       --
       -- There were non-excludes and we didn't match any
       --
       g_inelg_rsn_cd := 'FPT';
       fnd_message.set_name('BEN','BEN_91692_FL_PT_PRFL_FAIL');
       hr_utility.set_location('Criteria Failed: '||l_proc,20);
       raise g_criteria_failed;
       --
     end if;
  end if;
  --
  if p_score_compute_mode
  then
     hr_utility.set_location('count '||l_score_tab.count,20);
     write(p_profile_score_tab,l_score_tab);
  end if;
  hr_utility.set_location('Leaving: '||l_proc,20);
  --
end check_fl_tm_pt_elig;
-- ---------------------------------------------------------------
--  This procedure det elig based on persons benefit balance.
-- ---------------------------------------------------------------
procedure check_person_ben_bal(p_eligy_prfl_id     in number,
                               p_person_id         in number,
                               p_business_group_id in number,
                               p_effective_date    in date,
                               p_per_comp_val      in number,
                               p_eval_typ          in varchar2,
                               p_comp_obj_mode     in boolean,
                               p_lf_evt_ocrd_dt    in date,
                               p_per_in_ler_id     in number default null,
                               p_score_compute_mode in boolean default false,
                               p_profile_score_tab in out nocopy scoreTab,
                               p_pl_id             in number default null,
                               p_pgm_id            in number default null,
                               p_oipl_id           in number default null,
                               p_plip_id           in number default null,
                               p_opt_id            in number default null) is
  --
  l_proc             varchar2(100):=g_package||'check_person_ben_bal';
  l_inst_dets ben_elp_cache.g_cache_elpecl_instor;
  l_inst_count number;
  l_insttorrw_num binary_integer;
  l_ok               boolean := false;
  l_rows_found       boolean := false;
  l_per_comp_val     number := p_per_comp_val;
  l_crit_passed     boolean;
  l_score_tab       scoreTab;
  --
begin
  --
  hr_utility.set_location('Entering: '||l_proc, 10);
  --
  -- Getting eligibility profile compensation level by eligibility profile
  --
  ben_elp_cache.elpecl_getcacdets
    (p_effective_date    => nvl(l_fonm_cvg_strt_dt,p_effective_date)
    ,p_business_group_id => p_business_group_id
    ,p_comp_src_cd       => 'BNFTBALTYP'
    ,p_eligy_prfl_id     => p_eligy_prfl_id
    ,p_inst_set          => l_inst_dets
    ,p_inst_count        => l_inst_count);
  --
  if l_inst_count > 0 then
    --
    for l_insttorrw_num in l_inst_dets.first .. l_inst_dets.last loop
      --
      --if p_per_comp_val is null then
        --
        --fnd_message.set_name('BEN','BEN_91767_DERIVABLE_NO_EXIST');
        --raise ben_manage_life_events.g_record_error;
        --
      --end if;
      --
      if not p_comp_obj_mode or
         p_eval_typ <> 'E' then
        --
        ben_derive_factors.determine_compensation
        (p_person_id            => p_person_id
        ,p_comp_lvl_fctr_id     => l_inst_dets(l_insttorrw_num).comp_lvl_fctr_id
        ,p_pgm_id               => p_pgm_id
        ,p_pl_id                => p_pl_id
        ,p_oipl_id              => p_oipl_id
        ,p_per_in_ler_id        => p_per_in_ler_id
        ,p_comp_obj_mode        => p_comp_obj_mode
        ,p_perform_rounding_flg => true
        ,p_effective_date       => p_effective_date
        ,p_lf_evt_ocrd_dt       => p_lf_evt_ocrd_dt
        ,p_business_group_id    => p_business_group_id
        ,p_value                => l_per_comp_val
        ,p_fonm_cvg_strt_dt     => l_fonm_cvg_strt_dt );
      --
      end if;
      l_ok := is_ok(l_per_comp_val
                   ,l_inst_dets(l_insttorrw_num).mx_comp_val
                   ,l_inst_dets(l_insttorrw_num).mn_comp_val
                   ,l_inst_dets(l_insttorrw_num).no_mx_comp_flag
                   ,l_inst_dets(l_insttorrw_num).no_mn_comp_flag
                   );
      --if l_ok is null then
      --  l_ok:=false;
      --end if;
      --
      if l_per_comp_val is null then
        --
        l_ok := false;
        --
      end if;
      --
      if l_ok and l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
        --
        if p_score_compute_mode then
           if l_crit_passed is null then
              l_crit_passed := true;
           end if;
           write(l_score_tab,
                 l_inst_dets(l_insttorrw_num).eligy_prfl_id,
                 l_inst_dets(l_insttorrw_num).short_code,
                 l_inst_dets(l_insttorrw_num).pk_id,
                 ( l_per_comp_val * nvl(l_inst_dets(l_insttorrw_num).criteria_weight, 0) ) +
                 nvl(l_inst_dets(l_insttorrw_num).criteria_score, 0)    /* Bug 4429071 */
                 );
        else
           exit;
        end if;
        --
      elsif l_ok and l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := false;
        exit;
        --
      elsif (not l_ok) and l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := true;
        if p_score_compute_mode then
           write(l_score_tab,
                 l_inst_dets(l_insttorrw_num).eligy_prfl_id,
                 l_inst_dets(l_insttorrw_num).short_code,
                 l_inst_dets(l_insttorrw_num).pk_id,
                 ( l_per_comp_val * nvl(l_inst_dets(l_insttorrw_num).criteria_weight, 0) ) +
                 nvl(l_inst_dets(l_insttorrw_num).criteria_score, 0)    /* Bug 4429071 */
                 );
        end if;
        -- exit;
        --
      elsif l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
        --
        l_rows_found := true;
        --
      end if;
      --
    end loop;
    --
  end if;
  --
  if l_crit_passed is null
  then
     if l_rows_found and
       not l_ok then
       --
       g_inelg_rsn_cd := 'CMP';
       fnd_message.set_name('BEN','BEN_91672_COMP_LVL_PRFL_FAIL');
       hr_utility.set_location('Criteria Failed: '||l_proc,20);
       raise g_criteria_failed;
       --
     end if;
  end if;
  --
  if p_score_compute_mode
  then
     hr_utility.set_location('count '||l_score_tab.count,20);
     write(p_profile_score_tab,l_score_tab);
  end if;
  hr_utility.set_location('Leaving :'||l_proc,20);
  --
end check_person_ben_bal;
--
procedure check_asnt_set
        (p_eligy_prfl_id     in number,
         p_business_group_id in number,
         p_score_compute_mode in boolean default false,
         p_profile_score_tab in out nocopy scoreTab,
         p_person_id         in number,
         p_effective_date    in date) is
  --
  l_proc          varchar2(100):=g_package||'check_asnt_set';
  l_inst_dets     ben_elp_cache.g_cache_elpean_instor;
  l_inst_count    number;
  l_insttorrw_num binary_integer;
  l_ok            boolean := false;
  l_rows_found    boolean := false;
  l_ass_rec       per_all_assignments_f%rowtype;
  l_outputs       ff_exec.outputs_t;
  l_include_flag  varchar2(80);
  l_crit_passed     boolean;
  l_score_tab       scoreTab;
  --
begin
  --
  hr_utility.set_location('Entering: '||l_proc, 10);
  --
  -- Getting eligibility profile compensation level by eligibility profile
  --
  ben_elp_cache.elpean_getcacdets
    (p_effective_date    => p_effective_date
    ,p_business_group_id => p_business_group_id
    ,p_eligy_prfl_id     => p_eligy_prfl_id
    ,p_inst_set          => l_inst_dets
    ,p_inst_count        => l_inst_count);
  --
  if l_inst_count > 0 then
    --
    ben_person_object.get_object(p_person_id => p_person_id,
                                 p_rec       => l_ass_rec);
    --
    for l_count in l_inst_dets.first .. l_inst_dets.last loop
      --
      -- Error if someone hasn't built the formula as this will
      -- cause an error. In this case kill the run.
      --
      if l_inst_dets(l_count).formula_id is null then
        --
        fnd_message.set_name('BEN','BEN_92460_ASS_SET_FORMULA');
        fnd_message.set_token('PROC',l_proc);
        fnd_message.set_token('ELIGY_PRFL_ID',to_char(p_eligy_prfl_id));
        fnd_message.raise_error;
        --
      end if;
      --
      l_outputs := benutils.formula
                      (p_formula_id     => l_inst_dets(l_count).formula_id,
                       p_assignment_id  => l_ass_rec.assignment_id,
                       p_effective_date => p_effective_date,
        p_param1            => 'BEN_IV_RT_STRT_DT',
        p_param1_value      => fnd_date.date_to_canonical(ben_manage_life_events.g_fonm_rt_strt_dt),
        p_param2            => 'BEN_IV_CVG_STRT_DT',
        p_param2_value      => fnd_date.date_to_canonical(l_fonm_cvg_strt_dt)
        );
      --
      begin
        --
        if l_outputs(l_outputs.first).name = 'INCLUDE_FLAG' then
          --
          l_include_flag := l_outputs(l_outputs.first).value;
          --
        else
          --
          -- Account for cases where formula returns an unknown
          -- variable name
          --
          fnd_message.set_name('BEN','BEN_92310_FORMULA_RET_PARAM_');
          fnd_message.set_token('PROC',l_proc);
          fnd_message.set_token('FORMULA',l_inst_dets(l_count).formula_id);
          fnd_message.set_token('PARAMETER',l_outputs(l_outputs.first).name);
          fnd_message.raise_error;
          --
        end if;
        --
        -- Code for type casting errors from formula return variables
        --
      exception
        --
        when others then
          --
          fnd_message.set_name('BEN','BEN_92311_FORMULA_VAL_PARAM');
          fnd_message.set_token('PROC',l_proc);
          fnd_message.set_token('FORMULA',l_inst_dets(l_count).formula_id);
          fnd_message.set_token('PARAMETER',l_outputs(l_outputs.first).name);
          fnd_message.raise_error;
          --
      end;
      --
      hr_utility.set_location('Include Flag '||l_include_flag,10);
      --
      l_ok := nvl((l_include_flag = 'Y'),FALSE);
      --if l_ok is null then
      --  l_ok:=false;
      --end if;
      --
      if l_ok and l_inst_dets(l_count).excld_flag = 'N' then
        --
        if p_score_compute_mode then
           if l_crit_passed is null then
              l_crit_passed := true;
           end if;
           write(l_score_tab,
                 l_inst_dets(l_count).eligy_prfl_id,
                 l_inst_dets(l_count).short_code,
                 l_inst_dets(l_count).pk_id,
                 nvl(l_inst_dets(l_count).criteria_score,
                 l_inst_dets(l_count).criteria_weight));
        else
           exit;
        end if;
        --
      elsif l_ok and l_inst_dets(l_count).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := false;
        exit;
        --
      elsif (not l_ok) and l_inst_dets(l_count).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := true;
        if p_score_compute_mode then
           write(l_score_tab,
                 l_inst_dets(l_count).eligy_prfl_id,
                 l_inst_dets(l_count).short_code,
                 l_inst_dets(l_count).pk_id,
                 nvl(l_inst_dets(l_count).criteria_score,
                 l_inst_dets(l_count).criteria_weight));
        end if;
        -- exit;
        --
      elsif l_inst_dets(l_count).excld_flag = 'N' then
        --
        l_rows_found := true;
        --
      end if;
      --
    end loop;
    --
  end if;
  --
  if l_crit_passed is null
  then
     if l_rows_found and
       not l_ok then
       --
       g_inelg_rsn_cd := 'ASS';
       fnd_message.set_name('BEN','BEN_92459_ASS_SET_PRFL_FAIL');
       hr_utility.set_location('Criteria Failed: '||l_proc,20);
       raise g_criteria_failed;
       --
     end if;
  end if;
  --
  if p_score_compute_mode
  then
     hr_utility.set_location('count '||l_score_tab.count,20);
     write(p_profile_score_tab,l_score_tab);
  end if;
  hr_utility.set_location('Leaving :'||l_proc,20);
  --
end check_asnt_set;
------------------------------------------------------------------------
-- ---------------------------------------------------------------
--  This procedure det elig based on persons benefit balance.
-- ---------------------------------------------------------------
procedure check_person_balance(p_eligy_prfl_id     in number,
                               p_person_id         in number,
                               p_business_group_id in number,
                               p_effective_date    in date,
                               p_per_comp_val      in number,
                               p_eval_typ          in varchar2,
                               p_comp_obj_mode     in boolean,
                               p_lf_evt_ocrd_dt    in date,
                               p_score_compute_mode in boolean default false,
                               p_profile_score_tab in out nocopy scoreTab,
                               p_per_in_ler_id     in number default null,
                               p_pl_id             in number default null,
                               p_pgm_id            in number default null,
                               p_oipl_id           in number default null,
                               p_plip_id           in number default null,
                               p_opt_id            in number default null) is
  --
  l_proc             varchar2(100):=g_package||'check_person_balance';
  l_inst_dets ben_elp_cache.g_cache_elpecl_instor;
  l_inst_count number;
  l_insttorrw_num binary_integer;
  l_ok               boolean := false;
  l_rows_found       boolean := false;
  l_per_comp_val     number := p_per_comp_val;
  l_crit_passed     boolean;
  l_score_tab       scoreTab;
  --
begin
  --
  hr_utility.set_location('Entering: '||l_proc, 10);
  --
  -- Getting eligibility profile compensation level by eligibility profile
  --
  ben_elp_cache.elpecl_getcacdets
    (p_effective_date    => nvl(l_fonm_cvg_strt_dt,p_effective_date)
    ,p_business_group_id => p_business_group_id
    ,p_comp_src_cd       => 'BALTYP'
    ,p_eligy_prfl_id     => p_eligy_prfl_id
    ,p_inst_set          => l_inst_dets
    ,p_inst_count        => l_inst_count);
  --
  if l_inst_count > 0 then
    --
    for l_insttorrw_num in l_inst_dets.first .. l_inst_dets.last loop
      --
      --if p_per_comp_val is null then
        --
        --fnd_message.set_name('BEN','BEN_91767_DERIVABLE_NO_EXIST');
        --raise ben_manage_life_events.g_record_error;
        --
      --end if;
      --
      if not p_comp_obj_mode or
         p_eval_typ <> 'E' then
        --
        ben_derive_factors.determine_compensation
        (p_person_id            => p_person_id
        ,p_comp_lvl_fctr_id     => l_inst_dets(l_insttorrw_num).comp_lvl_fctr_id
        ,p_pgm_id               => p_pgm_id
        ,p_pl_id                => p_pl_id
        ,p_oipl_id              => p_oipl_id
        ,p_per_in_ler_id        => p_per_in_ler_id
        ,p_perform_rounding_flg => true
        ,p_effective_date       => p_effective_date
        ,p_lf_evt_ocrd_dt       => p_lf_evt_ocrd_dt
        ,p_business_group_id    => p_business_group_id
        ,p_value                => l_per_comp_val
        ,p_fonm_cvg_strt_dt     => l_fonm_cvg_strt_dt);
      --
      end if;
      l_ok := is_ok(l_per_comp_val
                   ,l_inst_dets(l_insttorrw_num).mx_comp_val
                   ,l_inst_dets(l_insttorrw_num).mn_comp_val
                   ,l_inst_dets(l_insttorrw_num).no_mx_comp_flag
                   ,l_inst_dets(l_insttorrw_num).no_mn_comp_flag
                   );
      --
      if l_per_comp_val is null then
        --
        l_ok := false;
        --
      end if;
      --
      if l_ok and l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
        --
        if p_score_compute_mode then
           if l_crit_passed is null then
              l_crit_passed := true;
           end if;
           write(l_score_tab,
                 l_inst_dets(l_insttorrw_num).eligy_prfl_id,
                 l_inst_dets(l_insttorrw_num).short_code,
                 l_inst_dets(l_insttorrw_num).pk_id,
                 ( l_per_comp_val * nvl(l_inst_dets(l_insttorrw_num).criteria_weight, 0) ) +
                 nvl(l_inst_dets(l_insttorrw_num).criteria_score, 0)    /* Bug 4429071 */
                 );
        else
           exit;
        end if;
        --
      elsif l_ok and l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := false;
        exit;
        --
      elsif (not l_ok) and l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := true;
        if p_score_compute_mode then
           write(l_score_tab,
                 l_inst_dets(l_insttorrw_num).eligy_prfl_id,
                 l_inst_dets(l_insttorrw_num).short_code,
                 l_inst_dets(l_insttorrw_num).pk_id,
                 ( l_per_comp_val * nvl(l_inst_dets(l_insttorrw_num).criteria_weight, 0) ) +
                 nvl(l_inst_dets(l_insttorrw_num).criteria_score, 0)    /* Bug 4429071 */
                 );
        end if;
        -- exit;
        --
      elsif l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
        --
        l_rows_found := true;
        --
      end if;
      --
    end loop;
    --
  end if;
  --
  if l_crit_passed is null
  then
     if l_rows_found and
       not l_ok then
       --
       g_inelg_rsn_cd := 'CMP';
       fnd_message.set_name('BEN','BEN_91672_COMP_LVL_PRFL_FAIL');
       hr_utility.set_location('Criteria Failed: '||l_proc,20);
       raise g_criteria_failed;
       --
     end if;
  end if;
  --
  if p_score_compute_mode
  then
     hr_utility.set_location('count '||l_score_tab.count,20);
     write(p_profile_score_tab,l_score_tab);
  end if;
  hr_utility.set_location('Leaving :'||l_proc,20);
  --
end check_person_balance;
--------------------------------------------------------------------
--
-- --------------------------------------------------------------------------
--  This procedure det elig based on no other coverage participation.
-- --------------------------------------------------------------------------
--
procedure check_elig_no_othr_cvg_prte(p_eligy_prfl_id     in number,
                                      p_person_id         in number,
                                      p_business_group_id in number,
                                      p_effective_date    in date) is
  --
  l_proc             varchar2(100):=g_package||'check_elig_no_othr_cvg_prte';
  l_inst_dets        ben_elp_cache.g_cache_elpeno_instor;
  l_inst_count       number;
  l_insttorrw_num    binary_integer;
  l_ok               boolean := false;
  l_rows_found       boolean := false;
  l_rec              per_all_people_f%rowtype;
  --
begin
  --
  hr_utility.set_location('Entering: '||l_proc, 10);
  --
  -- Getting eligibility profile compensation level by eligibility profile
  --
  ben_elp_cache.elpeno_getcacdets
    (p_effective_date    => p_effective_date,
     p_business_group_id => p_business_group_id,
     p_eligy_prfl_id     => p_eligy_prfl_id,
     p_inst_set          => l_inst_dets,
     p_inst_count        => l_inst_count);
  --
  if l_inst_count > 0 then
    --
    -- Operation
    -- =========
    -- 1) Grab all profiles for this eligibility profile id
    -- 2) Check that the flag corresponds to the person record. If not error.
    --
    ben_person_object.get_object(p_person_id => p_person_id,
                                 p_rec       => l_rec);
    --
    for l_insttorrw_num in l_inst_dets.first .. l_inst_dets.last loop
      --
      l_rows_found := true;
      l_ok := nvl((nvl(l_rec.coord_ben_no_cvg_flag,'N') =
                  l_inst_dets(l_insttorrw_num).coord_ben_no_cvg_flag),FALSE);
      --if l_ok is null then
      --  l_ok:=false;
      --end if;
      --
      --
    end loop;
    --
  end if;
  --
  if l_rows_found and
    not l_ok then
    --
    g_inelg_rsn_cd := 'ENO';
    fnd_message.set_name('BEN','BEN_92227_ENO_ELIG_PRFL_FAIL');
    hr_utility.set_location('Criteria Failed: '||l_proc,20);
    raise g_criteria_failed;
    --
  end if;
  --
  hr_utility.set_location('Leaving :'||l_proc,20);
  --
end check_elig_no_othr_cvg_prte;
--
-- --------------------------------------------------------------------------
--  This procedure det elig based on leaving reason participation.
-- --------------------------------------------------------------------------
--
procedure check_elig_lvg_rsn_prte(p_eligy_prfl_id     in number,
                                  p_person_id         in number,
                                  p_business_group_id in number,
                                  p_score_compute_mode in boolean default false,
                                  p_profile_score_tab in out nocopy scoreTab,
                                  p_leaving_reason    in varchar2 default null,
                                  p_effective_date    in date) is
  --
  l_proc             varchar2(100):=g_package||'check_elig_lvg_rsn_prte';
  l_inst_dets        ben_elp_cache.g_cache_elpelv_instor;
  l_inst_count       number;
  l_insttorrw_num    binary_integer;
  l_ok               boolean := false;
  l_rows_found       boolean := false;
  l_rec              per_periods_of_service%rowtype;
  --
  l_crit_passed     boolean;
  l_score_tab       scoreTab;
begin
  --
  hr_utility.set_location('Entering: '||l_proc, 10);
  --
  -- Getting eligibility profile compensation level by eligibility profile
  --
  ben_elp_cache.elpelv_getcacdets
    (p_effective_date    => p_effective_date,
     p_business_group_id => p_business_group_id,
     p_eligy_prfl_id     => p_eligy_prfl_id,
     p_inst_set          => l_inst_dets,
     p_inst_count        => l_inst_count);
  --
  if l_inst_count > 0 then
    --
    -- Operation
    -- =========
    -- 1) Grab all profiles for this eligibility profile id
    -- 2) If the leaving reason code is excluded then person is not eligible
    -- 3) If the leaving reason code is not excluded then person is eligible.
    --
    if p_leaving_reason is null then
       ben_person_object.get_object(p_person_id => p_person_id,
                                    p_rec       => l_rec);
    else
       l_rec.leaving_reason := p_leaving_reason;
    end if;
    --
    for l_insttorrw_num in l_inst_dets.first .. l_inst_dets.last loop
      --
      l_rows_found := true;
      l_ok := nvl((nvl(l_rec.leaving_reason,'-1') =
              l_inst_dets(l_insttorrw_num).lvg_rsn_cd),FALSE);
      --if l_ok is null then
      --  l_ok:=false;
      --end if;
      --
      if l_ok = true then
        if l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
          --
          l_ok := false;
          exit ;
          --
        else
          --
          if p_score_compute_mode then
             if l_crit_passed is null then
                l_crit_passed := true;
             end if;
             write(l_score_tab,
                   l_inst_dets(l_insttorrw_num).eligy_prfl_id,
                   l_inst_dets(l_insttorrw_num).short_code,
                   l_inst_dets(l_insttorrw_num).pk_id,
                   nvl(l_inst_dets(l_insttorrw_num).criteria_score,
                   l_inst_dets(l_insttorrw_num).criteria_weight));
          else
             exit;
          end if;
          --
        end if;
      elsif l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
        --
        l_ok := true;
        if p_score_compute_mode then
           write(l_score_tab,
                 l_inst_dets(l_insttorrw_num).eligy_prfl_id,
                 l_inst_dets(l_insttorrw_num).short_code,
                 l_inst_dets(l_insttorrw_num).pk_id,
                 nvl(l_inst_dets(l_insttorrw_num).criteria_score,
                 l_inst_dets(l_insttorrw_num).criteria_weight));
        end if;
        -- exit;
        --
      end if;
      --
    end loop;
    --
  end if;
  --
  if l_crit_passed is null
  then
     if l_rows_found and
       not l_ok then
       --
       g_inelg_rsn_cd := 'ELV';
       fnd_message.set_name('BEN','BEN_92228_ELV_ELIG_PRFL_FAIL');
       hr_utility.set_location('Criteria Failed: '||l_proc,20);
       raise g_criteria_failed;
       --
     end if;
  end if;
  --
  if p_score_compute_mode
  then
     hr_utility.set_location('count '||l_score_tab.count,20);
     write(p_profile_score_tab,l_score_tab);
  end if;
  hr_utility.set_location('Leaving :'||l_proc,20);
  --
end check_elig_lvg_rsn_prte;
--
-- --------------------------------------------------------------------------
--  This procedure det elig based on opting medicare participation.
-- --------------------------------------------------------------------------
--
procedure check_elig_optd_mdcr_prte(p_eligy_prfl_id     in number,
                                    p_person_id         in number,
                                    p_business_group_id in number,
                                    p_effective_date    in date) is
  --
  l_proc             varchar2(100):=g_package||'check_elig_optd_mdcr_prte';
  l_inst_dets        ben_elp_cache.g_cache_elpeom_instor;
  l_inst_count       number;
  l_insttorrw_num    binary_integer;
  l_ok               boolean := false;
  l_rows_found       boolean := false;
  l_rec              per_all_people_f%rowtype;
  --
begin
  --
  hr_utility.set_location('Entering: '||l_proc, 10);
  --
  -- Getting eligibility profile compensation level by eligibility profile
  --
  ben_elp_cache.elpeom_getcacdets
    (p_effective_date    => p_effective_date,
     p_business_group_id => p_business_group_id,
     p_eligy_prfl_id     => p_eligy_prfl_id,
     p_inst_set          => l_inst_dets,
     p_inst_count        => l_inst_count);
  --
  if l_inst_count > 0 then
    --
    -- Operation
    -- =========
    -- 1) Grab all profiles for this eligibility profile id
    -- 2) If the leaving reason code is excluded then person is not eligible
    -- 3) If the leaving reason code is not excluded then person is eligible.
    --
    ben_person_object.get_object(p_person_id => p_person_id,
                                 p_rec       => l_rec);
    --
    for l_insttorrw_num in l_inst_dets.first .. l_inst_dets.last loop
      --
      l_rows_found := true;
      l_ok := nvl((nvl(l_rec.per_information10,'N') =
              l_inst_dets(l_insttorrw_num).optd_mdcr_flag),FALSE);
      --if l_ok is null then
      --  l_ok:=false;
      --end if;
      --
      --  There is only one row so there is no need to do further checking.
      --
    end loop;
    --
  end if;
  --
  if l_rows_found and
    not l_ok then
    --
    g_inelg_rsn_cd := 'EOM';
    fnd_message.set_name('BEN','BEN_92229_EOM_ELIG_PRFL_FAIL');
    hr_utility.set_location('Criteria Failed: '||l_proc,20);
    raise g_criteria_failed;
    --
  end if;
  --
  hr_utility.set_location('Leaving :'||l_proc,20);
  --
end check_elig_optd_mdcr_prte;
--
-- --------------------------------------------------------------------------
--  This procedure det elig based on enrolled in another plan.
-- --------------------------------------------------------------------------
--
procedure check_elig_enrld_anthr_pl(p_eligy_prfl_id     in number,
                                    p_business_group_id in number,
                                    p_pl_id             in number,
                                    p_person_id         in number,
                                    p_effective_date    in date,
                                    p_lf_evt_ocrd_dt    in date) is
  --
  l_proc             varchar2(100):=g_package||'check_elig_enrld_anthr_pl';
  l_inst_dets        ben_elp_cache.g_cache_elpeep_instor;
  l_inst_count       number;
  l_insttorrw_num    binary_integer;
  l_ok               boolean := false;
  l_rows_found       boolean := false;
  l_found_plan       boolean := false;
  l_date_to_use      date;
  l_dummy            varchar2(1);
  --
begin
  --
  hr_utility.set_location('Entering: '||l_proc, 10);
  --
  -- Getting eligibility profile enrld in another plan by eligibility profile
  --
  ben_elp_cache.elpeep_getcacdets
    (p_effective_date    => nvl(p_lf_evt_ocrd_dt,p_effective_date),
     p_business_group_id => p_business_group_id,
     p_eligy_prfl_id     => p_eligy_prfl_id,
     p_inst_set          => l_inst_dets,
     p_inst_count        => l_inst_count);
  --
  if l_inst_count > 0 then
    --
    -- Operation
    -- =========
    -- 1) Grab all profiles for this eligibility profile id
    -- 2) If the plan id is the same then check if the person was covered
    --    the day before the life event.
    --
    <<prfl>>
    for l_insttorrw_num in l_inst_dets.first .. l_inst_dets.last loop
      --
      l_rows_found := true;
      --
      <<rslt>>
      for l_count in nvl(ben_manage_life_events.g_cache_person_prtn.first,0)..
                     nvl(ben_manage_life_events.g_cache_person_prtn.last,-1) loop
        if ben_manage_life_events.g_cache_person_prtn(l_count).pl_id =
           l_inst_dets(l_insttorrw_num).pl_id then
          --
          -- Apply the date logic to the life event occurred date.
          --
          ben_determine_date.main
            (p_date_cd        => l_inst_dets(l_insttorrw_num).enrl_det_dt_cd,
             p_effective_date => p_effective_date,
             p_lf_evt_ocrd_dt => p_lf_evt_ocrd_dt,
             p_fonm_cvg_strt_dt  => ben_manage_life_events.g_fonm_cvg_strt_dt,
             p_fonm_rt_strt_dt  => ben_manage_life_events.g_fonm_rt_strt_dt,
             p_returned_date  => l_date_to_use);
          --
          if (l_date_to_use
             between ben_manage_life_events.
                     g_cache_person_prtn(l_count).enrt_cvg_strt_dt
             and ben_manage_life_events.
                 g_cache_person_prtn(l_count).enrt_cvg_thru_dt) then
             l_found_plan := true;
            --
            if l_inst_dets(l_insttorrw_num).excld_flag = 'N'then
              --
              l_ok := true;
              exit prfl;
              --
            end if;
            --
            if l_inst_dets(l_insttorrw_num).excld_flag = 'Y'then
              --
              l_ok := false;
              exit prfl;
              --
            end if;
            --
          end if;
          --
        end if;
      end loop rslt;
      --
      --  If person is not enrolled in plan and exclude flag = 'Y',
      --  person is eligible.
      --
      if (l_found_plan = false
         and l_inst_dets(l_insttorrw_num).excld_flag = 'Y') then
        l_ok := true;
        exit;
      end if;
      --
    end loop prfl;
    --
  end if;
  --
  if l_rows_found and
    not l_ok then
    --
    g_inelg_rsn_cd := 'EEP';
    fnd_message.set_name('BEN','BEN_92230_EEP_ELIG_PRFL_FAIL');
    hr_utility.set_location('Criteria Failed: '||l_proc,20);
    raise g_criteria_failed;
    --
  end if;
  --
  hr_utility.set_location('Leaving :'||l_proc,20);
  --
end check_elig_enrld_anthr_pl;
--
-- --------------------------------------------------------------------------
--  This procedure det elig based on enrolled in another option in plan.
-- --------------------------------------------------------------------------
--
procedure check_elig_enrld_anthr_oipl(p_eligy_prfl_id     in number,
                                      p_business_group_id in number,
                                      p_oipl_id           in number,
                                      p_person_id         in number,
                                      p_effective_date    in date,
                                      p_lf_evt_ocrd_dt    in date) is
  --
  l_proc             varchar2(100):=g_package||'check_elig_enrld_anthr_oipl';
  l_inst_dets        ben_elp_cache.g_cache_elpeei_instor;
  l_inst_count       number;
  l_insttorrw_num    binary_integer;
  l_ok               boolean := false;
  l_rows_found       boolean := false;
  l_found_oipl       boolean := false;
  l_date_to_use      date;
  l_dummy            varchar2(1);
  --
  cursor c1(p_date_to_use DATE) is
    select null
    from   ben_prtt_enrt_rslt_f pen
    where  pen.business_group_id  = p_business_group_id
    and    pen.oipl_id = p_oipl_id
    and    pen.person_id = p_person_id
    and    p_date_to_use
           between pen.enrt_cvg_strt_dt
           and     pen.enrt_cvg_thru_dt
    and    pen.enrt_cvg_thru_dt <= pen.effective_end_date
    and    pen.prtt_enrt_rslt_stat_cd is null;
  --
begin
  --
  hr_utility.set_location('Entering: '||l_proc, 10);
  --
  -- Getting eligibility profile compensation level by eligibility profile
  --
  ben_elp_cache.elpeei_getcacdets
    (p_effective_date    => nvl(l_fonm_cvg_strt_dt,nvl(p_lf_evt_ocrd_dt,p_effective_date)),
     p_business_group_id => p_business_group_id,
     p_eligy_prfl_id     => p_eligy_prfl_id,
     p_inst_set          => l_inst_dets,
     p_inst_count        => l_inst_count);
  --
  if l_inst_count > 0 then
    --
    -- Operation
    -- =========
    -- 1) Grab all profiles for this eligibility profile id
    -- 2) If the plan id is the same then check if the person was covered
    --    the day before the life event.
    --
    <<prfl>>
    for l_insttorrw_num in l_inst_dets.first .. l_inst_dets.last loop
      --
      l_rows_found := true;
      --
      <<rslt>>
      for l_count in nvl(ben_manage_life_events.g_cache_person_prtn.first,0)..
                     nvl(ben_manage_life_events.g_cache_person_prtn.last,-1) loop
        if ben_manage_life_events.
           g_cache_person_prtn(l_count).oipl_id =
             l_inst_dets(l_insttorrw_num).oipl_id then
          --
          -- Apply the date logic to the life event occurred date.
          --
          ben_determine_date.main
            (p_date_cd        => l_inst_dets(l_insttorrw_num).enrl_det_dt_cd,
             p_effective_date => p_effective_date,
             p_lf_evt_ocrd_dt => p_lf_evt_ocrd_dt,
             p_fonm_cvg_strt_dt  => ben_manage_life_events.g_fonm_cvg_strt_dt,
             p_fonm_rt_strt_dt  => ben_manage_life_events.g_fonm_rt_strt_dt,
             p_returned_date  => l_date_to_use);
          --
          if (l_date_to_use
             between ben_manage_life_events.
                     g_cache_person_prtn(l_count).enrt_cvg_strt_dt
             and ben_manage_life_events.
                 g_cache_person_prtn(l_count).enrt_cvg_thru_dt) then
            --
            l_found_oipl := true;
            --
            if l_inst_dets(l_insttorrw_num).excld_flag = 'N'then
              --
              l_ok := true;
              exit prfl;
              --
            end if;
            --
            if l_inst_dets(l_insttorrw_num).excld_flag = 'Y'then
              --
              l_ok := false;
              exit prfl;
              --
            end if;
            --
          end if;
          --
        end if;
        --
      end loop rslt;
          --
      if (l_found_oipl = false
          and l_inst_dets(l_insttorrw_num).excld_flag = 'Y') then
        --
        l_ok := true;
        exit;
          --
      end if;
      --
    end loop prfl;
    --
  end if;
  --
  if l_rows_found and
    not l_ok then
    --
    g_inelg_rsn_cd := 'EEI';
    fnd_message.set_name('BEN','BEN_92231_EEI_ELIG_PRFL_FAIL');
    hr_utility.set_location('Criteria Failed: '||l_proc,20);
    raise g_criteria_failed;
    --
  end if;
  --
  hr_utility.set_location('Leaving :'||l_proc,20);
  --
end check_elig_enrld_anthr_oipl;
--
-- --------------------------------------------------------------------------
--  This procedure det elig based on enrolled in another program.
-- --------------------------------------------------------------------------
--
procedure check_elig_enrld_anthr_pgm
  (p_eligy_prfl_id     in number
  ,p_business_group_id in number
  ,p_pgm_id            in number
  ,p_person_id         in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  )
is
  --
  l_proc             varchar2(100):=g_package||'check_elig_enrld_anthr_pgm';
  l_inst_dets        ben_elp_cache.g_cache_elpeeg_instor;
  l_inst_count       number;
  l_insttorrw_num    binary_integer;
  l_ok               boolean := false;
  l_rows_found       boolean := false;
  l_found_pgm        boolean := false;
  l_date_to_use      date;
  l_dummy            varchar2(1);
  --
begin
  --
  hr_utility.set_location('Entering: '||l_proc, 10);
  hr_utility.set_location('prfl_id: '||p_eligy_prfl_id, 10);
  --
  -- Getting eligibility profile compensation level by eligibility profile
  --
  ben_elp_cache.elpeeg_getcacdets
    (p_effective_date    => nvl(l_fonm_cvg_strt_dt,nvl(p_lf_evt_ocrd_dt,p_effective_date)),
     p_business_group_id => p_business_group_id,
     p_eligy_prfl_id     => p_eligy_prfl_id,
     p_inst_set          => l_inst_dets,
     p_inst_count        => l_inst_count);
  --
  if l_inst_count > 0 then
    --
    -- Operation
    -- =========
    -- 1) Grab all profiles for this eligibility profile id
    -- 2) If the plan id is the same then check if the person was covered
    --    the day before the life event.
    --
    <<prfl>>
    for l_insttorrw_num in l_inst_dets.first .. l_inst_dets.last loop
      --
      l_rows_found := true;
      --
      <<rslt>>
      for l_count in nvl(ben_manage_life_events.g_cache_person_prtn.first,0)..
                     nvl(ben_manage_life_events.g_cache_person_prtn.last,-1) loop
        if ben_manage_life_events.g_cache_person_prtn(l_count).pgm_id =
             l_inst_dets(l_insttorrw_num).pgm_id then
           l_found_pgm := true;
          --
          -- Apply the date logic to the life event occurred date.
          --
          ben_determine_date.main
            (p_date_cd        => l_inst_dets(l_insttorrw_num).enrl_det_dt_cd,
             p_effective_date => p_effective_date,
             p_lf_evt_ocrd_dt => p_lf_evt_ocrd_dt,
             p_fonm_cvg_strt_dt  => ben_manage_life_events.g_fonm_cvg_strt_dt,
             p_fonm_rt_strt_dt  => ben_manage_life_events.g_fonm_rt_strt_dt,
             p_returned_date  => l_date_to_use);
          --
          if (l_date_to_use
             between ben_manage_life_events.
                     g_cache_person_prtn(l_count).enrt_cvg_strt_dt
             and ben_manage_life_events.
                 g_cache_person_prtn(l_count).enrt_cvg_thru_dt) then
            --
            if l_inst_dets(l_insttorrw_num).excld_flag = 'N'then
              --
              l_ok := true;
              exit prfl;
              --
            end if;
            --
            if l_inst_dets(l_insttorrw_num).excld_flag = 'Y'then
              --
              l_ok := false;
              exit prfl;
              --
            end if;
            --
          end if;
          --
        end if;
        --
      end loop rslt;
        --
        --  If person is not enrolled in the program and exclude flag = "Y"
        --  person is eligible.
        --
        if (l_found_pgm = false
            and l_inst_dets(l_insttorrw_num).excld_flag = 'Y') then
          --
          l_ok := true;
          exit;
          --
        end if;

      --
    end loop prfl;
    --
  end if;
  --
  if l_rows_found and
    not l_ok then
    --
    g_inelg_rsn_cd := 'EEG';
    fnd_message.set_name('BEN','BEN_92232_EEG_ELIG_PRFL_FAIL');
    hr_utility.set_location('Criteria Failed: '||l_proc,20);
    raise g_criteria_failed;
    --
  end if;
  --
  hr_utility.set_location('Leaving :'||l_proc,20);
  --
end check_elig_enrld_anthr_pgm;
--
-- --------------------------------------------------------------------------
--  This procedure det elig based on dependent covered by another plan.
-- --------------------------------------------------------------------------
procedure check_elig_dpnt_cvrd_othr_pl(p_eligy_prfl_id     in number,
                                       p_business_group_id in number,
                                       p_pl_id             in number,
                                       p_person_id         in number,
                                       p_effective_date    in date,
                                       p_lf_evt_ocrd_dt    in date) is
  --
  l_proc             varchar2(100):=g_package||'check_elig_dpnt_cvrd_othr_pl';
  l_inst_dets        ben_elp_cache.g_cache_elpedp_instor;
  l_inst_count       number;
  l_insttorrw_num    binary_integer;
  l_ok               boolean := false;
  l_rows_found       boolean := false;
  l_date_to_use      date;
  l_dummy            varchar2(1);
  --
  cursor c1(p_pl_id in number) is
    select null
    from   ben_elig_cvrd_dpnt_f pdp,
           ben_prtt_enrt_rslt_f pen
    where  pen.business_group_id  = p_business_group_id
    and    pen.pl_id = p_pl_id
    and    pdp.dpnt_person_id = p_person_id
    and    l_date_to_use
           between pen.enrt_cvg_strt_dt
           and     pen.enrt_cvg_thru_dt
    and    pen.enrt_cvg_thru_dt <= pen.effective_end_date
    and    pdp.business_group_id  = pen.business_group_id
    and    pdp.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
    --
    and    pen.prtt_enrt_rslt_stat_cd is null
    and    l_date_to_use
           between pdp.cvg_strt_dt
           and     pdp.cvg_thru_dt
    and    pdp.effective_end_date = hr_api.g_eot;
  --
begin
  --
  hr_utility.set_location('Entering: '||l_proc, 10);
  --
  -- Getting eligibility profile compensation level by eligibility profile
  --
  ben_elp_cache.elpedp_getcacdets
    (p_effective_date    => nvl(p_lf_evt_ocrd_dt,p_effective_date),
     p_business_group_id => p_business_group_id,
     p_eligy_prfl_id     => p_eligy_prfl_id,
     p_inst_set          => l_inst_dets,
     p_inst_count        => l_inst_count);
  --
  if l_inst_count > 0 then
    --
    -- Operation
    -- =========
    -- 1) Grab all profiles for this eligibility profile id
    -- 2) If the plan id is the same then check if the person was covered
    --    the day before the life event.
    --
    for l_insttorrw_num in l_inst_dets.first .. l_inst_dets.last loop
      --
      l_rows_found := true;
      --
      --
      -- Apply the date logic to the life event occurred date.
      --
      ben_determine_date.main
        (p_date_cd        => l_inst_dets(l_insttorrw_num).cvg_det_dt_cd,
         p_effective_date => p_effective_date,
         p_lf_evt_ocrd_dt => p_lf_evt_ocrd_dt,
         p_fonm_cvg_strt_dt  => ben_manage_life_events.g_fonm_cvg_strt_dt,
         p_fonm_rt_strt_dt  => ben_manage_life_events.g_fonm_rt_strt_dt,
         p_returned_date  => l_date_to_use);
      --
      open c1(l_inst_dets(l_insttorrw_num).pl_id);
      fetch c1 into l_dummy;
      --
      if c1%found then
        --
        close c1;
        --
        if l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
          l_ok := true;
          exit;
        end if;
        --
        if l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
          l_ok := false;
          exit;
        end if;
        --
      else
        --
        close c1;
        if l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
          l_ok := true;
          -- exit;
        end if;
      end if;
      --
    end loop;
    --
  end if;
  --
  if l_rows_found and
    not l_ok then
    --
    g_inelg_rsn_cd := 'EDP';
    fnd_message.set_name('BEN','BEN_92233_EDP_ELIG_PRFL_FAIL');
    hr_utility.set_location('Criteria Failed: '||l_proc,20);
    raise g_criteria_failed;
    --
  end if;
  --
  hr_utility.set_location('Leaving :'||l_proc,20);
  --
end check_elig_dpnt_cvrd_othr_pl;
--
-- --------------------------------------------------------------------------
--  This procedure det elig based on enrolled in another plan in program.
-- --------------------------------------------------------------------------
--
procedure check_elig_enrld_anthr_plip(p_eligy_prfl_id     in number,
                                      p_business_group_id in number,
                                      p_person_id         in number,
                                      p_effective_date    in date,
                                      p_lf_evt_ocrd_dt    in date) is
  --
  l_proc             varchar2(100):=g_package||'check_elig_enrld_anthr_plip';
  l_inst_dets        ben_elp_cache.g_cache_elpeai_instor;
  l_inst_count       number;
  l_insttorrw_num    binary_integer;
  l_ok               boolean := false;
  l_rows_found       boolean := false;
  l_date_to_use      date;
  l_dummy            varchar2(1);
  --
  cursor c1(p_plip_id in number,p_date_to_use date) is
    select null
    from   ben_prtt_enrt_rslt_f pen
          ,ben_plip_f           cpp
    where  pen.business_group_id  = p_business_group_id
    and    pen.pgm_id = cpp.pgm_id
    and    pen.pl_id  = cpp.pl_id
    and    cpp.plip_id = p_plip_id
    and    p_date_to_use
           between cpp.effective_start_date
           and     cpp.effective_end_date
    and    cpp.business_group_id = pen.business_group_id
    and    pen.person_id = p_person_id
    and    p_date_to_use
           between pen.enrt_cvg_strt_dt
           and     pen.enrt_cvg_thru_dt
    and    pen.enrt_cvg_thru_dt <= pen.effective_end_date
    and    pen.prtt_enrt_rslt_stat_cd is null;
  --
begin
  --
  hr_utility.set_location('Entering: '||l_proc, 10);
  --
  -- Getting eligibility profile compensation level by eligibility profile
  --
  ben_elp_cache.elpeai_getcacdets
    (p_effective_date    => nvl(l_fonm_cvg_strt_dt,nvl(p_lf_evt_ocrd_dt,p_effective_date)),
     p_business_group_id => p_business_group_id,
     p_eligy_prfl_id     => p_eligy_prfl_id,
     p_inst_set          => l_inst_dets,
     p_inst_count        => l_inst_count);
  --
  if l_inst_count > 0 then
    --
    -- Operation
    -- =========
    -- 1) Grab all profiles for this eligibility profile id
    -- 2) If the plan id is the same then check if the person was covered
    --    the day before the life event.
    --
    for l_insttorrw_num in l_inst_dets.first .. l_inst_dets.last loop
      --
      l_rows_found := true;
      --
      --
      -- Apply the date logic to the life event occurred date.
      --
      ben_determine_date.main
        (p_date_cd        => l_inst_dets(l_insttorrw_num).enrl_det_dt_cd,
         p_effective_date => p_effective_date,
         p_lf_evt_ocrd_dt => p_lf_evt_ocrd_dt,
         p_fonm_cvg_strt_dt  => ben_manage_life_events.g_fonm_cvg_strt_dt,
         p_fonm_rt_strt_dt  => ben_manage_life_events.g_fonm_rt_strt_dt,
         p_returned_date  => l_date_to_use);
      --
      -- 4204020  l_date_to_use := nvl(l_fonm_cvg_strt_dt,l_date_to_use);
      --
      open c1(l_inst_dets(l_insttorrw_num).plip_id,l_date_to_use);
      fetch c1 into l_dummy;
      --
      if c1%found then
        --
        close c1;
        --
        if l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
          l_ok := true;
          exit;
        end if;
        --
        if l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
          l_ok := false;
          exit;
        end if;
        --
      else
        --
        close c1;
        if l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
          l_ok := true;
          -- exit;
        end if;
      end if;
      --
    end loop;
    --
  end if;
  --
  if l_rows_found and
    not l_ok then
    --
    g_inelg_rsn_cd := 'EAI';
    fnd_message.set_name('BEN','BEN_92420_EAI_ELIG_PRFL_FAIL');
    hr_utility.set_location('Criteria Failed: '||l_proc,20);
    raise g_criteria_failed;
    --
  end if;
  --
  hr_utility.set_location('Leaving :'||l_proc,20);
  --
end check_elig_enrld_anthr_plip;
--
-- --------------------------------------------------------------------------
--  This procedure det elig based on dependent coverd in another plan in program.
-- --------------------------------------------------------------------------
--
procedure check_elig_dpnt_cvrd_othr_plip(p_eligy_prfl_id     in number,
                                         p_business_group_id in number,
                                         p_person_id         in number,
                                         p_effective_date    in date,
                                         p_lf_evt_ocrd_dt    in date) is
  --
  l_proc             varchar2(100):=g_package||'check_elig_dpnt_cvrd_othr_plip';
  l_inst_dets        ben_elp_cache.g_cache_elpedi_instor;
  l_inst_count       number;
  l_insttorrw_num    binary_integer;
  l_ok               boolean := false;
  l_rows_found       boolean := false;
  l_date_to_use      date;
  l_dummy            varchar2(1);
  --
  cursor c1(p_plip_id in number,p_date_to_use date ) is
    select null
    from   ben_prtt_enrt_rslt_f pen
          ,ben_elig_cvrd_dpnt_f pdp
          ,ben_plip_f           cpp
    where  pen.prtt_enrt_rslt_id = pdp.prtt_enrt_rslt_id
    --and    pen.prtt_enrt_rslt_stat_cd not in ('BCKDT', 'VOIDD')
    and    pen.prtt_enrt_rslt_stat_cd is null
    and    pdp.dpnt_person_id = p_person_id
    and    pen.pgm_id = cpp.pgm_id
    and    pen.pl_id  = cpp.pl_id
    and    cpp.plip_id = p_plip_id
    and    p_date_to_use
           between cpp.effective_start_date
           and     cpp.effective_end_date
    and    cpp.business_group_id = pen.business_group_id
    and    p_date_to_use
           between pen.enrt_cvg_strt_dt
           and     pen.enrt_cvg_thru_dt
    and    pen.business_group_id  = p_business_group_id
    and    pen.enrt_cvg_thru_dt <= pen.effective_end_date
    and    pen.prtt_enrt_rslt_stat_cd is null
    and    pdp.business_group_id = pen.business_group_id
    and    p_date_to_use
           between pdp.cvg_strt_dt
           and     pdp.cvg_thru_dt
    and    pdp.effective_end_date = hr_api.g_eot;
  --
begin
  --
  hr_utility.set_location('Entering: '||l_proc, 10);
  --
  -- Getting eligibility profile compensation level by eligibility profile
  --
  ben_elp_cache.elpedi_getcacdets
    (p_effective_date    => nvl(l_fonm_cvg_strt_dt,nvl(p_lf_evt_ocrd_dt,p_effective_date)),
     p_business_group_id => p_business_group_id,
     p_eligy_prfl_id     => p_eligy_prfl_id,
     p_inst_set          => l_inst_dets,
     p_inst_count        => l_inst_count);
  --
  if l_inst_count > 0 then
    --
    -- Operation
    -- =========
    -- 1) Grab all profiles for this eligibility profile id
    -- 2) If the plan id is the same then check if the person was covered
    --    the day before the life event.
    --
    for l_insttorrw_num in l_inst_dets.first .. l_inst_dets.last loop
      --
      l_rows_found := true;
      --
      --
      -- Apply the date logic to the life event occurred date.
      --
      ben_determine_date.main
        (p_date_cd        => l_inst_dets(l_insttorrw_num).enrl_det_dt_cd,
         p_effective_date => p_effective_date,
         p_lf_evt_ocrd_dt => p_lf_evt_ocrd_dt,
         p_fonm_cvg_strt_dt  => ben_manage_life_events.g_fonm_cvg_strt_dt,
         p_fonm_rt_strt_dt  => ben_manage_life_events.g_fonm_rt_strt_dt,
         p_returned_date  => l_date_to_use);
      --
      -- 4204020 l_date_to_use := nvl(l_fonm_cvg_strt_dt,l_date_to_use);
      --
      open c1(l_inst_dets(l_insttorrw_num).plip_id,l_date_to_use );
      fetch c1 into l_dummy;
      --
      if c1%found then
        --
        close c1;
        --
        if l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
          l_ok := true;
          exit;
        end if;
        --
        if l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
          l_ok := false;
          exit;
        end if;
        --
      else
        --
        close c1;
        if l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
          l_ok := true;
          -- exit;
        end if;
      end if;
      --
    end loop;
    --
  end if;
  --
  if l_rows_found and
    not l_ok then
    --
    g_inelg_rsn_cd := 'EDI';
    fnd_message.set_name('BEN','BEN_92421_EDI_ELIG_PRFL_FAIL');
    hr_utility.set_location('Criteria Failed: '||l_proc,20);
    raise g_criteria_failed;
    --
  end if;
  --
  hr_utility.set_location('Leaving :'||l_proc,20);
  --
end check_elig_dpnt_cvrd_othr_plip;
--
-- --------------------------------------------------------------------------
--  This procedure det elig based enrollment in other plan type in program.
-- --------------------------------------------------------------------------
--
procedure check_elig_enrld_anthr_ptip(p_eligy_prfl_id     in number,
                                      p_business_group_id in number,
                                      p_effective_date    in date,
                                      p_lf_evt_ocrd_dt    in date) is
  --
  l_proc varchar2(100):=g_package||'check_elig_enrld_anthr_ptip';
  --
  l_inst_dets                   ben_elp_cache.g_cache_elpeet_instor;
  l_inst_count                  number;
  l_insttorrw_num               binary_integer;
  l_ok                          boolean := false;
  l_rows_found                  boolean := false;
  l_found_ptip                  boolean := false;
  l_continue                    boolean := true;
  l_date_to_use                 date;
  l_dummy                       varchar2(1);
  l_pl_rec                      ben_comp_object.g_cache_pl_rec_table;
  --
  cursor c1(p_pl_id in number,p_date_to_use date ) is
    select null
    from   ben_pl_f pln,
           ben_pl_regn_f prg,
           ben_regn_f reg
    where  pln.pl_id = p_pl_id
    and    pln.business_group_id  = p_business_group_id
    and    p_date_to_use
           between pln.effective_start_date
           and     pln.effective_end_date
    and    pln.pl_id = prg.pl_id
    and    prg.business_group_id  = pln.business_group_id
    and    p_date_to_use
           between prg.effective_start_date
           and     prg.effective_end_date
    and    prg.regn_id = reg.regn_id
    and    reg.business_group_id  = prg.business_group_id
    and    p_date_to_use
           between reg.effective_start_date
           and     reg.effective_end_date
    and    reg.sttry_citn_name = 'COBRA';

  --
begin
  --
  hr_utility.set_location('Entering: '||l_proc, 10);
  hr_utility.set_location('l_fonm_cvg_strt_dt: '||l_fonm_cvg_strt_dt, 10);
  --
  -- Getting eligibility profile compensation level by eligibility profile
  --
  ben_elp_cache.elpeet_getcacdets
    (p_effective_date    => nvl(l_fonm_cvg_strt_dt,nvl(p_lf_evt_ocrd_dt,p_effective_date)),
     p_business_group_id => p_business_group_id,
     p_eligy_prfl_id     => p_eligy_prfl_id,
     p_inst_set          => l_inst_dets,
     p_inst_count        => l_inst_count);
  --
  hr_utility.set_location('l_inst_count: '||l_inst_count, 10);
  if l_inst_count > 0 then
    --
    -- Operation
    -- =========
    -- 1) Grab all profiles for this eligibility profile id
    -- 2) Look only at profiles for this PTIP_ID
    -- 3) Set must be derived based on whether the plans are subject
    --    to COBRA or not.
    -- 4) If person eligible for any of the plans and exclude flag = 'Y'
    --    then no problem.
    -- 5) If person eligible for any of the plans and exclude flag = 'N'
    --    then fail criteria.
    --
    hr_utility.set_location('Getting profiles',10);
    <<prfl>>
    for l_insttorrw_num in l_inst_dets.first .. l_inst_dets.last loop
      --
      l_rows_found := true;
      --
      hr_utility.set_location('Getting results' || ben_manage_life_events.g_cache_person_prtn.last ,10);

      <<rslt>>
      for l_count in nvl(ben_manage_life_events.g_cache_person_prtn.first,0)..
                     nvl(ben_manage_life_events.g_cache_person_prtn.last,-1) loop
        if ben_manage_life_events.
           g_cache_person_prtn(l_count).ptip_id =
             l_inst_dets(l_insttorrw_num).ptip_id then
          --
          -- Apply the date logic to the life event occurred date.
          --
          ben_determine_date.main
            (p_date_cd        => l_inst_dets(l_insttorrw_num).enrl_det_dt_cd,
             p_effective_date => p_effective_date,
             p_lf_evt_ocrd_dt => p_lf_evt_ocrd_dt,
             p_fonm_cvg_strt_dt  => ben_manage_life_events.g_fonm_cvg_strt_dt,
             p_fonm_rt_strt_dt  => ben_manage_life_events.g_fonm_rt_strt_dt,
             p_returned_date  => l_date_to_use);
          --
          hr_utility.set_location( 'l_date_to_use ' || l_date_to_use , 99 ) ;

          -- 4204020 l_date_to_use := NVL(l_fonm_cvg_strt_dt,l_date_to_use);
          hr_utility.set_location( 'l_date_to_use ' || l_date_to_use , 99 ) ;
          --
          --  If only check plans that are subject to COBRA.
          --
          l_continue := true;
          --
          hr_utility.set_location('Getting cobra plans',10);
          --
          if l_inst_dets(l_insttorrw_num).only_pls_subj_cobra_flag = 'Y' then
            --
            open c1(ben_manage_life_events.g_cache_person_prtn(l_count).pl_id,
                    l_date_to_use );
              --
              fetch c1 into l_dummy;
              --
              if c1%notfound then
                --
                hr_utility.set_location('Cobra plans not found',10);
                l_continue := false;
                --
              end if;
              --
            close c1;
            --
          end if;
          --
          if l_continue then
            --
            hr_utility.set_location('Cobra plans found',10);
            --
            if (l_date_to_use
               between ben_manage_life_events.
                       g_cache_person_prtn(l_count).enrt_cvg_strt_dt
               and ben_manage_life_events.
                   g_cache_person_prtn(l_count).enrt_cvg_thru_dt) then
              --
              l_found_ptip := true;
              hr_utility.set_location('cobra  plans found',10);
              --
              if l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
                --
                hr_utility.set_location('Exclude flags = N Cobra plans found',10);
                l_ok := true;
                exit prfl;
                --
              end if;
              --
              if l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
                --
                hr_utility.set_location('Exclude flags = Y Cobra plans found',10);
                l_ok := false;
                exit prfl;
                --
              end if;
              --
            end if;
            --
          end if;
          --
        end if;
        --
      end loop rslt;
      --
      if l_found_ptip = false
         and l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
        --
        l_ok := true;
        exit;
        --
      end if;
      --
    end loop prfl;
    --
  end if;
  --
  if l_rows_found and
    not l_ok then
    --
    g_inelg_rsn_cd := 'EET';
    fnd_message.set_name('BEN','BEN_92422_EET_ELIG_PRFL_FAIL');
    hr_utility.set_location('Criteria Failed: '||l_proc,20);
    raise g_criteria_failed;
    --
  end if;
  --
  hr_utility.set_location('Leaving :'||l_proc,20);
  --
end check_elig_enrld_anthr_ptip;
--
-- --------------------------------------------------------------------------
--  This procedure det elig based on dependent covered in another plan type
--  in program.
-- --------------------------------------------------------------------------
--
procedure check_elig_dpnt_cvrd_othr_ptip(p_eligy_prfl_id     in number,
                                         p_business_group_id in number,
                                         p_person_id         in number,
                                         p_effective_date    in date,
                                         p_lf_evt_ocrd_dt    in date) is
  --
  l_proc             varchar2(100):=g_package||'check_elig_dpnt_cvrd_othr_ptip';
  l_inst_dets        ben_elp_cache.g_cache_elpedt_instor;
  l_inst_count       number;
  l_insttorrw_num    binary_integer;
  l_ok               boolean := false;
  l_rows_found       boolean := false;
  l_continue         boolean := true;
  l_found_ptip       boolean := false;
  l_date_to_use      date;
  l_dummy            varchar2(1);
  --
  cursor c1(p_ptip_id in number,p_date_to_use date ) is
    select pen.pl_id
    from   ben_prtt_enrt_rslt_f pen
          ,ben_elig_cvrd_dpnt_f pdp
    where  pen.prtt_enrt_rslt_id = pdp.prtt_enrt_rslt_id
    --and    pen.prtt_enrt_rslt_stat_cd not in ('BCKDT', 'VOIDD')
    and    pen.prtt_enrt_rslt_stat_cd is null
    and    pdp.dpnt_person_id = p_person_id
    and    pen.ptip_id = p_ptip_id
    and    p_date_to_use
           between pen.enrt_cvg_strt_dt
           and     pen.enrt_cvg_thru_dt
    and    pen.business_group_id  = p_business_group_id
    and    pen.enrt_cvg_thru_dt <= pen.effective_end_date
    and    pen.prtt_enrt_rslt_stat_cd is null
    and    pdp.business_group_id = pen.business_group_id
    and    p_date_to_use
           between pdp.cvg_strt_dt
           and     pdp.cvg_thru_dt
    and    pdp.effective_end_date = hr_api.g_eot;
  --
  cursor c2(p_pl_id in number,p_date_to_use date ) is
    select null
    from   ben_pl_regn_f prg
          ,ben_regn_f reg
    where  prg.pl_id = p_pl_id
    and    prg.regn_id = reg.regn_id
    and    reg.sttry_citn_name = 'COBRA'
    and    prg.business_group_id = p_business_group_id
    and    p_date_to_use
           between prg.effective_start_date
           and     prg.effective_end_date
    and    prg.business_group_id = reg.business_group_id
    and    p_date_to_use
           between reg.effective_start_date
           and     reg.effective_end_date;
  --
begin
  --
  hr_utility.set_location('Entering: '||l_proc, 10);
  --
  -- Getting eligibility profile compensation level by eligibility profile
  --
  ben_elp_cache.elpedt_getcacdets
    (p_effective_date    => nvl(l_fonm_cvg_strt_dt,
                               nvl(p_lf_evt_ocrd_dt,p_effective_date)),
     p_business_group_id => p_business_group_id,
     p_eligy_prfl_id     => p_eligy_prfl_id,
     p_inst_set          => l_inst_dets,
     p_inst_count        => l_inst_count);
  --
  if l_inst_count > 0 then
    --
    -- Operation
    -- =========
    -- 1) Grab all profiles for this eligibility profile id
    -- 2) If the plan id is the same then check if the person was covered
    --    the day before the life event.
    --
    <<prfl>>
    for l_insttorrw_num in l_inst_dets.first .. l_inst_dets.last loop
      --
      l_rows_found := true;
      --
      --
      -- Apply the date logic to the life event occurred date.
      --
      ben_determine_date.main
        (p_date_cd        => l_inst_dets(l_insttorrw_num).enrl_det_dt_cd,
         p_effective_date => p_effective_date,
         p_lf_evt_ocrd_dt => p_lf_evt_ocrd_dt,
         p_fonm_cvg_strt_dt  => ben_manage_life_events.g_fonm_cvg_strt_dt,
         p_fonm_rt_strt_dt  => ben_manage_life_events.g_fonm_rt_strt_dt,
         p_returned_date  => l_date_to_use);
      --
      -- 4204020 l_date_to_use := nvl(l_fonm_cvg_strt_dt,l_date_to_use);
      --
      <<dpnt>>
      for l_pdp_rec in c1(l_inst_dets(l_insttorrw_num).ptip_id,l_date_to_use ) loop
        --
        --  Check if the dependent have to be covered in the ptip where
        --  there are plans subject to cobra.
        --
        l_continue := true;
        --
        if l_inst_dets(l_insttorrw_num).only_pls_subj_cobra_flag = 'Y' then
          open c2(l_pdp_rec.pl_id, l_date_to_use );
          fetch c2 into l_dummy;
          if c2%notfound then
            l_continue := false;
          end if;
          close c2;
        end if;
        --
        if l_continue then
          l_found_ptip := true;
          --
          if l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
            l_ok := true;
            exit prfl;
          end if;
          --
          if l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
            l_ok := false;
            exit prfl;
          end if;
          --
        end if;
         --
      end loop dpnt;
      --
      if (l_found_ptip = false
         and l_inst_dets(l_insttorrw_num).excld_flag = 'Y') then
        l_ok := true;
        exit;
      end if;
      --
    end loop prfl;
    --
  end if;
  --
  if l_rows_found and
    not l_ok then
    --
    g_inelg_rsn_cd := 'EDT';
    fnd_message.set_name('BEN','BEN_92423_EDT_ELIG_PRFL_FAIL');
    hr_utility.set_location('Criteria Failed: '||l_proc,20);
    raise g_criteria_failed;
    --
  end if;
  --
  hr_utility.set_location('Leaving :'||l_proc,20);
  --
end check_elig_dpnt_cvrd_othr_ptip;
--
-- --------------------------------------------------------------------------
--  This procedure det elig based on dependent covered in another program.
-- --------------------------------------------------------------------------
procedure check_elig_dpnt_cvrd_othr_pgm(p_eligy_prfl_id     in number,
                                        p_business_group_id in number,
                                        p_person_id         in number,
                                        p_effective_date    in date,
                                        p_lf_evt_ocrd_dt    in date) is
  --
  l_proc             varchar2(100):=g_package||'check_elig_dpnt_cvrd_othr_pgm';
  l_inst_dets        ben_elp_cache.g_cache_elpedg_instor;
  l_inst_count       number;
  l_insttorrw_num    binary_integer;
  l_ok               boolean := false;
  l_rows_found       boolean := false;
  l_date_to_use      date;
  l_dummy            varchar2(1);
  --
  cursor c1(p_pgm_id in number) is
    select null
    from   ben_elig_cvrd_dpnt_f pdp,
           ben_prtt_enrt_rslt_f pen
    where  pen.business_group_id  = p_business_group_id
    and    pen.pgm_id = p_pgm_id
    and    pdp.dpnt_person_id = p_person_id
    and    l_date_to_use -- 5550851
           between pen.enrt_cvg_strt_dt
           and     pen.enrt_cvg_thru_dt
    and    pen.enrt_cvg_thru_dt <= pen.effective_end_date
    and    pdp.business_group_id  = pen.business_group_id
    and    pdp.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
    --and    pen.prtt_enrt_rslt_stat_cd not in ('BCKDT', 'VOIDD')
    and    pen.prtt_enrt_rslt_stat_cd is null
    and    l_date_to_use -- 5550851
           between pdp.cvg_strt_dt
           and     pdp.cvg_thru_dt
    and    pdp.effective_end_date = hr_api.g_eot;
  --
begin
  --
  hr_utility.set_location('Entering: '||l_proc, 10);
  --
  -- Getting eligibility profile compensation level by eligibility profile
  --
  ben_elp_cache.elpedg_getcacdets
    (p_effective_date    => nvl(l_fonm_cvg_strt_dt,nvl(p_lf_evt_ocrd_dt,p_effective_date)),
     p_business_group_id => p_business_group_id,
     p_eligy_prfl_id     => p_eligy_prfl_id,
     p_inst_set          => l_inst_dets,
     p_inst_count        => l_inst_count);
  --
  if l_inst_count > 0 then
    --
    -- Operation
    -- =========
    -- 1) Grab all profiles for this eligibility profile id
    -- 2) If the plan id is the same then check if the person was covered
    --    the day before the life event.
    --
    for l_insttorrw_num in l_inst_dets.first .. l_inst_dets.last loop
      --
      l_rows_found := true;
      --
      --
      -- Apply the date logic to the life event occurred date.
      --
      ben_determine_date.main
        (p_date_cd        => l_inst_dets(l_insttorrw_num).enrl_det_dt_cd,
         p_effective_date => p_effective_date,
         p_lf_evt_ocrd_dt => p_lf_evt_ocrd_dt,
         p_fonm_cvg_strt_dt  => ben_manage_life_events.g_fonm_cvg_strt_dt,
         p_fonm_rt_strt_dt  => ben_manage_life_events.g_fonm_rt_strt_dt,
         p_returned_date  => l_date_to_use);
      --
      open c1(l_inst_dets(l_insttorrw_num).pgm_id);
      fetch c1 into l_dummy;
      --
      if c1%found then
        --
        close c1;
        --
        if l_inst_dets(l_insttorrw_num).excld_flag = 'N' then
          l_ok := true;
          exit;
        end if;
        --
        if l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
          l_ok := false;
          exit;
        end if;
        --
      else
        --
        close c1;
        if l_inst_dets(l_insttorrw_num).excld_flag = 'Y' then
          l_ok := true;
          --exit ;
        end if;
      end if;
      --
    end loop;
    --
  end if;
  --
  if l_rows_found and
    not l_ok then
    --
    g_inelg_rsn_cd := 'EDG';
    fnd_message.set_name('BEN','BEN_92424_EDG_ELIG_PRFL_FAIL');
    hr_utility.set_location('Criteria Failed: '||l_proc,20);
    raise g_criteria_failed;
    --
  end if;
  --
  hr_utility.set_location('Leaving :'||l_proc,20);
  --
end check_elig_dpnt_cvrd_othr_pgm;
--
-- --------------------------------------------------------------------------
--  This procedure det elig based on cobra qualified benificiary status.
-- --------------------------------------------------------------------------
--
procedure check_elig_cbr_quald_bnf
        (p_eligy_prfl_id     in number,
         p_person_id         in number,
         p_business_group_id in number,
         p_lf_evt_ocrd_dt    in date,
         p_effective_date    in date) is
--
  l_proc             varchar2(100):=g_package||'check_elig_cbr_quald_bnf';
  l_inst_dets        ben_elp_cache.g_cache_elpecq_instor;
  l_quald_bnf_flag   ben_cbr_quald_bnf.quald_bnf_flag%type;
  l_cbr_elig_perd_strt_dt ben_cbr_quald_bnf.cbr_elig_perd_strt_dt%type;

  l_inst_count       number;
  l_insttorrw_num    binary_integer;
  l_ok               boolean := false;
  l_rows_found       boolean := false;
  l_rec              per_all_people_f%rowtype;
  --
  cursor c1(p_person_id      in number
           ,p_lf_evt_ocrd_dt in date
           ,p_pgm_id         in number
           ,p_ptip_id        in number) is
    select cqb.quald_bnf_flag
          ,cqb.cbr_elig_perd_strt_dt
    from  ben_cbr_quald_bnf cqb
         ,ben_cbr_per_in_ler crp
         ,ben_per_in_ler pil
    where cqb.quald_bnf_person_id = p_person_id
    -- lamc added these next 2 lines
    and cqb.pgm_id = nvl(p_pgm_id,cqb.pgm_id)
    and nvl(cqb.ptip_id,-1) = nvl(p_ptip_id, -1)
    --
    and nvl(p_lf_evt_ocrd_dt,p_effective_date)
    between cqb.cbr_elig_perd_strt_dt
    and     cqb.cbr_elig_perd_end_dt
    and cqb.business_group_id  = p_business_group_id
    and cqb.cbr_quald_bnf_id = crp.cbr_quald_bnf_id
    and crp.per_in_ler_id = pil.per_in_ler_id
    and crp.business_group_id = cqb.business_group_id
 --   and pil.business_group_id = crp.business_group_id
    and crp.init_evt_flag = 'Y'
    and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
    order by cbr_elig_perd_strt_dt desc;  -- 8463981

  --
begin
  --
  hr_utility.set_location('Entering: '||l_proc, 10);
  --
  -- Getting eligibility profile compensation level by eligibility profile
  --
  ben_elp_cache.elpecq_getcacdets
    (p_effective_date    => nvl(p_lf_evt_ocrd_dt,p_effective_date),
     p_business_group_id => p_business_group_id,
     p_eligy_prfl_id     => p_eligy_prfl_id,
     p_inst_set          => l_inst_dets,
     p_inst_count        => l_inst_count);
  --
  if l_inst_count > 0 then
    --
    -- Operation
    -- =========
    -- 1) Grab all profiles for this eligibility profile id
    -- 2) If the leaving reason code is excluded then person is not eligible
    -- 3) If the leaving reason code is not excluded then person is eligible.
    --
    for l_insttorrw_num in l_inst_dets.first .. l_inst_dets.last loop
      --
      l_rows_found := true;
      --
      open c1(p_person_id
             ,p_lf_evt_ocrd_dt
             ,l_inst_dets(l_insttorrw_num).pgm_id
             ,l_inst_dets(l_insttorrw_num).ptip_id);
      fetch c1 into l_quald_bnf_flag
                   ,l_cbr_elig_perd_strt_dt; -- 8463981
      if c1%found then
        l_ok := nvl((nvl(l_quald_bnf_flag,'-1') = l_inst_dets(l_insttorrw_num).quald_bnf_flag),FALSE);
      else
        l_ok := nvl((l_inst_dets(l_insttorrw_num).quald_bnf_flag = 'N'),FALSE);
      end if;
      close c1;
      --if l_ok is null then
      --  l_ok:=false;
      if l_ok then
        exit;
      end if;
    end loop;
    --
  end if;
  --
  if l_rows_found and
    not l_ok then
    --
    g_inelg_rsn_cd := 'ECQ';
    fnd_message.set_name('BEN','BEN_92425_ECQ_ELIG_PRFL_FAIL');
    hr_utility.set_location('Criteria Failed: '||l_proc,20);
    raise g_criteria_failed;
    --
  end if;
  --
  hr_utility.set_location('Leaving :'||l_proc,20);
  --
end check_elig_cbr_quald_bnf;
-- ----------------------------------------------------------------------------
-- Disabled
-- ----------------------------------------------------------------------------
procedure check_dsbld_elig
  (p_eligy_prfl_id  in number
  ,p_effective_date in date
  ,p_score_compute_mode in boolean default false
  ,p_profile_score_tab in out nocopy scoreTab
  ,p_dsbld_cd       in varchar2
  )
is
  --
  l_proc          varchar2(100) := g_package||'check_dsbld_elig';
  --
  l_inst_set      ben_elp_cache.g_elp_cache := ben_elp_cache.g_elp_cache();
  l_ok            boolean := false;
  l_rows_found    boolean := false;
  l_ele_num       pls_integer;
  l_crit_passed     boolean;
  l_score_tab       scoreTab;
  --
begin
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  ben_elp_cache.elpeds_getdets
    (p_effective_date => p_effective_date
    ,p_eligy_prfl_id  => p_eligy_prfl_id
    --
    ,p_inst_set       => l_inst_set
    );
  --
  if l_inst_set.count > 0 then
    --
    l_ele_num := 1;
    --
    for i in l_inst_set.first .. l_inst_set.last loop
      --
      l_rows_found := true;
      --
      l_ok := nvl((nvl(p_dsbld_cd,'xxxx') = l_inst_set(l_ele_num).v230_val),FALSE);
      --
      if l_ok and l_inst_set(l_ele_num).excld_flag = 'N' then
        --
        hr_utility.set_location('Exclude Flag = N, Disabled Code = ' || p_dsbld_cd || ' found ', 20 );
        if p_score_compute_mode then
           if l_crit_passed is null then
              l_crit_passed := true;
           end if;
           write(l_score_tab,
                 l_inst_set(l_ele_num).eligy_prfl_id,
                 l_inst_set(l_ele_num).short_code,
                 l_inst_set(l_ele_num).pk_id,
                 nvl(l_inst_set(l_ele_num).criteria_score,
                 l_inst_set(l_ele_num).criteria_weight));
        else
           exit;
        end if;
        --
      elsif l_ok and l_inst_set(l_ele_num).excld_flag = 'Y' then
        --
        hr_utility.set_location('Exclude Flag = Y, Disabled Code = ' || p_dsbld_cd || ' found ', 20 );
        l_ok := false;
        exit;
        --
      elsif (not l_ok) and l_inst_set(l_ele_num).excld_flag = 'Y' then
        --
        l_ok := true;
        if p_score_compute_mode then
           write(l_score_tab,
                 l_inst_set(l_ele_num).eligy_prfl_id,
                 l_inst_set(l_ele_num).short_code,
                 l_inst_set(l_ele_num).pk_id,
                 nvl(l_inst_set(l_ele_num).criteria_score,
                 l_inst_set(l_ele_num).criteria_weight));
        end if;
        --
      end if;
      --
      l_ele_num := l_ele_num+1;
      --
    end loop;
    --
    -- clean up varray since it is no longer required
    --
    l_inst_set.delete;
    --
  end if;
  --
  if l_crit_passed is null
  then
     if l_rows_found
       and not l_ok
     then
       --
       g_inelg_rsn_cd := 'DSB';
       fnd_message.set_name('BEN','BEN_93080_DSBLD_PRFL_FAIL');
       hr_utility.set_location('Criteria Failed: '||l_proc,40);
       raise g_criteria_failed;
       --
     end if;
  end if;
  --
  if p_score_compute_mode
  then
     hr_utility.set_location('count '||l_score_tab.count,20);
     write(p_profile_score_tab,l_score_tab);
  end if;
  hr_utility.set_location('Leaving: '||l_proc,50);
  --
end check_dsbld_elig;
--
-- ----------------------------------------------------------------------------
-- Tobacco Use
-- ----------------------------------------------------------------------------
procedure check_tbco_use_elig
  (p_eligy_prfl_id  in number
  ,p_effective_date in date
  ,p_score_compute_mode in boolean default false
  ,p_profile_score_tab in out nocopy scoreTab
  ,p_tbco_use_flag  in varchar2
  )
is
  --
  l_proc          varchar2(100) := g_package||'check_tbco_use_elig';
  --
  l_inst_set      ben_elp_cache.g_elp_cache := ben_elp_cache.g_elp_cache();
  l_ok            boolean := false;
  l_rows_found    boolean := false;
  l_ele_num       pls_integer;
  l_crit_passed     boolean;
  l_score_tab       scoreTab;
  --
begin
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  ben_elp_cache.elpetu_getdets
    (p_effective_date => p_effective_date
    ,p_eligy_prfl_id  => p_eligy_prfl_id
    --
    ,p_inst_set       => l_inst_set
    );
  --
  if l_inst_set.count > 0 then
    --
    l_ele_num := 1;
    --
    for i in l_inst_set.first .. l_inst_set.last loop
      --
      l_rows_found := true;
      --
      l_ok := nvl((nvl(p_tbco_use_flag,'xxxx') = l_inst_set(l_ele_num).v230_val),FALSE);
      --
      if l_ok and l_inst_set(l_ele_num).excld_flag = 'N' then
        --
        hr_utility.set_location('Exclude Flag = N, Tobacco Use = ' || p_tbco_use_flag || ' found ', 20 );
        if p_score_compute_mode then
           if l_crit_passed is null then
              l_crit_passed := true;
           end if;
           write(l_score_tab,
                 l_inst_set(l_ele_num).eligy_prfl_id,
                 l_inst_set(l_ele_num).short_code,
                 l_inst_set(l_ele_num).pk_id,
                 nvl(l_inst_set(l_ele_num).criteria_score,
                 l_inst_set(l_ele_num).criteria_weight));
        else
           exit;
        end if;
        --
      elsif l_ok and l_inst_set(l_ele_num).excld_flag = 'Y' then
        --
        hr_utility.set_location('Exclude Flag = Y, Tobacco Use = ' || p_tbco_use_flag || ' found ', 20 );
        l_ok := false;
        exit;
        --
      elsif (not l_ok) and l_inst_set(l_ele_num).excld_flag = 'Y' then
        --
        l_ok := true;
        --
        if p_score_compute_mode then
           write(l_score_tab,
                 l_inst_set(l_ele_num).eligy_prfl_id,
                 l_inst_set(l_ele_num).short_code,
                 l_inst_set(l_ele_num).pk_id,
                 nvl(l_inst_set(l_ele_num).criteria_score,
                 l_inst_set(l_ele_num).criteria_weight));
        end if;
      end if;
      --
      l_ele_num := l_ele_num+1;
      --
    end loop;
    --
    -- clean up varray since it is no longer required
    --
    l_inst_set.delete;
    --
  end if;
  --
  if l_crit_passed is null
  then
     if l_rows_found
       and not l_ok
     then
       --
       g_inelg_rsn_cd := 'ETU';
       fnd_message.set_name('BEN','BEN_93081_TBCO_USE_PRFL_FAIL');
       hr_utility.set_location('Criteria Failed: '||l_proc,40);
       raise g_criteria_failed;
       --
     end if;
  end if;
  --
  if p_score_compute_mode
  then
     hr_utility.set_location('count '||l_score_tab.count,20);
     write(p_profile_score_tab,l_score_tab);
  end if;
  hr_utility.set_location('Leaving: '||l_proc,50);
  --
end check_tbco_use_elig;
--
-- ----------------------------------------------------------------------------
-- Total Coverage Volume
-- ----------------------------------------------------------------------------
procedure check_ttl_cvg_vol_elig
        (p_eligy_prfl_id     in number,
         p_business_group_id in number,
         p_person_id         in number,
         p_ttl_cvg           in number,
         p_lf_evt_ocrd_dt    in date,
         p_effective_date    in date) is
--
  l_proc          varchar2(100):=g_package||'.check_ttl_cvg_vol_elig';
  --
  l_inst_set      ben_elp_cache.g_elp_cache := ben_elp_cache.g_elp_cache();
  l_ok            boolean := false;
  l_rows_found    boolean := false;
  l_ele_num       pls_integer;
  --
  l_ttl_cvg_vol   number ;
  l_dummy	  char;
  --
  l_eot		  date := hr_api.g_eot;
  --
  cursor c_bnft_amt(cp_lf_evt_ocrd_dt in date ,
  		    cp_effective_date in date ,
                    cp_business_group_id in number) is
    select sum(nvl(pen.bnft_amt,0))
    from   ben_prtt_enrt_rslt_f pen
    where pen.business_group_id = cp_business_group_id
    and nvl(cp_lf_evt_ocrd_dt,cp_effective_date)
             between pen.enrt_cvg_strt_dt and pen.enrt_cvg_thru_dt
    and pen.sspndd_flag = 'N'
    and pen.prtt_enrt_rslt_stat_cd is null
    and pen.effective_end_date = l_eot;
  --
  cursor c_pen_found(cp_lf_evt_ocrd_dt in date ,	-- bug 2431619
  		     cp_effective_date in date ,
  		     cp_person_id      in number,
                     cp_business_group_id in number) is
    select null
    from   ben_prtt_enrt_rslt_f pen
    where pen.person_id = cp_person_id
    and pen.business_group_id = cp_business_group_id
    and nvl(cp_lf_evt_ocrd_dt,cp_effective_date)
             between pen.enrt_cvg_strt_dt and pen.enrt_cvg_thru_dt
    and pen.sspndd_flag = 'N'
    and pen.prtt_enrt_rslt_stat_cd is null
    and pen.effective_end_date = l_eot;
  --
begin
  --
  hr_utility.set_location('Entering: '||l_proc, 10);
  --
  ben_elp_cache.elpetc_getdets
  (p_effective_date => nvl(l_fonm_cvg_strt_dt,p_effective_date)
  ,p_eligy_prfl_id  => p_eligy_prfl_id
  --
  ,p_inst_set       => l_inst_set
  );
  --
  if l_inst_set.count > 0 then
    --
    if p_ttl_cvg is not null then
       l_ttl_cvg_vol := p_ttl_cvg;
    else
       open c_bnft_amt(nvl(l_fonm_cvg_strt_dt,p_lf_evt_ocrd_dt) ,
       		    p_effective_date ,
                       p_business_group_id ) ;
       fetch c_bnft_amt into l_ttl_cvg_vol ;
       close c_bnft_amt ;
    end if;

    l_ele_num := 1;

    --
    for i in l_inst_set.first .. l_inst_set.last loop
      --
      l_rows_found := true;
      --
      if nvl(l_ttl_cvg_vol,0)
          between nvl(l_inst_set(l_ele_num).num_val,0)
          and nvl(l_inst_set(l_ele_num).num_val1 - 1 , 999999999999999)		-- 2431619
      then
    	  hr_utility.set_location(l_proc, 20);
          l_ok := true;
          exit;
          --
      elsif nvl(l_ttl_cvg_vol,0) = nvl(l_inst_set(l_ele_num).num_val1, 999999999999999) then	-- bug 2431619
          --
	  open c_pen_found(nvl(l_fonm_cvg_strt_dt,p_lf_evt_ocrd_dt) ,
    		           p_effective_date ,
    		           p_person_id ,
                           p_business_group_id ) ;
          fetch c_pen_found into l_dummy;
          if c_pen_found%found then
            --
    	    hr_utility.set_location(l_proc, 30);
            close c_pen_found;
            l_ok := true;
            exit;
            --
          else
            --
    	    hr_utility.set_location(l_proc, 40);
            close c_pen_found;
            l_ok := false;
            --
          end if;
          --							-- end 2431619
      else
          --
    	  hr_utility.set_location(l_proc, 50);
          l_ok := false;
          --
      end if;
      --
      l_ele_num := l_ele_num + 1;
      --
    end loop;
    --
  end if;
  --
  if l_rows_found
    and not l_ok
  then
    --
    g_inelg_rsn_cd := 'ETC';
    fnd_message.set_name('BEN','BEN_93082_TTLCVGVOL_PRFL_FAIL');
    hr_utility.set_location('Criteria Failed: '||l_proc,60);
    raise g_criteria_failed;
    --
  end if;
  --
  hr_utility.set_location('Leaving: '||l_proc,50);
  --
end check_ttl_cvg_vol_elig;
--
-- ----------------------------------------------------------------------------
-- Total Participants
-- ----------------------------------------------------------------------------
procedure check_ttl_prtt_elig
        (p_eligy_prfl_id     in number,
         p_business_group_id in number,
         p_person_id         in number,
         p_ttl_prtt          in number,
         p_lf_evt_ocrd_dt    in date,
         p_effective_date    in date) is
--
  l_proc          varchar2(100):=g_package||'.check_ttl_prtt_elig';
  --
  l_inst_set      ben_elp_cache.g_elp_cache := ben_elp_cache.g_elp_cache();
  l_ok            boolean := false;
  l_rows_found    boolean := false;
  l_ele_num       pls_integer;
  --
  l_ttl_prtt      number ;
  l_dummy	  char;
  --
  l_eot		  date := hr_api.g_eot;
  --
  cursor c_ttl_prtt(cp_lf_evt_ocrd_dt in date ,
  		    cp_effective_date in date ,
                    cp_business_group_id in number) is
    select count(pen.prtt_enrt_rslt_id)
    from   ben_prtt_enrt_rslt_f pen
    where pen.business_group_id = cp_business_group_id
    and nvl(cp_lf_evt_ocrd_dt,cp_effective_date)
             between pen.enrt_cvg_strt_dt and pen.enrt_cvg_thru_dt
    and pen.sspndd_flag = 'N'
    and pen.prtt_enrt_rslt_stat_cd is null
    and pen.effective_end_date = l_eot;
  --
  cursor c_pen_found(cp_lf_evt_ocrd_dt in date ,	-- bug 2431619
  		     cp_effective_date in date ,
  		     cp_person_id      in number,
                     cp_business_group_id in number) is
    select null
    from   ben_prtt_enrt_rslt_f pen
    where pen.person_id = cp_person_id
    and pen.business_group_id = cp_business_group_id
    and nvl(cp_lf_evt_ocrd_dt,cp_effective_date)
             between pen.enrt_cvg_strt_dt and pen.enrt_cvg_thru_dt
    and pen.sspndd_flag = 'N'
    and pen.prtt_enrt_rslt_stat_cd is null
    and pen.effective_end_date = l_eot;
  --
begin
  --
  hr_utility.set_location('Entering: '||l_proc, 10);
  --
  ben_elp_cache.elpetp_getdets
  (p_effective_date => nvl(l_fonm_cvg_strt_dt,p_effective_date)
  ,p_eligy_prfl_id  => p_eligy_prfl_id
  --
  ,p_inst_set       => l_inst_set
  );
  --
  if l_inst_set.count > 0 then
    --
    if p_ttl_prtt is not null then
       l_ttl_prtt := p_ttl_prtt;
    else
       open c_ttl_prtt(nvl(l_fonm_cvg_strt_dt,p_lf_evt_ocrd_dt) ,
       		    p_effective_date ,
                       p_business_group_id ) ;
       fetch c_ttl_prtt into l_ttl_prtt ;
       close c_ttl_prtt ;
    end if;

    l_ele_num := 1;
    --
    for i in l_inst_set.first .. l_inst_set.last loop
      --
      l_rows_found := true;
      --
      hr_utility.set_location('l_ttl_prtt ' || l_ttl_prtt || ' num_val1 ' || l_inst_set(l_ele_num).num_val1, -729);
      if nvl(l_ttl_prtt,0)
          between nvl(l_inst_set(l_ele_num).num_val,0)
          and nvl(l_inst_set(l_ele_num).num_val1 - 1 , 999999999999999)		-- bug 2431619
      then
    	  hr_utility.set_location(l_proc, 20);
          l_ok := true;
          exit;
          --
      elsif nvl(l_ttl_prtt,0) = nvl(l_inst_set(l_ele_num).num_val1, 999999999999999) then	-- bug 2431619
          --
	  open c_pen_found(nvl(l_fonm_cvg_strt_dt,p_lf_evt_ocrd_dt) ,
    		           p_effective_date ,
    		           p_person_id ,
                           p_business_group_id ) ;
          fetch c_pen_found into l_dummy;
          if c_pen_found%found then
            --
    	    hr_utility.set_location(l_proc, 30);
            close c_pen_found;
            l_ok := true;
            exit;
            --
          else
            --
    	    hr_utility.set_location(l_proc, 40);
            close c_pen_found;
            l_ok := false;
            --
          end if;
          --							-- end 2431619
      else
          --
    	  hr_utility.set_location(l_proc, 50);
          l_ok := false;
          --
      end if;
      --
      l_ele_num := l_ele_num+1;
      --
    end loop;
    --
  end if;
  --
  if l_rows_found
    and not l_ok
  then
    --
    g_inelg_rsn_cd := 'ETP';
    fnd_message.set_name('BEN','BEN_93083_TTL_PRTT_PRFL_FAIL');
    hr_utility.set_location('Criteria Failed: '||l_proc,60);
    raise g_criteria_failed;
    --
  end if;
  --
  hr_utility.set_location('Leaving: '||l_proc,50);
  --
end check_ttl_prtt_elig;
--
-- ----------------------------------------------------------------------------
-- Participation in Another Plan
-- ----------------------------------------------------------------------------
procedure check_anthr_pl_elig
        (p_eligy_prfl_id     in number,
         p_business_group_id in number,
         p_person_id         in number,
         p_lf_evt_ocrd_dt    in date,
         p_effective_date    in date) is
--
  l_proc          varchar2(100):=g_package||'.check_anthr_pl_elig';
  --
  l_inst_set      ben_elp_cache.g_elp_cache := ben_elp_cache.g_elp_cache();
  l_ok            boolean := false;
  l_rows_found    boolean := false;
  l_ele_num       pls_integer;
  --
  l_dummy         char ;
  --
  l_eot		  date := hr_api.g_eot;
  --
  cursor c_prtt_in_pl(cp_person_id         in number,
  		      cp_pl_id             in number,
  		      cp_lf_evt_ocrd_dt    in date ,
  		      cp_effective_date    in date ,
                      cp_business_group_id in number) is
    select null
    from   ben_prtt_enrt_rslt_f pen
    where pen.business_group_id = cp_business_group_id
    and pen.person_id = cp_person_id
    and pen.pl_id = cp_pl_id
    and nvl(cp_lf_evt_ocrd_dt,cp_effective_date)
             between pen.enrt_cvg_strt_dt and pen.enrt_cvg_thru_dt
    and pen.sspndd_flag = 'N'
    and pen.prtt_enrt_rslt_stat_cd is null
    and pen.effective_end_date = l_eot;
  --
begin
  --
  hr_utility.set_location('Entering: '||l_proc, 10);
  --
  ben_elp_cache.elpeop_getdets
  (p_effective_date => p_effective_date
  ,p_eligy_prfl_id  => p_eligy_prfl_id
  --
  ,p_inst_set       => l_inst_set
  );
  --
  if l_inst_set.count > 0 then
    --
    l_ele_num := 1;
    --
    for i in l_inst_set.first .. l_inst_set.last loop
      --
      l_rows_found := true;
      --
      open c_prtt_in_pl(p_person_id,
      		    l_inst_set(l_ele_num).num_val,
      		    p_lf_evt_ocrd_dt ,
      		    p_effective_date ,
                    p_business_group_id ) ;
      fetch c_prtt_in_pl into l_dummy ;
      --
      if c_prtt_in_pl%found then
        l_ok := true;
      else
        l_ok := false;
      end if;
      --
      close c_prtt_in_pl ;
      --
      --
      if l_ok and l_inst_set(l_ele_num).excld_flag = 'N' then
        --
        hr_utility.set_location('Exclude Flag = N, Participation in Plan id = ' || l_inst_set(l_ele_num).num_val || ' found ', 20 );
        exit;
        --
      elsif l_ok and l_inst_set(l_ele_num).excld_flag = 'Y' then
        --
        hr_utility.set_location('Exclude Flag = Y, Participation in Plan id = ' || l_inst_set(l_ele_num).num_val || ' found ', 20 );
        l_ok := false;
        exit;
        --
      elsif (not l_ok) and l_inst_set(l_ele_num).excld_flag = 'Y' then
        --
        l_ok := true;
        --
      end if;
      --
      l_ele_num := l_ele_num+1;
      --
    end loop;
    --
  end if;
  --
  if l_rows_found
    and not l_ok
  then
    --
    g_inelg_rsn_cd := 'EOP';
    fnd_message.set_name('BEN','BEN_93084_ANTHR_PL_PRFL_FAIL');
    hr_utility.set_location('Criteria Failed: '||l_proc,40);
    raise g_criteria_failed;
    --
  end if;
  --
  hr_utility.set_location('Leaving: '||l_proc,50);
  --
end check_anthr_pl_elig;
--
-- ----------------------------------------------------------------------------
-- Health Coverage Selected
-- ----------------------------------------------------------------------------
procedure check_hlth_cvg_elig
        (p_eligy_prfl_id     in number,
         p_business_group_id in number,
         p_person_id         in number,
         p_lf_evt_ocrd_dt    in date,
         p_effective_date    in date) is
--
  l_proc          varchar2(100):=g_package||'.check_hlth_cvg_elig';
  --
  l_inst_set      ben_elp_cache.g_elp_cache := ben_elp_cache.g_elp_cache();
  l_ok            boolean := false;
  l_rows_found    boolean := false;
  l_ele_num       pls_integer;
  --
  l_dummy         char ;
  --
  l_eot		  date := hr_api.g_eot;
  --
  cursor c_prtt_in_oipl(cp_person_id         in number,
  		      cp_pl_typ_opt_typ_id in number,
  		      cp_oipl_id           in number,
  		      cp_lf_evt_ocrd_dt    in date ,
  		      cp_effective_date    in date ,
                      cp_business_group_id in number) is
    select null
    from  ben_prtt_enrt_rslt_f pen
    	, ben_pl_typ_opt_typ_f pto
    where pto.pl_typ_opt_typ_id = cp_pl_typ_opt_typ_id
    and pto.business_group_id = cp_business_group_id
    and nvl(cp_lf_evt_ocrd_dt,cp_effective_date)
             between pto.effective_start_date and pto.effective_end_date
    and pen.person_id = cp_person_id
    and pen.pl_typ_id = pto.pl_typ_id
    and pen.oipl_id = cp_oipl_id
    and pen.business_group_id = cp_business_group_id
    and nvl(cp_lf_evt_ocrd_dt,cp_effective_date)
             between pen.enrt_cvg_strt_dt and pen.enrt_cvg_thru_dt
    and pen.sspndd_flag = 'N'
    and pen.prtt_enrt_rslt_stat_cd is null
    and pen.effective_end_date = l_eot;

  --
begin
  --
  hr_utility.set_location('Entering: '||l_proc, 10);
  --
  ben_elp_cache.elpehc_getdets
  (p_effective_date => nvl(l_fonm_cvg_strt_dt,p_effective_date)
  ,p_eligy_prfl_id  => p_eligy_prfl_id
  --
  ,p_inst_set       => l_inst_set
  );
  --
  if l_inst_set.count > 0 then
    --
    l_ele_num := 1;
    --
    for i in l_inst_set.first .. l_inst_set.last loop
      --
      l_rows_found := true;
      --
      open c_prtt_in_oipl(p_person_id,
      		    l_inst_set(l_ele_num).num_val,
      		    l_inst_set(l_ele_num).num_val1,
      		    nvl(l_fonm_cvg_strt_dt,p_lf_evt_ocrd_dt) ,
      		    p_effective_date ,
                    p_business_group_id ) ;
      fetch c_prtt_in_oipl into l_dummy ;
      --
      if c_prtt_in_oipl%found then
        l_ok := true;
      else
        l_ok := false;
      end if;
      --
      close c_prtt_in_oipl ;
      --
      --
      if l_ok and l_inst_set(l_ele_num).excld_flag = 'N' then
        --
        hr_utility.set_location('Exclude Flag = N, Health Coverage in OIPL id = ' || l_inst_set(l_ele_num).num_val1 || ' found ', 20 );
        exit;
        --
      elsif l_ok and l_inst_set(l_ele_num).excld_flag = 'Y' then
        --
        hr_utility.set_location('Exclude Flag = Y, Health Coverage in OIPL id = ' || l_inst_set(l_ele_num).num_val1 || ' found ', 20 );
        l_ok := false;
        exit;
        --
      elsif (not l_ok) and l_inst_set(l_ele_num).excld_flag = 'Y' then
        --
        l_ok := true;
        --
      end if;
      --
      l_ele_num := l_ele_num+1;
      --
    end loop;
    --
  end if;
  --
  if l_rows_found
    and not l_ok
  then
    --
    g_inelg_rsn_cd := 'EHC';
    fnd_message.set_name('BEN','BEN_93085_HLTH_CVG_PRFL_FAIL');
    hr_utility.set_location('Criteria Failed: '||l_proc,40);
    raise g_criteria_failed;
    --
  end if;
  --
  hr_utility.set_location('Leaving: '||l_proc,50);
  --
end check_hlth_cvg_elig;
--
-- ----------------------------------------------------------------------------
-- Competency
-- ----------------------------------------------------------------------------
procedure check_comptncy_elig
        (p_eligy_prfl_id     in number,
         p_business_group_id in number,
         p_person_id         in number,
         p_competence_id     in number default null,
         p_rating_level_id   in number default null,
         p_score_compute_mode in boolean default false,
         p_profile_score_tab in out nocopy scoreTab,
         p_lf_evt_ocrd_dt    in date,
         p_effective_date    in date) is
--
  l_proc          varchar2(100):=g_package||'.check_comptncy_elig';
  --
  l_inst_set      ben_elp_cache.g_elp_cache := ben_elp_cache.g_elp_cache();
  l_ok            boolean := false;
  l_rows_found    boolean := false;
  l_ele_num       pls_integer;
  l_effective_date date;
  l_crit_passed     boolean;
  l_score_tab       scoreTab;
  --
  l_dummy         char ;
  --
  cursor c_competency(cp_person_id         in number,
  		      cp_competence_id     in number,
  		      cp_rating_level_id   in number,
  		      cp_effective_date    in date ,
                      cp_business_group_id in number) is
    select null
    from  per_competence_elements cmp
    where cmp.person_id = cp_person_id
    and cmp.type = 'PERSONAL'
    and cmp.competence_id = cp_competence_id
    and cmp.proficiency_level_id = cp_rating_level_id
    and cmp.business_group_id = cp_business_group_id
    and cp_effective_date
             between nvl(cmp.effective_date_from, cp_effective_date)
             	and  nvl(cmp.effective_date_to, cp_effective_date) ;
  --
begin
  --
  hr_utility.set_location('Entering: '||l_proc, 10);
  --
  ben_elp_cache.elpecy_getdets
  (p_effective_date => nvl(l_fonm_cvg_strt_dt,p_effective_date)
  ,p_eligy_prfl_id  => p_eligy_prfl_id
  --
  ,p_inst_set       => l_inst_set
  );
  --
  if l_inst_set.count > 0 then
    --
    l_ele_num := 1;
    --
    for i in l_inst_set.first .. l_inst_set.last loop
      --
      l_rows_found := true;
      --
      l_effective_date := nvl(l_fonm_cvg_strt_dt,nvl(p_lf_evt_ocrd_dt,p_effective_date));
      if p_competence_id is null then
         open c_competency(p_person_id,
         		    l_inst_set(l_ele_num).num_val,
         		    l_inst_set(l_ele_num).num_val1,
         		    l_effective_date ,
                       p_business_group_id ) ;
         fetch c_competency into l_dummy ;
         --
         if c_competency%found then
           l_ok := true;
         else
           l_ok := false;
         end if;
         --
         close c_competency ;
      else
         if p_competence_id = l_inst_set(l_ele_num).num_val and
            p_rating_level_id = l_inst_set(l_ele_num).num_val1 then
            l_ok := true;
         else
            l_ok := false;
         end if;
      end if;
      --
      --
      if l_ok and l_inst_set(l_ele_num).excld_flag = 'N' then
        --
        hr_utility.set_location('Exclude Flag = N, Competence ' || l_inst_set(l_ele_num).num_val || ' and Rating level ' || l_inst_set(l_ele_num).num_val1 || ' found ', 20 );
        if p_score_compute_mode then
           if l_crit_passed is null then
              l_crit_passed := true;
           end if;
           write(l_score_tab,
                 l_inst_set(l_ele_num).eligy_prfl_id,
                 l_inst_set(l_ele_num).short_code,
                 l_inst_set(l_ele_num).pk_id,
                 nvl(l_inst_set(l_ele_num).criteria_score,
                 l_inst_set(l_ele_num).criteria_weight));
        else
           exit;
        end if;
        --
      elsif l_ok and l_inst_set(l_ele_num).excld_flag = 'Y' then
        --
        hr_utility.set_location('Exclude Flag = Y, Competence ' || l_inst_set(l_ele_num).num_val || ' and Rating level ' || l_inst_set(l_ele_num).num_val1 || ' found ', 20 );
        l_ok := false;
        exit;
        --
      elsif (not l_ok) and l_inst_set(l_ele_num).excld_flag = 'Y' then
        --
        l_ok := true;
        --
        if p_score_compute_mode then
           write(l_score_tab,
                 l_inst_set(l_ele_num).eligy_prfl_id,
                 l_inst_set(l_ele_num).short_code,
                 l_inst_set(l_ele_num).pk_id,
                 nvl(l_inst_set(l_ele_num).criteria_score,
                 l_inst_set(l_ele_num).criteria_weight));
        end if;
      end if;
      --
      l_ele_num := l_ele_num+1;
      --
    end loop;
    --
  end if;
  --
  if l_crit_passed is null
  then
     if l_rows_found
       and not l_ok
     then
       --
       g_inelg_rsn_cd := 'ECY';
       fnd_message.set_name('BEN','BEN_93086_COMPTNCY_PRFL_FAIL');
       hr_utility.set_location('Criteria Failed: '||l_proc,40);
       raise g_criteria_failed;
       --
     end if;
  end if;
  --
  if p_score_compute_mode
  then
     hr_utility.set_location('count '||l_score_tab.count,20);
     write(p_profile_score_tab,l_score_tab);
  end if;
  hr_utility.set_location('Leaving: '||l_proc,50);
  --
end check_comptncy_elig;
--
-- ----------------------------------------------------------------------------
-- Performance Rating
-- ----------------------------------------------------------------------------
procedure check_perf_rtng_elig
        (p_eligy_prfl_id     in number,
         p_business_group_id in number,
         p_person_id         in number,
         p_perf_rtng_cd      in varchar2 default null,
         p_event_type        in varchar2 default null,
         p_score_compute_mode in boolean default false,
         p_profile_score_tab in out nocopy scoreTab,
         p_lf_evt_ocrd_dt    in date,
         p_effective_date    in date) is
--

  l_proc          varchar2(100):=g_package||'.check_perf_rtng_elig';
  --
  l_inst_set      ben_elp_cache.g_elp_cache := ben_elp_cache.g_elp_cache();
  l_ok            boolean := false;
  l_rows_found    boolean := false;
  l_ele_num       pls_integer;
  l_crit_passed     boolean;
  l_score_tab       scoreTab;
  --
  l_dummy         varchar2(10) ;
  --
  l_performance_rating   varchar2(80);
  --
  CURSOR c1 (
     p_person_id            NUMBER,
     p_event_type           VARCHAR2,
     p_business_group_id    NUMBER,
     p_effective_date       DATE
  )
  IS
     SELECT ppr.performance_rating
       FROM per_performance_reviews ppr,
            per_events pev,
            per_all_assignments_f asg
      WHERE pev.assignment_id = asg.assignment_id
        AND pev.TYPE = p_event_type
        AND pev.business_group_id = p_business_group_id
        AND p_effective_date BETWEEN NVL (pev.date_start,
                                          p_effective_date)
                                 AND NVL (pev.date_end, p_effective_date)
        AND ppr.event_id = pev.event_id
        -- AND ppr.performance_rating = p_performance_rating
        AND p_effective_date BETWEEN NVL (asg.effective_start_date,
                                          p_effective_date
                                         )
                                 AND NVL (asg.effective_end_date,
                                          p_effective_date
                                         )
        AND asg.business_group_id = p_business_group_id
        AND asg.primary_flag = 'Y'
        AND asg.person_id = ppr.person_id
        AND ppr.person_id = p_person_id
   ORDER BY pev.date_start desc, ppr.review_date desc;
  --
  /* Bug 4031314
   * If ELPRO criteria does not specify Performance Type then we would select
   * only those performance reviews which do have Performance (Interview) Type
   * as NULL i.e PPR.EVENT_ID IS NULL
   */
  CURSOR c2_without_events (
     p_person_id            NUMBER,
     p_effective_date       DATE
  )
  IS
     SELECT ppr.performance_rating
       FROM per_performance_reviews ppr
      WHERE ppr.person_id = p_person_id
        AND ppr.review_date <= p_effective_date
        AND ppr.event_id IS NULL
   ORDER BY ppr.review_date desc;
  --
begin
  --
  hr_utility.set_location('Entering: '||l_proc, 10);
  --
  if p_perf_rtng_cd is null then
     ben_elp_cache.elpepr_getdets
     (p_effective_date => p_effective_date
     ,p_eligy_prfl_id  => p_eligy_prfl_id
     --
     ,p_inst_set       => l_inst_set
     );
  else
     l_inst_set(1).v230_val := p_perf_rtng_cd;
     if p_event_type is null then
        l_inst_set(1).v230_val1 := '-1';
     else
        l_inst_set(1).v230_val1 := p_event_type;
     end if;
     l_inst_set(1).excld_flag := 'N';

  end if;
  --
  if l_inst_set.count > 0 then
    --
    l_ele_num := 1;
    --
    for i in l_inst_set.first .. l_inst_set.last loop
      --
      l_rows_found := true;
      --
      /* Bug 4031314
       * - When BEN_ELIG_PERF_RTNG_PRTE_F.EVENT_TYPE = '-1', then fetch performance reviews
       *   that have Performance (Interview) Type as NULL.
       * - When BEN_ELIG_PERF_RTNG_PRTE_F.EVENT_TYPE is not '-1', then fetch performanc reviews
       *   with Performance Type as defined in ELPRO criteria
       */
      if l_inst_set(l_ele_num).v230_val1 = '-1'
      then
        --
        if p_perf_rtng_cd is not null then
           if p_perf_rtng_cd =l_inst_set(l_ele_num).v230_val
           then
             --
             l_ok := true;
             --
           else
             --
             l_ok := false;
             --
           end if;
           --
        else
           open c2_without_events(
                   p_person_id          => p_person_id
          	       ,p_effective_date     => nvl(p_lf_evt_ocrd_dt, p_effective_date)
           );
             --
             fetch c2_without_events into l_performance_rating;
             --
             if c2_without_events%found and l_performance_rating =l_inst_set(l_ele_num).v230_val
             then
               --
               l_ok := true;
               --
             else
               --
               l_ok := false;
               --
             end if;
             --
           close c2_without_events;
        end if;
        --
      else
        if p_perf_rtng_cd is not null then
           if p_perf_rtng_cd =l_inst_set(l_ele_num).v230_val and
              p_event_type = l_inst_set(l_ele_num).v230_val1
           then
             --
             l_ok := true;
             --
           else
             --
             l_ok := false;
             --
           end if;
           --
        else
           open c1(p_person_id          => p_person_id
                  ,p_event_type         => l_inst_set(l_ele_num).v230_val1
                  ,p_business_group_id  => p_business_group_id
          	       ,p_effective_date     => nvl(p_lf_evt_ocrd_dt, p_effective_date) );
           fetch c1 into l_performance_rating;
           --
           if c1%found and l_performance_rating = l_inst_set(l_ele_num).v230_val then
             l_ok := true;
           else
             l_ok := false;
           end if;
           --
           close c1 ;
           --
        end if;
      end if;
      --
      if l_ok and l_inst_set(l_ele_num).excld_flag = 'N' then
        --
        hr_utility.set_location('Exclude Flag = N, Performance Rating ' || l_inst_set(l_ele_num).num_val || ' and Rating level ' || l_inst_set(l_ele_num).num_val1 || ' found ', 20 );
        if p_score_compute_mode then
           if l_crit_passed is null then
              l_crit_passed := true;
           end if;
           write(l_score_tab,
                 l_inst_set(l_ele_num).eligy_prfl_id,
                 l_inst_set(l_ele_num).short_code,
                 l_inst_set(l_ele_num).pk_id,
                 nvl(l_inst_set(l_ele_num).criteria_score,
                 l_inst_set(l_ele_num).criteria_weight));
        else
           exit;
        end if;
        --
      elsif l_ok and l_inst_set(l_ele_num).excld_flag = 'Y' then
        --
        hr_utility.set_location('Exclude Flag = Y, Performance Rating ' || l_inst_set(l_ele_num).num_val || ' and Rating level ' || l_inst_set(l_ele_num).num_val1 || ' found ', 20 );
        l_ok := false;
        exit;
        --
      elsif (not l_ok) and l_inst_set(l_ele_num).excld_flag = 'Y' then
        --
        l_ok := true;
        --
        if p_score_compute_mode then
           write(l_score_tab,
                 l_inst_set(l_ele_num).eligy_prfl_id,
                 l_inst_set(l_ele_num).short_code,
                 l_inst_set(l_ele_num).pk_id,
                 nvl(l_inst_set(l_ele_num).criteria_score,
                 l_inst_set(l_ele_num).criteria_weight));
        end if;
      end if;
      --
      l_ele_num := l_ele_num+1;
      --
    end loop;
    --
  end if;
  --
  if l_crit_passed is null
  then
     if l_rows_found and not l_ok
     then
       --
       g_inelg_rsn_cd := 'ERG';
       fnd_message.set_name('BEN','BEN_93108_PERF_RTNG_PRFL_FAIL');
       hr_utility.set_location('Criteria Failed: '||l_proc,40);
       raise g_criteria_failed;
       --
     end if;
  end if;
  --
  if p_score_compute_mode
  then
     hr_utility.set_location('count '||l_score_tab.count,20);
     write(p_profile_score_tab,l_score_tab);
  end if;
  hr_utility.set_location('Leaving: '||l_proc,50);
  --
end check_perf_rtng_elig;
--
-- --------------------------------------------------
--  Quartile in Grade
-- --------------------------------------------------
procedure check_qua_in_gr_elig( p_eligy_prfl_id     in number,
		     		p_business_group_id in number,
                     		p_person_id   	    in number,
                     		p_grade_id	    in number,
                     		p_assignment_id     in number,
                                p_score_compute_mode in boolean default false,
                                p_profile_score_tab in out nocopy scoreTab,
                     		p_effective_date    date,
                     		p_lf_evt_ocrd_dt    date,
                     		p_pay_basis_id 	    number) is
  --
  l_proc       	   varchar2(100) := g_package||' check_qua_in_gr_elig';
  l_inst_set       ben_elp_cache.g_elp_cache := ben_elp_cache.g_elp_cache();
  l_ele_num        pls_integer;
  --
  l_dummy          varchar2(10) ;
  --
  l_ok 		   boolean := false;
  l_rows_found 	   boolean := false;
  l_max_val	   number;
  l_min_val	   number;
  l_max_qualifier  number;
  l_min_qualifier  number;
  l_in_quartile    boolean;
  l_person_sal	   number := 0;
  l_crit_passed     boolean;
  l_score_tab       scoreTab;
  l_quar_grad       VARCHAR2 (30);    --    added for bug: 4558945
  --
  cursor c1(p_grade_id 		 number
  	    ,p_business_group_id number
  	    ,p_lf_evt_ocrd_dt	 date
  	    ,p_pay_basis_id 	 number) is
  select (maximum * grade_annualization_factor) maximum ,
  	 (minimum * grade_annualization_factor) minimum
  from 	 pay_grade_rules_f pgr,
  	 per_pay_bases ppb             -- 2594204
  where  ppb.pay_basis_id = p_pay_basis_id
  and    ppb.business_group_id = p_business_group_id
  and	 pgr.rate_id = ppb.rate_id
  and    pgr.business_group_id = p_business_group_id
  and    pgr.grade_or_spinal_point_id  = p_grade_id
  and 	 p_lf_evt_ocrd_dt between nvl(pgr.effective_start_date, p_lf_evt_ocrd_dt)
  and 	 nvl(pgr.effective_end_date, p_lf_evt_ocrd_dt);

  /*
  Bug 4031314 : We need
                (1) Pay Annualization Factor of Salary Basis
                (2) Person's Approved Pay Proposal
                Splitting the following cursor :
  cursor c2(p_assignment_id 	 number
  	    ,p_business_group_id number
  	    ,p_lf_evt_ocrd_dt	 date
  	    ,p_pay_basis_id      number) is
  select ppp.proposed_salary_n * ppb.pay_annualization_factor annual_salary
  from   per_pay_bases  	ppb,
	 per_pay_proposals ppp
  where  ppb.pay_basis_id = p_pay_basis_id
  and    ppb.business_group_id = p_business_group_id
  and    ppp.assignment_id = p_assignment_id
  and    ppp.change_date <= p_lf_evt_ocrd_dt
  order by ppp.change_date desc ;
  */
  cursor c_salary ( p_assignment_id 	 number
  	           ,p_business_group_id  number
  	           ,p_lf_evt_ocrd_dt	 date
                   ) is
       select ppp.proposed_salary_n
         from per_pay_proposals ppp
        where ppp.assignment_id = p_assignment_id
          and ppp.business_group_id = p_business_group_id
          and ppp.approved = 'Y'
          and ppp.change_date <= p_lf_evt_ocrd_dt
     order by ppp.change_date desc;
  --
  cursor c_pay_bas_ann_fctr ( p_pay_basis_id number
                             ,p_business_group_id number
                            ) is
      select ppb.pay_annualization_factor
        from per_pay_bases ppb
       where ppb.pay_basis_id = p_pay_basis_id
         and ppb.business_group_id = ppb.business_group_id;
  --
  l_ann_fctr       number := 0;
  l_ann_sal        number := 0;
  -- Bug 4031314
  --

  procedure get_quartile(p_min 	IN number default 0
  		     	,p_max 	IN number default 0
  		     	,p_code IN  varchar2
  		     	,p_min_qualifier OUT NOCOPY number
  		     	,p_max_qualifier OUT NOCOPY number
  		     ) is
  l_divisor 		number := 4;
  l_addition_factor  	number;
  l_multiplication_factor number;
  begin
  	if p_code not in ('ABV' , 'BLW' , 'NA' ) then
  		l_multiplication_factor := to_number(p_code);
  		l_addition_factor := (p_max - p_min)/l_divisor;
  		p_min_qualifier := p_max - l_addition_factor * (l_multiplication_factor )  ;
  		p_max_qualifier := p_max - l_addition_factor * (l_multiplication_factor - 1 ) ;
  		--
  		if l_multiplication_factor <> 4 then
  		   p_min_qualifier :=  p_min_qualifier + 1;
  		end if;
  	end if;
  end;
  --
begin
  --
  hr_utility.set_location('Entering: '||l_proc, 10);
  --
  ben_elp_cache.elpeqg_getdets
  (p_effective_date => nvl(l_fonm_cvg_strt_dt,p_effective_date)
  ,p_eligy_prfl_id  => p_eligy_prfl_id
  --
  ,p_inst_set       => l_inst_set
  );
  --
  if l_inst_set.count > 0 then
    --
    l_ele_num := 1;
    --
    --  get min , max limits from grade scale
    --
    open c1(p_grade_id
    	   ,p_business_group_id
       	   ,nvl(l_fonm_cvg_strt_dt,nvl(p_lf_evt_ocrd_dt, p_effective_date))
       	   ,p_pay_basis_id);
    fetch c1 into l_max_val, l_min_val;
    close c1;
    --
    -- get persons salary by applying the annual factor
    --
    /* Bug 4031314
    open c2(p_assignment_id
     	   ,p_business_group_id
      	   ,nvl(l_fonm_cvg_strt_dt,nvl(p_lf_evt_ocrd_dt, p_effective_date))
      	   ,p_pay_basis_id) ;
    fetch c2 into l_person_sal;
    close c2;
    */
    open c_salary ( p_assignment_id     => p_assignment_id,
                    p_business_group_id => p_business_group_id,
                    p_lf_evt_ocrd_dt    => nvl( l_fonm_cvg_strt_dt,
                                                      nvl(p_lf_evt_ocrd_dt, p_effective_date
                                                         )
                                               )
                  );
      fetch c_salary into l_person_sal;
    close c_salary;
    --
    open c_pay_bas_ann_fctr ( p_pay_basis_id      => p_pay_basis_id,
                              p_business_group_id => p_business_group_id );
      fetch c_pay_bas_ann_fctr into l_ann_fctr;
    close c_pay_bas_ann_fctr;
    --
    l_ann_sal := l_person_sal * l_ann_fctr;
    --
          -- added for bug: 4558945
      l_quar_grad :=
         ben_cwb_person_info_pkg.get_grd_quartile (p_salary      => l_ann_sal,
                                                   p_min         => NVL
                                                                       (l_min_val,
                                                                        0
                                                                       ),
                                                   p_max         => NVL
                                                                       (l_max_val,
                                                                        0
                                                                       ),
                                                   p_mid         =>   (  NVL
                                                                            (l_min_val,
                                                                             0
                                                                            )
                                                                       + NVL
                                                                            (l_max_val,
                                                                             0
                                                                            )
                                                                      )
                                                                    / 2
                                                  );
    for i in l_inst_set.first..l_inst_set.last loop
        l_rows_found := true;
        --
	-- commented for bug: 4558945
	/*
	get_quartile(p_min  	    => nvl(l_min_val,0)
		   ,p_max 	    => nvl(l_max_val,0)
		   ,p_code 	    => l_inst_set(l_ele_num).v230_val
		   ,p_min_qualifier => l_min_qualifier
		   ,p_max_qualifier => l_max_qualifier );
        hr_utility.set_location('ACE l_min_qualifier = ' || l_min_qualifier, 9999);
        hr_utility.set_location('ACE l_max_qualifier = ' || l_max_qualifier, 9999);

	--
	if l_inst_set(l_ele_num).v230_val  = 'ABV' then
	   l_in_quartile := l_ann_sal > nvl(l_max_val,0);
	elsif l_inst_set(l_ele_num).v230_val  = 'BLW' then
	   l_in_quartile := l_ann_sal < nvl(l_min_val,0);
	else
	   l_in_quartile := l_ann_sal between l_min_qualifier and l_max_qualifier;
	end if;
	--
	*/
	-- commented for bug: 4558945
	-- if l_inst_set(l_ele_num).excld_flag = 'N' and l_in_quartile then
	IF     l_inst_set (l_ele_num).excld_flag = 'N' AND l_inst_set (l_ele_num).v230_val = l_quar_grad then
	  l_ok := true;
          if p_score_compute_mode then
             if l_crit_passed is null then
                l_crit_passed := true;
             end if;
             write(l_score_tab,
                   l_inst_set(l_ele_num).eligy_prfl_id,
                   l_inst_set(l_ele_num).short_code,
                   l_inst_set(l_ele_num).pk_id,
                   nvl(l_inst_set(l_ele_num).criteria_score,
                   l_inst_set(l_ele_num).criteria_weight));
          else
             exit;
          end if;
	-- commented for bug: 4558945
	-- elsif l_inst_set(l_ele_num).excld_flag = 'N' and not l_in_quartile then
	ELSIF     l_inst_set (l_ele_num).excld_flag = 'N' AND l_inst_set (l_ele_num).v230_val <> l_quar_grad then
        l_ok := false;
	-- commented for bug: 4558945
	-- elsif l_inst_set(l_ele_num).excld_flag = 'Y' and not l_in_quartile then
	ELSIF     l_inst_set (l_ele_num).excld_flag = 'Y' AND l_inst_set (l_ele_num).v230_val <> l_quar_grad then
         l_ok := true;
          if p_score_compute_mode then
             write(l_score_tab,
                   l_inst_set(l_ele_num).eligy_prfl_id,
                   l_inst_set(l_ele_num).short_code,
                   l_inst_set(l_ele_num).pk_id,
                   nvl(l_inst_set(l_ele_num).criteria_score,
                   l_inst_set(l_ele_num).criteria_weight));
        end if;
	-- commented for bug: 4558945
	-- elsif l_inst_set(l_ele_num).excld_flag = 'Y' and l_in_quartile then
	ELSIF     l_inst_set (l_ele_num).excld_flag = 'Y' AND l_inst_set (l_ele_num).v230_val = l_quar_grad THEN
	  l_ok := false;
	  exit;
	end if;
        --
        l_ele_num := l_ele_num+1;
        --
    end loop;
    --
  end if;
  --
  if l_crit_passed is null
  then
     if l_rows_found and not l_ok
     then
       --
       g_inelg_rsn_cd := 'EQG';
       fnd_message.set_name('BEN','BEN_93107_QUA_IN_GR_PRFL_FAIL');
       hr_utility.set_location('Criteria Failed: '||l_proc,40);
       raise g_criteria_failed;
       --
     end if;
  end if;
  --
  if p_score_compute_mode
  then
     hr_utility.set_location('count '||l_score_tab.count,20);
     write(p_profile_score_tab,l_score_tab);
  end if;
  hr_utility.set_location('Leaving: '||l_proc,50);
  --
end check_qua_in_gr_elig;
--
-- Public Function
--
-- -----------------------------------------------------------------------------
-- |-----------------------< eligible >-------------------------------|
-- -----------------------------------------------------------------------------
function eligible
  (p_person_id                 in number
  ,p_assignment_id             in number default null
  ,p_business_group_id         in number
  ,p_effective_date            in date
  ,p_eligprof_tab              in proftab default t_prof_tbl
  ,p_vrbl_rt_prfl_id           in number default null
  ,p_lf_evt_ocrd_dt            in date   default null
  ,p_dpr_rec                   in ben_derive_part_and_rate_facts.g_cache_structure default l_dpr_rec
  ,p_per_in_ler_id             in number default null
  ,p_ler_id                    in number default null
  ,p_pgm_id                    in number default null
  ,p_ptip_id                   in number default null
  ,p_plip_id                   in number default null
  ,p_pl_id                     in number default null
  ,p_oipl_id                   in number default null
  ,p_oiplip_id                 in number default null
  ,p_pl_typ_id                 in number default null
  ,p_opt_id                    in number default null
  ,p_par_pgm_id                in number default null
  ,p_par_plip_id               in number default null
  ,p_par_pl_id                 in number default null
  ,p_par_opt_id                in number default null
  ,p_currepe_row               in ben_determine_rates.g_curr_epe_rec default ben_determine_rates.g_def_curr_epe_rec
  ,p_asg_status                in varchar2 default 'EMP'
  ,p_ttl_prtt                  in number   default null
  ,p_ttl_cvg                   in number   default null
  ,p_all_prfls                 in boolean  default false
  ,p_eval_typ                  in varchar2 default 'E' -- V for Vapro
  ,p_comp_obj_mode             in boolean  default true
  ,p_score_tab                 out nocopy scoreTab
  ) return boolean is

  --
  l_proc                  varchar2(100):= g_package||'eligible';
  --
  l_eligprof_dets         ben_cep_cache.g_cobcep_odcache;
  l_tmpelp_dets           ben_cep_cache.g_cobcep_odcache := ben_cep_cache.g_cobcep_odcache();
  --
  l_elptorrw_num          binary_integer;
  l_inst_count            number;
  l_elig_flag             boolean := false;
  l_elig_per_id           number;
  l_prtn_ovridn_thru_dt   date;
  l_effective_date        date;
  l_prtn_ovridn_flag      ben_elig_per_f.prtn_ovridn_flag%type;
  l_rl_count              number;
  l_match_one             boolean := false;
  l_match_one_rl          varchar2(15) := 'FALSE';
  l_outputs               ff_exec.outputs_t;
  l_ok_so_far             varchar2(1);
  l_mx_wtg_perd_prte_elig boolean := false;
  l_elig_apls_flag        varchar2(30);
  l_dpnt_elig_flag        varchar2(1) := 'Y';
  l_dependent_elig_flag   varchar2(1) := 'Y';
  l_dpnt_inelig_rsn_cd    ben_elig_dpnt.inelg_rsn_cd%type;
  l_per_in_ler_id         ben_per_in_ler.per_in_ler_id%type;
  l_per_cvrd_cd           ben_pl_f.per_cvrd_cd%type;
  l_elig_inelig_cd        ben_elig_to_prte_rsn_f.elig_inelig_cd%type;
  l_dpnt_pl_id            ben_pl_f.pl_id%type;
  l_exists                varchar2(30);
  --
  l_terminated    per_assignment_status_types.per_system_status%type ;
  l_assignment_id per_all_assignments_f.assignment_id%type;
  l_found_profile varchar2(1) := 'N';
  l_pl_rec        ben_pl_f%rowtype;
  l_pl3_rec       ben_pl_f%rowtype;
  l_ptip2_rec	  ben_ptip_f%rowtype;
  l_oipl_rec      ben_oipl_f%rowtype;
  l_plip_rec      ben_plip_f%rowtype;
  l_ptip_rec      ben_ptip_f%rowtype;
  --
  l_inst_set      ben_elig_rl_cache.g_elig_rl_inst_tbl;
  l_elig_rl_cnt   number := 0;
  l_ctr_count     number := 0;
  l_jurisdiction_code     varchar2(30);
  --
  l_per_rec       per_all_people_f%rowtype;
  l_ass_rec       per_all_assignments_f%rowtype;
  l_ass_rec1      per_all_assignments_f%rowtype; -- Bug 6399423
  l_hsc_rec       hr_soft_coding_keyflex%rowtype;
  l_org_rec       hr_all_organization_units%rowtype;
  l_loop_count    number;
  --
  l_empasg_row    per_all_assignments_f%rowtype;
  l_benasg_row    per_all_assignments_f%rowtype;
  l_pil_row       ben_per_in_ler%rowtype;
  --
  l_cagrelig_cnt       pls_integer;
  l_pl_typ_id	number;
  l_typ_rec    ben_person_object.g_cache_typ_table;
  l_appass_rec ben_person_object.g_cache_ass_table;
  l_comp_obj_tree_row          ben_manage_life_events.g_cache_proc_objects_rec;
  l_comp_rec    ben_derive_part_and_rate_facts.g_cache_structure;
  l_oiplip_rec  ben_derive_part_and_rate_facts.g_cache_structure;
  --
  l_ff_use_asg_id_flag varchar2(1);
  l_vrfy_fmly_mmbr_cd  varchar2(30);
  l_vrfy_fmly_mmbr_rl  number;
  l_pl_id              number;
  l_env                ben_env_object.g_global_env_rec_type;
  --
  l_age_val            number;
  l_los_val            number;
  l_comb_age           number;
  l_comb_los           number;
  l_cmbn_age_n_los_val number;
  l_comp_ref_amt       number;
  l_once_r_cntug_cd    varchar2(30);
  l_pct_fl_tm_val      number;
  l_hrs_wkd_val        number;
  l_comp_elig_flag     varchar2(1);
  l_asg_found          boolean;
  --FONM
  -- l_fonm_cvg_strt_dt DATE ;
  --END FONM
  l_age_fctr_id                  number;
  l_comp_lvl_fctr_id             number;
  l_cmbn_age_los_fctr_id         number;
  l_los_fctr_id                  number;
  l_pct_fl_tm_fctr_id            number;
  l_hrs_wkd_in_perd_fctr_id      number;
  l_competence_id                number;
  l_rating_level_id              number;
  l_absence_attendance_type_id   number;
  l_absence_attendance_reason_id number;
  l_quar_in_grade_cd             varchar2(30);
  l_qualification_type_id        number;
  l_title                        varchar2(255);
  l_event_type                   varchar2(255);
  l_perf_rtng_cd                 varchar2(255);
  l_leaving_reason               varchar2(255);
  l_postal_code                  varchar2(255);
  l_crit_ovrrd_val_rec           pqh_popl_criteria_ovrrd.g_crit_ovrrd_val_rec;
  l_crit_ovrrd_val_tab           pqh_popl_criteria_ovrrd.g_crit_ovrrd_val_tbl;
  l_profile_score_tab            scoreTab;
  l_prof_score_compute           boolean := false;

  cursor c_elgy_prfl(p_eligy_prfl_id  number,
                     c_effective_date date) is
    select  null,
            p_pgm_id,
            p_ptip_id,
            p_plip_id,
            p_pl_id,
            p_oipl_id,
            null,
            null,       -- prtn_elig_id
            null,        -- mndtry_flag
            'N',
            'N',
            tab3.eligy_prfl_id,
            tab3.asmt_to_use_cd,
            tab3.elig_enrld_plip_flag,
            tab3.elig_cbr_quald_bnf_flag,
            tab3.elig_enrld_ptip_flag,
            tab3.elig_dpnt_cvrd_plip_flag,
            tab3.elig_dpnt_cvrd_ptip_flag,
            tab3.elig_dpnt_cvrd_pgm_flag,
            tab3.elig_job_flag,
            tab3.elig_hrly_slrd_flag,
            tab3.elig_pstl_cd_flag,
            tab3.elig_lbr_mmbr_flag,
            tab3.elig_lgl_enty_flag,
            tab3.elig_benfts_grp_flag,
            tab3.elig_wk_loc_flag,
            tab3.elig_brgng_unit_flag,
            tab3.elig_age_flag,
            tab3.elig_los_flag,
            tab3.elig_per_typ_flag,
            tab3.elig_fl_tm_pt_tm_flag,
            tab3.elig_ee_stat_flag,
            tab3.elig_grd_flag,
            tab3.elig_pct_fl_tm_flag,
            tab3.elig_asnt_set_flag,
            tab3.elig_hrs_wkd_flag,
            tab3.elig_comp_lvl_flag,
            tab3.elig_org_unit_flag,
            tab3.elig_loa_rsn_flag,
            tab3.elig_pyrl_flag,
            tab3.elig_schedd_hrs_flag,
            tab3.elig_py_bss_flag,
            tab3.eligy_prfl_rl_flag,
            tab3.elig_cmbn_age_los_flag,
            tab3.cntng_prtn_elig_prfl_flag,
            tab3.elig_prtt_pl_flag,
            tab3.elig_ppl_grp_flag,
            tab3.elig_svc_area_flag,
            tab3.elig_ptip_prte_flag,
            tab3.elig_no_othr_cvg_flag,
            tab3.elig_enrld_pl_flag,
            tab3.elig_enrld_oipl_flag,
            tab3.elig_enrld_pgm_flag,
            tab3.elig_dpnt_cvrd_pl_flag,
            tab3.elig_lvg_rsn_flag,
            tab3.elig_optd_mdcr_flag,
            tab3.elig_tbco_use_flag,
            tab3.elig_dpnt_othr_ptip_flag,
            tab3.ELIG_GNDR_FLAG,
            tab3.ELIG_MRTL_STS_FLAG,
            tab3.ELIG_DSBLTY_CTG_FLAG,
            tab3.ELIG_DSBLTY_RSN_FLAG,
            tab3.ELIG_DSBLTY_DGR_FLAG,
            tab3.ELIG_SUPPL_ROLE_FLAG,
            tab3.ELIG_QUAL_TITL_FLAG,
            tab3.ELIG_PSTN_FLAG,
            tab3.ELIG_PRBTN_PERD_FLAG,
            tab3.ELIG_SP_CLNG_PRG_PT_FLAG,
            tab3.BNFT_CAGR_PRTN_CD,
            tab3.ELIG_DSBLD_FLAG,
            tab3.ELIG_TTL_CVG_VOL_FLAG,
            tab3.ELIG_TTL_PRTT_FLAG,
            tab3.ELIG_COMPTNCY_FLAG,
            tab3.ELIG_HLTH_CVG_FLAG,
            tab3.ELIG_ANTHR_PL_FLAG,
            tab3.elig_qua_in_gr_flag,
            tab3.elig_perf_rtng_flag,
            tab3.elig_crit_values_flag
     from ben_eligy_prfl_f tab3
    where tab3.eligy_prfl_id = p_eligy_prfl_id
      and tab3.stat_cd = 'A'
      and c_effective_date between tab3.effective_start_date
      and tab3.effective_end_date;

  cursor c_ptip_pl_typ(c_effective_date date) is
     select  pl_typ_id
     from    ben_ptip_f
     where   ptip_id = p_ptip_id
     and     c_effective_date
     between effective_start_date
     and     effective_end_date;
  --
  cursor c_plip_pl_typ(c_effective_date date) is
     select  pln.pl_typ_id
     from    ben_plip_f plip,
             ben_pl_f pln
     where   plip_id = p_plip_id
     and     c_effective_date
     between plip.effective_start_date and plip.effective_end_date
     and     pln.pl_id = plip.pl_id
     and     c_effective_date
     between pln.effective_start_date and pln.effective_end_date ;
  --
  cursor c_oipl_pl_typ(c_effective_date date) is
     select  pln.pl_typ_id
     from    ben_oipl_f oipl,
             ben_pl_f pln
     where   oipl_id = p_oipl_id
     and     c_effective_date
     between oipl.effective_start_date and oipl.effective_end_date
     and     pln.pl_id = oipl.pl_id
     and     c_effective_date
     between pln.effective_start_date and pln.effective_end_date ;
  --
  cursor c_ff_use_asg(cv_formula_id in number) is
     select 'Y'
     from ff_fdi_usages_f
     where FORMULA_ID = cv_formula_id
       and ITEM_NAME  = 'ASSIGNMENT_ID'
       and usage      = 'U';
  -- 4958846
  l_env_rec              ben_env_object.g_global_env_rec_type;
  l_benmngle_parm_rec    benutils.g_batch_param_rec;
  -- Procedure to assign overridden values
  --
  procedure assign_overriden_values
  (p_per_rec    in out nocopy per_all_people_f%rowtype,
   p_asg_rec    in out nocopy per_all_assignments_f%rowtype)
  is

  cursor check_gen_criteria(p_short_code varchar2) is
  select 'x'
    from ben_eligy_criteria
   where short_code = p_short_code;

  l_dummy   varchar2(1);
  l_proc    varchar2(30) := 'assign_overriden_values';

  begin

  hr_utility.set_location('Entering :'||l_proc,10);

  if not (pqh_popl_criteria_ovrrd.g_criteria_count>0) then
     hr_utility.set_location('No overridden values',10);
     hr_utility.set_location('Leaving :'||l_proc,10);
     return;
  end if;

  hr_utility.set_location('Overridden count '||pqh_popl_criteria_ovrrd.g_criteria_override_val.count,10);

  for i in 1..pqh_popl_criteria_ovrrd.g_criteria_override_val.count
  loop
     l_crit_ovrrd_val_rec := pqh_popl_criteria_ovrrd.g_criteria_override_val(i);
     hr_utility.set_location('Short code '||l_crit_ovrrd_val_rec.criteria_short_code,10);
     if l_crit_ovrrd_val_rec.criteria_short_code is null then
        exit;
     end if;

     if l_crit_ovrrd_val_rec.criteria_short_code = 'EAN' then
  --      p_asg_rec.assignment_set_id := l_crit_ovrrd_val_rec.number_value1;
        null;
     elsif l_crit_ovrrd_val_rec.criteria_short_code = 'EES' then
        p_asg_rec.assignment_status_type_id := l_crit_ovrrd_val_rec.number_value1;
     elsif l_crit_ovrrd_val_rec.criteria_short_code = 'EAP' then
        l_age_fctr_id := l_crit_ovrrd_val_rec.number_value1;
     elsif l_crit_ovrrd_val_rec.criteria_short_code = 'EBN' then
        p_per_rec.benefit_group_id := l_crit_ovrrd_val_rec.number_value1;
     elsif l_crit_ovrrd_val_rec.criteria_short_code = 'EBU' then
        p_asg_rec.bargaining_unit_code := l_crit_ovrrd_val_rec.char_value1;
     elsif l_crit_ovrrd_val_rec.criteria_short_code = 'ECL' then
        l_comp_lvl_fctr_id := l_crit_ovrrd_val_rec.number_value1;
     elsif l_crit_ovrrd_val_rec.criteria_short_code = 'ECP' then
        l_cmbn_age_los_fctr_id := l_crit_ovrrd_val_rec.number_value1;
     elsif l_crit_ovrrd_val_rec.criteria_short_code = 'ECY' then
        l_competence_id := l_crit_ovrrd_val_rec.number_value1;
        l_rating_level_id := l_crit_ovrrd_val_rec.number_value2;
     elsif l_crit_ovrrd_val_rec.criteria_short_code = 'EDB' then
        p_per_rec.registered_disabled_flag := l_crit_ovrrd_val_rec.char_value1;
     elsif l_crit_ovrrd_val_rec.criteria_short_code = 'EFP' then
        p_asg_rec.employment_category := l_crit_ovrrd_val_rec.char_value1;
     elsif l_crit_ovrrd_val_rec.criteria_short_code = 'EPF' then
        l_pct_fl_tm_fctr_id := l_crit_ovrrd_val_rec.number_value1;
     elsif l_crit_ovrrd_val_rec.criteria_short_code = 'EGN' then
        p_per_rec.sex := l_crit_ovrrd_val_rec.char_value1;
     elsif l_crit_ovrrd_val_rec.criteria_short_code = 'EGR' then
        p_asg_rec.grade_id := l_crit_ovrrd_val_rec.number_value1;
     elsif l_crit_ovrrd_val_rec.criteria_short_code = 'EHS' then
        p_asg_rec.hourly_salaried_code := l_crit_ovrrd_val_rec.char_value1;
     elsif l_crit_ovrrd_val_rec.criteria_short_code = 'EHW' then
        l_hrs_wkd_in_perd_fctr_id := l_crit_ovrrd_val_rec.number_value1;
     elsif l_crit_ovrrd_val_rec.criteria_short_code = 'EJP' then
        p_asg_rec.job_id := l_crit_ovrrd_val_rec.number_value1;
     elsif l_crit_ovrrd_val_rec.criteria_short_code = 'ELN' then
        p_asg_rec.organization_id := l_crit_ovrrd_val_rec.number_value1;
     elsif l_crit_ovrrd_val_rec.criteria_short_code = 'ELR' then
        l_absence_attendance_type_id := l_crit_ovrrd_val_rec.number_value1;
        l_absence_attendance_reason_id := l_crit_ovrrd_val_rec.number_value2;
     elsif l_crit_ovrrd_val_rec.criteria_short_code = 'ELS' then
        l_los_fctr_id := l_crit_ovrrd_val_rec.number_value1;
     elsif l_crit_ovrrd_val_rec.criteria_short_code = 'ELU' then
        p_asg_rec.labour_union_member_flag := l_crit_ovrrd_val_rec.char_value1;
     elsif l_crit_ovrrd_val_rec.criteria_short_code = 'ELV' then
        l_leaving_reason := l_crit_ovrrd_val_rec.char_value1;
     elsif l_crit_ovrrd_val_rec.criteria_short_code = 'EOM' then
        p_per_rec.per_information10 := l_crit_ovrrd_val_rec.char_value1;
     elsif l_crit_ovrrd_val_rec.criteria_short_code = 'EOU' then
        p_asg_rec.organization_id := l_crit_ovrrd_val_rec.number_value1;
     elsif l_crit_ovrrd_val_rec.criteria_short_code = 'EPB' then
        p_asg_rec.pay_basis_id := l_crit_ovrrd_val_rec.number_value1;
     elsif l_crit_ovrrd_val_rec.criteria_short_code = 'EPG' then
        p_asg_rec.people_group_id := l_crit_ovrrd_val_rec.number_value1;
     elsif l_crit_ovrrd_val_rec.criteria_short_code = 'EPS' then
        p_asg_rec.position_id := l_crit_ovrrd_val_rec.number_value1;
     elsif l_crit_ovrrd_val_rec.criteria_short_code = 'EPT' then
        p_per_rec.person_type_id := l_crit_ovrrd_val_rec.number_value1;
     elsif l_crit_ovrrd_val_rec.criteria_short_code = 'EPY' then
        p_asg_rec.payroll_id := l_crit_ovrrd_val_rec.number_value1;
     elsif l_crit_ovrrd_val_rec.criteria_short_code = 'EPZ' then
        l_postal_code := l_crit_ovrrd_val_rec.char_value1;
     elsif l_crit_ovrrd_val_rec.criteria_short_code = 'EQG' then
        l_quar_in_grade_cd := l_crit_ovrrd_val_rec.char_value1;
     elsif l_crit_ovrrd_val_rec.criteria_short_code = 'EQT' then
        l_qualification_type_id := l_crit_ovrrd_val_rec.number_value1;
        l_title := l_crit_ovrrd_val_rec.char_value1;
     elsif l_crit_ovrrd_val_rec.criteria_short_code = 'ERG' then
        l_event_type := l_crit_ovrrd_val_rec.char_value1;
        l_perf_rtng_cd := l_crit_ovrrd_val_rec.char_value2;
     elsif l_crit_ovrrd_val_rec.criteria_short_code = 'ESA' then
        l_postal_code := l_crit_ovrrd_val_rec.char_value1;
     elsif l_crit_ovrrd_val_rec.criteria_short_code = 'ESH' then
        null;
     elsif l_crit_ovrrd_val_rec.criteria_short_code = 'ETU' then
        p_per_rec.uses_tobacco_flag := l_crit_ovrrd_val_rec.char_value1;
     elsif l_crit_ovrrd_val_rec.criteria_short_code = 'EWL' then
        p_asg_rec.location_id := l_crit_ovrrd_val_rec.number_value1;
     else
        open check_gen_criteria(l_crit_ovrrd_val_rec.criteria_short_code);
        fetch check_gen_criteria into l_dummy;
        if check_gen_criteria%found then
           l_crit_ovrrd_val_tab(l_crit_ovrrd_val_tab.count+1) := l_crit_ovrrd_val_rec;
        else
           hr_utility.set_location('Unknown criteria '||l_crit_ovrrd_val_rec.criteria_short_code,10);
        end if;
        close check_gen_criteria;

     end if;

  end loop;

  hr_utility.set_location('Leaving :'||l_proc,10);

  end assign_overriden_values;

begin
  --
  hr_utility.set_location('Entering :'||l_proc,10);
  --
  -- intialize the global
  --
  l_fonm_cvg_strt_dt := null ;
  if ben_manage_life_events.fonm = 'Y'
     and ben_manage_life_events.g_fonm_cvg_strt_dt is not null then
    --
    if p_eval_typ = 'E' then
      --
      l_fonm_cvg_strt_dt := nvl(ben_manage_life_events.g_fonm_cvg_strt_dt,nvl(p_lf_evt_ocrd_dt,p_effective_date));
      --
    else
      --
      l_fonm_cvg_strt_dt :=nvl(ben_manage_life_events.g_fonm_rt_strt_dt,
                             nvl(ben_manage_life_events.g_fonm_cvg_strt_dt,
                                 nvl(p_lf_evt_ocrd_dt, p_effective_date)));
      --
    end if;
    --
  end if;
  hr_utility.set_location('l_fonm_cvg_strt_dt :'||l_fonm_cvg_strt_dt,10);
  l_effective_date := nvl(p_lf_evt_ocrd_dt,p_effective_date);
  -- Start of Bug 3520054
  if p_plip_id is not null then
    --
      hr_utility.set_location('PLIP_ID '||p_plip_id,11);
      --
      ben_comp_object.get_object(p_plip_id => p_plip_id
                                ,p_rec   => l_plip_rec);
      --
  elsif p_ptip_id is not null then
    --
      hr_utility.set_location('PTIP_ID '||p_ptip_id,12);
      --
      ben_comp_object.get_object(p_ptip_id => p_ptip_id
                                ,p_rec   => l_ptip_rec);
      --
  -- End of Bug 3520054
  elsif p_pl_id is not null then
    --
    hr_utility.set_location('PL_ID '||p_pl_id,14);
    --
    ben_comp_object.get_object(p_pl_id => p_pl_id
                              ,p_rec   => l_pl_rec);
    --
  elsif p_oipl_id is not null then
    --
    hr_utility.set_location('OIPL_ID '||p_oipl_id,16);
    --
    ben_comp_object.get_object(p_oipl_id => p_oipl_id
                              ,p_rec   => l_oipl_rec);

  end if;

  if p_eval_typ = 'E' and
     p_comp_obj_mode then

     l_age_val            := p_dpr_rec.age_val;
     l_los_val            := p_dpr_rec.los_val;
     l_comb_age           := p_dpr_rec.comb_age;
     l_comb_los           := p_dpr_rec.comb_los;
     l_cmbn_age_n_los_val := p_dpr_rec.cmbn_age_n_los_val;
     l_comp_ref_amt       := p_dpr_rec.comp_ref_amt;
     l_once_r_cntug_cd    := p_dpr_rec.once_r_cntug_cd;
     l_pct_fl_tm_val      := p_dpr_rec.pct_fl_tm_val;
     l_hrs_wkd_val        := p_dpr_rec.hrs_wkd_val;
     l_comp_elig_flag     := p_dpr_rec.elig_flag;

  end if;

  if  nvl(p_eligprof_tab.count,0) = 0 then

     if p_vrbl_rt_prfl_id is null then

        ben_cep_cache.cobcep_odgetdets
        (p_effective_date       => nvl(l_fonm_cvg_strt_dt,l_effective_date)
        ,p_pgm_id               => p_pgm_id
        ,p_pl_id                => p_pl_id
        ,p_oipl_id              => p_oipl_id
        ,p_plip_id              => p_plip_id
        ,p_ptip_id              => p_ptip_id
        ,p_vrbl_rt_prfl_id      => p_vrbl_rt_prfl_id
        ,p_inst_set             => l_eligprof_dets
        );
     else

        ben_cep_cache.cobcep_odgetdets
        (p_effective_date       => nvl(l_fonm_cvg_strt_dt,l_effective_date)
        ,p_pgm_id               => null
        ,p_pl_id                => null
        ,p_oipl_id              => null
        ,p_plip_id              => null
        ,p_ptip_id              => null
        ,p_vrbl_rt_prfl_id      => p_vrbl_rt_prfl_id
        ,p_inst_set             => l_eligprof_dets
        );
     end if;

  else

    l_eligprof_dets := ben_cep_cache.g_cobcep_odcache();
    l_eligprof_dets.extend(p_eligprof_tab.count);
    for i in 1..p_eligprof_tab.count
    loop

      hr_utility.set_location('prfl count'||p_eligprof_tab.count,99);
      hr_utility.set_location('prfl id'||p_eligprof_tab(i).eligy_prfl_id,99);
      open c_elgy_prfl(p_eligprof_tab(i).eligy_prfl_id,
                       nvl(l_fonm_cvg_strt_dt,l_effective_date));
     fetch c_elgy_prfl into l_eligprof_dets(i);
     close c_elgy_prfl;
     l_eligprof_dets(i).mndtry_flag := nvl(p_eligprof_tab(i).mndtry_flag,'N');
     l_eligprof_dets(i).compute_score_flag := nvl(p_eligprof_tab(i).compute_score_flag,'N');
     l_eligprof_dets(i).trk_scr_for_inelg_flag := nvl(p_eligprof_tab(i).trk_scr_for_inelg_flag,'N');

    end loop;

  end if;

  hr_utility.set_location(l_proc||' After Cache call ',46);
    --
    -- Filter out non CAGR profiles in collective agreement mode
    --
    -- Get the environment details
    --
    ben_env_object.get(p_rec => l_env);
    --
    if l_env.mode_cd = 'A'
       and l_eligprof_dets.count > 0 then
              --
              l_cagrelig_cnt := 1;  -- varray index start from 1 bug 2431869
              l_tmpelp_dets.delete;
              --
              for elenum in l_eligprof_dets.first..l_eligprof_dets.last
              loop
                --
                if nvl(l_eligprof_dets(elenum).BNFT_CAGR_PRTN_CD,'ZZZZ') = 'CAGR'
                then
                  --
                  l_tmpelp_dets.extend(1);
                  l_tmpelp_dets(l_cagrelig_cnt) := l_eligprof_dets(elenum);
                  l_cagrelig_cnt := l_cagrelig_cnt+1;
                  --
                end if;
                --
              end loop;
              --
              if l_cagrelig_cnt = 1 then
                --
                g_inelg_rsn_cd := 'NOCAGRELP';
                fnd_message.set_name('BEN','BEN_92844_NOCAGRELP_NOT_ELIG');
                return false;
                --
              end if;
              hr_utility.set_location('l_cagrelig_cnt = '|| l_cagrelig_cnt,1687);
              --
              l_eligprof_dets.delete;
              l_eligprof_dets := l_tmpelp_dets;
              --
    end if;
    --
    -- Bug 4454878
    -- Reset g_per_eligible to TRUE
    --
    g_per_eligible := true;
    --
    -- Check if any eligibility profiles exist
    --
    if l_eligprof_dets.count > 0 then
      --
      if p_person_id is not null then
          ben_person_object.get_object(p_person_id => p_person_id,
                                       p_rec       => l_typ_rec);
          --
          ben_person_object.get_object(p_person_id => p_person_id,
                                       p_rec       => l_per_rec);
          --
          -- if the person cache is not in the date range, clear the cahce
          --
          if not nvl(l_fonm_cvg_strt_dt,l_effective_date)
             between l_per_rec.effective_start_date and l_per_rec.effective_end_date then

              hr_utility.set_location('clearing cache'||nvl(l_fonm_cvg_strt_dt,l_effective_date) ,10);
              hr_utility.set_location('cache start'||l_per_rec.effective_start_date ,10);
              hr_utility.set_location('cache end'||l_per_rec.effective_end_date ,10);

              ben_use_cvg_rt_date.fonm_clear_down_cache;
              --
              ben_person_object.get_object(p_person_id => p_person_id,
                                           p_rec       => l_typ_rec);
              --
              ben_person_object.get_object(p_person_id => p_person_id,
                                           p_rec       => l_per_rec);

              hr_utility.set_location('nw cache start'||l_per_rec.effective_start_date ,10);
              hr_utility.set_location('nw cache end'||l_per_rec.effective_end_date ,10);
          else

    -- Bug 6399423
/*              ben_person_object.get_object(p_person_id => p_person_id,
                                             p_rec       => l_ass_rec);
 */

              ben_person_object.get_object(p_person_id => p_person_id,
                                           p_rec       => l_ass_rec1);
    -- Bug 6399423

              hr_utility.set_location('cache asg start'||l_ass_rec1.effective_start_date ,10);
              hr_utility.set_location('cache asg end'||l_ass_rec1.effective_end_date ,10);

              if not nvl(l_fonm_cvg_strt_dt,l_effective_date)
                 between l_ass_rec1.effective_start_date and l_ass_rec1.effective_end_date then

                 hr_utility.set_location('clearing asg cache'||nvl(l_fonm_cvg_strt_dt,l_effective_date) ,10);
                 ben_use_cvg_rt_date.fonm_clear_down_cache;

              end if ;
          end if ;
      end if ;
      --
      -- First determine if score is to be computed for any profile
      --
      g_score_compute_mode := false;
      for l_elptorrw_num in l_eligprof_dets.first..l_eligprof_dets.last loop
          g_trk_scr_for_inelg_flag := (l_eligprof_dets(l_elptorrw_num).trk_scr_for_inelg_flag = 'Y');
          if l_eligprof_dets(l_elptorrw_num).compute_score_flag = 'Y' then
             g_score_compute_mode := true;
             exit;
          end if;
      end loop;
      --
      if g_score_compute_mode then
         hr_utility.set_location('in score compute mode',10);
      end if;
      if g_trk_scr_for_inelg_flag then
         hr_utility.set_location('track score for inelig flag on',10);
      end if;

      g_per_eligible := null;
      --
      for l_elptorrw_num in l_eligprof_dets.first..l_eligprof_dets.last loop
        --
        l_found_profile := 'Y';
        --
        --  if eligibility profiles do exists for program, plan or option:
        --
        hr_utility.set_location('ELigibility Profile ID = '||l_eligprof_dets(l_elptorrw_num).eligy_prfl_id,10);
        hr_utility.set_location('Number of profiles = '||l_eligprof_dets.count,10);
        begin
          if g_score_compute_mode then
             if g_per_eligible is not null then --per already found elig/inelig
                if nvl(l_eligprof_dets(l_elptorrw_num).compute_score_flag,'N')='N' then
                   hr_utility.set_location('skipping prof '||
                   l_eligprof_dets(l_elptorrw_num).eligy_prfl_id,45);
                   raise g_skip_profile;
                end if;
             end if;
          end if;
          --
          l_profile_score_tab.delete;
          l_prof_score_compute := (l_eligprof_dets(l_elptorrw_num).compute_score_flag = 'Y');
          hr_utility.set_location(l_proc||' St ELP loop ',46);
          --
          g_inelg_rsn_cd := null;
          --
          if l_eligprof_dets(l_elptorrw_num).elig_per_typ_flag = 'Y' then
          check_per_typ_elig
            (p_eligy_prfl_id     => l_eligprof_dets(l_elptorrw_num).
                                    eligy_prfl_id,
             p_business_group_id => p_business_group_id,
             p_score_compute_mode=> l_prof_score_compute,
             p_profile_score_tab => l_profile_score_tab,
             p_effective_date    => nvl(l_fonm_cvg_strt_dt,l_effective_date),
             p_per_per_typ       => l_typ_rec);
          end if;
          --
          -- Now we check these profiles using the required assignment type
          --
          l_loop_count := 1;
          --
          if p_person_id is not null then
             if l_eligprof_dets(l_elptorrw_num).asmt_to_use_cd = 'EAO' then
               --
               -- Employee assignment only
               --
               ben_person_object.get_object(p_person_id => p_person_id,
                                            p_rec       => l_ass_rec);
               --
             elsif l_eligprof_dets(l_elptorrw_num).asmt_to_use_cd = 'BAO' then
               --
               -- Benefit assignment only
               --
               ben_person_object.get_benass_object(p_person_id => p_person_id,
                                                   p_rec       => l_ass_rec);
               --
             elsif l_eligprof_dets(l_elptorrw_num).asmt_to_use_cd = 'AAO' then
               --
               -- Applicant assignment only
               --
-- Bug 6509099
	       ben_env_object.get(p_rec => l_env_rec);
               benutils.get_batch_parameters(p_benefit_action_id => l_env_rec.benefit_action_id
					     ,p_rec => l_benmngle_parm_rec);

	       if l_benmngle_parm_rec.mode_cd = 'I' then
                --
                   l_appass_rec.delete;
                   l_appass_rec(1) := ben_manage_life_events.g_irec_ass_rec ;
               else
                --
               ben_person_object.get_object(p_person_id => p_person_id,
                                            p_rec       => l_appass_rec);
               --
	       end if;
	       --
-- Bug 6509099
               --
               if not l_appass_rec.exists(1) then
                 --
                 -- Initialize first record so that one time test works
                 --
                 l_appass_rec(1).person_id := p_person_id;
                 --
               end if;
               --
               l_ass_rec := l_appass_rec(1);
               l_loop_count := l_appass_rec.count;
               --
             elsif l_eligprof_dets(l_elptorrw_num).asmt_to_use_cd = 'ANY' then
               --
               -- First assignment only
               --
               hr_utility.set_location('Getting all assignments',10);
               -- 4958846 ssarkar for irec
	       ben_env_object.get(p_rec => l_env_rec);
               benutils.get_batch_parameters(p_benefit_action_id => l_env_rec.benefit_action_id
                                ,p_rec => l_benmngle_parm_rec);

               hr_utility.set_location('l_benmngle_parm_rec.mode_cd :' || l_benmngle_parm_rec.mode_cd,99);

	       if l_benmngle_parm_rec.mode_cd = 'I' then


                   l_appass_rec.delete;

                   l_appass_rec(1) := ben_manage_life_events.g_irec_ass_rec ;

		   hr_utility.set_location(' p_assignment_id :' || l_appass_rec(1).assignment_id,99);
                   hr_utility.set_location(' location_id :' || l_appass_rec(1).location_id,99);
		   hr_utility.set_location(' p_effective_date :' || p_effective_date,99);


	       else
                   ben_person_object.get_allass_object(p_person_id => p_person_id,
                                                      p_rec       => l_appass_rec);
               end if; -- 4958846 :irec
                --
               if not l_appass_rec.exists(1) then
                 --
                 -- Initialize first record so that one time test works
                 --
                 l_appass_rec(1).person_id := p_person_id;
                 --
                 hr_utility.set_location('NO RECS',10);
                 --
               end if;
               --
               l_loop_count := l_appass_rec.count;
               --
               l_ass_rec := l_appass_rec(1);
               hr_utility.set_location('NUMRECS'||l_appass_rec.count,10);
               hr_utility.set_location('GRADE'||l_appass_rec(1).grade_id,10);
             elsif l_eligprof_dets(l_elptorrw_num).asmt_to_use_cd = 'ETB' then
               --
               -- Employee then Benefits assignment only
               --
               ben_person_object.get_object(p_person_id => p_person_id,
                                            p_rec       => l_ass_rec);
               --
               if l_ass_rec.assignment_id is null then
                 --
                 -- Get Benefits Assignment
                 --
                 ben_person_object.get_benass_object(p_person_id => p_person_id,
                                                     p_rec       => l_ass_rec);
                 --
               end if;
               --
             elsif l_eligprof_dets(l_elptorrw_num).asmt_to_use_cd = 'BTE' then
               --
               -- Benefits then Employee assignment only
               --
               ben_person_object.get_benass_object(p_person_id => p_person_id,
                                                   p_rec       => l_ass_rec);
               --
               if l_ass_rec.assignment_id is null then
                 --
                 -- Get Employee Assignment
                 --
                 ben_person_object.get_object(p_person_id => p_person_id,
                                              p_rec       => l_ass_rec);
                 --
               end if;
               --
             elsif l_eligprof_dets(l_elptorrw_num).asmt_to_use_cd = 'EBA' then
               --
               -- Employee then Benefits then Applicant assignment only
               --
               ben_person_object.get_object(p_person_id => p_person_id,
                                            p_rec       => l_ass_rec);
               --
               if l_ass_rec.assignment_id is null then
                 --
                 -- Get Benefits Assignment
                 --
                 ben_person_object.get_benass_object(p_person_id => p_person_id,
                                                     p_rec       => l_ass_rec);
                 --
                 if l_ass_rec.assignment_id is null then
                   --
                   -- Applicant assignment only
                   --
-- Bug 6509099
		       ben_env_object.get(p_rec => l_env_rec);
	               benutils.get_batch_parameters(p_benefit_action_id => l_env_rec.benefit_action_id
				                     ,p_rec		 => l_benmngle_parm_rec);

		       if l_benmngle_parm_rec.mode_cd = 'I' then
		        --
	                   l_appass_rec.delete;
		           l_appass_rec(1) := ben_manage_life_events.g_irec_ass_rec ;
	               else
		        --
	               ben_person_object.get_object(p_person_id => p_person_id,
		                                    p_rec       => l_appass_rec);
	                --
		       end if;
		       --
-- Bug 6509099
                   if not l_appass_rec.exists(1) then
                     --
                     -- Initialize first record so that one time test works
                     --
                     l_appass_rec(1).person_id := p_person_id;
                     --
                   end if;
                   --
                   l_loop_count := l_appass_rec.count;
                   l_ass_rec := l_appass_rec(1);
                   --
                 end if;
                 --
               end if;
               --
             end if;
             --
             -- bug fix 2431776 - 27-AUG-2002 - hnarayan
             --
             -- Now assignment type is also considered a criteria. Hence,
             -- if Assignment Type is set to any thing other than "ANY' => any assignment
             -- i.e. any one of (EAO, BAO, AAO, ETB, BTE, EBA) then validate the assignment
             -- record retreived. If a person does not have an assignment matching the
             -- assignment type given in the ELPRO then he is considered ineligible.
             -- The only exclusion is ANY (Any Assignment)
             --
             -- For customers who have already set up their assignment type without
             -- considering it as a criteria, the workaround will be to change the
             -- assignment type as 'ANY', so that their ELPROs get checked during
             -- eligibilty determination
             --
             -- At this stage the assignment record would have been retreived
             -- as per the assignment type code given in the ELPRO for this person
             --
             hr_utility.set_location(l_proc || ' Start Check Asst Type' , 10) ;
             --
             if (l_eligprof_dets(l_elptorrw_num).asmt_to_use_cd <> 'ANY' and
                 l_ass_rec.assignment_id is null) then
               --
               g_inelg_rsn_cd := 'AST';
               fnd_message.set_name('BEN','BEN_93193_ASGN_TYPE_PRFL_FAIL');
   	       hr_utility.set_location('Criteria Failed: Assignment Type',20);
	       raise g_criteria_failed;
               --
             end if;
             --
             hr_utility.set_location(l_proc || ' End Check Asst Type' , 10) ;
             --
             -- end fix 2431776 - 27-AUG-2002 - hnarayan
             --
             -- if assignment_id is passed in, make sure eligibility profile's
             -- asmt_to_use_cd matches with that value
             --
             if p_assignment_id is not null then

                l_asg_found := false;
                for l_count in 1..l_loop_count loop
                    if l_loop_count > 1 then
                      l_ass_rec := l_appass_rec(l_count);
                    end if;
                    if l_ass_rec.assignment_id = p_assignment_id then
                       l_asg_found := true;
                       l_appass_rec.delete;
                       l_appass_rec(l_count) := l_ass_rec;
                       l_loop_count := 1;
                       exit;
                    end if;
                end loop;

                if not l_asg_found then
                   --
                   g_inelg_rsn_cd := 'AST';
                   fnd_message.set_name('BEN','BEN_93193_ASGN_TYPE_PRFL_FAIL');
                   hr_utility.set_location('Criteria Failed: Assignment Type',20);
                   raise g_criteria_failed;
                   --
                end if;
             end if;
          end if; --p_person_id not null

          hr_utility.set_location(l_proc||' Asg ELPs ',46);
          for l_count in 1..l_loop_count loop
            --
            begin
              --
              if p_person_id is not null and
                 l_loop_count > 1 then
                --
                -- Make sure that we pass in the correct assignment
                --
                l_ass_rec := l_appass_rec(l_count);
                --
              end if;
              --
              assign_overriden_values(l_per_rec,l_ass_rec);
              --
              hr_utility.set_location(' here ',999);
              if l_eligprof_dets(l_elptorrw_num).elig_ee_stat_flag = 'Y' then
              check_ee_stat_elig
                (p_eligy_prfl_id             => l_eligprof_dets(l_elptorrw_num).
                                                eligy_prfl_id,
                 p_business_group_id         => p_business_group_id,
                 p_score_compute_mode=> l_prof_score_compute,
                 p_profile_score_tab => l_profile_score_tab,
                 p_effective_date            => nvl(l_fonm_cvg_strt_dt,l_effective_date),
                 p_assignment_status_type_id => l_ass_rec.assignment_status_type_id);
              end if;
              --
              if l_eligprof_dets(l_elptorrw_num).elig_wk_loc_flag = 'Y' then
              check_wk_location_elig
                (p_eligy_prfl_id     => l_eligprof_dets(l_elptorrw_num).
                                        eligy_prfl_id,
                 p_business_group_id => p_business_group_id,
                 p_score_compute_mode=> l_prof_score_compute,
                 p_profile_score_tab => l_profile_score_tab,
                 p_effective_date    => nvl(l_fonm_cvg_strt_dt,l_effective_date),
                 p_location_id       => l_ass_rec.location_id);
              end if;
              --
              if l_eligprof_dets(l_elptorrw_num).elig_org_unit_flag = 'Y' then
              check_org_unit_elig
                (p_eligy_prfl_id     => l_eligprof_dets(l_elptorrw_num).
                                        eligy_prfl_id,
                 p_business_group_id => p_business_group_id,
                 p_score_compute_mode=> l_prof_score_compute,
                 p_profile_score_tab => l_profile_score_tab,
                 p_effective_date    => nvl(l_fonm_cvg_strt_dt,l_effective_date),
                 p_organization_id   => l_ass_rec.organization_id);
              end if;
              --
              if l_eligprof_dets(l_elptorrw_num).elig_ppl_grp_flag = 'Y' then
              check_people_group_elig
                (p_eligy_prfl_id     => l_eligprof_dets(l_elptorrw_num).
                                        eligy_prfl_id,
                 p_business_group_id => p_business_group_id,
                 p_score_compute_mode=> l_prof_score_compute,
                 p_profile_score_tab => l_profile_score_tab,
                 p_effective_date    => nvl(l_fonm_cvg_strt_dt,l_effective_date),
                 p_people_group_id   => l_ass_rec.people_group_id);
              end if;
              --
              if l_eligprof_dets(l_elptorrw_num).elig_schedd_hrs_flag = 'Y' then
		--
		if p_pgm_id is not null then
		  -- pl_typ_id is not available at pgm level
		  null;
		elsif p_pl_id is not null then
		  -- pl_typ_id is available in plan record
		  l_pl_typ_id := l_pl_rec.pl_typ_id;
		elsif p_oipl_id is not null then
		  --
		  if l_pl_typ_id is null then
		    --
		    ben_comp_object.get_object(p_pl_id => l_oipl_rec.pl_id
		    			      ,p_rec   => l_pl3_rec);
		    l_pl_typ_id := l_pl3_rec.pl_typ_id;
		    --
		  end if;
		  --
		elsif p_plip_id is not null then
		  --
		  if l_pl_typ_id is null then
		    --
		    ben_comp_object.get_object(p_pl_id => l_plip_rec.pl_id
		  			      ,p_rec   => l_pl3_rec);
		    l_pl_typ_id := l_pl3_rec.pl_typ_id;
		    --
		  end if;
		  --
		elsif p_ptip_id is not null then
		  --
		  if l_pl_typ_id is null then
		    --
		    ben_comp_object.get_object(p_ptip_id => l_ptip_rec.ptip_id
		  			      ,p_rec     => l_ptip2_rec);
		    l_pl_typ_id := l_ptip2_rec.pl_typ_id;
		    --
		  end if;
		  --
		end if;
		--
                check_sched_hrs_elig
                (p_eligy_prfl_id      => l_eligprof_dets(l_elptorrw_num).
                				eligy_prfl_id,
                 p_business_group_id  => p_business_group_id,
                 p_effective_date     => l_effective_date,
                 p_lf_evt_ocrd_dt     => p_lf_evt_ocrd_dt,
                 p_person_id	      => p_person_id,
                 p_pgm_id	      => p_par_pgm_id,
                 p_pl_id	      => nvl(p_pl_id,p_par_pl_id),
                 p_oipl_id	      => p_oipl_id,
                 p_pl_typ_id	      => l_pl_typ_id,
                 p_opt_id	      => l_oipl_rec.opt_id,
                 p_comp_obj_mode      => p_comp_obj_mode,
                 p_per_in_ler_id      => p_per_in_ler_id,
                 p_score_compute_mode=> l_prof_score_compute,
                 p_profile_score_tab => l_profile_score_tab,
                 p_ler_id	      => p_ler_id,
                 p_jurisdiction_code  => l_jurisdiction_code,
                 p_assignment_id      => l_ass_rec.assignment_id,
                 p_organization_id    => l_ass_rec.organization_id);
              end if;
              --
              if l_eligprof_dets(l_elptorrw_num).elig_fl_tm_pt_tm_flag = 'Y' then
              check_fl_tm_pt_elig
                (p_eligy_prfl_id       => l_eligprof_dets(l_elptorrw_num).
                                          eligy_prfl_id,
                 p_business_group_id   => p_business_group_id,
                 p_score_compute_mode=> l_prof_score_compute,
                 p_profile_score_tab => l_profile_score_tab,
                 p_effective_date      => nvl(l_fonm_cvg_strt_dt,l_effective_date),
                 p_employment_category => l_ass_rec.employment_category) ;
              end if;
              --
              if l_eligprof_dets(l_elptorrw_num).elig_grd_flag = 'Y' then
              check_grade_elig
                (p_eligy_prfl_id     => l_eligprof_dets(l_elptorrw_num).
                                        eligy_prfl_id,
                 p_business_group_id => p_business_group_id,
                 p_score_compute_mode=> l_prof_score_compute,
                 p_profile_score_tab => l_profile_score_tab,
                 p_effective_date    => nvl(l_fonm_cvg_strt_dt,l_effective_date),
                 p_grade_id          => l_ass_rec.grade_id);
              end if;
              --
              if l_eligprof_dets(l_elptorrw_num).elig_job_flag = 'Y' then
              check_job_elig
                (p_eligy_prfl_id     => l_eligprof_dets(l_elptorrw_num).
                                        eligy_prfl_id,
                 p_business_group_id => p_business_group_id,
                 p_score_compute_mode=> l_prof_score_compute,
                 p_profile_score_tab => l_profile_score_tab,
                 p_effective_date    => nvl(l_fonm_cvg_strt_dt,l_effective_date),
                 p_job_id            => l_ass_rec.job_id);
              end if;
              --
              if l_eligprof_dets(l_elptorrw_num).elig_py_bss_flag = 'Y' then
              check_py_bss_elig
                (p_eligy_prfl_id     => l_eligprof_dets(l_elptorrw_num).
                                        eligy_prfl_id,
                 p_business_group_id => p_business_group_id,
                 p_score_compute_mode=> l_prof_score_compute,
                 p_profile_score_tab => l_profile_score_tab,
                 p_effective_date    => nvl(l_fonm_cvg_strt_dt,l_effective_date),
                 p_pay_basis_id      => l_ass_rec.pay_basis_id);
              end if;
              --
              if l_eligprof_dets(l_elptorrw_num).elig_pyrl_flag = 'Y' then
              check_pyrl_elig
                (p_eligy_prfl_id     => l_eligprof_dets(l_elptorrw_num).
                                        eligy_prfl_id,
                 p_business_group_id => p_business_group_id,
                 p_score_compute_mode=> l_prof_score_compute,
                 p_profile_score_tab => l_profile_score_tab,
                 p_effective_date    => nvl(l_fonm_cvg_strt_dt,l_effective_date),
                 p_payroll_id        => l_ass_rec.payroll_id);
              end if;
              --
              if l_eligprof_dets(l_elptorrw_num).elig_brgng_unit_flag = 'Y' then
              check_brgng_unit_elig
                (p_eligy_prfl_id        => l_eligprof_dets(l_elptorrw_num).
                                           eligy_prfl_id,
                 p_business_group_id    => p_business_group_id,
                 p_score_compute_mode=> l_prof_score_compute,
                 p_profile_score_tab => l_profile_score_tab,
                 p_effective_date       => nvl(l_fonm_cvg_strt_dt,l_effective_date),
                 p_bargaining_unit_code => l_ass_rec.bargaining_unit_code);
              end if;
              --
              if l_eligprof_dets(l_elptorrw_num).elig_lbr_mmbr_flag = 'Y' then
              check_lbr_union_elig
                (p_eligy_prfl_id     => l_eligprof_dets(l_elptorrw_num).
                                        eligy_prfl_id,
                 p_business_group_id => p_business_group_id,
                 p_score_compute_mode=> l_prof_score_compute,
                 p_profile_score_tab => l_profile_score_tab,
                 p_effective_date    => nvl(l_fonm_cvg_strt_dt,l_effective_date),
                 p_labour_union_member_flag => l_ass_rec.labour_union_member_flag);
              end if;
              --
              if l_eligprof_dets(l_elptorrw_num).elig_hrly_slrd_flag = 'Y' then
              check_py_freq_elig
                (p_eligy_prfl_id     => l_eligprof_dets(l_elptorrw_num).
                                        eligy_prfl_id,
                 p_business_group_id => p_business_group_id,
                 p_score_compute_mode=> l_prof_score_compute,
                 p_profile_score_tab => l_profile_score_tab,
                 p_effective_date    => nvl(l_fonm_cvg_strt_dt,l_effective_date),
                 p_hourly_salaried_code => l_ass_rec.hourly_salaried_code);
              end if;
              --
              if l_eligprof_dets(l_elptorrw_num).elig_loa_rsn_flag = 'Y' then
              check_loa_rsn_elig
              (p_eligy_prfl_id     => l_eligprof_dets(l_elptorrw_num).
                                      eligy_prfl_id,
               p_person_id         => p_person_id,
               p_business_group_id => p_business_group_id,
               p_score_compute_mode=> l_prof_score_compute,
               p_profile_score_tab => l_profile_score_tab,
               p_assignment_id     => l_ass_rec.assignment_id,
               p_assignment_type   => l_ass_rec.assignment_type,
               p_abs_attd_type_id  => l_absence_attendance_type_id,
               p_abs_attd_reason_id => l_absence_attendance_reason_id,
               p_effective_date    => nvl(l_fonm_cvg_strt_dt,l_effective_date));
              end if;
             --
              hr_utility.set_location(' here 2 ',999);
              if l_ass_rec.soft_coding_keyflex_id is not null then
                --
                ben_person_object.get_object
                  (p_soft_coding_keyflex_id => l_ass_rec.soft_coding_keyflex_id,
                   p_rec                    => l_hsc_rec);
                --
                if l_hsc_rec.segment1 is not null and
                   hr_api.return_legislation_code(p_business_group_id) = 'US'
                then
                  --
                  ben_org_object.get_object
                    (p_organization_id => l_hsc_rec.segment1,
                     p_rec             => l_org_rec);
                  --
                end if;
                --
              end if;
              --
              if l_eligprof_dets(l_elptorrw_num).elig_lgl_enty_flag = 'Y'
              and hr_api.return_legislation_code(p_business_group_id) = 'US'
              then
              check_lgl_enty_elig
                (p_eligy_prfl_id     => l_eligprof_dets(l_elptorrw_num).
                                        eligy_prfl_id,
                 p_business_group_id => p_business_group_id,
                 p_score_compute_mode=> l_prof_score_compute,
                 p_profile_score_tab => l_profile_score_tab,
                 p_effective_date    => nvl(l_fonm_cvg_strt_dt,l_effective_date),
                 p_gre_name          => l_org_rec.name);
              end if;
              -- RBC

              if l_eligprof_dets(l_elptorrw_num).elig_crit_values_flag = 'Y' then

                 ben_evaluate_elig_criteria.main
                 (p_eligy_prfl_id        => l_eligprof_dets(l_elptorrw_num).eligy_prfl_id,
                  p_person_id            => p_person_id,
                  p_assignment_id        => nvl(p_assignment_id,l_ass_rec.assignment_id),
                  p_business_group_id    => p_business_group_id,
                  p_pgm_id               => p_par_pgm_id,
                  p_pl_id                => nvl(p_pl_id,p_par_pl_id),
                  p_opt_id               => l_oipl_rec.opt_id,
                  p_oipl_id              => p_oipl_id,
                  p_ler_id               => p_ler_id,
                  p_pl_typ_id            => l_pl_typ_id,
                  p_effective_date       => nvl(p_lf_evt_ocrd_dt,p_effective_date),
                  p_fonm_cvg_strt_date   => ben_manage_life_events.g_fonm_cvg_strt_dt,
                  p_fonm_rt_strt_date    => ben_manage_life_events.g_fonm_cvg_strt_dt,
                  p_crit_ovrrd_val_tbl   => l_crit_ovrrd_val_tab) ;

              end if ;

              if l_eligprof_dets(l_elptorrw_num).eligy_prfl_rl_flag = 'Y' then
              hr_utility.set_location(l_proc||' Chk Rule',48);

              -- Bug# 2424041 pl_typ_id context is not being passed to the formula
	      if p_pgm_id is not null then
	          -- pl_typ_id is not available at pgm level
	          null;
	      elsif p_pl_id is not null then
	          -- pl_typ_id is available in plan record
		  l_pl_typ_id := l_pl_rec.pl_typ_id;
	      elsif p_oipl_id is not null then
		  open c_oipl_pl_typ(nvl(l_fonm_cvg_strt_dt,
                                        nvl(p_lf_evt_ocrd_dt,p_effective_date)));
		  fetch c_oipl_pl_typ into l_pl_typ_id;
		  close c_oipl_pl_typ;
	      elsif p_plip_id is not null then
		  open c_plip_pl_typ(nvl(l_fonm_cvg_strt_dt,
                                           nvl(p_lf_evt_ocrd_dt,p_effective_date)));
		  fetch c_plip_pl_typ into l_pl_typ_id;
		  close c_plip_pl_typ;
	      elsif p_ptip_id is not null then
		  open c_ptip_pl_typ(nvl(l_fonm_cvg_strt_dt,
                                          nvl(p_lf_evt_ocrd_dt,p_effective_date)));
		  fetch c_ptip_pl_typ into l_pl_typ_id;
		  close c_ptip_pl_typ;
	      end if;
	      -- End bug# 2424041
	      --
              check_rule_elig
                (p_person_id         => p_person_id
                ,p_business_group_id => p_business_group_id
                ,p_pgm_id            => p_par_pgm_id
                ,p_pl_id             => nvl(p_pl_id,p_par_pl_id)
                ,p_oipl_id           => p_oipl_id
                ,p_ler_id            => p_ler_id
                ,p_eligy_prfl_id     => l_eligprof_dets(l_elptorrw_num).
                                        eligy_prfl_id
                ,p_effective_date    => nvl(p_lf_evt_ocrd_dt,p_effective_date)
                ,p_score_compute_mode=> l_prof_score_compute
                ,p_profile_score_tab => l_profile_score_tab
                ,p_assignment_id     => l_ass_rec.assignment_id
		,p_pl_typ_id         => l_pl_typ_id
		,p_organization_id   => l_ass_rec.organization_id
                );
              end if;
              --
              -- Assignment must have been successful so exit and carry on
              -- checking profiles.
              --
              exit;
              --
            exception
              --
              when g_skip_profile then
                   hr_utility.set_location('skip 1',20);
                   raise g_skip_profile;
              when g_criteria_failed then
                --
                -- Handle case where we want an error if we are dealing with
                -- the last assignment to be processed. If it is the last
                -- assignment then we want to error the profile.
                --
                -- # bug - 3270301
                --
                if  (l_count = l_loop_count and l_eligprof_dets.count = 1 ) then
                  --
                  -- Raise error to main exception handler
                  --
                  if g_score_compute_mode then
                     g_per_eligible := false;
                     raise g_criteria_failed ;
                  else
                     return false;
                  end if;
                  --
                else
                  -- continue dont error, chk for other profiles
                  -- if all assignments have been checked
                  --
                  if  l_count = l_loop_count then
                      raise g_criteria_failed ;
                  end if ;
                  --
                end if;
                --
                hr_utility.set_location(l_proc||' Crit Failed ',48);
               --
               -- Bug 8685338 --  Person should error out instead
               -- of failing the criteria.
               --
              /* when others then
                --
                -- Catch any unhandled exceptions
                --
                hr_utility.set_location(l_proc||' Crit Failed ',49);
                return false; */
                --
            end;
            --
          end loop;
          --
          -- Check these criteria only if the person is an employee who is
          -- not terminated:
          --
          hr_utility.set_location(' here 3 ',999);
          if p_person_id is not null and
             l_typ_rec(1).system_person_type = 'EMP' and
             nvl(p_asg_status,hr_api.g_varchar2) <> 'TERM_ASSIGN' then

            hr_utility.set_location(l_proc||' Not TERM ASSIGN',48);

            if l_eligprof_dets(l_elptorrw_num).elig_pct_fl_tm_flag = 'Y' then
               --
               -- for Vapros, get the values from elig_per and elig_per_opt ??
               --
               if p_comp_obj_mode and
                  p_eval_typ <> 'E' then
                  l_pct_fl_tm_val := get_rt_pct_fltm
                          (p_person_id         => p_person_id
                          ,p_business_group_id => p_business_group_id
                          ,p_effective_date    => p_effective_date
                          ,p_opt_id            => p_opt_id
                          ,p_plip_id           => p_plip_id
                          ,p_pl_id             => p_pl_id
                          ,p_pgm_id            => p_pgm_id);
               end if;

               check_pct_fltm_elig
                 (p_person_id         => p_person_id,
                  p_assignment_id     => p_assignment_id,
                  p_eligy_prfl_id     => l_eligprof_dets(l_elptorrw_num).
                                         eligy_prfl_id,
                  p_business_group_id => p_business_group_id,
                  p_evl_typ           => p_eval_typ,
                  p_comp_obj_mode     => p_comp_obj_mode,
                  p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
                  p_score_compute_mode=> l_prof_score_compute,
                  p_profile_score_tab => l_profile_score_tab,
                  p_effective_date    => l_effective_date,
                  p_per_pct_ft_val    => l_pct_fl_tm_val);
            end if;
            --
            if l_eligprof_dets(l_elptorrw_num).elig_asnt_set_flag = 'Y' then
            check_asnt_set
              (p_eligy_prfl_id     => l_eligprof_dets(l_elptorrw_num).
                                      eligy_prfl_id,
               p_business_group_id => p_business_group_id,
               p_score_compute_mode=> l_prof_score_compute,
               p_profile_score_tab => l_profile_score_tab,
               p_person_id         => p_person_id,
               p_effective_date    => nvl(l_fonm_cvg_strt_dt,l_effective_date));
            end if;
          end if;
          --
          --
              hr_utility.set_location(' here 4 ',999);
          if l_eligprof_dets(l_elptorrw_num).elig_los_flag = 'Y' then
          check_los_elig
            (p_eligy_prfl_id     => l_eligprof_dets(l_elptorrw_num).
                                    eligy_prfl_id,
             p_person_id         => p_person_id,
             p_business_group_id => p_business_group_id,
             p_effective_date    => l_effective_date,
             p_eval_typ          => p_eval_typ,
             p_comp_obj_mode     => p_comp_obj_mode,
             p_currepe_row       => p_currepe_row,
             p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
             p_per_in_ler_id     => p_per_in_ler_id,
             p_score_compute_mode=> l_prof_score_compute,
             p_profile_score_tab => l_profile_score_tab,
             p_pl_id             => p_pl_id,
             p_pgm_id            => p_pgm_id,
             p_oipl_id           => p_oipl_id,
             p_plip_id           => p_plip_id,
             p_opt_id            => p_opt_id,
             p_per_los           => l_los_val);
          end if;
          --
          if l_eligprof_dets(l_elptorrw_num).elig_cmbn_age_los_flag = 'Y' then
          check_age_los_elig
            (p_eligy_prfl_id     => l_eligprof_dets(l_elptorrw_num).
                                    eligy_prfl_id,
             p_person_id         => p_person_id,
             p_business_group_id => p_business_group_id,
             p_effective_date    => l_effective_date,
             p_per_cmbn_age_los  => l_cmbn_age_n_los_val,
             p_per_cmbn_age      => l_comb_age,
             p_per_cmbn_los      => l_comb_los,
             p_dob               => l_per_rec.date_of_birth,
             p_eval_typ          => p_eval_typ,
             p_comp_obj_mode     => p_comp_obj_mode,
             p_currepe_row       => p_currepe_row,
             p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
             p_score_compute_mode=> l_prof_score_compute,
             p_profile_score_tab => l_profile_score_tab,
             p_per_in_ler_id     => p_per_in_ler_id,
             p_pl_id             => p_pl_id,
             p_pgm_id            => p_pgm_id,
             p_oipl_id           => p_oipl_id,
             p_plip_id           => p_plip_id,
             p_opt_id            => p_opt_id);
          end if;
          --
          hr_utility.set_location(l_proc||' check_comp_level_elig',50);
          if l_eligprof_dets(l_elptorrw_num).elig_comp_lvl_flag = 'Y' then
          check_comp_level_elig
            (p_eligy_prfl_id     => l_eligprof_dets(l_elptorrw_num).
                                    eligy_prfl_id,
             p_business_group_id => p_business_group_id,
             p_effective_date    => l_effective_date,
             p_comp_obj_mode     => p_comp_obj_mode,
             p_pgm_id            => nvl(p_pgm_id, p_par_pgm_id), --Bug 2424654
             p_pl_id             => nvl(p_pl_id,p_par_pl_id),
             p_oipl_id           => p_oipl_id,
             p_person_id         => p_person_id,
             p_per_in_ler_id     => l_per_in_ler_id,
             p_score_compute_mode=> l_prof_score_compute,
             p_profile_score_tab => l_profile_score_tab,
             p_per_comp_val      => l_comp_ref_amt);
          end if;
          --
          if l_eligprof_dets(l_elptorrw_num).elig_comp_lvl_flag = 'Y' then
          check_comp_level_rl_elig
            (p_eligy_prfl_id     => l_eligprof_dets(l_elptorrw_num).
                                    eligy_prfl_id,
             p_person_id         => p_person_id,
             p_business_group_id => p_business_group_id,
             p_effective_date    => l_effective_date,
             p_per_comp_val      => l_comp_ref_amt,
             p_eval_typ          => p_eval_typ,
             p_comp_obj_mode     => p_comp_obj_mode,
             p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
             p_per_in_ler_id     => p_per_in_ler_id,
             p_score_compute_mode=> l_prof_score_compute,
             p_profile_score_tab => l_profile_score_tab,
             p_pl_id             => p_pl_id,
             p_pgm_id            => p_pgm_id,
             p_oipl_id           => p_oipl_id,
             p_plip_id           => p_plip_id,
             p_opt_id            => p_opt_id);
          end if;
          --
          if l_eligprof_dets(l_elptorrw_num).elig_comp_lvl_flag = 'Y' then
          check_person_ben_bal
            (p_eligy_prfl_id     => l_eligprof_dets(l_elptorrw_num).
                                    eligy_prfl_id,
             p_person_id         => p_person_id,
             p_business_group_id => p_business_group_id,
             p_effective_date    => l_effective_date,
             p_per_comp_val      => l_comp_ref_amt,
             p_eval_typ          => p_eval_typ,
             p_comp_obj_mode     => p_comp_obj_mode,
             p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
             p_per_in_ler_id     => p_per_in_ler_id,
             p_score_compute_mode=> l_prof_score_compute,
             p_profile_score_tab => l_profile_score_tab,
             p_pl_id             => p_pl_id,
             p_pgm_id            => p_pgm_id,
             p_oipl_id           => p_oipl_id,
             p_plip_id           => p_plip_id,
             p_opt_id            => p_opt_id);
          end if;
          --
          hr_utility.set_location(l_proc||' check_person_balance',52);
          if l_eligprof_dets(l_elptorrw_num).elig_comp_lvl_flag = 'Y' then
          check_person_balance
            (p_eligy_prfl_id     => l_eligprof_dets(l_elptorrw_num).
                                    eligy_prfl_id,
             p_person_id         => p_person_id,
             p_business_group_id => p_business_group_id,
             p_effective_date    => l_effective_date,
             p_per_comp_val      => l_comp_ref_amt,
             p_eval_typ          => p_eval_typ,
             p_comp_obj_mode     => p_comp_obj_mode,
             p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
             p_per_in_ler_id     => p_per_in_ler_id,
             p_score_compute_mode=> l_prof_score_compute,
             p_profile_score_tab => l_profile_score_tab,
             p_pl_id             => p_pl_id,
             p_pgm_id            => p_pgm_id,
             p_oipl_id           => p_oipl_id,
             p_plip_id           => p_plip_id,
             p_opt_id            => p_opt_id);
          end if;
          --
          if l_eligprof_dets(l_elptorrw_num).elig_hrs_wkd_flag = 'Y' then
          hr_utility.set_location(l_proc||' check_hrs_wkd_ben_bal',54);

             if p_comp_obj_mode and
                p_eval_typ <> 'E' then
                --
                -- for Vapros, get the values from elig_per and elig_per_opt ??
                --
                l_hrs_wkd_val := get_rt_hrs_wkd
                                 (p_person_id         => p_person_id
                                 ,p_business_group_id => p_business_group_id
                                 ,p_effective_date    =>
                                       nvl(l_fonm_cvg_strt_dt,l_effective_date)
                                 ,p_opt_id            => p_opt_id
                                 ,p_plip_id           => p_plip_id
                                 ,p_pl_id             => p_pl_id
                                 ,p_pgm_id            => p_pgm_id);
             end if;

             check_hrs_wkd_ben_bal
               (p_person_id         => p_person_id,
                p_assignment_id     => p_assignment_id,
                p_eligy_prfl_id     => l_eligprof_dets(l_elptorrw_num).
                                       eligy_prfl_id,
                p_once_r_cntug_cd   => l_once_r_cntug_cd,
                p_elig_flag         => l_comp_elig_flag,
                p_business_group_id => p_business_group_id,
                p_comp_obj_mode     => p_comp_obj_mode,
                p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
                p_score_compute_mode=> l_prof_score_compute,
                p_profile_score_tab => l_profile_score_tab,
                p_effective_date    => nvl(l_fonm_cvg_strt_dt,l_effective_date),
                p_per_hrs_wkd       => l_hrs_wkd_val);
             --
             check_hrs_wkd_balance
               (p_person_id         => p_person_id,
                p_assignment_id     => p_assignment_id,
                p_eligy_prfl_id     => l_eligprof_dets(l_elptorrw_num).
                                       eligy_prfl_id,
                p_once_r_cntug_cd   => l_once_r_cntug_cd,
                p_elig_flag         => l_comp_elig_flag,
                p_business_group_id => p_business_group_id,
                p_score_compute_mode=> l_prof_score_compute,
                p_profile_score_tab => l_profile_score_tab,
                p_comp_obj_mode     => p_comp_obj_mode,
                p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
                p_effective_date    => nvl(l_fonm_cvg_strt_dt,l_effective_date),
                p_per_hrs_wkd       => l_hrs_wkd_val);
             --
             check_hrs_wkd_rl_balance
               (p_person_id         => p_person_id,
                p_assignment_id     => p_assignment_id,
                p_eligy_prfl_id     => l_eligprof_dets(l_elptorrw_num).
                                       eligy_prfl_id,
                p_once_r_cntug_cd   => l_once_r_cntug_cd,
                p_elig_flag         => l_comp_elig_flag,
                p_business_group_id => p_business_group_id,
                p_score_compute_mode=> l_prof_score_compute,
                p_profile_score_tab => l_profile_score_tab,
                p_comp_obj_mode     => p_comp_obj_mode,
                p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
                p_effective_date    => nvl(l_fonm_cvg_strt_dt,l_effective_date),
                p_per_hrs_wkd       => l_hrs_wkd_val);
             --
          end if;
          --
          hr_utility.set_location(l_proc||' check_age_elig',56);
          if l_eligprof_dets(l_elptorrw_num).elig_age_flag = 'Y' then
          check_age_elig
            (p_eligy_prfl_id          => l_eligprof_dets(l_elptorrw_num).
                                    eligy_prfl_id,
             p_business_group_id      => p_business_group_id,
             p_effective_date         => l_effective_date,
             p_person_id              => p_person_id,
             p_per_age                => l_age_val,
             p_per_dob                => l_per_rec.date_of_birth,
             p_eval_typ               => p_eval_typ,
             p_comp_obj_mode          => p_comp_obj_mode,
             p_currepe_row            => p_currepe_row,
             p_lf_evt_ocrd_dt         => p_lf_evt_ocrd_dt,
             p_per_in_ler_id          => p_per_in_ler_id,
             p_score_compute_mode     => l_prof_score_compute,
             p_profile_score_tab      => l_profile_score_tab,
             p_pl_id                  => p_pl_id,
             p_pgm_id                 => p_pgm_id,
             p_oipl_id                => p_oipl_id,
             p_plip_id                => p_plip_id,
             p_opt_id                 => p_opt_id);
          end if;
          --
          hr_utility.set_location(l_proc||' Zip Code',48);
          if l_eligprof_dets(l_elptorrw_num).elig_pstl_cd_flag = 'Y' then
          check_zip_code_rng_elig
            (p_eligy_prfl_id     => l_eligprof_dets(l_elptorrw_num).
                                    eligy_prfl_id,
             p_person_id         => p_person_id,
             p_business_group_id => p_business_group_id,
             p_score_compute_mode=> l_prof_score_compute,
             p_profile_score_tab => l_profile_score_tab,
             p_postal_code       => l_postal_code,
             p_effective_date    => nvl(l_fonm_cvg_strt_dt,l_effective_date));
          end if;
          hr_utility.set_location(l_proc||' check_service_a',60);
          --
          if l_eligprof_dets(l_elptorrw_num).elig_svc_area_flag = 'Y' then
          check_service_area_elig
            (p_eligy_prfl_id     => l_eligprof_dets(l_elptorrw_num).
                                    eligy_prfl_id,
             p_person_id         => p_person_id,
             p_business_group_id => p_business_group_id,
             p_score_compute_mode=> l_prof_score_compute,
             p_profile_score_tab => l_profile_score_tab,
             p_postal_code       => l_postal_code,
             p_effective_date    => nvl(l_fonm_cvg_strt_dt,l_effective_date));
          end if;
          --
          hr_utility.set_location(l_proc||' check_benefits_grp_elig',62);
          if l_eligprof_dets(l_elptorrw_num).elig_benfts_grp_flag = 'Y' then
          check_benefits_grp_elig
            (p_eligy_prfl_id     => l_eligprof_dets(l_elptorrw_num).
                                    eligy_prfl_id,
             p_business_group_id => p_business_group_id,
             p_score_compute_mode=> l_prof_score_compute,
             p_profile_score_tab => l_profile_score_tab,
             p_effective_date    => nvl(l_fonm_cvg_strt_dt,l_effective_date),
             p_benefit_group_id  => l_per_rec.benefit_group_id);
          end if;
          --
          if l_eligprof_dets(l_elptorrw_num).elig_prtt_pl_flag = 'Y' then
          check_prtt_in_anthr_pl_elig
            (p_eligy_prfl_id         => l_eligprof_dets(l_elptorrw_num).
                                        eligy_prfl_id,
             p_person_id             => p_person_id,
             p_business_group_id     => p_business_group_id,
             p_effective_date        => nvl(l_fonm_cvg_strt_dt,p_effective_date),
             p_lf_evt_ocrd_dt        => p_lf_evt_ocrd_dt);
          end if;
          --
          -- start -- new criteria checks
          -- ----------------------------------------------------------------------
          --
          --         competency
          --
          if l_eligprof_dets(l_elptorrw_num).elig_comptncy_flag = 'Y' then
          check_comptncy_elig
	          (p_eligy_prfl_id     => l_eligprof_dets(l_elptorrw_num).
	                                    eligy_prfl_id,
	           p_business_group_id => p_business_group_id,
                   p_score_compute_mode=> l_prof_score_compute,
                   p_profile_score_tab => l_profile_score_tab,
	           p_person_id         => p_person_id,
                   p_competence_id     => l_competence_id,
                   p_rating_level_id   => l_rating_level_id,
	           p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
                   p_effective_date    => p_effective_date);
	  end if;
	  --
	  --         health coverage
	  --
          if l_eligprof_dets(l_elptorrw_num).elig_hlth_cvg_flag = 'Y' then
          check_hlth_cvg_elig
	          (p_eligy_prfl_id     => l_eligprof_dets(l_elptorrw_num).
	                                    eligy_prfl_id,
	           p_business_group_id => p_business_group_id,
	           p_person_id         => p_person_id,
	           p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
                   p_effective_date    => p_effective_date);
	  end if;
          --
          --         participation in another plan
          --
          if l_eligprof_dets(l_elptorrw_num).elig_anthr_pl_flag = 'Y' then
          check_anthr_pl_elig
	          (p_eligy_prfl_id     => l_eligprof_dets(l_elptorrw_num).
	                                    eligy_prfl_id,
	           p_business_group_id => p_business_group_id,
	           p_person_id         => p_person_id,
	           p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
                   p_effective_date    => p_effective_date);
          end if;

          if not p_all_prfls then
             --
             --         total participants
             --
             if l_eligprof_dets(l_elptorrw_num).elig_ttl_prtt_flag = 'Y' then
             check_ttl_prtt_elig
	     	   (p_eligy_prfl_id     => l_eligprof_dets(l_elptorrw_num).
	     	                           eligy_prfl_id,
	     	    p_business_group_id => p_business_group_id,
	            p_person_id         => p_person_id ,
                    p_ttl_prtt          => p_ttl_prtt,
                    p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
                    p_effective_date    => p_effective_date);
             end if;
             --
             --         total coverage volume
             --
             if l_eligprof_dets(l_elptorrw_num).elig_ttl_cvg_vol_flag = 'Y' then
             check_ttl_cvg_vol_elig
	     	   (p_eligy_prfl_id     => l_eligprof_dets(l_elptorrw_num).
	     	                           eligy_prfl_id,
	     	    p_business_group_id => p_business_group_id,
                    p_person_id         => p_person_id ,
                    p_ttl_cvg           => p_ttl_cvg,
	     	    p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
                    p_effective_date    => p_effective_date);

             end if;
          end if;
          --
          --         tobacco use
          --
          if l_eligprof_dets(l_elptorrw_num).elig_tbco_use_flag = 'Y' then
          check_tbco_use_elig
	          (p_eligy_prfl_id  => l_eligprof_dets(l_elptorrw_num).
	  	                       eligy_prfl_id,
	           p_effective_date => nvl(l_fonm_cvg_strt_dt,p_effective_date),
                   p_score_compute_mode=> l_prof_score_compute,
                   p_profile_score_tab => l_profile_score_tab,
        	   p_tbco_use_flag  => l_per_rec.uses_tobacco_flag );
          end if ;
          --
          --	      disabled
          --
          if l_eligprof_dets(l_elptorrw_num).elig_dsbld_flag = 'Y' then
          check_dsbld_elig
	    	  (p_eligy_prfl_id  => l_eligprof_dets(l_elptorrw_num).eligy_prfl_id,
	      	   p_effective_date => nvl(l_fonm_cvg_strt_dt,p_effective_date),
                   p_score_compute_mode=> l_prof_score_compute,
                   p_profile_score_tab => l_profile_score_tab,
  		   p_dsbld_cd       => l_per_rec.registered_disabled_flag);
	  end if ;
	  --
	  --  Performance rating
	  --
          if l_eligprof_dets(l_elptorrw_num).elig_perf_rtng_flag = 'Y' then
	  check_perf_rtng_elig
	        (p_eligy_prfl_id     => l_eligprof_dets(l_elptorrw_num).eligy_prfl_id,
	         p_business_group_id => p_business_group_id ,
	         p_person_id         => p_person_id ,
                 p_perf_rtng_cd      => l_perf_rtng_cd,
                 p_event_type        => l_event_type,
                 p_score_compute_mode=> l_prof_score_compute,
                 p_profile_score_tab => l_profile_score_tab,
	         p_lf_evt_ocrd_dt    => nvl(l_fonm_cvg_strt_dt,p_lf_evt_ocrd_dt),
	         p_effective_date    => nvl(l_fonm_cvg_strt_dt,p_effective_date) );
	  end if ;
          --
          -- Quartile in grade
          --
          if l_eligprof_dets(l_elptorrw_num).elig_qua_in_gr_flag = 'Y' then
          check_qua_in_gr_elig
	    	  (p_eligy_prfl_id     => l_eligprof_dets(l_elptorrw_num).eligy_prfl_id,
	      	   p_effective_date    => nvl(l_fonm_cvg_strt_dt,p_effective_date),
	      	   p_business_group_id => p_business_group_id ,
	      	   p_person_id         => p_person_id ,
	      	   p_assignment_id     => l_ass_rec.assignment_id ,
  		   p_grade_id          => l_ass_rec.grade_id ,
	      	   p_lf_evt_ocrd_dt    => nvl(l_fonm_cvg_strt_dt,p_lf_evt_ocrd_dt) ,
                   p_score_compute_mode=> l_prof_score_compute,
                   p_profile_score_tab => l_profile_score_tab,
	      	   p_pay_basis_id      => l_ass_rec.pay_basis_id);
	  end if ;
          --
	  --   end - new criteria checks
          -- ----------------------------------------------------------------------
          -- Only check these profiles if we are dealing with a cobra program
          --
           -- Bug 7411918: moved out leaving reason elig criteria out of the if condition for cobra program

           if l_eligprof_dets(l_elptorrw_num).elig_lvg_rsn_flag = 'Y' then
            check_elig_lvg_rsn_prte
              (p_eligy_prfl_id         => l_eligprof_dets(l_elptorrw_num).
                                          eligy_prfl_id,
               p_person_id             => p_person_id,
               p_business_group_id     => p_business_group_id,
               p_score_compute_mode    => l_prof_score_compute,
               p_profile_score_tab     => l_profile_score_tab,
               p_leaving_reason        => l_leaving_reason,
               p_effective_date        => nvl(l_fonm_cvg_strt_dt,l_effective_date));
           end if;
           --

          hr_utility.set_location(l_proc||' cobra',64);
          if p_par_pgm_id is not null or
             p_eval_typ <> 'E' then
            --
            -- We are dealing with a program hierarchy
            --
            if l_eligprof_dets(l_elptorrw_num).elig_ptip_prte_flag = 'Y' then
            ben_elpro_check_eligibility.check_elig_othr_ptip_prte
              (p_eligy_prfl_id     => l_eligprof_dets(l_elptorrw_num).
                                          eligy_prfl_id
              ,p_business_group_id => p_business_group_id
              ,p_effective_date    => p_effective_date
              ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
              ,p_person_id         => p_person_id
              --
              ,p_per_in_ler_id     => p_per_in_ler_id
              );
            end if;
            --
            if l_eligprof_dets(l_elptorrw_num).elig_dpnt_othr_ptip_flag = 'Y' then
            ben_elpro_check_eligibility.check_elig_dpnt_othr_ptip
              (p_eligy_prfl_id     => l_eligprof_dets(l_elptorrw_num).
                                          eligy_prfl_id
              ,p_business_group_id => p_business_group_id
              ,p_effective_date    => p_effective_date
              ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
              ,p_person_id         => p_person_id
              --
              ,p_per_in_ler_id     => p_per_in_ler_id
              );
            end if;
            --
            --
            if l_eligprof_dets(l_elptorrw_num).elig_no_othr_cvg_flag = 'Y' then
            check_elig_no_othr_cvg_prte
              (p_eligy_prfl_id         => l_eligprof_dets(l_elptorrw_num).
                                          eligy_prfl_id,
               p_person_id             => p_person_id,
               p_business_group_id     => p_business_group_id,
               p_effective_date        => nvl(l_fonm_cvg_strt_dt,l_effective_date));
            end if;
            --
            --
            if l_eligprof_dets(l_elptorrw_num).elig_optd_mdcr_flag = 'Y' then
            check_elig_optd_mdcr_prte
              (p_eligy_prfl_id         => l_eligprof_dets(l_elptorrw_num).
                                          eligy_prfl_id,
               p_person_id             => p_person_id,
               p_business_group_id     => p_business_group_id,
               p_effective_date        => nvl(l_fonm_cvg_strt_dt,l_effective_date));
            end if;
            --
            if l_eligprof_dets(l_elptorrw_num).elig_enrld_pl_flag = 'Y' then
            check_elig_enrld_anthr_pl
              (p_eligy_prfl_id         => l_eligprof_dets(l_elptorrw_num).
                                          eligy_prfl_id,
               p_business_group_id     => p_business_group_id,
               p_pl_id                 => p_pl_id,
               p_person_id             => p_person_id,
               p_effective_date        => p_effective_date,
               p_lf_evt_ocrd_dt        => p_lf_evt_ocrd_dt);
            end if;
            --
            if l_eligprof_dets(l_elptorrw_num).elig_enrld_oipl_flag = 'Y' then
            check_elig_enrld_anthr_oipl
              (p_eligy_prfl_id         => l_eligprof_dets(l_elptorrw_num).
                                          eligy_prfl_id,
               p_business_group_id     => p_business_group_id,
               p_oipl_id               => p_oipl_id,
               p_person_id             => p_person_id,
               p_effective_date        => p_effective_date,
               p_lf_evt_ocrd_dt        => p_lf_evt_ocrd_dt);
            end if;
            --
            if l_eligprof_dets(l_elptorrw_num).elig_enrld_pgm_flag = 'Y' then
            check_elig_enrld_anthr_pgm
              (p_eligy_prfl_id         => l_eligprof_dets(l_elptorrw_num).
                                          eligy_prfl_id,
               p_business_group_id     => p_business_group_id,
               p_pgm_id                => p_pgm_id,
               p_person_id             => p_person_id,
               p_effective_date        => p_effective_date,
               p_lf_evt_ocrd_dt        => p_lf_evt_ocrd_dt);
            end if;
            --
            if l_eligprof_dets(l_elptorrw_num).elig_dpnt_cvrd_pl_flag = 'Y' then
            check_elig_dpnt_cvrd_othr_pl
              (p_eligy_prfl_id         => l_eligprof_dets(l_elptorrw_num).
                                          eligy_prfl_id,
               p_business_group_id     => p_business_group_id,
               p_pl_id                 => p_pl_id,
               p_person_id             => p_person_id,
               p_effective_date        => p_effective_date,
               p_lf_evt_ocrd_dt        => p_lf_evt_ocrd_dt);
            end if;
            --
            if l_eligprof_dets(l_elptorrw_num).elig_enrld_plip_flag = 'Y' then
            check_elig_enrld_anthr_plip
              (p_eligy_prfl_id         => l_eligprof_dets(l_elptorrw_num).
                                          eligy_prfl_id,
               p_business_group_id     => p_business_group_id,
               p_person_id             => p_person_id,
               p_effective_date        => p_effective_date,
               p_lf_evt_ocrd_dt        => p_lf_evt_ocrd_dt);
            end if;
            --
            if l_eligprof_dets(l_elptorrw_num).elig_dpnt_cvrd_plip_flag = 'Y' then
            check_elig_dpnt_cvrd_othr_plip
              (p_eligy_prfl_id         => l_eligprof_dets(l_elptorrw_num).
                                          eligy_prfl_id,
               p_business_group_id     => p_business_group_id,
               p_person_id             => p_person_id,
               p_effective_date        => p_effective_date,
               p_lf_evt_ocrd_dt        => p_lf_evt_ocrd_dt);
            end if;
            --
            if l_eligprof_dets(l_elptorrw_num).elig_enrld_ptip_flag = 'Y' then
            check_elig_enrld_anthr_ptip
              (p_eligy_prfl_id         => l_eligprof_dets(l_elptorrw_num).
                                          eligy_prfl_id,
               p_business_group_id     => p_business_group_id,
               p_effective_date        => p_effective_date,
               p_lf_evt_ocrd_dt        => p_lf_evt_ocrd_dt);
            end if;
            --
            if l_eligprof_dets(l_elptorrw_num).elig_dpnt_cvrd_ptip_flag = 'Y' then
            check_elig_dpnt_cvrd_othr_ptip
              (p_eligy_prfl_id         => l_eligprof_dets(l_elptorrw_num).
                                          eligy_prfl_id,
               p_business_group_id     => p_business_group_id,
               p_person_id             => p_person_id,
               p_effective_date        => p_effective_date,
               p_lf_evt_ocrd_dt        => p_lf_evt_ocrd_dt);
            end if;
            --
            if l_eligprof_dets(l_elptorrw_num).elig_dpnt_cvrd_pgm_flag = 'Y' then
            check_elig_dpnt_cvrd_othr_pgm
              (p_eligy_prfl_id         => l_eligprof_dets(l_elptorrw_num).
                                          eligy_prfl_id,
               p_business_group_id     => p_business_group_id,
               p_person_id             => p_person_id,
               p_effective_date        => p_effective_date,
               p_lf_evt_ocrd_dt        => p_lf_evt_ocrd_dt);
            end if;
            --
            if l_eligprof_dets(l_elptorrw_num).elig_cbr_quald_bnf_flag = 'Y' then
            check_elig_cbr_quald_bnf
              (p_eligy_prfl_id         => l_eligprof_dets(l_elptorrw_num).
                                          eligy_prfl_id,
               p_person_id             => p_person_id,
               p_business_group_id     => p_business_group_id,
               p_lf_evt_ocrd_dt        => nvl(l_fonm_cvg_strt_dt,p_lf_evt_ocrd_dt),
               p_effective_date        => p_effective_date);
            end if;
            --
          end if;
          hr_utility.set_location(l_proc||' Done cobra',66);
          hr_utility.set_location(l_eligprof_dets(l_elptorrw_num).eligy_prfl_id,99);
          --
          ben_cagr_check_eligibility.check_cagr_elig_profiles
            (p_eligprof_dets    => l_eligprof_dets(l_elptorrw_num)
            ,p_effective_date   => nvl(l_fonm_cvg_strt_dt,p_effective_date)
            --
            ,p_person_id        => p_person_id
            ,p_score_compute_mode=> l_prof_score_compute
            ,p_profile_score_tab => l_profile_score_tab
            ,p_per_sex          => l_per_rec.sex
            ,p_per_mar_status   => l_per_rec.marital_status
            ,p_per_qualification_type_id  => l_qualification_type_id
            ,p_per_title        => l_title
            ,p_asg_job_id       => l_ass_rec.job_id
            ,p_asg_position_id  => l_ass_rec.position_id
            ,p_asg_prob_perd    => l_ass_rec.probation_period
            ,p_asg_prob_unit    => l_ass_rec.probation_unit
            ,p_asg_sps_id       => l_ass_rec.special_ceiling_step_id
            );
          --
          -- If we get here, then all the criteria of the profile passed.
          -- That means profile passed.
          --
          if l_eligprof_dets(l_elptorrw_num).mndtry_flag = 'N' then
            --
            -- If we are in a optional profile, that means we passed all
            -- the mandatory profiles.
            -- If the mt_one flag = 'Y', then we only need to meet one of
            -- the optional
            -- profiles for the person to be eligible.  Go on to check rules.
            --
            l_ok_so_far := 'Y';
            if g_score_compute_mode then
               if g_per_eligible is null then
                  g_per_eligible := true;
               end if;
            else
               g_per_eligible := true;
               exit;
            end if;
            --
          end if;
          --
          -- Person satisified the profile. Need to store the Scores so far
          --
          if l_prof_score_compute then
             write(p_score_tab,l_profile_score_tab);
          end if;
        exception
          --
          when g_skip_profile then
               hr_utility.set_location('skip 2',20);
               null;
          when g_criteria_failed then
            --
            -- when one of the criteria of the profile fail, they raise
            -- this exception.
            -- This means the profile failed.
            --
            if l_eligprof_dets(l_elptorrw_num).mndtry_flag = 'Y' then
              --
              -- if the profile is a mandatory one,
              -- then person is not eligible for
              -- this program, plan or option in plan.  Skip checking the rules.
              --
              if g_score_compute_mode then
                 g_per_eligible := false;
              else
                 return false;
              end if;
              --
            else
              --
              -- If profile isn't mandatory, it's ok to fail it,
              -- go onto next profile but keep track of the fact that the
              -- last profile failed.
              --
              if l_ok_so_far is null then
                 l_ok_so_far := 'N';
              end if;
              --
          end if;
          --
        end;
        --
        hr_utility.set_location(l_proc||' End ELP loop ',68);
      end loop; -- elig_prfls
      --
    end if; -- inst_count
    --
    --
    hr_utility.set_location(l_proc||' After profile loop',70);
    --
    -- If we are here, either:
    --    there were no profiles or
    --    all mandatory profiles passed
    --
    --    there were no optional profiles
    --    or there are optional ones, but mt_one flag is off
    --            so we don't care and didn't check the optional profiles
    --
    --    or there are optional ones, mt_one flag is on and ONE
    -- optional profile passed or there are optional ones, mt_one flag is
    -- off and ALL optional profiles failed.
    --
    if l_ok_so_far = 'N' then
      --
      -- there are optional profiles, mt_one flag is off
      -- and all optional profiles failed
      --
      -- 5173693 Truncate the String, if too long.
       ben_manage_life_events.g_output_string :=
       SUBSTR(ben_manage_life_events.g_output_string,1,900) ||
        'Elg: No '||
        'Rsn: Opt Prfl No Pass';

      --
      -- Person failed the comp object. Decide if we need to trash the Scores
      --
      if g_score_compute_mode and
         not g_trk_scr_for_inelg_flag
      then
        l_profile_score_tab.delete;
        p_score_tab.delete;
      end if;
      return false;
      --
    end if;
    --
    if not g_per_eligible then
       --
       -- Person failed the comp object. Decide if we need to trash the Scores
       --
       if g_score_compute_mode and
          not g_trk_scr_for_inelg_flag
       then
        l_profile_score_tab.delete;
        p_score_tab.delete;
       end if;
       return false;
    end if;
    --
    hr_utility.set_location('Leaving: '||l_proc,99);
    --
    return true;
  --
end eligible;

end ben_evaluate_elig_profiles;

/
