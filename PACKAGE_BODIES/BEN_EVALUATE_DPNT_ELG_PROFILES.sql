--------------------------------------------------------
--  DDL for Package Body BEN_EVALUATE_DPNT_ELG_PROFILES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EVALUATE_DPNT_ELG_PROFILES" as
/* $Header: bendpelg.pkb 120.5.12010000.8 2010/04/13 15:22:44 krupani ship $ */
-----------------------------------------------------------------------
/*
+==============================================================================+
|                       Copyright (c) 1998 Oracle Corporation                  |
|                          Redwood Shores, California, USA                     |
|                               All rights reserved.                           |
+==============================================================================+
Name
      Manage Dependent Eligibility
Purpose
      This package is used to determine if a specific dependent is eligible for
      a specific electable choice for a participant.  It returns the eligibility
      in the p_dependent_eligible_flag as an out nocopy parameter.
History
        Date             Who           Version    What?
        ----             ---           -------    -----
        09 Apr 98        M Rosen/JM    110.0      Created.
        03 Jun 98        J Mohapatra              Replaced age calculation with a new
                                                  procedure call.
        24 Nov 98        jcarpent      115.3      Check rltd_per_rsds_w_dsgntr_flag
                                                  Get dsgntr address if Y
        15 Dec 98        stee          115.4      Schema changes to
                                                  ben_dsgn_rqmt_f.
        21 Dec 98        jcarpent      115.5      Track date of elig change
        18 Jan 99        G Perry       115.6      LED V ED
        16 Apr 99        jcarpent      115.8      Added call to dpnt_cvg_elig_det_rl
        06 May 99        shdas         115.9      Added contexts to rule calls.
        17 May 99        jcarpent      115.10     Handle dob of null
        25 May 99        stee          115.11     Add new eligibility criteria
                                                  for COBRA.
        06 Jun 99        stee          115.12     Fix check_cvrd_anthr_pl_cvg
                                                  to check for all plans in
                                                  the profile.
        12 Jul 99        tguy           115.13    fixed from and to check for
                                                  postal zip range.
        20-JUL-99        Gperry        115.14     genutils -> benutils package
                                                  rename.
        30-Aug-99        maagrawa      115.15     Added p_dpnt_inelig_rsn_cd
                                                  to procedure main.
                                                  Added p_inelig_rsn_cd to
                                                  all check procedures.
        07-Sep-99        tguy          115.16     fixed calls to pay_mag_util
        14-Oct-99        Gperry        115.17     Changed dependent address
                                                  error to use the generic
                                                  exception rather than
                                                  fnd_message.raise_error
                                                  exception. Changed error
                                                  message to explain error
                                                  more thouroughly.
        11-Nov-99        mhoyes        115.18   - Added trace messages.
        11-Nov-99        Gperry        115.19     Fixed bug 3665.
                                                  Made l_age variable number
                                                  rather than number(15);
        30-Nov-99        lmcdonal      115.20     Debugging messages.
        12-dec-99        pbodla        115.21   - l_contact.person_id is
                                                  passed, as input value when
                                                  dpnt_cvg_elig_det_rl evaluated.
                                                  As the assignment id may not be
                                                  available all the time. This is
                                                  a work around to access the
                                                  contact person data. Customer
                                                  have to write the formula function.
        20-dec-99        maagrawa      115.22  The dependent becomes ineligible
                                               when the contact relationship
                                               record ends. (Bug 4028)
        28-jan-00        lmcdonal      115.23  Bug 1167262.  Find ptip dpnt elig
                                               profiles when processing plans
                                               and oipls.  Added c_ptip cursor.
        08-feb-00        maagrawa      115.24  Set the g_elig_change_dt to
                                               the date when the dpnt. crosses
                                               the limit.(1178670)
        09-feb-00        stee          115.25  Fix invalid cursor in
                                               dsgntr_enrld_cvg_elig profile.
                                               WWBUG# 1189088.
        12-Feb-00        maagrawa      115.26  Default the g_elig_change_dt to
                                               nvl(p_lf_evt_ocrd_dt,
                                                   p_effective_date)
        24-Feb-00        maagrawa      115.27  Dpnt. having max age should be
                                               ineligible. (1207798).
        28-Feb-00        gperry        115.28  Added use of dpnt profile flags.
                                               for performance.
        07-Mar-00        pbodla        115.29  Bug 3531 : p_contact_person_id
                                               passed to formula call.
        31-Mar-00        maagrawa      115.30  For optional profiles, get the
                                               latest date when eligibility
                                               ends. (1244531).
                                               The ineligibiltye date should
                                               be between coverage start date
                                               and effective_date (4929).
        05-Apr-00        mmogel        115.31  Added tokens to messages to
                                               make them more meaningful to
                                               the user
        26-Jun-00        gperry        115.32  Added p_contact_person_id to
                                               drive off parent information
                                               when needed.
        30-Jul-00        mhoyes        115.33 - Tuned c_ade. Removed nvls and
                                                business_group_id restrictions.
                                              - Removed nvls and + 0s from cursors
        30-nov-00        tilak         115.34   bug  1522219
        01-Dec-00        mhoyes        115.35 - Fixed bug 1511643. Changed
                                                check_military_elig to handle null
                                                values.

        04-dec-00        tilak         115.36   bug  1522219
        07-dec-00        rchase        115.37   Bug 1518211. Make p_dob an out
                                                parameter.
                                                Lepfrog version based on 115.33
        07-dec-00        jcarpent      115.38   Merge version of 115.37+115.36.
        07-dec-00        tilak         115.39   bug : 1096978 address and sharing prtt addr
                                                validated when postal teria is validated
        15-jan-01        tilak         115.40   bug : 1540610 >= min and < max age validation is
                                                change to >= min and < max+1
        29-aug-01        pbodla        115.41   bug:1949361 jurisdiction code is
                                                derived inside benutils.formula
        18-Sep-01        ikasire       115.42   bug 1977901 fixed the logic in max/min
                                                age validation
        28-sep-01        tjesumic      115.43   bug : 1638727  fixed , error message for
                                                depnt address is reomoved,dpnt wont be eligible
                                                if address is not defined
        30-Nov-01        ikasire       115.44   Bug 2101937 Ceil condition replace with a if
                                                condition to handle wholes numbers and decimal
                                                numbers seperately not to break the existing
                                                functionality and to support decimal ranges in
                                                derived factors.
       15-Dec-01        ikasire        115.45   Added dbdrv lines.
                                                Bug 2100564 - fixed the Exclude flag
                                                functionality in the profiles like done in
                                                bendetel and benrtprf.
       08-Jun-02        pabodla        115.46   Do not select the contingent worker
                                                assignment when assignment data is
                                                fetched.
       10-Oct-03        kmahendr       115.49   Performance fix - check_age_elig moved
                                                down and check_contact_elig moved up.
       13-aug-04        tjesumic       115.50   fonm changes
       07-Feb-05        kmahendr    115.51   Bug#4157836 - the ineligible date on account
                                                  of contact type based on person table reversed
       01-Apr-05         swjain         115.52 Bug 4271143 -- Added check to calculate apld_dpnt_cvg_elig_rl
                                                   since if Coverage Eligibility Rule is specified, then it should also
						   evaluate to true alongwith eligibility profile. Also added one more cursor c_ade1
						   in procedure main.
       09-May-05         kmahendr       115.53  Bug#4318031 - added cursor contact2 and added
                                                codes to check_contact_elig
       07-Jun-05         kmahendr  115.54  Bug#4399894-added c_previous_per to check
                                           previous value
       13-jun-05         kmahendr  115.55  Fixes for other eligibility viz military,
                                           student and marital
       19-aug-05         ssarkar   115.56  bug 4546890 : set_elig_change_dt is called for rule evaluation of eligibility.
                                                         and modified proc set_elig_change_dt for FONM case.
       24-Oct-07          swjain   115.57  Bug 6520270: Made changes in set_elig_change_dt
       14-Nov-07          swjain   115.58  Bug 6615978: Updated procedure check_age_elig. Ineligibility date is calculated
                                                        as per the profile value set now.
       14-jan-08	       rtagarra  115.59  Bug 6738429: Added prtt_enrt_rslt_stat_cd clause in
                                                        Cursor c_get_elig_cvrd_dpnt for the issue in contact person
							                                    covered in other plan.
       06-mar-08         bachakra  115.61  Bug 6870564: Corrected the prtt_enrt_rslt_stat_cd clause in cursor
                                                        c_get_prtt_enrt_rslt in the procedure
							                                   check_dsgntr_enrld_cvg_elig
       22-APR-08         stee      115.62  Bug 6956648: Change cursor c_contact in check_contact_elig
                                                        to only check contact for the person.
       01-Oct-09         krupani   115.64  Bug 8856039: Even in FONM setup, the coverage end date should be based on life event occurred date
       13-Apr-10         krupani   120.5.12010000.8   Bug 9558250 : 12.1.3 enhancement to have user defined criteria for dependents.

*/
-----------------------------------------------------------------------
--
-- Global to track eligibility change date
--
g_elig_change_dt   date;
g_dpnt_cvg_strt_dt date;
g_effective_date   date;
--
procedure set_elig_change_dt(p_elig_change_dt in date,
                             p_effective_date in date) is
  --
  l_proc             varchar2(80) := g_package || '.set_elig_change_dt';
  --
begin
  --
  hr_utility.set_location ('Entering '||l_proc,10);
  hr_utility.set_location ('p_elig_change_dt '||p_elig_change_dt,10);
  hr_utility.set_location ('g_elig_change_dt '||g_elig_change_dt,10);
  hr_utility.set_location ('g_effective_date '||g_effective_date,10);
  hr_utility.set_location ('** SUP p_effective_date '||p_effective_date,10);
  hr_utility.set_location ('g_dpnt_cvg_strt_dt '||g_dpnt_cvg_strt_dt,10);
  --
  -- If dpnt. coverage start date is specified then, the elig change date
  -- cannot be before that.
  -- Additionally
  --  - Mandatory profiles are checked first and once any of them are found
  --    ineligible, we stop with that date. So, if it happens, it will be the
  --    first call to this procedure and will never be called again.
  --  - If optional profiles are found ineligible, we need to find the latest
  --    day when all the optional profiles become ineligible. So, we update the
  --    date only if the new date is greater than the old one.

  -- bug 4546890 : compare p_elig_change_dt with the
  -- l_effective_date  which is the l_fonm_cvg_strt_dt  rather than the life event
  -- occured date,in case FONM flag = 'Y'.Otherwise compare with life event occured date .
  -- SO changed g_effective_date , which always hold life event occured date , to p_effective_date

  if (g_dpnt_cvg_strt_dt is null or
      p_elig_change_dt >= g_dpnt_cvg_strt_dt) and
     (g_elig_change_dt is null or
      p_elig_change_dt > g_elig_change_dt)   then
    --
    -- Bug 6520270: If p_elig_change_dt > p_effective_date, that is employee is losing eligibility in furture
    -- then set the g_elig_change_dt to effective_date -1
    --
    if (p_elig_change_dt <= p_effective_date) then
      /* Bug 8856039: Even in FONM setup, the coverage end date should be based on life event occurred date */
      if ben_manage_life_events.fonm = 'Y' then
        hr_utility.set_location ('fonm case: g_effective_date '||g_effective_date,11);
        g_elig_change_dt := g_effective_date - 1;  -- life event occurred date - 1
      else
        g_elig_change_dt := p_elig_change_dt;
      end if;
    else
        g_elig_change_dt := p_effective_date - 1;
    end if;
    --
    -- End 6520270
    --
    hr_utility.set_location (' Setting g_elig_change_dt '||g_elig_change_dt,10);
  end if;
  --
  hr_utility.set_location ('Leaving '||l_proc,10);
  --
end set_elig_change_dt;
--
--
procedure main
        (p_contact_relationship_id  in number,
         p_contact_person_id        in number,
         p_pgm_id                   in number default null,
         p_pl_id                    in number,
         p_ptip_id                  in number default null,
         p_oipl_id                  in number default null,
         p_business_group_id        in number,
         p_per_in_ler_id            in number,
         p_effective_date           in date,
         p_lf_evt_ocrd_dt           in date,
         p_dpnt_cvg_strt_dt         in date     default null,
         p_level                    in varchar2 default null,
         p_dependent_eligible_flag  out nocopy varchar2,
         p_dpnt_inelig_rsn_cd       out nocopy varchar2) is
  --
  l_proc                              varchar2(80) := g_package || '.main';
  l_level                              varchar2(30) := 'PLAN';
  l_eligible_flag                  varchar2(30) := 'Y';
  l_apld_eligible_flag         varchar2(30) := 'Y';
  l_inelig_rsn_cd                varchar2(30) := null;
  l_assignment_id                number;
  l_organization_id              number;
  l_region_2                        hr_locations_all.region_2%type;
  l_outputs                          ff_exec.outputs_t;
  l_jurisdiction_code           varchar2(30);
  l_effective_date               date ;
  --
  l_exists    varchar2(1);
  l_return    varchar2(30);
  --
  l_fonm_cvg_strt_dt   date  ;
  -- More cursors - this may go away when caching is used
  --
  cursor c_pgm
    (c_effective_date in date
    )
  is
    select dpnt_dsgn_lvl_cd,
           dpnt_dsgn_cd,
           dpnt_cvg_strt_dt_cd,
           dpnt_cvg_strt_dt_rl,
           dpnt_cvg_end_dt_cd,
           dpnt_cvg_end_dt_rl
    from   ben_pgm_f pgm
    where  pgm.pgm_id = p_pgm_id
    and    c_effective_date
           between pgm.effective_start_date
           and     pgm.effective_end_date;
  --
  l_pgm    c_pgm%rowtype;
  --
  cursor c_contact
    (c_effective_date in date
    )
  is
    select contact_person_id,
           contact_relationship_id,
           contact_type,
           personal_flag,
           rltd_per_rsds_w_dsgntr_flag,
           person_id,
           date_end
    from   per_contact_relationships ctr
    where  ctr.contact_relationship_id = p_contact_relationship_id
    and    c_effective_date >=
           nvl(date_start,c_effective_date);
  --
  l_contact c_contact%rowtype;
  --
  cursor c_contact2 (p_effective_date in date)
    is
     select contact_type
     from   per_contact_relationships ctr
     where  ctr.contact_relationship_id <> p_contact_relationship_id
     and    ctr.contact_person_id = p_contact_person_id
     and    ctr.personal_flag = 'Y'
     and    p_effective_date between nvl(ctr.date_start,p_effective_date)
           and     nvl(ctr.date_end,p_effective_date);
  --
  l_contact_type2  varchar2(300);
  --
  cursor   c_dsgn
    (c_effective_date in date
    )
  is
    select null
    from   ben_dsgn_rqmt_f ddr
    where  (ddr.oipl_id = p_oipl_id
            or ddr.pl_id = p_pl_id
            or ddr.opt_id = (select oipl.opt_id
                             from   ben_oipl_f oipl
                             where  oipl.oipl_id = p_oipl_id
                             and    oipl.business_group_id  =
                                    p_business_group_id
                             and    c_effective_date
                                    between oipl.effective_start_date
                                    and     oipl.effective_end_date))
    and    ddr.dsgn_typ_cd = 'DPNT'
    and    ddr.business_group_id  = p_business_group_id
    and    c_effective_date
           between ddr.effective_start_date
           and     ddr.effective_end_date;
  --
  cursor c_dsgn_rl_typ
    (c_effective_date in date
     ,p_contact_type  in varchar2
    )
  is
    select null
    from   ben_dsgn_rqmt_f ddr, ben_dsgn_rqmt_rlshp_typ rl
    where  ddr.dsgn_rqmt_id = rl.dsgn_rqmt_id(+)
    and    rl.rlshp_typ_cd = p_contact_type
    and    (ddr.oipl_id = p_oipl_id
            or ddr.pl_id = p_pl_id
            or ddr.opt_id = (select oipl.opt_id
                             from   ben_oipl_f oipl
                             where  oipl.oipl_id = p_oipl_id
                             and    oipl.business_group_id  =
                                    p_business_group_id
                             and    c_effective_date
                                    between oipl.effective_start_date
                                    and     oipl.effective_end_date))
    and    ddr.dsgn_typ_cd = 'DPNT'
-- Commented and added new clause for Bug fix - 1859111
--  and    (nvl(ddr.mn_dpnts_rqd_num,-1) <> 0
--            and nvl(ddr.mx_dpnts_alwd_num,-1) <> 0)
    and    ( (nvl(ddr.mn_dpnts_rqd_num,-1) = -1 and ddr.no_mn_num_dfnd_flag = 'Y')
             or ( ddr.mn_dpnts_rqd_num is not null and ddr.no_mn_num_dfnd_flag = 'N') )
    and    ( (nvl(ddr.mx_dpnts_alwd_num,-1) = -1 and ddr.no_mx_num_dfnd_flag = 'Y')
             or ( ddr.mx_dpnts_alwd_num <> 0 and ddr.no_mx_num_dfnd_flag = 'N') )
-- End of Bug fix - 1859111
    and    ddr.business_group_id  = p_business_group_id
    and    c_effective_date
           between ddr.effective_start_date
           and     ddr.effective_end_date;
  --
  cursor  c_dsgn_grp
    (c_effective_date in date
    )
  is
    select null
    from   ben_dsgn_rqmt_f ddr
    where  ddr.grp_rlshp_cd is null
    and    (ddr.oipl_id = p_oipl_id
            or ddr.pl_id  = p_pl_id
            or ddr.opt_id = (select oipl.opt_id
                             from   ben_oipl_f oipl
                             where  oipl.oipl_id = p_oipl_id
                             and    oipl.business_group_id  =
                                    p_business_group_id
                             and    c_effective_date
                                    between oipl.effective_start_date
                                    and     oipl.effective_end_date))
    and    ddr.dsgn_typ_cd = 'DPNT'
-- Commented and added new clause for Bug fix - 1859111
--  and    (nvl(ddr.mn_dpnts_rqd_num,-1) <> 0
--            and nvl(ddr.mx_dpnts_alwd_num,-1) <> 0)
    and    ( (nvl(ddr.mn_dpnts_rqd_num,-1) = -1 and ddr.no_mn_num_dfnd_flag = 'Y')
             or ( ddr.mn_dpnts_rqd_num is not null and ddr.no_mn_num_dfnd_flag = 'N') )
    and    ( (nvl(ddr.mx_dpnts_alwd_num,-1) = -1 and ddr.no_mx_num_dfnd_flag = 'Y')
             or ( ddr.mx_dpnts_alwd_num <> 0 and ddr.no_mx_num_dfnd_flag = 'N') )
-- End of Bug fix - 1859111
    and    ddr.business_group_id  = p_business_group_id
    and    c_effective_date
           between ddr.effective_start_date
           and     ddr.effective_end_date;
  --
  cursor c_dsgn_not_rl_typ
    (c_effective_date in date
    )
  is
    select null
    from   ben_dsgn_rqmt_f ddr,
           ben_dsgn_rqmt_rlshp_typ rl
    where  ddr.dsgn_rqmt_id = rl.dsgn_rqmt_id(+)
    and    ddr.grp_rlshp_cd is not null
    and    rl.rlshp_typ_cd <> l_contact.contact_type
    and   (ddr.oipl_id = p_oipl_id
           or ddr.pl_id = p_pl_id
           or ddr.opt_id = (select oipl.opt_id
                            from   ben_oipl_f oipl
                            where  oipl.oipl_id = p_oipl_id
                            and    oipl.business_group_id  =
                                   p_business_group_id
                            and    c_effective_date
                                   between oipl.effective_start_date
                                   and     oipl.effective_end_date))
    and    ddr.dsgn_typ_cd = 'DPNT'
    and    ddr.business_group_id  = p_business_group_id
    and    c_effective_date
           between ddr.effective_start_date
           and     ddr.effective_end_date;

  cursor c_ptip
    (c_effective_date in date
    )
  is
  select ptip.ptip_id
  from ben_ptip_f ptip, ben_pl_f pl
  where ptip.pl_typ_id = pl.pl_typ_id
    and ptip.pgm_id = p_pgm_id
    and pl.pl_id = p_pl_id
    and    c_effective_date
           between ptip.effective_start_date
           and     ptip.effective_end_date
    and    c_effective_date
           between pl.effective_start_date
           and     pl.effective_end_date;

  l_ptip c_ptip%rowtype;


   --
  -- Join the apld eligibility profiles to the dependent coverage
  --      eligibility profile to weed out non-ACTIVE profiles
  --      Process mandatory first
  --
  cursor c_ade
           (c_lvl            varchar2
           ,c_effective_date date
           ,c_pgm_id         number
           ,c_ptip_id        number
           ,c_pl_id          number
           )
  is
    select ade.dpnt_cvg_eligy_prfl_id,
           ade.mndtry_flag,
           ade.apld_dpnt_cvg_elig_rl,                -- Bug No 4271143
           dce.dpnt_cvg_elig_det_rl,
           dce.dpnt_rlshp_flag,
           dce.dpnt_age_flag,
           dce.dpnt_stud_flag,
           dce.dpnt_dsbld_flag,
           dce.dpnt_mrtl_flag,
           dce.dpnt_mltry_flag,
           dce.dpnt_pstl_flag,
           dce.dpnt_crit_flag,                       -- Bug 9558250
           dce.dpnt_cvrd_in_anthr_pl_flag,
           dce.dpnt_dsgnt_crntly_enrld_flag
    from   ben_apld_dpnt_cvg_elig_prfl_f ade,
           ben_dpnt_cvg_eligy_prfl_f dce
    where  decode(c_lvl,
                  'PL',c_pl_id,
                  'PTIP',c_ptip_id,
                  'PGM', c_pgm_id) =
           decode(c_lvl,
                  'PL',ade.pl_id,
                  'PTIP',ade.ptip_id,
                  'PGM', ade.pgm_id)
    and    c_effective_date
           between ade.effective_start_date
           and     ade.effective_end_date
    and    dce.dpnt_cvg_eligy_prfl_id = ade.dpnt_cvg_eligy_prfl_id
    and    dce.dpnt_cvg_eligy_prfl_stat_cd = 'A'
    and    c_effective_date
           between dce.effective_start_date
           and     dce.effective_end_date
    order  by decode(ade.mndtry_flag,'Y',1,2);
  --
  l_ade c_ade%rowtype;
  --
  -- Bug 4271143 : Added c_ade1 to fetch records where no eligibility profile
  -- is attached, only dependent coverage eligibility rule is there
  --
  cursor c_ade1
           (c_lvl            varchar2
           ,c_effective_date date
           ,c_pgm_id         number
           ,c_ptip_id        number
           ,c_pl_id          number
           )
  is
    select ade.dpnt_cvg_eligy_prfl_id,
           ade.mndtry_flag,
           ade.apld_dpnt_cvg_elig_rl
    from   ben_apld_dpnt_cvg_elig_prfl_f ade
     where  decode(c_lvl,
                  'PL',c_pl_id,
                  'PTIP',c_ptip_id,
                  'PGM', c_pgm_id) =
           decode(c_lvl,
                  'PL',ade.pl_id,
                  'PTIP',ade.ptip_id,
                  'PGM', ade.pgm_id)
    and    c_effective_date
           between ade.effective_start_date
           and     ade.effective_end_date
    and ade.dpnt_cvg_eligy_prfl_id is null
    and ade.apld_dpnt_cvg_elig_rl is not null
    order  by decode(ade.mndtry_flag,'Y',1,2);
  --
  l_ade1 c_ade1%rowtype;
  --
  -- End 4271143
  --
  cursor c_per
    (c_effective_date in date
    )
  is
    select marital_status,
           on_military_service,
           student_status,
           registered_disabled_flag,
           effective_start_date
    from   per_all_people_f per
    where  per.person_id = p_contact_person_id
    and    c_effective_date
           between per.effective_start_date
           and     per.effective_end_date;
  --
  cursor c_previous_per (p_effective_date in date)
    is
    select marital_status,
           on_military_service,
           student_status,
           registered_disabled_flag
    from   per_all_people_f per
    where  per.person_id = p_contact_person_id
    and    p_effective_date
           between per.effective_start_date
           and     per.effective_end_date;

  l_per c_per%rowtype;
  l_previous_per c_previous_per%rowtype;
  --
  cursor c_add
    (c_effective_date in date
    )
  is
    select addr.postal_code,
           addr.date_from
    from   per_addresses addr
    where  addr.person_id = p_contact_person_id
    and    addr.primary_flag = 'Y'
    and    (c_effective_date >= addr.date_from
           or  addr.date_from is null)
    and    (c_effective_date <= addr.date_to
            or addr.date_to is null);
  --
  l_add c_add%rowtype;
  --
  cursor c_add2
    (c_effective_date in date
    )
  is
    select addr.postal_code,
           addr.date_from
    from   per_addresses addr
    where  addr.person_id = l_contact.person_id
    and    addr.primary_flag = 'Y'
    and    (c_effective_date >= addr.date_from
           or  addr.date_from is null)
    and    (c_effective_date <= addr.date_to
            or addr.date_to is null);
  --
  cursor c_pl_typ
    (c_effective_date in date
    )
  is
  select pl.pl_typ_id
  from ben_pl_f pl
  where pl.pl_id = p_pl_id
    and    c_effective_date
           between pl.effective_start_date
           and     pl.effective_end_date;

  l_pl_typ c_pl_typ%rowtype;

  cursor c_ler
    (c_effective_date in date
    )
  is
  select pil.ler_id
  from ben_per_in_ler pil
  where pil.per_in_ler_id = p_per_in_ler_id;

  l_ler c_ler%rowtype;

  cursor c_asg
    (c_effective_date in date
    )
  is
    select asg.assignment_id,asg.organization_id,loc.region_2
    from   per_all_assignments_f asg,hr_locations_all loc
    where  asg.person_id = l_contact.person_id
    and    asg.assignment_type <> 'C'
    and    asg.location_id = loc.location_id(+)
    and    asg.primary_flag='Y'
    and    c_effective_date
           between asg.effective_start_date
           and     asg.effective_end_date;
  --
  cursor c_opt
    (c_effective_date in date
    )
  is
  select oipl.opt_id
  from ben_oipl_f oipl
  where oipl.oipl_id = p_oipl_id
  and    c_effective_date
    between oipl.effective_start_date
      and     oipl.effective_end_date;

  l_opt c_opt%rowtype;


begin
  --
  hr_utility.set_location ('Entering '||l_proc,10);
  --
  -- Initialize the globals.
  --
  g_elig_change_dt   := null;
  g_dpnt_cvg_strt_dt := p_dpnt_cvg_strt_dt;
  g_effective_date   := nvl(p_lf_evt_ocrd_dt, p_effective_date);
  -- fonm
  l_effective_date   := nvl(p_lf_evt_ocrd_dt, p_effective_date);
  if ben_manage_life_events.fonm = 'Y'
      and ben_manage_life_events.g_fonm_cvg_strt_dt is not null then
     --
     l_fonm_cvg_strt_dt := ben_manage_life_events.g_fonm_cvg_strt_dt ;
     l_effective_date   := nvl(l_fonm_cvg_strt_dt,l_effective_date ) ;

     --
     hr_utility.set_location ('Fonm Date  '||g_effective_date ,10);
  end if;

  --
  hr_utility.set_location ('p_contact_person_id '||to_char(p_contact_person_id),10);
  hr_utility.set_location ('p_contact_relationship_id '||
            to_char(p_contact_relationship_id),10);
  hr_utility.set_location ('p_pgm_id:'||to_char(p_pgm_id)||
  ' p_pl_id:'||to_char(p_pl_id)||' p_ptip_id:'||to_char(p_ptip_id)||
  ' p_oipl_id:'||to_char(p_oipl_id),10);

  --
  -- If the eligibility is lost due to plan design type of issues
  --   Not related to the particular person then use effective_date
  --
  -- g_elig_change_dt   := nvl(p_lf_evt_ocrd_dt,p_effective_date)-1;
  --
  hr_utility.set_location ('Determining designation level ',20);

  if p_level is null then
    if p_pgm_id is not null then
      open c_pgm
        (c_effective_date => l_effective_date
        );
        fetch c_pgm into l_pgm;
        if c_pgm%notfound then
          close c_pgm;
          hr_utility.set_location ('BEN_91470_PGM_NOT_FOUND ',10);
          fnd_message.set_name('BEN','BEN_91470_PGM_NOT_FOUND');
          fnd_message.set_token('PROC',l_proc);
          fnd_message.set_token('PGM_ID',to_char(p_pgm_id));
          fnd_message.raise_error;
        end if;
      close c_pgm;
      l_level := l_pgm.dpnt_dsgn_lvl_cd;
    else
      l_level := 'PL';
    end if;
  else
    l_level := p_level;
  end if;
  --
  hr_utility.set_location ('l_level: '||l_level,20);

  -- In order to find ptip eligibility profiles, this was added:
  -- Bug 1167262
  l_ptip.ptip_id := p_ptip_id;
  if l_level = 'PTIP' and p_ptip_id is null and p_pgm_id is not null
     and p_pl_id is not null then
     open c_ptip
       (c_effective_date => l_effective_date
       );
     fetch c_ptip into l_ptip;
     close c_ptip;
  end if;

  --
  -- Note:
  -- contact must be opened before other cursors in order
  --   to get the person_id (of the participant) used to
  --   use per_in_ler_id, but this may be null from bendsgel
  --
  open c_contact
    (c_effective_date => l_effective_date
    );
    --
    fetch c_contact into l_contact;
    if c_contact%notfound then
      --
      close c_contact;
      hr_utility.set_location ('BEN_91480_MISSING_CONTACT_REL ',10);
      fnd_message.set_name('BEN','BEN_91480_MISSING_CONTACT_REL');
      fnd_message.set_token('PROC',l_proc);
      fnd_message.set_token('CONT_RLSHP_ID',to_char(p_contact_relationship_id));
      fnd_message.set_token('LF_EVT_OCRD_DT',to_char(p_lf_evt_ocrd_dt));
      fnd_message.set_token('EFFECTIVE_DATE',to_char(p_effective_date));
      fnd_message.raise_error;
      --
    end if;
    --
  close c_contact;
  --
  -- If the contact relationship has been ended as of the effective date then
  -- the contact should no longer be eligible.
  --
  if l_contact.date_end < p_effective_date then
     --
     l_eligible_flag := 'N';
     l_inelig_rsn_cd := 'REL';
     set_elig_change_dt(p_elig_change_dt => l_contact.date_end,p_effective_date => l_effective_date); -- bug 4546890
     -- g_elig_change_dt := l_contact.date_end;
     --
  end if;
  --
  -- If its an option in plan then the contact type
  --  must be valid for the electable choice contact type
  --
  if l_eligible_flag = 'Y' and
     p_oipl_id is not null then
    --
    -- Must match up with contact relationship type cd
    --
    --  If there are no designation requirements for the comp object
    --  then any number or type of dependents can be designated.
    --
    hr_utility.set_location ('c_dsgn'||l_eligible_flag,20);
    --
    open c_dsgn
      (c_effective_date => l_effective_date
      );
      --
      fetch c_dsgn into l_exists;
      --
      if c_dsgn%notfound then
        --
        l_eligible_flag := 'Y';
        l_inelig_rsn_cd := null;
        --
      else
        --
        -- if there is a designation requirement for the contact_type.
        --
        hr_utility.set_location ('c_dsgn_rl_typ'||l_eligible_flag,20);
        --
        open c_dsgn_rl_typ
          (c_effective_date => l_effective_date,
           p_contact_type   => l_contact.contact_type
          );
          --
          fetch c_dsgn_rl_typ into l_exists;
          if c_dsgn_rl_typ%notfound then
            --
            l_eligible_flag := 'N';
            l_inelig_rsn_cd := 'REL';
            --
            -- Check if there is a designation requirement for any
            -- relationship type. If there is one, check if there are
            -- other designation requirements defined for other contact
            -- type.  If there are, the dependent is not eligible.
            --
            open c_dsgn_grp
              (c_effective_date => l_effective_date
              );
              --
              fetch c_dsgn_grp into l_exists;
              if c_dsgn_grp%found then
                --
                hr_utility.set_location ('c_dsgn_grp'||l_eligible_flag,20);
                l_eligible_flag := 'Y';
                l_inelig_rsn_cd := null;
                --
                open c_dsgn_not_rl_typ
                  (c_effective_date => l_effective_date
                  );
                  --
                  fetch c_dsgn_not_rl_typ into l_exists;
                  if c_dsgn_not_rl_typ%found then
                    --
                    hr_utility.set_location ('c_dsgn_not_rl_typ'||
                                         l_eligible_flag,20);
                    l_eligible_flag := 'N';
                    l_inelig_rsn_cd := 'REL';
                    --
                  end if;
                  --
                close c_dsgn_not_rl_typ;
                --
              end if;
              --
            close c_dsgn_grp;
            --
          end if;
          --
        close c_dsgn_rl_typ;
        --
      end if;
      --
    close c_dsgn;
    --
  end if;
  --
  --bug#4318031 - need to go through other contact types with person flag
  if l_eligible_flag = 'N' then
    --
    open c_contact2(l_effective_date);
    loop
      fetch c_contact2 into l_contact_type2;
      if c_contact2%notfound then
        exit;
      end if;
      open c_dsgn_rl_typ(l_effective_date, l_contact_type2);
      fetch c_dsgn_rl_typ into l_exists;
      if c_dsgn_rl_typ%found then
       --
        l_eligible_flag := 'Y';
        close c_dsgn_rl_typ;
        exit;
        --
      end if;
      close c_dsgn_rl_typ;
    end loop;
    --
    close c_contact2;
    --
  end if;
  hr_utility.set_location ('eligible flag'||l_eligible_flag,30);
  --
  -- Loop through all profiles
  --
  if l_eligible_flag = 'Y' then
      hr_utility.set_location (l_proc||' l_eligible_flag=Y ',10);
    --
    -- Eventally call the cache
    --
    open c_per
       (c_effective_date => l_effective_date
       );
      --
      fetch c_per into l_per;
      --
      if c_per%notfound then
        --
        close c_per;
        hr_utility.set_location ('BEN_91481_INVALID_PERSON ',10);
        fnd_message.set_name('BEN','BEN_91481_INVALID_PERSON');
        fnd_message.set_token('PROC',l_proc);
        fnd_message.set_token('CONT_PER_ID',to_char(p_contact_person_id));
        fnd_message.raise_error;
        --
      end if;
      --
    close c_per;
    --
   /*
    -- Get address info
    --
    open c_add
       (c_effective_date => l_effective_date
       );
      --
      fetch c_add into l_add;
      if c_add%notfound and
        l_contact.rltd_per_rsds_w_dsgntr_flag='N' then
        --
        close c_add;
        hr_utility.set_location ('BEN_91482_INVALID_ADDRESS ',10);
        fnd_message.set_name('BEN','BEN_91482_INVALID_ADDRESS');
        fnd_message.set_token('PROC',l_proc);
        fnd_message.set_token('CONT_PER_ID',to_char(p_contact_person_id));
        raise ben_manage_life_events.g_record_error;
        --
      elsif c_add%notfound and
        l_contact.rltd_per_rsds_w_dsgntr_flag='Y' then
        --
        open c_add2
          (c_effective_date => l_effective_date
          );
          --
          fetch c_add2 into l_add;
          if c_add2%notfound then
            hr_utility.set_location ('BEN_91482_INVALID_ADDRESS - c_add2 ',10);
            fnd_message.set_name('BEN','BEN_91482_INVALID_ADDRESS');
            fnd_message.set_token('PROC',l_proc);
            fnd_message.set_token('CONT_PER_ID',to_char(l_contact.person_id));
            raise ben_manage_life_events.g_record_error;
            --
          end if;
          --
        close c_add2;
        --
      end if;
      --
    close c_add;
    */
    --
    -- If the eligibility is lost due to person info then
    --   use the date on which the person_info was changed
    -- Note: overridden in check_age_elig for that case
    --       overridden for postal elig for that case
    --
    -- g_elig_change_dt:=l_per.effective_start_date-1;
    --
    hr_utility.set_location ('  g_elig_change_dt '||to_char(g_elig_change_dt),40);
    open c_ade
           (c_lvl            => l_level
           ,c_effective_date => l_effective_date
           ,c_pgm_id         => p_pgm_id
           ,c_ptip_id        => l_ptip.ptip_id
           ,c_pl_id          => p_pl_id
           );
      --
      loop
        --
        -- All mandatory profiles are processed first
        --
        fetch c_ade into l_ade;
        exit when c_ade%notfound;
        --
        -- Check all the factors for this profile
        --
        l_eligible_flag := 'Y';
        --
        /* moved the check at the end
        if l_ade.dpnt_age_flag = 'Y' then
          --
          check_age_elig
          (p_eligy_prfl_id     => l_ade.dpnt_cvg_eligy_prfl_id,
           p_person_id         => p_contact_person_id,
           p_contact_person_id => l_contact.person_id,
           p_pgm_id            => p_pgm_id,
           p_pl_id             => p_pl_id,
           p_oipl_id           => p_oipl_id,
           p_business_group_id => p_business_group_id,
           p_per_in_ler_id     => p_per_in_ler_id,
           p_effective_date    => p_effective_date,
           p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
           p_eligible_flag     => l_eligible_flag,
           p_inelig_rsn_cd     => l_inelig_rsn_cd);
          --
          hr_utility.set_location ('eligible flag'||l_eligible_flag,40);
          exit when (l_ade.mndtry_flag = 'Y' and l_eligible_flag <> 'Y');
          --
        end if;
        --
        */
        if l_ade.dpnt_rlshp_flag = 'Y' and
          l_eligible_flag = 'Y' then
          --
          check_contact_elig
          (p_eligy_prfl_id     => l_ade.dpnt_cvg_eligy_prfl_id,
           p_person_id         => p_contact_person_id,
           p_contact_person_id => l_contact.person_id, -- Bug 6956648
           p_business_group_id => p_business_group_id,
           p_effective_date    => p_effective_date,
           p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
           p_contact_type      => l_contact.contact_type,
           p_eligible_flag     => l_eligible_flag,
           p_inelig_rsn_cd     => l_inelig_rsn_cd);
          --
          --bug#4157836 - contact relationship is not a datetracked table and
          --end of relationship is checked first before processing
          /*
          if l_eligible_flag <> 'Y' then
            set_elig_change_dt(p_elig_change_dt=>l_per.effective_start_date-1);
          end if;
          */
          --
          hr_utility.set_location ('eligible flag'||l_eligible_flag,80);
          exit when (l_ade.mndtry_flag = 'Y' and l_eligible_flag <> 'Y');
          --
        end if;
        --
        if l_eligible_flag = 'Y' then
          --
          -- Run eligibility rule
          --
          if l_ade.dpnt_cvg_elig_det_rl is not null or
	         l_ade.apld_dpnt_cvg_elig_rl is not null then  -- Bug 4271143 Added apld_dpnt_cvg_elig_rl condition also
            --
            if p_pl_id is not null then
              --
              open c_pl_typ
                (c_effective_date => l_effective_date
                );
                --
                fetch c_pl_typ into l_pl_typ;
                --
              close c_pl_typ;
              --
            end if;
            --
            if p_oipl_id is not null then
              --
              open c_opt
                (c_effective_date => l_effective_date
                );
                --
                fetch c_opt into l_opt;
                --
              close c_opt;
              --
            end if;
            --
            if p_per_in_ler_id is not null then
              --
              open c_ler
                (c_effective_date => l_effective_date
                );
                --
                fetch c_ler into l_ler;
                --
              close c_ler;
              --
            end if;
            --
            open c_asg
              (c_effective_date => l_effective_date
              );
              --
              fetch c_asg into l_assignment_id,l_organization_id,l_region_2;
              --
            close c_asg;
            --
            /*
            if l_region_2 is not null then
              --
              l_jurisdiction_code := pay_mag_utils.lookup_jurisdiction_code
                                     (p_state => l_region_2);
              --
            end if;
            */
            --
            -- l_contact.person_id is passed, as the assignment id may not be
            -- available all the time. This is a work around to access the
            -- contact person data. Customer have to write the formula function.
            --
       if l_ade.dpnt_cvg_elig_det_rl is not null then
             l_outputs := benutils.formula
              (p_formula_id        => l_ade.dpnt_cvg_elig_det_rl,
               p_effective_date    => nvl(p_lf_evt_ocrd_dt,p_effective_date),
               p_business_group_id => p_business_group_id,
               p_assignment_id     => l_assignment_id,
               p_organization_id   => l_organization_id,
               p_pgm_id            => p_pgm_id,
               p_pl_id             => p_pl_id,
               p_pl_typ_id         => l_pl_typ.pl_typ_id,
               p_opt_id            => l_opt.opt_id,
               p_ler_id            => l_ler.ler_id,
               p_param1            => 'CON_PERSON_ID',
               p_param1_value      => to_char(p_contact_person_id),
               p_jurisdiction_code => l_jurisdiction_code);
            --
            l_eligible_flag := l_outputs(l_outputs.first).value;
            --
            if l_eligible_flag = 'Y' then
              --
              l_inelig_rsn_cd := null;
              --
            else
              --
              l_inelig_rsn_cd := 'AGE';
	      --hr_utility.set_location('** SUP l_effective_date-1'||l_effective_date,900);
	      set_elig_change_dt(p_elig_change_dt=>l_effective_date-1,p_effective_date => l_effective_date); -- bug 4546890
              --
            end if;
            --
	  end if;
	  --
          --  Bug 4271143 Added apld_dpnt_cvg_elig_rl condition also as if
	  -- Coverage Eligibility Rule is specified, then it should also evaluate to true
	  --
          if l_ade.apld_dpnt_cvg_elig_rl is not null then
            l_outputs := benutils.formula
              (p_formula_id        => l_ade.apld_dpnt_cvg_elig_rl,
               p_effective_date    => nvl(p_lf_evt_ocrd_dt,p_effective_date),
               p_business_group_id => p_business_group_id,
               p_assignment_id     => l_assignment_id,
               p_organization_id   => l_organization_id,
               p_pgm_id            => p_pgm_id,
               p_pl_id             => p_pl_id,
               p_pl_typ_id         => l_pl_typ.pl_typ_id,
               p_opt_id            => l_opt.opt_id,
               p_ler_id            => l_ler.ler_id,
               p_param1            => 'CON_PERSON_ID',
               p_param1_value      => to_char(p_contact_person_id),
               p_jurisdiction_code => l_jurisdiction_code);
            --
            l_apld_eligible_flag := l_outputs(l_outputs.first).value;
            --
            if l_apld_eligible_flag = 'Y' then
              --
              l_inelig_rsn_cd := null;
              --
            else
              --
              l_inelig_rsn_cd := 'AGE';
	      --hr_utility.set_location('** SUP l_effective_date'||l_effective_date,901);
	      set_elig_change_dt(p_elig_change_dt=>l_effective_date-1,p_effective_date => l_effective_date); -- bug 4546890
              --
            end if;
            --
	  end if;
	  --
          end if;
          --
          exit when (l_ade.mndtry_flag = 'Y' and (l_eligible_flag <> 'Y' or l_apld_eligible_flag <> 'Y'));
          --
        end if;
        --
        hr_utility.set_location ('apld dep eligible flag'||l_apld_eligible_flag,50);
	--
	-- End 4271143
	--
        hr_utility.set_location ('eligible flag'||l_eligible_flag,50);
        --
        if l_ade.dpnt_mrtl_flag = 'Y' and
          l_eligible_flag = 'Y' then
          --
          check_marital_elig
          (p_eligy_prfl_id     => l_ade.dpnt_cvg_eligy_prfl_id,
           p_person_id         => p_contact_person_id,
           p_business_group_id => p_business_group_id,
           p_effective_date    => p_effective_date,
           p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
           p_marital_cd        => l_per.marital_status,
           p_eligible_flag     => l_eligible_flag,
           p_inelig_rsn_cd     => l_inelig_rsn_cd);
          --
          if l_eligible_flag <> 'Y' then
            -- check previous value
            open c_previous_per(l_per.effective_start_date-1);
            fetch c_previous_per into l_previous_per;
            if c_previous_per%found and nvl(l_previous_per.marital_status,'X')<>
                nvl(l_per.marital_status,'X') then
              set_elig_change_dt(p_elig_change_dt=>l_per.effective_start_date-1,p_effective_date => l_effective_date); -- bug 4546890
            end if;
            close c_previous_per;
          end if;
          --
          exit when (l_ade.mndtry_flag = 'Y' and l_eligible_flag <> 'Y');
          --
        end if;
        --
        hr_utility.set_location ('eligible flag'||l_eligible_flag,50);
        --
        if l_ade.dpnt_mltry_flag = 'Y' and
          l_eligible_flag = 'Y' then
          --
          check_military_elig
          (p_eligy_prfl_id     => l_ade.dpnt_cvg_eligy_prfl_id,
           p_person_id         => p_contact_person_id,
           p_business_group_id => p_business_group_id,
           p_effective_date    => p_effective_date,
           p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
           p_military_service  => l_per.on_military_service,
           p_eligible_flag     => l_eligible_flag,
           p_inelig_rsn_cd     => l_inelig_rsn_cd);
          --
          if l_eligible_flag <> 'Y' then
            --check previous status
            open c_previous_per(l_per.effective_start_date-1);
            fetch c_previous_per into l_previous_per;
            if c_previous_per%found and nvl(l_previous_per.on_military_service,'X')<>
                nvl(l_per.on_military_service,'X') then
              set_elig_change_dt(p_elig_change_dt=>l_per.effective_start_date-1,p_effective_date => l_effective_date); -- bug 4546890
            end if;
            close c_previous_per;
          end if;
          --
          exit when (l_ade.mndtry_flag = 'Y' and l_eligible_flag <> 'Y');
          --
        end if;
        --
        hr_utility.set_location ('eligible flag'||l_eligible_flag,60);
        --
        if l_ade.dpnt_stud_flag = 'Y' and
          l_eligible_flag = 'Y' then
          --
          check_student_elig
          (p_eligy_prfl_id     => l_ade.dpnt_cvg_eligy_prfl_id,
           p_person_id         => p_contact_person_id,
           p_business_group_id => p_business_group_id,
           p_effective_date    => p_effective_date,
           p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
           p_student_status    => l_per.student_status,
           p_eligible_flag     => l_eligible_flag,
           p_inelig_rsn_cd     => l_inelig_rsn_cd);
          --
          if l_eligible_flag <> 'Y' then
            --check previous status
            open c_previous_per(l_per.effective_start_date-1);
            fetch c_previous_per into l_previous_per;
            if c_previous_per%found and nvl(l_previous_per.student_status,'X')<>
                nvl(l_per.student_status,'X') then
              set_elig_change_dt(p_elig_change_dt=>l_per.effective_start_date-1,p_effective_date => l_effective_date); -- bug 4546890
            end if;
            close c_previous_per;
          end if;
          --
          hr_utility.set_location ('eligible flag'||l_eligible_flag,70);
          exit when (l_ade.mndtry_flag = 'Y' and l_eligible_flag <> 'Y');
          --
        end if;
        --
        /* for performance reason the relationship criteria is checked first and age
           factor at the end
        if l_ade.dpnt_rlshp_flag = 'Y' and
          l_eligible_flag = 'Y' then
          --
          check_contact_elig
          (p_eligy_prfl_id     => l_ade.dpnt_cvg_eligy_prfl_id,
           p_person_id         => p_contact_person_id,
           p_contact_person_id => l_contact.person_id, -- Bug 6956648
           p_business_group_id => p_business_group_id,
           p_effective_date    => p_effective_date,
           p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
           p_contact_type      => l_contact.contact_type,
           p_eligible_flag     => l_eligible_flag,
           p_inelig_rsn_cd     => l_inelig_rsn_cd);
          --
          if l_eligible_flag <> 'Y' then
            set_elig_change_dt(p_elig_change_dt=>l_per.effective_start_date-1);
          end if;
          --
          hr_utility.set_location ('eligible flag'||l_eligible_flag,80);
          exit when (l_ade.mndtry_flag = 'Y' and l_eligible_flag <> 'Y');
          --
        end if;
        */
        --
        if l_ade.dpnt_dsbld_flag = 'Y' and
          l_eligible_flag = 'Y' then
          --
          check_disabled_elig
          (p_eligy_prfl_id     => l_ade.dpnt_cvg_eligy_prfl_id,
           p_person_id         => p_contact_person_id,
           p_business_group_id => p_business_group_id,
           p_effective_date    => p_effective_date,
           p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
           p_per_dsbld_type    => l_per.registered_disabled_flag,
           p_eligible_flag     => l_eligible_flag,
           p_inelig_rsn_cd     => l_inelig_rsn_cd);
          --
          if l_eligible_flag <> 'Y' then
            -- check the previous value
            open c_previous_per(l_per.effective_start_date-1);
            fetch c_previous_per into l_previous_per;
            if c_previous_per%found and nvl(l_previous_per.registered_disabled_flag,'X')<>
                nvl(l_per.registered_disabled_flag,'X') then
              set_elig_change_dt(p_elig_change_dt=>l_per.effective_start_date-1,p_effective_date => l_effective_date); -- bug 4546890
            end if;
            close c_previous_per;
          end if;
          --
          hr_utility.set_location ('eligible flag'||l_eligible_flag,90);
          exit when (l_ade.mndtry_flag = 'Y' and l_eligible_flag <> 'Y');
          --
        end if;
        --
        if l_ade.dpnt_pstl_flag = 'Y' and
          l_eligible_flag = 'Y' then
          --- Beofre calling postal eligibility check whehter the address/share address is defined
          --
         hr_utility.set_location('postal flag ',  219);
         open c_add
              (c_effective_date => l_effective_date
               );
               --
               fetch c_add into l_add;
               if c_add%notfound and  l_contact.rltd_per_rsds_w_dsgntr_flag='N' then
                  --
                  --close c_add;
                  hr_utility.set_location ('BEN_91482_INVALID_ADDRESS ',10);
                 hr_utility.set_location ('contact '|| l_contact.rltd_per_rsds_w_dsgntr_flag ,10);
                  --fnd_message.set_name('BEN','BEN_91482_INVALID_ADDRESS');
                  --fnd_message.set_token('PROC',l_proc);
                  --fnd_message.set_token('CONT_PER_ID',to_char(p_contact_person_id));
                  --raise ben_manage_life_events.g_record_error;

               elsif c_add%notfound and  l_contact.rltd_per_rsds_w_dsgntr_flag='Y' then
                  --
                  open c_add2
                      (c_effective_date => l_effective_date
                       );
                      --
                  fetch c_add2 into l_add;
                  if c_add2%notfound then

            hr_utility.set_location ('contact '|| l_contact.rltd_per_rsds_w_dsgntr_flag ,10);
                     hr_utility.set_location ('BEN_91482_INVALID_ADDRESS - c_add2 ',10);
                     --fnd_message.set_name('BEN','BEN_91482_INVALID_ADDRESS');
                     --fnd_message.set_token('PROC',l_proc);
                     --fnd_message.set_token('CONT_PER_ID',to_char(l_contact.person_id));
                     --raise ben_manage_life_events.g_record_error;
                     --
                  end if;
                  --
                  close c_add2;
                  --
               end if;
               --
          close c_add;
          --
          hr_utility.set_location ('calling check_postal ' ,10);
          check_postal_elig
          (p_eligy_prfl_id     => l_ade.dpnt_cvg_eligy_prfl_id,
           p_person_id         => p_contact_person_id,
           p_business_group_id => p_business_group_id,
           p_effective_date    => p_effective_date,
           p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
           p_postal_code       => l_add.postal_code,
           p_eligible_flag     => l_eligible_flag,
           p_inelig_rsn_cd     => l_inelig_rsn_cd);
          --
          if l_eligible_flag<>'Y' and l_add.date_from is not null then
            --
            -- set the change date to the address change date
            --
            set_elig_change_dt(p_elig_change_dt => l_add.date_from-1,p_effective_date => l_effective_date); -- bug 4546890
            -- g_elig_change_dt:=l_add.date_from-1;
            --
          end if;
          --
          hr_utility.set_location ('eligible flag'||l_eligible_flag,100);
          exit when (l_ade.mndtry_flag = 'Y' and l_eligible_flag <> 'Y');
          --
        end if;
        --
        -- Bug 9558250
        if l_ade.dpnt_crit_flag  = 'Y' and
          l_eligible_flag = 'Y' then

          ben_evl_dpnt_elig_criteria.main
          (p_dpnt_cvg_eligy_prfl_id =>  l_ade.dpnt_cvg_eligy_prfl_id,
           p_person_id         => p_contact_person_id,
           p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
           p_business_group_id => p_business_group_id,
           p_effective_date    => p_effective_date,
           p_eligible_flag     => l_eligible_flag,
           p_inelig_rsn_cd     => l_inelig_rsn_cd);

          --
          if l_eligible_flag <> 'Y' then
            set_elig_change_dt(p_elig_change_dt=>l_per.effective_start_date-1,p_effective_date => l_effective_date);-- bug 4546890
          end if;
          --
          hr_utility.set_location ('eligible flag'||l_eligible_flag,110);
          exit when (l_ade.mndtry_flag = 'Y' and l_eligible_flag <> 'Y');
          --
        end if;

        -- Bug 9558250

        if l_ade.dpnt_cvrd_in_anthr_pl_flag  = 'Y' and
          l_eligible_flag = 'Y' then
          --
          check_cvrd_anthr_pl_elig
          (p_eligy_prfl_id     => l_ade.dpnt_cvg_eligy_prfl_id,
           p_person_id         => p_contact_person_id,
           p_business_group_id => p_business_group_id,
           p_effective_date    => p_effective_date,
           p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
           p_pl_id             => p_pl_id,
           p_eligible_flag     => l_eligible_flag,
           p_inelig_rsn_cd     => l_inelig_rsn_cd);
          --
          if l_eligible_flag <> 'Y' then
            set_elig_change_dt(p_elig_change_dt=>l_per.effective_start_date-1,p_effective_date => l_effective_date);-- bug 4546890
          end if;
          --
          hr_utility.set_location ('eligible flag'||l_eligible_flag,110);
          exit when (l_ade.mndtry_flag = 'Y' and l_eligible_flag <> 'Y');
          --
        end if;
        --
        if l_ade.dpnt_age_flag = 'Y'  and
             l_eligible_flag = 'Y' then
          --
          check_age_elig
          (p_eligy_prfl_id     => l_ade.dpnt_cvg_eligy_prfl_id,
           p_person_id         => p_contact_person_id,
           p_contact_person_id => l_contact.person_id,
           p_pgm_id            => p_pgm_id,
           p_pl_id             => p_pl_id,
           p_oipl_id           => p_oipl_id,
           p_business_group_id => p_business_group_id,
           p_per_in_ler_id     => p_per_in_ler_id,
           p_effective_date    => p_effective_date,
           p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
           p_eligible_flag     => l_eligible_flag,
           p_inelig_rsn_cd     => l_inelig_rsn_cd);
          --
          hr_utility.set_location ('eligible flag'||l_eligible_flag,40);
          exit when (l_ade.mndtry_flag = 'Y' and l_eligible_flag <> 'Y');
          --
        end if;
        --
        if l_ade.dpnt_dsgnt_crntly_enrld_flag = 'Y' and
          l_eligible_flag = 'Y' then
          --
          check_dsgntr_enrld_cvg_elig
          (p_eligy_prfl_id     => l_ade.dpnt_cvg_eligy_prfl_id,
           p_person_id         => p_contact_person_id,
           p_dsgntr_id         => l_contact.person_id,
           p_business_group_id => p_business_group_id,
           p_effective_date    => p_effective_date,
           p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
           p_pgm_id            => p_pgm_id,
           p_eligible_flag     => l_eligible_flag,
           p_inelig_rsn_cd     => l_inelig_rsn_cd);
          --
          if l_eligible_flag <> 'Y' then
            set_elig_change_dt(p_elig_change_dt=>l_per.effective_start_date-1,p_effective_date => l_effective_date); -- bug 4546890
          end if;
          --
          hr_utility.set_location ('eligible flag'||l_eligible_flag,110);
          exit when (l_ade.mndtry_flag = 'Y' and l_eligible_flag <> 'Y');
          --
        end if;
        --
        exit when (l_ade.mndtry_flag <> 'Y' and l_eligible_flag = 'Y');
        --
      end loop;
      --
    close c_ade;
  --
  -- Bug 4271143 : Fetch from c_ade1 for records where no eligibility profile
  -- is attached, only dependent coverage eligibility rule is there
  --
    hr_utility.set_location('eligible flag'||l_eligible_flag,115);
    hr_utility.set_location ('apld dep eligible flag'||l_apld_eligible_flag,115);
    -- fetch only if till now all the profiles with mandatory flag on have been satisfied
   if (not(l_ade.mndtry_flag = 'Y' and (l_eligible_flag <> 'Y' or l_apld_eligible_flag <> 'Y'))) then
   open c_ade1
           (c_lvl            => l_level
           ,c_effective_date => l_effective_date
           ,c_pgm_id         => p_pgm_id
           ,c_ptip_id        => l_ptip.ptip_id
           ,c_pl_id          => p_pl_id
           );
      --
      loop
        --
        -- All mandatory profiles are processed first
        --
        fetch c_ade1 into l_ade1;
        exit when c_ade1%notfound;
	  if l_apld_eligible_flag = 'Y' then
	  --
          -- Run eligibility rule
          --
          if l_ade1.apld_dpnt_cvg_elig_rl is not null then
            --
            if p_pl_id is not null then
              --
              open c_pl_typ
                (c_effective_date => l_effective_date
                );
                --
                fetch c_pl_typ into l_pl_typ;
                --
              close c_pl_typ;
              --
            end if;
            --
            if p_oipl_id is not null then
              --
              open c_opt
                (c_effective_date => l_effective_date
                );
                --
                fetch c_opt into l_opt;
                --
              close c_opt;
              --
            end if;
            --
            if p_per_in_ler_id is not null then
              --
              open c_ler
                (c_effective_date => l_effective_date
                );
                --
                fetch c_ler into l_ler;
                --
              close c_ler;
              --
            end if;
            --
            open c_asg
              (c_effective_date => l_effective_date
              );
              --
              fetch c_asg into l_assignment_id,l_organization_id,l_region_2;
              --
            close c_asg;
            --
            l_outputs := benutils.formula
              (p_formula_id        => l_ade1.apld_dpnt_cvg_elig_rl,
               p_effective_date    => nvl(p_lf_evt_ocrd_dt,p_effective_date),
               p_business_group_id => p_business_group_id,
               p_assignment_id     => l_assignment_id,
               p_organization_id   => l_organization_id,
               p_pgm_id            => p_pgm_id,
               p_pl_id             => p_pl_id,
               p_pl_typ_id         => l_pl_typ.pl_typ_id,
               p_opt_id            => l_opt.opt_id,
               p_ler_id            => l_ler.ler_id,
               p_param1            => 'CON_PERSON_ID',
               p_param1_value      => to_char(p_contact_person_id),
               p_jurisdiction_code => l_jurisdiction_code);
            --
              l_apld_eligible_flag := l_outputs(l_outputs.first).value;
	    --
            if l_apld_eligible_flag = 'Y' then
              --
              l_inelig_rsn_cd := null;
              --
            else
              --
              l_inelig_rsn_cd := 'AGE';
	      --hr_utility.set_location('** SUP l_effective_date-1'||l_effective_date,902);
	      set_elig_change_dt(p_elig_change_dt=>l_effective_date-1,p_effective_date => l_effective_date); -- bug 4546890
              --
            end if;
            --
	  end if;
	  --
          end if;
          --
          exit when (l_ade1.mndtry_flag = 'Y' and l_apld_eligible_flag <> 'Y');
          --
       hr_utility.set_location ('apld dep eligible flag'||l_apld_eligible_flag,115);
    end loop;
    close c_ade1;
  --
  end if;
  --
  -- End 4271143
  --
  end if;
  --
  if g_elig_change_dt is null then
    --
    -- If the eligibility is lost due to plan design type of issues
    --   Not related to the particular person then use effective_date
    --
    set_elig_change_dt
        (p_elig_change_dt => l_effective_date-1,p_effective_date => l_effective_date); -- bug 4546890
    --
  end if;
  --
  hr_utility.set_location ('eligible flag'||l_eligible_flag,120);
  hr_utility.set_location ('apld eligible flag'||l_apld_eligible_flag,120);
  --
  if (l_apld_eligible_flag = 'N') then                            --  Bug 4271143
       l_eligible_flag := 'N';
  end if;
  --
  p_dependent_eligible_flag    := l_eligible_flag;
  p_dpnt_inelig_rsn_cd         := l_inelig_rsn_cd;
  --
  hr_utility.set_location ('Leaving'||l_proc,130);
  --
end main;
--
procedure check_age_elig
         (p_eligy_prfl_id     in number,
          p_person_id         in number,
          p_contact_person_id in number,
          p_pgm_id            in number,
          p_pl_id             in number,
          p_oipl_id           in number,
          p_business_group_id in number,
          p_per_in_ler_id     in number,
          p_effective_date    in date,
          p_lf_evt_ocrd_dt    in date,
          p_eligible_flag     out nocopy varchar2,
          p_inelig_rsn_cd     out nocopy varchar2) is

  --
  l_proc              varchar2(100):= g_package||'.check_age_elig';
  l_found_one         varchar2(10) := 'N';
  l_elig              varchar2(10) := 'N';
  l_eligy_prfl_id     number(15)   := p_eligy_prfl_id;
  l_bg_id             number(15)   := p_business_group_id;
  l_effective_date    date         := p_effective_date;
  l_age               number;
  l_pgm_id            number(15)   := p_pgm_id;
  l_pl_id             number(15)   := p_pl_id;
  l_oipl_id           number(15)   := p_oipl_id;
  l_change_date       date;
  l_elig_change_dt    date         := null;
  l_dob               date;
  l_check_dob         boolean := true;
  l_max_age_number    number ;
  --fonm
  l_fonm_cvg_strt_dt  date ;
  l_defct_brch_dtctd varchar2(100) := null;
  --
  -- cursor to get the dob (if null will be inelig)
  --
  cursor   c_per is
    select date_of_birth
    from   per_all_people_f per
    where  per.person_id = p_person_id
    and    per.business_group_id = p_business_group_id
    and    l_effective_date
           between per.effective_start_date
           and     per.effective_end_date;
  --
  --  Cursor to grab age requirement for eligibility profile.
  --
  cursor c_age_check is
    select agf.mx_age_num,
           agf.mn_age_num,
           agf.age_uom,
           agf.no_mn_age_flag,
           agf.no_mx_age_flag,
           eac.excld_flag,
           eac.age_fctr_id
    from   ben_age_fctr agf,
           ben_elig_age_cvg_f  eac
    where  agf.age_fctr_id = eac.age_fctr_id
    and    agf.business_group_id   = p_business_group_id
    and    eac.dpnt_cvg_eligy_prfl_id = p_eligy_prfl_id
    and    eac.business_group_id   = p_business_group_id
    and    l_effective_date
           between eac.effective_start_date
           and     eac.effective_end_date;
  --
begin
  --
  hr_utility.set_location('Entering :'||l_proc, 10);
  hr_utility.set_location('PERSON ID :'||p_person_id, 10);
  hr_utility.set_location('BUSINESS_GROUP_ID :'||p_business_group_id, 10);
  hr_utility.set_location('EFFECTIVE_DATE :'||p_effective_date, 10);
  hr_utility.set_location('LIFE_EVENT_DATE :'||p_lf_evt_ocrd_dt, 10);
  hr_utility.set_location('PROFILE_ID :'||p_eligy_prfl_id, 10);
  --

   -- fonm
  l_effective_date  :=  nvl(p_lf_evt_ocrd_dt,p_effective_date ) ;
  if ben_manage_life_events.fonm = 'Y'
      and ben_manage_life_events.g_fonm_cvg_strt_dt is not null then
     --
     l_fonm_cvg_strt_dt := ben_manage_life_events.g_fonm_cvg_strt_dt ;
     l_effective_date   := nvl(l_fonm_cvg_strt_dt,l_effective_date ) ;

     --
     hr_utility.set_location ('Fonm Date  '||l_effective_date ,10);
  end if;



  for age in c_age_check loop
    --
    l_found_one := 'Y';
    --
    --  If person does not have a date of birth then he/she
    --  is not eligible.
    --
    if l_check_dob = true then
      hr_utility.set_location('HERE',10);
      open c_per;
      fetch c_per into l_dob;
      close c_per;
      if l_dob is null then
        l_elig := 'N';
        exit;
      end if;
      l_check_dob := false;
    end if;
    --
    -- Feed in proper ID
    -- This may not be correct logic
    --
    if l_oipl_id is not null then
      l_pl_id := null;
      l_pgm_id := null;
    elsif l_pl_id is not null then
      l_pgm_id := null;
    end if;
    --
    hr_utility.set_location('XXXX AGE = '||l_age,10);
    hr_utility.set_location('XXXX DOB = '||l_dob,10);
    hr_utility.set_location('XXXX MIN = '||age.mn_age_num,10);
    hr_utility.set_location('XXXX MAX = '||age.mx_age_num,10);
    hr_utility.set_location('XXXX EXCLD = '||age.excld_flag,10);
    --
    ben_derive_factors.determine_age
      (p_person_id            => p_person_id ,
       p_per_dob              => l_dob,
       p_age_fctr_id          => age.age_fctr_id,
       p_pgm_id               => l_pgm_id,
       p_pl_id                => l_pl_id ,
       p_oipl_id              => l_oipl_id ,
       p_per_in_ler_id        => p_per_in_ler_id,
       p_effective_date       => p_effective_date,
       p_lf_evt_ocrd_dt       => p_lf_evt_ocrd_dt,
       p_business_group_id    => p_business_group_id,
       p_perform_rounding_flg => true,
       p_value                => l_age,
       p_change_date          => l_change_date,
       p_parent_person_id     => p_contact_person_id,
       p_fonm_cvg_strt_dt     => l_fonm_cvg_strt_dt );
    --
    hr_utility.set_location('XXXX AGE = '||l_age,10);
    hr_utility.set_location('XXXX DOB  = '||l_dob,10);
    hr_utility.set_location('XXXX DOB = '||l_change_date,1965);
    hr_utility.set_location('XXXX MIN = '||age.mn_age_num,10);
    hr_utility.set_location('XXXX MAX = '||age.mx_age_num,10);
    hr_utility.set_location('XXXX EXCLD = '||age.excld_flag,10);
    hr_utility.set_location ('  age chek in dep elig  ' , 610);
    --Bug 2101937 we need to test the max limit differently for
    --whole numbers and decimal numbers.
    --if the age_max_num is a whole number we need to take age_max_num + 1
    --else we need to take the age_max_num + 0.00000001
    --
    if age.mx_age_num is not null then
      --
      l_max_age_number := null ;
      --
      if ( l_max_age_number <> trunc(l_max_age_number)
         OR ( age.mn_age_num is not null and age.mn_age_num <> trunc(age.mn_age_num) )) then
        --
        l_max_age_number := age.mx_age_num + 0.000000001 ;
        --
      else
        --
        l_max_age_number := age.mx_age_num + 1 ;
        --
      end if;
    --
    end if;
    --
/**
    if ((l_age >= age.mn_age_num and l_age < ceil(age.mx_age_num+0.001) )
       --or (age.no_mn_age_flag = 'Y' and l_age <  age.mx_age_num)
       --or (age.no_mx_age_flag = 'Y' and l_age > age.mn_age_num)) then
       --bug 1977901 fixes
       or (age.no_mn_age_flag = 'Y' and l_age <  ceil(age.mx_age_num+0.001) )
       or (age.no_mx_age_flag = 'Y' and l_age >= age.mn_age_num)) then
*/
    --
    -- Bug 6615978 : Check the profile value and accordingly calculate the ineligibility date
    --
    l_defct_brch_dtctd := nvl(fnd_profile.VALUE ('BEN_DEFCT_BRCH_DTCTD'),'USE_ACTUAL_INELIG_DT');

    if ((l_age >= age.mn_age_num and l_age <  l_max_age_number)
       or (age.no_mn_age_flag = 'Y' and l_age <  l_max_age_number)
       or (age.no_mx_age_flag = 'Y' and l_age >= age.mn_age_num) ) then

       hr_utility.set_location (' passed age chekc in dep elig ' , 610);
      --
      if age.excld_flag = 'Y' then
        --
        -- exclude means if the criteria matches, the person is not eligible
        --
        l_elig := 'N';
        --
        -- Failed, set the change date
        -- Used 'GT_MIN' as the age can only increase and not decrease.
        -- g_elig_change_dt is used in bendsgel where the dpnt. was found
        -- previously eligible. So the only case for exclude can be when
        -- a dpnt crosses the minimum value.
        --
	if l_defct_brch_dtctd = 'USE_LE_OCRD_BRCH_DT' then
           l_elig_change_dt :=  l_effective_date - 1;
        else
          l_elig_change_dt:= benutils.derive_date(
                             p_date    => l_dob,
                             p_uom     => age.age_uom,
                             p_min     => age.mn_age_num,
                             p_max     => age.mx_age_num,
                             p_value   => 'GT_MIN') - 1;
        end if;
        --
	hr_utility.set_location('l_elig_change_dt :'||l_elig_change_dt, 5);
	--
        set_elig_change_dt(p_elig_change_dt => l_elig_change_dt,p_effective_date => l_effective_date); -- bug 4546890
        exit;
        --
      else   -- age.excld_flag = 'N'
        --
        l_elig := 'Y';
        exit;
        --
      end if;
      --
    else
      --
      if age.excld_flag = 'Y' then
        --
        l_elig := 'Y';
        exit;
        --
      else
        --
        -- Used 'GT_MAX' as the age can only increase and not decrease.
        -- g_elig_change_dt is used in bendsgel where the dpnt. was found
        -- previously eligible. So the only case where the profile fails is
        -- when a dpnt crosses the maximum value.
        --
        l_elig := 'N';
	if l_defct_brch_dtctd = 'USE_LE_OCRD_BRCH_DT' then
           l_elig_change_dt :=  l_effective_date - 1;
        else
        l_elig_change_dt := benutils.derive_date(
                               p_date    => l_dob,
                               p_uom     => age.age_uom,
                               p_min     => age.mn_age_num,
                               p_max     => age.mx_age_num,
                               p_value   => 'GT_MAX') - 1;
         end if;

         hr_utility.set_location('l_elig_change_dt :'||l_elig_change_dt, 10);

        set_elig_change_dt(p_elig_change_dt => l_elig_change_dt,p_effective_date => l_effective_date); -- bug 4546890
        --
      end if;
      --
    end if;
    --
    -- End Bug 6615978
    --
  end loop;
  --
  if l_found_one = 'N' then
    --
    l_elig := 'Y';
    --
  end if;
  --
  hr_utility.set_location('l_elig :'||l_elig, 10);
  p_eligible_flag := l_elig;
  --
  if l_elig = 'Y' then
     p_inelig_rsn_cd := null;
  else
     p_inelig_rsn_cd := 'AGE';
  end if;
  --
  hr_utility.set_location('Leaving :'||l_proc, 20);
  --
end check_age_elig;
--
procedure check_marital_elig
         (p_eligy_prfl_id     in number,
          p_person_id         in number,
          p_business_group_id in number,
          p_effective_date    in date,
          p_lf_evt_ocrd_dt    in date,
          p_marital_cd        in varchar2,
          p_eligible_flag     out nocopy varchar2,
          p_inelig_rsn_cd     out nocopy varchar2) is

  --
  l_proc              varchar2(100):= g_package||'check_marital_elig';
  l_elig              varchar2(10) := 'Y';
  l_eligy_prfl_id     number(15)   := p_eligy_prfl_id;
  l_bg_id             number(15)   := p_business_group_id;
  l_effective_date    date         := p_effective_date;
  --
  --fonm
  l_fonm_cvg_strt_dt  date ;

  -- Cursor to get marital status criteria
  --
  cursor   c_ems is
    select mrtl_stat_cd
    from   ben_elig_mrtl_stat_cvg_f ems
    where  ems.dpnt_cvg_eligy_prfl_id = l_eligy_prfl_id
    and    ems.business_group_id = l_bg_id
    and    l_effective_date
           between ems.effective_start_date
           and     ems.effective_end_date;
  --
  l_ems c_ems%rowtype;
  --
begin
  --
  hr_utility.set_location('Entering: '||l_proc,10);
  --

  -- fonm
  l_effective_date  :=  nvl(p_lf_evt_ocrd_dt,p_effective_date ) ;
  if ben_manage_life_events.fonm = 'Y'
      and ben_manage_life_events.g_fonm_cvg_strt_dt is not null then
     --
     l_fonm_cvg_strt_dt := ben_manage_life_events.g_fonm_cvg_strt_dt ;
     l_effective_date   := nvl(l_fonm_cvg_strt_dt,l_effective_date ) ;

     --
     hr_utility.set_location ('Fonm Date  '||l_effective_date ,10);
  end if;


  open c_ems;
    --
    loop
      --
      fetch c_ems into l_ems;
      exit when c_ems%notfound;
      --
      if l_ems.mrtl_stat_cd = p_marital_cd then
        --
        l_elig := 'Y';
        exit;
        --
      else
        --
        l_elig := 'N';
        --
      end if;
      --
    end loop;
    --
  close c_ems;
  --
  p_eligible_flag := l_elig;
  --
  if l_elig = 'Y' then
     p_inelig_rsn_cd := null;
  else
     p_inelig_rsn_cd := 'MRT';
  end if;
  --
  hr_utility.set_location('Leaving: '||l_proc,20);
  --
end check_marital_elig;
--
procedure check_military_elig
         (p_eligy_prfl_id     in number,
          p_person_id         in number,
          p_business_group_id in number,
          p_effective_date    in date,
          p_lf_evt_ocrd_dt    in date,
          p_military_service  in varchar2,
          p_eligible_flag     out nocopy varchar2,
          p_inelig_rsn_cd     out nocopy varchar2) is

  --
  l_proc              varchar2(100):= g_package || '.check_military_elig';
  l_elig              varchar2(10) := 'Y';
  l_eligy_prfl_id     number(15)   := p_eligy_prfl_id;
  l_bg_id             number(15)   := p_business_group_id;
  l_effective_date    date         := p_effective_date;
  --
  --fonm
  l_fonm_cvg_strt_dt  date ;

  -- Cursor to get military status criteria
  --
  cursor c_emc is
    select mltry_stat_cd
    from   ben_elig_mltry_stat_cvg_f emc
    where  emc.dpnt_cvg_eligy_prfl_id = l_eligy_prfl_id
    and    emc.business_group_id = l_bg_id
    and    l_effective_date
           between emc.effective_start_date
           and     emc.effective_end_date;
  --
  l_emc c_emc%rowtype;
  --
begin
  --
  hr_utility.set_location('Entering: '||l_proc,10);
  --
  -- fonm
  l_effective_date  :=  nvl(p_lf_evt_ocrd_dt,p_effective_date ) ;
  if ben_manage_life_events.fonm = 'Y'
      and ben_manage_life_events.g_fonm_cvg_strt_dt is not null then
     --
     l_fonm_cvg_strt_dt := ben_manage_life_events.g_fonm_cvg_strt_dt ;
     l_effective_date   := nvl(l_fonm_cvg_strt_dt,l_effective_date ) ;

     --
     hr_utility.set_location ('Fonm Date  '||l_effective_date ,10);
  end if;


  open c_emc;
    --
    loop
      --
      fetch c_emc into l_emc;
      exit when c_emc%notfound;
      --
      if l_emc.mltry_stat_cd = nvl(p_military_service,'N') then
        --
        l_elig := 'Y';
        exit;
        --
      else
        --
        l_elig := 'N';
        --
      end if;
      --
    end loop;
    --
  close c_emc;
  --
  p_eligible_flag := l_elig;
  --
  if l_elig = 'Y' then
     p_inelig_rsn_cd := null;
  else
     p_inelig_rsn_cd := 'MLT';
  end if;
  --
  hr_utility.set_location('Leaving: '||l_proc,20);
  --
end check_military_elig;
--
procedure check_student_elig
         (p_eligy_prfl_id     in number,
          p_person_id         in number,
          p_business_group_id in number,
          p_effective_date    in date,
          p_lf_evt_ocrd_dt    in date,
          p_student_status    in varchar2,
          p_eligible_flag     out nocopy varchar2,
          p_inelig_rsn_cd     out nocopy varchar2) is

  --
  l_proc              varchar2(100):= g_package || '.check_student_elig';
  l_elig              varchar2(10) := 'Y';
  l_eligy_prfl_id     number(15)   := p_eligy_prfl_id;
  l_bg_id             number(15)   := p_business_group_id;
  l_effective_date    date         := p_effective_date;
  --
  --fonm
  l_fonm_cvg_strt_dt  date ;

  -- Cursor to get student status criteria
  --
  cursor   c_esc is
    select stdnt_stat_cd
    from   ben_elig_stdnt_stat_cvg_f esc
    where  esc.dpnt_cvg_eligy_prfl_id = l_eligy_prfl_id
    and    esc.business_group_id = l_bg_id
    and    l_effective_date
           between esc.effective_start_date
           and     esc.effective_end_date;
  --
  l_esc c_esc%rowtype;
  --
begin
  --
  hr_utility.set_location('Entering: '||l_proc,10);
  --
  -- fonm
  l_effective_date  :=  nvl(p_lf_evt_ocrd_dt,p_effective_date ) ;
  if ben_manage_life_events.fonm = 'Y'
      and ben_manage_life_events.g_fonm_cvg_strt_dt is not null then
     --
     l_fonm_cvg_strt_dt := ben_manage_life_events.g_fonm_cvg_strt_dt ;
     l_effective_date   := nvl(l_fonm_cvg_strt_dt,l_effective_date ) ;

     --
     hr_utility.set_location ('Fonm Date  '||l_effective_date ,10);
  end if;


  open c_esc;
    --
    loop
      --
      fetch c_esc into l_esc;
      exit when c_esc%notfound;
      --
      if l_esc.stdnt_stat_cd = p_student_status then
        --
        l_elig := 'Y';
        exit;
        --
      else
        --
        l_elig := 'N';
        --
      end if;
      --
    end loop;
    --
  close c_esc;
  --
  p_eligible_flag := l_elig;
  --
  if l_elig = 'Y' then
     p_inelig_rsn_cd := null;
  else
     p_inelig_rsn_cd := 'STU';
  end if;
  --
  hr_utility.set_location('Leaving: '||l_proc,20);
  --
end check_student_elig;
--
procedure check_contact_elig
         (p_eligy_prfl_id     in number,
          p_person_id         in number,
          p_contact_person_id in number, -- Bug 6956648
          p_business_group_id in number,
          p_effective_date    in date,
          p_lf_evt_ocrd_dt    in date,
          p_contact_type      in varchar2,
          p_eligible_flag     out nocopy varchar2,
          p_inelig_rsn_cd     out nocopy varchar2) is
  --
  l_proc              varchar2(100):= g_package || '.check_contact_elig';
  l_elig              varchar2(10) := 'Y';
  l_eligy_prfl_id     number(15)   := p_eligy_prfl_id;
  l_bg_id             number(15)   := p_business_group_id;
  l_effective_date    date         := p_effective_date;
  --
  --fonm
  l_fonm_cvg_strt_dt  date ;

  -- Cursor to get student status criteria
  --
  cursor   c_dcr is
    select per_relshp_typ_cd
    from   ben_dpnt_cvg_rqd_rlshp_f dcr
    where  dcr.dpnt_cvg_eligy_prfl_id = l_eligy_prfl_id
    and    dcr.business_group_id = l_bg_id
    and    l_effective_date
           between dcr.effective_start_date
           and     dcr.effective_end_date;
  --
  --
  cursor c_contact (p_contact_type  in varchar2,
                    p_effective_date in date) is
    select null
    from per_contact_relationships ctr
    where ctr.contact_type = p_contact_type
     and    ctr.contact_person_id = p_person_id
     and    ctr.person_id = p_contact_person_id -- Bug 6956648
     and    ctr.personal_flag = 'Y'
     and    p_effective_date between nvl(ctr.date_start,p_effective_date)
           and     nvl(ctr.date_end,p_effective_date);
  --
  l_dummy   varchar2(30);
  l_dcr c_dcr%rowtype;
  --
begin
  --
  hr_utility.set_location('Entering: '||l_proc,10);
  --
    -- fonm
  l_effective_date  :=  nvl(p_lf_evt_ocrd_dt,p_effective_date ) ;
  if ben_manage_life_events.fonm = 'Y'
      and ben_manage_life_events.g_fonm_cvg_strt_dt is not null then
     --
     l_fonm_cvg_strt_dt := ben_manage_life_events.g_fonm_cvg_strt_dt ;
     l_effective_date   := nvl(l_fonm_cvg_strt_dt,l_effective_date ) ;

     --
     hr_utility.set_location ('Fonm Date  '||l_effective_date ,10);
  end if;


  open c_dcr;
    --
    loop
      --
      fetch c_dcr into l_dcr;
      exit when c_dcr%notfound;
      --
      if l_dcr.per_relshp_typ_cd = p_contact_type then
        --
        l_elig := 'Y';
        exit;
        --
      else
        --
        l_elig := 'N';
        -- bug#4318031 - check other relationships of contact person with personal flag
        open c_contact (l_dcr.per_relshp_typ_cd, l_effective_date);
        fetch c_contact into l_dummy;
        if c_contact%found then
           l_elig := 'Y';
           exit;
        end if;
        close c_contact;
        --
      end if;
      --
    end loop;
    --
  close c_dcr;
  --
  p_eligible_flag := l_elig;
  --
  if l_elig = 'Y' then
     p_inelig_rsn_cd := null;
  else
     p_inelig_rsn_cd := 'REL';
  end if;
  --
  hr_utility.set_location('Leaving: '||l_proc,20);
  --
end check_contact_elig;
--
procedure check_disabled_elig
         (p_eligy_prfl_id     in number,
          p_person_id         in number,
          p_business_group_id in number,
          p_effective_date    in date,
          p_lf_evt_ocrd_dt    in date,
          p_per_dsbld_type    in varchar2,
          p_eligible_flag     out nocopy varchar2,
          p_inelig_rsn_cd     out nocopy varchar2) is
  --
  l_proc              varchar2(100):= g_package || '.check_disabled_elig';
  l_elig              varchar2(10) := 'Y';
  l_eligy_prfl_id     number(15)   := p_eligy_prfl_id;
  l_bg_id             number(15)   := p_business_group_id;
  l_effective_date    date         := p_effective_date;
  --
  --fonm
  l_fonm_cvg_strt_dt  date ;

  -- Cursor to get disabled status criteria
  --
  cursor   c_edc is
    select dsbld_cd
    from   ben_elig_dsbld_stat_cvg_f edc
    where  edc.dpnt_cvg_eligy_prfl_id = l_eligy_prfl_id
    and    edc.business_group_id = l_bg_id
    and    l_effective_date
           between edc.effective_start_date
           and     edc.effective_end_date;
  --
  l_edc c_edc%rowtype;
  --
begin
  --
  hr_utility.set_location('Entering: '||l_proc,10);
  hr_utility.set_location('*** SUP  in Check disability  p_effective_date '|| p_effective_date,10);

  --
  -- fonm
  l_effective_date  :=  nvl(p_lf_evt_ocrd_dt,p_effective_date ) ;
  if ben_manage_life_events.fonm = 'Y'
      and ben_manage_life_events.g_fonm_cvg_strt_dt is not null then
     --
     l_fonm_cvg_strt_dt := ben_manage_life_events.g_fonm_cvg_strt_dt ;
     l_effective_date   := nvl(l_fonm_cvg_strt_dt,l_effective_date ) ;

     --
     hr_utility.set_location ('Fonm Date  '||l_effective_date ,10);
  end if;


  open c_edc;
    --
    loop
      --
      fetch c_edc into l_edc;
      exit when c_edc%notfound;
      --
      if l_edc.dsbld_cd = p_per_dsbld_type then
        --
        l_elig := 'Y';
        exit;
        --
      else
        --
        l_elig := 'N';
        --
      end if;
      --
    end loop;
    --
  close c_edc;
  --
  p_eligible_flag := l_elig;
  --
  if l_elig = 'Y' then
     p_inelig_rsn_cd := null;
  else
     p_inelig_rsn_cd := 'DSB';
  end if;
  --
   hr_utility.set_location('** sup in disability check p_eligible_flag '||p_eligible_flag,200);
  hr_utility.set_location('Leaving: '||l_proc,20);
  --
end check_disabled_elig;
--
procedure check_postal_elig
         (p_eligy_prfl_id     in number,
          p_person_id         in number,
          p_business_group_id in number,
          p_effective_date    in date,
          p_lf_evt_ocrd_dt    in date,
          p_postal_code       in varchar2,
          p_eligible_flag     out nocopy varchar2,
          p_inelig_rsn_cd     out nocopy varchar2) is
  --
  l_proc              varchar2(100):= g_package || '.check_postal_elig';
  l_elig              varchar2(10) := 'N';
  l_eligy_prfl_id     number(15)   := p_eligy_prfl_id;
  l_bg_id             number(15)   := p_business_group_id;
  l_effective_date    date         := p_effective_date;
  l_found_one         varchar2(30) := 'N';
  --
  --fonm
  l_fonm_cvg_strt_dt  date ;

  --  Cursor to grab zip code range requirement.
  --
  cursor c_zip_code_rng is
    select rzr.from_value,
           rzr.to_value,
           epl.excld_flag
    from   ben_pstl_zip_rng_f rzr,
           ben_elig_pstl_cd_r_rng_cvg_f epl
    where  rzr.pstl_zip_rng_id = epl.pstl_zip_rng_id
    and    epl.dpnt_cvg_eligy_prfl_id = l_eligy_prfl_id
    and    epl.business_group_id  = l_bg_id
    and    rzr.business_group_id  = l_bg_id
    and    l_effective_date
           between epl.effective_start_date
           and epl.effective_end_date
    and    l_effective_date
           between rzr.effective_start_date
           and rzr.effective_end_date
    order  by epl.ordr_num;
  --
  l_zip c_zip_code_rng%rowtype;
  l_len number ;
  --
begin
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  -- fonm
  l_effective_date  :=  nvl(p_lf_evt_ocrd_dt,p_effective_date ) ;
  if ben_manage_life_events.fonm = 'Y'
      and ben_manage_life_events.g_fonm_cvg_strt_dt is not null then
     --
     l_fonm_cvg_strt_dt := ben_manage_life_events.g_fonm_cvg_strt_dt ;
     l_effective_date   := nvl(l_fonm_cvg_strt_dt,l_effective_date ) ;

     --
     hr_utility.set_location ('Fonm Date  '||l_effective_date ,10);
  end if;


  open c_zip_code_rng;
    --
    loop
      --
      fetch c_zip_code_rng into l_zip;
      exit when c_zip_code_rng%notfound;
      --
      l_found_one := 'Y';
      hr_utility.set_location('Found zip criteria. from:'||
                              l_zip.from_value||' to:'||
                              l_zip.to_value||' '||p_postal_code,2219.2);

      l_len :=  length(nvl(l_zip.from_value,'00000')) ;
      --
      hr_utility.set_location(' len ' || l_len , 2219.2);
      ---
      if nvl( length(p_postal_code) >= length(l_zip.from_value) and
         (substr(nvl(p_postal_code,'-1'),1,l_len )
          between nvl(l_zip.from_value,'00000') and
                                nvl(l_zip.to_value,nvl(p_postal_code,'-1'))),false)  then
          hr_utility.set_location('result true  ' ,2219.2);
        --
        if l_zip.excld_flag = 'Y' then
          -- exclude means if the criteria matches, the person is not eligible
          l_elig := 'N';
          hr_utility.set_location(' l_elig := No ',99);
          exit;
          --
        else   -- l_zip.excld_flag = 'N'
          -- one criteria instance passed, leave.
          l_elig := 'Y';
          hr_utility.set_location(' l_elig := yes ',99);
          exit;
        --
        end if;
        --
      elsif l_zip.excld_flag = 'Y' then   -- No Match and exclude is 'Y' case
        --
        hr_utility.set_location('No Match and exclude is yes ' ,99);
        l_elig := 'Y';
        -- exit;
        --
      end if;
      -- one criteria instance failed.  keep going to check others.
    end loop;
    --
    hr_utility.set_location(' l_elig '||l_elig ,99);
    if l_found_one = 'N' then
      --
      -- No criteria passes
      --
      l_elig := 'Y';
      --
    end if;
    --
  close c_zip_code_rng;
  --
  p_eligible_flag := l_elig;
  --
  if l_elig = 'Y' then
     p_inelig_rsn_cd := null;
  else
     p_inelig_rsn_cd := 'ZIP';
  end if;
  --
  hr_utility.set_location(' l_elig '||l_elig ,100);
  hr_utility.set_location('Leaving: '||l_proc,20);
  --
end check_postal_elig;
--
procedure check_cvrd_anthr_pl_elig
         (p_eligy_prfl_id     in number,
          p_person_id         in number,
          p_business_group_id in number,
          p_effective_date    in date,
          p_lf_evt_ocrd_dt    in date,
          p_pl_id             in number,
          p_eligible_flag     out nocopy varchar2,
          p_inelig_rsn_cd     out nocopy varchar2) is
  --
  l_proc              varchar2(100):= g_package || '.check_cvrd_anthr_pl_elig';
  l_elig              varchar2(10) := 'Y';
  l_cvg_det_dt        date;
  l_exists            varchar(1);
  --
   --fonm
  l_effective_date    date ;
  l_fonm_cvg_strt_dt  date ;

  -- Cursor to get pl_id criteria
  --
  cursor   c_get_cvrd_anthr_pl is
    select dpc.pl_id,dpc.cvg_det_dt_cd, dpc.excld_flag
    from   ben_dpnt_cvrd_anthr_pl_cvg_f dpc
    where  dpc.dpnt_cvg_eligy_prfl_id = p_eligy_prfl_id
    and    dpc.business_group_id = p_business_group_id
    and    l_effective_date
           between dpc.effective_start_date
           and     dpc.effective_end_date;
  --
  cursor  c_get_elig_cvrd_dpnt(p_pl_id in number) is
    select null
    from ben_elig_cvrd_dpnt_f pdp
        ,ben_prtt_enrt_rslt_f pen
    where pdp.dpnt_person_id = p_person_id
    and   pdp.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
    --and   pen.prtt_enrt_rslt_stat_cd not in ('VOIDD','BCKDT')
    and pen.prtt_enrt_rslt_stat_cd is null
    and   pen.pl_id = p_pl_id
    and l_cvg_det_dt
        between pdp.cvg_strt_dt
        and    nvl(pdp.cvg_thru_dt,hr_api.g_eot)
    and pdp.cvg_strt_dt is not null
    and nvl(p_lf_evt_ocrd_dt,p_effective_date)
        between pdp.effective_start_date
        and     pdp.effective_end_date
    and nvl(p_lf_evt_ocrd_dt,p_effective_date)
        between pen.effective_start_date
        and     pen.effective_end_date
    ;

  --
  l_dpc c_get_cvrd_anthr_pl%rowtype;
  --
begin
  --
  hr_utility.set_location('Entering: '||l_proc,10);
  --
  -- fonm
  l_effective_date  :=  nvl(p_lf_evt_ocrd_dt,p_effective_date ) ;
  if ben_manage_life_events.fonm = 'Y'
      and ben_manage_life_events.g_fonm_cvg_strt_dt is not null then
     --
     l_fonm_cvg_strt_dt := ben_manage_life_events.g_fonm_cvg_strt_dt ;
     l_effective_date   := nvl(l_fonm_cvg_strt_dt,l_effective_date ) ;

     --
     hr_utility.set_location ('Fonm Date  '||l_effective_date ,10);
  end if;


  open c_get_cvrd_anthr_pl;
    --
    loop
      --
      fetch c_get_cvrd_anthr_pl into l_dpc;
      exit when c_get_cvrd_anthr_pl%notfound;
      --
      --  Check if contact person is currently covered in
      --  under the plan.
      --
      ben_determine_date.main
        (p_date_cd        => l_dpc.cvg_det_dt_cd,
         p_effective_date => p_effective_date,
         p_lf_evt_ocrd_dt => p_lf_evt_ocrd_dt,
         p_returned_date  => l_cvg_det_dt,
         p_fonm_cvg_strt_dt=> l_fonm_cvg_strt_dt);
      --
      open c_get_elig_cvrd_dpnt(l_dpc.pl_id);
      fetch c_get_elig_cvrd_dpnt into l_exists;
      if c_get_elig_cvrd_dpnt%found then
        close c_get_elig_cvrd_dpnt;
      --
      --  If the dependent is covered under the plan
      --  and the exclude flag is set to 'Y' then he/she
      --  is not eligible.
      --
	hr_utility.set_location ('Found c_get_elig_cvrd_dpnt '||l_dpc.excld_flag,34634611);
        if l_dpc.excld_flag = 'Y' then
          l_elig := 'N';
          exit ;
        else
          exit;
        end if;
          --
      else
        --
        close c_get_elig_cvrd_dpnt;
        --
        -- If the dependent is not covered under plan and the
        -- exclude flag is set to 'Y', then the he/she is eligible.
        --
	hr_utility.set_location ('Not Found c_get_elig_cvrd_dpnt '||l_dpc.excld_flag,34634611);
        if l_dpc.excld_flag = 'N' then
          l_elig := 'N';
        else
          l_elig := 'Y' ;
          -- exit;
        end if;
        --
      end if;
    end loop;
    --
  close c_get_cvrd_anthr_pl;
  --
  p_eligible_flag := l_elig;
  --
  if l_elig = 'Y' then
     p_inelig_rsn_cd := null;
  else
     p_inelig_rsn_cd := 'CVP';
  end if;
  --
  hr_utility.set_location('Leaving: '||l_proc,20);

  --
end check_cvrd_anthr_pl_elig;
--
procedure check_dsgntr_enrld_cvg_elig
         (p_eligy_prfl_id     in number,
          p_person_id         in number,
          p_dsgntr_id         in number,
          p_business_group_id in number,
          p_effective_date    in date,
          p_lf_evt_ocrd_dt    in date,
          p_pgm_id            in number,
          p_eligible_flag     out nocopy varchar2,
          p_inelig_rsn_cd     out nocopy varchar2) is
  --
  l_proc                     varchar2(100):= g_package || '.check_dsgntr_enrld_cvg_elig';
  l_elig                     varchar2(10) := 'Y';
  l_exists                   varchar(1);
  l_dsgntr_crntly_enrld_flag varchar(1);
  --
  --fonm
  l_effective_date    date ;
  l_fonm_cvg_strt_dt  date ;

  -- Cursor to get criteria
  --
  cursor   c_get_dsgntr_enrld_cvg is
    select dec.dsgntr_crntly_enrld_flag
    from   ben_dsgntr_enrld_cvg_f dec
    where  dec.dpnt_cvg_eligy_prfl_id = p_eligy_prfl_id
    and    dec.business_group_id = p_business_group_id
    and    l_effective_date
           between dec.effective_start_date
           and     dec.effective_end_date;
  --
  cursor  c_get_prtt_enrt_rslt is
    select null
    from ben_prtt_enrt_rslt_f pen
    where pen.person_id = p_dsgntr_id
    and   pen.pgm_id = p_pgm_id
    --and   pen.prtt_enrt_rslt_stat_cd not in ('VOIDD','BCKDT')
    and   pen.prtt_enrt_rslt_stat_cd is null
    and nvl(p_lf_evt_ocrd_dt,p_effective_date)
        between pen.enrt_cvg_strt_dt and pen.enrt_cvg_thru_dt
        and pen.enrt_cvg_thru_dt <= pen.effective_end_date;

  --
begin
  --
  hr_utility.set_location('Entering: '||l_proc,10);
  hr_utility.set_location('eligy_prfl: '||p_eligy_prfl_id,10);
  hr_utility.set_location('dsgntr_id: '||p_dsgntr_id,10);
  --
  -- fonm
  l_effective_date  :=  nvl(p_lf_evt_ocrd_dt,p_effective_date ) ;
  if ben_manage_life_events.fonm = 'Y'
      and ben_manage_life_events.g_fonm_cvg_strt_dt is not null then
     --
     l_fonm_cvg_strt_dt := ben_manage_life_events.g_fonm_cvg_strt_dt ;
     l_effective_date   := nvl(l_fonm_cvg_strt_dt,l_effective_date ) ;

     --
     hr_utility.set_location ('Fonm Date  '||l_effective_date ,10);
  end if;


  open c_get_dsgntr_enrld_cvg;
    --
  fetch c_get_dsgntr_enrld_cvg into l_dsgntr_crntly_enrld_flag;
  if c_get_dsgntr_enrld_cvg%found then
      --
    open c_get_prtt_enrt_rslt;
    fetch c_get_prtt_enrt_rslt into l_exists;
    if c_get_prtt_enrt_rslt%found then
      close c_get_prtt_enrt_rslt;
      --
      --  If designator is currently enrolled in the program and flag = N,
      --  then contact person is not eligible.
      --
      if l_dsgntr_crntly_enrld_flag = 'N' then
        l_elig := 'N';
      end if;
    else
      close c_get_prtt_enrt_rslt;
      --
      --  If designator is not enrolled in the program and flag = Y,
      --  then contact person is not eligible.
      --
      if l_dsgntr_crntly_enrld_flag = 'Y' then
        l_elig := 'N';
      end if;
    end if;
    --
  end if;
  close c_get_dsgntr_enrld_cvg;
  --
  p_eligible_flag := l_elig;
  --
  if l_elig = 'Y' then
     p_inelig_rsn_cd := null;
  else
     p_inelig_rsn_cd := 'DEG';
  end if;
  --
  hr_utility.set_location('Leaving: '||l_proc,20);
  --
end check_dsgntr_enrld_cvg_elig;
--
function get_elig_change_dt return date is
  --
begin
  --
  return nvl(g_elig_change_dt,g_effective_date);
  --
end get_elig_change_dt;
--
END;

/
