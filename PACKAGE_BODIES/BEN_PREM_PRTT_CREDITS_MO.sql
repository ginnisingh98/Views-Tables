--------------------------------------------------------
--  DDL for Package Body BEN_PREM_PRTT_CREDITS_MO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PREM_PRTT_CREDITS_MO" as
/* $Header: benprprc.pkb 120.0 2005/05/28 09:20:54 appldev noship $ */
g_package             varchar2(80) := 'ben_prem_prtt_credits_mo';
-- ----------------------------------------------------------------------------
-- |------------------------------< main >------------------------------------|
-- ----------------------------------------------------------------------------
-- This is the procedure to call to determine all participant premium credits
-- for prior months.
procedure main
  (p_validate                 in varchar2 default 'N',
   p_person_id                in number default null,
   p_pl_id                    in number default null,
   p_person_selection_rule_id in number default null,
   p_comp_selection_rule_id   in number default null,
   p_pgm_id                   in number default null,
   p_pl_typ_id                in number default null,
   p_organization_id          in number default null,
   p_legal_entity_id          in number default null,
   p_business_group_id        in number,
   p_mo_num                   in number,
   p_yr_num                   in number,
   p_first_day_of_month       in date,
   p_effective_date           in date) is
    --
  l_package               varchar2(80) := g_package||'.main';
  l_error_text            varchar2(200) := null;
  --
  -- participants that have paid a premium for coverage that ended and
  -- credit look-backs are defined for that actual-premium.  This cursor will
  -- really limit the results that are processed in this run.
  --
  cursor c_results is
    select distinct pen.prtt_enrt_rslt_id, pen.enrt_cvg_thru_dt, pen.pgm_id,
           pen.pl_id, pen.oipl_id, pen.person_id, pen.ler_id, pen.pl_typ_id,
           pen.prtt_enrt_rslt_stat_cd, pen.sspndd_flag, pil.per_in_ler_stat_cd,
           pen.effective_start_date, pen.effective_end_date,
           pen.enrt_cvg_strt_dt
    from   ben_prtt_enrt_rslt_f pen, ben_prtt_prem_f ppe,
           ben_per_in_ler pil
           ,ben_prtt_prem_by_mo_f prm, ben_actl_prem_f apr
    where
         ( (pen.sspndd_flag = 'N'
           -- Credits for 'normal' stuff and
           -- Task 417:  Credits for:
           -- c. voided results (RETRO and PRO).
    and    (pen.prtt_enrt_rslt_stat_cd is null
           or pen.prtt_enrt_rslt_stat_cd = 'VOIDD')
           -- result effective START date is this month
   -- and    pen.effective_start_date between
   --        p_first_day_of_month and p_effective_date
           -- cvg ended prior to the end of this month - needed for prospective
           -- for retro we really care about cvg ending last month.
    and    pen.enrt_cvg_thru_dt between  add_months(p_effective_date, - (apr.cr_lkbk_val))
                    and p_effective_date
           -- a premium was paid for the month in which coverage ended
    and    ((prm.mo_num = to_char(pen.enrt_cvg_thru_dt,'mm')
           and    prm.yr_num = to_char(pen.enrt_cvg_thru_dt,'yyyy'))
           -- or a premium was paid for the month after cvg ended
           or    (prm.mo_num = to_char(add_months(pen.enrt_cvg_thru_dt,1),'mm')
           and    prm.yr_num = to_char(add_months(pen.enrt_cvg_thru_dt,1),'yyyy')))
    and    pil.per_in_ler_stat_cd not in ('BCKDT')
    and    p_effective_date between
           ppe.effective_start_date and ppe.effective_end_date
    and    p_effective_date between
           prm.effective_start_date and prm.effective_end_date)
    -- Task 415:  Credits for:
    -- b. suspended results (PRO).
    or     (pen.sspndd_flag = 'Y'
    and    pen.prtt_enrt_rslt_stat_cd is null
           -- result effective START date is this month
    and    pen.effective_start_date between
           p_first_day_of_month and p_effective_date
           -- this will only happen for prospective, this is redundant
    and    apr.prsptv_r_rtsptv_cd = 'PRO'
           -- a premium was paid for the month in which coverage was suspended
    and    ((prm.mo_num = to_char(p_effective_date,'mm')
           and    prm.yr_num = to_char(p_effective_date,'yyyy')))
    and    pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
    and    p_effective_date between
           ppe.effective_start_date and ppe.effective_end_date
    and    p_effective_date between
           prm.effective_start_date and prm.effective_end_date)
    -- Task 415: create prem credits for:
    -- INTERIM dt-ended before cvg started criteria (PRO):
    or    (pen.prtt_enrt_rslt_stat_cd is null
           -- rows where result was ended, not just date-track updated.
    and    pen.object_version_number = (select max(object_version_number)
           from ben_prtt_enrt_rslt_f p where p.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id)
           -- cvg started sometime this month - a pro prem could have been written
    and    pen.enrt_cvg_strt_dt between p_first_day_of_month and p_effective_date
           -- result effective END date is this month
    and    pen.effective_end_date between
           p_first_day_of_month and p_effective_date
           -- date track ended before cvg started.
    and    pen.effective_end_date < pen.enrt_cvg_strt_dt
           -- a premium was paid for this month
    and    (prm.mo_num = to_char(p_first_day_of_month,'mm')
           and    prm.yr_num = to_char(p_first_day_of_month,'yyyy'))
           -- this will only happen for prospective, this is redundant
    and    apr.prsptv_r_rtsptv_cd = 'PRO'
    and    pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT'))
    -- Task 417: create prem credits for:
    -- BACKED OUT per in ler criteria (RETRO AND PRO):
    -- when the premium processfor backedout le
    -- get all the prem_by_mo for the period between the process and lkbk  prd
    -- then find ler_id for the premium is backed out and make sure credit entries are not alread ycreated for the
    --  premium bug 3692290
    or (pil.per_in_ler_stat_cd in ( 'BCKDT' ,'VOIDD')
       --- and    pil.bckt_dt between
       ---        p_first_day_of_month and p_effective_date
       --- and    p_effective_date between
       ---        ppe.effective_start_date and ppe.effective_end_date
       --- and    p_effective_date between
       ---        prm.effective_start_date and prm.effective_end_date
         and pil.per_in_ler_id = ppe.per_in_ler_id
         and ppe.prtt_prem_id  = prm.prtt_prem_id
         and prm.cr_val is null
         and prm.effective_start_date between add_months(p_effective_date, - (apr.cr_lkbk_val))
               and p_effective_date
          and  p_effective_date  between
               ppe.effective_start_date and ppe.effective_end_date
          and  p_effective_date  between
               prm.effective_start_date and prm.effective_end_date
          and not exists
            ( select pmo.prtt_prem_by_mo_id from  ben_prtt_prem_by_mo_f pmo
              where  pmo.prtt_prem_by_mo_id = prm.prtt_prem_by_mo_id
              and    pmo.cr_val is not null
            )
       )
    )
    and    pen.comp_lvl_cd not in ('PLANFC', 'PLANIMP')  -- not a dummy plan
    and    (pen.pl_id = p_pl_id  or p_pl_id is null)
    and    (pen.pl_typ_id = p_pl_typ_id or p_pl_typ_id is null)
    and    (pen.pgm_id = p_pgm_id or p_pgm_id is null)
    and    (pen.person_id = p_person_id or p_person_id is null)
           -- premium was not already credited
    and    nvl(prm.cr_val,0) = 0
           -- credit look backs defined
    and    apr.cr_lkbk_val is not null
    and    apr.cr_lkbk_val <>0  -- bug 1213601
    and    pen.business_group_id = p_business_group_id
    and    pen.prtt_enrt_rslt_id = ppe.prtt_enrt_rslt_id
    and    ppe.prtt_prem_id = prm.prtt_prem_id
    and    ppe.actl_prem_id = apr.actl_prem_id
    and    apr.prem_asnmt_cd = 'ENRT'
    and    p_effective_date between
           apr.effective_start_date and apr.effective_end_date
    -- Do not use effective date against ppe nor prm because we want to pick
    -- up interim rows that were end dated.
    --and    p_effective_date between
    --       ppe.effective_start_date and ppe.effective_end_date
    --and    p_effective_date between
    --       prm.effective_start_date and prm.effective_end_date
    and    pil.per_in_ler_id=ppe.per_in_ler_id
    and    pil.business_group_id=ppe.business_group_id;

  l_results c_results%rowtype;

  -- Participant Premiums to be processed:
  cursor c_prems (p_prtt_enrt_rslt_id number
                 ,p_interim varchar2) is
    select apr.actl_prem_id, apr.prtl_mo_det_mthd_cd, apr.prtl_mo_det_mthd_rl,
           apr.cr_lkbk_crnt_py_only_flag, apr.cr_lkbk_uom,
           apr.cr_lkbk_val, ppe.prtt_prem_id, apr.wsh_rl_dy_mo_num,
           apr.rndg_cd, apr.rndg_rl, ppe.std_prem_val, apr.prsptv_r_rtsptv_cd,
           apr.lwr_lmt_calc_rl, apr.lwr_lmt_val,
           apr.upr_lmt_calc_rl, apr.upr_lmt_val
    from   ben_actl_prem_f apr, ben_prtt_prem_f ppe
    where  apr.prem_asnmt_cd = 'ENRT'
    and    apr.cr_lkbk_val is not null   -- bug 1213601
    and    apr.cr_lkbk_val <>0
    and    ppe.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
    and    ppe.actl_prem_id = apr.actl_prem_id
    and    apr.business_group_id+0 = p_business_group_id
    and    (p_interim = 'Y'
     or    p_effective_date between
           ppe.effective_start_date and ppe.effective_end_date)
    and    p_effective_date between
           apr.effective_start_date and apr.effective_end_date;
  -- l_prems c_prems%rowtype;

  -- participant prem by month row:
  cursor c_prem_by_mo (p_prtt_prem_id number
               ,p_process_mo_num number
               ,p_process_yr_num number
               ,p_interim varchar2 ) is
    select prm.val, prm.prtt_prem_by_mo_id, prm.mo_num, prm.yr_num,
           prm.object_version_number, prm.effective_start_date
    from   ben_prtt_prem_by_mo_f prm
    where  prm.prtt_prem_id = p_prtt_prem_id
    and    prm.mo_num = p_process_mo_num
    and    prm.yr_num = p_process_yr_num
    and    prm.business_group_id+0 = p_business_group_id
    and    (p_interim = 'Y'
     or    p_effective_date between
           prm.effective_start_date and prm.effective_end_date);
  l_prem_by_mo c_prem_by_mo%rowtype;

  -- plan year period for the effective date and the plan:
  cursor c_pl_yr  (p_pgm_id number, p_pl_id number) is
    select yrp.start_date
    from   ben_yr_perd yrp, ben_popl_yr_perd cpy
    where  yrp.business_group_id+0 = p_business_group_id
    and    p_effective_date between
           yrp.start_date and yrp.end_date
    and    yrp.yr_perd_id = cpy.yr_perd_id
    and    ((cpy.pgm_id = p_pgm_id) or
           (p_pgm_id is null and cpy.pl_id = p_pl_id));
  l_pl_yr c_pl_yr%rowtype;

  cursor c_opt(l_oipl_id  number) is
	select opt_id from ben_oipl_f oipl
	where oipl.oipl_id = l_oipl_id
        and p_effective_date between
            oipl.effective_start_date and oipl.effective_end_date;
  l_opt c_opt%rowtype;

  l_effective_start_date date;
  l_effective_end_date   date;
  l_ovn                  number;
  l_process_date         date;
  l_process_mo_num       number;
  l_process_yr_num       number;
  l_cvg_end_day_num      number;
  l_earliest_date        date;
  l_cvg_end_mo           varchar2(1);
  l_val                  number;
  l_datetrack_mode       varchar2(30);
  l_rule_ret             char(1);
  l_interim              varchar2(1);
  l_effective_date       date;
  l_prem_val             number;

begin
  hr_utility.set_location ('Entering '||l_package,10);
  savepoint process_premium_credits;
  -- p_effective_date is always the last day of the month this is being run
  -- loop thru results that may have a credit  required.
  for l_results in c_results loop
     hr_utility.set_location ('loop l_results '||
                to_char(l_results.prtt_enrt_rslt_id),12);

     l_rule_ret := 'Y';
     if p_person_selection_rule_id is not null then
        hr_utility.set_location('found a person rule',14);
        l_rule_ret := ben_batch_utils.person_selection_rule
                    (p_person_id               => l_results.person_id
                    ,p_business_group_id       => p_business_group_id
                    ,p_person_selection_rule_id=> p_person_selection_rule_id
                    ,p_effective_date          => p_effective_date
                    );
     end if;
     if l_rule_ret = 'Y'  then
        if l_results.oipl_id is not null then
           open c_opt(l_results.oipl_id);
           fetch c_opt into l_opt;
           close c_opt;
        end if;
     end if;

     if l_rule_ret = 'Y' and p_comp_selection_rule_id is not null then
        hr_utility.set_location('found a comp object rule',16);
        if l_results.oipl_id is not null then
           open c_opt(l_results.oipl_id);
           fetch c_opt into l_opt;
           close c_opt;
        end if;

        l_rule_ret:=ben_maintain_designee_elig.comp_selection_rule(
                p_person_id                => l_results.person_id
               ,p_business_group_id        => p_business_group_id
               ,p_pgm_id                   => l_results.pgm_id
               ,p_pl_id                    => l_results.pl_id
               ,p_pl_typ_id                => l_results.pl_typ_id
               ,p_opt_id                   => l_opt.opt_id
               ,p_oipl_id                  => l_results.oipl_id
               ,p_ler_id                   => null  -- do not call with ler.
               ,p_comp_selection_rule_id   => p_comp_selection_rule_id
               ,p_effective_date           => p_effective_date
      );
     end if;

     -- rules say to continue with person and comp object
     if l_rule_ret = 'Y' then

       -- day the coverage ended is needed for determining a partial month credit.
       l_cvg_end_day_num :=  to_char(l_results.enrt_cvg_thru_dt,'DD');
       if l_results.sspndd_flag = 'Y' then
          -- if result is suspended, we need to 'end cvg' with the suspend date,
          -- because there is no cvg end date set.
          l_results.enrt_cvg_thru_dt := l_results.effective_start_date;
       end if;
       if l_results.enrt_cvg_strt_dt > l_results.effective_end_date then
          -- we're dealing with an interim result ended before cvg started.
          l_interim := 'Y';
       else l_interim := 'N';
       end if;

       -- loop thru the prtt_prems for the result
       for l_prems in c_prems
                    (p_prtt_enrt_rslt_id => l_results.prtt_enrt_rslt_id
                    ,p_interim           => l_interim) loop
          hr_utility.set_location ('loop prems '||to_char(l_prems.prtt_prem_id),14);

          if (l_prems.prsptv_r_rtsptv_cd = 'RETRO'
             and l_results.enrt_cvg_thru_dt < p_first_day_of_month) or
             l_prems.prsptv_r_rtsptv_cd = 'PRO' or
             l_results.per_in_ler_stat_cd = 'BCKDT'  then

             -- For retro premiums, a credit is only calculated if the cvg
             -- ended before the beginning of this month.  If cvg ended during
             -- this month, the correct premium value would have been
             -- calculated in benprprm.
             -- For Prospective premiums, if cvg ended this month, we must
             -- calc a credit, because benprprm deals with next month's
             -- cvg for PRO premiums.
             -- For Backed Out results, the cvg end date is not set, we want
             -- to credit all premiums.

             -- actl-prem look-back converted into earliest date to provide premium credits
             -- Lookback UOM should only ever be 'Month', but I'd already coded all
             -- this, so  here it stays.
             if l_prems.cr_lkbk_uom = 'DY' then
                l_earliest_date :=
                  to_date('01-'||to_char(p_effective_date - l_prems.cr_lkbk_val,'MM-YYYY'),
                  'DD-MM-YYYY');
             elsif l_prems.cr_lkbk_uom = 'WK' then
                l_earliest_date :=
                  to_date('01-'||
                  to_char(p_effective_date - (l_prems.cr_lkbk_val*7),'MM-YYYY'),
                  'DD-MM-YYYY');
             elsif l_prems.cr_lkbk_uom = 'MO' then
                l_earliest_date :=
                  to_date('01-'||
                  to_char(add_months(p_effective_date , -l_prems.cr_lkbk_val),'MM-YYYY'),
                  'DD-MM-YYYY');
             else  --if l_prems.cr_lkbk_uom = 'YR' then
                l_earliest_date :=
                  to_date('01-'||
                  to_char(add_months(p_effective_date , -(l_prems.cr_lkbk_val*12)),'MM-YYYY'),
                  'DD-MM-YYYY');
             end if;

             if l_prems.cr_lkbk_crnt_py_only_flag = 'Y' then
                 hr_utility.set_location ('py_only_flag = Y ',14);
                 -- don't go before the current plan year.
                 open c_pl_yr (p_pgm_id => l_results.pgm_id
                              ,p_pl_id  => l_results.pl_id);
                 fetch c_pl_yr into l_pl_yr;
                 if c_pl_yr%found then
                    if l_earliest_date < l_pl_yr.start_date then
                       l_earliest_date :=
                         to_date('01-'||to_char(l_pl_yr.start_date,'mm-yyyy'),'dd-mm-yyyy');
                    end if;
                 end if;
                 close c_pl_yr;
             end if;
             hr_utility.set_location ('earliest date '||
                     to_char(l_earliest_date,'dd-mon-yyyy'),17);

             -- for each premium we loop thru, load the earliest date we want to
             -- process a credit for.
             if l_results.per_in_ler_stat_cd = 'BCKDT' or
                l_interim = 'Y' then
                -- if result is backed out or we are end-dating a result before
                -- coverage starts, we need to start with the cvg strt dt,
                -- because there is no cvg end date set.
                l_process_date :=
                 to_date('01-'||to_char(l_results.enrt_cvg_strt_dt,'MM-YYYY'),'DD-MM-YYYY');
                l_process_mo_num := to_char(l_results.enrt_cvg_strt_dt,'MM');
                l_process_yr_num := to_char(l_results.enrt_cvg_strt_dt,'YYYY');
                -- this flag is used to determine partial month.  in these cases, we
                -- do not want to calc partial month credit, we want to credit the
                -- entire prem amt.
                l_cvg_end_mo := 'N';
             else
                -- Start with the coverage end date month.  use the first day of the month
                -- for comparison's sake.
                l_process_date :=
                 to_date('01-'||to_char(l_results.enrt_cvg_thru_dt,'MM-YYYY'),'DD-MM-YYYY');
                l_process_mo_num := to_char(l_results.enrt_cvg_thru_dt,'MM');
                l_process_yr_num := to_char(l_results.enrt_cvg_thru_dt,'YYYY');
                l_cvg_end_mo := 'Y';
             end if;

             loop
               -- If month we are about to process is before the earliest month
               -- we should process, then skip to next month.
               hr_utility.set_location ('process date '||
                        to_char(l_process_date,'dd-mon-yyyy'),20);
               if l_process_date >= l_earliest_date and
                  l_results.enrt_cvg_thru_dt <> last_day(l_process_date) then
                 open c_prem_by_mo
                       (p_prtt_prem_id   => l_prems.prtt_prem_id
                       ,p_process_mo_num => l_process_mo_num
                       ,p_process_yr_num => l_process_yr_num
                       ,p_interim        => l_interim) ;
                 fetch c_prem_by_mo into l_prem_by_mo;

                 -- l_val is what they paid for the month in question
                 l_val := l_prem_by_mo.val;
                 hr_utility.set_location ('prem amt '||to_char(l_val),24);
                 if c_prem_by_mo%found then
                 hr_utility.set_location ('prem amt ',26);
                     -- this might be a partial credit for month where
                     -- cvg ended, unless cvg ended on last day of month.
                     -- Don't calc partial month for voided or backed out results,
                     -- credit the entire premium amt.
                     -- Also, do not calc partial credit if the cvg thru dt is less
                     -- than the cvg strt dt (or rslt sspndd before cvg starts)
                     -- even the coverage ended eof month and the partial calc code is rl or proration
                     -- call the partial calcualtion
                     if l_cvg_end_mo = 'Y'
                        and ( ( l_results.enrt_cvg_thru_dt <> last_day(l_process_date)
                                and to_char(l_results.enrt_cvg_thru_dt, 'MM-RRRR') = to_char(l_process_date,'MM-RRRR')
                              )
                             or ( l_results.enrt_cvg_thru_dt =  last_day(l_process_date)
                                  and l_prems.prtl_mo_det_mthd_cd in ('PRTVAL','WASHRULE','RL')
                                )
                            )
                        and l_results.prtt_enrt_rslt_stat_cd is null
                        and l_results.enrt_cvg_strt_dt <= l_results.enrt_cvg_thru_dt then

                            hr_utility.set_location ('prem amt ',28);
                        ben_prem_prtt_monthly.compute_partial_mo
                          (p_business_group_id   => p_business_group_id
                          ,p_effective_date      => p_effective_date
                          ,p_actl_prem_id        => l_prems.actl_prem_id
                          ,p_person_id           => l_results.person_id
                          ,p_enrt_cvg_strt_dt    => null
                          ,p_enrt_cvg_thru_dt    => l_results.enrt_cvg_thru_dt
                          ,p_prtl_mo_det_mthd_cd => l_prems.prtl_mo_det_mthd_cd
                          ,p_prtl_mo_det_mthd_rl => l_prems.prtl_mo_det_mthd_rl
                          ,p_wsh_rl_dy_mo_num    => l_prems.wsh_rl_dy_mo_num
                          ,p_rndg_cd             => l_prems.rndg_cd
                          ,p_rndg_rl             => l_prems.rndg_rl
                          ,p_lwr_lmt_calc_rl     => l_prems.lwr_lmt_calc_rl
                          ,p_lwr_lmt_val         => l_prems.lwr_lmt_val
                          ,p_upr_lmt_calc_rl     => l_prems.upr_lmt_calc_rl
                          ,p_upr_lmt_val         => l_prems.upr_lmt_val
                          ,p_pgm_id              => l_results.pgm_id
                          ,p_pl_typ_id           => l_results.pl_typ_id
                          ,p_pl_id               => l_results.pl_id
                          ,p_opt_id              => l_opt.opt_id
                          ,p_val                 => l_prems.std_prem_val);
                        -- l_prems.std_prem_val when passed in was max premium he
                        -- could have paid.  compute_partial returns what he should have
                        -- paid.
                        -- Convert this into a credit amount based on what he did pay.
                        hr_utility.set_location ('debit  amt '||to_char(l_prem_by_mo.val),28);
                        hr_utility.set_location ('partial   amt '||to_char(l_prems.std_prem_val),28);
                        l_val := l_prem_by_mo.val - l_prems.std_prem_val;
                     end if;
                     hr_utility.set_location ('credit amt '||to_char(l_val),28);

                     if l_val > 0 then
                       -- found a premium paid for this month, credit them.
                       -- Do not write negative credits!
                       if p_effective_date = l_prem_by_mo.effective_start_date then
                          l_datetrack_mode := hr_api.g_correction;
                       else
                          l_datetrack_mode := hr_api.g_update;
                       end if;
                       if l_interim = 'Y' then
                          -- if we are running with an ended interim, we can't update
                          -- on the end-of-month date because the record was end-dated
                          -- sometime this month.
                          l_effective_date := l_results.effective_end_date;
                          l_datetrack_mode := hr_api.g_correction;
                       else
                          l_effective_date := p_effective_date;
                       end if;
                       -- bug#2823935 -
                       if l_datetrack_mode = hr_api.g_update then
                           l_prem_val := null;
                       else
                           l_prem_val := l_prem_by_mo.val;
                       end if;
                       --
                       ben_prtt_prem_by_mo_api.update_prtt_prem_by_mo
                         (p_prtt_prem_by_mo_id    => l_prem_by_mo.prtt_prem_by_mo_id
                         ,p_effective_start_date  => l_effective_start_date
                         ,p_effective_end_date    => l_effective_end_date
                         ,p_val                   => l_prem_val
                         ,p_cr_val                => l_val
                         ,p_object_version_number => l_prem_by_mo.object_version_number
                         ,p_request_id            => fnd_global.conc_request_id
                         ,p_program_application_id  => fnd_global.prog_appl_id
                         ,p_program_id            => fnd_global.conc_program_id
                         ,p_program_update_date   => sysdate
                         ,p_effective_date        => l_effective_date
                         ,p_datetrack_mode        => l_datetrack_mode);
                       --
                       -- write to the report table
                       g_rec.rep_typ_cd            := 'PRCREDIT';
                       g_rec.person_id             := l_results.person_id;
                       g_rec.pgm_id                := l_results.pgm_id;
                       g_rec.pl_id                 := l_results.pl_id;
                       g_rec.oipl_id               := l_results.oipl_id;
                       g_rec.pl_typ_id             := l_results.pl_typ_id;
                       g_rec.actl_prem_id          := l_prems.actl_prem_id;
                       g_rec.val                   := l_val;
                       g_rec.mo_num                := l_process_mo_num;
                       g_rec.yr_num                := l_process_yr_num;

                       benutils.write(p_rec => g_rec);

                     end if;
                     close c_prem_by_mo;
                 else
                     close c_prem_by_mo;
                     --exit;
                 end if;   -- if c_prem_by_mo found
               end if;
               -- check following month until we run out of premiums paid
               l_process_date := add_months(l_process_date,1);
               if l_process_date > p_effective_date then
                  exit ;
               end if ;
               l_process_mo_num := to_char(l_process_date,'MM');
               l_process_yr_num := to_char(l_process_date,'YYYY');
               l_cvg_end_mo := 'N';
             end loop;
          end if;  -- if 'pro' or ('retro' and cvg ended last month)
       end loop;  -- prtt prems
     end if;    -- rules pass
  end loop;   -- results

  if p_validate = 'Y' then
     Rollback to process_premium_credits;
  end if;
  hr_utility.set_location ('Leaving '||l_package,99);
exception
  when others then
    l_error_text := sqlerrm;
    hr_utility.set_location ('Fail in '||l_package,999);
    hr_utility.set_location ('with error '||l_error_text,999);
    fnd_message.raise_error;
end main;
end ben_prem_prtt_credits_mo;

/
