--------------------------------------------------------
--  DDL for Package Body BEN_DETERMINE_RATE_CHG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_DETERMINE_RATE_CHG" as
/* $Header: benrtchg.pkb 120.12.12010000.8 2010/01/15 10:18:45 krupani ship $ */

--------------------------------------------------------------------------------
/*
+==============================================================================+
|           Copyright (c) 1997 Oracle Corporation                  |
|              Redwood Shores, California, USA                     |
|                   All rights reserved.                           |
+==============================================================================+
Name:
    Determine rate/benefit changes.
Purpose:
    This process determines what rate, benefit amount, or actual premiums have
    changed and updates corresponding data

History:
    Date             Who        Version    What?
    ----             ---        -------    -----
    25 Oct 98        T Guy       115.0     Created.
    22 Dec 98        T Guy       115.1     Added enrt_mthd_cd to call for
                                           ben_election_information.
                                           election_rate_information
    28 Dec 98        j lamoureux 115.2     Removed parameters
                                                dflt_enrt_dt,
                                                enrt_typ_cycl_cd,
                                                enrt_perd_strt_dt,
                                                enrt_perd_end_dt
                                           in call to elig_per_elctbl_chc api
    11 Jan 99        T Guy       115.3     added elctbl_chc_id to call for
                                           ben_determine_rates.main
    16 Feb 99        T Guy       115.4     added comp level cd check for
                                           planfc and planimp
    09 Mar 99        G Perry     115.6     IS to AS.
    16 Apr 99        T Guy       115.7     Removed call to create new
                                           elctbl_chc.  Bendenrr now creates
                                           a choice for currently enrolled
                                           and sets elctbl_flag to N.  Also
                                           removed calls to determince coverage
                                           and determine rates.  These will
                                           be already run during the normal
                                           benmngle run.
    29 Apr 99        lmcdonal     115.8    prtt_rt_val and prtt_enrt_rslt have
                                           status codes now.
    30 Jun 99        T Guy        115.9    Added total premium check
    07 Jul 99        jcarpent     115.10   Added per_in_ler_id to call to
                                           update_prtt_prem_f
    09 Jul 99        jcarpent     115.11   Added checks for backed out nocopy pil
    20-JUL-99        Gperry       115.12   genutils -> benutils package
                                           rename.
    14-SEP-99        shdas        115.13   added bnft_val to election_information
    28-SEP-99        tguy         115.14   set global flag so that benmngle will
                                           will close per_in_ler's with the others
                                           being processed.  This allows us to
                                           avoid duplication and throughing off
                                           counts for reporting purposes.
    18-NOV-99        gperry       115.15   Corrected error messages.
    30-Dec-99        maagrawa     115.16   Bug 3431 (1096820) fixed.
                                           Major re-structuring of package.
                                           Added parameter business_group_id.
    20-Jan-00        thayden      115.17   Get any per_in_ler_id, not just STRTD.
    02-Feb-00        lmcdonal     115.18   Re-compute certain premiums before
                                           updating the prtt-prem row.
    18-Feb-00        jcarpent     115.19   Remove 115.14 change to set the
                                           g_electable_choice_created flag
                                           this is already done in bendenrr.
                                           Bug 4720 (no wwbug number)
    01-Mar-00        jcarpent     115.20   Pass bnft_amt_changed flag to
                                           ben_election_rate_info.  Put in
                                           payroll change checks.
    31-Mar-00        mmogel       115.21   I changed the message number from
                                           91382 to 91832 in the message name
                                           BEN_91382_PACKAGE_PARAM_NULL
    14-May-00        gperry       115.22   Fixed bug 1298556. Rates get created
                                           if activity changes and rate does
                                           not.
    25-May-00        lmcdonal     115.23   Bug 1312906 leap-froged from 115.21
                                           for aera.
                                           call imputed income if benefit
                                           changes on subj-to-imp plan.
    25-May-00        lmcdonal     115.24   Bug 1312906 'real' version.
    29-May-00        gperry       115.25   Corrected cursor for bug 1298556.
    05-Jan-01        kmahendr     115.26   Added parameter per_in_ler_id
    16-Jan-01        mhoyes       115.27   EFC stuff. Added new OUT NOCOPY parameter
                                           to election_rate_information.
    19-feb-01        tilak        115.28   flex credit amout changes is not affecting
                                           on next enrollment. cursor c_flex and c_bpl
                                           is creatd to update the ledger
    15-Mar-01       kmahendr      115.29   Modified cursor c_flex and c_bpl and added call
                                           total_pools to write prtt_rt_val for flex credit
                                           Bug#1653733
    26 Jun 01       ikasire       115.30   bug 1849019   added two new procedures
                                           prv_delete and get_rate_codes to
                                           handle ENTRBL rate start date codes.
    17 Aug 01       kmahendr      115.31   Added parameter p_mode to prv_delete and modified
                                           codes
    22 Aug 01       kmahendr      115.32   Made changes to prv_delete procedure for future dated
                                           rates
    10 Sep 01       kmahendr      115.33   Bug#1969043 - Imputed Income compute procedure is
                                           added
    25 Sep 01       kmahendr      115.34   Added parameter p_mode to main and added condition
                                           'R' to look for enrollment result
    26 Nov 01       dschwart/     115.35   Bug#1646442: fixed invalid date use (was using date
                    BBurns                 benmngle run, not event date).
    19 Mar 02       kmahendr      115.36   Bug#2273129 - cursor c_bpl is changed to return
                                           row only for prvdd_val and total_pools procedure
                                           is called to write flex credit rate if bnft_amt
                                           is changed.
    19 Mar 02       kmahendr      115.37   Added dbdrv lines.
    30 Apr 02       kmahendr      115.38   Added token to message 91832.
    06 May 02       kmahendr      115.39   Bug#2359835 - fix made for bug#2273129 broke for
                                           non-flex programs - before calling total_pools
                                           program type is checked.
    08-Jun-02       pabodla       115.40   Do not select the contingent worker
                                           assignment when assignment data is
                                           fetched.
    08-Aug-02       kmahendr      115.41   Bug#2382651 - added pgm_id to total_pools call.
    19-Sep-02       mmudigon      115.42   Bug#2505008 - pass l_eff_dt instead of
                                           p_eff_dt while calling imputed_income
    19-Sep-02       ikasire       115.43   Bug 2551834 we need use nvl for l_ecr.val
                                           while calling election_information
                                           to compute rate changes.
    28-Oct-02       kmahendr      115.44   Bug#2648512 - Effective date is modified according to the
                                           date of election in imputed income.
    11-dec-2002     hmani 	  115.45	NoCopy changes
    21-Feb-2003     kmahendr      115.46   Bug#2776740 - added call - end_prtt_rt_val
    25-Feb-2003     ikasire       115.47   Bug 2789814 fixes for future enrollment results
                                           from the previous life events
    04-Apr-2003     pbodla        115.48   Bug 2841161 : Copy DFF segments if the
                                           benefit amount changes and new enrollment is created.
    23-Apr-2003     kmahendr      115.49   New function Determine_change_in_flex added - bug#290823
    28-May-2003     kmahendr      115.50   Added codes for canon fix.
    04-Jun-2003     kmahendr      115.51   Added a cursor c_entr_val and not to consider rates
                                           with enter value at enrollment.Bug#2959410
    07-Aug-2003     iaksire       115.52   Bug 3044116 Added code to handle the cases like
                                           LE after Old LE date and before old le effective
                                           date. We need to use enrt_perd_start_dt plus 1
                                           to avoid the issue of correction.
    13-Aug-2003     kmahendr      115.53   Added codes for Cvg_mlf_cd - ERL
    01-Oct-2003     mmudigon      115.54   Bug 2775742. Update rates for rt chg
                                           process when element/input attached
                                           to abr is changed.
    26-Oct-2003     mmudigon      115.55   Bug 2775742. changed <> to = line 937
    30-Oct-2003     ikasire       115.56   Bug 3192923 Override Thru date needs to be
                                           handled to coverage and rates.
    11-nov-2003     nhunur        115.57   changed '= to in' in determine_change_in_flex
    20-Jan-2004     kmahendr      115.58   Bug#3378865 - added ele_entry_val_cd check for
                                           calling election_rate_information
    22-Jan-2004     kmahendr      115.59   Bug#3395033 - added codes to call total_pools
                                           to recompute flex credits
    28-Jan-2004     ikasire       115.60   Bug 3394862 When rate is enter value at
                                           enrollment, recalc is not being processed for
                                           payroll changes. on fp.F it computes but with
                                           null values for the rates.
    16-Feb-2004     mmudigon      115.61   Bug 3437083. Logic to determine abr
                                           assignment changes
    05-Apr-2004     kmahendr      115.62   Bug#3554751 - cursor c_ppe modified to look
                                           for per_in_ler_stat_cd
    07-Apr-2004     tjesumic      115.63   fonm parameter added
    14-Apr-2004     mmudigon      115.64   Additional FONM changes
    08-Jul-2004     kmahendr      115.65   Bug#3739641 - modified c_ecr cursors
    27-Jul-2004     mmudigon      115.66   Bug 3797946. Logic to determine
                                           change in extra input values
    11-jan-2005     kmahendr      115.67   Bug#4113295 - the change is not compared for SAREC rates
    10-feb-2005     mmudigon      115.68   Bug 4157759. Modified cursor c_prv
                                           and added a new cursor c_prv_min_dt
    17-Mar-2005     kmahendr      115.69   Bug#3856424 - Modified cursor c_pen
    30-Aug-2005     kmahendr      115.70   Bug#4481319 - effective date is
                                           assigned enrt_perd_start_date
    03-Nov-2005     abparekh      115.71   Bug 4715688 - Added cases to detect coverage change
    10-Nov-2005     abparekh      115.72   Bug 4723828 - Added cases to detect coverage change
    09-Nov-2005     ikasire       115.73   Bug 4715657 recalc doesnot work if rate start date code
                                           is a rule
    09-Nov-2005     kmahendr      115.74   Bug#4872115 - regression of fix made in version
                                           71 and  72
    05-Jan-2006     abparekh      115.75   Bug 4895872 - Nullify all member variables of L_ENB
                                                         if C_ENB not found
    09-Jan-2006     kmahendr      115.76   Bug#4938930 - added mlt_cd condition
                                           to cursor c_enb
    05-Apr-2006     abparekh      115.77   Bug 5126800 : SAAEAR case added to detect change
                                                         in benefit amount during Recalculate Run
    08-sep-2006     ssarkar       115.78   Bug 5507982 - initialise variable element_changed to false
                                                         for each epe .
    24-oct-2006     ikasired      115.79   Bug 5617091 - need to exclude interim enrollments from
                                           being pickedup for rate change processing
    30-Jan-2007     rgajula       115.80   Bug 5768795 - Added call to PEN_API.chk_arcs_breach in main
                                                         for each of the pgm_id's in the enrollment results.
    18-jun-2007     rtagarra      115.81   Bug 6133258 - Made fix 5768795 compatible for numeric overflow error

    13-Feb-2008     rtagarra      115.82   Bug 6528302 - Fixed cursor c_element_info.

    22-Feb-2008     rtagarra      115.83   Bug 6840074
    23-Apr-08       sallumwa      115.84   Reverted back the changes made for the Bug : 6528302
    21-Oct-08       krupani       115.85   Bug 7414466 - Update the rates if communicated amount
                                                         or annual amount changes
    27-Jan-09       krupani       115.86   Bug 7566569 - Non-recurring element should not be
                                           recreated while running Recalculate Participant Values
    24-Aug-09       krupani       115.87   Bug 8623254 - While calling ben_element_entry.get_extra_ele_inputs,
                                           opt_id was passed null. Now passing the opt_id for extra input FF evaluation
    15-Jan-10       krupani       115.88   Bug 9286869 - Introduced profile option BEN: Create Non Recurring Entries.
                                           If the profile option is set to Yes, then non-recurring entries will be recreated
                                           while running Recalculate Participant Values program.
*/

----------------------------------------------------------------------------------------------------
--
g_package varchar2(80) := 'ben_determine_rate_chg';
--
PROCEDURE main
     (p_effective_date         in date,
      p_lf_evt_ocrd_dt         in date,
      p_business_group_id      in number,
      p_person_id              in number,
--    added per_in_ler_id for unrestricted enhancement
      p_per_in_ler_id          in number,
      p_mode                   in varchar2) IS
   --
   l_package        varchar2(80) := g_package||'.main ';
   l_object_version_number number;
   l_prtt_rt_val_id number;
   l_dummy_number number;
   l_dummy_date date;
   l_dummy_bool boolean;
   l_dummy_char varchar(30);
   l_prtt_enrt_rslt_id number;
   l_period_type    varchar2(30);
   --
   /* Start of Changes for WWBUG: 1646442: added following block of local variables */
   --
   l_ppe_dt_to_use  date;
   l_correction               boolean;
   l_update                   boolean;
   l_update_override          boolean;
   l_update_change_insert     boolean;
   l_ppe_datetrack_mode        varchar2(30);
   l_enrt_cvg_strt_dt      date;
   l_enrt_cvg_strt_dt_cd   varchar2(30);
   l_enrt_cvg_strt_dt_rl   number;
   l_rt_strt_dt_cd         varchar2(30);
   l_rt_strt_dt_rl         number;
   l_enrt_cvg_end_dt       date;
   l_enrt_cvg_end_dt_cd    varchar2(30);
   l_enrt_cvg_end_dt_rl    number;
   l_rt_end_dt             date;
   l_rt_end_dt_cd          varchar2(30);
   l_rt_end_dt_rl          number;
   /* End of Changes for WWBUG: 1646442                                         */
   --
   l_rt_end_dt_non_rec       date;             -- Bug 7566569
   l_recurring_rt            boolean := true;  -- Bug 7566569
   l_chk_non_rec_entry       varchar2(30);     -- Bug 9286869

   l_pen_found      boolean := false;
   l_enb_found      boolean := false;
   l_prv_found      boolean := false;
   l_ppe_found      boolean := false;
   l_bnft_changed   boolean := false;
   l_imp_changed    boolean := false;
   --
   l_effective_date              date := least(p_effective_date,
                                                nvl(p_lf_evt_ocrd_dt,p_effective_date));
   l_new_assignment_id           number;
   l_new_organization_id         number;
   l_new_payroll_id              number;
   --
   cursor c_pil is
     select pil.per_in_ler_id, pil.lf_evt_ocrd_dt, pil.ler_id
     from   ben_per_in_ler pil
     where  pil.person_id = p_person_id
--   added per_in_ler_id for unrestricted enhancement
      and   pil.per_in_ler_id = p_per_in_ler_id
      and   pil.lf_evt_ocrd_dt = p_lf_evt_ocrd_dt;
   l_pil c_pil%rowtype;
   --
   cursor c_epe(l_per_in_ler_id number) is
     select epe.elig_per_elctbl_chc_id,
            epe.elctbl_flag,
            epe.prtt_enrt_rslt_id,
            pel.acty_ref_perd_cd,
            epe.pl_id,
            epe.oipl_id,
            epe.pil_elctbl_chc_popl_id,
            epe.fonm_cvg_strt_dt,
            pel.enrt_perd_id,
            pel.lee_rsn_id,
            pel.enrt_perd_strt_dt
     from   ben_elig_per_elctbl_chc epe,
            ben_pil_elctbl_chc_popl pel
     where  epe.per_in_ler_id          = l_per_in_ler_id
     and    epe.pil_elctbl_chc_popl_id = pel.pil_elctbl_chc_popl_id
     and    epe.per_in_ler_id          = pel.per_in_ler_id
     and    epe.comp_lvl_cd not in ('PLANFC', 'PLANIMP');
   --
    cursor c_epe2(l_per_in_ler_id number) is
     select epe.elig_per_elctbl_chc_id,
            epe.elctbl_flag,
            epe.prtt_enrt_rslt_id,
            pel.acty_ref_perd_cd,
            epe.pl_id,
            epe.oipl_id,
            epe.pil_elctbl_chc_popl_id,
            epe.fonm_cvg_strt_dt,
            pel.enrt_perd_id,
            pel.lee_rsn_id,
            pel.enrt_perd_strt_dt
     from   ben_elig_per_elctbl_chc epe,
            ben_pil_elctbl_chc_popl pel
     where  epe.per_in_ler_id          = l_per_in_ler_id
     and    epe.pil_elctbl_chc_popl_id = pel.pil_elctbl_chc_popl_id
     and    epe.per_in_ler_id          = pel.per_in_ler_id
     and    epe.comp_lvl_cd not in ('PLANFC', 'PLANIMP')
     and    (exists (select null from ben_enrt_rt ecr
                    where ecr.elig_per_elctbl_chc_id = epe.elig_per_elctbl_chc_id
                    and   ecr.rt_mlt_cd = 'ERL') or exists (
                    select null from ben_enrt_rt ecr, ben_enrt_bnft enb
                    where enb.elig_per_elctbl_chc_id = epe.elig_per_elctbl_chc_id
                    and   ecr.enrt_bnft_id = enb.enrt_bnft_id
                    and   ecr.rt_mlt_cd = 'ERL'));

    cursor c_epe3(l_per_in_ler_id number) is
     select epe.elig_per_elctbl_chc_id,
            epe.elctbl_flag,
            epe.prtt_enrt_rslt_id,
            pel.acty_ref_perd_cd,
            epe.pl_id,
            epe.oipl_id,
            epe.pil_elctbl_chc_popl_id,
            epe.fonm_cvg_strt_dt,
            pel.enrt_perd_id,
            pel.lee_rsn_id,
            pel.enrt_perd_strt_dt
     from   ben_elig_per_elctbl_chc epe,
            ben_pil_elctbl_chc_popl pel
     where  epe.per_in_ler_id          = l_per_in_ler_id
     and    epe.pil_elctbl_chc_popl_id = pel.pil_elctbl_chc_popl_id
     and    epe.per_in_ler_id          = pel.per_in_ler_id
     and    epe.comp_lvl_cd not in ('PLANFC', 'PLANIMP')
     and    (exists (select null from ben_enrt_bnft enb
                    where enb.elig_per_elctbl_chc_id = epe.elig_per_elctbl_chc_id
                    and   enb.cvg_mlt_cd = 'ERL')
                    );
   --
   l_epe c_epe%rowtype;
   --BUG 3192923 If the life event passed the override thru date we
   --need to process the enrollments and rates.
   --If there is no override thru date we can never override the enrollment
   --
   cursor c_pen is
      select pen.prtt_enrt_rslt_id,
             pen.enrt_mthd_cd,
             pen.pl_id,
             pen.pgm_id,
             pen.pl_typ_id,
             pen.oipl_id,
             pen.ler_id,
             pen.enrt_cvg_strt_dt,
             pen.bnft_amt,
             pen.object_version_number,
             pen.person_id,
             pen.business_group_id,
             pen.per_in_ler_id,
             -- Added for bug 2841161
             pen.pen_attribute_category,
             pen.pen_attribute1,
             pen.pen_attribute2,
             pen.pen_attribute3,
             pen.pen_attribute4,
             pen.pen_attribute5,
             pen.pen_attribute6,
             pen.pen_attribute7,
             pen.pen_attribute8,
             pen.pen_attribute9,
             pen.pen_attribute10,
             pen.pen_attribute11,
             pen.pen_attribute12,
             pen.pen_attribute13,
             pen.pen_attribute14,
             pen.pen_attribute15,
             pen.pen_attribute16,
             pen.pen_attribute17,
             pen.pen_attribute18,
             pen.pen_attribute19,
             pen.pen_attribute20,
             pen.pen_attribute21,
             pen.pen_attribute22,
             pen.pen_attribute23,
             pen.pen_attribute24,
             pen.pen_attribute25,
             pen.pen_attribute26,
             pen.pen_attribute27,
             pen.pen_attribute28,
             pen.pen_attribute29,
             pen.pen_attribute30
      from   ben_prtt_enrt_rslt_f pen
      where  pen.prtt_enrt_rslt_id = l_epe.prtt_enrt_rslt_id
      and    pen.person_id = p_person_id
      and    pen.sspndd_flag = 'N'
      and    ( (pen.enrt_ovridn_flag = 'N' ) OR
               (pen.enrt_ovridn_flag = 'Y' and nvl(pen.enrt_ovrid_thru_dt,hr_api.g_eot) < l_effective_date ))
      and    pen.enrt_cvg_thru_dt = hr_api.g_eot
      and    pen.prtt_enrt_rslt_stat_cd is null
      and    l_effective_date -- Bug 3044116 p_effective_date
             between pen.effective_start_date and pen.effective_end_date
      --bug#3856424 - check for any deenrollment in future - defensive coding
      and exists (select null from ben_prtt_enrt_rslt_f pen2
                  where pen2.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
                  and   pen2.enrt_cvg_thru_dt = hr_api.g_eot
                  and   pen2.effective_end_date =  hr_api.g_eot)
      and not exists ( select 'x' from ben_prtt_enrt_rslt_f pen3  --Bug 5617091 exclude interim results
                        where pen3.rplcs_sspndd_rslt_id= pen.prtt_enrt_rslt_id
                          and pen3.sspndd_flag = 'Y'
                          and pen3.prtt_enrt_rslt_stat_cd is null
                          and pen3.enrt_cvg_thru_dt = hr_api.g_eot
                          and pen3.effective_end_date =  hr_api.g_eot)
      ;
   --
   l_pen  c_pen%rowtype;
   --
   -- Bug 4715688 : The cursor is used to get the coverage amount. Now even if the person is not enrolled
   --               we need to fetch the coverage amount to ascertain if coverage exists. Hence added
   --               clause enb.prtt_enrt_rslt_id is null in following cursor
   --
   cursor c_enb is
      select enb.val,
             enb.enrt_bnft_id,
             enb.prtt_enrt_rslt_id,
             enb.entr_val_at_enrt_flag,
             enb.CVG_MLT_CD
      from   ben_enrt_bnft enb
      where  enb.elig_per_elctbl_chc_id = l_epe.elig_per_elctbl_chc_id
        and  ( enb.prtt_enrt_rslt_id      = l_epe.prtt_enrt_rslt_id    OR
               (enb.prtt_enrt_rslt_id is null      /* Bug 4715688 */
                and enb.cvg_mlt_cd not like '%RNG')--bug#4938930
              );
   --
   l_enb   c_enb%rowtype;
   --
   cursor c_ecr(v_elig_per_elctbl_chc_id in number,
                v_enrt_bnft_id           in number) is
   select nvl(ecr.val,ecr.dflt_val) val,
          ecr.enrt_rt_id,
          nvl(ecr.ann_val,ecr.ann_dflt_val) ann_val,
          ecr.acty_base_rt_id,
          ecr.acty_typ_cd,
          ecr.tx_typ_cd,
          ecr.rt_strt_dt_cd,
          ecr.rt_strt_dt,
          ecr.ENTR_VAL_AT_ENRT_FLAG,
          ecr.rt_mlt_cd,
          nvl(ecr.cmcd_val,ecr.cmcd_dflt_val) cmcd_val  /* bug 7414466 */
     from ben_enrt_rt  ecr
    where ecr.elig_per_elctbl_chc_id = v_elig_per_elctbl_chc_id
      and ecr.business_group_id    = p_business_group_id
      -- added for canon fix
      and ecr.rt_mlt_cd <> 'ERL'
      and ecr.ASN_ON_ENRT_FLAG = 'Y'
    UNION
   select nvl(ecr.val,ecr.dflt_val) val,
          ecr.enrt_rt_id,
          nvl(ecr.ann_val,ecr.ann_dflt_val) ann_val,
          ecr.acty_base_rt_id,
          ecr.acty_typ_cd,
          ecr.tx_typ_cd,
          ecr.rt_strt_dt_cd,
          ecr.rt_strt_dt,
          ecr.ENTR_VAL_AT_ENRT_FLAG,
          ecr.rt_mlt_cd,
          nvl(ecr.cmcd_val,ecr.cmcd_dflt_val) cmcd_val  /* bug 7414466 */
     from ben_enrt_rt    ecr
    where ecr.enrt_bnft_id           = v_enrt_bnft_id
      and ecr.business_group_id    = p_business_group_id
       -- added for canon fix
      and ecr.rt_mlt_cd <> 'ERL'
      and ecr.ASN_ON_ENRT_FLAG = 'Y';
   --
   l_ecr_row         c_ecr%rowtype;
   --
   cursor c_entr_val (p_acty_base_rt_id number
                     ,p_effective_date date) is
     select 'Y'
     from dual
     where exists (select null
                   from ben_acty_base_rt_f abr
                   where abr.PARNT_ACTY_BASE_RT_ID = p_acty_base_rt_id
                   and   abr.PARNT_CHLD_CD = 'CHLD'
                   and   abr.entr_val_at_enrt_flag = 'Y'
                   and   abr.ACTY_BASE_RT_STAT_CD = 'A'
                   and   p_effective_date between
                         abr.effective_start_date and abr.effective_end_date)
     or    exists (select null
                   from ben_acty_base_rt_f abr1,
                        ben_acty_base_rt_f abr2
                   where abr1.acty_base_rt_id = p_acty_base_rt_id
                   and   abr1.PARNT_CHLD_CD = 'CHLD'
                   and   abr1.PARNT_ACTY_BASE_RT_ID = abr2.acty_base_rt_id
                   and   abr2.entr_val_at_enrt_flag = 'Y'
                   and   abr2.ACTY_BASE_RT_STAT_CD = 'A'
                   and   p_effective_date between
                         abr1.effective_start_date and abr1.effective_end_date
                   and    p_effective_date between
                         abr2.effective_start_date and abr2.effective_end_date);
   -- added for canon fix
    cursor c_ecr2(v_elig_per_elctbl_chc_id in number,
                v_enrt_bnft_id           in number) is
     select nvl(ecr.val,ecr.dflt_val) val,
          ecr.enrt_rt_id,
          nvl(ecr.ann_val,ecr.ann_dflt_val) ann_val,
          ecr.acty_base_rt_id,
          ecr.acty_typ_cd,
          ecr.tx_typ_cd,
          ecr.rt_strt_dt_cd,
          ecr.rt_strt_dt
     from ben_enrt_rt  ecr
    where ecr.elig_per_elctbl_chc_id = v_elig_per_elctbl_chc_id
      and ecr.business_group_id    = p_business_group_id
      -- added for canon fix
      and ecr.rt_mlt_cd = 'ERL'
      and ecr.ASN_ON_ENRT_FLAG = 'Y'
    UNION
     select nvl(ecr.val,ecr.dflt_val) val,
          ecr.enrt_rt_id,
          nvl(ecr.ann_val,ecr.ann_dflt_val) val,
          ecr.acty_base_rt_id,
          ecr.acty_typ_cd,
          ecr.tx_typ_cd,
          ecr.rt_strt_dt_cd,
          ecr.rt_strt_dt
     from ben_enrt_rt    ecr
      where ecr.enrt_bnft_id       = v_enrt_bnft_id
      and ecr.business_group_id    = p_business_group_id
       -- added for canon fix
      and ecr.rt_mlt_cd = 'ERL'
      and ecr.ASN_ON_ENRT_FLAG = 'Y';
   --
   --BUG 3192923 If the life event passed the override thru date we
   --need to process the enrollments and rates.
   --If there is no override thru date we can never override the enrollment
   --
   --
   cursor c_prv(v_acty_base_rt_id number,
                v_rt_strt_dt      date) is
      select prv.prtt_rt_val_id,
             prv.rt_val,
             prv.rt_strt_dt,
             prv.elctns_made_dt,
             prv.acty_typ_cd,
             prv.tx_typ_cd,
             prv.element_entry_value_id,
             prv.rt_ovridn_flag,
             prv.rt_ovridn_thru_dt,
             prv.ann_rt_val,
             prv.cmcd_rt_val
      from   ben_prtt_rt_val prv
      where  prv.prtt_enrt_rslt_id = l_pen.prtt_enrt_rslt_id
      and    prv.acty_base_rt_id   = v_acty_base_rt_id
      and    ((v_rt_strt_dt is not null and
                v_rt_strt_dt between prv.rt_strt_dt and prv.rt_end_dt) or
               (v_rt_strt_dt is null and
                prv.rt_end_dt         = hr_api.g_eot))
      and    prv.prtt_rt_val_stat_cd is null;
   --
   l_prv  c_prv%rowtype;
   --
   cursor c_prv_min_dt(p_pen_id   number,
                       p_abr_id   number) is
   select min(prv.rt_strt_dt)
     from ben_prtt_rt_val prv
    where prv.prtt_enrt_rslt_id = p_pen_id
      and prv.acty_base_rt_id   = p_abr_id
      and prv.prtt_rt_val_stat_cd is null;

   cursor c_epr(v_elig_per_elctbl_chc_id in number,
                v_enrt_bnft_id           in number) is
   select epr.val,
          epr.enrt_prem_id,
          epr.actl_prem_id
     from ben_enrt_prem  epr
    where epr.elig_per_elctbl_chc_id = v_elig_per_elctbl_chc_id
      and epr.business_group_id    = p_business_group_id
    UNION
   select epr.val,
          epr.enrt_prem_id,
          epr.actl_prem_id
     from ben_enrt_prem    epr
    where epr.enrt_bnft_id           = v_enrt_bnft_id
      and epr.business_group_id    = p_business_group_id;
   --
   cursor c_ppe(v_actl_prem_id number
     /* Start of Changes for WWBUG: 1646442  added following line       */
               ,p_ppe_dt_to_use date)
     /* End of Changes for WWBUG: 1646442                               */
   is
     select ppe.prtt_prem_id,
             ppe.std_prem_val,
             ppe.std_prem_uom,
             ppe.object_version_number
      from   ben_prtt_prem_f ppe,
             ben_per_in_ler pil
      where  ppe.prtt_enrt_rslt_id = l_pen.prtt_enrt_rslt_id
      and    ppe.actl_prem_id      = v_actl_prem_id
      and    ppe.per_in_ler_id = pil.per_in_ler_id
      and    pil.per_in_ler_stat_cd not in ('BCKDT','VOIDD')
      and    ppe.business_group_id = p_business_group_id
      /*
         CODE PRIOR TO WWBUG: 1646442
      and p_effective_date between
      */
      /* Start of Changes for WWBUG: 1646442                    */
      and    p_ppe_dt_to_use between
      /* End of Changes for WWBUG: 1646442                      */
             ppe.effective_start_date and ppe.effective_end_date;

   --
   l_ppe  c_ppe%rowtype;
   --
   cursor c_payroll_type_changed(
            cp_person_id number,
            cp_business_group_id number,
            cp_effective_date date,
            cp_orig_effective_date date
   ) is
   select pay.period_type
   from   per_all_assignments_f asg,
          pay_payrolls_f pay,
          per_all_assignments_f asg2,
          pay_payrolls_f pay2
   where  asg.person_id = cp_person_id
      and   asg.assignment_type <> 'C'
      and asg.business_group_id = cp_business_group_id
      and asg.primary_flag = 'Y'
      and cp_effective_date between
          asg.effective_start_date and asg.effective_end_date
      and pay.payroll_id=asg.payroll_id
      and pay.business_group_id = asg.business_group_id
      and cp_effective_date between
          pay.effective_start_date and pay.effective_end_date
      and asg2.person_id = cp_person_id
      and   asg2.assignment_type <> 'C'
      and asg2.business_group_id = cp_business_group_id
      and asg2.primary_flag = 'Y'
      and cp_orig_effective_date between
          asg2.effective_start_date and asg2.effective_end_date
      and pay2.payroll_id=asg2.payroll_id
      and pay2.business_group_id = asg2.business_group_id
      and cp_orig_effective_date between
          pay2.effective_start_date and pay2.effective_end_date
      and pay2.period_type<>pay.period_type
      and asg.assignment_type = asg2.assignment_type ;

   cursor c_pl(p_pl_id number,p_eff_dt date) is
      select 'x' from ben_pl_f pl
      where pl.pl_id = p_pl_id
        and pl.SUBJ_TO_IMPTD_INCM_TYP_CD is not null
        and p_eff_dt between
            pl.effective_start_date and pl.effective_end_date;
   l_pl  c_pl%rowtype;

  ---
  --- to find the flex credit place holder choice and rate
  --- flex credit amount is changes is not effecting the ledger
  --- this find the flex credit place holder plan prvdd amount
  --- then the amount will be compared with bnft_prvdd_ldgr row
  --  if a rate cahnge found update the bnft_prvdd_ldgr
   cursor c_flex_choice (p_pgm_id number)  is
    select      epe.bnft_prvdr_pool_id,
                epe.elig_per_elctbl_chc_id,
                epe.prtt_enrt_rslt_id,
                epe.business_group_id,
                epe.per_in_ler_id,
                ecr.enrt_rt_id,
                ecr.acty_base_rt_id,
                nvl(ecr.dflt_val, ecr.val) val
    from        ben_elig_per_elctbl_chc epe1,
                ben_elig_per_elctbl_chc epe,
                ben_enrt_rt ecr
    where       epe1.elig_per_elctbl_chc_id=l_epe.elig_per_elctbl_chc_id  and
                epe1.business_group_id=p_business_group_id and
                epe1.pgm_id = epe.pgm_id and
                epe1.per_in_ler_id = epe.per_in_ler_id and
                epe.bnft_prvdr_pool_id is not null and
                epe.business_group_id=p_business_group_id and
                epe.pgm_id = p_pgm_id and
                ecr.elig_per_elctbl_chc_id = epe.elig_per_elctbl_chc_id and
                ecr.rt_usg_cd = 'FLXCR' and
                ecr.business_group_id = p_business_group_id;

   ---to get the current provdd value

    cursor c_bpl ( c_acty_base_rt_id number ,
                   c_bnft_prvdr_pool_id number ,
                   c_prtt_enrt_rslt_id number) is
    select  prvdd_val
    from ben_bnft_prvdd_ldgr_f bpl,
         ben_per_in_ler pil
    where   bpl.acty_base_rt_id = c_acty_base_rt_id
      and bpl.bnft_prvdr_pool_id = c_bnft_prvdr_pool_id
      and bpl.prtt_enrt_rslt_id = c_prtt_enrt_rslt_id
      and bpl.prvdd_val is not null
      and pil.per_in_ler_id = bpl.per_in_ler_id
      and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
      and bpl.business_group_id = p_business_group_id
      and p_effective_date between
          bpl.effective_start_date and bpl.effective_end_date ;
   --
   /* Start of Changes for WWBUG: 1646442: added cursor and variable */
   cursor c_pel (p_elig_pe_elctbl_chc_id number) is
   select pel.enrt_perd_id,pel.lee_rsn_id
   from ben_pil_elctbl_chc_popl pel
       ,ben_elig_per_elctbl_chc epe
   where pel.pil_elctbl_chc_popl_id = epe.pil_elctbl_chc_popl_id
   and epe.elig_per_elctbl_chc_id = p_elig_pe_elctbl_chc_id;
   --
   l_pelrec     c_pel%rowtype;
   /* End of Changes for WWBUG: 1646442                         */
   --
   --Bug 3044116
    cursor c_prtt_enrt (p_pgm_id number) is
     select epe.prtt_enrt_rslt_id,pel.enrt_perd_strt_dt
     from  ben_pil_elctbl_chc_popl pel,
           ben_elig_per_elctbl_chc epe
     where  pel.per_in_ler_id = p_per_in_ler_id
     and    pel.pil_elctbl_chc_popl_id = epe.pil_elctbl_chc_popl_id
     and    epe.comp_lvl_cd = 'PLANFC'
     and    epe.pgm_id      = p_pgm_id
     and    epe.business_group_id = p_business_group_id;
   --
   cursor  c_pen2 (p_prtt_enrt_rslt_id number) is
     select enrt_mthd_cd
     from   ben_prtt_enrt_rslt_f
     where  prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and    prtt_enrt_rslt_stat_cd is null
     and    l_effective_date -- Bug 3044116 p_effective_date
            between effective_start_date and effective_end_date;
   --
   cursor c_imputed_rslt is
     select effective_start_date
     from   ben_prtt_enrt_rslt_f pen,
            ben_elig_per_elctbl_chc epe
     where  pen.prtt_enrt_rslt_id = epe.prtt_enrt_rslt_id
     and    epe.per_in_ler_id = p_per_in_ler_id
     and    epe.comp_lvl_cd = 'PLANIMP'
     and    epe.business_group_id = p_business_group_id
     and    pen.prtt_enrt_rslt_stat_cd is null
     order by effective_start_date ;
   --
   cursor c_element_info (p_element_entry_value_id number,
                          p_prtt_enrt_rslt_id      number) is
      select elk.element_type_id,
             eev.input_value_id,
             asg.payroll_id,
             pee.element_entry_id,
             pee.assignment_id,
             pee.effective_end_date
      from   per_all_assignments_f asg,
             pay_element_links_f elk,
             pay_element_entries_f pee,
             pay_element_entry_values_f eev
      where  eev.element_entry_value_id = p_element_entry_value_id
      and    eev.element_entry_id = pee.element_entry_id
      and    pee.element_link_id = elk.element_link_id
      and    pee.effective_start_date between elk.effective_start_date
             and elk.effective_end_date
      and    eev.effective_start_date between pee.effective_start_date
             and pee.effective_end_date
      and    pee.creator_type = 'F'
      and    pee.creator_id = p_prtt_enrt_rslt_id
      and    asg.assignment_id = pee.assignment_id
      and    pee.effective_start_date between asg.effective_start_date
      and    asg.effective_end_date
     /*
      and    p_effective_date between asg.effective_start_date
      and    asg.effective_end_date
     */
   order by pee.effective_end_date desc ;
   l_element_info   c_element_info%rowtype;
   --
   cursor c_abr(p_acty_base_rt_id number,
                p_eff_dt          date) is
   select ele_rqd_flag,
          element_type_id,
          input_value_id,
          ele_entry_val_cd,
          input_va_calc_rl,
          effective_start_date,
          effective_end_date
     from ben_acty_base_rt_f
    where acty_base_rt_id = p_acty_base_rt_id
      and p_eff_dt between effective_start_date
      and effective_end_date;
   l_abr c_abr%rowtype;
   l_abr2 c_abr%rowtype;


   l_prvdd_val             ben_bnft_prvdd_ldgr_f.prvdd_Val%type ;
   l_prtt_enrt_rslt_id_shell     number ;
   l_acty_ref_perd_cd            varchar2(80);
   l_acty_base_rt_id             number;
   l_bpp_rt_strt_dt              date;
   l_rt_strt_dt                  date;
   l_rt_val                      number;
   l_element_type_id             number;
   l_enrt_mthd_cd                varchar2(80) := null;
   l_perform_imp                 varchar2(1)  := 'N';
   l_start_date                  date;
   l_entr_val_at_enrt_flag       varchar2(1) := 'N';
   l_element_changed             boolean := FALSE;
   --
   l_enrt_perd_strt_dt           date ;
   l_total_pools_eff_dt          date ;
   l_enb_valrow                 ben_determine_coverage.ENBValType;
   l_flex_call                   boolean := false;
   l_ext_inpval_tab              ben_element_entry.ext_inpval_tab_typ;
   l_inpval_tab                  ben_element_entry.inpval_tab_typ;
   l_jurisdiction_code           varchar2(30);
   l_subpriority                 number;
   l_ext_inp_changed             boolean;
   l_prv_min_strt_dt             date;

--Bug 6133258
/*--Start Bug 5768795
   TYPE pgm_idtype IS  TABLE OF BEN_PGM_F.PGM_ID%TYPE INDEX BY BINARY_INTEGER;
   pgm_id_table pgm_idtype;
   pgm_id_table_index BINARY_INTEGER;
--End Bug 5768795*/
   TYPE pgm_idtype IS  TABLE OF BEN_PGM_F.PGM_ID%TYPE INDEX BY VARCHAR2(50);
   pgm_id_table pgm_idtype;
   pgm_id_table_index VARCHAR2(50);
--Bug 6133258
   --

   -- Bug 8623254
   cursor c_get_opt_id
   is
   select oipl.opt_id
     from ben_oipl_f oipl
    where oipl.oipl_id = l_pen.oipl_id
      and business_group_id = p_business_group_id
      and l_rt_strt_dt between oipl.effective_start_date and oipl.effective_end_date;

   l_get_opt_id c_get_opt_id%rowtype;

   -- Bug 8623254


   BEGIN
     --
     hr_utility.set_location ('Entering '||l_package,10);
     hr_utility.set_location ('ler date '||l_effective_date,10);
     --
     -- Edit to ensure that the input p_effective_date has a value
     --
     If p_effective_date is null then
       --
       fnd_message.set_name('BEN','BEN_91832_PACKAGE_PARAM_NULL');
       fnd_message.set_token('PACKAGE',l_package);
       fnd_message.set_token('PROC','Rate Change Event');
       fnd_message.set_token('PARAM','p_effective_date');
       fnd_message.raise_error;
       --
     elsif p_person_id is null then
       --
       fnd_message.set_name('BEN','BEN_91832_PACKAGE_PARAM_NULL');
       fnd_message.set_token('PACKAGE',l_package);
       fnd_message.set_token('PROC','Rate Change Event');
       fnd_message.set_token('PARAM','p_person_id');
       fnd_message.raise_error;
       --
     end if;
     --
     hr_utility.set_location (l_package,20);
     --
     -- Get the active per in ler id.
     --
     open c_pil;
       fetch c_pil into l_pil;
     close c_pil;
     --
     -- Get all electbale choices for the per in ler.
     --
     hr_utility.set_location ('Before loop '||l_package,25);
     --
     open  c_epe(l_pil.per_in_ler_id);
     --
     loop
       --
       hr_utility.set_location ('In loop '||l_package,30);
       --
       fetch c_epe into l_epe;
       exit when c_epe%notfound;
       hr_utility.set_location('Found an epe', 32);
       hr_utility.set_location('pl_id='||l_epe.pl_id,1963);
       hr_utility.set_location('GP oipl_id='||l_epe.oipl_id,1963);
       hr_utility.set_location('epe_id='||l_epe.elig_per_elctbl_chc_id,1963);
       hr_utility.set_location('pen_id='||l_epe.prtt_enrt_rslt_id,1963);
       --
       -- Initialize the variables.
       --
       l_pen_found         := false;
       l_enb_found         := false;
       l_prv_found         := false;
       l_ppe_found         := false;
       l_bnft_changed      := false;
       l_imp_changed       := false;
       l_enrt_cvg_strt_dt  := null;
       l_rt_strt_dt        := null;
       l_element_changed   := false; -- bug 5507982
       --
       --Bug 2789814 to resolve the issue of running the rate change before the
       --already started pen effective_start_date. Get the ENRT_PERD_STRT_DT fromn
       --the popl and if this is in future use that date instead of l_effective_date
       --for all computations.
       if l_epe.enrt_perd_strt_dt is not null then
         l_effective_date := l_epe.enrt_perd_strt_dt ;
       end if ;
       --
       hr_utility.set_location('Max l_effective_date '||l_effective_date,123);
       --
       -- Look for rate, benefit, premium changes only if the choice is
       -- not electable (electable flag is off).
       --
       hr_utility.set_location('elctbl_flag='||l_epe.elctbl_flag,1963);
       if l_epe.elctbl_flag = 'N' or p_mode = 'R' then
         --
         hr_utility.set_location ('An epe is not electable'||
         to_char(l_epe.elig_per_elctbl_chc_id),35);
         --
         open  c_pen;
         fetch c_pen into l_pen;
         --
         if c_pen%found then
           --
           l_pen_found := true;
           hr_utility.set_location('pen found',1963);
           hr_utility.set_location('pen_id='||l_epe.prtt_enrt_rslt_id,1963);
           --
         else
           hr_utility.set_location('pen not found',1963);
           hr_utility.set_location('pen_id='||l_epe.prtt_enrt_rslt_id,1963);
         end if;
     --
         close c_pen;
         --
         if l_pen_found then
           --
           -- Check for benefit amount changes.
           --
           hr_utility.set_location (l_package,40);
           --
           open  c_enb;
           fetch c_enb into l_enb;
           --
           if c_enb%found then
             --
             hr_utility.set_location('c_enb found enrt_bnft_id = ' || l_enb.enrt_bnft_id, 1999);
             hr_utility.set_location('c_enb found prtt_enrt_rslt_id = ' || l_enb.prtt_enrt_rslt_id, 1999);
             l_enb_found := true;
             --
             open c_pl(l_epe.pl_id,nvl(l_epe.fonm_cvg_strt_dt,p_effective_date));
             fetch c_pl into l_pl;
             if c_pl%FOUND then
                l_perform_imp := 'Y';
             end if;
             close c_pl;
             --
           else
             --
             -- Reset bnft id to null, if bnft record does not exist.
             --
             -- Bug 4895872 - Nullify all member variables of L_ENB
             hr_utility.set_location('c_enb not found',  1999);
             l_enb.enrt_bnft_id := null;
             l_enb.val := null;
             l_enb.prtt_enrt_rslt_id := null;
             l_enb.entr_val_at_enrt_flag := NULL;
             --
           end if; --
           close c_enb;
           --
           --
           if l_enb.CVG_MLT_CD = 'SAAEAR'
           then
             --
             open c_ecr(v_elig_per_elctbl_chc_id => null,
                        v_enrt_bnft_id           => l_enb.enrt_bnft_id );
               --
               fetch c_ecr into l_ecr_row;
               --
             close c_ecr;
             --
           end if;
           --
           if ben_manage_life_events.fonm = 'Y' then
              ben_manage_life_events.g_fonm_cvg_strt_dt :=
                              l_epe.fonm_cvg_strt_dt;
           end if;

           hr_utility.set_location('Old Amount '||l_pen.bnft_amt,10);
           hr_utility.set_location('New Amount '||l_enb.val,10);
           --
           -- Case B added for bug 4715688
           -- Case C added for bug 4723828
           -- Case : Same as Annualized Elected Activity Rate (SAAEAR) added for bug 5126800 - For this case
           --        ENB.VAL will always be null. Now if ECR.ENTR_VAL_AT_ENRT_FLAG = Y, then we should not
           --        update the PEN record with BNFT_AMT
           --
           if ( (  l_enb_found AND /* Case A : If earlier coverage existed and new coverage is different from old */
                   nvl(l_pen.bnft_amt, -1) <> nvl(l_enb.val, -1)  and
                   l_enb.entr_val_at_enrt_flag = 'N'  AND
                   l_enb.CVG_MLT_CD <> 'SAAEAR'
                 )
                 OR
                 (
                   l_enb.CVG_MLT_CD = 'SAAEAR' AND
                   l_ecr_row.ENTR_VAL_AT_ENRT_FLAG = 'N'
                 )
              )
              OR
              (  l_enb.prtt_enrt_rslt_id is null AND /* Case B : If coverage didnt exist earlier but now coverage exists */
                 l_enb.val is not null
               )
              OR
              (  l_enb.enrt_bnft_id IS NULL AND /* Case C : If coverage existed, but new coverage is absent or null */
                 l_pen.bnft_amt IS NOT NULL
               )
           then
             --
             -- When benefit amount changes, new result is written. The
             -- process also writes the new premium records. The new rates
             -- do NOT get created as we are not passing any rates.
             -- Also note that the new result id gets passed on to the
             -- variable l_pen.prtt_enrt_rslt_id.

             l_bnft_changed := true;

             -- check if we need to re-compute imputed income:
             -- if any plan in loop meets this criteria, recompute out of loop.
             open c_pl(l_epe.pl_id,nvl(l_epe.fonm_cvg_strt_dt,p_effective_date));
             fetch c_pl into l_pl;
             if c_pl%FOUND then
                l_imp_changed := true;
             end if;
             close c_pl;

             hr_utility.set_location (l_package,45);

             ben_election_information.election_information
               (p_elig_per_elctbl_chc_id => l_epe.elig_per_elctbl_chc_id,
                p_prtt_enrt_rslt_id      => l_pen.prtt_enrt_rslt_id,
                p_effective_date         => l_effective_date,
                p_enrt_mthd_cd           => l_pen.enrt_mthd_cd,
                p_enrt_bnft_id           => l_enb.enrt_bnft_id,
                p_bnft_val               => l_enb.val,
                p_prtt_rt_val_id1        => l_dummy_number,
                p_prtt_rt_val_id2        => l_dummy_number,
                p_prtt_rt_val_id3        => l_dummy_number,
                p_prtt_rt_val_id4        => l_dummy_number,
                p_prtt_rt_val_id5        => l_dummy_number,
                p_prtt_rt_val_id6        => l_dummy_number,
                p_prtt_rt_val_id7        => l_dummy_number,
                p_prtt_rt_val_id8        => l_dummy_number,
                p_prtt_rt_val_id9        => l_dummy_number,
                p_prtt_rt_val_id10       => l_dummy_number,
                -- Bug 2841161
                p_pen_attribute_category =>  l_pen.pen_attribute_category,
                p_pen_attribute1         =>  l_pen.pen_attribute1,
                p_pen_attribute2         =>  l_pen.pen_attribute2,
                p_pen_attribute3         =>  l_pen.pen_attribute3,
                p_pen_attribute4         =>  l_pen.pen_attribute4,
                p_pen_attribute5         =>  l_pen.pen_attribute5,
                p_pen_attribute6         =>  l_pen.pen_attribute6,
                p_pen_attribute7         =>  l_pen.pen_attribute7,
                p_pen_attribute8         =>  l_pen.pen_attribute8,
                p_pen_attribute9         =>  l_pen.pen_attribute9,
                p_pen_attribute10        =>  l_pen.pen_attribute10,
                p_pen_attribute11        =>  l_pen.pen_attribute11,
                p_pen_attribute12        =>  l_pen.pen_attribute12,
                p_pen_attribute13        =>  l_pen.pen_attribute13,
                p_pen_attribute14        =>  l_pen.pen_attribute14,
                p_pen_attribute15        =>  l_pen.pen_attribute15,
                p_pen_attribute16        =>  l_pen.pen_attribute16,
                p_pen_attribute17        =>  l_pen.pen_attribute17,
                p_pen_attribute18        =>  l_pen.pen_attribute18,
                p_pen_attribute19        =>  l_pen.pen_attribute19,
                p_pen_attribute20        =>  l_pen.pen_attribute20,
                p_pen_attribute21        =>  l_pen.pen_attribute21,
                p_pen_attribute22        =>  l_pen.pen_attribute22,
                p_pen_attribute23        =>  l_pen.pen_attribute23,
                p_pen_attribute24        =>  l_pen.pen_attribute24,
                p_pen_attribute25        =>  l_pen.pen_attribute25,
                p_pen_attribute26        =>  l_pen.pen_attribute26,
                p_pen_attribute27        =>  l_pen.pen_attribute27,
                p_pen_attribute28        =>  l_pen.pen_attribute28,
                p_pen_attribute29        =>  l_pen.pen_attribute29,
                p_pen_attribute30        =>  l_pen.pen_attribute30,
                p_datetrack_mode         => hr_api.g_update,
                p_suspend_flag           => l_dummy_char,
                p_effective_start_date   => l_dummy_date,
                p_effective_end_date     => l_dummy_date,
                p_object_version_number  => l_pen.object_version_number,
                p_prtt_enrt_interim_id   => l_dummy_number,
                p_business_group_id      => p_business_group_id,
                p_dpnt_actn_warning      => l_dummy_bool,
                p_bnf_actn_warning       => l_dummy_bool,
                p_ctfn_actn_warning      => l_dummy_bool);
             --
--Start Bug 5768795
	     if((not pgm_id_table.exists(l_pen.pgm_id)) and l_pen.pgm_id is not null)then
	         pgm_id_table(l_pen.pgm_id):=l_pen.pgm_id;
		 hr_utility.set_location('pgm_id_table(l_pen.pgm_id) ' ||pgm_id_table(l_pen.pgm_id),10);
	     end if;
--End Bug 5768795
        --
         end if;
           --
           -- Look for rate changes.
           --
           hr_utility.set_location ('Before Rates ',50);
           --
           for l_ecr in c_ecr(l_epe.elig_per_elctbl_chc_id,
                              l_enb.enrt_bnft_id) loop

	     l_rt_end_dt_non_rec := null;  -- Bug 7566569
             --
             hr_utility.set_location ('In rates loop ',55);
             --
             if l_ecr.rt_strt_dt_cd is null then
                l_rt_strt_dt := l_ecr.rt_strt_dt;
             end if;
             --BUG 4715657 This needs to be called if l_rt_strt_dt is null before calling c_prv
             if l_rt_strt_dt is null then
                   --
                   -- derive new rt strt dt
                   --
                   ben_determine_date.rate_and_coverage_dates
                   (p_which_dates_cd         => 'R'
                   ,p_date_mandatory_flag    => 'Y'
                   ,p_compute_dates_flag     => 'Y'
                   ,p_business_group_id      => p_business_group_id
                   ,p_per_in_ler_id          => l_pil.per_in_ler_id
                   ,p_person_id              => p_person_id
                   ,p_pgm_id                 => l_pen.pgm_id
                   ,p_pl_id                  => l_pen.pl_id
                   ,p_oipl_id                => l_pen.oipl_id
                   ,p_lee_rsn_id             => l_epe.lee_rsn_id
                   ,p_enrt_perd_id           => l_epe.enrt_perd_id
                   ,p_enrt_cvg_strt_dt       => l_enrt_cvg_strt_dt     --out
                   ,p_enrt_cvg_strt_dt_cd    => l_enrt_cvg_strt_dt_cd  --out
                   ,p_enrt_cvg_strt_dt_rl    => l_enrt_cvg_strt_dt_rl  --out
                   ,p_rt_strt_dt             => l_rt_strt_dt           --out
                   ,p_rt_strt_dt_cd          => l_rt_strt_dt_cd        --out
                   ,p_rt_strt_dt_rl          => l_rt_strt_dt_rl        --out
                   ,p_enrt_cvg_end_dt        => l_enrt_cvg_end_dt      --out
                   ,p_enrt_cvg_end_dt_cd     => l_enrt_cvg_end_dt_cd   --out
                   ,p_enrt_cvg_end_dt_rl     => l_enrt_cvg_end_dt_rl   --out
                   ,p_rt_end_dt              => l_rt_end_dt            --out
                   ,p_rt_end_dt_cd           => l_rt_end_dt_cd         --out
                   ,p_rt_end_dt_rl           => l_rt_end_dt_rl         --out
                   ,p_effective_date         => l_effective_date
                   ,p_lf_evt_ocrd_dt    => nvl(l_pil.lf_evt_ocrd_dt,p_effective_date)
                   );

             end if; --l_rt_strt_dt
             -- Bug 9286869: Added profile BEN: Create Non Recurring Entries
             -- Default value for the profile is 'Y', which means that non-recurring elements will be created
             -- while running RPV. If the profile is set to 'N' and if it is a non-recurring element, then
             -- do not recreated it while running RPV

             l_chk_non_rec_entry := fnd_profile.value('BEN_CREATE_NON_REC_ENTRIES');
             hr_utility.set_location ('profile BEN_CREATE_NON_REC_ENTRIES '||l_chk_non_rec_entry,50);
             --
             -- Bug 7566569 : Check whether the element / rate is a non-recurring one. If it is non-recurring,
	           -- we should not re-create it while running Recalculate Participant Values program
	           --
             BEN_PRTT_RT_VAL_API.get_non_recurring_end_dt
               (p_rt_strt_dt             =>  l_rt_strt_dt
               ,p_acty_base_rt_id        =>  l_ecr.acty_base_rt_id
               ,p_business_group_id      =>  p_business_group_id
               ,p_rt_end_dt              =>  l_rt_end_dt_non_rec
               ,p_recurring_rt           =>  l_recurring_rt
               ,p_effective_date         =>  l_effective_date
                );

             if (nvl(l_chk_non_rec_entry,'Y') = 'Y' or (nvl(l_chk_non_rec_entry,'Y')='N' and l_recurring_rt)) then
	              hr_utility.set_location ('Rate is either recurring or non-rec with profile option as Yes ',50);
                open c_prv(l_ecr.acty_base_rt_id,l_rt_strt_dt);
                fetch c_prv into l_prv;
                --
                if c_prv%found then
                   --
                   l_prv_found := true;
                   --
                else
                  --
                  l_prv_found          := false;
                  l_prv.prtt_rt_val_id := null;
                  --
                end if;
                --
                close c_prv;
                --
                -- Update rates when the rate has changed.
                -- Also write rates when benefit amount changes, as the rates
                -- were not written while creating the new result.
                --
                -- Fix for WWBUG 1298556
                -- Check if activity changed.
                --
                hr_utility.set_location('OLD RT'||l_prv.rt_val,10);
                hr_utility.set_location('NEW RT'||l_ecr.val,10);
                hr_utility.set_location('OLD ACT'||l_prv.acty_typ_cd,10);
                hr_utility.set_location('NEW ACT'||l_ecr.acty_typ_cd,10);
                -- Bug 2551834 If the ecr.val is null it fails
                -- Bug#2959410 - don't look for changes if the rate is enter value
                -- at enrollment as the val will always be null
                l_entr_val_at_enrt_flag := l_ecr.entr_val_at_enrt_flag;
                --
                if l_ecr.entr_val_at_enrt_flag = 'N' then
                   -- to check whether parent or child is enter value at enrollment
                   open c_entr_val (l_ecr.acty_base_rt_id, l_effective_date);
                   fetch c_entr_val into l_entr_val_at_enrt_flag;
                   close c_entr_val;
                   --
                end if;
                --
                -- if the amt changed, no need to determine if the element
                -- info changed
                --
                if l_prv_found and
                   ((nvl(l_prv.rt_val,0)       =  nvl(l_ecr.val,0)       and
                     nvl(l_prv.ann_rt_val,0)   =  nvl(l_ecr.ann_val,0)   and  /* bug 7414466 */
                     nvl(l_prv.cmcd_rt_val,0)  =  nvl(l_ecr.cmcd_val,0)) OR  /* bug 7414466 */
                    l_prv.rt_ovridn_flag    = 'Y') then
                  --
                  if l_rt_strt_dt is null then
                      --
                      -- derive new rt strt dt
                      --
                      ben_determine_date.rate_and_coverage_dates
                      (p_which_dates_cd         => 'R'
                      ,p_date_mandatory_flag    => 'Y'
                      ,p_compute_dates_flag     => 'Y'
                      ,p_business_group_id      => p_business_group_id
                      ,p_per_in_ler_id          => l_pil.per_in_ler_id
                      ,p_person_id              => p_person_id
                      ,p_pgm_id                 => l_pen.pgm_id
                      ,p_pl_id                  => l_pen.pl_id
                      ,p_oipl_id                => l_pen.oipl_id
                      ,p_lee_rsn_id             => l_epe.lee_rsn_id
                      ,p_enrt_perd_id           => l_epe.enrt_perd_id
                      ,p_enrt_cvg_strt_dt       => l_enrt_cvg_strt_dt     --out
                      ,p_enrt_cvg_strt_dt_cd    => l_enrt_cvg_strt_dt_cd  --out
                      ,p_enrt_cvg_strt_dt_rl    => l_enrt_cvg_strt_dt_rl  --out
                      ,p_rt_strt_dt             => l_rt_strt_dt           --out
                      ,p_rt_strt_dt_cd          => l_rt_strt_dt_cd        --out
                      ,p_rt_strt_dt_rl          => l_rt_strt_dt_rl        --out
                      ,p_enrt_cvg_end_dt        => l_enrt_cvg_end_dt      --out
                      ,p_enrt_cvg_end_dt_cd     => l_enrt_cvg_end_dt_cd   --out
                      ,p_enrt_cvg_end_dt_rl     => l_enrt_cvg_end_dt_rl   --out
                      ,p_rt_end_dt              => l_rt_end_dt            --out
                      ,p_rt_end_dt_cd           => l_rt_end_dt_cd         --out
                      ,p_rt_end_dt_rl           => l_rt_end_dt_rl         --out
                      ,p_effective_date         => l_effective_date
                      ,p_lf_evt_ocrd_dt    => nvl(l_pil.lf_evt_ocrd_dt,p_effective_date)
                      );

                  end if; --l_rt_strt_dt
                  --
                end if;  -- rv.rt_ovridn_flag    = 'Y'

                if ben_manage_life_events.fonm = 'Y' then
                   ben_manage_life_events.g_fonm_rt_strt_dt := l_rt_strt_dt;
                end if;
                --
                --Bug 3192923 If the rate was overriden in the previous enrollment
                --and the rate start date is not after the override thru date we
                --don't need to recompute the rates.
                --
                if (( l_prv_found and
                   nvl(l_prv.rt_val,0) =  nvl(l_ecr.val,0) and
                   nvl(l_prv.ann_rt_val,0) = nvl(l_ecr.ann_val,0) and  /* bug 7414466 */
                   nvl(l_prv.cmcd_rt_val,0)   = nvl(l_ecr.cmcd_val,0)   /* bug 7414466 */
                  )and
                  (l_prv.rt_ovridn_flag = 'N' OR
                   (l_prv.rt_ovridn_flag= 'Y' and nvl(l_prv.rt_ovridn_thru_dt,hr_api.g_eot)< l_rt_strt_dt )))  then
                   --
                   -- get old element info
                   --
                   l_element_info := null;
                   if l_prv.element_entry_value_id is not null then
                      open c_element_info (l_prv.element_entry_value_id,
                                           l_pen.prtt_enrt_rslt_id);
                      fetch c_element_info into l_element_info;
                      close c_element_info;
                   end if;

                   hr_utility.set_location('elt :'||l_element_info.element_type_id,10);
                   hr_utility.set_location('inp :'||l_element_info.input_value_id,10);
                   hr_utility.set_location('ee end:'||l_element_info.effective_end_date,10);
                   hr_utility.set_location('rt strt :'||l_rt_strt_dt,10);
                   --
                   -- get current element info
                   --
                   open c_abr(l_ecr.acty_base_rt_id,l_rt_strt_dt);
                   fetch c_abr into l_abr;
                   close c_abr;
                   --
                   -- get old values on standard rate
                   --
                   if not (l_prv.rt_strt_dt between l_abr.effective_start_date and
                      l_abr.effective_end_date) then
                      open c_abr(l_ecr.acty_base_rt_id,l_prv.rt_strt_dt);
                      fetch c_abr into l_abr2;
                      close c_abr;
                   else
                      l_abr2 := l_abr;
                   end if;
                   --
                   --get the new abr assignment and payroll
                   --
                   l_new_assignment_id := null;
                   l_new_organization_id := null;
                   l_new_payroll_id    := null;

                   ben_element_entry.get_abr_assignment
                   (p_person_id       => p_person_id,
                    p_effective_date  => l_rt_strt_dt,
                    p_acty_base_rt_id => l_ecr.acty_base_rt_id,
                    p_assignment_id   => l_new_assignment_id,
                    p_payroll_id      => l_new_payroll_id,
                    p_organization_id => l_new_organization_id);

                   --
                   -- determine if element info changed
                   --
                   l_element_changed :=
                     (l_prv.element_entry_value_id is not null and
                      l_abr.ele_rqd_flag = 'N') or
                     (l_abr.ele_rqd_flag = 'Y' and
                      ((nvl(l_element_info.input_value_id,-1) <>
                        l_abr.input_value_id) or
                       (nvl(l_element_info.element_type_id,-1) <>
                        l_abr.element_type_id) or
                        (l_element_info.effective_end_date < l_rt_strt_dt) or
                        (l_element_info.assignment_id <>
                         nvl(l_new_assignment_id,-1)) or
                        (nvl(l_element_info.payroll_id,-1) <>
                         nvl(l_new_payroll_id,-1)) or
                        (nvl(l_abr.ele_entry_val_cd,'PP') <>
                          nvl(l_abr2.ele_entry_val_cd,'PP')))
                     );
                   --
                   -- determine if extra input values changed
                   --
                   if not l_element_changed then

                      -- Bug 8623254
                      l_get_opt_id := null;

                      hr_utility.set_location( 'l_pen.oipl_id '||l_pen.oipl_id, 20);
                      if l_pen.oipl_id is not null then
 		                     open c_get_opt_id;
			                   fetch c_get_opt_id into l_get_opt_id;
			                   close c_get_opt_id;
                      end if;
                      hr_utility.set_location( 'l_get_opt_id.opt_id '||l_get_opt_id.opt_id, 20);

	              -- Bug 8623254

                      l_ext_inpval_tab.delete;
                      ben_element_entry.get_extra_ele_inputs
                      (p_effective_date         => l_rt_strt_dt
                      ,p_person_id              => p_person_id
                      ,p_business_group_id      => p_business_group_id
                      ,p_assignment_id          => l_new_assignment_id
                      ,p_element_link_id        => null
                      ,p_entry_type             => 'E'
                      ,p_input_value_id1        => null
                      ,p_entry_value1           => null
                      ,p_element_entry_id       => null
                      ,p_acty_base_rt_id        => l_ecr.acty_base_rt_id
                      ,p_input_va_calc_rl       => l_abr.input_va_calc_rl
                      ,p_abs_ler                => null
                      ,p_organization_id        => l_new_organization_id
                      ,p_payroll_id             => l_new_payroll_id
                      ,p_pgm_id                 => l_pen.pgm_id
                      ,p_pl_id                  => l_pen.pl_id
                      ,p_pl_typ_id              => l_pen.pl_typ_id
                      ,p_opt_id                 => l_get_opt_id.opt_id          -- Bug 8623254
                      ,p_ler_id                 => l_pen.ler_id
                      ,p_dml_typ                => 'C'
                      ,p_jurisdiction_code      => l_jurisdiction_code
                      ,p_ext_inpval_tab         => l_ext_inpval_tab
                      ,p_subpriority            => l_subpriority
                      );

                      ben_element_entry.get_inpval_tab
                      (p_element_entry_id   => l_element_info.element_entry_id
                      ,p_effective_date     => l_rt_strt_dt
                      ,p_inpval_tab         => l_inpval_tab);

                      l_ext_inp_changed := false;
                      for i in 1..l_ext_inpval_tab.count
                      loop
                         for j in 1..l_inpval_tab.count
                         loop
                             if (l_ext_inpval_tab(i).input_value_id =
                                l_inpval_tab(j).input_value_id) and
                                (nvl(l_ext_inpval_tab(i).return_value,'-1')  <>
                                nvl(l_inpval_tab(j).value,'-1')) then
                                l_ext_inp_changed := true;
                                exit;
                             end if;
                         end loop;
                         if l_ext_inp_changed then
                            exit;
                         end if;
                      end loop;

                      l_element_changed := l_ext_inp_changed;

                   end if;

                end if;
                --
                open c_prv_min_dt(l_pen.prtt_enrt_rslt_id,l_ecr.acty_base_rt_id);
                fetch c_prv_min_dt into l_prv_min_strt_dt;
                close c_prv_min_dt;

                if ((l_rt_strt_dt >= nvl(l_prv_min_strt_dt,l_rt_strt_dt)) and
                    ((NOT l_prv_found)  OR
                     (l_prv.rt_ovridn_flag = 'N' OR
                      (l_prv.rt_ovridn_flag= 'Y' and
                       nvl(l_prv.rt_ovridn_thru_dt,hr_api.g_eot)< l_rt_strt_dt))))
                then
                  --
                  /* Bug 3394862 We need to modify this if clause such that
                     l_entr_val_at_enrt_flag is checked only
                     with nvl(l_prv.rt_val,0) <> nvl(l_ecr.val,0) condition.
                     --
                  if (l_entr_val_at_enrt_flag = 'N' and
                      (nvl(l_prv.rt_val,0) <> nvl(l_ecr.val,0) or
                       nvl(l_prv.acty_typ_cd,'-1') <> nvl(l_ecr.acty_typ_cd,'-1') or
                       nvl(l_prv.tx_typ_cd,'-1') <> nvl(l_ecr.tx_typ_cd,'-1') or
                       l_element_changed)) or
                     l_bnft_changed then
                  */
                 /* bug#4113295 - SAREC condition added as there is no need to create rate
                    if there is no change in benefit amount * will anyway create rates
                  */

                  if (l_entr_val_at_enrt_flag = 'N' and
                     (nvl(l_prv.rt_val,0) <> nvl(l_ecr.val,0) or
                      nvl(l_prv.ann_rt_val,0) <> nvl(l_ecr.ann_val,0) or   /* bug 7414466 */
                      nvl(l_prv.cmcd_rt_val,0) <> nvl(l_ecr.cmcd_val,0)    /* bug 7414466 */
                     )
                     and l_ecr.rt_mlt_cd <> 'SAREC') or
                     nvl(l_prv.acty_typ_cd,'-1') <> nvl(l_ecr.acty_typ_cd,'-1') or
                     nvl(l_prv.tx_typ_cd,'-1') <> nvl(l_ecr.tx_typ_cd,'-1') or
                     l_element_changed or
                     l_bnft_changed then
                     --
                      hr_utility.set_location ('Calling rate_info ',60);
                      hr_utility.set_location('rate change',13);
                     --
                      l_flex_call := true;
                      ben_election_information.election_rate_information
                      (p_enrt_mthd_cd      => l_pen.enrt_mthd_cd
                      ,p_effective_date    => l_effective_date
                      ,p_prtt_enrt_rslt_id => l_pen.prtt_enrt_rslt_id
                      ,p_per_in_ler_id     => l_pil.per_in_ler_id
                      ,p_person_id         => p_person_id
                      ,p_pgm_id            => l_pen.pgm_id
                      ,p_pl_id             => l_pen.pl_id
                      ,p_oipl_id           => l_pen.oipl_id
                      ,p_enrt_rt_id        => l_ecr.enrt_rt_id
                      ,p_prtt_rt_val_id    => l_prv.prtt_rt_val_id
                      ,p_rt_val            => l_ecr.val
                      ,p_ann_rt_val        => l_ecr.ann_val
                      ,p_enrt_cvg_strt_dt  => l_pen.enrt_cvg_strt_dt
                      ,p_acty_ref_perd_cd  => l_epe.acty_ref_perd_cd
                      ,p_datetrack_mode    => hr_api.g_update
                      ,p_business_group_id => p_business_group_id
                      ,p_bnft_amt_changed  => l_bnft_changed
                      ,p_ele_changed       => l_element_changed
                      ,p_prv_rt_val        => l_dummy_number
                      ,p_prv_ann_rt_val    => l_dummy_number
                      );
                    --
                  end if;
                  --
                end if; --Override if

             end if;   -- l_recurring_rt -- Bug 7566569
             --
           end loop;

           hr_utility.set_location ('Before imputed and premium process  ',65);

           if l_bnft_changed then
              -- if benefit amount changed, check to see if imputed
              -- income should also change.
              if l_imp_changed then
                ben_det_imputed_income.p_comp_imputed_income
                (p_person_id            => p_person_id
                ,p_enrt_mthd_cd         => 'A'
                ,p_per_in_ler_id        => l_pil.per_in_ler_id
                ,p_effective_date       => l_effective_date
                ,p_business_group_id    => p_business_group_id
                ,p_ctrlm_fido_call      => false
                ,p_validate             => false);
                --
                l_perform_imp := 'N';
              end if;
              --
              -- call total-pools to compute flex credit rate - bug#2273129
              open c_prtt_enrt (l_pen.pgm_id);
              fetch c_prtt_enrt into l_prtt_enrt_rslt_id_shell,l_enrt_perd_strt_dt ;
              close c_prtt_enrt;
              --Bug 3044116
              l_total_pools_eff_dt := l_effective_date ;
              --
              /* l_effective_date is already assigned the enrt_perd_strt_dt
              if l_enrt_perd_strt_dt > l_effective_date then
                l_total_pools_eff_dt := l_enrt_perd_strt_dt + 1 ;
              end if ;
              */
              --
              if l_prtt_enrt_rslt_id_shell is not null then
                 ben_provider_pools.total_pools(
                                p_prtt_enrt_rslt_id => l_prtt_enrt_rslt_id_shell,
                                p_prtt_rt_val_id    => l_prtt_rt_val_id,
                                p_acty_ref_perd_cd  => l_acty_ref_perd_cd,
                                p_acty_base_rt_id   => l_acty_base_rt_id,
                                p_rt_strt_dt        => l_bpp_rt_strt_dt,
                                p_rt_val            => l_rt_val,
                                p_element_type_id   => l_element_type_id,
                                p_person_id         => p_person_id,
                                p_per_in_ler_id     => p_per_in_ler_id,
                                p_enrt_mthd_cd      => 'E' ,
                                p_effective_date    => l_total_pools_eff_dt, -- l_pil.lf_evt_ocrd_dt,
                                p_business_group_id => p_business_group_id,
                                p_pgm_id            => l_pen.pgm_id
                                );
              --
              end if;
              --

           else
             open c_prtt_enrt (l_pen.pgm_id);
             fetch c_prtt_enrt into l_prtt_enrt_rslt_id_shell,l_enrt_perd_strt_dt ;
             close c_prtt_enrt;
             if l_prtt_enrt_rslt_id_shell is null then
               --call flex credit recompute even if there is no change in provided
                --value as the net amount might have been changed because of used value
                 l_flex_call := false;
             else
               --
               open c_pen2(l_prtt_enrt_rslt_id_shell);
               fetch c_pen2 into l_enrt_mthd_cd;
               close c_pen2;
               --
             end if;
             --Bug 3044116
             l_total_pools_eff_dt := l_effective_date ;
             --
             /*
             if l_enrt_perd_strt_dt > l_effective_date then
               l_total_pools_eff_dt := l_enrt_perd_strt_dt + 1 ;
             end if ;
             */
             -- cal for the flex credit changes
             for   i in  c_flex_choice (l_pen.pgm_id) Loop
                l_prvdd_val := null;
                open c_bpl ( i.acty_base_rt_id ,
                             i.bnft_prvdr_pool_id,
                             l_prtt_enrt_rslt_id_shell ) ;
                fetch c_bpl into l_prvdd_val ;
                close c_bpl ;
                --if there is amount change call the updating
                hr_utility.set_location( 'prvdd val ' || l_prvdd_val , 1001);
                hr_utility.set_location( 'changed val  ' || i.val , 1001);
                hr_utility.set_location('Result id'||l_prtt_enrt_rslt_id_shell,1002);


                if l_prvdd_val is not null and l_prvdd_val <> i.val then
                    ben_provider_pools.create_credit_ledger_entry
                                      ( p_person_id               => p_person_id  ,
                                        p_elig_per_elctbl_chc_id  => i.elig_per_elctbl_chc_id ,
                                        p_per_in_ler_id           => i.per_in_ler_id,
                                        p_business_group_id       => p_business_group_id ,
                                        p_bnft_prvdr_pool_id      => i.bnft_prvdr_pool_id,
                                        p_enrt_mthd_cd            => l_pen.enrt_mthd_cd,
                                        p_effective_date          => l_effective_date
                                                                     --l_pil.lf_evt_ocrd_dt
                                      );
                    --
                    /*
                    open c_pen2(l_prtt_enrt_rslt_id_shell);
                    fetch c_pen2 into l_enrt_mthd_cd;
                    close c_pen2;
                    */
                    --
                    l_flex_call := false;
                    ben_provider_pools.total_pools(
                                p_prtt_enrt_rslt_id => l_prtt_enrt_rslt_id_shell,
                                p_prtt_rt_val_id    => l_prtt_rt_val_id,
                                p_acty_ref_perd_cd  => l_acty_ref_perd_cd,
                                p_acty_base_rt_id   => l_acty_base_rt_id,
                                p_rt_strt_dt        => l_bpp_rt_strt_dt,
                                p_rt_val            => l_rt_val,
                                p_element_type_id   => l_element_type_id,
                                p_person_id         => p_person_id,
                                p_per_in_ler_id     => p_per_in_ler_id,
                                p_enrt_mthd_cd      => l_enrt_mthd_cd ,
                                p_effective_date    => l_total_pools_eff_dt , --l_pil.lf_evt_ocrd_dt,
                                p_business_group_id => p_business_group_id,
                                p_pgm_id            => l_pen.pgm_id
                                );

                end if;
            end loop ;
            --UK select bug
            if l_flex_call then
               -- call total_pools to recompute the net credit
                l_flex_call := false;
                ben_provider_pools.total_pools(
                                p_prtt_enrt_rslt_id => l_prtt_enrt_rslt_id_shell,
                                p_prtt_rt_val_id    => l_prtt_rt_val_id,
                                p_acty_ref_perd_cd  => l_acty_ref_perd_cd,
                                p_acty_base_rt_id   => l_acty_base_rt_id,
                                p_rt_strt_dt        => l_bpp_rt_strt_dt,
                                p_rt_val            => l_rt_val,
                                p_element_type_id   => l_element_type_id,
                                p_person_id         => p_person_id,
                                p_per_in_ler_id     => p_per_in_ler_id,
                                p_enrt_mthd_cd      => l_enrt_mthd_cd ,
                                p_effective_date    => l_total_pools_eff_dt ,
                                p_business_group_id => p_business_group_id,
                                p_pgm_id            => l_pen.pgm_id
                                );
           end if;

             -- Look for premium changes.
             -- If the benefit amount has changed, the premium would
             -- already have changed by the election_information call.
             for l_epr in c_epr(l_epe.elig_per_elctbl_chc_id,
                                l_enb.enrt_bnft_id) loop
               hr_utility.set_location ('In Prem. loop  ',70);
               --
               -- derive new rt strt dt
               --
               if l_rt_strt_dt is null then
                  ben_determine_date.rate_and_coverage_dates
                  (p_which_dates_cd         => 'R'
                  ,p_date_mandatory_flag    => 'Y'
                  ,p_compute_dates_flag     => 'Y'
                  ,p_business_group_id      => p_business_group_id
                  ,p_per_in_ler_id          => l_pil.per_in_ler_id
                  ,p_person_id              => p_person_id
                  ,p_pgm_id                 => l_pen.pgm_id
                  ,p_pl_id                  => l_pen.pl_id
                  ,p_oipl_id                => l_pen.oipl_id
                  ,p_lee_rsn_id             => l_epe.lee_rsn_id
                  ,p_enrt_perd_id           => l_epe.enrt_perd_id
                  ,p_enrt_cvg_strt_dt       => l_dummy_date
                  ,p_enrt_cvg_strt_dt_cd    => l_dummy_char
                  ,p_enrt_cvg_strt_dt_rl    => l_dummy_number
                  ,p_rt_strt_dt             => l_rt_strt_dt
                  ,p_rt_strt_dt_cd          => l_rt_strt_dt_cd
                  ,p_rt_strt_dt_rl          => l_rt_strt_dt_rl
                  ,p_enrt_cvg_end_dt        => l_dummy_date
                  ,p_enrt_cvg_end_dt_cd     => l_dummy_char
                  ,p_enrt_cvg_end_dt_rl     => l_dummy_number
                  ,p_rt_end_dt              => l_dummy_date
                  ,p_rt_end_dt_cd           => l_dummy_char
                  ,p_rt_end_dt_rl           => l_dummy_number
                  ,p_effective_date         => p_effective_date
                  ,p_lf_evt_ocrd_dt         => nvl(l_pil.lf_evt_ocrd_dt,p_effective_date)
                     );
               end if;

               if l_enrt_cvg_strt_dt is null then
                  ben_determine_date.rate_and_coverage_dates
                  (p_which_dates_cd         => 'C'
                  ,p_date_mandatory_flag    => 'Y'
                  ,p_compute_dates_flag     => 'Y'
                  ,p_business_group_id      => p_business_group_id
                  ,p_per_in_ler_id          => l_pil.per_in_ler_id
                  ,p_person_id              => p_person_id
                  ,p_pgm_id                 => l_pen.pgm_id
                  ,p_pl_id                  => l_pen.pl_id
                  ,p_oipl_id                => l_pen.oipl_id
                  ,p_lee_rsn_id             => l_epe.lee_rsn_id
                  ,p_enrt_perd_id           => l_epe.enrt_perd_id
                  ,p_enrt_cvg_strt_dt       => l_enrt_cvg_strt_dt     --out
                  ,p_enrt_cvg_strt_dt_cd    => l_dummy_char
                  ,p_enrt_cvg_strt_dt_rl    => l_dummy_number
                  ,p_rt_strt_dt             => l_dummy_date
                  ,p_rt_strt_dt_cd          => l_dummy_char
                  ,p_rt_strt_dt_rl          => l_dummy_number
                  ,p_enrt_cvg_end_dt        => l_dummy_date
                  ,p_enrt_cvg_end_dt_cd     => l_dummy_char
                  ,p_enrt_cvg_end_dt_rl     => l_dummy_number
                  ,p_rt_end_dt              => l_dummy_date
                  ,p_rt_end_dt_cd           => l_dummy_char
                  ,p_rt_end_dt_rl           => l_dummy_number
                  ,p_effective_date         => p_effective_date
                  ,p_lf_evt_ocrd_dt         => nvl(l_pil.lf_evt_ocrd_dt,p_effective_date)
                     );
               end if;

               if ben_manage_life_events.fonm = 'Y' then
                  l_ppe_dt_to_use := l_enrt_cvg_strt_dt;
                  ben_manage_life_events.g_fonm_rt_strt_dt := l_rt_strt_dt;
                  ben_manage_life_events.g_fonm_cvg_strt_dt := l_enrt_cvg_strt_dt;

               else
                  l_ppe_dt_to_use := greatest(l_pen.enrt_cvg_strt_dt,l_rt_strt_dt);
               end if;

               open c_ppe(l_epr.actl_prem_id,l_ppe_dt_to_use);
               fetch c_ppe into l_ppe;

               if c_ppe%found then
                 l_ppe_found := true;
               else
                 l_ppe_found := false;
               end if;
               close c_ppe;

               if l_ppe_found then
                 -- Because the benefit amount could have changed, and the premiums
                 -- can be based on the benefit amount, re-calc it.  It does a recalc
                 -- if the benefit amount is entered at enrollment.
                 ben_PRTT_PREM_api.recalc_PRTT_PREM
                 (p_prtt_prem_id                   =>  l_ppe.prtt_prem_id
                 ,p_std_prem_uom                   =>  l_ppe.std_prem_uom
                 ,p_std_prem_val                   =>  l_epr.val  -- in/out
                 ,p_actl_prem_id                   =>  l_epr.actl_prem_id
                 ,p_prtt_enrt_rslt_id              =>  l_pen.prtt_enrt_rslt_id
                 ,p_per_in_ler_id                  =>  l_pil.per_in_ler_id
                 ,p_ler_id                         =>  l_pil.ler_id
                 ,p_lf_evt_ocrd_dt                 =>  l_pil.lf_evt_ocrd_dt
                 ,p_elig_per_elctbl_chc_id         =>  l_epe.elig_per_elctbl_chc_id
                 ,p_enrt_bnft_id                   =>  l_enb.enrt_bnft_id
                 ,p_business_group_id              =>  p_business_group_id
                 ,p_effective_date                 =>  l_effective_date  --9999p_effective_date
                 -- bof FONM
                 ,p_enrt_cvg_strt_dt               => l_enrt_cvg_strt_dt
                 ,p_rt_strt_dt                     => l_rt_strt_dt
                 -- eof FONM
                 );
                 --
                 if l_ppe.std_prem_val <> l_epr.val then
                   hr_utility.set_location ('Updating prem. ',75);
                   /* Start of Changes for WWBUG: 1646442                       */
                   --
                   --Find the valid datetrack modes.
                   --
                   dt_api.find_dt_upd_modes
                        (p_effective_date       => l_ppe_dt_to_use,
                         p_base_table_name      => 'BEN_PRTT_PREM_F',
                         p_base_key_column      => 'prtt_prem_id',
                         p_base_key_value       => l_ppe.prtt_prem_id,
                         p_correction           => l_correction,
                         p_update               => l_update,
                         p_update_override      => l_update_override,
                         p_update_change_insert => l_update_change_insert);

                   if l_update_override then
                        l_ppe_datetrack_mode := hr_api.g_update_override;
                   elsif l_update then
                        l_ppe_datetrack_mode := hr_api.g_update;
                   else
                        l_ppe_datetrack_mode := hr_api.g_correction;
                   end if;
                   /* End of Changes for WWBUG: 1646442                         */

                   ben_prtt_prem_api.update_prtt_prem
                   (p_prtt_prem_id               => l_ppe.prtt_prem_id,
                    p_object_version_number      => l_ppe.object_version_number,
                    p_std_prem_val               => l_epr.val,
                    p_per_in_ler_id              => l_pil.per_in_ler_id,
                    /*
                        CODE PRIOR TO WWBUG: 1646442
                    p_effective_date             => l_effective_date, --9999 p_effective_date,
                    p_datetrack_mode             => hr_api.g_update,
                    */
                    /* Start of Changes for WWBUG: 1646442                      */
                    p_effective_date             => l_ppe_dt_to_use,
                    p_datetrack_mode             => l_ppe_datetrack_mode,
                    /* End of Changes for WWBUG: 1646442                        */
                    p_effective_start_date       => l_dummy_date,
                    p_effective_end_date         => l_dummy_date);
                  end if;
               end if;
             end loop; -- c_epr

           end if; -- l_bnft_changed
           --
          -- Bug#2776740 - if the standard rate already enrolled is not valid in this life event
          -- then end the participant rate
           ben_det_enrt_rates.end_prtt_rt_val
                (p_person_id           => l_pen.person_id
                ,p_per_in_ler_id       => p_per_in_ler_id
                ,p_business_group_id   => l_pen.business_group_id
                ,p_effective_date      => l_effective_date -- 9999 p_effective_date
                ,p_prtt_enrt_rslt_id   => l_pen.prtt_enrt_rslt_id
                );
           --
         end if; -- l_pen_found
         --
       end if;  -- elctbl_flag = 'N'
       --
     end loop;  -- c_epe
     --
     hr_utility.set_location ('Out of epe loop '||l_package,85);
     --
     close c_epe;
     --
     --gevity fix
     -- to prevent any bleeding of the variable it is reinitialised
     l_flex_call := false;

     open  c_epe3(l_pil.per_in_ler_id);
     --
     loop
       --
       hr_utility.set_location ('In loop '||l_package,321);
       --
       fetch c_epe3 into l_epe;
       exit when c_epe3%notfound;
       hr_utility.set_location('pen_id='||l_epe.prtt_enrt_rslt_id,1964);
       l_pen_found         := false;
       l_enrt_cvg_strt_dt  := null;
       l_rt_strt_dt        := null;

       if l_epe.elctbl_flag = 'N' or p_mode = 'R' then
         --
         hr_utility.set_location ('An epe is not electable'||
         to_char(l_epe.elig_per_elctbl_chc_id),33);
         --
         open  c_pen;
         fetch c_pen into l_pen;
         --
         if c_pen%found then
           --
           l_pen_found := true;
           hr_utility.set_location('pen_id='||l_epe.prtt_enrt_rslt_id,1964);
           --
         else
           hr_utility.set_location('pen not found',1963);
         end if;
     --
         close c_pen;
         --
         if l_pen_found then
           --
           if ben_manage_life_events.fonm = 'Y' then
              ben_manage_life_events.g_fonm_cvg_strt_dt :=
                              l_epe.fonm_cvg_strt_dt;
           end if;

            ben_determine_coverage.main
            (p_elig_per_elctbl_chc_id => l_epe.elig_per_elctbl_chc_id
            ,p_effective_date         => p_effective_date
            ,p_lf_evt_ocrd_dt         => l_pil.lf_evt_ocrd_dt
            ,p_perform_rounding_flg   => true
            --
            ,p_enb_valrow             => l_enb_valrow
            ,p_calculate_only_mode    => TRUE
            );
            --
           if nvl(l_enb_valrow.val,0) <> nvl(l_pen.bnft_amt,0) then
              --
               open  c_enb;
               fetch c_enb into l_enb;
               close c_enb;
              --
              ben_election_information.election_information
               (p_elig_per_elctbl_chc_id => l_epe.elig_per_elctbl_chc_id,
                p_prtt_enrt_rslt_id      => l_epe.prtt_enrt_rslt_id,
                p_effective_date         => l_effective_date,
                p_enrt_mthd_cd           => l_pen.enrt_mthd_cd,
                p_enrt_bnft_id           => l_enb.enrt_bnft_id,
                p_bnft_val               => l_enb_valrow.val,
                p_prtt_rt_val_id1        => l_dummy_number,
                p_prtt_rt_val_id2        => l_dummy_number,
                p_prtt_rt_val_id3        => l_dummy_number,
                p_prtt_rt_val_id4        => l_dummy_number,
                p_prtt_rt_val_id5        => l_dummy_number,
                p_prtt_rt_val_id6        => l_dummy_number,
                p_prtt_rt_val_id7        => l_dummy_number,
                p_prtt_rt_val_id8        => l_dummy_number,
                p_prtt_rt_val_id9        => l_dummy_number,
                p_prtt_rt_val_id10       => l_dummy_number,
                p_pen_attribute_category =>  l_pen.pen_attribute_category,
                p_pen_attribute1         =>  l_pen.pen_attribute1,
                p_pen_attribute2         =>  l_pen.pen_attribute2,
                p_pen_attribute3         =>  l_pen.pen_attribute3,
                p_pen_attribute4         =>  l_pen.pen_attribute4,
                p_pen_attribute5         =>  l_pen.pen_attribute5,
                p_pen_attribute6         =>  l_pen.pen_attribute6,
                p_pen_attribute7         =>  l_pen.pen_attribute7,
                p_pen_attribute8         =>  l_pen.pen_attribute8,
                p_pen_attribute9         =>  l_pen.pen_attribute9,
                p_pen_attribute10        =>  l_pen.pen_attribute10,
                p_pen_attribute11        =>  l_pen.pen_attribute11,
                p_pen_attribute12        =>  l_pen.pen_attribute12,
                p_pen_attribute13        =>  l_pen.pen_attribute13,
                p_pen_attribute14        =>  l_pen.pen_attribute14,
                p_pen_attribute15        =>  l_pen.pen_attribute15,
                p_pen_attribute16        =>  l_pen.pen_attribute16,
                p_pen_attribute17        =>  l_pen.pen_attribute17,
                p_pen_attribute18        =>  l_pen.pen_attribute18,
                p_pen_attribute19        =>  l_pen.pen_attribute19,
                p_pen_attribute20        =>  l_pen.pen_attribute20,
                p_pen_attribute21        =>  l_pen.pen_attribute21,
                p_pen_attribute22        =>  l_pen.pen_attribute22,
                p_pen_attribute23        =>  l_pen.pen_attribute23,
                p_pen_attribute24        =>  l_pen.pen_attribute24,
                p_pen_attribute25        =>  l_pen.pen_attribute25,
                p_pen_attribute26        =>  l_pen.pen_attribute26,
                p_pen_attribute27        =>  l_pen.pen_attribute27,
                p_pen_attribute28        =>  l_pen.pen_attribute28,
                p_pen_attribute29        =>  l_pen.pen_attribute29,
                p_pen_attribute30        =>  l_pen.pen_attribute30,
                p_datetrack_mode         => hr_api.g_update,
                p_suspend_flag           => l_dummy_char,
                p_effective_start_date   => l_dummy_date,
                p_effective_end_date     => l_dummy_date,
                p_object_version_number  => l_pen.object_version_number,
                p_prtt_enrt_interim_id   => l_dummy_number,
                p_business_group_id      => p_business_group_id,
                p_dpnt_actn_warning      => l_dummy_bool,
                p_bnf_actn_warning       => l_dummy_bool,
                p_ctfn_actn_warning      => l_dummy_bool);

--Start Bug 5768795
	     if((not pgm_id_table.exists(l_pen.pgm_id)) and l_pen.pgm_id is not null)then
	         pgm_id_table(l_pen.pgm_id):=l_pen.pgm_id;
		 hr_utility.set_location('pgm_id_table(l_pen.pgm_id) ' ||pgm_id_table(l_pen.pgm_id),20);
	     end if;
--End Bug 5768795


               for l_ecr in c_ecr(l_epe.elig_per_elctbl_chc_id,
                                l_enb.enrt_bnft_id) loop

                   if ben_manage_life_events.fonm = 'Y' then
                      if l_ecr.rt_strt_dt_cd is null then
                         l_rt_strt_dt := l_ecr.rt_strt_dt;
                      end if;
                      --
                      -- derive new rt strt dt
                      --
                      if l_rt_strt_dt is null then
                         ben_determine_date.rate_and_coverage_dates
                         (p_which_dates_cd         => 'R'
                         ,p_date_mandatory_flag    => 'Y'
                         ,p_compute_dates_flag     => 'Y'
                         ,p_business_group_id      => p_business_group_id
                         ,p_per_in_ler_id          => l_pil.per_in_ler_id
                         ,p_person_id              => p_person_id
                         ,p_pgm_id                 => l_pen.pgm_id
                         ,p_pl_id                  => l_pen.pl_id
                         ,p_oipl_id                => l_pen.oipl_id
                         ,p_lee_rsn_id             => l_epe.lee_rsn_id
                         ,p_enrt_perd_id           => l_epe.enrt_perd_id
                         ,p_enrt_cvg_strt_dt       => l_dummy_date
                         ,p_enrt_cvg_strt_dt_cd    => l_dummy_char
                         ,p_enrt_cvg_strt_dt_rl    => l_dummy_number
                         ,p_rt_strt_dt             => l_rt_strt_dt
                         ,p_rt_strt_dt_cd          => l_rt_strt_dt_cd
                         ,p_rt_strt_dt_rl          => l_rt_strt_dt_rl
                         ,p_enrt_cvg_end_dt        => l_dummy_date
                         ,p_enrt_cvg_end_dt_cd     => l_dummy_char
                         ,p_enrt_cvg_end_dt_rl     => l_dummy_number
                         ,p_rt_end_dt              => l_dummy_date
                         ,p_rt_end_dt_cd           => l_dummy_char
                         ,p_rt_end_dt_rl           => l_dummy_number
                         ,p_effective_date         => p_effective_date
                         ,p_lf_evt_ocrd_dt         => nvl(l_pil.lf_evt_ocrd_dt,p_effective_date)
                            );
                      end if;

                      ben_manage_life_events.g_fonm_rt_strt_dt := l_rt_strt_dt;

                   end if;

                   l_flex_call := true;
                   ben_election_information.election_rate_information
                     (p_enrt_mthd_cd      => l_pen.enrt_mthd_cd
                     ,p_effective_date    => nvl(l_effective_date,p_effective_date)
                     ,p_prtt_enrt_rslt_id => l_epe.prtt_enrt_rslt_id
                     ,p_per_in_ler_id     => l_pil.per_in_ler_id
                     ,p_person_id         => p_person_id
                     ,p_pgm_id            => l_pen.pgm_id
                     ,p_pl_id             => l_pen.pl_id
                     ,p_oipl_id           => l_pen.oipl_id
                     ,p_enrt_rt_id        => l_ecr.enrt_rt_id
                     ,p_prtt_rt_val_id    => l_prtt_rt_val_id
                     ,p_rt_val            => l_ecr.val
                     ,p_ann_rt_val        => l_ecr.ann_val
                     ,p_enrt_cvg_strt_dt  => l_pen.enrt_cvg_strt_dt
                     ,p_acty_ref_perd_cd  => l_epe.acty_ref_perd_cd
                     ,p_datetrack_mode    => null
                     ,p_business_group_id => p_business_group_id
                     --
                     ,p_prv_rt_val        => l_dummy_number
                     ,p_prv_ann_rt_val    => l_dummy_number
                     );
                end loop;  -- c_ecr
            --
             end if;
          --
          end if;
          --
        end if;
        --
     end loop; -- c_epe3
     close c_epe3;
     -- canon fix
     hr_utility.set_location ('Before c_epe2 loop '||l_package,86);
     --
     l_pen_found         := false;
     --
     open  c_epe2(l_pil.per_in_ler_id);
     --
     loop
       --
       hr_utility.set_location ('In loop '||l_package,31);
       --
       fetch c_epe2 into l_epe;
       exit when c_epe2%notfound;
       hr_utility.set_location('Found an epe', 32);
       hr_utility.set_location('pl_id='||l_epe.pl_id,1964);
       hr_utility.set_location('GP oipl_id='||l_epe.oipl_id,1964);
       hr_utility.set_location('epe_id='||l_epe.elig_per_elctbl_chc_id,1964);
       hr_utility.set_location('pen_id='||l_epe.prtt_enrt_rslt_id,1964);
       l_pen_found         := false;
       l_enb_found         := false;
       l_prv_found         := false;
       l_enrt_cvg_strt_dt  := null;
       l_rt_strt_dt        := null;
       if l_epe.elctbl_flag = 'N' or p_mode = 'R' then
         --
         hr_utility.set_location ('An epe is not electable'||
         to_char(l_epe.elig_per_elctbl_chc_id),33);
         --
         open  c_pen;
         fetch c_pen into l_pen;
         --
         if c_pen%found then
           --
           l_pen_found := true;
           hr_utility.set_location('pen found',1964);
           hr_utility.set_location('pen_id='||l_epe.prtt_enrt_rslt_id,1964);
           --
         else
           hr_utility.set_location('pen not found',1963);
           hr_utility.set_location('pen_id='||l_epe.prtt_enrt_rslt_id,1963);
         end if;
     --
         close c_pen;
         --
         if l_pen_found then
           --
           hr_utility.set_location (l_package,40);
           --
           if ben_manage_life_events.fonm = 'Y' then
              ben_manage_life_events.g_fonm_cvg_strt_dt :=
                              l_epe.fonm_cvg_strt_dt;
           end if;

           open  c_enb;
           fetch c_enb into l_enb;
           --
           if c_enb%found then
             --
             l_enb_found := true;
           else
             --
             l_enb.enrt_bnft_id := null;
             --
           end if; --
           close c_enb;
           for l_ecr in c_ecr2(l_epe.elig_per_elctbl_chc_id,
                              l_enb.enrt_bnft_id) loop
               if ben_manage_life_events.fonm = 'Y' then
                  if l_ecr.rt_strt_dt_cd is null then
                     l_rt_strt_dt := l_ecr.rt_strt_dt;
                  end if;
                  --
                  -- derive new rt strt dt
                  --
                  if l_rt_strt_dt is null then
                     ben_determine_date.rate_and_coverage_dates
                     (p_which_dates_cd         => 'R'
                     ,p_date_mandatory_flag    => 'Y'
                     ,p_compute_dates_flag     => 'Y'
                     ,p_business_group_id      => p_business_group_id
                     ,p_per_in_ler_id          => l_pil.per_in_ler_id
                     ,p_person_id              => p_person_id
                     ,p_pgm_id                 => l_pen.pgm_id
                     ,p_pl_id                  => l_pen.pl_id
                     ,p_oipl_id                => l_pen.oipl_id
                     ,p_lee_rsn_id             => l_epe.lee_rsn_id
                     ,p_enrt_perd_id           => l_epe.enrt_perd_id
                     ,p_enrt_cvg_strt_dt       => l_dummy_date
                     ,p_enrt_cvg_strt_dt_cd    => l_dummy_char
                     ,p_enrt_cvg_strt_dt_rl    => l_dummy_number
                     ,p_rt_strt_dt             => l_rt_strt_dt
                     ,p_rt_strt_dt_cd          => l_rt_strt_dt_cd
                     ,p_rt_strt_dt_rl          => l_rt_strt_dt_rl
                     ,p_enrt_cvg_end_dt        => l_dummy_date
                     ,p_enrt_cvg_end_dt_cd     => l_dummy_char
                     ,p_enrt_cvg_end_dt_rl     => l_dummy_number
                     ,p_rt_end_dt              => l_dummy_date
                     ,p_rt_end_dt_cd           => l_dummy_char
                     ,p_rt_end_dt_rl           => l_dummy_number
                     ,p_effective_date         => p_effective_date
                     ,p_lf_evt_ocrd_dt         => nvl(l_pil.lf_evt_ocrd_dt,p_effective_date)
                        );
                  end if;

                  ben_manage_life_events.g_fonm_rt_strt_dt := l_rt_strt_dt;

               end if;

               l_flex_call := true;
               --
               ben_election_information.election_rate_information
                 (p_enrt_mthd_cd      => l_pen.enrt_mthd_cd
                 ,p_effective_date    => nvl(l_effective_date,p_effective_date)
                 ,p_prtt_enrt_rslt_id => l_pen.prtt_enrt_rslt_id
                 ,p_per_in_ler_id     => l_pil.per_in_ler_id
                 ,p_person_id         => p_person_id
                 ,p_pgm_id            => l_pen.pgm_id
                 ,p_pl_id             => l_pen.pl_id
                 ,p_oipl_id           => l_pen.oipl_id
                 ,p_enrt_rt_id        => l_ecr.enrt_rt_id
                 ,p_prtt_rt_val_id    => l_prtt_rt_val_id
                 ,p_rt_val            => l_ecr.val
                 ,p_ann_rt_val        => l_ecr.ann_val
                 ,p_enrt_cvg_strt_dt  => l_pen.enrt_cvg_strt_dt
                 ,p_acty_ref_perd_cd  => l_epe.acty_ref_perd_cd
                 ,p_datetrack_mode    => null
                 ,p_business_group_id => p_business_group_id
                 --
                 ,p_prv_rt_val        => l_dummy_number
                 ,p_prv_ann_rt_val    => l_dummy_number
                 );
            end loop;  -- c_ecr2
            --
          --
          end if;
          --
        end if;
        --
     end loop; -- c_epe2
     close c_epe2;
     --

--Start Bug 5768795

pgm_id_table_index := pgm_id_table.first;


if(pgm_id_table_index is not null) then

     loop

        ben_PRTT_ENRT_RESULT_api.chk_coverage_across_plan_types
		(p_person_id              =>p_person_id,
		 p_effective_date         =>p_effective_date,
		 p_lf_evt_ocrd_dt         =>p_lf_evt_ocrd_dt,
		 p_business_group_id      =>p_business_group_id,
		 p_pgm_id                 =>pgm_id_table(pgm_id_table_index),
		 p_minimum_check_flag     =>'N',
		 p_suspended_enrt_check_flag  =>'N');

	exit when pgm_id_table_index = pgm_id_table.last;

        pgm_id_table_index := pgm_id_table.next(pgm_id_table_index);
    end loop;

end if;

--End Bug 5768795

     if l_pen_found or l_flex_call then
        --
        open c_prtt_enrt (l_pen.pgm_id);
        fetch c_prtt_enrt into l_prtt_enrt_rslt_id_shell,l_enrt_perd_strt_dt ;
        close c_prtt_enrt;
        --Bug 3044116
        l_total_pools_eff_dt := l_effective_date ;
        --
        /*
        if l_enrt_perd_strt_dt > l_effective_date then
          l_total_pools_eff_dt := l_enrt_perd_strt_dt + 1 ;
        end if ;
        */
        --
        if l_prtt_enrt_rslt_id_shell is not null then
            ben_provider_pools.total_pools(
                                p_prtt_enrt_rslt_id => l_prtt_enrt_rslt_id_shell,
                                p_prtt_rt_val_id    => l_prtt_rt_val_id,
                                p_acty_ref_perd_cd  => l_acty_ref_perd_cd,
                                p_acty_base_rt_id   => l_acty_base_rt_id,
                                p_rt_strt_dt        => l_bpp_rt_strt_dt,
                                p_rt_val            => l_rt_val,
                                p_element_type_id   => l_element_type_id,
                                p_person_id         => p_person_id,
                                p_per_in_ler_id     => p_per_in_ler_id,
                                p_enrt_mthd_cd      => 'E' ,
                                p_effective_date    => l_total_pools_eff_dt, -- l_pil.lf_evt_ocrd_dt,
                                p_business_group_id => p_business_group_id,
                                p_pgm_id            => l_pen.pgm_id
                                );
              --
          end if;
          --
      end if;

     -- Bug#1969043
     if l_perform_imp = 'Y' then
        --
        open c_imputed_rslt;
        fetch c_imputed_rslt into l_start_date;
        close c_imputed_rslt;
        --
        if l_start_date is not null then
           if l_effective_date < l_start_date then
              l_effective_date := l_start_date ;
           end if;
        end if;
        --
        ben_det_imputed_income.p_comp_imputed_income
                (p_person_id            => p_person_id
                ,p_enrt_mthd_cd         => 'E'
                ,p_per_in_ler_id        => l_pil.per_in_ler_id
                ,p_effective_date       => l_effective_date
                ,p_business_group_id    => p_business_group_id
                ,p_ctrlm_fido_call      => false
                ,p_validate             => false);
        --
     end if;
     --
     hr_utility.set_location ('Leaving '||l_package,10);
     --
   end main;
--
procedure prv_delete(p_prtt_rt_val_id in number ,
                     p_enrt_rt_id in number,
                     p_rt_val in number,
                     p_rt_strt_dt in date,
                     p_business_group_id in number,
                     p_prtt_enrt_rslt_id in number,
                     p_person_id         in number,
                     p_effective_date    in date,
                     p_mode              in varchar2 default 'NEW'
) is
 --
 l_object_version_number number;
 l_acty_base_rt_id number ;
 cursor c_prv is
   select
     prv.rt_val,
     prv.rt_strt_dt,
     prv.object_version_number
   from ben_prtt_rt_val prv
     where prv.prtt_rt_val_id = p_prtt_rt_val_id and
           prv.business_group_id = p_business_group_id and
           prv.prtt_rt_val_stat_cd is null
           ;
 --
 l_prv c_prv%rowtype;
 --
 cursor c_prv_future is
   select
       prv.*
   from ben_prtt_rt_val prv
     where prv.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id and
           prv.business_group_id = p_business_group_id and
           prv.acty_base_rt_id = l_acty_base_rt_id and
           prv.prtt_rt_val_stat_cd is null
     order by prv.rt_strt_dt desc
           ;
 --
 cursor c_prv_past is
   select
       prv.*
   from ben_prtt_rt_val prv
     where prv.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id and
           prv.rt_end_dt = (l_prv.rt_strt_dt -1)  and
           prv.business_group_id = p_business_group_id and
           prv.acty_base_rt_id = l_acty_base_rt_id and
           prv.prtt_rt_val_stat_cd is null
     order by prv.rt_end_dt desc
           ;
  --
  cursor c_ecr is
    select
      ecr.*
    from ben_enrt_rt ecr
    where ecr.enrt_rt_id = p_enrt_rt_id and
    ecr.business_group_id = p_business_group_id ;
  --
  cursor c_abr is
    select
         abr.*,
         py.processing_type
    from ben_acty_base_rt_f abr,
         pay_element_types_f py
    where
        abr.acty_base_rt_id = l_acty_base_rt_id
    and abr.business_group_id = p_business_group_id
    and p_effective_date between
        abr.effective_start_date and abr.effective_end_date
    and abr.element_type_id = py.element_type_id(+)
    and p_effective_date between
        py.effective_start_date(+) and py.effective_end_date(+);

  --
  l_prv_future c_prv_future%rowtype;
  l_ecr c_ecr%rowtype;
  l_abr c_abr%rowtype;
  l_delete  boolean := false;
  l_update_prtt boolean := false;
  --
begin
 --
 open c_prv ;
 fetch c_prv into l_prv ;
 close c_prv;
 --
 open c_ecr ;
 fetch c_ecr into l_ecr;
 close c_ecr ;
 l_acty_base_rt_id := l_ecr.acty_base_rt_id;
 --

 if l_prv.rt_strt_dt < p_rt_strt_dt  and p_mode = 'UPD' then
        ben_prtt_rt_val_api.delete_prtt_rt_val
           (p_prtt_rt_val_id                 =>  p_prtt_rt_val_id
            ,p_person_id                     => p_person_id
            ,p_business_group_id             => p_business_group_id
            ,p_object_version_number         => l_prv.object_version_number
            ,p_effective_date                => p_effective_date
            );
      --
      update ben_enrt_rt ecr
      set prtt_rt_val_id = null
      where enrt_rt_id = p_enrt_rt_id ;
      --
 elsif l_prv.rt_strt_dt < p_rt_strt_dt  and p_mode = 'NEW' then
      -- do nothing
      null;
      --
 elsif l_prv.rt_strt_dt > p_rt_strt_dt then
    --
    open c_abr ;
    fetch c_abr into l_abr;
    close c_abr;
    --
    open c_prv_future ;
    loop
    fetch c_prv_future into l_prv_future ;
    if c_prv_future%notfound
    then
        exit ;
    end if;
    --
    if l_prv_future.rt_strt_dt > p_rt_strt_dt then
        --
        ben_prtt_rt_val_api.delete_prtt_rt_val
          (p_prtt_rt_val_id                 =>  l_prv_future.prtt_rt_val_id
          ,p_person_id                     => p_person_id
          ,p_business_group_id             => p_business_group_id
          ,p_object_version_number         => l_prv_future.object_version_number
          ,p_effective_date                => p_effective_date
          );
        --
        l_delete := true;
        --
    elsif l_delete then  -- if l_prv_future.rt_val <> p_rt_val then
         --
    /*
         update ben_enrt_rt ecr
         set prtt_rt_val_id = null -- l_prv_future.prtt_rt_val_id
         where enrt_rt_id = p_enrt_rt_id ;
    */
      if l_abr.processing_type = 'N' or
         l_abr.rcrrg_cd = 'ONCE' then
        -- do nothing for non recurring rate
          null;
      else

         ben_prtt_rt_val_api.update_prtt_rt_val(
             p_validate            => FALSE
             ,p_prtt_rt_val_id     => l_prv_future.prtt_rt_val_id
             ,p_person_id          => p_person_id
             ,p_input_value_id     => l_abr.input_value_id
             ,p_element_type_id    => l_abr.element_type_id
             ,p_enrt_rt_id         => l_ecr.enrt_rt_id
             ,p_rt_strt_dt         => l_prv_future.rt_strt_dt
             ,p_rt_end_dt          => p_rt_strt_dt-1
             ,p_rt_typ_cd          => l_prv_future.rt_typ_cd
             ,p_tx_typ_cd          => l_prv_future.tx_typ_cd
             ,p_acty_typ_cd        => l_abr.acty_typ_cd
             ,p_mlt_cd             => l_prv_future.mlt_cd
             ,p_acty_ref_perd_cd   => l_prv_future.acty_ref_perd_cd
             ,p_rt_val             => l_prv_future.rt_val
             ,p_ann_rt_val         => l_prv_future.ann_rt_val
             ,p_cmcd_rt_val        => l_prv_future.cmcd_rt_val
             ,p_cmcd_ref_perd_cd   => l_prv_future.cmcd_ref_perd_cd
             ,p_bnft_rt_typ_cd     => l_prv_future.bnft_rt_typ_cd
             ,p_dsply_on_enrt_flag => l_prv_future.dsply_on_enrt_flag
             ,p_rt_ovridn_flag     => l_prv_future.rt_ovridn_flag
             ,p_rt_ovridn_thru_dt  => l_prv_future.rt_ovridn_thru_dt
             ,p_elctns_made_dt     => l_prv_future.elctns_made_dt
             ,p_prtt_rt_val_stat_cd => l_prv_future.prtt_rt_val_stat_cd
             ,p_prtt_enrt_rslt_id  => l_prv_future.prtt_enrt_rslt_id
             ,p_cvg_amt_calc_mthd_id  => l_prv_future.cvg_amt_calc_mthd_id
             ,p_actl_prem_id       => l_prv_future.actl_prem_id
             ,p_comp_lvl_fctr_id   => l_prv_future.comp_lvl_fctr_id
             ,p_element_entry_value_id     => l_prv_future.element_entry_value_id
             ,p_per_in_ler_id     => l_prv_future.per_in_ler_id
             ,p_ended_per_in_ler_id     => l_prv_future.ended_per_in_ler_id
             ,p_acty_base_rt_id     => l_prv_future.acty_base_rt_id
             ,p_prtt_reimbmt_rqst_id     => l_prv_future.prtt_reimbmt_rqst_id
             ,p_business_group_id     => l_prv_future.business_group_id
             ,p_prv_attribute_category => l_prv_future.prv_attribute_category
             ,p_prv_attribute1     => l_prv_future.prv_attribute1
             ,p_prv_attribute2     => l_prv_future.prv_attribute2
             ,p_prv_attribute3     => l_prv_future.prv_attribute3
             ,p_prv_attribute4     => l_prv_future.prv_attribute4
             ,p_prv_attribute5     => l_prv_future.prv_attribute5
             ,p_prv_attribute6     => l_prv_future.prv_attribute6
             ,p_prv_attribute7     => l_prv_future.prv_attribute7
             ,p_prv_attribute8     => l_prv_future.prv_attribute8
             ,p_prv_attribute9     => l_prv_future.prv_attribute9
             ,p_prv_attribute10     => l_prv_future.prv_attribute10
             ,p_prv_attribute11     => l_prv_future.prv_attribute11
             ,p_prv_attribute12     => l_prv_future.prv_attribute12
             ,p_prv_attribute13     => l_prv_future.prv_attribute13
             ,p_prv_attribute14     => l_prv_future.prv_attribute14
             ,p_prv_attribute15     => l_prv_future.prv_attribute15
             ,p_prv_attribute16     => l_prv_future.prv_attribute16
             ,p_prv_attribute17     => l_prv_future.prv_attribute17
             ,p_prv_attribute18     => l_prv_future.prv_attribute18
             ,p_prv_attribute19     => l_prv_future.prv_attribute19
             ,p_prv_attribute20     => l_prv_future.prv_attribute20
             ,p_prv_attribute21     => l_prv_future.prv_attribute21
             ,p_prv_attribute22     => l_prv_future.prv_attribute22
             ,p_prv_attribute23     => l_prv_future.prv_attribute23
             ,p_prv_attribute24     => l_prv_future.prv_attribute24
             ,p_prv_attribute25     => l_prv_future.prv_attribute25
             ,p_prv_attribute26     => l_prv_future.prv_attribute26
             ,p_prv_attribute27     => l_prv_future.prv_attribute27
             ,p_prv_attribute28     => l_prv_future.prv_attribute28
             ,p_prv_attribute29     => l_prv_future.prv_attribute29
             ,p_prv_attribute30     => l_prv_future.prv_attribute30
             ,p_object_version_number     => l_prv_future.object_version_number
             ,p_effective_date     => p_effective_date
          );
          --
          exit;
          --
        end if;
      end if;
        --
    end loop;
    --
    if l_delete then
       --
       update ben_enrt_rt ecr
       set prtt_rt_val_id = null -- l_prv_future.prtt_rt_val_id
       where enrt_rt_id = p_enrt_rt_id ;
      --
    end if;

    close c_prv_future ;
    --
 end if ;
  --
end prv_delete;
--
--
-- This is a wrapper to get rt_end_dt_cd and rt_srt_dt_cd from forms.
--
procedure get_rate_codes
          (p_business_group_id      in number
          ,p_elig_per_elctbl_chc_id in number
          ,p_rt_strt_dt_cd          out nocopy varchar2
          ,p_rt_end_dt_cd           out nocopy varchar2
          ,p_acty_base_rt_id        in number
          ,p_effective_date         in date) is
  --
  l_dummy_var     varchar2(30);
  l_dummy_date    date;
  l_dummy_number  number;
  --
begin
  --
  ben_determine_date.rate_and_coverage_dates
          (p_which_dates_cd         => 'R'
          ,p_compute_dates_flag     => 'N'
          ,p_business_group_id      => p_business_group_id
          ,p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id
          ,p_enrt_cvg_strt_dt       => l_dummy_date
          ,p_enrt_cvg_strt_dt_cd    => l_dummy_var
          ,p_enrt_cvg_strt_dt_rl    => l_dummy_var
          ,p_rt_strt_dt             => l_dummy_date
          ,p_rt_strt_dt_cd          => p_rt_strt_dt_cd
          ,p_rt_strt_dt_rl          => l_dummy_var
          ,p_enrt_cvg_end_dt        => l_dummy_date
          ,p_enrt_cvg_end_dt_cd     => l_dummy_var
          ,p_enrt_cvg_end_dt_rl     => l_dummy_var
          ,p_rt_end_dt              => l_dummy_date
          ,p_rt_end_dt_cd           => p_rt_end_dt_cd
          ,p_rt_end_dt_rl           => l_dummy_var
          ,p_acty_base_rt_id        => p_acty_base_rt_id
          ,p_effective_date         => p_effective_date);
  --
end get_rate_codes;
--
Function Determine_change_in_flex
         (p_prtt_enrt_rslt_id number,
          p_per_in_ler_id     number,
          p_effective_date    date)
          return boolean is
  --
  cursor c_prvdd_val is
    select bpl.acty_base_rt_id,
           bpl.bnft_prvdr_pool_id,
           bpl.prvdd_val,
           bpl.business_group_id,
           pil.person_id
    from   ben_bnft_prvdd_ldgr_f bpl,
           ben_per_in_ler  pil
    where  bpl.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
    and    bpl.prvdd_val is not null
    and    bpl.effective_end_date = hr_api.g_eot
    and    bpl.per_in_ler_id = pil.per_in_ler_id
    and    pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT');
  --
  cursor  c_new_cr_val (p_acty_base_rt_id number,
                        p_bnft_prvdr_pool_id number) is
    select ecr.val,
           ecr.elig_per_elctbl_chc_id
    from ben_enrt_rt ecr
    where ecr.acty_base_rt_id = p_acty_base_rt_id
    and   ecr.elig_per_elctbl_chc_id in
                (select
                 epe.elig_per_elctbl_chc_id
                 from ben_elig_per_elctbl_chc epe, ben_BNFT_PRVDR_POOL_f bpl,
                      ben_acty_base_rt_f abr
                 where epe.BNFT_PRVDR_POOL_ID = p_bnft_prvdr_pool_id
                 and   epe.bnft_prvdr_pool_id = bpl.bnft_prvdr_pool_id
		 and   p_effective_date between bpl.effective_start_date and
                                                 bpl.effective_end_date
                 and   epe.per_in_ler_id = p_per_in_ler_id
                 and   abr.acty_base_rt_id = p_acty_base_rt_id
                 and   (abr.pgm_id = epe.pgm_id or
                        abr.pl_id  = epe.pl_id  or
                        abr.plip_id = epe.plip_id or
                        abr.ptip_id = epe.ptip_id or
                        abr.OIPLIP_ID = epe.OIPLIP_ID or
                        abr.CMBN_PTIP_ID = epe.CMBN_PTIP_ID or
                        abr.CMBN_PTIP_OPT_ID = epe.CMBN_PTIP_OPT_ID or
                        abr.CMBN_PLIP_ID     = epe.CMBN_PLIP_ID)
                 and    p_effective_date between abr.effective_start_date and
                                                 abr.effective_end_date);
--
  l_new_cr_val     c_new_cr_val%rowtype;
  l_prvdd_val      c_prvdd_val%rowtype;
  l_return         boolean := false;
--
Begin
 --
 open c_prvdd_val;
 loop
   fetch c_prvdd_val into l_prvdd_val;
   if c_prvdd_val%notfound then
      exit;
   end if;
   --
   hr_utility.set_location ('Provided Val'||l_prvdd_val.prvdd_val,10);
   hr_utility.set_location ('Acty base Rt'||l_prvdd_val.acty_base_rt_id,11);
   open c_new_cr_val (p_acty_base_rt_id =>l_prvdd_val.acty_base_rt_id,
                      p_bnft_prvdr_pool_id =>l_prvdd_val.bnft_prvdr_pool_id);
   loop
   fetch c_new_cr_val into l_new_cr_val;
   if c_new_cr_val%found then
      --
      if l_prvdd_val.prvdd_val <> l_new_cr_val.val then
         l_return := true;
         --
         ben_provider_pools.create_credit_ledger_entry
                 ( p_person_id               => l_prvdd_val.person_id  ,
                   p_elig_per_elctbl_chc_id  => l_new_cr_val.elig_per_elctbl_chc_id ,
                   p_per_in_ler_id           => p_per_in_ler_id,
                   p_business_group_id       => l_prvdd_val.business_group_id ,
                   p_bnft_prvdr_pool_id      => l_prvdd_val.bnft_prvdr_pool_id,
                   p_enrt_mthd_cd            => 'E',
                   p_effective_date          => p_effective_date );
      end if;
   else
       exit ;
   end if;
   end loop;
   close c_new_cr_val;
 end loop;
 close c_prvdd_val;
 return l_return;

End  Determine_change_in_flex;

end ben_determine_rate_chg;

/
