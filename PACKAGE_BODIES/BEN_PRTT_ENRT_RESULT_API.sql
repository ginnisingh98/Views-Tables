--------------------------------------------------------
--  DDL for Package Body BEN_PRTT_ENRT_RESULT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PRTT_ENRT_RESULT_API" as
/* $Header: bepenapi.pkb 120.65.12010000.27 2010/03/03 11:32:29 sallumwa ship $ */
--
/* ============================================================================
  File Information
  ================
  This file was originally copied from the bpapiskl.pkb file.
  Skeleton Version: 40.3
  --------------------------------------------------------------------------
  Change List
  ===========
  Version Date        Author         Comment
  -------+-----------+--------------+---------------------------------------
  110.0   May 27 98   Hugh Dang      initial created
  110.1   Jun 04 98   Hugh Dang      add columns
  110.6   Jun 16 98   Hugh Dang      Add Messages call and fixed cvg end dt.
  110.7   Jun 17 98   Hugh Dang      Un-comment Element Entry procedure call.
  110.7   Jun 17 98   Hugh Dang      comment Element Entry procedure call.
                                     and change rate end date to end of time.
  110.8   Jun 17 98   Hugh Dang      Add Create_credit_ledger_entry.
  110.9   Jun 23 98   Hugh Dang      Remove Dpnt coverage end date check.
  110.11  Jun 26 98   jcarpent       Replaced create_credit_ledger_entry with
                                     accumulate_pools
  110.12  Jul 22 98   Hugh Dang      Add prtt_resulst OVN in/out parmater to
                                     determine action item call.
  110.13  Jul 22 98   Hugh dang      Add p_multi_row_actn in ben_elig_cvrd_
                                     dpnt_api.update_elig_cvrd_dpnt and
                                     ben_plan_beneficiary_api.delete_plan_
                                     beneficiary
  110.14  Sep 25 98   bbulusu        Added out nocopy parameters (warnings) to create
                                     _enrollment and in the call to determine_
                                     action_items.
  115.11  Oct-02-98   Hugh Dang      Remove Rt_strt_dt, Rt_end_dt,
                                     enrld_cvrd_flag and Change BNFT_UOM
                                     to UOM.
                                     * Change Create/Delete enrollment logic.
  115.11  Oct-13-98   Hugh Dang      Make Enrt_bnft_id as default parameters.
  115.12  Oct 13 1998 Hugh Dang      Make enrt_cvg_thru_dt default to eot
                                     instead of NULL
  115.14  Oct 19 98   bbulusu        added p_new_enrt_rslt_ovn in the call to
                                     ben_mng_dpnt_bnf.recycle_dpnt_bnf
  115.15  Oct 21 98   Hugh Dang      Add business_group_id for all dpnt api.
  115.16  Oct 21 98   Siok Tee       Call Manage Primary care provider if plan
                                     has not changed but oipl changes.
  115.17  Oct 25 98   Jon Carpenter  Added call to rate_and_coverage_dates
                                     Removed get_rate_and_cvg_start_end_date
  115.18  Oct 26 98   Hugh Dang      Add p_per_in_ler_id, p_enrt_perd_id,
                                     p_lee_rsn_id in delete enrollment and
                                     make sure if electable choice is not passed
                                     then above infor. need to passed.
  115.19  Oct 29 98   Graham Perry   Added in datetrack check for update_
                                     enrollment, switches mode to correction
                                     if needed.
  115.20  Oct 29 98   lmcdonal       Added new parms to call to delete prtt rt
                                     val.
  115.21  Oct 30 98   Hugh Dang      Added new parms to call to update prtt
                                     rt val.set post_rslt_flag to multi_row_
                                     edit flag.
  115.22  Oct 31 98   bbulusu        Modified unhook_bnf procedure to zap all
                                     bnf's when zapping enrt rslt. Siok fixed
                                     the c_pen cursor in delete_enrollment.
  115.23  Nov 01 98   Hdang          Change logic on per_in_ler_id on delete
                                     enrollment and Change C_pen cursor to
                                     eliminate duplicate Electable choice.
  115.24  Nov 02 98   Hdang          Add business group id parms for update_prtt
                                     rt_val.
  115.26  Nov 04 98   Hdang          add l_elig_per_elctbl_chc_id to make the
                                     the per_in_ler for cursor is current.
  115.27  Nov 04 98   Hdang          Change C_prv cursor to eliminate others
                                     outer join.
  115.28  Nov 05 98   Hdang          Change update enrollment's compare oipl
                                     from equal to not equal
  115.29  Nov 10 98   Hdang       - Add call to delete ben_pl_bnf_ctfn api
                                    to remove children before call prtt_actn
                                    items.
                                  - Add logic to handle Saving plan.
                                    Zap enrollments elected today and delete
                                    same day.
  115.30  Dec 07 1998 Hdang         Add parameter into multi-row edit to
                                    handle last year enrollment but not
                                    default current year.
  115.31  Dec 10 1998 Hdang         modify the c_prv to eliminate duplicate
                                    row cause by multi-row ben_enrt_rt.
  115.32  Dec 11 1998 lmcdonal      When deleting rows in multi-row, join to
                                    choice table.
  115.33  Dec 15 1998 pxdas         Added Code for logging change event
  115.34  Dec 16 1998 pxdas         Modified Change_exists_in_db procedure
  115.35  Dec 16 1998 Hdang         Add person_id and pgm_id to limit the fetch
                                    and fix the c_prv cursor.
  115.36  Dec 28 1998 Stee          Fix cursor to zap beneficiaries in delete
                                    enrollment.
  115.37  Dec 28 1998 Hdang         Remove per_in_ler check and pass per_in_ler
                                    for all dependent procedure.
  115.38  Dec 28 1998 Hdang         Remove per_in_ler_id from update_prtt_rt_val.
  115.39  Dec 29 1998 pxdas         Modified Create_Change_Log procedure
  115.40  Dec 29 1998 lmcdonal      Because p_suspend_flag is an out, not an
                                    in/out we have to always set it.  It is
                                    usually set when calling the action_item
                                    proc, but when that proc is not called, we
                                    must set the flag.
  115.41  Jan 01 1999 pxdas         Modified effective date when calling
                                    Create_Change_Log procedure
  115.42  Jan 04 1999 Hdang         C_pil%notfound check.
  115.43  Jan 12 1999 maagrawa      p_acty_base_rt_id removed from call to
                                    delete_prtt_rt_val.
  115.44  Jan 21 1999 Hdang         Avoid de-enrolled any enrollmente which has
                                    the earliest de-enrollment date has not been
                                    reached.
  115.45  Jan 26 1999 Hdang       * Remove mandatory check in delete enrollment.
                                  * Change SVG_PL_FLAG to ENRT_PL_OPT_FLAG for
                                    Create_enrollment to determine if
                                    "Determine action item" need to be called.
  115.46  Jan 30 1999 Yrathman      Add no_lngr_elig_flag column
                                    Modify delete_enrollment to assign cvg end date
                                    1 day prior to new cvg start date, if found.
                                    Modify multi_rows_edit to delete enrollments
                                    no longer eligible for if elections were made
                                    for program or plan type.
  115.47  Feb 04 1999 jcarpent      Added ended_per_in_ler_id to update_prv.
  115.48  Feb 18 1999 Hdang         Fixed cursor for remove old enrollments
                                    which pick up all plan not in program.
  115.49  Feb 24 1999 Yrathman      Added bnft_ordr_num, prtt_enrt_rslt_stat_cd column
  115.50  Mar 03 1999 jcarpent      Removed dbms_output.put_lines
  115.51  Mar 04 1999 jcarpent      Populate p_prtt_enrt_interim_id out nocopy parm
  115.52  Mar 10 1999 T Mathers
  115.53  Mar 29 1999 T Hayden      Added calls to ben_ext_chlg,
                                    Added parameter p_source,
                                    Removed old way of writing to chg log.
  115.54  Apr 15 1999 mhoyes        Un datetracked per in ler
  115.55  Apr 16 1999 jcarpent      Removed update to choice of crntly_enrd.
  115.56  Apr 24 1999 lmcdonal      prtt-rt-val has a status code now.  Added
                                    override condition to multi row c1 cursors.
                                    prtt_enrt_rslt also has status code.
  115.57  May 02 1999 maagrawa      Added condition in multi row c1 cursors,
                                    to exclude flex and imputed income plans.
  115.58  May 03 1999 TGUY          Added condition in multi to check for overall
                                    min/max cvg across ptip.
  115.59  May 10, 1999 lmcdonal     Add void_enrollment procedure.
                                    Changes to delete_enrollment:
                                     1.Modify c_prv cursor so that it gets
                                       rates even if tied to a bnft, not a chc.
                                     2.Remove c_rt cursor and it's use.
                                     3.Case 1 no longer zaps rows but instead
                                       marks the rows as voided.
                                     4.Since only case 3 and 4 delete, removed
                                       the use of the delete_flag.
                                     5.on insert, do not load choice fk to rslt
                                       if rslt is void or backed out.
  115.60  May 13, 1999 jcarpent     Check ('VOIDD', 'BCKDT') for pil stat cd
  115.61  May 19, 1999 lmcdonal     Added parm to create_enrollment to trigger
                                    which save point to set and rollback.
                                    Also changed c_interim_enrt per Jon.
  115.62  May 20, 1999 jcarpent     Changed c_interim_enrt p_pen_id=>l_pen_id
  115.63  May 25, 1999 maagrawa     Fixed c_prv cursor to fetch enrt_rt
                                    records for the current choice, if
                                    it exists.
  115.64  Jun 03, 1999 tmathers     Leapfrog of 115.60 incorporating cursor
                                    change from 115.63
  115.65  Jun 03, 1999 tmathers     Leapfrog of 115.63
  115.66  Jun 04  1999 lmcdonal     added comp_lvl_cd.
  115.67  Jun 14  1999 tguy         fixed cursor c_prtt_total_bnft_amt.
  115.68  Jun 14  1999 tguy         fixed cursor c_prtt_total_bnft_amt to
                                    look at table and not a view.
  115.69  Jul 1   1999 tguy         added prtt_prem_f creating, update and
                                    deleting.  Also deals with deleting child
                                    records.
  115.70  Jul 2   1999 stee         Add an edit for COBRA to not allow a
                                    person to be covered in the same
                                    plan as a dependent.
  115.71  Jul 7   1999 jcarpent     Add pil_id to most ben_prtt_prem_api calls
  115.72  Jul 9   1999 jcarpent     Added checks for backed out nocopy pil
  115.73  Jul 14  1999 jcarpent     close c_check_cvrd_in_plan moved to fix
                                    invalid cursor error.
  115.74  Jul 14  1999 stee         Fix delete_enrollment to check for a
                                    correctly check for a null per_in_ler id.
                                    bug #1885.
  115.75  Jul 23  1999 tguy         fixed creating/update/delete prtt_prem_f
                                    issues.
  115.76  Jul 28  1999 jcarpent     Commented out nocopy code in create_enrollment
                                    which checked for update condition, will
                                    no longer do an update, always a create.
  115.77  Aug 06  1999 isen         Added new and old values for extract change log
  115.78  Aug 10, 1999 lmcdonal     Leapfrog version 75 with fix listed in 79.
  115.79  Aug 10, 1999 lmcdonal     Modify delete_enrollment, case 2.  It was trying
                                    to call update_prtt_prem/by_mo in delete mode.
                                    Since rslt is being updated for case2, the
                                    prem process will pick up the change, no need to
                                    do anything here.  Bug 3061.
  115.80 Aug 10, 1999 lmcdonal      uncomment exit, remove ctrl-M's.
  115.81 Aug 23, 1999 maagrawa      add premium_warning(lmcdonal)
                                    In Delete-result, remove call to delete
                                    prtt-ctfns because they are deleted as part
                                    of call to delete-prtt-actions.(lmcdonal)
                                    Made Changes related to breaking of
                                    dependents table. (maagrawa)
  115.82 Aug 23, 1999 shdas         added pl_ordr_num,plip_ordr_num,
                                    ptip_ordr_num, oipl_ordr_num.
  115.83 Sep 02, 1999 maagrawa      Added HIPAA communications.
  115.84 Sep 29, 1999 isen          Modified calls to log_benefit_chg
  115.85 Oct 02 ,1999 stee          Change COBRA program type selection
                                    to use 'COBRA%'instead of 'COBRA'
  115.86 Oct 13 ,1999 lmcdonal      Attempt to copy dpnts more freely - not
                                    just if new rslt is written over old result.
                                    Call recycle_dpnts in multi-row when non-
                                    elected results are about to be deleted.
  115.87 Oct 20, 1999 lmcdonal      If the result being created is the
                                    dummy flex or imputed income plan, do not
                                    create ledgers (don't call accumulate pools).
  115.88 Oct 29, 1999 lmcdonal      Edit check the datetrack mode before updating
                                    premiums in step 72.
  115.89 Oct 29, 1999 maagrawa      By-pass the erlst_deenrt_dt check in delete
                                    enrollment, when calling from beninelg.
  115.90 12-Nov-99  lmcdonal        Better debugging messages.
  115.91 30-Nov-99  jcarpent      - replace datetrack strings with globals
                                    update_override was spelled with 1 r. b3846
                                  - Pass enrt_bnft_id to void enrollment.
  115.92 01-Dec-99  lmcdonal        When automatically de-enrolling prtt from
                                    results that are choices but the prtt did
                                    not choose them, only deenroll from choices
                                    with elctbl_flag = 'Y'.
  115.93 03-Dec-99  jcarpent      - Changed c_prv cursors to eliminate dups
  115.94 16-Dec-99  jcarpent      - Create enrt - call action items more often
                                  - Fix acrs_ptip to actually check ptip enrts
  115.95 20-Dec-99  maagrawa        Do not call manage_enrt_bnft when called
                                    from election_information (benelinf).
  115.96 30-Dec-99  jcarpent      - Changed strtd to not in voidd bckdt n c_epe
                                    Fixed 91902 message name so error shows.
  115.97 11-Jan-00  jcarpent      - Changed how erlst_deenrt_dt is checked.
  115.98 13-Jan-00  maagrawa      - Removed HIPAA Communications. Now called
                                    from close enrollment.
  115.99 18-Jan-00  shdas           Added calls to remove_bnft_prvdd_ldgr in
                                    first case of delete enrollment.
 115.100 19-Jan-00  lmcdonal        Bug 1132739.  Cases where a date-track delete
                                    was being done on a row where the eed of the
                                    row = the eff dt of the dt-delete.
 115.101 25-Jan-00  thayden       - Changed existing calls to Change event log,
                                    and added new calls to it, mostly in the
                                    delete and void enrollment areas.
 115.102 27-Jan-00  thayden       - Pass end cvg thru date when creating chg log.
 115.103 08-Feb-00  lmcdonal        Bug 1166174.  We need to re-calc certain
                                    premiums after save of enrollment.
 115.104 08-Feb-00  lmcdonal        Bug 1169607 - chg to delete-enrollment
                                    so that rows will be end-dated.
 115.105 08-Feb-00  maagrawa        Delete the interim coverage when the
                                    suspended result is deleted.(1173011)
 115.106 11-Feb-00  maagrawa        Do not issue the savepoint delete_enrollment
                                    in procedure delete_enrollment when calling
                                    itself to delete interim coverage.
 115.107 17-Feb-00  jcarpent      - Fixed unhook dpnt bug 4715
                                  - Fix result not found error in recalc_prem
 115.108 17-Feb-00  thayden       - Fix date passed into log_benefit_chg.
 115.109 25-Feb-00  jcarpent      - If delete_enrollment called from benuneai
                                    don't delete interim.
 115.110 26-Feb-00  maagrawa      - Call action item routine from
                                    update_enrollment. (1211553)
                                  - Added parameters dpnt_actn_warning and
                                    bnf_actn_warning to update_enrollment.
 115.111 28-Feb-00  maagrawa      - Delete interim enrollment only when called
                                    from enrollment forms and from
                                    election_information in delete_enrollment.
 115.112 29-Feb-00  gperry          Fixed caching problem when calling elig
                                    dpnt api since business group id wasn't
                                    being passed.
 115.113 01-Mar-00  stee            Added check for backed out nocopy result in
                                    COBRA edit.
 115.114 02-Mar-00  bbulusu         Incorrect dt mode being
                                    passed to update_prtt_prem
 115.115 03-Mar-00  shdas           modify determine_dpnt_cvg_dt_cd(4280)
 115.116 04-Mar-00  pbodla        - Bug 4822 :Check for min/max across ptip
                                    is moved, called after delete enrollment.
 115.117 05-Mar-00  jcarpent      - Bug 4783 :changed c_prv2 cursor.
 115.118 10-Mar-00  jcarpent      - Bug 4839 :handle create of prtt_prem
 115.119 31-Mar-00  maagrawa      - Datetrack delete premium rows if they are
                                    not end-dated in delete_enrollment. (4924)
 115.120 05-Apr-00  lmcdonal        Bug 1253007.  Using globals for epe, pil,
                                    pel, pen, enb, asg data for performance.
 115.121 05-Apr-00  shdas           Bug 4444--changed get_election_date to
                                    consider per_in_ler_id while updating
                                    enrollment result.
 115.122 06-Apr-00  stee            Remove per_in_ler_id from get_election_date
                                    as enrollment results are voided when
                                    a person is found newly ineligible.
 115.123 07-Apr-00  lmcdonal        Call to clear_pen.
 115.124 11-Apr-00  shdas           changed get_election_date to add 2 out nocopy parameters
                                    to decide when to void an enrollment(4444).
 115.125 14-Apr-00  jcarpent        Refresh pen cache after action items calls
                                    bug 5083
 115.126 19-Apr-00  maagrawa        Do not delete the interim coverage when it
                                    is used by some other result also.(1274214)
 115.127 24-Apr-00  gperry          Fixed Internal Bug 4924.
 115.128 25-Apr-00  maagrawa        Fidelity P1(1278255): Cursor c_prv2 fixed.
                                    Delete rates which are not end-dated
                                    i.e. rate end date is end of time (eot).
 115.129 26-Apr-00  jcarpent        Fixed dt_mode for update of elig_cvrd_dpnt
                                    in unhook_dpnts. (4938)
 115.130 01-May-00  shdas           added effective date adjustment in delete enrolment
                                    when coverage has not started and source is benelinf(5129)
 115.131 02-May-00  jcarpent        Removed check for pel.elcns_made_dt or
                                    pel.dflt_asnd_dt from no_lngr_elig_pnip_c.
                                    From Clenr order of calls was
                                    multi_rows_edit, post_results..., then
                                    post enrt so dflt_asnd_dt was not yet set.
 115.132 02-May-00  jcarpent        bug # for above change is 5020.
 115.133 12-May-00  lmcdonal        Leapfrog of 128 with fix in 134 for
                                    Fido P1 1299007.
 115.134 12-May-00  lmcdonal        Added actl_prem_id to c_ppe cursor.
 115.135 13-May-00  lmcdonal        Bug 1298802: re-open dpnt records for result
                                    more often.
 115.136 15-May-00  jcarpent        Recycle dependents when ptip enrollment was
                                    ended by benmngle.  (4981/1259094)
 115.137 14-jun-00  jcarpent        p2 bug 1311768, handle 1 prior rt_end_dt.
                                    based on 115.133.
 115.138 14-jun-00  jcarpent        Leapfrog: based on 115.136 with changes from 137.
 115.139 28-jun-00  bbulusu         Fixed cursor c_ptip_enrollment_info so that
                                    it ignores the enrt_rslt row just created.
                                    Fix for bug 4981.
 115.140 14-jul-00  kmahendr        Bug#5123 - Date Track end date of place holder plan for imputed income
                                    when the prtt becomes ineligible after eligible need not be done.
                                    Added one more elsif clause in delete_enrollment procedure to handle
                                    this kind of situation
 115.141 19-jul-00  gperry          Fixed WWBUG 1349363.
                                    Now pass in less of life event occurred
                                    date-1 or effective date -1.
                                    Changed remove_cert_action_items.
 115.142 20-jul-00  kmahendr        Effective date is to be passed if effective date -1 >
                                    life event occurred - related to version -115.141
 115.143 11-aug-00  gperry          Fixed call to ben_determine_date.
                                    Was passing cvg_end_dt_cd and
                                    cvg_strt_dt_rl. Should have passed
                                    cvg_end_dt_rl.
                                    Fix for WWBUG 1375481.
 115.144 06-Sep-00  jcarpent        1269016. Fixed handling of future dated
                                    covered dependents when deleting an enrt.
 115.145 14-Sep-00  jcarpent        1394044. Object version number issue.
                                    also undo some of fix from prev version
                                    so that don't delete rows for voided pils.
 115.146 21-Sep-00  maagrawa        1406914. Do not decrease the effective_date
                                    in remove_cert_action_items, if it is
                                    less than the effective_start_date.
 115.147 13-Oct-00  pbodla          bug : 1418754 : added call to
                                    chk_max_num_dpnt_for_pen after call to
                                    update_elig_cvrd_dpnt.
 115.148 25-Oct-00  bbulusu         Bug fix 1471158. Don't zap elig_cvrd_dpnt
                                    if cvg is already ended.
 115.149 08-NOV-00  vputtiga        Fixed bug 1485814. Added procedure
                                    update_person_type_usages
 115.150 19-nov-00  tilak           mesage 91902 changed
                                    pen cursor in delete enrollemt changed to get
                                    plan and option name
                                    ECVG_threu date is validated instead of effctived date
                                    with erlst_deenrt_dt to  deenroll
 115.151 05-Jan-01  maagrawa        Added parameters enrt_cvg_thru_dt and p_mode
                                    to delete_enrollment to handle special
                                    cases when the cvg_thru_dt is entered by
                                    the user.
 115.152 08-feb-01  tilak           cursor for OPT/PTIP/PL created to validate
                                    deentrolment allowed bug : 1620161
 115.153 19-feb-01  tilak           flex credit amout changes is not affecting
                                    on next enrollment
                                    cursor c_flex and c_bpl is creatd
                                    to update the ledger
 115.154 21-Feb-01  maagrawa        In delete_enrollment, pass the coverage
                                    end date to rate_and_coverage_dates
                                    procedure when it is enterable by the user.
                                    (1647095).
 115.155 23-Feb-01  ikasire         fix the '1 prior' date code in
                                    delete_enrollment procedure by
                                    adding 'WL' cases and changing the cursor
                                    used for it (1633284,1558809,1584238)
 115.156 15-Mar-01  kmahendr        Bug#1684498 - added enrt_cvg_thru_dt condition
                                    in the cursor c_prtt_total_bnft_amt in procedure
                                    multi_rows_edit
 115.157 23-Mar-01  maagrawa        Call to ben_env_object.init added to
                                    delete_enrollment.
 115.158 26-Apr-01  maagrawa        Performance changes.
                                    Bypass dependent,beneficiary,flex credit,
                                    premium logic based on plan design.
 115.159 30-Apr-01  maagrawa        Call ben_env_object.init to initialize
                                    cache variables.
 115.160 04-May-01  ikasire         1712890 Added the validation conditions for
                                    attribute columns in UPDATE routine
 115.161 08-May-01  jcarpent        Bug 158783. Reset l_ppe.prtt_prem_id before
                                    fetch since this is used instead of %found
 115.162 17-May-01  maagrawa        Changed the calls to ben_global_enrt.
 115.164 21-May-01  kmahendr        Merged version 163 and 162 as 163 was a
                                    leapfrog version on 153
 115.165 22-May-01  maagrawa        Fixed bug introduced by performance changes
                                    for premiums.
 115.167 29-May-01  kmahendr        Version 165 brought forward as version 166 was
                                    a leapfrog version of 156 and fixes in 160
 115.168 01-jun-01  tilak           bug : 1186192 unhook_bnf is changed to end date
                                    usage , unhhok_bnf is called from update
 115.169 14-Jul-01  kmahendr        Non-recurring element entries are not removed when
                                    deenrolling from comp. objects - added cursor c_prv3
 115.170 16-jul-01  kmahendr        Change history for 115.169 entered
 115.171 16-jul-01  shdas           added p_enrt_cvg_end_dt to calc_dpnt_cvg_dt
 115.172 17-Aug-01  kmahendr        Bug#1939522 - for unhook_dpnt and unhook_bnf, per_in_ler
                                    is passed null from delete_enrollment when delete_enro
                                    is called from ben_newly_ineligible in selection mode
 115.173 28-Aug-01  kmahendr        cursor c_abr added to check non-recurring element entries
                                    as unrestricted per_in_ler_id will always be same
 115.174 17-Oct-01  kmahendr        Bug#2038814 - new cursor c_prv4 added in the delete_enroll
                                    ment procedure
 115.175 02-Nov-01  kmahendr        Changed paramater value from p_datetrack_mode to l_date
 115.176 09-Nov-01  pbodla          Bug 2093859 : zap the enrollment data if
                                    coverage is not started yet. Case 3 and 4
                                    ( Mahendran and Manish have knowledge of the issue
                                      before changing please consult one )
 115.177 12-Nov-01  kmahendr       Bug-2093859 - conc_request_id in self_service is given 0
                                   - benmngle mode is checked with in clause for 0, -1
 115.178 05-dec-01  dschwart/     - WWBUG#1646442:
                    bburns             - added block of variable declarations in
                                         create_enrolment
                                       - replaced c_ppe in create_enrolment
                                       - added c_pel and processing in create_enrolment
                                       - added processing to get correct date/update mode
 115.179 31-Jan-02  kmahendr      -Bug#2209048-if delete_enrollment is called from beninelg
                                   delete_mode is assigned 'DELETE'.
 115.181 01-Apr-02  shdas         reopen cvrd dpnt record only if he is still eligible.
                                  changed c_egd cursor in update_enrollment to add
                                  filtering on dpnt_inelig_flag.
 115.182 23-May-02  ikasire       Bug 2200139 Override Enhancements there may be
                                  future enrollments needs to be deleted. To handle this
                                  if the pen esd is >= p eff date, then we are passing
                                   esd + 1 for p eff date from multi row edit.
 115.183 29-May-02  ikasire       1.Bug 2386000 If the delete enrollment is called from
                                  benuneai, pass this to p_called_from parameter of
                                  unhook_dpnt.
                                  2. When elig_per_elctbl_chc_id is null, we need to pass
                                  lee_rsn_id and enrt_perd_id also along with pgm,pl,oipl
                                 to ben_determine_date.rate_and_coverage_dates call.
 115.184 25-Jun-02  tjesumic     bug:2479616 for the 1 prior rate end date code, the date is
                                 calcualted on coverage start date, that was changed to
                                 calculate on rate start date
 115.185 05-Jul-02  ikasire      bug:2479616 fixed a typo in the 1 prior rate if condition
 115.186 29-Aug-02  ikasire      Bug 2537720 fix for the effective date in suspend
                                 enrollment update case.
 115.187 10-Sep-02  kmahendr     Bug#2545915 - c_prv cursor in void_enrollment modified.
 115.188 28-Sep-02  ikasire      Bug 2600087 cursor C1 is not selecting the future
                                 enrollements.
 115.189 29-Sep-02  bmanyam      Bug 2597005 - Changed the dt-mode to 'correction'
                                 before calling 'update_elig_cvrd_dpnt'
 115.190 30-sep-02  kmahendr     Bug#2602124 - cursor c1 modified to not to pick the ones
                                 with electable choice having result ids.
 115.191 03-Oct -02 bmanyam      Bug 2597005 - Reversed the changes made in 115.189 version
 115.192 15-oct-02  tjesumic     Bug 2546259 - Delete_enrolment Delete(ZAP) the result  if
                                 Coverage Started in the Future Date. If the current LE is
                                 backedout , deleted result is required to restore the previous
                                 LE. This fix  Void the enrollment result instead of deleting
                                 result of the future dated  coverage
 115.193 15-Oct-02  ikasire      Bug 2627078 added the cursor to update the epe with
                                 the current result id when the interim records are deleted

 115.194 09-Nov-02  tjesumic     Bug 2546259 - Suspend_flag control  removed
 115.195 14-Nov-02  kmahendr     Bug#2625060 - in delete_enrollment procedure, activity base rt id is not
                                 passed when calling update_prtt_rt_val api.
 115.196 28-Nov-02  lakrish      Bug 2519378, Set tokens for error message
                                 BEN_91711_ENRT_RSLT_NOT_FND
 115.197 07-Jan-03  ikasire      Bug 2739965 delete enrollment for unrestricted.
                                 added p_ler_typ_cd parameter to get_ben_pen_upd_dt_mode
                                 procedure
 115.199 15-Feb-03  pbodla       DEBUG : hr_utility.set_location calls wrpped
                                 around if statements.
 115.200 14-Mar-03  kmahendr     Bug#2785410 - code added in void_enrollment proc.
 115.201 14-Mar-03  ikasire      Bug2847110 and 2852703 1 Prior Code fixes
 115.202 24-Mar-03  ikasire      Bug 2739965 Added a warning message while deleting the future
                                 rate changes.
 115.203 10-Apr-03  kmahendr     Bug#2893826 - cursor c_prem changed to look for per_in_ler_stat
                                 cd strd
 115.204 17-Jul-03  ikasire      Bug3051674 fixes for the multi-row edits to happen
                                 as of the lf_evt_ocrd_dt
 115.205 28-Aug-03  tjesumic     bug # 3086161 when the open LE reprocessed on the same day of
                                 the previous LE process date. the previous LE result are
                                 updated with open per in ler id. if the open LE is backedout
                                 then the result of  previous LE are lost. this is fixed
                                 by copying the result of  LE to backop table and copy
                                 back to result when the open is backed out
                                 bepenapi modified to  copy  to the  backup table in update_prtt_reslt
                                 and delete_enrollment to update the  result from backup tabe
                                 Related changes are in benbolfe.pkb
 115.206 16-Sep-03  vsethi       Bug 3123698 - Added tokens to messages BEN_92179_BELOW_MIN_AMOUNT and
         BEN_92180_ABOVE_MAX_AMOUNT
 115.207 26-Sep-03  kmahendr     Added void_rate procedure and codes in delete_enroll - GHR fix
 115.208 07-Oct-03  tjesumic     if the dpnt enrolled in same type of plan the dpnt are recyled
                                 even if alws_dpnt_dsgn_flag is 'N'
 115.209 10-Oct-03  tjesumic     even if the old result_id not passed the dpnt carry forward for
                                 alws_dpnt_dsgn_flag is 'N' # 3175382
 115.210 13-Nov-03  ikasire      Bug 3256056 We want remove the penid from the enb record
                                 while zaping or voiding the pen
 115.211 14-Nov-03  mmudigon     Bug 3222057. Step 155 Bypass call to
                                 ben_cobj_cache.get_pgm_dets for plnip
 115.212 15-Nov-03  kmahendr     Bug#3260564 - assign rt_end_dt at the time delete_enrollment
                                 for 1 prior codes based on new enrollment.
 115.213 29-Dec-03  rpgupta      Bug#3327224 - Make dpnt cvg end dt independent of prtt cvg end dt
 115.214 08-Jan-04  vvprabhu     Bug 1620171 - Changes to date format in message 91902
 115.215 05-Feb-04  ikasire      Bug 3412562 void_rate
 115.216 11-Mar-04  bmanyam    BUG: 3398353 -  END-DATE/VOID Dependent Designation records
                                 (BEN_ELIG_CVRD_DPNT_F) in void_enrollment procedure
                                 for Unrestricted Enrollment.
                                 Bug: 1620171 - For msg 91902, used fnd_date.date_to_chardate
                                 instead of a fixed format-mask.
 115.217 07=Apr-04  tjesumic    FONM changes added
 115.218 19-apr-04  bmanyam     Bug# 3573173 : In c_prem cursor, added
                                condition NVL(ecr.enrt_bnft_id, -1) = NVL(p_enrt_bnft_id, -1) to
                                make sure the ben_enrt_prem record refers to the correct ben_enrt_bnft_f
                                record while creating ben_prtt_prem.
 115.219 21-Apr-04  kmahendr    Bug#3568529 - ben_env_object.init is called only if the
                                object was not initialised.
 115.220 04-May-04  bmanyam     Bug: 3574168 - In void_enrollment, delete_enrollment and
                                unhook_dpnt procedures, added code to delete the assigned
                                Primary-Care-Providers for the enrollment.
 115.221 13-May-04  bmanyam     Bug# 3574168: Removed delete_prmry_care_prvdr
                                from unhook_dpnt, as "update_elig_cvrd_dpnt"
                                procedure will do it.
 115.222 17-May-04  ikasire     Bug# 3631117 fixes for APP-PAY-07155 and APP-BEN-91711 errors
 115.223 18-May-04  ikasire     Bug# 3631117 change null to to_number(null)
 115.224 18-May-04  nhunur      Bug# 3626176
 115.225 21-May-04 bmanyam      Bug# 3631067 - changed cursors c_pcp and c_pcp_future
                                to fetch records based on cvg_thru_date and NOT p_effective_date
 115.226 16-Jun-04 bmanyam      Bug# 3657077 : In procedure determine_dpnt_cvg_dt_cd,
                                check if DPNT_DSGN_CD is specified at plan-level.
                                If it is specified then dependent designation level is PL.
                                This overrides PGM and PTIP levels
 115.230  Leapfroged version of 115.228 by  Amit Parekh
 115.231  28-Jun-04 kmahendr    Bug#3714789 - Effective date is derived from benmngle
                                parameter for Selection mode in delete_enrollment
 115.232 30-Jun-04 abparekh     Bug 3733213 : In delete_enrollment while setting new Coverage End Date
                                for CVG_END_DT_CD starting with W or LW, check for NULL value of
        l_new_enrt_cvg_strt_dt and not whether cursor C_NEW_CVG_STRT_DT
        fetched any row since the cursor uses aggregate function.
 115.233 06-Jul-04 ikasire      Bug 3695005 consider suspended enrollment also in the multi
                                row edits in evaluating coverage across plan types.
 115.234 23-Jul-04 kmahendr     Bug#3772143 - added parameter - p_include_erl
 115.234 29-Jul-04 tjesumic     Bug#3259447 - nvl added to recalc_premium for p_enrt_cvg_strt_dt
 115.236 09-Aug-04 nhunur       Bug - 3797391 - call unhook_dpnt / unhook_bnf .
 115.237 23-Aug-04 mmudigon     CFW. changes to delete_enrollment
                                2534391 :NEED TO LEAVE ACTION ITEMS
 115.238 01-Sep-04 abparekh     Bug# 3866580 : Call determine_action_items only for savings plan enrollment
                                at plan level (and not option in plan level). For rest of the plans
                                call for enrollment in plan as well as option in plan level
 115.239 07-sep-04 mmudigon     CFW. Continued
 115.240 09-sep-04 mmudigon     Bug fixes 3865108 and 3882130
 115.241 30-sep-04 tmathers     Overloaded multi_rows_edit as
                                not all libraries have the new parameter
                                p_include_erl.392661
 115.242  07-oct-04 ssarkar     BUG: 3904792: MAINLINE FIX FOR 3894240: WHEN UPDATING A SAVINGS
                                PLAN RATE SYSTEM IS END DATE
 115.243  12-Oct-04 ikasire     Bug 3939785 Need to handled the override thru date properly
 115.244  19-Oct-04 abparekh    Bug 3958064 Need to handled the override thru date properly only for Overriden records
 115.245  12-Jan-05 lakrish     4114012, Added SS wrapper procedure delete_enrollment_w
 115.246  18-Jan-05 ikasire     Bug 4064635 CF SUSP and INTERIM 'W' and 'WL' cases
 115.247  21-jan-05 nhunur      Added c_prvdel cursor
 115.248  07-Feb-05 tjesumic    backout_future_coverage function removed from benelinf.pkb. future coverages are
                                copied into backup table in delete_enrollmet. multo_rows_edit take care of voiding
                                # 4118315
 115.248  09-Mar-05 mmudigon    Bug 4157759 . Added var l_prtt_rt_val_stat_cd in
                                proc delete_enrollment.
 115.249  05-Apr-05 bmanyam     Bug 4268494: Added '1 Prior' logic for
                                LDPPOEFD - 1 Prior or End of Pay Period On or After Effective Date
                                LDPPFEFD - 1 Prior or End of Pay Period after Effective Date
 115.250  13-Apr-05 ikasire     Added new parameter to manage_enrt_bnft call
 115.251  15-Apr-05 kmahendr    Added a condition for 1 prior codes in delete_enrollment
 115.252  18-May-05 ikasire     Bug 4262697 don't delete the results of previous life events if there
                                are no electable choices in the current life event of the comp
                                object.
 115.253  23-may-05 ssarkar     bug 3123698 : added cursor c_pl_typ_names to proc multi_row_edit.
 115.255  26-May-05 vborkar     Bug 4387247 : In wrapper method exception
                                handlers changes made to avoid null errors
                                on SS pages
 115.256  01-Jun-05 vborkar     Bug 4387247 : Modifications to take care of
                                application exceptions.
 115.257  04-Jul-05 rgajula     Bug 4431511 Added checks in get_ben_pen_upd_dt_modes to ensure update_override is passed as
				effective datetrack mode if the desired date track mode is
				delete next change in case of unrestricted enrollments
 115.258  20-Jul-05 ikasire     Bug 4463836 added new parameter p_called_from_ss
 115.259  27-Jul-05 kmahendr    Bug#4509665 - modified the cursor c_pl_typ_names
                                and increased the length of variable l_pl_typ_name
 115.260  29-jul-05  tjesumic   BUG 4510798 : fonm variable intialised on delete_enrollment
 115.261  24-Aug-05  swjain     Bug 4520785 : Updated cursor c_old_dpnt in procedure unhook_dpnt
 115.262  24-Aug-05  ikasire    Indented delete_enrollment procedure to improve productivity
                                in bug resolutions.
 115.263  06-Oct-05  bmanyam    Bug 4642299 : Added 'LODBEWM','ODBEWM' too for 1 Prior logic.
 115.264  07-oct-05  ssarkar    Bug 4616225 : Call to pl/oipl cache is set to nvl(life_event_dt/effective_date).
                                      proc delete_enrollment modified for same .Also ben_cobj_cache.get_pl_dets/get_oipl_dets
				      are called after ben_global_enrt.get_pil .
 115.265  17-Oct-05  vborkar    BUG 4663971 : In delete_enrollment, called update_prtt_enrt_result
                                instead of delete_prtt_enrt_result for datetrack mode other than zap.
                                Also if eff date equals PEN start date then called update_prtt_enrt_result
                                in correction mode, otherwise in update mode.
115.266  18-Oct-05  abparekh    Bug 4662362 : Unhook dependents / beneficiary in all case
115.267  31-Oct-05  ikasire     Bug 4690334 : multi_rows_edit from overview page
115.268  31-Oct-05  ikasire     Bug 4710937 cursor c_old_dpnt regression from 4520785
115.269  02-Nov-05  ikasire     Bug 4709601 multi_rows_edit not required for CFW call
115.270  10-Nov-05  abparekh    Bug 4723828 Correctly handle nullifying of benefit amount
115.271  18-Nov-05  bmanyam     Bug 4739922: In delete_enrollment, Case 4:
                                Backout the Result/ (do not VOIDD).
115.272  18-Nov-05  bmanyam     If enrollment api's are called from
                                concurrent manager for conversion or ivr                                 kind of interfaces, call raises error.
                                benutils.get_batch_parameters
 115.273  13-Dec-05  vborkar    Bug 4695708 : Made changes to delete_enrollment
                                and delete_enrollment_w exception handlers
                                so that error messages are correctly shown
                                in SS.
 115.275  24-Jan-06  vborkar    4962138 : In remove_cert_action_items, when p_source is null
                                changed datetrack mode from DELETE to ZAP,
                                in order to avoid display of action item(s) in PUI
                                for de-enrolled selections.
 115.276  31-Jan-06  kmahendr   Bug#4967063 - modified cursor c_new_cvg_strt in
                                delete_enrollment
 115.277  02-Feb-06  bmanyam    BUG 4919591 - Changed c_rslt_ptip, c_rslt_pl, c_rslt_oipl
                                to check Earliest De-enrollment date in case of Unrestricted.
 115.278  17-Feb-06  kmahendr   Bug#5032364 - modified cursor c_old_corr_pen in
                                delete_enrollment
 115.279  28-Feb-06  rgajula    Bug 4770367 : Added the NVL condition so as to allow the user to update
				the attributes with NULL values if the user wishes to do so
 115.280  03-Mar-06  rtagarra   Bug 5018328 : Added condition in exception block for delete_enrollment so
                                that it will take care for this specific exception condition.
 115.281  03-Mar-06  kmahendr   Added check for automatic enrollment in
                                delete_enrollment  - enh
 115.282  13-Mar-06  kmahendr   Bug#5082245 - savings plan is determined by flag
                                than opt type code
 115.283  16_mar-06  rtagarra   Bug 5018328 :Added a check for exception l_fnd_message_exception
                                in exception block for delete_enrollment procedure.
 115.285  10-Apr-06  kmahendr   Bug#5126242 - added a parameter to delete_prmry_care
 115.286  19Apr-06   rtagarra   Added cursor c_crntly_enrd_flag and c_crntly_enrd_flag_unres for Bug#5018328 which checks
                                whether the deenrollment should be allowed in subsequesnt LE depending on earliest deenrollment date
				both for LE and Unrestricted.
 115.286  02-May-06  ikasired   Bug 5102337
 115.291  13-jun-06  ssarkar    bug 5287988 - leap -frog of 115.287 as ver 288 to 290 r reverted
 115.292  28-jun-06  ssarkar    bug 5347887 - need to populate rplcs_sspndd_rslt_id while end-dating sspndd pen.
 115.293  29-jun-06  kmahendra/ bug 5363388 - marking pen as 'BCKDT' when cvg st dt > cvg end dt
                     ssarkar
 115.294  10-Jul-06  rgajula    Bug 5368060
				Dont void the rate if the PEN record is Backed-Out
				If the PEN record is end-dated in the subsequent life event dont void the rate
115.295   03-aug-06 ssarkar     bug 5417132 - by passing chk of enrt method for flex and impute
115.297   04-Sep-06  rgajula    Bug 5499809 - Void the enrollment and rate if the delete enrollment is being performed in the same life event and that life event is not unrestricted LE
115.298   27-Sep-06 stee        Bug 5391554 - Adjust overlapping rates.
115.299   10/4/2006 gsehgal     Bug 5550679 - void_rate void the rates for all per_in_ler_id whereas it should void the
					      rate only calling that per_in_ler_id
115.300   12-Oct-06 rtagarra    Bug 5567840 - Added check so that error 94596 wont be raised for imputed income plans.
115.301   30-Oct-06 abparekh    Bug 5626835 - For delete cases 3/4 : For Enter Value At Enrollment cases,
                                              we need to void rate instead of deleting them.
115.302   01-Nov-06 swjain      Bug 5637595 - Added more checks in procedure delete_enrollment so that for open
                                              enrollment cases, if future dated coverages are there in previous
					      and subsequent LEs, then changing enrollments should not backout the
					      end dated coverage record.
115.303   22-Nov-06 vborkar      Bug 5663280 - Do not 'VOID' carry forwarded enrollments which are end-dated in
                                              current life event
115.304   24-nov-06 rtagarra     Bug 5664907 - Application Exceptions for delete_enrollment are handled.
115.305   19-dec-06 ssarkar	 Bug 5717428
115.306   24-Jan-07 swjain       Bug 5739530 - Updated procedure delete_enrollment, update future prvs only if
					       they haven't been updated previously.
115.307   30-Jan-07 rgajula      Bug 5768795 - Moved the code for validation of "Coverage Across Plan Types" from multi_rows_edit
                                               to a seperate procedure chk_coverage_across_plan_types.
115.309   21-feb-07 rgajula      Bug 5859714 :Updated the field BEN_PER_IN_LER.BCKT_PER_IN_LER_ID of
                                               the backed out L.E with the per_in_ler_id of the causing L.E
115.310   11-May-07 ikasired     Bug 5985777   Backup the future completed action items.
115.311   14-May-06 rtagarra     Bug 6000303 : Defer Deenrollment ENH.
115.312   04-Jul-07 swjain       Bug 6165501 : Updated cursor c_intm_other_rslt in delete_enrollment procedure
115.313   04-Oct-07 rtagarra     Bug 6471236 : void_rate should only be called for the PRV for which void should happen
					       instead of calling for all PRV's associated with the PEN for entr_val_at_enrt_flag.
115.314   26-Oct-07  swjain      Bug 6528876 : Added order by clause in get_election_date
115.315   30-Nov-06  rtagarra    Bug 6656136 : While calling multi_rows_edit pass l_lf_evt_ocrd_dt only for Open and for others pass p_effective_date.
115.316   01-Dec-07  sshetty     Bug 6641853 : The enrollment is set to correction
                                               when the changes are done within
                                               enrollment period and does not
                                               void.
115.317   14-Dec-07 sallumwa     Bug 6683229 : Removed a condition,which is satisfied always because l_other_pen_rec
                                               is not populated before it is used.

115.318   23-Dec-07  sshetty     Bug 6641853 : Handled some more conditions for
                                               same bug
115.318   06-Jan-08  sshetty     Bug 6641853 : Fixed rate issue
115.319   14-Jan-08  rtagarra    Bug 6747807 : Fixed cursor c_check_cvrd_in_plan
115.320   04-APR-08  sshetty     Bug 6641853 : Added per_in_ler_id as cursor
                                               param to make sure the correction
                                               is not read as update
115.321   30-apr-08  sallumwa    Bug 6925893 : A Rate Gap exists when Rate Start dates Code
					       is set to First of Next Pay period,
                                               Rate end date is 1 Prior and enrollments
                                               are saved on different dates
					       crossing pay periods.

115.322   19-may-08  bachakra    Bug 6963660:  Updated the effective start date of the
                                               corrected result in the back up table to the more
					       recent date so, that the previous enrollment gets opened up
                                               on backing out the current life event which has two
                                               records attached to it for the same plan. Please refer bug
					       for test case.
115.326   10-sep-08  sallumwa    Bug 7311284 : Modified the condition while setting the effective date in
                                               delete_enrollment procedure.
115.327   12-Jun-08  sallumwa    Bug 7133998: Modified the update_enrollment procedure to delete the future
                                              premium records corresponding to the previous Le.
115.328   15-Oct-08  stee        Bug 7197868: Remove fix for bug 6963660.  Change cursor c_old_corr_pen
                                              to check for effective_start_date.
115.329   07-Nov-08  sallumwa    Bug 7458990: Reverted back the fix 5018328,so that the system throws the error
                                              when trying to change the plan before the earliest de-enrol date.
115.330   29-Jan-09  sallumwa    Bug 7711723 :Whenever future certification prvdd records are found,move them to
                                              back-up table and delete the same from ben_prtt_enrt_actn_f and
					      ben_prtt_enrt_ctfn_prvdd_f tables.
115.332  16-Feb-09   velvanop    Bug 7561395: If Coverage Amount is changed multiple times for the same Life Event, then Required
                                              Certication alert should not popup. When the Benefit Amount is changed, New penid will
					      be generated for the enrollment. This causes action item and certification records
					      to be deleted of the old penid. When Benefit Amount is changed for the third time, since there are no
					      action item records, certification is still required although produced. Fix will create
					      new Action Item and Certification record for the new penid. History of the previous action items
					      and certification records are not created, but only latest record from the previous penid
					      will be restored.
115.333  20-Mar-09   sallumwa   Bug 8304294 : Reverted the fix made for the bug 7711723.The fix is implemented in
                                              bepeaapi.pkb.
115.334  23-Mar-09   sallumwa   Bug 8222481 : Modified the procedure delete_enrollment to handle the coverage gaps
                                              when multiple changed are made within the same enrollment period,
					      whenever Coverage End Date Code is set as 1 Prior.
115.335  28-Apr-09   sallumwa   Bug 7209243 : Handled the rate gap when multiple changes are made in the same Life
                                              event with Rate end date code as "1 Prior".
115.336  06-Jun-09   velvanop   Bug 8578358 : APP-BEN-91902 error should not be thrown when changing the option with
                                              in the same plan within the required period of enrollment
115.338  10-Jun-09   velvanop   Bug 8573195 : Ended_per_in_ler_id of future backedout lifeevent is being updated while adjusting the rates
                                              on processing and saving the elctions of intervening LifeEvent.
115.340  10-Aug-09   velvanop   Bug 8669907 : Fix 7561395 copies the action items when ever the coverage amount is changed multiple time in the same lifevent.
                                              This results in action item being created even if the Participant selects
					      No Coverage plans against the new pen_id.. Only completed action items will be copied and check will be made whether to copy the
					      completed actions items or not.
115.341  25-Aug-09   sallumwa   Bug 8688513 : Modified the fix done for 8222481 to handle the coverage gaps when no electability exists for the
                                              previous life event.
115.343  07-Oct-09   sallumwa   Bug 8919376 : Update the elig cvrd dpnt ID in the ben_elig_cvrd_dpnt_f table correponding to the
                                              enrollment result if the participant is currently enrolled in the plan.
115.344  14-Oct-09   stee       Bug 8972844 : Changed cursor c_bckup_tbl_restore.
115.345  13-Nov-09   stee       Bug 9114147 : Use life event occurred date to check if an enrollment is
                                              overriden when determining if an enrollment should be terminated
                                              in multi_rows_edit.
115.346  08-Jan-09   velvanop  Bug 9256641 : Do not generate communications while creating the action items
==================================================================================================================
*/
--
-- Package Variables
--
g_package        Varchar2(33) := '  ben_PRTT_ENRT_RESULT_api.';
g_debug boolean := hr_utility.debug_enabled;

/* Added for Bug 7561395*/

g_new_prtt_enrt_rslt_id number;
TYPE g_enrt_list_tab IS TABLE OF NUMBER;
g_enrt_list g_enrt_list_tab := g_enrt_list_tab();

/*End for 7561395 */
--
Function display_boolean(p_condition boolean) return varchar2 is
begin
    if (p_condition) then
        return 'TRUE';
    else
        return 'FALSE';
    end if;
end display_boolean;
--
procedure rpt_error (p_proc     in varchar2
                    ,p_step     in number
                    ) is
begin
  if g_debug then
    hr_utility.set_location('Fail in '|| p_proc || ' at step ' ||
                            to_char(p_step),999);
  end if;
end;



--
-- ----------------------------------------------------------------------------
-- |----------------------< Remove_Cert_Action_items >------------------------|
-- ----------------------------------------------------------------------------
--

procedure remove_cert_action_items
                 (p_prtt_enrt_rslt_id  in     number
                 ,p_effective_date     in     date
                 ,p_end_date           in     date default null
                 ,p_business_group_id  in     number
                 ,p_validate           in     boolean default FALSE
                 ,p_datetrack_mode     in     varchar2
                 ,p_source             in     varchar2 default null
                 ,p_per_in_ler_id      in     number default null
                 ,p_per_in_ler_ended_id in    number default null
                 ) is
   l_proc  varchar2(80); -- := g_package||'.remove_cert_action_items';
   l_step  number(5);
   l_tmp   number(15);

   cursor c_bnf_types is
       select  pea.prtt_enrt_actn_id
              ,pea.object_version_number
              ,pea.effective_start_date
              ,pea.effective_end_date
              ,pil.lf_evt_ocrd_dt
         from ben_prtt_enrt_actn_f pea,
              ben_per_in_ler pil
        where pea.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
          and pea.business_group_id = p_business_group_id
          and p_effective_date
                  between pea.effective_start_date and pea.effective_end_date
          and pil.per_in_ler_id=pea.per_in_ler_id
          and pil.business_group_id=pea.business_group_id
          and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT') ;

  cursor c_min_max_dt(p_prtt_enrt_actn_id  number) is
  select min(effective_start_date),
         max(effective_end_date)
    from ben_prtt_enrt_actn_f
   where prtt_enrt_actn_id = p_prtt_enrt_actn_id;
  --
  cursor c_pea_ovn(p_prtt_enrt_actn_id  number,
                   p_effective_date date) is
  select pea.object_version_number
    from ben_prtt_enrt_actn_f pea
   where pea.prtt_enrt_actn_id = p_prtt_enrt_actn_id
     and p_effective_date between pea.effective_start_date
                              and pea.effective_end_date ;
  --
  cursor c_future_pea(p_prtt_enrt_actn_id  number,p_effective_date date ) is
    select *
     from ben_prtt_enrt_actn_f
    where prtt_enrt_actn_id = p_prtt_enrt_actn_id
      and effective_start_date > p_effective_date
    order by effective_start_date desc ;

  --
  cursor c_future_pcs(p_prtt_enrt_actn_id  number,p_effective_date date ) is
     select *
       from ben_prtt_enrt_ctfn_prvdd_f
      where prtt_enrt_actn_id = p_prtt_enrt_actn_id
        and effective_start_date > p_effective_date
      order by effective_start_date desc ;
  --
  l_effective_date date;
  l_min_start_date date;
  l_max_end_date   date;
  l_datetrack_mode varchar2(30);
  --
begin
  if g_debug then
    l_proc := g_package||'.remove_cert_action_items';
    hr_utility.set_location ('Entering '||l_proc,10);
    hr_utility.set_location ('p_end_date '||p_end_date,10);
  end if;
  --
   l_step := 10;
/* leslie removed this call
   for l_prtt_ctfn_prvdd in c_prtt_ctfn_prvdd loop
       ben_prtt_enrt_ctfn_prvdd_api.delete_prtt_enrt_ctfn_prvdd
         (p_validate               => FALSE
         ,p_prtt_enrt_ctfn_prvdd_id=> l_prtt_ctfn_prvdd.prtt_enrt_ctfn_prvdd_id
         ,p_effective_start_date   => l_prtt_ctfn_prvdd.effective_start_date
         ,p_effective_end_date     => l_prtt_ctfn_prvdd.effective_end_date
         ,p_object_version_number  => l_prtt_ctfn_prvdd.object_version_number
         ,p_effective_date         => p_effective_date
         ,p_datetrack_mode         => p_datetrack_mode
         );
   end loop;
   l_step := 20;
*/
   for l_bnf_types in c_bnf_types loop
       l_step := 25;
     if p_end_date is not null then

        l_min_start_date := null;
        l_max_end_date   := null;

        open c_min_max_dt(l_bnf_types.prtt_enrt_actn_id);
        fetch c_min_max_dt into l_min_start_date,l_max_end_date;
        close c_min_max_dt;

        if p_end_date < l_min_start_date then
           l_effective_date := p_effective_date;
           l_datetrack_mode := hr_api.g_zap;
        elsif p_end_date < l_max_end_date then
           l_effective_date := p_end_date;
           l_datetrack_mode := hr_api.g_delete;
           --
           --get the correct ovn
           --
           open c_pea_ovn(l_bnf_types.prtt_enrt_actn_id, p_end_date);
           fetch c_pea_ovn into l_bnf_types.object_version_number;
           close c_pea_ovn;
           --
        else
           l_datetrack_mode := null;
        end if;

        if l_datetrack_mode is not null then
           --
           --BUG 5985777 writing future action items to backup table
           --
           --Find if there are any future action items. If exists
           --backup those rows.
           --
           --ben_prtt_enrt_actn_f
           --
           for l_pea in c_future_pea(l_bnf_types.prtt_enrt_actn_id,l_effective_date) loop
             --
             insert into BEN_LE_CLSN_N_RSTR (
                   BKUP_TBL_TYP_CD,
                   BKUP_TBL_ID,
                   EFFECTIVE_START_DATE,
                   EFFECTIVE_END_DATE,
                   PRTT_IS_CVRD_FLAG, -- RQD_FLAG
                   ASSIGNMENT_ID,     -- ACTN_TYP_ID
                   PRTT_ENRT_RSLT_ID,
                   PER_IN_LER_ID,
                   BUSINESS_GROUP_ID,
                   ENRT_CVG_THRU_DT,   -- CMPLTD_DT
                   ENRT_OVRID_THRU_DT, -- DUE_DT
                   PGM_ID,             -- PL_BNF_ID
                   PTIP_ID,            -- ELIG_CVRD_DPNT_ID
                   LCR_ATTRIBUTE_CATEGORY,
                   LCR_ATTRIBUTE1,
                   LCR_ATTRIBUTE2,
                   LCR_ATTRIBUTE3,
                   LCR_ATTRIBUTE4,
                   LCR_ATTRIBUTE5,
                   LCR_ATTRIBUTE6,
                   LCR_ATTRIBUTE7,
                   LCR_ATTRIBUTE8,
                   LCR_ATTRIBUTE9,
                   LCR_ATTRIBUTE10,
                   LCR_ATTRIBUTE11,
                   LCR_ATTRIBUTE12,
                   LCR_ATTRIBUTE13,
                   LCR_ATTRIBUTE14,
                   LCR_ATTRIBUTE15 ,
                   LCR_ATTRIBUTE16,
                   LCR_ATTRIBUTE17,
                   LCR_ATTRIBUTE18,
                   LCR_ATTRIBUTE19,
                   LCR_ATTRIBUTE20,
                   LCR_ATTRIBUTE21,
                   LCR_ATTRIBUTE22,
                   LCR_ATTRIBUTE23,
                   LCR_ATTRIBUTE24,
                   LCR_ATTRIBUTE25,
                   LCR_ATTRIBUTE26,
                   LCR_ATTRIBUTE27,
                   LCR_ATTRIBUTE28,
                   LCR_ATTRIBUTE29,
                   LCR_ATTRIBUTE30,
                   LAST_UPDATE_DATE,
                   LAST_UPDATED_BY,
                   LAST_UPDATE_LOGIN,
                   CREATED_BY,
                   CREATION_DATE,
                   REQUEST_ID,
                   PROGRAM_APPLICATION_ID,
                   PROGRAM_ID,
                   PROGRAM_UPDATE_DATE,
                   OBJECT_VERSION_NUMBER,
                   PER_IN_LER_ENDED_ID)
                 values (
                   'BEN_PRTT_ENRT_ACTN_F_UPD'
                   ,l_pea.PRTT_ENRT_ACTN_ID
                   ,l_pea.EFFECTIVE_START_DATE
                   ,l_pea.EFFECTIVE_END_DATE
                   ,l_pea.RQD_FLAG
                   ,l_pea.ACTN_TYP_ID
                   ,l_pea.PRTT_ENRT_RSLT_ID
                   ,P_PER_IN_LER_ID
                   ,l_pea.BUSINESS_GROUP_ID
                   ,l_pea.CMPLTD_DT
                   ,l_pea.DUE_DT
                   ,l_pea.PL_BNF_ID
                   ,l_pea.ELIG_CVRD_DPNT_ID
                   ,l_pea.PEA_ATTRIBUTE_CATEGORY
                   ,l_pea.PEA_ATTRIBUTE1
                   ,l_pea.PEA_ATTRIBUTE2
                   ,l_pea.PEA_ATTRIBUTE3
                   ,l_pea.PEA_ATTRIBUTE4
                   ,l_pea.PEA_ATTRIBUTE5
                   ,l_pea.PEA_ATTRIBUTE6
                   ,l_pea.PEA_ATTRIBUTE7
                   ,l_pea.PEA_ATTRIBUTE8
                   ,l_pea.PEA_ATTRIBUTE9
                   ,l_pea.PEA_ATTRIBUTE10
                   ,l_pea.PEA_ATTRIBUTE11
                   ,l_pea.PEA_ATTRIBUTE12
                   ,l_pea.PEA_ATTRIBUTE13
                   ,l_pea.PEA_ATTRIBUTE14
                   ,l_pea.PEA_ATTRIBUTE15
                   ,l_pea.PEA_ATTRIBUTE16
                   ,l_pea.PEA_ATTRIBUTE17
                   ,l_pea.PEA_ATTRIBUTE18
                   ,l_pea.PEA_ATTRIBUTE19
                   ,l_pea.PEA_ATTRIBUTE20
                   ,l_pea.PEA_ATTRIBUTE21
                   ,l_pea.PEA_ATTRIBUTE22
                   ,l_pea.PEA_ATTRIBUTE23
                   ,l_pea.PEA_ATTRIBUTE24
                   ,l_pea.PEA_ATTRIBUTE25
                   ,l_pea.PEA_ATTRIBUTE26
                   ,l_pea.PEA_ATTRIBUTE27
                   ,l_pea.PEA_ATTRIBUTE28
                   ,l_pea.PEA_ATTRIBUTE29
                   ,l_pea.PEA_ATTRIBUTE30
                   ,l_pea.LAST_UPDATE_DATE
                   ,l_pea.LAST_UPDATED_BY
                   ,l_pea.LAST_UPDATE_LOGIN
                   ,l_pea.CREATED_BY
                   ,l_pea.CREATION_DATE
                   ,l_pea.REQUEST_ID
                   ,l_pea.PROGRAM_APPLICATION_ID
                   ,l_pea.PROGRAM_ID
                   ,l_pea.PROGRAM_UPDATE_DATE
                   ,l_pea.OBJECT_VERSION_NUMBER
                   ,p_per_in_ler_ended_id
                 );

           end loop;
           --
           --ben_prtt_enrt_ctfn_prvdd_f
           --
           for l_lcs in c_future_pcs(l_bnf_types.prtt_enrt_actn_id,l_effective_date) loop
             --
             insert into BEN_LE_CLSN_N_RSTR (
                   BKUP_TBL_TYP_CD,
                   BKUP_TBL_ID,
                   EFFECTIVE_START_DATE,
                   EFFECTIVE_END_DATE,
                   PRTT_IS_CVRD_FLAG,   -- ENRT_CTFN_RQD_FLAG
                   COMP_LVL_CD,         -- ENRT_CTFN_TYP_CD
                   ENRT_CVG_THRU_DT,    -- ENRT_CTFN_RECD_DT
                   PRTT_ENRT_RSLT_ID,
                   PGM_ID,              -- PRTT_ENRT_ACTN_ID
                   ENRT_OVRID_THRU_DT,  -- ENRT_CTFN_DND_DT
                   BNFT_TYP_CD,         --  ENRT_R_BNFT_CTFN_CD
                   BUSINESS_GROUP_ID,
                   LCR_ATTRIBUTE_CATEGORY,
                   LCR_ATTRIBUTE1,
                   LCR_ATTRIBUTE2,
                   LCR_ATTRIBUTE3,
                   LCR_ATTRIBUTE4,
                   LCR_ATTRIBUTE5,
                   LCR_ATTRIBUTE6,
                   LCR_ATTRIBUTE7,
                   LCR_ATTRIBUTE8,
                   LCR_ATTRIBUTE9,
                   LCR_ATTRIBUTE10,
                   LCR_ATTRIBUTE11,
                   LCR_ATTRIBUTE12,
                   LCR_ATTRIBUTE13,
                   LCR_ATTRIBUTE14,
                   LCR_ATTRIBUTE15 ,
                   LCR_ATTRIBUTE16,
                   LCR_ATTRIBUTE17,
                   LCR_ATTRIBUTE18,
                   LCR_ATTRIBUTE19,
                   LCR_ATTRIBUTE20,
                   LCR_ATTRIBUTE21,
                   LCR_ATTRIBUTE22,
                   LCR_ATTRIBUTE23,
                   LCR_ATTRIBUTE24,
                   LCR_ATTRIBUTE25,
                   LCR_ATTRIBUTE26,
                   LCR_ATTRIBUTE27,
                   LCR_ATTRIBUTE28,
                   LCR_ATTRIBUTE29,
                   LCR_ATTRIBUTE30,
                   LAST_UPDATE_DATE,
                   LAST_UPDATED_BY,
                   LAST_UPDATE_LOGIN,
                   CREATED_BY,
                   CREATION_DATE,
                   REQUEST_ID,
                   PROGRAM_APPLICATION_ID,
                   PROGRAM_ID,
                   PROGRAM_UPDATE_DATE,
                   OBJECT_VERSION_NUMBER,
                   PER_IN_LER_ID,
                   PER_IN_LER_ENDED_ID)
                 values (
                   'BEN_PRTT_ENRT_CTFN_PRVDD_F_UPD'
                   ,l_lcs.PRTT_ENRT_CTFN_PRVDD_ID
                   ,l_lcs.EFFECTIVE_START_DATE
                   ,l_lcs.EFFECTIVE_END_DATE
                   ,l_lcs.ENRT_CTFN_RQD_FLAG
                   ,l_lcs.ENRT_CTFN_TYP_CD
                   ,l_lcs.ENRT_CTFN_RECD_DT
                   ,l_lcs.PRTT_ENRT_RSLT_ID
                   ,l_lcs.PRTT_ENRT_ACTN_ID
                   ,l_lcs.ENRT_CTFN_DND_DT
                   ,l_lcs.ENRT_R_BNFT_CTFN_CD
                   ,l_lcs.BUSINESS_GROUP_ID
                   ,l_lcs.PCS_ATTRIBUTE_CATEGORY
                   ,l_lcs.PCS_ATTRIBUTE1
                   ,l_lcs.PCS_ATTRIBUTE2
                   ,l_lcs.PCS_ATTRIBUTE3
                   ,l_lcs.PCS_ATTRIBUTE4
                   ,l_lcs.PCS_ATTRIBUTE5
                   ,l_lcs.PCS_ATTRIBUTE6
                   ,l_lcs.PCS_ATTRIBUTE7
                   ,l_lcs.PCS_ATTRIBUTE8
                   ,l_lcs.PCS_ATTRIBUTE9
                   ,l_lcs.PCS_ATTRIBUTE10
                   ,l_lcs.PCS_ATTRIBUTE11
                   ,l_lcs.PCS_ATTRIBUTE12
                   ,l_lcs.PCS_ATTRIBUTE13
                   ,l_lcs.PCS_ATTRIBUTE14
                   ,l_lcs.PCS_ATTRIBUTE15
                   ,l_lcs.PCS_ATTRIBUTE16
                   ,l_lcs.PCS_ATTRIBUTE17
                   ,l_lcs.PCS_ATTRIBUTE18
                   ,l_lcs.PCS_ATTRIBUTE19
                   ,l_lcs.PCS_ATTRIBUTE20
                   ,l_lcs.PCS_ATTRIBUTE21
                   ,l_lcs.PCS_ATTRIBUTE22
                   ,l_lcs.PCS_ATTRIBUTE23
                   ,l_lcs.PCS_ATTRIBUTE24
                   ,l_lcs.PCS_ATTRIBUTE25
                   ,l_lcs.PCS_ATTRIBUTE26
                   ,l_lcs.PCS_ATTRIBUTE27
                   ,l_lcs.PCS_ATTRIBUTE28
                   ,l_lcs.PCS_ATTRIBUTE29
                   ,l_lcs.PCS_ATTRIBUTE30
                   ,l_lcs.LAST_UPDATE_DATE
                   ,l_lcs.LAST_UPDATED_BY
                   ,l_lcs.LAST_UPDATE_LOGIN
                   ,l_lcs.CREATED_BY
                   ,l_lcs.CREATION_DATE
                   ,l_lcs.REQUEST_ID
                   ,l_lcs.PROGRAM_APPLICATION_ID
                   ,l_lcs.PROGRAM_ID
                   ,l_lcs.PROGRAM_UPDATE_DATE
                   ,l_lcs.OBJECT_VERSION_NUMBER
                   ,p_per_in_ler_id
                   ,p_per_in_ler_ended_id
                 );

             --
	  --   Bug 8304294,the fix for 7711723 is reverted.
	  --    l_datetrack_mode := hr_api.g_future_change; ----Bug 7711723
           end loop;
           --
           ben_prtt_enrt_actn_api.delete_prtt_enrt_actn
           (p_validate              => FALSE
           ,p_prtt_enrt_actn_id     => l_bnf_types.prtt_enrt_actn_id
           ,p_effective_start_date  => l_bnf_types.effective_start_date
           ,p_effective_end_date    => l_bnf_types.effective_end_date
           ,p_object_version_number => l_bnf_types.object_version_number
           ,p_effective_date        => l_effective_date
           ,p_datetrack_mode        => l_datetrack_mode
           ,p_prtt_enrt_rslt_id     => p_prtt_enrt_rslt_id
           ,p_unsuspend_enrt_flag   => 'N'
           ,p_rslt_object_version_number => l_tmp
           ,p_business_group_id     => p_business_group_id);
        end if;

     else
       --
       -- Datetrack delete the action items, one day before.
       -- Do not decrease the effective date, when called from 'benelinf',
       -- as the date is already modified in delete_enrollment in such cases.
       --
       if l_bnf_types.effective_start_date < p_effective_date and
        p_datetrack_mode = hr_api.g_delete and
          nvl(p_source,'benelinf') <> 'benelinf' then
          l_datetrack_mode := p_datetrack_mode;
          l_effective_date := p_effective_date -1;
			 -- 4962138
			 elsif l_bnf_types.effective_start_date <= p_effective_date and
             p_datetrack_mode = hr_api.g_delete and
             p_source is null then
          l_datetrack_mode := hr_api.g_zap;
					l_effective_date := p_effective_date;
			 -- end 4962138
       else
          l_datetrack_mode := p_datetrack_mode;
          l_effective_date := p_effective_date;
       end if;
       --
       -- Do not attempt dt delete if the row selected already has an effective
       -- end date equal to(or less than) the date you are trying to delete it on.
       -- Bug 1132739
       --
         if (p_datetrack_mode = hr_api.g_delete and
             l_bnf_types.effective_end_date > l_effective_date) or
             p_datetrack_mode <> hr_api.g_delete then
             ben_prtt_enrt_actn_api.delete_prtt_enrt_actn
             (p_validate              => FALSE
             ,p_prtt_enrt_actn_id     => l_bnf_types.prtt_enrt_actn_id
             ,p_effective_start_date  => l_bnf_types.effective_start_date
             ,p_effective_end_date    => l_bnf_types.effective_end_date
             ,p_object_version_number => l_bnf_types.object_version_number
             ,p_effective_date        => l_effective_date
             ,p_datetrack_mode        => l_datetrack_mode -- 4962138
             ,P_prtt_enrt_rslt_id     => p_prtt_enrt_rslt_id
             ,P_unsuspend_enrt_flag   => 'N'
             ,P_rslt_object_version_number => l_tmp
             ,P_business_group_id     => p_business_group_id);
         end if;
     end if;
   end loop;
   if g_debug then
      hr_utility.set_location ('Leaving '||l_proc,70);
   end if;
   --
exception
    when others then
      if g_debug then
        hr_utility.set_location ('Fail in '||l_proc|| ' at step ' ||
                                 to_char(l_step),999);
      end if;
      raise;
end;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< Get_ben_upd_dt_mode >---------------------------|
-- ----------------------------------------------------------------------------

procedure get_ben_pen_upd_dt_mode
                  (p_effective_date         in     date
                  ,p_base_key_value         in     number
                  ,P_desired_datetrack_mode in     varchar2
                  ,P_datetrack_allow        in out nocopy varchar2
                  ,p_ler_typ_cd             in     varchar2 default null
                  )is
  l_dt_correction           boolean;
  l_dt_update               boolean;
  l_dt_update_override      boolean;
  l_dt_update_change_insert boolean;
-- Bug 4431511 new variables created
  l_dt_delete_next_change boolean;
  l_dt_delete boolean;
  l_dt_zap boolean;
  l_dt_future_change boolean;
-- End Bug 4431511
  l_step                 number(9);
  l_proc                 varchar2(80) ; -- := g_package||'.get_ben_pen_upd_dt_mode';
begin
  --
  g_debug := hr_utility.debug_enabled;
  if g_debug then
   l_proc := g_package||'.get_ben_pen_upd_dt_mode';
   hr_utility.set_location ('Entering '||l_proc,10);
   hr_utility.set_location('IK p_effective_date'||p_effective_date,1234);
   hr_utility.set_location('IK P_desired_datetrack_mode '||P_desired_datetrack_mode,1234);
  end if;
   --
   l_step := 10;
   --
   ben_pen_shd.find_dt_upd_modes
       (p_effective_date        => p_effective_date
       ,p_base_key_value        => p_base_key_value
       ,p_correction        => l_dt_correction
       ,p_update                => l_dt_update
       ,p_update_override       => l_dt_update_override
       ,p_update_change_insert  => l_dt_update_change_insert
       );
--Bug 4431511 calling the find_dt_del_modes
       if(p_ler_typ_cd = 'SCHEDDU'
       and p_desired_datetrack_mode = hr_api.g_delete_next_change) then

       ben_pen_shd.find_dt_del_modes
       (p_effective_date        => p_effective_date
       ,p_base_key_value        => p_base_key_value
       ,p_delete_next_change  => l_dt_delete_next_change
       ,p_zap	=> l_dt_zap
       ,p_delete  => l_dt_delete
       ,p_future_change  => l_dt_future_change
       );
       END if;

       if(p_ler_typ_cd = 'SCHEDDU'
       and p_desired_datetrack_mode = hr_api.g_delete) then

       ben_pen_shd.find_dt_del_modes
       (p_effective_date        => p_effective_date
       ,p_base_key_value        => p_base_key_value
       ,p_delete_next_change  => l_dt_delete_next_change
       ,p_zap	=> l_dt_zap
       ,p_delete  => l_dt_delete
       ,p_future_change  => l_dt_future_change
       );
	END if;
-- End 4431511

   --
   l_step := 20;
   --
   if l_dt_correction then
      if g_debug then
         hr_utility.set_location( 'l_dt_correction',1234);
      end if;
   end if;
   --
   if l_dt_update then
      if g_debug then
         hr_utility.set_location( 'l_dt_update',1234);
      end if;
   end if;
   --
   if l_dt_update_override then
      if g_debug then
         hr_utility.set_location( 'l_dt_update_override',1234);
      end if;
   end if;
   --
   if l_dt_update_change_insert then
      if g_debug then
         hr_utility.set_location( 'l_dt_update_change_insert',1234);
      end if;
   end if;

   if l_dt_delete_next_change then
      if g_debug then
         hr_utility.set_location( 'l_dt_delete_next_change',1234);
      end if;
   end if;

  if l_dt_delete then
      if g_debug then
         hr_utility.set_location( 'l_dt_delete',1234);
      end if;
   end if;

   --
   if (p_desired_datetrack_mode = hr_api.g_update and l_dt_update) then
       p_datetrack_allow := hr_api.g_update;
   elsif (p_desired_datetrack_mode = hr_api.g_correction and l_dt_correction) then
       p_datetrack_allow := hr_api.g_correction;
   elsif (l_dt_update) then
       p_datetrack_allow := hr_api.g_update;
   --Bug 2739965 In case of unrestricted we need to take the
   -- l_dt_update_override case also.
   elsif (l_dt_update_override and -- p_ler_typ_cd = 'SCHEDDU' and    --Bug 5102337 this applied to LE mode also
          p_desired_datetrack_mode = hr_api.g_update) then
       p_datetrack_allow := hr_api.g_update_override;
--Bug 4431511 Added this check to ensure update_override is passed as
--effective datetrack mode if the desired date track mode is
--delete next change in case of unrestricted enrollments
   elsif (l_dt_delete_next_change and p_ler_typ_cd = 'SCHEDDU' and
          p_desired_datetrack_mode = hr_api.g_delete_next_change) then
       p_datetrack_allow := hr_api.g_update_override;
   elsif (l_dt_delete and p_ler_typ_cd = 'SCHEDDU' and
          p_desired_datetrack_mode = hr_api.g_delete) then
       p_datetrack_allow := hr_api.g_update_override;
--End Bug 4431511
   elsif (l_dt_correction) then
       p_datetrack_allow := hr_api.g_correction;
   else
       rpt_error(p_proc => l_proc, p_step => l_step);
       fnd_message.set_name('BEN', 'BEN_91700_DATETRACK_NOT_ALWD');
       fnd_message.set_token('MODE',p_desired_datetrack_mode);
       fnd_message.raise_error;
   end if;
   --
   if g_debug then
      hr_utility.set_location(' P_datetrack_allow '||P_datetrack_allow ,1234);
   end if;
   l_step := 30;
   --
   if g_debug then
      hr_utility.set_location ('Leaving '||l_proc,70);
   end if;
Exception
   when others then
       rpt_error(p_proc => l_proc, p_step => l_step);
       raise;
end;
--
--
-- Added by pxdas for logging change event needed for extract.
--
-- ----------------------------------------------------------------------------
-- |-------------------------< Change_Exists_In_DB >---------------------------|
-- ----------------------------------------------------------------------------
-- Private Function:
--   This procedure checks whether change already exists in DB.
-- Returns:
--   TRUE  - if exists
--   FALSE - otherwise
--
function change_exists_in_db
         (p_person_id     in    number
         ,p_chg_evt_cd    in    varchar2
         ,p_chg_eff_dt    in    date
         ,p_pl_id         in    number
         ,p_oipl_id       in    number
         ) return boolean is
--
  cursor get_change is
  SELECT null
  FROM   ben_ext_chg_evt_log a
  WHERE  a.person_id = p_person_id
  AND    a.chg_evt_cd = p_chg_evt_cd
  AND    a.prmtr_01 = to_char(p_pl_id)
  AND    a.prmtr_02 = to_char(p_oipl_id)
  AND    trunc(a.chg_eff_dt) = trunc(p_chg_eff_dt);
--
  l_proc          varchar2(80) ; -- := g_package || '.change_exists_in_db';
  l_dummy         varchar2(30);
  l_return        boolean;
--
begin
--
  if g_debug then
     l_proc  := g_package || '.change_exists_in_db';
     hr_utility.set_location ('Entering '||l_proc,10);
  end if;
--
  open get_change;
  fetch get_change into l_dummy;
--
  if get_change%found then
    l_return := TRUE;
  else
    l_return := FALSE;
  end if;
--
  close get_change;
--
  return (l_return);
--
  if g_debug then
     hr_utility.set_location ('Leaving '||l_proc,70);
  end if;
--
end change_exists_in_db;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_enrollment >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_enrollment
  (p_validate                       in  boolean   default false
  ,p_prtt_enrt_rslt_id              out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default null
  ,p_oipl_id                        in  number    default null
  ,p_person_id                      in  number    default null
  ,p_assignment_id                  in  number    default null
  ,p_pgm_id                         in  number    default null
  ,p_pl_id                          in  number    default null
  ,p_rplcs_sspndd_rslt_id           in  number    default null
  ,p_ptip_id                        in  number    default null
  ,p_pl_typ_id                      in  number    default null
  ,p_ler_id                         in  number    default null
  ,p_sspndd_flag                    in  varchar2  default 'N'
  ,p_called_from_sspnd              in  varchar2  default 'N'
  ,p_prtt_is_cvrd_flag              in  varchar2  default 'N'
  ,p_bnft_amt                       in  number    default null
  ,p_uom                            in  varchar2  default null
  ,p_orgnl_enrt_dt                  in  date      default null
  ,p_enrt_mthd_cd                   in  varchar2  default null
  ,p_enrt_ovridn_flag               in  varchar2  default 'N'
  ,p_enrt_ovrid_rsn_cd              in  varchar2  default null
  ,p_erlst_deenrt_dt                in  date      default null
  ,p_enrt_cvg_strt_dt               in  date      default null
  ,p_enrt_cvg_thru_dt               in  date      default hr_api.g_eot
  ,p_enrt_ovrid_thru_dt             in  date      default null
  ,p_pl_ordr_num                    in  number    default null
  ,p_plip_ordr_num                  in  number    default null
  ,p_ptip_ordr_num                  in  number    default null
  ,p_oipl_ordr_num                  in  number    default null
  ,p_pen_attribute_category         in  varchar2  default null
  ,p_pen_attribute1                 in  varchar2  default null
  ,p_pen_attribute2                 in  varchar2  default null
  ,p_pen_attribute3                 in  varchar2  default null
  ,p_pen_attribute4                 in  varchar2  default null
  ,p_pen_attribute5                 in  varchar2  default null
  ,p_pen_attribute6                 in  varchar2  default null
  ,p_pen_attribute7                 in  varchar2  default null
  ,p_pen_attribute8                 in  varchar2  default null
  ,p_pen_attribute9                 in  varchar2  default null
  ,p_pen_attribute10                in  varchar2  default null
  ,p_pen_attribute11                in  varchar2  default null
  ,p_pen_attribute12                in  varchar2  default null
  ,p_pen_attribute13                in  varchar2  default null
  ,p_pen_attribute14                in  varchar2  default null
  ,p_pen_attribute15                in  varchar2  default null
  ,p_pen_attribute16                in  varchar2  default null
  ,p_pen_attribute17                in  varchar2  default null
  ,p_pen_attribute18                in  varchar2  default null
  ,p_pen_attribute19                in  varchar2  default null
  ,p_pen_attribute20                in  varchar2  default null
  ,p_pen_attribute21                in  varchar2  default null
  ,p_pen_attribute22                in  varchar2  default null
  ,p_pen_attribute23                in  varchar2  default null
  ,p_pen_attribute24                in  varchar2  default null
  ,p_pen_attribute25                in  varchar2  default null
  ,p_pen_attribute26                in  varchar2  default null
  ,p_pen_attribute27                in  varchar2  default null
  ,p_pen_attribute28                in  varchar2  default null
  ,p_pen_attribute29                in  varchar2  default null
  ,p_pen_attribute30                in  varchar2  default null
  ,p_request_id                     in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  ,p_object_version_number          out nocopy number
  ,p_per_in_ler_id                  in  number    default null
  ,p_bnft_typ_cd                    in  varchar2  default null
  ,p_bnft_ordr_num                  in  number    default null
  ,p_prtt_enrt_rslt_stat_cd         in  varchar2  default null
  ,p_bnft_nnmntry_uom               in  varchar2  default null
  ,p_comp_lvl_cd                    in  varchar2  default null
  ,p_effective_date                 in  date
  ,p_multi_row_validate             in  boolean    default TRUE
  ,p_elig_per_elctbl_chc_id         in  number
  ,p_prtt_enrt_rslt_id_o            in  number
  ,p_suspend_flag                   out nocopy varchar2
  ,p_prtt_enrt_interim_id           out nocopy number
  ,p_datetrack_mode                 in  varchar2
  ,p_dpnt_actn_warning              out nocopy boolean
  ,p_bnf_actn_warning               out nocopy boolean
  ,p_ctfn_actn_warning              out nocopy boolean
  ,p_enrt_bnft_id                   in  number   default NULL
  ,p_source                         in  varchar2 default null
  ) is
  --
  -- Declare cursors and local variables
  --
l_chg_evt_cd                hr_lookups.lookup_code%type;
l_prtt_enrt_rslt_id         ben_prtt_enrt_rslt_f.prtt_enrt_rslt_id%TYPE;
l_effective_start_date      ben_prtt_enrt_rslt_f.effective_start_date%TYPE;
l_effective_end_date        ben_prtt_enrt_rslt_f.effective_end_date%TYPE;
l_effective_date            date;
l_proc                      varchar2(72); --  := g_package||'create_enrollment';
l_object_version_number     ben_prtt_enrt_rslt_f.object_version_number%TYPE;
l_return_to_exist_cvg_flag  varchar2(30) := 'N';
l_datetrack_mode            varchar2(30);
l_step                      integer;
l_crntly_enrd_flag          varchar2(30) := 'N';
l_post_rslt_flag            varchar2(30) := 'Y';
l_prtt_prem_id              number;
l_exists                    varchar2(1);
l_create                    varchar2(1) := 'N';
l_update                    varchar2(1) := 'N';
l_dummy                     varchar2(1);
--
/* Start of Changes for WWBUG: 1646442 : added declarations     */
l_ppe_datetrack_mode        varchar2(30);
l_ppe_dt_to_use             date;
lb_correction               boolean;
lb_update                   boolean;
lb_update_override          boolean;
lb_update_change_insert     boolean;
l_enrt_cvg_strt_dt          date;
l_enrt_cvg_strt_dt_cd       varchar2(30);
l_enrt_cvg_strt_dt_rl       number;
l_rt_strt_dt                date;
l_rt_strt_dt_cd             varchar2(30);
l_rt_strt_dt_rl             number;
l_enrt_cvg_end_dt           date;
l_enrt_cvg_end_dt_cd        varchar2(30);
l_enrt_cvg_end_dt_rl        number;
l_rt_end_dt                 date;
l_rt_end_dt_cd              varchar2(30);
l_rt_end_dt_rl              number;
/* End of Changes for WWBUG: 1646442 : added declarations       */
--
l_global_epe_rec ben_global_enrt.g_global_epe_rec_type;
l_global_pen_rec ben_prtt_enrt_rslt_f%rowtype;
l_pl_rec         ben_cobj_cache.g_pl_inst_row;
l_pgm_rec        ben_cobj_cache.g_pgm_inst_row;
l_oipl_rec       ben_cobj_cache.g_oipl_inst_row;
--
cursor c_ptip_enrollment_info  is
       select pen.prtt_enrt_rslt_id,
              pen.pl_id,
              pen.oipl_id,
              pen.pl_typ_id
       from   ben_prtt_enrt_rslt_f pen
       where  pen.person_id=p_person_id and
              pen.business_group_id =p_business_group_id and
              pen.prtt_enrt_rslt_stat_cd is null and
              pen.sspndd_flag='N' and
              pen.prtt_enrt_rslt_id <> l_prtt_enrt_rslt_id and
              pen.effective_end_date = hr_api.g_eot and
              p_enrt_cvg_strt_dt-1 <=
                pen.enrt_cvg_thru_dt and
              pen.enrt_cvg_strt_dt < pen.effective_end_date and
              p_ptip_id=pen.ptip_id;

l_ptip_enrt c_ptip_enrollment_info%rowtype;

cursor c_pen (l_prtt_enrt_rslt_id number) is
    select prtt_enrt_rslt_id
          ,effective_start_date
          ,enrt_cvg_strt_dt
          ,enrt_cvg_thru_dt
          ,pgm_id
          ,ptip_id
          ,pl_typ_id
          ,pl_id
          ,oipl_id
          ,object_version_number
      from ben_prtt_enrt_rslt_f
     where prtt_enrt_rslt_id = l_prtt_enrt_rslt_id
       and p_effective_date between
               effective_start_date and effective_end_date;
--
l_pen_o                     c_pen%rowtype;
--
cursor c_prem is
  select ecr.val,
         ecr.uom,
         ecr.actl_prem_id,
         pil.lf_evt_ocrd_dt,
         pil.ler_id
  from   ben_enrt_prem ecr,
         ben_per_in_ler pil,
         ben_elig_per_elctbl_chc epe
  where  ecr.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id
    and  epe.elig_per_elctbl_chc_id = ecr.elig_per_elctbl_chc_id
    and  pil.per_in_ler_id = epe.per_in_ler_id
    and  pil.per_in_ler_stat_cd = 'STRTD'
    and  NVL(ecr.enrt_bnft_id, -1) = NVL(p_enrt_bnft_id, -1); -- 3573173. Added this condition.
   -- and  pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT');
--
l_prem c_prem%rowtype;
--
-- Commented out the join to per-in-ler for performance.  I belive that
-- any result we are processing could not be attached to a backed out
-- life event.  lamc 4/5/00.
--
-- Bug#1646442: replaced following cursor:
--
/*********************** START OF CODE PRIOR TO WWBUG:1646442  ********
cursor c_ppe (p_prtt_enrt_rslt_id in number,
              p_actl_prem_id      in number) is
  select ppe.prtt_prem_id,
         ppe.std_prem_uom,
         ppe.std_prem_val,
         ppe.actl_prem_id,
         ppe.object_version_number
    from ben_prtt_prem_f ppe
--         ben_per_in_ler pil
   where ppe.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and ppe.actl_prem_id = p_actl_prem_id
     and p_effective_date between
         ppe.effective_start_date and ppe.effective_end_date;
--     and pil.per_in_ler_id=ppe.per_in_ler_id
--     and pil.business_group_id=ppe.business_group_id
 --    and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
***************************END OF CODE PRIOR TO WWBUG:1646442 ************/
/*  Start of Changes for WWBUG: 1646442                                 */
 cursor c_ppe (p_prtt_enrt_rslt_id  in number,
               p_actl_prem_id       in number,
               p_ppe_dt_to_use      in date) is
  select ppe.prtt_prem_id,
         ppe.std_prem_uom,
         ppe.std_prem_val,
         ppe.actl_prem_id,
         ppe.object_version_number
    from ben_prtt_prem_f ppe
   where ppe.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and ppe.actl_prem_id = p_actl_prem_id
     and /*p_effective_date*/ p_ppe_dt_to_use between
         ppe.effective_start_date and ppe.effective_end_date;
/*  End of Changes for WWBUG: 1646442                                   */
--
l_ppe c_ppe%rowtype;
--
cursor c_check_cvrd_in_plan is
  select null
  from   ben_elig_cvrd_dpnt_f  pdp
        ,ben_prtt_enrt_rslt_f  pen
        ,ben_pgm_f             pgm
  where  pdp.dpnt_person_id = p_person_id
  and    pdp.business_group_id  = p_business_group_id
  and    p_effective_date
  between pdp.effective_start_date and pdp.effective_end_date
  and    pdp.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
  --and    pen.prtt_enrt_rslt_stat_cd not in ('BCKDT', 'VOIDD')
  and    pen.prtt_enrt_rslt_stat_cd is null
  and    pdp.cvg_thru_dt = hr_api.g_eot
  and    pen.pgm_id = p_pgm_id
  and    pen.pgm_id = pgm.pgm_id
  and    pen.prtt_enrt_rslt_stat_cd is null
  and    pgm.pgm_typ_cd like 'COBRA%'
  and    p_effective_date between
         pen.effective_start_date and pen.effective_end_date
  and    pen.pl_id = p_pl_id
  and    pen.business_group_id  = pdp.business_group_id
  and    p_effective_date between
         pen.effective_start_date and pen.effective_end_date
  and    pgm.business_group_id = pen.business_group_id
  and    p_effective_date between
         pgm.effective_start_date and pgm.effective_end_date;
--
/* Start of Changes for Bug: 1646442: added cursor              */
cursor c_pel (p_elig_pe_elctbl_chc_id number) is
   select pel.enrt_perd_id,pel.lee_rsn_id
   from ben_pil_elctbl_chc_popl pel
       ,ben_elig_per_elctbl_chc epe
   where pel.pil_elctbl_chc_popl_id = epe.pil_elctbl_chc_popl_id
   and epe.elig_per_elctbl_chc_id = p_elig_pe_elctbl_chc_id;
--
-- Bug : 3866580
cursor c_pl_typ_opt_typ_cd (pl_typ_id number, p_effective_date date) is
   select ptp.opt_typ_cd
     from ben_pl_typ_f ptp
    where ptp.pl_typ_id = p_pl_typ_id
      and p_effective_date between ptp.effective_start_date
                               and ptp.effective_end_date;

l_pl_typ_opt_typ_cd    ben_pl_typ.opt_typ_cd%type;
-- Bug : 3866580
--
l_pel  c_pel%rowtype;
/* End of Changes for Bug: 1646442: added cursor                */
l_process_dpnt      boolean := false;
l_process_bnf       boolean := false;
--
begin
    --
    g_debug := hr_utility.debug_enabled;
    if g_debug then
       l_proc  := g_package||'create_enrollment';
       hr_utility.set_location('Entering:'|| l_proc, 10);
    end if;
    g_multi_rows_validate := p_multi_row_validate;
    l_step := 10;
    If (p_multi_row_validate) then
        l_post_rslt_flag := 'Y';
    Else
        l_post_rslt_flag := 'N';
    End if;
    --
    -- Ensure elctbl_chc_id is not NULL.
    --
    hr_api.mandatory_arg_error
              (p_api_name       => l_proc
              ,p_argument       => 'elig_per_elctbl_chc_id'
              ,p_argument_value => p_elig_per_elctbl_chc_id
              );
    --
    -- Issue a savepoint if operating in validation only mode
    --
    if p_called_from_sspnd = 'N' then
       savepoint create_enrollment;
    else
       savepoint create_enrollment_sspnd;
    end if;
    --
    l_step := 15;
    --
    l_crntly_enrd_flag := 'N';
    if g_debug then
       hr_utility.set_location(l_proc, 20);
    end if;
    l_step := 20;
    --
    -- Get choice data from prtt_per_elctbl_chc table
    --
    ben_global_enrt.get_epe  -- choice
       (p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id
       ,p_global_epe_rec         => l_global_epe_rec);

    ben_cobj_cache.get_pl_dets
       (p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_pl_id             => l_global_epe_rec.pl_id
       ,p_inst_row          => l_pl_rec);

    if l_global_epe_rec.oipl_id is not null then
      ben_cobj_cache.get_oipl_dets
         (p_business_group_id => p_business_group_id
         ,p_effective_date    => p_effective_date
         ,p_oipl_id           => l_global_epe_rec.oipl_id
         ,p_inst_row          => l_oipl_rec);
    end if;

    l_step:=25;
    --
    --  Check if person is also a covered dependent in the plan.
    --  This is a COBRA edit.  For example,if the person is covered under
    --  employee + family, he/she cannot separate coverage.
    --
    if p_pgm_id is not null then
      open c_check_cvrd_in_plan;
      fetch c_check_cvrd_in_plan into l_exists;
      if c_check_cvrd_in_plan%found then
        close c_check_cvrd_in_plan;
        fnd_message.set_name('BEN','BEN_92243_CVRD_IN_PLAN');
        fnd_message.raise_error;
      end if;
      close c_check_cvrd_in_plan;
    end if;
    --
    l_step := 30;
    --
    if (l_global_epe_rec.prtt_enrt_rslt_id is not NULL) then
       ben_global_enrt.get_pen  -- result
       (p_prtt_enrt_rslt_id      => l_global_epe_rec.prtt_enrt_rslt_id
       ,p_effective_date         => p_effective_date
       ,p_global_pen_rec         => l_global_pen_rec);
    else
       ben_global_enrt.clear_pen  -- result
       (p_global_pen_rec         => l_global_pen_rec);
    end if;
    l_step := 40;
--
-- commented out to allow for creation of a new result
-- when the benefit amount changes (in benelinf).  It looks
-- like benelinf is the only process which calls create_enrt
-- so... would like it to only do a create and copy the child
-- stuff over if a p_prtt_enrt_rslt_id is passed in.
-- jcarpent 7/28/1999
-- lamc removed commented code 4/5/00
        l_step := 80;
        if (p_prtt_enrt_rslt_id_o is not NULL) then
            open c_pen(p_prtt_enrt_rslt_id_o);
            fetch c_pen into l_pen_o;
            if c_pen%notfound then
                l_step := 90;
                close c_pen;
                rpt_error(p_proc => l_proc, p_step => l_step);
                fnd_message.set_name('BEN','BEN_91711_ENRT_RSLT_NOT_FND');
                fnd_message.set_token('PROC',l_proc);
                fnd_message.set_token('ID', to_char(p_prtt_enrt_rslt_id_o));
                fnd_message.set_token('PERSON_ID', to_char(p_person_id));
                fnd_message.set_token('LER_ID', to_char(p_ler_id));
                fnd_message.set_token('EFFECTIVE_DATE',to_char(p_effective_date));
                fnd_message.raise_error;
            else
                close c_pen;
                if (p_datetrack_mode = hr_api.g_correction) then
                    l_effective_date := l_pen_o.effective_start_date;
                else
                    l_effective_date := p_effective_date;
                end if;
            end if;
        else
            l_pen_o := NULL;
            l_effective_date := p_effective_date;
        end if;
        l_step := 100;
        create_PRTT_ENRT_RESULT
           (p_validate                       =>  FALSE
           ,p_prtt_enrt_rslt_id              =>  l_prtt_enrt_rslt_id
           ,p_effective_start_date           =>  l_effective_start_date
           ,p_effective_end_date             =>  l_effective_end_date
           ,p_business_group_id              =>  p_business_group_id
           ,p_oipl_id                        =>  p_oipl_id
           ,p_person_id                      =>  p_person_id
           ,p_assignment_id                  =>  p_assignment_id
           ,p_pgm_id                         =>  p_pgm_id
           ,p_pl_id                          =>  p_pl_id
           ,p_rplcs_sspndd_rslt_id           =>  p_rplcs_sspndd_rslt_id
           ,p_ptip_id                        =>  p_ptip_id
           ,p_pl_typ_id                      =>  p_pl_typ_id
           ,p_ler_id                         =>  p_ler_id
           ,p_sspndd_flag                    =>  p_sspndd_flag
           ,p_prtt_is_cvrd_flag              =>  p_prtt_is_cvrd_flag
           ,p_bnft_amt                       =>  p_bnft_amt
           ,p_uom                            =>  p_uom
           ,p_orgnl_enrt_dt                  =>  p_orgnl_enrt_dt
           ,p_enrt_mthd_cd                   =>  p_enrt_mthd_cd
           ,p_enrt_ovridn_flag               =>  p_enrt_ovridn_flag
           ,p_enrt_ovrid_rsn_cd              =>  p_enrt_ovrid_rsn_cd
           ,p_erlst_deenrt_dt                =>  p_erlst_deenrt_dt
           ,p_enrt_cvg_strt_dt               =>  p_enrt_cvg_strt_dt
           ,p_enrt_cvg_thru_dt               =>  p_enrt_cvg_thru_dt
           ,p_enrt_ovrid_thru_dt             =>  p_enrt_ovrid_thru_dt
           ,p_pl_ordr_num                    =>  p_pl_ordr_num
           ,p_plip_ordr_num                  =>  p_plip_ordr_num
           ,p_ptip_ordr_num                  =>  p_ptip_ordr_num
           ,p_oipl_ordr_num                  =>  p_oipl_ordr_num
           ,p_pen_attribute_category         =>  p_pen_attribute_category
           ,p_pen_attribute1                 =>  p_pen_attribute1
           ,p_pen_attribute2                 =>  p_pen_attribute2
           ,p_pen_attribute3                 =>  p_pen_attribute3
           ,p_pen_attribute4                 =>  p_pen_attribute4
           ,p_pen_attribute5                 =>  p_pen_attribute5
           ,p_pen_attribute6                 =>  p_pen_attribute6
           ,p_pen_attribute7                 =>  p_pen_attribute7
           ,p_pen_attribute8                 =>  p_pen_attribute8
           ,p_pen_attribute9                 =>  p_pen_attribute9
           ,p_pen_attribute10                =>  p_pen_attribute10
           ,p_pen_attribute11                =>  p_pen_attribute11
           ,p_pen_attribute12                =>  p_pen_attribute12
           ,p_pen_attribute13                =>  p_pen_attribute13
           ,p_pen_attribute14                =>  p_pen_attribute14
           ,p_pen_attribute15                =>  p_pen_attribute15
           ,p_pen_attribute16                =>  p_pen_attribute16
           ,p_pen_attribute17                =>  p_pen_attribute17
           ,p_pen_attribute18                =>  p_pen_attribute18
           ,p_pen_attribute19                =>  p_pen_attribute19
           ,p_pen_attribute20                =>  p_pen_attribute20
           ,p_pen_attribute21                =>  p_pen_attribute21
           ,p_pen_attribute22                =>  p_pen_attribute22
           ,p_pen_attribute23                =>  p_pen_attribute23
           ,p_pen_attribute24                =>  p_pen_attribute24
           ,p_pen_attribute25                =>  p_pen_attribute25
           ,p_pen_attribute26                =>  p_pen_attribute26
           ,p_pen_attribute27                =>  p_pen_attribute27
           ,p_pen_attribute28                =>  p_pen_attribute28
           ,p_pen_attribute29                =>  p_pen_attribute29
           ,p_pen_attribute30                =>  p_pen_attribute30
           ,p_request_id                     =>  fnd_global.conc_request_id
           ,p_program_application_id         =>  fnd_global.prog_appl_id
           ,p_program_id                     =>  fnd_global.conc_program_id
           ,p_program_update_date            =>  sysdate
           ,p_object_version_number          =>  l_object_version_number
           ,p_per_in_ler_id                  =>  p_per_in_ler_id
           ,p_bnft_typ_cd                    =>  p_bnft_typ_cd
           ,p_bnft_ordr_num                  =>  p_bnft_ordr_num
           ,p_prtt_enrt_rslt_stat_cd         =>  p_prtt_enrt_rslt_stat_cd
           ,p_bnft_nnmntry_uom               =>  p_bnft_nnmntry_uom
           ,p_comp_lvl_cd                    =>  p_comp_lvl_cd
           ,p_effective_date                 =>  l_effective_date
           ,p_multi_row_validate             =>  p_multi_row_validate
           );

           l_create := 'Y';

           /*Added for Bug 7561395*/
	   g_enrt_list.extend;
           g_enrt_list(g_enrt_list.last) := l_prtt_enrt_rslt_id;
	   hr_utility.set_location(' Extend table ',500);
	   hr_utility.set_location('New pen_id '|| g_new_prtt_enrt_rslt_id,500);
	   hr_utility.set_location('Intmr Rslt Id '|| p_rplcs_sspndd_rslt_id,500);
	   hr_utility.set_location('oipl id cr  '|| p_oipl_id,500);
	   /*Ended for Bug 7561395*/

           ben_global_enrt.reload_pen  -- result globals loaded after insert.
             (p_prtt_enrt_rslt_id      => l_prtt_enrt_rslt_id
             ,p_effective_date         => p_effective_date
             ,p_global_pen_rec         => l_global_pen_rec);

  --
   l_step := 105;
   -- if the result will be voided in the rhi or the rslt is being
   -- inserted as 'backed out', do not update choice fk.
   -- This call needs to be before the update to premiums because it
   -- assumes the chc was already updated with the rslt id.
   if p_enrt_cvg_strt_dt > nvl(p_enrt_cvg_thru_dt,p_enrt_cvg_strt_dt)
        or p_prtt_enrt_rslt_stat_cd = 'BCKDT' then
       null;
   else
      l_step := 110;
      ben_ELIG_PER_ELC_CHC_api.update_ELIG_PER_ELC_CHC
           (p_validate                       => FALSE
           ,p_elig_per_elctbl_chc_id         => p_elig_per_elctbl_chc_id
           ,p_prtt_enrt_rslt_id              => l_prtt_enrt_rslt_id
           ,p_object_version_number          =>
                  l_global_epe_rec.object_version_number
           ,p_effective_date                 => p_effective_date
           ,p_request_id                     => fnd_global.conc_request_id
           ,p_program_application_id         => fnd_global.prog_appl_id
           ,p_program_id                     => fnd_global.conc_program_id
           ,p_program_update_date            => sysdate
           );

        ben_global_enrt.reload_epe  -- chc globals re-loaded after update.
          (p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id
          ,p_global_epe_rec         => l_global_epe_rec);

    end if;

   l_step := 115;

   if (l_update = 'Y' or l_create = 'Y') then
   --
      for l_prem in c_prem loop
      --
         l_step := 120;
         -- bug 1587837. jcarpent reset l_ppe.prtt_prem_id
         l_ppe.prtt_prem_id:=null;
         --
         /* Start of Changes for WWBUG: 1646442: added           */
         open c_pel(p_elig_per_elctbl_chc_id);
         fetch c_pel into l_pel;
         close c_pel;

         ben_determine_date.rate_and_coverage_dates
                  (p_which_dates_cd         => 'R'
                  ,p_date_mandatory_flag    => 'Y'
                  ,p_compute_dates_flag     => 'Y'
                  ,p_business_group_id      => p_business_group_id
                  ,P_PER_IN_LER_ID          => p_per_in_ler_id
                  ,P_PERSON_ID              => p_person_id
                  ,P_PGM_ID                 => p_pgm_id
                  ,P_PL_ID                  => p_pl_id
                  ,P_OIPL_ID                => p_oipl_id
                  ,P_LEE_RSN_ID             => l_pel.lee_rsn_id
                  ,P_ENRT_PERD_ID           => l_pel.enrt_perd_id
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
                  ,p_effective_date         => p_effective_date
                  ,p_lf_evt_ocrd_dt         => nvl(l_prem.lf_evt_ocrd_dt,p_effective_date)
                  );

         l_ppe_dt_to_use := greatest(p_enrt_cvg_strt_dt,l_rt_strt_dt);
         hr_utility.set_location( 'cvg start dt ' || p_enrt_cvg_strt_dt, 99 ) ;
         hr_utility.set_location( 'l_ppe_dt_to_use ' || l_ppe_dt_to_use, 99 ) ;

         /* End of Changes for WWBUG: 1646442: addition        */
         --
         /*
            CODE PRIOR TO WWBUG: 1646442
         open c_ppe(l_prtt_enrt_rslt_id, l_prem.actl_prem_id);
         */
         /* Start of Changes for WWBUG: 1646442                 */
         open c_ppe(l_prtt_enrt_rslt_id, l_prem.actl_prem_id,l_ppe_dt_to_use);
         /* End of Changes for WWBUG: 1646442                   */
         fetch c_ppe into l_ppe;
         close c_ppe;
         --
         l_step := 125;
         if l_ppe.prtt_prem_id is not null and l_update = 'Y' then
           -- Because the benefit amount could have changed, and the premiums
           -- can be based on the benefit amount, re-calc it.  It does a recalc
           -- if the benefit amount is entered at enrollment.
           -- PPE is from prtt-prem.  prem is from enrt-prem.
           ben_PRTT_PREM_api.recalc_PRTT_PREM
                 (p_prtt_prem_id                   =>  l_ppe.prtt_prem_id
                 ,p_std_prem_uom                   =>  l_prem.uom
                 ,p_std_prem_val                   =>  l_prem.val  -- in/out
                 ,p_actl_prem_id                   =>  l_prem.actl_prem_id
                 ,p_prtt_enrt_rslt_id              =>  l_prtt_enrt_rslt_id
                 ,p_per_in_ler_id                  =>  p_per_in_ler_id
                 ,p_ler_id                         =>  l_prem.ler_id
                 ,p_lf_evt_ocrd_dt                 =>  l_prem.lf_evt_ocrd_dt
                 ,p_elig_per_elctbl_chc_id         =>  p_elig_per_elctbl_chc_id
                 ,p_enrt_bnft_id                   =>  p_enrt_bnft_id
                 ,p_business_group_id              =>  p_business_group_id
                 ,p_effective_date                 =>  p_effective_date
                 -- bof FONM
                 ,p_enrt_cvg_strt_dt               =>  nvl(l_enrt_cvg_strt_dt ,l_ppe_dt_to_use)
                 ,p_rt_strt_dt                     => l_rt_strt_dt
                       -- eof FONM
                 );
           l_step := 127;
           --
           /* Start of Changes for WWBUG: 1646442: added                */
           --
           -- Find the valid datetrack modes.
           --
           dt_api.find_dt_upd_modes
                  (p_effective_date       => l_ppe_dt_to_use,
                   p_base_table_name      => 'BEN_PRTT_PREM_F',
                   p_base_key_column      => 'prtt_prem_id',
                   p_base_key_value       => l_ppe.prtt_prem_id,
                   p_correction           => lb_correction,
                   p_update               => lb_update,
                   p_update_override      => lb_update_override,
                   p_update_change_insert => lb_update_change_insert);

           if lb_update_override then
           --
             l_ppe_datetrack_mode := hr_api.g_update_override;
           --
           elsif lb_update then
           --
             l_ppe_datetrack_mode := hr_api.g_update;
           --
           else
           --
             l_ppe_datetrack_mode := hr_api.g_correction;
           end if;
           /* End of Changes for WWBUG: 1646442                         */

           ben_prtt_prem_api.update_prtt_prem
              ( p_validate                => FALSE
               ,p_prtt_prem_id            => l_ppe.prtt_prem_id
               ,p_effective_start_date    => p_effective_start_date
               ,p_effective_end_date      => p_effective_end_date
               ,p_std_prem_uom            => l_prem.uom
               ,p_std_prem_val            => l_prem.val
               ,p_actl_prem_id            => l_prem.actl_prem_id
               ,p_prtt_enrt_rslt_id       => l_prtt_enrt_rslt_id
               ,p_per_in_ler_id           => p_per_in_ler_id
               ,p_business_group_id       => p_business_group_id
               ,p_object_version_number   => l_ppe.object_version_number
               ,p_request_id              => fnd_global.conc_request_id
               ,p_program_application_id  => fnd_global.prog_appl_id
               ,p_program_id              => fnd_global.conc_program_id
               ,p_program_update_date     => sysdate
             /* CODE PRIOR TO WWBUG: 1646442
               ,p_effective_date          => p_effective_date
               ,p_datetrack_mode          => l_datetrack_mode
             */
             /* Start of Changes for WWBUG: 1646442             */
               ,p_effective_date          => l_ppe_dt_to_use
               ,p_datetrack_mode          => l_ppe_datetrack_mode
             /* End of Changes for WWBUG: 1646442               */
              );
         --
         elsif l_create = 'Y' or l_ppe.prtt_prem_id is null then
           -- Because the benefit amount could have changed, and the premiums
           -- can be based on the benefit amount, re-calc it.  It does a recalc
           -- if the benefit amount is entered at enrollment.
           -- PPE is from prtt-prem.  prem is from enrt-prem.
           ben_PRTT_PREM_api.recalc_PRTT_PREM
                 (p_prtt_prem_id                   =>  null
                 ,p_std_prem_uom                   =>  l_prem.uom
                 ,p_std_prem_val                   =>  l_prem.val  -- in/out
                 ,p_actl_prem_id                   =>  l_prem.actl_prem_id
                 ,p_prtt_enrt_rslt_id              =>  l_prtt_enrt_rslt_id
                 ,p_per_in_ler_id                  =>  p_per_in_ler_id
                 ,p_ler_id                         =>  l_prem.ler_id
                 ,p_lf_evt_ocrd_dt                 =>  l_prem.lf_evt_ocrd_dt
                 ,p_elig_per_elctbl_chc_id         =>  p_elig_per_elctbl_chc_id
                 ,p_enrt_bnft_id                   =>  p_enrt_bnft_id
                 ,p_business_group_id              =>  p_business_group_id
                 ,p_effective_date                 =>  p_effective_date
                 -- bof FONM
                 ,p_enrt_cvg_strt_dt               => nvl(l_enrt_cvg_strt_dt,l_ppe_dt_to_use)
                 ,p_rt_strt_dt                     => l_rt_strt_dt
                       -- eof FONM
                  );
           l_step := 130;
           ben_prtt_prem_api.create_prtt_prem
              ( p_validate                => FALSE
               ,p_prtt_prem_id            => l_prtt_prem_id
               ,p_effective_start_date    => p_effective_start_date
               ,p_effective_end_date      => p_effective_end_date
               ,p_std_prem_uom            => l_prem.uom
               ,p_std_prem_val            => l_prem.val
               ,p_actl_prem_id            => l_prem.actl_prem_id
               ,p_prtt_enrt_rslt_id       => l_prtt_enrt_rslt_id
               ,p_per_in_ler_id           => p_per_in_ler_id
               ,p_business_group_id       => p_business_group_id
               ,p_object_version_number   => l_object_version_number
               ,p_request_id              => fnd_global.conc_request_id
               ,p_program_application_id  => fnd_global.prog_appl_id
               ,p_program_id              => fnd_global.conc_program_id
               ,p_program_update_date     => sysdate
               /*
                        CODE PRIOR TO WWBUG: 1646442
               ,p_effective_date          => p_effective_date
               */
                /* Start of Changes for WWBUG: 1646442             */
                ,p_effective_date          => l_ppe_dt_to_use
                /* End of Changes for WWBUG: 1646442               */
              );
         --
         end if;
      --
      end loop;
   --
   end if;
   --
   l_step := 135;
   if p_comp_lvl_cd in ('PLANFC', 'PLANIMP') then
      null;
   else
     if l_global_epe_rec.pgm_id is not null then
       ben_provider_pools.accumulate_pools
          (p_validate               => FALSE
          ,p_person_id              => p_person_id
          ,p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id
          ,p_business_group_id      => p_business_group_id
          ,p_enrt_mthd_cd           => p_enrt_mthd_cd
          ,p_effective_date         => p_effective_date);
      end if;
    end if;
    l_step := 140;
    if (l_global_epe_rec.prtt_enrt_rslt_id is not NULL
       and l_crntly_enrd_flag = 'Y') then
       l_return_to_exist_cvg_flag := 'Y';
    else
       l_return_to_exist_cvg_flag := 'N';
    end if;
      --
      -- write to change log, except for when called by benelinf where
      -- the change log is written directly from there.
      --
     l_step := 145;
     if p_source is null or
        p_source <> 'benelinf' then
     ben_ext_chlg.log_benefit_chg
        (p_action                      => 'CREATE'
        ,p_pl_id                       =>  p_pl_id
        ,p_oipl_id                     =>  p_oipl_id
        ,p_enrt_cvg_strt_dt            =>  p_enrt_cvg_strt_dt
        ,p_enrt_cvg_end_dt             =>  p_enrt_cvg_thru_dt
        ,p_prtt_enrt_rslt_id           =>  l_prtt_enrt_rslt_id
        ,p_per_in_ler_id               =>  p_per_in_ler_id
        ,p_person_id                   =>  p_person_id
        ,p_business_group_id           =>  p_business_group_id
        ,p_effective_date              =>  l_effective_date
        );
    end if;
    --
    --
    -- If there was enrollment terminated before this new choice elected,
    -- then the dependents for old enrollment can be re-used, or user select
    -- the currently coveraged enrollment as his/her election, then use old
    -- dependent information as well.
    --
    l_step := 150;
    if g_debug then
      hr_utility.set_location('p_prtt_enrt_rslt_id_o'||
        to_char(p_prtt_enrt_rslt_id_o)||' l_epe.prtt_enrt_rslt_id'||
        to_char(l_global_epe_rec.prtt_enrt_rslt_id),150);
      hr_utility.set_location(
        ' flag'||l_global_epe_rec.crntly_enrd_flag, 150);
    end if;

    if (p_prtt_enrt_rslt_id_o is not NULL
       or (l_global_epe_rec.prtt_enrt_rslt_id is not NULL
           and  nvl(l_global_epe_rec.crntly_enrd_flag, 'X') = 'Y') ) then
        l_step := 155;
        if l_global_epe_rec.alws_dpnt_dsgn_flag = 'Y' then
          l_process_dpnt := true;
        else
          l_process_dpnt := false;
          if l_global_epe_rec.pgm_id is not null then
             ben_cobj_cache.get_pgm_dets
             (p_business_group_id => p_business_group_id
             ,p_effective_date    => p_effective_date
             ,p_pgm_id            => l_global_epe_rec.pgm_id
             ,p_inst_row          => l_pgm_rec);
             hr_utility.set_location('process dptn  level ' ||l_pgm_rec.dpnt_dsgn_lvl_cd , 150);
            if l_pgm_rec.dpnt_dsgn_lvl_cd='PTIP' then
               open c_ptip_enrollment_info;
               fetch c_ptip_enrollment_info into l_ptip_enrt;
               if c_ptip_enrollment_info%found then
                  l_process_dpnt:= true;
                  hr_utility.set_location('process dptn  true ', 150);
               end if ;
            end if ;
          end if ;
        end if;
        if l_pl_rec.bnf_dsgn_cd is not null then
          l_process_bnf := true;
        else
          l_process_bnf := false;
        end if;
        ben_mng_dpnt_bnf.recycle_dpnt_bnf
            (p_validate                   => FALSE
            ,p_new_prtt_enrt_rslt_id      => l_prtt_enrt_rslt_id
            ,p_old_prtt_enrt_rslt_id      => p_prtt_enrt_rslt_id_o
            ,P_NEW_ENRT_RSLT_OVN          => l_object_version_number
            ,p_new_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id
            ,p_person_id                  => p_person_id
            ,p_return_to_exist_cvg_flag   => l_return_to_exist_cvg_flag
            ,p_old_pl_id                  => l_pen_o.pl_id
            ,p_new_pl_id                  => p_pl_id
            ,p_old_oipl_id                => l_pen_o.oipl_id
            ,p_new_oipl_id                => p_oipl_id
            ,p_old_pl_typ_id              => l_pen_o.pl_typ_id
            ,p_new_pl_typ_id              => p_pl_typ_id
            ,p_pgm_id                     => p_pgm_id
            ,p_ler_id                     => p_ler_id
            ,p_per_in_ler_id              => p_per_in_ler_id
            ,p_dpnt_cvg_strt_dt_cd        => l_global_epe_rec.dpnt_cvg_strt_dt_cd
            ,p_dpnt_cvg_strt_dt_rl        => l_global_epe_rec.dpnt_cvg_strt_dt_rl
            ,p_business_group_id          => p_business_group_id
            ,p_ENRT_CVG_STRT_DT           => l_global_pen_rec.enrt_cvg_strt_dt
            ,p_effective_date             => p_effective_date
            ,p_datetrack_mode             => p_datetrack_mode
            ,p_process_dpnt               => l_process_dpnt
            ,p_process_bnf                => l_process_bnf
            );
        --
        --  Copy primary care provider if the plan has not changed but the
        --  option in plan has changed.
        --
        l_step := 160;
        If (l_pen_o.pl_id = p_pl_id and l_pen_o.oipl_id <> p_oipl_id) then
          ben_mng_prmry_care_prvdr.recycle_ppr
            (P_VALIDATE               => FALSE
            ,P_NEW_PRTT_ENRT_RSLT_ID  => l_prtt_enrt_rslt_id
            ,P_OLD_PRTT_ENRT_RSLT_ID  => p_prtt_enrt_rslt_id_o
            ,P_BUSINESS_GROUP_ID      => P_business_group_id
            ,P_EFFECTIVE_DATE         => p_effective_date
            ,P_DATETRACK_MODE         => p_datetrack_mode
            );
        End if;
    elsif p_pgm_id is not null
        /*and l_global_epe_rec.alws_dpnt_dsgn_flag = 'Y'
         if previously enrolled then carry forward even if the flaf is 'N'  */
        then
      --
      -- no old result passed in or not reenrolling in same choice
      -- different coverage, sooo..
      -- handle dependent recycling at ptip level if used to be
      -- enrolled in plan type but coverage ended due to eligibility.
      --
      ben_cobj_cache.get_pgm_dets
       (p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_pgm_id            => l_global_epe_rec.pgm_id
       ,p_inst_row          => l_pgm_rec);
      if l_pgm_rec.dpnt_dsgn_lvl_cd='PTIP' then
        open c_ptip_enrollment_info;
        fetch c_ptip_enrollment_info into l_ptip_enrt;
        if c_ptip_enrollment_info%found then
          ben_mng_dpnt_bnf.recycle_dpnt_bnf
            (p_validate                   => FALSE
            ,p_new_prtt_enrt_rslt_id      => l_prtt_enrt_rslt_id
            ,p_old_prtt_enrt_rslt_id      => l_ptip_enrt.prtt_enrt_rslt_id
            ,P_NEW_ENRT_RSLT_OVN          => l_object_version_number
            ,p_new_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id
            ,p_person_id                  => p_person_id
            ,p_return_to_exist_cvg_flag   => l_return_to_exist_cvg_flag
            ,p_old_pl_id                  => l_ptip_enrt.pl_id
            ,p_new_pl_id                  => p_pl_id
            ,p_old_oipl_id                => l_ptip_enrt.oipl_id
            ,p_new_oipl_id                => p_oipl_id
            ,p_old_pl_typ_id              => l_ptip_enrt.pl_typ_id
            ,p_new_pl_typ_id              => p_pl_typ_id
            ,p_pgm_id                     => p_pgm_id
            ,p_ler_id                     => p_ler_id
            ,p_per_in_ler_id              => p_per_in_ler_id
            ,p_dpnt_cvg_strt_dt_cd        => l_global_epe_rec.dpnt_cvg_strt_dt_cd
            ,p_dpnt_cvg_strt_dt_rl        => l_global_epe_rec.dpnt_cvg_strt_dt_rl
            ,p_business_group_id          => p_business_group_id
            ,p_ENRT_CVG_STRT_DT           => l_global_pen_rec.enrt_cvg_strt_dt
            ,p_effective_date             => p_effective_date
            ,p_datetrack_mode             => p_datetrack_mode
            ,p_process_dpnt               => true
            ,p_process_bnf                => false
          );
          close c_ptip_enrollment_info;
        end if;
      end if;
    end if;
    --
    -- If new choice is not currently coverage, call action_item RCO to
    -- determine any action need to be taken.
    --
    -- Bug 3866580
    --
    -- Find out the Option Type of Plan Type of the Plan being enrolled in
   /*  It is better to go by savings plan flag rather option type code as
       the type code is only informational
    open c_pl_typ_opt_typ_cd (l_pl_rec.pl_typ_id, p_effective_date);
       fetch c_pl_typ_opt_typ_cd into l_pl_typ_opt_typ_cd;
    close c_pl_typ_opt_typ_cd;
    --
   */
    if    ( l_pl_rec.svgs_pl_flag = 'Y' and p_oipl_id is null and l_pl_rec.ENRT_PL_OPT_FLAG = 'Y' )
       or ( l_pl_rec.svgs_pl_flag = 'N')
    then
    /*
    Commented this part as, Enrollment Action Items for all enrollment in "Plans"
    as well as "Option In Plans" should be determined except for savings plan. In case
    of savings plan, enrollment actions items should be determined only if enrollment is in
    plan level (i.e. p_oipl_id = NULL
    --
    If l_pl_rec.ENRT_PL_OPT_FLAG = 'N'
       or (l_pl_rec.ENRT_PL_OPT_FLAG = 'Y'
       and p_oipl_id is NULL) then
    */
       --
        l_step := 165;
        ben_enrollment_action_items.determine_action_items
            (p_prtt_enrt_rslt_id          => l_prtt_enrt_rslt_id
            ,p_effective_date             => p_effective_date
            ,p_business_group_id          => p_business_group_id
            ,p_datetrack_mode             => p_datetrack_mode
            ,p_suspend_flag               => p_suspend_flag
            ,p_rslt_object_version_number => l_object_version_number
            ,p_enrt_bnft_id               => p_enrt_bnft_id
            ,p_post_rslt_flag             => l_post_rslt_flag
            ,p_dpnt_actn_warning          => p_dpnt_actn_warning
            ,p_bnf_actn_warning           => p_bnf_actn_warning
            ,p_ctfn_actn_warning          => p_ctfn_actn_warning
            );
        if (l_global_epe_rec.prtt_enrt_rslt_id is not NULL) then
          ben_global_enrt.get_pen  -- result
          (p_prtt_enrt_rslt_id      => l_global_epe_rec.prtt_enrt_rslt_id
          ,p_effective_date         => p_effective_date
          ,p_global_pen_rec         => l_global_pen_rec);
        else
          ben_global_enrt.clear_pen  -- result
          (p_global_pen_rec         => l_global_pen_rec);
        end if;
        --
        l_step := 167;
        -- if action item's calls update-enrollment, the globals will be
        -- reloaded for us.
        p_prtt_enrt_interim_id :=
          ben_global_enrt.g_global_pen_rec.rplcs_sspndd_rslt_id;
    end if;
    --
    -- When in validation only mode raise the Validate_Enabled exception
    --
    if p_validate then
        raise hr_api.validate_enabled;
    end if;
    --
    -- Set all output arguments
    --
    p_prtt_enrt_rslt_id     := l_prtt_enrt_rslt_id;
    p_effective_start_date  := l_effective_start_date;
    p_effective_end_date    := l_effective_end_date;
    p_object_version_number := l_object_version_number;

    /* Added for Bug 7561395*/
    if(g_enrt_list.count > 1) then
       g_enrt_list.trim(1);
       hr_utility.set_location(' count gt 1 ',5522);
    else
       if(g_enrt_list.count = 1) then
           hr_utility.set_location(' count is 1 ',5522);
          g_new_prtt_enrt_rslt_id := g_enrt_list(g_enrt_list.last);
          g_enrt_list.trim(1);
	   hr_utility.set_location(' g_new_prtt_enrt_rslt_id '||g_new_prtt_enrt_rslt_id ,5522);
       end if;
    end if;
    /* Ended for Bug 7561395*/

    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 999);
    end if;
exception
    when hr_api.validate_enabled then
        -- As the Validate_Enabled exception has been raised
        -- we must rollback to the savepoint
        --

	/* Added for Bug 7561395*/
	if(g_enrt_list.count > 1 ) then
          g_enrt_list.trim(g_enrt_list.count);
        end if;
	/* Ended for Bug 7561395*/

        if p_called_from_sspnd = 'N' then
          ROLLBACK TO create_enrollment;
        else
          ROLLBACK TO create_enrollment_sspnd;
        end if;

        --
        -- Only set output warning arguments
        -- (Any key or derived arguments must be set to null
        -- when validation only mode is being used.)
        --
        p_prtt_enrt_rslt_id := null;
        p_effective_start_date := null;
        p_effective_end_date := null;
        p_object_version_number  := null;
        if g_debug then
            hr_utility.set_location(' Leaving:'||l_proc, 80);
        end if;
  when others then
        --
        -- A validation or unexpected error has occured
        --
        /* Added for Bug 7561395*/
        if(g_enrt_list.count > 1 ) then
          g_enrt_list.trim(g_enrt_list.count);
        end if;
	/* Ended for Bug 7561395*/

        rpt_error(p_proc => l_proc, p_step => l_step);
        if p_called_from_sspnd = 'N' then
          ROLLBACK TO create_enrollment;
        else
          ROLLBACK TO create_enrollment_sspnd;
        end if;
        -- nocopy, reset
        p_prtt_enrt_rslt_id := null;
  p_effective_start_date := null;
  p_effective_end_date := null;
        p_object_version_number  := null;
        raise;
end create_enrollment;
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_PRTT_ENRT_RESULT >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_PRTT_ENRT_RESULT
  (p_validate                       in  boolean   default false
  ,p_prtt_enrt_rslt_id              out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default null
  ,p_oipl_id                        in  number    default null
  ,p_person_id                      in  number    default null
  ,p_assignment_id                  in  number    default null
  ,p_pgm_id                         in  number    default null
  ,p_pl_id                          in  number    default null
  ,p_rplcs_sspndd_rslt_id           in  number    default null
  ,p_ptip_id                        in  number    default null
  ,p_pl_typ_id                      in  number    default null
  ,p_ler_id                         in  number    default null
  ,p_sspndd_flag                    in  varchar2  default 'N'
  ,p_prtt_is_cvrd_flag              in  varchar2  default 'N'
  ,p_bnft_amt                       in  number    default null
  ,p_uom                            in  varchar2  default null
  ,p_orgnl_enrt_dt                  in  date      default null
  ,p_enrt_mthd_cd                   in  varchar2  default null
  ,p_no_lngr_elig_flag              in  varchar2  default 'N'
  ,p_enrt_ovridn_flag               in  varchar2  default 'N'
  ,p_enrt_ovrid_rsn_cd              in  varchar2  default null
  ,p_erlst_deenrt_dt                in  date      default null
  ,p_enrt_cvg_strt_dt               in  date      default null
  ,p_enrt_cvg_thru_dt               in  date      default hr_api.g_eot
  ,p_enrt_ovrid_thru_dt             in  date      default null
  ,p_pl_ordr_num                    in  number    default null
  ,p_plip_ordr_num                  in  number    default null
  ,p_ptip_ordr_num                  in  number    default null
  ,p_oipl_ordr_num                  in  number    default null
  ,p_pen_attribute_category         in  varchar2  default null
  ,p_pen_attribute1                 in  varchar2  default null
  ,p_pen_attribute2                 in  varchar2  default null
  ,p_pen_attribute3                 in  varchar2  default null
  ,p_pen_attribute4                 in  varchar2  default null
  ,p_pen_attribute5                 in  varchar2  default null
  ,p_pen_attribute6                 in  varchar2  default null
  ,p_pen_attribute7                 in  varchar2  default null
  ,p_pen_attribute8                 in  varchar2  default null
  ,p_pen_attribute9                 in  varchar2  default null
  ,p_pen_attribute10                in  varchar2  default null
  ,p_pen_attribute11                in  varchar2  default null
  ,p_pen_attribute12                in  varchar2  default null
  ,p_pen_attribute13                in  varchar2  default null
  ,p_pen_attribute14                in  varchar2  default null
  ,p_pen_attribute15                in  varchar2  default null
  ,p_pen_attribute16                in  varchar2  default null
  ,p_pen_attribute17                in  varchar2  default null
  ,p_pen_attribute18                in  varchar2  default null
  ,p_pen_attribute19                in  varchar2  default null
  ,p_pen_attribute20                in  varchar2  default null
  ,p_pen_attribute21                in  varchar2  default null
  ,p_pen_attribute22                in  varchar2  default null
  ,p_pen_attribute23                in  varchar2  default null
  ,p_pen_attribute24                in  varchar2  default null
  ,p_pen_attribute25                in  varchar2  default null
  ,p_pen_attribute26                in  varchar2  default null
  ,p_pen_attribute27                in  varchar2  default null
  ,p_pen_attribute28                in  varchar2  default null
  ,p_pen_attribute29                in  varchar2  default null
  ,p_pen_attribute30                in  varchar2  default null
  ,p_request_id                     in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  ,p_object_version_number          out nocopy number
  ,p_per_in_ler_id                  in  number    default null
  ,p_bnft_typ_cd                    in  varchar2  default null
  ,p_bnft_ordr_num                  in  number    default null
  ,p_prtt_enrt_rslt_stat_cd         in  varchar2  default null
  ,p_bnft_nnmntry_uom               in  varchar2  default null
  ,p_comp_lvl_cd                    in  varchar2  default null
  ,p_effective_date                 in  date
  ,p_multi_row_validate             in boolean    default TRUE
  ) is
--
-- Declare cursors and local variables
--
l_prtt_enrt_rslt_id ben_prtt_enrt_rslt_f.prtt_enrt_rslt_id%TYPE;
l_effective_start_date ben_prtt_enrt_rslt_f.effective_start_date%TYPE;
l_effective_end_date ben_prtt_enrt_rslt_f.effective_end_date%TYPE;
l_proc varchar2(72) ; -- := g_package||'create_PRTT_ENRT_RESULT';
l_object_version_number ben_prtt_enrt_rslt_f.object_version_number%TYPE;
begin
    g_debug := hr_utility.debug_enabled;
    if g_debug then
       l_proc := g_package||'create_PRTT_ENRT_RESULT';
       hr_utility.set_location('Entering:'|| l_proc, 10);
    end if;
    --
    g_multi_rows_validate := p_multi_row_validate;
    --
    -- Issue a savepoint if operating in validation only mode
    --
    savepoint create_PRTT_ENRT_RESULT;
    --
    if fnd_global.conc_request_id in (0,-1) then
      --
    --
        ben_env_object.init(p_business_group_id  => p_business_group_id,
                            p_effective_date     => p_effective_date,
                            p_thread_id          => 1,
                            p_chunk_size         => 1,
                            p_threads            => 1,
                            p_max_errors         => 1,
                            p_benefit_action_id  => null);
      --
    end if;
    if g_debug then
       hr_utility.set_location(l_proc, 20);
    end if;
    --
    -- Process Logic
    --
    begin
        --
        -- Start of API User Hook for the before hook of create_PRTT_ENRT_RESULT
        --
        ben_PRTT_ENRT_RESULT_bk1.create_PRTT_ENRT_RESULT_b
            (p_business_group_id              =>  p_business_group_id
            ,p_oipl_id                        =>  p_oipl_id
            ,p_person_id                      =>  p_person_id
            ,p_assignment_id                  =>  p_assignment_id
            ,p_pgm_id                         =>  p_pgm_id
            ,p_pl_id                          =>  p_pl_id
            ,p_rplcs_sspndd_rslt_id           =>  p_rplcs_sspndd_rslt_id
            ,p_ptip_id                        =>  p_ptip_id
            ,p_pl_typ_id                      =>  p_pl_typ_id
            ,p_ler_id                         =>  p_ler_id
            ,p_sspndd_flag                    =>  p_sspndd_flag
            ,p_prtt_is_cvrd_flag              =>  p_prtt_is_cvrd_flag
            ,p_bnft_amt                       =>  p_bnft_amt
            ,p_uom                            =>  p_uom
            ,p_orgnl_enrt_dt                  =>  p_orgnl_enrt_dt
            ,p_enrt_mthd_cd                   =>  p_enrt_mthd_cd
                ,p_no_lngr_elig_flag              =>  p_no_lngr_elig_flag
            ,p_enrt_ovridn_flag               =>  p_enrt_ovridn_flag
            ,p_enrt_ovrid_rsn_cd              =>  p_enrt_ovrid_rsn_cd
            ,p_erlst_deenrt_dt                =>  p_erlst_deenrt_dt
            ,p_enrt_cvg_strt_dt               =>  p_enrt_cvg_strt_dt
            ,p_enrt_cvg_thru_dt               =>  p_enrt_cvg_thru_dt
            ,p_enrt_ovrid_thru_dt             =>  p_enrt_ovrid_thru_dt
            ,p_pl_ordr_num                    =>  p_pl_ordr_num
            ,p_plip_ordr_num                  =>  p_plip_ordr_num
            ,p_ptip_ordr_num                  =>  p_ptip_ordr_num
            ,p_oipl_ordr_num                  =>  p_oipl_ordr_num
            ,p_pen_attribute_category         =>  p_pen_attribute_category
            ,p_pen_attribute1                 =>  p_pen_attribute1
            ,p_pen_attribute2                 =>  p_pen_attribute2
            ,p_pen_attribute3                 =>  p_pen_attribute3
            ,p_pen_attribute4                 =>  p_pen_attribute4
            ,p_pen_attribute5                 =>  p_pen_attribute5
            ,p_pen_attribute6                 =>  p_pen_attribute6
            ,p_pen_attribute7                 =>  p_pen_attribute7
            ,p_pen_attribute8                 =>  p_pen_attribute8
            ,p_pen_attribute9                 =>  p_pen_attribute9
            ,p_pen_attribute10                =>  p_pen_attribute10
            ,p_pen_attribute11                =>  p_pen_attribute11
            ,p_pen_attribute12                =>  p_pen_attribute12
            ,p_pen_attribute13                =>  p_pen_attribute13
            ,p_pen_attribute14                =>  p_pen_attribute14
            ,p_pen_attribute15                =>  p_pen_attribute15
            ,p_pen_attribute16                =>  p_pen_attribute16
            ,p_pen_attribute17                =>  p_pen_attribute17
            ,p_pen_attribute18                =>  p_pen_attribute18
            ,p_pen_attribute19                =>  p_pen_attribute19
            ,p_pen_attribute20                =>  p_pen_attribute20
            ,p_pen_attribute21                =>  p_pen_attribute21
            ,p_pen_attribute22                =>  p_pen_attribute22
            ,p_pen_attribute23                =>  p_pen_attribute23
            ,p_pen_attribute24                =>  p_pen_attribute24
            ,p_pen_attribute25                =>  p_pen_attribute25
            ,p_pen_attribute26                =>  p_pen_attribute26
            ,p_pen_attribute27                =>  p_pen_attribute27
            ,p_pen_attribute28                =>  p_pen_attribute28
            ,p_pen_attribute29                =>  p_pen_attribute29
            ,p_pen_attribute30                =>  p_pen_attribute30
            ,p_request_id                     =>  p_request_id
            ,p_program_application_id         =>  p_program_application_id
            ,p_program_id                     =>  p_program_id
            ,p_program_update_date            =>  p_program_update_date
                ,p_per_in_ler_id                  =>  p_per_in_ler_id
                ,p_bnft_typ_cd                    =>  p_bnft_typ_cd
                ,p_bnft_ordr_num                  =>  p_bnft_ordr_num
                ,p_prtt_enrt_rslt_stat_cd         =>  p_prtt_enrt_rslt_stat_cd
                ,p_bnft_nnmntry_uom               =>  p_bnft_nnmntry_uom
                ,p_comp_lvl_cd                    =>  p_comp_lvl_cd
            ,p_effective_date                 =>  trunc(p_effective_date)
            );
    exception
        when hr_api.cannot_find_prog_unit then
            hr_api.cannot_find_prog_unit_error
                (p_module_name => 'CREATE_PRTT_ENRT_RESULT'
            ,p_hook_type   => 'BP'
            );
        --
        -- End of API User Hook for the before hook of create_PRTT_ENRT_RESULT
        --
    end;
    ben_pen_ins.ins
            (p_prtt_enrt_rslt_id             => l_prtt_enrt_rslt_id
            ,p_effective_start_date          => l_effective_start_date
            ,p_effective_end_date            => l_effective_end_date
            ,p_business_group_id             => p_business_group_id
            ,p_oipl_id                       => p_oipl_id
            ,p_person_id                     => p_person_id
            ,p_assignment_id                 => p_assignment_id
            ,p_pgm_id                        => p_pgm_id
            ,p_pl_id                         => p_pl_id
            ,p_rplcs_sspndd_rslt_id          => p_rplcs_sspndd_rslt_id
            ,p_ptip_id                       => p_ptip_id
            ,p_pl_typ_id                     => p_pl_typ_id
            ,p_ler_id                        => p_ler_id
            ,p_sspndd_flag                   => p_sspndd_flag
            ,p_prtt_is_cvrd_flag             => p_prtt_is_cvrd_flag
            ,p_bnft_amt                      => p_bnft_amt
            ,p_uom                           => p_uom
            ,p_orgnl_enrt_dt                 => p_orgnl_enrt_dt
            ,p_enrt_mthd_cd                  => p_enrt_mthd_cd
                ,p_no_lngr_elig_flag             => p_no_lngr_elig_flag
            ,p_enrt_ovridn_flag              => p_enrt_ovridn_flag
            ,p_enrt_ovrid_rsn_cd             => p_enrt_ovrid_rsn_cd
            ,p_erlst_deenrt_dt               => p_erlst_deenrt_dt
            ,p_enrt_cvg_strt_dt              => p_enrt_cvg_strt_dt
            ,p_enrt_cvg_thru_dt              => p_enrt_cvg_thru_dt
            ,p_enrt_ovrid_thru_dt            => p_enrt_ovrid_thru_dt
            ,p_pl_ordr_num                   =>  p_pl_ordr_num
            ,p_plip_ordr_num                 =>  p_plip_ordr_num
            ,p_ptip_ordr_num                 =>  p_ptip_ordr_num
            ,p_oipl_ordr_num                 =>  p_oipl_ordr_num
                ,p_pen_attribute_category        => p_pen_attribute_category
            ,p_pen_attribute1                => p_pen_attribute1
                ,p_pen_attribute2                => p_pen_attribute2
            ,p_pen_attribute3                => p_pen_attribute3
            ,p_pen_attribute4                => p_pen_attribute4
            ,p_pen_attribute5                => p_pen_attribute5
            ,p_pen_attribute6                => p_pen_attribute6
            ,p_pen_attribute7                => p_pen_attribute7
            ,p_pen_attribute8                => p_pen_attribute8
            ,p_pen_attribute9                => p_pen_attribute9
            ,p_pen_attribute10               => p_pen_attribute10
            ,p_pen_attribute11               => p_pen_attribute11
            ,p_pen_attribute12               => p_pen_attribute12
            ,p_pen_attribute13               => p_pen_attribute13
            ,p_pen_attribute14               => p_pen_attribute14
            ,p_pen_attribute15               => p_pen_attribute15
            ,p_pen_attribute16               => p_pen_attribute16
            ,p_pen_attribute17               => p_pen_attribute17
            ,p_pen_attribute18               => p_pen_attribute18
            ,p_pen_attribute19               => p_pen_attribute19
            ,p_pen_attribute20               => p_pen_attribute20
            ,p_pen_attribute21               => p_pen_attribute21
            ,p_pen_attribute22               => p_pen_attribute22
            ,p_pen_attribute23               => p_pen_attribute23
            ,p_pen_attribute24               => p_pen_attribute24
            ,p_pen_attribute25               => p_pen_attribute25
            ,p_pen_attribute26               => p_pen_attribute26
            ,p_pen_attribute27               => p_pen_attribute27
            ,p_pen_attribute28               => p_pen_attribute28
            ,p_pen_attribute29               => p_pen_attribute29
            ,p_pen_attribute30               => p_pen_attribute30
            ,p_request_id                    => p_request_id
            ,p_program_application_id        => p_program_application_id
            ,p_program_id                    => p_program_id
            ,p_program_update_date           => p_program_update_date
            ,p_object_version_number         => l_object_version_number
            ,p_per_in_ler_id                 => p_per_in_ler_id
            ,p_bnft_typ_cd                   => p_bnft_typ_cd
            ,p_bnft_ordr_num                 => p_bnft_ordr_num
            ,p_prtt_enrt_rslt_stat_cd        => p_prtt_enrt_rslt_stat_cd
            ,p_bnft_nnmntry_uom              => p_bnft_nnmntry_uom
            ,p_comp_lvl_cd                   => p_comp_lvl_cd
            ,p_effective_date                => trunc(p_effective_date)
            );
    begin
        --
        -- Start of API User Hook for the after hook of create_PRTT_ENRT_RESULT
        --
        ben_PRTT_ENRT_RESULT_bk1.create_PRTT_ENRT_RESULT_a
            (p_prtt_enrt_rslt_id              =>  l_prtt_enrt_rslt_id
            ,p_effective_start_date           =>  l_effective_start_date
            ,p_effective_end_date             =>  l_effective_end_date
            ,p_business_group_id              =>  p_business_group_id
            ,p_oipl_id                        =>  p_oipl_id
            ,p_person_id                      =>  p_person_id
            ,p_assignment_id                  =>  p_assignment_id
            ,p_pgm_id                         =>  p_pgm_id
            ,p_pl_id                          =>  p_pl_id
            ,p_rplcs_sspndd_rslt_id           =>  p_rplcs_sspndd_rslt_id
            ,p_ptip_id                        =>  p_ptip_id
            ,p_pl_typ_id                      =>  p_pl_typ_id
            ,p_ler_id                         =>  p_ler_id
            ,p_sspndd_flag                    =>  p_sspndd_flag
            ,p_prtt_is_cvrd_flag              =>  p_prtt_is_cvrd_flag
            ,p_bnft_amt                       =>  p_bnft_amt
            ,p_uom                            =>  p_uom
            ,p_orgnl_enrt_dt                  =>  p_orgnl_enrt_dt
            ,p_enrt_mthd_cd                   =>  p_enrt_mthd_cd
            ,p_no_lngr_elig_flag              =>  p_no_lngr_elig_flag
            ,p_enrt_ovridn_flag               =>  p_enrt_ovridn_flag
            ,p_enrt_ovrid_rsn_cd              =>  p_enrt_ovrid_rsn_cd
            ,p_erlst_deenrt_dt                =>  p_erlst_deenrt_dt
            ,p_enrt_cvg_strt_dt               =>  p_enrt_cvg_strt_dt
            ,p_enrt_cvg_thru_dt               =>  p_enrt_cvg_thru_dt
            ,p_enrt_ovrid_thru_dt             =>  p_enrt_ovrid_thru_dt
            ,p_pl_ordr_num                    =>  p_pl_ordr_num
            ,p_plip_ordr_num                  =>  p_plip_ordr_num
            ,p_ptip_ordr_num                  =>  p_ptip_ordr_num
            ,p_oipl_ordr_num                  =>  p_oipl_ordr_num
            ,p_pen_attribute_category         =>  p_pen_attribute_category
            ,p_pen_attribute1                 =>  p_pen_attribute1
            ,p_pen_attribute2                 =>  p_pen_attribute2
            ,p_pen_attribute3                 =>  p_pen_attribute3
            ,p_pen_attribute4                 =>  p_pen_attribute4
            ,p_pen_attribute5                 =>  p_pen_attribute5
            ,p_pen_attribute6                 =>  p_pen_attribute6
            ,p_pen_attribute7                 =>  p_pen_attribute7
            ,p_pen_attribute8                 =>  p_pen_attribute8
            ,p_pen_attribute9                 =>  p_pen_attribute9
            ,p_pen_attribute10                =>  p_pen_attribute10
            ,p_pen_attribute11                =>  p_pen_attribute11
            ,p_pen_attribute12                =>  p_pen_attribute12
            ,p_pen_attribute13                =>  p_pen_attribute13
            ,p_pen_attribute14                =>  p_pen_attribute14
            ,p_pen_attribute15                =>  p_pen_attribute15
            ,p_pen_attribute16                =>  p_pen_attribute16
            ,p_pen_attribute17                =>  p_pen_attribute17
            ,p_pen_attribute18                =>  p_pen_attribute18
            ,p_pen_attribute19                =>  p_pen_attribute19
            ,p_pen_attribute20                =>  p_pen_attribute20
            ,p_pen_attribute21                =>  p_pen_attribute21
            ,p_pen_attribute22                =>  p_pen_attribute22
            ,p_pen_attribute23                =>  p_pen_attribute23
            ,p_pen_attribute24                =>  p_pen_attribute24
            ,p_pen_attribute25                =>  p_pen_attribute25
            ,p_pen_attribute26                =>  p_pen_attribute26
            ,p_pen_attribute27                =>  p_pen_attribute27
            ,p_pen_attribute28                =>  p_pen_attribute28
            ,p_pen_attribute29                =>  p_pen_attribute29
            ,p_pen_attribute30                =>  p_pen_attribute30
            ,p_request_id                     =>  p_request_id
            ,p_program_application_id         =>  p_program_application_id
            ,p_program_id                     =>  p_program_id
            ,p_program_update_date            =>  p_program_update_date
            ,p_object_version_number          =>  l_object_version_number
            ,p_per_in_ler_id                  =>  p_per_in_ler_id
            ,p_bnft_typ_cd                    =>  p_bnft_typ_cd
            ,p_bnft_ordr_num                  =>  p_bnft_ordr_num
            ,p_prtt_enrt_rslt_stat_cd         =>  p_prtt_enrt_rslt_stat_cd
            ,p_bnft_nnmntry_uom               =>  p_bnft_nnmntry_uom
            ,p_comp_lvl_cd                    =>  p_comp_lvl_cd
            ,p_effective_date                 => trunc(p_effective_date)
            );
    exception
        when hr_api.cannot_find_prog_unit then
            hr_api.cannot_find_prog_unit_error
            (p_module_name => 'CREATE_PRTT_ENRT_RESULT'
            ,p_hook_type   => 'AP'
            );
    end;
    if g_debug then
       hr_utility.set_location(l_proc, 60);
    end if;
    --
    -- When in validation only mode raise the Validate_Enabled exception
    --
    if p_validate then
        raise hr_api.validate_enabled;
    end if;
    --
    -- Set all output arguments
    --
    p_prtt_enrt_rslt_id := l_prtt_enrt_rslt_id;
    p_effective_start_date := l_effective_start_date;
    p_effective_end_date := l_effective_end_date;
    p_object_version_number := l_object_version_number;
    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 70);
    end if;
exception
    when hr_api.validate_enabled then
        --
        -- As the Validate_Enabled exception has been raised
        -- we must rollback to the savepoint
        --
        ROLLBACK TO create_PRTT_ENRT_RESULT;
        --
        -- Only set output warning arguments
        -- (Any key or derived arguments must be set to null
        -- when validation only mode is being used.)
        --
        p_prtt_enrt_rslt_id := null;
        p_effective_start_date := null;
        p_effective_end_date := null;
        p_object_version_number  := null;
        if g_debug then
           hr_utility.set_location(' Leaving:'||l_proc, 80);
        end if;
    when others then
        --
        -- A validation or unexpected error has occured
        --
        ROLLBACK TO create_PRTT_ENRT_RESULT;
        --nocopy, reset
        p_prtt_enrt_rslt_id := null;
  p_effective_start_date := null;
  p_effective_end_date := null;
  p_object_version_number  := null;

        raise;
end create_PRTT_ENRT_RESULT;
--
-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
--
procedure update_ENROLLMENT
  (p_validate                       in  boolean   default false
  ,p_prtt_enrt_rslt_id              in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_oipl_id                        in  number    default hr_api.g_number
  ,p_person_id                      in  number    default hr_api.g_number
  ,p_assignment_id                  in  number    default hr_api.g_number
  ,p_pgm_id                         in  number    default hr_api.g_number
  ,p_pl_id                          in  number    default hr_api.g_number
  ,p_rplcs_sspndd_rslt_id           in  number    default hr_api.g_number
  ,p_ptip_id                        in  number    default hr_api.g_number
  ,p_pl_typ_id                      in  number    default hr_api.g_number
  ,p_ler_id                         in  number    default hr_api.g_number
  ,p_sspndd_flag                    in  varchar2  default hr_api.g_varchar2
  ,p_prtt_is_cvrd_flag              in  varchar2  default hr_api.g_varchar2
  ,p_enrt_bnft_id                   in  number    default NULL
  ,p_bnft_amt                       in  number    default hr_api.g_number
  ,p_uom                            in  varchar2  default hr_api.g_varchar2
  ,p_orgnl_enrt_dt                  in  date      default hr_api.g_date
  ,p_enrt_mthd_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_enrt_ovridn_flag               in  varchar2  default hr_api.g_varchar2
  ,p_enrt_ovrid_rsn_cd              in  varchar2  default hr_api.g_varchar2
  ,p_erlst_deenrt_dt                in  date      default hr_api.g_date
  ,p_enrt_cvg_strt_dt               in  date      default hr_api.g_date
  ,p_enrt_cvg_thru_dt               in  date      default hr_api.g_date
  ,p_enrt_ovrid_thru_dt             in  date      default hr_api.g_date
  ,p_pl_ordr_num                    in  number    default hr_api.g_number
  ,p_plip_ordr_num                  in  number    default hr_api.g_number
  ,p_ptip_ordr_num                  in  number    default hr_api.g_number
  ,p_oipl_ordr_num                  in  number    default hr_api.g_number
  ,p_pen_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_request_id                     in  number    default hr_api.g_number
  ,p_program_application_id         in  number    default hr_api.g_number
  ,p_program_id                     in  number    default hr_api.g_number
  ,p_program_update_date            in  date      default hr_api.g_date
  ,p_object_version_number          in  out nocopy number
  ,p_per_in_ler_id                  in  number    default hr_api.g_number
  ,p_bnft_typ_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_bnft_ordr_num                  in  number    default hr_api.g_number
  ,p_prtt_enrt_rslt_stat_cd         in  varchar2  default hr_api.g_varchar2
  ,p_bnft_nnmntry_uom               in  varchar2  default hr_api.g_varchar2
  ,p_comp_lvl_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_multi_row_validate             in  boolean   default TRUE
  ,p_suspend_flag                   out nocopy varchar2
  ,p_prtt_enrt_interim_id           out nocopy number
  ,p_dpnt_actn_warning              out nocopy boolean
  ,p_bnf_actn_warning               out nocopy boolean
  ,p_ctfn_actn_warning              out nocopy boolean
  ) is
--
-- Declare cursors and local variables
--
l_pl_rec         ben_cobj_cache.g_pl_inst_row;
l_oipl_rec       ben_cobj_cache.g_oipl_inst_row;
--
l_global_pen_rec ben_prtt_enrt_rslt_f%rowtype;


cursor c_interim_enrt is
  select pen.rplcs_sspndd_rslt_id
  from   ben_prtt_enrt_rslt_f pen
  where  pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id and
         pen.business_group_id = p_business_group_id and
         p_effective_date between
           pen.effective_start_date and pen.effective_end_date;

cursor c_prem is
  select ecr.val,
         ecr.uom,
         ecr.actl_prem_id,
         pil.lf_evt_ocrd_dt,
         pil.ler_id,
         epe.elig_per_elctbl_chc_id
  from   ben_enrt_prem ecr,
         ben_per_in_ler pil,
         ben_elig_per_elctbl_chc epe
  where  epe.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
    and  epe.elig_per_elctbl_chc_id = ecr.elig_per_elctbl_chc_id
    and  pil.per_in_ler_id = epe.per_in_ler_id
    and  pil.per_in_ler_stat_cd = 'STRTD';
    --and  pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT');
--
l_prem c_prem%rowtype;
--
/*
  CODE PRIOR TO WWBUG: 1646442
cursor c_ppe (p_prtt_enrt_rslt_id in number,
              p_actl_prem_id      in number) is
*/
/* Start of Changes for WWBUG: 1646442                  */
cursor c_ppe (p_prtt_enrt_rslt_id in number,
              p_actl_prem_id      in number,
              p_ppe_dt_to_use     in date) is
/* End of Changes for WWBUG: 1646442                    */
  select ppe.prtt_prem_id,
         ppe.std_prem_uom,
         ppe.std_prem_val,
         ppe.actl_prem_id,
         ppe.object_version_number,
         ppe.effective_start_date
    from ben_prtt_prem_f ppe,
         ben_per_in_ler pil
   where ppe.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and ppe.actl_prem_id = p_actl_prem_id
     /*
          CODE PRIOR TO WWBUG: 1646442
     and p_effective_date between
     */
     /* Start of Changes for WWBUG: 1646442             */
     and  p_ppe_dt_to_use between
     /* End of Changes for WWBUG: 1646442               */
         ppe.effective_start_date and ppe.effective_end_date
     and pil.per_in_ler_id=ppe.per_in_ler_id
     and pil.business_group_id=ppe.business_group_id
     and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
     ;
--
l_ppe c_ppe%rowtype;

----For Bug : 7133998
cursor c_ppe1 (p_prtt_enrt_rslt_id in number,
              p_actl_prem_id      in number,
              p_ppe_dt_to_use     in date) is
  select ppe.*
    from ben_prtt_prem_f ppe,
         ben_per_in_ler pil
   where ppe.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and ppe.actl_prem_id = p_actl_prem_id
     and p_ppe_dt_to_use <= ppe.effective_start_date
     and pil.per_in_ler_id=ppe.per_in_ler_id
     and pil.business_group_id=ppe.business_group_id
     and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
     ;
l_count    number := 0;
l_objversion_no  number;
---For Bug : 7133998
--
-- This cursor is used to update the elig_cvrd_dpnt records
-- when the participant stays in the same plan and we need
-- to copy his dependents from elig_dpnt to elig_cvrd_dpnt.
--
-- Note: Result Id is same on the choice and elig_cvrd_dpnt record,
--  but per_in_ler_id is DIFFERENT.
--  Do not do any updates for same per_in_ler_id as we would have
--  done the updates when per_in_ler_id changed and the user would
--  have changed his designation since then. (Basically do not repeat it.)
--
-- Bug 1298802:  sometimes per-in-ler is the same...when have a ler and move
-- out of this result then right back into this result on same day.  If prtt
-- does an uncover, change option, then back into option, I think
-- it's better to re-cover the dpnts....then user can uncover them again.
--
cursor c_egd is
   select egd.elig_cvrd_dpnt_id,
          egd.per_in_ler_id,
          pdp.effective_start_date,
          pdp.object_version_number
   from   ben_elig_per_elctbl_chc epe,
          ben_elig_dpnt           egd,
          ben_elig_cvrd_dpnt_f    pdp,
          ben_per_in_ler          egd_pil,
          ben_per_in_ler          pdp_pil
   where  epe.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
   and    epe.per_in_ler_id     = p_per_in_ler_id
   and    epe.elig_per_elctbl_chc_id = egd.elig_per_elctbl_chc_id
   and    egd.elig_cvrd_dpnt_id      = pdp.elig_cvrd_dpnt_id
   and    pdp.prtt_enrt_rslt_id      = p_prtt_enrt_rslt_id
 --  and    egd.per_in_ler_id          <> pdp.per_in_ler_id
   and    egd.per_in_ler_id          = egd_pil.per_in_ler_id
   and    egd_pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
   and    pdp.per_in_ler_id          = pdp_pil.per_in_ler_id
   and    pdp_pil.per_in_ler_stat_cd not in ('VOIDD', 'BCKDT')
   and    p_effective_date between
          pdp.effective_start_date and pdp.effective_end_date
   and    p_effective_date >= pdp.cvg_strt_dt
   and    egd.dpnt_inelig_flag = 'N'
--   and    p_effective_date between
--          pdp.cvg_strt_dt and pdp.cvg_thru_dt
    ;

  ------Check if the elig_cvrd_dpnt_id is set in ben_elig_dpnt table,Bug 8919376
  cursor c_check_cvrd_dpnt is
   select egd.*,pdp.elig_cvrd_dpnt_id cvrd_dpnt_id
   from   ben_elig_per_elctbl_chc epe,
          ben_elig_dpnt           egd,
          ben_elig_cvrd_dpnt_f    pdp,
          ben_per_in_ler          egd_pil,
          ben_per_in_ler          pdp_pil
   where  epe.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
   and    epe.per_in_ler_id     = p_per_in_ler_id
   AND    epe.crntly_enrd_flag = 'Y'
   and    epe.elig_per_elctbl_chc_id = egd.elig_per_elctbl_chc_id
   and    egd.elig_cvrd_dpnt_id IS NULL
   AND    egd.dpnt_person_id = pdp.dpnt_person_id
   and    pdp.prtt_enrt_rslt_id      = p_prtt_enrt_rslt_id
   and    egd.per_in_ler_id          = egd_pil.per_in_ler_id
   and    egd_pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
   and    pdp.per_in_ler_id          = pdp_pil.per_in_ler_id
   and    pdp_pil.per_in_ler_stat_cd not in ('VOIDD', 'BCKDT')
   and    p_effective_date between
          pdp.effective_start_date and pdp.effective_end_date
   and     p_effective_date >= pdp.cvg_strt_dt
   and    egd.dpnt_inelig_flag = 'N';
  ----------Bug 8919376
  --- to find the flex credit place holder choice and rate
  --- flex credit amount is changes is not effecting the ledger
  ---- this find the flex credit place holder plan prvdd amount
  ---  then the amount will be compared with bnft_prvdd_ldgr row
  --   if a rate cahnge found update the bnft_prvdd_ldgr
   cursor c_flex_choice  is
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
    where       epe1.prtt_enrt_rslt_id =p_prtt_enrt_rslt_id  and
                epe1.per_in_ler_id     = p_per_in_ler_id     and
                epe1.business_group_id=p_business_group_id and
                epe1.pgm_id = epe.pgm_id and
                epe1.per_in_ler_id = epe.per_in_ler_id and
                epe.bnft_prvdr_pool_id is not null and
                epe.business_group_id=p_business_group_id and
                ecr.elig_per_elctbl_chc_id = epe.elig_per_elctbl_chc_id and
                ecr.rt_usg_cd = 'FLXCR' and
                ecr.business_group_id = p_business_group_id;



   cursor c_bpl ( c_acty_base_rt_id number ,
                  c_bnft_prvdr_pool_id number ,
                  c_prtt_enrt_rslt_id number) is
   select  prvdd_val
   from ben_bnft_prvdd_ldgr_f bpl,
        ben_per_in_ler pil
   where   bpl.acty_base_rt_id = c_acty_base_rt_id
     and bpl.bnft_prvdr_pool_id = c_bnft_prvdr_pool_id
     and bpl.prtt_enrt_rslt_id = c_prtt_enrt_rslt_id
     and pil.per_in_ler_id = bpl.per_in_ler_id
     and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
     and bpl.business_group_id = p_business_group_id
     and p_effective_date between
         bpl.effective_start_date and bpl.effective_end_date ;
   --
   cursor c_prtt_enrt is
     select prtt_enrt_rslt_id
     from   ben_elig_per_elctbl_chc epe
     where  epe.per_in_ler_id = p_per_in_ler_id
     and    epe.comp_lvl_cd = 'PLANFC'
     and    epe.business_group_id = p_business_group_id;
  --
  cursor c_elig_per_elctbl_chc is
     select elig_per_elctbl_chc_id
     from   ben_elig_per_elctbl_chc
     where  prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and    per_in_ler_id = p_per_in_ler_id;
  --
/* Start of Changes for WWBUG: 1646442: added                           */
   cursor c_pel (p_elig_pe_elctbl_chc_id number) is
   select pel.enrt_perd_id,pel.lee_rsn_id
   from ben_pil_elctbl_chc_popl pel
       ,ben_elig_per_elctbl_chc epe
   where pel.pil_elctbl_chc_popl_id = epe.pil_elctbl_chc_popl_id
   and epe.elig_per_elctbl_chc_id = p_elig_pe_elctbl_chc_id;

   l_pel c_pel%rowtype;
   --
   -- Bug : 3866580
   cursor c_pl_typ_opt_typ_cd (pl_typ_id number, p_effective_date date) is
      select ptp.opt_typ_cd
        from ben_pl_typ_f ptp
       where ptp.pl_typ_id = p_pl_typ_id
         and p_effective_date between ptp.effective_start_date
                                  and ptp.effective_end_date;

   l_pl_typ_opt_typ_cd    ben_pl_typ.opt_typ_cd%type;
   -- Bug : 3866580
   --
--
l_ppe_dt_to_use         date;
l_enrt_cvg_strt_dt      date;
l_enrt_cvg_strt_dt_cd   varchar2(30);
l_enrt_cvg_strt_dt_rl   number;
l_rt_strt_dt            date;
l_rt_strt_dt_cd         varchar2(30);
l_rt_strt_dt_rl         number;
l_enrt_cvg_end_dt       date;
l_enrt_cvg_end_dt_cd    varchar2(30);
l_enrt_cvg_end_dt_rl    number;
l_rt_end_dt             date;
l_rt_end_dt_cd          varchar2(30);
l_rt_end_dt_rl          number;
/* End of Changes for WWBUG: 1646442                                    */
--
l_proc                  varchar2(72); --  := g_package||'update_ENROLLMENT';
l_object_version_number ben_prtt_enrt_rslt_f.object_version_number%TYPE;
l_effective_start_date  ben_prtt_enrt_rslt_f.effective_start_date%TYPE;
l_effective_end_date    ben_prtt_enrt_rslt_f.effective_end_date%TYPE;
l_prev_bnft_amt         ben_prtt_enrt_rslt_f.bnft_amt%TYPE;
l_enrt_pl_opt_flag      ben_pl_f.enrt_pl_opt_flag%TYPE;
l_prvdd_val             ben_bnft_prvdd_ldgr_f.prvdd_Val%type ;
l_chg                   boolean := FALSE;
l_step                  number(9);
l_datetrack_mode        varchar2(30) := p_datetrack_mode;
l_correction            boolean;
l_update                boolean;
l_update_override       boolean;
l_update_change_insert  boolean;
l_post_rslt_flag        varchar2(30) := 'Y';
l_egd_datetrack_mode    varchar2(30);
l_ppe_datetrack_mode    varchar2(30);
l_prtt_enrt_rslt_id     number ;
l_elig_per_elctbl_chc_id number;
--
begin
--
l_step := 10;
    g_debug := hr_utility.debug_enabled;
    if g_debug then
       l_proc := g_package||'update_ENROLLMENT';
       hr_utility.set_location('Entering:'|| l_proc, 10);
    end if;
    --
    g_multi_rows_validate := p_multi_row_validate;
    If (p_multi_row_validate) then
        l_post_rslt_flag := 'Y';
    Else
        l_post_rslt_flag := 'N';
    End if;
    --
    -- Issue a savepoint if operating in validation only mode
    --
    savepoint update_ENROLLMENT;
    if g_debug then
       hr_utility.set_location(l_proc, 20);
    end if;
    --
    -- Process Logic
    --
    l_object_version_number := p_object_version_number;
l_step := 20;
    ben_global_enrt.get_pen  -- result
       (p_prtt_enrt_rslt_id      => p_prtt_enrt_rslt_id
       ,p_effective_date         => p_effective_date
       ,p_global_pen_rec         => l_global_pen_rec);
     --
     ben_cobj_cache.get_pl_dets
       (p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_pl_id             => l_global_pen_rec.pl_id
       ,p_inst_row          => l_pl_rec);
     if l_global_pen_rec.oipl_id is not null then
       ben_cobj_cache.get_oipl_dets
         (p_business_group_id => p_business_group_id
         ,p_effective_date    => p_effective_date
         ,p_oipl_id           => l_global_pen_rec.oipl_id
         ,p_inst_row          => l_oipl_rec);
     end if;
    --
l_step := 30;
    if (p_oipl_id <> hr_api.g_number and
            nvl(l_global_pen_rec.oipl_id,hr_api.g_number) <>
            nvl(p_oipl_id,hr_api.g_number)) then
       l_chg := TRUE;
    end if;
    if (p_assignment_id <>  hr_api.g_number and
            nvl(l_global_pen_rec.assignment_id,hr_api.g_number) <>
            nvl(p_assignment_id,hr_api.g_number)) then
       l_chg := TRUE;
    end if;
    if (p_pgm_id <> hr_api.g_number and
            nvl(l_global_pen_rec.pgm_id,hr_api.g_number) <>
            nvl(p_pgm_id,hr_api.g_number)) then
       l_chg := TRUE;
    end if;
    if (p_pl_id <> hr_api.g_number and
            nvl(l_global_pen_rec.pl_id,hr_api.g_number) <>
            nvl(p_pl_id, hr_api.g_number)) then
       l_chg := TRUE;
    end if;
    if (p_rplcs_sspndd_rslt_id <> hr_api.g_number and
           nvl(l_global_pen_rec.rplcs_sspndd_rslt_id,hr_api.g_number) <>
           nvl(p_rplcs_sspndd_rslt_id,hr_api.g_number) ) then
       l_chg := TRUE;
    end if;
l_step := 35;
    if (p_ptip_id <> hr_api.g_number and
           nvl(l_global_pen_rec.ptip_id,hr_api.g_number) <>
           nvl(p_ptip_id,hr_api.g_number)) then
       l_chg := TRUE;
    end if;
    if (p_pl_typ_id <> hr_api.g_number and
           nvl(l_global_pen_rec.pl_typ_id,hr_api.g_number) <>
           nvl(p_pl_typ_id,hr_api.g_number)) then
       l_chg := TRUE;
    end if;
    if (p_ler_id <> hr_api.g_number and
           nvl(l_global_pen_rec.ler_id,hr_api.g_number) <>
           nvl(p_ler_id,hr_api.g_number)) then
       l_chg := TRUE;
    end if;
    if  (p_sspndd_flag <> hr_api.g_varchar2 and
           nvl(l_global_pen_rec.sspndd_flag,hr_api.g_varchar2) <>
           nvl(p_sspndd_flag,hr_api.g_varchar2))  then
       l_chg := TRUE;
    end if;
    if (p_prtt_is_cvrd_flag <> hr_api.g_varchar2 and
           nvl(l_global_pen_rec.prtt_is_cvrd_flag,hr_api.g_varchar2) <>
           nvl(p_prtt_is_cvrd_flag,hr_api.g_varchar2)) then
       l_chg := TRUE;
    end if;
    --
    -- Bug 4723828 : If benefit amount changes from non-zero value to NULL
    --               we need to detect that nullify the coverage. So added
    --               nvl(p_bnft_amt, -9999)
    --
    if (nvl(p_bnft_amt, -9999) <> hr_api.g_number and
           nvl(l_global_pen_rec.bnft_amt,hr_api.g_number) <>
           nvl(p_bnft_amt,hr_api.g_number)) then
       l_chg := TRUE;
    end if;
l_step := 40;
    if (p_uom <> hr_api.g_varchar2 and
           nvl(l_global_pen_rec.uom,hr_api.g_varchar2) <>
           nvl(p_uom,hr_api.g_varchar2)) then
       l_chg := TRUE;
    end if;
    if (p_orgnl_enrt_dt <> hr_api.g_date and
           nvl(l_global_pen_rec.orgnl_enrt_dt,hr_api.g_date) <>
           nvl(p_orgnl_enrt_dt,hr_api.g_date)) then
       l_chg := TRUE;
    end if;
    -- 5417132  by pass enrt_mthd_cd chk for Imputed/flex rows
    if p_comp_lvl_cd not in ('PLANFC','PLANIMP') then
      if (p_enrt_mthd_cd <> hr_api.g_varchar2 and
           nvl(l_global_pen_rec.enrt_mthd_cd,hr_api.g_varchar2) <>
           nvl(p_enrt_mthd_cd,hr_api.g_varchar2)) then
       l_chg := TRUE;
      end if;
    end if;
    if (p_enrt_ovridn_flag <> hr_api.g_varchar2 and
           nvl(l_global_pen_rec.enrt_ovridn_flag,hr_api.g_varchar2) <>
           nvl(p_enrt_ovridn_flag,hr_api.g_varchar2))  then
       l_chg := TRUE;
    end if;
    if (p_enrt_ovrid_rsn_cd <> hr_api.g_varchar2 and
           nvl(l_global_pen_rec.enrt_ovrid_rsn_cd,hr_api.g_varchar2) <>
           nvl(p_enrt_ovrid_rsn_cd,hr_api.g_varchar2)) then
       l_chg := TRUE;
    end if;
    if  (p_erlst_deenrt_dt <> hr_api.g_date and
           nvl(l_global_pen_rec.erlst_deenrt_dt,hr_api.g_date) <>
           nvl(p_erlst_deenrt_dt,hr_api.g_date)) then
       l_chg := TRUE;
    end if;
    if (p_enrt_cvg_strt_dt <> hr_api.g_date and
           nvl(l_global_pen_rec.enrt_cvg_strt_dt,hr_api.g_date) <>
           nvl(p_enrt_cvg_strt_dt,hr_api.g_date)) then
       l_chg := TRUE;
    end if;
    if (p_enrt_cvg_thru_dt <> hr_api.g_date and
           nvl(l_global_pen_rec.enrt_cvg_thru_dt,hr_api.g_date) <>
           nvl(p_enrt_cvg_thru_dt,hr_api.g_date)) then
       l_chg := TRUE;
    end if;
    if (p_enrt_ovrid_thru_dt <> hr_api.g_date and
           nvl(l_global_pen_rec.enrt_ovrid_thru_dt,hr_api.g_date) <>
           nvl(p_enrt_ovrid_thru_dt,hr_api.g_date)) then
       l_chg := TRUE;
    end if;
l_step := 50;
    if (p_per_in_ler_id <> hr_api.g_number and
           nvl(l_global_pen_rec.per_in_ler_id,hr_api.g_number) <>
           nvl(p_per_in_ler_id,hr_api.g_number)) then
       l_chg := TRUE;
    end if;
    if  (p_bnft_typ_cd <> hr_api.g_varchar2 and
           nvl(l_global_pen_rec.bnft_typ_cd,hr_api.g_varchar2) <>
           nvl(p_bnft_typ_cd,hr_api.g_varchar2)) then
       l_chg := TRUE;
    end if;
    if  (p_bnft_ordr_num <> hr_api.g_number and
           nvl(l_global_pen_rec.bnft_ordr_num,hr_api.g_number) <>
           nvl(p_bnft_ordr_num,hr_api.g_number)) then
       l_chg := TRUE;
    end if;
    if  (p_prtt_enrt_rslt_stat_cd <> hr_api.g_varchar2 and
           nvl(l_global_pen_rec.prtt_enrt_rslt_stat_cd,hr_api.g_varchar2) <>
           nvl(p_prtt_enrt_rslt_stat_cd,hr_api.g_varchar2)) then
       l_chg := TRUE;
    end if;
    if (p_bnft_nnmntry_uom <> hr_api.g_varchar2 and
           nvl(l_global_pen_rec.bnft_nnmntry_uom,hr_api.g_varchar2) <>
           nvl(p_bnft_nnmntry_uom,hr_api.g_varchar2)) then
       l_chg := TRUE;
    end if;
    if (p_comp_lvl_cd <> hr_api.g_varchar2 and
           nvl(l_global_pen_rec.comp_lvl_cd,hr_api.g_varchar2) <>
           nvl(p_comp_lvl_cd,hr_api.g_varchar2)) then
       l_chg := TRUE;
    end if;
    --
    -- bug 1712890 added the following columns
    --

--Bug 4770367 : Added the NVL condition so as to allow the user to update
-- the attributes with NULL values if the user wishes to do so

--If DFF field changes from non-zero value to NULL
--               we need to detect that nullify the coverage. So added
--               nvl(p_pen_attributexx, '~')

    if (nvl(p_pen_attribute1 ,'~')<> hr_api.g_varchar2 and
           nvl(l_global_pen_rec.pen_attribute1,hr_api.g_varchar2) <>
           nvl(p_pen_attribute1,hr_api.g_varchar2)) then
       l_chg := TRUE;
    end if;
    if (nvl(p_pen_attribute2 ,'~')<> hr_api.g_varchar2 and
           nvl(l_global_pen_rec.pen_attribute2,hr_api.g_varchar2) <>
           nvl(p_pen_attribute2,hr_api.g_varchar2)) then
       l_chg := TRUE;
    end if;
    if (nvl(p_pen_attribute3 ,'~')<> hr_api.g_varchar2 and
           nvl(l_global_pen_rec.pen_attribute3,hr_api.g_varchar2) <>
           nvl(p_pen_attribute3,hr_api.g_varchar2)) then
       l_chg := TRUE;
    end if;
    if (nvl(p_pen_attribute4 ,'~')<> hr_api.g_varchar2 and
           nvl(l_global_pen_rec.pen_attribute4,hr_api.g_varchar2) <>
           nvl(p_pen_attribute4,hr_api.g_varchar2)) then
       l_chg := TRUE;
    end if;
    if (nvl(p_pen_attribute5 ,'~')<> hr_api.g_varchar2 and
           nvl(l_global_pen_rec.pen_attribute5,hr_api.g_varchar2) <>
           nvl(p_pen_attribute5,hr_api.g_varchar2)) then
       l_chg := TRUE;
    end if;
    if (nvl(p_pen_attribute6 ,'~')<> hr_api.g_varchar2 and
           nvl(l_global_pen_rec.pen_attribute6,hr_api.g_varchar2) <>
           nvl(p_pen_attribute6,hr_api.g_varchar2)) then
       l_chg := TRUE;
    end if;
    if (nvl(p_pen_attribute7 ,'~')<> hr_api.g_varchar2 and
           nvl(l_global_pen_rec.pen_attribute7,hr_api.g_varchar2) <>
           nvl(p_pen_attribute7,hr_api.g_varchar2)) then
       l_chg := TRUE;
    end if;
    if (nvl(p_pen_attribute8 ,'~')<> hr_api.g_varchar2 and
           nvl(l_global_pen_rec.pen_attribute8,hr_api.g_varchar2) <>
           nvl(p_pen_attribute8,hr_api.g_varchar2)) then
       l_chg := TRUE;
    end if;
    if (nvl(p_pen_attribute9 ,'~')<> hr_api.g_varchar2 and
           nvl(l_global_pen_rec.pen_attribute9,hr_api.g_varchar2) <>
           nvl(p_pen_attribute9,hr_api.g_varchar2)) then
       l_chg := TRUE;
    end if;
    if (nvl(p_pen_attribute10 ,'~')<> hr_api.g_varchar2 and
           nvl(l_global_pen_rec.pen_attribute10,hr_api.g_varchar2) <>
           nvl(p_pen_attribute10,hr_api.g_varchar2)) then
       l_chg := TRUE;
    end if;
    if (nvl(p_pen_attribute11 ,'~')<> hr_api.g_varchar2 and
           nvl(l_global_pen_rec.pen_attribute11,hr_api.g_varchar2) <>
           nvl(p_pen_attribute11,hr_api.g_varchar2)) then
       l_chg := TRUE;
    end if;
    if (nvl(p_pen_attribute12 ,'~')<> hr_api.g_varchar2 and
           nvl(l_global_pen_rec.pen_attribute12,hr_api.g_varchar2) <>
           nvl(p_pen_attribute12,hr_api.g_varchar2)) then
       l_chg := TRUE;
    end if;
    if (nvl(p_pen_attribute13 ,'~')<> hr_api.g_varchar2 and
           nvl(l_global_pen_rec.pen_attribute13,hr_api.g_varchar2) <>
           nvl(p_pen_attribute13,hr_api.g_varchar2)) then
       l_chg := TRUE;
    end if;
    if (nvl(p_pen_attribute14 ,'~')<> hr_api.g_varchar2 and
           nvl(l_global_pen_rec.pen_attribute14,hr_api.g_varchar2) <>
           nvl(p_pen_attribute14,hr_api.g_varchar2)) then
       l_chg := TRUE;
    end if;
    if (nvl(p_pen_attribute15 ,'~')<> hr_api.g_varchar2 and
           nvl(l_global_pen_rec.pen_attribute15,hr_api.g_varchar2) <>
           nvl(p_pen_attribute15,hr_api.g_varchar2)) then
       l_chg := TRUE;
    end if;
    if (nvl(p_pen_attribute16 ,'~')<> hr_api.g_varchar2 and
           nvl(l_global_pen_rec.pen_attribute16,hr_api.g_varchar2) <>
           nvl(p_pen_attribute16,hr_api.g_varchar2)) then
       l_chg := TRUE;
    end if;
    if (nvl(p_pen_attribute17 ,'~')<> hr_api.g_varchar2 and
           nvl(l_global_pen_rec.pen_attribute17,hr_api.g_varchar2) <>
           nvl(p_pen_attribute17,hr_api.g_varchar2)) then
       l_chg := TRUE;
    end if;
    if (nvl(p_pen_attribute18 ,'~')<> hr_api.g_varchar2 and
           nvl(l_global_pen_rec.pen_attribute18,hr_api.g_varchar2) <>
           nvl(p_pen_attribute18,hr_api.g_varchar2)) then
       l_chg := TRUE;
    end if;
    if (nvl(p_pen_attribute19 ,'~')<> hr_api.g_varchar2 and
           nvl(l_global_pen_rec.pen_attribute19,hr_api.g_varchar2) <>
           nvl(p_pen_attribute19,hr_api.g_varchar2)) then
       l_chg := TRUE;
    end if;
    if (nvl(p_pen_attribute20 ,'~')<> hr_api.g_varchar2 and
           nvl(l_global_pen_rec.pen_attribute20,hr_api.g_varchar2) <>
           nvl(p_pen_attribute20,hr_api.g_varchar2)) then
       l_chg := TRUE;
    end if;
    if (nvl(p_pen_attribute21 ,'~')<> hr_api.g_varchar2 and
           nvl(l_global_pen_rec.pen_attribute21,hr_api.g_varchar2) <>
           nvl(p_pen_attribute21,hr_api.g_varchar2)) then
       l_chg := TRUE;
    end if;
    if (nvl(p_pen_attribute22 ,'~')<> hr_api.g_varchar2 and
           nvl(l_global_pen_rec.pen_attribute22,hr_api.g_varchar2) <>
           nvl(p_pen_attribute22,hr_api.g_varchar2)) then
       l_chg := TRUE;
    end if;
    if (nvl(p_pen_attribute23 ,'~')<> hr_api.g_varchar2 and
           nvl(l_global_pen_rec.pen_attribute23,hr_api.g_varchar2) <>
           nvl(p_pen_attribute23,hr_api.g_varchar2)) then
       l_chg := TRUE;
    end if;
    if (nvl(p_pen_attribute24 ,'~')<> hr_api.g_varchar2 and
           nvl(l_global_pen_rec.pen_attribute24,hr_api.g_varchar2) <>
           nvl(p_pen_attribute24,hr_api.g_varchar2)) then
       l_chg := TRUE;
    end if;
    if (nvl(p_pen_attribute25 ,'~')<> hr_api.g_varchar2 and
           nvl(l_global_pen_rec.pen_attribute25,hr_api.g_varchar2) <>
           nvl(p_pen_attribute25,hr_api.g_varchar2)) then
       l_chg := TRUE;
    end if;
    if (nvl(p_pen_attribute26 ,'~')<> hr_api.g_varchar2 and
           nvl(l_global_pen_rec.pen_attribute26,hr_api.g_varchar2) <>
           nvl(p_pen_attribute26,hr_api.g_varchar2)) then
       l_chg := TRUE;
    end if;
    if (nvl(p_pen_attribute27 ,'~')<> hr_api.g_varchar2 and
           nvl(l_global_pen_rec.pen_attribute27,hr_api.g_varchar2) <>
           nvl(p_pen_attribute27,hr_api.g_varchar2)) then
       l_chg := TRUE;
    end if;
    if (nvl(p_pen_attribute28 ,'~')<> hr_api.g_varchar2 and
           nvl(l_global_pen_rec.pen_attribute28,hr_api.g_varchar2) <>
           nvl(p_pen_attribute28,hr_api.g_varchar2)) then
       l_chg := TRUE;
    end if;
    if (nvl(p_pen_attribute29 ,'~')<> hr_api.g_varchar2 and
           nvl(l_global_pen_rec.pen_attribute29,hr_api.g_varchar2) <>
           nvl(p_pen_attribute29,hr_api.g_varchar2)) then
       l_chg := TRUE;
    end if;
    if (nvl(p_pen_attribute30 ,'~')<> hr_api.g_varchar2 and
           nvl(l_global_pen_rec.pen_attribute30,hr_api.g_varchar2) <>
           nvl(p_pen_attribute30,hr_api.g_varchar2)) then
       l_chg := TRUE;
    end if;
--End Bug 4770367

    if (l_chg) then
l_step := 60;


    -- Check dt mode is valid
    --
    dt_api.find_dt_upd_modes
      (p_effective_date       => p_effective_date,
       p_base_table_name      => 'BEN_PRTT_ENRT_RSLT_F',
       p_base_key_column      => 'prtt_enrt_rslt_id',
       p_base_key_value       => p_prtt_enrt_rslt_id,
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
        --
        -- Start of API User Hook for the before hook of
        -- update_PRTT_ENRT_RESULT
        --
        ben_PRTT_ENRT_RESULT_API.update_PRTT_ENRT_RESULT
                 (p_validate                   =>  FALSE
                 ,p_prtt_enrt_rslt_id          =>  p_prtt_enrt_rslt_id
                 ,p_effective_start_date       =>  l_effective_start_date
                 ,p_effective_end_date         =>  l_effective_end_date
                 ,p_business_group_id          =>  p_business_group_id
                 ,p_oipl_id                    =>  p_oipl_id
                 ,p_person_id                  =>  p_person_id
                 ,p_assignment_id              =>  p_assignment_id
                 ,p_pgm_id                     =>  p_pgm_id
                 ,p_pl_id                      =>  p_pl_id
                 ,p_rplcs_sspndd_rslt_id       =>  p_rplcs_sspndd_rslt_id
                 ,p_ptip_id                    =>  p_ptip_id
                 ,p_pl_typ_id                  =>  p_pl_typ_id
                 ,p_ler_id                     =>  p_ler_id
                 ,p_sspndd_flag                =>  p_sspndd_flag
                 ,p_prtt_is_cvrd_flag          =>  p_prtt_is_cvrd_flag
                 ,p_bnft_amt                   =>  p_bnft_amt
                 ,p_uom                        =>  p_uom
                 ,p_orgnl_enrt_dt              =>  p_orgnl_enrt_dt
                 ,p_enrt_mthd_cd               =>  p_enrt_mthd_cd
                 ,p_enrt_ovridn_flag           =>  p_enrt_ovridn_flag
                 ,p_enrt_ovrid_rsn_cd          =>  p_enrt_ovrid_rsn_cd
                 ,p_erlst_deenrt_dt            =>  p_erlst_deenrt_dt
                 ,p_enrt_cvg_strt_dt           =>  p_enrt_cvg_strt_dt
                 ,p_enrt_cvg_thru_dt           =>  p_enrt_cvg_thru_dt
                 ,p_enrt_ovrid_thru_dt         =>  p_enrt_ovrid_thru_dt
             ,p_pl_ordr_num                =>  p_pl_ordr_num
             ,p_plip_ordr_num              =>  p_plip_ordr_num
             ,p_ptip_ordr_num              =>  p_ptip_ordr_num
             ,p_oipl_ordr_num              =>  p_oipl_ordr_num
                 ,p_pen_attribute_category     =>  p_pen_attribute_category
                 ,p_pen_attribute1             =>  p_pen_attribute1
                 ,p_pen_attribute2             =>  p_pen_attribute2
                 ,p_pen_attribute3             =>  p_pen_attribute3
                 ,p_pen_attribute4             =>  p_pen_attribute4
                 ,p_pen_attribute5             =>  p_pen_attribute5
                 ,p_pen_attribute6             =>  p_pen_attribute6
                 ,p_pen_attribute7             =>  p_pen_attribute7
                 ,p_pen_attribute8             =>  p_pen_attribute8
                 ,p_pen_attribute9             =>  p_pen_attribute9
                 ,p_pen_attribute10            =>  p_pen_attribute10
                 ,p_pen_attribute11            =>  p_pen_attribute11
                 ,p_pen_attribute12            =>  p_pen_attribute12
                 ,p_pen_attribute13            =>  p_pen_attribute13
                 ,p_pen_attribute14            =>  p_pen_attribute14
                 ,p_pen_attribute15            =>  p_pen_attribute15
                 ,p_pen_attribute16            =>  p_pen_attribute16
                 ,p_pen_attribute17            =>  p_pen_attribute17
                 ,p_pen_attribute18            =>  p_pen_attribute18
                 ,p_pen_attribute19            =>  p_pen_attribute19
                 ,p_pen_attribute20            =>  p_pen_attribute20
                 ,p_pen_attribute21            =>  p_pen_attribute21
                 ,p_pen_attribute22            =>  p_pen_attribute22
                 ,p_pen_attribute23            =>  p_pen_attribute23
                 ,p_pen_attribute24            =>  p_pen_attribute24
                 ,p_pen_attribute25            =>  p_pen_attribute25
                 ,p_pen_attribute26            =>  p_pen_attribute26
                 ,p_pen_attribute27            =>  p_pen_attribute27
                 ,p_pen_attribute28            =>  p_pen_attribute28
                 ,p_pen_attribute29            =>  p_pen_attribute29
                 ,p_pen_attribute30            =>  p_pen_attribute30
                 ,p_request_id                 =>  fnd_global.conc_request_id
                 ,p_program_application_id     =>  fnd_global.prog_appl_id
                 ,p_program_id                 =>  fnd_global.conc_program_id
                 ,p_program_update_date        =>  sysdate
                 ,p_object_version_number      =>  l_object_version_number
                 ,p_per_in_ler_id              =>  p_per_in_ler_id
                 ,p_bnft_typ_cd                =>  p_bnft_typ_cd
                 ,p_bnft_ordr_num              =>  p_bnft_ordr_num
                 ,p_prtt_enrt_rslt_stat_cd     =>  p_prtt_enrt_rslt_stat_cd
                 ,p_bnft_nnmntry_uom           =>  p_bnft_nnmntry_uom
                 ,p_comp_lvl_cd                =>  p_comp_lvl_cd
                 ,p_effective_date             =>  trunc(p_effective_date)
                 ,p_datetrack_mode             =>  l_datetrack_mode
                 ,p_multi_row_validate         =>  p_multi_row_validate
                 );

        ben_global_enrt.reload_pen  -- result  globals re-loaded after update.
          (p_prtt_enrt_rslt_id      => p_prtt_enrt_rslt_id
          ,p_effective_date         => p_effective_date
          ,p_global_pen_rec         => l_global_pen_rec);
          ----call update for flex cedit entries for rate change
       if p_comp_lvl_cd in ('PLANFC', 'PLANIMP') then
          null;
       else
         if l_global_pen_rec.pgm_id is not null then
           open c_prtt_enrt;
           fetch c_prtt_enrt into l_prtt_enrt_rslt_id;
           close c_prtt_enrt;
           for i in  c_flex_choice  Loop
               l_prvdd_val := null;
               open c_bpl ( i.acty_base_rt_id ,
                          i.bnft_prvdr_pool_id,
                          l_prtt_enrt_rslt_id  ) ;
               fetch c_bpl into l_prvdd_val ;
               close c_bpl ;
               --if there is amount change call the updating
               if g_debug then
                  hr_utility.set_location( 'prvdd val ' || l_prvdd_val  ||
                                           ' ; changed val  ' || i.val , 1001);
               end if;

               if l_prvdd_val is not null and l_prvdd_val <> i.val then
                   ben_provider_pools.create_credit_ledger_entry
                       ( p_person_id               => p_person_id  ,
                         p_elig_per_elctbl_chc_id  => i.elig_per_elctbl_chc_id ,
                         p_per_in_ler_id           => i.per_in_ler_id,
                         p_business_group_id       => p_business_group_id ,
                         p_bnft_prvdr_pool_id      => i.bnft_prvdr_pool_id,
                         p_enrt_mthd_cd            => p_enrt_mthd_cd,
                         p_effective_date          => p_effective_date );
               end if;
           end loop ;
           open c_elig_per_elctbl_chc;
           fetch  c_elig_per_elctbl_chc into l_elig_per_elctbl_chc_id;
           close c_elig_per_elctbl_chc;

           ben_provider_pools.accumulate_pools
            (p_validate               => FALSE
            ,p_person_id              => p_person_id
            ,p_elig_per_elctbl_chc_id => l_elig_per_elctbl_chc_id
            ,p_business_group_id      => p_business_group_id
            ,p_enrt_mthd_cd           => p_enrt_mthd_cd
            ,p_effective_date         => p_effective_date
            );

         end if; -- pgm_id is not null.
       end if;

        for l_prem in c_prem loop
           l_step := 70;
           -- bug 158783. jcarpent reset l_ppe.prtt_prem_id
           l_ppe.prtt_prem_id:=null;
           /* Start of Changes for WWBUG: 1646442: added                */
           open c_pel(l_prem.elig_per_elctbl_chc_id);
           fetch c_pel into l_pel;
           close c_pel;

           ben_determine_date.rate_and_coverage_dates
                  (p_which_dates_cd         => 'R'
                  ,p_date_mandatory_flag    => 'Y'
                  ,p_compute_dates_flag     => 'Y'
                  ,p_business_group_id      => p_business_group_id
                  ,P_PER_IN_LER_ID          => p_per_in_ler_id
                  ,P_PERSON_ID              => p_person_id
                  ,P_PGM_ID                 => p_pgm_id
                  ,P_PL_ID                  => p_pl_id
                  ,P_OIPL_ID                => p_oipl_id
                  ,P_LEE_RSN_ID             => l_pel.lee_rsn_id
                  ,P_ENRT_PERD_ID           => l_pel.enrt_perd_id
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
                  ,p_effective_date         => p_effective_date
                  ,p_lf_evt_ocrd_dt         => nvl(l_prem.lf_evt_ocrd_dt,p_effective_date)
                  );

           l_ppe_dt_to_use := greatest(p_enrt_cvg_strt_dt,l_rt_strt_dt);
           /* End of Changes for WWBUG: 1646442                 */
           /*
                CODE PRIOR TO WWBUG: 1646442
           open c_ppe(p_prtt_enrt_rslt_id, l_prem.actl_prem_id);
           */
           /* Start of Changes for WWBUG: 1646442               */
           open c_ppe(p_prtt_enrt_rslt_id, l_prem.actl_prem_id,l_ppe_dt_to_use);
           /* End of Changes for WWBUG: 1646442                 */
             fetch c_ppe into l_ppe;
           close c_ppe;
           l_step := 71;
           if l_ppe.prtt_prem_id is not null then
             /********************* CODE PRIOR TO WWBUG: 1646442 *****
             ***  moved this code below ****
             --
             -- Find the valid datetrack modes.
             --
             dt_api.find_dt_upd_modes
             (p_effective_date       => p_effective_date,
              p_base_table_name      => 'BEN_PRTT_PREM_F',
              p_base_key_column      => 'prtt_prem_id',
              p_base_key_value       => l_ppe.prtt_prem_id,
              p_correction           => l_correction,
              p_update               => l_update,
              p_update_override      => l_update_override,
              p_update_change_insert => l_update_change_insert);
             --
             if l_update_override then
             --
               l_ppe_datetrack_mode := hr_api.g_update_override;
             --
             elsif l_update then
             --
               l_ppe_datetrack_mode := hr_api.g_update;
             --
             else
             --
               l_ppe_datetrack_mode := hr_api.g_correction;
             end if;
             ********************* END CODE PRIOR TO WWBUG: 1646442  *********/
             -- Because the benefit amount could have changed, and the premiums
             -- can be based on the benefit amount, re-calc it.  It does a recalc
             -- if the benefit amount is entered at enrollment.
             -- PPE is from prtt-prem.  prem is from enrt-prem.
             ben_PRTT_PREM_api.recalc_PRTT_PREM
                 (p_prtt_prem_id                   =>  l_ppe.prtt_prem_id
                 ,p_std_prem_uom                   =>  l_prem.uom
                 ,p_std_prem_val                   =>  l_prem.val  -- in/out
                 ,p_actl_prem_id                   =>  l_prem.actl_prem_id
                 ,p_prtt_enrt_rslt_id              =>  p_prtt_enrt_rslt_id
                 ,p_per_in_ler_id                  =>  p_per_in_ler_id
                 ,p_ler_id                         =>  l_prem.ler_id
                 ,p_lf_evt_ocrd_dt                 =>  l_prem.lf_evt_ocrd_dt
                 ,p_elig_per_elctbl_chc_id         =>  l_prem.elig_per_elctbl_chc_id
                 ,p_enrt_bnft_id                   =>  p_enrt_bnft_id
                 ,p_business_group_id              =>  p_business_group_id
                 ,p_effective_date                 =>  p_effective_date
                 -- bof FONM
                 ,p_enrt_cvg_strt_dt               => nvl(l_enrt_cvg_strt_dt,l_ppe_dt_to_use)
                 ,p_rt_strt_dt                     => l_rt_strt_dt
                 -- eof FONM
                 );

             l_step := 72;
	     ---For the Bug : 7133998

	        hr_utility.set_location('p_prtt_enrt_rslt_id,srav : '||p_prtt_enrt_rslt_id,1);
	     hr_utility.set_location('l_prem.actl_prem_id : '||l_prem.actl_prem_id,1);
	     hr_utility.set_location('l_ppe_dt_to_use : '||l_ppe_dt_to_use,1);

	     -----check if there are any future rows corresponding to the Previous LE's.
	      --------7133998
	     l_count := 0;
	     hr_utility.set_location('srav,in else',1);
	     for l_ppe1 in c_ppe1(p_prtt_enrt_rslt_id, l_prem.actl_prem_id,l_ppe_dt_to_use) loop
	      l_count := l_count + 1;
	      hr_utility.set_location('c_ppe1 found',1);
	      hr_utility.set_location('l_ppe1.prtt_prem_id : '||l_ppe1.prtt_prem_id,1);
	     ---bkup table
             insert into BEN_LE_CLSN_N_RSTR (
                      BKUP_TBL_TYP_CD,
                      LCR_ATTRIBUTE6,
                      LCR_ATTRIBUTE7,
                      LCR_ATTRIBUTE8,
                      LCR_ATTRIBUTE9,
                      LCR_ATTRIBUTE10,
                      LCR_ATTRIBUTE11,
                      LCR_ATTRIBUTE12,
                      LCR_ATTRIBUTE13,
                      LCR_ATTRIBUTE14,
                      LCR_ATTRIBUTE15,
                      LCR_ATTRIBUTE16,
                      LCR_ATTRIBUTE17,
                      LCR_ATTRIBUTE18,
                      LCR_ATTRIBUTE19,
                      LCR_ATTRIBUTE20,
                      LCR_ATTRIBUTE21,
                      LCR_ATTRIBUTE22,
                      LCR_ATTRIBUTE23,
                      LCR_ATTRIBUTE24,
                      LCR_ATTRIBUTE25,
                      LCR_ATTRIBUTE26,
                      LCR_ATTRIBUTE27,
                      LCR_ATTRIBUTE28,
                      LCR_ATTRIBUTE29,
                      LCR_ATTRIBUTE30,
                      LAST_UPDATE_DATE,
                      LAST_UPDATED_BY,
                      LAST_UPDATE_LOGIN,
                      CREATED_BY,
                      CREATION_DATE,
                      OBJECT_VERSION_NUMBER,
                      REQUEST_ID,
                      PROGRAM_APPLICATION_ID,
                      PROGRAM_ID,
                      PROGRAM_UPDATE_DATE,
                      PER_IN_LER_ID,
		      PER_IN_LER_ENDED_ID,
                      BKUP_TBL_ID, -- PRTT_PREM_ID,
                      EFFECTIVE_START_DATE,
                      EFFECTIVE_END_DATE,
                      STD_PREM_UOM,
                      STD_PREM_VAL,
                      ACTL_PREM_ID,
                      PRTT_ENRT_RSLT_ID,
                      BUSINESS_GROUP_ID,
                      LCR_ATTRIBUTE_CATEGORY,
                      LCR_ATTRIBUTE1,
                      LCR_ATTRIBUTE2,
                      LCR_ATTRIBUTE3,
                      LCR_ATTRIBUTE4,
                      LCR_ATTRIBUTE5
                      )
                  values (
                      'BEN_PRTT_PREM_F_CORR',
                     l_ppe1.PPE_ATTRIBUTE6,
                     l_ppe1.PPE_ATTRIBUTE7,
                     l_ppe1.PPE_ATTRIBUTE8,
                     l_ppe1.PPE_ATTRIBUTE9,
                     l_ppe1.PPE_ATTRIBUTE10,
                     l_ppe1.PPE_ATTRIBUTE11,
                     l_ppe1.PPE_ATTRIBUTE12,
                     l_ppe1.PPE_ATTRIBUTE13,
                     l_ppe1.PPE_ATTRIBUTE14,
                     l_ppe1.PPE_ATTRIBUTE15,
                     l_ppe1.PPE_ATTRIBUTE16,
                     l_ppe1.PPE_ATTRIBUTE17,
                     l_ppe1.PPE_ATTRIBUTE18,
                     l_ppe1.PPE_ATTRIBUTE19,
                     l_ppe1.PPE_ATTRIBUTE20,
                     l_ppe1.PPE_ATTRIBUTE21,
                     l_ppe1.PPE_ATTRIBUTE22,
                     l_ppe1.PPE_ATTRIBUTE23,
                     l_ppe1.PPE_ATTRIBUTE24,
                     l_ppe1.PPE_ATTRIBUTE25,
                     l_ppe1.PPE_ATTRIBUTE26,
                     l_ppe1.PPE_ATTRIBUTE27,
                     l_ppe1.PPE_ATTRIBUTE28,
                     l_ppe1.PPE_ATTRIBUTE29,
                     l_ppe1.PPE_ATTRIBUTE30,
                     l_ppe1.LAST_UPDATE_DATE,
                     l_ppe1.LAST_UPDATED_BY,
                     l_ppe1.LAST_UPDATE_LOGIN,
                     l_ppe1.CREATED_BY,
                     l_ppe1.CREATION_DATE,
                     l_ppe1.OBJECT_VERSION_NUMBER,
                     l_ppe1.REQUEST_ID,
                     l_ppe1.PROGRAM_APPLICATION_ID,
                     l_ppe1.PROGRAM_ID,
                     l_ppe1.PROGRAM_UPDATE_DATE,
                     l_ppe1.PER_IN_LER_ID,
		     p_per_in_ler_id,
                     l_ppe1.PRTT_PREM_ID,
                     l_ppe1.EFFECTIVE_START_DATE,
                     l_ppe1.EFFECTIVE_END_DATE,
                     l_ppe1.STD_PREM_UOM,
                     l_ppe1.STD_PREM_VAL,
                     l_ppe1.ACTL_PREM_ID,
                     l_ppe1.PRTT_ENRT_RSLT_ID,
                     l_ppe1.BUSINESS_GROUP_ID,
                     l_ppe1.PPE_ATTRIBUTE_CATEGORY,
                     l_ppe1.PPE_ATTRIBUTE1,
                     l_ppe1.PPE_ATTRIBUTE2,
                     l_ppe1.PPE_ATTRIBUTE3,
                     l_ppe1.PPE_ATTRIBUTE4,
                     l_ppe1.PPE_ATTRIBUTE5
                  );

	     ben_prtt_prem_api.update_prtt_prem
                ( p_validate                => FALSE
                 ,p_prtt_prem_id            => l_ppe1.prtt_prem_id
                 ,p_effective_start_date    => p_effective_start_date
                 ,p_effective_end_date      => p_effective_end_date
                 ,p_per_in_ler_id           => p_per_in_ler_id
                 ,p_business_group_id       => p_business_group_id
		 ,p_prtt_enrt_rslt_id       => l_ppe1.prtt_enrt_rslt_id
                 ,p_object_version_number   => l_ppe1.object_version_number
                 ,p_request_id              => fnd_global.conc_request_id
                 ,p_program_application_id  => fnd_global.prog_appl_id
                 ,p_program_id              => fnd_global.conc_program_id
                 ,p_program_update_date     => sysdate
                 ,p_effective_date           => l_ppe1.effective_start_date
                 ,p_datetrack_mode          => 'CORRECTION'

             );
             end loop;
	        open c_ppe(p_prtt_enrt_rslt_id, l_prem.actl_prem_id,l_ppe_dt_to_use);
             fetch c_ppe into l_ppe;
           close c_ppe;
             /* Start of Changes for WWBUG: 1646442                     */
             /*  moved from above                                       */
             --
	     If l_count = 0 then --------7133998
             -- Find the valid datetrack modes.
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
             --
               l_ppe_datetrack_mode := hr_api.g_update_override;
             --
             elsif l_update then
             --
               l_ppe_datetrack_mode := hr_api.g_update;
             --
             else
             --
               l_ppe_datetrack_mode := hr_api.g_correction;
             end if;
             /* End of Changes for WWBUG: 1646442                       */

             ben_prtt_prem_api.update_prtt_prem
                ( p_validate                => FALSE
                 ,p_prtt_prem_id            => l_ppe.prtt_prem_id
                 ,p_effective_start_date    => p_effective_start_date
                 ,p_effective_end_date      => p_effective_end_date
                 ,p_std_prem_uom            => l_prem.uom
                 ,p_std_prem_val            => l_prem.val
                 ,p_actl_prem_id            => l_prem.actl_prem_id
                 ,p_prtt_enrt_rslt_id       => p_prtt_enrt_rslt_id
                 ,p_per_in_ler_id           => p_per_in_ler_id
                 ,p_business_group_id       => p_business_group_id
                 ,p_object_version_number   => l_ppe.object_version_number
                 ,p_request_id              => fnd_global.conc_request_id
                 ,p_program_application_id  => fnd_global.prog_appl_id
                 ,p_program_id              => fnd_global.conc_program_id
                 ,p_program_update_date     => sysdate
              /*
                 CODE PRIOR TO WWBUG: 1646442
                 ,p_effective_date          => p_effective_date
              */
              /* Start of Changes for WWBUG: 1646442                    */
                 ,p_effective_date           => l_ppe_dt_to_use
              /* End of Changes for WWBUG: 1646442                      */
                 ,p_datetrack_mode          => l_ppe_datetrack_mode
             );
	   end if;------7133998
           else
             ben_PRTT_PREM_api.recalc_PRTT_PREM
                 (p_prtt_prem_id                   =>  null
                 ,p_std_prem_uom                   =>  l_prem.uom
                 ,p_std_prem_val                   =>  l_prem.val  -- in/out
                 ,p_actl_prem_id                   =>  l_prem.actl_prem_id
                 ,p_prtt_enrt_rslt_id              =>  p_prtt_enrt_rslt_id
                 ,p_per_in_ler_id                  =>  p_per_in_ler_id
                 ,p_ler_id                         =>  l_prem.ler_id
                 ,p_lf_evt_ocrd_dt                 =>  l_prem.lf_evt_ocrd_dt
                 ,p_elig_per_elctbl_chc_id         =>  l_prem.elig_per_elctbl_chc_id
                 ,p_enrt_bnft_id                   =>  p_enrt_bnft_id
                 ,p_business_group_id              =>  p_business_group_id
                 ,p_effective_date                 =>  p_effective_date
                 -- bof FONM
                 ,p_enrt_cvg_strt_dt               => nvl(l_enrt_cvg_strt_dt,l_ppe_dt_to_use)
                 ,p_rt_strt_dt                     => l_rt_strt_dt
                 -- eof FONM
                );
             l_step := 130;
             ben_prtt_prem_api.create_prtt_prem
              ( p_validate                => FALSE
               ,p_prtt_prem_id            => l_ppe.prtt_prem_id
               ,p_effective_start_date    => p_effective_start_date
               ,p_effective_end_date      => p_effective_end_date
               ,p_std_prem_uom            => l_prem.uom
               ,p_std_prem_val            => l_prem.val
               ,p_actl_prem_id            => l_prem.actl_prem_id
               ,p_prtt_enrt_rslt_id       => p_prtt_enrt_rslt_id
               ,p_per_in_ler_id           => p_per_in_ler_id
               ,p_business_group_id       => p_business_group_id
               ,p_object_version_number   => l_ppe.object_version_number
               ,p_request_id              => fnd_global.conc_request_id
               ,p_program_application_id  => fnd_global.prog_appl_id
               ,p_program_id              => fnd_global.conc_program_id
               ,p_program_update_date     => sysdate
              /*
                  CODE PRIOR TO WWBUG: 1646442
               ,p_effective_date          => p_effective_date
              */
              /* Start of Changes for WWBUG: 1646442                    */
               ,p_effective_date          => l_ppe_dt_to_use
              /* End of Changes for WWBUG: 1646442                      */
             );
             --
           end if;
        end loop;

	--------Bug 8919376
        for l_chk_cvrd_dpnt in c_check_cvrd_dpnt loop
	   ben_elig_dpnt_api.update_perf_elig_dpnt
                (p_elig_dpnt_id           => l_chk_cvrd_dpnt.elig_dpnt_id
                ,p_per_in_ler_id          => l_chk_cvrd_dpnt.per_in_ler_id
                ,p_elig_thru_dt           => l_chk_cvrd_dpnt.elig_thru_dt
		,p_elig_cvrd_dpnt_id      => l_chk_cvrd_dpnt.cvrd_dpnt_id
                ,p_object_version_number  => l_chk_cvrd_dpnt.object_version_number
                ,p_effective_date         => l_chk_cvrd_dpnt.create_dt
                ,p_program_application_id => fnd_global.prog_appl_id
                ,p_program_id             => fnd_global.conc_program_id
                ,p_request_id             => fnd_global.conc_request_id
                ,p_program_update_date    => sysdate
                );
	end loop;
	----------Bug 8919376
        -- un-end dpnt coverage for existing dependents.
        for l_egd in c_egd loop
          --
          -- Find the valid datetrack modes.
          --
          dt_api.find_dt_upd_modes
          (p_effective_date       => p_effective_date,
           p_base_table_name      => 'BEN_ELIG_CVRD_DPNT_F',
           p_base_key_column      => 'elig_cvrd_dpnt_id',
           p_base_key_value       => l_egd.elig_cvrd_dpnt_id,
           p_correction           => l_correction,
           p_update               => l_update,
           p_update_override      => l_update_override,
           p_update_change_insert => l_update_change_insert);

          if l_update_override then
            l_egd_datetrack_mode := hr_api.g_update_override;
          elsif l_update then
            l_egd_datetrack_mode := hr_api.g_update;
          else
            l_egd_datetrack_mode := hr_api.g_correction;
          end if;

          ben_elig_cvrd_dpnt_api.update_elig_cvrd_dpnt(
              p_elig_cvrd_dpnt_id     => l_egd.elig_cvrd_dpnt_id,
              p_effective_start_date  => p_effective_start_date,
              p_effective_end_date    => p_effective_end_date,
              p_business_group_id     => p_business_group_id,
              p_per_in_ler_id         => p_per_in_ler_id,
              p_cvg_thru_dt           => hr_api.g_eot,
              p_object_version_number => l_egd.object_version_number,
              p_datetrack_mode        => l_egd_datetrack_mode,
              p_request_id              => fnd_global.conc_request_id,
              p_program_application_id  => fnd_global.prog_appl_id,
              p_program_id              => fnd_global.conc_program_id,
              p_program_update_date     => sysdate,
              p_effective_date          => p_effective_date,
              p_multi_row_actn          => FALSE);
           --
           -- Bug 1418754
           --
           ben_ELIG_CVRD_DPNT_api.chk_max_num_dpnt_for_pen (
             p_prtt_enrt_rslt_id      => p_PRTT_ENRT_RSLT_ID,
             p_effective_date         => p_effective_date,
             p_business_group_id      => p_business_group_id);
           --
        end loop;
        --
        -- write to the change event log.  thayden.
        --
        ben_ext_chlg.log_benefit_chg
        (p_action                      => 'UPDATE'
        ,p_pl_id                       =>  p_pl_id
        ,p_old_pl_id                   =>  l_global_pen_rec.pl_id
        ,p_oipl_id                     =>  p_oipl_id
        ,p_old_oipl_id                 =>  l_global_pen_rec.oipl_id
        ,p_enrt_cvg_strt_dt            =>  p_enrt_cvg_strt_dt
        ,p_old_enrt_cvg_strt_dt        =>  l_global_pen_rec.enrt_cvg_strt_dt
        ,p_bnft_amt                    =>  p_bnft_amt
        ,p_old_bnft_amt                =>  l_global_pen_rec.bnft_amt
        ,p_pen_attribute1              =>  p_pen_attribute1
        ,p_old_pen_attribute1          =>  l_global_pen_rec.pen_attribute1
        ,p_pen_attribute2              =>  p_pen_attribute2
        ,p_old_pen_attribute2          =>  l_global_pen_rec.pen_attribute2
        ,p_pen_attribute3              =>  p_pen_attribute3
        ,p_old_pen_attribute3          =>  l_global_pen_rec.pen_attribute3
        ,p_pen_attribute4              =>  p_pen_attribute4
        ,p_old_pen_attribute4          =>  l_global_pen_rec.pen_attribute4
        ,p_pen_attribute5              =>  p_pen_attribute5
        ,p_old_pen_attribute5          =>  l_global_pen_rec.pen_attribute5
        ,p_pen_attribute6              =>  p_pen_attribute6
        ,p_old_pen_attribute6          =>  l_global_pen_rec.pen_attribute6
        ,p_pen_attribute7              =>  p_pen_attribute7
        ,p_old_pen_attribute7          =>  l_global_pen_rec.pen_attribute7
        ,p_pen_attribute8              =>  p_pen_attribute8
        ,p_old_pen_attribute8          =>  l_global_pen_rec.pen_attribute8
        ,p_pen_attribute9              =>  p_pen_attribute9
        ,p_old_pen_attribute9          =>  l_global_pen_rec.pen_attribute9
        ,p_pen_attribute10             =>  p_pen_attribute10
        ,p_old_pen_attribute10         =>  l_global_pen_rec.pen_attribute10
        ,p_prtt_enrt_rslt_id           =>  p_prtt_enrt_rslt_id
        ,p_per_in_ler_id               =>  l_global_pen_rec.per_in_ler_id
        ,p_person_id                   =>  p_person_id
        ,p_business_group_id           =>  p_business_group_id
        ,p_effective_date              =>  p_effective_date
        );
        -- Bug 3866580
        --
        -- Find out the Option Type of Plan Type of the Plan being enrolled in
        /*
       It is better to go by savings plan flag rather option type code as
       the type code is only informational
        open c_pl_typ_opt_typ_cd (l_pl_rec.pl_typ_id, p_effective_date);
           fetch c_pl_typ_opt_typ_cd into l_pl_typ_opt_typ_cd;
        close c_pl_typ_opt_typ_cd;
        --
        */
        if    ( l_pl_rec.svgs_pl_flag = 'Y' and p_oipl_id is null and l_pl_rec.ENRT_PL_OPT_FLAG = 'Y' )
       or ( l_pl_rec.svgs_pl_flag = 'N')
        then
    /*
        if    ( l_pl_typ_opt_typ_cd = 'SVG' and p_oipl_id is null and l_pl_rec.ENRT_PL_OPT_FLAG = 'Y' )
           or ( nvl(l_pl_typ_opt_typ_cd, 'XXXX') <> 'SVG' )
        then
        /*
        Commented this part, as Enrollment Action Items for all enrollment in "Plans"
        as well as "Option In Plans" should be determined except for savings plan. In case
        of savings plan, enrollment actions items should be determined only if enrollment is in
        plan level (i.e. p_oipl_id = NULL
        --
        If l_pl_rec.enrt_pl_opt_flag = 'N'
           or (l_pl_rec.enrt_pl_opt_flag = 'Y' and l_global_pen_rec.oipl_id is NULL) then
        */
          l_step := 165;
          ben_enrollment_action_items.determine_action_items
            (p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
            ,p_effective_date             => p_effective_date
            ,p_business_group_id          => p_business_group_id
            ,p_datetrack_mode             => l_datetrack_mode
            ,p_suspend_flag               => p_suspend_flag
            ,p_rslt_object_version_number => l_object_version_number
            ,p_enrt_bnft_id               => p_enrt_bnft_id
            ,p_post_rslt_flag             => l_post_rslt_flag
            ,p_dpnt_actn_warning          => p_dpnt_actn_warning
            ,p_bnf_actn_warning           => p_bnf_actn_warning
            ,p_ctfn_actn_warning          => p_ctfn_actn_warning
            );
          ben_global_enrt.get_pen  -- result
           (p_prtt_enrt_rslt_id      => p_prtt_enrt_rslt_id
           ,p_effective_date         => p_effective_date
           ,p_global_pen_rec         => l_global_pen_rec);
       l_step :=71;
           open c_interim_enrt;
           fetch c_interim_enrt into p_prtt_enrt_interim_id;
           close c_interim_enrt;
        else
          -- set the out parms that would have come from action item.
          p_dpnt_actn_warning := false;
          p_bnf_actn_warning  := false;
          p_ctfn_actn_warning := false;
          p_suspend_flag := l_global_pen_rec.sspndd_flag;
          if l_global_pen_rec.sspndd_flag='Y' then
            open c_interim_enrt;
            fetch c_interim_enrt into p_prtt_enrt_interim_id;
            close c_interim_enrt;
          end if;
        end if;
    end if;
    if g_debug then
       hr_utility.set_location(l_proc, 60);
    end if;
    --
    -- When in validation only mode raise the Validate_Enabled exception
    --
    if p_validate then
        raise hr_api.validate_enabled;
    end if;
    --
    -- Set all output arguments
    --
    p_object_version_number := l_object_version_number;
    p_effective_start_date := l_effective_start_date;
    p_effective_end_date := l_effective_end_date;
    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 70);
    end if;
exception
    when hr_api.validate_enabled then
        --
        -- As the Validate_Enabled exception has been raised
        -- we must rollback to the savepoint
        --
        ROLLBACK TO update_ENROLLMENT;
        --
        -- Only set output warning arguments
        -- (Any key or derived arguments must be set to null
        -- when validation only mode is being used.)
        --
        if g_debug then
           hr_utility.set_location(' Leaving:'||l_proc, 80);
        end if;
    when others then
        --
        -- A validation or unexpected error has occured
        --
        ROLLBACK TO update_ENROLLMENT;
        rpt_error(p_proc => l_proc, p_step => l_step);
        p_effective_start_date := null; --nocopy change
        p_effective_end_date := null; --nocopy change
        raise;
end update_ENROLLMENT;
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_PRTT_ENRT_RESULT >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_PRTT_ENRT_RESULT
  (p_validate                       in  boolean   default false
  ,p_prtt_enrt_rslt_id              in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_oipl_id                        in  number    default hr_api.g_number
  ,p_person_id                      in  number    default hr_api.g_number
  ,p_assignment_id                  in  number    default hr_api.g_number
  ,p_pgm_id                         in  number    default hr_api.g_number
  ,p_pl_id                          in  number    default hr_api.g_number
  ,p_rplcs_sspndd_rslt_id           in  number    default hr_api.g_number
  ,p_ptip_id                        in  number    default hr_api.g_number
  ,p_pl_typ_id                      in  number    default hr_api.g_number
  ,p_ler_id                         in  number    default hr_api.g_number
  ,p_sspndd_flag                    in  varchar2  default hr_api.g_varchar2
  ,p_prtt_is_cvrd_flag              in  varchar2  default hr_api.g_varchar2
  ,p_bnft_amt                       in  number    default hr_api.g_number
  ,p_uom                            in  varchar2  default hr_api.g_varchar2
  ,p_orgnl_enrt_dt                  in  date      default hr_api.g_date
  ,p_enrt_mthd_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_no_lngr_elig_flag              in  varchar2  default hr_api.g_varchar2
  ,p_enrt_ovridn_flag               in  varchar2  default hr_api.g_varchar2
  ,p_enrt_ovrid_rsn_cd              in  varchar2  default hr_api.g_varchar2
  ,p_erlst_deenrt_dt                in  date      default hr_api.g_date
  ,p_enrt_cvg_strt_dt               in  date      default hr_api.g_date
  ,p_enrt_cvg_thru_dt               in  date      default hr_api.g_date
  ,p_enrt_ovrid_thru_dt             in  date      default hr_api.g_date
  ,p_pl_ordr_num                    in  number    default hr_api.g_number
  ,p_plip_ordr_num                  in  number    default hr_api.g_number
  ,p_ptip_ordr_num                  in  number    default hr_api.g_number
  ,p_oipl_ordr_num                  in  number    default hr_api.g_number
  ,p_pen_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_request_id                     in  number    default hr_api.g_number
  ,p_program_application_id         in  number    default hr_api.g_number
  ,p_program_id                     in  number    default hr_api.g_number
  ,p_program_update_date            in  date      default hr_api.g_date
  ,p_object_version_number          in  out nocopy number
  ,p_per_in_ler_id                  in  number    default hr_api.g_number
  ,p_bnft_typ_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_bnft_ordr_num                  in  number    default hr_api.g_number
  ,p_prtt_enrt_rslt_stat_cd         in  varchar2  default hr_api.g_varchar2
  ,p_bnft_nnmntry_uom               in  varchar2  default hr_api.g_varchar2
  ,p_comp_lvl_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_multi_row_validate             in  boolean   default TRUE
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) ; -- := g_package||'update_PRTT_ENRT_RESULT';
  l_object_version_number ben_prtt_enrt_rslt_f.object_version_number%TYPE;
  l_effective_start_date ben_prtt_enrt_rslt_f.effective_start_date%TYPE;
  l_effective_end_date ben_prtt_enrt_rslt_f.effective_end_date%TYPE;

  --
  cursor c_old_rslt is
  select *
  from  ben_prtt_enrt_rslt_f
  where prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
    and prtt_enrt_rslt_stat_cd is null
    and p_effective_date between effective_start_date and effective_end_date ;
  l_old_rslt c_old_rslt%rowtype ;

 -- if there is entry for the same id
 -- dont create new value , the backout must restore
 -- origianl entry.
 cursor c_bckup_tbl_restore (
              c_pil_end_id number ,
              c_pen_id     number ,
              c_pil_id     number ,
              c_eff_strt_dt date  ,
              c_eff_end_dt  date  ,
              c_cvg_strt_dt date  ,
              c_cvg_thru_dt  date  ,
              c_pen_stat_cd varchar2 ) is
  select 'x'
    from  BEN_LE_CLSN_N_RSTR
    where bkup_tbl_id         =  c_pen_id
      and ((per_in_ler_id       =  c_pil_id
           and per_in_ler_ended_id =  c_pil_end_id)
           or (per_in_ler_ended_id =  c_pil_id     -- 8972844
               and per_in_ler_id = c_pil_end_id))  -- 7197868
      and BKUP_TBL_TYP_CD     =  'BEN_PRTT_ENRT_RSLT_F_CORR'
  union
    select 'x'
    from  BEN_LE_CLSN_N_RSTR
    where bkup_tbl_id         =  c_pen_id
      and per_in_ler_id       =  c_pil_id
      and BKUP_TBL_TYP_CD     =  'BEN_PRTT_ENRT_RSLT_F'
      and c_eff_strt_dt       =  EFFECTIVE_START_DATE
      and c_eff_end_dt        =  EFFECTIVE_END_DATE
      and c_cvg_strt_dt       =  ENRT_CVG_STRT_DT
      and c_cvg_thru_dt       =  ENRT_CVG_THRU_DT
      and nvl(c_pen_stat_cd,'-1') = nvl(PRTT_ENRT_RSLT_STAT_CD,'-1')
  ;

  l_env_rec     ben_env_object.g_global_env_rec_type;

  l_dummy   varchar2(1) ;

  --
begin
  --
  g_debug := hr_utility.debug_enabled;
  if g_debug then
     l_proc := g_package||'update_PRTT_ENRT_RESULT';
     hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  g_multi_rows_validate := p_multi_row_validate;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_PRTT_ENRT_RESULT;
  --
  if fnd_global.conc_request_id in (0,-1) and
     p_business_group_id <> hr_api.g_number then
    --
    --bug#3568529
    ben_env_object.get(p_rec => l_env_rec);
    if l_env_rec.benefit_action_id is null then
    --
      ben_env_object.init(p_business_group_id  => p_business_group_id,
                          p_effective_date     => p_effective_date,
                          p_thread_id          => 1,
                          p_chunk_size         => 1,
                          p_threads            => 1,
                          p_max_errors         => 1,
                          p_benefit_action_id  => null);
    end if;
    --
  end if;
  --
  if g_debug then
     hr_utility.set_location(l_proc, 20);
           hr_utility.set_location(' old per in ler id ' || l_old_rslt.per_in_ler_id, 99 );
     hr_utility.set_location(' new per in ler id ' || p_per_in_ler_id, 99 );
     hr_utility.set_location(' mode  ' || p_datetrack_mode, 99 );

  end if;
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  -- whne the mode is correction  and the old per_in_ler id is not the same of
  -- new per_in_ler_id and   effective state date is same of effecitve date
  -- then copy the result record to  backup table
  -- when the open LE then  gain dpnt ,then process the opne on the same dt of GD
  -- the result of GD are lost. because the per_in_ler id of open updated in gd

  --bug # 3086161
  if p_datetrack_mode = hr_api.g_correction  and p_per_in_ler_id <> hr_api.g_number  then
    open c_old_rslt ;
    fetch c_old_rslt into l_old_rslt ;
    close c_old_rslt ;
    if  l_old_rslt.per_in_ler_id <> p_per_in_ler_id
       and p_effective_date=l_old_rslt.effective_start_date  then

         hr_utility.set_location(' old per in ler id ' || l_old_rslt.per_in_ler_id, 99 );
         hr_utility.set_location(' new per in ler id ' || p_per_in_ler_id, 99 );
         hr_utility.set_location(' corrected result id   ' ||p_prtt_enrt_rslt_id , 99 );
         hr_utility.set_location(' mode  ' || p_datetrack_mode, 99 );
         hr_utility.set_location(' insertin the row of   ' || p_prtt_enrt_rslt_id , 99 );


         --- if the update called to reverse the stored  row from
         --- from backup table dont insert to backup table
         open  c_bckup_tbl_restore (
                           p_per_in_ler_id     ,
                           p_prtt_enrt_rslt_id     ,
                           l_old_rslt.per_in_ler_id,
                           l_old_rslt.EFFECTIVE_START_DATE,
                           l_old_rslt.EFFECTIVE_END_DATE  ,
                           l_old_rslt.ENRT_CVG_STRT_DT ,
                           l_old_rslt.ENRT_CVG_THRU_DT ,
                           l_old_rslt.PRTT_ENRT_RSLT_STAT_CD  ) ;
         fetch c_bckup_tbl_restore into l_dummy ;
         if c_bckup_tbl_restore%notfound then
         hr_utility.set_location(' backup row not found   ' || p_prtt_enrt_rslt_id , 99 );

             insert into BEN_LE_CLSN_N_RSTR (
                   BKUP_TBL_TYP_CD,
                   COMP_LVL_CD,
                   LCR_ATTRIBUTE16,
                   LCR_ATTRIBUTE17,
                   LCR_ATTRIBUTE18,
                   LCR_ATTRIBUTE19,
                   LCR_ATTRIBUTE20,
                   LCR_ATTRIBUTE21,
                   LCR_ATTRIBUTE22,
                   LCR_ATTRIBUTE23,
                   LCR_ATTRIBUTE24,
                   LCR_ATTRIBUTE25,
                   LCR_ATTRIBUTE26,
                   LCR_ATTRIBUTE27,
                   LCR_ATTRIBUTE28,
                   LCR_ATTRIBUTE29,
                   LCR_ATTRIBUTE30,
                   LAST_UPDATE_DATE,
                   LAST_UPDATED_BY,
                   LAST_UPDATE_LOGIN,
                   CREATED_BY,
                   CREATION_DATE,
                   REQUEST_ID,
                   PROGRAM_APPLICATION_ID,
                   PROGRAM_ID,
                   PROGRAM_UPDATE_DATE,
                   OBJECT_VERSION_NUMBER,
                   BKUP_TBL_ID, -- PRTT_ENRT_RSLT_ID,
                   EFFECTIVE_START_DATE,
                   EFFECTIVE_END_DATE,
                   ENRT_CVG_STRT_DT,
                   ENRT_CVG_THRU_DT,
                   SSPNDD_FLAG,
                   PRTT_IS_CVRD_FLAG,
                   BNFT_AMT,
                   BNFT_NNMNTRY_UOM,
                   BNFT_TYP_CD,
                   UOM,
                   ORGNL_ENRT_DT,
                   ENRT_MTHD_CD,
                   ENRT_OVRIDN_FLAG,
                   ENRT_OVRID_RSN_CD,
                   ERLST_DEENRT_DT,
                   ENRT_OVRID_THRU_DT,
                   NO_LNGR_ELIG_FLAG,
                   BNFT_ORDR_NUM,
                   PERSON_ID,
                   ASSIGNMENT_ID,
                   PGM_ID,
                   PRTT_ENRT_RSLT_STAT_CD,
                   PL_ID,
                   OIPL_ID,
                   PTIP_ID,
                   PL_TYP_ID,
                   LER_ID,
                   PER_IN_LER_ID,
                   RPLCS_SSPNDD_RSLT_ID,
                   BUSINESS_GROUP_ID,
                   LCR_ATTRIBUTE_CATEGORY,
                   LCR_ATTRIBUTE1,
                   LCR_ATTRIBUTE2,
                   LCR_ATTRIBUTE3,
                   LCR_ATTRIBUTE4,
                   LCR_ATTRIBUTE5,
                   LCR_ATTRIBUTE6,
                   LCR_ATTRIBUTE7,
                   LCR_ATTRIBUTE8,
                   LCR_ATTRIBUTE9,
                   LCR_ATTRIBUTE10,
                   LCR_ATTRIBUTE11,
                   LCR_ATTRIBUTE12,
                   LCR_ATTRIBUTE13,
                   LCR_ATTRIBUTE14,
                   LCR_ATTRIBUTE15 ,
                   PER_IN_LER_ENDED_ID,
                   PL_ORDR_NUM,
                   PLIP_ORDR_NUM,
                   PTIP_ORDR_NUM,
                   OIPL_ORDR_NUM)
                 values (
                  'BEN_PRTT_ENRT_RSLT_F_CORR',
                  l_old_rslt.COMP_LVL_CD,
                  l_old_rslt.PEN_ATTRIBUTE16,
                  l_old_rslt.PEN_ATTRIBUTE17,
                  l_old_rslt.PEN_ATTRIBUTE18,
                  l_old_rslt.PEN_ATTRIBUTE19,
                  l_old_rslt.PEN_ATTRIBUTE20,
                  l_old_rslt.PEN_ATTRIBUTE21,
                  l_old_rslt.PEN_ATTRIBUTE22,
                  l_old_rslt.PEN_ATTRIBUTE23,
                  l_old_rslt.PEN_ATTRIBUTE24,
                  l_old_rslt.PEN_ATTRIBUTE25,
                  l_old_rslt.PEN_ATTRIBUTE26,
                  l_old_rslt.PEN_ATTRIBUTE27,
                  l_old_rslt.PEN_ATTRIBUTE28,
                  l_old_rslt.PEN_ATTRIBUTE29,
                  l_old_rslt.PEN_ATTRIBUTE30,
                  l_old_rslt.LAST_UPDATE_DATE,
                  l_old_rslt.LAST_UPDATED_BY,
                  l_old_rslt.LAST_UPDATE_LOGIN,
                  l_old_rslt.CREATED_BY,
                  l_old_rslt.CREATION_DATE,
                  l_old_rslt.REQUEST_ID,
                  l_old_rslt.PROGRAM_APPLICATION_ID,
                  l_old_rslt.PROGRAM_ID,
                  l_old_rslt.PROGRAM_UPDATE_DATE,
                  l_old_rslt.OBJECT_VERSION_NUMBER,
                  l_old_rslt.PRTT_ENRT_RSLT_ID,
                  l_old_rslt.EFFECTIVE_START_DATE,
                  l_old_rslt.EFFECTIVE_END_DATE,
                  l_old_rslt.ENRT_CVG_STRT_DT,
                  l_old_rslt.ENRT_CVG_THRU_DT,
                  l_old_rslt.SSPNDD_FLAG,
                  l_old_rslt.PRTT_IS_CVRD_FLAG,
                  l_old_rslt.BNFT_AMT,
                  l_old_rslt.BNFT_NNMNTRY_UOM,
                  l_old_rslt.BNFT_TYP_CD,
                  l_old_rslt.UOM,
                  l_old_rslt.ORGNL_ENRT_DT,
                  l_old_rslt.ENRT_MTHD_CD,
                  l_old_rslt.ENRT_OVRIDN_FLAG,
                  l_old_rslt.ENRT_OVRID_RSN_CD,
                  l_old_rslt.ERLST_DEENRT_DT,
                  l_old_rslt.ENRT_OVRID_THRU_DT,
                  l_old_rslt.NO_LNGR_ELIG_FLAG,
                  l_old_rslt.BNFT_ORDR_NUM,
                  l_old_rslt.PERSON_ID,
                  l_old_rslt.ASSIGNMENT_ID,
                  l_old_rslt.PGM_ID,
                  l_old_rslt.PRTT_ENRT_RSLT_STAT_CD,
                  l_old_rslt.PL_ID,
                  l_old_rslt.OIPL_ID,
                  l_old_rslt.PTIP_ID,
                  l_old_rslt.PL_TYP_ID,
                  l_old_rslt.LER_ID,
                  l_old_rslt.PER_IN_LER_ID,
                  l_old_rslt.RPLCS_SSPNDD_RSLT_ID,
                  l_old_rslt.BUSINESS_GROUP_ID,
                  l_old_rslt.PEN_ATTRIBUTE_CATEGORY,
                  l_old_rslt.PEN_ATTRIBUTE1,
                  l_old_rslt.PEN_ATTRIBUTE2,
                  l_old_rslt.PEN_ATTRIBUTE3,
                  l_old_rslt.PEN_ATTRIBUTE4,
                  l_old_rslt.PEN_ATTRIBUTE5,
                  l_old_rslt.PEN_ATTRIBUTE6,
                  l_old_rslt.PEN_ATTRIBUTE7,
                  l_old_rslt.PEN_ATTRIBUTE8,
                  l_old_rslt.PEN_ATTRIBUTE9,
                  l_old_rslt.PEN_ATTRIBUTE10,
                  l_old_rslt.PEN_ATTRIBUTE11,
                  l_old_rslt.PEN_ATTRIBUTE12,
                  l_old_rslt.PEN_ATTRIBUTE13,
                  l_old_rslt.PEN_ATTRIBUTE14,
                  l_old_rslt.PEN_ATTRIBUTE15,
                  p_per_in_ler_id ,
                  l_old_rslt.PL_ORDR_NUM,
                  l_old_rslt.PLIP_ORDR_NUM,
                  l_old_rslt.PTIP_ORDR_NUM,
                  l_old_rslt.OIPL_ORDR_NUM
              );
        end if;
        close c_bckup_tbl_restore ;


    end if ;
    --eof bug # 3086161



  end if ;

  begin
    --
    -- Start of API User Hook for the before hook of update_PRTT_ENRT_RESULT
    --
    ben_PRTT_ENRT_RESULT_bk2.update_PRTT_ENRT_RESULT_b
      (
       p_prtt_enrt_rslt_id              =>  p_prtt_enrt_rslt_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_oipl_id                        =>  p_oipl_id
      ,p_person_id                      =>  p_person_id
      ,p_assignment_id                  =>  p_assignment_id
      ,p_pgm_id                         =>  p_pgm_id
      ,p_pl_id                          =>  p_pl_id
      ,p_rplcs_sspndd_rslt_id           =>  p_rplcs_sspndd_rslt_id
      ,p_ptip_id                        =>  p_ptip_id
      ,p_pl_typ_id                      =>  p_pl_typ_id
      ,p_ler_id                         =>  p_ler_id
      ,p_sspndd_flag                    =>  p_sspndd_flag
      ,p_prtt_is_cvrd_flag              =>  p_prtt_is_cvrd_flag
      ,p_bnft_amt                       =>  p_bnft_amt
      ,p_uom                            =>  p_uom
      ,p_orgnl_enrt_dt                  =>  p_orgnl_enrt_dt
      ,p_enrt_mthd_cd                   =>  p_enrt_mthd_cd
      ,p_no_lngr_elig_flag              =>  p_no_lngr_elig_flag
      ,p_enrt_ovridn_flag               =>  p_enrt_ovridn_flag
      ,p_enrt_ovrid_rsn_cd              =>  p_enrt_ovrid_rsn_cd
      ,p_erlst_deenrt_dt                =>  p_erlst_deenrt_dt
      ,p_enrt_cvg_strt_dt               =>  p_enrt_cvg_strt_dt
      ,p_enrt_cvg_thru_dt               =>  p_enrt_cvg_thru_dt
      ,p_enrt_ovrid_thru_dt             =>  p_enrt_ovrid_thru_dt
      ,p_pl_ordr_num                    =>  p_pl_ordr_num
      ,p_plip_ordr_num                  =>  p_plip_ordr_num
      ,p_ptip_ordr_num                  =>  p_ptip_ordr_num
      ,p_oipl_ordr_num                  =>  p_oipl_ordr_num
      ,p_pen_attribute_category         =>  p_pen_attribute_category
      ,p_pen_attribute1                 =>  p_pen_attribute1
      ,p_pen_attribute2                 =>  p_pen_attribute2
      ,p_pen_attribute3                 =>  p_pen_attribute3
      ,p_pen_attribute4                 =>  p_pen_attribute4
      ,p_pen_attribute5                 =>  p_pen_attribute5
      ,p_pen_attribute6                 =>  p_pen_attribute6
      ,p_pen_attribute7                 =>  p_pen_attribute7
      ,p_pen_attribute8                 =>  p_pen_attribute8
      ,p_pen_attribute9                 =>  p_pen_attribute9
      ,p_pen_attribute10                =>  p_pen_attribute10
      ,p_pen_attribute11                =>  p_pen_attribute11
      ,p_pen_attribute12                =>  p_pen_attribute12
      ,p_pen_attribute13                =>  p_pen_attribute13
      ,p_pen_attribute14                =>  p_pen_attribute14
      ,p_pen_attribute15                =>  p_pen_attribute15
      ,p_pen_attribute16                =>  p_pen_attribute16
      ,p_pen_attribute17                =>  p_pen_attribute17
      ,p_pen_attribute18                =>  p_pen_attribute18
      ,p_pen_attribute19                =>  p_pen_attribute19
      ,p_pen_attribute20                =>  p_pen_attribute20
      ,p_pen_attribute21                =>  p_pen_attribute21
      ,p_pen_attribute22                =>  p_pen_attribute22
      ,p_pen_attribute23                =>  p_pen_attribute23
      ,p_pen_attribute24                =>  p_pen_attribute24
      ,p_pen_attribute25                =>  p_pen_attribute25
      ,p_pen_attribute26                =>  p_pen_attribute26
      ,p_pen_attribute27                =>  p_pen_attribute27
      ,p_pen_attribute28                =>  p_pen_attribute28
      ,p_pen_attribute29                =>  p_pen_attribute29
      ,p_pen_attribute30                =>  p_pen_attribute30
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_object_version_number          =>  p_object_version_number
      ,p_per_in_ler_id                  =>  p_per_in_ler_id
      ,p_bnft_typ_cd                    =>  p_bnft_typ_cd
      ,p_bnft_ordr_num                  =>  p_bnft_ordr_num
      ,p_prtt_enrt_rslt_stat_cd         =>  p_prtt_enrt_rslt_stat_cd
      ,p_bnft_nnmntry_uom               =>  p_bnft_nnmntry_uom
      ,p_comp_lvl_cd                    =>  p_comp_lvl_cd
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_datetrack_mode                 =>  p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PRTT_ENRT_RESULT'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_PRTT_ENRT_RESULT
    --
  end;
  --
   hr_utility.set_location ( ' eff date ' || p_effective_date, 99 );
   hr_utility.set_location ( ' OVN ' || l_object_version_number, 99 );
   ben_pen_upd.upd
    (p_prtt_enrt_rslt_id             => p_prtt_enrt_rslt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_business_group_id             => p_business_group_id
    ,p_oipl_id                       => p_oipl_id
    ,p_person_id                     => p_person_id
    ,p_assignment_id                 => p_assignment_id
    ,p_pgm_id                        => p_pgm_id
    ,p_pl_id                         => p_pl_id
    ,p_rplcs_sspndd_rslt_id          => p_rplcs_sspndd_rslt_id
    ,p_ptip_id                       => p_ptip_id
    ,p_pl_typ_id                     => p_pl_typ_id
    ,p_ler_id                        => p_ler_id
    ,p_sspndd_flag                   => p_sspndd_flag
    ,p_prtt_is_cvrd_flag             => p_prtt_is_cvrd_flag
    ,p_bnft_amt                      => p_bnft_amt
    ,p_uom                           => p_uom
    ,p_orgnl_enrt_dt                 => p_orgnl_enrt_dt
    ,p_enrt_mthd_cd                  => p_enrt_mthd_cd
    ,p_no_lngr_elig_flag             => p_no_lngr_elig_flag
    ,p_enrt_ovridn_flag              => p_enrt_ovridn_flag
    ,p_enrt_ovrid_rsn_cd             => p_enrt_ovrid_rsn_cd
    ,p_erlst_deenrt_dt               => p_erlst_deenrt_dt
    ,p_enrt_cvg_strt_dt              => p_enrt_cvg_strt_dt
    ,p_enrt_cvg_thru_dt              => p_enrt_cvg_thru_dt
    ,p_enrt_ovrid_thru_dt            => p_enrt_ovrid_thru_dt
    ,p_pl_ordr_num                   => p_pl_ordr_num
    ,p_plip_ordr_num                 => p_plip_ordr_num
    ,p_ptip_ordr_num                 => p_ptip_ordr_num
    ,p_oipl_ordr_num                 => p_oipl_ordr_num
    ,p_pen_attribute_category        => p_pen_attribute_category
    ,p_pen_attribute1                => p_pen_attribute1
    ,p_pen_attribute2                => p_pen_attribute2
    ,p_pen_attribute3                => p_pen_attribute3
    ,p_pen_attribute4                => p_pen_attribute4
    ,p_pen_attribute5                => p_pen_attribute5
    ,p_pen_attribute6                => p_pen_attribute6
    ,p_pen_attribute7                => p_pen_attribute7
    ,p_pen_attribute8                => p_pen_attribute8
    ,p_pen_attribute9                => p_pen_attribute9
    ,p_pen_attribute10               => p_pen_attribute10
    ,p_pen_attribute11               => p_pen_attribute11
    ,p_pen_attribute12               => p_pen_attribute12
    ,p_pen_attribute13               => p_pen_attribute13
    ,p_pen_attribute14               => p_pen_attribute14
    ,p_pen_attribute15               => p_pen_attribute15
    ,p_pen_attribute16               => p_pen_attribute16
    ,p_pen_attribute17               => p_pen_attribute17
    ,p_pen_attribute18               => p_pen_attribute18
    ,p_pen_attribute19               => p_pen_attribute19
    ,p_pen_attribute20               => p_pen_attribute20
    ,p_pen_attribute21               => p_pen_attribute21
    ,p_pen_attribute22               => p_pen_attribute22
    ,p_pen_attribute23               => p_pen_attribute23
    ,p_pen_attribute24               => p_pen_attribute24
    ,p_pen_attribute25               => p_pen_attribute25
    ,p_pen_attribute26               => p_pen_attribute26
    ,p_pen_attribute27               => p_pen_attribute27
    ,p_pen_attribute28               => p_pen_attribute28
    ,p_pen_attribute29               => p_pen_attribute29
    ,p_pen_attribute30               => p_pen_attribute30
    ,p_request_id                    => p_request_id
    ,p_program_application_id        => p_program_application_id
    ,p_program_id                    => p_program_id
    ,p_program_update_date           => p_program_update_date
    ,p_object_version_number         => l_object_version_number
    ,p_per_in_ler_id                 => p_per_in_ler_id
    ,p_bnft_typ_cd                   => p_bnft_typ_cd
    ,p_bnft_ordr_num                 => p_bnft_ordr_num
    ,p_prtt_enrt_rslt_stat_cd        => p_prtt_enrt_rslt_stat_cd
    ,p_bnft_nnmntry_uom              => p_bnft_nnmntry_uom
    ,p_comp_lvl_cd                   => p_comp_lvl_cd
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
--
--
  begin
    --
    -- Start of API User Hook for the after hook of update_PRTT_ENRT_RESULT
    --
    ben_PRTT_ENRT_RESULT_bk2.update_PRTT_ENRT_RESULT_a
      (
       p_prtt_enrt_rslt_id              =>  p_prtt_enrt_rslt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_business_group_id              =>  p_business_group_id
      ,p_oipl_id                        =>  p_oipl_id
      ,p_person_id                      =>  p_person_id
      ,p_assignment_id                  =>  p_assignment_id
      ,p_pgm_id                         =>  p_pgm_id
      ,p_pl_id                          =>  p_pl_id
      ,p_rplcs_sspndd_rslt_id           =>  p_rplcs_sspndd_rslt_id
      ,p_ptip_id                        =>  p_ptip_id
      ,p_pl_typ_id                      =>  p_pl_typ_id
      ,p_ler_id                         =>  p_ler_id
      ,p_sspndd_flag                    =>  p_sspndd_flag
      ,p_prtt_is_cvrd_flag              =>  p_prtt_is_cvrd_flag
      ,p_bnft_amt                       =>  p_bnft_amt
      ,p_uom                            =>  p_uom
      ,p_orgnl_enrt_dt                  =>  p_orgnl_enrt_dt
      ,p_enrt_mthd_cd                   =>  p_enrt_mthd_cd
      ,p_no_lngr_elig_flag              =>  p_no_lngr_elig_flag
      ,p_enrt_ovridn_flag               =>  p_enrt_ovridn_flag
      ,p_enrt_ovrid_rsn_cd              =>  p_enrt_ovrid_rsn_cd
      ,p_erlst_deenrt_dt                =>  p_erlst_deenrt_dt
      ,p_enrt_cvg_strt_dt               =>  p_enrt_cvg_strt_dt
      ,p_enrt_cvg_thru_dt               =>  p_enrt_cvg_thru_dt
      ,p_enrt_ovrid_thru_dt             =>  p_enrt_ovrid_thru_dt
      ,p_pl_ordr_num                    =>  p_pl_ordr_num
      ,p_plip_ordr_num                  =>  p_plip_ordr_num
      ,p_ptip_ordr_num                  =>  p_ptip_ordr_num
      ,p_oipl_ordr_num                  =>  p_oipl_ordr_num
      ,p_pen_attribute_category         =>  p_pen_attribute_category
      ,p_pen_attribute1                 =>  p_pen_attribute1
      ,p_pen_attribute2                 =>  p_pen_attribute2
      ,p_pen_attribute3                 =>  p_pen_attribute3
      ,p_pen_attribute4                 =>  p_pen_attribute4
      ,p_pen_attribute5                 =>  p_pen_attribute5
      ,p_pen_attribute6                 =>  p_pen_attribute6
      ,p_pen_attribute7                 =>  p_pen_attribute7
      ,p_pen_attribute8                 =>  p_pen_attribute8
      ,p_pen_attribute9                 =>  p_pen_attribute9
      ,p_pen_attribute10                =>  p_pen_attribute10
      ,p_pen_attribute11                =>  p_pen_attribute11
      ,p_pen_attribute12                =>  p_pen_attribute12
      ,p_pen_attribute13                =>  p_pen_attribute13
      ,p_pen_attribute14                =>  p_pen_attribute14
      ,p_pen_attribute15                =>  p_pen_attribute15
      ,p_pen_attribute16                =>  p_pen_attribute16
      ,p_pen_attribute17                =>  p_pen_attribute17
      ,p_pen_attribute18                =>  p_pen_attribute18
      ,p_pen_attribute19                =>  p_pen_attribute19
      ,p_pen_attribute20                =>  p_pen_attribute20
      ,p_pen_attribute21                =>  p_pen_attribute21
      ,p_pen_attribute22                =>  p_pen_attribute22
      ,p_pen_attribute23                =>  p_pen_attribute23
      ,p_pen_attribute24                =>  p_pen_attribute24
      ,p_pen_attribute25                =>  p_pen_attribute25
      ,p_pen_attribute26                =>  p_pen_attribute26
      ,p_pen_attribute27                =>  p_pen_attribute27
      ,p_pen_attribute28                =>  p_pen_attribute28
      ,p_pen_attribute29                =>  p_pen_attribute29
      ,p_pen_attribute30                =>  p_pen_attribute30
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_object_version_number          =>  l_object_version_number
      ,p_per_in_ler_id                  =>  p_per_in_ler_id
      ,p_bnft_typ_cd                    =>  p_bnft_typ_cd
      ,p_bnft_ordr_num                  =>  p_bnft_ordr_num
      ,p_prtt_enrt_rslt_stat_cd         =>  p_prtt_enrt_rslt_stat_cd
      ,p_bnft_nnmntry_uom               =>  p_bnft_nnmntry_uom
      ,p_comp_lvl_cd                    =>  p_comp_lvl_cd
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_datetrack_mode                 =>  p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PRTT_ENRT_RESULT'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_PRTT_ENRT_RESULT
    --
  end;
  --
  if g_debug then
     hr_utility.set_location(l_proc, 60);
  end if;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_object_version_number := l_object_version_number;
  p_effective_start_date := l_effective_start_date;
  p_effective_end_date := l_effective_end_date;
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 70);
  end if;
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_PRTT_ENRT_RESULT;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    if g_debug then
      hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO update_PRTT_ENRT_RESULT;
    p_effective_start_date := null; --nocopy change
    p_effective_end_date := null; --nocopy change
    raise;
    --
end update_PRTT_ENRT_RESULT;
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_PRTT_ENRT_RESULT >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_PRTT_ENRT_RESULT
  (p_validate                       in  boolean  default false
  ,p_prtt_enrt_rslt_id              in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_multi_row_validate             in boolean    default TRUE
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) ; -- := g_package||'delete_PRTT_ENRT_RESULT';
  l_object_version_number ben_prtt_enrt_rslt_f.object_version_number%TYPE;
  l_effective_start_date ben_prtt_enrt_rslt_f.effective_start_date%TYPE;
  l_effective_end_date ben_prtt_enrt_rslt_f.effective_end_date%TYPE;
  --
begin
  --
  g_debug := hr_utility.debug_enabled;
  if g_debug then
     l_proc := g_package||'delete_PRTT_ENRT_RESULT';
     hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  g_multi_rows_validate := p_multi_row_validate;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_PRTT_ENRT_RESULT;
  --
  if g_debug then
     hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  --
  begin
    --
    -- Start of API User Hook for the before hook of delete_PRTT_ENRT_RESULT
    --
    ben_PRTT_ENRT_RESULT_bk3.delete_PRTT_ENRT_RESULT_b
      (
       p_prtt_enrt_rslt_id              =>  p_prtt_enrt_rslt_id
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PRTT_ENRT_RESULT'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_PRTT_ENRT_RESULT
    --
  end;
  --
  ben_pen_del.del
    (
     p_prtt_enrt_rslt_id             => p_prtt_enrt_rslt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_PRTT_ENRT_RESULT
    --
    ben_PRTT_ENRT_RESULT_bk3.delete_PRTT_ENRT_RESULT_a
      (
       p_prtt_enrt_rslt_id              =>  p_prtt_enrt_rslt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      ,p_datetrack_mode                 => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PRTT_ENRT_RESULT'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_PRTT_ENRT_RESULT
    --
  end;
  --
  if g_debug then
     hr_utility.set_location(l_proc, 60);
  end if;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  p_effective_start_date  := l_effective_start_date;
  p_effective_end_date    := l_effective_end_date;
  p_object_version_number := l_object_version_number;

  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 70);
  end if;
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_PRTT_ENRT_RESULT;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_effective_start_date := null;
    p_effective_end_date := null;
    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_PRTT_ENRT_RESULT;
    p_effective_start_date := null; --nocopy change
    p_effective_end_date := null; --nocopy change
    raise;
    --
end delete_PRTT_ENRT_RESULT;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------< calc_dpnt_cvg_end_date >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure calc_dpnt_cvg_dt
         (p_calc_end_dt            in     boolean   default FALSE
         ,P_calc_strt_dt           in     boolean   default FALSE
         ,P_per_in_ler_id          in     number    default NULL
         ,p_person_id              in     number    default NULL
         ,p_pgm_id                 in     number    default NULL
         ,p_pl_id                  in     number    default NULL
         ,p_oipl_id                in     number    default NULL
         ,p_ptip_id                in     number    default NULL
         ,p_ler_id                 in     number    default NULL
         ,p_elig_per_elctbl_chc_id in     number    default NULL
         ,p_business_group_id      in     number
         ,p_effective_date         in     date
         ,p_enrt_cvg_end_dt        in     date          default NULL
         ,p_returned_strt_dt          out nocopy date
         ,p_returned_end_dt           out nocopy date
         ) is
  l_proc         varchar2(72); --  := g_package||'calc_dpnt_cvg_dt';
  l_enrt_cvg_end_dt   date;
  l_cvg_strt_dt  date;
  l_cvg_strt_cd  varchar2(30);
  l_cvg_strt_rl  number(15);
  l_cvg_end_cd   varchar2(30);
  l_cvg_end_rl   number(15);
  l_step         integer;
begin
    g_debug := hr_utility.debug_enabled;
    if g_debug then
       l_proc :=  g_package||'calc_dpnt_cvg_dt';
       hr_utility.set_location(' Entering:'||l_proc,10);
    end if;
    l_step := 10;
    if (p_elig_per_elctbl_chc_id is not NULL) then
        determine_dpnt_cvg_dt_cd
                (p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id
                ,p_effective_date         => p_effective_date
                ,p_business_group_id      => p_business_group_id
                ,p_cvg_strt_cd            => l_cvg_strt_cd
                ,p_cvg_strt_rl            => l_cvg_strt_rl
                ,p_cvg_end_cd             => l_cvg_end_cd
                ,p_cvg_end_rl             => l_cvg_end_rl
                );
        if g_debug then
           hr_utility.set_location('dpnt_end_cd' || l_cvg_end_cd,15);
           hr_utility.set_location('dpnt_strt_cd'|| l_cvg_strt_cd,15);
        end if;
        if (p_calc_strt_dt and l_cvg_strt_cd is not NULL) then
            l_step := 20;
            ben_determine_date.main
                   (P_DATE_CD                => l_cvg_strt_cd
                   ,p_formula_id             => l_cvg_strt_rl
                   ,P_ELIG_PER_ELCTBL_CHC_ID => p_elig_per_elctbl_chc_id
                   ,P_BUSINESS_GROUP_ID      => p_business_group_id
                   ,P_EFFECTIVE_DATE         => p_effective_date
                   ,P_RETURNED_DATE          => l_cvg_strt_dt
           );
        else
            l_cvg_strt_dt := NULL;
        end if;
        if (p_calc_end_dt and l_cvg_end_cd is not NULL) then
            l_step := 30;
            ben_determine_date.main
                   (P_DATE_CD                => l_cvg_end_cd
                   ,p_formula_id             => l_cvg_end_rl
                   ,p_enrt_cvg_end_dt        => p_enrt_cvg_end_dt
                   ,P_ELIG_PER_ELCTBL_CHC_ID => p_elig_per_elctbl_chc_id
                   ,P_BUSINESS_GROUP_ID      => p_business_group_id
                   ,P_EFFECTIVE_DATE         => p_effective_date
                   ,P_RETURNED_DATE          => l_enrt_cvg_end_dt
           );
        else
            l_enrt_cvg_end_dt := NULL;
        end if;
    else
        l_step := 40;
        determine_dpnt_cvg_dt_cd
              (p_pgm_id                 => p_pgm_id
              ,P_ptip_id                => p_ptip_id
              ,p_pl_id                  => p_pl_id
              ,p_ler_id                 => p_ler_id
              ,p_effective_date         => p_effective_date
              ,p_business_group_id      => p_business_group_id
              ,p_cvg_strt_cd            => l_cvg_strt_cd
              ,p_cvg_strt_rl            => l_cvg_strt_rl
              ,p_cvg_end_cd             => l_cvg_end_cd
              ,p_cvg_end_rl             => l_cvg_end_rl
              );
        if (p_calc_strt_dt and l_cvg_strt_cd is not null) then
            l_step := 50;
            ben_determine_date.main
                (P_DATE_CD                => l_cvg_strt_cd
                ,p_formula_id             => l_cvg_strt_rl
                ,P_PER_IN_LER_ID          => p_per_in_ler_id
                ,P_PERSON_ID              => p_person_id
                ,P_PGM_ID                 => p_pgm_id
                ,P_PL_ID                  => p_pl_id
                ,P_OIPL_ID                => p_oipl_id
                ,P_BUSINESS_GROUP_ID      => p_business_group_id
                ,P_EFFECTIVE_DATE         => p_effective_date
                ,P_RETURNED_DATE          => l_cvg_strt_dt
            );
        else
            l_cvg_strt_dt := NULL;
        end if;
        if (p_calc_end_dt and l_cvg_end_cd is not NULL) then
            l_step := 60;
            ben_determine_date.main
                (P_DATE_CD                => l_cvg_end_cd
                ,p_formula_id             => l_cvg_end_rl
                ,p_enrt_cvg_end_dt        => p_enrt_cvg_end_dt
                ,P_PER_IN_LER_ID          => p_per_in_ler_id
                ,P_PERSON_ID              => p_person_id
                ,P_PGM_ID                 => p_pgm_id
                ,P_PL_ID                  => p_pl_id
                ,P_OIPL_ID                => p_oipl_id
                ,P_BUSINESS_GROUP_ID      => p_business_group_id
                ,P_EFFECTIVE_DATE         => p_effective_date
                ,P_RETURNED_DATE          => l_enrt_cvg_end_dt
                );
        else
            l_enrt_cvg_end_dt := NULL;
        end if;
    end if;
    l_step := 70;
    p_returned_end_dt  := l_enrt_cvg_end_dt;
    p_returned_strt_dt := l_cvg_strt_dt;
    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 70);
    end if;
exception
    when others then
        rpt_error(p_proc => l_proc, p_step => l_step);
        raise;
end calc_dpnt_cvg_dt;
--
-- ----------------------------------------------------------------------------
-- |---------------------< determine_dpnt_cvg_dt_cd >------------------------|
-- ----------------------------------------------------------------------------
--
procedure determine_dpnt_cvg_dt_cd
        (p_elig_per_elctbl_chc_id in     number default NULL
        ,p_pgm_id                 in     number default NULL
        ,p_pl_id                  in     number default NULL
        ,p_ptip_id                in     number default NULL
        ,p_ler_id                 in     number default NULL
        ,p_effective_date         in     date
        ,p_business_group_id      in     number
        ,p_cvg_strt_cd               out nocopy varchar2
        ,p_cvg_strt_rl               out nocopy number
        ,p_cvg_end_cd                out nocopy varchar2
        ,p_cvg_end_rl                out nocopy number
        ) is
  l_proc        varchar2(80); --  := 'determine_dpnt_cvg_dt_cd';
  l_level       varchar2(10) :=NULL;
  l_cvg_strt_cd varchar2(30);
  l_cvg_strt_rl number(15);
  l_cvg_end_cd  varchar2(30);
  l_cvg_end_rl  number(15);
  l_step        integer;
  --
  l_pl_rec         ben_cobj_cache.g_pl_inst_row;
  l_pgm_rec        ben_cobj_cache.g_pgm_inst_row;
  l_ptip_rec       ben_cobj_cache.g_ptip_inst_row;
  --
  cursor c_epe is
      select epe.elig_per_elctbl_chc_id
             ,epe.pgm_id
             ,epe.ptip_id
             ,epe.pl_id
             ,pil.ler_id
        from ben_elig_per_elctbl_chc epe
             ,ben_per_in_ler pil
       where elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id
         and epe.business_group_id = p_business_group_id
         and epe.per_in_ler_id = pil.per_in_ler_id
         and pil.per_in_ler_stat_cd not in ('VOIDD', 'BCKDT')
             ;
  l_epe  c_epe%rowtype;
  --
  cursor c_ler_chg_dep(p_level varchar2) is
      select chg.cvg_eff_strt_cd
             ,chg.cvg_eff_end_cd
             ,chg.cvg_eff_strt_rl
             ,chg.cvg_eff_end_rl
             ,chg.ler_chg_dpnt_cvg_cd
             ,chg.ler_chg_dpnt_cvg_rl
        from ben_ler_chg_dpnt_cvg_f chg
       where chg.ler_id = l_epe.ler_id
         and chg.business_group_id = p_business_group_id
         and decode(p_level
                   ,'PL',l_epe.pl_id
                   ,'PTIP', l_epe.ptip_id
                   ,'PGM', l_epe.pgm_id) = decode(p_level
                                                 ,'PL',chg.pl_id
                                                 ,'PTIP', chg.ptip_id
                                                 ,'PGM', chg.pgm_id)
         and p_effective_date between
                 chg.effective_start_date and chg.effective_end_date
             ;
  l_chg  c_ler_chg_dep%rowtype;
  l_env_rec     ben_env_object.g_global_env_rec_type;
--
begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_proc := 'determine_dpnt_cvg_dt_cd';
    hr_utility.set_location ('Entering '||l_proc,10);
  end if;
l_step := 10;
  if fnd_global.conc_request_id in (0,-1) then
    --
    --bug#3568529
    ben_env_object.get(p_rec => l_env_rec);
    if l_env_rec.benefit_action_id is null then
    --
      ben_env_object.init(p_business_group_id  => p_business_group_id,
                        p_effective_date     => p_effective_date,
                        p_thread_id          => 1,
                        p_chunk_size         => 1,
                        p_threads            => 1,
                        p_max_errors         => 1,
                        p_benefit_action_id  => null);
    end if;
    --
  end if;
    if p_elig_per_elctbl_chc_id is not null then
        open c_epe;
        fetch c_epe into l_epe;
        if c_epe%notfound then
            close c_epe;
            rpt_error(p_proc => l_proc, p_step => l_step);
            if g_debug then
               hr_utility.set_location('BEN_91457_ELCTBL_CHC_NOT_FOUND id:'||
                to_char(p_elig_per_elctbl_chc_id), 15);
            end if;
            fnd_message.set_name('BEN','BEN_91457_ELCTBL_CHC_NOT_FOUND');
            fnd_message.set_token('ID', to_char(p_elig_per_elctbl_chc_id) );
            fnd_message.set_token('PROC','2:'||l_proc );
            fnd_message.raise_error;
        end if;
        close c_epe;
    else
        l_epe.elig_per_elctbl_chc_id := NULL;
        l_epe.pgm_id  := p_pgm_id;
        l_epe.pl_id   := p_pl_id;
        l_epe.ptip_id := p_ptip_id;
        l_epe.ler_id  := p_ler_id;
    end if;
    if g_debug then
       hr_utility.set_location ('Determining designation level '||l_proc,30);
    end if;
l_step := 20;
    --
    -- If program Id is specified, then use program Id to retreive dependent
    -- designation level.  If not, use plan as dependent designation level.
    --
    if (l_epe.pl_id is not null ) then
      ben_cobj_cache.get_pl_dets
         (p_business_group_id => p_business_group_id
         ,p_effective_date    => p_effective_date
         ,p_pl_id             => l_epe.pl_id
         ,p_inst_row          => l_pl_rec);
    end if;

    if ( (l_epe.pgm_id is not null)) then
      ben_cobj_cache.get_pgm_dets
       (p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_pgm_id            => l_epe.pgm_id
       ,p_inst_row          => l_pgm_rec);
        -- 3657077 : Added the below IF-condition.
        -- check if DPNT_DSGN_CD is specified at plan-level. If it is specified
        -- then dependent designation level is PL. This overrides all PGM and PTIP levels
      if (l_pl_rec.dpnt_dsgn_cd IS NULL) then
        l_level := l_pgm_rec.dpnt_dsgn_lvl_cd;
      else
        l_level := 'PL';
      end if;
      if l_level not in ('PL', 'PGM', 'PTIP') then
          rpt_error(p_proc => l_proc, p_step => l_step);
          fnd_message.set_name('BEN', 'BEN_91712_INVALID_DP_DSGN_LVL');
          fnd_message.set_token('LVL', l_level);
      end if;
    else
        l_level := 'PL';
    end if;

    if (l_epe.ptip_id is not null and l_level = 'PTIP') then
      ben_cobj_cache.get_ptip_dets
         (p_business_group_id => p_business_group_id
         ,p_effective_date    => p_effective_date
         ,p_ptip_id           => l_epe.ptip_id
         ,p_inst_row          => l_ptip_rec);
    end if;
l_step := 30;
    open c_ler_chg_dep(l_level);
    fetch c_ler_chg_dep into l_chg;
    if c_ler_chg_dep%notfound then
        --
        -- If there are no records, continue to get start date code and
        -- end date code from program or Plan.
        --
        l_cvg_strt_cd := NULL;
        l_cvg_strt_rl := NULL;
        l_cvg_end_cd  := NULL;
        l_cvg_end_rl  := NULL;
    else
        l_cvg_strt_cd := l_chg.cvg_eff_strt_cd;
        l_cvg_strt_rl := l_chg.cvg_eff_strt_rl;
        l_cvg_end_cd  := l_chg.cvg_eff_end_cd;
        l_cvg_end_rl  := l_chg.cvg_eff_end_rl;
    end if;
    close c_ler_chg_dep;
l_step := 40;
    if (l_cvg_strt_cd is NULL) then
        if (l_level = 'PL') then
            l_cvg_strt_cd := l_pl_rec.dpnt_cvg_strt_dt_cd;
            l_cvg_strt_rl := l_pl_rec.dpnt_cvg_strt_dt_rl;
        elsif (l_level = 'PTIP') then
            l_cvg_strt_cd := l_ptip_rec.dpnt_cvg_strt_dt_cd;
            l_cvg_strt_rl := l_ptip_rec.dpnt_cvg_strt_dt_rl;
        elsif (l_level = 'PGM') then
            l_cvg_strt_cd := l_pgm_rec.dpnt_cvg_strt_dt_cd;
            l_cvg_strt_rl := l_pgm_rec.dpnt_cvg_strt_dt_rl;
        end if;
    end if;
l_step := 50;
    if (l_cvg_end_cd is NULL) then
        if (l_level = 'PL') then
            l_cvg_end_cd := l_pl_rec.dpnt_cvg_end_dt_cd;
            l_cvg_end_rl := l_pl_rec.dpnt_cvg_end_dt_rl;
        elsif (l_level = 'PTIP') then
            l_cvg_end_cd := l_ptip_rec.dpnt_cvg_end_dt_cd;
            l_cvg_end_rl := l_ptip_rec.dpnt_cvg_end_dt_rl;
        elsif (l_level = 'PGM') then
            l_cvg_end_cd := l_pgm_rec.dpnt_cvg_end_dt_cd;
            l_cvg_end_rl := l_pgm_rec.dpnt_cvg_end_dt_rl;
        end if;
    end if;
l_step := 60;
    p_cvg_strt_cd := l_cvg_strt_cd;
    p_cvg_strt_rl := l_cvg_strt_rl;
    p_cvg_end_cd  := l_cvg_end_cd;
    p_cvg_end_rl  := l_cvg_end_rl;
exception
    when others then
         rpt_error(p_proc => l_proc, p_step => l_step);
         raise;
end determine_dpnt_cvg_dt_cd;
--
-- ----------------------------------------------------------------------------
-- |------------------------<Get_election_date  >-----------------------------|
-- ----------------------------------------------------------------------------
--
Procedure Get_election_date(p_effective_date    in Date
                           ,p_prtt_enrt_rslt_id in Number
                           ,p_business_group_id in Number
                           ,p_date out nocopy date
                           ,p_pil_id out nocopy number
                           ) is
    Cursor c1 is
        Select min(effective_start_date),pen.per_in_ler_id
          From ben_prtt_enrt_rslt_f pen
         Where pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
           And pen.business_group_id = p_business_group_id
	   and pen.prtt_enrt_rslt_stat_cd is null
           Group by pen.per_in_ler_id
	   order by pen.per_in_ler_id asc;   -- Bug 6528876

    l_date  date;
    l_pil_id number;
Begin
    Open c1;
    Fetch c1 into l_date,l_pil_id;
    If c1%notfound then
       l_date := hr_api.g_date;
       l_pil_id := to_number(null);
    End if;
    Close c1;
    p_date := l_date;
    p_pil_id := l_pil_id;
End;

-- ----------------------------------------------------------------------------
-- |------------------------< void_enrollment >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure void_enrollment
  (p_validate                in      boolean   default false
  ,p_per_in_ler_id           in      number
  ,p_prtt_enrt_rslt_id       in      number
  ,p_business_group_id       in      number
  ,p_enrt_cvg_strt_dt        in      date      default null
  ,p_person_id               in      number    default null
  ,p_elig_per_elctbl_chc_id  in      number    default null
  ,p_epe_ovn                 in      number    default null
  ,p_object_version_number   in      number    default null
  ,p_effective_date          in      date
  ,p_datetrack_mode          in      varchar2
  ,p_multi_row_validate      in      boolean   default TRUE
  ,p_source                  in      varchar2  default null
  ,p_enrt_bnft_id            in      number    default null)
is
  --
  -- Declare cursors and local variables
  --
  /*
  cursor c_pen
  is
  select pen.ler_id
         ,pen.person_id
         ,pen.ENRT_CVG_STRT_DT
         ,pen.ENRT_CVG_THRU_DT
         ,pen.effective_start_date
         ,pen.effective_end_date
         ,pen.pl_id
         ,pen.oipl_id
         ,pen.object_version_number
         ,epe.elig_per_elctbl_chc_id
         ,epe.per_in_ler_id
         ,epe.object_version_number epe_ovn
         ,enb.enrt_bnft_id
    from ben_prtt_enrt_rslt_f pen
         ,ben_elig_per_elctbl_chc epe
         ,ben_per_in_ler pil
         ,ben_enrt_bnft enb
   where pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and pen.prtt_enrt_rslt_id = epe.prtt_enrt_rslt_id (+)
     and nvl(epe.elig_per_elctbl_chc_id, -1) = enb.elig_per_elctbl_chc_id (+)
     and pen.business_group_id  = p_business_group_id
     and p_effective_date between pen.effective_start_date
                  and pen.effective_end_date
     and pil.per_in_ler_id(+)=epe.per_in_ler_id
     and pil.business_group_id(+)=epe.business_group_id
     and (   pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT') -- found row condition
          or pil.per_in_ler_stat_cd is null                  -- outer join condition
         )
  ;
  */
--
  cursor c_pen
  is
  select pen.ler_id
         ,pen.person_id
         ,pen.ENRT_CVG_STRT_DT
         ,pen.ENRT_CVG_THRU_DT
         ,pen.effective_start_date
         ,pen.effective_end_date
         ,pen.pl_id
         ,pen.oipl_id
         ,pen.object_version_number
         ,to_number(null) elig_per_elctbl_chc_id
         ,to_number(null) per_in_ler_id
         ,to_number(null) epe_ovn
         ,to_number(null) enrt_bnft_id
    from ben_prtt_enrt_rslt_f pen
   where pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and p_effective_date between pen.effective_start_date
                  and pen.effective_end_date
  ;
--
  cursor c_epe
  is
  select  epe.elig_per_elctbl_chc_id
         ,epe.per_in_ler_id
         ,epe.object_version_number epe_ovn
         ,enb.enrt_bnft_id
    from  ben_elig_per_elctbl_chc epe
         ,ben_per_in_ler pil
         ,ben_enrt_bnft enb
   where epe.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and nvl(epe.elig_per_elctbl_chc_id, -1) = enb.elig_per_elctbl_chc_id (+)
     and pil.per_in_ler_id=epe.per_in_ler_id
     and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
  ;

-- ???? should we have that effective date check?
  l_pen c_pen%rowtype;
  --
  /*
  cursor c_prv is
  select prv.prtt_rt_val_id
        --,max(ecr.enrt_rt_id) enrt_rt_id
        ,ecr.enrt_rt_id
        ,prv.object_version_number
        ,ecr.acty_base_rt_id
        ,abr.element_type_id
        ,abr.input_value_id
        ,prv.rt_strt_dt
    from ben_prtt_rt_val prv
        ,ben_enrt_rt  ecr
        ,ben_acty_base_rt_f abr
   where prv.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and prv.prtt_rt_val_stat_cd is null
     and prv.prtt_rt_val_id    = ecr.prtt_rt_val_id (+) */
     /* joining ecr with choice id or benefit id is removed as ecr will be
        having prtt_rt_val_id only for that particular benefit record in the case of
        flat range - bug#2545915 - this one matches with the cursor in delete_enrollment
     */
   /*
     and (l_pen.elig_per_elctbl_chc_id is null or
          l_pen.enrt_bnft_id is not null or
          l_pen.elig_per_elctbl_chc_id = ecr.elig_per_elctbl_chc_id)
     and (l_pen.enrt_bnft_id is null or
          l_pen.enrt_bnft_id = ecr.enrt_bnft_id)
     and prv.business_group_id = p_business_group_id
     and nvl(prv.acty_base_rt_id,-1) = abr.acty_base_rt_id (+)
     and p_effective_date between abr.effective_start_date (+)
                  and abr.effective_end_date (+)
     order by prv.rt_strt_dt desc; */
    /*
     group by
         prv.prtt_rt_val_id
        ,prv.object_version_number
        ,ecr.acty_base_rt_id
        ,abr.element_type_id
        ,abr.input_value_id
        ,prv.rt_strt_dt
    */
  --
  cursor c_prv is
  select distinct prv.prtt_rt_val_id
        ,prv.object_version_number
        ,abr.element_type_id
        ,abr.input_value_id
        ,prv.rt_strt_dt
    from ben_prtt_rt_val prv
        ,ben_acty_base_rt_f abr
   where prv.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and prv.prtt_rt_val_stat_cd is null
     and prv.business_group_id = p_business_group_id
     and prv.acty_base_rt_id   = abr.acty_base_rt_id
     and p_effective_date between abr.effective_start_date
                  and abr.effective_end_date
     order by prv.rt_strt_dt desc;
  --
  -- Rates with non-recurring element entries- prtt rt val are end dated
  cursor c_prv3 (p_per_in_ler_id number)is
    select prv.prtt_rt_val_id
        ,prv.object_version_number
        ,ecr.enrt_rt_id
        ,ecr.acty_base_rt_id
    from ben_prtt_rt_val prv,
         ben_enrt_rt ecr
    where prv.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and prv.prtt_rt_val_id   = ecr.prtt_rt_val_id
     and prv.rt_end_dt <>  hr_api.g_eot
     and prv.business_group_id = p_business_group_id
     and prv.per_in_ler_id     = p_per_in_ler_id
     and prv.prtt_rt_val_stat_cd is null;
  --
   cursor c_abr (p_acty_base_rt_id number) is
     select py.processing_type,
            abr.rcrrg_cd
     from   ben_acty_base_rt_f abr,
            pay_element_types_f py
     where  abr.element_type_id = py.element_type_id(+)
     and    abr.acty_base_rt_id = p_acty_base_rt_id
     and    p_effective_date between abr.effective_start_date
            and abr.effective_end_date
     and    p_effective_date between py.effective_start_date(+)
            and py.effective_end_date(+);
  --
  cursor c_unrestricted_future (p_per_in_ler_id number,
                                p_prtt_enrt_rslt_id number,
                                p_effective_start_date date) is
    select null
    from   ben_prtt_enrt_rslt_f pen,
           ben_per_in_ler pil,
           ben_ler_f ler
    where  pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
    and    pen.effective_start_date > p_effective_start_date
    and    pen.per_in_ler_id = pil.per_in_ler_id
    and    pil.ler_id = ler.ler_id
    and    ler.typ_cd = 'SCHEDDU'
    and    p_effective_start_date between ler.effective_start_date
           and ler.effective_end_date
    and    pen.business_group_id = p_business_group_id;

  -- 3574168
  -- Fetch all Primary Care Provider records.
  Cursor c_pcp
  is
  select pcp.PRMRY_CARE_PRVDR_ID
        ,pcp.EFFECTIVE_START_DATE
        ,pcp.EFFECTIVE_END_DATE
        ,pcp.PRTT_ENRT_RSLT_ID
        ,pcp.BUSINESS_GROUP_ID
        ,pcp.OBJECT_VERSION_NUMBER
    from ben_prmry_care_prvdr_f pcp
   where pcp.business_group_id = p_business_group_id
     and pcp.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and p_effective_date between pcp.effective_start_date
        and pcp.effective_end_date
       ;
  --
  -- Fetch all PCP records in future.
  Cursor c_pcp_future
  is
  select pcp.PRMRY_CARE_PRVDR_ID
        ,pcp.EFFECTIVE_START_DATE
        ,pcp.EFFECTIVE_END_DATE
        ,pcp.PRTT_ENRT_RSLT_ID
        ,pcp.BUSINESS_GROUP_ID
        ,pcp.OBJECT_VERSION_NUMBER
    from ben_prmry_care_prvdr_f pcp
   where pcp.business_group_id = p_business_group_id
     and pcp.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and p_effective_date  < pcp.effective_start_date
     and  NVL(pcp.effective_end_date, hr_api.g_eot) = hr_api.g_eot
       ;
   -- 3574168

  l_abr     c_abr%rowtype;

  -- Local variable declaration.
  l_proc                    varchar2(72); --  := g_package||'void_enrollment';
  l_datetrack_mode          varchar2(20);
  l_step                    integer;
  l_tmp_ovn                 integer;
  l_effective_start_date    date;
  l_effective_end_date      date;
  l_eff_dt                date;
  l_dummy                 varchar2(30);
  l_pcp_effective_date  date;

--
begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
     l_proc := g_package||'void_enrollment';
     hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint void_enrollment;
  --
  l_step := 10;

  -- Person id is needed for call to update_prtt_rt (because it calls
  -- element-entry proc that needs it as input).
  -- P_elig_per_elctbl_chc_id and p_epe_ovn are needed for update to chc table.
  -- Others are needed for update to result table.

    open c_pen;
    fetch c_pen into l_pen;
    if c_pen%notfound then
      close c_pen;
      rpt_error(p_proc => l_proc, p_step => l_step);
      fnd_message.set_name('BEN','BEN_91711_ENRT_RSLT_NOT_FND');
      fnd_message.set_token('ID', to_char(p_prtt_enrt_rslt_id));
      fnd_message.set_token('PROC',l_proc);
      fnd_message.set_token('PERSON_ID', to_char(p_person_id));
      fnd_message.set_token('LER_ID', null);
      fnd_message.set_token('EFFECTIVE_DATE',to_char(p_effective_date));
      fnd_message.raise_error;
    else
      --
      open c_epe;
      fetch c_epe into  l_pen.elig_per_elctbl_chc_id,
                        l_pen.per_in_ler_id,
                        l_pen.epe_ovn,
                        l_pen.enrt_bnft_id ;
      close c_epe ;
      --
    end if;
    close c_pen;
   -- always fetch the above data because other values are needed.
  /*
    l_pen.enrt_cvg_strt_dt := p_enrt_cvg_strt_dt;
    l_pen.person_id := p_person_id;
    l_pen.elig_per_elctbl_chc_id := p_elig_per_elctbl_chc_id;
    l_pen.epe_ovn := p_epe_ovn;
    l_pen.object_version_number := p_object_version_number;
    l_pen.enrt_bnft_id := p_enrt_bnft_id; */
    --
    if g_debug then
       hr_utility.set_location('Rate Non recurring',3459);
    end if;
       for l_prv in c_prv3 (p_per_in_ler_id) loop
         --check whether rate is non-recurring
         open c_abr(l_prv.acty_base_rt_id);
         fetch c_abr into l_abr;
         close c_abr;
         --
         if l_abr.processing_type = 'N' or
            l_abr.rcrrg_cd = 'ONCE' then
            null;
         else
           exit;
         end if;

         if g_debug then
           hr_utility.set_location('delete prtt',3459);
         end if;
           update ben_enrt_rt
              set prtt_rt_val_id = null
              where enrt_rt_id = l_prv.enrt_rt_id;
           --
           ben_prtt_rt_val_api.delete_prtt_rt_val
           (P_VALIDATE                => FALSE
           ,P_PRTT_RT_VAL_ID          => l_prv.prtt_rt_val_id
           ,P_OBJECT_VERSION_NUMBER   => l_prv.object_version_number
           ,P_EFFECTIVE_DATE          => l_eff_dt
           ,p_person_id               => l_pen.person_id
           ,p_business_group_id       => p_business_group_id
           );
       end loop;



  l_step := 14;
  --
  -- Update rt_end_dt in prtt_rate_val table
  --
  hr_utility.set_location(' c_prv EPE'||l_pen.elig_per_elctbl_chc_id,10);
  hr_utility.set_location(' c_prv ENB'||l_pen.enrt_bnft_id,10);
  hr_utility.set_location(' c_prv PEN'||p_prtt_enrt_rslt_id,10);
  --
  For l_prv in c_prv loop
    --
    hr_utility.set_location(' l_prv PRV'||l_prv.prtt_rt_val_id,10);
    --
    ben_prtt_rt_val_api.update_prtt_rt_val
        (P_VALIDATE                => FALSE
        ,P_PRTT_RT_VAL_ID          => l_prv.prtt_rt_val_id
        ,P_RT_END_DT               => (l_prv.rt_strt_dt - 1)
        ,p_person_id               => l_pen.person_id
   --     ,p_acty_base_rt_id         => l_prv.acty_base_rt_id
        ,p_input_value_id          => l_prv.input_value_id
        ,p_element_type_id         => l_prv.element_type_id
        ,p_ended_per_in_ler_id     => p_per_in_ler_id
        ,p_prtt_rt_val_stat_cd     => 'VOIDD'
        ,p_business_group_id       => p_business_group_id
        ,P_OBJECT_VERSION_NUMBER   => l_prv.object_version_number
        ,P_EFFECTIVE_DATE          => p_effective_date
        );
  end loop;
  --
  --
  -- 3574168: Remove PCP records
  -- Set End-date to coverage-end-date.
  --
  for l_pcp in c_pcp loop
    --
    hr_utility.set_location('Delete prmry_care_prvdr_id '|| l_pcp.prmry_care_prvdr_id,15);
    --
    ben_prmry_care_prvdr_api.delete_prmry_care_prvdr
    (P_VALIDATE               => FALSE
    ,P_PRMRY_CARE_PRVDR_ID    => l_pcp.prmry_care_prvdr_id
    ,P_EFFECTIVE_START_DATE   => l_pcp.effective_start_date
    ,P_EFFECTIVE_END_DATE     => l_pcp.effective_end_date
    ,P_OBJECT_VERSION_NUMBER  => l_pcp.object_version_number
    ,P_EFFECTIVE_DATE         => p_effective_date
    ,P_DATETRACK_MODE         => hr_api.g_zap
    ,p_called_from            => 'delete_enrollment'
    );
    --
  End loop;
  --
  -- Get future PCP records if any and zap - delete all of them.
  --
  for l_pcp_future in c_pcp_future loop
    --
    hr_utility.set_location('ZAP prmry_care_prvdr_id '|| l_pcp_future.prmry_care_prvdr_id, 15);
    --
    l_pcp_effective_date := l_pcp_future.effective_start_date ;
    --
    ben_prmry_care_prvdr_api.delete_prmry_care_prvdr
    (P_VALIDATE               => FALSE
    ,P_PRMRY_CARE_PRVDR_ID    => l_pcp_future.prmry_care_prvdr_id
    ,P_EFFECTIVE_START_DATE   => l_pcp_future.effective_start_date
    ,P_EFFECTIVE_END_DATE     => l_pcp_future.effective_end_date
    ,P_OBJECT_VERSION_NUMBER  => l_pcp_future.object_version_number
    ,P_EFFECTIVE_DATE         => l_pcp_effective_date
    ,P_DATETRACK_MODE         => hr_api.g_zap
    ,p_called_from            => 'delete_enrollment'
    );
    --
  End loop;

  -- 3574168
  --

  l_step := 120;

  get_ben_pen_upd_dt_mode
    (p_effective_date         => p_effective_date
    ,p_base_key_value         => p_prtt_enrt_rslt_id
    ,P_desired_datetrack_mode => p_datetrack_mode
    ,P_datetrack_allow        => l_datetrack_mode
    );

  l_step := 125;
  --
  --2785410 - if the deenrollment record is already there in the case of unrestricted
  -- and now if the result gets voided the datetrack mode needs to be changed
  open c_unrestricted_future(p_per_in_ler_id => l_pen.per_in_ler_id,
                             p_prtt_enrt_rslt_id => p_prtt_enrt_rslt_id,
                             p_effective_start_date =>l_pen.effective_start_date);
  fetch c_unrestricted_future into l_dummy;
  if c_unrestricted_future%found then
     --
     ben_prtt_enrt_result_api.delete_prtt_enrt_result
              (p_validate                => false,
               p_prtt_enrt_rslt_id       => p_prtt_enrt_rslt_id,
               p_effective_start_date    => l_effective_start_date,
               p_effective_end_date      => l_effective_end_date,
               p_object_version_number   => l_pen.object_version_number,
               p_effective_date          => p_effective_date,
               p_datetrack_mode          => hr_api.g_future_change,
               p_multi_row_validate      => FALSE);
     --
      open c_pen;
      fetch c_pen into l_pen;
      close c_pen;
     --
  end if;
  close c_unrestricted_future;

  ben_prtt_enrt_result_api.update_prtt_enrt_result
      (p_validate                => FALSE
           ,p_prtt_enrt_rslt_id       => p_prtt_enrt_rslt_id
       ,p_effective_start_date    => l_effective_start_date
       ,p_effective_end_date      => l_effective_end_date
           ,p_per_in_ler_id           => l_pen.per_in_ler_id
       ,p_enrt_cvg_thru_dt        => (l_pen.enrt_cvg_strt_dt - 1)
           ,p_prtt_enrt_rslt_stat_cd  => 'VOIDD'
       ,p_object_version_number   => l_pen.object_version_number
       ,p_effective_date          => p_effective_date
       ,p_datetrack_mode          => l_datetrack_mode
           ,p_multi_row_validate      => p_multi_row_validate
           ,p_business_group_id       => p_business_group_id  );


  l_step := 136;
  --
  -- Do not call manage_enrt_bnft, if it is called from election_information
  -- as the call is always made from there.
  --
  --Bug 3256056 This call from election_information is associated with the
  --New results - That other call works fine if the result was continued from
  --the prevoius enrollment. But if the user made the change in the
  --current enrollment olny [I mean selected option 1 , saved and then now
  --changing to option 2 ] we don't want to keep the pen id on the enb record.
  --
  --if p_source is null or
  --   p_source <> 'benelinf' then
     --
     ben_election_information.manage_enrt_bnft
         (p_prtt_enrt_rslt_id     => p_prtt_enrt_rslt_id
         ,p_business_group_id     => p_business_group_id
         ,p_effective_date        => p_effective_date
         ,p_object_version_number => l_tmp_ovn
         ,p_per_in_ler_id         => p_per_in_ler_id
         );
     --
  --end if;
  --
  l_step := 177;


  -- leslie code begin:
  -- when result is voided in correction mode, we can't compute premium
  -- credits.  Tell use that they may want to manually.
  -- If in correction and esd of result is before first day of this month...
  if l_datetrack_mode = hr_api.g_correction and l_pen.effective_start_date <
     to_date(to_char(p_effective_date, 'mm-yyyy'), 'mm-yyyy') then
     ben_prem_prtt_monthly.premium_warning
          (p_person_id            => l_pen.person_id
          ,p_prtt_enrt_rslt_id    => p_prtt_enrt_rslt_id
          ,p_effective_start_date => l_pen.effective_start_date
          ,p_effective_date       => p_effective_date
          ,p_warning              => 'VOID');

  end if;
  -- leslie code end.

  -- write to change event log. -thayden
  l_step := 178;
  --
  if p_source is null or
        p_source <> 'benelinf' then
    ben_ext_chlg.log_benefit_chg
        (p_action                      => 'DELETE'
        ,p_old_pl_id                   =>  l_pen.pl_id
        ,p_old_oipl_id                 =>  l_pen.oipl_id
        ,p_old_enrt_cvg_strt_dt        =>  l_pen.enrt_cvg_strt_dt
        ,p_old_enrt_cvg_end_dt         =>  l_pen.enrt_cvg_thru_dt
        ,p_pl_id                       =>  l_pen.pl_id
        ,p_oipl_id                     =>  l_pen.oipl_id
        ,p_enrt_cvg_strt_dt            =>  l_pen.enrt_cvg_strt_dt
        ,p_enrt_cvg_end_dt             =>  (l_pen.enrt_cvg_strt_dt - 1)
        ,p_prtt_enrt_rslt_id           =>  p_prtt_enrt_rslt_id
        ,p_per_in_ler_id               =>  l_pen.per_in_ler_id
        ,p_person_id                   =>  l_pen.person_id
        ,p_business_group_id           =>  p_business_group_id
        ,p_effective_date              =>  p_effective_date
        );
  end if;

  if g_debug then
     hr_utility.set_location(l_proc, 60);
  end if;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
      raise hr_api.validate_enabled;
  end if;
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 70);
  end if;
--
Exception
  --
  when hr_api.validate_enabled
  then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO void_enrollment;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO void_enrollment;
    rpt_error(p_proc => l_proc, p_step => l_step);
    fnd_message.raise_error;
--
end void_enrollment;
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_enrollment >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_enrollment
  (p_validate                in      boolean   default false
  ,p_per_in_ler_id           in      number    default NULL
  ,p_lee_rsn_id              in      number    default NULL
  ,p_enrt_perd_id            in      number    default NULL
  ,p_prtt_enrt_rslt_id       in      number
  ,p_business_group_id       in      number
  ,p_effective_start_date    out nocopy     date
  ,p_effective_end_date      out nocopy     date
  ,p_object_version_number   in out nocopy  number
  ,p_effective_date          in      date
  ,p_datetrack_mode          in      varchar2
  ,p_multi_row_validate      in      boolean  default TRUE
  ,p_source                  in      varchar2 default null
  ,p_enrt_cvg_thru_dt        in      date     default null
  ,p_mode                    in      varchar2 default null)
is
  --
  l_fnd_message_exception exception;
  -- Get result and choice information for row we are trying to end.
  --
  cursor c_pen is
  select pen.pl_id
         ,pen.pgm_id
         ,pen.ptip_id
         ,pen.pl_typ_id
         ,pen.oipl_id
         ,pen.ler_id
         ,pen.person_id
         ,pen.business_group_id
         ,pen.ENRT_CVG_STRT_DT
         ,pen.ENRT_CVG_THRU_DT
         ,pen.SSPNDD_FLAG
         ,pen.ERLST_DEENRT_DT
         ,pen.effective_start_date
         ,pen.effective_end_date
         ,pen.object_version_number pen_ovn
         ,pen.rplcs_sspndd_rslt_id
         ,pen.per_in_ler_id pen_per_in_ler_id
         ,epe.elig_per_elctbl_chc_id
         ,epe.per_in_ler_id
         ,epe.object_version_number epe_ovn
         ,epe.MNDTRY_FLAG
         ,epe.fonm_cvg_strt_dt
         ,epe.ELCTBL_FLAG
         ,epe.AUTO_ENRT_FLAG
         ,enb.enrt_bnft_id
         ,pil.per_in_ler_stat_cd
         ,oipl.opt_id
         ,pl.name  pl_name
         ,opt.name opt_name
	 ,pl.imptd_incm_calc_cd
    from ben_prtt_enrt_rslt_f pen
         ,ben_elig_per_elctbl_chc epe
         ,ben_per_in_ler pil
         ,ben_enrt_bnft enb
         ,ben_oipl_f oipl
         ,ben_pl_f   pl
         ,ben_opt_f opt
   where pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and pen.prtt_enrt_rslt_id = epe.prtt_enrt_rslt_id (+)
     and nvl(epe.elig_per_elctbl_chc_id, -1) = enb.elig_per_elctbl_chc_id (+)
     and pen.business_group_id = epe.business_group_id (+)
     and nvl(p_per_in_ler_id, pen.per_in_Ler_id) = epe.per_in_ler_id (+)
     and pen.business_group_id = p_business_group_id
     and p_effective_date between pen.effective_start_date
                  and pen.effective_end_date
     and pil.per_in_ler_id(+)=epe.per_in_ler_id
     and pil.business_group_id(+)=epe.business_group_id
     and (   pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT') -- found row condition
          or pil.per_in_ler_stat_cd is null                  -- outer join condition
         )
     and pl.business_group_id=p_business_group_id
     and pl.pl_id  =pen.pl_id
     and p_effective_date between
          pl.effective_start_date and pl.effective_end_date
     and oipl.business_group_id(+)=p_business_group_id
     and oipl.oipl_id(+)=pen.oipl_id
     and p_effective_date between
           oipl.effective_start_date(+) and oipl.effective_end_date(+)
     and opt.business_group_id(+)=p_business_group_id
     and opt.opt_id(+)=oipl.opt_id
     and p_effective_date between
           opt.effective_start_date(+) and opt.effective_end_date(+)
   ;
  l_pen c_pen%rowtype;
  l_prtt_prem_id number;
  --
  --  get all prtt_prem for result
  --
   /****************** CODE PRIOR TO WWBUG: 1646442 *******************
  cursor c_ppe is
    select ppe.prtt_prem_id,
           ppe.object_version_number,
           ppe.effective_start_date,
           ppe.effective_end_date,
           ppe.actl_prem_id
      from ben_prtt_prem_f ppe,
           ben_per_in_ler pil
     where ppe.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
       and pil.per_in_ler_id=ppe.per_in_ler_id
       and pil.business_group_id=ppe.business_group_id
       and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT');
   ******************** END CODE PRIOR TO WBUG: 1646442 ****************/
  /* Start of Changes for WWBUG: 1646442                                */
  cursor c_ppe (p_ppe_dt_to_use IN DATE) is
    select ppe.prtt_prem_id,
           ppe.object_version_number,
           ppe.effective_start_date,
           ppe.effective_end_date,
           ppe.actl_prem_id
      from ben_prtt_prem_f ppe,
           ben_per_in_ler pil
     where ppe.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
       and pil.per_in_ler_id=ppe.per_in_ler_id
       and pil.business_group_id=ppe.business_group_id
       and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
-- jcarpent added additional logic below to fix primary key error.
-- case 1 is where you want the dt effective row
-- case 2 is where you want the future dated rows to zap.
       and p_ppe_dt_to_use between ppe.effective_start_date and ppe.effective_end_date
     UNION
    select ppe1.prtt_prem_id,
           ppe1.object_version_number,
           ppe1.effective_start_date,
           ppe1.effective_end_date,
           ppe1.actl_prem_id
      from ben_prtt_prem_f ppe1,
           ben_per_in_ler pil
     where ppe1.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
       and pil.per_in_ler_id=ppe1.per_in_ler_id
       and pil.business_group_id=ppe1.business_group_id
       and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
       and ppe1.effective_start_date > p_ppe_dt_to_use
       and not exists
           (select 1
              from ben_prtt_prem_f ppe2,
                   ben_per_in_ler pil
             where ppe2.prtt_prem_id = ppe1.prtt_prem_id
             and   ppe2.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
             and   pil.per_in_ler_id=ppe2.per_in_ler_id
             and   pil.business_group_id=ppe2.business_group_id
             and   pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
             and   p_ppe_dt_to_use between
                        ppe2.effective_start_date and ppe2.effective_end_date);
/*  End of Changes for WWBUG: 1646442                                   */
  --
  l_ppe c_ppe%rowtype;
  --
  cursor c_prm is
    select prm.prtt_prem_by_mo_id,
           prm.object_version_number,
           prm.effective_start_date,
           prm.effective_end_date
      from ben_prtt_prem_by_mo_f prm
     where prm.prtt_prem_id = l_prtt_prem_id;
  --
  l_prm c_prm%rowtype;
  --
  -- Get all rates for result row we are trying to end.
  --
  cursor c_prv2 is
  select prv.prtt_rt_val_id
        ,prv.rt_strt_dt
        ,prv.per_in_ler_id
        ,prv.object_version_number
        ,prv.acty_base_rt_id
        ,abr.element_type_id
        ,abr.input_value_id
    from ben_prtt_rt_val prv
        ,ben_acty_base_rt_f abr
   where prv.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and prv.rt_end_dt         = hr_api.g_eot
     and prv.business_group_id = p_business_group_id
     and prv.acty_base_rt_id = abr.acty_base_rt_id
     and p_effective_date between abr.effective_start_date
                  and abr.effective_end_date
  ;
  --
  --  overlapped adj
  --
  cursor c_prv5(p_rt_end_dt date) is
  select prv.prtt_rt_val_id
        ,prv.rt_strt_dt
        ,prv.per_in_ler_id
        ,prv.object_version_number
        ,prv.acty_base_rt_id
        ,abr.element_type_id
        ,abr.input_value_id
    from ben_prtt_rt_val prv
        ,ben_acty_base_rt_f abr
	,ben_per_in_ler pil -- Bug 8573195,not to pick the rows of backed out lifevent for rate adjustment
   where prv.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and prv.rt_end_dt         > p_rt_end_dt
     and prv.per_in_ler_id <> p_per_in_ler_id
     and prv.rt_end_dt         <> hr_api.g_eot
     and prv.business_group_id = p_business_group_id
     and prv.acty_base_rt_id = abr.acty_base_rt_id
     and pil.per_in_ler_id = prv.per_in_ler_id
     and pil.per_in_ler_stat_cd not in ('BCKDT','VOIDD')
     and p_effective_date between abr.effective_start_date
                  and abr.effective_end_date
  ;

  --
  -- Get program extra info to determine if rates should be adjusted.
  --
  cursor c_get_pgm_extra_info(p_pgm_id number) is
  select pgi_information1
  from ben_pgm_extra_info
  where information_type = 'ADJ_RATE_PREV_LF_EVT'
  and pgm_id = p_pgm_id;

  -- Get all rates for result row we are trying to end without looking at end date.
  --
  cursor c_prvdel is
  select prv.prtt_rt_val_id
        ,max(ecr.enrt_rt_id) enrt_rt_id
        ,prv.object_version_number
        ,ecr.acty_base_rt_id
        ,abr.element_type_id
        ,abr.input_value_id
	,abr.entr_val_at_enrt_flag
	,prv.rt_strt_dt
    from ben_prtt_rt_val prv
        ,ben_enrt_rt  ecr
        ,ben_acty_base_rt_f abr
   where prv.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and prv.prtt_rt_val_id    = ecr.prtt_rt_val_id (+)
     and prv.business_group_id = p_business_group_id
     and nvl(prv.acty_base_rt_id,-1) = abr.acty_base_rt_id (+)
     and p_effective_date between abr.effective_start_date (+)
                  and abr.effective_end_date (+)
     group by
         prv.prtt_rt_val_id
        ,prv.object_version_number
        ,ecr.acty_base_rt_id
        ,abr.element_type_id
        ,abr.input_value_id
        ,abr.entr_val_at_enrt_flag
	,prv.rt_strt_dt;
  --
  --  Rates having non-recurring element entries - prtt rt vals are end dated
  cursor c_prv3 (p_per_in_ler_id number)is
  select prv.prtt_rt_val_id
        ,prv.object_version_number
        ,ecr.enrt_rt_id
        ,ecr.acty_base_rt_id
    from ben_prtt_rt_val prv,
         ben_enrt_rt ecr
   where prv.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and prv.prtt_rt_val_id   = ecr.prtt_rt_val_id
     and prv.rt_end_dt <>  hr_api.g_eot
     and prv.business_group_id = p_business_group_id
     and prv.per_in_ler_id     = p_per_in_ler_id
     and prv.prtt_rt_val_stat_cd is null;
--
  cursor c_prv4 (p_rt_end_dt date) is
  select prv.prtt_rt_val_id
        ,ecr.enrt_rt_id enrt_rt_id
        ,prv.object_version_number
        ,ecr.acty_base_rt_id
        ,abr.element_type_id
        ,abr.input_value_id
        ,prv.rt_end_dt --This is needed to determine the future started rate
    from ben_prtt_rt_val prv
        ,ben_enrt_rt  ecr
        ,ben_acty_base_rt_f abr
   where prv.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and prv.rt_end_dt         > p_rt_end_dt
     and prv.prtt_rt_val_id    = ecr.prtt_rt_val_id (+)
     and prv.business_group_id = p_business_group_id
     and prv.prtt_rt_val_stat_cd is null
     and nvl(prv.acty_base_rt_id,-1) = abr.acty_base_rt_id (+)
     and p_effective_date between abr.effective_start_date (+)
                              and abr.effective_end_date (+);
--
  cursor c_abr (p_acty_base_rt_id number) is
     select py.processing_type,
            abr.rcrrg_cd
     from   ben_acty_base_rt_f abr,
            pay_element_types_f py
     where  abr.element_type_id = py.element_type_id(+)
     and    abr.acty_base_rt_id = p_acty_base_rt_id
     and    p_effective_date between abr.effective_start_date
            and abr.effective_end_date
     and    p_effective_date between py.effective_start_date(+)
            and py.effective_end_date(+);
  --
   l_abr     c_abr%rowtype;
   --
  Cursor c_pcp(c_pcp_effective_date DATE)
  is
  select pcp.PRMRY_CARE_PRVDR_ID
        ,pcp.EFFECTIVE_START_DATE
        ,pcp.EFFECTIVE_END_DATE
        ,pcp.PRTT_ENRT_RSLT_ID
        ,pcp.BUSINESS_GROUP_ID
        ,pcp.OBJECT_VERSION_NUMBER
    from ben_prmry_care_prvdr_f pcp
   where business_group_id = p_business_group_id
     and prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and c_pcp_effective_date between effective_start_date  --3631067: Changed p_effective_date to c_pcp_effective_date
                  and effective_end_date
       ;
  -- 3574168
  -- Fetch all PCP records in future.
  Cursor c_pcp_future (c_pcp_effective_date DATE)
  is
  select pcp.PRMRY_CARE_PRVDR_ID
        ,pcp.EFFECTIVE_START_DATE
        ,pcp.EFFECTIVE_END_DATE
        ,pcp.PRTT_ENRT_RSLT_ID
        ,pcp.BUSINESS_GROUP_ID
        ,pcp.OBJECT_VERSION_NUMBER
    from ben_prmry_care_prvdr_f pcp
   where business_group_id = p_business_group_id
     and prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and c_pcp_effective_date  < effective_start_date ----3631067: Changed p_effective_date to c_pcp_effective_date
     and  NVL(effective_end_date, hr_api.g_eot) = hr_api.g_eot
       ;
   -- 3574168

    --
  l_global_pil_rec ben_global_enrt.g_global_pil_rec_type;
  --
  -- ikasire: deleted the condition
  --          pen.enrt_cvg_strt_dt >= p_effective_date
  --          since it may not be always true. Instead added the
  --          condition pen.ENRT_CVG_THRU_DT = hr_api.g_eot
  --          to get the new prtt enrt record. Still there is a
  --          gap in this '1 prior' coding, which has to be
  --          handled with more detailed study.
  --Bug 2847110
  --18-Jan-2005
  --CF SUSP and INTERIM CASE
  --
  --bug#4967063 - added strt dt condition for getting new coverage at plan type
  --level - otherwise if multiple plans enrolled in same plan type leads to bug
  cursor c_new_cvg_strt_dt(l_pl_typ_id number, l_ptip_id number, l_pl_id number,
                           p_enrt_cvg_strt_dt date ) is
    select max(enrt_cvg_strt_dt)
      from ben_prtt_enrt_rslt_f  pen
     where pen.per_in_ler_id = nvl(p_per_in_ler_id, -1)          -- is this OK?
       and ((pen.pgm_id is null and pen.pl_typ_id is not null
                       and pen.pl_typ_id = nvl(l_pl_typ_id, -1))
            or (pen.ptip_id is not null and pen.ptip_id = nvl(l_ptip_id, -1))
           )
       and pen.no_lngr_elig_flag = 'N'
       and ((l_pl_id =-999 and pen.enrt_cvg_strt_dt >= p_enrt_cvg_strt_dt)
             or pen.pl_id = l_pl_id ) -- Bug 2847110
       and pen.prtt_enrt_rslt_stat_cd is null
  --     and pen.enrt_cvg_strt_dt >= p_effective_date
       and pen.ENRT_CVG_THRU_DT = hr_api.g_eot
       and pen.effective_end_date = hr_api.g_eot
  --     and pen.business_group_id = p_business_group_id
       --and p_effective_date between pen.effective_start_date
       --                      and pen.effective_end_date
       and pen.prtt_enrt_rslt_id <> p_prtt_enrt_rslt_id
       ;
  --
  cursor c_intm_other_rslt(p_per_in_ler_id number) is
     select 'Y'
     from   ben_prtt_enrt_rslt_f pen
     where  pen.rplcs_sspndd_rslt_id = l_pen.rplcs_sspndd_rslt_id
     and    pen.business_group_id    = p_business_group_id
     and    pen.sspndd_flag          = 'Y'
     and    pen.enrt_cvg_thru_dt     = hr_api.g_eot
     and    pen.effective_end_date   = hr_api.g_eot
     and    pen.prtt_enrt_rslt_stat_cd is null
     and    p_effective_date between
            pen.effective_start_date and pen.effective_end_date
  -- Bug 6165501 : Added union clause if its a Correction case, and interim has already
  -- been end-dated by the new pil, then no need to call delete_enrollment for the interim
  UNION
    select 'Y'
    from   ben_prtt_enrt_rslt_f pen, ben_le_clsn_n_rstr cls
    where  pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
    and    pen.prtt_enrt_rslt_stat_cd is null
    and    pen.enrt_cvg_thru_dt <> hr_api.g_eot
    and    pen.per_in_ler_id = p_per_in_ler_id
    and    cls.bkup_tbl_id = pen.prtt_enrt_rslt_id
    and    cls.bkup_tbl_typ_cd = 'BEN_PRTT_ENRT_RSLT_F_CORR'
    and    cls.per_in_ler_ended_id = p_per_in_ler_id;
  -- End Bug 6165501

  --
  cursor c_interim is
     select pen.prtt_enrt_rslt_id,
            pen.object_version_number,
            pen.effective_start_date,
            pen.effective_end_date
     from   ben_prtt_enrt_rslt_f pen
     where  pen.prtt_enrt_rslt_id = l_pen.rplcs_sspndd_rslt_id
     and    pen.business_group_id = p_business_group_id
     and    pen.prtt_enrt_rslt_stat_cd is null
     and    p_effective_date between
            pen.effective_start_date and pen.effective_end_date;

  cursor c_rslt_opt (p_person_id  number ,
                     p_pgm_id   number ,
                     p_pl_id    number ,
                     p_oipl_id  number ,
                     p_per_in_ler_id  number ,
                     p_effective_date date
                    )  is
      select 'x'
      from   ben_prtt_enrt_rslt_f pen
      where  pen.person_id  = p_person_id
        and  nvl(p_pgm_id,-1)   = nvl(pen.pgm_id,-1)
        and  nvl(p_pl_id ,-1)   = nvl(pen.pl_id,-1)
        and  nvl(p_oipl_id,-1)  = nvl(pen.oipl_id, -1)
        and  (p_per_in_ler_id <>  pen.per_in_ler_id
             or l_global_pil_rec.typ_cd = 'SCHEDDU') -- 4919591
        and  pen.prtt_enrt_rslt_stat_cd is null
        and  pen.sspndd_flag = 'N'
        and  p_effective_date > pen.effective_start_date
        and  pen.enrt_cvg_thru_dt > p_effective_date -- 4919591
        and  pen.effective_end_date = hr_api.g_eot; --4919591


 cursor c_rslt_pl (  p_person_id  number ,
                     p_pgm_id   number ,
                     p_pl_id    number ,
                     p_per_in_ler_id  number ,
                     p_effective_date date
                    )  is
      select 'x'
      from   ben_prtt_enrt_rslt_f pen
      where  pen.person_id = p_person_id
        and  nvl(p_pgm_id,-1) = nvl(pen.pgm_id,-1)
        and  p_pl_id          = pen.pl_id
        and  (p_per_in_ler_id <>  pen.per_in_ler_id
             or l_global_pil_rec.typ_cd = 'SCHEDDU') -- 4919591
        and  pen.prtt_enrt_rslt_stat_cd is null
        and  pen.sspndd_flag = 'N'
        and  p_effective_date > pen.effective_start_date
	and  p_effective_date < nvl(pen.erlst_deenrt_dt,(p_effective_date + 1)) ----Bug 8578358
        and  pen.enrt_cvg_thru_dt > p_effective_date -- 4919591
        and  pen.effective_end_date = hr_api.g_eot; -- 4919591------------7458990

 cursor c_rslt_ptip( p_person_id     number ,
                     p_pgm_id        number ,
                     p_ptip_id       number ,
                     p_per_in_ler_id number ,
                     p_effective_date date
                    )  is
      select 'x'
      from   ben_prtt_enrt_rslt_f pen
      where  pen.person_id = p_person_id
        and  p_pgm_id   = pen.pgm_id
        and  p_ptip_id  = pen.ptip_id
        and  (p_per_in_ler_id <>  pen.per_in_ler_id
             or l_global_pil_rec.typ_cd = 'SCHEDDU')
        and  pen.prtt_enrt_rslt_stat_cd is null
        and  pen.sspndd_flag = 'N'
        and  p_effective_date > pen.effective_start_date
        and  pen.enrt_cvg_thru_dt > p_effective_date
        and  pen.effective_end_date = hr_api.g_eot;
  --
  cursor c_per_in_ler (p_per_in_ler_id number) is
    select *
    from ben_per_in_ler
    where per_in_ler_id = p_per_in_ler_id
    and   business_group_id = p_business_group_id;

  --
  l_per_in_ler             c_per_in_ler%rowtype;
  --
  cursor c_pen_ovn (p_prtt_enrt_rslt_id number, p_effective_date date ) is
    select pen.object_version_number,pen.effective_start_date  --4663971
    from ben_prtt_enrt_rslt_f pen
    where pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
    and   p_effective_date between pen.effective_start_date and pen.effective_end_date ;
  l_pen_ovn                 c_pen_ovn%rowtype;
  --
  cursor c_pel (p_elig_pe_elctbl_chc_id number) is
    select pel.enrt_perd_id,pel.lee_rsn_id
    from ben_pil_elctbl_chc_popl pel
       ,ben_elig_per_elctbl_chc epe
    where pel.pil_elctbl_chc_popl_id = epe.pil_elctbl_chc_popl_id
    and epe.elig_per_elctbl_chc_id = p_elig_pe_elctbl_chc_id;
  --
  CURSOR c_lee_rsn_for_plan (c_ler_id number, c_pl_id number,c_effective_date date ) IS
      SELECT   leer.lee_rsn_id
      FROM     ben_lee_rsn_f leer,
               ben_popl_enrt_typ_cycl_f petc
      WHERE    leer.ler_id            = c_ler_id
      AND      leer.business_group_id = p_business_group_id
      AND      c_effective_date BETWEEN leer.effective_start_date
                   AND leer.effective_end_date
      AND      leer.popl_enrt_typ_cycl_id = petc.popl_enrt_typ_cycl_id
      AND      petc.pl_id                 = c_pl_id
      AND      petc.enrt_typ_cycl_cd = 'L'                        -- life event
      AND      petc.business_group_id = p_business_group_id
      AND      c_effective_date BETWEEN petc.effective_start_date
                   AND petc.effective_end_date;
  --
  CURSOR c_lee_rsn_for_program (c_ler_id number, c_pgm_id number,c_effective_date date )IS
      SELECT   leer.lee_rsn_id
      FROM     ben_lee_rsn_f leer,
               ben_popl_enrt_typ_cycl_f petc
      WHERE    leer.ler_id            = c_ler_id
      AND      leer.business_group_id = p_business_group_id
      AND      c_effective_date BETWEEN leer.effective_start_date
                   AND leer.effective_end_date
      AND      leer.popl_enrt_typ_cycl_id = petc.popl_enrt_typ_cycl_id
      AND      petc.pgm_id                = c_pgm_id
      AND      petc.enrt_typ_cycl_cd      = 'L'
      AND      petc.business_group_id     = p_business_group_id
      AND      c_effective_date BETWEEN petc.effective_start_date
                   AND petc.effective_end_date;
  --
  l_pel  c_pel%rowtype;
  l_interim  c_interim%rowtype;
  --
  -- Bug 2627078 update epe with current pen_id
  cursor c_curr_rslt (p_person_id  number ,
                      p_pgm_id   number ,
                      p_pl_id    number ,
                      p_oipl_id  number ,
                      p_per_in_ler_id  number
                    )  is
      select prtt_enrt_rslt_id
      from   ben_prtt_enrt_rslt_f pen
      where  pen.person_id  = p_person_id
        and  nvl(p_pgm_id,-1)   = nvl(pen.pgm_id,-1)
        and  nvl(p_pl_id ,-1)   = nvl(pen.pl_id,-1)
        and  nvl(p_oipl_id,-1)  = nvl(pen.oipl_id, -1)
        and  p_per_in_ler_id =  pen.per_in_ler_id
        and  pen.prtt_enrt_rslt_stat_cd is null
        and  pen.enrt_cvg_thru_dt <> hr_api.g_eot
      ;
  --
  l_current_result_id       number ;
  --
  -- Bug 2689915
  cursor c_ler is
    select typ_cd
    from ben_ler_f ler,
         ben_prtt_enrt_rslt_f pen
    where pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
      and pen.ler_id            = ler.ler_id ;
  --
  cursor  c_old_corr_pen (c_pil_id  number
                         ,c_pen_id  number
                         ,c_pen_effective_start_date date) is  -- bug 7197868
   select per_in_ler_id
   from   BEN_LE_CLSN_N_RSTR
   where  bkup_tbl_id         =  c_pen_id
     and  per_in_ler_ended_id =  c_pil_id
     and  per_in_ler_id       <>  c_pil_id
     and  effective_start_date = c_pen_effective_start_date  -- bug 7197868
     and  enrt_cvg_thru_dt = hr_api.g_eot;
  l_corr_pil_id BEN_LE_CLSN_N_RSTR.per_in_ler_id%type  ;

  cursor  c_pen_obj_no (c_pil_id  number
                       ,c_pen_id  number ) is
   select object_version_number
     from  ben_prtt_enrt_rslt_f pen
    where pen.prtt_enrt_rslt_id = c_pen_id
      and pen.per_in_ler_id     = c_pil_id
      and p_effective_date between
          pen.effective_start_date and pen.effective_end_date ;
  --
 --Added for Bug#5018328

  cursor c_crntly_enrd_flag(p_elig_pe_elctbl_chc_id number) is
   select epe.crntly_enrd_flag,ler.typ_cd
   from  ben_elig_per_elctbl_chc epe,
         ben_ler_f ler,
	 ben_prtt_enrt_rslt_f pen
   where epe.per_in_ler_id=p_per_in_ler_id
   and   epe.elig_per_elctbl_chc_id=p_elig_pe_elctbl_chc_id
   and   epe.prtt_enrt_rslt_id=pen.prtt_enrt_rslt_id
   and   pen.per_in_ler_id=p_per_in_ler_id
   and   pen.ler_id = ler.ler_id
   and   nvl(epe.erlst_deenrt_dt,hr_api.g_sot) > p_effective_date;

  l_crntly_enrd_flag  varchar2(10);
  l_ler_type_cd varchar2(20);

 --Added for Bug#5018328

  cursor c_crntly_enrd_flag_unres(p_elig_pe_elctbl_chc_id number) is
   select ler.typ_cd
   from   ben_prtt_enrt_rslt_f pen,
          ben_elig_per_elctbl_chc epe,
          ben_ler_f ler
   where epe.elig_per_elctbl_chc_id=p_elig_pe_elctbl_chc_id
   and   epe.per_in_ler_id=p_per_in_ler_id
   and   pen.ler_id = ler.ler_id
   and   epe.prtt_enrt_rslt_id=pen.prtt_enrt_rslt_id
   and   pen.per_in_ler_id=p_per_in_ler_id
   and   nvl(epe.erlst_deenrt_dt,hr_api.g_sot) > p_effective_date;

  l_typ_cd varchar2(20);
  --

  --5663280
  cursor c_check_carry_fwd_enrt(p_prtt_enrt_rslt_id number,
                                p_per_in_ler_id number,
                                p_enrt_cvg_strt_dt date,
                                p_effective_start_date date) is
    select 'Y'
    from   ben_prtt_enrt_rslt_f pen
    where  pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
    and    pen.prtt_enrt_rslt_stat_cd is null
    and    pen.enrt_cvg_thru_dt = to_date('4712/12/31','rrrr/mm/dd')
    and    pen.per_in_ler_id <> p_per_in_ler_id
    and    pen.enrt_cvg_strt_dt = p_enrt_cvg_strt_dt
    and    pen.effective_end_date < p_effective_start_date;

  l_check_carry_fwd_enrt varchar2(1);
  --

  -----Bug 6925893
  cursor c_get_old_prv is
    SELECT oldprv.prtt_rt_val_id,
       oldprv.prtt_rt_val_stat_cd ,
       oldprv.object_version_number,
       abr.input_value_id,
       abr.element_type_id
  FROM ben_prtt_rt_val oldprv,
       ben_prtt_rt_val curprv,
       ben_acty_base_rt_f abr
 WHERE curprv.business_group_id=oldprv.business_group_id
   AND curprv.per_in_ler_id = oldprv.ended_per_in_ler_id
   AND oldprv.rt_end_dt <> hr_api.g_eot
   AND oldprv.acty_base_rt_id = curprv.acty_base_rt_id
   AND oldprv.prtt_rt_val_stat_cd IS NULL
   and curprv.prtt_enrt_rslt_id=p_prtt_enrt_rslt_id
   AND abr.acty_base_rt_id = oldprv.acty_base_rt_id
   AND p_effective_date BETWEEN abr.effective_start_date
         AND abr.effective_end_date
   and oldprv.ended_per_in_ler_id= p_per_in_ler_id
   AND oldprv.business_group_id= p_business_group_id;

   l_get_old_prv  c_get_old_prv%ROWTYPE;
  ------------Bug 7209243
  --The cursor is written based on the assumption that there will be only plan per plan type
  --elected in a Life Event.
  cursor c_get_epe(p_pl_typ_id number) is
   SELECT epe.*
    FROM ben_prtt_enrt_rslt_f pen,
       ben_elig_per_elctbl_chc epe
   WHERE pen.per_in_ler_id = p_per_in_ler_id
     AND pen.business_group_id = p_business_group_id
     AND epe.per_in_ler_id = pen.per_in_ler_id
     AND epe.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
     and pen.pl_typ_id = p_pl_typ_id
     AND pen.effective_end_date = hr_api.g_eot
     AND pen.enrt_cvg_thru_dt = hr_api.g_eot
  ORDER BY pen.effective_start_date desc;
  l_get_epe c_get_epe%rowtype;

  cursor c_get_old_prv1 is
  SELECT distinct oldprv.prtt_rt_val_id, ---Bug 9290518
       oldprv.prtt_rt_val_stat_cd ,
       oldprv.object_version_number,
       abr.input_value_id,
       abr.element_type_id
  FROM ben_prtt_rt_val oldprv,
       ben_prtt_rt_val curprv,
       ben_acty_base_rt_f abr,
       ben_acty_base_rt_f abr2 ,
       ben_prtt_enrt_rslt_f pen
 WHERE curprv.business_group_id=oldprv.business_group_id
   AND curprv.per_in_ler_id = oldprv.ended_per_in_ler_id
   AND oldprv.rt_end_dt <> hr_api.g_eot
   AND oldprv.prtt_rt_val_stat_cd IS NULL
   AND abr.acty_base_rt_id = oldprv.acty_base_rt_id
   AND p_effective_date BETWEEN abr.effective_start_date
         AND abr.effective_end_date
   AND abr2.acty_base_rt_id = curprv.acty_base_rt_id
   AND p_effective_date BETWEEN abr2.effective_start_date
         AND abr2.effective_end_date
   AND oldprv.acty_base_rt_id <> curprv.acty_base_rt_id
   and oldprv.ended_per_in_ler_id= p_per_in_ler_id
   AND oldprv.business_group_id= p_business_group_id
   AND pen.per_in_ler_id = oldprv.per_in_ler_id
   AND pen.prtt_enrt_rslt_id = oldprv.prtt_enrt_rslt_id
   AND pen.business_group_id = p_business_group_id
   and curprv.prtt_enrt_rslt_id=p_prtt_enrt_rslt_id
   AND EXISTS (SELECT pen1.pl_typ_id
                 FROM ben_prtt_enrt_rslt_f pen1
                WHERE pen1.business_group_id = pen.business_group_id
                  AND pen1.per_in_ler_id = curprv.per_in_ler_id
                  AND pen1.pl_typ_id = pen.pl_typ_id
                  AND pen1.prtt_enrt_rslt_id = curprv.prtt_enrt_rslt_id
                  AND pen1.effective_end_date = hr_api.g_eot
                  AND pen1.enrt_cvg_thru_dt = hr_api.g_eot);
 -- l_get_old_prv1    c_get_old_prv1%rowtype;  ---Bug 9290518
  l_rt_strt_dt1                date;
  l_enrt_cvg_end_dt1           date;
  l_enrt_cvg_strt_dt1      date;
  l_rt_end_dt1                 date;
  ------------Bug 7209243
  --
  -- Bug No 5637595 Added to get the lf_evt_ocrd_dt of the pil
  --
  cursor get_lf_evt_dt is
   select lf_evt_ocrd_dt from
     ben_per_in_ler where
      per_in_ler_id = p_per_in_ler_id and
      per_in_ler_stat_cd not in ('VOIDD','BCKDT');
  l_lf_evt_ocrd_dt date;


--this is a fix for bug#:6641853 when
--in the scenario where there is a
--LE process and then the open process
--on the same day.
--The first LE is FONM and the person is enrolled
--then again the person enrolls on the same day for the open
--again the person chages the election on the other
--day, which voids the current enrollment.
--Now we check in the backup table to see
--if any correction has happened and then we
--dont void.
  cursor c_get_correction_info (cp_prtt_enrt_rslt_id NUMBER
                               ,cp_effective_date DATE
                               ,cp_per_in_ler_id NUMBER
                               ) IS
  SELECT 'X'  place_holder
   FROM ben_le_clsn_n_rstr bcr
  WHERE bcr.bkup_tbl_id=cp_prtt_enrt_rslt_id
    AND bcr.effective_start_date=cp_effective_date
   UNION
   SELECT 'X'  place_holder
   FROM ben_le_clsn_n_rstr bcr
  WHERE bcr.bkup_tbl_id=cp_prtt_enrt_rslt_id
    AND bcr.per_in_ler_id <> cp_per_in_ler_id
    AND bcr.bkup_tbl_typ_cd LIKE '%CORR' ;

l_get_correction_info c_get_correction_info%ROWTYPE;

  -- Local variable declaration.
  --
  -----Bug 9290518
  l_old_prv_found boolean := false;
  -----Bug 9290518
  l_temp_stat_cd            VARCHAR2(30);
  l_temp_date               DATE;
  l_proc                    varchar2(72); --  := g_package||'delete_enrollment';
  l_dpnt_cvg_end_dt         date;
  l_dpnt_cvg_thru_dt        date;
  l_dump_date               date;
  l_datetrack_mode          varchar2(20);
  l_step                    integer;
  l_tmp_ovn                 integer;
  l_enrt_cvg_strt_dt        date;
  l_enrt_cvg_strt_dt_cd     varchar2(30);
  l_enrt_cvg_strt_dt_rl     number;
  l_rt_strt_dt              date;
  l_rt_strt_dt_cd           varchar2(30);
  l_rt_strt_dt_rl           number;
  l_enrt_cvg_end_dt         date;
  l_enrt_cvg_end_dt_cd      varchar2(30);
  l_enrt_cvg_end_dt_rl      number;
  l_rt_end_dt               date;
  l_eff_dt                 date;
  l_rt_end_dt_cd            varchar2(30);
  l_rt_end_dt_rl            number;
  l_elig_per_elctbl_chc_id  number(15);
  l_new_enrt_cvg_strt_dt    date;
  l_date                    date;
  l_pil_id                  number;
  l_cvg_end_dt_cd           varchar2(30);
  l_dummy                   varchar2(1);
  l_rqd_perd_enrt_nenrt_uom varchar2(30);
  l_rqd_perd_enrt_nenrt_val number;
  l_rqd_perd_enrt_nenrt_rl  number;
  l_level                   varchar2(30);
  l_other_pen_rec           ben_prtt_enrt_rslt_f%rowtype;
  l_intm_other_rslt         varchar2(30) := 'N';
  l_new_enrollment          varchar2(1)  := 'N' ;
  l_object_version_number   number  ;
  --
  l_pl_rec         ben_cobj_cache.g_pl_inst_row;
  l_oipl_rec       ben_cobj_cache.g_oipl_inst_row;
  l_deenrol_dt              date;
  l_prv_count               number;
  l_env_rec              ben_env_object.g_global_env_rec_type;
  l_benmngle_parm_rec    benutils.g_batch_param_rec;
  l_enrt_perd_id             number ;
  l_lee_rsn_id               number := null ;
  /* Start of Changes WWBUG: 1646442: added             */
  l_ppe_dt_to_use           date;
  l_ppe_datetrack_mode      varchar2(30);
  /* End of Changes WWBUG: 1646442                      */
  l_ler_typ_cd              varchar2(30);
  l_pcp_effective_date    date;
  l_pcp_effective_start_date date;
  l_process_date             date;
  l_rplcs_sspndd_rslt_id     number;
  l_prtt_rt_val_stat_cd      varchar2(30);
  l_sub                      varchar2(300);
  l_prtt_enrt_rslt_Stat_cd   varchar2(300);
  l_adjust                   varchar2(1);
  prev_prtt_rt_val_id number := -1;                             -- Bug 5739530

/*Added for Bug 7561395*/
l_actn_start_date date;
l_actn_end_date date;
l_rslt_object_version_number number;
l_actn_object_version_number number;
l_prtt_enrt_actn_id number;
l_ctfn_start_date date;
l_ctfn_end_date date;
l_ctfn_object_version_number number;
l_prtt_enrt_ctfn_prvdd_id number;
l_act_flag boolean default false;
l_ctfn_flag boolean default false;
l_same_per_in_ler_id number;
l_dummy1 varchar2(1);
l_oper_in_ler_id number;
l_nper_in_ler_id number;

 cursor c_grt_new_ovn is
    select object_version_number from ben_prtt_enrt_rslt_f
    where prtt_enrt_rslt_id = g_new_prtt_enrt_rslt_id;

 cursor c_get_actn_items is
 select actn.* from ben_prtt_enrt_actn_f actn,
(select max(effective_start_date) max_effective_date,prtt_enrt_actn_id from ben_prtt_enrt_actn_f
    where prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
    and per_in_ler_id = p_per_in_ler_id
    and cmpltd_dt is not null --Bug 8669907: Get only the completed action items for creation
    group by prtt_enrt_actn_id) new_actn
where new_actn.max_effective_date=actn.effective_start_date
and new_actn.prtt_enrt_actn_id=actn.prtt_enrt_actn_id
and actn.cmpltd_dt is not null;

 l_act_items_rec c_get_actn_items%rowtype;
 TYPE l_act_items_table IS TABLE OF ben_prtt_enrt_actn_f%rowtype
 INDEX BY BINARY_INTEGER;
 l_act_items l_act_items_table;

cursor c_get_ctfn is
    select ctfn.* from ben_prtt_enrt_ctfn_prvdd_f ctfn,ben_prtt_enrt_actn_f actn,
(select max(effective_start_date) max_effective_date,prtt_enrt_actn_id,prtt_enrt_ctfn_prvdd_id
    from ben_prtt_enrt_ctfn_prvdd_f
    where prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
    group by prtt_enrt_actn_id,prtt_enrt_ctfn_prvdd_id) max_ctfn_rec
where ctfn.prtt_enrt_ctfn_prvdd_id=max_ctfn_rec.prtt_enrt_ctfn_prvdd_id
and ctfn.prtt_enrt_actn_id=max_ctfn_rec.prtt_enrt_actn_id
and ctfn.effective_start_date=max_ctfn_rec.max_effective_date
and actn.prtt_enrt_actn_id = ctfn.prtt_enrt_actn_id
and actn.cmpltd_dt is not null; -- Bug 8669907: Get only the completed action items for creation

cursor c_chk_same_event(c_prtt_enrt_rslt_id number) is
select per_in_ler_id from ben_prtt_enrt_rslt_f
where prtt_enrt_rslt_id = c_prtt_enrt_rslt_id
and prtt_enrt_rslt_stat_cd is NULL;

l_ctfn_rec c_get_ctfn%rowtype;
 TYPE l_ctfn_table IS TABLE OF ben_prtt_enrt_ctfn_prvdd_f%rowtype
 INDEX BY BINARY_INTEGER;
 l_ctfn l_ctfn_table;

cursor c_chk_act_item_exits(c_prtt_enrt_rslt_id number) is
select '1' from ben_prtt_enrt_actn_f actn
where actn.prtt_enrt_rslt_id=c_prtt_enrt_rslt_id;

/* Added for Bug 8669907 */
cursor c_chk_same_comp_obj(c_new_pen_id number,c_old_pen_id number,c_per_in_ler_id number) is
select 'Y' from
  ben_prtt_enrt_rslt_f new_pen,
  ben_prtt_enrt_rslt_f old_pen
where new_pen.prtt_enrt_rslt_id = c_new_pen_id
      and old_pen.prtt_enrt_rslt_id = c_old_pen_id
      and old_pen.per_in_ler_id = c_per_in_ler_id
      and new_pen.per_in_ler_id = c_per_in_ler_id
      and nvl(old_pen.pgm_id,-1) = nvl(new_pen.pgm_id,-1)
      and nvl(old_pen.pl_id,-1) = nvl(new_pen.pl_id,-1)
      and nvl(old_pen.oipl_id,-1) = nvl(new_pen.oipl_id,-1)
      and old_pen.pl_typ_id = new_pen.pl_typ_id;

cursor c_bnft_amt(c_prtt_enrt_rslt_id number,c_per_in_ler_id number) is
select bnft_amt,
       mn_val,
       mx_val ,
       entr_val_at_enrt_flag,
       cvg_mlt_cd,
       mx_wout_ctfn_val
from ben_enrt_bnft bnft,
     ben_elig_per_elctbl_chc epe,
     ben_prtt_enrt_rslt_f pen
where epe.prtt_enrt_rslt_id = c_prtt_enrt_rslt_id
      and epe.per_in_ler_id = c_per_in_ler_id
      and pen.per_in_ler_id = c_per_in_ler_id
      and pen.prtt_enrt_rslt_id = epe.prtt_enrt_rslt_id
      and epe.elig_per_elctbl_chc_id = bnft.elig_per_elctbl_chc_id;

l_bnft c_bnft_amt%rowtype;
l_create_flag varchar2(1) default 'N';
l_sspnd_flag varchar2(1) default 'N';
/*End of Bug 8669907 */

/*Ended for Bug 7561395*/

  --
   ------------Bug 8222481
  cursor c_get_last_pil(p_person_id number,p_pen_id number) is
  SELECT pil.per_in_ler_id
  FROM ben_per_in_ler pil
 WHERE pil.per_in_ler_stat_cd = 'PROCD'
   AND pil.lf_evt_ocrd_dt = (SELECT Max(pil1.lf_evt_ocrd_dt)
                           FROM ben_per_in_ler pil1,
			        ben_prtt_enrt_rslt_f pen          ------------Bug 8688513
                          WHERE pil1.person_id = pil.person_id
                            AND pil1.per_in_ler_stat_cd = 'PROCD'
			    AND pen.prtt_enrt_rslt_id = p_pen_id
                            AND pen.prtt_enrt_rslt_stat_cd IS NULL
                            AND pen.per_in_ler_id = pil1.per_in_ler_id
                            AND pen.enrt_cvg_thru_dt >= pen.enrt_cvg_strt_dt
			    )
   and pil.person_id = p_person_id ;
  l_get_last_pil   c_get_last_pil%rowtype;
  cursor c_get_ended_pen(p_per_in_ler_id number,
                         p_pl_typ_id number,
			 p_pgm_id number) is
   SELECT *
  FROM ben_prtt_enrt_rslt_f pen
 WHERE pen.per_in_ler_id = p_per_in_ler_id
   AND pen.pl_typ_id = p_pl_typ_id
   AND pen.pgm_id = p_pgm_id
   AND enrt_cvg_thru_dt <> hr_api.g_eot
   AND pen.prtt_enrt_rslt_stat_cd IS NULL;

   type l_get_ended_pen1 is table of c_get_ended_pen%rowtype;
   l_get_ended_pen  l_get_ended_pen1;

   cursor c_last_pil_pen(p_per_in_ler_id number,p_pen_id number) is
    SELECT *
     FROM ben_prtt_enrt_rslt_f pen
    WHERE pen.per_in_ler_id = p_per_in_ler_id
      AND pen.prtt_enrt_rslt_id = p_pen_id
     AND pen.prtt_enrt_rslt_stat_cd IS NULL;

     l_last_pil_pen  c_last_pil_pen%rowtype;

   cursor c_last_pil_pen1(p_per_in_ler_id number,
                          p_pl_id number,
			  p_pgm_id number) is
    SELECT *
     FROM ben_prtt_enrt_rslt_f pen
    WHERE pen.per_in_ler_id = p_per_in_ler_id
      AND pen.pl_id = p_pl_id
      and pen.pgm_id = p_pgm_id
     AND pen.prtt_enrt_rslt_stat_cd IS NULL;

     l_last_pil_pen1  c_last_pil_pen1%rowtype;

     l_del_next_chg_pen  c_last_pil_pen1%rowtype;
  ----------------Bug 8222481
  procedure void_rate (p_prtt_enrt_rslt_id number,
                       p_business_group_id number,
                       p_person_id         number,
                       p_per_in_ler_id     number,
                       p_effective_date  date) is
      --
      --Bug 3412562 Doesn't look like we need link to ben_enrt_rt table here.
      --
     cursor c_prv is
        select prv.prtt_rt_val_id
               ,prv.object_version_number
               ,prv.acty_base_rt_id
               ,abr.element_type_id
               ,abr.input_value_id
               ,prv.rt_strt_dt
         from ben_prtt_rt_val prv
             ,ben_acty_base_rt_f abr
         where prv.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
	 -- bug: 5550679
	 and prv.per_in_ler_id = p_per_in_ler_id
	 --
         and   prv.prtt_rt_val_stat_cd is null
         and prv.business_group_id = p_business_group_id
         and prv.acty_base_rt_id = abr.acty_base_rt_id
         and p_effective_date between abr.effective_start_date
                  and abr.effective_end_date
         order by prv.rt_strt_dt desc;
     l_prv   c_prv%rowtype;

   begin
     --
     For l_prv in c_prv loop
        ben_prtt_rt_val_api.update_prtt_rt_val
            (P_VALIDATE                => FALSE
            ,P_PRTT_RT_VAL_ID          => l_prv.prtt_rt_val_id
            ,P_RT_END_DT               => (l_prv.rt_strt_dt - 1)
            ,p_person_id               => p_person_id
            ,p_input_value_id          => l_prv.input_value_id
            ,p_element_type_id         => l_prv.element_type_id
            ,p_ended_per_in_ler_id     => p_per_in_ler_id
            ,p_prtt_rt_val_stat_cd     => 'VOIDD'
            ,p_business_group_id       => p_business_group_id
            ,P_OBJECT_VERSION_NUMBER   => l_prv.object_version_number
            ,P_EFFECTIVE_DATE          => p_effective_date
            );
      end loop;
      --
   end;


--
begin
  g_debug := hr_utility.debug_enabled;

  if g_debug then
     l_proc := g_package||'delete_enrollment';
     hr_utility.set_location('Entering:'|| l_proc, 10);
     hr_utility.set_location('p_prtt_enrt_rslt_id'||
      to_char(p_prtt_enrt_rslt_id),10);
  end if;

  /* Added for Bug 7561395*/
  open c_grt_new_ovn;
  fetch c_grt_new_ovn into l_rslt_object_version_number;
  close c_grt_new_ovn;
  /* Ended for Bug 7561395*/

  --
  -- Issue a savepoint if operating in validation only mode
  --
  if p_source is null or
     p_source <> 'delete_enrollment'  then
    --
    -- Do not issue the savepoint if this procedure called itself.
    --
    savepoint delete_enrollment;
    --
  end if;
  --
  -- Work out if we are being called from a concurrent program
  -- otherwise we need to initialize the environment
  --
  ben_env_object.get(p_rec => l_env_rec);
  if fnd_global.conc_request_id in (0,-1) then
    --bug#3568529
    -- ben_env_object.get(p_rec => l_env_rec);
    if l_env_rec.benefit_action_id is null then
    --
       hr_utility.set_location('Intialise env object',11);
       ben_env_object.init(p_business_group_id  => p_business_group_id,
                           p_effective_date     => p_effective_date,
                           p_thread_id          => 1,
                           p_chunk_size         => 1,
                           p_threads            => 1,
                           p_max_errors         => 1,
                           p_benefit_action_id  => null);
   end if;
   --
  else
     -- to check whether it is called in benmngle selection mode
     ben_env_object.get(p_rec => l_env_rec);
     --
     -- If enrollment api's are called from concurrent manager for
     -- conversion or ivr kind of interfaces, call raises error.
     --
     if l_env_rec.benefit_action_id is not null then

        benutils.get_batch_parameters(p_benefit_action_id => l_env_rec.benefit_action_id
                                   ,p_rec => l_benmngle_parm_rec);
     end if;
    --
  end if;
  --
  --bug#3714789 - the effective date is manipulated in beninelg and in selection
  --mode the lf evt ocrd dt is null- the actual effective date of the process is
  --used for coverage end date determination mode
  if p_per_in_ler_id is null and l_benmngle_parm_rec.process_date is not null then
     --
     l_process_date  := l_benmngle_parm_rec.process_date;
     --
  else
     --
     l_process_date  := p_effective_date;
     --
  end if;
  --
  l_step := 10;
  --
  open c_pen;
  fetch c_pen into l_pen;
  if c_pen%notfound then
    close c_pen;
    rpt_error(p_proc => l_proc, p_step => l_step);
    fnd_message.set_name('BEN','BEN_91711_ENRT_RSLT_NOT_FND');
    fnd_message.set_token('ID', to_char(p_prtt_enrt_rslt_id));
    fnd_message.set_token('PROC',l_proc);
    fnd_message.set_token('PERSON_ID', null);
    fnd_message.set_token('LER_ID', null);
    fnd_message.set_token('EFFECTIVE_DATE',to_char(p_effective_date));
--    fnd_message.raise_error;
    raise l_fnd_message_exception;

  end if;
  close c_pen;
  --

  --Bug 2739965 we need this for unrestricted also.
  --
  open c_ler ;
    fetch c_ler into l_ler_typ_cd ;
  close c_ler ;

   ---Bug 7458990
  /*  open c_crntly_enrd_flag(l_pen.elig_per_elctbl_chc_id);
     fetch c_crntly_enrd_flag into l_crntly_enrd_flag,l_ler_type_cd;
    close c_crntly_enrd_flag;

   --Bug#5018328
    if l_crntly_enrd_flag = 'Y' and l_ler_type_cd <> 'SCHEDDU'  then
     fnd_message.set_name('BEN','BEN_91902_ENRT_NOT_ALWD_DELETE');
     fnd_message.set_token('PLANNAMEANDOPTIONNAME',l_pen.pl_name || ' '||l_pen.opt_name );
     fnd_message.set_token('EARLIESTDEENROLLMENTDATE',fnd_date.date_to_chardate(l_pen.erlst_deenrt_dt));
--   fnd_message.raise_error;
    raise l_fnd_message_exception;
   end if;

    open c_crntly_enrd_flag_unres(l_pen.elig_per_elctbl_chc_id);
     fetch c_crntly_enrd_flag_unres into l_typ_cd;
    close c_crntly_enrd_flag_unres;

   if l_typ_cd='SCHEDDU' then
     fnd_message.set_name('BEN','BEN_91902_ENRT_NOT_ALWD_DELETE');
     fnd_message.set_token('PLANNAMEANDOPTIONNAME',l_pen.pl_name || ' '||l_pen.opt_name );
     fnd_message.set_token('EARLIESTDEENROLLMENTDATE',fnd_date.date_to_chardate(l_pen.erlst_deenrt_dt));
--   fnd_message.raise_error;
    raise l_fnd_message_exception;
   end if;  */
   ---Bug 7458990


  --Bug#5018328
  -----bug :1527086
  -- calcaulte the coverage end date to check the ERLST_DEENRT_DT
  -- this part is moved from updation part

  -- If Electable choice ID is not passed, then per_in_ler, and either
  -- Enrt_perd_id or Lee_rsn_id need to be passed.
  --
  l_step := 14;
  If ( nvl(l_pen.per_in_ler_id, -1) <> nvl(p_per_in_ler_id,-1) ) then
     l_elig_per_elctbl_chc_id := NULL;
  Else
     --
     --Bug 5567840 added check for imputed income plan
     if l_pen.auto_enrt_flag = 'Y' and l_pen.elctbl_flag = 'N' and l_pen.imptd_incm_calc_cd is null then
       --
       fnd_message.set_name('BEN','BEN_94596_DEENROL_NOT_ALL');
       fnd_message.set_token('PLANNAME', l_pen.pl_name);
--       fnd_message.raise_error;
       raise l_fnd_message_exception;

       --
     end if;
     --
     l_elig_per_elctbl_chc_id := l_pen.elig_per_elctbl_chc_id;
  End if;
  l_pen.per_in_ler_id := p_per_in_ler_id;
  --
  ben_global_enrt.get_pil
       (p_per_in_ler_id          => p_per_in_ler_id
       ,p_global_pil_rec         => l_global_pil_rec);

  -- bug 4616225 : cache built on date,de-enrollment date of a plan,may not have
  -- correct comp objects built.So,life event occured date to be considered first .
  -- And so both get_pl_dets,get_oipl_dets calls are moved down and are called after
  -- ben_global_enrt.get_pil call.
  ben_cobj_cache.get_pl_dets
     (p_business_group_id => p_business_group_id
     ,p_effective_date    => nvl(l_global_pil_rec.lf_evt_ocrd_dt,p_effective_date)
     ,p_pl_id             => l_pen.pl_id
     ,p_inst_row          => l_pl_rec);

  if l_pen.oipl_id is not null then
    ben_cobj_cache.get_oipl_dets
       (p_business_group_id => p_business_group_id
       ,p_effective_date    =>  nvl(l_global_pil_rec.lf_evt_ocrd_dt,p_effective_date) --
       ,p_oipl_id           => l_pen.oipl_id
       ,p_inst_row          => l_oipl_rec);
  end if;
  -- end bug 4616225
  if l_global_pil_rec.person_id is not null then
    l_pen.person_id := l_global_pil_rec.person_id;
    l_pen.ler_id    := l_global_pil_rec.ler_id;
  end if;
  -- 2386000 Find lee_rsn_id at popl level
  if l_elig_per_elctbl_chc_id is null then
    if l_pen.elig_per_elctbl_chc_id is not null then
      open c_pel(l_pen.elig_per_elctbl_chc_id);
        fetch c_pel into l_enrt_perd_id,l_lee_rsn_id ;
      close c_pel ;
    end if;
    -- If not found find at plan level
    if l_lee_rsn_id is null then
      open c_lee_rsn_for_plan(l_pen.ler_id, l_pen.pl_id,p_effective_date );
        fetch c_lee_rsn_for_plan into l_lee_rsn_id ;
      close c_lee_rsn_for_plan ;
    end if ;
    --
    if l_lee_rsn_id is null and l_pen.pgm_id is not null then
      open c_lee_rsn_for_program(l_pen.ler_id, l_pen.pgm_id,p_effective_date);
        fetch c_lee_rsn_for_program into l_lee_rsn_id ;
      close c_lee_rsn_for_program ;
    end if;
  end if ;
  -- Locate end date and rate codes and rules for participant.
  l_step := 30;
  /* Bug 2386000
    l_elig_per_elctbl_chc_id is passed as null we need to pass these ids to
    rate_and_coverage_dates procedure.
    p_pl_id;
    p_pgm_id;
    p_enrt_perd_id;
    p_lee_rsn_id;
    p_oipl_id;
    p_per_in_ler_id;
    p_person_id;
  */
  --- Determine FONM for  delete enrollment
  if  nvl( ben_manage_life_events.fonm,'N')  = 'Y'  then

      if l_pen.fonm_cvg_strt_dt is not null then
         if l_pen.fonm_cvg_strt_dt <> ben_manage_life_events.g_fonm_cvg_strt_dt then
            ben_manage_life_events.g_fonm_cvg_strt_dt := l_pen.fonm_cvg_strt_dt ;
         end if ;

      else
        -- set theflag and date to null
         ben_manage_life_events.fonm := 'N';
         ben_manage_life_events.g_fonm_cvg_strt_dt := null;
         ben_manage_life_events.g_fonm_rt_strt_dt := null;

      end if ;
  else
     if l_pen.fonm_cvg_strt_dt is not null then
        ben_manage_life_events.fonm := 'Y';
        ben_manage_life_events.g_fonm_cvg_strt_dt := l_pen.fonm_cvg_strt_dt ;
     else
        ben_manage_life_events.fonm := 'N';
        ben_manage_life_events.g_fonm_cvg_strt_dt := null;
        ben_manage_life_events.g_fonm_rt_strt_dt := null;
     end if ;
  end if  ;
  hr_utility.set_location (' FONM ' ||  ben_manage_life_events.fonm , 99 ) ;
  hr_utility.set_location (' FONM CVG  ' ||  ben_manage_life_events.g_fonm_cvg_strt_dt , 99 ) ;
  -- eof FONM

  ben_determine_date.rate_and_coverage_dates
      (p_which_dates_cd         => 'C'
      ,p_date_mandatory_flag    => 'N'
      ,p_compute_dates_flag     => 'N'
      ,p_elig_per_elctbl_chc_id => l_elig_per_elctbl_chc_id
      ,p_business_group_id      => l_pen.business_group_id
      ,P_PER_IN_LER_ID          => l_pen.per_in_ler_id
      ,P_PERSON_ID              => l_pen.person_id
      ,P_PGM_ID                 => l_pen.pgm_id
      ,P_PL_ID                  => l_pen.pl_id
      ,P_OIPL_ID                => l_pen.oipl_id
      ,P_LEE_RSN_ID             => nvl(p_lee_rsn_id,l_lee_rsn_id)   -- 2386000
      ,P_ENRT_PERD_ID           => nvl(p_enrt_perd_id,l_enrt_perd_id) -- 2386000
      ,p_enrt_cvg_strt_dt       => l_enrt_cvg_strt_dt
      ,p_enrt_cvg_strt_dt_cd    => l_enrt_cvg_strt_dt_cd
      ,p_enrt_cvg_strt_dt_rl    => l_enrt_cvg_strt_dt_rl
      ,p_rt_strt_dt             => l_rt_strt_dt
      ,p_rt_strt_dt_cd          => l_rt_strt_dt_cd
      ,p_rt_strt_dt_rl          => l_rt_strt_dt_rl
      ,p_enrt_cvg_end_dt        => l_enrt_cvg_end_dt
      ,p_enrt_cvg_end_dt_cd     => l_enrt_cvg_end_dt_cd
      ,p_enrt_cvg_end_dt_rl     => l_enrt_cvg_end_dt_rl
      ,p_rt_end_dt              => l_rt_end_dt
      ,p_rt_end_dt_cd           => l_rt_end_dt_cd
      ,p_rt_end_dt_rl           => l_rt_end_dt_rl
      ,p_effective_date         => nvl(l_global_pil_rec.lf_evt_ocrd_dt,l_process_date)    --p_effective_date
      );
    --
  l_cvg_end_dt_cd := l_enrt_cvg_end_dt_cd;
  --
  -- If called in the special mode which allows the cvg_thru_dt to be entered,
  -- the cvg_thru_dt_cd should be 'ENTRBL'. If it is not,no processing required.
  --
  if p_mode = 'CVG_END_DATE_ENTERABLE' and
     nvl(l_enrt_cvg_end_dt_cd, 'XXX') <> 'ENTRBL' then
     return;
  end if;

    --
  ben_determine_date.rate_and_coverage_dates
      (p_elig_per_elctbl_chc_id => l_elig_per_elctbl_chc_id
      ,p_business_group_id      => l_pen.business_group_id
      ,P_PER_IN_LER_ID          => l_pen.per_in_ler_id
      ,P_PERSON_ID              => l_pen.person_id
      ,P_PGM_ID                 => l_pen.pgm_id
      ,P_PL_ID                  => l_pen.pl_id
      ,P_OIPL_ID                => l_pen.oipl_id
      ,P_LEE_RSN_ID             => nvl(p_lee_rsn_id,l_lee_rsn_id)
      ,P_ENRT_PERD_ID           => nvl(p_enrt_perd_id,l_enrt_perd_id)
      ,p_enrt_cvg_strt_dt       => l_enrt_cvg_strt_dt
      ,p_enrt_cvg_strt_dt_cd    => l_enrt_cvg_strt_dt_cd
      ,p_enrt_cvg_strt_dt_rl    => l_enrt_cvg_strt_dt_rl
      ,p_rt_strt_dt             => l_rt_strt_dt
      ,p_rt_strt_dt_cd          => l_rt_strt_dt_cd
      ,p_rt_strt_dt_rl          => l_rt_strt_dt_rl
      ,p_enrt_cvg_end_dt        => l_enrt_cvg_end_dt
      ,p_enrt_cvg_end_dt_cd     => l_enrt_cvg_end_dt_cd
      ,p_enrt_cvg_end_dt_rl     => l_enrt_cvg_end_dt_rl
      ,p_rt_end_dt              => l_rt_end_dt
      ,p_rt_end_dt_cd           => l_rt_end_dt_cd
      ,p_rt_end_dt_rl           => l_rt_end_dt_rl
      ,p_effective_date         => nvl(l_global_pil_rec.lf_evt_ocrd_dt,l_process_date)   --p_effective_date
      ,p_end_date               => p_enrt_cvg_thru_dt
      );
  --
  ----Bug 6925893
  if  (substr(nvl(l_rt_end_dt_cd, 'X'), 1, 1) = 'W' or
          substr(nvl(l_rt_end_dt_cd, 'X'), 1, 2) = 'LW' or              ------Bug 7209243
          l_rt_end_dt_cd in ('LDPPOEFD','LDPPFEFD','LODBEWM','ODBEWM')) ------Bug 7209243
	   and l_ler_typ_cd not in ('IREC','GSP','COMP','ABS','SCHEDDU') then
    --determine new rt start date
	      ben_determine_date.rate_and_coverage_dates
		 (p_elig_per_elctbl_chc_id => l_elig_per_elctbl_chc_id
		 ,p_business_group_id      => l_pen.business_group_id
		 ,P_PER_IN_LER_ID          => l_pen.per_in_ler_id
		 ,P_PERSON_ID              => l_pen.person_id
		 ,P_PGM_ID                 => l_pen.pgm_id
		 ,P_PL_ID                  => l_pen.pl_id
		 ,P_OIPL_ID                => l_pen.oipl_id
		 ,P_LEE_RSN_ID             => nvl(p_lee_rsn_id,l_lee_rsn_id)
		 ,P_ENRT_PERD_ID           => nvl(p_enrt_perd_id,l_enrt_perd_id)
		 ,p_enrt_cvg_strt_dt       => l_enrt_cvg_strt_dt
		 ,p_enrt_cvg_strt_dt_cd    => l_enrt_cvg_strt_dt_cd
		 ,p_enrt_cvg_strt_dt_rl    => l_enrt_cvg_strt_dt_rl
		 ,p_rt_strt_dt             => l_rt_strt_dt
		 ,p_rt_strt_dt_cd          => l_rt_strt_dt_cd
		 ,p_rt_strt_dt_rl          => l_rt_strt_dt_rl
		 ,p_enrt_cvg_end_dt        => l_enrt_cvg_end_dt
		 ,p_enrt_cvg_end_dt_cd     => l_enrt_cvg_end_dt_cd
		 ,p_enrt_cvg_end_dt_rl     => l_enrt_cvg_end_dt_rl
		 ,p_rt_end_dt              => l_rt_end_dt
		  ,p_rt_end_dt_cd           => l_rt_end_dt_cd
		  ,p_rt_end_dt_rl           => l_rt_end_dt_rl
		  ,p_effective_date         => p_effective_date
		  ,p_end_date               => p_enrt_cvg_thru_dt
		  );
  end if;
  -----Bug 6925893
  if l_cvg_end_dt_cd = 'ENTRBL' and
     p_enrt_cvg_thru_dt is not null then
     l_enrt_cvg_end_dt := p_enrt_cvg_thru_dt;
  end if;

  -----bug :1527086


  -- Check ERLST_DEENRT_DT
  --
  l_step := 15;

  if p_source = 'beninelg' then
     --
     -- If called from newly ineligible package (beninelg), the comp-obejct
     -- need to de-enrolled even if there is a locking period.
     -- **** By-pass the check.
     --
     null;
     --
     --elsif (p_effective_date < nvl(l_pen.erlst_deenrt_dt,hr_api.g_sot) and
     -- on the erlst_deenrt_dt then deenrt is allowd so -1 is compared
     if g_debug then
        hr_utility.set_location('cvg end dt ' || l_enrt_cvg_end_dt , 7086);
        hr_utility.set_location('denrt  ' || l_pen.erlst_deenrt_dt , 7086);
     end if;
  elsif (l_enrt_cvg_end_dt <  nvl(l_pen.erlst_deenrt_dt,hr_api.g_sot)-1  and
         l_pen.sspndd_flag = 'N' /*and  p_effective_date > l_pen.enrt_cvg_strt_dt */) then
    --
    -- Must now check if can deenroll legally.  If an enrollment is
    -- found for the level at which the the required period of enrollment
    -- was defined where the per_in_ler is different, then delete is OK
    --
    -- Find the required period of enrollment code/rule/uom/level defined at

    --Removed because the below condition is satisfied always.Bug : 6683229

    /* if l_other_pen_rec.prtt_enrt_rslt_id is null then
          fnd_message.set_name('BEN','BEN_91902_ENRT_NOT_ALWD_DELETE');
          fnd_message.set_token('PLANNAMEANDOPTIONNAME',l_pen.pl_name || ' '||l_pen.opt_name );
          fnd_message.set_token('EARLIESTDEENROLLMENTDATE',fnd_date.date_to_chardate(l_pen.erlst_deenrt_dt));
--          fnd_message.raise_error;
          raise l_fnd_message_exception;
       End if;
    */
    --- Bug : 6683229

    ben_enrolment_requirements.find_rqd_perd_enrt(
                   p_oipl_id                 =>l_pen.oipl_id
                   ,p_opt_id                  =>l_pen.opt_id
                   ,p_pl_id                   =>l_pen.pl_id
                   ,p_ptip_id                 =>l_pen.ptip_id
                   ,p_effective_date          =>p_effective_date
                   ,p_business_group_id       =>p_business_group_id
                   ,p_rqd_perd_enrt_nenrt_uom =>l_rqd_perd_enrt_nenrt_uom
                   ,p_rqd_perd_enrt_nenrt_val =>l_rqd_perd_enrt_nenrt_val
                   ,p_rqd_perd_enrt_nenrt_rl  =>l_rqd_perd_enrt_nenrt_rl
                   ,p_level                   =>l_level
    );

    ---after getting the level chek enrollemnt is not new one or
    --- processed (for over riding) then then chek any other election before error

    l_new_enrollment := 'N' ;
    if l_level = 'PTIP' then
        open c_rslt_ptip( l_pen.person_id ,
                     l_pen.pgm_id    ,
                     l_pen.ptip_id    ,
                     l_pen.per_in_ler_id ,
                     p_effective_date
                    );

       fetch c_rslt_ptip into l_dummy ;
       if c_rslt_ptip%notfound  then
          l_new_enrollment := 'Y' ;
       end if ;
       close  c_rslt_ptip ;
    elsif l_level = 'PL' then
       if g_debug then
          hr_utility.set_location('in pl level' , 161);
       end if;
       open  c_rslt_pl(l_pen.person_id ,
                     l_pen.pgm_id    ,
                     l_pen.pl_id     ,
                     l_pen.per_in_ler_id  ,
                     p_effective_date
                    ) ;

        fetch c_rslt_pl into l_dummy ;
        if c_rslt_pl%notfound  then
           l_new_enrollment := 'Y' ;
        end if ;
        close  c_rslt_pl ;
    else  -- OPT,OIPL
       if g_debug then
          hr_utility.set_location('per in ler  ' || l_pen.per_in_ler_id,161);
          hr_utility.set_location('start date ' || l_pen.effective_start_date,161);
          hr_utility.set_location('in opt level' , 161);
       end if;
       open  c_rslt_opt ( l_pen.person_id  ,
             l_pen.pgm_id    ,
             l_pen.pl_id     ,
             l_pen.oipl_id   ,
             l_pen.per_in_ler_id,
             p_effective_date
        ) ;

        fetch c_rslt_opt into l_dummy ;
        if c_rslt_opt%notfound  then
           l_new_enrollment := 'Y' ;
        end if ;
        close  c_rslt_opt ;
    end if;
    if g_debug then
       hr_utility.set_location(' l_new_enrollment ' || l_new_enrollment , 161 );
    end if;
    if (l_new_enrollment <>  'Y'  or  l_pen.per_in_ler_stat_cd = 'PROCD') then
       --
       -- Got level now see if other enrt in level exists
       --
       ben_enrolment_requirements.find_enrt_at_same_level(
       p_person_id               =>l_pen.person_id
      ,p_opt_id                  =>l_pen.opt_id
      ,p_oipl_id                 =>l_pen.oipl_id
      ,p_pl_id                   =>l_pen.pl_id
      ,p_ptip_id                 =>l_pen.ptip_id
      ,p_pl_typ_id               =>l_pen.pl_typ_id
      ,p_pgm_id                  =>l_pen.pgm_id
      ,p_effective_date          =>p_effective_date
      ,p_business_group_id       =>p_business_group_id
      ,p_prtt_enrt_rslt_id       =>p_prtt_enrt_rslt_id
      ,p_level                   =>l_level
      ,p_pen_rec                 =>l_other_pen_rec
       );
      if g_debug then
       hr_utility.set_location('result ' || l_other_pen_rec.prtt_enrt_rslt_id ,161);
      end if;
       if l_other_pen_rec.prtt_enrt_rslt_id is null/* or l_crntly_enrd_flag='Y'*/ then  -------7458990
         hr_utility.set_location('entering',9999);
          fnd_message.set_name('BEN','BEN_91902_ENRT_NOT_ALWD_DELETE');
          fnd_message.set_token('PLANNAMEANDOPTIONNAME',l_pen.pl_name || ' '||l_pen.opt_name );
          fnd_message.set_token('EARLIESTDEENROLLMENTDATE',fnd_date.date_to_chardate(l_pen.erlst_deenrt_dt));
--          fnd_message.raise_error;
          raise l_fnd_message_exception;

       End if;
    end if ;
    --
  end if;
  --
  -- Check if coverage has started.  If coverage has started, then
  -- the coverage end date is updated and the enrollment result is
  -- updated with the coverage end date.
  --
  -- There are 4 cases:
  --     Case 1: Coverage started, Coverage Elected and delete in same day.
  --               * void result and its rates.
  --     Case 2: Coverage Started, Coverage Elected and delete but not in same
  --             day.  (Elected earlier before Today)
  --               * Calculate its coverage end date.
  --     Case 3: Coverage not started yet. Elected and deleted in same day.
  --               * Date-track end dated.
  --     Case 4: Coverage not started yet. Elected and deleted not in same day.
  --               * Date-track end dated.
  --
  --  There is one more case - Bug#5123
  --             Coverage started, Coverage Ended and no election is possible
  --             Coverage Ended on account of newly Ineligible - This procedure
  --             called for imputed income plan when election is made and the
  --             row need not be Date-tracked
  --
  -- (maagrawa Jan 05,2001).
  -- One special modification is made here.
  -- When the coverage through date is allowed to be entered, then we need to
  -- always update the result by updating it with that date irrespective
  -- of when the coverage starts and when the elections are made.
  --

  hr_utility.set_location('p_effective_date  '|| to_char(p_effective_date) , 100);
  hr_utility.set_location('l_pen.ENRT_CVG_STRT_DT  '|| to_char(l_pen.ENRT_CVG_STRT_DT) , 100);
  hr_utility.set_location('l_pen.enrt_cvg_thru_dt  '|| to_char(l_pen.enrt_cvg_thru_dt) , 100);
  hr_utility.set_location('enrt_cvg_start_dt tilak  '||  l_enrt_cvg_strt_dt  , 100);
  hr_utility.set_location('enrt_cvg_start_dt tilak  '||  l_enrt_cvg_strt_dt  , 100);
  hr_utility.set_location('prtt_id  tilak  '||  p_prtt_enrt_rslt_id  , 100);
  hr_utility.set_location('PLIPID   tilak  '||  l_pen.per_in_ler_id  , 100);
  hr_utility.set_location('PLIPID   tilak  '||  l_pen.pen_per_in_ler_id  , 100);
  hr_utility.set_location('p_mode  '|| p_mode , 100);

  -- future enrollment is deleted
  -- copy the data into backup table

  if  l_enrt_cvg_strt_dt <  l_pen.enrt_cvg_strt_dt  and  l_pen.enrt_cvg_strt_dt < l_pen.enrt_cvg_thru_dt
        and l_pen.pen_per_in_ler_id <> l_pen.per_in_ler_id   then
         ben_back_out_life_event.back_out_life_events
           (p_per_in_ler_id           => l_pen.pen_per_in_ler_id ,
            p_bckt_per_in_ler_id      => l_pen.per_in_ler_id ,  --Bug 5859714
            p_bckt_stat_cd            => null ,
            p_business_group_id       => p_business_group_id,
            p_bckdt_prtt_enrt_rslt_id => p_prtt_enrt_rslt_id,
            p_copy_only               => 'Y' ,
            p_effective_date          => p_effective_date) ;
  end if ;
  l_step := 20;
  --
  -- Bug No 5637595 Moved the get_election date before if check as
  -- p_pil_id is required in if condition. Also added more checks to
  -- to see that for future dates coverages, if change of enrollment is done
  -- then previous end-dated coverage pen record should not be backout out.
  -- i.e. for this case code should go in Case 1 or Case 2 and not later ones.
  --
  Get_election_date(p_effective_date    => p_effective_date
                   ,p_prtt_enrt_rslt_id => p_prtt_enrt_rslt_id
                   ,p_business_group_id => p_business_group_id
                   ,p_date => l_date
                   ,p_pil_id => l_pil_id
                   );
  --
  open get_lf_evt_dt;
  fetch get_lf_evt_dt into l_lf_evt_ocrd_dt;
     if get_lf_evt_dt%NOTFOUND then
        l_lf_evt_ocrd_dt := p_effective_date;
     end if;
  close get_lf_evt_dt;
  --
  If ((p_effective_date between
      l_pen.ENRT_CVG_STRT_DT and nvl(l_pen.enrt_cvg_thru_dt, hr_api.g_eot))
      and ( (l_pen.SSPNDD_FLAG = 'N') or
            ( nvl(p_source,'x') <> 'benuneai' and l_pen.SSPNDD_FLAG = 'Y') --CFW
     )) or
     ((l_lf_evt_ocrd_dt between
      l_pen.ENRT_CVG_STRT_DT and nvl(l_pen.enrt_cvg_thru_dt, hr_api.g_eot))
      and l_pil_id <> p_per_in_ler_id
      and ( (l_pen.SSPNDD_FLAG = 'N') or
            ( nvl(p_source,'x') <> 'benuneai' and l_pen.SSPNDD_FLAG = 'Y') --CFW
     )) or
     p_mode = 'CVG_END_DATE_ENTERABLE' then
    --
    open  c_old_corr_pen (p_per_in_ler_id
                        , p_prtt_enrt_rslt_id
                       , l_pen.effective_start_date) ; -- 7197868
    fetch c_old_corr_pen  into l_corr_pil_id ;
    if c_old_corr_pen%found then
            l_pil_id           :=  l_corr_pil_id ;
            hr_utility.set_location('not found corrected   '|| l_proc , 99 ) ;
    end if ;
    close c_old_corr_pen ;
    hr_utility.set_location('p_per_in_ler_id  '|| p_per_in_ler_id , 100);
    hr_utility.set_location('l_date  '|| to_char(l_date) , 100);
    hr_utility.set_location('l_pil_id  '|| l_pil_id , 100);
    hr_utility.set_location('p_mode  '|| p_mode , 100);
    --     Case 1: Coverage started, Coverage Elected and delete in same day.
    --               * void result and its rates.
    if (l_date = p_effective_date) and
         ((p_per_in_ler_id is not null and p_per_in_ler_id = l_pil_id) or
          p_per_in_ler_id is null) and
         (p_mode is null or p_mode <> 'CVG_END_DATE_ENTERABLE')then
      if g_debug then
          hr_utility.set_location('p_effective_date='||p_effective_date,19);
      end if;
      hr_utility.set_location(' p_date '|| p_effective_date || '--'||l_pen.effective_start_date , 99 ) ;
      hr_utility.set_location(' p_datetrack_mode '|| p_datetrack_mode , 99 ) ;
      hr_utility.set_location(' p_source '|| p_source , 99 ) ;
      hr_utility.set_location(' result ' ||  p_prtt_enrt_rslt_id , 99 ) ;
      hr_utility.set_location(' thru date ' ||  p_enrt_cvg_thru_dt , 99 ) ;
      l_step := 21;
      void_enrollment
       (p_validate                =>      p_validate
       ,p_per_in_ler_id           =>      p_per_in_ler_id
       ,p_prtt_enrt_rslt_id       =>      p_prtt_enrt_rslt_id
       ,p_business_group_id       =>      p_business_group_id
       ,p_enrt_cvg_strt_dt        =>      l_pen.enrt_cvg_strt_dt
       ,p_person_id               =>      l_pen.person_id
       ,p_elig_per_elctbl_chc_id  =>      l_pen.elig_per_elctbl_chc_id
       ,p_epe_ovn                 =>      l_pen.epe_ovn
       ,p_object_version_number   =>      l_pen.pen_ovn
       ,p_effective_date          =>      p_effective_date
       ,p_datetrack_mode          =>      p_datetrack_mode
       ,p_multi_row_validate      =>      p_multi_row_validate
       ,p_source                  =>      p_source
       ,p_enrt_bnft_id            =>      l_pen.enrt_bnft_id);
      --
      if l_pen.pgm_id is not null then
        ben_provider_pools.remove_bnft_prvdd_ldgr
       (p_prtt_enrt_rslt_id  => p_prtt_enrt_rslt_id
       ,p_effective_date     => p_effective_date
       ,p_business_group_id  => p_business_group_id
       ,p_validate           => FALSE
       ,p_datetrack_mode     => hr_api.g_delete
       );
      end if;
      hr_utility.set_location('l_benmngle_parm_rec.mode_cd  '|| l_benmngle_parm_rec.mode_cd , 100);
      hr_utility.set_location('l_env_rec.mode_cd  '|| l_env_rec.mode_cd , 100);
      hr_utility.set_location('p_source  '|| p_source , 100);
      -- 3398353
      /* In case of Unrestricted Enrollment running on the same-day,
      the dependent designation records (ben_elig_cvrd_dpnt_f) also
      needs to be end-dated / voided, when the enrollment is voided.
      */
      -- Also call the below code for 3797391  when source is benelinf
      --
      -- IF-UNRESTRICTED-OR-SCHEDULED
      -- Bug 4662362 : Removing the following IF condition since dependents / beneficiaries
      -- should be UNHOOKED for all cases
      --
      -- if (l_benmngle_parm_rec.mode_cd  = 'S' or l_ler_typ_cd = 'SCHEDDU' ) or ( p_source = 'benelinf' ) then
      --
      if g_debug then
        hr_utility.set_location('Updating Dependent Records. l_enrt_cvg_end_dt: '||l_enrt_cvg_end_dt, 100);
      end if;
      --
      l_step := 30;
      --
      if g_debug then
        hr_utility.set_location('calc_dpnt_cvg_dt ', 100);
      end if;
      --
      calc_dpnt_cvg_dt
        (p_calc_end_dt         => TRUE
        ,P_calc_strt_dt        => FALSE
        ,p_per_in_ler_id       => l_pen.per_in_ler_id
        ,P_person_id           => l_pen.person_id
        ,p_pgm_id              => l_pen.pgm_id
        ,p_pl_id               => l_pen.pl_id
        ,p_oipl_id             => l_pen.oipl_id
        ,p_ptip_id             => l_pen.ptip_id
        ,p_ler_id              => l_pen.ler_id
        ,P_BUSINESS_GROUP_ID   => p_business_group_id
        ,P_EFFECTIVE_DATE      => p_effective_date
        ,P_RETURNED_END_DT     => l_dpnt_cvg_end_dt
        ,P_RETURNED_STRT_DT    => l_dump_date
        ,p_enrt_cvg_end_dt     => l_enrt_cvg_end_dt
        );
      --
      l_step := 40;
      --
      l_dpnt_cvg_thru_dt := l_dpnt_cvg_end_dt;
      --
      -- In this case we are voiding the enrollment. so, the dependent coverage should
      -- end the same day as the participants.
      --
      if l_dpnt_cvg_end_dt is not NULL then
        l_dpnt_cvg_thru_dt := least(l_enrt_cvg_end_dt, l_dpnt_cvg_end_dt);
      End if;
      --
      -- Unhook dependent rows
      --
      l_step := 50;
      --
      if g_debug then
        hr_utility.set_location('unhook_dpnt cvg-end-date: '||l_dpnt_cvg_thru_dt, 100);
      end if;
      --
      unhook_dpnt
        (p_validate               => FALSE
        ,p_prtt_enrt_rslt_id      => p_prtt_enrt_rslt_id
        ,p_per_in_ler_id          => l_pen.per_in_ler_id
        ,p_cvg_thru_dt            => l_dpnt_cvg_thru_dt
        ,p_business_group_id      => p_business_group_id
        ,p_effective_date         => p_effective_date
        ,p_datetrack_mode         => p_datetrack_mode
        ,p_called_from            => p_source
        );
         --
      if g_debug then
        hr_utility.set_location('unhook_bnf cvg-end-date: '||l_dpnt_cvg_thru_dt, 100);
      end if;
      --
      unhook_bnf
       (p_validate               => FALSE
       ,p_prtt_enrt_rslt_id      => p_prtt_enrt_rslt_id
       ,p_per_in_ler_id          => l_pen.per_in_ler_id
       ,p_dsgn_thru_dt           => l_enrt_cvg_end_dt
       ,p_business_group_id      => p_business_group_id
       ,p_effective_date         => p_effective_date
       ,p_datetrack_mode         => p_datetrack_mode
       );
      -- end if;-- IF-UNRESTRICTED-OR-SCHEDULED
      ---

      /*Ended code for Bug 7561395*/
       hr_utility.set_location('IF-UNRESTRICTED-OR-SCHEDULED ', 500);
       hr_utility.set_location('Unhook dependent rows ', 500);
       hr_utility.set_location('p_prtt_enrt_rslt_ids '||p_prtt_enrt_rslt_id, 502);
       hr_utility.set_location('l_pen.pen_per_in_ler_id '||l_pen.pen_per_in_ler_id, 502);
       hr_utility.set_location('p_pen_per_in_ler_id '||p_per_in_ler_id, 502);
       hr_utility.set_location('g_new_prtt_enrt_rslt_id '||g_new_prtt_enrt_rslt_id, 502);

       /* Bug 8669907:
         if(action item exists for the pen_id ) do not create
	 else
	    if(Participant has selected diff comp obj) do not create
	    else   if(not enter value at enrollment) perform validations before creating action items
	           else perform validations before creating action items
	    Set the l_create_flag to 'Y' if action item has to be created */

       open c_chk_act_item_exits(g_new_prtt_enrt_rslt_id);
       fetch c_chk_act_item_exits into l_dummy1;
       if(c_chk_act_item_exits%found) then
           hr_utility.set_location('No Create 1',500);
           close c_chk_act_item_exits;
	   l_create_flag := 'N';
        else
           close c_chk_act_item_exits;
           open c_chk_same_comp_obj(g_new_prtt_enrt_rslt_id,p_prtt_enrt_rslt_id,p_per_in_ler_id);
           fetch c_chk_same_comp_obj into l_create_flag;
	    if(c_chk_same_comp_obj%notfound) then
	         hr_utility.set_location('No Create 2',500);
	         close c_chk_same_comp_obj;
		 l_create_flag := 'N';
	    else
	         close c_chk_same_comp_obj;
		 open c_bnft_amt(g_new_prtt_enrt_rslt_id,p_per_in_ler_id);
		 fetch c_bnft_amt into l_bnft ;
		 close c_bnft_amt;
		 if(l_bnft.entr_val_at_enrt_flag = 'N') then
		    if(l_bnft.cvg_mlt_cd = 'FLRNG') then
		       if(l_bnft.bnft_amt > l_bnft.mx_val) then
		          hr_utility.set_location('FLRNG Create ',500);
		          l_create_flag := 'Y';
		       else
		         hr_utility.set_location('FLRNG No Create',500);
		         l_create_flag := 'N';
		       end if;
		    else
		      hr_utility.set_location('Create 1',500);
		      l_create_flag := 'Y';
		    end if;
		 else
		    if(l_bnft.mx_wout_ctfn_val is not null and l_bnft.bnft_amt > l_bnft.mx_wout_ctfn_val ) then
		      hr_utility.set_location('Create 2',500);
		      l_create_flag := 'Y';
		    elsif(l_bnft.mx_wout_ctfn_val is not null and l_bnft.bnft_amt <= l_bnft.mx_wout_ctfn_val ) then
		      hr_utility.set_location('No Create 4',500);
		      l_create_flag := 'N';
		    else
		       hr_utility.set_location('Create 3',500);
		       l_create_flag := 'Y';
		    end if;
		 end if;
	    end if;
	end if;
        hr_utility.set_location('l_create_flag '||l_create_flag,500);

       open c_chk_same_event(g_new_prtt_enrt_rslt_id);
       fetch c_chk_same_event into l_nper_in_ler_id ;
       close c_chk_same_event;
       open c_chk_same_event(p_prtt_enrt_rslt_id);
       fetch c_chk_same_event into l_oper_in_ler_id ;
       close c_chk_same_event;
       open c_chk_act_item_exits(p_prtt_enrt_rslt_id);
             fetch c_chk_act_item_exits into l_dummy1;
	     if(c_chk_act_item_exits%found) then
		l_act_flag := true;
	        hr_utility.set_location('In loop2 false',500);
	     else
	       l_act_flag := false;
	       hr_utility.set_location('In loop2 true',500);
	     end if;
        close c_chk_act_item_exits;
       if(l_nper_in_ler_id = l_oper_in_ler_id and l_act_flag) then

	 open c_get_actn_items;
	 fetch c_get_actn_items BULK COLLECT into l_act_items;
	 hr_utility.set_location('In loop1',500);
           if(l_act_items.count > 0) then
	     l_act_flag := true;
	     hr_utility.set_location('In loop10 '||l_act_items.count,500);
	  else
            l_act_flag := false;
	    hr_utility.set_location('In loop11',500);
          end if;
	 close c_get_actn_items;


	 open c_get_ctfn;
	 fetch c_get_ctfn BULK COLLECT into l_ctfn;
	 if(l_ctfn.count > 0) then
	    l_ctfn_flag := true;
	    hr_utility.set_location('In loop10 '||l_ctfn.count,500);
	 end if;
	 close c_get_ctfn;

	 hr_utility.set_location('Remving action items',500);
	 remove_cert_action_items
		(p_prtt_enrt_rslt_id  => p_prtt_enrt_rslt_id
		,p_effective_date     => p_effective_date
		,p_business_group_id  => p_business_group_id
		,p_validate           => FALSE
		,p_datetrack_mode     => hr_api.g_zap
		,p_source             => p_source
		,p_per_in_ler_id      => l_pen.pen_per_in_ler_id
		,p_per_in_ler_ended_id=> l_pen.per_in_ler_id
		);

           if(l_act_flag and l_create_flag = 'Y' ) then
	   hr_utility.set_location('creating action items',500);
		for i IN l_act_items.FIRST..l_act_items.LAST loop
		   ben_PRTT_ENRT_ACTN_api.create_PRTT_ENRT_ACTN
				  (p_validate   => false
				  ,p_effective_date =>  p_effective_date
				  ,p_cmpltd_dt  => l_act_items(i).cmpltd_dt
				  ,p_due_dt  => l_act_items(i).due_dt
				  ,p_rqd_flag   => l_act_items(i).rqd_flag
				  ,p_prtt_enrt_rslt_id  => g_new_prtt_enrt_rslt_id
				  ,p_per_in_ler_id  => p_per_in_ler_id
				  ,p_rslt_object_version_number => l_rslt_object_version_number
				  ,p_actn_typ_id    => l_act_items(i).actn_typ_id
				  ,p_elig_cvrd_dpnt_id   => l_act_items(i).elig_cvrd_dpnt_id
				  ,p_pl_bnf_id     => l_act_items(i).pl_bnf_id
				  ,p_business_group_id  => l_act_items(i).business_group_id
				  ,p_pea_attribute_category  => l_act_items(i).pea_attribute_category
				  ,p_pea_attribute1 => l_act_items(i).pea_attribute1
				  ,p_pea_attribute2 => l_act_items(i).pea_attribute2
				  ,p_pea_attribute3 => l_act_items(i).pea_attribute3
				  ,p_pea_attribute4  => l_act_items(i).pea_attribute4
				  ,p_pea_attribute5  => l_act_items(i).pea_attribute5
				  ,p_pea_attribute6  => l_act_items(i).pea_attribute6
				  ,p_pea_attribute7   => l_act_items(i).pea_attribute7
				  ,p_pea_attribute8 => l_act_items(i).pea_attribute8
				  ,p_pea_attribute9  => l_act_items(i).pea_attribute9
				  ,p_pea_attribute10 => l_act_items(i).pea_attribute10
				  ,p_pea_attribute11 => l_act_items(i).pea_attribute11
				  ,p_pea_attribute12 => l_act_items(i).pea_attribute12
				  ,p_pea_attribute13 => l_act_items(i).pea_attribute13
				  ,p_pea_attribute14  => l_act_items(i).pea_attribute14
				  ,p_pea_attribute15 => l_act_items(i).pea_attribute15
				  ,p_pea_attribute16 => l_act_items(i).pea_attribute16
				  ,p_pea_attribute17  => l_act_items(i).pea_attribute17
				  ,p_pea_attribute18  => l_act_items(i).pea_attribute18
				  ,p_pea_attribute19  => l_act_items(i).pea_attribute19
				  ,p_pea_attribute20 => l_act_items(i).pea_attribute20
				  ,p_pea_attribute21 => l_act_items(i).pea_attribute21
				  ,p_pea_attribute22 => l_act_items(i).pea_attribute22
				  ,p_pea_attribute23  => l_act_items(i).pea_attribute23
				  ,p_pea_attribute24   => l_act_items(i).pea_attribute24
				  ,p_pea_attribute25  => l_act_items(i).pea_attribute25
				  ,p_pea_attribute26 => l_act_items(i).pea_attribute26
				  ,p_pea_attribute27 => l_act_items(i).pea_attribute27
				  ,p_pea_attribute28   => l_act_items(i).pea_attribute28
				  ,p_pea_attribute29 => l_act_items(i).pea_attribute29
				  ,p_pea_attribute30 => l_act_items(i).pea_attribute30
				  ,p_object_version_number  => l_actn_object_version_number
				  ,p_prtt_enrt_actn_id   => l_prtt_enrt_actn_id
				  ,p_effective_start_date => l_actn_start_date
				  ,p_effective_end_date   => l_actn_end_date
				  ,p_gnrt_cm => false -- Bug 9256641 : Do not generate communications
				  );
	      end loop;
	      hr_utility.set_location('created action items',500);
        end if;

        hr_utility.set_location('before creating cert',500);
        if(l_ctfn_flag and l_create_flag = 'Y' ) then
	hr_utility.set_location('creating certifications ',500);
	 for j IN l_ctfn.FIRST..l_ctfn.LAST loop
	        hr_utility.set_location('looping cert ',500);
		ben_PRTT_ENRT_CTFN_PRVDD_api.create_PRTT_ENRT_CTFN_PRVDD
		  (p_validate => false
		  ,p_prtt_enrt_ctfn_prvdd_id => l_prtt_enrt_ctfn_prvdd_id
		  ,p_effective_start_date  => l_ctfn_start_date
		  ,p_effective_end_date => l_ctfn_end_date
		  ,p_enrt_ctfn_rqd_flag  => l_ctfn(j).enrt_ctfn_rqd_flag
		  ,p_enrt_ctfn_typ_cd   => l_ctfn(j).enrt_ctfn_typ_cd
		  ,p_enrt_ctfn_recd_dt => l_ctfn(j).enrt_ctfn_recd_dt
		  ,p_enrt_ctfn_dnd_dt  => l_ctfn(j).enrt_ctfn_dnd_dt
		  ,p_enrt_r_bnft_ctfn_cd => l_ctfn(j).enrt_r_bnft_ctfn_cd
		  ,p_prtt_enrt_rslt_id => g_new_prtt_enrt_rslt_id
		  ,p_prtt_enrt_actn_id  => l_prtt_enrt_actn_id
		  ,p_business_group_id  => l_ctfn(j).business_group_id
		  ,p_pcs_attribute_category  => l_ctfn(j).pcs_attribute_category
		  ,p_pcs_attribute1  => l_ctfn(j).pcs_attribute1
		  ,p_pcs_attribute2  => l_ctfn(j).pcs_attribute2
		  ,p_pcs_attribute3 => l_ctfn(j).pcs_attribute3
		  ,p_pcs_attribute4 => l_ctfn(j).pcs_attribute4
		  ,p_pcs_attribute5 => l_ctfn(j).pcs_attribute5
		  ,p_pcs_attribute6  => l_ctfn(j).pcs_attribute6
		  ,p_pcs_attribute7  => l_ctfn(j).pcs_attribute7
		  ,p_pcs_attribute8  => l_ctfn(j).pcs_attribute8
		  ,p_pcs_attribute9  => l_ctfn(j).pcs_attribute9
		  ,p_pcs_attribute10 => l_ctfn(j).pcs_attribute10
		  ,p_pcs_attribute11 => l_ctfn(j).pcs_attribute11
		  ,p_pcs_attribute12 => l_ctfn(j).pcs_attribute12
		  ,p_pcs_attribute13=> l_ctfn(j).pcs_attribute13
		  ,p_pcs_attribute14  => l_ctfn(j).pcs_attribute14
		  ,p_pcs_attribute15 => l_ctfn(j).pcs_attribute15
		  ,p_pcs_attribute16=> l_ctfn(j).pcs_attribute16
		  ,p_pcs_attribute17  => l_ctfn(j).pcs_attribute17
		  ,p_pcs_attribute18 => l_ctfn(j).pcs_attribute18
		  ,p_pcs_attribute19 => l_ctfn(j).pcs_attribute19
		  ,p_pcs_attribute20 => l_ctfn(j).pcs_attribute20
		  ,p_pcs_attribute21=> l_ctfn(j).pcs_attribute21
		  ,p_pcs_attribute22 => l_ctfn(j).pcs_attribute22
		  ,p_pcs_attribute23  => l_ctfn(j).pcs_attribute23
		  ,p_pcs_attribute24=>l_ctfn(j).pcs_attribute24
		  ,p_pcs_attribute25 =>l_ctfn(j).pcs_attribute25
		  ,p_pcs_attribute26 => l_ctfn(j).pcs_attribute26
		  ,p_pcs_attribute27 => l_ctfn(j).pcs_attribute27
		  ,p_pcs_attribute28 => l_ctfn(j).pcs_attribute28
		  ,p_pcs_attribute29 => l_ctfn(j).pcs_attribute29
		  ,p_pcs_attribute30 => l_ctfn(j).pcs_attribute30
		  ,p_object_version_number  => l_ctfn_object_version_number
		  ,p_effective_date => p_effective_date
		  );
	     end loop;
           end if;
	   g_new_prtt_enrt_rslt_id := -1;
      else
	     remove_cert_action_items
		(p_prtt_enrt_rslt_id  => p_prtt_enrt_rslt_id
		,p_effective_date     => p_effective_date
		,p_business_group_id  => p_business_group_id
		,p_validate           => FALSE
		,p_datetrack_mode     => hr_api.g_zap
		,p_source             => p_source
		,p_per_in_ler_id      => l_pen.pen_per_in_ler_id
		,p_per_in_ler_ended_id=> l_pen.per_in_ler_id
		);
      end if;

      -- Commented for Bug 7561395
      /*remove_cert_action_items
        (p_prtt_enrt_rslt_id  => p_prtt_enrt_rslt_id
        ,p_effective_date     => p_effective_date
        ,p_business_group_id  => p_business_group_id
        ,p_validate           => FALSE
        ,p_datetrack_mode     => hr_api.g_zap
        ,p_source             => p_source
        ,p_per_in_ler_id      => l_pen.pen_per_in_ler_id
        ,p_per_in_ler_ended_id=> l_pen.per_in_ler_id
        );*/

      /*Ended code for Bug 7561395*/



      -- 3398353
      --     Case 2: Coverage Started, Coverage Elected and delete but not in same
      --             day.  (Elected earlier before Today)
      --               * Calculated its coverage end date.
    else
      --
      -- 4642299: For either Rate or Coverage Code of '1 Prior'
      -- Open c_new_cvg_strt_dt to determine if new coverage exists
      -- If so, change the Rate / Coverage end-date to 1 day prior.
      -- Added 'LODBEWM','ODBEWM' too for 1 Prior logic.
      If (substr(nvl(l_cvg_end_dt_cd, 'X'), 1, 1) = 'W' or
          substr(nvl(l_cvg_end_dt_cd, 'X'), 1, 2) = 'LW' or
          substr(nvl(l_rt_end_dt_cd, 'X'), 1, 1) = 'W' or
          substr(nvl(l_rt_end_dt_cd, 'X'), 1, 2) = 'LW' or
          l_rt_end_dt_cd in ('LDPPOEFD','LDPPFEFD','LODBEWM','ODBEWM') ) and
         (p_per_in_ler_id <> l_pil_id or l_ler_typ_cd = 'SCHEDDU' or
	  (p_per_in_ler_id = l_pil_id and l_ler_typ_cd not in ('IREC','GSP','COMP','ABS'))) then
        -- Bug 2847110
	hr_utility.set_location('c_new_cvg_strt_dt,srav : '||l_new_enrt_cvg_strt_dt,199);
        open c_new_cvg_strt_dt(l_pen.pl_typ_id, l_pen.ptip_id,l_pen.pl_id,
                               l_enrt_cvg_strt_dt );
        fetch c_new_cvg_strt_dt into l_new_enrt_cvg_strt_dt;
        close c_new_cvg_strt_dt;
        --
        if l_new_enrt_cvg_strt_dt is null then
          open c_new_cvg_strt_dt(l_pen.pl_typ_id, l_pen.ptip_id,-999,
                                 l_enrt_cvg_strt_dt );
          fetch c_new_cvg_strt_dt into l_new_enrt_cvg_strt_dt;
          close c_new_cvg_strt_dt;
        end if;
        --
      End if;
      --
      -- Change Coverage Dates to 1 Prior
      if (substr(nvl(l_cvg_end_dt_cd, 'X'), 1, 1) = 'W' or
          substr(nvl(l_cvg_end_dt_cd, 'X'), 1, 2) = 'LW' ) and
         (p_per_in_ler_id <> l_pil_id or l_ler_typ_cd = 'SCHEDDU' ) then
         --
          if l_new_enrt_cvg_strt_dt is not null then
            l_enrt_cvg_end_dt := nvl(l_new_enrt_cvg_strt_dt - 1, l_enrt_cvg_end_dt ) ;
          end if;
          --
      end if;
      --
      if g_debug then
         hr_utility.set_location('c_new_cvg_strt_dt'||l_new_enrt_cvg_strt_dt,199);
         hr_utility.set_location('l_enrt_cvg_end_dt'||l_enrt_cvg_end_dt,199);
      end if;
      --
      -- Change Rate Dates to 1 Prior
      If (substr(nvl(l_rt_end_dt_cd, 'X'), 1, 1) = 'W' or
          substr(nvl(l_rt_end_dt_cd, 'X'), 1, 2) = 'LW' or
          l_rt_end_dt_cd in ('LDPPOEFD','LDPPFEFD','LODBEWM','ODBEWM') )
         -- Bug: 4268494. Evaluate '1 Prior' for these codes as well.
         -- Bug: 4642299 Added 'LODBEWM','ODBEWM' too for 1 Prior logic.
      then
        --
        if g_debug then
             hr_utility.set_location(' pen api rt strt dt ' || l_rt_strt_dt, 299 );
             hr_utility.set_location(' pen api rt end dt ' || l_rt_end_dt, 299 );
        end if;
        --bug#3260564
        if l_new_enrt_cvg_strt_dt is not null then
          l_rt_end_dt := nvl(l_rt_strt_dt - 1,l_rt_end_dt) ;
        end if;
      --
      End if;
      --
      If l_enrt_cvg_end_dt is NULL then
        rpt_error(p_proc => l_proc, p_step => l_step);
        fnd_message.set_name('BEN','BEN_91702_NOT_DET_CVG_END_DT');
--        fnd_message.raise_error;
        raise l_fnd_message_exception;

      End if;
      --
      If l_rt_end_dt is NULL then
        rpt_error(p_proc => l_proc, p_step => l_step);
        fnd_message.set_name('BEN','BEN_91703_NOT_DET_RATE_END_DT');
--        fnd_message.raise_error;
          raise l_fnd_message_exception;
      end if;
      --
      -- when the result is voided the participant rate rows also should be voided as sometimes
      -- the rate end date comes greater or equal to rate start date which is not voiding the rate rows
      -- Update rt_end_dt in prtt_rate_val table
      --
      --Bug 5368060
      --Dont void the rate if the PEN record is Backed-Out
      --If the PEN record is end-dated in the subsequent life event dont void the rate

      --Bug 5499809
      --Void the enrollment rate if the delete enrollment is being performed in the same life event and that life event is not unrestricted LE

      -- Commented the below if condition
      -- if l_pen.enrt_cvg_strt_dt > l_enrt_cvg_end_dt then

      if ((l_pen.per_in_ler_id = l_pen.pen_per_in_ler_id) and (l_ler_typ_cd <> 'SCHEDDU')) then
      --
			  --5663280
        open c_check_carry_fwd_enrt(p_prtt_enrt_rslt_id, p_per_in_ler_id, l_pen.enrt_cvg_strt_dt,
                                    l_pen.effective_start_date);
        fetch c_check_carry_fwd_enrt into l_check_carry_fwd_enrt;
        close c_check_carry_fwd_enrt;

        if l_check_carry_fwd_enrt is null then
          hr_utility.set_location('Void Rate procedure is called',3455);
          void_rate (p_prtt_enrt_rslt_id => p_prtt_enrt_rslt_id,
                     p_business_group_id => p_business_group_id,
                     p_person_id         => l_pen.person_id,
                     p_per_in_ler_id     => p_per_in_ler_id,
                     p_effective_date    => p_effective_date );

         -----Bug 6925893
	  If substr(nvl(l_rt_end_dt_cd, 'X'), 1, 1) = 'W' or
	     substr(nvl(l_rt_end_dt_cd, 'X'), 1, 2) = 'LW' or
             l_rt_end_dt_cd in ('LDPPOEFD','LDPPFEFD','LODBEWM','ODBEWM') then  ---Bug 7209243
	    /*  open c_get_old_prv;
	    fetch c_get_old_prv into l_get_old_prv;
	    if c_get_old_prv%found then
	      hr_utility.set_location('l_get_old_prv.prtt_rt_val_id :'||l_get_old_prv.prtt_rt_val_id,3455); */
	      --Bug 9290518
	      l_old_prv_found := false;
               for l_old_prv in c_get_old_prv loop
	          hr_utility.set_location('l_old_prv.prtt_rt_val_id :'|| l_old_prv.prtt_rt_val_id,3455);
		  l_old_prv_found := true;
		  ben_prtt_rt_val_api.update_prtt_rt_val
		  (P_VALIDATE                => FALSE
		  ,P_PRTT_RT_VAL_ID          => l_old_prv.prtt_rt_val_id  --l_get_old_prv.prtt_rt_val_id
		  ,P_RT_END_DT               => l_rt_end_dt
		  ,p_person_id               => l_pen.person_id
		  ,p_input_value_id          => l_old_prv.input_value_id  --l_get_old_prv.input_value_id
		  ,p_element_type_id         => l_old_prv.element_type_id  --l_get_old_prv.element_type_id
		  ,p_prtt_rt_val_stat_cd     => null
		  ,p_business_group_id       => p_business_group_id
		  ,P_OBJECT_VERSION_NUMBER   => l_old_prv.object_version_number  --l_get_old_prv.object_version_number
		  ,P_EFFECTIVE_DATE          => p_effective_date
		  );
		end loop;
		---Bug 9290518
	    hr_utility.set_location('P_RT_END_DT :'||hr_api.g_eot,3455);
	 -- else ------------Bug 7209243
	    if not(l_old_prv_found) then  --Bug 9290518
	      hr_utility.set_location('c_get_old_prv not found',3455);
	      ---get the new rt start dat to compute the end date
	      open c_get_epe(l_pen.pl_typ_id);
	      fetch c_get_epe into l_get_epe;
	      if c_get_epe%found then
	      ben_determine_date.rate_and_coverage_dates
		 (p_elig_per_elctbl_chc_id => l_get_epe.elig_per_elctbl_chc_id
		 ,p_business_group_id      => l_get_epe.business_group_id
		 ,P_PER_IN_LER_ID          => l_get_epe.per_in_ler_id
		 ,P_PERSON_ID              => l_pen.person_id
		 ,P_PGM_ID                 => l_get_epe.pgm_id
		 ,P_PL_ID                  => l_get_epe.pl_id
		 ,P_OIPL_ID                => l_get_epe.oipl_id
		 ,P_LEE_RSN_ID             => nvl(p_lee_rsn_id,l_lee_rsn_id)
		 ,P_ENRT_PERD_ID           => nvl(p_enrt_perd_id,l_enrt_perd_id)
		 ,p_enrt_cvg_strt_dt       => l_enrt_cvg_strt_dt1
		 ,p_enrt_cvg_strt_dt_cd    => l_enrt_cvg_strt_dt_cd
		 ,p_enrt_cvg_strt_dt_rl    => l_enrt_cvg_strt_dt_rl
		 ,p_rt_strt_dt             => l_rt_strt_dt1
		 ,p_rt_strt_dt_cd          => l_rt_strt_dt_cd
		 ,p_rt_strt_dt_rl          => l_rt_strt_dt_rl
		 ,p_enrt_cvg_end_dt        => l_enrt_cvg_end_dt1
		 ,p_enrt_cvg_end_dt_cd     => l_enrt_cvg_end_dt_cd
		 ,p_enrt_cvg_end_dt_rl     => l_enrt_cvg_end_dt_rl
		 ,p_rt_end_dt              => l_rt_end_dt1
		  ,p_rt_end_dt_cd           => l_rt_end_dt_cd
		  ,p_rt_end_dt_rl           => l_rt_end_dt_rl
		  ,p_effective_date         => p_effective_date
		  ,p_end_date               => p_enrt_cvg_thru_dt
		  );
	      l_rt_end_dt1 := l_rt_strt_dt1 - 1;
	      ---Bug 9290518
	    /*   open c_get_old_prv1;
	      fetch c_get_old_prv1 into l_get_old_prv1;
	      if c_get_old_prv1%found then  */
                for l_get_old_prv1 in c_get_old_prv1 loop
		hr_utility.set_location('l_get_old_prv1.prtt_rt_val_id :'||l_get_old_prv1.prtt_rt_val_id,3455);
		hr_utility.set_location('l_get_old_prv1.ovn :'||l_get_old_prv1.object_version_number,3455.1);
		hr_utility.set_location('l_rt_end_dt1 :'||l_rt_end_dt1,3455.1);

		ben_prtt_rt_val_api.update_prtt_rt_val
		(P_VALIDATE                => FALSE
		,P_PRTT_RT_VAL_ID          => l_get_old_prv1.prtt_rt_val_id
		,P_RT_END_DT               => l_rt_end_dt1
		,p_person_id               => l_pen.person_id
		,p_input_value_id          => l_get_old_prv1.input_value_id
		,p_element_type_id         => l_get_old_prv1.element_type_id
		,p_prtt_rt_val_stat_cd     => null
		,p_business_group_id       => p_business_group_id
		,P_OBJECT_VERSION_NUMBER   => l_get_old_prv1.object_version_number
		,P_EFFECTIVE_DATE          => p_effective_date
		);
	    /*  end if;
	      close c_get_old_prv1; */
	      end loop;
	      --Bug 9290518
	      end if;
	      close c_get_epe; -------------Bug 7209243
	  end if;
	--  close c_get_old_prv; ---Bug 9290518
	  hr_utility.set_location('P_RT_END_DT not fund :'||hr_api.g_eot,3455);
	  hr_utility.set_location('p_effective_start_date :'||p_effective_start_date,3455);
	  hr_utility.set_location('p_effective_date :'||p_effective_date,3455);
         end if;
	  -----Bug 6925893
        end if;
      end if;
     --End Bug 5499809

       hr_utility.set_location('P_RT_END_DT not fund1 :'||hr_api.g_eot,3455);
      --
      l_step := 35;
      if g_debug then
         hr_utility.set_location(l_proc,3456);
      end if;
      --  rate is having non recurring
      if g_debug then
        hr_utility.set_location(l_deenrol_dt,3459);
      end if;
      for l_prv in c_prv3 (p_per_in_ler_id) loop
         --check whether rate is non-recurring
         open c_abr(l_prv.acty_base_rt_id);
         fetch c_abr into l_abr;
         close c_abr;
         --
         if (l_abr.processing_type = 'N' or
            l_abr.rcrrg_cd = 'ONCE' ) and
              l_pen.enrt_cvg_strt_dt > l_enrt_cvg_end_dt then
            null;
         else
           exit;
         end if;
         if g_debug then
          hr_utility.set_location('delete prtt',3459);
         end if;
           update ben_enrt_rt
              set prtt_rt_val_id = null
              where enrt_rt_id = l_prv.enrt_rt_id;
           --
           ben_prtt_rt_val_api.delete_prtt_rt_val
           (P_VALIDATE                => FALSE
           ,P_PRTT_RT_VAL_ID          => l_prv.prtt_rt_val_id
           ,P_OBJECT_VERSION_NUMBER   => l_prv.object_version_number
           ,P_EFFECTIVE_DATE          => l_eff_dt
           ,p_person_id               => l_pen.person_id
           ,p_business_group_id       => p_business_group_id
           );
      end loop;
      For l_prv in c_prv2 loop
        if g_debug then
          hr_utility.set_location(l_proc,3457);
        end if;
        l_prv_count := l_prv_count + 1;
        if (nvl(l_prv.per_in_ler_id, -1) <> nvl(p_per_in_ler_id,-1)) and
           l_rt_end_dt < l_prv.rt_strt_dt then
           l_prtt_rt_val_stat_cd := 'BCKDT';
        end if;
        ben_prtt_rt_val_api.update_prtt_rt_val
        (P_VALIDATE                => FALSE
        ,P_PRTT_RT_VAL_ID          => l_prv.prtt_rt_val_id
        ,P_RT_END_DT               => l_rt_end_dt
        ,p_person_id               => l_pen.person_id
        --Bug#2625060 - for converted data, null is passed for activity base rt id
        --   ,p_acty_base_rt_id         => l_prv.acty_base_rt_id
        ,p_input_value_id          => l_prv.input_value_id
        ,p_prtt_rt_val_stat_cd     => l_prtt_rt_val_stat_cd
        ,p_element_type_id         => l_prv.element_type_id
        ,p_ended_per_in_ler_id     => p_per_in_ler_id
        ,p_business_group_id       => p_business_group_id
        ,P_OBJECT_VERSION_NUMBER   => l_prv.object_version_number
        ,P_EFFECTIVE_DATE          => p_effective_date
        );
        if g_debug then
           hr_utility.set_location(l_proc,3458);
        end if;
      end loop;
      --
      --   Adjust overlapping rates . Bug 5391554
      --
       -- basu
       hr_utility.set_location('p_per_in_ler_id '||p_per_in_ler_id,44333);
       --
      open c_get_pgm_extra_info(l_pen.pgm_id);
      fetch c_get_pgm_extra_info into l_adjust;
      if c_get_pgm_extra_info%found then
        if l_adjust = 'Y' then
          for l_prv5 in c_prv5(l_rt_end_dt) loop
          --
          if g_debug then
            hr_utility.set_location('Adjusting rate '||l_rt_end_dt,111);
          end if;
          ben_prtt_rt_val_api.update_prtt_rt_val
           (P_VALIDATE                => FALSE
           ,P_PRTT_RT_VAL_ID          => l_prv5.prtt_rt_val_id
           ,P_RT_END_DT               => l_rt_end_dt
           ,p_person_id               => l_pen.person_id
           ,p_input_value_id          => l_prv5.input_value_id
           ,p_element_type_id         => l_prv5.element_type_id
           ,p_ended_per_in_ler_id     => p_per_in_ler_id
           ,p_business_group_id       => p_business_group_id
           ,P_OBJECT_VERSION_NUMBER   => l_prv5.object_version_number
           ,P_EFFECTIVE_DATE          => p_effective_date
           );
          end loop;
        end if;
      end if;
      close c_get_pgm_extra_info;

      -- Bug#2038814 - cursor above updates only the last prtt_rt_val and if there is
      -- any future dated prtt_rt_val, rows with rt end date greater than the calculated rt end
      -- date needs to be updated
      -- Bug 2739965
      if l_benmngle_parm_rec.mode_cd = 'S' or l_ler_typ_cd = 'SCHEDDU' then
        if g_debug then
         hr_utility.set_location('ben mngle mode',111);
         hr_utility.set_location('rate end date'||l_rt_end_dt,111);
        end if;
        For l_prv4 in c_prv4 (l_rt_end_dt) loop
          if g_debug then
             hr_utility.set_location(l_proc,3459);
          end if;
          -- 2739965 In case of unrestricted enrollment, this happens only when there are future rates
          -- and they got deleted as part of c_prv2 process above. Lets us throw this error
          -- here warning the user about the deletion of the future rate.
          --
    /* Bug 5739530 : Update prv only if it has not been updated previously */
     if l_prv4.prtt_rt_val_id <> prev_prtt_rt_val_id then
     --
     prev_prtt_rt_val_id := l_prv4.prtt_rt_val_id;
     --
          if fnd_global.conc_request_id in ( 0,-1) then
            -- Issue a warning to the user.  These will display on the enrt forms.
            ben_warnings.load_warning
            (p_application_short_name  => 'BEN',
             p_message_name            => 'BEN_93369_DEL_FUT_RATE',
             p_parma     => fnd_date.date_to_chardate( l_prv4.rt_end_dt+1 ),
             p_parmb     => l_pen.pl_name || ' '||l_pen.opt_name,
             p_person_id => l_pen.person_id);
          end if;
          --
          ben_prtt_rt_val_api.update_prtt_rt_val
            (P_VALIDATE                => FALSE
            ,P_PRTT_RT_VAL_ID          => l_prv4.prtt_rt_val_id
            ,P_RT_END_DT               => l_rt_end_dt
            ,p_person_id               => l_pen.person_id
             --Bug#2625060 - for converted data, null is passed for activity base rt id
              --    ,p_acty_base_rt_id         => l_prv4.acty_base_rt_id
            ,p_input_value_id          => l_prv4.input_value_id
            ,p_element_type_id         => l_prv4.element_type_id
            ,p_ended_per_in_ler_id     => p_per_in_ler_id
            ,p_business_group_id       => p_business_group_id
            ,P_OBJECT_VERSION_NUMBER   => l_prv4.object_version_number
            ,P_EFFECTIVE_DATE          => p_effective_date
              );
          if g_debug then
             hr_utility.set_location(l_proc,3460);
          end if;
        --
        end if;       /* End Bug 5739530 */
        --
        end loop;
      --
      end if;
      if g_debug then
         hr_utility.set_location(l_proc,3459);
      end if;
      --
      -- 3574168: Remove PCP records
      -- Set End-date to coverage-end-date.
      --
      l_pcp_effective_date := NVL(l_enrt_cvg_end_dt+1, p_effective_date);
      --
      for l_pcp in c_pcp(l_pcp_effective_date) loop
        --
        hr_utility.set_location('DELETE prmry_care_prvdr_id '|| l_pcp.prmry_care_prvdr_id, 15);
        hr_utility.set_location('PCP ESD: EED '|| l_pcp.effective_start_date ||': '||l_pcp.effective_end_date, 15);
        hr_utility.set_location('Effective Date to delete '|| l_pcp_effective_date, 15);
        hr_utility.set_location('DATETRACK_MODE '|| hr_api.g_delete, 15);
        -- Since, deletion automatically sets end-date to 1 day less than effective-date,
        -- call the delete-api with effective_date = cvg_thru_date+1.
        --
        ben_prmry_care_prvdr_api.delete_prmry_care_prvdr
        (P_VALIDATE               => FALSE
        ,P_PRMRY_CARE_PRVDR_ID    => l_pcp.prmry_care_prvdr_id
        ,P_EFFECTIVE_START_DATE   => l_pcp.effective_start_date
        ,P_EFFECTIVE_END_DATE     => l_pcp.effective_end_date
        ,P_OBJECT_VERSION_NUMBER  => l_pcp.object_version_number
        ,P_EFFECTIVE_DATE         => l_pcp_effective_date
        ,P_DATETRACK_MODE         => hr_api.g_delete
        ,p_called_from            => 'delete_enrollment'
        );
        --
      End loop;
      --
      -- Get future PCP records if any and zap - delete all of them.
      --
      for l_pcp_future in c_pcp_future(l_pcp_effective_date) loop
        --
        l_pcp_effective_start_date := l_pcp_future.effective_start_date;
        --
        hr_utility.set_location('ZAP prmry_care_prvdr_id '|| l_pcp_future.prmry_care_prvdr_id, 15);
        hr_utility.set_location('PCP ESD: EED '|| l_pcp_future.effective_start_date ||': '||l_pcp_future.effective_end_date, 15);
        hr_utility.set_location('Effective Date to delete '|| l_pcp_effective_start_date, 15);
        --
        ben_prmry_care_prvdr_api.delete_prmry_care_prvdr
        (P_VALIDATE               => FALSE
        ,P_PRMRY_CARE_PRVDR_ID    => l_pcp_future.prmry_care_prvdr_id
        ,P_EFFECTIVE_START_DATE   => l_pcp_future.effective_start_date
        ,P_EFFECTIVE_END_DATE     => l_pcp_future.effective_end_date
        ,P_OBJECT_VERSION_NUMBER  => l_pcp_future.object_version_number
        ,P_EFFECTIVE_DATE         => l_pcp_effective_start_date
        ,P_DATETRACK_MODE         => hr_api.g_zap
        ,p_called_from            => 'delete_enrollment'
        );
      End loop;
      -- 3574168
      --
      -- Get dependent coverage End date. If Participant coverage end date
      -- is greater than dependent coverage end date, then use participant.
      --
      l_step := 40;
      --
      calc_dpnt_cvg_dt
        (p_calc_end_dt         => TRUE
        ,P_calc_strt_dt        => FALSE
        ,p_per_in_ler_id       => l_pen.per_in_ler_id
        ,P_person_id           => l_pen.person_id
        ,p_pgm_id              => l_pen.pgm_id
        ,p_pl_id               => l_pen.pl_id
        ,p_oipl_id             => l_pen.oipl_id
        ,p_ptip_id             => l_pen.ptip_id
        ,p_ler_id              => l_pen.ler_id
        ,P_BUSINESS_GROUP_ID   => p_business_group_id
        ,P_EFFECTIVE_DATE      => p_effective_date
        ,P_RETURNED_END_DT     => l_dpnt_cvg_end_dt
        ,P_RETURNED_STRT_DT    => l_dump_date
        ,p_enrt_cvg_end_dt     => l_enrt_cvg_end_dt
        );
      --
      l_step := 90;
      --
      -- bug 3327224 -- make dpnt cvg independent of prtt's cvg
      /*
      If l_dpnt_cvg_end_dt is not NULL then
        l_dpnt_cvg_thru_dt := least(l_enrt_cvg_end_dt, l_dpnt_cvg_end_dt);
      End if;
      */
      l_dpnt_cvg_thru_dt := l_dpnt_cvg_end_dt;
      --
      -- Unhook dependent rows
      --
      l_step := 110;
      unhook_dpnt
        (p_validate               => FALSE
        ,p_prtt_enrt_rslt_id      => p_prtt_enrt_rslt_id
        ,p_per_in_ler_id          => l_pen.per_in_ler_id
        ,p_cvg_thru_dt            => l_dpnt_cvg_thru_dt
        ,p_business_group_id      => p_business_group_id
        ,p_effective_date         => p_effective_date
        ,p_datetrack_mode         => p_datetrack_mode
        ,p_called_from            => p_source
        );
      unhook_bnf
       (p_validate               => FALSE
       ,p_prtt_enrt_rslt_id      => p_prtt_enrt_rslt_id
       ,p_per_in_ler_id          => l_pen.per_in_ler_id
       ,p_dsgn_thru_dt           => l_enrt_cvg_end_dt
       ,p_business_group_id      => p_business_group_id
       ,p_effective_date         => p_effective_date
       ,p_datetrack_mode         => p_datetrack_mode
       );

       /* Added code for Bug 7561395*/
       hr_utility.set_location('Unhook dependent rows ', 500);
       hr_utility.set_location('p_prtt_enrt_rslt_ids '||p_prtt_enrt_rslt_id, 503);
       hr_utility.set_location('l_pen.pen_per_in_ler_id '||l_pen.pen_per_in_ler_id, 503);
       hr_utility.set_location('p_pen_per_in_ler_id '||p_per_in_ler_id, 503);
       hr_utility.set_location('g_new_prtt_enrt_rslt_id '||g_new_prtt_enrt_rslt_id, 503);

       /* Bug 8669907:
         if(action item exists for the pen_id ) do not create
	 else
	    if(Participant has selected diff comp obj) do not create
	    else   if(not enter value at enrollment) perform validations before creating action items
	           else perform validations before creating action items
	    Set the l_create_flag to 'Y' if action item has to be created */

       open c_chk_act_item_exits(g_new_prtt_enrt_rslt_id);
       fetch c_chk_act_item_exits into l_dummy1;
       if(c_chk_act_item_exits%found) then
           hr_utility.set_location('No Create 1',500);
           close c_chk_act_item_exits;
	   l_create_flag := 'N';
        else
           close c_chk_act_item_exits;
           open c_chk_same_comp_obj(g_new_prtt_enrt_rslt_id,p_prtt_enrt_rslt_id,p_per_in_ler_id);
           fetch c_chk_same_comp_obj into l_create_flag;
	    if(c_chk_same_comp_obj%notfound) then
	         hr_utility.set_location('No Create 2',500);
	         close c_chk_same_comp_obj;
		 l_create_flag := 'N';
	    else
	         close c_chk_same_comp_obj;
		 open c_bnft_amt(g_new_prtt_enrt_rslt_id,p_per_in_ler_id);
		 fetch c_bnft_amt into l_bnft ;
		 close c_bnft_amt;
		 if(l_bnft.entr_val_at_enrt_flag = 'N') then
		    if(l_bnft.cvg_mlt_cd = 'FLRNG') then
		       if(l_bnft.bnft_amt > l_bnft.mx_val) then
		          hr_utility.set_location('FLRNG Create ',500);
		          l_create_flag := 'Y';
		       else
		         hr_utility.set_location('FLRNG No Create',500);
		         l_create_flag := 'N';
		       end if;
		    else
		      hr_utility.set_location('Create 1',500);
		      l_create_flag := 'Y';
		    end if;
		 else
		    if(l_bnft.mx_wout_ctfn_val is not null and l_bnft.bnft_amt > l_bnft.mx_wout_ctfn_val ) then
		      hr_utility.set_location('Create 2',500);
		      l_create_flag := 'Y';
		    elsif(l_bnft.mx_wout_ctfn_val is not null and l_bnft.bnft_amt <= l_bnft.mx_wout_ctfn_val ) then
		      hr_utility.set_location('No Create 4',500);
		      l_create_flag := 'N';
		    else
		        hr_utility.set_location('Create 3',500);
		       l_create_flag := 'Y';
		    end if;
		 end if;
	    end if;
	end if;
	hr_utility.set_location('l_create_flag '||l_create_flag,500);

/*     open c_chk_same_comp_obj(g_new_prtt_enrt_rslt_id,p_prtt_enrt_rslt_id,p_per_in_ler_id);
       fetch c_chk_same_comp_obj into l_create_flag;
       if(c_chk_same_comp_obj%notfound) then
         l_create_flag := 'N';
       end if;
       close c_chk_same_comp_obj;*/

       open c_chk_same_event(g_new_prtt_enrt_rslt_id);
       fetch c_chk_same_event into l_nper_in_ler_id ;
       close c_chk_same_event;
       open c_chk_same_event(p_prtt_enrt_rslt_id);
       fetch c_chk_same_event into l_oper_in_ler_id ;
       close c_chk_same_event;
       open c_chk_act_item_exits(p_prtt_enrt_rslt_id);
	     fetch c_chk_act_item_exits into l_dummy1;
	     if(c_chk_act_item_exits%found) then
		l_act_flag := true;
	        hr_utility.set_location('In loop2 false',500);
	     else
	       l_act_flag := false;
	       hr_utility.set_location('In loop2 true',500);
	     end if;
	     close c_chk_act_item_exits;
      if(l_nper_in_ler_id = l_oper_in_ler_id and l_act_flag) then

	 open c_get_actn_items;
	 fetch c_get_actn_items BULK COLLECT into l_act_items;
	 hr_utility.set_location('In loop1',500);
          if(l_act_items.count > 0) then
	     l_act_flag := true;
	     hr_utility.set_location('In loop10 '||l_act_items.count,500);
	  else
            l_act_flag := false;
	    hr_utility.set_location('In loop11',500);
          end if;
	 close c_get_actn_items;


	 open c_get_ctfn;
	 fetch c_get_ctfn BULK COLLECT into l_ctfn;
	 if(l_ctfn.count > 0) then
	    l_ctfn_flag := true;
	 end if;
	 close c_get_ctfn;

	 hr_utility.set_location('Remving action items',500);
	 remove_cert_action_items
	      (p_prtt_enrt_rslt_id  => p_prtt_enrt_rslt_id
	      ,p_effective_date     => p_effective_date
	      ,p_end_date           => l_enrt_cvg_end_dt
	      ,p_business_group_id  => p_business_group_id
	      ,p_validate           => FALSE
	      ,p_datetrack_mode     => hr_api.g_delete
	      ,p_source             => p_source
	      ,p_per_in_ler_id      => l_pen.pen_per_in_ler_id
	      ,p_per_in_ler_ended_id=> l_pen.per_in_ler_id
	      );

           if(l_act_flag and l_create_flag = 'Y' ) then
	   hr_utility.set_location('creating action items',500);
		for i IN l_act_items.FIRST..l_act_items.LAST loop
			ben_PRTT_ENRT_ACTN_api.create_PRTT_ENRT_ACTN
			  (p_validate   => false
			  ,p_effective_date =>  p_effective_date
			  ,p_cmpltd_dt  => l_act_items(i).cmpltd_dt
			  ,p_due_dt  => l_act_items(i).due_dt
			  ,p_rqd_flag   => l_act_items(i).rqd_flag
			  ,p_prtt_enrt_rslt_id  => g_new_prtt_enrt_rslt_id
			  ,p_per_in_ler_id  => p_per_in_ler_id
			  ,p_rslt_object_version_number => l_rslt_object_version_number
			  ,p_actn_typ_id    => l_act_items(i).actn_typ_id
			  ,p_elig_cvrd_dpnt_id   => l_act_items(i).elig_cvrd_dpnt_id
			  ,p_pl_bnf_id     => l_act_items(i).pl_bnf_id
			  ,p_business_group_id  => l_act_items(i).business_group_id
			  ,p_pea_attribute_category  => l_act_items(i).pea_attribute_category
			  ,p_pea_attribute1 => l_act_items(i).pea_attribute1
			  ,p_pea_attribute2 => l_act_items(i).pea_attribute2
			  ,p_pea_attribute3 => l_act_items(i).pea_attribute3
			  ,p_pea_attribute4  => l_act_items(i).pea_attribute4
			  ,p_pea_attribute5  => l_act_items(i).pea_attribute5
			  ,p_pea_attribute6  => l_act_items(i).pea_attribute6
			  ,p_pea_attribute7   => l_act_items(i).pea_attribute7
			  ,p_pea_attribute8 => l_act_items(i).pea_attribute8
			  ,p_pea_attribute9  => l_act_items(i).pea_attribute9
			  ,p_pea_attribute10 => l_act_items(i).pea_attribute10
			  ,p_pea_attribute11 => l_act_items(i).pea_attribute11
			  ,p_pea_attribute12 => l_act_items(i).pea_attribute12
			  ,p_pea_attribute13 => l_act_items(i).pea_attribute13
			  ,p_pea_attribute14  => l_act_items(i).pea_attribute14
			  ,p_pea_attribute15 => l_act_items(i).pea_attribute15
			  ,p_pea_attribute16 => l_act_items(i).pea_attribute16
			  ,p_pea_attribute17  => l_act_items(i).pea_attribute17
			  ,p_pea_attribute18  => l_act_items(i).pea_attribute18
			  ,p_pea_attribute19  => l_act_items(i).pea_attribute19
			  ,p_pea_attribute20 => l_act_items(i).pea_attribute20
			  ,p_pea_attribute21 => l_act_items(i).pea_attribute21
			  ,p_pea_attribute22 => l_act_items(i).pea_attribute22
			  ,p_pea_attribute23  => l_act_items(i).pea_attribute23
			  ,p_pea_attribute24   => l_act_items(i).pea_attribute24
			  ,p_pea_attribute25  => l_act_items(i).pea_attribute25
			  ,p_pea_attribute26 => l_act_items(i).pea_attribute26
			  ,p_pea_attribute27 => l_act_items(i).pea_attribute27
			  ,p_pea_attribute28   => l_act_items(i).pea_attribute28
			  ,p_pea_attribute29 => l_act_items(i).pea_attribute29
			  ,p_pea_attribute30 => l_act_items(i).pea_attribute30
			  ,p_object_version_number  => l_actn_object_version_number
			  ,p_prtt_enrt_actn_id   => l_prtt_enrt_actn_id
			  ,p_effective_start_date => l_actn_start_date
			  ,p_effective_end_date   => l_actn_end_date
			  ,p_gnrt_cm => false  -- Bug 9256641 : Do not generate communications
			  );
	        end loop;
		hr_utility.set_location('created action items',500);
        end if;

        hr_utility.set_location('before creating cert',500);
        if(l_ctfn_flag and l_create_flag = 'Y' ) then
	hr_utility.set_location('creating certifications ',500);
	     for j IN l_ctfn.FIRST..l_ctfn.LAST loop
	        hr_utility.set_location('looping cert ',500);
		ben_PRTT_ENRT_CTFN_PRVDD_api.create_PRTT_ENRT_CTFN_PRVDD
		  (p_validate => false
		  ,p_prtt_enrt_ctfn_prvdd_id => l_prtt_enrt_ctfn_prvdd_id
		  ,p_effective_start_date  => l_ctfn_start_date
		  ,p_effective_end_date => l_ctfn_end_date
		  ,p_enrt_ctfn_rqd_flag  => l_ctfn(j).enrt_ctfn_rqd_flag
		  ,p_enrt_ctfn_typ_cd   => l_ctfn(j).enrt_ctfn_typ_cd
		  ,p_enrt_ctfn_recd_dt => l_ctfn(j).enrt_ctfn_recd_dt
		  ,p_enrt_ctfn_dnd_dt  => l_ctfn(j).enrt_ctfn_dnd_dt
		  ,p_enrt_r_bnft_ctfn_cd => l_ctfn(j).enrt_r_bnft_ctfn_cd
		  ,p_prtt_enrt_rslt_id => g_new_prtt_enrt_rslt_id
		  ,p_prtt_enrt_actn_id  => l_prtt_enrt_actn_id
		  ,p_business_group_id  => l_ctfn(j).business_group_id
		  ,p_pcs_attribute_category  => l_ctfn(j).pcs_attribute_category
		  ,p_pcs_attribute1  => l_ctfn(j).pcs_attribute1
		  ,p_pcs_attribute2  => l_ctfn(j).pcs_attribute2
		  ,p_pcs_attribute3 => l_ctfn(j).pcs_attribute3
		  ,p_pcs_attribute4 => l_ctfn(j).pcs_attribute4
		  ,p_pcs_attribute5 => l_ctfn(j).pcs_attribute5
		  ,p_pcs_attribute6  => l_ctfn(j).pcs_attribute6
		  ,p_pcs_attribute7  => l_ctfn(j).pcs_attribute7
		  ,p_pcs_attribute8  => l_ctfn(j).pcs_attribute8
		  ,p_pcs_attribute9  => l_ctfn(j).pcs_attribute9
		  ,p_pcs_attribute10 => l_ctfn(j).pcs_attribute10
		  ,p_pcs_attribute11 => l_ctfn(j).pcs_attribute11
		  ,p_pcs_attribute12 => l_ctfn(j).pcs_attribute12
		  ,p_pcs_attribute13=> l_ctfn(j).pcs_attribute13
		  ,p_pcs_attribute14  => l_ctfn(j).pcs_attribute14
		  ,p_pcs_attribute15 => l_ctfn(j).pcs_attribute15
		  ,p_pcs_attribute16=> l_ctfn(j).pcs_attribute16
		  ,p_pcs_attribute17  => l_ctfn(j).pcs_attribute17
		  ,p_pcs_attribute18 => l_ctfn(j).pcs_attribute18
		  ,p_pcs_attribute19 => l_ctfn(j).pcs_attribute19
		  ,p_pcs_attribute20 => l_ctfn(j).pcs_attribute20
		  ,p_pcs_attribute21=> l_ctfn(j).pcs_attribute21
		  ,p_pcs_attribute22 => l_ctfn(j).pcs_attribute22
		  ,p_pcs_attribute23  => l_ctfn(j).pcs_attribute23
		  ,p_pcs_attribute24=>l_ctfn(j).pcs_attribute24
		  ,p_pcs_attribute25 =>l_ctfn(j).pcs_attribute25
		  ,p_pcs_attribute26 => l_ctfn(j).pcs_attribute26
		  ,p_pcs_attribute27 => l_ctfn(j).pcs_attribute27
		  ,p_pcs_attribute28 => l_ctfn(j).pcs_attribute28
		  ,p_pcs_attribute29 => l_ctfn(j).pcs_attribute29
		  ,p_pcs_attribute30 => l_ctfn(j).pcs_attribute30
		  ,p_object_version_number  => l_ctfn_object_version_number
		  ,p_effective_date => p_effective_date
		  );
		end loop;
           end if;
	   g_new_prtt_enrt_rslt_id := -1;
      else
	      remove_cert_action_items
	      (p_prtt_enrt_rslt_id  => p_prtt_enrt_rslt_id
	      ,p_effective_date     => p_effective_date
	      ,p_end_date           => l_enrt_cvg_end_dt
	      ,p_business_group_id  => p_business_group_id
	      ,p_validate           => FALSE
	      ,p_datetrack_mode     => hr_api.g_delete
	      ,p_source             => p_source
	      ,p_per_in_ler_id      => l_pen.pen_per_in_ler_id
	      ,p_per_in_ler_ended_id=> l_pen.per_in_ler_id
	      );
      end if;

      /* Commented code for Bug 7561395
      remove_cert_action_items
      (p_prtt_enrt_rslt_id  => p_prtt_enrt_rslt_id
      ,p_effective_date     => p_effective_date
      ,p_end_date           => l_enrt_cvg_end_dt
      ,p_business_group_id  => p_business_group_id
      ,p_validate           => FALSE
      ,p_datetrack_mode     => hr_api.g_delete
      ,p_source             => p_source
      ,p_per_in_ler_id      => l_pen.pen_per_in_ler_id
      ,p_per_in_ler_ended_id=> l_pen.per_in_ler_id
      );*/

      /* Ended code for Bug 7561395*/

      --
      l_step := 120;
      --
      hr_utility.set_location(' Before get_ben_pen_upd_dt_mode '||p_datetrack_mode,123);
      get_ben_pen_upd_dt_mode
        (p_effective_date         => p_effective_date
        ,p_base_key_value         => p_prtt_enrt_rslt_id
        ,P_desired_datetrack_mode => p_datetrack_mode
        ,P_datetrack_allow        => l_datetrack_mode
        ,p_ler_typ_cd             => l_ler_typ_cd -- Bug 2739965
        );
      hr_utility.set_location(' After get_ben_pen_upd_dt_mode '||l_datetrack_mode,123);
      --
      l_step := 125;
      --
      if g_debug then
         hr_utility.set_location('enrt_cvg_end_dt='||l_enrt_cvg_end_dt,19);
      end if;
      --
      --CFW. If deleting a suspended result, remove interim pen id
      -- below code is commenetd as part of 5347887.
      /*l_rplcs_sspndd_rslt_id := hr_api.g_number;
      if l_pen.sspndd_flag = 'Y' then
         l_rplcs_sspndd_rslt_id := null;
      end if;*/
      -- bug#5363388
      if l_enrt_cvg_end_dt < l_pen.enrt_cvg_strt_dt then
         --
         if l_pen.per_in_ler_id <> l_pen.pen_per_in_ler_id then
            l_prtt_enrt_rslt_Stat_cd := 'BCKDT';
         end if;
         --
      end if;
--Bug 5499809
--Void the enrollment if the delete is being performed in the same life event and that life event is not unrestricted LE
      if ((l_pen.per_in_ler_id = l_pen.pen_per_in_ler_id) and (l_ler_typ_cd <> 'SCHEDDU') ) then

        --Bug#:6641853
        OPEN c_get_correction_info (p_prtt_enrt_rslt_id,
                                    l_pen.effective_start_date,
                                    l_pen.per_in_ler_id
                                    );
        FETCH c_get_correction_info INTO l_get_correction_info;
        CLOSE c_get_correction_info;

       IF l_get_correction_info.place_holder='X' THEN
        l_prtt_enrt_rslt_Stat_cd:=NULL;
        l_datetrack_mode:='CORRECTION';
       ELSE

         --5663280
         open c_check_carry_fwd_enrt(p_prtt_enrt_rslt_id, p_per_in_ler_id, l_pen.enrt_cvg_strt_dt,
                                     l_pen.effective_start_date);
         fetch c_check_carry_fwd_enrt into l_check_carry_fwd_enrt;
         close c_check_carry_fwd_enrt;

         if l_check_carry_fwd_enrt is null then
         	 l_prtt_enrt_rslt_Stat_cd := 'VOIDD';
         end if;
       END IF;
      end if;

      if g_debug then
           hr_utility.set_location('prtt stat cd'||l_prtt_enrt_rslt_Stat_cd,20);
           hr_utility.set_location('l_ler_typ_cd'||l_ler_typ_cd,20);
       end if;
       ----------------------------Bug 8222481
      if l_prtt_enrt_rslt_Stat_cd = 'VOIDD' then
      If (substr(nvl(l_cvg_end_dt_cd, 'X'), 1, 1) = 'W' or
          substr(nvl(l_cvg_end_dt_cd, 'X'), 1, 2) = 'LW' ) then
         -------get the ended pen ID
         open c_get_ended_pen(p_per_in_ler_id,l_pen.pl_typ_id,l_pen.pgm_id);
	 fetch c_get_ended_pen bulk collect into l_get_ended_pen;
	     hr_utility.set_location('Total ended pen : '||c_get_ended_pen%rowcount,1);
           --Removed this part,since the fix works only if one plan in a plan type is de-enrolled.
	   /*  if c_get_ended_pen%rowcount > 1 then
	      hr_utility.set_location('enrolled into more than 1 plan',1);
	     open c_get_last_pil(l_get_ended_pen(1).person_id);
	      fetch c_get_last_pil into l_get_last_pil;

              if c_get_last_pil%found then
		 for i in l_get_ended_pen.first..l_get_ended_pen.last loop
		 open c_last_pil_pen1(l_get_last_pil.per_in_ler_id,l_pen.pl_id,l_get_ended_pen(i).pgm_id);
		 fetch c_last_pil_pen1 into l_last_pil_pen1;
		 if c_last_pil_pen1%found then
                 l_del_next_chg_pen := l_last_pil_pen1;
		 hr_utility.set_location('l_del_next_chg_pen.pen_id : '||l_del_next_chg_pen.prtt_enrt_rslt_id,1);
		 end if;
		 close c_last_pil_pen1;
		 end loop;
	       end if;
	       close c_get_last_pil;
	    elsif c_get_ended_pen%rowcount = 1 then */
	     if c_get_ended_pen%rowcount = 1 then
	      hr_utility.set_location('enroled into 1 plan only',1);
	      open c_get_last_pil(l_get_ended_pen(1).person_id,l_get_ended_pen(1).prtt_enrt_rslt_id);  -----Bug 8688513
	      fetch c_get_last_pil into l_get_last_pil;

              if c_get_last_pil%found then
	         hr_utility.set_location('l_get_last_pil.per_in_ler_id : '||l_get_last_pil.per_in_ler_id,1);
	         open c_last_pil_pen(l_get_last_pil.per_in_ler_id,l_get_ended_pen(1).prtt_enrt_rslt_id);
		 fetch c_last_pil_pen into l_last_pil_pen;
		 close c_last_pil_pen;
		 l_del_next_chg_pen := l_last_pil_pen;
		 hr_utility.set_location('l_del_next_chg_pen.prtt_enrt_rslt_id : '||l_del_next_chg_pen.prtt_enrt_rslt_id,1);
		  --------delete the next change corresponding to old pen
		 ben_prtt_enrt_result_api.delete_prtt_enrt_result
              (p_validate                => false,
               p_prtt_enrt_rslt_id       => l_del_next_chg_pen.prtt_enrt_rslt_id,
               p_effective_start_date    => p_effective_start_date,
               p_effective_end_date      => p_effective_end_date,
               p_object_version_number   => l_del_next_chg_pen.object_version_number,
               p_effective_date          => l_del_next_chg_pen.effective_start_date,
               p_datetrack_mode          => hr_api.g_delete_next_change,
               p_multi_row_validate      => FALSE);

	      end if;
	      close c_get_last_pil;
	       end if;
	       close c_get_ended_pen;

      end if;
      end if;
      ---------------Bug 8222481
--End Bug 5499809

      ben_prtt_enrt_result_api.update_prtt_enrt_result
        (p_validate                => FALSE
        ,p_prtt_enrt_rslt_id       => p_prtt_enrt_rslt_id
        ,p_effective_start_date    => p_effective_start_date
        ,p_effective_end_date      => p_effective_end_date
        ,p_per_in_ler_id           => l_pen.per_in_ler_id
        ,p_ler_id                  => l_pen.ler_id
        ,p_enrt_cvg_thru_dt        => l_enrt_cvg_end_dt
        --,p_rplcs_sspndd_rslt_id    => l_rplcs_sspndd_rslt_id /* 5347887*/
        ,p_object_version_number   => l_pen.pen_ovn
        ,p_effective_date          => p_effective_date
        ,p_datetrack_mode          => l_datetrack_mode
        ,p_multi_row_validate      => p_multi_row_validate
        ,p_business_group_id       => p_business_group_id
        ,p_prtt_enrt_rslt_stat_cd  => l_prtt_enrt_rslt_Stat_cd
        );
      l_step := 126;
      --
      if p_source is null or
        p_source <> 'benelinf' then
        ben_ext_chlg.log_benefit_chg
          (p_action                      => 'DELETE'
          ,p_old_pl_id                   =>  l_pen.pl_id
          ,p_old_oipl_id                 =>  l_pen.oipl_id
          ,p_old_enrt_cvg_strt_dt        =>  l_pen.enrt_cvg_strt_dt
          ,p_old_enrt_cvg_end_dt         =>  l_pen.enrt_cvg_thru_dt
          ,p_pl_id                       =>  l_pen.pl_id
          ,p_oipl_id                     =>  l_pen.oipl_id
          ,p_enrt_cvg_strt_dt            =>  l_pen.enrt_cvg_strt_dt
          ,p_enrt_cvg_end_dt             =>  l_enrt_cvg_end_dt
          ,p_prtt_enrt_rslt_id           =>  p_prtt_enrt_rslt_id
          ,p_per_in_ler_id               =>  l_pen.per_in_ler_id
          ,p_person_id                   =>  l_pen.person_id
          ,p_business_group_id           =>  p_business_group_id
          ,p_effective_date              =>  p_effective_date
          );
      end if;
      l_step := 127;
      --
      if l_pen.pgm_id is not null then
        ben_provider_pools.remove_bnft_prvdd_ldgr
          (p_prtt_enrt_rslt_id  => p_prtt_enrt_rslt_id
          ,p_effective_date     => p_effective_date
          ,p_business_group_id  => p_business_group_id
          ,p_validate           => FALSE
          ,p_datetrack_mode     => hr_api.g_delete
          );
      end if;
      --
    end if;
    -- Special Case - Bug#5123
  Elsif (p_effective_date > l_pen.enrt_cvg_thru_dt)
       /* and l_pen.SSPNDD_FLAG = 'N'*/ then
    --    do nothing
        null;
    --
    --     Case 3: Coverage not started yet. Elected and deleted in same day.
    --     Case 4: Coverage not started yet. Elected and deleted not in same day.
    --               * Date-track end dated.
  Else
    --- if the coverage starts in future date and the per_in_ler_id is not the same
    ---  the result are not deleted (ZAP), zaping create the problem if the current
    ---  LE is backedout, it need the result to reintiate the previos LE
    ---
    Get_election_date(p_effective_date    => p_effective_date
                           ,p_prtt_enrt_rslt_id => p_prtt_enrt_rslt_id
                           ,p_business_group_id => p_business_group_id
                           ,p_date => l_date
                           ,p_pil_id => l_pil_id
                           );
    l_step := 135;
    if g_debug then
       hr_utility.set_location('p_datetrack_mode='||p_datetrack_mode,20);
    end if;
    if p_source is null or p_source = 'benelinf' then
        -- Bug 2537720
        -- This is not allowing to update the enrollment on the same date for
        -- the suspended enrollment.So added the l_pen.effective_start_date < p_effective_date
        -- condition.
        if p_datetrack_mode=hr_api.g_update
           and l_pen.effective_start_date < p_effective_date
	   and p_per_in_ler_id <> l_pil_id then -----Added for the Bug 7311284
           --
           l_eff_dt:=p_effective_date-1;
         else
           l_eff_dt:=p_effective_date;
         end if;
    else
        l_eff_dt := p_effective_date;
    end if;
    if g_debug then
       hr_utility.set_location('per in ler ='|| p_per_in_ler_id ||' old ' || l_pil_id,21);
       hr_utility.set_location('future dated cvg ='||l_pen.enrt_cvg_strt_dt,21);
    end if;
    --- bug 2546259  the if condition added to treat the future dated Coverage
    --- if future dated cvg exisit dont zap the result, if the current LE
    --- Backedout then the future dated result hase to be  restored
    --- Instead of zaping the result it is voided now
    if p_effective_date < l_pen.enrt_cvg_strt_dt
        and p_per_in_ler_id <> l_pil_id /* and l_pen.SSPNDD_FLAG = 'N' */  then
      -- Voiding future dated coverage started in previous LE
      --
      if g_debug then
           hr_utility.set_location('future dated cvg ='||l_pen.enrt_cvg_strt_dt,21);
      end if;
      If substr(nvl(l_cvg_end_dt_cd, 'X'), 1, 1) = 'W' or
           substr(nvl(l_cvg_end_dt_cd, 'X'), 1, 2) = 'LW' then
          --Bug 2847110
          open c_new_cvg_strt_dt(l_pen.pl_typ_id, l_pen.ptip_id, l_pen.pl_id,
                                 l_enrt_cvg_strt_dt );
          fetch c_new_cvg_strt_dt into l_new_enrt_cvg_strt_dt;
        if c_new_cvg_strt_dt%found then
            --
            l_enrt_cvg_end_dt := nvl(l_new_enrt_cvg_strt_dt- 1,l_enrt_cvg_end_dt);
            close c_new_cvg_strt_dt;
        else
            close c_new_cvg_strt_dt;
            --
            open c_new_cvg_strt_dt(l_pen.pl_typ_id, l_pen.ptip_id,-999,
                                   l_enrt_cvg_strt_dt );
            fetch c_new_cvg_strt_dt into l_new_enrt_cvg_strt_dt;
            if c_new_cvg_strt_dt%found then
              l_enrt_cvg_end_dt := nvl(l_new_enrt_cvg_strt_dt - 1, l_enrt_cvg_end_dt ) ;
            end if;
            close c_new_cvg_strt_dt;
            --
        end if;
        --
      End if;
      --
      if g_debug then
          hr_utility.set_location('c_new_cvg_strt_dt'||l_new_enrt_cvg_strt_dt,199);
          hr_utility.set_location('l_enrt_cvg_end_dt'||l_enrt_cvg_end_dt,199);
      end if;
        -- ikasire: Added the cases starting with 'LW'
        -- fixed typo - changed from l_cvg_end_dt_cd to l_rt_end_dt_cd in
        -- the if condition
      If substr(nvl(l_rt_end_dt_cd, 'X'), 1, 1) = 'W' or
           substr(nvl(l_rt_end_dt_cd, 'X'), 1, 2) = 'LW'
      then
          --
            if g_debug then
              hr_utility.set_location(' pen api rt strt dt ' || l_rt_strt_dt, 299 );
              hr_utility.set_location(' pen api rt end dt ' || l_rt_end_dt, 299 );
            end if;
            l_rt_end_dt := nvl(l_rt_strt_dt - 1,l_rt_end_dt) ;
      End if;
         --
      If l_enrt_cvg_end_dt is NULL then
           rpt_error(p_proc => l_proc, p_step => l_step);
           fnd_message.set_name('BEN','BEN_91702_NOT_DET_CVG_END_DT');
--           fnd_message.raise_error;
           raise l_fnd_message_exception;
      End if;
      --
      If l_rt_end_dt is NULL then
           rpt_error(p_proc => l_proc, p_step => l_step);
           fnd_message.set_name('BEN','BEN_91703_NOT_DET_RATE_END_DT');
--           fnd_message.raise_error;
           raise l_fnd_message_exception;
      end if;
      --
      -- Update rt_end_dt in prtt_rate_val table
      --
      l_step := 35;
      if g_debug then
           hr_utility.set_location(l_proc,3456);
      end if;
          --  rate is having non recurring
      for l_prv in c_prv3 (p_per_in_ler_id) loop
             --check whether rate is non-recurring
          open c_abr(l_prv.acty_base_rt_id);
            fetch c_abr into l_abr;
          close c_abr;
             --
        if l_abr.processing_type = 'N' or
                l_abr.rcrrg_cd = 'ONCE' then
                null;
        else
               exit;
        end if;
        if g_debug then
              hr_utility.set_location('delete prtt',3459);
        end if;
        update ben_enrt_rt
            set prtt_rt_val_id = null
          where enrt_rt_id = l_prv.enrt_rt_id;
        --
        ben_prtt_rt_val_api.delete_prtt_rt_val
               (P_VALIDATE                => FALSE
               ,P_PRTT_RT_VAL_ID          => l_prv.prtt_rt_val_id
               ,P_OBJECT_VERSION_NUMBER   => l_prv.object_version_number
               ,P_EFFECTIVE_DATE          => l_eff_dt
               ,p_person_id               => l_pen.person_id
               ,p_business_group_id       => p_business_group_id
               );
      end loop;
      For l_prv in c_prv2 loop
        if g_debug then
              hr_utility.set_location(l_proc,3457);
        end if;
        l_prv_count := l_prv_count + 1;
        ben_prtt_rt_val_api.update_prtt_rt_val
                (P_VALIDATE                => FALSE
                ,P_PRTT_RT_VAL_ID          => l_prv.prtt_rt_val_id
                ,P_RT_END_DT               => l_rt_end_dt
                ,p_person_id               => l_pen.person_id
             --Bug#2625060 - for converted data, null is passed for activity base rt id
             --   ,p_acty_base_rt_id         => l_prv.acty_base_rt_id
                ,p_input_value_id          => l_prv.input_value_id
                ,p_element_type_id         => l_prv.element_type_id
                ,p_ended_per_in_ler_id     => p_per_in_ler_id
                ,p_business_group_id       => p_business_group_id
                ,p_prtt_rt_val_stat_cd     => 'BCKDT'
                ,P_OBJECT_VERSION_NUMBER   => l_prv.object_version_number
                ,P_EFFECTIVE_DATE          => p_effective_date
               );
        if g_debug then
              hr_utility.set_location(l_proc,3458);
        end if;
      end loop;
      --
      --   Adjust overlapping rates . Bug 5391554
      --
      -- basu
      hr_utility.set_location('p_per_in_ler_id '||p_per_in_ler_id,44333);
      --
      open c_get_pgm_extra_info(l_pen.pgm_id);
      fetch c_get_pgm_extra_info into l_adjust;
      if c_get_pgm_extra_info%found then
        if l_adjust = 'Y' then
          for l_prv5 in c_prv5(l_rt_end_dt) loop
          --
          if g_debug then
            hr_utility.set_location('Adjusting rate '||l_rt_end_dt,111);
          end if;
            ben_prtt_rt_val_api.update_prtt_rt_val
            (P_VALIDATE                => FALSE
            ,P_PRTT_RT_VAL_ID          => l_prv5.prtt_rt_val_id
            ,P_RT_END_DT               => l_rt_end_dt
            ,p_person_id               => l_pen.person_id
            ,p_input_value_id          => l_prv5.input_value_id
            ,p_element_type_id         => l_prv5.element_type_id
            ,p_ended_per_in_ler_id     => p_per_in_ler_id
            ,p_business_group_id       => p_business_group_id
            ,P_OBJECT_VERSION_NUMBER   => l_prv5.object_version_number
            ,P_EFFECTIVE_DATE          => p_effective_date
            );
          end loop;
        end if;
      end if;
      close c_get_pgm_extra_info;

      -- Bug#2038814 - cursor above updates only the last prtt_rt_val and if there
      -- any future dated prtt_rt_val, rows with rt end date greater than the calc
      --- ulated rt end
      -- date needs to be updated
      -- Bug 2739965
      if l_benmngle_parm_rec.mode_cd = 'S' or l_ler_typ_cd = 'SCHEDDU' then
        if g_debug then
                hr_utility.set_location('ben mngle mode',111);
                hr_utility.set_location('rate end date'||l_rt_end_dt,111);
        end if;
        --
        For l_prv4 in c_prv4 (l_rt_end_dt) loop
               -- 2739965 In case of unrestricted enrollment, this happens only when there are future rates
               -- and they got deleted as part of c_prv2 process above. Lets us throw this error
               -- here warning the user about the deletion of the future rate.
          --
          if fnd_global.conc_request_id in ( 0,-1) then
               -- Issue a warning to the user.  These will display on the enrt forms.
                 ben_warnings.load_warning
                  (p_application_short_name  => 'BEN',
                   p_message_name            => 'BEN_93369_DEL_FUT_RATE',
                   p_parma     => fnd_date.date_to_chardate( l_prv4.rt_end_dt+1 ),
                   p_parmb     => l_pen.pl_name || ' '||l_pen.opt_name,
                   p_person_id => l_pen.person_id);
          end if;
               --
          ben_prtt_rt_val_api.update_prtt_rt_val
                  (P_VALIDATE                => FALSE
                  ,P_PRTT_RT_VAL_ID          => l_prv4.prtt_rt_val_id
                  ,P_RT_END_DT               => l_rt_end_dt
                  ,p_person_id               => l_pen.person_id
             --Bug#2625060 - for converted data, null is passed for activity base rt id
                --  ,p_acty_base_rt_id         => l_prv4.acty_base_rt_id
                  ,p_input_value_id          => l_prv4.input_value_id
                  ,p_element_type_id         => l_prv4.element_type_id
                  ,p_ended_per_in_ler_id     => p_per_in_ler_id
                  ,p_business_group_id       => p_business_group_id
                  ,p_prtt_rt_val_stat_cd     => 'BCKDT' -- Bug 4739922: Backout the Result/ (do not VOIDD).
                  ,P_OBJECT_VERSION_NUMBER   => l_prv4.object_version_number
                  ,P_EFFECTIVE_DATE          => p_effective_date
                  );
        end loop;
      end if;
      if g_debug then
         hr_utility.set_location(l_proc,3459);
      end if;
      --
      -- Get dependent coverage End date. If Participant coverage end date
      -- is greater than dependent coverage end date, then use participant.
      --
      l_step := 40;
      --
      calc_dpnt_cvg_dt
              (p_calc_end_dt         => TRUE
              ,P_calc_strt_dt        => FALSE
              ,p_per_in_ler_id       => l_pen.per_in_ler_id
              ,P_person_id           => l_pen.person_id
              ,p_pgm_id              => l_pen.pgm_id
              ,p_pl_id               => l_pen.pl_id
              ,p_oipl_id             => l_pen.oipl_id
              ,p_ptip_id             => l_pen.ptip_id
              ,p_ler_id              => l_pen.ler_id
              ,P_BUSINESS_GROUP_ID   => p_business_group_id
              ,P_EFFECTIVE_DATE      => p_effective_date
              ,P_RETURNED_END_DT     => l_dpnt_cvg_end_dt
              ,P_RETURNED_STRT_DT    => l_dump_date
              ,p_enrt_cvg_end_dt     => l_enrt_cvg_end_dt
              );
      --
      l_step := 90;
      --
      -- bug 3327224
      /*
        If l_dpnt_cvg_end_dt is not NULL then
           l_dpnt_cvg_thru_dt := least(l_enrt_cvg_end_dt, l_dpnt_cvg_end_dt);
        End if;
      */
      l_dpnt_cvg_thru_dt :=  l_dpnt_cvg_end_dt;
      --
      -- Unhook dependent rows
      --
      l_step := 110;
      unhook_dpnt
            (p_validate               => FALSE
            ,p_prtt_enrt_rslt_id      => p_prtt_enrt_rslt_id
            ,p_per_in_ler_id          => l_pen.per_in_ler_id
            ,p_cvg_thru_dt            => l_dpnt_cvg_thru_dt
            ,p_business_group_id      => p_business_group_id
            ,p_effective_date         => p_effective_date
            ,p_datetrack_mode         => p_datetrack_mode
            ,p_called_from            => p_source
            );
      unhook_bnf
            (p_validate               => FALSE
            ,p_prtt_enrt_rslt_id      => p_prtt_enrt_rslt_id
            ,p_per_in_ler_id          => l_pen.per_in_ler_id
            ,p_dsgn_thru_dt           => l_enrt_cvg_end_dt
            ,p_business_group_id      => p_business_group_id
            ,p_effective_date         => p_effective_date
            ,p_datetrack_mode         => p_datetrack_mode
            );
      --
      l_step := 120;
      --
      get_ben_pen_upd_dt_mode
            (p_effective_date         => p_effective_date
            ,p_base_key_value         => p_prtt_enrt_rslt_id
            ,P_desired_datetrack_mode => p_datetrack_mode
            ,P_datetrack_allow        => l_datetrack_mode
            ,p_ler_typ_cd             => l_ler_typ_cd  -- Bug 2739965
            );
      --
      l_step := 125;
      if g_debug then
             hr_utility.set_location('enrt_cvg_end_dt='||l_enrt_cvg_end_dt,19);
      end if;
      ben_prtt_enrt_result_api.update_prtt_enrt_result
                (p_validate                => FALSE
                ,p_prtt_enrt_rslt_id       => p_prtt_enrt_rslt_id
                ,p_effective_start_date    => p_effective_start_date
                ,p_effective_end_date      => p_effective_end_date
                ,p_per_in_ler_id           => l_pen.per_in_ler_id
                ,p_ler_id                  => l_pen.ler_id
                ,p_enrt_cvg_thru_dt        => l_enrt_cvg_end_dt
                ,p_object_version_number   => l_pen.pen_ovn
                ,p_prtt_enrt_rslt_stat_cd  => 'BCKDT' -- Bug 4739922: Backout the Result/ (do not VOIDD).
                ,p_effective_date          => p_effective_date
                ,p_datetrack_mode          => l_datetrack_mode
                ,p_multi_row_validate      => p_multi_row_validate
                ,p_business_group_id       => p_business_group_id
                );
      --
      l_step := 126;
      --
      if l_pen.pgm_id is not null then
              ben_provider_pools.remove_bnft_prvdd_ldgr
                (p_prtt_enrt_rslt_id  => p_prtt_enrt_rslt_id
                ,p_effective_date     => p_effective_date
                ,p_business_group_id  => p_business_group_id
                ,p_validate           => FALSE
                ,p_datetrack_mode     => hr_api.g_delete
              );
      end if;
      --
      --- # 2546259
    Else
      --
      -- Bug  2093859 : When coverage is not started just zap all the data.
      --
       --Bug#:6641853
       OPEN c_get_correction_info (p_prtt_enrt_rslt_id,
                                   l_pen.effective_start_date,
                                    l_pen.per_in_ler_id
                                  );
       FETCH c_get_correction_info INTO l_get_correction_info;
       CLOSE c_get_correction_info;
       IF l_get_correction_info.place_holder='X' THEN
        l_prtt_enrt_rslt_Stat_cd:=NULL;
        l_datetrack_mode:='CORRECTION';
       ELSE
        l_datetrack_mode :=  hr_api.g_zap;
       END IF;
      --
      if p_source  = 'beninelg' then
         l_datetrack_mode := hr_api.g_delete;
      elsif p_source is null or --CFW
             p_source = 'benuneai' then
            l_datetrack_mode := p_datetrack_mode;
      end if;
      if g_debug then
             hr_utility.set_location('l_datetrack_mode='||l_datetrack_mode,20);
      end if;
      l_step := 140;
      --
      -- Added call the below code for 3797391 to get all dates properly
      --
      if g_debug then
        hr_utility.set_location('calc_dpnt_cvg_dt ', 100);
      end if;
      --
      calc_dpnt_cvg_dt
        (p_calc_end_dt         => TRUE
        ,P_calc_strt_dt        => FALSE
        ,p_per_in_ler_id       => l_pen.per_in_ler_id
        ,P_person_id           => l_pen.person_id
        ,p_pgm_id              => l_pen.pgm_id
        ,p_pl_id               => l_pen.pl_id
        ,p_oipl_id             => l_pen.oipl_id
        ,p_ptip_id             => l_pen.ptip_id
        ,p_ler_id              => l_pen.ler_id
        ,P_BUSINESS_GROUP_ID   => p_business_group_id
        ,P_EFFECTIVE_DATE      => p_effective_date
        ,P_RETURNED_END_DT     => l_dpnt_cvg_end_dt
        ,P_RETURNED_STRT_DT    => l_dump_date
        ,p_enrt_cvg_end_dt     => l_enrt_cvg_end_dt
        );
      --
      l_step := 40;
      --
      l_dpnt_cvg_thru_dt := l_dpnt_cvg_end_dt;
          --
          -- bug 3797391
          --
      unhook_bnf
            (p_validate               => FALSE
            ,p_prtt_enrt_rslt_id      => p_prtt_enrt_rslt_id
            ,p_per_in_ler_id          => l_pen.per_in_ler_id
            ,p_dsgn_thru_dt           => l_enrt_cvg_end_dt
            ,p_business_group_id      => p_business_group_id
            ,p_effective_date         =>  l_eff_dt -- Bug  2093859 p_effective_date
            ,p_datetrack_mode         => l_datetrack_mode
            ,p_rslt_delete_flag        => TRUE
            );

             hr_utility.set_location('p_prtt_enrt_rslt_id ='||p_prtt_enrt_rslt_id,20);
             hr_utility.set_location('l_pen.per_in_ler_id ='||l_pen.per_in_ler_id,20);
             hr_utility.set_location('l_dpnt_cvg_thru_dt ='||to_char(l_dpnt_cvg_thru_dt),20);
             hr_utility.set_location('l_eff_dt ='||to_char(l_eff_dt),20);
             hr_utility.set_location('p_source ='||p_source,20);
      --
      l_step := 150;
      --
      unhook_dpnt
            (p_validate                => FALSE
            ,p_prtt_enrt_rslt_id       => p_prtt_enrt_rslt_id
            ,p_per_in_ler_id           => l_pen.per_in_ler_id
            ,p_cvg_thru_dt             => l_dpnt_cvg_thru_dt
            ,p_business_group_id       => p_business_group_id
            ,p_effective_date          => l_eff_dt
            ,p_datetrack_mode          => l_datetrack_mode
            ,p_rslt_delete_flag        => TRUE
            ,p_called_from             => p_source    );
      --
      l_step := 160;
      --
      if (l_pen.elig_per_elctbl_chc_id is not NULL) then
            -- Bug 2627078
            -- if called from delete_enrollment then
            -- we need to get the current_enrollment result id
            -- populated when the interim is getting deleted.
            --
            l_current_result_id := null ;
            --
        if p_source = 'delete_enrollment' then
              --
              open c_curr_rslt (l_pen.person_id, l_pen.pgm_id,
                                l_pen.pl_id, l_pen.oipl_id, p_per_in_ler_id ) ;
              fetch c_curr_rslt into l_current_result_id ;
              close  c_curr_rslt ;
              --
        end if ;
        --
        ben_ELIG_PER_ELC_CHC_api.update_ELIG_PER_ELC_CHC
              (p_validate                => FALSE
              ,p_elig_per_elctbl_chc_id  => l_pen.elig_per_elctbl_chc_id
              ,p_prtt_enrt_rslt_id       => l_current_result_id -- NULL
              ,p_object_version_number   => l_pen.epe_ovn
              ,p_effective_date          => l_eff_dt
              );
      end if;
      --
      l_step := 136;
      --

      /* Added code for Bug 7561395*/
       hr_utility.set_location('delete_enrollment ',500);
       hr_utility.set_location('Unhook dependent rows ', 500);
       hr_utility.set_location('p_prtt_enrt_rslt_ids '||p_prtt_enrt_rslt_id, 504);
       hr_utility.set_location('l_pen.pen_per_in_ler_id '||l_pen.pen_per_in_ler_id, 504);
       hr_utility.set_location('l_pen.per_in_ler_id '||l_pen.per_in_ler_id, 504);
       hr_utility.set_location('p_pen_per_in_ler_id '||p_per_in_ler_id, 504);
       hr_utility.set_location('g_new_prtt_enrt_rslt_id '||g_new_prtt_enrt_rslt_id, 504);

       /* Bug 8669907:
         if(action item exists for the pen_id ) do not create
	 else
	    if(Participant has selected diff comp obj) do not create
	    else   if(not enter value at enrollment) perform validations before creating action items
	           else perform validations before creating action items
	    Set the l_create_flag to 'Y' if action item has to be created */

       open c_chk_act_item_exits(g_new_prtt_enrt_rslt_id);
       fetch c_chk_act_item_exits into l_dummy1;
       if(c_chk_act_item_exits%found) then
           hr_utility.set_location('No Create 1',500);
           close c_chk_act_item_exits;
	   l_create_flag := 'N';
        else
           close c_chk_act_item_exits;
           open c_chk_same_comp_obj(g_new_prtt_enrt_rslt_id,p_prtt_enrt_rslt_id,p_per_in_ler_id);
           fetch c_chk_same_comp_obj into l_create_flag;
	    if(c_chk_same_comp_obj%notfound) then
	         hr_utility.set_location('No Create 2',500);
	         close c_chk_same_comp_obj;
		 l_create_flag := 'N';
	    else
	         close c_chk_same_comp_obj;
		 open c_bnft_amt(g_new_prtt_enrt_rslt_id,p_per_in_ler_id);
		 fetch c_bnft_amt into l_bnft ;
		 close c_bnft_amt;
		 if(l_bnft.entr_val_at_enrt_flag = 'N') then
		    if(l_bnft.cvg_mlt_cd = 'FLRNG') then
		       if(l_bnft.bnft_amt > l_bnft.mx_val) then
		          hr_utility.set_location('FLRNG Create ',500);
		          l_create_flag := 'Y';
		       else
		         hr_utility.set_location('FLRNG No Create',500);
		         l_create_flag := 'N';
		       end if;
		    else
		      hr_utility.set_location('Create 1',500);
		      l_create_flag := 'Y';
		    end if;
		 else
		   if(l_bnft.mx_wout_ctfn_val is not null and l_bnft.bnft_amt > l_bnft.mx_wout_ctfn_val ) then
		      hr_utility.set_location('Create 2',500);
		      l_create_flag := 'Y';
		    elsif(l_bnft.mx_wout_ctfn_val is not null and l_bnft.bnft_amt <= l_bnft.mx_wout_ctfn_val ) then
		      hr_utility.set_location('No Create 4',500);
		      l_create_flag := 'N';
		    else
		       hr_utility.set_location('Create 3',500);
		       l_create_flag := 'Y';
		    end if;
		 end if;
	    end if;
	end if;
        hr_utility.set_location('l_create_flag '||l_create_flag,500);

       /*open c_chk_same_comp_obj(g_new_prtt_enrt_rslt_id,p_prtt_enrt_rslt_id,p_per_in_ler_id);
       fetch c_chk_same_comp_obj into l_create_flag;
       if(c_chk_same_comp_obj%notfound) then
         l_create_flag := 'N';
       end if;
       close c_chk_same_comp_obj;*/

       open c_chk_same_event(g_new_prtt_enrt_rslt_id);
       fetch c_chk_same_event into l_nper_in_ler_id ;
       close c_chk_same_event;
       open c_chk_same_event(p_prtt_enrt_rslt_id);
       fetch c_chk_same_event into l_oper_in_ler_id ;
       close c_chk_same_event;
       hr_utility.set_location('Old per_in_ler '||l_oper_in_ler_id, 500);
       hr_utility.set_location('new per_in_ler  '||l_nper_in_ler_id, 500);
       open c_chk_act_item_exits(p_prtt_enrt_rslt_id);
	     fetch c_chk_act_item_exits into l_dummy1;
	     if(c_chk_act_item_exits%found) then
		l_act_flag := true;
	        hr_utility.set_location('In loop2 false',500);
	     else
	       l_act_flag := false;
	       hr_utility.set_location('In loop2 true',500);
	     end if;
	     close c_chk_act_item_exits;
      if(l_nper_in_ler_id = l_oper_in_ler_id and l_act_flag) then
	 open c_get_actn_items;
	 fetch c_get_actn_items BULK COLLECT into l_act_items;
	  hr_utility.set_location('In loop1',500);
          if(l_act_items.count > 0) then
	     l_act_flag := true;
	     hr_utility.set_location('In loop10 '||l_act_items.count,500);
	  else
            l_act_flag := false;
	    hr_utility.set_location('In loop11',500);
          end if;
	 close c_get_actn_items;


	 open c_get_ctfn;
	 fetch c_get_ctfn BULK COLLECT into l_ctfn;
	 if(l_ctfn.count > 0) then
	    l_ctfn_flag := true;
	 end if;
	 close c_get_ctfn;

	 hr_utility.set_location('Remving action items',500);
	 remove_cert_action_items
            (p_prtt_enrt_rslt_id  => p_prtt_enrt_rslt_id
            ,p_effective_date     => l_eff_dt
            ,p_business_group_id  => p_business_group_id
            ,p_validate           => FALSE
            ,p_datetrack_mode     => l_datetrack_mode
            ,p_source             => p_source
            ,p_per_in_ler_id      => l_pen.pen_per_in_ler_id
            ,p_per_in_ler_ended_id=> l_pen.per_in_ler_id
            );

           if(l_act_flag and l_create_flag = 'Y' ) then
	   hr_utility.set_location('creating action items',500);
		 for i IN l_act_items.FIRST..l_act_items.LAST loop
			ben_PRTT_ENRT_ACTN_api.create_PRTT_ENRT_ACTN
			  (p_validate   => false
			  ,p_effective_date =>  p_effective_date
			  ,p_cmpltd_dt  => l_act_items(i).cmpltd_dt
			  ,p_due_dt  => l_act_items(i).due_dt
			  ,p_rqd_flag   => l_act_items(i).rqd_flag
			  ,p_prtt_enrt_rslt_id  => g_new_prtt_enrt_rslt_id
			  ,p_per_in_ler_id  => p_per_in_ler_id
			  ,p_rslt_object_version_number => l_rslt_object_version_number
			  ,p_actn_typ_id    => l_act_items(i).actn_typ_id
			  ,p_elig_cvrd_dpnt_id   => l_act_items(i).elig_cvrd_dpnt_id
			  ,p_pl_bnf_id     => l_act_items(i).pl_bnf_id
			  ,p_business_group_id  => l_act_items(i).business_group_id
			  ,p_pea_attribute_category  => l_act_items(i).pea_attribute_category
			  ,p_pea_attribute1 => l_act_items(i).pea_attribute1
			  ,p_pea_attribute2 => l_act_items(i).pea_attribute2
			  ,p_pea_attribute3 => l_act_items(i).pea_attribute3
			  ,p_pea_attribute4  => l_act_items(i).pea_attribute4
			  ,p_pea_attribute5  => l_act_items(i).pea_attribute5
			  ,p_pea_attribute6  => l_act_items(i).pea_attribute6
			  ,p_pea_attribute7   => l_act_items(i).pea_attribute7
			  ,p_pea_attribute8 => l_act_items(i).pea_attribute8
			  ,p_pea_attribute9  => l_act_items(i).pea_attribute9
			  ,p_pea_attribute10 => l_act_items(i).pea_attribute10
			  ,p_pea_attribute11 => l_act_items(i).pea_attribute11
			  ,p_pea_attribute12 => l_act_items(i).pea_attribute12
			  ,p_pea_attribute13 => l_act_items(i).pea_attribute13
			  ,p_pea_attribute14  => l_act_items(i).pea_attribute14
			  ,p_pea_attribute15 => l_act_items(i).pea_attribute15
			  ,p_pea_attribute16 => l_act_items(i).pea_attribute16
			  ,p_pea_attribute17  => l_act_items(i).pea_attribute17
			  ,p_pea_attribute18  => l_act_items(i).pea_attribute18
			  ,p_pea_attribute19  => l_act_items(i).pea_attribute19
			  ,p_pea_attribute20 => l_act_items(i).pea_attribute20
			  ,p_pea_attribute21 => l_act_items(i).pea_attribute21
			  ,p_pea_attribute22 => l_act_items(i).pea_attribute22
			  ,p_pea_attribute23  => l_act_items(i).pea_attribute23
			  ,p_pea_attribute24   => l_act_items(i).pea_attribute24
			  ,p_pea_attribute25  => l_act_items(i).pea_attribute25
			  ,p_pea_attribute26 => l_act_items(i).pea_attribute26
			  ,p_pea_attribute27 => l_act_items(i).pea_attribute27
			  ,p_pea_attribute28   => l_act_items(i).pea_attribute28
			  ,p_pea_attribute29 => l_act_items(i).pea_attribute29
			  ,p_pea_attribute30 => l_act_items(i).pea_attribute30
			  ,p_object_version_number  => l_actn_object_version_number
			  ,p_prtt_enrt_actn_id   => l_prtt_enrt_actn_id
			  ,p_effective_start_date => l_actn_start_date
			  ,p_effective_end_date   => l_actn_end_date
			  ,p_gnrt_cm => false -- Bug 9256641 : Do not generate communications
			  );
	       end loop;
	       hr_utility.set_location('created action items',500);
        end if;

        hr_utility.set_location('before creating cert',500);
        if(l_ctfn_flag and l_create_flag = 'Y' ) then
          hr_utility.set_location('creating certifications ',500);
	     for j IN l_ctfn.FIRST..l_ctfn.LAST loop
	        hr_utility.set_location('looping cert ',500);
		ben_PRTT_ENRT_CTFN_PRVDD_api.create_PRTT_ENRT_CTFN_PRVDD
		  (p_validate => false
		  ,p_prtt_enrt_ctfn_prvdd_id => l_prtt_enrt_ctfn_prvdd_id
		  ,p_effective_start_date  => l_ctfn_start_date
		  ,p_effective_end_date => l_ctfn_end_date
		  ,p_enrt_ctfn_rqd_flag  => l_ctfn(j).enrt_ctfn_rqd_flag
		  ,p_enrt_ctfn_typ_cd   => l_ctfn(j).enrt_ctfn_typ_cd
		  ,p_enrt_ctfn_recd_dt => l_ctfn(j).enrt_ctfn_recd_dt
		  ,p_enrt_ctfn_dnd_dt  => l_ctfn(j).enrt_ctfn_dnd_dt
		  ,p_enrt_r_bnft_ctfn_cd => l_ctfn(j).enrt_r_bnft_ctfn_cd
		  ,p_prtt_enrt_rslt_id => g_new_prtt_enrt_rslt_id
		  ,p_prtt_enrt_actn_id  => l_prtt_enrt_actn_id
		  ,p_business_group_id  => l_ctfn(j).business_group_id
		  ,p_pcs_attribute_category  => l_ctfn(j).pcs_attribute_category
		  ,p_pcs_attribute1  => l_ctfn(j).pcs_attribute1
		  ,p_pcs_attribute2  => l_ctfn(j).pcs_attribute2
		  ,p_pcs_attribute3 => l_ctfn(j).pcs_attribute3
		  ,p_pcs_attribute4 => l_ctfn(j).pcs_attribute4
		  ,p_pcs_attribute5 => l_ctfn(j).pcs_attribute5
		  ,p_pcs_attribute6  => l_ctfn(j).pcs_attribute6
		  ,p_pcs_attribute7  => l_ctfn(j).pcs_attribute7
		  ,p_pcs_attribute8  => l_ctfn(j).pcs_attribute8
		  ,p_pcs_attribute9  => l_ctfn(j).pcs_attribute9
		  ,p_pcs_attribute10 => l_ctfn(j).pcs_attribute10
		  ,p_pcs_attribute11 => l_ctfn(j).pcs_attribute11
		  ,p_pcs_attribute12 => l_ctfn(j).pcs_attribute12
		  ,p_pcs_attribute13=> l_ctfn(j).pcs_attribute13
		  ,p_pcs_attribute14  => l_ctfn(j).pcs_attribute14
		  ,p_pcs_attribute15 => l_ctfn(j).pcs_attribute15
		  ,p_pcs_attribute16=> l_ctfn(j).pcs_attribute16
		  ,p_pcs_attribute17  => l_ctfn(j).pcs_attribute17
		  ,p_pcs_attribute18 => l_ctfn(j).pcs_attribute18
		  ,p_pcs_attribute19 => l_ctfn(j).pcs_attribute19
		  ,p_pcs_attribute20 => l_ctfn(j).pcs_attribute20
		  ,p_pcs_attribute21=> l_ctfn(j).pcs_attribute21
		  ,p_pcs_attribute22 => l_ctfn(j).pcs_attribute22
		  ,p_pcs_attribute23  => l_ctfn(j).pcs_attribute23
		  ,p_pcs_attribute24=>l_ctfn(j).pcs_attribute24
		  ,p_pcs_attribute25 =>l_ctfn(j).pcs_attribute25
		  ,p_pcs_attribute26 => l_ctfn(j).pcs_attribute26
		  ,p_pcs_attribute27 => l_ctfn(j).pcs_attribute27
		  ,p_pcs_attribute28 => l_ctfn(j).pcs_attribute28
		  ,p_pcs_attribute29 => l_ctfn(j).pcs_attribute29
		  ,p_pcs_attribute30 => l_ctfn(j).pcs_attribute30
		  ,p_object_version_number  => l_ctfn_object_version_number
		  ,p_effective_date => p_effective_date
		  );
	      end loop;
           end if;
	   g_new_prtt_enrt_rslt_id := -1;
      else
	  remove_cert_action_items
            (p_prtt_enrt_rslt_id  => p_prtt_enrt_rslt_id
            ,p_effective_date     => l_eff_dt
            ,p_business_group_id  => p_business_group_id
            ,p_validate           => FALSE
            ,p_datetrack_mode     => l_datetrack_mode
            ,p_source             => p_source
            ,p_per_in_ler_id      => l_pen.pen_per_in_ler_id
            ,p_per_in_ler_ended_id=> l_pen.per_in_ler_id
            );
      end if;

      /* Commented code for Bug 7561395
      remove_cert_action_items
            (p_prtt_enrt_rslt_id  => p_prtt_enrt_rslt_id
            ,p_effective_date     => l_eff_dt
            ,p_business_group_id  => p_business_group_id
            ,p_validate           => FALSE
            ,p_datetrack_mode     => l_datetrack_mode
            ,p_source             => p_source
            ,p_per_in_ler_id      => l_pen.pen_per_in_ler_id
            ,p_per_in_ler_ended_id=> l_pen.per_in_ler_id
            ); */

      /* Ended code for Bug 7561395 */
      --
      l_step := 137;
      --
      if l_pen.pgm_id is not null then
          ben_provider_pools.remove_bnft_prvdd_ldgr
            (p_prtt_enrt_rslt_id  => p_prtt_enrt_rslt_id
            ,p_effective_date     => l_eff_dt
            ,p_business_group_id  => p_business_group_id
            ,p_validate           => FALSE
            ,p_datetrack_mode     => l_datetrack_mode
            );
      end if;
      --
      -- Remove all participant Rate Values rows
      --
      l_step := 170;
      --
      -- Bug 4136432
      for l_prv in c_prvdel
      loop
            --
            hr_utility.set_location('p_prtt_enrt_rslt_id ='||p_prtt_enrt_rslt_id,20);
            hr_utility.set_location('l_eff_dt ='||to_char(l_eff_dt),20);
            hr_utility.set_location('l_prv.prtt_rt_val_id ='||l_prv.prtt_rt_val_id,20);
            hr_utility.set_location('l_pen.person_id ='|| l_pen.person_id,20);
            hr_utility.set_location('l_prv.enrt_rt_id ='||l_prv.enrt_rt_id,20);
            --
	    -- Bug 5626835 : For Enter Value At Enrollment cases, we need to just BCKDT PRV, so that
	    --               during reinstatement of corresponding PEN, we can get the actual PRV
	    --               and hence the previously selected RT_VAL
	    -- Note : Probably we need this fix for all cases, but I made change for Enter Value At
	    --        Enrollment case only. Right now for other cases, while reinstating we create records
	    --        from BEPENAPI.MULTI_ROWS_EDIT >> BEN_DET_ENRT_RATES using ECR
	    --
            IF l_prv.entr_val_at_enrt_flag = 'Y'
	    THEN
	      --
    -- Bug 6471236
             /* void_rate
	                (p_prtt_enrt_rslt_id      => p_prtt_enrt_rslt_id,
                         p_business_group_id      => p_business_group_id,
                         p_person_id              => l_pen.person_id,
                         p_per_in_ler_id          => p_per_in_ler_id,
                         p_effective_date         => p_effective_date
                         ); */
         if  l_datetrack_mode='CORRECTION' then
             l_temp_date:=l_enrt_cvg_end_dt;
             l_temp_stat_cd:=NULL;
                  --Bug#:6641853
         else
             l_temp_date:=l_prv.rt_strt_dt - 1;
             l_temp_stat_cd:='VOIDD';
         end if;
	 ben_prtt_rt_val_api.update_prtt_rt_val
		    (P_VALIDATE                =>  FALSE
		    ,P_PRTT_RT_VAL_ID          =>  l_prv.prtt_rt_val_id
		    ,P_RT_END_DT               =>  l_temp_date
		    ,p_person_id               =>  l_pen.person_id
		    ,p_input_value_id          =>  l_prv.input_value_id
		    ,p_element_type_id         =>  l_prv.element_type_id
		    ,p_ended_per_in_ler_id     =>  p_per_in_ler_id
		    ,p_prtt_rt_val_stat_cd     =>  l_temp_stat_cd
		    ,p_business_group_id       =>  p_business_group_id
		    ,P_OBJECT_VERSION_NUMBER   =>  l_prv.object_version_number
		    ,P_EFFECTIVE_DATE          =>  p_effective_date
	            );
           l_temp_date:=NULL;
    -- Bug 6471236
           --
	    ELSE
	      --
             if  l_datetrack_mode='CORRECTION' then


              ben_prtt_rt_val_api.update_prtt_rt_val
                    (P_VALIDATE                =>  FALSE
                    ,P_PRTT_RT_VAL_ID          =>  l_prv.prtt_rt_val_id
                    ,P_RT_END_DT               =>  l_enrt_cvg_end_dt
                    ,p_person_id               =>  l_pen.person_id
                    ,p_input_value_id          =>  l_prv.input_value_id
                    ,p_element_type_id         =>  l_prv.element_type_id
                    ,p_ended_per_in_ler_id     =>  p_per_in_ler_id
                   -- ,p_prtt_rt_val_stat_cd     =>  l_temp_stat_cd
                    ,p_business_group_id       =>  p_business_group_id
                    ,P_OBJECT_VERSION_NUMBER   =>  l_prv.object_version_number
                    ,P_EFFECTIVE_DATE          =>  p_effective_date
                    );

             ELSE
                  --Bug#:6641853
              ben_prtt_rt_val_api.delete_prtt_rt_val
			(P_VALIDATE                => FALSE
			,P_PRTT_RT_VAL_ID          => l_prv.prtt_rt_val_id
			,P_ENRT_RT_ID              => l_prv.enrt_rt_id
			,P_OBJECT_VERSION_NUMBER   => l_prv.object_version_number
			,P_EFFECTIVE_DATE          => l_eff_dt
			,p_person_id               => l_pen.person_id
			,p_business_group_id       => p_business_group_id
			);
             END IF;
	      --
	    END IF;
	    --
      end loop;
          --
          -- Remove PCP records
          --
      for l_pcp in c_pcp(l_eff_dt) loop
            ben_prmry_care_prvdr_api.delete_prmry_care_prvdr
              (P_VALIDATE               => FALSE
              ,P_PRMRY_CARE_PRVDR_ID    => l_pcp.prmry_care_prvdr_id
              ,P_EFFECTIVE_START_DATE   => l_pcp.effective_start_date
              ,P_EFFECTIVE_END_DATE     => l_pcp.effective_end_date
              ,P_OBJECT_VERSION_NUMBER  => l_pcp.object_version_number
              ,P_EFFECTIVE_DATE         => l_eff_dt
              ,P_DATETRACK_MODE         => l_datetrack_mode
              ,p_called_from            => 'delete_enrollment'
            );
      End loop;
       --
          -- Remove ppe records and children
          --
          /* Start of Code Change for WWBUG: 1646442: added           */
      l_ppe_dt_to_use := least(l_enrt_cvg_end_dt,l_rt_end_dt);
          /* End of Code Change for WWBUG: 1646442                    */
          /*
               CODE PRIOR TO WWBUG: 1646442
           for l_ppe in c_ppe loop
          */
          /* Start of Code Change for WWBUG: 1646442                  */
      for l_ppe in c_ppe(l_ppe_dt_to_use) loop
          /* End of Code Change for WWBUG: 1646442                    */
          --
          l_prtt_prem_id := l_ppe.prtt_prem_id;
            --
          /******************** BEGIN CODE PRIOR TO WWBUG: 1646442  **********
            This whole section has been deleted
            ** BBurns 15aug2001
            ** A              'invalid primary key' error occurred when a date track delete
            ** was attempted with a p_effective_date prior to the start of
            ** the ben_prtt_prem_by_mo_f row.  The ben_prtt_prem_by_mo_f rows have
            ** already been reported to the carrier and should not be modified
            ** by this procedure.
            ** A review of how prtt_prem_by_mo_f is defined and the functionality
            ** of this procedure is in order.
            **
            --
            --  delete child ben_prtt_prem_by_mo_f records
            --
          for l_prm in c_prm loop
            --
            if (l_datetrack_mode = hr_api.g_delete and
                  l_prm.effective_end_date > l_eff_dt) or
                  l_datetrack_mode <> hr_api.g_delete then
                --
                ben_prtt_prem_by_mo_api.delete_prtt_prem_by_mo
                  (p_validate              => false,
                   p_prtt_prem_by_mo_id    => l_prm.prtt_prem_by_mo_id,
                   p_object_version_number => l_prm.object_version_number,
                   p_effective_date        => l_eff_dt,
                   p_effective_start_date  => l_prm.effective_end_date,
                   p_effective_end_date    => l_prm.effective_start_date,
                   p_datetrack_mode        => l_datetrack_mode
                  );
                --
            end if;
            --
          end loop;
            ******************** END CODE PRIOR TO WWBUG: 1646442  ************/
          --
          if (l_datetrack_mode = hr_api.g_delete and
                l_ppe.effective_end_date > l_eff_dt) or
                l_datetrack_mode <> hr_api.g_delete then
              --
              /* Start of Changes for WWBUG: 1646442: added                   */
              l_ppe_dt_to_use := least(l_enrt_cvg_end_dt,l_rt_end_dt);
              l_ppe_datetrack_mode := l_datetrack_mode;
            if l_ppe_dt_to_use < l_ppe.effective_start_date
              then
                   l_ppe_dt_to_use := l_ppe.effective_start_date;
                   l_ppe_datetrack_mode := hr_api.g_zap;
            end if;
            /* End of Changes for WWBUG: 1646442                            */
              /***************** BEGIN CODE PRIOR TO WWBUG: 1646442   **********
            ben_prtt_prem_api.delete_prtt_prem
                (p_validate              => false,
                 p_prtt_prem_id          => l_ppe.prtt_prem_id,
                 p_object_version_number => l_ppe.object_version_number,
                 p_effective_date        => l_eff_dt,
                 p_effective_start_date  => l_ppe.effective_end_date,
                 p_effective_end_date    => l_ppe.effective_start_date,
                 p_datetrack_mode        => l_datetrack_mode
                );
              ******************* END CODE PRIOR TO WWBUG: 1646442 *****************/
             /* Start of Code Changes for WWBUG: 1646442                      */
             ben_prtt_prem_api.delete_prtt_prem
                (p_validate              => false,
                 p_prtt_prem_id          => l_ppe.prtt_prem_id,
                 p_object_version_number => l_ppe.object_version_number,
                 p_effective_date        => l_ppe_dt_to_use, /*l_eff_dt*/
                 p_effective_start_date  => l_ppe.effective_end_date,
                 p_effective_end_date    => l_ppe.effective_start_date,
                 p_datetrack_mode        => l_ppe_datetrack_mode /*l_datetrack_mode*/
                );
              /* End of Code Changes for WWBUG: 1646442                       */
             --
          end if;
          --
      end loop;
        --
        -- Clear out ben_enrt_bnft table's prtt_enrt_rslt_id
        --
        l_step := 176;
        --
        -- Do not call manage_enrt_bnft, if it is called from election_information
        -- as the call is always made from there.
        --
        --Bug 3256056 This call from election_information is associated with the
        --New results - That other call works fine if the result was continued from
        --the prevoius enrollment. But if the user made the change in the
        --current enrollment olny [I mean selected option 1 , saved and then now
        --changing to option 2 ] we don't want to keep the pen id on the enb record.
        --When we are zaping the records for the call from election information we
        --we want to remove the penid from enb also.
        --
        if p_source = 'benelinf' and l_datetrack_mode = hr_api.g_zap then
             --
             ben_election_information.manage_enrt_bnft
               (p_prtt_enrt_rslt_id     => p_prtt_enrt_rslt_id
               ,p_business_group_id     => p_business_group_id
               ,p_effective_date        => l_eff_dt
               ,p_object_version_number => l_tmp_ovn
               ,p_per_in_ler_id         => p_per_in_ler_id
               );
             --
        end if;
        --
        if p_source is null or
             p_source <> 'benelinf' then
             --
             ben_election_information.manage_enrt_bnft
               (p_prtt_enrt_rslt_id     => p_prtt_enrt_rslt_id
               ,p_business_group_id     => p_business_group_id
               ,p_effective_date        => l_eff_dt
               ,p_object_version_number => l_tmp_ovn
               ,p_per_in_ler_id         => p_per_in_ler_id
               );
             --
        end if;
        --
        l_step := 177;
        -- Do not attempt dt delete if the row selected already has an effective
        -- end date equal to (or less than) the date you are trying to delete it on.
          -- Bug 1132739
          -- Bug 2386000 If the result got update as part of on of the above calls,
          -- we need to get the latest object_version_number
          --
        if (l_datetrack_mode = hr_api.g_delete and
              l_pen.effective_end_date > l_eff_dt) or
              l_datetrack_mode <> hr_api.g_delete then
					--
					-- 4663971
					open c_pen_ovn( p_prtt_enrt_rslt_id,l_eff_dt ) ;
						fetch c_pen_ovn into l_pen_ovn.object_version_number,l_pen_ovn.effective_start_date ;
					close c_pen_ovn ;
          --
          -- BUG 4663971 we should never call delete process with other than zap mode
          -- if the datetrack mode is other than zap we need to call
          -- update_prtt_enrt_result procedure
          --
          if p_source = 'benuneai' or l_datetrack_mode <> hr_api.g_zap then
                hr_utility.set_location('called from benuneai',99);
								--
                -- 4663971
                if l_pen_ovn.effective_start_date = l_eff_dt
                   or l_datetrack_mode='CORRECTION' then
                  l_datetrack_mode := hr_api.g_correction ;
                  l_temp_date:=l_enrt_cvg_end_dt;
                  --Bug#:6641853
                else
                  l_datetrack_mode := hr_api.g_update ;
                  l_temp_date:=l_pen.enrt_cvg_strt_dt-1;
                end if;
                --
                ben_prtt_enrt_result_api.update_prtt_enrt_result
                (p_validate                => FALSE
                ,p_prtt_enrt_rslt_id       => p_prtt_enrt_rslt_id
                ,p_effective_start_date    => p_effective_start_date
                ,p_effective_end_date      => p_effective_end_date
                ,p_per_in_ler_id           => l_pen.per_in_ler_id
                ,p_ler_id                  => l_pen.ler_id
                ,p_enrt_cvg_thru_dt        => l_temp_date
                ,p_rplcs_sspndd_rslt_id    => null
                ,p_object_version_number   => l_pen_ovn.object_version_number
                ,p_effective_date          => l_eff_dt
                ,p_datetrack_mode          => l_datetrack_mode  --4663971
                ,p_multi_row_validate      => p_multi_row_validate
                ,p_business_group_id       => p_business_group_id
                );
          else
               ben_prtt_enrt_result_api.delete_prtt_enrt_result
               (p_validate                => FALSE
               ,p_prtt_enrt_rslt_id       => p_prtt_enrt_rslt_id
               ,p_effective_start_date    => p_effective_start_date
               ,p_effective_end_date      => p_effective_end_date
               ,p_object_version_number   => l_pen_ovn.object_version_number  -- 2386000
               ,p_effective_date          => l_eff_dt
               ,p_datetrack_mode          => l_datetrack_mode
               ,p_multi_row_validate      => p_multi_row_validate);
          end if;
        end if;
    end if ;  ----2546259
    -- write to change event log. -thayden
    --
    l_step := 178;
    --
    if p_source is null or
        p_source <> 'benelinf' then
        ben_ext_chlg.log_benefit_chg
        (p_action                      => 'DELETE'
        ,p_old_pl_id                   =>  l_pen.pl_id
        ,p_old_oipl_id                 =>  l_pen.oipl_id
        ,p_old_enrt_cvg_strt_dt        =>  l_pen.enrt_cvg_strt_dt
        ,p_old_enrt_cvg_end_dt         =>  l_pen.enrt_cvg_thru_dt
        ,p_pl_id                       =>  l_pen.pl_id
        ,p_oipl_id                     =>  l_pen.oipl_id
        ,p_enrt_cvg_strt_dt            =>  l_pen.enrt_cvg_strt_dt
        ,p_enrt_cvg_end_dt             =>  l_eff_dt
        ,p_prtt_enrt_rslt_id           =>  p_prtt_enrt_rslt_id
        ,p_per_in_ler_id               =>  l_pen.per_in_ler_id
        ,p_person_id                   =>  l_pen.person_id
        ,p_business_group_id           =>  p_business_group_id
        ,p_effective_date              =>  l_eff_dt
        );
    end if;
  --
  end if;
  --bug # 3086161
  if l_corr_pil_id is not null then
     hr_utility.set_location(' correcting the  resulst for ' || l_corr_pil_id , 999 );
     open  c_pen_obj_no (p_per_in_ler_id ,p_prtt_enrt_rslt_id ) ;
     fetch c_pen_obj_no into l_object_version_number ;
     if c_pen_obj_no%found then
           hr_utility.set_location(' correcting the  result ovn ' || l_object_version_number , 999 );
           ben_prtt_enrt_result_api.update_prtt_enrt_result
               (p_validate                => FALSE
               ,p_prtt_enrt_rslt_id       => p_prtt_enrt_rslt_id
               ,p_effective_start_date    => p_effective_start_date
               ,p_effective_end_date      => p_effective_end_date
               ,p_per_in_ler_id           => l_corr_pil_id
               ,p_ler_id                  => l_pen.ler_id
               ,p_object_version_number   => l_object_version_number
               ,p_effective_date          => p_effective_date
               ,p_datetrack_mode          => hr_api.g_correction
               ,p_multi_row_validate      => FALSE
               ,p_business_group_id       => p_business_group_id
               );
     end if ;
     /* -- added here for bug 6963660
     -- updated the corrected result in the back up table so that it behaves as
     -- if corrected on the p_effective_start_date
     --
     update ben_le_clsn_n_rstr
     set effective_start_date = p_effective_start_date
     where per_in_ler_id = l_corr_pil_id
     and   bkup_tbl_id = p_prtt_enrt_rslt_id
     and   bkup_tbl_typ_cd = 'BEN_PRTT_ENRT_RSLT_F_CORR';
     --
     -- added till here for bug 6963660 */
     close c_pen_obj_no ;
  end if ;
  --- eof bug # 3086161
  --
  -- Delete the interim coverage also.
  -- Delete interim only when called from enrollment forms (p_source is null)
  -- and when called from election_information (p_source='benelinf')
  --
  if l_pen.sspndd_flag = 'Y' and
     l_pen.rplcs_sspndd_rslt_id is not null and
     (p_source is null or
      p_source = 'benelinf') then
    --
    -- Check if the interim result is been used by some other suspended
    -- result. If yes, do not delete the interim result.
    -- This case is most important when I'm moving from a suspended result
    -- to other result, which also gets suspended and both have the same
    -- interim. In this case, we create the new suspended result first
    -- and when interim needs to be created, it finds interim result to be
    -- already present. Now when the old suspended result is deleted in the
    -- same run, it tries to delete the interim result along with it.
    -- So the new suspended result is without any interims.
    -- In order to avoid this, this new cursor is introduced. (Bug 1274214)
    --
    open  c_intm_other_rslt(p_per_in_ler_id);           -- Bug 6165501 : Added Input param
    fetch c_intm_other_rslt into l_intm_other_rslt;
    close c_intm_other_rslt;
    --
    if l_intm_other_rslt is null or
       l_intm_other_rslt <> 'Y' then
      --
      open c_interim;
      fetch c_interim into l_interim;
      --
      if c_interim%found then
        --
        delete_enrollment(
             p_validate              => false,
             p_per_in_ler_id         => p_per_in_ler_id,
             p_prtt_enrt_rslt_id     => l_interim.prtt_enrt_rslt_id,
             p_effective_start_date  => l_interim.effective_start_date,
             p_effective_end_date    => l_interim.effective_end_date,
             p_object_version_number => l_interim.object_version_number,
             p_business_group_id     => p_business_group_id,
             p_effective_date        => p_effective_date,
             p_datetrack_mode        => p_datetrack_mode,
             p_source                => 'delete_enrollment',
             p_lee_rsn_id            => p_lee_rsn_id,
             p_enrt_perd_id          => p_enrt_perd_id,
             p_multi_row_validate    => false);
        --
      end if;
      --
      close c_interim;
      --
    end if;
    --
  end if;
  --
  if g_debug then
     hr_utility.set_location(l_proc, 60);
  end if;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
      raise hr_api.validate_enabled;
  end if;
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 70);
  end if;
--
Exception
  --
  when hr_api.validate_enabled
  then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_enrollment;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
    --
    when l_fnd_message_exception then
       ROLLBACK TO delete_enrollment;
       rpt_error(p_proc => l_proc, p_step => l_step);
       p_effective_start_date := null; --nocopy change
       p_effective_end_date := null; --nocopy change
       fnd_message.raise_error;
    --
 --Bug 5664907
    when app_exception.application_exception then
      ROLLBACK TO delete_enrollment;
      rpt_error(p_proc => l_proc, p_step => l_step);
      p_effective_start_date := null; --nocopy change
      p_effective_end_date := null; --nocopy change
      fnd_message.raise_error;
    --
 --Bug 5664907
  when others then
   --
   --
   -- A validation or unexpected error has occured
   --
  ROLLBACK TO delete_enrollment;
    rpt_error(p_proc => l_proc, p_step => l_step);
    p_effective_start_date := null; --nocopy change
    p_effective_end_date := null; --nocopy change
    fnd_message.set_name('PER','FFU10_GENERAL_ORACLE_ERROR');
    fnd_message.set_token('2',substr(sqlerrm,1,500)); -- 4695708
    fnd_message.raise_error;
 --
end delete_enrollment;
--
-- --------------------------------------------------------------------------
-- |--------------------------< unhook_bnf >--------------------------------|
-- --------------------------------------------------------------------------
--
 procedure unhook_bnf
  (p_validate          in     boolean default FALSE
  ,p_prtt_enrt_rslt_id in     number
  ,p_per_in_ler_id     in     number
  ,p_dsgn_thru_dt       in     date
  ,p_business_group_id in     number
  ,p_effective_date    in     date
  ,p_datetrack_mode    in     varchar2
  ,p_rslt_delete_flag  in     boolean default FALSE

  ) is


 cursor c_old_bnf
  is
  select pbf.pl_bnf_id
         ,pbf.effective_start_date
         ,pbf.effective_end_date
         ,pbf.object_version_number
         ,pbf.dsgn_strt_dt
         ,pbf.dsgn_thru_dt
         ,pbf.per_in_ler_id
    from ben_pl_bnf_f pbf,
         ben_per_in_ler pil
   where pbf.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and pbf.business_group_id  = p_business_group_id
     and p_effective_date between pbf.effective_start_date
                              and pbf.effective_end_date
     and pil.per_in_ler_id=pbf.per_in_ler_id
     and pil.business_group_id=pbf.business_group_id
     and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
  ;
  --
 cursor c_zap_bnf
  is
  select pbf.pl_bnf_id
        ,pbf.object_version_number
    from ben_pl_bnf_f pbf,
         ben_per_in_ler pil
  where pbf.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
   and p_effective_date
   between pbf.effective_start_date
   and pbf.effective_end_date
   and pil.per_in_ler_id=pbf.per_in_ler_id
   and pil.business_group_id=pbf.business_group_id
   and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
  ;

 l_proc                     varchar2(72); --  := g_package||'unhook_bnf';

  l_effective_start_date  date;
  l_effective_end_date    date;
  l_object_version_number number(9);
  l_step                  integer;
  l_datetrack_mode        varchar2(30);
  l_correction            boolean;
  l_update                boolean;
  l_update_override       boolean;
  l_update_change_insert  boolean;
  l_last                  number:=-1;
  l_effective_date        date;
  l_per_in_ler_id         number := p_per_in_ler_id;
--
begin
  --
  g_debug := hr_utility.debug_enabled;
  if g_debug then
     l_proc := g_package||'unhook_bnf';
     hr_utility.set_location('Entering'||l_proc, 5);
  end if;
  --
  l_step := 10;
  --
  for orec in c_old_bnf loop
    --
    -- Only pick up first occurrence of each ID.
    -- This was added to zap future dated rows
    -- because result delete fails if children
    -- are not ended.
   --
   if l_last=-1 or  l_last<>orec.pl_bnf_id then
      l_last:=orec.pl_bnf_id;
      l_effective_date:=p_effective_date;
      if (p_effective_date<nvl(orec.effective_start_date,hr_api.g_date)) then
         l_effective_date:=orec.effective_start_date;
         l_datetrack_mode := hr_api.g_zap;
      elsIf (p_effective_date = nvl(orec.effective_start_date,hr_api.g_date)) then
         l_datetrack_mode := hr_api.g_correction;
      Elsif (p_datetrack_mode in (hr_api.g_correction, hr_api.g_zap)) then
         l_datetrack_mode := hr_api.g_correction;
      Else
         l_datetrack_mode := hr_api.g_update;
      End if;
      --
      --
      If (p_effective_date between nvl(orec.dsgn_strt_dt, p_effective_date+1)
         and nvl(orec.dsgn_thru_dt, hr_api.g_eot)
         and not p_rslt_delete_flag
         and l_datetrack_mode<>hr_api.g_zap
         ) then
         --
         -- If Coverage started, then end the coverage by set the coverage
         -- thru date.
         --

         dt_api.find_dt_upd_modes
          (p_effective_date       => p_effective_date,
           p_base_table_name      => 'BEN_PL_BNF_F',
           p_base_key_column      => 'PL_BNF_ID',
           p_base_key_value       => orec.PL_BNF_ID,
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
         if g_debug then
            hr_utility.set_location('dt_mode='||l_datetrack_mode,11);
         end if;
         --
         l_step := 20;
         --
         If p_dsgn_thru_dt is null then
            rpt_error(p_proc => l_proc, p_step => l_step);
            fnd_message.set_name('BEN','BEN_91704_NOT_DET_DP_CVG_E_DT');
            fnd_message.raise_error;
         End if;
         --
         if l_per_in_ler_id is null then
            l_per_in_ler_id := orec.per_in_ler_id;
         end if;
         --
         if g_debug then
            hr_utility.set_location('calling update mode' || l_datetrack_mode , 192 );
         end if;
         ben_PLAN_BENEFICIARY_api.update_PLAN_BENEFICIARY
        (p_validate                => FALSE
        ,p_business_group_id       => p_business_group_id
        ,p_pl_bnf_id               => orec.pl_bnf_id
        ,p_effective_start_date    => orec.effective_start_date
        ,p_effective_end_date      => orec.effective_end_date
        ,p_dsgn_thru_dt            => p_dsgn_thru_dt
        ,p_per_in_ler_id           => l_per_in_ler_id
        ,p_object_version_number   => orec.object_version_number
        ,p_effective_date          => p_effective_date
        ,p_datetrack_mode          => l_datetrack_mode
        ,p_multi_row_actn          => FALSE);
      --
    elsif orec.dsgn_thru_dt < p_effective_date then
      --
      -- Coverage is already ended. Don't do anything.
    --
      null;
      --
    Else
      --
      -- If coverage not yet started, then reset coverage start/end date
      -- to NULL and coverage flag to 'N'
      --
      l_step := 40;
      --
      If (p_effective_date <= nvl(orec.effective_start_date,hr_api.g_date)) then
        l_datetrack_mode := hr_api.g_zap;
      Elsif (p_datetrack_mode in (hr_api.g_correction, hr_api.g_zap)) then
        l_datetrack_mode := hr_api.g_zap;
      Else
        l_datetrack_mode := hr_api.g_delete;

     End if;
      --
      -- Start of fix for INTERNAL bug 4924
   --
      if l_datetrack_mode = hr_api.g_delete and
        p_effective_date = orec.effective_end_date then
        --
        -- Already end dated
        --
        null;
        --
      else
        --
      if g_debug then
         hr_utility.set_location('calling delete ' || l_datetrack_mode , 192 );
      end if;
      ben_plan_beneficiary_api.delete_plan_beneficiary
        (p_validate              => p_validate
        ,p_pl_bnf_id             => orec.pl_bnf_id
        ,p_effective_start_date  => orec.effective_start_date
        ,p_effective_end_date    => orec.effective_end_date
        ,p_object_version_number => orec.object_version_number
        ,p_effective_date        => p_effective_date
        ,p_datetrack_mode        => nvl(l_datetrack_mode,p_datetrack_mode)
        ,p_multi_row_actn        => FALSE
        ,p_business_group_id     => p_business_group_id);

        --
      end if;
      --
      -- End of fix for INTERNAL BUG 4924.
      --
    End if;
   end if;
  End loop;
  if g_debug then
     hr_utility.set_location('Exiting'||l_proc, 30);
  end if;

exception
  --
  when others then
    rpt_error(p_proc => l_proc, p_step => l_step);
    fnd_message.raise_error;
End unhook_bnf;
--


--
-- ---------------------------------------------------------------------------
-- |----------------------------< unhook_dpnt >------------------------------|
-- ---------------------------------------------------------------------------
--
Procedure unhook_dpnt
  (p_validate          in     boolean default FALSE
  ,p_prtt_enrt_rslt_id in     number
  ,p_per_in_ler_id     in     number
  ,p_cvg_thru_dt       in     date
  ,p_business_group_id in     number
  ,p_effective_date    in     date
  ,p_datetrack_mode    in     varchar2
  ,p_rslt_delete_flag  in     boolean default FALSE
  ,p_called_from       in     varchar2 default 'bepenapi'
  ) is
  cursor c_old_dpnt is
  select  ecd.elig_cvrd_dpnt_id
         ,ecd.effective_start_date
         ,ecd.effective_end_date
         ,ecd.dpnt_person_id
         ,ecd.cvg_strt_dt
         ,ecd.CVG_PNDG_FLAG
         ,ecd.cvg_thru_dt
         ,ecd.object_version_number
         ,ecd.per_in_ler_id
  from   ben_elig_cvrd_dpnt_f ecd,
         ben_per_in_ler pil
  where  ecd.prtt_enrt_rslt_id=p_prtt_enrt_rslt_id
     and ecd.cvg_strt_dt is not null
 --    and ecd.cvg_thru_dt = hr_api.g_eot
     and ecd.business_group_id=p_business_group_id
--     and p_effective_date between
--         ecd.effective_start_date and ecd.effective_end_date
     and p_effective_date <= ecd.effective_end_date
     and pil.per_in_ler_id(+)=ecd.per_in_ler_id
     and pil.business_group_id(+)=ecd.business_group_id
     and (pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT') or
          -- outer join condition below
          -- above is case where found pil,
          -- below is case where pil not found and want row
          pil.per_in_ler_stat_cd is null)
     /* Bug 4520785 Pick only those cvrd dependent records where either cvg thru date hasn't
        been end dated yet or cvg thru date is more than effective date */
     and ecd.elig_cvrd_dpnt_id not in (select ecd1.elig_cvrd_dpnt_id
                                         from ben_elig_cvrd_dpnt_f ecd1
                                           where ecd1.elig_cvrd_dpnt_id = ecd.elig_cvrd_dpnt_id
                                               and ecd1.cvg_thru_dt <= p_effective_date
                                               and p_effective_date <= ecd1.effective_end_date ) -- Bug 4710937
     /* End Bug 4520785 */
     order by ecd.elig_cvrd_dpnt_id,
              ecd.effective_start_date;

  -- 3574168
  -- Fetch all PCP records on effective date
    Cursor c_pcp (c_elig_cvrd_dpnt_id NUMBER)
    is
    select pcp.PRMRY_CARE_PRVDR_ID
        ,pcp.EFFECTIVE_START_DATE
        ,pcp.EFFECTIVE_END_DATE
        ,pcp.PRTT_ENRT_RSLT_ID
        ,pcp.BUSINESS_GROUP_ID
        ,pcp.OBJECT_VERSION_NUMBER
    from ben_prmry_care_prvdr_f pcp
    where business_group_id = p_business_group_id
     and elig_cvrd_dpnt_id = c_elig_cvrd_dpnt_id
     and p_effective_date between effective_start_date
                  and effective_end_date
       ;
     --
     -- Fetch all PCP records in future
    Cursor c_pcp_future (c_elig_cvrd_dpnt_id NUMBER)
    is
    select pcp.PRMRY_CARE_PRVDR_ID
      ,pcp.EFFECTIVE_START_DATE
      ,pcp.EFFECTIVE_END_DATE
      ,pcp.PRTT_ENRT_RSLT_ID
      ,pcp.BUSINESS_GROUP_ID
      ,pcp.OBJECT_VERSION_NUMBER
    from ben_prmry_care_prvdr_f pcp
     where pcp.business_group_id = p_business_group_id
     and pcp.elig_cvrd_dpnt_id = c_elig_cvrd_dpnt_id
     and p_effective_date  < pcp.effective_start_date
     and  NVL(pcp.effective_end_date, hr_api.g_eot) = hr_api.g_eot
       ;
       -- 3574168

  l_proc                  varchar2(72); --  := g_package||'unhook_dpnt';
  l_effective_start_date  date;
  l_effective_end_date    date;
  l_object_version_number number(9);
  l_step                  integer;
  l_datetrack_mode        varchar2(30);
  l_correction            boolean;
  l_update                boolean;
  l_update_override       boolean;
  l_update_change_insert  boolean;
  l_last                  number:=-1;
  l_effective_date        date;
  l_per_in_ler_id         number := p_per_in_ler_id;
  l_pcp_effective_date    date;
--
begin
  --
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_proc := g_package||'unhook_dpnt';
    hr_utility.set_location('Entering'||l_proc, 5);
    hr_utility.set_location('p_effective_date '||to_char(p_effective_date), 5);
  end if;
  --
  l_step := 10;
  --
  for orec in c_old_dpnt loop
    --
    -- Only pick up first occurrence of each ID.
    -- This was added to zap future dated rows
    -- because result delete fails if children
    -- are not ended.
    --
    hr_utility.set_location('orec.effective_start_date '||to_char(orec.effective_start_date), 5);
    hr_utility.set_location('p_datetrack_mode '||p_datetrack_mode , 5);
    hr_utility.set_location('orec.cvg_strt_dt '||to_char(orec.cvg_strt_dt), 5);
    hr_utility.set_location('orec.cvg_thru_dt '||to_char(orec.cvg_thru_dt), 5);

    if l_last=-1 or
       l_last<>orec.elig_cvrd_dpnt_id then
      l_last:=orec.elig_cvrd_dpnt_id;
    l_effective_date:=p_effective_date;
    if (p_effective_date<nvl(orec.effective_start_date,hr_api.g_date)) then
      l_effective_date:=orec.effective_start_date;
      l_datetrack_mode := hr_api.g_zap;
    elsIf (p_effective_date = nvl(orec.effective_start_date,hr_api.g_date)) then
      l_datetrack_mode := hr_api.g_correction;
    Elsif (p_datetrack_mode in (hr_api.g_correction, hr_api.g_zap)) then
      l_datetrack_mode := hr_api.g_correction;
    Else
      l_datetrack_mode := hr_api.g_update;
    End if;
    --
    If (p_effective_date between nvl(orec.cvg_strt_dt, p_effective_date+1)
            and nvl(orec.cvg_thru_dt, hr_api.g_eot)
        and orec.CVG_PNDG_FLAG = 'N'
        and not p_rslt_delete_flag
        and l_datetrack_mode<>hr_api.g_zap
       ) then
      --
      -- If Coverage started, then end the coverage by set the coverage
      -- thru date.
      --
      dt_api.find_dt_upd_modes
        (p_effective_date       => p_effective_date,
         p_base_table_name      => 'BEN_ELIG_CVRD_DPNT_F',
         p_base_key_column      => 'ELIG_CVRD_DPNT_ID',
         p_base_key_value       => orec.elig_cvrd_dpnt_id,
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

        /* Bug 2597005: Reverse changes (Update the coverages of Dependents in correction mode )*/
       -- l_datetrack_mode := hr_api.g_correction;
        /* Bug 2597005: Reverse changes (Update the coverages of Dependents in correction mode) */
        --
      else
        --
        l_datetrack_mode := hr_api.g_correction;
        --

      end if;
      if g_debug then
        hr_utility.set_location('dt_mode='||l_datetrack_mode,11);
      end if;
      --
      l_step := 20;
      --
      If p_cvg_thru_dt is null then
        rpt_error(p_proc => l_proc, p_step => l_step);
        fnd_message.set_name('BEN','BEN_91704_NOT_DET_DP_CVG_E_DT');
        fnd_message.raise_error;
      End if;
      --
      if l_per_in_ler_id is null then
         l_per_in_ler_id := orec.per_in_ler_id;
      end if;
      ben_elig_cvrd_dpnt_api.update_elig_cvrd_dpnt
        (p_validate                => FALSE
        ,p_business_group_id       => p_business_group_id
        ,p_elig_cvrd_dpnt_id       => orec.elig_cvrd_dpnt_id
        ,p_effective_start_date    => orec.effective_start_date
        ,p_effective_end_date      => orec.effective_end_date
        ,p_cvg_thru_dt             => p_cvg_thru_dt
        ,p_per_in_ler_id           => l_per_in_ler_id
        ,p_object_version_number   => orec.object_version_number
        ,p_effective_date          => p_effective_date
        ,p_datetrack_mode          => l_datetrack_mode
        ,p_multi_row_actn          => FALSE);
      --
/*      --
    -- 3617724: Remove PCP records
        -- NO NEED TO REMOVE PCP's here as "update_elig_cvrd_dpnt" procedure above will do it.
        -- 3617724
*/

    elsif orec.cvg_thru_dt < p_effective_date then
      --
      -- Coverage is already ended. Don't do anything.
      --
      null;
      --
    Else
      --
      -- If coverage not yet started, then reset coverage start/end date
      -- to NULL and coverage flag to 'N'
      --
      l_step := 40;
      --
      If (p_effective_date <= nvl(orec.effective_start_date,hr_api.g_date)) then
        l_datetrack_mode := hr_api.g_zap;
      Elsif (p_datetrack_mode in (hr_api.g_correction, hr_api.g_zap)) then
        l_datetrack_mode := hr_api.g_zap;
      Else
        l_datetrack_mode := hr_api.g_delete;
        if g_debug then
           hr_utility.set_location('in dt_mode='||l_datetrack_mode,11);
        end if;
      End if;
      --
      -- Start of fix for INTERNAL bug 4924
      --
      if g_debug then
         hr_utility.set_location('dt_mode='||l_datetrack_mode,11);
      end if;
      if l_datetrack_mode = hr_api.g_delete and
        p_effective_date = orec.effective_end_date then
        --
        -- Already end dated
        --
        null;
        --
      else

        --
    -- 3574168: Remove PCP records
    -- Set End-date to coverage-end-date.
    --
        for l_pcp in c_pcp(orec.elig_cvrd_dpnt_id) loop
          --
          hr_utility.set_location('Delete prmry_care_prvdr_id '|| l_pcp.prmry_care_prvdr_id, 15);
          --
            ben_prmry_care_prvdr_api.delete_prmry_care_prvdr
            (P_VALIDATE               => FALSE
            ,P_PRMRY_CARE_PRVDR_ID    => l_pcp.prmry_care_prvdr_id
            ,P_EFFECTIVE_START_DATE   => l_pcp.effective_start_date
            ,P_EFFECTIVE_END_DATE     => l_pcp.effective_end_date
            ,P_OBJECT_VERSION_NUMBER  => l_pcp.object_version_number
            ,P_EFFECTIVE_DATE         => l_effective_date
            ,P_DATETRACK_MODE         => l_datetrack_mode
            ,p_called_from            => 'delete_enrollment'
            );
            --
        End loop;
    --
    -- Get future PCP records if any and zap - delete all of them.
    --
        for l_pcp_future in c_pcp_future(orec.elig_cvrd_dpnt_id) loop
      --
      hr_utility.set_location('ZAP prmry_care_prvdr_id '|| l_pcp_future.prmry_care_prvdr_id, 15);
      --
      l_pcp_effective_date := l_pcp_future.effective_start_date;
      --
            ben_prmry_care_prvdr_api.delete_prmry_care_prvdr
            (P_VALIDATE               => FALSE
            ,P_PRMRY_CARE_PRVDR_ID    => l_pcp_future.prmry_care_prvdr_id
            ,P_EFFECTIVE_START_DATE   => l_pcp_future.effective_start_date
            ,P_EFFECTIVE_END_DATE     => l_pcp_future.effective_end_date
            ,P_OBJECT_VERSION_NUMBER  => l_pcp_future.object_version_number
            ,P_EFFECTIVE_DATE         => l_pcp_effective_date
            ,P_DATETRACK_MODE         => hr_api.g_zap
            ,p_called_from            => 'delete_enrollment'
            );
        End loop;
        -- 3574168

        --
        -- Bug 2386000 Added new parameter p_called_from not to unsuspend the
        -- enrollment which is going to be deleted.
        ben_elig_cvrd_dpnt_api.delete_elig_cvrd_dpnt
          (p_validate                => FALSE
          ,p_elig_cvrd_dpnt_id       => orec.elig_cvrd_dpnt_id
          ,p_effective_start_date    => orec.effective_start_date
          ,p_business_group_id       => p_business_group_id
          ,p_effective_end_date      => orec.effective_end_date
          ,p_object_version_number   => orec.object_version_number
          ,p_effective_date          => l_effective_date
          ,p_datetrack_mode          => l_datetrack_mode
          ,p_multi_row_actn          => FALSE
          ,p_called_from             => p_called_from
          );
        --
      end if;
      --
      -- End of fix for INTERNAL BUG 4924.
      --
    End if;
   end if;
  End loop;
  if g_debug then
    hr_utility.set_location('Exiting'||l_proc, 30);
  end if;
exception
  --
  when others then
    rpt_error(p_proc => l_proc, p_step => l_step);
    fnd_message.raise_error;
End unhook_dpnt;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_prtt_enrt_rslt_id       in     number
  ,p_object_version_number   in     number
  ,p_effective_date          in     date
  ,p_datetrack_mode          in     varchar2
  ,p_validation_start_date      out nocopy date
  ,p_validation_end_date        out nocopy date
  ) is
  --
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72); --  := g_package||'lck';
  l_validation_start_date date;
  l_validation_end_date date;
  --
begin
  --
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_proc := g_package||'lck';
    hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  ben_pen_shd.lck
    (
      p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
     ,p_validation_start_date      => l_validation_start_date
     ,p_validation_end_date        => l_validation_end_date
     ,p_object_version_number      => p_object_version_number
     ,p_effective_date             => p_effective_date
     ,p_datetrack_mode             => p_datetrack_mode
    );
  --
  if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 70);
  end if;
  --
end lck;

--Start Bug 5768795

procedure chk_coverage_across_plan_types
(  p_person_id              in number,
   p_effective_date         in date,
   p_lf_evt_ocrd_dt         in date,
   p_business_group_id      in number,
   p_pgm_id                 in number,
   p_minimum_check_flag     in varchar default 'Y',
   p_suspended_enrt_check_flag in varchar default 'Y') is

  cursor c_acrs_ptip is
   select acrs_ptip_cvg_id,
          mx_cvg_alwd_amt,
          mn_cvg_alwd_amt
   from   ben_acrs_ptip_cvg_f
   where  pgm_id = p_pgm_id
     and  --p_effective_date between BUG 3051674
          p_lf_evt_ocrd_dt between
          effective_start_date and effective_end_date
     and  business_group_id = p_business_group_id;
  --
  cursor c_prtt_total_bnft_amt(p_acrs_ptip_cvg_id number) is
   select sum(prt.bnft_amt)
   from   ben_prtt_enrt_rslt_f prt,
          ben_ptip_f ptp
   where  prt.pgm_id = p_pgm_id
     and  prt.person_id = p_person_id
     and prt.sspndd_flag = 'N' -- # 3626176
     and  prt.prtt_enrt_rslt_stat_cd is null
     and  prt.effective_end_date = hr_api.g_eot
     and nvl(prt.enrt_cvg_thru_dt,hr_api.g_eot) = hr_api.g_eot
     and  p_effective_date between
          prt.effective_start_date and prt.effective_end_date
     and  prt.business_group_id = p_business_group_id
     and  p_lf_evt_ocrd_dt between -- BUG 3051674 p_effective_date between
          ptp.effective_start_date and ptp.effective_end_date
     and  ptp.acrs_ptip_cvg_id=p_acrs_ptip_cvg_id
     and  ptp.ptip_id=prt.ptip_id
     and  ptp.business_group_id=prt.business_group_id
   ;
  --Bug 3695005 fixes
  --This cursor needs to get suspended enrollments and
  --other enrollments. But it should exclude Interim coverages
  --here.
  --
  cursor c_prtt_total_bnft_amt_sspndd(p_acrs_ptip_cvg_id number) is
   select sum(prt.bnft_amt)
   from   ben_prtt_enrt_rslt_f prt,
          ben_ptip_f ptp
   where  prt.pgm_id = p_pgm_id
     and  prt.person_id = p_person_id
     and ( prt.sspndd_flag = 'Y' or (
           prt.sspndd_flag = 'N' and not exists (
             select 'x'
               from ben_prtt_enrt_rslt_f prt1
              where prt1.person_id = p_person_id
                and prt1.pgm_id = p_pgm_id
                and PRT1.rplcs_sspndd_rslt_id = prt.prtt_enrt_rslt_id
                and prt1.per_in_ler_id = prt.per_in_ler_id
                and prt1.sspndd_flag = 'Y'
                and p_lf_evt_ocrd_dt between
                    prt1.effective_start_date and prt1.effective_end_date
                and prt1.effective_end_date =  hr_api.g_eot
                and prt1.enrt_cvg_thru_dt = hr_api.g_eot
                and prt1.prtt_enrt_rslt_stat_cd is null)))
     and  prt.prtt_enrt_rslt_stat_cd is null
     and  prt.effective_end_date = hr_api.g_eot
     and  prt.enrt_cvg_thru_dt = hr_api.g_eot
     and  p_effective_date between
          prt.effective_start_date and prt.effective_end_date
     and  prt.business_group_id = p_business_group_id
     and  p_lf_evt_ocrd_dt between -- BUG 3051674 p_effective_date between
          ptp.effective_start_date and ptp.effective_end_date
     and  ptp.acrs_ptip_cvg_id=p_acrs_ptip_cvg_id
     and  ptp.ptip_id=prt.ptip_id
     and  ptp.business_group_id=prt.business_group_id
   ;

  cursor c_pl_typ_names(p_acrs_ptip_cvg_id number) is
   select name
   from ben_pl_typ_f
   where pl_typ_id in
              ( select pl_typ_id
                from ben_ptip_f
                where pgm_id = p_pgm_id
                and acrs_ptip_cvg_id = p_acrs_ptip_cvg_id
                and  business_group_id = p_business_group_id)
  and  p_lf_evt_ocrd_dt between
          effective_start_date and effective_end_date;
  --
  l_output_names varchar2(4000);
  l_total_amt               number;
  l_pl_typ_names varchar2(600);
  l_acrs_ptip c_acrs_ptip%rowtype;

  l_proc varchar2(72) := 'ben_PRTT_ENRT_RESULT_api.chk_coverage_across_plan_types';

begin

  if g_debug then
    hr_utility.set_location(' Entering '||l_proc, 70);
  end if;

 if p_pgm_id is not NULL then
    --
      if g_debug then
         hr_utility.set_location('Check for min/max across ptip', 77);
      end if;
      --
      for l_acrs_ptip in c_acrs_ptip loop
      --
       if g_debug then
          hr_utility.set_location('Check for min/max across ptip', 78);
       end if;
       open c_prtt_total_bnft_amt(l_acrs_ptip.acrs_ptip_cvg_id);
       fetch c_prtt_total_bnft_amt into l_total_amt;
       close c_prtt_total_bnft_amt;
       if g_debug then
          hr_utility.set_location('total='||l_total_amt||' mn='||
               l_acrs_ptip.mn_cvg_alwd_amt||' mx='||l_acrs_ptip.mx_cvg_alwd_amt,20);
       end if;
       --
        -- bug 3123698
           open c_pl_typ_names(l_acrs_ptip.acrs_ptip_cvg_id);
           loop
           fetch c_pl_typ_names into l_pl_typ_names ;
             if c_pl_typ_names%notfound then
                exit;
      	       else if l_output_names is null then
	     	    l_output_names := l_output_names||l_pl_typ_names;
	          else if length(l_output_names ||','||l_pl_typ_names) <= 4000 then
	              l_output_names := l_output_names ||','||l_pl_typ_names;
	          else
		       exit;
	          end if;
	        end if;
	     end if;
           end loop;
           close c_pl_typ_names;
	   -- end 3123698
       if l_acrs_ptip.mn_cvg_alwd_amt is not null and
          nvl(l_total_amt,0) < l_acrs_ptip.mn_cvg_alwd_amt and p_minimum_check_flag ='Y' then

           --
            fnd_message.set_name('BEN','BEN_92179_BELOW_MIN_AMOUNT');
            fnd_message.set_token('TOT_AMT',nvl(l_total_amt,0));
            fnd_message.set_token('MIN_AMT',l_acrs_ptip.mn_cvg_alwd_amt);
	    fnd_message.set_token('PL_TYP_NAMES',l_output_names); -- bug 3123698
	    fnd_message.raise_error;
          --
       elsif l_acrs_ptip.mx_cvg_alwd_amt is not null and
             l_total_amt > l_acrs_ptip.mx_cvg_alwd_amt then
       --
         fnd_message.set_name('BEN','BEN_92180_ABOVE_MAX_AMOUNT');
         fnd_message.set_token('TOT_AMT',nvl(l_total_amt,0));
         fnd_message.set_token('MX_AMT',l_acrs_ptip.mx_cvg_alwd_amt);
	 fnd_message.set_token('PL_TYP_NAMES',l_output_names); -- bug 3123698
         fnd_message.raise_error;
       --
       end if;
       --
       --Bug 3695005 Coverage Across Plan type considering
       --Suspended enrollment.
       --

     if p_suspended_enrt_check_flag = 'Y'  then

       open c_prtt_total_bnft_amt_sspndd(l_acrs_ptip.acrs_ptip_cvg_id);
       fetch c_prtt_total_bnft_amt_sspndd into l_total_amt;
       close c_prtt_total_bnft_amt_sspndd;
       --
       if l_acrs_ptip.mx_cvg_alwd_amt is not null and
             l_total_amt > l_acrs_ptip.mx_cvg_alwd_amt  then
       --
         fnd_message.set_name('BEN','BEN_92180_ABOVE_MAX_AMOUNT');
         fnd_message.set_token('TOT_AMT',nvl(l_total_amt,0));
         fnd_message.set_token('MX_AMT',l_acrs_ptip.mx_cvg_alwd_amt);
	 fnd_message.set_token('PL_TYP_NAMES',l_output_names); -- bug 3123698
         fnd_message.raise_error;
       --
       end if;
       --
       if g_debug then
          hr_utility.set_location('total='||l_total_amt||' mn='||
               l_acrs_ptip.mn_cvg_alwd_amt||' mx='||l_acrs_ptip.mx_cvg_alwd_amt,20);
       end if;
       --
       end if; --p_suspended_enrt_check_flag

      end loop; --c_acrs_ptip
    --
  end if;

  if g_debug then
    hr_utility.set_location(' Leaving '||l_proc, 70);
  end if;


end chk_coverage_across_plan_types;

--End Bug 5768795
--
-- ----------------------------------------------------------------------------
-- |---------------------< multi_rows_edit >----------------------------------|
-- ----------------------------------------------------------------------------
--
procedure multi_rows_edit
  (p_person_id              in number,
   p_effective_date         in date,
   p_business_group_id      in number,
   p_pgm_id                 in number,
   p_per_in_ler_id          in number  default NULL,
   p_include_erl            in varchar2,
   p_called_frm_ss          in Boolean default FALSE

  ) is
  --
  --Bug 3051674 We need to validate the edits with the life events
  --occured on date. This is an issue mainly for the open enrollment
  --If there is a change in the restrictions for the coverages etc.
  --Not using this for delete enrollment calls and corresponding
  --cursors.
  --
  cursor c_le_date(p_per_in_ler_id number) is
    select
      lf_evt_ocrd_dt
    from
      ben_per_in_ler pil
    where pil.per_in_ler_id = p_per_in_ler_id ;
  --
  l_lf_evt_ocrd_dt date ;
  --
  --End of 3051674 changes
  --
  -- If c1 or c1_pnip change, change the matching cursor in BENUTILS.pld
  -- enrt_pfc_deenrol procedure
  --
  Cursor c1 is
    Select r.prtt_enrt_rslt_id
          ,r.effective_start_date
          ,r.effective_end_date
          ,r.object_version_number
          ,r.pl_id
          ,r.pl_typ_id
          ,r.oipl_id
          ,r.pgm_id
          ,r.erlst_deenrt_dt
          ,r.person_id
          ,oipl.opt_id
          ,r.ptip_id
          ,r.enrt_mthd_cd   --Bug 2200139
      From ben_prtt_enrt_rslt_f r,
           ben_oipl_f oipl,
           ben_elig_per_elctbl_chc c
     Where c.per_in_ler_id = p_per_in_ler_id
       and r.prtt_enrt_rslt_id = c.prtt_enrt_rslt_id
       and r.per_in_ler_id <> c.per_in_ler_id
       and r.person_id = p_person_id
       and nvl(r.pgm_id,-1) = p_pgm_id
       and r.effective_end_date = hr_api.g_eot
       and nvl(enrt_cvg_thru_dt,hr_api.g_eot) = hr_api.g_eot
       and r.prtt_enrt_rslt_stat_cd is null
       and c.comp_lvl_cd not in ('PLANFC', 'PLANIMP')
       and c.elctbl_flag = 'Y'
       /* BUG 3939785
       and (r.ENRT_OVRID_THRU_DT is null or
            r.ENRT_OVRID_THRU_DT < p_effective_date)
       */
       and ( r.enrt_ovridn_flag  = 'N'  /* Bug 3958064 */
           or
             ( r.enrt_ovridn_flag = 'Y' and  nvl(r.ENRT_OVRID_THRU_DT,hr_api.g_eot) <= l_lf_evt_ocrd_dt ) -- 9114147
           )
       and oipl.oipl_id(+)=r.oipl_id
       and oipl.business_group_id(+)=r.business_group_id
       and p_effective_date between
           oipl.effective_start_date(+) and oipl.effective_end_date(+)
    --
    -- Bug 2600087 Added for finding the results which are not found
    -- when linked with epe records
    union
    Select r.prtt_enrt_rslt_id
          ,r.effective_start_date
          ,r.effective_end_date
          ,r.object_version_number
          ,r.pl_id
          ,r.pl_typ_id
          ,r.oipl_id
          ,r.pgm_id
          ,r.erlst_deenrt_dt
          ,r.person_id
          ,oipl.opt_id
          ,r.ptip_id
          ,r.enrt_mthd_cd
      From ben_prtt_enrt_rslt_f r,
           ben_oipl_f oipl
     Where r.per_in_ler_id <> p_per_in_ler_id
       and r.person_id = p_person_id
       and nvl(r.pgm_id,-1) = p_pgm_id
       and r.effective_end_date = hr_api.g_eot
       and nvl(enrt_cvg_thru_dt,hr_api.g_eot) = hr_api.g_eot
       and r.prtt_enrt_rslt_stat_cd is null
       and r.comp_lvl_cd not in ('PLANFC', 'PLANIMP')
       /* BUG 3939785
       and (r.ENRT_OVRID_THRU_DT is null or
            r.ENRT_OVRID_THRU_DT < p_effective_date)
       */
       and ( r.enrt_ovridn_flag  = 'N' /* Bug 3958064 */
           or
             ( r.enrt_ovridn_flag = 'Y' and  nvl(r.ENRT_OVRID_THRU_DT,hr_api.g_eot) <= l_lf_evt_ocrd_dt) -- 9114147
           )
       and oipl.oipl_id(+)=r.oipl_id
       and oipl.business_group_id(+)=r.business_group_id
       and p_effective_date between
           oipl.effective_start_date(+) and oipl.effective_end_date(+)
--bug#2602124
       and not exists
            (
               select k.prtt_enrt_rslt_id
               from ben_elig_per_elctbl_chc k
               Where k.per_in_ler_id = p_per_in_ler_id
                 and k.prtt_enrt_rslt_id = r.prtt_enrt_rslt_id
                 and k.comp_lvl_cd not in ('PLANFC', 'PLANIMP')
            )
--bug 4262697 We need to delete only if there are electable choices exists in this life event
--            otherwise we don't need to delete.
       and exists
            (
               select k.elig_per_elctbl_chc_id
               from ben_elig_per_elctbl_chc k
               Where k.per_in_ler_id = p_per_in_ler_id
                 and k.pl_id = r.pl_id
                 and k.pgm_id= p_pgm_id
                 and ((k.oipl_id is null and r.oipl_id is null) or
                      (k.oipl_id = r.oipl_id )
                     )
            )
     ;

  --
  Cursor c1_pnip is
    Select r.prtt_enrt_rslt_id
          ,r.effective_start_date
          ,r.effective_end_date
          ,r.object_version_number
          ,r.pl_id
          ,r.pl_typ_id
          ,r.oipl_id
          ,r.pgm_id
          ,r.erlst_deenrt_dt
          ,r.person_id
          ,oipl.opt_id
          ,r.ptip_id
          ,r.enrt_mthd_cd
      From ben_prtt_enrt_rslt_f r
          ,ben_elig_per_elctbl_chc c
          ,ben_oipl_f oipl
          ,ben_pil_elctbl_chc_popl pel
     Where c.per_in_ler_id = p_per_in_ler_id
       and r.prtt_enrt_rslt_id = c.prtt_enrt_rslt_id
       and r.per_in_ler_id <> c.per_in_ler_id
       and r.person_id = p_person_id
       and r.prtt_enrt_rslt_stat_cd is null
       and r.pgm_id is NULL
       and pel.pgm_id is NULL
       and (pel.elcns_made_dt is not null or pel.dflt_asnd_dt is not NULL)
       and pel.pl_id = r.pl_id
       and c.pil_elctbl_chc_popl_id = pel.pil_elctbl_chc_popl_id
       and r.effective_end_date = hr_api.g_eot
       and nvl(enrt_cvg_thru_dt,hr_api.g_eot) = hr_api.g_eot
       and c.comp_lvl_cd not in ('PLANFC', 'PLANIMP')
       and c.elctbl_flag = 'Y'
       /*
       and (r.ENRT_OVRID_THRU_DT is null or
            r.ENRT_OVRID_THRU_DT < p_effective_date)
       */
       and ( r.enrt_ovridn_flag  = 'N' /* Bug 3958064 */
           or
             ( r.enrt_ovridn_flag = 'Y' and  nvl(r.ENRT_OVRID_THRU_DT,hr_api.g_eot) <= l_lf_evt_ocrd_dt) -- 9114147
           )
       and oipl.oipl_id(+)=r.oipl_id
       and oipl.business_group_id(+)=r.business_group_id
       and p_effective_date between
           oipl.effective_start_date(+) and oipl.effective_end_date(+)
-- BUG: 3904792: MAINLINE FIX FOR 3894240: WHEN UPDATING A SAVINGS PLAN RATE SYSTEM IS END DATE
       AND NOT EXISTS
           (SELECT NULL
              FROM ben_ler_f ler,
                   ben_pl_f pln
             WHERE ler.ler_id = r.ler_id
               AND ler.typ_cd = 'SCHEDDU'
               AND pln.SVGS_PL_FLAG = 'Y'
               and pln.pl_id = r.pl_id
               AND p_effective_date between pln.effective_start_date
                                        AND pln.effective_end_date
               AND p_effective_date between ler.effective_start_date
                                       AND ler.effective_end_date
           )
-- BUG: 3904792: ENDS --
      ;
  --
  type l_tbl is table of c1%rowtype index by binary_integer;
  l_rec                     l_tbl;
  l_cnt                     Binary_integer := 0;
  l_proc                    varchar2(72); --  := g_package||'multi_rows_edit';
  l_effective_start_date    date;
  l_effective_end_date      date;
  l_pl_typ_id               number;
  l_total_amt               number;
  l_other_pen_rec           ben_prtt_enrt_rslt_f%rowtype;
  l_rqd_perd_enrt_nenrt_uom varchar2(30);
  l_rqd_perd_enrt_nenrt_val number;
  l_rqd_perd_enrt_nenrt_rl  number;
  l_level                   varchar2(30);
  l_effective_date          date ;
  --
  --
  -- For program (if p_pgm_id is not null)
  --
  cursor no_lngr_elig_pgm_c is
   select pen.prtt_enrt_rslt_id,
          pen.object_version_number,
          pen.effective_start_date
     from ben_prtt_enrt_rslt_f     pen
    where pen.per_in_ler_id = p_per_in_ler_id
      and pen.pgm_id = p_pgm_id
      and pen.prtt_enrt_rslt_stat_cd is null
      and pen.no_lngr_elig_flag = 'Y'
      and pen.effective_end_date = hr_api.g_eot
      and nvl(enrt_cvg_thru_dt,hr_api.g_eot) = hr_api.g_eot
      and pen.business_group_id = p_business_group_id;
  --
  -- For plan not in program (p_pgm_id is null)
  --
  cursor pl_typ_c  is
    select distinct pln.pl_typ_id
     from  ben_pil_elctbl_chc_popl  pel,
           ben_pl_f                 pln
    where  pel.per_in_ler_id = p_per_in_ler_id
      and  pel.pgm_id is null
      and  (pel.elcns_made_dt is not null or pel.dflt_asnd_dt is not NULL)
      and  pln.pl_id = nvl(pel.pl_id, -1)
      and  p_effective_date between
             pln.effective_start_date and pln.effective_end_date
      and  pel.business_group_id = p_business_group_id
      and  pln.business_group_id = p_business_group_id;
  --
  cursor no_lngr_elig_pnip_c is
   select pen.prtt_enrt_rslt_id,
          pen.object_version_number,
          pen.effective_start_date
     from ben_prtt_enrt_rslt_f     pen
    where pen.pgm_id is null
      and pl_typ_id = l_pl_typ_id
      and pen.per_in_ler_id = p_per_in_ler_id
      and pen.prtt_enrt_rslt_stat_cd is null
      and pen.no_lngr_elig_flag = 'Y'
      and pen.effective_end_date = hr_api.g_eot
      and nvl(enrt_cvg_thru_dt,hr_api.g_eot) = hr_api.g_eot
      and pen.business_group_id = p_business_group_id;
  --
  cursor c_acrs_ptip is
   select acrs_ptip_cvg_id,
          mx_cvg_alwd_amt,
          mn_cvg_alwd_amt
   from   ben_acrs_ptip_cvg_f
   where  pgm_id = p_pgm_id
     and  --p_effective_date between BUG 3051674
          l_lf_evt_ocrd_dt between
          effective_start_date and effective_end_date
     and  business_group_id = p_business_group_id;
  --
  l_acrs_ptip c_acrs_ptip%rowtype;
  -- bug 3123698
  cursor c_pl_typ_names(p_acrs_ptip_cvg_id number) is
   select name
   from ben_pl_typ_f
   where pl_typ_id in
              ( select pl_typ_id
                from ben_ptip_f
                where pgm_id = p_pgm_id
                and acrs_ptip_cvg_id = p_acrs_ptip_cvg_id
                and  business_group_id = p_business_group_id)
  and  l_lf_evt_ocrd_dt between
          effective_start_date and effective_end_date;
  --
  l_pl_typ_names varchar2(600);
  l_output_names varchar2(4000);
  -- end 3123698
  --
  cursor c_prtt_total_bnft_amt(p_acrs_ptip_cvg_id number) is
   select sum(prt.bnft_amt)
   from   ben_prtt_enrt_rslt_f prt,
          ben_ptip_f ptp
   where  prt.pgm_id = p_pgm_id
     and  prt.person_id = p_person_id
     and prt.sspndd_flag = 'N' -- # 3626176
     and  prt.prtt_enrt_rslt_stat_cd is null
     and  prt.effective_end_date = hr_api.g_eot
     and nvl(prt.enrt_cvg_thru_dt,hr_api.g_eot) = hr_api.g_eot
     and  p_effective_date between
          prt.effective_start_date and prt.effective_end_date
     and  prt.business_group_id = p_business_group_id
     and  l_lf_evt_ocrd_dt between -- BUG 3051674 p_effective_date between
          ptp.effective_start_date and ptp.effective_end_date
     and  ptp.acrs_ptip_cvg_id=p_acrs_ptip_cvg_id
     and  ptp.ptip_id=prt.ptip_id
     and  ptp.business_group_id=prt.business_group_id
   ;
  --Bug 3695005 fixes
  --This cursor needs to get suspended enrollments and
  --other enrollments. But it should exclude Interim coverages
  --here.
  --
  cursor c_prtt_total_bnft_amt_sspndd(p_acrs_ptip_cvg_id number) is
   select sum(prt.bnft_amt)
   from   ben_prtt_enrt_rslt_f prt,
          ben_ptip_f ptp
   where  prt.pgm_id = p_pgm_id
     and  prt.person_id = p_person_id
     and ( prt.sspndd_flag = 'Y' or (
           prt.sspndd_flag = 'N' and not exists (
             select 'x'
               from ben_prtt_enrt_rslt_f prt1
              where prt1.person_id = p_person_id
                and prt1.pgm_id = p_pgm_id
                and PRT1.rplcs_sspndd_rslt_id = prt.prtt_enrt_rslt_id
                and prt1.per_in_ler_id = prt.per_in_ler_id
                and prt1.sspndd_flag = 'Y'
                and l_lf_evt_ocrd_dt between
                    prt1.effective_start_date and prt1.effective_end_date
                and prt1.effective_end_date =  hr_api.g_eot
                and prt1.enrt_cvg_thru_dt = hr_api.g_eot
                and prt1.prtt_enrt_rslt_stat_cd is null)))
     and  prt.prtt_enrt_rslt_stat_cd is null
     and  prt.effective_end_date = hr_api.g_eot
     and  prt.enrt_cvg_thru_dt = hr_api.g_eot
     and  p_effective_date between
          prt.effective_start_date and prt.effective_end_date
     and  prt.business_group_id = p_business_group_id
     and  l_lf_evt_ocrd_dt between -- BUG 3051674 p_effective_date between
          ptp.effective_start_date and ptp.effective_end_date
     and  ptp.acrs_ptip_cvg_id=p_acrs_ptip_cvg_id
     and  ptp.ptip_id=prt.ptip_id
     and  ptp.business_group_id=prt.business_group_id
   ;

  Cursor c_needs_dpnts (p_pl_typ_id number) is
    Select distinct r.prtt_enrt_rslt_id
          ,r.effective_start_date
          ,r.effective_end_date
          ,r.object_version_number
          ,r.pl_id
          ,r.pl_typ_id
          ,r.oipl_id
          ,r.pgm_id
          ,r.enrt_cvg_strt_dt
          ,c.elig_per_elctbl_chc_id
          ,c.dpnt_cvg_strt_dt_cd
          ,c.dpnt_cvg_strt_dt_rl
          ,pil.ler_id
          ,c.alws_dpnt_dsgn_flag
          ,pl.bnf_dsgn_cd
      From ben_prtt_enrt_rslt_f r,
           ben_elig_per_elctbl_chc c,
           ben_per_in_ler pil,
           ben_pl_f pl
     Where r.pl_typ_id          = p_pl_typ_id
       and r.per_in_ler_id      = p_per_in_ler_id
       and r.pgm_id             = p_pgm_id
       and r.person_id          = p_person_id
       and r.effective_end_date = hr_api.g_eot
       and r.enrt_cvg_thru_dt = hr_api.g_eot
       and r.prtt_enrt_rslt_stat_cd is null
       and r.prtt_enrt_rslt_id  = c.prtt_enrt_rslt_id
       and r.per_in_ler_id      = c.per_in_ler_id
       and c.comp_lvl_cd        not in ('PLANFC', 'PLANIMP')
       and pil.per_in_ler_id    = c.per_in_ler_id
       and pil.per_in_ler_stat_cd = 'STRTD'
       and pl.pl_id               = r.pl_id
       and p_effective_date between
           pl.effective_start_date and pl.effective_end_date
       and ((c.alws_dpnt_dsgn_flag = 'Y'
           and not exists (select 'x' from ben_elig_cvrd_dpnt_f pdp
           where pdp.prtt_enrt_rslt_id = r.prtt_enrt_rslt_id
           and p_effective_date between
           pdp.effective_start_date and pdp.effective_end_date))
           OR
           (pl.bnf_dsgn_cd is not null
           and not exists (select 'x' from ben_pl_bnf_f pbn
           where pbn.prtt_enrt_rslt_id = r.prtt_enrt_rslt_id
           and p_effective_date between
           pbn.effective_start_date and pbn.effective_end_date)));
  --
  l_needs_dpnts c_needs_dpnts%rowtype;
  l_process_dpnt      boolean := false;
  l_process_bnf       boolean := false;
  l_env_rec     ben_env_object.g_global_env_rec_type;
  --
  -- Bug 6656136
    cursor c_ler_typ_cd is
     --
     select ler.typ_cd
     from ben_per_in_ler pil,
          ben_ler_f ler
     where pil.per_in_ler_id = p_per_in_ler_id
      and  pil.ler_id =  ler.ler_id
      and  pil.business_group_id = p_business_group_id
      and  pil.business_group_id = ler.business_group_id
      and  p_effective_date between
	       ler.effective_start_date and ler.effective_end_date;
     --
   l_ler_typ_cd ben_ler_f.typ_cd%type;
     --
  begin
  --
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_proc := g_package||'multi_rows_edit';
    hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  --Bug 4709601 we dont need to call multi_rows_edit in this case
  --
  if ben_sspndd_enrollment.g_cfw_flag = 'Y' then
    hr_utility.set_location('Leaving- called from CFW action items',15);
    return;
  end if;
  --
  if fnd_global.conc_request_id in (0,-1) then
    --
    --bug#3568529
    ben_env_object.get(p_rec => l_env_rec);
    if l_env_rec.benefit_action_id is null then
    --
      ben_env_object.init(p_business_group_id  => p_business_group_id,
                        p_effective_date     => p_effective_date,
                        p_thread_id          => 1,
                        p_chunk_size         => 1,
                        p_threads            => 1,
                        p_max_errors         => 1,
                        p_benefit_action_id  => null);
    end if;
    --
  end if;
  --
  --
  --Bug 3051674 Get the le date
  --
  if p_per_in_ler_id is not null then
    --
    open c_le_date(p_per_in_ler_id);
      fetch c_le_date into l_lf_evt_ocrd_dt ;
    close c_le_date ;
    --
  end if ;
  --
  l_lf_evt_ocrd_dt := nvl(l_lf_evt_ocrd_dt,p_effective_date);
  --
  If p_per_in_ler_id is not NULL then
    If (p_pgm_id is not NULL) then
      For lrec in c1 loop
        l_cnt := l_cnt + 1;
        l_rec(l_cnt) := lrec;
      End loop;
    Else
      For lrec in c1_pnip loop
        l_cnt := l_cnt + 1;
        l_rec(l_cnt) := lrec;
      End loop;
    End if;
    --
    -- Remove any old enrollments - These are results where there was a choice
    -- in this same program for that comp object.  And they didn't elect the
    -- comp object (the result doesn't have this per-in-ler).  That must mean
    -- they don't want the enrollment anymore.
    --
    -- Before removing the enrollment, see if we can copy some of the dpnts or
    -- bnf's from the old enrollment (of the same plan type and program)
    -- to a new result.
    --
    For i in 1..l_cnt loop


      hr_utility.set_location('result id :'|| l_rec(i).prtt_enrt_rslt_id , 10);


      if l_rec(i).erlst_deenrt_dt is not null and
         l_rec(i).erlst_deenrt_dt>p_effective_date then
        ben_enrolment_requirements.find_rqd_perd_enrt(
                        p_oipl_id                 =>l_rec(i).oipl_id
                       ,p_opt_id                  =>l_rec(i).opt_id
                       ,p_pl_id                   =>l_rec(i).pl_id
                       ,p_ptip_id                 =>l_rec(i).ptip_id
                       ,p_effective_date          =>p_effective_date
                       ,p_business_group_id       =>p_business_group_id
                       ,p_rqd_perd_enrt_nenrt_uom =>l_rqd_perd_enrt_nenrt_uom
                       ,p_rqd_perd_enrt_nenrt_val =>l_rqd_perd_enrt_nenrt_val
                       ,p_rqd_perd_enrt_nenrt_rl  =>l_rqd_perd_enrt_nenrt_rl
                       ,p_level                   =>l_level
        );
        --
        -- Got level now see if other enrt in level exists
        --
        if l_level is not null then
          ben_enrolment_requirements.find_enrt_at_same_level(
           p_person_id               =>l_rec(i).person_id
          ,p_opt_id                  =>l_rec(i).opt_id
          ,p_oipl_id                 =>l_rec(i).oipl_id
          ,p_pl_id                   =>l_rec(i).pl_id
          ,p_ptip_id                 =>l_rec(i).ptip_id
          ,p_pl_typ_id               =>l_rec(i).pl_typ_id
          ,p_pgm_id                  =>l_rec(i).pgm_id
          ,p_effective_date          =>p_effective_date
          ,p_business_group_id       =>p_business_group_id
          ,p_prtt_enrt_rslt_id       =>l_rec(i).prtt_enrt_rslt_id
          ,p_level                   =>l_level
          ,p_pen_rec                 =>l_other_pen_rec
          );
        end if;
      end if;
      if l_other_pen_rec.prtt_enrt_rslt_id is not null or
         l_level is null or
         l_rec(i).erlst_deenrt_dt is null or
         l_rec(i).erlst_deenrt_dt<=p_effective_date then
        --
        if p_pgm_id is not null then
          for l_needs_dpnts in c_needs_dpnts(p_pl_typ_id => l_rec(i).pl_typ_id)
            loop
             --
             if l_needs_dpnts.alws_dpnt_dsgn_flag = 'Y' then
               l_process_dpnt := true;
             else
               l_process_dpnt := false;
             end if;
             if l_needs_dpnts.bnf_dsgn_cd is not null then
               l_process_bnf := true;
             else
               l_process_bnf := false;
             end if;
             --
             ben_mng_dpnt_bnf.recycle_dpnt_bnf
            (p_validate                   => FALSE
            ,p_new_prtt_enrt_rslt_id      => l_needs_dpnts.prtt_enrt_rslt_id
            ,p_old_prtt_enrt_rslt_id      => l_rec(i).prtt_enrt_rslt_id
            ,P_NEW_ENRT_RSLT_OVN          => l_needs_dpnts.object_version_number
            ,p_new_elig_per_elctbl_chc_id => l_needs_dpnts.elig_per_elctbl_chc_id
            ,p_person_id                  => p_person_id
            ,p_return_to_exist_cvg_flag   => 'N'
            ,p_old_pl_id                  => l_rec(i).pl_id
            ,p_new_pl_id                  => l_needs_dpnts.pl_id
            ,p_old_oipl_id                => l_rec(i).oipl_id
            ,p_new_oipl_id                => l_needs_dpnts.oipl_id
            ,p_old_pl_typ_id              => l_rec(i).pl_typ_id
            ,p_new_pl_typ_id              => l_needs_dpnts.pl_typ_id
            ,p_pgm_id                     => p_pgm_id
            ,p_ler_id                     => l_needs_dpnts.ler_id
            ,p_per_in_ler_id              => p_per_in_ler_id
            ,p_dpnt_cvg_strt_dt_cd        => l_needs_dpnts.dpnt_cvg_strt_dt_cd
            ,p_dpnt_cvg_strt_dt_rl        => l_needs_dpnts.dpnt_cvg_strt_dt_rl
            ,p_business_group_id          => p_business_group_id
            ,p_ENRT_CVG_STRT_DT           => l_needs_dpnts.enrt_cvg_strt_dt
            ,p_effective_date             => p_effective_date
            ,p_datetrack_mode             => hr_api.g_update -- note below
            ,p_process_dpnt               => l_process_dpnt
            ,p_process_bnf                => l_process_bnf);
            -- if the datetrack mode of update causes problems, then we'll need
            -- to pass the datetrack mode in from the form.  Each enrollment
            -- library will need to change.  We'd also probably want to pass in
            -- the dtmode from benauten, beneadeb and bensuenr.
          end loop;
        end if; -- if pgm_id is not null
        --
        -- Bug 2200139 If the old enrollment started in Future from Override Enrollment
        -- Pass the p_effective_date as effective_start_date + 1 to handle
        -- the deenroll and also backout cases.
        --
        if l_rec(i).effective_start_date >= p_effective_date then
          l_effective_date := l_rec(i).effective_start_date + 1 ;
        else
          l_effective_date := p_effective_date ;
        end if ;
        --
        delete_enrollment
        (p_validate                => FALSE
        ,p_per_in_ler_id           => p_per_in_ler_id
        ,p_prtt_enrt_rslt_id       => l_rec(i).prtt_enrt_rslt_id
        ,p_business_group_id       => p_business_group_id
        ,p_effective_start_date    => l_rec(i).effective_start_date
        ,p_effective_end_date      => l_rec(i).effective_end_date
        ,p_object_version_number   => l_rec(i).object_version_number
        ,p_effective_date          => l_effective_date
        ,p_datetrack_mode          => hr_api.g_delete
        ,p_multi_row_validate      => FALSE
        ,p_source                  => 'bepenapi'
        );
      end if;
    End loop;
    --
    if g_debug then
      hr_utility.set_location('Del rslts no lngr elig for', 30);
    end if;
    --
    -- Take care of enrollments no longer eligible for
    --
    -- In Program
    --
    if p_pgm_id is not null then
      --
      For rslt in no_lngr_elig_pgm_c Loop
        -- Bug 2200139
        if rslt.effective_start_date >= p_effective_date then
          l_effective_date := rslt.effective_start_date + 1 ;
        else
          l_effective_date := p_effective_date ;
        end if ;
        --
        if g_debug then

          hr_utility.set_location('Del rslt in Pgm no lngr elig for:' ||
                                to_char(p_pgm_id)||' rslt:'||
                                to_char(rslt.prtt_enrt_rslt_id), 35);
        end if;
        delete_enrollment
          (p_validate                => FALSE
          ,p_per_in_ler_id           => p_per_in_ler_id
          ,p_prtt_enrt_rslt_id       => rslt.prtt_enrt_rslt_id
          ,p_business_group_id       => p_business_group_id
          ,p_effective_start_date    => l_effective_start_date
          ,p_effective_end_date      => l_effective_end_date
          ,p_object_version_number   => rslt.object_version_number
          ,p_effective_date          => l_effective_date
          ,p_datetrack_mode          => hr_api.g_delete
          ,p_multi_row_validate      => FALSE
          ,p_source                  => 'bepenapi'
          );
        --
      End Loop;
    --
    else
      --   not in program
      --
      For typ In pl_typ_c Loop
        --
        l_pl_typ_id := typ.pl_typ_id;
        --
        if g_debug then
           hr_utility.set_location('Del rslt no lngr elig for for pl type '||
                                to_char(l_pl_typ_id), 37);
        end if;
        --
        For rslt In no_lngr_elig_pnip_c Loop
          --
          -- Bug 2200139
          if rslt.effective_start_date >= p_effective_date then
            l_effective_date := rslt.effective_start_date + 1 ;
          else
            l_effective_date := p_effective_date ;
          end if ;
          --
          delete_enrollment
            (p_validate                => FALSE
            ,p_per_in_ler_id           => p_per_in_ler_id
            ,p_prtt_enrt_rslt_id       => rslt.prtt_enrt_rslt_id
            ,p_business_group_id       => p_business_group_id
            ,p_effective_start_date    => l_effective_start_date
            ,p_effective_end_date      => l_effective_end_date
            ,p_object_version_number   => rslt.object_version_number
            ,p_effective_date          => l_effective_date
            ,p_datetrack_mode          => hr_api.g_delete
            ,p_multi_row_validate      => FALSE
            ,p_source                  => 'bepenapi'
            );
          --
        End Loop;
        --
      End Loop;
    --
    End if;
  --
  End if;
  --
  if not p_called_frm_ss then
  --
  ben_newly_ineligible.defer_delete_enrollment	 -- Defer ENH
  (p_per_in_ler_id	    => p_per_in_ler_id,
   p_person_id		    => p_person_id,
   p_business_group_id      => p_business_group_id,
   p_effective_date         => l_lf_evt_ocrd_dt
   );
  --
--Start Bug 5768795
--Moved the Code to the below called procedure. chk_coverage_across_plan_types is now externalized
--to be called from benrtchg.pkb.

 chk_coverage_across_plan_types
(  p_person_id              => p_person_id,
   p_effective_date         => p_effective_date,
   p_lf_evt_ocrd_dt         => l_lf_evt_ocrd_dt,
   p_business_group_id      => p_business_group_id,
   p_pgm_id                 => p_pgm_id);

--End Bug 5768795

    --
    -- Call multi row edit.
    --
    open c_ler_typ_cd;
     fetch c_ler_typ_cd into l_ler_typ_cd;
    close c_ler_typ_cd;
    --
-- Bug 6656136
    if l_ler_typ_cd in ('SCHEDDO','SCHEDDA') then
     --
    BEN_PEN_bus.multi_rows_edit
      (p_person_id           => p_person_id
      ,p_effective_date      => l_lf_evt_ocrd_dt
      ,p_business_group_id   => p_business_group_id
      ,p_pgm_id              => p_pgm_id
      ,p_include_erl         => p_include_erl
       );
    --
    else
     --
      BEN_PEN_bus.multi_rows_edit
      (p_person_id           => p_person_id
      ,p_effective_date      => p_effective_date
      ,p_business_group_id   => p_business_group_id
      ,p_pgm_id              => p_pgm_id
      ,p_include_erl         => p_include_erl
       );
    --
    end if;
    --
-- Bug 6656136
  end if; -- p_called_frm_ss
  --
  if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 70);
  end if;
  --
end multi_rows_edit;
--
-- Overloaded
--




procedure multi_rows_edit
  (p_person_id              in number,
   p_effective_date         in date,
   p_business_group_id      in number,
   p_pgm_id                 in number,
   p_per_in_ler_id          in number  default NULL,
   p_called_frm_ss          in Boolean default FALSE

  ) is
begin
   ben_prtt_enrt_result_api.multi_rows_edit(p_person_id=> p_person_id
                                     ,p_effective_date => p_effective_date
                                     ,p_business_group_id => p_business_group_id
                                     ,p_pgm_id => p_pgm_id
                                     ,p_per_in_ler_id => p_per_in_ler_id
                                     ,p_include_erl => 'N'
                                     ,p_called_frm_ss => p_called_frm_ss );  -- BUG 4690334
end multi_rows_edit;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_person_type_usages >----------------------------|
-- ----------------------------------------------------------------------------
--
-- VP 11/08/00
--
Procedure update_person_type_usages
    (p_person_id             in     number,
     p_business_group_id     in     number,
     p_effective_date        in     date
     ) is
--
  l_proc        varchar2(72); -- := g_package||'update_person_type_usages';
--
Begin

  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_proc := g_package||'update_person_type_usages';
    hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  --
  if (g_enrollment_change) then
     --
     ben_pen_bus.manage_per_type_usages
    (p_person_id           => p_person_id
        ,p_business_group_id   => p_business_group_id
        ,p_effective_date      => p_effective_date
        );
     null;
     --
  end if;

  g_enrollment_change := FALSE;
  --
  if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
  --
End update_person_type_usages;

-- ----------------------------------------------------------------------------
-- |------------------------< delete_enrollment_w >-----------------------------|
-- ----------------------------------------------------------------------------
--
--  Description: Self-service wrapper for delete_enrollment to handle exceptions
--
procedure delete_enrollment_w
  (p_validate                in      boolean   default false
  ,p_per_in_ler_id           in      number    default NULL
  ,p_lee_rsn_id              in      number    default NULL
  ,p_enrt_perd_id            in      number    default NULL
  ,p_prtt_enrt_rslt_id       in      number
  ,p_business_group_id       in      number
  ,p_effective_start_date    out nocopy     date
  ,p_effective_end_date      out nocopy     date
  ,p_object_version_number   in out nocopy  number
  ,p_effective_date          in      date
  ,p_datetrack_mode          in      varchar2
  ,p_multi_row_validate      in      boolean  default TRUE
  ,p_source                  in      varchar2 default null
  ,p_enrt_cvg_thru_dt        in      date     default null
  ,p_mode                    in      varchar2 default null)
is
   l_proc varchar2(72) := g_package||'delete_enrollment_w';
begin
  fnd_msg_pub.initialize;

  if g_debug then
    hr_utility.set_location('Entering:'||l_proc, 5);
  end if;

delete_enrollment
  (p_validate                => p_validate
  ,p_per_in_ler_id           => p_per_in_ler_id
  ,p_lee_rsn_id              => p_lee_rsn_id
  ,p_enrt_perd_id            => p_enrt_perd_id
  ,p_prtt_enrt_rslt_id       => p_prtt_enrt_rslt_id
  ,p_business_group_id       => p_business_group_id
  ,p_effective_start_date    => p_effective_start_date
  ,p_effective_end_date      => p_effective_end_date
  ,p_object_version_number   => p_object_version_number
  ,p_effective_date          => p_effective_date
  ,p_datetrack_mode          => p_datetrack_mode
  ,p_multi_row_validate      => p_multi_row_validate
  ,p_enrt_cvg_thru_dt        => p_enrt_cvg_thru_dt
  ,p_mode                    => p_mode);

  if g_debug then
    hr_utility.set_location('Leaving:'||l_proc, 10);
  end if;

exception
  --
  when app_exception.application_exception then	--Bug 4387247
    hr_utility.set_location ('Application Error in delete_enrollment_w.', 88);
    fnd_msg_pub.add;
  when others then
    if g_debug then
      hr_utility.set_location('Exception:'||l_proc, 100);
    end if;
    hr_utility.set_location ('Other Error in delete_enrollment_w : '|| sqlerrm , 89);
    --Bug 4387247
    fnd_message.set_name('PER','FFU10_GENERAL_ORACLE_ERROR');
    fnd_message.set_token('2',substr(sqlerrm,1,200));
    fnd_msg_pub.add;
  --
 end delete_enrollment_w;
--

end ben_PRTT_ENRT_RESULT_api;

/
