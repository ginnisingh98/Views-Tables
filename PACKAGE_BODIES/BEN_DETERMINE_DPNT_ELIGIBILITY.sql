--------------------------------------------------------
--  DDL for Package Body BEN_DETERMINE_DPNT_ELIGIBILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_DETERMINE_DPNT_ELIGIBILITY" as
/* $Header: bendepen.pkb 120.13.12010000.3 2010/03/08 07:07:02 sagnanas ship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|                       Copyright (c) 1998 Oracle Corporation                   |
|                          Redwood Shores, California, USA                      |
|                               All rights reserved.                            |
+==============================================================================+
--
Name
	Dependent Eligibility
Purpose
	This package is used to determine the dependents who may be eligible for
      an electable choice for a specific participant.  It also determines
      if the electable choice may or may not actually be electable.
History
	Date       Who           Version    What?
	----       ---           -------    -----
      09 Apr 98    M Rosen/JM    110.0      Created.
      03 Jun 98    J Mohapatra              Replaced the date calculation
                                            with a new procedure call.
      13 Jun 98    Ty Hayden                Added batch Who columns.
      17 Jun 98    J Mohapatra              Added parameters(dpnt_cvg_strt
                                            dt_cd/rl) in the call to update
                                            api on elec_chc table. Make
                                            changes in the hirerchy of
                                            picking of cvg strt date/rl.
      11 Sep 98      maagrawa   115.4       Eligibility to be checked for
                                            non-electable choices also.
      30-OCT-98    G PERRY       115.5      Removed Control m
      10-DEC-98      lmcdonal   115.6       Do not load dpnt cvg_strt_dt
                                            when creating dpnt records that are
                                            tied only to a choice and not to a
                                            result.  Bug 1536.
      15-DEC-98      stee       115.7       Remove dsgn rqmt check as it
                                            is checked in ben_evaluate_dpnt
                                            -elg_profiles.
      20-DEC-98     G PERRY      115.8      Added in info to cache about the
                                            covered dependent.
      22-DEC-98     stee         115.9      If participant has a qmcso, set
                                            electable_flag to 'N' for choices
                                            that do not allow dependents.
      28-DEC-98     stee         115.10     Fix c_contact cursor to select
                                            the contacts within a date range.
      02-JAN-99     stee         115.11     Added p_multi_row_actn of false
                                            to update_elig_cvrd_dpnt api.
      18 Jan 99     G Perry      115.12     LED V ED
      05 Apr 99     mhoyes       115.13   - Un-datetrack of per_in_ler_f changes.
                                            - Removed DT restriction from
                                              - main/c_per_in_ler
      30 Apr 99     shdas	 115.15	    Added contexts to rule calls(genutils.formula)
					    Added a rule call for enrt_cvg_strt_dt_rl.
      08 May 99     jcarpent     115.16     Check ('VOIDD', 'BCKDT') for pil stat cd
      06 Jun 99     stee         115.17     Check for datetrack mode before
                                            updating dependent.
      28 Jul 99     tmathers     115.18     genutils to benutils.
      06 Aug 99     mhoyes       115.19   - Added new trace messages.
      10 Aug 99     gperry       115.20     Removed global references to
                                            g_cache_person.
      24 Aug 99     maagrawa     115.21     Changes related to breaking of
                                            dependents table.
      26 Aug 99     gperry       115.22     Added benefits assignment call for
                                            when employee assignment is null.
      30 Aug 99     maagrawa     115.23     Added p_dpnt_inelig_rsn_cd to
                                            Dependent eligibility process to
                                            return ineligible reason.
      02 Sep 99     maagrawa     115.24     Added HIPAA communication.
      07 Sep 99     jcarpent     115.25     Removed qmcso check.
      11 Oct 99     jcarpent     115.26     Added bg_id to update_elig_cvrd_dpn
      19 Nov 99     pbodla       115.27     Passed p_elig_per_elctbl_chc_id
                                            to formula
      30 Nov 99     lmcdonal     115.28     add per_all_people_f to c_contact
                                            cursor to avoid error in bendpelg.
      03 Jan 00     maagrawa     115.29     Added pl_typ_id to comm. process.
      07 Jan 00     pbodla       115.30     oabrules.xls says the ler_chg_dpnt_cvg_rl
                                            should return Y/N.
      18 Jan 00     maagrawa     115.31     Removed HIPAA comm. Now called
                                            from benmngle.
      12 Feb 00     maagrawa     115.32     Use the elig_change_dt to
                                            calculate cvg_end_dt (1193065).
      17 Feb 00     jcarpent     115.33     change c_contact cursor to also
                                            include covered even if ended.
      22 Feb 00     jcarpent     115.34     Added hierarchy for ben_dsgn_rqmt
      10 Mar 00     jcarpent     115.35     Pass cvg_end_dt to update_elig_dpnt
      31 mar 00     maagrawa     115.36     Pass the cvg_strt_dt to dpnt.
                                            eligibilty process (4929).
      01 Apr 00     stee         115.36     Set a global variable when
                                            dependent is found ineligible
                                            so a benefit assignment can
                                            be written.
      05 Apr 00     mmogel       115.38     Added tokens to message calls to
                                            make the messages more meaningful
      11 Apr 00     jcarpent     115.39     Handle the case when bendsgel has
                                            already end dated the elig covered
                                            dependent in the future (5076)
      25 Apr 00     mhoyes       115.40   - Added trace messages for profiling.
      01 May 00     pbodla       115.41   - Task 131 : Elig dependent rows are
                                            created before creating the electable
                                            choice rows. Added procedures main() -
                                            created the elig dependent rows,
                                            p_upd_egd_with_epe_id()- updates elig
                                            dependent rows with electable choice
                                            rows.
      13 May 00     mhoyes       115.42   - Added trace messages for profiling.
      14 May 00     lmcdonal     115.43     Bug 1193065.  Use life event occurred
                                            date for elig_strt_dt.
      15 May 00     mhoyes       115.44   - Called performance API.
      22 May 00     jcarpent     115.45   - Create elig_dpnts when mnanrd so
                                            that they can be carried over by
                                            the system. (4981).
      23 May 00     stee         115.46   - Do not update coverage end date
                                            if the dependent was previously
                                            ineligible.
      24 May 00     jcarpent     115.47   - Fix for bug introduced in 115.45
      29 May 00     mhoyes       115.48   - Called update performance covers
                                            for EPEs and EGDs.
      15 Jun 00     pbodla       115.49   - Removed old main(). as Martin looked
                                            at it for performance reasons.
                                          - Task 133 : Interim coverage cannot
                                            be assigned when in insufficient number
                                            of dependents have been designated
                                            to a participant enrollment. In this case,
                                            the current product will end the
                                            participant's current coverage.
                                            To have above functionality, if no
                                            dependent designation is required if
                                            l_mn_dpnts_rqd_num is 0 or
                                            l_no_mn_num_dfnd_flag is Y.
      28 Jun 00     mhoyes       115.50   - Called update performance covers
                                            for EPE.
                                          - Stored sysdate to local to reduce
                                            sysdate references.
      09 Aug 00     maagrawa     115.51   - If plan/option has decline flag ON,
                                            do not create elig_dpnt records.
      14 Aug 00     gperry       115.52     Fixed WWBUG 1375474.
                                            Passed in more contexts to
                                            ben_determine_date call.
      30 Aug 00     tilak        115.53     bug:1390107 region_2 is validate before calling pay_mag_util.
                                             lokup_jurisdiction_code
      07 Nov 00     mhoyes       115.54   - Phased out c_elctbl_chc. Referenced
                                            comp object loop electable choice context
                                            global.
      21 NOV 00     rchase       115.55   - Bug 1500945.  Update elig_dpnt row
                                            when coverage is lost
                                            due to ineligibility.  Leapfrog
                                            based on ver 115.53.
      21 NOV 00     jcarpent     115.56   - Merged version of 115.54 and 115.55.
      12 DEC 00     jcarpent     115.57   - Bug 1524099, When elig_dpnt row was
                                            not found was assuming eligible.
                                            Added nvl(..dpnt_inelig_flag,'N').
      26 DEC 00     Ikasire	 115.58     Bug 1531647 added input values for contact_person_id
                                            in the call to ben_determine_date.main procedure
      05 Jan 01     kmahendr     115.59     Added per_in_ler_id column in the cursor to fetch active
                                            life event
      27 Aug 01     tilak        115.61     bug:1949361 jurisdiction code is
                                            derived inside benutils.formula.
      18 nov 01     tjesumic     115.62     cwb changes
      20 dec 01     ikasire      115.63     added dbdrv lines
      22 jan 02     mhoyes       115.64   - Added p_per_in_ler_id and p_opt_id to
                                            call to get_elig_dpnt_rec.
      23 Jan 02     ikasire      115.65     Bug 2189561 dependent eligility profile
                                            not recognised when attached at plan level
      24 jan 02     tjesumic     115.66     2147682 - fixed by jc
      11 mar 02     mhoyes       115.67   - Tuned get_elig_dpnt_rec.
                                          - Modified c_per_in_ler changed alias from
                                            pil. to ler.
      12 jun 02     mhoyes       115.68   - Performance tuning. Bypassed call to
                                            get_elig_per_id.
      31 jul 02     hnarayan     115.69   - bug 1192368 - modified designation level determination
      					    in procedure main to first check if it is defined at
      					    plan level, then check at program level.
      03 Oct 02     tjesumic     115.70     # 2508745 To validate the PTIP level  the plan type id
                                            is validated instead of PTIP id , this allow to  validate
                                            across the porgram
      25 Nov-02     tjesumic     115.71     fix of the  # 2508745 reverted
      10 Feb-03     pbodla       115.72     Filter GRADE/STEP life events.
      18-Mar-04     kmahendr     115.73     bug#3495592 - cursor c_dpnt_exist added to
                                            check already created elig_dpnt record
      27-jul-04     nhunur       115.74     3685120-create elig_dpnt records for unrestricted.
      03-Aug-04     tjesumic     115.75     3784375 - cursor c_pdp changed to validate  the eot
      03-Aug-04     tjesumic     115.76     fonm changes
      16-Aug-04     kmahendr     115.77     Bug#3238951 - assign O to dpnt_dsgn_cd if the
                                            plan is waive and reversed the fix made for
                                            bug#1192368
      17-Sep-04     pbodla       115.78     iREC : Avoid fetching the iRecruitement
                                            life events.
      15-Nov-04     kmahendr     115.79     Unrest. enh changes
      14-dec-04     nhunur       115.80     4051409 - Reset variable l_elig_dpnt_id to allow creation
                                            of elig_dpnt rows for multiple contacts.
      07-Apr-05     abparekh     115. 81    Bug 4287999 : Fixed cursor c_contact not to select
                                                          deceased persons
      12-May-05     nhunur      115. 82    Bug 4366892 : Fixed cursor c_contact not to select
                                           one contact more than once if he has more than 1
                                           personal relationship.

      03-Jun-05     kmahendr    115.84     Added additional conditions to cursor c_contact
                                           to avoid regression
      03-Oct-05     kmahendr    115.85     Added mode_cd R to create elig_dpnt rows
      24-Oct-05     kmahendr    115.86     Bug#4658173 - effective_date is arrived
                                           based on pdp row
      26-Oct-05     bmanyam     115.87     Bug 4692782 - changed c_contact cursor.
      16-Dec-05     bmanyam     115.88     4697057 - Relationship End-date should
                                           be end-date of dependent coverage.
      04-Feb-06     mhoyes      115.89   - bug4966769 - hr_utility tuning.
      04-Apr-06     vborkar     115.90     Bug 5127698 : Changes in cursors c_pdp,
                                           c_plan_enrolment_info and c_oipl_enrolment_info.
      17-Apr-06     bmanyam     115.91     5152062 - Changed c_dsgn, such that
                                           all desgn.requirement are summed up
                                           at a particular level (PL/OIPL/OPT).
      26-May-06     bmanyam     115.92     5100008 - EGD elig_thru_dt is the
                                           date eligibility is lost. Previously the elig_thru_dt
                                           was updated with PDP cvg_thru_dt.
      28-Jun-06     swjain      115.94     5331889 - Added person_id as param in call to
                                           benutils.formula for ler_chg_dpnt_cvg_rl in procedure main
      15-Sep-06    rgajula      115.95     Bug 5529902: In the cursor c_dsgn
                                           if mx_dpnts_alwd_num is NULL, consider unlimited designees can be assigned.
      02-Apr-07     swjain      115.96     Bug 5936849 : Set L_ENV.MODE_CD using benutils
                                           if not available through benenvir
      01-Oct-09     krupani     115.97     Bug 7481099: Corrected the fix done against bug 4287999
      08-Mar-10     sagnanas    115.98     Bug 9443647 -  Corrected the fix done against bug 4287999
*/
--------------------------------------------------------------------------------
g_rec         benutils.g_batch_dpnt_rec;
g_cvg_thru_dt date := null;
g_mnanrd_condition boolean:=false;
--
--
--
-- Task 131 (pbodla): Elig dependent records are created soon after
-- person is found eligible. This procedure is called from
-- ben_manage_life_events.process_comp_objects(benmngle.pkb).
-- Then electable choice record is created in bendenrr.pkb.
-- Essentially elig dependent rows are created before creating
-- the electable choice row.
-- All elig dependent rows which belongs to a electable choice
-- row are stored in g_egd_table, Also  g_upd_epe_egd_rec record
-- holds the information required to update electable choice row.
--
procedure main
  (p_pgm_id            in     number default null
  ,p_pl_id             in     number default null
  ,p_plip_id           in     number default null
  ,p_ptip_id           in     number default null
  ,p_oipl_id           in     number default null
  ,p_pl_typ_id         in     number default null
  ,p_business_group_id in     number
  ,p_person_id         in     number
  ,p_effective_date    in     date
  ,p_lf_evt_ocrd_dt    in     date
  ,p_per_in_ler_id     in     number default null
  ,p_elig_per_id       in     number default null
  ,p_elig_per_opt_id   in     number default null
  )
is
  --
  l_proc                varchar2(80):= g_package||'.main2';
  l_process_flag        varchar2(30):= 'Y';
  l_level               varchar2(30):= 'PL';
  l_code                varchar2(30);
  l_cvg_strt_cd         varchar2(30);
  l_cvg_strt_rl         number(15);
  l_cvg_end_cd          varchar2(30);
  l_cvg_end_rl          number(15);
  l_chc_id              number(15);
  l_elig_flag           varchar2(30);
  l_inelig_rsn_cd       varchar2(30);
  l_exists              varchar2(1);
  l_elctbl_flag         ben_elig_per_elctbl_chc.elctbl_flag%TYPE;
  l_cvg_strt_dt         date;
  l_datetrack_mode      varchar2(30);
  l_cvg_end_dt          date;
  l_ler_chg_dpnt_cvg_cd varchar2(30);
  l_elig_cvrd_dpnt_id   number(15);
  l_pl_typ_id           number ;
  l_pdp_effective_start_date        date;
  l_pdp_effective_end_date          date;
  l_correction           boolean;
  l_update               boolean;
  l_update_override      boolean;
  l_update_change_insert boolean;
  l_mnanrd_condition     boolean:=false;
  --
  l_fonm_cvg_strt_dt   date  ;
  l_lf_evt_ocrd_dt     date  ;
  -- Formula stuff
  --
  l_outputs   ff_exec.outputs_t;
  --
  l_return    varchar2(30);
  --
  -- 9999 Can I get all comp objects  from cache????
  --
  -- Define cursors
  --
  cursor c_opt is
	select opt_id from ben_oipl_f oipl
	where oipl.oipl_id = p_oipl_id
    and    oipl.business_group_id = p_business_group_id
    and    l_lf_evt_ocrd_dt
	   between oipl.effective_start_date
	   and     oipl.effective_end_date;


  l_opt c_opt%rowtype;
  --- This cursor added to find the pl_typ id   # 2508745
  --- for the ptip comparison for different pgm pl_typ_id to be compared
  cursor  c_pl_typ is
   select pl_typ_id
     from ben_ptip_f  ptip
     where p_ptip_id =  ptip.ptip_id
       and l_lf_evt_ocrd_dt
           between ptip.effective_start_date
           and     ptip.effective_end_date   ;


  cursor   c_plan is
    select pl.dpnt_dsgn_cd,
	   pl.dpnt_cvg_strt_dt_cd,
	   pl.dpnt_cvg_strt_dt_rl,
	   pl.dpnt_cvg_end_dt_cd,
	   pl.dpnt_cvg_end_dt_rl
    from   ben_pl_f pl
    where  pl.pl_id = p_pl_id
    and    pl.business_group_id = p_business_group_id
    and    l_lf_evt_ocrd_dt
	   between pl.effective_start_date
	   and     pl.effective_end_date;
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
    and    pgm.business_group_id = p_business_group_id
    and    l_lf_evt_ocrd_dt
	   between pgm.effective_start_date
	   and     pgm.effective_end_date;
  --
  l_pgm    c_pgm%rowtype;
  --
  cursor   c_ptip is
    select ptip.dpnt_dsgn_cd,
           ptip.dpnt_cvg_strt_dt_cd,
           ptip.dpnt_cvg_strt_dt_rl,
           ptip.dpnt_cvg_end_dt_cd,
           ptip.dpnt_cvg_end_dt_rl
    from   ben_ptip_f ptip
    where  ptip.ptip_id = p_ptip_id
    and    ptip.business_group_id = p_business_group_id
    and    l_lf_evt_ocrd_dt
	   between ptip.effective_start_date
	   and ptip.effective_end_date;
  --
  l_ptip   c_ptip%rowtype;
  --
  -- Can I get it from cache????
  -- iREC : Ideally it should be obtained from cache or should passed
  -- from calling routine. For now avoid looking at iRec life events.
  --
  cursor   c_per_in_ler is
    select pil.ler_id,
	   pil.person_id,
	   pil.lf_evt_ocrd_dt,
	   pil.per_in_ler_id
    from   ben_per_in_ler pil,
           ben_ler_f  ler
    where  pil.person_id          = p_person_id
    --and    pil.business_group_id  = p_business_group_id
    and    pil.per_in_ler_stat_cd = 'STRTD'
    ---cwb changes
    and    ler.ler_id = pil.ler_id
    and    ler.typ_cd not in ('COMP', 'GSP', 'IREC')
    and    l_lf_evt_ocrd_dt
           between ler.effective_start_date
           and ler.effective_end_date
--  unrestricted enhancement
    and    pil.per_in_ler_id      = nvl(p_per_in_ler_id,pil.per_in_ler_id);
  --

  --
  l_per_in_ler  c_per_in_ler%rowtype;
  --
  l_loc_rec hr_locations_all%rowtype;
  l_jurisdiction_code varchar2(30);

   cursor   c_ler_chg_dep(p_level varchar2) is
    select chg.cvg_eff_strt_cd,
           chg.cvg_eff_end_cd,
           chg.cvg_eff_strt_rl,
           chg.cvg_eff_end_rl,
           chg.ler_chg_dpnt_cvg_cd,
           chg.ler_chg_dpnt_cvg_rl
    from   ben_ler_chg_dpnt_cvg_f chg
    where  chg.ler_id = l_per_in_ler.ler_id
    and    chg.business_group_id = p_business_group_id
    and    decode(p_level,
                  'PL',p_pl_id,
                  'PTIP',p_ptip_id,
                  'PGM', p_pgm_id) =
           decode(p_level,
                  'PL',chg.pl_id,
                  'PTIP',chg.ptip_id,
                  'PGM', chg.pgm_id)
    and    l_lf_evt_ocrd_dt
           between chg.effective_start_date
           and     chg.effective_end_date;

  /*
  --
  cursor   c_ler_chg_dep(p_level varchar2) is
    select chg.cvg_eff_strt_cd,
	   chg.cvg_eff_end_cd,
	   chg.cvg_eff_strt_rl,
	   chg.cvg_eff_end_rl,
	   chg.ler_chg_dpnt_cvg_cd,
	   chg.ler_chg_dpnt_cvg_rl
    from   ben_ler_chg_dpnt_cvg_f chg,
           ben_ptip_f  ptip
    where  chg.ler_id = l_per_in_ler.ler_id
    and    chg.business_group_id = p_business_group_id
    and    chg.Ptip_id = ptip.ptip_id (+)
    and    l_lf_evt_ocrd_dt
           between ptip.effective_start_date (+)
           and     ptip.effective_end_date    (+)
    and    decode(p_level,
		  'PL',p_pl_id,
		  'PTIP',l_pl_typ_id,    -- 2508745 ptip validateated agains pl type id
		  'PGM', p_pgm_id) =
	   decode(p_level,
		  'PL',chg.pl_id,
		  'PTIP',ptip.pl_typ_id,
		  'PGM', chg.pgm_id)
    and    l_lf_evt_ocrd_dt
	   between chg.effective_start_date
	   and     chg.effective_end_date;
 */
  --
  l_ler_chg_dep c_ler_chg_dep%rowtype;
  l_prtt_enrt_rslt_id number;
  --
  -- Gets the enrolment information for this plan
  --
  cursor c_plan_enrolment_info is
       select prtt_enrt_rslt_id
       from   ben_prtt_enrt_rslt_f pen
       where  pen.person_id=p_person_id and
              pen.business_group_id =p_business_group_id and
              --pen.sspndd_flag='N' and --5127698
              pen.prtt_enrt_rslt_stat_cd is null and
              pen.effective_end_date = hr_api.g_eot and
              nvl(l_lf_evt_ocrd_dt,p_effective_date)-1 <=
                pen.enrt_cvg_thru_dt and
              pen.enrt_cvg_strt_dt < pen.effective_end_date
              and pen.pl_id = p_pl_id
              and nvl(pen.pgm_id, -1) = nvl(p_pgm_id, -1);
  --
  -- Gets the enrolment information for this oipl
  --
  cursor c_oipl_enrolment_info  is
       select prtt_enrt_rslt_id
       from   ben_prtt_enrt_rslt_f pen
       where  pen.person_id=p_person_id and
              pen.business_group_id =p_business_group_id and
              --pen.sspndd_flag='N' and --5127698
              pen.prtt_enrt_rslt_stat_cd is null and
              pen.effective_end_date = hr_api.g_eot and
              nvl(l_lf_evt_ocrd_dt,p_effective_date)-1 <=
                pen.enrt_cvg_thru_dt and
              pen.enrt_cvg_strt_dt < pen.effective_end_date and
              pen.oipl_id=p_oipl_id
              and nvl(pen.pgm_id, -1) = nvl(p_pgm_id, -1);
  --
  cursor c_contact is
  select ctr.contact_person_id,
         ctr.contact_relationship_id,
	     ctr.contact_type,
         ctr.date_end, -- 4697057 Added this
         'Y' contact_active_flag,
         per.date_of_death                          /* Bug 7481099  */
    from per_contact_relationships ctr,
         per_all_people_f per
   where per.person_id = ctr.contact_person_id
--     and l_lf_evt_ocrd_dt <= nvl(per.DATE_OF_DEATH, l_lf_evt_ocrd_dt) /* Bug 4287999 */
     and l_lf_evt_ocrd_dt between per.effective_start_date and per.effective_end_date
     and ctr.personal_flag = 'Y'
     and ctr.contact_relationship_id =
               ( select min(contact_relationship_id)
	               from per_contact_relationships ctr2
                  where ctr2.contact_person_id = ctr.contact_person_id
                    and ctr2.person_id = p_person_id /* Bug 4692782 */
                    and ctr2.personal_flag = 'Y'
                    and l_lf_evt_ocrd_dt between
                            nvl(ctr2.date_start,nvl(l_lf_evt_ocrd_dt,p_effective_date))
                            and nvl(ctr2.date_end,nvl(l_lf_evt_ocrd_dt,p_effective_date))
               )
     and ctr.business_group_id = p_business_group_id
     and ctr.person_id = p_person_id
     and l_lf_evt_ocrd_dt between
           nvl(ctr.date_start,nvl(l_lf_evt_ocrd_dt,p_effective_date))
           and nvl(ctr.date_end,nvl(l_lf_evt_ocrd_dt,p_effective_date))
    union
    --
    -- this union is to provide rows for ended contacts.
    -- these ended contacts will have contact_active_flag='N'.
    -- these contacts elig_cvrd_dpnt rows should be ended.
    --
    select ctr.contact_person_id,
           ctr.contact_relationship_id,
	       ctr.contact_type,
           ctr.date_end,  -- 4697057 Added this
           'N' contact_active_flag,
           per.date_of_death                              /* Bug 7481099  */
      from per_contact_relationships ctr,
           per_all_people_f per,
           ben_elig_cvrd_dpnt_f pdp,
           ben_per_in_ler pil
     where per.person_id = ctr.contact_person_id
--       and l_lf_evt_ocrd_dt <= nvl(per.DATE_OF_DEATH, l_lf_evt_ocrd_dt) /* Bug 4287999 */
       and l_lf_evt_ocrd_dt between per.effective_start_date and per.effective_end_date
       and ctr.personal_flag = 'Y'
       and ctr.business_group_id = p_business_group_id
       and ctr.person_id = p_person_id
       and l_lf_evt_ocrd_dt >= nvl(ctr.date_end,nvl(l_lf_evt_ocrd_dt,p_effective_date))
       and pdp.prtt_enrt_rslt_id = l_prtt_enrt_rslt_id
       and pdp.business_group_id  = p_business_group_id
       and pdp.dpnt_person_id = ctr.contact_person_id
       and nvl(p_lf_evt_ocrd_dt,p_effective_date) between
                 pdp.effective_start_date and pdp.effective_end_date
       and l_lf_evt_ocrd_dt between pdp.cvg_strt_dt and nvl(pdp.cvg_thru_dt,hr_api.g_eot)
       and pil.per_in_ler_id=pdp.per_in_ler_id
       and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
       and not exists (
            select null
              from per_contact_relationships ctr1,
                   per_all_people_f per1
             where ctr1.contact_person_id=ctr.contact_person_id
               and per1.person_id = ctr1.contact_person_id
               and l_lf_evt_ocrd_dt between per1.effective_start_date and per1.effective_end_date
               and ctr1.personal_flag = 'Y'
               and ctr1.business_group_id = p_business_group_id
               and ctr1.person_id = p_person_id
               and nvl(l_lf_evt_ocrd_dt,p_effective_date) between
                        nvl(ctr1.date_start, nvl(l_lf_evt_ocrd_dt,p_effective_date))
                        and nvl(ctr1.date_end, nvl(l_lf_evt_ocrd_dt,p_effective_date)))
  ;
  --
  l_contact c_contact%rowtype;
  --
  -- hierarchy
  -- 1) oipl
  -- 2) opt
  -- 3) pl
  --
  cursor   c_dsgn is
    select a.lvl,  -- 5152062 : Added the GROUPING..
           SUM(NVL(a.mn_dpnts_rqd_num,0)) mn_dpnts_rqd_num,
           SUM(NVL(a.mx_dpnts_alwd_num,9999999)) mx_dpnts_alwd_num, --Bug 5529902: if mx_dpnts_alwd_num is NULL consider unlimited designees can be assigned
           MAX(NVL(a.no_mn_num_dfnd_flag,'N')) no_mn_num_dfnd_flag
      from (
    select decode(nvl(ddr.oipl_id,-1),
                  -1,
                  decode(nvl(ddr.opt_id,-1),
                         -1,
                         3,--pl level
                         2),--opt level
                  1) lvl, -- oipl level,
           mn_dpnts_rqd_num,
           mx_dpnts_alwd_num,
           no_mn_num_dfnd_flag
    from   ben_dsgn_rqmt_f ddr
    where  (ddr.oipl_id = p_oipl_id
            or ddr.pl_id = p_pl_id
            or ddr.opt_id = (select oipl.opt_id
                             from   ben_oipl_f oipl
                             where  oipl.oipl_id = p_oipl_id
                             and    oipl.business_group_id  =
                                    p_business_group_id
                             and    l_lf_evt_ocrd_dt
                                    between oipl.effective_start_date
                                    and     oipl.effective_end_date))
    and    ddr.dsgn_typ_cd  = 'DPNT'
    /*
       Task 133 : when mn_dpnts_rqd_num is 0 or no_mn_num_dfnd_flag is Y
       then make dpnt_dsgn_cd optional, otherwise no interim will be
       assigned. These commented conditions are checked when the rows are
       fetched.
    and    nvl(ddr.mn_dpnts_rqd_num,-1) = 0
    and    nvl(ddr.mx_dpnts_alwd_num,-1) = 0
    */
    and    ddr.business_group_id  = p_business_group_id
    and    l_lf_evt_ocrd_dt
	   between ddr.effective_start_date
	   and     ddr.effective_end_date
       ) a
    group by a.lvl
    order by 1
    ;
  --
  l_mn_dpnts_rqd_num    number;
  l_mx_dpnts_alwd_num   number;
  l_no_mn_num_dfnd_flag varchar2(1);
  cursor c_pdp is
    select pdp.object_version_number,
           pdp.elig_cvrd_dpnt_id,
           pdp.effective_start_date,
           pdp.cvg_strt_dt,
           pdp.effective_end_date
    from   ben_elig_cvrd_dpnt_f pdp,
           ben_per_in_ler pil
    where  pdp.prtt_enrt_rslt_id = l_prtt_enrt_rslt_id
    and    pdp.business_group_id  = p_business_group_id
    and    pdp.dpnt_person_id = l_contact.contact_person_id
    -- bug 3784375
    --and    nvl(p_lf_evt_ocrd_dt,p_effective_date)
    --	   between pdp.effective_start_date and pdp.effective_end_date
    and    pdp.effective_end_date = hr_api.g_eot
    --
    -- Bug 5127698 : Due to following date check, dependents do not get carry forwarded
    -- when PDP.cvg_strt_dt is later than l_lf_evt_ocrd_dt.
    -- Above date check(EOT) should be sufficient.
    --and    l_lf_evt_ocrd_dt
    --       between pdp.cvg_strt_dt and nvl(pdp.cvg_thru_dt,hr_api.g_eot)
    -- Instead of above check, added following check which will make sure that
    -- end dated dependents will not get carry forwarded
    and    nvl(pdp.cvg_thru_dt,hr_api.g_eot) >= l_lf_evt_ocrd_dt
    and    nvl(pdp.cvg_thru_dt,hr_api.g_eot) >= pdp.cvg_strt_dt
    and    pil.per_in_ler_id=pdp.per_in_ler_id
    and    pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT');
  --
  cursor c_dcln_pl_opt is
    select decode(pln.invk_dcln_prtn_pl_flag,
                     'N', nvl(opt.invk_wv_opt_flag,'N'),
                     'Y')                               dcln_pl_opt_flag
    from   ben_pl_f  pln,
           ben_oipl_f oipl,
           ben_opt_f  opt
    where  pln.pl_id        = p_pl_id
    and    oipl.oipl_id (+) = p_oipl_id
    and    oipl.pl_id (+)   = pln.pl_id
    and    oipl.opt_id      = opt.opt_id (+)
    and    l_lf_evt_ocrd_dt
           between pln.effective_start_date and pln.effective_end_date
    and    l_lf_evt_ocrd_dt
           between oipl.effective_start_date(+) and oipl.effective_end_date(+)
    and    l_lf_evt_ocrd_dt
           between opt.effective_start_date(+) and opt.effective_end_date(+);
  --
  cursor c_dpnt_exist (p_per_in_ler_id  number,
                       p_elig_per_id    number,
                       p_elig_per_opt_id number,
                       p_dpnt_person_id  number)  is
   select null
   from   ben_elig_dpnt egd
   where  egd.dpnt_person_id = p_dpnt_person_id
   and    egd.per_in_ler_id = p_per_in_ler_id
   and    egd.elig_per_id = p_elig_per_id
   and    (p_elig_per_opt_id is null or
          egd.elig_per_opt_id = p_elig_per_opt_id);
  --
  l_pdp c_pdp%rowtype;
  l_ass_rec per_all_assignments_f%rowtype;
  l_egd_rec ben_elig_dpnt%rowtype;
  l_egd_rec_found boolean := false;
  l_pdp_rec_found boolean := false;
  l_elig_dpnt_id  number;
  l_elig_per_id   number;
  l_elig_per_opt_id number;
  l_egd_object_version_number number(9);
  l_dummy        varchar2(1);
  l_dsgn_rqmt_level number;
  l_dpnt_cvg_strt_dt date;
  l_next_row         number;
  l_sysdate          date;
  l_decline_flag     varchar2(30) := 'N';
  --
  l_elig_per_elctbl_chc_id number;
   l_per_in_ler_id number;

  l_env ben_env_object.g_global_env_rec_type;
  l_benmngle_parm_rec  benutils.g_batch_param_rec;               /* Bug 5936849 */
  l_effective_date  date ;
  l_contact_date_end date;
  --
begin
  --
  g_debug := hr_utility.debug_enabled;
  --
  -- Set sysdate to a local
  --
  if g_debug then
    hr_utility.set_location ('Entering '||l_proc,10);
  end if;
  --
  if g_debug then
    hr_utility.set_location ('Fonm   '|| ben_manage_life_events.fonm ,10);
    hr_utility.set_location ('Fonm   '|| ben_manage_life_events.g_fonm_cvg_strt_dt ,10);
  end if;
  l_sysdate := sysdate;
  -- fonm
  l_lf_evt_ocrd_dt   := nvl(p_lf_evt_ocrd_dt, p_effective_date);
  if ben_manage_life_events.fonm = 'Y'
      and ben_manage_life_events.g_fonm_cvg_strt_dt is not null then
     --
     l_fonm_cvg_strt_dt := ben_manage_life_events.g_fonm_cvg_strt_dt ;
     l_lf_evt_ocrd_dt   := nvl(l_fonm_cvg_strt_dt,l_lf_evt_ocrd_dt ) ;

     --
     hr_utility.set_location ('Fonm Date  '||l_lf_evt_ocrd_dt ,10);
  end if;

  --
  if g_debug then
    hr_utility.set_location ('pl '||p_pl_id,10);
    hr_utility.set_location ('plip '||p_plip_id,10);
    hr_utility.set_location ('pgm '||p_pgm_id,10);
  end if;
  --
  g_egd_table.delete;
  g_egd_table := g_egd_table_temp;
  --
  if p_oipl_id is not null then
	open c_opt;
	fetch c_opt into l_opt;
	close c_opt;
  end if;
  -- Determine designation level
  --
  if g_debug then
    hr_utility.set_location ('Determining designation level '||l_proc,30);
  end if;
  -- fix made for 1192368 reversed - bug#3238951
  -- start fix 1192368
  -- while finding out the dependency designation level we should first see
  -- if it has been defined at plan level and then check the level at program
  -- level to see if it is PGM / PTIP
  -- Moved the cursor code of c_plan from below to here to check if
  -- pl.dpnt_dsgn_cd is null or not
  --
  /*
  open c_plan;
    --
    fetch c_plan into l_plan;
    if c_plan%notfound then
      --
      close c_plan;
      fnd_message.set_name('BEN','BEN_91472_PLAN_NOT_FOUND');
      fnd_message.set_token('PROC',l_proc);
      fnd_message.set_token('PL_ID',to_char(p_pl_id));
      fnd_message.raise_error;
      --
    end if;
    --
  close c_plan;
  */
  --
  -- end fix 1192368
  -- modified the if condn below to check for l_plan.dpnt_dsgn_cd before
  -- going into pgm level check.
  --
  if p_pgm_id is not null then
    --
    -- find the level from the program
    --
    open c_pgm;
      --
      fetch c_pgm into l_pgm;
      --
      if c_pgm%notfound then
        --
          close c_pgm;
	  fnd_message.set_name('BEN','BEN_91470_PGM_NOT_FOUND');
          fnd_message.set_token('PROC',l_proc);
          fnd_message.set_token('PGM_ID',to_char(p_pgm_id));
	  fnd_message.raise_error;
          --
      end if;
      --
    close c_pgm;
    --
    l_level := l_pgm.dpnt_dsgn_lvl_cd;
    --
  else
    --
    -- PLAN level
    --
    l_level := 'PL';
    --
  end if;
  --
  --Bug 2189561 in case of plan in program when the dpnt_dsgn_lvl_cd is null at plan level
  -- and  user defines ONLY in plan enrollment requirements, it fails.
  --To resolve the issue, we are resetting to PL if it is null
  --
  if l_level is null then
    --
    l_level := 'PL';
    --
  end if;
  --
  -- Retrieve designation code
  --
  if g_debug then
    hr_utility.set_location ('Level = '||l_level,40);
  end if;
  --
  if l_level = 'PGM' then
    --
    l_code := l_pgm.dpnt_dsgn_cd;
    --
  elsif l_level = 'PTIP' then
    --
    open c_ptip;
      --
      fetch c_ptip into l_ptip;
      --
      if c_ptip%notfound then
        --
        close c_ptip;
        fnd_message.set_name('BEN','BEN_91471_MISSING_PLAN_TYPE');
        fnd_message.set_token('PROC',l_proc);
        fnd_message.set_token('PTIP_ID',to_char(p_ptip_id));
        fnd_message.raise_error;
        --
      end if;
      --
    close c_ptip;
    --
    l_code := l_ptip.dpnt_dsgn_cd;
    --
  elsif l_level = 'PL' then
      --
       open c_plan;
       fetch c_plan into l_plan;
       if c_plan%notfound then
          --
         close c_plan;
         fnd_message.set_name('BEN','BEN_91472_PLAN_NOT_FOUND');
         fnd_message.set_token('PROC',l_proc);
         fnd_message.set_token('PL_ID',to_char(p_pl_id));
         fnd_message.raise_error;
       --
       end if;
       --
       close c_plan;
      --
      l_code := l_plan.dpnt_dsgn_cd;
      --
  else
    --
    l_code := NULL;
    l_process_flag := 'N';
    --
  end if;
  --
  if g_debug then
    hr_utility.set_location ('l_code '||l_code,50);
    hr_utility.set_location ('l_level '||l_level,50);
    hr_utility.set_location( 'l_process_flag ' || l_process_flag , 50) ;
  end if;
  --
  -- Check whether the choice is for Decline Plan/Option. If so,
  -- no need to create eligible dependents for them.
  --
  open  c_dcln_pl_opt;
  fetch c_dcln_pl_opt into l_decline_flag;
  close c_dcln_pl_opt;
  --
  if l_decline_flag = 'Y' then
    l_process_flag := 'N';
    --bug#3238951 - assign Optional to dependent designation
    l_code := 'O';
  end if;
  --
  -- Does this life event support dependent changes?
  --
  if g_debug then
    hr_utility.set_location ('Determining life event support '||l_proc,50);
    hr_utility.set_location ('Process Flag '||l_process_flag,50);
  end if;
  --
  if l_process_flag = 'Y' then
    --
    open c_per_in_ler;
      --
      fetch c_per_in_ler into l_per_in_ler;
      --
      if c_per_in_ler%notfound then
        --
        close c_per_in_ler;
        fnd_message.set_name('BEN','BEN_91473_PER_NOT_FOUND');
        fnd_message.set_token('PROC',l_proc);
        /* fnd_message.set_token('PER_IN_LER_ID',
                             to_char(l_elctbl_chc.per_in_ler_id)); */
        fnd_message.raise_error;
        --
      end if;
      --
    close c_per_in_ler;
    -- before ler change find out the  pl type id  # 2508745

    open c_pl_typ ;
    fetch c_pl_typ into l_pl_typ_id ;
    close  c_pl_typ ;
    --
    if g_debug then
      hr_utility.set_location( ' l_pl_typ_id ' || l_pl_typ_id , 40) ;
      hr_utility.set_location( ' l_process_flag ' || l_process_flag , 40) ;
    end if;
    --
    open c_ler_chg_dep(l_level);
      --
      fetch c_ler_chg_dep into l_ler_chg_dep;
      --
      if c_ler_chg_dep%notfound then
        --
        l_process_flag := 'N';
        --
        if g_debug then
          hr_utility.set_location( ' ler chagne l_process_flag ' || l_process_flag , 40) ;
        end if;
      else
        --
        l_ler_chg_dpnt_cvg_cd := l_ler_chg_dep.ler_chg_dpnt_cvg_cd;
        --
        if l_ler_chg_dpnt_cvg_cd = 'RL' then
	  --
          ben_person_object.get_object(p_person_id => l_per_in_ler.person_id,
                                       p_rec       => l_ass_rec);
          --
          if l_ass_rec.assignment_id is null then
            --
            ben_person_object.get_benass_object
                   (p_person_id => l_per_in_ler.person_id,
                    p_rec       => l_ass_rec);
            --
          end if;
          --
          if l_ass_rec.location_id is not null then
            --
            ben_location_object.get_object
               (p_location_id => l_ass_rec.location_id,
                p_rec         => l_loc_rec);
            --
            --if l_loc_rec.region_2 is not null then
            --    l_jurisdiction_code := pay_mag_utils.lookup_jurisdiction_code
            --                        (p_state => l_loc_rec.region_2);
            --end if ;
            --
          end if;
          --
          l_outputs := benutils.formula
            (p_formula_id       => l_ler_chg_dep.ler_chg_dpnt_cvg_rl,
             p_effective_date   => nvl(p_lf_evt_ocrd_dt,p_effective_date),
             p_assignment_id    => l_ass_rec.assignment_id,
             p_organization_id  => l_ass_rec.organization_id,
             p_business_group_id => p_business_group_id,
             p_pgm_id            => p_pgm_id,
             p_pl_id             => p_pl_id,
             p_pl_typ_id         => p_pl_typ_id,
             p_opt_id            => l_opt.opt_id,
             p_ler_id            => l_per_in_ler.ler_id,
             p_elig_per_elctbl_chc_id => null,
             p_jurisdiction_code => l_jurisdiction_code,
	     p_param1               => 'BEN_IV_PERSON_ID',          -- Bug 5331889
             p_param1_value         => to_char(p_person_id));
          --
          l_ler_chg_dpnt_cvg_cd := l_outputs(l_outputs.first).value;
          --
        end if;
        --
	if l_ler_chg_dpnt_cvg_cd in ('MNANRD', 'N') then
          --
	  l_process_flag := 'N';
          --
        end if;
         hr_utility.set_location( ' ler chagne l_process_flag ' || l_process_flag , 50) ;

	if l_ler_chg_dpnt_cvg_cd in ('MNANRD', 'N','MRD') then
          --
          -- If the below flag is true then process the dependents
          -- as if process_flag='Y' but update choice to be not
          -- designatable.
          --
          l_mnanrd_condition:=true;
          hr_utility.set_location ('mnanrd set',59);
          --
        end if;
        --
      end if;
      --
    close c_ler_chg_dep;
    --
  end if;
  --
  if g_debug then
    hr_utility.set_location ('Checking comp object dep allowed '||l_proc,60);
    hr_utility.set_location ('Process Flag '||l_process_flag,50);
  end if;
  --
  if l_process_flag = 'Y' then
          hr_utility.set_location ('in this if',50);
    --
    -- See if we can find designation requirements ben_dsgn_rqmt_f
    -- If designation requirments does not exist, than any number
    -- or type of dependents are allowed.  If designation requirements
    -- are found, then the min and max cannot be 0(Employee Only option).
    --
    open c_dsgn;
      --
      fetch c_dsgn into l_dsgn_rqmt_level,
                        l_mn_dpnts_rqd_num,
                        l_mx_dpnts_alwd_num,
                        l_no_mn_num_dfnd_flag;
      --
      if c_dsgn%found then
        --
        -- Task 133 : Interim coverage cannot be assigned when in
        -- insufficient number of dependents have been designated
        -- to a participant enrollment. In this case, the current
        -- product will end the participant's current coverage.
        -- To have above functionality, if no dependent designation
        -- is required if l_mn_dpnts_rqd_num is 0 or l_no_mn_num_dfnd_flag
        -- is Y.
        --
        if nvl(l_mn_dpnts_rqd_num, -1) = 0 and
           nvl(l_mx_dpnts_alwd_num, -1) = 0 and
           l_no_mn_num_dfnd_flag = 'N' then
           -- 5152062 : Set process_flag to 'N' , only if  if explicitly set l_mn_dpnts_rqd_num to 'Y'.
           --
           hr_utility.set_location ('dsgn not found',50);
           l_process_flag := 'N';
           --
        end if;
        --
        if nvl(l_mn_dpnts_rqd_num, -1) = 0
          -- 5152062 : Do not need the below condition.
          -- OR l_no_mn_num_dfnd_flag = 'Y'
        then
           --
           l_code := 'O';
           --
        end if;
      end if;
      --
    close c_dsgn;

  end if;
  --
  if g_debug then
    hr_utility.set_location ('Process Flag '||l_process_flag,50);
  end if;
  --
  --  Determine coverage dates
  --
  if l_process_flag = 'Y' or l_mnanrd_condition then
    --
    hr_utility.set_location ('Determining coverage dates '||l_proc,70);
    --
    l_cvg_strt_cd := l_ler_chg_dep.cvg_eff_strt_cd;
    l_cvg_strt_rl := l_ler_chg_dep.cvg_eff_strt_rl;
    l_cvg_end_cd  := l_ler_chg_dep.cvg_eff_end_cd;
    l_cvg_end_rl  := l_ler_chg_dep.cvg_eff_end_rl;
    --
    if l_cvg_strt_cd is null and l_cvg_strt_rl is null then
      --
      if l_level ='PL' then
        --
        l_cvg_strt_cd := l_plan.dpnt_cvg_strt_dt_cd;
        l_cvg_strt_rl := l_plan.dpnt_cvg_strt_dt_rl;
        l_cvg_end_cd  := l_plan.dpnt_cvg_end_dt_cd;
        l_cvg_end_rl  := l_plan.dpnt_cvg_end_dt_rl;
        --
      elsif l_level = 'PTIP' then
        --
        l_cvg_strt_cd := l_ptip.dpnt_cvg_strt_dt_cd;
        l_cvg_strt_rl := l_ptip.dpnt_cvg_strt_dt_rl;
        l_cvg_end_cd  := l_ptip.dpnt_cvg_end_dt_cd;
        l_cvg_end_rl  := l_ptip.dpnt_cvg_end_dt_rl;
        --
      elsif l_level ='PGM' then
        --
        -- Use program dates if available
        --
        l_cvg_strt_cd := l_pgm.dpnt_cvg_strt_dt_cd;
        l_cvg_strt_rl := l_pgm.dpnt_cvg_strt_dt_rl;
        l_cvg_end_cd  := l_pgm.dpnt_cvg_end_dt_cd;
        l_cvg_end_rl  := l_pgm.dpnt_cvg_end_dt_rl;
        --
      end if;
      --
    end if;
    --
    if l_cvg_strt_cd is null then
      --
      fnd_message.set_name('BEN','BEN_91475_DEPT_ST_DT_NULL');
      fnd_message.set_token('PROC',l_proc);
      fnd_message.set_token('LER_ID',to_char(l_per_in_ler.ler_id));
      fnd_message.raise_error;
      --
    else
      --
      IF l_cvg_strt_cd <> 'RL' THEN
      --
      hr_utility.set_location('cvg_strt_cd'||l_cvg_strt_cd,10);
      hr_utility.set_location('cvg_strt_rl'||l_cvg_strt_rl,10);
      ben_determine_date.main
       (P_DATE_CD                => l_cvg_strt_cd,
        P_BUSINESS_GROUP_ID      => p_business_group_id,
        P_PERSON_ID              => p_person_id,
        P_PGM_ID                 => p_pgm_id,
        P_PL_ID                  => p_pl_id,
        P_OIPL_ID                => p_oipl_id,
        P_PER_IN_LER_ID          => l_per_in_ler.per_in_ler_id,
        P_ELIG_PER_ELCTBL_CHC_ID => null,
        P_FORMULA_ID             => l_cvg_strt_rl,
        P_EFFECTIVE_DATE         => p_effective_date,
        P_LF_EVT_OCRD_DT         => p_lf_evt_ocrd_dt,
        P_RETURNED_DATE          => l_cvg_strt_dt
         );
      --
      END IF;
      --
    end if;
    --
  end if;
  --
  if g_debug then
    hr_utility.set_location ('l_Process_flag '||l_process_flag,80);
  end if;
  --
  g_upd_epe_egd_rec.g_process_flag  :=  l_Process_flag;
  g_mnanrd_condition:=l_mnanrd_condition;
  g_upd_epe_egd_rec.g_code          :=  l_code;
  g_upd_epe_egd_rec.g_ler_chg_dpnt_cvg_cd  :=  l_ler_chg_dpnt_cvg_cd;
  g_upd_epe_egd_rec.g_cvg_strt_cd   :=  l_cvg_strt_cd;
  g_upd_epe_egd_rec.g_cvg_strt_rl   :=  l_cvg_strt_rl;
  --
  if l_Process_flag = 'Y' or l_mnanrd_condition then
    --
    -- Loop through potential dependent pool
    --
    hr_utility.set_location ('open c_contact2 '||l_proc,90);
    --
    -- Get the enrollment result row.
    --
    if (p_oipl_id is null) then
        --
        open c_plan_enrolment_info;
        fetch c_plan_enrolment_info into l_prtt_enrt_rslt_id;
        close c_plan_enrolment_info;
        --
    else
        --
        open c_oipl_enrolment_info;
        fetch c_oipl_enrolment_info into l_prtt_enrt_rslt_id;
        close c_oipl_enrolment_info;
        --
    end if;
    --
    open c_contact;
      loop
          hr_utility.set_location ('again in loop',50);

	--
	fetch c_contact into l_contact;
	exit when c_contact%notfound;
	--
        -- 9999 As enrollment result not available,
        -- How to find the pdp. Need to derive from the
        -- comp object combination. ????
        --
      -- Following condition is added to fix Bug 1531647 to add inpute value contact_person_id

      IF l_cvg_strt_cd = 'RL' THEN
      --
      hr_utility.set_location('cvg_strt_cd'||l_cvg_strt_cd,10);
      hr_utility.set_location('cvg_strt_rl'||l_cvg_strt_rl,10);
      ben_determine_date.main
       (P_DATE_CD                => l_cvg_strt_cd,
        P_BUSINESS_GROUP_ID      => p_business_group_id,
        P_PERSON_ID              => p_person_id,
        P_PGM_ID                 => p_pgm_id,
        P_PL_ID                  => p_pl_id,
        P_OIPL_ID                => p_oipl_id,
        P_PER_IN_LER_ID          => l_per_in_ler.per_in_ler_id,
        P_ELIG_PER_ELCTBL_CHC_ID => null,
        P_FORMULA_ID             => l_cvg_strt_rl,
        P_EFFECTIVE_DATE         => p_effective_date,
        P_LF_EVT_OCRD_DT         => p_lf_evt_ocrd_dt,
        P_RETURNED_DATE          => l_cvg_strt_dt,
        P_PARAM1                 => 'CON_PERSON_ID',
        P_PARAM1_VALUE           => to_char(l_contact.contact_person_id));
      --
      END IF;
      --
        open c_pdp;
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
        --
        if l_contact.contact_active_flag='Y' then
          --
          hr_utility.set_location ('BEDEP_MN '||l_proc,90);
          --fonm taken care inside of the code dont pass any date
	  ben_evaluate_dpnt_elg_profiles.main
            (p_contact_relationship_id  => l_contact.contact_relationship_id,
	     p_contact_person_id        => l_contact.contact_person_id,
	     p_pgm_id                   => p_pgm_id,
	     p_pl_id                    => p_pl_id,
	     p_ptip_id                  => p_ptip_id,
	     p_oipl_id                  => p_oipl_id,
	     p_business_group_id        => p_business_group_id,
	     p_per_in_ler_id            => l_per_in_ler.per_in_ler_id,
	     p_effective_date           => p_effective_date,
	     p_lf_evt_ocrd_dt           => p_lf_evt_ocrd_dt,
             p_dpnt_cvg_strt_dt         => l_dpnt_cvg_strt_dt,
	     p_level                    => l_level,
	     p_dependent_eligible_flag  => l_elig_flag,
             p_dpnt_inelig_rsn_cd       => l_inelig_rsn_cd);
          hr_utility.set_location ('Dn BEDEP_MN '||l_proc,90);
        else
          hr_utility.set_location ('contact ended '||l_proc,90);
          l_elig_flag:='N';
          l_contact_date_end := l_contact.date_end;
        end if;
        --
        hr_utility.set_location ('l_contact.date_of_death '||l_contact.date_of_death,110);
        hr_utility.set_location ('l_lf_evt_ocrd_dt '||l_lf_evt_ocrd_dt,110);

        -- Bug 7481099
        -- if dependent is not already enrolled and if he is dead, set elig flag to N
        if not l_pdp_rec_found and nvl(l_contact.date_of_death,hr_api.g_eot) <= l_lf_evt_ocrd_dt then
           l_elig_flag := 'N';
           hr_utility.set_location ('setting elig_flag to N ',110);
        end if;

        -- Bug 7481099

        if l_pdp_rec_found then
           --
           -- 9999 is it required? As it is based on pdp.
           --
           l_egd_rec_found := ben_ELIG_DPNT_api.get_elig_dpnt_rec(
                                p_elig_cvrd_dpnt_id => l_elig_cvrd_dpnt_id,
                                p_effective_date    => l_lf_evt_ocrd_dt,
                                p_elig_dpnt_rec     => l_egd_rec);
           --
        else
           --
           l_egd_rec_found := ben_ELIG_DPNT_api.get_elig_dpnt_rec
                                (p_pl_id           => p_pl_id
                                ,p_pgm_id          => p_pgm_id
                                ,p_oipl_id         => p_oipl_id
                                ,p_dpnt_person_id  => l_contact.contact_person_id
                                ,p_effective_date  => l_lf_evt_ocrd_dt
                                --
                                ,p_per_in_ler_id   => p_per_in_ler_id
                                ,p_elig_per_id     => p_elig_per_id
                                ,p_elig_per_opt_id => p_elig_per_opt_id
                                ,p_opt_id          => l_opt.opt_id
                                --
                                ,p_elig_dpnt_rec   => l_egd_rec
                                );
           --
        end if;
        hr_utility.set_location ('Dn BEDP_GEDR '||l_proc,90);
        --
        if l_elig_flag = 'Y' then
           --
           g_rec.person_id := l_per_in_ler.person_id;
           g_rec.pgm_id := p_pgm_id;
           g_rec.pl_id := p_pl_id;
           g_rec.oipl_id := p_oipl_id;
           g_rec.contact_typ_cd := l_contact.contact_type;
           g_rec.dpnt_person_id := l_contact.contact_person_id;
           g_rec.business_group_id := p_business_group_id;
           g_rec.effective_date := p_effective_date;
           --
           benutils.write(p_rec => g_rec);
           --
           hr_utility.set_location (' Elig Y BED_GEPID '||l_proc,90);
           if p_elig_per_id is not null
           then
             --
             l_elig_per_id     := p_elig_per_id;
             l_elig_per_opt_id := p_elig_per_opt_id;
             --
           else
             --
             ben_ELIG_DPNT_api.get_elig_per_id
               (p_person_id         => l_per_in_ler.person_id
               ,p_pgm_id            => p_pgm_id
               ,p_pl_id             => p_pl_id
               ,p_oipl_id           => p_oipl_id
               ,p_business_group_id => p_business_group_id
               ,p_effective_date    => l_lf_evt_ocrd_dt
               ,p_elig_per_id       => l_elig_per_id
               ,p_elig_per_opt_id   => l_elig_per_opt_id
               );
             --
           end if;
           --
           hr_utility.set_location (' Elig Y BED_CED '||l_proc,90);
           --
           -- 3685120 - Get the environment details and if it is U then create EGD
           --
           ben_env_object.get(p_rec => l_env);
           --
	   -- Bug 5936849
           hr_utility.set_location('ACE l_env.mode_cd = ' || l_env.mode_cd, 9999);
           hr_utility.set_location('ACE l_env.benefit_action_id = ' || l_env.benefit_action_id, 9999);
           --
	   if l_env.mode_cd is null
	   then
	     --
             benutils.get_batch_parameters(p_benefit_action_id => l_env.benefit_action_id,
                                           p_rec               => l_benmngle_parm_rec
                                           );
             --
             hr_utility.set_location('ACE l_benmngle_parm_rec.mode_cd = ' || l_benmngle_parm_rec.mode_cd, 9999);
	     --
	     l_env.mode_cd :=  l_benmngle_parm_rec.mode_cd;
	     --
	   end if;
	   --
           -- End Bug 5936849

           hr_utility.set_location (' env mode cd '||l_env.mode_cd ,90);
           --bug#3495592 - cursor to check already created elig_dpnt record
           open c_dpnt_exist (p_per_in_ler_id =>l_per_in_ler.per_in_ler_id,
                              p_elig_per_id  => l_elig_per_id,
                              p_elig_per_opt_id => l_elig_per_opt_id,
                              p_dpnt_person_id  => l_contact.contact_person_id);
           fetch c_dpnt_exist into l_dummy;
           if c_dpnt_exist%notfound or nvl(l_env.mode_cd,'~') in ('R', 'U') then
             if l_env.mode_cd in ('U','R') then
               --
                hr_utility.set_location ('inside ',11);
               /*j
               l_elig_dpnt_id := ben_manage_unres_life_events.egd_exists
                                 (p_PER_IN_LER_ID => 1 --l_per_in_ler.per_in_ler_id
                                 ,p_ELIG_PER_ID   => 1 --l_elig_per_id
                                 ,p_ELIG_PER_OPT_ID => 1 --l_elig_per_opt_id
                                 ,p_DPNT_PERSON_ID =>1 --l_contact.contact_person_id
                                 );
              */
               l_elig_dpnt_id := ben_manage_unres_life_events.egd_exists
                                 (p_PER_IN_LER_ID => 1
                                 ,p_ELIG_PER_ID   => 1
                                 ,p_ELIG_PER_OPT_ID => 1
                                 ,p_DPNT_PERSON_ID =>1
                                 );
              hr_utility.set_location ('after',12);
             end if;
             if l_elig_dpnt_id is not null then
               --
               ben_manage_unres_life_events.update_elig_dpnt
                 (p_elig_dpnt_id           => l_elig_dpnt_id
                 ,p_create_dt              => l_lf_evt_ocrd_dt
                 ,p_business_group_id      => p_business_group_id
                 ,p_elig_per_elctbl_chc_id => null
                 ,p_dpnt_person_id         => l_contact.contact_person_id
                 ,p_per_in_ler_id          => l_per_in_ler.per_in_ler_id
                 ,p_elig_cvrd_dpnt_id      => l_elig_cvrd_dpnt_id
                 ,p_elig_strt_dt           => nvl(l_egd_rec.elig_strt_dt,
                                                 nvl(p_lf_evt_ocrd_dt,
                                                     p_effective_date))
                 ,p_elig_thru_dt           => hr_api.g_eot
                 ,p_elig_per_id            => l_elig_per_id
                 ,p_elig_per_opt_id        => l_elig_per_opt_id,
                  p_ovrdn_flag             => nvl(l_egd_rec.ovrdn_flag,'N')
                 ,p_ovrdn_thru_dt          => l_egd_rec.ovrdn_thru_dt
                 ,p_object_version_number  => l_egd_object_version_number
                 ,p_effective_date         => p_effective_date
                 ,p_program_application_id => fnd_global.prog_appl_id
                 ,p_program_id             => fnd_global.conc_program_id
                 ,p_request_id             => fnd_global.conc_request_id
                 ,p_program_update_date    => l_sysdate
                 );
                 --
             else
               ben_elig_dpnt_api.create_perf_elig_dpnt
                 (p_elig_dpnt_id           => l_elig_dpnt_id
                 ,p_create_dt              => l_lf_evt_ocrd_dt
                 ,p_business_group_id      => p_business_group_id
                 ,p_elig_per_elctbl_chc_id => null
                 ,p_dpnt_person_id         => l_contact.contact_person_id
                 ,p_per_in_ler_id          => l_per_in_ler.per_in_ler_id
                 ,p_elig_cvrd_dpnt_id      => l_elig_cvrd_dpnt_id
                 ,p_elig_strt_dt           => nvl(l_egd_rec.elig_strt_dt,
                                                 nvl(p_lf_evt_ocrd_dt,
                                                     p_effective_date))
                 ,p_elig_thru_dt           => hr_api.g_eot
                 ,p_elig_per_id            => l_elig_per_id
                 ,p_elig_per_opt_id        => l_elig_per_opt_id,
                  p_ovrdn_flag             => nvl(l_egd_rec.ovrdn_flag,'N')
                 ,p_ovrdn_thru_dt          => l_egd_rec.ovrdn_thru_dt
                 ,p_object_version_number  => l_egd_object_version_number
                 ,p_effective_date         => p_effective_date
                 ,p_program_application_id => fnd_global.prog_appl_id
                 ,p_program_id             => fnd_global.conc_program_id
                 ,p_request_id             => fnd_global.conc_request_id
                 ,p_program_update_date    => l_sysdate
                 );
                 --
               end if;

              hr_utility.set_location ('Dn Elig Y '||l_proc,90);

           --
              l_next_row := nvl(g_egd_table.LAST, 0) + 1;
              g_egd_table(l_next_row).object_version_number := l_egd_object_version_number;
              g_egd_table(l_next_row).elig_dpnt_id := l_elig_dpnt_id;
              l_elig_dpnt_id := null ; -- 4051409 - regression

           end if;
           close c_dpnt_exist;
           --
        else
          --
          --  Only update the coverage end date if dependent is currently
          --  ineligible.
          --
          -- jcarpent bug fix for bug 1524099 below.
          -- added nvl below.
          -- jcarpent bug fix for 2147682 , merged by tilak
          if nvl(l_egd_rec.dpnt_inelig_flag,'N') = 'N'  and l_pdp_rec_found = true  then
            --
            --  Get coverage end date
            --
            if l_cvg_end_cd is null then
              --
              fnd_message.set_name('BEN','BEN_91478_INVALID_DEP_ENDDT');
              fnd_message.set_token('PROC',l_proc);
              fnd_message.set_token('LER_ID',to_char(l_per_in_ler.ler_id));
              fnd_message.raise_error;
              --
            else
              --
              hr_utility.set_location('l_cvg_end_cd'||l_cvg_end_Cd,10);
              hr_utility.set_location('l_cvg_end_rl'||l_cvg_end_rl,10);
              hr_utility.set_location('l_contact.date_end '|| l_contact.date_end,10);
              hr_utility.set_location('l_lf_evt_ocrd_dt '|| l_lf_evt_ocrd_dt,10);
              hr_utility.set_location('get_elig_change_dt '|| ben_evaluate_dpnt_elg_profiles.get_elig_change_dt,10);
              --
              -- 4697057 : If relationship is end-dated, determine end-date as of
              --           relationship_end, rather than ben_evaluate_dpnt_elg_profiles.get_elig_change_dt,
              --           since  ben_evaluate_dpnt_elg_profiles.set_elig_change_dt is never
              --           called in this case..
              --9443647
              if (l_contact.date_end < l_lf_evt_ocrd_dt) then
                 l_contact_date_end := l_contact.date_end + 1;
              else
                 l_contact_date_end := ben_evaluate_dpnt_elg_profiles.get_elig_change_dt + 1;
              end if;
              --
              --
              ben_determine_date.main
               (P_DATE_CD                => l_cvg_end_cd,
                P_BUSINESS_GROUP_ID      => p_business_group_id,
                P_PERSON_ID              => p_person_id,
                P_PGM_ID                 => p_pgm_id,
                P_PL_ID                  => p_pl_id,
                P_OIPL_ID                => p_oipl_id,
                P_PER_IN_LER_ID          => l_per_in_ler.per_in_ler_id,
                P_ELIG_PER_ELCTBL_CHC_ID => null,
                P_FORMULA_ID             => l_cvg_end_rl,
                P_EFFECTIVE_DATE         => p_effective_date,
                P_LF_EVT_OCRD_DT         => l_contact_date_end, -- 4697057
                P_RETURNED_DATE          => l_cvg_end_dt,
                P_PARAM1                 => 'CON_PERSON_ID',
                P_PARAM1_VALUE           => to_char(l_contact.contact_person_id));
              --
            end if;
            hr_utility.set_location ('Dn Elig N BENDETDT '||l_proc,90);
            --
            -- According to the cursor, the coverage has started as of the
            -- effective date, so the coverage through date should atleast be
            -- the coverge start date. If the coverage through date is less
            -- than the coverage start date, we assign a value of effective
            -- date.
            --
            if l_cvg_end_dt < l_pdp.cvg_strt_dt then
              --
              l_cvg_end_dt := l_LF_EVT_OCRD_DT;
              --
            end if;
            --
            if l_pdp_rec_found then
              --
              --bug#4658173
              if nvl(p_lf_evt_ocrd_dt,p_effective_date) < l_pdp.effective_start_date then
                l_effective_date := l_pdp.effective_start_date;
              else
                l_effective_date := nvl(p_lf_evt_ocrd_dt,p_effective_date);
              end if;
              -- Check datetrack mode.
              --
              dt_api.find_dt_upd_modes
                (p_effective_date       => l_effective_date,
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
              hr_utility.set_location ('datetrack_mode '||l_datetrack_mode,10);
	      --
	      -- Update the eligible dependent record
	      --
              hr_utility.set_location (' Elig N BECD_UECD '||l_proc,90);
              hr_utility.set_location (' l_cvg_thru_dt '||l_cvg_end_dt,90);
              --
	          ben_elig_cvrd_dpnt_api.update_elig_cvrd_dpnt
                (p_elig_cvrd_dpnt_id      => l_elig_cvrd_dpnt_id
                ,p_effective_start_date   => l_pdp_effective_start_date
                ,p_effective_end_date     => l_pdp_effective_end_date
                ,p_per_in_ler_id          => l_per_in_ler.per_in_ler_id
                ,p_cvg_thru_dt            => l_cvg_end_dt
                ,p_object_version_number  => l_pdp.object_version_number
                ,p_effective_date         => l_effective_date
                ,p_datetrack_mode         => l_datetrack_mode
                ,p_program_application_id => fnd_global.prog_appl_id
                ,p_program_id             => fnd_global.conc_program_id
                ,p_request_id             => fnd_global.conc_request_id
                ,p_program_update_date    => l_sysdate
                ,p_business_group_id      => p_business_group_id
                ,p_multi_row_actn         => FALSE
                );
                --
                -- RCHASE - update elig_dpnt row when coverage is lost due to ineligibility
                if l_egd_rec.dpnt_inelig_flag = 'N' then
                --
                   hr_utility.set_location(' Set Dpnt InElig ' || (l_contact_date_end -1), 10);
                   hr_utility.set_location(' l_egd_rec.object_version_number ' || l_egd_rec.object_version_number, 10);
                   --
                   ben_elig_dpnt_api.update_elig_dpnt(
                                     p_elig_dpnt_id          => l_egd_rec.elig_dpnt_id
                                    ,p_object_version_number => l_egd_rec.object_version_number
                                    ,p_effective_date        => nvl(l_lf_evt_ocrd_dt,p_effective_date)
                                    ,p_elig_thru_dt          => (l_contact_date_end-1) --l_cvg_end_dt 5100008
                                    ,p_dpnt_inelig_flag      => 'Y'
                                    ,p_inelg_rsn_cd          => l_inelig_rsn_cd
                                    );
               --
               end if;
              --
              --  Update global variable so a benefit assignment can
              --  be written.
              --
              hr_utility.set_location ('dpnt ineligible  ',90);
              g_dpnt_ineligible := true;
              --
            end if;
            --
            if l_egd_rec_found then
              --
              hr_utility.set_location (' Elig N BED_UED '||l_proc,90);
              --
              ben_elig_dpnt_api.update_perf_elig_dpnt
                (p_elig_dpnt_id           => l_egd_rec.elig_dpnt_id
                ,p_per_in_ler_id          => l_per_in_ler.per_in_ler_id
                ,p_elig_thru_dt           => (l_contact_date_end-1)--nvl(l_cvg_end_dt,p_effective_date) 5100008
                ,p_dpnt_inelig_flag       => 'Y'
                ,p_inelg_rsn_cd           => l_inelig_rsn_cd
                ,p_object_version_number  => l_egd_rec.object_version_number
                ,p_effective_date         => nvl(l_lf_evt_ocrd_dt,p_effective_date)
                ,p_program_application_id => fnd_global.prog_appl_id
                ,p_program_id             => fnd_global.conc_program_id
                ,p_request_id             => fnd_global.conc_request_id
                ,p_program_update_date    => l_sysdate
                );
               --
            end if;
            --
            hr_utility.set_location ('Dn Elig N '||l_proc,90);
          end if;
        end if; -- elig_flag = 'Y'
        --
        hr_utility.set_location ('End Con Loop '||l_proc,90);
      end loop;
      --
    close c_contact;
    hr_utility.set_location ('close c_contact '||l_proc,90);
    --
  end if;
  --
  if g_debug then
    hr_utility.set_location ('Leaving '||l_proc,80);
  end if;
end;
--
-- Task 131 (pbodla): Elig dependent records are created soon after
-- person is found eligible(In benmngle.pkb). Then electable
-- coice record is created in bendenrr.pkb. This procedure
-- links all the elig dependent rows and electable choice row.
-- All elig dependent rows which belongs to a electable choice
-- row are stored in g_egd_table, Also  g_upd_epe_egd_rec record
-- holds the information required to update electable choice row.
-- Both g_egd_table, g_upd_epe_egd_rec are populated by bendepen.pkb
--
procedure p_upd_egd_with_epe_id
  (p_elig_per_elctbl_chc_id   in number
  ,p_person_id                in number
  ,p_effective_date           in date
  ,p_lf_evt_ocrd_dt           in date
  )
is
  --
  l_proc                varchar2(80):= g_package||'.p_upd_egd_with_epe_id';
  l_chc_id              number(15);
  l_elctbl_flag         ben_elig_per_elctbl_chc.elctbl_flag%TYPE;
  --
  -- Formula stuff
  --
  l_outputs   ff_exec.outputs_t;
  l_return    varchar2(30);
/*
  --
  -- Define cursors
  --
  cursor c_elctbl_chc is
    select chc.elig_per_elctbl_chc_id,
	   chc.object_version_number,
	   chc.business_group_id,
	   chc.per_in_ler_id,
	   chc.pgm_id,
	   chc.pl_id,
	   chc.pl_typ_id,
	   chc.ptip_id,
	   chc.oipl_id,
	   chc.prtt_enrt_rslt_id,
           chc.elctbl_flag,
           pel.enrt_perd_id
    from   ben_elig_per_elctbl_chc chc,
           ben_pil_elctbl_chc_popl pel
    where  chc.elig_per_elctbl_chc_id = l_chc_id
    and    chc.pil_elctbl_chc_popl_id = pel.pil_elctbl_chc_popl_id;
  --
  l_elctbl_chc c_elctbl_chc%rowtype;
*/
  --
  l_elctbl_chc ben_epe_cache.g_pilepe_inst_row;
  --
  cursor   c_per_in_ler is
    select pil.ler_id,
	   pil.person_id,
	   pil.lf_evt_ocrd_dt
    from   ben_per_in_ler pil
    where  pil.per_in_ler_id = l_elctbl_chc.per_in_ler_id
    and    pil.business_group_id = l_elctbl_chc.business_group_id
    and    pil.per_in_ler_stat_cd = 'STRTD';
  --
  l_per_in_ler  c_per_in_ler%rowtype;
  l_sysdate     date;
  --
begin
  --
  g_debug := hr_utility.debug_enabled;
  --
  hr_utility.set_location ('Entering '||l_proc,10);
  --
  -- Set sysdate to a local
  --
  l_sysdate := sysdate;
  --
  -- get the electable choice
  --
  hr_utility.set_location('Elig_per_elctbl_chc_id '||p_elig_per_elctbl_chc_id,10);
  l_chc_id := p_elig_per_elctbl_chc_id;
  --
  -- Check that current comp object loop EPE row is set
  --
  if ben_epe_cache.g_currcobjepe_row.elig_per_elctbl_chc_id is not null then
    --
    l_elctbl_chc.elig_per_elctbl_chc_id := ben_epe_cache.g_currcobjepe_row.elig_per_elctbl_chc_id;
    l_elctbl_chc.pl_id                  := ben_epe_cache.g_currcobjepe_row.pl_id;
    l_elctbl_chc.plip_id                := ben_epe_cache.g_currcobjepe_row.plip_id;
    l_elctbl_chc.oipl_id                := ben_epe_cache.g_currcobjepe_row.oipl_id;
    l_elctbl_chc.elctbl_flag            := ben_epe_cache.g_currcobjepe_row.elctbl_flag;
    l_elctbl_chc.per_in_ler_id          := ben_epe_cache.g_currcobjepe_row.per_in_ler_id;
    l_elctbl_chc.business_group_id      := ben_epe_cache.g_currcobjepe_row.business_group_id;
    l_elctbl_chc.object_version_number  := ben_epe_cache.g_currcobjepe_row.object_version_number;
    --
  else
    --
    return;
    --
  end if;
  --
/*
  open c_elctbl_chc;
  --
  fetch c_elctbl_chc into l_elctbl_chc;
  if c_elctbl_chc%notfound then
    --
    -- If no choice found, no need to go ahead, just return back.
    --
    close c_elctbl_chc;
    return;
    --
  else
    --
    close c_elctbl_chc;
    --
  end if;
  --
*/
  l_elctbl_flag := l_elctbl_chc.elctbl_flag;
  --
  -- Does this life event support dependent changes?
  --
    open c_per_in_ler;
      --
      fetch c_per_in_ler into l_per_in_ler;
      --
      if c_per_in_ler%notfound then
        --
        close c_per_in_ler;
        fnd_message.set_name('BEN','BEN_91473_PER_NOT_FOUND');
        fnd_message.set_token('PROC',l_proc);
        fnd_message.set_token('PER_IN_LER_ID',
                             to_char(l_elctbl_chc.per_in_ler_id));
        fnd_message.raise_error;
        --
      end if;
      --
    close c_per_in_ler;
    --
  hr_utility.set_location ('Updating electable choice '||l_proc,80);
  hr_utility.set_location ('g_Process_flag '||g_upd_epe_egd_rec.g_process_flag,80);
  --
  if g_upd_epe_egd_rec.g_process_flag <> 'Y' then
    --
    hr_utility.set_location ('l_elctbl_flag '||l_elctbl_flag,40);
    hr_utility.set_location ('pl_id '||l_elctbl_chc.pl_id,50);
    hr_utility.set_location ('oipl_id '||l_elctbl_chc.oipl_id,50);
    -- Also must update g_code
    --  p_allws_dpnt_dsgn_flag will go away and be replaced by
    --  1.  Designation code     => g_code
    --  2.  LER chg dep cd       => g_ler_chg_dpnt_cvg_cd
    --  3.  Allows dep cvg flag  => g_process_flag
    --
    -- Update the allows_dpnt_dsgn_flag to 'N'
    --
    hr_utility.set_location ('BEEPEAPI_UPD '||l_proc,80);
    ben_elig_per_elc_chc_api.update_perf_elig_per_elc_chc
      (p_elig_per_elctbl_chc_id  => l_elctbl_chc.elig_per_elctbl_chc_id,
       p_alws_dpnt_dsgn_flag     => 'N',
       p_object_version_number   => l_elctbl_chc.object_version_number,
       p_effective_date          => p_effective_date,
       p_dpnt_dsgn_cd            => g_upd_epe_egd_rec.g_code,
       p_ler_chg_dpnt_cvg_cd     => g_upd_epe_egd_rec.g_ler_chg_dpnt_cvg_cd,
       p_program_application_id  => fnd_global.prog_appl_id,
       p_program_id              => fnd_global.conc_program_id,
       p_request_id              => fnd_global.conc_request_id,
       p_program_update_date     => l_sysdate,
       p_dpnt_cvg_strt_dt_cd     => g_upd_epe_egd_rec.g_cvg_strt_cd ,
       p_dpnt_cvg_strt_dt_rl     => g_upd_epe_egd_rec.g_cvg_strt_rl );
    hr_utility.set_location ('Dn BEEPEAPI_UPD '||l_proc,80);
    --
  else
    --
    -- Update the allows_dpnt_dsgn_flag
    --
    -- Not sure at this time if we should be storing
    -- Codes, dates, rules, or other codes
    -- Now writing dsgn_cd and cvg_cd
    --
    hr_utility.set_location ('BEEPEAPI_UPD 1 '||l_proc,80);
    ben_elig_per_elc_chc_api.update_perf_elig_per_elc_chc
      (p_elig_per_elctbl_chc_id  => l_elctbl_chc.elig_per_elctbl_chc_id,
       p_alws_dpnt_dsgn_flag     => 'Y',
       p_object_version_number   => l_elctbl_chc.object_version_number,
       p_effective_date          => p_effective_date,
       p_dpnt_dsgn_cd            => g_upd_epe_egd_rec.g_code,
       p_ler_chg_dpnt_cvg_cd     => g_upd_epe_egd_rec.g_ler_chg_dpnt_cvg_cd,
       p_program_application_id  => fnd_global.prog_appl_id,
       p_program_id              => fnd_global.conc_program_id,
       p_request_id              => fnd_global.conc_request_id,
       p_program_update_date     => l_sysdate,
       p_dpnt_cvg_strt_dt_cd     => g_upd_epe_egd_rec.g_cvg_strt_cd ,
       p_dpnt_cvg_strt_dt_rl     => g_upd_epe_egd_rec.g_cvg_strt_rl );
     --
     hr_utility.set_location ('Dn BEEPEAPI_UPD 1 '||l_proc,80);
  end if;
  if g_upd_epe_egd_rec.g_process_flag = 'Y' or g_mnanrd_condition then
     hr_utility.set_location ('BEEGDAPI_UPD Loop '||l_proc,80);
     --
     -- Now update all the elig dpnt rows with epe id.
     --
     if nvl(g_egd_table.last, 0) > 0 then
        for  l_curr_count in g_egd_table.first..g_egd_table.last
        loop
          hr_utility.set_location ('St BEEGDAPI_UPD loop '||l_proc,80);
          --
          -- Update the egd row with electable choice id.
          --
          ben_elig_dpnt_api.update_perf_elig_dpnt
             (p_elig_dpnt_id           => g_egd_table(l_curr_count).elig_dpnt_id,
              p_per_in_ler_id          => l_elctbl_chc.per_in_ler_id,
              p_elig_per_elctbl_chc_id => l_elctbl_chc.elig_per_elctbl_chc_id,
              p_object_version_number  =>
                               g_egd_table(l_curr_count).object_version_number,
              p_effective_date         => p_effective_date,
              p_program_update_date    => l_sysdate);
          hr_utility.set_location ('End BEEGDAPI_UPD loop '||l_proc,80);
          --
        end loop;
        --
        hr_utility.set_location ('Dn BEEGDAPI_UPD Loop '||l_proc,80);
     end if;

  end if;
  --
  if g_debug then
    hr_utility.set_location ('Leaving '||l_proc,80);
  end if;
end;
END;

/
