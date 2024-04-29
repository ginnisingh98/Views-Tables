--------------------------------------------------------
--  DDL for Package Body BEN_ENROLLMENT_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ENROLLMENT_PROCESS" as
/* $Header: benenrol.pkb 120.18 2006/12/29 08:29:06 nkkrishn noship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|                       Copyright (c) 1998 Oracle Corporation                  |
|                          Redwood Shores, California, USA                     |
|                               All rights reserved.                           |
+==============================================================================+
--
Name
        Enrollment Process
Purpose
        This is a wrapper procedure for Benefits enrollments,
        dependents and beneficiaries designation for Enrollments conversion,
        ongoing mass updates and IVR Process.
History
	Date		Who		Version	What?
	----		---		-------	-----
	01 Nov 05	ikasire 	115.0	Created
        31 Jan 06       ikasired        115.1   Added more validations
        07 Feb 06       ikasired        115.2   More validations
        21 Feb 06       ikasired        115.3   GSCC Errors
        01 Mar 06       ikasired        115.4   Fix for c_epe cursors to
                                                for plans in multiple programs
        16 Mar 06       ikasired        115.6   Bug 5099945 fixes
        17 Mar 06       ikasired        115.7   Bug 5100373 fix
        21 Mar 06       ikasired        115.8   Bug 5108304 Added validation for
                                                benefit amounts
                                                Bug 5099864 Dependents validation fix
        22 Mar 06       ikasired        115.9   Bug 5111326 fixes - more validations
        23 Mar 06       ikasired        115.10  Bug 5097635 fix for beneficiary action
                                                items
        13 Apr 06       nkkrishn        115.11  Summary row elimination changes
        02 May 06       nkkrishn        115.12  Fixed Beneficiary upload
        10 May 06       nkkrishn        115.13  Beneficiary upload, suspend
	                                        enrollment problem fixed
        10 May 06       nkkrishn        115.14  passing benefit amount param
	                                        to create_plan_beneficiary
        12 Jun 06       ikasired        115.15  If condition got removed for the
                                                call to ben_env_object.init
                                                Bug 5259118
        12 Jun 06       ikasired        115.16  Bug 5305426 to populate the proper
                                                designation coverage start date
        22 Nov 06       nkkrishn        115.18  Bug 5675220 - end dependant
                                                designation not showing up
						in PUI
        07 Dec 06       nkkrishn        115.19  Bug 5675220 - end dependant
                                                designation not showing up
						in PUI.Using ben_prtt_enrt_result_api.
						calc_dpnt_cvg_dt to calculate both
						coverage start and end date for
						dependants
        29 Dec 06       nkkrishn        115.20  ENH - End Enrollment. (5738940)
*/
--
--Globals
--
g_debug boolean := hr_utility.debug_enabled;
--
cursor c_pil(p_ler_id number,
             p_life_event_date date,
             p_person_id number) is
     select pil.per_in_ler_id
       from ben_per_in_ler pil
      where pil.ler_id = p_ler_id
        and pil.lf_evt_ocrd_dt = p_life_event_date
        and pil.person_id = p_person_id
        and pil.per_in_ler_stat_cd = 'STRTD' ;
--
cursor c_epe_oipl(p_per_in_ler_id number,
                  p_pl_id number,
                  p_opt_id number,
                  p_life_event_date date,
                  p_pgm_id number ) is
     select epe.elig_per_elctbl_chc_id,
            epe.enrt_cvg_strt_dt,
            epe.enrt_cvg_strt_dt_cd,
            epe.prtt_enrt_rslt_id,
            epe.oipl_id,
            epe.dpnt_cvg_strt_dt_cd,
            epe.dpnt_cvg_strt_dt_rl,
            epe.pgm_id,
            epe.pl_id,
            epe.ptip_id
       from ben_elig_per_elctbl_chc epe,
            ben_oipl_f oipl
      where epe.per_in_ler_id = p_per_in_ler_id
        and epe.pl_id         = p_pl_id
        and epe.oipl_id       = oipl.oipl_id
        and epe.elctbl_flag   = 'Y'
        and oipl.opt_id       = p_opt_id
        and (epe.pgm_id = p_pgm_id OR p_pgm_id IS NULL)
        and p_life_event_date between oipl.effective_start_date
                                  and oipl.effective_end_date ;
--
--Get EPE from Plan
cursor c_epe_pl(p_per_in_ler_id number,
                p_pl_id number,
                p_pgm_id number ) is
     select epe.elig_per_elctbl_chc_id,
            epe.enrt_cvg_strt_dt,
            epe.enrt_cvg_strt_dt_cd,
            epe.prtt_enrt_rslt_id,
            epe.oipl_id,
            epe.dpnt_cvg_strt_dt_cd,
            epe.dpnt_cvg_strt_dt_rl,
            epe.pgm_id,
            epe.pl_id,
            epe.ptip_id
       from ben_elig_per_elctbl_chc epe
      where epe.per_in_ler_id = p_per_in_ler_id
        and epe.oipl_id IS NULL  --- SAVINGS PLAN FIX
        and epe.pl_id         = p_pl_id
        and epe.elctbl_flag   = 'Y'
        and (epe.pgm_id = p_pgm_id OR p_pgm_id IS NULL) ;
--
cursor c_egd(p_per_in_ler_id number,
             p_elig_per_elctbl_chc_id number,
             p_dpnt_person_id number) is
     select egd.elig_dpnt_id,
            egd.elig_strt_dt,
            egd.elig_thru_dt
      from ben_elig_dpnt egd
     where egd.per_in_ler_id = p_per_in_ler_id
       and egd.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id
       and egd.dpnt_person_id = p_dpnt_person_id ;
--
cursor c_bnf(p_prtt_enrt_rslt_id  number,
             p_bnf_person_id      number,
             p_effective_date     date ) is
     select pbn.pl_bnf_id,
            pbn.dsgn_strt_dt,
            pbn.dsgn_thru_dt,
            pbn.object_version_number,
            pbn.effective_start_date
      from ben_pl_bnf_f pbn
     where pbn.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
       and pbn.bnf_person_id     = p_bnf_person_id
       and p_effective_date between pbn.effective_start_date
                                and pbn.effective_end_date ;
--
cursor c_bnf_org(p_prtt_enrt_rslt_id  number,
             p_organization_id        number,
             p_effective_date     date ) is
     select pbn.pl_bnf_id,
            pbn.dsgn_strt_dt,
            pbn.dsgn_thru_dt,
            pbn.object_version_number,
            pbn.effective_start_date
      from ben_pl_bnf_f pbn
     where pbn.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
       and pbn.organization_id   = p_organization_id
       and p_effective_date between pbn.effective_start_date
                                and pbn.effective_end_date ;
--
procedure get_pil
  (p_person_id       in number,
   p_ler_id          in number,
   p_life_event_date in date,
   p_pil            out nocopy c_pil%ROWTYPE ) is
  --
  l_proc                   varchar2(60) := 'ben_enrollment_process.get_pil';
  --
  l_pil    c_pil%ROWTYPE;
  --
begin
   --Get PIL
   OPEN c_pil(p_ler_id,p_life_event_date,p_person_id);
     FETCH c_pil into l_pil ;
     --
     IF c_pil%NOTFOUND THEN
        --
        CLOSE c_pil;
        if g_debug then
          hr_utility.set_location('BEN_94534_PIL_NOT_FOUND'|| to_char(p_person_id),54);
        end if;
        fnd_message.set_name('BEN','BEN_94534_PIL_NOT_FOUND');
        fnd_message.set_token('PROC',l_proc);
        fnd_message.set_token('PERSON_ID',to_char(p_person_id));
        fnd_message.set_token('LER_ID',to_char(p_ler_id));
        fnd_message.set_token('LE_DATE', p_life_event_date);
        fnd_message.raise_error;
        --
     END IF;
   CLOSE c_pil;
   --
   p_pil  := l_pil ;
   --
end get_pil ;
--
procedure get_epe
  (p_person_id       in number,
   p_per_in_ler_id   in number,
   p_life_event_date in date,
   p_opt_id          in number,
   p_pl_id           in number,
   p_pgm_id          in number,
   p_epe            out nocopy c_epe_pl%ROWTYPE ) is
  --
  l_proc                   varchar2(60) := 'ben_enrollment_process.get_epe';
  l_epe    c_epe_pl%ROWTYPE;
  --
begin
   --Get EPE
   --Get EPE
   IF p_opt_id IS NOT NULL THEN
     --
     OPEN c_epe_oipl(p_per_in_ler_id,
                     p_pl_id,
                     p_opt_id,
                     p_life_event_date,
                     p_pgm_id ) ;
       FETCH c_epe_oipl INTO l_epe;
       IF c_epe_oipl%NOTFOUND THEN
         CLOSE c_epe_oipl ;
         if g_debug then
           hr_utility.set_location('BEN_94612_NO_EPE_EU'|| to_char(p_person_id),54);
         end if;
         fnd_message.set_name('BEN','BEN_94612_NO_EPE_EU');
         fnd_message.set_token('PROC',l_proc);
         fnd_message.set_token('PERSON_ID',to_char(p_person_id));
         fnd_message.set_token('PGM_ID',to_char(p_pgm_id));
         fnd_message.set_token('PL_ID',to_char(p_pl_id));
         fnd_message.set_token('OPT_ID',to_char(p_opt_id));
         fnd_message.set_token('PER_IN_LER_ID',to_char(p_per_in_ler_id));
         fnd_message.set_token('LE_DATE',p_life_event_date);
         fnd_message.raise_error;
         --
       END IF;
       --
     CLOSE c_epe_oipl ;
     --
   ELSE
     --
     OPEN c_epe_pl(p_per_in_ler_id,
                   p_pl_id,
                   p_pgm_id ) ;
       FETCH c_epe_pl INTO l_epe;
       IF c_epe_pl%NOTFOUND THEN
         CLOSE c_epe_pl ;
         if g_debug then
           hr_utility.set_location('BEN_94612_NO_EPE_EU'|| to_char(p_person_id),54);
         end if;
         fnd_message.set_name('BEN','BEN_94612_NO_EPE_EU');
         fnd_message.set_token('PROC',l_proc);
         fnd_message.set_token('PERSON_ID',to_char(p_person_id));
         fnd_message.set_token('PGM_ID',to_char(p_pgm_id));
         fnd_message.set_token('PL_ID',to_char(p_pl_id));
         fnd_message.set_token('OPT_ID',to_char(p_opt_id));
         fnd_message.set_token('PER_IN_LER_ID',to_char(p_per_in_ler_id));
         fnd_message.set_token('LE_DATE',p_life_event_date);
         fnd_message.raise_error;
         --
       END IF;
       --
     CLOSE c_epe_pl ;
     --
   END IF;
   --
   p_epe := l_epe ;
   --
end get_epe ;
--
procedure get_egd
  (p_per_in_ler_id          in number,
   p_dpnt_person_id         in number,
   p_elig_per_elctbl_chc_id in number,
   p_egd            out nocopy c_egd%ROWTYPE ) is
  --
  l_proc                   varchar2(60) := 'ben_enrollment_process.get_egd';
  --
  l_pil c_pil%ROWTYPE;
  l_epe c_epe_oipl%ROWTYPE;
  l_egd c_egd%ROWTYPE;
  --
begin
  --Get PIL
  open c_egd(p_per_in_ler_id          => p_per_in_ler_id,
             p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id,
             p_dpnt_person_id         => p_dpnt_person_id
            );
    fetch c_egd into l_egd ;
      --
      IF c_egd%NOTFOUND THEN
         CLOSE c_egd ;
         if g_debug then
           hr_utility.set_location('BEN_94616_DPNT_WRONG',54);
         end if;
         fnd_message.set_name('BEN','BEN_94616_DPNT_WRONG');
         fnd_message.set_token('PROC',l_proc);
         fnd_message.raise_error;
         --
      END IF;
      --
  close c_egd ;
  --
  p_egd := l_egd ;
  --
end get_egd ;
--
procedure check_pen
  (p_per_in_ler_id          in number,
   p_prtt_enrt_rslt_id      in number ) is
  --
  l_proc                   varchar2(60) := 'ben_enrollment_process.check_pen';
  --
  cursor c_pen is
    select 'x'
     from ben_prtt_enrt_rslt_f pen
    where pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
      and pen.prtt_enrt_rslt_stat_cd is null
      and pen.effective_end_date = hr_api.g_eot
      and pen.enrt_cvg_thru_dt = hr_api.g_eot ;
  --
  l_dummy varchar2(30);
  --
begin
  --Get PIL
  IF p_prtt_enrt_rslt_id IS NOT NULL THEN
    open c_pen;
      fetch c_pen into l_dummy;
      IF c_pen%NOTFOUND THEN
         CLOSE c_pen ;
         if g_debug then
           hr_utility.set_location('BEN_94617_DPNT_NO_PEN',54);
         end if;
         fnd_message.set_name('BEN','BEN_94617_DPNT_NO_PEN');
         fnd_message.set_token('PROC',l_proc);
         fnd_message.raise_error;
         --
        END IF;
        --
    close c_pen ;
  ELSE
    --
    if g_debug then
       hr_utility.set_location('BEN_94617_DPNT_NO_PEN',54);
    end if;
    fnd_message.set_name('BEN','BEN_94617_DPNT_NO_PEN');
    fnd_message.set_token('PROC',l_proc);
    fnd_message.raise_error;
    --
  END IF;
  --
end check_pen ;
--
procedure get_pbn
  (p_effective_date        in date,
   p_bnf_person_id         in number,
   p_organization_id       in number,
   p_prtt_enrt_rslt_id     in number,
   p_bnf            out nocopy c_bnf%ROWTYPE ) is
  --
  l_proc                   varchar2(60) := 'ben_enrollment_process.get_pbn';
  --
  l_bnf c_bnf%ROWTYPE;
  --
begin
  --
  IF p_organization_id IS NULL AND p_bnf_person_id IS NULL THEN
    --
    if g_debug then
       hr_utility.set_location('BEN_94617_NO_BNF_PERSON',54);
    end if;
    fnd_message.set_name('BEN','BEN_94617_NO_BNF_PERSON');
    fnd_message.set_token('PROC',l_proc);
    fnd_message.raise_error;
    --
  END IF;
  --Get PIL
  IF p_organization_id IS NOT NULL THEN
    --
    open c_bnf_org(p_prtt_enrt_rslt_id =>  p_prtt_enrt_rslt_id,
             p_organization_id   =>  p_organization_id,
             p_effective_date    =>  p_effective_date
            );
      fetch c_bnf_org into l_bnf ;
    close c_bnf_org ;
    --
  ELSIF p_bnf_person_id IS NOT NULL THEN
    --
    open c_bnf(p_prtt_enrt_rslt_id =>  p_prtt_enrt_rslt_id,
             p_bnf_person_id     =>  p_bnf_person_id,
             p_effective_date    =>  p_effective_date
            );
      fetch c_bnf into l_bnf ;
    close c_bnf ;
    --
  ELSE
    --Raise error;
    null;
  END IF;
  --
  p_bnf := l_bnf ;
  --
end get_pbn ;
--
procedure get_current_pen
  (p_effective_date    in date,
   p_life_event_date   in date,
   p_person_id         in number,
   p_pgm_id            in number,
   p_pl_id             in number,
   p_opt_id            in number,
   p_bnft_val          in number,
   p_prtt_enrt_rslt_id out nocopy number,
   p_object_version_number out nocopy number) is
  --
  l_proc                varchar2(60) := 'ben_enrollment_information_detail.get_pen';
  l_prtt_enrt_rslt_id   number ;
  l_oipl_id             number ;
  --
  cursor c_oipl is
   select oipl_id
     from ben_oipl_f
    where opt_id = p_opt_id
      and pl_id  = p_pl_id
      and p_effective_date between effective_start_date
                               and effective_end_date;
  --
  cursor c_pen_plnip is
    select pen.prtt_enrt_rslt_id,
           pen.object_version_number
      from ben_prtt_enrt_rslt_f pen
     where pen.pl_id = p_pl_id
       and pen.person_id = p_person_id
       and pen.effective_end_date = hr_api.g_eot
       and pen.enrt_cvg_thru_dt = hr_api.g_eot
       and ( p_bnft_val is NULL or
             pen.bnft_amt = p_bnft_val)
       and prtt_enrt_rslt_stat_cd is null;
--
cursor c_pen_oiplnip is
    select pen.prtt_enrt_rslt_id,
           pen.object_version_number
      from ben_prtt_enrt_rslt_f pen
     where pen.oipl_id = l_oipl_id
       and pen.person_id = p_person_id
       and pen.effective_end_date = hr_api.g_eot
       and pen.enrt_cvg_thru_dt = hr_api.g_eot
       and ( p_bnft_val is NULL or
             pen.bnft_amt = p_bnft_val)
       and prtt_enrt_rslt_stat_cd is null;
--
cursor c_pen_pl is
    select pen.prtt_enrt_rslt_id,
           pen.object_version_number
      from ben_prtt_enrt_rslt_f pen
     where pen.pgm_id = p_pgm_id
       and pen.pl_id = p_pl_id
       and pen.person_id = p_person_id
       and pen.effective_end_date = hr_api.g_eot
       and pen.enrt_cvg_thru_dt = hr_api.g_eot
       and ( p_bnft_val is NULL or
             pen.bnft_amt = p_bnft_val)
       and prtt_enrt_rslt_stat_cd is null;
--
cursor c_pen_oipl is
    select pen.prtt_enrt_rslt_id,
           pen.object_version_number
      from ben_prtt_enrt_rslt_f pen
     where pen.pgm_id = p_pgm_id
       and pen.oipl_id = l_oipl_id
       and pen.person_id = p_person_id
       and pen.effective_end_date = hr_api.g_eot
       and pen.enrt_cvg_thru_dt = hr_api.g_eot
       and ( p_bnft_val is NULL or
             pen.bnft_amt = p_bnft_val)
       and prtt_enrt_rslt_stat_cd is null;
  --
  l_pen     c_pen_plnip%ROWTYPE;
  --
begin
  --
  open c_oipl ;
    fetch c_oipl into l_oipl_id;
  close c_oipl ;
  --
  IF p_pgm_id IS NULL THEN
    --
    IF l_oipl_id IS NULL THEN
      --
      open c_pen_plnip ;
        fetch c_pen_plnip into l_pen ;
      close c_pen_plnip ;
      --
    ELSE -- Plan level
      open c_pen_oiplnip ;
        fetch c_pen_oiplnip into l_pen ;
      close c_pen_oiplnip ;
    END IF;
    --
  ELSE
    --
    IF l_oipl_id IS NULL THEN
      --
      open c_pen_pl;
        fetch c_pen_pl into l_pen ;
      close c_pen_pl ;
      --
    ELSE -- Plan level
      open c_pen_oipl ;
        fetch c_pen_oipl into l_pen ;
      close c_pen_oipl ;
    END IF;
    --
  END IF;
  --
  p_prtt_enrt_rslt_id := l_pen.prtt_enrt_rslt_id;
  p_object_version_number := l_pen.object_version_number;
  --
end get_current_pen ;
--
procedure get_ended_pen
  (p_effective_date    in date,
   p_life_event_date   in date,
   p_person_id         in number,
   p_pgm_id            in number,
   p_pl_id             in number,
   p_opt_id            in number,
   p_prtt_enrt_rslt_id out nocopy number) is
  --
  l_proc                varchar2(60) := 'ben_enrollment_information_detail.get_ended_pen';
  l_prtt_enrt_rslt_id   number ;
  l_oipl_id             number ;
  --
  cursor c_oipl is
   select oipl_id
     from ben_oipl_f
    where opt_id = p_opt_id
      and pl_id  = p_pl_id
      and p_effective_date between effective_start_date
                               and effective_end_date;
  --
  cursor c_pen_plnip is
    select pen.prtt_enrt_rslt_id,
           pen.object_version_number
      from ben_prtt_enrt_rslt_f pen
     where pen.pl_id = p_pl_id
       and pen.person_id = p_person_id
       and (pen.effective_end_date <> hr_api.g_eot
        or pen.enrt_cvg_thru_dt <> hr_api.g_eot);
--
cursor c_pen_oiplnip is
    select pen.prtt_enrt_rslt_id,
           pen.object_version_number
      from ben_prtt_enrt_rslt_f pen
     where pen.oipl_id = l_oipl_id
       and pen.person_id = p_person_id
       and (pen.effective_end_date <> hr_api.g_eot
        or pen.enrt_cvg_thru_dt <> hr_api.g_eot);
--
cursor c_pen_pl is
    select pen.prtt_enrt_rslt_id,
           pen.object_version_number
      from ben_prtt_enrt_rslt_f pen
     where pen.pgm_id = p_pgm_id
       and pen.pl_id = p_pl_id
       and pen.person_id = p_person_id
       and (pen.effective_end_date <> hr_api.g_eot
       or pen.enrt_cvg_thru_dt <> hr_api.g_eot);
--
cursor c_pen_oipl is
    select pen.prtt_enrt_rslt_id,
           pen.object_version_number
      from ben_prtt_enrt_rslt_f pen
     where pen.pgm_id = p_pgm_id
       and pen.oipl_id = l_oipl_id
       and pen.person_id = p_person_id
       and (pen.effective_end_date <> hr_api.g_eot
       or pen.enrt_cvg_thru_dt <> hr_api.g_eot);
--
l_pen     c_pen_plnip%ROWTYPE;
--
begin
  --
  open c_oipl ;
    fetch c_oipl into l_oipl_id;
  close c_oipl ;
  --
  IF p_pgm_id IS NULL THEN
    --
    IF l_oipl_id IS NULL THEN
      --
      open c_pen_plnip ;
        fetch c_pen_plnip into l_pen ;
      close c_pen_plnip ;
      --
    ELSE -- Plan level
      open c_pen_oiplnip ;
        fetch c_pen_oiplnip into l_pen ;
      close c_pen_oiplnip ;
    END IF;
    --
  ELSE
    --
    IF l_oipl_id IS NULL THEN
      --
      open c_pen_pl;
        fetch c_pen_pl into l_pen ;
      close c_pen_pl ;
      --
    ELSE -- Plan level
      open c_pen_oipl ;
        fetch c_pen_oipl into l_pen ;
      close c_pen_oipl ;
    END IF;
    --
  END IF;
  --
  p_prtt_enrt_rslt_id := l_pen.prtt_enrt_rslt_id;
  --
end get_ended_pen;
--
-- --------------------------------------------------------------------------------
-- |-----------------------------< ELECTION_INFORMATION >-------------------------|
-- -------------------------------------------------------------------------------+
--
procedure enrollment_information_detail
  (p_validate               in boolean  default false
  ,p_pgm_id                 in number   default null
  ,p_pl_id                  in number   default null
  ,p_opt_id                 in number   default null
  ,p_ler_id                 in number
  ,p_life_event_date        in date
  ,p_ended_pl_id            in number   default null
  ,p_ended_opt_id           in number   default null
  ,p_ended_bnft_val         in number   default null
  ,p_effective_date         in date
  ,p_person_id              in number
  ,p_bnft_val               in number   default null
  ,p_acty_base_rt_id1       in number   default null
  ,p_rt_val1                in number   default null
  ,p_ann_rt_val1            in number   default null
  ,p_rt_strt_dt1            in date     default null
  ,p_rt_end_dt1             in date     default null
  ,p_acty_base_rt_id2       in number   default null
  ,p_rt_val2                in number   default null
  ,p_ann_rt_val2            in number   default null
  ,p_rt_strt_dt2            in date     default null
  ,p_rt_end_dt2             in date     default null
  ,p_acty_base_rt_id3       in number   default null
  ,p_rt_val3                in number   default null
  ,p_ann_rt_val3            in number   default null
  ,p_rt_strt_dt3            in date     default null
  ,p_rt_end_dt3             in date     default null
  ,p_acty_base_rt_id4       in number   default null
  ,p_rt_val4                in number   default null
  ,p_ann_rt_val4            in number   default null
  ,p_rt_strt_dt4            in date     default null
  ,p_rt_end_dt4             in date     default null
  ,p_business_group_id      in number
  ,p_enrt_cvg_strt_dt       in date     default null
  ,p_enrt_cvg_thru_dt       in date     default null
  ,p_orgnl_enrt_dt          in date     default null ) is
   --
   --
   l_proc                   varchar2(60) := 'ben_enrollment_process.enrollment_information_detail';
   l_suspend_flag           varchar2(30);
   l_dpnt_actn_warning      boolean;
   l_bnf_actn_warning       boolean;
   l_ctfn_actn_warning      boolean;
   l_object_version_number  number;
   l_prtt_enrt_rslt_id      number;
   l_prtt_rt_val_id1        number;
   l_prtt_rt_val_id2        number;
   l_prtt_rt_val_id3        number;
   l_prtt_rt_val_id4        number;
   l_prtt_rt_val_id5        number;
   l_prtt_rt_val_id6        number;
   l_prtt_rt_val_id7        number;
   l_prtt_rt_val_id8        number;
   l_prtt_rt_val_id9        number;
   l_prtt_rt_val_id10       number;
   l_enrt_rt_id1            number;
   l_enrt_rt_id2            number;
   l_enrt_rt_id3            number;
   l_enrt_rt_id4            number;
   l_enrt_bnft_id           number;
   l_elig_per_elctbl_chc_id number;
   l_prtt_enrt_interim_id   number;
   l_effective_start_date   date;
   l_effective_end_date     date;
   l_datetrack_mode         varchar2(30) ;
   l_pl_id                  number       := p_pl_id;
   l_enroll_flag            boolean      := true;
   --
   l_pil      c_pil%ROWTYPE;
   --
   l_epe     c_epe_oipl%ROWTYPE;
   --
   --GET ENB when bnft amount entered by the user
   --
   cursor c_enb_with_amt is
     select enb.enrt_bnft_id,
            enb.cvg_mlt_cd,
            enb.entr_val_at_enrt_flag,
            enb.val,
            enb.mn_val,
            enb.mx_val,
            enb.incrmt_val
       from ben_enrt_bnft enb
      where enb.elig_per_elctbl_chc_id = l_epe.elig_per_elctbl_chc_id
        and enb.mx_wo_ctfn_flag = 'N'
        and (enb.entr_val_at_enrt_flag = 'Y' OR enb.vaL = p_bnft_val) ;
   --
   l_enb     c_enb_with_amt%ROWTYPE;
   --
   --GET ENB when bnft amount is not entered by the user
   --
   cursor c_enb is
     select enb.enrt_bnft_id,enb.cvg_mlt_cd,enb.entr_val_at_enrt_flag,enb.val,
            enb.mn_val,
            enb.mx_val,
            enb.incrmt_val
       from ben_enrt_bnft enb
      where enb.elig_per_elctbl_chc_id = l_epe.elig_per_elctbl_chc_id
        and enb.mx_wo_ctfn_flag = 'N' ;
   --
   --ECR from EPE
   --
   cursor c_ecr(p_acty_base_rt_id number) is
     select enrt_rt_id,
            rt_strt_dt,
            rt_strt_dt_cd,
            entr_val_at_enrt_flag,
            val,
            ann_val
       from ben_enrt_rt ecr
      where ecr.elig_per_elctbl_chc_id = l_epe.elig_per_elctbl_chc_id
        --and ecr.entr_val_at_enrt_flag  = 'Y'
        and ecr.acty_base_rt_id = p_acty_base_rt_id ;
   --
   l_ecr1     c_ecr%ROWTYPE;
   l_ecr2     c_ecr%ROWTYPE;
   l_ecr3     c_ecr%ROWTYPE;
   l_ecr4     c_ecr%ROWTYPE;
   --
   --ECR from ENB
   --
   cursor c_ecr_enb(p_acty_base_rt_id number) is
     select enrt_rt_id,
            rt_strt_dt,
            rt_strt_dt_cd,
            entr_val_at_enrt_flag,
            val,
            ann_val
       from ben_enrt_rt ecr
      where ecr.enrt_bnft_id  = l_enb.enrt_bnft_id
        --and ecr.entr_val_at_enrt_flag  = 'Y'
        and ecr.acty_base_rt_id = p_acty_base_rt_id ;
   --
   cursor c_ecr_eve(p_epe_id number) is
    select 'Y'
      from ben_enrt_rt ecr
     where ecr.elig_per_elctbl_chc_id = p_epe_id
       and ecr.entr_val_at_enrt_flag = 'Y' ;
   --
   cursor c_ecr_enb_eve(p_enb_id number) is
    select 'Y'
      from ben_enrt_rt ecr
     where ecr.enrt_bnft_id = p_enb_id
       and ecr.entr_val_at_enrt_flag = 'Y' ;
   --
   l_dummy  varchar2(30);
   --
   cursor c_pl_opt_name(p_epe_id number) is
     select pln.name || ' '|| opt.name
     from   ben_elig_per_elctbl_chc epe,
            ben_pl_f                pln,
            ben_oipl_f              oipl,
            ben_opt_f               opt
     where  epe.elig_per_elctbl_chc_id = p_epe_id
     and    epe.pl_id                  = pln.pl_id
     and    epe.oipl_id                = oipl.oipl_id(+)
     and    oipl.opt_id                = opt.opt_id(+)
     and    p_life_event_date between
            pln.effective_start_date and pln.effective_end_date
     and    p_life_event_date between
            oipl.effective_start_date(+) and oipl.effective_end_date(+)
     and    p_life_event_date between
            opt.effective_start_date(+) and opt.effective_end_date(+);
   --
   l_pl_opt_name       varchar2(600) := null;
   --
 begin
   --
   hr_utility.set_location('Entering:'||l_proc, 20);
   --
   fnd_file.put_line
           (which => fnd_file.log,
            buff  => 'Entering - BEN_ENROLLMENT_PROCESS.ENROLLMENT_INFORMATION_DETAIL' );
   fnd_file.put_line
           (which => fnd_file.log,
            buff  => 'l_person_id '||p_person_id||' l_pgm_id '||p_pgm_id||' l_pl_id '||p_pl_id);
   --
   fnd_file.put_line
           (which => fnd_file.log,
            buff  => 'l_opt_id '||p_opt_id||' l_ler_id '||p_ler_id);
   fnd_file.put_line
           (which => fnd_file.log,
            buff  => 'p_bnft_val '||p_bnft_val);
   fnd_file.put_line
           (which => fnd_file.log,
            buff  => 'l_life_event_date '||p_life_event_date);
   --
   fnd_file.put_line
           (which => fnd_file.log,
            buff  => 'p_ended_pl_id '||p_ended_pl_id||' p_ended_opt_id '||p_ended_opt_id);
   --
   get_pil
    (p_person_id       => p_person_id,
     p_ler_id          => p_ler_id,
     p_life_event_date => p_life_event_date,
     p_pil             => l_pil
     );
   --
   --Set De-Enroll flag if ended plan details have been entered by the user
   --
   if p_ended_pl_id is not null and p_pl_id is null then --De Enroll person from the spedified plan
      l_enroll_flag := false;
   end if;
   --
   if (l_enroll_flag) then
   --
   --Get EPE
   --
   get_epe
    (p_person_id       => p_person_id,
     p_per_in_ler_id   => l_pil.per_in_ler_id,
     p_life_event_date => p_life_event_date,
     p_opt_id          => p_opt_id,
     p_pl_id           => p_pl_id,
     p_pgm_id          => p_pgm_id,
     p_epe             => l_epe
    ) ;
   --
   --Get Ended Enrollment Result
   --
   get_current_pen
       (p_effective_date    => p_effective_date,
        p_life_event_date   => p_life_event_date,
        p_person_id         => p_person_id,
        p_pgm_id            => p_pgm_id,
        p_pl_id             => p_ended_pl_id,
        p_opt_id            => p_ended_opt_id,
        p_bnft_val          => p_ended_bnft_val,
        p_prtt_enrt_rslt_id => l_prtt_enrt_rslt_id,
	p_object_version_number => l_object_version_number
       );
   --
   --Coverage start date check. User should only enter for the code ENTRBL
   IF l_epe.enrt_cvg_strt_dt_cd = 'ENTRBL' THEN
     --
     IF p_enrt_cvg_strt_dt IS NOT NULL THEN
       l_epe.enrt_cvg_strt_dt := p_enrt_cvg_strt_dt ;
     ELSE
       --Throw Error.. Coverage start date needs to be entered
         if g_debug then
           hr_utility.set_location('BEN_94552_NO_CVG_STRT_DT'|| to_char(p_person_id),54);
         end if;
         fnd_message.set_name('BEN','BEN_94552_NO_CVG_STRT_DT');
         fnd_message.set_token('PACKAGE',l_proc);
         fnd_message.set_token('PERSON_ID',to_char(p_person_id));
         fnd_message.set_token('LER_ID', to_char(p_ler_id));
         fnd_message.set_token('PGM_ID',to_char(p_pgm_id));
         fnd_message.set_token('PLAN_ID', to_char(p_pl_id));
         fnd_message.set_token('OPT_ID',to_char(p_opt_id));
         fnd_message.raise_error;
       --
     END IF;
     --
   ELSE
     --
     if g_debug then
       hr_utility.set_location('No Coverage Start date is required '||p_enrt_cvg_strt_dt ,54);
     end if;
     --
   END IF;
   --
   --Get ENB
     --User needs to enter benefit amout for flat range and enter value at enrollment cases.
     --Enter Benefit amount.
     --Flat Range
     --Other types.
     --
     --If amount is entered by user, get the matching record or MX_WO_CTFN_FLAG
     --If no amount
   IF p_bnft_val IS NOT NULL THEN
     --
     OPEN c_enb_with_amt ;
       --
       FETCH c_enb_with_amt INTO l_enb;
       IF c_enb_with_amt%NOTFOUND THEN
         CLOSE c_enb_with_amt ;
         if g_debug then
           hr_utility.set_location('BEN_91561_BENVRBRT_ENB_NF'|| to_char(p_person_id),54);
         end if;
         fnd_message.set_name('BEN','BEN_91561_BENVRBRT_ENB_NF');
         fnd_message.set_token('PACKAGE',l_proc);
         fnd_message.set_token('PERSON_ID',to_char(p_person_id));
         fnd_message.set_token('PGM_ID',to_char(p_pgm_id));
         fnd_message.set_token('PL_ID', to_char(p_pl_id));
         fnd_message.set_token('OIPL_ID',to_char(l_epe.oipl_id));
         fnd_message.set_token('LF_EVT_OCRD_DT',p_life_event_date);
         fnd_message.set_token('EFFECTIVE_DATE',p_effective_date);
         fnd_message.set_token('PER_IN_LER_ID',to_char(l_pil.per_in_ler_id));
         fnd_message.set_token('ELIG_PER_ELCTBL_CHC_ID', to_char(l_epe.elig_per_elctbl_chc_id));
         fnd_message.raise_error;
         --
       ELSE
         --
         --Check check to see if the coverage calculation method requires the benefit amount.
         IF (l_enb.entr_val_at_enrt_flag = 'Y' or l_enb.cvg_mlt_cd like '%RNG') THEN
           --
           l_enb.val := p_bnft_val ;
           --
         ELSE
           --
           CLOSE c_enb_with_amt ;
           if g_debug then
             hr_utility.set_location('BEN_94558_INVALID_BNFT_VAL'|| to_char(p_person_id),54);
           end if;
           fnd_message.set_name('BEN','BEN_91561_BENVRBRT_ENB_NF');
           fnd_message.set_token('PROC',l_proc);
           fnd_message.set_token('PERSON_ID',to_char(p_person_id));
           fnd_message.set_token('LER_ID',to_char(p_ler_id));
           fnd_message.set_token('PGM_ID',to_char(p_pgm_id));
           fnd_message.set_token('PLAN_ID', to_char(p_pl_id));
           fnd_message.set_token('OPT_ID',to_char(p_opt_id));
           fnd_message.raise_error;
           --
         END IF;
         --
       END IF;
       --
     CLOSE c_enb_with_amt ;
     --Validation for Benefit Amount ranges
     if p_bnft_val is not null then
        --
        --  Bug 3181158, added nvl in 'if' to handle
        --  'EnrtValAtEnrt + no default value' condition
        --
        if ((l_enb.mn_val is not null and p_bnft_val < l_enb.mn_val) or
            (l_enb.mx_val is not null and p_bnft_val > l_enb.mx_val)) then
          --
          -- Open the c_pl_opt_name cursor only if error needs to be displayed.
          --
          open  c_pl_opt_name(l_epe.elig_per_elctbl_chc_id);
          fetch c_pl_opt_name into l_pl_opt_name;
          close c_pl_opt_name;
          --
          fnd_message.set_name('BEN','BEN_92394_OUT_OF_RANGE');
          fnd_message.set_token('MINIMUM', l_enb.mn_val);
          fnd_message.set_token('MAXIMUM', l_enb.mx_val);
          fnd_message.set_token('PLAN', l_pl_opt_name);
          fnd_message.raise_error;
          --
        end if;
        --
        if l_enb.mn_val is not null and
           l_enb.incrmt_val is not null and
           mod(p_bnft_val-l_enb.mn_val, l_enb.incrmt_val) <> 0 then
          --
          -- Open the c_pl_opt_name cursor only if error needs to be displayed.
          --
          open  c_pl_opt_name(l_epe.elig_per_elctbl_chc_id);
          fetch c_pl_opt_name into l_pl_opt_name;
          close c_pl_opt_name;
          --
          fnd_message.set_name('BEN','BEN_92395_NOT_IN_INCR');
          fnd_message.set_token('INCREMENT', l_enb.incrmt_val);
          fnd_message.set_token('PLAN', l_pl_opt_name);
          fnd_message.raise_error;
          --
        end if;
        --
     end if;
     --
     --
   ELSE
     --
     OPEN c_enb ;
       FETCH c_enb INTO l_enb;
         IF ((l_enb.entr_val_at_enrt_flag = 'Y' or l_enb.cvg_mlt_cd like '%RNG')  and
              p_bnft_val IS NULL) THEN
           --
           if g_debug then
             hr_utility.set_location('BEN_94559_NO_BNFT_VAL'|| to_char(p_person_id),54);
           end if;
           CLOSE c_enb ;
           fnd_message.set_name('BEN','BEN_94559_NO_BNFT_VAL');
           fnd_message.set_token('PROC',l_proc);
           fnd_message.set_token('PERSON_ID',to_char(p_person_id));
           fnd_message.set_token('LER_ID',to_char(p_ler_id));
           fnd_message.set_token('PGM_ID',to_char(p_pgm_id));
           fnd_message.set_token('PLAN_ID', to_char(p_pl_id));
           fnd_message.set_token('OPT_ID',to_char(p_opt_id));
           fnd_message.raise_error;
           --
         END IF;
     CLOSE c_enb ;
     --
   END IF;
   --
   IF l_enb.enrt_bnft_id IS NOT NULL THEN
     open c_ecr_enb_eve(l_enb.enrt_bnft_id );
       fetch c_ecr_enb_eve into l_dummy;
     close c_ecr_enb_eve;
     --
   ELSE
     --
     open c_ecr_eve(l_epe.elig_per_elctbl_chc_id);
       fetch c_ecr_eve into l_dummy;
     close c_ecr_eve;
     --
   END IF;
   --
   IF l_dummy = 'Y' THEN
     --
     IF p_acty_base_rt_id1 IS NOT NULL AND
      (p_rt_val1 IS NOT NULL OR  p_ann_rt_val1 IS NOT NULL OR p_rt_strt_dt1 IS NOT NULL ) THEN
      --
      null;
     ELSIF p_acty_base_rt_id2 IS NOT NULL AND
      (p_rt_val2 IS NOT NULL OR  p_ann_rt_val2 IS NOT NULL OR p_rt_strt_dt2 IS NOT NULL ) THEN
       --
       null;
       --
     ELSIF p_acty_base_rt_id3 IS NOT NULL AND
      (p_rt_val3 IS NOT NULL OR  p_ann_rt_val3 IS NOT NULL OR p_rt_strt_dt3 IS NOT NULL ) THEN
       --
       null;
       --
     ELSIF p_acty_base_rt_id4 IS NOT NULL AND
      (p_rt_val4 IS NOT NULL OR  p_ann_rt_val4 IS NOT NULL OR p_rt_strt_dt4 IS NOT NULL ) THEN
       --
       null;
       --
     ELSE
       --
       if g_debug then
         hr_utility.set_location('APP_94555_NO_RATE_VAL'|| to_char(p_person_id),54);
       end if;
       fnd_message.set_name('BEN','APP_94555_NO_RATE_VAL');
       fnd_message.set_token('PROC',l_proc);
       fnd_message.set_token('PERSON_ID', to_char(p_person_id));
       fnd_message.set_token('LER_ID',to_char(p_ler_id));
       fnd_message.set_token('PGM_ID',to_char(p_pgm_id));
       fnd_message.set_token('PLAN_ID', to_char(p_pl_id));
       fnd_message.set_token('OPT_ID',to_char(p_opt_id));
       fnd_message.raise_error;
       --
     END IF;

   END IF ;
   --

   --Get ECR
   --
   IF p_acty_base_rt_id1 IS NOT NULL AND
      (p_rt_val1 IS NOT NULL OR  p_ann_rt_val1 IS NOT NULL OR p_rt_strt_dt1 IS NOT NULL ) THEN
     --
     IF l_enb.enrt_bnft_id IS NOT NULL THEN
       --
       OPEN c_ecr_enb(p_acty_base_rt_id1);
         FETCH c_ecr_enb INTO l_ecr1; -- l_enrt_rt_id1;
         IF c_ecr_enb%NOTFOUND THEN
           CLOSE c_ecr_enb ;
           if g_debug then
             hr_utility.set_location('BEN_94535_ECR_NOT_FOUND'|| to_char(p_person_id),54);
           end if;
           fnd_message.set_name('BEN','BEN_94535_ECR_NOT_FOUND');
           fnd_message.set_token('PROC',l_proc);
           fnd_message.set_token('PERSON_ID', to_char(p_person_id));
           fnd_message.set_token('ABR_ID', to_char(p_acty_base_rt_id1));
           fnd_message.set_token('RT_VAL', to_char(p_rt_val1));
           fnd_message.set_token('ANN_RT_VAL', to_char(p_ann_rt_val1));
           fnd_message.raise_error;
           --
         ELSE
           --
           IF l_ecr1.rt_strt_dt_cd = 'ENTRBL' THEN
             IF p_rt_strt_dt1 IS NOT NULL THEN
               --
               l_ecr1.rt_strt_dt := p_rt_strt_dt1 ;
               --
             ELSE
               --Throw Error
               if g_debug then
                 hr_utility.set_location('BEN_94552_NO_RT_STRT_DT'|| to_char(p_person_id),54);
               end if;
               CLOSE c_ecr_enb;
               fnd_message.set_name('BEN','BEN_94552_NO_RT_STRT_DT');
               fnd_message.set_token('PACKAGE',l_proc);
               fnd_message.set_token('PERSON_ID',to_char(p_person_id));
               fnd_message.set_token('LER_ID', to_char(p_ler_id));
               fnd_message.set_token('PGM_ID',to_char(p_pgm_id));
               fnd_message.set_token('PLAN_ID', to_char(p_pl_id));
               fnd_message.set_token('OPT_ID',to_char(p_opt_id));
               fnd_message.raise_error;
               --
             END IF;
           END IF;
           --
           IF l_ecr1.entr_val_at_enrt_flag = 'Y' THEN
             --
             IF p_rt_val1 IS NOT NULL OR  p_ann_rt_val1 IS NOT NULL THEN
               l_ecr1.val := p_rt_val1 ;
               l_ecr1.ann_val := p_ann_rt_val1;
             ELSE
               --Throw error- rates need to be entered
               if g_debug then
                 hr_utility.set_location('BEN_94555_NO_RATE_VAL'|| to_char(p_person_id),54);
               end if;
               CLOSE c_ecr_enb;
               fnd_message.set_name('BEN','BEN_94555_NO_RATE_VAL');
               fnd_message.set_token('PACKAGE',l_proc);
               fnd_message.set_token('PERSON_ID',to_char(p_person_id));
               fnd_message.set_token('LER_ID', to_char(p_ler_id));
               fnd_message.set_token('PGM_ID',to_char(p_pgm_id));
               fnd_message.set_token('PLAN_ID', to_char(p_pl_id));
               fnd_message.set_token('OPT_ID',to_char(p_opt_id));
               fnd_message.raise_error;
               --
             END IF;
             --
           ELSE
             null ; --ignore supplied rates.
           END IF;
         END IF;
         --
       CLOSE c_ecr_enb;
       --
     ELSE
       --
       OPEN c_ecr(p_acty_base_rt_id1);
         FETCH c_ecr INTO l_ecr1; -- l_enrt_rt_id1;
         IF c_ecr%NOTFOUND THEN
           CLOSE c_ecr ;
           if g_debug then
             hr_utility.set_location('BEN_94535_ECR_NOT_FOUND'|| to_char(p_person_id),54);
           end if;
           fnd_message.set_name('BEN','BEN_94535_ECR_NOT_FOUND');
           fnd_message.set_token('PROC',l_proc);
           fnd_message.set_token('PERSON_ID', to_char(p_person_id));
           fnd_message.set_token('ABR_ID', to_char(p_acty_base_rt_id1));
           fnd_message.set_token('RT_VAL', to_char(p_rt_val1));
           fnd_message.set_token('ANN_RT_VAL', to_char(p_ann_rt_val1));
           fnd_message.raise_error;
           --
         ELSE
           --
           IF l_ecr1.rt_strt_dt_cd = 'ENTRBL' THEN
             IF p_rt_strt_dt1 IS NOT NULL THEN
               --
               l_ecr1.rt_strt_dt := p_rt_strt_dt1 ;
               --
             ELSE
               --Throw Error
               if g_debug then
                 hr_utility.set_location('BEN_94552_NO_RT_STRT_DT'|| to_char(p_person_id),54);
               end if;
               CLOSE c_ecr;
               fnd_message.set_name('BEN','BEN_94552_NO_RT_STRT_DT');
               fnd_message.set_token('PACKAGE',l_proc);
               fnd_message.set_token('PERSON_ID',to_char(p_person_id));
               fnd_message.set_token('LER_ID', to_char(p_ler_id));
               fnd_message.set_token('PGM_ID',to_char(p_pgm_id));
               fnd_message.set_token('PLAN_ID', to_char(p_pl_id));
               fnd_message.set_token('OPT_ID',to_char(p_opt_id));
               fnd_message.raise_error;
               --
             END IF;
           END IF;
           --
           IF l_ecr1.entr_val_at_enrt_flag = 'Y' THEN
             --
             IF p_rt_val1 IS NOT NULL OR  p_ann_rt_val1 IS NOT NULL THEN
               l_ecr1.val := p_rt_val1 ;
               l_ecr1.ann_val := p_ann_rt_val1;
             ELSE
               --Throw error- rates need to be entered
               if g_debug then
                 hr_utility.set_location('BEN_94555_NO_RATE_VAL'|| to_char(p_person_id),54);
               end if;
               CLOSE c_ecr;
               fnd_message.set_name('BEN','BEN_94555_NO_RATE_VAL');
               fnd_message.set_token('PACKAGE',l_proc);
               fnd_message.set_token('PERSON_ID',to_char(p_person_id));
               fnd_message.set_token('LER_ID', to_char(p_ler_id));
               fnd_message.set_token('PGM_ID',to_char(p_pgm_id));
               fnd_message.set_token('PLAN_ID', to_char(p_pl_id));
               fnd_message.set_token('OPT_ID',to_char(p_opt_id));
               fnd_message.raise_error;
               --
             END IF;
             --
           ELSE
             null ; --ignore supplied rates.
           END IF;
           --
         END IF;
         --
       CLOSE c_ecr;
       --
     END IF;
     --
   END IF;
   --
   IF p_acty_base_rt_id2 IS NOT NULL AND
      (p_rt_val2 IS NOT NULL OR  p_ann_rt_val2 IS NOT NULL OR p_rt_strt_dt2 IS NOT NULL ) THEN
     --
     IF l_enb.enrt_bnft_id IS NOT NULL THEN
       --
       OPEN c_ecr_enb(p_acty_base_rt_id2);
         FETCH c_ecr_enb INTO l_ecr2; -- l_enrt_rt_id2;
         IF c_ecr_enb%NOTFOUND THEN
           CLOSE c_ecr_enb ;
           if g_debug then
             hr_utility.set_location('BEN_94535_ECR_NOT_FOUND'|| to_char(p_person_id),54);
           end if;
           fnd_message.set_name('BEN','BEN_94535_ECR_NOT_FOUND');
           fnd_message.set_token('PROC',l_proc);
           fnd_message.set_token('PERSON_ID', to_char(p_person_id));
           fnd_message.set_token('ABR_ID', to_char(p_acty_base_rt_id2));
           fnd_message.set_token('RT_VAL', to_char(p_rt_val2));
           fnd_message.set_token('ANN_RT_VAL', to_char(p_ann_rt_val2));
           fnd_message.raise_error;
           --
         ELSE
           --
           IF l_ecr2.rt_strt_dt_cd = 'ENTRBL' THEN
             IF p_rt_strt_dt2 IS NOT NULL THEN
               --
               l_ecr2.rt_strt_dt := p_rt_strt_dt2 ;
               --
             ELSE
               --Throw Error
               if g_debug then
                 hr_utility.set_location('BEN_94552_NO_RT_STRT_DT'|| to_char(p_person_id),54);
               end if;
               CLOSE c_ecr_enb;
               fnd_message.set_name('BEN','BEN_94552_NO_RT_STRT_DT');
               fnd_message.set_token('PACKAGE',l_proc);
               fnd_message.set_token('PERSON_ID',to_char(p_person_id));
               fnd_message.set_token('LER_ID', to_char(p_ler_id));
               fnd_message.set_token('PGM_ID',to_char(p_pgm_id));
               fnd_message.set_token('PLAN_ID', to_char(p_pl_id));
               fnd_message.set_token('OPT_ID',to_char(p_opt_id));
               fnd_message.raise_error;
               --
             END IF;
           END IF;
           --
           IF l_ecr2.entr_val_at_enrt_flag = 'Y' THEN
             --
             IF p_rt_val2 IS NOT NULL OR  p_ann_rt_val2 IS NOT NULL THEN
               l_ecr2.val := p_rt_val2 ;
               l_ecr2.ann_val := p_ann_rt_val2;
             ELSE
               --Throw error- rates need to be entered
               if g_debug then
                 hr_utility.set_location('BEN_94555_NO_RATE_VAL'|| to_char(p_person_id),54);
               end if;
               CLOSE c_ecr_enb;
               fnd_message.set_name('BEN','BEN_94555_NO_RATE_VAL');
               fnd_message.set_token('PACKAGE',l_proc);
               fnd_message.set_token('PERSON_ID',to_char(p_person_id));
               fnd_message.set_token('LER_ID', to_char(p_ler_id));
               fnd_message.set_token('PGM_ID',to_char(p_pgm_id));
               fnd_message.set_token('PLAN_ID', to_char(p_pl_id));
               fnd_message.set_token('OPT_ID',to_char(p_opt_id));
               fnd_message.raise_error;
               --
             END IF;
             --
           ELSE
             null ; --ignore supplied rates.
           END IF;
         END IF;
         --
       CLOSE c_ecr_enb;
       --
     ELSE
       --
       OPEN c_ecr(p_acty_base_rt_id2);
         FETCH c_ecr INTO l_ecr2; -- l_enrt_rt_id2;
         IF c_ecr%NOTFOUND THEN
           CLOSE c_ecr ;
           if g_debug then
             hr_utility.set_location('BEN_94535_ECR_NOT_FOUND'|| to_char(p_person_id),54);
           end if;
           fnd_message.set_name('BEN','BEN_94535_ECR_NOT_FOUND');
           fnd_message.set_token('PROC',l_proc);
           fnd_message.set_token('PERSON_ID', to_char(p_person_id));
           fnd_message.set_token('ABR_ID', to_char(p_acty_base_rt_id2));
           fnd_message.set_token('RT_VAL', to_char(p_rt_val2));
           fnd_message.set_token('ANN_RT_VAL', to_char(p_ann_rt_val2));
           fnd_message.raise_error;
           --
         ELSE
           --
           IF l_ecr2.rt_strt_dt_cd = 'ENTRBL' THEN
             IF p_rt_strt_dt2 IS NOT NULL THEN
               --
               l_ecr2.rt_strt_dt := p_rt_strt_dt2 ;
               --
             ELSE
               --Throw Error
               if g_debug then
                 hr_utility.set_location('BEN_94552_NO_RT_STRT_DT'|| to_char(p_person_id),54);
               end if;
               CLOSE c_ecr;
               fnd_message.set_name('BEN','BEN_94552_NO_RT_STRT_DT');
               fnd_message.set_token('PACKAGE',l_proc);
               fnd_message.set_token('PERSON_ID',to_char(p_person_id));
               fnd_message.set_token('LER_ID', to_char(p_ler_id));
               fnd_message.set_token('PGM_ID',to_char(p_pgm_id));
               fnd_message.set_token('PLAN_ID', to_char(p_pl_id));
               fnd_message.set_token('OPT_ID',to_char(p_opt_id));
               fnd_message.raise_error;
               --
             END IF;
           END IF;
           --
           IF l_ecr2.entr_val_at_enrt_flag = 'Y' THEN
             --
             IF p_rt_val2 IS NOT NULL OR  p_ann_rt_val2 IS NOT NULL THEN
               l_ecr2.val := p_rt_val2 ;
               l_ecr2.ann_val := p_ann_rt_val2;
             ELSE
               --Throw error- rates need to be entered
               if g_debug then
                 hr_utility.set_location('BEN_94555_NO_RATE_VAL'|| to_char(p_person_id),54);
               end if;
               CLOSE c_ecr;
               fnd_message.set_name('BEN','BEN_94555_NO_RATE_VAL');
               fnd_message.set_token('PACKAGE',l_proc);
               fnd_message.set_token('PERSON_ID',to_char(p_person_id));
               fnd_message.set_token('LER_ID', to_char(p_ler_id));
               fnd_message.set_token('PGM_ID',to_char(p_pgm_id));
               fnd_message.set_token('PLAN_ID', to_char(p_pl_id));
               fnd_message.set_token('OPT_ID',to_char(p_opt_id));
               fnd_message.raise_error;
               --
             END IF;
             --
           ELSE
             null ; --ignore supplied rates.
           END IF;
           --
         END IF;
         --
       CLOSE c_ecr;
       --
     END IF;
     --
   END IF;
   --
   IF p_acty_base_rt_id3 IS NOT NULL AND
      (p_rt_val3 IS NOT NULL OR  p_ann_rt_val3 IS NOT NULL OR p_rt_strt_dt3 IS NOT NULL ) THEN
     --
     IF l_enb.enrt_bnft_id IS NOT NULL THEN
       --
       OPEN c_ecr_enb(p_acty_base_rt_id3);
         FETCH c_ecr_enb INTO l_ecr3; -- l_enrt_rt_id3;
         IF c_ecr_enb%NOTFOUND THEN
           CLOSE c_ecr_enb ;
           if g_debug then
             hr_utility.set_location('BEN_94535_ECR_NOT_FOUND'|| to_char(p_person_id),54);
           end if;
           fnd_message.set_name('BEN','BEN_94535_ECR_NOT_FOUND');
           fnd_message.set_token('PROC',l_proc);
           fnd_message.set_token('PERSON_ID', to_char(p_person_id));
           fnd_message.set_token('ABR_ID', to_char(p_acty_base_rt_id3));
           fnd_message.set_token('RT_VAL', to_char(p_rt_val3));
           fnd_message.set_token('ANN_RT_VAL', to_char(p_ann_rt_val3));
           fnd_message.raise_error;
           --
         ELSE
           --
           IF l_ecr3.rt_strt_dt_cd = 'ENTRBL' THEN
             IF p_rt_strt_dt3 IS NOT NULL THEN
               --
               l_ecr3.rt_strt_dt := p_rt_strt_dt3 ;
               --
             ELSE
               --Throw Error
               if g_debug then
                 hr_utility.set_location('BEN_94552_NO_RT_STRT_DT'|| to_char(p_person_id),54);
               end if;
               CLOSE c_ecr_enb;
               fnd_message.set_name('BEN','BEN_94552_NO_RT_STRT_DT');
               fnd_message.set_token('PACKAGE',l_proc);
               fnd_message.set_token('PERSON_ID',to_char(p_person_id));
               fnd_message.set_token('LER_ID', to_char(p_ler_id));
               fnd_message.set_token('PGM_ID',to_char(p_pgm_id));
               fnd_message.set_token('PLAN_ID', to_char(p_pl_id));
               fnd_message.set_token('OPT_ID',to_char(p_opt_id));
               fnd_message.raise_error;
               --
             END IF;
           END IF;
           --
           IF l_ecr3.entr_val_at_enrt_flag = 'Y' THEN
             --
             IF p_rt_val3 IS NOT NULL OR  p_ann_rt_val3 IS NOT NULL THEN
               l_ecr3.val := p_rt_val3 ;
               l_ecr3.ann_val := p_ann_rt_val3;
             ELSE
               --Throw error- rates need to be entered
               if g_debug then
                 hr_utility.set_location('BEN_94555_NO_RATE_VAL'|| to_char(p_person_id),54);
               end if;
               CLOSE c_ecr_enb;
               fnd_message.set_name('BEN','BEN_94555_NO_RATE_VAL');
               fnd_message.set_token('PACKAGE',l_proc);
               fnd_message.set_token('PERSON_ID',to_char(p_person_id));
               fnd_message.set_token('LER_ID', to_char(p_ler_id));
               fnd_message.set_token('PGM_ID',to_char(p_pgm_id));
               fnd_message.set_token('PLAN_ID', to_char(p_pl_id));
               fnd_message.set_token('OPT_ID',to_char(p_opt_id));
               fnd_message.raise_error;
               --
             END IF;
             --
           ELSE
             null ; --ignore supplied rates.
           END IF;
         END IF;
         --
       CLOSE c_ecr_enb;
       --
     ELSE
       --
       OPEN c_ecr(p_acty_base_rt_id3);
         FETCH c_ecr INTO l_ecr3; -- l_enrt_rt_id3;
         IF c_ecr%NOTFOUND THEN
           CLOSE c_ecr ;
           if g_debug then
             hr_utility.set_location('BEN_94535_ECR_NOT_FOUND'|| to_char(p_person_id),54);
           end if;
           fnd_message.set_name('BEN','BEN_94535_ECR_NOT_FOUND');
           fnd_message.set_token('PROC',l_proc);
           fnd_message.set_token('PERSON_ID', to_char(p_person_id));
           fnd_message.set_token('ABR_ID', to_char(p_acty_base_rt_id3));
           fnd_message.set_token('RT_VAL', to_char(p_rt_val3));
           fnd_message.set_token('ANN_RT_VAL', to_char(p_ann_rt_val3));
           fnd_message.raise_error;
           --
         ELSE
           --
           IF l_ecr3.rt_strt_dt_cd = 'ENTRBL' THEN
             IF p_rt_strt_dt3 IS NOT NULL THEN
               --
               l_ecr3.rt_strt_dt := p_rt_strt_dt3 ;
               --
             ELSE
               --Throw Error
               if g_debug then
                 hr_utility.set_location('BEN_94552_NO_RT_STRT_DT'|| to_char(p_person_id),54);
               end if;
               CLOSE c_ecr;
               fnd_message.set_name('BEN','BEN_94552_NO_RT_STRT_DT');
               fnd_message.set_token('PACKAGE',l_proc);
               fnd_message.set_token('PERSON_ID',to_char(p_person_id));
               fnd_message.set_token('LER_ID', to_char(p_ler_id));
               fnd_message.set_token('PGM_ID',to_char(p_pgm_id));
               fnd_message.set_token('PLAN_ID', to_char(p_pl_id));
               fnd_message.set_token('OPT_ID',to_char(p_opt_id));
               fnd_message.raise_error;
               --
             END IF;
           END IF;
           --
           IF l_ecr3.entr_val_at_enrt_flag = 'Y' THEN
             --
             IF p_rt_val3 IS NOT NULL OR  p_ann_rt_val3 IS NOT NULL THEN
               l_ecr3.val := p_rt_val3 ;
               l_ecr3.ann_val := p_ann_rt_val3;
             ELSE
               --Throw error- rates need to be entered
               if g_debug then
                 hr_utility.set_location('BEN_94555_NO_RATE_VAL'|| to_char(p_person_id),54);
               end if;
               CLOSE c_ecr;
               fnd_message.set_name('BEN','BEN_94555_NO_RATE_VAL');
               fnd_message.set_token('PACKAGE',l_proc);
               fnd_message.set_token('PERSON_ID',to_char(p_person_id));
               fnd_message.set_token('LER_ID', to_char(p_ler_id));
               fnd_message.set_token('PGM_ID',to_char(p_pgm_id));
               fnd_message.set_token('PLAN_ID', to_char(p_pl_id));
               fnd_message.set_token('OPT_ID',to_char(p_opt_id));
               fnd_message.raise_error;
               --
             END IF;
             --
           ELSE
             null ; --ignore supplied rates.
           END IF;
           --
         END IF;
         --
       CLOSE c_ecr;
       --
     END IF;
     --
   END IF;
   --
   IF p_acty_base_rt_id4 IS NOT NULL AND
      (p_rt_val4 IS NOT NULL OR  p_ann_rt_val4 IS NOT NULL OR p_rt_strt_dt4 IS NOT NULL ) THEN
     --
     IF l_enb.enrt_bnft_id IS NOT NULL THEN
       --
       OPEN c_ecr_enb(p_acty_base_rt_id4);
         FETCH c_ecr_enb INTO l_ecr4; -- l_enrt_rt_id4;
         IF c_ecr_enb%NOTFOUND THEN
           CLOSE c_ecr_enb ;
           if g_debug then
             hr_utility.set_location('BEN_94535_ECR_NOT_FOUND'|| to_char(p_person_id),54);
           end if;
           fnd_message.set_name('BEN','BEN_94535_ECR_NOT_FOUND');
           fnd_message.set_token('PROC',l_proc);
           fnd_message.set_token('PERSON_ID', to_char(p_person_id));
           fnd_message.set_token('ABR_ID', to_char(p_acty_base_rt_id4));
           fnd_message.set_token('RT_VAL', to_char(p_rt_val4));
           fnd_message.set_token('ANN_RT_VAL', to_char(p_ann_rt_val4));
           fnd_message.raise_error;
           --
         ELSE
           --
           IF l_ecr4.rt_strt_dt_cd = 'ENTRBL' THEN
             IF p_rt_strt_dt4 IS NOT NULL THEN
               --
               l_ecr4.rt_strt_dt := p_rt_strt_dt4 ;
               --
             ELSE
               --Throw Error
               if g_debug then
                 hr_utility.set_location('BEN_94552_NO_RT_STRT_DT'|| to_char(p_person_id),54);
               end if;
               CLOSE c_ecr_enb;
               fnd_message.set_name('BEN','BEN_94552_NO_RT_STRT_DT');
               fnd_message.set_token('PACKAGE',l_proc);
               fnd_message.set_token('PERSON_ID',to_char(p_person_id));
               fnd_message.set_token('LER_ID', to_char(p_ler_id));
               fnd_message.set_token('PGM_ID',to_char(p_pgm_id));
               fnd_message.set_token('PLAN_ID', to_char(p_pl_id));
               fnd_message.set_token('OPT_ID',to_char(p_opt_id));
               fnd_message.raise_error;
               --
             END IF;
           END IF;
           --
           IF l_ecr4.entr_val_at_enrt_flag = 'Y' THEN
             --
             IF p_rt_val4 IS NOT NULL OR  p_ann_rt_val4 IS NOT NULL THEN
               l_ecr4.val := p_rt_val4 ;
               l_ecr4.ann_val := p_ann_rt_val4;
             ELSE
               --Throw error- rates need to be entered
               if g_debug then
                 hr_utility.set_location('BEN_94555_NO_RATE_VAL'|| to_char(p_person_id),54);
               end if;
               CLOSE c_ecr_enb;
               fnd_message.set_name('BEN','BEN_94555_NO_RATE_VAL');
               fnd_message.set_token('PACKAGE',l_proc);
               fnd_message.set_token('PERSON_ID',to_char(p_person_id));
               fnd_message.set_token('LER_ID', to_char(p_ler_id));
               fnd_message.set_token('PGM_ID',to_char(p_pgm_id));
               fnd_message.set_token('PLAN_ID', to_char(p_pl_id));
               fnd_message.set_token('OPT_ID',to_char(p_opt_id));
               fnd_message.raise_error;
               --
             END IF;
             --
           ELSE
             null ; --ignore supplied rates.
           END IF;
         END IF;
         --
       CLOSE c_ecr_enb;
       --
     ELSE
       --
       OPEN c_ecr(p_acty_base_rt_id4);
         FETCH c_ecr INTO l_ecr4; -- l_enrt_rt_id4;
         IF c_ecr%NOTFOUND THEN
           CLOSE c_ecr ;
           if g_debug then
             hr_utility.set_location('BEN_94535_ECR_NOT_FOUND'|| to_char(p_person_id),54);
           end if;
           fnd_message.set_name('BEN','BEN_94535_ECR_NOT_FOUND');
           fnd_message.set_token('PROC',l_proc);
           fnd_message.set_token('PERSON_ID', to_char(p_person_id));
           fnd_message.set_token('ABR_ID', to_char(p_acty_base_rt_id4));
           fnd_message.set_token('RT_VAL', to_char(p_rt_val4));
           fnd_message.set_token('ANN_RT_VAL', to_char(p_ann_rt_val4));
           fnd_message.raise_error;
           --
         ELSE
           --
           IF l_ecr4.rt_strt_dt_cd = 'ENTRBL' THEN
             IF p_rt_strt_dt4 IS NOT NULL THEN
               --
               l_ecr4.rt_strt_dt := p_rt_strt_dt4 ;
               --
             ELSE
               --Throw Error
               if g_debug then
                 hr_utility.set_location('BEN_94552_NO_RT_STRT_DT'|| to_char(p_person_id),54);
               end if;
               CLOSE c_ecr;
               fnd_message.set_name('BEN','BEN_94552_NO_RT_STRT_DT');
               fnd_message.set_token('PACKAGE',l_proc);
               fnd_message.set_token('PERSON_ID',to_char(p_person_id));
               fnd_message.set_token('LER_ID', to_char(p_ler_id));
               fnd_message.set_token('PGM_ID',to_char(p_pgm_id));
               fnd_message.set_token('PLAN_ID', to_char(p_pl_id));
               fnd_message.set_token('OPT_ID',to_char(p_opt_id));
               fnd_message.raise_error;
               --
             END IF;
           END IF;
           --
           IF l_ecr4.entr_val_at_enrt_flag = 'Y' THEN
             --
             IF p_rt_val4 IS NOT NULL OR  p_ann_rt_val4 IS NOT NULL THEN
               l_ecr4.val := p_rt_val4 ;
               l_ecr4.ann_val := p_ann_rt_val4;
             ELSE
               --Throw error- rates need to be entered
               if g_debug then
                 hr_utility.set_location('BEN_94555_NO_RATE_VAL'|| to_char(p_person_id),54);
               end if;
               CLOSE c_ecr;
               fnd_message.set_name('BEN','BEN_94555_NO_RATE_VAL');
               fnd_message.set_token('PACKAGE',l_proc);
               fnd_message.set_token('PERSON_ID',to_char(p_person_id));
               fnd_message.set_token('LER_ID', to_char(p_ler_id));
               fnd_message.set_token('PGM_ID',to_char(p_pgm_id));
               fnd_message.set_token('PLAN_ID', to_char(p_pl_id));
               fnd_message.set_token('OPT_ID',to_char(p_opt_id));
               fnd_message.raise_error;
               --
             END IF;
             --
           ELSE
             null ; --ignore supplied rates.
           END IF;
           --
         END IF;
         --
       CLOSE c_ecr;
       --
     END IF;
     --
   END IF;
   --
   -- WAENT --1 Prior or Enterable
   -- ENTRBL - Enterable -- Start date
   --
   ben_election_information.election_information
    (p_validate               => p_validate
    ,p_elig_per_elctbl_chc_id => l_epe.elig_per_elctbl_chc_id
    ,p_prtt_enrt_rslt_id      => l_prtt_enrt_rslt_id
    ,p_effective_date         => p_effective_date
    ,p_enrt_mthd_cd           => 'E'
    ,p_enrt_bnft_id           => l_enb.enrt_bnft_id
    ,p_bnft_val               => l_enb.val
    ,p_enrt_cvg_strt_dt       => l_epe.enrt_cvg_strt_dt
    ,p_enrt_cvg_thru_dt       => p_enrt_cvg_thru_dt
    ,p_enrt_rt_id1            => l_ecr1.enrt_rt_id
    ,p_prtt_rt_val_id1        => l_prtt_rt_val_id1
    ,p_rt_val1                => l_ecr1.val
    ,p_ann_rt_val1            => l_ecr1.ann_val
    ,p_rt_strt_dt1            => p_rt_strt_dt1
    ,p_rt_end_dt1             => p_rt_end_dt1
    ,p_enrt_rt_id2            => l_ecr2.enrt_rt_id
    ,p_prtt_rt_val_id2        => l_prtt_rt_val_id2
    ,p_rt_val2                => l_ecr2.val
    ,p_ann_rt_val2            => l_ecr2.ann_val
    ,p_rt_strt_dt2            => p_rt_strt_dt2
    ,p_rt_end_dt2             => p_rt_end_dt2
    ,p_enrt_rt_id3            => l_ecr3.enrt_rt_id
    ,p_prtt_rt_val_id3        => l_prtt_rt_val_id3
    ,p_rt_val3                => l_ecr3.val
    ,p_ann_rt_val3            => l_ecr3.ann_val
    ,p_rt_strt_dt3            => p_rt_strt_dt3
    ,p_rt_end_dt3             => p_rt_end_dt3
    ,p_enrt_rt_id4            => l_ecr4.enrt_rt_id
    ,p_prtt_rt_val_id4        => l_prtt_rt_val_id4
    ,p_rt_val4                => l_ecr4.val
    ,p_ann_rt_val4            => l_ecr4.ann_val
    ,p_rt_strt_dt4            => p_rt_strt_dt4
    ,p_rt_end_dt4             => p_rt_end_dt4
    ,p_prtt_rt_val_id5        => l_prtt_rt_val_id5
    ,p_prtt_rt_val_id6        => l_prtt_rt_val_id6
    ,p_prtt_rt_val_id7        => l_prtt_rt_val_id7
    ,p_prtt_rt_val_id8        => l_prtt_rt_val_id8
    ,p_prtt_rt_val_id9        => l_prtt_rt_val_id9
    ,p_prtt_rt_val_id10       => l_prtt_rt_val_id10
    ,p_datetrack_mode         => l_datetrack_mode
    ,p_suspend_flag           => l_suspend_flag
    ,p_called_from_sspnd      => 'N'
    ,p_effective_start_date   => l_effective_start_date
    ,p_effective_end_date     => l_effective_end_date
    ,p_object_version_number  => l_object_version_number
    ,p_prtt_enrt_interim_id   => l_prtt_enrt_interim_id
    ,p_business_group_id      => p_business_group_id
    ,p_dpnt_actn_warning      => l_dpnt_actn_warning
    ,p_bnf_actn_warning       => l_bnf_actn_warning
    ,p_ctfn_actn_warning      => l_ctfn_actn_warning);
    --
    --Set the Original Coverage Start Date
    IF p_orgnl_enrt_dt IS NOT NULL and l_prtt_enrt_rslt_id IS NOT NULL THEN
      --
      update ben_prtt_enrt_rslt_f
         set ORGNL_ENRT_DT = p_orgnl_enrt_dt
       where prtt_enrt_rslt_id = l_prtt_enrt_rslt_id ;
      --
    END IF;
    --
   else --De Enroll from plan (dax)
     --
     --Get Ended Enrollment Result
     --
     get_current_pen
         (p_effective_date    => p_effective_date,
          p_life_event_date   => p_life_event_date,
          p_person_id         => p_person_id,
          p_pgm_id            => p_pgm_id,
          p_pl_id             => p_ended_pl_id,
          p_opt_id            => p_ended_opt_id,
          p_bnft_val          => p_ended_bnft_val,
          p_prtt_enrt_rslt_id => l_prtt_enrt_rslt_id,
          p_object_version_number => l_object_version_number
         );
     --
     if l_prtt_enrt_rslt_id is null then
       --
       --Check for already ended enrollments
       --
       get_ended_pen
           (p_effective_date    => p_effective_date,
            p_life_event_date   => p_life_event_date,
	    p_person_id         => p_person_id,
            p_pgm_id            => p_pgm_id,
            p_pl_id             => p_ended_pl_id,
	    p_opt_id            => p_ended_opt_id,
            p_prtt_enrt_rslt_id => l_prtt_enrt_rslt_id
           );
       --
       if l_prtt_enrt_rslt_id is not null then
         --
	 --Raise error saying that enrollment has already been ended.
	 --
         fnd_message.set_name('BEN','BEN_94658_PLN_ALRDY_DE_ENRLD');
         fnd_message.set_token('PACKAGE',l_proc);
         fnd_message.set_token('PERSON_ID',to_char(p_person_id));
         fnd_message.set_token('PGM_ID',to_char(p_pgm_id));
         fnd_message.set_token('PL_ID', to_char(p_ended_pl_id));
         fnd_message.set_token('OPT_ID',to_char(p_ended_opt_id));
         fnd_message.set_token('PER_ENR_RSLT_ID',to_char(l_prtt_enrt_rslt_id));
         fnd_message.set_token('LE_DATE', p_life_event_date);
         fnd_message.raise_error;
	 --
       else
         --
	 --No Enrollment open/ended were found. Invalid data entered. Raise error
	 --
         fnd_message.set_name('BEN','BEN_94659_NO_PLN_FOR_DE_ENRL');
         fnd_message.set_token('PACKAGE',l_proc);
         fnd_message.set_token('PERSON_ID',to_char(p_person_id));
         fnd_message.set_token('PGM_ID',to_char(p_pgm_id));
         fnd_message.set_token('PL_ID', to_char(p_ended_pl_id));
         fnd_message.set_token('OPT_ID',to_char(p_ended_opt_id));
         fnd_message.set_token('LE_DATE', p_life_event_date);
         fnd_message.raise_error;
	 --
       end if;
       --
     end if;
     --
     --Proceed with de-enrolling from the specified plan
     --
     fnd_file.put_line
         (which => fnd_file.log,
          buff  => 'l_prtt_enrt_rslt_id '||l_prtt_enrt_rslt_id);
     --
     ben_prtt_enrt_result_api.delete_enrollment
        (p_validate                => p_validate
        ,p_per_in_ler_id           => l_pil.per_in_ler_id
        ,p_lee_rsn_id              => null                      --?
        ,p_enrt_perd_id            => null                      --?
        ,p_prtt_enrt_rslt_id       => l_prtt_enrt_rslt_id
        ,p_business_group_id       => p_business_group_id
        ,p_effective_start_date    => l_effective_start_date
        ,p_effective_end_date      => l_effective_end_date
        ,p_object_version_number   => l_object_version_number
        ,p_effective_date          => p_effective_date
        ,p_datetrack_mode          => l_datetrack_mode
        ,p_multi_row_validate      => false                     --??
        ,p_source                  => null                      --?
        ,p_enrt_cvg_thru_dt        => p_enrt_cvg_thru_dt        --?
        ,p_mode                    => null);                    --?
     --
   end if; --End of if(l_enroll_flag)
   --
   hr_utility.set_location('Leaving:'||l_proc, 20);
   --
 exception when others then
   raise ;
 end enrollment_information_detail;
--
-- --------------------------------------------------------------------------------
-- |-----------------------------< ELECTION_INFORMATION >-------------------------|
-- -------------------------------------------------------------------------------+
--
  procedure post_enrollment
  (p_validate               in boolean default false
  ,p_person_id              in number
  ,p_ler_id                 in number
  ,p_life_event_date        in date
  ,p_pgm_id                 in number default null
  ,p_pl_id                  in number default null
  -- ,p_flx_cr_flag            in varchar2 default 'N'
  ,p_proc_cd                in varchar2 default null
  ,p_business_group_id      in number
  ,p_effective_date         in date ) is
   --
   l_proc                   varchar2(60) := 'ben_process_enrollment.post_enrollment';
   --
   cursor c_pgm is
     select pgm_typ_cd
       from ben_pgm_f pgm
      where pgm.pgm_id = p_pgm_id
        and p_life_event_date between pgm.effective_start_date
                                  and pgm.effective_end_date ;
   --
   cursor c_pil is
     select pil.per_in_ler_id
      from  ben_per_in_ler pil
     where  pil.ler_id  =p_ler_id
       and  pil.person_id = p_person_id
       and  pil.lf_evt_ocrd_dt = p_life_event_date
       and  pil.per_in_ler_stat_cd = 'STRTD' ;
   --
   l_per_in_ler_id   NUMBER(15);
   l_pgm_typ_cd      hr_lookups.lookup_code%TYPE;
   l_flx_cr_flag     VARCHAR2(30) := 'N';
   --
  begin
    --
    hr_utility.set_location('Entering:'||l_proc, 20);
    --
    IF p_pgm_id IS NOT NULL THEN
      OPEN c_pgm ;
        FETCH c_pgm INTO l_pgm_typ_cd ;
      CLOSE c_pgm;
      --
      IF l_pgm_typ_cd in ('FLEX','FPC')  THEN
        --
        l_flx_cr_flag := 'Y';
        --
      END IF;
      --
    END IF;
    --
    OPEN c_pil;
      FETCH c_pil INTO l_per_in_ler_id;
      --
      IF c_pil%NOTFOUND THEN
        CLOSE c_pil ;
        --
        if g_debug then
           hr_utility.set_location('BEN_94534_PIL_NOT_FOUND'|| to_char(p_person_id),54);
        end if;
        fnd_message.set_name('BEN','BEN_94534_PIL_NOT_FOUND');
        fnd_message.set_token('PROC',l_proc);
        fnd_message.set_token('PERSON_ID',to_char(p_person_id));
        fnd_message.set_token('LER_ID',to_char(p_ler_id));
        fnd_message.set_token('LE_DATE', p_life_event_date);
        fnd_message.raise_error;
        --
      END IF;
      --
    CLOSE c_pil;
    --
    ben_proc_common_enrt_rslt.set_elcn_made_or_asnd_dt
      (p_validate              => p_validate
      ,p_per_in_ler_id         => l_per_in_ler_id
      ,p_pgm_id                => p_pgm_id
      ,p_pl_id                 => p_pl_id
      ,p_enrt_mthd_cd          => 'E'
      ,p_business_group_id     => p_business_group_id
      ,p_effective_date        => p_effective_date);
    --
    ben_prtt_enrt_result_api.multi_rows_edit
      (p_person_id            => p_person_id
      ,p_per_in_ler_id        => l_per_in_ler_id
      ,p_pgm_id               => p_pgm_id
      ,p_business_group_id    => p_business_group_id
      ,p_effective_date       => p_effective_date);
    --
    ben_proc_common_enrt_rslt.process_post_results
      (p_validate             => p_validate
      ,p_person_id            => p_person_id
      ,p_per_in_ler_id        => l_per_in_ler_id
      ,p_flx_cr_flag          => l_flx_cr_flag
      ,p_enrt_mthd_cd         => 'E'
      ,p_business_group_id    => p_business_group_id
      ,p_effective_date       => p_effective_date
      ,p_self_service_flag    => false
      ,p_pgm_id               => p_pgm_id
      ,p_pl_id                => p_pl_id);
    --
    ben_proc_common_enrt_rslt.process_post_enrollment
      (p_validate             => p_validate
      ,p_person_id            => p_person_id
      ,p_per_in_ler_id        => l_per_in_ler_id
      ,p_pgm_id               => p_pgm_id
      ,p_pl_id                => p_pl_id
      ,p_enrt_mthd_cd         => 'E'
      ,p_cls_enrt_flag        => false
      ,p_proc_cd              => p_proc_cd
      ,p_business_group_id    => p_business_group_id
      ,p_effective_date       => p_effective_date);
    --
    hr_utility.set_location('Leaving:'||l_proc, 20);
    --
  exception when others then
    raise ;
  end post_enrollment ;
  --
procedure create_enrollment
  (p_validate               in boolean  default false
  ,p_pgm_id                 in number   default null
  ,p_pl_id                  in number   default null
  ,p_opt_id                 in number   default null
  ,p_ler_id                 in number
  ,p_life_event_date        in date
  ,p_ended_pl_id            in number   default null
  ,p_ended_opt_id           in number   default null
  ,p_ended_bnft_val         in number   default null
  ,p_effective_date         in date
  ,p_person_id              in number
  ,p_bnft_val               in number   default null
  ,p_acty_base_rt_id1       in number   default null
  ,p_rt_val1                in number   default null
  ,p_ann_rt_val1            in number   default null
  ,p_rt_strt_dt1            in date     default null
  ,p_rt_end_dt1             in date     default null
  ,p_acty_base_rt_id2       in number   default null
  ,p_rt_val2                in number   default null
  ,p_ann_rt_val2            in number   default null
  ,p_rt_strt_dt2            in date     default null
  ,p_rt_end_dt2             in date     default null
  ,p_acty_base_rt_id3       in number   default null
  ,p_rt_val3                in number   default null
  ,p_ann_rt_val3            in number   default null
  ,p_rt_strt_dt3            in date     default null
  ,p_rt_end_dt3             in date     default null
  ,p_acty_base_rt_id4       in number   default null
  ,p_rt_val4                in number   default null
  ,p_ann_rt_val4            in number   default null
  ,p_rt_strt_dt4            in date     default null
  ,p_rt_end_dt4             in date     default null
  ,p_business_group_id      in number
  ,p_enrt_cvg_strt_dt       in date     default null
  ,p_enrt_cvg_thru_dt       in date     default null
  ,p_orgnl_enrt_dt          in date     default null
  ,p_proc_cd                in varchar2 default null
  ,p_record_typ_cd          in varchar2 ) IS
  --
  l_proc                   varchar2(60) := 'ben_enrollment_process.create_enrollment' ;
  --
 begin
   --
   hr_utility.set_location('Entering:'||l_proc||':'||p_record_typ_cd, 20);
   --Bug 5259118
   -- IF fnd_global.conc_request_id = -1 THEN
     --
     ben_env_object.init(p_business_group_id  => p_business_group_id,
                         p_effective_date     => p_effective_date,
                         p_thread_id          => 1,
                         p_chunk_size         => 1,
                         p_threads            => 1,
                         p_max_errors         => 1,
                         p_benefit_action_id  => null);
     --
   -- END IF;
   --
   IF upper(p_record_typ_cd) = 'ENROLL' THEN
     --
     enrollment_information_detail
       (p_validate               => p_validate
       ,p_pgm_id                 => p_pgm_id
       ,p_pl_id                  => p_pl_id
       ,p_opt_id                 => p_opt_id
       ,p_ler_id                 => p_ler_id
       ,p_life_event_date        => p_life_event_date
       ,p_ended_pl_id            => p_ended_pl_id
       ,p_ended_opt_id           => p_ended_opt_id
       ,p_effective_date         => p_effective_date
       ,p_person_id              => p_person_id
       ,p_bnft_val               => p_bnft_val
       ,p_acty_base_rt_id1       => p_acty_base_rt_id1
       ,p_rt_val1                => p_rt_val1
       ,p_ann_rt_val1            => p_ann_rt_val1
       ,p_rt_strt_dt1            => p_rt_strt_dt1
       ,p_rt_end_dt1             => p_rt_end_dt1
       ,p_acty_base_rt_id2       => p_acty_base_rt_id2
       ,p_rt_val2                => p_rt_val2
       ,p_ann_rt_val2            => p_ann_rt_val2
       ,p_rt_strt_dt2            => p_rt_strt_dt2
       ,p_rt_end_dt2             => p_rt_end_dt2
       ,p_acty_base_rt_id3       => p_acty_base_rt_id3
       ,p_rt_val3                => p_rt_val3
       ,p_ann_rt_val3            => p_ann_rt_val3
       ,p_rt_strt_dt3            => p_rt_strt_dt3
       ,p_rt_end_dt3             => p_rt_end_dt3
       ,p_acty_base_rt_id4       => p_acty_base_rt_id4
       ,p_rt_val4                => p_rt_val4
       ,p_ann_rt_val4            => p_ann_rt_val4
       ,p_rt_strt_dt4            => p_rt_strt_dt4
       ,p_rt_end_dt4             => p_rt_end_dt4
       ,p_business_group_id      => p_business_group_id
       ,p_enrt_cvg_strt_dt       => p_enrt_cvg_strt_dt
       ,p_enrt_cvg_thru_dt       => p_enrt_cvg_thru_dt
       ,p_orgnl_enrt_dt          => p_orgnl_enrt_dt
       );
     --
   ELSIF upper(p_record_typ_cd) = 'POST' THEN
     --
--NK
--Changes to eliminate summary row in Enrollment Upload Spreadsheet.
--If the record type is POST, this is the last record of the group
--So, first do the enrollment and then run the post enrollment process
     enrollment_information_detail
       (p_validate               => p_validate
       ,p_pgm_id                 => p_pgm_id
       ,p_pl_id                  => p_pl_id
       ,p_opt_id                 => p_opt_id
       ,p_ler_id                 => p_ler_id
       ,p_life_event_date        => p_life_event_date
       ,p_ended_pl_id            => p_ended_pl_id
       ,p_ended_opt_id           => p_ended_opt_id
       ,p_effective_date         => p_effective_date
       ,p_person_id              => p_person_id
       ,p_bnft_val               => p_bnft_val
       ,p_acty_base_rt_id1       => p_acty_base_rt_id1
       ,p_rt_val1                => p_rt_val1
       ,p_ann_rt_val1            => p_ann_rt_val1
       ,p_rt_strt_dt1            => p_rt_strt_dt1
       ,p_rt_end_dt1             => p_rt_end_dt1
       ,p_acty_base_rt_id2       => p_acty_base_rt_id2
       ,p_rt_val2                => p_rt_val2
       ,p_ann_rt_val2            => p_ann_rt_val2
       ,p_rt_strt_dt2            => p_rt_strt_dt2
       ,p_rt_end_dt2             => p_rt_end_dt2
       ,p_acty_base_rt_id3       => p_acty_base_rt_id3
       ,p_rt_val3                => p_rt_val3
       ,p_ann_rt_val3            => p_ann_rt_val3
       ,p_rt_strt_dt3            => p_rt_strt_dt3
       ,p_rt_end_dt3             => p_rt_end_dt3
       ,p_acty_base_rt_id4       => p_acty_base_rt_id4
       ,p_rt_val4                => p_rt_val4
       ,p_ann_rt_val4            => p_ann_rt_val4
       ,p_rt_strt_dt4            => p_rt_strt_dt4
       ,p_rt_end_dt4             => p_rt_end_dt4
       ,p_business_group_id      => p_business_group_id
       ,p_enrt_cvg_strt_dt       => p_enrt_cvg_strt_dt
       ,p_enrt_cvg_thru_dt       => p_enrt_cvg_thru_dt
       ,p_orgnl_enrt_dt          => p_orgnl_enrt_dt
       );
     --
     post_enrollment
     (p_validate               => p_validate
     ,p_person_id              => p_person_id
     ,p_ler_id                 => p_ler_id
     ,p_life_event_date        => p_life_event_date
     ,p_pgm_id                 => p_pgm_id
     ,p_pl_id                  => p_pl_id
     ,p_proc_cd                => p_proc_cd
     ,p_business_group_id      => p_business_group_id
     ,p_effective_date         => p_effective_date );
     --
   ELSE
     --
     if g_debug then
           hr_utility.set_location('BEN_94536_RECORD_TYPE_ERROR'|| to_char(p_person_id),54);
     end if;
     fnd_message.set_name('BEN','BEN_94536_RECORD_TYPE_ERROR');
     fnd_message.set_token('PROC',l_proc);
     fnd_message.set_token('PERSON_ID',p_record_typ_cd);
     fnd_message.raise_error;
     --
   END IF;
   --
exception when others then
  raise ;
end create_enrollment ;
--
procedure process_dependent
  (p_validate               in boolean  default false
  ,p_person_id              in number
  ,p_pgm_id                 in number   default null
  ,p_pl_id                  in number   default null
  ,p_opt_id                 in number   default null
  ,p_ler_id                 in number
  ,p_life_event_date        in date
  ,p_effective_date         in date
  ,p_contact_person_id      in number
  ,p_business_group_id      in number
  ,p_cvg_strt_dt            in date     default null
  ,p_cvg_thru_dt            in date     default null
  ,p_multi_row_actn         in boolean  default false
  ,p_record_typ_cd          in varchar2 ) is
  --
  l_proc                   varchar2(60) := 'ben_enrollment_process.process_dependent';
  --
  l_pil      c_pil%ROWTYPE;
  --
  l_epe     c_epe_oipl%ROWTYPE;
  l_egd     c_egd%ROWTYPE;
  l_dt_mode varchar2(30) := hr_api.g_update;  --5675220
  l_elig_cvrd_dpnt_id number;
  l_dummy_date  date;
  l_ovn         number;
  l_person_id          number := p_person_id;
  l_pgm_id             number := p_pgm_id;
  l_pl_id              number := p_pl_id;
  l_opt_id             number := p_opt_id;
  l_ler_id             number := p_ler_id;
  l_life_event_date    date   := p_life_event_date;
  l_contact_person_id  number := p_contact_person_id;
  l_cvg_strt_dt        date   := p_cvg_strt_dt;
  l_pd_cvg_strt_dt     date ;
  l_cvg_thru_dt        date   := p_cvg_thru_dt;
  l_record_typ_cd      varchar2(30) := p_record_typ_cd;
  l_returned_strt_dt   date ;
  l_returned_end_dt    date ;
  --
begin
  --
  hr_utility.set_location('Entering:'||l_proc, 20);
  --
  --Bug 5259118
  -- IF fnd_global.conc_request_id = -1 THEN
    --
    ben_env_object.init(p_business_group_id  => p_business_group_id,
                         p_effective_date     => p_effective_date,
                         p_thread_id          => 1,
                         p_chunk_size         => 1,
                         p_threads            => 1,
                         p_max_errors         => 1,
                         p_benefit_action_id  => null);
  --
  -- END IF;
  --
  IF l_person_id = hr_api.g_number THEN
    l_person_id := null;
  END IF;
  --
  IF l_pgm_id = hr_api.g_number THEN
    l_pgm_id := null;
  END IF;
  --
  IF l_pl_id = hr_api.g_number THEN
    l_pl_id := null;
  END IF;
  --
  IF l_opt_id = hr_api.g_number THEN
    l_opt_id := null;
  END IF;
  --
  IF l_ler_id = hr_api.g_number THEN
    l_ler_id := null;
  END IF;
  --
  IF l_life_event_date = hr_api.g_date THEN
    l_life_event_date := null;
  END IF;
  --
  IF l_contact_person_id = hr_api.g_number THEN
    l_contact_person_id := null;
  END IF;
  --
  IF l_cvg_strt_dt = hr_api.g_date THEN
    l_cvg_strt_dt := null;
  END IF;
  --
  IF l_cvg_thru_dt = hr_api.g_date THEN
    l_cvg_thru_dt  := null;
  END IF;
  --
  IF l_record_typ_cd = hr_api.g_varchar2 THEN
    l_record_typ_cd := 'ENROLL' ;
  END IF;
  --
  fnd_file.put_line
           (which => fnd_file.log,
            buff  => 'Entering - BEN_ENROLLMENT_PROCESS.PROCESS_DEPENDENT' );
  fnd_file.put_line
           (which => fnd_file.log,
            buff  => 'l_person_id '||l_person_id||' l_pgm_id '||l_pgm_id||' l_pl_id '||l_pl_id);
  --
  fnd_file.put_line
           (which => fnd_file.log,
            buff  => 'l_opt_id '||l_opt_id||' l_ler_id '||l_ler_id);
  fnd_file.put_line
           (which => fnd_file.log,
            buff  => 'l_record_typ_cd '||l_record_typ_cd);
  fnd_file.put_line
           (which => fnd_file.log,
            buff  => 'l_life_event_date '||l_life_event_date||' l_contact_person_id '||l_contact_person_id);
  fnd_file.put_line
           (which => fnd_file.log,
            buff  => 'l_cvg_strt_dt '||l_cvg_strt_dt||' l_cvg_thru_dt '||l_cvg_thru_dt);
  --
  get_pil
    (p_person_id       => l_person_id,
     p_ler_id          => l_ler_id,
     p_life_event_date => l_life_event_date,
     p_pil             => l_pil
     );
  --
  fnd_file.put_line
     (which => fnd_file.log,
      buff  => 'l_pil.per_in_ler_id '||l_pil.per_in_ler_id);
  --Get EPE
  IF l_pil.per_in_ler_id IS NOT NULL THEN
    get_epe
      (p_person_id       => l_person_id,
       p_per_in_ler_id   => l_pil.per_in_ler_id,
       p_life_event_date => l_life_event_date,
       p_opt_id          => l_opt_id,
       p_pl_id           => l_pl_id,
       p_pgm_id          => l_pgm_id,
       p_epe             => l_epe
      ) ;
    fnd_file.put_line
      (which => fnd_file.log,
       buff  => 'l_epe.elig_per_elctbl_chc_id '||l_epe.elig_per_elctbl_chc_id);
      --
    --Find if there is a valid enrollment result exists for this epe and pil
    --If not throw error.
    --
      check_pen
      (p_per_in_ler_id       =>   l_pil.per_in_ler_id,
       p_prtt_enrt_rslt_id   =>   l_epe.prtt_enrt_rslt_id );
    --
    --You can't designate a person if the person is not enrolled in this plan
    --or option in plan.
    --
    --
    IF l_epe.elig_per_elctbl_chc_id IS NOT NULL THEN
      --
      /*
      --Now Get the Depdenent Coverage Start Date derived.
      if l_EPE.DPNT_CVG_STRT_DT_CD is not null then
        --
        --
        ben_determine_date.main
                         (p_cache_mode => false
                         ,p_date_cd => l_epe.dpnt_cvg_strt_dt_cd
                         ,p_per_in_ler_id => l_pil.per_in_ler_id
                         ,p_person_id => p_person_id
                         ,p_pgm_id    => l_epe.pgm_id
                         ,p_pl_id     => l_epe.pl_id
                         ,p_oipl_id   => l_epe.oipl_id
                         ,p_elig_per_elctbl_chc_id => l_epe.elig_per_elctbl_chc_id
                         ,p_business_group_id => p_business_group_id
                         ,p_formula_id     => l_epe.dpnt_cvg_strt_dt_rl
                         ,p_acty_base_rt_id => null
                         ,p_bnfts_bal_id    => null
                         ,p_effective_date => p_effective_date
                         ,p_lf_evt_ocrd_dt  =>null
                         ,p_returned_date  => l_pd_cvg_strt_dt
                         ,p_start_date     => null
                         ,p_param1         => 'CON_PERSON_ID'
                         ,p_param1_value   => p_contact_person_id
                         ,p_parent_person_id=>null
                         ,p_enrt_cvg_end_dt =>null
                         ,p_comp_obj_mode =>true
                         ,p_fonm_cvg_strt_dt  =>null
                         ,p_fonm_rt_strt_dt    =>null
                      --    ,p_cmpltd_dt          =>null
                         );
        --
      end if;
      */
      ben_prtt_enrt_result_api.calc_dpnt_cvg_dt(
         p_calc_end_dt            => true,
         P_calc_strt_dt           => true,
         P_per_in_ler_id          => l_pil.per_in_ler_id,
         p_person_id              => l_person_id,
         p_pgm_id                 => l_pgm_id,
         p_pl_id                  => l_pl_id,
         p_oipl_id                => l_epe.oipl_id,
         p_ptip_id                => l_epe.ptip_id,
         p_ler_id                 => l_ler_id,
         p_elig_per_elctbl_chc_id => l_epe.elig_per_elctbl_chc_id,
         p_business_group_id      => p_business_group_id,
         p_effective_date         => p_effective_date,
         p_enrt_cvg_end_dt        => null,
         p_returned_strt_dt       => l_returned_strt_dt,
         p_returned_end_dt        => l_returned_end_dt);
      --
      IF l_cvg_thru_dt IS NULL THEN
         l_returned_end_dt := NULL;
      ELSIF l_cvg_thru_dt <> l_returned_end_dt THEN
         --Make entry in log file indicating mismatch between the supplied and plan design Coverge Through Date.
           fnd_file.put_line
               (which => fnd_file.log,
                buff  => 'Mismatch found between supplied and plan design Dependant Coverage Through Date. Using the date in Plan Design: '||l_returned_end_dt);
         NULL;
      end if;
      --
      IF l_cvg_strt_dt is NULL THEN
        NULL;
      ELSIF l_cvg_strt_dt <> l_returned_strt_dt THEN
        IF l_cvg_thru_dt IS NULL THEN --Check for thru date null again,so that start date warning is printed only when enrolling dependants.
          --Make entry in log file indicating mismatch between the supplied and plan design Coverge Start Date.
          fnd_file.put_line
              (which => fnd_file.log,
               buff  => 'Mismatch found between supplied and plan design Dependant Coverage Start Date. Using the date in Plan Design: '||l_returned_strt_dt);
        END IF;
      END IF;
      --
      /*
      if l_cvg_strt_dt is null then
         --
         l_cvg_strt_dt := l_pd_cvg_strt_dt;
         --
      end if;
      */
      --
      IF l_record_typ_cd = 'ENROLL' THEN
        --
        get_egd
          (p_per_in_ler_id          => l_pil.per_in_ler_id,
           p_dpnt_person_id         => l_contact_person_id,
           p_elig_per_elctbl_chc_id => l_epe.elig_per_elctbl_chc_id,
           p_egd                    => l_egd
          );
        --
        fnd_file.put_line
          (which => fnd_file.log,
           buff  => ' l_egd.elig_dpnt_id '||l_egd.elig_dpnt_id);
        --
        IF l_egd.elig_dpnt_id IS NOT NULL THEN
          --
          ben_elig_dpnt_api.process_dependent(
             p_validate              => p_validate
            ,p_elig_dpnt_id          => l_egd.elig_dpnt_id
            ,p_business_group_id     => p_business_group_id
            ,p_effective_date        => p_effective_date
            ,p_cvg_strt_dt           => l_returned_strt_dt -- l_cvg_strt_dt --If in EGD take it
            ,p_cvg_thru_dt           => l_returned_end_dt  -- NVL(l_returned_end_dt,l_egd.elig_thru_dt)
            ,p_datetrack_mode        => l_dt_mode
            ,p_elig_cvrd_dpnt_id     => l_elig_cvrd_dpnt_id
            ,p_effective_start_date  => l_dummy_date
            ,p_effective_end_date    => l_dummy_date
            ,p_object_version_number => l_ovn
            ,p_multi_row_actn        => p_multi_row_actn);
          --
        END IF;
        --
      ELSIF l_record_typ_cd = 'POST' THEN
--NK
--Changes to eliminate summary row in Enrollment Upload Spreadsheet.
--If the record type is POST, this is the last record of the group
--So, first process the dependent information and then run the post process.
        --
        get_egd
          (p_per_in_ler_id          => l_pil.per_in_ler_id,
           p_dpnt_person_id         => l_contact_person_id,
           p_elig_per_elctbl_chc_id => l_epe.elig_per_elctbl_chc_id,
           p_egd                    => l_egd
          );
        --
        fnd_file.put_line
          (which => fnd_file.log,
           buff  => ' l_egd.elig_dpnt_id '||l_egd.elig_dpnt_id);
        --
        IF l_egd.elig_dpnt_id IS NOT NULL THEN
          --
          ben_elig_dpnt_api.process_dependent(
             p_validate              => p_validate
            ,p_elig_dpnt_id          => l_egd.elig_dpnt_id
            ,p_business_group_id     => p_business_group_id
            ,p_effective_date        => p_effective_date
            ,p_cvg_strt_dt           => l_returned_strt_dt -- l_cvg_strt_dt --If in EGD take it
            ,p_cvg_thru_dt           => l_returned_end_dt -- NVL(l_returned_end_dt,l_egd.elig_thru_dt) --If Entered take it
            ,p_datetrack_mode        => l_dt_mode
            ,p_elig_cvrd_dpnt_id     => l_elig_cvrd_dpnt_id
            ,p_effective_start_date  => l_dummy_date
            ,p_effective_end_date    => l_dummy_date
            ,p_object_version_number => l_ovn
            ,p_multi_row_actn        => p_multi_row_actn);
          --
        END IF;
        --
        -- POST PROCESS
        --
        IF l_epe.prtt_enrt_rslt_id IS NOT NULL THEN
          --
          ben_elig_cvrd_dpnt_api.dpnt_actn_items(
             p_prtt_enrt_rslt_id => l_epe.prtt_enrt_rslt_id,
             p_elig_cvrd_dpnt_id => null,
             p_effective_date    => p_effective_date,
             p_business_group_id => p_business_group_id,
             p_datetrack_mode    => l_dt_mode);
          --
          ben_elig_cvrd_dpnt_api.chk_max_num_dpnt_for_pen(
             p_prtt_enrt_rslt_id => l_epe.prtt_enrt_rslt_id,
             p_effective_date    => p_effective_date,
             p_business_group_id => p_business_group_id);
          --
        END IF;
        --
      ELSE
        --Throw Error  invalid record type
        if g_debug then
           hr_utility.set_location('BEN_94536_RECORD_TYPE_ERROR'|| to_char(p_person_id),54);
        end if;
        fnd_message.set_name('BEN','BEN_94536_RECORD_TYPE_ERROR');
        fnd_message.set_token('PROC',l_proc);
        fnd_message.set_token('PERSON_ID',l_record_typ_cd);
        fnd_message.raise_error;
        --
      END IF;
      --
    END IF;
  ELSE
    if g_debug then
       hr_utility.set_location('BEN_94534_PIL_NOT_FOUND'|| to_char(p_person_id),54);
    end if;
    fnd_message.set_name('BEN','BEN_94534_PIL_NOT_FOUND');
    fnd_message.set_token('PROC',l_proc);
    fnd_message.set_token('PERSON_ID',to_char(p_person_id));
    fnd_message.set_token('LER_ID',to_char(p_ler_id));
    fnd_message.set_token('LE_DATE', p_life_event_date);
    fnd_message.raise_error;
    --
  END IF;
  --
  exception when others then
  --
  raise;
  --
end process_dependent;
--
-- --------------------------------------------------------------------------------
-- |-----------------------------< PROCESS_BENEFICIARY >-------------------------|
-- -------------------------------------------------------------------------------+
procedure process_beneficiary
  (p_validate               in boolean  default false
  ,p_person_id              in number
  ,p_pgm_id                 in number   default null
  ,p_pl_id                  in number   default null
  ,p_opt_id                 in number   default null
  ,p_bnft_val               in number   default null
  ,p_ler_id                 in number
  ,p_life_event_date        in date
  ,p_effective_date         in date
  ,p_bnf_person_id          in number
  ,p_business_group_id      in number
  ,p_dsgn_strt_dt           in date     default null
  ,p_dsgn_thru_dt           in date     default null
  ,p_prmry_cntngnt_cd       in varchar2
  ,p_pct_dsgd_num           in number
  ,p_amt_dsgd_val           in number    default null
  ,p_amt_dsgd_uom           in varchar2  default null
  ,p_addl_instrn_txt        in varchar2  default null
  ,p_multi_row_actn         in boolean   default true
  ,p_organization_id        in number    default null
  ,p_ttee_person_id         in number    default null
  ,p_record_typ_cd          in varchar2 ) is
  --
  l_proc                   varchar2(60) := 'ben_enrollment_information_detail.process_beneficiary';
  l_prtt_enrt_rslt_id      number;
  l_object_version_number  number;
  l_pl_bnf_id              number;
  l_dummy_date             date;
  l_pil              c_pil%ROWTYPE;
  l_epe              c_epe_oipl%ROWTYPE;
  l_bnf              c_bnf%ROWTYPE;
  l_dt_mode          varchar2(30);
  l_person_id        number     := p_person_id;
  l_dsgn_strt_dt     date       := p_dsgn_strt_dt;
  l_dsgn_thru_dt     date       := p_dsgn_thru_dt;
  l_bnft_val         number     := p_bnft_val;
  l_pgm_id           number     := p_pgm_id;
  l_pl_id            number     := p_pl_id;
  l_opt_id           number     := p_opt_id;
  l_ler_id           number     := p_ler_id;
  l_life_event_date  date       := p_effective_date;
  l_prmry_cntngnt_cd varchar2(30) := p_prmry_cntngnt_cd;
  l_bnf_person_id    number     := p_bnf_person_id;
  l_pct_dsgd_num     number     :=  p_pct_dsgd_num;
  l_amt_dsgd_val     ben_pl_bnf_f.amt_dsgd_val%TYPE    := p_amt_dsgd_val;
  l_amt_dsgd_uom     ben_pl_bnf_f.amt_dsgd_uom%TYPE    := p_amt_dsgd_uom;
  l_addl_instrn_txt  ben_pl_bnf_f.addl_instrn_txt%TYPE := p_addl_instrn_txt;
  l_organization_id  number     := p_organization_id;
  l_ttee_person_id   number     := p_ttee_person_id;
  l_bnf_actn_warning boolean;
  l_suspend_flag     varchar2(30);
  l_rslt_object_version_number number(9);
  l_record_typ_cd      varchar2(30) := p_record_typ_cd;
  --
  cursor get_rslt_ovn_c is
   select object_version_number,
          sspndd_flag
   from   ben_prtt_enrt_rslt_f
   where  prtt_enrt_rslt_id = l_prtt_enrt_rslt_id
   and    business_group_id = p_business_group_id
   and    p_effective_date
          between effective_start_date and effective_end_date;
  --
begin
  hr_utility.set_location('Entering:'||l_proc, 20);
  --
  --Bug 5259118
  -- IF fnd_global.conc_request_id = -1 THEN
    --
    ben_env_object.init(p_business_group_id  => p_business_group_id,
                         p_effective_date     => p_effective_date,
                         p_thread_id          => 1,
                         p_chunk_size         => 1,
                         p_threads            => 1,
                         p_max_errors         => 1,
                         p_benefit_action_id  => null);
  --
  -- END IF;
  --
  IF l_dsgn_strt_dt = hr_api.g_date THEN
    l_dsgn_strt_dt := NULL;
  END IF;
  --
  IF l_dsgn_thru_dt = hr_api.g_date THEN
    l_dsgn_thru_dt := NULL;
  END IF;
  --
  IF l_bnft_val = hr_api.g_number THEN
    l_bnft_val := null;
  END IF;
  --
  IF l_amt_dsgd_val = hr_api.g_number THEN
    l_amt_dsgd_val := null;
  END IF;
  --
  IF l_amt_dsgd_uom = hr_api.g_varchar2 THEN
    l_amt_dsgd_uom := null;
  END IF;
  --
  IF l_addl_instrn_txt = hr_api.g_varchar2 THEN
    l_addl_instrn_txt := null;
  END IF;
  --
  IF l_organization_id = hr_api.g_number THEN
    l_organization_id := NULL ;
  END IF;
  --
  IF l_ttee_person_id = hr_api.g_number THEN
    l_ttee_person_id := NULL;
  END IF;
  --
  IF l_record_typ_cd = hr_api.g_varchar2 THEN
    l_record_typ_cd := 'ENROLL';
  END IF;
  --
  fnd_file.put_line
           (which => fnd_file.log,
            buff  => 'Entering - ben_enrollment_process.process_beneficiary' );
  --
  fnd_file.put_line
           (which => fnd_file.log,
            buff  => 'l_person_id '||l_person_id||' l_pgm_id '||l_pgm_id||' l_pl_id '||l_pl_id);
  --
  fnd_file.put_line
           (which => fnd_file.log,
            buff  => 'l_opt_id '||l_opt_id||' l_bnft_val '||l_bnft_val||' l_ler_id '||l_ler_id);
  fnd_file.put_line
           (which => fnd_file.log,
            buff  => 'l_pct_dsgd_num '||l_pct_dsgd_num||' l_amt_dsgd_val '||l_amt_dsgd_val);
  fnd_file.put_line
           (which => fnd_file.log,
            buff  => 'l_addl_instrn_txt '||l_addl_instrn_txt);
  fnd_file.put_line
           (which => fnd_file.log,
            buff  => 'l_organization_id '||l_organization_id||' l_ttee_person_id '||l_ttee_person_id);
  fnd_file.put_line
           (which => fnd_file.log,
            buff  => 'l_life_event_date '||l_life_event_date||' l_bnf_person_id '||l_bnf_person_id);
  fnd_file.put_line
           (which => fnd_file.log,
            buff  => 'l_dsgn_strt_dt '||l_dsgn_strt_dt||' l_dsgn_thru_dt '||l_dsgn_thru_dt);
  fnd_file.put_line
           (which => fnd_file.log,
	    buff  => 'l_record_typ_cd '||l_record_typ_cd);
  --
  get_pil
    (p_person_id       => l_person_id,
     p_ler_id          => l_ler_id,
     p_life_event_date => l_life_event_date,
     p_pil             => l_pil
     );
  --
  --Get Ended Enrollment Result
  get_current_pen
       (p_effective_date    => p_effective_date,
        p_life_event_date   => l_life_event_date,
        p_person_id         => l_person_id,
        p_pgm_id            => l_pgm_id,
        p_pl_id             => l_pl_id,
        p_opt_id            => l_opt_id,
        p_bnft_val          => l_bnft_val,
        p_prtt_enrt_rslt_id => l_prtt_enrt_rslt_id,
	p_object_version_number => l_object_version_number
       );
  --
  IF l_prtt_enrt_rslt_id IS NULL THEN
     --
     fnd_message.set_name('BEN','BEN_94614_NO_PEN_FOR_BNF');
     fnd_message.set_token('PROC',l_proc);
     fnd_message.set_token('PERSON_ID',to_char(p_person_id));
     fnd_message.set_token('PGM_ID',to_char(p_pgm_id));
     fnd_message.set_token('PL_ID',to_char(p_pl_id));
     fnd_message.set_token('OPT_ID',to_char(p_opt_id));
     fnd_message.set_token('PER_IN_LER_ID',to_char(l_pil.per_in_ler_id));
     fnd_message.set_token('LE_DATE',p_life_event_date);
     fnd_message.raise_error;
     --
  END IF;
  --
  open get_rslt_ovn_c;
  fetch get_rslt_ovn_c into l_rslt_object_version_number,
                            l_suspend_flag;
  close get_rslt_ovn_c;
  --
  IF l_pil.per_in_ler_id IS NULL THEN
     --
     if g_debug then
        hr_utility.set_location('BEN_94534_PIL_NOT_FOUND'|| to_char(p_person_id),54);
     end if;
     fnd_message.set_name('BEN','BEN_94534_PIL_NOT_FOUND');
     fnd_message.set_token('PROC',l_proc);
     fnd_message.set_token('PERSON_ID',to_char(p_person_id));
     fnd_message.set_token('LER_ID',to_char(p_ler_id));
     fnd_message.set_token('LE_DATE', p_life_event_date);
     fnd_message.raise_error;
     --
  END IF ;
  --
  get_pbn
    (p_effective_date     => p_effective_date,
     p_bnf_person_id      => l_bnf_person_id,
     p_organization_id    => l_organization_id,
     p_prtt_enrt_rslt_id  => l_prtt_enrt_rslt_id,
     p_bnf                => l_bnf
    );
  --
  IF l_bnf.pl_bnf_id IS NULL and l_prtt_enrt_rslt_id IS NOT NULL and
    l_dsgn_thru_dt IS NULL THEN
    --
    ben_plan_beneficiary_api.create_plan_beneficiary
    (  p_validate                =>    p_validate
      ,p_pl_bnf_id               =>    l_pl_bnf_id
      ,p_effective_start_date    =>    l_dummy_date
      ,p_effective_end_date      =>    l_dummy_date
      ,p_business_group_id       =>    p_business_group_id
      ,p_prtt_enrt_rslt_id       =>    l_prtt_enrt_rslt_id
      ,p_bnf_person_id           =>    l_bnf_person_id
      ,p_organization_id         =>    l_organization_id
      ,p_prmry_cntngnt_cd        =>    l_prmry_cntngnt_cd
      ,p_pct_dsgd_num            =>    l_pct_dsgd_num
      ,p_amt_dsgd_val            =>    l_amt_dsgd_val
      ,p_amt_dsgd_uom            =>    l_amt_dsgd_uom
      ,p_dsgn_strt_dt            =>    l_dsgn_strt_dt
      ,p_dsgn_thru_dt            =>    l_dsgn_thru_dt
      ,p_object_version_number   =>    l_object_version_number
      ,p_per_in_ler_id           =>    l_pil.per_in_ler_id
      ,p_effective_date          =>    p_effective_date
      ,p_multi_row_actn          =>    p_multi_row_actn
    );
    --
  ELSIF l_bnf.pl_bnf_id IS NOT NULL and l_dsgn_thru_dt IS NULL THEN
    --
    IF l_bnf.effective_start_date < p_effective_date THEN
       l_dt_mode := hr_api.g_update ;
    ELSE
      l_dt_mode := hr_api.g_correction ;
    END IF ;
    --
    ben_plan_beneficiary_api.update_plan_beneficiary
    (  p_validate                =>    p_validate
      ,p_pl_bnf_id               =>    l_bnf.pl_bnf_id
      ,p_effective_start_date    =>    l_dummy_date
      ,p_effective_end_date      =>    l_dummy_date
      ,p_business_group_id       =>    p_business_group_id
      ,p_prtt_enrt_rslt_id       =>    l_prtt_enrt_rslt_id
      ,p_bnf_person_id           =>    l_bnf_person_id
      ,p_organization_id         =>    l_organization_id
      ,p_prmry_cntngnt_cd        =>    l_prmry_cntngnt_cd
      ,p_pct_dsgd_num            =>    l_pct_dsgd_num
      ,p_amt_dsgd_val            =>    l_amt_dsgd_val
      ,p_amt_dsgd_uom            =>    l_amt_dsgd_uom
      ,p_dsgn_strt_dt            =>    l_dsgn_strt_dt
      ,p_dsgn_thru_dt            =>    l_dsgn_thru_dt
      ,p_object_version_number   =>    l_bnf.object_version_number
      ,p_per_in_ler_id           =>    l_pil.per_in_ler_id
      ,p_effective_date          =>    p_effective_date
      ,p_datetrack_mode          =>    l_dt_mode
      ,p_multi_row_actn          =>    p_multi_row_actn
      );
    --
  ELSIF l_bnf.pl_bnf_id IS NOT NULL AND l_dsgn_thru_dt IS NOT NULL THEN
    --
    IF l_bnf.effective_start_date < p_effective_date THEN
       l_dt_mode := hr_api.g_update ;
       ben_plan_beneficiary_api.update_plan_beneficiary
       (  p_validate                =>    p_validate
         ,p_pl_bnf_id               =>    l_bnf.pl_bnf_id
         ,p_effective_start_date    =>    l_dummy_date
         ,p_effective_end_date      =>    l_dummy_date
         ,p_business_group_id       =>    p_business_group_id
         ,p_prtt_enrt_rslt_id       =>    l_prtt_enrt_rslt_id
         ,p_bnf_person_id           =>    l_bnf_person_id
         ,p_organization_id         =>    l_organization_id
         ,p_prmry_cntngnt_cd        =>    l_prmry_cntngnt_cd
         ,p_pct_dsgd_num            =>    l_pct_dsgd_num
         ,p_amt_dsgd_val            =>    l_amt_dsgd_val
         ,p_amt_dsgd_uom            =>    l_amt_dsgd_uom
         ,p_dsgn_strt_dt            =>    l_dsgn_strt_dt
         ,p_dsgn_thru_dt            =>    l_dsgn_thru_dt
         ,p_object_version_number   =>    l_bnf.object_version_number
         ,p_per_in_ler_id           =>    l_pil.per_in_ler_id
         ,p_effective_date          =>    p_effective_date
         ,p_datetrack_mode          =>    l_dt_mode
         ,p_multi_row_actn          =>    p_multi_row_actn
      );
      --
    ELSE
      --
      l_dt_mode := hr_api.g_zap ;
      ben_plan_beneficiary_api.delete_plan_beneficiary
        (p_validate                =>    p_validate
        ,p_pl_bnf_id               =>    l_bnf.pl_bnf_id
        ,p_effective_start_date    =>    l_dummy_date
        ,p_effective_end_date      =>    l_dummy_date
        ,p_business_group_id       =>    p_business_group_id
        ,p_object_version_number   =>    l_bnf.object_version_number
        ,p_effective_date          =>    p_effective_date
        ,p_datetrack_mode          =>    l_dt_mode
        ,p_multi_row_actn          =>    true
        );
    END IF;
    --
  ELSE
    --Bad case why are we here ???
    fnd_file.put_line
           (which => fnd_file.log,
            buff  => 'Nothing happended... something wrong...');
     fnd_message.set_name('BEN','BEN_94615_BNF_WRONG_IF');
     fnd_message.set_token('PROC',l_proc);
     fnd_message.set_token('PERSON_ID',to_char(p_person_id));
     fnd_message.set_token('PGM_ID',to_char(p_pgm_id));
     fnd_message.set_token('PL_ID',to_char(p_pl_id));
     fnd_message.set_token('OPT_ID',to_char(p_opt_id));
     fnd_message.set_token('PER_IN_LER_ID',to_char(l_pil.per_in_ler_id));
     fnd_message.set_token('LE_DATE',p_life_event_date);
     fnd_message.raise_error;
     --
  END IF;
  --
--  IF l_prtt_enrt_rslt_id IS NOT NULL THEN
  IF l_record_typ_cd = 'POST' THEN
    --
    fnd_file.put_line
           (which => fnd_file.log,
            buff  => 'Calling ben_plan_beneficiary_api.bnf_actn_items');
    --
    ben_plan_beneficiary_api.bnf_actn_items(
       p_prtt_enrt_rslt_id => l_prtt_enrt_rslt_id
      ,p_pl_bnf_id         => l_bnf.pl_bnf_id
      ,p_effective_date    => p_effective_date
      ,p_business_group_id => p_business_group_id
      ,p_validate          => p_validate
      ,p_datetrack_mode    => NULL);

/*    ben_enrollment_action_items.process_bnf_actn_items(
                    p_prtt_enrt_rslt_id          => l_prtt_enrt_rslt_id
                   ,p_rslt_object_version_number => l_rslt_object_version_number
                   ,p_effective_date             => trunc(p_effective_date)
                   ,p_business_group_id          => p_business_group_id
                   ,p_validate                   => p_validate
                   ,p_datetrack_mode             => NULL
                   ,p_suspend_flag               => l_suspend_flag
                   ,p_bnf_actn_warning           => l_bnf_actn_warning
                   );
*/
    --
    --
  END IF;
  --
 end process_beneficiary ;
--
end ben_enrollment_process;

/
