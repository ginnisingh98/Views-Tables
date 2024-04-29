--------------------------------------------------------
--  DDL for Package Body BEN_SSPNDD_ENROLLMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_SSPNDD_ENROLLMENT" as
/* $Header: bensuenr.pkb 120.33.12010000.11 2009/07/22 07:13:16 pvelvano ship $ */
/* ===========================================================================
 * Name
 *        Suspend enrollment
 * Purpose
 *        This package is used to update the enrollment result to indicate
 *        it to be suspended and assign a interiem coverage if it's required
 *        and available.
 * History
 *   Date        Who        Version What?
 *   ----------- ---------- ------- -----
 *   27 May 1998 maagrawa   110.0   Created.
 *   17 Jun 1998 maagrawa   110.1   elctbl_chc api changes.
 *   19 Jun 1998 maagrawa   110.2   Header line changes.
 *   24 Jun 1998 maagrawa   110.3   Added call to multi_row_edit.
 *   07 Jul 1998 jmohapat   110.4   Added batch who col to call of
 *                                  ben_elig_per_elc_chc_api.update..
 *                                  ,ben_prtt_enrt_result_api.update.
 *   22 Jul 1998 maagrawa   110.5   p_rslt_object_version_number argument added.
 *   22 Sep 1998 bbulusu    110.6   removed p_enrt_mthd_cd from
 *                                  p_suspend_enrollment
 *   30 Oct 1998 Hdang      115.7   Change (Un)suspend process logic Remove
 *                                  misc. procedures/Functions
 *   30 Oct 1998 Hdang      115.8   add per_in_ler_id as one of input parameter.
 *   19 Nov 1998 Hdang      115.9   unsuspended options if plan is saving plan.
 *   10 Feb 1999 Hdang      115.10  Add logic to handle unsuspend enrollment.
 *   19 Feb 1999 Hdang      115.11  Add logic to handle interim coverage.
 *   03 Mar 1999 jcarpent   115.12  Removed dbms_output.put_lines
 *   04 Mar 1999 jcarpent   115.13  Unsuspend handles old Element entries.
 *   22 Mar 1999 jcarpent   115.15  Removed pen join in c_prv cursor
 *   03 May 1999 jcarpent   115.16  Added check for prtt_rt_val_stat_cd is null
 *   03 May 1999 shdas      115.17  Added contexts to rule calls.
 *   03 May 1999 jcarpent   115.18  Added support for unsspnd_enrt_cd
 *   03 May 1999 shdas      115.21  Added jurisdiction_cd
 *   06 May 1999 jcarpent   115.22  check status of per_in_ler <> 'VOIDD'
 *   07 May 1999 lmcdonal   115.23  Check status of prtt_enrt_rslt, and added
 *                                  per_in_ler_stat <> 'BCKDT'.
 *   08 May 1999 jcarpent   115.24  Check ('VOIDD', 'BCKDT') for pil stat cd
 *   11 May 1999 jcarpent   115.25  Fixed unsspnd_enrt_cd of 'UEECSD' to
 *                                  handle null l_rec_rt_strt_dt.
 *   19 May 1999 jcarpent   115.26  Changed c_current_enrt cursor to union
 *                                  to pick up only choice for current pil
 *                                  or no choice at all.
 *   19 May 1999 jcarpent   115.27  Added c_new_ovn cursor to get updated ovn.
 *                                  Changed determine interim result cursor
 *                                  to only get old enrollments.
 *                                  Process_interim was passing epe.ovn as
 *                                  the pen.ovn into ben_election_info.
 *   09 Jul 1999 jcarpent   115.28  Added checks for backed out nocopy pil
 *   20-JUL-1999 Gperry     115.29  genutils -> benutils package rename.
 *   12-Aug-1999 lmcdonal   115.30  Call get_ben_pen_upd_dt_mode before calling
 *                                  update_prtt_enrt_rslt.
 *   19-Aug-1999 lmcdonal   115.31  Add call to premium_warning.Made p_person_id
 *                                  required in update_sspndd_flag.
 *   07-Sep-1999 tguy       115.32  fixed call to pay_mag_util
 *   09-Sep-1999 maagrawa   115.33  Backport to 115.29. Made fix to calculate
 *                                  dpnt_cvg_strt_dt when the code is not null
 *   09-Sep-1999 maagrawa   115.34  Leapfrog to 115.32 and applied changes in
 *                                  115.33
 *   14-Sep-1999 shdas      115.35  changed election_information to add bnft_amt
 *   08-oct-1999 jcarpent   115.36  Added ed to call to create_enrollment_ele
 *   10-oct-1999 pbodla     115.37  Added ed to call to reopen_closed_enrollment
 *   26-Oct-1999 maagrawa   115.38  Fixed c_choice_info cursor in
 *                                  unsuspend_enrt to get choice for the same
 *                                  per_in_ler_id as the result.
 *   05-Nov-1999 jcarpent   115.39  Fixed interim cursors to be less
 *                                  restrictive, use election_information globs
 *   12-Nov-1999 lmcdonal   115.41  Better debugging message
 *   19-Nov-1999 pbodla     115.42  Added p_elig_per_elctbl_chc_id as parameter to
 *                                  get_dflt_to_asn_pndg_ctfn_cd
 *   03-Jan-2000 lmcdonal   115.43  When update_prtt_rt_val is called, update the
 *                                  per_in_ler_id too.  This is used in a check in
 *                                  the election_rate_information proc to decide
 *                                  if the rt_strt_dt should be recalulated.
 *                                  Bug 1121022
 *   06-Jan-2000 maagrawa   115.44  Update rate start date and dpnt cvg strt dt
 *                                  while unsuspending only if enrt cvg strt dt
 *                                  is to be updated.
 *                                  Pass person_id when calling
 *                                  update_prtt_rt_val api. (Bug 1096737)
 *   13-Jan-2000 lmcdonal   115.45  When calling election_info to create a new
 *                                  result, pass in the correct enrt_mthd_cd.
 *                                  Bug 1147606.
 *   24-Jan-2000 maagrawa   115.46  Pass per_in_ler_id when calling
 *                                  process_post_results (Bug 1148445)
 *   05-Feb-2000 maagrawa   115.47  Fixed interim coverage logic in
 *                                  procedure determine_interim (1172233).
 *
 *   10-FEB-2000 shdas      115.48  call determine_date.main only if
 *                                  dpnt_cvg_end_dt_cd is not null.
 *   18-Feb-2000 jcarpent   115.49  changed the c_choice_info cursor to use
 *                                  the comp object to join instead of the
 *                                  result_id since won't be the same.
 *   18-Feb-2000 bbulusu    115.49  Added join to plan to determine if
 *                                  bnf designation is optional
 *   28-Feb-2000 maagrawa   115.50  Pass p_source to delete_enrollment.
 *
 *   28-Feb-2000 pbodla     115.51   Bug: 4279 : passed p_prtt_rt_val_id to
 *                                   reopen. To get the correct element entry
 *   24-Mar-2000 lmcdonal   115.52   better debugging messages.
 *                                   Bug 1247109 - was sometimes using the wrong
 *                                   result id for interim coverage.
 *   28-Mar-2000 shdas      115.53   delete ledger row if result is suspended.
 *   30-Mar-2000 lmcdonal   115.54   Bug 1252084 - When cvg restriction is Opt,
 *                                   we still may have a bnft row hanging off
 *                                   the opt.  Fetch it: c_next_lower_oipl_epe,
 *                                   c_min_oipl_epe
 *   13-Apr-2000 pbodla     115.55 - Bug 5052 - unsuspend_enrollment :
 *                                   moved the interim update or delete to
 *                                   the beginning of procedure. First
 *                                   update or delete the interim and then
 *                                   do the un suspend of original enrollment.
 *   17-Apr-2000 maagrawa   115.56 - Bug 5098. Check the ctfn_rqd_flag for the
 *                                   benefit record also, even if the rstrn
 *                                   is "Option Restriction applies".
 *   22-May-2000 lmcdonal   115.57   Bug 1249901 - when cvg is entered at enrt
 *                                   and interim is 'min', give them the min
 *                                   amt from same bfnt row.
 *   23-May-2000 lmcdonal   115.58   Fix v57 fix so that other interims with
 *                                   'min' codes work.
 *   24-May-2000 shdas      115.59   bug 5234- interim cvg end date is set based on
 *                                   datetrack mode.
 *   19-Jul-2000 rchase     115.61   bug 5353 - iterim cvg not selecting previous
 *                                   cvg if previous cvg exists in same pl or pl_typ
 *   19-Jul-2000 rchase     115.62   bug 5181 - backed out nocopy cvg included in selection
 *                                   for current.
 *   04-Aug-2000 jcarpent   115.63   bug 5353 - Bug was wrong.  Should use
 *                                   code not hardcode to 'SM'
 *                                   Also bug 5427. Was not checking interim
 *                                   codes stored on plip.
 *   28-Aug-2000 jcarpent   115.64   bug 1386626. Recalc imputed income for
 *                                   suspend/unsuspend enrollments.
 *
 *   06-Sep-2000 rchase     115.65   fix for bug#1394066.  Set the interim coverage
 *                                   date to suspended - 1 if coverage start
 *                                   dates are the same.
 *   23-Oct-2000 pbodla     115.66   fix for bug#1471135 : Added code to reset
 *                                   the enrt_cvg_strt_dt after the cursor
 *                                   csr_prtt_enrt_rslt is opened second time.
 *   14-Nov-2000 rchase     115.67   Bug 1477284.  Also look for unsuspend
 *                                   enrt_cd at ptip level.
 *   09-Jan-2001 mhoyes     115.68 - Added new out nocopy parameter to call
 *                                   create_enrollment_element.
 *   27-Feb-2001 kmahendr   115.69 - Bug#1649847 - changed value of parameter from
 *                                   p_per_in_ler_id to l_per_in_ler_id to call
 *                                   ben_determine_date.rate_and_coverage_dates
 *                                   as null was passed
 *   29-Mar-2001 maagrawa   115.70   When the enrollment is unsuspended, update
 *                                   or create the element entries for rates
 *                                   which are active for this result and
 *                                   life event.
 *   02-Apr-2001 kmahendr   115.71 - Bug#1617825 - when the enrollment is unsuspended
 *                                   call create_debit_ledger_entries to write ledger
 *                                   entries into pool
 *   27-aug-2001 tilak      115.72   bug:1949361 jurisdiction code is
                                     derived inside benutils.formula.
 *   02-nov-2001 pbodla     115.73   bug:2088231 Called accumulate pools after
 *                                   unsuspend enrollment.
 *   23-Jan-2002 ikasire    115.74   bug:2185509 when unsuspended, we are  calling
 *                                   the ben_provider_pools.remove_bnft_prvdd_ldgr
 *                                   to remove the ledger entries of the interim
 *                                   coverage
 *   30-Jan-2002 ikasire    115.75   Bug2191886 fixed the error where effective
 *                                   date is used for life event occured date in
 *                                   unsuspend enrollment.
 *   28-Jan-2002 hnarayan   115.76   Bug 1826902 when rule is attached to interim
 *                                   coverage, the default to assign pending code
 *                                   returned by the rule is captured as Varchar2
 *				     and returned as number. Fixed.
 *   13-Mar-2002 pbodla     115.77   p_cmncd_rt, and p_ann_rt values passed to
 *                                   create_enrollment_element : Based on
 *                                   ele_entry_val_cd communicated and annual
 *                                   rate values are used in EE creation.
 *   29-Mar-2002 ikasire    115.78   Bug 1998648 Interim issues related with
 *                                   default code are fixed. See bug for more
 *                                   details.
 *
 *   10-Apr-2002 ikasire    115.79   Bug 1886183 fixed the enter value at enrollment
 *                                   cases for the determine_interim procedure.
 *   20-Apr-2002 ikasire    115.80   Bug 1886183 fixed the cursor which determines the
 *                                   current enrollment in determine_interim process
 *   08-Jun-2002 pabodla    115.81   Do not select the contingent worker
 *                                   assignment when assignment data is
 *                                   fetched.
 *   02-Jul-2002 pabodla    115.82   Bug 2396628: at the time of unsuspending a plan
 *                                   check whether interim is there or not
 *                                   if interim is already deleted then bypass
 *                                   deletion logic.
 *   07-Jul-2002 ikasire    115.82   Bug 2502633 - Interim Enhancements
 *                                   See Bug for more details.
 *   13-Aug-2002 hnarayan   115.84   Bug 2330694 - Premium handling for interim
 *				     coverage. See bug for details
 *   03-Sep-2002 ikasire    115.85   Bug 2538015 changes to unsuspend enrollment
 *                                   procedure to use the unsuspend code for
 *                                   ending the interim coverage, rates and
 *                                   starting the unsuspeded enrollment coverage and
 *                                   rates.
 *                                   Also fixed the interim code xxx,xxx;New, Next Lower
 *                                   cursor c_next_lower_pl_typ_epe to exclude the
 *                                   oipl under suspension.
 *   06-Sep-2002 ikasire    115.86   if the default is another comp object and the
 *                                   coverage calculation is enter value at enrollment
 *                                   need to get the right benefit record for interim
 *   06-Sep-2002 ikasire    115.87   Bug2543071 added the person_id and program_id in
 *                                   the cursor c_current_same_epe where clause
 *   19-Sep-2002 ikasire    115.88   Bug2577315 Fixed the Next Lower Option restricitons
 *                                   error. Changed to (+) to nvl in where clause
 *   26-Sep-2002 ikasire    115.89   Bug 2595113 fixed the cursor c_current_enrt in
 *                                   determine_interim procedure
 *   02-Dec-2002 hnarayan   115.90   Bug 2689926 - changed unsuspend_enrollment to
 *				     call ben_provider_pools.total_pools after
 *				     calling accumulate_pools.
 *   24-dec-2002 hmani      115.91   For nocopy changes
 *   15-May-2003 ikasire    115.92   Bug2958032 Issues in Unsuspended enrollment
 *                                   1.update epe with the pen id
 *                                   2.update enb to removed the interim pen id
 *                                     and make sure we have the right pen id on
 *                                     the unsuspended pen
 *   26-Jun-2003 ikasire    115.93   c_pea is getting called multiple times due
 *                                   to date trackupdate of the pen row.
 *   23-Jul-2003 ikasire    115.94   Bug 3042379 fixes for indefinate loop when
 *                                   multiple certifications are required or
 *                                   dependent or beneficiary designation in
 *                                   combination with benefit restrictions.
 *   18-Aug-2003 ikasire    115.95   Bug 3095291 cleaned the c_current_enrt
 *                                   cursor and removed the union and out joined
 *                                   to epe.
 *   30-Oct-2003 kmahendr   115.96   Bug#3202455 - added a cursor c_previous_status
 *                                   in unsuspend_enrollment procedure.
 *   25-Nov-2003 ikasire    115.97   Bug 3278908 Modified the c_ppe cursor get the
 *                                   correct record
 *   14-Jan-2004 ikasire    115.98   Bug fix 3202455 introduced another regression
 *                                   Since l_previous_no_sspn is not initialized
 *                                   nevel goes into IF clause and always goes into
 *                                   else clause. This will make the system not to
 *                                   use unsuspend code.
 *   21-Jan-2004 mmudigon    115.99  Bug 3317017. CWB Changes
 *   16-Feb-2004 ikasire     115.100 Bug 3441027 compute the date track mode while
 *                                   unsuspending the result
 *   08-Jun-2004 kmahendr    115.101 Bug#3659657 - added code to suspend_enroll procedure
 *                                   to handle correction of date received for certification
 *   22-Jun-2004 kmahendr    115.102 Bug#3692450 - rate start date not changedif the
 *                                   unsuspend code is UEECSD.
 *   30-Jun-2004 tjesumic    115.103 bug 3666347 fixed by reverting 115.84 2330694 fix
 *   02-Aug-2004 kmahendr    115.104 Bug#3794162 - added a parameter - p_per_in_ler_id
 *                                   to determine_interim and modified cursors by joing
 *                                   per_in_ler_id
 *   04-Aug-2004 kmahendr    115.105 Bug#3794162 - modified cursor c_interim
 *   23-Aug-2004 mmudigon    115.106 CFW. Added p_act_item_flag to
 *                                   suspend_enrollment.
 *                                   2534391 :NEED TO LEAVE ACTION ITEMS
 *   26-aug-2004 nhunur      115.107 gscc compliance
 *   05-sep-2004 ikasire     115.108 FIDOML Override Enhancements
 *   07-Sep-2004 mmudigon    115.109 CFW. Changes to suspend_enrollment
 *   09-Sep-2004 mmudigon    115.110 CFW. p_act_item_flag no longer needed
 *   03-Nov-2004 ikasire     115.111 Bug 3977951 fix
 *   13-Nov-2004 kmahendr    115.112 Bug#4009443-modified cursor c_current_enrt
 *   16-Nov-2004 kmahendr    115.113 Bug#4009443-modified cursor c_current_enrt
 *   30-dec-2004  nhunur     115.114 4031733 - No need to open cursor c_state.
 *   07-Jan-2005 ikasire     115.115 Bug 4064635. Need to carry forward suspended and
 *                                   interim enrollment
 *   11-Jan-2005 ikasire     115.116 CF Interim Suspended BUG 4064635
 *   18-Jan-2005 ikasire     115.117 CF Interim Suspended BUG 4064635- unsuspend epe
 *                                   for electable is 'N'
 *   02-Feb-2005 ikasire     115.118 CF Interim Suspended BUG 4064635
 *   10-Feb-2005 kmahendr    115.119 Bug#4172569 - suspend flag is checked
 *   16-Feb-2005 kmahendr    115.120 Bug#4186343 - cursors in determine_interim modified to
 *                                   look for optional certification
 *   07-Mar-2005 ikasire     115.121 Bug#4223840 Second part of Interim code is not
 *                                   evaluated right in determining the interim code
 *                                   when you save the enrollments multiple times.
 *   18-Mar-2005 ikasire     115.122 Bug 4247213 Performance changes
 *   24-Mar-2005 abparekh    115.123 Bug 4256836 : While determining interim coverage
 *                           115.124 select electable choice that falls under the program
 *                                   for which enrollment is suspended. This it to avoid
 *                                   suspended and interim falling into different programs
 *   05-Apr-2005 abparekh    115.125 Bug 4141269 pass p_input_value_id and p_element_type_id
 *                                   as null to ben_element_entry.create_enrollment_element
 *   14-Apr-2005 ikasire     115.126 Added new parameter to manage_enrt_bnft call
 *   20-Jun-2005 mmudigon    115.127 Bug 4352871. Added logic to delete element
 *                                   entries when pen is suspended.
 *   29-Jun-2005 ikasire     115.128 Bug 4422667 getting into loop issue
 *   17-Aug-2005 ikasire     115.129 Bug 4547332 fix changes to c_current_enrt
 *   19-Aug-2005 ikasire     115.130 Bug 4563223 to filter program in the cursor
 *   26-Aug-2005 ikasire     115.131 Bug 4558512 for completion date
 *                                   search string p_cmpltd_dt
 *   01-Sep-2005 ikasire     115.132 Bug 4577581 we need to pass p_per_in_ler_id to
 *                                   multi row edit call from susps and unsusp
 *   13-Sep-2005 ikasire     115.133 Bug 4463267 fix several interim cursors
 *   15 Sep 2005 ikasire     115.134 Bug 4450214 Added cfw condition bases on
 *                                   g_cfw_flag and modified the cfw cursor to
 *                                   to function as per the changed process in
 *                                   election_information.
 *   22 Sep 2005 ikasire     115.135 Bug 4622534 for carrforward dependents from
 *                                   default rule
 *   27 Sep 2005 mmudigon    115.136 Bug 4622534 continued. Added join on
 *                                   person_id in cursor c_cf_suspended
 *   05 Dec 2005 bmanyam     115.137 4775743: If Dpnt Cvg starts after the PEN Cvg Strt,
 *                                   then use Dpnt Cvg Strt, as the Start date
 *                                   for restoring results.
 *   07 Mar 2006 ikasired    115.140 Interim - Default to Assign Pending Action
 *                                   Rule Enhacenments.
 *   07 Mar 2006 ikasired    115.141 Interim - Rule more changes
 *   12 Apr 2006 ikasired    115.142 fix for regression from 115.120 version
 *                                   Flat Range see Bug 5158595
 *   12 Apr 2006 ikasired    115.143 fix for flat rante bug 5158471
 *   19 Apr 2006 gsehgal     115.144 bug:5148514. change the message when interim amount is
 *                                   equal to benefit amount.
 *   27 Apr 2006 nhunur      115.145 bug:5135117. interim amount should be less than
 *                                   benefit amount.
 *   16 May 2006 swjain      115.146 Bug 5225780 - Updated procedure validate_interim_rule
 *                                   to pick valid epe records
 *   17 May 2006 swjain      115.147 Bug 5225780 - Updated the message number
 *   18-May-2006 abparekh    115.149 Bug 5231894 - While un-suspending, update rate start date
 *                                                 only if its earlier than date of un-suspension
 *   11-Jul-2006 ssarkar     115.150 Bug 5381200 - modified c_bnft,c_dflt_bnft of proc determine_interim
 *   26-Jul-2006 rtagarra    115.151 Bug 5402317 - modified cursor c1 to check as per lf_evt_ocrd_dt.
 *   01-Aug-2006 abparekh    115.152 Bug 5415757 - Commented cursor c_rt clause that prevented carry
 *                                                 forward of rates for interim PEN.
 *   30-Aug-2006 rtagarra    115.153 Bug 5491212 - Changed the cursor Csr_prtt_enrt_rslt.
 *   12-Oct-2006 ikasired    115.154 Bug 5596918 fix for 'SAME' part in carryforward. bnft amt null issue
 *   12-Oct-2006 ikasired    115.154 Bug 5596907 fix for carryforward to use right bnft record
 *   10-nov-2006 ssarkar     115.155 Bug 5653168 - resetting g_interim_flag for any exception in process_interim
 *   18-May-2007 swjain      115.156 Bug 6054988 - In procedure unsuspend_enrollment, call multi_rows_edit only
                                                   if any elections made in the current pil
 *   22-jun-2007 nhunur      115.157 perf changes
 *   24-Aug-2007 gsehgal     115.158 bug 6337803 added global variable g_sspnded_rslt_id to store the pen id of
                                     enrollment going to suspend at the time of processing the interim
 *   12-Nov-2007 sshetty     115.156.11516.2 Bug 6597329 Added per_in_ler id
 *                                           check for c_prv_sspnd to fix
 *                                           the purge issue
 *   22-Feb-2008 rtagarra    115.157         Bug 6840074
 *   23-Jun-2008 sallumwa    115.161  Bug 7195598 - Fixed cursor c_cur_bnft to fetch benefit records
 *                                                  even if order number is 1,which inturn is used to
 *                                                  calculate interim rates.
 *   18-sep-2008 sallumwa    115.162  Bug 7262435 : Fixed cursor c_cur_bnft to fetch correct benefit
 *                                                  records which inturn is used to
 *                                                  calculate interim rates for EVAT and falt range cases.
 *   06-Jan-2009 sallumwa    115.163  Bug 7557403 : Modified procedure unsuspend_enrollment to set the
 *					            global cvg and rate start date variables if unsuspend
 *						    enrollment code is "FDMCFC".
 *   10-Mar-2009 sallumwa    115.164  Bug 8244575 : Implemented the fix done in 7557403 for the unsuspend
 *						    enrollments codes like 'FD%'.
 *   21-Apr-2009 sallumwa    115.165  Bug 8420062 : Implemented the fix done in 7557403 when multiple
 *						    rates are attched to the same comp object.
 *   13-May-2009 sallumwa    115.166  Bug 8244648 : When the interim Code is Current Same Plan,%;New Defaults
 *						    and the system doesn't find any default within the same plan,
 *					            then continue default search within the plan type.
 *   25-May-2009 velvanop    115.167  Bug 7426609 : Reinstate the interim on backing out and
 *						    reprocessing the LE
 *   01-Jul-2009 velvanop    115.168  Bug 8488400 : Whenever certification is received on a data prior to Suspended coverage
 *                                                  start date and the life event is backed out reprocessed on a date on or after
 *                                                  Coverage start date the coverage start date on the unsuspended enrollment
 *                                                  get changed to certification received date.
 *   22-Jul-2009 velvanop    115.169  Bug 8528791 : When backing out the current life event, the system restores the suspended
 *                                                  enrollment tied to previous le, but the interim is not created.
 *                                                  Previous LifeEvent does not have any electability. Modified cursors
 *                                                  'c_next_lower_pl_typ_epe' and 'c_next_lower_pl_epe' to pick the interim
 *                                                  even though there is no electability for the LE
 =========================================================================================*/
g_package varchar2(80) := 'ben_sspndd_enrollment';
--
-- ==========================================================================
--                           << Rpt_error >>
-- ==========================================================================
--
procedure rpt_error(p_proc        varchar2
                   ,p_last_action varchar2
                   ) is
Begin
  hr_utility.set_location('>> Fail at ' || p_proc, 999);
  hr_utility.set_location('>>    '      || p_last_action, 999);
End rpt_error;
--
-- ==========================================================================
--                           << get_cvg_strt_dt >>
-- ==========================================================================
--
Function get_cvg_strt_dt(p_effective_date        in Date
                        ,p_prtt_enrt_rslt_id     in Number
                        ,p_calc_cvg_strt_dt_cd   in varchar2
                        ) return date is
  l_proc     varchar2(80) := g_package || '.get_cvg_strt_dt';
Begin
  hr_utility.set_location('Entering ' || l_proc, 05);
  hr_utility.set_location('Leaving  ' || l_proc, 10);
End get_cvg_strt_dt;
--
-- ==========================================================================
--                           << Get_cvg_end_dt >>
-- ==========================================================================
--
Function get_cvg_end_dt (p_effective_date        in Date
                        ,p_prtt_enrt_rslt_id     in Number
                        ,p_calc_cvg_end_dt_cd    in varchar2
                        ) return date is
  l_proc     varchar2(80) := g_package || '.get_cvg_end_dt';
Begin
  hr_utility.set_location('Entering ' || l_proc, 05);
  hr_utility.set_location('Leaving  ' || l_proc, 10);
End get_cvg_end_dt;
--
-- ----------------------------------------------------------------------------
-- |---------------------< Get_DFLT_TO_ASN_PNDG_CTFN_CD >---------------------|
-- ----------------------------------------------------------------------------
/******* added organization_id ,pgm_id,pl_id,pl_typ_id,opt_id,ler_id --shdas ***********/

Function get_dflt_to_asn_pndg_ctfn_cd
             (p_dflt_to_asn_pndg_ctfn_rl in number
             ,p_person_id                in number
             ,p_per_in_ler_id            in number
             ,p_assignment_id            in number
             ,p_organization_id          in number
             ,p_business_group_id        in number
             ,p_pgm_id                   in number
             ,p_pl_id                    in number
             ,p_pl_typ_id                in number
             ,p_opt_id                   in number
             ,p_ler_id                   in number
             ,p_elig_per_elctbl_chc_id   in number
             ,p_jurisdiction_code        in varchar2
             ,p_effective_date           in date
             ,p_prtt_enrt_rslt_id        in number
             ,p_interim_epe_id           out nocopy number
          --    ,p_interim_enb_id           out nocopy number
             ,p_interim_bnft_amt         out nocopy number
             ) return varchar2 is
  --
  -- ** Declaration Section
  l_proc       varchar2(80) := g_package||'.get_dflt_to_asn';
  l_outputs    ff_exec.outputs_t;
  l_return     varchar2(30);
  l_step       integer;
  l_interim_epe_id number;
  l_interim_enb_id number;
  l_interim_bnft_amt number;
  --
begin
  hr_utility.set_location ('Entering '||l_proc,10);
  --
  -- Call formula initialise routine
  --
  l_step := 20;

/******* added organization_id,business_group_id ,pgm_id,pl_id,pl_typ_id,opt_id,ler_id --shdas ***********/
  hr_utility.set_location ('Organization_id '||to_char(p_organization_id),10);
  hr_utility.set_location ('assignment_id '||to_char(p_assignment_id),15);
  hr_utility.set_location ('Business_group_id '||to_char(p_business_group_id),20);
  hr_utility.set_location ('pgm_id '||to_char(p_pgm_id),30);
  hr_utility.set_location ('pl_id '||to_char(p_pl_id),40);
  hr_utility.set_location ('pl_typ_id '||to_char(p_pl_typ_id),50);
  hr_utility.set_location ('opt_id '||to_char(p_opt_id),60);
  hr_utility.set_location ('ler_id '||to_char(p_ler_id),70);
  hr_utility.set_location ('prtt_enrt_rslt_id '||to_char(p_prtt_enrt_rslt_id),70);

  l_outputs := benutils.formula
                 (p_formula_id       => p_dflt_to_asn_pndg_ctfn_rl
                 ,p_effective_date   => p_effective_date
                 ,p_assignment_id    => p_assignment_id
                 ,p_organization_id  => p_organization_id
                 ,p_business_group_id  => p_business_group_id
                 ,p_pgm_id  => p_pgm_id
                 ,p_pl_id  => p_pl_id
                 ,p_pl_typ_id  => p_pl_typ_id
                 ,p_opt_id  => p_opt_id
                 ,p_ler_id  => p_ler_id
                 ,p_elig_per_elctbl_chc_id  => p_elig_per_elctbl_chc_id
                 ,p_jurisdiction_code => p_jurisdiction_code
                 ,p_param1            => 'BEN_PEN_IV_PRTT_ENRT_RSLT_ID'
                 ,p_param1_value      => to_char(p_prtt_enrt_rslt_id)
                 ,p_param2            => 'BEN_PER_IV_PERSON_ID'
                 ,p_param2_value      => to_char(p_person_id)
                 ,p_param3            => 'BEN_PIL_IV_PER_IN_LER_ID'
                 ,p_param3_value      => to_char(p_per_in_ler_id)
                 );
  --
  --
  l_return := l_outputs(l_outputs.last).value;
  --Start Interim Rule Enhancement
  if l_return is NULL then
    --Invalid Rule
    hr_utility.set_location('BEN_94600_NULL_RETURNED',80);
    fnd_message.set_name('BEN','BEN_94600_NULL_RETURNED');
    fnd_message.set_token('PERSON_ID' , to_char(p_person_id));
    fnd_message.set_token('EPE_ID',to_char(p_elig_per_elctbl_chc_id));
    fnd_message.raise_error;
    --
  elsif instr('0123456789', substr(l_return,1,1) ) >  0 THEN
    --
    l_return := NULL;
    --
    for l_count in l_outputs.first..l_outputs.last loop
      --
      begin
        --
        if l_count = l_outputs.last  then
           --
           l_interim_epe_id := l_outputs(l_count).value;
           --
        elsif l_count = l_outputs.last - 1  then
           --
           l_interim_bnft_amt := l_outputs(l_count).value;
           --
        end if;
      end;
      --
    end loop;
  end if;
  --
  p_interim_epe_id := l_interim_epe_id ;
  -- p_interim_enb_id := l_interim_enb_id ;
  p_interim_bnft_amt := l_interim_bnft_amt;
  -- End Interim Rule enhancement
  hr_utility.set_location('p_interim_epe_id '||p_interim_epe_id,111);
  -- hr_utility.set_location('p_interim_enb_id '||p_interim_enb_id,111);
  hr_utility.set_location('p_interim_bnft_amt '||p_interim_bnft_amt,111);
  hr_utility.set_location('l_return '||l_return,111);
  hr_utility.set_location ('Leaving '||l_proc,50);
  return l_return;
Exception
  When others then
     hr_utility.set_location ('Fail in '||l_proc|| ' step in '||
                              to_char(l_step),999);
     fnd_message.raise_error;
End get_dflt_to_asn_pndg_ctfn_cd;
--
--
-- ==========================================================================
--                         << validate_interim_rule >>
-- ==========================================================================
--
procedure validate_interim_rule (
        p_prtt_enrt_rslt_id              in     number,
        p_elig_per_elctbl_chc_id         in     number,
        p_enrt_bnft_id                   in     number,
        p_business_group_id              in     number,
        p_person_id                      in     number,
        p_ler_id                         in     number,
        p_per_in_ler_id                  in     number,
        p_pl_id                          in     number,
        p_pgm_id                         in     number,
        p_pl_typ_id                      in     number,
        p_oipl_id                        in     number,
        p_pl_ordr_num                    in     number,
        p_oipl_ordr_num                  in     number,
        p_plip_ordr_num                  in     number,
        p_bnft_ordr_num                  in     number,
        p_interim_elctbl_chc_id          in     number,
        p_interim_enrt_bnft_id           out    nocopy number,
        p_interim_bnft_amt               in     number
)
AS
   --
   l_proc                      varchar2(80) := g_package || '.validate_interim_rule';
   --
   l_interim_enrt_bnft_id NUMBER := p_interim_enrt_bnft_id;
   l_interim_bnft_amt NUMBER := p_interim_bnft_amt;
   --
   cursor c_epe(v_elig_per_elctbl_chc_id number) is
    select epe.*
     from ben_elig_per_elctbl_chc epe, ben_per_in_ler pil
    where epe.elig_per_elctbl_chc_id = v_elig_per_elctbl_chc_id
      and epe.per_in_ler_id = pil.per_in_ler_id(+)               /* Bug 5225780 */
      and (pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT') or
           pil.per_in_ler_stat_cd is null);
   --
   cursor c_epe_from_enb(v_enrt_bnft_id number) is
    select enb.*
     from ben_enrt_bnft enb
    where enb.enrt_bnft_id = v_enrt_bnft_id ;
   --
   l_epe_from_enb c_epe_from_enb%ROWTYPE;
   --
   cursor c_enb_rng(v_epe_id number,
          --          v_enrt_bnft_id number,
                    v_bnft_amt number) is
    select enb.*
      from ben_enrt_bnft enb
     where -- enb.enrt_bnft_id = v_enrt_bnft_id
           enb.val = p_interim_bnft_amt
       and enb.elig_per_elctbl_chc_id = v_epe_id ;
   --
   l_dummy varchar2(30);
   --
   cursor c_enb(v_elig_per_elctbl_chc_id number) is
    select enb.*
      from ben_enrt_bnft enb
    where enb.elig_per_elctbl_chc_id = v_elig_per_elctbl_chc_id
      and enb.MX_WO_CTFN_FLAG = 'N' ;
   --
   cursor c_enb_entr(v_elig_per_elctbl_chc_id number) is
    select enb.*
      from ben_enrt_bnft enb
    where enb.elig_per_elctbl_chc_id = v_elig_per_elctbl_chc_id
      and enb.MX_WO_CTFN_FLAG = 'Y' ;
   --
   /*
   --
   cursor c_ecc(v_elig_per_elctbl_chc_id number) is
   select ecc.rqd_flag,
         ecc.enrt_ctfn_typ_cd,
         ecc.SUSP_IF_CTFN_NOT_PRVD_FLAG,
         ecc.ctfn_determine_cd
    from ben_elctbl_chc_ctfn ecc
   where ecc.elig_per_elctbl_chc_id = v_elig_per_elctbl_chc_id
     and ecc.enrt_bnft_id is null
     and ecc.business_group_id = p_business_group_id ;
   */
   --
   cursor c_enbcount(v_elig_per_elctbl_chc_id number) is
   select count(*)
     from ben_enrt_bnft
    where elig_per_elctbl_chc_id = v_elig_per_elctbl_chc_id
      and ordr_num >= 0 ;  --This will exclude the records being create for SAME case
                           --which are created with -1
   --
   cursor c_pen(v_prtt_enrt_rslt_id number,
                v_per_in_ler_id number ) is
     select pen.*
     from ben_prtt_enrt_rslt_f pen
    where pen.prtt_enrt_rslt_id = v_prtt_enrt_rslt_id
      and pen.per_in_ler_id = v_per_in_ler_id
      and pen.prtt_enrt_rslt_stat_cd IS NULL
      and pen.effective_end_date = hr_api.g_eot ;
   --
   l_pen         c_pen%ROWTYPE;
   l_susp_epe    c_epe%ROWTYPE;
   l_interim_epe c_epe%ROWTYPE;
   l_interim_enb c_enb%ROWTYPE;
   l_enb         c_enb%ROWTYPE;
   l_interim_enb_entr c_enb%ROWTYPE;
   l_enb_count   number ;
   --
BEGIN
   --
   hr_utility.set_location('Entering ' || l_proc, 5);
   --
/* hr_utility.set_location('p_prtt_enrt_rslt_id ----*** ' || p_prtt_enrt_rslt_id, 5);
hr_utility.set_location('p_elig_per_elctbl_chc_id ' || p_elig_per_elctbl_chc_id, 5);
hr_utility.set_location('p_enrt_bnft_id ' || p_enrt_bnft_id, 5);
hr_utility.set_location('p_interim_elctbl_chc_id ' || p_interim_elctbl_chc_id, 5);
hr_utility.set_location('p_oipl_id ' || p_oipl_id, 5);
hr_utility.set_location('p_pl_id ' || p_pl_id, 5);
hr_utility.set_location('p_interim_bnft_amt ---*** ' || p_interim_bnft_amt, 5);
*/
--
   open c_epe(p_elig_per_elctbl_chc_id);
     fetch c_epe into l_susp_epe ;
   close c_epe;
   --
   open c_epe(p_interim_elctbl_chc_id);
     fetch c_epe into l_interim_epe ;
     /* Bug 5225780 */
     if c_epe%NOTFOUND or l_interim_epe.per_in_ler_id <> l_susp_epe.per_in_ler_id then
        hr_utility.set_location('BEN_94628', 80);
        fnd_message.set_name('BEN','BEN_94628_EPE_NOTIN_PIL');
        fnd_message.set_token('PROC',l_proc);
        fnd_message.set_token('PERSON_ID' , to_char(p_person_id));
        fnd_message.set_token('INT_EPE_ID',to_char(p_interim_elctbl_chc_id));
        fnd_message.set_token('SSP_EPE_ID',to_char(p_elig_per_elctbl_chc_id));
        fnd_message.raise_error;
     end if;
     /* End Bug 5225780 */
   close c_epe;
   --
   --a. Validate EPE to be in the same plan type of suspending enrollment.
   --
   IF l_interim_epe.ptip_id <> l_susp_epe.ptip_id THEN
     --
     hr_utility.set_location('BEN_94601', 80);
     fnd_message.set_name('BEN','BEN_94601_EPE_NOTIN_PTIP');
     fnd_message.set_token('PROC',l_proc);
     fnd_message.set_token('PERSON_ID' , to_char(p_person_id));
     fnd_message.set_token('INT_EPE_ID',to_char(p_interim_elctbl_chc_id));
     fnd_message.set_token('SSP_EPE_ID',to_char(p_elig_per_elctbl_chc_id));
     fnd_message.raise_error;
     --
   END IF;
   --
   open c_enbcount(p_interim_elctbl_chc_id) ;
     fetch c_enbcount into l_enb_count;
   close c_enbcount;
   --
   IF l_enb_count = 0 AND p_interim_bnft_amt IS NULL THEN
     --
     IF p_elig_per_elctbl_chc_id = p_interim_elctbl_chc_id THEN
       --
       hr_utility.set_location('BEN_94602_SM_AS_SSPND', 80);
       fnd_message.set_name('BEN','BEN_94602_SM_AS_SSPND');
       fnd_message.set_token('PROC',l_proc);
       fnd_message.set_token('PERSON_ID' , to_char(p_person_id));
       fnd_message.set_token('INT_EPE_ID',to_char(p_interim_elctbl_chc_id));
       fnd_message.set_token('SSP_EPE_ID',to_char(p_elig_per_elctbl_chc_id));
       fnd_message.raise_error;
       --
     END IF;
     --
     return;
   ELSIF l_enb_count = 0 AND p_interim_bnft_amt IS NOT NULL THEN
     --
     hr_utility.set_location('BEN_94603_WHY_ENB_ID', 80);
     fnd_message.set_name('BEN','BEN_94603_WHY_ENB_ID');
     fnd_message.set_token('PROC',l_proc);
     fnd_message.set_token('PERSON_ID' , to_char(p_person_id));
     fnd_message.set_token('INT_EPE_ID',to_char(p_interim_elctbl_chc_id));
     fnd_message.set_token('SSP_EPE_ID',to_char(p_elig_per_elctbl_chc_id));
     fnd_message.raise_error;
     --
   ELSIF l_enb_count = 1 THEN
     --
     open c_enb(p_interim_elctbl_chc_id);
     fetch c_enb into l_interim_enb ;
     close c_enb;
     --
     hr_utility.set_location('l_interim_enb.enrt_bnft_id ' || l_interim_enb.enrt_bnft_id, 5);
     --
     IF p_elig_per_elctbl_chc_id <> p_interim_elctbl_chc_id AND
        p_enrt_bnft_id <> l_interim_enb.enrt_bnft_id
     THEN
         --Make sure the interim amount is less than or equal to the suspended coverage amount
         open c_enb(p_interim_elctbl_chc_id);
         fetch c_enb into l_interim_enb ;
         close c_enb;
         --
         open c_enb(p_elig_per_elctbl_chc_id);
         fetch c_enb into l_enb ;
         close c_enb;
         --
	 IF  nvl(l_interim_enb.val,-1) > nvl(l_enb.val,-1)
	 THEN
           hr_utility.set_location('BEN_94607_MORE_THAN_SSPND', 80);
           fnd_message.set_name('BEN','BEN_94607_MORE_THAN_SSPND');
           fnd_message.set_token('PROC',l_proc);
           fnd_message.set_token('PERSON_ID' , to_char(p_person_id));
           fnd_message.set_token('INT_EPE_ID',to_char(p_interim_elctbl_chc_id));
           fnd_message.set_token('SSP_EPE_ID',to_char(p_elig_per_elctbl_chc_id));
           fnd_message.raise_error;
	  END IF;
           --
     END IF;
     --
     --Make sure Suspended and interim enb are same then throw the error.
     IF p_elig_per_elctbl_chc_id = p_interim_elctbl_chc_id AND
        p_enrt_bnft_id = l_interim_enb.enrt_bnft_id THEN
       --
       hr_utility.set_location('BEN_94602_SM_AS_SSPND', 80);
       fnd_message.set_name('BEN','BEN_94602_SM_AS_SSPND');
       fnd_message.set_token('PROC',l_proc);
       fnd_message.set_token('PERSON_ID' , to_char(p_person_id));
       fnd_message.set_token('INT_EPE_ID',to_char(p_interim_elctbl_chc_id));
       fnd_message.set_token('SSP_EPE_ID',to_char(p_elig_per_elctbl_chc_id));
       fnd_message.raise_error;
       --
     END IF;
     --
     p_interim_enrt_bnft_id :=  l_interim_enb.enrt_bnft_id;
     -- p_interim_bnft_amt := l_interim_enb.val;
     return;
     --
   ELSIF l_enb_count > 1 AND p_interim_bnft_amt IS NULL  THEN
     --
     hr_utility.set_location('BEN_94604_NO_ENB_ID', 80);
     fnd_message.set_name('BEN','BEN_94604_NO_ENB_ID');
     fnd_message.set_token('PROC',l_proc);
     fnd_message.set_token('PERSON_ID' , to_char(p_person_id));
     fnd_message.set_token('INT_EPE_ID',to_char(p_interim_elctbl_chc_id));
     fnd_message.set_token('SSP_EPE_ID',to_char(p_elig_per_elctbl_chc_id));
     fnd_message.raise_error;
     --
   ELSIF l_enb_count > 1 THEN
     --
         --Make sure the interim amount is less than or equal to the suspended coverage amount
         open c_pen(p_prtt_enrt_rslt_id,p_per_in_ler_id ) ;
         fetch c_pen into l_pen;
         close c_pen;
         --
         IF p_interim_bnft_amt > l_pen.bnft_amt THEN
           --
           hr_utility.set_location('BEN_94607_MORE_THAN_SSPND', 80);
           fnd_message.set_name('BEN','BEN_94607_MORE_THAN_SSPND');
           fnd_message.set_token('PROC',l_proc);
           fnd_message.set_token('PERSON_ID' , to_char(p_person_id));
           fnd_message.set_token('INT_EPE_ID',to_char(p_interim_elctbl_chc_id));
           fnd_message.set_token('SSP_EPE_ID',to_char(p_elig_per_elctbl_chc_id));
           fnd_message.raise_error;
           --
         END IF;
         --
         --Make sure enb_id returned by the rule belongs to the same epe
         open c_enb(p_interim_elctbl_chc_id);
         fetch c_enb into l_interim_enb ;
         close c_enb;
         --
         --
         IF l_interim_enb.cvg_mlt_cd like '%RNG%' THEN
         --
           open c_enb_rng(p_interim_elctbl_chc_id,p_interim_bnft_amt) ;
           fetch c_enb_rng into l_interim_enb;
           IF c_enb_rng%NOTFOUND THEN
             --
             close c_enb_rng;
             hr_utility.set_location('BEN_94606_INVALID_ENB_RNG', 80);
             fnd_message.set_name('BEN','BEN_94606_INVALID_ENB_RNG');
             fnd_message.set_token('PROC',l_proc);
             fnd_message.set_token('PERSON_ID' , to_char(p_person_id));
             fnd_message.set_token('INT_EPE_ID',to_char(p_interim_elctbl_chc_id));
             fnd_message.set_token('SSP_EPE_ID',to_char(p_elig_per_elctbl_chc_id));
             fnd_message.raise_error;
             --
           END IF;
           close c_enb_rng;
           --
           IF l_interim_enb.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id AND
             l_interim_enb.enrt_bnft_id = p_enrt_bnft_id THEN
            --
            hr_utility.set_location('BEN_99602_SM_AS_SSPND', 80);
            fnd_message.set_name('BEN','BEN_99602_SM_AS_SSPND');
            fnd_message.set_token('PROC',l_proc);
            fnd_message.set_token('PERSON_ID' , to_char(p_person_id));
            fnd_message.set_token('INT_EPE_ID',to_char(p_interim_elctbl_chc_id));
            fnd_message.set_token('SSP_EPE_ID',to_char(p_elig_per_elctbl_chc_id));
            fnd_message.raise_error;
            --
           END IF;
           --
           --
           l_interim_enrt_bnft_id := l_interim_enb.enrt_bnft_id ;
           --
         ELSE
           -- Here we need to get only flat fixed enter value at enrollment case.
           open c_enb_entr(p_interim_elctbl_chc_id);
           fetch c_enb_entr into l_interim_enb_entr ;
           close c_enb_entr;
           --
           l_interim_enrt_bnft_id := l_interim_enb_entr.enrt_bnft_id ;
           --
	   IF p_interim_bnft_amt = l_pen.bnft_amt THEN
           --
           -- hr_utility.set_location('BEN_99602_SM_AS_SSPND', 80);
           -- fnd_message.set_name('BEN','BEN_99602_SM_AS_SSPND');
	   -- message changed for Bug 5148514
	   hr_utility.set_location('BEN_94624_AMT_SM_SSPND', 80);
           fnd_message.set_name('BEN','BEN_94624_AMT_SM_SSPND');
           fnd_message.set_token('PROC',l_proc);
           fnd_message.set_token('PERSON_ID' , to_char(p_person_id));
           fnd_message.set_token('INT_EPE_ID',to_char(p_interim_elctbl_chc_id));
           fnd_message.set_token('SSP_EPE_ID',to_char(p_elig_per_elctbl_chc_id));
           fnd_message.raise_error;
           --
           END IF;
         --
         END IF;
       --
     --
   END IF;
   --
   p_interim_enrt_bnft_id := l_interim_enrt_bnft_id;
   -- p_interim_bnft_amt     := l_interim_bnft_amt;
   --
   hr_utility.set_location('Leaving ' || l_proc, 10);
   --
EXCEPTION
   --
   WHEN OTHERS THEN
     --
     hr_utility.set_location('EXC : ' || substr(SQLERRM, 1, 50), 9999);
     raise;
     --
   --
END validate_interim_rule;
--
--
-- ==========================================================================
--                         << Determine_interim >>
-- ==========================================================================
--
Procedure Determine_interim
            (p_elig_per_elctbl_chc_id  in     number
            ,p_prtt_enrt_rslt_id       in     number
            ,p_enrt_bnft_id            in     number     /*ENH*/
            ,p_interim_elctbl_chc_id   in out nocopy number
            ,p_interim_enrt_bnft_id    out nocopy    number
            ,p_interim_enrt_rslt_id    out nocopy    number
            ,p_person_id               in     number
            ,p_ler_id                  in     number
            ,p_per_in_ler_id           in     number
            ,p_pl_id                   in     number
            ,p_pgm_id                  in     number       /* Bug 4256836 */
            ,p_pl_typ_id               in     number
            ,p_oipl_id                 in     number
            ,p_pl_ordr_num             in     number
            ,p_oipl_ordr_num           in     number
            ,p_plip_ordr_num           in     number      /*ENH*/
            ,p_bnft_ordr_num           in     number      /*ENH*/
            ,p_business_group_id       in     number
            ,p_effective_date          in     date
            ,p_interim_bnft_amt        out nocopy    number
            ,p_bnft_or_option_rstrctn_cd out nocopy  varchar2 -- Bug 1886183
            ) is
  l_proc                      varchar2(80) := g_package ||
                                 '.Determine_interim';
  l_last_place                varchar2(132);
  l_interim_enrt_bnft_id      number;
  l_DFLT_TO_ASN_PNDG_CTFN_CD  ben_pl_f.DFLT_TO_ASN_PNDG_CTFN_CD%type := NULL ;
  l_DFLT_TO_ASN_PNDG_CTFN_RL  ben_pl_f.DFLT_TO_ASN_PNDG_CTFN_RL%type := NULL ;
  l_bnft_or_option_rstrctn_cd ben_pl_f.BNFT_OR_OPTION_RSTRCTN_CD%type := NULL;
  l_assignment_id             per_all_assignments_f.assignment_id%type;

  /********************* l_organization_id added by shdas **********/

  l_organization_id           per_all_assignments_f.organization_id%type;
  l_interim_action            varchar2(30):='NT';
  l_bnft_ordr_num             number;
  l_enrt_pl_id                number         := null;
  l_enrt_chc_id               number         := null;
  l_enrt_pl_typ_id            number         := null;
  --RCHASE Bug#5353 added l_prtt_enrt_rslt_id for interim assignment to current
  l_prtt_enrt_rslt_id         number         := null;
  l_intm_dfn_level            varchar2(30)   := null;
  l_jurisdiction_code     varchar2(30);
  --
  -- for nocopy changes
    l_interim_elctbl_chc_id number := p_interim_elctbl_chc_id;

  -- Cursor declaration
  --

  Cursor c_state is
  select region_2
  from hr_locations_all loc,per_all_assignments_f asg
  where loc.location_id = asg.location_id
  and asg.person_id = p_person_id
  and asg.assignment_type <> 'C'
  and asg.primary_flag = 'Y'
       and p_effective_date between
             asg.effective_start_date and asg.effective_end_date
       and asg.business_group_id=p_business_group_id;

l_state c_state%rowtype;

  Cursor c_epe is
         select epe.business_group_id,
                epe.pgm_id,
		epe.pl_id,
                epe.pl_typ_id,
                epe.oipl_id,
                pil.ler_id
         from ben_elig_per_elctbl_chc epe,ben_per_in_ler pil
	 where epe.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id
         and pil.per_in_ler_id = epe.per_in_ler_id;

  l_epe c_epe%rowtype;

  Cursor c1(l_get_lf_evt_ocrd_dt date) is
    select 1 order_no
          ,DFLT_TO_ASN_PNDG_CTFN_CD
          ,DFLT_TO_ASN_PNDG_CTFN_RL
          ,null BNFT_OR_OPTION_RSTRCTN_CD
      From ben_ler_bnft_rstrn_f
     Where pl_id = p_pl_id
       and ler_id = p_ler_id
       and l_get_lf_evt_ocrd_dt between    --Bug#5402317
             effective_start_date and effective_end_date
       and business_group_id=p_business_group_id
       and DFLT_TO_ASN_PNDG_CTFN_CD is not NULL
  Union
    select 2 order_no
          ,plip.DFLT_TO_ASN_PNDG_CTFN_CD
          ,plip.DFLT_TO_ASN_PNDG_CTFN_RL
          ,plip.BNFT_OR_OPTION_RSTRCTN_CD
      From ben_plip_f plip, ben_prtt_enrt_rslt_f pen
     Where pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
       and pen.pgm_id = plip.pgm_id
       and pen.pl_id = plip.pl_id
       and pen.prtt_enrt_rslt_stat_cd is null
       and l_get_lf_evt_ocrd_dt between      --Bug#5402317
             pen.effective_start_date and pen.effective_end_date
       and l_get_lf_evt_ocrd_dt between
             plip.effective_start_date and plip.effective_end_date
       and pen.business_group_id=p_business_group_id
--       and DFLT_TO_ASN_PNDG_CTFN_CD is not NULL
  Union
    select 3 order_no
          ,DFLT_TO_ASN_PNDG_CTFN_CD
          ,DFLT_TO_ASN_PNDG_CTFN_RL
          ,BNFT_OR_OPTION_RSTRCTN_CD
      From ben_pl_f
     Where pl_id = p_pl_id
       and l_get_lf_evt_ocrd_dt between     --Bug#5402317
             effective_start_date and effective_end_date
       and business_group_id=p_business_group_id
--       and DFLT_TO_ASN_PNDG_CTFN_CD is not NULL
     order by 1
          ;

  Cursor c_paf is
    Select assignment_id,organization_id
      From per_all_assignments_f
     Where person_id = p_person_id
      and   assignment_type <> 'C'
       And business_group_id=p_business_group_id
        and p_effective_date between
            effective_start_date and effective_end_date
        and primary_flag = 'Y'
           ;

 Cursor c_opt
  is select oipl.opt_id
  from ben_oipl_f oipl
  where oipl.oipl_id = l_epe.oipl_id
       and p_effective_date between
             oipl.effective_start_date and oipl.effective_end_date
       and oipl.business_group_id=p_business_group_id;

 l_opt c_opt%rowtype;
  /* BUG 3095291 FOLLOWING MESS IS CLEANED UP AND WRITEN A NEW CURSOR
  -- this cursor finds the current enrollment and unions to results (because
  -- we need to know the info even if a choice does not exist.
  -- RCHASE Bug#5353 added prtt_enrt_rslt_id to cursor.  This will be used to set the interim
  -- jcarpent bug 5353 (again) added bnft_id/amt to query
  --
   --ikasire Bug 1886183. This cursor doesnot work if there is a change in the
   --benefit amount in the subsequent life envent due to epe.per_in_ler_id=pil.per_in_ler_id
   --Also the select after the union never returns any rows because of
   -- per.per_in_ler_id <> pinl.per_in_ler_id  condition in it.
   --
  cursor c_current_enrt(v_pl_id number, v_oipl_id number )  is
       select per.pl_id,
              per.pl_typ_id,
              epe.elig_per_elctbl_chc_id,
              -- RCHASE Bug#5353 added
              per.prtt_enrt_rslt_id
       from   ben_prtt_enrt_rslt_f per,
              ben_elig_per_elctbl_chc epe,
              ben_per_in_ler pil
       where  pil.business_group_id=p_business_group_id and
              pil.person_id=p_person_id and
              pil.per_in_ler_stat_cd='STRTD' and
              per.person_id=p_person_id and
              per.business_group_id=p_business_group_id and
              per.sspndd_flag='N' and
              per.prtt_enrt_rslt_stat_cd is null and
              p_effective_date-1 between
                 per.effective_start_date and per.effective_end_date and
              -- RCHASE Bug#5181 check against life event occrd date -1
              -- instead of effective date
--              p_effective_date <= per.enrt_cvg_thru_dt and
              pil.lf_evt_ocrd_dt-1 <= per.enrt_cvg_thru_dt and
--              per.enrt_cvg_strt_dt < p_effective_date and
              per.enrt_cvg_strt_dt <= pil.lf_evt_ocrd_dt-1 and
              -- RCHASE Bug#5181 don't check my per_in_ler
              per.per_in_ler_id <> pil.per_in_ler_id and
              per.pl_typ_id=p_pl_typ_id and
              per.pl_id  = nvl(v_pl_id, per.pl_id) and
              nvl(per.oipl_id,-1) = nvl(v_oipl_id,nvl(per.oipl_id,-1)) and
              epe.prtt_enrt_rslt_id=per.prtt_enrt_rslt_id and
              epe.business_group_id=per.business_group_id
       --       epe.per_in_ler_id=pil.per_in_ler_id   Bug 1886183 This doesnot work for benefit amt changes
  union
      select  per.pl_id,
              per.pl_typ_id,
              to_number(null) elig_per_elctbl_chc_id,
              -- RCHASE Bug#5353
              per.prtt_enrt_rslt_id
      from    ben_prtt_enrt_rslt_f per,
              ben_per_in_ler pinl
       where  per.per_in_ler_id=pinl.per_in_ler_id and -- Bug 2595113
              per.person_id=p_person_id and
              per.business_group_id=p_business_group_id and
              per.sspndd_flag='N' and
              per.prtt_enrt_rslt_stat_cd is null and
              p_effective_date-1 between
                 per.effective_start_date and per.effective_end_date and
              -- RCHASE Bug#5181 check against life event occrd date -1
              -- instead of effective date
--              p_effective_date <= per.enrt_cvg_thru_dt and
--              per.enrt_cvg_strt_dt < p_effective_date and
              pinl.lf_evt_ocrd_dt-1 <= per.enrt_cvg_thru_dt and
              per.enrt_cvg_strt_dt <= pinl.lf_evt_ocrd_dt-1 and
              -- RCHASE Bug#5181 don't check my per_in_ler
              -- per.per_in_ler_id <> pinl.per_in_ler_id and --  Bug 2595113
              per.pl_typ_id=p_pl_typ_id and
              per.pl_id    = nvl(v_pl_id, per.pl_id) and
              nvl(per.oipl_id,-1) = nvl(v_oipl_id,nvl(per.oipl_id,-1)) and
              not exists (
                select null
                from   ben_elig_per_elctbl_chc epe,
                       ben_per_in_ler pil
                where  pil.business_group_id=p_business_group_id and
                       pil.person_id=p_person_id and
                       pil.per_in_ler_stat_cd='STRTD' and
                       epe.prtt_enrt_rslt_id=per.prtt_enrt_rslt_id and
                       epe.business_group_id=per.business_group_id and
                       epe.per_in_ler_id=pil.per_in_ler_id)
      ;
  */
  --
  --BUG 3095291 Cleaned up the above cursor and rewriten.
  --The following cursor is used to determine the current enrollments.
  --Outer joined to epe to get the results of if there were no epe
  --records for the current enrollment.Removed the union and the
  --second select. Also, using pil.lf_evt_ocrd_dt instead of using
  --pil.lf_evt_ocrd_dt - 1 in the where cause to avoid the issue
  --happening in the bug. We are now using the logic similar to the
  --bendenrr to get the current enrollment.
  --
  --
  /*
      Here is the status of the records when this procedure is being called

         LE1                                 LE2

         |------------------------------------|---------------------------------------------

     Case 1: Continuing in the same enrollment
          OldOipl                              OldOipl
          OldPIL                               NewPIL
          OldPEN                               OldPEN
                                               CTD   EOT
                                               EED   EOT

     Case 2: Continuing in the same enrollment save and then change with new option again

          OldOipl                              OldOipl
          OldPIL                               NewPIL
          OldPEN                               OldPEN
                                               CTD   EOT
                                               EED   EOT
              [the data will change once the delete enrollment is called]
                        Ended                  OldOipl
                                               NewPIL
                                               OldPEN
                                               CTD   FILLED
                                               EED   EOT

                        New                    NewOipl
                                               NewPIL
                                               NewPEN
                                               CTD   EOT
                                               EED   EOT
     Case 3: Replace the enrollment with a new Plan Option

          OldOipl                              OldOipl
          OldPIL                               OldPIL [Important]
          OldPEN                               OldPEN
                                               CTD   EOT
                                               EED   EOT
              [the data will change once the delete enrollment is called]
                        Ended                  OldOipl
                                               NewPIL
                                               OldPEN
                                               CTD   FILLED
                                               EED   EOT

                         New                   NewOipl
                                               NewPIL
                                               NewPEN
                                               CTD   EOT
                                               EED   EOT

     Case 4: delete the current enrollment and enroll in a new one later

          OldOipl                              OldOipl
          OldPIL                               NewPIL
          OldPEN                               OldPEN
                                               CTD   FILLED
                                               EED   EOT
              [the data will change once the delete enrollment is called]
                        Ended                  OldOipl
                                               NewPIL
                                               OldPEN
                                               CTD   FILLED
                                               EED   EOT

                         New                   NewOipl
                                               NewPIL
                                               NewPEN
                                               CTD   EOT
                                               EED   EOT


*/
  --BUG 4547332 rewriten sql
  --Check the above cases before changing any logic
  --
  cursor c_current_enrt(v_pl_id number, v_oipl_id number )  is
       select per.pl_id,
              per.pl_typ_id,
              per.prtt_enrt_rslt_id
       from   ben_prtt_enrt_rslt_f per,
              ben_per_in_ler pil
       where  pil.business_group_id      = p_business_group_id and
              pil.person_id              = p_person_id and
              pil.per_in_ler_id          = p_per_in_ler_id and
              per.person_id              = pil.person_id and
              per.business_group_id      = p_business_group_id and
              per.sspndd_flag            = 'N' and
              per.prtt_enrt_rslt_stat_cd is null and
              per.effective_end_date     = hr_api.g_eot and
              per.enrt_cvg_strt_dt      <  per.effective_end_date and
             (
               (  p_per_in_ler_id = per.per_in_ler_id and
                  (  /* Case 4 */
                     per.enrt_cvg_thru_dt <> hr_api.g_eot or
                     ( /* Case 1,2*/
                        ( exists (select 'x' from ben_prtt_enrt_rslt_f pen3
                                  where pen3.prtt_enrt_rslt_id = per.prtt_enrt_rslt_id and
                                        pen3.prtt_enrt_rslt_stat_cd is null and
                                        pen3.sspndd_flag = 'N' and
                                        pen3.effective_end_date <  per.effective_start_date and
                                        pen3.enrt_cvg_thru_dt = hr_api.g_eot and
                                        pen3.per_in_ler_id <> per.per_in_ler_id
                                 )
                        ) and
                        per.enrt_cvg_thru_dt = hr_api.g_eot
                     )
                  )
               )
               or
               (  /* Case 3 */
                   per.enrt_cvg_thru_dt = to_date('31-12-4712','dd-mm-yyyy') and
                   per.per_in_ler_id <> p_per_in_ler_id
               )
             ) and
              per.pl_typ_id              = p_pl_typ_id and
              (( per.pgm_id = p_pgm_id) or
               (p_pgm_id is null)
              ) and    -- BUG 4563223
              ((per.pl_id = v_pl_id) or
               (v_pl_id is null)) and
              ((per.oipl_id = v_oipl_id) or
               (v_oipl_id is null))
       ;
     --
     cursor c_default_epe  is
       select epe.elig_per_elctbl_chc_id,
              enb.enrt_bnft_id
       from   ben_per_in_ler pil,
              ben_elig_per_elctbl_chc epe,
              ben_pl_f pl,
              ben_enrt_bnft enb
       where
              pil.business_group_id=p_business_group_id and
              pil.person_id=p_person_id and
              --pil.per_in_ler_stat_cd='STRTD' and
              pil.per_in_ler_id = p_per_in_ler_id and
              epe.per_in_ler_id=pil.per_in_ler_id and
              epe.pl_typ_id =p_pl_typ_id and
              epe.business_group_id=p_business_group_id and
              epe.elctbl_flag='Y' and
              epe.dflt_flag='Y' and
              nvl(epe.dpnt_dsgn_cd,'O')='O' and
       --       epe.ctfn_rqd_flag='N' and
              epe.pl_id = pl.pl_id and
              ( epe.pgm_id = p_pgm_id or
                p_pgm_id is null         ) and                    /* Bug 4256836 */
              nvl(pl.bnf_dsgn_cd, 'O') = 'O' and
              p_effective_date between
                pl.effective_start_date and pl.effective_end_date and
              enb.elig_per_elctbl_chc_id(+)=epe.elig_per_elctbl_chc_id and
              nvl(enb.dflt_flag,'Y') = 'Y' and
              nvl(enb.ctfn_rqd_flag,'N') ='N' and
              --bug#4186343
              not exists ( select 'Y'
                               from ben_elctbl_chc_ctfn
                               where elig_per_elctbl_chc_id = epe.elig_per_elctbl_chc_id
                               and nvl(enrt_bnft_id,nvl(enb.enrt_bnft_id,-1)) = nvl(enb.enrt_bnft_id,-1)
                               and   SUSP_IF_CTFN_NOT_PRVD_FLAG = 'Y')
        order by epe.plip_ordr_num,epe.oipl_ordr_num
        ;
  -- Option Restrictions at plan level.
  cursor c_default_pl_epe  is
       select epe.elig_per_elctbl_chc_id,
              enb.enrt_bnft_id
       from   ben_per_in_ler pil,
              ben_elig_per_elctbl_chc epe,
              ben_pl_f pl,
              ben_enrt_bnft enb
       where
              pil.business_group_id=p_business_group_id and
              pil.person_id=p_person_id and
              --pil.per_in_ler_stat_cd='STRTD' and
              pil.per_in_ler_id = p_per_in_ler_id and
              epe.per_in_ler_id=pil.per_in_ler_id and
              epe.pl_id =p_pl_id and
              epe.business_group_id=p_business_group_id and
              epe.elctbl_flag='Y' and
              epe.dflt_flag='Y' and
              nvl(epe.dpnt_dsgn_cd,'O')='O' and
         --     epe.ctfn_rqd_flag='N' and
              epe.pl_id = pl.pl_id and
              ( epe.pgm_id = p_pgm_id or
                p_pgm_id is null         ) and                    /* Bug 4256836 */
              nvl(pl.bnf_dsgn_cd, 'O') = 'O' and
              p_effective_date between
                pl.effective_start_date and pl.effective_end_date and
              enb.elig_per_elctbl_chc_id(+)=epe.elig_per_elctbl_chc_id and
              nvl(enb.dflt_flag,'Y') = 'Y' and
              nvl(enb.ctfn_rqd_flag,'N') ='N' and
              --bug#4186343
              not exists ( select 'Y'
                               from ben_elctbl_chc_ctfn
                               where elig_per_elctbl_chc_id = epe.elig_per_elctbl_chc_id
                               and nvl(enrt_bnft_id,nvl(enb.enrt_bnft_id,-1)) = nvl(enb.enrt_bnft_id,-1)
                               and   SUSP_IF_CTFN_NOT_PRVD_FLAG = 'Y')
        order by epe.plip_ordr_num,epe.oipl_ordr_num
        ;
  -- This Benefit restriction still needs to look at the plan type. If the plan or
  -- option having the suspended coverage is not the default one, we need to
  -- get someother default comp object in the plan type. It could be
  -- Plan or Option with No Coverage. This should not be filtered by pl_id or
  -- oipl_id as done in Next Lower and Min in the benefit restrictions cases.
  --
  cursor c_default_bnft_epe  is
       select epe.elig_per_elctbl_chc_id,
              enb.enrt_bnft_id
       from   ben_per_in_ler pil,
              ben_elig_per_elctbl_chc epe,
              ben_pl_f pl,
              ben_enrt_bnft enb
       where
              pil.business_group_id=p_business_group_id and
              pil.person_id=p_person_id and
              --pil.per_in_ler_stat_cd='STRTD' and
              pil.per_in_ler_id = p_per_in_ler_id and
              epe.per_in_ler_id=pil.per_in_ler_id and
              epe.pl_typ_id =p_pl_typ_id and
              epe.business_group_id=p_business_group_id and
              -- epe.elctbl_flag='Y' and
              epe.dflt_flag='Y' and
              nvl(epe.dpnt_dsgn_cd,'O')='O' and
              epe.ctfn_rqd_flag='N' and
              epe.pl_id = pl.pl_id and
              ( epe.pgm_id = p_pgm_id or
                p_pgm_id is null         ) and                    /* Bug 4256836 */
              nvl(pl.bnf_dsgn_cd, 'O') = 'O' and
              p_effective_date between
                pl.effective_start_date and pl.effective_end_date and
              enb.elig_per_elctbl_chc_id(+)=epe.elig_per_elctbl_chc_id and
              ((nvl(enb.dflt_flag,'Y') = 'Y' and
                nvl(enb.ctfn_rqd_flag,'N') ='N')
              or ( nvl(enb.mx_wo_ctfn_flag,'Y') = 'Y' and nvl(enb.ordr_num,0)=0 ) )
              and not exists ( select 'Y'
                               from ben_elctbl_chc_ctfn
                               where elig_per_elctbl_chc_id = epe.elig_per_elctbl_chc_id
                               and nvl(enrt_bnft_id,nvl(enb.enrt_bnft_id,-1)) = nvl(enb.enrt_bnft_id,-1)
                               and   SUSP_IF_CTFN_NOT_PRVD_FLAG = 'Y')
              -- If the default one is enter value at enrollment then ctfn is Y
        order by epe.plip_ordr_num,epe.oipl_ordr_num,nvl(enb.ordr_num,1)
        ;
  -- This Benefit restriction still needs to look at the plan level. If the
  -- option having the suspended coverage is not the default one, we need to
  -- get someother default comp object in the plan. It could be
  -- Option with No Coverage. This should not be filtered by
  -- oipl_id as done in Next Lower and Min in the benefit restrictions cases.
  --
  cursor c_default_bnft_pl_epe  is
       select epe.elig_per_elctbl_chc_id,
              enb.enrt_bnft_id
       from   ben_per_in_ler pil,
              ben_elig_per_elctbl_chc epe,
              ben_pl_f pl,
              ben_enrt_bnft enb
       where
              pil.business_group_id=p_business_group_id and
              pil.person_id=p_person_id and
              --pil.per_in_ler_stat_cd='STRTD' and
              pil.per_in_ler_id = p_per_in_ler_id and
              epe.per_in_ler_id=pil.per_in_ler_id and
              epe.pl_id =p_pl_id and
              epe.business_group_id=p_business_group_id and
              -- epe.elctbl_flag='Y' and
              epe.dflt_flag='Y' and
              nvl(epe.dpnt_dsgn_cd,'O')='O' and
              epe.ctfn_rqd_flag='N' and
              epe.pl_id = pl.pl_id and
              ( epe.pgm_id = p_pgm_id or
                p_pgm_id is null         ) and                    /* Bug 4256836 */
              nvl(pl.bnf_dsgn_cd, 'O') = 'O' and
              p_effective_date between
                pl.effective_start_date and pl.effective_end_date and
              enb.elig_per_elctbl_chc_id (+) = epe.elig_per_elctbl_chc_id and
              ((nvl(enb.dflt_flag,'Y') = 'Y' and nvl(enb.ctfn_rqd_flag,'N') ='N')
              or ( nvl(enb.mx_wo_ctfn_flag,'Y') = 'Y' and nvl(enb.ordr_num,0)=0 ) )
              and not exists ( select 'Y'
                               from ben_elctbl_chc_ctfn
                               where elig_per_elctbl_chc_id = epe.elig_per_elctbl_chc_id
                               and nvl(enrt_bnft_id,nvl(enb.enrt_bnft_id,-1)) = nvl(enb.enrt_bnft_id,-1)
                               and   SUSP_IF_CTFN_NOT_PRVD_FLAG = 'Y')
              -- If the default one is enter value at enrollment then ctfn is Y
        order by epe.oipl_ordr_num,enb.ordr_num
        ;
  -- Within the Same Plan - Option Restrictions case
  -- There must be options in a plan to get the interim.
  -- Removed the comments not to get the same suspended enrollment as interim
  --
  cursor c_min_oipl_epe  is
       select epe.elig_per_elctbl_chc_id, eb.enrt_bnft_id
       from   ben_per_in_ler pil,
              ben_elig_per_elctbl_chc epe,
              ben_pl_f pl,
              ben_enrt_bnft eb
       where
              pil.business_group_id=p_business_group_id and
              pil.person_id=p_person_id and
              --pil.per_in_ler_stat_cd='STRTD' and
              pil.per_in_ler_id = p_per_in_ler_id and
              epe.per_in_ler_id=pil.per_in_ler_id and
              epe.pl_id =p_pl_id and
              epe.elctbl_flag='Y' and
              epe.business_group_id=p_business_group_id and
              nvl(epe.dpnt_dsgn_cd,'O')='O' and
              -- epe.ctfn_rqd_flag='N' and
              epe.pl_id = pl.pl_id and
              ( epe.pgm_id = p_pgm_id or
                p_pgm_id is null         ) and                    /* Bug 4256836 */
              nvl(pl.bnf_dsgn_cd, 'O') = 'O' and
              epe.elig_per_elctbl_chc_id = eb.elig_per_elctbl_chc_id(+) and
              nvl(eb.ctfn_rqd_flag,'N') = 'N' and
              nvl(eb.ordr_num,1) > 0 and
              p_effective_date between
                pl.effective_start_date and pl.effective_end_date and
              epe.oipl_ordr_num is not null and
              epe.oipl_ordr_num< p_oipl_ordr_num
              and not exists ( select 'Y'
                               from ben_elctbl_chc_ctfn
                               where elig_per_elctbl_chc_id = epe.elig_per_elctbl_chc_id
                               and nvl(enrt_bnft_id,nvl(eb.enrt_bnft_id,-1)) = nvl(eb.enrt_bnft_id,-1)
                               and   SUSP_IF_CTFN_NOT_PRVD_FLAG = 'Y')
       order by epe.oipl_ordr_num ;
       --
       -- Added more logic to handle the case - if options exist for the min plan
       -- we need to get the minimum option of the plan
  cursor c_min_pl_epe  is
       select epe.elig_per_elctbl_chc_id,
              enb.enrt_bnft_id
       from   ben_per_in_ler pil,
              ben_elig_per_elctbl_chc epe,
              ben_enrt_bnft enb,
              ben_pl_f pl
       where pil.business_group_id=p_business_group_id and
              pil.person_id=p_person_id and
              --pil.per_in_ler_stat_cd='STRTD' and
              pil.per_in_ler_id = p_per_in_ler_id and
              epe.per_in_ler_id=pil.per_in_ler_id and
              epe.pl_typ_id =p_pl_typ_id and
              -- epe.elctbl_flag='Y' and
              epe.business_group_id=p_business_group_id and
              nvl(epe.dpnt_dsgn_cd,'O')='O' and
              epe.pl_id = pl.pl_id and
              ( epe.pgm_id = p_pgm_id or
                p_pgm_id is null         ) and                    /* Bug 4256836 */
              nvl(pl.bnf_dsgn_cd, 'O') = 'O' and
              p_effective_date between
                pl.effective_start_date and pl.effective_end_date and
              epe.ctfn_rqd_flag='N' and
              epe.elig_per_elctbl_chc_id = enb.elig_per_elctbl_chc_id (+) and
              nvl(enb.ctfn_rqd_flag,'N') = 'N' and
              nvl(enb.ordr_num,1) > 0 and
              epe.plip_ordr_num is not null and
              epe.plip_ordr_num<= p_plip_ordr_num
              and not exists ( select 'Y'
                               from ben_elctbl_chc_ctfn
                               where elig_per_elctbl_chc_id = epe.elig_per_elctbl_chc_id
                               and nvl(enrt_bnft_id,nvl(enb.enrt_bnft_id,-1)) = nvl(enb.enrt_bnft_id,-1)
                               and   SUSP_IF_CTFN_NOT_PRVD_FLAG = 'Y')
       order by epe.plip_ordr_num,epe.oipl_ordr_num ;
  -- Get the Next Lower Option of the Plan
  cursor c_next_lower_pl_epe  is
       select epe.elig_per_elctbl_chc_id,
                eb.enrt_bnft_id
       from   ben_per_in_ler pil,
              ben_elig_per_elctbl_chc epe,
              ben_pl_f pl,
              ben_enrt_bnft eb
       where
              pil.business_group_id=p_business_group_id and
              pil.person_id=p_person_id and
              --pil.per_in_ler_stat_cd='STRTD' and
              pil.per_in_ler_id = p_per_in_ler_id and
              epe.per_in_ler_id=pil.per_in_ler_id and
              epe.pl_id =p_pl_id and
	      /*Bug 8528791 : Added the below condition to pick the interim if the LE has no electability */
              --epe.elctbl_flag='Y' and
	      (epe.elctbl_flag='Y' or ('Y' = (select 'Y' from dual
                                             where not exists
                                             (select 'Y' from ben_elig_per_elctbl_chc epe1,
                                              ben_per_in_ler pil1
                                              where epe1.pl_id =p_pl_id
                                              and epe1.elctbl_flag='Y'
                                              and epe1.per_in_ler_id=pil1.per_in_ler_id
                                              and pil1.per_in_ler_id = p_per_in_ler_id)) and  epe.crntly_enrd_flag='Y' )
                                            ) and
              epe.business_group_id=p_business_group_id and
              nvl(epe.dpnt_dsgn_cd,'O')='O' and
              -- epe.ctfn_rqd_flag='N' and
              epe.pl_id = pl.pl_id and
              ( epe.pgm_id = p_pgm_id or
                p_pgm_id is null         ) and                    /* Bug 4256836 */
              nvl(pl.bnf_dsgn_cd, 'O') = 'O' and
              epe.elig_per_elctbl_chc_id = eb.elig_per_elctbl_chc_id(+) and
              nvl(eb.ctfn_rqd_flag,'N') = 'N' and
              p_effective_date between
                pl.effective_start_date and pl.effective_end_date and
              epe.oipl_ordr_num < p_oipl_ordr_num
              and not exists ( select 'Y'
                               from ben_elctbl_chc_ctfn
                               where elig_per_elctbl_chc_id = epe.elig_per_elctbl_chc_id
                               and nvl(enrt_bnft_id,nvl(eb.enrt_bnft_id,-1)) = nvl(eb.enrt_bnft_id,-1)
                               and   SUSP_IF_CTFN_NOT_PRVD_FLAG = 'Y')
       order by epe.oipl_ordr_num desc
       ;
  --
  -- Get the Next Lower Option in the Plan type. If there are multiple
  -- Plans and Options for the Plans, first find the next lower option of
  -- the present plan and then find the next lower plan and its options so on.
  --
  cursor c_next_lower_pl_typ_epe  is
       select epe.elig_per_elctbl_chc_id,
               eb.enrt_bnft_id
       from   ben_per_in_ler pil,
              ben_elig_per_elctbl_chc epe,
              ben_enrt_bnft eb,
              ben_pl_f pl
       where
              pil.business_group_id=p_business_group_id and
              pil.person_id=p_person_id and
              --pil.per_in_ler_stat_cd='STRTD' and
              pil.per_in_ler_id = p_per_in_ler_id and
              epe.per_in_ler_id=pil.per_in_ler_id and
              epe.pl_typ_id =p_pl_typ_id and
	      /*Bug 8528791 : Added the below condition to pick the interim if the LE has no electability */
              --epe.elctbl_flag='Y' and
	      (epe.elctbl_flag='Y' or ('Y' = (select 'Y' from dual
                                             where not exists
                                             (select 'Y' from ben_elig_per_elctbl_chc epe1,
                                              ben_per_in_ler pil1
                                              where epe1.pl_typ_id =p_pl_typ_id
                                              and epe1.elctbl_flag='Y'
                                              and epe1.per_in_ler_id=pil1.per_in_ler_id
                                              and pil1.per_in_ler_id = p_per_in_ler_id)) and  epe.crntly_enrd_flag='Y' )
                                            ) and
              epe.business_group_id=p_business_group_id and
              nvl(epe.dpnt_dsgn_cd,'O')='O' and
              epe.pl_id = pl.pl_id and
              ( epe.pgm_id = p_pgm_id or
                p_pgm_id is null         ) and                    /* Bug 4256836 */
              nvl(pl.bnf_dsgn_cd, 'O') = 'O' and
              p_effective_date between
                pl.effective_start_date and pl.effective_end_date and
              -- epe.ctfn_rqd_flag='N' and
              epe.elig_per_elctbl_chc_id = eb.elig_per_elctbl_chc_id (+) and
              nvl(eb.ctfn_rqd_flag,'N') = 'N' and -- Bug 2677315 changed the (+) to nvl
              (epe.plip_ordr_num <= p_plip_ordr_num and
                (epe.plip_ordr_num <> p_plip_ordr_num or
                 (epe.oipl_ordr_num is null or epe.oipl_ordr_num < p_oipl_ordr_num ))) -- changed to < from <=
              and not exists ( select 'Y'
                               from ben_elctbl_chc_ctfn
                               where elig_per_elctbl_chc_id = epe.elig_per_elctbl_chc_id
                               and nvl(enrt_bnft_id,nvl(eb.enrt_bnft_id,-1)) = nvl(eb.enrt_bnft_id,-1)
                               and   SUSP_IF_CTFN_NOT_PRVD_FLAG = 'Y')
       order by epe.plip_ordr_num desc, epe.oipl_ordr_num desc
       ;
  -- Modified the cursor to handle the minimun benefit record within the same plan or
  -- Option in Plan.
  --
  cursor c_min_bnft_epe  is
       select epe.elig_per_elctbl_chc_id,
              enb.enrt_bnft_id
       from   ben_per_in_ler pil,
              ben_elig_per_elctbl_chc epe,
              ben_enrt_bnft enb,
              ben_pl_f pl
       where
              pil.business_group_id=p_business_group_id and
              pil.person_id=p_person_id and
              --pil.per_in_ler_stat_cd='STRTD' and
              pil.per_in_ler_id = p_per_in_ler_id and
              epe.per_in_ler_id=pil.per_in_ler_id and
              epe.pl_id =p_pl_id and
              ( epe.pgm_id = p_pgm_id or
                p_pgm_id is null         ) and                    /* Bug 4256836 */
              nvl(epe.oipl_id,-1)= nvl( p_oipl_id,-1) and
              epe.elctbl_flag='Y' and
              epe.business_group_id=p_business_group_id and
              nvl(epe.dpnt_dsgn_cd,'O')='O' and
              -- epe.ctfn_rqd_flag='N' and
              epe.pl_id = pl.pl_id and
              nvl(pl.bnf_dsgn_cd, 'O') = 'O' and
              p_effective_date between
                pl.effective_start_date and pl.effective_end_date and
              enb.elig_per_elctbl_chc_id=epe.elig_per_elctbl_chc_id and
              enb.business_group_id=p_business_group_id and
              enb.ctfn_rqd_flag = 'N' and
              enb.ordr_num < p_bnft_ordr_num
              and not exists ( select 'Y'
                               from ben_elctbl_chc_ctfn
                               where elig_per_elctbl_chc_id = epe.elig_per_elctbl_chc_id
                               and   SUSP_IF_CTFN_NOT_PRVD_FLAG = 'Y'
                               and   enrt_bnft_id = enb.enrt_bnft_id )  --BUG 5158595
       order by enb.ordr_num
       ;
  --
  -- This a Benefit Restrictions Case. This needs to get the Next Lower Coverage for
  -- the same comp object. This is not for going to a different option. We can use one
  -- same cursor for Current same Plan and Current Same Plan type cases.
  --
  cursor c_next_lower_bnft_pl_epe  is
       select epe.elig_per_elctbl_chc_id,
              eb.enrt_bnft_id
       from   ben_per_in_ler pil,
              ben_elig_per_elctbl_chc epe,
              ben_enrt_bnft eb,
              ben_pl_f pl
       where
              pil.business_group_id=p_business_group_id and
              pil.person_id=p_person_id and
              --pil.per_in_ler_stat_cd='STRTD' and
              pil.per_in_ler_id = p_per_in_ler_id and
              epe.per_in_ler_id=pil.per_in_ler_id and
              epe.elctbl_flag='Y' and
              epe.pl_id =p_pl_id and
              ( epe.pgm_id = p_pgm_id or
                p_pgm_id is null         ) and                    /* Bug 4256836 */
              nvl(epe.oipl_id,-1) = nvl(p_oipl_id,-1) and
              epe.business_group_id=p_business_group_id and
              nvl(epe.dpnt_dsgn_cd,'O')='O' and
              -- epe.ctfn_rqd_flag='N' and
              eb.ordr_num < p_bnft_ordr_num and
              eb.ordr_num > 0 and
              epe.pl_id = pl.pl_id and
              nvl(pl.bnf_dsgn_cd, 'O') = 'O' and
              p_effective_date between
                pl.effective_start_date and pl.effective_end_date and
              eb.elig_per_elctbl_chc_id=epe.elig_per_elctbl_chc_id and
              eb.business_group_id=p_business_group_id and
              eb.ctfn_rqd_flag='N'
              and not exists ( select 'Y'
                               from ben_elctbl_chc_ctfn
                               where elig_per_elctbl_chc_id = epe.elig_per_elctbl_chc_id
                               and   enrt_bnft_id = eb.enrt_bnft_id
                               and   SUSP_IF_CTFN_NOT_PRVD_FLAG = 'Y')
       order by eb.ordr_num desc ;
       --
        -- Since this record is created for this interim purpose with 'N' flag
        -- Bug the nim/max and default values are stored in the maim bnft record
        -- we need to get the enrt_bnft_id from the entr_val_at_enrt_flag = 'N'
        -- and min and default  values from entr_val_at_enrt_flag = 'Y'
        -- condition.
        -- c_bnft SHOULD BE USED ONLY for Coverage Calculation of Flat Amount
        -- with Enter value at enrollment case
 /*ENH
 cursor c_bnft is
        select nvl(enb2.mn_val, 0) min_bnft_amt,
               nvl(enb2.dflt_val, 0) dflt_bnft_amt,  -- Bug 1886183
               enb1.enrt_bnft_id
        from   ben_enrt_bnft enb1,
               ben_enrt_bnft enb2
        where  enb1.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id
        and    enb1.cvg_mlt_cd = 'FLFX'
        and    enb2.elig_per_elctbl_chc_id = enb1.elig_per_elctbl_chc_id
        and    enb2.entr_val_at_enrt_flag = 'Y'
        and    enb1.entr_val_at_enrt_flag = 'N'; -- Bug 1886183 changed to 'N'
        -- Since this record is created for this interim purpose with 'N' flag
        -- Bug the nim/max and default values are stored in the maim bnft record
        -- we need to get the enrt_bnft_id from the entr_val_at_enrt_flag = 'N'
        -- and min and default  values from entr_val_at_enrt_flag = 'Y'
        -- condition.
 */
 -- Now we are handling the bencvrge.pkb to get the right amount into enb1.val
 -- depending on the interim code. So we can take the bnft amount from the
 -- dummy row we create for the coverage enter value at enrollment case.
 -- For details so bencvrge.pkb changes.
 --
 cursor c_bnft is
        select enb1.val bnft_amt,
               enb1.enrt_bnft_id
        from   ben_enrt_bnft enb1,
               ben_enrt_bnft enb2,
               ben_pl_f pl,
               ben_elig_per_elctbl_chc epe  --Bug 3042379 Dont select 'R' cases
                                            --to make it consistent with other
                                            --interim cursors.
        where  epe.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id
        and    nvl(epe.dpnt_dsgn_cd,'O')='O'
        -- and    epe.ctfn_rqd_flag='N'
        and    epe.pl_id = pl.pl_id
        and    p_effective_date between
               pl.effective_start_date and pl.effective_end_date
        and    nvl(pl.bnf_dsgn_cd, 'O') ='O'
        and    enb1.elig_per_elctbl_chc_id = epe.elig_per_elctbl_chc_id
        and    enb1.cvg_mlt_cd = 'FLFX'
        and    enb2.elig_per_elctbl_chc_id = enb1.elig_per_elctbl_chc_id
        and    enb2.entr_val_at_enrt_flag = 'Y'
        and    enb1.entr_val_at_enrt_flag = 'N'
        and    not exists ( select 'Y'
                               from ben_elctbl_chc_ctfn
                               where elig_per_elctbl_chc_id = epe.elig_per_elctbl_chc_id
                               and   enrt_bnft_id = enb1.enrt_bnft_id   -- 5381200
                               and   SUSP_IF_CTFN_NOT_PRVD_FLAG = 'Y'  )
        and    enb1.ordr_num = 0 ;
 --
 l_bnft c_bnft%rowtype;
 --
 cursor c_dflt_bnft is
        select enb1.val bnft_amt,
               enb1.enrt_bnft_id
        from   ben_enrt_bnft enb1,
               ben_enrt_bnft enb2,
               ben_pl_f pl,
               ben_elig_per_elctbl_chc epe  --Bug 3042379 Dont select 'R' cases
                                            --to make it consistent with other
                                            --interim cursors.
        where  epe.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id
        and    nvl(epe.dpnt_dsgn_cd,'O')='O'
        -- and    epe.ctfn_rqd_flag='N'
        and    epe.pl_id = pl.pl_id
        and    p_effective_date between
               pl.effective_start_date and pl.effective_end_date
        and    nvl(pl.bnf_dsgn_cd, 'O') ='O'
        and    enb1.elig_per_elctbl_chc_id = epe.elig_per_elctbl_chc_id
        and    enb1.cvg_mlt_cd = 'FLFX'
        and    enb2.elig_per_elctbl_chc_id = enb1.elig_per_elctbl_chc_id
        and    enb2.entr_val_at_enrt_flag = 'Y'
        and    enb1.entr_val_at_enrt_flag = 'N'
        and    enb1.ordr_num = 0
        and    enb2.dflt_flag = 'Y'
        and    not exists ( select 'Y'
                               from ben_elctbl_chc_ctfn
                               where elig_per_elctbl_chc_id = epe.elig_per_elctbl_chc_id
			       and   enrt_bnft_id = enb1.enrt_bnft_id   -- 5381200
                               and   SUSP_IF_CTFN_NOT_PRVD_FLAG = 'Y') ;
 -- RCHASE Bug#5353 add current benefit cursor
 --
 cursor c_cur_bnft(p_elig_per_elctbl_chc_id in number) is
        select enb.val bnft_amt,
        enb.enrt_bnft_id
        from   ben_enrt_bnft enb
        where  enb.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id
        ----Bug : 7195598
        and    enb.ordr_num in (-1,1)
	---Bug 7195598
	---Bug 7262435
	order by enb.ordr_num
	---Bug 7262435
	;
 --
 l_cur_bnft c_cur_bnft%rowtype;
 --
 /*
 cursor c_current_same_epe(c_current_epe_id number) is
        select epe_new.elig_per_elctbl_chc_id
        from   ben_elig_per_elctbl_chc epe_current,
               ben_elig_per_elctbl_chc epe_new,
               ben_per_in_ler pil_new
        where  epe_current.elig_per_elctbl_chc_id = c_current_epe_id
        and    epe_current.pl_id = epe_new.pl_id
        and    nvl(epe_current.oipl_id,-1) = nvl(epe_new.oipl_id,-1)
        and    epe_new.comp_lvl_cd not in ( 'PLANFC' , 'PLANIMP')
        and    epe_new.crntly_enrd_flag = 'Y'
        and    pil_new.per_in_ler_id = epe_new.per_in_ler_id
        and    pil_new.per_in_ler_stat_cd='STRTD' ;
 */
 --
 --The following cursor is to get the present life event
 --electable choice using the current enrollment result
 --ie the enrollment result from the previous life event.
 --
 cursor c_current_same_epe(c_current_pen_id number) is
        select epe_new.elig_per_elctbl_chc_id
        from   ben_prtt_enrt_rslt_f pen_current,
               ben_elig_per_elctbl_chc epe_new,
               ben_per_in_ler pil_new
        where  pen_current.prtt_enrt_rslt_id = c_current_pen_id
        and    pen_current.pl_id = epe_new.pl_id
        and    nvl(pen_current.pgm_id,-1) = nvl(epe_new.pgm_id,-1)
        and    nvl(pen_current.oipl_id,-1) = nvl(epe_new.oipl_id,-1)
        and    epe_new.comp_lvl_cd not in ( 'PLANFC' , 'PLANIMP')
        and    epe_new.crntly_enrd_flag = 'Y'
        and    pil_new.per_in_ler_id = epe_new.per_in_ler_id
        and    pil_new.person_id = p_person_id
        --and    pil_new.per_in_ler_stat_cd='STRTD' ;
        and    pil_new.per_in_ler_id= p_per_in_ler_id
        and    pen_current.prtt_enrt_rslt_stat_cd is null;
 --
 l_use_same_bnft varchar2(1);
 l_currently_enrolled varchar2(30) := 'N' ;
 l_cf_required        varchar2(30) := 'N' ;
 --
 --Cursor to See if we need to carry forward the certifications.
 --Decides if it is a carryforward suspension or not
 --
 /*  Bug 4463267 This does not work as per the changes made in
     election information. Initially, suspended record was getting date track
     updated. Now we are deleting the suspended enrollment and recreating
     new result.

 cursor c_cf_suspended(c_prtt_enrt_rslt_id number,
             c_per_in_ler_id number,
             c_elig_per_elctbl_chc_id number) is
  select currently_susp.prtt_enrt_rslt_id,
         currently_susp.rplcs_sspndd_rslt_id
    from ben_prtt_enrt_rslt_f susp,
         ben_prtt_enrt_rslt_f currently_susp
   where susp.prtt_enrt_rslt_id = c_prtt_enrt_rslt_id
     and susp.per_in_ler_id = c_per_in_ler_id
     -- and susp.sspndd_flag = 'N' --This can be changed once elinf is fixed
     and susp.effective_end_date = hr_api.g_eot
     and susp.enrt_cvg_thru_dt = hr_api.g_eot
     and susp.prtt_enrt_rslt_id = currently_susp.prtt_enrt_rslt_id
     and currently_susp.effective_end_date+1 = susp.effective_start_date
     and currently_susp.enrt_cvg_thru_dt = hr_api.g_eot
     and currently_susp.per_in_ler_id <> c_per_in_ler_id
     and currently_susp.sspndd_flag = 'Y' ;
 */
cursor c_cf_suspended(c_prtt_enrt_rslt_id number,
             c_per_in_ler_id number,
             c_elig_per_elctbl_chc_id number) is
  select currently_susp.prtt_enrt_rslt_id,
         currently_susp.rplcs_sspndd_rslt_id
    from ben_prtt_enrt_rslt_f susp,
         ben_prtt_enrt_rslt_f currently_susp
   where susp.prtt_enrt_rslt_id = c_prtt_enrt_rslt_id
     and susp.per_in_ler_id = c_per_in_ler_id
     -- and susp.sspndd_flag = 'N' --This can be changed once elinf is fixed
     and susp.effective_end_date = hr_api.g_eot
     and susp.enrt_cvg_thru_dt = hr_api.g_eot
     and currently_susp.prtt_enrt_rslt_stat_cd IS NULL
     and susp.person_id = currently_susp.person_id
     and (currently_susp.pl_id = susp.pl_id AND
          (p_pgm_id IS NULL or currently_susp.pgm_id = susp.pgm_id) AND
          (p_oipl_id IS NULL or currently_susp.oipl_id = susp.oipl_id))
     and currently_susp.effective_end_date = hr_api.g_eot
     and currently_susp.enrt_cvg_thru_dt = hr_api.g_eot
     and currently_susp.per_in_ler_id <> c_per_in_ler_id
     and currently_susp.sspndd_flag = 'Y' ;
 --
 l_cf_suspended c_cf_suspended%ROWTYPE;
 --
 --determines if we have a valid interim to carry forward
 --
 cursor c_cf_interim(c_prtt_enrt_rslt_id number,
                     c_per_in_ler_id number) is
  select new_epe.elig_per_elctbl_chc_id,
         interim.bnft_ordr_num ordr_num,
         interim.bnft_amt
    from ben_prtt_enrt_rslt_f interim,
         ben_elig_per_elctbl_chc new_epe
   where interim.prtt_enrt_rslt_id = c_prtt_enrt_rslt_id
     and interim.per_in_ler_id <> c_per_in_ler_id
     and interim.effective_end_date = hr_api.g_eot
     and interim.enrt_cvg_thru_dt = hr_api.g_eot
     and new_epe.per_in_ler_id = c_per_in_ler_id
     and new_epe.pl_id = interim.pl_id
     and nvl(new_epe.pgm_id,-1) = nvl(interim.pgm_id,-1)
     and nvl(new_epe.oipl_id,-1)= nvl(interim.oipl_id,-1)
     and interim.prtt_enrt_rslt_stat_cd is null ;
 --
 l_cf_interim c_cf_interim%ROWTYPE;
 --
 cursor c_cf_bnft(c_ordr_num number,
                  c_bnft_amt number,
                  c_elig_per_elctbl_chc_id number ) is
   select enb.enrt_bnft_id,
          enb.val bnft_amt
     from ben_enrt_bnft enb
    where enb.ordr_num = c_ordr_num
          --enb.val = c_bnft_amt
      and enb.entr_val_at_enrt_flag = 'N'
      and enb.elig_per_elctbl_chc_id = c_elig_per_elctbl_chc_id ;
 --We are dealing this like 'SM' case as the interim code is SM
 --Changind as per discussion with Lynda on 12-Oct-2006
  cursor c_cf_bnft_sm(c_ordr_num number,
                  c_bnft_amt number,
                  c_elig_per_elctbl_chc_id number ) is
   select enb.enrt_bnft_id,
          enb.val bnft_amt
     from ben_enrt_bnft enb
    where --enb.ordr_num = c_ordr_num
          enb.val = c_bnft_amt
      and enb.entr_val_at_enrt_flag = 'N'
      and enb.mx_wo_ctfn_flag = 'Y'
      and enb.ordr_num = -1
      and enb.elig_per_elctbl_chc_id = c_elig_per_elctbl_chc_id ;
  --
--Bug#5402317
  cursor c_get_lf_evt_ocrd_dt
  is
  select  lf_evt_ocrd_dt
  from    ben_per_in_ler pil
  where   pil.per_in_ler_id = p_per_in_ler_id
  and     pil.business_group_id = p_business_group_id;
--Bug#5402317
 --
 l_get_lf_evt_ocrd_dt ben_per_in_ler.lf_evt_ocrd_dt%type;
 l_ctfn_rqd      varchar2(30);
 l_cf_bnft c_cf_bnft%ROWTYPE;

 /*Added for Bug 7426609 */
 /* Cursor to fetch the new Interim benfit amount */
 cursor c_interim_bnft(p_elig_per_elctbl_chc_id number) is
        select enb.val bnft_amt,
        enb.enrt_bnft_id
        from   ben_enrt_bnft enb
        where  enb.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id
        and    enb.ordr_num in (-1,1)
	order by enb.ordr_num;

l_int_bnft_amt c_interim_bnft%rowtype;
/*End of Bug 7426609 */

 --
Begin
  hr_utility.set_location('Entering ' || l_proc, 05);
  hr_utility.set_location('p_per_in_ler_id '||p_per_in_ler_id,10);

  -- set an output to null
  p_interim_bnft_amt := null;
  --
  open c_get_lf_evt_ocrd_dt;
   fetch c_get_lf_evt_ocrd_dt into l_get_lf_evt_ocrd_dt;
   close c_get_lf_evt_ocrd_dt;
  --
  hr_utility.set_location('l_get_lf_evt_ocrd_dt '||l_get_lf_evt_ocrd_dt,23);
  hr_utility.set_location('p_ler_id'||p_ler_id,23);
  hr_utility.set_location('p_pl_id'||p_pl_id,23);
  hr_utility.set_location('p_prtt_enrt_rslt_id'||p_prtt_enrt_rslt_id,23);
  --
  For l_rec in c1(l_get_lf_evt_ocrd_dt) loop
    if l_rec.order_no = 2 then
      l_BNFT_OR_OPTION_RSTRCTN_CD := l_rec.BNFT_OR_OPTION_RSTRCTN_CD;
    end if;
    If (l_rec.order_no = 3) and
      l_bnft_or_option_rstrctn_cd is null then
      l_BNFT_OR_OPTION_RSTRCTN_CD := l_rec.BNFT_OR_OPTION_RSTRCTN_CD;
    End if;
    If l_DFLT_TO_ASN_PNDG_CTFN_CD is null then
      l_DFLT_TO_ASN_PNDG_CTFN_CD := l_rec.DFLT_TO_ASN_PNDG_CTFN_CD;
      l_DFLT_TO_ASN_PNDG_CTFN_RL := l_rec.DFLT_TO_ASN_PNDG_CTFN_RL;
    End if;
  End loop;
  --

  /*Added for Bug 7426609 */
  /* Instead of determining the new Interim again, modified the code to get the Interim choice epe id for the reprocessed LE
   set the approproiate values and return. */
  if(ben_lf_evt_clps_restore.g_reinstate_interim_flag and ben_lf_evt_clps_restore.g_reinstate_interim_chc_id is not null) then
     p_interim_elctbl_chc_id := ben_lf_evt_clps_restore.g_reinstate_interim_chc_id;

     open c_interim_bnft(p_interim_elctbl_chc_id);
     fetch c_interim_bnft into l_int_bnft_amt;
     close c_interim_bnft;

     p_interim_bnft_amt      := l_int_bnft_amt.bnft_amt;
     p_interim_enrt_bnft_id  := l_int_bnft_amt.enrt_bnft_id;

     p_bnft_or_option_rstrctn_cd := l_bnft_or_option_rstrctn_cd;

	  hr_utility.set_location('dflt_to_asn_pndg_ctfn_cd='||l_DFLT_TO_ASN_PNDG_CTFN_CD,9991);
	  hr_utility.set_location('interim_action='||l_interim_action,9991);
	  hr_utility.set_location('interim_bnf='||p_interim_enrt_bnft_id,9991);
	  hr_utility.set_location('p_interim_enrt_rslt_id='||p_interim_enrt_rslt_id,9991);
	  ben_lf_evt_clps_restore.g_reinstate_interim_flag := false;
  return;
  end if;
  /*Ended for Bug 7426609 */


  hr_utility.set_location('l_DFLT_TO_ASN_PNDG_CTFN_CD'||l_DFLT_TO_ASN_PNDG_CTFN_CD,24);
  hr_utility.set_location('l_BNFT_OR_OPTION_RSTRCTN_CD'||l_BNFT_OR_OPTION_RSTRCTN_CD,24);
  --
  hr_utility.set_location(l_proc,10 );
  --
  -- If code is rule, get the real code by calling formula
  --
  If (l_DFLT_TO_ASN_PNDG_CTFN_CD = 'RL') then
    hr_utility.set_location(l_proc,20 );

    if p_elig_per_elctbl_chc_id is not null then
      hr_utility.set_location(l_proc, 30);
      open c_epe;
      fetch c_epe into l_epe;
      close c_epe;
    end if;
    hr_utility.set_location(l_proc, 40);

    if l_epe.oipl_id is not null then
      hr_utility.set_location(l_proc, 50);
      open c_opt;
      fetch c_opt into l_opt;
      close c_opt;
    end if;
    hr_utility.set_location(l_proc, 60);
/*  -- 4031733 - Cursor c_state populates l_state variable which is no longer
    -- used in the package. Cursor can be commented
    if p_person_id is not null then
      open c_state;
      fetch c_state into l_state;
      close c_state;

--      if l_state.region_2 is not null then
--        l_jurisdiction_code :=
--           pay_mag_utils.lookup_jurisdiction_code
--            (p_state => l_state.region_2);
--      end if;
      hr_utility.set_location(l_proc, 70);
    end if;
*/
    hr_utility.set_location(l_proc, 80);

    open c_paf;

    fetch c_paf into l_assignment_id,l_organization_id;
    if (c_paf%notfound) then
       close c_paf;
       hr_utility.set_location('BEN_91698_NO_ASSIGNMENT_FND', 80);
       fnd_message.set_name('BEN','BEN_91698_NO_ASSIGNMENT_FND');
       fnd_message.set_token('ID' , to_char(p_person_id));
       fnd_message.raise_error;
    end if;
    close c_paf;
    hr_utility.set_location(l_proc, 90);


    l_dflt_to_asn_pndg_ctfn_cd :=
      get_dflt_to_asn_pndg_ctfn_cd
        (p_dflt_to_asn_pndg_ctfn_rl => l_dflt_to_asn_pndg_ctfn_rl
        ,p_person_id                => p_person_id
        ,p_per_in_ler_id            => p_per_in_ler_id
        ,p_assignment_id            => l_assignment_id
        ,p_organization_id          => l_organization_id
        ,p_business_group_id	    => p_business_group_id
        ,p_pgm_id                   => l_epe.pgm_id
        ,p_pl_id                    => l_epe.pl_id
        ,p_pl_typ_id                => l_epe.pl_typ_id
        ,p_opt_id                   => l_opt.opt_id
        ,p_ler_id                   => l_epe.ler_id
        ,p_jurisdiction_code        => l_jurisdiction_code
        ,p_elig_per_elctbl_chc_id   => p_elig_per_elctbl_chc_id
        ,p_effective_date           => p_effective_date
        ,p_prtt_enrt_rslt_id        => p_prtt_enrt_rslt_id
        ,p_interim_epe_id           => p_interim_elctbl_chc_id
      --   ,p_interim_enb_id           => p_interim_enrt_bnft_id
        ,p_interim_bnft_amt         => p_interim_bnft_amt
        );
    --Call the validation procedure if p_interim_elctbl_chc_id is being returned by the
    --abovl.
    --9999
    IF p_interim_elctbl_chc_id IS NOT NULL THEN
      --
      validate_interim_rule (
         p_prtt_enrt_rslt_id         =>p_prtt_enrt_rslt_id
        ,p_elig_per_elctbl_chc_id    =>p_elig_per_elctbl_chc_id
        ,p_enrt_bnft_id              =>p_enrt_bnft_id
        ,p_person_id                 =>p_person_id
        ,p_ler_id                    =>p_ler_id
        ,p_per_in_ler_id             =>p_per_in_ler_id
        ,p_pl_id                     =>p_pl_id
        ,p_pgm_id                    =>p_pgm_id
        ,p_pl_typ_id                 =>p_pl_typ_id
        ,p_oipl_id                   =>p_oipl_id
        ,p_pl_ordr_num               =>p_pl_ordr_num
        ,p_oipl_ordr_num             =>p_oipl_ordr_num
        ,p_plip_ordr_num             =>p_plip_ordr_num
        ,p_bnft_ordr_num             =>p_bnft_ordr_num
        ,p_business_group_id         =>p_business_group_id
        ,p_interim_elctbl_chc_id     =>p_interim_elctbl_chc_id
        ,p_interim_enrt_bnft_id      =>p_interim_enrt_bnft_id
        ,p_interim_bnft_amt          =>p_interim_bnft_amt
        );
      --
      p_bnft_or_option_rstrctn_cd := l_bnft_or_option_rstrctn_cd;
      --
      hr_utility.set_location('Interim Rule is returning the following comp object',1888);
      hr_utility.set_location('interim_chc='||p_interim_elctbl_chc_id,1888);
      hr_utility.set_location('interim_bnf='||p_interim_enrt_bnft_id,1888);
      hr_utility.set_location('interim_amt='||p_interim_bnft_amt,1888);
     hr_utility.set_location('l_bnft_or_option_rstrctn_cd'||l_bnft_or_option_rstrctn_cd,1888);
      hr_utility.set_location('Leaving  ' || l_proc, 1888);
      --
      return;
      --
    END IF;
    --
    hr_utility.set_location(l_proc, 100);
  End if;

  l_last_place:='Step 1';
  hr_utility.set_location(l_proc||l_DFLT_TO_ASN_PNDG_CTFN_CD, 120);
  --
  -- Char's 2/3 indicate whether we need to stay in what they were enrolled in
  -- if it's the same plan only (SE), or if it's just the same plan type (AS).
  l_intm_dfn_level := substr(l_DFLT_TO_ASN_PNDG_CTFN_CD,2,2);
  hr_utility.set_location('l_intm_dfn_level '||l_intm_dfn_level,125);

  -- ikasire - 'AS' can have plans and also oipls. Why to restricts only to
  -- plans without options ? 'AS' is not for plan without options as per documentation.
  -- if we need to make any changes here that needs to be documented with Keith.
  --
  -- ikasire - Interim Enhancements 30-Jul-2002
  -- 'AS' is now used for Current Same Plan Type set of codes.
  -- We can have plans or option in Plans for this case.
  if l_intm_dfn_level = 'AS' then
         -- and p_oipl_id is null then   Bug 1998648 This never works if there are options
     open c_current_enrt(v_pl_id => null,v_oipl_id => null);
     fetch c_current_enrt into
       l_enrt_pl_id,
       l_enrt_pl_typ_id,
       --l_enrt_chc_id,
       -- RCHASE Bug#5353
       l_prtt_enrt_rslt_id;
     close c_current_enrt;
     hr_utility.set_location('l_enrt_chc_id: '||to_char(l_enrt_chc_id), 61);
     --
     -- Plan Type level interim coverage defintion.
     -- This is supposed to be defined for plans without options i.e.
     -- benefits are at plan level.
     --
     if l_enrt_pl_typ_id is not null then
       -- Current enrollment found.
       -- RCHASE Bug#5353 current enrollment in same plan type requires
       -- iterim set to code
       l_interim_action:=substr(l_dflt_to_asn_pndg_ctfn_cd,4,2);
       --
       l_currently_enrolled := 'Y' ;
       --
     else
       -- New Enrollment.
       l_interim_action:=substr(l_dflt_to_asn_pndg_ctfn_cd,7,2);
     end if;
     hr_utility.set_location('l_interim_action: '||l_interim_action, 62);

  elsif l_intm_dfn_level = 'SE' then
     -- This is Option or Benefits within a Plan Case
     open c_current_enrt(v_pl_id => p_pl_id,v_oipl_id => null );
     fetch c_current_enrt into
       l_enrt_pl_id,
       l_enrt_pl_typ_id,
       -- l_enrt_chc_id,
       -- RCHASE Bug#5353
       l_prtt_enrt_rslt_id;
     close c_current_enrt;
     hr_utility.set_location('l_enrt_chc_id: '||to_char(l_enrt_chc_id), 63);
     --
     -- Plan level interim coverage defintion.
     --
     if l_enrt_pl_id is not null then
        -- Current enrollment found.
       -- RCHASE Bug#5353 current enrollment in same plan type requires
       -- iterim set to code.
       l_interim_action:=substr(l_dflt_to_asn_pndg_ctfn_cd,4,2);
       --
       l_currently_enrolled := 'Y' ;
       --
      else
        -- New Enrollment.
        l_interim_action:=substr(l_dflt_to_asn_pndg_ctfn_cd,7,2);
      end if;
     hr_utility.set_location('l_interim_action: '||l_interim_action, 64);
    --
  elsif l_intm_dfn_level = 'SO' then
     -- This is Option or Benefits within a Plan Case
     open c_current_enrt(v_pl_id => p_pl_id,v_oipl_id => p_oipl_id );
     fetch c_current_enrt into
       l_enrt_pl_id,
       l_enrt_pl_typ_id,
       -- l_enrt_chc_id,
       -- RCHASE Bug#5353
       l_prtt_enrt_rslt_id;
     close c_current_enrt;
     hr_utility.set_location('l_enrt_chc_id: '||to_char(l_enrt_chc_id), 63);
     --
     -- Plan level interim coverage defintion.
     --
     if l_enrt_pl_id is not null then
        -- Current enrollment found.
       -- iterim set to code.
       l_interim_action:=substr(l_dflt_to_asn_pndg_ctfn_cd,4,2);
       --
       l_currently_enrolled := 'Y' ;
       --
     else
        -- New Enrollment.
       l_interim_action:=substr(l_dflt_to_asn_pndg_ctfn_cd,7,2);
     end if;
     hr_utility.set_location('l_interim_action: '||l_interim_action, 64);
  end if;
  hr_utility.set_location(l_proc, 180);
  l_last_place:='Step 3';
  --
  -- l_interim_action is either chars 4/5 (if prev enrt in same pl type was found)
  -- or chars 7/8 if no prev enrt in plan type was found.
  -- It indicates NT (no interim), MN (minimum order num), NL (next lower order num)
  -- or DF (default chc)
  -- According to doc, these should only be looked at if chars 2/3 do not produce
  -- an electable choice.  I don't think the code is doing that.  We should
  -- check with ddw as to which is correct.
  --
  --Carry Forward Certifcations,Suspended and Interim Enrollments logic
  --
  hr_utility.set_location('Before Checking CF Suspended Results',181);
  hr_utility.set_location('l_currently_enrolled:'||l_currently_enrolled,181);
  hr_utility.set_location('p_prtt_enrt_rslt_id:'||p_prtt_enrt_rslt_id,181);
  hr_utility.set_location('p_per_in_ler_id:'||p_per_in_ler_id,181);
  hr_utility.set_location('p_elig_per_elctbl_chc_id:'||p_elig_per_elctbl_chc_id,181);
  hr_utility.set_location('g_cfw_flag '||g_cfw_flag,181);
  --Bug 4463267
  IF g_cfw_flag = 'Y' THEN
  if l_currently_enrolled = 'Y' then
    --
    open c_cf_suspended(p_prtt_enrt_rslt_id,
                        p_per_in_ler_id,
                        p_elig_per_elctbl_chc_id );
    --
    fetch c_cf_suspended into l_cf_suspended ;
      --
      if c_cf_suspended%found then
        l_cf_required := 'Y' ;
        hr_utility.set_location('l_cf_required := Y',181);
      end if;
      --
    close c_cf_suspended ;
    --
    if l_cf_required = 'Y' and l_cf_suspended.rplcs_sspndd_rslt_id IS NOT NULL then
      --
      hr_utility.set_location('Curr Interim '||l_cf_suspended.rplcs_sspndd_rslt_id,181);
      --
      open c_cf_interim(l_cf_suspended.rplcs_sspndd_rslt_id,p_per_in_ler_id);
        fetch c_cf_interim into l_cf_interim;
      close c_cf_interim ;
      --
      p_interim_elctbl_chc_id := l_cf_interim.elig_per_elctbl_chc_id ;
      p_interim_enrt_rslt_id  := l_cf_suspended.rplcs_sspndd_rslt_id ;
      --
      hr_utility.set_location('p_interim_elctbl_chc_id'||p_interim_elctbl_chc_id,181);
      hr_utility.set_location('p_interim_enrt_rslt_id'||p_interim_enrt_rslt_id,181);
      hr_utility.set_location(' l_cf_interim.bnft_amt '||l_cf_interim.bnft_amt,181);
      hr_utility.set_location(' l_cf_interim.ordr_num '||l_cf_interim.ordr_num,181);
      hr_utility.set_location(' l_interim_action '||l_interim_action,181);
      --
      if l_cf_interim.elig_per_elctbl_chc_id is not null then
        --
        IF l_interim_action='SM' THEN
          --
          open c_cf_bnft_sm(l_cf_interim.ordr_num, l_cf_interim.bnft_amt,
                       l_cf_interim.elig_per_elctbl_chc_id);
            fetch c_cf_bnft_sm into l_cf_bnft ;
          close c_cf_bnft_sm ;
          --
        ELSE
          --
          open c_cf_bnft(l_cf_interim.ordr_num, l_cf_interim.bnft_amt,
                       l_cf_interim.elig_per_elctbl_chc_id);
            fetch c_cf_bnft into l_cf_bnft ;
          close c_cf_bnft ;
          --
        END IF;
        --
        if l_cf_bnft.enrt_bnft_id IS NOT NULL THEN
          --
          p_interim_bnft_amt      := l_cf_bnft.bnft_amt;
          p_interim_enrt_bnft_id  := l_cf_bnft.enrt_bnft_id;
          --
          hr_utility.set_location('p_interim_bnft_amt '||p_interim_bnft_amt,182);
          hr_utility.set_location('p_interim_enrt_bnft_id '||p_interim_enrt_bnft_id,182);
          --
        end if;
        --
      end if;
      --
    end if;
  end if;
  --
  END IF; --g_cfw_flag
  --
  hr_utility.set_location('After CF Suspended Results cf_required :'||l_cf_required ,181);
  --
  if l_cf_required = 'N' then
  --
  if l_interim_action='NT' then
     hr_utility.set_location(l_proc, 190);
     --  No interim
     l_last_place:='Step 4';
     p_interim_elctbl_chc_id:=null;
  elsif l_interim_action='SM' then
    hr_utility.set_location(l_proc, 200);
    --
    --  Interim is old enrollment
    l_last_place:='Step 5';
    --
    p_interim_elctbl_chc_id := null;
    --
    open c_current_same_epe(l_prtt_enrt_rslt_id) ;
    fetch c_current_same_epe into p_interim_elctbl_chc_id ;
    close c_current_same_epe ;
    --
    if p_interim_elctbl_chc_id is not null then
      --
      open c_cur_bnft(p_interim_elctbl_chc_id);
      fetch c_cur_bnft into l_cur_bnft;
      close c_cur_bnft;
      if l_cur_bnft.enrt_bnft_id is not null then
          p_interim_bnft_amt      := l_cur_bnft.bnft_amt;
          p_interim_enrt_bnft_id  := l_cur_bnft.enrt_bnft_id;
      end if;
      hr_utility.set_location(l_proc||'Got current Interim',12);
    else
      hr_utility.set_location(l_proc||'Not Current ',12);
    end if;
  --
  elsif l_interim_action='MN' then
    hr_utility.set_location(l_proc, 210);
    -- interim is minimum order number
    l_last_place:='Step 6';

    -- Bug 1249901:  if cvg is entered at enrollment, and interim-action is Minimum
    -- select the min val from same enrt-bnft and enroll the person in that.  When
    -- cvg is entered at enrt, I wouldn't expect there to be more than one
    -- enrt-bnft row.
    l_use_same_bnft := 'N';
    if p_elig_per_elctbl_chc_id is not null then
       open c_bnft;
       fetch c_bnft into l_bnft;
       close c_bnft;
       if l_bnft.enrt_bnft_id is not null then
          p_interim_bnft_amt      := l_bnft.bnft_amt;
          p_interim_enrt_bnft_id  := l_bnft.enrt_bnft_id;
          p_interim_elctbl_chc_id := p_elig_per_elctbl_chc_id;
          l_use_same_bnft := 'Y';
       end if;
    end if;

    if l_use_same_bnft = 'N' then
      if l_intm_dfn_level = 'AS' then
        --
        -- Current Same Plan Type Case, we need to see the minimum PLIP order.
        -- If there are options for the plans we need to see the minimum OIPL
        -- order also within the min PLIP
        if l_bnft_or_option_rstrctn_cd='BNFT' then
          -- Benefit restrictions case here.
          -- Find the minimum benefit record of the same comp object
          open c_min_bnft_epe ;
            fetch c_min_bnft_epe into p_interim_elctbl_chc_id,p_interim_enrt_bnft_id ;
          close c_min_bnft_epe ;
          l_last_place:='Step 6.4.1';
          hr_utility.set_location(' l_last_place '||l_last_place,122);
          hr_utility.set_location(' p_interim_elctbl_chc_id '||p_interim_elctbl_chc_id,122);
          hr_utility.set_location(' p_interim_enrt_bnft_id '||p_interim_enrt_bnft_id,122);
        else
          -- Option Restrictions case here
          hr_utility.set_location(l_proc, 220);
          l_last_place:='Step 6.5.1';
          open c_min_pl_epe;
             fetch c_min_pl_epe into p_interim_elctbl_chc_id,p_interim_enrt_bnft_id ;
          close c_min_pl_epe;
          hr_utility.set_location(' l_last_place '||l_last_place,123);
          hr_utility.set_location(' p_interim_elctbl_chc_id '||p_interim_elctbl_chc_id,123);
          hr_utility.set_location(' p_interim_enrt_bnft_id '||p_interim_enrt_bnft_id,123);

        end if;
      elsif l_intm_dfn_level in ( 'SE','SO') then
        if l_bnft_or_option_rstrctn_cd='BNFT' then
          -- Benefit restrictions case here.
          -- Find the minimum benefit record of the same comp object
          open c_min_bnft_epe;
          fetch c_min_bnft_epe into
            p_interim_elctbl_chc_id,
            l_interim_enrt_bnft_id;
          close c_min_bnft_epe;
          p_interim_enrt_bnft_id:=l_interim_enrt_bnft_id;
          l_last_place:= 'Step 6.6.1';
          hr_utility.set_location(' l_last_place '||l_last_place,124);
          hr_utility.set_location(' p_interim_elctbl_chc_id '||p_interim_elctbl_chc_id,124);
          hr_utility.set_location(' p_interim_enrt_bnft_id '||p_interim_enrt_bnft_id,124);
        else
          --
          -- Plan Level Option restrictions case
          --
          hr_utility.set_location(l_proc, 230);
          l_last_place:='Step 7';
          open c_min_oipl_epe;
          fetch c_min_oipl_epe into
            p_interim_elctbl_chc_id, p_interim_enrt_bnft_id;
          close c_min_oipl_epe;
          --
          hr_utility.set_location(' l_last_place '||l_last_place,125);
          hr_utility.set_location(' p_interim_elctbl_chc_id '||p_interim_elctbl_chc_id,125);
          hr_utility.set_location(' p_interim_enrt_bnft_id '||p_interim_enrt_bnft_id,125);
        end if;
      end if;
    end if;
    hr_utility.set_location('p_interim_elctbl_chc_id: '||
               to_char(p_interim_elctbl_chc_id), 240);
    hr_utility.set_location('p_interim_enrt_bnft_id: '||
               to_char(p_interim_enrt_bnft_id), 240);
    hr_utility.set_location('p_interim_bnft_amt: '||
               to_char(p_interim_bnft_amt), 240);
  elsif l_interim_action='NL' then
    hr_utility.set_location(l_proc, 250);
    -- Add Enter Value at enrollment Case
    l_use_same_bnft := 'N';
    if p_elig_per_elctbl_chc_id is not null then
       open c_bnft;
       fetch c_bnft into l_bnft;
       close c_bnft;
       if l_bnft.enrt_bnft_id is not null then
          p_interim_bnft_amt      := l_bnft.bnft_amt;
          p_interim_enrt_bnft_id  := l_bnft.enrt_bnft_id;
          p_interim_elctbl_chc_id := p_elig_per_elctbl_chc_id;
          l_use_same_bnft := 'Y';
       end if;
    end if;
    if l_use_same_bnft = 'N'then -- This is NOT enter value at enrollment case
      -- interim is next lower order number
      if l_intm_dfn_level = 'AS' then
        hr_utility.set_location(l_proc, 255);
        if l_bnft_or_option_rstrctn_cd='BNFT' then
          --
          -- Add Benefit Restrictions case. We need to look for the
          -- Next lower benefit record for the suspended comp object only.
          --
          open c_next_lower_bnft_pl_epe;
          fetch c_next_lower_bnft_pl_epe into
            p_interim_elctbl_chc_id,
            p_interim_enrt_bnft_id;
          close c_next_lower_bnft_pl_epe;
        else
          l_last_place:='Step 6.5';
          -- This is Option Restrictions case
          open c_next_lower_pl_typ_epe;
            fetch c_next_lower_pl_typ_epe into
            p_interim_elctbl_chc_id,
            p_interim_enrt_bnft_id ;
          close c_next_lower_pl_typ_epe;
        end if;
        --
      elsif l_intm_dfn_level in  ('SE','SO') then
        if l_bnft_or_option_rstrctn_cd='BNFT' then
          hr_utility.set_location(l_proc, 260);
          l_last_place:='Step 8';
          --
          -- Add Benefit Restrictions case. We need to look for the
          -- Next lower benefit record for the suspended comp object only.
          --
          open c_next_lower_bnft_pl_epe;
          fetch c_next_lower_bnft_pl_epe into
            p_interim_elctbl_chc_id,
            p_interim_enrt_bnft_id;
          close c_next_lower_bnft_pl_epe;
        else
          hr_utility.set_location(l_proc, 270);
          l_last_place:='Step 9';
          open c_next_lower_pl_epe;
          fetch c_next_lower_pl_epe into
            p_interim_elctbl_chc_id, p_interim_enrt_bnft_id;
          close c_next_lower_pl_epe;
        end if;
      end if;
    end if;
    hr_utility.set_location(l_proc, 280);
  elsif l_interim_action='DF' then
    -- Added the Enter value at  enrollment case to default
    l_use_same_bnft := 'N';
    if p_elig_per_elctbl_chc_id is not null then
       open c_dflt_bnft ;
       fetch c_dflt_bnft into l_bnft ;
       close c_dflt_bnft ;
       if l_bnft.enrt_bnft_id is not null then
          p_interim_bnft_amt      := l_bnft.bnft_amt;
          p_interim_enrt_bnft_id  := l_bnft.enrt_bnft_id;
          p_interim_elctbl_chc_id := p_elig_per_elctbl_chc_id;
          l_use_same_bnft := 'Y';
       end if;
    end if;
    --
    if l_use_same_bnft = 'N' then
      --Bug 1998648 added the SE and AS if condition
      if l_intm_dfn_level = 'AS' then
        --
        if l_bnft_or_option_rstrctn_cd='BNFT' then
        -- Benefit Restrictions case
        -- We need to get the default benefit record of the default plan in the
        -- plan type of the suspended enrollment.
          open c_default_bnft_epe;
          fetch c_default_bnft_epe into p_interim_elctbl_chc_id,
                                   p_interim_enrt_bnft_id ;
          close c_default_bnft_epe;
        else
          -- Option Restrictions Case
          -- We need to get the default plan or option in plan in the
          -- plan type of the suspended enrollment
          open c_default_epe;
          fetch c_default_epe into p_interim_elctbl_chc_id,
                                   p_interim_enrt_bnft_id ;
          close c_default_epe;
          --
        end if;

        hr_utility.set_location(l_proc, 290);
        -- interim is default choice
        l_last_place:='Step 10';
      elsif l_intm_dfn_level in  ('SE','SO') then
        --
        if l_bnft_or_option_rstrctn_cd='BNFT' then
          -- Benefit Restrictions case
          -- We need to get the default benefit record of the default plan in the
          -- plan type of the suspended enrollment.
          open c_default_bnft_pl_epe;
          fetch c_default_bnft_pl_epe into p_interim_elctbl_chc_id,
                                   p_interim_enrt_bnft_id ;
          close c_default_bnft_pl_epe;
	  ---Bug 8244648
	  if p_interim_elctbl_chc_id is null and p_interim_enrt_bnft_id is null then
	    open c_default_bnft_epe;
            fetch c_default_bnft_epe into p_interim_elctbl_chc_id,
                                          p_interim_enrt_bnft_id ;
            close c_default_bnft_epe;
	  end if;
	  ---Bug 8244648
        else
          -- Option Restrictions Case
          -- We need to get the default plan or option in plan in the
          -- plan type of the suspended enrollment
          l_last_place:='Step 11';
          open c_default_pl_epe;
          fetch c_default_pl_epe into p_interim_elctbl_chc_id,
                                 p_interim_enrt_bnft_id ;
          close c_default_pl_epe;
          --
	  ---Bug 8244648
	  if p_interim_elctbl_chc_id is null and p_interim_enrt_bnft_id is null then
	     open c_default_epe;
             fetch c_default_epe into p_interim_elctbl_chc_id,
                                      p_interim_enrt_bnft_id ;
             close c_default_epe;
	  end if;
	  ----Bug 8244648
        end if;
        --
        hr_utility.set_location(l_proc, 294);
        --
      end if;
      --
    end if;
    --
  end if;
  --
  end if; -- l_cf_required = 'N' case
  --
  -- Bug 1247109.  commented out this 'if' stmt.  It was causing us to try to use
  -- the suspended result id as the interim coverage, which caused an error due
  -- to object version number being wrong in update_enrollment.  Just allow
  -- subsequent process (election information) to get the result id for the
  -- interim choice.

  --  if l_enrt_chc_id=p_interim_elctbl_chc_id then
  --  hr_utility.set_location('pen_id='||to_char(p_prtt_enrt_rslt_id), 9876);
  --  p_interim_enrt_rslt_id:=p_prtt_enrt_rslt_id;
  --else
  -- RCHASE Bug#5353 nullifying the p_interim_enrt_rslt_id will not allow for the
  -- previous election to be used as the interim.  Removed null assignment.
  --  hr_utility.set_location(l_proc, 300);
  --  p_interim_enrt_rslt_id:=null;
  --end if;
  p_bnft_or_option_rstrctn_cd := l_bnft_or_option_rstrctn_cd ;
  --
  hr_utility.set_location('interim_chc='||p_interim_elctbl_chc_id,999);
  hr_utility.set_location('dflt_to_asn_pndg_ctfn_cd='||l_DFLT_TO_ASN_PNDG_CTFN_CD,999);
  hr_utility.set_location('interim_action='||l_interim_action,999);
  hr_utility.set_location('interim_bnf='||p_interim_enrt_bnft_id,999);
  hr_utility.set_location('p_interim_enrt_rslt_id='||p_interim_enrt_rslt_id,999);
  hr_utility.set_location('Leaving  ' || l_proc, 999);

Exception
  When others then
    hr_utility.set_location(l_proc, 320);
    rpt_error (p_proc  => l_proc, p_last_action => l_last_place);
--    hr_utility.set_location('ERROR: '||sqlerrm,1);
-- for nocopy changes
    p_interim_elctbl_chc_id := l_interim_elctbl_chc_id;
    fnd_message.raise_error;
End Determine_interim;
--
-- ==========================================================================
--                           << Process_interim >>
-- ==========================================================================
--
Procedure process_interim
            (p_elig_per_elctbl_chc_id  in     number
            ,p_enrt_bnft_id            in     number
            ,p_bnft_amt                in     number
            ,p_prtt_enrt_rslt_id       in out nocopy number
            ,p_business_group_id       in     number
            ,p_effective_date          in     date
            ,p_enrt_mthd_cd            in     varchar2 ) is

  cursor c_epe is
    select epe.ELIG_PER_ELCTBL_CHC_ID,
           epe.pgm_id,
           epe.pl_id,
           epe.oipl_id,
           pen.pgm_id pen_pgm_id,
           pen.pl_id pen_pl_id,
           pen.oipl_id pen_oipl_id,
           pen.enrt_cvg_thru_dt,
           pen.object_version_number
      From ben_elig_per_elctbl_chc epe,
           ben_prtt_enrt_rslt_f    pen
     Where epe.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id
       and epe.business_group_id = p_business_group_id
       and pen.prtt_enrt_rslt_id(+)=epe.prtt_enrt_rslt_id
       and pen.business_group_id(+)=p_business_group_id
       and pen.prtt_enrt_rslt_stat_cd is null
       and p_effective_date between
             pen.effective_start_date(+) and pen.effective_end_date(+)
          ;
  l_epe  c_epe%rowtype;
  --
  cursor c_rt is
    select ecr.enrt_rt_id
          ,ecr.dflt_val
          ,ecr.ANN_DFLT_VAL
      from ben_enrt_rt ecr
     where ecr.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id
       and ecr.business_group_id = p_business_group_id
       and ecr.entr_val_at_enrt_flag = 'Y'
       -- and ecr.prtt_rt_val_id is null -- Bug 5415757 - This clause prevented carry forward of rates for interim PEN
  union
    select ecr.enrt_rt_id
          ,ecr.dflt_val
          ,ecr.ANN_DFLT_VAL
      from ben_enrt_rt ecr
          ,ben_enrt_bnft enb
     where enb.enrt_bnft_id = ecr.enrt_bnft_id
       and ecr.business_group_id = p_business_group_id
       and enb.business_group_id = p_business_group_id
       and enb.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id
       and ecr.entr_val_at_enrt_flag = 'Y'
       -- and ecr.prtt_rt_val_id is null -- Bug 5415757 - This clause prevented carry forward of rates for interim PEN
          ;
  --
  cursor c_bnft is
    select enrt_bnft_id, val
      from ben_enrt_bnft
     where elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id
       and business_group_id=p_business_group_id
--       and dflt_flag = 'Y'
       and (enrt_bnft_id=p_enrt_bnft_id
           or (p_enrt_bnft_id is null and
               dflt_flag='Y'))
          ;
  type enrt_id_table is table of c_rt%rowtype index by binary_integer;
  l_proc                 varchar2(80) := g_package || '.process_interim';
  l_rt                   enrt_id_table;
  l_tot_rt               number(5) := 0;
  l_bnft_amt             ben_enrt_bnft.val%type;
  l_bnft_id              ben_enrt_bnft.enrt_bnft_id%type;
  l_suspend_flag         varchar2(30);
  l_prtt_enrt_interim_id number(15);
  l_datetrack_mode       varchar2(30);
  l_effective_start_date date;
  l_effective_end_date   date;
  l_dump_num             number(15);
  -- RCHASE Bug#5353 added for generating output
  l_ret             number;
  l_dump_boolean         boolean;
  l_last_place           varchar2(80);

  -- for nocopy changes
  l_prtt_enrt_rslt_id number := p_prtt_enrt_rslt_id;
Begin
  hr_utility.set_location ('Entering '|| l_proc,5);
  hr_utility.set_location('pen_id='||to_char(p_prtt_enrt_rslt_id), 1499);
  open c_epe;
  fetch c_epe into l_epe;
  If c_epe%notfound then
    close c_epe;
    hr_utility.set_location('BEN_91457_ELCTBL_CHC_NOT_FOUND id:'||
           to_char(p_elig_per_elctbl_chc_id), 10);
    fnd_message.set_name('BEN','BEN_91457_ELCTBL_CHC_NOT_FOUND');
    fnd_message.set_token('ID', to_char(p_elig_per_elctbl_chc_id));
    fnd_message.set_token('PROC', '1:'||l_proc);
    fnd_message.raise_error;
  End if;
  close c_epe;
  --
  -- Get Benefit ID and Benefit amount
  --
  if p_enrt_bnft_id is not null and p_bnft_amt is null then
     open c_bnft;
     fetch c_bnft into l_bnft_id, l_bnft_amt;
     close c_bnft;
  else
     l_bnft_amt := p_bnft_amt;
     l_bnft_id :=  p_enrt_bnft_id;
  end if;
  --
  hr_utility.set_location(' l_bnft_amt '||l_bnft_amt,1234);
  hr_utility.set_location(' l_bnft_id '||l_bnft_id,1234);
  -- Initialize enrt_id_tbl and enrt_val_tbl, then load rate data
  --
  For i in 1..10 loop
    l_rt(i).enrt_rt_id   := NULL;
    l_rt(i).dflt_val     := 0;
    l_rt(i).ann_dflt_val := 0;
  End loop;
  l_tot_rt := 0;
  For Crec in c_rt loop
    l_tot_rt := l_tot_rt + 1;
    l_rt(l_tot_rt).enrt_rt_id    := Crec.enrt_rt_id;
    l_rt(l_tot_rt).dflt_val      := Crec.dflt_val;
    l_rt(l_tot_rt).ann_dflt_val  := Crec.ann_dflt_val;
  End loop;
  l_suspend_flag := 'N';
  g_use_new_result:=true;
  --
  hr_utility.set_location('g_use_new_result',333);
  --
  --CFW. Same epe. Just needs to have the interim updated with the new pil
  --
  /*
  if nvl(l_epe.pgm_id,-1) = nvl(l_epe.pen_pgm_id,-1) and
     nvl(l_epe.pl_id,-1) = nvl(l_epe.pen_pl_id,-1) and
     nvl(l_epe.oipl_id,-1) = nvl(l_epe.pen_oipl_id,-1) and
     l_epe.enrt_cvg_thru_dt = hr_api.g_eot then
     g_use_new_result:=false;
     --
     hr_utility.set_location('g_use_new_result false',333);
     --
  end if;
  */
  --
  ben_election_information.election_information
    (p_elig_per_elctbl_chc_id => l_epe.elig_per_elctbl_chc_id
    ,p_prtt_enrt_rslt_id      => p_prtt_enrt_rslt_id
    ,p_effective_date         => p_effective_date
    ,p_enrt_mthd_cd           => p_enrt_mthd_cd
    ,p_called_from_sspnd      => 'Y'
    ,p_business_group_id      => p_business_group_id
    ,p_enrt_bnft_id           => l_bnft_id
    ,p_bnft_val               => l_bnft_amt
    ,p_enrt_rt_id1            => l_rt(1).enrt_rt_id
    ,p_enrt_rt_id2            => l_rt(2).enrt_rt_id
    ,p_enrt_rt_id3            => l_rt(3).enrt_rt_id
    ,p_enrt_rt_id4            => l_rt(4).enrt_rt_id
    ,p_enrt_rt_id5            => l_rt(5).enrt_rt_id
    ,p_enrt_rt_id6            => l_rt(6).enrt_rt_id
    ,p_enrt_rt_id7            => l_rt(7).enrt_rt_id
    ,p_enrt_rt_id8            => l_rt(8).enrt_rt_id
    ,p_enrt_rt_id9            => l_rt(9).enrt_rt_id
    ,p_enrt_rt_id10           => l_rt(10).enrt_rt_id
    ,p_rt_val1                => l_rt(1).dflt_val
    ,p_rt_val2                => l_rt(2).dflt_val
    ,p_rt_val3                => l_rt(3).dflt_val
    ,p_rt_val4                => l_rt(4).dflt_val
    ,p_rt_val5                => l_rt(5).dflt_val
    ,p_rt_val6                => l_rt(6).dflt_val
    ,p_rt_val7                => l_rt(7).dflt_val
    ,p_rt_val8                => l_rt(8).dflt_val
    ,p_rt_val9                => l_rt(9).dflt_val
    ,p_rt_val10               => l_rt(10).dflt_val
    ,p_Ann_rt_val1            => l_rt(1).ann_dflt_val
    ,p_Ann_rt_val2            => l_rt(2).ann_dflt_val
    ,p_Ann_rt_val3            => l_rt(3).ann_dflt_val
    ,p_Ann_rt_val4            => l_rt(4).ann_dflt_val
    ,p_Ann_rt_val5            => l_rt(5).ann_dflt_val
    ,p_Ann_rt_val6            => l_rt(6).ann_dflt_val
    ,p_Ann_rt_val7            => l_rt(7).ann_dflt_val
    ,p_Ann_rt_val8            => l_rt(8).ann_dflt_val
    ,p_Ann_rt_val9            => l_rt(9).ann_dflt_val
    ,p_Ann_rt_val10           => l_rt(10).ann_dflt_val
    ,p_datetrack_mode         => hr_api.g_update
    ,p_suspend_flag           => l_suspend_flag
    ,p_prtt_enrt_interim_id   => l_prtt_enrt_interim_id
    ,P_PRTT_RT_VAL_ID1        => l_dump_num
    ,P_PRTT_RT_VAL_ID2        => l_dump_num
    ,P_PRTT_RT_VAL_ID3        => l_dump_num
    ,P_PRTT_RT_VAL_ID4        => l_dump_num
    ,P_PRTT_RT_VAL_ID5        => l_dump_num
    ,P_PRTT_RT_VAL_ID6        => l_dump_num
    ,P_PRTT_RT_VAL_ID7        => l_dump_num
    ,P_PRTT_RT_VAL_ID8        => l_dump_num
    ,P_PRTT_RT_VAL_ID9        => l_dump_num
    ,P_PRTT_RT_VAL_ID10       => l_dump_num
    ,P_OBJECT_VERSION_NUMBER  => l_epe.object_version_number
    ,p_effective_start_date   => l_effective_start_date
    ,p_effective_end_date     => l_effective_end_date
    ,P_DPNT_ACTN_WARNING      => l_dump_boolean
    ,P_BNF_ACTN_WARNING       => l_dump_boolean
    ,P_CTFN_ACTN_WARNING      => l_dump_boolean
     );
    g_use_new_result:=false;
  hr_utility.set_location ('Leaving '|| l_proc,99);
Exception
  When others then
    hr_utility.set_location('ERROR '||l_proc, 98);
    rpt_error (p_proc  => l_proc, p_last_action => l_last_place);
    -- for nocopy changes
    p_prtt_enrt_rslt_id := l_prtt_enrt_rslt_id;
     g_interim_flag := 'N';  -- bug 5653168
    fnd_message.raise_error;
End process_interim;
--
-- ==========================================================================
--                        << Update_sspndd_flag >>
-- ==========================================================================
--
Procedure update_sspndd_flag
  (p_prtt_enrt_rslt_id       in      number,
   p_effective_date          in      date,
   p_business_group_id       in      number,
   p_sspndd_flag             in      varchar2,
   p_RPLCS_SSPNDD_RSLT_ID    in      number,
   p_object_version_number   in out nocopy  number,
   p_datetrack_mode          in      varchar2,
   p_ENRT_PL_OPT_FLAG        in      varchar2  default 'N',
   p_enrt_cvg_strt_dt        in      date      default hr_api.g_date,
   p_enrt_cvg_thru_dt        in      date      default hr_api.g_date,
   p_pgm_id                  in      number    default NULL,
   p_pl_id                   in      number    default NULL,
   p_person_id               in      number
  ) is
  Cursor csr_pen is
    Select rplcs_sspndd_rslt_id
          ,prtt_enrt_rslt_id
          ,effective_start_date
          ,effective_end_date
          ,enrt_cvg_strt_dt
          ,enrt_cvg_thru_dt
          ,object_version_number
      From ben_prtt_enrt_rslt_f pen
     Where pen.business_group_id  = p_business_group_id
       And pen.person_id = p_person_id
       And nvl(pen.pgm_id,-1) = nvl(p_pgm_id,-1)
       And pen.pl_id = p_pl_id
       And p_effective_date between
             pen.effective_start_date and nvl(pen.effective_end_date,hr_api.g_eot)
       And pen.sspndd_flag = 'Y'
       and pen.prtt_enrt_rslt_stat_cd is null
       And pen.oipl_id is not NULL
          ;
  l_effective_start_date   date;
  l_effective_end_date     date;
  l_proc                   varchar2(80) := g_package || '.update_sspndd_flag';
  l_last_place             varchar2(100);
  l_datetrack_mode         varchar2(30);
 -- for nocopy changes
 l_object_version_number number := p_object_version_number ;

Begin
  hr_utility.set_location('Entering '||l_proc, 05);

  l_last_place := 'Calling get_ben_pen_upd_dt_mode';
  --
  hr_utility.set_location('p_datetrack_mode '||p_datetrack_mode,10);
  --
  ben_prtt_enrt_result_api.get_ben_pen_upd_dt_mode
                     (p_effective_date         => p_effective_date
                     ,p_base_key_value         => p_prtt_enrt_rslt_id
                     ,P_desired_datetrack_mode => p_datetrack_mode
                     ,P_datetrack_allow        => l_datetrack_mode
                     );
  --
  hr_utility.set_location('l_datetrack_mode '||l_datetrack_mode,10);
  --
  l_last_place := 'Calling update_prtt_enrt_result';
  ben_prtt_enrt_result_api.update_prtt_enrt_result
    (p_validate                 => FALSE,
     p_prtt_enrt_rslt_id        => p_prtt_enrt_rslt_id,
     p_effective_start_date     => l_effective_start_date,
     p_effective_end_date       => l_effective_end_date,
     p_business_group_id        => p_business_group_id,
     p_sspndd_flag              => p_sspndd_flag,
     p_RPLCS_SSPNDD_RSLT_ID     => p_rplcs_sspndd_rslt_id,
     p_enrt_cvg_strt_dt         => p_enrt_cvg_strt_dt,
     p_enrt_cvg_thru_dt         => p_enrt_cvg_thru_dt,
     p_object_version_number    => p_object_version_number,
     p_effective_date           => p_effective_date,
     p_datetrack_mode           => l_datetrack_mode,
     p_multi_row_validate       => FALSE,
     p_program_application_id   => fnd_global.prog_appl_id,
     p_program_id               => fnd_global.conc_program_id,
     p_request_id               => fnd_global.conc_request_id,
     p_program_update_date      => sysdate);
  --
  -- If the un-suspended plan is saving plan, then un-suspend its
  -- options as well.
  --
  If (p_ENRT_PL_OPT_FLAG = 'Y') then
    l_last_place := 'Calling update_prtt_enrt_rslt options...';
    For l_rec in csr_pen loop
      If (p_effective_date = l_rec.effective_start_date) Then
        l_datetrack_mode  := 'CORRECTION';
      Else
        l_datetrack_mode  := p_datetrack_mode;
      End If;
      l_last_place := 'Calling update_prtt_enrt_rslt case 1.2';
      ben_prtt_enrt_result_api.update_prtt_enrt_result
        (p_validate                 => FALSE,
         p_prtt_enrt_rslt_id        => l_rec.prtt_enrt_rslt_id,
         p_effective_start_date     => l_rec.effective_start_date,
         p_effective_end_date       => l_rec.effective_end_date,
         p_enrt_cvg_strt_dt         => p_enrt_cvg_strt_dt,
         p_enrt_cvg_thru_dt         => p_enrt_cvg_thru_dt,
         p_business_group_id        => p_business_group_id,
         p_sspndd_flag              => p_sspndd_flag,
         p_RPLCS_SSPNDD_RSLT_ID     => l_rec.rplcs_sspndd_rslt_id,
         p_object_version_number    => l_rec.object_version_number,
         p_effective_date           => p_effective_date,
         p_datetrack_mode           => l_datetrack_mode,
         p_multi_row_validate       => FALSE,
         p_program_application_id   => fnd_global.prog_appl_id,
         p_program_id               => fnd_global.conc_program_id,
         p_request_id               => fnd_global.conc_request_id,
         p_program_update_date      => sysdate);
    End loop;
  End if;

  -- when result is suspended or unsuspended in correction mode,
  -- we can't compute premiums or premium credits.
  -- Tell use that they may want to manually.
  -- If in correction and esd of result is before first day of this month...
  if l_datetrack_mode = 'CORRECTION' and l_effective_start_date <
     to_date(to_char(p_effective_date, 'mm-yyyy'), 'mm-yyyy') then
     if p_sspndd_flag = 'Y' then
        ben_prem_prtt_monthly.premium_warning
          (p_person_id            => p_person_id
          ,p_prtt_enrt_rslt_id    => p_prtt_enrt_rslt_id
          ,p_effective_start_date => l_effective_start_date
          ,p_effective_date       => p_effective_date
          ,p_warning              => 'SUSPEND');
     else
        ben_prem_prtt_monthly.premium_warning
          (p_person_id            => p_person_id
          ,p_prtt_enrt_rslt_id    => p_prtt_enrt_rslt_id
          ,p_effective_start_date => l_effective_start_date
          ,p_effective_date       => p_effective_date
          ,p_warning              => 'UNSUSPEND');
     end if;
  end if;

  hr_utility.set_location('Leaving:'||l_proc, 99);
Exception
  When others then
    hr_utility.set_location('ERROR '||l_proc, 97);
    Rpt_error(p_proc => l_proc, p_last_action => l_last_place);
-- for nocopy changes
p_object_version_number := l_object_version_number ;
    fnd_message.raise_error;
End update_sspndd_flag;
--
-- =======================================================================
--                      << Suspend_enrollment >>
-- =======================================================================
--
Procedure suspend_enrollment
  (p_prtt_enrt_rslt_id       in number,
   p_effective_date          in date,
   p_post_rslt_flag          in varchar2,
   p_business_group_id       in number,
   p_object_version_number   in out nocopy number,
   p_datetrack_mode          in varchar2
  ) is
  --
  Cursor Csr_prtt_enrt_rslt is
    select pen.rplcs_sspndd_rslt_id
          ,pen.prtt_enrt_rslt_id
          ,pen.person_id
          ,pen.pgm_id
          ,pen.sspndd_flag
          ,pen.enrt_mthd_cd
          ,pen.enrt_cvg_strt_dt
          ,pen.effective_start_date
          ,pen.effective_end_date
          ,epe.prtt_enrt_rslt_id  chc_prtt_enrt_rslt_id
          ,epe.elig_per_elctbl_chc_id
          ,pen.pl_id
          ,pen.oipl_id
          ,pen.pl_typ_id
          ,pen.ler_id
          ,pen.per_in_ler_id
          ,pen.oipl_ordr_num
          ,pen.pl_ordr_num
          ,pen.bnft_amt
          ,pen.plip_ordr_num     /*ENH*/
          ,pen.bnft_ordr_num      /*ENH*/
          ,epe.dpnt_dsgn_cd
      From ben_prtt_enrt_rslt_f    pen
          ,ben_elig_per_elctbl_chc epe
          ,ben_per_in_ler pil
     where pen.prtt_enrt_rslt_id  = p_prtt_enrt_rslt_id
       and pen.business_group_id= p_business_group_id
       and pen.prtt_enrt_rslt_stat_cd is null
       and p_effective_date between
               pen.effective_start_date and pen.effective_end_date
       and pen.business_group_id = epe.business_group_id (+)
       and pen.prtt_enrt_rslt_id = epe.prtt_enrt_rslt_id (+)
       and pen.per_in_ler_id = epe.per_in_ler_id (+)
       and pil.per_in_ler_id=pen.per_in_ler_id			--Bug#5491212
       and pil.business_group_id=pen.business_group_id		--Bug#5491212
       and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
           ;
  cursor c_current_bnft (p_prtt_enrt_rslt_id number,
                         p_elig_per_elctbl_chc_id number,
                         p_bnft_ordr_num number ) is
    select enb.enrt_bnft_id
    from   ben_enrt_bnft enb
    where  enb.prtt_enrt_rslt_id=p_prtt_enrt_rslt_id
       and enb.elig_per_elctbl_chc_id=p_elig_per_elctbl_chc_id
       and enb.business_group_id=p_business_group_id
    union -- To get this when the enb is not update with the pen_id
    -- This happens in the flex enrollment if the certifications is called
    -- from flex routine /*ENH*/
    select enb.enrt_bnft_id
    from ben_enrt_bnft enb
    where
         enb.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id
     and enb.ordr_num = p_bnft_ordr_num ;

  Cursor c_new_ovn is
    select pen.object_version_number
      From ben_prtt_enrt_rslt_f    pen
     where pen.prtt_enrt_rslt_id  = p_prtt_enrt_rslt_id
       and pen.business_group_id= p_business_group_id
       and pen.prtt_enrt_rslt_stat_cd is null
       and p_effective_date between
               pen.effective_start_date and pen.effective_end_date
    ;
  Cursor c_epe (c_elig_per_elctbl_chc_id number) is
    select *
      From ben_elig_per_elctbl_chc
     Where elig_per_elctbl_chc_id = c_elig_per_elctbl_chc_id
          ;
  cursor c_prv_ee (c_prtt_enrt_rslt_id number) is
    select prv.prtt_rt_val_id
          ,prv.object_version_number
          ,prv.rt_strt_dt
          ,prv.rt_end_dt
          ,prv.rt_val
          ,prv.acty_base_rt_id
          ,prv.acty_ref_perd_cd
          ,abr.input_value_id
          ,abr.element_type_id
          ,prv.element_entry_value_id
          ,pev.effective_end_date
          ,pee.element_link_id
      from ben_prtt_rt_val            prv,
           ben_acty_base_rt_f         abr,
           pay_element_entry_values_f pev,
           pay_element_entries_f      pee
     where prv.prtt_enrt_rslt_id = c_prtt_enrt_rslt_id
       and prv.rt_end_dt=hr_api.g_eot
       and prv.business_group_id = p_business_group_id
       and prv.prtt_rt_val_stat_cd is null
       and abr.acty_base_rt_id=prv.acty_base_rt_id
       and abr.business_group_id = p_business_group_id
       and p_effective_date between
             abr.effective_start_date and abr.effective_end_date
       and pev.element_entry_value_id = prv.element_entry_value_id
       and prv.rt_strt_dt between
             pev.effective_start_date and pev.effective_end_date
       and pee.element_entry_id = pev.element_entry_id
       and prv.rt_strt_dt between
           pee.effective_start_date and pee.effective_end_date
          ;
   cursor c_pl(p_pl_id number) is
      select 'x' from ben_pl_f pl
      where pl.pl_id = p_pl_id
        and pl.SUBJ_TO_IMPTD_INCM_TYP_CD is not null
        and p_effective_date between
            pl.effective_start_date and pl.effective_end_date;
   --Bug 1998648 Cursor to get action items
   --
   cursor c_pea(p_prtt_enrt_rslt_id number) is
      select
          pea.prtt_enrt_actn_id
         ,pea.actn_typ_id
         ,pea.rqd_flag
         ,pea.business_group_id
         ,pea.object_version_number pea_object_version_number
         ,pen.object_version_number pen_object_version_number
         --START OHSU
         ,pea.effective_start_date pea_effective_date
         --END OHSU
       from ben_prtt_enrt_actn_f pea,
            ben_prtt_enrt_rslt_f pen
       where
           pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
       --START OHSU
       and p_effective_date between pen.effective_start_date and
                                    pen.effective_end_date
       --END OHSU
       and pen.prtt_enrt_rslt_id = pea.prtt_enrt_rslt_id
       and pea.rqd_flag = 'Y'
       and pen.prtt_enrt_rslt_stat_cd is null;
  --
  cursor c_interim (p_prtt_enrt_rslt_id number,
                    p_per_in_ler_id number) is
    select pen.RPLCS_SSPNDD_RSLT_ID
    from   ben_prtt_enrt_rslt_f pen
    where  pen.prtt_enrt_rslt_id  = p_prtt_enrt_rslt_id
    and    pen.sspndd_flag = 'Y'
    and    pen.per_in_ler_id = p_per_in_ler_id
    and    pen.prtt_enrt_rslt_stat_cd is null
    and    not exists
           (select null
              from ben_prtt_enrt_rslt_f pen3
             where pen3.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
               and pen3.prtt_enrt_rslt_stat_cd is null
               and pen3.effective_start_date < pen.effective_start_date
               and pen3.per_in_ler_id <> pen.per_in_ler_id)
    and    exists (select null from ben_prtt_enrt_rslt_f pen2
                   where pen2.prtt_enrt_rslt_id = pen.RPLCS_SSPNDD_RSLT_ID
                   and   pen2.prtt_enrt_rslt_stat_cd is null
                   and   pen2.per_in_ler_id = p_per_in_ler_id
                   and   pen2.enrt_cvg_thru_dt <> hr_api.g_eot
                   and   pen2.effective_end_date = hr_api.g_eot);
 --
  cursor  c_enrt_rslt (p_prtt_enrt_rslt_id number) is
      select pen.effective_start_date,
             pen.effective_end_date,
             pen.object_version_number
      from   ben_prtt_enrt_rslt_f pen
      where  pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
      and    pen.prtt_enrt_rslt_stat_cd is null
      and    pen.effective_end_date = (select pen2.effective_start_date - 1
      from   ben_prtt_enrt_rslt_f pen2
      where    pen2.enrt_cvg_thru_dt <> hr_api.g_eot
      and    pen2.effective_end_date = hr_api.g_eot
      and    pen2.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
      and    pen2.prtt_enrt_rslt_stat_cd is null);
  --
  cursor c_prv_sspndd(p_pen_id   number
                      ,cp_per_in_ler_id number) is
  select prv.rowid,
         prv.prtt_rt_val_id,
         prv.object_version_number,
         prv.acty_base_rt_id,
         prv.rt_strt_dt,
         prv.rt_end_dt,
         prv.rt_val,
         prv.ann_rt_val,
         prv.acty_ref_perd_cd
    from ben_prtt_rt_val prv
   where prv.prtt_rt_val_stat_cd is null
     and prv.prtt_enrt_rslt_id = p_pen_id
     and prv.per_in_ler_id = cp_per_in_ler_id
     and prv.rt_strt_dt =  -- for Unrestricted
              (select max(prv1.rt_strt_dt)
                 from ben_prtt_rt_val prv1
                where prv1.prtt_enrt_rslt_id = prv.prtt_enrt_rslt_id
                  and prv1.per_in_ler_id = prv.per_in_ler_id
                  and prv1.prtt_rt_val_stat_cd is null
                  and prv1.acty_base_rt_id = prv.acty_base_rt_id);
  l_prv_sspndd c_prv_sspndd%rowtype;

  cursor c_prv_rowid (p_rowid rowid) is
  select object_version_number
    from ben_prtt_rt_val
   where rowid = p_rowid;

  cursor c_prv (p_prtt_enrt_rslt_id number,
                p_per_in_ler_id     number) is
    select prv.prtt_rt_val_id,
           prv.object_version_number,
           prv.rt_end_dt,
           prv.rt_strt_dt,
           prv.per_in_ler_id,
           prv.prtt_enrt_rslt_id,
           pil.person_id
    from   ben_prtt_rt_val  prv,
           ben_per_in_ler pil
    where  prv.per_in_ler_id = p_per_in_ler_id
    and    prv.per_in_ler_id = pil.per_in_ler_id
    and    prv.prtt_rt_val_stat_cd is null
    and    prv.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
    and    prv.rt_end_dt <> hr_api.g_eot
    and    prv.rt_strt_dt = (select max(rt_strt_dt)
                             from ben_prtt_rt_val
                             where prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
                             and rt_end_dt <> hr_api.g_eot
                             and prtt_rt_val_stat_cd is null)
          ;
  --
  l_pea                  c_pea%rowtype ;
  l_imp_inc_plan         boolean:=false;
  l_dummy                varchar2(30);
  l_pen                  Csr_prtt_enrt_rslt%rowtype;
  l_epe                  c_epe%rowtype;
  l_datetrack_mode       varchar2(80);
  l_proc                 varchar2(80) := g_package||'.suspend_enrollment';
  l_last_place           varchar2(100);
  l_rplcs_sspndd_rslt_id number;
  l_interim_epe_id       number;
  l_enrt_bnft_id         number;
  l_current_enrt_bnft_id number;
  l_interim_bnft_amt     number;
  l_pea_effective_start_date date;
  l_pea_effective_end_date   date;
  l_bnft_or_option_rstrctn_cd ben_pl_f.bnft_or_option_rstrctn_cd%type;
-- for nocopy changes
 l_object_version_number number := p_object_version_number ;
 l_enrt_rslt     c_enrt_rslt%rowtype;
 l_prv           c_prv%rowtype;
 l_pre_interim   boolean;
 l_effective_start_date  date;
 l_effective_end_date    date;
 --
begin
  hr_utility.set_location ('Entering '|| l_proc, 10);
  --
  -- Check all the input parameters are not null
  --
  hr_api.mandatory_arg_error
           (p_api_name             => l_proc
           ,p_argument             => 'p_prtt_enrt_rslt_id'
           ,p_argument_value       => p_prtt_enrt_rslt_id);
  hr_api.mandatory_arg_error
           (p_api_name             => l_proc
           ,p_argument             => 'p_effective_date'
           ,p_argument_value       => p_effective_date);
  hr_api.mandatory_arg_error
           (p_api_name             => l_proc
           ,p_argument             => 'p_business_group_id'
           ,p_argument_value       => p_business_group_id);
  hr_api.mandatory_arg_error
           (p_api_name             => l_proc
           ,p_argument             => 'p_object_version_number'
           ,p_argument_value       => p_object_version_number);
  hr_api.mandatory_arg_error
           (p_api_name             => l_proc
           ,p_argument             => 'p_datetrack_mode'
           ,p_argument_value       => p_datetrack_mode);
  --
  -- ** Open result cursor.
  l_last_place := 'Fetching record from ben_prtt_enrt_rslt_f';
  Open  Csr_prtt_enrt_rslt;
  Fetch Csr_prtt_enrt_rslt Into l_pen;
  If Csr_prtt_enrt_rslt%NOTFOUND Then
    Close Csr_prtt_enrt_rslt;
    hr_utility.set_location('BEN_91493_PEN_NOT_FOUND', 55);
    fnd_message.set_name('BEN','BEN_91493_PEN_NOT_FOUND');
    fnd_message.raise_error;
  End If;
  Close Csr_prtt_enrt_rslt;
  --bug#4172569 - if the comp object is already suspended then return
  --if more than one required action item then this procedure is called more
  --than one time
  if l_pen.sspndd_flag = 'Y' then
    hr_utility.set_location('Comp Object already suspended',56);
    hr_utility.set_location('Leaving '||l_proc,57);
    return;
  end if;
  --
  if l_pen.prtt_enrt_rslt_id is not null then
    open c_current_bnft(l_pen.prtt_enrt_rslt_id,l_pen.elig_per_elctbl_chc_id,
                        l_pen.bnft_ordr_num );
    fetch c_current_bnft into l_current_enrt_bnft_id;
    close c_current_bnft;
  end if;
  --
  -- ** Get corrected datetrack mode
  If (p_effective_date = l_pen.effective_start_date) Then
    l_datetrack_mode  := 'CORRECTION';
  Else
    l_datetrack_mode  := p_datetrack_mode;
  End If;
  --
  l_rplcs_sspndd_rslt_id := NULL;
  l_enrt_bnft_id:=null;
  l_interim_epe_id:=null;
  --
  --buG#3659657
  open c_interim (l_pen.prtt_enrt_rslt_id,l_pen.per_in_ler_id);
  fetch c_interim into l_rplcs_sspndd_rslt_id;
  close c_interim;
  --
  hr_utility.set_location ('Suspended result id'||l_pen.prtt_enrt_rslt_id,11);
  hr_utility.set_location ('interim result id'||l_rplcs_sspndd_rslt_id,12);
  if l_rplcs_sspndd_rslt_id is not null then
    l_pre_interim := true;
  else
    l_pre_interim := false;
  end if;
  -- Determine the interim id
  --
  if not l_pre_interim then
    --
     Determine_interim
          (p_elig_per_elctbl_chc_id  => l_pen.elig_per_elctbl_chc_id
          ,p_prtt_enrt_rslt_id       => p_prtt_enrt_rslt_id
          ,p_enrt_bnft_id            => l_current_enrt_bnft_id   /*ENH*/
          ,p_interim_elctbl_chc_id   => l_interim_epe_id
          ,p_interim_enrt_bnft_id    => l_enrt_bnft_id
          ,p_interim_enrt_rslt_id    => l_rplcs_sspndd_rslt_id
          ,p_person_id               => l_pen.person_id
          ,p_ler_id                  => l_pen.ler_id
          ,p_per_in_ler_id           => l_pen.per_in_ler_id
          ,p_pl_id                   => l_pen.pl_id
          ,p_pgm_id                  => l_pen.pgm_id      /* Bug 4256836 */
          ,p_pl_typ_id               => l_pen.pl_typ_id
          ,p_oipl_id                 => l_pen.oipl_id
          ,p_pl_ordr_num             => l_pen.pl_ordr_num
          ,p_oipl_ordr_num           => l_pen.oipl_ordr_num
          ,p_plip_ordr_num           => l_pen.plip_ordr_num     /*ENH*/
          ,p_bnft_ordr_num           => l_pen.bnft_ordr_num      /*ENH*/
          ,p_business_group_id       => p_business_group_id
          ,p_effective_date          => p_effective_date
          ,p_interim_bnft_amt        => l_interim_bnft_amt
          ,p_bnft_or_option_rstrctn_cd => l_bnft_or_option_rstrctn_cd
          );
  end if;
  hr_utility.set_location(' p_prtt_enrt_rslt_id '||p_prtt_enrt_rslt_id ,1234);
  hr_utility.set_location(' l_rplcs_sspndd_rslt_id '||l_rplcs_sspndd_rslt_id,1234);
  hr_utility.set_location(' l_pen.bnft_amt '||l_pen.bnft_amt,1234);
  hr_utility.set_location(' l_interim_bnft_amt '||l_interim_bnft_amt,1234);
  hr_utility.set_location(' l_current_enrt_bnft_id '||l_current_enrt_bnft_id,1234);
  hr_utility.set_location(' g_enb '||ben_election_information.g_enrt_bnft_id,1234);
  hr_utility.set_location(' l_enrt_bnft_id '||l_enrt_bnft_id,1234);
  hr_utility.set_location(' l_pen.elig_per_elctbl_chc_id '||l_pen.elig_per_elctbl_chc_id,1234);
  hr_utility.set_location(' l_interim_epe_id '||l_interim_epe_id,1234);
  --
  /*ENH
  if ( p_prtt_enrt_rslt_id<>nvl(l_rplcs_sspndd_rslt_id,-1) or
       nvl(ben_election_information.g_enrt_bnft_id,-1) <> nvl(l_enrt_bnft_id,-1) or
      --         nvl(l_current_enrt_bnft_id,-1)<>nvl(l_enrt_bnft_id,-1) or   Bug 1886183
       nvl(l_pen.bnft_amt,0)<>nvl(l_interim_bnft_amt,0))
       and ( l_pen.elig_per_elctbl_chc_id <> nvl(l_interim_epe_id,-1) -- Bug 1886183
             or l_bnft_or_option_rstrctn_cd = 'BNFT')  then  --1998648
      --     or       l_pen.dpnt_dsgn_cd is not null then
  */
  --
  if ( p_prtt_enrt_rslt_id <> nvl(l_rplcs_sspndd_rslt_id,-1) or
      nvl(l_current_enrt_bnft_id,-1)<>nvl(l_enrt_bnft_id,-1) or
      nvl(l_pen.bnft_amt,0)<>nvl(l_interim_bnft_amt,0)
     )
     and
     ( l_pen.elig_per_elctbl_chc_id <> nvl(l_interim_epe_id,-1) or
       ( l_pen.elig_per_elctbl_chc_id = nvl(l_interim_epe_id,-1) and
         l_bnft_or_option_rstrctn_cd = 'BNFT'
       ) or
        l_interim_epe_id is null -- No Interim Created But needs to be suspended
     )
  then
    --
    hr_utility.set_location('interim epe='||l_interim_epe_id,1066);
    hr_utility.set_location('suspended epe='||l_pen.elig_per_elctbl_chc_id,1066);
    --
    if l_interim_epe_id is not null then
      --
      -- the following two lines will cause a new result to be always written
      -- but this causes certifications not to be carried over because
      -- benactcm logic requires result_id not to change.
      -- also line below process_interim to null out the global too.
      --
      --        ben_election_information.g_elig_per_elctbl_chc_id:=
      --          l_pen.elig_per_elctbl_chc_id;
      --Bug 4422667
      g_interim_flag := 'Y';
      --
      -- bug 6337803
      g_sspnded_rslt_id := p_prtt_enrt_rslt_id;
      hr_utility.set_location('p_prtt_enrt_rslt_id '|| p_prtt_enrt_rslt_id ,1212);
      hr_utility.set_location('g_sspnded_rslt_id  '|| g_sspnded_rslt_id  ,1212);
      process_interim
          (p_elig_per_elctbl_chc_id  => l_interim_epe_id
          ,p_prtt_enrt_rslt_id       => l_rplcs_sspndd_rslt_id
          ,p_enrt_bnft_id            => l_enrt_bnft_id
          ,p_bnft_amt                => l_interim_bnft_amt
          ,p_business_group_id       => p_business_group_id
          ,p_effective_date          => p_effective_date
          ,p_enrt_mthd_cd            => l_pen.enrt_mthd_cd );
      --
      g_interim_flag := 'N';
      -- 6337803 unsetting the pen id to be suspended
      ben_sspndd_enrollment.g_sspnded_rslt_id := null;

      --
      --        ben_election_information.g_elig_per_elctbl_chc_id:=null;

      if p_prtt_enrt_rslt_id=l_rplcs_sspndd_rslt_id then
          --
          -- get the updated ovn
          --
          open c_new_ovn;
          fetch c_new_ovn into p_object_version_number;
          close c_new_ovn;
      end if;
    End if;
    -- ** Update suspend flag on prtt_enrt_rslt_f to Y
    l_last_place := 'Calling update_sspndd_flag to update sspndd flag';
    open c_new_ovn;
    fetch c_new_ovn into p_object_version_number;
    close c_new_ovn;
    update_sspndd_flag
      (p_prtt_enrt_rslt_id         => p_prtt_enrt_rslt_id
       ,p_effective_date            => p_effective_date
        ,p_business_group_id         => p_business_group_id
        ,p_enrt_cvg_strt_dt          => l_pen.enrt_cvg_strt_dt
        ,p_sspndd_flag               => 'Y'
        ,p_RPLCS_SSPNDD_RSLT_ID      => l_rplcs_sspndd_rslt_id
        ,p_object_version_number     => p_object_version_number
        ,p_datetrack_mode            => l_datetrack_mode
        ,p_person_id                 => l_pen.person_id
      );

    --
    -- Delete element entry and De-link prv
    --
    open c_prv_sspndd(p_prtt_enrt_rslt_id,l_pen.per_in_ler_id);
    loop
       fetch c_prv_sspndd into l_prv_sspndd;
       if c_prv_sspndd%notfound then
          exit;
       end if;

       ben_element_entry.end_enrollment_element
       (p_business_group_id        => p_business_group_id
       ,p_person_id                => l_pen.person_id
       ,p_enrt_rslt_id             => p_prtt_enrt_rslt_id
       ,p_acty_ref_perd            => l_prv_sspndd.acty_ref_perd_cd
       ,p_element_link_id          => null
       ,p_prtt_rt_val_id           => l_prv_sspndd.prtt_rt_val_id
       ,p_rt_end_date              => l_prv_sspndd.rt_strt_dt-1
       ,p_effective_date           => l_prv_sspndd.rt_strt_dt
       ,p_dt_delete_mode           => null
       ,p_acty_base_rt_id          => l_prv_sspndd.acty_base_rt_id
       ,p_amt                      => l_prv_sspndd.rt_val
       );
       --
       --fetch prv ovn again just incase prv got updated in the above call
       --
       open c_prv_rowid(l_prv_sspndd.rowid);
       fetch c_prv_rowid into l_prv_sspndd.object_version_number;
       close c_prv_rowid;

       ben_prtt_rt_val_api.update_prtt_rt_val
       (p_validate                => false
       ,p_business_group_id       => p_business_group_id
       ,p_prtt_rt_val_id          => l_prv_sspndd.prtt_rt_val_id
       ,p_element_entry_value_id  => null
       ,p_object_version_number   => l_prv_sspndd.object_version_number
       ,p_effective_date          => l_prv_sspndd.rt_strt_dt
       );

    end loop;
    close c_prv_sspndd;


    ben_provider_pools.remove_bnft_prvdd_ldgr
        (p_prtt_enrt_rslt_id  => p_prtt_enrt_rslt_id
        ,p_effective_date     => p_effective_date
        ,p_business_group_id  => p_business_group_id
        ,p_validate           => FALSE
        ,p_datetrack_mode     => 'ZAP'
    );


    l_last_place := 'Calling the Post-Result RCO';
    If p_post_rslt_flag = 'Y' Then
      -- Bug 4622534
      if g_cfw_dpnt_flag = 'N' THEN
        --
        ben_prtt_enrt_result_api.multi_rows_edit
          (p_person_id               => l_pen.person_id
          ,p_effective_date          => p_effective_date
          ,p_business_group_id       => p_business_group_id
          ,p_pgm_id                  => l_pen.pgm_id
          ,p_per_in_ler_id           => l_pen.per_in_ler_id
        );
        ben_proc_common_enrt_rslt.process_post_results
          (p_person_id               => l_pen.person_id
          ,p_enrt_mthd_cd            => l_pen.enrt_mthd_cd
          ,p_effective_date          => p_effective_date
          ,p_business_group_id       => p_business_group_id
          ,p_per_in_ler_id           => l_pen.per_in_ler_id
        );
      end if;
      --
    else
      -- check if it's an imputed income plan
      open c_pl(l_pen.pl_id);
      fetch c_pl into l_dummy;
      if c_pl%FOUND then
        l_imp_inc_plan := true;
      end if;
      close c_pl;
      if l_imp_inc_plan then
        ben_det_imputed_income.p_comp_imputed_income
        (p_person_id            => l_pen.person_id
        ,p_enrt_mthd_cd         => l_pen.enrt_mthd_cd
        ,p_per_in_ler_id        => l_pen.per_in_ler_id
        ,p_effective_date       => p_effective_date
        ,p_business_group_id    => p_business_group_id
        ,p_ctrlm_fido_call      => false
        ,p_validate             => false);
      end if;
    End if;
    --
    -- reopen the interim result and the rates after suspending to avoid
    --element entry error

    if l_pre_interim then
      --
      open c_enrt_rslt(l_rplcs_sspndd_rslt_id);
      fetch c_enrt_rslt into l_enrt_rslt;
      close c_enrt_rslt;
      --
      if l_enrt_rslt.effective_start_date is not null then
           ben_prtt_enrt_result_api.delete_prtt_enrt_result
            (p_validate                => false,
             p_prtt_enrt_rslt_id       => l_rplcs_sspndd_rslt_id,
             p_effective_start_date    => l_effective_start_date,
             p_effective_end_date      => l_effective_end_date,
             p_object_version_number   => l_enrt_rslt.object_version_number,
             p_effective_date          => l_enrt_rslt.effective_end_date,
             p_datetrack_mode          => hr_api.g_future_change,
             p_multi_row_validate      => FALSE);
         --
         open c_prv(l_rplcs_sspndd_rslt_id, l_pen.per_in_ler_id);
         loop
           fetch c_prv into l_prv;
           if c_prv%notfound then
              exit;
           end if;
           ben_prtt_rt_val_api.update_prtt_rt_val
                  (p_validate               => FALSE
                  ,p_prtt_rt_val_id         => l_prv.prtt_rt_val_id
                  ,p_object_version_number  => l_prv.object_version_number
                  ,p_rt_end_dt              => hr_api.g_eot
                  ,p_prtt_rt_val_stat_cd    => null
                  ,p_ended_per_in_ler_id    => null
                  ,p_person_id              => l_prv.person_id
                  ,p_business_group_id      => p_business_group_id
                  ,p_effective_date         => p_effective_date);
         end loop;
         close c_prv;
      end if;
      --
    end if;
    --
  elsif l_pen.elig_per_elctbl_chc_id = nvl(l_interim_epe_id,-1)  then
    --
    open c_pea(p_prtt_enrt_rslt_id) ;
    loop
    fetch c_pea into l_pea ;
    if c_pea%notfound then  exit ;
    end if;
    --
    hr_utility.set_location('Updating the Required Flag to No ',5);
    hr_utility.set_location('Before Entering ben_prtt_enrt_actn_api.update_prtt_enrt_actn ' ,10);
    ben_prtt_enrt_actn_api.update_prtt_enrt_actn
    (    p_prtt_enrt_actn_id          => l_pea.prtt_enrt_actn_id
        ,p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
        ,p_rslt_object_version_number => l_pea.pen_object_version_number
        ,p_actn_typ_id                => l_pea.actn_typ_id
        ,p_rqd_flag                   => 'N'
       --START OHSU
       -- ,p_effective_date             => p_effective_date
        ,p_effective_date             => l_pea.pea_effective_date
       --END OHSU
        ,p_post_rslt_flag             => p_post_rslt_flag
        ,p_business_group_id          => p_business_group_id
        ,p_effective_start_date       => l_pea_effective_start_date
        ,p_effective_end_date         => l_pea_effective_end_date
        ,p_object_version_number      => l_pea.pea_object_version_number
        ,p_datetrack_mode             => hr_api.g_correction
    );
    hr_utility.set_location('After ben_prtt_enrt_actn_api.update_prtt_enrt_actn ',20);
    --
    end loop ;
    close c_pea ;
    --
  End If;
  hr_utility.set_location('Leaving:'||l_proc, 10);
Exception
  When others then
    hr_utility.set_location('ERROR '||l_proc, 96);
    rpt_error(p_proc => l_proc, p_last_action => l_last_place);
-- for nocopy changes
p_object_version_number := l_object_version_number ;
    fnd_message.raise_error;
End suspend_enrollment;
--
--
-- ==========================================================================+
--                         << Unsuspend Enrollment >>                        +
--                                                                           +
-- ==========================================================================+
--
procedure unsuspend_enrollment
            (p_prtt_enrt_rslt_id     in     number
            ,p_effective_date        in     date
            ,p_per_in_ler_id         in     number
            ,p_post_rslt_flag        in     varchar2
            ,p_business_group_id     in     number
            ,p_object_version_number in out nocopy number
            ,p_datetrack_mode        in     varchar2
            ,p_called_from           in     varchar2 default 'BENSUENR'
            ,p_cmpltd_dt             in     date default null
            ) is
  --
  l_proc                   varchar2(80) := g_package||'.unsuspend_enrollment';
  l_last_place             varchar2(80);
  l_datetrack_mode         varchar2(80);
  l_interim_del            Boolean  default FALSE;
  l_interim_upd            Boolean  default FALSE;
  l_ee_end_date            date;
  l_ler_id                 number;
  l_per_in_ler_id          number;
  l_lf_evt_ocrd_dt         date;
  l_lee_rsn_id             number;
  l_enrt_perd_id           number;
  l_unsspnd_enrt_cd        varchar2(30);
  l_rec_rt_strt_dt         date;
  l_rec_rt_end_dt          date;
  l_elig_per_elctbl_chc_id number;
  l_update_dates           boolean := false;
  --
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
  --
  l_dpnt_cvg_strt_dt      date;
  l_dpnt_cvg_end_dt       date;
  l_dpnt_cvg_strt_dt_cd   varchar2(30);
  l_dpnt_cvg_strt_dt_rl   number;
  l_dpnt_cvg_end_dt_cd    varchar2(30);
  l_dpnt_cvg_end_dt_rl    number;
  l_decr_bnft_prvdr_pool_id number;
  l_bnft_prvdd_ldgr_id    number;
  --
  -- Added for Bug fix 2689926
  --
  l_prtt_enrt_rslt_id	  number ;
  l_prtt_rt_val_id	  number ;
  l_acty_ref_perd_cd	  varchar2(30) ;
  l_acty_base_rt_id 	  number ;
  l_rt_strt_dt1      	  date ;
  l_rt_val          	  number ;
  l_element_type_id 	  number ;
  --
  -- End Bug fix 2689926
  --
  l_carry_forward              varchar2(1) := 'N';
-- for nocopy changes
 l_object_version_number number := p_object_version_number ;
  --
  -- Added for bug
  --
  l_epe                        ben_epe_shd.g_rec_type;
  --
  Cursor Csr_prtt_enrt_rslt (c_rslt_id  Number) is
    Select pen.rplcs_sspndd_rslt_id
          ,pen.prtt_enrt_rslt_id
          ,pen.per_in_ler_id
          ,pen.enrt_cvg_strt_dt
          ,pen.enrt_cvg_thru_dt
          ,pen.person_id
          ,pen.pgm_id
          ,pen.sspndd_flag
          ,pen.effective_start_date
          ,pen.effective_end_date
          ,pen.enrt_mthd_cd
          ,pen.object_version_number
          ,pen.pl_id
          ,pen.oipl_id
          ,pen.ptip_id
          ,pln.ENRT_PL_OPT_FLAG
          ,pen.business_group_id
          ,'USEEFD'     calc_cvg_strt_dt_cd
          ,'USE1BSEFD'  calc_cvg_end_dt_cd
      From ben_prtt_enrt_rslt_f pen
          ,ben_pl_f pln
     Where pen.prtt_enrt_rslt_id = c_rslt_id
       And pen.business_group_id = p_business_group_id
       and pen.prtt_enrt_rslt_stat_cd is null
       And p_effective_date between
             pen.effective_start_date and
             pen.effective_end_date
       And pen.pl_id = pln.pl_id
       And pen.business_group_id = pln.business_group_id
       And p_effective_date between
             pln.effective_start_date and
             pln.effective_end_date
          ;
   cursor c_pl(p_pl_id number) is
      select 'x' from ben_pl_f pl
      where pl.pl_id = p_pl_id
        and pl.SUBJ_TO_IMPTD_INCM_TYP_CD is not null
        and p_effective_date between
            pl.effective_start_date and pl.effective_end_date;
  l_imp_inc_plan         boolean:=false;
  l_dummy                varchar2(30);
  l_pen              csr_prtt_enrt_rslt%rowtype;
  l_interim          csr_prtt_enrt_rslt%rowtype;
  l_cvg_thru_dt      date;
  --
  cursor c_choice_info(c_prtt_enrt_rslt_id number) is
    select epe.elig_per_elctbl_chc_id,
           pel.lee_rsn_id,
           pel.enrt_perd_id,
           --START Bug 2958032
           epe.prtt_enrt_rslt_id,
           epe.object_version_number
           --END Bug 2958032
    from   ben_prtt_enrt_rslt_f pen,
           ben_pil_elctbl_chc_popl pel,
           ben_per_in_ler pil,
           ben_elig_per_elctbl_chc epe
    where  pen.prtt_enrt_rslt_id=c_prtt_enrt_rslt_id
       and p_effective_date between
           pen.effective_start_date and pen.effective_end_date
       and pen.person_id=pil.person_id
       and epe.pl_id=pen.pl_id
       and nvl(epe.oipl_id,-1)=nvl(pen.oipl_id,-1)
       and nvl(epe.pgm_id,-1)=nvl(pen.pgm_id,-1)
       and epe.per_in_ler_id = l_per_in_ler_id
       and epe.business_group_id=p_business_group_id
       -- and epe.elctbl_flag = 'Y' -- Bug 2958032 CF BUG 4064635
       and pel.pil_elctbl_chc_popl_id=epe.pil_elctbl_chc_popl_id
       and pel.business_group_id=p_business_group_id
       and pil.per_in_ler_id=epe.per_in_ler_id
       and pil.business_group_id=epe.business_group_id
      and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
      and pen.prtt_enrt_rslt_stat_cd is null
  ;
  ----Bug 7557403
  cursor c_fonm_check(p_epe_id number) is
   select epe.fonm_cvg_strt_dt
     from ben_elig_per_elctbl_chc epe
    where epe.elig_per_elctbl_chc_id = p_epe_id
      and epe.business_group_id=p_business_group_id;

  l_fonm_check c_fonm_check%rowtype;
  cursor c_get_enrt_rt(p_elig_per_elctbl_chc_id number) is
   select ecr.*
      from ben_enrt_rt ecr
     where ecr.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id
       and ecr.business_group_id = p_business_group_id
  union
    select ecr.*
      from ben_enrt_rt ecr
          ,ben_enrt_bnft enb
     where enb.enrt_bnft_id = ecr.enrt_bnft_id
       and ecr.business_group_id = p_business_group_id
       and enb.business_group_id = p_business_group_id
       and enb.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id;
  l_get_enrt_rt   c_get_enrt_rt%rowtype;
  ----Bug 7557403
  cursor c_enrt(p_elig_per_elctbl_chc_id   number,
                p_acty_base_rt_id          number) is
  select ecr.*
    from ben_enrt_rt ecr
   where elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id
     and acty_base_rt_id = p_acty_base_rt_id;
  l_enrt_rt c_enrt%rowtype;

  --
  -- restict prv's to update to those which are not ended
  --
  cursor c_prv (c_prtt_enrt_rslt_id number) is
    select prv.*
          ,abr.input_value_id
          ,abr.element_type_id
      from ben_prtt_rt_val prv,
           ben_acty_base_rt_f abr
     where prv.prtt_enrt_rslt_id = c_prtt_enrt_rslt_id
       and prv.per_in_ler_id = l_per_in_ler_id
       and prv.rt_strt_dt <= prv.rt_end_dt
       -- and prv.rt_end_dt=hr_api.g_eot
       and prv.business_group_id = p_business_group_id
       and prv.prtt_rt_val_stat_cd is null
       and abr.acty_base_rt_id=prv.acty_base_rt_id
       and abr.business_group_id = p_business_group_id
       and p_effective_date between
             abr.effective_start_date and abr.effective_end_date
          ;
  --
  -- bug 2330694 - to delete/end-date premiums corresponding to interim
  -- 		   coverage once this the interim is deleted / coverage ended.
  --
  --3278908  APP 07115 Errir
  l_ppe_effective_date       date;
  --
  ----
  /*  bug 3666347 reverted the fix
  cursor c_ppe (c_prtt_enrt_rslt_id number) is
    select ppe.prtt_prem_id,
           ppe.object_version_number
      from ben_prtt_prem_f ppe,
           ben_actl_prem_f apr
     where ppe.prtt_enrt_rslt_id = c_prtt_enrt_rslt_id
       and ppe.per_in_ler_id = l_per_in_ler_id
       and ppe.business_group_id = p_business_group_id
       and ppe.actl_prem_id = apr.actl_prem_id
       and apr.business_group_id = p_business_group_id
       and l_ppe_effective_date between -- p_effective_date between  ----3278908
       		apr.effective_start_date and apr.effective_end_date
       --Added for 3278908
       and l_ppe_effective_date between
                ppe.effective_start_date and ppe.effective_end_date
       	;
  */
  l_ppe_effective_start_date date;
  l_ppe_effective_end_date   date;
  -- l_ppe_effective_date       date;
  l_ppe_datetrack_mode	     varchar2(80);
  --
  -- end fix 2330694
  --
  cursor c_ee (p_element_entry_value_id number,p_rt_strt_dt date) is
    select pev.effective_end_date
      from pay_element_entry_values_f pev,
           pay_element_entries_f      pee
     where pev.element_entry_value_id = p_element_entry_value_id
       and p_rt_strt_dt between
             pev.effective_start_date and pev.effective_end_date
       and pee.element_entry_id = pev.element_entry_id
       and p_rt_strt_dt between
           pee.effective_start_date and pee.effective_end_date
          ;
  Cursor c_dpnt (c_prtt_enrt_rslt_id number) is
    select ecd.elig_cvrd_dpnt_id
          ,ecd.effective_start_date
          ,ecd.effective_end_date
          ,ecd.cvg_strt_dt
          ,ecd.cvg_thru_dt
          ,ecd.object_version_number
     From ben_elig_cvrd_dpnt_f ecd,
          ben_per_in_ler pil
    Where ecd.prtt_enrt_rslt_id = c_prtt_enrt_rslt_id
      and ecd.cvg_strt_dt is not null
      and ecd.cvg_thru_dt = hr_api.g_eot
      and ecd.business_group_id = p_business_group_id
      and p_effective_date between
            ecd.effective_start_date and ecd.effective_end_date
      and pil.per_in_ler_id=ecd.per_in_ler_id
      and pil.business_group_id=ecd.business_group_id
      and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
    ;
  --
  cursor c_per_in_ler_info is
          select pil.lf_evt_ocrd_dt,
                 pil.ler_id
          from   ben_per_in_ler pil
          where  pil.per_in_ler_id=l_per_in_ler_id and
                 pil.business_group_id=p_business_group_id;
  --
  -- RCHASE added PLIP join for unsspnd enrt cd setup at plip level
  cursor c_unsspnd_enrt_cd is
    select nvl(lbr.unsspnd_enrt_cd,
                nvl(pl.unsspnd_enrt_cd, plip.unsspnd_enrt_cd))
    from   ben_ler_bnft_rstrn_f lbr,
           ben_pl_f pl,
           ben_plip_f plip
    where
           pl.pl_id=l_pen.pl_id
      and  plip.pl_id(+)=pl.pl_id
      and  nvl(plip.pgm_id,l_pen.pgm_id)=l_pen.pgm_id
      and  pl.business_group_id = p_business_group_id
      and  nvl(l_lf_evt_ocrd_dt,p_effective_date)
             between pl.effective_start_date
             and     pl.effective_end_date
      and  nvl(l_lf_evt_ocrd_dt,p_effective_date)
             between plip.effective_start_date(+)
             and     plip.effective_end_date(+)
      -- get ler_bnft_rstrn_f if exists
      and  lbr.pl_id(+)=pl.pl_id
      and  lbr.ler_id(+)=l_ler_id
      and  lbr.business_group_id(+) = p_business_group_id
      and  nvl(l_lf_evt_ocrd_dt,p_effective_date)
             between lbr.effective_start_date(+)
             and     lbr.effective_end_date(+)
    ;
  --
  --
  cursor c_enrt_rt (p_prtt_rt_val_id number) is
     select decr_bnft_prvdr_pool_id
     from   ben_enrt_rt
     where  prtt_rt_val_id = p_prtt_rt_val_id;
  --
  --Bug 2958032 Get the benefit record of the unsuspended enrollment result
  --Update the enb to remove penid from the interim row
  cursor c_enb(p_prtt_enrt_rslt_id number,
               p_elig_per_elctbl_chc_id number) is
    select enb.enrt_bnft_id,
           enb.object_version_number
    from ben_enrt_bnft enb
    where enb.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id
    and enb.prtt_enrt_rslt_id is not null
    and enb.prtt_enrt_rslt_id  <> p_prtt_enrt_rslt_id ;
  --
  -- update the enb if there is not pen_id or pen_id is not the right one
  cursor c_enrt_bnft(p_prtt_enrt_rslt_id number,
                     p_elig_per_elctbl_chc_id number,
                     p_effective_date date) is
    select enb.enrt_bnft_id,
           enb.object_version_number
    from ben_prtt_enrt_rslt_f pen,
         ben_enrt_bnft enb
    where pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
    and p_effective_date between pen.effective_start_date and pen.effective_end_date
    and pen.bnft_ordr_num = enb.ordr_num
    and enb.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id
    and nvl(enb.prtt_enrt_rslt_id,p_prtt_enrt_rslt_id) <> p_prtt_enrt_rslt_id
    and pen.prtt_enrt_rslt_stat_cd is null;
  --
  -- bug#3202455 - determine whether unsuspend is on account of some user error
  cursor c_previous_status is
    select null
    from ben_prtt_enrt_rslt_f pen
    where pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
    and   pen.sspndd_flag = 'N'
    and   pen.per_in_ler_id <> l_per_in_ler_id
    and   pen.prtt_enrt_rslt_stat_cd is null;
  --
  -- 6054988 : Check if any elections have been made in the current pil.
  --
  cursor chk_elcn_dt_in_pel is
   SELECT 'x'
   FROM ben_pil_elctbl_chc_popl popl, ben_prtt_enrt_rslt_f pen
   WHERE popl.per_in_ler_id = l_per_in_ler_id
   AND popl.elcns_made_dt IS NULL
   AND popl.dflt_asnd_dt IS NULL
   AND popl.pgm_id = pen.pgm_id
   AND pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
   AND pen.per_in_ler_id = popl.per_in_ler_id
   AND prtt_enrt_rslt_stat_cd IS NULL;
  l_var          varchar2(30);
  --
  -- End 6054988
  --
  l_dummy_number number;
  l_unsusp_cvg_start_date    date default null ;
  --
  --START Bug 2958032
  l_epe_prtt_enrt_rslt_id      number(15);
  l_epe_object_version_number  number(9);
  l_enrt_bnft_id               number(15);
  l_enb_object_version_number  number(15);
  l_previous_no_sspn           boolean := false ;
  --END Bug 2958032
Begin
  hr_utility.set_location('Entering:'||l_proc, 05);
  hr_utility.set_location('p_prtt_enrt_rslt_id:'||to_char(p_prtt_enrt_rslt_id), 05);
  hr_utility.set_location('p_per_in_ler_id:'||p_per_in_ler_id, 05);

  --
  -- Check all the input parameters are not null
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'p_prtt_enrt_rslt_id',
                             p_argument_value => p_prtt_enrt_rslt_id);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'p_effective_date',
                             p_argument_value => p_effective_date);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'p_business_group_id',
                             p_argument_value => p_business_group_id);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'p_object_version_number',
                             p_argument_value => p_object_version_number);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'p_datetrack_mode',
                             p_argument_value => p_datetrack_mode);
  --
  l_last_place := 'Fetching record from ben_prtt_enrt_rslt_f';
  --
  -- Get the needed result info
  --
  Open  Csr_prtt_enrt_rslt(p_prtt_enrt_rslt_id);
  Fetch Csr_prtt_enrt_rslt Into l_pen;
  If Csr_prtt_enrt_rslt%NOTFOUND Then
    Close Csr_prtt_enrt_rslt;
    hr_utility.set_location('BEN_91493_PEN_NOT_FOUND ID:'|| to_char(p_prtt_enrt_rslt_id), 65);
    fnd_message.set_name('BEN','BEN_91493_PEN_NOT_FOUND');
    fnd_message.raise_error;
  End If;
  Close Csr_prtt_enrt_rslt;
  --
  if p_per_in_ler_id is not null then
     --
     l_per_in_ler_id := p_per_in_ler_id;
     --
  else
     --
     l_per_in_ler_id := l_pen.per_in_ler_id;
     --
  end if;
  if p_per_in_ler_id <> l_pen.per_in_ler_id then
     l_carry_forward := 'Y';
  end if;
  hr_utility.set_location('l_carry_forward '||l_carry_forward, 10);
  --
  -- Get the info on the per_in_ler if it exists
  --
  hr_utility.set_location('past Csr_prtt_enrt_rslt', 10);
  hr_utility.set_location('per in ler id '||l_per_in_ler_id, 10);

  open c_per_in_ler_info;
  fetch c_per_in_ler_info into
    l_lf_evt_ocrd_dt,
    l_ler_id;
  close c_per_in_ler_info;
  hr_utility.set_location('past c_per_in_ler_info', 10);
  --
  --bug#3202455
  open c_previous_status;
  fetch c_previous_status into l_dummy;
  if c_previous_status%found then
     l_previous_no_sspn := true;
     hr_utility.set_location('l_previous_no_sspn',11);
  end if;
  close c_previous_status;
  If (nvl(l_pen.sspndd_flag, 'X') <> 'N' ) then
    --
    -- ======================================================================
    --
    -- Case 1,2,3 : Suspended enrollment is started
    --
    --   Case 1:    Suspended enrollment coverage started and interim started as
    --              well.
    --   Case 2:    Suspended enrollment coverage started but interim not.
    --
    --   Case 3:    Suspended enrollment started and it has not interim cvg.
    --
    -- Case 4,5,6 : Suspended enrollment is not started yet
    --
    --   Case 4:    Suspended enrollment coverage is not started yet but interim
    --              started.
    --   Case 5:    Suspended enrollment coverage is not started yet and interim
    --              not started neither.
    --   Case 6:    Suspended enrollment is not started yet and it has not
    --              interim cvg.
    --
    -- ======================================================================
    --
    -- This next section decides what to do to the interim enrollment
    --
    If (l_pen.rplcs_sspndd_rslt_id is not NULL) then
      Open  Csr_prtt_enrt_rslt(l_pen.rplcs_sspndd_rslt_id);
      Fetch Csr_prtt_enrt_rslt Into l_interim;
      --
      -- To allow continuing the enrollment process, incase if the user deletes interim.
      --
      --
      If Csr_prtt_enrt_rslt%FOUND Then
        If ( nvl(p_cmpltd_dt,p_effective_date) >= l_interim.enrt_cvg_strt_dt ) then
	   -- Bug 8488400 : Added nvl(p_cmpltd_dt,p_effective_date) to the if condition

	  -- ** Case 1+4: suspended and interim both coverage been started
          l_interim_upd := TRUE;
        Else
          -- ** Case 2+5: suspended started but interim not.
          l_interim_del := TRUE;
        End if;
      End if;
      Close Csr_prtt_enrt_rslt;
    End if;
    --
    -- This section is handle interim coverage.  For delete, delete enrollment
    -- will handle it automatically, but for update, we need need to prtt_rate
    -- val and dpnt_cvg rate/coverage end date handle correctly.
    --
    If (l_interim_del) then
      l_last_place := 'Calling Delete Enrollment';
      ben_prtt_enrt_result_api.delete_enrollment
        (P_VALIDATE              => FALSE
        ,P_PRTT_ENRT_RSLT_ID     => l_interim.prtt_enrt_rslt_id
        ,p_per_in_ler_id         => p_per_in_ler_id
        ,P_BUSINESS_GROUP_ID     => p_business_group_id
        ,P_EFFECTIVE_START_DATE  => l_interim.effective_start_date
        ,P_EFFECTIVE_END_DATE    => l_interim.effective_end_date
        ,P_OBJECT_VERSION_NUMBER => l_interim.object_version_number
        ,P_EFFECTIVE_DATE        => p_effective_date
        ,P_DATETRACK_MODE        => hr_api.g_delete
        ,P_MULTI_ROW_VALIDATE    => FALSE
        ,p_source                => 'bensuenr'
         );
    End if;
    If (l_interim_upd) then
      --
      -- These dated need to be recalculated bases on the Unsuspend code used.
      -- Interim coverage end date.
        --
        if l_carry_forward = 'N' then --CFW
           open c_unsspnd_enrt_cd;
           fetch c_unsspnd_enrt_cd into l_unsspnd_enrt_cd;
           if c_unsspnd_enrt_cd%notfound or l_unsspnd_enrt_cd is null then
             l_unsspnd_enrt_cd:='ACD';
           end if;
           close c_unsspnd_enrt_cd;
        else
          l_unsspnd_enrt_cd:='ACD';
        end if;
        hr_utility.set_location('past c_unsspnd_enrt_cd', 10);
        --
        -- need choice info to recalc dates
        --
        open c_choice_info(p_prtt_enrt_rslt_id);
        fetch c_choice_info into
          l_elig_per_elctbl_chc_id,
          l_lee_rsn_id,
          l_enrt_perd_id,
          --START Bug 2958032
          l_epe_prtt_enrt_rslt_id,
          l_epe_object_version_number ;
          --END Bug 2958032
        if c_choice_info%notfound then
          --
          hr_utility.set_location('BEN_91457_ELCTBL_CHC_NOT_FOUND  rslt id:'||
            to_char(p_prtt_enrt_rslt_id), 75);
          fnd_message.set_name('BEN','BEN_91457_ELCTBL_CHC_NOT_FOUND');
          fnd_message.set_token('ID', 'NA');
          fnd_message.set_token('PROC', '2:'||l_proc);
          fnd_message.raise_error;
        end if;
        close c_choice_info;
        --
        If l_unsspnd_enrt_cd = 'ACD' then
          l_unsusp_cvg_start_date := p_effective_date;
          hr_utility.set_location('l_pen.enrt_cvg_strt_dt:'||l_pen.enrt_cvg_strt_dt, 60);
        Elsif l_unsspnd_enrt_cd = 'UEECSD' then
          --
          -- Use existing enrollments coverage start Date
          --
          l_unsusp_cvg_start_date := l_pen.enrt_cvg_strt_dt ;
          --
        elsif l_unsspnd_enrt_cd='RUCDECSDC' then
          --
          -- Recalc using enrt_cvg_strt_dt_cd
          -- Substitute p_effective_date for the lf_evt_ocrd_dt
          --
          ben_determine_date.rate_and_coverage_dates
            (p_which_dates_cd         => 'C'
            ,p_date_mandatory_flag    => 'Y'
            ,p_compute_dates_flag     => 'Y'
            ,p_business_group_id      => p_business_group_id
            ,P_PER_IN_LER_ID          => p_per_in_ler_id
            ,P_PERSON_ID              => l_pen.person_id
            ,P_PGM_ID                 => l_pen.pgm_id
            ,P_PL_ID                  => l_pen.pl_id
            ,P_OIPL_ID                => l_pen.oipl_id
            ,P_LEE_RSN_ID             => l_lee_rsn_id
            ,P_ENRT_PERD_ID           => l_enrt_perd_id
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
            ,p_lf_evt_ocrd_dt         => nvl(p_cmpltd_dt,p_effective_date)
          );
          l_unsusp_cvg_start_date :=l_enrt_cvg_strt_dt;
          --
        else
          hr_utility.set_location('1 g_cmpltn dt'||p_cmpltd_dt,777);

          ben_determine_date.main
            (p_date_cd                => l_unsspnd_enrt_cd
            ,p_formula_id             => null
            ,P_PER_IN_LER_ID          => p_per_in_ler_id
            ,P_PERSON_ID              => l_pen.person_id
            ,P_PGM_ID                 => l_pen.pgm_id
            ,P_PL_ID                  => l_pen.pl_id
            ,P_OIPL_ID                => l_pen.oipl_id
            ,p_business_group_id      => p_business_group_id
            ,p_effective_date         => p_effective_date
            ,p_lf_evt_ocrd_dt         => l_lf_evt_ocrd_dt -- p_effective_date
            ,p_cmpltd_dt              => nvl(p_cmpltd_dt,p_effective_date)
            ,p_returned_date          => l_unsusp_cvg_start_date
          );
        End if;
      --
      hr_utility.set_location('2 l_unsusp_cvg_start_date'||l_unsusp_cvg_start_date,777);
      ----Bug 7557403
      -----set the global variables
      open c_fonm_check(l_elig_per_elctbl_chc_id);
      fetch c_fonm_check into l_fonm_check;
      close c_fonm_check;
      if l_fonm_check.fonm_cvg_strt_dt is not null then
      ben_manage_life_events.g_fonm_cvg_strt_dt := l_unsusp_cvg_start_date;
      ben_manage_life_events.g_fonm_rt_strt_dt := l_unsusp_cvg_start_date;
      end if;
      hr_utility.set_location('l_unsspnd_enrt_cd : '||l_unsspnd_enrt_cd,777);
      if l_unsspnd_enrt_cd like 'FD%' then -------------------------Bug 8244575
      ----------Bug 8420062,if multiple rates are attached to the comp object,then
      ----------update all the rate records.
      --update the enrt rt table with the new rt start date
      /* open c_get_enrt_rt(l_elig_per_elctbl_chc_id);
      fetch c_get_enrt_rt into l_get_enrt_rt;
      if c_get_enrt_rt%found then
          update ben_enrt_rt
               set rt_strt_dt = l_unsusp_cvg_start_date
          where enrt_rt_id = l_get_enrt_rt.enrt_rt_id;
      end if;
      close c_get_enrt_rt;*/
      for l_get_rt in c_get_enrt_rt(l_elig_per_elctbl_chc_id) loop
         hr_utility.set_location('l_get_rt.enrt_rt_id : '||l_get_rt.enrt_rt_id,777);
         update ben_enrt_rt
               set rt_strt_dt = l_unsusp_cvg_start_date
          where enrt_rt_id = l_get_rt.enrt_rt_id;
      end loop;
      ----------Bug 8420062
      end if;
      hr_utility.set_location('g_fonm_rt_start_date'||ben_manage_life_events.g_fonm_rt_strt_dt,777);
      hr_utility.set_location('g_fonm_cvg_start_date'||ben_manage_life_events.g_fonm_cvg_strt_dt,777);
      ----Bug 7557403

      l_cvg_thru_dt := l_unsusp_cvg_start_date - 1 ;
      -- need choice info to recalc dates
      --
      -- We need to end the rates one day before the new Coverage start as per
      -- Unsuspend Code which is l_cvg_thru_dt
      For l_prv in c_prv (l_interim.prtt_enrt_rslt_id) loop
        l_last_place := 'Calling update_prtt_rt_val';
        ben_prtt_rt_val_api.update_prtt_rt_val
          (P_VALIDATE                => FALSE
          ,P_PRTT_RT_VAL_ID          => l_prv.prtt_rt_val_id
          ,p_person_id               => l_interim.person_id
          ,P_RT_END_DT               => l_cvg_thru_dt  -- 999 l_rec_rt_end_dt
          ,p_business_group_id       => p_business_group_id
          ,p_per_in_ler_id           => l_per_in_ler_id
          ,P_OBJECT_VERSION_NUMBER   => l_prv.object_version_number
          ,P_EFFECTIVE_DATE          => p_effective_date
          );
      End loop;
      --
      -- Update Dependent coverage thru date.
      --
      For l_dpnt in c_dpnt(l_interim.prtt_enrt_rslt_id) loop
        --
        If (p_effective_date = l_dpnt.effective_start_date) then
          l_datetrack_mode := hr_api.g_correction;
        Else
          l_datetrack_mode := hr_api.g_update;
        End if;
        --
        l_last_place := 'Calling update_elig_cvrd_dpnt';
        ben_elig_cvrd_dpnt_api.update_elig_cvrd_dpnt
          (p_validate                => FALSE
          ,p_business_group_id       => p_business_group_id
          ,p_elig_cvrd_dpnt_id       => l_dpnt.elig_cvrd_dpnt_id
          ,p_effective_start_date    => l_dpnt.effective_start_date
          ,p_effective_end_date      => l_dpnt.effective_end_date
          ,p_cvg_thru_dt             => l_cvg_thru_dt -- 999 l_dpnt_cvg_end_dt
          ,p_object_version_number   => l_dpnt.object_version_number
          ,p_effective_date          => p_effective_date
          ,p_datetrack_mode          => l_datetrack_mode
          ,p_multi_row_actn          => FALSE);
      End loop;
      --
      -- Update interim result row.
      --
      if l_unsusp_cvg_start_date = l_interim.enrt_cvg_strt_dt then
        l_datetrack_mode := hr_api.g_correction;
      Else
        l_datetrack_mode := hr_api.g_update;
      End if;
      hr_utility.set_location('l_cvg_thru_dt'||l_cvg_thru_dt,777);
      --
      Update_sspndd_flag
        (p_prtt_enrt_rslt_id         => l_interim.prtt_enrt_rslt_id
        ,p_effective_date            => p_effective_date
        ,p_business_group_id         => p_business_group_id
        ,p_sspndd_flag               => 'N'
        ,p_RPLCS_SSPNDD_RSLT_ID      => NULL
        ,p_enrt_cvg_thru_dt          => l_cvg_thru_dt
        ,p_object_version_number     => l_interim.object_version_number
        ,p_datetrack_mode            => l_datetrack_mode
        ,p_ENRT_PL_OPT_FLAG          => 'N'
        ,p_pgm_id                    => l_interim.pgm_id
        ,p_pl_id                     => l_interim.pl_id
        ,p_person_id                 => l_interim.person_id
      );
      --Bug 2185509 Delete the interim ledger entries
      ben_provider_pools.remove_bnft_prvdd_ldgr
          (p_prtt_enrt_rslt_id  => l_interim.prtt_enrt_rslt_id
          ,p_effective_date     => p_effective_date
          ,p_business_group_id  => p_business_group_id
          ,p_validate           => FALSE
          ,p_datetrack_mode     => hr_api.g_delete
      );
      --
    End if;
    --
    -- Get the unsuspend enrollment code
    -- Default to "As of completed date" if not found or null
    --
    if l_carry_forward = 'N' then --CFW
       open c_unsspnd_enrt_cd;
       fetch c_unsspnd_enrt_cd into l_unsspnd_enrt_cd;
       if c_unsspnd_enrt_cd%notfound or l_unsspnd_enrt_cd is null then
         l_unsspnd_enrt_cd:='ACD';
       end if;
       close c_unsspnd_enrt_cd;
    else
         l_unsspnd_enrt_cd:='ACD';
    end if;
    hr_utility.set_location('past c_unsspnd_enrt_cd', 10);
    --
    -- need choice info to recalc dates
    --
    open c_choice_info(p_prtt_enrt_rslt_id);
    fetch c_choice_info into
      l_elig_per_elctbl_chc_id,
      l_lee_rsn_id,
      l_enrt_perd_id,
      --START Bug 2958032
      l_epe_prtt_enrt_rslt_id,
      l_epe_object_version_number;
      --END Bug 2958032;
    if c_choice_info%notfound then
      --
      -- error
      --
      hr_utility.set_location('BEN_91457_ELCTBL_CHC_NOT_FOUND  rslt id:'||
            to_char(p_prtt_enrt_rslt_id), 75);
      fnd_message.set_name('BEN','BEN_91457_ELCTBL_CHC_NOT_FOUND');
      fnd_message.set_token('ID', 'NA');
      fnd_message.set_token('PROC', '2:'||l_proc);
      fnd_message.raise_error;
    end if;
    close c_choice_info;
    hr_utility.set_location('past c_choice_info', 10);
    --
    -- This section handles the changes to the suspended enrollment's
    -- coverage start date
    --
    hr_utility.set_location('l_unsspnd_enrt_cd:'||l_unsspnd_enrt_cd, 60);
    hr_utility.set_location('p_effective_date:'||p_effective_date, 60);
    hr_utility.set_location('l_pen.enrt_cvg_strt_dt'||l_pen.enrt_cvg_strt_dt,777);

    If ( nvl(p_cmpltd_dt,p_effective_date) >= l_pen.enrt_cvg_strt_dt ) then
    -- Bug 8488400 : Added nvl(p_cmpltd_dt,p_effective_date) to the if condition
      --
      l_update_dates := true;
      --
      if not l_previous_no_sspn then
       If l_unsspnd_enrt_cd = 'ACD' then
         --
         l_pen.enrt_cvg_strt_dt := nvl(p_cmpltd_dt,p_effective_date) ;
         --
         hr_utility.set_location('l_pen.enrt_cvg_strt_dt:'||l_pen.enrt_cvg_strt_dt, 60);
         --
       Elsif l_unsspnd_enrt_cd = 'UEECSD' then
        --
        -- Do nothing already set
        --
         null;
       elsif l_unsspnd_enrt_cd='RUCDECSDC' then
        --
        -- Recalc using enrt_cvg_strt_dt_cd
        -- Substitute p_effective_date for the lf_evt_ocrd_dt
        --
         ben_determine_date.rate_and_coverage_dates
          (p_which_dates_cd         => 'C'
          ,p_date_mandatory_flag    => 'Y'
          ,p_compute_dates_flag     => 'Y'
          ,p_business_group_id      => p_business_group_id
          ,P_PER_IN_LER_ID          => p_per_in_ler_id
          ,P_PERSON_ID              => l_pen.person_id
          ,P_PGM_ID                 => l_pen.pgm_id
          ,P_PL_ID                  => l_pen.pl_id
          ,P_OIPL_ID                => l_pen.oipl_id
          ,P_LEE_RSN_ID             => l_lee_rsn_id
          ,P_ENRT_PERD_ID           => l_enrt_perd_id
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
          ,p_lf_evt_ocrd_dt         => nvl(p_cmpltd_dt,p_effective_date)
        );
         l_pen.enrt_cvg_strt_dt :=l_enrt_cvg_strt_dt;
        --
       else
         hr_utility.set_location('TWO g_cmpltn dt'||p_cmpltd_dt,777);
         ben_determine_date.main
          (p_date_cd                => l_unsspnd_enrt_cd
          ,p_formula_id             => null
          ,P_PER_IN_LER_ID          => p_per_in_ler_id
          ,P_PERSON_ID              => l_pen.person_id
          ,P_PGM_ID                 => l_pen.pgm_id
          ,P_PL_ID                  => l_pen.pl_id
          ,P_OIPL_ID                => l_pen.oipl_id
          ,p_business_group_id      => p_business_group_id
          ,p_effective_date         => p_effective_date
          ,p_lf_evt_ocrd_dt         => l_lf_evt_ocrd_dt -- p_effective_date
          ,p_cmpltd_dt              => nvl(p_cmpltd_dt,p_effective_date)
          ,p_returned_date          => l_enrt_cvg_strt_dt
        );
         hr_utility.set_location('TWO l_pen.enrt_cvg_strt_dt'||l_pen.enrt_cvg_strt_dt,777);
         l_pen.enrt_cvg_strt_dt :=l_enrt_cvg_strt_dt;
         hr_utility.set_location('TWO l_enrt_cvg_strt_dt'||l_enrt_cvg_strt_dt,777);

       End if;
       --
      end if; -- l_previous_no_sspn
      --
    end if;
    --
    --
    -- Determine new dates for rates and dependents
    --
    -- Updating participant rate value's coverage start date
    -- NOTE: this must happen before the suspend flag is set to N
    --
    For l_prv in c_prv (p_prtt_enrt_rslt_id) loop
      l_last_place := 'Calling update_prtt_rt_val';
      --
      if not l_previous_no_sspn then
        -- Don't bother updating if the date is the same
        -- 999
        --bug#3692450 - if the unsuspend code is use existing enrollment start
        --use the rate start date arrived by participation process
        if l_unsspnd_enrt_cd <> 'UEECSD' then
          l_rec_rt_strt_dt := l_pen.enrt_cvg_strt_dt ;
        end if;
        --
        if l_rec_rt_strt_dt is null then
          l_rec_rt_strt_dt:=l_prv.rt_strt_dt;
        end if;
      --
        -- Bug 5231894 changed "<>" to ">". We should update rate start date only if the rate
        -- has started on a date earlier than effective_date / date of un-suspension.
        -- if (l_rec_rt_strt_dt<>l_prv.rt_strt_dt) and
        if (l_rec_rt_strt_dt > l_prv.rt_strt_dt) and
           l_update_dates then
          ben_prtt_rt_val_api.update_prtt_rt_val
            (P_VALIDATE                => FALSE
            ,P_PRTT_RT_VAL_ID          => l_prv.prtt_rt_val_id
            ,p_person_id               => l_pen.person_id
            ,P_RT_STRT_DT              => l_rec_rt_strt_dt
            ,p_business_group_id       => p_business_group_id
            ,p_per_in_ler_id           => l_per_in_ler_id
            ,P_OBJECT_VERSION_NUMBER   => l_prv.object_version_number
            ,P_EFFECTIVE_DATE          => p_effective_date
          );
        else
           l_rec_rt_strt_dt := l_prv.rt_strt_dt;
        end if;
       else
          l_rec_rt_strt_dt := l_prv.rt_strt_dt;
        --
      end if;
        -- Handle update/create of EEs
        --
	-- Bug 4141269 We will pass p_input_value_id and p_element_type_id as null
	--             so that they get correctly re-queried in benelmen.pkb
	--             based on life event occurred date or rate start date
      if l_prv.element_entry_value_id is null then
        ben_element_entry.create_enrollment_element
          (p_business_group_id         => p_business_group_id
          ,p_prtt_rt_val_id            => l_prv.prtt_rt_val_id
          ,p_person_id                 => l_pen.person_id
          ,p_acty_ref_perd             => l_prv.acty_ref_perd_cd
          ,p_acty_base_rt_id           => l_prv.acty_base_rt_id
          ,p_enrt_rslt_id              => p_prtt_enrt_rslt_id
          ,p_rt_start_date             => l_rec_rt_strt_dt
          ,p_rt                        => l_prv.rt_val
          ,p_cmncd_rt                  => l_prv.cmcd_rt_val
          ,p_ann_rt                    => l_prv.ann_rt_val
          ,p_input_value_id            => null  -- l_prv.input_value_id  /* Bug 4141269 */
          ,p_element_type_id           => null  -- l_prv.element_type_id /* Bug 4141269 */
          ,p_prv_object_version_number => l_prv.object_version_number
          ,p_effective_date            => p_effective_date
          --
          ,p_eev_screen_entry_value   => l_dummy_number
          ,p_element_entry_value_id   => l_dummy_number
          );
        --
      else
        open c_ee(l_prv.element_entry_value_id,l_rec_rt_strt_dt);
        fetch c_ee into l_ee_end_date;
        close c_ee;
        if l_ee_end_date <> hr_api.g_eot and
           l_prv.rt_end_dt   =  hr_api.g_eot then
          ben_element_entry.reopen_closed_enrollment(
             p_business_group_id        => p_business_group_id
            ,p_person_id                => l_pen.person_id
            ,p_prtt_rt_val_id            => l_prv.prtt_rt_val_id
            ,p_acty_base_rt_id          => l_prv.acty_base_rt_id
            ,p_element_type_id          => l_prv.element_type_id
            ,p_input_value_id           => l_prv.input_value_id
            ,p_rt                       => null --not used
            ,p_rt_start_date            => l_rec_rt_strt_dt
            ,p_effective_date           => p_effective_date
          );
         --
        end if;
      end if;
      --
      --  following codE writes entries to pool ledger-bug#1617825
      --
      open c_enrt_rt(l_prv.prtt_rt_val_id);
      fetch c_enrt_rt into l_decr_bnft_prvdr_pool_id;
      close c_enrt_rt;
      --
      if l_decr_bnft_prvdr_pool_id is not null then
         --
         ben_provider_pools.create_debit_ledger_entry
          (p_person_id               => l_pen.person_id
          ,p_per_in_ler_id           => l_per_in_ler_id
          ,p_elig_per_elctbl_chc_id  => l_elig_per_elctbl_chc_id
          ,p_prtt_enrt_rslt_id       => p_prtt_enrt_rslt_id
          ,p_decr_bnft_prvdr_pool_id => l_decr_bnft_prvdr_pool_id
          ,p_acty_base_rt_id         => l_prv.acty_base_rt_id
          ,p_prtt_rt_val_id          => l_prv.prtt_rt_val_id
          ,p_enrt_mthd_cd            => l_pen.enrt_mthd_cd
          ,p_val                     => l_prv.rt_val
          ,p_bnft_prvdd_ldgr_id      => l_bnft_prvdd_ldgr_id
          ,p_business_group_id       => p_business_group_id
          ,p_effective_date          => p_effective_date
          --
          ,p_bpl_used_val            => l_dummy_number
          );
        --
       end if;
    End loop;
    --
    -- Un-suspend Enrollment.  Which involve updating coverage start date of
    -- dependent, participant rate value tables
    -- Note: this must be done after rate stuff since the prv api updates
    --       the ee's except when the result is suspended.  We want to
    --       handle the ee's here (above)
    --
    l_last_place := 'Calling update_sspndd_flag';
    --
    if l_update_dates then
       --
       -- As the below cursor Csr_prtt_enrt_rslt replaces the computed
       -- cvrg_strt_dt save it to reset it.
       --
       l_enrt_cvg_strt_dt  := l_pen.enrt_cvg_strt_dt;
       --
    end if;
    --
    -- Get the needed result info
    --
    Open  Csr_prtt_enrt_rslt(p_prtt_enrt_rslt_id);
    l_pen.prtt_enrt_rslt_id:=null;
    Fetch Csr_prtt_enrt_rslt Into l_pen;
    Close Csr_prtt_enrt_rslt;
    if l_pen.prtt_enrt_rslt_id is not null then
      --
      -- Check date-track mode.
      -- BUG 3441027 we can't use the p_datetrack_mode if the
      -- p_effective_date > l_pen.effective_start_date.
      -- What ever mode user selects while completing the
      -- certifications, we need to derive it here.
      --
      IF (p_effective_date = l_pen.effective_start_date) Then
        --
        l_datetrack_mode  := hr_api.g_correction;
        --
      ELSIF p_effective_date > l_pen.effective_start_date then
        --
        l_datetrack_mode  := hr_api.g_update;
        --
      ELSE
        --
        l_datetrack_mode  := p_datetrack_mode;
        --
      END IF;
      --
      hr_utility.set_location('l_datetrack_mode:'||l_datetrack_mode, 60);
      hr_utility.set_location('l_enrt_cvg_strt_dt'||l_enrt_cvg_strt_dt,777);
      hr_utility.set_location('BEFORE l_pen.enrt_cvg_strt_dt '||l_pen.enrt_cvg_strt_dt ,777);

      --
      if l_update_dates and not l_previous_no_sspn then
       --
       -- As the above cursor Csr_prtt_enrt_rslt replaces the computed
       -- enrt_cvrg_strt_dt reset it with computed value.
       --
       l_pen.enrt_cvg_strt_dt  := l_enrt_cvg_strt_dt;
       hr_utility.set_location('INSIDE l_pen.enrt_cvg_strt_dt '||l_pen.enrt_cvg_strt_dt ,777);

       --
      end if;
      --
      Update_sspndd_flag
        (p_prtt_enrt_rslt_id         => p_prtt_enrt_rslt_id
        ,p_effective_date            => p_effective_date
        ,p_business_group_id         => p_business_group_id
        ,p_sspndd_flag               => 'N'
        ,p_RPLCS_SSPNDD_RSLT_ID      => NULL
        ,p_object_version_number     => l_pen.object_version_number
        ,p_datetrack_mode            => l_datetrack_mode
        ,p_ENRT_PL_OPT_FLAG          => l_pen.ENRT_PL_OPT_FLAG
        ,p_enrt_cvg_strt_dt          => l_pen.enrt_cvg_strt_dt
        ,p_pgm_id                    => l_pen.pgm_id
        ,p_pl_id                     => l_pen.pl_id
        ,p_person_id                 => l_pen.person_id
      );
      --START BUG 2958032
      open c_choice_info(p_prtt_enrt_rslt_id);
      fetch c_choice_info into
        l_elig_per_elctbl_chc_id,
        l_lee_rsn_id,
        l_enrt_perd_id,
        l_epe_prtt_enrt_rslt_id,
        l_epe_object_version_number;
      if c_choice_info%notfound then
        hr_utility.set_location('BEN_91457_ELCTBL_CHC_NOT_FOUND  rslt id:'||
            to_char(p_prtt_enrt_rslt_id), 75);
        fnd_message.set_name('BEN','BEN_91457_ELCTBL_CHC_NOT_FOUND');
        fnd_message.set_token('ID', 'NA');
        fnd_message.set_token('PROC', '2:'||l_proc);
        fnd_message.raise_error;
      end if;
      close c_choice_info;
      --
      hr_utility.set_location('got the latest epe info', 10);
      hr_utility.set_location(' l_elig_per_elctbl_chc_id '||l_elig_per_elctbl_chc_id,22);
      hr_utility.set_location(' l_epe_prtt_enrt_rslt_id '||l_epe_prtt_enrt_rslt_id,23);
      --
      if l_epe_prtt_enrt_rslt_id is null or
         l_epe_prtt_enrt_rslt_id <> p_prtt_enrt_rslt_id then
        --
        ben_ELIG_PER_ELC_CHC_api.update_ELIG_PER_ELC_CHC
           (p_validate                       => FALSE
           ,p_elig_per_elctbl_chc_id         => l_elig_per_elctbl_chc_id
           ,p_prtt_enrt_rslt_id              => p_prtt_enrt_rslt_id
           ,p_object_version_number          => l_epe_object_version_number
           ,p_effective_date                 => p_effective_date
	   ----Bug 7557403
	   ,p_fonm_cvg_strt_dt               => ben_manage_life_events.g_fonm_cvg_strt_dt
	   ----Bug 7557403
           ,p_request_id                     => fnd_global.conc_request_id
           ,p_program_application_id         => fnd_global.prog_appl_id
           ,p_program_id                     => fnd_global.conc_program_id
           ,p_program_update_date            => sysdate
           );
        --
      end if;
      -- Need to clean the enb records for pen_id
      --
      for l_enb in c_enb(p_prtt_enrt_rslt_id,l_elig_per_elctbl_chc_id) loop
        --
        ben_enrt_bnft_api.update_enrt_bnft
          (p_enrt_bnft_id           => l_enb.enrt_bnft_id
          ,p_effective_date         => p_effective_date
          ,p_object_version_number  => l_enb.object_version_number
          ,p_business_group_id      => p_business_group_id
          ,p_prtt_enrt_rslt_id      => NULL
          ,p_program_application_id => fnd_global.prog_appl_id
          ,p_program_id             => fnd_global.conc_program_id
          ,p_request_id             => fnd_global.conc_request_id
          ,p_program_update_date    => sysdate
        );
        --
      end loop ;
      --
      open c_enrt_bnft(p_prtt_enrt_rslt_id,l_elig_per_elctbl_chc_id,p_effective_date);
        fetch c_enrt_bnft into l_enrt_bnft_id,l_enb_object_version_number;
      close c_enrt_bnft ;
      --
      if l_enrt_bnft_id is not null then
        --
        ben_election_information.manage_enrt_bnft(
              p_enrt_bnft_id               => l_enrt_bnft_id,
              p_effective_date             => p_effective_date,
              p_object_version_number      => l_enb_object_version_number,
              p_business_group_id          => p_business_group_id,
              p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id,
              p_per_in_ler_id              => l_per_in_ler_id
        );
        --
      end if;
      --
      --END BUG 2958032
      --
      -- Bug : 2088231
      -- As the enrollment is unsuspended, go create the
      -- credit ledger entry.
      --
      ben_provider_pools.accumulate_pools
          (p_validate               => FALSE
          ,p_person_id              => l_pen.person_id
          ,p_elig_per_elctbl_chc_id => l_elig_per_elctbl_chc_id
          ,p_business_group_id      => p_business_group_id
          ,p_enrt_mthd_cd           => l_pen.enrt_mthd_cd
          ,p_effective_date         => p_effective_date);
      --
      -- Bug fix 2689926: It is not enuf if the accumulate_pools alone is called
      -- becos it will only handle the create/delete of ledger rows,
      -- in addition to this, when the enrollment gets unsuspended we need
      -- to do other flex credits processing like forfeiture, distribution,
      -- rollover and "updation of prtt_rt_value of flex shell plan enrt_rslt
      -- row", due to the unsuspension. Hence making a call to
      -- ben_provider_pools.total_plans will handle all of the above.
      --
      l_prtt_enrt_rslt_id := p_prtt_enrt_rslt_id ;
      ben_provider_pools.total_pools
        (p_validate             => FALSE
        ,p_prtt_enrt_rslt_id    => l_prtt_enrt_rslt_id
        ,p_prtt_rt_val_id       => l_prtt_rt_val_id
        ,p_acty_ref_perd_cd     => l_acty_ref_perd_cd
        ,p_acty_base_rt_id      => l_acty_base_rt_id
        ,p_rt_strt_dt           => l_rt_strt_dt1
        ,p_rt_val               => l_rt_val
        ,p_element_type_id      => l_element_type_id
        ,p_person_id            => l_pen.person_id
        ,p_per_in_ler_id        => l_per_in_ler_id
        ,p_enrt_mthd_cd         => l_pen.enrt_mthd_cd
        ,p_effective_date       => p_effective_date
        ,p_business_group_id    => p_business_group_id
        ,p_pgm_id               => l_pen.pgm_id
      );
      --
      -- End fix 2689926
      --
      --
      -- Update Dependent coverage start date.
      --
      For l_dpnt in c_dpnt(p_prtt_enrt_rslt_id) loop
      -- if l_dpnt.cvg_strt_dt<>l_dpnt_cvg_strt_dt and   --BUG 3977951
      -- 4775743: If Dpnt Cvg starts after the PEN Strt, then use Dpnt Cvg Strt.
      --
      l_dpnt_cvg_strt_dt := greatest(NVL(l_dpnt.cvg_strt_dt,l_pen.enrt_cvg_strt_dt), l_pen.enrt_cvg_strt_dt);
      --
        if l_dpnt.cvg_strt_dt <> l_pen.enrt_cvg_strt_dt and  l_update_dates then
          --
          If (p_effective_date = l_dpnt.effective_start_date) then
            l_datetrack_mode := hr_api.g_correction;
          Else
            l_datetrack_mode := hr_api.g_update;
          End if;
          --
          l_last_place := 'Calling update_elig_cvrd_dpnt';
          --
          ben_elig_cvrd_dpnt_api.update_elig_cvrd_dpnt
            (p_validate                => FALSE
            ,p_business_group_id       => p_business_group_id
            ,p_elig_cvrd_dpnt_id       => l_dpnt.elig_cvrd_dpnt_id
            ,p_effective_start_date    => l_dpnt.effective_start_date
            ,p_effective_end_date      => l_dpnt.effective_end_date
            ,p_cvg_strt_dt             => l_dpnt_cvg_strt_dt -- l_pen.enrt_cvg_strt_dt -- 999 l_dpnt_cvg_strt_dt
            ,p_object_version_number   => l_dpnt.object_version_number
            ,p_effective_date          => p_effective_date
            ,p_datetrack_mode          => l_datetrack_mode
            ,p_multi_row_actn          => FALSE
          );
        end if;
      End loop;
    end if;
    l_last_place := 'Calling the Post-Result RCO';
    --
    If p_called_from = 'BENEOPEH' then
      hr_utility.set_location(l_proc||' Called from Override',99);
    else
      --
      If (p_post_rslt_flag = 'Y') Then
        l_last_place := 'Calling result multi-row edit';
        --Bug 4622534
        if g_cfw_dpnt_flag = 'N' THEN
	    --
	    -- Start 6054988 : Call multi_rows_edit only if any elections made
	    -- in the current pil else call chk_coverage_across_plan_types
            open chk_elcn_dt_in_pel;
	    fetch chk_elcn_dt_in_pel into l_var;
	    if chk_elcn_dt_in_pel%NOTFOUND then
                 ben_prtt_enrt_result_api.multi_rows_edit
	   	    (p_person_id           => l_pen.person_id
	            ,p_effective_date      => p_effective_date
		    ,p_business_group_id   => p_business_group_id
	            ,p_pgm_id              => l_pen.pgm_id
		    ,p_per_in_ler_id       => l_per_in_ler_id
                    );
            else
	          ben_PRTT_ENRT_RESULT_api.chk_coverage_across_plan_types
                    (p_person_id              => l_pen.person_id,
                     p_effective_date         => p_effective_date,
                     p_lf_evt_ocrd_dt         => l_lf_evt_ocrd_dt,
                     p_business_group_id      => p_business_group_id,
                     p_pgm_id                 => l_pen.pgm_id);
            end if;
            --
	    -- End 6054988
            --
            l_last_place := 'Calling process_post_results';
            ben_proc_common_enrt_rslt.process_post_results
            (p_person_id           => l_pen.person_id
            ,p_enrt_mthd_cd        => l_pen.enrt_mthd_cd
            ,p_effective_date      => p_effective_date
            ,p_business_group_id   => p_business_group_id
            ,p_per_in_ler_id       => l_per_in_ler_id
            );
        end if;
        --
      else
        -- check if it's an imputed income plan
        open c_pl(l_pen.pl_id);
        fetch c_pl into l_dummy;
        if c_pl%FOUND then
          l_imp_inc_plan := true;
        end if;
        close c_pl;
        if l_imp_inc_plan then
          ben_det_imputed_income.p_comp_imputed_income
          (p_person_id            => l_pen.person_id
          ,p_enrt_mthd_cd         => l_pen.enrt_mthd_cd
          ,p_per_in_ler_id        => l_pen.per_in_ler_id
          ,p_effective_date       => p_effective_date
          ,p_business_group_id    => p_business_group_id
          ,p_ctrlm_fido_call      => false
          ,p_validate             => false);
        end if;
      End if;
    End if; -- p_called_from
  End If;
  hr_utility.set_location('Leaving:'|| l_proc, 99);
Exception
    When others then
        hr_utility.set_location('ERROR '||l_proc, 95);
        rpt_error(l_proc, l_last_place);
	-- for nocopy changes
	p_object_version_number := l_object_version_number ;
        fnd_message.raise_error;
End unsuspend_enrollment;
--
end ben_sspndd_enrollment;

/
