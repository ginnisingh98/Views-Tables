--------------------------------------------------------
--  DDL for Package Body BEN_ENROLLMENT_ACTION_ITEMS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ENROLLMENT_ACTION_ITEMS" as
/* $Header: benactcm.pkb 120.28.12010000.9 2009/08/10 07:34:36 pvelvano ship $ */
--
/*
--
Name
       Determine Enrollment Action Items - ENTE66R06
Purpose
       This package is used to check enrollment action items. It is meant to be
       used in the enrollment process.  As a batch job with several entry points
       callable by other processes.
       Process 1) Determines if an enrollment action item(s) need to be written
       when a person enrolls in a plan.  Check dependents and beneficiary info.
       2) Updates new enrollment action item(s) when an enrollment is changed.
       3) Updates enrollment when an action item is completed in Designate Dpnt,
       Desginate Beneficiary or Certification forms.
       4) Create Certifications required for a person to complete action items.
       5) Suspends an enrollment when an action item is created.
--------------------------------------------------------------------------------
History
-------
  Version Date       Author           Comment
  -------+----------+----------------+------------------------------------------
  110.0   22 Apr 98  J Schneider      Created.
  110.1   06 Jun 98  S Tee            Fixed invalid cursor when creating a BNF
                                      action item and also BNFADDNL cursor,
                                      c_cntngnt_types as it was not selecting
                                      any rows.
  110.2   06 Jun 98  J Schneider      fixed DD if no dependents. changed
                                      get_enrt_actn_id to return object_version_
                                      number for updates.
  110.3   08 Jun 98  J Schneider      change to write multiple DDCTFN, BNFCTFN
                                      added deenrollment proc
  110.4   09 Jun 98  J Schneider      added cmpltd_dt support get_enrt_actn_id
                                      p_suspend_flag added
  110.5   10 Jun 98  J Schneider      uncommented exit
  110.6   11 Jun 98  J Schneider      moved suspend_actn stuff to API ben_prtt_
                                      enrt_actn_f so all action items will
                                      suspend enrt if new or cmpltd_dt is NULL
  110.7   13 Jun 98  J Schneider      l_g_suspend,l_suspend_flag rechecked for
                                      problems
  110.8   15 Jun 98  J Schneider      ben_dsgn_rqmt_f now uses oipl_id
  110.9   15 Jun 98  J Schneider      redo oipl pl dsgn_rqmt
  110.10  16 Jun 98  J Schneider      dsgn_rqmt needs more work for DDADDNL
  110.11  17 Jun 98  J Schneider      recheck for DDADDNL if no dependents found
  110.12  18 Jun 98  J Schneider      return suspend flag at all times
  110.13  18 Jun 98  J Schneider      110.13 typo
  110.14  18 Jun 98  J Schneider      DDADDNL redone
  110.15  23 Jun 98  J Schneider      fix DD and suspend mode
  110.16  30 Jun 98  J Schneider      datetrack_mode changes when doing updates,
                                      get_enrt_actn_id a proc
  110.17  07 Jul 98  J Mohapatra      Added batch who cols in call to ben_cvrd_
                                      dpnt_ctfn_prvdd_api.create...
  110.18  15 Jul 98  J Schneider      add exception handlers, fix dpnt ctfns.
  110.19  16 Jul 98  J Schneider      dependent certifications changes
  110.20  17 Jul 98  J Schneider      post rslt flag added for calls to suspend
                                      enrollment
  110.21  22 Jul 98  maagrawa         rslt_object_version_number added to calls
                                      to suspend enrollment.
  115.10  12 Oct 98  bbulusu          Modified a lot of procedures and functions
                                      that go against action items to handle
                                      dpnts and bnfs. Added out nocopy parameters to
                                      determine_action_items to send msgs back
                                      to forms. Made dpnt dsgn rqmts work at
                                      plan and option level. Modified call to
                                      delete_prtt_enrt_actn_. Wrote the get_due_
                                      date function. Modified the check_bnf_ttee
                                      func to check if a trustee is assigned.
  115.11  26 Oct 98  bbulusu          Modified get_due_dt function
  115.12  06 Nov 98  bbulusu          Fixed determine_bnf_action_items to insert
                                      an opitional action item if the dsgn rqmt
                                      is optional. Fixed the get_due_date func
                                      to not error out nocopy if popl_actn_typ notfound
  115.13  09 Dec 98  bbulusu          Fixed problem with warning flags not being
                                      returned.
  115.14  10-Dec-98  lmcdonal         re-write complete_dependent_designation.
  115.15  22-Dec-98  bbulusu          Fixed determine_bnf_actn_items to complete
                                      a BNF actn item if one already exists and
                                      bnfs are found Fixed determine_dpnt_actn_
                                      items to complete a DD actn item if one
                                      already exists and dpns are found Added
                                      calls to the close unresolved actn items
                                      batch process. Removed complete_all_actn_
                                      items procedure (redundant). Fixed determ
                                      ine_bnf_actn_items to delete all other bnf
                                      actn item when a BNF actn item is written.
                                      Minor fix to complete_dpnt_dsgn don't
                                      need to check to see if an actn item was
                                      found before calling process_action_item.
  115.16  22-Dec-98  bbulusu          uncommented exit statement.
  115.17  28-Dec-98  stee             Set the default for post_rslt_flag = 'Y'.
  115.18  30-Dec-98  bbulusu          Removed call to cls unresolved actn items.
  115.19  24-Feb-99  bbulusu          Modified check_dpnt_ctfn. Modified cursors
                                      c_dpnt_ctfn_pl, c_dpnt_ctfn_pgm, c_dpnt_
                                      ctfn_ptip to select dpnt ctfns based on
                                      the contact type. Added function
                                      check_ctfns_defined.
  115.20  02-Mar-99  bbulusu          Modified check_bnf_ctfn and determine_bnf
                                      _actn_items for bug fixes.
  115.21  04-Mar-99  bbulusu          Modified get_due_dt and determine_bnf_miss
                                      _actn_items.
  115.22  08-Mar-99  tmathers         Changed the not-equal operators to <>.
  115.23  23-Mar-99  bbulusu          Modified determine_addnl_bnf
  115.24  29-Apr-99  bbulusu          Fixed determine_addnl_bnf to pick up all
                                      bnfs that are not spouses.
  115.25  29-APR-99  shdas            Added pl_typ_id,opt_id,ler_id,
                                      business_group_id organization_id,
                                      assignment_id to the parameter list of
                                      genutils.formula
  115.26  03-may-99  shdas            Added jurisdiction_code.
  115.28  08-may-99  jcarpent         Check ('VOIDD', 'BCKDT') for pil stat cd
  115.29  13-may-99  jcarpent         More of same.
  115.30  02-Jun-99  bbulusu          Fix to not call check_bnf_ttee if dob is
                                      not found for the bnf.
  115.31  07-Jul-99  maagrawa         Modified determine_dpnt_miss_actn_items
                                      to work for plans not in programs.
  115.32  09-Jul-99  bbulusu          Added checks for backed out nocopy life evts.
  115.33  14-Jul-99  maagrawa         Corrected opening of cursor c_nsc_ctfn_pl.
                                      Use of bnf_ctfn_rqd_flag and
                                      dpnt_dsgn_no_ctfn_rqd_flag negated.
  115.34  20-JUL-99  Gperry           genutils -> benutils package rename.
  115.35  24-Aug-99  maagrawa         Changes related to breaking of dependents
                                      table.
  115.36  07-Sep-99  tguy             fixed call to pay_mag_util
  115.37  27-Sep-99  maagrawa         Modified Check procedures for prtt, dpnt,
                                      bnf certifications. Created new procedure
                                      process_new_ctfn_action to create/update
                                      a action item when new ctfn is created.
  115.38  27-Sep-99  tguy             Modified call to determine_date to
                                      accomadate new codes.
  115.39  12-Oct-99  stee             Fixed enrollment certification for
                                      benefit amount.  Cursor c_ecc2 was
                                      selecting comparing choice id to bnft_id.
                                      Also set the enrt_ctfn_warning flag.
  115.40  12-Nov-99  lmcdonal         Better debugging messages.
  115.41  09-Dec-99  maagrawa         Call the date routine to calculate the
                                      action item due date only if the date
                                      code is not null.
  115.42  10-Jan-00  lmcdonal         If bnf dsgn is optional, do not make the
                                      BNF% actions rqd.
  115.43  14-Jan-00  lmcdonal         Bug 1148447:  When dpnt ctfn's are at PTIP lvl,
                                      process was not writing actions nor ctfns
                                      because pgm and ptip ids were not being passed
                                      to check_ctfns_defined.  Also, removed use of
                                      lack...flag, using rqd_flag instead for dpnts.
  115.44  17-Jan-00  TMathers         Fixed syntax error in previous fix.
  115.45  31-Mar-00  MMogel           Added tokens to messages to make messages
                                      more meaningful to the user
  115.46  31-mar-00  shdas            don't always create a rqd action item for addnl dpnt(3629).
  115.47  03-apr-00  shdas            bring c_chc_flags cursor into process_dpnt_action_items
                                      from complete_dependent_desigantion and determine_dpnt_action_items.
  115.48  12-May-00  lmcdonal         Bug 1249901.  before writing bnft ctfn's, check
                                      if cvg entered at enrt, then entered amt greater
                                      than max-wout-ctfn.
  115.49  06-Jul-00  kmahendr         Bug 5140- sub-query to get contact_type returns more than
                                      one row as dependent may be a contact to more than one
                                      participant. All the sub-query to get contact_type were
                                      modified by adding prtt_person_id in the where clause
 115.50   07-Jul-00  kmahendr         Bug#1319520 is fixed on version 115.46 for aera
 115.51   07-Jul-00  kmahendr         Changes made in 115.50 applied to 115.49
 115.52   18-Jul-00  bbulusu          Fixed bug #5386. Added code to check for
                                      ctfns defined in the ben_ler_chg_dpnt_
                                      cvg_ctfn_f table for dpnt change of life
                                      events.
 115.53   08-Aug-00  bbulusu          Bug 5432. Ctfn being recreated in
                                      subsequenct life event.
 115.54   15-Aug-00  IAli             PCP Required for Participant and for Dependent process is added
 115.55   16-Aug-00  IAli             Fixed the infinite loop in determine_pcp_action procedure
 115.56   19-Aug-00  Shdas            added process_pcp_actn_items and
                                      and process_pcp_dpnt_actn_items.
 115.57   25-Aug-00  Shdas            added warnings for process_pcp_actn_items
                                      and process_pcp_dpnt_actn_items.
 115.58   28-Aug-00  cdaniels         OraBug# 4988. Suppressed raising of
                                      error 91457 when alws_dpnt_desgn_flag
                                      and dpnt_dsgn_cd not found for a
                                      specified enrt_rslt_id and effective
                                      date.  Defaulted these values to 'N'
                                      and 'O', respectively, for the case
                                      when not found.
 115.59   29-Aug-00  jcarpent         Merge of 57 and 58 changes.  57 changes
                                      were not ready for primetime so leaped
                                      now in synch.
 115.60   06-Sep-00  jcarpent         1269016. Handling of future change dt mode.
 115.61   07-Sep-00  jcarpent         Changes from 115.60 based on version 115.58.
                                      Leapfrog version not containing pcp stuff.
 115.62   07-Sep-00  jcarpent         Same as version
 115.63   26-Oct-00  pbodla           - Enhancement : Pass contact person id as
                                      input value for "certification required
                                      when rule" if the rule is for contacts.
 115.64   27-Oct-00  pbodla           - param1(CON_PERSON_ID)  passed to formula
 115.65   15-Nov-00  jcarpent         Bug 1488666.  Was creating same ctfn
                                      2 times because both cursors ecc1+2
                                      were returning the same row.
 115.66   22-Nov-00  jcarpent         Bug 1488666. Was creating same ctfn
                                      when one was a benefit ctfn and one
                                      was an enrt ctfn.  No need for both.
 115.67   29-Dec-00  ikasire          bug fix 1491912
 115.68   08-mar-01  ikasire          bug fix 1421978 modified the pcp cursors
                                      for dependent and participant
 115.69   20-apr-01  ikasire          bug 1421978 Only one action item for pcp
                                      is created for all the dependents of the
                                      prtt. This is fixed to get the pcp
                                      action item one for each dependent.
                                      Added p_elig_cvrd_dpnt_id parameter to the
                                      determine_pcp_dpnt_actn_items procedure.
                                      Also passed p_elig_cvrd_dpnt_id parameter
                                      for the call to get_prtt_enrt_actn_id and
                                      process_action_item procedures from the
                                      determine_pcp_dpnt_actn_items procedure.
 115.70   25-Apr-01  maagrawa         Performance changes.
 115.71   17-May-01  maagrawa         More Performance changes.
 115.72   17-May-01  maagrawa         Added exit statement.
 115.73   02-Jul-01  kmahendr         Bug#1842614- increased l_pln_name variable to 80
 115.74   27-aug-01  tilak            bug:1949361 jurisdiction code is
                                      derived inside benutils.formula.
 115.75   26-Dec-01  pabodla          bug:1857685 - Do not create dependent and
                                      beneficiary related action items for
                                      waive plans and options.
 115.76   08-FEB-02  aprabhak         added an action item for future salary
                                      increase
 115.77   21-FEB-02  ikasire          bug 2228123 getting the suspend_flag in
                                      determine_action_items procedure
 115.78   02-MAR-02  aprabhak         modified the salary cursor to pickup
                                      only salary increase plan
 115.79   08-MAR-02  aprabhak         Modified the future salary cursor.
                                      Removed the rate join.
 115.80   14-Mar-02  rpillay          UTF8 Changes Bug 2254683
 115.81   30-Apr-02  kmahendr         Added token to message 91832.
 115.82   23-May-02  ikasire          Bug 2389261 Inconsistent results due to
                                      not exclusion on epe with bnft_prvdr_pool_id
                                      from the cursors
 115.83   30-May-02  ikasire          Bug 2386000 Added p_called_from to the
                                     delete_cvrd_dpnt_ctfn_prvdd call
 115.84   08-Jun-02  pabodla         Do not select the contingent worker
                                     assignment when assignment data is
                                     fetched.
 115.85   30-jul-02  hnarayan        bug 1169240 - added the function
                                     check_bnf_actn_item_dfnd to check for
                                     any action items defined for beneficiaries
 115.86   26-DEC-02  kichoudh        NOCOPY changes
 115.87   13-feb-03  hnarayan        hr_utility.set_location - 'if g_debug' changes
 115.88   21-Mar-03  mmudigon        Bug 2858700. Added dt condition and order
                                     by clause to cursor c_dpnt_bnf_adrs.
 115.89   24-Mar-03  mmudigon        Bug 2858700 continued. Added order by
                                     clause to cursor c_prtt_adrs.
 115.90   22-Jul-03  ikasire         Bug 3042379 dont create action items for the
                                     interim enrollment. defensive code.
 115.91   19-Aug-03  ikasire         Bug 3105160 added raise in the exception clause.
 115.92   25-aug-03  kmahendr        Bug#3108422 - if ERL is the cvg_mlt_cd certification action item
                                     is called.
 115.93   26-aug-03  kmahendr        Condition modified for ERL
 115.94   08-aug-03  pbodla          Bug 3183266 : For flat range mx_wout_ctfn_val
                                     will be null, so use nvl around it.
 115.95   17-oct-03  hmani           Modified the arg passed to
                             write_new_bnf_ctfn_item call - Bug 3196152
 115.96   05-Nov-03  tjesumic       contact_type are expected to have more than one row for epnt
                                    sub query failing due to =, now changed to in   # 3228530
 115.97   13-Nov-03  bmanyam        Bug.3248711. Allowing Dpnt Dsgn Action item to get created,
                                    when (epe.alws_dpnt_dsgn_flag = 'Y' OR epe.dpnt_dsgn_cd = 'R'
 115.98  17-Dec-03   vvprabhu       Added the assignment for g_debug at the start
                                    of each public procedure
 115.99  21-Jan-2003 vvprabhu       Added the assignment for g_debug at the start
                                    of each public Function
 115.100 20-Feb-2004 kmahendr       Bug#3442729 - added codes to set_cmpltd_dt
 115.101 19-Apr-2004 bmanyam        Bug# 3510501 - In the date_track_verify method,
                                    set the date-track-mode to UPDATE, in the ELSE..part.
 115.102 01-Jun-2004 kmahendr       Bug#3643597 - added a new private procedure
                                    check_ctfn_prvdd.
 115.103 02-Jun-2004 kmahendr       Bug#3643597 - cursor c_prtt_enrt_rslt modified.
 115.104 03-jun-2004 kmahendr       Bug#3643597 - cursor c_prtt_enrt_rslt modified.
 115.105 01-jul-2004 bmanyam        Bug#3730053 - cursor c_emp_only modified.
                                    OIPL level DSGN_RQMTS override OPT level
 115.106 01-jul-2004 kmahendr       bug#3590524 - Added codes to check_ctfn_prvdd
 115.107 21-jul-2004 rpgupta        bug#3771346 - If waive flag not checked at option level, check at the plan level
 115.108 29-jul-2004 kmahendr       bug#3748133 - Added codes to check_ctfn_prvdd
 115.109 17-Aug-2004 hmani          bug#3806262 - p_crntly_enrd_flag can be 'N' for new enrollment
 115.110 19-Aug-2004 kmahendr       Optional certification changes
 115.111 23-Aug-2004 mmudigon       CFW. Added p_act_item flag
                                    2534391 :NEED TO LEAVE ACTION ITEMS
 115.112 26-aug-2004 nhunur         gscc compliance
 115.113 26-Aug-2004 abparekh       Bug# 3854556 - Modified cursor c_dsgn_bnf
 115.114 31-Aug-2004 abparekh       Bug# 3851427 Added p_susp_if_ctfn_not_prvd_flag to function
                                    check_ctfns_defined. Consider "Suspend Enrollment" flag at
                                    LER_CHG_DPNT level when certifications are considered at
                                    LER_CHG_DPNT level. Modified p_rqd flag parameter in write_new_action_item
 115.115 31-Aug-2004 pbodla         CFW. Several cursors modified to join per_in_ler
 115.116 09-sep-2004 mmudigon       CFW. p_act_item flag no longer needed
 115.117 03-nov-2004 kmahendr       Bug3976575- cursor c_ctfn_defined modified to pl_id and
                                    added codes in write_new_action_items for handling message
 115.118 01-Dec-2004 abparekh       Bug 4039404 : Fixed cursor c_pl_name in write_new_action_item
 115.119 30-dec-2004  nhunur          4031733 - No need to open cursor c_state.
 115.120 18-Mar-2005  swjain          4241743 - Added cursor c_prev_actn_ler in determine_other_actn_items
                                                       and modified if conditions to create action items also when ler id is different
 115.121  22-Mar-2005  swjain         Removed show errors
 115.122  12-Apr-2005   swjain         4241743 - Removed cursor c_prev_actn_ler and added c_enrt_actn
 115.123 13-Jun-2005 rbingi         Bug:4396160 -   Curosr name is changed from c_emp_only to c_tot_mn_mx_dpnts_req
                                    cursor query changed to selects the total no. of Min and Max Dpnts req for the CompObj.
				    Changed Procedure: determine_dpnt_actn_items sothat,
					For both Min and Max = 0, Action Item will NOT be created.
					For  Min = 0 and Max > 0, Action Item will be created IF Elig dpnts exists
					For both Min and Max > 0, Action Item will be created irrespective of Elig dpnts.
 115.124 13-Jun-2005 rbingi         Corrected previuos change to create Action Item when no DD record is defined.
 115.125 13-Jun-2005 rbingi         Corrected compilation errors had in previuos version
 115.126 29-Jun-2005 ikasire        Bug 4422667 getting into loop issue
 115.127 13-Jul-2005 ikasire        Bug 4454990 fixed for the code
 115.128 02-Aug-2005 rgajula        Bug No 4525608
 115.129 10-Aug-2005                A new parameter l_ctfn_actn_warning_o
				    was defined in determine_action_items which is passed on to
				    process_dpnt_actn_items and inturn passed to determine_other_actn_items
				    as out parameters.The signatures of the procedures have been changed accordingly
				    This flag whould capture the certification required action warning
				    if dependent details have been furnished and plan level certification have
				    not been furnished.
 115.130 31-Aug-2005 ikasire        BUG 4558512 completion date fix in set_cmpltd_dt procedure
 115.131 01-Sep-2005 ikasire        BUG 4558512 more changes
 115.132 15-sep-2005 rgajula        Bug 4610971 Passed the p_business_group_id to the procedure
				    ben_determine_date.main in procedure get_due_date so that
				    it ill be available to Action Type Due Date rule .
 115.133 27-Apr-2006 swjain         Bug 5156111 : Added additional logic for certications for organizations
                                    in procedure determine_additional_bnf
 115.134 28-Apr-2006 swjain         Bug 5156111 : Updated cursor c_nsc_ctfn_pl in procedure determine_additional_bnf
 115.135 02-May-2006 swjain         Bug 5156111 : Updated cursor c_spouse to check for BNF_MAY_DSGT_ORG_FLAG flag
 115.136 29-jun-2006 nhunur         bug 5362890 : Added date clauses for pcr in c_spouse
 114.137 11-Aug-2006 abparekh       Bug 5461171 : Modified clauses in CURSOR c_nsc_ctfn_pl
 115.138 9/20/2006   gsehgal        bug 5513339 : added cursor c_curr_ovn_of_actn to pass right ovn
						  to delete_action_item
 115.139 10-Jan-2007 bmanyam        5736589: No need for to check for Option Restrictions
                                    when ctfn_determine_cd = 'ENRAT', as certifications are
                                    determined at bendenrr (check_ctfn_prvdd)
 115.141 23-Feb-07   swjain         Bug 5887665: In procedure determine_other_actn_items, for coverage
                                    certifications, added code to evaluate suspended codes
 115.142 27-Feb-07   swjain         Additional changes in procedure determine_other_actn_items and added new
                                    parameter p_enrt_r_bnft_ctfn_cd in call to procedure check_ctfn_prvdd.
 115.143 2-May-2007  rgajula        Bug 5998009 : Corrected the code in the procedure determine_dpnt_miss_actn_items so as to make the system behaviour
                                    ideal when Formula for 'Dependent Certification Required' type is used
 115.144 04-May-2007 swjain         Bug 6022327: Updated cursor c_ctfn_exists in procedure write_new_prtt_ctfn_prvdd_item
 115.145 18-May-2007 swjain         Bug 5965415: In procedure check_ctfn_prvdd, updated the cursor c_ctfn_prvdd and
                                    c_ctfn_prvdd2 to check if any certification received in past for the same plan-option
				    (and not based on pen_id as it changes when coverage amount changes)
 115.146 19-Jun-2007 gsehgal        bug 6010780: checking future rows in update and correction mode also
 115.147
 115.148
 115.149 23-Aug-2007 rgajula        Bug 6353069 : Modified the procedure process_new_ctfn_action to check for dpnt certification suspend flag at various levels.
 115.150 24-Sep-2007 rtagarra       Bug 6434143 : before suspending enrollment check for SUSP_IF_CTFN_NOT_PRVD_FLAG flag.
 115.151 22-Feb-2008 rtagarra       6840074
 115.152 22-Sep-2008 sallumwa       Bug 7417593 : Modified the cursor c_ctfn_prvdd to check if the certification is already received
                                    in the past or not for the same plan and option.
 115.153 24-sep-2008 sallumwa       Bug 7417474 : Modified the cursor c_prtt_enrt_rslt,so that it doesn't fetch the record if two options
                                    from the same plan are enrolled.
 115.154 12-Nov-2008 pvelvano	    Bug 7513897 : If Coverage Amount is changed multiple times for the same Life Event, then Required
                                    Certication alert should not popup.
 115.155 11-Dec-2008 krupani        Bug 7516987 : For open life event, the designation requirement does not get evaluated as of
                                    life event occurred date.
 115.156 16-Feb-2009 velvanop       Bug 7561395: Same fix as 7513897. Bug 7513897 has been obsoleted for more changes in the fix.
 115.157 29-May-2009 velvanop       Bug 8549599 : cursor 'c_get_ler_typ' is modified to get the latest LifeEvent occured date
                                    to determine the number of dependent covered as on that date.
 115.158 10-Aug-2009 velvanop       Bug 8669907: Modified cursor c_ctfn_prvdd to check if certification is received on p_effective_date.
-------------------------------------------------------------------------------------------------------------------------------------------
*/
--
-- Package Variables
--
g_debug boolean := hr_utility.debug_enabled;
--
-- -----------------------------------------------------------------------------
-- |-----------------------< check_ctfns_defined >-----------------------------|
-- -----------------------------------------------------------------------------
--
function check_ctfns_defined
  (p_dpnt_person_id		in number
  ,p_person_id			in number
  ,p_prtt_enrt_rslt_id		in number
  ,p_lvl_cd			in varchar2
  ,p_pgm_id			in number default null
  ,p_pl_id			in number default null
  ,p_ptip_id			in number default null
  ,p_effective_date		in date
  ,p_business_group_id		in number
  ,p_ctfn_at_ler_chg		out nocopy boolean
  ,p_susp_if_ctfn_not_prvd_flag out nocopy varchar2
  )
return boolean is
  --
  -- This function checks whether certifications have defined for a certain
  -- contact type and sets the out parameter if the ctfn has been found at the
  -- ben_ler_chg_dpnt_cvg_ctfn_f table.
  -- Here the assumption is that if a certification is defined
  -- without a contact type, then it is for all contact types. The function
  -- returns TRUE if either a certification is found for the person's contact
  -- type or a certification with a contact type of null is found.
  --
  -- Bug#  3851427 : Defined out parameter P_SUSP_IF_CTFN_NOT_PRVD_FLAG. This
  -- parameter holds the value of "Suspend Enrollment" flag defined for
  -- Dependent Change Of Life Event (BEN_LER_CHG_DPNT_CVG_F). Whenever certifications
  -- are considered at "Dependent Change Of Life Event" level and NOT at PLN, PTIP or PGM
  -- level, suspension should also be considered based on "Suspension Enrollment" flag value
  -- at the "Dependent Change Of Life Event" level. Hence this flag will return valid
  -- value only when P_CTFN_AT_LER_CHG is also true.
  --
  cursor c_ctfns_ler_chg is
  select ldc.susp_if_ctfn_not_prvd_flag
    from ben_ler_chg_dpnt_cvg_ctfn_f lcc,
         ben_ler_chg_dpnt_cvg_f ldc,
         ben_prtt_enrt_rslt_f pen
   where pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and pen.business_group_id = p_business_group_id
     and p_effective_date between pen.effective_start_date
                              and pen.effective_end_date
     and pen.ler_id = ldc.ler_id
     and p_effective_date between ldc.effective_start_date
                              and ldc.effective_end_date
     and pen.prtt_enrt_rslt_stat_cd is null
     and ((p_lvl_cd = 'PTIP' and ldc.ptip_id = p_ptip_id) OR
          (p_lvl_cd = 'PL' and ldc.pl_id = p_pl_id) OR
          (p_lvl_cd = 'PGM' and ldc.pgm_id = p_pgm_id))
     and ldc.ler_chg_dpnt_cvg_id = lcc.ler_chg_dpnt_cvg_id
     and p_effective_date between lcc.effective_start_date
                              and lcc.effective_end_date
     and (lcc.rlshp_typ_cd is null
          or
          lcc.rlshp_typ_cd in (select contact_type
                                from per_contact_relationships
                               where contact_person_id = p_dpnt_person_id
                                 and person_id = p_person_id
                                 and business_group_id = p_business_group_id
                                 and p_effective_date
                                     between nvl(date_start, p_effective_date)
                                         and nvl(date_end, hr_api.g_eot)));

  --
  cursor c_ctfns_pgm is
  select 'x'
    from ben_pgm_dpnt_cvg_ctfn_f
   where pgm_id = p_pgm_id
     and business_group_id = p_business_group_id
     and p_effective_date between effective_start_date
                              and effective_end_date
     and (rlshp_typ_cd is null
          or
          rlshp_typ_cd in (select contact_type
                            from per_contact_relationships
                           where contact_person_id = p_dpnt_person_id
                             and person_id = p_person_id
                             and business_group_id = p_business_group_id
                             and p_effective_date
                                   between nvl(date_start, p_effective_date)
                                       and nvl(date_end, hr_api.g_eot)));
  --
  cursor c_ctfns_ptip is
  select 'x'
    from ben_ptip_dpnt_cvg_ctfn_f
   where ptip_id = p_ptip_id
     and business_group_id = p_business_group_id
     and p_effective_date between effective_start_date
                              and effective_end_date
     and (rlshp_typ_cd is null
          or
          rlshp_typ_cd in (select contact_type
                            from per_contact_relationships
                           where contact_person_id = p_dpnt_person_id
                             and person_id = p_person_id
                             and business_group_id = p_business_group_id
                             and p_effective_date
                                   between nvl(date_start, p_effective_date)
                                       and nvl(date_end, hr_api.g_eot)));
  --
  cursor c_ctfns_pl is
  select 'x'
    from ben_pl_dpnt_cvg_ctfn_f
   where pl_id = p_pl_id
     and business_group_id = p_business_group_id
     and p_effective_date between effective_start_date
                              and effective_end_date
     and (rlshp_typ_cd is null
          or
          rlshp_typ_cd in (select contact_type
                            from per_contact_relationships
                           where contact_person_id = p_dpnt_person_id
                             and person_id = p_person_id
                             and business_group_id = p_business_group_id
                             and p_effective_date
                                   between nvl(date_start, p_effective_date)
                                       and nvl(date_end, hr_api.g_eot)));
  --
  l_dummy varchar2(1);
  l_return boolean := FALSE;
  --
  l_proc varchar2(80) ;
  l_susp_if_ctfn_not_prvd_flag varchar2(30);
  --
begin
  --
  if g_debug then
    l_proc := g_package || '.check_ctfns_defined';
    hr_utility.set_location('Entering ' || l_proc, 10);
  end if;
  if g_debug then
    hr_utility.set_location('Dpnt dsgn level code : ' || p_lvl_cd, 10);
  end if;
  --
  l_susp_if_ctfn_not_prvd_flag := null;
  --
  if p_lvl_cd = 'PGM' then
    --
    -- At the program level, first check for ctfns defined for the ler change
    -- and then check for regular ctfns.
    --
    open c_ctfns_ler_chg;
    fetch c_ctfns_ler_chg into l_susp_if_ctfn_not_prvd_flag;
    if c_ctfns_ler_chg%found then
      close c_ctfns_ler_chg;
      l_return := TRUE;
      p_ctfn_at_ler_chg := TRUE;
    else
      close c_ctfns_ler_chg;
      open c_ctfns_pgm;
      fetch c_ctfns_pgm into l_dummy;
      if c_ctfns_pgm%found then
        l_return := TRUE;
      else
        l_return := FALSE;
      end if;
      close c_ctfns_pgm;
    end if;
    --
  elsif p_lvl_cd = 'PTIP' then
    --
    -- At the ptip level, first check for ctfns defined for the ler change
    -- and then check for regular ctfns.
    --
    open c_ctfns_ler_chg;
    fetch c_ctfns_ler_chg into l_susp_if_ctfn_not_prvd_flag;
    if c_ctfns_ler_chg%found then
      close c_ctfns_ler_chg;
      l_return := TRUE;
      p_ctfn_at_ler_chg := TRUE;
    else
      close c_ctfns_ler_chg;
      open c_ctfns_ptip;
      fetch c_ctfns_ptip into l_dummy;
      if c_ctfns_ptip%found then
        l_return := TRUE;
      else
        l_return := FALSE;
      end if;
      close c_ctfns_ptip;
    end if;
    --
  else
    --
    -- At the plan level, first check for ctfns defined for the ler change
    -- and then check for regular ctfns.
    --
    open c_ctfns_ler_chg;
    fetch c_ctfns_ler_chg into l_susp_if_ctfn_not_prvd_flag;
    if c_ctfns_ler_chg%found then
      close c_ctfns_ler_chg;
      l_return := TRUE;
      p_ctfn_at_ler_chg := TRUE;
    else
      close c_ctfns_ler_chg;
      open c_ctfns_pl;
      fetch c_ctfns_pl into l_dummy;
      if c_ctfns_pl%found then
        l_return := TRUE;
      else
        l_return := FALSE;
      end if;
      close c_ctfns_pl;
    end if;
    --
  end if;
  --
  p_susp_if_ctfn_not_prvd_flag := l_susp_if_ctfn_not_prvd_flag;
  --
  if l_return then
    if g_debug then
      hr_utility.set_location('CTFNS are defined', 99);
    end if;
  else
    if g_debug then
      hr_utility.set_location('CTFNS not defined', 99);
    end if;
  end if;
  --
  if g_debug then
    hr_utility.set_location('Leaving ' || l_proc, 99);
  end if;
  --
  return l_return;
  --
end check_ctfns_defined;
--
-- -----------------------------------------------------------------------------
-- |-----------------------------< get_due_date >------------------------------|
-- -----------------------------------------------------------------------------
--
function get_due_date
  (p_prtt_enrt_rslt_id in number
  ,p_actn_typ_id       in number
  ,p_effective_date    in date
  ,p_business_group_id in number)
return date is
   --
   l_proc varchar2(80) := g_package || '.get_due_date';
  --
  -- Cursor to fetch the due date code for an action item. The action type can
  -- be defined at either the program or the plan level. If an action type is
  -- defined at both levels, then the one at the plan level should be selected.
  --
  cursor c_pl_popl_actn_typ(v_pl_id number) is
  select pat.popl_actn_typ_id,
         pat.effective_start_date,
         pat.effective_end_date,
         pat.actn_typ_due_dt_cd,
         pat.actn_typ_due_dt_rl
    from ben_popl_actn_typ_f pat
   where pat.pl_id = v_pl_id
     and pat.actn_typ_id = p_actn_typ_id
     and pat.business_group_id = p_business_group_id
     and p_effective_date between pat.effective_start_date
                              and pat.effective_end_date;
  --
  cursor c_pgm_popl_actn_typ(v_pgm_id number) is
  select pat.popl_actn_typ_id,
         pat.effective_start_date,
         pat.effective_end_date,
         pat.actn_typ_due_dt_cd,
         pat.actn_typ_due_dt_rl
    from ben_popl_actn_typ_f pat
   where pat.pgm_id = v_pgm_id
     and pat.actn_typ_id = p_actn_typ_id
     and pat.business_group_id = p_business_group_id
     and p_effective_date between pat.effective_start_date
                              and pat.effective_end_date;
  --
  l_pat c_pl_popl_actn_typ%rowtype;
  --
  -- Cursor to fetch elctbl_chc_id for the prtt_enrt_rslt_id
  --
  cursor c_elctbl_chc is
  select epe.elig_per_elctbl_chc_id,
         epe.pl_id,
         epe.pgm_id
    from ben_prtt_enrt_rslt_f pen,
         ben_elig_per_elctbl_chc epe,
         ben_per_in_ler pil
   where pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and pen.prtt_enrt_rslt_stat_cd is null
     and p_effective_date between
         pen.effective_start_date and pen.effective_end_date
     and pen.prtt_enrt_rslt_id = epe.prtt_enrt_rslt_id
     and pen.per_in_ler_id     = epe.per_in_ler_id
     and pil.per_in_ler_id = epe.per_in_ler_id
     and pil.business_group_id = p_business_group_id
     and pil.per_in_ler_stat_cd not in ('VOIDD', 'BCKDT');
  --
  l_elig_per_elctbl_chc_id number(15) := null;
  l_pl_id                  number;
  l_pgm_id                 number;
  --
  -- Cursor to fetch the start date for the enrollment period
  --
  l_returned_date date := null;
  --
  pat_not_found exception;
--
begin
--
  if g_debug then
    hr_utility.set_location ('Entering '||l_proc,10);
  end if;
  --
  if p_actn_typ_id is null then
    --
    fnd_message.set_name('BEN','BEN_91832_PACKAGE_PARAM_NULL');
    fnd_message.set_token('PACKAGE',l_proc);
    fnd_message.set_token('PROC','Enrollment Action Items');
    fnd_message.set_token('PARAM','p_actn_typ_id');
    fnd_message.raise_error;
    --
  end if;
  --
  open  c_elctbl_chc;
  fetch c_elctbl_chc into l_elig_per_elctbl_chc_id, l_pl_id, l_pgm_id;
  close c_elctbl_chc;
  --
  open c_pl_popl_actn_typ(l_pl_id);
  fetch c_pl_popl_actn_typ into l_pat;
  close c_pl_popl_actn_typ;
  --
  if l_pat.popl_actn_typ_id is null and
     l_pgm_id is not null then
    --
    open c_pgm_popl_actn_typ(l_pgm_id);
    fetch c_pgm_popl_actn_typ into l_pat;
    close c_pgm_popl_actn_typ;
    --
  end if;
  --
  if l_pat.popl_actn_typ_id is null then
    raise pat_not_found;
  end if;
  --
  --
  -- Call the ben_determine_date.main procedure
  --
  --
  -- Call the date routine only if the due date code is not null.
  --
  if l_pat.actn_typ_due_dt_cd is not null then
     --
--Bug 4610971 Passed the p_business_group_id to the procedure
-- ben_determine_date.main so that it ill be available to Action Type Due Date rule
     ben_determine_date.main
       (p_date_cd                => l_pat.actn_typ_due_dt_cd
       ,p_effective_date         => p_effective_date
       ,p_elig_per_elctbl_chc_id => l_elig_per_elctbl_chc_id
       ,p_formula_id             => l_pat.actn_typ_due_dt_rl
       ,p_business_group_id	 => p_business_group_id
       ,p_returned_date          => l_returned_date);
     --
--End Bug 4610971
  end if;
  --
  if g_debug then
    hr_utility.set_location ('Leaving '||l_proc,10);
  end if;
  --
  return l_returned_date;
  --
exception
  --
  when pat_not_found then
    --
    if g_debug then
      hr_utility.set_location('Leaving : ' || l_proc, 10);
    end if;
    l_returned_date := NULL;
    return l_returned_date;
    --
  when others then
    if g_debug then
      hr_utility.set_location('Exception Raised '||l_proc, 10);
    end if;
    raise;
--
end get_due_date;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< get_actn_typ_id >-----------------------------|
-- ----------------------------------------------------------------------------
--
function get_actn_typ_id
  (p_type_cd           in  varchar2
  ,p_business_group_id in  number)
return number is
  --
  -- Return the actn_typ_id or NULL when given the ben_actn_typ.type_cd
  -- type_cd examples DDDOB, DDSSN, BNFADDR, etc.
  -- note: future improvement could be to get this list once and then find
  -- the values from the pl/sql record
  --
  l_proc  varchar2(80);
  l_actn_typ_id     ben_actn_typ.actn_typ_id%type := NULL;
  --
  cursor c_actn_typ_id is
  select bat.actn_typ_id
    from ben_actn_typ bat
   where bat.type_cd = p_type_cd
     and bat.business_group_id = p_business_group_id;
--
begin
--
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_proc := g_package||'.get_actn_typ_id';
    hr_utility.set_location ('Entering '||l_proc,10);
  end if;
  --
  open c_actn_typ_id;
  fetch c_actn_typ_id into l_actn_typ_id;
  --
  if c_actn_typ_id%notfound then
    l_actn_typ_id := NULL;
  end if;
  --
  close c_actn_typ_id;
  --
  if g_debug then
    hr_utility.set_location ('Leaving '||l_proc, 10);
  end if;
  --
  return l_actn_typ_id;
  --
exception
  when others then
    if g_debug then
      hr_utility.set_location('Exception Raised '||l_proc, 10);
    end if;
    raise;
--
end get_actn_typ_id;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< get_prtt_enrt_actn_id >------------------------|
-- ----------------------------------------------------------------------------
--
procedure get_prtt_enrt_actn_id
  (p_actn_typ_id           in     number
  ,p_prtt_enrt_rslt_id     in     number
  ,p_elig_cvrd_dpnt_id     in     number default null
  ,p_pl_bnf_id             in     number default null
  ,p_effective_date        in     date
  ,p_business_group_id     in     number
  ,p_prtt_enrt_actn_id        out nocopy number
  ,p_cmpltd_dt                out nocopy date
  ,p_object_version_number in out nocopy number) is
  --
  -- This procedure returns the prtt_enrt_actn_id for either a general action
  -- type like DD that can only be associated with an enrt rslt or it can be
  -- used to retrieve a more specific action id like DDDOB which is tied to an
  -- eligible covered dependent using the elig_cvrd_dpnt_id
  --
  l_proc         varchar2(80);
  --
  -- Cursor to fetch an action item record that is not associated with any dpnt
  -- or a bnf but is tied to the participant's enrt rslt id and is of a general
  -- action type like DD or BNF
  --
  cursor c_enrt_actn is
  select pea.prtt_enrt_actn_id,
         pea.cmpltd_dt,
         pea.object_version_number
    from ben_prtt_enrt_actn_f pea,
         ben_per_in_ler pil
   where pea.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and pea.actn_typ_id = p_actn_typ_id
     and pea.pl_bnf_id is null
     and pea.elig_cvrd_dpnt_id is null
     and pea.per_in_ler_id = pil.per_in_ler_id
     and pil.per_in_ler_stat_cd not in ('BCKDT', 'VOIDD')
     and pea.business_group_id = p_business_group_id
     and p_effective_date between pea.effective_start_date
                              and pea.effective_end_date ;
  --
  l_enrt_actn c_enrt_actn%rowtype;
  l_object_version_number number(15);

  --
  -- Cursor to fetch an action item record for a particular dependent and for
  -- a particular action type.
  --
  cursor c_enrt_actn_dpnt is
  select pea.prtt_enrt_actn_id,
         pea.cmpltd_dt,
         pea.object_version_number
    from ben_prtt_enrt_actn_f pea,
         ben_per_in_ler pil
   where pea.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and pea.actn_typ_id = p_actn_typ_id
     and pea.per_in_ler_id = pil.per_in_ler_id
     and pil.per_in_ler_stat_cd not in ('BCKDT', 'VOIDD')
     and pea.elig_cvrd_dpnt_id = p_elig_cvrd_dpnt_id
     and pea.business_group_id = p_business_group_id
     and p_effective_date between pea.effective_start_date
                              and pea.effective_end_date;
  --
  l_enrt_actn_dpnt c_enrt_actn_dpnt%rowtype;
  --
  -- Cursor to fetch an action item record for a particular beneficiary and for
  -- a particular action type.
  --
  cursor c_enrt_actn_bnf is
  select pea.prtt_enrt_actn_id,
         pea.cmpltd_dt,
         pea.object_version_number
    from ben_prtt_enrt_actn_f pea,
         ben_per_in_ler pil
   where pea.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and pea.actn_typ_id = p_actn_typ_id
     and pea.pl_bnf_id = p_pl_bnf_id
     and pea.per_in_ler_id = pil.per_in_ler_id
     and pil.per_in_ler_stat_cd not in ('BCKDT', 'VOIDD')
     and pea.business_group_id = p_business_group_id
     and p_effective_date between pea.effective_start_date
                              and pea.effective_end_date;
  --
  l_enrt_actn_bnf c_enrt_actn_bnf%rowtype;

--
begin
--
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_proc         := g_package||'.get_prtt_enrt_actn_id';
    hr_utility.set_location ('Entering '||l_proc,10);
  end if;
  l_object_version_number := p_object_version_number ;

    hr_utility.set_location ('p_prtt_enrt_rslt_id '|| p_prtt_enrt_rslt_id,10);
    hr_utility.set_location ('p_elig_cvrd_dpnt_id '|| p_elig_cvrd_dpnt_id,10);
    hr_utility.set_location ('p_pl_bnf_id '|| p_pl_bnf_id,10);

  --
  if p_prtt_enrt_rslt_id is not null then
    --
    if p_elig_cvrd_dpnt_id is null and
       p_pl_bnf_id is null then
      --
      -- A general enrt action id was requested from the calling proc.
      -- Open the appropriate cursor
      --
      open c_enrt_actn;
      fetch c_enrt_actn into l_enrt_actn;
      --
      if c_enrt_actn%notfound then
        p_prtt_enrt_actn_id := NULL;
        p_cmpltd_dt    := NULL;
      else
        p_prtt_enrt_actn_id := l_enrt_actn.prtt_enrt_actn_id;
        p_cmpltd_dt    := l_enrt_actn.cmpltd_dt;
        p_object_version_number := l_enrt_actn.object_version_number;
      end if;
      --
      close c_enrt_actn;
      --
    hr_utility.set_location ('p_prtt_enrt_actn_id '|| p_prtt_enrt_actn_id,11);
    hr_utility.set_location ('p_cmpltd_dt '|| p_cmpltd_dt,11);



    elsif p_elig_cvrd_dpnt_id is not null and
          p_pl_bnf_id is null then
      --
      -- A request for a dependent's specific action item was made
      --
      open c_enrt_actn_dpnt;
      fetch c_enrt_actn_dpnt into l_enrt_actn_dpnt;
      --
      if c_enrt_actn_dpnt%notfound then
        p_prtt_enrt_actn_id := NULL;
        p_cmpltd_dt := NULL;
      else
        p_prtt_enrt_actn_id := l_enrt_actn_dpnt.prtt_enrt_actn_id;
        p_cmpltd_dt    := l_enrt_actn_dpnt.cmpltd_dt;
        p_object_version_number := l_enrt_actn_dpnt.object_version_number;
      end if;
      --
      close c_enrt_actn_dpnt;
      --
    hr_utility.set_location ('p_prtt_enrt_actn_id '|| p_prtt_enrt_actn_id,12);
    hr_utility.set_location ('p_cmpltd_dt '|| p_cmpltd_dt,12);

    elsif p_elig_cvrd_dpnt_id is null and
          p_pl_bnf_id is not null then
      --
      -- A request for a benefiary's specific action item was made
      --
      open c_enrt_actn_bnf;
      fetch c_enrt_actn_bnf into l_enrt_actn_bnf;
      --
      if c_enrt_actn_bnf%notfound then
        p_prtt_enrt_actn_id := NULL;
        p_cmpltd_dt := NULL;
      else
        p_prtt_enrt_actn_id := l_enrt_actn_bnf.prtt_enrt_actn_id;
        p_cmpltd_dt    := l_enrt_actn_bnf.cmpltd_dt;
        p_object_version_number := l_enrt_actn_bnf.object_version_number;
      end if;
      --
      close c_enrt_actn_bnf;
      --
    hr_utility.set_location ('p_prtt_enrt_actn_id '|| p_prtt_enrt_actn_id,13);
    hr_utility.set_location ('p_cmpltd_dt '|| p_cmpltd_dt,13);

    end if;
    --
  else
    -- p_enrt_rslt_id is null
    --
    p_prtt_enrt_actn_id := NULL;
    p_cmpltd_dt := NULL;
    p_object_version_number := NULL;
  end if;
  --
  if g_debug then
    hr_utility.set_location ('Leaving '||l_proc, 10);
  end if;
  --
exception
   when others then

     -- Init Variables for NOCOPY
     p_prtt_enrt_actn_id :=null ;
     p_cmpltd_dt         :=null ;
     p_object_version_number := l_object_version_number ;
     --
     if g_debug then
       hr_utility.set_location('Exception Raised '||l_proc, 10);
     end if;
     raise;
--
end get_prtt_enrt_actn_id;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< date_track_verify >---------------------------|
-- ----------------------------------------------------------------------------
--
function date_track_verify
  (p_dt_mode     in varchar2
  ,p_dflt_mode   in varchar2
  ,p_eff_date    in date
  ,p_start_date  in date)
return varchar2 is
--
  l_proc  varchar2(80);
  l_datetrack_mode varchar2(30);
--
begin
--
  if g_debug then
    l_proc  := g_package||'.date_track_verify';
    hr_utility.set_location ('Entering '||l_proc,10);
  end if;
  --
  -- Date track settings need some massaging right now.
  -- This routine is used to set the rules for mode settings depending
  -- on what we are passed and action we are doing.
  --
  if p_dt_mode IS NULL then
    l_datetrack_mode := p_dflt_mode;
  else
    l_datetrack_mode := p_dt_mode;
  end if;
  --
  -- there are other rules now that we must apply
  --
  if l_datetrack_mode = DTMODE_ZAP then
    -- zap mode converts to correction
    l_datetrack_mode := hr_api.g_correction;
    --
  elsif l_datetrack_mode = DTMODE_DELETE then
    -- delete mode converts to update
    l_datetrack_mode := DTMODE_UPDATE;
  elsif l_datetrack_mode = hr_api.g_future_change then
    l_datetrack_mode := DTMODE_UPDATE;
    --
  else
    -- Bug: 3510501: In all other cases, set date-track mode to 'UPDATE'.
    -- NULL;
    l_datetrack_mode := DTMODE_UPDATE;
  end if;
  --
  -- recheck the DTMODE_UPDATE by comparing effective date with effective start
  -- date
  --
  if l_datetrack_mode = DTMODE_UPDATE and
     p_eff_date IS NOT NULL and
     p_start_date IS NOT NULL and
     p_eff_date = p_start_date then
    l_datetrack_mode := hr_api.g_correction;
  end if;
  --
  if g_debug then
    hr_utility.set_location ('Leaving '||l_proc, 10);
  end if;
  --
  return l_datetrack_mode;
  --
exception
  when others then
    if g_debug then
      hr_utility.set_location('Exception Raised '||l_proc, 10);
    end if;
    raise;
--
end date_track_verify;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< write_new_action_item >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure write_new_action_item
  (p_prtt_enrt_rslt_id          in     number
  ,p_rslt_object_version_number in out nocopy number
  ,p_actn_typ_id                in     number
  ,p_elig_cvrd_dpnt_id          in     number   default null
  ,p_pl_bnf_id                  in     number   default null
  ,p_rqd_flag                   in     varchar2 default 'Y'
  ,p_cmpltd_dt                  in     date     default null
  ,p_effective_date             in     date
  ,p_business_group_id          in     number
  ,p_post_rslt_flag             in     varchar2 default 'Y'
  ,p_object_version_number         out nocopy number
  ,p_prtt_enrt_actn_id             out nocopy number) is
  --
   cursor c_act_name is
   select tl.name  actn_typ_name
    from ben_actn_typ typ,
         ben_actn_typ_tl tl
    where p_actn_typ_id = typ.actn_typ_id
     and typ.actn_typ_id = tl.actn_typ_id
     and tl.language     = userenv('lang')
     and typ.type_cd <> 'BNF'
     and typ.type_cd like 'BNF%'
     and typ.business_group_id = p_business_group_id;
  --
  cursor c_pl_name is
    select pln.name,
           pen.person_id
    from ben_pl_f pln,
         ben_prtt_enrt_rslt_f pen
    where pln.pl_id = pen.pl_id
    and pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id  /* Bug 4039404 */
    and pen.prtt_enrt_rslt_stat_cd is null
    and p_effective_date between pln.effective_Start_date
        and pln.effective_end_date
    and p_effective_date between pen.effective_Start_date
        and pen.effective_end_date;
  --
  l_act_name    varchar2(300);
  l_pl_name     varchar2(300);
  l_person_id   number;
  l_proc  varchar2(80);
  l_effective_start_date date;
  l_effective_end_date   date;
  l_due_dt               date;
  l_rslt_object_version_number number(15);
  l_message1     varchar2(300) := 'BEN_94108_BNF_ACT_ITEM';

--
begin
--
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_proc  := g_package||'.write_new_action_item';
    hr_utility.set_location ('Entering '||l_proc,10);
  end if;
  l_rslt_object_version_number := p_rslt_object_version_number ;
  --
  -- Get the due date for the action item
  --
  l_due_dt := get_due_date
                  (p_prtt_enrt_rslt_id => p_prtt_enrt_rslt_id
                  ,p_actn_typ_id       => p_actn_typ_id
                  ,p_effective_date    => p_effective_date
                  ,p_business_group_id => p_business_group_id);
  --
  -- Using table api write a new record for an action item
  --
  ben_prtt_enrt_actn_api.create_prtt_enrt_actn
    (p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
    ,p_rslt_object_version_number => p_rslt_object_version_number
    ,p_actn_typ_id                => p_actn_typ_id
    ,p_elig_cvrd_dpnt_id          => p_elig_cvrd_dpnt_id
    ,p_pl_bnf_id                  => p_pl_bnf_id
    ,p_due_dt                     => l_due_dt
    ,p_rqd_flag                   => p_rqd_flag
    ,p_cmpltd_dt                  => p_cmpltd_dt
    ,p_effective_date             => p_effective_date
    ,p_post_rslt_flag             => p_post_rslt_flag
    ,p_business_group_id          => p_business_group_id
    ,p_object_version_number      => p_object_version_number
    ,p_effective_start_date       => l_effective_start_date
    ,p_effective_end_date         => l_effective_end_date
    ,p_prtt_enrt_actn_id          => p_prtt_enrt_actn_id);
  if p_pl_bnf_id is not null then
    --
    open c_act_name;
    fetch c_act_name into l_act_name;
    close c_act_name;
    --
    open c_pl_name;
    fetch c_pl_name into l_pl_name, l_person_id;
    close c_pl_name;
    --

    ben_warnings.load_warning
        (p_application_short_name  => 'BEN',
        p_message_name            => l_message1,
        p_parma     => l_act_name,
        p_parmb     => l_pl_name,
        p_person_id => l_person_id);

  --
  end if;
  --
  if g_debug then
    hr_utility.set_location ('Leaving '||l_proc, 10);
  end if;
  --
exception
  when others then


    -- Init Variables for NOCOPY
    p_rslt_object_version_number :=l_rslt_object_version_number;
    p_object_version_number :=null;
    p_prtt_enrt_actn_id     :=null;

    if g_debug then
      hr_utility.set_location('Exception Raised '||l_proc, 10);
    end if;
    raise;
--
end write_new_action_item;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< write_new_dpnt_ctfn_item >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure write_new_dpnt_ctfn_item
  (p_elig_cvrd_dpnt_id       in     number
  ,p_prtt_enrt_actn_id       in     number
  ,p_dpnt_dsgn_ctfn_typ_cd   in     varchar2
  ,p_dpnt_dsgn_ctfn_rqd_flag in     varchar2
  ,p_effective_date          in     date
  ,p_business_group_id       in     number
  ,p_object_version_number      out nocopy number
  ,p_cvrd_dpnt_ctfn_prvdd_id    out nocopy number) is
  --
  -- this procedure writes a dependent certification to
  -- ben_cvrd_dpnt_ctfn_prvdd_f
  --
  l_proc  varchar2(80);
  l_effective_start_date date;
  l_effective_end_date   date;
--
begin
--
  if g_debug then
    l_proc  := g_package||'.write_new_dpnt_ctfn_item';
    hr_utility.set_location ('Entering '||l_proc,10);
  end if;
  --
  -- write a new record for a dependent certification item
  --
  ben_cvrd_dpnt_ctfn_prvdd_api.create_cvrd_dpnt_ctfn_prvdd
    (p_elig_cvrd_dpnt_id       => p_elig_cvrd_dpnt_id
    ,p_prtt_enrt_actn_id       => p_prtt_enrt_actn_id
    ,p_dpnt_dsgn_ctfn_typ_cd   => p_dpnt_dsgn_ctfn_typ_cd
    ,p_dpnt_dsgn_ctfn_rqd_flag => p_dpnt_dsgn_ctfn_rqd_flag
    ,p_effective_date          => p_effective_date
    ,p_business_group_id       => p_business_group_id
    ,p_object_version_number   => p_object_version_number
    ,p_effective_start_date    => l_effective_start_date
    ,p_effective_end_date      => l_effective_end_date
    ,p_cvrd_dpnt_ctfn_prvdd_id => p_cvrd_dpnt_ctfn_prvdd_id
    ,p_program_application_id  => fnd_global.prog_appl_id
    ,p_program_id              => fnd_global.conc_program_id
    ,p_request_id              => fnd_global.conc_request_id
    ,p_program_update_date     => sysdate);
  --
  if g_debug then
    hr_utility.set_location ('Leaving '||l_proc, 10);
  end if;
  --
exception
   /* we could have duplicates already here from prior run
    - BEN_91632_DUP_DPNT_CTFN */
   when others then

     -- Init Variables for NOCOPY
     p_object_version_number :=null ;
     p_cvrd_dpnt_ctfn_prvdd_id :=null ;
     if g_debug then
       hr_utility.set_location('Exception Raised '||l_proc, 10);
     end if;
     raise;
--
end write_new_dpnt_ctfn_item;
--
-- ----------------------------------------------------------------------------
-- |-------------------< write_new_prtt_ctfn_prvdd_item >---------------------|
-- ----------------------------------------------------------------------------
--
procedure write_new_prtt_ctfn_prvdd_item
  (p_rqd_flag                in     varchar2
  ,p_enrt_ctfn_typ_cd        in     varchar2
  ,p_enrt_r_bnft_ctfn_cd     in     varchar2
  ,p_prtt_enrt_rslt_id       in     number
  ,p_prtt_enrt_actn_id       in     number
  ,p_effective_date          in     date
  ,p_business_group_id       in     number
  ,p_object_version_number      out nocopy number
  ,p_prtt_enrt_ctfn_prvdd_id    out nocopy number) is
  --
  -- Does this ctfn already exist for this action item?
  --
  cursor c_ctfn_exists is
    select null
    from ben_prtt_enrt_ctfn_prvdd_f ecp
    where ecp.enrt_ctfn_typ_cd=p_enrt_ctfn_typ_cd
      and ecp.enrt_ctfn_rqd_flag=p_rqd_flag
      and p_effective_date between
          ecp.effective_start_date and ecp.effective_end_date
      and ecp.business_group_id=p_business_group_id
      and ecp.prtt_enrt_actn_id=p_prtt_enrt_actn_id
      and exists    -- Bug 6022327: Changed from not exists to exists
      ( select pea.prtt_enrt_actn_id
        from ben_prtt_enrt_actn_f pea,
             ben_per_in_ler pil
        where pea.per_in_ler_id = pil.per_in_ler_id
          and pil.per_in_ler_stat_cd not in ('BCKDT', 'VOIDD')
          and pea.prtt_enrt_actn_id = p_prtt_enrt_actn_id
          and p_effective_date between
              pea.effective_start_date and pea.effective_end_date);
  --
  -- this procedure writes to the ben_prtt_enrt_ctfn_prvdd_f
  --
  l_proc  varchar2(80);
  l_effective_start_date date;
  l_effective_end_date   date;
  l_ctfn_exists varchar2(30):='N';
--
begin
--
  if g_debug then
    l_proc  := g_package||'.write_new_prtt_ctfn_prvdd_item';
    hr_utility.set_location ('Entering '||l_proc,10);
  end if;
  --
  -- write a new record for a participant certification item
  --
  -- if it does not already exist
  --
  open c_ctfn_exists;
  fetch c_ctfn_exists into l_ctfn_exists;
  close c_ctfn_exists;
  if l_ctfn_exists='N' then
    ben_prtt_enrt_ctfn_prvdd_api.create_prtt_enrt_ctfn_prvdd
      (p_enrt_ctfn_rqd_flag      => p_rqd_flag
      ,p_enrt_ctfn_typ_cd        => p_enrt_ctfn_typ_cd
      ,p_enrt_r_bnft_ctfn_cd      => p_enrt_r_bnft_ctfn_cd
      ,p_prtt_enrt_rslt_id       => p_prtt_enrt_rslt_id
      ,p_prtt_enrt_actn_id       => p_prtt_enrt_actn_id
      ,p_effective_date          => p_effective_date
      ,p_business_group_id       => p_business_group_id
      ,p_object_version_number   => p_object_version_number
      ,p_effective_start_date    => l_effective_start_date
      ,p_effective_end_date      => l_effective_end_date
      ,p_prtt_enrt_ctfn_prvdd_id => p_prtt_enrt_ctfn_prvdd_id
    );
  else
    hr_utility.set_location ('Already certification exists. No need to create new one', 10);
  end if;
  --
  if g_debug then
    hr_utility.set_location ('Leaving '||l_proc, 10);
  end if;
  --
exception
  when others then

    -- Init Variables for NOCOPY
    p_object_version_number  := null ;
    p_prtt_enrt_ctfn_prvdd_id:= null;

    if g_debug then
      hr_utility.set_location('Exception Raised '||l_proc, 10);
    end if;
    raise;
--
end write_new_prtt_ctfn_prvdd_item;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< set_cmpltd_dt >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure set_cmpltd_dt
  (p_prtt_enrt_actn_id          in     number
  ,p_prtt_enrt_rslt_id          in     number
  ,p_rslt_object_version_number in out nocopy number
  ,p_actn_typ_id                in     number
  ,p_rqd_flag                   in     varchar2 default 'Y'
  ,p_effective_date             in     date
  ,p_post_rslt_flag             in     varchar2 default 'Y'
  ,p_business_group_id          in     number
  ,p_object_version_number      in out nocopy number
  ,p_open_close                 in     varchar2
  ,p_datetrack_mode             in     varchar2 default hr_api.g_correction) is
  --
  l_proc  varchar2(80);
  l_datetrack_mode varchar2(30);
	-- bug 6010780
	l_datetrack_mode2 varchar2(30);
  l_cmpltd_dt date := NULL;
  l_effective_start_date date;
  l_effective_end_date   date;
  l_rslt_object_version_number number ;
  l_object_version_number      number ;

  --
  -- the cursor is for datetrack mode verify
  --
  cursor c_start_date is
  select pea.effective_start_date
    from ben_prtt_enrt_actn_f pea
   where pea.prtt_enrt_actn_id = p_prtt_enrt_actn_id
     and pea.business_group_id = p_business_group_id
     and p_effective_date  between pea.effective_start_date
                               and pea.effective_end_date;
  --
  cursor c_future_row is
    select object_version_number
    from ben_prtt_enrt_actn_f pea
    where pea.prtt_enrt_actn_id = p_prtt_enrt_actn_id
     and pea.business_group_id = p_business_group_id
     and p_effective_date  < pea.effective_start_date
     ;
  --
  --BUG 4558512 new cursors to determine the right completion date
  --
  cursor c_pcs(p_prtt_enrt_rslt_id number,p_prtt_enrt_actn_id number) is
     select  max(pcs.enrt_ctfn_recd_dt) ctfn_recd_dt
     from    ben_prtt_enrt_ctfn_prvdd_f pcs
     where   pcs.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and     pcs.prtt_enrt_actn_id = p_prtt_enrt_actn_id
     and     p_effective_date between
             pcs.effective_start_date and pcs.effective_end_date;
  --
  cursor c_ccp(p_prtt_enrt_actn_id number) is
     select  max(ccp.dpnt_dsgn_ctfn_recd_dt) ctfn_recd_dt
     from    ben_cvrd_dpnt_ctfn_prvdd_f ccp,
             ben_prtt_enrt_actn_f pea
     where   ccp.prtt_enrt_actn_id = p_prtt_enrt_actn_id
     and     pea.prtt_enrt_actn_id = p_prtt_enrt_actn_id
     and     ccp.elig_cvrd_dpnt_id = pea.elig_cvrd_dpnt_id
     and     p_effective_date between
             pea.effective_start_date and pea.effective_end_date
     and     p_effective_date between
             ccp.effective_start_date and ccp.effective_end_date;
  --
  cursor c_pbc(p_prtt_enrt_actn_id number) is
     select  max(pbc.bnf_ctfn_recd_dt) ctfn_recd_dt
     from    ben_pl_bnf_ctfn_prvdd_f pbc,
             ben_prtt_enrt_actn_f pea
     where   pbc.prtt_enrt_actn_id = p_prtt_enrt_actn_id
     and     pea.prtt_enrt_actn_id = p_prtt_enrt_actn_id
     and     pbc.pl_bnf_id = pea.pl_bnf_id
     and     p_effective_date between
             pea.effective_start_date and pea.effective_end_date
     and     p_effective_date between
             pbc.effective_start_date and pbc.effective_end_date;
  --
  l_object_version_number2  number;
  l_start_date c_start_date%rowtype;
  l_dummy_number  number;
  l_prvdd_dt     date := NULL;

  --
 cursor c_curr_ovn_of_actn (c_prtt_enrt_actn_id number) is
  select object_version_number
    from ben_prtt_enrt_actn_f
    where prtt_enrt_actn_id = c_prtt_enrt_actn_id
      and business_group_id = p_business_group_id
      and p_effective_date between effective_start_date
           and effective_end_date;

 curr_ovn ben_prtt_enrt_actn_f.object_version_number%TYPE;
  --
--
begin
--
  if g_debug then
    l_proc  := g_package||'.set_cmpltd_dt';
    hr_utility.set_location ('Entering '||l_proc,10);
    hr_utility.set_location('p_prtt_enrt_actn_id '||p_prtt_enrt_actn_id,119);
    hr_utility.set_location('p_prtt_enrt_rslt_id '||p_prtt_enrt_rslt_id,119);
    --
  end if;
  --

  l_rslt_object_version_number := p_rslt_object_version_number ;
  l_object_version_number      := p_object_version_number      ;

  -- Using table api update existing record for an action item
  -- setting the cmpltd_dt to effective_date
  --
  open c_start_date;
  fetch c_start_date into l_start_date;
  close c_start_date;
  --
  if p_open_close = 'OPEN' then
    l_cmpltd_dt := NULL;
  elsif p_open_close = 'CLOSE' then
    --
    if p_prtt_enrt_rslt_id is not null and
       p_prtt_enrt_actn_id is not null then
      --
      open c_pcs(p_prtt_enrt_rslt_id,p_prtt_enrt_actn_id);
        fetch c_pcs into l_prvdd_dt ;
      close c_pcs ;
      --
    end if;
    --
    l_cmpltd_dt := l_prvdd_dt ;
    --
    hr_utility.set_location('FIRST l_cmpltd_dt '||l_cmpltd_dt,119);
    --
    open c_ccp(p_prtt_enrt_actn_id);
      fetch c_ccp into l_prvdd_dt ;
    close c_ccp ;
    --
    if l_prvdd_dt > nvl(l_cmpltd_dt,l_prvdd_dt-1) then
      l_cmpltd_dt := l_prvdd_dt ;
    end if;
    --
    hr_utility.set_location('SECOND l_cmpltd_dt '||l_cmpltd_dt,119);
    --
    open c_pbc(p_prtt_enrt_actn_id);
      fetch c_pbc into l_prvdd_dt ;
    close c_pbc ;
    --
    if l_prvdd_dt > nvl(l_cmpltd_dt,l_prvdd_dt-1) then
      l_cmpltd_dt := l_prvdd_dt ;
    end if;
    --
    hr_utility.set_location(' p_effective_date '||p_effective_date,119);
    hr_utility.set_location(' l_cmpltd_dt '||l_cmpltd_dt,119);
    l_cmpltd_dt := nvl(l_cmpltd_dt,p_effective_date) ;
    --
  end if;
  --
  l_datetrack_mode := date_track_verify
    (p_dt_mode        => p_datetrack_mode
    ,p_dflt_mode      => DTMODE_CORRECT
    ,p_eff_date       => p_effective_date
    ,p_start_date     => l_start_date.effective_start_date);
  --
  -- if p_datetrack_mode = hr_api.g_future_change then -- bug 6010780
    --
    open c_future_row;
    fetch c_future_row into l_object_version_number2;
    close c_future_row;
    --
  -- end if;
  if l_object_version_number2 is not null
      and p_datetrack_mode = hr_api.g_future_change
  then -- future rows exists
    --
    ben_prtt_enrt_actn_api.delete_PRTT_ENRT_ACTN
    (
     p_prtt_enrt_actn_id              => p_prtt_enrt_actn_id
    ,p_business_group_id              => p_business_group_id
    ,p_effective_date                 => p_effective_date
    ,p_datetrack_mode                 => p_datetrack_mode
    ,p_object_version_number          => p_object_version_number
    ,p_unsuspend_enrt_flag            => 'N'
    ,p_prtt_enrt_rslt_id              => p_prtt_enrt_rslt_id
    ,p_rslt_object_version_number     => l_dummy_number
    ,p_effective_start_date           => l_effective_start_date
    ,p_effective_end_date             => l_effective_end_date
    );
    --
  else
   --
        -- bug 6010780
        if l_object_version_number2 is not null then
                l_datetrack_mode2 := 'FUTURE_CHANGE';

                hr_utility.set_location(' Future change exists fo update or correction ', 121 );
                hr_utility.set_location(' p_object_version_number 1  ' || p_object_version_number , 121 );

                ben_prtt_enrt_actn_api.delete_prtt_enrt_actn
                (p_prtt_enrt_actn_id               => p_prtt_enrt_actn_id,
                p_business_group_id               => p_business_group_id,
                p_effective_date                  => p_effective_date,
                p_datetrack_mode                  => l_datetrack_mode2,
                p_object_version_number           => p_object_version_number,
                p_unsuspend_enrt_flag             => 'N',
                p_prtt_enrt_rslt_id               => p_prtt_enrt_rslt_id,
                p_rslt_object_version_number      => l_dummy_number,
                p_effective_start_date            => l_effective_start_date,
                p_effective_end_date              => l_effective_end_date
                );
        end if;
    hr_utility.set_location(' p_object_version_number 2  ' || p_object_version_number , 121 );
    open c_curr_ovn_of_actn(p_prtt_enrt_actn_id);
    fetch c_curr_ovn_of_actn into curr_ovn;
    close c_curr_ovn_of_actn;
    hr_utility.set_location('curr_ovn ' || curr_ovn , 121 );
    if curr_ovn is not null then
    ben_prtt_enrt_actn_api.update_prtt_enrt_actn
      (p_cmpltd_dt                  => l_cmpltd_dt
      ,p_prtt_enrt_actn_id          => p_prtt_enrt_actn_id
      ,p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
      ,p_rslt_object_version_number => p_rslt_object_version_number
      ,p_actn_typ_id                => p_actn_typ_id
      ,p_rqd_flag                   => p_rqd_flag
      ,p_effective_date             => p_effective_date
      ,p_post_rslt_flag             => p_post_rslt_flag
      ,p_business_group_id          => p_business_group_id
      ,p_effective_start_date       => l_effective_start_date
      ,p_effective_end_date         => l_effective_end_date
      -- ,p_object_version_number      => p_object_version_number 6010780
      ,p_object_version_number      => curr_ovn
      ,p_datetrack_mode             => l_datetrack_mode
      );
   end if;
   end if;
  --
  if g_debug then
    hr_utility.set_location ('Leaving '||l_proc, 10);
  end if;
  --
exception
  when others then

    if g_debug then
      hr_utility.set_location('Exception Raised '||l_proc, 10);
    end if;
    -- Init Variables for NOCOPY
    p_rslt_object_version_number := l_rslt_object_version_number ;
    p_object_version_number      := l_object_version_number ;

    raise;
--
end set_cmpltd_dt;
--
-- ----------------------------------------------------------------------------
-- |---------------------< complete_this_action_item >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure complete_this_action_item
  (p_prtt_enrt_actn_id  in number
  ,p_effective_date     in date
  ,p_validate           in boolean  default false
  ,p_datetrack_mode     in varchar2 default hr_api.g_correction
  ,p_post_rslt_flag     in varchar2 default 'Y') is
  --
  -- this procedure will set the completed date for a single open action item
  -- for a participant result both dependent and beneficiary
  --
  l_proc  varchar2(80);
  --
  cursor c_actn_this is
  select pea.prtt_enrt_rslt_id,
         pea.actn_typ_id,
         pea.object_version_number,
         pea.business_group_id,
         pea.effective_start_date,
         pea.effective_end_date,
         pen.object_version_number rslt_object_version_number
    from ben_prtt_enrt_actn_f pea,
         ben_prtt_enrt_rslt_f pen
   where pea.prtt_enrt_actn_id = p_prtt_enrt_actn_id
     and pea.cmpltd_dt IS NULL
     and pen.prtt_enrt_rslt_stat_cd is null
     and p_effective_date between pea.effective_start_date
                              and pea.effective_end_date
     and pea.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
     and p_effective_date between pen.effective_start_date
                              and pen.effective_end_date
  ;
--
begin
--
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_proc  := g_package||'.complete_this_action_item';
    hr_utility.set_location ('Entering '||l_proc,10);
  end if;
  --
  -- Using table api update the record for an action item
  --
  for l_actn_this in c_actn_this loop
    --
    set_cmpltd_dt
      (p_prtt_enrt_actn_id          => p_prtt_enrt_actn_id
      ,p_prtt_enrt_rslt_id          => l_actn_this.prtt_enrt_rslt_id
      ,p_rslt_object_version_number => l_actn_this.rslt_object_version_number
      ,p_actn_typ_id                => l_actn_this.actn_typ_id
      ,p_effective_date             => p_effective_date
      ,p_post_rslt_flag             => p_post_rslt_flag
      ,p_business_group_id          => l_actn_this.business_group_id
      ,p_object_version_number      => l_actn_this.object_version_number
      ,p_open_close                 => 'CLOSE'
      ,p_datetrack_mode             => p_datetrack_mode);
    --
  end loop;
  --
  if g_debug then
    hr_utility.set_location ('Leaving '||l_proc, 10);
  end if;
  --
exception
   when others then
     if g_debug then
       hr_utility.set_location('Exception Raised '||l_proc, 10);
     end if;
     raise;
--
end complete_this_action_item;
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_prtt_ctfn_prvdd >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_prtt_ctfn_prvdd
  (p_prtt_enrt_ctfn_prvdd_id in     number
  ,p_object_version_number   in out nocopy number
  ,p_effective_date          in     date
  ,p_datetrack_mode          in     varchar2 default DTMODE_DELETE) is
  --
  -- for participant certifications
  -- this procedure datetrack deletes the ben_prtt_enrt_ctfn_prvdd_f
  --
  l_proc  varchar2(80);
  l_effective_start_date date;
  l_effective_end_date   date;
  l_object_version_number number(15);

--
begin
--
  if g_debug then
    l_proc  := g_package||'.delete_prtt_ctfn_prvdd';
    hr_utility.set_location ('Entering '||l_proc,10);
  end if;
  --
  l_object_version_number := p_object_version_number ;

  -- date track delete the record for a participant certification item
  --
  ben_prtt_enrt_ctfn_prvdd_api.delete_prtt_enrt_ctfn_prvdd
    (p_prtt_enrt_ctfn_prvdd_id => p_prtt_enrt_ctfn_prvdd_id
    ,p_effective_start_date    => l_effective_start_date
    ,p_effective_end_date      => l_effective_end_date
    ,p_object_version_number   => p_object_version_number
    ,p_effective_date          => p_effective_date
    ,p_datetrack_mode          => p_datetrack_mode);
  --
  if g_debug then
    hr_utility.set_location ('Leaving '||l_proc, 10);
  end if;
  --
exception
  when others then

    if g_debug then
      hr_utility.set_location('Exception Raised '||l_proc, 10);
    end if;
    p_object_version_number  := l_object_version_number ;

    raise;
--
end delete_prtt_ctfn_prvdd;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_dpnt_ctfn_prvdd >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_dpnt_ctfn_prvdd
  (p_cvrd_dpnt_ctfn_prvdd_id in     number
  ,p_object_version_number   in out nocopy number
  ,p_effective_date          in     date
  ,p_business_group_id       in     number
  ,p_datetrack_mode          in     varchar2 default DTMODE_DELETE) is
  --
  -- for a dependent certification for a participant
  -- datetrack_mode delete
  --
  l_proc  varchar2(80);
  l_effective_start_date date;
  l_effective_end_date   date;
  l_object_version_number number(15);

--
begin
--
  if g_debug then
    l_proc  := g_package||'.delete_dpnt_ctfn_prvdd';
    hr_utility.set_location ('Entering '||l_proc,10);
  end if;
  --
  l_object_version_number := p_object_version_number ;

  -- date track delete the record for a dependent certification item
  --
  ben_cvrd_dpnt_ctfn_prvdd_api.delete_cvrd_dpnt_ctfn_prvdd
    (p_cvrd_dpnt_ctfn_prvdd_id => p_cvrd_dpnt_ctfn_prvdd_id
    ,p_effective_start_date    => l_effective_start_date
    ,p_effective_end_date      => l_effective_end_date
    ,p_object_version_number   => p_object_version_number
    ,p_effective_date          => p_effective_date
    ,p_business_group_id       => p_business_group_id
    ,p_datetrack_mode          => p_datetrack_mode
    ,p_called_from             => 'benactcm' );
  --
  if g_debug then
    hr_utility.set_location ('Leaving '||l_proc, 10);
  end if;
  --
exception
  when others then
    if g_debug then
      hr_utility.set_location('Exception Raised '||l_proc, 10);
    end if;
    p_object_version_number := l_object_version_number ;
    raise;
--
end delete_dpnt_ctfn_prvdd;
--
-- ----------------------------------------------------------------------------
-- |----------------------< remove_prtt_certifications >----------------------|
-- ----------------------------------------------------------------------------
--
procedure remove_prtt_certifications
  (p_prtt_enrt_rslt_id  in number
  ,p_effective_date     in date
  ,p_business_group_id  in number
  ,p_datetrack_mode     in varchar2 default DTMODE_DELETE) is
  --
  -- this procedure removes participant certifications from
  -- ben_prtt_enrt_ctfn_prvdd_f. This is datetrack_mode controlled
  --
  l_proc  varchar2(80);
  -- CFW2
  cursor c_prtt_ctfn_prvdd is
  select pcs.prtt_enrt_ctfn_prvdd_id,
         pcs.object_version_number
    from ben_prtt_enrt_ctfn_prvdd_f pcs,
         ben_prtt_enrt_actn_f pea,
         ben_per_in_ler pil
   where pcs.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and pcs.enrt_ctfn_recd_dt is NULL
     and pcs.business_group_id = p_business_group_id
     and p_effective_date between pcs.effective_start_date
                              and pcs.effective_end_date
     and pea.prtt_enrt_actn_id=pcs.prtt_enrt_actn_id
     and pea.pl_bnf_id is null
     and pea.elig_cvrd_dpnt_id is null
     and pea.per_in_ler_id = pil.per_in_ler_id
     and pil.per_in_ler_stat_cd not in ('BCKDT', 'VOIDD')
     and pea.business_group_id=p_business_group_id
     and p_effective_date between pea.effective_start_date
                              and pea.effective_end_date
  ;
--
begin
--
  if g_debug then
    l_proc  := g_package||'.remove_prtt_certifications';
    hr_utility.set_location ('Entering '||l_proc,10);
  end if;
  --
  -- Using table api write a new record for an action item
  --
  for l_prtt_ctfn_prvdd in c_prtt_ctfn_prvdd loop
    --
    delete_prtt_ctfn_prvdd
      (p_prtt_enrt_ctfn_prvdd_id => l_prtt_ctfn_prvdd.prtt_enrt_ctfn_prvdd_id
      ,p_object_version_number   => l_prtt_ctfn_prvdd.object_version_number
      ,p_effective_date          => p_effective_date
      ,p_datetrack_mode          => p_datetrack_mode);
    --
  end loop;
  --
  if g_debug then
    hr_utility.set_location ('Leaving '||l_proc, 10);
  end if;
  --
exception
  when others then
    if g_debug then
      hr_utility.set_location('Exception Raised '||l_proc, 10);
    end if;
    raise;
--
end remove_prtt_certifications;
--
-- ----------------------------------------------------------------------------
-- |----------------------< remove_dpnt_certifications >----------------------|
-- ----------------------------------------------------------------------------
--
procedure remove_dpnt_certifications
  (p_prtt_enrt_rslt_id    in     number
  ,p_effective_date       in     date
  ,p_business_group_id    in     number
  ,p_datetrack_mode       in     varchar2 default DTMODE_DELETE
  ,p_effective_start_date    out nocopy date
  ,p_effective_end_date      out nocopy date) is
  --
  -- this procedure removes certifications for dependents of a participant
  -- if cvrd_flag = Y and dpnt_dsgn_ctfn_recd_dt is NULL
  -- this is datetrack_mode controlled
  --
  l_proc  varchar2(80);

  --
  cursor c_dpnt_ctfn_prvdd is
  select prv.cvrd_dpnt_ctfn_prvdd_id,
         prv.object_version_number
    from ben_elig_cvrd_dpnt_f ecd, ben_cvrd_dpnt_ctfn_prvdd_f prv,
         ben_per_in_ler pil
   where ecd.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and ecd.cvg_strt_dt is not null
     and nvl(ecd.cvg_thru_dt, hr_api.g_eot) = hr_api.g_eot
     and ecd.elig_cvrd_dpnt_id = prv.elig_cvrd_dpnt_id
     and prv.dpnt_dsgn_ctfn_recd_dt is NULL
     and ecd.business_group_id = p_business_group_id
     and p_effective_date between ecd.effective_start_date
                              and ecd.effective_end_date
     and prv.business_group_id = p_business_group_id
     and p_effective_date between prv.effective_start_date
                              and prv.effective_end_date
     and pil.per_in_ler_id=ecd.per_in_ler_id
     and pil.business_group_id=p_business_group_id
     and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT');
--
begin
--
  if g_debug then
    l_proc  := g_package||'.remove_dpnt_certifications';
    hr_utility.set_location ('Entering '||l_proc,10);
  end if;
  --
  for l_dpnt_ctfn_prvdd in c_dpnt_ctfn_prvdd loop
    --
    delete_dpnt_ctfn_prvdd
      (p_cvrd_dpnt_ctfn_prvdd_id => l_dpnt_ctfn_prvdd.cvrd_dpnt_ctfn_prvdd_id
      ,p_object_version_number   => l_dpnt_ctfn_prvdd.object_version_number
      ,p_effective_date          => p_effective_date
      ,p_business_group_id       => p_business_group_id
      ,p_datetrack_mode          => p_datetrack_mode);
  --
  end loop;
  --
  if g_debug then
    hr_utility.set_location ('Leaving '||l_proc, 10);
  end if;
  --
exception
  when others then
    p_effective_start_date := null;
    p_effective_end_date   := null;

    if g_debug then
      hr_utility.set_location('Exception Raised '||l_proc, 10);
    end if;
    raise;
--
end remove_dpnt_certifications;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_action_item >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_action_item
  (p_prtt_enrt_actn_id          in     number
  ,p_object_version_number      in out nocopy number
  ,p_business_group_id          in     number
  ,p_effective_date             in     date
  ,p_datetrack_mode             in     varchar2 default DTMODE_DELETE
  ,p_prtt_enrt_rslt_id          in     number
  ,p_rslt_object_version_number in out nocopy number
  ,p_post_rslt_flag             in     varchar2) is
  --
  l_proc  varchar2(80);
  l_effective_start_date date;
  l_effective_end_date   date;
  l_object_version_number       number(15);
  l_rslt_object_version_number  number(15);

--
begin
--
  if g_debug then
    l_proc  := g_package||'.delete_action_item';
    hr_utility.set_location ('Entering '||l_proc,10);
  end if;
  if g_debug then
    hr_utility.set_location(p_datetrack_mode || ' ' || l_proc, 10);
  end if;
  --
  l_object_version_number      := p_object_version_number;
  l_rslt_object_version_number := p_rslt_object_version_number ;

  -- Using table api datetrack delete the record for an action item
  --
  ben_prtt_enrt_actn_api.delete_prtt_enrt_actn
    (p_prtt_enrt_actn_id          => p_prtt_enrt_actn_id
    ,p_business_group_id          => p_business_group_id
    ,p_effective_date             => p_effective_date
    ,p_datetrack_mode             => p_datetrack_mode
    ,p_object_version_number      => p_object_version_number
    ,p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
    ,p_rslt_object_version_number => p_rslt_object_version_number
    ,p_post_rslt_flag             => p_post_rslt_flag
    ,p_effective_start_date       => l_effective_start_date
    ,p_effective_end_date         => l_effective_end_date);
  --
  if g_debug then
    hr_utility.set_location ('Leaving '||l_proc, 10);
  end if;
  --
exception
  when others then
    if g_debug then
      hr_utility.set_location('Exception Raised '||l_proc, 10);
    end if;
    p_object_version_number := l_object_version_number ;
    p_rslt_object_version_number := l_rslt_object_version_number ;
    raise;
--
end delete_action_item;
--
--
procedure get_ctfn_count
      (p_prtt_enrt_actn_id    in number,
       p_prtt_enrt_rslt_id    in number default null,
       p_elig_cvrd_dpnt_id    in number default null,
       p_pl_bnf_id            in number default null,
       p_effective_date       in date,
       p_optional_count       out nocopy number,
       p_required_count       out nocopy number,
       p_open_optional_count  out nocopy number,
       p_open_required_count  out nocopy number) is
  --
  cursor c_pcs is
     select  sum(1) tot_ctfn,
             sum(decode(pcs.enrt_ctfn_rqd_flag,'Y',1,0)) tot_rqd,
             sum(decode(pcs.enrt_ctfn_recd_dt,null,1,0)) tot_open_ctfn,
             sum(decode(pcs.enrt_ctfn_rqd_flag,'N',0,
                        decode(pcs.enrt_ctfn_recd_dt,null,1,0))) tot_open_rqd
     from    ben_prtt_enrt_ctfn_prvdd_f pcs
     where   pcs.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and     pcs.prtt_enrt_actn_id = p_prtt_enrt_actn_id
     and     p_effective_date between
             pcs.effective_start_date and pcs.effective_end_date;
  --
  cursor c_ccp is
     select  sum(1) tot_ctfn,
             sum(decode(ccp.dpnt_dsgn_ctfn_rqd_flag,'Y',1,0)) tot_rqd,
             sum(decode(ccp.dpnt_dsgn_ctfn_recd_dt,null,1,0)) tot_open_ctfn,
             sum(decode(ccp.dpnt_dsgn_ctfn_rqd_flag,'N',0,
                     decode(ccp.dpnt_dsgn_ctfn_recd_dt,null,1,0))) tot_open_rqd
     from    ben_cvrd_dpnt_ctfn_prvdd_f ccp
     where   ccp.prtt_enrt_actn_id = p_prtt_enrt_actn_id
     and     ccp.elig_cvrd_dpnt_id = p_elig_cvrd_dpnt_id
     and     p_effective_date between
             ccp.effective_start_date and ccp.effective_end_date;
  --
  cursor c_pbc is
     select  sum(1) tot_ctfn,
             sum(decode(pbc.bnf_ctfn_rqd_flag,'Y',1,0)) tot_rqd,
             sum(decode(pbc.bnf_ctfn_recd_dt,null,1,0)) tot_open_ctfn,
             sum(decode(pbc.bnf_ctfn_rqd_flag,'N',0,
                        decode(pbc.bnf_ctfn_recd_dt,null,1,0))) tot_open_rqd
     from    ben_pl_bnf_ctfn_prvdd_f pbc
     where   pbc.prtt_enrt_actn_id = p_prtt_enrt_actn_id
     and     pbc.pl_bnf_id = p_pl_bnf_id
     and     p_effective_date between
             pbc.effective_start_date and pbc.effective_end_date;
  --
  l_ctfn    c_pbc%rowtype;
  --
  l_proc varchar2(80) ;
  --
begin
  --
  if g_debug then
    l_proc := g_package || '.get_ctfn_count';
    hr_utility.set_location ('Entering '||l_proc,10);
  end if;
  --
  p_optional_count      := 0;
  p_required_count      := 0;
  p_open_required_count := 0;
  p_open_optional_count := 0;
  --
  if p_prtt_enrt_actn_id is null then
     if g_debug then
       hr_utility.set_location ('Leaving '||l_proc,97);
     end if;
     return;
  end if;
  --
  if p_elig_cvrd_dpnt_id is not null then
     --
     open  c_ccp;
     fetch c_ccp into l_ctfn;
     close c_ccp;
     --
  elsif p_pl_bnf_id is not null then
     --
     open  c_pbc;
     fetch c_pbc into l_ctfn;
     close c_pbc;
     --
  elsif p_prtt_enrt_rslt_id is not null then
     --
     open  c_pcs;
     fetch c_pcs into l_ctfn;
     close c_pcs;
     --
  else
     if g_debug then
       hr_utility.set_location ('Leaving '||l_proc,98);
     end if;
     return;
     --
  end if;
  --
  p_required_count       := l_ctfn.tot_rqd +0;
  p_optional_count       := l_ctfn.tot_ctfn - l_ctfn.tot_rqd + 0;
  p_open_required_count  := l_ctfn.tot_open_rqd + 0;
  p_open_optional_count  := l_ctfn.tot_open_ctfn - p_open_required_count +0;

      hr_utility.set_location ('l_ctfn.tot_rqd '|| l_ctfn.tot_rqd,10);
      hr_utility.set_location ('l_ctfn.tot_ctfn '|| l_ctfn.tot_ctfn,10);
      hr_utility.set_location ('l_ctfn.tot_open_rqd '|| l_ctfn.tot_open_rqd,10);
      hr_utility.set_location ('l_ctfn.tot_open_ctfn '|| l_ctfn.tot_open_ctfn,10);
      hr_utility.set_location ('p_open_required_count '|| p_open_required_count,10);

  --
  if g_debug then
    hr_utility.set_location ('Leaving '||l_proc,99);
  end if;
  --
end get_ctfn_count;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< process_action_item >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure process_action_item
  (p_prtt_enrt_actn_id          in out nocopy number
  ,p_actn_typ_id                in     number
  ,p_cmpltd_dt                  in     date
  ,p_object_version_number      in out nocopy number
  ,p_effective_date             in     date
  ,p_rqd_data_found             in     boolean
  ,p_prtt_enrt_rslt_id          in     number
  ,p_elig_cvrd_dpnt_id          in     number   default null
  ,p_pl_bnf_id                  in     number   default null
  ,p_rqd_flag                   in     varchar2 default 'Y'
  ,p_post_rslt_flag             in     varchar2 default 'Y'
  ,p_business_group_id          in     number
  ,p_datetrack_mode             in     varchar2
  ,p_rslt_object_version_number in out nocopy number) is
  --
  l_proc  varchar2(80);

  l_prtt_enrt_actn_id          number(15);
  l_object_version_number      number(15);
  l_rslt_object_version_number number(15);


  --
begin
  --
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_proc  := g_package||'.process_action_item';
    hr_utility.set_location ('Entering '||l_proc,10);
  end if;
  --
  l_prtt_enrt_actn_id     := p_prtt_enrt_actn_id ;
  l_object_version_number := p_object_version_number ;
  l_rslt_object_version_number := p_rslt_object_version_number;

  --
  if (p_prtt_enrt_actn_id IS NULL and p_rqd_data_found = FALSE) then
    --
    -- An action item does not exist and required data is not found. Write a
    -- new action item
    --
    write_new_action_item
      (p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
      ,p_rslt_object_version_number => p_rslt_object_version_number
      ,p_actn_typ_id                => p_actn_typ_id
      ,p_effective_date             => p_effective_date
      ,p_post_rslt_flag             => p_post_rslt_flag
      ,p_business_group_id          => p_business_group_id
      ,p_elig_cvrd_dpnt_id          => p_elig_cvrd_dpnt_id
      ,p_pl_bnf_id                  => p_pl_bnf_id
      ,p_rqd_flag                   => p_rqd_flag
      ,p_cmpltd_dt                  => p_cmpltd_dt
      ,p_prtt_enrt_actn_id          => p_prtt_enrt_actn_id
      ,p_object_version_number      => p_object_version_number);
    --
  elsif p_prtt_enrt_actn_id IS NOT NULL and
        p_rqd_data_found = TRUE and
        p_cmpltd_dt IS NULL then
    --
    -- Existing open action item but we now have required data. Close the open
    -- action item by setting cmpltd_dt field
    --
    set_cmpltd_dt
      (p_prtt_enrt_actn_id          => p_prtt_enrt_actn_id
      ,p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
      ,p_rslt_object_version_number => p_rslt_object_version_number
      ,p_actn_typ_id                => p_actn_typ_id
      ,p_rqd_flag                   => p_rqd_flag
      ,p_effective_date             => p_effective_date
      ,p_post_rslt_flag             => p_post_rslt_flag
      ,p_business_group_id          => p_business_group_id
      ,p_object_version_number      => p_object_version_number
      ,p_open_close                 => 'CLOSE'
      ,p_datetrack_mode             => p_datetrack_mode);
     --
  elsif p_prtt_enrt_actn_id IS NOT NULL and
        p_rqd_data_found = FALSE and
        p_cmpltd_dt IS NOT NULL then
    --
    -- Found a closed action item. But required data is missing. Reopen item
    --
    set_cmpltd_dt
      (p_prtt_enrt_actn_id          => p_prtt_enrt_actn_id
      ,p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
      ,p_rslt_object_version_number => p_rslt_object_version_number
      ,p_actn_typ_id                => p_actn_typ_id
      ,p_rqd_flag                   => p_rqd_flag
      ,p_effective_date             => p_effective_date
      ,p_post_rslt_flag             => p_post_rslt_flag
      ,p_business_group_id          => p_business_group_id
      ,p_object_version_number      => p_object_version_number
      ,p_open_close                 => 'OPEN'
      ,p_datetrack_mode             => p_datetrack_mode);
    --
  else
    -- p_prtt_enrt_actn_id IS NOT NULL and p_rqd_data_found = FALSE
    -- and p_cmpltd_dt is null
    --    i.e. existing action still no information and not completed.
    -- p_prtt_enrt_actn_id IS NOT NULL and p_rqd_data_found=TRUE
    -- and p_cmpltd_dt is not null.
    --    i.e. action action had already been completed with all information.
    -- p_prtt_enrt_actn_id IS NULL and p_rqd_data_found = TRUE
    --    i.e. have always had information
    NULL;
  end if;
  --
  if g_debug then
    hr_utility.set_location ('Leaving '||l_proc, 10);
  end if;
  --
exception
  when others then

    if g_debug then
      hr_utility.set_location('Exception Raised '||l_proc, 10);
    end if;

    p_prtt_enrt_actn_id          := l_prtt_enrt_actn_id ;
    p_object_version_number      := l_object_version_number ;
    p_rslt_object_version_number := l_rslt_object_version_number ;

    raise;
--
end process_action_item;
--
procedure process_new_ctfn_action(
           p_prtt_enrt_rslt_id    in number,
           p_elig_cvrd_dpnt_id    in number default null,
           p_pl_bnf_id            in number default null,
           p_actn_typ_cd          in varchar2,
           p_ctfn_rqd_flag        in varchar2,
           p_ctfn_recd_dt         in date  default null,
           p_business_group_id    in number,
           p_effective_date       in date,
           p_prtt_enrt_actn_id    out nocopy number) is
   --
   l_proc       varchar2(80);
   --
   l_actn_typ_id                number  := null;
   l_cmpltd_dt                  date    := null;
   l_data_found                 boolean := false;
   l_object_version_number      number  := null;
   l_rslt_object_version_number number  := null;
   l_optional                   number;
   l_required                   number;
   l_open_optional              number;
   l_open_required              number;
   --
--Bug 6353069
   cursor c_pen is
      select pen.pgm_id,
             pen.ptip_id,
             pen.pl_id,
             pen.pl_typ_id,
             pen.oipl_id,
             pen.ler_id,
             pen.person_id,
             pen.object_version_number
      from   ben_prtt_enrt_rslt_f pen
      where  pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
      and    pen.business_group_id = p_business_group_id
      and    pen.prtt_enrt_rslt_stat_cd is null
      and    p_effective_date between
             pen.effective_start_date and pen.effective_end_date;

l_rslt c_pen%rowtype;

  -- Cursor to retrieve the dependent designation level
  --
  cursor c_dpnt_lvl_cd (p_pgm_id number) is
  select pgm.dpnt_dsgn_lvl_cd
    from ben_pgm_f pgm
   where pgm.pgm_id = p_pgm_id
     and pgm.business_group_id = p_business_group_id
     and p_effective_date between
         pgm.effective_start_date and pgm.effective_end_date;
  --
  -- Cursor to retrieve dependant required flags at the pgm level
  --
  cursor c_dpnt_pgm (p_pgm_id number) is
  select pgm.susp_if_ctfn_not_dpnt_flag
    from ben_pgm_f pgm
   where pgm.pgm_id = p_pgm_id
     and pgm.business_group_id = p_business_group_id
     and p_effective_date between
         pgm.effective_start_date and pgm.effective_end_date;
  --
  l_dpnt c_dpnt_pgm%rowtype;
  --
  -- cursor to retrieve dpnts' required-info-flags at the ptip level
  --
  cursor c_dpnt_ptip (p_ptip_id number) is
  select ptip.susp_if_ctfn_not_dpnt_flag
    from ben_ptip_f ptip
   where ptip.ptip_id = p_ptip_id
     and ptip.business_group_id = p_business_group_id
     and p_effective_date between
         ptip.effective_start_date and ptip.effective_end_date;
  --
  -- Cursor to retrieve dpnt required flags at the plan level
  --
  cursor c_dpnt_pl (p_pl_id number) is
  select pl.susp_if_ctfn_not_dpnt_flag
    from ben_pl_f pl
   where pl.pl_id = p_pl_id
     and pl.business_group_id = p_business_group_id
     and p_effective_date between
         pl.effective_start_date and pl.effective_end_date;
  --
  -- Cursor to retrieve Suspend Enrollment Flag at the various levels
  --
cursor c_ldc (p_lvl_cd varchar) is
select ldc.susp_if_ctfn_not_prvd_flag
from BEN_LER_CHG_DPNT_CVG_f ldc,
     ben_prtt_enrt_rslt_f pen
where pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and pen.business_group_id = p_business_group_id
     and p_effective_date between pen.effective_start_date
                              and pen.effective_end_date
     and pen.ler_id = ldc.ler_id
     and pen.prtt_enrt_rslt_stat_cd is null
     and p_effective_date between ldc.effective_start_date
                              and ldc.effective_end_date
     and ((p_lvl_cd = 'PTIP' and ldc.ptip_id = pen.ptip_id) OR
          (p_lvl_cd = 'PL' and ldc.pl_id = pen.pl_id) OR
          (p_lvl_cd = 'PGM' and ldc.pgm_id = pen.pgm_id));


  l_ler_susp_if_ctfn_not_prvd varchar2(30);
  l_rqd_flag      varchar2(30) := 'Y';
  l_lvl_cd      ben_pgm_f.dpnt_dsgn_lvl_cd%type;

--End Bug 6353069


   --
begin
   --
   g_debug := hr_utility.debug_enabled;
   if g_debug then
      l_proc       := g_package||'.process_ctfn_action_item';
     hr_utility.set_location ('Entering '||l_proc, 10);
   end if;
   --
   p_prtt_enrt_actn_id := null;
   --
   l_actn_typ_id := get_actn_typ_id
                      (p_type_cd           => p_actn_typ_cd,
                       p_business_group_id => p_business_group_id);
   --
   get_prtt_enrt_actn_id
        (p_actn_typ_id           => l_actn_typ_id,
         p_prtt_enrt_rslt_id     => p_prtt_enrt_rslt_id,
         p_elig_cvrd_dpnt_id     => p_elig_cvrd_dpnt_id,
         p_pl_bnf_id             => p_pl_bnf_id,
         p_effective_date        => p_effective_date,
         p_business_group_id     => p_business_group_id,
         p_prtt_enrt_actn_id     => p_prtt_enrt_actn_id,
         p_cmpltd_dt             => l_cmpltd_dt,
         p_object_version_number => l_object_version_number);
   --
   if p_ctfn_rqd_flag = 'Y' and p_ctfn_recd_dt is null then
      --
      -- Case 1: Required open ctfn
      -- We require a open action item for this open required ctfn.
      --
      l_data_found := false;
      --
   elsif p_ctfn_rqd_flag = 'Y' and p_ctfn_recd_dt is not null then
      --
      -- Case 2: Required Closed Ctfn.
      --
      if p_prtt_enrt_actn_id is not null then
         --
         -- The ctfn we are inserting is required but also closed, so
         -- we just require the action item id to write the ctfn.
         -- Action item found, do not do anything with action items.
         --
         return;
         --
      else
         --
         -- No action item found, so we need to create a closed
         -- action item.
         --
         l_data_found := false;
         l_cmpltd_dt  := p_effective_date;
         --
      end if;
      --
   elsif p_ctfn_rqd_flag = 'N' and p_ctfn_recd_dt is null then
      --
      -- Case 3: Optional Open Ctfn.
      --
      hr_utility.set_location ('p_ctfn_rqd_flag '|| p_ctfn_rqd_flag,10);
      hr_utility.set_location ('p_ctfn_recd_dt '|| p_ctfn_recd_dt,10);

      get_ctfn_count
         (p_prtt_enrt_actn_id   => p_prtt_enrt_actn_id
         ,p_prtt_enrt_rslt_id   => p_prtt_enrt_rslt_id
         ,p_elig_cvrd_dpnt_id   => p_elig_cvrd_dpnt_id
         ,p_pl_bnf_id           => p_pl_bnf_id
         ,p_effective_date      => p_effective_date
         ,p_required_count      => l_required
         ,p_optional_count      => l_optional
         ,p_open_required_count => l_open_required
         ,p_open_optional_count => l_open_optional);
      --
      if l_optional > 0 then
         --
         -- Optional Ctfn already exists. It means the action item would
         -- have been already created. Creation of new Optional Open Ctfn
         -- does not change anything, so just return.
         --
         return;
         --
      else
         --
         -- No optional ctfn. exists. So we need to have a open action item.
         --
         l_data_found := false;
         --
      end if;
      --
   elsif p_ctfn_rqd_flag = 'N' and p_ctfn_recd_dt is not null then
      --
      -- Case 4: Optional Closed Ctfn.
      --
      hr_utility.set_location ('p_ctfn_rqd_flag '|| p_ctfn_rqd_flag,11);
      hr_utility.set_location ('p_ctfn_recd_dt '|| p_ctfn_recd_dt,11);

      get_ctfn_count
         (p_prtt_enrt_actn_id   => p_prtt_enrt_actn_id
         ,p_prtt_enrt_rslt_id   => p_prtt_enrt_rslt_id
         ,p_elig_cvrd_dpnt_id   => p_elig_cvrd_dpnt_id
         ,p_pl_bnf_id           => p_pl_bnf_id
         ,p_effective_date      => p_effective_date
         ,p_required_count      => l_required
         ,p_optional_count      => l_optional
         ,p_open_required_count => l_open_required
         ,p_open_optional_count => l_open_optional);
      --
      if l_optional > 0 and
         l_open_optional = l_optional and
         l_open_required = 0 then
         --
         -- All required Ctfn closed and optional ctfn exists and none of
         -- the optional ctfn is closed. It means that the new optional closed
         -- ctfn. which we are inserting, should close the action item.
         --
         l_data_found := true;
         --
      elsif p_prtt_enrt_actn_id is null then
         --
         -- No action item exists, so we need to create a closed action item.
         --
         l_data_found := false;
         l_cmpltd_dt  := p_effective_date;
         --
      else
         --
         -- The state of action item remains the same in all other cases,
         -- so just return
         --
         return;
         --
      end if;
      --
   else
      --
      -- Invalid Case.
      --
      return;
      --
   end if;
   --

--Bug 6353069
      OPEN c_pen;
      FETCH c_pen INTO l_rslt;
      CLOSE c_pen;

      IF (p_prtt_enrt_actn_id IS NULL AND l_data_found = FALSE AND p_elig_cvrd_dpnt_id is not NULL)
      THEN
         --
         -- Fetch the designation level code from the ben_pgm_f table.
         --
         IF l_rslt.pgm_id IS NOT NULL
         THEN
            OPEN c_dpnt_lvl_cd (p_pgm_id => l_rslt.pgm_id);
            FETCH c_dpnt_lvl_cd INTO l_lvl_cd;
            CLOSE c_dpnt_lvl_cd;
         END IF;

         --

         IF g_debug
         THEN
            hr_utility.set_location ('Designation level code : ' || l_lvl_cd,14 );
         END IF;

         --
         -- check the level code for program, ptip or plan (default) and fetch the
         -- appropriate required-info-flags.
         --
         IF (l_lvl_cd = 'PGM' AND l_rslt.pgm_id IS NOT NULL)
         THEN
            -- Fetch the flags at the program level
            OPEN c_dpnt_pgm (p_pgm_id => l_rslt.pgm_id);
            FETCH c_dpnt_pgm INTO l_dpnt;
            CLOSE c_dpnt_pgm;
         --
         ELSIF (l_lvl_cd = 'PTIP' AND l_rslt.pgm_id IS NOT NULL)
         THEN
            -- Fetch the flags at the ptip level
            OPEN c_dpnt_ptip (p_ptip_id => l_rslt.ptip_id);
            FETCH c_dpnt_ptip INTO l_dpnt;
            CLOSE c_dpnt_ptip;
         --
         ELSE
            -- always use plan as default
            OPEN c_dpnt_pl (p_pl_id => l_rslt.pl_id);
            FETCH c_dpnt_pl INTO l_dpnt;
            CLOSE c_dpnt_pl;
            l_lvl_cd := 'PL';
         --
         END IF;

         l_rqd_flag := l_dpnt.susp_if_ctfn_not_dpnt_flag;
         OPEN c_ldc (l_lvl_cd);
         FETCH c_ldc INTO l_ler_susp_if_ctfn_not_prvd;
         CLOSE c_ldc;

         IF (l_ler_susp_if_ctfn_not_prvd <> NULL)
         THEN
            l_rqd_flag := l_ler_susp_if_ctfn_not_prvd;
         END IF;
      ELSE
         l_rqd_flag := 'Y';
      END IF;

      IF g_debug
      THEN
         hr_utility.set_location ('l_rqd_flag : ' || l_rqd_flag, 14);
      END IF;
--End Bug 6353069
   --
   process_action_item
        (p_prtt_enrt_actn_id          => p_prtt_enrt_actn_id,
         p_actn_typ_id                => l_actn_typ_id,
         p_cmpltd_dt                  => l_cmpltd_dt,
         p_object_version_number      => l_object_version_number,
         p_effective_date             => p_effective_date,
         p_rqd_data_found             => l_data_found,
         p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id,
         p_elig_cvrd_dpnt_id          => p_elig_cvrd_dpnt_id,
         p_pl_bnf_id                  => p_pl_bnf_id,
         p_rqd_flag                   => l_rqd_flag,  --Bug 6353069
         p_post_rslt_flag             => 'N',
         p_business_group_id          => p_business_group_id,
         p_datetrack_mode             => hr_api.g_update,
         p_rslt_object_version_number => l_rslt.object_version_number);
   --
   if g_debug then
     hr_utility.set_location ('Leaving '||l_proc, 10);
   end if;
   --
end process_new_ctfn_action;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< check_dob >---------------------------------|
-- ----------------------------------------------------------------------------
--
function check_dob
  (p_person_id  in number
  ,p_effective_date    in date
  ,p_business_group_id in number)
return boolean is
  --
  l_proc     varchar2(80) ;
  l_dob_found   boolean;
  --
  cursor c_date_of_birth is
  select per.date_of_birth
    from per_all_people_f per
   where per.person_id = p_person_id
     and per.business_group_id = p_business_group_id
     and p_effective_date between per.effective_start_date
                              and per.effective_end_date;
  --
  l_date_of_birth date;
--
begin
  --
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_proc      := g_package||'.check_dob';
    hr_utility.set_location ('Entering '||l_proc,10);
  end if;
  --
  open c_date_of_birth;
  fetch c_date_of_birth into l_date_of_birth;
  close c_date_of_birth;
  --
  if l_date_of_birth is not null then
    l_dob_found := TRUE;
  else
    l_dob_found := FALSE;
  end if;
  --
  if g_debug then
    hr_utility.set_location ('Leaving ' ||l_proc,10);
  end if;
  --
  return l_dob_found;
--
exception
  when others then
    if g_debug then
      hr_utility.set_location('Exception Raised '||l_proc, 10);
    end if;
    raise;
--
end check_dob;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< check_adrs >--------------------------------|
-- ----------------------------------------------------------------------------
--
function check_adrs
  (p_prtt_enrt_rslt_id  in number
  ,p_dpnt_bnf_person_id in number
  ,p_effective_date     in date
  ,p_business_group_id  in number)
return boolean is
  --
  -- this function has many things to do.  We need to check person resides with
  -- the participant.  Does the participant have a primary address. A valid
  -- zip code.  If person does not reside with participant do they have a
  -- primary address and a valid zip code.
  --
  l_proc     varchar2(80) ;
  l_rsds        per_contact_relationships.rltd_per_rsds_w_dsgntr_flag%type;
  l_valid_adrs  boolean;
  --
  -- Cursor to check if person resides with participant
  --
  cursor c_rsds is
  select pcr.rltd_per_rsds_w_dsgntr_flag
    from per_contact_relationships pcr, ben_prtt_enrt_rslt_f perslt
   where perslt.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and perslt.person_id = pcr.person_id
     and pcr.contact_person_id = p_dpnt_bnf_person_id
     and pcr.business_group_id  = p_business_group_id
     and perslt.business_group_id  = p_business_group_id
     and perslt.prtt_enrt_rslt_stat_cd is null
     and p_effective_date between
         perslt.effective_start_date and perslt.effective_end_date;
  --
  -- Cursor to check if participant has primary address
  --
  cursor c_prtt_adrs is
  select peradd.primary_flag,
         peradd.address_line1,
         peradd.postal_code
    from per_addresses peradd,
         ben_prtt_enrt_rslt_f perslt
   where perslt.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and perslt.person_id = peradd.person_id
     and peradd.business_group_id = p_business_group_id
     and perslt.business_group_id = p_business_group_id
     and perslt.prtt_enrt_rslt_stat_cd is null
     and p_effective_date between
         perslt.effective_start_date and perslt.effective_end_date
    order by decode(peradd.primary_flag,'Y',1,2);
  --
  l_prtt_adrs c_prtt_adrs%rowtype;
  --
  -- Cursor to check if the dependent or beneficiary has their own primary addr
  --
  -- Bug 2858700. Added dt condition and order by clause to the original
  -- cursor (commented below).
  cursor c_dpnt_bnf_adrs is
  select peradd.primary_flag,
         peradd.address_line1,
         peradd.postal_code
    from per_addresses peradd
   where peradd.person_id = p_dpnt_bnf_person_id
     and peradd.business_group_id = p_business_group_id
     and p_effective_date between peradd.date_from and
         nvl(peradd.date_to,p_effective_date)
    order by decode(peradd.primary_flag,'Y',1,2);

/*  cursor c_dpnt_bnf_adrs is
  select peradd.primary_flag,
         peradd.address_line1,
         peradd.postal_code
    from per_addresses peradd
   where peradd.person_id = p_dpnt_bnf_person_id
     and peradd.business_group_id = p_business_group_id; */
  --
  l_dpnt_bnf_adrs c_dpnt_bnf_adrs%rowtype;
  --
begin
--
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_proc      := g_package||'.check_adrs';
    hr_utility.set_location ('Entering '||l_proc,10);
  end if;
  --
  -- check if the person resides with the participant
  --
  open c_rsds;
  fetch c_rsds into l_rsds;
  close c_rsds;
  --
  -- if they reside together. Does participant have primary address and zipcode
  --
  if l_rsds = 'Y' then
    open c_prtt_adrs;
    fetch c_prtt_adrs into l_prtt_adrs;
    close c_prtt_adrs;
    --
    -- now check if participant has valid primary address and valid zipcode
    --
    if l_prtt_adrs.primary_flag = 'Y' and
       l_prtt_adrs.postal_code IS NOT NULL then
      l_valid_adrs := TRUE;
    else
      l_valid_adrs := FALSE;
    end if;
    --
  elsif l_rsds = 'N' or l_rsds is null then
    --
    -- dependent or beneficiary does not reside with participant.
    -- Then check if the dependent/beneficiary has a primary address
    -- and valid zipcode.
    --
    open c_dpnt_bnf_adrs;
    fetch c_dpnt_bnf_adrs into l_dpnt_bnf_adrs;
    close c_dpnt_bnf_adrs;
    --
    if l_dpnt_bnf_adrs.primary_flag = 'Y' and
       l_dpnt_bnf_adrs.postal_code IS NOT NULL then
      l_valid_adrs := TRUE;
    else
      l_valid_adrs := FALSE;
    end if;
  --
  end if; -- l_rsds
  --
  if g_debug then
    hr_utility.set_location ('Leaving ' ||l_proc,10);
  end if;
  --
  return l_valid_adrs;
  --
exception
  when others then
    if g_debug then
      hr_utility.set_location('Exception Raised '||l_proc, 10);
    end if;
    raise;
--
end check_adrs;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< check_legid >-------------------------------|
-- ----------------------------------------------------------------------------
--
function check_legid
  (p_person_id         in number
  ,p_effective_date    in date
  ,p_business_group_id in number)
return boolean is
  --
  -- this function checks the social security number, ssn, or
  -- national identifier.  We are just checking if NULL, not the value.
  -- return Y if there is a value found otherwise N.
  --
  l_proc     varchar2(80) ;
  l_legid_found boolean;
  --
  cursor c_leg_id is
  select per.national_identifier
    from per_all_people_f per
   where per.person_id = p_person_id
     and per.business_group_id = p_business_group_id
     and p_effective_date between
         per.effective_start_date and per.effective_end_date;
  --
  l_leg_id c_leg_id%rowtype;
--
begin
--
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_proc      := g_package||'.check_legid';
    hr_utility.set_location ('Entering '||l_proc,10);
  end if;
  --
  open c_leg_id;
  fetch c_leg_id into l_leg_id;
  close c_leg_id;
  --
  if l_leg_id.national_identifier IS NOT NULL then
    l_legid_found := TRUE;
  else
    l_legid_found := FALSE;
  end if;
  --
  if g_debug then
    hr_utility.set_location ('Leaving ' ||l_proc,10);
  end if;
  --
  return l_legid_found;
  --
exception
  when others then
    if g_debug then
      hr_utility.set_location('Exception Raised '||l_proc, 10);
    end if;
    raise;
--
end check_legid;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< check_ctfn >--------------------------------|
-- ----------------------------------------------------------------------------
--
function check_ctfn(p_required_count      in number
                   ,p_optional_count      in number
                   ,p_open_required_count in number
                   ,p_open_optional_count in number)
return boolean is
  --
  l_proc      varchar2(80) ;
  --
begin
  --
  if g_debug then
    l_proc       := g_package ||'.check_ctfn';
    hr_utility.set_location ('Entering '||l_proc,10);
  end if;
  --
  if (p_required_count + p_optional_count) = 0 then
    --
    -- No certifications were found. Return FALSE.
    if g_debug then
      hr_utility.set_location ('Leaving '||l_proc,95);
    end if;
    return FALSE;
    --
  end if;
  --
  --
  if p_open_required_count = 0 and
     p_optional_count = 0 then
    -- all reqd provided and no optional ones found
     if g_debug then
       hr_utility.set_location ('Leaving '||l_proc,96);
     end if;
    return TRUE;
    --
  elsif p_open_required_count = 0  and
        p_optional_count <> p_open_optional_count then
    -- all rqd prvdd and atleast one optional prvdd
    if g_debug then
      hr_utility.set_location ('Leaving '||l_proc,97);
    end if;
    return TRUE;
    --
  else
    -- certifications missing or no optional ones provided
     if g_debug then
       hr_utility.set_location ('Leaving '||l_proc,98);
     end if;
    return FALSE;
    --
  end if;
  --
  if g_debug then
    hr_utility.set_location ('Leaving '||l_proc,99);
  end if;
  --
end check_ctfn;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< check_enrt_ctfn >---------------------------|
-- ----------------------------------------------------------------------------
--
function check_enrt_ctfn
  (p_prtt_enrt_actn_id in number
  ,p_prtt_enrt_rslt_id in number
  ,p_effective_date    in date)
return boolean is
  --
  -- This function checks for certifications for an enrollment result.
  -- Check if certifications were provided.  For this participant
  -- if the enrt_ctfn_rqd_flag is 'Y'if the enrt_ctfn_recd_dt IS NULL
  -- The recd_dt is filled in via a form interface.
  -- we are also checking for at least one optional certification.
  -- optional means dpnt_dsgn_ctfn_rqd_flag is 'N' for the ctfn_prvdd entry
  -- with the dpnt_dsgn_ctfn_recd_dt not NULL
  --
  l_required  number;
  l_optional  number;
  l_open_required number;
  l_open_optional number;
  l_return  boolean;
  --
  l_proc     varchar2(80) ;
--
begin
--
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_proc      := g_package||'.check_enrt_ctfn';
    hr_utility.set_location ('Entering '||l_proc,10);
  end if;
  --
  get_ctfn_count
    (p_prtt_enrt_actn_id   => p_prtt_enrt_actn_id
    ,p_prtt_enrt_rslt_id   => p_prtt_enrt_rslt_id
    ,p_effective_date      => p_effective_date
    ,p_required_count      => l_required
    ,p_optional_count      => l_optional
    ,p_open_required_count => l_open_required
    ,p_open_optional_count => l_open_optional);
  --
  l_return := check_ctfn(p_required_count      => l_required
                        ,p_optional_count      => l_optional
                        ,p_open_required_count => l_open_required
                        ,p_open_optional_count => l_open_optional);
  --
  if g_debug then
    hr_utility.set_location ('Leaving '||l_proc,10);
  end if;
  --
  return l_return;
  --
exception
  when others then
    if g_debug then
      hr_utility.set_location('Exception Raised '||l_proc, 10);
    end if;
    raise;
--
end check_enrt_ctfn;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< check_dpnt_ctfn >---------------------------|
-- ----------------------------------------------------------------------------
--
function check_dpnt_ctfn
  (p_prtt_enrt_actn_id in number
  ,p_elig_cvrd_dpnt_id in number
  ,p_effective_date    in date)
return boolean is
  --
  -- This function checks for certifications for an enrollment result.
  -- Check if certifications were provided.  For this covered dependent check
  -- if the dpnt_dsgn_ctfn_rqd_flag is 'Y'if the dpnt_dsgn_ctfn_recd_dt IS NULL
  -- The recd_dt is filled in via a form interface.
  -- we are also checking for at least one optional certification.
  -- optional means dpnt_dsgn_ctfn_rqd_flag is 'N' for the ctfn_prvdd entry
  -- with the dpnt_dsgn_ctfn_recd_dt not NULL
  --
  l_required  number;
  l_optional  number;
  l_open_required number;
  l_open_optional number;
  l_return  boolean;
  --
  l_proc     varchar2(80) ;
--
begin
--
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_proc      := g_package||'.check_dpnt_ctfn';
    hr_utility.set_location ('Entering '||l_proc,10);
  end if;
  --
  get_ctfn_count
    (p_prtt_enrt_actn_id   => p_prtt_enrt_actn_id
    ,p_elig_cvrd_dpnt_id   => p_elig_cvrd_dpnt_id
    ,p_effective_date      => p_effective_date
    ,p_required_count      => l_required
    ,p_optional_count      => l_optional
    ,p_open_required_count => l_open_required
    ,p_open_optional_count => l_open_optional);
  --
  l_return := check_ctfn(p_required_count      => l_required
                        ,p_optional_count      => l_optional
                        ,p_open_required_count => l_open_required
                        ,p_open_optional_count => l_open_optional);
  --
  if g_debug then
    hr_utility.set_location ('Leaving '||l_proc,99);
  end if;
  --
  return l_return;
  --
exception
  when others then
    if g_debug then
      hr_utility.set_location('Exception Raised '||l_proc, 999);
    end if;
    raise;
--
end check_dpnt_ctfn;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< check_write_ctfn >-------------------------------|
-- ----------------------------------------------------------------------------
--
function check_write_ctfn
  (p_formula_id     in number
  ,p_pgm_id         in number default NULL
  ,p_pl_id          in number default NULL
  ,p_pl_typ_id       in number default NULL
  ,p_oipl_id         in number default NULL
  ,p_ler_id          in number default NULL
  ,p_param1          in varchar2 default NULL
  ,p_param1_value    in varchar2 default NULL
  ,p_business_group_id          in number default NULL
  ,p_assignment_id          in number default NULL
  ,p_organization_id          in number default NULL
  ,p_jurisdiction_code      in varchar2
  ,p_effective_date in date)
return boolean is
--
 l_write_ctfn     boolean := TRUE;
 l_outputs        ff_exec.outputs_t;
 l_proc        varchar2(80) ;
 --
 cursor c_opt is
    select oipl.opt_id
    from ben_oipl_f oipl
    where oipl.oipl_id = p_oipl_id
        and business_group_id = p_business_group_id
        and p_effective_date between
         oipl.effective_start_date and oipl.effective_end_date;

 l_opt c_opt%rowtype;
--
begin
  --
  if g_debug then
   l_proc         := g_package||'.check_write_ctfn';
    hr_utility.set_location ('Entering '||l_proc,10);
  end if;
  --
  if p_formula_id IS NOT NULL then
    --
    if p_oipl_id is not null then
      open c_opt;
      fetch c_opt into l_opt;
      close c_opt;
    end if;
    --
    l_outputs := benutils.formula
                   (p_formula_id           => p_formula_id
                   ,p_pgm_id               => p_pgm_id
                   ,p_pl_id                => p_pl_id
                   ,p_pl_typ_id            => p_pl_typ_id
                   ,p_opt_id               => l_opt.opt_id
                   ,p_ler_id               => p_ler_id
                   ,p_param1               => p_param1
                   ,p_param1_value         => p_param1_value
                   ,p_business_group_id    => p_business_group_id
                   ,p_assignment_id        => p_assignment_id
                   ,p_organization_id      => p_organization_id
                   ,p_jurisdiction_code    => p_jurisdiction_code
                   ,p_effective_date       => p_effective_date);
    --
    if l_outputs(l_outputs.first).value = 'N' then
      l_write_ctfn := FALSE;
    end if;
    --
  else
    NULL; -- nothing to do at this time
  end if;
  --
  if g_debug then
    hr_utility.set_location ('Leaving ' ||l_proc,10);
  end if;
  --
  return l_write_ctfn;
  --
exception
  when others then
    if g_debug then
      hr_utility.set_location('Exception Raised '||l_proc, 10);
    end if;
    raise;
--
end check_write_ctfn;
--
-- ----------------------------------------------------------------------------
-- |-------------------< determine_dpnt_miss_actn_items >---------------------|
-- ----------------------------------------------------------------------------
--
procedure determine_dpnt_miss_actn_items
  (p_validate                   in     boolean  default false
  ,p_effective_date             in     date
  ,p_business_group_id          in     number
  ,p_datetrack_mode             in     varchar2 default hr_api.g_correction
  ,p_prtt_enrt_rslt_id          in     number
  ,p_rslt_object_version_number in out nocopy number
  ,p_post_rslt_flag             in     varchar2 default 'Y'
  ,p_dpnt_actn_warning             out nocopy boolean) is
  --
  -- This procedure determines if a desgnated dependent has missing information
  -- DOB, SSN, ADRS, CTFN that are required to complete an enrollment.  It also
  -- completes the DD action. The dependent information requirements are defined
  -- at the program, plan, and plan type in program level.
  --
  l_proc     varchar2(80) ;
  l_rslt_object_version_number number(15);

  --
  l_allws_flag  varchar2(30);
  l_lvl_cd      ben_pgm_f.dpnt_dsgn_lvl_cd%type;
  l_actn_typ_id    number;
  l_rqd_data_found     boolean;  -- holds return value from check_xxx functions
  l_effective_start_date    date;
  l_effective_end_date      date;
  l_object_version_number   number;
  l_cmpltd_dt               date;
  l_prtt_enrt_actn_id       number;
  l_prtt_enrt_ctfn_prvdd_id number;
  --
  l_dpnt_actn_warning boolean := FALSE;

  l_dpnt_ctfn_actn_warning boolean := FALSE; -- Bug 5998009

  l_all_lvls       varchar2(30);  -- flag for processing levels of dpnt certs
  l_outputs        ff_exec.outputs_t;
  l_write_ctfn     boolean := FALSE;
  l_ctfns_defined boolean := FALSE;
  l_ff_ctfns_exists boolean := FALSE ;   -- Bug1491912
  l_susp_if_ctfn_not_prvd_flag varchar2(30);

  -- Cursor to select context parameters for benutils.formula

  cursor c_rslt is
    select rslt.pgm_id,
    rslt.ptip_id,
    rslt.pl_id,
    rslt.pl_typ_id,
    rslt.oipl_id,
    rslt.ler_id,
    rslt.person_id,
    rslt.business_group_id
    from ben_prtt_enrt_rslt_f rslt
    where rslt.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
       and rslt.prtt_enrt_rslt_stat_cd is null
        and p_effective_date between
         rslt.effective_start_date and rslt.effective_end_date;

l_rslt c_rslt%rowtype;

  cursor c_asg is
    select asg.assignment_id,asg.organization_id
    from per_all_assignments_f asg
    where asg.person_id = l_rslt.person_id
    and   asg.assignment_type <> 'C'
    and asg.primary_flag = 'Y'
        and p_effective_date between
         asg.effective_start_date and asg.effective_end_date;

l_asg c_asg%rowtype;

  Cursor c_state is
  select region_2
  from hr_locations_all loc,per_all_assignments_f asg
  where loc.location_id = asg.location_id
  and asg.person_id = l_rslt.person_id
       and   asg.assignment_type <> 'C'
       and p_effective_date between
             asg.effective_start_date and asg.effective_end_date
       and asg.business_group_id=p_business_group_id;

l_state c_state%rowtype;

  -- Cursor to retrieve the dependent designation level
  --
  cursor c_dpnt_lvl_cd (p_pgm_id number) is
  select pgm.dpnt_dsgn_lvl_cd
    from ben_pgm_f pgm
   where pgm.pgm_id = p_pgm_id
     and pgm.business_group_id = p_business_group_id
     and p_effective_date between
         pgm.effective_start_date and pgm.effective_end_date;
  --
  -- Cursor to retrieve dependant required flags at the pgm level
  --
  cursor c_dpnt_pgm (p_pgm_id number) is
  select pgm.susp_if_dpnt_ssn_nt_prv_cd,
         pgm.susp_if_dpnt_dob_nt_prv_cd,
         pgm.susp_if_dpnt_adr_nt_prv_cd,
         pgm.susp_if_ctfn_not_dpnt_flag,
         pgm.dpnt_ctfn_determine_cd,
         pgm.dpnt_dsgn_no_ctfn_rqd_flag
    from ben_pgm_f pgm
   where pgm.pgm_id = p_pgm_id
     and pgm.business_group_id = p_business_group_id
     and p_effective_date between
         pgm.effective_start_date and pgm.effective_end_date;
  --
  l_dpnt c_dpnt_pgm%rowtype;
  --
  -- cursor to retrieve dpnts' required-info-flags at the ptip level
  --
  cursor c_dpnt_ptip (p_ptip_id number) is
  select ptip.susp_if_dpnt_ssn_nt_prv_cd,
         ptip.susp_if_dpnt_dob_nt_prv_cd,
         ptip.susp_if_dpnt_adr_nt_prv_cd,
         ptip.susp_if_ctfn_not_dpnt_flag,
         ptip.dpnt_ctfn_determine_cd,
         ptip.dpnt_cvg_no_ctfn_rqd_flag
    from ben_ptip_f ptip
   where ptip.ptip_id = p_ptip_id
     and ptip.business_group_id = p_business_group_id
     and p_effective_date between
         ptip.effective_start_date and ptip.effective_end_date;
  --
  -- Cursor to retrieve dpnt required flags at the plan level
  --
  cursor c_dpnt_pl (p_pl_id number) is
  select pl.susp_if_dpnt_ssn_nt_prv_cd,
         pl.susp_if_dpnt_dob_nt_prv_cd,
         pl.susp_if_dpnt_adr_nt_prv_cd,
         pl.susp_if_ctfn_not_dpnt_flag,
         pl.dpnt_ctfn_determine_cd,
         pl.dpnt_no_ctfn_rqd_flag
    from ben_pl_f pl
   where pl.pl_id = p_pl_id
     and pl.business_group_id = p_business_group_id
     and p_effective_date between
         pl.effective_start_date and pl.effective_end_date;
  --
  cursor c_ctfns_ler_chg(v_lvl_cd varchar2
                        ,v_dpnt_person_id number
                        ,v_person_id number
                        ,v_pgm_id number
                        ,v_pl_id number
                        ,v_ptip_id number) is
  select lcc.dpnt_cvg_ctfn_typ_cd,
         lcc.ctfn_rqd_when_rl,
         lcc.rqd_flag,
         lcc.rlshp_typ_cd,
         ldc.susp_if_ctfn_not_prvd_flag,
         ldc.ctfn_determine_cd
    from ben_ler_chg_dpnt_cvg_ctfn_f lcc,
         ben_ler_chg_dpnt_cvg_f ldc,
         ben_prtt_enrt_rslt_f pen
   where pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and pen.business_group_id = p_business_group_id
     and p_effective_date between pen.effective_start_date
                              and pen.effective_end_date
     and pen.ler_id = ldc.ler_id
     and pen.prtt_enrt_rslt_stat_cd is null
     and p_effective_date between ldc.effective_start_date
                              and ldc.effective_end_date
     and ((v_lvl_cd = 'PTIP' and ldc.ptip_id = v_ptip_id) OR
          (v_lvl_cd = 'PL' and ldc.pl_id = v_pl_id) OR
          (v_lvl_cd = 'PGM' and ldc.pgm_id = v_pgm_id))
     and ldc.ler_chg_dpnt_cvg_id = lcc.ler_chg_dpnt_cvg_id
     and p_effective_date between lcc.effective_start_date
                              and lcc.effective_end_date
     and (lcc.rlshp_typ_cd is null
          or
          lcc.rlshp_typ_cd in (select contact_type
                                from per_contact_relationships
                               where contact_person_id = v_dpnt_person_id
                                 and person_id = v_person_id
                                 and business_group_id = p_business_group_id
                                 and p_effective_date
                                     between nvl(date_start, p_effective_date)
                                         and nvl(date_end, hr_api.g_eot)));
  --
  -- Cursor to retrieve dependent certification information at the plan level
  --
  cursor c_dpnt_ctfn_pl(v_pl_id number, v_dpnt_person_id number, v_person_id number) is
  select pl.dpnt_cvg_ctfn_typ_cd ctcvgcd,
         pl.ctfn_rqd_when_rl ctrrl,
         pl.rqd_flag,
         pl.rlshp_typ_cd ctrlshcd,
         pl.pl_id
    from ben_pl_dpnt_cvg_ctfn_f pl
   where pl.pl_id = v_pl_id
     and pl.business_group_id = p_business_group_id
     and p_effective_date between pl.effective_start_date
                              and pl.effective_end_date
     and (pl.rlshp_typ_cd is null
          or
          pl.rlshp_typ_cd in (select contact_type
                               from per_contact_relationships
                              where contact_person_id = v_dpnt_person_id
                                and person_id = v_person_id
                                and business_group_id = p_business_group_id
                                and p_effective_date
                                      between nvl(date_start, p_effective_date)
                                          and nvl(date_end, hr_api.g_eot)));
  --
  -- Cursor to retrieve dependent certification at the program level
  --
  cursor c_dpnt_ctfn_pgm(v_pgm_id number, v_dpnt_person_id number, v_person_id number) is
  select pgm.dpnt_cvg_ctfn_typ_cd ctcvgcd,
         pgm.ctfn_rqd_when_rl ctrrl,
         pgm.rqd_flag,
         pgm.rlshp_typ_cd ctrlshcd,
         pgm.pgm_id
    from ben_pgm_dpnt_cvg_ctfn_f pgm
   where pgm.pgm_id = v_pgm_id
     and pgm.business_group_id = p_business_group_id
     and p_effective_date between pgm.effective_start_date
                              and pgm.effective_end_date
     and (pgm.rlshp_typ_cd is null
          or
          pgm.rlshp_typ_cd in  (select contact_type
                                from per_contact_relationships
                               where contact_person_id = v_dpnt_person_id
                                 and person_id = v_person_id
                                 and business_group_id = p_business_group_id
                                 and p_effective_date
                                       between nvl(date_start, p_effective_date)
                                           and nvl(date_end, hr_api.g_eot)));

  --
  -- Cursor to retrieve dependent certifications at the ptip level
  --
  cursor c_dpnt_ctfn_ptip(v_ptip_id number, v_dpnt_person_id number, v_person_id number) is
  select ptip.dpnt_cvg_ctfn_typ_cd ctcvgcd,
         ptip.ctfn_rqd_when_rl ctrrl,
         ptip.rqd_flag,
         ptip.rlshp_typ_cd ctrlshcd,
         ptip.ptip_id
    from ben_ptip_dpnt_cvg_ctfn_f ptip
   where ptip.ptip_id = v_ptip_id
     and ptip.business_group_id = p_business_group_id
     and p_effective_date between ptip.effective_start_date
                              and ptip.effective_end_date
     and (ptip.rlshp_typ_cd is null
          or
          ptip.rlshp_typ_cd in (select contact_type
                                 from per_contact_relationships
                                where contact_person_id = v_dpnt_person_id
                                  and person_id = v_person_id
                                  and business_group_id = p_business_group_id
                                  and p_effective_date
                                       between nvl(date_start, p_effective_date)
                                           and nvl(date_end, hr_api.g_eot)));

  --
  -- Cursor to fetch the covered dependents for an enrt_rslt_id
  --
  cursor c_cvrd_dpnt is
  select ecd.dpnt_person_id,
         ecd.elig_cvrd_dpnt_id,
         pen.pgm_id,
         pen.ptip_id,
         pen.pl_id
    from ben_elig_cvrd_dpnt_f ecd,
         ben_prtt_enrt_rslt_f pen,
         ben_per_in_ler pil
   where pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and pen.prtt_enrt_rslt_id = ecd.prtt_enrt_rslt_id
     and ecd.cvg_strt_dt is not null
     and nvl(ecd.cvg_thru_dt, hr_api.g_eot) = hr_api.g_eot
     and ecd.business_group_id = p_business_group_id
     and p_effective_date between
         ecd.effective_start_date and ecd.effective_end_date
     and p_effective_date between
         pen.effective_start_date and pen.effective_end_date
     and pen.prtt_enrt_rslt_stat_cd is null
     and pil.per_in_ler_id=ecd.per_in_ler_id
     and pil.business_group_id=p_business_group_id
     and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT');
  --
  cursor c_mng_dpnts (cl_dpnt_id number) is
  select ccp.elig_cvrd_dpnt_id,
         ccp.dpnt_dsgn_ctfn_typ_cd,
         ccp.dpnt_dsgn_ctfn_rqd_flag,
         ccp.dpnt_dsgn_ctfn_recd_dt
    from ben_cvrd_dpnt_ctfn_prvdd_f ccp,
         ben_elig_cvrd_dpnt_f ecd,
         ben_per_in_ler pil
   where ccp.elig_cvrd_dpnt_id = cl_dpnt_id
     and ccp.dpnt_dsgn_ctfn_recd_dt IS NULL
     and ccp.business_group_id = p_business_group_id
     and p_effective_date between
         ccp.effective_start_date and ccp.effective_end_date
     and ecd.elig_cvrd_dpnt_id=ccp.elig_cvrd_dpnt_id
     and ecd.business_group_id = p_business_group_id
     and p_effective_date between
         ecd.effective_start_date and ecd.effective_end_date
     and pil.per_in_ler_id=ecd.per_in_ler_id
     and pil.business_group_id=p_business_group_id
     and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT');
--
     -- bug: 5513339
  cursor c_curr_ovn_of_actn (c_prtt_enrt_actn_id number) is
  select object_version_number
    from ben_prtt_enrt_actn_f
    where prtt_enrt_actn_id = c_prtt_enrt_actn_id
      and business_group_id = p_business_group_id
      and p_effective_date between effective_start_date
           and effective_end_date;

  --
  l_mng_dpnts c_mng_dpnts%rowtype;
  l_jurisdiction_code     varchar2(30);
  l_ctfn_at_ler_chg boolean := FALSE;
  l_rqd_flag      varchar2(30);

--
begin
--
  if g_debug then
    l_proc      := g_package||'.determine_dpnt_miss_actn_items';
    hr_utility.set_location ('Entering '||l_proc,10);
  end if;

  l_rslt_object_version_number := p_rslt_object_version_number ;

  --
  if p_prtt_enrt_rslt_id is not null then
    open c_rslt;
    fetch c_rslt into l_rslt;
    close c_rslt;
  else
    if g_debug then
      hr_utility.set_location('RESULT ID IS NULL!!' , 13);
    end if;
  end if;
  --
  if l_rslt.person_id is not null then
    open c_asg;
    fetch c_asg into l_asg;
    close c_asg;
  end if;
  --

/*  -- 4031733 - Cursor used to populate l_state.region_2 param for benutils.limit_checks
    -- which is not used down the line
    --
    if l_rslt.person_id is not null then
    open c_state;
    fetch c_state into l_state;
    close c_state;

--    if l_state.region_2 is not null then

--      l_jurisdiction_code :=
--         pay_mag_utils.lookup_jurisdiction_code
--           (p_state => l_state.region_2);

--    end if;
  end if;
*/

  --
  -- Fetch the designation level code from the ben_pgm_f table.
  --
  if l_rslt.pgm_id is not null then
    open c_dpnt_lvl_cd(p_pgm_id => l_rslt.pgm_id);
    fetch c_dpnt_lvl_cd into l_lvl_cd;
    close c_dpnt_lvl_cd;
  end if;
  --
  if g_debug then
    hr_utility.set_location('Designation level code : ' || l_lvl_cd, 14);
  end if;
  --
  -- check the level code for program, ptip or plan (default) and fetch the
  -- appropriate required-info-flags.
  --
  if (l_lvl_cd = 'PGM' and l_rslt.pgm_id IS NOT NULL) then
    -- Fetch the flags at the program level
    open c_dpnt_pgm(p_pgm_id => l_rslt.pgm_id);
    fetch c_dpnt_pgm into l_dpnt;
    close c_dpnt_pgm;
  --
  elsif (l_lvl_cd = 'PTIP' and l_rslt.pgm_id IS NOT NULL) then
    -- Fetch the flags at the ptip level
    open c_dpnt_ptip(p_ptip_id => l_rslt.ptip_id);
    fetch c_dpnt_ptip into l_dpnt;
    close c_dpnt_ptip;
  --
  else
    -- always use plan as default
    open c_dpnt_pl(p_pl_id => l_rslt.pl_id);
    fetch c_dpnt_pl into l_dpnt;
    close c_dpnt_pl;
    l_lvl_cd := 'PL';
  --
  end if;
  --
  -- for each dependent covered by participant check
  -- date of birth, address, national id, certifications
  --
  for l_cvrd_dpnt in c_cvrd_dpnt loop
    -- date of birth action item
    --
    -- Check if a DDDOB action item exists for the dependent
    --
    l_ff_ctfns_exists := FALSE ;
    --
    if g_debug then
      hr_utility.set_location('DOB action item ', 30);
    end if;
    --
    l_actn_typ_id := get_actn_typ_id
                       (p_type_cd           => 'DDDOB'
                       ,p_business_group_id => p_business_group_id);
    --
    get_prtt_enrt_actn_id
      (p_actn_typ_id           => l_actn_typ_id
      ,p_prtt_enrt_rslt_id     => p_prtt_enrt_rslt_id
      ,p_elig_cvrd_dpnt_id     => l_cvrd_dpnt.elig_cvrd_dpnt_id
      ,p_effective_date        => p_effective_date
      ,p_business_group_id     => p_business_group_id
      ,p_prtt_enrt_actn_id     => l_prtt_enrt_actn_id
      ,p_cmpltd_dt             => l_cmpltd_dt
      ,p_object_version_number => l_object_version_number);
    --
    if l_dpnt.susp_if_dpnt_dob_nt_prv_cd is not null then
      --
      -- check if person has a date of birth entry
      --
      if g_debug then
        hr_utility.set_location('DOB is rqd', 35);
      end if;
      --
      if l_dpnt.susp_if_dpnt_dob_nt_prv_cd = 'RQDS' then
        l_rqd_flag := 'Y';
      else
        l_rqd_flag := 'N';
      end if;
      l_rqd_data_found := check_dob
                            (p_person_id         => l_cvrd_dpnt.dpnt_person_id
                            ,p_effective_date    => p_effective_date
                            ,p_business_group_id => p_business_group_id);
      --
      -- Process the action item
      --
      process_action_item
        (p_prtt_enrt_actn_id          => l_prtt_enrt_actn_id
        ,p_actn_typ_id                => l_actn_typ_id
        ,p_cmpltd_dt                  => l_cmpltd_dt
        ,p_object_version_number      => l_object_version_number
        ,p_effective_date             => p_effective_date
        ,p_rqd_data_found             => l_rqd_data_found
        ,p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
        ,p_elig_cvrd_dpnt_id          => l_cvrd_dpnt.elig_cvrd_dpnt_id
        ,p_rqd_flag                   => l_rqd_flag  --'Y'
        ,p_post_rslt_flag             => p_post_rslt_flag
        ,p_business_group_id          => p_business_group_id
        ,p_datetrack_mode             => p_datetrack_mode
        ,p_rslt_object_version_number => p_rslt_object_version_number);
      --
      if l_rqd_data_found = FALSE then
        l_dpnt_actn_warning := TRUE;
      end if;
      --
    else
      -- dpnt_dob_rqd_flag is 'N'
      -- if date_track mode is updating and designation at plan level
      -- delete action item of type DDDOB.
      --
      if g_debug then
        hr_utility.set_location('DOB is not required', 40);
      end if;
      --
      if (l_prtt_enrt_actn_id IS NOT NULL and p_datetrack_mode = DTMODE_DELETE) then
      --
        delete_action_item
          (p_prtt_enrt_actn_id          => l_prtt_enrt_actn_id
          ,p_object_version_number      => l_object_version_number
          ,p_business_group_id          => p_business_group_id
          ,p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
          ,p_rslt_object_version_number => p_rslt_object_version_number
          ,p_effective_date             => p_effective_date
          ,p_datetrack_mode             => p_datetrack_mode
          ,p_post_rslt_flag             => p_post_rslt_flag);
        --
      else
        NULL;  -- nothing to do at this time.
      end if;
      --
    end if; -- dpnt_dob_rqd_flag
    --
    -- Social security number/national identifier action item
    --
    if g_debug then
      hr_utility.set_location('SSN action item ', 45);
    end if;
    --
    l_actn_typ_id := get_actn_typ_id
                       (p_type_cd           => 'DDSSN'
                       ,p_business_group_id => p_business_group_id);
    --
    get_prtt_enrt_actn_id
      (p_actn_typ_id           => l_actn_typ_id
      ,p_prtt_enrt_rslt_id     => p_prtt_enrt_rslt_id
      ,p_elig_cvrd_dpnt_id     => l_cvrd_dpnt.elig_cvrd_dpnt_id
      ,p_effective_date        => p_effective_date
      ,p_business_group_id     => p_business_group_id
      ,p_prtt_enrt_actn_id     => l_prtt_enrt_actn_id
      ,p_cmpltd_dt             => l_cmpltd_dt
      ,p_object_version_number => l_object_version_number);
    --
    if l_dpnt.susp_if_dpnt_ssn_nt_prv_cd is not null then
      --
      -- check if person has a national identifier entry
      --
      if g_debug then
        hr_utility.set_location('SSN is rqd', 50);
      end if;
      --
      if l_dpnt.susp_if_dpnt_ssn_nt_prv_cd = 'RQDS' then
        l_rqd_flag := 'Y';
      else
        l_rqd_flag := 'N';
      end if;
      l_rqd_data_found := check_legid
                            (p_person_id         => l_cvrd_dpnt.dpnt_person_id
                            ,p_effective_date    => p_effective_date
                            ,p_business_group_id => p_business_group_id);
      --
      -- Process the action item
      --
      process_action_item
        (p_prtt_enrt_actn_id          => l_prtt_enrt_actn_id
        ,p_actn_typ_id                => l_actn_typ_id
        ,p_cmpltd_dt                  => l_cmpltd_dt
        ,p_object_version_number      => l_object_version_number
        ,p_effective_date             => p_effective_date
        ,p_rqd_data_found             => l_rqd_data_found
        ,p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
        ,p_elig_cvrd_dpnt_id          => l_cvrd_dpnt.elig_cvrd_dpnt_id
        ,p_rqd_flag                   => l_rqd_flag  --'Y'
        ,p_post_rslt_flag             => p_post_rslt_flag
        ,p_business_group_id          => p_business_group_id
        ,p_datetrack_mode             => p_datetrack_mode
        ,p_rslt_object_version_number => p_rslt_object_version_number);
      --
      if l_rqd_data_found = FALSE then
        l_dpnt_actn_warning := TRUE;
      end if;
      --
    else
      --
      if g_debug then
        hr_utility.set_location('SSN is not rqd', 55);
      end if;
      --
      -- dpnt_leg_id_rqd_flag is 'N'
      -- if date_track mode is updating and designation at plan level
      -- delete action type of type DDSSN.
      --
      if l_prtt_enrt_actn_id IS NOT NULL and
         p_datetrack_mode = DTMODE_DELETE then
      --
        delete_action_item
          (p_prtt_enrt_actn_id          => l_prtt_enrt_actn_id
          ,p_object_version_number      => l_object_version_number
          ,p_business_group_id          => p_business_group_id
          ,p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
          ,p_rslt_object_version_number => p_rslt_object_version_number
          ,p_effective_date             => p_effective_date
          ,p_datetrack_mode             => p_datetrack_mode
          ,p_post_rslt_flag             => p_post_rslt_flag);
        --
      else
        NULL;  -- nothing to do at this time.
      end if;
      --
    end if; -- dpnt_leg_id_rqd_flag
    --
    -- address action item
    --
    if g_debug then
      hr_utility.set_location('ADDR action item ' , 60);
    end if;
    --
    l_actn_typ_id := get_actn_typ_id
                       (p_type_cd           => 'DDADDR'
                       ,p_business_group_id => p_business_group_id);
    --
    get_prtt_enrt_actn_id
      (p_actn_typ_id           => l_actn_typ_id
      ,p_prtt_enrt_rslt_id     => p_prtt_enrt_rslt_id
      ,p_elig_cvrd_dpnt_id     => l_cvrd_dpnt.elig_cvrd_dpnt_id
      ,p_effective_date        => p_effective_date
      ,p_business_group_id     => p_business_group_id
      ,p_prtt_enrt_actn_id     => l_prtt_enrt_actn_id
      ,p_cmpltd_dt             => l_cmpltd_dt
      ,p_object_version_number => l_object_version_number);
    --
    if l_dpnt.susp_if_dpnt_adr_nt_prv_cd is not null  then
      --
      -- check if person has an address
      --
      if g_debug then
        hr_utility.set_location('ADDR is rqd', 65);
      end if;
      --
      if l_dpnt.susp_if_dpnt_adr_nt_prv_cd = 'RQDS' then
        l_rqd_flag := 'Y';
      else
        l_rqd_flag := 'N';
      end if;
      l_rqd_data_found := check_adrs
                            (p_prtt_enrt_rslt_id  => p_prtt_enrt_rslt_id
                            ,p_dpnt_bnf_person_id => l_cvrd_dpnt.dpnt_person_id
                            ,p_effective_date     => p_effective_date
                            ,p_business_group_id  => p_business_group_id);
      --
      -- Process the action item
      --
      process_action_item
        (p_prtt_enrt_actn_id          => l_prtt_enrt_actn_id
        ,p_actn_typ_id                => l_actn_typ_id
        ,p_cmpltd_dt                  => l_cmpltd_dt
        ,p_object_version_number      => l_object_version_number
        ,p_effective_date             => p_effective_date
        ,p_rqd_data_found             => l_rqd_data_found
        ,p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
        ,p_elig_cvrd_dpnt_id          => l_cvrd_dpnt.elig_cvrd_dpnt_id
        ,p_rqd_flag                   => l_rqd_flag --'Y'
        ,p_post_rslt_flag             => p_post_rslt_flag
        ,p_business_group_id          => p_business_group_id
        ,p_datetrack_mode             => p_datetrack_mode
        ,p_rslt_object_version_number => p_rslt_object_version_number);
      --
      if l_rqd_data_found = FALSE then
        l_dpnt_actn_warning := TRUE;
      end if;
      --
    else
      --
      if g_debug then
        hr_utility.set_location('ADD is not rqd', 70);
      end if;
      --
      -- dpnt_adrs_rqd_flag is 'N'
      -- if date_track mode is updating and designation at plan level
      -- delete action type of type DDADDR.
      --
      if (l_prtt_enrt_actn_id IS NOT NULL and p_datetrack_mode = DTMODE_DELETE) then
        --
        delete_action_item
          (p_prtt_enrt_actn_id          => l_prtt_enrt_actn_id
          ,p_object_version_number      => l_object_version_number
          ,p_business_group_id          => p_business_group_id
          ,p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
          ,p_rslt_object_version_number => p_rslt_object_version_number
          ,p_effective_date             => p_effective_date
          ,p_datetrack_mode             => p_datetrack_mode
          ,p_post_rslt_flag             => p_post_rslt_flag);
        --
      end if;
      --
    end if; -- dpnt_adrs_rqd_flag
    --
    -- certification action item
    --
    if g_debug then
      hr_utility.set_location('CTFN action item ' , 75);
    end if;
    --
    l_actn_typ_id := get_actn_typ_id
                       (p_type_cd           => 'DDCTFN'
                       ,p_business_group_id => p_business_group_id);
    --
    -- Check if a dpnt ctfn action item exists.
    --
    get_prtt_enrt_actn_id
      (p_actn_typ_id           => l_actn_typ_id
      ,p_prtt_enrt_rslt_id     => p_prtt_enrt_rslt_id
      ,p_elig_cvrd_dpnt_id     => l_cvrd_dpnt.elig_cvrd_dpnt_id
      ,p_effective_date        => p_effective_date
      ,p_business_group_id     => p_business_group_id
      ,p_prtt_enrt_actn_id     => l_prtt_enrt_actn_id
      ,p_cmpltd_dt             => l_cmpltd_dt
      ,p_object_version_number => l_object_version_number);
    --
    -- ************************************************************
    -- Note, the flag says NO Dependent Certification Required.
    -- ************************************************************
    --
    if l_dpnt.dpnt_dsgn_no_ctfn_rqd_flag = 'N' then
      -- double negative....ctfn is required.
      if g_debug then
        hr_utility.set_location('DPNT CTFN is rqd', 80);
      end if;
      --
      --
      -- check if person has certification
      --
      l_rqd_data_found := check_dpnt_ctfn
                           (p_elig_cvrd_dpnt_id => l_cvrd_dpnt.elig_cvrd_dpnt_id
                           ,p_prtt_enrt_actn_id => l_prtt_enrt_actn_id
                           ,p_effective_date    => p_effective_date);
      --
      -- Check if any certifications are defined for the comp object.
      --
      l_ctfns_defined := check_ctfns_defined
                           (p_dpnt_person_id             => l_cvrd_dpnt.dpnt_person_id
                           ,p_person_id                  => l_rslt.person_id
                           ,p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
                           ,p_lvl_cd                     => l_lvl_cd
                           ,p_pgm_id                     => l_rslt.pgm_id
                           ,p_pl_id                      => l_cvrd_dpnt.pl_id
                           ,p_ptip_id                    => l_rslt.ptip_id
                           ,p_effective_date             => p_effective_date
                           ,p_business_group_id          => p_business_group_id
                           ,p_ctfn_at_ler_chg            => l_ctfn_at_ler_chg
                           ,p_susp_if_ctfn_not_prvd_flag => l_susp_if_ctfn_not_prvd_flag);
      --
      if l_prtt_enrt_actn_id IS NULL and
         not(l_rqd_data_found)  and
         (l_ctfns_defined) then
        --
        if g_debug then
          hr_utility.set_location('Ctfn defined and not provided', 85);
        end if;
        --
        -- Bug 3851427 : If certifications are considered at LER_CHG_DPNT level, then Suspension of
        -- enrollment ( SUSP_IF_CTFN_NOT_PRVD_FLAG ) should also be considered at LER_CHG_DPNT level
        --
        if l_ctfn_at_ler_chg = true
        then
          --
          l_rqd_flag := l_susp_if_ctfn_not_prvd_flag; -- This flag is at LER_CHG_DPNT
          --
        else
          --
          l_rqd_flag := l_dpnt.susp_if_ctfn_not_dpnt_flag; -- This flag is at PTIP, PLN or PGM level
          --
        end if;
        --
        -- Since an action item is being written set the out warning param
        --
--        l_dpnt_actn_warning := TRUE;  -- Bug 5998009 Commented out the assignment statement
        --
        -- Certifications are required and certifications are defined. However
        -- no certifications were found for this person. Create an action item.
        --
        write_new_action_item
          (p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
          ,p_rslt_object_version_number => p_rslt_object_version_number
          ,p_actn_typ_id                => l_actn_typ_id
          ,p_elig_cvrd_dpnt_id          => l_cvrd_dpnt.elig_cvrd_dpnt_id
          ,p_rqd_flag                   => l_rqd_flag        -- Bug 3851427
          ,p_effective_date             => p_effective_date
          ,p_post_rslt_flag             => p_post_rslt_flag
          ,p_business_group_id          => p_business_group_id
          ,p_object_version_number      => l_object_version_number
          ,p_prtt_enrt_actn_id          => l_prtt_enrt_actn_id);
        --
        -- loop thru all the specified certifications at the proper level
        -- write each one specified to the cvrd_dpnt_ctfn_prvdd_f table
        -- if no records then write them for all levels. Otherwise just
        -- the level they are requested for
        --
        -- first check if there are any existing certification
        -- for this dependent moved over from Managed Dependent process
        --
        l_all_lvls := YES_FOUND; -- init value
        --
        open c_mng_dpnts(l_cvrd_dpnt.elig_cvrd_dpnt_id);
        fetch c_mng_dpnts into l_mng_dpnts;
        --
        if c_mng_dpnts%NOTFOUND then
          l_all_lvls := NOT_FOUND;  -- write for all levels since nothing found
        end if;
        --
        close c_mng_dpnts;
        --
        if g_debug then
          hr_utility.set_location('l_all_lvls:'||l_all_lvls|| 'l_lvl_cd:'||
                    l_lvl_cd||' l_pgm_id:'||to_char(l_rslt.pgm_id), 87);
        end if;
        --
        -- now write out the appropriate certifications for each level
        --
        if l_all_lvls = NOT_FOUND and
           l_lvl_cd = 'PGM' and
           l_rslt.pgm_id IS NOT NULL then
          --
          if l_ctfn_at_ler_chg = TRUE then
            --
            -- Certifications defined for dpnt ler change
            --
            for l_ctfn in c_ctfns_ler_chg(l_lvl_cd
                                         ,l_cvrd_dpnt.dpnt_person_id
                                         ,l_rslt.person_id
                                         ,l_cvrd_dpnt.pgm_id
                                         ,l_cvrd_dpnt.pl_id
                                         ,l_cvrd_dpnt.ptip_id) loop
              --
              l_write_ctfn := check_write_ctfn
                (p_formula_id        => l_ctfn.ctfn_rqd_when_rl
                ,p_pgm_id            => l_rslt.pgm_id
                ,p_pl_id             => l_rslt.pl_id
                ,p_pl_typ_id         => l_rslt.pl_typ_id
                ,p_oipl_id           => l_rslt.oipl_id
                ,p_ler_id            => l_rslt.ler_id
                ,p_param1            => 'CON_PERSON_ID'
                ,p_param1_value      => to_char(l_cvrd_dpnt.dpnt_person_id)
                ,p_business_group_id => l_rslt.business_group_id
                ,p_assignment_id     => l_asg.assignment_id
                ,p_organization_id   => l_asg.organization_id
                ,p_jurisdiction_code => l_jurisdiction_code
                ,p_effective_date    => p_effective_date);
              --
              if l_write_ctfn then
                -- 9999
				l_ff_ctfns_exists := TRUE ;
                --
                -- presently we want to write the certifications always.
                -- unless the above rule indicates not to.
                --
                write_new_dpnt_ctfn_item
                  (p_elig_cvrd_dpnt_id       => l_cvrd_dpnt.elig_cvrd_dpnt_id
                  ,p_prtt_enrt_actn_id       => l_prtt_enrt_actn_id
                  ,p_dpnt_dsgn_ctfn_typ_cd   => l_ctfn.dpnt_cvg_ctfn_typ_cd
                  ,p_dpnt_dsgn_ctfn_rqd_flag => l_ctfn.rqd_flag
                  ,p_effective_date          => p_effective_date
                  ,p_business_group_id       => p_business_group_id
                  ,p_object_version_number   => l_object_version_number
                  ,p_cvrd_dpnt_ctfn_prvdd_id => l_prtt_enrt_ctfn_prvdd_id);
                --
              end if;
              --
            end loop;
            --
          else
            --
            -- No ctfns for ler change. Fetch the regular ctfns
            --
            for l_dpnt_ctfn_pgm in c_dpnt_ctfn_pgm(l_cvrd_dpnt.pgm_id
                                                  ,l_cvrd_dpnt.dpnt_person_id
                                                  ,l_rslt.person_id) loop
              --
              l_write_ctfn := check_write_ctfn
                (p_formula_id        => l_dpnt_ctfn_pgm.ctrrl
                ,p_pgm_id            => l_rslt.pgm_id
                ,p_pl_id             => l_rslt.pl_id
                ,p_pl_typ_id         => l_rslt.pl_typ_id
                ,p_oipl_id           => l_rslt.oipl_id
                ,p_ler_id            => l_rslt.ler_id
                ,p_param1            => 'CON_PERSON_ID'
                ,p_param1_value      => to_char(l_cvrd_dpnt.dpnt_person_id)
                ,p_business_group_id => l_rslt.business_group_id
                ,p_assignment_id     => l_asg.assignment_id
                ,p_organization_id   => l_asg.organization_id
                ,p_jurisdiction_code => l_jurisdiction_code
                ,p_effective_date    => p_effective_date);
              --
              if l_write_ctfn then
                --
                -- 9999
                l_ff_ctfns_exists := TRUE ;
                --
                -- presently we want to write the certifications always.
                -- unless the above rule indicates not to.
                --
                write_new_dpnt_ctfn_item
                  (p_elig_cvrd_dpnt_id       => l_cvrd_dpnt.elig_cvrd_dpnt_id
                  ,p_prtt_enrt_actn_id       => l_prtt_enrt_actn_id
                  ,p_dpnt_dsgn_ctfn_typ_cd   => l_dpnt_ctfn_pgm.ctcvgcd
                  ,p_dpnt_dsgn_ctfn_rqd_flag => l_dpnt_ctfn_pgm.rqd_flag
                  ,p_effective_date          => p_effective_date
                  ,p_business_group_id       => p_business_group_id
                  ,p_object_version_number   => l_object_version_number
                  ,p_cvrd_dpnt_ctfn_prvdd_id => l_prtt_enrt_ctfn_prvdd_id);
                --
              end if;
              --
            end loop;
            --
          end if;
          --
        end if;
        --
        if l_all_lvls = NOT_FOUND and
           l_lvl_cd = 'PTIP' and
           l_rslt.pgm_id IS NOT NULL then
          --
          if l_ctfn_at_ler_chg = TRUE then
            --
            -- Certifications defined for dpnt ler change
            --
            for l_ctfn in c_ctfns_ler_chg(l_lvl_cd
                                         ,l_cvrd_dpnt.dpnt_person_id
                                         ,l_rslt.person_id
                                         ,l_cvrd_dpnt.pgm_id
                                         ,l_cvrd_dpnt.pl_id
                                         ,l_cvrd_dpnt.ptip_id) loop
              --
              l_write_ctfn := check_write_ctfn
                (p_formula_id        => l_ctfn.ctfn_rqd_when_rl
                ,p_pgm_id            => l_rslt.pgm_id
                ,p_pl_id             => l_rslt.pl_id
                ,p_pl_typ_id         => l_rslt.pl_typ_id
                ,p_oipl_id           => l_rslt.oipl_id
                ,p_ler_id            => l_rslt.ler_id
                ,p_param1            => 'CON_PERSON_ID'
                ,p_param1_value      => to_char(l_cvrd_dpnt.dpnt_person_id)
                ,p_business_group_id => l_rslt.business_group_id
                ,p_assignment_id     => l_asg.assignment_id
                ,p_organization_id   => l_asg.organization_id
                ,p_jurisdiction_code => l_jurisdiction_code
                ,p_effective_date    => p_effective_date);
              --
              if l_write_ctfn then
                --
                -- 9999
                l_ff_ctfns_exists := TRUE ;
                --
                -- presently we want to write the certifications always.
                -- unless the above rule indicates not to.
                --
                write_new_dpnt_ctfn_item
                  (p_elig_cvrd_dpnt_id       => l_cvrd_dpnt.elig_cvrd_dpnt_id
                  ,p_prtt_enrt_actn_id       => l_prtt_enrt_actn_id
                  ,p_dpnt_dsgn_ctfn_typ_cd   => l_ctfn.dpnt_cvg_ctfn_typ_cd
                  ,p_dpnt_dsgn_ctfn_rqd_flag => l_ctfn.rqd_flag
                  ,p_effective_date          => p_effective_date
                  ,p_business_group_id       => p_business_group_id
                  ,p_object_version_number   => l_object_version_number
                  ,p_cvrd_dpnt_ctfn_prvdd_id => l_prtt_enrt_ctfn_prvdd_id);
                --
              else
          if g_debug then
            hr_utility.set_location('Dpnt ctfns at ptip in else - false returned ', 111);
          end if;
              end if;
              --
            end loop;
          if g_debug then
            hr_utility.set_location('Dpnt ctfns at ptip level - false returned ', 990);
          end if;
            --
          else
            --
            for l_dpnt_ctfn_ptip in c_dpnt_ctfn_ptip(l_cvrd_dpnt.ptip_id
                                                    ,l_cvrd_dpnt.dpnt_person_id
                                                    ,l_rslt.person_id) loop
              --
              l_write_ctfn := check_write_ctfn
                (p_formula_id        => l_dpnt_ctfn_ptip.ctrrl
                ,p_pgm_id            => l_rslt.pgm_id
                ,p_pl_id             => l_rslt.pl_id
                ,p_pl_typ_id         => l_rslt.pl_typ_id
                ,p_oipl_id           => l_rslt.oipl_id
                ,p_ler_id            => l_rslt.ler_id
                ,p_param1            => 'CON_PERSON_ID'
                ,p_param1_value      => to_char(l_cvrd_dpnt.dpnt_person_id)
                ,p_business_group_id => l_rslt.business_group_id
                ,p_assignment_id     => l_asg.assignment_id
                ,p_organization_id   => l_asg.organization_id
                ,p_jurisdiction_code => l_jurisdiction_code
                ,p_effective_date    => p_effective_date);
              --
              if l_write_ctfn then
                --
                -- 9999
                l_ff_ctfns_exists := TRUE ;
                --
                -- presently we want to write the certifications always.
                -- unless the above rule indicates not to.
                --
                write_new_dpnt_ctfn_item
                  (p_elig_cvrd_dpnt_id       => l_cvrd_dpnt.elig_cvrd_dpnt_id
                  ,p_prtt_enrt_actn_id       => l_prtt_enrt_actn_id
                  ,p_dpnt_dsgn_ctfn_typ_cd   => l_dpnt_ctfn_ptip.ctcvgcd
                  ,p_dpnt_dsgn_ctfn_rqd_flag => l_dpnt_ctfn_ptip.rqd_flag
                  ,p_effective_date          => p_effective_date
                  ,p_business_group_id       => p_business_group_id
                  ,p_object_version_number   => l_object_version_number
                  ,p_cvrd_dpnt_ctfn_prvdd_id => l_prtt_enrt_ctfn_prvdd_id);
                --
              end if;
              --
            end loop;
            --
          end if;
          --
        end if;
        --
        --
        if l_all_lvls = NOT_FOUND and
           (l_lvl_cd = 'PL' ) then
          --
          if g_debug then
            hr_utility.set_location('Dpnt ctfns at plan level', 90);
          end if;
          --
          if l_ctfn_at_ler_chg = TRUE then
            --
            -- Certifications defined for dpnt ler change
            --
            for l_ctfn in c_ctfns_ler_chg(l_lvl_cd
                                         ,l_cvrd_dpnt.dpnt_person_id
                                         ,l_rslt.person_id
                                         ,l_cvrd_dpnt.pgm_id
                                         ,l_cvrd_dpnt.pl_id
                                         ,l_cvrd_dpnt.ptip_id) loop
              --
              l_write_ctfn := check_write_ctfn
                (p_formula_id        => l_ctfn.ctfn_rqd_when_rl
                ,p_pgm_id            => l_rslt.pgm_id
                ,p_pl_id             => l_rslt.pl_id
                ,p_pl_typ_id         => l_rslt.pl_typ_id
                ,p_oipl_id           => l_rslt.oipl_id
                ,p_ler_id            => l_rslt.ler_id
                ,p_param1            => 'CON_PERSON_ID'
                ,p_param1_value      => to_char(l_cvrd_dpnt.dpnt_person_id)
                ,p_business_group_id => l_rslt.business_group_id
                ,p_assignment_id     => l_asg.assignment_id
                ,p_organization_id   => l_asg.organization_id
                ,p_jurisdiction_code => l_jurisdiction_code
                ,p_effective_date    => p_effective_date);
              --
              if l_write_ctfn then
                --
                --
                -- 9999
                l_ff_ctfns_exists := TRUE ;
                --
                -- presently we want to write the certifications always.
                -- unless the above rule indicates not to.
                --
                write_new_dpnt_ctfn_item
                  (p_elig_cvrd_dpnt_id       => l_cvrd_dpnt.elig_cvrd_dpnt_id
                  ,p_prtt_enrt_actn_id       => l_prtt_enrt_actn_id
                  ,p_dpnt_dsgn_ctfn_typ_cd   => l_ctfn.dpnt_cvg_ctfn_typ_cd
                  ,p_dpnt_dsgn_ctfn_rqd_flag => l_ctfn.rqd_flag
                  ,p_effective_date          => p_effective_date
                  ,p_business_group_id       => p_business_group_id
                  ,p_object_version_number   => l_object_version_number
                  ,p_cvrd_dpnt_ctfn_prvdd_id => l_prtt_enrt_ctfn_prvdd_id);
                --
              end if;
              --
            end loop;
            --
          else
            --
            for l_dpnt_ctfn_pl in c_dpnt_ctfn_pl(l_cvrd_dpnt.pl_id
                                                ,l_cvrd_dpnt.dpnt_person_id
                                                ,l_rslt.person_id) loop
              --
              l_write_ctfn := check_write_ctfn
                (p_formula_id        => l_dpnt_ctfn_pl.ctrrl
                ,p_pgm_id            => l_rslt.pgm_id
                ,p_pl_id             => l_rslt.pl_id
                ,p_pl_typ_id         => l_rslt.pl_typ_id
                ,p_oipl_id           => l_rslt.oipl_id
                ,p_ler_id            => l_rslt.ler_id
                ,p_param1            => 'CON_PERSON_ID'
                ,p_param1_value      => to_char(l_cvrd_dpnt.dpnt_person_id)
                ,p_business_group_id => l_rslt.business_group_id
                ,p_assignment_id     => l_asg.assignment_id
                ,p_organization_id   => l_asg.organization_id
                ,p_jurisdiction_code => l_jurisdiction_code
                ,p_effective_date    => p_effective_date);
              --
              --
              if l_write_ctfn then
                --
                --
                -- 9999
                l_ff_ctfns_exists := TRUE ;
                --
                -- presently we want to write the certifications always.
                -- unless the above rule indicates not to.
                --
                if g_debug then
                  hr_utility.set_location('Writing Certification', 95);
                end if;
                --
                write_new_dpnt_ctfn_item
                  (p_elig_cvrd_dpnt_id       => l_cvrd_dpnt.elig_cvrd_dpnt_id
                  ,p_prtt_enrt_actn_id       => l_prtt_enrt_actn_id
                  ,p_dpnt_dsgn_ctfn_typ_cd   => l_dpnt_ctfn_pl.ctcvgcd
                  ,p_dpnt_dsgn_ctfn_rqd_flag => l_dpnt_ctfn_pl.rqd_flag
                  ,p_effective_date          => p_effective_date
                  ,p_business_group_id       => p_business_group_id
                  ,p_object_version_number   => l_object_version_number
                  ,p_cvrd_dpnt_ctfn_prvdd_id => l_prtt_enrt_ctfn_prvdd_id);
                --
              else
                if g_debug then
                  hr_utility.set_location('Rule failed.. not writing ctfn', 100);
                end if;
              end if;
              --
            end loop;
            --
          end if;
          --
        end if;
        --

      -- 9999 Bug1491912  prtt act item row is deleted if there are no certifications created for
      -- for that action item.
      IF  l_ff_ctfns_exists = FALSE
      THEN
          --
          if g_debug then
            hr_utility.set_location ('Entering  l_ff_ctfns_exists',999);
          end if;
          --
               -- bug: 5513339
	     open c_curr_ovn_of_actn (l_prtt_enrt_actn_id);
		fetch c_curr_ovn_of_actn into l_object_version_number;
	     close c_curr_ovn_of_actn ;
	  delete_action_item
          (p_prtt_enrt_actn_id          => l_prtt_enrt_actn_id
          ,p_object_version_number      => l_object_version_number
          ,p_business_group_id          => p_business_group_id
          ,p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
          ,p_rslt_object_version_number => p_rslt_object_version_number
          ,p_effective_date             => p_effective_date
          ,p_datetrack_mode             => hr_api.g_zap
          ,p_post_rslt_flag             => p_post_rslt_flag);
          --
          if g_debug then
            hr_utility.set_location ('Leaving  l_ff_ctfns_exists',999);
          end if;
--Start Bug 5998009
      ELSE
          l_dpnt_ctfn_actn_warning := TRUE;
--End Bug 5998009
      END IF ;
      --
      elsif l_prtt_enrt_actn_id IS NOT NULL and
            l_rqd_data_found = TRUE and
            l_cmpltd_dt IS NULL then
        --
-- Bug 6434143
        if l_ctfn_at_ler_chg = true
        then
          --
          l_rqd_flag := l_susp_if_ctfn_not_prvd_flag; -- This flag is at LER_CHG_DPNT
          --
        else
          --
          l_rqd_flag := l_dpnt.susp_if_ctfn_not_dpnt_flag; -- This flag is at PTIP, PLN or PGM level
          --
        end if;
       --
-- Bug 6434143
        if g_debug then
          hr_utility.set_location('Existing actn item. Have rqd info', 110);
        end if;
        --
        -- Existing open action item. But we now have required info. Close the
        -- action item by setting the cmpltd_dt field.
        --
        set_cmpltd_dt
          (p_prtt_enrt_actn_id          => l_prtt_enrt_actn_id
          ,p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
          ,p_rslt_object_version_number => p_rslt_object_version_number
          ,p_actn_typ_id                => l_actn_typ_id
--        ,p_rqd_flag                   => 'Y'   -- Bug 6434143
          ,p_rqd_flag                   => l_rqd_flag
          ,p_effective_date             => p_effective_date
          ,p_post_rslt_flag             => p_post_rslt_flag
          ,p_business_group_id          => p_business_group_id
          ,p_object_version_number      => l_object_version_number
          ,p_open_close                 => 'CLOSE'
          ,p_datetrack_mode             => p_datetrack_mode);
        --
      elsif l_prtt_enrt_actn_id IS NOT NULL and
            l_rqd_data_found = FALSE and
            l_cmpltd_dt IS NULL then
        --
        -- Existing closed action item. But required info is missing. Reopen the
        -- action item.
        --
        if g_debug then
          hr_utility.set_location('Existing actn item. Rqd info missing', 115);
        end if;
        --
--Bug 6434143
        if l_ctfn_at_ler_chg = true
        then
          --
          l_rqd_flag := l_susp_if_ctfn_not_prvd_flag;
          --
        else
          --
          l_rqd_flag := l_dpnt.susp_if_ctfn_not_dpnt_flag;
          --
        end if;
       --
--Bug 6434143

        set_cmpltd_dt
          (p_prtt_enrt_actn_id          => l_prtt_enrt_actn_id
          ,p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
          ,p_rslt_object_version_number => p_rslt_object_version_number
          ,p_actn_typ_id                => l_actn_typ_id
--        ,p_rqd_flag                   => 'Y' -- Bug 6434143
          ,p_rqd_flag                   => l_rqd_flag
          ,p_effective_date             => p_effective_date
          ,p_post_rslt_flag             => p_post_rslt_flag
          ,p_business_group_id          => p_business_group_id
          ,p_object_version_number      => l_object_version_number
          ,p_open_close                 => 'OPEN'
          ,p_datetrack_mode             => p_datetrack_mode);
        --
      end if;
      --
    else
      --
      if g_debug then
        hr_utility.set_location('Dpnt ctfn rqd flag is N', 120);
      end if;
      --
      -- dpnt_ctfn_rqd_flag is 'N'
      -- if date_track mode is updating and designation at plan level
      -- delete action type of type DDCTFN.
      --
      if (l_prtt_enrt_actn_id IS NOT NULL and p_datetrack_mode = DTMODE_DELETE) then
        --
        delete_action_item
          (p_prtt_enrt_actn_id          => l_prtt_enrt_actn_id
          ,p_object_version_number      => l_object_version_number
          ,p_business_group_id          => p_business_group_id
          ,p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
          ,p_rslt_object_version_number => p_rslt_object_version_number
          ,p_effective_date             => p_effective_date
          ,p_datetrack_mode             => p_datetrack_mode
          ,p_post_rslt_flag             => p_post_rslt_flag);
        --
      else
        NULL;  -- nothing to do at this time
      end if;
      --
    end if; -- dpnt_ctfn_rqd_flag
    --
  end loop; -- dpnt loop
  --
  if g_debug then
    hr_utility.set_location ('Leaving '||l_proc,999);
  end if;
  --
  p_dpnt_actn_warning := l_dpnt_actn_warning;
  --

--Start Bug 5998009
  if(l_dpnt_ctfn_actn_warning = TRUE) then
  p_dpnt_actn_warning := TRUE;
  end if;
--End Bug 5998009


exception
  --
  when others then
    if g_debug then
      hr_utility.set_location('Exception Raised '||l_proc, 997);
    end if;
    p_rslt_object_version_number :=l_rslt_object_version_number;
    p_dpnt_actn_warning          := null;

    raise;
--
end determine_dpnt_miss_actn_items;
--
-- Added by Anil
-- ----------------------------------------------------------------------------
-- |--------------------< determine_future_sal_incr_actn_items >----- ---------|
-- ----------------------------------------------------------------------------
--
procedure det_fut_sal_incr_actn_items
(
    p_prtt_enrt_rslt_id          in     number
 ,p_effective_date             in     date
 ,p_business_group_id          in     number
 ,p_validate                   in     boolean  default FALSE
 ,p_datetrack_mode             in     varchar2 default hr_api.g_correction
 ,p_post_rslt_flag             in     varchar2 default 'Y'
 ,p_rslt_object_version_number in out nocopy number
 ,p_suspend_flag               in out nocopy varchar2
) is
--
l_proc varchar2(80) := g_package||'.determine_future_sal_incr_actn_items';
l_actn_typ_id number(15);
l_dummy varchar2(30);
l_object_version_number number;
l_prtt_enrt_actn_id number(15);
l_rslt_object_version_number number(15);
l_suspend_flag  varchar2(10);
--
cursor c_future_sal_inc is
Select 'X'
from   per_pay_proposals pay
        ,ben_prtt_enrt_rslt_f rslt
      ,ben_pl_typ_f tyP
Where rslt.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
  and p_effective_date between rslt.effective_start_date and rslt.effective_end_date
  and pay.approved = 'Y'
  and rslt.assignment_id = pay.assignment_id
  and pay.business_group_id = p_business_group_id
  and pay.change_date >= p_effective_date
  and typ.pl_typ_id = rslt.pl_typ_id
  and rslt.prtt_enrt_rslt_stat_cd is null
  and p_effective_date between typ.effective_start_date and typ.effective_end_date
  and typ.comp_typ_cd = 'ICM7';
--
  l_future_sal_inc c_future_sal_inc%ROWTYPE;
--
BEGIN
--
    if g_debug then
      hr_utility.set_location ('Entering '||l_proc,10);
    end if;
  --

  l_rslt_object_version_number := p_rslt_object_version_number ;
  l_suspend_flag               := p_suspend_flag  ;

  -- Issue a savepoint if operating in validate only mode
  --
  OPEN c_future_sal_inc;
    fetch c_future_sal_inc into l_future_sal_inc;
    /*fnd_file.put_line(fnd_file.log,'-->The info garnered from the sal cursor');
    fnd_file.put_line(fnd_file.log,'-->l_future_sal_inc.prtt_enrt_rslt_id'||l_future_sal_inc.rslt_id);
      fnd_file.put_line(fnd_file.log,'-->l_future_sal_inc.per_in_ler_id'||l_future_sal_inc.per_in_ler_id);
      fnd_file.put_line(fnd_file.log,'-->l_future_sal_inc.assignment_id'||l_future_sal_inc.assignment_id);*/
  IF c_future_sal_inc%FOUND THEN
    l_actn_typ_id := get_actn_typ_id
                       (p_type_cd           => 'MRRFS'
                       ,p_business_group_id => p_business_group_id);
    /*fnd_file.put_line(fnd_file.log,'-->The Action item type is l_actn_typ_id'||l_actn_typ_id);
    fnd_file.put_line(fnd_file.log,'-->wrt_actn_item writing the action item with the following parameters');
      fnd_file.put_line(fnd_file.log,'-->wrt_actn_item p_prtt_enrt_rslt_id '||p_prtt_enrt_rslt_id);
      fnd_file.put_line(fnd_file.log,'-->wrt_actn_item p_effective_date    '||p_effective_date);
      fnd_file.put_line(fnd_file.log,'-->wrt_actn_item p_business_group_id '||p_business_group_id );
      fnd_file.put_line(fnd_file.log,'-->wrt_actn_item p_datetrack_mode    '||p_datetrack_mode);
      fnd_file.put_line(fnd_file.log,'-->wrt_actn_item p_post_rslt_flag    '||p_post_rslt_flag);
      fnd_file.put_line(fnd_file.log,'-->wrt_actn_item p_rslt_object_version_number'||p_rslt_object_version_number);
      fnd_file.put_line(fnd_file.log,'-->wrt_actn_item p_prtt_enrt_actn_id '||l_prtt_enrt_actn_id);
      fnd_file.put_line(fnd_file.log,'---------------------------------------------------------------------------');*/
      write_new_action_item
          ( p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
           ,p_rslt_object_version_number => p_rslt_object_version_number
           ,p_actn_typ_id                => l_actn_typ_id
           ,p_effective_date             => p_effective_date
           ,p_post_rslt_flag             => p_post_rslt_flag
           ,p_business_group_id          => p_business_group_id
           ,p_object_version_number      => l_object_version_number
           ,p_prtt_enrt_actn_id          => l_prtt_enrt_actn_id);
          p_suspend_flag := 'Y';
    END IF;

  CLOSE c_future_sal_inc;
 -- new call to write to ben_reporting
 if g_debug then
   hr_utility.set_location ('Leaving '||l_proc, 10);
 end if;
 --
EXCEPTION
  WHEN OTHERS THEN
    if g_debug then
      hr_utility.set_location('Exception Raised '||l_proc, 10);
    end if;
      fnd_file.put_line(fnd_file.log,'Exception Raised -'||l_proc);
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      fnd_file.put_line(fnd_file.log,sqlerrm);

      p_rslt_object_version_number :=l_rslt_object_version_number;
      p_suspend_flag               :=l_suspend_flag  ;
    RAISE;
--
END DET_FUT_SAL_INCR_ACTN_ITEMS;
--
-- ----------------------------------------------------------------------------
-- |--------------------< process_cwb_actn_items >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure process_cwb_actn_items
  (p_validate                   in     boolean  default FALSE
  ,p_prtt_enrt_rslt_id          in     number
  ,p_effective_date             in     date
  ,p_business_group_id          in     number
  ,p_datetrack_mode             in     varchar2 default hr_api.g_correction
  ,p_post_rslt_flag             in     varchar2 default 'Y'
  ,p_rslt_object_version_number in out nocopy number
  ,p_suspend_flag               in out nocopy varchar2) is
  --
  l_proc  varchar2(80);
  l_rslt_object_version_number  number(15);
  l_suspend_flag                varchar2(15);


--
begin
--
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_proc  := g_package||'.process_cwb_actn_items';
    hr_utility.set_location ('Entering '||l_proc,10);
  end if;
  if g_debug then
    hr_utility.set_location ('Entering rslt id '||to_char(p_prtt_enrt_rslt_id),11);
  end if;
  --
  l_rslt_object_version_number  := p_rslt_object_version_number  ;
  l_suspend_flag := p_suspend_flag ;

  -- Issue a savepoint if operating in validate only mode
  --
  savepoint process_cwb_actn_items;
  --
  /*fnd_file.put_line(fnd_file.log,'-->fut_sal_incr det_fut_sal_incr_actn_items with the following parameters');
    fnd_file.put_line(fnd_file.log,'-->fut_sal_incr p_prtt_enrt_rslt_id '||p_prtt_enrt_rslt_id);
    fnd_file.put_line(fnd_file.log,'-->fut_sal_incr p_effective_date    '||p_effective_date);
    fnd_file.put_line(fnd_file.log,'-->fut_sal_incr p_business_group_id '||p_business_group_id );
    fnd_file.put_line(fnd_file.log,'-->fut_sal_incr p_datetrack_mode    '||p_datetrack_mode);
    fnd_file.put_line(fnd_file.log,'-->fut_sal_incr p_post_rslt_flag    '||p_post_rslt_flag);
    fnd_file.put_line(fnd_file.log,'-->fut_sal_incr p_rslt_object_version_number'||p_rslt_object_version_number);
    fnd_file.put_line(fnd_file.log,'-->fut_sal_incr p_suspend_flag      '||p_suspend_flag);
    fnd_file.put_line(fnd_file.log,'---------------------------------------------------------------------------');*/
    --
  det_fut_sal_incr_actn_items
        (p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
        ,p_rslt_object_version_number => p_rslt_object_version_number
        ,p_effective_date             => p_effective_date
        ,p_business_group_id          => p_business_group_id
        ,p_datetrack_mode             => p_datetrack_mode
        ,p_post_rslt_flag             => p_post_rslt_flag
        ,p_suspend_flag               => p_suspend_flag
        ,p_validate                   => p_validate);

  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  if g_debug then
    hr_utility.set_location ('Leaving '||l_proc, 10);
  end if;
  --
exception
  --
  when hr_api.validate_enabled
  then
    rollback to process_cwb_actn_items;
    --
    if g_debug then
      hr_utility.set_location(' Leaving:'||l_proc, 10);
    end if;
  --
  when others then
    if g_debug then
      hr_utility.set_location('Exception Raised '||l_proc, 10);
    end if;
    p_rslt_object_version_number := l_rslt_object_version_number ;
    p_suspend_flag  := l_suspend_flag ;
    raise;
--
end process_cwb_actn_items;
--
-- ----------------------------------------------------------------------------
-- |-------------------< determine_dpnt_actn_items >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure determine_dpnt_actn_items
  (p_validate                   in     boolean  default FALSE
  ,p_prtt_enrt_rslt_id          in     number
  ,p_effective_date             in     date
  ,p_business_group_id          in     number
  ,p_datetrack_mode             in     varchar2 default hr_api.g_correction
  ,p_post_rslt_flag             in     varchar2 default 'Y'
  ,p_allws_flag                 in     varchar2
  ,p_dsgn_cd                    in     varchar2
  ,p_rslt_object_version_number in out nocopy number
  ,p_dd_actn_item_open             out nocopy boolean
  ,p_hack                          out nocopy varchar2) is
  -- this procedure determines if dependents are required to complete enrollment
  -- for an enrollment result check ben_elig_per_elctbl_chc.alws_dpnt_dsgn_flag
  -- if 'Y' and a new enrollment result write DD action item.
  -- A DD action item is only written when no dependents were designated.
  -- in additon if the dependent designation is 'R' required, suspend enrollment
  -- or if designation 'O' optional, do not suspend.
  --
  l_proc varchar2(80) ;
  --
  l_actn_typ_id           number(15);
  l_cmpltd_dt             date;
  l_object_version_number number;
  l_prtt_enrt_actn_id     number(15);
  l_rqd_flag              varchar2(30);

  l_rslt_object_version_number  number(15);



  --
  cursor c_dpnt_dsgn is
  select ecd.dpnt_person_id
    from ben_elig_cvrd_dpnt_f ecd,
         ben_per_in_ler pil
   where ecd.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and ecd.cvg_strt_dt is not null
     and nvl(ecd.cvg_thru_dt, hr_api.g_eot) = hr_api.g_eot
     and ecd.business_group_id = p_business_group_id
     and p_effective_date between
         ecd.effective_start_date and ecd.effective_end_date
     and pil.per_in_ler_id=ecd.per_in_ler_id
     and pil.business_group_id=p_business_group_id
     and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT');
  --
  l_dpnt_dsgn c_dpnt_dsgn%rowtype;
  --
  -- Cursor to fetch dependent action items other than the DD item. this will
  -- be used to delete all dependent action items after a DD action item is
  -- written
  --
  cursor c_other_dpnt_actn_items is
  select pea.prtt_enrt_actn_id,
         pea.object_version_number
    from ben_prtt_enrt_actn_f pea,
         ben_actn_typ typ,
         ben_per_in_ler pil
   where pea.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and pea.business_group_id = p_business_group_id
     and typ.type_cd <> 'DD'
     and typ.type_cd like 'DD%'
     and pea.per_in_ler_id = pil.per_in_ler_id
     and pil.per_in_ler_stat_cd not in ('BCKDT', 'VOIDD')
     and typ.business_group_id = p_business_group_id
     and pea.actn_typ_id = typ.actn_typ_id
     and p_effective_date between
         pea.effective_start_date and pea.effective_end_date
  ;
  --
  -- Cursor to check if the enrt rslt is for an employee only option where the
  -- min and max dpnts will be 0.
  -- 3730053: Designation Requirements for OPT overrides OIPL overrides PLN.
  -- Bug 4396160: Curosr name is changed from c_emp_only to c_tot_mn_mx_dpnts_req
  --  sothat total number of Min and Max no of dpnts calculated
  -- If no DD record is defined, Query will result in Both totals as NULL
  cursor c_tot_mn_mx_dpnts_req is -- c_not_emp_only is
 select  sum(tot_mn_dpnts_rqd_num)  tot_mn_dpnts_rqd_num,
         sum(tot_mx_dpnts_alwd_num) tot_mx_dpnts_alwd_num
 from (select sum(nvl(drq.mn_dpnts_rqd_num,  0 ))         tot_mn_dpnts_rqd_num,
              sum(nvl(drq.mx_dpnts_alwd_num,9999999999))  tot_mx_dpnts_alwd_num
    from ben_dsgn_rqmt_f drq,
         ben_oipl_f cop,
         ben_prtt_enrt_rslt_f pen
   where pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
    -- and drq.oipl_id = pen.oipl_id -- 3730053: OPT level DSGN_RQMTS override OIPL level
     and pen.oipl_id = cop.oipl_id
     and ( (drq.oipl_id = pen.oipl_id
            and not exists
        (select null
                  from ben_dsgn_rqmt_f drq2
                  where drq2.opt_id = cop.opt_id
                   and p_effective_date between drq2.effective_start_date
                                            and drq2.effective_end_date))
        or cop.opt_id = drq.opt_id)
     and drq.dsgn_typ_cd = 'DPNT'
     --and drq.mn_dpnts_rqd_num > 0
     --and drq.mx_dpnts_alwd_num = 0
     and cop.business_group_id = p_business_group_id
     and p_effective_date between cop.effective_start_date
                              and cop.effective_end_date
     and pen.business_group_id = p_business_group_id
     and p_effective_date between pen.effective_start_date
                              and pen.effective_end_date
     and drq.business_group_id = p_business_group_id
     and p_effective_date between drq.effective_start_date
                              and drq.effective_end_date
  UNION -- 3730053: Added this to check PL-level designation requirements are specified at PLAN-LEVEL.
  select sum(nvl(drq.mn_dpnts_rqd_num,  0 ))         tot_mn_dpnts_rqd_num,
         sum(nvl(drq.mx_dpnts_alwd_num,9999999999))  tot_mx_dpnts_alwd_num
    from ben_dsgn_rqmt_f drq,
         ben_prtt_enrt_rslt_f pen
   where pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and drq.pl_id = pen.pl_id
     and drq.dsgn_typ_cd = 'DPNT'
     --and drq.mn_dpnts_rqd_num > 0
     --and drq.mx_dpnts_alwd_num = 0
     and pen.business_group_id = p_business_group_id
     and p_effective_date between pen.effective_start_date
                              and pen.effective_end_date
     and drq.business_group_id = p_business_group_id
     and p_effective_date between drq.effective_start_date
                              and drq.effective_end_date
      and (pen.oipl_id IS NULL
     OR  NOT EXISTS (select null
                     from ben_dsgn_rqmt_f drq3
                     where drq3.oipl_id = pen.oipl_id
                     and p_effective_date between drq3.effective_start_date and drq3.effective_end_date
              UNION ALL
              select null
                from ben_dsgn_rqmt_f drq4,
                     ben_oipl_f cop
                where cop.oipl_id = pen.oipl_id
                and drq4.opt_id = cop.opt_id
                and p_effective_date between cop.effective_start_date and cop.effective_end_date
                and p_effective_date between drq4.effective_start_date and drq4.effective_end_date))
    );
  --
  --
    cursor c_elig_dpnts is
     SELECT 'S'
     from BEN_ELIG_DPNT           egd,
          BEN_ELIG_PER_ELCTBL_CHC epe,
          BEN_PRTT_ENRT_RSLT_F    pen
     where pen.PRTT_ENRT_RSLT_ID      = p_prtt_enrt_rslt_id
     and   pen.PRTT_ENRT_RSLT_ID      = epe.PRTT_ENRT_RSLT_ID
     and   egd.elig_per_elctbl_chc_id = epe.elig_per_elctbl_chc_id
     and   pen.prtt_enrt_rslt_stat_cd is null
     and   p_effective_date between pen.effective_start_date and pen.effective_end_date
     and dpnt_inelig_flag = 'N' ;
  --
  l_dummy varchar2(1);
  l_open_act_item_flag boolean := TRUE;
  l_mn_tot_dpnts_req    number ;
  l_mx_tot_dpnts_alwd   number ;
  --
begin
--
  if g_debug then
    l_proc  := g_package||'.determine_dpnt_actn_items';
    hr_utility.set_location ('Entering '||l_proc,10);
  end if;
  --
  l_rslt_object_version_number :=p_rslt_object_version_number ;

  --
  l_actn_typ_id := get_actn_typ_id
                     (p_type_cd           => 'DD'
                     ,p_business_group_id => p_business_group_id);
  --
  get_prtt_enrt_actn_id
    (p_actn_typ_id           => l_actn_typ_id
    ,p_prtt_enrt_rslt_id     => p_prtt_enrt_rslt_id
    ,p_effective_date        => p_effective_date
    ,p_business_group_id     => p_business_group_id
    ,p_prtt_enrt_actn_id     => l_prtt_enrt_actn_id
    ,p_cmpltd_dt             => l_cmpltd_dt
    ,p_object_version_number => l_object_version_number);
  --

  -- BUG:3248711: Since epe.alws_dpnt_dsgn_flag = 'N' (LE doesn't allow dpnt dsgn)
  -- and yet epe.dpnt_dsgn_cd = 'R' (Dpnt Dsgn is Required)
  -- In this case.. we'll have to show the the message that 'Dpnt design is pending'
  -- and also suspend the plan. Hence the or-condition (l_dsgn_cd = 'R') as been added
  -- to below if-condition

  if ((p_allws_flag = 'Y') or (p_dsgn_cd = 'R')) then
    --
    if g_debug then
      hr_utility.set_location('Dpnt dsgn allowed', 10);
    end if;
    --
    -- Check if any dependents are designated
    --
    open c_dpnt_dsgn;
    fetch c_dpnt_dsgn into l_dpnt_dsgn;
    --
    -- check the dsgn code for R - required or O - optional and set the
    -- parameter to be passed to process_action_items. This will ensure that
    -- the enrollment is suspended if required.
    --
    if p_dsgn_cd = 'R' then
      l_rqd_flag := 'Y';
    else
      l_rqd_flag := 'N';
    end if;
    --
    if g_debug then
      hr_utility.set_location('Dpnt dsgn rqd flag : ' || l_rqd_flag || ' ' || l_proc, 20);
    end if;
    --
    if c_dpnt_dsgn%NOTFOUND then
      --
      if g_debug then
        hr_utility.set_location('No dpnts designated', 10);
      end if;
      --
      -- there are no dependents designated
      --
      -- If the enrt is for an employee only option then a DD actn item
      -- need not be written.
      --
      -- Changed for Bug: 4396160,
      --   Action Items will not be created if both total min and max are zero for the Paln/Option
      --   For Min = 0 and Max > 0, Action Item will be created if Elig dpnts exists
      --   For both Min and Max > 0, Action Items will be created irrespective of Elig dpnts.
      --   Added case to create Action Items if no DD records defined also.
      open c_tot_mn_mx_dpnts_req;
      fetch c_tot_mn_mx_dpnts_req into  l_mn_tot_dpnts_req, l_mx_tot_dpnts_alwd ;
      close c_tot_mn_mx_dpnts_req;
      --
      if l_mn_tot_dpnts_req is not null and l_mx_tot_dpnts_alwd is not null then -- DD record is defined
       if  l_mn_tot_dpnts_req = 0 then
        --
        if l_mx_tot_dpnts_alwd = 0 then
          --
          l_open_act_item_flag := FALSE ;
          --
        else
          --
          Open c_elig_dpnts;
          Fetch c_elig_dpnts into l_Dummy;
          --
          If c_elig_dpnts%FOUND then
            --
            l_open_act_item_flag := TRUE ;
            if g_debug then
              hr_utility.set_location('Eligible dpnts found: ', 10);
            end if;
            --
          Else
            l_open_act_item_flag := FALSE ;
          End if;
	  --
          Close c_elig_dpnts;
          --
        End if;
       Else
       --
       l_open_act_item_flag := TRUE ;
       --
       End if;
       --
      Else -- if No DD record is defined, Then also create Action Item.
       l_open_act_item_flag := TRUE ;
       --
      End if;

/*      if c_not_emp_only%found then
        --
        if g_debug then
          hr_utility.set_location('c_not_emp_only found', 10);
        end if;
        --
	l_open_act_item_flag := TRUE ;
        --
      else
        --
        if g_debug then
          hr_utility.set_location('c_not_emp_only not found: l_mx_dpnts_alwd_num: '||l_mx_dpnts_alwd_num, 10);
        end if;
        --
	  Open c_elig_dpnts;
	  Fetch c_elig_dpnts into l_Dummy;
	  --
	  If c_elig_dpnts%FOUND then
	    --
            l_open_act_item_flag := TRUE ;
            if g_debug then
              hr_utility.set_location('c_lig_dpnts found: ', 10);
            end if;
	    --
	  Else
            l_open_act_item_flag := FALSE ;
          End if;
	  Close c_elig_dpnts;
      End if;
      Close c_not_emp_only;*/

      If l_open_act_item_flag then

        --
        -- There is no desination requirement defined for the option that
        -- doesn't allow dpnts. Write a DD action item.
        --
        -- process the action item
        --
        process_action_item
          (p_prtt_enrt_actn_id          => l_prtt_enrt_actn_id
          ,p_actn_typ_id                => l_actn_typ_id
          ,p_cmpltd_dt                  => l_cmpltd_dt
          ,p_object_version_number      => l_object_version_number
          ,p_effective_date             => p_effective_date
          ,p_rqd_data_found             => FALSE
          ,p_rqd_flag                   => l_rqd_flag
          ,p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
          ,p_post_rslt_flag             => p_post_rslt_flag
          ,p_business_group_id          => p_business_group_id
          ,p_datetrack_mode             => p_datetrack_mode
          ,p_rslt_object_version_number => p_rslt_object_version_number);
        --
        -- Since the action item was opened/reopened, set the flag to TRUE and
        -- also the p_hack flag to 'N' so that the calling procedure knows
        -- that action items were actually written and this not to fool it.
        --
        p_dd_actn_item_open := TRUE;
        p_hack := 'N';
        --
        -- Also, delete all other "dependent" action items that might exist for
        -- the prtt_enrt_rslt_id.
        --
        if g_debug then
          hr_utility.set_location('Deleting other dpnt actn items', 10);
        end if;
        --
        for actn_item_rec in c_other_dpnt_actn_items loop
          --
          delete_action_item
            (p_prtt_enrt_actn_id          => actn_item_rec.prtt_enrt_actn_id
            ,p_object_version_number      => actn_item_rec.object_version_number
            ,p_business_group_id          => p_business_group_id
            ,p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
            ,p_rslt_object_version_number => p_rslt_object_version_number
            ,p_effective_date             => p_effective_date
            ,p_datetrack_mode             => hr_api.g_zap
            ,p_post_rslt_flag             => p_post_rslt_flag);
          --
        end loop;
      else
        --
        -- The option does not allow designation of any dependents. Don't write
        -- any DD action items.
        --
        --
        -- Set the parameter to TRUE and the hack flag to 'Y' so that the
        -- calling procedure does not check for dpnt missing info.
        --
        p_dd_actn_item_open := TRUE;
        p_hack := 'Y';
	--
      End if;
        --
    else
      --
      if g_debug then
        hr_utility.set_location('Dpnts designated', 10);
      end if;
      --
      -- Dependents found. Set the out parameter.
      --
      p_dd_actn_item_open := FALSE;
      --
      -- If a DD action item was found, we need to complete it. Set the
      -- p_rqd_data_found flag to TRUE so that the process_action_item can
      -- close the DD action item.
      --
      process_action_item
        (p_prtt_enrt_actn_id          => l_prtt_enrt_actn_id
        ,p_actn_typ_id                => l_actn_typ_id
        ,p_cmpltd_dt                  => l_cmpltd_dt
        ,p_object_version_number      => l_object_version_number
        ,p_effective_date             => p_effective_date
        ,p_rqd_data_found             => TRUE
        ,p_rqd_flag                   => l_rqd_flag
        ,p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
        ,p_post_rslt_flag             => p_post_rslt_flag
        ,p_business_group_id          => p_business_group_id
        ,p_datetrack_mode             => p_datetrack_mode
        ,p_rslt_object_version_number => p_rslt_object_version_number);
    end if;
    --
    close c_dpnt_dsgn;
    --
  end if;
  --
  if g_debug then
    hr_utility.set_location('Leaving ' ||l_proc,10);
  end if;
  --
exception
  when others then
    if g_debug then
      hr_utility.set_location('Exception Raised '||l_proc, 10);
    end if;
    p_rslt_object_version_number  := l_rslt_object_version_number ;
    p_dd_actn_item_open := null;
    p_hack              := null;

    raise;
--
end determine_dpnt_actn_items;
--
-- ----------------------------------------------------------------------------
-- |-----------------< complete_dependent_designation >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure complete_dependent_designation
  (p_prtt_enrt_rslt_id          in     number
  ,p_effective_date             in     date
  ,p_business_group_id          in     number
  ,p_datetrack_mode             in     varchar2 default hr_api.g_correction
  ,p_post_rslt_flag             in     varchar2 default 'Y'
  ,p_dsgn_cd                    in     varchar2
  ,p_rslt_object_version_number in out nocopy number
  ,p_dpnt_actn_warning          in out nocopy boolean) is
  --
  -- this procedure determines if desginated dependents meet all the criteria
  -- to complete an open DD action item.  The participant can change plans to
  -- where designation requirements such as the minimum number of dependents or
  -- maximum number of dependents has changed.  If a participant changes option
  -- within a plan they are required to re-designate their dependents so this is
  -- only relevent for a 'plan' change.
  --
  l_proc     varchar2(80) ;
  --
  l_meets_rqmt  varchar2(1) := 'Y';
  l_actn_typ_id number(15);
  l_cmpltd_dt date;
  l_object_version_number number;
  l_prtt_enrt_actn_id  ben_prtt_enrt_actn_f.prtt_enrt_actn_id%type;
  l_rslt_object_version_number   number(15);
  l_dpnt_actn_warning            boolean ;
  --
  --
  -- look for dsgn rqmt records that have no group code.  These indicate
  -- a general mininum (and/or maximum) number of dpnts that can be
  -- designated for this comp object.
  --
  -- cursor c_min_no_grp modified against Bug 7516987
  cursor c_min_no_grp (c_effective_date date) is
  select mn_dpnts_rqd_num
    from ben_prtt_enrt_rslt_f perslt,
         ben_dsgn_rqmt_f drq
   where perslt.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and perslt.prtt_enrt_rslt_stat_cd is null
     and drq.dsgn_typ_cd = 'DPNT'
     and drq.grp_rlshp_cd is null
     and (nvl(drq.pl_id,0) = perslt.pl_id
          or
          nvl(drq.oipl_id,0) = perslt.oipl_id
          or
          nvl(drq.opt_id,0) = (select o.opt_id
                                 from ben_oipl_f o
                                where o.oipl_id = perslt.oipl_id
                                  and c_effective_date
                                        between o.effective_start_date
                                            and o.effective_end_date)
         )
     and drq.business_group_id = p_business_group_id
     and c_effective_date between drq.effective_start_date
                              and drq.effective_end_date
     and perslt.business_group_id = p_business_group_id
     and c_effective_date between perslt.effective_start_date
                              and perslt.effective_end_date;
  --
  l_min_no_grp c_min_no_grp%rowtype;
  --
  cursor c_num_of_dpnts is
  select count(1) cnt
    from ben_elig_cvrd_dpnt_f ecd,
         ben_per_in_ler pil
   where p_prtt_enrt_rslt_id = ecd.prtt_enrt_rslt_id
     and ecd.cvg_strt_dt is not null
     and nvl(ecd.cvg_thru_dt, hr_api.g_eot) = hr_api.g_eot
     and ecd.business_group_id = p_business_group_id
     and p_effective_date between ecd.effective_start_date
                              and ecd.effective_end_date
     and pil.per_in_ler_id=ecd.per_in_ler_id
     and pil.business_group_id=p_business_group_id
     and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT');
  --
  l_num_of_dpnts c_num_of_dpnts%rowtype;
  --
  -- Select 'x' where there are dsgn rqmts for specific contact types
  -- and we don't have the minimum number of that contact type
  -- designated.
  --
  -- cursor c_min_typ modified against Bug 7516987
  cursor c_min_typ (c_effective_date date) is
  select distinct 'X'  -- mn_dpnts_rqd_num
    from ben_prtt_enrt_rslt_f perslt,
         ben_dsgn_rqmt_f drq
   where perslt.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and drq.dsgn_typ_cd = 'DPNT'
     and drq.grp_rlshp_cd is not null
     and perslt.prtt_enrt_rslt_stat_cd is null
     and (nvl(drq.pl_id,0) = perslt.pl_id
          or
          nvl(drq.oipl_id,0) = perslt.oipl_id
          or
          nvl(drq.opt_id,0) = (select o.opt_id
                                 from ben_oipl_f o
                                where o.oipl_id = perslt.oipl_id
                                  and c_effective_date
                                        between o.effective_start_date
                                            and o.effective_end_date)
         )
     and drq.business_group_id = p_business_group_id
     and c_effective_date between drq.effective_start_date
                              and drq.effective_end_date
     and perslt.business_group_id = p_business_group_id
     and c_effective_date between perslt.effective_start_date
                              and perslt.effective_end_date
     and mn_dpnts_rqd_num >
         (select count(1)
            from ben_elig_cvrd_dpnt_f ecd,
                 per_contact_relationships pcr,
                 ben_per_in_ler pil
           where ecd.prtt_enrt_rslt_id = perslt.prtt_enrt_rslt_id
             and ecd.cvg_strt_dt is not null
             and nvl(ecd.cvg_thru_dt, hr_api.g_eot) = hr_api.g_eot
             and ecd.business_group_id = p_business_group_id
             and c_effective_date between
                 ecd.effective_start_date and ecd.effective_end_date
             and perslt.person_id = pcr.person_id
             and ecd.dpnt_person_id = pcr.contact_person_id
             and pcr.business_group_id = p_business_group_id
             and pcr.contact_type in
                   (select drrt.rlshp_typ_cd
                      from ben_dsgn_rqmt_rlshp_typ drrt
                     where drrt.dsgn_rqmt_id = drq.dsgn_rqmt_id)
             and pil.per_in_ler_id=ecd.per_in_ler_id
             and pil.business_group_id=p_business_group_id
             and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT'));
  --
  l_min_typ c_min_typ%rowtype;

  -- added cursor c_get_ler_typ against Bug 7516987 to check for open life event
  -- Bug 7516987
  cursor  c_get_ler_typ is
  select  ler.typ_cd,
          pil.lf_evt_ocrd_dt
    from  ben_prtt_enrt_rslt_f pen,
          ben_per_in_ler pil,
	  ben_ler_f ler
   where  pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and  pen.per_in_ler_id = pil.per_in_ler_id
     and  ler.ler_id = pil.ler_id
     and  pil.lf_evt_ocrd_dt between ler.effective_start_date and ler.effective_end_date
     order by pil.lf_evt_ocrd_dt desc; --Bug 8549599: Added order by clause to get the latest LifeEvent occured date

  l_get_ler_typ c_get_ler_typ%rowtype;

  -- Bug 7516987

  l_rqd_flag              varchar2(30);
  --
begin
--
  if g_debug then
    l_proc      := g_package||'.complete_dependent_designation';
    hr_utility.set_location ('Entering '||l_proc,10);
  end if;
  --
  l_rslt_object_version_number :=p_rslt_object_version_number;
  l_dpnt_actn_warning          :=p_dpnt_actn_warning ;

  -- Bug 7516987
  open c_get_ler_typ;
  fetch c_get_ler_typ into l_get_ler_typ;
  close c_get_ler_typ;
  -- Bug 7516987

  hr_utility.set_location ('l_get_ler_typ.typ_cd '||to_char(l_get_ler_typ.typ_cd),20);
  hr_utility.set_location ('l_get_ler_typ.lf_evt_ocrd_dt '||to_char(l_get_ler_typ.lf_evt_ocrd_dt),20);
  hr_utility.set_location ('p_effective_date '||p_effective_date,20);
  hr_utility.set_location ('p_prtt_enrt_rslt_id '||p_prtt_enrt_rslt_id,20);
  hr_utility.set_location ('l_get_ler_typ '||l_get_ler_typ.typ_cd,20);

  --
  -- Check the total number of dpnts designated.  See if it's less
  -- than the minimum number of dpnts of any contact type.  There
  -- should only be one rqmt record with no group code for this
  -- comp object, so no need for a loop.
  --

  -- Bug 7516987
  -- For Open life event, look for the setup of designation requirement as of life event occurred date
  if l_get_ler_typ.typ_cd in ('SCHEDDO', 'SCHEDDA') then
     open c_min_no_grp (l_get_ler_typ.lf_evt_ocrd_dt);
     fetch c_min_no_grp into l_min_no_grp;
  else
     open c_min_no_grp (p_effective_date);
     fetch c_min_no_grp into l_min_no_grp;
  end if;

  -- Bug 7516987
  --
  if c_min_no_grp%FOUND and
     nvl(l_min_no_grp.mn_dpnts_rqd_num,0) > 0 then
    --
    open c_num_of_dpnts;
    fetch c_num_of_dpnts into l_num_of_dpnts;
    --
    if l_num_of_dpnts.cnt < l_min_no_grp.mn_dpnts_rqd_num then
      -- create action item for additional dpnts needed.
      l_meets_rqmt := 'N';
    end if;
    --
    close c_num_of_dpnts;
    --
  end if;
  --
  close c_min_no_grp;
  --
  if g_debug then
    hr_utility.set_location ('After c_min_no_grp '||l_proc,20);
  end if;
  --
  -- Check the other dsgn rqmts.  If there are any rows returned from
  -- this cursor, then the person must designate more dependents of
  -- some contact type.
  --

  -- Bug 7516987
  -- For Open life event, look for the setup of designation requirement as of life event occurred date
  if l_get_ler_typ.typ_cd in ('SCHEDDO', 'SCHEDDA') then
     open c_min_typ (l_get_ler_typ.lf_evt_ocrd_dt);
     fetch c_min_typ into l_min_typ;
  else
     open c_min_typ (p_effective_date);
     fetch c_min_typ into l_min_typ;
  end if;
  -- Bug 7516987

  if c_min_typ%FOUND then
     -- create action item for additional dpnts needed.
     l_meets_rqmt := 'N';
  end if;
  --
  close c_min_typ;
  --
  if g_debug then
    hr_utility.set_location ('After c_min_typ '||l_proc,30);
  end if;
  --
  --
  -- find DDADDNL action item, if it exists.
  --
  l_actn_typ_id := get_actn_typ_id
                     (p_type_cd           => 'DDADDNL'
                     ,p_business_group_id => p_business_group_id);
  --
  get_prtt_enrt_actn_id
    (p_actn_typ_id           => l_actn_typ_id
    ,p_prtt_enrt_rslt_id     => p_prtt_enrt_rslt_id
    ,p_effective_date        => p_effective_date
    ,p_business_group_id     => p_business_group_id
    ,p_prtt_enrt_actn_id     => l_prtt_enrt_actn_id
    ,p_cmpltd_dt             => l_cmpltd_dt
    ,p_object_version_number => l_object_version_number);
  --
  if g_debug then
    hr_utility.set_location ('After get_prtt_enrt_actn_id call '||l_proc,30);
  end if;
  --
  if p_dsgn_cd = 'R' then
      l_rqd_flag := 'Y';
    else
      l_rqd_flag := 'N';
    end if;
    --
  if l_meets_rqmt = 'Y' then
    --
    if g_debug then
      hr_utility.set_location('Meets addnl dpnt rqmts', 10);
    end if;
    --
    -- they meet the minimum number of dpnts, call process-action-item with
    -- rqd-data 'true'
    --
    process_action_item
      (p_prtt_enrt_actn_id          => l_prtt_enrt_actn_id
      ,p_actn_typ_id                => l_actn_typ_id
      ,p_cmpltd_dt                  => l_cmpltd_dt
      ,p_object_version_number      => l_object_version_number
      ,p_effective_date             => p_effective_date
      ,p_rqd_data_found             => TRUE
      ,p_rqd_flag                   => l_rqd_flag
      ,p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
      ,p_post_rslt_flag             => p_post_rslt_flag
      ,p_business_group_id          => p_business_group_id
      ,p_datetrack_mode             => p_datetrack_mode
      ,p_rslt_object_version_number => p_rslt_object_version_number);
    --
  elsif l_meets_rqmt = 'N' then
    --
    if g_debug then
      hr_utility.set_location('Does not meet rqmts', 10);
    end if;
    --
    --
    -- Doesn't meet requirements. set rqd-data 'FALSE'
    --
    process_action_item
      (p_prtt_enrt_actn_id          => l_prtt_enrt_actn_id
      ,p_actn_typ_id                => l_actn_typ_id
      ,p_cmpltd_dt                  => l_cmpltd_dt
      ,p_object_version_number      => l_object_version_number
      ,p_effective_date             => p_effective_date
      ,p_rqd_data_found             => FALSE
      ,p_rqd_flag                   => l_rqd_flag
      ,p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
      ,p_post_rslt_flag             => p_post_rslt_flag
      ,p_business_group_id          => p_business_group_id
      ,p_datetrack_mode             => p_datetrack_mode
      ,p_rslt_object_version_number => p_rslt_object_version_number);
    --
  end if;
  --
  -- Pass a warning back to the calling proc only if the requirements are not
  -- met and the incoming value was FALSE.
  --
  if l_meets_rqmt = 'N' and p_dpnt_actn_warning = FALSE then
    p_dpnt_actn_warning := TRUE;
  end if;
  --
  if g_debug then
    hr_utility.set_location ('Leaving ' ||l_proc,90);
  end if;
  --
exception
  when others then
    if g_debug then
      hr_utility.set_location('Exception Raised '||l_proc, 99);
    end if;
    p_rslt_object_version_number := l_rslt_object_version_number;
    p_dpnt_actn_warning          := l_dpnt_actn_warning ;
    raise;
--
end complete_dependent_designation;
--
-- ----------------------------------------------------------------------------
-- |----------------------< process_dpnt_actn_items >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure process_dpnt_actn_items
  (p_validate                   in     boolean  default FALSE
  ,p_prtt_enrt_rslt_id          in     number
  ,p_effective_date             in     date
  ,p_business_group_id          in     number
  ,p_datetrack_mode             in     varchar2 default hr_api.g_correction
  ,p_post_rslt_flag             in     varchar2 default 'Y'
  ,p_rslt_object_version_number in out nocopy number
  ,p_suspend_flag               in out nocopy varchar2
  ,p_dpnt_actn_warning             out nocopy boolean
  --Bug No 4525608 to capture the certification required warning
  ,p_ctfn_actn_warning             out nocopy boolean) is
  --End Bug 4525608
  --
  l_proc         varchar2(80);
  l_rslt_object_version_number  number(15);
  l_suspend_flag                varchar2(15);

  --
  l_dd_actn_item_open boolean := FALSE; -- flag is set to TRUE if a DD actn item
                                        -- is written/opened.
  l_dpnt_actn_warning boolean := FALSE;

  --Bug No 4525608 Addtional local parameter
  l_ctfn_actn_warning boolean := FALSE;
  --End Bug 4525608

  l_hack varchar2(1) := 'N';
  l_allws_flag            varchar2(30);
  l_dsgn_cd               varchar2(30);

  cursor c_chc_flags is
  select epe.alws_dpnt_dsgn_flag, epe.dpnt_dsgn_cd
    from ben_prtt_enrt_rslt_f pen,
         ben_elig_per_elctbl_chc epe,
         ben_per_in_ler pil
   where pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and pen.prtt_enrt_rslt_stat_cd is null
     and p_effective_date between
         pen.effective_start_date and pen.effective_end_date
-- Join by comp object not result_id
     and nvl(pen.pgm_id,-1)=nvl(epe.pgm_id,-1)
     and pen.pl_id=epe.pl_id
     and epe.bnft_prvdr_pool_id is null  -- Bug 2389261 exclude these records
     and nvl(pen.oipl_id,-1)=nvl(epe.oipl_id,-1)
--     and pen.prtt_enrt_rslt_id = epe.prtt_enrt_rslt_id
     and pen.per_in_ler_id     = epe.per_in_ler_id
     and epe.business_group_id = p_business_group_id
     and pil.per_in_ler_id = epe.per_in_ler_id
     and pil.business_group_id = p_business_group_id
     and pil.per_in_ler_stat_cd not in ('VOIDD', 'BCKDT');
--
begin
--
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_proc         := g_package||'.process_dpnt_actn_items';
    hr_utility.set_location ('Entering '||l_proc,10);
  end if;
  --
  l_rslt_object_version_number :=p_rslt_object_version_number;
  l_suspend_flag               :=p_suspend_flag  ;


  -- Issue a savepoint if operating in validate only mode
  --
  savepoint process_dpnt_actn_items;
  --
  open c_chc_flags;
  fetch c_chc_flags into l_allws_flag, l_dsgn_cd;
   if c_chc_flags%notfound then
     l_allws_flag := 'N';
     l_dsgn_cd := 'O';
   end if;
  close c_chc_flags;
  --
  -- BUG:3248711: Since epe.alws_dpnt_dsgn_flag = 'N' (LE doesn't allow dpnt dsgn)
  -- and yet epe.dpnt_dsgn_cd = 'R' (Dpnt Dsgn is Required)
  -- In this case.. we'll have to show the the message that 'Dpnt design is pending'
  -- and also suspend the plan. Hence the or-condition (l_dsgn_cd = 'R') as been added
  -- to below if-condition

  if ( (l_allws_flag = 'Y') or (l_dsgn_cd = 'R') ) then

    determine_dpnt_actn_items
      (p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
      ,p_rslt_object_version_number => p_rslt_object_version_number
      ,p_effective_date             => p_effective_date
      ,p_business_group_id          => p_business_group_id
      ,p_datetrack_mode             => p_datetrack_mode
      ,p_post_rslt_flag             => p_post_rslt_flag
      ,p_allws_flag                 => l_allws_flag
      ,p_dsgn_cd                    => l_dsgn_cd
      ,p_dd_actn_item_open          => l_dd_actn_item_open
      ,p_hack                       => l_hack);
    --
    if l_dd_actn_item_open = FALSE then
      --
      -- The following is executed only if a DD action item was not written, i.e.
      -- dependents were found
      --
      determine_dpnt_miss_actn_items
        (p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
        ,p_effective_date             => p_effective_date
        ,p_business_group_id          => p_business_group_id
        ,p_datetrack_mode             => p_datetrack_mode
        ,p_post_rslt_flag             => p_post_rslt_flag
        ,p_rslt_object_version_number => p_rslt_object_version_number
        ,p_dpnt_actn_warning          => l_dpnt_actn_warning);
      --
      complete_dependent_designation
        (p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
        ,p_effective_date             => p_effective_date
        ,p_business_group_id          => p_business_group_id
        ,p_datetrack_mode             => p_datetrack_mode
        ,p_post_rslt_flag             => p_post_rslt_flag
        ,p_dsgn_cd                    => l_dsgn_cd
        ,p_rslt_object_version_number => p_rslt_object_version_number
        ,p_dpnt_actn_warning          => l_dpnt_actn_warning);
      --
--Bug No 4525608
--Passed additional parameter p_ctfn_actn_warning
--to capture the certification action warning
       determine_other_actn_items
       (p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
       ,p_rslt_object_version_number => p_rslt_object_version_number
       ,p_effective_date             => p_effective_date
       ,p_post_rslt_flag             => p_post_rslt_flag
       ,p_business_group_id          => p_business_group_id
       ,p_validate                   => FALSE
       ,p_datetrack_mode             => p_datetrack_mode
       ,p_suspend_flag               => l_suspend_flag
       ,p_ctfn_actn_warning          => l_ctfn_actn_warning);
--End Bug 4525608
     --
    else
      --
      -- l_dd_actn_item_open is TRUE. Set l_dpnt_actn_warning to TRUE to indicate
      -- that an action item has been written or reopened
      --
      if l_hack = 'Y' then
        -- This indicates that the l_dd_actn_item_open was set to TRUE only to
        -- fool this process to not check for dependent mising items  and no
        -- DD action item was written. Set the l_dpnt_actn_warning to FALSE
        --
        l_dpnt_actn_warning := FALSE;
      else
        l_dpnt_actn_warning := TRUE;
      end if;
      --
    end if;
    --
  end if; -- allws_dpnt_flag = 'Y'
  --
  p_dpnt_actn_warning := l_dpnt_actn_warning;

  --Bug No 4525608 capture the certification required action item warning
  p_ctfn_actn_warning := l_ctfn_actn_warning;
  -- End Bug No 4525608

  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  if g_debug then
    hr_utility.set_location ('Leaving '||l_proc, 10);
  end if;
  --
exception
  --
  when hr_api.validate_enabled
  then
    rollback to process_dpnt_actn_items;
    --
    if g_debug then
      hr_utility.set_location(' Leaving:'||l_proc, 10);
    end if;
  --
  when others then
    if g_debug then
      hr_utility.set_location('Exception Raised '||l_proc, 10);
    end if;

    p_rslt_object_version_number := l_rslt_object_version_number ;
    p_suspend_flag               := l_suspend_flag ;
    p_dpnt_actn_warning          := null ;

    --Bug No 4525608 when any exception
    p_ctfn_actn_warning          := null ;
    --End Bug No 4525608

    raise;
--
end process_dpnt_actn_items;
--
procedure check_ctfn_prvdd
    (p_prtt_enrt_rslt_id          in     number
    ,p_effective_date             in     date
    ,p_business_group_id          in     number
    ,p_enrt_ctfn_typ_cd           in     varchar2
    ,p_oipl_id                    in     number
    ,p_rqd_flag                   in     varchar2
    ,p_pl_id                      in     number
    ,p_per_in_ler_id              in     number
    ,p_bnft_amt                   in     number
    ,p_ctfn_determine_cd          in     varchar2
    ,p_crntly_enrd_flag           in     varchar2
    ,p_enrt_r_bnft_ctfn_cd        in     varchar2 default null      -- Bug 5887665
    ,p_ctfn_prvdd                 out    nocopy boolean) is
  --
  --Determine the level of the certification
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
  --Determine if currently enrolled at the plan level
  --
  /* ikasire
  Bug 4454990 See the details below. Keep in mind that this happens before the
  delete enrollment call from election information.
  So these are the following cases we need to keep in mind. If you see issues
  please do add the example here so that the future developer won't intruduce another
  regression.

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
                                               NewOipl
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
                                               NewOipl
                                               NewPIL
                                               NewPEN
                                               CTD   EOT
                                               EED   EOT

     Case 4: delete the current enrollment and enroll in a new one later

          OldOipl                              OldOipl
          OldPIL                               NewPIL
          OldPEN                               OldPEN
                                               CTD   Date will be filled in
                                               EED   EOT
              [the data will change once the delete enrollment is called]
                                               NewOipl
                                               NewPIL
                                               NewPEN
                                               CTD   EOT
                                               EED   EOT

  */

  cursor c_current_pl_enrollment (p_prtt_enrt_rslt_id number) is
    select 'Y'
    from  ben_prtt_enrt_rslt_f pen,
          ben_prtt_enrt_rslt_f pen2
    where pen2.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
    and   nvl(pen2.rplcs_sspndd_rslt_id,-999) <> pen.prtt_enrt_rslt_id --NO Interim
    and   pen2.effective_end_date = to_date('31-12-4712','dd-mm-yyyy')
    and   pen2.pl_id = pen.pl_id
    and   pen2.person_id = pen.person_id
    and   pen.sspndd_flag = 'N'
    and   (
            (  pen2.per_in_ler_id = pen.per_in_ler_id and
               (  pen.enrt_cvg_thru_dt <>  to_date('31-12-4712','dd-mm-yyyy') or
                  (  (-- pen.prtt_enrt_rslt_id <> pen2.prtt_enrt_rslt_id and
                      exists (select 'x' from ben_elig_per_elctbl_chc epe,
                                              ben_prtt_enrt_rslt_f pen3
                              where epe.per_in_ler_id = pen.per_in_ler_id and
                                    epe.pl_id = pen.pl_id and
                                    ( epe.pgm_id = pen.pgm_id or pen.pgm_id is null) and
                                    ( epe.oipl_id = pen.oipl_id or pen.oipl_id is null) and
                                    epe.crntly_enrd_flag = 'Y' and
                                    epe.elctbl_flag = 'Y' and
                                    epe.bnft_prvdr_pool_id is null and
                                    pen3.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id and
                                    pen3.prtt_enrt_rslt_stat_cd is null and
                                    pen3.sspndd_flag = 'N' and
                                    pen3.effective_end_date = pen.effective_start_date - 1
                              )
                     ) and
                     pen.enrt_cvg_thru_dt = to_date('31-12-4712','dd-mm-yyyy')
                  )
               ) and
               pen.effective_end_date = to_date('31-12-4712','dd-mm-yyyy')
            )
            or
            (  pen.enrt_cvg_thru_dt = to_date('31-12-4712','dd-mm-yyyy') and
                pen.effective_end_date = to_date('31-12-4712','dd-mm-yyyy') and
                pen.per_in_ler_id <> pen2.per_in_ler_id
            )
          )
    and  pen2.prtt_enrt_rslt_stat_cd is null
    and  pen.prtt_enrt_rslt_stat_cd is null ;
  --
  --Current Option enrollment
  --
  cursor c_current_oipl_enrollment (p_prtt_enrt_rslt_id number) is
    select 'Y'
    from  ben_prtt_enrt_rslt_f pen,
          ben_prtt_enrt_rslt_f pen2
    where pen2.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
    and   nvl(pen2.rplcs_sspndd_rslt_id,-999) <> pen.prtt_enrt_rslt_id --NO Interim
    and   pen2.effective_end_date = to_date('31-12-4712','dd-mm-yyyy')
    and   pen2.pl_id = pen.pl_id
    and   pen2.oipl_id = pen.oipl_id
    and   pen2.person_id = pen.person_id
    and   pen.sspndd_flag = 'N'
    and   (
            (  pen2.per_in_ler_id = pen.per_in_ler_id and
               (  pen.enrt_cvg_thru_dt <>  to_date('31-12-4712','dd-mm-yyyy') or
                  (  (-- pen.prtt_enrt_rslt_id <> pen2.prtt_enrt_rslt_id or
                      exists (select 'x' from ben_elig_per_elctbl_chc epe,
                                              ben_prtt_enrt_rslt_f pen3
                              where epe.per_in_ler_id = pen2.per_in_ler_id and
                                    epe.pl_id = pen2.pl_id and
                                    ( epe.pgm_id = pen2.pgm_id or pen2.pgm_id is null) and
                                    ( epe.oipl_id = pen2.oipl_id ) and
                                    epe.crntly_enrd_flag = 'Y' and
                                    epe.elctbl_flag = 'Y' and
                                    epe.bnft_prvdr_pool_id is null and
                                    pen3.prtt_enrt_rslt_id = pen2.prtt_enrt_rslt_id and
                                    pen3.prtt_enrt_rslt_stat_cd is null and
                                    pen3.sspndd_flag = 'N' and
                                    pen3.effective_end_date = pen2.effective_start_date - 1
                              )
                     ) and
                     pen.enrt_cvg_thru_dt = to_date('31-12-4712','dd-mm-yyyy')
                  )
               ) and
               pen.effective_end_date = to_date('31-12-4712','dd-mm-yyyy')
            )
            or
            (  pen.enrt_cvg_thru_dt = to_date('31-12-4712','dd-mm-yyyy') and
                pen.effective_end_date = to_date('31-12-4712','dd-mm-yyyy') and
                pen.per_in_ler_id <> pen2.per_in_ler_id
            )
          )
    and  pen2.prtt_enrt_rslt_stat_cd is null
    and  pen.prtt_enrt_rslt_stat_cd is null ;
  --
  --End Determine the level of the certification
  --

 --
 -- Bug 5965415 : Updated the cursor to check if any certification received in past
 --               for the same plan-option (and not based on pen_id as it changes
 --               when coverage amount changes)
 --
 cursor c_ctfn_prvdd (p_prtt_enrt_rslt_id number) is
    select null
    from ben_prtt_enrt_ctfn_prvdd_f pcs
    where pcs.prtt_enrt_rslt_id in
          (select distinct(pen1.prtt_enrt_rslt_id) from ben_prtt_enrt_rslt_f pen1, ben_prtt_enrt_rslt_f pen2
                                 where pen2.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
                                 and pen1.person_id = pen2.person_id
                                 and pen1.prtt_enrt_rslt_stat_cd is null
                                 and pen2.prtt_enrt_rslt_stat_cd is null
                                 and pen1.pl_id = pen2.pl_id
                                 --and pen1.per_in_ler_id <> pen2.per_in_ler_id /* Bug 7513897 : If Coverage Amount is changed multiple times for the same Life Event */
                                 and nvl(pen2.oipl_id,0) = nvl(pen1.oipl_id,0)
                                 and pen1.enrt_cvg_thru_dt >= pen1.effective_start_date
                                 and pen1.enrt_cvg_strt_dt <= pen1.enrt_cvg_thru_dt
                                 and pen2.enrt_cvg_thru_dt = to_date('4712/12/31','rrrr/mm/dd')
                                 and p_effective_date between pen2.effective_start_date and
                                     pen2.effective_end_date
                                 and pen1.orgnl_enrt_dt = pen2.orgnl_enrt_dt)
    and   pcs.ENRT_CTFN_TYP_CD  = p_enrt_ctfn_typ_cd
    and   pcs.ENRT_CTFN_RECD_DT is not null
    and   pcs.enrt_ctfn_rqd_flag = 'Y'
    and   pcs.ENRT_R_BNFT_CTFN_CD = nvl(p_enrt_r_bnft_ctfn_cd,'ENRT')   -- Bug 5887665
    ---Bug 7417593
   /* and   p_effective_date between pcs.effective_start_date and
            pcs.effective_end_date*/
    and p_effective_date >= pcs.enrt_ctfn_recd_dt -- Bug 8669907: Changed condition to >=
    ---Bug 7417593
    ;
  --
  cursor c_ctfn_prvdd2 (p_prtt_enrt_rslt_id number) is
    select null
    from ben_prtt_enrt_ctfn_prvdd_f pcs
    where pcs.prtt_enrt_rslt_id in
          (select distinct(pen1.prtt_enrt_rslt_id) from ben_prtt_enrt_rslt_f pen1, ben_prtt_enrt_rslt_f pen2
                                 where pen2.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
                                 and pen1.person_id = pen2.person_id
                                 and pen1.prtt_enrt_rslt_stat_cd is null
                                 and pen2.prtt_enrt_rslt_stat_cd is null
                                 and pen1.pl_id = pen2.pl_id
                                 --and pen1.per_in_ler_id <> pen2.per_in_ler_id /* Bug 7513897 : If Coverage Amount is changed multiple times for the same Life Event */
                                 and nvl(pen2.oipl_id,0) = nvl(pen1.oipl_id,0)
                                 and pen1.enrt_cvg_thru_dt >= pen1.effective_start_date
                                 and pen1.enrt_cvg_strt_dt <= pen1.enrt_cvg_thru_dt
                                 and pen2.enrt_cvg_thru_dt = to_date('4712/12/31','rrrr/mm/dd')
                                 and p_effective_date between pen2.effective_start_date and
                                     pen2.effective_end_date
                                 and pen1.orgnl_enrt_dt = pen2.orgnl_enrt_dt)
    and   pcs.ENRT_CTFN_RECD_DT is not null
    and   pcs.ENRT_R_BNFT_CTFN_CD = nvl(p_enrt_r_bnft_ctfn_cd,'ENRT')  -- Bug 5887665
    and   pcs.enrt_ctfn_rqd_flag = 'N'
    and   exists (select null from ben_prtt_enrt_ctfn_prvdd_f pcs2
                  where pcs2.prtt_enrt_rslt_id = pcs.prtt_enrt_rslt_id
                  and   pcs2.ENRT_CTFN_TYP_CD = p_enrt_ctfn_typ_cd
                  and   p_effective_date between pcs2.effective_start_date and
                        pcs2.effective_end_date)
    and   p_effective_date between pcs.effective_start_date and
            pcs.effective_end_date;
--
-- End Bug 5965415
--
  cursor c_prtt_enrt_rslt (p_prtt_enrt_rslt_id number) is
    select pen.prtt_enrt_rslt_id
    from  ben_prtt_enrt_rslt_f pen,
          ben_prtt_enrt_rslt_f pen2
    where pen2.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
--  and   pen2.bnft_amt is null          -- Bug 5887665 Need to call this code for benefit level certifications as well
    and   pen2.effective_end_date = to_date('31-12-4712','dd-mm-yyyy')
    and   pen2.pl_id = pen.pl_id
    and   pen2.person_id = pen.person_id
    and   ((pen2.per_in_ler_id = pen.per_in_ler_id and
           pen2.oipl_id <> pen.oipl_id and   -- Bug 5887665 Only in same LE we need to chk if option is changed
           pen.enrt_cvg_thru_dt <>  to_date('31-12-4712','dd-mm-yyyy') and
           pen.effective_end_date = to_date('31-12-4712','dd-mm-yyyy')) or
           (pen.enrt_cvg_thru_dt = to_date('31-12-4712','dd-mm-yyyy') and
           pen.effective_end_date = to_date('31-12-4712','dd-mm-yyyy') and  -----Bug 7417474
	   pen2.oipl_id = pen.oipl_id)) ----Bug 7417474
    and  pen2.prtt_enrt_rslt_stat_cd is null
    and  pen.prtt_enrt_rslt_stat_cd is null;
  --
  cursor  c_ler_rstrn(p_effective_date date,
                      p_per_in_ler_id  number,
                      p_pl_id          number) is
    select rstrn.cvg_incr_r_decr_only_cd
    from   ben_ler_bnft_rstrn_f rstrn,
           ben_per_in_ler pil
    where  rstrn.ler_id = pil.ler_id
    and    rstrn.pl_id  = p_pl_id
    and    pil.per_in_ler_id = p_per_in_ler_id
    and    p_effective_date
           between rstrn.effective_start_date
           and     rstrn.effective_end_date;
  --
  cursor c_pl_rstrn (p_effective_date date,
                     p_pl_id          number) is
    select pln.cvg_incr_r_decr_only_cd,
           pln.bnft_or_option_rstrctn_cd
    from   ben_pl_f pln
    where  pln.pl_id = p_pl_id
    and    p_effective_date
           between pln.effective_start_date
           and     pln.effective_end_date;
  --
  cursor c_prev_enrollment (p_prtt_enrt_rslt_id number) is
    select pen.bnft_amt
    from  ben_prtt_enrt_rslt_f pen,
          ben_prtt_enrt_rslt_f pen2
    where pen2.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
    and   pen2.bnft_amt <> pen.bnft_amt
    and   pen2.effective_end_date = to_date('31-12-4712','dd-mm-yyyy')
    and   pen2.pl_id = pen.pl_id
    and   pen2.person_id = pen.person_id
    and   ((pen2.per_in_ler_id = pen.per_in_ler_id and
           pen.enrt_cvg_thru_dt <>  to_date('31-12-4712','dd-mm-yyyy') and
           pen.effective_end_date = to_date('31-12-4712','dd-mm-yyyy')) or
           (pen.enrt_cvg_thru_dt = to_date('31-12-4712','dd-mm-yyyy') and
           pen.effective_end_date = to_date('31-12-4712','dd-mm-yyyy')))
    and  pen2.prtt_enrt_rslt_stat_cd is null
    and  pen.prtt_enrt_rslt_stat_cd is null;
  --
  cursor c_new_dependent (p_prtt_enrt_rslt_id number) is
    select 'Y'
    from ben_elig_cvrd_dpnt_f egd
    where egd.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
    and   egd.per_in_ler_id = p_per_in_ler_id
    and   egd.cvg_thru_dt = hr_api.g_eot
    and not exists (select null
                    from ben_elig_cvrd_dpnt_f egd2
                    where egd.elig_cvrd_dpnt_id = egd2.elig_cvrd_dpnt_id
                    and   egd.dpnt_person_id = egd2.dpnt_person_id
                    and   egd2.per_in_ler_id <> p_per_in_ler_id);
  --
  l_prtt_enrt_rslt_id  number;
  l_ctfn_prvdd         boolean := false;
  l_dummy              varchar2(30) ;
  l_cvg_incr_code      varchar2(240);
  l_old_amt            number;
  l_bnft_or_option_rstrctn_cd VARCHAR2(30);
  l_cvg_incr_code_pln varchar(30);

--
Begin
  --
  hr_utility.set_location('Entering - Check certification prvdd',10);
  --
  hr_utility.set_location('ctfn_determine_cd'||p_ctfn_determine_cd,11);
  hr_utility.set_location('enrt_ctfn_typ_cd'||p_enrt_ctfn_typ_cd,11);
  hr_utility.set_location('prtt_enrt_rslt_id'||p_prtt_enrt_rslt_id,11);
  hr_utility.set_location('enrt_r_bnft_ctfn_cd'||p_enrt_r_bnft_ctfn_cd,11);
  --bug#3748133
  /*
  if p_crntly_enrd_flag = 'Y'  and p_ctfn_determine_cd = 'ENRFT' then
     if p_bnft_amt = 0  then
       l_ctfn_prvdd := TRUE;
     else
       --
       open c_prev_enrollment (p_prtt_enrt_rslt_id);
       fetch c_prev_enrollment into l_old_amt;
       close c_prev_enrollment;
       --
       if l_old_amt = p_bnft_amt then
         l_ctfn_prvdd := TRUE;
       end if;
     end if;
  end if;
  */
  --
  --BUG 4454990 Multiple Changes. See bug for the expected functionality
  --
  if p_ctfn_determine_cd = 'ENRFT' then
    --Check if the certification is defined at the plan level
    --If defined at the plan level, then need to see the previous enrollment in
    --any option in plan. If the ctfn is not defined at the plan level just check
    --for the currently enrolled
    --
    hr_utility.set_location(' p_ctfn_determine_cd = '||p_ctfn_determine_cd,122);
    --
    open c_pl_ctfn(p_pl_id,p_per_in_ler_id,p_effective_date,p_enrt_ctfn_typ_cd);
      fetch c_pl_ctfn into l_dummy;
      if c_pl_ctfn%found then
        --
        hr_utility.set_location(' Plan Level Cert',122);
        --
        open c_current_pl_enrollment(p_prtt_enrt_rslt_id);
          --
          fetch c_current_pl_enrollment into l_dummy;
          if c_current_pl_enrollment%found then
            hr_utility.set_location(' Plan Level - Currently Enrolled in',122);
            l_ctfn_prvdd := TRUE;
          end if;
          --
        close c_current_pl_enrollment;
        --
      elsif p_crntly_enrd_flag = 'Y' and p_oipl_id is not null then
        --
        hr_utility.set_location(' Option Level -',123);
        --Now we need to check if the previous enrollment was unsuspeded or not
        open c_current_oipl_enrollment(p_prtt_enrt_rslt_id);
          --
          fetch c_current_oipl_enrollment into l_dummy;
          if c_current_oipl_enrollment%found then
            hr_utility.set_location(' Option in Plan Level - Currently Enrolled in',122);
            l_ctfn_prvdd := TRUE;
          end if;
          --
        close c_current_oipl_enrollment;
        --
      else
        hr_utility.set_location('Not Currently Enrolled in- why here ', 123);
      end if;
    close c_pl_ctfn ;
  end if;
  --
  if not l_ctfn_prvdd  and p_ctfn_determine_cd = 'ENRNP' then
    --
    if p_rqd_flag = 'Y' then
      open c_ctfn_prvdd (p_prtt_enrt_rslt_id);
      fetch c_ctfn_prvdd into l_dummy;
      if c_ctfn_prvdd%found then
        l_ctfn_prvdd := TRUE;
      end if;
      close c_ctfn_prvdd;
      --
    else
       --
       open c_ctfn_prvdd2 (p_prtt_enrt_rslt_id);
       fetch c_ctfn_prvdd2 into l_dummy;
       if c_ctfn_prvdd2%found then
         l_ctfn_prvdd := TRUE;
       end if;
       close c_ctfn_prvdd2;
       --
    end if;
    --
  end if;
  --
  if not l_ctfn_prvdd and p_oipl_id is not null and
      p_ctfn_determine_cd = 'ENRNP'then
    --
    hr_utility.set_location('different opt',12);
    open c_prtt_enrt_rslt(p_prtt_enrt_rslt_id);
    fetch c_prtt_enrt_rslt into l_prtt_enrt_rslt_id;
    close c_prtt_enrt_rslt;
    --
    hr_utility.set_location('Prtt result Id'||l_prtt_enrt_rslt_id,13);
    if l_prtt_enrt_rslt_id is not null then
      --
      if p_rqd_flag = 'Y' then
         hr_utility.set_location('inside',11);
         open c_ctfn_prvdd(l_prtt_enrt_rslt_id);
         fetch c_ctfn_prvdd into l_dummy;
         if c_ctfn_prvdd%found then
           l_ctfn_prvdd := TRUE;
         end if;
         close c_ctfn_prvdd;
         --
      else
         --
         open c_ctfn_prvdd2(l_prtt_enrt_rslt_id);
         fetch c_ctfn_prvdd2 into l_dummy;
         if c_ctfn_prvdd2%found then
           hr_utility.set_location('True',14);
           l_ctfn_prvdd := TRUE;
         end if;
         close c_ctfn_prvdd2;
         --
       end if;
     end if;
  end if;
  if not l_ctfn_prvdd and  p_ctfn_determine_cd = 'ENRDP' then
     if p_crntly_enrd_flag = 'Y' then
     --check any new dependents designated
       l_dummy := null;
       open c_new_dependent(p_prtt_enrt_rslt_id);
       fetch c_new_dependent into l_dummy;
       close c_new_dependent;
       if l_dummy = 'Y' then
         l_ctfn_prvdd := FALSE;
       else
         l_ctfn_prvdd := TRUE;
       end if;
     else
        l_ctfn_prvdd := TRUE;
     end if;
     --
  end if;
     --
    --
  if not l_ctfn_prvdd  and
     (p_ctfn_determine_cd is null or p_ctfn_determine_cd = 'ENRAT') then
    --check for increase/decrease certification -bug#3590524
    open c_ler_rstrn (p_effective_date, p_per_in_ler_id, p_pl_id);
    fetch c_ler_rstrn into l_cvg_incr_code;
    close c_ler_rstrn;
    --
    --if l_cvg_incr_code is null then
    open c_pl_rstrn (p_effective_date, p_pl_id);
    fetch c_pl_rstrn into l_cvg_incr_code_pln, l_bnft_or_option_rstrctn_cd;
    close c_pl_rstrn;
    --end if;
    l_cvg_incr_code := NVL(l_cvg_incr_code, l_cvg_incr_code_pln);
    --
    if l_cvg_incr_code is not null then
      --
       -- new enrollment
     --
      if (NVL(l_bnft_or_option_rstrctn_cd,'BNFT') = 'BNFT') then            -- 5736589
      --
          if (p_crntly_enrd_flag is null or p_crntly_enrd_flag = 'N') then -- 3806262
             l_ctfn_prvdd := TRUE;
          else
            --only if the enrollment is new then certication is required
            open c_prev_enrollment (p_prtt_enrt_rslt_id);
            fetch c_prev_enrollment into l_old_amt;
            close c_prev_enrollment;
            if l_old_amt is null then
               l_ctfn_prvdd := TRUE;
            elsif l_cvg_incr_code = 'DECRCTF' and p_bnft_amt > l_old_amt then
               l_ctfn_prvdd := TRUE;
            elsif l_cvg_incr_code = 'INCRCTF' and p_bnft_amt < l_old_amt then
               l_ctfn_prvdd := TRUE;
            end if;
          end if;
          --
      end if;  -- 5736589
      --
    end if;
  end if;
  p_ctfn_prvdd := l_ctfn_prvdd;
  --
  if p_ctfn_prvdd then
    hr_utility.set_location('Leaving Check Ctfn Prvdd TRUE',13);
  else
    hr_utility.set_location('Leaving Check Ctfn Prvdd FALSE',14);
  end if;
  --
end;


-- ----------------------------------------------------------------------------
-- |--------------------< determine_other_actn_items >------------------------|
-- ----------------------------------------------------------------------------
--
procedure determine_other_actn_items
  (p_prtt_enrt_rslt_id          in     number
  ,p_effective_date             in     date
  ,p_business_group_id          in     number
  ,p_validate                   in     boolean  default FALSE
  ,p_enrt_bnft_id               in     number   default NULL
  ,p_datetrack_mode             in     varchar2 default hr_api.g_correction
  ,p_post_rslt_flag             in     varchar2 default 'Y'
  ,p_rslt_object_version_number in out nocopy number
  ,p_suspend_flag               in out nocopy varchar2
  ,p_ctfn_actn_warning             out nocopy boolean) is
  --
  -- this procedure determines all other enrollment action items that need to
  -- be written.  We are checking the participant enrollment results looking for
  -- certifications, ENRTCTFN, and required specific rates.
  --
  l_proc varchar2(80) := g_package||'.determine_other_actn_items';
  l_meets_rqmt varchar2(3);
  l_actn_typ_id number(15);
  l_prtt_enrt_ctfn_prvdd_id number(15);
  l_cmpltd_dt date;
  l_object_version_number number;
  l_prtt_enrt_actn_id number(15);
  l_datetrack_mode varchar2(30);
  l_enrt_exist varchar2(1);

  l_rslt_object_version_number  number(15);
  l_suspend_flag                varchar2(15);


  --
  cursor c_epe is
  select epe.ctfn_rqd_flag,
         epe.elig_per_elctbl_chc_id,
         epe.crntly_enrd_flag,
         epe.per_in_ler_id,
         epe.pl_id,
         nvl(pen.bnft_amt, 0) bnft_amt,
         pen.oipl_id
    from ben_prtt_enrt_rslt_f pen,
         ben_elig_per_elctbl_chc epe,
         ben_per_in_ler pil
   where pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and pen.prtt_enrt_rslt_stat_cd is null
     and p_effective_date between
         pen.effective_start_date and pen.effective_end_date
-- join by comp object
     and nvl(pen.pgm_id,-1)=nvl(epe.pgm_id,-1)
     and pen.pl_id=epe.pl_id
     and epe.bnft_prvdr_pool_id is null  -- Bug 2389261 exclude these records
     and nvl(pen.oipl_id,-1)=nvl(epe.oipl_id,-1)
--     and pen.prtt_enrt_rslt_id = epe.prtt_enrt_rslt_id
     and pen.per_in_ler_id     = epe.per_in_ler_id
     and epe.business_group_id = p_business_group_id
     and pil.per_in_ler_id = epe.per_in_ler_id
     and pil.business_group_id = p_business_group_id
     and pil.per_in_ler_stat_cd not in ('VOIDD', 'BCKDT');
  --
  l_epe c_epe%rowtype;
  --
  cursor c_ecc1(v_elig_per_elctbl_chc_id number) is
  select ecc.rqd_flag,
         ecc.enrt_ctfn_typ_cd,
         ecc.SUSP_IF_CTFN_NOT_PRVD_FLAG,
         ecc.ctfn_determine_cd
    from ben_elctbl_chc_ctfn ecc
   where ecc.elig_per_elctbl_chc_id = v_elig_per_elctbl_chc_id
     -- jcarpent added line below for bug 1488666
     and ecc.enrt_bnft_id is null
     and ecc.business_group_id = p_business_group_id;
  --
  cursor c_enrt_bnft is
  select enb.ctfn_rqd_flag,
         nvl(enb.entr_val_at_enrt_flag, 'N') entr_val_at_enrt_flag,
         mx_wout_ctfn_val,
         cvg_mlt_cd
    from ben_enrt_bnft enb
   where enb.enrt_bnft_id = p_enrt_bnft_id
     and enb.business_group_id = p_business_group_id;
  --
  l_enrt_bnft c_enrt_bnft%rowtype;
  --
  cursor c_ecc2(v_enrt_bnft_id number,
                v_elig_per_elctbl_chc_id number) is
  select ecc.rqd_flag,
         ecc.enrt_ctfn_typ_cd,
         ecc.SUSP_IF_CTFN_NOT_PRVD_FLAG,
         ecc.ctfn_determine_cd
    from ben_elctbl_chc_ctfn ecc
   where ecc.enrt_bnft_id = v_enrt_bnft_id
     and ecc.elig_per_elctbl_chc_id = v_elig_per_elctbl_chc_id
     and ecc.business_group_id = p_business_group_id;
  --
  cursor c_enrt_ctfn(v_prtt_enrt_actn_id number) is
  select pec.prtt_enrt_ctfn_prvdd_id,
         pec.enrt_ctfn_recd_dt,
         pec.object_version_number
    from ben_prtt_enrt_ctfn_prvdd_f pec
   where pec.prtt_enrt_actn_id = v_prtt_enrt_actn_id
     and pec.enrt_r_bnft_ctfn_cd = 'BNFT'
     and pec.business_group_id = p_business_group_id
     and p_effective_date between pec.effective_start_date
                              and pec.effective_end_date;
  l_enrt_ctfn c_enrt_ctfn%rowtype;
  --
  -- Bug No 4241743
  cursor c_enrt_actn ( p_actn_typ_id           number
                                 ,p_prtt_enrt_rslt_id   number
                                 ,p_effective_date      date
                                 ,p_business_group_id number)
  is
  select pea.prtt_enrt_actn_id,
            pea.per_in_ler_id
    from ben_prtt_enrt_actn_f pea,
             ben_per_in_ler pil
   where pea.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and pea.actn_typ_id = p_actn_typ_id
     and pea.pl_bnf_id is null
     and pea.elig_cvrd_dpnt_id is null
     and pea.per_in_ler_id = pil.per_in_ler_id
     and pil.per_in_ler_stat_cd not in ('BCKDT', 'VOIDD')
     and pea.business_group_id = p_business_group_id
     and p_effective_date between pea.effective_start_date
                              and pea.effective_end_date ;
  l_enrt_actn    c_enrt_actn%rowtype;
  --
  l_write_new_ctfn boolean := TRUE;
  l_ctfn_prvdd     boolean ;
  l_actn_exists varchar2(10) := 'N';    -- Bug No 4241743
  --
  -- Bug 5887665
  --
  cursor  c_ler_rstrn(p_effective_date date,
                      p_per_in_ler_id  number,
                      p_pl_id          number) is
    select rstrn.cvg_incr_r_decr_only_cd
    from   ben_ler_bnft_rstrn_f rstrn,
           ben_per_in_ler pil
    where  rstrn.ler_id = pil.ler_id
    and    rstrn.pl_id  = p_pl_id
    and    pil.per_in_ler_id = p_per_in_ler_id
    and    p_effective_date
           between rstrn.effective_start_date
           and     rstrn.effective_end_date;
  --
  cursor c_pl_rstrn (p_effective_date date,
                     p_pl_id          number) is
    select pln.cvg_incr_r_decr_only_cd,
           pln.bnft_or_option_rstrctn_cd
    from   ben_pl_f pln
    where  pln.pl_id = p_pl_id
    and    p_effective_date
           between pln.effective_start_date
           and     pln.effective_end_date;
  --
  l_bnft_or_option_rstrctn_cd VARCHAR2(30);
  l_cvg_incr_code_pln varchar(30);
  l_cvg_incr_code      varchar2(240);
  --
  -- End Bug 5887665
  --
begin
--
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    hr_utility.set_location ('Entering '||l_proc,10);
  end if;
  --
  l_rslt_object_version_number  :=p_rslt_object_version_number ;
  l_suspend_flag                :=p_suspend_flag ;

  --
  savepoint determine_other_actn_items;
  --
  -- Get elig_per_elctbl_chc id
  --
  open c_epe;
  fetch c_epe into l_epe;
  --
  if c_epe%notfound then
    close c_epe;
    /* Bug 2386000 When you run the close action items process after due date
       when enrollment was originally suspended due to the BOD certification
       requirement (for example) the enrollment might already be end dated
       as part of calls from bepenapi delete_enrollment and this may fail.
       Instead let us return without doing anything if this cursor doesnot
       return any records */
    -- fnd_message.set_name('BEN', 'BEN_91578_BENACPRM_EPE_NF');
    -- fnd_message.set_token('PROC',l_proc);
    -- fnd_message.set_token('PRTT_ENRT_RSLT_ID',to_char(p_prtt_enrt_rslt_id));
    -- fnd_message.set_token('EFFECTIVE_DATE',p_effective_date);
    -- fnd_message.set_token('BUSINESS_GROUP_ID',to_char(p_business_group_id));
    -- fnd_message.raise_error;
    if g_debug then
      hr_utility.set_location('Enrollment already ended/ZAPed by another process ',22);
    end if;
    return ;
  else
    close c_epe;
  end if;
  --
  l_actn_typ_id := get_actn_typ_id
                     (p_type_cd           => 'ENRTCTFN'
                     ,p_business_group_id => p_business_group_id);
  --
/*  get_prtt_enrt_actn_id
       (p_actn_typ_id           => l_actn_typ_id,
        p_prtt_enrt_rslt_id     => p_prtt_enrt_rslt_id,
        p_effective_date        => p_effective_date,
        p_business_group_id     => p_business_group_id,
        p_prtt_enrt_actn_id     => l_prtt_enrt_actn_id,
        p_cmpltd_dt             => l_cmpltd_dt,
        p_object_version_number => l_object_version_number);   */ -- Commented for 4241743
  --
  hr_utility.set_location('CTFN rqd flag '||l_epe.ctfn_rqd_flag,9);
  if l_epe.ctfn_rqd_flag = 'Y' then
    --
    if g_debug then
      hr_utility.set_location('CTFN rqd flag is Y', 10);
      hr_utility.set_location('l_actn_exists '||l_actn_exists,10);
    end if;
    -- Bug No 4241743
    l_prtt_enrt_actn_id := null;
      open c_enrt_actn
       (p_actn_typ_id           => l_actn_typ_id,
        p_prtt_enrt_rslt_id     => p_prtt_enrt_rslt_id,
        p_effective_date        => p_effective_date,
        p_business_group_id     => p_business_group_id
     );
  loop
  fetch c_enrt_actn into l_enrt_actn;
     exit when c_enrt_actn%notfound;
              l_prtt_enrt_actn_id := l_enrt_actn.prtt_enrt_actn_id;
              if l_epe.per_in_ler_id = l_enrt_actn.per_in_ler_id then
    	         hr_utility.set_location('Actn Id '||l_prtt_enrt_actn_id||'found in per_in_ler_id '||l_enrt_actn.per_in_ler_id,12);
	         l_actn_exists := 'Y';
                 exit;
              end if;
   end loop;
   close c_enrt_actn;
  hr_utility.set_location('After loop l_actn_exists '||l_actn_exists,12);
    --
    -- Loop through the certifications that might exist for the eltbl chc and
    -- write required certifications to the prtt_enrt_ctfn_prvdd table
    --
    -- Bug No 4241743 Added l_actn_exists check in if condition
    if (l_prtt_enrt_actn_id is null or l_actn_exists = 'N') then
      --
      for l_ecc in c_ecc1(l_epe.elig_per_elctbl_chc_id) loop
        --
        check_ctfn_prvdd
            (p_prtt_enrt_rslt_id  => p_prtt_enrt_rslt_id
            ,p_effective_date     => p_effective_date
            ,p_business_group_id  => p_business_group_id
            ,p_enrt_ctfn_typ_cd   => l_ecc.enrt_ctfn_typ_cd
            ,p_oipl_id            => l_epe.oipl_id
            ,p_rqd_flag           => l_ecc.rqd_flag
            ,p_pl_id              => l_epe.pl_id
            ,p_per_in_ler_id      => l_epe.per_in_ler_id
            ,p_bnft_amt           => l_epe.bnft_amt
            ,p_ctfn_determine_cd  => l_ecc.ctfn_determine_cd
            ,p_crntly_enrd_flag   => l_epe.crntly_enrd_flag
            ,p_ctfn_prvdd         => l_ctfn_prvdd);
        --
        -- Bug No 4241743 Added l_actn_exists check in if condition
        if ((l_prtt_enrt_actn_id is null or l_actn_exists = 'N') and not l_ctfn_prvdd)  then
          --
          hr_utility.set_location('write action ',12);
          write_new_action_item
            (p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
            ,p_rslt_object_version_number => p_rslt_object_version_number
            ,p_actn_typ_id                => l_actn_typ_id
            ,p_rqd_flag                   => l_ecc.SUSP_IF_CTFN_NOT_PRVD_FLAG --'Y'
            ,p_effective_date             => p_effective_date
            ,p_post_rslt_flag             => p_post_rslt_flag
            ,p_business_group_id          => p_business_group_id
            ,p_object_version_number      => l_object_version_number
            ,p_prtt_enrt_actn_id          => l_prtt_enrt_actn_id);
          --
          p_ctfn_actn_warning := true;
        end if;
        --
        if  not l_ctfn_prvdd then
          --
          write_new_prtt_ctfn_prvdd_item
            (p_rqd_flag                => l_ecc.rqd_flag
            ,p_enrt_ctfn_typ_cd        => l_ecc.enrt_ctfn_typ_cd
            ,p_enrt_r_bnft_ctfn_cd     => 'ENRT'
            ,p_prtt_enrt_rslt_id       => p_prtt_enrt_rslt_id
            ,p_prtt_enrt_actn_id       => l_prtt_enrt_actn_id
            ,p_effective_date          => p_effective_date
            ,p_business_group_id       => p_business_group_id
            ,p_object_version_number   => l_object_version_number
            ,p_prtt_enrt_ctfn_prvdd_id => l_prtt_enrt_ctfn_prvdd_id);
          --
         end if;
         --
      end loop;
      --
    end if;
    --
  end if;
  --
  -- If an enrt_bnft_id was passed we need to check if the enrollment benefit
  -- needs any certifications.
  --
  if p_enrt_bnft_id is not null then
    --
    open c_enrt_bnft;
    fetch c_enrt_bnft into l_enrt_bnft;
    --
    if c_enrt_bnft%notfound then
      close c_enrt_bnft;
      fnd_message.set_name('BEN', 'BEN_91580_BENACPRM_ENB_NF');
      fnd_message.set_token('PROC',l_proc);
      fnd_message.set_token('ENRT_BNFT_ID',to_char(p_enrt_bnft_id));
      fnd_message.set_token('BUSINESS_GROUP_ID',to_char(p_business_group_id));
      fnd_message.set_token('EFFECTIVE_DATE',p_effective_date);
      fnd_message.raise_error;
    else
      close c_enrt_bnft;
      if g_debug then
        hr_utility.set_location('c_enrt_bnft found', 10);
      end if;
    end if;
    --
    -- Check if there are any ENRTCTFN action items and certifications that
    -- already exist. There may be a need to delete them if the enrt bnft record
    -- was changed from a one that requires ctfn to a one that doesn't.
    --
    get_prtt_enrt_actn_id
      (p_actn_typ_id           => l_actn_typ_id
      ,p_prtt_enrt_rslt_id     => p_prtt_enrt_rslt_id
      ,p_effective_date        => p_effective_date
      ,p_business_group_id     => p_business_group_id
      ,p_prtt_enrt_actn_id     => l_prtt_enrt_actn_id
      ,p_cmpltd_dt             => l_cmpltd_dt
      ,p_object_version_number => l_object_version_number);
    --
    -- swjain - This code seems to be redundant as l_prtt_enrt_actn_id won't be not null
    -- in any case. Need to review this part of code.
    --
    if (l_prtt_enrt_actn_id is not null) then
    --
    -- Delete all certifications of type 'BNFT' for the action item
    --
        If p_datetrack_mode = hr_api.g_zap then
           l_datetrack_mode := hr_api.g_zap;
        Elsif p_datetrack_mode = hr_api.g_delete then
           l_datetrack_mode := hr_api.g_delete;
        Elsif p_datetrack_mode = hr_api.g_correction then
           l_datetrack_mode := hr_api.g_zap;
        Elsif p_datetrack_mode = hr_api.g_update then
           l_datetrack_mode := hr_api.g_delete;
        Else
           l_datetrack_mode := hr_api.g_delete;
        End if;
        --
        for l_enrt_ctfn in c_enrt_ctfn(l_prtt_enrt_actn_id) loop
        --
        if l_enrt_ctfn.enrt_ctfn_recd_dt = null then
          l_write_new_ctfn := TRUE;
          delete_prtt_ctfn_prvdd
            (p_prtt_enrt_ctfn_prvdd_id => l_enrt_ctfn.prtt_enrt_ctfn_prvdd_id
            ,p_object_version_number   => l_enrt_ctfn.object_version_number
            ,p_effective_date          => p_effective_date
            ,p_datetrack_mode          => l_datetrack_mode);
        else
             l_write_new_ctfn := FALSE;
        end if;
        --
       end loop;
    --
    end if;

    -- write the ctfn's only if the flag is 'Y' AND if the cvg amt was
    -- enterable, the entered amt was more than the mx_wout_ctfn_val.Bug 1249901
    hr_utility.set_location('Benefit amount '||l_epe.bnft_amt,11);
    --
    open c_ler_rstrn (p_effective_date, l_epe.per_in_ler_id, l_epe.pl_id);
     fetch c_ler_rstrn into l_cvg_incr_code;
    close c_ler_rstrn;
    --
    --if l_cvg_incr_code is null then
    open c_pl_rstrn (p_effective_date, l_epe.pl_id);
     fetch c_pl_rstrn into l_cvg_incr_code_pln, l_bnft_or_option_rstrctn_cd;
    close c_pl_rstrn;
    --end if;
    l_cvg_incr_code := NVL(l_cvg_incr_code, l_cvg_incr_code_pln);
    --
    if l_enrt_bnft.ctfn_rqd_flag = 'Y'
       and (l_epe.bnft_amt > nvl(l_enrt_bnft.mx_wout_ctfn_val, 0) or
            (l_bnft_or_option_rstrctn_cd = 'BNFT' and l_cvg_incr_code = 'DECRCTF')) then
    --
    -- swjain -- No need for other conditions. Also for 'DECRCTF' codes, no need to chk if
    -- bnft_amt > l_enrt_bnft.mx_wout_ctfn_val
    --
   /* and ((l_enrt_bnft.entr_val_at_enrt_flag = 'N' or
         l_enrt_bnft.entr_val_at_enrt_flag = 'Y'or l_enrt_bnft.cvg_mlt_cd in ('ERL')) */
      --
      -- Bug 3183266 : For flat range l_enrt_bnft.mx_wout_ctfn_val will be null
      --
      if g_debug then
        hr_utility.set_location('CTFN rqd flag is Y', 10);
      end if;
      --
      -- Loop through the certifications that might exist for the eltbl chc and
      -- write required certifications to the prtt_enrt_ctfn_prvdd table
      --
      for l_ecc in c_ecc2(p_enrt_bnft_id
                         ,l_epe.elig_per_elctbl_chc_id) loop
      --
      -- Bug 5887665 - Even for coverage ctfns, we need to see the suspended codes, and
      -- then create action items and ctfns accordingly
      --
	check_ctfn_prvdd
	      (p_prtt_enrt_rslt_id  => p_prtt_enrt_rslt_id
	      ,p_effective_date     => p_effective_date
	      ,p_business_group_id  => p_business_group_id
	      ,p_enrt_ctfn_typ_cd   => l_ecc.enrt_ctfn_typ_cd
	      ,p_oipl_id            => l_epe.oipl_id
	      ,p_rqd_flag           => l_ecc.rqd_flag
	      ,p_pl_id              => l_epe.pl_id
	      ,p_per_in_ler_id      => l_epe.per_in_ler_id
	      ,p_bnft_amt           => l_epe.bnft_amt
	      ,p_ctfn_determine_cd  => l_ecc.ctfn_determine_cd
	      ,p_crntly_enrd_flag   => l_epe.crntly_enrd_flag
	      ,p_enrt_r_bnft_ctfn_cd => 'BNFT'
	      ,p_ctfn_prvdd         => l_ctfn_prvdd);
        --
        if (l_prtt_enrt_actn_id is null and not l_ctfn_prvdd) then
          --
          write_new_action_item
            (p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
            ,p_rslt_object_version_number => p_rslt_object_version_number
            ,p_actn_typ_id                => l_actn_typ_id
            ,p_rqd_flag                   => l_ecc.SUSP_IF_CTFN_NOT_PRVD_FLAG --'Y'
            ,p_effective_date             => p_effective_date
            ,p_post_rslt_flag             => p_post_rslt_flag
            ,p_business_group_id          => p_business_group_id
            ,p_object_version_number      => l_object_version_number
            ,p_prtt_enrt_actn_id          => l_prtt_enrt_actn_id);
          --
          p_ctfn_actn_warning := true;
          --
        end if;
	--
        if (not l_ctfn_prvdd and (l_prtt_enrt_actn_id is null or
	                         (l_prtt_enrt_actn_id is not null and l_write_new_ctfn))) then
          --
          write_new_prtt_ctfn_prvdd_item
            (p_rqd_flag                => l_ecc.rqd_flag
            ,p_enrt_ctfn_typ_cd        => l_ecc.enrt_ctfn_typ_cd
            ,p_enrt_r_bnft_ctfn_cd     => 'BNFT'
            ,p_prtt_enrt_rslt_id       => p_prtt_enrt_rslt_id
            ,p_prtt_enrt_actn_id       => l_prtt_enrt_actn_id
            ,p_effective_date          => p_effective_date
            ,p_business_group_id       => p_business_group_id
            ,p_object_version_number   => l_object_version_number
            ,p_prtt_enrt_ctfn_prvdd_id => l_prtt_enrt_ctfn_prvdd_id);
          --
        end if;
        --
      end loop;
      --
    end if; -- ctfn_rqd_flag
    --
  end if; -- p_enrt_bnft_id
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  if g_debug then
    hr_utility.set_location ('Leaving ' ||l_proc,10);
  end if;
  --
exception
  --
  when hr_api.validate_enabled
  then
    rollback to determine_other_actn_items;
    if g_debug then
      hr_utility.set_location ('Leaving ' ||l_proc,10);
    end if;
  --
  when others then
    if g_debug then
      hr_utility.set_location('Exception Raised '||l_proc, 10);
    end if;
    raise;
--
end determine_other_actn_items;
--
-- ----------------------------------------------------------------------------
-- |--------------------< determine_pcp_dpnt_actn_items >------------------------|
-- ----------------------------------------------------------------------------
--
procedure determine_pcp_dpnt_actn_items
  (p_prtt_enrt_rslt_id          in     number
  ,p_effective_date             in     date
  ,p_business_group_id          in     number
  ,p_elig_cvrd_dpnt_id          in     number
  ,p_validate                   in     boolean  default FALSE
  ,p_datetrack_mode             in     varchar2 default hr_api.g_correction
  ,p_post_rslt_flag             in     varchar2 default 'Y'
  ,p_pcp_dpnt_dsgn_cd           in     varchar2
  ,p_rslt_object_version_number in out nocopy number
  ,p_suspend_flag               in out nocopy varchar2
  ,p_pcp_dpnt_actn_warning              out nocopy boolean) is
  --
 l_proc varchar2(80) ;
  l_actn_typ_id number(15);
  l_prtt_enrt_ctfn_prvdd_id number(15);
  l_cmpltd_dt date;
  l_datetrack_mode varchar2(30);
  l_pcp_dpnt_actn_warning boolean := FALSE;
  l_dummy  varchar2(30);
  l_prtt_enrt_actn_id number(15);
  l_object_version_number number;
  l_rqd_flag  varchar2(30);
  l_rqd_data_found  boolean := FALSE;

  l_rslt_object_version_number number(15);
  l_suspend_flag               varchar2(20);


  cursor c_prmry_care_actn is
  select 'x'
    from ben_prmry_care_prvdr_f  pf,
         ben_elig_cvrd_dpnt_f ecd
   where pf.elig_cvrd_dpnt_id = ecd.elig_cvrd_dpnt_id
   --  and ecd.prtt_enrt_rslt_id =  p_prtt_enrt_rslt_id  bug 1421978
     and ecd.elig_cvrd_dpnt_id = p_elig_cvrd_dpnt_id
     and pf.business_group_id = p_business_group_id
     and ecd.business_group_id = p_business_group_id
     and p_effective_date between ecd.effective_start_date
                              and ecd.effective_end_date
     and p_effective_date between pf.effective_start_date
                              and pf.effective_end_date;
--
begin
--
  if g_debug then
   l_proc  := g_package||'.determine_pcp_dpnt_actn_items';
    hr_utility.set_location ('Entering '||l_proc,10);
  end if;
  --
  l_rslt_object_version_number := p_rslt_object_version_number ;
  l_suspend_flag               := p_suspend_flag  ;

  -- Issue a savepoint if operating in validate only mode
  --
  savepoint determine_pcp_dpnt_actn_items;
 --
  if p_pcp_dpnt_dsgn_cd = 'R' then
      l_rqd_flag := 'Y';
  else
      l_rqd_flag := 'N';
  end if;
  --
    if g_debug then
      hr_utility.set_location('pcp dpnt dsgn rqd flag : ' || l_rqd_flag || ' ' ||
                            l_proc, 20);
    end if;
  --
  -- As the only modification happening in the code is for rqd_flag = 'Y',
  -- restrict the code execution only when it's on.
  --
  if l_rqd_flag = 'Y' then
    open c_prmry_care_actn;
    fetch c_prmry_care_actn into l_dummy;
    if c_prmry_care_actn%notfound then
       l_rqd_data_found := FALSE;
       if g_debug then
         hr_utility.set_location('c_prmry_care_actn notfound' , 90 );
       end if;
    elsif c_prmry_care_actn%found then
       l_rqd_data_found := TRUE;
       if g_debug then
         hr_utility.set_location('c_prmry_care_actn found' , 91 );
       end if;
    end if;
    close c_prmry_care_actn;
    --
    if g_debug then
      hr_utility.set_location('PCPDPNT action item ', 30);
    end if;
    --
    l_actn_typ_id := get_actn_typ_id
                       (p_type_cd           => 'PCPDPNT'
                       ,p_business_group_id => p_business_group_id);
    --
    if g_debug then
      hr_utility.set_location ('Entering get_prtt_enrt_actn_id ' , 101);
    end if;
    get_prtt_enrt_actn_id
       (p_actn_typ_id           => l_actn_typ_id,
        p_prtt_enrt_rslt_id     => p_prtt_enrt_rslt_id,
        p_elig_cvrd_dpnt_id     => p_elig_cvrd_dpnt_id,
        p_effective_date        => p_effective_date,
        p_business_group_id     => p_business_group_id,
        p_prtt_enrt_actn_id     => l_prtt_enrt_actn_id,
        p_cmpltd_dt             => l_cmpltd_dt,
        p_object_version_number => l_object_version_number);

    --
    if (l_prtt_enrt_actn_id IS NULL and
        l_rqd_data_found = FALSE) then
      l_pcp_dpnt_actn_warning := TRUE;
    elsif l_prtt_enrt_actn_id IS NOT NULL and
        l_rqd_data_found = TRUE and
        l_cmpltd_dt IS NULL then
      --
      if g_debug then
        hr_utility.set_location ('Case 1 ',102);
      end if;
      -- Existing open action item but we now have required data. Close the open
      -- action item by setting cmpltd_dt field
      --
      l_pcp_dpnt_actn_warning := FALSE;
    elsif l_prtt_enrt_actn_id IS NOT NULL and
        l_rqd_data_found = FALSE and
        l_cmpltd_dt IS NOT NULL then
      --
      -- Found a closed action item. But required data is missing. Reopen item
      --
      if g_debug then
        hr_utility.set_location ('Case2 ',103);
      end if;
      l_pcp_dpnt_actn_warning := TRUE;
    else
      if g_debug then
        hr_utility.set_location ('Case3 ',104);
      end if;
      l_pcp_dpnt_actn_warning := FALSE;
    end if;
    -- process the action item
    --
    process_action_item
          (p_prtt_enrt_actn_id          => l_prtt_enrt_actn_id
          ,p_actn_typ_id                => l_actn_typ_id
          ,p_cmpltd_dt                  => l_cmpltd_dt
          ,p_object_version_number      => l_object_version_number
          ,p_effective_date             => p_effective_date
          ,p_rqd_data_found             => l_rqd_data_found
          ,p_rqd_flag                   => l_rqd_flag
          ,p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
          ,p_elig_cvrd_dpnt_id          => p_elig_cvrd_dpnt_id   --bug 1421978
          ,p_post_rslt_flag             => p_post_rslt_flag
          ,p_business_group_id          => p_business_group_id
          ,p_datetrack_mode             => p_datetrack_mode
          ,p_rslt_object_version_number => p_rslt_object_version_number);
    --
  end if; -- rqd_flag = 'Y'
  --
  p_pcp_dpnt_actn_warning := l_pcp_dpnt_actn_warning;
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  if g_debug then
    hr_utility.set_location ('Leaving '||l_proc, 10);
  end if;
  --

exception
  --
  when hr_api.validate_enabled
  then
    rollback to determine_pcp_dpnt_actn_items;
    --
    if g_debug then
      hr_utility.set_location(' Leaving:'||l_proc, 10);
    end if;
  --
  when others then
    if g_debug then
      hr_utility.set_location('Exception Raised '||l_proc, 10);
    end if;
    p_rslt_object_version_number := l_rslt_object_version_number;
    p_suspend_flag               := l_suspend_flag  ;
    p_pcp_dpnt_actn_warning      := null ;

    raise;
--
end determine_pcp_dpnt_actn_items;
--
-- ----------------------------------------------------------------------------
-- |--------------------< determine_pcp_actn_items >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure determine_pcp_actn_items
  (p_prtt_enrt_rslt_id          in     number
  ,p_effective_date             in     date
  ,p_business_group_id          in     number
  ,p_validate                   in     boolean  default FALSE
  ,p_datetrack_mode             in     varchar2 default hr_api.g_correction
  ,p_post_rslt_flag             in     varchar2 default 'Y'
  ,p_pcp_dsgn_cd                in     varchar2
  ,p_rslt_object_version_number in out nocopy number
  ,p_suspend_flag               in out nocopy varchar2
  ,p_pcp_actn_warning              out nocopy boolean) is
  --
  l_proc varchar2(80) ;
  l_actn_typ_id number(15);
  l_prtt_enrt_ctfn_prvdd_id number(15);
  l_cmpltd_dt date;
  l_datetrack_mode varchar2(30);
  l_pcp_actn_warning boolean := FALSE;
  l_dummy  varchar2(30);
  l_prtt_enrt_actn_id number(15);
  l_object_version_number number;
  l_rqd_flag  varchar2(30);
  l_rqd_data_found  boolean := FALSE;

  l_rslt_object_version_number   number(15);
  l_suspend_flag                 varchar2(20);

  cursor c_prmry_care_actn is
  select 'x'
    from ben_prmry_care_prvdr_f  pf
   where pf.prtt_enrt_rslt_id =  p_prtt_enrt_rslt_id
     and pf.business_group_id = p_business_group_id
     and p_effective_date between pf.effective_start_date
                              and pf.effective_end_date;
--
begin
--
  if g_debug then
    l_proc  := g_package||'.determine_pcp_actn_items';
    hr_utility.set_location ('Entering '||l_proc,10);
  end if;
  --

  l_rslt_object_version_number  := p_rslt_object_version_number  ;
  l_suspend_flag                := p_suspend_flag ;

  -- Issue a savepoint if operating in validate only mode
  --
  savepoint determine_pcp_actn_items;
  --
  if p_pcp_dsgn_cd = 'R' then
      l_rqd_flag := 'Y';
  else
      l_rqd_flag := 'N';
  end if;
  --
    if g_debug then
      hr_utility.set_location('pcp dsgn rqd flag : ' || l_rqd_flag || ' ' ||
                            l_proc, 20);
    end if;
  --
  -- As the only modification happening in the code is for rqd_flag = 'Y',
  -- restrict the code execution only when it's on.
  --
  if l_rqd_flag = 'Y' then
    open c_prmry_care_actn;
    fetch c_prmry_care_actn into l_dummy;
    if c_prmry_care_actn%notfound then
       l_rqd_data_found := FALSE;
    elsif c_prmry_care_actn%found then
       l_rqd_data_found := TRUE;
    end if;
    close c_prmry_care_actn;
    --
    if g_debug then
      hr_utility.set_location('PCPPRTT action item ', 30);
    end if;
    --
    l_actn_typ_id := get_actn_typ_id
                       (p_type_cd           => 'PCPPRTT'
                       ,p_business_group_id => p_business_group_id);
    --
    get_prtt_enrt_actn_id
       (p_actn_typ_id           => l_actn_typ_id,
        p_prtt_enrt_rslt_id     => p_prtt_enrt_rslt_id,
        p_effective_date        => p_effective_date,
        p_business_group_id     => p_business_group_id,
        p_prtt_enrt_actn_id     => l_prtt_enrt_actn_id,
        p_cmpltd_dt             => l_cmpltd_dt,
        p_object_version_number => l_object_version_number);

    --
    if (l_prtt_enrt_actn_id IS NULL and
        l_rqd_data_found = FALSE) then
      l_pcp_actn_warning := TRUE;
      if g_debug then
        hr_utility.set_location ('Leaving '||'TRUE', 11);
      end if;
    elsif l_prtt_enrt_actn_id IS NOT NULL and
        l_rqd_data_found = TRUE and
        l_cmpltd_dt IS NULL then
      --
      -- Existing open action item but we now have required data. Close the open
      -- action item by setting cmpltd_dt field
      --
      if g_debug then
        hr_utility.set_location ('Leaving '||'FALSE', 12);
      end if;
      l_pcp_actn_warning := FALSE;
    elsif l_prtt_enrt_actn_id IS NOT NULL and
        l_rqd_data_found = FALSE and
        l_cmpltd_dt IS NOT NULL then
      --
      -- Found a closed action item. But required data is missing. Reopen item
      --
      if g_debug then
        hr_utility.set_location ('Leaving '||'TRUE', 13);
      end if;
      l_pcp_actn_warning := TRUE;
    else
      if g_debug then
        hr_utility.set_location ('Leaving '||'FALSE', 14);
      end if;
      l_pcp_actn_warning := FALSE;
    end if;
    -- process the action item
    --
    process_action_item
          (p_prtt_enrt_actn_id          => l_prtt_enrt_actn_id
          ,p_actn_typ_id                => l_actn_typ_id
          ,p_cmpltd_dt                  => l_cmpltd_dt
          ,p_object_version_number      => l_object_version_number
          ,p_effective_date             => p_effective_date
          ,p_rqd_data_found             => l_rqd_data_found
          ,p_rqd_flag                   => l_rqd_flag
          ,p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
          ,p_post_rslt_flag             => p_post_rslt_flag
          ,p_business_group_id          => p_business_group_id
          ,p_datetrack_mode             => p_datetrack_mode
          ,p_rslt_object_version_number => p_rslt_object_version_number);
    --
  end if; -- rqd_flag = 'Y'
  --
  p_pcp_actn_warning := l_pcp_actn_warning;
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  if g_debug then
    hr_utility.set_location ('Leaving '||l_proc, 10);
  end if;
  --

exception
  --
  when hr_api.validate_enabled
  then
    rollback to determine_pcp_actn_items;
    --
    if g_debug then
      hr_utility.set_location(' Leaving:'||l_proc, 10);
    end if;
  --
  when others then
    if g_debug then
      hr_utility.set_location('Exception Raised '||l_proc, 10);
    end if;

    p_rslt_object_version_number := l_rslt_object_version_number;
    p_suspend_flag               := l_suspend_flag ;
    p_pcp_actn_warning           := null ;

    raise;
--
end determine_pcp_actn_items;


-- ----------------------------------------------------------------------------
-- |--------------------< process_pcp_dpnt_actn_items >------------------------|
-- ----------------------------------------------------------------------------
--
procedure process_pcp_dpnt_actn_items
  (p_validate                   in     boolean  default FALSE
  ,p_prtt_enrt_rslt_id          in     number
  ,p_effective_date             in     date
  ,p_business_group_id          in     number
  ,p_datetrack_mode             in     varchar2 default hr_api.g_correction
  ,p_post_rslt_flag             in     varchar2 default 'Y'
  ,p_rslt_object_version_number in out nocopy number
  ,p_suspend_flag               in out nocopy varchar2
  ,p_pcp_dpnt_actn_warning             out nocopy boolean) is
  --
  l_proc         varchar2(80);

  l_rslt_object_version_number  number(15);
  l_suspend_flag                varchar2(20);


  --
  --this procedure determines whether the result correspoding to dependent
  -- designation has pcp_dpnt_dsgn_cd turned on.if it's on we need to create
  -- an action item and suspend the result during dependent designation.
  --
  l_pcp_dpnt_dsgn_cd   varchar2(30) := null;
  l_elig_cvrd_dpnt_id  ben_elig_cvrd_dpnt_f.elig_cvrd_dpnt_id%TYPE;
  l_pcp_dpnt_actn_warning boolean := FALSE;

  cursor c_pcp_dpnt_cd_oipl is
  select cop.pcp_dpnt_dsgn_cd,
         ecd.elig_cvrd_dpnt_id
    from ben_prtt_enrt_rslt_f  pen,
         ben_elig_cvrd_dpnt_f ecd,
         ben_oipl_f cop
   where cop.oipl_id  = pen.oipl_id
     and pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and pen.prtt_enrt_rslt_id = ecd.prtt_enrt_rslt_id
     and ecd.cvg_strt_dt is not null
     and nvl(ecd.cvg_thru_dt,hr_api.g_eot) = hr_api.g_eot
     and pen.business_group_id = p_business_group_id
     and cop.business_group_id = p_business_group_id
     and ecd.business_group_id = p_business_group_id
     and p_effective_date between ecd.effective_start_date
                              and ecd.effective_end_date
     and p_effective_date between cop.effective_start_date
                              and cop.effective_end_date
     and p_effective_date between pen.effective_start_date
                              and pen.effective_end_date
     and cop.pcp_dpnt_dsgn_cd is not null ;
  -- added the cop.pcp_dpnt_dsgn_cd is not null condition bug 1421978
  --
  cursor c_pcp_dpnt_cd is
  select pcp.pcp_dpnt_dsgn_cd ,
         ecd.elig_cvrd_dpnt_id
    from ben_prtt_enrt_rslt_f  pen,
         ben_elig_cvrd_dpnt_f ecd,
         ben_pl_pcp  pcp
   where pcp.pl_id  = pen.pl_id
     and pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and pen.prtt_enrt_rslt_id = ecd.prtt_enrt_rslt_id
     and ecd.cvg_strt_dt is not null
     and nvl(ecd.cvg_thru_dt,hr_api.g_eot) = hr_api.g_eot
     and pen.business_group_id = p_business_group_id
     and pcp.business_group_id = p_business_group_id
     and p_effective_date between ecd.effective_start_date
                              and ecd.effective_end_date
     and p_effective_date between pen.effective_start_date
                              and pen.effective_end_date;
--
begin
--
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_proc         := g_package||'.process_pcp_dpnt_actn_items';
    hr_utility.set_location ('Entering '||l_proc,10);
  end if;
  if g_debug then
    hr_utility.set_location ('Entering rslt id '||to_char(p_prtt_enrt_rslt_id),11);
  end if;
  --
  --

  l_rslt_object_version_number := p_rslt_object_version_number ;
  l_suspend_flag               := p_suspend_flag  ;



  -- Issue a savepoint if operating in validate only mode
  --
  savepoint process_pcp_dpnt_actn_items;
   --

  open c_pcp_dpnt_cd_oipl;
  fetch c_pcp_dpnt_cd_oipl into l_pcp_dpnt_dsgn_cd,l_elig_cvrd_dpnt_id;
  if c_pcp_dpnt_cd_oipl%notfound then
     close c_pcp_dpnt_cd_oipl;
     open c_pcp_dpnt_cd;
     fetch c_pcp_dpnt_cd into l_pcp_dpnt_dsgn_cd,l_elig_cvrd_dpnt_id;
     if c_pcp_dpnt_cd%notfound then
        close c_pcp_dpnt_cd;
        if g_debug then
          hr_utility.set_location('pcp not required ' , 298);
        end if;
        return;
     else
        loop
          if g_debug then
            hr_utility.set_location('l_pcp_dpnt_dsgn_cd '||l_pcp_dpnt_dsgn_cd , 299);
          end if;
          if g_debug then
            hr_utility.set_location('l_elig_cvrd_dpnt_id '||l_elig_cvrd_dpnt_id, 299);
          end if;
          determine_pcp_dpnt_actn_items
              (p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
              ,p_elig_cvrd_dpnt_id          => l_elig_cvrd_dpnt_id
              ,p_effective_date             => p_effective_date
              ,p_business_group_id          => p_business_group_id
              ,p_datetrack_mode             => p_datetrack_mode
              ,p_post_rslt_flag             => p_post_rslt_flag
              ,p_pcp_dpnt_dsgn_cd           => l_pcp_dpnt_dsgn_cd
              ,p_rslt_object_version_number => p_rslt_object_version_number
              ,p_suspend_flag               => p_suspend_flag
              ,p_pcp_dpnt_actn_warning      => l_pcp_dpnt_actn_warning);
          --
          fetch c_pcp_dpnt_cd into l_pcp_dpnt_dsgn_cd,l_elig_cvrd_dpnt_id;
          exit when c_pcp_dpnt_cd%notfound ;
        end loop ;
        --
        close c_pcp_dpnt_cd;
        --
     end if;
   else
     if g_debug then
       hr_utility.set_location('l_pcp_dpnt_dsgn_cd '||l_pcp_dpnt_dsgn_cd , 399);
     end if;
     loop
       --
       determine_pcp_dpnt_actn_items
              (p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
              ,p_elig_cvrd_dpnt_id          => l_elig_cvrd_dpnt_id
              ,p_effective_date             => p_effective_date
              ,p_business_group_id          => p_business_group_id
              ,p_datetrack_mode             => p_datetrack_mode
              ,p_post_rslt_flag             => p_post_rslt_flag
              ,p_pcp_dpnt_dsgn_cd           => l_pcp_dpnt_dsgn_cd
              ,p_rslt_object_version_number => p_rslt_object_version_number
              ,p_suspend_flag               => p_suspend_flag
              ,p_pcp_dpnt_actn_warning           => l_pcp_dpnt_actn_warning);
       --
       fetch c_pcp_dpnt_cd_oipl into l_pcp_dpnt_dsgn_cd,l_elig_cvrd_dpnt_id;
       exit when c_pcp_dpnt_cd_oipl%notfound ;
     end loop;
     --
     close c_pcp_dpnt_cd_oipl;
     --
   end if;
  --
  p_pcp_dpnt_actn_warning := l_pcp_dpnt_actn_warning;
  --
 if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  if g_debug then
    hr_utility.set_location ('Leaving '||l_proc, 10);
  end if;
  --
exception
  --
  when hr_api.validate_enabled
  then
    rollback to process_pcp_dpnt_actn_items;
    --
    if g_debug then
      hr_utility.set_location(' Leaving:'||l_proc, 10);
    end if;
  --
  when others then
    if g_debug then
      hr_utility.set_location('Exception Raised '||l_proc, 10);
    end if;

    p_rslt_object_version_number := l_rslt_object_version_number ;
    p_suspend_flag               := l_suspend_flag   ;
    p_pcp_dpnt_actn_warning      := null ;

    raise;
--
end process_pcp_dpnt_actn_items;
--
-- ----------------------------------------------------------------------------
-- |--------------------< process_pcp_actn_items >------------------------|
-- ----------------------------------------------------------------------------
--
procedure process_pcp_actn_items
  (p_validate                   in     boolean  default FALSE
  ,p_prtt_enrt_rslt_id          in     number
  ,p_effective_date             in     date
  ,p_business_group_id          in     number
  ,p_datetrack_mode             in     varchar2 default hr_api.g_correction
  ,p_post_rslt_flag             in     varchar2 default 'Y'
  ,p_rslt_object_version_number in out nocopy number
  ,p_suspend_flag               in out nocopy varchar2
  ,p_pcp_actn_warning             out nocopy boolean) is
  --
  l_proc         varchar2(80);

  l_rslt_object_version_number  number(15);
  l_suspend_flag                varchar2(20);

  --
  -- this procedure determines if the plan in the result has pcp_dsgn_cd on
  -- if it's on we need to write an action item and suspend the result
  l_pcp_dsgn_cd   varchar2(30) := null;
  l_pcp_actn_warning boolean := FALSE;

  cursor c_pcp_cd_oipl is
  select cop.pcp_dsgn_cd
    from ben_prtt_enrt_rslt_f  perf,
         ben_oipl_f cop
   where cop.oipl_id  = perf.oipl_id
     and perf.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and perf.business_group_id = p_business_group_id
     and cop.business_group_id = p_business_group_id
     and p_effective_date between cop.effective_start_date
                              and cop.effective_end_date
     and p_effective_date between perf.effective_start_date
                              and perf.effective_end_date
     and cop.pcp_dsgn_cd is not null ;
  -- added the cop.pcp_dsgn_cd is not null condition bug 1421978
  cursor c_pcp_cd is
  select pcp.pcp_dsgn_cd
    from ben_prtt_enrt_rslt_f  perf,
         ben_pl_pcp  pcp
   where pcp.pl_id  = perf.pl_id
     and perf.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and perf.business_group_id = p_business_group_id
     and pcp.business_group_id = p_business_group_id
     and p_effective_date between perf.effective_start_date
                              and perf.effective_end_date;
--
begin
--
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_proc         := g_package||'.process_pcp_actn_items';
    hr_utility.set_location ('Entering '||l_proc,10);
  end if;
  --
  l_rslt_object_version_number := p_rslt_object_version_number ;
  l_suspend_flag               := p_suspend_flag ;

  -- Issue a savepoint if operating in validate only mode
  --
  savepoint process_pcp_actn_items;
  --
  open c_pcp_cd_oipl;
  fetch c_pcp_cd_oipl into l_pcp_dsgn_cd;
  if c_pcp_cd_oipl%notfound then
     close c_pcp_cd_oipl;
     open c_pcp_cd;
     fetch c_pcp_cd into l_pcp_dsgn_cd;
     if c_pcp_cd%notfound then
       close c_pcp_cd;
       return;
     else
       close c_pcp_cd;
       if g_debug then
         hr_utility.set_location('l_pcp_dsgn_cd '||l_pcp_dsgn_cd , 198);
       end if;
       if g_debug then
         hr_utility.set_location('p_prtt_enrt_rslt_id '||p_prtt_enrt_rslt_id ,198);
       end if;

       determine_pcp_actn_items
              (p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
              ,p_effective_date             => p_effective_date
              ,p_business_group_id          => p_business_group_id
              ,p_datetrack_mode             => p_datetrack_mode
              ,p_post_rslt_flag             => p_post_rslt_flag
              ,p_pcp_dsgn_cd                => l_pcp_dsgn_cd
              ,p_rslt_object_version_number => p_rslt_object_version_number
              ,p_suspend_flag               => p_suspend_flag
              ,p_pcp_actn_warning           => l_pcp_actn_warning);
      end if;
   else
      close c_pcp_cd_oipl;
       if g_debug then
         hr_utility.set_location('l_pcp_dsgn_cd '||l_pcp_dsgn_cd , 199);
       end if;
       if g_debug then
         hr_utility.set_location('p_prtt_enrt_rslt_id '||p_prtt_enrt_rslt_id ,199);
       end if;

       determine_pcp_actn_items
              (p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
              ,p_effective_date             => p_effective_date
              ,p_business_group_id          => p_business_group_id
              ,p_datetrack_mode             => p_datetrack_mode
              ,p_post_rslt_flag             => p_post_rslt_flag
              ,p_pcp_dsgn_cd                => l_pcp_dsgn_cd
              ,p_rslt_object_version_number => p_rslt_object_version_number
              ,p_suspend_flag               => p_suspend_flag
              ,p_pcp_actn_warning           => l_pcp_actn_warning);
   end if;
 --
  p_pcp_actn_warning := l_pcp_actn_warning;
  --
 if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  if g_debug then
    hr_utility.set_location ('Leaving '||l_proc, 10);
  end if;
  --
exception
  --
  when hr_api.validate_enabled
  then
    rollback to process_pcp_actn_items;
    --
    if g_debug then
      hr_utility.set_location(' Leaving:'||l_proc, 10);
    end if;
  --
  when others then
    if g_debug then
      hr_utility.set_location('Exception Raised '||l_proc, 10);
    end if;

    p_rslt_object_version_number := l_rslt_object_version_number ;
    p_suspend_flag               := l_suspend_flag ;
    p_pcp_actn_warning           := null;

    raise;
--
end process_pcp_actn_items;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< check_bnf_ttee >-----------------------------|
-- ----------------------------------------------------------------------------
--
function check_bnf_ttee
  (p_pl_bnf_id         in number
  ,p_effective_date    in date
  ,p_business_group_id in number)
return boolean is
  --
  -- This routine will check if designated brneficiary is over the age 18 and
  -- will return FALSE if under 18 and TRUE if over 18
  --
  l_proc     varchar2(80) ;
  --
  cursor c_bnf_age is
  select round
          (trunc
            (months_between(p_effective_date, per.date_of_birth))/ 12
             ) bnf_age,
         pb.ttee_person_id
    from per_all_people_f per,
         ben_pl_bnf_f pb
   where pb.pl_bnf_id = p_pl_bnf_id
     and per.person_id = pb.bnf_person_id
     and per.business_group_id = p_business_group_id
     and p_effective_date between per.effective_start_date
                              and per.effective_end_date;
  --
  l_bnf_age c_bnf_age%rowtype;
  --
--
begin
--
  if g_debug then
    l_proc      := g_package||'.check_bnf_ttee';
    hr_utility.set_location ('Entering '||l_proc,10);
  end if;
  --
  open c_bnf_age;
  fetch c_bnf_age into l_bnf_age;
  close c_bnf_age;
  --
  if g_debug then
    hr_utility.set_location ('Leaving ' ||l_proc,10);
  end if;
  --
  if (l_bnf_age.bnf_age IS NOT NULL and
      l_bnf_age.bnf_age >= 18)
     OR
     (l_bnf_age.bnf_age is not null and
      l_bnf_age.bnf_age < 18 and
      l_bnf_age.ttee_person_id is not null) then
    return TRUE;
  elsif l_bnf_age.bnf_age is not null and
        l_bnf_age.bnf_age < 18 and
        l_bnf_age.ttee_person_id is null then
    return FALSE;
  end if;
  --
exception
   when others then
     if g_debug then
       hr_utility.set_location('Exception Raised '||l_proc, 10);
     end if;
     raise;
--
end check_bnf_ttee;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< check_bnf_ctfn >------------------------------|
-- ----------------------------------------------------------------------------
--
function check_bnf_ctfn
  (p_prtt_enrt_actn_id in number
  ,p_pl_bnf_id         in number
  ,p_effective_date    in date)
return boolean is
  --
  -- This function checks for certifications for an enrollment result.
  -- Check if certifications were provided. For this beneficiary check
  -- if the bnf_ctfn_rqd_flag is 'Y' then write action item
  -- if the bnf_ctfn_recd_dt IS NULL.  The bnf_ctfn_recd_dt is filled in via
  -- a form interface.
  --
  l_required  number;
  l_optional  number;
  l_open_required number;
  l_open_optional number;
  l_return  boolean;
  --
  l_proc     varchar2(80) ;
--
begin
--
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_proc      := g_package||'.check_bnf_ctfn';
    hr_utility.set_location ('Entering '||l_proc,10);
  end if;
  --
  get_ctfn_count
    (p_prtt_enrt_actn_id   => p_prtt_enrt_actn_id
    ,p_pl_bnf_id           => p_pl_bnf_id
    ,p_effective_date      => p_effective_date
    ,p_required_count      => l_required
    ,p_optional_count      => l_optional
    ,p_open_required_count => l_open_required
    ,p_open_optional_count => l_open_optional);
  --
  l_return := check_ctfn(p_required_count      => l_required
                        ,p_optional_count      => l_optional
                        ,p_open_required_count => l_open_required
                        ,p_open_optional_count => l_open_optional);
  --
  if g_debug then
    hr_utility.set_location ('Leaving '||l_proc,10);
  end if;
  --
  return l_return;
  --
exception
  --
  when others then
    if g_debug then
      hr_utility.set_location('Exception Raised '||l_proc, 10);
    end if;
    raise;
--
end check_bnf_ctfn;
--
-- ----------------------------------------------------------------------------
-- |-------------------< check_bnf_actn_item_dfnd >----------------------------|
-- ----------------------------------------------------------------------------
--
function check_bnf_actn_item_dfnd
  (p_pl_id          number
  ,p_actn_type_cd       varchar2
  ,p_business_group_id      number
  ,p_effective_date     date)
return boolean is
  --
  -- Bug 1169240 - checking the popl_actn_typ table to see if action item defined
  -- This check is being done because the flags in ben_pl_f table are not getting
  -- updated when enrollment action items are attached to a plan . This was noticed
  -- for beneficiary related action types.
  --
  cursor c_bnf_actn_item is
    select null
      from ben_popl_actn_typ_f pat,
           ben_actn_typ eat
     where pat.pl_id = p_pl_id
       and pat.actn_typ_id = eat.actn_typ_id
       and eat.type_cd = p_actn_type_cd
       and pat.business_group_id = p_business_group_id
       and p_effective_date between
        pat.effective_start_date and pat.effective_end_date ;
  --
  l_dummy   char ;
  l_exists  boolean ;
  --
  l_proc     varchar2(80) ;
  --
begin
  --
  if g_debug then
    l_proc      := g_package||'.check_bnf_actn_item_dfnd' ;
    hr_utility.set_location ('Entering '||l_proc,10);
  end if;
  --
  open c_bnf_actn_item ;
  fetch c_bnf_actn_item into l_dummy;
  --
  if c_bnf_actn_item%FOUND then
    --
    l_exists := TRUE;
    --
  else
    --
    l_exists := FALSE;
    --
  end if;
  --
  close c_bnf_actn_item;
  --
  if g_debug then
    hr_utility.set_location ('Leaving '||l_proc,10);
  end if;
  --
  return l_exists;
  --
end check_bnf_actn_item_dfnd ;
--
-- ----------------------------------------------------------------------------
-- |----------------------< write_new_bnf_ctfn_item >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure write_new_bnf_ctfn_item
  (p_pl_bnf_id             in     number
  ,p_prtt_enrt_actn_id     in     number
  ,p_bnf_ctfn_typ_cd       in     varchar2
  ,p_bnf_ctfn_rqd_flag     in     varchar2
  ,p_effective_date        in     date
  ,p_business_group_id     in     number
  ,p_object_version_number    out nocopy number
  ,p_pl_bnf_ctfn_prvdd_id     out nocopy number) is
  --
  -- this procedure writes a beneficiary certification to
  -- ben_pl_bnf_ctfn_prvdd_f
  --
  l_proc  varchar2(80);
  l_effective_start_date date;
  l_effective_end_date   date;
--
begin
--
  if g_debug then
    l_proc  := g_package||'.write_new_bnf_ctfn_item';
    hr_utility.set_location ('Entering '||l_proc,10);
  end if;
  --
  -- write a new record for each beneficiary certification item
  --
  ben_pl_bnf_ctfn_prvdd_api.create_pl_bnf_ctfn_prvdd
    (p_pl_bnf_id             => p_pl_bnf_id
    ,p_prtt_enrt_actn_id     => p_prtt_enrt_actn_id
    ,p_bnf_ctfn_typ_cd       => p_bnf_ctfn_typ_cd
    ,p_bnf_ctfn_rqd_flag     => p_bnf_ctfn_rqd_flag
    ,p_effective_date        => p_effective_date
    ,p_business_group_id     => p_business_group_id
    ,p_object_version_number => p_object_version_number
    ,p_effective_start_date  => l_effective_start_date
    ,p_effective_end_date    => l_effective_end_date
    ,p_pl_bnf_ctfn_prvdd_id  => p_pl_bnf_ctfn_prvdd_id);
  --
  if g_debug then
    hr_utility.set_location ('Leaving '||l_proc, 10);
  end if;
  --
exception
  /* we could have duplicates already here from prior run */
  when others then
    if g_debug then
      hr_utility.set_location('Exception Raised '||l_proc, 10);
    end if;

    p_object_version_number := null ;
    p_pl_bnf_ctfn_prvdd_id   := null;

    raise;
--
end write_new_bnf_ctfn_item;
--
-- ----------------------------------------------------------------------------
-- |-------------------< determine_bnf_miss_actn_items >----------------------|
-- ----------------------------------------------------------------------------
--
procedure determine_bnf_miss_actn_items
  (p_prtt_enrt_rslt_id          in     number
  ,p_effective_date             in     date
  ,p_business_group_id          in     number
  ,p_datetrack_mode             in     varchar2 default hr_api.g_correction
  ,p_post_rslt_flag             in     varchar2 default 'Y'
  ,p_rslt_object_version_number in out nocopy number
  ,p_bnf_actn_warning              out nocopy boolean) is
--
  -- This procedure determines if a designated beneficiary has missing info like
  -- DOB, SSN, ADRS, CTFN, TTEE that is required to complete an enrollment and
  -- writes action items if required data is missing.
  --
  l_proc     varchar2(80) ;
  --
  l_bnf_dsgn_cd varchar2(30);
  l_rqd_data_found boolean;
  l_prtt_enrt_ctfn_prvdd_id number;
  l_outputs   ff_exec.outputs_t;
  l_bnf_actn_warning boolean := FALSE;
  l_actn_typ_id number(15);
  l_prtt_enrt_actn_id number(15);
  l_cmpltd_dt date;
  l_object_version_number number(15);
  l_pl_bnf_ctfn_prvdd_id number;
  l_dob_found boolean;
  l_dummy varchar2(30);
  l_ctfn_defined boolean := FALSE;
  l_person_id  number;
  l_rslt_object_version_number number(15) ;

  --
  --
  -- Cursor to retrieve certifications defined for a plan and for the bnf
  -- person's contact_type.
  --
  cursor c_ctfns(v_bnf_person_id number, v_pl_id number, v_person_id number) is
  select pl.lack_ctfn_sspnd_enrt_flag ctflag,
         pl.bnf_ctfn_typ_cd ctcvgcd,
         pl.ctfn_rqd_when_rl ctrrl,
         pl.rqd_flag rqd_flag,
         pl.rlshp_typ_cd ctrlshcd,
         pl.bnf_typ_cd, pl.pl_id
    from ben_pl_bnf_ctfn_f pl
   where pl.bnf_ctfn_typ_cd <> 'NSC'
     and pl.pl_id = v_pl_id
     and (pl.rlshp_typ_cd is null or
         pl.rlshp_typ_cd in (select contact_type
                              from per_contact_relationships
                           where contact_person_id = v_bnf_person_id
                             and person_id = v_person_id
                             and business_group_id = p_business_group_id
                             and p_effective_date
                                   between nvl(date_start, p_effective_date)
                                       and nvl(date_end, hr_api.g_eot)))
     and pl.business_group_id = p_business_group_id
     and p_effective_date between
         pl.effective_start_date and pl.effective_end_date;
  --
  cursor c_ctfns_exist(v_pl_bnf_id number) is
  select 's'
    from ben_pl_bnf_ctfn_prvdd_f
   where pl_bnf_id = v_pl_bnf_id
     and p_effective_date between effective_start_date
                              and effective_end_date
     and business_group_id = p_business_group_id;
  --
  cursor c_dsgn_bnf is
  select pbd.pl_bnf_id,
         pbd.bnf_person_id
    from ben_pl_bnf_f pbd,
         ben_per_in_ler pil
   where pbd.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and pbd.dsgn_strt_dt is not null
     and nvl(pbd.dsgn_thru_dt, hr_api.g_eot) = hr_api.g_eot
     and pbd.business_group_id = p_business_group_id
     and p_effective_date between pbd.effective_start_date
                              and pbd.effective_end_date
     and pil.per_in_ler_id=pbd.per_in_ler_id
     and pil.business_group_id=p_business_group_id
     and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
     -- Check fo DOB, SSN, ADDRESS only for person beneficiaries
     -- and not for Organization Beneficiaries
     and pbd.bnf_person_id is not null;                          -- Bug : 3854556
  --
  cursor c_ctfn_defined(v_bnf_person_id number,
                        v_person_id number,
                        p_pl_id    number) is
  select 's'
    from ben_pl_bnf_ctfn_f
   where bnf_ctfn_typ_cd <> 'NSC'
     and pl_id = p_pl_id
     and (bnf_typ_cd is null or bnf_typ_cd = 'P')
     and (rlshp_typ_cd is null
          or
          rlshp_typ_cd in (select contact_type
                            from per_contact_relationships
                           where contact_person_id = v_bnf_person_id
                             and person_id = v_person_id
                             and business_group_id = p_business_group_id
                             and p_effective_date
                                   between nvl(date_start, p_effective_date)
                                       and nvl(date_end, hr_api.g_eot)))
     and business_group_id = p_business_group_id
     and p_effective_date between effective_start_date
                              and effective_end_date;
  cursor c_person_id is
   select person_id,
          pl_id
     from ben_prtt_enrt_rslt_f
     where prtt_enrt_rslt_id = p_prtt_enrt_rslt_id;
  --
  l_bnf_actn_typ_dfnd   boolean;  -- bug 1169240
  l_rqd_flag  varchar2(1);
  l_pl_id     number;
--
-- start bug 5667528
  cursor c_pen_info is
	SELECT pen.pgm_id, pen.pl_id, pen.pl_typ_id, pen.oipl_id, pen.ler_id,
	       pen.person_id, pen.business_group_id
	  FROM ben_prtt_enrt_rslt_f pen
	 WHERE pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
	   AND p_effective_date BETWEEN pen.effective_start_date
				    AND pen.effective_end_date;
   --
   pen_info_rec c_pen_info%ROWTYPE;
   --
   cursor c_asg(v_person_id in number) is
	SELECT asg.assignment_id, asg.organization_id
	  FROM per_all_assignments_f asg
	 WHERE asg.person_id = v_person_id
	   AND asg.assignment_type <> 'C'
	   AND asg.primary_flag = 'Y'
	   AND p_effective_date BETWEEN asg.effective_start_date
				    AND asg.effective_end_date;
   asg_rec c_asg%ROWTYPE;
   --
   cursor c_opt (v_oipl_id in number) is
	SELECT opt_id
	  FROM ben_oipl_f oipl
	 WHERE oipl.oipl_id = v_oipl_id
	   AND oipl.business_group_id = p_business_group_id
	   AND p_effective_date BETWEEN oipl.effective_start_date
				    AND oipl.effective_end_date;
   opt_rec c_opt%ROWTYPE;
   --
   CURSOR c_curr_ovn_of_actn (c_prtt_enrt_actn_id NUMBER)
      IS
         SELECT object_version_number
           FROM ben_prtt_enrt_actn_f
          WHERE prtt_enrt_actn_id = c_prtt_enrt_actn_id
            AND business_group_id = p_business_group_id
            AND p_effective_date BETWEEN effective_start_date
                                     AND effective_end_date;

   cursor c_act_name (v_actn_typ_id in number) is
   select tl.name  actn_typ_name
    from ben_actn_typ typ,
         ben_actn_typ_tl tl
    where v_actn_typ_id = typ.actn_typ_id
     and typ.actn_typ_id = tl.actn_typ_id
     and tl.language     = userenv('lang')
     and typ.type_cd <> 'BNF'
     and typ.type_cd like 'BNF%'
     and typ.business_group_id = p_business_group_id;
--
     CURSOR c_plan_name(v_plan_id in number)
     IS
       SELECT pl.NAME
	         FROM ben_pl_f pl
       WHERE pl.pl_id = v_plan_id
	      AND p_effective_date BETWEEN pl.effective_start_date
				   AND pl.effective_end_date;

     plan_name_rec   c_plan_name%ROWTYPE;
     l_act_name      ben_actn_typ_tl.name%TYPE;
     l_message_name  fnd_new_messages.message_name%TYPE := 'BEN_94108_BNF_ACT_ITEM';
     l_write_ctfn BOOLEAN;
     l_ff_ctfn_exits BOOLEAN;
 --
 -- end bug 5667528
begin
--

  if g_debug then
    l_proc      := g_package||'.determine_bnf_miss_actn_items';
    hr_utility.set_location ('Entering '||l_proc,10);
  end if;
  --
  l_rslt_object_version_number := p_rslt_object_version_number;
  --
  open c_person_id;
  fetch c_person_id into l_person_id, l_pl_id;
  close c_person_id;
  --
-- get data from pl table.
  open g_bnf_pl(p_prtt_enrt_rslt_id => p_prtt_enrt_rslt_id
               ,p_effective_date    => p_effective_date);
  fetch g_bnf_pl into g_bnf_pl_rec;
  close g_bnf_pl;
  --
  for l_dsgn_bnf in c_dsgn_bnf loop
    --
    -- date of birth action item
    --
    if g_debug then
      hr_utility.set_location('DOB action item ' || l_proc, 20);
    end if;
    --
    l_actn_typ_id := get_actn_typ_id
                       (p_type_cd           => 'BNFDOB'
                       ,p_business_group_id => p_business_group_id);
    --
    -- bug 1169240
    --
    l_bnf_actn_typ_dfnd := check_bnf_actn_item_dfnd
                     (p_pl_id         => g_bnf_pl_rec.pl_id
                 ,p_actn_type_cd      => 'BNFDOB'
                 ,p_business_group_id => p_business_group_id
                 ,p_effective_date    => p_effective_date);
    --
    -- end bug 1169240
    --
    get_prtt_enrt_actn_id
      (p_actn_typ_id           => l_actn_typ_id
      ,p_prtt_enrt_rslt_id     => p_prtt_enrt_rslt_id
      ,p_pl_bnf_id             => l_dsgn_bnf.pl_bnf_id
      ,p_effective_date        => p_effective_date
      ,p_business_group_id     => p_business_group_id
      ,p_prtt_enrt_actn_id     => l_prtt_enrt_actn_id
      ,p_cmpltd_dt             => l_cmpltd_dt
      ,p_object_version_number => l_object_version_number);
    --
    if g_bnf_pl_rec.susp_if_bnf_dob_nt_prv_cd is not null or l_bnf_actn_typ_dfnd then --date of birth is required for plan
      --
      if g_debug then
        hr_utility.set_location('DOB rqd flag is Y', 10);
      end if;
      --
      --
      -- check if person has a date of birth entry
      --
      l_rqd_data_found := check_dob
                            (p_person_id         => l_dsgn_bnf.bnf_person_id
                            ,p_effective_date    => p_effective_date
                            ,p_business_group_id => p_business_group_id);
      --
      if l_rqd_data_found = FALSE then
        l_bnf_actn_warning := TRUE;
        l_dob_found := FALSE;
      elsif l_rqd_data_found = TRUE then
        l_dob_found := TRUE;
      end if;
      --
      if g_bnf_pl_rec.susp_if_bnf_dob_nt_prv_cd = 'RQDS' then
         l_rqd_flag := 'Y';
      else
         l_rqd_flag := 'N';
      end if;
      --
      process_action_item
        (p_prtt_enrt_actn_id          => l_prtt_enrt_actn_id
        ,p_actn_typ_id                => l_actn_typ_id
        ,p_cmpltd_dt                  => l_cmpltd_dt
        ,p_object_version_number      => l_object_version_number
        ,p_effective_date             => p_effective_date
        ,p_rqd_data_found             => l_rqd_data_found
        ,p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
        ,p_pl_bnf_id                  => l_dsgn_bnf.pl_bnf_id
        ,p_rqd_flag                   => l_rqd_flag    --g_bnf_pl_rec.rqd
        ,p_post_rslt_flag             => p_post_rslt_flag
        ,p_business_group_id          => p_business_group_id
        ,p_datetrack_mode             => p_datetrack_mode
        ,p_rslt_object_version_number => p_rslt_object_version_number);
      --
    else
      --
      if g_debug then
        hr_utility.set_location('DOB rqd flag is N', 10);
      end if;
      --
      -- bnf_dob_rqd_flag is 'N';
      -- if date_track mode is updating and designation at plan level
      -- delete action type of type BNFDOB
      --
      if l_prtt_enrt_actn_id IS NOT NULL and p_datetrack_mode = DTMODE_DELETE then
      --
        delete_action_item
          (p_prtt_enrt_actn_id          => l_prtt_enrt_actn_id
          ,p_object_version_number      => l_object_version_number
          ,p_business_group_id          => p_business_group_id
          ,p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
          ,p_rslt_object_version_number => p_rslt_object_version_number
          ,p_effective_date             => p_effective_date
          ,p_datetrack_mode             => p_datetrack_mode
          ,p_post_rslt_flag             => p_post_rslt_flag);
        --
      else
        NULL;  -- nothing to do at this time.
      end if;
      --
    end if; -- bnf_dob_rqd_flag
    --
    -- legislative code (social security number/national identifier) action item
    --
    if g_debug then
      hr_utility.set_location('SSN action item ' || l_proc, 35);
    end if;
    --
    l_actn_typ_id := get_actn_typ_id
                       (p_type_cd           => 'BNFSSN'
                       ,p_business_group_id => p_business_group_id);
    --
    -- bug 1169240
    --
    l_bnf_actn_typ_dfnd := check_bnf_actn_item_dfnd
                     (p_pl_id         => g_bnf_pl_rec.pl_id
                 ,p_actn_type_cd      => 'BNFSSN'
                 ,p_business_group_id => p_business_group_id
                 ,p_effective_date    => p_effective_date);
    --
    -- end bug 1169240
    --
    get_prtt_enrt_actn_id
      (p_actn_typ_id           => l_actn_typ_id
      ,p_prtt_enrt_rslt_id     => p_prtt_enrt_rslt_id
      ,p_effective_date        => p_effective_date
      ,p_business_group_id     => p_business_group_id
      ,p_prtt_enrt_actn_id     => l_prtt_enrt_actn_id
      ,p_pl_bnf_id             => l_dsgn_bnf.pl_bnf_id
      ,p_cmpltd_dt             => l_cmpltd_dt
      ,p_object_version_number => l_object_version_number);
    --
    if g_bnf_pl_rec.susp_if_bnf_ssn_nt_prv_cd is not null or l_bnf_actn_typ_dfnd then --legislative id is rqd for plan
      --
      if g_debug then
        hr_utility.set_location('SSN rqd flag is Y', 10);
      end if;
      --
      -- check if person has a national identifier entry
      --
      l_rqd_data_found := check_legid
                            (p_person_id         => l_dsgn_bnf.bnf_person_id
                            ,p_effective_date    => p_effective_date
                            ,p_business_group_id => p_business_group_id);
      --
      if l_rqd_data_found = FALSE then
        l_bnf_actn_warning := TRUE;
      end if;
      --
      if g_bnf_pl_rec.susp_if_bnf_ssn_nt_prv_cd = 'RQDS' then
         l_rqd_flag := 'Y';
      else
         l_rqd_flag := 'N';
      end if;
      --
      process_action_item
        (p_prtt_enrt_actn_id          => l_prtt_enrt_actn_id
        ,p_actn_typ_id                => l_actn_typ_id
        ,p_cmpltd_dt                  => l_cmpltd_dt
        ,p_object_version_number      => l_object_version_number
        ,p_effective_date             => p_effective_date
        ,p_rqd_data_found             => l_rqd_data_found
        ,p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
        ,p_pl_bnf_id                  => l_dsgn_bnf.pl_bnf_id
        ,p_rqd_flag                   => l_rqd_flag --rqd
        ,p_post_rslt_flag             => p_post_rslt_flag
        ,p_business_group_id          => p_business_group_id
        ,p_datetrack_mode             => p_datetrack_mode
        ,p_rslt_object_version_number => p_rslt_object_version_number);
      --
    else
      --
      if g_debug then
        hr_utility.set_location('SSN rqd flag is N', 10);
      end if;
      --
      -- bnf_legv_id_rqd_flag is 'N'
      -- if date_track mode is updating and designation at plan level
      -- delete action type of type BNFSSN.
      --
      if l_prtt_enrt_actn_id IS NOT NULL and p_datetrack_mode = DTMODE_DELETE then
        --
        delete_action_item
          (p_prtt_enrt_actn_id          => l_prtt_enrt_actn_id
          ,p_object_version_number      => l_object_version_number
          ,p_business_group_id          => p_business_group_id
          ,p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
          ,p_rslt_object_version_number => p_rslt_object_version_number
          ,p_effective_date             => p_effective_date
          ,p_datetrack_mode             => p_datetrack_mode
          ,p_post_rslt_flag             => p_post_rslt_flag);
        --
      else
        NULL;  -- nothing to do at this time.
      end if;
      --
    end if; -- bnf_legv_id_rqd_flag
    --
    -- address action item
    --
    l_actn_typ_id := get_actn_typ_id
                       (p_type_cd           => 'BNFADDR'
                       ,p_business_group_id => p_business_group_id);
    --
    -- bug 1169240
    --
    l_bnf_actn_typ_dfnd := check_bnf_actn_item_dfnd
                     (p_pl_id         => g_bnf_pl_rec.pl_id
                 ,p_actn_type_cd      => 'BNFADDR'
                 ,p_business_group_id => p_business_group_id
                 ,p_effective_date    => p_effective_date);
    --
    -- end bug 1169240
    --
    get_prtt_enrt_actn_id
      (p_actn_typ_id           => l_actn_typ_id
      ,p_prtt_enrt_rslt_id     => p_prtt_enrt_rslt_id
      ,p_pl_bnf_id             => l_dsgn_bnf.pl_bnf_id
      ,p_effective_date        => p_effective_date
      ,p_business_group_id     => p_business_group_id
      ,p_prtt_enrt_actn_id     => l_prtt_enrt_actn_id
      ,p_cmpltd_dt             => l_cmpltd_dt
      ,p_object_version_number => l_object_version_number);
    --
    if g_bnf_pl_rec.susp_if_bnf_adr_nt_prv_cd is not null  or l_bnf_actn_typ_dfnd then -- address is required for plan
      --
      if g_debug then
        hr_utility.set_location('ADDR rqd flag is Y', 10);
      end if;
      --
      -- check if person has an address
      --
      l_rqd_data_found := check_adrs
                            (p_prtt_enrt_rslt_id   => p_prtt_enrt_rslt_id
                            ,p_dpnt_bnf_person_id  => l_dsgn_bnf.bnf_person_id
                            ,p_effective_date      => p_effective_date
                            ,p_business_group_id   => p_business_group_id);
      --
      if l_rqd_data_found = FALSE then
        l_bnf_actn_warning := TRUE;
      end if;
      --
      if g_bnf_pl_rec.susp_if_bnf_adr_nt_prv_cd = 'RQDS' then
         l_rqd_flag := 'Y';
      else
         l_rqd_flag := 'N';
      end if;
      --
      process_action_item
        (p_prtt_enrt_actn_id          => l_prtt_enrt_actn_id
        ,p_actn_typ_id                => l_actn_typ_id
        ,p_cmpltd_dt                  => l_cmpltd_dt
        ,p_object_version_number      => l_object_version_number
        ,p_effective_date             => p_effective_date
        ,p_rqd_data_found             => l_rqd_data_found
        ,p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
        ,p_pl_bnf_id                  => l_dsgn_bnf.pl_bnf_id
        ,p_rqd_flag                   => l_rqd_flag --g_bnf_pl_rec.rqd
        ,p_post_rslt_flag             => p_post_rslt_flag
        ,p_business_group_id          => p_business_group_id
        ,p_datetrack_mode             => p_datetrack_mode
        ,p_rslt_object_version_number => p_rslt_object_version_number);
      --
    else
      --
      if g_debug then
        hr_utility.set_location('ADDR rqd flag is N', 10);
      end if;
      --
      -- bnf_adrs_rqd_flag is 'N'
      -- if date_track mode is updating and designation at plan level
      -- delete action type of type BNFADDR.
      --
      if l_prtt_enrt_actn_id IS NOT NULL and p_datetrack_mode = DTMODE_DELETE then
        --
        delete_action_item
          (p_prtt_enrt_actn_id          => l_prtt_enrt_actn_id
          ,p_object_version_number      => l_object_version_number
          ,p_business_group_id          => p_business_group_id
          ,p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
          ,p_rslt_object_version_number => p_rslt_object_version_number
          ,p_effective_date             => p_effective_date
          ,p_datetrack_mode             => p_datetrack_mode
          ,p_post_rslt_flag             => p_post_rslt_flag);
        --
      else
        NULL;  -- nothing to do at this time.
      end if;
      --
    end if; -- bnf_adrs_rqd_flag
    --
    -- trustee action item
    --
    l_actn_typ_id := get_actn_typ_id
                       (p_type_cd           => 'BNFTTEE'
                       ,p_business_group_id => p_business_group_id);
    --
    -- bug 1169240
    --
    l_bnf_actn_typ_dfnd := check_bnf_actn_item_dfnd
                     (p_pl_id         => g_bnf_pl_rec.pl_id
                 ,p_actn_type_cd      => 'BNFTTEE'
                 ,p_business_group_id => p_business_group_id
                 ,p_effective_date    => p_effective_date);
    --
    -- end bug 1169240
    --
    get_prtt_enrt_actn_id
      (p_actn_typ_id           => l_actn_typ_id
      ,p_prtt_enrt_rslt_id     => p_prtt_enrt_rslt_id
      ,p_pl_bnf_id             => l_dsgn_bnf.pl_bnf_id
      ,p_effective_date        => p_effective_date
      ,p_business_group_id     => p_business_group_id
      ,p_prtt_enrt_actn_id     => l_prtt_enrt_actn_id
      ,p_cmpltd_dt             => l_cmpltd_dt
      ,p_object_version_number => l_object_version_number);
    --
    -- Check the trustee action item only if the DOB of beneficiary is present
    --
    if ( g_bnf_pl_rec.bnf_dsge_mnr_ttee_rqd_flag = 'Y' or l_bnf_actn_typ_dfnd ) and
       l_dob_found = TRUE then
      --
      if g_debug then
        hr_utility.set_location('TTEE rqd flag is Y and DOB found', 10);
      end if;
      --
      --
      -- check if the designated beneficiary is over age of 18
      --
      l_rqd_data_found := check_bnf_ttee
                            (p_pl_bnf_id         => l_dsgn_bnf.pl_bnf_id
                            ,p_effective_date    => p_effective_date
                            ,p_business_group_id => p_business_group_id);
      --
      if l_rqd_data_found = FALSE then
        -- designated beneficiary is a minor
        l_bnf_actn_warning := TRUE;
        --
      end if;
      --
      process_action_item
        (p_prtt_enrt_actn_id          => l_prtt_enrt_actn_id
        ,p_actn_typ_id                => l_actn_typ_id
        ,p_cmpltd_dt                  => l_cmpltd_dt
        ,p_object_version_number      => l_object_version_number
        ,p_effective_date             => p_effective_date
        ,p_rqd_data_found             => l_rqd_data_found
        ,p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
        ,p_pl_bnf_id                  => l_dsgn_bnf.pl_bnf_id
        ,p_rqd_flag                   => g_bnf_pl_rec.rqd
        ,p_post_rslt_flag             => p_post_rslt_flag
        ,p_business_group_id          => p_business_group_id
        ,p_datetrack_mode             => p_datetrack_mode
        ,p_rslt_object_version_number => p_rslt_object_version_number);
      --
    else
      --
      if g_debug then
        hr_utility.set_location('TTEE rqd flag is N or DOB not found', 10);
      end if;
      --
      -- bnf_dsge_mnr_ttee_rqd_flag is 'N'
      -- if date_track mode is updating and designation at plan level
      -- delete action type of type BNFTTEE.
      --
      if l_prtt_enrt_actn_id IS NOT NULL and p_datetrack_mode = DTMODE_DELETE then
        --
        delete_action_item
          (p_prtt_enrt_actn_id          => l_prtt_enrt_actn_id
          ,p_object_version_number      => l_object_version_number
          ,p_business_group_id          => p_business_group_id
          ,p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
          ,p_rslt_object_version_number => p_rslt_object_version_number
          ,p_effective_date             => p_effective_date
          ,p_datetrack_mode             => p_datetrack_mode
          ,p_post_rslt_flag             => p_post_rslt_flag);
        --
      else
        NULL;  -- nothing to do at this time.
      end if;
      --
    end if; -- bnf_dsge_mnr_ttee_rqd_flag
    --
    --
    -- certification action item
    --
    l_actn_typ_id := get_actn_typ_id
                       (p_type_cd           => 'BNFCTFN'
                       ,p_business_group_id => p_business_group_id);
    --
    -- bug 1169240
    --
    l_bnf_actn_typ_dfnd := check_bnf_actn_item_dfnd
                     (p_pl_id         => g_bnf_pl_rec.pl_id
                 ,p_actn_type_cd      => 'BNFCTFN'
                 ,p_business_group_id => p_business_group_id
                 ,p_effective_date    => p_effective_date);
    --
    -- end bug 1169240
    --
    get_prtt_enrt_actn_id
      (p_actn_typ_id           => l_actn_typ_id
      ,p_prtt_enrt_rslt_id     => p_prtt_enrt_rslt_id
      ,p_pl_bnf_id             => l_dsgn_bnf.pl_bnf_id
      ,p_effective_date        => p_effective_date
      ,p_business_group_id     => p_business_group_id
      ,p_prtt_enrt_actn_id     => l_prtt_enrt_actn_id
      ,p_cmpltd_dt             => l_cmpltd_dt
      ,p_object_version_number => l_object_version_number);
    --
    -- ******************************************************
    -- ****************Very Important************************
    -- The flag here says Beneficiary Certification Required,
    -- but in the form it says the opposite, No Ctfn Required.
    -- The name of this flag needs to be changed, so till this
    -- happens bear with the name and assume it to be something
    -- "bnf_no_ctfn_rqd_flag" (Column re-naming).
    -- *******************************************************
    --
    if g_bnf_pl_rec.bnf_ctfn_rqd_flag = 'N' or l_bnf_actn_typ_dfnd then
      --
      if g_debug then
        hr_utility.set_location('Ctfn rqd flag is N', 10);
      end if;
      --
      -- Certifications are required for the plan.
      -- Check if there are any certifications defined for the plan that are
      -- not of the Notarized Spousal Consent (NSC) type.
      --
      open c_ctfn_defined(l_dsgn_bnf.bnf_person_id,l_person_id, l_pl_id);
      fetch c_ctfn_defined into l_dummy;
      --
      if c_ctfn_defined%found then
        l_ctfn_defined := TRUE;
      else
        l_ctfn_defined := FALSE;
      end if;
      --
      close c_ctfn_defined;
      --
      -- If certifications were defined, then check to see if all the proper
      -- certifications were provided for the bnf person.
      --
      if l_ctfn_defined = TRUE then
        --
        if g_debug then
          hr_utility.set_location('Certifications defined', 10);
        end if;
        --
        l_rqd_data_found := check_bnf_ctfn
                              (p_prtt_enrt_actn_id => l_prtt_enrt_actn_id
                              ,p_pl_bnf_id         => l_dsgn_bnf.pl_bnf_id
                              ,p_effective_date    => p_effective_date);
        --
        if l_rqd_data_found = FALSE then
          l_bnf_actn_warning := TRUE;
        end if;
        --
        process_action_item
          (p_prtt_enrt_actn_id          => l_prtt_enrt_actn_id
          ,p_actn_typ_id                => l_actn_typ_id
          ,p_cmpltd_dt                  => l_cmpltd_dt
          ,p_object_version_number      => l_object_version_number
          ,p_effective_date             => p_effective_date
          ,p_rqd_data_found             => l_rqd_data_found
          ,p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
          ,p_pl_bnf_id                  => l_dsgn_bnf.pl_bnf_id
          ,p_rqd_flag                   => g_bnf_pl_rec.susp_if_ctfn_not_bnf_flag
          ,p_post_rslt_flag             => p_post_rslt_flag
          ,p_business_group_id          => p_business_group_id
          ,p_datetrack_mode             => p_datetrack_mode
          ,p_rslt_object_version_number => p_rslt_object_version_number);
        --
        if l_rqd_data_found = FALSE then
          --
          if g_debug then
            hr_utility.set_location('Ctfn rqmts not met', 10);
          end if;
          --
          -- Ctfn rqmts are not met or no ctfns were found. Check if ctfns
          -- exist for the person in ben_pl_bnf_ctfn_prvdd_f.
          --
          open c_ctfns_exist(l_dsgn_bnf.pl_bnf_id);
          fetch c_ctfns_exist into l_dummy;
          --
          if c_ctfns_exist%notfound then
            --
            if g_debug then
              hr_utility.set_location('Person has no ctfns defined', 10);
            end if;
            --
            -- No ctfns exist for this person. Write new ctfns.
            --
            for l_ctfn_rec in c_ctfns(l_dsgn_bnf.bnf_person_id
                                      ,g_bnf_pl_rec.pl_id,l_person_id) loop
              --
              -- start bug 5667528
            l_write_ctfn := TRUE;
            l_ff_ctfn_exits := FALSE;
            hr_utility.set_location (' l_ctfn_rec.ctrrl	' || l_ctfn_rec.ctrrl,
                                     12.12
                                    );

            IF l_ctfn_rec.ctrrl IS NOT NULL
            THEN
               OPEN c_pen_info;

               FETCH c_pen_info
                INTO pen_info_rec;

               CLOSE c_pen_info;

               OPEN c_asg (pen_info_rec.person_id);

               FETCH c_asg
                INTO asg_rec;

               CLOSE c_asg;

               OPEN c_opt (pen_info_rec.oipl_id);

               FETCH c_opt
                INTO opt_rec;

               CLOSE c_opt;

               l_outputs :=
                  benutils.formula
                      (p_formula_id             => l_ctfn_rec.ctrrl,
                       p_pgm_id                 => pen_info_rec.pgm_id,
                       p_pl_id                  => pen_info_rec.pl_id,
                       p_pl_typ_id              => pen_info_rec.pl_typ_id,
                       p_opt_id                 => opt_rec.opt_id,
                       p_ler_id                 => pen_info_rec.ler_id,
                       p_business_group_id      => pen_info_rec.business_group_id,
                       p_assignment_id          => asg_rec.assignment_id,
                       p_organization_id        => asg_rec.organization_id,
                       p_effective_date         => p_effective_date
                      );
               hr_utility.set_location (   ' formula result '
                                        || l_outputs (l_outputs.FIRST).VALUE,
                                        12.12
                                       );

               IF l_outputs (l_outputs.FIRST).VALUE <> 'Y'
               THEN
                  l_write_ctfn := FALSE;
                  hr_utility.set_location (' setting ctfn to false ', 12.12);
               END IF;
            END IF;                     -- end if l_ctfn_rec.ctrrl is not null
	           IF l_write_ctfn = TRUE THEN
		               l_ff_ctfn_exits := true;
	         	      hr_utility.set_location(' writing certification ',12.12);

		              write_new_bnf_ctfn_item
                (p_pl_bnf_id             => l_dsgn_bnf.pl_bnf_id
                ,p_prtt_enrt_actn_id     => l_prtt_enrt_actn_id
                ,p_bnf_ctfn_typ_cd       => l_ctfn_rec.ctcvgcd
		             --,p_bnf_ctfn_rqd_flag     => l_ctfn_rec.ctflag  Bug 3196152
		             ,p_bnf_ctfn_rqd_flag     => l_ctfn_rec.rqd_flag
                ,p_effective_date        => p_effective_date
                ,p_business_group_id     => p_business_group_id
                ,p_object_version_number => l_object_version_number
                ,p_pl_bnf_ctfn_prvdd_id  => l_pl_bnf_ctfn_prvdd_id);
              --
	            END IF;
            end loop;
            --
          end if; -- ctfns_exist
          --
          close c_ctfns_exist;
          --
        end if; -- rqd_data_found
        --
        IF l_ff_ctfn_exits = FALSE
            THEN
               hr_utility.set_location
                      ('Deleting enrollment action item when formula fails ',
                       12.12
                      );

               OPEN c_curr_ovn_of_actn (l_prtt_enrt_actn_id);

               FETCH c_curr_ovn_of_actn
                INTO l_object_version_number;

               CLOSE c_curr_ovn_of_actn;

               delete_action_item
                  (p_prtt_enrt_actn_id               => l_prtt_enrt_actn_id,
                   p_object_version_number           => l_object_version_number,
                   p_business_group_id               => p_business_group_id,
                   p_prtt_enrt_rslt_id               => p_prtt_enrt_rslt_id,
                   p_rslt_object_version_number      => p_rslt_object_version_number,
                   p_effective_date                  => p_effective_date,
                   p_datetrack_mode                  => hr_api.g_zap,
                   p_post_rslt_flag                  => p_post_rslt_flag
                  );

               -- we need to delete warning also that was created for this action item
               OPEN c_act_name (l_actn_typ_id);

               FETCH c_act_name
                INTO l_act_name;

               CLOSE c_act_name;

               OPEN c_plan_name (pen_info_rec.pl_id);

               FETCH c_plan_name
                INTO plan_name_rec;

               CLOSE c_plan_name;

               ben_warnings.delete_warnings
                                        (p_application_short_name      => 'BEN',
                                         p_message_name                => l_message_name,
                                         p_parma                       => l_act_name,
                                         p_parmb                       => plan_name_rec.NAME,
                                         p_person_id                   => pen_info_rec.person_id
                                        );
         END IF;
      -- end  bug 5667528
      end if; -- ctfn_defined
      --
    else
      --
      -- bnf_ctfn_rqd_flag is 'Y'
      -- if date_track mode is updating and designation at plan level
      -- delete action type of type BNFCTFN.
      --
      if l_prtt_enrt_actn_id IS NOT NULL and p_datetrack_mode = DTMODE_DELETE then
      --
        delete_action_item
          (p_prtt_enrt_actn_id          => l_prtt_enrt_actn_id
          ,p_object_version_number      => l_object_version_number
          ,p_business_group_id          => p_business_group_id
          ,p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
          ,p_rslt_object_version_number => p_rslt_object_version_number
          ,p_effective_date             => p_effective_date
          ,p_datetrack_mode             => p_datetrack_mode
          ,p_post_rslt_flag             => p_post_rslt_flag);
        --
      end if;
      --
    end if; -- bnf_ctfn_rqd_flag
    --
  end loop; -- bnf loop
  --
  if g_debug then
    hr_utility.set_location ('Leaving '||l_proc,10);
  end if;
  --
exception
  when others then
    if g_debug then
      hr_utility.set_location('Exception Raised '||l_proc, 10);
    end if;

    p_rslt_object_version_number :=l_rslt_object_version_number ;
    p_bnf_actn_warning           := null;

    raise;
--
end determine_bnf_miss_actn_items;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< determine_bnf_actn_items >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure determine_bnf_actn_items
  (p_prtt_enrt_rslt_id          in     number
  ,p_effective_date             in     date
  ,p_business_group_id          in     number
  ,p_datetrack_mode             in     varchar2 default hr_api.g_correction
  ,p_post_rslt_flag             in     varchar2 default 'Y'
  ,p_rslt_object_version_number in out nocopy number
  ,p_bnf_actn_item_open            out nocopy boolean
  ,p_hack                          out nocopy varchar2) is
  --
  -- this procedure determines if beneficiaries are required to complete
  -- enrollment. For an enrollment result check ben_pl_f.bnf_dsgn_cd
  -- if not NULL then a beneficiary is requested so write BNF action item.
  -- in additon if the bnf designation is 'R' required, suspend enrollment.
  -- or if designation 'O' optional, do not suspend.
  --
  cursor c_find_bnf is
  select pl_bnf_id
    from ben_pl_bnf_f,
         ben_per_in_ler pil
   where prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and p_effective_date between
         effective_start_date and effective_end_date
     and pil.per_in_ler_id=ben_pl_bnf_f.per_in_ler_id
     and pil.business_group_id=p_business_group_id
     and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT');
  --
  l_find_bnf c_find_bnf%rowtype;
  --
  -- Cursor to fetch bnf action items other than the BNF item. this will
  -- be used to delete all beneficiary action items after a BNF action item is
  -- written
  --
  cursor c_other_bnf_actn_items is
  select pea.prtt_enrt_actn_id,
         pea.object_version_number
    from ben_prtt_enrt_actn_f pea,
         ben_actn_typ typ,
         ben_per_in_ler pil
   where pea.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and pea.business_group_id = p_business_group_id
     and typ.type_cd <> 'BNF'
     and typ.type_cd like 'BNF%'
     and typ.business_group_id = p_business_group_id
     and pea.per_in_ler_id = pil.per_in_ler_id
     and pil.per_in_ler_stat_cd not in ('BCKDT', 'VOIDD')
     and pea.actn_typ_id = typ.actn_typ_id
     and p_effective_date between pea.effective_start_date
                              and pea.effective_end_date
  ;
  --
  l_actn_typ_id number;
  l_cmpltd_dt date;
  l_object_version_number number;
  l_prtt_enrt_actn_id number;
  l_bnf_found boolean;
  l_rslt_object_version_number number(15);

  --
  bnf_dsgn_cd_null exception;
  --
  l_proc     varchar2(80) ;
--
begin
--
  if g_debug then
    l_proc      := g_package||'.determine_bnf_actn_items';
    hr_utility.set_location ('Entering '||l_proc,10);
  end if;
  --
  l_rslt_object_version_number := p_rslt_object_version_number;

  -- get data from pl table.
  open g_bnf_pl(p_prtt_enrt_rslt_id => p_prtt_enrt_rslt_id
               ,p_effective_date    => p_effective_date);
  fetch g_bnf_pl into g_bnf_pl_rec;
  if g_bnf_pl_rec.rqd is null then
     -- if bnf_dsgn_cd is null, skip out of this procedure.
     close g_bnf_pl;
     raise bnf_dsgn_cd_null;
  end if;
  close g_bnf_pl;
  --
  -- Check if beneficiaries are designated.
  --
  open c_find_bnf;
  fetch c_find_bnf into l_find_bnf;
  --
  if c_find_bnf%found then
    l_bnf_found := TRUE;
  else
    l_bnf_found := FALSE;
  end if;
  --
  close c_find_bnf;
  --
  -- Get the actn type id for the BNF action item
  --
  l_actn_typ_id := get_actn_typ_id
                     (p_type_cd           => 'BNF'
                     ,p_business_group_id => p_business_group_id);
  --
  -- Get the action item id if one exists
  --
  get_prtt_enrt_actn_id
    (p_actn_typ_id           => l_actn_typ_id
    ,p_prtt_enrt_rslt_id     => p_prtt_enrt_rslt_id
    ,p_effective_date        => p_effective_date
    ,p_business_group_id     => p_business_group_id
    ,p_prtt_enrt_actn_id     => l_prtt_enrt_actn_id
    ,p_cmpltd_dt             => l_cmpltd_dt
    ,p_object_version_number => l_object_version_number);
  --
  if l_bnf_found = FALSE then
    --
    if g_debug then
      hr_utility.set_location('Beneficiaries not designated', 10);
    end if;
    --
    --
    -- There are no beneficiaries designated
    --
    -- Set the p_rqd_data_found parameter to FALSE so that the procedure writes
    -- an action item
    --
    process_action_item
      (p_prtt_enrt_actn_id          => l_prtt_enrt_actn_id
      ,p_actn_typ_id                => l_actn_typ_id
      ,p_cmpltd_dt                  => l_cmpltd_dt
      ,p_object_version_number      => l_object_version_number
      ,p_effective_date             => p_effective_date
      ,p_rqd_data_found             => FALSE
      ,p_rqd_flag                   => g_bnf_pl_rec.rqd
      ,p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
      ,p_post_rslt_flag             => p_post_rslt_flag
      ,p_business_group_id          => p_business_group_id
      ,p_datetrack_mode             => p_datetrack_mode
      ,p_rslt_object_version_number => p_rslt_object_version_number);
    --
    p_bnf_actn_item_open := TRUE;
    --
    -- Set the hack flag to N so that the calling program knows that an action
    -- item was actually written
    --
    p_hack := 'N';
    --
    -- Delete all other beneficiary action items.
    --
    for actn_item_rec in c_other_bnf_actn_items loop
      --
      delete_action_item
        (p_prtt_enrt_actn_id          => actn_item_rec.prtt_enrt_actn_id
        ,p_object_version_number      => actn_item_rec.object_version_number
        ,p_business_group_id          => p_business_group_id
        ,p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
        ,p_rslt_object_version_number => p_rslt_object_version_number
        ,p_effective_date             => p_effective_date
        ,p_datetrack_mode             => hr_api.g_zap
        ,p_post_rslt_flag             => p_post_rslt_flag);
      --
    end loop;
    --
  else
    --
    -- Beneficiaries found
    --
    if g_debug then
      hr_utility.set_location('Beneficiaries found', 10);
    end if;
    --
    --
    -- Set the p_rqd_data_found = TRUE so that the proc below closes an open
    -- action item of type BNF, if found.
    --
    process_action_item
      (p_prtt_enrt_actn_id          => l_prtt_enrt_actn_id
      ,p_actn_typ_id                => l_actn_typ_id
      ,p_cmpltd_dt                  => l_cmpltd_dt
      ,p_object_version_number      => l_object_version_number
      ,p_effective_date             => p_effective_date
      ,p_rqd_data_found             => TRUE
      ,p_rqd_flag                   => g_bnf_pl_rec.rqd
      ,p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
      ,p_post_rslt_flag             => p_post_rslt_flag
      ,p_business_group_id          => p_business_group_id
      ,p_datetrack_mode             => p_datetrack_mode
      ,p_rslt_object_version_number => p_rslt_object_version_number);
    --
    p_bnf_actn_item_open := FALSE;
    p_hack := 'N';
    --
  end if;
  --
  if g_debug then
    hr_utility.set_location ('Leaving ' ||l_proc,10);
  end if;
  --
exception
  --
  when bnf_dsgn_cd_null
  then
    -- Since designation of beneficiaries is not required for the plan, we don't
    -- have to write any action item. Set the out parameter so that the calling
    -- proc does not call determine_bnf_miss_actn_items. Also set the hack flag
    -- to Y so that the calling procedure knows that no action items were
    -- written.
    --
    p_bnf_actn_item_open := TRUE;
    p_hack := 'Y';
    --
    if g_debug then
      hr_utility.set_location('Bnf dsgn not specified.', 10);
    end if;
    if g_debug then
      hr_utility.set_location('Leaving : ' || l_proc, 10);
    end if;
    --
   when others then
     if g_debug then
       hr_utility.set_location('Exception Raised '||l_proc, 10);
     end if;

     p_rslt_object_version_number :=l_rslt_object_version_number ;
     p_bnf_actn_item_open         := null;
     p_hack                       := null ;
     raise;
--
end determine_bnf_actn_items;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< determine_additional_bnf >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure determine_additional_bnf
  (p_validate                   in     boolean  default FALSE
  ,p_prtt_enrt_rslt_id          in     number
  ,p_effective_date             in     date
  ,p_business_group_id          in     number
  ,p_datetrack_mode             in     varchar2 default hr_api.g_correction
  ,p_post_rslt_flag             in     varchar2 default 'Y'
  ,p_rslt_object_version_number in out nocopy number
  ,p_bnf_actn_warning           in out nocopy boolean) is
--
  -- This procedure is run after all beneficiaries have been designated. If an
  -- additonal beneficiary designation is needed an action item of type BNFADDNL
  -- is written. It also writes a BNFSCCTFN (spousal consent certification)
  -- aciton item when a prtt has designated a person other than his/her spouse
  -- as a primary beneficiary and spousal consent certification is required and
  -- has not been provided.
  --
  l_proc     varchar2(80) ;
  l_actn_typ_id    number;
  l_cmpltd_dt date;
  l_object_version_number number;
  l_prtt_enrt_actn_id  number;
  l_prtt_enrt_ctfn_prvdd_id number;
  l_meets_rqmt  boolean;
  l_outputs        ff_exec.outputs_t;
  l_write_ctfn  boolean := TRUE;
  l_bnf_actn_warning boolean := FALSE;
  l_rslt_object_version_number number(15);

  l_dummy varchar2(30);
  --
  -- Cursor to compute the sum of the primary and contingent beneficiaries'
  -- designated percentages
  --
  cursor c_rslt is select
    rslt.pgm_id,
    rslt.pl_id,
    rslt.pl_typ_id,
    rslt.oipl_id,
    rslt.ler_id,
    rslt.person_id,
    rslt.business_group_id
    from ben_prtt_enrt_rslt_f rslt
    where rslt.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
        and p_effective_date between
         rslt.effective_start_date and rslt.effective_end_date;

l_rslt c_rslt%rowtype;

  cursor c_opt is
    select oipl.opt_id
    from ben_oipl_f oipl
    where oipl.oipl_id = l_rslt.oipl_id
        and business_group_id = p_business_group_id
        and p_effective_date between
         oipl.effective_start_date and oipl.effective_end_date;

l_opt c_opt%rowtype;

  cursor c_asg is
    select asg.assignment_id,asg.organization_id
    from per_all_assignments_f asg
    where asg.person_id = l_rslt.person_id
    and asg.assignment_type <> 'C'
    and asg.primary_flag = 'Y'
        and p_effective_date between
         asg.effective_start_date and asg.effective_end_date;

l_asg c_asg%rowtype;

  cursor c_sum_bnf_pct is
  select prmry_cntngnt_cd cntgcd,
         sum(pct_dsgd_num) prcnt
    from ben_pl_bnf_f ,
         ben_per_in_ler pil
   where prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and ben_pl_bnf_f.business_group_id = p_business_group_id
     and p_effective_date between
         ben_pl_bnf_f.effective_start_date and ben_pl_bnf_f.effective_end_date
     and pil.per_in_ler_id=ben_pl_bnf_f.per_in_ler_id
     and pil.business_group_id=p_business_group_id
     and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
   group by prmry_cntngnt_cd;
  --
  l_sum_bnf_pct c_sum_bnf_pct%rowtype;
  --
  -- Cursor to pick up any NSC ctfns that may be defined for the plan and
  -- contact type.
  --  Bug 5461171 - Modified conditions. See Bug Closure for all scenarios
  --                satisfied by the cursor
  --
   CURSOR c_nsc_ctfn_pl (v_contact_type IN VARCHAR2, v_pl_id IN NUMBER)
   IS
      SELECT pcx.rqd_flag ctflag, pcx.bnf_ctfn_typ_cd ctcvgcd,
             pcx.ctfn_rqd_when_rl ctrrl, pcx.rlshp_typ_cd ctrlshcd,
             pcx.bnf_typ_cd, pcx.pl_id
        FROM ben_pl_bnf_ctfn_f pcx
       WHERE pcx.pl_id = v_pl_id
         AND (   (    NVL (pcx.bnf_typ_cd, 'O') = 'O'
                  AND v_contact_type = 'O'
                  AND pcx.rlshp_typ_cd IS NULL
                 )
              OR                                      -- Bug 5156111
                 (    NVL (pcx.bnf_typ_cd, 'P') = 'P'
                  AND NVL (pcx.rlshp_typ_cd, v_contact_type) = v_contact_type
                  AND v_contact_type <> 'O'
                 )
             )
         AND pcx.bnf_ctfn_typ_cd = 'NSC'
         AND pcx.business_group_id = p_business_group_id
         AND p_effective_date BETWEEN pcx.effective_start_date
                                  AND pcx.effective_end_date;

  --
  -- check if the participant is married and the spouse the primary beneficiary
  --
  cursor c_spouse is
  select pcr.contact_type,
         plb.bnf_person_id,
         plb.pl_bnf_id,
         pl.pl_id
    from per_all_people_f per,
         per_contact_relationships pcr,
         ben_pl_f pl,
         ben_pl_bnf_f plb,
         ben_prtt_enrt_rslt_f pen,
         ben_per_in_ler pil
   where pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and pen.pl_id = pl.pl_id
     and pl.bnf_qdro_rl_apls_flag = 'Y'
     and pl.bnf_ctfn_rqd_flag = 'N'   -- Flag is named incorrectly(opposite).
     and plb.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
     and plb.prmry_cntngnt_cd = 'PRIMY'
     and pcr.contact_person_id = plb.bnf_person_id
     and pcr.person_id = pen.person_id
     and per.person_id = pen.person_id
     and per.marital_status = 'M'
     and pcr.business_group_id = p_business_group_id
     and pen.business_group_id = p_business_group_id
     and p_effective_date between pen.effective_start_date
                              and pen.effective_end_date
     and per.business_group_id = p_business_group_id
     and p_effective_date between per.effective_start_date
                              and per.effective_end_date
     and pl.business_group_id = p_business_group_id
     and p_effective_date between pl.effective_start_date
                              and pl.effective_end_date
     and plb.business_group_id = p_business_group_id
     and p_effective_date between plb.effective_start_date
                              and plb.effective_end_date
     and p_effective_date  between nvl(date_start, p_effective_date) -- bug 5362890
                               and nvl(date_end, hr_api.g_eot)
     and pil.per_in_ler_id=plb.per_in_ler_id
     and pil.business_group_id=p_business_group_id
     and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
UNION                                           -- Bug 5156111 : Added union clause
  select 'O',
         plb.organization_id,
         plb.pl_bnf_id,
         pl.pl_id
    from per_all_people_f per,
         hr_all_organization_units o,
         ben_pl_f pl,
         ben_pl_bnf_f plb,
         ben_prtt_enrt_rslt_f pen,
         ben_per_in_ler pil
   where pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and pen.pl_id = pl.pl_id
     and pl.bnf_qdro_rl_apls_flag = 'Y'
     and pl.bnf_may_dsgt_org_flag = 'Y'
     and pl.bnf_ctfn_rqd_flag = 'N'   -- Flag is named incorrectly(opposite).
     and plb.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
     and plb.prmry_cntngnt_cd = 'PRIMY'
     and o.organization_id = plb.organization_id
     and per.person_id = pen.person_id
     and per.marital_status = 'M'
     and o.business_group_id = p_business_group_id
     and pen.business_group_id = p_business_group_id
     and p_effective_date between pen.effective_start_date
                              and pen.effective_end_date
     and per.business_group_id = p_business_group_id
     and p_effective_date between per.effective_start_date
                              and per.effective_end_date
     and pl.business_group_id = p_business_group_id
     and p_effective_date between pl.effective_start_date
                              and pl.effective_end_date
     and plb.business_group_id = p_business_group_id
     and p_effective_date between o.date_from
                              and nvl(o.date_to, p_effective_date)
     and pil.per_in_ler_id=plb.per_in_ler_id
     and pil.business_group_id=p_business_group_id
     and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT');

  --
  -- Cursor to check if the NSC ctfn has been provided.
  --
  cursor c_nsc_prvdd(v_pl_bnf_id number) is
  select 's'
    from ben_pl_bnf_ctfn_prvdd_f
   where pl_bnf_id = v_pl_bnf_id
     and bnf_ctfn_recd_dt is not null
     and business_group_id = p_business_group_id
     and p_effective_date between effective_start_date
                              and effective_end_date;

begin
--
  if g_debug then
    l_proc      := g_package||'.determine_additional_bnf';
    hr_utility.set_location ('Entering '||l_proc,10);
  end if;
  --

  l_rslt_object_version_number := p_rslt_object_version_number;

  --
  if p_prtt_enrt_rslt_id is not null then
    open c_rslt;
    fetch c_rslt into l_rslt;
    close c_rslt;

    -- get data from pl table.
    open g_bnf_pl(p_prtt_enrt_rslt_id => p_prtt_enrt_rslt_id
                 ,p_effective_date    => p_effective_date);
    fetch g_bnf_pl into g_bnf_pl_rec;
    close g_bnf_pl;
  end if;


  if l_rslt.person_id is not null then
    open c_asg;
    fetch c_asg into l_asg;
    close c_asg;
  end if;

  l_meets_rqmt := TRUE;
  --
  open c_sum_bnf_pct;
  --
  -- Check if the sum total of the percentages is 100% for either primary or
  -- contingent beneficiaries. If not, then write an action item of type
  -- BNFADDNL for designating addtional beneficiaryies.
  --
  loop
    --
    fetch c_sum_bnf_pct into l_sum_bnf_pct;
    exit when c_sum_bnf_pct%notfound;
    --
    if l_sum_bnf_pct.prcnt < 100 then
      l_meets_rqmt := FALSE;
    end if;
    --
  end loop;
  --
  close c_sum_bnf_pct;
  --
  -- Check if an action item of type BNFADDNL exists.
  --
  l_actn_typ_id := get_actn_typ_id
                     (p_type_cd           => 'BNFADDNL'
                     ,p_business_group_id => p_business_group_id);
  --
  get_prtt_enrt_actn_id
    (p_actn_typ_id           => l_actn_typ_id
    ,p_prtt_enrt_rslt_id     => p_prtt_enrt_rslt_id
    ,p_effective_date        => p_effective_date
    ,p_business_group_id     => p_business_group_id
    ,p_prtt_enrt_actn_id     => l_prtt_enrt_actn_id
    ,p_cmpltd_dt             => l_cmpltd_dt
    ,p_object_version_number => l_object_version_number);
  --
  if l_meets_rqmt = TRUE then
    --
    if g_debug then
      hr_utility.set_location('rqmts met for BNFADDNL', 10);
    end if;
    --
    -- Set the p_rqd_data_found = TRUE so that the procedure closes an open
    -- action item of type BNFADDNL, if found.
    --
    process_action_item
      (p_prtt_enrt_actn_id          => l_prtt_enrt_actn_id
      ,p_actn_typ_id                => l_actn_typ_id
      ,p_cmpltd_dt                  => l_cmpltd_dt
      ,p_object_version_number      => l_object_version_number
      ,p_effective_date             => p_effective_date
      ,p_rqd_data_found             => TRUE
      ,p_rqd_flag                   => g_bnf_pl_rec.rqd
      ,p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
      ,p_post_rslt_flag             => p_post_rslt_flag
      ,p_business_group_id          => p_business_group_id
      ,p_datetrack_mode             => p_datetrack_mode
      ,p_rslt_object_version_number => p_rslt_object_version_number);
    --
  else
    --
    if g_debug then
      hr_utility.set_location('rqmts not met for BNFADDNL', 10);
    end if;

    --
    -- Requirements are not met. Set the p_rqd_data_found = FALSE so that the
    -- procedure reopens or writes a new action item of type BNFADDNL.
    --
    process_action_item
      (p_prtt_enrt_actn_id          => l_prtt_enrt_actn_id
      ,p_actn_typ_id                => l_actn_typ_id
      ,p_cmpltd_dt                  => l_cmpltd_dt
      ,p_object_version_number      => l_object_version_number
      ,p_effective_date             => p_effective_date
      ,p_rqd_data_found             => FALSE
      ,p_rqd_flag                   => g_bnf_pl_rec.rqd
      ,p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
      ,p_post_rslt_flag             => p_post_rslt_flag
      ,p_business_group_id          => p_business_group_id
      ,p_datetrack_mode             => p_datetrack_mode
      ,p_rslt_object_version_number => p_rslt_object_version_number);
    --
  end if;
  --
  --
  -- SPOUSAL CONSENT CERTIFICATTION
  --
  -- Check if the primary bnf is a spouse and if not, whether the plan requires
  -- a spousal consent ctfn.
  --
  for l_bnf_rec in c_spouse loop
    --
    -- Reset the enrt actn id for each new iteration.
    --
    l_prtt_enrt_actn_id := NULL;
    --
    if l_bnf_rec.contact_type <> 'S' then
      --
      -- The primary bnf is not a spouse.
      --
      if g_debug then
        hr_utility.set_location('Contact type ' || l_bnf_rec.contact_type ||
                              ' is not a spouse', 10);
      end if;
      --
      -- Check if an BNFSCCTFN actn item already exists for the bnf.
      --
      l_actn_typ_id := get_actn_typ_id
                        (p_type_cd           => 'BNFSCCTFN'
                        ,p_business_group_id => p_business_group_id);
      --
      get_prtt_enrt_actn_id
        (p_actn_typ_id           => l_actn_typ_id
        ,p_prtt_enrt_rslt_id     => p_prtt_enrt_rslt_id
        ,p_pl_bnf_id             => l_bnf_rec.pl_bnf_id
        ,p_effective_date        => p_effective_date
        ,p_business_group_id     => p_business_group_id
        ,p_prtt_enrt_actn_id     => l_prtt_enrt_actn_id
        ,p_cmpltd_dt             => l_cmpltd_dt
        ,p_object_version_number => l_object_version_number);
      --
      -- Loop through sposal consent ctfns that are defined for this contact
      -- type and write to pl_bnf_ctfn_prvdd_f.
      --
      for l_nsc_ctfn_pl in c_nsc_ctfn_pl(l_bnf_rec.contact_type
                                        ,l_bnf_rec.pl_id)       loop
        --
        -- We will be in this loop only if a ctfn is defined for this contact
        -- type. If the action item was not found earlier, we need to create
        -- one and then write ctfns into the ctfn_prvdd table.
        --
        if l_prtt_enrt_actn_id IS NULL then
          --
          -- no BNFSCCTFN action item yet so create a new entry
          --
          if g_debug then
            hr_utility.set_location('No BNFSCCTFN actn item.', 10);
          end if;
          --
          write_new_action_item
            (p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
            ,p_rslt_object_version_number => p_rslt_object_version_number
            ,p_actn_typ_id                => l_actn_typ_id
            ,p_pl_bnf_id                  => l_bnf_rec.pl_bnf_id
            ,p_rqd_flag                   => g_bnf_pl_rec.rqd
            ,p_effective_date             => p_effective_date
            ,p_post_rslt_flag             => p_post_rslt_flag
            ,p_business_group_id          => p_business_group_id
            ,p_object_version_number      => l_object_version_number
            ,p_prtt_enrt_actn_id          => l_prtt_enrt_actn_id);
          --
          l_write_ctfn := true;
          --
          if l_nsc_ctfn_pl.ctrrl IS NOT NULL then
            --
            if l_rslt.oipl_id is not null then
              open c_opt;
              fetch c_opt into l_opt;
              close c_opt;
            end if;
            --
            l_outputs := benutils.formula
                           (p_formula_id     => l_nsc_ctfn_pl.ctrrl
                           ,p_pgm_id         => NULL
                           ,p_pl_id          => l_nsc_ctfn_pl.pl_id
                           ,p_pl_typ_id          => l_rslt.pl_typ_id
                           ,p_opt_id           => l_opt.opt_id
                           ,p_ler_id          => l_rslt.ler_id
                           ,p_business_group_id          => l_rslt.business_group_id
                           ,p_assignment_id          => l_asg.assignment_id
                           ,p_organization_id          => l_asg.organization_id
                           ,p_effective_date => p_effective_date);
            --
            if l_outputs(l_outputs.first).value <> 'Y' then
              l_write_ctfn := FALSE;
            end if;
            --
          end if;
          --
          if l_write_ctfn = TRUE then
            --
            write_new_bnf_ctfn_item
              (p_pl_bnf_id             => l_bnf_rec.pl_bnf_id
              ,p_prtt_enrt_actn_id     => l_prtt_enrt_actn_id
              ,p_bnf_ctfn_typ_cd       => l_nsc_ctfn_pl.ctcvgcd
              ,p_bnf_ctfn_rqd_flag     => l_nsc_ctfn_pl.ctflag
              ,p_effective_date        => p_effective_date
              ,p_business_group_id     => p_business_group_id
              ,p_object_version_number => l_object_version_number
              ,p_pl_bnf_ctfn_prvdd_id  => l_prtt_enrt_ctfn_prvdd_id);
            --
          end if; -- write_ctfn
          --
        end if;  -- prtt_enrt_actn_id
        --
      end loop; -- inner loop
      --
      if l_prtt_enrt_actn_id IS NOT NULL then
        --
        -- A BNFSCCTFN action item was written in an earlier run. Check if the
        -- NSC ctfn has been provided and if yes, close the action item.
        --
        if g_debug then
          hr_utility.set_location('BNFSCCTFN actn item found', 10);
        end if;
        --
        open c_nsc_prvdd(l_bnf_rec.pl_bnf_id);
        fetch c_nsc_prvdd into l_dummy;
        --
        if c_nsc_prvdd%found then
          --
          -- Ctfn provided. Close action item.
          --
          if g_debug then
            hr_utility.set_location('SCCTFN provided. Close actn item.', 10);
          end if;
          --
          set_cmpltd_dt
            (p_prtt_enrt_actn_id          => l_prtt_enrt_actn_id
            ,p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
            ,p_rslt_object_version_number => p_rslt_object_version_number
            ,p_actn_typ_id                => l_actn_typ_id
            ,p_rqd_flag                   => g_bnf_pl_rec.rqd
            ,p_effective_date             => p_effective_date
            ,p_post_rslt_flag             => p_post_rslt_flag
            ,p_business_group_id          => p_business_group_id
            ,p_object_version_number      => l_object_version_number
            ,p_open_close                 => 'CLOSE'
            ,p_datetrack_mode             => p_datetrack_mode);
          --
        else
          --
          -- Ctfn not provided. Open action item if already closed.
          --
          if g_debug then
            hr_utility.set_location('CTFN not prvdd. Open actn item.', 10);
          end if;
          --
          if l_cmpltd_dt is null then
            set_cmpltd_dt
              (p_prtt_enrt_actn_id          => l_prtt_enrt_actn_id
              ,p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
              ,p_rslt_object_version_number => p_rslt_object_version_number
              ,p_actn_typ_id                => l_actn_typ_id
              ,p_rqd_flag                   => g_bnf_pl_rec.rqd
              ,p_effective_date             => p_effective_date
              ,p_post_rslt_flag             => p_post_rslt_flag
              ,p_business_group_id          => p_business_group_id
              ,p_object_version_number      => l_object_version_number
              ,p_open_close                 => 'OPEN'
              ,p_datetrack_mode             => p_datetrack_mode);
            --
          end if;
          --
        end if;
        --
        close c_nsc_prvdd;
        --
      end if; -- prtt_enrt_actn_id
      --
    end if; -- contact type <> 'S'
    --
  end loop; -- outer loop
  --
  if g_debug then
    hr_utility.set_location ('Leaving ' ||l_proc,10);
  end if;
  --
exception
  when others then
    if g_debug then
      hr_utility.set_location('Exception Raised '||l_proc, 10);
    end if;
    p_rslt_object_version_number :=l_rslt_object_version_number ;
    p_bnf_actn_warning           :=l_bnf_actn_warning ;
    raise;
--
end determine_additional_bnf;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< process_bnf_actn_items >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure process_bnf_actn_items
  (p_prtt_enrt_rslt_id          in     number
  ,p_effective_date             in     date
  ,p_business_group_id          in     number
  ,p_validate                   in     boolean  default FALSE
  ,p_datetrack_mode             in     varchar2 default hr_api.g_correction
  ,p_post_rslt_flag             in     varchar2 default 'Y'
  ,p_rslt_object_version_number in out nocopy number
  ,p_suspend_flag               in out nocopy varchar2
  ,p_bnf_actn_warning              out nocopy boolean) is
  --
  l_proc varchar2(80) ;
  --
  l_bnf_actn_item_open boolean := FALSE;
  l_bnf_actn_warning boolean := FALSE;
  l_hack varchar2(1) := 'N';

  l_rslt_object_version_number  number(15);
  l_suspend_flag                varchar2(20);

  --
begin
  --
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_proc  := g_package || '.process_bnf_actn_items';
    hr_utility.set_location ('Entering '||l_proc,10);
  end if;
  --

  l_rslt_object_version_number:= p_rslt_object_version_number ;
  l_suspend_flag              := p_suspend_flag ;

  --
  savepoint process_bnf_actn_items;
  --
  determine_bnf_actn_items
    (p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
    ,p_rslt_object_version_number => p_rslt_object_version_number
    ,p_effective_date             => p_effective_date
    ,p_business_group_id          => p_business_group_id
    ,p_datetrack_mode             => p_datetrack_mode
    ,p_post_rslt_flag             => p_post_rslt_flag
    ,p_bnf_actn_item_open         => l_bnf_actn_item_open
    ,p_hack                       => l_hack);
  --
  if l_bnf_actn_item_open = FALSE then
    --
    -- A BNF actn item was not written by the previous procedure. i.e. bnf's are
    -- designated. Determine missing bnf information
    --
    determine_bnf_miss_actn_items
      (p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
      ,p_rslt_object_version_number => p_rslt_object_version_number
      ,p_effective_date             => p_effective_date
      ,p_business_group_id          => p_business_group_id
      ,p_datetrack_mode             => p_datetrack_mode
      ,p_post_rslt_flag             => p_post_rslt_flag
      ,p_bnf_actn_warning           => l_bnf_actn_warning);
    --
    determine_additional_bnf
      (p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
      ,p_rslt_object_version_number => p_rslt_object_version_number
      ,p_effective_date             => p_effective_date
      ,p_business_group_id          => p_business_group_id
      ,p_datetrack_mode             => p_datetrack_mode
      ,p_post_rslt_flag             => p_post_rslt_flag
      ,p_bnf_actn_warning           => l_bnf_actn_warning);
    --
  else
    --
    -- l_bnf_actn_item_open is TRUE. Set the l_bnf_actn_warning flag.
    --
    if l_hack = 'Y' then
      -- This indicates that the l_bnf_actn_item_open was set to TRUE only to
      -- fool this process to not check for bnf missing items  and no
      -- BNF action item was written. Set the l_dpnt_actn_warning to FALSE
      --
      l_bnf_actn_warning := FALSE;
      --
    else
      --
      -- A BNF actn item was actually written. Set the flag to TRUE.
      --
      l_bnf_actn_warning := TRUE;
      --
    end if;
    --
  end if;
  --
  p_bnf_actn_warning := l_bnf_actn_warning;
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  if g_debug then
    hr_utility.set_location ('Leaving '||l_proc, 10);
  end if;
  --
exception
  --
  when hr_api.validate_enabled
  then
    --
    rollback to process_bnf_actn_items;
    if g_debug then
      hr_utility.set_location ('Leaving '||l_proc, 10);
    end if;
  --
  when others then
    if g_debug then
      hr_utility.set_location('Exception Raised '||l_proc, 10);
    end if;

    p_rslt_object_version_number :=l_rslt_object_version_number ;
    p_suspend_flag               :=l_suspend_flag ;
    p_bnf_actn_warning           :=null;

    raise;
--
end process_bnf_actn_items;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< determine_action_items >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure determine_action_items
  (p_prtt_enrt_rslt_id          in     number
  ,p_effective_date             in     date
  ,p_business_group_id          in     number
  ,p_validate                   in     boolean  default false
  ,p_enrt_bnft_id               in     number   default null
  ,p_datetrack_mode             in     varchar2 default hr_api.g_correction
  ,p_post_rslt_flag             in     varchar2 default 'Y'
  ,p_rslt_object_version_number in out nocopy number
  ,p_suspend_flag                  out nocopy varchar2
  ,p_dpnt_actn_warning             out nocopy boolean
  ,p_bnf_actn_warning              out nocopy boolean
  ,p_ctfn_actn_warning             out nocopy boolean
  ) is
  --
  -- this procedure is the main driver/entry point for action items
  -- determines if designated dependents and benficiaries meet all the criteria
  -- for PL, PGM, and PTIP where necessary.
  --
  l_proc     varchar2(80) ;
  --
  l_suspend_flag varchar2(30) := 'N';
  l_dpnt_actn_warning boolean := FALSE;
  l_bnf_actn_warning  boolean := FALSE;
  l_ctfn_actn_warning boolean := FALSE;

  --Bug 4525608 New variable to handle the case when dependent details are
  -- provided and plan level certification has not been furnished
  -- this flag will be set when plan certification is not provided
  -- and dependent details are provided
  l_ctfn_actn_warning_o boolean := FALSE;
  --End Bug 4525608


  l_pcp_actn_warning boolean := FALSE;
  l_pcp_dpnt_actn_warning boolean := FALSE;
  l_pln_name  ben_pl_f.name%type; -- UTF8 Change Bug 2254683
  l_person_id per_all_people_f.person_id%type;
  l_rslt_object_version_number  number(15);

  --
  -- Bug : 1857685
  --
  l_waive_flag varchar2(2) := 'N';
  l_pl_id ben_pl_f.pl_id%type;
  l_oipl_id ben_oipl_f.oipl_id%type;
  l_comp_lvl_cd ben_prtt_enrt_rslt_f.comp_lvl_cd%type;

  --
  cursor c_waive_info_flag is
  select pen.pl_id, pen.oipl_id,pen.sspndd_flag --Bug 2228123 added sspndd_flag
  from ben_prtt_enrt_rslt_f pen
  where pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
  and pen.business_group_id = p_business_group_id
  and p_effective_date between pen.effective_start_date
  and pen.effective_end_date;
  --
  -- Bug 1857685 : Do not create dependents and beneficiaries for
  -- Waive plans and options
  --
  cursor c_waive_pl_flag is
    select pln.invk_dcln_prtn_pl_flag
    from ben_pl_f pln
    where pln.pl_id = l_pl_id
      and p_effective_date between
          pln.effective_start_date and pln.effective_end_date;
  --
  -- Bug : 1857685
  --
  cursor c_waive_opt_flag is
    select invk_wv_opt_flag
    from ben_opt_f opt,
         ben_oipl_f oipl
    where opt.opt_id = oipl.opt_id
      and oipl.oipl_id = l_oipl_id
      and p_effective_date between
          opt.effective_start_date and opt.effective_end_date
      and p_effective_date between
          oipl.effective_start_date and oipl.effective_end_date;
  --
  cursor c_info_for_msg is
  select pen.person_id,
  pln.name
  from ben_prtt_enrt_rslt_f pen
  ,ben_pl_f pln
  where pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
  and pen.pl_id= pln.pl_id
  and pen.business_group_id = p_business_group_id
  and pln.business_group_id = p_business_group_id
  and p_effective_date between pen.effective_start_date
  and pen.effective_end_date
  and p_effective_date between pln.effective_start_date
  and pln.effective_end_date;

  l_message1   fnd_new_messages.message_name%type := 'BEN_92596_PRTTPCP_ERR';
  l_message2   fnd_new_messages.message_name%type := 'BEN_92597_DPNTPCP_ERR';
  --
  /*
  --BUG 3042379 Don't create action items for the interim
  --enrollment.
  cursor c_interim is
    select 'x'
    from   ben_prtt_enrt_rslt_f pen
    where  pen.rplcs_sspndd_rslt_id = p_prtt_enrt_rslt_id
    and    p_effective_date between pen.effective_start_date
                                and pen.effective_end_date
    and    pen.prtt_enrt_rslt_stat_cd is null ;
  */
  --
  l_dummy      varchar2(30);
  l_interim    boolean := false ;
  --
begin
--
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_proc      := g_package||'.determine_action_items';
    hr_utility.set_location ('Entering '||l_proc,10);
  end if;
  --
  l_rslt_object_version_number  :=p_rslt_object_version_number ;


  -- Issue a savepoint if operating in validation only mode
  --
  savepoint detemine_action_items;
  --BUG 3042379 Don't create action items for the interim
  --enrollment
  /*
  open c_interim;
    fetch c_interim into l_dummy;
    if c_interim%found then
      --
      l_interim := true ;
      --
    end if;
  close c_interim ;
  */
  --
  --Bug 4422667 The above commented condition doesnot work some times.
  --
  if ben_sspndd_enrollment.g_interim_flag = 'Y' then
    --
    l_interim := true;
    --
  end if;
  --
  -- Bug : 185768
  --
  if p_prtt_enrt_rslt_id is not null then
     open c_waive_info_flag;
     fetch c_waive_info_flag into l_pl_id, l_oipl_id,l_suspend_flag ; --Bug 2228123;
     close c_waive_info_flag;
  end if;
  --
  if l_oipl_id is null then
     --
     open c_waive_pl_flag;
     fetch c_waive_pl_flag into l_waive_flag;
     close c_waive_pl_flag;
     --
  else
     --
     open c_waive_opt_flag;
     fetch c_waive_opt_flag into l_waive_flag;
     close c_waive_opt_flag;

     if g_debug then
       hr_utility.set_location ('waive_flag = '||l_waive_flag,9);
     end if;

     --
    -- un comment the following code 3771346 /*
     if nvl(l_waive_flag, 'N') = 'N' then
       --
       -- Check at plan level.
       --
       open c_waive_pl_flag;
       fetch c_waive_pl_flag into l_waive_flag;
       close c_waive_pl_flag;
       --
     end if;
    --end 3771346 */
  end if;

  if g_debug then
    hr_utility.set_location ('waive_flag = '||l_waive_flag,10);
  end if;
  --BUG 3042379 We don't need to process the action items for the
  --interim enrollment.

  --
  -- Dependents
  --
  --  Bug : 185768
  -- If result is associated with waive plan or option do not create
  -- dependent or beneficiary action items.
  --
  -- BUG 3042379 Don't create action items for the interim
  if not l_interim then
  -- BUG 3042379 Don't create action items for the interim
    --
    if nvl(l_waive_flag, 'N') = 'N' then
      --
      process_dpnt_actn_items
        (p_validate                   => FALSE
        ,p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
        ,p_effective_date             => p_effective_date
        ,p_business_group_id          => p_business_group_id
        ,p_datetrack_mode             => p_datetrack_mode
        ,p_post_rslt_flag             => p_post_rslt_flag
        ,p_rslt_object_version_number => p_rslt_object_version_number
        ,p_suspend_flag               => l_suspend_flag
        ,p_dpnt_actn_warning          => l_dpnt_actn_warning
	  --Bug No 4525608 to capture the plan level certification required warning
        ,p_ctfn_actn_warning          => l_ctfn_actn_warning_o);
          -- End Bug 4525608
       --
       -- Beneficiaries
       --
       process_bnf_actn_items
         (p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
         ,p_effective_date             => p_effective_date
         ,p_business_group_id          => p_business_group_id
         ,p_validate                   => FALSE
         ,p_datetrack_mode             => p_datetrack_mode
         ,p_post_rslt_flag             => p_post_rslt_flag
         ,p_rslt_object_version_number => p_rslt_object_version_number
         ,p_suspend_flag               => l_suspend_flag
         ,p_bnf_actn_warning           => l_bnf_actn_warning);
       --
       process_pcp_actn_items
         (p_validate                   => FALSE
         ,p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
         ,p_effective_date             => p_effective_date
         ,p_business_group_id          => p_business_group_id
         ,p_datetrack_mode             => p_datetrack_mode
         ,p_post_rslt_flag             => p_post_rslt_flag
         ,p_rslt_object_version_number => p_rslt_object_version_number
         ,p_suspend_flag               => l_suspend_flag
         ,p_pcp_actn_warning           => l_pcp_actn_warning);
       --
       process_pcp_dpnt_actn_items
         (p_validate                   => FALSE
         ,p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
         ,p_effective_date             => p_effective_date
         ,p_business_group_id          => p_business_group_id
         ,p_datetrack_mode             => p_datetrack_mode
         ,p_post_rslt_flag             => p_post_rslt_flag
         ,p_rslt_object_version_number => p_rslt_object_version_number
         ,p_suspend_flag               => l_suspend_flag
         ,p_pcp_dpnt_actn_warning      => l_pcp_dpnt_actn_warning);
       --
  end if;
  --
  -- Determine all other enrollment action items that need writing
  --
  determine_other_actn_items
     (p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
     ,p_rslt_object_version_number => p_rslt_object_version_number
     ,p_effective_date             => p_effective_date
     ,p_post_rslt_flag             => p_post_rslt_flag
     ,p_business_group_id          => p_business_group_id
     ,p_validate                   => FALSE
     ,p_enrt_bnft_id               => p_enrt_bnft_id
     ,p_datetrack_mode             => p_datetrack_mode
     ,p_suspend_flag               => l_suspend_flag
     ,p_ctfn_actn_warning          => l_ctfn_actn_warning);

   --
  --
    -- Added by Anil --
    --
    /*fnd_file.put_line(fnd_file.log,'-->cwb_actn process_cwb_actn_items with the following parameters');
    fnd_file.put_line(fnd_file.log,'-->cwb_actn p_prtt_enrt_rslt_id '||p_prtt_enrt_rslt_id);
    fnd_file.put_line(fnd_file.log,'-->cwb_actn p_effective_date    '||p_effective_date);
    fnd_file.put_line(fnd_file.log,'-->cwb_actn p_business_group_id '||p_business_group_id );
    fnd_file.put_line(fnd_file.log,'-->cwb_actn p_datetrack_mode    '||p_datetrack_mode);
    fnd_file.put_line(fnd_file.log,'-->cwb_actn p_post_rslt_flag    '||p_post_rslt_flag);
    fnd_file.put_line(fnd_file.log,'-->cwb_actn p_rslt_object_version_number'||p_rslt_object_version_number);
    fnd_file.put_line(fnd_file.log,'-->cwb_actn l_suspend_flag      '||l_suspend_flag);
    fnd_file.put_line(fnd_file.log,'---------------------------------------------------------------------------');*/
    --
    process_cwb_actn_items
      (p_validate                   => FALSE
      ,p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
      ,p_effective_date             => p_effective_date
      ,p_business_group_id          => p_business_group_id
      ,p_datetrack_mode             => p_datetrack_mode
      ,p_post_rslt_flag             => p_post_rslt_flag
      ,p_rslt_object_version_number => p_rslt_object_version_number
      ,p_suspend_flag               => l_suspend_flag);
  --
  -- BUG 3042379 Don't create action items for the interim
  else
    if g_debug then
      hr_utility.set_location ('Interim Enrt- No action item created PEN '||p_prtt_enrt_rslt_id,110);
    end if;
  end if ;
  -- BUG 3042379 Don't create action items for the interim
  --
  -- Set the warning flags
  --
  p_bnf_actn_warning := l_bnf_actn_warning;
  p_dpnt_actn_warning := l_dpnt_actn_warning;

-- Bug 4525608 set the certification required flag if any of the
-- flags is true
  if l_ctfn_actn_warning or l_ctfn_actn_warning_o then
  p_ctfn_actn_warning := TRUE;
  end if;
-- End Bug 4525608


  if l_pcp_actn_warning or l_pcp_dpnt_actn_warning then

     if p_prtt_enrt_rslt_id is not null then
             open c_info_for_msg;
             fetch c_info_for_msg into l_person_id,l_pln_name;
             close c_info_for_msg;
     end if;

  end if;
  --
  l_pln_name    := substr(l_pln_name,1,60);
  if l_pcp_actn_warning then
     ben_warnings.load_warning
        (p_application_short_name  => 'BEN',
        p_message_name            => l_message1,
        p_parma     => l_pln_name,
        p_person_id => l_person_id);
  end if;
  --
  if l_pcp_dpnt_actn_warning then
     ben_warnings.load_warning
        (p_application_short_name  => 'BEN',
        p_message_name            => l_message2,
        p_parma     => l_pln_name,
        p_person_id => l_person_id);
  end if;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
     raise hr_api.validate_enabled;
  end if;
  --
  p_suspend_flag := l_suspend_flag;
  --
  if g_debug then
    hr_utility.set_location ('Leaving ' ||l_proc,10);
  end if;
  --
exception
  --
  when hr_api.validate_enabled
  then
    -- rollback to the savepoint
    --
    ROLLBACK TO determine_action_items;
  --
  when others then
    if g_debug then
      hr_utility.set_location('Exception Raised '||l_proc, 10);
    end if;
    p_rslt_object_version_number :=l_rslt_object_version_number ;
    p_suspend_flag               :=l_suspend_flag ;
    p_ctfn_actn_warning          := null ;

    p_dpnt_actn_warning          := null;
    p_bnf_actn_warning           := null;
    p_ctfn_actn_warning          := null;
    --
    raise; -- Bug 3105160
    --
end determine_action_items;
--
end ben_enrollment_action_items;

/
