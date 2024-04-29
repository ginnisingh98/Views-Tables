--------------------------------------------------------
--  DDL for Package Body BEN_MNG_DPNT_BNF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_MNG_DPNT_BNF" as
/* $Header: benmndep.pkb 120.8.12010000.2 2008/08/05 14:48:43 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------Private Global Definitions-----------------------|
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_mng_dpnt_bnf.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |---------------------------< recycle_dpnt_bnf >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure inherits dependents for the enrollment result
--   from the set of dependents previously covered by this result
--   according to the set of rules.
--   This process also performes required synchronization for outdated
--   dependent and beneficiary rows that were attached to the enrollment
--   result previously.
-- ----------------------------------------------------------------------------
--
procedure recycle_dpnt_bnf
  (p_validate                   in boolean default false
  ,p_new_prtt_enrt_rslt_id      in number
  ,p_new_enrt_rslt_ovn          in out nocopy number
  ,p_old_prtt_enrt_rslt_id      in number
  ,p_new_elig_per_elctbl_chc_id in number
  ,p_person_id                  in number
  ,p_return_to_exist_cvg_flag   in varchar2
  ,p_old_pl_id                  in number
  ,p_new_pl_id                  in number
  ,p_old_oipl_id                in number
  ,p_new_oipl_id                in number
  ,p_old_pl_typ_id              in number
  ,p_new_pl_typ_id              in number
  ,p_pgm_id                     in number
  ,p_ler_id                     in number
  ,p_per_in_ler_id              in number default null
  ,p_dpnt_cvg_strt_dt_cd        in varchar2
  ,p_dpnt_cvg_strt_dt_rl        in number
  ,p_enrt_cvg_strt_dt           in date
  ,p_business_group_id          in number
  ,p_effective_date             in date
  ,p_datetrack_mode             in varchar2
  ,p_multi_row_actn             in boolean default false
  ,p_process_dpnt               in boolean default true
  ,p_process_bnf                in boolean default true)
is
--
  l_proc                        varchar2(72) := g_package||'recycle_dpnt_bnf';
--
  l_effective_start_date        date;
  l_effective_end_date          date;
  l_object_version_number       number(15);
  l_inherit                     boolean  := TRUE;
  l_ttl_rqmt_exist              boolean  := FALSE;
--
  l_num_cov_dpnt_elig_new       number(15);
  l_num_cov_elig_rlshp          number(15);

  l_bnf_effective_start_date    date;
  l_bnf_effective_end_date      date;
  l_bnf_object_version_number   number(9);
  l_pl_bnf_id                   number(15);
--
  l_cvg_strt_dt                 date;
  l_dpnt_elig                   varchar2(1);
--
  l_ttl_max_num                 number(15);
  l_ttl_no_max_flag             varchar2(30);
  l_grp_rlshp_cd                ben_dsgn_rqmt_f.grp_rlshp_cd%type ;
  l_dsgn_rqmt_id                number;
--

  --
  --
  -- total designation requirement (new comp object):
  --
  cursor total_rqmt_c is
  select r.mx_dpnts_alwd_num,
         r.no_mx_num_dfnd_flag,
         r.dsgn_rqmt_id,
         r.grp_rlshp_cd
    from ben_dsgn_rqmt_f r
   where ((r.pl_id = p_new_pl_id)
          or
          (r.oipl_id = p_new_oipl_id)
          or
          (r.opt_id = (select opt_id
                         from ben_oipl_f
                        where oipl_id = p_new_oipl_id
                          and p_effective_date between effective_start_date
                                                   and effective_end_date
                          and business_group_id = p_business_group_id)))
     and r.dsgn_typ_cd = 'DPNT'
     -- and r.grp_rlshp_cd is null
     and r.business_group_id = p_business_group_id
     and p_effective_date between r.effective_start_date
                              and r.effective_end_date;
  --
  --
  -- Cursor to pick the total number of covered dependents from old comp object
  -- eligible for the new comp object
  --
  -- it's just used to check if there are any before continuing.
  --
  cursor c_num_cvd_dpnt is
  select count(old.elig_cvrd_dpnt_id)
    from ben_elig_cvrd_dpnt_f old,
         ben_elig_dpnt new,
         ben_per_in_ler pil,
         ben_per_in_ler pil2
   where old.prtt_enrt_rslt_id = p_old_prtt_enrt_rslt_id
     and old.cvg_strt_dt is not null
     and nvl(old.cvg_thru_dt, hr_api.g_eot) >= nvl(pil2.lf_evt_ocrd_dt - 1,
                                                   hr_api.g_eot)
     and old.business_group_id = p_business_group_id
     and p_effective_date between old.effective_start_date
                              and old.effective_end_date
     and new.elig_per_elctbl_chc_id = p_new_elig_per_elctbl_chc_id
     and new.business_group_id = p_business_group_id
     and old.dpnt_person_id = new.dpnt_person_id
     and pil.per_in_ler_id=old.per_in_ler_id
     and pil.business_group_id=p_business_group_id
     and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
     and pil2.per_in_ler_id=new.per_in_ler_id
     and pil2.business_group_id=p_business_group_id
     and pil2.per_in_ler_stat_cd not in ('VOIDD','BCKDT');
--
  --
  -- get all dependents that can be copied, based upon the fact that there
  -- are no individual rlshp restrictions or we meet the restrictions.
  cursor copy_dpnt_c is
  select old.elig_cvrd_dpnt_id old_dpnt,
         new.elig_dpnt_id new_dpnt
    from ben_elig_cvrd_dpnt_f old,
         ben_elig_dpnt new,
         per_contact_relationships pcr,
         ben_per_in_ler pil,
         ben_per_in_ler pil2
   where old.prtt_enrt_rslt_id = p_old_prtt_enrt_rslt_id
     and old.cvg_strt_dt is not null
     and nvl(old.cvg_thru_dt, hr_api.g_eot) >= nvl(pil2.lf_evt_ocrd_dt - 1,
                                                   hr_api.g_eot)
     and old.business_group_id  = p_business_group_id
     and p_effective_date between old.effective_start_date
                              and old.effective_end_date
     and new.elig_per_elctbl_chc_id = p_new_elig_per_elctbl_chc_id
     and new.business_group_id  = p_business_group_id
     and old.dpnt_person_id = new.dpnt_person_id
     and new.dpnt_person_id = pcr.contact_person_id
     and pcr.person_id = p_person_id
     and pcr.personal_flag = 'Y' -- Bug 3137774
     and
         (pcr.contact_type in
         (select c.rlshp_typ_cd
         from ben_dsgn_rqmt_f p,
              ben_dsgn_rqmt_rlshp_typ c
         where p.dsgn_rqmt_id = c.dsgn_rqmt_id
           and ((p.pl_id = p_new_pl_id)
              or
              (p.oipl_id = p_new_oipl_id)
              or
              (p.opt_id = (select opt_id
                         from ben_oipl_f
                        where oipl_id = p_new_oipl_id
                          and p_effective_date between effective_start_date
                                                   and effective_end_date
                          and business_group_id = p_business_group_id)))
         and p.dsgn_typ_cd = 'DPNT'
         and p.grp_rlshp_cd is not null
         and p.business_group_id  = p_business_group_id
         and p_effective_date between p.effective_start_date
                              and p.effective_end_date
         and nvl(p.mx_dpnts_alwd_num,999) >=
             (select count('s')
             from ben_elig_dpnt new2,
                  per_contact_relationships pcr2
             where new2.elig_per_elctbl_chc_id = p_new_elig_per_elctbl_chc_id
              and new2.business_group_id  = p_business_group_id
              and new2.dpnt_person_id in
                  -- Make sure that the dpnt being counted was covered before
                  (select dpnt_person_id
                     from ben_elig_cvrd_dpnt_f ecd
                    where prtt_enrt_rslt_id = p_old_prtt_enrt_rslt_id
                      and cvg_strt_dt is not null
                      and nvl(cvg_thru_dt, hr_api.g_eot) >=
                          nvl(pil2.lf_evt_ocrd_dt - 1, hr_api.g_eot)
                      and business_group_id  = p_business_group_id
                      and p_effective_date between effective_start_date
                              and effective_end_date)
              and new2.dpnt_person_id = pcr2.contact_person_id
              and pcr2.person_id = p_person_id
              and pcr2.contact_type in
              (select rlshp_typ_cd
               from ben_dsgn_rqmt_rlshp_typ c2
               where c2.dsgn_rqmt_id = p.dsgn_rqmt_id)))
      or not exists
         (select 's'
         from ben_dsgn_rqmt_f p3
         where p3.grp_rlshp_cd is not null
           and ((p3.pl_id = p_new_pl_id)
              or
              (p3.oipl_id = p_new_oipl_id)
              or
              (p3.opt_id = (select opt_id
                         from ben_oipl_f
                        where oipl_id = p_new_oipl_id
                          and p_effective_date between effective_start_date
                                                   and effective_end_date
                          and business_group_id = p_business_group_id)))
         and p3.dsgn_typ_cd = 'DPNT'
         and p3.business_group_id  = p_business_group_id
         and p_effective_date between p3.effective_start_date
                              and p3.effective_end_date))
     and pil.per_in_ler_id=old.per_in_ler_id
     and pil.business_group_id=p_business_group_id
     and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
     and pil2.per_in_ler_id=new.per_in_ler_id
     and pil2.business_group_id=p_business_group_id
     and pil2.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
  ;
  --
  -- for copying dpnts when staying in the same coverage he was in before.
  cursor exist_dpnt_c is
  select ecd.elig_cvrd_dpnt_id,
         ecd.dpnt_person_id,
         ecd.elig_per_elctbl_chc_id,
         ecd.object_version_number
    from ben_elig_cvrd_dpnt_f ecd,
         ben_per_in_ler pil
   where ecd.prtt_enrt_rslt_id = p_new_prtt_enrt_rslt_id
     and ecd.cvg_strt_dt is not null
     and nvl(ecd.cvg_thru_dt, hr_api.g_eot) = hr_api.g_eot
     and ecd.business_group_id = p_business_group_id
     and p_effective_date between ecd.effective_start_date
                              and ecd.effective_end_date
     and pil.per_in_ler_id=ecd.per_in_ler_id
     and pil.business_group_id=p_business_group_id
     and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT');
  --
  cursor old_bnf_c is
  select pbn.*
    from ben_pl_bnf_f pbn,
         ben_per_in_ler pil
   where pbn.prtt_enrt_rslt_id = p_old_prtt_enrt_rslt_id
     and pbn.business_group_id  = p_business_group_id
     and p_effective_date between pbn.effective_start_date
                              and pbn.effective_end_date
     and pil.per_in_ler_id=pbn.per_in_ler_id
     and pil.business_group_id=pbn.business_group_id
     and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
  ;

  cursor c_tot_elig_dpnt
        ( v_dsgn_rqmt_id number ,
          v_grp_rlshp_cd varchar2 ) is
    select count(old.elig_cvrd_dpnt_id)
    from ben_elig_cvrd_dpnt_f old,
         ben_elig_dpnt new,
         ben_per_in_ler pil,
         ben_per_in_ler pil2,
         per_contact_relationships pcr
   where old.prtt_enrt_rslt_id = p_old_prtt_enrt_rslt_id
     and old.cvg_strt_dt is not null
     and nvl(old.cvg_thru_dt, hr_api.g_eot) >= nvl(pil2.lf_evt_ocrd_dt - 1,
                                                   hr_api.g_eot)
     and old.business_group_id = p_business_group_id
     and p_effective_date between old.effective_start_date
                              and old.effective_end_date
     and new.elig_per_elctbl_chc_id = p_new_elig_per_elctbl_chc_id
     and new.business_group_id = p_business_group_id
     and old.dpnt_person_id = new.dpnt_person_id
     and pil.per_in_ler_id=old.per_in_ler_id
     and pil.business_group_id=p_business_group_id
     and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
     and pil2.per_in_ler_id=new.per_in_ler_id
     and pil2.business_group_id=p_business_group_id
     and pil2.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
     and pcr.person_id = p_person_id
     and pcr.contact_person_id =new.dpnt_person_id
     and  p_effective_date between  nvl(pcr.date_start,p_effective_date)
         and  nvl(pcr.date_end,p_effective_date)
         --- validate the no of dpnt for the grp
     and ( pcr.contact_type in
          ( select drt.rlshp_typ_cd
            from  ben_dsgn_rqmt_f bdr ,
            ben_dsgn_rqmt_rlshp_typ drt
            where bdr.dsgn_rqmt_id = v_dsgn_rqmt_id
            and   drt.dsgn_rqmt_id = bdr.dsgn_rqmt_id
            and  ( bdr.grp_rlshp_cd = v_grp_rlshp_cd or
                  (bdr.grp_rlshp_cd is null and v_grp_rlshp_cd is null )
                 )
            and   p_effective_date between bdr.effective_start_date
                  and bdr.effective_end_date
           )
           --- if there is no relation typ defind take all
           or
           not exists
           (select 'x'  from  ben_dsgn_rqmt_rlshp_typ drt
              where drt.dsgn_rqmt_id = v_dsgn_rqmt_id
            )
          ) ;

  /* Bug: 3812994: If the new Option is Waive (or Plan is waived..),
     then we do not copy the beneficiaries to the new result.
  */
    CURSOR c_waive_pl_opt IS
    SELECT NULL
     FROM ben_oipl_f oipl,
          ben_opt_f opt
    WHERE oipl.opt_id = opt.opt_id
      AND oipl.oipl_id = p_new_oipl_id
      AND p_effective_date BETWEEN oipl.effective_start_date AND oipl.effective_end_date
      AND p_effective_date BETWEEN opt.effective_start_date AND opt.effective_end_date
      AND NVL (opt.invk_wv_opt_flag, 'N') = 'Y'
    UNION
    SELECT NULL
      FROM ben_pl_f pln
     WHERE pln.pl_id = p_new_pl_id
       AND p_effective_date BETWEEN pln.effective_start_date AND pln.effective_end_date
       AND NVL (pln.invk_dcln_prtn_pl_flag, 'N') = 'Y';

    l_waive_pl_opt VARCHAR2(1);

--
begin
--
  hr_utility.set_location('Entering:'||l_proc, 5);
  --

  -- If participant is returning to his prior coverage that is
  -- in effect at the time of the p_effective_date then we need to
  -- go back to the old dependents (update existing cvrd dep rows by
  -- updating cvg_thru_dt to null. This code assumes that dsgn requirements
  -- did not change at the time of open enrollment (otherwise the
  -- inheritance logic should still apply).
  --
  if p_return_to_exist_cvg_flag = 'Y' and
     p_process_dpnt then
    hr_utility.set_location('Restore existing cvg', 10);

    FOR dpnt in exist_dpnt_c LOOP
      --
      if dpnt.elig_per_elctbl_chc_id = p_new_elig_per_elctbl_chc_id then
        --
        ben_elig_cvrd_dpnt_api.update_elig_cvrd_dpnt
          (p_validate                => p_validate
          ,p_business_group_id       => p_business_group_id
          ,p_elig_cvrd_dpnt_id       => dpnt.elig_cvrd_dpnt_id
          ,p_effective_start_date    => l_effective_start_date
          ,p_effective_end_date      => l_effective_end_date
          ,p_prtt_enrt_rslt_id       => p_new_prtt_enrt_rslt_id
          ,p_cvg_thru_dt             => null
          ,p_per_in_ler_id           => p_per_in_ler_id
	  ,p_object_version_number   => l_object_version_number
          ,p_effective_date          => p_effective_date
          ,p_datetrack_mode          => p_datetrack_mode
          ,p_request_id              => fnd_global.conc_request_id
          ,p_program_application_id  => fnd_global.prog_appl_id
          ,p_program_id              => fnd_global.conc_program_id
          ,p_program_update_date     => sysdate);
        --
      end if;
      --
    END LOOP;
    --
    -- Bug 1418754
    --
    ben_ELIG_CVRD_DPNT_api.chk_max_num_dpnt_for_pen (
             p_prtt_enrt_rslt_id      => p_new_prtt_enrt_rslt_id,
             p_effective_date         => p_effective_date,
             p_business_group_id      => p_business_group_id);
    --
    /*
    -- same for bnf
    --
    FOR bnf in exist_bnf_c LOOP
      --
      ben_plan_beneficiary_api.update_plan_beneficiary
        (p_validate               => p_validate
        ,p_pl_bnf_id              => bnf.pl_bnf_id
        ,P_DSG_THRU_DT            => null
        ,p_effective_start_date   => l_effective_start_date
        ,p_effective_end_date     => l_effective_end_date
        ,p_object_version_number  => l_object_version_number
        ,p_effective_date         => p_effective_date
         ,p_per_in_ler_id           => p_per_in_ler_id
	 ,p_datetrack_mode         => p_datetrack_mode
        ,p_request_id             => fnd_global.conc_request_id
        ,p_program_application_id => fnd_global.prog_appl_id
        ,p_program_id             => fnd_global.conc_program_id
        ,p_program_update_date    => sysdate);
      --
    END LOOP;
    */
    --
  else
    -- We are not returning the the same comp object, try to inherit.
    --
    if p_process_dpnt then
    -- Check if inheritance for dependents will apply.
    -- Are there those previously covered that are eligible for new the chc_id?
    --
    open c_num_cvd_dpnt;
    fetch c_num_cvd_dpnt into l_num_cov_dpnt_elig_new;
    close c_num_cvd_dpnt;
    --
    -- Is updated result Plan type is the same as an old result Plan type?
    --
    if l_num_cov_dpnt_elig_new = 0 or
       p_old_pl_typ_id <> p_new_pl_typ_id then
      --
      -- no inheritance
      --
      hr_utility.set_location('No inheritance possible:' || l_proc, 15);
      --
      l_inherit := FALSE;
      --
    else
      --
      -- check total max requirements
      -- # 2646284
      --- if conodtion was chnged to loop to validate all the
      --- Relationship groups
      open total_rqmt_c;
      Loop
         fetch total_rqmt_c into l_ttl_max_num, l_ttl_no_max_flag,
               l_dsgn_rqmt_id,l_grp_rlshp_cd ;
         --
         if total_rqmt_c%notfound then
            Exit  ;
         End if ;
         hr_utility.set_location('grp_rlshp_cd ' || l_grp_rlshp_cd, 99 );
         hr_utility.set_location('l_ttl_max_num '|| l_ttl_max_num, 99 );
         --
         --
         l_ttl_rqmt_exist := TRUE;
         --
        open c_tot_elig_dpnt (l_dsgn_rqmt_id,l_grp_rlshp_cd) ;
        fetch c_tot_elig_dpnt into l_num_cov_dpnt_elig_new  ;
        close c_tot_elig_dpnt ;
        hr_utility.set_location(' total eligible ' || l_num_cov_dpnt_elig_new, 99 );

         if l_ttl_no_max_flag = 'N' and
            l_num_cov_dpnt_elig_new > l_ttl_max_num then
            --
            hr_utility.set_location('No inheritance, total max exceeded : ',99 );
            --
            -- no inheritance
            --
            l_inherit := FALSE;
            exit ;
            --
           hr_utility.set_location(' inherit false ',  99 );
         end if;
         --
      end loop;  -- if a total requirement is found.
      --
      close total_rqmt_c;

    end if;
    --
    if l_inherit then

      hr_utility.set_location('Get cvg start dt'||l_proc, 26);
      --
      -- Calculate Dependents Coverage Start Date
      -- dbms_output.put_line('Calculating cvg strt dt');
      --
      ben_determine_date.main
        (p_date_cd                 => p_dpnt_cvg_strt_dt_cd
        ,p_per_in_ler_id           => null
        ,p_person_id               => null
        ,p_pgm_id                  => null
        ,p_pl_id                   => null
        ,p_oipl_id                 => null
        ,p_elig_per_elctbl_chc_id  => p_new_elig_per_elctbl_chc_id
        ,p_business_group_id       => p_business_group_id
        ,p_formula_id              => p_dpnt_cvg_strt_dt_rl
        ,p_effective_date          => p_effective_date
        ,p_returned_date           => l_cvg_strt_dt);
      --
      if l_cvg_strt_dt is null then
        -- error
        --
        fnd_message.set_name('BEN', 'BEN_91657_DPNT_CVG_STRT_DT');
        fnd_message.raise_error;
      end if;
      --
      -- Take the latter of the calculated date and p_enrt_cvg_strt_dt
      --
      if l_cvg_strt_dt > p_enrt_cvg_strt_dt then
        --
        l_cvg_strt_dt := p_enrt_cvg_strt_dt;
        --
      end if;
      --
      hr_utility.set_location('Cvg start dt ='||to_char(l_cvg_strt_dt), 25);

      -- Loop thru dependents previously covered by the result:
      --
      hr_utility.set_location('Loop thru old dependents:'||l_proc, 30);
      -- dbms_output.put_line('Start loop for old dpnts');
      --
      FOR copy_dpnt_rec in copy_dpnt_c LOOP
        --
        hr_utility.set_location('Inherit dependent, rlshp max OK:'||l_proc, 45);
        --
        hook_dpnt
          (p_validate              => FALSE
          ,p_elig_dpnt_id          => copy_dpnt_rec.new_dpnt
          ,p_prtt_enrt_rslt_id     => p_new_prtt_enrt_rslt_id
	  ,p_old_prtt_enrt_rslt_id => p_old_prtt_enrt_rslt_id
          ,p_new_enrt_rslt_ovn     => p_new_enrt_rslt_ovn
          ,p_pgm_id                => p_pgm_id
          ,p_cvg_strt_dt           => l_cvg_strt_dt
          ,p_effective_date        => p_effective_date
          ,p_old_elig_cvrd_dpnt_id => copy_dpnt_rec.old_dpnt
          ,p_per_in_ler_id         => p_per_in_ler_id
          ,p_business_group_id     => p_business_group_id
          ,p_datetrack_mode        => p_datetrack_mode
          ,p_multi_row_actn        => p_multi_row_actn);
         --
      END LOOP;
    end if;  -- if l-inherit
    end if;  -- if p_process_dpnt
    --
    if p_process_bnf then
    --
    -- For now, since beneficiaries are attached to the plan inherit them if
    -- no plan change:
    --
    If p_old_pl_id = p_new_pl_id then
      --
      hr_utility.set_location('Plans the same, copy bnfs', 55);
      --
      /* Bug: 3812994: If the new Option is Waive (or Plan is waived..),
         then we do not copy the beneficiaries to the new result.
      */
      OPEN c_waive_pl_opt;
      FETCH c_waive_pl_opt INTO l_waive_pl_opt;
      IF c_waive_pl_opt%FOUND THEN
         hr_utility.set_location('Waive Opt/Plan. Need not carry bnf ', 60);
         hr_utility.set_location('Exiting'||l_proc, 99);
         return;
      END IF;
      -- End 3812994 changes.
      --
      FOR bnf in old_bnf_c LOOP
        --
        ben_plan_beneficiary_api.create_plan_beneficiary
          (p_validate                => p_validate
          ,p_pl_bnf_id               => l_pl_bnf_id
          ,p_effective_start_date    => l_bnf_effective_start_date
          ,p_effective_end_date      => l_bnf_effective_end_date
          ,p_business_group_id       => p_business_group_id
          ,p_prtt_enrt_rslt_id       => p_new_prtt_enrt_rslt_id
          ,p_bnf_person_id           => bnf.bnf_person_id
          ,p_organization_id         => bnf.organization_id
          ,p_ttee_person_id          => bnf.ttee_person_id
          ,p_prmry_cntngnt_cd        => bnf.prmry_cntngnt_cd
          ,p_pct_dsgd_num            => bnf.pct_dsgd_num
          ,p_amt_dsgd_val            => bnf.amt_dsgd_val
          ,p_amt_dsgd_uom            => bnf.amt_dsgd_uom
          ,p_addl_instrn_txt         => bnf.addl_instrn_txt
	   ,p_per_in_ler_id           => p_per_in_ler_id
          ,p_dsgn_strt_dt            => p_effective_date
           ,p_pbn_attribute_category  => bnf.pbn_attribute_category
          ,p_pbn_attribute1          => bnf.pbn_attribute1
          ,p_pbn_attribute2          => bnf.pbn_attribute2
          ,p_pbn_attribute3          => bnf.pbn_attribute3
          ,p_pbn_attribute4          => bnf.pbn_attribute4
          ,p_pbn_attribute5          => bnf.pbn_attribute5
          ,p_pbn_attribute6          => bnf.pbn_attribute6
          ,p_pbn_attribute7          => bnf.pbn_attribute7
          ,p_pbn_attribute8          => bnf.pbn_attribute8
          ,p_pbn_attribute9          => bnf.pbn_attribute9
          ,p_pbn_attribute10         => bnf.pbn_attribute10
          ,p_pbn_attribute11         => bnf.pbn_attribute11
          ,p_pbn_attribute12         => bnf.pbn_attribute12
          ,p_pbn_attribute13         => bnf.pbn_attribute13
          ,p_pbn_attribute14         => bnf.pbn_attribute14
          ,p_pbn_attribute15         => bnf.pbn_attribute15
          ,p_pbn_attribute16         => bnf.pbn_attribute16
          ,p_pbn_attribute17         => bnf.pbn_attribute17
          ,p_pbn_attribute18         => bnf.pbn_attribute18
          ,p_pbn_attribute19         => bnf.pbn_attribute19
          ,p_pbn_attribute20         => bnf.pbn_attribute20
          ,p_pbn_attribute21         => bnf.pbn_attribute21
          ,p_pbn_attribute22         => bnf.pbn_attribute22
          ,p_pbn_attribute23         => bnf.pbn_attribute23
          ,p_pbn_attribute24         => bnf.pbn_attribute24
          ,p_pbn_attribute25         => bnf.pbn_attribute25
          ,p_pbn_attribute26         => bnf.pbn_attribute26
          ,p_pbn_attribute27         => bnf.pbn_attribute27
          ,p_pbn_attribute28         => bnf.pbn_attribute28
          ,p_pbn_attribute29         => bnf.pbn_attribute29
          ,p_pbn_attribute30         => bnf.pbn_attribute30
          ,p_request_id              => fnd_global.conc_request_id
          ,p_program_application_id  => fnd_global.prog_appl_id
          ,p_program_id              => fnd_global.conc_program_id
          ,p_program_update_date     => sysdate
          ,p_object_version_number   => l_bnf_object_version_number
          ,p_multi_row_actn          => p_multi_row_actn
          ,p_effective_date          => p_effective_date);
        --
      END LOOP;
      --
    End if;
    end if;  -- if p_process_bnf
    --
  end if;
  --
  hr_utility.set_location('Exiting'||l_proc, 99);

--

--
End recycle_dpnt_bnf;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< hook_dpnt >---------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure hook_dpnt
  (p_validate              in     boolean  default false
  ,p_elig_dpnt_id          in     number
  ,p_prtt_enrt_rslt_id     in     number
  ,p_old_prtt_enrt_rslt_id in     number
  ,p_new_enrt_rslt_ovn     in out nocopy number
  ,p_pgm_id                in     number
  ,p_cvg_strt_dt           in     date
  ,p_effective_date        in     date
  ,p_old_elig_cvrd_dpnt_id in     number
  ,p_per_in_ler_id         in     number
  ,p_business_group_id     in     number
  ,p_datetrack_mode        in     varchar2
  ,p_multi_row_actn        in     BOOLEAN default FALSE)
IS
  --
  l_proc                     varchar2(72) := g_package||'hook_dpnt';
  l_cvg_strt_dt              date;
  l_effective_start_date     date;
  l_effective_end_date       date;
  l_object_version_number    number(9);
  l_cvrd_dpnt_ctfn_prvdd_id  number(15);
  l_dsgn_lvl_cd              varchar2(30);
  l_actn_typ_id              number(15);
  l_prtt_enrt_actn_id        number(15);
  l_cmpltd_dt                date;
  l_actn_object_version_number number(15);
  l_actn_effective_start_date  date;
  l_actn_effective_end_date    date;
  l_ctfn_rqd_flag varchar2(30);
  l_pdp_object_version_number  number(9);
  l_elig_cvrd_dpnt_id number(15);
  --
  -- Cursor to fetch the designation level code
  --
  cursor dsgn_lvl_c
  is
  select dpnt_dsgn_lvl_cd
    from ben_pgm_f
   where pgm_id = p_pgm_id
     and business_group_id  = p_business_group_id
     and p_effective_date between effective_start_date
                              and effective_end_date;
  --
  -- Cursor to retrieve dependant ctfn required flags at the pgm level
  --
  cursor c_dpnt_pgm
  is
  select pgm.dpnt_dsgn_no_ctfn_rqd_flag
    from ben_pgm_f pgm
   where pgm.pgm_id = p_pgm_id
     and pgm.business_group_id = p_business_group_id
     and p_effective_date between pgm.effective_start_date
                              and pgm.effective_end_date;
  --
  -- cursor to retrieve dpnts' required-info-flags at the ptip level
  --
  cursor c_dpnt_ptip
  is
  select ptip.dpnt_cvg_no_ctfn_rqd_flag
    from ben_ptip_f ptip
   where ptip.ptip_id = (select ptip_id
                           from ben_prtt_enrt_rslt_f
                          where prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
                            and business_group_id =p_business_group_id
			    and prtt_enrt_rslt_stat_cd is null
                            and p_effective_date between effective_start_date
                                                     and effective_end_date)
     and ptip.business_group_id = p_business_group_id
     and p_effective_date between
         ptip.effective_start_date and ptip.effective_end_date;
  --
  -- Cursor to fetch certifications provided
  --
  cursor dpnt_ctfn_c
  is
  select *
    from ben_cvrd_dpnt_ctfn_prvdd_f
   where elig_cvrd_dpnt_id    = p_old_elig_cvrd_dpnt_id
     and business_group_id = p_business_group_id
     and p_effective_date between effective_start_date
                              and effective_end_date;
--
--Bug# 5572910
 --
  cursor c_dpnt_pea is
    select    pea.prtt_enrt_rslt_id,
	      pea.prtt_enrt_actn_id,
	      pea.actn_typ_id,
	      pea.object_version_number,
	      pea.effective_start_date,
	      pea.effective_end_date
from	      ben_prtt_enrt_actn_f pea,
	      ben_actn_typ eat
 where	pea.elig_cvrd_dpnt_id = p_old_elig_cvrd_dpnt_id
 and	pea.prtt_enrt_rslt_id = p_old_prtt_enrt_rslt_id
 and	pea.cmpltd_dt is not null
 and	eat.type_cd in ('DDCTFN')
 and	eat.actn_typ_id=pea.actn_typ_id
 and    p_effective_date
 between pea.effective_start_date and pea.effective_end_date;  -- bug 6793512
 -- order by pea.prtt_enrt_actn_id,pea.effective_start_date,pea.effective_end_date;
 --
  l_dpnt_pea   c_dpnt_pea%rowtype;
  l_pea_object_version_number  ben_prtt_enrt_actn_f.object_version_number%TYPE;
  l_pea_effective_start_date   ben_prtt_enrt_actn_f.effective_start_date%TYPE;
  l_pea_effective_end_date     ben_prtt_enrt_actn_f.effective_end_date%TYPE;
 --
 cursor c_ccp (ll_prtt_enrt_actn_id number) is
   select    ccp.cvrd_dpnt_ctfn_prvdd_id
	    ,ccp.effective_start_date
	    ,ccp.effective_end_date
	    ,ccp.object_version_number
	    ,ccp.prtt_enrt_actn_id
   from      ben_cvrd_dpnt_ctfn_prvdd_f ccp
   where     ccp.prtt_enrt_actn_id = ll_prtt_enrt_actn_id
     and     ccp.elig_cvrd_dpnt_id = p_old_elig_cvrd_dpnt_id
     and     ccp.business_group_id=p_business_group_id
     and     ccp.dpnt_dsgn_ctfn_recd_dt is not null
     and     p_effective_date between ccp.effective_start_date
		                and   ccp.effective_end_date;
 --
  l_ccp_rec  c_ccp%rowtype;
  l_ccp_object_version_number  ben_cvrd_dpnt_ctfn_prvdd_f.object_version_number%TYPE;
  l_ccp_effective_start_date   ben_cvrd_dpnt_ctfn_prvdd_f.effective_start_date%TYPE;
  l_ccp_effective_end_date     ben_cvrd_dpnt_ctfn_prvdd_f.effective_end_date%TYPE;
  l_ccp_update_flag varchar2(30) := 'N'; --6613891
 --
  -- Bug 6793512
 l_correction                boolean;
 l_update                    boolean;
 l_update_override           boolean;
 l_update_change_insert      boolean;
 l_datetrack_mode            varchar2(20);
 -- Bug 6793512

 --Bug# 5572910
 --

begin
  --
  hr_utility.set_location('Entering'||l_proc, 5);
  --
  --
  -- update cvrd_flag, rslt_id, etc. ...
  --
  hr_utility.set_location('Update dpnt info'||l_proc, 20);
  if p_multi_row_actn then
         hr_utility.set_location('LAMC manage multi row', 20);
  else     hr_utility.set_location('LAMC manage NOT multi row', 20);
  end if;

  ben_ELIG_DPNT_api.process_dependent(
     p_elig_dpnt_id          => p_elig_dpnt_id,
     p_business_group_id     => p_business_group_id,
     p_effective_date        => p_effective_date,
     p_cvg_strt_dt           => p_cvg_strt_dt,
     p_cvg_thru_dt           => hr_api.g_eot,
     p_datetrack_mode        => p_datetrack_mode,
     p_elig_cvrd_dpnt_id     => l_elig_cvrd_dpnt_id,
     p_effective_start_date  => l_effective_start_date,
     p_effective_end_date    => l_effective_end_date,
     p_object_version_number => l_pdp_object_version_number,
     p_multi_row_actn        => p_multi_row_actn);
  --
  -- dbms_output.put_line('Dpnt Info Done');
  --
  --Bug# 5572910
  --
  open c_dpnt_pea;
  --
   fetch c_dpnt_pea into l_dpnt_pea;
  --
    hr_utility.set_location('l_dpnt_pea.prtt_enrt_actn_id'||l_dpnt_pea.prtt_enrt_actn_id,1114);
  --
   if c_dpnt_pea%found then
    l_ccp_update_flag := 'N'; --6613891
    hr_utility.set_location('In c_dpnt_pea. l_ccp_update_flag = '|| l_ccp_update_flag,8085);
    --
     open c_ccp(l_dpnt_pea.prtt_enrt_actn_id);
       loop
         fetch c_ccp into l_ccp_rec;
           exit when c_ccp%notfound;
	   l_ccp_update_flag := 'Y'; --6613891
  --
  	     hr_utility.set_location('l_elig_cvrd_dpnt_id'||l_elig_cvrd_dpnt_id,1114);
  --
  -- Bug 6793512
             --
             dt_api.find_dt_upd_modes
            (p_effective_date       => p_effective_date,
             p_base_table_name      => 'ben_cvrd_dpnt_ctfn_prvdd_f',
             p_base_key_column      => 'cvrd_dpnt_ctfn_prvdd_id',
             p_base_key_value       => l_ccp_rec.cvrd_dpnt_ctfn_prvdd_id,
             p_correction           => l_correction,
             p_update               => l_update,
             p_update_override      => l_update_override,
             p_update_change_insert => l_update_change_insert);
             --
       	     if l_update_override then
               l_datetrack_mode := hr_api.g_update_override;
             elsif l_update then
               l_datetrack_mode := hr_api.g_update;
             else
               l_datetrack_mode := hr_api.g_correction;
             end if;
	     --
	     hr_utility.set_location('rtagarra '||l_datetrack_mode,9653);
  -- Bug 6793512
  		ben_CVRD_DPNT_CTFN_PRVDD_api.update_CVRD_DPNT_CTFN_PRVDD
			 (
			    p_validate		       =>  FALSE
			   ,p_cvrd_dpnt_ctfn_prvdd_id  =>  l_ccp_rec.cvrd_dpnt_ctfn_prvdd_id
			   ,p_effective_start_date     =>  l_ccp_effective_start_date
			   ,p_effective_end_date       =>  l_ccp_effective_end_date
			   ,p_elig_cvrd_dpnt_id        =>  l_elig_cvrd_dpnt_id
			   ,p_prtt_enrt_actn_id        =>  l_ccp_rec.prtt_enrt_actn_id
			   ,p_object_version_number    =>  l_ccp_rec.object_version_number
			   ,p_effective_date           =>  p_effective_date
			   ,p_datetrack_mode           =>  l_datetrack_mode
			 );
--
       end loop;
 --
   close c_ccp;

     --6613891
     hr_utility.set_location('l_ccp_update_flag = ' || l_ccp_update_flag,8085);
     --

     if l_ccp_update_flag = 'Y' then
     --
-- Bug 6793512
       --
       dt_api.find_dt_upd_modes
        (p_effective_date       => p_effective_date,
         p_base_table_name      => 'ben_prtt_enrt_actn_f',
         p_base_key_column      => 'prtt_enrt_actn_id',
         p_base_key_value       => l_dpnt_pea.prtt_enrt_actn_id,
         p_correction           => l_correction,
         p_update               => l_update,
         p_update_override      => l_update_override,
         p_update_change_insert => l_update_change_insert);
       --
       if l_update_override then
         l_datetrack_mode := hr_api.g_update_override;
       elsif l_update then
         l_datetrack_mode := hr_api.g_update;
       else
         l_datetrack_mode := hr_api.g_correction;
       end if;
       --
        hr_utility.set_location('rtagarra '||l_datetrack_mode,9653);
      --
-- Bug 6793512
       ben_PRTT_ENRT_ACTN_api.update_PRTT_ENRT_ACTN
       	(
       	  p_validate                     =>   FALSE
       	 ,p_effective_start_date	 =>   l_pea_effective_start_date
       	 ,p_effective_end_date		 =>   l_pea_effective_end_date
       	 ,p_prtt_enrt_actn_id		 =>   l_dpnt_pea.prtt_enrt_actn_id
       	 ,p_prtt_enrt_rslt_id		 =>   p_prtt_enrt_rslt_id
       	 ,p_elig_cvrd_dpnt_id		 =>   l_elig_cvrd_dpnt_id
       	 ,p_object_version_number        =>   l_dpnt_pea.object_version_number
       	 ,p_effective_date		 =>   p_effective_date
       	 ,p_datetrack_mode               =>   l_datetrack_mode
       	 ,p_rslt_object_version_number   =>   l_pea_object_version_number
       	 );
     end if;
 --
 end if;
 --
close c_dpnt_pea;

--Bug# 5572910

  -- copy certifications at Program or Plan Type in Program levels
  --
  if p_pgm_id is not null then
    --
    open dsgn_lvl_c;
    fetch dsgn_lvl_c into l_dsgn_lvl_cd;
    --
    if dsgn_lvl_c%FOUND then
    --
      if l_dsgn_lvl_cd <> 'PL' then
        --
        if l_dsgn_lvl_cd = 'PGM' then
          --
          open c_dpnt_pgm;
          fetch c_dpnt_pgm into l_ctfn_rqd_flag;
          close c_dpnt_pgm;
          --
        elsif l_dsgn_lvl_cd = 'PTIP' then
          --
          open c_dpnt_ptip;
          fetch c_dpnt_ptip into l_ctfn_rqd_flag;
          close c_dpnt_ptip;
          --
        end if;
        --
        -- Get the actn type id
        --
        l_actn_typ_id := ben_enrollment_action_items.get_actn_typ_id
                           (p_type_cd            => 'DDCTFN'
                           ,p_business_group_id => p_business_group_id);
        --
        ben_enrollment_action_items.get_prtt_enrt_actn_id
             (p_actn_typ_id           => l_actn_typ_id,
              p_prtt_enrt_rslt_id     => p_prtt_enrt_rslt_id,
              p_elig_cvrd_dpnt_id     => l_elig_cvrd_dpnt_id,
              p_effective_date        => p_effective_date,
              p_business_group_id     => p_business_group_id,
              p_prtt_enrt_actn_id     => l_prtt_enrt_actn_id,
              p_cmpltd_dt             => l_cmpltd_dt,
              p_object_version_number => l_actn_object_version_number);
        --
        if l_prtt_enrt_actn_id is null then
          --
          FOR ctfn_rec in dpnt_ctfn_c LOOP
            --
            -- Certification needs to be created, create a action item
            -- as none exists.
            -- Create it ONCE.
            --
            if l_prtt_enrt_actn_id is null then
              --
              ben_enrollment_action_items.write_new_action_item
                (p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
                ,p_rslt_object_version_number => p_new_enrt_rslt_ovn
                ,p_actn_typ_id                => l_actn_typ_id
                ,p_effective_date             => p_effective_date
                ,p_post_rslt_flag             => 'N'
                ,p_business_group_id          => p_business_group_id
                ,p_elig_cvrd_dpnt_id          => l_elig_cvrd_dpnt_id
                ,p_rqd_flag                   => l_ctfn_rqd_flag
                ,p_prtt_enrt_actn_id          => l_prtt_enrt_actn_id
                ,p_object_version_number      => l_actn_object_version_number);
              --
            end if;
            --
            ben_cvrd_dpnt_ctfn_prvdd_api.create_cvrd_dpnt_ctfn_prvdd
              (p_validate                => false
              ,p_cvrd_dpnt_ctfn_prvdd_id => l_cvrd_dpnt_ctfn_prvdd_id
              ,p_effective_start_date    => l_effective_start_date
              ,p_effective_end_date      => l_effective_end_date
              ,p_dpnt_dsgn_ctfn_typ_cd   => ctfn_rec.dpnt_dsgn_ctfn_typ_cd
              ,p_dpnt_dsgn_ctfn_rqd_flag => ctfn_rec.dpnt_dsgn_ctfn_rqd_flag
              ,p_dpnt_dsgn_ctfn_recd_dt  => ctfn_rec.dpnt_dsgn_ctfn_recd_dt
              ,p_elig_cvrd_dpnt_id       => l_elig_cvrd_dpnt_id
              ,p_prtt_enrt_actn_id       => l_prtt_enrt_actn_id
              ,p_business_group_id       => ctfn_rec.business_group_id
              ,p_ccp_attribute_category  => ctfn_rec.ccp_attribute_category
              ,p_ccp_attribute1          => ctfn_rec.ccp_attribute1
              ,p_ccp_attribute2          => ctfn_rec.ccp_attribute2
              ,p_ccp_attribute3          => ctfn_rec.ccp_attribute3
              ,p_ccp_attribute4          => ctfn_rec.ccp_attribute4
              ,p_ccp_attribute5          => ctfn_rec.ccp_attribute5
              ,p_ccp_attribute6          => ctfn_rec.ccp_attribute6
              ,p_ccp_attribute7          => ctfn_rec.ccp_attribute7
              ,p_ccp_attribute8          => ctfn_rec.ccp_attribute8
              ,p_ccp_attribute9          => ctfn_rec.ccp_attribute9
              ,p_ccp_attribute10         => ctfn_rec.ccp_attribute10
              ,p_ccp_attribute11         => ctfn_rec.ccp_attribute11
              ,p_ccp_attribute12         => ctfn_rec.ccp_attribute12
              ,p_ccp_attribute13         => ctfn_rec.ccp_attribute13
              ,p_ccp_attribute14         => ctfn_rec.ccp_attribute14
              ,p_ccp_attribute15         => ctfn_rec.ccp_attribute15
              ,p_ccp_attribute16         => ctfn_rec.ccp_attribute16
              ,p_ccp_attribute17         => ctfn_rec.ccp_attribute17
              ,p_ccp_attribute18         => ctfn_rec.ccp_attribute18
              ,p_ccp_attribute19         => ctfn_rec.ccp_attribute19
              ,p_ccp_attribute20         => ctfn_rec.ccp_attribute20
              ,p_ccp_attribute21         => ctfn_rec.ccp_attribute21
              ,p_ccp_attribute22         => ctfn_rec.ccp_attribute22
              ,p_ccp_attribute23         => ctfn_rec.ccp_attribute23
              ,p_ccp_attribute24         => ctfn_rec.ccp_attribute24
              ,p_ccp_attribute25         => ctfn_rec.ccp_attribute25
              ,p_ccp_attribute26         => ctfn_rec.ccp_attribute26
              ,p_ccp_attribute27         => ctfn_rec.ccp_attribute27
              ,p_ccp_attribute28         => ctfn_rec.ccp_attribute28
              ,p_ccp_attribute29         => ctfn_rec.ccp_attribute29
              ,p_ccp_attribute30         => ctfn_rec.ccp_attribute30
              ,p_object_version_number   => l_object_version_number
              ,p_effective_date          => p_effective_date
              ,p_request_id              => fnd_global.conc_request_id
              ,p_program_application_id  => fnd_global.prog_appl_id
              ,p_program_id              => fnd_global.conc_program_id
              ,p_program_update_date     => sysdate);
            --
          END LOOP;
          --
        end if;
        --
      end if;
      --
    end if;
    --
    close dsgn_lvl_c;
    --
  end if;
  --
  hr_utility.set_location('Exiting'||l_proc, 25);
--
End hook_dpnt;
--
end ben_mng_dpnt_bnf;

/
