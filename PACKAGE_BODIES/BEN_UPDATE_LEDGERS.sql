--------------------------------------------------------
--  DDL for Package Body BEN_UPDATE_LEDGERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_UPDATE_LEDGERS" as
/* $Header: benbplup.pkb 120.2.12010000.2 2008/08/05 14:33:56 ubhat ship $ */

-- Package Variables
g_package  varchar2(33) := '  ben_update_ledgers.';

-- ---------------------------------------------------------------------
-- main
-- ---------------------------------------------------------------------
procedure main  is

  l_proc varchar2(72)     := g_package||'main';

  -- if acty-ref-perd-cd is not null, we ran this against the row.
  -- added used-val in where to pick up rows where prv row has different value
  -- than bpl row (like where rollovers went to two pools for one rslt)
  cursor c_ldgr is
    select bpl.bnft_prvdd_ldgr_id, bpl.acty_base_rt_id, bpl.prtt_enrt_rslt_id,
           bpl.business_group_id, bpl.effective_start_date, bpl.effective_end_date,
           bpl.object_version_number, bpl.per_in_ler_id,
           bpl.frftd_val, bpl.used_val, bpl.prvdd_val, bpl.cash_recd_val, bpl.rld_up_val
     from  ben_bnft_prvdd_ldgr_f bpl,
           ben_per_in_ler pil,
           ben_prtt_enrt_rslt_f pen
    where  (bpl.acty_ref_perd_cd is null or
            (bpl.used_val is not null and bpl.cmcd_used_val is null))
            and bpl.per_in_ler_id = pil.per_in_ler_id
            and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
            and bpl.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
	    and pen.prtt_enrt_rslt_stat_cd is null
            and bpl.effective_start_date between pen.effective_start_date
            and pen.effective_end_date ;
  l_ldgr  c_ldgr%rowtype;
  l_object_version_number  number ;
  --

  l_cmcd_frftd_val     number := null;
  l_cmcd_prvdd_val     number := null;
  l_cmcd_rld_up_val    number := null;
  l_cmcd_used_val      number := null;
  l_cmcd_cash_recd_val number := null;
  l_ann_frftd_val      number := null;
  l_ann_prvdd_val      number := null;
  l_ann_rld_up_val     number := null;
  l_ann_used_val       number := null;
  l_ann_cash_recd_val  number := null;
  l_acty_ref_perd_cd   varchar2(30) := null;
  l_cmcd_ref_perd_cd   varchar2(30) := null;

  l_datetrack_mode     varchar2(30);
  test_ldgr_id         number;
BEGIN
  hr_utility.set_location('Entering '||l_proc, 10);

/*  new columns being loaded:
 ACTY_REF_PERD_CD                         VARCHAR2(30)
 CMCD_FRFTD_VAL                           NUMBER
 CMCD_PRVDD_VAL                           NUMBER
 CMCD_RLD_UP_VAL                          NUMBER
 CMCD_USED_VAL                            NUMBER
 CMCD_CASH_RECD_VAL                       NUMBER
 CMCD_REF_PERD_CD                         VARCHAR2(30)
 ANN_FRFTD_VAL                            NUMBER
 ANN_PRVDD_VAL                            NUMBER
 ANN_RLD_UP_VAL                           NUMBER
 ANN_USED_VAL                             NUMBER
 ANN_CASH_RECD_VAL
*/

  for l_ldgr in c_ldgr loop
    hr_utility.set_location('This result is:  ', 20);

    l_acty_ref_perd_cd    := null;
    l_cmcd_ref_perd_cd    := null;
    l_cmcd_frftd_val      := null;
    l_cmcd_prvdd_val      := null;
    l_cmcd_rld_up_val     := null;
    l_cmcd_used_val       := null;
    l_cmcd_cash_recd_val  := null;
    l_ann_frftd_val       := null;
    l_ann_prvdd_val       := null;
    l_ann_rld_up_val      := null;
    l_ann_used_val        := null;
    l_ann_cash_recd_val   := null;

    get_cmcd_ann_values
           (p_bnft_prvdd_ldgr_id   => l_ldgr.bnft_prvdd_ldgr_id,
           p_acty_base_rt_id       => l_ldgr.acty_base_rt_id,
           p_prtt_enrt_rslt_id     => l_ldgr.prtt_enrt_rslt_id,
           p_business_group_id     => l_ldgr.business_group_id,
           p_effective_start_date  => l_ldgr.effective_start_date,
           p_per_in_ler_id         => l_ldgr.per_in_ler_id,
           p_frftd_val             => l_ldgr.frftd_val,
           p_used_val              => l_ldgr.used_val,
           p_prvdd_val             => l_ldgr.prvdd_val,
           p_cash_recd_val         => l_ldgr.cash_recd_val,
           p_rld_up_val            => l_ldgr.rld_up_val,
           p_acty_ref_perd_cd      => l_acty_ref_perd_cd,  -- beginning of out parms
           p_cmcd_ref_perd_cd      => l_cmcd_ref_perd_cd,
           p_cmcd_frftd_val        => l_cmcd_frftd_val,
           p_cmcd_prvdd_val        => l_cmcd_prvdd_val,
           p_cmcd_rld_up_val       => l_cmcd_rld_up_val,
           p_cmcd_used_val         => l_cmcd_used_val,
           p_cmcd_cash_recd_val    => l_cmcd_cash_recd_val,
           p_ann_frftd_val         => l_ann_frftd_val,
           p_ann_prvdd_val         => l_ann_prvdd_val,
           p_ann_rld_up_val        => l_ann_rld_up_val,
           p_ann_used_val          => l_ann_used_val,
           p_ann_cash_recd_val     => l_ann_cash_recd_val);

      -- Now update the ledger columns if we found something to update them with:
      if l_cmcd_frftd_val is not null or l_cmcd_prvdd_val is not null or
         l_cmcd_rld_up_val is not null or l_cmcd_used_val is not null or
         l_cmcd_cash_recd_val is not null then
          /* get_dt_mode
             (p_effective_date       => l_ldgr.effective_start_date,
              p_base_key_value       => l_ldgr.bnft_prvdd_ldgr_id,
              p_mode                 => l_datetrack_mode);
          */
        --
        --
        hr_utility.set_location('Updating ledger.  Id='||to_char(l_ldgr.bnft_prvdd_ldgr_id),22);
        begin
           ben_Benefit_Prvdd_Ledger_api.update_Benefit_Prvdd_Ledger (
            p_bnft_prvdd_ldgr_id           => l_ldgr.bnft_prvdd_ldgr_id
           ,p_effective_start_date         => l_ldgr.effective_start_date
           ,p_effective_end_date           => l_ldgr.effective_end_date
           ,p_acty_ref_perd_cd             => l_acty_ref_perd_cd
           ,p_cmcd_frftd_val               => l_cmcd_frftd_val
           ,p_cmcd_prvdd_val               => l_cmcd_prvdd_val
           ,p_cmcd_rld_up_val              => l_cmcd_rld_up_val
           ,p_cmcd_used_val                => l_cmcd_used_val
           ,p_cmcd_cash_recd_val           => l_cmcd_cash_recd_val
           ,p_cmcd_ref_perd_cd             => l_cmcd_ref_perd_cd
           ,p_ann_frftd_val                => l_ann_frftd_val
           ,p_ann_prvdd_val                => l_ann_prvdd_val
           ,p_ann_rld_up_val               => l_ann_rld_up_val
           ,p_ann_used_val                 => l_ann_used_val
           ,p_ann_cash_recd_val            => l_ann_cash_recd_val
           ,p_object_version_number        => l_ldgr.object_version_number
           ,p_effective_date               => l_ldgr.effective_start_date
           ,p_datetrack_mode               => 'CORRECTION');
           hr_utility.set_location('Updated Ledger.  Id='||to_char(l_ldgr.bnft_prvdd_ldgr_id),24);
         exception
              when others then
                  --continue leaving the errored record
                  null;
          end;
      end if;

  end loop;

  hr_utility.set_location('Leaving '||l_proc, 999);

END;  -- main
-- ---------------------------------------------------------------------
-- get_cmcd_ann_values
-- ---------------------------------------------------------------------
procedure get_cmcd_ann_values
           (p_bnft_prvdd_ldgr_id   in number default null,
           p_acty_base_rt_id       in number,
           p_prtt_enrt_rslt_id     in number,
           p_business_group_id     in number,
           p_effective_start_date  in date,
           p_per_in_ler_id         in number,
           p_frftd_val             in number,
           p_used_val              in number,
           p_prvdd_val             in number,
           p_cash_recd_val         in number,
           p_rld_up_val            in number,
           p_acty_ref_perd_cd    out nocopy varchar2,
           p_cmcd_ref_perd_cd    out nocopy varchar2,
           p_cmcd_frftd_val      out nocopy number,
           p_cmcd_prvdd_val      out nocopy number,
           p_cmcd_rld_up_val     out nocopy number,
           p_cmcd_used_val       out nocopy number,
           p_cmcd_cash_recd_val  out nocopy number,
           p_ann_frftd_val       out nocopy number,
           p_ann_prvdd_val       out nocopy number,
           p_ann_rld_up_val      out nocopy number,
           p_ann_used_val        out nocopy number,
           p_ann_cash_recd_val   out nocopy number) is

  l_proc varchar2(72)     := g_package||'get_cmcd_ann_values';
  cursor c_ldgr(c_bnft_prvdd_ldgr_id in number,
                c_effective_date     in date) is
    select bpl.acty_base_rt_id, bpl.prtt_enrt_rslt_id,
           bpl.business_group_id,  bpl.per_in_ler_id
     from  ben_bnft_prvdd_ldgr_f bpl
    where  bpl.bnft_prvdd_ldgr_id = c_bnft_prvdd_ldgr_id
      and  c_effective_date between
           bpl.effective_start_date and bpl.effective_end_date;
  l_ldgr        c_ldgr%rowtype;
  l_ldgr_parms  c_ldgr%rowtype;

   -- This is the DUMMY flex credit row.  ALL ledgers hang off this.
  cursor c_rslt (c_prtt_enrt_rslt_id in number,
                 c_effective_date    in date) is
    select distinct pen.person_id, pen.pgm_id,
           pgm.acty_ref_perd_cd, pgm.enrt_info_rt_freq_cd
    from   ben_prtt_enrt_rslt_f pen, ben_pgm_f pgm
    where  pen.prtt_enrt_rslt_id = c_prtt_enrt_rslt_id
      and  pen.pgm_id = pgm.pgm_id
      and  pen.prtt_enrt_rslt_stat_cd is null
      and  c_effective_date between
           pen.effective_start_date and pen.effective_end_date
      and  c_effective_date between
           pgm.effective_start_date and pgm.effective_end_date;
  l_rslt  c_rslt%rowtype;
  /*
  cursor c_person (c_person_id      in number,
                   c_effective_date in date) is
    select distinct asg.payroll_id
    from   per_all_assignments_f asg
    where  asg.person_id = c_person_id
      and   asg.assignment_type <> 'C'
      and  asg.primary_flag = 'Y'
      and  c_effective_date between
           asg.effective_start_date and asg.effective_end_date;
  l_person  c_person%rowtype;
  */

  -- for used rates, there is no direct link from the ldgr to the person's result's
  -- rate.  We have to join on acty-base-rt-id to prtt-rt-val, then from prtt-rt-val
  -- to check that we have the right person's result.
  cursor c_used_rate (c_acty_base_rt_id      in number,
                      c_person_id            in number,
                      c_acty_ref_perd_cd     in varchar2,
                      c_enrt_info_rt_freq_cd in varchar2,
                      c_effective_date       in date,
                      c_used_val             in number)is
    select distinct ann_rt_val, cmcd_rt_val
    from   ben_prtt_rt_val prv, ben_prtt_enrt_rslt_f pen
    where  prv.acty_base_rt_id = c_acty_base_rt_id
           -- make sure we're dealing with the exact same rate
      and  prv.rt_val = c_used_val
      and  prv.acty_ref_perd_cd = c_acty_ref_perd_cd
      and  prv.cmcd_ref_perd_cd = c_enrt_info_rt_freq_cd
           -- make sure the rate is for our person
      and  prv.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
      and  pen.person_id = c_person_id
      and  pen.prtt_enrt_rslt_stat_cd is null
      and  c_effective_date between
           pen.effective_start_date and pen.effective_end_date;
  l_used_rate c_used_rate%rowtype;

  -- for providded rates, we can go right from the result-id on the ldgr to
  -- that result for the person.
  cursor c_prvdd_rate (c_prtt_enrt_rslt_id    in number,
                       c_acty_ref_perd_cd     in varchar2,
                       c_enrt_info_rt_freq_cd in varchar2,
                       c_effective_date       in date,
                       c_prvdd_val            in number)is
    select distinct ann_rt_val, cmcd_rt_val
    from   ben_prtt_rt_val prv
    where  prv.rt_val = c_prvdd_val
      and  prv.acty_ref_perd_cd = c_acty_ref_perd_cd
      and  prv.cmcd_ref_perd_cd = c_enrt_info_rt_freq_cd
      and  prv.prtt_enrt_rslt_id = c_prtt_enrt_rslt_id;
  l_prvdd_rate c_prvdd_rate%rowtype;
  -- and if we can't find the prvdd rate in the result table, we'll look in the
  -- enrt-rt table.
  cursor c_prvdd_rate2 (c_acty_base_rt_id      in number,
                        c_person_id            in number,
                        c_per_in_ler_id        in number,
                        c_acty_ref_perd_cd     in varchar2,
                        c_enrt_info_rt_freq_cd in varchar2,
                        c_effective_date       in date,
                        c_prvdd_val            in number)is
    select distinct ann_val, cmcd_val
    from   ben_enrt_rt ecr, ben_elig_per_elctbl_chc epe, ben_per_in_ler pil,
           ben_pil_elctbl_chc_popl pel
    where  ecr.acty_base_rt_id = c_acty_base_rt_id
           -- make sure we're dealing with the exact same rate
      and  ecr.val = c_prvdd_val
      and  pel.acty_ref_perd_cd = c_acty_ref_perd_cd
      and  ecr.cmcd_acty_ref_perd_cd = c_enrt_info_rt_freq_cd
           -- make sure the rate is for our person
      and  ecr.elig_per_elctbl_chc_id = epe.elig_per_elctbl_chc_id
      and  epe.pil_elctbl_chc_popl_id = pel.pil_elctbl_chc_popl_id
      and  epe.per_in_ler_id = c_per_in_ler_id
      and  pel.per_in_ler_id = pil.per_in_ler_id
      and  pil.person_id = c_person_id;
  l_prvdd_rate2 c_prvdd_rate2%rowtype;

  -- for cash and forfeited rates, we calc the value from the enrt-rt for the
  -- abr on the ldgr
  cursor c_choice_data  (c_acty_base_rt_id      in number,
                             c_person_id            in number,
                             c_per_in_ler_id        in number,
                             c_acty_ref_perd_cd     in varchar2,
                             c_enrt_info_rt_freq_cd in varchar2,
                             c_effective_date       in date)is
    select distinct epe.elig_per_elctbl_chc_id, ecr.enrt_rt_id, pil.lf_evt_ocrd_dt
    from   ben_enrt_rt ecr, ben_elig_per_elctbl_chc epe, ben_per_in_ler pil,
           ben_pil_elctbl_chc_popl pel, ben_enrt_bnft enb
    where  ecr.acty_base_rt_id = c_acty_base_rt_id
           -- make sure we're dealing with the exact same rate
      and  pel.acty_ref_perd_cd = c_acty_ref_perd_cd
      and  ecr.cmcd_acty_ref_perd_cd = c_enrt_info_rt_freq_cd
           -- make sure the rate is for our person
      and  epe.elig_per_elctbl_chc_id = enb.elig_per_elctbl_chc_id(+)
      and  (epe.elig_per_elctbl_chc_id = ecr.elig_per_elctbl_chc_id or
           enb.enrt_bnft_id = ecr.enrt_bnft_id)
      and  epe.pil_elctbl_chc_popl_id = pel.pil_elctbl_chc_popl_id
      and  epe.per_in_ler_id = c_per_in_ler_id
      and  pel.per_in_ler_id = pil.per_in_ler_id
      and  pil.person_id = c_person_id;
  l_choice_data c_choice_data%rowtype;
--
-- Bug No 4538786 Added cursor to fetch the rate and element id
-- of the Flex Shell plan instead of the flex credits
--
cursor get_flex_shell_rt(c_per_in_ler_id        in number,
                         c_pgm_id               in number) is
   select  ecr.enrt_rt_id, abr.acty_base_rt_id, abr.element_type_id,
           epe.elig_per_elctbl_chc_id , pil.lf_evt_ocrd_dt
   from ben_enrt_rt ecr, ben_elig_per_elctbl_chc epe, ben_per_in_ler pil,
        ben_acty_base_rt_f abr
   where epe.elig_per_elctbl_chc_id = ecr.elig_per_elctbl_chc_id
     and epe.pgm_id = c_pgm_id
     and epe.comp_lvl_cd = 'PLANFC'
     and pil.per_in_ler_id = epe.per_in_ler_id
     and epe.per_in_ler_id = c_per_in_ler_id
     and ecr.acty_base_rt_id = abr.acty_base_rt_id;
l_flex_shell_rt get_flex_shell_rt%rowtype;
--
-- End Bug No 4538786
--
--GEVITY
 cursor c_abr(cv_acty_base_rt_id number)
 is select rate_periodization_rl
      from ben_acty_base_rt_f abr
     where abr.acty_base_rt_id = cv_acty_base_rt_id
       and p_effective_start_date between abr.effective_start_date
                                and abr.effective_end_date ;
 --
 l_rate_periodization_rl NUMBER;
 --
 l_dfnd_dummy number;
 l_ann_dummy  number;
 l_cmcd_dummy number;
 l_assignment_id                 per_all_assignments_f.assignment_id%type;
 l_payroll_id                    per_all_assignments_f.payroll_id%type;
 l_organization_id               per_all_assignments_f.organization_id%type;
 --END GEVITY
begin
    hr_utility.set_location('Entering '||l_proc, 10);
    -- init all the out parms
    p_acty_ref_perd_cd    := null;
    p_cmcd_ref_perd_cd    := null;
    p_cmcd_frftd_val      := null;
    p_cmcd_prvdd_val      := null;
    p_cmcd_rld_up_val     := null;
    p_cmcd_used_val       := null;
    p_cmcd_cash_recd_val  := null;
    p_ann_frftd_val       := null;
    p_ann_prvdd_val       := null;
    p_ann_rld_up_val      := null;
    p_ann_used_val        := null;
    p_ann_cash_recd_val   := null;
    --
    -- When updating ledgers, the api may not get all the parms passed in, hence
    -- we might not either.  Go get the ones we need.
    if p_prtt_enrt_rslt_id is null or p_acty_base_rt_id is null or
       p_per_in_ler_id is null or p_business_group_id is null then
       hr_utility.set_location('Have to find out nocopy ledger parms:'||
          to_char(p_bnft_prvdd_ldgr_id), 20);
       open c_ldgr(c_bnft_prvdd_ldgr_id => p_bnft_prvdd_ldgr_id,
                   c_effective_date     => p_effective_start_date);
       fetch c_ldgr into l_ldgr;
       if c_ldgr%NOTFOUND or c_ldgr%NOTFOUND is null then
          -- if we can't find this info, we can't find the data we need.
          hr_utility.set_location('LEDGER INFO NOT FOUND.  LEDGER ID='||
            to_char(p_bnft_prvdd_ldgr_id)||' DATE='||
            to_char(p_effective_start_date)||' RESULT ID='||
            to_char(p_prtt_enrt_rslt_id)||' ',22);
          close c_ldgr;
          return;              --<-------------------------------------
       end if;
       close c_ldgr;
       hr_utility.set_location('Found ledger parms',24);
    end if;
    if p_prtt_enrt_rslt_id is null then
          l_ldgr_parms.prtt_enrt_rslt_id := l_ldgr.prtt_enrt_rslt_id;
    else
       l_ldgr_parms.prtt_enrt_rslt_id := p_prtt_enrt_rslt_id;
    end if;
    if p_prtt_enrt_rslt_id is null then
          l_ldgr_parms.acty_base_rt_id := l_ldgr.acty_base_rt_id;
    else
       l_ldgr_parms.acty_base_rt_id   := p_acty_base_rt_id;
    end if;
    if p_per_in_ler_id is null then
          l_ldgr_parms.per_in_ler_id := l_ldgr.per_in_ler_id;
    else
       l_ldgr_parms.per_in_ler_id     := p_per_in_ler_id;
    end if;
    if p_business_group_id is null then
          l_ldgr_parms.business_group_id := l_ldgr.business_group_id;
    else
       l_ldgr_parms.business_group_id := p_business_group_id;
    end if;

    /*
    hr_utility.set_location('rslt:'||to_char(l_ldgr_parms.prtt_enrt_rslt_id), 26);
    hr_utility.set_location('rt:'||to_char(l_ldgr_parms.acty_base_rt_id), 26);
    hr_utility.set_location('pil:'||to_char(l_ldgr_parms.per_in_ler_id), 26);
    hr_utility.set_location('bg:'||to_char(l_ldgr_parms.business_group_id), 26);
    hr_utility.set_location('esd:'||to_char(p_effective_start_date), 26);
    hr_utility.set_location('used:'||to_char(p_used_val), 26);
    */

     -- get the dummy flex credit result and it's programs ref-perd-cd's.
    open c_rslt (c_prtt_enrt_rslt_id => l_ldgr_parms.prtt_enrt_rslt_id,
                 c_effective_date    => p_effective_start_date);
    fetch c_rslt into l_rslt;
    if c_rslt%NOTFOUND or c_rslt%NOTFOUND is null then
       close c_rslt;
       hr_utility.set_location('RESULT INFO NOT FOUND.  LEDGER ID='||
          to_char(p_bnft_prvdd_ldgr_id)||' DATE='||
          to_char(p_effective_start_date)||' RESULT ID='||
          to_char(l_ldgr_parms.prtt_enrt_rslt_id)||' ',28);
    else
      close c_rslt;
      /*
      hr_utility.set_location('person:'||to_char(l_rslt.person_id), 30);
      hr_utility.set_location('ref prd:'||l_rslt.acty_ref_perd_cd, 30);
      hr_utility.set_location('cmcd:'||l_rslt.enrt_info_rt_freq_cd, 30);
      */
      --GEVITY
       ben_element_entry.get_abr_assignment
        (p_person_id       => l_rslt.person_id
        ,p_effective_date  => p_effective_start_date
        ,p_acty_base_rt_id => p_acty_base_rt_id
        ,p_organization_id => l_organization_id
        ,p_payroll_id      => l_payroll_id
        ,p_assignment_id   => l_assignment_id
        );
       --
       open c_abr(p_acty_base_rt_id) ;
         fetch c_abr into l_rate_periodization_rl ;
       close c_abr;
      --END GEVITY
      -- set two of the out parms.
      p_acty_ref_perd_cd  := l_rslt.acty_ref_perd_cd;
      p_cmcd_ref_perd_cd  := l_rslt.enrt_info_rt_freq_cd;

      -- determine cmcd and ann values as needed.
      -- ---------------------------------------------------------------------
      -- Forfeited values
      -- ---------------------------------------------------------------------
      if p_frftd_val is not null then
        hr_utility.set_location('Forfeited Row: '||l_ldgr_parms.prtt_enrt_rslt_id, 32);
        if p_frftd_val = 0 then
           p_ann_frftd_val := 0;
           p_cmcd_frftd_val := 0;
        else
          -- Forfeited values are stored nowhere but the ledger.  We have to call the
          -- calculate routines to find the annual and communicated amounts.  To
          -- do this, an enrt-rt MUST exist for the providded flex credit choice row,
          -- as that's the rate we're going to base the cal on.
          open c_choice_data(c_acty_base_rt_id      => l_ldgr_parms.acty_base_rt_id,
                             c_person_id            => l_rslt.person_id,
                             c_per_in_ler_id        => l_ldgr_parms.per_in_ler_id,
                             c_acty_ref_perd_cd     => l_rslt.acty_ref_perd_cd,
                             c_enrt_info_rt_freq_cd => l_rslt.enrt_info_rt_freq_cd,
                             c_effective_date       => p_effective_start_date);
          fetch c_choice_data into l_choice_data;
          if c_choice_data%NOTFOUND or c_choice_data%NOTFOUND is null then
            close c_choice_data;
            hr_utility.set_location('FORFEITED RATE INFO NOT FOUND.  LEDGER ID='||
              to_char(p_bnft_prvdd_ldgr_id)||' DATE='||
              to_char(p_effective_start_date)||' RESULT ID='||
              to_char(l_ldgr_parms.prtt_enrt_rslt_id),34);
          else
            close c_choice_data;

            -- to convert the rates, we need the payroll id.
           /*
            open c_person(c_person_id      => l_rslt.person_id,
                          c_effective_date => p_effective_start_date);
            fetch c_person into l_person;
            if c_person%NOTFOUND or c_person%NOTFOUND is null then
              close c_person;
              hr_utility.set_location('FORFEITED PERSON INFO NOT FOUND.  LEDGER ID='||
                to_char(p_bnft_prvdd_ldgr_id)||' DATE='||
                to_char(p_effective_start_date)||' RESULT ID='||
                to_char(l_ldgr_parms.prtt_enrt_rslt_id),36);
            else
              close c_person;
           */
            if l_payroll_id IS NOT NULL THEN
            IF l_rate_periodization_rl IS NOT NULL THEN
              --
              --
              ben_distribute_rates.periodize_with_rule
                  (p_formula_id             => l_rate_periodization_rl
                  ,p_effective_date         => p_effective_start_date
                  ,p_assignment_id          => l_assignment_id
                  ,p_convert_from_val       => p_frftd_val
                  ,p_convert_from           => 'DEFINED'
                  ,p_elig_per_elctbl_chc_id => l_choice_data.elig_per_elctbl_chc_id
                  ,p_acty_base_rt_id        => p_acty_base_rt_id
                  ,p_business_group_id      => l_ldgr_parms.business_group_id
                  ,p_enrt_rt_id             => l_choice_data.enrt_rt_id
                  ,p_ann_val                => p_ann_frftd_val
                  ,p_cmcd_val               => p_cmcd_frftd_val
                  ,p_val                    => l_dfnd_dummy
              );
              --
            ELSE
              hr_utility.set_location('Forfeited Row: Calling Distribute Rates', 38);
              p_ann_frftd_val := ben_distribute_rates.period_to_annual(
                          p_amount                 => p_frftd_val,
                          p_enrt_rt_id             => l_choice_data.enrt_rt_id,
                          p_elig_per_elctbl_chc_id => l_choice_data.elig_per_elctbl_chc_id,
                          p_acty_ref_perd_cd       => l_rslt.acty_ref_perd_cd,
                          p_payroll_id             => l_payroll_id,
                          p_business_group_id      => l_ldgr_parms.business_group_id,
                          p_effective_date         => p_effective_start_date,
                          p_lf_evt_ocrd_dt         => l_choice_data.lf_evt_ocrd_dt,
                          p_complete_year_flag     => 'Y');
             --
             -- Bug No 4538786
             -- In this case, where rows are fetched from ecr(l_choice_data), pay periods
	     -- should be fetched from flex shell plan
	     if (l_rslt.enrt_info_rt_freq_cd = 'PPF') then
              open get_flex_shell_rt(l_ldgr_parms.per_in_ler_id,
				     l_rslt.pgm_id);
	      fetch get_flex_shell_rt into l_flex_shell_rt;
	      if get_flex_shell_rt%FOUND then
                close get_flex_shell_rt;
		hr_utility.set_location('frftd l_flex_shell_rt.enrt_rt_id'||l_flex_shell_rt.enrt_rt_id,99);
                hr_utility.set_location('frftd l_flex_shell_rt.element_type_id'||l_flex_shell_rt.element_type_id,99);
                hr_utility.set_location('frftd l_flex_shell_rt.acty_base_rt_id'||l_flex_shell_rt.acty_base_rt_id,99);
                p_cmcd_frftd_val := ben_distribute_rates.annual_to_period(
                          p_amount                 => p_ann_frftd_val,
                          p_enrt_rt_id             => l_flex_shell_rt.enrt_rt_id,
                          p_elig_per_elctbl_chc_id => l_flex_shell_rt.elig_per_elctbl_chc_id,
                          p_acty_ref_perd_cd       => l_rslt.enrt_info_rt_freq_cd,
                          p_payroll_id             => l_payroll_id,
                          p_business_group_id      => l_ldgr_parms.business_group_id,
                          p_effective_date         => p_effective_start_date,
			  p_element_type_id        => l_flex_shell_rt.element_type_id,
                          p_lf_evt_ocrd_dt         => l_flex_shell_rt.lf_evt_ocrd_dt,
                          p_complete_year_flag     => 'Y');
              else
	        close get_flex_shell_rt;  -- Bug 4604560, Close statement top of End If
	      end if;
	     else
              p_cmcd_frftd_val := ben_distribute_rates.annual_to_period(
                          p_amount                 => p_ann_frftd_val,
                          p_enrt_rt_id             => l_choice_data.enrt_rt_id,
                          p_elig_per_elctbl_chc_id => l_choice_data.elig_per_elctbl_chc_id,
                          p_acty_ref_perd_cd       => l_rslt.enrt_info_rt_freq_cd,
                          p_payroll_id             => l_payroll_id,
                          p_business_group_id      => l_ldgr_parms.business_group_id,
                          p_effective_date         => p_effective_start_date,
                          p_lf_evt_ocrd_dt         => l_choice_data.lf_evt_ocrd_dt,
                          p_complete_year_flag     => 'Y');
             end if;
	     -- End Bug No 4538786
            END IF; --GEVITY
            end if;
          end if;
        end if;
      -- ---------------------------------------------------------------------
      -- Used values
      -- ---------------------------------------------------------------------
      elsif p_used_val is not null then
        hr_utility.set_location('Used Row: '||l_ldgr_parms.prtt_enrt_rslt_id, 40);
        -- used val's are complex, must get communicated and annual values from
        -- the prtt-rt-val table.  They must have been put there by the enrollment
        -- process, otherwise we can't get them. If rates are overridden, the user
        -- must have provided the cmcd and ann vals to prtt-rt too.
        if p_used_val = 0 then
           p_ann_used_val := 0;
           p_cmcd_used_val := 0;
        else
          -- try to get the used cmcd and annual values from the prtt-rt-val table
          open c_used_rate(c_acty_base_rt_id      => l_ldgr_parms.acty_base_rt_id,
                           c_person_id            => l_rslt.person_id,
                           c_acty_ref_perd_cd     => l_rslt.acty_ref_perd_cd,
                           c_enrt_info_rt_freq_cd => l_rslt.enrt_info_rt_freq_cd,
                           c_effective_date       => p_effective_start_date,
                           c_used_val             => p_used_val);
          fetch c_used_rate into l_used_rate;
          if c_used_rate%NOTFOUND or c_used_rate%NOTFOUND is null then
            close c_used_rate;
            -- Cannot find the used rate in the prv table.  Calculate it by calling the
            -- convert routines.  The only time (so far) that we need to do this is when
            -- the prtt does a rollover of excess credits from two different benefit
            -- pools into the same plan (creating one result row, but 2 ledger rows).
            open c_choice_data(c_acty_base_rt_id      => l_ldgr_parms.acty_base_rt_id,
                               c_person_id            => l_rslt.person_id,
                               c_per_in_ler_id        => l_ldgr_parms.per_in_ler_id,
                               c_acty_ref_perd_cd     => l_rslt.acty_ref_perd_cd,
                               c_enrt_info_rt_freq_cd => l_rslt.enrt_info_rt_freq_cd,
                               c_effective_date       => p_effective_start_date);
            fetch c_choice_data into l_choice_data;
            if c_choice_data%NOTFOUND or c_choice_data%NOTFOUND is null then
              close c_choice_data;
              hr_utility.set_location('USED CHOICE INFO NOT FOUND.  LEDGER ID='||
                to_char(p_bnft_prvdd_ldgr_id)||' DATE='||
                to_char(p_effective_start_date)||' RESULT ID='||
                to_char(l_ldgr_parms.prtt_enrt_rslt_id),42);
            else
              close c_choice_data;
            /*
              -- to convert the rates, we need the payroll id.
              open c_person(c_person_id      => l_rslt.person_id,
                            c_effective_date => p_effective_start_date);
              fetch c_person into l_person;
              if c_person%NOTFOUND or c_person%NOTFOUND is null then
                close c_person;
                hr_utility.set_location('USED PERSON INFO NOT FOUND.  LEDGER ID='||
                  to_char(p_bnft_prvdd_ldgr_id)||' DATE='||
                  to_char(p_effective_start_date)||' RESULT ID='||
                  to_char(l_ldgr_parms.prtt_enrt_rslt_id),44);
              else
                close c_person;
             */
            if l_payroll_id IS NOT NULL THEN
                hr_utility.set_location('Forfeited Row: Calling Distribute Rates', 46);
            IF l_rate_periodization_rl IS NOT NULL THEN
              --
              --
              ben_distribute_rates.periodize_with_rule
                  (p_formula_id             => l_rate_periodization_rl
                  ,p_effective_date         => p_effective_start_date
                  ,p_assignment_id          => l_assignment_id
                  ,p_convert_from_val       => p_used_val
                  ,p_convert_from           => 'DEFINED'
                  ,p_elig_per_elctbl_chc_id => l_choice_data.elig_per_elctbl_chc_id
                  ,p_acty_base_rt_id        => p_acty_base_rt_id
                  ,p_business_group_id      => l_ldgr_parms.business_group_id
                  ,p_enrt_rt_id             => l_choice_data.enrt_rt_id
                  ,p_ann_val                => p_ann_used_val
                  ,p_cmcd_val               => p_cmcd_used_val
                  ,p_val                    => l_dfnd_dummy
              );
              --
            ELSE
                p_ann_used_val := ben_distribute_rates.period_to_annual(
                          p_amount                 => p_used_val,
                          p_enrt_rt_id             => l_choice_data.enrt_rt_id,
                          p_elig_per_elctbl_chc_id => l_choice_data.elig_per_elctbl_chc_id,
                          p_acty_ref_perd_cd       => l_rslt.acty_ref_perd_cd,
                          p_payroll_id             => l_payroll_id,
                          p_business_group_id      => l_ldgr_parms.business_group_id,
                          p_effective_date         => p_effective_start_date,
                          p_lf_evt_ocrd_dt         => l_choice_data.lf_evt_ocrd_dt,
                          p_complete_year_flag     => 'Y');

                p_cmcd_used_val := ben_distribute_rates.annual_to_period(
                          p_amount                 => p_ann_used_val,
                          p_enrt_rt_id             => l_choice_data.enrt_rt_id,
                          p_elig_per_elctbl_chc_id => l_choice_data.elig_per_elctbl_chc_id,
                          p_acty_ref_perd_cd       => l_rslt.enrt_info_rt_freq_cd,
                          p_payroll_id             => l_payroll_id,
                          p_business_group_id      => l_ldgr_parms.business_group_id,
                          p_effective_date         => p_effective_start_date,
                          p_lf_evt_ocrd_dt         => l_choice_data.lf_evt_ocrd_dt,
                          p_complete_year_flag     => 'Y');
              END IF; --GEVITY
              --
                if p_ann_used_val is null or p_cmcd_used_val is null then
                  hr_utility.set_location('USED RATE ANN OR CMCD NOT FOUND.  LEDGER ID='||
                    to_char(p_bnft_prvdd_ldgr_id)||' DATE='||
                    to_char(p_effective_start_date)||' RESULT ID='||
                    to_char(l_ldgr_parms.prtt_enrt_rslt_id),48);
                end if;
              end if;  -- end if person not found
            end if;    -- end if choice not found
          else
            -- used found in prv, use it.
            close c_used_rate;
            p_ann_used_val := l_used_rate.ann_rt_val;
            p_cmcd_used_val := l_used_rate.cmcd_rt_val;
            /*
            hr_utility.set_location('ann:'||to_char(p_ann_used_val), 50);
            hr_utility.set_location('cmcd:'||to_char(p_cmcd_used_val), 50);
            */
            if p_ann_used_val is null or p_cmcd_used_val is null then
              hr_utility.set_location('USED RATE ANN OR CMCD NOT FOUND.  LEDGER ID='||
                to_char(p_bnft_prvdd_ldgr_id)||' DATE='||
                to_char(p_effective_start_date)||' RESULT ID='||
                to_char(l_ldgr_parms.prtt_enrt_rslt_id),52);
            end if;
          end if;  -- end if used not found in prv
        end if;    -- end if used = 0
      -- ---------------------------------------------------------------------
      -- Provided values
      -- ---------------------------------------------------------------------
      elsif p_prvdd_val is not null then
        hr_utility.set_location('Provided Row: '||l_ldgr_parms.prtt_enrt_rslt_id, 54);
        if p_used_val = 0 then
           p_ann_used_val := 0;
           p_cmcd_used_val := 0;
        else
          -- try to get the provided cmcd and annual values from the prtt-rt-val table
          open c_prvdd_rate(c_prtt_enrt_rslt_id    => l_ldgr_parms.prtt_enrt_rslt_id,
                            c_acty_ref_perd_cd     => l_rslt.acty_ref_perd_cd,
                            c_enrt_info_rt_freq_cd => l_rslt.enrt_info_rt_freq_cd,
                            c_effective_date       => p_effective_start_date,
                            c_prvdd_val            => p_prvdd_val);
          fetch c_prvdd_rate into l_prvdd_rate;
          if c_prvdd_rate%NOTFOUND or c_prvdd_rate%NOTFOUND is null then
            close c_prvdd_rate;
            -- we couldn't find the prvdd in the prtt-rt-val table, probably because
            -- it's a total there, rather than individual provided values.  Look in
            -- enrt-rt table instead.
            open c_prvdd_rate2 (c_acty_base_rt_id      => l_ldgr_parms.acty_base_rt_id,
                                c_person_id            => l_rslt.person_id,
                                c_per_in_ler_id        => l_ldgr_parms.per_in_ler_id,
                                c_acty_ref_perd_cd     => l_rslt.acty_ref_perd_cd,
                                c_enrt_info_rt_freq_cd => l_rslt.enrt_info_rt_freq_cd,
                                c_effective_date       => p_effective_start_date,
                                c_prvdd_val            => p_prvdd_val);
            fetch c_prvdd_rate2 into l_prvdd_rate2;
            if c_prvdd_rate2%NOTFOUND or c_prvdd_rate2%NOTFOUND is null then
              close c_prvdd_rate2;
              hr_utility.set_location('PRVDD RATE INFO NOT FOUND.  LEDGER ID='||
                to_char(p_bnft_prvdd_ldgr_id)||' DATE='||
                to_char(p_effective_start_date)||' RESULT ID='||
                to_char(l_ldgr_parms.prtt_enrt_rslt_id),56);
            else
              close c_prvdd_rate2;
              p_ann_prvdd_val := l_prvdd_rate2.ann_val;
              p_cmcd_prvdd_val := l_prvdd_rate2.cmcd_val;
            end if;
          else
            close c_prvdd_rate;
            p_ann_prvdd_val := l_prvdd_rate.ann_rt_val;
            p_cmcd_prvdd_val := l_prvdd_rate.cmcd_rt_val;
          end if;
        end if;

      -----------------------------------------------------------------------
      -- Cash values
      -- ---------------------------------------------------------------------
      elsif p_cash_recd_val is not null then
        hr_utility.set_location('Cash Row: '||l_ldgr_parms.prtt_enrt_rslt_id, 58);
        if p_cash_recd_val = 0 then
           p_ann_cash_recd_val := 0;
           p_cmcd_cash_recd_val := 0;
        else
          -- Cash values are stored nowhere but the ledger.  We have to call the
          -- calculate routines to find the annual and communicated amounts.  To
          -- do this, an enrt-rt MUST exist for the associated providded flex credit
          -- choice row, as that's the rate we're going to base the calc on.
          open c_choice_data(c_acty_base_rt_id      => l_ldgr_parms.acty_base_rt_id,
                             c_person_id            => l_rslt.person_id,
                             c_per_in_ler_id        => l_ldgr_parms.per_in_ler_id,
                             c_acty_ref_perd_cd     => l_rslt.acty_ref_perd_cd,
                             c_enrt_info_rt_freq_cd => l_rslt.enrt_info_rt_freq_cd,
                             c_effective_date       => p_effective_start_date);
          fetch c_choice_data into l_choice_data;
          if c_choice_data%NOTFOUND or c_choice_data%NOTFOUND is null then
            close c_choice_data;
            hr_utility.set_location('CASH RATE INFO NOT FOUND.  LEDGER ID='||
              to_char(p_bnft_prvdd_ldgr_id)||' DATE='||
              to_char(p_effective_start_date)||' RESULT ID='||
              to_char(l_ldgr_parms.prtt_enrt_rslt_id),60);
          else
            close c_choice_data;
        /*
            -- to convert the rates, we need the payroll id.
            open c_person(c_person_id      => l_rslt.person_id,
                          c_effective_date => p_effective_start_date);
            fetch c_person into l_person;
            if c_person%NOTFOUND or c_person%NOTFOUND is null then
              close c_person;
              hr_utility.set_location('CASH PERSON INFO NOT FOUND.  LEDGER ID='||
                to_char(p_bnft_prvdd_ldgr_id)||' DATE='||
                to_char(p_effective_start_date)||' RESULT ID='||
                to_char(l_ldgr_parms.prtt_enrt_rslt_id),62);
            else
              close c_person;
         */
           if l_payroll_id IS NOT NULL THEN
              hr_utility.set_location('Cash Row: Calling Distribute Rates', 64);
            IF l_rate_periodization_rl IS NOT NULL THEN
              --
              --
              ben_distribute_rates.periodize_with_rule
                  (p_formula_id             => l_rate_periodization_rl
                  ,p_effective_date         => p_effective_start_date
                  ,p_assignment_id          => l_assignment_id
                  ,p_convert_from_val       => p_cash_recd_val
                  ,p_convert_from           => 'DEFINED'
                  ,p_elig_per_elctbl_chc_id => l_choice_data.elig_per_elctbl_chc_id
                  ,p_acty_base_rt_id        => p_acty_base_rt_id
                  ,p_business_group_id      => l_ldgr_parms.business_group_id
                  ,p_enrt_rt_id             => l_choice_data.enrt_rt_id
                  ,p_ann_val                => p_ann_cash_recd_val
                  ,p_cmcd_val               => p_cmcd_cash_recd_val
                  ,p_val                    => l_dfnd_dummy
              );
              --
            ELSE
              p_ann_cash_recd_val := ben_distribute_rates.period_to_annual(
                          p_amount                 => p_cash_recd_val,
                          p_enrt_rt_id             => l_choice_data.enrt_rt_id,
                          p_elig_per_elctbl_chc_id => l_choice_data.elig_per_elctbl_chc_id,
                          p_acty_ref_perd_cd       => l_rslt.acty_ref_perd_cd,
                          p_payroll_id             => l_payroll_id,
                          p_business_group_id      => l_ldgr_parms.business_group_id,
                          p_effective_date         => p_effective_start_date,
                          p_lf_evt_ocrd_dt         => l_choice_data.lf_evt_ocrd_dt,
                          p_complete_year_flag     => 'Y');
             --
             -- Bug No 4538786
             -- In this case, where rows are fetched from ecr(l_choice_data), pay periods
	     -- should be fetched from flex shell plan
           if (l_rslt.enrt_info_rt_freq_cd = 'PPF') then
              open get_flex_shell_rt(l_ldgr_parms.per_in_ler_id,
	                             l_rslt.pgm_id);
	      fetch get_flex_shell_rt into l_flex_shell_rt;
	      if get_flex_shell_rt%FOUND then
                close get_flex_shell_rt;
		hr_utility.set_location('cash l_flex_shell_rt.enrt_rt_id'||l_flex_shell_rt.enrt_rt_id,99);
                hr_utility.set_location('cash l_flex_shell_rt.element_type_id'||l_flex_shell_rt.element_type_id,99);
                hr_utility.set_location('cash l_flex_shell_rt.acty_base_rt_id'||l_flex_shell_rt.acty_base_rt_id,99);
                p_cmcd_cash_recd_val := ben_distribute_rates.annual_to_period(
                          p_amount                 => p_ann_cash_recd_val,
                          p_enrt_rt_id             => l_flex_shell_rt.enrt_rt_id,
                          p_elig_per_elctbl_chc_id => l_flex_shell_rt.elig_per_elctbl_chc_id,
                          p_acty_ref_perd_cd       => l_rslt.enrt_info_rt_freq_cd,
                          p_payroll_id             => l_payroll_id,
                          p_business_group_id      => l_ldgr_parms.business_group_id,
                          p_effective_date         => p_effective_start_date,
			  p_element_type_id        => l_flex_shell_rt.element_type_id,
                          p_lf_evt_ocrd_dt         => l_flex_shell_rt.lf_evt_ocrd_dt,
                          p_complete_year_flag     => 'Y');
	      else
	        --
                close get_flex_shell_rt; -- Bug 4604560, Close statement top of End If
              end if;
            else
              p_cmcd_cash_recd_val := ben_distribute_rates.annual_to_period(
                          p_amount                 => p_ann_cash_recd_val,
                          p_enrt_rt_id             => l_choice_data.enrt_rt_id,
                          p_elig_per_elctbl_chc_id => l_choice_data.elig_per_elctbl_chc_id,
                          p_acty_ref_perd_cd       => l_rslt.enrt_info_rt_freq_cd,
                          p_payroll_id             => l_payroll_id,
                          p_business_group_id      => l_ldgr_parms.business_group_id,
                          p_effective_date         => p_effective_start_date,
                          p_lf_evt_ocrd_dt         => l_choice_data.lf_evt_ocrd_dt,
                          p_complete_year_flag     => 'Y');
            end if;
            -- End Bug No 4538786
            END IF; --GEVITY
            end if;
          end if;
        end if;

      -- ---------------------------------------------------------------------
      -- Rolled Up values
      -- ---------------------------------------------------------------------
      else --if l_ldgr.rld_up_val is not null then
        -- as of delivery of this module, we were not using the rld_up_val field.
        null;
      end if; -- end of 'if' for the various val columns
    end if;  -- end of 'if' for getting result table data

  hr_utility.set_location('Leaving '||l_proc, 999);
end; -- get_cmcd_ann_values
-- ---------------------------------------------------------------------
-- get_dt_mode
-- ---------------------------------------------------------------------
procedure get_dt_mode
          (p_effective_date        in  date,
           p_base_key_value        in  number,
           p_mode                  out nocopy varchar2) is

  l_proc varchar2(72)     := g_package||'get_dt_mode';
  l_correction             boolean := TRUE;
  l_update                 boolean := FALSE;
  l_update_override        boolean := FALSE;
  l_update_change_insert   boolean := FALSE;
  --
begin
  hr_utility.set_location('Entering '||l_proc, 10);
  --
  -- Get the appropriate update mode.
  --
  DT_Api.Find_DT_Upd_Modes(p_effective_date => p_effective_date,
             p_base_table_name       => 'BEN_BNFT_PRVDD_LDGR_F',
             p_base_key_column       => 'BNFT_PRVDD_LDGR_ID',
                    p_base_key_value        => p_base_key_value,
                    p_correction            => l_correction,
                    p_update                => l_update,
                    p_update_override       => l_update_override,
                    p_update_change_insert  => l_update_change_insert);
  --
  if l_update_override or l_update_change_insert then
     p_mode := 'UPDATE_OVERRIDE';
  elsif l_correction then
     p_mode := 'CORRECTION';
  else
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  end if;
  hr_utility.set_location('Leaving '||l_proc, 999);
end;  -- get_dt_mode
end ben_update_ledgers;

/
