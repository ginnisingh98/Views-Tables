--------------------------------------------------------
--  DDL for Package Body BEN_DETERMINE_CHC_CTFN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_DETERMINE_CHC_CTFN" as
/* $Header: benchctf.pkb 120.1.12010000.2 2009/05/29 05:32:30 sallumwa ship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation                  |
|			   Redwood Shores, California, USA                     |
|			        All rights reserved.	                       |
+==============================================================================+
Name:
    Determine choice certifications.
Purpose:
    This process determines what certifications are necessary for an election and
    then writes them to elctbl_chc_ctfn.
History:
     Date             Who        Version    What?
     ----             ---        -------    -----
     10 Feb 99        T Guy       115.0     Created.
     26 Feb 99        T Guy       115.1     Removed control m's
     29 Mar 99        T Guy       115.2     Fixed cursors to use
                                            local var's instead of referencing
                                            for loop cursor
     31 Mar 99        T Guy       115.3     Added checking for crntly enrolled
                                            if so then do not create ctfn's
                                            changed ben_per_in_ler_f to a non
                                            date tracked table and fixed approp.
                                            cursors
     13 Apr 99        T Guy       115.4     Fixed ben_elig_per_elctbl_chc api
                                            call
     28 Apr 99        Shdas       115.5     Added more contexts to rule calls.
     30 Apr 99        lmcdonal    115.6     Add check for per-in-ler status.
     04 May 99        Shdas       115.7     Added jurisdiction code.
     14 May 99        T Guy       115.8     is to as
     15 Jul 99        mhoyes      115.9   - Added new trace messages.
                                          - Replaced all +0s
     20-JUL-99        Gperry      115.10    genutils -> benutils package
                                            rename.
     20-JUL-99        mhoyes      115.11    Added new trace messages.
     30-AUG-99        tguy        115.12    fixed choice object version
                                            number problem in get_ecf_ctfn
     01-Sep-99        tguy        115.13    fixed choice object version
                                            number for get_ler_ctfns
     07-Sep-99        tguy        115.14    fixed call to pay_mag_utils.
                                                  lookup_jurisdiction_code
     02-Nov-99        maagrawa    115.15    Modified to write enrt ctfns
                                            for level jumping restrictions.
                                            Major changes in the package
                                            structure.
     15-Nov-99        mhoyes      115.16  - Added new trace messages.
     18-Nov-99        mhoyes      115.17  - Added new trace messages.
     18-Nov-99        gperry      115.18    Fixed error messages.
     18-Nov-99        gperry      115.19    p_elig_per_elctbl_chc_id passed to
                                            formula.
     24-Jan-00        maagrawa    115.20    Create certification defined at
                                            life event level and the comp.
                                            object level. Do not use exclude
                                            flag at life event level.
     31-Mar-00        mmogel      115.21    Changed the message number in the
                                            message name BEN_91382_PACKAGE_PARAM_
                                            NULL from 91382 to 91832
     06-APR-00        pbodla      115.22  - Bug 3294/1096790 When  formula called
                                            in write_ctfn enrt_ctfn_typ_cd passed
                                            as context. To access DBI's on
                                            ben_elctbl_chc_ctfn.
     09-May-00        lmcdonal    115.23    If a choice already has the ctfn type
                                            attached, don't write another one.
     14-May-00        gperry      115.24    Replaced header wiped by previous
                                            version.
     05-Jun-00        stee        115.25    Change to process one electable
                                            choice at a time.  Previously, it
                                            was called after all choices were
                                            created. WWBug 1308629.
     07-AUG-00        Tmathers    115.26    moved header 1 line wwbug 1374473.
     30-AUG-00        stee        115.27    Backport of 115.24 with wwbug
                                            1374473 fix. wwbug 1391217.
     30-AUG-00        stee        115.28    Leapfrog of 115.26. wwbug 1391217.
     24-OCT-00        gperry      115.29    Write certficications for all
                                            coverages that break max wout cert
                                            value. Fixes WWBUG 1427477.
     07-Nov-00        mhoyes      115.30  - Phased out main.c_epe.
                                          - Referenced comp object loop.
     21-NOV-00        jcarpent    115.31  - Close cursor missing.
     27-Aug-01        pbodla      115.32  - bug:1949361 jurisdiction code is
                                            derived inside benutils.formula.
     30-Apr-02        kmahendr    115.33  - Added token to message 91832.
     08-Jun-02        pabodla     115.34    Do not select the contingent worker
                                            assignment when assignment data is
                                            fetched.
     19-AUg-04        kmahendr    115.35    Optional certification changes
     15-nov-04        kmahendr    115.36    Unrest. enh changes
     21-feb-05        kmahendr    115.37    Bug#4198774 - mode checked for ctfn
     28-Feb-05        kmahendr    115.38    Bug#4175303 - certification is written only
                                            for one level
     12 Sep 05        ikasire     115.40    Added new procedure update_susp_if_ctfn_flag
     29-May-09        sallumwa    115.41    Bug 7701140 : Initialized the dummy variables
                                            in the electbl choice cert loop.

*/
-----------------------------------------------------------------------------------
--
--	Globals
--
g_package varchar2(80) := 'ben_determine_chc_ctfn';
--
g_ctfn_created     boolean := false;
g_mode             varchar2(1);
--
----------------------------------------------------------------
--
--  Write ELCTBL_CHC_CTFN records
--
----------------------------------------------------------------
procedure write_ctfn(p_elig_per_elctbl_chc_id in number,
                     p_enrt_bnft_id           in number default null,
                     p_enrt_ctfn_typ_cd       in varchar2,
                     p_rqd_flag               in varchar2,
                     p_ctfn_rqd_when_rl       in number,
                     p_business_group_id      in number,
                     p_effective_date         in date,
                     p_assignment_id          in number,
                     p_organization_id        in number,
                     p_jurisdiction_code      in varchar2,
                     p_pgm_id                 in number,
                     p_pl_id                  in number,
                     p_pl_typ_id              in number,
                     p_opt_id                 in number,
                     p_ler_id                 in number,
                     p_susp_if_ctfn_not_prvd_flag in varchar2 default 'Y',
                     p_ctfn_determine_cd      in varchar2  default null,
                     p_mode                   in varchar2 ) is
--
l_package               varchar2(80)      := g_package||'.write_ctfn ';
l_ler_ctfn_rqd          ff_exec.outputs_t;
l_elctbl_chc_ctfn_id    number;
l_object_version_number number;
l_write_ctfn            boolean           := false;

cursor c1 is
  select 'x'
  from ben_elctbl_chc_ctfn
  where elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id
  and   enrt_ctfn_typ_cd       = p_enrt_ctfn_typ_cd
  and   nvl(enrt_bnft_id,-1) = nvl(p_enrt_bnft_id,-1);
  l_dummy varchar2(1);

Begin

  hr_utility.set_location ('Entering '||l_package,5);
  hr_utility.set_location ('p_elig_per_elctbl_chc_id '||
      to_char(p_elig_per_elctbl_chc_id),5);
  hr_utility.set_location ('p_enrt_bnft_id '||
      to_char(p_enrt_bnft_id),5);
  hr_utility.set_location ('p_enrt_ctfn_typ_cd '||
      p_enrt_ctfn_typ_cd,5);

  -- if this certificaion type cd has already been attached to the choice,
  -- don't attach another one.  This prevents problems with bad plan
  -- design setup.
  open c1;
  fetch c1 into l_dummy;
  if c1%FOUND  and p_mode not in ('U','R') then
    hr_utility.set_location ('found ctfn ',5);
    close c1;
  else
    close c1;
    l_write_ctfn := false;

    if p_ctfn_rqd_when_rl is not null then

       l_ler_ctfn_rqd := benutils.formula
                        (p_formula_id        => p_ctfn_rqd_when_rl,
                         p_effective_date    => p_effective_date,
                         p_business_group_id => p_business_group_id,
                         p_assignment_id     => p_assignment_id,
                         p_organization_id   => p_organization_id,
                         p_pgm_id            => p_pgm_id,
                         p_pl_id             => p_pl_id,
                         p_pl_typ_id         => p_pl_typ_id,
                         p_opt_id            => p_opt_id,
                         p_ler_id            => p_ler_id,
                         p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id,
                         p_enrt_ctfn_typ_cd  => p_enrt_ctfn_typ_cd,
                         p_jurisdiction_code => p_jurisdiction_code);

       if l_ler_ctfn_rqd.exists(1) and
            l_ler_ctfn_rqd(l_ler_ctfn_rqd.first).value = 'Y' then
            l_write_ctfn := true;
       end if;

    else
       l_write_ctfn := true;
    end if;

    if l_write_ctfn then

       -- This global variable used to determine whether to update the
       -- ctfn_rqd_flag on the choice.
       --
       g_ctfn_created := true;
       --
       if p_mode in ('U','R') then
         --
         l_elctbl_chc_ctfn_id := ben_manage_unres_life_events.ecc_exists
                           ( p_ELIG_PER_ELCTBL_CHC_ID =>p_elig_per_elctbl_chc_id
                            ,p_enrt_bnft_id           =>p_enrt_bnft_id
                            ,p_ENRT_CTFN_TYP_CD       =>p_enrt_ctfn_typ_cd
                           );
       end if;
       if l_elctbl_chc_ctfn_id is not null then
         --
         ben_manage_unres_life_events.update_enrt_ctfn
               (p_elctbl_chc_ctfn_id      => l_elctbl_chc_ctfn_id,
                p_enrt_ctfn_typ_cd        => p_enrt_ctfn_typ_cd,
                p_rqd_flag                => p_rqd_flag,
                p_elig_per_elctbl_chc_id  => p_elig_per_elctbl_chc_id,
                p_enrt_bnft_id            => p_enrt_bnft_id,
                p_susp_if_ctfn_not_prvd_flag => p_susp_if_ctfn_not_prvd_flag,
                p_ctfn_determine_cd          =>  p_ctfn_determine_cd,
                p_business_group_id       => p_business_group_id,
                p_object_version_number   => l_object_version_number,
                p_effective_date          => p_effective_date,
                p_request_id              => fnd_global.conc_request_id,
                p_program_application_id  => fnd_global.prog_appl_id,
                p_program_id              => fnd_global.conc_program_id,
                p_program_update_date     => sysdate);
          --
       else
         --
         ben_eltbl_chc_ctfn_api.create_eltbl_chc_ctfn(
                p_elctbl_chc_ctfn_id      => l_elctbl_chc_ctfn_id,
                p_enrt_ctfn_typ_cd        => p_enrt_ctfn_typ_cd,
                p_rqd_flag                => p_rqd_flag,
                p_elig_per_elctbl_chc_id  => p_elig_per_elctbl_chc_id,
                p_enrt_bnft_id            => p_enrt_bnft_id,
                p_susp_if_ctfn_not_prvd_flag => p_susp_if_ctfn_not_prvd_flag,
                p_ctfn_determine_cd          =>  p_ctfn_determine_cd,
                p_business_group_id       => p_business_group_id,
                p_object_version_number   => l_object_version_number,
                p_effective_date          => p_effective_date,
                p_request_id              => fnd_global.conc_request_id,
                p_program_application_id  => fnd_global.prog_appl_id,
                p_program_id              => fnd_global.conc_program_id,
                p_program_update_date     => sysdate);
         --
       end if;
       --
    end if;
  end if;

  hr_utility.set_location ('Leaving '||l_package,10);

end write_ctfn;
--
--
----------------------------------------------------------------
--
--  Create get_ler_ctfns records
--
----------------------------------------------------------------
procedure get_ler_ctfns(p_ler_rqrs_enrt_ctfn_id  in number,
                        p_elig_per_elctbl_chc_id in number,
                        p_business_group_id      in number,
                        p_effective_date         in date,
                        p_ctfn_rqd_when_rl       in number,
                        p_assignment_id          in number,
                        p_organization_id        in number,
                        p_jurisdiction_code      in varchar2,
                        p_pgm_id                 in number,
                        p_pl_id                  in number,
                        p_pl_typ_id              in number,
                        p_opt_id                 in number,
                        p_ler_id                 in number) is
--
l_package     varchar2(80) := g_package||'.get_ler_ctfns ';
l_ctfn_rqd    ff_exec.outputs_t;
l_create_ctfn boolean      := false;
--
  cursor c_ctfn is
     select ctfn.rqd_flag,
            ctfn.enrt_ctfn_typ_cd,
            ctfn.ctfn_rqd_when_rl,
            lre.susp_if_ctfn_not_prvd_flag,
            lre.ctfn_determine_cd
     from   ben_ler_enrt_ctfn_f ctfn,
            ben_ler_rqrs_enrt_ctfn_f lre
     where  ctfn.ler_rqrs_enrt_ctfn_id = p_ler_rqrs_enrt_ctfn_id
     and    lre.ler_rqrs_enrt_ctfn_id = ctfn.ler_rqrs_enrt_ctfn_id
     and    p_effective_date between
            lre.effective_start_date and lre.effective_end_date
     and    ctfn.business_group_id = p_business_group_id
     and    p_effective_date between
            ctfn.effective_start_date and ctfn.effective_end_date;
--
begin
--
   hr_utility.set_location ('Entering '||l_package,10);
   --
   l_create_ctfn := false;
   --
   if p_ctfn_rqd_when_rl is not null then
      --
      l_ctfn_rqd := benutils.formula
                       (p_formula_id        => p_ctfn_rqd_when_rl,
                        p_effective_date    => p_effective_date,
                        p_business_group_id => p_business_group_id,
                        p_assignment_id     => p_assignment_id,
                        p_organization_id   => p_organization_id,
                        p_pgm_id            => p_pgm_id,
                        p_pl_id             => p_pl_id,
                        p_pl_typ_id         => p_pl_typ_id,
                        p_opt_id            => p_opt_id,
                        p_ler_id            => p_ler_id,
                        p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id,
                        p_jurisdiction_code => p_jurisdiction_code);
      --
     if l_ctfn_rqd(l_ctfn_rqd.first).value = 'Y' then
        --
        l_create_ctfn := true;
        --
     end if;
     --
   else
      --
      l_create_ctfn := true;
      --
   end if;
   --
   if l_create_ctfn then
     --
     for l_ctfn in c_ctfn loop
        --
        write_ctfn(p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id,
                   p_enrt_ctfn_typ_cd       => l_ctfn.enrt_ctfn_typ_cd,
                   p_rqd_flag               => l_ctfn.rqd_flag,
                   p_ctfn_rqd_when_rl       => l_ctfn.ctfn_rqd_when_rl,
                   p_business_group_id      => p_business_group_id,
                   p_effective_date         => p_effective_date,
                   p_assignment_id          => p_assignment_id,
                   p_organization_id        => p_organization_id,
                   p_jurisdiction_code      => p_jurisdiction_code,
                   p_pgm_id                 => p_pgm_id,
                   p_pl_id                  => p_pl_id,
                   p_pl_typ_id              => p_pl_typ_id,
                   p_opt_id                 => p_opt_id,
                   p_ler_id                 => p_ler_id,
                   p_susp_if_ctfn_not_prvd_flag => l_ctfn.susp_if_ctfn_not_prvd_flag,
                   p_ctfn_determine_cd      => l_ctfn.ctfn_determine_cd,
                   p_mode                   => g_mode);
        --
     end loop;
     --
   end if;
   --
   hr_utility.set_location ('Leaving '||l_package,10);
--
end get_ler_ctfns;
--
--
procedure write_bnft_rstrn_ctfn(p_elig_per_elctbl_chc_id in number,
                                p_pgm_id                 in number,
                                p_pl_id                  in number,
                                p_pl_typ_id              in number,
                                p_opt_id                 in number,
                                p_ler_id                 in number,
                                p_assignment_id          in number,
                                p_organization_id        in number,
                                p_jurisdiction_code      in varchar2,
                                p_business_group_id      in number,
                                p_effective_date         in date) is
  --
  l_package           varchar2(80) := g_package||'.write_bnft_rstrn_ctfn ';
  l_ler_bnft_rstrn_id number       := null;
  l_rstrn_found       boolean      := false;
  --
  cursor c_ler_rstrn is
     select rstrn.ler_bnft_rstrn_id
     from   ben_ler_bnft_rstrn_f rstrn,
            ben_pl_f             pln
     where  rstrn.pl_id  = p_pl_id
     and    rstrn.ler_id = p_ler_id
     and    rstrn.pl_id  = pln.pl_id
     and    pln.bnft_or_option_rstrctn_cd = 'OPT'
     and    rstrn.business_group_id = p_business_group_id
     and    p_effective_date between
            rstrn.effective_start_date and rstrn.effective_end_date
     and    p_effective_date between
            pln.effective_start_date and pln.effective_end_date;
  --
  cursor c_ler_rstrn_ctfn is
     select ctfn.rqd_flag,
            ctfn.enrt_ctfn_typ_cd,
            ctfn.ctfn_rqd_when_rl,
            lbr.susp_if_ctfn_not_prvd_flag,
            lbr.ctfn_determine_cd
     from   ben_ler_bnft_rstrn_ctfn_f ctfn,
            ben_ler_bnft_rstrn_f lbr
     where  ctfn.ler_bnft_rstrn_id = l_ler_bnft_rstrn_id
     and    lbr.ler_bnft_rstrn_id = ctfn.ler_bnft_rstrn_id
     and    p_effective_date between
            lbr.effective_start_date and lbr.effective_end_date
     and    ctfn.business_group_id = p_business_group_id
     and    p_effective_date between
            ctfn.effective_start_date and ctfn.effective_end_date;
  --
  cursor c_pl_rstrn_ctfn is
     select ctfn.rqd_flag,
            ctfn.enrt_ctfn_typ_cd,
            ctfn.ctfn_rqd_when_rl,
            pln.susp_if_ctfn_not_prvd_flag,
            pln.ctfn_determine_cd
     from   ben_bnft_rstrn_ctfn_f ctfn,
            ben_pl_f              pln
     where  pln.pl_id = p_pl_id
     and    pln.bnft_or_option_rstrctn_cd = 'OPT'
     and    pln.business_group_id = p_business_group_id
     and    pln.pl_id = ctfn.pl_id
     and    p_effective_date between
            pln.effective_start_date and pln.effective_end_date
     and    p_effective_date between
            ctfn.effective_start_date and ctfn.effective_end_date;
  --
begin
  --
  hr_utility.set_location ('Entering '||l_package,10);
  --
  open  c_ler_rstrn;
  fetch c_ler_rstrn into l_ler_bnft_rstrn_id;
  --
  if c_ler_rstrn%found then
     --
     l_rstrn_found := true;
     --
     for l_ctfn in c_ler_rstrn_ctfn loop
        --
        -- Life Event Level option jumping certifications.
        --
        write_ctfn(p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id,
                   p_enrt_ctfn_typ_cd       => l_ctfn.enrt_ctfn_typ_cd,
                   p_rqd_flag               => l_ctfn.rqd_flag,
                   p_ctfn_rqd_when_rl       => l_ctfn.ctfn_rqd_when_rl,
                   p_business_group_id      => p_business_group_id,
                   p_effective_date         => p_effective_date,
                   p_assignment_id          => p_assignment_id,
                   p_organization_id        => p_organization_id,
                   p_jurisdiction_code      => p_jurisdiction_code,
                   p_pgm_id                 => p_pgm_id,
                   p_pl_id                  => p_pl_id,
                   p_pl_typ_id              => p_pl_typ_id,
                   p_opt_id                 => p_opt_id,
                   p_ler_id                 => p_ler_id,
                   p_susp_if_ctfn_not_prvd_flag => l_ctfn.susp_if_ctfn_not_prvd_flag,
                   p_ctfn_determine_cd      => l_ctfn.ctfn_determine_cd,
                   p_mode                   => g_mode);
        --
     end loop;
     --
  end if;
  --
  close c_ler_rstrn;
  --
  if not l_rstrn_found then
     --
     -- Plan Level option jumping certifications.
     --
     for l_ctfn in c_pl_rstrn_ctfn loop
        --
        hr_utility.set_location ('l_ctfn.enrt_ctfn_typ_cd '||l_ctfn.enrt_ctfn_typ_cd,10);

        write_ctfn(p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id,
                   p_enrt_ctfn_typ_cd       => l_ctfn.enrt_ctfn_typ_cd,
                   p_rqd_flag               => l_ctfn.rqd_flag,
                   p_ctfn_rqd_when_rl       => l_ctfn.ctfn_rqd_when_rl,
                   p_business_group_id      => p_business_group_id,
                   p_effective_date         => p_effective_date,
                   p_assignment_id          => p_assignment_id,
                   p_organization_id        => p_organization_id,
                   p_jurisdiction_code      => p_jurisdiction_code,
                   p_pgm_id                 => p_pgm_id,
                   p_pl_id                  => p_pl_id,
                   p_pl_typ_id              => p_pl_typ_id,
                   p_opt_id                 => p_opt_id,
                   p_ler_id                 => p_ler_id,
                   p_susp_if_ctfn_not_prvd_flag => l_ctfn.susp_if_ctfn_not_prvd_flag,
                   p_ctfn_determine_cd      => l_ctfn.ctfn_determine_cd,
                   p_mode                   => g_mode);
        --
     end loop;
     --
  end if;
  --
  hr_utility.set_location ('Leaving '||l_package,10);
  --
end write_bnft_rstrn_ctfn;
--
--
procedure update_ctfn_rqd_flag(p_elig_per_elctbl_chc_id in number,
                               p_ctfn_rqd_flag          in varchar2,
                               p_object_version_number  in number,
                               p_business_group_id      in number,
                               p_effective_date         in date) is
  --
  l_package               varchar2(80) := g_package||'.update_ctfn_rqd_flag ';
  l_object_version_number number       := p_object_version_number;
  l_ctfn_rqd_flag         varchar2(30) := 'N';
  --
begin
  --
  hr_utility.set_location ('Entering '||l_package,10);
  --
  if g_ctfn_created then
     --
     l_ctfn_rqd_flag := 'Y';
     --
  end if;
  --
  if l_ctfn_rqd_flag <> p_ctfn_rqd_flag then
     --
     -- Update the flag, only if it has changed.
     --
     ben_elig_per_elc_chc_api.update_perf_elig_per_elc_chc
          (p_elig_per_elctbl_chc_id  => p_elig_per_elctbl_chc_id,
           p_ctfn_rqd_flag           => l_ctfn_rqd_flag,
           p_object_version_number   => l_object_version_number,
           p_business_group_id       => p_business_group_id,
           p_effective_date          => p_effective_date);
     --
  end if;
  --
  hr_utility.set_location ('Leaving '||l_package,10);
  --
end update_ctfn_rqd_flag;
--
-------------------------------------------------------------------------
--
--   driving procedure
--
-------------------------------------------------------------------------
PROCEDURE main(p_effective_date         IN date,
               p_person_id              IN number,
               p_elig_per_elctbl_chc_id IN number,
               p_mode                   in varchar2) IS
--
l_package varchar2(80) := g_package||'.main ';
l_found   boolean := false;
l_oipl_id varchar2(30);
l_business_group_id varchar2(30);
l_pl_id varchar2(30);
l_ler_id varchar2(30);
--
/*
cursor c_epe is
   select epe.elig_per_elctbl_chc_id,
          epe.object_version_number,
          epe.comp_lvl_cd,
          epe.pgm_id,
          epe.oipl_id,
          epe.pl_id,
          epe.pl_typ_id,
          oipl.opt_id,
          epe.business_group_id,
          epe.ctfn_rqd_flag,
          pil.person_id,
          pil.ler_id
   from   ben_elig_per_elctbl_chc epe,
          ben_per_in_ler pil,
          ben_oipl_f     oipl
   where  pil.per_in_ler_id = epe.per_in_ler_id
     and  epe.crntly_enrd_flag = 'N'
     and  epe.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id
     and  epe.oipl_id = oipl.oipl_id(+)
     and  p_effective_date between
          nvl(oipl.effective_start_date, p_effective_date) and
          nvl(oipl.effective_end_date, p_effective_date);
--
l_epe c_epe%rowtype;
*/
  --
  l_epe ben_epe_cache.g_pilepe_inst_row;
  --
cursor c_lre_oipl is
   select lre.ler_rqrs_enrt_ctfn_id,
          lre.ctfn_rqd_when_rl
   from   ben_ler_rqrs_enrt_ctfn_f lre
   where  lre.oipl_id = l_oipl_id
     and  lre.ler_id = l_ler_id
     and  lre.business_group_id = l_business_group_id
     and  p_effective_date
          between lre.effective_start_date
              and lre.effective_end_date;
--
cursor c_lre_pl is
   select lre.ler_rqrs_enrt_ctfn_id,
          lre.ctfn_rqd_when_rl
   from   ben_ler_rqrs_enrt_ctfn_f lre
   where  lre.pl_id = l_pl_id
     and  lre.ler_id = l_ler_id
     and  lre.business_group_id = l_business_group_id
     and  p_effective_date
          between lre.effective_start_date
              and lre.effective_end_date;
--
l_lre c_lre_pl%rowtype;
--
cursor c_ecf_oipl is
   select ecf.enrt_ctfn_typ_cd,
          ecf.rqd_flag,
          ecf.ctfn_rqd_when_rl,
          cop.susp_if_ctfn_not_prvd_flag,
          cop.ctfn_determine_cd
   from   ben_enrt_ctfn_f ecf,
          ben_oipl_f cop
   where  ecf.oipl_id = l_oipl_id
     and  cop.oipl_id = ecf.oipl_id
     and  ecf.business_group_id = l_business_group_id
     and  p_effective_date
          between cop.effective_start_date
              and cop.effective_end_date
     and  p_effective_date
          between ecf.effective_start_date
              and ecf.effective_end_date;
--
cursor c_ecf_pl is
   select ecf.enrt_ctfn_typ_cd,
          ecf.rqd_flag,
          ecf.ctfn_rqd_when_rl,
          pln.susp_if_ctfn_not_prvd_flag,
          pln.ctfn_determine_cd
   from   ben_enrt_ctfn_f ecf,
          ben_pl_f pln
   where  ecf.pl_id = l_pl_id
     and  pln.pl_id = ecf.pl_id
     and  ecf.business_group_id = l_business_group_id
     and  p_effective_date
          between pln.effective_start_date
              and pln.effective_end_date
     and  p_effective_date
          between ecf.effective_start_date
              and ecf.effective_end_date;
--
l_ecf c_ecf_pl%rowtype;
--
  cursor c_asg is
    select asg.assignment_id,asg.organization_id,loc.region_2
    from   per_all_assignments_f asg,hr_locations_all loc
    where  asg.person_id = p_person_id
    and    asg.assignment_type <> 'C'
    and    asg.primary_flag = 'Y'
    and    asg.location_id  = loc.location_id(+)
    and    p_effective_date
           between asg.effective_start_date
           and     asg.effective_end_date;
--
l_asg c_asg%rowtype;
l_jurisdiction_code     varchar2(30) := null;
--
BEGIN
  --
  hr_utility.set_location ('Entering '||l_package,10);
  --
  -- Edit to ensure that the input p_effective_date has a value
  --
  If p_effective_date is null then
    --
    fnd_message.set_name('BEN','BEN_91832_PACKAGE_PARAM_NULL');
    fnd_message.set_token('PACKAGE',l_package);
    fnd_message.set_token('PARAM','p_effective_date');
    fnd_message.set_token('PROC','Certification requirement');
    fnd_message.raise_error;
    --
  elsif p_person_id is null then
    --
    fnd_message.set_name('BEN','BEN_91832_PACKAGE_PARAM_NULL');
    fnd_message.set_token('PACKAGE',l_package);
    fnd_message.set_token('PARAM','p_person_id');
    fnd_message.set_token('PROC','Certification requirement');
    fnd_message.raise_error;
    --
  end if;
  --
  open c_asg;
  fetch c_asg into l_asg;  -- if not found, we don't care,
  close c_asg;             -- will pass null to formula
  --
  g_mode := p_mode;
  /*
  Bug 1949361 : Now the l_jurisdiction_code is derived inside benutils.formula.
  if l_asg.region_2 is not null then
     --
     l_jurisdiction_code := pay_mag_utils.lookup_jurisdiction_code
                                   (p_state => l_asg.region_2);
     --
  end if;
  */
  --
  -- (maagrawa 1/24/2000. As discussed with dwollenb)
  -- Certifications are now written in the following order.
  -- 1) If OIPL, create life event level oipl certification.
  -- 2) If OIPL, Create OIPL level certification.
  -- 3) If OIPL, and no cert.created in 1) and 2) then go ahead with 4) and 5).
  -- 4) Create life event level plan certification.
  -- 5) Create Plan level certification.
  --
  if ben_epe_cache.g_currcobjepe_row.elig_per_elctbl_chc_id is not null then
    --
    l_epe.elig_per_elctbl_chc_id := ben_epe_cache.g_currcobjepe_row.elig_per_elctbl_chc_id;
    l_epe.object_version_number  := ben_epe_cache.g_currcobjepe_row.object_version_number;
    l_epe.pl_id                  := ben_epe_cache.g_currcobjepe_row.pl_id;
    l_epe.ler_id                 := ben_epe_cache.g_currcobjepe_row.ler_id;
    l_epe.oipl_id                := ben_epe_cache.g_currcobjepe_row.oipl_id;
    l_epe.business_group_id      := ben_epe_cache.g_currcobjepe_row.business_group_id;
    l_epe.comp_lvl_cd            := ben_epe_cache.g_currcobjepe_row.comp_lvl_cd;
    l_epe.pgm_id                 := ben_epe_cache.g_currcobjepe_row.pgm_id;
    l_epe.pl_typ_id              := ben_epe_cache.g_currcobjepe_row.pl_typ_id;
    l_epe.opt_id                 := ben_epe_cache.g_currcobjepe_row.opt_id;
    l_epe.ctfn_rqd_flag          := ben_epe_cache.g_currcobjepe_row.ctfn_rqd_flag;
    --
/*
   open c_epe;
   fetch c_epe into l_epe;
   if c_epe%found then
     close c_epe;
*/
     hr_utility.set_location (l_package||' Start EPE loop ',10);
     --
     l_found        := false;
     g_ctfn_created := false;
     --
     hr_utility.set_location ('l_ler_id '||l_ler_id,55);
     hr_utility.set_location ('l_pl_id '||l_pl_id,55);
     hr_utility.set_location ('l_oipl_id '||l_oipl_id,55);
     hr_utility.set_location ('l_epe.elig_per_elctbl_chc_id '||
                                          l_epe.elig_per_elctbl_chc_id,55);
     hr_utility.set_location ('l_epe.object_version_number '||
                                          l_epe.object_version_number,55);
     --
     l_pl_id             := l_epe.pl_id;
     l_ler_id            := l_epe.ler_id;
     l_oipl_id           := l_epe.oipl_id;
     l_business_group_id := l_epe.business_group_id;
     --
     If l_epe.comp_lvl_cd = 'OIPL' then
        --
        --  process ler rqrd ctfn if found for oipl
        --
        hr_utility.set_location ('Entering oipl ',99);
        --
        for l_lre in c_lre_oipl loop
           --
           hr_utility.set_location ('Entering oipl lre ',99);
           l_found := true;
           --
           get_ler_ctfns
               (p_ler_rqrs_enrt_ctfn_id  => l_lre.ler_rqrs_enrt_ctfn_id ,
                p_elig_per_elctbl_chc_id => l_epe.elig_per_elctbl_chc_id,
                p_business_group_id      => l_epe.business_group_id,
                p_effective_date         => p_effective_date,
                p_ctfn_rqd_when_rl       => l_lre.ctfn_rqd_when_rl,
                p_assignment_id          => l_asg.assignment_id,
                p_organization_id        => l_asg.organization_id,
                p_jurisdiction_code      => l_jurisdiction_code,
                p_pgm_id                 => l_epe.pgm_id,
                p_pl_id                  => l_epe.pl_id,
                p_pl_typ_id              => l_epe.pl_typ_id,
                p_opt_id                 => l_epe.opt_id,
                p_ler_id                 => l_epe.ler_id);
           --
        end loop;
        --
        --bug#4175303 - if ler ctfns are written oipl will not be called
        --
        if not l_found then
          for l_ecf in c_ecf_oipl loop
             --
             hr_utility.set_location ('Entering oipl ecf',99);
             l_found := true;
             --
             write_ctfn
               (p_elig_per_elctbl_chc_id => l_epe.elig_per_elctbl_chc_id,
                p_enrt_ctfn_typ_cd       => l_ecf.enrt_ctfn_typ_cd,
                p_rqd_flag               => l_ecf.rqd_flag,
                p_ctfn_rqd_when_rl       => l_ecf.ctfn_rqd_when_rl,
                p_business_group_id      => l_epe.business_group_id,
                p_effective_date         => p_effective_date,
                p_assignment_id          => l_asg.assignment_id,
                p_organization_id        => l_asg.organization_id,
                p_jurisdiction_code      => l_jurisdiction_code,
                p_pgm_id                 => l_epe.pgm_id,
                p_pl_id                  => l_epe.pl_id,
                p_pl_typ_id              => l_epe.pl_typ_id,
                p_opt_id                 => l_epe.opt_id,
                p_ler_id                 => l_epe.ler_id,
                p_susp_if_ctfn_not_prvd_flag => l_ecf.susp_if_ctfn_not_prvd_flag,
                p_ctfn_determine_cd      => l_ecf.ctfn_determine_cd,
                p_mode                   => g_mode);
             --
          end loop;
          --
       end if;
        --
     end if;
     --
       hr_utility.set_location (l_package||' EPE CLC CHK ',10);
     if l_epe.comp_lvl_cd in ('OIPL','PLAN','PLANFC','PLANIMP') then
        --
        --  process plan ler ctfns
        --
        if not l_found then
           --
           for l_lre in c_lre_pl loop
              --
              hr_utility.set_location ('Entering pl lre',99);
              l_found := true;
              --
              get_ler_ctfns
                  (p_ler_rqrs_enrt_ctfn_id  => l_lre.ler_rqrs_enrt_ctfn_id ,
                   p_elig_per_elctbl_chc_id => l_epe.elig_per_elctbl_chc_id,
                   p_business_group_id      => l_epe.business_group_id,
                   p_effective_date         => p_effective_date,
                   p_ctfn_rqd_when_rl       => l_lre.ctfn_rqd_when_rl,
                   p_assignment_id          => l_asg.assignment_id,
                   p_organization_id        => l_asg.organization_id,
                   p_jurisdiction_code      => l_jurisdiction_code,
                   p_pgm_id                 => l_epe.pgm_id,
                   p_pl_id                  => l_epe.pl_id,
                   p_pl_typ_id              => l_epe.pl_typ_id,
                   p_opt_id                 => l_epe.opt_id,
                   p_ler_id                 => l_epe.ler_id);
              --
              hr_utility.set_location ('Done glerctfns '||l_package,10);
              --
           end loop;
           --
           --
           if not l_found then
             for l_ecf in c_ecf_pl loop
                --
                hr_utility.set_location ('Entering pl ecf',99);
                l_found := true;
                --
                write_ctfn
                 (p_elig_per_elctbl_chc_id => l_epe.elig_per_elctbl_chc_id,
                  p_enrt_ctfn_typ_cd       => l_ecf.enrt_ctfn_typ_cd,
                  p_rqd_flag               => l_ecf.rqd_flag,
                  p_ctfn_rqd_when_rl       => l_ecf.ctfn_rqd_when_rl,
                  p_business_group_id      => l_epe.business_group_id,
                  p_effective_date         => p_effective_date,
                  p_assignment_id          => l_asg.assignment_id,
                  p_organization_id        => l_asg.organization_id,
                  p_jurisdiction_code      => l_jurisdiction_code,
                  p_pgm_id                 => l_epe.pgm_id,
                  p_pl_id                  => l_epe.pl_id,
                  p_pl_typ_id              => l_epe.pl_typ_id,
                  p_opt_id                 => l_epe.opt_id,
                  p_ler_id                 => l_epe.ler_id,
                  p_susp_if_ctfn_not_prvd_flag => l_ecf.susp_if_ctfn_not_prvd_flag,
                  p_ctfn_determine_cd      => l_ecf.ctfn_determine_cd,
                  p_mode                   => g_mode);
              --
                hr_utility.set_location ('Done gecfctfns '||l_package,10);
                --
             end loop;
             --
          end if;
          --
        end if;
        --
     end if;
     --
       hr_utility.set_location (l_package||' EPE OIPL ID EPE CRF ',10);
     if l_epe.oipl_id is not null and l_epe.ctfn_rqd_flag = 'Y' then
        --
        -- Write level jumping certifications for OIPL's only if
        -- bendenrr has already found that certification is required
        -- to jump to this level.
        --
        write_bnft_rstrn_ctfn
            (p_elig_per_elctbl_chc_id  => l_epe.elig_per_elctbl_chc_id,
             p_pgm_id                  => l_epe.pgm_id,
             p_pl_id                   => l_epe.pl_id,
             p_pl_typ_id               => l_epe.pl_typ_id,
             p_opt_id                  => l_epe.opt_id,
             p_ler_id                  => l_epe.ler_id,
             p_assignment_id           => l_asg.assignment_id,
             p_organization_id         => l_asg.organization_id,
             p_jurisdiction_code       => l_jurisdiction_code,
             p_business_group_id       => l_epe.business_group_id,
             p_effective_date          => p_effective_date);
        --
     end if;
     --
       hr_utility.set_location (l_package||' UCRF ',10);
     update_ctfn_rqd_flag
            (p_elig_per_elctbl_chc_id => l_epe.elig_per_elctbl_chc_id,
             p_ctfn_rqd_flag          => l_epe.ctfn_rqd_flag,
             p_object_version_number  => l_epe.object_version_number,
             p_business_group_id      => l_epe.business_group_id,
             p_effective_date         => p_effective_date);
     --
     hr_utility.set_location (l_package||' End EPE loop ',10);
/*
   else
     close c_epe;
*/
   end if;
   --
   hr_utility.set_location ('Leaving '||l_package,10);
   --
end main;
--
procedure update_susp_if_ctfn_flag(
                     p_effective_date         in date,
                     p_lf_evt_ocrd_dt         in date,
                     p_person_id              in number,
                     p_per_in_ler_id          in number
                     ) IS
  l_package varchar2(80) := g_package||'.update_susp_if_ctfn_flag ';
  --
  cursor c_ecc is
  select   distinct epe.pgm_id,
                    epe.pl_typ_id,
                    epe.pl_id,
                    ecc.enrt_ctfn_typ_cd
      from ben_elctbl_chc_ctfn ecc,
           ben_elig_per_elctbl_chc epe
     where epe.per_in_ler_id = p_per_in_ler_id
       and epe.elctbl_flag   = 'Y'
       and epe.ctfn_rqd_flag = 'Y'
       and ecc.elig_per_elctbl_chc_id = epe.elig_per_elctbl_chc_id
       and ecc.enrt_bnft_id is null
       and ecc.ctfn_determine_cd = 'ENRFT'
       and ecc.susp_if_ctfn_not_prvd_flag = 'Y'
       and ecc.rqd_flag = 'Y'
  order by 1,2,3,4;
  --
  cursor c_pl_ctfn ( p_pl_id number,
                     p_per_in_ler_id number,
                     p_effective_date date,
                     p_enrt_ctfn_typ_cd varchar2 ) is
    select 'Y'
    from   ben_ler_rqrs_enrt_ctfn_f lre,
           ben_ler_enrt_ctfn_f lec,
           ben_per_in_ler pil
    where lre.pl_id = p_pl_id
      and pil.per_in_ler_id = p_per_in_ler_id
      and lre.ler_id = pil.ler_id
      and p_effective_date between lre.effective_start_date
                               and lre.effective_end_date
      and p_effective_date between lec.effective_start_date
                               and lec.effective_end_date
      and lec.ler_rqrs_enrt_ctfn_id = lre.ler_rqrs_enrt_ctfn_id
      and lec.enrt_ctfn_typ_cd = p_enrt_ctfn_typ_cd
    union
    select 'Y'
    from  ben_enrt_ctfn_f ec
    where ec.pl_id = p_pl_id
      and p_effective_date between ec.effective_start_date
                               and ec.effective_end_date
      and ec.enrt_ctfn_typ_cd = p_enrt_ctfn_typ_cd ;
  --
      CURSOR c_plan_enrolment_info(p_cvg_dt date,
                                   p_person_id number,
                                   p_pgm_id number,
                                   p_pl_id number) IS
      SELECT   'Y'
      FROM     ben_prtt_enrt_rslt_f pen
      WHERE    pen.person_id = p_person_id
      AND      pen.sspndd_flag = 'N'
      AND      pen.prtt_enrt_rslt_stat_cd IS NULL
      AND      pen.effective_end_date = hr_api.g_eot
      AND      p_cvg_dt <= pen.enrt_cvg_thru_dt
      AND      pen.enrt_cvg_strt_dt < pen.effective_end_date
      -- AND      pen.oipl_id IS NULL
      AND      p_pl_id = pen.pl_id
      AND      (
                    (    pen.pgm_id = p_pgm_id
                     AND p_pgm_id IS NOT NULL)
                 OR (    pen.pgm_id IS NULL
                     AND p_pgm_id IS NULL))
      ;
  --
    CURSOR c_oipl_enrolment_info(p_cvg_dt date,
                                 p_person_id number,
                                 p_pgm_id number,
                                 p_oipl_id number ) IS
      SELECT   'Y'
      FROM     ben_prtt_enrt_rslt_f pen
      WHERE    pen.person_id = p_person_id
      AND      pen.sspndd_flag = 'N'
      AND      pen.prtt_enrt_rslt_stat_cd IS NULL
      AND      pen.effective_end_date = hr_api.g_eot
      AND      p_cvg_dt <= pen.enrt_cvg_thru_dt
      AND      pen.enrt_cvg_strt_dt < pen.effective_end_date
      AND      p_oipl_id = pen.oipl_id
      AND      (
                    (    pen.pgm_id = p_pgm_id
                     AND p_pgm_id IS NOT NULL)
                 OR (    pen.pgm_id IS NULL
                     AND p_pgm_id IS NULL))
      ;
  --
  cursor c_oipl_ecc(p_pl_id number) is
  select  epe.elig_per_elctbl_chc_id,
          epe.pgm_id,
          epe.pl_typ_id,
          epe.pl_id,
          epe.oipl_id,
          ecc.enrt_ctfn_typ_cd,
          ecc.elctbl_chc_ctfn_id,
          ecc.object_version_number,
          ecc.business_group_id
      from ben_elctbl_chc_ctfn ecc,
           ben_elig_per_elctbl_chc epe
     where epe.per_in_ler_id = p_per_in_ler_id
       and epe.pl_id         = p_pl_id
       and epe.elctbl_flag   = 'Y'
       and epe.ctfn_rqd_flag = 'Y'
       and epe.oipl_id IS NOT NULL
       and ecc.elig_per_elctbl_chc_id = epe.elig_per_elctbl_chc_id
       and ecc.enrt_bnft_id is null
       and ecc.ctfn_determine_cd = 'ENRFT'
       and ecc.susp_if_ctfn_not_prvd_flag = 'Y'
       and ecc.rqd_flag = 'Y' ;
  --
  cursor c_pl_or_oipl_ecc(p_pl_id number) is
  select  epe.elig_per_elctbl_chc_id,
          epe.pgm_id,
          epe.pl_typ_id,
          epe.pl_id,
          epe.oipl_id,
          ecc.enrt_ctfn_typ_cd,
          ecc.elctbl_chc_ctfn_id,
          ecc.object_version_number,
          ecc.business_group_id
      from ben_elctbl_chc_ctfn ecc,
           ben_elig_per_elctbl_chc epe
     where epe.per_in_ler_id = p_per_in_ler_id
       and epe.pl_id         = p_pl_id
       and epe.elctbl_flag   = 'Y'
       and epe.ctfn_rqd_flag = 'Y'
       and ecc.elig_per_elctbl_chc_id = epe.elig_per_elctbl_chc_id
       and ecc.enrt_bnft_id is null
       and ecc.ctfn_determine_cd = 'ENRFT'
       and ecc.susp_if_ctfn_not_prvd_flag = 'Y'
       and ecc.rqd_flag = 'Y' ;
  --
  l_oipl_rec c_oipl_ecc%ROWTYPE;
  l_ecc_ovn   NUMBER(9);
  --
  l_dummy VARCHAR2(30) := 'N';
  l_dummy1 VARCHAR2(30) := 'N';
  l_dummy2 VARCHAR2(30) := 'N';
begin
  hr_utility.set_location ('Entering '||l_package,10);
  FOR l_ecc IN c_ecc LOOP
    --
    l_dummy := 'N';    --Bug 7701140
    l_dummy1 := 'N';   --Bug 7701140
    hr_utility.set_location ('l_ecc.pgm_id'||l_ecc.pgm_id,20);
    hr_utility.set_location ('l_ecc.pl_id '||l_ecc.pl_id,20);
    hr_utility.set_location ('l_ecc.enrt_ctfn_typ_cd '||l_ecc.enrt_ctfn_typ_cd,20);
    --
    OPEN c_pl_ctfn(l_ecc.pl_id,p_per_in_ler_id,p_effective_date,l_ecc.enrt_ctfn_typ_cd) ;
      FETCH c_pl_ctfn INTO l_dummy ;
    CLOSE c_pl_ctfn ;
    hr_utility.set_location(' l_dummy '||l_dummy,30);
    IF l_dummy = 'Y' THEN
      -- Plan level certification is setup and now check to see current at the plan level
      OPEN c_plan_enrolment_info(p_lf_evt_ocrd_dt,
                                  p_person_id,
                                  l_ecc.pgm_id,
                                  l_ecc.pl_id) ;
        FETCH c_plan_enrolment_info INTO l_dummy1 ;
      CLOSE c_plan_enrolment_info ;
      --Currently enrolled at plan level
      hr_utility.set_location(' Plan Level Certs l_dummy1 '||l_dummy1,40);
      IF l_dummy1 = 'Y' THEN
          --Currently enrolled in this option, so we need to update the flag
         OPEN c_pl_or_oipl_ecc(l_ecc.pl_id) ;
         loop
           fetch c_pl_or_oipl_ecc INTO l_oipl_rec;
           if c_pl_or_oipl_ecc%notfound then
             close c_pl_or_oipl_ecc ;
             exit ;
           end if;
           --
           hr_utility.set_location(' l_oipl_rec.elctbl_chc_ctfn_id '||l_oipl_rec.elctbl_chc_ctfn_id,50);
           l_ecc_ovn := l_oipl_rec.object_version_number ;
           --
           ben_ELTBL_CHC_CTFN_api.update_ELTBL_CHC_CTFN
            (p_elctbl_chc_ctfn_id            => l_oipl_rec.elctbl_chc_ctfn_id
            ,p_susp_if_ctfn_not_prvd_flag    => 'N'
           ,p_object_version_number         => l_ecc_ovn
           ,p_effective_date                => trunc(p_effective_date)
            );
         end loop;
         --
      END IF;
      --
    ELSE
      -- Plan level certification is not setup, so need to see if current only at the option level
      hr_utility.set_location('Cert at Option Level',60);
      OPEN c_oipl_ecc(l_ecc.pl_id) ;
      loop
        fetch c_oipl_ecc INTO l_oipl_rec;
        if c_oipl_ecc%notfound then
          close c_oipl_ecc ;
          exit ;
        end if;
        OPEN c_oipl_enrolment_info(p_lf_evt_ocrd_dt,
                                  p_person_id,
                                  l_ecc.pgm_id,
                                  l_oipl_rec.oipl_id) ;
          FETCH c_oipl_enrolment_info INTO l_dummy2 ;
        CLOSE c_oipl_enrolment_info ;
        hr_utility.set_location(' l_dummy2 '||l_dummy2,70);
        IF l_dummy2 = 'Y' THEN
          --Currently enrolled in this option, so we need to update the flag
          l_ecc_ovn := l_oipl_rec.object_version_number ;
          --
          hr_utility.set_location(' l_oipl_rec.elctbl_chc_ctfn_id '||l_oipl_rec.elctbl_chc_ctfn_id,80);
          ben_ELTBL_CHC_CTFN_api.update_ELTBL_CHC_CTFN
          (p_elctbl_chc_ctfn_id            => l_oipl_rec.elctbl_chc_ctfn_id
          ,p_susp_if_ctfn_not_prvd_flag    => 'N'
          ,p_object_version_number         => l_ecc_ovn
          ,p_effective_date                => trunc(p_effective_date)
          );
          --
        END IF;
      end loop;
      --
    END IF;
    --
  END LOOP;
  hr_utility.set_location ('Leaving '||l_package,10);
end update_susp_if_ctfn_flag ;
--
end BEN_DETERMINE_CHC_CTFN;

/
