--------------------------------------------------------
--  DDL for Package Body BEN_DETERMINE_DPNT_ELIG_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_DETERMINE_DPNT_ELIG_SS" as
/* $Header: bendpels.pkb 120.1.12000000.2 2007/09/12 10:42:50 vborkar noship $ */
/*
+==============================================================================+
|                       Copyright (c) 1998 Oracle Corporation                   |
|                          Redwood Shores, California, USA                      |
|                               All rights reserved.                            |
+==============================================================================+
--
Name
        Dependent Eligibility for Self Service
Purpose
        This package loops through all electable choices for a passed in per_in_ler
and determines if the dependent (person_contact_id is passed in) is eligible.  This
is called from self service enrollment.  This logic is similar to the Dependent
Designation Form logic so changes made here should also be made in the forms library
for the Dependent Designation Form.

History
        Date       Who           Version    What?
        ----       ---           -------    -----
        03 Aug 00  Thayden       115.0      Created.
        12 Feb 02  Shdas         115.1      Added fmly_mmbr_cd_exist proc.
        01 Apr 02  Shdas         115.2      Changed procedure Main(bug fix2049316)
        06 May 02  Shdas         115.3      Added exception.
        29 May 02  Shdas         115.5      Added code to update elig dpnt record
                                            if found eligble.
        31-Oct-02  ashrivas      115.6      bug - 2419139. passing in lf_evt_ocrd_dt for
                                            effective date for creating dpnt and removed the
                                            date clause from the c_elig_dpnt cursor
        31-Oct-02  ashrivas      115.7      Added Whenever OSError..
        04-Dec-02  kmullapu      115.8      Added create_contact_w,update_person_w
                                            NOCOPY changes
        21-Jun-03  hnarayan      115.10     bug 3013964 - passed lf_evt_ocrd_dt as null
        				    to dpnt elig process and create_elig_dpnt
        				    if it is less than effective date.
        				    Also added fnd_msg_pub.initialize
        31-jul-03  hnarayan      115.11     bug 3042223 - changed create_contact_w
                                            to set contact effective_start_date
                                            based on max(PESD, min(RSD, EFF Dt))
	09 Mar 05  vborkar	 115.12	    Bug 4218944 - Added wrapper procedure
	                                    update_contact_w which in turn calls
					    HR_CONTACT_REL_API.update_contact_relationship
					    and treats exceptions in more user friendly
				    manner.
     26-May-06  bmanyam   115.13     5100008 - EGD elig_thru_dt is the
                                     date eligibility is lost. Previously the elig_thru_dt
                                     was updated with PDP cvg_thru_dt.
     12-Sep-07  vborkar   115.14     6279654 - Called ben_env_object.init to initialize
                                     business_group_id and effective_date in the environment record.
*/
--------------------------------------------------------------------------------+
--
g_package varchar2(80) := 'ben_determine_dpnt_elig_ss';


procedure main
  (p_pgm_id                  in number
  ,p_per_in_ler_id           in number
  ,p_person_id               in number
  ,p_contact_person_id       in number
  ,p_contact_relationship_id in number
  ,p_effective_date          in date
  --,p_business_group_id       in number
  )
is
  --
  l_proc                varchar2(80):= g_package||'.main';
--
  l_dependent_eligible_flag  varchar2(30);
  l_cvrd_flag                varchar2(30);
  l_inelig_rsn_cd            varchar2(30);
--
  l_elig_per_id              number;
  l_elig_per_opt_id          number;
  l_elig_dpnt_id             number;
  l_elig_cvrd_dpnt_id        number;
  l_object_version_number    number;
  l_pdp_effective_start_date        date;
  l_pdp_effective_end_date          date;
  l_datetrack_mode           varchar2(30);
  l_correction               boolean;
  l_update                   boolean;
  l_update_override          boolean;
  l_update_change_insert     boolean;
  l_business_group_id        number;
  --

cursor c_elig_per_elctbl_chc is
   select pl_id,
              oipl_id,
              ptip_id,
              business_group_id,
              dpnt_cvg_strt_dt_cd,
              enrt_cvg_strt_dt_cd,
              dpnt_cvg_strt_dt_rl,
              elig_per_elctbl_chc_id
   from ben_elig_per_elctbl_chc epe
   where epe.per_in_ler_id = p_per_in_ler_id
              and epe.pgm_id = p_pgm_id
              and epe.elctbl_flag = 'Y'
              and epe.alws_dpnt_dsgn_flag = 'Y';

cursor c_elig_dpnt (p_dpnt_person_id number,
                    p_elig_per_elctbl_chc_id number,
                    p_effective_date date)  is
   select epe.elig_dpnt_id,
          epe.object_version_number,
          epe.dpnt_inelig_flag
   from ben_elig_dpnt epe
   where epe.dpnt_person_id = p_dpnt_person_id
   and   epe.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id;
  --bug 2419139
   --and   p_effective_date between
  -- nvl(epe.elig_strt_dt,p_effective_date)
   --and nvl(epe.elig_thru_dt,p_effective_date);
--
l_elig_dpnt c_elig_dpnt%rowtype;

cursor   c_per_in_ler is
    select pil.lf_evt_ocrd_dt,
           pil.ler_id
    from   ben_per_in_ler pil,
           ben_ler_f  ler
    where  pil.person_id          = p_person_id
    and    pil.business_group_id  = l_business_group_id
    and    pil.per_in_ler_stat_cd = 'STRTD'
    and    pil.ler_id = ler.ler_id
    and    ler.typ_cd <> 'COMP'
    and    p_effective_date
           between nvl(ler.effective_start_date,p_effective_date)
           and nvl(ler.effective_end_date,p_effective_date)
    and    pil.per_in_ler_id      = p_per_in_ler_id;
--
l_per_in_ler  c_per_in_ler%rowtype;
--
-- bug 3013964
l_lf_evt_ocrd_dt date ;
--
cursor   c_ler_chg_dep(l_level varchar2,l_pl_id number,l_ptip_id number) is
    select chg.cvg_eff_strt_cd,
           chg.cvg_eff_end_cd,
           chg.cvg_eff_strt_rl,
           chg.cvg_eff_end_rl,
           chg.ler_chg_dpnt_cvg_cd,
           chg.ler_chg_dpnt_cvg_rl
    from   ben_ler_chg_dpnt_cvg_f chg
    where  chg.ler_id = l_per_in_ler.ler_id
    and    chg.business_group_id = l_business_group_id
    and    decode(l_level,
                  'PL',l_pl_id,
                  'PTIP',l_ptip_id,
                  'PGM', p_pgm_id) =
           decode(l_level,
                  'PL',chg.pl_id,
                  'PTIP',chg.ptip_id,
                  'PGM', chg.pgm_id)
    and    nvl(l_per_in_ler.lf_evt_ocrd_dt,p_effective_date)
           between nvl(chg.effective_start_date,p_effective_date)
           and     nvl(chg.effective_end_date,p_effective_date);
  --
  l_ler_chg_dep c_ler_chg_dep%rowtype;

  cursor   c_plan(l_pl_id number) is
    select pl.dpnt_dsgn_cd,
           pl.dpnt_cvg_strt_dt_cd,
           pl.dpnt_cvg_strt_dt_rl,
           pl.dpnt_cvg_end_dt_cd,
           pl.dpnt_cvg_end_dt_rl
    from   ben_pl_f pl
    where  pl.pl_id = l_pl_id
    and    pl.business_group_id = l_business_group_id
    and    nvl(l_per_in_ler.lf_evt_ocrd_dt,p_effective_date)
           between nvl(pl.effective_start_date,p_effective_date)
           and     nvl(pl.effective_end_date,p_effective_date);
  --
  l_plan   c_plan%rowtype;
  --
  cursor   c_pgm is
    select pgm.dpnt_dsgn_lvl_cd,
           pgm.dpnt_dsgn_cd,
           pgm.dpnt_cvg_strt_dt_cd,
           pgm.dpnt_cvg_strt_dt_rl,
           pgm.dpnt_cvg_end_dt_cd,
           pgm.dpnt_cvg_end_dt_rl
    from   ben_pgm_f pgm
    where  pgm.pgm_id = p_pgm_id
    and    pgm.business_group_id = l_business_group_id
    and    nvl(l_per_in_ler.lf_evt_ocrd_dt,p_effective_date)
           between nvl(pgm.effective_start_date,p_effective_date)
           and     nvl(pgm.effective_end_date,p_effective_date);
  --
  l_pgm    c_pgm%rowtype;
  l_level  ben_pgm_f.dpnt_dsgn_lvl_cd%type;

  cursor   c_ptip(l_ptip_id number) is
    select ptip.dpnt_dsgn_cd,
           ptip.dpnt_cvg_strt_dt_cd,
           ptip.dpnt_cvg_strt_dt_rl,
           ptip.dpnt_cvg_end_dt_cd,
           ptip.dpnt_cvg_end_dt_rl
    from   ben_ptip_f ptip
    where  ptip.ptip_id = l_ptip_id
    and    ptip.business_group_id = l_business_group_id
    and    nvl(l_per_in_ler.lf_evt_ocrd_dt,p_effective_date)
           between nvl(ptip.effective_start_date,p_effective_date)
           and nvl(ptip.effective_end_date,p_effective_date);
  --
  -- Gets the enrolment information for this plan
  --
  cursor c_plan_enrolment_info(l_pl_id number) is
       select pen.prtt_enrt_rslt_id
       from   ben_prtt_enrt_rslt_f pen
       where  pen.person_id=p_person_id and
              pen.sspndd_flag='N' and
              pen.prtt_enrt_rslt_stat_cd is null and
              pen.effective_end_date = hr_api.g_eot and
              nvl(l_per_in_ler.lf_evt_ocrd_dt,p_effective_date)-1 <=
                pen.enrt_cvg_thru_dt and
              pen.enrt_cvg_strt_dt < pen.effective_end_date
              and pen.pl_id = l_pl_id
              and pen.pgm_id = p_pgm_id;
  --
  -- Gets the enrolment information for this oipl
  --
  cursor c_oipl_enrolment_info(l_oipl_id number)  is
       select pen.prtt_enrt_rslt_id
       from   ben_prtt_enrt_rslt_f pen
       where  pen.person_id=p_person_id and
              pen.sspndd_flag='N' and
              pen.prtt_enrt_rslt_stat_cd is null and
              pen.effective_end_date = hr_api.g_eot and
              nvl(l_per_in_ler.lf_evt_ocrd_dt,p_effective_date)-1 <=
                pen.enrt_cvg_thru_dt and
              pen.enrt_cvg_strt_dt < pen.effective_end_date and
              pen.oipl_id=l_oipl_id
              and pen.pgm_id = p_pgm_id;
  --
  l_prtt_enrt_rslt_id number;

  cursor c_pdp(l_prtt_enrt_rslt_id number) is
    select pdp.object_version_number,
           pdp.elig_cvrd_dpnt_id,
           pdp.effective_start_date,
           pdp.cvg_strt_dt,
           pdp.effective_end_date
    from   ben_elig_cvrd_dpnt_f pdp,
           ben_per_in_ler pil
    where  pdp.prtt_enrt_rslt_id = l_prtt_enrt_rslt_id
    and    pdp.business_group_id  = l_business_group_id
    and    pdp.dpnt_person_id = p_contact_person_id
    and    nvl(l_per_in_ler.lf_evt_ocrd_dt,p_effective_date)
           between pdp.effective_start_date and pdp.effective_end_date
    and    nvl(l_per_in_ler.lf_evt_ocrd_dt, p_effective_date)
           between pdp.cvg_strt_dt and nvl(pdp.cvg_thru_dt,hr_api.g_eot)
    and    pil.per_in_ler_id=pdp.per_in_ler_id
    and    pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT');
  --

  cursor c_bg_id is
    select business_group_id
    from per_all_people_f
    where person_id = p_person_id
    and p_effective_date between effective_start_date and effective_end_date;

  l_pdp    c_pdp%rowtype;
  l_ptip   c_ptip%rowtype;
  l_cvg_end_cd          varchar2(30);
  l_cvg_end_rl          number(15);
  l_cvg_end_dt          date;
  l_pdp_rec_found boolean := false;
  l_look_again boolean := false;
  l_dpnt_cvg_strt_dt    date;
  l_egd_elig_thru_dt     date; -- 5100008
  --
  l_dummy varchar2(1);

begin
  hr_utility.set_location ('Entering '|| l_proc,10);
  --6279654
  if fnd_global.conc_request_id = -1 then
    --
    if ben_env_object.g_global_env_rec.business_group_id is null then
      --
      open c_bg_id;
      fetch c_bg_id into l_business_group_id;
      close c_bg_id;

      hr_utility.set_location ('business_group_id '|| l_business_group_id, 8085);
      hr_utility.set_location ('effective_date '|| p_effective_date, 8085);

      ben_env_object.init(p_business_group_id  => l_business_group_id,
                          p_effective_date     => p_effective_date,
                          p_thread_id          => 1,
                          p_chunk_size         => 1,
                          p_threads            => 1,
                          p_max_errors         => 1,
                          p_benefit_action_id  => null);
      --
    end if;
  end if;
  --end 6279654

  --
  for  epe in c_elig_per_elctbl_chc loop

   l_business_group_id := epe.business_group_id;
   --Need to get the lf_evt_ocrd_dt --bug 2419139
    open c_per_in_ler;
     fetch c_per_in_ler into l_per_in_ler;
    close c_per_in_ler;
  --
  -- bug 3013964
  -- if life event occurred date is less than effective date then we have to
  -- pass null for lf_evt_ocrd_dt instead of l_per_in_ler.lf_evt_ocrd_dt.
  -- Otherwise, dependent elig prcess will check for the contact eligibility
  -- as of the life event date, even when the contact is added as of effective
  -- date. This needs to be avoided.
  -- Also, the same applies for the elig_strt_dt when calling create_elig_dpnt
  -- So set the elig_strt_dt accordingly.
  -- This is now in sync with forms library for Dpnt Designation form.
  --
    l_lf_evt_ocrd_dt := l_per_in_ler.lf_evt_ocrd_dt ;
    --
    if l_lf_evt_ocrd_dt < p_effective_date then
      l_lf_evt_ocrd_dt := null ;
    end if;
  --Always call ben_evaluate_dpnt_elg_profiles.main
  --
  l_dependent_eligible_flag := 'N';
  ben_evaluate_dpnt_elg_profiles.main(
      p_contact_relationship_id => p_contact_relationship_id
      , p_contact_person_id       => p_contact_person_id
      , p_pgm_id                  =>  p_pgm_id
      , p_pl_id                   => epe.pl_id
      , p_ptip_id                 => epe.ptip_id
      , p_oipl_id                 => epe.oipl_id
      , p_business_group_id       => epe.business_group_id
      , p_per_in_ler_id           => p_per_in_ler_id
      , p_effective_date          => p_effective_date
      , p_lf_evt_ocrd_dt          => l_lf_evt_ocrd_dt
      , p_level                   => null
      , p_dependent_eligible_flag => l_dependent_eligible_flag  --out
      , p_dpnt_inelig_rsn_cd      => l_inelig_rsn_cd  --out
    );
    --
   -- 5100008 : EGD ELIG_THRU_DT
  l_egd_elig_thru_dt := ben_evaluate_dpnt_elg_profiles.get_elig_change_dt;
    --
  open c_elig_dpnt(p_contact_person_id,
                   epe.elig_per_elctbl_chc_id,
                   p_effective_date);
  fetch c_elig_dpnt into l_elig_dpnt;
  if c_elig_dpnt%notfound then
  --
 /* if no elig dpnt record but is now found eligible then create elig dpnt record.
    if no elig dpnt record and is still found inelig then do nothing
 */
     if l_dependent_eligible_flag = 'N' then
    --
       null;
    --
    else
      --

        ben_ELIG_DPNT_api.get_elig_per_id(
         p_person_id => p_person_id
        ,p_pgm_id    => p_pgm_id
        ,p_pl_id     => epe.pl_id
        ,p_oipl_id   => epe.oipl_id
        ,p_business_group_id => epe.business_group_id
        ,p_effective_date => p_effective_date
        ,p_elig_per_id    => l_elig_per_id
        ,p_elig_per_opt_id => l_elig_per_opt_id);
        --
        ben_elig_dpnt_api.create_elig_dpnt
         (p_validate => FALSE
         ,p_ELIG_DPNT_ID => l_ELIG_DPNT_ID --out
         ,p_create_dt    => p_effective_date
         ,p_ELIG_CVRD_DPNT_ID => null
         ,p_BUSINESS_GROUP_ID => epe.business_group_id
         ,p_elig_per_elctbl_chc_id => epe.elig_per_elctbl_chc_id
         ,p_DPNT_PERSON_ID => p_contact_person_id
         ,p_ELIG_STRT_DT => nvl(l_lf_evt_ocrd_dt,p_effective_date)
         ,p_ELIG_THRU_DT => hr_api.g_eot
         ,p_elig_per_id  => l_elig_per_id
         ,p_elig_per_opt_id => l_elig_per_opt_id
         ,p_OBJECT_VERSION_NUMBER =>  l_object_version_number
         ,p_ovrdn_flag     => 'N'
         ,p_per_in_ler_id  => p_per_in_ler_id
         ,p_ovrdn_thru_dt  => null
         ,p_effective_date => p_effective_date);
         --
    end if; --flag
--
  elsif c_elig_dpnt%found then
  --
  /* If elig dpnt record exists and is now found eligible after evaluation of elig
     profiles then check dpnt_inelig_flag on the elig dpnt record.If it's Y, that means
     he was ineligible.Since he is now eligible again,update elig dpnt record to make it N.
     Else if the flag is N, it means he was eligible.Since he is still eligible,do nothing.

     If elig dpnt record exists and is now found ineligible after evaluation of elig
     profiles then check if the dependent person is covered--determine coverage end date and
     update elig covered dependent record.If dpnt_inelig_flag on the elig dpnt record is N ,
     which means he was eligible,update the elig dpnt record to set it to Y with the elig rsn cd.

  */
    if l_dependent_eligible_flag = 'Y' then
    --
        if l_elig_dpnt.dpnt_inelig_flag = 'Y' then
        --
           ben_elig_dpnt_api.update_elig_dpnt(
                                     p_elig_dpnt_id          => l_elig_dpnt.elig_dpnt_id
                                    ,p_object_version_number => l_elig_dpnt.object_version_number
                                    ,p_effective_date        => p_effective_date
                                    ,p_elig_thru_dt          => hr_api.g_eot
                                    ,p_dpnt_inelig_flag      => 'N'
                                    ,p_inelg_rsn_cd          => null
                                    );
               --
        else
            null;
        end if;
    --
    else
      --
       -- Determine designation level
       --
       if p_pgm_id is not null then
       --
       -- find the level from the program
       --
          open c_pgm;
          fetch c_pgm into l_pgm;
          close c_pgm;
          l_level := l_pgm.dpnt_dsgn_lvl_cd;
       else
          l_level := 'PL';

       end if;
       --
       -- added following 3 lines for core bug 2189561
       if l_level is null then
          l_level := 'PL';
       end if;

     --  if p_per_in_ler_id is not null then
     --     open c_per_in_ler;
     --     fetch c_per_in_ler into l_per_in_ler;
    --      close c_per_in_ler;
    --   end if;

       -- Determine coverage end date

       open c_ler_chg_dep(l_level,epe.pl_id,epe.ptip_id);
       fetch c_ler_chg_dep into l_ler_chg_dep;
       if c_ler_chg_dep%found then
          l_cvg_end_cd  := l_ler_chg_dep.cvg_eff_end_cd;
          l_cvg_end_rl  := l_ler_chg_dep.cvg_eff_end_rl;
          if l_cvg_end_cd is null and l_cvg_end_rl is null then
             l_look_again := true;
          end if;
          close c_ler_chg_dep;
       else
          close c_ler_chg_dep;
          l_look_again := true;
       end if;
       if (l_look_again) then
          if l_level ='PL' then
             open c_plan(epe.pl_id);
             fetch c_plan into l_plan;
             if c_plan%found then
                l_cvg_end_cd  := l_plan.dpnt_cvg_end_dt_cd;
                l_cvg_end_rl  := l_plan.dpnt_cvg_end_dt_rl;
                close c_plan;
             else
                close c_plan;
                if l_level ='PTIP' then
                   open c_ptip(epe.ptip_id);
                   fetch c_ptip into l_ptip;
                   if c_ptip%found then
                      l_cvg_end_cd  := l_ptip.dpnt_cvg_end_dt_cd;
                      l_cvg_end_rl  := l_ptip.dpnt_cvg_end_dt_rl;
                      close c_ptip;
                   else
                      close c_ptip;
                      if l_level ='PGM' then
                         l_cvg_end_cd  := l_pgm.dpnt_cvg_end_dt_cd;
                         l_cvg_end_rl  := l_pgm.dpnt_cvg_end_dt_rl;
                      end if;
                   end if;
                 end if;  -- ptip
              end if;
           end if;  -- plan
       end if; --dependent change of life event
       -- End determine coverage end date

       if l_cvg_end_cd is not null then
          ben_determine_date.main
               (P_DATE_CD                => l_cvg_end_cd,
                P_BUSINESS_GROUP_ID      => l_business_group_id,
                P_PERSON_ID              => p_person_id,
                P_PGM_ID                 => p_pgm_id,
                P_PL_ID                  => epe.pl_id,
                P_OIPL_ID                => epe.oipl_id,
                P_PER_IN_LER_ID          => p_per_in_ler_id,
                P_ELIG_PER_ELCTBL_CHC_ID => null,
                P_FORMULA_ID             => l_cvg_end_rl,
                P_EFFECTIVE_DATE         => p_effective_date,
                P_LF_EVT_OCRD_DT         => l_per_in_ler.lf_evt_ocrd_dt,
                P_RETURNED_DATE          => l_cvg_end_dt,
                P_PARAM1                 => 'CON_PERSON_ID',
                P_PARAM1_VALUE           => to_char(p_contact_person_id));
        end if;

        -- Get the enrollment result row.
        --
        if (epe.oipl_id is null and epe.pl_id is not null) then
         --
           open c_plan_enrolment_info(epe.pl_id);
           fetch c_plan_enrolment_info into l_prtt_enrt_rslt_id;
           if c_plan_enrolment_info%notfound then
              null;
           end if;
           close c_plan_enrolment_info;
        elsif (epe.oipl_id is not null) then
         --
           open c_oipl_enrolment_info(epe.oipl_id);
           fetch c_oipl_enrolment_info into l_prtt_enrt_rslt_id;
           if c_oipl_enrolment_info%notfound then
              null;
           end if;
           close c_oipl_enrolment_info;
        --
         end if;

        -- Get Dependent Coverage Start Date
        --
        if l_prtt_enrt_rslt_id is not null then
           open c_pdp(l_prtt_enrt_rslt_id);
           fetch c_pdp into l_pdp;
           if c_pdp%found then
              l_pdp_rec_found     := true;
              l_elig_cvrd_dpnt_id := l_pdp.elig_cvrd_dpnt_id;
              l_dpnt_cvg_strt_dt  := l_pdp.cvg_strt_dt;
           else
              l_pdp_rec_found     := false;
              l_elig_cvrd_dpnt_id := null;
              l_dpnt_cvg_strt_dt  := null;
           end if;
           close c_pdp;

           /*if l_cvg_end_dt < l_pdp.cvg_strt_dt then
              l_cvg_end_dt := p_effective_date;
           end if;*/
           --
           -- Update the elig cvrd dependent record
           --
           if l_pdp_rec_found then
              --
              -- Check datetrack mode.
              --
              dt_api.find_dt_upd_modes
                (p_effective_date       => nvl(l_per_in_ler.lf_evt_ocrd_dt,
                                               p_effective_date),
                 p_base_table_name      => 'BEN_ELIG_CVRD_DPNT_F',
                 p_base_key_column      => 'elig_cvrd_dpnt_id',
                 p_base_key_value       => l_elig_cvrd_dpnt_id,
                 p_correction           => l_correction,
                 p_update               => l_update,
                 p_update_override      => l_update_override,
                 p_update_change_insert => l_update_change_insert);
               --
               if l_update_override then
                --
                l_datetrack_mode := hr_api.g_update_override;
                --
              elsif l_update then
                --
                l_datetrack_mode := hr_api.g_update;
                --
              else
                --
                l_datetrack_mode := hr_api.g_correction;
                --
              end if;

              if l_cvg_end_dt is null then
              --
                l_cvg_end_dt := hr_api.g_eot;
              --
              end if;
              --
              ben_elig_cvrd_dpnt_api.update_elig_cvrd_dpnt
                (p_elig_cvrd_dpnt_id      => l_elig_cvrd_dpnt_id
                ,p_effective_start_date   => l_pdp_effective_start_date
                ,p_effective_end_date     => l_pdp_effective_end_date
                ,p_per_in_ler_id          => p_per_in_ler_id
                ,p_cvg_thru_dt            => l_cvg_end_dt
                ,p_object_version_number  => l_pdp.object_version_number
                ,p_effective_date         => nvl(l_per_in_ler.lf_evt_ocrd_dt,
                                                p_effective_date)
                ,p_datetrack_mode         => l_datetrack_mode
                ,p_program_application_id => fnd_global.prog_appl_id
                ,p_program_id             => fnd_global.conc_program_id
                ,p_request_id             => fnd_global.conc_request_id
                ,p_program_update_date    => sysdate
                ,p_business_group_id      => l_business_group_id
                ,p_multi_row_actn         => FALSE
                );
           end if;
        end if; -- l_prtt_enrt_rslt_id not null

        if l_elig_dpnt.dpnt_inelig_flag = 'N' then
        --
           ben_elig_dpnt_api.update_elig_dpnt(
                                     p_elig_dpnt_id          => l_elig_dpnt.elig_dpnt_id
                                    ,p_object_version_number => l_elig_dpnt.object_version_number
                                    ,p_effective_date        => p_effective_date
                                    ,p_elig_thru_dt          => l_egd_elig_thru_dt --l_cvg_end_dt -- 5100008
                                    ,p_dpnt_inelig_flag      => 'Y'
                                    ,p_inelg_rsn_cd          => l_inelig_rsn_cd
                                    );
               --
         end if;

    end if;
  end if; --notfound
  close c_elig_dpnt;
  --
end loop;
--
hr_utility.set_location ('Leaving '|| l_proc,10);

exception
when others then
  fnd_msg_pub.initialize;
  fnd_msg_pub.add;
--
END main;
--
-- -----------------------------------------------------------------------------
-- |-----------------------< fmly_mmbr_cd_exist >----------------------------|
-- -----------------------------------------------------------------------------
--
-- This procedure is called from selfservice to determine if family mmbr cd exists
-- at any level i.e pgm,plip,ptip,pl or oipl level.Also it checks if per_cvrd_cd
-- exists at pl or oipl level.If fmly_mmbr_cd or fmly_mmbr_rl or per_cvrd_cd exists
-- this procedure returns Y.
--
procedure fmly_mmbr_cd_exist
          (p_business_group_id         in         number
          ,p_effective_date            in         date
          ,p_fmly_mmbr_exist           out NOCOPY varchar2
          )
is
  --
  l_proc                  varchar2(100):= g_package||'fmly_mmbr_cd_exist';
  --
  cursor c_pgm is
  select pgm.pgm_id,
  pgm.vrfy_fmly_mmbr_cd,
  pgm.vrfy_fmly_mmbr_rl
  from ben_pgm_f pgm
  where pgm.business_group_id = p_business_group_id
  and pgm.pgm_stat_cd = 'A'
  and p_effective_date
  between pgm.effective_start_date and pgm.effective_end_date;
  --
  cursor c_plip(l_pgm_id number) is
  select plip.plip_id,
         plip.pl_id,
  plip.vrfy_fmly_mmbr_cd,
  plip.vrfy_fmly_mmbr_rl
  from ben_plip_f plip
  where plip.business_group_id = p_business_group_id
  and plip.plip_stat_cd = 'A'
  and plip.pgm_id = l_pgm_id
  and p_effective_date
  between plip.effective_start_date and plip.effective_end_date;
  --
  cursor c_ptip(l_pgm_id number) is
  select ptip.ptip_id,
  ptip.vrfy_fmly_mmbr_cd,
  ptip.vrfy_fmly_mmbr_rl
  from ben_ptip_f ptip
  where ptip.business_group_id = p_business_group_id
  and ptip.ptip_stat_cd = 'A'
  and ptip.pgm_id = l_pgm_id
  and p_effective_date
  between ptip.effective_start_date and ptip.effective_end_date;
  --
  cursor c_pl(l_pl_id number) is
  select pl.pl_id,
  pl.vrfy_fmly_mmbr_cd,
  pl.vrfy_fmly_mmbr_rl,
  pl.per_cvrd_cd
  from ben_pl_f pl
  where pl.business_group_id = p_business_group_id
  and pl.pl_stat_cd = 'A'
  and pl.pl_id = l_pl_id
  and p_effective_date
  between pl.effective_start_date and pl.effective_end_date;
  --
  cursor c_oipl(l_pl_id number) is
  select oipl.oipl_id,
  oipl.vrfy_fmly_mmbr_cd,
  oipl.vrfy_fmly_mmbr_rl,
  oipl.per_cvrd_cd
  from ben_oipl_f oipl
  where oipl.business_group_id = p_business_group_id
  and oipl.oipl_stat_cd = 'A'
  and oipl.pl_id = l_pl_id
  and p_effective_date
  between oipl.effective_start_date and oipl.effective_end_date;
  --
  cursor c_elig_to_prte_pgm(l_pgm_id number) is
  select etpr.elig_to_prte_rsn_id,
         etpr.vrfy_fmly_mmbr_cd,
         etpr.vrfy_fmly_mmbr_rl
  from ben_elig_to_prte_rsn_f etpr
  where etpr.business_group_id = p_business_group_id
  and etpr.pgm_id = l_pgm_id
  and p_effective_date
  between etpr.effective_start_date and etpr.effective_end_date;
 --
  cursor c_elig_to_prte_plip(l_plip_id number) is
  select etpr.elig_to_prte_rsn_id,
         etpr.vrfy_fmly_mmbr_cd,
         etpr.vrfy_fmly_mmbr_rl
  from ben_elig_to_prte_rsn_f etpr
  where etpr.business_group_id = p_business_group_id
  and etpr.plip_id = l_plip_id
  and p_effective_date
  between etpr.effective_start_date and etpr.effective_end_date;
 --
  cursor c_elig_to_prte_pl(l_pl_id number) is
  select etpr.elig_to_prte_rsn_id,
         etpr.vrfy_fmly_mmbr_cd,
         etpr.vrfy_fmly_mmbr_rl
  from ben_elig_to_prte_rsn_f etpr
  where etpr.business_group_id = p_business_group_id
  and etpr.pl_id = l_pl_id
  and p_effective_date
  between etpr.effective_start_date and etpr.effective_end_date;
 --
  cursor c_elig_to_prte_ptip(l_ptip_id number) is
  select etpr.elig_to_prte_rsn_id,
         etpr.vrfy_fmly_mmbr_cd,
         etpr.vrfy_fmly_mmbr_rl
  from ben_elig_to_prte_rsn_f etpr
  where etpr.business_group_id = p_business_group_id
  and etpr.ptip_id = l_ptip_id
  and p_effective_date
  between etpr.effective_start_date and etpr.effective_end_date;
 --
  cursor c_elig_to_prte_oipl(l_oipl_id number) is
  select etpr.elig_to_prte_rsn_id,
         etpr.vrfy_fmly_mmbr_cd,
         etpr.vrfy_fmly_mmbr_rl
  from ben_elig_to_prte_rsn_f etpr
  where etpr.business_group_id = p_business_group_id
  and etpr.oipl_id = l_oipl_id
  and p_effective_date
  between etpr.effective_start_date and etpr.effective_end_date;
 --
  l_elig_to_prte_rsn_id          ben_elig_to_prte_rsn_f.elig_to_prte_rsn_id%TYPE;
  l_vrfy_fmly_mmbr_cd            ben_pgm_f.vrfy_fmly_mmbr_cd%TYPE;
  l_vrfy_fmly_mmbr_rl            ben_pgm_f.vrfy_fmly_mmbr_rl%TYPE;
  l_per_cvrd_cd                  ben_pl_f.per_cvrd_cd%TYPE;
  l_found                        boolean := false;
 --
begin
  --
  hr_utility.set_location('Entering: '||l_proc,10);
  --
  for l_pgm_rec in c_pgm loop
  --
     if l_pgm_rec.vrfy_fmly_mmbr_cd is not null or  --level 1
     l_pgm_rec.vrfy_fmly_mmbr_rl is not null then
        l_found := true;
        exit;
  --
     else                                           --level 1
        open c_elig_to_prte_pgm(l_pgm_rec.pgm_id);
        fetch c_elig_to_prte_pgm into l_elig_to_prte_rsn_id,l_vrfy_fmly_mmbr_cd,l_vrfy_fmly_mmbr_rl;
  --
        if (c_elig_to_prte_pgm%found) and           --level 2
        (l_vrfy_fmly_mmbr_cd is not null or
        l_vrfy_fmly_mmbr_rl is not null) then
           l_found := true;
           close c_elig_to_prte_pgm;
           exit;
        else                                        --level 2
           close c_elig_to_prte_pgm;
           for l_plip_rec in c_plip(l_pgm_rec.pgm_id) loop
  --
              if l_plip_rec.vrfy_fmly_mmbr_cd is not null or  --level 3
              l_plip_rec.vrfy_fmly_mmbr_rl is not null then
                 l_found := true;
                 exit;
              else                                            --level 3
                 open c_elig_to_prte_plip(l_plip_rec.plip_id);
                 fetch c_elig_to_prte_plip into l_elig_to_prte_rsn_id,l_vrfy_fmly_mmbr_cd,l_vrfy_fmly_mmbr_rl;
  --
                 if (c_elig_to_prte_plip%found) and           --level 4
                 (l_vrfy_fmly_mmbr_cd is not null or
                 l_vrfy_fmly_mmbr_rl is not null) then
                    l_found := true;
                    close c_elig_to_prte_plip;
                    exit;
                 else                                         --level 4
                    close c_elig_to_prte_plip;
                    for l_pl_rec in c_pl(l_plip_rec.pl_id) loop
  --
                       if l_pl_rec.vrfy_fmly_mmbr_cd is not null or   --level 5
                       l_pl_rec.vrfy_fmly_mmbr_rl is not null or
                       l_pl_rec.per_cvrd_cd is not null then
                          l_found := true;
                          exit;
                       else                                             --level 5
                          open c_elig_to_prte_pl(l_plip_rec.pl_id);
                          fetch c_elig_to_prte_pl into l_elig_to_prte_rsn_id,l_vrfy_fmly_mmbr_cd,l_vrfy_fmly_mmbr_rl;
                          if (c_elig_to_prte_pl%found) and            --level 6
                          (l_vrfy_fmly_mmbr_cd is not null or
                          l_vrfy_fmly_mmbr_rl is not null) then
                             l_found := true;
                             close c_elig_to_prte_pl;
                             exit;
                          else                                          --level 6
                             close c_elig_to_prte_pl;
                             for l_oipl_rec in c_oipl(l_plip_rec.pl_id) loop
  --
                                if l_oipl_rec.vrfy_fmly_mmbr_cd is not null or     --level 7
                                   l_oipl_rec.vrfy_fmly_mmbr_rl is not null or
                                   l_oipl_rec.per_cvrd_cd is not null then
                                      l_found := true;
                                       exit;
                                 else                                               --level 7
                                    open c_elig_to_prte_oipl(l_oipl_rec.oipl_id);
                                    fetch c_elig_to_prte_oipl into l_elig_to_prte_rsn_id,l_vrfy_fmly_mmbr_cd,l_vrfy_fmly_mmbr_rl;
  --
                                    if (c_elig_to_prte_oipl%found) and              --level 8
                                       (l_vrfy_fmly_mmbr_cd is not null or
                                       l_vrfy_fmly_mmbr_rl is not null) then
                                          l_found := true;
                                          close c_elig_to_prte_oipl;
                                          exit;
                                     else                                             --level 8
                                           close c_elig_to_prte_oipl;
                                     end if;                                          --level 8
                                  end if;                                             --level 7
                               end loop;                                              --oipl end loop
                              if (l_found) then
                                 exit;
                              end if;                                                   --level 6
                            end if;                                                   --level 6
                         end if;                                                      --level 5
                      end loop;                                                       --pl end loop
                      if (l_found) then
                        exit;
                      end if;                                                   --level 6
                   end if;                                                            --level 4
                end if;                                                               --level 3
             end loop;                                                                --plip end loop
             if (l_found) then
               exit;
             end if;

             for l_ptip_rec in c_ptip(l_pgm_rec.pgm_id) loop
  --
                if l_ptip_rec.vrfy_fmly_mmbr_cd is not null or   --level 9
                l_ptip_rec.vrfy_fmly_mmbr_rl is not null then
                   l_found := true;
                   exit;
                else                                             --level 9
                   open c_elig_to_prte_ptip(l_ptip_rec.ptip_id);
                   fetch c_elig_to_prte_ptip into l_elig_to_prte_rsn_id,l_vrfy_fmly_mmbr_cd,l_vrfy_fmly_mmbr_rl;
  --
                   if (c_elig_to_prte_ptip%found) and            --level 10
                   (l_vrfy_fmly_mmbr_cd is not null or
                   l_vrfy_fmly_mmbr_rl is not null) then
                      l_found := true;
                      close c_elig_to_prte_ptip;
                      exit;
                   else                                          --level 10
                      close c_elig_to_prte_ptip;
                   end if;                                       --level 10
                end if;                                          --level 9
             end loop;                                           --ptip end loop
             if (l_found) then
               exit;
             end if;
          end if;                                                --level 2
       end if;                                                   --level 1
  end loop;                                                      --pgm end loop
  hr_utility.set_location('Leaving: '||l_proc,20);
  --
  if (l_found) then
     p_fmly_mmbr_exist := 'Y';
  else
     p_fmly_mmbr_exist := 'N';
  end if;
  --
exception
when others then
  p_fmly_mmbr_exist :=NULL;
  fnd_msg_pub.initialize;
  fnd_msg_pub.add;
--
end fmly_mmbr_cd_exist;
--
-- -----------------------------------------------------------------------------
-- |-------------------------<create_contact_w>--------------------------------|
-- -----------------------------------------------------------------------------
--
-- This is a SS wraper to HR_CONTACT_REL_API.create_contact.
-- Returns 'S' on sucess and 'E' on error
--
procedure create_contact_w
  (p_validate                     in        varchar2    default 'N'
  ,p_start_date                   in        date
  ,p_business_group_id            in        number
  ,p_person_id                    in        number
  ,p_contact_person_id            in        number      default null
  ,p_contact_type                 in        varchar2
  ,p_ctr_comments                 in        varchar2    default null
  ,p_primary_contact_flag         in        varchar2    default 'N'
  ,p_date_start                   in        date        default null
  ,p_start_life_reason_id         in        number      default null
  ,p_date_end                     in        date        default null
  ,p_end_life_reason_id           in        number      default null
  ,p_rltd_per_rsds_w_dsgntr_flag  in        varchar2    default 'N'
  ,p_personal_flag                in        varchar2    default 'N'
  ,p_sequence_number              in        number      default null
  ,p_cont_attribute_category      in        varchar2    default null
  ,p_cont_attribute1              in        varchar2    default null
  ,p_cont_attribute2              in        varchar2    default null
  ,p_cont_attribute3              in        varchar2    default null
  ,p_cont_attribute4              in        varchar2    default null
  ,p_cont_attribute5              in        varchar2    default null
  ,p_cont_attribute6              in        varchar2    default null
  ,p_cont_attribute7              in        varchar2    default null
  ,p_cont_attribute8              in        varchar2    default null
  ,p_cont_attribute9              in        varchar2    default null
  ,p_cont_attribute10             in        varchar2    default null
  ,p_cont_attribute11             in        varchar2    default null
  ,p_cont_attribute12             in        varchar2    default null
  ,p_cont_attribute13             in        varchar2    default null
  ,p_cont_attribute14             in        varchar2    default null
  ,p_cont_attribute15             in        varchar2    default null
  ,p_cont_attribute16             in        varchar2    default null
  ,p_cont_attribute17             in        varchar2    default null
  ,p_cont_attribute18             in        varchar2    default null
  ,p_cont_attribute19             in        varchar2    default null
  ,p_cont_attribute20             in        varchar2    default null
  ,p_cont_information_category    in        varchar2    default null
  ,p_cont_information1            in        varchar2    default null
  ,p_cont_information2            in        varchar2    default null
  ,p_cont_information3            in        varchar2    default null
  ,p_cont_information4            in        varchar2    default null
  ,p_cont_information5            in        varchar2    default null
  ,p_cont_information6            in        varchar2    default null
  ,p_cont_information7            in        varchar2    default null
  ,p_cont_information8            in        varchar2    default null
  ,p_cont_information9            in        varchar2    default null
  ,p_cont_information10           in        varchar2    default null
  ,p_cont_information11           in        varchar2    default null
  ,p_cont_information12           in        varchar2    default null
  ,p_cont_information13           in        varchar2    default null
  ,p_cont_information14           in        varchar2    default null
  ,p_cont_information15           in        varchar2    default null
  ,p_cont_information16           in        varchar2    default null
  ,p_cont_information17           in        varchar2    default null
  ,p_cont_information18           in        varchar2    default null
  ,p_cont_information19           in        varchar2    default null
  ,p_cont_information20           in        varchar2    default null
  ,p_third_party_pay_flag         in        varchar2    default 'N'
  ,p_bondholder_flag              in        varchar2    default 'N'
  ,p_dependent_flag               in        varchar2    default 'N'
  ,p_beneficiary_flag             in        varchar2    default 'N'
  ,p_last_name                    in        varchar2    default null
  ,p_sex                          in        varchar2    default null
  ,p_person_type_id               in        number      default null
  ,p_per_comments                 in        varchar2    default null
  ,p_date_of_birth                in        date        default null
  ,p_email_address                in        varchar2    default null
  ,p_first_name                   in        varchar2    default null
  ,p_known_as                     in        varchar2    default null
  ,p_marital_status               in        varchar2    default null
  ,p_middle_names                 in        varchar2    default null
  ,p_nationality                  in        varchar2    default null
  ,p_national_identifier          in        varchar2    default null
  ,p_previous_last_name           in        varchar2    default null
  ,p_registered_disabled_flag     in        varchar2    default null
  ,p_title                        in        varchar2    default null
  ,p_work_telephone               in        varchar2    default null
  ,p_attribute_category           in        varchar2    default null
  ,p_attribute1                   in        varchar2    default null
  ,p_attribute2                   in        varchar2    default null
  ,p_attribute3                   in        varchar2    default null
  ,p_attribute4                   in        varchar2    default null
  ,p_attribute5                   in        varchar2    default null
  ,p_attribute6                   in        varchar2    default null
  ,p_attribute7                   in        varchar2    default null
  ,p_attribute8                   in        varchar2    default null
  ,p_attribute9                   in        varchar2    default null
  ,p_attribute10                  in        varchar2    default null
  ,p_attribute11                  in        varchar2    default null
  ,p_attribute12                  in        varchar2    default null
  ,p_attribute13                  in        varchar2    default null
  ,p_attribute14                  in        varchar2    default null
  ,p_attribute15                  in        varchar2    default null
  ,p_attribute16                  in        varchar2    default null
  ,p_attribute17                  in        varchar2    default null
  ,p_attribute18                  in        varchar2    default null
  ,p_attribute19                  in        varchar2    default null
  ,p_attribute20                  in        varchar2    default null
  ,p_attribute21                  in        varchar2    default null
  ,p_attribute22                  in        varchar2    default null
  ,p_attribute23                  in        varchar2    default null
  ,p_attribute24                  in        varchar2    default null
  ,p_attribute25                  in        varchar2    default null
  ,p_attribute26                  in        varchar2    default null
  ,p_attribute27                  in        varchar2    default null
  ,p_attribute28                  in        varchar2    default null
  ,p_attribute29                  in        varchar2    default null
  ,p_attribute30                  in        varchar2    default null
  ,p_per_information_category     in        varchar2    default null
  ,p_per_information1             in        varchar2    default null
  ,p_per_information2             in        varchar2    default null
  ,p_per_information3             in        varchar2    default null
  ,p_per_information4             in        varchar2    default null
  ,p_per_information5             in        varchar2    default null
  ,p_per_information6             in        varchar2    default null
  ,p_per_information7             in        varchar2    default null
  ,p_per_information8             in        varchar2    default null
  ,p_per_information9             in        varchar2    default null
  ,p_per_information10            in        varchar2    default null
  ,p_per_information11            in        varchar2    default null
  ,p_per_information12            in        varchar2    default null
  ,p_per_information13            in        varchar2    default null
  ,p_per_information14            in        varchar2    default null
  ,p_per_information15            in        varchar2    default null
  ,p_per_information16            in        varchar2    default null
  ,p_per_information17            in        varchar2    default null
  ,p_per_information18            in        varchar2    default null
  ,p_per_information19            in        varchar2    default null
  ,p_per_information20            in        varchar2    default null
  ,p_per_information21            in        varchar2    default null
  ,p_per_information22            in        varchar2    default null
  ,p_per_information23            in        varchar2    default null
  ,p_per_information24            in        varchar2    default null
  ,p_per_information25            in        varchar2    default null
  ,p_per_information26            in        varchar2    default null
  ,p_per_information27            in        varchar2    default null
  ,p_per_information28            in        varchar2    default null
  ,p_per_information29            in        varchar2    default null
  ,p_per_information30            in        varchar2    default null
  ,p_correspondence_language      in        varchar2    default null
  ,p_honors                       in        varchar2    default null
  ,p_pre_name_adjunct             in        varchar2    default null
  ,p_suffix                       in        varchar2    default null
  ,p_create_mirror_flag           in        varchar2    default 'N'
  ,p_mirror_type                  in        varchar2    default null

  ,p_contact_relationship_id      out       NOCOPY    number
  ,p_ctr_object_version_number    out       NOCOPY    number
  ,p_per_person_id                out       NOCOPY    number
  ,p_per_object_version_number    out       NOCOPY    number
  ,p_per_effective_start_date     out       NOCOPY    date
  ,p_per_effective_end_date       out       NOCOPY    date
  ,p_full_name                    out       NOCOPY    varchar2
  ,p_per_comment_id               out       NOCOPY    number
  ,p_name_combination_warning     out       NOCOPY    varchar2
  ,p_orig_hire_warning            out       NOCOPY    varchar2
  ,p_return_status                out       NOCOPY    varchar2
  ) IS

l_validate                    boolean :=false;
l_name_combination_warning    boolean :=false;
l_orig_hire_warning           boolean :=false;

-- bug 3042223
-- CESD - Contact Person Effective Start Date
-- PESD - Participant's Effective Start Date
-- RSD  - Relationship Start Date
-- EFD  - Effective Date (Session Date)
--
-- CESD = Max (PESD, Min(RSD, EFD))
--
cursor c_per_efsd is
  select per.effective_start_date
  from per_all_people_f per
  where per.person_id = p_person_id
  order by effective_start_date asc ;
--
-- By default, effective date is initally passed on from SS into
--     p_start_date param, and it is overridden here.
-- RSD is passed on as p_date_start param. it is either user-entered or
--     defaulted to effective date.
--
l_start_date               date := p_start_date ;
l_per_effective_start_date date := null ;
BEGIN
  IF(p_validate = 'Y')
   THEN
     l_validate :=true;
   END IF;

  -- bug fix 3042223
  open c_per_efsd;
  fetch c_per_efsd into l_per_effective_start_date ;
  close c_per_efsd;
  --
  if p_date_start < l_start_date then  -- RSD < Eff Date
    l_start_date := p_date_start ;
  end if;
  --
  if l_per_effective_start_date > l_start_date then  -- PESD > Min (RSD, Eff Dt)
    l_start_date := l_per_effective_start_date ;
  end if;
  --
  -- now pass l_start_date instead of p_start_date to HR's api - HR_CONTACT_REL_API.
  -- end fix 3042223

  HR_CONTACT_REL_API.create_contact
    ( p_validate                        => l_validate
    , p_start_date                  	=> l_start_date        -- p_start_date
    , p_business_group_id           	=> p_business_group_id
    , p_person_id                   	=> p_person_id
    , p_contact_person_id           	=> p_contact_person_id
    , p_contact_type                	=> p_contact_type
    , p_ctr_comments                	=> p_ctr_comments
    , p_primary_contact_flag        	=> p_primary_contact_flag
    , p_date_start              	=> p_date_start
    , p_start_life_reason_id        	=> p_start_life_reason_id
    , p_date_end                	=> p_date_end
    , p_end_life_reason_id          	=> p_end_life_reason_id
    , p_rltd_per_rsds_w_dsgntr_flag 	=> p_rltd_per_rsds_w_dsgntr_flag
    , p_personal_flag               	=> p_personal_flag
    , p_sequence_number             	=> p_sequence_number
    , p_cont_attribute_category     	=> p_cont_attribute_category
    , p_cont_attribute1             	=> p_cont_attribute1
    , p_cont_attribute2             	=> p_cont_attribute2
    , p_cont_attribute3             	=> p_cont_attribute3
    , p_cont_attribute4             	=> p_cont_attribute4
    , p_cont_attribute5             	=> p_cont_attribute5
    , p_cont_attribute6             	=> p_cont_attribute6
    , p_cont_attribute7             	=> p_cont_attribute7
    , p_cont_attribute8             	=> p_cont_attribute8
    , p_cont_attribute9             	=> p_cont_attribute9
    , p_cont_attribute10            	=> p_cont_attribute10
    , p_cont_attribute11            	=> p_cont_attribute11
    , p_cont_attribute12            	=> p_cont_attribute12
    , p_cont_attribute13            	=> p_cont_attribute13
    , p_cont_attribute14            	=> p_cont_attribute14
    , p_cont_attribute15            	=> p_cont_attribute15
    , p_cont_attribute16            	=> p_cont_attribute16
    , p_cont_attribute17            	=> p_cont_attribute17
    , p_cont_attribute18            	=> p_cont_attribute18
    , p_cont_attribute19            	=> p_cont_attribute19
    , p_cont_attribute20            	=> p_cont_attribute20
    , p_cont_information_category   	=> p_cont_information_category
    , p_cont_information1           	=> p_cont_information1
    , p_cont_information2           	=> p_cont_information2
    , p_cont_information3           	=> p_cont_information3
    , p_cont_information4           	=> p_cont_information4
    , p_cont_information5           	=> p_cont_information5
    , p_cont_information6           	=> p_cont_information6
    , p_cont_information7           	=> p_cont_information7
    , p_cont_information8           	=> p_cont_information8
    , p_cont_information9           	=> p_cont_information9
    , p_cont_information10          	=> p_cont_information10
    , p_cont_information11          	=> p_cont_information11
    , p_cont_information12          	=> p_cont_information12
    , p_cont_information13          	=> p_cont_information13
    , p_cont_information14          	=> p_cont_information14
    , p_cont_information15          	=> p_cont_information15
    , p_cont_information16          	=> p_cont_information16
    , p_cont_information17          	=> p_cont_information17
    , p_cont_information18          	=> p_cont_information18
    , p_cont_information19          	=> p_cont_information19
    , p_cont_information20          	=> p_cont_information20
    , p_third_party_pay_flag        	=> p_third_party_pay_flag
    , p_bondholder_flag             	=> p_bondholder_flag
    , p_dependent_flag              	=> p_dependent_flag
    , p_beneficiary_flag            	=> p_beneficiary_flag
    , p_last_name                   	=> p_last_name
    , p_sex                         	=> p_sex
    , p_person_type_id              	=> p_person_type_id
    , p_per_comments                	=> p_per_comments
    , p_date_of_birth           	=> p_date_of_birth
    , p_email_address               	=> p_email_address
    , p_first_name                  	=> p_first_name
    , p_known_as                    	=> p_known_as
    , p_marital_status              	=> p_marital_status
    , p_middle_names                	=> p_middle_names
    , p_nationality                 	=> p_nationality
    , p_national_identifier         	=> p_national_identifier
    , p_previous_last_name          	=> p_previous_last_name
    , p_registered_disabled_flag    	=> p_registered_disabled_flag
    , p_title                       	=> p_title
    , p_work_telephone              	=> p_work_telephone
    , p_attribute_category          	=> p_attribute_category
    , p_attribute1                  	=> p_attribute1
    , p_attribute2                  	=> p_attribute2
    , p_attribute3                  	=> p_attribute3
    , p_attribute4                  	=> p_attribute4
    , p_attribute5                  	=> p_attribute5
    , p_attribute6                  	=> p_attribute6
    , p_attribute7                  	=> p_attribute7
    , p_attribute8                  	=> p_attribute8
    , p_attribute9                  	=> p_attribute9
    , p_attribute10                 	=> p_attribute10
    , p_attribute11                 	=> p_attribute11
    , p_attribute12                 	=> p_attribute12
    , p_attribute13                 	=> p_attribute13
    , p_attribute14                 	=> p_attribute14
    , p_attribute15                 	=> p_attribute15
    , p_attribute16                 	=> p_attribute16
    , p_attribute17                 	=> p_attribute17
    , p_attribute18                 	=> p_attribute18
    , p_attribute19                 	=> p_attribute19
    , p_attribute20                 	=> p_attribute20
    , p_attribute21                 	=> p_attribute21
    , p_attribute22                 	=> p_attribute22
    , p_attribute23                 	=> p_attribute23
    , p_attribute24                 	=> p_attribute24
    , p_attribute25                 	=> p_attribute25
    , p_attribute26                 	=> p_attribute26
    , p_attribute27                 	=> p_attribute27
    , p_attribute28                 	=> p_attribute28
    , p_attribute29                 	=> p_attribute29
    , p_attribute30                 	=> p_attribute30
    , p_per_information_category    	=> p_per_information_category
    , p_per_information1            	=> p_per_information1
    , p_per_information2            	=> p_per_information2
    , p_per_information3            	=> p_per_information3
    , p_per_information4            	=> p_per_information4
    , p_per_information5            	=> p_per_information5
    , p_per_information6            	=> p_per_information6
    , p_per_information7            	=> p_per_information7
    , p_per_information8            	=> p_per_information8
    , p_per_information9            	=> p_per_information9
    , p_per_information10           	=> p_per_information10
    , p_per_information11           	=> p_per_information11
    , p_per_information12           	=> p_per_information12
    , p_per_information13           	=> p_per_information13
    , p_per_information14           	=> p_per_information14
    , p_per_information15           	=> p_per_information15
    , p_per_information16           	=> p_per_information16
    , p_per_information17           	=> p_per_information17
    , p_per_information18           	=> p_per_information18
    , p_per_information19           	=> p_per_information19
    , p_per_information20           	=> p_per_information20
    , p_per_information21           	=> p_per_information21
    , p_per_information22           	=> p_per_information22
    , p_per_information23           	=> p_per_information23
    , p_per_information24           	=> p_per_information24
    , p_per_information25           	=> p_per_information25
    , p_per_information26           	=> p_per_information26
    , p_per_information27           	=> p_per_information27
    , p_per_information28           	=> p_per_information28
    , p_per_information29           	=> p_per_information29
    , p_per_information30           	=> p_per_information30
    , p_correspondence_language     	=> p_correspondence_language
    , p_honors                      	=> p_honors
    , p_pre_name_adjunct            	=> p_pre_name_adjunct
    , p_suffix                      	=> p_suffix
    , p_create_mirror_flag          	=> p_create_mirror_flag
    , p_mirror_type                 	=> p_mirror_type

    , p_contact_relationship_id     	=> p_contact_relationship_id
    , p_ctr_object_version_number   	=> p_ctr_object_version_number
    , p_per_person_id               	=> p_per_person_id
    , p_per_object_version_number   	=> p_per_object_version_number
    , p_per_effective_start_date    	=> p_per_effective_start_date
    , p_per_effective_end_date      	=> p_per_effective_end_date
    , p_full_name                   	=> p_full_name
    , p_per_comment_id              	=> p_per_comment_id
    , p_name_combination_warning    	=> l_name_combination_warning
    , p_orig_hire_warning           	=> l_orig_hire_warning
  ) ;

  p_return_status :='S';
EXCEPTION
  --
  when others then
    p_return_status              :='E';
    p_contact_relationship_id    := NULL;
  --p_ctr_object_version_number  := NULL;
    p_per_person_id              := NULL;
  --p_per_object_version_number  := NULL;
    p_per_effective_start_date   := NULL;
    p_per_effective_end_date     := NULL;
    p_full_name                  := NULL;
    p_per_comment_id             := NULL;
    p_name_combination_warning   := NULL;
    p_orig_hire_warning          := NULL;

    fnd_msg_pub.initialize;
    fnd_msg_pub.add;
  --
END create_contact_w;
--
--
-- -----------------------------------------------------------------------------
-- |-------------------------<update_contact_w>--------------------------------|
-- -----------------------------------------------------------------------------
--
-- This is a SS wraper to HR_CONTACT_REL_API.update_contact_relationship.
-- Returns 'S' on sucess and 'E' on error
--
procedure update_contact_w
  (p_validate                          in        varchar2    default 'N'
  ,p_effective_date                    in        date
  ,p_contact_relationship_id           in        number
  ,p_contact_type                      in        varchar2  default hr_api.g_varchar2
  ,p_comments                          in        long      default hr_api.g_varchar2
  ,p_primary_contact_flag              in        varchar2  default hr_api.g_varchar2
  ,p_third_party_pay_flag              in        varchar2  default hr_api.g_varchar2
  ,p_bondholder_flag                   in        varchar2  default hr_api.g_varchar2
  ,p_date_start                        in        date      default hr_api.g_date
  ,p_start_life_reason_id              in        number    default hr_api.g_number
  ,p_date_end                          in        date      default hr_api.g_date
  ,p_end_life_reason_id                in        number    default hr_api.g_number
  ,p_rltd_per_rsds_w_dsgntr_flag       in        varchar2  default hr_api.g_varchar2
  ,p_personal_flag                     in        varchar2  default hr_api.g_varchar2
  ,p_sequence_number                   in        number    default hr_api.g_number
  ,p_dependent_flag                    in        varchar2  default hr_api.g_varchar2
  ,p_beneficiary_flag                  in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute_category           in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute1                   in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute2                   in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute3                   in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute4                   in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute5                   in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute6                   in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute7                   in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute8                   in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute9                   in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute10                  in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute11                  in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute12                  in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute13                  in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute14                  in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute15                  in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute16                  in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute17                  in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute18                  in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute19                  in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute20                  in        varchar2  default hr_api.g_varchar2
  ,p_cont_information_category         in        varchar2  default hr_api.g_varchar2
  ,p_cont_information1                 in        varchar2  default hr_api.g_varchar2
  ,p_cont_information2                 in        varchar2  default hr_api.g_varchar2
  ,p_cont_information3                 in        varchar2  default hr_api.g_varchar2
  ,p_cont_information4                 in        varchar2  default hr_api.g_varchar2
  ,p_cont_information5                 in        varchar2  default hr_api.g_varchar2
  ,p_cont_information6                 in        varchar2  default hr_api.g_varchar2
  ,p_cont_information7                 in        varchar2  default hr_api.g_varchar2
  ,p_cont_information8                 in        varchar2  default hr_api.g_varchar2
  ,p_cont_information9                 in        varchar2  default hr_api.g_varchar2
  ,p_cont_information10                in        varchar2  default hr_api.g_varchar2
  ,p_cont_information11                in        varchar2  default hr_api.g_varchar2
  ,p_cont_information12                in        varchar2  default hr_api.g_varchar2
  ,p_cont_information13                in        varchar2  default hr_api.g_varchar2
  ,p_cont_information14                in        varchar2  default hr_api.g_varchar2
  ,p_cont_information15                in        varchar2  default hr_api.g_varchar2
  ,p_cont_information16                in        varchar2  default hr_api.g_varchar2
  ,p_cont_information17                in        varchar2  default hr_api.g_varchar2
  ,p_cont_information18                in        varchar2  default hr_api.g_varchar2
  ,p_cont_information19                in        varchar2  default hr_api.g_varchar2
  ,p_cont_information20                in        varchar2  default hr_api.g_varchar2
  ,p_object_version_number             in out nocopy    number
  ,p_return_status                     out    nocopy    varchar2
  ) IS

l_validate                    boolean :=false;
BEGIN
  IF (p_validate = 'Y') THEN
    l_validate :=true;
  END IF;

  HR_CONTACT_REL_API.update_contact_relationship
    ( p_validate                          =>        l_validate
     ,p_effective_date                    =>        p_effective_date
     ,p_contact_relationship_id           =>        p_contact_relationship_id
     ,p_contact_type                      =>        p_contact_type
     ,p_comments                          =>        p_comments
     ,p_primary_contact_flag              =>        p_primary_contact_flag
     ,p_third_party_pay_flag              =>        p_third_party_pay_flag
     ,p_bondholder_flag                   =>        p_bondholder_flag
     ,p_date_start                        =>        p_date_start
     ,p_start_life_reason_id              =>        p_start_life_reason_id
     ,p_date_end                          =>        p_date_end
     ,p_end_life_reason_id                =>        p_end_life_reason_id
     ,p_rltd_per_rsds_w_dsgntr_flag       =>        p_rltd_per_rsds_w_dsgntr_flag
     ,p_personal_flag                     =>        p_personal_flag
     ,p_sequence_number                   =>        p_sequence_number
     ,p_dependent_flag                    =>        p_dependent_flag
     ,p_beneficiary_flag                  =>        p_beneficiary_flag
     ,p_cont_attribute_category           =>        p_cont_attribute_category
     ,p_cont_attribute1                   =>        p_cont_attribute1
     ,p_cont_attribute2                   =>        p_cont_attribute2
     ,p_cont_attribute3                   =>        p_cont_attribute3
     ,p_cont_attribute4                   =>        p_cont_attribute4
     ,p_cont_attribute5                   =>        p_cont_attribute5
     ,p_cont_attribute6                   =>        p_cont_attribute6
     ,p_cont_attribute7                   =>        p_cont_attribute7
     ,p_cont_attribute8                   =>        p_cont_attribute8
     ,p_cont_attribute9                   =>        p_cont_attribute9
     ,p_cont_attribute10                  =>        p_cont_attribute10
     ,p_cont_attribute11                  =>        p_cont_attribute11
     ,p_cont_attribute12                  =>        p_cont_attribute12
     ,p_cont_attribute13                  =>        p_cont_attribute13
     ,p_cont_attribute14                  =>        p_cont_attribute14
     ,p_cont_attribute15                  =>        p_cont_attribute15
     ,p_cont_attribute16                  =>        p_cont_attribute16
     ,p_cont_attribute17                  =>        p_cont_attribute17
     ,p_cont_attribute18                  =>        p_cont_attribute18
     ,p_cont_attribute19                  =>        p_cont_attribute19
     ,p_cont_attribute20                  =>        p_cont_attribute20
     ,p_cont_information_category         =>        p_cont_information_category
     ,p_cont_information1                 =>        p_cont_information1
     ,p_cont_information2                 =>        p_cont_information2
     ,p_cont_information3                 =>        p_cont_information3
     ,p_cont_information4                 =>        p_cont_information4
     ,p_cont_information5                 =>        p_cont_information5
     ,p_cont_information6                 =>        p_cont_information6
     ,p_cont_information7                 =>        p_cont_information7
     ,p_cont_information8                 =>        p_cont_information8
     ,p_cont_information9                 =>        p_cont_information9
     ,p_cont_information10                =>        p_cont_information10
     ,p_cont_information11                =>        p_cont_information11
     ,p_cont_information12                =>        p_cont_information12
     ,p_cont_information13                =>        p_cont_information13
     ,p_cont_information14                =>        p_cont_information14
     ,p_cont_information15                =>        p_cont_information15
     ,p_cont_information16                =>        p_cont_information16
     ,p_cont_information17                =>        p_cont_information17
     ,p_cont_information18                =>        p_cont_information18
     ,p_cont_information19                =>        p_cont_information19
     ,p_cont_information20                =>        p_cont_information20
     ,p_object_version_number             =>        p_object_version_number
    ) ;

  p_return_status :='S';
EXCEPTION
  --
  when others then
    p_return_status              :='E';

    fnd_msg_pub.initialize;
    fnd_msg_pub.add;
  --
END update_contact_w;
--
-- -----------------------------------------------------------------------------
-- |--------------------------<update_person_w>--------------------------------|
-- -----------------------------------------------------------------------------
--
-- This is a SS wraper to HR_PERSON_API.update_person.
-- Returns 'S' on sucess and 'E' on error
--
procedure update_person_w
  (p_validate                     in      varchar2   default 'N'
  ,p_effective_date               in      date
  ,p_datetrack_update_mode        in      varchar2
  ,p_person_id                    in      number
  ,p_object_version_number        in out  NOCOPY    number
  ,p_person_type_id               in      number   default hr_api.g_number
  ,p_last_name                    in      varchar2 default hr_api.g_varchar2
  ,p_applicant_number             in      varchar2 default hr_api.g_varchar2
  ,p_comments                     in      varchar2 default hr_api.g_varchar2
  ,p_date_employee_data_verified  in      date     default hr_api.g_date
  ,p_date_of_birth                in      date     default hr_api.g_date
  ,p_email_address                in      varchar2 default hr_api.g_varchar2
  ,p_employee_number              in out  NOCOPY   varchar2
  ,p_expense_check_send_to_addres in      varchar2 default hr_api.g_varchar2
  ,p_first_name                   in      varchar2 default hr_api.g_varchar2
  ,p_known_as                     in      varchar2 default hr_api.g_varchar2
  ,p_marital_status               in      varchar2 default hr_api.g_varchar2
  ,p_middle_names                 in      varchar2 default hr_api.g_varchar2
  ,p_nationality                  in      varchar2 default hr_api.g_varchar2
  ,p_national_identifier          in      varchar2 default hr_api.g_varchar2
  ,p_previous_last_name           in      varchar2 default hr_api.g_varchar2
  ,p_registered_disabled_flag     in      varchar2 default hr_api.g_varchar2
  ,p_sex                          in      varchar2 default hr_api.g_varchar2
  ,p_title                        in      varchar2 default hr_api.g_varchar2
  ,p_vendor_id                    in      number   default hr_api.g_number
  ,p_work_telephone               in      varchar2 default hr_api.g_varchar2
  ,p_attribute_category           in      varchar2 default hr_api.g_varchar2
  ,p_attribute1                   in      varchar2 default hr_api.g_varchar2
  ,p_attribute2                   in      varchar2 default hr_api.g_varchar2
  ,p_attribute3                   in      varchar2 default hr_api.g_varchar2
  ,p_attribute4                   in      varchar2 default hr_api.g_varchar2
  ,p_attribute5                   in      varchar2 default hr_api.g_varchar2
  ,p_attribute6                   in      varchar2 default hr_api.g_varchar2
  ,p_attribute7                   in      varchar2 default hr_api.g_varchar2
  ,p_attribute8                   in      varchar2 default hr_api.g_varchar2
  ,p_attribute9                   in      varchar2 default hr_api.g_varchar2
  ,p_attribute10                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute11                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute12                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute13                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute14                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute15                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute16                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute17                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute18                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute19                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute20                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute21                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute22                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute23                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute24                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute25                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute26                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute27                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute28                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute29                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute30                  in      varchar2 default hr_api.g_varchar2
  ,p_per_information_category     in      varchar2 default hr_api.g_varchar2
  ,p_per_information1             in      varchar2 default hr_api.g_varchar2
  ,p_per_information2             in      varchar2 default hr_api.g_varchar2
  ,p_per_information3             in      varchar2 default hr_api.g_varchar2
  ,p_per_information4             in      varchar2 default hr_api.g_varchar2
  ,p_per_information5             in      varchar2 default hr_api.g_varchar2
  ,p_per_information6             in      varchar2 default hr_api.g_varchar2
  ,p_per_information7             in      varchar2 default hr_api.g_varchar2
  ,p_per_information8             in      varchar2 default hr_api.g_varchar2
  ,p_per_information9             in      varchar2 default hr_api.g_varchar2
  ,p_per_information10            in      varchar2 default hr_api.g_varchar2
  ,p_per_information11            in      varchar2 default hr_api.g_varchar2
  ,p_per_information12            in      varchar2 default hr_api.g_varchar2
  ,p_per_information13            in      varchar2 default hr_api.g_varchar2
  ,p_per_information14            in      varchar2 default hr_api.g_varchar2
  ,p_per_information15            in      varchar2 default hr_api.g_varchar2
  ,p_per_information16            in      varchar2 default hr_api.g_varchar2
  ,p_per_information17            in      varchar2 default hr_api.g_varchar2
  ,p_per_information18            in      varchar2 default hr_api.g_varchar2
  ,p_per_information19            in      varchar2 default hr_api.g_varchar2
  ,p_per_information20            in      varchar2 default hr_api.g_varchar2
  ,p_per_information21            in      varchar2 default hr_api.g_varchar2
  ,p_per_information22            in      varchar2 default hr_api.g_varchar2
  ,p_per_information23            in      varchar2 default hr_api.g_varchar2
  ,p_per_information24            in      varchar2 default hr_api.g_varchar2
  ,p_per_information25            in      varchar2 default hr_api.g_varchar2
  ,p_per_information26            in      varchar2 default hr_api.g_varchar2
  ,p_per_information27            in      varchar2 default hr_api.g_varchar2
  ,p_per_information28            in      varchar2 default hr_api.g_varchar2
  ,p_per_information29            in      varchar2 default hr_api.g_varchar2
  ,p_per_information30            in      varchar2 default hr_api.g_varchar2
  ,p_date_of_death                in      date     default hr_api.g_date
  ,p_background_check_status      in      varchar2 default hr_api.g_varchar2
  ,p_background_date_check        in      date     default hr_api.g_date
  ,p_blood_type                   in      varchar2 default hr_api.g_varchar2
  ,p_correspondence_language      in      varchar2 default hr_api.g_varchar2
  ,p_fast_path_employee           in      varchar2 default hr_api.g_varchar2
  ,p_fte_capacity                 in      number   default hr_api.g_number
  ,p_hold_applicant_date_until    in      date     default hr_api.g_date
  ,p_honors                       in      varchar2 default hr_api.g_varchar2
  ,p_internal_location            in      varchar2 default hr_api.g_varchar2
  ,p_last_medical_test_by         in      varchar2 default hr_api.g_varchar2
  ,p_last_medical_test_date       in      date     default hr_api.g_date
  ,p_mailstop                     in      varchar2 default hr_api.g_varchar2
  ,p_office_number                in      varchar2 default hr_api.g_varchar2
  ,p_on_military_service          in      varchar2 default hr_api.g_varchar2
  ,p_pre_name_adjunct             in      varchar2 default hr_api.g_varchar2
  ,p_projected_start_date         in      date     default hr_api.g_date
  ,p_rehire_authorizor            in      varchar2 default hr_api.g_varchar2
  ,p_rehire_recommendation        in      varchar2 default hr_api.g_varchar2
  ,p_resume_exists                in      varchar2 default hr_api.g_varchar2
  ,p_resume_last_updated          in      date     default hr_api.g_date
  ,p_second_passport_exists       in      varchar2 default hr_api.g_varchar2
  ,p_student_status               in      varchar2 default hr_api.g_varchar2
  ,p_work_schedule                in      varchar2 default hr_api.g_varchar2
  ,p_rehire_reason                in      varchar2 default hr_api.g_varchar2
  ,p_suffix                       in      varchar2 default hr_api.g_varchar2
  ,p_benefit_group_id             in      number   default hr_api.g_number
  ,p_receipt_of_death_cert_date   in      date     default hr_api.g_date
  ,p_coord_ben_med_pln_no         in      varchar2 default hr_api.g_varchar2
  ,p_coord_ben_no_cvg_flag        in      varchar2 default hr_api.g_varchar2
  ,p_coord_ben_med_ext_er         in      varchar2 default hr_api.g_varchar2
  ,p_coord_ben_med_pl_name        in      varchar2 default hr_api.g_varchar2
  ,p_coord_ben_med_insr_crr_name  in      varchar2 default hr_api.g_varchar2
  ,p_coord_ben_med_insr_crr_ident in      varchar2 default hr_api.g_varchar2
  ,p_coord_ben_med_cvg_strt_dt    in      date     default hr_api.g_date
  ,p_coord_ben_med_cvg_end_dt     in      date     default hr_api.g_date
  ,p_uses_tobacco_flag            in      varchar2 default hr_api.g_varchar2
  ,p_dpdnt_adoption_date          in      date     default hr_api.g_date
  ,p_dpdnt_vlntry_svce_flag       in      varchar2 default hr_api.g_varchar2
  ,p_original_date_of_hire        in      date     default hr_api.g_date
  ,p_adjusted_svc_date            in      date     default hr_api.g_date
  ,p_town_of_birth                in      varchar2 default hr_api.g_varchar2
  ,p_region_of_birth              in      varchar2 default hr_api.g_varchar2
  ,p_country_of_birth             in      varchar2 default hr_api.g_varchar2
  ,p_global_person_id             in      varchar2 default hr_api.g_varchar2
  ,p_party_id                     in      number   default hr_api.g_number
  ,p_npw_number                   in      varchar2 default hr_api.g_varchar2
  ,p_effective_start_date         out     NOCOPY  date
  ,p_effective_end_date           out     NOCOPY  date
  ,p_full_name                    out     NOCOPY  varchar2
  ,p_comment_id                   out     NOCOPY  number
  ,p_name_combination_warning     out     NOCOPY  varchar2
  ,p_assign_payroll_warning       out     NOCOPY  varchar2
  ,p_orig_hire_warning            out     NOCOPY  varchar2
  ,p_return_status                out     NOCOPY  varchar2
  ) is

 l_validate                    boolean :=false;
 l_name_combination_warning    boolean :=false;
 l_orig_hire_warning           boolean :=false;
 l_assign_payroll_warning      boolean :=false;

 BEGIN
 IF(p_validate = 'Y')
   THEN
      l_validate :=true;
   END IF;

 hr_person_api.update_person
      (p_validate                               =>l_validate
      ,p_effective_date                         =>p_effective_date
      ,p_datetrack_update_mode        		=>p_datetrack_update_mode
      ,p_person_id                    		=>p_person_id
      ,p_object_version_number        		=>p_object_version_number
      ,p_person_type_id               		=>p_person_type_id
      ,p_last_name                    		=>p_last_name
      ,p_applicant_number             		=>p_applicant_number
      ,p_comments                     		=>p_comments
      ,p_date_employee_data_verified  		=>p_date_employee_data_verified
      ,p_date_of_birth                		=>p_date_of_birth
      ,p_email_address                		=>p_email_address
      ,p_employee_number              		=>p_employee_number
      ,p_expense_check_send_to_addres 		=>p_expense_check_send_to_addres
      ,p_first_name                   		=>p_first_name
      ,p_known_as                     		=>p_known_as
      ,p_marital_status               		=>p_marital_status
      ,p_middle_names                 		=>p_middle_names
      ,p_nationality                  		=>p_nationality
      ,p_national_identifier          		=>p_national_identifier
      ,p_previous_last_name           		=>p_previous_last_name
      ,p_registered_disabled_flag     		=>p_registered_disabled_flag
      ,p_sex                          		=>p_sex
      ,p_title                        		=>p_title
      ,p_vendor_id                    		=>p_vendor_id
      ,p_work_telephone               		=>p_work_telephone
      ,p_attribute_category           		=>p_attribute_category
      ,p_attribute1                   		=>p_attribute1
      ,p_attribute2                   		=>p_attribute2
      ,p_attribute3                   		=>p_attribute3
      ,p_attribute4                   		=>p_attribute4
      ,p_attribute5                   		=>p_attribute5
      ,p_attribute6                   		=>p_attribute6
      ,p_attribute7                   		=>p_attribute7
      ,p_attribute8                   		=>p_attribute8
      ,p_attribute9                   		=>p_attribute9
      ,p_attribute10                  		=>p_attribute10
      ,p_attribute11                  		=>p_attribute11
      ,p_attribute12                  		=>p_attribute12
      ,p_attribute13                  		=>p_attribute13
      ,p_attribute14                  		=>p_attribute14
      ,p_attribute15                  		=>p_attribute15
      ,p_attribute16                  		=>p_attribute16
      ,p_attribute17                  		=>p_attribute17
      ,p_attribute18                  		=>p_attribute18
      ,p_attribute19                  		=>p_attribute19
      ,p_attribute20                  		=>p_attribute20
      ,p_attribute21                  		=>p_attribute21
      ,p_attribute22                  		=>p_attribute22
      ,p_attribute23                  		=>p_attribute23
      ,p_attribute24                  		=>p_attribute24
      ,p_attribute25                  		=>p_attribute25
      ,p_attribute26                  		=>p_attribute26
      ,p_attribute27                  		=>p_attribute27
      ,p_attribute28                  		=>p_attribute28
      ,p_attribute29                  		=>p_attribute29
      ,p_attribute30                  		=>p_attribute30
      ,p_per_information_category     		=>p_per_information_category
      ,p_per_information1             		=>p_per_information1
      ,p_per_information2             		=>p_per_information2
      ,p_per_information3             		=>p_per_information3
      ,p_per_information4             		=>p_per_information4
      ,p_per_information5             		=>p_per_information5
      ,p_per_information6             		=>p_per_information6
      ,p_per_information7             		=>p_per_information7
      ,p_per_information8             		=>p_per_information8
      ,p_per_information9             		=>p_per_information9
      ,p_per_information10            		=>p_per_information10
      ,p_per_information11            		=>p_per_information11
      ,p_per_information12            		=>p_per_information12
      ,p_per_information13            		=>p_per_information13
      ,p_per_information14            		=>p_per_information14
      ,p_per_information15            		=>p_per_information15
      ,p_per_information16            		=>p_per_information16
      ,p_per_information17            		=>p_per_information17
      ,p_per_information18            		=>p_per_information18
      ,p_per_information19            		=>p_per_information19
      ,p_per_information20            		=>p_per_information20
      ,p_per_information21            		=>p_per_information21
      ,p_per_information22            		=>p_per_information22
      ,p_per_information23            		=>p_per_information23
      ,p_per_information24            		=>p_per_information24
      ,p_per_information25            		=>p_per_information25
      ,p_per_information26            		=>p_per_information26
      ,p_per_information27            		=>p_per_information27
      ,p_per_information28            		=>p_per_information28
      ,p_per_information29            		=>p_per_information29
      ,p_per_information30            		=>p_per_information30
      ,p_date_of_death                		=>p_date_of_death
      ,p_background_check_status      		=>p_background_check_status
      ,p_background_date_check        		=>p_background_date_check
      ,p_blood_type                   		=>p_blood_type
      ,p_correspondence_language      		=>p_correspondence_language
      ,p_fast_path_employee           		=>p_fast_path_employee
      ,p_fte_capacity                 		=>p_fte_capacity
      ,p_hold_applicant_date_until    		=>p_hold_applicant_date_until
      ,p_honors                       		=>p_honors
      ,p_internal_location            		=>p_internal_location
      ,p_last_medical_test_by         		=>p_last_medical_test_by
      ,p_last_medical_test_date       		=>p_last_medical_test_date
      ,p_mailstop                     		=>p_mailstop
      ,p_office_number                		=>p_office_number
      ,p_on_military_service          		=>p_on_military_service
      ,p_pre_name_adjunct             		=>p_pre_name_adjunct
      ,p_projected_start_date         		=>p_projected_start_date
      ,p_rehire_authorizor            		=>p_rehire_authorizor
      ,p_rehire_recommendation        		=>p_rehire_recommendation
      ,p_resume_exists                		=>p_resume_exists
      ,p_resume_last_updated          		=>p_resume_last_updated
      ,p_second_passport_exists       		=>p_second_passport_exists
      ,p_student_status               		=>p_student_status
      ,p_work_schedule                		=>p_work_schedule
      ,p_rehire_reason                		=>p_rehire_reason
      ,p_suffix                       		=>p_suffix
      ,p_benefit_group_id             		=>p_benefit_group_id
      ,p_receipt_of_death_cert_date   		=>p_receipt_of_death_cert_date
      ,p_coord_ben_med_pln_no         		=>p_coord_ben_med_pln_no
      ,p_coord_ben_no_cvg_flag        		=>p_coord_ben_no_cvg_flag
      ,p_coord_ben_med_ext_er         		=>p_coord_ben_med_ext_er
      ,p_coord_ben_med_pl_name        		=>p_coord_ben_med_pl_name
      ,p_coord_ben_med_insr_crr_name  		=>p_coord_ben_med_insr_crr_name
      ,p_coord_ben_med_insr_crr_ident 		=>p_coord_ben_med_insr_crr_ident
      ,p_coord_ben_med_cvg_strt_dt    		=>p_coord_ben_med_cvg_strt_dt
      ,p_coord_ben_med_cvg_end_dt     		=>p_coord_ben_med_cvg_end_dt
      ,p_uses_tobacco_flag            		=>p_uses_tobacco_flag
      ,p_dpdnt_adoption_date          		=>p_dpdnt_adoption_date
      ,p_dpdnt_vlntry_svce_flag       		=>p_dpdnt_vlntry_svce_flag
      ,p_original_date_of_hire        		=>p_original_date_of_hire
      ,p_adjusted_svc_date            		=>p_adjusted_svc_date
      ,p_town_of_birth                		=>p_town_of_birth
      ,p_region_of_birth              		=>p_region_of_birth
      ,p_country_of_birth             		=>p_country_of_birth
      ,p_global_person_id             		=>p_global_person_id
      ,p_party_id                     		=>p_party_id
      ,p_npw_number                   		=>p_npw_number
      ,p_effective_start_date         		=>p_effective_start_date
      ,p_effective_end_date           		=>p_effective_end_date
      ,p_full_name                    		=>p_full_name
      ,p_comment_id                   		=>p_comment_id
      ,p_name_combination_warning     		=>l_name_combination_warning
      ,p_assign_payroll_warning       		=>l_assign_payroll_warning
      ,p_orig_hire_warning            		=>l_orig_hire_warning
   );

   p_return_status :='S';
 EXCEPTION
  --
   when others then
     p_return_status            := 'E';
     p_employee_number          := NULL;
     p_effective_start_date     := NULL;
     p_effective_end_date       := NULL;
     p_full_name                := NULL;
     p_comment_id               := NULL;
     p_name_combination_warning := NULL;
     p_assign_payroll_warning   := NULL;
     p_orig_hire_warning        := NULL;

     fnd_msg_pub.initialize;
     fnd_msg_pub.add;
  --
 END update_person_w;
end ben_determine_dpnt_elig_ss;

/
