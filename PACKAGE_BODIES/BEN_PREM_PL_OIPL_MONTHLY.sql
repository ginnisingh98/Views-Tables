--------------------------------------------------------
--  DDL for Package Body BEN_PREM_PL_OIPL_MONTHLY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PREM_PL_OIPL_MONTHLY" as
/* $Header: benprplo.pkb 120.0 2005/05/28 09:20:35 appldev noship $ */
g_package             varchar2(80) := 'ben_prem_pl_oipl_monthly';

-- ----------------------------------------------------------------------------
-- |----------------------< get_comp_object_info >----------------------------|
-- ----------------------------------------------------------------------------
-- This procedure is called from main and from ben_premium_plan_concurrent
-- to get premium comp object ids.
procedure get_comp_object_info
             (p_oipl_id       in number default null
             ,p_pl_id         in number default null
             ,p_pgm_id        in number default null
             ,p_effective_date in date
             ,p_out_pgm_id    out nocopy number
             ,p_out_pl_typ_id out nocopy number
             ,p_out_pl_id     out nocopy number
             ,p_out_opt_id    out nocopy number) is

  cursor c_opt(p_oipl_id number) is
    select oipl.opt_id, oipl.pl_id, pl.pl_typ_id
    from   ben_oipl_f  oipl, ben_pl_f pl
    where  oipl.oipl_id = p_oipl_id
    and    pl.pl_id = oipl.pl_id
    and    p_effective_date
           between pl.effective_start_date
           and     pl.effective_end_date
    and    p_effective_date
           between oipl.effective_start_date
           and     oipl.effective_end_date;

  cursor c_pl(p_pl_id number) is
    select pl.pl_id, pl.pl_typ_id
    from   ben_pl_f pl
    where  pl.pl_id = p_pl_id
    and    p_effective_date
           between pl.effective_start_date
           and     pl.effective_end_date;

  cursor c_plip (p_pl_id number)is
    select plip.pgm_id
    from   ben_plip_f plip
    where  plip.pgm_id = p_pgm_id
    and    plip.pl_id = p_pl_id
    and    p_effective_date
           between plip.effective_start_date
           and     plip.effective_end_date;

begin
         p_out_pl_typ_id := null ;
         p_out_pl_id     := null ;
         p_out_opt_id    := null ;
         p_out_pgm_id    := null ;

         if p_oipl_id is not null then
           open c_opt(p_oipl_id);
           fetch c_opt into p_out_opt_id, p_out_pl_id, p_out_pl_typ_id;
           close c_opt;
         else   -- pl id must be not null
           open  c_pl(p_pl_id);
           fetch c_pl into p_out_pl_id, p_out_pl_typ_id;
           close c_pl;
         end if;

         if p_pgm_id is not null then
            open c_plip(p_pl_id => p_out_pl_id);
            fetch c_plip into p_out_pgm_id;
            close c_plip;
         end if;

end get_comp_object_info;
-- ----------------------------------------------------------------------------
-- |----------------------< determine_vrbl_prfls >----------------------------|
-- ----------------------------------------------------------------------------
-- Procedure used internally to compute variable actual premiums.
procedure   determine_vrbl_prfls
                    (p_actl_prem_id        in number
                    ,p_business_group_id   in number
                    ,p_effective_date      in date
                    ,p_first_day_of_month  in date
                    ,p_last_day_of_month   in date
                    ,p_pl_id               in number
                    ,p_oipl_id             in number
                    ,p_pl_typ_id           in number
                    ,p_pl2_id              in number
                    ,p_opt_id              in number
                    ,p_wsh_rl_dy_mo_num    in number
                    ,p_rndg_cd             in varchar2 default null
                    ,p_rndg_rl             in number   default null
                    ,p_num_of_prtts        in number
                    ,p_total_cvg           in number
                    ,p_actl_prem_val       in number
                    ,p_bnft_rt_typ_cd      in varchar2
                    ,p_mlt_cd              in varchar2
                    ,p_vrbl_rt_add_on_calc_rl in number
                    ,p_val                out nocopy number
                    ,p_matched_vrbl_prfl  out nocopy varchar2) is
  --
  l_package               varchar2(80) := g_package||'.determine_vrbl_prfls';
  l_error_text            varchar2(200) := null;
  --
  -- participants that have this coverage this month that should be
  -- paying the premium.
  -- If this cursor changes, check c_results and c_each_result
  -- Assuming person can't be in same plan in two programs.
  -- if they are, they will be counted twice due to this cursor.
  cursor c_people is
    select distinct pen.person_id , pen.pgm_id, nvl(pen.bnft_amt,0) bnft_amt
    from   ben_prtt_enrt_rslt_f pen,
           per_all_people_f per  -- Bug 1750817 :  Filter out enrollments of deleted person.
    where  per.person_id = pen.person_id
    and    per.business_group_id = pen.business_group_id
    and    p_effective_date between per.effective_start_date
                                and per.effective_end_date
    and    pen.prtt_enrt_rslt_stat_cd is null
    and    pen.sspndd_flag = 'N'
    and    pen.comp_lvl_cd not in ('PLANFC', 'PLANIMP')  -- not a dummy plan
           -- cvg is active entire month
    and    ((pen.enrt_cvg_strt_dt <= p_last_day_of_month
           and    pen.enrt_cvg_thru_dt >= p_first_day_of_month)
           or
           -- is no washrule and cvg was for at least part of the month
           (pen.enrt_cvg_strt_dt <= p_last_day_of_month
           and    pen.enrt_cvg_thru_dt >= p_first_day_of_month
           and p_wsh_rl_dy_mo_num is null)
           or
           -- if washrule there, and cvg strts this month it starts before wash day.
           (p_wsh_rl_dy_mo_num is not null
           and pen.enrt_cvg_strt_dt between
              p_first_day_of_month and p_last_day_of_month
           and to_char(pen.enrt_cvg_strt_dt,'dd') < p_wsh_rl_dy_mo_num )
           or
           -- if washrule there, and cvg end this month it ends after wash day.
           (p_wsh_rl_dy_mo_num is not null
           and pen.enrt_cvg_thru_dt between
              p_first_day_of_month and p_last_day_of_month
           and to_char(pen.enrt_cvg_thru_dt,'dd') > p_wsh_rl_dy_mo_num ))
    and    ((pen.pl_id = p_pl_id and pen.oipl_id is null) or p_pl_id is null)
    and    (pen.oipl_id = p_oipl_id or p_oipl_id is null)
    and    pen.business_group_id = p_business_group_id
    /*   Bug#2903964 - it is better to get the results based on effective end date rather
         filtering on effective_date
    and    p_effective_date between
           pen.effective_start_date and pen.effective_end_date */
    and    pen.effective_end_date = hr_api.g_eot;
 l_people  c_people%rowtype;

  cursor c_vrbl_val (p_vrbl_rt_prfl_id number) is
     select nvl(vpf.val,0) val, vpf.upr_lmt_val, vpf.upr_lmt_calc_rl
           ,vpf.lwr_lmt_val, vpf.lwr_lmt_calc_rl, vpf.rndg_cd,
            vpf.rndg_rl, vpf.bnft_rt_typ_cd, vpf.mlt_cd
     from   ben_vrbl_rt_prfl_f vpf
     where  vpf.vrbl_rt_prfl_id = p_vrbl_rt_prfl_id
     and    vpf.business_group_id = p_business_group_id
     and    p_effective_date between
            vpf.effective_start_date and vpf.effective_end_date;
  l_vrbl_val  c_vrbl_val%rowtype;

  -- make sure flags default to 'Y'  ??
  cursor c_alwys_cnt_no  is
     select 'Y'
     from   ben_vrbl_rt_prfl_f vpf, ben_actl_prem_vrbl_rt_f apv
     where  apv.actl_prem_id = p_actl_prem_id
     and    apv.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
     and    ((vpf.alwys_cnt_all_prtts_flag = 'N' and exists
            (select 'x' from ben_ttl_prtt_rt_f ttp
             where ttp.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id))
            or (vpf.alwys_sum_all_cvg_flag = 'N'and exists
            (select 'x' from ben_ttl_cvg_vol_rt_f tcv
             where tcv.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id)))
     and    vpf.business_group_id = p_business_group_id
     and    p_effective_date between
            vpf.effective_start_date and vpf.effective_end_date;
  l_alwys_cnt_no varchar2(1) := 'N';


l_vrbl_rt_prfl_id      number;
l_num_of_prfls_matched number := 0;

l_persons              g_person_table;
/*type g_person_rec is record
 (person_id                  number
 ,pgm_id                     number
 ,bnft_amt                   number); */

l_insert_record        varchar2(1);
l_val                  number;
l_persons_matched      number := 0;
i                      number := 0;
l_use_globals            boolean := false;
l_outputs              ff_exec.outputs_t;


begin
  hr_utility.set_location ('Entering '||l_package,10);
  hr_utility.set_location ('actl_prem_id:'||
                 to_char(p_actl_prem_id),10);

  -- p_pl_id is the actl_prem.pl_id, which can be null
  -- p_pl2_id is the pl_id of the actl_prem.oipl_id or actl_prem.pl_id.  will
  -- never be null.

  p_matched_vrbl_prfl  := 'N';  -- used to see if ANYONE matched a profile.
  p_val := 0;

  ben_evaluate_rate_profiles.init_globals;

  open c_alwys_cnt_no;
  fetch c_alwys_cnt_no into l_alwys_cnt_no;
  close c_alwys_cnt_no;
  -- ?? this assumes that all vrbl prfls for an actl prem have this flag
  -- set the same....

  if l_alwys_cnt_no = 'Y' then
     -- there are variable rate profiles with one of the ALWAYS flags set to NO.
    l_use_globals := true;  -- for use in SECOND call to main.
    for l_people in c_people loop
        -- these calls are required so we can call ben_evaluate_rate_profiles.main
        ben_env_object.setenv(p_person_id => l_people.person_id);
        --ben_env_object.setenv(p_business_group_id => p_business_group_id);
        if l_people.pgm_id is not null then
           ben_env_object.setenv(p_pgm_id => l_people.pgm_id);
        end if;
        if p_pl2_id is not null then
           ben_env_object.setenv(p_pl_id => p_pl2_id);
        end if;
        if p_oipl_id is not null then
           ben_env_object.setenv(p_oipl_id => p_oipl_id);
        end if;
        -- Call main with the all_prfls = true.  This tells main to find all the profiles
        -- that a person matches, not just the first one.  It loads these into a global
        -- table structure.  It skips the ttl_prtt and ttl_cvg evaulation.
        ben_evaluate_rate_profiles.main
         (p_person_id               => l_people.person_id,
          p_elig_per_elctbl_chc_id  => null,
          p_acty_base_rt_id         => null,
          p_actl_prem_id            => p_actl_prem_id,
          p_cvg_amt_calc_mthd_id    => null,
          p_effective_date          => p_effective_date,
          p_lf_evt_ocrd_dt          => p_effective_date,
          p_calc_only_rt_val_flag   => true,
          p_pgm_id                  => l_people.pgm_id,
          p_pl_id                   => p_pl2_id,  -- pl id of apr's oipl or pl
          p_pl_typ_id               => p_pl_typ_id,
          p_oipl_id                 => p_oipl_id,
          p_per_in_ler_id           => null,
          p_ler_id                  => null,
          p_business_group_id       => p_business_group_id,
          p_ttl_prtt                => null,
          p_ttl_cvg                 => null,
          p_all_prfls               => true,
          p_use_globals             => false,
          p_use_prfls               => false,
          p_bnft_amt                => l_people.bnft_amt,
          p_vrbl_rt_prfl_id         => l_vrbl_rt_prfl_id);  -- output

        if l_vrbl_rt_prfl_id is not null then
           -- the person matched at least one profile, save them for the
           -- second looping.
           l_persons_matched := l_persons_matched + 1;
           l_persons(l_persons_matched).person_id := l_people.person_id;
           l_persons(l_persons_matched).pgm_id    := l_people.pgm_id;
           l_persons(l_persons_matched).bnft_amt  := l_people.bnft_amt;
        end if;
      end loop; -- c_people

  end if;

  -- All people were evaluated thru all profiles.  We know how many matched no
  -- profiles so far and how many matched each profile.  Now we want to loop through
  -- those folks that matched a profile and find which profile they match first
  -- WITH evaluation of ttl_cvg and ttl_prtt.

  -- This loop is either looping through people that matched a profile in
  -- the loop above, or if we didn't execute that loop, thru all people
  -- in c_people cursor.
  if l_persons_matched > 0 or l_alwys_cnt_no = 'N' then
     if l_alwys_cnt_no = 'N' then
        open c_people;
     end if;
     loop
       if l_alwys_cnt_no = 'N' then
          fetch c_people into l_people;
          if c_people%NOTFOUND or c_people%NOTFOUND is null then
             close c_people;
             -- ?? check what's done on exit.
             exit;
          end if;
       else
          i := i + 1;
          if i > l_persons_matched then exit; end if;
          l_people.person_id := l_persons(i).person_id;
          l_people.pgm_id    := l_persons(i).pgm_id;
          l_people.bnft_amt  := l_persons(i).bnft_amt;
       end if;
       hr_utility.set_location ('looping for person '||
               to_char(l_people.person_id),12);

       -- these calls are required so we can call ben_evaluate_rate_profiles.main
       ben_env_object.setenv(p_person_id => l_people.person_id);
       --ben_env_object.setenv(p_business_group_id => p_business_group_id);
       if l_people.pgm_id is not null then
          ben_env_object.setenv(p_pgm_id => l_people.pgm_id);
       end if;
       if p_pl2_id is not null then
          ben_env_object.setenv(p_pl_id => p_pl2_id);
       end if;
       if p_oipl_id is not null then
          ben_env_object.setenv(p_oipl_id => p_oipl_id);
       end if;

       -- ?? should we pass pl_id of actl_prem (which could be null)
       -- or of actl_prem's pl or oipl?   currently passing pl/oipl's.
       ben_evaluate_rate_profiles.main
         (p_person_id               => l_people.person_id,
          p_elig_per_elctbl_chc_id  => null,
          p_acty_base_rt_id         => null,
          p_actl_prem_id            => p_actl_prem_id,
          p_cvg_amt_calc_mthd_id    => null,
          p_effective_date          => p_effective_date,
          p_lf_evt_ocrd_dt          => p_effective_date,
          p_calc_only_rt_val_flag   => true,
          p_pgm_id                  => l_people.pgm_id,
          p_pl_id                   => p_pl2_id,  -- pl id of apr's oipl or pl
          p_pl_typ_id               => p_pl_typ_id,
          p_oipl_id                 => p_oipl_id,
          p_per_in_ler_id           => null,
          p_ler_id                  => null,
          p_business_group_id       => p_business_group_id,
          p_ttl_prtt                => p_num_of_prtts,
          p_ttl_cvg                 => p_total_cvg,
          p_all_prfls               => false,
          p_use_globals             => l_use_globals,
          p_use_prfls               => true, -- bug 1211317 added parm.
          p_bnft_amt                => l_people.bnft_amt,
          p_vrbl_rt_prfl_id         => l_vrbl_rt_prfl_id);  -- output

      if l_vrbl_rt_prfl_id is not null then
         p_matched_vrbl_prfl  := 'Y';
     end if;
     end loop;  -- c_people or matched people
  end if;


  ----------- compute total premium value  -------------------------------
  -- first use the actual premium value for those persons that didn't match
  -- any variable profiles:
  if ben_evaluate_rate_profiles.g_no_match_cnt > 0 then
     hr_utility.set_location ('g_no_match_cnt:'||
        to_char(ben_evaluate_rate_profiles.g_no_match_cnt),18);
     if p_mlt_cd = 'NSVU' then
        if p_vrbl_rt_add_on_calc_rl is null then
           -- there is no standard value and no profiles matched, error.
           fnd_message.set_name('BEN', 'BEN_92290_NSVU_NO_PROFILES');
           fnd_message.raise_error;
        else
            -- this rule returns an amount.
            l_outputs := benutils.formula
              (p_formula_id        => p_vrbl_rt_add_on_calc_rl,
               p_effective_date    => p_effective_date,
               p_business_group_id  => p_business_group_id,
               p_assignment_id      => null,  -- we are not processing a single
               p_organization_id    => null,  -- person, but a group.
               p_pgm_id             => null,  -- and we don't know the pgm.
               p_pl_id            => p_pl2_id,
               p_pl_typ_id        => p_pl_typ_id,
               p_opt_id             => p_opt_id,
               p_ler_id             => null,
               p_jurisdiction_code  => null);
            p_val := l_outputs(l_outputs.first).value;
        end if;
     elsif p_mlt_cd = 'TTLPRTT' then
        hr_utility.set_location ('ttlprtt p_actl_prem_id:'||to_char(p_actl_prem_id)||
                                ' p_bnft_rt_typ_cd:'||p_bnft_rt_typ_cd, 22);
        benutils.rt_typ_calc
           (p_rt_typ_cd       => p_bnft_rt_typ_cd
           ,p_val             => ben_evaluate_rate_profiles.g_no_match_cnt
           ,p_val_2           => p_actl_prem_val
           ,p_calculated_val  => p_val);  -- output p_val
     else -- p_mlt_cd = 'TTLCVG'
        hr_utility.set_location ('ttlcvg p_actl_prem_id:'||to_char(p_actl_prem_id)||
                       ' p_bnft_rt_typ_cd:'||p_bnft_rt_typ_cd, 24);
        benutils.rt_typ_calc
           (p_rt_typ_cd       => p_bnft_rt_typ_cd
           ,p_val             => ben_evaluate_rate_profiles.g_no_match_cvg
           ,p_val_2           => p_actl_prem_val
           ,p_calculated_val  => p_val);  -- output p_val
     end if;
  end if;
  -- round against actl_prem.
  p_val := benutils.do_rounding
        (p_rounding_cd    => p_rndg_cd
        ,p_rounding_rl    => p_rndg_rl
        ,p_value          => p_val
        ,p_effective_date => p_effective_date);
  -- then loop thru profiles matched and add up rates based on number of people
  -- that matched that profile or amount of coverage of those people.
  if ben_evaluate_rate_profiles.g_num_of_prfls_used > 0 then
    for i in 1..ben_evaluate_rate_profiles.g_num_of_prfls_used loop
      hr_utility.set_location('vrbl_rt_prfl_id'||
         to_char(ben_evaluate_rate_profiles.g_use_prfls(i).vrbl_rt_prfl_id),26);
      open c_vrbl_val(p_vrbl_rt_prfl_id =>
           ben_evaluate_rate_profiles.g_use_prfls(i).vrbl_rt_prfl_id);
      fetch c_vrbl_val into l_vrbl_val;
      if c_vrbl_val%found then
         if l_vrbl_val.mlt_cd = 'TTLPRTT' then
            benutils.rt_typ_calc
              (p_rt_typ_cd       => l_vrbl_val.bnft_rt_typ_cd
              ,p_val             =>
                ben_evaluate_rate_profiles.g_use_prfls(i).match_cnt
              ,p_val_2           => l_vrbl_val.val
              ,p_calculated_val  => l_val);  -- output val
         else  -- l_vrbl_val.mlt_cd = 'TTLCVG'
            benutils.rt_typ_calc
              (p_rt_typ_cd       => l_vrbl_val.bnft_rt_typ_cd
              ,p_val             =>
                 ben_evaluate_rate_profiles.g_use_prfls(i).match_cvg
              ,p_val_2           => l_vrbl_val.val
              ,p_calculated_val  => l_val);  -- output val
         end if;
         -- round and check limits against variable rate profiles.
         l_val := benutils.do_rounding
             (p_rounding_cd    => l_vrbl_val.rndg_cd
             ,p_rounding_rl    => l_vrbl_val.rndg_rl
             ,p_value          => l_val
             ,p_effective_date => p_effective_date);
         hr_utility.set_location('Variable Limits Checking',28);
         benutils.limit_checks
              (p_upr_lmt_val        => l_vrbl_val.upr_lmt_val,
               p_lwr_lmt_val        => l_vrbl_val.lwr_lmt_val,
               p_upr_lmt_calc_rl    => l_vrbl_val.upr_lmt_calc_rl,
               p_lwr_lmt_calc_rl    => l_vrbl_val.lwr_lmt_calc_rl,
               p_effective_date     => p_effective_date,
               p_business_group_id  => p_business_group_id,
               p_assignment_id      => null,  -- we are not processing a single
               p_organization_id    => null,  -- person, but a group.
               p_pgm_id             => null,  -- and we don't know the pgm.
               p_pl_id            => p_pl2_id,
               p_pl_typ_id        => p_pl_typ_id,
               p_opt_id             => p_opt_id,
               p_ler_id             => null,
               p_state              => null,
               p_val                => l_val);
         -- Add rounded value to running total
         p_val := p_val + l_val;
      else
        -- ?? error
        null;
      end if;
      close c_vrbl_val;
    end loop;
  end if;
  hr_utility.set_location ('Leaving '||l_package,99);
exception
  when others then
    l_error_text := sqlerrm;
    hr_utility.set_location ('Fail in '||l_package||' error:',999);
    hr_utility.set_location (l_error_text,999);
    fnd_message.raise_error;
end determine_vrbl_prfls;
-- ----------------------------------------------------------------------------
-- |------------------------------< main >------------------------------------|
-- ----------------------------------------------------------------------------
-- This is the procedure to call to determine all the 'PROC' type premiums for
-- the month.
procedure main
  (p_validate                 in varchar2 default 'N',
   p_actl_prem_id             in number,
   p_business_group_id        in number,
   p_mo_num                   in number,
   p_yr_num                   in number,
   p_first_day_of_month       in date,
   p_effective_date           in date)  is
--   p_pl_typ_id                in number,
--   p_pl_id                    in number,
--   p_opt_id                   in number
  --
  l_package               varchar2(80) := g_package||'.main';
  l_error_text            varchar2(200) := null;

  cursor c_prems  is
    select apr.wsh_rl_dy_mo_num, apr.actl_prem_id, apr.prem_asnmt_lvl_cd,
           apr.val, apr.uom, apr.pl_id, apr.oipl_id, apr.bnft_rt_typ_cd,
           apr.rndg_cd, apr.rndg_rl, apr.upr_lmt_calc_rl, apr.upr_lmt_val,
           apr.lwr_lmt_calc_rl, apr.lwr_lmt_val, apr.prsptv_r_rtsptv_cd,
           apr.mlt_cd, apr.cost_allocation_keyflex_id, apr.vrbl_rt_add_on_calc_rl
    from   ben_actl_prem_f apr
    where  apr.actl_prem_id = p_actl_prem_id
    and    p_effective_date between
           apr.effective_start_date and apr.effective_end_date;
  l_prems c_prems%rowtype;

  --
  -- Number of participants that have this coverage this month that should be
  -- paying the premium:
  -- If this cursor changes, check c_people and c_each_result
  cursor c_results (p_first_day_of_month date,
                    p_last_day_of_month date, p_wsh_rl_dy_mo_num number,
                    p_pl_id number, p_oipl_id number) is
    select count('s') num_of_prtts, sum(nvl(pen.bnft_amt,0)) total_cvg
    from   ben_prtt_enrt_rslt_f pen,
           per_all_people_f per  -- Bug 1750817 :  Filter out enrollments of deleted person.
    where  per.person_id = pen.person_id
    and    per.business_group_id = pen.business_group_id
    and    p_effective_date between per.effective_start_date
                                and per.effective_end_date
    and    pen.prtt_enrt_rslt_stat_cd is null
    and    pen.sspndd_flag = 'N'
    and    pen.comp_lvl_cd not in ('PLANFC', 'PLANIMP')  -- not a dummy plan
           -- cvg is active entire month
    and    ((pen.enrt_cvg_strt_dt <= p_last_day_of_month
           and    pen.enrt_cvg_thru_dt >= p_first_day_of_month)
           or
           -- is no washrule and cvg was for at least part of the month
           (pen.enrt_cvg_strt_dt <= p_last_day_of_month
           and    pen.enrt_cvg_thru_dt >= p_first_day_of_month
           and p_wsh_rl_dy_mo_num is null)
           or
           -- if washrule there, and cvg strts this month it starts before wash day.
           (p_wsh_rl_dy_mo_num is not null
           and pen.enrt_cvg_strt_dt between
              p_first_day_of_month and p_last_day_of_month
           and to_char(pen.enrt_cvg_strt_dt,'dd') < p_wsh_rl_dy_mo_num )
           or
           -- if washrule there, and cvg end this month it ends after wash day.
           (p_wsh_rl_dy_mo_num is not null
           and pen.enrt_cvg_thru_dt between
              p_first_day_of_month and p_last_day_of_month
           and to_char(pen.enrt_cvg_thru_dt,'dd') > p_wsh_rl_dy_mo_num ))
    and    ((pen.pl_id = p_pl_id and pen.oipl_id is null) or p_pl_id is null)
    and    (pen.oipl_id = p_oipl_id or p_oipl_id is null)
    and    pen.business_group_id = p_business_group_id
     /*   Bug#2903964 - it is better to get the results based on effective end date rather
         filtering on effective_date
          and    p_effective_date between
           pen.effective_start_date and pen.effective_end_date */
    and    pen.effective_end_date = hr_api.g_eot;
  l_results  c_results%rowtype;
  --
  -- participants that have this coverage this month that should be
  -- paying the premium.  Used when we need to allocate prem to each participant.
  -- If this cursor changes, check c_results and c_people
  cursor c_each_result (p_first_day_of_month date,
                        p_last_day_of_month date, p_wsh_rl_dy_mo_num number,
                        p_pl_id number, p_oipl_id number) is
    select pen.prtt_enrt_rslt_id, pen.person_id, pen.pl_id, pen.oipl_id,
           pen.pgm_id, pen.pl_typ_id,
           /*  Start of Code Change for WWBUG: 1646442: added following table           */
           pen.enrt_cvg_strt_dt
           /*  End of Code Change for WWBUG: 1646442                                    */
    from   ben_prtt_enrt_rslt_f pen,
           per_all_people_f per  -- Bug 1750817 :  Filter out enrollments of deleted person.
    where  per.person_id = pen.person_id
    and    per.business_group_id = pen.business_group_id
    and    p_effective_date between per.effective_start_date
                                and per.effective_end_date
    and    pen.prtt_enrt_rslt_stat_cd is null
    and    pen.sspndd_flag = 'N'
    and    pen.comp_lvl_cd not in ('PLANFC', 'PLANIMP')  -- not a dummy plan
           -- cvg is active entire month
    and    ((pen.enrt_cvg_strt_dt <= p_last_day_of_month
           and    pen.enrt_cvg_thru_dt >= p_first_day_of_month)
           or
           -- is no washrule and cvg was for at least part of the month
           (pen.enrt_cvg_strt_dt <= p_last_day_of_month
           and    pen.enrt_cvg_thru_dt >= p_first_day_of_month
           and p_wsh_rl_dy_mo_num is null)
           or
           -- if washrule there, and cvg strts this month it starts before wash day.
           (p_wsh_rl_dy_mo_num is not null
           and pen.enrt_cvg_strt_dt between
              p_first_day_of_month and p_last_day_of_month
           and to_char(pen.enrt_cvg_strt_dt,'dd') < p_wsh_rl_dy_mo_num )
           or
           -- if washrule there, and cvg end this month it ends after wash day.
           (p_wsh_rl_dy_mo_num is not null
           and pen.enrt_cvg_thru_dt between
              p_first_day_of_month and p_last_day_of_month
           and to_char(pen.enrt_cvg_thru_dt,'dd') > p_wsh_rl_dy_mo_num ))
    and    ((pen.pl_id = p_pl_id and pen.oipl_id is null) or p_pl_id is null)
    and    (pen.oipl_id = p_oipl_id or p_oipl_id is null)
    and    pen.business_group_id = p_business_group_id
    /*   Bug#2903964 - it is better to get the results based on effective end date rather
         filtering on effective_date
         and    p_effective_date between
           pen.effective_start_date and pen.effective_end_date*/
    and   pen.effective_end_date = hr_api.g_eot;
  l_each_result  c_each_result%rowtype;

  -- participant prem row:
  cursor c_ppe (p_prtt_enrt_rslt_id number
               ,p_actl_prem_id      number ) is
    select ppe.std_prem_uom, ppe.prtt_prem_id
    from   ben_prtt_prem_f ppe,
           ben_per_in_ler pil
    where  ppe.actl_prem_id = p_actl_prem_id
    and    ppe.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
    and    ppe.business_group_id = p_business_group_id
    and    p_effective_date between
           ppe.effective_start_date and ppe.effective_end_date
    and    pil.per_in_ler_id(+)=ppe.per_in_ler_id
    and    pil.business_group_id(+)=ppe.business_group_id
    and    (pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT') -- found row condition
     	    or pil.per_in_ler_stat_cd is null                  -- outer join condition
           );
    l_ppe c_ppe%rowtype;

  cursor c_pbm (p_actl_prem_id number, p_mo_num number, p_yr_num number) is
    select pbm.pl_r_oipl_prem_by_mo_id, pbm.object_version_number
    from   ben_pl_r_oipl_prem_by_mo_f pbm
    where  pbm.mo_num = p_mo_num
    and    pbm.yr_num = p_yr_num
    and    pbm.actl_prem_id = p_actl_prem_id ;
    -- and    p_effective_date between pbm.effective_start_date and pbm.effective_end_date; -- bug 2784213
  l_pbm c_pbm%rowtype;

  cursor c_prm (p_prtt_prem_id number, p_mo_num number, p_yr_num number) is
    select prm.prtt_prem_by_mo_id,prm.val,prm.cr_val,mnl_adj_flag, prm.object_version_number
    from ben_prtt_prem_by_mo_f prm
    where  prm.mo_num = p_mo_num
    and    prm.yr_num = p_yr_num
    and    prm.prtt_prem_id = p_prtt_prem_id
    order by prm.effective_start_date ;
    -- and    p_effective_date between prm.effective_start_date and prm.effective_end_date;-- bug 2784213
  l_prm c_prm%rowtype;


  cursor c_prm_ovn (p_prtt_prem_id number ,
                    p_mo_num number,
                    p_yr_num number,
                    p_effective_dt date) is
    select prm.prtt_prem_by_mo_id,prm.val,prm.cr_val,mnl_adj_flag, prm.object_version_number
    from ben_prtt_prem_by_mo_f prm
    where  prm.mo_num = p_mo_num
    and    prm.yr_num = p_yr_num
    and    prm.prtt_prem_id = p_prtt_prem_id
    and    p_effective_dt between prm.effective_start_date and prm.effective_end_date;





  l_pl_typ_id number ;
  l_pl_id     number ;
  l_opt_id    number ;
  l_pgm_id    number ;
  l_val_net   number ;

  l_effective_start_date date;
  l_effective_end_date   date;
  l_cak                  number;
  l_ovn                  number;
  l_val                  number;
  l_prtt_val             number;
  l_reg_prtt_val         number;
  l_balance_val          number;
  l_matched_vrbl_prfl    varchar2(1);
  l_rule_ret             varchar2(1);
  l_last_day_of_month    date;
  l_first_day_of_month   date;
  l_mo_num               number;
  l_yr_num               number;

  l_outputs              ff_exec.outputs_t;
  l_effective_date_mo	 date;
  l_last_effective_dt	 date;
begin
  hr_utility.set_location ('Entering '||l_package,10);
  Savepoint process_pl_premium_savepoint;

  -- this call is required so we can call ben_evaluate_rate_profiles.main
  ben_env_object.init(p_business_group_id => p_business_group_id,
               p_effective_date    => p_effective_date,
               p_thread_id         => null,
               p_chunk_size        => null,
               p_threads           => null,
               p_max_errors        => null,
               p_benefit_action_id => null) ;

  -- p_effective_date is always the last day of the month this is being run

     hr_utility.set_location ('process actl_prem_id:'||to_char(p_actl_prem_id),12);

     open c_prems;
     fetch c_prems into l_prems;
     close c_prems;

     if l_prems.prsptv_r_rtsptv_cd = 'RETRO' then
        -- if the premium is retrospective, process with this month
        l_last_day_of_month := p_effective_date;
        l_first_day_of_month := p_first_day_of_month;
        l_mo_num := p_mo_num;
        l_yr_num := p_yr_num;
     else
        -- if premium is prospective, process with next month's date.
        l_last_day_of_month := add_months(p_effective_date,1);
        l_first_day_of_month := add_months(p_first_day_of_month,1);
        l_mo_num := to_char(l_last_day_of_month,'mm');
        l_yr_num := to_char(l_last_day_of_month,'YYYY');
     end if;
     l_last_effective_dt := last_day(l_last_day_of_month) ;

       -- Find total number of prtt for this premium.
       hr_utility.set_location ('pl_id:'||to_char(l_prems.pl_id)||
       ' oipl_id:'||to_char(l_prems.oipl_id)||' washrule:'||
       to_char(l_prems.wsh_rl_dy_mo_num)||' last:'||to_char(l_last_day_of_month)||
       ' first:'||to_char(l_first_day_of_month),1);

       open c_results
                    (p_first_day_of_month => l_first_day_of_month
                    ,p_last_day_of_month => l_last_day_of_month
                    ,p_wsh_rl_dy_mo_num  => l_prems.wsh_rl_dy_mo_num
                    ,p_pl_id             => l_prems.pl_id
                    ,p_oipl_id           => l_prems.oipl_id) ;
       fetch c_results into l_results;
       close c_results;
       if l_results.num_of_prtts = 0 then
         -- c_results%notfound is irrelevant when cursor uses a 'sum'
         -- if no people, skip all the vrbl prfl stuff and write a zero value premium
         l_val := 0;
       else
         hr_utility.set_location ('total results:'||to_char(l_results.num_of_prtts)||
               ' tot cvg:'||to_char(l_results.total_cvg),14);

         ben_prem_pl_oipl_monthly.get_comp_object_info
             (p_oipl_id        => l_prems.oipl_id
             ,p_pl_id          => l_prems.pl_id
             ,p_pgm_id         => null
             ,p_effective_date => p_effective_date
             ,p_out_pgm_id     => l_pgm_id
             ,p_out_pl_typ_id  => l_pl_typ_id
             ,p_out_pl_id      => l_pl_id
             ,p_out_opt_id     => l_opt_id);

         -- Determine if there are any variable profiles matching and if so,
         -- compute the premium values.
         l_matched_vrbl_prfl := 'N';
         determine_vrbl_prfls (p_actl_prem_id    => l_prems.actl_prem_id
                          ,p_business_group_id => p_business_group_id
                          ,p_effective_date    => p_effective_date
                          ,p_first_day_of_month => l_first_day_of_month
                          ,p_last_day_of_month => l_last_day_of_month
                          ,p_pl_id             => l_prems.pl_id
                          ,p_oipl_id           => l_prems.oipl_id
                          ,p_pl_typ_id         => l_pl_typ_id
                          ,p_pl2_id            => l_pl_id
                          ,p_opt_id            => l_opt_id
                          ,p_wsh_rl_dy_mo_num  => l_prems.wsh_rl_dy_mo_num
                          ,p_rndg_cd           => l_prems.rndg_cd
                          ,p_rndg_rl           => l_prems.rndg_rl
                          ,p_num_of_prtts      => l_results.num_of_prtts
                          ,p_total_cvg         => l_results.total_cvg
                          ,p_actl_prem_val     => l_prems.val
                          ,p_bnft_rt_typ_cd    => l_prems.bnft_rt_typ_cd
                          ,p_mlt_cd            => l_prems.mlt_cd
                          ,p_vrbl_rt_add_on_calc_rl => l_prems.vrbl_rt_add_on_calc_rl
                          ,p_val               => l_val
                          ,p_matched_vrbl_prfl => l_matched_vrbl_prfl);
         if l_matched_vrbl_prfl = 'N' then
           hr_utility.set_location ('l_matched_vrbl_prfl = N',16);
           -- compute total premium based on number of participants or
           -- total coverage amt of prtts.
              if l_prems.mlt_cd = 'NSVU' then
                 if l_prems.vrbl_rt_add_on_calc_rl is null then
                    -- there is no standard value and no profiles matched, error.
                    fnd_message.set_name('BEN', 'BEN_92290_NSVU_NO_PROFILES');
                    fnd_message.raise_error;
                 else
                    -- this rule returns an amount.
                    l_outputs := benutils.formula
                      (p_formula_id         => l_prems.vrbl_rt_add_on_calc_rl,
                       p_effective_date     => p_effective_date,
                       p_business_group_id  => p_business_group_id,
                       p_assignment_id      => null,  -- we are not processing a single
                       p_organization_id    => null,  -- person, but a group.
                       p_pgm_id             => null,  -- and we don't know the pgm.
                       p_pl_id              => l_prems.pl_id,
                       p_pl_typ_id          => l_pl_typ_id,
                       p_opt_id             => l_opt_id,
                       p_ler_id             => null,
                       p_jurisdiction_code  => null);
                   l_val := l_outputs(l_outputs.first).value;
                 end if;
              elsif l_prems.mlt_cd = 'TTLPRTT' then
                 benutils.rt_typ_calc
                     (p_rt_typ_cd       => l_prems.bnft_rt_typ_cd
                     ,p_val             => l_prems.val
                     ,p_val_2           => l_results.num_of_prtts
                     ,p_calculated_val  => l_val);
              else -- l_prems.mlt_cd = 'TTLCVG'
                 benutils.rt_typ_calc
                     (p_rt_typ_cd       => l_prems.bnft_rt_typ_cd
                     ,p_val             => l_prems.val
                     ,p_val_2           => l_results.total_cvg
                     ,p_calculated_val  => l_val);
              end if;
              -- round against actl_prem
              l_val := benutils.do_rounding
                (p_rounding_cd    => l_prems.rndg_cd
                ,p_rounding_rl    => l_prems.rndg_rl
                ,p_value          => l_val
                ,p_effective_date => p_effective_date);
         end if;

         hr_utility.set_location('Premium Limits Checking',20);
         benutils.limit_checks
              (p_upr_lmt_val        => l_prems.upr_lmt_val,
               p_lwr_lmt_val        => l_prems.lwr_lmt_val,
               p_upr_lmt_calc_rl    => l_prems.upr_lmt_calc_rl,
               p_lwr_lmt_calc_rl    => l_prems.lwr_lmt_calc_rl,
               p_effective_date     => p_effective_date,
               p_business_group_id  => p_business_group_id,
               p_assignment_id      => null,  -- we are not processing a single
               p_organization_id    => null,  -- person, but a group.
               p_pgm_id             => null,  -- and we don't know the pgm.
               p_pl_id              => l_pl_id,
               p_pl_typ_id          => l_pl_typ_id,
               p_opt_id             => l_opt_id,
               p_ler_id             => null,
               p_state              => null,
               p_val                => l_val);


           -- l_val should be the total premium to be written to pl_r_oipl_prem_by_mo


            if l_prems.prem_asnmt_lvl_cd = 'PRTTNPLOIPL' then
              -- allocate premium to participants
              -- l_prtt_val should be the total prem divided by number of prtts,
              -- and written to prtt_prem_by_mo.
              -- compute Per participant value
              l_prtt_val       := l_val / l_results.num_of_prtts;

              -- Task 416, July 99 : balance individual prem to total prem.
              -- One person's premium may be more than the others to compenstate.
              -- round individual prem against actl_prem rounding code
              l_prtt_val := benutils.do_rounding
                (p_rounding_cd    => l_prems.rndg_cd
                ,p_rounding_rl    => l_prems.rndg_rl
                ,p_value          => l_prtt_val
                ,p_effective_date => p_effective_date);
              l_balance_val := l_val - (l_prtt_val * l_results.num_of_prtts);
              l_reg_prtt_val := l_prtt_val;
              l_prtt_val := l_prtt_val + l_balance_val;


              -- looping thru results matching actl_prem's pl and oipl
              for l_each_result in c_each_result
                    (p_first_day_of_month => l_first_day_of_month
                    ,p_last_day_of_month => l_last_day_of_month
                    ,p_wsh_rl_dy_mo_num  => l_prems.wsh_rl_dy_mo_num
                    ,p_pl_id             => l_prems.pl_id
                    ,p_oipl_id           => l_prems.oipl_id) loop
                -- for each result find a prtt prem row matching the actl_prem_id.
                -- If it doesn't exist, create one.
                hr_utility.set_location ('looping c_each_result',28);
                open c_ppe(p_prtt_enrt_rslt_id => l_each_result.prtt_enrt_rslt_id
                    ,p_actl_prem_id      => l_prems.actl_prem_id);
                fetch c_ppe into l_ppe;
                if c_ppe%notfound or c_ppe%notfound is null then
                   ben_prtt_prem_api.create_prtt_prem
                   (p_prtt_prem_id            => l_ppe.prtt_prem_id
                   ,p_effective_start_date    => l_effective_start_date
                   ,p_effective_end_date      => l_effective_end_date
                   ,p_std_prem_uom            => l_prems.uom
                   ,p_std_prem_val            => l_prtt_val
                   ,p_actl_prem_id            => l_prems.actl_prem_id
                   ,p_prtt_enrt_rslt_id       => l_each_result.prtt_enrt_rslt_id
                   ,p_business_group_id       => p_business_group_id
                   ,p_object_version_number   => l_ovn
                   ,p_request_id              => fnd_global.conc_request_id
                   ,p_program_application_id  => fnd_global.prog_appl_id
                   ,p_program_id              => fnd_global.conc_program_id
                   ,p_program_update_date     => sysdate
                   /* CODE PRIOR TO WWBUG: 1646442
                   ,p_effective_date          => p_effective_date);
                   */
                   /* Start of Changes for WWBUG: 1646442               */
                   ,p_effective_date          => l_each_result.enrt_cvg_strt_dt);
                   /*  End of Changes for WWBUG: 1646442                */
                 l_ppe.std_prem_uom := l_prems.uom;
                end if;
                close c_ppe;
                hr_utility.set_location ('write prtt premium by mo. val:'||
                to_char(l_prtt_val),31);
                open c_prm(p_prtt_prem_id => l_ppe.prtt_prem_id
                          ,p_mo_num       => l_mo_num
                          ,p_yr_num       => l_yr_num);
                fetch c_prm into l_prm;
                if c_prm%notfound or c_prm%notfound is null then
                   -- bug  2784213
	           l_effective_date_mo :=  last_day(to_date(l_yr_num||lpad(l_mo_num,2,0),'YYYYMM'));
          	   --
                   ben_prtt_prem_by_mo_api.create_prtt_prem_by_mo
                    (p_prtt_prem_by_mo_id      => l_prm.prtt_prem_by_mo_id
                    ,p_effective_start_date    => l_effective_start_date
                    ,p_effective_end_date      => l_effective_end_date
                    ,p_mnl_adj_flag            => 'N'
                    ,p_mo_num                  => l_mo_num
                    ,p_yr_num                  => l_yr_num
                    ,p_antcpd_prtt_cntr_uom    => null
                    ,p_antcpd_prtt_cntr_val    => null
                    ,p_val                     => l_prtt_val
                    ,p_cr_val                  => null
                    ,p_cr_mnl_adj_flag         => 'N'
                    ,p_alctd_val_flag          => 'Y'
                    ,p_uom                     => l_ppe.std_prem_uom  -- uom from prtt_prem if exists
                    ,p_prtt_prem_id            => l_ppe.prtt_prem_id
                    ,p_cost_allocation_keyflex_id => l_prems.cost_allocation_keyflex_id
                    ,p_business_group_id       => p_business_group_id
                    ,p_object_version_number   => l_prm.object_version_number
                    ,p_request_id              => fnd_global.conc_request_id
                    ,p_program_application_id  => fnd_global.prog_appl_id
                    ,p_program_id              => fnd_global.conc_program_id
                    ,p_program_update_date     => sysdate
                    ,p_effective_date          => l_effective_date_mo); --p_effective_date);
                else

                   -- get the net value
                   open c_prm_ovn (p_prtt_prem_id  => l_ppe.prtt_prem_id
                                   ,p_mo_num       => l_mo_num
                                   ,p_yr_num       => l_yr_num
                                   ,p_effective_dt => l_last_effective_dt );
                   fetch c_prm_ovn into l_prm ;
                   close c_prm_ovn ;
                   --
                   if l_prm.mnl_adj_flag = 'N' then
                      if l_prm.cr_val> 0 and  l_prtt_val  >  0 then

                         hr_utility.set_location ('update  the  premium:'|| l_prm.prtt_prem_by_mo_id, 10) ;

                         ben_prtt_prem_by_mo_api.update_prtt_prem_by_mo
                          (p_prtt_prem_by_mo_id      => l_prm.prtt_prem_by_mo_id
                          ,p_effective_start_date    => l_effective_start_date
                          ,p_effective_end_date      => l_effective_end_date
                          ,p_mnl_adj_flag            => 'N'
                          ,p_val                     => l_prtt_val
                          ,p_cr_val                  => null
                          ,p_alctd_val_flag          => 'Y'
                          ,p_uom                     => l_ppe.std_prem_uom  -- uom from prtt_prem if exists
                          ,p_cost_allocation_keyflex_id => l_prems.cost_allocation_keyflex_id
                          ,p_object_version_number   => l_prm.object_version_number
                          ,p_request_id              => fnd_global.conc_request_id
                          ,p_program_application_id  => fnd_global.prog_appl_id
                          ,p_program_id              => fnd_global.conc_program_id
                          ,p_program_update_date     => sysdate
                          ,p_effective_date          => l_last_effective_dt
                          ,p_datetrack_mode          => hr_api.g_correction);

                      else

                         ben_prtt_prem_by_mo_api.update_prtt_prem_by_mo
                         (p_prtt_prem_by_mo_id      => l_prm.prtt_prem_by_mo_id
                          ,p_effective_start_date    => l_effective_start_date
                          ,p_effective_end_date      => l_effective_end_date
                          ,p_mnl_adj_flag            => 'N'
                          ,p_val                     => l_prtt_val
                          ,p_alctd_val_flag          => 'Y'
                          ,p_uom                     => l_ppe.std_prem_uom  -- uom from prtt_prem if exists
                          ,p_cost_allocation_keyflex_id => l_prems.cost_allocation_keyflex_id
                          ,p_object_version_number   => l_prm.object_version_number
                          ,p_request_id              => fnd_global.conc_request_id
                          ,p_program_application_id  => fnd_global.prog_appl_id
                          ,p_program_id              => fnd_global.conc_program_id
                          ,p_program_update_date     => sysdate
                          ,p_effective_date          => l_last_effective_dt
                          ,p_datetrack_mode          => hr_api.g_correction);
                       end if ;
                   end if ;
                end if;
                close c_prm;
                -- write info to reporting table
                -- if we are processing this month for retrospective or next
                -- month for prospective, the report considers this 'current month'.
                g_rec.rep_typ_cd            := 'PRPPOIPL';
                g_rec.person_id             := l_each_result.person_id;
                g_rec.pgm_id                := l_each_result.pgm_id;
                g_rec.pl_id                 := l_each_result.pl_id;
                g_rec.oipl_id               := l_each_result.oipl_id;
                g_rec.pl_typ_id             := l_each_result.pl_typ_id;
                g_rec.actl_prem_id          := l_prems.actl_prem_id;
                g_rec.val                   := l_prtt_val;
                g_rec.mo_num                := l_mo_num;
                g_rec.yr_num                := l_yr_num;

                benutils.write(p_rec => g_rec);

                -- Task 416:  set individual prem back to regular value for the rest
                -- of the prtts.
                l_prtt_val := l_reg_prtt_val;

              end loop;  -- looping thru results matching actl_prem's pl and oipl
            end if;
       end if;  -- if found participants enrolled (c_results)

       hr_utility.set_location ('write costing 2 ',40);
       -- first insert into cost allocation keyflex ??
       if l_prems.prem_asnmt_lvl_cd = 'PLOIPL' then
             -- premiums were not allocated to prtts, cost at the pl/oipl level.
             -- Costing a PROC premium is simply pointing to the same cak id
             -- as the actl_prem record.  We use prem-cstg-by-sgmt only for
             -- ENRT premiums (benprprm.pkb).
             l_cak := l_prems.cost_allocation_keyflex_id;
       else l_cak := null;
       end if;

       hr_utility.set_location ('write premium by mo.  val:'||to_char(l_val),41);
       open c_pbm(p_actl_prem_id  => l_prems.actl_prem_id
                 ,p_mo_num        => l_mo_num
                 ,p_yr_num        => l_yr_num);
       fetch c_pbm into l_pbm;
       if c_pbm%notfound or c_pbm%notfound is null then
          -- bug  2784213
          l_effective_date_mo :=  last_day(to_date(l_yr_num||lpad(l_mo_num,2,0),'YYYYMM'));
          --
          ben_pl_r_oipl_prem_by_mo_api.create_pl_r_oipl_prem_by_mo
            (p_pl_r_oipl_prem_by_mo_id => l_pbm.pl_r_oipl_prem_by_mo_id
            ,p_effective_start_date    => l_effective_start_date
            ,p_effective_end_date      => l_effective_end_date
            ,p_mnl_adj_flag            => 'N'
            ,p_mo_num                  => l_mo_num
            ,p_yr_num                  => l_yr_num
            ,p_val                     => l_val
            ,p_uom                     => l_prems.uom  -- uom from actl_prem
            ,p_prtts_num               => l_results.num_of_prtts
            ,p_actl_prem_id            => l_prems.actl_prem_id
            ,p_cost_allocation_keyflex_id => l_cak
            ,p_business_group_id       => p_business_group_id
            ,p_object_version_number   => l_ovn
            ,p_request_id              => fnd_global.conc_request_id
            ,p_program_application_id  => fnd_global.prog_appl_id
            ,p_program_id              => fnd_global.conc_program_id
            ,p_program_update_date     => sysdate
            ,p_effective_date          => l_effective_date_mo ); -- p_effective_date);
       else
         --
         l_effective_date_mo :=  last_day(to_date(l_yr_num||lpad(l_mo_num,2,0),'YYYYMM'));
         ben_pl_r_oipl_prem_by_mo_api.update_pl_r_oipl_prem_by_mo
            (p_pl_r_oipl_prem_by_mo_id => l_pbm.pl_r_oipl_prem_by_mo_id
            ,p_effective_start_date    => l_effective_start_date
            ,p_effective_end_date      => l_effective_end_date
            ,p_mnl_adj_flag            => 'N'
            ,p_val                     => l_val
            ,p_uom                     => l_prems.uom  -- uom from actl_prem
            ,p_prtts_num               => l_results.num_of_prtts
            ,p_cost_allocation_keyflex_id => l_cak
            ,p_object_version_number   => l_pbm.object_version_number
            ,p_request_id              => fnd_global.conc_request_id
            ,p_program_application_id  => fnd_global.prog_appl_id
            ,p_program_id              => fnd_global.conc_program_id
            ,p_program_update_date     => sysdate
            ,p_effective_date          => l_effective_date_mo -- p_effective_date
            ,p_datetrack_mode          => hr_api.g_correction);
       end if;
       close c_pbm;
       -- write info to reporting table
       g_rec.rep_typ_cd            := 'PRPLOIPL';
       g_rec.person_id             := null;
       g_rec.pgm_id                := null;  -- ??l_pgm_id;
       g_rec.pl_id                 := l_pl_id;
       g_rec.oipl_id               := l_prems.oipl_id;
       g_rec.pl_typ_id             := l_pl_typ_id;
       g_rec.actl_prem_id          := l_prems.actl_prem_id;
       g_rec.val                   := l_val;
       g_rec.mo_num                := l_mo_num;
       g_rec.yr_num                := l_yr_num;

       benutils.write(p_rec => g_rec);

  If (p_validate = 'Y') then
    Rollback to process_pl_premium_savepoint;
  End if;

  hr_utility.set_location ('Leaving '||l_package,99);
exception
  when others then
    l_error_text := sqlerrm;
    hr_utility.set_location ('Fail in '||l_package||' error:',999);
    hr_utility.set_location (l_error_text,999);
    fnd_message.raise_error;
end main;
end ben_prem_pl_oipl_monthly;

/
