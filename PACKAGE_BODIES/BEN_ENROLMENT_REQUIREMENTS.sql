--------------------------------------------------------
--  DDL for Package Body BEN_ENROLMENT_REQUIREMENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ENROLMENT_REQUIREMENTS" AS
/* $Header: bendenrr.pkb 120.24.12010000.6 2009/09/24 12:24:43 sallumwa ship $ */
-------------------------------------------------------------------------------
/*
+=============================================================================+
|                       Copyright (c) 1998 Oracle Corporation                 |
|                          Redwood Shores, California, USA                    |
|                               All rights reserved.                          |
+=============================================================================+
--
Name
  Determine Enrolment Requirements
Purpose
  This package is used to create enrolment choice entries for all choices
  which a person may elect.
History
     Date       Who          Version   What?
     ----       ---          -------   -----
     18 Mar 98  jcarpent     110.0     Created
     05 Jun 98  jcarpent     110.1     Compensated for null pl_id
     06 Jun 98  jcarpent     110.2     Changed order of heirarchy for date cd
                                       Save pl_typ_cd in epe.
     08 Jun 98  jcarpent     110.3     Changed default_flag processing
                                       added new dflt_enrt_cd code hanlers
     09 Jun 98  thayden      110.4     Added batch who columns.
     10 Jun 98  jcarpent     110.5     Changed rule execution routines
     11 Jun 98  jcarpent     110.6     Fixed wrong error messag for rt_strt_dt
     17 Jun 98  jcarpent     110.7     Some business_group_id checks added
     29 Jun 98  jcarpent     110.8     Check invk_imptd/flxcr flag
                                       nvl on dys_aftr_end_to_dflt
                                       nvl on addit_procg_dys_num
                                       Changed tco_chg_enrt to check enrt
     01 Jul 98  jcarpent     110.9     Added return to determine
                                       erlst_deenrt_dt
     01 Jul 98  jcarpent     110.10    Changed enrt_cd handling for unenrolled
     08 Jul 98  jcarpent     110.11    Fixed pgm level sched enrt perd
                                       added p_popl_enrt_typ_cycl_id arg
     21 Jul 98  jcarpent     110.12    Added/changed some messages
     18 Aug 98  jcarpent     110.13    Put in substr on write calls
     27 Aug 98  G Perry      115.12    Formatted and used values from benmngle
                                       global structures
     27 Aug 98  jcarpent     115.14    Create plan choice if elig and oipl
                                       created. If plan has oipls then
                                       create no choice.
     28 Aug 98  G Perry      115.15    Added use of global
                                       g_electable_choice_created to test when
                                       an electable choice has been created.
     22 Sep 98  jcarpent     115.16    added 'STRTD' restriction
     25 Sep 98  jcarpent     115.17    added ler_chg_ptip.
                                       look at ler_chc* for open enrt
                                       enrt_perd+lee_rsn passed to epe api
                                       handle plans in multiple programs
                                       removed rt_strt_dt form epe api call
     15 Oct 98  G Perry      115.21    Added in auto enrt stuff, corrected a
                                       few cursor bugs.
     15 Oct 98  G Perry      115.22    Defaulted mndtry_flag.
     16 Oct 98  jcarpent     115.23    Fixed auto_enrt_flag or oipls
     19 Oct 98  jcarpent     115.24    Use plip enrt info. Use pl.enrt_rl.
                                       Provide acty_ref_perd_cd/uom.
     20 Oct 98  jcarpent     115.25    default oipl_auto_flag to 'N'
     21 Oct 98  jcarpent     115.26    Added l_rec_auto_enrt_flag
                                       Support for unrestricted enrt.
                                       Removed all rt_strt_dt logic.
                                       use enrt_perd_for_pl_f for csd calc.
     28 Oct 98  jcarpent     115.27    Set l_rec_cls_enrt_dt_to_use_cd
                                       Check pgm_id on all ben_elig_per_f sql
     28 Oct 98  G Perry      115.28    Fixed all ben_elig_per_f references in
                                       cursors as they were all ropey.
     30 Oct 98  G Perry      115.30    Fixed how parameter
                                       popl_enrt_typ_cycl_id works to support
                                       multiple scheduled enrollment.
     12 Dec 98  jcarpent     115.31    Create epe when dependent change
                                       allowed.  Changed all pen cursors to
                                       check csd+ced
     15 Dec 98  G Perry      115.32    Added in call to electbl choice
                                       reporting stuff for the audit log.
     18 Dec 98  jcarpent     115.33    Changed ler_chg_enrt heirarchy.
     20 Dec 98  G Perry      115.34    Plan electablce cache entry no longer
                                       contains option details.
     23 Dec 98  jcarpent     115.35    Handle overridden results.
                                       Fixed c_oipl_enrolment_info cursor
                                       to check cvg dates.
                                       Changed default enrt cd processing
     04 Jan 99  jcarpent     115.36    Return value for all functions.
     14 Jan 99  jcarpent     115.37    Use current enrt_cvg_strt_dt if !null
     18 Jan 99  G Perry      115.38    LED V ED
     27 Jan 99  jcarpent     115.39    Changed erlst_deenrt_dt logic.
     03 Feb 99  jcarpent     115.40    Support for Level jumping restrictions
                                       Get erlst_deenrt_dt from opt,pl,oipl too
     25 Mar 99  jcarpent     115.42    Added assignment_id to rule contexts
     01 Apr 99  jcarpent     115.43    Remove exit point when currently enrd,
                                       no dpnt chg allowed, not electable.
     09 Apr 99  stee         115.44    Change ben_per_in_ler_f to
                                       ben_per_in_ler.
     28 Apr 99  shdas	     115.45    Added more contexts in rule calls.
     28 Apr 99  jcarpent     115.46    When no lee_rsn exists exist don't error
                                       exit without creating choice.
     28 Apr 99  jcarpent     115.47    Init perd_for_pgm_found to 'N'
     29 Apr 99  lmcdonal     115.48    prtt_enrt_rslt now has a status code.
     04 May 99  shdas	     115.49    Added jurisdiction code.
     06 May 99  jcarpent     115.50    Fork off version 115.39 to do below chg
     06 May 99  jcarpent     115.51    Call new hashing procedure
     07 May 99  jcarpent     115.52    Pass greater(elig_strt_dt,lf_evt_oc_dt)
                                       into start date routines.
     11 May 99  jcarpent     115.53    Made all lf_evt_ocrd_dt change.
     20 May 99  jcarpent     115.54    Backed out nocopy lf_evt chg for enrollment.
                                       because eff dates based on eff dt.
     21 May 99  jcarpent     115.55    Error if cls_enrt_dt_to_use_cd is null
                                       fix assignment messages.
     24 May 99  jcarpent     115.56    Make sure comp objects exist as of
                                       enrt_perd_strt_dt.  Pgm,pl_typ,pl,opt,
                                       oipl,plip,ptip,lee_rsn,ler.
     24 Jun 99  maagrawa     115.57    invk_imptd_incm_pl_flag changed to
                                       imptd_incm_calc_cd.
     24 Jun 99  maagrawa     115.57    invk_imptd_incm_pl_flag changed to
                                       imptd_incm_calc_cd.
     05 Jul 99  stee         115.58    COBRA changes.  Check for coverage
                                       in a plan when evaluating enrollment
                                       code.  Also evaluate the
                                       cvg_incr_r_decr_only_code at the plip
                                       level.
     12 Jul 99  jcarpent     115.59    Added checks for backed out nocopy pil.
     12 Jul 99  moyes        115.60  - Added trace messages.
                                     - Removed + 0s from all cursors.
     20-JUL-99  Gperry       115.61    genutils -> benutils package rename.
     21-JUL-99  mhoyes       115.62  - Added trace messages.
     30-JUL-99  mhoyes       115.63  - Added trace messages.
     02-Aug-99  tguy         115.64    Added spouse and dependent for imputed
                                       incomes.
     04-Aug-99  jcarpent     115.65  - Fixed level jumping signs
     10-Aug-99  tmathers     115.66  - Fixed formula returning date
                                       code.
     23-Aug-99  shdas        115.67  - Added codes for pl_ordr_num,plip_ordr_num,
                                       ptip_ordr_num,oipl_ordr_num.
     31-Aug-99  jcarpent     115.68  - Update to look at ptip enrollment cols.
                                       Use new ler_chg_pgm_enrt_f table.
                                       Added dflt_enrt_cd/rl hierarchy.
     07-Sep-99  tguy         115.69    fixed call to pay_mag_util
     09-Sep-99  jcarpent     115.70  - Turn off auto flag for plan choices
                                       created due to auto oipl.
     09-Sep-99  stee         115.71  - Add new cvg_incr_r_decr_only codes
                                       MNAVLO and MXAVLO.
     21-Sep-99  jcarpent     115.72  - Added dflt_enrt_cds nncsedr, ndcsedr
     22-Sep-99  jcarpent     115.73  - Changed calls to auto_enrt_(mthd)_rl
                                       Combined calls for ler_chg and non-ler
                                       chg to call determine_enrolment once.
     23-Sep-99  jcarpent     115.74  - Renamed l_enrt_rl to l_ler_enrt_rl.
     24-Sep-99  jcarpent     115.75  - Changed auto_enrt_cd/flag processing.
                                       Consolidated *electable_flag variables
                                       and parameters to be more consistent.
     25-Sep-99  stee         115.76  - Added pgm_typ_cd to elctbl_chc_api.
     01-Oct-99  tguy         115.77  - Fixed level jumping issues
     01-Oct-99  jcarpent     115.78  - Added oipl.enrt_cd/rl
     03-Oct-99  tguy         115.79  - New fixes to level jumping.
     06-Oct-99  tguy         115.80  - added new checks for level jumping.
     14-Oct-99  jcarpent     115.81  - Allow enrt_cd to control elctbl_flag
                                       for automatic enrollments.
     19-Oct-99  pbodla       115.82  - At Level : Period for program found
                                       in call to ben_determine_date.main
                                       l_pgme_enrt_perd_end_dt_rl is modified
                                       to l_pgme_enrt_perd_strt_dt_rl
     26-Oct-99  maagrawa     115.83  - Level jumping fixed for persons, who
                                       are not previously enrolled. i.e. when
                                       enrd_ordr_num is null.
     02-Nov-99  maagrawa     115.84  - Level jumping restrictions removed at
                                       plip level.
     12-Nov-99  mhoyes       115.85  - Fixed bug 3630. Invalid number problem
                                       in cursor c_ler_chg_enrt_info.
     16-Nov-99  jcarpent     115.86  - Changed c_ler_chg_enrt_info again
                                       problem was with decode for dflt_enrt_rl
                                     - Also Added determine_dflt_enrt_cd
                                     - Also added new global
                                     - Fixed auto enrt rule execution.
                                       was never running auto enrt rule.
     03-Dec-99 lmcdonal      115.87    stl_elig...flag was being passed
                                       incorrectly to determine_enrollment.
     08-Dec-99 jcarpent      115.88  - Change hierarchy for enrt_mthd_cd/rl.
                                     - Fix oipl enrt_cd bug. Rl overwrote cd.
     01-Jan-00 pbodla        115.89  - Automatic enrollment rule is executed,
                                       even if the enrt_mthd_cd is null.
     05-Jan-00 jcarpent      115.90  - Added procs find_rqd_perd_enrt and
                                       find_enrt_at_same_level
     13-Jan-00 shdas         115.91  - added code so that choices for flx and
                                       imptd inc plans are created irrespective
                                       of whether they are configured  to be
                                       electable for each life event or not.
     21-Jan-00 pbodla        115.92  - p_elig-per_id is added to
                                       execute_enrt_rule, determine_enrolment
                                       and passes to benutils.formula
     05-Jan-00 maagrawa      115.93  - Get the auto enrollment flag from oipl's
                                       ler record, if availabe (Bug 4290).
                                     - If the choice is automatic, it cannot
                                       be default. (Bug 1175262).
     07-Jan-00 jcarpent      115.94  - Subtract 1 day from date when checking
                                       prev enrollment for tco-chg logic.
                                       (bug 1120686/4145)
     15-Feb-00 jcarpent      115.95  - Subtract 1 day from all enrollment chks
                                     - Added plip level jumping restrictsions
                                       back in. (bug 1146785/4153)
     07-Mar-00 jcarpent      115.96  - De-enroll if "Lose only". bug 1217196
     16-Mar-00 stee          115.97  - Remove program restriction if
                                       cvg_incr_r_decr_only_cd is specified at
                                       the plip level.
     23-Mar-00 jcarpent      115.98  - Fix enrt_mthd_rule use.  Removed
                                       l_auto_enrt_rl (use l_ler_auto_enrt_rl)
                                       Bug 1246785/4922.
     29-Mar-00  lmcdonal   115.66    Bug 1247115 - do not subtract 1 from
                                          life event ocrd dt when looking for
                                          esd/eed.  Only when looking for cvg
                                          strt/end dates.  Did this to all
                                          cursors that had the -1 except those
                                          looking at elig_per tables.
     06-Apr-00  mmogel       115.100 - Added tokens to message calls to make
                                       the messages more meaningful to the user
     11-Apr-00  maagrawa     115.101 - Start the enrollment period on the
                                       effective date if there is an conflicting
                                       life event between the enrollment period
                                       start date and the effective date.
                                       Bug 4988.
     18-Apr-00  maagrawa     115.102   Backport to 115.100
     18-Apr-00  lmcdonal     115.103   Fido Bug 6176:  When looking for current
                                       enrollments, no longer look for
                                       nvl(lf_evt_orcd_dt, eff dt) between esd and eed
                                       instead look for eed = eot.
     20-Apr-00  mhoyes       115.104 - Added profiling messages.
     03-May-00  pbodla       115.105 - Task 131 : execute_enrt_rule modified
                                     - If elig dependent rows are already created
                                       then pass the elig dependent id as input
                                       values to rule.
     12-May-00  mhoyes       115.106 - Added profiling messages.
     13-May-00  jcarpent     115.107 - Modified enrt_perd_strt_dt logic for
                                       reinstated le's (4988,1269016)
     15-May-00  mhoyes       115.108 - Called create EPE performance cover.
     16-May-00  mhoyes       115.109 - Added profiling messages.
     18-May-00  jcarpent     115.110 - Modified c_get_latest_procd_dt to
                                       ignore backed out nocopy pils (4988,1269016)
     23-May-00  mhoyes       115.113 - General tuning of SQL by dharris.
                                     - Added p_comp_obj_tree_row to
                                       enrolment_requirements.
     24-May-00  mhoyes       115.114 - Added/removed trace messages.
                                     - Enabled cache mode for rates_and_coverage
                                       dates. This caches the per in ler.
     25-May-00  jcarpent     115.115 - Added logic to have crnt_enrt_prclds_chg
                                       work for entire ptip. (5216,1308627)
     29-May-00  mhoyes       115.116 - Commented out nocopy hr_utility calls for
                                       performance in highly executed logic.
                                     - Tuning by dharris.
     31-May-00  mhoyes       115.117 - Passed through current comp object
                                       row parameters to avoid cache calls.
                                     - Passed comp object rows to
                                       rate_and_coverage_dates to avoid cursor
                                       executions.
     09-Jun-00  pbodla       115.118 - Bug 5272 : A fix to cursors
                                       c_sched_enrol_period_for_plan,
                                       c_sched_enrol_period_for_pgm in version
                                       115.113 caused this bug. These cursors
                                       are fixed.
     23-Jun-00  pbodla       115.119 - Fix to check enrollment results as
                                       of the life event occurred date instead
                                       of life event occurred -1 when
                                       determining the default flag. Bug 5241.
     28-Jun-00  shdas        115.120 - Added procedure execute_auto_dflt_enrt_rule.
     28-Jun-00  jcarpent     115.121 - Bug 4936: Use new cvg_strt_dt if sched
                                       enrt and plan is for 125 or 129
                                       regulation.
     29-Jun-00  mhoyes       115.122 - Reworked cursors c_nenrt and c_pl_bnft_rstrn
                                       as PLSQL.
     30-Jun-00  mhoyes       115.123 - Fired cursor c_nenrt when context parameters
                                       are not set.
     05-Jul-00  mhoyes       115.124 - Added context parameters.
     13-Jul-00  mhoyes       115.125 - Removed context parameters.
     19-Jul-00  jcarpent     115.126 - 5241,1343362. Added update_defaults
     03-Aug-00  jcarpent     115.127 - 5429. Fixed reinstate dependent logic.
     04-Aug-00  pbodla       115.128 - 4871(1255493) : After mndtry_rl executed
                                       it's out nocopy put is not used.
     31-Aug-00  jcarpent     115.129 - Comp object changes were causing
                                       non-date effective error.  Added
                                       requery logic.  WWbug 1394507.
     05-sep-00  pbodla       115.130 - Bug 5422 : Allow different enrollment periods
                                       for programs for a scheduled  enrollment.
                                       p_popl_enrt_typ_cycl_id is removed.
     14-Sep-00  jcarpent     115.131 - Leapfrog version based on 115.129.
                                       Bug 1401098.  Added logic to update_
                                       defaults to change elctbl_flag also.
                                       Needed for rules which use enrol/elig
                                       in other plans for electablility.
     14-Sep-00  jcarpent     115.132 - Merged version of 115.131 with 130.
     25-Sep-00  mhoyes       115.133 - Removed hr_utility.set_locations.
     07-Nov-00  mhoyes       115.134 - Added hr_utility.set_locations for
                                       profiling.
                                     - Modified update_defaults to use the
                                       electable choice performance API.
    15-dec-00   tilak        115.135   bug: 1527086 early denenrollment date carried forward
                                       for future enrolment ,oipl_id condtion addded in cursor wich
                                       take the information ofexisting enrolment for OPT level
    04-jan-01   jcarpent     115.136 - Bug 1568555.  Removed +1 from enrt
                                       period logic.
    01-feb-01   kmahendr     115.137 - Bug 1621593 - If plan is savings and has options attached
                                       then previous enrollment is checked and prtt_enrt_rslt_id
                                       is assigned
    08-feb-01   tilak        115.138   find_enrt_at_same_level changed to return the correct row
                                       bug : 1620161
    26-feb-01   kmahendr     115.139 - unrestricted process changes - if future enrollments exists
                                       then treat it as not currently enrolled
    27-feb-01   thayden     115.140  - change unrestricted enrolment period end date to end of time.
    08-jun-01   kmahendr    115.141  - Bug#1811636 - For level jumping logical order number is used
                                       in place of database ordr_num
    08-jun-01   kmahendr    115.142  - Effective date condition added to cursor c_opt_level
    26-jul-01   ikasire     115.143    bug1895874 added new nip_dflt_flag to ben_pl_f table.
                                       In the internal procedure determine_dflt_enrt_cd
                                       added to parameters p_pgm_rec,p_ptip_rec,p_plip_rec,
                                       p_oipl_rec,p_pl_rec to get the data from the already
                                       cached records. Also removed the calls to ben_cobj_cache
                                       from internal determine_dflt_enrt_cd procedure as this
                                       can not be used here.
    27-aug-01  tilak        115.144   bug:1949361 jurisdiction code is
                                      derived inside benutils.formula.
    13-Nov-01  kmahendr     115.145   bug#2080856 - in determine_dflt_flag procedure, coverage is
                                      checked at ptip level if plan level fails.
    15-Nov-01  kmahendr     115.146   Bug#2080856 - if dflt_enrt_cd is null then default flag
                                      is set to 'N' - changed the assignment in determine_dflt_flag
    07-Dec-01  mhoyes       115.146  - Added p_per_in_ler_id to enrolment_requirements.
    11-Dec-01  mhoyes       115.147  - Added p_per_in_ler_id to update_defaults.
    18-Dec-01  kmahendr     115.148  - Comp. work bench changes
    19-Dec-01  kmahendr     115.149  - put the end if before elig_flag for p_run_mode = 'W'
    29-Dec-01  pbodla       115.152  - CWB Changes : Initialised package
                                       globals g_ple_hrchy_to_use_cd,
                                       g_ple_pos_structure_version_id
                                       to use later in benmngle.
    29-Dec-01  pbodla       115.153  - CWB Changes : hierarchy to use code
                                       lookup codes changed to match ones in
                                       seed115, extended C mode to W.
    03-Jan-02  rpillay      115.154  - Applied nvl function to all flag-type parameters
                                       passed in the call to create_perf_elig_per_elc_chc
                                       from enrolment_requirements Bug# 2141756
    04-jan-02  pbodla       115.155  - CWB Changes : hierarchy table is
                                       populated after epe row is created.
    11-Jan-02  ikasire      115.156    CWB Changes Bug 2172036 addition of new column
                                       assignment_id to epe table
    29-Jan-02  kmahendr     115.157    Bug#2108168 - Added a cursor c_ptip_waive_enrolment_info
                                       in the procedure - determine_enrollment to check for
                                       current enrollment in a waive plan
    12-feb-02  pbodla       115.158  - CWB Changes : 2213828 - No need to
                                       determine the enrt_perd_strt_dt,
                                       enrt_perd_end_dt if the mode is W.
    12-feb-02  pbodla       115.159  - CWB Changes : 2230922 : If ws manager id
                                       not found then default to supervisor if
                                       position heirarchy is used.
    27-Feb-02  rpillay      115.160  - CWB Bug 2241010 Made changes to set elctbl_flag
                                       and elig_flag to 'N' when person is ineligible
    01-Apr-02  ikasire      115.161    Bug 229032 if the enrollment starts in a future
                                       date, for unrestricted, user cannot get the enrollment
                                       record for correction causing problems.
    17-Apr-02  kmahendr     115.162    Bug#2328029 - previous eligibility must be arrived based
                                       on life event occurred date or effective date-changed
                                       l_effective_date_1 in enrollment_requirements and update
                                       default procedures.
    02-May-02  hnarayan     115.163    bug 2008871 - commented the return and included it
                                       inside the requery cursor if block
    				       since it affects positive cases of electability
    14-May-02  ikasire      115.164    Bug 2374403 electable choices for the imputed
                                       income type of spouse is not getting created
                                       properly. IMPTD_INCM_CALC_CD of SPSL is used
                                       instead of using SPS
    19-May-02  ikasire      115.165    Bug 2200139 Override Enrollment changes
    08-Jun-02  pabodla      115.164    Do not select the contingent worker
                                       assignment when assignment data is
                                       fetched.
    20-Jun-02  ikasire      115.167    Bug 2404008 fixed by passing lf_evt_ocrd_dt rather
                                       than p_effective_date to determine_dflt_enrt_cd call
    14-Jul-02  pbodla       115.168    ABSENCES - Added absences mode M.
                                       This mode is similar to mode L.
    05-Aug-02  mmudigon     115.169    ABSENCES - do not look at backed out nocopy and
                                       processed lers for determining enrollment
                                       period
   08-Aug-02  tjesumic      115.170    # 2500805 certain situation,where  2 option in same plan
                                       became defaulted if the coverage start date is not controlled
                                       Pls See the bug for the test case.
                                       cursors c_plan_enrolment_info,c_oipl_enrolment_info in
                                       procedure determine_dflt_flag validatd for cvg_strt_dt
   21-Aug-02  pbodla        115.171    Bug 2503570 - CWB electable flag always set Y
   29-Aug-02  kmahendr      115.172    Bug#2207956 - new enrollment code added and references
                                       to sec129 or 125 is removed.
   13-Sep-02  tjesumic      115.173    # 2534744  to fix the issue of defaulting past enrolled
                                       elected value  new retutn values introduced in formula
                                       AUTO_DFLT_ELCN_VAL in  execute_auto_dflt_enrt_rule
                                       formula type auto enrollment
                                       Which return elected value which is used by bencvrge to
                                       populated the default benefit
   28-Sep-02 pbodla         115.174    Bug 2600087 added order by clause to
                                       c_oipl_enrolment_info and c_plan_enrolment_info
   20-Oct-02  mhoyes        115.175  - Phased in call to ben_pep_cache.get_currpepepo_dets.
                                     - Phased out nocopy previous eligibility cursors and
                                       pointed to the previous eligibility cache.
   01-Nov-02  mmudigon      115.176  - CWB: Bug 2526595 Bypass creation of epe
                                       if trk_inelig is set to No and the person
                                       is not eligible
   01-Nov-02  tjesumic      115.177  - # 2542162 enrt_perd_strt_dt send  as param to the rule which
                                       Calculate the enrt_perd_end_dt
   01-Dec-02  pabodla       115.178  - Arcsing the file with CWB itemization code as commented.
   04-Dec-02  rpillay       115.179  - CWB: Bug 2684227 - If a position is vacant climb the
                                       position hierarchy till a person is found
   09-Dec-02  mmudigon      115.180  - CWB itemization code uncommented.
   16 Dec 02  hnarayan      115.181    Added NOCOPY hint
   27 Dec 02  ikasire       115.182    Bug 2677804 changes.for Override thru date
   03 Jan 03  tjesumic      115.183    bug # 2685018 if the formula return the result  id then
                                       the result id will be catcated wiht dpnt carry forawrd  to store
   07 Dec 03  tjesumic      115.184    New return value added in default enrollment formula 'PREV_PRTT_ENRT_RSLT_ID'
                                       This value  added to the value of CARRY_FORWARD_ELIG_DPNT for storage
   10 jan 03  pbodla        115.18?    GRADE/STEP : Added code to support
                                       grade step progression process.
   24-Feb-03  mmudigon      115.185  - CWB itemization : implement trk_inelig
                                       flag at oipl level
   12-Mar-03  ikasire       115.186    Bug 2827121 Contingent worker issue for
                                       cwb
   17-Mar-03  vsethi        115.187  - Bug 2650247 -passing the value for inelg_rsn_cd in call to
  				       elig per elctbl chc api
   10-Apr-03  rpgupta       115.188  - Bug 2746865
   				       Enrollment period window enhancement
   				       Changed the logic for arriving at the enrollment period start
   				       and end dates
   20-Jun-03  kmahendr      115.189  - Bug#2980560 - date passed to get_pilepo was changed to
                                       l_effective_date_1
   14-Jul-03  ikasire       115.190  - Bug 3044311 to get valid manager
                                       for cwb position hierarchy.
   11-Aug-03  ikasire       115.191    Bug 3058189 use l_lf_evt_ocrd_dt for the unrestricted cursors
                                       while getting the pen info.
   11-Aug-03  tjesumic      115.192    # 3086161 whne the LE reprocedd ,the Enrt Dt determined as of the
                                       Previous LE Processed Date. if the nerollment made on the same date
                                       the Exisiting results are updated in correction mode(same date).
                                       Whne the cirrent LE backedout the previous LE results are lost
                                       because the per_in_ler id updated in correction mode updated
                                       This is fixed : if the  max enrollment date is  higer than the
                                       max processed date then  max enrollment dt + 1 used for enrt_prd_strt_dt
   12-Aug-03  vsethi        115.193    Bug 3063867, Changed enrt_perd_strt_dt When a prior life event has been
   				       VOIDD, the enrollment period start date should not be set as the last
   				       backed out date instead retain the original enrt window.
   28-Aug-03  tjesumic      115.194    115.192 fix is reversed for # 3086161
   25-Sep-03  rpillay       115.195    GRADE/STEP: Changes to enrolment_requirements
                                       to not throw error for G mode when year periods
                                       are not set up
   07-oct-03  hmani         115.196    Bug 3137519 - Modified the c_get_latest_enrt_dt cursor
   21-oct-03  hmani         115.197    Bug 3177401 - Changed p_date_mandatory_flag to 'Y'
   28-Oct-03  tjesumic      115.198    #  2982606 when the coverage start date of the prev LE is in future
                                       and current LE is current or earlier than previous one
                                       create new result and set  currently enrolled flag to 'N'
                                       related changes in  benbolfe  , benelinf ,benleclr
   11-oct-03  hmani	    115.199    reversing the change done in 115.197. Changing the flag again.
   18-Nov-03  tjesumic      115.200    # 3248770 Voided per in ler is not considered to find the enrollment period date
   14-Jan-04  pbodla        115.201    GLOBALCWB : moved the heirarchy data
                                       population to benptnle (on to ben_per_in_ler)
   15-Mar-04  pbodla        115.202    GLOBALCWB : Bug 3502094  : For FP-F trk
                                       inelig flag do not have any significance.
                                       For july FP : final functionality will be
                                       decided later.
   15-Mar-04  pbodla        115.203    GLOBALCWB : Bug 3502094  : Commented end if
                                       properly
   18-Mar-04  rpgupta       115.204    3510229 - Allow system to pick up the
   					default enrollment code from higher
   					levels if not found in the lowest level
   13-Apr-04  kmahendr      115.205    FONM changes.
   29-Apr-04  mmudigon      115.206    Bug 3595902. Changes to cursors
                                       c_plan_enrolment_info_unrst and
                                       c_plan_enrolment_info in proc
                                       enrolment_requirements
   15-Jun-04  mmudigon      115.207    Bug 3685228. Merged cursors
                                       c_plan_enrolment_info_unrst and
                                       c_plan_enrolment_info in proc
                                       enrolment_requirements. Treating 'M'
                                       mode similar to 'U' mode for these
                                       cursors.
   29-Jun-04  kmahendr      115.208    Bug#3726552 - added call for updating dflt flag on
                                       enrt bnft in update_defaults
   13-Jul-04  kmahendr      115.209    Bug#3697378 - modified cursor-c_get_latest_enrt_dt
   23-Aug-04  mmudigon      115.210    CFW : 2534391 :NEED TO LEAVE ACTION ITEMS
                                       CERTIFICATIONS on subsequent events
   27-Sep-04  pbodla        115.211    iRec : Avoid iRec life events similar to
                                       gsp events.
   30-Sep-04  abparekh      115.212    iRec : While picking assignments for iRec do not compare
                                       primary flag. Extend / Exclude processing for iRec like GSP.
   21-Oct-04  tjesumic      115.213    # 3936695 Enrollment_cd fixed by cheking the level of the setup
   26-Oct-04  tjesumic      115.214    # 3936695
   29-Oct-04  ikasire       115.215    Bugs 3972973 and 3978745 fixes
   15-nov-04  kmahendr      115.216    Unrest. enh changes
   17-Nov-04  tjesumic      115.217    # 4008380 fixed. fixed default flag validations
   22-Nov-04 abparekh       115.218    Bug 4023880 : Fixed code to create elctbl chc at PLAN level if
                                       they dont exist while creating elctbl chc at OIPL level.
   01-Dec-04  kmahendr      115.219    Unrest. enh changes
   30-dec-04    nhunur      115.49     4031733 - No need to open cursor c_state.
   04-Jan-04  kmahendr      115.221   Bug#4096382 - condition added to return if comp.
                                      objects are in pending or suspended in U or R mode
   05-Jan-05  ikasire       115.222   Bug 4106760 fix
   11-Jan-05  ikasire       115.223   BUG 4064635 CF Suspended Interim Changes
   26-Jan-05  ikasire       115.224   BUG 4064635 CF Suspended Interim Changes
   02-Feb-05  ikasire       115.225   BUG 4064635 CF Suspended Interim Changes
   18-Apr-05  tjesumic      115.226   GHR enhancement to add number of days in enrt perd codeds
   29-Apr-05  kmahendr      115.227   Added a parameter - update_def_elct_flag to
                                      determine_enrolment - bug#4338685
   24-May-05  bmanyam       115.228   Bug 4388226 : Changed c_get_latest_enrt_dt to
                                      pick up valid enrollments only.
   08-Jul-05  rbingi        115.229   Bug 4447114 : assigning Global value of
                                      ben_evaluate_elig_profiles.g_inelg_rsn_cd
                                      to l_inelg_rsn_cd in case of CWB run mode
   12-Jul-05  pbodla        115.230   Populating data into ben_cwb_hrchy is
                                      completely removed.
   21-Jul-05  kmahendr      115.231   Bug#4478186 - added codes to procedure
                                      enrt_perd_strt_dt
   10-Nov-05  tjesumic      115.233   fix 115.232 (4571771) is reversed as the benauten  electable flag
                                      validation is reverted
   18-Jan-06  rbingi        115.234   Bug-4717052: Calling update_elig_per_elctbl when epe
                                      existing for PLAN record for update of pen_id.
   15-Feb-06  rbingi        115.235   Bug-5035423: contd from prev fix, calling Update_epe
                                       only when epe exists for PLAN
   03-Mar-06  kmahendr      115.236   Added new enrollment codes
   14-Mar-06  ssarkar       115.237   5092244 - populating g_egd_table in update_defaults
   04-Apr-06  rbingi        115.238   5029028: Added UNIONs to select the enrolment codes
                                       from respective tables if ler_chg records not defined
   26-Jun-06  swjain        115.239   5331889 - Added person_id param in calls to benutils.formula
   30-Jun-06  swjain        115.240   Commented out show errors
   01-sep-06  ssarkar       115.241   Bug 5491475 - reverted 5029028 fix
   26-Sep-06  abparekh      115.242   Bug 5555402 - While determining DFLT_ENRT_CD, consider code
                                                    at PL_NIP level for enrollment at PLIP level
   28-Sep-06  abparekh      115.243   Bug 5569758 - Get OIPL details correctly in procedure
                                                    DETERMINE_DFLT_ENRT_CD (1)
   27-Sep-06  stee          115.244   Bug 5650482  - For scheduled mode, change the processing
                                      end date to not slide if the event is backed out and
                                      reprocessed at a later date.
   05-Dec-06  stee          115.245   Bug 5650482  - If ENRT_PERD_DET_OVRLP_BCKDT_CD
                                      = L_EPSD_PEPD then slide the processing date.
   06-Jan-06  bmanyam       115.246   5736589: Increase/Decrease Requires certification
                                      for Option Restrictions
   08-Jan-06  bmanyam       115.247   5736589: Increase/Decrease Requires certification
                                      for Option Restrictions
   12-Jan-07  gsehgal       115.248   Bug 5644451 - Defaults are not getting created properly.
				                              See bug details for test case. Also local procedure
				                              determine_dflt_enrt_cd moved at top of the package as this
				                              is now used in ben_enrolment_requirements.enrolment_requirements
   10-Feb-07  stee           115.249   Added a check for g_debug for trace statements.
   22-Jan-07  rtagarra      115.249   -- ICM Changes for 'D' Mode.
   28-May-07 rgajula        115.250   Bug 6061856 -- Modified the procedure determine_dflt_enrt_cd such that
                                      Default Enrollment Codes at LER level Override Default Enrollment Codes at OIPL level.
   20-Dec-07 sagnanas		      Included fix 6281735 and 6519487 for 12.1
   15-Apr-09 ksridhar       115.255   Bug 7452061 : Reverting back the fix 5644451 for the bug 7452061
   23-Apr-09 skameswa       115.257   Bug 8228639 : Modified the fix 7507714,restricted the fix to Unrestricted LE.
   04-May-09 sallumwa       115.258   Bug 8453712 : Restricted the fix done in 6519487,when the plans corresponding to past and current
                                      Life events are different.
   08-Jun-09 sagnanas       115.259   Bug 8399189 - Modified cursor c_plan_enrolment_info
   21-Aug-09 sallumwa       115.260   Bug 8768050 : Restricted the fix done in 6519487,when the plans corresponding to past and current
                                                    Life events are different,when the plan has options.
   24-Jun-09 sallumwa       115.262   Bug 8846328 : Modified the fix done for the bug 6519487 so that currently enrolled flags are set
                                                    for the suspended and interim elections.
*/
---------------------------------------------------------------------------------------------------
  g_package VARCHAR2(80)                := 'ben_enrolment_requirements';
  g_rec     benutils.g_batch_elctbl_rec;
  g_ptip_id NUMBER;
--
--
-- internal version below for update_defaults
-- bug 5644451. Move at top of the package
procedure determine_dflt_enrt_cd
  (p_oipl_id           in     number
  ,p_oipl_rec          in     ben_oipl_f%rowtype
  ,p_plip_id           in     number
  ,p_plip_rec          in     ben_plip_f%rowtype
  ,p_pl_id             in     number
  ,p_pl_rec            in     ben_pl_f%rowtype
  ,p_ptip_id           in     number
  ,p_ptip_rec          in     ben_ptip_f%rowtype
  ,p_pgm_id            in     number
  ,p_pgm_rec           in     ben_pgm_f%rowtype
  ,p_ler_id            in     number
  ,p_business_group_id in     number
  ,p_effective_date    in     date
  ,p_dflt_enrt_cd         out nocopy varchar2
  ,p_dflt_enrt_rl         out nocopy number
  ,p_level                out nocopy varchar2
  ,p_ler_dflt_flag   out nocopy varchar2
  )
IS
    --
    -- NOTE:
    --
    --   This procedure is also callable from other RCOs
    --   Please do not remove get_object calls since they
    --   may be needed if not called from bendenrr.
    --
    l_proc         VARCHAR2(80)       := g_package || '.determine_dflt_enrt_cd';
    --
    CURSOR c_ler_oipl_dflt_cd IS
      SELECT   leo.dflt_enrt_cd,
               leo.dflt_enrt_rl,
               leo.dflt_flag
      FROM     ben_ler_chg_oipl_enrt_f leo
      WHERE    p_oipl_id = leo.oipl_id
      AND      p_ler_id = leo.ler_id
      AND      p_effective_date BETWEEN leo.effective_start_date
                   AND leo.effective_end_date;
    --
    -- Use cache for oipl, don't need cursor
    --
    CURSOR c_ler_pl_nip_dflt_cd IS
      SELECT   len.dflt_enrt_cd,
               len.dflt_enrt_rl,
               len.dflt_flag
      FROM     ben_ler_chg_pl_nip_enrt_f len
      WHERE    p_pl_id = len.pl_id
      AND      p_ler_id = len.ler_id
      AND      p_effective_date BETWEEN len.effective_start_date
                   AND len.effective_end_date;
    --
    CURSOR c_ler_plip_dflt_cd IS
      SELECT   lep.dflt_enrt_cd,
               lep.dflt_enrt_rl,
               lep.dflt_flag
      FROM     ben_ler_chg_plip_enrt_f lep
      WHERE    p_plip_id = lep.plip_id
      AND      p_ler_id = lep.ler_id
      AND      p_effective_date BETWEEN lep.effective_start_date
                   AND lep.effective_end_date;
    --
    CURSOR c_ler_ptip_dflt_cd IS
      SELECT   lep.dflt_enrt_cd,
               lep.dflt_enrt_rl
      FROM     ben_ler_chg_ptip_enrt_f lep
      WHERE    p_ptip_id = lep.ptip_id
      AND      p_ler_id = lep.ler_id
      AND      p_effective_date BETWEEN lep.effective_start_date
                   AND lep.effective_end_date;
    --
    CURSOR c_ler_pgm_dflt_cd IS
      SELECT   lep.dflt_enrt_cd,
               lep.dflt_enrt_rl
      FROM     ben_ler_chg_pgm_enrt_f lep
      WHERE    p_pgm_id = lep.pgm_id
      AND      p_ler_id = lep.ler_id
      AND      p_effective_date BETWEEN lep.effective_start_date
                   AND lep.effective_end_date;
    --
    CURSOR c_pl_nip_dflt_cd IS
      SELECT   pln.nip_dflt_enrt_cd,
               pln.nip_dflt_enrt_det_rl,
               pln.nip_dflt_flag
      FROM     ben_pl_f pln
      WHERE    p_pl_id = pln.pl_id
      AND      p_effective_date BETWEEN pln.effective_start_date
                   AND pln.effective_end_date;
    --
    CURSOR c_plip_dflt_cd IS
      SELECT   plp.dflt_enrt_cd,
               plp.dflt_enrt_det_rl
      FROM     ben_plip_f plp
      WHERE    p_plip_id = plp.plip_id
      AND      p_effective_date BETWEEN plp.effective_start_date
                   AND plp.effective_end_date;
    --
    CURSOR c_ptip_dflt_cd IS
      SELECT   ptp.dflt_enrt_cd,
               ptp.dflt_enrt_det_rl
      FROM     ben_ptip_f ptp
      WHERE    p_ptip_id = ptp.ptip_id
      AND      p_effective_date BETWEEN ptp.effective_start_date
                   AND ptp.effective_end_date;
    --
    l_dflt_enrt_cd VARCHAR2(30);
    l_dflt_enrt_rl NUMBER;
    l_plan_rec     ben_pl_f%ROWTYPE;
    l_oipl_rec     ben_cobj_cache.g_oipl_inst_row;
    l_ler_dflt_flag varchar2(30); -- 3510229
  BEGIN
    --
    g_debug := hr_utility.debug_enabled;
    --
    if g_debug then
    hr_utility.set_location('Entering: ' || l_proc, 10);
    end if;
    --
    l_dflt_enrt_cd :=  NULL;
    --
    --Start Bug 6061856 -- Modified the Ordering, moved oipl to 6
    -- Hierarchy
    --
    -- 1  if oipl     ben_ler_chg_oipl_enrt_f
    -- 2  if no pgm   ben_ler_chg_pl_nip_enrt_f
    -- 3  if pgm      ben_ler_chg_plip_enrt_f
    -- 4  if pgm      ben_ler_chg_ptip_enrt_f
    -- 5  if pgm      ben_ler_chg_pgm_enrt_f
    --
    -- 6  if oipl     ben_oipl_f (from cache)

    -- 7  if no pgm   ben_pl_f
    -- 8  if pgm      ben_plip_f
    -- 9  if pgm      ben_ptip_f
    --
--End Bug 6061856
    IF p_oipl_id IS NOT NULL THEN
      --
      -- 1
      --
      OPEN c_ler_oipl_dflt_cd;
      FETCH c_ler_oipl_dflt_cd INTO l_dflt_enrt_cd, l_dflt_enrt_rl, l_ler_dflt_flag;
                                    --p_ler_dflt_flag; 3510229
      CLOSE c_ler_oipl_dflt_cd;
      if /*l_dflt_enrt_cd 3510229*/l_ler_dflt_flag is not null then
        p_level:='LER_OIPL';
        p_ler_dflt_flag := l_ler_dflt_flag; -- 3510229
        l_ler_dflt_flag := null ; --3510229
      end if;
      --
     /* IF l_dflt_enrt_cd IS NULL THEN
        --
        -- 2
        --
	if g_debug then
        hr_utility.set_location('In the case 2 ' , 100);
	end if;
        --
        --l_dflt_enrt_cd :=  ben_cobj_cache.g_oipl_currow.dflt_enrt_cd;
        --l_dflt_enrt_rl :=  ben_cobj_cache.g_oipl_currow.dflt_enrt_det_rl;
        --
        l_dflt_enrt_cd := p_oipl_rec.dflt_enrt_cd ;
        l_dflt_enrt_rl := p_oipl_rec.dflt_enrt_det_rl ;

        --hr_utility.set_location(' p_oipl_rec.oipl_id '||p_oipl_rec.oipl_id ,110);
        --hr_utility.set_location(' p_oipl_rec.dflt_enrt_cd '||p_oipl_rec.dflt_enrt_cd ,110);
        --hr_utility.set_location(' p_oipl_rec.dflt_flag '||p_oipl_rec.dflt_flag, 110)  ;
        --
      if l_dflt_enrt_cd is not null
         and p_level is null then -- 3510229
        p_level:='OIPL';
      end if;
      --
      END IF;*/
    END IF;

    IF     p_pgm_id IS NULL
       AND l_dflt_enrt_cd IS NULL THEN
      --
      -- 2
      --
      OPEN c_ler_pl_nip_dflt_cd;
      FETCH c_ler_pl_nip_dflt_cd INTO l_dflt_enrt_cd, l_dflt_enrt_rl,l_ler_dflt_flag; --3510229
                                    --p_ler_dflt_flag;
      CLOSE c_ler_pl_nip_dflt_cd;
      if l_dflt_enrt_cd is not null
         and p_level is null then -- 3510229
        p_level:='LER_PL_NIP';
        -- 3510229 start
        -- there could be default flag without default code , so this s moved down - 	4008380
        --if p_ler_dflt_flag is null then
        --  p_ler_dflt_flag := l_ler_dflt_flag;
        --end if;
        --l_ler_dflt_flag := null ;
	if g_debug then
        hr_utility.set_location('after LER pNip chk p_ler_dflt_flag:  '||p_ler_dflt_flag , 100);
	end if;
        -- 3510229 end

      end if;
      -- there could be default flag without default code 4008380
      if p_ler_dflt_flag is null and l_ler_dflt_flag is not null  then
          p_ler_dflt_flag := l_ler_dflt_flag ;
      end if ;
      if g_debug then
      hr_utility.set_location('l_ler_dflt_flag ' || l_ler_dflt_flag ,40);
      hr_utility.set_location(l_dflt_enrt_cd,40);
      end if;

    ELSIF     p_pgm_id IS NOT NULL
          AND l_dflt_enrt_cd IS NULL THEN
      --
      -- 3
      --
      OPEN c_ler_plip_dflt_cd;
      FETCH c_ler_plip_dflt_cd INTO l_dflt_enrt_cd, l_dflt_enrt_rl, l_ler_dflt_flag; --3510229
                                    --p_ler_dflt_flag;
      CLOSE c_ler_plip_dflt_cd;
      if l_dflt_enrt_cd is not null
         and p_level is null then -- 3510229
        p_level:='LER_PLIP';

        -- 3510229 start
        --  4008380
        --if p_ler_dflt_flag is null then
        --  p_ler_dflt_flag := l_ler_dflt_flag;
        --end if;
	if g_debug then
        hr_utility.set_location('after LER PLIP chk p_ler_dflt_flag:  '||p_ler_dflt_flag , 100);
	end if;
        --l_ler_dflt_flag := null ;
        -- 3510229 end

      end if;
      --  4008380
      if p_ler_dflt_flag is null and l_ler_dflt_flag is not null  then
          p_ler_dflt_flag := l_ler_dflt_flag ;
      end if ;
      if g_debug then
      hr_utility.set_location('l_ler_dflt_flag ' || l_ler_dflt_flag ,50);
      hr_utility.set_location(l_dflt_enrt_cd,50);
      end if;
      --  4008380
      --  there could be plip but the setup may be in plan  ler level
      IF l_dflt_enrt_cd IS NULL THEN

         OPEN c_ler_pl_nip_dflt_cd;
         FETCH c_ler_pl_nip_dflt_cd INTO l_dflt_enrt_cd, l_dflt_enrt_rl,l_ler_dflt_flag;
         CLOSE c_ler_pl_nip_dflt_cd;

         if l_dflt_enrt_cd is not null
            and p_level is null then -- 3510229
            p_level:='LER_PL';
         if g_debug then
            hr_utility.set_location('after LER Plan  chk p_ler_dflt_flag:  '||p_ler_dflt_flag , 100);
         end if;
         end if;
         -- there could be default flag without default code 4008380
         if p_ler_dflt_flag is null and l_ler_dflt_flag is not null  then
            p_ler_dflt_flag := l_ler_dflt_flag ;
         end if ;
	 if g_debug then
         hr_utility.set_location('l_ler_dflt_flag ' || l_ler_dflt_flag ,40);
         hr_utility.set_location(l_dflt_enrt_cd,40);
	 end if;
      end if ;



      --- ptip level
      IF l_dflt_enrt_cd IS NULL THEN
        --
        -- 4
        --
        OPEN c_ler_ptip_dflt_cd;
        FETCH c_ler_ptip_dflt_cd INTO l_dflt_enrt_cd, l_dflt_enrt_rl;
        CLOSE c_ler_ptip_dflt_cd;
      if l_dflt_enrt_cd is not null
         and p_level is null then -- 3510229
        p_level:='LER_PTIP';
      end if;
        --  hr_utility.set_location(l_dflt_enrt_cd,60);
        IF l_dflt_enrt_cd IS NULL THEN
          --
          -- 5
          --
          OPEN c_ler_pgm_dflt_cd;
          FETCH c_ler_pgm_dflt_cd INTO l_dflt_enrt_cd, l_dflt_enrt_rl;
          CLOSE c_ler_pgm_dflt_cd;
      if l_dflt_enrt_cd is not null
         and p_level is null then --3510229
        p_level:='LER_PTIP'; --Bug 6281735
      end if;
        END IF;
      END IF;
    END IF;
--Start Bug 6061856
--Default Codes LER override OIPL Level
    if p_oipl_id is not null then
      IF l_dflt_enrt_cd IS NULL THEN
        --
        -- 6
        --
        hr_utility.set_location('In the case 2 ' , 100);
        --
        --l_dflt_enrt_cd :=  ben_cobj_cache.g_oipl_currow.dflt_enrt_cd;
        --l_dflt_enrt_rl :=  ben_cobj_cache.g_oipl_currow.dflt_enrt_det_rl;
        --
        l_dflt_enrt_cd := p_oipl_rec.dflt_enrt_cd ;
        l_dflt_enrt_rl := p_oipl_rec.dflt_enrt_det_rl ;

        --hr_utility.set_location(' p_oipl_rec.oipl_id '||p_oipl_rec.oipl_id ,110);
        --hr_utility.set_location(' p_oipl_rec.dflt_enrt_cd '||p_oipl_rec.dflt_enrt_cd ,110);
        --hr_utility.set_location(' p_oipl_rec.dflt_flag '||p_oipl_rec.dflt_flag, 110)  ;
        --
      if l_dflt_enrt_cd is not null
         and p_level is null then -- 3510229
        p_level:='OIPL';
      end if;
      --
      END IF;
     end if;
--End Bug 6061856

    --  hr_utility.set_location(l_dflt_enrt_cd,80);
    IF     p_pgm_id IS NULL
       AND l_dflt_enrt_cd IS NULL THEN
      --
      -- 7
      --
      -- Bug 1895874
      -- l_dflt_enrt_cd :=  ben_cobj_cache.g_pl_currow.nip_dflt_enrt_cd;
      -- l_dflt_enrt_rl :=  ben_cobj_cache.g_pl_currow.nip_dflt_enrt_det_rl;
      --
      if g_debug then
      hr_utility.set_location(' p_pl_rec.pl_id '||p_oipl_rec.oipl_id ,110);
      hr_utility.set_location(' p_pl_rec.nip_dflt_enrt_cd '||p_pl_rec.nip_dflt_enrt_cd ,110);
      hr_utility.set_location(' p_pl_rec.nip_dflt_flag '||p_pl_rec.nip_dflt_flag, 110)  ;
      end if;
      --
      l_dflt_enrt_cd := p_pl_rec.nip_dflt_enrt_cd ;
      l_dflt_enrt_rl := p_pl_rec.nip_dflt_enrt_det_rl ;
      if p_ler_dflt_flag is null then -- 3510229
        p_ler_dflt_flag := p_pl_rec.nip_dflt_flag ;
      end if;

/*
      OPEN c_pl_nip_dflt_cd;
      FETCH c_pl_nip_dflt_cd INTO l_dflt_enrt_cd, l_dflt_enrt_rl,
                                    p_ler_dflt_flag;
      CLOSE c_pl_nip_dflt_cd;
*/
      --
      if l_dflt_enrt_cd is not null
         and p_level is null then -- 3510229
        p_level:='PL';
      end if;
      --
    --  hr_utility.set_location(l_dflt_enrt_cd,90);

    ELSIF     p_pgm_id IS NOT NULL
          AND l_dflt_enrt_cd IS NULL THEN
      --
      -- 8
      --
      l_dflt_enrt_cd := p_plip_rec.dflt_enrt_cd ;
      l_dflt_enrt_rl := p_plip_rec.dflt_enrt_det_rl ;
/*
      OPEN c_plip_dflt_cd;
      FETCH c_plip_dflt_cd INTO l_dflt_enrt_cd, l_dflt_enrt_rl;
      CLOSE c_plip_dflt_cd;
*/
      if l_dflt_enrt_cd is not null
         and p_level is null then -- 3510229
        p_level:='PLIP';
      end if;
       if g_debug then
       hr_utility.set_location(l_dflt_enrt_cd,100);
       end if;
        --
      IF l_dflt_enrt_cd IS NULL THEN
        --
        -- 9
        --
      l_dflt_enrt_cd := p_ptip_rec.dflt_enrt_cd ;
      l_dflt_enrt_rl := p_ptip_rec.dflt_enrt_det_rl ;
/*
        OPEN c_ptip_dflt_cd;
        FETCH c_ptip_dflt_cd INTO l_dflt_enrt_cd, l_dflt_enrt_rl;
        CLOSE c_ptip_dflt_cd;
*/
      if l_dflt_enrt_cd is not null
         and p_level is null then -- 3510229
        p_level:='PTIP';
      end if;
      if g_debug then
      hr_utility.set_location(l_dflt_enrt_cd,110);
      end if;
        --
      END IF;
    END IF;
  --
   if g_debug then
    hr_utility.set_location(' p_pgm_id '||p_pgm_id||' pl_id '||p_pl_id||' oipl '||p_oipl_id||
                            ' plip '||p_plip_id||' ptip '||p_ptip_id,130);
    hr_utility.set_location('dflt_enrt_cd= '||l_dflt_enrt_cd,130);
    hr_utility.set_location('dflt_enrt_rl= '||l_dflt_enrt_rl,140);
    hr_utility.set_location('p_ler_dflt_flag= '||p_ler_dflt_flag ,140);
   end if;
    p_dflt_enrt_cd :=  l_dflt_enrt_cd;
    p_dflt_enrt_rl :=  l_dflt_enrt_rl;
    if g_debug then
    hr_utility.set_location('Leaving: ' || l_proc, 150);
    end if;
  exception
    --
    when others then
      --
      p_dflt_enrt_cd        := null;
      p_dflt_enrt_rl        := null;
      p_level               := null;
      p_ler_dflt_flag       := null;
      raise;
      --
  END;
-- end internal determine_dflt_enrt_cd
  PROCEDURE determine_ben_settings(
    p_pl_id                     IN     ben_ler_chg_pl_nip_enrt_f.pl_id%TYPE,
    p_ler_id                    IN     ben_ler_chg_pl_nip_enrt_f.ler_id%TYPE,
    p_lf_evt_ocrd_dt            IN     DATE,
    p_ptip_id                   IN     ben_ler_chg_ptip_enrt_f.ptip_id%TYPE,
    p_pgm_id                    IN     ben_ler_chg_pgm_enrt_f.pgm_id%TYPE,
    p_plip_id                   IN     ben_ler_chg_plip_enrt_f.plip_id%TYPE,
    p_oipl_id                   IN     ben_ler_chg_oipl_enrt_f.oipl_id%TYPE,
    p_just_prclds_chg_flag      IN     BOOLEAN DEFAULT FALSE,
    p_enrt_cd                   OUT NOCOPY    ben_ler_chg_oipl_enrt_f.enrt_cd%TYPE,
    p_enrt_rl                   OUT NOCOPY    ben_ler_chg_oipl_enrt_f.enrt_rl%TYPE,
    p_auto_enrt_mthd_rl         OUT NOCOPY    ben_ler_chg_oipl_enrt_f.auto_enrt_mthd_rl%TYPE,
    p_crnt_enrt_prclds_chg_flag OUT NOCOPY    ben_ler_chg_oipl_enrt_f.crnt_enrt_prclds_chg_flag%TYPE,
    p_dflt_flag                 OUT NOCOPY    ben_ler_chg_oipl_enrt_f.dflt_flag%TYPE,
    p_enrt_mthd_cd              OUT NOCOPY    ben_ler_chg_pgm_enrt_f.enrt_mthd_cd%TYPE,
    p_stl_elig_cant_chg_flag    OUT NOCOPY    ben_ler_chg_oipl_enrt_f.stl_elig_cant_chg_flag%TYPE,
    p_tco_chg_enrt_cd           OUT NOCOPY    ben_ler_chg_ptip_enrt_f.tco_chg_enrt_cd%TYPE,
    p_ler_chg_oipl_found_flag   OUT NOCOPY    VARCHAR2,
    p_ler_chg_found_flag        OUT NOCOPY    VARCHAR2,
    p_enrt_cd_level             OUT NOCOPY    VARCHAR2 ) IS
    -- ========================
    -- define the local cursors
    -- ========================
    -- Bug 5029028: Added UNIONs for all cursors to select the codes from respective
    -- tables if ler_chg records not defined.
   -- ssarkar 5491475 : roll back 5029028
    CURSOR csr_oipl IS
      SELECT   oipl.auto_enrt_flag,
               oipl.auto_enrt_mthd_rl,
               oipl.crnt_enrt_prclds_chg_flag,
               oipl.dflt_flag,
               oipl.enrt_cd,
               oipl.enrt_rl,
               oipl.ler_chg_oipl_enrt_id,
               oipl.stl_elig_cant_chg_flag
      FROM     ben_ler_chg_oipl_enrt_f oipl
      WHERE    oipl.oipl_id = p_oipl_id
      AND      oipl.ler_id = p_ler_id
      AND      p_lf_evt_ocrd_dt BETWEEN oipl.effective_start_date
                   AND oipl.effective_end_date;
    --
    CURSOR csr_pgm IS
      SELECT   pgm.auto_enrt_mthd_rl,
               pgm.crnt_enrt_prclds_chg_flag,
               pgm.enrt_cd,
               pgm.enrt_mthd_cd,
               pgm.enrt_rl,
               pgm.ler_chg_pgm_enrt_id,
               pgm.stl_elig_cant_chg_flag
      FROM     ben_ler_chg_pgm_enrt_f pgm
      WHERE    pgm.pgm_id = p_pgm_id
      AND      pgm.ler_id = p_ler_id
      AND      p_lf_evt_ocrd_dt BETWEEN pgm.effective_start_date
                   AND pgm.effective_end_date;
    --
    CURSOR csr_ptip IS
      SELECT   ptip.crnt_enrt_prclds_chg_flag,
               ptip.enrt_cd,
               ptip.enrt_mthd_cd,
               ptip.enrt_rl,
               ptip.ler_chg_ptip_enrt_id,
               ptip.stl_elig_cant_chg_flag,
               ptip.tco_chg_enrt_cd
      FROM     ben_ler_chg_ptip_enrt_f ptip
      WHERE    ptip.ptip_id = p_ptip_id
      AND      ptip.ler_id = p_ler_id
      AND      p_lf_evt_ocrd_dt BETWEEN ptip.effective_start_date
                   AND ptip.effective_end_date;
    --
    CURSOR csr_plip IS
      SELECT   plip.auto_enrt_mthd_rl,
               plip.crnt_enrt_prclds_chg_flag,
               plip.dflt_flag,
               plip.enrt_cd,
               plip.enrt_mthd_cd,
               plip.enrt_rl,
               plip.ler_chg_plip_enrt_id,
               plip.stl_elig_cant_chg_flag,
               plip.tco_chg_enrt_cd
      FROM     ben_ler_chg_plip_enrt_f plip
      WHERE    plip.plip_id = p_plip_id
      AND      plip.ler_id = p_ler_id
      AND      p_lf_evt_ocrd_dt BETWEEN plip.effective_start_date
                   AND plip.effective_end_date;
    --
    CURSOR csr_pl_nip IS
      SELECT   pl_nip.auto_enrt_mthd_rl,
               pl_nip.crnt_enrt_prclds_chg_flag,
               pl_nip.dflt_flag,
               pl_nip.enrt_cd,
               pl_nip.enrt_mthd_cd,
               pl_nip.enrt_rl,
               pl_nip.ler_chg_pl_nip_enrt_id,
               pl_nip.stl_elig_cant_chg_flag,
               pl_nip.tco_chg_enrt_cd
      FROM     ben_ler_chg_pl_nip_enrt_f pl_nip
      WHERE    pl_nip.pl_id = p_pl_id
      AND      pl_nip.ler_id = p_ler_id
      AND      p_lf_evt_ocrd_dt BETWEEN pl_nip.effective_start_date
                   AND pl_nip.effective_end_date;
    -- ======================
    -- define local variables
    -- ======================
    oipl_auto_enrt_flag            ben_ler_chg_oipl_enrt_f.auto_enrt_flag%TYPE;
    oipl_auto_enrt_mthd_rl         ben_ler_chg_oipl_enrt_f.auto_enrt_mthd_rl%TYPE;
    oipl_crnt_enrt_prclds_chg_flag ben_ler_chg_oipl_enrt_f.crnt_enrt_prclds_chg_flag%TYPE;
    oipl_dflt_flag                 ben_ler_chg_oipl_enrt_f.dflt_flag%TYPE;
    oipl_enrt_cd                   ben_ler_chg_oipl_enrt_f.enrt_cd%TYPE;
    oipl_enrt_rl                   ben_ler_chg_oipl_enrt_f.enrt_rl%TYPE;
    oipl_ler_chg_oipl_enrt_id      ben_ler_chg_oipl_enrt_f.ler_chg_oipl_enrt_id%TYPE;
    oipl_stl_elig_cant_chg_flag    ben_ler_chg_oipl_enrt_f.stl_elig_cant_chg_flag%TYPE;
    pgm_auto_enrt_mthd_rl          ben_ler_chg_pgm_enrt_f.auto_enrt_mthd_rl%TYPE;
    pgm_crnt_enrt_prclds_chg_flag  ben_ler_chg_pgm_enrt_f.crnt_enrt_prclds_chg_flag%TYPE;
    pgm_enrt_cd                    ben_ler_chg_pgm_enrt_f.enrt_cd%TYPE;
    pgm_enrt_mthd_cd               ben_ler_chg_pgm_enrt_f.enrt_mthd_cd%TYPE;
    pgm_enrt_rl                    ben_ler_chg_pgm_enrt_f.enrt_rl%TYPE;
    pgm_ler_chg_pgm_enrt_id        ben_ler_chg_pgm_enrt_f.ler_chg_pgm_enrt_id%TYPE;
    pgm_stl_elig_cant_chg_flag     ben_ler_chg_pgm_enrt_f.stl_elig_cant_chg_flag%TYPE;
    pnip_auto_enrt_mthd_rl         ben_ler_chg_pl_nip_enrt_f.auto_enrt_mthd_rl%TYPE;
    pnip_crnt_enrt_prclds_chg_flag ben_ler_chg_pl_nip_enrt_f.crnt_enrt_prclds_chg_flag%TYPE;
    pnip_dflt_flag                 ben_ler_chg_pl_nip_enrt_f.dflt_flag%TYPE;
    pnip_enrt_cd                   ben_ler_chg_pl_nip_enrt_f.enrt_cd%TYPE;
    pnip_enrt_mthd_cd              ben_ler_chg_pl_nip_enrt_f.enrt_mthd_cd%TYPE;
    pnip_enrt_rl                   ben_ler_chg_pl_nip_enrt_f.enrt_rl%TYPE;
    pnip_ler_chg_pnip_enrt_id      ben_ler_chg_pl_nip_enrt_f.ler_chg_pl_nip_enrt_id%TYPE;
    pnip_stl_elig_cant_chg_flag    ben_ler_chg_pl_nip_enrt_f.stl_elig_cant_chg_flag%TYPE;
    pnip_tco_chg_enrt_cd           ben_ler_chg_pl_nip_enrt_f.tco_chg_enrt_cd%TYPE;
    plip_auto_enrt_mthd_rl         ben_ler_chg_plip_enrt_f.auto_enrt_mthd_rl%TYPE;
    plip_crnt_enrt_prclds_chg_flag ben_ler_chg_plip_enrt_f.crnt_enrt_prclds_chg_flag%TYPE;
    plip_dflt_flag                 ben_ler_chg_plip_enrt_f.dflt_flag%TYPE;
    plip_enrt_cd                   ben_ler_chg_plip_enrt_f.enrt_cd%TYPE;
    plip_enrt_mthd_cd              ben_ler_chg_plip_enrt_f.enrt_mthd_cd%TYPE;
    plip_enrt_rl                   ben_ler_chg_plip_enrt_f.enrt_rl%TYPE;
    plip_ler_chg_plip_enrt_id      ben_ler_chg_plip_enrt_f.ler_chg_plip_enrt_id%TYPE;
    plip_stl_elig_cant_chg_flag    ben_ler_chg_plip_enrt_f.stl_elig_cant_chg_flag%TYPE;
    plip_tco_chg_enrt_cd           ben_ler_chg_plip_enrt_f.tco_chg_enrt_cd%TYPE;
    ptip_crnt_enrt_prclds_chg_flag ben_ler_chg_ptip_enrt_f.crnt_enrt_prclds_chg_flag%TYPE;
    ptip_enrt_cd                   ben_ler_chg_ptip_enrt_f.enrt_cd%TYPE;
    ptip_enrt_mthd_cd              ben_ler_chg_ptip_enrt_f.enrt_mthd_cd%TYPE;
    ptip_enrt_rl                   ben_ler_chg_ptip_enrt_f.enrt_rl%TYPE;
    ptip_ler_chg_ptip_enrt_id      ben_ler_chg_ptip_enrt_f.ler_chg_ptip_enrt_id%TYPE;
    ptip_stl_elig_cant_chg_flag    ben_ler_chg_ptip_enrt_f.stl_elig_cant_chg_flag%TYPE;
    ptip_tco_chg_enrt_cd           ben_ler_chg_ptip_enrt_f.tco_chg_enrt_cd%TYPE;
    l_temp                         number; -- 5029028
  BEGIN
  -- ============================================
  -- open,fetch and close each cursor if required
  -- ============================================
    IF p_ler_id IS NOT NULL THEN
      IF p_oipl_id IS NOT NULL THEN
        OPEN csr_oipl;
        FETCH csr_oipl INTO oipl_auto_enrt_flag,
                            oipl_auto_enrt_mthd_rl,
                            oipl_crnt_enrt_prclds_chg_flag,
                            oipl_dflt_flag,
                            oipl_enrt_cd,
                            oipl_enrt_rl,
                            oipl_ler_chg_oipl_enrt_id,
                            oipl_stl_elig_cant_chg_flag;
                            --l_temp;
        CLOSE csr_oipl;
      END IF;
      IF p_pl_id IS NOT NULL THEN
        OPEN csr_pl_nip;
        FETCH csr_pl_nip INTO pnip_auto_enrt_mthd_rl,
                              pnip_crnt_enrt_prclds_chg_flag,
                              pnip_dflt_flag,
                              pnip_enrt_cd,
                              pnip_enrt_mthd_cd,
                              pnip_enrt_rl,
                              pnip_ler_chg_pnip_enrt_id,
                              pnip_stl_elig_cant_chg_flag,
                              pnip_tco_chg_enrt_cd;
                              --l_temp;
        CLOSE csr_pl_nip;
      END IF;
      IF p_plip_id IS NOT NULL THEN
        OPEN csr_plip;
        FETCH csr_plip INTO plip_auto_enrt_mthd_rl,
                            plip_crnt_enrt_prclds_chg_flag,
                            plip_dflt_flag,
                            plip_enrt_cd,
                            plip_enrt_mthd_cd,
                            plip_enrt_rl,
                            plip_ler_chg_plip_enrt_id,
                            plip_stl_elig_cant_chg_flag,
                            plip_tco_chg_enrt_cd;
                            --l_temp;
        CLOSE csr_plip;
      END IF;
      IF p_ptip_id IS NOT NULL THEN
        OPEN csr_ptip;
        FETCH csr_ptip INTO ptip_crnt_enrt_prclds_chg_flag,
                            ptip_enrt_cd,
                            ptip_enrt_mthd_cd,
                            ptip_enrt_rl,
                            ptip_ler_chg_ptip_enrt_id,
                            ptip_stl_elig_cant_chg_flag,
                            ptip_tco_chg_enrt_cd;
                            --l_temp;
        CLOSE csr_ptip;
      END IF;
      IF p_pgm_id IS NOT NULL THEN
        OPEN csr_pgm;
        FETCH csr_pgm INTO pgm_auto_enrt_mthd_rl,
                           pgm_crnt_enrt_prclds_chg_flag,
                           pgm_enrt_cd,
                           pgm_enrt_mthd_cd,
                           pgm_enrt_rl,
                           pgm_ler_chg_pgm_enrt_id,
                           pgm_stl_elig_cant_chg_flag;
                           --l_temp;
        CLOSE csr_pgm;
      END IF;
      -- ==========================================
      -- determine and SET the OUT parameter values
      -- ==========================================
      -- --------------------------------
      -- set: p_crnt_enrt_prclds_chg_flag
      -- --------------------------------
      IF oipl_crnt_enrt_prclds_chg_flag IS NULL THEN
        IF pnip_crnt_enrt_prclds_chg_flag IS NULL THEN
          IF plip_crnt_enrt_prclds_chg_flag IS NULL THEN
            IF ptip_crnt_enrt_prclds_chg_flag IS NULL THEN
              p_crnt_enrt_prclds_chg_flag :=  pgm_crnt_enrt_prclds_chg_flag;
            ELSE
              p_crnt_enrt_prclds_chg_flag :=  ptip_crnt_enrt_prclds_chg_flag;
            END IF;
          ELSE
            p_crnt_enrt_prclds_chg_flag :=  plip_crnt_enrt_prclds_chg_flag;
          END IF;
        ELSE
          p_crnt_enrt_prclds_chg_flag :=  pnip_crnt_enrt_prclds_chg_flag;
        END IF;
      ELSE
        p_crnt_enrt_prclds_chg_flag :=  oipl_crnt_enrt_prclds_chg_flag;
      END IF;
      -- test to see if only the p_crnt_enrt_prclds_chg_flag is required
      --IF p_just_prclds_chg_flag THEN
      --  RETURN;
      --END IF;
      -- ----------------------------
      -- set: p_enrt_cd and p_enrt_rl
      -- ----------------------------

     ----
     hr_utility.set_location( 'oipl' || oipl_enrt_cd , 10) ;
     hr_utility.set_location( 'pl' || pnip_enrt_cd , 10) ;
     hr_utility.set_location( 'plip' || plip_enrt_cd , 10);
     hr_utility.set_location( 'ptip' || ptip_enrt_cd , 10) ;



     hr_utility.set_location( 'oipl id ' || p_oipl_id , 10) ;
     hr_utility.set_location( 'ptip id ' || p_ptip_id , 10) ;
     hr_utility.set_location( 'plip id ' || p_plip_id , 10) ;
     hr_utility.set_location( 'pl id   ' || p_pl_id   , 10) ;
     ---


      IF oipl_enrt_cd IS NULL THEN
        IF pnip_enrt_cd IS NULL THEN
          IF plip_enrt_cd IS NULL THEN
            IF ptip_enrt_cd IS NULL THEN
              p_enrt_cd      :=  pgm_enrt_cd;
              p_enrt_rl      :=  pgm_enrt_rl;
              p_enrt_cd_level:= 'PGM' ;
            ELSE
              p_enrt_cd :=  ptip_enrt_cd;
              p_enrt_rl :=  ptip_enrt_rl;
              p_enrt_cd_level := 'PTIP' ;
            END IF;
          ELSE
            p_enrt_cd :=  plip_enrt_cd;
            p_enrt_rl :=  plip_enrt_rl;
            p_enrt_cd_level := 'PLIP' ;
          END IF;
        ELSE
          p_enrt_cd :=  pnip_enrt_cd;
          p_enrt_rl :=  pnip_enrt_rl;
          p_enrt_cd_level := 'PL' ;
        END IF;
      ELSE
        p_enrt_cd :=  oipl_enrt_cd;
        p_enrt_rl :=  oipl_enrt_rl;
        p_enrt_cd_level := 'OIPL' ;
      END IF;
      hr_utility.set_location( 'p_enrt_cd_level  ' || p_enrt_cd_level , 10) ;

       IF p_just_prclds_chg_flag THEN
        RETURN;
      END IF;



      -- ------------------------
      -- set: p_auto_enrt_mthd_rl
      -- ------------------------
      IF oipl_auto_enrt_mthd_rl IS NULL THEN
        IF pnip_auto_enrt_mthd_rl IS NULL THEN
          IF plip_auto_enrt_mthd_rl IS NULL THEN
            p_auto_enrt_mthd_rl :=  pgm_auto_enrt_mthd_rl;
          ELSE
            p_auto_enrt_mthd_rl :=  plip_auto_enrt_mthd_rl;
          END IF;
        ELSE
          p_auto_enrt_mthd_rl :=  pnip_auto_enrt_mthd_rl;
        END IF;
      ELSE
        p_auto_enrt_mthd_rl :=  oipl_auto_enrt_mthd_rl;
      END IF;
      -- ----------------
      -- set: p_dflt_flag
      -- ----------------
      IF oipl_dflt_flag IS NULL THEN
        IF pnip_dflt_flag IS NULL THEN
          p_dflt_flag :=  plip_dflt_flag;
        ELSE
          p_dflt_flag :=  pnip_dflt_flag;
        END IF;
      ELSE
        p_dflt_flag :=  oipl_dflt_flag;
      END IF;
      -- -------------------
      -- set: p_enrt_mthd_cd
      -- -------------------
      IF oipl_auto_enrt_flag = 'Y' THEN
        p_enrt_mthd_cd :=  'A';
      ELSIF oipl_auto_enrt_flag = 'N' THEN
        p_enrt_mthd_cd :=  'E';
      ELSE
        IF pnip_enrt_mthd_cd IS NULL THEN
          IF plip_enrt_mthd_cd IS NULL THEN
            IF ptip_enrt_mthd_cd IS NULL THEN
              p_enrt_mthd_cd :=  pgm_enrt_mthd_cd;
            ELSE
              p_enrt_mthd_cd :=  ptip_enrt_mthd_cd;
            END IF;
          ELSE
            p_enrt_mthd_cd :=  plip_enrt_mthd_cd;
          END IF;
        ELSE
          p_enrt_mthd_cd :=  pnip_enrt_mthd_cd;
        END IF;
      END IF;
      -- -----------------------------
      -- set: p_stl_elig_cant_chg_flag
      -- -----------------------------
      IF oipl_stl_elig_cant_chg_flag IS NULL THEN
        IF pnip_stl_elig_cant_chg_flag IS NULL THEN
          IF plip_stl_elig_cant_chg_flag IS NULL THEN
            IF ptip_stl_elig_cant_chg_flag IS NULL THEN
              p_stl_elig_cant_chg_flag :=  pgm_stl_elig_cant_chg_flag;
            ELSE
              p_stl_elig_cant_chg_flag :=  ptip_stl_elig_cant_chg_flag;
            END IF;
          ELSE
            p_stl_elig_cant_chg_flag :=  plip_stl_elig_cant_chg_flag;
          END IF;
        ELSE
          p_stl_elig_cant_chg_flag :=  pnip_stl_elig_cant_chg_flag;
        END IF;
      ELSE
        p_stl_elig_cant_chg_flag :=  oipl_stl_elig_cant_chg_flag;
      END IF;
      -- ----------------------
      -- set: p_tco_chg_enrt_cd
      -- ----------------------
      IF pnip_tco_chg_enrt_cd IS NULL THEN
        IF plip_tco_chg_enrt_cd IS NULL THEN
          p_tco_chg_enrt_cd :=  ptip_tco_chg_enrt_cd;
        ELSE
          p_tco_chg_enrt_cd :=  plip_tco_chg_enrt_cd;
        END IF;
      ELSE
        p_tco_chg_enrt_cd :=  pnip_tco_chg_enrt_cd;
      END IF;
      -- -------------------------------------------------------
      -- set: p_ler_chg_oipl_found_flag and p_ler_chg_found_flag
      -- -------------------------------------------------------
      IF oipl_ler_chg_oipl_enrt_id IS NULL THEN
        p_ler_chg_oipl_found_flag :=  'N';
        IF     plip_ler_chg_plip_enrt_id IS NULL
           AND ptip_ler_chg_ptip_enrt_id IS NULL
           AND pnip_ler_chg_pnip_enrt_id IS NULL
           AND pgm_ler_chg_pgm_enrt_id IS NULL THEN
          p_ler_chg_found_flag :=  'N';
        ELSE
          p_ler_chg_found_flag :=  'Y';
        END IF;
      ELSE
        p_ler_chg_oipl_found_flag :=  'Y';
        p_ler_chg_found_flag :=       'Y';
      END IF;
    END IF;
    hr_utility.set_location( 'p_enrt_cd_level  ' || p_enrt_cd_level , 10) ;
  exception
    --
    when others then
      --
      p_enrt_cd                   := null;
      p_enrt_rl                   := null;
      p_auto_enrt_mthd_rl         := null;
      p_crnt_enrt_prclds_chg_flag := null;
      p_dflt_flag                 := null;
      p_enrt_mthd_cd              := null;
      p_stl_elig_cant_chg_flag    := null;
      p_tco_chg_enrt_cd           := null;
      p_ler_chg_oipl_found_flag   := null;
      p_ler_chg_found_flag        := null;
      raise;
      --
  END determine_ben_settings;
  --
  PROCEDURE determine_enrolment(
    p_previous_eligibility       VARCHAR2,
    p_crnt_enrt_cvg_strt_dt      DATE,
    p_dpnt_cvrd_flag             VARCHAR2,
    p_enrt_cd                    VARCHAR2,
    p_enrt_rl                    NUMBER,
    p_enrt_mthd_cd               VARCHAR2,
    p_auto_enrt_mthd_rl          NUMBER,
    p_effective_date             DATE,
    p_lf_evt_ocrd_dt             DATE DEFAULT NULL,
    p_elig_per_id                NUMBER DEFAULT NULL,
    p_enrt_prclds_chg_flag       VARCHAR2 DEFAULT 'N',
    p_stl_elig_cant_chg_flag     VARCHAR2 DEFAULT 'N',
    p_tco_chg_enrt_cd            VARCHAR2 DEFAULT 'CPOO',
    p_pl_id                      NUMBER,
    p_pgm_id                     NUMBER,
    p_oipl_id                    NUMBER,
    p_opt_id                     NUMBER,
    p_pl_typ_id                  NUMBER,
    p_person_id                  NUMBER,
    p_ler_id                     NUMBER,
    p_business_group_id          NUMBER,
    p_electable_flag         OUT NOCOPY VARCHAR2,
    p_assignment_id              NUMBER,
    p_run_mode                   varchar2 default null,  /* iRec : Added p_run_mode */
    p_update_def_elct_flag       varchar2) IS
    --
    l_proc                     VARCHAR2(80)
                                          := g_package ||
                                               '.determine_enrolment';
    --
    l_result_flag              VARCHAR2(30);
    l_crnt_pl_enrt_cvg_strt_dt DATE;
    l_crnt_opt_cvg_strt_dt     DATE;
    l_pgm_rec                  ben_pgm_f%ROWTYPE;
    l_jurisdiction_code        VARCHAR2(30);
    --
    l_lf_evt_ocrd_dt           DATE := NVL(p_lf_evt_ocrd_dt, p_effective_date);
    l_lf_evt_ocrd_dt_1         DATE                     := l_lf_evt_ocrd_dt -
                                                             1;
    l_enrt_cd                  ben_ler_chg_oipl_enrt_f.enrt_cd%TYPE;
    l_enrt_rl                  ben_ler_chg_oipl_enrt_f.enrt_rl%TYPE;
    l_auto_enrt_mthd_rl        ben_ler_chg_oipl_enrt_f.auto_enrt_mthd_rl%TYPE;
    l_dflt_flag                ben_ler_chg_oipl_enrt_f.dflt_flag%TYPE;
    l_enrt_mthd_cd             ben_ler_chg_pgm_enrt_f.enrt_mthd_cd%TYPE;
    l_stl_elig_cant_chg_flag   ben_ler_chg_oipl_enrt_f.stl_elig_cant_chg_flag%TYPE;
    l_tco_chg_enrt_cd          ben_ler_chg_ptip_enrt_f.tco_chg_enrt_cd%TYPE;
    l_ler_chg_oipl_found_flag  VARCHAR2(30);
    l_ler_chg_found_flag       VARCHAR2(30);
    --
    -- Gets the enrollments in the ptip and option
    --
    -- --
    CURSOR c_enrolled_opts_in_pl_typ IS
      SELECT   pen.enrt_cvg_strt_dt enrt_cvg_strt_dt
      FROM     ben_prtt_enrt_rslt_f pen, ben_pl_f pl, ben_oipl_f oipl
      WHERE    pen.person_id = p_person_id
      AND      pen.business_group_id = p_business_group_id
      AND      pen.effective_end_date = hr_api.g_eot
      AND      l_lf_evt_ocrd_dt_1 BETWEEN pen.enrt_cvg_strt_dt
                   AND pen.enrt_cvg_thru_dt
      AND      pl.pl_id = pen.pl_id
      AND      pl.business_group_id = p_business_group_id
      AND      pl.pl_typ_id = p_pl_typ_id
      AND      oipl.oipl_id = pen.oipl_id
      AND      oipl.opt_id = p_opt_id
      AND      l_lf_evt_ocrd_dt BETWEEN pl.effective_start_date
                   AND pl.effective_end_date
      AND      l_lf_evt_ocrd_dt BETWEEN oipl.effective_start_date
                   AND oipl.effective_end_date
      AND      pen.enrt_cvg_strt_dt < pen.effective_end_date
      AND      pen.sspndd_flag = 'N'
      AND      pen.prtt_enrt_rslt_stat_cd IS NULL
      AND      oipl.business_group_id = p_business_group_id
      AND      (
                    (    pen.pgm_id = p_pgm_id
                     AND p_pgm_id IS NOT NULL)
                 OR (    pen.pgm_id IS NULL
                     AND p_pgm_id IS NULL));
    --
    -- Gets the enrollments in the ptip and option
    --
    --
    CURSOR c_cvrd_opts_in_pl_typ IS
      SELECT   pen.enrt_cvg_strt_dt enrt_cvg_strt_dt
      FROM     ben_prtt_enrt_rslt_f pen,
               ben_pl_f pl,
               ben_oipl_f oipl,
               ben_elig_cvrd_dpnt_f pdp
      WHERE    pdp.dpnt_person_id = p_person_id
      AND      l_lf_evt_ocrd_dt_1 BETWEEN pdp.cvg_strt_dt AND pdp.cvg_thru_dt
      AND      pen.effective_end_date = hr_api.g_eot
      AND      pdp.effective_end_date = hr_api.g_eot
      AND      pdp.business_group_id = p_business_group_id
      AND      pdp.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
      AND      pen.business_group_id = p_business_group_id
      AND      l_lf_evt_ocrd_dt_1 BETWEEN pen.enrt_cvg_strt_dt
                   AND pen.enrt_cvg_thru_dt
      AND      pl.pl_id = pen.pl_id
      AND      pl.business_group_id = p_business_group_id
      AND      pl.pl_typ_id = p_pl_typ_id
      AND      oipl.oipl_id = pen.oipl_id
      AND      oipl.opt_id = p_opt_id
      AND      l_lf_evt_ocrd_dt BETWEEN pl.effective_start_date
                   AND pl.effective_end_date
      AND      l_lf_evt_ocrd_dt BETWEEN oipl.effective_start_date
                   AND oipl.effective_end_date
      AND      pen.enrt_cvg_strt_dt < pen.effective_end_date
      AND      pen.sspndd_flag = 'N'
      AND      pen.prtt_enrt_rslt_stat_cd IS NULL
      AND      oipl.business_group_id = p_business_group_id
      AND      (
                    (    pen.pgm_id = p_pgm_id
                     AND p_pgm_id IS NOT NULL)
                 OR (    pen.pgm_id IS NULL
                     AND p_pgm_id IS NULL));
    --
    --
    CURSOR c_state IS
      SELECT   loc.region_2
      FROM     hr_locations_all loc, per_all_assignments_f asg
      WHERE    loc.location_id = asg.location_id
      AND      asg.person_id = p_person_id
      and      asg.assignment_type <> 'C'
      AND      asg.primary_flag = 'Y'
      AND      l_lf_evt_ocrd_dt BETWEEN asg.effective_start_date
                   AND asg.effective_end_date
      AND      asg.business_group_id = p_business_group_id;
    --
    l_state                    c_state%ROWTYPE;
    --
    --
    CURSOR c_asg IS
      SELECT   asg.assignment_id,
               asg.organization_id
      FROM     per_all_assignments_f asg
      WHERE    person_id = p_person_id
      and      asg.assignment_type <> 'C'
      AND      asg.primary_flag = decode(p_run_mode, 'I',asg.primary_flag, 'Y')   -- iRec
      AND      l_lf_evt_ocrd_dt BETWEEN asg.effective_start_date
                   AND asg.effective_end_date;
    --
    l_asg                      c_asg%ROWTYPE;
    -- Gets the enrolment information for this plan
    --
    --
    CURSOR c_plan_enrolment_info IS
      SELECT   pen.enrt_cvg_strt_dt enrt_cvg_strt_dt
      FROM     ben_prtt_enrt_rslt_f pen
      WHERE    pen.person_id = p_person_id
      AND      pen.business_group_id = p_business_group_id
      AND      pen.prtt_enrt_rslt_stat_cd IS NULL
--      AND      pen.sspndd_flag = 'N' --CFW
      AND      (pen.sspndd_flag = 'N' --CFW
                 OR (pen.sspndd_flag = 'Y' and
                     pen.enrt_cvg_thru_dt = hr_api.g_eot
                    )
               )
      AND      pen.effective_end_date = hr_api.g_eot
      AND      l_lf_evt_ocrd_dt_1 <= pen.enrt_cvg_thru_dt
      AND      pen.enrt_cvg_strt_dt < pen.effective_end_date
      AND      p_pl_id = pen.pl_id
      AND      (
                    (    pen.pgm_id = p_pgm_id
                     AND p_pgm_id IS NOT NULL)
                 OR (    pen.pgm_id IS NULL
                     AND p_pgm_id IS NULL));

    -- added for level

     CURSOR c_plip_enrolment_info IS
      SELECT   pen.enrt_cvg_strt_dt enrt_cvg_strt_dt
      FROM     ben_prtt_enrt_rslt_f pen
      WHERE    pen.person_id = p_person_id
      AND      pen.business_group_id = p_business_group_id
      AND      pen.prtt_enrt_rslt_stat_cd IS NULL
--      AND      pen.sspndd_flag = 'N' --CFW
      AND      (pen.sspndd_flag = 'N' --CFW
                 OR (pen.sspndd_flag = 'Y' and
                     pen.enrt_cvg_thru_dt = hr_api.g_eot
                    )
               )
      AND      pen.effective_end_date = hr_api.g_eot
      AND      l_lf_evt_ocrd_dt_1 <= pen.enrt_cvg_thru_dt
      AND      pen.enrt_cvg_strt_dt < pen.effective_end_date
      AND      p_pl_id = pen.pl_id
      AND      pen.pgm_id = p_pgm_id ;

    --

     CURSOR c_ptip_2_enrolment_info IS
      SELECT   pen.enrt_cvg_strt_dt enrt_cvg_strt_dt
      FROM     ben_prtt_enrt_rslt_f pen
      WHERE    pen.person_id = p_person_id
      AND      pen.business_group_id = p_business_group_id
      AND      pen.prtt_enrt_rslt_stat_cd IS NULL
      AND      pen.effective_end_date = hr_api.g_eot
      AND      l_lf_evt_ocrd_dt_1 <= pen.enrt_cvg_thru_dt
      AND      pen.enrt_cvg_strt_dt < pen.effective_end_date
      AND      g_ptip_id   = pen.ptip_id
      AND      pen.pgm_id = p_pgm_id ;

   ---

     CURSOR c_pgm_enrolment_info IS
      SELECT   pen.enrt_cvg_strt_dt enrt_cvg_strt_dt
      FROM     ben_prtt_enrt_rslt_f pen
      WHERE    pen.person_id = p_person_id
      AND      pen.business_group_id = p_business_group_id
      AND      pen.prtt_enrt_rslt_stat_cd IS NULL
      AND      pen.effective_end_date = hr_api.g_eot
      AND      l_lf_evt_ocrd_dt_1 <= pen.enrt_cvg_thru_dt
      AND      pen.enrt_cvg_strt_dt < pen.effective_end_date
      AND      pen.pgm_id = p_pgm_id ;


    -- Bug#2108168 - Check for current enrollment in a waive plan
    CURSOR c_ptip_waive_enrolment_info IS
      SELECT   pen.enrt_cvg_strt_dt
      FROM     ben_prtt_enrt_rslt_f pen, ben_pl_f pln
      WHERE    pen.person_id = p_person_id
      AND      pen.business_group_id = p_business_group_id
      AND      pen.prtt_enrt_rslt_stat_cd IS NULL
      AND      pen.sspndd_flag = 'N'
      AND      pen.effective_end_date = hr_api.g_eot
      AND      l_lf_evt_ocrd_dt_1 <= pen.enrt_cvg_thru_dt
      AND      pen.enrt_cvg_strt_dt < pen.effective_end_date
      AND      g_ptip_id = pen.ptip_id
      AND      pln.pl_id = pen.pl_id
      AND      pln.invk_dcln_prtn_pl_flag = 'Y'
      AND      l_lf_evt_ocrd_dt BETWEEN pln.effective_start_date
                   AND pln.effective_end_date;

    -- Gets the enrolment information for this plan
    --
    --
    CURSOR c_plan_cvg_info IS
      SELECT   pen.enrt_cvg_strt_dt enrt_cvg_strt_dt
      FROM     ben_prtt_enrt_rslt_f pen, ben_elig_cvrd_dpnt_f pdp
      WHERE    pdp.dpnt_person_id = p_person_id
      AND      pen.effective_end_date = hr_api.g_eot
      AND      pdp.effective_end_date = hr_api.g_eot
      AND      l_lf_evt_ocrd_dt_1 BETWEEN pdp.cvg_strt_dt AND pdp.cvg_thru_dt
      AND      pdp.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
      AND      pen.business_group_id = p_business_group_id
      AND      pen.prtt_enrt_rslt_stat_cd IS NULL
      -- AND      pen.sspndd_flag = 'N'
      AND      (pen.sspndd_flag = 'N' --CFW
                 OR (pen.sspndd_flag = 'Y' and
                     pen.enrt_cvg_thru_dt = hr_api.g_eot
                    )
               )
      AND      l_lf_evt_ocrd_dt_1 <= pen.enrt_cvg_thru_dt
      AND      pen.enrt_cvg_thru_dt < pen.effective_end_date
      AND      p_pl_id = pen.pl_id
      AND      (
                    (    pen.pgm_id = p_pgm_id
                     AND p_pgm_id IS NOT NULL)
                 OR (    pen.pgm_id IS NULL
                     AND p_pgm_id IS NULL));
    --
    -- Gets the enrolment information for the ptip in which the plan belongs
    --
    CURSOR c_ptip_enrolment_info IS
      SELECT   pen.pl_id,
               pen.oipl_id,
               plip.plip_id
      FROM     ben_prtt_enrt_rslt_f pen, ben_plip_f plip
      WHERE    pen.person_id = p_person_id
      AND      pen.business_group_id = p_business_group_id
      AND      pen.prtt_enrt_rslt_stat_cd IS NULL
      --AND      pen.sspndd_flag = 'N'
      AND      (pen.sspndd_flag = 'N' --CFW
                 OR (pen.sspndd_flag = 'Y' and
                     pen.enrt_cvg_thru_dt = hr_api.g_eot
                    )
               )
      AND      pen.effective_end_date = hr_api.g_eot
      AND      l_lf_evt_ocrd_dt_1 <= pen.enrt_cvg_thru_dt
      AND      pen.enrt_cvg_strt_dt < pen.effective_end_date
      AND      g_ptip_id = pen.ptip_id
      AND      plip.pgm_id = pen.pgm_id
      AND      plip.pl_id = pen.pl_id
      AND      l_lf_evt_ocrd_dt BETWEEN plip.effective_start_date
                   AND plip.effective_end_date;
    --
     CURSOR c_plip_info IS
      SELECT   bpf.plip_id
      FROM     ben_plip_f bpf
      WHERE    bpf.pl_id = p_pl_id
      AND      bpf.pgm_id = p_pgm_id
      AND      bpf.business_group_id = p_business_group_id
      AND      l_lf_evt_ocrd_dt BETWEEN bpf.effective_start_date
                   AND bpf.effective_end_date;

    --
    l_plip_id                  number ;
    l_enrolled_ptip            c_ptip_enrolment_info%ROWTYPE;
    --
    /*
    cursor c_prclds_flag
    is
    select
           nvl(oipl.crnt_enrt_prclds_chg_flag,
             nvl(pl_nip.crnt_enrt_prclds_chg_flag,
               nvl(plip.crnt_enrt_prclds_chg_flag,
                 nvl(ptip.crnt_enrt_prclds_chg_flag,
                     pgm.crnt_enrt_prclds_chg_flag)))) crnt_enrt_prclds_chg_flag
    from   dual,
           ben_ler_chg_pl_nip_enrt_f pl_nip,
           ben_ler_chg_pgm_enrt_f    pgm,
           ben_ler_chg_ptip_enrt_f   ptip,
           ben_ler_chg_plip_enrt_f   plip,
           ben_ler_chg_oipl_enrt_f   oipl
    where
           pl_nip.pl_id(+)=l_enrolled_ptip.pl_id and
           pl_nip.business_group_id(+)=p_business_group_id and
           pl_nip.ler_id(+)=decode(dual.dummy,dual.dummy,p_ler_id,dual.dummy) and
           l_lf_evt_ocrd_dt between
             pl_nip.effective_start_date(+) and pl_nip.effective_end_date(+) and
           ptip.ptip_id(+)=g_ptip_id and
           ptip.business_group_id(+)=p_business_group_id and
           ptip.ler_id(+)=decode(dual.dummy,dual.dummy,p_ler_id,dual.dummy) and
           l_lf_evt_ocrd_dt between
             ptip.effective_start_date(+) and ptip.effective_end_date(+) and
           pgm.pgm_id(+)=p_pgm_id and
           pgm.business_group_id(+)=p_business_group_id and
           pgm.ler_id(+)=decode(dual.dummy,dual.dummy,p_ler_id,dual.dummy) and
           l_lf_evt_ocrd_dt between
             pgm.effective_start_date(+) and pgm.effective_end_date(+) and
           plip.plip_id(+)=l_enrolled_ptip.plip_id and
           plip.business_group_id(+)=p_business_group_id and
           plip.ler_id(+)=decode(dual.dummy,dual.dummy,p_ler_id,dual.dummy) and
           l_lf_evt_ocrd_dt between
             plip.effective_start_date(+) and plip.effective_end_date(+) and
           oipl.oipl_id(+) = l_enrolled_ptip.oipl_id and
           oipl.business_group_id(+) = p_business_group_id and
           oipl.ler_id(+)=decode(dual.dummy,dual.dummy,p_ler_id,dual.dummy) and
           l_lf_evt_ocrd_dt between
             oipl.effective_start_date(+) and oipl.effective_end_date(+);
    */
    l_ptip_prclds_flag         VARCHAR2(30);
    l_enrt_cd_level            VARCHAR2(30);
    l_enrt_cvg_date            date ;

    --- determine the current enrollment according to the level


  --
  BEGIN
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    hr_utility.set_location('Entering: ' || l_proc, 10);
  end if;
--  hr_utility.set_location('enrt_mthd_cd='||p_enrt_mthd_cd,11);
--  hr_utility.set_location('auto_enrt_mthd_rl='||p_auto_enrt_mthd_rl,13);
--  hr_utility.set_location('enrt_cd='||p_enrt_cd,12);
  --
  --  Get program record.
  --
    IF p_pgm_id IS NOT NULL THEN
      ben_comp_object.get_object(p_pgm_id => p_pgm_id, p_rec => l_pgm_rec);
      if g_debug then
      hr_utility.set_location('Done PGM NN: ' || l_proc, 10);
      end if;
    END IF;
--
-- Check the tco_chg_enrt_cd if this comp object can be changed
--
-- Note: "enrolled in option" only includes option within plans of
--       the same plan type.
--
--              | Is enrolled | Is Not         | Is enrolled | Is not enrolled
-- Level TCO_CD | in plan     | enrolled in pl | in option   | in option
-- ----- -------+-------------+----------------+-------------+----------------
-- oipl  CPOO   | Y           | Y              | Y           | Y
-- oipl  CPNO   | n/a         | n/a            | Y           | N
-- oipl  CONP   | Y           | N              | n/a         | n/a
-- ----- -------+-------------+----------------+-------------+----------------
-- pl    CPOO   | Y           | Y              | Y           | Y
-- pl    CPNO   | Y           | Y              | Y           | Y
-- pl    CONP   | Y           | N              | n/a         | n/a
--
/* -- 4031733 - Cursor c_state populates l_state variable which is no longer
   -- used in the package. Cursor can be commented

    IF p_person_id IS NOT NULL THEN
      OPEN c_state;
      FETCH c_state INTO l_state;
      CLOSE c_state;
      hr_utility.set_location('close c_state: ' || l_proc, 9999);
      --IF l_state.region_2 IS NOT NULL THEN
      --  l_jurisdiction_code :=
      --    pay_mag_utils.lookup_jurisdiction_code(p_state => l_state.region_2);
      --END IF;
    END IF;
*/

    OPEN c_asg;
    FETCH c_asg INTO l_asg;
    IF c_asg%NOTFOUND THEN
      CLOSE c_asg;
      fnd_message.set_name('BEN', 'BEN_92106_PRTT_NO_ASGN');
      fnd_message.set_token('PROC', l_proc);
      fnd_message.set_token('PERSON_ID', TO_CHAR(p_person_id));
      fnd_message.set_token('LF_EVT_OCRD_DT', TO_CHAR(p_lf_evt_ocrd_dt));
      fnd_message.set_token('EFFECTIVE_DATE', TO_CHAR(p_effective_date));
      RAISE ben_manage_life_events.g_record_error;
    END IF;
    CLOSE c_asg;
    if g_debug then
    hr_utility.set_location('close c_asg: ' || l_proc, 10);
    end if;
    IF p_oipl_id IS NOT NULL THEN
      IF p_tco_chg_enrt_cd = 'CONP' THEN
        --
        OPEN c_plan_enrolment_info;
        FETCH c_plan_enrolment_info INTO l_crnt_pl_enrt_cvg_strt_dt;
        IF c_plan_enrolment_info%NOTFOUND THEN
          --
          open c_ptip_waive_enrolment_info;
          fetch c_ptip_waive_enrolment_info into l_crnt_pl_enrt_cvg_strt_dt;
          if c_ptip_waive_enrolment_info%NOTFOUND then
            IF p_pgm_id IS NOT NULL THEN
                --
                --  When processing the COBRA, also check the elig_cvrd_dpnt
                --  table as dependents can make independent elections.
                --
              IF l_pgm_rec.pgm_typ_cd LIKE 'COBRA%' THEN
                OPEN c_plan_cvg_info;
                FETCH c_plan_cvg_info INTO l_crnt_pl_enrt_cvg_strt_dt;
                CLOSE c_plan_cvg_info;
              END IF;
            END IF;
            --
          end if;
          close c_ptip_waive_enrolment_info;
        END IF;
        --
        CLOSE c_plan_enrolment_info;
      --
      ELSIF p_tco_chg_enrt_cd = 'CPNO' THEN
        --
	if g_debug then
        hr_utility.set_location('pl_typ_id=' || p_pl_typ_id, 1963);
        hr_utility.set_location('opt_id=' || p_opt_id, 1963);
        hr_utility.set_location(
          'crnt_opt_cvg_strt_dt=' || l_crnt_opt_cvg_strt_dt,
          1963);
        end if;
        OPEN c_enrolled_opts_in_pl_typ;
        FETCH c_enrolled_opts_in_pl_typ INTO l_crnt_opt_cvg_strt_dt;
	if g_debug then
        hr_utility.set_location(
          'crnt_opt_cvg_strt_dt=' || l_crnt_opt_cvg_strt_dt,
          1963);
        end if;
        IF c_enrolled_opts_in_pl_typ%NOTFOUND THEN
          IF p_pgm_id IS NOT NULL THEN
            --
            --  When processing the COBRA, also check the elig_cvrd_dpnt
            --  table as dependents can make independent elections.
            --
            IF l_pgm_rec.pgm_typ_cd LIKE 'COBRA%' THEN
              OPEN c_cvrd_opts_in_pl_typ;
              FETCH c_cvrd_opts_in_pl_typ INTO l_crnt_opt_cvg_strt_dt;
	      if g_debug then
              hr_utility.set_location(
                'crnt_opt_cvg_strt_dt=' || l_crnt_opt_cvg_strt_dt,
                1963);
              end if;
              CLOSE c_cvrd_opts_in_pl_typ;
            END IF;
          END IF;
        END IF;
        CLOSE c_enrolled_opts_in_pl_typ;
      END IF;
    --
    END IF;
    if g_debug then
    hr_utility.set_location('Done p_oipl NN ' || l_proc, 10);
    end if;
    --
    IF NOT (
                (                                                  -- eval oipl
                      p_oipl_id IS NOT NULL
                  AND (                         -- can change plan or option or
                           p_tco_chg_enrt_cd = 'CPOO'
                        OR (           -- change plan only and enrolled in oipl
                                 p_tco_chg_enrt_cd = 'CPNO'
                             AND l_crnt_opt_cvg_strt_dt IS NOT NULL)
                        OR (         -- change option only and enrolled in plan
                                 p_tco_chg_enrt_cd = 'CONP'
                             AND l_crnt_pl_enrt_cvg_strt_dt IS NOT NULL)))
             OR (                                                    -- eval pl
                      p_oipl_id IS NULL
                  AND (                            -- change plan or/not option
                           p_tco_chg_enrt_cd IN ('CPOO', 'CPNO')
                        OR (         -- change option only and enrolled in plan
                                 p_tco_chg_enrt_cd = 'CONP'
                             AND (
                                      p_crnt_enrt_cvg_strt_dt IS NOT NULL
                                   OR p_dpnt_cvrd_flag = 'Y'))))) THEN
      --
      p_electable_flag :=  'N';
      --
      if g_debug then
      hr_utility.set_location(' Leaving:' || l_proc, 5);
      end if;
      --
      RETURN;
    --
    END IF;
    --
    -- If stl_elig_cant_chg_flag is set to Y and
    -- previous_eligibility is true, Done, not electable.
    --
    IF (    p_stl_elig_cant_chg_flag = 'Y'
        AND p_previous_eligibility = 'Y') THEN
      --
      p_electable_flag :=  'N';
      --
      if g_debug then
      hr_utility.set_location(' Leaving:' || l_proc, 10);
      end if;
      --
      RETURN;
    --
    END IF;
    -- if P_ENRT_PRCLDS_CHG_FLAG is true and person is
    -- currently enrolled, this choice is NOT electable.  DONE.
    -- bug 5216 - check across ptip for enrollment.  If enrolled
    -- in ptip then use this flag from that comp object.
    -- if set to Y then nothing in ptip is electable.
    --
    IF (    p_enrt_prclds_chg_flag = 'Y'
        AND p_crnt_enrt_cvg_strt_dt IS NOT NULL) THEN
      --
      p_electable_flag :=  'N';
      --
      if g_debug then
      hr_utility.set_location(' Returning:' || l_proc, 15);
      end if;
      --
      RETURN;
    --
    ELSE
      -- get the plip id from the pgm and pl not from the enrollment data
      open c_plip_info ;
      fetch c_plip_info into l_plip_id ;
      close c_plip_info ;

       determine_ben_settings(
          p_pl_id                     => p_pl_id,         --l_enrolled_ptip.pl_id,
          p_ler_id                    => p_ler_id,
          p_lf_evt_ocrd_dt            => l_lf_evt_ocrd_dt,
          p_ptip_id                   => g_ptip_id,
          p_pgm_id                    => p_pgm_id,
          p_plip_id                   => l_plip_id ,     --l_enrolled_ptip.plip_id,
          p_oipl_id                   => p_oipl_id ,     --l_enrolled_ptip.oipl_id,
          p_just_prclds_chg_flag      => TRUE,
          p_enrt_cd                   => l_enrt_cd,
          p_enrt_rl                   => l_enrt_rl,
          p_auto_enrt_mthd_rl         => l_auto_enrt_mthd_rl,
          p_crnt_enrt_prclds_chg_flag => l_ptip_prclds_flag,
          p_dflt_flag                 => l_dflt_flag,
          p_enrt_mthd_cd              => l_enrt_mthd_cd,
          p_stl_elig_cant_chg_flag    => l_stl_elig_cant_chg_flag,
          p_tco_chg_enrt_cd           => l_tco_chg_enrt_cd,
          p_ler_chg_oipl_found_flag   => l_ler_chg_oipl_found_flag,
          p_ler_chg_found_flag        => l_ler_chg_found_flag,
          p_enrt_cd_level             => l_enrt_cd_level );

          if g_debug then
          hr_utility.set_location( 'l_enrt_cd_level ' || l_enrt_cd_level , 99 );
          hr_utility.set_location( 'enrt_cd ' || p_enrt_cd  , 99 );
          end if;
          --- check the level of enrollment code and intialise the coverage date
          if  l_enrt_cd_level = 'OIPL'   then
              l_enrt_cvg_date := p_crnt_enrt_cvg_strt_dt ;
          elsif  l_enrt_cd_level = 'PL'  then
              if p_oipl_id is null then
                 l_enrt_cvg_date := p_crnt_enrt_cvg_strt_dt ;
              else
                 OPEN c_plan_enrolment_info;
                 FETCH c_plan_enrolment_info INTO l_enrt_cvg_date;
                 close  c_plan_enrolment_info ;
              end if ;
          elsif  l_enrt_cd_level = 'PLIP'  then
                 OPEN  c_plip_enrolment_info;
                 FETCH c_plip_enrolment_info INTO l_enrt_cvg_date;
                 close c_plip_enrolment_info ;
          elsif  l_enrt_cd_level = 'PTIP'  then
                 OPEN  c_ptip_2_enrolment_info;
                 FETCH c_ptip_2_enrolment_info INTO l_enrt_cvg_date;
                 close c_ptip_2_enrolment_info ;
          elsif  l_enrt_cd_level = 'PGM'  then
                 OPEN  c_pgm_enrolment_info;
                 FETCH c_pgm_enrolment_info INTO l_enrt_cvg_date;
                 close c_pgm_enrolment_info ;
          else
                l_enrt_cvg_date := p_crnt_enrt_cvg_strt_dt ;
          end if ;
	  if g_debug then
          hr_utility.set_location( 'l_enrt_cvg_date ' || l_enrt_cvg_date , 99 );
	  end if;
          ----


      -- check if enrolled in ptip
      if g_debug then
      hr_utility.set_location(' Op c_ptip_enr_inf'||l_proc, 15);
      end if;
      OPEN c_ptip_enrolment_info;
      FETCH c_ptip_enrolment_info INTO l_enrolled_ptip;
      if g_debug then
      hr_utility.set_location(' Dn Fet c_ptip_enr_inf'||l_proc, 15);
      end if;
      IF c_ptip_enrolment_info%FOUND THEN
      if g_debug then
         hr_utility.set_location('CHKPTIPENRT found', 10);
      end if;
         IF l_ptip_prclds_flag = 'Y' THEN
	 if g_debug then
            hr_utility.set_location('CHKPTIPENRT prclds', 10);
         end if;
            p_electable_flag :=  'N';
            --
	    if g_debug then
            hr_utility.set_location(' Leaving:' || l_proc, 19);
	    end if;
            --
            RETURN;
            --
         END IF;
      END IF;
      CLOSE c_ptip_enrolment_info;
    END IF;
    -- If the enrt_cd is rule
    if g_debug then
    hr_utility.set_location('EC=RL: ' || l_proc, 10);
    end if;
    IF (p_enrt_cd = 'RL') THEN
      -- 5092244 : commented the following code
     /* if p_update_def_elct_flag is not null then -- don't reevaluate the rule again
        --
        p_electable_flag := p_update_def_elct_flag;
        RETURN;
        --
      end if;*/
      l_result_flag :=
       execute_enrt_rule(
         p_opt_id            => p_opt_id,
         p_pl_id             => p_pl_id,
         p_pgm_id            => p_pgm_id,
         p_rule_id           => p_enrt_rl,
         p_ler_id            => p_ler_id,
         p_pl_typ_id         => p_pl_typ_id,
         p_business_group_id => p_business_group_id,
         p_effective_date    => p_effective_date,
         p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
         p_elig_per_id       => p_elig_per_id,
         p_assignment_id     => p_assignment_id,
         p_organization_id   => l_asg.organization_id,
         p_jurisdiction_code => l_jurisdiction_code,
	 p_person_id         => p_person_id              -- Bug 5331889
	 );
      --
      IF (l_result_flag = 'N') THEN
        --
        p_electable_flag :=  'N';
        --
	if g_debug then
        hr_utility.set_location(' Leaving:' || l_proc, 20);
	end if;
        --
        RETURN;
      --
      ELSIF l_result_flag = 'L' THEN
        --
        -- L will be used for Lose only functionality.
        --
        p_electable_flag :=  'L';
	if g_debug then
        hr_utility.set_location(' Leaving:' || l_proc, 21);
	end if;
        --
        RETURN;
      --
      END IF;
    --
    ELSIF    p_enrt_cd = 'CLONN'
          OR (
                   p_enrt_cd in ('CLNCC','CNNA')
               AND  l_enrt_cvg_date IS NOT NULL
               AND p_dpnt_cvrd_flag = 'N') THEN
      --
      -- Just return L.  This will trigger
      -- call to ben_newly_ineligible.
      -- which will either do nothing or deenroll
      --
      p_electable_flag :=  'L';
      --
      RETURN;
    --
    ELSE                                                    -- p_enrt_cd = 'RL'
    if g_debug then
      hr_utility.set_location('Else EC=RL: ' || l_proc, 10);
    end if;
-- If the combination of enrt_cd and eligibility status is YES in the
-- following matrix then the choice is electable
-- (continue to create choice),
-- else it is not electable.  (DONE).
--
--                   Create Choice?
-- ENRT_CD     Not enrolled     Enrolled  Note
-- CKNCC           YES             NO
-- CCONCC          YES             YES    Duplicate with below
-- CCKCNCC         YES             YES    Duplicate with above
-- CCKCSNCC        YES             YES    Duplicate with above
-- CLNCC           YES             NO     *Should not be eligible
-- CCKCNN          NO              YES    Duplicate with below
-- CCONN           NO              YES    Duplicate with above
-- CKNN            NO              NO
-- CLONN           NO              NO     *Should not be eligible
--
-- particles
--
-- Part   Description
-- CCKC   current can keep or choose
-- CCO    Same as above
-- CK     current must keep
-- CL     current will loose
-- CLO    Same as above
-- NCC    new can choose
-- NN     new cannot choose
--
      IF NOT (                               -- currently enrolled and eligible
                  (
                        (
                              l_enrt_cvg_date IS NOT NULL
                          OR p_dpnt_cvrd_flag = 'Y')
                    AND p_enrt_cd IN ('CCONCC', 'CCKCNN', 'CCONN', 'CCKCNCC','CCKCSNCC'))
               OR
                  -- not enrolled, but eligible
                  (
                        (
                               l_enrt_cvg_date IS NULL
                          AND p_dpnt_cvrd_flag = 'N')
                    AND p_enrt_cd IN ('CKNCC', 'CCONCC', 'CLNCC', 'CCKCNCC','CCKCSNCC'))) THEN
        --
        p_electable_flag :=  'N';
        --
	if g_debug then
        hr_utility.set_location(' Leaving:' || l_proc, 25);
	end if;
        --
        RETURN;
      --
      END IF;                                                  -- enrt_cd table
    --
    END IF;                                                     -- p_enrt_cd=RL
    --
    p_electable_flag :=  'Y';
    --
    if g_debug then
    hr_utility.set_location(' Leaving:' || l_proc, 30);
    end if;
    --
    RETURN;
  --
  exception  -- nocopy changes
    --
    when others then
      --
      p_electable_flag := null;
      raise;
      --
  END determine_enrolment;
--
-- cwb changes
procedure get_cwb_manager_and_assignment
             (p_person_id in number,
              p_hrchy_to_use_cd in varchar2,
              p_pos_structure_version_id in number,
              p_effective_date in date,
              p_manager_id out nocopy number,
              p_assignment_id out nocopy number )
  is
  --
  --Bug 2827121 Manager can be a contingent worker also.
  cursor c_get_assignment is
    select assignment_id,
           position_id,
           supervisor_id
    from per_all_assignments_f
    where person_id = p_person_id
    and primary_flag = 'Y'
    and assignment_type in ( 'E','C' )  -- Bug 2827121
    and p_effective_date
      between effective_start_date and effective_end_date;
  --
  l_get_assignment   c_get_assignment%rowtype;
  --
  cursor c_parent_position_id (p_position_id number)
    is
    select parent_position_id
    from per_pos_structure_elements
    where subordinate_position_id = p_position_id
    and   pos_structure_version_id = p_pos_structure_version_id;
  --
  cursor c_manager_id (p_position_id number)
    is
    select person_id
    from per_all_assignments_f ass,
         per_assignment_status_types ast
    where  ass.position_id = p_position_id
    and    ass.primary_flag = 'Y'
    and ass.assignment_type in ( 'E' , 'C' ) -- Bug 2827121
    and p_effective_date
      between ass.effective_start_date and ass.effective_end_date
    --Bug 3044311 -- Need to verify what other system types should be considered.
    and ass.assignment_status_type_id = ast.assignment_status_type_id
    -- and ast.active_flag = 'Y'
    and ast.per_system_status in ('ACTIVE_ASSIGN','SUSP_ASSIGN') ;
    --
  --
  l_parent_position_id   number(15);
  l_manager_id           number(15);
  l_assignment_id        number(15);

  l_position_id          number(15);
Begin
  --
  g_debug := hr_utility.debug_enabled;
  open c_get_assignment;
  fetch c_get_assignment into l_get_assignment;
  close c_get_assignment;
  --
  l_assignment_id := l_get_assignment.assignment_id;
  --
  if p_hrchy_to_use_cd = 'S' then
    l_manager_id := l_get_assignment.supervisor_id;
  elsif p_hrchy_to_use_cd = 'P' then

    -- Start Bug 2684227
    -- Upon a vacancy, continue to climb the position hierarchy
    -- until a person is found

    l_position_id :=  l_get_assignment.position_id;

    loop
      open c_parent_position_id(l_position_id);
      fetch c_parent_position_id into l_parent_position_id;
      exit when c_parent_position_id%notfound;
      close c_parent_position_id;
      if l_parent_position_id is not null then
        open c_manager_id (l_parent_position_id);
        fetch c_manager_id into l_manager_id;
        close c_manager_id;
        if  l_manager_id is not null then
          exit;
        end if;
      end if;

      l_position_id := l_parent_position_id;
    end loop;

    -- End Bug 2684227
    --
    --
    -- Bug 2230922 : If manager id not found then default to supervisor.
    --
    if l_manager_id is null then
       --
       l_manager_id := l_get_assignment.supervisor_id;
       --
    end if;
    --
 end if;
 --
 p_manager_id := l_manager_id;
 p_assignment_id := l_assignment_id;
 --
exception  -- nocopy changes
  --
  when others then
    --
    p_manager_id:= null;
    p_assignment_id := null;
    raise;
    --
end get_cwb_manager_and_assignment;
-------------------------
-- 2746865
-- separate procedure instead of inline code
procedure enrt_perd_strt_dt
  (p_person_id 				in 	number
   ,p_lf_evt_ocrd_dt 			in 	date
   ,p_enrt_perd_det_ovrlp_bckdt_cd 	in 	varchar2
   ,p_business_group_id                 in      number
   ,p_ler_id                            in      number
   ,p_effective_date                    in      date
   ,p_rec_enrt_perd_strt_dt 		in out 	nocopy date
   )
IS
  -- local variables
  l_proc             varchar2 (72) := g_package || 'enrt_perd_strt_dt';
  l_latest_procd_dt  date;
  l_backed_out_date  date;
  l_latest_enrt_dt   date;
  l_lf_evt_ocrd_dt   date := NVL(p_lf_evt_ocrd_dt, p_effective_date);
  -- store sysdate sans the time component into a local variable for once
  l_sysdate          date := trunc(sysdate);
  -- define cursors
  CURSOR c_get_latest_procd_dt IS
    SELECT   MAX(pil.procd_dt)
    FROM     ben_per_in_ler pil
            -- CWB changes
            ,ben_ler_f      ler
    WHERE    pil.person_id = p_person_id
    AND      pil.ler_id    = ler.ler_id
    and      ler.typ_cd   not in ('COMP','ABS', 'GSP', 'IREC','SCHEDDU')
    and      l_lf_evt_ocrd_dt between
             ler.effective_start_date and ler.effective_end_date
    AND      pil.business_group_id = p_business_group_id
    AND      pil.per_in_ler_stat_cd NOT IN ('BCKDT', 'VOIDD')
    AND      pil.procd_dt IS NOT NULL;
  --
  CURSOR c_backed_out_ler IS
    SELECT   MAX(pil.bckt_dt)
    FROM     ben_per_in_ler pil
            -- CWB changes
            ,ben_ler_f      ler
            ,ben_ptnl_ler_for_per  plr
    WHERE    pil.person_id = p_person_id
    AND      pil.ler_id    = ler.ler_id
    and      ler.typ_cd   not in ('COMP','ABS', 'GSP', 'IREC','SCHEDDU')
    and      l_lf_evt_ocrd_dt between
             ler.effective_start_date and ler.effective_end_date
    AND      pil.business_group_id = p_business_group_id
    AND      pil.ler_id = p_ler_id
    AND      pil.lf_evt_ocrd_dt = p_lf_evt_ocrd_dt
    AND      pil.bckt_dt IS NOT NULL
    and      pil.per_in_ler_stat_cd = 'BCKDT' -- 3063867
    and      pil.ptnl_ler_for_per_id   = plr.ptnl_ler_for_per_id  --3248770
    and      plr.ptnl_ler_for_per_stat_cd <> 'VOIDD' ;
  --

  -- 2746865
  -- cursor to select a person's maximum enrollment start date
  -- Changed the following cursor for bug 3137519 to exclude GSP/ABS/COMP ler types.
  -- Also included status no in backdt/voidd clause
  --bug#3697378 - discussed with Phil why we add + 1 to the latest enrollment
  --however he wanted this to be removed so that self service open enrollment
  --will not be impacted and asked find ways to show history on enrollment results later
  cursor c_get_latest_enrt_dt is
    select max(rslt.effective_start_date)
    from   ben_prtt_enrt_rslt_f rslt,ben_ler_f ler
     where  rslt.person_id = p_person_id
    and ler.ler_id=rslt.ler_id
  --  and rslt.prtt_enrt_rslt_stat_cd NOT IN ('BCKDT', 'VOIDD')
    and rslt.prtt_enrt_rslt_stat_cd is null
    and   ler.typ_cd   not in ('COMP','ABS', 'GSP', 'IREC','SCHEDDU' )
    and    rslt.business_group_id = p_business_group_id
    and rslt.enrt_cvg_thru_dt = hr_api.g_eot; -- Bug 4388226 - End-dated suspended enrl shudn't be picked up.

  --

  begin

  -- following are the 4 codes used for enrt. period determination
  -------------------------------------------------------------------------
  -- L_EPSD_PEPD 	- Later of Enrollment period start date and
  --		 	  prior event processed date
  -- L_EPSD_PEESD 	- Later of Enrollment period start date and
  --		 	  One day after prior event elections start date
  -- L_EPSD_PEESD_BCKDT - Later of Enrollment period start date and One
  --			  day after prior event elections start date and
  --			  current events backed out date
  -- L_EPSD_PEESD_SYSDT - Later of Enrollment period start date and One
  --			  day after prior event elections start date
  --			  and system date
  -------------------------------------------------------------------------
  -- if cd is L_EPSD_PEPD, use the old logic
  hr_utility.set_location(' Entering '||l_proc, 10);
  --
  -- remove all these debug messages
  hr_utility.set_location(' p_enrt_perd_det_ovrlp_bckdt_cd is  '||p_enrt_perd_det_ovrlp_bckdt_cd, 987);
  hr_utility.set_location(' p_person_id '||p_person_id, 10);
  hr_utility.set_location(' p_lf_evt_ocrd_dt '||p_lf_evt_ocrd_dt, 10);
  hr_utility.set_location(' p_ler_id '||p_ler_id, 10);
  hr_utility.set_location(' p_effective_date '||p_effective_date, 10);
  hr_utility.set_location(' p_rec_enrt_perd_strt_dt '||p_rec_enrt_perd_strt_dt, 10);
  --

  IF nvl(p_enrt_perd_det_ovrlp_bckdt_cd, 'L_EPSD_PEPD') = 'L_EPSD_PEPD' THEN
    --
    hr_utility.set_location(' L_EPSD_PEPD', 987);
    OPEN c_get_latest_procd_dt;
    FETCH c_get_latest_procd_dt INTO l_latest_procd_dt;
    -- new epsd is greater of epsd or latest_procd_dt
    -- IF c_get_latest_procd_dt%FOUND THEN
    IF l_latest_procd_dt IS NOT NULL THEN
      hr_utility.set_location(' c_get_latest_procd_dt%found', 987);
      hr_utility.set_location('l_latest_procd_dt is '||l_latest_procd_dt, 987);
      -- jcarpent 1/4/2001 bug 1568555, removed +1 from line below
      IF p_rec_enrt_perd_strt_dt < l_latest_procd_dt THEN
        hr_utility.set_location('l_latest_procd_dt made enrt strt dt ', 987);
        -- jcarpent 1/4/2001 bug 1568555, removed +1 from line below
        p_rec_enrt_perd_strt_dt :=  l_latest_procd_dt;
        -- if the enrollment  exist for the previous LE
        -- start the window latest_procd_dt + 1
        -- or the previous enrollment will be updated in correction mode
        -- and backout of this LE will remove the previous LE results
        --the  changes are backedout  3086161
        --
        --Bugs 3972973 and 3978745 fixes.
        --If the enrollment starts after the processed date we need to consider the
        --latest enrollment date.
        --
      End IF;
      --bug#4478186 - enrl start date should always be equal or greater to latest
      --enrt dt
      OPEN c_get_latest_enrt_dt;
      FETCH c_get_latest_enrt_dt into l_latest_enrt_dt;
      close c_get_latest_enrt_dt ;
      --
      if l_latest_enrt_dt is not null and  l_latest_enrt_dt > p_rec_enrt_perd_strt_dt then
         p_rec_enrt_perd_strt_dt := l_latest_enrt_dt ;
      end if ;
        --
    END IF;
    CLOSE c_get_latest_procd_dt;
    -- 4 is new epsd <= p_lf_evt_ocrd_dt?
    IF p_rec_enrt_perd_strt_dt <= p_lf_evt_ocrd_dt THEN
      -- 5 is there a backed out le for the current ler and ...
      OPEN c_backed_out_ler;
      FETCH c_backed_out_ler INTO l_backed_out_date;
      --IF c_backed_out_ler%FOUND THEN
      IF l_backed_out_date is NOT NULL THEN
        hr_utility.set_location(' c_backed_out_ler%found', 987);
        hr_utility.set_location('l_backed_out_date is '||l_backed_out_date, 987);
        -- 5a ... and is the backed-out date > than the new epsd?
        IF l_backed_out_date > p_rec_enrt_perd_strt_dt THEN
          hr_utility.set_location('l_backed_out_date made enrt strt dt ', 987);
          -- 6 it is the new epsd.
          p_rec_enrt_perd_strt_dt :=  l_backed_out_date;
        END IF;
      END IF;
      CLOSE c_backed_out_ler;
    END IF;
    -- 2746865
    -- if cd is L_EPSD_PEESD%, use the new logic
  ELSIF p_enrt_perd_det_ovrlp_bckdt_cd like  'L_EPSD_PEESD%' THEN
    hr_utility.set_location('  L_EPSD_PEESD%', 987);
    -- get the person's latest enrollment start date +1
    OPEN c_get_latest_enrt_dt;
      FETCH c_get_latest_enrt_dt into l_latest_enrt_dt;
      -- IF c_get_latest_enrt_dt%FOUND THEN --changed as its always found
      IF l_latest_enrt_dt is not null THEN
        hr_utility.set_location(' c_get_latest_enrt_dt%FOUND', 987);
        hr_utility.set_location('l_latest_enrt_dt is '||l_latest_enrt_dt, 987);
        -- if latest enrt dt is greater than epsd, make it the epsd
        IF l_latest_enrt_dt > p_rec_enrt_perd_strt_dt THEN
          p_rec_enrt_perd_strt_dt := l_latest_enrt_dt;
          hr_utility.set_location('l_latest_enrt_dt substituted', 987);
        END IF;
      END IF;
      CLOSE c_get_latest_enrt_dt;
      -- cd is 2 find the bckdt out dt
      IF p_enrt_perd_det_ovrlp_bckdt_cd = 'L_EPSD_PEESD_BCKDT' THEN
        hr_utility.set_location('L_EPSD_PEESD_BCKDT entered', 987);
        -- get the backed out date
        OPEN c_backed_out_ler;
        FETCH c_backed_out_ler INTO l_backed_out_date;
        hr_utility.set_location('l_backed_out_date is '||l_backed_out_date, 987);
        --IF c_backed_out_ler%FOUND THEN -- changed as its of no use
        IF l_backed_out_date is not null THEN
          hr_utility.set_location('bckdt%found', 987);
          -- if bckdt out dt is greater than epsd, make it the epsd
          IF l_backed_out_date > p_rec_enrt_perd_strt_dt THEN
            p_rec_enrt_perd_strt_dt := l_backed_out_date;
            hr_utility.set_location('l_backed_out_date substituted', 987);
          END IF;
        END IF;
        CLOSE c_backed_out_ler;
      -- if cd is 4, compare epsd with sysdate
      ELSIF p_enrt_perd_det_ovrlp_bckdt_cd = 'L_EPSD_PEESD_SYSDT' THEN
        hr_utility.set_location('L_EPSD_PEESD_SYSDT entered', 987);
        -- if sysdate is lis greater than epsd, make it the epsd
        IF l_sysdate > p_rec_enrt_perd_strt_dt THEN
          p_rec_enrt_perd_strt_dt := l_sysdate;
          hr_utility.set_location('sysdate substituted', 987);
        END IF;
      END IF;
    -- end 2746865
  END IF;
  end; --procedure
--
-------------------------

procedure enrolment_requirements
  (p_comp_obj_tree_row      in     ben_manage_life_events.g_cache_proc_objects_rec
  ,p_run_mode               in     varchar2
  ,p_business_group_id      in     number
  ,p_effective_date         in     date
  ,p_lf_evt_ocrd_dt         in     date default null
  ,p_ler_id                 in     number
  ,p_per_in_ler_id          in     number
  ,p_person_id              in     number
  ,p_pl_id                  in     number
  ,p_pgm_id                 in     number default null
  ,p_oipl_id                in     number default null
  ,p_create_anyhow_flag     in     varchar2 default 'N'
  -- 5422 : PB ,p_popl_enrt_typ_cycl_id  in     number default null
  --
  ,p_asnd_lf_evt_dt         in     date default null
  ,p_electable_flag            out nocopy varchar2
  ,p_elig_per_elctbl_chc_id    out nocopy number
  )
IS
  --
  l_currpep_dets     ben_pep_cache.g_pep_rec;
  l_currepe_dets ben_epe_cache.g_pilepe_inst_row;
  --
  l_prevepo_rec      ben_derive_part_and_rate_facts.g_cache_structure;
  l_prevpep_rec      ben_derive_part_and_rate_facts.g_cache_structure;
  --
    l_dummy                        varchar2(30);
    l_dummy_rt_strt_dt             DATE;
    l_dummy_rt_strt_dt_cd          VARCHAR2(30);
    l_dummy_rt_strt_dt_rl          NUMBER;
    l_dummy_enrt_cvg_end_dt        DATE;
    l_dummy_enrt_cvg_end_dt_cd     VARCHAR2(30);
    l_dummy_enrt_cvg_end_dt_rl     NUMBER;
    l_dummy_rt_end_dt              DATE;
    l_dummy_rt_end_dt_cd           VARCHAR2(30);
    l_dummy_rt_end_dt_rl           NUMBER;
    l_dummy_enrt_cvg_strt_dt_cd    VARCHAR2(30);
    l_dummy_enrt_cvg_strt_dt_rl    NUMBER;


--l_overide_enrt_cvg_strt_dt_cd varchar2(30);
--l_overide_enrt_cvg_strt_dt_rl number;
    l_pl_id                        NUMBER;
    l_prereq_electable_flag        VARCHAR2(30);
    l_oipl_name                    ben_opt_f.name%TYPE;
    l_pl_name                      ben_pl_f.name%TYPE;
    l_ler_name                     ben_ler_f.name%TYPE;
    l_must_enrl_anthr_pl_id        NUMBER;
    l_auto_enrt_flag               VARCHAR2(30)                 := 'N';
    l_rec_auto_enrt_flag           VARCHAR2(30)                 := 'N';
    l_comp_lvl_cd                  VARCHAR2(30);
    l_prtt_enrt_rslt_id            NUMBER;
    l_prtt_enrt_rslt_id_2          NUMBER;
    l_object_version_number        NUMBER;
    l_popl_yr_perd_id              NUMBER;
    l_yr_perd_strt_date            DATE;
    l_yr_perd_end_date             DATE;
    l_popl_yr_perd_ordr_num        NUMBER;
    l_yr_perd_id                   NUMBER;
    l_elig_per_elctbl_chc_id       NUMBER;
    l_tco_chg_enrt_cd              VARCHAR2(30)                 := 'CPOO';
    l_opt_id                       NUMBER;
    l_ptip_id                      NUMBER;
    l_ptip_ordr_num                NUMBER;
    l_plip_ordr_num                NUMBER;
    l_ptip_esd                     DATE;
    l_ptip_eed                     DATE;
    l_per_in_ler_id                NUMBER;
    l_alws_unrstrctd_enrt_flag     VARCHAR2(30)                 := 'N';
    l_plip_id                      NUMBER;
    l_plip_esd                     DATE;
    l_plip_eed                     DATE;
    l_plip_dflt_flag               VARCHAR2(30);
    l_plip_enrt_cd                 VARCHAR2(30);
    l_plip_enrt_rl                 NUMBER;
    l_oipl_dflt_flag               VARCHAR2(30);
    l_elig_per_id                  NUMBER;
    l_current_eligibility          VARCHAR2(30);
    l_prtn_strt_dt                 DATE;
    l_previous_eligibility         VARCHAR2(30);
    l_pl_typ_id                    NUMBER;
    l_proc                         VARCHAR2(72)
                                       := g_package ||
                                            '.enrolment_requirements';
    l_pl_enrt_cd                   VARCHAR2(30);
--L_PL_ENRT_CVG_STRT_DT_CD      varchar2(30);
--L_PL_ENRT_CVG_STRT_DT_RL      number;
    l_pl_enrt_mthd_cd              VARCHAR2(30);
    l_plip_enrt_mthd_cd            VARCHAR2(30);
    l_crnt_enrt_cvg_strt_dt        DATE;
    l_crnt_enrt_cvg_thru_dt        DATE;    --BUG 6519487 fix
    l_mndtry_flag                  VARCHAR2(30)                 := 'N';
    l_mndtry_rl                    NUMBER;
    l_choice_exists_flag           VARCHAR2(30);
    l_lf_evt_ocrd_dt_fetch         DATE;
    l_rqd_perd_enrt_nenrt_uom      VARCHAR2(30);
    l_ler_typ_cd                   VARCHAR2(30);
    l_ler_chg_found_flag           VARCHAR2(30);
    l_ler_chg_oipl_found_flag      VARCHAR2(30);
    l_ler_enrt_prclds_chg_flag     VARCHAR2(30);
    l_ler_dflt_flag                VARCHAR2(30);
    l_ler_enrt_cd                  VARCHAR2(30);
    l_ple_dys_aftr_end_to_dflt_num NUMBER;
    l_perd_for_plan_found          VARCHAR2(30)                 := 'N';
    l_rqd_perd_enrt_nenrt_val      NUMBER;
    l_rqd_perd_enrt_nenrt_rl       NUMBER;
    l_ler_enrt_mthd_cd             VARCHAR2(30);
    l_ler_enrt_rl                  NUMBER;
    l_ple_enrt_perd_end_dt_rl      NUMBER;
--L_PLE_ENRT_CVG_STRT_DT_CD     varchar2(30);
    l_use_dflt_enrt_cd             VARCHAR2(30);
    l_use_dflt_enrt_rl             NUMBER;
    l_use_dflt_flag                VARCHAR2(30);
    l_ler_stl_elig_cant_chg_flag   VARCHAR2(30);
    l_pl_enrt_rl                   NUMBER;
    l_ple_enrt_perd_strt_dt_rl     NUMBER;
    l_ple_enrt_perd_strt_days     NUMBER;
    l_ple_enrt_perd_end_days     NUMBER;
    l_pgme_dys_aftr_end_to_dflt    NUMBER;
    l_perd_for_program_found       VARCHAR2(30)                 := 'N';
    l_ple_enrt_perd_end_dt_cd      VARCHAR2(30);
    l_pgme_enrt_perd_end_dt_rl     NUMBER;
    l_ple_enrt_perd_strt_dt        DATE;
    l_rec_enrt_cvg_strt_dt_cd      VARCHAR2(30);
    l_rec_enrt_cvg_strt_dt_rl      NUMBER;
    l_ple_enrt_perd_strt_dt_cd     VARCHAR2(30);
    l_pgme_enrt_perd_strt_dt_rl    NUMBER;
    l_pgme_enrt_perd_strt_days    NUMBER;
    l_pgme_enrt_perd_end_days    NUMBER;
    l_ple_enrt_perd_end_dt         DATE;
    l_pgme_enrt_perd_strt_dt       DATE;
    l_rec_enrt_cvg_strt_dt         DATE;
    l_pgme_enrt_perd_end_dt_cd     VARCHAR2(30);
    l_ple_procg_end_dt             DATE;
    l_pgme_enrt_perd_end_dt        DATE;
    l_rec_mndtry_flag              VARCHAR2(30)                 := 'N';
    l_rec_elctbl_flag              VARCHAR2(30)                 := 'Y';
    l_exists_flag                  VARCHAR2(30);
    l_pgme_enrt_perd_strt_dt_cd    VARCHAR2(30);
    l_ple_dflt_enrt_dt             DATE;
    l_pgme_procg_end_dt            DATE;
    l_ple_enrt_typ_cycl_cd         VARCHAR2(30);
    l_rec_crntly_enrd_flag         VARCHAR2(30);
    l_pgme_dflt_enrt_dt            DATE;
    l_rec_enrt_typ_cycl_cd         VARCHAR2(30);
    l_pgme_enrt_typ_cycl_cd        VARCHAR2(30);
    l_dflt_flag                    VARCHAR2(30);
    l_rec_enrt_perd_strt_dt        DATE;
    l_erlst_deenrt_calc_dt         date ;         /*used for determine erly_deenrt_dt accroing level */
    l_orgnl_enrt_dt                date ;
    l_rec_enrt_perd_end_dt         DATE;
    l_ple_addit_procg_dys_num      NUMBER;
    l_rec_dflt_asnmt_dt            DATE;
    l_rec_procg_end_dt             DATE;
    l_crnt_erlst_deenrt_dt         DATE;
    l_rec_roll_crs_only_flag       VARCHAR2(30);
    l_rec_elctns_made_flag         VARCHAR2(30);
    l_rec_assignment_id            NUMBER;
    l_rec_organization_id          NUMBER;
    l_pgme_addit_procg_dys_num     NUMBER;
    l_rec_erlst_deenrt_dt          DATE;
    l_plip_auto_enrt_rl            NUMBER;
    l_pl_auto_enrt_rl              NUMBER;
    l_ler_auto_enrt_rl             NUMBER;
    l_invk_flx_cr_pl_flag          VARCHAR2(30);
    l_imptd_incm_calc_cd           VARCHAR2(30);
    l_pl_trk_inelig_per_flag       VARCHAR2(30);
    l_oipl_trk_inelig_per_flag     VARCHAR2(30);
    l_ple_enrt_perd_id             NUMBER;
    l_pgme_enrt_perd_id            NUMBER;
    l_rec_enrt_perd_id             NUMBER;
    l_rec_lee_rsn_id               NUMBER;
    l_rec_lee_rsn_esd              DATE;
    l_rec_lee_rsn_eed              DATE;
    l_ple_lee_rsn_id               NUMBER;
    l_pgme_lee_rsn_id              NUMBER;
    l_rec_acty_ref_perd_cd         VARCHAR2(30);
    l_rec_cls_enrt_dt_to_use_cd    VARCHAR2(30);
    l_rec_uom                      VARCHAR2(30);
    l_oipl_auto_enrt_flag          VARCHAR2(30)                 := 'N';
    l_oipl_auto_enrt_mthd_rl       NUMBER;
    l_unrestricted_enrt_flag       VARCHAR2(30)                 := 'N';
    l_enrt_ovridn_flag             VARCHAR2(30);
    l_enrt_ovrid_thru_dt           DATE;
    l_oipl_ordr_num                NUMBER;
    l_boo_rstrctn_cd               VARCHAR2(30);
    l_mn_ordr_num                  ben_oipl_f.ordr_num%TYPE;
    l_mx_ordr_num                  ben_oipl_f.ordr_num%TYPE;
    l_enrd_ordr_num                NUMBER;
    l_level                        VARCHAR2(30);
    l_plan_rec                     ben_pl_f%ROWTYPE;
    l_pgm_rec                      ben_pgm_f%ROWTYPE;
    l_oipl_rec                     ben_cobj_cache.g_oipl_inst_row;
    l_pen_rec                      ben_prtt_enrt_rslt_f%ROWTYPE;
    l_pl_typ_esd                   DATE;
    l_pl_typ_eed                   DATE;
    l_ler_esd                      DATE;
    l_ler_eed                      DATE;
    l_dpnt_cvrd_flag               VARCHAR2(1)                  := 'N';
    l_ptip_enrt_cd                 VARCHAR2(30);
    l_ptip_enrt_rl                 NUMBER;
    l_ptip_enrt_mthd_cd            VARCHAR2(30);
    l_ptip_auto_enrt_rl            NUMBER;
    l_jurisdiction_code            VARCHAR2(30);
    l_ctfn_rqd_flag                VARCHAR2(30)                 := 'N';
    l_reinstt_flag                 VARCHAR2(30);
    l_reinstt_cd                   VARCHAR2(30);
    --
    l_cvg_incr_r_decr_only_cd      VARCHAR2(30);
    l_mx_cvg_mlt_incr_num          NUMBER;
    l_mx_cvg_mlt_incr_wcf_num      NUMBER;
    l_tmp_level                    VARCHAR2(30);
    l_restriction_pgm_id           NUMBER;
    l_regn_125_or_129_flag         varchar2(30);
    --
    l_lf_evt_ocrd_dt               DATE
                                    := NVL(p_lf_evt_ocrd_dt, p_effective_date);
    l_lf_evt_ocrd_dt_1             DATE                 := l_lf_evt_ocrd_dt - 1;
  --  l_effective_date_1             DATE                 := p_effective_date - --  1;
  --  Bug#2328029
    l_effective_date_1     date :=
           least(p_effective_date, nvl(p_lf_evt_ocrd_dt,p_effective_date)) -1;
    --

    --
    l_ple_hrchy_to_use_cd          varchar2(30);
    l_ple_pos_structure_version_id    number;
    l_ws_mgr_id                    number;
    l_elig_flag                    varchar2(30);
    l_assignment_id                number(15);
    -- 2746865 -- variable for new column
    l_enrt_perd_det_ovrlp_bckdt_cd varchar2(30);
    l_fonm_cvg_strt_dt             date;
    l_epe_exists                   number ;
    --
    -- bug: 5644451
    l_oipl_record   ben_oipl_f%ROWTYPE;
    l_plip_record   ben_plip_f%ROWTYPE;
    l_ptip_record   ben_ptip_f%ROWTYPE;
    l_dflt_level    varchar2(30);
    --
    -- define all cursors
    --
    --
    ------------Bug 8846328
    l_fut_rslt_exist boolean := false;
    l_crnt_enrt_sspndd_flag varchar2(10) := 'N';
    ------------Bug 8846328
    CURSOR c_pl_typ IS
      SELECT   bpt.effective_start_date,
               bpt.effective_end_date
      FROM     ben_pl_typ_f bpt
      WHERE    bpt.pl_typ_id = l_pl_typ_id
      AND      l_lf_evt_ocrd_dt BETWEEN bpt.effective_start_date
                   AND bpt.effective_end_date
      AND      bpt.business_group_id = p_business_group_id;
    --
    CURSOR c_state IS
      SELECT   loc.region_2
      FROM     hr_locations_all loc, per_all_assignments_f asg
      WHERE    loc.location_id = asg.location_id
      AND      asg.person_id = p_person_id
      and      asg.assignment_type <> 'C'
      AND      asg.primary_flag = 'Y'
      AND      l_lf_evt_ocrd_dt BETWEEN asg.effective_start_date
                   AND asg.effective_end_date
      AND      asg.business_group_id = p_business_group_id;
    --
    l_state                        c_state%ROWTYPE;
    --
    CURSOR c_asg IS
      SELECT   asg.assignment_id,
               asg.organization_id
      FROM     per_all_assignments_f asg
      WHERE    asg.person_id = p_person_id
      and      asg.assignment_type <> 'C'
      AND      asg.primary_flag = decode (p_run_mode, 'I', asg.primary_flag, 'Y')-- iREC
      AND      l_lf_evt_ocrd_dt BETWEEN asg.effective_start_date
                   AND asg.effective_end_date;
  --
  --
  -- Enrt_perd_for_pl info
  --
--cursor c_enrt_perd_for_pl_info is
--  select epp.enrt_cvg_strt_dt_cd,
--         epp.enrt_cvg_strt_dt_rl
--  from   ben_enrt_perd_for_pl_f epp
--  where  epp.pl_id=l_pl_id and
--         (epp.enrt_perd_id=l_pgme_enrt_perd_id or
--          epp.lee_rsn_id=l_pgme_lee_rsn_id) and
--         nvl(p_lf_evt_ocrd_dt,p_effective_date) between
--           epp.effective_start_date and epp.effective_end_date and
--         epp.business_group_id =p_business_group_id
--  ;
  --
  -- Determine the current popl_yr_period
  --
    CURSOR c_pl_popl_yr_period_current IS
      SELECT   pyp.yr_perd_id,
               pyp.popl_yr_perd_id,
               yp.start_date,
               yp.end_date,
               pyp.ordr_num
      FROM     ben_popl_yr_perd pyp, ben_yr_perd yp
      WHERE    pyp.pl_id = l_pl_id
      AND      pyp.yr_perd_id = yp.yr_perd_id
      AND      pyp.business_group_id = p_business_group_id
      AND      l_lf_evt_ocrd_dt BETWEEN yp.start_date AND yp.end_date
      AND      yp.business_group_id = p_business_group_id;
    --
    -- see if the elig_per_elctbl_chc record already exists
    --
    --
    CURSOR c_choice_exists_for_option IS
      SELECT   NULL
      FROM     ben_elig_per_elctbl_chc epe
      WHERE    epe.oipl_id = p_oipl_id
      -- added 9/25/98 to handle plans in mult progs
      AND      (
                    (    epe.pgm_id = p_pgm_id
                     AND p_pgm_id IS NOT NULL)
                 OR (    epe.pgm_id IS NULL
                     AND p_pgm_id IS NULL))
      AND      epe.per_in_ler_id = l_per_in_ler_id
      AND      epe.business_group_id = p_business_group_id;
    --
    -- see if the elig_per_elctbl_chc record already exists
    --
    --
    CURSOR c_choice_exists_for_plan(pp_pl_id NUMBER) IS
      SELECT   elig_per_elctbl_chc_id
      FROM     ben_elig_per_elctbl_chc epe
      WHERE    epe.pl_id = pp_pl_id
      AND      epe.oipl_id IS NULL
      -- added 9/25/98 to handle plans in mult progs
      AND      (
                    (    epe.pgm_id = p_pgm_id
                     AND p_pgm_id IS NOT NULL)
                 OR (    epe.pgm_id IS NULL
                     AND p_pgm_id IS NULL))
      AND      epe.per_in_ler_id = l_per_in_ler_id
      AND      epe.business_group_id = p_business_group_id;
    --
    -- Gets the enrolment information for this plan
    --
    --
    --8399189
    CURSOR c_plan_enrolment_info(p_cvg_dt date,p_run_mode varchar2) IS
      SELECT   pen.enrt_cvg_strt_dt,
               pen.erlst_deenrt_dt,
               pen.prtt_enrt_rslt_id,
               pen.enrt_ovridn_flag,
               pen.enrt_ovrid_thru_dt,
               pen.orgnl_enrt_dt,
               pen.enrt_cvg_thru_dt,
               pen.pl_typ_id
      FROM     ben_prtt_enrt_rslt_f pen
      WHERE    pen.person_id = p_person_id
      AND      pen.business_group_id = p_business_group_id
      AND      (pen.sspndd_flag = 'N' --CFW
                 OR (pen.sspndd_flag = 'Y' and
                     pen.enrt_cvg_thru_dt = hr_api.g_eot
                    )
               )
      AND      pen.prtt_enrt_rslt_stat_cd IS NULL
      --8399189
      AND      ((pen.effective_end_date = hr_api.g_eot
      and      p_run_mode <> 'U')
       or      ( p_effective_date between pen.effective_start_date and pen.effective_end_date
      and       p_run_mode = 'U'))
      --8399189
      AND      p_cvg_dt <= pen.enrt_cvg_thru_dt
      AND      pen.enrt_cvg_strt_dt < pen.effective_end_date
      AND      pen.oipl_id IS NULL
      AND      l_pl_id = pen.pl_id
      AND      (
                    (    pen.pgm_id = p_pgm_id
                     AND p_pgm_id IS NOT NULL)
                 OR (    pen.pgm_id IS NULL
                     AND p_pgm_id IS NULL))
      order by pen.enrt_cvg_strt_dt,decode(pen.sspndd_flag,'Y',1,2) ;
    --
    -- Bug 2600087
    --
    -- Gets the enrolment information for this oipl
    --
    --
     CURSOR c_oipl_enrolment_info(p_cvg_dt date,p_run_mode varchar2) IS
      SELECT   pen.enrt_cvg_strt_dt,
               pen.erlst_deenrt_dt,
               pen.prtt_enrt_rslt_id,
               pen.enrt_ovridn_flag,
               pen.enrt_ovrid_thru_dt,
               pen.enrt_cvg_thru_dt,
	       pen.sspndd_flag,   ---------Bug 8846328
               pen.pl_typ_id
      FROM     ben_prtt_enrt_rslt_f pen
      WHERE    pen.person_id = p_person_id
      AND      pen.business_group_id = p_business_group_id
      AND      (pen.sspndd_flag = 'N' --CFW
                 OR (pen.sspndd_flag = 'Y' and
                     pen.enrt_cvg_thru_dt = hr_api.g_eot
                    )
               )
      AND      pen.prtt_enrt_rslt_stat_cd IS NULL
      ------Bug 8228639,modified the fix 7507714
      AND      ((pen.effective_end_date = hr_api.g_eot
      and      p_run_mode <> 'U')
       or      ( p_effective_date between pen.effective_start_date and pen.effective_end_date
      and       p_run_mode = 'U'))
      ------Bug 8228639,modified the fix 7507714
      AND      p_cvg_dt <= pen.enrt_cvg_thru_dt
      AND      pen.enrt_cvg_strt_dt < pen.effective_end_date
      AND      p_oipl_id = pen.oipl_id
      AND      (
                    (    pen.pgm_id = p_pgm_id
                     AND p_pgm_id IS NOT NULL)
                 OR (    pen.pgm_id IS NULL
                     AND p_pgm_id IS NULL))
    -- Bug 2600087
    order by pen.enrt_cvg_strt_dt,decode(pen.sspndd_flag,'Y',1,2);
    --
    --BUG 6519487 fix
    --
    CURSOR c_future_results (p_person_id in number,
                             p_enrt_cvg_thru_dt  in date,
                             p_pgm_id            in number,
                             p_pl_typ_id         in number) is
   SELECT   pen.* ----'Y',Bug 8453712
     FROM   ben_prtt_enrt_rslt_f pen
    WHERE   pen.person_id  = p_person_id
    AND     pen.effective_end_date = hr_api.g_eot
    AND     pen.enrt_cvg_strt_dt > p_enrt_cvg_thru_dt
    ANd     pen.pl_typ_id       = p_pl_typ_id
    and     nvl(pen.sspndd_flag,'N') = 'N'
    AND    (
                    (    pen.pgm_id = p_pgm_id
                     AND p_pgm_id IS NOT NULL)
                 OR (    pen.pgm_id IS NULL
                     AND p_pgm_id IS NULL))
    AND     pen.prtt_enrt_rslt_stat_cd is null;

    l_future_results c_future_results%rowtype;--Bug 8453712
    --
    --BUG 6519487 fix
    --
    -- Gets the coverage information for this plan
    --
    --
    CURSOR c_plan_cvg_info IS
      SELECT   'Y'
      FROM     ben_prtt_enrt_rslt_f pen, ben_elig_cvrd_dpnt_f pdp
      WHERE    pdp.dpnt_person_id = p_person_id
      AND      pdp.effective_end_date = hr_api.g_eot
      AND      l_lf_evt_ocrd_dt_1 BETWEEN pdp.cvg_strt_dt AND pdp.cvg_thru_dt
      AND      pdp.business_group_id = p_business_group_id
      AND      pdp.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
      AND      pen.business_group_id = p_business_group_id
      AND      pen.sspndd_flag = 'N'
      AND      pen.prtt_enrt_rslt_stat_cd IS NULL
      AND      pen.effective_end_date = hr_api.g_eot
      AND      l_lf_evt_ocrd_dt_1 <= pen.enrt_cvg_thru_dt
      AND      pen.enrt_cvg_strt_dt < pen.effective_end_date
      AND      l_pl_id = pen.pl_id
      AND      (
                    (    pen.pgm_id = p_pgm_id
                     AND p_pgm_id IS NOT NULL)
                 OR (    pen.pgm_id IS NULL
                     AND p_pgm_id IS NULL));
    --
    -- Gets the coverage information for this oipl
    --
    --
    CURSOR c_oipl_cvg_info IS
      SELECT   'Y'
      FROM     ben_prtt_enrt_rslt_f pen, ben_elig_cvrd_dpnt_f pdp
      WHERE    pdp.dpnt_person_id = p_person_id
      AND      pdp.effective_end_date = hr_api.g_eot
      AND      l_lf_evt_ocrd_dt_1 BETWEEN pdp.cvg_strt_dt AND pdp.cvg_thru_dt
      AND      pdp.business_group_id = p_business_group_id
      AND      pdp.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
      AND      pen.business_group_id = p_business_group_id
      AND      pen.sspndd_flag = 'N'
      AND      pen.prtt_enrt_rslt_stat_cd IS NULL
      AND      pen.effective_end_date = hr_api.g_eot
      AND      l_lf_evt_ocrd_dt_1 <= pen.enrt_cvg_thru_dt
      AND      pen.enrt_cvg_strt_dt < pen.effective_end_date
      AND      p_oipl_id = pen.oipl_id
      AND      (
                    (    pen.pgm_id = p_pgm_id
                     AND p_pgm_id IS NOT NULL)
                 OR (    pen.pgm_id IS NULL
                     AND p_pgm_id IS NULL));
    --
    -- Determines the current eligibility for an option
    --
    CURSOR c_current_elig_for_option IS
      SELECT   ep.elig_per_id,
               epo.elig_flag,
               ep.must_enrl_anthr_pl_id,
               epo.prtn_strt_dt
      FROM     ben_elig_per_f ep, ben_elig_per_opt_f epo, ben_per_in_ler pil
      WHERE    ep.person_id = p_person_id
      AND      ep.pl_id = l_pl_id
      AND      (
                    (    ep.pgm_id = p_pgm_id
                     AND p_pgm_id IS NOT NULL)
                 OR (    ep.pgm_id IS NULL
                     AND p_pgm_id IS NULL))
      AND      ep.business_group_id = p_business_group_id
      AND      p_effective_date BETWEEN ep.effective_start_date
                   AND ep.effective_end_date
      AND      ep.elig_per_id = epo.elig_per_id
      AND      epo.opt_id = l_opt_id
      AND      epo.business_group_id = p_business_group_id
      AND      p_effective_date BETWEEN epo.effective_start_date
                   AND epo.effective_end_date
      AND      pil.per_in_ler_id (+) = epo.per_in_ler_id
      AND      pil.business_group_id (+) = epo.business_group_id
      AND      (
                    pil.per_in_ler_stat_cd NOT IN
                                        (
                                          'VOIDD',
                                          'BCKDT')       -- found row condition
                 OR pil.per_in_ler_stat_cd IS NULL);    -- outer join condition
    -- Determines the previous eligibility for an option
    --
    CURSOR c_previous_elig_for_option IS
      SELECT   epo.elig_flag
      FROM     ben_elig_per_f ep, ben_elig_per_opt_f epo, ben_per_in_ler pil
      WHERE    ep.person_id = p_person_id
      AND      ep.pl_id = l_pl_id
      AND      (
                    (    ep.pgm_id = p_pgm_id
                     AND p_pgm_id IS NOT NULL)
                 OR (    ep.pgm_id IS NULL
                     AND p_pgm_id IS NULL))
      AND      ep.business_group_id = p_business_group_id
      AND      p_effective_date - 1 BETWEEN ep.effective_start_date
                   AND ep.effective_end_date
      AND      ep.elig_per_id = epo.elig_per_id
      AND      epo.opt_id = l_opt_id
      AND      epo.business_group_id = p_business_group_id
      AND      l_effective_date_1 BETWEEN epo.effective_start_date
                   AND epo.effective_end_date
      AND      pil.per_in_ler_id (+) = epo.per_in_ler_id
      AND      pil.business_group_id (+) = epo.business_group_id
      AND      (
                    pil.per_in_ler_stat_cd NOT IN
                                        (
                                          'VOIDD',
                                          'BCKDT')       -- found row condition
                 OR pil.per_in_ler_stat_cd IS NULL);    -- outer join condition
    --
    -- Determines the current eligibility for a plan
    --
    CURSOR c_current_elig_for_plan
    is
      SELECT   pep.elig_per_id,
               pep.elig_flag,
               pep.must_enrl_anthr_pl_id,
               pep.prtn_strt_dt,
               pep.inelg_rsn_cd -- 2650247
      FROM     ben_elig_per_f pep, ben_per_in_ler pil
      WHERE    pep.person_id = p_person_id
      AND      pep.pl_id = l_pl_id
      AND      (
                    (    pep.pgm_id = p_pgm_id
                     AND p_pgm_id IS NOT NULL)
                 OR (    pep.pgm_id IS NULL
                     AND p_pgm_id IS NULL))
      AND      pep.business_group_id = p_business_group_id
      AND      p_effective_date BETWEEN pep.effective_start_date
                   AND pep.effective_end_date
      AND      pil.per_in_ler_id (+) = pep.per_in_ler_id
      AND      pil.business_group_id (+) = pep.business_group_id
      AND      (
                    pil.per_in_ler_stat_cd NOT IN
                                        (
                                          'VOIDD',
                                          'BCKDT')       -- found row condition
                 OR pil.per_in_ler_stat_cd IS NULL);    -- outer join condition
    --
    -- Determines the previous eligibility for a plan
    --
    CURSOR c_previous_elig_for_plan IS
      SELECT   pep.elig_flag
      FROM     ben_elig_per_f pep, ben_per_in_ler pil
      WHERE    pep.person_id = p_person_id
      AND      pep.pl_id = l_pl_id
      AND      (
                    (    pep.pgm_id = p_pgm_id
                     AND p_pgm_id IS NOT NULL)
                 OR (    pep.pgm_id IS NULL
                     AND p_pgm_id IS NULL))
      AND      pep.business_group_id = p_business_group_id
      AND      l_effective_date_1 BETWEEN pep.effective_start_date
                   AND pep.effective_end_date
      AND      pil.per_in_ler_id (+) = pep.per_in_ler_id
      AND      pil.business_group_id (+) = pep.business_group_id
      AND      (
                    pil.per_in_ler_stat_cd NOT IN
                                        (
                                          'VOIDD',
                                          'BCKDT')       -- found row condition
                 OR pil.per_in_ler_stat_cd IS NULL);    -- outer join condition
    -- Determines the per_in_ler and gets associated info
    --
    CURSOR c_per_in_ler_info IS
      SELECT   pil.per_in_ler_id,
               ler.typ_cd,
               ler.name,
               pil.lf_evt_ocrd_dt,
               ler.effective_start_date,
               ler.effective_end_date
      FROM     ben_per_in_ler pil, ben_ler_f ler
      WHERE    pil.person_id = p_person_id
      AND      pil.business_group_id = p_business_group_id
      AND      pil.ler_id = p_ler_id
      AND      pil.per_in_ler_stat_cd = 'STRTD'
      AND      ler.business_group_id = p_business_group_id
      AND      pil.ler_id = ler.ler_id
      AND      l_lf_evt_ocrd_dt BETWEEN ler.effective_start_date
                   AND ler.effective_end_date
      and      nvl(pil.assignment_id, -9999) = decode (p_run_mode,
                                           'I',
					   ben_manage_life_events.g_irec_ass_rec.assignment_id,
					   nvl(pil.assignment_id, -9999) );            -- iRec
    --
    -- Bug 2200139 Get new the per_in_ler info for the Override Election.
    --
    CURSOR c_ovrd_per_in_ler_info IS
      SELECT   pil.per_in_ler_id,
               ler.typ_cd,
               ler.name,
               pil.lf_evt_ocrd_dt,
               ler.effective_start_date,
               ler.effective_end_date
      FROM     ben_per_in_ler pil, ben_ler_f ler
      WHERE    pil.per_in_ler_id = p_per_in_ler_id
      AND      pil.business_group_id = p_business_group_id
--     AND      pil.ler_id = p_ler_id
--     AND      pil.per_in_ler_stat_cd = 'STRTD'
      AND      ler.business_group_id = p_business_group_id
      AND      pil.ler_id = ler.ler_id
      AND      l_lf_evt_ocrd_dt BETWEEN ler.effective_start_date
                   AND ler.effective_end_date;
    -- end Override Election
    -- This cursor gets the enrolment period for scheduled
    -- elections for plan level
    --
    -- Bug 5272 : To get the enrolment period get the
    -- enrollment strt_dt and use it to get the programs enrollment
    -- period data.
    --
    CURSOR c_sched_enrol_period_for_plan IS
      SELECT   enrtp.enrt_perd_id,
               enrtp.strt_dt,
               enrtp.end_dt,
               enrtp.procg_end_dt,
               enrtp.dflt_enrt_dt,
               petc.enrt_typ_cycl_cd,
               enrtp.cls_enrt_dt_to_use_cd,
               enrtp.hrchy_to_use_cd,
               enrtp.pos_structure_version_id,
               /* bug 2746865  */
               enrtp.enrt_perd_det_ovrlp_bckdt_cd
      FROM     ben_popl_enrt_typ_cycl_f petc,
               ben_enrt_perd enrtp,
                ben_ler_f ler
      WHERE    petc.pl_id = l_pl_id
      AND      petc.business_group_id = p_business_group_id
      AND      l_lf_evt_ocrd_dt BETWEEN petc.effective_start_date
                   AND petc.effective_end_date
      AND      petc.enrt_typ_cycl_cd <> 'L'
      AND      enrtp.business_group_id = p_business_group_id
      AND      enrtp.asnd_lf_evt_dt  = p_lf_evt_ocrd_dt
      /* PB :5422 AND      enrtp.strt_dt=enrtp1.strt_dt
      AND      enrtp1.popl_enrt_typ_cycl_id = p_popl_enrt_typ_cycl_id
      AND      enrtp1.business_group_id     = p_business_group_id */
      AND      enrtp.popl_enrt_typ_cycl_id  = petc.popl_enrt_typ_cycl_id
      -- comp work bench changes
      and      ler.ler_id (+) = enrtp.ler_id
      and      ler.ler_id (+) = p_ler_id
      and      l_lf_evt_ocrd_dt between ler.effective_start_date (+)
                                    and ler.effective_end_date (+);

    -- This cursor gets the enrolment period for scheduled
    -- elections for program level
    --
    -- Bug 5272 : To get the enrolment period,  get the
    -- enrollment strt_dt and use it to get the plans enrollment
    -- period data.
    --
    CURSOR c_sched_enrol_period_for_pgm IS
      SELECT   enrtp.enrt_perd_id,
               enrtp.strt_dt,
               enrtp.end_dt,
               enrtp.procg_end_dt,
               enrtp.dflt_enrt_dt,
               petc.enrt_typ_cycl_cd,
               enrtp.cls_enrt_dt_to_use_cd,
               enrtp.hrchy_to_use_cd,
               enrtp.pos_structure_version_id,
               /* bug 2746865*/
               enrtp.enrt_perd_det_ovrlp_bckdt_cd
      FROM     ben_popl_enrt_typ_cycl_f petc,
               ben_enrt_perd enrtp,
               ben_ler_f ler
      WHERE    petc.pgm_id = p_pgm_id
      AND      petc.business_group_id = p_business_group_id
      AND      l_lf_evt_ocrd_dt BETWEEN petc.effective_start_date
                   AND petc.effective_end_date
      AND      petc.enrt_typ_cycl_cd <> 'L'
      AND      enrtp.business_group_id = p_business_group_id
      AND      enrtp.asnd_lf_evt_dt  = p_lf_evt_ocrd_dt
      /* PB :5422 AND      enrtp1.business_group_id = p_business_group_id
      AND      enrtp.strt_dt= enrtp1.strt_dt
      AND      enrtp1.enrt_perd_id = p_popl_enrt_typ_cycl_id */
      AND      enrtp.popl_enrt_typ_cycl_id = petc.popl_enrt_typ_cycl_id
      -- comp work bench
      and      ler.ler_id (+) = enrtp.ler_id
      and      ler.ler_id (+) = p_ler_id
      and      l_lf_evt_ocrd_dt between ler.effective_start_date (+)
                                    and ler.effective_end_date (+);

    -- This cursor gets information used to determine the
    -- enrolment period for life event driven elections
    --
    CURSOR c_lee_period_for_plan IS
      SELECT   leer.dys_aftr_end_to_dflt_num,
               leer.enrt_perd_end_dt_rl,
               leer.enrt_perd_strt_dt_rl,
               leer.enrt_perd_end_dt_cd,
               leer.enrt_perd_strt_dt_cd,
               leer.addl_procg_dys_num,
               petc.enrt_typ_cycl_cd,
               leer.lee_rsn_id,
               leer.cls_enrt_dt_to_use_cd,
               leer.effective_start_date,
               leer.effective_end_date,
               leer.enrt_perd_strt_days,
               leer.enrt_perd_end_days,
               /* bug 2746865*/
               leer.enrt_perd_det_ovrlp_bckdt_cd
      FROM     ben_lee_rsn_f leer, ben_popl_enrt_typ_cycl_f petc
      WHERE    leer.ler_id = p_ler_id
      AND      leer.business_group_id = p_business_group_id
      AND      l_lf_evt_ocrd_dt BETWEEN leer.effective_start_date
                   AND leer.effective_end_date
      AND      leer.popl_enrt_typ_cycl_id = petc.popl_enrt_typ_cycl_id
      AND      petc.pl_id = l_pl_id
      AND      petc.enrt_typ_cycl_cd = 'L'                        -- life event
      AND      petc.business_group_id = p_business_group_id
      AND      l_lf_evt_ocrd_dt BETWEEN petc.effective_start_date
                   AND petc.effective_end_date;
    -- This cursor gets information used to determine the
    -- enrolment period for life event driven elections
    --
    CURSOR c_lee_period_for_program IS
      SELECT   leer.dys_aftr_end_to_dflt_num,
               leer.enrt_perd_end_dt_rl,
               leer.enrt_perd_strt_dt_rl,
               leer.enrt_perd_end_dt_cd,
               leer.enrt_perd_strt_dt_cd,
               leer.addl_procg_dys_num,
               petc.enrt_typ_cycl_cd,
               leer.lee_rsn_id,
               leer.cls_enrt_dt_to_use_cd,
               leer.effective_start_date,
               leer.effective_end_date ,
               leer.enrt_perd_strt_days,
               leer.enrt_perd_end_days,
               /* bug 2746865*/
               leer.enrt_perd_det_ovrlp_bckdt_cd
      FROM     ben_lee_rsn_f leer, ben_popl_enrt_typ_cycl_f petc
      WHERE    leer.ler_id = p_ler_id
      AND      leer.business_group_id = p_business_group_id
      AND      l_lf_evt_ocrd_dt BETWEEN leer.effective_start_date
                   AND leer.effective_end_date
      AND      leer.popl_enrt_typ_cycl_id = petc.popl_enrt_typ_cycl_id
      AND      petc.pgm_id = p_pgm_id
      AND      petc.enrt_typ_cycl_cd = 'L'
      AND      petc.business_group_id = p_business_group_id
      AND      l_lf_evt_ocrd_dt BETWEEN petc.effective_start_date
                   AND petc.effective_end_date;
    -- Gets all information on the plip which is needed
    --
    CURSOR c_plip_info IS
      SELECT   bpf.plip_id,
               bpf.dflt_flag,
               bpf.enrt_cd,
               bpf.enrt_rl,
               bpf.enrt_mthd_cd,
               bpf.auto_enrt_mthd_rl,
               bpf.alws_unrstrctd_enrt_flag,
               bpf.effective_start_date,
               bpf.effective_end_date,
               bpf.ordr_num
      FROM     ben_plip_f bpf
      WHERE    bpf.pl_id = l_pl_id
      AND      bpf.pgm_id = p_pgm_id
      AND      bpf.business_group_id = p_business_group_id
      AND      l_lf_evt_ocrd_dt BETWEEN bpf.effective_start_date
                   AND bpf.effective_end_date;
    -- Gets all information on the ptip which is needed
    --
    CURSOR c_ptip_info IS
      SELECT   ptip.ptip_id,
               ptip.enrt_cd,
               ptip.enrt_rl,
               ptip.enrt_mthd_cd,
               ptip.auto_enrt_mthd_rl,
               ptip.effective_start_date,
               ptip.effective_end_date,
               ptip.ordr_num
      FROM     ben_ptip_f ptip
      WHERE    ptip.pl_typ_id = l_pl_typ_id
      AND      ptip.pgm_id = p_pgm_id
      AND      ptip.business_group_id = p_business_group_id
      AND      l_lf_evt_ocrd_dt BETWEEN ptip.effective_start_date
                   AND ptip.effective_end_date;
    --
    -- Returns one row if any oipls exist for the plan
    --
    CURSOR c_any_oipl_for_plan IS                                -- oipl exists
      SELECT   NULL
      FROM     ben_oipl_f cop
      WHERE    cop.pl_id = l_pl_id
      AND      business_group_id = p_business_group_id
      AND      l_lf_evt_ocrd_dt BETWEEN cop.effective_start_date
                   AND cop.effective_end_date;
    --
    -- Get level restriction
    --
    --
    CURSOR c_ler_bnft_rstrn IS
      SELECT   '4',
               plip.pgm_id,
               oipl.ordr_num,
               plip.bnft_or_option_rstrctn_cd,
               lbr.cvg_incr_r_decr_only_cd,
               lbr.mx_cvg_mlt_incr_num,
               lbr.mx_cvg_mlt_incr_wcf_num
      FROM     ben_oipl_f oipl, ben_ler_bnft_rstrn_f lbr, ben_plip_f plip
      WHERE    plip.plip_id = l_plip_id
      AND      plip.business_group_id = p_business_group_id
      AND      plip.bnft_or_option_rstrctn_cd = 'OPT'
      AND      l_lf_evt_ocrd_dt BETWEEN plip.effective_start_date
                   AND plip.effective_end_date
      AND      oipl.oipl_id = p_oipl_id
      AND      oipl.pl_id = plip.pl_id
      AND      oipl.business_group_id = p_business_group_id
      AND      l_lf_evt_ocrd_dt BETWEEN oipl.effective_start_date
                   AND oipl.effective_end_date
      AND      lbr.plip_id = plip.plip_id
      AND      lbr.ler_id = p_ler_id
      AND      lbr.business_group_id = p_business_group_id
      AND      l_lf_evt_ocrd_dt BETWEEN lbr.effective_start_date
                   AND lbr.effective_end_date
      UNION ALL
      SELECT   '3',
               TO_NUMBER(NULL),
               oipl.ordr_num,
               pl.bnft_or_option_rstrctn_cd,
               lbr.cvg_incr_r_decr_only_cd,
               lbr.mx_cvg_mlt_incr_num,
               lbr.mx_cvg_mlt_incr_wcf_num
      FROM     ben_oipl_f oipl, ben_ler_bnft_rstrn_f lbr, ben_pl_f pl
      WHERE    pl.pl_id = l_pl_id
      AND      pl.business_group_id = p_business_group_id
      AND      l_lf_evt_ocrd_dt BETWEEN pl.effective_start_date
                   AND pl.effective_end_date
      AND      oipl.oipl_id = p_oipl_id
      AND      oipl.pl_id = pl.pl_id
      AND      oipl.business_group_id = p_business_group_id
      AND      l_lf_evt_ocrd_dt BETWEEN oipl.effective_start_date
                   AND oipl.effective_end_date
      AND      lbr.pl_id = pl.pl_id
      AND      lbr.plip_id IS NULL
      AND      lbr.ler_id = p_ler_id
      AND      pl.bnft_or_option_rstrctn_cd = 'OPT'
      AND      lbr.business_group_id = p_business_group_id
      AND      l_lf_evt_ocrd_dt BETWEEN lbr.effective_start_date
                   AND lbr.effective_end_date;
    --
    --
    /*
        --
        CURSOR c_pl_bnft_rstrn IS
          SELECT   '2',
                   plip.pgm_id,
                   oipl.ordr_num,
                   plip.bnft_or_option_rstrctn_cd,
                   plip.cvg_incr_r_decr_only_cd,
                   plip.mx_cvg_mlt_incr_num,
                   plip.mx_cvg_mlt_incr_wcf_num
          FROM     ben_oipl_f oipl, ben_plip_f plip
          WHERE    plip.plip_id = l_plip_id
          AND      plip.bnft_or_option_rstrctn_cd = 'OPT'
          AND      plip.business_group_id = p_business_group_id
          AND      l_lf_evt_ocrd_dt BETWEEN plip.effective_start_date
                       AND plip.effective_end_date
          AND      oipl.oipl_id = p_oipl_id
          AND      oipl.pl_id = plip.pl_id
          AND      oipl.business_group_id = p_business_group_id
          AND      l_lf_evt_ocrd_dt BETWEEN oipl.effective_start_date
                       AND oipl.effective_end_date
          UNION ALL
          SELECT   '1',
                   TO_NUMBER(NULL),
                   oipl.ordr_num,
                   pl.bnft_or_option_rstrctn_cd,
                   pl.cvg_incr_r_decr_only_cd,
                   pl.mx_cvg_mlt_incr_num,
                   pl.mx_cvg_mlt_incr_wcf_num
          FROM     ben_oipl_f oipl, ben_pl_f pl
          WHERE    pl.pl_id = l_pl_id
          AND      pl.bnft_or_option_rstrctn_cd = 'OPT'
          AND      pl.business_group_id = p_business_group_id
          AND      l_lf_evt_ocrd_dt BETWEEN pl.effective_start_date
                       AND pl.effective_end_date
          AND      oipl.oipl_id = p_oipl_id
          AND      oipl.pl_id = pl.pl_id
          AND      oipl.business_group_id = p_business_group_id
          AND      l_lf_evt_ocrd_dt BETWEEN oipl.effective_start_date
                       AND oipl.effective_end_date;
        --**
    */
--**
  --
  -- get the oipl enrollment for this plan (may not be this oipl)
  --
  --
    CURSOR c_oipl_enrt_in_pl IS
      SELECT   enrd_oipl.ordr_num
      FROM     ben_prtt_enrt_rslt_f pen, ben_oipl_f enrd_oipl
      WHERE
               -- get result for plan if exists
               pen.person_id = p_person_id
      AND      pen.business_group_id = p_business_group_id
      AND      pen.prtt_enrt_rslt_stat_cd IS NULL
      AND      pen.sspndd_flag = 'N'
      AND      pen.effective_end_date = hr_api.g_eot
      AND      pen.enrt_cvg_thru_dt >= l_lf_evt_ocrd_dt_1
      AND      pen.enrt_cvg_strt_dt < pen.effective_end_date
      AND      pen.pl_id = l_pl_id
      -- get enrolled oipl
      AND      enrd_oipl.oipl_id = pen.oipl_id
      AND      enrd_oipl.business_group_id = p_business_group_id
      AND      l_lf_evt_ocrd_dt BETWEEN enrd_oipl.effective_start_date
                   AND enrd_oipl.effective_end_date;
    --
    -- get the oipl coverage for this plan (may not be this oipl)
    --
    --
    CURSOR c_oipl_cvg_in_pl IS
      SELECT   enrd_oipl.ordr_num
      FROM     ben_prtt_enrt_rslt_f pen,
               ben_elig_cvrd_dpnt_f pdp,
               ben_oipl_f enrd_oipl
      WHERE    pdp.dpnt_person_id = p_person_id
      AND      pdp.effective_end_date = hr_api.g_eot
      AND      l_lf_evt_ocrd_dt_1 BETWEEN pdp.cvg_strt_dt AND pdp.cvg_thru_dt
      AND      pdp.business_group_id = p_business_group_id
      AND      pdp.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
      -- get result for plan if exists
      AND      pen.business_group_id = p_business_group_id
      AND      pen.prtt_enrt_rslt_stat_cd IS NULL
      AND      pen.sspndd_flag = 'N'
      AND      pen.effective_end_date = hr_api.g_eot
      AND      pen.enrt_cvg_thru_dt >= l_lf_evt_ocrd_dt_1
      AND      pen.enrt_cvg_strt_dt < pen.effective_end_date
      AND      pen.pl_id = l_pl_id
      -- get enrolled oipl
      AND      enrd_oipl.oipl_id = pen.oipl_id
      AND      enrd_oipl.business_group_id = p_business_group_id
      AND      l_lf_evt_ocrd_dt BETWEEN enrd_oipl.effective_start_date
                   AND enrd_oipl.effective_end_date;
    --
    --
    CURSOR c_get_min_max_ordr_num IS
      SELECT   MIN(cop.ordr_num),
               MAX(cop.ordr_num)
      FROM     ben_oipl_f cop
      WHERE    cop.pl_id = l_pl_id
      AND      l_lf_evt_ocrd_dt BETWEEN cop.effective_start_date
                   AND cop.effective_end_date
      AND      cop.business_group_id = p_business_group_id;
    --
    l_latest_procd_dt              DATE;
    l_backed_out_date              DATE;
    l_orig_epsd                    DATE;
    --
/*
    cursor c_regn_125_or_129 is
      select   'Y'
      from     ben_pl_regn_f prg,
               ben_regn_f regn
      where    prg.pl_id=l_pl_id
           and p_effective_date between
               prg.effective_start_date and prg.effective_end_date
           and prg.business_group_id=p_business_group_id
           and regn.regn_id=prg.regn_id
           and regn.name in ('IRC Section 125','IRC Section 129')
           and p_effective_date between
               regn.effective_start_date and regn.effective_end_date
           and regn.business_group_id=p_business_group_id
      ;
*/
  --
  -- following requery logic added for bug 1394507 - 9 cursors
  --
  cursor c_pgm_requery(p_id number,p_ed date) is
    select 'Y'
    from ben_pgm_f pgm
    where pgm_id=p_id and
          business_group_id=p_business_group_id and
          p_ed between effective_start_date and effective_end_date
    ;
  --
  cursor c_plip_requery(p_id number,p_ed date) is
    select 'Y'
    from ben_plip_f plip
    where plip_id=p_id and
          business_group_id=p_business_group_id and
          p_ed between effective_start_date and effective_end_date
    ;
  --
  cursor c_ptip_requery(p_id number,p_ed date) is
    select 'Y'
    from ben_ptip_f ptip
    where ptip_id=p_id and
          business_group_id=p_business_group_id and
          p_ed between effective_start_date and effective_end_date
    ;
  --
  cursor c_oipl_requery(p_id number,p_ed date) is
    select 'Y'
    from ben_oipl_f oipl
    where oipl_id=p_id and
          business_group_id=p_business_group_id and
          p_ed between effective_start_date and effective_end_date
    ;
  --
  cursor c_opt_requery(p_id number,p_ed date) is
    select 'Y'
    from ben_opt_f opt
    where opt_id=p_id and
          business_group_id=p_business_group_id and
          p_ed between effective_start_date and effective_end_date
    ;
  --
  cursor c_plan_requery(p_id number,p_ed date) is
    select 'Y'
    from ben_pl_f plan
    where pl_id=p_id and
          business_group_id=p_business_group_id and
          p_ed between effective_start_date and effective_end_date
    ;
  --
  cursor c_pl_typ_requery(p_id number,p_ed date) is
    select 'Y'
    from ben_pl_typ_f pl_typ
    where pl_typ_id=p_id and
          business_group_id=p_business_group_id and
          p_ed between effective_start_date and effective_end_date
    ;
  --
  cursor c_lee_rsn_requery(p_id number,p_ed date) is
    select 'Y'
    from ben_lee_rsn_f lee_rsn
    where lee_rsn_id=p_id and
          business_group_id=p_business_group_id and
          p_ed between effective_start_date and effective_end_date
    ;
  --
  cursor c_ler_requery(p_id number,p_ed date) is
    select 'Y'
    from ben_ler_f ler
    where ler_id=p_id and
          business_group_id=p_business_group_id and
          p_ed between effective_start_date and effective_end_date
    ;
  --
  -- unrestricted process change
  cursor c_prtt_enrt_rslt(l_prtt_enrt_rslt_id number) is
    select min(effective_start_date)
    from   ben_prtt_enrt_rslt_f
    where  prtt_enrt_rslt_id = l_prtt_enrt_rslt_id;
  l_effective_start_date date;
  --
  cursor c_opt_level is
    select oipl2.ordr_num
    from   ben_oipl_f oipl,
           ben_oipl_f oipl2
    where  oipl.oipl_id  = p_oipl_id
    and    oipl.pl_id   = oipl2.pl_id
    and    oipl2.oipl_stat_cd = 'A'
    and    oipl.business_group_id = p_business_group_id
    and    l_lf_evt_ocrd_dt BETWEEN oipl.effective_start_date
                   AND oipl.effective_end_date
    and    oipl2.business_group_id = p_business_group_id
    and      l_lf_evt_ocrd_dt BETWEEN oipl2.effective_start_date
                   AND oipl2.effective_end_date
    order by 1;
  --

  --
  l_cnt          number := 0;
  l_oipl_seq_num number ;
  l_enrd_seq_num number ;
  l_found        boolean := FALSE;
  l_opt_level    number;
  l_new_cvg_strt  varchar2(1) := 'N';
  l_cvg_dt       date;
  l_enrt_cd_level varchar2(30);


  --
  -- CWB Chnages.
  --
  l_emp_epe_id   number;
  l_inelg_rsn_cd ben_elig_per_f.inelg_rsn_cd%type; -- 2650247

  -- CWBITEM
  l_emp_pel_id   number;
  l_pel_id       number;
  --

  -- CWBITEM
/*  cursor c_cwb_hrchy(cv_emp_epe_id in number) is
   select emp_elig_per_elctbl_chc_id
   from ben_cwb_mgr_hrchy
   where emp_elig_per_elctbl_chc_id = cv_emp_epe_id; */
  --
  cursor c_hrchy(cv_emp_epe_id number) is
   select hrc.emp_pil_elctbl_chc_popl_id,
          pel.pil_elctbl_chc_popl_id
   from ben_elig_per_elctbl_chc epe,
        ben_pil_elctbl_chc_popl pel,
        ben_cwb_hrchy hrc
   where pel.pil_elctbl_chc_popl_id = epe.pil_elctbl_chc_popl_id
     and epe.elig_per_elctbl_chc_id = cv_emp_epe_id
     and hrc.emp_pil_elctbl_chc_popl_id(+) = pel.pil_elctbl_chc_popl_id;
  --
  -- BUG 6519487 fix
  l_dummy_varchar varchar2(30);
  l_current_pl_typ_id number;
  --END BUG 6519487 fix
  BEGIN
    --
    g_debug := hr_utility.debug_enabled;
    hr_utility.set_location('Entering:' || l_proc, 10);
    --
    -- If the run_mode is not "life event" or "scheduled" DONE
    -- Bug 2200139 Added 'V' mode for override
    -- ABSENCES - added absence mode. Added GRADE/STEP
    -- iRec - Added mode 'I'
    --
    IF p_run_mode NOT IN ('L', 'C', 'U','W','V', 'M','G', 'I','D') THEN
      --
      fnd_message.set_name('BEN', 'BEN_91458_DENRR_MODE_INVALID');
      fnd_message.set_token('PROC', l_proc);
      fnd_message.set_token('MODE', p_run_mode);
      fnd_message.set_token('PERSON_ID', TO_CHAR(p_person_id));
      RAISE ben_manage_life_events.g_record_error;
    --
    END IF;
    --
    -- Get option information if an oipl_id is passed,
    -- need to do this before getting oipl eligibility.
    --
    IF (p_oipl_id IS NOT NULL) THEN
      --
      -- get oipl information
      --
      if g_debug then
      hr_utility.set_location('OIPL NN: ' || l_proc, 10);
      end if;
      --
      -- Bug 2200139 For Override call the cache routine else call the benmnglecache
      -- this is not required as the data is fetched on the benovrrd.pkb
      --IF p_run_mode = 'V' THEN
      --  --
      --  ben_cobj_cache.get_oipl_dets (
      --     p_business_group_id => p_business_group_id
      --    ,p_effective_date    => p_effective_date
      --    ,p_oipl_id           => p_oipl_id
      --    ,p_inst_row          => l_oipl_rec
      --    ) ;
      --  --
      --ELSE
        --
        l_oipl_rec := ben_cobj_cache.g_oipl_currow;
        l_oipl_name :=               ben_cobj_cache.g_opt_currow.name;
        --
      --END IF;
      --
      l_pl_id :=                   l_oipl_rec.pl_id;
      l_oipl_dflt_flag :=          l_oipl_rec.dflt_flag;
      l_opt_id :=                  l_oipl_rec.opt_id;
      l_mndtry_flag :=             l_oipl_rec.mndtry_flag;
      l_mndtry_rl :=               l_oipl_rec.mndtry_rl;
      l_oipl_auto_enrt_flag :=     l_oipl_rec.auto_enrt_flag;
      l_oipl_auto_enrt_mthd_rl :=  l_oipl_rec.auto_enrt_mthd_rl;
      l_oipl_trk_inelig_per_flag := l_oipl_rec.trk_inelig_per_flag;
      --
      -- l_oipl_name :=               ben_cobj_cache.g_opt_currow.name;
      if g_debug then
      hr_utility.set_location('DONE OIPL NN: ' || l_proc, 10);
      end if;
    --
    ELSE
      --
      l_pl_id :=  p_pl_id;
    --
    END IF;
    --
    -- get plan cache row
    --
    ben_comp_object.get_object(p_pl_id => l_pl_id, p_rec => l_plan_rec);
    if g_debug then
    hr_utility.set_location('Done PLN cac: ' || l_proc, 10);
    hr_utility.set_location(
      'Plan name is ' || SUBSTR(l_plan_rec.name, 1, 30),
      17);
    end if;
    --
    -- Get pgm cache row if needed
    --
    IF p_pgm_id IS NOT NULL THEN
    if g_debug then
      hr_utility.set_location('PGM NN 2: ' || l_proc, 10);
    end if;
      ben_comp_object.get_object(p_pgm_id => p_pgm_id, p_rec => l_pgm_rec);
      if g_debug then
      hr_utility.set_location('Done PGM NN 2: ' || l_proc, 10);
      hr_utility.set_location(
        'Pgm name is ' || SUBSTR(l_pgm_rec.name, 1, 30),
        18);
      end if;
    END IF;
    --
    -- Check required parameters of run_mode, person_id, pl_id or oipl_id,
    -- business_group_id, and ler_id.
    --
    IF (
            p_run_mode IS NULL
         OR p_business_group_id IS NULL
         OR p_effective_date IS NULL
         OR p_ler_id IS NULL
         OR p_person_id IS NULL
         OR l_pl_id IS NULL) THEN
      --
      if g_debug then
      hr_utility.set_location('error', 19);
      end if;
      fnd_message.set_name('BEN', 'BEN_91737_ENRT_REQ_MISS_PARM');
      fnd_message.set_token('PROC', l_proc);
      fnd_message.set_token('MODE', p_run_mode);
      fnd_message.set_token('BG_ID', TO_CHAR(p_business_group_id));
      fnd_message.set_token('EFFECTIVE_DATE', TO_CHAR(p_effective_date));
      fnd_message.set_token('LER_ID', TO_CHAR(p_ler_id));
      fnd_message.set_token('PERSON_ID', TO_CHAR(p_person_id));
      fnd_message.set_token('PL_ID', TO_CHAR(l_pl_id));
      RAISE ben_manage_life_events.g_record_error;
    --
    END IF;
    --
/*  -- 4031733 - Cursor c_state populates l_state variable which is no longer
    -- used in the package. Cursor can be commented

    IF p_person_id IS NOT NULL THEN
      OPEN c_state;
      FETCH c_state INTO l_state;
      CLOSE c_state;
      hr_utility.set_location('close c_state: ' || l_proc, 10);
      --
      --IF l_state.region_2 IS NOT NULL THEN
        --
      --  l_jurisdiction_code :=
      --    pay_mag_utils.lookup_jurisdiction_code(p_state => l_state.region_2);
      --
     -- END IF;
    --
    END IF;
*/
    --
    OPEN c_asg;
    FETCH c_asg INTO l_rec_assignment_id, l_rec_organization_id;
    IF c_asg%NOTFOUND THEN
      CLOSE c_asg;
      hr_utility.set_location('error', 20);
      fnd_message.set_name('BEN', 'BEN_92106_PRTT_NO_ASGN');
      fnd_message.set_token('PROC', l_proc);
      fnd_message.set_token('PERSON_ID', TO_CHAR(p_person_id));
      fnd_message.set_token('LF_EVT_OCRD_DT', TO_CHAR(p_lf_evt_ocrd_dt));
      fnd_message.set_token('EFFECTIVE_DATE', TO_CHAR(p_effective_date));
      RAISE ben_manage_life_events.g_record_error;
    END IF;
    CLOSE c_asg;
    hr_utility.set_location('close c_asg: ' || l_proc, 10);
    --
    -- Determine if the person is currently enrolled and if so
    -- determine the coverage start date.
    --
    IF p_run_mode in ('M','U') then
       l_cvg_dt := l_lf_evt_ocrd_dt;
    ELSE
       l_cvg_dt := l_lf_evt_ocrd_dt_1;
    END IF;

  IF p_run_mode <> 'D' THEN
   --
    ------------Bug 8846328
    l_fut_rslt_exist := false;
    l_crnt_enrt_sspndd_flag := 'N';
    -------------Bug 8846328
    IF (p_oipl_id IS NULL)  THEN
      --
      --8399189
      OPEN c_plan_enrolment_info(l_cvg_dt,p_run_mode);
      --
      FETCH c_plan_enrolment_info INTO l_crnt_enrt_cvg_strt_dt,
                                     l_crnt_erlst_deenrt_dt,
                                     l_prtt_enrt_rslt_id,
                                     l_enrt_ovridn_flag,
                                     l_enrt_ovrid_thru_dt,
                                     l_orgnl_enrt_dt,
                                     l_crnt_enrt_cvg_thru_dt,  --BUG 6519487 fix
                                     l_current_pl_typ_id ;  --BUG 6519487 fix
      --
      IF c_plan_enrolment_info%NOTFOUND THEN
        --
        l_crnt_enrt_cvg_strt_dt :=  NULL;
        --
        --  Check if person is a covered dependent - COBRA.
        --
        IF p_pgm_id IS NOT NULL THEN
          IF l_pgm_rec.pgm_typ_cd LIKE 'COBRA%' THEN
            OPEN c_plan_cvg_info;
            FETCH c_plan_cvg_info INTO l_dpnt_cvrd_flag;
            CLOSE c_plan_cvg_info;
          END IF;
        END IF;
      --
      ELSE
        --BUG 6519487 fix
        IF l_crnt_enrt_cvg_thru_dt <> hr_api.g_eot THEN
          OPEN c_future_results (p_person_id ,
                             l_crnt_enrt_cvg_thru_dt,
                             p_pgm_id   ,
                             l_current_pl_typ_id) ;
          --
          FETCH c_future_results INTO l_future_results;--Bug 8453712,l_dummy_varchar;
          IF c_future_results%FOUND THEN
	    if l_future_results.pl_id <> l_pl_id then
	    hr_utility.set_location('in if',10.1);
             --
             l_crnt_enrt_cvg_strt_dt := null;
             l_crnt_erlst_deenrt_dt := null;
             l_prtt_enrt_rslt_id := null;
             l_enrt_ovridn_flag := null;
             l_enrt_ovrid_thru_dt := null;
             l_crnt_enrt_cvg_thru_dt := null;
             --
	    else  --Bug 8453712
	     hr_utility.set_location('in else',10.1);
	     l_fut_rslt_exist := true;  -------------Bug 8846328
	     l_crnt_enrt_cvg_strt_dt := l_future_results.enrt_cvg_strt_dt;
             l_crnt_erlst_deenrt_dt := l_future_results.erlst_deenrt_dt;
             l_prtt_enrt_rslt_id := l_future_results.prtt_enrt_rslt_id;
             l_enrt_ovridn_flag := l_future_results.enrt_ovridn_flag;
             l_enrt_ovrid_thru_dt := l_future_results.enrt_ovrid_thru_dt;
             l_crnt_enrt_cvg_thru_dt := l_future_results.enrt_cvg_thru_dt;
	    end if;
          END IF;
          --
          CLOSE c_future_results ;
        END IF;
        --END BUG 6519487 fix
        --
      END IF;
      --
      CLOSE c_plan_enrolment_info;
      if g_debug then
      hr_utility.set_location('close c_PEI: ' || l_proc, 10);
      end if;
    --
    ELSE
      --
      OPEN c_oipl_enrolment_info(l_cvg_dt,p_run_mode);
      --
      FETCH c_oipl_enrolment_info INTO l_crnt_enrt_cvg_strt_dt,
                                       l_crnt_erlst_deenrt_dt,
                                       l_prtt_enrt_rslt_id,
                                       l_enrt_ovridn_flag,
                                       l_enrt_ovrid_thru_dt,
                                       l_crnt_enrt_cvg_thru_dt, --BUG 6519487 fix
				       l_crnt_enrt_sspndd_flag,  ------------Bug 8846328
                                       l_current_pl_typ_id;   --BUG 6519487 fix      --
      IF c_oipl_enrolment_info%NOTFOUND THEN
        --
        l_crnt_enrt_cvg_strt_dt :=  NULL;
        --
        --  Check if person is a covered dependent - COBRA.
        --
        IF p_pgm_id IS NOT NULL THEN
          IF l_pgm_rec.pgm_typ_cd LIKE 'COBRA%' THEN
            OPEN c_oipl_cvg_info;
            FETCH c_oipl_cvg_info INTO l_dpnt_cvrd_flag;
            CLOSE c_oipl_cvg_info;
          END IF;
        END IF;
      --
      ELSE
      ----BUG 6519487 fix
        IF l_crnt_enrt_cvg_thru_dt <> hr_api.g_eot THEN
          OPEN c_future_results (p_person_id ,
                               l_crnt_enrt_cvg_thru_dt,
                               p_pgm_id   ,
                               l_current_pl_typ_id) ;
          --
          FETCH c_future_results INTO l_future_results ;-----Bug 8453712,l_dummy_varchar;
          IF c_future_results%FOUND THEN
            if l_future_results.pl_id <> l_pl_id then  -------Bug

	     hr_utility.set_location('in if',10.1);
             --
             l_crnt_enrt_cvg_strt_dt := null;
             l_crnt_erlst_deenrt_dt := null;
             l_prtt_enrt_rslt_id := null;
             l_enrt_ovridn_flag := null;
             l_enrt_ovrid_thru_dt := null;
             l_crnt_enrt_cvg_thru_dt := null;
           else  ----Bug 8768050
	     hr_utility.set_location('in else',10.1);
	     l_fut_rslt_exist := true;  -------------Bug 8846328
	     l_crnt_enrt_cvg_strt_dt := l_future_results.enrt_cvg_strt_dt;
             l_crnt_erlst_deenrt_dt := l_future_results.erlst_deenrt_dt;
             l_prtt_enrt_rslt_id := l_future_results.prtt_enrt_rslt_id;
             l_enrt_ovridn_flag := l_future_results.enrt_ovridn_flag;
             l_enrt_ovrid_thru_dt := l_future_results.enrt_ovrid_thru_dt;
             l_crnt_enrt_cvg_thru_dt := l_future_results.enrt_cvg_thru_dt;
	    end if; -------Bug 8768050
          END IF;
          CLOSE c_future_results ;
        END IF;
        --END BUG 6519487 fix
      --
      END IF;
      --
      CLOSE c_oipl_enrolment_info;
      if g_debug then
      hr_utility.set_location('close c_OIEI: ' || l_proc, 10);
      end if;
    --
    END IF;
    --
  END IF;
    -- Bug 2200139 For Override don't associate the current enrollment
    --
    if p_run_mode = 'V' then
      --
      l_crnt_enrt_cvg_strt_dt := null;
      l_prtt_enrt_rslt_id := null;
      --
    end if;
    --
    -- unrestricted process changes
    -- if mode is unrestricted and crnt_enrt_strt_date > p_effective_date assign null
    -- as unrestricted may be processed before the previously processed life event
    --
    if p_run_mode = 'U' then
        --
        if l_crnt_enrt_cvg_strt_dt is not null  then
            --
            --  Bug 2290302 see the Bug for datails. We cann't have this
            -- condition as user may have the coverage started in future
            -- for the current enrollment.
            -- if l_crnt_enrt_cvg_strt_dt > p_effective_date then
            --    l_crnt_enrt_cvg_strt_dt := null;
            --    l_prtt_enrt_rslt_id := null;
            --
            -- else
               --
               open c_prtt_enrt_rslt(l_prtt_enrt_rslt_id);
               fetch c_prtt_enrt_rslt into l_effective_start_date;
               close c_prtt_enrt_rslt;
               --
               if l_effective_start_date > p_effective_date then
                  l_crnt_enrt_cvg_strt_dt := null;
                  l_prtt_enrt_rslt_id := null;
               end if;
              --
            --  end if;
        end if;
    end if;
    --
    -- Determine if the person is eligible for this compensation object.
    --
    ben_pep_cache.get_currpepepo_dets
      (p_comp_obj_tree_row => p_comp_obj_tree_row
      ,p_per_in_ler_id     => p_per_in_ler_id
      ,p_effective_date    => p_effective_date
      ,p_pgm_id            => p_pgm_id
      ,p_pl_id             => l_pl_id
      ,p_oipl_id           => p_oipl_id
      ,p_opt_id            => l_opt_id
      --
      ,p_inst_row          => l_currpep_dets
      );
    --
    IF l_currpep_dets.elig_per_id is null THEN
      --
      l_current_eligibility :=  'N';
      --
      If NVL(l_currpep_dets.inelg_rsn_cd, 'OTH') = 'OTH'
        and nvl(ben_evaluate_elig_profiles.g_inelg_rsn_cd,'OTH') <> 'OTH'
        and p_run_mode = 'W'
      then     -- Bug 4447114, If condition added
          l_inelg_rsn_cd	      := ben_evaluate_elig_profiles.g_inelg_rsn_cd ;
      else
          l_inelg_rsn_cd	      := l_currpep_dets.inelg_rsn_cd ;
      end if;
      --
    else
      --
      l_elig_per_id           := l_currpep_dets.elig_per_id;
      l_current_eligibility   := l_currpep_dets.elig_flag;
      l_must_enrl_anthr_pl_id := l_currpep_dets.must_enrl_anthr_pl_id;
      l_prtn_strt_dt          := l_currpep_dets.prtn_strt_dt;
      --l_inelg_rsn_cd	      := l_currpep_dets.inelg_rsn_cd;      -- 2650247
      --
      If NVL(l_currpep_dets.inelg_rsn_cd, 'OTH') = 'OTH'
        and nvl(ben_evaluate_elig_profiles.g_inelg_rsn_cd,'OTH') <> 'OTH'
        and p_run_mode = 'W'
      then  -- Bug 4447114, If condition added
          l_inelg_rsn_cd	      := ben_evaluate_elig_profiles.g_inelg_rsn_cd ;
      else
          l_inelg_rsn_cd	      := l_currpep_dets.inelg_rsn_cd ;
      end if;
      --
    END IF;
    if g_debug then
    hr_utility.set_location('Got passed initial comp loads', 21);
    end if;
    --
    -- If the current_eligibility is N, DONE, no choice is required.
    --  ...(12/23/1998 except when overridden, and thru date >= ed jcarpent)
    --
    -- combine both ovrid(n) fields into one as to simplify for use
    -- further down in the code.
    --
    IF (
             l_enrt_ovridn_flag = 'Y'
         AND l_enrt_ovrid_thru_dt >= NVL(p_lf_evt_ocrd_dt, p_effective_date)) THEN
      l_enrt_ovridn_flag :=  'Y';
    ELSE
      l_enrt_ovridn_flag :=  'N';
    END IF;
    --
    -- Now, can we elect?
    --
     --cwb changes
     --Bug 2200139 Override Enrollment Changes
    IF l_current_eligibility = 'N'
       AND l_enrt_ovridn_flag = 'N' and p_run_mode <> 'W' and p_run_mode <> 'V' THEN
      --
      p_electable_flag :=  'N';
      --
      if g_debug then
      hr_utility.set_location(' Leaving:' || l_proc, 15);
      end if;
      --
      RETURN;
    --
    END IF;
    --
    --
    -- Determine if the person was previously eligible for this comp object.
    --
  IF p_run_mode <> 'D' THEN
   --
    IF (p_oipl_id IS NULL) THEN
      --
      ben_pep_cache.get_pilpep_dets
        (p_person_id         => p_person_id
        ,p_business_group_id => p_business_group_id
        ,p_effective_date    => l_effective_date_1
        ,p_pgm_id            => p_pgm_id
        ,p_pl_id             => l_pl_id
        ,p_plip_id           => null
        ,p_ptip_id           => null
        ,p_inst_row          => l_prevpep_rec
        );
      --
      if l_prevpep_rec.elig_flag is null
      then
        --
        l_previous_eligibility := 'N';
        --
      else
        --
        l_previous_eligibility := l_prevpep_rec.elig_flag;
        --
      end if;
      --
      if g_debug then
      hr_utility.set_location('close c_PEFP: ' || l_proc, 10);
      end if;
      --
    ELSE
      --
      ben_pep_cache.get_pilepo_dets
        (p_person_id         => p_person_id
        ,p_business_group_id => p_business_group_id
        ,p_effective_date    => l_effective_date_1 --p_effective_date
        ,p_pgm_id            => p_comp_obj_tree_row.par_pgm_id
        ,p_pl_id             => p_comp_obj_tree_row.par_pl_id
        ,p_opt_id            => p_comp_obj_tree_row.par_opt_id
        --
        ,p_inst_row          => l_prevepo_rec
        );
      --
      if l_prevepo_rec.elig_flag is null
      then
        --
        l_previous_eligibility := 'N';
        --
      else
        --
        l_previous_eligibility := l_prevepo_rec.elig_flag;
        --
      end if;
      --
      if g_debug then
      hr_utility.set_location('close c_PEFO: ' || l_proc, 10);
      end if;
      --
    END IF;
    --
  END IF;  --'D' mode
  if g_debug then
    hr_utility.set_location('get plan info', 10);
  end if;
    --
    -- get plan_info
    --
    l_pl_name :=                  l_plan_rec.name;
    l_pl_typ_id :=                l_plan_rec.pl_typ_id;
    l_pl_enrt_cd :=               l_plan_rec.enrt_cd;
    l_pl_enrt_rl :=               l_plan_rec.enrt_rl;
    l_pl_enrt_mthd_cd :=          l_plan_rec.enrt_mthd_cd;
    l_pl_auto_enrt_rl :=          l_plan_rec.auto_enrt_mthd_rl;
    l_invk_flx_cr_pl_flag :=      l_plan_rec.invk_flx_cr_pl_flag;
    l_imptd_incm_calc_cd :=       l_plan_rec.imptd_incm_calc_cd;
    l_pl_trk_inelig_per_flag :=   l_plan_rec.trk_inelig_per_flag;
    --
    -- If a pgm_id was passed
    --
    IF (p_pgm_id IS NOT NULL) THEN
      --
      -- Find the plip and get its needed attributes.
      --
      OPEN c_plip_info;
      --
      FETCH c_plip_info INTO l_plip_id,
                             l_plip_dflt_flag,
                             l_plip_enrt_cd,
                             l_plip_enrt_rl,
                             l_plip_enrt_mthd_cd,
                             l_plip_auto_enrt_rl,
                             l_alws_unrstrctd_enrt_flag,
                             l_plip_esd,
                             l_plip_eed,
                             l_plip_ordr_num;
      IF c_plip_info%NOTFOUND THEN
        --
        fnd_message.set_name('BEN', 'BEN_91461_PLIP_MISSING');
        fnd_message.set_token('PROC', l_proc);
        fnd_message.set_token('PGM_ID', TO_CHAR(p_pgm_id));
        fnd_message.set_token('PL_ID', TO_CHAR(l_pl_id));
        fnd_message.set_token('BG_ID', TO_CHAR(p_business_group_id));
        RAISE ben_manage_life_events.g_record_error;
      --
      END IF;
      --
      CLOSE c_plip_info;
      if g_debug then
      hr_utility.set_location('close c_plip_info: ' || l_proc, 10);
      end if;
      --
      -- Find the ptip and get its needed attributes.
      --
      OPEN c_ptip_info;
      --
      FETCH c_ptip_info INTO l_ptip_id,
                             l_ptip_enrt_cd,
                             l_ptip_enrt_rl,
                             l_ptip_enrt_mthd_cd,
                             l_ptip_auto_enrt_rl,
                             l_ptip_esd,
                             l_ptip_eed,
                             l_ptip_ordr_num;
      --
      IF c_ptip_info%NOTFOUND THEN
        --
        fnd_message.set_name('BEN', 'BEN_91462_PTIP_MISSING');
        fnd_message.set_token('PROC', l_proc);
        fnd_message.set_token('PGM_ID', TO_CHAR(p_pgm_id));
        fnd_message.set_token('PL_TYP_ID', TO_CHAR(l_pl_typ_id));
        fnd_message.set_token('BG_ID', TO_CHAR(p_business_group_id));
        RAISE ben_manage_life_events.g_record_error;
      --
      END IF;
      --
      CLOSE c_ptip_info;
      if g_debug then
      hr_utility.set_location('close c_ptip_info: ' || l_proc, 10);
      end if;
    --
    END IF;
--
-- Unrestricted processing
--   for mode of U only let qualified plans through
--   for other modes if plan is unrestricted process
--   as normally do (i.e. set l_unrestricted_enrt_flag
--   to 'N')
--
-- mode=U   unres_flag=Y   set flag   return
--    N          N            N          N
--    N          Y            N          N
--    Y          N            n/a        Y
--    Y          Y            Y          N
--
    IF (p_pgm_id IS NULL) THEN
      l_alws_unrstrctd_enrt_flag :=  l_plan_rec.alws_unrstrctd_enrt_flag;
      if g_debug then
      hr_utility.set_location(
        'alws_unres_flag=' || l_alws_unrstrctd_enrt_flag,
        10);
      end if;
    END IF;
    --
    -- all that to do this
    --
    IF p_run_mode in ('U','D') THEN
      IF l_alws_unrstrctd_enrt_flag = 'Y' THEN
        l_unrestricted_enrt_flag :=  'Y';
	if g_debug then
        hr_utility.set_location(
          'Unrestricted mode in force for this plan',
          10);
        end if;
      ELSE
        p_electable_flag :=  'N';
	if g_debug then
        hr_utility.set_location('Unrestricted mode not for regular plans', 10);
	end if;
        RETURN;
      END IF;
    ELSE
      l_unrestricted_enrt_flag :=  'N';
    END IF;
    --
    if g_debug then
    hr_utility.set_location('per in ler info', 20);
    end if;
    --
    -- Bug 2200139  this cursor is getting the Started Perinler info.
    -- for Override Mode we get the info of the p_ler_in_ler_id
    if p_run_mode = 'V' then
      OPEN c_ovrd_per_in_ler_info;
      --
      FETCH c_ovrd_per_in_ler_info INTO l_per_in_ler_id,
                                   l_ler_typ_cd,
                                   l_ler_name,
                                   l_lf_evt_ocrd_dt_fetch,
                                   l_ler_esd,
                                   l_ler_eed;
      --
      IF c_ovrd_per_in_ler_info%NOTFOUND THEN
        --
        fnd_message.set_name('BEN', 'BEN_91272_PER_IN_LER_MISSING');
        fnd_message.set_token('PROC', l_proc);
        fnd_message.set_token('PERSON_ID', TO_CHAR(p_person_id));
        fnd_message.set_token('LER_ID', TO_CHAR(p_ler_id));
        fnd_message.set_token('EFFECTIVE_DATE', TO_CHAR(p_effective_date));
        fnd_message.set_token('BG_ID', TO_CHAR(p_business_group_id));
        RAISE ben_manage_life_events.g_record_error;
      --
      END IF;
      --
      CLOSE c_ovrd_per_in_ler_info;
      if g_debug then
      hr_utility.set_location('close c_PILI: ' || l_proc, 10);
      end if;
      --
    else
      --
      OPEN c_per_in_ler_info;
      --
      FETCH c_per_in_ler_info INTO l_per_in_ler_id,
                                 l_ler_typ_cd,
                                 l_ler_name,
                                 l_lf_evt_ocrd_dt_fetch,
                                 l_ler_esd,
                                 l_ler_eed;
      --
      IF c_per_in_ler_info%NOTFOUND THEN
        --
        fnd_message.set_name('BEN', 'BEN_91272_PER_IN_LER_MISSING');
        fnd_message.set_token('PROC', l_proc);
        fnd_message.set_token('PERSON_ID', TO_CHAR(p_person_id));
        fnd_message.set_token('LER_ID', TO_CHAR(p_ler_id));
        fnd_message.set_token('EFFECTIVE_DATE', TO_CHAR(p_effective_date));
        fnd_message.set_token('BG_ID', TO_CHAR(p_business_group_id));
        RAISE ben_manage_life_events.g_record_error;
      --
      END IF;
      --
      CLOSE c_per_in_ler_info;
    end if;
    if g_debug then
    hr_utility.set_location('close c_PILI: ' || l_proc, 10);
    end if;
    --

    OPEN c_pl_popl_yr_period_current;
    --
    FETCH c_pl_popl_yr_period_current INTO l_yr_perd_id,
                                           l_popl_yr_perd_id,
                                           l_yr_perd_strt_date,
                                           l_yr_perd_end_date,
                                           l_popl_yr_perd_ordr_num;
    --
    IF ((c_pl_popl_yr_period_current%NOTFOUND) and (p_run_mode not in ('G','D'))) THEN
      --
      fnd_message.set_name('BEN', 'BEN_91334_PLAN_YR_PERD');
      fnd_message.set_token('PROC', l_proc);
      RAISE ben_manage_life_events.g_record_error;
    --
    END IF;
    --
    CLOSE c_pl_popl_yr_period_current;
    if g_debug then
    hr_utility.set_location('close c_PPYPC: ' || l_proc, 10);
    --
    hr_utility.set_location('oipl id is null', 20);
    end if;
    ben_epe_cache.get_pilcobjepe_dets
      (p_per_in_ler_id => p_per_in_ler_id
      ,p_pgm_id        => p_pgm_id
      ,p_pl_id         => l_pl_id
      ,p_oipl_id       => p_oipl_id
      --
      ,p_inst_row      => l_currepe_dets
      );
    --
    IF l_currepe_dets.elig_per_elctbl_chc_id is not null and
         p_run_mode not in ('U','R','D') THEN
      --
      fnd_message.set_name('BEN', 'BEN_91463_ELCTBL_CHC_EXISTS');
      fnd_message.set_token('PROC', l_proc);
      benutils.write(p_text => SUBSTR(fnd_message.get, 1, 128));
      if g_debug then
      hr_utility.set_location('Leaving: ' || l_proc, 20);
      end if;
      p_electable_flag :=  'N';
      RETURN;
      --
    --bug#4096382
    elsif  l_currepe_dets.elig_per_elctbl_chc_id is not null and
         p_run_mode in ('U','R') THEN
       --
       l_epe_exists :=  ben_manage_unres_life_events.epe_exists
                         (p_per_in_ler_id => l_per_in_ler_id,
                          p_pgm_id => p_pgm_id,
                          p_pl_id  => l_pl_id,
                          p_oipl_id =>p_oipl_id);
       --
       if l_epe_Exists is null then  -- comp object in pgm/plnot in pgm  is in pending or suspended status
         --
          p_electable_flag :=  'N';
          RETURN;
         --
       end if;
       --
    END IF;
    --
    -- do prerequisite check if not overridden.
    --
    if g_debug then
    hr_utility.set_location('enroll another plan', 20);
    end if;
    IF     l_must_enrl_anthr_pl_id IS NOT NULL
       AND l_enrt_ovridn_flag = 'N'
    THEN
      --
      -- Get the current electable choice info for the comp object
      --
      ben_epe_cache.get_pilcobjepe_dets
        (p_per_in_ler_id => p_per_in_ler_id
        ,p_pgm_id        => p_pgm_id
        ,p_pl_id         => l_must_enrl_anthr_pl_id
        ,p_oipl_id       => null
        --
        ,p_inst_row      => l_currepe_dets
        );
      --
      IF l_currepe_dets.elig_per_elctbl_chc_id is null THEN
        --
        -- prereq not found recurse.
        --
        enrolment_requirements
          (p_comp_obj_tree_row      => p_comp_obj_tree_row
          ,p_run_mode               => p_run_mode
          ,p_business_group_id      => p_business_group_id
          ,p_effective_date         => p_effective_date
          ,p_lf_evt_ocrd_dt         => p_lf_evt_ocrd_dt
          ,p_ler_id                 => p_ler_id
          ,p_per_in_ler_id          => p_per_in_ler_id
          ,p_person_id              => p_person_id
          ,p_pl_id                  => l_must_enrl_anthr_pl_id
          ,p_pgm_id                 => p_pgm_id
          ,p_oipl_id                => NULL
          ,p_elig_per_elctbl_chc_id => l_elig_per_elctbl_chc_id
          ,p_electable_flag         => l_prereq_electable_flag
          -- ,p_popl_enrt_typ_cycl_id  => p_popl_enrt_typ_cycl_id
          );
      if g_debug then
        hr_utility.set_location('Dn Sub BENDENRR: ' || l_proc, 99);
      end if;
        --
        IF l_prereq_electable_flag = 'N' THEN
          --
          p_electable_flag :=  'N';
	  if g_debug then
          hr_utility.set_location('Not electable since prereq is not.', 10);
	  end if;
          RETURN;
        --
        END IF;
      --
      END IF;
      --
      if g_debug then
      hr_utility.set_location('close c_CHEFP: ' || l_proc, 10);
      --
      hr_utility.set_location('found prereq plan choice', 10);
    --
      end if;
    END IF;                                                   -- prereq exists.
    --
    -- Determine if the compensation object requires or allows an election change
    -- If life event mode
    --
    if g_debug then
    hr_utility.set_location('ler change stuff', 20);
    end if;
    l_ler_chg_found_flag :=       'N';
    l_ler_chg_oipl_found_flag :=  'N';
    --
    -- See if there is a life event reason to change
    --
    if g_debug then
    hr_utility.set_location('ler change stuff not null stuff', 20);
    hr_utility.set_location(' Op c_lce_info: ' || l_proc, 10);
    end if;
    --
 IF p_run_mode <> 'D' THEN
  --
    determine_ben_settings(
      p_pl_id                     => l_pl_id,
      p_ler_id                    => p_ler_id,
      p_lf_evt_ocrd_dt            => l_lf_evt_ocrd_dt,
      p_ptip_id                   => l_ptip_id,
      p_pgm_id                    => p_pgm_id,
      p_plip_id                   => l_plip_id,
      p_oipl_id                   => p_oipl_id,
      p_just_prclds_chg_flag      => FALSE,
      p_enrt_cd                   => l_ler_enrt_cd,
      p_enrt_rl                   => l_ler_enrt_rl,
      p_auto_enrt_mthd_rl         => l_ler_auto_enrt_rl,
      p_crnt_enrt_prclds_chg_flag => l_ler_enrt_prclds_chg_flag,
      p_dflt_flag                 => l_ler_dflt_flag,
      p_enrt_mthd_cd              => l_ler_enrt_mthd_cd,
      p_stl_elig_cant_chg_flag    => l_ler_stl_elig_cant_chg_flag,
      p_tco_chg_enrt_cd           => l_tco_chg_enrt_cd,
      p_ler_chg_oipl_found_flag   => l_ler_chg_oipl_found_flag,
      p_ler_chg_found_flag        => l_ler_chg_found_flag,
      p_enrt_cd_level             => l_enrt_cd_level );
   --
   if g_debug then
    hr_utility.set_location(' Cl c_lce_info: ' || l_proc, 10);
   end if;
    --
      -- Determine enrt codes/rules method codes/rules then
    -- figure out if electable.
    --
    --
    -- Initially set to ler_chg values if not null
    --
    IF l_ler_enrt_cd IS NOT NULL THEN
      l_pl_enrt_cd :=  l_ler_enrt_cd;
      l_pl_enrt_rl :=  l_ler_enrt_rl;
    ELSIF l_oipl_rec.enrt_cd IS NOT NULL THEN
      l_pl_enrt_cd :=  l_oipl_rec.enrt_cd;
      l_pl_enrt_rl :=  l_oipl_rec.enrt_rl;
    END IF;
    IF p_oipl_id IS NULL THEN
      IF    l_ler_enrt_mthd_cd IS NOT NULL
         OR l_ler_auto_enrt_rl IS NOT NULL THEN
        l_pl_enrt_mthd_cd :=  l_ler_enrt_mthd_cd;
        l_pl_auto_enrt_rl :=  l_ler_auto_enrt_rl;
      END IF;
    ELSE
      --
      -- below, if ler_chg row found then code will always
      -- be not null since comes from a decode of the flag.
      --
      IF l_ler_chg_oipl_found_flag = 'Y' THEN
        l_pl_enrt_mthd_cd :=  l_ler_enrt_mthd_cd;
        l_pl_auto_enrt_rl :=  l_ler_auto_enrt_rl;
        --
        IF l_ler_enrt_mthd_cd = 'A' THEN
          --
          l_oipl_auto_enrt_flag :=  'Y';
        --
        ELSE
          --
          l_oipl_auto_enrt_flag :=  'N';
        --
        END IF;
      --
      ELSE
        IF l_oipl_auto_enrt_flag = 'Y' THEN
          l_pl_enrt_mthd_cd :=  'A';
        ELSE
          l_pl_enrt_mthd_cd :=  'E';
        END IF;
        l_pl_auto_enrt_rl :=  l_oipl_auto_enrt_mthd_rl;
      END IF;
    END IF;
    --
    -- If the ler_chg values were null then now have plan values
    --
    -- Update if still null with values from above in hierarchy
    --
    IF     l_pl_enrt_cd IS NULL
       AND p_pgm_id IS NOT NULL THEN
      l_pl_enrt_cd :=  l_plip_enrt_cd;
      l_pl_enrt_rl :=  l_plip_enrt_rl;
    END IF;
    IF     l_pl_enrt_mthd_cd IS NULL
       AND p_pgm_id IS NOT NULL THEN
      l_pl_enrt_mthd_cd :=  l_plip_enrt_mthd_cd;
      l_pl_auto_enrt_rl :=  l_plip_auto_enrt_rl;
    END IF;
    --
    -- overlay ptip if value is still null
    --
    IF     l_pl_enrt_cd IS NULL
       AND p_pgm_id IS NOT NULL THEN
      l_pl_enrt_cd :=  l_ptip_enrt_cd;
      l_pl_enrt_rl :=  l_ptip_enrt_rl;
    END IF;
    IF     l_pl_enrt_mthd_cd IS NULL
       AND p_pgm_id IS NOT NULL THEN
      l_pl_enrt_mthd_cd :=  l_ptip_enrt_mthd_cd;
      l_pl_auto_enrt_rl :=  l_ptip_auto_enrt_rl;
    END IF;
    --
    -- get from program level if not at plan or plip or ptip levels
    --
    IF     l_pl_enrt_cd IS NULL
       AND p_pgm_id IS NOT NULL THEN
      l_pl_enrt_cd :=  l_pgm_rec.enrt_cd;
      l_pl_enrt_rl :=  l_pgm_rec.enrt_rl;
    END IF;
    IF     l_pl_enrt_mthd_cd IS NULL
       AND p_pgm_id IS NOT NULL THEN
      l_pl_enrt_mthd_cd :=  l_pgm_rec.enrt_mthd_cd;
      l_pl_auto_enrt_rl :=  l_pgm_rec.auto_enrt_mthd_rl;
    END IF;
    --
    -- Catch all default to explicit
    --
    --
    -- evaluate the rule and see what it returns that
    -- will take precedence over previous value.
    --
    IF l_pl_auto_enrt_rl IS NOT NULL THEN
      --
      -- Use the results of the enrt_mthd_rl as the code
      --
      if g_debug then
      hr_utility.set_location(' Exe enrt rl: ' || l_proc, 10);
      end if;
       execute_auto_dflt_enrt_rule(
         p_opt_id            => l_opt_id,
         p_pl_id             => l_pl_id,
         p_pgm_id            => p_pgm_id,
         p_rule_id           => l_pl_auto_enrt_rl,
         p_ler_id            => p_ler_id,
         p_pl_typ_id         => l_pl_typ_id,
         p_business_group_id => p_business_group_id,
         p_effective_date    => p_effective_date,
         p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
         p_elig_per_id       => l_elig_per_id,
         p_assignment_id     => l_rec_assignment_id,
         p_organization_id   => l_rec_organization_id,
         p_jurisdiction_code => l_jurisdiction_code,
	 p_person_id         => p_person_id,            -- Bug 5331889
         p_enrt_mthd         => l_pl_enrt_mthd_cd,
         p_reinstt_dpnt      => l_reinstt_flag
         );
     if g_debug then
      hr_utility.set_location(' Dn Exe enrt rl: ' || l_proc, 10);
     end if;
        --
      l_reinstt_cd := l_reinstt_flag;
      --
      -- Following if for backward compatability only
      -- in future will return A/E.
      --
      IF l_pl_enrt_mthd_cd = 'N' THEN
        --
        l_pl_enrt_mthd_cd :=  'E';
      ELSIF l_pl_enrt_mthd_cd = 'Y' THEN
        l_pl_enrt_mthd_cd :=  'A';
      END IF;
      --
      IF p_oipl_id IS NOT NULL THEN
        IF l_pl_enrt_mthd_cd = 'A' THEN
          l_oipl_auto_enrt_flag :=  'Y';
        ELSE
          l_oipl_auto_enrt_flag :=  'N';
        END IF;
      END IF;
    END IF;
    --
    IF l_pl_enrt_mthd_cd IS NULL THEN
      l_pl_enrt_mthd_cd :=  'E';
    END IF;
    --
END IF; -- 'D' Mode
    -- New Enrollment Code for changing coverage start date for currently enrolled comp.objects
    if l_pl_enrt_cd = 'CCKCSNCC' then
      l_new_cvg_strt := 'Y';
    end if;
    -- Don't check electability if automatic enrollment or
    --   only check it if explicit enrollment
    --
    -- Bug 2200139 for Override don't check electability but
    -- set the electable flag to 'N' so that users don't see these
    -- choices in the view person life events and enrollment forms.
    --
    if p_run_mode = 'V' then
      --
      l_rec_elctbl_flag := 'N' ;
      --
    else
      --
      --
      if g_debug then
      hr_utility.set_location('H', 20);
      hr_utility.set_location('Call detenr 2: ' || l_proc, 10);
      end if;
      g_ptip_id :=                  l_ptip_id;
      --
      --Bug 2677804 We dont need to get electable flag for the
      --pl/oipl if l_enrt_ovridn_flag is 'Y'
      --We need to make it electable
      --
      if l_enrt_ovridn_flag = 'Y' then
        --
	if g_debug then
        hr_utility.set_location('First Electable Due to Override ' ,123);
	end if;
        l_rec_elctbl_flag :=  'Y' ;
        --
      else
        --
        determine_enrolment(
          p_previous_eligibility   => l_previous_eligibility,
          p_crnt_enrt_cvg_strt_dt  => l_crnt_enrt_cvg_strt_dt,
          p_dpnt_cvrd_flag         => l_dpnt_cvrd_flag,
          p_person_id              => p_person_id,
          p_ler_id                 => p_ler_id,
          p_enrt_cd                => l_pl_enrt_cd,
          p_enrt_rl                => l_pl_enrt_rl,
          p_enrt_mthd_cd           => l_pl_enrt_mthd_cd,
          p_auto_enrt_mthd_rl      => l_pl_auto_enrt_rl,
          p_effective_date         => p_effective_date,
          p_lf_evt_ocrd_dt         => p_lf_evt_ocrd_dt,
          p_enrt_prclds_chg_flag   => NVL(l_ler_enrt_prclds_chg_flag, 'N'),
          p_stl_elig_cant_chg_flag => NVL(l_ler_stl_elig_cant_chg_flag, 'N'),
          p_tco_chg_enrt_cd        => NVL(l_tco_chg_enrt_cd, 'CPOO'),
          p_pl_id                  => l_pl_id,
          p_pgm_id                 => p_pgm_id,
          p_oipl_id                => p_oipl_id,
          p_opt_id                 => l_opt_id,
          p_pl_typ_id              => l_pl_typ_id,
          p_business_group_id      => p_business_group_id,
          p_electable_flag         => l_rec_elctbl_flag,
          p_assignment_id          => l_rec_assignment_id,
          p_run_mode               => p_run_mode);   -- iRec
     if g_debug then
        hr_utility.set_location('Dn detenr 2: ' || l_proc, 10);
     end if;
      end if;
      -- End Bug 2677804
      IF l_rec_elctbl_flag = 'Y' THEN
        --
        -- continue
        --
        NULL;
      --
      ELSIF l_rec_elctbl_flag = 'L' THEN
        --
        -- Lose only condition.
        -- If enrolled will deenroll.
        --
        ben_newly_ineligible.main(
          p_person_id         => p_person_id,
          p_pgm_id            => p_pgm_id,
          p_pl_id             => p_pl_id,
          p_oipl_id           => p_oipl_id,
          p_business_group_id => p_business_group_id,
          p_ler_id            => p_ler_id,
          p_effective_date    => p_effective_date);
        p_electable_flag :=  'N';
	if g_debug then
        hr_utility.set_location('Dn BNI_MN: ' || l_proc, 10);
	end if;
        RETURN;
        --
      ELSIF l_pl_enrt_mthd_cd = 'A' THEN
        --
        -- Leave as choice and use elctbl_flag
        --
        NULL;
        --
      ELSIF l_crnt_enrt_cvg_strt_dt IS NOT NULL THEN
        --
        -- if currently enrolled then create the choice
        -- and don't exit
        --
        l_rec_elctbl_flag :=  'N';
        --
      ELSIF    l_plan_rec.invk_flx_cr_pl_flag = 'Y'
            OR l_plan_rec.imptd_incm_calc_cd IN ('PRTT', 'DPNT', 'SPS') THEN
        l_rec_elctbl_flag :=  'N';
        --
      ELSE
        --
        p_electable_flag :=  'N';
        RETURN;
        --
      END IF;                                          -- determine_enrolment='Y'
      --
    end if;  -- Override Enrollment endif
    --
    -- Set p_electable flag back to 'N' if we are dealing with an automatic
    -- enrollment
    --
    IF l_pl_enrt_mthd_cd = 'A' THEN
      --
      l_auto_enrt_flag :=  'Y';
    --
    END IF;
    --
    -- Check level jumping restrictions
    --
    if g_debug then
    hr_utility.set_location(l_proc || ' Lev Jump OIPL ', 12);
    end if;
    IF p_oipl_id IS NOT NULL AND p_run_mode <> 'D' THEN
      --
      if g_debug then
      hr_utility.set_location('get ler bnft_rstrns ', 12);
      hr_utility.set_location(l_proc || ' Op c_ler_bnft_rstrn ', 12);
      end if;
      OPEN c_ler_bnft_rstrn;
      FETCH c_ler_bnft_rstrn INTO l_tmp_level,
                                  l_restriction_pgm_id,
                                  l_oipl_ordr_num,
                                  l_boo_rstrctn_cd,
                                  l_cvg_incr_r_decr_only_cd,
                                  l_mx_cvg_mlt_incr_num,
                                  l_mx_cvg_mlt_incr_wcf_num;
      --
      IF c_ler_bnft_rstrn%NOTFOUND THEN
        --
        CLOSE c_ler_bnft_rstrn;
        -- Romoved the commented code
        IF     ben_cobj_cache.g_plip_currow.plip_id = l_plip_id
           AND ben_cobj_cache.g_plip_currow.bnft_or_option_rstrctn_cd = 'OPT'
           AND l_lf_evt_ocrd_dt >= ben_cobj_cache.g_plip_currow.effective_start_date
           AND l_lf_evt_ocrd_dt <= ben_cobj_cache.g_plip_currow.effective_end_date
           AND ben_cobj_cache.g_oipl_currow.oipl_id = p_oipl_id
           AND ben_cobj_cache.g_oipl_currow.pl_id = ben_cobj_cache.g_plip_currow.pl_id
           AND l_lf_evt_ocrd_dt >= ben_cobj_cache.g_oipl_currow.effective_start_date
           AND l_lf_evt_ocrd_dt <= ben_cobj_cache.g_oipl_currow.effective_end_date THEN
          --
          l_tmp_level                := 2;
          l_restriction_pgm_id       := ben_cobj_cache.g_plip_currow.pgm_id;
          l_oipl_ordr_num            := ben_cobj_cache.g_oipl_currow.ordr_num;
          l_boo_rstrctn_cd           :=
                                       ben_cobj_cache.g_plip_currow.bnft_or_option_rstrctn_cd;
          l_cvg_incr_r_decr_only_cd  := ben_cobj_cache.g_plip_currow.cvg_incr_r_decr_only_cd;
          l_mx_cvg_mlt_incr_num      := ben_cobj_cache.g_plip_currow.mx_cvg_mlt_incr_num;
          l_mx_cvg_mlt_incr_wcf_num  := ben_cobj_cache.g_plip_currow.mx_cvg_mlt_incr_wcf_num;
        --
        ELSIF     ben_cobj_cache.g_pl_currow.pl_id = l_pl_id
              AND ben_cobj_cache.g_pl_currow.bnft_or_option_rstrctn_cd = 'OPT'
              AND l_lf_evt_ocrd_dt >= ben_cobj_cache.g_pl_currow.effective_start_date
              AND l_lf_evt_ocrd_dt <= ben_cobj_cache.g_pl_currow.effective_end_date
              AND ben_cobj_cache.g_oipl_currow.oipl_id = p_oipl_id
              AND ben_cobj_cache.g_oipl_currow.pl_id = ben_cobj_cache.g_pl_currow.pl_id
              AND l_lf_evt_ocrd_dt >= ben_cobj_cache.g_oipl_currow.effective_start_date
              AND l_lf_evt_ocrd_dt <= ben_cobj_cache.g_oipl_currow.effective_end_date THEN
          --
          l_tmp_level                := 1;
          l_restriction_pgm_id       := NULL;
          l_oipl_ordr_num            := ben_cobj_cache.g_oipl_currow.ordr_num;
          l_boo_rstrctn_cd           := ben_cobj_cache.g_pl_currow.bnft_or_option_rstrctn_cd;
          l_cvg_incr_r_decr_only_cd  := ben_cobj_cache.g_pl_currow.cvg_incr_r_decr_only_cd;
          l_mx_cvg_mlt_incr_num      := ben_cobj_cache.g_pl_currow.mx_cvg_mlt_incr_num;
          l_mx_cvg_mlt_incr_wcf_num  := ben_cobj_cache.g_pl_currow.mx_cvg_mlt_incr_wcf_num;
        --
        END IF;
      ELSE
        --
        CLOSE c_ler_bnft_rstrn;
      --
      END IF;
      if g_debug then
      hr_utility.set_location(l_proc || ' c_ler_bnft_rstrn ', 12);
      end if;
/*  uncomment these for debuggin only
  hr_utility.set_location('l_plip_id -> '||l_plip_id,11);
  hr_utility.set_location('p_pgm_id -> '||p_pgm_id,11);
  hr_utility.set_location('l_restriction_pgm_id -> '||l_restriction_pgm_id,11);
  hr_utility.set_location('l_tmp_level -> '||l_tmp_level,11);
  hr_utility.set_location('l_oipl_ordr_num -> '||l_oipl_ordr_num,12);
  hr_utility.set_location('l_boo_rstrctn_cd -> '||l_boo_rstrctn_cd,12);
  hr_utility.set_location('l_cvg_incr_r_decr_only_cd -> '||l_cvg_incr_r_decr_only_cd,12);
  hr_utility.set_location('l_mx_cvg_mlt_incr_num -> '||l_mx_cvg_mlt_incr_num,12);
  hr_utility.set_location('l_mx_cvg_mlt_incr_wcf_num -> '||l_mx_cvg_mlt_incr_wcf_num,12);
*/
      IF l_boo_rstrctn_cd IS NOT NULL THEN
        --
        OPEN c_oipl_enrt_in_pl;
        FETCH c_oipl_enrt_in_pl INTO l_enrd_ordr_num;
        --
        --  For COBRA, also check elig_cvrd_dpnt as the person
        --  may be a dependent.
        --
        IF c_oipl_enrt_in_pl%NOTFOUND THEN
          IF p_pgm_id IS NOT NULL THEN
            IF l_pgm_rec.pgm_typ_cd LIKE 'COBRA%' THEN
              OPEN c_oipl_cvg_in_pl;
              FETCH c_oipl_cvg_in_pl INTO l_enrd_ordr_num;
              CLOSE c_oipl_cvg_in_pl;
            END IF;
          END IF;
        END IF;
        CLOSE c_oipl_enrt_in_pl;
        --
        -- convert ordr_num to logical orD number
        l_cnt := 1;
        if l_oipl_ordr_num is not null then
          open c_opt_level;
          loop
            fetch c_opt_level into l_opt_level;
            if c_opt_level%Notfound then
               exit;
            end if;
         --   hr_utility.set_location('opt level'||l_opt_level,111);

            if l_opt_level = l_oipl_ordr_num then
               l_oipl_seq_num := l_cnt;
               l_found  := TRUE;
               exit;
            end if;
            l_cnt := l_cnt + 1;
          end loop;
          close c_opt_level;
          if not l_found then
             fnd_message.set_name('BEN','BEN_92699_SEQ_NUM_NOT_EXST');
             fnd_message.raise_error;
          end if;
        end if;
        --
        l_cnt := 1;
        l_found := FALSE;
        if l_enrd_ordr_num is not null then
          open c_opt_level;
          loop
            fetch c_opt_level into l_opt_level;
            if c_opt_level%Notfound then
               exit;
            end if;
         if g_debug then
            hr_utility.set_location('Enrd Ord'||l_enrd_ordr_num,113);
         end if;
            if l_opt_level = l_enrd_ordr_num then
               l_enrd_seq_num := l_cnt;
               l_found  := TRUE;
               exit;
            end if;
            l_cnt := l_cnt + 1;
          end loop;
          close c_opt_level;
          if not l_found then
             fnd_message.set_name('BEN','BEN_92699_SEQ_NUM_NOT_EXST');
             fnd_message.raise_error;
          end if;
        end if;
       --     End of Logical Ordr Num

        -- Check for conditions where no choice should be created (N above)
        --
        IF l_cvg_incr_r_decr_only_cd = 'MNAVLO' THEN
          --
          --  Minimum available.
          --
          OPEN c_get_min_max_ordr_num;
          FETCH c_get_min_max_ordr_num INTO l_mn_ordr_num, l_mx_ordr_num;
          CLOSE c_get_min_max_ordr_num;
          --
          IF l_oipl_ordr_num <> l_mn_ordr_num THEN
	  if g_debug then
            hr_utility.set_location(
              'Level jumping to this object not allowed',
              12);
          end if;
            p_electable_flag :=  'N';
            RETURN;
          END IF;
	  if g_debug then
          hr_utility.set_location('min avail', 12);
	  end if;
        --
        ELSIF l_cvg_incr_r_decr_only_cd = 'MXAVLO' THEN
          --
          --  Maximum available.
          --
          OPEN c_get_min_max_ordr_num;
          FETCH c_get_min_max_ordr_num INTO l_mn_ordr_num, l_mx_ordr_num;
          CLOSE c_get_min_max_ordr_num;
          --
          IF l_oipl_ordr_num <> l_mx_ordr_num THEN
	  if g_debug then
            hr_utility.set_location(
              'Level jumping to this object not allowed',
              12);
          end if;
            p_electable_flag :=  'N';
            RETURN;
          END IF;
	  if g_debug then
          hr_utility.set_location('max avail', 12);
	  end if;
        --
        ELSIF l_enrd_ordr_num IS NULL THEN
          --
          -- When person is not previously enrolled.
          --
	  if g_debug then
          hr_utility.set_location('person not prev enrolled', 12);
	  end if;
          p_electable_flag :=  'Y';
        --
        ELSIF (
                   (
                         l_cvg_incr_r_decr_only_cd = 'INCRO'
                     AND l_oipl_ordr_num <= l_enrd_ordr_num)
                OR (
                         l_cvg_incr_r_decr_only_cd = 'EQINCR'
                     AND l_oipl_ordr_num < l_enrd_ordr_num)
                OR (
                         l_cvg_incr_r_decr_only_cd = 'DECRO'
                     AND l_oipl_ordr_num >= l_enrd_ordr_num)
                OR (
                         l_cvg_incr_r_decr_only_cd = 'EQDECR'
                     AND l_oipl_ordr_num > l_enrd_ordr_num)) THEN
          --
	  if g_debug then
          hr_utility.set_location('incr or decr check failed, no choice', 12);
	  end if;
          --
          p_electable_flag :=  'N';
          --
          RETURN;
        --
        ELSIF (
                   l_cvg_incr_r_decr_only_cd IS NULL
                OR l_cvg_incr_r_decr_only_cd = 'NR'
                OR (
                         l_cvg_incr_r_decr_only_cd = 'INCRO'
                     AND l_oipl_ordr_num > l_enrd_ordr_num)
                OR (
                         l_cvg_incr_r_decr_only_cd = 'EQINCR'
                     AND l_oipl_ordr_num >= l_enrd_ordr_num)
                OR (
                         l_cvg_incr_r_decr_only_cd = 'DECRO'
                     AND l_oipl_ordr_num < l_enrd_ordr_num)
                OR (
                         l_cvg_incr_r_decr_only_cd = 'EQDECR'
                     AND l_oipl_ordr_num <= l_enrd_ordr_num)
                OR l_cvg_incr_r_decr_only_cd IN ('INCRCTF', 'DECRCTF', 'DECINCCTF')) THEN
         --
/*   uncomment these for debugging only
         hr_utility.set_location('Level jumping passed incr or decr check',12);
         hr_utility.set_location('now check max incr and max wctfn incr',12);
         hr_utility.set_location('l_mx_cvg_mlt_incr_wcf_num -> '||l_mx_cvg_mlt_incr_wcf_num,12);
         hr_utility.set_location('l_mx_cvg_mlt_incr_num -> '||l_mx_cvg_mlt_incr_num,12);
         hr_utility.set_location('current enrolled order num -> '||l_enrd_ordr_num,12);
*/
-- logical ordr number is used rather database ordr num
          --
          IF     l_oipl_seq_num >
                                  (
                                    l_mx_cvg_mlt_incr_wcf_num +
                                      l_enrd_seq_num)
             AND l_mx_cvg_mlt_incr_wcf_num IS NOT NULL THEN
            --
	    if g_debug then
            hr_utility.set_location('can not jump here 1', 12);
	    end if;
            p_electable_flag :=  'N';
            RETURN;
          --
          ELSIF     (
                      l_oipl_seq_num >
                                      (
                                        l_mx_cvg_mlt_incr_num +
                                          l_enrd_seq_num))
                AND l_mx_cvg_mlt_incr_num IS NOT NULL
                AND l_mx_cvg_mlt_incr_wcf_num IS NULL THEN
            --
	    if g_debug then
            hr_utility.set_location('can not jump here 2', 12);
	    end if;
            p_electable_flag :=  'N';
            RETURN;
          --
          ELSIF     (
                      l_oipl_seq_num >
                              (
                                NVL(l_mx_cvg_mlt_incr_num, 0) +
                                  l_enrd_seq_num))
                AND (
                      l_oipl_seq_num <=
                                  (
                                    l_mx_cvg_mlt_incr_wcf_num +
                                      l_enrd_seq_num))
                AND l_mx_cvg_mlt_incr_wcf_num IS NOT NULL THEN
            --
	    if g_debug then
            hr_utility.set_location('set ctfn rqd flag to true ', 12);
	    end if;
            p_electable_flag :=  'Y';
            l_ctfn_rqd_flag :=   'Y';
          ELSE
            --
            p_electable_flag :=  'Y';
            --
          END IF;
        --
          -- 5736589: Increase/Decrease Requires certification for Option Restrictions
	  if g_debug then
            hr_utility.set_location('Opt.Rest. Incr/Dec.Req.Cert.  ' || l_cvg_incr_r_decr_only_cd, 12);
          end if;
            IF (l_cvg_incr_r_decr_only_cd  = 'INCRCTF'
                and l_oipl_ordr_num > l_enrd_ordr_num) THEN
              --
              l_ctfn_rqd_flag :=  'Y';
          --
            ELSIF (l_cvg_incr_r_decr_only_cd  = 'DECRCTF'
                and l_oipl_ordr_num < l_enrd_ordr_num) THEN
              --
              l_ctfn_rqd_flag :=  'Y';
              --
            ELSIF (l_cvg_incr_r_decr_only_cd  = 'DECINCCTF'
                and l_oipl_ordr_num <> l_enrd_ordr_num) THEN
              --
              l_ctfn_rqd_flag :=  'Y';
          END IF;
        --
	if g_debug then
            hr_utility.set_location('Opt.Rest. Cert Flag  ' || l_ctfn_rqd_flag, 12);
        end if;
          --
        ELSE
          --
        if g_debug then
          hr_utility.set_location('Level jumping success', 0);
        end if;
          p_electable_flag :=  'Y';
        --
        END IF;
      --
      END IF;
    --
    END IF;
    --

    -- Determine the enrt_cvg_strt_dt_cd and enrt_cvg_end_dt_cd
    -- (rules as well), and dates
    -- use the new determine date function
    -- Get it from the lee_rsn_f for the plan, if not set get it from the plan,
    -- if not set get it from the lee_rsn_f at the pgm level,
    -- if not set get it from the pgm, if not set report and error.
    -- (end date is optional is used at the same level as the start)
    --
    if g_debug then
    hr_utility.set_location('J', 20);
    hr_utility.set_location(l_proc || ' RMODE=L ', 12);
    end if;
    --
    -- ABSENCES : absence processing is similar to life event processing
    -- GRADE/STEP : GS progression process is similar to life event
    -- iREC : Added mode 'I'
    --
-- IF p_run_mode <> 'D' then
  --
    IF (    p_run_mode in  ('L', 'M', 'G', 'I')
        AND l_unrestricted_enrt_flag = 'N') THEN
      --
      if g_debug then
      hr_utility.set_location('K', 20);
      hr_utility.set_location(l_proc || ' RMODE=L UEF=N ', 12);
      end if;
      OPEN c_lee_period_for_plan;
      --
      FETCH c_lee_period_for_plan INTO l_ple_dys_aftr_end_to_dflt_num,
                                       l_ple_enrt_perd_end_dt_rl,
                                       l_ple_enrt_perd_strt_dt_rl,
                                       l_ple_enrt_perd_end_dt_cd,
                                       l_ple_enrt_perd_strt_dt_cd,
--                                     l_ple_enrt_cvg_strt_dt_cd,
--                                     l_ple_enrt_cvg_strt_dt_rl,
                                       l_ple_addit_procg_dys_num,
                                       l_ple_enrt_typ_cycl_cd,
                                       l_ple_lee_rsn_id,
                                       l_rec_cls_enrt_dt_to_use_cd,
                                       l_rec_lee_rsn_esd,
                                       l_rec_lee_rsn_eed,
                                       l_ple_enrt_perd_strt_days,
                                       l_ple_enrt_perd_end_days,
                                       /* bug 2746865*/
                                       l_enrt_perd_det_ovrlp_bckdt_cd;
      --
      IF c_lee_period_for_plan%FOUND THEN
        --
        l_perd_for_plan_found :=  'Y';
      --
      ELSE
        --
        l_perd_for_plan_found :=  'N';
      --
      END IF;                                                          -- found
      --
      CLOSE c_lee_period_for_plan;
      if g_debug then
      hr_utility.set_location(l_proc || ' Cl c_lpfpln ', 12);
      --
      hr_utility.set_location('L', 20);
      end if;
      -- Get pgm level enrt period if it is needed
      -- Program must exist and
      -- Needed when can't find record at plan level or
      -- Need it to determine the enrt_perd_strt_dt_cd
      --
      IF (
               p_pgm_id IS NOT NULL
           AND (
                    l_perd_for_plan_found = 'N'
                 OR (l_ple_enrt_perd_strt_dt_cd IS NULL))) THEN
        --
        OPEN c_lee_period_for_program;
        --
        FETCH c_lee_period_for_program INTO l_pgme_dys_aftr_end_to_dflt,
                                            l_pgme_enrt_perd_end_dt_rl,
                                            l_pgme_enrt_perd_strt_dt_rl,
                                            l_pgme_enrt_perd_end_dt_cd,
                                            l_pgme_enrt_perd_strt_dt_cd,
--                                            l_pgme_enrt_cvg_strt_dt_cd,
--                                            l_pgme_enrt_cvg_strt_dt_rl,
                                            l_pgme_addit_procg_dys_num,
                                            l_pgme_enrt_typ_cycl_cd,
                                            l_pgme_lee_rsn_id,
                                            l_rec_cls_enrt_dt_to_use_cd,
                                            l_rec_lee_rsn_esd,
                                            l_rec_lee_rsn_eed,
                                            l_pgme_enrt_perd_strt_days,
                                            l_pgme_enrt_perd_end_days,
                                            /* bug 2746865 */
                                            l_enrt_perd_det_ovrlp_bckdt_cd;
        --
        IF c_lee_period_for_program%FOUND THEN
          --
          l_perd_for_program_found :=  'Y';
        --
        ELSE
          --
          l_perd_for_program_found :=  'N';
        --
        END IF;                                                        -- Found
        --
        CLOSE c_lee_period_for_program;
	if g_debug then
        hr_utility.set_location(l_proc || ' Cl c_lpfprg ', 12);
	end if;
      --
      -- If there is a plan level enrt_perd_for_pl use it's value (if not null)
      --
--      open c_enrt_perd_for_pl_info;
--      fetch c_enrt_perd_for_pl_info into
--        l_overide_enrt_cvg_strt_dt_cd,
--        l_overide_enrt_cvg_strt_dt_rl;
--      close c_enrt_perd_for_pl_info;
--      if l_overide_enrt_cvg_strt_dt_cd is not null then
--        l_pgme_enrt_cvg_strt_dt_cd:=l_overide_enrt_cvg_strt_dt_cd;
--        l_pgme_enrt_cvg_strt_dt_rl:=l_overide_enrt_cvg_strt_dt_rl;
--      end if;
      --
      END IF;                -- Need to get program level enrolment period info
    --
    ELSIF (   ( p_run_mode = 'C'or p_run_mode = 'W')
           AND l_unrestricted_enrt_flag = 'N') THEN
      --
      if g_debug then
      hr_utility.set_location(l_proc || ' RMODE=C UEF=N ', 12);
      end if;
      OPEN c_sched_enrol_period_for_plan;
      --
      FETCH c_sched_enrol_period_for_plan INTO l_ple_enrt_perd_id,
                                               l_ple_enrt_perd_strt_dt,
                                               l_ple_enrt_perd_end_dt,
                                               l_ple_procg_end_dt,
                                               l_ple_dflt_enrt_dt,
--                                             l_ple_enrt_cvg_strt_dt_cd,
--                                             l_ple_enrt_cvg_strt_dt_rl,
                                               l_ple_enrt_typ_cycl_cd,
                                               l_rec_cls_enrt_dt_to_use_cd,
                                               l_ple_hrchy_to_use_cd,
                                               l_ple_pos_structure_version_id,
                                               /* bug 2746865 */
                                               l_enrt_perd_det_ovrlp_bckdt_cd;

      --
      IF c_sched_enrol_period_for_plan%FOUND THEN
        --
        l_perd_for_plan_found :=  'Y';
      --
      ELSE
        --
        l_perd_for_plan_found :=  'N';
      --
      END IF;                                                          -- found
      --
      CLOSE c_sched_enrol_period_for_plan;
      --
      -- Get pgm level enrt period if it is needed
      -- Program must exist and
      -- Needed when can't find record at plan level or
      -- Need it to determine the enrt_perd_strt_dt_cd
      --
      IF (
               p_pgm_id IS NOT NULL
           AND (
                    l_perd_for_plan_found = 'N'
                 OR (l_ple_enrt_perd_strt_dt IS NULL))) THEN
        --
        OPEN c_sched_enrol_period_for_pgm;
        --
        FETCH c_sched_enrol_period_for_pgm INTO l_pgme_enrt_perd_id,
                                                l_pgme_enrt_perd_strt_dt,
                                                l_pgme_enrt_perd_end_dt,
                                                l_pgme_procg_end_dt,
                                                l_pgme_dflt_enrt_dt,
--                                                l_pgme_enrt_cvg_strt_dt_cd,
--                                                l_pgme_enrt_cvg_strt_dt_rl,
                                                l_pgme_enrt_typ_cycl_cd,
                                                l_rec_cls_enrt_dt_to_use_cd,
                                                l_ple_hrchy_to_use_cd,
                                                l_ple_pos_structure_version_id,
                                                /* bug 2746865 */
                                                l_enrt_perd_det_ovrlp_bckdt_cd;
        --
        IF c_sched_enrol_period_for_pgm%FOUND THEN
          --
          l_perd_for_program_found :=  'Y';
        --
        ELSE
          --
          l_perd_for_program_found :=  'N';
        --
        END IF;                                                        -- Found
        --
        CLOSE c_sched_enrol_period_for_pgm;
      --
      -- If there is a plan level enrt_perd_for_pl use it's value (if not null)
      --
      --
      END IF;                -- Need to get program level enrolment period info
    -- Bug 2200139 Override Enrollments
    ELSIF l_unrestricted_enrt_flag = 'Y' OR p_run_mode = 'V'  THEN
      l_rec_enrt_perd_strt_dt :=      l_lf_evt_ocrd_dt_fetch;
      l_rec_enrt_perd_end_dt :=       hr_api.g_eot;
      l_rec_procg_end_dt :=           hr_api.g_eot;
      l_rec_dflt_asnmt_dt :=          l_lf_evt_ocrd_dt_fetch;
      l_rec_enrt_typ_cycl_cd :=       'U';
      l_rec_cls_enrt_dt_to_use_cd :=  'ELCNSMADE';
    END IF;                                                   -- run_mode cases
    --
    -- One of the levels must have been found
    --
    if g_debug then
    hr_utility.set_location('M', 20);
    hr_utility.set_location(
      'l_perd_for_plan_found=' || l_perd_for_plan_found,
      20);
    hr_utility.set_location(
      'l_perd_for_program_found=' || l_perd_for_program_found,
      20);
    hr_utility.set_location(
      'l_unrestricted_enrt_flag=' || l_unrestricted_enrt_flag,
      20);
    hr_utility.set_location('l_pfpf=N ' || l_proc, 10);
    end if;
    --Bug 2200139 Override Enrollment
    IF (
             l_perd_for_plan_found = 'N'
         AND l_perd_for_program_found = 'N'
         AND l_unrestricted_enrt_flag = 'N'
         AND nvl(p_run_mode,'X') not in ('V','D') ) THEN -- For 'D' Mode we dont set code for periods
      --
      -- ABSENCES : absence processing is similar to life event processing.
      -- iRec : Added mode 'I'
      IF p_run_mode in ('L', 'M','G', 'I') THEN
      if g_debug then
        hr_utility.set_location(' Leaving:' || l_proc, 981);
      end if;
        p_electable_flag :=  'N';
        RETURN;
      ELSE
      if g_debug then
        hr_utility.set_location('Did not find enrt_perd, raise error', 982);
      end if;
        fnd_message.set_name('BEN', 'BEN_91335_PLAN_YR_ENRT_PERD');
        fnd_message.set_token('PROC', l_proc);
        fnd_message.set_token('PGM_ID', TO_CHAR(p_pgm_id));
        fnd_message.set_token('PL_ID', TO_CHAR(l_pl_id));
        fnd_message.set_token('EFFECTIVE_DATE', TO_CHAR(p_effective_date));
        fnd_message.set_token('LF_EVT_OCRD_DT', TO_CHAR(p_lf_evt_ocrd_dt));
        RAISE ben_manage_life_events.g_record_error;
      END IF;
    --
    END IF;                                         -- no enrt_perd info found.
    --
    if g_debug then
    hr_utility.set_location('P', 20);
    --
    -- Determine the mndtry_flag
    -- If the comp object is an OIPL
    --
    hr_utility.set_location('Ch oipl_id NN ' || l_proc, 10);
    end if;
    IF (p_oipl_id IS NOT NULL AND p_run_mode <> 'D') THEN
      --
      -- If the mndtry_rl is not null, execute it to determine
      -- if the oipl is mandatory.
      --
      IF l_mndtry_rl IS NOT NULL THEN
        --
        l_mndtry_flag :=
         execute_enrt_rule(
           p_opt_id            => l_opt_id,
           p_pl_id             => l_pl_id,
           p_pgm_id            => p_pgm_id,
           p_rule_id           => l_mndtry_rl,
           p_ler_id            => p_ler_id,
           p_pl_typ_id         => l_pl_typ_id,
           p_business_group_id => p_business_group_id,
           p_effective_date    => p_effective_date,
           p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
           p_assignment_id     => l_rec_assignment_id,
           p_organization_id   => l_rec_organization_id,
           p_jurisdiction_code => l_jurisdiction_code,
	   p_person_id         => p_person_id);          -- Bug 5331889
        --
        l_rec_mndtry_flag :=  l_mndtry_flag;
        --
      --
      -- If the mndtry_rl is null, use the mndtry_flag to
      -- determine if the oipl is mandatory.
      --
      ELSE
        --
        l_rec_mndtry_flag :=  l_mndtry_flag;
      --
      END IF;
    --
    END IF;
    --
    -- Determine the elctbl_flag
    -- If the comp object is an OIPL
    --
    if g_debug then
    hr_utility.set_location('R', 20);
    hr_utility.set_location('Ch oipl_id1 NN ' || l_proc, 10);
    end if;
    --
    -- CWBITEM : do not check for CWB plans, goahead and create the epe.
    --
    IF (p_oipl_id IS NULL and p_run_mode not in ('W','D')) THEN
      --
      -- Only check to see if we have to create electable choice for plan if
      -- the enrt pl opt flag is set
      --
      IF l_plan_rec.enrt_pl_opt_flag = 'N' THEN
        --
        OPEN c_any_oipl_for_plan;
        --
        FETCH c_any_oipl_for_plan INTO l_exists_flag;
	if g_debug then
        hr_utility.set_location('Fet c_aofp ' || l_proc, 10);
	end if;
        --
        IF c_any_oipl_for_plan%FOUND THEN
          --
          p_electable_flag :=  'N';
          RETURN;
        --
        END IF;
        --
        CLOSE c_any_oipl_for_plan;
      --
      END IF;
    --
    END IF;
    --
    if g_debug then
    hr_utility.set_location('S', 20);
    -- Determine the enrt_typ_cycl_cd
    -- Find the lee_rsn_f and related popl_enrt_typ_cycl_f for the plan.
    --
    hr_utility.set_location('l_PFPF=Y ' || l_proc, 10);
    end if;
  IF p_run_mode <> 'D' THEN
    IF (    l_perd_for_plan_found = 'Y'
        AND l_ple_enrt_typ_cycl_cd IS NOT NULL) THEN
      -- If found use it's enrt_typ_cycl_cd
      l_rec_enrt_typ_cycl_cd :=  l_ple_enrt_typ_cycl_cd;
    -- If not found then find the lee_rsn_f and related
    -- popl_enrt_typ_cycl_f for the program.
    --
    ELSIF (
                l_perd_for_program_found = 'Y'
            AND l_pgme_enrt_typ_cycl_cd IS NOT NULL) THEN
      -- If found use it's enrt_typ_cycl_cd
      l_rec_enrt_typ_cycl_cd :=  l_pgme_enrt_typ_cycl_cd;
    -- Bug 2200139 Override Enrollment
    ELSIF l_unrestricted_enrt_flag = 'N' and nvl(p_run_mode,'X') <> 'V' THEN
      -- If nothing found report an error.
      fnd_message.set_name('BEN', 'BEN_91464_ENRT_TYP_CYCL_CD');
      fnd_message.set_token('PROC', l_proc);
      fnd_message.set_token('PGM_ID', TO_CHAR(p_pgm_id));
      fnd_message.set_token('PGM_ENRT_TYP_CYCL_CD', l_pgme_enrt_typ_cycl_cd);
      fnd_message.set_token('PL_ID', TO_CHAR(l_pl_id));
      fnd_message.set_token('PL_ENRT_TYP_CYCL_CD', l_ple_enrt_typ_cycl_cd);
      RAISE ben_manage_life_events.g_record_error;
    --
    END IF;
    --
  END IF; -- 'D' Mode
    -- Determine the crntly_enrd_flag
    -- Set it to the currently_enrolled parameter.
    --
    IF l_crnt_enrt_cvg_strt_dt IS NOT NULL THEN
      --
      l_rec_crntly_enrd_flag :=  'Y';
    --
    ELSE
      --
      l_rec_crntly_enrd_flag :=  'N';
    --
    END IF;
    --
    -- get the dflt_enrt_cd/rule
    --
    if g_debug then
    hr_utility.set_location('DrtDEC ' || l_proc, 10);
    -- start bug 5644451
        hr_utility.set_location('Determine with new call 5644451 ' || l_proc, 10);
    end if;
	IF (p_oipl_id IS NOT NULL)
	THEN
	-- get oipl information
	ben_comp_object.get_object (p_oipl_id                     => p_oipl_id,
				  p_rec                         => l_oipl_record);
	l_oipl_auto_enrt_flag := l_oipl_rec.auto_enrt_flag;
	END IF;
	-- Get ptip cache row if needed
	IF l_ptip_id IS NOT NULL
	THEN
	ben_comp_object.get_object (p_ptip_id                     => l_ptip_id,
				  p_rec                         => l_ptip_record);
	END IF;
	-- Get plip cache row if needed
	IF l_plip_id IS NOT NULL
	THEN
	ben_comp_object.get_object (p_plip_id                     => l_plip_id,
				  p_rec                         => l_plip_record);
	END IF;


    /*
    determine_dflt_enrt_cd
      (p_oipl_id           => p_oipl_id
      ,p_plip_id           => l_plip_id
      ,p_pl_id             => l_pl_id
      ,p_ptip_id           => l_ptip_id
      ,p_pgm_id            => p_pgm_id
      ,p_ler_id            => p_ler_id
      ,p_dflt_enrt_cd      => l_use_dflt_enrt_cd
      ,p_dflt_enrt_rl      => l_use_dflt_enrt_rl
      ,p_business_group_id => p_business_group_id
      ,p_effective_date    => p_effective_date
      );
      */
    IF p_run_mode <> 'D' THEN
     --
      determine_dflt_enrt_cd
        (p_oipl_id           => p_oipl_id
        ,p_oipl_rec          => l_oipl_record
        ,p_plip_id           => l_plip_id
        ,p_plip_rec          => l_plip_record
        ,p_pl_id             => l_pl_id
        ,p_pl_rec            => l_plan_rec
        ,p_ptip_id           => l_ptip_id
        ,p_ptip_rec          => l_ptip_record
        ,p_pgm_id            => p_pgm_id
        ,p_pgm_rec           => l_pgm_rec
        ,p_ler_id            => p_ler_id
        ,p_dflt_enrt_cd      => l_use_dflt_enrt_cd
        ,p_dflt_enrt_rl      => l_use_dflt_enrt_rl
        ,p_business_group_id => p_business_group_id
        ,p_effective_date    => l_lf_evt_ocrd_dt
        ,p_level             => l_dflt_level
        ,p_ler_dflt_flag     => l_ler_dflt_flag
      );

     -- end bug 5644451
   if g_debug then
    hr_utility.set_location('Dn DrtDEC ' || l_proc, 10);
   end if;
    --
    -- Set the values for the dflt_flag
    --
    l_use_dflt_flag :=            NULL;
    IF l_ler_chg_found_flag = 'Y' THEN
      IF    l_ler_chg_oipl_found_flag = 'Y'
         OR (    l_ler_chg_oipl_found_flag = 'N'
             AND p_oipl_id IS NULL) THEN
        --
        -- Use flag only if at appropriate level
        --
        l_use_dflt_flag :=  l_ler_dflt_flag;
      END IF;
    END IF;
  if g_debug then
    hr_utility.set_location('U', 20);
  end if;
    --
    -- oipl level default code/flag
    --
    IF p_oipl_id IS NOT NULL THEN
      IF l_use_dflt_flag IS NULL THEN
        --
        -- use oipl level flag
        --
        l_use_dflt_flag :=  l_oipl_dflt_flag;
      END IF;
    END IF;
  if g_debug then
    hr_utility.set_location('U3', 30);
  end if;
    --
    -- plip level default code/flag
    --
    IF l_plip_id IS NOT NULL THEN
      IF l_use_dflt_flag IS NULL THEN
        l_use_dflt_flag :=  l_plip_dflt_flag;
      END IF;
    END IF;
    --
    if g_debug then
    hr_utility.set_location('V', 20);
    end if;
    --
    -- If no default flag is set then make it not a default.
    --
    IF l_use_dflt_flag IS NULL THEN
      --
      l_use_dflt_flag :=  'N';
    --
    END IF;
    if g_debug then
    hr_utility.set_location('  l_use_dflt_flag  ' ||  l_use_dflt_flag, 10);
    end if;
     determine_dflt_flag(
       l_use_dflt_flag,
       l_use_dflt_enrt_cd,
       l_crnt_enrt_cvg_strt_dt,
       l_previous_eligibility,
       l_use_dflt_enrt_rl,
       p_oipl_id,
       l_pl_id,
       p_pgm_id,
       p_effective_date,
       p_lf_evt_ocrd_dt,
       p_ler_id,
       l_opt_id,
       l_pl_typ_id,
       l_ptip_id,
       p_person_id,
       p_business_group_id,
       l_rec_assignment_id,
       l_dflt_flag,
       l_reinstt_flag,
       -- bug 5644451
       l_dflt_level,
       p_run_mode           -- iRec
       );
     if l_reinstt_cd is null then
        l_reinstt_cd := l_reinstt_flag;
     end if;
   if g_debug then
    hr_utility.set_location(' Dn det_dflt_flag ' || l_proc, 10);
    hr_utility.set_location(' l_dflt_flag   ' ||  l_dflt_flag , 10);
   end if;
    --
    IF (l_dflt_flag = 'DEFER') THEN
      --
      l_dflt_flag :=  l_use_dflt_flag;
    --
    END IF;
    --Bug 2200139 Override Enrollment changes
    IF p_run_mode = 'V' then
      --
      l_dflt_flag := 'N' ;
      --
    end if;
    --
 END IF;
    -- Determine the enrt_perd_strt_dt and enrt_perd_end_dt.
    -- Determine the dflt_asnmt_dt
    -- Determine the procg_end_dt.
    -- GRADE/STEP : Extend L mode to cater Grade step process.
    -- iRec : Added mode 'I'
    --
    IF (p_run_mode in ('L', 'G', 'I')  AND p_run_mode <> 'D'
        AND l_unrestricted_enrt_flag = 'N') THEN
      --
      -- Get it from the lee_rsn_f for the plan (or program if not set)
      -- enrt_perd_strt_dt_cd and enrt_perd_end_dt_cd (and rules)
      -- What domain is this?  Determine the date using the code/rule.
      -- If Life event mode, set dflt_asnmt_dt to the
      -- enrt_perd_end_dt + dys_aftr_end_to_dflt_num.
      --
   if g_debug then
      hr_utility.set_location(' RM L UEF N ' || l_proc, 10);
   end if;
      IF (
               l_perd_for_plan_found = 'Y'
           AND l_ple_enrt_perd_strt_dt_cd IS NOT NULL) THEN
        --
        ben_determine_date.main(
          p_date_cd           => l_ple_enrt_perd_strt_dt_cd,
          p_per_in_ler_id     => l_per_in_ler_id,
          p_person_id         => p_person_id,
          p_pgm_id            => p_pgm_id,
          p_pl_id             => l_pl_id,
          p_oipl_id           => p_oipl_id,
          p_business_group_id => p_business_group_id,
          p_formula_id        => l_ple_enrt_perd_strt_dt_rl,
          p_effective_date    => p_effective_date,
          p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
          p_returned_date     => l_rec_enrt_perd_strt_dt);

         -- GHR enhancment
         if  l_ple_enrt_perd_strt_dt_cd  in ( 'NUMDOE', 'NUMDON','NUMDOEN') then
             l_rec_enrt_perd_strt_dt := l_rec_enrt_perd_strt_dt + nvl(l_ple_enrt_perd_strt_days,0) ;
         end if ;
        --
        -- The following logic was added by jcarpent for bug 4988/1269016
        -- based on tech design of maagrawa (1-6, 2 is done above)
        -- NOTE: please see identical logic for other modes.  Code added
        -- inline since we don't want to add additional function calls
        -- for performance reasons.
        --
      if g_debug then
        hr_utility.set_location(' PLS BLK 1 ' || l_proc, 10);
      end if;
        BEGIN
	if g_debug then
          hr_utility.set_location(' entering ' || l_proc, 10);
        end if;
          -- jcarpent 1/4/2001 bug 1568555, removed +1 from line below
          -- 1 get latest processed date
          l_orig_epsd :=  l_rec_enrt_perd_strt_dt;
          --
          -- GRADE/STEP  : Following code is only applicable for L mode
          --
          if p_run_mode  = 'L' then
            -- 2746865
            -- call the enrt_perd_strt_dt procedure to compute the epsd and eped
            -- according to the enrt. period determination code
            -- removed inline code and made it a procedure
	    if g_debug then
            hr_utility.set_location(' calling new proc ' , 20);
	    end if;
            enrt_perd_strt_dt
            ( p_person_id => p_person_id
              , p_lf_evt_ocrd_dt => p_lf_evt_ocrd_dt
              , p_enrt_perd_det_ovrlp_bckdt_cd => l_enrt_perd_det_ovrlp_bckdt_cd
              , p_rec_enrt_perd_strt_dt => l_rec_enrt_perd_strt_dt
              , p_ler_id => p_ler_id
              , p_business_group_id => p_business_group_id
              , p_effective_date => p_effective_date
              );
          end if;
	  if g_debug then
          hr_utility.set_location(' l_rec_enrt_perd_strt_dt is '|| l_rec_enrt_perd_strt_dt , 876);
	  end if;
        END;                                           -- of special epsd logic
	if g_debug then
        hr_utility.set_location(' Dn PLS BLK 1 ' || l_proc, 10);
	end if;
        ben_determine_date.main(
          p_date_cd           => l_ple_enrt_perd_end_dt_cd,
          p_start_date        => l_orig_epsd,
          p_per_in_ler_id     => l_per_in_ler_id,
          p_person_id         => p_person_id,
          p_pgm_id            => p_pgm_id,
          p_pl_id             => l_pl_id,
          p_oipl_id           => p_oipl_id,
          p_business_group_id => p_business_group_id,
          p_formula_id        => l_ple_enrt_perd_end_dt_rl,
          p_effective_date    => p_effective_date,
          p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
          p_param1            => 'ENRT_PERD_START_DATE',
          p_param1_value      => fnd_date.date_to_canonical(l_rec_enrt_perd_strt_dt),
          p_returned_date     => l_rec_enrt_perd_end_dt);


         -- GHR enhancment
         if  l_ple_enrt_perd_end_dt_cd  in ( 'NUMDOE', 'NUMDON','NUMDOEN') then
             l_rec_enrt_perd_end_dt := l_rec_enrt_perd_end_dt + nvl(l_ple_enrt_perd_end_days,0) ;
         end if ;

        --
	if g_debug then
          hr_utility.set_location(' l_rec_enrt_perd_end_dt is '|| l_rec_enrt_perd_end_dt , 876);
        end if;
       --
       -- 2746865

       -- if cd is L_EPSD_PEPD or null, proceed as before
       IF ( nvl(l_enrt_perd_det_ovrlp_bckdt_cd,'L_EPSD_PEPD') = 'L_EPSD_PEPD') THEN
           hr_utility.set_location('L_EPSD_PEPD' , 765);
         l_rec_enrt_perd_end_dt :=
                l_rec_enrt_perd_end_dt + (l_rec_enrt_perd_strt_dt - l_orig_epsd);
       -- 2746865
       ELSE
         -- for other codes
         -- if end dt is less than the start dt, make the strt dt as the end dt
         IF l_rec_enrt_perd_end_dt < l_rec_enrt_perd_strt_dt THEN
	 if g_debug then
           hr_utility.set_location(' end dt < strt dt ', 876);
         end if;
         l_rec_enrt_perd_end_dt := l_rec_enrt_perd_strt_dt;
         END IF;
       END IF;
	--
        l_rec_dflt_asnmt_dt :=
              l_rec_enrt_perd_end_dt + NVL(l_ple_dys_aftr_end_to_dflt_num, 0);
        -- Set it to the enrt_perd_end_dt + addt_procg_dys_num.
        l_rec_procg_end_dt :=
                   l_rec_enrt_perd_end_dt + NVL(l_ple_addit_procg_dys_num, 0);
        --
        l_rec_lee_rsn_id :=        l_ple_lee_rsn_id;
        --
	if g_debug then
        hr_utility.set_location(' Dn RM L UEF N ' || l_proc, 10);
	end if;
      ELSIF (
                  l_perd_for_program_found = 'Y'
              AND l_pgme_enrt_perd_strt_dt_cd IS NOT NULL) THEN
        --
	if g_debug then
        hr_utility.set_location(' BDD_MN PFPF=Y ' || l_proc, 10);
	end if;
        ben_determine_date.main(
          p_date_cd           => l_pgme_enrt_perd_strt_dt_cd,
          p_per_in_ler_id     => l_per_in_ler_id,
          p_person_id         => p_person_id,
          p_pgm_id            => p_pgm_id,
          p_pl_id             => l_pl_id,
          p_oipl_id           => p_oipl_id,
          p_business_group_id => p_business_group_id,
          p_formula_id        => l_pgme_enrt_perd_strt_dt_rl,
          p_effective_date    => p_effective_date,
          p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
          p_returned_date     => l_rec_enrt_perd_strt_dt);


        -- GHR enhancment
        if  l_pgme_enrt_perd_strt_dt_cd  in ( 'NUMDOE', 'NUMDON','NUMDOEN') then
            l_rec_enrt_perd_strt_dt := l_rec_enrt_perd_strt_dt + nvl(l_pgme_enrt_perd_strt_days,0) ;
        end if ;

        --
        -- The following logic was added by jcarpent for bug 4988/1269016
        -- based on tech design of maagrawa (1-6, 2 is done above)
        -- NOTE: please see identical logic for other modes.  Code added
        -- inline since we don't want to add additional function calls
        -- for performance reasons.
        --
        BEGIN
          -- jcarpent 1/4/2001 bug 1568555, removed +1 from line below
          -- 1 get latest processed date
          l_orig_epsd :=  l_rec_enrt_perd_strt_dt;
          --
          if p_run_mode  = 'L' then
          -- 2746865
          -- call the enrt_perd_strt_dt procedure
	  -- removed inline code and made it a procedure
	     enrt_perd_strt_dt
	                ( p_person_id => p_person_id
	                , p_lf_evt_ocrd_dt => p_lf_evt_ocrd_dt
	                , p_enrt_perd_det_ovrlp_bckdt_cd => l_enrt_perd_det_ovrlp_bckdt_cd
	                , p_rec_enrt_perd_strt_dt => l_rec_enrt_perd_strt_dt
	                , p_ler_id => p_ler_id
                        , p_business_group_id => p_business_group_id
                        , p_effective_date => p_effective_date
                        );
          --
	  end if;
        END;                                           -- of special epsd logic
	if g_debug then
        hr_utility.set_location(' Bef BDD_Mn ' || l_proc, 10);
	end if;
        ben_determine_date.main(
          p_date_cd           => l_pgme_enrt_perd_end_dt_cd,
          p_start_date        => l_orig_epsd,
          p_per_in_ler_id     => l_per_in_ler_id,
          p_person_id         => p_person_id,
          p_pgm_id            => p_pgm_id,
          p_pl_id             => l_pl_id,
          p_oipl_id           => p_oipl_id,
          p_business_group_id => p_business_group_id,
          p_formula_id        => l_pgme_enrt_perd_end_dt_rl,
          p_effective_date    => p_effective_date,
          p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
          p_param1            => 'ENRT_PERD_START_DATE',
          p_param1_value      => fnd_date.date_to_canonical(l_rec_enrt_perd_strt_dt),
          p_returned_date     => l_rec_enrt_perd_end_dt);
          --

          -- GHR enhancment
          if  l_pgme_enrt_perd_end_dt_cd  in ( 'NUMDOE', 'NUMDON','NUMDOEN') then
              l_rec_enrt_perd_end_dt := l_rec_enrt_perd_end_dt + nvl(l_pgme_enrt_perd_end_days,0) ;
          end if ;


          -- 2746865
          -- if cd is L_EPSD_PEPD, proceed as before
          IF ( nvl(l_enrt_perd_det_ovrlp_bckdt_cd,'L_EPSD_PEPD') = 'L_EPSD_PEPD') THEN
            hr_utility.set_location('L_EPSD_PEPD' , 765);
            l_rec_enrt_perd_end_dt :=
                   l_rec_enrt_perd_end_dt + (l_rec_enrt_perd_strt_dt - l_orig_epsd);
          -- 2746865
          ELSE
            -- for other codes
            -- if end dt is less than the start dt, make the strt dt as the end dt
            IF l_rec_enrt_perd_end_dt < l_rec_enrt_perd_strt_dt THEN
	    if g_debug then
              hr_utility.set_location(' end dt < strt dt ', 876);
            end if;
            l_rec_enrt_perd_end_dt := l_rec_enrt_perd_strt_dt;
            END IF;
          END IF;

        --
        l_rec_dflt_asnmt_dt :=
                 l_rec_enrt_perd_end_dt + NVL(l_pgme_dys_aftr_end_to_dflt, 0);
        -- Set it to the enrt_perd_end_dt + addt_procg_dys_num.
        l_rec_procg_end_dt :=
                  l_rec_enrt_perd_end_dt + NVL(l_pgme_addit_procg_dys_num, 0);
        --
        l_rec_lee_rsn_id :=        l_pgme_lee_rsn_id;
        --
	if g_debug then
        hr_utility.set_location(' Dn PFPF=Y ' || l_proc, 10);
	end if;
      ELSE
        --
        fnd_message.set_name('BEN', 'BEN_91335_PLAN_YR_ENRT_PERD');
        fnd_message.set_token('PROC', l_proc);
        fnd_message.set_token('PGM_ID', TO_CHAR(p_pgm_id));
        fnd_message.set_token('PL_ID', TO_CHAR(l_pl_id));
        fnd_message.set_token('EFFECTIVE_DATE', TO_CHAR(p_effective_date));
        fnd_message.set_token('LF_EVT_OCRD_DT', TO_CHAR(p_lf_evt_ocrd_dt));
        RAISE ben_manage_life_events.g_record_error;
      --
      END IF;                             -- perd found and strt_dt_cd not null
    --
    ELSIF (    p_run_mode in ( 'C', 'W') AND p_run_mode <> 'D'
           AND l_unrestricted_enrt_flag = 'N') THEN
      -- If scheduled mode, use enrt_perd.dflt_enrt_dt to determine dflt_asnmt_dt.
      IF (    l_perd_for_plan_found = 'Y'
          AND l_ple_enrt_perd_strt_dt IS NOT NULL) THEN
        --
        l_rec_enrt_perd_strt_dt :=  l_ple_enrt_perd_strt_dt;
        --
        -- The following logic was added by jcarpent for bug 4988/1269016
        -- based on tech design of maagrawa (1-6, 2 is done above)
        -- NOTE: please see identical logic for other modes.  Code added
        -- inline since we don't want to add additional function calls
        -- for performance reasons.
        --
        BEGIN
         -- jcarpent 1/4/2001 bug 1568555, removed +1 from line below
         -- 1 get latest processed date
         l_orig_epsd :=  l_rec_enrt_perd_strt_dt;
         --
         -- Comp work bench
         -- ABSENCES : do not reset the enrt perd.
         --
         if p_run_mode <> 'W' then
           --
           -- 2746865
	   -- call the enrt_perd_strt_dt procedure
	   -- removed inline code and made it a procedure
	   enrt_perd_strt_dt
	   ( p_person_id => p_person_id
	   , p_lf_evt_ocrd_dt => p_lf_evt_ocrd_dt
	   , p_enrt_perd_det_ovrlp_bckdt_cd => l_enrt_perd_det_ovrlp_bckdt_cd
	   , p_rec_enrt_perd_strt_dt => l_rec_enrt_perd_strt_dt
	   , p_ler_id => p_ler_id
           , p_business_group_id => p_business_group_id
           , p_effective_date => p_effective_date
           );
           --
         end if; -- p_mode <> 'W'
        END;                                           -- of special epsd logic
        --
        -- 2746865
        -- if cd is L_EPSD_PEPD, proceed as before
	if g_debug then
        hr_utility.set_location('l_ple_enrt_perd_end_dt ' ||l_ple_enrt_perd_end_dt, 765);
        hr_utility.set_location('l_rec_enrt_perd_end_dt ' ||l_rec_enrt_perd_end_dt, 765);
	end if;

        IF ( nvl(l_enrt_perd_det_ovrlp_bckdt_cd,'L_EPSD_PEPD') = 'L_EPSD_PEPD') THEN
	if g_debug then
          hr_utility.set_location('L_EPSD_PEPD' , 765);
        end if;
          l_rec_enrt_perd_end_dt :=
                l_ple_enrt_perd_end_dt + (l_rec_enrt_perd_strt_dt - l_orig_epsd);
          --
          l_rec_procg_end_dt :=
                  l_ple_procg_end_dt + (l_rec_enrt_perd_strt_dt - l_orig_epsd);
        -- 2746865
        ELSE
          -- for other codes

          -- end dt is the greatest of start date and orig. end date
          /*IF l_ple_enrt_perd_end_dt < l_rec_enrt_perd_strt_dt THEN
            hr_utility.set_location(' end dt < strt dt ', 876);
            l_rec_enrt_perd_end_dt := l_rec_enrt_perd_strt_dt;
          ELSE
            l_rec_enrt_perd_end_dt := l_ple_enrt_perd_end_dt;
          END IF;
          */

          l_rec_enrt_perd_end_dt := greatest (l_rec_enrt_perd_strt_dt, l_ple_enrt_perd_end_dt);
	  if g_debug then
          hr_utility.set_location('l_rec_enrt_perd_end_dt ' ||l_rec_enrt_perd_end_dt, 765);
	  end if;
          --
          --  Bug 5650482.  If the enrollment period end date is greater that the
          --  processing end date, set processing end date to the enrollment
          --  period end date.
          --
          IF l_rec_enrt_perd_end_dt >=  l_ple_procg_end_dt then
            l_rec_procg_end_dt := l_rec_enrt_perd_end_dt;
          ELSE
            l_rec_procg_end_dt := l_ple_procg_end_dt;
          END IF;
          --
        END IF;
	if g_debug then
        hr_utility.set_location('l_rec_procg_end_dt ' ||l_rec_procg_end_dt, 765);
	end if;
        --
        l_rec_dflt_asnmt_dt :=
                  l_ple_dflt_enrt_dt + (l_rec_enrt_perd_strt_dt - l_orig_epsd);
        --
        /* l_rec_procg_end_dt :=
                  l_ple_procg_end_dt + (l_rec_enrt_perd_strt_dt - l_orig_epsd); */
        l_rec_enrt_perd_id :=       l_ple_enrt_perd_id;
      --
      ELSIF (
                  l_perd_for_program_found = 'Y'
              AND l_pgme_enrt_perd_strt_dt IS NOT NULL) THEN
        --
        l_rec_enrt_perd_strt_dt :=  l_pgme_enrt_perd_strt_dt;
        --
        -- The following logic was added by jcarpent for bug 4988/1269016
        -- based on tech design of maagrawa (1-6, 2 is done above)
        -- NOTE: please see identical logic for other modes.  Code added
        -- inline since we don't want to add additional function calls
        -- for performance reasons.
        --
        BEGIN
          -- jcarpent 1/4/2001 bug 1568555, removed +1 from line below
          -- 1 get latest processed date
          l_orig_epsd :=  l_rec_enrt_perd_strt_dt;
          -- 2746865
	  -- call the enrt_perd_strt_dt procedure
	  -- removed inline code and made it a procedure
	  enrt_perd_strt_dt
	  ( p_person_id => p_person_id
	  , p_lf_evt_ocrd_dt => p_lf_evt_ocrd_dt
	  , p_enrt_perd_det_ovrlp_bckdt_cd => l_enrt_perd_det_ovrlp_bckdt_cd
	  , p_rec_enrt_perd_strt_dt => l_rec_enrt_perd_strt_dt
	  , p_ler_id => p_ler_id
          , p_business_group_id => p_business_group_id
          , p_effective_date => p_effective_date
	  );
          --
        END;                                           -- of special epsd logic

        -- 2746865
        -- if cd is L_EPSD_PEPD, proceed as before
        if g_debug then
        hr_utility.set_location('l_ple_enrt_perd_end_dt ' ||l_ple_enrt_perd_end_dt, 765);
        hr_utility.set_location('l_rec_enrt_perd_end_dt ' ||l_rec_enrt_perd_end_dt, 765);
	end if;

        IF ( nvl(l_enrt_perd_det_ovrlp_bckdt_cd,'L_EPSD_PEPD') = 'L_EPSD_PEPD') THEN
	if g_debug then
          hr_utility.set_location('L_EPSD_PEPD' , 765);
        end if;
          l_rec_enrt_perd_end_dt :=
               l_pgme_enrt_perd_end_dt + (l_rec_enrt_perd_strt_dt - l_orig_epsd);
          l_rec_procg_end_dt :=
                 l_pgme_procg_end_dt + (l_rec_enrt_perd_strt_dt - l_orig_epsd);
        ELSE
          -- 2746865
          -- for other codes
          -- end dt is the greatest of start date and original end date
          l_rec_enrt_perd_end_dt := greatest ( l_pgme_enrt_perd_end_dt, l_rec_enrt_perd_strt_dt);
          --
          --  Bug 5650482.  If the enrollment period end date is greater that the
          --  processing end date, set processing end date to the enrollment
          --  period end date.
          --
          IF l_rec_enrt_perd_end_dt >=  l_pgme_procg_end_dt then
            l_rec_procg_end_dt := l_rec_enrt_perd_end_dt;
          ELSE
            l_rec_procg_end_dt := l_pgme_procg_end_dt;
          END IF;
          --
        END IF;
	if g_debug then
        hr_utility.set_location('l_rec_procg_end_dt ' ||l_rec_procg_end_dt, 765);
        hr_utility.set_location('l_rec_enrt_perd_end_dt ' ||l_rec_enrt_perd_end_dt, 765);
	end if;
        --
        l_rec_dflt_asnmt_dt :=
                 l_pgme_dflt_enrt_dt + (l_rec_enrt_perd_strt_dt - l_orig_epsd);
        --
        l_rec_enrt_perd_id :=       l_pgme_enrt_perd_id;
      --
      ELSE
        --
        fnd_message.set_name('BEN', 'BEN_91335_PLAN_YR_ENRT_PERD');
        fnd_message.set_token('PROC', l_proc);
        fnd_message.set_token('PGM_ID', TO_CHAR(p_pgm_id));
        fnd_message.set_token('PL_ID', TO_CHAR(l_pl_id));
        fnd_message.set_token('EFFECTIVE_DATE', TO_CHAR(p_effective_date));
        fnd_message.set_token('LF_EVT_OCRD_DT', TO_CHAR(p_lf_evt_ocrd_dt));
        RAISE ben_manage_life_events.g_record_error;
      --
      END IF;                             -- perd found and strt_dt_cd not null
    ELSIF (p_run_mode =  'M' AND l_unrestricted_enrt_flag = 'N') THEN  -- ABS processing
      --
      -- Get it from the lee_rsn_f for the plan
      -- enrt_perd_strt_dt_cd and enrt_perd_end_dt_cd (and rules)
      -- What domain is this?  Determine the date using the code/rule.
      -- set dflt_asnmt_dt to the
      -- enrt_perd_end_dt + dys_aftr_end_to_dflt_num.
      --
      if g_debug then
      hr_utility.set_location(' RM L UEF N ' || l_proc, 20);
      end if;
      IF ( l_perd_for_plan_found = 'Y'
           AND l_ple_enrt_perd_strt_dt_cd IS NOT NULL) THEN
        --
        ben_determine_date.main(
          p_date_cd           => l_ple_enrt_perd_strt_dt_cd,
          p_per_in_ler_id     => l_per_in_ler_id,
          p_person_id         => p_person_id,
          p_pgm_id            => p_pgm_id,
          p_pl_id             => l_pl_id,
          p_oipl_id           => p_oipl_id,
          p_business_group_id => p_business_group_id,
          p_formula_id        => l_ple_enrt_perd_strt_dt_rl,
          p_effective_date    => p_effective_date,
          p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
          p_returned_date     => l_rec_enrt_perd_strt_dt);

        -- GHR enhancment
        if  l_ple_enrt_perd_strt_dt_cd  in ( 'NUMDOE', 'NUMDON','NUMDOEN') then
            l_rec_enrt_perd_strt_dt := l_rec_enrt_perd_strt_dt + nvl(l_ple_enrt_perd_strt_days,0) ;
        end if ;
        --
        ben_determine_date.main(
          p_date_cd           => l_ple_enrt_perd_end_dt_cd,
          p_start_date        => l_orig_epsd,
          p_per_in_ler_id     => l_per_in_ler_id,
          p_person_id         => p_person_id,
          p_pgm_id            => p_pgm_id,
          p_pl_id             => l_pl_id,
          p_oipl_id           => p_oipl_id,
          p_business_group_id => p_business_group_id,
          p_formula_id        => l_ple_enrt_perd_end_dt_rl,
          p_effective_date    => p_effective_date,
          p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
          p_param1            => 'ENRT_PERD_START_DATE',
          p_param1_value      => fnd_date.date_to_canonical(l_rec_enrt_perd_strt_dt),
          p_returned_date     => l_rec_enrt_perd_end_dt);


        -- GHR enhancment
        if  l_ple_enrt_perd_end_dt_cd  in ( 'NUMDOE', 'NUMDON','NUMDOEN') then
            l_rec_enrt_perd_end_dt := l_rec_enrt_perd_end_dt + nvl(l_ple_enrt_perd_end_days,0) ;
        end if ;

        --
        l_rec_dflt_asnmt_dt :=
              l_rec_enrt_perd_end_dt + NVL(l_ple_dys_aftr_end_to_dflt_num, 0);
        -- Set it to the enrt_perd_end_dt + addt_procg_dys_num.
        l_rec_procg_end_dt :=
                   l_rec_enrt_perd_end_dt + NVL(l_ple_addit_procg_dys_num, 0);
        --
        l_rec_lee_rsn_id :=        l_ple_lee_rsn_id;
        --
	if g_debug then
        hr_utility.set_location(' Dn RM L UEF N ' || l_proc, 20);
	end if;
      ELSE
        --
        fnd_message.set_name('BEN', 'BEN_91335_PLAN_YR_ENRT_PERD');
        fnd_message.set_token('PROC', l_proc);
        fnd_message.set_token('PGM_ID', TO_CHAR(p_pgm_id));
        fnd_message.set_token('PL_ID', TO_CHAR(l_pl_id));
        fnd_message.set_token('EFFECTIVE_DATE', TO_CHAR(p_effective_date));
        fnd_message.set_token('LF_EVT_OCRD_DT', TO_CHAR(p_lf_evt_ocrd_dt));
        RAISE ben_manage_life_events.g_record_error;
      --
      END IF;                             -- perd found and strt_dt_cd not null
    --
    END IF;                                                         -- run mode
-- END IF;
  if g_debug then
    hr_utility.set_location(' start DATE  ' || l_rec_enrt_perd_strt_dt, 92);
    hr_utility.set_location(' END DATE  ' || l_rec_enrt_perd_end_dt, 92);
  end if;
    -- Check to see if the start date is before the end date
    IF l_rec_enrt_perd_strt_dt > l_rec_enrt_perd_end_dt THEN
      --
      fnd_message.set_name('BEN', 'BEN_91735_END_BEFORE_STRT_DT');
      fnd_message.set_token('PROC', l_proc);
      fnd_message.set_token(
        'ENRT_PERD_STRT_DT',
        TO_CHAR(l_rec_enrt_perd_strt_dt));
      fnd_message.set_token(
        'ENRT_PERD_END_DT',
        TO_CHAR(l_rec_enrt_perd_end_dt));
      RAISE ben_manage_life_events.g_record_error;
    --
    END IF;
    --
    -- if sched mode and l_crnt_enrt_cvg_strt_dt is not null then
    -- see if plan has regulation of IRC Section 125 or 129.
    --
   /*
    l_regn_125_or_129_flag:='N';
    if p_run_mode='C' and
       l_crnt_enrt_cvg_strt_dt is not null then
      open c_regn_125_or_129;
      fetch c_regn_125_or_129 into l_regn_125_or_129_flag;
      hr_utility.set_location('regn_125_or_129='||l_regn_125_or_129_flag,10);
      close c_regn_125_or_129;
    end if;
 */
--hr_utility.set_location('p_run_mode='||p_run_mode,1776);
--hr_utility.set_location('l_crnt_enrt_cvg_strt_dt='||l_crnt_enrt_cvg_strt_dt,1776);
--hr_utility.set_location('l_regn_125_or_129_flag='||l_regn_125_or_129_flag,1776);
    --
    -- Determine the enrolment coverage codes/rules
    -- If currently enrolled get from old enrollment.
    --
    IF l_crnt_enrt_cvg_strt_dt IS NOT NULL and
       l_new_cvg_strt='N' THEN
      l_rec_enrt_cvg_strt_dt :=  l_crnt_enrt_cvg_strt_dt;

       -- 2982606 when the coverage start date of the prev LE is in future
       -- and current LE is current or earlier than previous one
       -- create new result and not currently enrolled - two plan
     if g_debug then
       hr_utility.set_location('l_crnt_enrt_cvg_strt_dt='||
                                l_crnt_enrt_cvg_strt_dt,1777);
     end if;
       if l_crnt_enrt_cvg_strt_dt > p_lf_evt_ocrd_dt then
            ben_determine_date.rate_and_coverage_dates
             (p_cache_mode          => TRUE
             ,p_per_in_ler_id       => l_per_in_ler_id
             ,p_person_id           => p_person_id
             ,p_pgm_id              => p_pgm_id
             ,p_pl_id               => l_pl_id
             ,p_oipl_id             => p_oipl_id
             ,p_par_ptip_id         => p_comp_obj_tree_row.par_ptip_id
             ,p_par_plip_id         => p_comp_obj_tree_row.par_plip_id
             ,p_lee_rsn_id          => l_rec_lee_rsn_id
             ,p_enrt_perd_id        => l_rec_enrt_perd_id
             ,p_business_group_id   => p_business_group_id
             ,p_which_dates_cd      => 'C'
             ,p_date_mandatory_flag => 'N'
             ,p_compute_dates_flag  => 'Y'
             ,p_enrt_cvg_strt_dt    => l_rec_enrt_cvg_strt_dt
             ,p_enrt_cvg_strt_dt_cd => l_dummy_enrt_cvg_strt_dt_cd
             ,p_enrt_cvg_strt_dt_rl => l_dummy_enrt_cvg_strt_dt_rl
             ,p_rt_strt_dt          => l_dummy_rt_strt_dt
             ,p_rt_strt_dt_cd       => l_dummy_rt_strt_dt_cd
             ,p_rt_strt_dt_rl       => l_dummy_rt_strt_dt_rl
             ,p_enrt_cvg_end_dt     => l_dummy_enrt_cvg_end_dt
             ,p_enrt_cvg_end_dt_cd  => l_dummy_enrt_cvg_end_dt_cd
             ,p_enrt_cvg_end_dt_rl  => l_dummy_enrt_cvg_end_dt_rl
             ,p_rt_end_dt           => l_dummy_rt_end_dt
             ,p_rt_end_dt_cd        => l_dummy_rt_end_dt_cd
             ,p_rt_end_dt_rl        => l_dummy_rt_end_dt_rl
             ,p_effective_date      => p_effective_date
            ,p_lf_evt_ocrd_dt       => GREATEST(
                                        NVL(p_lf_evt_ocrd_dt, l_prtn_strt_dt),
                                        NVL(l_prtn_strt_dt, p_lf_evt_ocrd_dt))
             );
	     if g_debug then
             hr_utility.set_location('Done RACD:' || l_proc, 11);
	     end if;

	     if  l_rec_enrt_cvg_strt_dt >=   l_crnt_enrt_cvg_strt_dt then
                 l_rec_enrt_cvg_strt_dt :=  l_crnt_enrt_cvg_strt_dt;
             else
                 l_rec_enrt_cvg_strt_dt_cd   := L_dummy_enrt_cvg_strt_dt_cd ;
                 l_rec_enrt_cvg_strt_dt_rl   := l_dummy_enrt_cvg_strt_dt_rl ;
                 if (l_fut_rslt_exist) or nvl(l_crnt_enrt_sspndd_flag,'N') = 'Y' then  -------------Bug 8846328
		 hr_utility.set_location('fur rslt exist or sspndd rec', 11);
                    ---Do nothing
		 else
		   hr_utility.set_location('fur rslt not exist', 11);
		   l_rec_crntly_enrd_flag      := 'N' ;
		 end if;
            end if;
	    if g_debug then
            hr_utility.set_location('l_rec_enrt_cvg_strt_dt RACD:'|| l_rec_enrt_cvg_strt_dt, 11);
	    end if;

       end if ;
       ---2982606

    ELSE
    if g_debug then
      hr_utility.set_location(' RACD:' || l_proc, 10);
    end if;
      ben_determine_date.rate_and_coverage_dates
        (p_cache_mode          => TRUE
        ,p_per_in_ler_id       => l_per_in_ler_id
        ,p_person_id           => p_person_id
        ,p_pgm_id              => p_pgm_id
        ,p_pl_id               => l_pl_id
        ,p_oipl_id             => p_oipl_id
        ,p_par_ptip_id         => p_comp_obj_tree_row.par_ptip_id
        ,p_par_plip_id         => p_comp_obj_tree_row.par_plip_id
        ,p_lee_rsn_id          => l_rec_lee_rsn_id
        ,p_enrt_perd_id        => l_rec_enrt_perd_id

        ,p_business_group_id   => p_business_group_id
        ,p_which_dates_cd      => 'C'
        ,p_date_mandatory_flag => 'N'
        ,p_compute_dates_flag  => 'Y'
        ,p_enrt_cvg_strt_dt    => l_rec_enrt_cvg_strt_dt
        ,p_enrt_cvg_strt_dt_cd => l_rec_enrt_cvg_strt_dt_cd
        ,p_enrt_cvg_strt_dt_rl => l_rec_enrt_cvg_strt_dt_rl
        ,p_rt_strt_dt          => l_dummy_rt_strt_dt
        ,p_rt_strt_dt_cd       => l_dummy_rt_strt_dt_cd
        ,p_rt_strt_dt_rl       => l_dummy_rt_strt_dt_rl
        ,p_enrt_cvg_end_dt     => l_dummy_enrt_cvg_end_dt
        ,p_enrt_cvg_end_dt_cd  => l_dummy_enrt_cvg_end_dt_cd
        ,p_enrt_cvg_end_dt_rl  => l_dummy_enrt_cvg_end_dt_rl
        ,p_rt_end_dt           => l_dummy_rt_end_dt
        ,p_rt_end_dt_cd        => l_dummy_rt_end_dt_cd
        ,p_rt_end_dt_rl        => l_dummy_rt_end_dt_rl
        ,p_effective_date      => p_effective_date
        ,p_lf_evt_ocrd_dt      => GREATEST(
                                   NVL(p_lf_evt_ocrd_dt, l_prtn_strt_dt),
                                   NVL(l_prtn_strt_dt, p_lf_evt_ocrd_dt))
        );
   if g_debug then
      hr_utility.set_location('Done RACD:' || l_proc, 10);
   end if;
    END IF;
    --
    -- Determine the erlst_deenrt_dt
    --
    if g_debug then
    hr_utility.set_location('AB', 20);
    end if;
    --
 IF p_run_mode <> 'D' THEN
    -- Find the required period of enrollment code/rule/uom/level defined at
    --
    find_rqd_perd_enrt(
      p_oipl_id                 => p_oipl_id,
      p_opt_id                  => l_opt_id,
      p_pl_id                   => l_pl_id,
      p_ptip_id                 => l_ptip_id,
/*
      p_parptip_row             => p_parptip_row,
      p_parpl_row               => p_parpl_row,
      p_paropt_row              => p_paropt_row,
      p_paroipl_row             => p_paroipl_row,
*/
      p_effective_date          => NVL(p_lf_evt_ocrd_dt, p_effective_date),
      p_business_group_id       => p_business_group_id,
      p_rqd_perd_enrt_nenrt_uom => l_rqd_perd_enrt_nenrt_uom,
      p_rqd_perd_enrt_nenrt_val => l_rqd_perd_enrt_nenrt_val,
      p_rqd_perd_enrt_nenrt_rl  => l_rqd_perd_enrt_nenrt_rl,
      p_level                   => l_level);
    --
    -- If don't have an existing erlst_deenrt_dt and
    -- there is a code defined at some level
    -- then see if the date is set on some pen row at that level
    -- levels are OIPL, OPT, PL, PTIP.
    --
    IF     l_crnt_erlst_deenrt_dt IS NULL
       AND l_level IS NOT NULL THEN
      find_enrt_at_same_level(
        p_person_id         => p_person_id,
        p_opt_id            => l_opt_id,
        p_oipl_id           => p_oipl_id,
        p_pl_id             => l_pl_id,
        p_ptip_id           => l_ptip_id,
        p_pl_typ_id         => l_pl_typ_id,
        p_pgm_id            => p_pgm_id,
        p_effective_date    => NVL(p_lf_evt_ocrd_dt, p_effective_date),
        p_business_group_id => p_business_group_id,
        p_prtt_enrt_rslt_id => -1,
        p_level             => l_level,
        p_pen_rec           => l_pen_rec);
        l_crnt_erlst_deenrt_dt :=  l_pen_rec.erlst_deenrt_dt;
	if g_debug then
        hr_utility.set_location('l_crnt_erlst_deenrt_dt' || l_crnt_erlst_deenrt_dt,8086.0);
	end if;
    END IF;
    --if elst_deenrt_dt is plan leven use original entrol date or
    -- option level  use coverage date
    l_erlst_deenrt_calc_dt   := l_rec_enrt_cvg_strt_dt  ;
    if l_level is not null then
      if l_level not in ('OPT','OIPL') then
         l_erlst_deenrt_calc_dt   := nvl(l_orgnl_enrt_dt,l_rec_enrt_cvg_strt_dt );
      end if ;
    end if ;
    if g_debug then
    hr_utility.set_location('l_erlst_deenrt_calc_dt' || l_erlst_deenrt_calc_dt ,8086);
    hr_utility.set_location('l_rec_enrt_cvg_strt_dt' || l_rec_enrt_cvg_strt_dt ,8086);
    end if;
    --
    -- if the enrt_cvg_strt_dt cannot be determined or
    -- the current enrt erlst_deenrt_dt is not null then
    -- use the old one
    --
    --IF ( l_rec_enrt_cvg_strt_dt IS NULL
    IF ( l_erlst_deenrt_calc_dt IS NULL
        OR l_crnt_erlst_deenrt_dt IS NOT NULL) THEN
      -- use the erlst_deenrt_dt from the current enrolment
      l_rec_erlst_deenrt_dt :=  l_crnt_erlst_deenrt_dt;
      --
    --
    -- else if the new enrolment cvg_strt_dt is set
    -- and the ptip.rqd_perd_enrt_nenrt_val is set then
    -- compute a new value
    --
    ELSIF (
                l_erlst_deenrt_calc_dt IS NOT NULL
            AND (
                     (
                           l_rqd_perd_enrt_nenrt_val IS NOT NULL
                       AND l_rqd_perd_enrt_nenrt_uom IS NOT NULL)
                  OR l_rqd_perd_enrt_nenrt_rl IS NOT NULL)) THEN
      --
      -- compute the date based on the enrt_cvg_strt_dt and the
      -- rqd_perd_enrt_nenrt_val/uom.
      --
      l_rec_erlst_deenrt_dt :=
       determine_erlst_deenrt_dt(
         l_erlst_deenrt_calc_dt,
         l_rqd_perd_enrt_nenrt_val,
         l_rqd_perd_enrt_nenrt_uom,
         l_rqd_perd_enrt_nenrt_rl,
         p_oipl_id,
         l_pl_id,
         l_pl_typ_id,
         l_opt_id,
         p_pgm_id,
         p_ler_id,
         l_popl_yr_perd_ordr_num,
         l_yr_perd_end_date,
         p_effective_date,
         p_lf_evt_ocrd_dt,
         p_person_id,
         p_business_group_id,
         l_rec_assignment_id,
         l_rec_organization_id,
         l_jurisdiction_code);
    --
    ELSE
      -- Leave it blank.
      l_rec_erlst_deenrt_dt :=  NULL;
    --
    END IF;
  if g_debug then
    hr_utility.set_location('l_rec_erlst_deenrt_dt' || l_rec_erlst_deenrt_dt  ,8086);
  end if;
    --
END IF; --'D' Mode
    -- set the comp_lvl_cd
    --
    IF (p_oipl_id IS NULL) THEN
      --
      IF l_invk_flx_cr_pl_flag = 'Y' THEN
        --
        l_rec_elctbl_flag :=  'N';
        l_comp_lvl_cd :=      'PLANFC';
      --
      ELSIF l_imptd_incm_calc_cd IN ('PRTT', 'DPNT', 'SPS') THEN
        --
        l_rec_elctbl_flag :=  'N';
        l_comp_lvl_cd :=      'PLANIMP';
      --
      ELSE
        --
        l_comp_lvl_cd :=  'PLAN';
      --
      END IF;
    --
    ELSE
      --
      l_comp_lvl_cd :=  'OIPL';
    --
    END IF;
    --
    -- Default the remaining fields
    -- roll_crs_only_flag to N
    --
    l_rec_roll_crs_only_flag :=   'N';
    -- elctns_made_flag to N
    l_rec_elctns_made_flag :=     'N';
    --
    -- Check all comp objects for existance when enrt perd starts
    --
    -- Start with pgm related things
    --
    --
    -- following requery logic added for bug 1394507 - for all plan design
    -- objects
    --
    IF p_pgm_id IS NOT NULL THEN
      --
      -- check pgm
      --
      IF (
           l_rec_enrt_perd_strt_dt NOT BETWEEN l_pgm_rec.effective_start_date
               AND l_pgm_rec.effective_end_date) THEN
        open c_pgm_requery(p_pgm_id,l_rec_enrt_perd_strt_dt);
        fetch c_pgm_requery into l_dummy;
        if c_pgm_requery%notfound then
	if g_debug then
          hr_utility.set_location(
            'Program not date effective on period start',
            10);
        end if;
          fnd_message.set_name('BEN', 'BEN_92214_PGM_NOT_EFF_ON_STRT');
          fnd_message.set_token('PROC', l_proc);
          fnd_message.set_token(
            'ENRT_PERD_STRT_DT',
            TO_CHAR(l_rec_enrt_perd_strt_dt));
          fnd_message.set_token(
            'PGM_STRT_DT',
            TO_CHAR(l_pgm_rec.effective_start_date));
          fnd_message.set_token(
            'PGM_END_DT',
            TO_CHAR(l_pgm_rec.effective_end_date));
          benutils.write(p_text => SUBSTR(fnd_message.get, 1, 128));
          p_electable_flag :=  'N';
          RETURN;
        end if;
        close c_pgm_requery;
      END IF;
      --
      -- check plip
      --
      IF (l_rec_enrt_perd_strt_dt NOT BETWEEN l_plip_esd AND l_plip_eed) THEN
        open c_plip_requery(l_plip_id,l_rec_enrt_perd_strt_dt);
        fetch c_plip_requery into l_dummy;
        if c_plip_requery%notfound then
	if g_debug then
          hr_utility.set_location('Plip not date effective on period start', 10);
        end if;
          fnd_message.set_name('BEN', 'BEN_92208_PLIP_NOT_EFF_ON_STRT');
          fnd_message.set_token('PROC', l_proc);
          fnd_message.set_token(
            'ENRT_PERD_STRT_DT',
            TO_CHAR(l_rec_enrt_perd_strt_dt));
          fnd_message.set_token('PLIP_STRT_DT', TO_CHAR(l_plip_esd));
          fnd_message.set_token('PLIP_END_DT', TO_CHAR(l_plip_eed));
          benutils.write(p_text => SUBSTR(fnd_message.get, 1, 128));
          p_electable_flag :=  'N';
          RETURN;
        end if;
        close c_plip_requery;
      END IF;

   if g_debug then
      hr_utility.set_location('NHK: l_lf_evt_ocrd_dt ' || l_lf_evt_ocrd_dt , 10);
      hr_utility.set_location('NHK: l_rec_enrt_perd_strt_dt ' || l_rec_enrt_perd_strt_dt , 20);
      hr_utility.set_location('NHK: l_ptip_esd ' || l_ptip_esd , 30);
      hr_utility.set_location('NHK: l_ptip_eed ' || l_ptip_eed , 40);
      hr_utility.set_location('NHK: p_electable_flag ' || p_electable_flag , 50);
      --
   end if;
      -- check ptip
      --
      IF (l_rec_enrt_perd_strt_dt NOT BETWEEN l_ptip_esd AND l_ptip_eed) THEN
      if g_debug then
        hr_utility.set_location('NHK: p_electable_flag ' || p_electable_flag , 60);
	end if;
        open c_ptip_requery(l_ptip_id,l_rec_enrt_perd_strt_dt);
        fetch c_ptip_requery into l_dummy;
        if c_ptip_requery%notfound then
	if g_debug then
          hr_utility.set_location('Ptip not date effective on period start', 10);
        end if;
          fnd_message.set_name('BEN', 'BEN_92213_PTIP_NOT_EFF_ON_STRT');
          fnd_message.set_token('PROC', l_proc);
          fnd_message.set_token(
            'ENRT_PERD_STRT_DT',
            TO_CHAR(l_rec_enrt_perd_strt_dt));
          fnd_message.set_token('PTIP_STRT_DT', TO_CHAR(l_ptip_esd));
          fnd_message.set_token('PTIP_END_DT', TO_CHAR(l_ptip_eed));
          benutils.write(p_text => SUBSTR(fnd_message.get, 1, 128));
          p_electable_flag :=  'N';
          -- Bug fix 2008871 -- hnarayan
          close c_ptip_requery;
          RETURN;
          -- End fix 2008871
	  if g_debug then
          hr_utility.set_location('NHK: p_electable_flag ' || p_electable_flag , 70);
	  end if;
        end if;
        close c_ptip_requery;
	if g_debug then
        hr_utility.set_location('NHK: p_electable_flag ' || p_electable_flag , 80);
	end if;
        -- Bug fix 2008871 -- hnarayan -- commented the return and included it above
        --  			since it affects positive cases of electability
        --			when l_rec_enrt_perd_strt_dt is not between the
        --			active ptip record which is effective (retrieved in c_ptip_requery also)
        --			as per the l_lf_ocrd_dt.
        -- RETURN;
      END IF;
    END IF;
    --
    -- Continue with option related things
    --
    IF p_oipl_id IS NOT NULL THEN
      --
      -- check oipl
      --
      IF (
           l_rec_enrt_perd_strt_dt NOT BETWEEN l_oipl_rec.effective_start_date
               AND l_oipl_rec.effective_end_date) THEN
        open c_oipl_requery(p_oipl_id,l_rec_enrt_perd_strt_dt);
        fetch c_oipl_requery into l_dummy;
        if c_oipl_requery%notfound then
	if g_debug then
        hr_utility.set_location('Oipl not date effective on period start', 10);
	end if;
        fnd_message.set_name('BEN', 'BEN_92207_OIPL_NOT_EFF_ON_STRT');
        fnd_message.set_token('PROC', l_proc);
        fnd_message.set_token(
          'ENRT_PERD_STRT_DT',
          TO_CHAR(l_rec_enrt_perd_strt_dt));
        fnd_message.set_token(
          'OIPL_STRT_DT',
          TO_CHAR(l_oipl_rec.effective_start_date));
        fnd_message.set_token(
          'OIPL_END_DT',
          TO_CHAR(l_oipl_rec.effective_end_date));
        benutils.write(p_text => SUBSTR(fnd_message.get, 1, 128));
        p_electable_flag :=  'N';
        RETURN;
        end if;
        close c_oipl_requery;
      END IF;
      --
      -- check opt
      --
      IF (
           l_rec_enrt_perd_strt_dt NOT BETWEEN ben_cobj_cache.g_opt_currow.effective_start_date
               AND ben_cobj_cache.g_opt_currow.effective_end_date) THEN
        open c_opt_requery(l_opt_id,l_rec_enrt_perd_strt_dt);
        fetch c_opt_requery into l_dummy;
        if c_opt_requery%notfound then
	if g_debug then
        hr_utility.set_location(
          'Option not date effective on period start',
          10);
        end if;
        fnd_message.set_name('BEN', 'BEN_92212_OPT_NOT_EFF_ON_STRT');
        fnd_message.set_token('PROC', l_proc);
        fnd_message.set_token(
          'ENRT_PERD_STRT_DT',
          TO_CHAR(l_rec_enrt_perd_strt_dt));
        fnd_message.set_token(
          'OPT_STRT_DT',
          TO_CHAR(ben_cobj_cache.g_opt_currow.effective_start_date));
        fnd_message.set_token(
          'OPT_END_DT',
          TO_CHAR(ben_cobj_cache.g_opt_currow.effective_end_date));
        benutils.write(p_text => SUBSTR(fnd_message.get, 1, 128));
        p_electable_flag :=  'N';
        RETURN;
        end if;
        close c_opt_requery;
      END IF;
    END IF;
    --
    -- check plan
    --
    IF (
         l_rec_enrt_perd_strt_dt NOT BETWEEN l_plan_rec.effective_start_date
             AND l_plan_rec.effective_end_date) THEN
        open c_plan_requery(l_pl_id,l_rec_enrt_perd_strt_dt);
        fetch c_plan_requery into l_dummy;
        if c_plan_requery%notfound then
     if g_debug then
      hr_utility.set_location('Plan not date effective on period start', 10);
      hr_utility.set_location('perd_strt_dt=' || l_rec_enrt_perd_strt_dt, 1);
      hr_utility.set_location('strt_dt=' || l_plan_rec.effective_start_date, 1);
      hr_utility.set_location('end_dt=' || l_plan_rec.effective_end_date, 1);
     end if;
      fnd_message.set_name('BEN', 'BEN_92211_PLAN_NOT_EFF_ON_STRT');
      fnd_message.set_token('PROC', l_proc);
      fnd_message.set_token(
        'ENRT_PERD_STRT_DT',
        TO_CHAR(l_rec_enrt_perd_strt_dt));
      fnd_message.set_token(
        'PL_STRT_DT',
        TO_CHAR(l_plan_rec.effective_start_date));
      fnd_message.set_token(
        'PL_END_DT',
        TO_CHAR(l_plan_rec.effective_end_date));
      benutils.write(p_text => SUBSTR(fnd_message.get, 1, 128));
      p_electable_flag :=  'N';
      RETURN;
        end if;
        close c_plan_requery;
    END IF;
    --
    -- check pl_typ
    --
    OPEN c_pl_typ;
    FETCH c_pl_typ INTO l_pl_typ_esd, l_pl_typ_eed;
    CLOSE c_pl_typ;
    if g_debug then
    hr_utility.set_location('close c_pl_typ:' || l_proc, 10);
    end if;
    IF (l_rec_enrt_perd_strt_dt NOT BETWEEN l_pl_typ_esd AND l_pl_typ_eed) THEN
        open c_pl_typ_requery(l_pl_typ_id,l_rec_enrt_perd_strt_dt);
        fetch c_pl_typ_requery into l_dummy;
        if c_pl_typ_requery%notfound then
      if g_debug then
      hr_utility.set_location('Pl_typ not date effective on period start', 10);
      end if;
      fnd_message.set_name('BEN', 'BEN_92206_PL_TYP_NOT_EFF_ON_ST');
      fnd_message.set_token('PROC', l_proc);
      fnd_message.set_token(
        'ENRT_PERD_STRT_DT',
        TO_CHAR(l_rec_enrt_perd_strt_dt));
      fnd_message.set_token('PL_TYP_STRT_DT', TO_CHAR(l_pl_typ_esd));
      fnd_message.set_token('PL_TYP_END_DT', TO_CHAR(l_pl_typ_eed));
      benutils.write(p_text => SUBSTR(fnd_message.get, 1, 128));
      p_electable_flag :=  'N';
      RETURN;
        end if;
        close c_pl_typ_requery;
    END IF;
    --
    -- check lee_rsn
    --
    IF (
         l_rec_enrt_perd_strt_dt NOT BETWEEN l_rec_lee_rsn_esd
             AND l_rec_lee_rsn_eed) THEN
        open c_lee_rsn_requery(l_rec_lee_rsn_id,l_rec_enrt_perd_strt_dt);
        fetch c_lee_rsn_requery into l_dummy;
        if c_lee_rsn_requery%notfound then
    if g_debug then
      hr_utility.set_location(
        'Lee_rsn not date effective on period start',
        10);
    end if;
      fnd_message.set_name('BEN', 'BEN_92210_LEE_RSN_NOT_EFF_ON_S');
      fnd_message.set_token('PROC', l_proc);
      fnd_message.set_token(
        'ENRT_PERD_STRT_DT',
        TO_CHAR(l_rec_enrt_perd_strt_dt));
      fnd_message.set_token('LEE_RSN_STRT_DT', TO_CHAR(l_rec_lee_rsn_esd));
      fnd_message.set_token('LEE_RSN_END_DT', TO_CHAR(l_rec_lee_rsn_eed));
      benutils.write(p_text => SUBSTR(fnd_message.get, 1, 128));
      p_electable_flag :=  'N';
      RETURN;
        end if;
        close c_lee_rsn_requery;
    END IF;
    --
    -- check ler
    --
    IF (l_rec_enrt_perd_strt_dt NOT BETWEEN l_ler_esd AND l_ler_eed) THEN
        open c_ler_requery(p_ler_id,l_rec_enrt_perd_strt_dt);
        fetch c_ler_requery into l_dummy;
        if c_ler_requery%notfound then
    if g_debug then
      hr_utility.set_location('Ler not date effective on period start', 10);
    end if;
      fnd_message.set_name('BEN', 'BEN_92209_LER_NOT_EFF_ON_STRT');
      fnd_message.set_token('PROC', l_proc);
      fnd_message.set_token(
        'ENRT_PERD_STRT_DT',
        TO_CHAR(l_rec_enrt_perd_strt_dt));
      fnd_message.set_token('LER_STRT_DT', TO_CHAR(l_ler_esd));
      fnd_message.set_token('LER_END_DT', TO_CHAR(l_ler_eed));
      benutils.write(p_text => SUBSTR(fnd_message.get, 1, 128));
      p_electable_flag :=  'N';
      RETURN;
        end if;
        close c_ler_requery;
    END IF;
    --
    -- set the acty_ref_perd_cd and uom
    --
    IF p_pgm_id IS NOT NULL THEN
      l_rec_acty_ref_perd_cd :=  l_pgm_rec.acty_ref_perd_cd;
      l_rec_uom :=               l_pgm_rec.pgm_uom;
    ELSE                                                        -- use the plan
      l_rec_acty_ref_perd_cd :=  l_plan_rec.nip_acty_ref_perd_cd;
      l_rec_uom :=               l_plan_rec.nip_pl_uom;
    END IF;
    --
    -- Set the auto_enrt_flag based on which comp level is being created
    --
    IF p_oipl_id IS NOT NULL THEN
      l_rec_auto_enrt_flag :=  l_oipl_auto_enrt_flag;
    ELSE
      l_rec_auto_enrt_flag :=  l_auto_enrt_flag;
    END IF;
    --
    --Based on automatic enrollment codes, the auto enrt flag needs to
    --be overridden
    If l_pl_enrt_cd = 'CANA' then
      --
      l_rec_auto_enrt_flag := 'Y' ;
      --
    elsif l_pl_enrt_cd = 'CANN' and l_rec_crntly_enrd_flag = 'Y' then
      --
      l_rec_auto_enrt_flag := 'Y' ;
      --
    elsif l_pl_enrt_cd = 'CANN' and l_rec_crntly_enrd_flag = 'N' then
      --
      l_rec_auto_enrt_flag := 'N';
      --
    elsif l_pl_enrt_cd = 'CNNA' and nvl(l_rec_crntly_enrd_flag,'N') = 'N' then
      --
      l_rec_auto_enrt_flag := 'Y';
      --
    elsif l_pl_enrt_cd = 'CNNA' and l_rec_crntly_enrd_flag = 'Y' then
      --
      l_rec_auto_enrt_flag := 'N';
      --
    end if;

      --

    -- Choice can be either automatic or default, not both.
    --
    IF l_rec_auto_enrt_flag = 'Y' THEN
      --
      l_dflt_flag :=  'N';
    --
    END IF;
    --
    -- Validate cls_enrt_dt_to_use_cd is defined
    --
    IF l_rec_cls_enrt_dt_to_use_cd IS NULL THEN
      --
--      hr_utility.set_location('Invalid cls_enrt_dt_cd', 10);
      --
      fnd_message.set_name('BEN', 'BEN_91905_INVLD_CLS_ENRT_DT_CD');
      fnd_message.set_token('PROC', l_proc);
      fnd_message.set_token(
        'CLS_ENRT_DT_TO_USE_CD',
        l_rec_cls_enrt_dt_to_use_cd);
      RAISE ben_manage_life_events.g_record_error;
    --
    END IF;
    --
    -- We need to determine if an electable choice has been written or not
    --
--    hr_utility.set_location('AG', 20);
    IF p_ler_id IS NOT NULL THEN
      --
      g_any_choice_created :=  TRUE;
      IF l_rec_elctbl_flag = 'Y' THEN
        g_electable_choice_created :=  TRUE;
      END IF;
      IF l_rec_auto_enrt_flag = 'Y' THEN
        g_auto_choice_created :=  TRUE;
      END IF;
    --
    END IF;
    -- cwb changes
    if p_run_mode = 'W' then

       g_ple_hrchy_to_use_cd       := l_ple_hrchy_to_use_cd;
       g_ple_pos_structure_version_id := l_ple_pos_structure_version_id;
       --
       /*
       -- For GLOBALCWB : this call is moved to benptnle
       get_cwb_manager_and_assignment(p_person_id => p_person_id,
                                      p_hrchy_to_use_cd => l_ple_hrchy_to_use_cd,
                                      p_pos_structure_version_id => l_ple_pos_structure_version_id,
                                      p_effective_date => p_effective_date,
                                      p_manager_id     => l_ws_mgr_id,
                                      p_assignment_id  => l_assignment_id ) ;
       */
       --
    end if;

    -- Bug 2503570
    -- 1. Irrespective of a person is eligible or not Elctble_flag is set to Y
    -- in case of CWB electable choices. Electable choices created for
    -- managers will always have Elctble_flag set to N.
    -- 2. If person is not eligible then elig_flag will be set to N else Y.
    --
    if p_run_mode = 'W' then
       l_rec_elctbl_flag := 'Y';
    end if;

    if l_current_eligibility = 'Y' then
       l_elig_flag := 'Y';
    else
       l_elig_flag  := 'N';
    end if;
--
--    hr_utility.set_location('Calling Create Api', 10);
--    hr_utility.set_location('p_enrt_perd_id ' || l_rec_enrt_perd_id, 10);
--    hr_utility.set_location('p_lee_rsn_id ' || l_rec_lee_rsn_id, 10);
--    hr_utility.set_location('l_per_in_ler_id ' || l_per_in_ler_id, 10);
--    hr_utility.set_location('l_prtt_enrt_rslt_id ' || l_prtt_enrt_rslt_id, 10);
    --
    /* if p_run_mode = 'W'
    then  Bug 3502094  : For FP-F this flag do not have any significance.
                           For july FP : final functionality will be decided.
      and l_elig_flag = 'N' and
       ( (p_oipl_id is null and
          nvl(l_pl_trk_inelig_per_flag,'N') = 'N') or
         (p_oipl_id is not null and
          nvl(l_oipl_trk_inelig_per_flag,'N') = 'N') ) then
       hr_utility.set_location('By passing creation of epe for CWB'||l_proc,10);
    else
    */
       if ben_manage_life_events.fonm = 'Y' then
       if g_debug then
          hr_utility.set_location('fonm cvr strt dt',100);
       end if;
          l_fonm_cvg_strt_dt := ben_manage_life_events.g_fonm_cvg_strt_dt;
       end if;
       if g_debug then
       hr_utility.set_location('EPEC_CRE: ' || l_proc, 10);
       end if;
       /* unrestricted Enh*/
       if p_run_mode in ('U','R') then
       if g_debug then
          hr_utility.set_location('before epe exists',11);
       end if;
         --
         l_epe_exists :=  ben_manage_unres_life_events.epe_exists
                  (p_per_in_ler_id => l_per_in_ler_id,
                   p_pgm_id => p_pgm_id,
                   p_pl_id  => l_pl_id,
                   p_oipl_id =>p_oipl_id);
         if l_epe_exists is not null then
            ben_manage_unres_life_events.update_elig_per_elctbl_choice
            (
             p_elig_per_elctbl_chc_id => l_epe_exists,
             p_business_group_id      => p_business_group_id,
             p_auto_enrt_flag         => NVL(l_rec_auto_enrt_flag,'N'),
             p_per_in_ler_id          => l_per_in_ler_id,
             p_yr_perd_id             => l_yr_perd_id,
             p_pl_id                  => l_pl_id,
             p_pl_typ_id              => l_pl_typ_id,
             p_oipl_id                => p_oipl_id,
             p_pgm_id                 => p_pgm_id,
             p_pgm_typ_cd             => l_pgm_rec.pgm_typ_cd,
             p_must_enrl_anthr_pl_id  => l_must_enrl_anthr_pl_id,
             p_plip_id                => l_plip_id,
             p_ptip_id                => l_ptip_id,
             p_prtt_enrt_rslt_id      => l_prtt_enrt_rslt_id,
             p_comp_lvl_cd            => l_comp_lvl_cd,
             p_enrt_cvg_strt_dt_cd    => l_rec_enrt_cvg_strt_dt_cd,
             p_enrt_perd_end_dt       => l_rec_enrt_perd_end_dt,
             p_enrt_perd_strt_dt      => l_rec_enrt_perd_strt_dt,
             p_enrt_cvg_strt_dt_rl    => l_rec_enrt_cvg_strt_dt_rl,
             p_roll_crs_flag          => 'N',
             p_ctfn_rqd_flag          => NVL(l_ctfn_rqd_flag,'N'),
             p_crntly_enrd_flag       => NVL(l_rec_crntly_enrd_flag,'N'),
             p_dflt_flag              => NVL(l_dflt_flag,'N'),
             p_elctbl_flag            => NVL(l_rec_elctbl_flag,'N'),
             p_mndtry_flag            => NVL(l_rec_mndtry_flag,'N'),
             p_dflt_enrt_dt           => l_rec_dflt_asnmt_dt,
             p_dpnt_cvg_strt_dt_cd    => NULL,
             p_dpnt_cvg_strt_dt_rl    => NULL,
             p_enrt_cvg_strt_dt       => l_rec_enrt_cvg_strt_dt,
             p_alws_dpnt_dsgn_flag    => 'N',
             p_erlst_deenrt_dt        => l_rec_erlst_deenrt_dt,
             p_procg_end_dt           => l_rec_procg_end_dt,
             p_pl_ordr_num            => l_plan_rec.ordr_num,
             p_plip_ordr_num          => l_plip_ordr_num,
             p_ptip_ordr_num          => l_ptip_ordr_num,
             p_oipl_ordr_num          => l_oipl_rec.ordr_num,
             --p_object_version_number  => l_object_version_number,
             p_effective_date         => p_effective_date,
             p_enrt_perd_id           => l_rec_enrt_perd_id,
             p_lee_rsn_id             => l_rec_lee_rsn_id,
             p_cls_enrt_dt_to_use_cd  => l_rec_cls_enrt_dt_to_use_cd,
             p_uom                    => l_rec_uom,
             p_acty_ref_perd_cd       => l_rec_acty_ref_perd_cd,
             p_cryfwd_elig_dpnt_cd    => l_reinstt_cd,
             p_ws_mgr_id              => l_ws_mgr_id,
             p_elig_flag              => NVL(l_elig_flag,'Y'),
             p_assignment_id          => l_assignment_id ,
             p_fonm_cvg_strt_dt       => l_fonm_cvg_strt_dt,
             p_inelig_rsn_cd	  => l_inelg_rsn_cd);
             --
             l_elig_per_elctbl_chc_id := l_epe_exists;
          end if;
         --
       end if;
       if l_epe_exists is null then
         ben_elig_per_elc_chc_api.create_perf_elig_per_elc_chc(
         p_elig_per_elctbl_chc_id => l_elig_per_elctbl_chc_id,
         p_business_group_id      => p_business_group_id,
         p_auto_enrt_flag         => NVL(l_rec_auto_enrt_flag,'N'),
         p_per_in_ler_id          => l_per_in_ler_id,
         p_yr_perd_id             => l_yr_perd_id,
         p_pl_id                  => l_pl_id,
         p_pl_typ_id              => l_pl_typ_id,
         p_oipl_id                => p_oipl_id,
         p_pgm_id                 => p_pgm_id,
         p_pgm_typ_cd             => l_pgm_rec.pgm_typ_cd,
         p_must_enrl_anthr_pl_id  => l_must_enrl_anthr_pl_id,
         p_plip_id                => l_plip_id,
         p_ptip_id                => l_ptip_id,
         p_prtt_enrt_rslt_id      => l_prtt_enrt_rslt_id,
         p_enrt_typ_cycl_cd       => l_rec_enrt_typ_cycl_cd,
         p_comp_lvl_cd            => l_comp_lvl_cd,
         p_enrt_cvg_strt_dt_cd    => l_rec_enrt_cvg_strt_dt_cd,
         p_enrt_perd_end_dt       => l_rec_enrt_perd_end_dt,
         p_enrt_perd_strt_dt      => l_rec_enrt_perd_strt_dt,
         p_enrt_cvg_strt_dt_rl    => l_rec_enrt_cvg_strt_dt_rl,
         p_roll_crs_flag          => 'N',
         p_ctfn_rqd_flag          => NVL(l_ctfn_rqd_flag,'N'),
         p_crntly_enrd_flag       => NVL(l_rec_crntly_enrd_flag,'N'),
         p_dflt_flag              => NVL(l_dflt_flag,'N'),
         p_elctbl_flag            => NVL(l_rec_elctbl_flag,'N'),
         p_mndtry_flag            => NVL(l_rec_mndtry_flag,'N'),
         p_dflt_enrt_dt           => l_rec_dflt_asnmt_dt,
         p_dpnt_cvg_strt_dt_cd    => NULL,
         p_dpnt_cvg_strt_dt_rl    => NULL,
         p_enrt_cvg_strt_dt       => l_rec_enrt_cvg_strt_dt,
         p_alws_dpnt_dsgn_flag    => 'N',
         p_erlst_deenrt_dt        => l_rec_erlst_deenrt_dt,
         p_procg_end_dt           => l_rec_procg_end_dt,
         p_pl_ordr_num            => l_plan_rec.ordr_num,
         p_plip_ordr_num          => l_plip_ordr_num,
         p_ptip_ordr_num          => l_ptip_ordr_num,
         p_oipl_ordr_num          => l_oipl_rec.ordr_num,
         p_object_version_number  => l_object_version_number,
         p_effective_date         => p_effective_date,
         p_program_application_id => fnd_global.prog_appl_id,
         p_program_id             => fnd_global.conc_program_id,
         p_request_id             => fnd_global.conc_request_id,
         p_program_update_date    => SYSDATE,
         p_enrt_perd_id           => l_rec_enrt_perd_id,
         p_lee_rsn_id             => l_rec_lee_rsn_id,
         p_cls_enrt_dt_to_use_cd  => l_rec_cls_enrt_dt_to_use_cd,
         p_uom                    => l_rec_uom,
         p_acty_ref_perd_cd       => l_rec_acty_ref_perd_cd,
         p_cryfwd_elig_dpnt_cd    => l_reinstt_cd,
         -- added for cwb
         p_ws_mgr_id              => l_ws_mgr_id,
         p_elig_flag              => NVL(l_elig_flag,'Y'),
         p_assignment_id          => l_assignment_id ,
         p_fonm_cvg_strt_dt       => l_fonm_cvg_strt_dt,
         p_inelig_rsn_cd	  => l_inelg_rsn_cd); -- 2650247

      if g_debug then
         hr_utility.set_location('Done EPEC_CRE: ' || l_proc, 10);
      end if;
       end if;
    --
    -- As part GLOBALCWB populating data into heirachy table
    -- is moved to per in ler table
    --
/*
       --
       -- CWBITEM : Code moved to beepeapi.pkb
       --
    if p_run_mode = 'W' and l_elig_per_elctbl_chc_id is not null then

       --
       -- Populate the heirarchy table.
       --
       --
       open c_hrchy(l_elig_per_elctbl_chc_id);
       fetch c_hrchy into l_emp_pel_id, l_pel_id;
       --
       if l_pel_id is not null and l_emp_pel_id is null then
          --
          insert into ben_cwb_hrchy (
             emp_pil_elctbl_chc_popl_id,
             mgr_pil_elctbl_chc_popl_id,
             lvl_num  )
          values(
             l_pel_id,
             -1,
             -1);
          --
       end if;
       --
       close c_hrchy;
       --
    end if;
*/
    --
    p_elig_per_elctbl_chc_id :=   l_elig_per_elctbl_chc_id;
    --
    g_rec.person_id :=            p_person_id;
    g_rec.pgm_id :=               p_pgm_id;
    g_rec.pl_id :=                p_pl_id;
    g_rec.oipl_id :=              p_oipl_id;
    g_rec.enrt_cvg_strt_dt :=     l_rec_enrt_cvg_strt_dt;
    g_rec.enrt_perd_strt_dt :=    l_rec_enrt_perd_strt_dt;
    g_rec.enrt_perd_end_dt :=     l_rec_enrt_perd_end_dt;
    g_rec.erlst_deenrt_dt :=      l_rec_erlst_deenrt_dt;
    g_rec.dflt_enrt_dt :=         l_rec_dflt_asnmt_dt;
    g_rec.enrt_typ_cycl_cd :=     l_rec_enrt_typ_cycl_cd;
    g_rec.comp_lvl_cd :=          l_comp_lvl_cd;
    g_rec.mndtry_flag :=          l_rec_mndtry_flag;
    g_rec.dflt_flag :=            l_dflt_flag;
    g_rec.business_group_id :=    p_business_group_id;
    g_rec.effective_date :=       p_effective_date;
    --
    benutils.write(p_rec => g_rec);
    if g_debug then
    hr_utility.set_location('FND mess: ' || l_proc, 10);
    end if;
    --
    fnd_message.set_name('BEN', 'BEN_91736_EPE_CHC_CREATED');
    fnd_message.set_token('PERSON_ID', p_person_id);
    fnd_message.set_token('LER_NAME', l_ler_name);
    fnd_message.set_token('COMP_LVL_CD', l_comp_lvl_cd);
    fnd_message.set_token('PLAN_NAME', l_pl_name);
    fnd_message.set_token('OIPL_NAME', l_oipl_name);
    --
    if g_debug then
    hr_utility.set_location('Dn FND mess: ' || l_proc, 10);
    end if;
    benutils.write(p_text => SUBSTR(fnd_message.get, 1, 128));
    --
    -- if choice is created for an oipl create one for plan it belongs to
    -- first find out if it already exists.
    --
    if g_debug then
    hr_utility.set_location('(p_oipl_id NN): ' || l_proc, 10);
    end if;
    IF (p_oipl_id IS NOT NULL) THEN
      --
      OPEN c_choice_exists_for_plan(l_pl_id);
      --
      FETCH c_choice_exists_for_plan INTO l_choice_exists_flag;
      --
      IF c_choice_exists_for_plan%NOTFOUND  or p_run_mode not in ('U','R') THEN
        --
        OPEN c_current_elig_for_plan;
        --
        FETCH c_current_elig_for_plan INTO l_elig_per_id,
                                           l_current_eligibility,
                                           l_must_enrl_anthr_pl_id,
                                           l_prtn_strt_dt,
                                           l_inelg_rsn_cd; -- 2650247
        --
        IF c_current_elig_for_plan%NOTFOUND THEN
          --
          l_current_eligibility :=  'N';
        --
        END IF;
        --
        CLOSE c_current_elig_for_plan;
      --
      END IF;
      --
      if g_debug then
      hr_utility.set_location('CREL=Y ' || l_proc, 10);
      end if;
      -- IF    ( c_choice_exists_for_plan%NOTFOUND or p_run_mode not in ('U','R')) /* Bug 4023880 : Commented */
      IF    ( c_choice_exists_for_plan%NOTFOUND  or l_plan_rec.svgs_pl_flag = 'Y') -- Bug 4717052 added or
         AND l_current_eligibility = 'Y' THEN
        --
--  if the plan is savings , as it is electable even if the plan is having options, check for any previous
--  enrollment
        --
        if l_plan_rec.svgs_pl_flag = 'Y' then
	   --
	   --8399189
           OPEN c_plan_enrolment_info(l_lf_evt_ocrd_dt_1,p_run_mode);

           --
           FETCH c_plan_enrolment_info INTO l_crnt_enrt_cvg_strt_dt,
                                       l_crnt_erlst_deenrt_dt,
                                       l_prtt_enrt_rslt_id,
                                       l_enrt_ovridn_flag,
                                       l_enrt_ovrid_thru_dt,
                                       l_orgnl_enrt_dt,
                                       l_crnt_enrt_cvg_thru_dt,    --BUG 6519487 fix
                                       l_current_pl_typ_id ;   --BUG 6519487 fix
          if c_plan_enrolment_info%found then
             l_prtt_enrt_rslt_id_2 := l_prtt_enrt_rslt_id;
          end if;
          --
          CLOSE c_plan_enrolment_info;
          --
        end if;
        --
        l_epe_exists := null;
        if p_run_mode in ('U','R') then
	if g_debug then
          hr_utility.set_location('before epe exists',11);
        end if;
         --
         l_epe_exists :=  ben_manage_unres_life_events.epe_exists
                  (p_per_in_ler_id => l_per_in_ler_id,
                   p_pgm_id => p_pgm_id,
                   p_pl_id  => l_pl_id,
                   p_oipl_id =>-1);
         if l_epe_exists is not null or (l_plan_rec.svgs_pl_flag = 'Y' and -- Bug 4717052 added or
                                          (--l_prtt_enrt_rslt_id_2 is not null or - bug 5035423
                                          c_choice_exists_for_plan%FOUND) )
          then
         --
         -- Bug 4717052, epe_exists will get from the global plsql table g_unrest_epe_instance
         -- which was populated during reuse of PIL,
         -- If its the new PIL, epe_exists will b null, but if exists in the DB,
         -- then just update it.
         -- for savings plan: PLAN epe shd be updated with pen_id
         --
            ben_manage_unres_life_events.update_elig_per_elctbl_choice
            (p_elig_per_elctbl_chc_id => nvl(l_epe_exists,l_choice_exists_flag),
             p_business_group_id      => p_business_group_id,
             p_auto_enrt_flag         => 'N',
             p_per_in_ler_id          => l_per_in_ler_id,
             p_yr_perd_id             => l_yr_perd_id,
             p_pl_id                  => l_pl_id,
             p_pl_typ_id              => l_pl_typ_id,
             p_oipl_id                => NULL,               -- this is the kicker
             p_pgm_id                 => p_pgm_id,
             p_pgm_typ_cd             => l_pgm_rec.pgm_typ_cd,
             p_must_enrl_anthr_pl_id  => NULL,
             p_plip_id                => l_plip_id,
             p_ptip_id                => l_ptip_id,
             p_prtt_enrt_rslt_id      => l_prtt_enrt_rslt_id_2,  -- NULL was before
             p_comp_lvl_cd            => 'PLAN',
             p_enrt_cvg_strt_dt_cd    => l_rec_enrt_cvg_strt_dt_cd,
             p_enrt_perd_end_dt       => l_rec_enrt_perd_end_dt,
             p_enrt_perd_strt_dt      => l_rec_enrt_perd_strt_dt,
             p_enrt_cvg_strt_dt_rl    => l_rec_enrt_cvg_strt_dt_rl,
             p_roll_crs_flag          => 'N',
             p_ctfn_rqd_flag          => NVL(l_ctfn_rqd_flag,'N'),
             p_crntly_enrd_flag       => 'N',
             p_dflt_flag              => 'N',
             p_elctbl_flag            => 'N',
             p_mndtry_flag            => NVL(l_rec_mndtry_flag,'N'),
             p_dflt_enrt_dt           => NULL,
             p_dpnt_cvg_strt_dt_cd    => NULL,
             p_dpnt_cvg_strt_dt_rl    => NULL,
             p_enrt_cvg_strt_dt       => l_rec_enrt_cvg_strt_dt,
             p_alws_dpnt_dsgn_flag    => 'N',
             p_erlst_deenrt_dt        => l_rec_erlst_deenrt_dt,
             p_procg_end_dt           => l_rec_procg_end_dt,
             p_pl_ordr_num            => l_plan_rec.ordr_num,
             p_plip_ordr_num          => l_plip_ordr_num,
             p_ptip_ordr_num          => l_ptip_ordr_num,
             p_oipl_ordr_num          => l_oipl_rec.ordr_num,
             p_effective_date         => p_effective_date,
             p_enrt_perd_id           => l_rec_enrt_perd_id,
             p_lee_rsn_id             => l_rec_lee_rsn_id,
             p_cls_enrt_dt_to_use_cd  => l_rec_cls_enrt_dt_to_use_cd,
             p_uom                    => l_rec_uom,
             p_acty_ref_perd_cd       => l_rec_acty_ref_perd_cd,
             p_cryfwd_elig_dpnt_cd    => l_reinstt_cd,
             p_fonm_cvg_strt_dt       => l_fonm_cvg_strt_dt,
             p_inelig_rsn_cd          => l_inelg_rsn_cd);
             --
             l_elig_per_elctbl_chc_id := nvl(l_epe_exists,l_choice_exists_flag);
          end if;
          --
        end if;
        --
        if l_epe_exists is null and c_choice_exists_for_plan%NOTFOUND then
            -- Bug4717052, added choices_exists_for_plan not found
             ben_elig_per_elc_chc_api.create_perf_elig_per_elc_chc(
             p_elig_per_elctbl_chc_id => l_elig_per_elctbl_chc_id,
             p_business_group_id      => p_business_group_id,
             p_auto_enrt_flag         => 'N',
             p_per_in_ler_id          => l_per_in_ler_id,
             p_yr_perd_id             => l_yr_perd_id,
             p_pl_id                  => l_pl_id,
             p_pl_typ_id              => l_pl_typ_id,
             p_oipl_id                => NULL,               -- this is the kicker
             p_pgm_id                 => p_pgm_id,
             p_pgm_typ_cd             => l_pgm_rec.pgm_typ_cd,
             p_must_enrl_anthr_pl_id  => NULL,
             p_plip_id                => l_plip_id,
             p_ptip_id                => l_ptip_id,
             p_prtt_enrt_rslt_id      => l_prtt_enrt_rslt_id_2,  -- NULL was before
             p_enrt_typ_cycl_cd       => l_rec_enrt_typ_cycl_cd,
             p_comp_lvl_cd            => 'PLAN',
             p_enrt_cvg_strt_dt_cd    => l_rec_enrt_cvg_strt_dt_cd,
             p_enrt_perd_end_dt       => l_rec_enrt_perd_end_dt,
             p_enrt_perd_strt_dt      => l_rec_enrt_perd_strt_dt,
             p_enrt_cvg_strt_dt_rl    => l_rec_enrt_cvg_strt_dt_rl,
             p_roll_crs_flag          => 'N',
             p_ctfn_rqd_flag          => NVL(l_ctfn_rqd_flag,'N'),
             p_crntly_enrd_flag       => 'N',
             p_dflt_flag              => 'N',
             p_elctbl_flag            => 'N',
             p_mndtry_flag            => NVL(l_rec_mndtry_flag,'N'),
             p_dflt_enrt_dt           => NULL,
             p_dpnt_cvg_strt_dt_cd    => NULL,
             p_dpnt_cvg_strt_dt_rl    => NULL,
             p_enrt_cvg_strt_dt       => l_rec_enrt_cvg_strt_dt,
             p_alws_dpnt_dsgn_flag    => 'N',
             p_erlst_deenrt_dt        => l_rec_erlst_deenrt_dt,
             p_procg_end_dt           => l_rec_procg_end_dt,
             p_pl_ordr_num            => l_plan_rec.ordr_num,
             p_plip_ordr_num          => l_plip_ordr_num,
             p_ptip_ordr_num          => l_ptip_ordr_num,
             p_oipl_ordr_num          => l_oipl_rec.ordr_num,
             p_object_version_number  => l_object_version_number,
             p_effective_date         => p_effective_date,
             p_program_application_id => fnd_global.prog_appl_id,
             p_program_id             => fnd_global.conc_program_id,
             p_request_id             => fnd_global.conc_request_id,
             p_program_update_date    => SYSDATE,
             p_enrt_perd_id           => l_rec_enrt_perd_id,
             p_lee_rsn_id             => l_rec_lee_rsn_id,
             p_cls_enrt_dt_to_use_cd  => l_rec_cls_enrt_dt_to_use_cd,
             p_uom                    => l_rec_uom,
             p_acty_ref_perd_cd       => l_rec_acty_ref_perd_cd,
             p_cryfwd_elig_dpnt_cd    => l_reinstt_cd,
             p_fonm_cvg_strt_dt       => l_fonm_cvg_strt_dt,
             p_inelig_rsn_cd	   => l_inelg_rsn_cd); -- 2650247
	     if g_debug then
             hr_utility.set_location('Done EPEC_CRE1: ' || l_proc, 10);
	     end if;
             --
        end if;
        --
        g_rec.person_id :=          p_person_id;
        g_rec.pgm_id :=             p_pgm_id;
        g_rec.pl_id :=              l_pl_id;
        g_rec.oipl_id :=            NULL;
        g_rec.enrt_cvg_strt_dt :=   l_rec_enrt_cvg_strt_dt;
        g_rec.enrt_perd_strt_dt :=  l_rec_enrt_perd_strt_dt;
        g_rec.enrt_perd_end_dt :=   l_rec_enrt_perd_end_dt;
        g_rec.erlst_deenrt_dt :=    l_rec_erlst_deenrt_dt;
        g_rec.dflt_enrt_dt :=       NULL;
        g_rec.enrt_typ_cycl_cd :=   l_rec_enrt_typ_cycl_cd;
        g_rec.comp_lvl_cd :=        'PLAN';
        g_rec.mndtry_flag :=        l_rec_mndtry_flag;
        g_rec.dflt_flag :=          'N';
        g_rec.business_group_id :=  p_business_group_id;
        g_rec.effective_date :=     p_effective_date;
        --
        benutils.write(p_rec => g_rec);
        --
	if g_debug then
        hr_utility.set_location('FND Mess: ' || l_proc, 10);
	end if;
        fnd_message.set_name('BEN', 'BEN_91736_EPE_CHC_CREATED');
        fnd_message.set_token('PERSON_ID', p_person_id);
        fnd_message.set_token('LER_NAME', l_ler_name);
        fnd_message.set_token('COMP_LVL_CD', l_comp_lvl_cd);
        fnd_message.set_token('PLAN_NAME', l_pl_name);
        fnd_message.set_token('OIPL_NAME', ' ');
	if g_debug then
        hr_utility.set_location('Dn FND Mess: ' || l_proc, 10);
	end if;
        benutils.write(p_text => SUBSTR(fnd_message.get, 1, 128));
	if g_debug then
        hr_utility.set_location('Dn FND GetMess: ' || l_proc, 10);
	end if;
      --
      END IF;                                                          -- found
      --
      CLOSE c_choice_exists_for_plan;
      if g_debug then
      hr_utility.set_location('close CEFP: ' || l_proc, 10);
      end if;
    --
    END IF;
    --
    --
    -- Set return value
    p_electable_flag := l_rec_elctbl_flag;
    --
    if g_debug then
    hr_utility.set_location(' Leaving:' || l_proc, 70);
    end if;
  --
  exception  -- nocopy changes
    --
    when others then
      --
      p_electable_flag := null;
      p_elig_per_elctbl_chc_id := null;
      raise;
      --
  END enrolment_requirements;

 PROCEDURE execute_auto_dflt_enrt_rule(
    p_opt_id            NUMBER,
    p_pl_id             NUMBER,
    p_pgm_id            NUMBER,
    p_rule_id           NUMBER,
    p_ler_id            NUMBER,
    p_pl_typ_id         NUMBER,
    p_business_group_id NUMBER,
    p_effective_date    DATE,
    p_lf_evt_ocrd_dt    DATE DEFAULT NULL,
    p_elig_per_id       NUMBER DEFAULT NULL,
    p_assignment_id     NUMBER,
    p_organization_id   NUMBER,
    p_jurisdiction_code VARCHAR2,
    p_person_id         NUMBER,               -- Bug 5331889
    p_enrt_mthd         out nocopy varchar2,
    p_reinstt_dpnt      out nocopy varchar2
    ) IS
    --
    l_package       VARCHAR2(80)      := g_package || '.execute_auto_dflt_enrt_rule';
    l_outputs       ff_exec.outputs_t;
    --
    l_param1        VARCHAR2(30);
    l_param1_value  VARCHAR2(30);
    l_param2        VARCHAR2(30);
    l_param2_value  VARCHAR2(30);
    l_param3        VARCHAR2(30);
    l_param3_value  VARCHAR2(30);
    l_param4        VARCHAR2(30);
    l_param4_value  VARCHAR2(30);
    l_param5        VARCHAR2(30);
    l_param5_value  VARCHAR2(30);
    l_param6        VARCHAR2(30);
    l_param6_value  VARCHAR2(30);
    l_param7        VARCHAR2(30);
    l_param7_value  VARCHAR2(30);
    l_param8        VARCHAR2(30);
    l_param8_value  VARCHAR2(30);
    l_param9        VARCHAR2(30);
    l_param9_value  VARCHAR2(30);
    l_param10       VARCHAR2(30);
    l_param10_value VARCHAR2(30);
    l_param11       VARCHAR2(30);
    l_param11_value VARCHAR2(30);
    l_param12       VARCHAR2(30);
    l_param12_value VARCHAR2(30);
    l_param13       VARCHAR2(30);
    l_param13_value VARCHAR2(30);
    l_param14       VARCHAR2(30);
    l_param14_value VARCHAR2(30);
    l_param15       VARCHAR2(30);
    l_param15_value VARCHAR2(30);
    l_param16       VARCHAR2(30);
    l_param16_value VARCHAR2(30);
    l_param17       VARCHAR2(30);
    l_param17_value VARCHAR2(30);
    l_param18       VARCHAR2(30);
    l_param18_value VARCHAR2(30);
    l_param19       VARCHAR2(30);
    l_param19_value VARCHAR2(30);
    l_param20       VARCHAR2(30);
    l_param20_value VARCHAR2(30);
    l_num_elig_dpnt NUMBER;
    l_prev_prtt_enrt_rslt_id  VARCHAR2(30);
  --
  BEGIN
    --
    g_debug := hr_utility.debug_enabled;
    if g_debug then
    hr_utility.set_location('Entering ' || l_package, 10);
    end if;
    --
    IF p_rule_id IS NULL THEN
      --
      p_enrt_mthd := 'Y';
      p_reinstt_dpnt := 'CFWP';
    --
    END IF;
    --
    if g_debug then
    hr_utility.set_location(
      'Organization_id ' || TO_CHAR(p_organization_id),
      10);
    hr_utility.set_location('assignment_id ' || TO_CHAR(p_assignment_id), 15);
    hr_utility.set_location(
      'Business_group_id ' || TO_CHAR(p_business_group_id),
      20);
    hr_utility.set_location('pgm_id ' || TO_CHAR(p_pgm_id), 30);
    hr_utility.set_location('pl_id ' || TO_CHAR(p_pl_id), 40);
    hr_utility.set_location('pl_typ_id ' || TO_CHAR(p_pl_typ_id), 50);
    hr_utility.set_location('opt_id ' || TO_CHAR(p_opt_id), 60);
    hr_utility.set_location('ler_id ' || TO_CHAR(p_ler_id), 70);
    end if;
    --
    -- Task 131 :If elig dependent rows are already crteated then
    -- pass the elig dependent id as input values to
    -- rule.
    --
    l_num_elig_dpnt :=
                      NVL(ben_determine_dpnt_eligibility.g_egd_table.LAST, 0);
    --
    IF NVL(ben_determine_dpnt_eligibility.g_egd_table.LAST, 0) > 0 THEN
      FOR l_curr_count IN
        ben_determine_dpnt_eligibility.g_egd_table.FIRST .. ben_determine_dpnt_eligibility.g_egd_table.LAST LOOP
        --
        -- Currently we are passing only 20 input values.
        -- Only 20 elig_dpnt_id are passed as input values.
        --
        EXIT WHEN l_curr_count > 20;
        --
        -- Update the egd row with electable choice id.
        --
        IF l_curr_count = 1 THEN
          l_param1 :=        'ELIG_DPNT_ID1';
          l_param1_value :=
           TO_CHAR(
             ben_determine_dpnt_eligibility.g_egd_table(l_curr_count).elig_dpnt_id);
        ELSIF l_curr_count = 2 THEN
          l_param2 :=        'ELIG_DPNT_ID2';
          l_param2_value :=
           TO_CHAR(
             ben_determine_dpnt_eligibility.g_egd_table(l_curr_count).elig_dpnt_id);
        ELSIF l_curr_count = 3 THEN
          l_param3 :=        'ELIG_DPNT_ID3';
          l_param3_value :=
           TO_CHAR(
             ben_determine_dpnt_eligibility.g_egd_table(l_curr_count).elig_dpnt_id);
        ELSIF l_curr_count = 4 THEN
          l_param4 :=        'ELIG_DPNT_ID4';
          l_param4_value :=
           TO_CHAR(
             ben_determine_dpnt_eligibility.g_egd_table(l_curr_count).elig_dpnt_id);
        ELSIF l_curr_count = 5 THEN
           l_param5 :=        'ELIG_DPNT_ID5';
          l_param5_value :=
           TO_CHAR(
             ben_determine_dpnt_eligibility.g_egd_table(l_curr_count).elig_dpnt_id);
        ELSIF l_curr_count = 6 THEN
          l_param6 :=        'ELIG_DPNT_ID6';
          l_param6_value :=
           TO_CHAR(
             ben_determine_dpnt_eligibility.g_egd_table(l_curr_count).elig_dpnt_id);
        ELSIF l_curr_count = 7 THEN
          l_param7 :=        'ELIG_DPNT_ID7';
          l_param7_value :=
           TO_CHAR(
             ben_determine_dpnt_eligibility.g_egd_table(l_curr_count).elig_dpnt_id);
        ELSIF l_curr_count = 8 THEN
          l_param8 :=        'ELIG_DPNT_ID8';
          l_param8_value :=
           TO_CHAR(
             ben_determine_dpnt_eligibility.g_egd_table(l_curr_count).elig_dpnt_id);
        ELSIF l_curr_count = 9 THEN
          l_param9 :=        'ELIG_DPNT_ID9';
          l_param9_value :=
           TO_CHAR(
             ben_determine_dpnt_eligibility.g_egd_table(l_curr_count).elig_dpnt_id);
        ELSIF l_curr_count = 10 THEN
          l_param10 :=        'ELIG_DPNT_ID10';
          l_param10_value :=
            TO_CHAR(
             ben_determine_dpnt_eligibility.g_egd_table(l_curr_count).elig_dpnt_id);
        ELSIF l_curr_count = 11 THEN
          l_param11 :=        'ELIG_DPNT_ID11';
          l_param11_value :=
           TO_CHAR(
             ben_determine_dpnt_eligibility.g_egd_table(l_curr_count).elig_dpnt_id);
        ELSIF l_curr_count = 12 THEN
          l_param12 :=        'ELIG_DPNT_ID12';
          l_param12_value :=
           TO_CHAR(
             ben_determine_dpnt_eligibility.g_egd_table(l_curr_count).elig_dpnt_id);
        ELSIF l_curr_count = 13 THEN
          l_param13 :=        'ELIG_DPNT_ID13';
          l_param13_value :=
           TO_CHAR(
             ben_determine_dpnt_eligibility.g_egd_table(l_curr_count).elig_dpnt_id);
        ELSIF l_curr_count = 14 THEN
          l_param14 :=        'ELIG_DPNT_ID14';
          l_param14_value :=
           TO_CHAR(
             ben_determine_dpnt_eligibility.g_egd_table(l_curr_count).elig_dpnt_id);
        ELSIF l_curr_count = 15 THEN
          l_param15 :=        'ELIG_DPNT_ID15';
          l_param15_value :=
           TO_CHAR(
             ben_determine_dpnt_eligibility.g_egd_table(l_curr_count).elig_dpnt_id);
        ELSIF l_curr_count = 16 THEN
           l_param16 :=        'ELIG_DPNT_ID16';
          l_param16_value :=
           TO_CHAR(
             ben_determine_dpnt_eligibility.g_egd_table(l_curr_count).elig_dpnt_id);
        ELSIF l_curr_count = 17 THEN
          l_param17 :=        'ELIG_DPNT_ID17';
          l_param17_value :=
           TO_CHAR(
             ben_determine_dpnt_eligibility.g_egd_table(l_curr_count).elig_dpnt_id);
        ELSIF l_curr_count = 18 THEN
          l_param18 :=        'ELIG_DPNT_ID18';
          l_param18_value :=
           TO_CHAR(
             ben_determine_dpnt_eligibility.g_egd_table(l_curr_count).elig_dpnt_id);
        ELSIF l_curr_count = 19 THEN
          l_param19 :=        'ELIG_DPNT_ID19';
          l_param19_value :=
           TO_CHAR(
             ben_determine_dpnt_eligibility.g_egd_table(l_curr_count).elig_dpnt_id);
        ELSIF l_curr_count = 20 THEN
          l_param20 :=        'ELIG_DPNT_ID20';
          l_param20_value :=
           TO_CHAR(
             ben_determine_dpnt_eligibility.g_egd_table(l_curr_count).elig_dpnt_id);
        END IF;
      --
      END LOOP;
    --
    END IF;
    --
    if g_debug then
    hr_utility.set_location(' Fire Rule ' || l_package, 10);
    end if;
    l_outputs :=
     benutils.formula(
       p_opt_id            => p_opt_id,
       p_pl_id             => p_pl_id,
       p_pgm_id            => p_pgm_id,
       p_formula_id        => p_rule_id,
       p_ler_id            => p_ler_id,
       p_elig_per_id       => p_elig_per_id,
       p_pl_typ_id         => p_pl_typ_id,
       p_assignment_id     => p_assignment_id,
       p_business_group_id => p_business_group_id,
       p_organization_id   => p_organization_id,
       p_jurisdiction_code => p_jurisdiction_code,
       p_effective_date    => NVL(p_lf_evt_ocrd_dt, p_effective_date),
       p_param1            => l_param1,
       p_param1_value      => l_param1_value,
       p_param2            => l_param2,
       p_param2_value      => l_param2_value,
       p_param3            => l_param3,
       p_param3_value      => l_param3_value,
       p_param4            => l_param4,
       p_param4_value      => l_param4_value,
       p_param5            => l_param5,
       p_param5_value      => l_param5_value,
       p_param6            => l_param6,
       p_param6_value      => l_param6_value,
       p_param7            => l_param7,
       p_param7_value      => l_param7_value,
       p_param8            => l_param8,
       p_param8_value      => l_param8_value,
       p_param9            => l_param9,
       p_param9_value      => l_param9_value,
       p_param10           => l_param10,
       p_param10_value     => l_param10_value,
       p_param11           => l_param11,
       p_param11_value     => l_param11_value,
       p_param12           => l_param12,
       p_param12_value     => l_param12_value,
       p_param13           => l_param13,
       p_param13_value     => l_param13_value,
       p_param14           => l_param14,
       p_param14_value     => l_param14_value,
       p_param15           => l_param15,
       p_param15_value     => l_param15_value,
       p_param16           => l_param16,
       p_param16_value     => l_param16_value,
       p_param17           => l_param17,
       p_param17_value     => l_param17_value,
       p_param18           => l_param18,
       p_param18_value     => l_param18_value,
       p_param19           => l_param19,
       p_param19_value     => l_param19_value,
       p_param20           => l_param20,
       p_param20_value     => l_param20_value,
       p_param21           => 'NUM_ELIG_DPNT',
       p_param21_value     => TO_CHAR(l_num_elig_dpnt),
       p_param22           => 'BEN_IV_PERSON_ID',            -- Bug 5331889 : Added person_id param as well
       p_param22_value     => to_char(p_person_id));
  if g_debug then
    hr_utility.set_location(' Dn Fire Rule ' || l_package, 10);
  end if;
    --
  for l_count in l_outputs.first..l_outputs.last loop
   begin
        --
        if l_outputs(l_count).name = 'AUTO_DFLT_VAL' then
           p_enrt_mthd := l_outputs(l_count).VALUE;
        elsif l_outputs(l_count).name = 'CARRY_FORWARD_ELIG_DPNT' then
           p_reinstt_dpnt := l_outputs(l_count).VALUE;
        elsif l_outputs(l_count).name = 'AUTO_DFLT_ELCN_VAL' then
           g_dflt_elcn_val := l_outputs(l_count).VALUE;
	   if g_debug then
           hr_utility.set_location ('formula default='||g_dflt_elcn_val,744);
           hr_utility.set_location ('formula default='||p_opt_id,744);
           end if;
        elsif l_outputs(l_count).name =  'PREV_PRTT_ENRT_RSLT_ID' then
           l_prev_prtt_enrt_rslt_id   := l_outputs(l_count).VALUE ;
	   if g_debug then
           hr_utility.set_location ('formula PREV_PRTT_ENRT_RSLT_ID ='||l_prev_prtt_enrt_rslt_id,744);
	   end if;

        end if;
    end;
   end loop;
   --- if the formula return the result id , concate the result with p_reinstt_dpnt  # 2685018
   if l_prev_prtt_enrt_rslt_id is not null then
      p_reinstt_dpnt := nvl(p_reinstt_dpnt,'') ||'^'||l_prev_prtt_enrt_rslt_id ;
   end if ;

  --
  if g_debug then
    hr_utility.set_location(' Leaving ' || l_package, 10);
  end if;

  exception  -- nocopy changes
    --
    when others then
      --
      p_enrt_mthd := null;
      p_reinstt_dpnt := null;
      raise;
      --
  END execute_auto_dflt_enrt_rule;

  FUNCTION execute_enrt_rule(
    p_opt_id            NUMBER,
    p_pl_id             NUMBER,
    p_pgm_id            NUMBER,
    p_rule_id           NUMBER,
    p_ler_id            NUMBER,
    p_pl_typ_id         NUMBER,
    p_business_group_id NUMBER,
    p_effective_date    DATE,
    p_lf_evt_ocrd_dt    DATE DEFAULT NULL,
    p_elig_per_id       NUMBER DEFAULT NULL,
    p_assignment_id     NUMBER,
    p_organization_id   NUMBER,
    p_jurisdiction_code VARCHAR2,
    p_person_id         NUMBER)         -- Bug 5331889
    RETURN VARCHAR2 IS
    --
    l_package       VARCHAR2(80)      := g_package || '.execute_enrt_rule';
    l_outputs       ff_exec.outputs_t;
    --
    l_param1        VARCHAR2(30);
    l_param1_value  VARCHAR2(30);
    l_param2        VARCHAR2(30);
    l_param2_value  VARCHAR2(30);
    l_param3        VARCHAR2(30);
    l_param3_value  VARCHAR2(30);
    l_param4        VARCHAR2(30);
    l_param4_value  VARCHAR2(30);
    l_param5        VARCHAR2(30);
    l_param5_value  VARCHAR2(30);
    l_param6        VARCHAR2(30);
    l_param6_value  VARCHAR2(30);
    l_param7        VARCHAR2(30);
    l_param7_value  VARCHAR2(30);
    l_param8        VARCHAR2(30);
    l_param8_value  VARCHAR2(30);
    l_param9        VARCHAR2(30);
    l_param9_value  VARCHAR2(30);
    l_param10       VARCHAR2(30);
    l_param10_value VARCHAR2(30);
    l_param11       VARCHAR2(30);
    l_param11_value VARCHAR2(30);
    l_param12       VARCHAR2(30);
    l_param12_value VARCHAR2(30);
    l_param13       VARCHAR2(30);
    l_param13_value VARCHAR2(30);
    l_param14       VARCHAR2(30);
    l_param14_value VARCHAR2(30);
    l_param15       VARCHAR2(30);
    l_param15_value VARCHAR2(30);
    l_param16       VARCHAR2(30);
    l_param16_value VARCHAR2(30);
    l_param17       VARCHAR2(30);
    l_param17_value VARCHAR2(30);
    l_param18       VARCHAR2(30);
    l_param18_value VARCHAR2(30);
    l_param19       VARCHAR2(30);
    l_param19_value VARCHAR2(30);
    l_param20       VARCHAR2(30);
    l_param20_value VARCHAR2(30);
    l_num_elig_dpnt NUMBER;
  --
  BEGIN
    --
   if g_debug then
    hr_utility.set_location('Entering ' || l_package, 10);
   end if;
    --
    IF p_rule_id IS NULL THEN
      --
      RETURN 'Y';
    --
    END IF;
    --
    if g_debug then
    hr_utility.set_location(
      'Organization_id ' || TO_CHAR(p_organization_id),
      10);
    hr_utility.set_location('assignment_id ' || TO_CHAR(p_assignment_id), 15);
    hr_utility.set_location(
      'Business_group_id ' || TO_CHAR(p_business_group_id),
      20);
    hr_utility.set_location('pgm_id ' || TO_CHAR(p_pgm_id), 30);
    hr_utility.set_location('pl_id ' || TO_CHAR(p_pl_id), 40);
    hr_utility.set_location('pl_typ_id ' || TO_CHAR(p_pl_typ_id), 50);
    hr_utility.set_location('opt_id ' || TO_CHAR(p_opt_id), 60);
    hr_utility.set_location('ler_id ' || TO_CHAR(p_ler_id), 70);
    end if;
    --
    -- Task 131 :If elig dependent rows are already crteated then
    -- pass the elig dependent id as input values to
    -- rule.
    --
    l_num_elig_dpnt :=
                      NVL(ben_determine_dpnt_eligibility.g_egd_table.LAST, 0);
    --
    IF NVL(ben_determine_dpnt_eligibility.g_egd_table.LAST, 0) > 0 THEN
      FOR l_curr_count IN
         ben_determine_dpnt_eligibility.g_egd_table.FIRST .. ben_determine_dpnt_eligibility.g_egd_table.LAST LOOP
        --
        -- Currently we are passing only 20 input values.
        -- Only 20 elig_dpnt_id are passed as input values.
        --
        EXIT WHEN l_curr_count > 20;
        --
        -- Update the egd row with electable choice id.
        --
        IF l_curr_count = 1 THEN
          l_param1 :=        'ELIG_DPNT_ID1';
          l_param1_value :=
           TO_CHAR(
             ben_determine_dpnt_eligibility.g_egd_table(l_curr_count).elig_dpnt_id);
        ELSIF l_curr_count = 2 THEN
          l_param2 :=        'ELIG_DPNT_ID2';
          l_param2_value :=
           TO_CHAR(
             ben_determine_dpnt_eligibility.g_egd_table(l_curr_count).elig_dpnt_id);
        ELSIF l_curr_count = 3 THEN
          l_param3 :=        'ELIG_DPNT_ID3';
          l_param3_value :=
           TO_CHAR(
             ben_determine_dpnt_eligibility.g_egd_table(l_curr_count).elig_dpnt_id);
        ELSIF l_curr_count = 4 THEN
          l_param4 :=        'ELIG_DPNT_ID4';
          l_param4_value :=
           TO_CHAR(
             ben_determine_dpnt_eligibility.g_egd_table(l_curr_count).elig_dpnt_id);
        ELSIF l_curr_count = 5 THEN
          l_param5 :=        'ELIG_DPNT_ID5';
          l_param5_value :=
           TO_CHAR(
             ben_determine_dpnt_eligibility.g_egd_table(l_curr_count).elig_dpnt_id);
        ELSIF l_curr_count = 6 THEN
          l_param6 :=        'ELIG_DPNT_ID6';
          l_param6_value :=
           TO_CHAR(
             ben_determine_dpnt_eligibility.g_egd_table(l_curr_count).elig_dpnt_id);
        ELSIF l_curr_count = 7 THEN
          l_param7 :=        'ELIG_DPNT_ID7';
          l_param7_value :=
           TO_CHAR(
             ben_determine_dpnt_eligibility.g_egd_table(l_curr_count).elig_dpnt_id);
        ELSIF l_curr_count = 8 THEN
          l_param8 :=        'ELIG_DPNT_ID8';
          l_param8_value :=
           TO_CHAR(
             ben_determine_dpnt_eligibility.g_egd_table(l_curr_count).elig_dpnt_id);
        ELSIF l_curr_count = 9 THEN
          l_param9 :=        'ELIG_DPNT_ID9';
          l_param9_value :=
           TO_CHAR(
             ben_determine_dpnt_eligibility.g_egd_table(l_curr_count).elig_dpnt_id);
        ELSIF l_curr_count = 10 THEN
          l_param10 :=        'ELIG_DPNT_ID10';
          l_param10_value :=
           TO_CHAR(
             ben_determine_dpnt_eligibility.g_egd_table(l_curr_count).elig_dpnt_id);
        ELSIF l_curr_count = 11 THEN
          l_param11 :=        'ELIG_DPNT_ID11';
          l_param11_value :=
           TO_CHAR(
             ben_determine_dpnt_eligibility.g_egd_table(l_curr_count).elig_dpnt_id);
        ELSIF l_curr_count = 12 THEN
          l_param12 :=        'ELIG_DPNT_ID12';
          l_param12_value :=
           TO_CHAR(
             ben_determine_dpnt_eligibility.g_egd_table(l_curr_count).elig_dpnt_id);
        ELSIF l_curr_count = 13 THEN
          l_param13 :=        'ELIG_DPNT_ID13';
          l_param13_value :=
           TO_CHAR(
             ben_determine_dpnt_eligibility.g_egd_table(l_curr_count).elig_dpnt_id);
        ELSIF l_curr_count = 14 THEN
          l_param14 :=        'ELIG_DPNT_ID14';
          l_param14_value :=
           TO_CHAR(
             ben_determine_dpnt_eligibility.g_egd_table(l_curr_count).elig_dpnt_id);
        ELSIF l_curr_count = 15 THEN
          l_param15 :=        'ELIG_DPNT_ID15';
          l_param15_value :=
           TO_CHAR(
             ben_determine_dpnt_eligibility.g_egd_table(l_curr_count).elig_dpnt_id);
        ELSIF l_curr_count = 16 THEN
          l_param16 :=        'ELIG_DPNT_ID16';
          l_param16_value :=
           TO_CHAR(
             ben_determine_dpnt_eligibility.g_egd_table(l_curr_count).elig_dpnt_id);
        ELSIF l_curr_count = 17 THEN
          l_param17 :=        'ELIG_DPNT_ID17';
          l_param17_value :=
           TO_CHAR(
             ben_determine_dpnt_eligibility.g_egd_table(l_curr_count).elig_dpnt_id);
        ELSIF l_curr_count = 18 THEN
          l_param18 :=        'ELIG_DPNT_ID18';
          l_param18_value :=
           TO_CHAR(
             ben_determine_dpnt_eligibility.g_egd_table(l_curr_count).elig_dpnt_id);
        ELSIF l_curr_count = 19 THEN
          l_param19 :=        'ELIG_DPNT_ID19';
          l_param19_value :=
           TO_CHAR(
             ben_determine_dpnt_eligibility.g_egd_table(l_curr_count).elig_dpnt_id);
        ELSIF l_curr_count = 20 THEN
          l_param20 :=        'ELIG_DPNT_ID20';
          l_param20_value :=
           TO_CHAR(
             ben_determine_dpnt_eligibility.g_egd_table(l_curr_count).elig_dpnt_id);
        END IF;
      --
      END LOOP;
    --
    END IF;
    --
    l_outputs :=
     benutils.formula(
       p_opt_id            => p_opt_id,
       p_pl_id             => p_pl_id,
       p_pgm_id            => p_pgm_id,
       p_formula_id        => p_rule_id,
       p_ler_id            => p_ler_id,
       p_elig_per_id       => p_elig_per_id,
       p_pl_typ_id         => p_pl_typ_id,
       p_assignment_id     => p_assignment_id,
       p_business_group_id => p_business_group_id,
       p_organization_id   => p_organization_id,
       p_jurisdiction_code => p_jurisdiction_code,
       p_effective_date    => NVL(p_lf_evt_ocrd_dt, p_effective_date),
       p_param1            => l_param1,
       p_param1_value      => l_param1_value,
       p_param2            => l_param2,
       p_param2_value      => l_param2_value,
       p_param3            => l_param3,
       p_param3_value      => l_param3_value,
       p_param4            => l_param4,
       p_param4_value      => l_param4_value,
       p_param5            => l_param5,
       p_param5_value      => l_param5_value,
       p_param6            => l_param6,
       p_param6_value      => l_param6_value,
       p_param7            => l_param7,
       p_param7_value      => l_param7_value,
       p_param8            => l_param8,
       p_param8_value      => l_param8_value,
       p_param9            => l_param9,
       p_param9_value      => l_param9_value,
       p_param10           => l_param10,
       p_param10_value     => l_param10_value,
       p_param11           => l_param11,
       p_param11_value     => l_param11_value,
       p_param12           => l_param12,
       p_param12_value     => l_param12_value,
       p_param13           => l_param13,
       p_param13_value     => l_param13_value,
       p_param14           => l_param14,
       p_param14_value     => l_param14_value,
       p_param15           => l_param15,
       p_param15_value     => l_param15_value,
       p_param16           => l_param16,
       p_param16_value     => l_param16_value,
       p_param17           => l_param17,
       p_param17_value     => l_param17_value,
       p_param18           => l_param18,
       p_param18_value     => l_param18_value,
       p_param19           => l_param19,
       p_param19_value     => l_param19_value,
       p_param20           => l_param20,
       p_param20_value     => l_param20_value,
       p_param21           => 'NUM_ELIG_DPNT',
       p_param21_value     => TO_CHAR(l_num_elig_dpnt),
       p_param22           => 'BEN_IV_PERSON_ID',            -- Bug 5331889 : Added person_id param as well
       p_param22_value     => to_char(p_person_id));
    --
    RETURN l_outputs(l_outputs.FIRST).VALUE;
  --
  END execute_enrt_rule;
--
  PROCEDURE determine_dflt_flag(
    p_dflt_flag             VARCHAR2,
    p_dflt_enrt_cd          VARCHAR2,
    p_crnt_enrt_cvg_strt_dt DATE,
    -- above is no longer used
    p_previous_eligibility  VARCHAR2,
    p_dflt_enrt_rl          NUMBER,
    p_oipl_id               NUMBER,
    p_pl_id                 NUMBER,
    p_pgm_id                NUMBER,
    p_effective_date        DATE,
    p_lf_evt_ocrd_dt        DATE DEFAULT NULL,
    p_ler_id                NUMBER,
    p_opt_id                NUMBER,
    p_pl_typ_id             NUMBER,
    p_ptip_id               NUMBER,
    p_person_id             NUMBER,
    p_business_group_id     NUMBER,
    p_assignment_id         NUMBER,
    p_deflt_flag            out nocopy VARCHAR2,
    p_reinstt_flag          out nocopy VARCHAR2,
    -- added bug 5644451
    p_default_level         VARCHAR2 default null,
    p_run_mode              varchar2 default null)   /* iRec : Added p_run_mode */
    IS
    --
    l_defer_flag           VARCHAR2(30)    := 'N';
    l_dflt_flag            VARCHAR2(30);
    l_reinstt_flag         VARCHAR2(30);
    l_next_level_enrt_flag VARCHAR2(30)    := 'N';
    l_jurisdiction_code    VARCHAR2(30);
    --
    l_lf_evt_ocrd_dt       DATE     := NVL(p_lf_evt_ocrd_dt, p_effective_date);
    l_lf_evt_ocrd_dt_1     DATE            := l_lf_evt_ocrd_dt - 1;
    l_covered_flag         varchar2(30):='N';
    --
    -- Gets the enrolment information for the plan in which the oipl belongs
    --
    --
    CURSOR c_plan_enrolment_info IS
      SELECT   'Y'
      FROM     ben_prtt_enrt_rslt_f pen
      WHERE    pen.person_id = p_person_id
      AND      pen.business_group_id = p_business_group_id
      AND      pen.prtt_enrt_rslt_stat_cd IS NULL
--      AND      pen.sspndd_flag = 'N' --CFW
      AND      (pen.sspndd_flag = 'N' --CFW
                 OR (pen.sspndd_flag = 'Y' and
                     pen.enrt_cvg_thru_dt = hr_api.g_eot
                    )
               )
      AND      pen.effective_end_date = hr_api.g_eot
      AND      l_lf_evt_ocrd_dt <= pen.enrt_cvg_thru_dt
      AND      l_lf_evt_ocrd_dt >= pen.enrt_cvg_strt_dt
      AND      pen.enrt_cvg_strt_dt < pen.effective_end_date
      AND      p_pl_id = pen.pl_id
      AND      (
                    (    pen.pgm_id = p_pgm_id
                     AND p_pgm_id IS NOT NULL)
                 OR (    pen.pgm_id IS NULL
                     AND p_pgm_id IS NULL));
    --
    -- Gets the enrolment information for this oipl
    --
    --
    CURSOR c_oipl_enrolment_info IS
      SELECT   'Y'
      FROM     ben_prtt_enrt_rslt_f pen
      WHERE    pen.person_id = p_person_id
      AND      pen.business_group_id = p_business_group_id
--      AND      pen.sspndd_flag = 'N' --CFW
      AND      (pen.sspndd_flag = 'N' --CFW
                 OR (pen.sspndd_flag = 'Y' and
                     pen.enrt_cvg_thru_dt = hr_api.g_eot
                    )
               )
      AND      pen.prtt_enrt_rslt_stat_cd IS NULL
      AND      pen.effective_end_date = hr_api.g_eot
      AND      l_lf_evt_ocrd_dt <= pen.enrt_cvg_thru_dt
      AND      l_lf_evt_ocrd_dt >= pen.enrt_cvg_strt_dt
      AND      pen.enrt_cvg_strt_dt < pen.effective_end_date
      AND      p_oipl_id = pen.oipl_id
      AND      (
                    (    pen.pgm_id = p_pgm_id
                     AND p_pgm_id IS NOT NULL)
                 OR (    pen.pgm_id IS NULL
                     AND p_pgm_id IS NULL));
    --
    -- Gets the enrolment information for the ptip in which the plan belongs
    --
    CURSOR c_ptip_enrolment_info IS
      SELECT   'Y'
      FROM     ben_prtt_enrt_rslt_f pen
      WHERE    pen.person_id = p_person_id
      AND      pen.business_group_id = p_business_group_id
      AND      pen.prtt_enrt_rslt_stat_cd IS NULL
      -- AND      pen.sspndd_flag = 'N'
      AND      (pen.sspndd_flag = 'N' --CFW
                 OR (pen.sspndd_flag = 'Y' and
                     pen.enrt_cvg_thru_dt = hr_api.g_eot
                    )
               )
      AND      pen.effective_end_date = hr_api.g_eot
      AND
               --   nvl(p_lf_evt_ocrd_dt,p_effective_date) between
               --      pen.effective_start_date and pen.effective_end_date and
               l_lf_evt_ocrd_dt <= pen.enrt_cvg_thru_dt
      AND      l_lf_evt_ocrd_dt >= pen.enrt_cvg_strt_dt
      AND      pen.enrt_cvg_strt_dt < pen.effective_end_date
      AND      p_ptip_id = pen.ptip_id;

    --
    CURSOR c_state IS
      SELECT   loc.region_2
      FROM     hr_locations_all loc, per_all_assignments_f asg
      WHERE    loc.location_id = asg.location_id
      AND      asg.person_id = p_person_id
      and      asg.assignment_type <> 'C'
      AND      asg.primary_flag = 'Y'
      AND      l_lf_evt_ocrd_dt BETWEEN asg.effective_start_date
                   AND asg.effective_end_date
      AND      asg.business_group_id = p_business_group_id;

    l_state                c_state%ROWTYPE;
    CURSOR c_asg IS
      SELECT   asg.assignment_id,
               asg.organization_id
      FROM     per_all_assignments_f asg
      WHERE    asg.person_id = p_person_id
      and      asg.assignment_type <> 'C'
      AND      asg.primary_flag = decode(p_run_mode, 'I',asg.primary_flag, 'Y')  -- iRec
      AND      l_lf_evt_ocrd_dt BETWEEN asg.effective_start_date
                   AND asg.effective_end_date;
    l_asg                  c_asg%ROWTYPE;
    l_proc                 VARCHAR2(80)   := g_package ||
                                               '.determine_dflt_flag';
  --
  BEGIN
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    hr_utility.set_location('Entering: ' || l_proc, 10);
    hr_utility.set_location('p_dflt_flag' || p_dflt_flag, 121.121);
    hr_utility.set_location('p_dflt_enrt_cd' || p_dflt_enrt_cd, 121.121);
    hr_utility.set_location('p_oipl_id' || p_oipl_id, 121.121);
    hr_utility.set_location('p_pl_id' || p_pl_id, 121.121);
    hr_utility.set_location('p_ptip_id' || p_ptip_id, 121.121);
    hr_utility.set_location('p_default_level' || p_default_level, 121.121);
  end if;

-- If the dflt_enrt_cd and enrollment status combination in the following
-- matrix is YES set the dflt_flag to Y, if it is NO set it to N,
-- if it is Flag use the dflt_flag.
--
--
-- For Plan
--                                              enrd in ptip and
-- DFLT_ENRT_CD    not enrd ptip   enrd pl      not enrd pl
---------------------------------------------------------------
-- NSDCSD          Flag            Flag         Flag
-- NSDCS           Flag            YES          NO(X)
-- NDCSEDR         Flag            YES          NO(X)
-- NNCS            NO              YES          NO
-- NNCSEDR         NO              YES          NO
-- NNCN            NO              NO           NO
-- NNCD            NO              Flag         Flag(X)
-- NDCN            Flag            NO           NO(X)
--
-- For Oipl
--                                              enrd in pl and
-- DFLT_ENRT_CD    not enrd pl     enrd oipl    not enrd oipl
---------------------------------------------------------------
-- NSDCSD          Flag            Flag         Flag
-- NSDCS           Flag            YES          NO(X)
-- NDCSEDR         Flag            YES          NO(X)
-- NNCS            NO              YES          NO
-- NNCSEDR         NO              YES          NO
-- NNCN            NO              NO           NO
-- NNCD            NO              Flag         Flag(X)
-- NDCN            Flag            NO           NO(X)
--
/*  -- 4031733 - Cursor c_state populates l_state variable which is no longer
    -- used in the package. Cursor can be commented

    IF p_person_id IS NOT NULL THEN
      OPEN c_state;
      FETCH c_state INTO l_state;
      CLOSE c_state;
      --IF l_state.region_2 IS NOT NULL THEN
      --  l_jurisdiction_code :=
      --    pay_mag_utils.lookup_jurisdiction_code(p_state => l_state.region_2);
      --END IF;
    END IF;
*/
    OPEN c_asg;
    FETCH c_asg INTO l_asg;
    IF c_asg%NOTFOUND THEN
      CLOSE c_asg;
      fnd_message.set_name('BEN', 'BEN_92106_PRTT_NO_ASGN');
      fnd_message.set_token('PROC', l_proc);
      fnd_message.set_token('PERSON_ID', TO_CHAR(p_person_id));
      fnd_message.set_token('LF_EVT_OCRD_DT', TO_CHAR(p_lf_evt_ocrd_dt));
      fnd_message.set_token('EFFECTIVE_DATE', TO_CHAR(p_effective_date));
      RAISE ben_manage_life_events.g_record_error;
    END IF;
    CLOSE c_asg;
    IF (p_oipl_id IS NULL) THEN
      --
      OPEN c_plan_enrolment_info;
      --
      FETCH c_plan_enrolment_info INTO l_covered_flag;
      --
      CLOSE c_plan_enrolment_info;
    --
    ELSE
      --
      OPEN c_oipl_enrolment_info;
      --
      FETCH c_oipl_enrolment_info INTO l_covered_flag;
      --
      CLOSE c_oipl_enrolment_info;
    --
    END IF;
    IF l_covered_flag='Y' THEN
      --
      -- enrolled in oipl/pl
      --
      IF p_dflt_enrt_cd IN ('NSDCS', 'NDCSEDR', 'NNCS', 'NNCSEDR') THEN
        l_dflt_flag :=  'Y';
      ELSIF p_dflt_enrt_cd IN ('NNCN', 'NDCN') THEN
        l_dflt_flag :=  'N';
      ELSE
        l_defer_flag :=  'Y';
      END IF;
    ELSE
      --
      -- not enrolled in oipl/pl must check for plan/ptip enrt
      -- Note: to speed processing if enrt does not matter set
      --   l_next_level_enrt_flag='Y'
      -- Note: for plans not in program don't have next level so
      --   not enrolled means not enrolled, set next level='N'
      --
      if g_debug then
      hr_utility.set_location(l_proc, 50);
      end if;
/*
      IF p_dflt_enrt_cd IN ('RL', 'NSDCSD', 'NNCS', 'NNCSEDR', 'NNCN') THEN
        l_next_level_enrt_flag :=  'Y';
      ELSIF p_oipl_id IS NOT NULL THEN
        OPEN c_plan_enrolment_info;
        FETCH c_plan_enrolment_info INTO l_next_level_enrt_flag;
        CLOSE c_plan_enrolment_info;
      ELSIF p_ptip_id IS NOT NULL THEN
        OPEN c_ptip_enrolment_info;
        FETCH c_ptip_enrolment_info INTO l_next_level_enrt_flag;
        CLOSE c_ptip_enrolment_info;
      ELSE
        l_next_level_enrt_flag :=  'N';
      END IF;
      --
*/
--bug#2080856 - need to check at ptip level if not enrolled in plan- the above code was
--skipping to check ptip level if oipl_id is not null
     IF p_dflt_enrt_cd IN ('RL', 'NSDCSD', 'NNCS', 'NNCSEDR', 'NNCN') THEN
        l_next_level_enrt_flag :=  'Y';
     ELSE
        if p_oipl_id IS NOT NULL THEN
	if g_debug then
	  hr_utility.set_location('p_oipl_id IS NOT NULL THEN',121.121);
        end if;
          OPEN c_plan_enrolment_info;
          FETCH c_plan_enrolment_info INTO l_next_level_enrt_flag;
          CLOSE c_plan_enrolment_info;
	  if g_debug then
	  hr_utility.set_location('l_next_level_enrt_flag '||nvl(l_next_level_enrt_flag,'-')|| '  ' ,121.121);
	  end if;
        end if;
        if l_next_level_enrt_flag <>'Y' then
	if g_debug then
	   hr_utility.set_location('l_next_level_enrt_flag <>Y ',121.121);
        end if;
           if  p_ptip_id IS NOT NULL THEN
	   if g_debug then
	     hr_utility.set_location('p_ptip_id IS NOT NULL  ',121.121);
	     hr_utility.set_location('Checking p_default level  ' || p_default_level,121.121);
	     end if;
           ---Reverting back the fix 5644451 for the bug 7452061
	    /* IF p_default_level IN('PTIP','LER_PTIP')
	     THEN*/
               OPEN c_ptip_enrolment_info;
                  FETCH c_ptip_enrolment_info INTO l_next_level_enrt_flag;
               CLOSE c_ptip_enrolment_info;
	    -- END IF; ---Reverting back the fix 5644451 for the bug 7452061
           ELSE
             l_next_level_enrt_flag :=  'N';
           end if;
         end if;
      END if;


      --
      IF l_next_level_enrt_flag = 'Y' THEN
        --
        -- Enrolled in plan/ptip and not oipl/plan
        --
	if g_debug then
	hr_utility.set_location('l_next_level_enrt_flag = Y 2 ',121.121);
	end if;
        IF p_dflt_enrt_cd IN (
                               'NSDCS',
                               'NDCSEDR',
                               'NNCS',
                               'NNCSEDR',
                               'NNCN',
                               'NDCN') THEN
          l_dflt_flag :=  'N';
        ELSE
          l_defer_flag :=  'Y';
        END IF;
      ELSE
        --
        -- Not enrolled in plan/ptip
        --
        IF p_dflt_enrt_cd IN ('NNCS', 'NNCSEDR', 'NNCN', 'NNCD') THEN
          l_dflt_flag :=  'N';
        ELSE
          l_defer_flag :=  'Y';
        END IF;
      END IF;
    END IF;
    --
    -- If the dflt_enrt_cd is RL then execute the rule,
    -- it will determine the value for the dflt_flag.
    --
    IF p_dflt_enrt_cd = 'RL' THEN
      --
      if g_debug then
      hr_utility.set_location(' EER ' || l_proc, 190);
      end if;
       execute_auto_dflt_enrt_rule(
         p_opt_id            => p_opt_id,
         p_pl_id             => p_pl_id,
         p_pgm_id            => p_pgm_id,
         p_rule_id           => p_dflt_enrt_rl,
         p_ler_id            => p_ler_id,
         p_pl_typ_id         => p_pl_typ_id,
         p_business_group_id => p_business_group_id,
         p_effective_date    => NVL(p_lf_evt_ocrd_dt, p_effective_date),
         p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
         p_assignment_id     => p_assignment_id,
         p_organization_id   => l_asg.organization_id,
         p_jurisdiction_code => l_jurisdiction_code,
	 p_person_id         => p_person_id,          -- Bug 5331889
         p_enrt_mthd         => l_dflt_flag,
         p_reinstt_dpnt      => l_reinstt_flag
         );
     if g_debug then
      hr_utility.set_location(' Dn EER ' || l_proc, 190);
     end if;
      --
      l_defer_flag :=  'N';
    ELSIF (    p_dflt_enrt_cd IS NULL
           AND p_dflt_flag IS NOT NULL) THEN
      --
      -- If the dflt_enrt_cd is null and the dflt_flag is not
      -- null set the dflt_flag to it's value.
      --
      l_dflt_flag :=  'N'; -- p_dflt_flag - Bug#2080856
      l_defer_flag :=  'N';
    --
    END IF;
   if g_debug then
    hr_utility.set_location(l_proc, 200);
   end if;
    --
    IF l_defer_flag = 'Y' THEN
      --
       l_dflt_flag := 'DEFER';
    --
    END IF;
    if g_debug then
    hr_utility.set_location('Leaving: ' || l_proc, 235);
    end if;
    --
    p_deflt_flag := l_dflt_flag;
    p_reinstt_flag := l_reinstt_flag;
  --
  exception  -- nocopy changes
    --
    when others then
      --
      p_deflt_flag := null;
      p_reinstt_flag := null;
      raise;
      --
  END;                                                              -- Function
--
  FUNCTION determine_erlst_deenrt_dt(
    p_enrt_cvg_strt_dt           DATE,
    p_rqd_perd_enrt_nenrt_val    NUMBER,
    p_rqd_perd_enrt_nenrt_tm_uom VARCHAR2,
    p_rqd_perd_enrt_nenrt_rl     NUMBER,
    p_oipl_id                    NUMBER,
    p_pl_id                      NUMBER,
    p_pl_typ_id                  NUMBER,
    p_opt_id                     NUMBER,
    p_pgm_id                     NUMBER,
    p_ler_id                     NUMBER,
    p_popl_yr_perd_ordr_num      NUMBER,
    p_yr_end_dt                  DATE,
    p_effective_date             DATE,
    p_lf_evt_ocrd_dt             DATE DEFAULT NULL,
    p_person_id                  NUMBER,
    p_business_group_id          NUMBER,
    p_assignment_id              NUMBER,
    p_organization_id            NUMBER,
    p_jurisdiction_code          VARCHAR2)
    RETURN DATE IS
    --
    -- local variables
    --
    l_deenrt_dt       DATE;
    l_yr_perd_id      NUMBER;
    l_popl_yr_perd_id NUMBER;
    l_start_date      DATE;
    l_end_date        DATE;
    l_outputs         ff_exec.outputs_t;
    -- Determine a future popl_yr_period
    CURSOR c_pl_popl_yr_period_future(p_order_num NUMBER) IS
      SELECT   pyp.yr_perd_id,
               pyp.popl_yr_perd_id,
               yp.start_date,
               yp.end_date
      FROM     ben_popl_yr_perd pyp, ben_yr_perd yp
      WHERE    pyp.pl_id = p_pl_id
      AND      pyp.business_group_id = p_business_group_id
      AND      pyp.ordr_num = p_popl_yr_perd_ordr_num
      AND      yp.business_group_id = p_business_group_id
      AND      pyp.yr_perd_id = yp.yr_perd_id;
  --
  BEGIN
    IF p_rqd_perd_enrt_nenrt_rl IS NOT NULL THEN
    if g_debug then
      hr_utility.set_location(
        'Organization_id ' || TO_CHAR(p_organization_id),
        10);
      hr_utility.set_location(
        'assignment_id ' || TO_CHAR(p_assignment_id),
        15);
      hr_utility.set_location(
        'Business_group_id ' || TO_CHAR(p_business_group_id),
        20);
      hr_utility.set_location('pgm_id ' || TO_CHAR(p_pgm_id), 30);
      hr_utility.set_location('pl_id ' || TO_CHAR(p_pl_id), 40);
      hr_utility.set_location('pl_typ_id ' || TO_CHAR(p_pl_typ_id), 50);
      hr_utility.set_location('opt_id ' || TO_CHAR(p_opt_id), 60);
      hr_utility.set_location('ler_id ' || TO_CHAR(p_ler_id), 70);
    end if;
      l_outputs :=
       benutils.formula(
         p_formula_id        => p_rqd_perd_enrt_nenrt_rl,
         p_effective_date    => NVL(p_lf_evt_ocrd_dt, p_effective_date),
         p_business_group_id => p_business_group_id,
         p_assignment_id     => p_assignment_id,
         p_organization_id   => p_organization_id,
         p_pl_id             => p_pl_id,
         p_pgm_id            => p_pgm_id,
         p_opt_id            => p_opt_id,
         p_pl_typ_id         => p_pl_typ_id,
         p_ler_id            => p_ler_id,
         p_jurisdiction_code => p_jurisdiction_code,
         p_param1            => 'BEN_IV_PERSON_ID',        -- Bug 5331889 : Added person_id param as well
         p_param1_value      => to_char(p_person_id));
      --
      -- Reformat Canonical Character output to be a date
      --
      l_deenrt_dt :=
                fnd_date.canonical_to_date(l_outputs(l_outputs.FIRST).VALUE);
    ELSE
      -- Code     Meaning
      -- D     Days
      -- W     Weeks
      -- M     Months
      -- PPLYRQ     Program or Plan Year Quarters
      -- Q     Quarters
      -- Y     Years
      -- PPLYR     Program or Plan Years
      IF (p_rqd_perd_enrt_nenrt_tm_uom IN ('D', 'DY')) THEN
        --
        l_deenrt_dt :=  p_enrt_cvg_strt_dt + p_rqd_perd_enrt_nenrt_val - 1;
      --
      ELSIF (p_rqd_perd_enrt_nenrt_tm_uom IN ('W', 'WK')) THEN
        --
        l_deenrt_dt :=  p_enrt_cvg_strt_dt + (p_rqd_perd_enrt_nenrt_val * 7) -
                          1;
      --
      ELSIF (p_rqd_perd_enrt_nenrt_tm_uom IN ('M', 'MO')) THEN
        --
        l_deenrt_dt :=
                 ADD_MONTHS(p_enrt_cvg_strt_dt, p_rqd_perd_enrt_nenrt_val) - 1;
      --
      ELSIF (p_rqd_perd_enrt_nenrt_tm_uom IN ('Q', 'QTR')) THEN
        --
        l_deenrt_dt :=
             ADD_MONTHS(p_enrt_cvg_strt_dt, p_rqd_perd_enrt_nenrt_val * 3) - 1;
      --
      ELSIF (p_rqd_perd_enrt_nenrt_tm_uom IN ('PPLYR')) THEN
        --
        -- program/plan years based on passed in current popl_yr_perd
        --
        IF p_rqd_perd_enrt_nenrt_val = 1 THEN
          --
          l_deenrt_dt :=  p_yr_end_dt;
        --
        ELSE
          --
          OPEN c_pl_popl_yr_period_future(
            p_popl_yr_perd_ordr_num + p_rqd_perd_enrt_nenrt_val - 1);
          --
          FETCH c_pl_popl_yr_period_future INTO l_yr_perd_id,
                                                l_popl_yr_perd_id,
                                                l_start_date,
                                                l_end_date;
          l_deenrt_dt :=  l_end_date;
          --
          CLOSE c_pl_popl_yr_period_future;
        --
        END IF;
      --
      ELSIF (p_rqd_perd_enrt_nenrt_tm_uom IN ('Y', 'YR')) THEN
        --
        l_deenrt_dt :=
               ADD_MONTHS(p_enrt_cvg_strt_dt, p_rqd_perd_enrt_nenrt_val * 12);
      --
      ELSE
        --
        l_deenrt_dt :=  NULL;
      --
      END IF;
    END IF;
    --
    RETURN l_deenrt_dt;
  --
  END;
--
  FUNCTION should_create_dpnt_dummy(
    p_pl_id             NUMBER,
    p_pl_typ_id         NUMBER,
    p_opt_id            NUMBER,
    p_ler_id            NUMBER,
    p_ptip_id           NUMBER,
    p_effective_date    DATE,
    p_lf_evt_ocrd_dt    DATE DEFAULT NULL,
    p_pgm_id            NUMBER,
    p_person_id         NUMBER,
    p_business_group_id NUMBER,
    p_assignment_id     NUMBER,
    p_organization_id   NUMBER,
    p_jurisdiction_code VARCHAR2)
    RETURN BOOLEAN IS
    l_level          NUMBER;
    l_dpnt_cvg_cd    VARCHAR2(30);
    l_dpnt_cvg_rl    NUMBER;
    l_outputs        ff_exec.outputs_t;
    --
    l_lf_evt_ocrd_dt DATE           := NVL(p_lf_evt_ocrd_dt, p_effective_date);
    -- Cursor to get the ler_chg_dpnt_f row to
    --   see if the choice needs to be created
    --   for dpnt reasons
    -- Walk up heirarchy - pl, ptip, then pgm.
    --
    CURSOR c_ler_chg_dep IS
      SELECT   '1',
               ldc.ler_chg_dpnt_cvg_cd,
               ldc.ler_chg_dpnt_cvg_rl
      FROM     ben_ler_chg_dpnt_cvg_f ldc
      WHERE    ldc.ler_id = p_ler_id
      AND      ldc.business_group_id = p_business_group_id
      AND      ldc.pl_id = p_pl_id
      AND      l_lf_evt_ocrd_dt BETWEEN ldc.effective_start_date
                   AND ldc.effective_end_date
      AND      ldc.ler_chg_dpnt_cvg_cd IS NOT NULL
      UNION ALL
      SELECT   '2',
               ldc.ler_chg_dpnt_cvg_cd,
               ldc.ler_chg_dpnt_cvg_rl
      FROM     ben_ler_chg_dpnt_cvg_f ldc
      WHERE    ldc.ler_id = p_ler_id
      AND      ldc.business_group_id = p_business_group_id
      AND      ldc.ptip_id = p_ptip_id
      AND      l_lf_evt_ocrd_dt BETWEEN ldc.effective_start_date
                   AND ldc.effective_end_date
      AND      ldc.ler_chg_dpnt_cvg_cd IS NOT NULL
      UNION ALL
      SELECT   '3',
               ldc.ler_chg_dpnt_cvg_cd,
               ldc.ler_chg_dpnt_cvg_rl
      FROM     ben_ler_chg_dpnt_cvg_f ldc
      WHERE    ldc.ler_id = p_ler_id
      AND      ldc.business_group_id = p_business_group_id
      AND      ldc.pgm_id = p_pgm_id
      AND      l_lf_evt_ocrd_dt BETWEEN ldc.effective_start_date
                   AND ldc.effective_end_date
      AND      ldc.ler_chg_dpnt_cvg_cd IS NOT NULL;
  BEGIN
    OPEN c_ler_chg_dep;
    FETCH c_ler_chg_dep INTO l_level, l_dpnt_cvg_cd, l_dpnt_cvg_rl;
    IF c_ler_chg_dep%NOTFOUND THEN
      RETURN FALSE;
    ELSE
      IF l_dpnt_cvg_cd = 'RL' THEN
        -- Evaluate the rule
      if g_debug then
        hr_utility.set_location(
          'Organization_id ' || TO_CHAR(p_organization_id),
          10);
        hr_utility.set_location(
          'assignment_id ' || TO_CHAR(p_assignment_id),
          15);
        hr_utility.set_location(
          'Business_group_id ' || TO_CHAR(p_business_group_id),
          20);
        hr_utility.set_location('pgm_id ' || TO_CHAR(p_pgm_id), 30);
        hr_utility.set_location('pl_id ' || TO_CHAR(p_pl_id), 40);
        hr_utility.set_location('pl_typ_id ' || TO_CHAR(p_pl_typ_id), 50);
        hr_utility.set_location('opt_id ' || TO_CHAR(p_opt_id), 60);
        hr_utility.set_location('ler_id ' || TO_CHAR(p_ler_id), 70);
      end if;
        l_outputs :=
         benutils.formula(
           p_formula_id        => l_dpnt_cvg_rl,
           p_effective_date    => NVL(p_lf_evt_ocrd_dt, p_effective_date),
           p_business_group_id => p_business_group_id,
           p_assignment_id     => p_assignment_id,
           p_organization_id   => p_organization_id,
           p_pl_id             => p_pl_id,
           p_pgm_id            => p_pgm_id,
           p_opt_id            => p_opt_id,
           p_pl_typ_id         => p_pl_typ_id,
           p_ler_id            => p_ler_id,
           p_jurisdiction_code => p_jurisdiction_code);
        l_dpnt_cvg_cd :=  l_outputs(l_outputs.FIRST).VALUE;
      END IF;
      --
      -- For MNANRD (May not add nor removed dependents)
      -- don't need choice, all other codes do need it.
      --
      IF l_dpnt_cvg_cd = 'MNANRD' THEN
        RETURN FALSE;
      END IF;
    END IF;
    CLOSE c_ler_chg_dep;
    RETURN TRUE;
  END;
--
procedure determine_dflt_enrt_cd
  (p_oipl_id           in     number
  ,p_plip_id           in     number
  ,p_pl_id             in     number
  ,p_ptip_id           in     number
  ,p_pgm_id            in     number
  ,p_ler_id            in     number
  ,p_business_group_id in     number
  ,p_effective_date    in     date
  ,p_dflt_enrt_cd         out nocopy varchar2
  ,p_dflt_enrt_rl         out nocopy number
  )
IS
    --
    -- NOTE:
    --
    --   This procedure is also callable from other RCOs
    --   Please do not remove get_object calls since they
    --   may be needed if not called from bendenrr.
    --
    l_proc         VARCHAR2(80)       := g_package || '.determine_dflt_enrt_cd';
    --
    CURSOR c_ler_oipl_dflt_cd IS
      SELECT   leo.dflt_enrt_cd,
               leo.dflt_enrt_rl
      FROM     ben_ler_chg_oipl_enrt_f leo
      WHERE    p_oipl_id = leo.oipl_id
      AND      p_ler_id = leo.ler_id
      AND      p_effective_date BETWEEN leo.effective_start_date
                   AND leo.effective_end_date;
    --
    -- Use cache for oipl, don't need cursor
    --
    CURSOR c_ler_pl_nip_dflt_cd IS
      SELECT   len.dflt_enrt_cd,
               len.dflt_enrt_rl
      FROM     ben_ler_chg_pl_nip_enrt_f len
      WHERE    p_pl_id = len.pl_id
      AND      p_ler_id = len.ler_id
      AND      p_effective_date BETWEEN len.effective_start_date
                   AND len.effective_end_date;
    --
    CURSOR c_ler_plip_dflt_cd IS
      SELECT   lep.dflt_enrt_cd,
               lep.dflt_enrt_rl
      FROM     ben_ler_chg_plip_enrt_f lep
      WHERE    p_plip_id = lep.plip_id
      AND      p_ler_id = lep.ler_id
      AND      p_effective_date BETWEEN lep.effective_start_date
                   AND lep.effective_end_date;
    --
    CURSOR c_ler_ptip_dflt_cd IS
      SELECT   lep.dflt_enrt_cd,
               lep.dflt_enrt_rl
      FROM     ben_ler_chg_ptip_enrt_f lep
      WHERE    p_ptip_id = lep.ptip_id
      AND      p_ler_id = lep.ler_id
      AND      p_effective_date BETWEEN lep.effective_start_date
                   AND lep.effective_end_date;
    --
    CURSOR c_ler_pgm_dflt_cd IS
      SELECT   lep.dflt_enrt_cd,
               lep.dflt_enrt_rl
      FROM     ben_ler_chg_pgm_enrt_f lep
      WHERE    p_pgm_id = lep.pgm_id
      AND      p_ler_id = lep.ler_id
      AND      p_effective_date BETWEEN lep.effective_start_date
                   AND lep.effective_end_date;
    --
    CURSOR c_pl_nip_dflt_cd IS
      SELECT   pln.nip_dflt_enrt_cd,
               pln.nip_dflt_enrt_det_rl
      FROM     ben_pl_f pln
      WHERE    p_pl_id = pln.pl_id
      AND      p_effective_date BETWEEN pln.effective_start_date
                   AND pln.effective_end_date;
    --
    CURSOR c_plip_dflt_cd IS
      SELECT   plp.dflt_enrt_cd,
               plp.dflt_enrt_det_rl
      FROM     ben_plip_f plp
      WHERE    p_plip_id = plp.plip_id
      AND      p_effective_date BETWEEN plp.effective_start_date
                   AND plp.effective_end_date;
    --
    CURSOR c_ptip_dflt_cd IS
      SELECT   ptp.dflt_enrt_cd,
               ptp.dflt_enrt_det_rl
      FROM     ben_ptip_f ptp
      WHERE    p_ptip_id = ptp.ptip_id
      AND      p_effective_date BETWEEN ptp.effective_start_date
                   AND ptp.effective_end_date;
    --
    l_dflt_enrt_cd VARCHAR2(30);
    l_dflt_enrt_rl NUMBER;
    l_plan_rec     ben_pl_f%ROWTYPE;
    l_oipl_rec     ben_cobj_cache.g_oipl_inst_row;
    l_pl_rec       ben_cobj_cache.g_pl_inst_row;
  BEGIN
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    hr_utility.set_location('Entering: ' || l_proc, 10);
  end if;
    --
    l_dflt_enrt_cd :=  NULL;
    --
    -- Hierarchy
    --
    -- 1  if oipl     ben_ler_chg_oipl_enrt_f
    -- 2  if oipl     ben_oipl_f (from cache)
    --
    -- 3  if no pgm   ben_ler_chg_pl_nip_enrt_f
    -- 4  if pgm      ben_ler_chg_plip_enrt_f
    -- 4.5 if pgm     ben_ler_chg_pl_nip_enrt_f
    -- 5  if pgm      ben_ler_chg_ptip_enrt_f
    -- 6  if pgm      ben_ler_chg_pgm_enrt_f
    --
    -- 7  if no pgm   ben_pl_f
    -- 8  if pgm      ben_plip_f
    -- 9  if pgm      ben_ptip_f
    --
    IF p_oipl_id IS NOT NULL THEN
      --
      -- 1
      --
      OPEN c_ler_oipl_dflt_cd;
      FETCH c_ler_oipl_dflt_cd INTO l_dflt_enrt_cd, l_dflt_enrt_rl;
      CLOSE c_ler_oipl_dflt_cd;
      --
      -- hr_utility.set_location(l_dflt_enrt_cd,20);
      IF l_dflt_enrt_cd IS NULL THEN
        --
        -- 2
        -- Bug 5569758
        --
        ben_cobj_cache.get_oipl_dets (p_business_group_id => p_business_group_id,
                                      p_effective_date    => p_effective_date,
                                      p_oipl_id           => p_oipl_id,
                                      p_inst_row	  => l_oipl_rec
                                      );
        --
        l_dflt_enrt_cd :=  l_oipl_rec.dflt_enrt_cd;
        l_dflt_enrt_rl :=  l_oipl_rec.dflt_enrt_det_rl;
      --
      END IF;
    END IF;
    -- hr_utility.set_location(l_dflt_enrt_cd,30);
    IF     p_pgm_id IS NULL
       AND l_dflt_enrt_cd IS NULL THEN
      --
      -- 3
      --
      OPEN c_ler_pl_nip_dflt_cd;
      FETCH c_ler_pl_nip_dflt_cd INTO l_dflt_enrt_cd, l_dflt_enrt_rl;
      CLOSE c_ler_pl_nip_dflt_cd;
    --  hr_utility.set_location(l_dflt_enrt_cd,40);
    ELSIF     p_pgm_id IS NOT NULL
          AND l_dflt_enrt_cd IS NULL THEN
      --
      -- 4
      --
      OPEN c_ler_plip_dflt_cd;
      FETCH c_ler_plip_dflt_cd INTO l_dflt_enrt_cd, l_dflt_enrt_rl;
      CLOSE c_ler_plip_dflt_cd;
      --  hr_utility.set_location(l_dflt_enrt_cd,50);
      -- Bug 5555402
      IF l_dflt_enrt_cd IS NULL THEN
        --
        -- 4.5
        --
        OPEN c_ler_pl_nip_dflt_cd;
        FETCH c_ler_pl_nip_dflt_cd INTO l_dflt_enrt_cd, l_dflt_enrt_rl;
        CLOSE c_ler_pl_nip_dflt_cd;
        --
        IF l_dflt_enrt_cd IS NULL THEN
          --
          -- 5
          --
          OPEN c_ler_ptip_dflt_cd;
          FETCH c_ler_ptip_dflt_cd INTO l_dflt_enrt_cd, l_dflt_enrt_rl;
          CLOSE c_ler_ptip_dflt_cd;
          --  hr_utility.set_location(l_dflt_enrt_cd,60);
          IF l_dflt_enrt_cd IS NULL THEN
            --
            -- 6
            --
            OPEN c_ler_pgm_dflt_cd;
            FETCH c_ler_pgm_dflt_cd INTO l_dflt_enrt_cd, l_dflt_enrt_rl;
            CLOSE c_ler_pgm_dflt_cd;
          END IF;
        END IF;
        --
      END IF;
      --
    END IF;
    --  hr_utility.set_location(l_dflt_enrt_cd,80);
    IF     p_pgm_id IS NULL
       AND l_dflt_enrt_cd IS NULL THEN
      --
      -- 7
      --
      ben_cobj_cache.get_pl_dets (p_business_group_id => p_business_group_id,
                                    p_effective_date  => p_effective_date,
                                    p_pl_id           => p_pl_id,
                                    p_inst_row	      => l_pl_rec
                                    );
      --
      l_dflt_enrt_cd :=  l_pl_rec.nip_dflt_enrt_cd;
      l_dflt_enrt_rl :=  l_pl_rec.nip_dflt_enrt_det_rl;
      --
      --  hr_utility.set_location(l_dflt_enrt_cd,90);
    ELSIF     p_pgm_id IS NOT NULL
          AND l_dflt_enrt_cd IS NULL THEN
      --
      -- 8
      --
      OPEN c_plip_dflt_cd;
      FETCH c_plip_dflt_cd INTO l_dflt_enrt_cd, l_dflt_enrt_rl;
      CLOSE c_plip_dflt_cd;
      --  hr_utility.set_location(l_dflt_enrt_cd,100);
        --
      IF l_dflt_enrt_cd IS NULL THEN
        --
        -- 9
        --
        OPEN c_ptip_dflt_cd;
        FETCH c_ptip_dflt_cd INTO l_dflt_enrt_cd, l_dflt_enrt_rl;
        CLOSE c_ptip_dflt_cd;
     --  hr_utility.set_location(l_dflt_enrt_cd,110);
        --
      END IF;
    END IF;
    --
    p_dflt_enrt_cd :=  l_dflt_enrt_cd;
    p_dflt_enrt_rl :=  l_dflt_enrt_rl;
    --
    if g_debug then
    hr_utility.set_location(l_dflt_enrt_cd,145);
    hr_utility.set_location('Leaving: ' || l_proc, 150);
    end if;
    --
  exception
    --
    when others then
      --
      p_dflt_enrt_cd        := null;
      p_dflt_enrt_rl        := null;
      raise;
      --
  END;
--
/*
This Procedure is moved at the top of the Package
-- internal version below for update_defaults
--
procedure determine_dflt_enrt_cd
  (p_oipl_id           in     number
  ,p_oipl_rec          in     ben_oipl_f%rowtype
  ,p_plip_id           in     number
  ,p_plip_rec          in     ben_plip_f%rowtype
  ,p_pl_id             in     number
  ,p_pl_rec            in     ben_pl_f%rowtype
  ,p_ptip_id           in     number
  ,p_ptip_rec          in     ben_ptip_f%rowtype
  ,p_pgm_id            in     number
  ,p_pgm_rec           in     ben_pgm_f%rowtype
  ,p_ler_id            in     number
  ,p_business_group_id in     number
  ,p_effective_date    in     date
  ,p_dflt_enrt_cd         out nocopy varchar2
  ,p_dflt_enrt_rl         out nocopy number
  ,p_level                out nocopy varchar2
  ,p_ler_dflt_flag   out nocopy varchar2
  )
IS
    --
    -- NOTE:
    --
    --   This procedure is also callable from other RCOs
    --   Please do not remove get_object calls since they
    --   may be needed if not called from bendenrr.
    --
    l_proc         VARCHAR2(80)       := g_package || '.determine_dflt_enrt_cd';
    --
    CURSOR c_ler_oipl_dflt_cd IS
      SELECT   leo.dflt_enrt_cd,
               leo.dflt_enrt_rl,
               leo.dflt_flag
      FROM     ben_ler_chg_oipl_enrt_f leo
      WHERE    p_oipl_id = leo.oipl_id
      AND      p_ler_id = leo.ler_id
      AND      p_effective_date BETWEEN leo.effective_start_date
                   AND leo.effective_end_date;
    --
    -- Use cache for oipl, don't need cursor
    --
    CURSOR c_ler_pl_nip_dflt_cd IS
      SELECT   len.dflt_enrt_cd,
               len.dflt_enrt_rl,
               len.dflt_flag
      FROM     ben_ler_chg_pl_nip_enrt_f len
      WHERE    p_pl_id = len.pl_id
      AND      p_ler_id = len.ler_id
      AND      p_effective_date BETWEEN len.effective_start_date
                   AND len.effective_end_date;
    --
    CURSOR c_ler_plip_dflt_cd IS
      SELECT   lep.dflt_enrt_cd,
               lep.dflt_enrt_rl,
               lep.dflt_flag
      FROM     ben_ler_chg_plip_enrt_f lep
      WHERE    p_plip_id = lep.plip_id
      AND      p_ler_id = lep.ler_id
      AND      p_effective_date BETWEEN lep.effective_start_date
                   AND lep.effective_end_date;
    --
    CURSOR c_ler_ptip_dflt_cd IS
      SELECT   lep.dflt_enrt_cd,
               lep.dflt_enrt_rl
      FROM     ben_ler_chg_ptip_enrt_f lep
      WHERE    p_ptip_id = lep.ptip_id
      AND      p_ler_id = lep.ler_id
      AND      p_effective_date BETWEEN lep.effective_start_date
                   AND lep.effective_end_date;
    --
    CURSOR c_ler_pgm_dflt_cd IS
      SELECT   lep.dflt_enrt_cd,
               lep.dflt_enrt_rl
      FROM     ben_ler_chg_pgm_enrt_f lep
      WHERE    p_pgm_id = lep.pgm_id
      AND      p_ler_id = lep.ler_id
      AND      p_effective_date BETWEEN lep.effective_start_date
                   AND lep.effective_end_date;
    --
    CURSOR c_pl_nip_dflt_cd IS
      SELECT   pln.nip_dflt_enrt_cd,
               pln.nip_dflt_enrt_det_rl,
               pln.nip_dflt_flag
      FROM     ben_pl_f pln
      WHERE    p_pl_id = pln.pl_id
      AND      p_effective_date BETWEEN pln.effective_start_date
                   AND pln.effective_end_date;
    --
    CURSOR c_plip_dflt_cd IS
      SELECT   plp.dflt_enrt_cd,
               plp.dflt_enrt_det_rl
      FROM     ben_plip_f plp
      WHERE    p_plip_id = plp.plip_id
      AND      p_effective_date BETWEEN plp.effective_start_date
                   AND plp.effective_end_date;
    --
    CURSOR c_ptip_dflt_cd IS
      SELECT   ptp.dflt_enrt_cd,
               ptp.dflt_enrt_det_rl
      FROM     ben_ptip_f ptp
      WHERE    p_ptip_id = ptp.ptip_id
      AND      p_effective_date BETWEEN ptp.effective_start_date
                   AND ptp.effective_end_date;
    --
    l_dflt_enrt_cd VARCHAR2(30);
    l_dflt_enrt_rl NUMBER;
    l_plan_rec     ben_pl_f%ROWTYPE;
    l_oipl_rec     ben_cobj_cache.g_oipl_inst_row;
    l_ler_dflt_flag varchar2(30); -- 3510229
  BEGIN
    hr_utility.set_location('Entering: ' || l_proc, 10);
    --
    l_dflt_enrt_cd :=  NULL;
    --
    -- Hierarchy
    --
    -- 1  if oipl     ben_ler_chg_oipl_enrt_f
    -- 2  if oipl     ben_oipl_f (from cache)
    --
    -- 3  if no pgm   ben_ler_chg_pl_nip_enrt_f
    -- 4  if pgm      ben_ler_chg_plip_enrt_f
    -- 5  if pgm      ben_ler_chg_ptip_enrt_f
    -- 6  if pgm      ben_ler_chg_pgm_enrt_f
    --
    -- 7  if no pgm   ben_pl_f
    -- 8  if pgm      ben_plip_f
    -- 9  if pgm      ben_ptip_f
    --
    IF p_oipl_id IS NOT NULL THEN
      --
      -- 1
      --
      OPEN c_ler_oipl_dflt_cd;
      FETCH c_ler_oipl_dflt_cd INTO l_dflt_enrt_cd, l_dflt_enrt_rl, l_ler_dflt_flag;
                                    --p_ler_dflt_flag; 3510229
      CLOSE c_ler_oipl_dflt_cd;
      if
			-- l_dflt_enrt_cd 3510229
			l_ler_dflt_flag is not null then
        p_level:='LER_OIPL';
        p_ler_dflt_flag := l_ler_dflt_flag; -- 3510229
        l_ler_dflt_flag := null ; --3510229
      end if;
      --
      IF l_dflt_enrt_cd IS NULL THEN
        --
        -- 2
        --
        hr_utility.set_location('In the case 2 ' , 100);
        --
        --l_dflt_enrt_cd :=  ben_cobj_cache.g_oipl_currow.dflt_enrt_cd;
        --l_dflt_enrt_rl :=  ben_cobj_cache.g_oipl_currow.dflt_enrt_det_rl;
        --
        l_dflt_enrt_cd := p_oipl_rec.dflt_enrt_cd ;
        l_dflt_enrt_rl := p_oipl_rec.dflt_enrt_det_rl ;

        --hr_utility.set_location(' p_oipl_rec.oipl_id '||p_oipl_rec.oipl_id ,110);
        --hr_utility.set_location(' p_oipl_rec.dflt_enrt_cd '||p_oipl_rec.dflt_enrt_cd ,110);
        --hr_utility.set_location(' p_oipl_rec.dflt_flag '||p_oipl_rec.dflt_flag, 110)  ;
        --
      if l_dflt_enrt_cd is not null
         and p_level is null then -- 3510229
        p_level:='OIPL';
      end if;
      --
      END IF;
    END IF;

    IF     p_pgm_id IS NULL
       AND l_dflt_enrt_cd IS NULL THEN
      --
      -- 3
      --
      OPEN c_ler_pl_nip_dflt_cd;
      FETCH c_ler_pl_nip_dflt_cd INTO l_dflt_enrt_cd, l_dflt_enrt_rl,l_ler_dflt_flag; --3510229
                                    --p_ler_dflt_flag;
      CLOSE c_ler_pl_nip_dflt_cd;
      if l_dflt_enrt_cd is not null
         and p_level is null then -- 3510229
        p_level:='LER_PL_NIP';
        -- 3510229 start
        -- there could be default flag without default code , so this s moved down - 	4008380
        --if p_ler_dflt_flag is null then
        --  p_ler_dflt_flag := l_ler_dflt_flag;
        --end if;
        --l_ler_dflt_flag := null ;
        hr_utility.set_location('after LER pNip chk p_ler_dflt_flag:  '||p_ler_dflt_flag , 100);
        -- 3510229 end

      end if;
      -- there could be default flag without default code 4008380
      if p_ler_dflt_flag is null and l_ler_dflt_flag is not null  then
          p_ler_dflt_flag := l_ler_dflt_flag ;
      end if ;
      hr_utility.set_location('l_ler_dflt_flag ' || l_ler_dflt_flag ,40);
      hr_utility.set_location(l_dflt_enrt_cd,40);


    ELSIF     p_pgm_id IS NOT NULL
          AND l_dflt_enrt_cd IS NULL THEN
      --
      -- 4
      --
      OPEN c_ler_plip_dflt_cd;
      FETCH c_ler_plip_dflt_cd INTO l_dflt_enrt_cd, l_dflt_enrt_rl, l_ler_dflt_flag; --3510229
                                    --p_ler_dflt_flag;
      CLOSE c_ler_plip_dflt_cd;
      if l_dflt_enrt_cd is not null
         and p_level is null then -- 3510229
        p_level:='LER_PLIP';

        -- 3510229 start
        --  4008380
        --if p_ler_dflt_flag is null then
        --  p_ler_dflt_flag := l_ler_dflt_flag;
        --end if;
        hr_utility.set_location('after LER PLIP chk p_ler_dflt_flag:  '||p_ler_dflt_flag , 100);
        --l_ler_dflt_flag := null ;
        -- 3510229 end

      end if;
      --  4008380
      if p_ler_dflt_flag is null and l_ler_dflt_flag is not null  then
          p_ler_dflt_flag := l_ler_dflt_flag ;
      end if ;
      hr_utility.set_location('l_ler_dflt_flag ' || l_ler_dflt_flag ,50);
      hr_utility.set_location(l_dflt_enrt_cd,50);

      --  4008380
      --  there could be plip but the setup may be in plan  ler level
      IF l_dflt_enrt_cd IS NULL THEN

         OPEN c_ler_pl_nip_dflt_cd;
         FETCH c_ler_pl_nip_dflt_cd INTO l_dflt_enrt_cd, l_dflt_enrt_rl,l_ler_dflt_flag;
         CLOSE c_ler_pl_nip_dflt_cd;

         if l_dflt_enrt_cd is not null
            and p_level is null then -- 3510229
            p_level:='LER_PL';
            hr_utility.set_location('after LER Plan  chk p_ler_dflt_flag:  '||p_ler_dflt_flag , 100);
         end if;
         -- there could be default flag without default code 4008380
         if p_ler_dflt_flag is null and l_ler_dflt_flag is not null  then
            p_ler_dflt_flag := l_ler_dflt_flag ;
         end if ;
         hr_utility.set_location('l_ler_dflt_flag ' || l_ler_dflt_flag ,40);
         hr_utility.set_location(l_dflt_enrt_cd,40);
      end if ;



      --- ptip level
      IF l_dflt_enrt_cd IS NULL THEN
        --
        -- 5
        --
        OPEN c_ler_ptip_dflt_cd;
        FETCH c_ler_ptip_dflt_cd INTO l_dflt_enrt_cd, l_dflt_enrt_rl;
        CLOSE c_ler_ptip_dflt_cd;
      if l_dflt_enrt_cd is not null
         and p_level is null then -- 3510229
        p_level:='LER_PTIP';
      end if;
        --  hr_utility.set_location(l_dflt_enrt_cd,60);
        IF l_dflt_enrt_cd IS NULL THEN
          --
          -- 6
          --
          OPEN c_ler_pgm_dflt_cd;
          FETCH c_ler_pgm_dflt_cd INTO l_dflt_enrt_cd, l_dflt_enrt_rl;
          CLOSE c_ler_pgm_dflt_cd;
      if l_dflt_enrt_cd is not null
         and p_level is null then --3510229
        p_level:='LER_PGM';
      end if;
        END IF;
      END IF;
    END IF;
    --  hr_utility.set_location(l_dflt_enrt_cd,80);
    IF     p_pgm_id IS NULL
       AND l_dflt_enrt_cd IS NULL THEN
      --
      -- 7
      --
      -- Bug 1895874
      -- l_dflt_enrt_cd :=  ben_cobj_cache.g_pl_currow.nip_dflt_enrt_cd;
      -- l_dflt_enrt_rl :=  ben_cobj_cache.g_pl_currow.nip_dflt_enrt_det_rl;
      --
      hr_utility.set_location(' p_pl_rec.pl_id '||p_oipl_rec.oipl_id ,110);
      hr_utility.set_location(' p_pl_rec.nip_dflt_enrt_cd '||p_pl_rec.nip_dflt_enrt_cd ,110);
      hr_utility.set_location(' p_pl_rec.nip_dflt_flag '||p_pl_rec.nip_dflt_flag, 110)  ;
      --
      l_dflt_enrt_cd := p_pl_rec.nip_dflt_enrt_cd ;
      l_dflt_enrt_rl := p_pl_rec.nip_dflt_enrt_det_rl ;
      if p_ler_dflt_flag is null then -- 3510229
        p_ler_dflt_flag := p_pl_rec.nip_dflt_flag ;
      end if;

/*
      OPEN c_pl_nip_dflt_cd;
      FETCH c_pl_nip_dflt_cd INTO l_dflt_enrt_cd, l_dflt_enrt_rl,
                                    p_ler_dflt_flag;
      CLOSE c_pl_nip_dflt_cd;
* /
      --
      if l_dflt_enrt_cd is not null
         and p_level is null then -- 3510229
        p_level:='PL';
      end if;
      --
    --  hr_utility.set_location(l_dflt_enrt_cd,90);

    ELSIF     p_pgm_id IS NOT NULL
          AND l_dflt_enrt_cd IS NULL THEN
      --
      -- 8
      --
      l_dflt_enrt_cd := p_plip_rec.dflt_enrt_cd ;
      l_dflt_enrt_rl := p_plip_rec.dflt_enrt_det_rl ;
/*
      OPEN c_plip_dflt_cd;
      FETCH c_plip_dflt_cd INTO l_dflt_enrt_cd, l_dflt_enrt_rl;
      CLOSE c_plip_dflt_cd;
* /
      if l_dflt_enrt_cd is not null
         and p_level is null then -- 3510229
        p_level:='PLIP';
      end if;
       hr_utility.set_location(l_dflt_enrt_cd,100);
        --
      IF l_dflt_enrt_cd IS NULL THEN
        --
        -- 9
        --
      l_dflt_enrt_cd := p_ptip_rec.dflt_enrt_cd ;
      l_dflt_enrt_rl := p_ptip_rec.dflt_enrt_det_rl ;
/*
        OPEN c_ptip_dflt_cd;
        FETCH c_ptip_dflt_cd INTO l_dflt_enrt_cd, l_dflt_enrt_rl;
        CLOSE c_ptip_dflt_cd;
* /
      if l_dflt_enrt_cd is not null
         and p_level is null then -- 3510229
        p_level:='PTIP';
      end if;
      hr_utility.set_location(l_dflt_enrt_cd,110);
        --
      END IF;
    END IF;
  --
    hr_utility.set_location(' p_pgm_id '||p_pgm_id||' pl_id '||p_pl_id||' oipl '||p_oipl_id||
                            ' plip '||p_plip_id||' ptip '||p_ptip_id,130);
    hr_utility.set_location('dflt_enrt_cd= '||l_dflt_enrt_cd,130);
    hr_utility.set_location('dflt_enrt_rl= '||l_dflt_enrt_rl,140);
    hr_utility.set_location('p_ler_dflt_flag= '||p_ler_dflt_flag ,140);
    p_dflt_enrt_cd :=  l_dflt_enrt_cd;
    p_dflt_enrt_rl :=  l_dflt_enrt_rl;
    hr_utility.set_location('Leaving: ' || l_proc, 150);
  exception
    --
    when others then
      --
      p_dflt_enrt_cd        := null;
      p_dflt_enrt_rl        := null;
      p_level               := null;
      p_ler_dflt_flag       := null;
      raise;
      --
  END;
  --
*/

  -- Find the required period of enrollment.  Code/rule/value and level.
  --
procedure find_rqd_perd_enrt
  (p_oipl_id                 in     number
  ,p_opt_id                  in     number
  ,p_pl_id                   in     number
  ,p_ptip_id                 in     number
  ,p_effective_date          in     date
  ,p_business_group_id       in     number
  ,p_rqd_perd_enrt_nenrt_uom    out nocopy varchar2
  ,p_rqd_perd_enrt_nenrt_val    out nocopy number
  ,p_rqd_perd_enrt_nenrt_rl     out nocopy number
  ,p_level                      out nocopy varchar2
  )
IS
    --
    -- THIS SQL STATEMENT HAS BEEN COMMENTED OUT AND REPLACED BY THE IF LOGIC
    --
    -- get rqd_perd_enrt_nenrt heirarchy
    --
    CURSOR c_nenrt IS
      SELECT   '1',
               bo.rqd_perd_enrt_nenrt_uom,
               bo.rqd_perd_enrt_nenrt_val,
               bo.rqd_perd_enrt_nenrt_rl
      FROM     ben_oipl_f bo
      WHERE    bo.oipl_id = p_oipl_id
      AND      p_effective_date BETWEEN bo.effective_start_date
                   AND bo.effective_end_date
      AND      bo.business_group_id = p_business_group_id
      AND      (
                    (
                          bo.rqd_perd_enrt_nenrt_uom IS NOT NULL
                      AND bo.rqd_perd_enrt_nenrt_val IS NOT NULL)
                 OR bo.rqd_perd_enrt_nenrt_rl IS NOT NULL)
      UNION ALL
      SELECT   '2',
               bo.rqd_perd_enrt_nenrt_uom,
               bo.rqd_perd_enrt_nenrt_val,
               bo.rqd_perd_enrt_nenrt_rl
      FROM     ben_opt_f bo
      WHERE    bo.opt_id = p_opt_id
      AND      p_effective_date BETWEEN bo.effective_start_date
                   AND bo.effective_end_date
      AND      bo.business_group_id = p_business_group_id
      AND      (
                    (
                          bo.rqd_perd_enrt_nenrt_uom IS NOT NULL
                      AND bo.rqd_perd_enrt_nenrt_val IS NOT NULL)
                 OR bo.rqd_perd_enrt_nenrt_rl IS NOT NULL)
      UNION ALL
      SELECT   '3',
               bp.rqd_perd_enrt_nenrt_uom,
               bp.rqd_perd_enrt_nenrt_val,
               bp.rqd_perd_enrt_nenrt_rl
      FROM     ben_pl_f bp
      WHERE    bp.pl_id = p_pl_id
      AND      p_effective_date BETWEEN bp.effective_start_date
                   AND bp.effective_end_date
      AND      bp.business_group_id = p_business_group_id
      AND      (
                    (
                          bp.rqd_perd_enrt_nenrt_uom IS NOT NULL
                      AND bp.rqd_perd_enrt_nenrt_val IS NOT NULL)
                 OR bp.rqd_perd_enrt_nenrt_rl IS NOT NULL)
      UNION ALL
      SELECT   '4',
               bp.rqd_perd_enrt_nenrt_tm_uom,
               bp.rqd_perd_enrt_nenrt_val,
               bp.rqd_perd_enrt_nenrt_rl
      FROM     ben_ptip_f bp
      WHERE    bp.ptip_id = p_ptip_id
      AND      p_effective_date BETWEEN bp.effective_start_date
                   AND bp.effective_end_date
      AND      bp.business_group_id = p_business_group_id
      AND      (
                    (
                          bp.rqd_perd_enrt_nenrt_tm_uom IS NOT NULL
                      AND bp.rqd_perd_enrt_nenrt_val IS NOT NULL)
                 OR bp.rqd_perd_enrt_nenrt_rl IS NOT NULL);
    l_level varchar2(30);
  BEGIN
    --
    -- Check if context parameters are set. When context parameters are
    -- not set then fire cursor
    --
    if ben_cobj_cache.g_ptip_currow.ptip_id is not null
      or ben_cobj_cache.g_pl_currow.pl_id is not null
      or ben_cobj_cache.g_opt_currow.opt_id is not null
      or ben_cobj_cache.g_oipl_currow.oipl_id is not null
    then
      --
      IF     ben_cobj_cache.g_oipl_currow.oipl_id = p_oipl_id
         AND (
                  (
                        ben_cobj_cache.g_oipl_currow.rqd_perd_enrt_nenrt_uom IS NOT NULL
                    AND ben_cobj_cache.g_oipl_currow.rqd_perd_enrt_nenrt_val IS NOT NULL)
               OR ben_cobj_cache.g_oipl_currow.rqd_perd_enrt_nenrt_rl IS NOT NULL) THEN
        --
        p_level                    := 'OIPL';
        p_rqd_perd_enrt_nenrt_uom  := ben_cobj_cache.g_oipl_currow.rqd_perd_enrt_nenrt_uom;
        p_rqd_perd_enrt_nenrt_val  := ben_cobj_cache.g_oipl_currow.rqd_perd_enrt_nenrt_val;
        p_rqd_perd_enrt_nenrt_rl   := ben_cobj_cache.g_oipl_currow.rqd_perd_enrt_nenrt_rl;
      ELSIF     ben_cobj_cache.g_opt_currow.opt_id = p_opt_id
            AND (
                     (
                           ben_cobj_cache.g_opt_currow.rqd_perd_enrt_nenrt_uom IS NOT NULL
                       AND ben_cobj_cache.g_opt_currow.rqd_perd_enrt_nenrt_val IS NOT NULL)
                  OR ben_cobj_cache.g_opt_currow.rqd_perd_enrt_nenrt_rl IS NOT NULL) THEN
        --
        p_level                    := 'OPT';
        p_rqd_perd_enrt_nenrt_uom  := ben_cobj_cache.g_opt_currow.rqd_perd_enrt_nenrt_uom;
        p_rqd_perd_enrt_nenrt_val  := ben_cobj_cache.g_opt_currow.rqd_perd_enrt_nenrt_val;
        p_rqd_perd_enrt_nenrt_rl   := ben_cobj_cache.g_opt_currow.rqd_perd_enrt_nenrt_rl;
      ELSIF     ben_cobj_cache.g_pl_currow.pl_id = p_pl_id
            AND (
                     (
                           ben_cobj_cache.g_pl_currow.rqd_perd_enrt_nenrt_uom IS NOT NULL
                       AND ben_cobj_cache.g_pl_currow.rqd_perd_enrt_nenrt_val IS NOT NULL)
                  OR ben_cobj_cache.g_pl_currow.rqd_perd_enrt_nenrt_rl IS NOT NULL) THEN
        --
        p_level                    := 'PL';
        p_rqd_perd_enrt_nenrt_uom  := ben_cobj_cache.g_pl_currow.rqd_perd_enrt_nenrt_uom;
        p_rqd_perd_enrt_nenrt_val  := ben_cobj_cache.g_pl_currow.rqd_perd_enrt_nenrt_val;
        p_rqd_perd_enrt_nenrt_rl   := ben_cobj_cache.g_pl_currow.rqd_perd_enrt_nenrt_rl;
      ELSIF     ben_cobj_cache.g_ptip_currow.ptip_id = p_ptip_id
            AND (
                     (
                           ben_cobj_cache.g_ptip_currow.rqd_perd_enrt_nenrt_tm_uom IS NOT NULL
                       AND ben_cobj_cache.g_ptip_currow.rqd_perd_enrt_nenrt_val IS NOT NULL)
                  OR ben_cobj_cache.g_ptip_currow.rqd_perd_enrt_nenrt_rl IS NOT NULL) THEN
        --
        p_level                    := 'PTIP';
        p_rqd_perd_enrt_nenrt_uom  := ben_cobj_cache.g_ptip_currow.rqd_perd_enrt_nenrt_tm_uom;
        p_rqd_perd_enrt_nenrt_val  := ben_cobj_cache.g_ptip_currow.rqd_perd_enrt_nenrt_val;
        p_rqd_perd_enrt_nenrt_rl   := ben_cobj_cache.g_ptip_currow.rqd_perd_enrt_nenrt_rl;
      END IF;
      --
    else
      --
      OPEN c_nenrt;
      FETCH c_nenrt INTO l_level,
                         p_rqd_perd_enrt_nenrt_uom,
                         p_rqd_perd_enrt_nenrt_val,
                         p_rqd_perd_enrt_nenrt_rl;
      CLOSE c_nenrt;
      IF l_level IS NOT NULL THEN
        IF l_level = 1 THEN
          p_level  := 'OIPL';
        ELSIF l_level = 2 THEN
          p_level  := 'OPT';
        ELSIF l_level = 3 THEN
          p_level  := 'PL';
        ELSIF l_level = 4 THEN
          p_level  := 'PTIP';
        END IF;
      END IF;
      --
    end if;
    if g_debug then
    hr_utility.set_location('level ' ||  p_level , 8086);
    end if;
    --
  exception
    --
    when others then
      --
      p_rqd_perd_enrt_nenrt_uom   := null;
      p_rqd_perd_enrt_nenrt_val   := null;
      p_rqd_perd_enrt_nenrt_rl    := null;
      p_level                     := null;
      raise;
      --
  END find_rqd_perd_enrt;
--
-- find an enrollment at the give level.
--
  PROCEDURE find_enrt_at_same_level(
    p_person_id         IN     NUMBER,
    p_opt_id            IN     NUMBER,
    p_oipl_id           IN     NUMBER,
    p_pl_id             IN     NUMBER,
    p_ptip_id           IN     NUMBER,
    p_pl_typ_id         IN     NUMBER,
    p_pgm_id            IN     NUMBER,
    p_effective_date    IN     DATE,
    p_business_group_id IN     NUMBER,
    p_prtt_enrt_rslt_id IN     NUMBER,
    p_level             IN     VARCHAR2,
    p_pen_rec           OUT NOCOPY    ben_prtt_enrt_rslt_f%ROWTYPE) IS
    --
    l_effective_date_1 DATE := p_effective_date - 1;
    --
    -- Gets the enrolment information for the ptip
    --
    -- Notes:
    --   <> pen_id checks are for enrollment time use not bendenrr use
    -- bug : 1620162 ig the send even the option saved then replaces with other option
    -- the chek l_effective_date_1 <= pen.enrt_cvg_thru_dt became true
    -- so changed to l_effective_date_1 < pen.enrt_cvg_thru_dt
    CURSOR c_ptip_enrolment_info IS
      SELECT   *
      FROM     ben_prtt_enrt_rslt_f pen
      WHERE    pen.person_id = p_person_id
      AND      pen.business_group_id = p_business_group_id
      AND      pen.prtt_enrt_rslt_stat_cd IS NULL
      AND      pen.sspndd_flag = 'N'
      AND      pen.effective_end_date = hr_api.g_eot
      AND      l_effective_date_1 < pen.enrt_cvg_thru_dt
      AND      pen.prtt_enrt_rslt_id <> p_prtt_enrt_rslt_id
      AND      (
                    (    pen.pgm_id = p_pgm_id
                     AND p_pgm_id IS NOT NULL)
                 OR (    pen.pgm_id IS NULL
                     AND p_pgm_id IS NOT NULL))
      AND      pen.comp_lvl_cd NOT IN ('PLANFC', 'PLANIMP')
      AND      pen.enrt_cvg_strt_dt < pen.effective_end_date
      AND      pen.ptip_id = p_ptip_id;
    --
    -- Gets the enrolment information for the oipl
    --
    CURSOR c_oipl_enrolment_info IS
      SELECT   *
      FROM     ben_prtt_enrt_rslt_f pen
      WHERE    pen.person_id = p_person_id
      AND      pen.business_group_id = p_business_group_id
      AND      pen.prtt_enrt_rslt_stat_cd IS NULL
--      AND      pen.sspndd_flag = 'N' --CFW
      AND      pen.effective_end_date = hr_api.g_eot
      AND      l_effective_date_1 < pen.enrt_cvg_thru_dt
      AND      pen.enrt_cvg_strt_dt < pen.effective_end_date
      AND      pen.prtt_enrt_rslt_id <> p_prtt_enrt_rslt_id
      AND      (
                    (    pen.pgm_id = p_pgm_id
                     AND p_pgm_id IS NOT NULL)
                 OR (    pen.pgm_id IS NULL
                     AND p_pgm_id IS NOT NULL))
      AND      pen.comp_lvl_cd NOT IN ('PLANFC', 'PLANIMP')
      AND      pen.oipl_id = p_oipl_id;
    --
    -- Gets the enrolment information for the pl
    --
    CURSOR c_pl_enrolment_info IS
      SELECT   *
      FROM     ben_prtt_enrt_rslt_f pen
      WHERE    pen.person_id = p_person_id
      AND      pen.business_group_id = p_business_group_id
      AND      pen.prtt_enrt_rslt_stat_cd IS NULL
      AND      pen.sspndd_flag = 'N'
      AND      pen.effective_end_date = hr_api.g_eot
      AND      l_effective_date_1 < pen.enrt_cvg_thru_dt
      AND      pen.enrt_cvg_strt_dt < pen.effective_end_date
      AND      pen.prtt_enrt_rslt_id <> p_prtt_enrt_rslt_id
      AND      (
                    (    pen.pgm_id = p_pgm_id
                     AND p_pgm_id IS NOT NULL)
                 OR (    pen.pgm_id IS NULL
                     AND p_pgm_id IS NOT NULL))
      AND      pen.comp_lvl_cd NOT IN ('PLANFC', 'PLANIMP')
      AND      pen.pl_id = p_pl_id;
    --
    -- Gets the enrolment information for the opt
    --
    CURSOR c_opt_enrolment_info IS
      SELECT   pen.*
      FROM     ben_prtt_enrt_rslt_f pen, ben_pl_f pl, ben_oipl_f oipl
      WHERE    pen.person_id = p_person_id
      AND      pen.business_group_id = p_business_group_id
      AND      pen.effective_end_date = hr_api.g_eot
      AND      l_effective_date_1 BETWEEN pen.enrt_cvg_strt_dt
               AND pen.enrt_cvg_thru_dt
      AND      pl.pl_id = pen.pl_id
      and      pen.oipl_id  = p_oipl_id       /* bug 1527086 */
      AND      pl.business_group_id = p_business_group_id
      AND      pl.pl_typ_id = p_pl_typ_id
      AND      oipl.pl_id = pl.pl_id
      AND      oipl.opt_id = p_opt_id
      AND      p_effective_date BETWEEN pl.effective_start_date
                   AND pl.effective_end_date
      AND      p_effective_date BETWEEN oipl.effective_start_date
                   AND oipl.effective_end_date
      AND      pen.enrt_cvg_strt_dt < pen.effective_end_date
      AND      pen.sspndd_flag = 'N'
      AND      pen.prtt_enrt_rslt_stat_cd IS NULL
      AND      oipl.business_group_id = p_business_group_id
      AND      pen.prtt_enrt_rslt_id <> p_prtt_enrt_rslt_id
      AND      (
                    (    pen.pgm_id = p_pgm_id
                     AND p_pgm_id IS NOT NULL)
                 OR (    pen.pgm_id IS NULL
                     AND p_pgm_id IS NOT NULL))
      AND      pen.comp_lvl_cd NOT IN ('PLANFC', 'PLANIMP');



  BEGIN
    IF p_level = 'PL' THEN
      OPEN c_pl_enrolment_info;
      FETCH c_pl_enrolment_info INTO p_pen_rec;
      CLOSE c_pl_enrolment_info;
    ELSIF p_level = 'OPT' THEN
      OPEN c_opt_enrolment_info;
      FETCH c_opt_enrolment_info INTO p_pen_rec;
      CLOSE c_opt_enrolment_info;
    ELSIF p_level = 'OIPL' THEN
      OPEN c_oipl_enrolment_info;
      FETCH c_oipl_enrolment_info INTO p_pen_rec;
      CLOSE c_oipl_enrolment_info;
    ELSIF p_level = 'PTIP' THEN
      OPEN c_ptip_enrolment_info;
      FETCH c_ptip_enrolment_info INTO p_pen_rec;
      CLOSE c_ptip_enrolment_info;
    END IF;
  exception
    --
    when others then
      --
      p_pen_rec := null;
      raise;
      --
  END find_enrt_at_same_level;
--
procedure update_defaults
  (p_run_mode               in     varchar2
  ,p_business_group_id      in     number
  ,p_effective_date         in     date
  ,p_lf_evt_ocrd_dt         in     date default null
  ,p_ler_id                 in     number
  ,p_person_id              in     number
  ,p_per_in_ler_id          in     number
  )
IS
  --
  l_oipl_id_va       benutils.g_number_table := benutils.g_number_table();
  l_pl_id_va         benutils.g_number_table := benutils.g_number_table();
  l_pgm_id_va        benutils.g_number_table := benutils.g_number_table();
  l_ptip_id_va       benutils.g_number_table := benutils.g_number_table();
  l_plip_id_va       benutils.g_number_table := benutils.g_number_table();
  l_epe_dflt_flag_va benutils.g_v2_30_table := benutils.g_v2_30_table();
  l_ELCTBL_FLAG_va   benutils.g_v2_30_table := benutils.g_v2_30_table();
  l_epe_id_va        benutils.g_number_table := benutils.g_number_table();
  l_epe_ovn_va       benutils.g_number_table := benutils.g_number_table();
  --
  l_prevepo_rec      ben_derive_part_and_rate_facts.g_cache_structure;
  l_prevpep_rec      ben_derive_part_and_rate_facts.g_cache_structure;
  --
  l_rec_assignment_id number;
  l_rec_organization_id number;
  l_dflt_flag      varchar2(30);
  l_use_dflt_flag  varchar2(30);
  l_oipl_rec ben_oipl_f%rowtype;
  l_empty_oipl ben_oipl_f%rowtype;
  l_plan_rec ben_pl_f%rowtype;
  l_pgm_rec  ben_pgm_f%rowtype;
  l_empty_pgm  ben_pgm_f%rowtype;
  l_plip_rec  ben_plip_f%rowtype;
  l_empty_plip  ben_plip_f%rowtype;
  l_ptip_rec  ben_ptip_f%rowtype;
  l_empty_ptip  ben_ptip_f%rowtype;
  l_use_dflt_enrt_cd varchar2(30);
  l_use_dflt_enrt_rl varchar2(30);
  l_reinstt_flag varchar2(30);
  l_dflt_level varchar2(30);
  l_lf_evt_ocrd_dt date;
  l_lf_evt_ocrd_dt_1 date;
  l_effective_date_1 date;
  l_ler_dflt_flag varchar2(30):=null;
  l_proc         VARCHAR2(80)       := g_package || '.update_defaults';
  --
  -- Choice population
  --   Auto enrollments are never defaulted.
  --
  cursor c_choices
    (c_lf_evt_ocrd_dt date
    ,c_per_in_ler_id  number
    )
  is
  select epe.oipl_id,
         epe.pl_id,
         epe.pgm_id,
         epe.ptip_id,
         epe.plip_id,
         epe.dflt_flag,
         epe.ELCTBL_FLAG,
         epe.ELIG_PER_ELCTBL_CHC_ID,
         epe.OBJECT_VERSION_NUMBER
  from   ben_elig_per_elctbl_chc epe,
/*
         ben_per_in_ler pil,
*/
         ben_pl_f pln
  where  epe.auto_enrt_flag = 'N'
  and    epe.per_in_ler_id  = c_per_in_ler_id
/*
    and  pil.person_id = p_person_id
    and  pil.per_in_ler_id = epe.per_in_ler_id
    and  pil.per_in_ler_stat_cd = 'STRTD'
*/
    and  pln.pl_id=epe.pl_id
    and  c_lf_evt_ocrd_dt
      between pln.effective_start_date and pln.effective_end_date
    and  nvl(pln.imptd_incm_calc_cd,'x') NOT IN ('PRTT', 'DPNT', 'SPS')
    and  invk_flx_cr_pl_flag='N'
    and  (epe.oipl_id is not null or
          not exists
            (select null
             from   ben_oipl_f oipl
             where  c_lf_evt_ocrd_dt
               between oipl.effective_start_date and oipl.effective_end_date
             and oipl.pl_id=epe.pl_id
            )
         );
  --
  -- Gets all information on the plip which is needed
  --
  CURSOR c_plip_info(p_pl_id number,p_pgm_id number) IS
      SELECT   bpf.dflt_flag
      FROM     ben_plip_f bpf
      WHERE    bpf.pl_id = p_pl_id
      AND      bpf.pgm_id = p_pgm_id
      AND      bpf.business_group_id = p_business_group_id
      AND      l_lf_evt_ocrd_dt BETWEEN bpf.effective_start_date
                   AND bpf.effective_end_date;
  CURSOR c_asg IS
      SELECT   asg.assignment_id,
               asg.organization_id
      FROM     per_all_assignments_f asg
      WHERE    asg.person_id = p_person_id
      and      asg.assignment_type <> 'C'
      AND      asg.primary_flag =  decode(p_run_mode, 'I',asg.primary_flag,'Y')  -- iRec
      AND      l_lf_evt_ocrd_dt BETWEEN asg.effective_start_date
                   AND asg.effective_end_date
  ;
  l_new_elctbl_flag              VARCHAR2(30)                 := 'Y';
  l_tco_chg_enrt_cd              VARCHAR2(30)                 := 'CPOO';
  l_previous_eligibility         VARCHAR2(30);
  l_pl_enrt_cd                   VARCHAR2(30);
  l_crnt_enrt_cvg_strt_dt        DATE;
  l_ler_enrt_prclds_chg_flag     VARCHAR2(30);
  l_ler_stl_elig_cant_chg_flag   VARCHAR2(30);
  l_pl_enrt_rl                   NUMBER;
  l_dpnt_cvrd_flag               VARCHAR2(1)                  := 'N';
  l_crnt_erlst_deenrt_dt         date;
  l_prtt_enrt_rslt_id            number;
  l_enrt_ovridn_flag             varchar2(30);
  l_enrt_ovrid_thru_dt           date;
  l_ler_chg_found_flag           varchar2(30);
  l_ler_chg_oipl_found_flag      varchar2(30);
  --
  l_ler_enrt_cd                  varchar2(30);
  l_ler_enrt_rl                  number;
  l_ler_auto_enrt_rl             number;
  l_ler_enrt_mthd_cd             varchar2(30);
  l_oipl_auto_enrt_flag          varchar2(30);
  l_pl_enrt_mthd_cd              varchar2(30);
  l_pl_auto_enrt_rl              number;
  --
  l_oipl_id                      number;
  l_pl_id                        number;
  l_pgm_id                       number;
  l_ptip_id                      number;
  l_plip_id                      number;
  l_epe_dflt_flag                varchar2(30);
  l_ELCTBL_FLAG                  varchar2(30);
  l_epe_id                       number;
  l_epe_ovn                      number;
  --
    -- Gets the enrolment information for this plan
    --
    --
    CURSOR c_plan_enrolment_info IS
      SELECT   pen.enrt_cvg_strt_dt,
               pen.erlst_deenrt_dt,
               pen.prtt_enrt_rslt_id,
               pen.enrt_ovridn_flag,
               pen.enrt_ovrid_thru_dt
      FROM     ben_prtt_enrt_rslt_f pen
      WHERE    pen.person_id = p_person_id
      AND      pen.business_group_id = p_business_group_id
--      AND      pen.sspndd_flag = 'N' --CFW
      AND      (pen.sspndd_flag = 'N' --CFW
                 OR (pen.sspndd_flag = 'Y' and
                     pen.enrt_cvg_thru_dt = hr_api.g_eot
                    )
               )
      AND      pen.prtt_enrt_rslt_stat_cd IS NULL
      AND      pen.effective_end_date = hr_api.g_eot
      AND      l_lf_evt_ocrd_dt_1 <= pen.enrt_cvg_thru_dt
      AND      pen.enrt_cvg_strt_dt < pen.effective_end_date
      AND      l_plan_rec.pl_id = pen.pl_id
      AND      (
                    (    pen.pgm_id = l_pgm_rec.pgm_id
                     AND l_pgm_rec.pgm_id IS NOT NULL)
                 OR (    pen.pgm_id IS NULL
                     AND l_pgm_rec.pgm_id IS NULL));
    --
    -- Gets the enrolment information for this oipl
    --
    --
    CURSOR c_oipl_enrolment_info IS
      SELECT   pen.enrt_cvg_strt_dt,
               pen.erlst_deenrt_dt,
               pen.prtt_enrt_rslt_id,
               pen.enrt_ovridn_flag,
               pen.enrt_ovrid_thru_dt
      FROM     ben_prtt_enrt_rslt_f pen
      WHERE    pen.person_id = p_person_id
      AND      pen.business_group_id = p_business_group_id
--      AND      pen.sspndd_flag = 'N' --CFW
      AND      (pen.sspndd_flag = 'N' --CFW
                 OR (pen.sspndd_flag = 'Y' and
                     pen.enrt_cvg_thru_dt = hr_api.g_eot
                    )
               )
      AND      pen.prtt_enrt_rslt_stat_cd IS NULL
      AND      pen.effective_end_date = hr_api.g_eot
      AND      l_lf_evt_ocrd_dt_1 <= pen.enrt_cvg_thru_dt
      AND      pen.enrt_cvg_strt_dt < pen.effective_end_date
      AND      l_oipl_rec.oipl_id = pen.oipl_id
      AND      (
                    (    pen.pgm_id = l_pgm_rec.pgm_id
                     AND l_pgm_rec.pgm_id IS NOT NULL)
                 OR (    pen.pgm_id IS NULL
                     AND l_pgm_rec.pgm_id IS NULL));
    --
    -- Gets the coverage information for this plan
    --
    --
    CURSOR c_plan_cvg_info IS
      SELECT   'Y'
      FROM     ben_prtt_enrt_rslt_f pen, ben_elig_cvrd_dpnt_f pdp
      WHERE    pdp.dpnt_person_id = p_person_id
      AND      pdp.effective_end_date = hr_api.g_eot
      AND      l_lf_evt_ocrd_dt_1 BETWEEN pdp.cvg_strt_dt AND pdp.cvg_thru_dt
      AND      pdp.business_group_id = p_business_group_id
      AND      pdp.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
      AND      pen.business_group_id = p_business_group_id
      AND      pen.sspndd_flag = 'N'
      AND      pen.prtt_enrt_rslt_stat_cd IS NULL
      AND      pen.effective_end_date = hr_api.g_eot
      AND      l_lf_evt_ocrd_dt_1 <= pen.enrt_cvg_thru_dt
      AND      pen.enrt_cvg_strt_dt < pen.effective_end_date
      AND      l_plan_rec.pl_id = pen.pl_id
      AND      (
                    (    pen.pgm_id = l_pgm_rec.pgm_id
                     AND l_pgm_rec.pgm_id IS NOT NULL)
                 OR (    pen.pgm_id IS NULL
                     AND l_pgm_rec.pgm_id IS NULL));
    --
    -- Gets the coverage information for this oipl
    --
    --
    CURSOR c_oipl_cvg_info IS
      SELECT   'Y'
      FROM     ben_prtt_enrt_rslt_f pen, ben_elig_cvrd_dpnt_f pdp
      WHERE    pdp.dpnt_person_id = p_person_id
      AND      pdp.effective_end_date = hr_api.g_eot
      AND      l_lf_evt_ocrd_dt_1 BETWEEN pdp.cvg_strt_dt AND pdp.cvg_thru_dt
      AND      pdp.business_group_id = p_business_group_id
      AND      pdp.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
      AND      pen.business_group_id = p_business_group_id
--      AND      pen.sspndd_flag = 'N'
      AND      (pen.sspndd_flag = 'N' --CFW
                 OR (pen.sspndd_flag = 'Y' and
                     pen.enrt_cvg_thru_dt = hr_api.g_eot
                    )
               )
      AND      pen.prtt_enrt_rslt_stat_cd IS NULL
      AND      pen.effective_end_date = hr_api.g_eot
      AND      l_lf_evt_ocrd_dt_1 <= pen.enrt_cvg_thru_dt
      AND      pen.enrt_cvg_strt_dt < pen.effective_end_date
      AND      l_oipl_rec.oipl_id = pen.oipl_id
      AND      (
                    (    pen.pgm_id = l_pgm_rec.pgm_id
                     AND l_pgm_rec.pgm_id IS NOT NULL)
                 OR (    pen.pgm_id IS NULL
                     AND l_pgm_rec.pgm_id IS NULL));
    -- Determines the previous eligibility for an option
    --
    CURSOR c_previous_elig_for_option IS
      SELECT   epo.elig_flag
      FROM     ben_elig_per_f ep, ben_elig_per_opt_f epo, ben_per_in_ler pil
      WHERE    ep.person_id = p_person_id
      AND      ep.pl_id = l_plan_rec.pl_id
      AND      (
                    (    ep.pgm_id = l_pgm_rec.pgm_id
                     AND l_pgm_rec.pgm_id IS NOT NULL)
                 OR (    ep.pgm_id IS NULL
                     AND l_pgm_rec.pgm_id IS NULL))
      AND      ep.business_group_id = p_business_group_id
      AND      p_effective_date - 1 BETWEEN ep.effective_start_date
                   AND ep.effective_end_date
      AND      ep.elig_per_id = epo.elig_per_id
      AND      epo.opt_id = l_oipl_rec.opt_id
      AND      epo.business_group_id = p_business_group_id
      AND      l_effective_date_1 BETWEEN epo.effective_start_date
                   AND epo.effective_end_date
      AND      pil.per_in_ler_id (+) = epo.per_in_ler_id
      AND      pil.business_group_id (+) = epo.business_group_id
      AND      (
                    pil.per_in_ler_stat_cd NOT IN
                                        (
                                          'VOIDD',
                                          'BCKDT')       -- found row condition
                 OR pil.per_in_ler_stat_cd IS NULL);    -- outer join condition
    -- Determines the previous eligibility for a plan
    --
    CURSOR c_previous_elig_for_plan IS
      SELECT   pep.elig_flag
      FROM     ben_elig_per_f pep, ben_per_in_ler pil
      WHERE    pep.person_id = p_person_id
      AND      pep.pl_id = l_plan_rec.pl_id
      AND      (
                    (    pep.pgm_id = l_pgm_rec.pgm_id
                     AND l_pgm_rec.pgm_id IS NOT NULL)
                 OR (    pep.pgm_id IS NULL
                     AND l_pgm_rec.pgm_id IS NULL))
      AND      pep.business_group_id = p_business_group_id
      AND      l_effective_date_1 BETWEEN pep.effective_start_date
                   AND pep.effective_end_date
      AND      pil.per_in_ler_id (+) = pep.per_in_ler_id
      AND      pil.business_group_id (+) = pep.business_group_id
      AND      (
                    pil.per_in_ler_stat_cd NOT IN
                                        (
                                          'VOIDD',
                                          'BCKDT')       -- found row condition
                 OR pil.per_in_ler_stat_cd IS NULL);    -- outer join condition
  --
  cursor c_enrt_bnft (p_elctbl_chc_id number) is
    select enb.enrt_bnft_id,
           enb.object_version_number
    from   ben_enrt_bnft enb
    where  enb.elig_per_elctbl_chc_id = p_elctbl_chc_id
    and    enb.dflt_flag = 'N'
    and    (exists  (select null from
                    ben_enrt_bnft enb2
                    where enb2.enrt_bnft_id = enb.enrt_bnft_id
                    and   enb2.dflt_val = enb2.val)
           or enb.cvg_mlt_cd not in ('FLRNG', 'CLRNG','FLPCLRNG','CLPFLRNG'));
  l_enrt_bnft    c_enrt_bnft%rowtype;
  l_enrt_cd_level varchar2(30) ;
  -- 5092244
  CURSOR c_elig_dpnt (v_epe_id NUMBER)
   IS
      SELECT egd.elig_dpnt_id, egd.object_version_number
        FROM ben_elig_dpnt egd, ben_per_in_ler pil
       WHERE elig_per_elctbl_chc_id = v_epe_id
         AND pil.per_in_ler_id = egd.per_in_ler_id
         AND pil.per_in_ler_stat_cd = 'STRTD';

   l_elig_dpnt   c_elig_dpnt%ROWTYPE;
   l_next_row    NUMBER;
  --
begin
  --
  g_debug := hr_utility.debug_enabled;
  --
if g_debug then
  hr_utility.set_location('Entering: '||l_proc,10);
  end if;
  --l_effective_date_1:=p_effective_date-1;
  --Bug#2328029
  l_effective_date_1:=
           least(p_effective_date, nvl(p_lf_evt_ocrd_dt,p_effective_date)) -1;
  --
  if p_lf_evt_ocrd_dt is not null then
    l_lf_evt_ocrd_dt:=p_lf_evt_ocrd_dt;
  else
    l_lf_evt_ocrd_dt:=p_effective_date;
  end if;
  l_lf_evt_ocrd_dt_1:=l_lf_evt_ocrd_dt-1;
  --
  open c_choices
    (c_lf_evt_ocrd_dt => p_lf_evt_ocrd_dt
    ,c_per_in_ler_id  => p_per_in_ler_id
    );
  fetch c_choices BULK COLLECT INTO l_oipl_id_va,
                                    l_pl_id_va,
                                    l_pgm_id_va,
                                    l_ptip_id_va,
                                    l_plip_id_va,
                                    l_epe_dflt_flag_va,
                                    l_ELCTBL_FLAG_va,
                                    l_epe_id_va,
                                    l_epe_ovn_va;
  close c_choices;
  --
  if l_epe_id_va.count > 0 then
    --
    for epeele_num in l_epe_id_va.first..l_epe_id_va.last
    loop
      --
      l_oipl_id        := l_oipl_id_va(epeele_num);
      l_pl_id          := l_pl_id_va(epeele_num);
      l_pgm_id         := l_pgm_id_va(epeele_num);
      l_ptip_id        := l_ptip_id_va(epeele_num);
      l_plip_id        := l_plip_id_va(epeele_num);
      l_epe_dflt_flag  := l_epe_dflt_flag_va(epeele_num);
      l_ELCTBL_FLAG    := l_ELCTBL_FLAG_va(epeele_num);
      l_epe_id         := l_epe_id_va(epeele_num);
      l_epe_ovn        := l_epe_ovn_va(epeele_num);
      --
/*
  for l_rec in c_choices
    (c_lf_evt_ocrd_dt => p_lf_evt_ocrd_dt
    ,c_per_in_ler_id  => p_per_in_ler_id
    )
  loop
*/
    if g_debug then
      hr_utility.set_location(l_proc||' ST c_choices loop: ',10);
    end if;
      --
      -- init flags
      --
      l_dflt_flag:='N';
      l_use_dflt_flag:='N';
      --
      -- Get option information if an oipl_id is passed,
      -- need to do this before getting oipl eligibility.
      --
      IF (l_oipl_id IS NOT NULL) THEN
        --
        -- get oipl information
        --
        ben_comp_object.get_object(p_oipl_id => l_oipl_id, p_rec =>l_oipl_rec);
        l_oipl_auto_enrt_flag:=l_oipl_rec.auto_enrt_flag;
      else
        l_oipl_rec:=l_empty_oipl;
      end if;
      --
      -- get plan cache row
      --
      ben_comp_object.get_object(p_pl_id => l_pl_id, p_rec => l_plan_rec);
      l_pl_enrt_mthd_cd :=          l_plan_rec.enrt_mthd_cd;
      l_pl_auto_enrt_rl :=          l_plan_rec.auto_enrt_mthd_rl;
      --
      -- Get pgm cache row if needed
      --
      IF l_pgm_id IS NOT NULL THEN
        ben_comp_object.get_object(p_pgm_id => l_pgm_id, p_rec => l_pgm_rec);
      else
        l_pgm_rec:=l_empty_pgm;
      END IF;
      --
      -- Get ptip cache row if needed
      --
      IF l_ptip_id IS NOT NULL THEN
        ben_comp_object.get_object(p_ptip_id => l_ptip_id,
                                   p_rec => l_ptip_rec);
      else
        l_ptip_rec:=l_empty_ptip;
      END IF;
      --
      -- Get plip cache row if needed
      --
      IF l_pgm_id IS NOT NULL THEN
        ben_comp_object.get_object(p_plip_id => l_plip_id,
                                   p_rec => l_plip_rec);
      else
        l_plip_rec:=l_empty_plip;
      END IF;
      --
      -- get the dflt_enrt_cd/rule
      --
      if g_debug then
      hr_utility.set_location('DDEC: '||l_proc,10);
      end if;
      determine_dflt_enrt_cd
        (p_oipl_id           => l_oipl_id
        ,p_oipl_rec          => l_oipl_rec
        ,p_plip_id           => l_plip_id
        ,p_plip_rec          => l_plip_rec
        ,p_pl_id             => l_pl_id
        ,p_pl_rec            => l_plan_rec
        ,p_ptip_id           => l_ptip_id
        ,p_ptip_rec          => l_ptip_rec
        ,p_pgm_id            => l_pgm_id
        ,p_pgm_rec           => l_pgm_rec
        ,p_ler_id            => p_ler_id
        ,p_dflt_enrt_cd      => l_use_dflt_enrt_cd
        ,p_dflt_enrt_rl      => l_use_dflt_enrt_rl
        ,p_business_group_id => p_business_group_id
        ,p_effective_date    => l_lf_evt_ocrd_dt -- Bug 2404008 p_effective_date
        ,p_level             => l_dflt_level
        ,p_ler_dflt_flag     => l_ler_dflt_flag
      );
      --hr_utility.set_location('After call to determine_dflt_enrt_cd ' , 5553);
      --hr_utility.set_location('l_pgm_id '||l_pgm_id,5554);
      if g_debug then
      hr_utility.set_location('l_oipl_id '||l_oipl_id ,5555);
      hr_utility.set_location('l_pl_id '||l_pl_id ,5556);
      --hr_utility.set_location('l_dflt_flag='||l_dflt_flag,5557);
      hr_utility.set_location('l_ler_dflt_flag '||l_ler_dflt_flag ,5555);
      hr_utility.set_location(' l_epe_dflt_flag='|| l_epe_dflt_flag,5558);
      hr_utility.set_location(' l_dflt_level ='|| l_dflt_level ,5558);
      end if;
      --hr_utility.set_location(' ---- ' ,5559);
      --
      -- Set the values for the dflt_flag
      --
      --
      l_use_dflt_flag :=            NULL;
      IF l_ler_dflt_flag is not null and
         (l_dflt_level='LER_OIPL' or
          l_oipl_id is null) then
        l_use_dflt_flag:=l_ler_dflt_flag;
      end if;
      --
      -- oipl level default code/flag
      --
      IF l_oipl_id IS NOT NULL THEN
        IF l_use_dflt_flag IS NULL THEN
          --
          -- use oipl level flag
          --
          l_use_dflt_flag :=  l_oipl_rec.dflt_flag;
        END IF;
      END IF;
      --
      -- plip level default code/flag
      --
      IF l_plip_id IS NOT NULL THEN
        IF l_use_dflt_flag IS NULL THEN
          --
          -- Find the plip and get its needed attributes.
          --
          OPEN c_plip_info(l_pl_id,l_pgm_id);
          --
          FETCH c_plip_info INTO l_use_dflt_flag;
          IF c_plip_info%NOTFOUND THEN
            --
            fnd_message.set_name('BEN', 'BEN_91461_PLIP_MISSING');
            fnd_message.set_token('PROC', l_proc);
            fnd_message.set_token('PGM_ID', TO_CHAR(l_pgm_id));
            fnd_message.set_token('PL_ID', TO_CHAR(l_pl_id));
            fnd_message.set_token('BG_ID', TO_CHAR(p_business_group_id));
            RAISE ben_manage_life_events.g_record_error;
          --
          END IF;
          --
          CLOSE c_plip_info;
        END IF;
      END IF;
      --
      -- If no default flag is set then make it not a default.
      --
      IF l_use_dflt_flag IS NULL THEN
        --
        l_use_dflt_flag :=  'N';
      --
      END IF;
      OPEN c_asg;
      FETCH c_asg INTO l_rec_assignment_id, l_rec_organization_id;
      IF c_asg%NOTFOUND THEN
          CLOSE c_asg;
	  if g_debug then
          hr_utility.set_location('error', 20);
	  end if;
          fnd_message.set_name('BEN', 'BEN_92106_PRTT_NO_ASGN');
          fnd_message.set_token('PROC', l_proc);
          fnd_message.set_token('PERSON_ID', TO_CHAR(p_person_id));
          fnd_message.set_token('LF_EVT_OCRD_DT', TO_CHAR(p_lf_evt_ocrd_dt));
          fnd_message.set_token('EFFECTIVE_DATE', TO_CHAR(p_effective_date));
          RAISE ben_manage_life_events.g_record_error;
      END IF;
      CLOSE c_asg;
      --hr_utility.set_location('Before call to l_use_dflt_flag ',5550);
      if g_debug then
      hr_utility.set_location(' l_use_dflt_flag ',5550);
      hr_utility.set_location(' l_use_dflt_enrt_cd ',5550);
      end if;
      determine_dflt_flag(
         l_use_dflt_flag,
         l_use_dflt_enrt_cd,
         null, --not used
         null, --not used
         l_use_dflt_enrt_rl,
         l_oipl_id,
         l_pl_id,
         l_pgm_id,
         p_effective_date,
         p_lf_evt_ocrd_dt,
         p_ler_id,
         l_oipl_rec.opt_id,
         l_plan_rec.pl_typ_id,
         l_ptip_id,
         p_person_id,
         p_business_group_id,
         l_rec_assignment_id,
         l_dflt_flag,
         l_reinstt_flag,
	 -- added bug 5644451
	 l_dflt_level,
	 p_run_mode           /* iRec : Added p_run_mode */
      );
      --
      if g_debug then
      hr_utility.set_location(' l_dflt_flag '|| l_dflt_flag ,5550);
      end if;
      IF (l_dflt_flag = 'DEFER') THEN
        --
        l_dflt_flag :=  l_use_dflt_flag;
      --
      END IF;
      --hr_utility.set_location('After call to determine_dflt_flag ' , 5553);
      --hr_utility.set_location('l_pgm_id '||l_pgm_id,5554);
      --hr_utility.set_location('l_oipl_id '||l_oipl_id ,5555);
      if g_debug then
      hr_utility.set_location('l_pl_id '||l_pl_id ,5556);
      hr_utility.set_location('l_dflt_flag='||l_dflt_flag,5557);
      hr_utility.set_location(' l_epe_dflt_flag='|| l_epe_dflt_flag,5558);
      end if;
      --
      -- Done with default flag now see if electable flag should be changed
      --
      -- Determine if the person is currently enrolled and if so
      -- determine the coverage start date.
      --
      if ( l_ELCTBL_FLAG='Y') then
        IF (l_oipl_id IS NULL) THEN
          --
          OPEN c_plan_enrolment_info;
          --
          FETCH c_plan_enrolment_info INTO l_crnt_enrt_cvg_strt_dt,
                                           l_crnt_erlst_deenrt_dt,
                                           l_prtt_enrt_rslt_id,
                                           l_enrt_ovridn_flag,
                                           l_enrt_ovrid_thru_dt;
          --
          IF c_plan_enrolment_info%NOTFOUND THEN
            --
            l_crnt_enrt_cvg_strt_dt :=  NULL;
            --
            --  Check if person is a covered dependent - COBRA.
            --
            IF l_pgm_id IS NOT NULL THEN
              IF l_pgm_rec.pgm_typ_cd LIKE 'COBRA%' THEN
                OPEN c_plan_cvg_info;
                FETCH c_plan_cvg_info INTO l_dpnt_cvrd_flag;
                CLOSE c_plan_cvg_info;
              END IF;
            END IF;
          --
          END IF;
          --
          CLOSE c_plan_enrolment_info;
	  if g_debug then
          hr_utility.set_location('close c_PEI: ' || l_proc, 10);
	  end if;
        --
        ELSE
          --
          OPEN c_oipl_enrolment_info;
          --
          FETCH c_oipl_enrolment_info INTO l_crnt_enrt_cvg_strt_dt,
                                           l_crnt_erlst_deenrt_dt,
                                           l_prtt_enrt_rslt_id,
                                           l_enrt_ovridn_flag,
                                           l_enrt_ovrid_thru_dt;
          --
          IF c_oipl_enrolment_info%NOTFOUND THEN
            --
            l_crnt_enrt_cvg_strt_dt :=  NULL;
            --
            --  Check if person is a covered dependent - COBRA.
            --
            IF l_pgm_id IS NOT NULL THEN
              IF l_pgm_rec.pgm_typ_cd LIKE 'COBRA%' THEN
                OPEN c_oipl_cvg_info;
                FETCH c_oipl_cvg_info INTO l_dpnt_cvrd_flag;
                CLOSE c_oipl_cvg_info;
              END IF;
            END IF;
          --
          END IF;
          --
          CLOSE c_oipl_enrolment_info;
	  if g_debug then
          hr_utility.set_location('close c_OIEI: ' || l_proc, 10);
	  end if;
        --
        END IF;
	if g_debug then
        hr_utility.set_location('determine prev elig', 10);
	end if;
        --
        -- Bug 2677804 We need to see the override case here.
        IF ( l_enrt_ovridn_flag = 'Y' AND l_enrt_ovrid_thru_dt >= l_lf_evt_ocrd_dt)  THEN
           l_enrt_ovridn_flag :=  'Y';
        ELSE
           l_enrt_ovridn_flag :=  'N';
        END IF;
        --
        -- Determine if the person was previously eligible for this comp object.
        --
        IF (l_oipl_id IS NULL) THEN
          --
          ben_pep_cache.get_pilpep_dets
            (p_person_id         => p_person_id
            ,p_business_group_id => p_business_group_id
            ,p_effective_date    => l_effective_date_1
            ,p_pgm_id            => l_pgm_rec.pgm_id
            ,p_pl_id             => l_plan_rec.pl_id
            ,p_plip_id           => null
            ,p_ptip_id           => null
            ,p_inst_row          => l_prevpep_rec
            );
          --
          if l_prevpep_rec.elig_flag is null
          then
            --
            l_previous_eligibility := 'N';
            --
          else
            --
            l_previous_eligibility := l_prevpep_rec.elig_flag;
            --
          end if;
          --
	  if g_debug then
          hr_utility.set_location('close c_PEFP: ' || l_proc, 10);
	  end if;
        --
        ELSE
          --
          ben_pep_cache.get_pilepo_dets
            (p_person_id         => p_person_id
            ,p_business_group_id => p_business_group_id
            ,p_effective_date    => l_effective_date_1 --p_effective_date
            ,p_pgm_id            => l_pgm_rec.pgm_id
            ,p_pl_id             => l_plan_rec.pl_id
            ,p_opt_id            => l_oipl_rec.opt_id
            --
            ,p_inst_row          => l_prevepo_rec
            );
          --
          if l_prevepo_rec.elig_flag is null
          then
            --
            l_previous_eligibility := 'N';
            --
          else
            --
            l_previous_eligibility := l_prevepo_rec.elig_flag;
            --
          end if;
          --
	  if g_debug then
          hr_utility.set_location('close c_PEFO: ' || l_proc, 10);
	  end if;
          --
        END IF;
        l_pl_enrt_cd :=               l_plan_rec.enrt_cd;
        l_pl_enrt_rl :=               l_plan_rec.enrt_rl;
        --
        -- Determine if the compensation object requires or allows
        -- an election change If life event mode
        --
	if g_debug then
        hr_utility.set_location('ler change stuff', 20);
	end if;
        l_ler_chg_found_flag :=       'N';
        l_ler_chg_oipl_found_flag :=  'N';
        --
        -- See if there is a life event reason to change
        --
	if g_debug then
        hr_utility.set_location('ler change stuff not null stuff', 20);
        hr_utility.set_location(' Op c_lce_info: ' || l_proc, 10);
	end if;
        --
        determine_ben_settings(
          p_pl_id                     => l_pl_id,
          p_ler_id                    => p_ler_id,
          p_lf_evt_ocrd_dt            => l_lf_evt_ocrd_dt,
          p_ptip_id                   => l_ptip_id,
          p_pgm_id                    => l_pgm_id,
          p_plip_id                   => l_plip_id,
          p_oipl_id                   => l_oipl_id,
          p_just_prclds_chg_flag      => FALSE,
          p_enrt_cd                   => l_ler_enrt_cd,
          p_enrt_rl                   => l_ler_enrt_rl,
          p_auto_enrt_mthd_rl         => l_ler_auto_enrt_rl,
          p_crnt_enrt_prclds_chg_flag => l_ler_enrt_prclds_chg_flag,
          p_dflt_flag                 => l_ler_dflt_flag,
          p_enrt_mthd_cd              => l_ler_enrt_mthd_cd,
          p_stl_elig_cant_chg_flag    => l_ler_stl_elig_cant_chg_flag,
          p_tco_chg_enrt_cd           => l_tco_chg_enrt_cd,
          p_ler_chg_oipl_found_flag   => l_ler_chg_oipl_found_flag,
          p_ler_chg_found_flag        => l_ler_chg_found_flag,
          p_enrt_cd_level             => l_enrt_cd_level);
      if g_debug then
        hr_utility.set_location(' Cl c_lce_info: ' || l_proc, 10);
      end if;
        --
        -- Determine enrt codes/rules method codes/rules then
        -- figure out if electable.
        --
        -- Initially set to ler_chg values if not null
        --
        IF l_ler_enrt_cd IS NOT NULL THEN
          l_pl_enrt_cd :=  l_ler_enrt_cd;
          l_pl_enrt_rl :=  l_ler_enrt_rl;
        ELSIF l_oipl_rec.enrt_cd IS NOT NULL THEN
          l_pl_enrt_cd :=  l_oipl_rec.enrt_cd;
          l_pl_enrt_rl :=  l_oipl_rec.enrt_rl;
        END IF;
        IF l_oipl_id IS NULL THEN
          IF    l_ler_enrt_mthd_cd IS NOT NULL
             OR l_ler_auto_enrt_rl IS NOT NULL THEN
            l_pl_enrt_mthd_cd :=  l_ler_enrt_mthd_cd;
            l_pl_auto_enrt_rl :=  l_ler_auto_enrt_rl;
          END IF;
        ELSE
          --
          -- below, if ler_chg row found then code will always
          -- be not null since comes from a decode of the flag.
          --
          IF l_ler_chg_oipl_found_flag = 'Y' THEN
            l_pl_enrt_mthd_cd :=  l_ler_enrt_mthd_cd;
            l_pl_auto_enrt_rl :=  l_ler_auto_enrt_rl;
            --
            IF l_ler_enrt_mthd_cd = 'A' THEN
              --
              l_oipl_auto_enrt_flag :=  'Y';
            --
            ELSE
              --
              l_oipl_auto_enrt_flag :=  'N';
            --
            END IF;
          --
          ELSE
            IF l_oipl_auto_enrt_flag = 'Y' THEN
              l_pl_enrt_mthd_cd :=  'A';
            ELSE
              l_pl_enrt_mthd_cd :=  'E';
            END IF;
            l_pl_auto_enrt_rl :=  l_oipl_rec.auto_enrt_mthd_rl;
          END IF;
        END IF;
        --
        -- If the ler_chg values were null then now have plan values
        --
        -- Update if still null with values from above in hierarchy
        --
        IF     l_pl_enrt_cd IS NULL
           AND l_pgm_id IS NOT NULL THEN
          l_pl_enrt_cd :=  l_plip_rec.enrt_cd;
          l_pl_enrt_rl :=  l_plip_rec.enrt_rl;
        END IF;
        IF     l_pl_enrt_mthd_cd IS NULL
           AND l_pgm_id IS NOT NULL THEN
          l_pl_enrt_mthd_cd :=  l_plip_rec.enrt_mthd_cd;
          l_pl_auto_enrt_rl :=  l_plip_rec.auto_enrt_mthd_rl;
        END IF;
        --
        -- overlay ptip if value is still null
        --
        IF     l_pl_enrt_cd IS NULL
           AND l_pgm_id IS NOT NULL THEN
          l_pl_enrt_cd :=  l_ptip_rec.enrt_cd;
          l_pl_enrt_rl :=  l_ptip_rec.enrt_rl;
        END IF;
        IF     l_pl_enrt_mthd_cd IS NULL
           AND l_pgm_id IS NOT NULL THEN
          l_pl_enrt_mthd_cd :=  l_ptip_rec.enrt_mthd_cd;
          l_pl_auto_enrt_rl :=  l_ptip_rec.auto_enrt_mthd_rl;
        END IF;
        --
        -- get from program level if not at plan or plip or ptip levels
        --
        IF     l_pl_enrt_cd IS NULL
           AND l_pgm_id IS NOT NULL THEN
          l_pl_enrt_cd :=  l_pgm_rec.enrt_cd;
          l_pl_enrt_rl :=  l_pgm_rec.enrt_rl;
        END IF;
        IF     l_pl_enrt_mthd_cd IS NULL
           AND l_pgm_id IS NOT NULL THEN
          l_pl_enrt_mthd_cd :=  l_pgm_rec.enrt_mthd_cd;
          l_pl_auto_enrt_rl :=  l_pgm_rec.auto_enrt_mthd_rl;
        END IF;

        g_ptip_id :=                  l_ptip_id;
  --  hr_utility.set_location('l_previous_eligibility='||l_previous_eligibility,1064);
  --  hr_utility.set_location('l_crnt_enrt_cvg_strt_dt='||l_crnt_enrt_cvg_strt_dt,1064);
  --  hr_utility.set_location('l_dpnt_cvrd_flag='||l_dpnt_cvrd_flag,1064);
  --  hr_utility.set_location('p_person_id='||p_person_id,1064);
  --  hr_utility.set_location('p_ler_id='||p_ler_id,1064);
  --  hr_utility.set_location('l_pl_enrt_cd='||l_pl_enrt_cd,1064);
  --  hr_utility.set_location('l_pl_enrt_rl='||l_pl_enrt_rl,1064);
  --  hr_utility.set_location('p_effective_date='||p_effective_date,1064);
  --  hr_utility.set_location('p_lf_evt_ocrd_dt='||p_lf_evt_ocrd_dt,1064);
  --  hr_utility.set_location('l_ler_enrt_prclds_chg_flag='||l_ler_enrt_prclds_chg_flag,1064);
  --  hr_utility.set_location('l_ler_stl_elig_cant_chg_flag='||l_ler_stl_elig_cant_chg_flag,1064);
  --  hr_utility.set_location('l_tco_chg_enrt_cd='||l_tco_chg_enrt_cd,1064);
  --  hr_utility.set_location('l_pl_id='||l_pl_id,1064);
  --  hr_utility.set_location('l_pgm_id='||l_pgm_id,1064);
  --  hr_utility.set_location('l_oipl_id='||l_oipl_id,1064);
  --  hr_utility.set_location('l_oipl_rec.opt_id='||l_oipl_rec.opt_id,1064);
  --  hr_utility.set_location('l_plan_rec.pl_typ_id='||l_plan_rec.pl_typ_id,1064);
  --  hr_utility.set_location('p_business_group_id='||p_business_group_id,1064);
  --  hr_utility.set_location('l_new_elctbl_flag='||l_new_elctbl_flag,1064);
  --  hr_utility.set_location('l_rec_assignment_id='||l_rec_assignment_id,1064);
  --      hr_utility.set_location('l_previous_eligibility='||l_previous_eligibility,1064);
       if g_debug then
        hr_utility.set_location(' Dn Det 1: ' || l_proc, 10);
       end if;
        -- Bug 2677804
        if l_enrt_ovridn_flag = 'Y' then
          --
	  if g_debug then
          hr_utility.set_location(' Electable Due to Override ' ,123);
	  end if;
          l_new_elctbl_flag := 'Y' ;
          --
        else
          -- start 5092244

          IF NVL (l_pl_enrt_cd, '-1') = 'RL'
          THEN
             ben_determine_dpnt_eligibility.g_egd_table.DELETE;
             ben_determine_dpnt_eligibility.g_egd_table :=
			      ben_determine_dpnt_eligibility.g_egd_table_temp;
             OPEN c_elig_dpnt (l_epe_id);
	     if g_debug then
             hr_utility.set_location('SS Populating g_egd_table',9909);
	     end if;
             LOOP
	        FETCH c_elig_dpnt INTO l_elig_dpnt;
	        EXIT WHEN c_elig_dpnt%NOTFOUND;
	        l_next_row :=
		             NVL (ben_determine_dpnt_eligibility.g_egd_table.LAST, 0)
		            + 1;
	        ben_determine_dpnt_eligibility.g_egd_table (l_next_row).object_version_number :=
					        l_elig_dpnt.object_version_number;
	        ben_determine_dpnt_eligibility.g_egd_table (l_next_row).elig_dpnt_id :=
						      l_elig_dpnt.elig_dpnt_id;
             END LOOP;

             CLOSE c_elig_dpnt;
         END IF;
         -- end 5092244
          determine_enrolment(
            p_previous_eligibility   => l_previous_eligibility,
            p_crnt_enrt_cvg_strt_dt  => l_crnt_enrt_cvg_strt_dt,
            p_dpnt_cvrd_flag         => l_dpnt_cvrd_flag,
            p_person_id              => p_person_id,
            p_ler_id                 => p_ler_id,
            p_enrt_cd                => l_pl_enrt_cd,
            p_enrt_rl                => l_pl_enrt_rl,
            p_enrt_mthd_cd           => null,
            p_auto_enrt_mthd_rl      => null,
            p_effective_date         => p_effective_date,
            p_lf_evt_ocrd_dt         => p_lf_evt_ocrd_dt,
            p_enrt_prclds_chg_flag   => NVL(l_ler_enrt_prclds_chg_flag, 'N'),
            p_stl_elig_cant_chg_flag => NVL(l_ler_stl_elig_cant_chg_flag, 'N'),
            p_tco_chg_enrt_cd        => NVL(l_tco_chg_enrt_cd, 'CPOO'),
            p_pl_id                  => l_pl_id,
            p_pgm_id                 => l_pgm_id,
            p_oipl_id                => l_oipl_id,
            p_opt_id                 => l_oipl_rec.opt_id,
            p_pl_typ_id              => l_plan_rec.pl_typ_id,
            p_business_group_id      => p_business_group_id,
            p_electable_flag         => l_new_elctbl_flag,
            p_assignment_id          => l_rec_assignment_id,
	    p_run_mode               => p_run_mode,            /* iRec : Added p_run_mode */
            p_update_def_elct_flag   => l_ELCTBL_FLAG -- 5092244 : this parameter is no longer needed.
          );
        end if ;
        --
	if g_debug then
        hr_utility.set_location(' Dn Det Enr 1: ' || l_proc, 10);
	end if;
        IF l_new_elctbl_flag = 'Y' THEN
          --
          -- continue
          --
          NULL;
        --
        ELSIF l_new_elctbl_flag = 'L' THEN
          --
          -- Lose only condition.
          -- If enrolled will deenroll.
          --
          ben_newly_ineligible.main(
            p_person_id         => p_person_id,
            p_pgm_id            => l_pgm_id,
            p_pl_id             => l_pl_id,
            p_oipl_id           => l_oipl_id,
            p_business_group_id => p_business_group_id,
            p_ler_id            => p_ler_id,
            p_effective_date    => p_effective_date);
        if g_debug then
          hr_utility.set_location(' BNI_MN 1: ' || l_proc, 10);
        end if;
          l_new_elctbl_flag :=  'N';
        end if;
      else
        l_new_elctbl_flag:='N';
      end if;
    if g_debug then
      hr_utility.set_location(' Bef dflt flag chk: ' || l_proc, 10);
    end if;
  --    hr_utility.set_location('l_new_elctbl_flag='||l_new_elctbl_flag,1064);
      --
      -- update the choice if it needs it.
      --
    if g_debug then
      hr_utility.set_location('Dflt flag is '|| l_epe_dflt_flag,2121);
      hr_utility.set_location('l_dflt_flag is '||l_dflt_flag,2121);
    end if;
      if l_dflt_flag<> l_epe_dflt_flag or
         l_new_elctbl_flag <>  l_ELCTBL_FLAG then
  --      hr_utility.set_location('Dflt flag changed to '||l_dflt_flag,2121);
  --      hr_utility.set_location('Elct flag changed to '||l_new_elctbl_flag,2121);
  --      hr_utility.set_location('l_pl_id='||l_pl_id,2121);
  --      hr_utility.set_location('l_oipl_id='||l_oipl_id,2121);
        IF p_ler_id IS NOT NULL and
           l_new_elctbl_flag = 'Y' and
            l_ELCTBL_FLAG = 'N' THEN
          g_electable_choice_created :=  TRUE;
        END IF;
	if g_debug then
        hr_utility.set_location(' BEPECA_UEPEC 1: ' || l_proc, 10);
	end if;
        ben_elig_per_elc_chc_api.update_perf_elig_per_elc_chc
          (p_elig_per_elctbl_chc_id  => l_epe_id,
           p_dflt_flag               => l_dflt_flag,
           p_elctbl_flag             => l_new_elctbl_flag,
           p_object_version_number   => l_epe_ovn,
           p_effective_date          => p_effective_date,
           p_program_application_id  => fnd_global.prog_appl_id,
           p_program_id              => fnd_global.conc_program_id,
           p_request_id              => fnd_global.conc_request_id,
           p_program_update_date     => sysdate
        );
	if g_debug then
        hr_utility.set_location(' Dn BEPECA_UEPEC 1: ' || l_proc, 10);
	end if;
        --
        --bug#3726552 - update the default flag on benefit row
        l_enrt_bnft.enrt_bnft_id  := null;
        open c_enrt_bnft(l_epe_id);
        fetch c_enrt_bnft into l_enrt_bnft;
        close c_enrt_bnft;
        if l_enrt_bnft.enrt_bnft_id is not null then
          --
          ben_enrt_bnft_api.update_enrt_bnft
            (p_enrt_bnft_id      => l_enrt_bnft.enrt_bnft_id
            ,p_dflt_flag         => 'Y'
            ,p_object_version_number => l_enrt_bnft.object_version_number
            ,p_effective_date        => p_effective_date);
        end if;
        --
      end if;
      if g_debug then
      hr_utility.set_location(l_proc||' End c_choices loop: ',10);
      end if;
    end loop;
    --
  end if;
  if g_debug then
  hr_utility.set_location('Leaving: '||l_proc,10);
  end if;
END update_defaults;
-- end of package, below
END ben_enrolment_requirements;

/
