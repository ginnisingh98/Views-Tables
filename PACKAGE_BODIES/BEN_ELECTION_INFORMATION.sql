--------------------------------------------------------
--  DDL for Package Body BEN_ELECTION_INFORMATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ELECTION_INFORMATION" as
/* $Header: benelinf.pkb 120.43.12010000.22 2010/05/03 09:59:00 pvelvano ship $ */
--
/*
+=============================================================================+
|                       Copyright (c) 1998 Oracle Corporation                 |
|                          Redwood Shores, California, USA                    |
|                               All rights reserved.                          |
+=============================================================================+
--
Name
        Determine Election Information
Purpose
        This process creates or updates the participant's record with
        information about plans and options elected.  This process
        determines the effective date of new elections.  The enrollment
        coverage end date for comp objects de-enrolled is in a later
        function.
History
     Date          Who          Version   What?
     ----          ---          -------   -----
     20 Apr 98     jcarpent     110.0     Created
     06 Jun 98     jcarpent     110.1     Added call to manage_enrt_bnft
     08 Jun 98     jcarpent     110.2     added busines group id to manage_enrt
                                          _bnft
     10 Jun 98     jcarpent     115.1     changed prtt_rt_val eff date to real
                                          eff dt
     11 Jun 98     jcarpent     115.2     On comp object ch do create then
                                          delete enrt When delete use effective
                                          _dt-1 for correctin
     15 Jun 98     jcarpent     115.3     Added p_validate flag.
                                          When delete use ed-1 for update not
                                          correct. Make rt_strt_dt and cvg_strt
                                          _dt required.
     18 Jun 98     jcarpent     115.4     Added business group to everything
                                          Changed out nocopy parameters
     23 Jun 98     jcarpent     115.5     Check status code for per_in_ler.
     08 Jul 98     Jmohapat     115.6     added batch who columns to api
                                          calls(ben_prtt_enrt_result_api.
                                          create/update_enrollment,
                                          ben_enrt_bnft_api. updateenrt_bnft
     24 Jul 98     jcarpent     115.7     Fixed message removed fnd_message.get
     28 Jul 98     jcarpent     115.8     Added flex fields.
     22 SEP 98     GPERRY       115.9     Corrected error messages
     25 SEP 98     bbulusu      115.10    Added out nocopy parameters (warnings) at
                                          end of election_information and in
                                          the call to ben_ prtt_enrt_rslt_api.
                                          create_enrollment
     12 Oct 98     jcarpent     115.11    model changes to prv and pen
     19 Oct 98     jcarpent     115.12    Moved rate start date calculation.
     22 Oct 98     jcarpent     115.13    Handle SAAEAR cvg_mlt_cd
                                          Update csd if bnft_amt changes.
                                          Keep old orgnl_enrt_dt if plan stays
                                          same
     26 Oct 98     jcarpent     115.14    Updated prv to non-datetracked
     27 Oct 98     jcarpent     115.15    Changed election_rate_information
     29 Oct 98     jcarpent     115.16    Fixed calls to ben_prtt_rt_val_api.
                                          Don't compare old elctns made date
     29 Oct 98     stee         115.17    Get rt_typ_cd and rt_mlt_cd from
                                          enrt_rt.
     31 Oct 98     bbulusu      115.18    Added per_in_ler_d to delet_enrolment
     04 Nov 98     jcarpent     115.19    Call annual_to_period/period_to_anual
                                          Pass different OVN to create_enrt
     05 Nov 98     jcarpent     115.20    Use prv_id from enrt_rt not one
                                          passed
     01 Dec 98     jcarpent     115.21    Made p_ovn optional (get it if null)
     10 Dec 98     stee         115.22    Fixed bnf warning.
     15 Dec 98     jcarpent     115.23    Added call to Create_debit_ledger..
     31 Dec 98     lmcdonal     115.24    Better debug messages.
     12 Jan 98     maagrawa     115.25    Modified calls to
                                          ben_prtt_rt_val_api. (Column
                                          acty_base_rt_id added to
                                          table ben_prtt_rt_val).
     01 Feb 99     jcarpent     115.26    Changed calls to update prv to use
                                          ended_per_in_ler_id.
     24 Feb 99     jcarpent     115.27    Changed rate cursor in ele_rt_info
                                          to include union to join to choice
     03 Mar 99     yrathman     115.28    Added bnft_ordr_num logic
     04 Mar 99     jcarpent     115.29    Don't end old enrollment if it is
                                          the interim enrollment.
     24 Mar 99     jcarpent     115.31    Always call manage_enrt_bnft.
                                          Delete/end date rate on bnft_amt chg
     29 Mar 99     thayden      115.32    Added call to ben_ext_chlg.
     05 Apr 99     mhoyes       115.33    Un-datetrack per_in_ler_f changes.
     06 May 99     jcarpent     115.34    Write new prv if suspended
     19 May 99     lmcdonal     115.35    Overloaded election_information to chg
                                          which save point to set and rollback.
                                          Because create_enrollment was also
                                          changed, changed the call.
     04 Jun 99     lmcdonal     115.36    Added loading of result.comp_lvl_cd
     11 Jun 99     jcarpent     115.37    Fixed messages.
     09 Jul 99     jcarpent     115.38    Added checks for backed out nocopy pil
     20 Jul 99     jcarpent     115.39    New result for bnft amt change.
     12 Aug 99     gperry       115.40    Added ben_env_object call for cases
                                          when the process is being called
                                          from forms. This makes all the
                                          caching work correctly.
     12 Aug 99     GPERRY       115.41    Backported 115.38 to add environment
                                          package call.
     24 Aug 99     GPERRY       115.42    Version 115.40 brought to top.
     30 Aug 99     shdas        115.43    Added ordr_num columns to create_enrollment.
     14 Sep 99     shdas        115.44    changed election_information to add bnft_val
     29 Sep 99     jcarpent     115.45    If pen_id is null get from choice.
     12 Oct 99     shdas        115.46    changed election information.
     12-Nov-1999   jcarpent     115.47    Added enrt_bnft/choice globals
     12-Nov-1999   jcarpent     115.48    Null out nocopy globals after calls.
     12-Nov-1999   lmcdonal     115.49    Better debugging messages
     17-Nov-1999   pbodla       115.50    l_acty_base_rt_id as passed to
                                          ben_determine_date.rate_and_coverage_dates
                                          ,ben_determine_date.main
                                          which is used as context for rules.

     19-Nov-1999   pbodla       115.51    elig_per_elctbl_chc_id  passed to
                                          benutils.formula.
     29-Nov-1999   jcarpent     115.52  - Write new prv most of the time in
                                          order to fix element entries.
                                          bug 3556
                                        - Write new enrollment result if bnft
                                          amount changed, put back in because
                                          removed in version 115.46.
                                        - Added lee_rsn/enrt_perd to del_enrt.
     14-Dec-1999   jcarpent     115.53  - Removed 'STRTD' restriction on pil.
     16-Dec-1999   jcarpent     115.54  - Recompute cvg date if bnft amt chg
     03-Jan-2000   lmcdonal     115.55    Bug 1121022. Do not re-calc rt-strt-dt
                                          if a prtt-rt-val row exists.
     20-Jan-2000   maagrawa     115.56   Pass payroll_id to ben_distribute_rates
     21-Jan-2000   lmcdonal     115.57    If the rate is mult-of-cvg and cvg
                                          can be entered at enrt, re-calc rate.
                                          Bug 1118016.
     25-Jan-2000   maagrawa     115.58    Pass per_in_ler_id to
                                          create_debit_ledger_entry.
     27-Jan-2000   thayden      115.59    New parameters for change event log.
     02-Feb-2000   jcarpent     115.60    Remove l_effective_date adjustment.
     24-Feb-2000   maagrawa     115.61    Re-open the rate only if the new
                                          rate start date is before the old
                                          rate end date.
     26-Feb-2000   maagrawa     115.62    Added two parameters dpnt_actn_warning
                                          and bnf_actn_warning to the procedure
                                          update_enrollment.(1211553)
     15-Mar-2000   shdas        115.63    Added parameters p_old_pl_id,p_old_oipl_id,
                                          p_old_bnft_amt to log_benefit_chg(create portion)
                                          for extract( bug 1187479).
     20-Mar-2000   shdas        115.64    call create_debit_ledger_entry if result
                                          is not suspndd(1217192).
     23-Mar-2000  lmcdonal      115.65    Bug 1247110 - When calling update_
                                          enrollment, pass eot as cvg_thru_dt.
     30-Mar-2000  maagrawa      115.66    Re-use the enrollment result, if it
                                          exists, when the choice is marked as
                                          currently enrolled. (4875).
     05-Apr-00  lmcdonal        115.67    Bug 1253007.  Using globals for epe, pil,
                                          pel, pen, enb, asg data for performance.
     06-Apr-2000  mmogel        115.68    Added tokens to message calls to make
                                          the messages more meaningful
     07-Apr-00  lmcdonal        115.69    Call 'clear_enb' procedure.
     13-Apr-00  jcarpent        115.70    Call clear_enb cache procedure at end
                                          and refetch after pen_api is called
                                          to handle recursive calls.
     13-Apr-00  lmcdonal        115.71    Change globals to locals
     04-May-00  shdas           115.72    added parameters p_use_balance_flag
                                          ,p_enrt_rt_id to period_to_annual and
                                          changed cmplt_yr_flag to "N"(5043)
     05-may-00  jcarpent        115.73    If form passes in wrong result_id,
                                          (will somtimes pass in default/not
                                          currently enrolled) use value from
                                          epe.  (5073)
     19-may-00  shdas           115.74    Always calculate period_to_annual.
     22-May-00  lmcdonal        115.75    update enb globals right before call
                                          to manage_enrt_bnft.
     28-Jun-00  shdas           115.76    Alwayss calculate period to annual with
                                          complt yr flag = yes.Calculate communicated
                                          based on periodic value.
     28-Jun-00  jcarpent        115.77    Bug 4936: Use new cvg_strt_dt if sched
                                          enrt and plan is for 125 or 129
                                          regulation.
     19-Jul-00  rchase          115.78    Bug 5353: bug 5353 - iterim cvg not selecting
                                          previous cvg if previous cvg exists in same
                                          pl or pl_typ
     20-jul-00  kmahendr        115.79    Bug5369 - Not able to save if the same plan is selected
                                          in a new life event after electing a different plan
                                          Result ID is assigned only when form is not sending any
                                          result in election_information procedure
     15-Aug-00  maagrawa        115.80    Added procedure election_information_w
                                          (Wrapper for self-service).
     07-Sep-00  maagrawa        115.81    Modified exception handling for
                                          self-service wrapper.
     09-Oct-00  maagrawa        115.82    Added checks for min/max benefit
                                          amounts in self-service wrapper.
                                          (1417250).
     06-Nov-00  tilak           115.83    bug 1480407 when entr at enrl and calculation
                                          cales the rate calculation for enterd value
     16-Nov-00  jcarpent        115.84    Bug 1495632.  If no benefit amounts then
                                          was always creating a new pen.
     14-Dec-00  maagrawa        115.85    Overloaded the self-service wrapper.
     15-dec-00  tilak           115.86    bug:1527086 funcation added to calculate the
                                          erlst_deenrt_dt , this function called wheenever the coverage
                                          date calcualted and the cvg date differ from cvg dt of ele_chc
     02-Jan-01  Ikasire         115.87    Bug 1543438 Standart rate entered at enrollment is not
                      saving inputed rate amount. Added rt_mlt_cd <> 'FLFX' for
                                          the ben_determine_rate.main calling if condition in
                                          election_rate_information procedure.
     05-Jan-01  maagrawa        115.88    Added parameters p_enrt_cvg_strt_dt,
                                          p_enrt_cvg_thru_dt for Individual
                                          Compensation to allow user to
                                          enter the coverage start date and
                                          coverage through date when the codes
                                          say they are enterable (ENTRBL).
     08-Jan-01  maagrawa        115.89    Set the local variable
                                          l_prtt_enrt_rslt_id to
                                          l_global_epe_rec.epe.prtt_enrt_rslt_id
     15-Jan-01  maagrawa        115.90    Modified the self-service wrapper
                                          to handle multiple rates.
     16-Jan-01  mhoyes          115.91  - Added calculate only mode parameter
                                          to election_rate_information.
     24-Jan-01  tilak           115.92    parent rate calucaltion is fixed
                                          bug : 1555624
     09-feb-01  ikasire         115.93    bug 1584238 and 1627373 remove the edit
                                          checking rate start date always to
                                          be after the coverage start date
     09-feb-01  ikasire         115.94    correct the version number
     23-Feb-01  maagrawa        115.95    Modified the error messages 92394,
                                          92395 for self-service.
     06-mar-01  ikasire         115.96    bug 1650517 remove the
                                          p_complete_year_flag => 'Y' parameter
                                          for SAREC condition for cmcd_val
     09-Mar-01  maagrawa        115.97    Added rt_strt_dt and rt_end_dt
                                          parameters to pass rate dates when
                                          they are enterable.
                                          Added support for rt_strt_dt_cd of
                                          ENTRBL(Enterable) and rt_end_dt_cd of
                                          WAENT(1 Prior or Enterable).
     09-Mar-01  maagrawa        115.98    Create/Update the rate whenever the
                                          per_in_ler_id changes.
                                          Added check that the rate start date
                                          should be less than or equal to rate
                                          end date in election_rate_info...
     17-May-01  maagrawa        115.99    Removed use of ben_comp_object and
                                          replaced with ben_cobj_cache.
                                          Modified calls to ben_global_enrt.
     29-May-01  kmahendr        115.100   Modified cursor c_prv2 Bug#1771887
     18-Jun-01  kmahendr        115.101   Bug#1830930-rate end date code is enterable
                                          and rate start dt is not passed thro PUI then
                                          end date is arrived as rate start dt - 1
     20-Jun-01  ikasire         115.102   bug 1840961 added p_enrt_cvg_strt_dt and
                                          p_enrt_cvg_thru_dt to the election_information
                                          procedure call.
     20-Jun-01  ikasire         115.104   this file is 115.102 after backporting version
                                          115.103 for bug 1840961
     25-Jun-01  kmahendr        115.105   The else condition in if code is WAENT is corrected
     01-Jul-01  kmahendr        115.106   Unrestricted changes
     23-Jul-01  kmahendr        115.107   Bug#1807450 - Coverage start date is not computed
                                          if there is any waiting period attached
     23-Jul-01  ikasire         115.108   Bug#1888085 fixed the issue of not calculating the
                                          actual amount for 'Percent of' and
                                          use_calc_acty_bs_rt_flag  is checked
     24-Jul-01  mmorishi        115.109   Election_information_w: Added rt_strt_dt_cd
                                          and person_id parms. Added call to prv_delete.
     06-Aug-01  ikasire         115.110   Bug1913254 added a new cursor to handle the cases
                                          for SAAEAR coverage code and the rate is not
                                          entered at enrollment.
     09-Aug-01  kmahendr        115.111   Bug#1890996 - Added cursor c_abr to check non recur-
                                          ring rate and not to call update_prtt_rt_val to end
                                          previous rate. Assign rate start date to rate end
                                          date if the rate is non-recurring
     17-Aug-01  maagrawa        115.112   Added parameter p_rt_update_mode
                                          to election_information_w.
     28-Aug-01  kmahendr        115.113   Added condition to check necessity to call update
                                          prtt_rt_val
     29-aug-01  tilak           115.114   bug:1949361 jurisdiction code is
                                              derived inside benutils.formula.
     30-aug-01  kmahendr        115.115   Already ended recurring rate is extended in the
                                          subsequent rate - added condition to check old
                                          rate end date
     31-aug-01  pbodla          115.117   Version 116 is actually version 111 with changes
                                          in version 114.
     25-Oct-01  kmahendr        115.118   Bug#2055961-codes starting with 1 prior handled
                                          before updating prtt_rt_val
     5-Dec-01   dschwart        115.119   - Bug#2141172: changed call to ben_determine
                                          _date.rate_and_coverage_dates to use life
                                          event date.
    18-dec-01   tjesumic        115.120   - cwb changes
    20-dec-01   ikasire         115.121   added dbdrv lines
    01-feb-02   ikasire         115.122   Bug 2172036 populate assignment_id in the pen records
                                          the one available in epe record
    12-Feb-02   ikasire         115.123   Bug 2212194 If there exist multiple rates while using
                                          SAAREC code for Coverage Calculation.
    12-Feb-02   ikasire         115.125   Bug 2212194 This is version 115.23 since we gave a
                                          backport to ADS in 115.124
    13-Feb-02   ikasire         115.126   Bug 2223694 When Rate code SAREC and the Coverage is
                                          not enter value at enrollment, defined amount and
                                          element entries not calculated.
    26-Feb-02   rpillay         115.127   Bug 2093830 Changed from p_effective_date
                                          to lf_evt_ocrd_dt in c_enrt_rt cursor
    27-Feb-02   tjesumic        115.128   bug : 1794303 fixed by passing parameter
                                          p_element_type_id  to annual_to_period
    04-Mar-02   kmahendr        115.129   bug#2048236 - added cursors  - c_element_type and
                                          if condition before update_prtt_rt_val -
                                          removed changes made in 128 per Tilak.
    14-Mar-02   rpillay         115.130   UTF8 Changes Bug 2254683
    23-May-02   kmahendr        115.131   Changed logic for communicated value
                                115.132   No changes
    04-Jun-02   kmahendr        115.133   Bug#2398448 and #2392732 - enrt_id is passed instead
                                          of electable choice id for computing communicated
                                          value.
    08-Jun-02   pabodla         115.134   Do not select the contingent worker
                                          assignment when assignment data is
                                          fetched.
    20-Jun-02   ikasire         115.135   Bug 2407041 wrong communication amount
                                          when payroll changes.
    06-Jun-02   ikasire         115.136   Bug 2483991 and Interim Ehancements.
    07-Aug-02   ikasire         115.136   Bug 2483991 wrong datetrack mode was passed
                                          to delete enrollment if the user replaces the
                                          defaulted enrollment with the some other
                                          compensation object.
    08-Aug-02   ikasire         115.137   Bug 2502633 Interim enhancements.This needs to
                                          go with the bensuenr.pkb/pkh as we are using a
                                          package global variable here.
    29-Aug-02   kmahendr        115.138   Bug#2207956 -sec 125 or 129 references removed and
                                          codes added for starting a new result.
    05-Sep-02   ikasire         115.140   Bug 2547005 and 2543071 for interim changes
    28-Sep-02   ikasire         115.141   Bug 2600087 fixes for deenrolled result
    28-Sep-02   ikasire         115.141   Bug 2600087 fixed error making infinit loop
    10-Oct-02   shdas           115.143   Changed election_information_w for multirates
    11-Oct-02   vsethi          115.144   Rates Sequence no enhancements. Modified to cater
                                          to new column ord_num on ben_acty_base_rt_f
    15-Oct-02   ikasire         115.145   Bug 2627078 fixes
    28-Nov-02   lakrish         115.146   Bug 2499754, set tokens for error messages
                                          BEN_91711_ENRT_RSLT_NOT_FND and
                                          BEN_91453_CVG_STRT_DT_NOT_FOUN
    02-Dec-02   kmullapu        115.147   out nocopy param added to election_information_w
    13-Dec-02   ikasire         115.148   Bug 2675486 FSA Dont recmpute the fsa if
                                          there is no change in the annual amount
                                          within the plan year in the subsequent
                                          life events
    27-Dec-02   ikasire         115.149   Bug 2677804 override thru date changes
    02-jan-03   hmani           115.149   Bug 2714383 - Passed pen_attributes
       					  after checking whether its equalto hr_api.g_varchar2
    					  Created a new function called 'decd_attribute'
    09-jan-03   kmahendr        115.151   Bug#2734491 - Rates with child code is treated as
                                          parent for annual target.
    23-Jan-03   ikasire         115.152   Bug#2149438 Used the overloaded annual_to_period
                                          procedure to determine the defined amount for
                                          FSA calculations.
    24-Jan-03   ikasire         115.153   Added nocopy changes
    13-Feb-03   kmahendr        115.154   Added a parameter to call -acty_base_rt.main
    13-feb-03   hnarayan	115.155   hr_utility.set_location - 'if g_debug' changes
    06-Mar-03   ikasire         115.156   Bug2833116 rounding issue for FSA - annual rates
    12-May-03   ikasire         115.157   Bug 2957028 nocopy bug fix for call to
                                          ben_determine_activity_base_rt.main procedure
    22-May-03   kmahendr        115.158   Fix for new rt mlt cd - ERL
    29-May-03   ikasire         115.159   Bug 2976103 for nonrecurring element entries
    22-Jul-03   tjesumic        115.160   rate start dt is passes as param to rate updated
                                          when the rate strt dt is enterable
    22-Jul-03   ikasire         115.161   brought forward 115.159 version.
                                          DONT USE 115.160 -- BUG 3053267
    13-Aug-03   kmahendr        115.162   Fix for new cvg_mlt_cd - ERL
    26-Sep-03   kmahendr        115.163   Fix for new rt strt dt codes.
    08-Oct-03   lakrish         115.164   Bug 3181158, for Enterable coverages
                                          raise min-max error properly even if
                                          default value is not defined for
                                          Coverage.
    15-Oct-03   mmudigon        115.165   Bug 2775742. Update rates for rt chg
                                          process when element/input attached
                                          to abr is changed.
    30-Oct-03   tjesumic        115.165   #  2982606  new procedure backout_future_coverage added to
                                115.166    backout the future dated coverage and the plan in not continued
                                          The backout caled for result level backed out
                                          related changes in  benbolfe , bendenrr ,benleclr
    14-Nov-03   ikasire         115.167   Bug 3253180 Get the right l_rt_val from the
                                          annual value when p_rt_val is null for
                                          l_enrt_rt.entr_ann_val_flag = 'Y'
                                          also - if the same plan yr period if there is no change
                                          in the annual contribution dont recompute the rates.
    18-Nov-03   kmahendr        115.169   Bug#3260564 - added cursor c_future_rates to delete future
                                          dated prtt_rt_val
    20-Nov-03   mmudigon        115.170   Bug#3250360. Changes to
                                          election_rate_information. cursors
                                          c_prtt_rt_val_1 and c_prtt_rt_val_2
                                          to pick the correct old prv
   21-nov-03    nhunur         115.171    setting the flags to 'N' if the cursor
                                          c_prtt_rt_val_2 does not return any rows.
   25-nov-03    tjesumic       115.172     hr_utility.debug_enabled added to  all public procedure
   16-Jan-04    kmahendr       115.173    Bug#3364910- added payroll change condition for
                                          fSA plans
   20-Jan-04    kmahendr       115.174    Bug#3378865 - added cursor c_abr to check for
                                          ele_entry_val_cd change
   21-Jan-04    mmudigon       115.175    Bug#3378865 - modified data type for
                                          variable l_ele_entry_val_cd
   03-Feb-04    kmahendr       115.176    Bug#3400822 - the subquery modified with                                                    effective_end_date condition to return only one
                                          row - cursor c_enrt_rslt
   16-Feb-04    mmudigon       115.177    Bug 3437083. Logic to determine abr
                                          assignment changes
   24-Feb-04    stee           115.178    Bug 3457483. Check the assignment to use code
                                          in activity base rate when selecting the
                                          assignment.
   08-mar-04    hmani          115.179    Bug 3488286 - Added p_lf_evt_ocrd_date parameter to
                                          BEN_DETERMINE_ACTIVITY_BASE_RT call
   19-Mar-04    ikasire        115.180    Added new procedure call for rate_periodization_rl
   23-Mar-04    ikasire        115.181    GSCC error
   05-Apr-04    bmanyam        115.182    Bug: 3547233. Copied annual value to l_ann_rt_val variable
                                          for prtt_enrt_rt record for 'Set Annual Value to Coverage'
                    					  calculation method.
  09-Apr-04     kmahendr       115.183    Bug#3540351 - rt_val and cmcd_val assigned
                                          value 0 if the value is negative.
  26-Apr-04     kmahendr       115.185    Bug#3510633 - person_id added to annual_to_period
                                          function
  07-jun-04      nhunur        115.186    bug 3602579 - original enrt date fix for waive oipls
  08-jun-04     mmudigon       115.187    FONM
  02-jul-04     rpgupt         115.188    3733745 - Do not delete future enrts. if it is an
                                          interim.
  15-Jul-04     kmahendr       115.189    Bug#3702090 - added enrt_mthd_cd condition while creating
                                          new result - new flex plan enrollment is created when
                                          override flex rate"
  27-Jul-04     mmudigon       115.190    Bug 3797946. Logic to determine
                                          change in extra input values
  02-Aug-04     ikasire        115.191    Bug 3804813 to recompute the rates if
                                          l_enrt_rt.entr_bnft_val_flag = 'Y'
  23-Aug-04     mmudigon       115.192    CFW. Added p_act_item_flag
                                          2534391 :NEED TO LEAVE ACTION ITEMS
  09-sep-04     mmudigon       115.193    CFW. Continued
  09-sep-04     mmudigon       115.194    CFW. p_act_item_flag no longer needed
  20-Sep-04     ikasire        115.195    Bug 3787832 backout only the future results
                                          of past life events.
  30-sep-04     mmudigon       115.196    Bug 3854378. In proc
                                          election_rate_information, old prv is
                                          re-opened only when it is necessary
 11-Oct-04     tjesumic        115.197    future backout only for a pgm, pgm_id added in validation
 20-nov-04     nhunur          115.198    4020061 - bnft_val should be null if enrt_bnft_id is passed as null.
 23-Nov-04     kmahendr        115.199    start_date passed for communicate val cal for fsa
                                          to handle new rate codes
 30-Nov-04     mmudigon        115.200    Bug 4018874. Changes to cursor
                                          c_fut_pen in backout_future_coverage
 01-Dec-04     ikasire         115.201    Bug 3988565 date type changed for a parameter  for SSBEN
 12-Dec-04     vvprabhu        115.202    Bug 3980063. SSBEN Trace enhnacement. Changes to exception
                                          handling in wrapper packages, addition of debug statements
					  and logic to enable trace based on profile value.
 22-Dec-04     maagrawa        115.203    Added more parms to election_information_w
                                          to have both procedures in sync.
 23-Dec-04     tjesumic        115.204    new param p_prtt_enrt_rslt_id added backout_future_coverage
                                          p_prtt_enrt_rslt_id nullified if the rslt is backedout
 28-Dec-04     kmahendr        115.205    Bug#4078828 - element_type and input_value fetched
                                          based on rate start date in case of start date code
                                          based on election
 29-Dec-04     tjesumic        115.206    continuation of 115.204 # 3945471 new cursor c_csr added
                                          to validate the future cvrd results deleted
 30-dec-2004    nhunur         115.207    4031733 - No need to open cursor c_state.
 04-Jan-04     tjesumic        115.208    continuation of 115.204 # 3945471
 04-Jan-04     tjesumic        115.209    continuation of 115.204  future backoit skipped for cwb,abs,comp ler
 11-Jan-04     ikasire         115.210    CF Interim Suspended BUG 4064635
 07-Feb-05     tjesumic        115.211    backout_future_result is removed, future cvg taken care
                                          in delete_enrollment # 4118315
 09-Feb-05     ikasire         115.212    Bug 4173505 Need to sspndd_flag to update_enrollment otherwise
                                          suspended enrollment will be carried forward with suspend flag
                                          checked even it is not required.
 10-Feb-05     mmudigon         115.213   Bug 4157759. Added proc
                                          handle_overlap_rates()
 09-Mar-05     vvprabhu         115.214   Bug 4216475 changes to election_information_w to
                                          validate coverage amount when default is outside
					  coverage range
 13-Apr-05     ikasire          115.215   Added a new parameter to manage_enrt_bnft procedure
 26-May-05     vborkar          115.216   Bug 4387247 : In wrapper method exception
                                          handlers changes made to avoid null errors
                                          on SS pages
 01-Jun-05     vborkar          115.217   Bug 4387247 : Modifications to take care of
                                          application exceptions.
 17-Jun-05     vborkar          115.218   Bug 4436578 : In SS wrapper app exception
                                          handler added generic(default) code.
 12-jul-05     ssarkar          115.219   BUG 4203714 : Modified c_comp_obj_name for proc handle_overlap_rates.
 29-jul-05     tjesumic         115.230   BUG 4510798 : fonm variable intialised on election information
 11-aug-05     ssarkar          115.221   BUG 4203714 : Rtrim to chop off the trailing spaces
 17-aug-05     kmahendr         115.222   Bug#4549089 - new result is created only
                                          if the per_in_ler is different in sspd enroll
 25-Aug-05     ikasire          115.223   Bug 4568911 fix
 08-Sep-05     kmahendr         115.224   Bug#4555320 - new result is not created
                                          if the per in ler ids are same
 27-Sep-05     vborkar          115.225   Bug 4543745 : Avoid election-information call for
	                                        electable choices whose existing enrollments
																					cannot be changed in current LE.
 03-Nov-05     rbingi           115.226   4710188: removed case entr_bnft_val='Y' in if condition of
                                            call to Std rates proc. will be called only for Post-Enrollment
 03-Nov-05     rbingi           115.227   reverted previous version changes
 08-Nov-05     rbingi           115.228   4710188: Calling acty_base_rt proc for ERL case only if
                                           rt value is not enterable
 02-dec-05    ssarkar           115.229   4775760 : Creat prtt_rt_val not be to called if sspndd_flag = 'Y' and prtt_rt_val is already present.
 12-dec-05    ssarkar           115.230   4775760,4871284 : rollback fix of 115.229 and commented the restrcition of Unrestricted.
 11-jan-06    ikasire           115.231   4938498 fixed c_prv2 cursor to exclude voided and backedout
                                          records.
 16-Jan-06    abparekh          115.232   Bug 4954541 : If bnft_amt is nullified, create new enrollment
 10-Feb-06    kmahendr          115.233   Bug#5032364 - before delete prtt row, it
                                          is captured in ben_le_clsn_n_rstr table
                                          for backout purpose
 22-Mar-06    rtagarra          115.234   Bug#5099296 : Changed the sspndd_flag parameter passed to update_enrollment.
 23-Mar-06    kmahendr          115.235   Bug#5105122 - coverage date is recomputed
                                          before create_enrollment
 16-Jun-06    rbingi            115.236   Bug#5259005-Moved code for calulating ann_rt_val, rt_val based in
                                           entr_val flag to proc election_rate_information from pld.
 09-Jul-06    rbingi            115.237   Bug#5303167-corrected if condition in proc elec_rt_info
 17-jul-06    ssarkar           115.238   Bug 5375381 - ben_determine_activity_base_rt being called for interim.
 03-aug-06    ssarkar           115.239   bug 5417132 - passing comp_lvl_cd to update_enrollment call
 27-Sep-06    ikasired          115.240   Bug 5502202 fix for Interim Rule. We need to recompute the rates when
                                          interim rule returs amounts.
 10-Oct-06    abparekh          115.241   Bug 5572484 : Take backup in BEN_LE_CLSN_N_RSTR only if the correction
                                                        is due to a new life event.
 11-Oct-06    ssarkar           115.242   Bug 5555269 - commented out fix of bug 5032364 as well 5572484
 12-Oct-06    gsehgal           115.243   Bug 5584813 - move the code to calculate rates to procedure
					  calc_rt_ann_rt_vals and also call this when cvg_mlt_cd='SAAEAR'
 17-Oct-06    abparekh          115.244   Bug 5600697 - In procedure ELECTION_INFORMATION
                                                        Set P_PRTT_ENRT_RSLT_ID only if
                                                        PRTT_ENRT_RSLT_STAT_CD is NULL
20-Oct-06     bmanyam           115.245   5612091 cursor c_enrt_rt corrected.
                                          join ecv with enb was incomplete. OR-ed with epe
26-Oct-06     ssarkar           115.246   5621049  : dont compare the cvg amt of option2 with option1
10-Nov-06     ssarkar           115.247   bug 5653168 : resetting g_use_new_result for any exception raised in election_information
18-nov-06     ssarkar           115.248   Bug 5717428 - passed life event occurred date to rate_and_coverage_dates
24-jan-07     stee              115.249   Bug 5766477 - Restore dependent
                                          coverage when future enrollments
                                          are deleted.
05-apr-07     ssarkar           115.250   bug 5942441 - overiding info to be passed to subsequent prv
08-may-07     gsehgal           115.251   bug 6022111 - wrong prv record was being fetched
                                          for parent record in cursor c_prv2
11-May-07     ikasired          115.252   Bug 5985777. When action items are completed in future
                                          we need to extend the suspended enrollments with future
                                          delete store the future completed action items in
                                          backup table for future reinstate in the event
                                          the current life event backout.
25-May-07     bmanyam           115.253   6057157 : -- same as above--
                                          Reopen future interim PRV records. This was
                                          missed out in the prev version.
21-Jun-07     swjain		115.254   6067740 - Updated procedure election_rate_information for SAREC
                                          cases.
26-Jun-07     sshetty		115.255   6132571--changed logic to detect the
                                          payroll id changes by calling
                                          get_abr_assignment for the old
                                          rate start date
24-Aug-07     gsehgal           115.256   bug 6337803 - dont delete the enrollment if enrollment to be suspended has same
                                          comp object as interim
05-Oct-07     swjain            115.258   Removing the fix in 6067740
23-Oct-07     rgajula           115.259   Bug 6503304 : Passed lf_evt_ocrd_dt instead of p_effective_date to procedures get_ptip_dets, get_plip_dets, get_oipl_dets,get_pl_dets
                                           to get the details as of life event occured date (open life event case)
28-aug-08     bachakra          115.260   Bug 7206471: adjust the coverage and rates when event date life event
                                          is processed after fonm life event in the same month.
06-Jan-09     sallumwa          115.261   Bug 7557403 : Modified procedure election_rate_information to set the
					  global cvg and rate start date variables.
10-Mar-09     krupani           115.264   BUG 8244388: When Child rate is multiple of parent, fetch the parent rate value
                                          as of Child rate strat date
01-Apr-09     krupani           115.265   Bug 8374859: While calling ben_determine_activity_base_rt.main, ler_id was
                                          getting passed from pen record. Now, passing it from ben_per_in_ler
29-Apr-09     velvanop          115.266   Bug 8300620: Fix of Bug 7206471 causing rate gap issues on processing the LifeEvent.
                                          Cursor c_get_elctbl_chc fetches all the choices tied to the current PIL grouped by ptip_id.
					  As a result, besides the required plan type to be actually adjusted, all ptip's are picked up
					  and the rates are adjusted.So modified cursor to pick the correct ptip instead of pickingup
					  all the ptip's
25-May-09     velvanop          115.267   Bug 8507247: Fixes done on top of Bug 7206471
02-Aug-09     krupani           115.268   8716870: Imputed Income Enhancement. Added new parameter p_imp_cvg_strt_dt
                                          which will have the coverage start date of the enrollment subject to imputed income
19-Aug-09     sallumwa          115.270   Bug 8596122 : Handled the overlap coverage case.Also,reverted the fix for 8312737.
05-Sep-09     velvanop          115.271   Bug 8871911 : Performance Bug. Modified cursor 'c_get_prior_per_in_ler' ,added a join condition
                                          to avoid full table scan on pil table
29-Sep-09     velvanop          115.272   Bug 8945818 : Coverage overlap when FONM UnSuspended code and Event date
                                          event processed in the same month
29-Oct-09     stee              115.273   Bug 9028102 : Fix cursor c_get_dpnt to check for an effective
                                                        end date that is not equal to eot.
31-Oct-09     velvanop          115.274   Bug 9057101: Instead of passing p_effective_date, pass
					  effective start date of the pen_id when adjusting the future coverage
27-Jan-10     sallumwa          115.275   Bug 9309878: While determining the defined amount,pass the rate start date
                                          to the procedure annual_to_period.
05-Feb-10     sallumwa          115.276   Bug 9139820 : When multiple changes to the elections are made in a life event,
                                          then open up the enrollment result attached to the previous life event and update
					  the record with the new changes made in the current life event.
16-Feb-10     sagnanas          115.277   Bug 8589355 - Passed opt_id to get_extra_ele_inputs
02-Mar-10     sallumwa          115.278   Bug 9143356 - sarec_compute flag is set to true when there is a change in
                                          assignment even though there is no change in payroll.
04-Mar-10     sallumwa          115.279   Bug 9430735 - Extended the fix done for the bug 9139820 to handle the case
                                          where no elections are made against the previous life event.
03-May-10     velvanop          115.280   Bug 9538592: Basing upon the flag set in reinstate enrollments call, set l_start_new_result
	                                  to true to create a new enrollment result
*/

-------------------------------------------------------------------------------
--
-- Package Variables
--
g_debug boolean := hr_utility.debug_enabled;
g_package varchar2(80):='ben_election_information.';
-- ---------------------------------------------------------------------------
-- |----------------------------< calc_rt_ann_rt_vals >---------------------|
-- Bug: 5584813 this is a private procedure that calculates the rate values --
-- ---------------------------------------------------------------------------
--
PROCEDURE calc_rt_ann_rt_vals (
   p_rt_val                  IN OUT NOCOPY  NUMBER,
   p_ann_rt_val              IN OUT NOCOPY  NUMBER,
   p_person_id               IN       NUMBER,
   p_effective_date          IN       DATE,
   p_acty_base_rt_id         IN       NUMBER,
   p_rate_periodization_rl   IN       NUMBER,
   p_elig_per_elctbl_chc_id    IN       NUMBER,
   p_business_group_id       IN       NUMBER,
   p_enrt_rt_id              IN       NUMBER,
   p_entr_ann_val_flag       IN       VARCHAR2,
   p_entr_val_at_enrt_flag   IN       VARCHAR2)
IS
   l_assignment_id     per_all_assignments_f.assignment_id%TYPE;
   l_payroll_id        per_all_assignments_f.payroll_id%TYPE;
   l_organization_id   per_all_assignments_f.organization_id%TYPE;
   --GEVITY
   l_dfnd_dummy        NUMBER;
   l_ann_dummy         NUMBER;
   l_cmcd_dummy        NUMBER;
   l_compute_val       NUMBER;

--END GEVITY
   l_proc                 varchar2(72) := g_package||'calc_rt_ann_rt_vals';
BEGIN
   hr_utility.set_location('Entering: '||l_proc, 10);
   IF p_entr_ann_val_flag = 'Y'
   THEN
      -- Enter Annual Value
      IF     p_rate_periodization_rl IS NOT NULL
         AND p_acty_base_rt_id IS NOT NULL
      THEN
         --
         ben_element_entry.get_abr_assignment
                                     (p_person_id                   => p_person_id,
                                      p_effective_date              => p_effective_date,
                                      p_acty_base_rt_id             => p_acty_base_rt_id,
                                      p_organization_id             => l_organization_id,
                                      p_payroll_id                  => l_payroll_id,
                                      p_assignment_id               => l_assignment_id);
         --
         l_ann_dummy := p_ann_rt_val;
         ben_distribute_rates.periodize_with_rule
                        (p_formula_id                  => p_rate_periodization_rl,
                         p_effective_date              => p_effective_date,
                         p_assignment_id               => l_assignment_id,
                         p_convert_from_val            => l_ann_dummy,
                         p_convert_from                => 'ANNUAL',
                         p_elig_per_elctbl_chc_id      => p_elig_per_elctbl_chc_id,
                         p_acty_base_rt_id             => p_acty_base_rt_id,
                         p_business_group_id           => p_business_group_id,
                         p_enrt_rt_id                  => p_enrt_rt_id,
                         p_ann_val                     => l_dfnd_dummy,
                         p_cmcd_val                    => l_cmcd_dummy,
                         p_val                         => l_compute_val);
      --
      ELSE
         l_compute_val :=
            ben_distribute_rates.annual_to_period
                                 (p_amount                      => p_ann_rt_val,
                                  p_enrt_rt_id                  => p_enrt_rt_id,
                                  p_elig_per_elctbl_chc_id      => NULL,
                                  p_acty_ref_perd_cd            => NULL,
                                  p_business_group_id           => p_business_group_id,
                                  p_effective_date              => p_effective_date,
                                  p_lf_evt_ocrd_dt              => NULL,
                                  p_complete_year_flag          => 'Y',
                                  p_use_balance_flag            => 'Y',
                                  p_start_date                  => NULL,
                                  p_end_date                    => NULL);
      --
      END IF;                                                         --GEVITY

      p_rt_val := l_compute_val;
   ELSIF p_entr_val_at_enrt_flag = 'Y'
   THEN
      --
      IF     p_rate_periodization_rl IS NOT NULL
         AND p_acty_base_rt_id IS NOT NULL
      THEN
         --
         ben_element_entry.get_abr_assignment
                             (p_person_id                   => p_person_id,
                              p_effective_date              => p_effective_date,
                              p_acty_base_rt_id             => p_acty_base_rt_id,
                              p_organization_id             => l_organization_id,
                              p_payroll_id                  => l_payroll_id,
                              p_assignment_id               => l_assignment_id);
         --
         l_dfnd_dummy := p_rt_val;
         --
         ben_distribute_rates.periodize_with_rule
                (p_formula_id                  => p_rate_periodization_rl,
                 p_effective_date              => p_effective_date,
                 p_assignment_id               => l_assignment_id,
                 p_convert_from_val            => l_dfnd_dummy,
                 p_convert_from                => 'DEFINED',
                 p_elig_per_elctbl_chc_id      => p_elig_per_elctbl_chc_id,
                 p_acty_base_rt_id             => p_acty_base_rt_id,
                 p_business_group_id           => p_business_group_id,
                 p_enrt_rt_id                  => p_enrt_rt_id,
                 p_ann_val                     => l_compute_val,
                 p_cmcd_val                    => l_cmcd_dummy,
                 p_val                         => l_cmcd_dummy);
      --
      ELSE
         l_compute_val :=
            ben_distribute_rates.period_to_annual
                                 (p_amount                      => p_rt_val,
                                  p_enrt_rt_id                  => p_enrt_rt_id,
                                  p_elig_per_elctbl_chc_id      => NULL,
                                  p_acty_ref_perd_cd            => NULL,
                                  p_business_group_id           => p_business_group_id,
                                  p_effective_date              => p_effective_date,
                                  p_lf_evt_ocrd_dt              => NULL,
                                  p_complete_year_flag          => 'Y',
                                  p_use_balance_flag            => 'Y',
                                  p_start_date                  => NULL,
                                  p_end_date                    => NULL);
      --
      END IF;                                                         --GEVITY

      p_ann_rt_val := l_compute_val;
   --
   END IF;
   hr_utility.set_location('Leaving: '||l_proc, 10);
END calc_rt_ann_rt_vals;


-- ---------------------------------------------------------------------------
-- |----------------------------< handle_overlap_rates >---------------------|
-- ---------------------------------------------------------------------------
--
procedure handle_overlap_rates
  (p_acty_base_rt_id                in  number
  ,p_prtt_enrt_rslt_id              in  number
  ,p_prtt_rt_val_id                 in out nocopy  number
  ,p_per_in_ler_id                  in  number
  ,p_person_id                      in  number
  ,p_element_type_id                in  number default null
  ,p_element_entry_value_id         in  number
  ,p_unrestricted                   in  varchar2 default 'N'
  ,p_rt_strt_dt                     in  date
  ,p_business_group_id              in  number
  ,p_effective_date                 in  date
  ) is

  --
  -- pick overlapping rates for the same abr (and)
  -- any future rates attached to the same element type
  --
  cursor c_future_prv(p_element_type_id number) is
  select prv.prtt_rt_val_id,
         prv.acty_base_rt_id,
         prv.acty_ref_perd_cd,
         prv.rt_strt_dt,
         prv.object_version_number
    from ben_prtt_rt_val prv
   where prv.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and ((prv.rt_strt_dt > p_rt_strt_dt) or -- old prv in future
          (p_unrestricted = 'N' and          -- old prv on same date
           prv.per_in_ler_id <> p_per_in_ler_id and
           prv.rt_strt_dt = p_rt_strt_dt))
     and prv.prtt_rt_val_stat_cd is null
     and (prv.acty_base_rt_id = p_acty_base_rt_id
          or exists
                (select 'x'
                   from per_all_assignments_f asg,
                        pay_element_links_f pel,
                        pay_element_entries_f pee,
                        pay_element_entry_values_f pev
                  where pel.element_type_id = p_element_type_id
                    and pee.element_entry_id = pev.element_entry_id
                    and pev.element_entry_value_id = prv.element_entry_value_id
                    and pee.element_link_id = pel.element_link_id
                    and pee.assignment_id = asg.assignment_id
                    and pee.creator_type ='F'
                    and pee.creator_id = p_prtt_enrt_rslt_id
                    and asg.person_id = p_person_id)
         )
  order by prv.rt_strt_dt desc;
  --
  l_future_prv      c_future_prv%ROWTYPE;
  --
  cursor c_current_prv is
  select prtt_rt_val_id,
         acty_base_rt_id,
         rt_strt_dt,
         rt_end_dt,
         object_version_number
    from ben_prtt_rt_val prv
   where prv.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and p_rt_strt_dt between prv.rt_strt_dt
     and prv.rt_end_dt
     and prv.acty_base_rt_id = l_future_prv.acty_base_rt_id
     and prv.prtt_rt_val_stat_cd is null;
  --
  l_current_prv      c_current_prv%ROWTYPE;
  --
  -- gets element_type_id from element_entry_value_id
  --
  cursor c_ele_entry (p_element_entry_value_id number) is
  select elk.element_type_id
    from pay_element_entry_values_f elv,
         pay_element_entries_f ele,
         pay_element_links_f elk
   where elv.element_entry_value_id  = p_element_entry_value_id
     and elv.element_entry_id = ele.element_entry_id
     and elv.effective_start_date between ele.effective_start_date
     and ele.effective_end_date
     and ele.element_link_id   = elk.element_link_id
     and ele.effective_start_date between elk.effective_start_date
     and elk.effective_end_date;
  --
  cursor c_comp_obj_name (p_prtt_enrt_rslt_id number)  is
  select rtrim(substr(pln.name||' '||opt.name,1,60)) -- 4203714 rtrim to chop off the trailing spaces
    from ben_prtt_enrt_rslt_f pen,
         ben_pl_f pln,
         ben_oipl_f oipl,
         ben_opt_f opt
   where pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and pen.pl_id = pln.pl_id
     and pen.oipl_id  = oipl.oipl_id(+)
     and nvl(oipl.opt_id,0) = opt.opt_id (+)
     and p_effective_date between pen.effective_start_date
     and pen.effective_end_date
     and p_effective_date between pln.effective_start_date
     and pln.effective_end_date
     and p_effective_date between nvl(oipl.effective_start_date,p_effective_date) --start 4203714
     and nvl(oipl.effective_end_date,p_effective_date)
     and p_effective_date between nvl(opt.effective_start_date,p_effective_date)
     and nvl(opt.effective_end_date,p_effective_date); -- end 4203714

  l_dummy                varchar2(1);
  l_comp_obj_name        varchar2(60);
  l_proc                 varchar2(72) ;
  l_element_type_id      number;

begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_proc := g_package||'handle_overlap_rates';
    hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;

  l_element_type_id := p_element_type_id;
  if l_element_type_id is null then

     open c_ele_entry(p_element_entry_value_id);
     fetch c_ele_entry into l_element_type_id ;
     close c_ele_entry;

  end if;


  open c_future_prv(l_element_type_id);
  loop

     fetch c_future_prv into l_future_prv ;
     if c_future_prv%notfound then
        exit;
     end if;

     if g_debug then
        hr_utility.set_location('future prv='||l_future_prv.prtt_rt_val_id,15);
     end if;

     if fnd_global.conc_request_id in ( 0,-1) then
        --
        -- Lets us throw a warning about the deletion of the future rate.
        --
        open c_comp_obj_name (p_prtt_enrt_rslt_id);
        fetch c_comp_obj_name into l_comp_obj_name;
        close c_comp_obj_name;
        --
        -- Issue a warning to the user.  This will display on the enrt
        -- forms.
        --

        ben_warnings.load_warning
         (p_application_short_name  => 'BEN',
          p_message_name            => 'BEN_93369_DEL_FUT_RATE',
          p_parma  => fnd_date.date_to_chardate(l_future_prv.rt_strt_dt),
          p_parmb                   => l_comp_obj_name,
          p_person_id               => p_person_id );

     end if;

     if p_prtt_rt_val_id = l_future_prv.prtt_rt_val_id then
        p_prtt_rt_val_id := null;
     end if;
     --
     -- Call delete prv if Unrestricted, else update prv
     --
     if p_unrestricted = 'Y' then
        ben_prtt_rt_val_api.delete_prtt_rt_val
        (p_prtt_rt_val_id         => l_future_prv.prtt_rt_val_id
        ,p_person_id              => p_person_id
        ,p_business_group_id      => p_business_group_id
        ,p_object_version_number  => l_future_prv.object_version_number
        ,p_effective_date         => l_future_prv.rt_strt_dt);
    else
        ben_prtt_rt_val_api.update_prtt_rt_val
        (p_validate                => false,
         p_person_id               => p_person_id,
         p_business_group_id       => p_business_group_id,
         p_prtt_rt_val_id          => l_future_prv.prtt_rt_val_id,
         p_rt_end_dt               => l_future_prv.rt_strt_dt -1,
         p_prtt_rt_val_stat_cd     => 'BCKDT',
         p_ended_per_in_ler_id     => p_per_in_ler_id,
         p_object_version_number   => l_future_prv.object_version_number,
         p_effective_date          => l_future_prv.rt_strt_dt);
    end if;
    --
    -- open up the current rates that are attached to the same
    -- element type
    --
    if l_future_prv.acty_base_rt_id <> p_acty_base_rt_id then

       l_current_prv := null;
       open c_current_prv;
       fetch c_current_prv into l_current_prv;
       close c_current_prv;

       if g_debug then
          hr_utility.set_location('curr prv='||l_current_prv.prtt_rt_val_id,15);
       end if;

       if l_current_prv.rt_end_dt <> hr_api.g_eot then
          --
          ben_prtt_rt_val_api.update_prtt_rt_val
          (p_prtt_rt_val_id         => l_current_prv.prtt_rt_val_id
          ,p_person_id              => p_person_id
          ,p_rt_end_dt              => hr_api.g_eot
          ,p_business_group_id      => p_business_group_id
          ,p_object_version_number  => l_current_prv.object_version_number
          ,p_effective_date         => p_effective_date);
          --
       end if;
       --
    end if;

  end loop;
  close c_future_prv ;

  if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 20);
  end if;

end handle_overlap_rates;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------< election_rate_information >-------------------------|
-- ----------------------------------------------------------------------------
procedure election_rate_information
  (p_calculate_only_mode in     boolean default false
  ,p_enrt_mthd_cd        in     varchar2
  ,p_effective_date      in     date
  ,p_prtt_enrt_rslt_id   in     number
  ,p_per_in_ler_id       in     number
  ,p_person_id           in     number
  ,p_pgm_id              in     number
  ,p_pl_id               in     number
  ,p_oipl_id             in     number
  ,p_enrt_rt_id          in     number
  ,p_prtt_rt_val_id      in out nocopy number
  ,p_rt_val              in     number
  ,p_ann_rt_val          in     number
  ,p_enrt_cvg_strt_dt    in     date
  ,p_acty_ref_perd_cd    in     varchar2
  ,p_datetrack_mode      in     varchar2
  ,p_business_group_id   in     number
  ,p_bnft_amt_changed    in     boolean default false
  ,p_ele_changed         in     boolean default null
  ,p_rt_strt_dt          in     date    default null
  ,p_rt_end_dt           in     date    default null
  --
  ,p_prv_rt_val             out nocopy number
  ,p_prv_ann_rt_val         out nocopy number
  ,p_imp_cvg_strt_dt     in  date default NULL)    -- 8716870
is
  --
  -- Local variable declarations
  --
  l_proc         varchar2(72) := g_package||'election_rate_information';
  --

        l_rt_val                        number;
        l_ann_rt_val                    number;
        l_calc_ann_val                  number;
        l_prnt_rt_val                   number;
        t_old_tx_typ_cd                 varchar2(30);
        l_old_tx_typ_cd                 varchar2(30);
        l_old_acty_typ_cd               varchar2(30);
        l_old_mlt_cd                    varchar2(30);
        l_old_acty_ref_perd_cd          varchar2(30);
        l_old_rt_val                    number;
        l_old_prtt_enrt_rslt_id         number;
        l_old_business_group_id         number;
        l_old_object_version_number     number;
        l_old_rt_typ_cd                 varchar2(30);
        l_old_rt_strt_dt                date;
        l_old_ann_rt_val                number;
        l_old_bnft_rt_typ_cd            varchar2(30);
        l_old_cmcd_ref_perd_cd          varchar2(30);
        l_old_cmcd_rt_val               number;
        l_old_dsply_on_enrt_flag        varchar2(30);
        l_old_cvg_amt_calc_mthd_id      number;
        l_old_actl_prem_id              number;
        l_old_comp_lvl_fctr_id          number;
        l_old_rt_end_dt                 date;
        l_old_per_in_ler_id             number := null;
        l_effective_start_date          date;
        l_effective_end_date            date;
        l_elctns_made_dt                date;
        l_rt_ovridn_flag                varchar2(30);
        l_rt_ovridn_thru_dt             date;
        l_element_entry_value_id        number;
        l_old_elctns_made_dt            date;
        l_period_type                   varchar2(30);
        l_xenrt_cvg_strt_dt             date;
        l_xenrt_cvg_strt_dt_cd          varchar2(30);
        l_xenrt_cvg_strt_dt_rl          number;
        l_xrt_strt_dt                   date;
        l_xrt_strt_dt_cd                varchar2(30);
        l_xrt_strt_dt_rl                number;
        l_xenrt_cvg_end_dt              date;
        l_xenrt_cvg_end_dt_cd           varchar2(30);
        l_xenrt_cvg_end_dt_rl           number;
        l_xrt_end_dt                    date;
        l_xrt_end_dt_cd                 varchar2(30);
        l_xrt_end_dt_rl                 number;
        l_bnft_prvdd_ldgr_id            number;
        l_dummy_num                     number;
        l_dummy_varchar2                varchar2(80);
        l_dummy_date                    date;
        l_dummy_number                  number;

        l_lf_evt_ocrd_dt                date;
        l_old_rt_ovridn_flag            varchar2(30) := 'N';
        l_old_rt_ovridn_thru_dt         date;
        l_effective_date                date ;
        l_yp_start_date                 date;
        l_old_element_entry_value_id    number;
        l_element_changed               boolean := false;
        l_non_recurring_rt              boolean := false;
        l_no_end_element                boolean := false;
        l_processing_type               varchar2(30);
        l_rt_end_dt                     date := p_rt_end_dt;
        l_element_type_id               number;
        l_sarec_compute                 boolean := true ;
        l_prnt_ann_val                  number;
        l_prnt_ann_rt                   varchar2(1) := 'N';
        l_rounded_value                 number;
        l_cal_val_in                    number ;
        l_global_asg_rec ben_global_enrt.g_global_asg_rec_type;
        l_global_pen_rec ben_prtt_enrt_rslt_f%rowtype;
        l_ele_entry_val_cd              varchar2(30);
        l_new_assignment_id             number;
        l_new_payroll_id                number;
        l_new_organization_id           number;
        l_assignment_id                 per_all_assignments_f.assignment_id%type;
        l_payroll_id                    per_all_assignments_f.payroll_id%type;
        l_organization_id               per_all_assignments_f.organization_id%type;
        l_ext_inpval_tab                ben_element_entry.ext_inpval_tab_typ;
        l_inpval_tab                    ben_element_entry.inpval_tab_typ;
        l_jurisdiction_code             varchar2(30);
        l_subpriority                   number;
        l_ext_inp_changed               boolean;
        l_old_assignment_id             number;
        l_old_payroll_id                number;
        l_old_organization_id           number;
  --

  --
  -- Cursor declarations.
  --
  -- Get the enrolment rate and activity base rate values
  cursor c_enrt_rt is
        select  abr.acty_base_rt_id,
                abr.ele_rqd_flag,
                abr.element_type_id,
                abr.input_value_id,
                abr.rcrrg_cd,
                abr.use_calc_Acty_bs_rt_flag,
                abr.entr_val_At_enrt_flag ,
                abr.rt_typ_cd abr_typ_cd,
                abr.val  abr_val,
                abr.rndg_cd,
                abr.rndg_rl,
                abr.ele_entry_val_cd,
                abr.input_va_calc_rl,
                abr.effective_start_date abr_esd,
                abr.effective_end_date abr_eed,
                er.rt_typ_cd,
                er.tx_typ_cd,
                er.acty_typ_cd,
                er.rt_mlt_cd,
                er.rt_strt_dt,
                er.rt_strt_dt_cd,
                er.rt_strt_dt_rl,
                er.bnft_rt_typ_cd,
                er.cmcd_acty_ref_perd_cd,
                er.val,
                er.ann_val,
                er.cmcd_val,
                er.dsply_on_enrt_flag,
                er.cvg_amt_calc_mthd_id,
                er.actl_prem_id,
                er.comp_lvl_fctr_id,
                er.business_group_id,
                nvl(eb.elig_per_elctbl_chc_id,
                    er.elig_per_elctbl_chc_id) elig_per_elctbl_chc_id,
                er.entr_ann_val_flag,
                er.prtt_rt_val_id,
                er.decr_bnft_prvdr_pool_id,
                nvl(eb.enrt_bnft_id,0) enrt_bnft_id,
                nvl(eb.entr_val_at_enrt_flag,'N') entr_bnft_val_flag,
                er.pp_in_yr_used_num,
                er.ordr_num,
                eb.cvg_mlt_cd,
                abr.rate_periodization_rl, --GEVITY
                nvl(eb.mx_wo_ctfn_flag,'N') interim_flag  --BUG 5502202
        from    ben_enrt_rt er,
                ben_enrt_bnft eb,
                ben_acty_base_rt_f abr
        where   er.enrt_rt_id=p_enrt_rt_id
        and     eb.enrt_bnft_id(+)=er.enrt_bnft_id
        and     er.acty_base_rt_id=abr.acty_base_rt_id
        and     ( (ben_manage_life_events.fonm = 'Y' and
                 nvl(nvl(p_rt_strt_dt,er.rt_strt_dt),l_effective_date) between
                 abr.effective_start_date and  abr.effective_end_date) or
                  (nvl(ben_manage_life_events.fonm,'N') = 'N'
                   and l_effective_date between abr.effective_start_date
                   and  abr.effective_end_date) ) ;
  l_enrt_rt c_enrt_rt%rowtype;

  -- Get the participant rate record

  cursor c_prtt_rt_val_1 is
        select  prv.rt_typ_cd,
                prv.tx_typ_cd,
                prv.acty_typ_cd,
                prv.mlt_cd,
                prv.acty_ref_perd_cd,
                prv.rt_val,
                prv.prtt_enrt_rslt_id,
                prv.business_group_id,
                prv.object_version_number,
                prv.rt_strt_dt,
                prv.ann_rt_val,
                prv.bnft_rt_typ_cd,
                prv.cmcd_ref_perd_cd,
                prv.cmcd_rt_val,
                prv.dsply_on_enrt_flag,
                prv.cvg_amt_calc_mthd_id,
                prv.actl_prem_id,
                prv.comp_lvl_fctr_id,
                prv.rt_end_dt,
                prv.per_in_ler_id,
                prv.element_entry_value_id,
                prv.elctns_made_dt,
                prv.rt_ovridn_flag,
                prv.rt_ovridn_thru_dt
        from    ben_prtt_rt_val prv
        where   prtt_rt_val_id=l_enrt_rt.prtt_rt_val_id and
                p_business_group_id=business_group_id;

  cursor c_prtt_rt_val_2 is
        select  prv.prtt_rt_val_id,
                prv.rt_typ_cd,
                prv.tx_typ_cd,
                prv.acty_typ_cd,
                prv.mlt_cd,
                prv.acty_ref_perd_cd,
                prv.rt_val,
                prv.prtt_enrt_rslt_id,
                prv.business_group_id,
                prv.object_version_number,
                prv.rt_strt_dt,
                prv.ann_rt_val,
                prv.bnft_rt_typ_cd,
                prv.cmcd_ref_perd_cd,
                prv.cmcd_rt_val,
                prv.dsply_on_enrt_flag,
                prv.cvg_amt_calc_mthd_id,
                prv.actl_prem_id,
                prv.comp_lvl_fctr_id,
                prv.rt_end_dt,
                prv.per_in_ler_id,
                prv.element_entry_value_id,
                prv.elctns_made_dt,
                prv.rt_ovridn_flag,
                prv.rt_ovridn_thru_dt
         from   ben_prtt_rt_val prv
        where   prv.acty_base_rt_id = l_enrt_rt.acty_base_rt_id
          and   prv.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
          and   prv.prtt_rt_val_stat_cd is null
          and   l_enrt_rt.rt_strt_dt between prv.rt_strt_dt
          and   prv.rt_end_dt
          and   p_business_group_id=prv.business_group_id;


  -- Parent rate information
  cursor c_abr2
    (c_effective_date in date,
     c_acty_base_rt_id in number
    )
  is
    select abr2.entr_val_at_enrt_flag,
           abr2.use_calc_acty_bs_rt_flag,
           abr2.acty_base_rt_id,
           abr2.rt_mlt_cd,
           abr2.entr_ann_val_flag
    from   ben_acty_base_rt_f abr,
           ben_acty_base_rt_f abr2
    where  abr.acty_base_rt_id = c_acty_base_rt_id
    and    abr2.acty_base_rt_id = abr.parnt_acty_base_rt_id
    and    abr2.parnt_chld_cd = 'PARNT'
    and    c_effective_date
           between abr.effective_start_date
           and     abr.effective_end_date
    and    c_effective_date
           between abr2.effective_start_date
           and  abr2.effective_end_date;

   l_prnt_abr      c_abr2%rowtype ;
  --
  cursor c_prv2
    (c_prtt_enrt_rslt_id  number,
     c_acty_base_rt_id  number,
     c_effective_date date              -- BUG 8244388
    )
   is
     select rt_val,
            ann_rt_val
     from ben_prtt_rt_val
     where acty_base_rt_id = c_acty_base_rt_id
       and prtt_enrt_rslt_id = c_prtt_enrt_rslt_id
       and per_in_ler_id     = p_per_in_ler_id
         -- bug 6022111
         AND (   (    c_effective_date BETWEEN rt_strt_dt AND rt_end_dt
                  -- for recurring rate
                  AND rt_strt_dt < rt_end_dt
                 )
              OR (                                   -- for non-recurring rate
                      rt_strt_dt = rt_end_dt
                  AND rt_strt_dt <= c_effective_date
                  AND rt_strt_dt =
                         (SELECT MAX (rt_strt_dt)
                            FROM ben_prtt_rt_val
                           WHERE acty_base_rt_id = c_acty_base_rt_id
                             AND prtt_enrt_rslt_id = c_prtt_enrt_rslt_id
                             AND per_in_ler_id = p_per_in_ler_id
                             AND rt_strt_dt = rt_end_dt
                             AND prtt_rt_val_stat_cd IS NULL)
                 )
             )
         -- end bug 6022111
       and prtt_rt_val_stat_cd IS NULL ;  --BUG 4938498
  --
  cursor c_unrestricted is
                   select null
                   from   ben_per_in_ler pil,
                          ben_ler_f ler
                   where  pil.per_in_ler_id = p_per_in_ler_id
                   and    pil.ler_id = ler.ler_id
                   and    ler.typ_cd = 'SCHEDDU'
                   and    ler.business_group_id = p_business_group_id
                   and    p_effective_date between ler.effective_start_date
                          and ler.effective_end_date;
  --

  -- Bug 8374859
  cursor c_ler_id is
                   select ler.ler_id
                   from   ben_per_in_ler pil,
                          ben_ler_f ler
                   where  pil.per_in_ler_id = p_per_in_ler_id
                   and    pil.ler_id = ler.ler_id
                   and    ler.business_group_id = p_business_group_id
                   and    p_effective_date between ler.effective_start_date
                          and ler.effective_end_date;

  l_ler_id   number;
  -- Bug 8374859

  cursor c_pet is
     select pet.processing_type
     from   pay_element_types_f pet
     where  pet.element_type_id = l_enrt_rt.element_type_id
     and    l_effective_date between pet.effective_start_date
            and pet.effective_end_date;
  --
   cursor c_element_info (p_element_entry_value_id number,
                          p_prtt_enrt_rslt_id      number) is
      select elk.element_type_id,
             eev.input_value_id,
            -- asg.payroll_id,
             pee.element_entry_id,
            -- pee.assignment_id,
             pee.effective_end_date
      from   pay_element_links_f elk,
             per_all_assignments_f asg,
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
   order by pee.effective_end_date desc ;
   l_element_info   c_element_info%rowtype;

   -- Bug 2675486
   CURSOR c_pl_popl_yr_period_current(cv_pl_id number,
                                      cv_pgm_id number,
                                      cv_lf_evt_ocrd_dt date ) IS
      SELECT   distinct yp.start_date
      FROM     ben_popl_yr_perd pyp, ben_yr_perd yp
      WHERE    ( pyp.pl_id = cv_pl_id or pyp.pgm_id = cv_pgm_id )
      AND      pyp.yr_perd_id = yp.yr_perd_id
      AND      pyp.business_group_id = p_business_group_id
      AND      cv_lf_evt_ocrd_dt BETWEEN yp.start_date AND yp.end_date
      AND      yp.business_group_id = p_business_group_id ;
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
      and asg.assignment_type <> 'C'
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
      and pay2.period_type <> pay.period_type
      and asg.assignment_type = asg2.assignment_type ;
  --bug#3260564 -
    -----Bug 9143356
   cursor c_assignment_changed(
            cp_person_id number,
            cp_business_group_id number,
            cp_effective_date date,
            cp_orig_effective_date date
   ) is
   select 1
   from   per_all_assignments_f asg,
          per_all_assignments_f asg2
   where  asg.person_id = cp_person_id
      and asg.assignment_type <> 'C'
      and asg.business_group_id = cp_business_group_id
      and asg.primary_flag = 'Y'
      and cp_effective_date between
          asg.effective_start_date and asg.effective_end_date
      and asg2.person_id = cp_person_id
      and   asg2.assignment_type <> 'C'
      and asg2.business_group_id = cp_business_group_id
      and asg2.primary_flag = 'Y'
      and cp_orig_effective_date between
          asg2.effective_start_date and asg2.effective_end_date
      and asg.assignment_id <> asg2.assignment_id
      ;

   l_assignment_changed   c_assignment_changed%rowtype;
   -----Bug 9143356
    cursor c_future_rates (p_prtt_enrt_rslt_id number,
                           p_acty_base_rt_id   number,
                           p_rt_strt_dt        date,
                           p_per_in_ler_id     number) is
      select prv.prtt_rt_val_id,
             prv.rt_strt_dt,
             prv.acty_ref_perd_cd,
             prv.object_version_number
      from   ben_prtt_rt_val prv
      where  prv.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
      and    prv.acty_base_rt_id   = p_acty_base_rt_id
      and    prv.rt_strt_dt >= p_rt_strt_dt
      and    prv.per_in_ler_id <> p_per_in_ler_id
      and    prv.prtt_rt_val_stat_cd is null
      order  by rt_strt_dt desc;
  --
  l_future_rates    c_future_rates%rowtype;
  --
  cursor c_abr (p_acty_base_rt_id number,
                p_effective_date  date) is
    select abr.ele_entry_val_cd,
           abr.element_type_id,
           abr.input_value_id
    from   ben_acty_base_rt_f abr
    where  abr.acty_base_rt_id = p_acty_base_rt_id
    and    p_effective_date between abr.effective_start_date
           and abr.effective_end_date;
  --
  cursor c_pl_name (p_pl_id number) is
    select name
    from  ben_pl_f pln
    where pln.pl_id = p_pl_id
    and   l_effective_date between
          pln.effective_start_date and pln.effective_end_date;
  --
   cursor c_epe  is
   select epe.fonm_cvg_strt_dt
     from ben_elig_per_elctbl_chc epe
    where epe.prtt_enrt_rslt_id  = p_prtt_enrt_rslt_id
      and epe.per_in_ler_id = p_per_in_ler_id;

--
      CURSOR c_sspnd_enrt_rt (cv_elig_per_elctbl_chc_id IN NUMBER)
      IS
         SELECT abr.entr_val_at_enrt_flag, er.rt_mlt_cd,
                NVL (eb.entr_val_at_enrt_flag, 'N') entr_bnft_val_flag,
                eb.cvg_mlt_cd
           FROM ben_enrt_rt er,
                ben_enrt_bnft eb,
                ben_acty_base_rt_f abr,
                ben_prtt_enrt_rslt_f pen
          WHERE eb.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
            AND pen.rplcs_sspndd_rslt_id = p_prtt_enrt_rslt_id
            AND eb.elig_per_elctbl_chc_id = cv_elig_per_elctbl_chc_id
            AND pen.per_in_ler_id = p_per_in_ler_id
            AND eb.enrt_bnft_id = er.enrt_bnft_id
            AND er.acty_base_rt_id = abr.acty_base_rt_id
            AND l_effective_date BETWEEN pen.effective_start_date
                                     AND pen.effective_end_date
            AND (   (    ben_manage_life_events.fonm = 'Y'
                     AND NVL (er.rt_strt_dt, l_effective_date)
                            BETWEEN abr.effective_start_date
                                AND abr.effective_end_date
                    )
                 OR (    NVL (ben_manage_life_events.fonm, 'N') = 'N'
                     AND l_effective_date BETWEEN abr.effective_start_date
                                              AND abr.effective_end_date
                    )
                );
  --
  -- 7206471

   /* Added cursor for Bug 8945818: Get the previous per_in_ler_id */
   cursor c_prev_per_in_ler is
    select pil.per_in_ler_id
    from   ben_per_in_ler pil,
           ben_per_in_ler pil1,
           ben_ler_f ler
    where  pil1.per_in_ler_id = p_per_in_ler_id
    and    pil1.person_id = pil.person_id
    and    pil1.per_in_ler_id <> pil.per_in_ler_id
    and    pil.ler_id  = ler.ler_id
    and    p_effective_date between
           ler.effective_start_date and ler.effective_end_date
    and    ler.typ_cd not in ('IREC', 'SCHEDDU', 'COMP', 'GSP', 'ABS')
    and    pil.per_in_ler_stat_cd not in('BCKDT', 'VOIDD')
    order by pil.lf_evt_ocrd_dt desc;

    l_prev_pil_id number;

  --

  cursor c_get_prior_per_in_ler(c_rt_strt_dt date) is
   select 'Y'
   from   ben_per_in_ler pil, ben_per_in_ler pil2
   where  pil.per_in_ler_id <> p_per_in_ler_id
   /* Bug 8945818: Added 'or' condition. Check for future rates for the previous life event */
   and    ( (trunc(pil.lf_evt_ocrd_dt, 'MM') = trunc(pil2.lf_evt_ocrd_dt, 'MM')) or
            ('Y' =  ( select 'Y' from ben_prtt_rt_val prv,
                                      ben_prtt_enrt_rslt_f pen_n,
                                      ben_prtt_enrt_rslt_f pen_o
                      where pen_n.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
                            and pen_n.prtt_enrt_rslt_stat_cd is null
                            and pen_n.per_in_ler_id = p_per_in_ler_id
                            and pen_o.per_in_ler_id = l_prev_pil_id
                            and pen_n.ptip_id = pen_o.ptip_id
                            and pen_o.prtt_enrt_rslt_stat_cd is null
                            and pen_o.enrt_cvg_strt_dt <= pen_o.enrt_cvg_thru_dt
                            and pen_o.prtt_enrt_rslt_id = prv.prtt_enrt_rslt_id
                            and prv.per_in_ler_id = l_prev_pil_id
                            and c_rt_strt_dt <= prv.rt_strt_dt
			    and rownum = 1
                    ))
          )
   and    pil2.per_in_ler_id = p_per_in_ler_id
   and    pil2.person_id = p_person_id
   and    pil.person_id = p_person_id
   and    pil.business_group_id = pil2.business_group_id
   and    pil.business_group_id = p_business_group_id
   and    pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT');

  l_exists varchar2(2);
  --
  cursor c_get_pgm_extra_info is
  select pgi_information1
  from ben_pgm_extra_info
  where information_type = 'ADJ_RATE_PREV_LF_EVT'
  and pgm_id = p_pgm_id;
  --
  l_adjust varchar2(2);
  --
  cursor c_get_elctbl_chc is
   select min(ecr.rt_strt_dt) rt_strt_dt
         ,epe.ptip_id
   from ben_elig_per_elctbl_chc  epe
       ,ben_enrt_rt ecr
       ,ben_enrt_bnft enb
   where epe.per_in_ler_id = p_per_in_ler_id
   and   epe.business_group_id = p_business_group_id
   and   ecr.enrt_rt_id = p_enrt_rt_id -- Bug 8300620
   and   decode(ecr.enrt_bnft_id, null, ecr.elig_per_elctbl_chc_id,
         enb.elig_per_elctbl_chc_id) = epe.elig_per_elctbl_chc_id
   and   enb.enrt_bnft_id (+) = ecr.enrt_bnft_id
   and   ecr.rt_strt_dt is not null
   and   ecr.business_group_id = p_business_group_id
   group by epe.ptip_id;

   /* Bug 8507247:  If the plan is non FONM(Ex:First of Pay Period after Effective Date	) the RT_STRT_DT gets recalculated again in
   election_rate_information and the same is not updated back to ben_enrt_rt table. So we cannot use the
   min(rt_strt_dt) from ben_enrt_rt table to adjust the rates since the actual RT_STRT_DT has changed.
   Instead since the adjustment is always done just before creating the new rate, we already know the new rt_strt_dt
   from which we are going to create the new rate i.e. the variable l_enrt_rt.rt_strt_dt passed to create_prtt_rt_val.
   The same should be used for adjusting the ended rates.*/
   cursor c_get_ptip_id is
	   select epe.ptip_id
	   from ben_elig_per_elctbl_chc  epe
	       ,ben_enrt_rt ecr
	       ,ben_enrt_bnft enb
	   where epe.per_in_ler_id = p_per_in_ler_id
	   and   epe.business_group_id = p_business_group_id
	   and   ecr.enrt_rt_id = p_enrt_rt_id
	   and   decode(ecr.enrt_bnft_id, null, ecr.elig_per_elctbl_chc_id,
		 enb.elig_per_elctbl_chc_id) = epe.elig_per_elctbl_chc_id
	   and   enb.enrt_bnft_id (+) = ecr.enrt_bnft_id
	   and   ecr.rt_strt_dt is not null
	   and   ecr.business_group_id = p_business_group_id;

   l_ptip_id number;

   /* End of Bug 8507247*/
   --
   cursor c_get_enrt_rslts(p_rt_end_dt date
                         ,p_ptip_id   number
                          ) is
   select prv.*
         ,abr.element_type_id
         ,abr.input_value_id
         ,pen.person_id
   from ben_prtt_enrt_rslt_f pen
       ,ben_prtt_rt_val prv
       ,ben_acty_base_rt_f abr
   where pen.effective_end_date = hr_api.g_eot
   and   pen.enrt_cvg_thru_dt <> hr_api.g_eot
   and   pen.prtt_enrt_rslt_stat_cd is null
   and   pen.person_id =  p_person_id
   and   pen.business_group_id = p_business_group_id
   and   pen.prtt_enrt_rslt_id = prv.prtt_enrt_rslt_id
   and   pen.ptip_id = p_ptip_id
   and   prv.prtt_rt_val_stat_cd is null
   and   prv.rt_end_dt >=  p_rt_end_dt
   and   prv.acty_base_rt_id = abr.acty_base_rt_id
   and   p_effective_date between abr.effective_start_date
                  and abr.effective_end_date;
   --
   cursor c_prtt_rt_val_adj (p_per_in_ler_id number,
                            p_prtt_rt_val_id number) is
   select null
   from ben_le_clsn_n_rstr
   where BKUP_TBL_TYP_CD = 'BEN_PRTT_RT_VAL_ADJ'
   AND   BKUP_TBL_ID = p_prtt_rt_val_id
   AND   PER_IN_LER_ID  = p_per_in_ler_id;
   --

   --8589355
   cursor c_get_opt_id(p_oipl_id number, p_rt_strt_dt date)
   is
   select oipl.opt_id
     from ben_oipl_f oipl
    where oipl.oipl_id = p_oipl_id
      and business_group_id = p_business_group_id
      and p_rt_strt_dt between oipl.effective_start_date and oipl.effective_end_date;

   l_get_opt_id c_get_opt_id%rowtype;
   --8589355

   -- end 7206471
  l_sspnd_enrt_rt                c_sspnd_enrt_rt%ROWTYPE;

  l_ann_mn_elcn_val  number := 0;
  l_ann_mx_elcn_val  number := 0;
  l_ptd_balance      number := 0;
  l_clm_balance      number := 0;
  l_pl_name          varchar2(240);
  --GEVITY
  l_dfnd_dummy number;
  l_ann_dummy  number;
  l_cmcd_dummy number;
  --END GEVITY
  l_fonm_cvg_strt_dt  date;
  l_input_value_id    number;
  l_global_pil_rec    ben_global_enrt.g_global_pil_rec_type;
  l_unrestricted      varchar2(1) := 'N';
  l_compute_val       number; --
  l_rt_val_param      number; --| 5259005 -- New vars to hold p_rt_val, p_ann_rt_val
  l_ann_rt_val_param  number; --|
  --
  begin

    g_debug := hr_utility.debug_enabled;
    if g_debug then
       hr_utility.set_location('Entering:'||l_proc, 5);
       hr_utility.set_location('enrt_rt:'||p_enrt_rt_id, 5);
       hr_utility.set_location('p_prtt_rt_val_id:'||p_prtt_rt_val_id,5);
       hr_utility.set_location('p_per_in_ler_id:'||p_per_in_ler_id,5);
    end if;
    --
    --Bug 8374859
    open c_ler_id;
    fetch c_ler_id into l_ler_id;
    close c_ler_id;

    ben_global_enrt.get_pil  -- per in ler
    (p_per_in_ler_id          => p_per_in_ler_id
    ,p_global_pil_rec         => l_global_pil_rec);

    l_lf_evt_ocrd_dt := l_global_pil_rec.lf_evt_ocrd_dt;
    --
    l_effective_date := nvl(l_lf_evt_ocrd_dt,p_effective_date);

    if l_global_pil_rec.typ_cd = 'SCHEDDU' then
       l_unrestricted := 'Y';
    end if;

    if ben_manage_life_events.fonm is null then

       open  c_epe;
       fetch c_epe into l_fonm_cvg_strt_dt;
       close c_epe;

       if l_fonm_cvg_strt_dt is not null then
          ben_manage_life_events.fonm := 'Y';
          ben_manage_life_events.g_fonm_cvg_strt_dt := l_fonm_cvg_strt_dt;
         /* 8716870: Code added for Imp Inc Enh starts*/
         if p_imp_cvg_strt_dt is not NULL and p_imp_cvg_strt_dt > l_fonm_cvg_strt_dt then
            ben_manage_life_events.g_fonm_cvg_strt_dt := p_imp_cvg_strt_dt;
         end if;
         /* Code added for Imp Inc Enh ends */

       else
          ben_manage_life_events.fonm := 'N';
          ben_manage_life_events.g_fonm_cvg_strt_dt := null;
          ben_manage_life_events.g_fonm_rt_strt_dt := null;
       end if;
    else
      if ben_manage_life_events.g_fonm_cvg_strt_dt is null and  ben_manage_life_events.fonm = 'Y'  then
         open  c_epe;
         fetch c_epe into l_fonm_cvg_strt_dt;
         close c_epe;
         ben_manage_life_events.g_fonm_cvg_strt_dt := l_fonm_cvg_strt_dt;
         /* 8716870: Code added for Imp Inc Enh starts*/
         hr_utility.set_location('p_imp_cvg_strt_dt '||p_imp_cvg_strt_dt,5);
         if p_imp_cvg_strt_dt is not NULL and p_imp_cvg_strt_dt > l_fonm_cvg_strt_dt then
            ben_manage_life_events.g_fonm_cvg_strt_dt := p_imp_cvg_strt_dt;
         end if;
        /* Code added for Imp Inc Enh ends */

      end if ;

    end if;
    --
    if p_bnft_amt_changed then
      if g_debug then
        hr_utility.set_location('p_bnft_amt changed:',5);
      end if;
    end if;
    --
    ben_det_enrt_rates.set_global_enrt_rt
       (p_enrt_rt_id   => p_enrt_rt_id);
    --
    -- Get the new values to be stored or updated
    --
    p_prtt_rt_val_id:=null;

    open c_enrt_rt;
    fetch c_enrt_rt into l_enrt_rt;
    if c_enrt_rt%notfound then
      close c_enrt_rt;
      fnd_message.set_name('BEN','BEN_91825_ENRT_RT_NOT_FOUND');
      fnd_message.set_token('PROC',l_proc);
      fnd_message.set_token('ENRT_RT_ID',to_char(p_enrt_rt_id));
      fnd_message.set_token('BG_ID',to_char(p_business_group_id));
      if g_debug then
        hr_utility.set_location('BEN_91825_ENRT_RT_NOT_FOUND', 20);
      end if;
      fnd_message.raise_error;
    end if;  -- notfound
    close c_enrt_rt;

    if ben_manage_life_events.fonm = 'Y' then
       ----Bug 7557403
       ben_manage_life_events.g_fonm_rt_strt_dt := nvl(ben_manage_life_events.g_fonm_rt_strt_dt,
                                                   nvl(p_rt_strt_dt,l_enrt_rt.rt_strt_dt));
       ----Bug 7557403
       /* 8716870: Code added for Imp Inc Enh starts*/
       hr_utility.set_location('p_imp_cvg_strt_dt '||p_imp_cvg_strt_dt,7);
       if p_imp_cvg_strt_dt is not NULL and p_imp_cvg_strt_dt > nvl(p_rt_strt_dt,l_enrt_rt.rt_strt_dt) then
         ben_manage_life_events.g_fonm_rt_strt_dt :=  p_imp_cvg_strt_dt;
       end if;
       /* Code added for Imp Inc Enh ends */
       l_effective_date := nvl(ben_manage_life_events.g_fonm_rt_strt_dt,l_effective_date);
    end if;

    if g_debug then
      hr_utility.set_location(l_proc, 30);
    end if;
    --
    -- bug fix 3457483
    --
    -- Get the payroll id to be passed to ben_distribute_rates.
    --
    ben_element_entry.get_abr_assignment
     (p_person_id       => p_person_id
     ,p_effective_date  => l_effective_date
     ,p_acty_base_rt_id => l_enrt_rt.acty_base_rt_id
     ,p_organization_id => l_organization_id
     ,p_payroll_id      => l_payroll_id
     ,p_assignment_id   => l_assignment_id
     );
    -- end bug fix 3457483
    --
    if l_enrt_rt.cmcd_acty_ref_perd_cd = 'PPF' then
       l_element_type_id := l_enrt_rt.element_type_id;
    end if;
    --
    open c_pet;
    fetch c_pet into l_processing_type;
    close c_pet;
    --
    -- for non recurring rates the rate end date is assigned the rate start date
    --
    if l_processing_type = 'N' or
       l_enrt_rt.rcrrg_cd = 'ONCE' then

       l_non_recurring_rt := true;
       l_rt_end_dt := p_rt_strt_dt;

    end if;
    --
    if p_rt_strt_dt is not null and
       l_rt_end_dt is not null  and
       p_rt_strt_dt > l_rt_end_dt then
      --
      fnd_message.set_name('BEN','BEN_92688_RT_STRT_DT_GT_END_DT');
      fnd_message.set_token('START',p_rt_strt_dt);
      fnd_message.set_token('END',l_rt_end_dt);
      fnd_message.raise_error;
      --
    end if;
    --
    -- Get data from old rate
    --
    hr_utility.set_location(' BKKKK l_enrt_rt.prtt_rt_val_id ' || l_enrt_rt.prtt_rt_val_id, 300);
    hr_utility.set_location(' BKKKK p_enrt_rt_id ' || p_enrt_rt_id, 300);
    hr_utility.set_location(' BKKKK p_business_group_id  ' || p_business_group_id, 300);
    hr_utility.set_location(' BKKKK l_enrt_rt.elig_per_elctbl_chc_id ' || l_enrt_rt.elig_per_elctbl_chc_id, 300);
    --
    if l_enrt_rt.prtt_rt_val_id is not null then
      -- Get data from old rate
      open c_prtt_rt_val_1;
      fetch c_prtt_rt_val_1 into
        l_old_rt_typ_cd,
        l_old_tx_typ_cd,
        l_old_acty_typ_cd,
        l_old_mlt_cd,
        l_old_acty_ref_perd_cd,
        l_old_rt_val,
        l_old_prtt_enrt_rslt_id,
        l_old_business_group_id,
        l_old_object_version_number,
        l_old_rt_strt_dt,
        l_old_ann_rt_val,
        l_old_bnft_rt_typ_cd,
        l_old_cmcd_ref_perd_cd,
        l_old_cmcd_rt_val,
        l_old_dsply_on_enrt_flag,
        l_old_cvg_amt_calc_mthd_id,
        l_old_actl_prem_id,
        l_old_comp_lvl_fctr_id,
        l_old_rt_end_dt,
        l_old_per_in_ler_id,
        l_old_element_entry_value_id,
        l_old_elctns_made_dt,
        l_old_rt_ovridn_flag,
        l_old_rt_ovridn_thru_dt ;

      if c_prtt_rt_val_1%notfound then
        close c_prtt_rt_val_1;
        if g_debug then
          hr_utility.set_location('BEN_92103_NO_PRTT_RT_VAL', 35);
        end if;
        fnd_message.set_name('BEN','BEN_92103_NO_PRTT_RT_VAL');
        fnd_message.set_token('PROC',l_proc);
        fnd_message.set_token('PRTT_RT_VAL_ID',to_char(l_enrt_rt.prtt_rt_val_id));
        fnd_message.raise_error;
      end if;

      if g_debug then
         hr_utility.set_location('ll_old_rt_strt_dt'||l_old_rt_strt_dt,99);
         hr_utility.set_location('l_old_per_in_ler_id'||l_old_per_in_ler_id,99);
         hr_utility.set_location('l_old_rt end date'||l_old_rt_end_dt,99);
      end if;
      close c_prtt_rt_val_1;
    end if;
    --
    -- Get result information
    --
    ben_global_enrt.get_pen  -- result
       (p_prtt_enrt_rslt_id      => p_prtt_enrt_rslt_id
       ,p_effective_date         => p_effective_date
       ,p_global_pen_rec         => l_global_pen_rec);

    hr_utility.set_location('l_global_pen_rec',99);
    --
    -- determine rate start date as long as there is not an existing prtt_rt_val
    -- record, or if there is an exising prtt_rt_val record, that the record was
    -- NOT updated during this per-in-ler (bensuenr updates the rt-strt-dt).
    -- part of bug 1121022
    --
    if l_enrt_rt.rt_strt_dt_cd = 'ENTRBL' and p_rt_strt_dt is not null then
      -- The rate start date is the parameter value if the date code
      -- is enterable.
      l_enrt_rt.rt_strt_dt := p_rt_strt_dt;
    elsif l_enrt_rt.prtt_rt_val_id is not null and
          l_old_per_in_ler_id = p_per_in_ler_id and
          l_unrestricted = 'N' then -- #5303167
          hr_utility.set_location('l_global_pen_rec2',99);
       -- check unrestricted life event
       -- if l_unrestricted = 'N' then #5303167 moved this condition to above elsif
         --
         -- we already have the correct prv created
         --
         p_prtt_rt_val_id := l_enrt_rt.prtt_rt_val_id;
         if l_enrt_rt.rt_strt_dt_cd in ('FDPPFED','FDPPOED') then
           hr_utility.set_location('l_global_pen_rec3',99);
           ben_determine_date.main(
               p_date_cd                => l_enrt_rt.rt_strt_dt_cd,
               p_per_in_ler_id          => p_per_in_ler_id,
               p_person_id              => p_person_id,
               p_pgm_id                 => p_pgm_id,
               p_pl_id                  => p_pl_id,
               p_oipl_id                => p_oipl_id,
               p_business_group_id      => p_business_group_id,
               p_formula_id             => l_enrt_rt.rt_strt_dt_rl,
               p_acty_base_rt_id        => l_enrt_rt.acty_base_rt_id,
               p_elig_per_elctbl_chc_id => l_enrt_rt.elig_per_elctbl_chc_id,
               p_effective_date         => p_effective_date,
               p_returned_date          => l_enrt_rt.rt_strt_dt
             );
         else
          --
          l_enrt_rt.rt_strt_dt := l_old_rt_strt_dt;
          --
         end if;
         --
       -- end if; #5303167
       --
    elsif l_enrt_rt.rt_strt_dt_cd is not null then
      if g_debug then
        hr_utility.set_location(l_proc, 40);
      end if;
      ben_determine_date.main(
        p_date_cd                => l_enrt_rt.rt_strt_dt_cd,
        p_per_in_ler_id          => p_per_in_ler_id,
        p_person_id              => p_person_id,
        p_pgm_id                 => p_pgm_id,
        p_pl_id                  => p_pl_id,
        p_oipl_id                => p_oipl_id,
        p_business_group_id      => p_business_group_id,
        p_formula_id             => l_enrt_rt.rt_strt_dt_rl,
        p_acty_base_rt_id        => l_enrt_rt.acty_base_rt_id,
        p_elig_per_elctbl_chc_id => l_enrt_rt.elig_per_elctbl_chc_id,
        p_effective_date         => p_effective_date,
        p_returned_date          => l_enrt_rt.rt_strt_dt
      );
      --bug#4078828 - rate start date gets changed because of rate code based on election
      open c_abr (l_enrt_rt.acty_base_rt_id,l_enrt_rt.rt_strt_dt);
      fetch c_abr into l_ele_entry_val_cd, l_enrt_rt.element_type_id,
                        l_enrt_rt.input_value_id;
      close c_abr;
      --
    end if;
    if g_debug then
      hr_utility.set_location(l_proc, 45);
    end if;
    if (l_enrt_rt.rt_strt_dt is null) then
      if g_debug then
        hr_utility.set_location('BEN_91455_RT_STRT_DT_NOT_FOUND id:'||
          to_char(p_pl_id), 50);
      end if;
      fnd_message.set_name('BEN','BEN_91455_RT_STRT_DT_NOT_FOUND');
      fnd_message.set_token('PROC',l_proc);
      fnd_message.set_token('PLAN_ID', to_char(p_pl_id));
      fnd_message.raise_error;
    end if; -- date is null

    if p_prtt_rt_val_id is null then

       if  l_enrt_rt.prtt_rt_val_id is null or
           l_enrt_rt.rt_strt_dt < l_old_rt_strt_dt or
           l_enrt_rt.rt_strt_dt > l_old_rt_end_dt then

           open c_prtt_rt_val_2;
           fetch c_prtt_rt_val_2 into
           p_prtt_rt_val_id,
           l_old_rt_typ_cd,
           l_old_tx_typ_cd,
           l_old_acty_typ_cd,
           l_old_mlt_cd,
           l_old_acty_ref_perd_cd,
           l_old_rt_val,
           l_old_prtt_enrt_rslt_id,
           l_old_business_group_id,
           l_old_object_version_number,
           l_old_rt_strt_dt,
           l_old_ann_rt_val,
           l_old_bnft_rt_typ_cd,
           l_old_cmcd_ref_perd_cd,
           l_old_cmcd_rt_val,
           l_old_dsply_on_enrt_flag,
           l_old_cvg_amt_calc_mthd_id,
           l_old_actl_prem_id,
           l_old_comp_lvl_fctr_id,
           l_old_rt_end_dt,
           l_old_per_in_ler_id,
           l_old_element_entry_value_id,
           l_old_elctns_made_dt,
           l_old_rt_ovridn_flag,
           l_old_rt_ovridn_thru_dt ;

           if c_prtt_rt_val_2%notfound then
              p_prtt_rt_val_id := null;
              l_old_rt_typ_cd := null;
              l_old_tx_typ_cd := null;
              l_old_acty_typ_cd := null;
              l_old_mlt_cd := null;
              l_old_acty_ref_perd_cd := null;
              l_old_rt_val := null;
              l_old_prtt_enrt_rslt_id := null;
              l_old_business_group_id := null;
              l_old_object_version_number := null;
              l_old_rt_strt_dt := null;
              l_old_ann_rt_val := null;
              l_old_bnft_rt_typ_cd := null;
              l_old_cmcd_ref_perd_cd := null;
              l_old_cmcd_rt_val := null;
              l_old_dsply_on_enrt_flag := 'N' ; -- null; # 3273247
              l_old_cvg_amt_calc_mthd_id := null;
              l_old_actl_prem_id := null;
              l_old_comp_lvl_fctr_id := null;
              l_old_rt_end_dt := null;
              l_old_per_in_ler_id := null;
              l_old_element_entry_value_id := null;
              l_old_elctns_made_dt := null;
              l_old_rt_ovridn_flag := 'N' ; -- null; # 3273247
              l_old_rt_ovridn_thru_dt := null;
           end if;
           close c_prtt_rt_val_2;
       else
          p_prtt_rt_val_id := l_enrt_rt.prtt_rt_val_id;
       end if;

    end if;
    if g_debug then
       hr_utility.set_location('p_prtt_rt_val_id:'||p_prtt_rt_val_id, 3);
    end if;
    --
    --Bug#2734491 - Child rate should behave the same way as parent
    --
    if l_enrt_rt.rt_mlt_cd = 'PRNT' and l_enrt_rt.use_calc_acty_bs_rt_flag = 'Y' then
       /* BUG 8244388 open c_abr2 and c_prv2 with l_enrt_rt.rt_strt_dt instead of l_effective_date */
       open c_abr2(l_enrt_rt.rt_strt_dt,l_enrt_rt.acty_base_rt_id ) ;
       fetch c_abr2 into l_prnt_abr ;
       if c_abr2%found then
         if l_prnt_abr.rt_mlt_cd = 'SAREC' or l_prnt_abr.entr_ann_val_flag = 'Y' then
        --- take the rate from the parent rcord
            l_prnt_ann_rt := 'Y';
            open c_prv2(p_prtt_enrt_rslt_id,l_prnt_abr.acty_base_rt_id, l_enrt_rt.rt_strt_dt);
            fetch  c_prv2 into l_prnt_rt_val ,l_prnt_ann_val;
            close  c_prv2 ;
         end if ;
       end if;
       close c_abr2;
    end if;

  -- determine new rate values
  -- rajkiran
  -- Moved part of code below from Enrollment forms PL/SQl Libraries
  -- to have calculated values for p_rt_val, p_ann_rt_val
  --
  -- When the user has changed the value in ann_val, (which
  -- is an annual value), we need to compute the per-period
  -- value and put it into either the pre-tax val or after
  -- tax val depending on which enter_val_flag is on.
  -- We know if the user entered the value because then the
  -- ann_val and ann_val_hide are different.
  --
   l_ann_rt_val_param := p_ann_rt_val ;
   l_rt_val_param     := p_rt_val ;
  --
  hr_utility.set_location('l_ann_rt_val_param ->'||l_ann_rt_val_param,9);
  hr_utility.set_location('l_rt_val_param     ->'||l_rt_val_param    ,9);
  hr_utility.set_location('p_ann_rt_val ->'||p_ann_rt_val,9);
  hr_utility.set_location('p_rt_val     ->'||p_rt_val    ,9);
  --
  hr_utility.set_location('entr_ann_val ->'||l_enrt_rt.entr_ann_val_flag, 9);
  hr_utility.set_location('entr_val     ->'||l_enrt_rt.entr_val_at_enrt_flag, 9);
  --
  /*
   -- commented for bug: 5584813
   -- this code moved to a procedure calc_rt_ann_rt_vals
  if l_enrt_rt.entr_ann_val_flag = 'Y' then
        -- Enter Annual Value
        IF l_enrt_rt.rate_periodization_rl  IS NOT NULL AND
           l_enrt_rt.acty_base_rt_id        IS NOT NULL THEN
          --
          ben_element_entry.get_abr_assignment
              (p_person_id       => p_person_id
              ,p_effective_date  => l_effective_date
              ,p_acty_base_rt_id => l_enrt_rt.acty_base_rt_id
              ,p_organization_id => l_organization_id
              ,p_payroll_id      => l_payroll_id
              ,p_assignment_id   => l_assignment_id
              );
          --
          l_ann_dummy := p_ann_rt_val;
          --
          ben_distribute_rates.periodize_with_rule(
              p_formula_id             => l_enrt_rt.rate_periodization_rl
             ,p_effective_date         => l_effective_date
             ,p_assignment_id          => l_assignment_id
             ,p_convert_from_val       => l_ann_dummy
             ,p_convert_from           => 'ANNUAL'
             ,p_elig_per_elctbl_chc_id => l_enrt_rt.elig_per_elctbl_chc_id
             ,p_acty_base_rt_id        => l_enrt_rt.acty_base_rt_id
             ,p_business_group_id      => p_business_group_id
             ,p_enrt_rt_id             => p_enrt_rt_id
             ,p_ann_val                => l_dfnd_dummy
             ,p_cmcd_val               => l_cmcd_dummy
             ,p_val                    => l_compute_val
          );
          --
        ELSE
         l_compute_val := ben_distribute_rates.annual_to_period(
                            p_amount  => p_ann_rt_val
                           ,p_enrt_rt_id => p_enrt_rt_id
                           ,p_elig_per_elctbl_chc_id => null
                           ,p_acty_ref_perd_cd => null
                           ,p_business_group_id => p_business_group_id
                           ,p_effective_date => l_effective_date
                           ,p_lf_evt_ocrd_dt => null
                           ,p_complete_year_flag => 'Y'
                           ,p_use_balance_flag => 'Y'
                           ,p_start_date => null
                           ,p_end_date => null);
         --
        END IF; --GEVITY
	   l_rt_val_param := l_compute_val ;
  --
  -- When the user has changed the value in the pre-tax or
  -- after-tax columns, we must compute the annual value
  -- which goes into the bnft_val column.
  --
  elsif l_enrt_rt.entr_val_at_enrt_flag = 'Y' then
     --
         IF l_enrt_rt.rate_periodization_rl  IS NOT NULL AND
            l_enrt_rt.acty_base_rt_id        IS NOT NULL THEN
             --
             ben_element_entry.get_abr_assignment
              (p_person_id       => p_person_id
              ,p_effective_date  => l_effective_date
              ,p_acty_base_rt_id => l_enrt_rt.acty_base_rt_id
              ,p_organization_id => l_organization_id
              ,p_payroll_id      => l_payroll_id
              ,p_assignment_id   => l_assignment_id
              );
             --
             l_dfnd_dummy := p_rt_val;
             --
             ben_distribute_rates.periodize_with_rule(
                 p_formula_id             => l_enrt_rt.rate_periodization_rl
                ,p_effective_date         => l_effective_date
                ,p_assignment_id          => l_assignment_id
                ,p_convert_from_val       => l_dfnd_dummy
                ,p_convert_from           => 'DEFINED'
                ,p_elig_per_elctbl_chc_id => l_enrt_rt.elig_per_elctbl_chc_id
                ,p_acty_base_rt_id        => l_enrt_rt.acty_base_rt_id
                ,p_business_group_id      => p_business_group_id
                ,p_enrt_rt_id             => p_enrt_rt_id
                ,p_ann_val                => l_compute_val
                ,p_cmcd_val               => l_cmcd_dummy
                ,p_val                    => l_cmcd_dummy
             );
             --
         ELSE
           l_compute_val := ben_distribute_rates.period_to_annual(
                            p_amount                 => p_rt_val
                           ,p_enrt_rt_id             => p_enrt_rt_id
                           ,p_elig_per_elctbl_chc_id => null
                           ,p_acty_ref_perd_cd       => null
                           ,p_business_group_id      => p_business_group_id
                           ,p_effective_date         => l_effective_date
                           ,p_lf_evt_ocrd_dt         => null
                           ,p_complete_year_flag     => 'Y'
                           ,p_use_balance_flag       => 'Y'
                           ,p_start_date             => null
                           ,p_end_date               => null);
         --
         END IF; --GEVITY
	   l_ann_rt_val_param := l_compute_val;
      --
  end if;
  */

  calc_rt_ann_rt_vals (
   p_rt_val                  => l_rt_val_param,
   p_ann_rt_val              => l_ann_rt_val_param,
   p_person_id               => p_person_id,
   p_effective_date          => l_effective_date,
   p_acty_base_rt_id         => l_enrt_rt.acty_base_rt_id,
   p_rate_periodization_rl   => l_enrt_rt.rate_periodization_rl,
   p_elig_per_elctbl_chc_id  => l_enrt_rt.elig_per_elctbl_chc_id,
   p_business_group_id       => p_business_group_id,
   p_enrt_rt_id              => p_enrt_rt_id,
   p_entr_ann_val_flag       => l_enrt_rt.entr_ann_val_flag,
   p_entr_val_at_enrt_flag   => l_enrt_rt.entr_val_at_enrt_flag);


  hr_utility.set_location('l_ann_rt_val_param ->'||l_ann_rt_val_param,9);
  hr_utility.set_location('l_rt_val_param     ->'||l_rt_val_param    ,9);
  hr_utility.set_location('p_ann_rt_val ->'||p_ann_rt_val,9);
  hr_utility.set_location('p_rt_val     ->'||p_rt_val    ,9);

  -- rajkiran

    --
    --bug 1888085 we need to eliminate the following 'PCT' condition if
    --use_calc_acty_bs_rt_flag is set to 'Y'
    --
    if l_enrt_rt.rt_typ_cd = 'PCT' and l_enrt_rt.use_calc_acty_bs_rt_flag <> 'Y' then
      if l_enrt_rt.entr_ann_val_flag = 'Y' then
        --
        -- get values from annual value
        --
        l_ann_rt_val       := l_ann_rt_val_param; -- changed from p_ann_rt_val to l_ann_rt_val_param
        l_rt_val           := l_ann_rt_val_param;
        l_enrt_rt.cmcd_val := l_ann_rt_val_param;
      else
        --
        -- get values from periodic value
        --
        l_ann_rt_val       := l_rt_val_param; -- changed from p_rt_val to l_rt_val_param
        l_rt_val           := l_rt_val_param;
        l_enrt_rt.cmcd_val := l_rt_val_param;
        --
      end if;
      --
    else
      --
      if l_enrt_rt.entr_ann_val_flag = 'Y' or l_prnt_ann_rt = 'Y' then
        --
        if g_debug then
          hr_utility.set_location('enter annual value',100);
        end if;
        if l_rt_val_param is null then -- changed from p_rt_val to l_rt_val_param
          --
          --GEVITY
          --
          IF l_enrt_rt.rate_periodization_rl IS NOT NULL THEN
            --
            l_ann_dummy := l_ann_rt_val_param ; --p_ann_rt_val; 5259005
            --
            ben_distribute_rates.periodize_with_rule
                  (p_formula_id             => l_enrt_rt.rate_periodization_rl
                  ,p_effective_date         => l_effective_date
                  ,p_assignment_id          => l_assignment_id
                  ,p_convert_from_val       => l_ann_dummy
                  ,p_convert_from           => 'ANNUAL'
                  ,p_elig_per_elctbl_chc_id => l_enrt_rt.elig_per_elctbl_chc_id
                  ,p_acty_base_rt_id        => l_enrt_rt.acty_base_rt_id
                  ,p_business_group_id      => p_business_group_id
                  ,p_enrt_rt_id             => p_enrt_rt_id
                  ,p_ann_val                => l_ann_rt_val
                  ,p_cmcd_val               => l_enrt_rt.cmcd_val
                  ,p_val                    => l_rt_val
            );
            --
          ELSE
            -- use ann_rt_val to drive other values
            --
            --
            l_enrt_rt.cmcd_val := ben_distribute_rates.annual_to_period
                  (p_amount                  => l_ann_rt_val_param, -- p_ann_rt_val, 5259005
                   p_elig_per_elctbl_chc_id  => l_enrt_rt.elig_per_elctbl_chc_id,
                   p_acty_ref_perd_cd        => l_enrt_rt.cmcd_acty_ref_perd_cd,
                   p_business_group_id       => p_business_group_id,
                   p_effective_date          => l_effective_date,
                   p_complete_year_flag      => 'Y',
                   p_payroll_id              => l_payroll_id,
                   p_element_type_id         => l_element_type_id,
                   p_person_id               => p_person_id
                   );
            --Bug#3540351
            if l_enrt_rt.cmcd_val < 0 then
               l_enrt_rt.cmcd_val := 0;
               l_rt_val := 0;
            else
              --Bug 3253180
              --l_rt_val:= l_enrt_rt.cmcd_val;
              --
              l_rt_val := ben_distribute_rates.annual_to_period
                      (p_amount                  => l_ann_rt_val_param, --p_ann_rt_val, 5259005
                       p_enrt_rt_id              => p_enrt_rt_id,
                       p_acty_ref_perd_cd        => p_acty_ref_perd_cd,
                       p_business_group_id       => p_business_group_id,
                       p_effective_date          => l_effective_date,
                       p_complete_year_flag      => 'Y',
                       p_use_balance_flag        => 'Y',
                       p_payroll_id              => l_payroll_id,
                       p_element_type_id         => l_element_type_id,
                       p_rounding_flag           => 'N',
                       p_person_id               => p_person_id
                       );
           end if;
            --
            l_rt_val := round(l_rt_val,4);
            l_ann_rt_val := l_ann_rt_val_param; --p_ann_rt_val; 5259005
            --
          END IF; --GEVITY
          --
          if g_debug then
            hr_utility.set_location('IK p_rt_val is null l_rt_val '||l_rt_val,101);
            hr_utility.set_location('IK p_rt_val is null l_ann_rt_val: '||l_ann_rt_val,101);
            hr_utility.set_location('IK p_rt_val is null l_enrt_rt.cmcd_val'||l_enrt_rt.cmcd_val,101);
          end if;
          --
        else
          --this condition added if the l_rt_val is not gone throu the post enrl calc
          -- then intialised here
          /*
          if l_rt_val is null then
             l_rt_val:=p_rt_val;
             l_ann_rt_val:=p_ann_rt_val;
          end if ;
          */
          --
          l_ann_rt_val := l_ann_rt_val_param; -- p_ann_rt_val; 5259005
          --
          -- calculate annual rate for the child
          if l_prnt_ann_rt = 'Y' then
             --
             if g_debug then
               hr_utility.set_location('Annual value'||l_prnt_ann_val,11);
             end if;
             benutils.rt_typ_calc
              (p_rt_typ_cd      => l_enrt_rt.abr_typ_cd
              ,p_val            => l_enrt_rt.abr_val
              ,p_val_2          => l_prnt_ann_val
              ,p_calculated_val => l_ann_rt_val);
             --
             if (l_enrt_rt.rndg_cd is not null or
                   l_enrt_rt.rndg_rl is not null) then
               --
                l_rounded_value := benutils.do_rounding
                  (p_rounding_cd     => l_enrt_rt.rndg_cd,
                   p_rounding_rl     => l_enrt_rt.rndg_rl,
                   p_value           => l_ann_rt_val,
                   p_effective_date  => l_effective_date);
                l_ann_rt_val := l_rounded_value;
             end if;
             --
             --GEVITY
             --
             IF l_enrt_rt.rate_periodization_rl IS NOT NULL THEN
               --
               l_ann_dummy := l_ann_rt_val;
               --
               ben_distribute_rates.periodize_with_rule
                  (p_formula_id             => l_enrt_rt.rate_periodization_rl
                  ,p_effective_date         => l_effective_date
                  ,p_assignment_id          => l_assignment_id
                  ,p_convert_from_val       => l_ann_dummy
                  ,p_convert_from           => 'ANNUAL'
                  ,p_elig_per_elctbl_chc_id => l_enrt_rt.elig_per_elctbl_chc_id
                  ,p_acty_base_rt_id        => l_enrt_rt.acty_base_rt_id
                  ,p_business_group_id      => p_business_group_id
                  ,p_enrt_rt_id             => p_enrt_rt_id
                  ,p_ann_val                => l_ann_rt_val
                  ,p_cmcd_val               => l_enrt_rt.cmcd_val
                  ,p_val                    => l_rt_val
               );
               --
             ELSE
               --
               l_rt_val := ben_distribute_rates.annual_to_period(
                                      p_amount  => l_ann_rt_val
                                     ,p_enrt_rt_id =>p_enrt_rt_id
                                     ,p_elig_per_elctbl_chc_id => null
                                     ,p_acty_ref_perd_cd => null
                                     ,p_business_group_id =>p_business_group_id
                                     ,p_effective_date => l_effective_date
                                     ,p_lf_evt_ocrd_dt => null
                                     ,p_complete_year_flag => 'Y'
                                     ,p_use_balance_flag => 'Y'
                                     ,p_start_date => null
                                     ,p_end_date => null
                                     ,p_rounding_flag => 'N'
                                     ,p_person_id     => p_person_id); --Bug 2149438
                --
                -- Bug 2149438 I am doing it to 3 because right now we have 2 digit rouding for
                -- the final value. Once we implement the rounding completely for the
                -- rate value this needs to be atleast one digit more than the
                -- actual rounding code dictates.
                --
                if l_rt_val < 0 then
                   l_rt_val := 0;
                   l_enrt_rt.cmcd_val := 0;
                else
                  --
                  --
                  --
                  l_enrt_rt.cmcd_val := ben_distribute_rates.annual_to_period
                      (p_amount                  => l_ann_rt_val,
                       --p_elig_per_elctbl_chc_id  => l_enrt_rt.elig_per_elctbl_chc_id,
                       p_enrt_rt_id              => p_enrt_rt_id,
                       p_acty_ref_perd_cd        => l_enrt_rt.cmcd_acty_ref_perd_cd,
                       p_business_group_id       => p_business_group_id,
                       p_effective_date          => l_effective_date,
                       p_use_balance_flag        => 'Y',
               --      p_complete_year_flag      => 'Y',
                       p_start_date              => l_enrt_rt.rt_strt_dt,
                       p_payroll_id              => l_payroll_id,
                       p_element_type_id         => l_element_type_id,
                       p_person_id               => p_person_id
                       );
                end if;
                --
             END IF; --GEVITY
          else -- let us find the right l_rt_val for annual rate using proper rounding
            -- Bug 2833116
            -- Bug 2675486 fixes for FSA
            l_sarec_compute := true;
            if l_old_ann_rt_val = l_ann_rt_val and l_old_rt_strt_dt is not null
               and l_enrt_rt.rate_periodization_rl IS NULL then
              -- Case - Benefit amount not changed and currently enrolled case
              -- See if the current rate is started in the present popl yr period.
              -- If started in current yr_perd then DONT compute defined and comm amounts
              -- else compute the defined comm amounts.
              -- l_sarec_compute
              open c_pl_popl_yr_period_current(p_pl_id,p_pgm_id,l_effective_date);
                fetch c_pl_popl_yr_period_current into l_yp_start_date ;
              close c_pl_popl_yr_period_current ;
              --
              if l_old_rt_strt_dt >= l_yp_start_date then
                -- Already enrolled in the same yr_perd and amount not changed so
                -- dont recompute the amounts
                  --bug#3364910 - check for payroll type change
                    l_period_type:=null;
                    open c_payroll_type_changed(
                          cp_person_id           =>p_person_id,
                          cp_business_group_id   =>p_business_group_id,
                          cp_effective_date      =>l_enrt_rt.rt_strt_dt,
                          cp_orig_effective_date =>l_old_rt_strt_dt);
                    fetch c_payroll_type_changed into l_period_type;
                    close c_payroll_type_changed;
               --      no change in payroll then dont recompute
                    if l_period_type is null then

                       if g_debug then
                         hr_utility.set_location('Same Yr Period and same rate ' ,123);
                       end if;
                       l_sarec_compute := false ;
                    end if;
              end if ;
              --
            end if ;
            --
            if l_sarec_compute then
              --GEVITY
              --
              IF l_enrt_rt.rate_periodization_rl IS NOT NULL THEN
                --
                l_ann_dummy := l_ann_rt_val;
                --
                ben_distribute_rates.periodize_with_rule
                  (p_formula_id             => l_enrt_rt.rate_periodization_rl
                  ,p_effective_date         => l_effective_date
                  ,p_assignment_id          => l_assignment_id
                  ,p_convert_from_val       => l_ann_dummy
                  ,p_convert_from           => 'ANNUAL'
                  ,p_elig_per_elctbl_chc_id => l_enrt_rt.elig_per_elctbl_chc_id
                  ,p_acty_base_rt_id        => l_enrt_rt.acty_base_rt_id
                  ,p_business_group_id      => p_business_group_id
                  ,p_enrt_rt_id             => p_enrt_rt_id
                  ,p_ann_val                => l_ann_rt_val
                  ,p_cmcd_val               => l_enrt_rt.cmcd_val
                  ,p_val                    => l_rt_val
                );
                --
              ELSE
                --
                l_rt_val := ben_distribute_rates.annual_to_period
                      (p_amount                  => l_ann_rt_val,
                       p_enrt_rt_id              => p_enrt_rt_id,
                       p_acty_ref_perd_cd        => p_acty_ref_perd_cd,
                       p_business_group_id       => p_business_group_id,
                       p_effective_date          => l_effective_date,
                       p_complete_year_flag      => 'Y',
                       p_use_balance_flag        => 'Y',
                       p_payroll_id              => l_payroll_id,
                       p_element_type_id         => l_element_type_id,
                       p_rounding_flag           => 'N',
                       p_person_id               => p_person_id
                       );
                --
                if l_rt_val < 0 then
                   l_rt_val := 0;
                   l_enrt_rt.cmcd_val := 0;
                else
                  --
                  l_rt_val := round(l_rt_val,4);
                  --
                  l_enrt_rt.cmcd_val := ben_distribute_rates.annual_to_period
                        (p_amount                  => l_ann_rt_val,
                         --p_elig_per_elctbl_chc_id  => l_enrt_rt.elig_per_elctbl_chc_id,
                         p_enrt_rt_id              => p_enrt_rt_id,
                         p_acty_ref_perd_cd        => l_enrt_rt.cmcd_acty_ref_perd_cd,
                         p_business_group_id       => p_business_group_id,
                         p_effective_date          => l_effective_date,
                         p_use_balance_flag        => 'Y',
                         -- p_complete_year_flag      => 'Y',
                         p_start_date              => l_enrt_rt.rt_strt_dt,
                         p_payroll_id              => l_payroll_id,
                         p_element_type_id         => l_element_type_id,
                         p_person_id               => p_person_id
                         );
                  --
                end if;
                --
              END IF; --GEVITY
              --
              if g_debug then
                 hr_utility.set_location('IK p_rt_val is NOT null l_rt_val '||l_rt_val,101);
                 hr_utility.set_location('IK p_rt_val is NOT null l_ann_rt_val: '||l_ann_rt_val,101);
                 hr_utility.set_location('IK p_rt_val is NOT null l_enrt_rt.cmcd_val'||l_enrt_rt.cmcd_val,101);
              end if;
              --
            else
              --
              l_rt_val           := l_old_rt_val ;
              l_calc_ann_val     := l_ann_rt_val;
              l_enrt_rt.cmcd_val := l_old_cmcd_rt_val ;
              --
              if g_debug then
                hr_utility.set_location('Continue old rate '||l_old_rt_val,123);
              end if;
              --
              if g_debug then
                hr_utility.set_location(' l_old_cmcd_rt_val '||l_old_cmcd_rt_val,123);
              end if;
              --
            end if;  -- l_sarec_compute
            --
          end if;
          -- ann_rt_val and rt_val are set, set locals
          --
        end if;
      else
        --
        -- annual not entered
        --
       if l_enrt_rt.rt_mlt_cd <> 'SAREC' then
         --
         -- If the rate is based on coverage and the coverage value is entered
         -- at enrollment, we must re-calculate the rate value.
         --
         /*BUG 3804813 We don't need to check for l_enrt_rt.rt_mlt_cd <> 'FLFX'
           Lets recompute id entr_bnft_val_flag = 'Y' which makes perfect sense.
         if (l_enrt_rt.entr_bnft_val_flag = 'Y' and
            l_enrt_rt.rt_mlt_cd <> 'FLFX') or
             l_enrt_rt.rt_mlt_cd = 'ERL'or
             l_enrt_rt.cvg_mlt_cd = 'ERL'  then -- ERL added for canon fix
           if g_debug then
             hr_utility.set_location('p_rt_val'||to_char(p_rt_val), 312);
             hr_utility.set_location( 'l_global_pen_rec.bnft_am'||l_global_pen_rec.bnft_amt ,314);
           end if;
         --BUG 3804813  */
         --START BUG 3804813
         if (l_enrt_rt.entr_bnft_val_flag = 'Y' OR
             l_enrt_rt.interim_flag = 'Y' OR   --For Interim Rule BUG 5502202
             l_enrt_rt.rt_mlt_cd = 'ERL'or
             l_enrt_rt.cvg_mlt_cd = 'ERL') -- ERL added for canon fix
         and l_enrt_rt.entr_val_at_enrt_flag = 'N' then -- Bug 4710188, Calling rates pack
                                                        -- rate is not enterable only when
           if g_debug then
             hr_utility.set_location('p_rt_val'||to_char(p_rt_val), 312);
             hr_utility.set_location('l_rt_val_param'||to_char(l_rt_val_param), 312);
             hr_utility.set_location( 'l_global_pen_rec.bnft_am'||l_global_pen_rec.bnft_amt ,314);
           end if;
           --END BUG 3804813
           if l_enrt_rt.enrt_bnft_id = 0 then
             l_enrt_rt.enrt_bnft_id := null;
           end if;
           ben_determine_activity_base_rt.main
             (p_person_id                  => p_person_id
             ,p_elig_per_elctbl_chc_id      => l_enrt_rt.elig_per_elctbl_chc_id
             ,p_enrt_bnft_id                => l_enrt_rt.enrt_bnft_id
             ,p_acty_base_rt_id             => l_enrt_rt.acty_base_rt_id
             ,p_effective_date              => p_effective_date
             ,p_per_in_ler_id               => p_per_in_ler_id
             ,p_lf_evt_ocrd_dt              => l_lf_evt_ocrd_dt -- Added Bug 3488286
             ,p_pl_id                       => p_pl_id
             ,p_pgm_id                      => p_pgm_id
             ,p_oipl_id                     => p_oipl_id
             ,p_pl_typ_id                   => l_global_pen_rec.pl_typ_id
             ,p_ler_id                      => l_ler_id -- Bug 8374859
             ,p_business_group_id           => p_business_group_id
             ,p_perform_rounding_flg        => true
             ,p_calc_only_rt_val_flag       => true
             ,p_bnft_amt                    => l_global_pen_rec.bnft_amt
             -- the following are all out parms:  the only ones we want are rate values.
             ,p_val                         => l_rt_val
             ,p_mn_elcn_val                 => l_dummy_num
             ,p_mx_elcn_val                 => l_dummy_num
             ,p_ann_val                     => l_ann_rt_val
             ,p_ann_mn_elcn_val             => l_dummy_num
             ,p_ann_mx_elcn_val             => l_dummy_num
             ,p_cmcd_val                    => l_dummy_num
             ,p_cmcd_mn_elcn_val            => l_dummy_num
             ,p_cmcd_mx_elcn_val            => l_dummy_num
             ,p_cmcd_acty_ref_perd_cd       => l_dummy_varchar2
             ,p_incrmt_elcn_val             => l_dummy_num
             ,p_dflt_val                    => l_dummy_num
             ,p_tx_typ_cd                   => l_dummy_varchar2
             ,p_acty_typ_cd                 => l_dummy_varchar2
             ,p_nnmntry_uom                 => l_dummy_varchar2
             ,p_entr_val_at_enrt_flag       => l_dummy_varchar2
             ,p_dsply_on_enrt_flag          => l_dummy_varchar2
             ,p_use_to_calc_net_flx_cr_flag => l_dummy_varchar2
             ,p_rt_usg_cd                   => l_dummy_varchar2
             ,p_bnft_prvdr_pool_id          => l_dummy_num
             ,p_actl_prem_id                => l_dummy_num
             ,p_cvg_calc_amt_mthd_id        => l_dummy_num
             ,p_bnft_rt_typ_cd              => l_dummy_varchar2
             ,p_rt_typ_cd                   => l_dummy_varchar2
             ,p_rt_mlt_cd                   => l_dummy_varchar2
             ,p_comp_lvl_fctr_id            => l_dummy_num
             ,p_entr_ann_val_flag           => l_dummy_varchar2
             ,p_ptd_comp_lvl_fctr_id        => l_dummy_num
             ,p_clm_comp_lvl_fctr_id        => l_dummy_num
             ,p_ann_dflt_val                => l_dummy_num
             ,p_rt_strt_dt                  => l_dummy_date
             ,p_rt_strt_dt_cd               => l_dummy_varchar2
             ,p_rt_strt_dt_rl               => l_dummy_num
             ,p_prtt_rt_val_id              => l_dummy_num
             ,p_dsply_mn_elcn_val           => l_dummy_num
             ,p_dsply_mx_elcn_val           => l_dummy_num
             ,p_pp_in_yr_used_num           => l_dummy_num
             ,p_ordr_num                => l_dummy_num
             ,p_iss_val                     =>l_dummy_num
             );
           if g_debug then
             hr_utility.set_location('l_rt_val'||to_char(l_rt_val), 312);
           end if;

         ELSE -- 5375381 :Added else part
	       /* This is purely for Interim pen which has has same epe as of its Sspndd pen.
	        And sspndd pen has entr_bnft_val_flag = 'Y'
	       */
                  OPEN c_sspnd_enrt_rt (l_enrt_rt.elig_per_elctbl_chc_id);
                  FETCH c_sspnd_enrt_rt INTO l_sspnd_enrt_rt;
                  CLOSE c_sspnd_enrt_rt;

                  IF     l_enrt_rt.entr_val_at_enrt_flag = 'N'
                     AND (    (   l_sspnd_enrt_rt.entr_bnft_val_flag = 'Y'
                               OR l_sspnd_enrt_rt.rt_mlt_cd = 'ERL'
                               OR l_sspnd_enrt_rt.cvg_mlt_cd = 'ERL'
                              )
                          AND l_sspnd_enrt_rt.entr_val_at_enrt_flag = 'N'
                         )
                  THEN
                     IF g_debug
                     THEN
                        hr_utility.set_location (   'p_rt_val'
                                                 || TO_CHAR (p_rt_val),
                                                 555
                                                );
                        hr_utility.set_location (   'l_rt_val_param'
                                                 || TO_CHAR (l_rt_val_param),
                                                 555
                                                );
                        hr_utility.set_location (   'l_global_pen_rec.bnft_am'
                                                 || l_global_pen_rec.bnft_amt,
                                                 555
                                                );
                     END IF;

                     IF l_enrt_rt.enrt_bnft_id = 0
                     THEN
                        l_enrt_rt.enrt_bnft_id := NULL;
                     END IF;

                     ben_determine_activity_base_rt.main (p_person_id                        => p_person_id,
                                                          p_elig_per_elctbl_chc_id           => l_enrt_rt.elig_per_elctbl_chc_id,
                                                          p_enrt_bnft_id                     => l_enrt_rt.enrt_bnft_id,
                                                          p_acty_base_rt_id                  => l_enrt_rt.acty_base_rt_id,
                                                          p_effective_date                   => p_effective_date,
                                                          p_per_in_ler_id                    => p_per_in_ler_id,
                                                          p_lf_evt_ocrd_dt                   => l_lf_evt_ocrd_dt, -- Added Bug 3488286

                                                          p_pl_id                            => p_pl_id,
                                                          p_pgm_id                           => p_pgm_id,
                                                          p_oipl_id                          => p_oipl_id,
                                                          p_pl_typ_id                        => l_global_pen_rec.pl_typ_id,
                                                          p_ler_id                           => l_ler_id,  -- Bug 8374859
                                                          p_business_group_id                => p_business_group_id,
                                                          p_perform_rounding_flg             => TRUE,
                                                          p_calc_only_rt_val_flag            => TRUE,
                                                          p_bnft_amt                         => l_global_pen_rec.bnft_amt,-- the following are all out parms:  the only ones we want are rate values.

                                                          p_val                              => l_rt_val,
                                                          p_mn_elcn_val                      => l_dummy_num,
                                                          p_mx_elcn_val                      => l_dummy_num,
                                                          p_ann_val                          => l_ann_rt_val,
                                                          p_ann_mn_elcn_val                  => l_dummy_num,
                                                          p_ann_mx_elcn_val                  => l_dummy_num,
                                                          p_cmcd_val                         => l_dummy_num,
                                                          p_cmcd_mn_elcn_val                 => l_dummy_num,
                                                          p_cmcd_mx_elcn_val                 => l_dummy_num,
                                                          p_cmcd_acty_ref_perd_cd            => l_dummy_varchar2,
                                                          p_incrmt_elcn_val                  => l_dummy_num,
                                                          p_dflt_val                         => l_dummy_num,
                                                          p_tx_typ_cd                        => l_dummy_varchar2,
                                                          p_acty_typ_cd                      => l_dummy_varchar2,
                                                          p_nnmntry_uom                      => l_dummy_varchar2,
                                                          p_entr_val_at_enrt_flag            => l_dummy_varchar2,
                                                          p_dsply_on_enrt_flag               => l_dummy_varchar2,
                                                          p_use_to_calc_net_flx_cr_flag      => l_dummy_varchar2,
                                                          p_rt_usg_cd                        => l_dummy_varchar2,
                                                          p_bnft_prvdr_pool_id               => l_dummy_num,
                                                          p_actl_prem_id                     => l_dummy_num,
                                                          p_cvg_calc_amt_mthd_id             => l_dummy_num,
                                                          p_bnft_rt_typ_cd                   => l_dummy_varchar2,
                                                          p_rt_typ_cd                        => l_dummy_varchar2,
                                                          p_rt_mlt_cd                        => l_dummy_varchar2,
                                                          p_comp_lvl_fctr_id                 => l_dummy_num,
                                                          p_entr_ann_val_flag                => l_dummy_varchar2,
                                                          p_ptd_comp_lvl_fctr_id             => l_dummy_num,
                                                          p_clm_comp_lvl_fctr_id             => l_dummy_num,
                                                          p_ann_dflt_val                     => l_dummy_num,
                                                          p_rt_strt_dt                       => l_dummy_date,
                                                          p_rt_strt_dt_cd                    => l_dummy_varchar2,
                                                          p_rt_strt_dt_rl                    => l_dummy_num,
                                                          p_prtt_rt_val_id                   => l_dummy_num,
                                                          p_dsply_mn_elcn_val                => l_dummy_num,
                                                          p_dsply_mx_elcn_val                => l_dummy_num,
                                                          p_pp_in_yr_used_num                => l_dummy_num,
                                                          p_ordr_num                         => l_dummy_num,
                                                          p_iss_val                          => l_dummy_num
                                                         );

                     IF g_debug
                     THEN
                        hr_utility.set_location (   'l_rt_val'
                                                 || TO_CHAR (l_rt_val),
                                                 556
                                                );
                     END IF;
                  ELSE
                     l_ann_rt_val := l_ann_rt_val_param; -- p_ann_rt_val; 5259005
                     l_rt_val := l_rt_val_param; --p_rt_val; 5259005
                  END IF;
         end if;
         --- bug : 1555624 if the parent defined as entr_val_At_enrt_flag and use_calc_acty_bs_rt_flag
         --- then call the rate calcualtion
         if l_enrt_rt.rt_mlt_cd in ('PRNT','PRNTANDCVG') then
	     /* BUG 8244388 open c_abr2 and c_prv2 with l_enrt_rt.rt_strt_dt instead of l_effective_date */
             open c_abr2(l_enrt_rt.rt_strt_dt,l_enrt_rt.acty_base_rt_id ) ;
             fetch c_abr2 into l_prnt_abr ;
             --- take the rate from the parent rcord
             if c_abr2%found then
                open c_prv2(p_prtt_enrt_rslt_id,l_prnt_abr.acty_base_rt_id,l_enrt_rt.rt_strt_dt );
                fetch  c_prv2 into l_prnt_rt_val ,l_prnt_ann_val;
                close  c_prv2 ;
             end if ;
             close c_abr2 ;
         end if ;

         --
         --  bug 1480407
         --
         if g_debug then
           hr_utility.set_location('entr_val_At_enrt_flag '||l_enrt_rt.entr_val_At_enrt_flag ,407);
           hr_utility.set_location('use_calc_acty_bs_rt_flag '||l_enrt_rt.use_calc_acty_bs_rt_flag ,407);
           hr_utility.set_location('l_enrt_rt.rt_mlt_cd' ||l_enrt_rt.rt_mlt_cd , 407);
         end if;
         --
         -- tilak :Rate calclation is called either the std rate  entr_val_At_enrt_flag is on and
         -- use_calc_acty_bs_rt_flag is on for coverage and other
         -- OR  std rate has parent and the parent's entr_val_At_enrt_flag is on
         -- and use_calc_acty_bs_rt_flag is on so the parent calcialted then the child

       if l_enrt_rt.entr_val_At_enrt_flag  = 'Y'
            or nvl(l_prnt_abr.entr_val_at_enrt_flag,'N')  = 'Y'  then
           --
           -- get values from annual value
           --
          If ( l_enrt_rt.entr_val_At_enrt_flag  = 'Y'
              and l_enrt_rt.use_calc_acty_bs_rt_flag = 'Y'
              and l_enrt_rt.rt_mlt_cd in('CVG','CL','PRNT','AP') )
             or
              (nvl(l_prnt_abr.entr_val_at_enrt_flag,'N')  = 'Y'
              and nvl(l_prnt_abr.use_calc_acty_bs_rt_flag,'N')  = 'Y'
              and l_enrt_rt.rt_mlt_cd in('PRNT','PRNTANDCVG')  ) then

             if g_debug then
               hr_utility.set_location(' calllign rate '||l_rt_val  ,407);
             end if;
             --
             -- NOCOPY ISSUE
             l_cal_val_in := l_rt_val ;
             -- END NOCOPY ISSUE
             --
             BEN_DETERMINE_ACTIVITY_BASE_RT.main
               (p_person_id                  => p_person_id
               ,p_elig_per_elctbl_chc_id      => l_enrt_rt.elig_per_elctbl_chc_id
               ,p_enrt_bnft_id                => l_enrt_rt.enrt_bnft_id
               ,p_acty_base_rt_id             => l_enrt_rt.acty_base_rt_id
               ,p_effective_date              => p_effective_date
               ,p_per_in_ler_id               => p_per_in_ler_id
               ,p_lf_evt_ocrd_dt              => l_lf_evt_ocrd_dt -- Added Bug 3488286
               ,p_pl_id                       => p_pl_id
               ,p_pgm_id                      => p_pgm_id
               ,p_oipl_id                     => p_oipl_id
               ,p_pl_typ_id                   => l_global_pen_rec.pl_typ_id
               ,p_ler_id                      => l_ler_id -- 8374859
               ,p_business_group_id           => p_business_group_id
               ,p_perform_rounding_flg        => true
               ,p_calc_only_rt_val_flag       => true
               ,p_bnft_amt                    => l_global_pen_rec.bnft_amt
               ,p_cal_val                     => l_cal_val_in -- NOCOPY ISSUE l_rt_val
               ,p_parent_val                  => l_prnt_rt_val
               ,p_val                         => l_rt_val
               ,p_mn_elcn_val                 => l_dummy_num
               ,p_mx_elcn_val                 => l_dummy_num
               ,p_ann_val                     => l_ann_rt_val
               ,p_ann_mn_elcn_val             => l_dummy_num
               ,p_ann_mx_elcn_val             => l_dummy_num
               ,p_cmcd_val                    => l_dummy_num
               ,p_cmcd_mn_elcn_val            => l_dummy_num
               ,p_cmcd_mx_elcn_val            => l_dummy_num
               ,p_cmcd_acty_ref_perd_cd       => l_dummy_varchar2
               ,p_incrmt_elcn_val             => l_dummy_num
               ,p_dflt_val                    => l_dummy_num
               ,p_tx_typ_cd                   => l_dummy_varchar2
               ,p_acty_typ_cd                 => l_dummy_varchar2
               ,p_nnmntry_uom                 => l_dummy_varchar2
               ,p_entr_val_at_enrt_flag       => l_dummy_varchar2
               ,p_dsply_on_enrt_flag          => l_dummy_varchar2
               ,p_use_to_calc_net_flx_cr_flag => l_dummy_varchar2
               ,p_rt_usg_cd                   => l_dummy_varchar2
               ,p_bnft_prvdr_pool_id          => l_dummy_num
               ,p_actl_prem_id                => l_dummy_num
               ,p_cvg_calc_amt_mthd_id        => l_dummy_num
               ,p_bnft_rt_typ_cd              => l_dummy_varchar2
               ,p_rt_typ_cd                   => l_dummy_varchar2
               ,p_rt_mlt_cd                   => l_dummy_varchar2
               ,p_comp_lvl_fctr_id            => l_dummy_num
               ,p_entr_ann_val_flag           => l_dummy_varchar2
               ,p_ptd_comp_lvl_fctr_id        => l_dummy_num
               ,p_clm_comp_lvl_fctr_id        => l_dummy_num
               ,p_ann_dflt_val                => l_dummy_num
               ,p_rt_strt_dt                  => l_dummy_date
               ,p_rt_strt_dt_cd               => l_dummy_varchar2
               ,p_rt_strt_dt_rl               => l_dummy_num
               ,p_prtt_rt_val_id              => l_dummy_num
               ,p_dsply_mn_elcn_val           => l_dummy_num
               ,p_dsply_mx_elcn_val           => l_dummy_num
               ,p_pp_in_yr_used_num           => l_dummy_num
               ,p_ordr_num                    => l_dummy_num
               ,p_iss_val                     => l_dummy_num
               );
             if g_debug then
               hr_utility.set_location(' rate ' ||l_rt_val,407);
             end if;
           End if ;
         end if;
         --
         --GEVITY
         --
         IF l_enrt_rt.rate_periodization_rl IS NOT NULL THEN
           --
           l_dfnd_dummy := l_rt_val;
           --
           ben_distribute_rates.periodize_with_rule
                  (p_formula_id             => l_enrt_rt.rate_periodization_rl
                  ,p_effective_date         => l_effective_date
                  ,p_assignment_id          => l_assignment_id
                  ,p_convert_from_val       => l_dfnd_dummy
                  ,p_convert_from           => 'DEFINED'
                  ,p_elig_per_elctbl_chc_id => l_enrt_rt.elig_per_elctbl_chc_id
                  ,p_acty_base_rt_id        => l_enrt_rt.acty_base_rt_id
                  ,p_business_group_id      => p_business_group_id
                  ,p_enrt_rt_id             => p_enrt_rt_id
                  ,p_ann_val                => l_ann_rt_val
                  ,p_cmcd_val               => l_enrt_rt.cmcd_val
                  ,p_val                    => l_rt_val
            );
            --
         ELSE
           --
           l_ann_rt_val := ben_distribute_rates.period_to_annual
                           (p_amount                  => l_rt_val
                           ,p_enrt_rt_id              => p_enrt_rt_id
                           ,p_elig_per_elctbl_chc_id  => l_enrt_rt.elig_per_elctbl_chc_id
                           ,p_acty_ref_perd_cd        => p_acty_ref_perd_cd
                           ,p_business_group_id       => p_business_group_id
                           ,p_effective_date          => l_effective_date
                           ,p_complete_year_flag      => 'Y'
                           ,p_use_balance_flag        => 'Y'
                           ,p_payroll_id              => l_payroll_id
                           );
           --
           -- always compute the cmcd rate based on the annual value
           --
           l_calc_ann_val := ben_distribute_rates.period_to_annual
                             (p_amount                  => l_rt_val
                             ,p_enrt_rt_id              => p_enrt_rt_id
                             ,p_elig_per_elctbl_chc_id  => l_enrt_rt.elig_per_elctbl_chc_id
                             ,p_acty_ref_perd_cd        => p_acty_ref_perd_cd
                             ,p_business_group_id       => p_business_group_id
                             ,p_effective_date          => l_effective_date
                             ,p_complete_year_flag      => 'Y'
                             ,p_payroll_id              => l_payroll_id
                             );
           --
           l_enrt_rt.cmcd_val := ben_distribute_rates.annual_to_period
                                 (p_amount                  => l_calc_ann_val
                                 ,p_elig_per_elctbl_chc_id  => l_enrt_rt.elig_per_elctbl_chc_id
                                 ,p_acty_ref_perd_cd        => l_enrt_rt.cmcd_acty_ref_perd_cd
                                 ,p_business_group_id       => p_business_group_id
                                 ,p_effective_date          => l_effective_date
                                 ,p_complete_year_flag      => 'Y'
                                 ,p_payroll_id              => l_payroll_id
                                 ,p_element_type_id         => l_element_type_id
                                 ,p_person_id               => p_person_id
                                 );
           --
         END IF; --GEVITY
       if g_debug then
         hr_utility.set_location('ann val'||l_ann_rt_val||'cal ann val'||l_calc_ann_val,100);
          hr_utility.set_location('communicated val'||l_enrt_rt.cmcd_val,101);
       end if;
    else  --mlt_cd='SAREC'
        if l_enrt_rt.entr_bnft_val_flag = 'Y' then
           if g_debug then
             hr_utility.set_location('p_rt_val'||to_char(p_rt_val), 319);
             hr_utility.set_location('p_ann_rt_val'||to_char(p_ann_rt_val), 319);
             hr_utility.set_location('l_rt_val_param'||to_char(l_rt_val_param), 319);          -- 5259005
             hr_utility.set_location('l_ann_rt_val_param'||to_char(l_ann_rt_val_param), 319);  -- 5259005
             hr_utility.set_location('bnft_val'||to_char(l_global_pen_rec.bnft_amt), 319);
           end if;
          --
          l_ann_rt_val := l_global_pen_rec.bnft_amt;
          -- Bug 2675486 fixes for FSA
          if l_old_ann_rt_val = l_ann_rt_val and l_old_rt_strt_dt is not null then
            -- Case - Benefit amount not changed and currently enrolled case
            -- See if the current rate is started in the present popl yr period.
            -- If started in current yr_perd then DONT compute defined and comm amounts
            -- else compute the defined comm amounts.
            -- l_sarec_compute
            open c_pl_popl_yr_period_current(p_pl_id,p_pgm_id,l_effective_date);
              fetch c_pl_popl_yr_period_current into l_yp_start_date ;
            close c_pl_popl_yr_period_current ;
            --
            if l_old_rt_strt_dt >= l_yp_start_date then
              -- Already enrolled in the same yr_perd and amount not changed so
              -- dont recompute the amounts
                  --bug#3364910 - check for payroll type change
                    l_period_type:=null;
                    open c_payroll_type_changed(
                          cp_person_id           =>p_person_id,
                          cp_business_group_id   =>p_business_group_id,
                          cp_effective_date      =>l_enrt_rt.rt_strt_dt,
                          cp_orig_effective_date =>l_old_rt_strt_dt);
                    fetch c_payroll_type_changed into l_period_type;
                    close c_payroll_type_changed;
               --      no change in payroll then dont recompute
                    if l_period_type is null then

                       if g_debug then
                         hr_utility.set_location('Same Yr Period and same rate ' ,124);
                       end if;
                       l_sarec_compute := false ;
		       --Check if there is any change in the assignment,9143356
		       hr_utility.set_location('Check for the assg change ' ,124);
                       open c_assignment_changed(
		                cp_person_id           =>p_person_id,
				cp_business_group_id   =>p_business_group_id,
				cp_effective_date      =>l_enrt_rt.rt_strt_dt,
				cp_orig_effective_date =>l_old_rt_strt_dt);
		       fetch c_assignment_changed into l_assignment_changed;
		       if c_assignment_changed%found then
		         hr_utility.set_location('Assg change found ' ,124);
			  hr_utility.set_location('sarec compute is set to true ' ,124);
		         l_sarec_compute := true ;
		       end if;
		       close c_assignment_changed;
                    end if;
            end if ;
            --
          end if ;
          --
          --l_ann_rt_val := l_global_pen_rec.bnft_amt;
          -- ikasire commented p_complete_year_flag => 'Y' per Bug 1650517
          if l_sarec_compute then
            --GEVITY
            --
            IF l_enrt_rt.rate_periodization_rl IS NOT NULL THEN
              --
              l_ann_dummy := l_ann_rt_val;
              --
              ben_distribute_rates.periodize_with_rule
                  (p_formula_id             => l_enrt_rt.rate_periodization_rl
                  ,p_effective_date         => l_effective_date
                  ,p_assignment_id          => l_assignment_id
                  ,p_convert_from_val       => l_ann_dummy
                  ,p_convert_from           => 'ANNUAL'
                  ,p_elig_per_elctbl_chc_id => l_enrt_rt.elig_per_elctbl_chc_id
                  ,p_acty_base_rt_id        => l_enrt_rt.acty_base_rt_id
                  ,p_business_group_id      => p_business_group_id
                  ,p_enrt_rt_id             => p_enrt_rt_id
                  ,p_ann_val                => l_ann_rt_val
                  ,p_cmcd_val               => l_enrt_rt.cmcd_val
                  ,p_val                    => l_rt_val
                );
                --
            ELSE
                --
              l_rt_val := ben_distribute_rates.annual_to_period
                    (p_amount                  => l_ann_rt_val,
                     p_enrt_rt_id              => p_enrt_rt_id,
                     p_acty_ref_perd_cd        => p_acty_ref_perd_cd,
                     p_business_group_id       => p_business_group_id,
                     p_effective_date          => l_effective_date,
                     p_complete_year_flag      => 'Y',
                     p_use_balance_flag        => 'Y',
		     p_start_date              => l_enrt_rt.rt_strt_dt,  ---Bug 9309878
                     p_payroll_id              => l_payroll_id,
                     p_element_type_id         => l_element_type_id,
                     p_rounding_flag           => 'N',
                     p_person_id               => p_person_id
                     );
              if g_debug then
                hr_utility.set_location(' IK l_rt_val '||l_rt_val,123);
              end if;
              --
              -- Bug 2149438 I am doing it to 3 because right now we have 2 digit rouding for
              -- the final value. Once we implement the rounding completely for the
              -- rate value this needs to be atleast one digit more than the
              -- actual rounding code dictates.
              --
              l_rt_val := round(l_rt_val,4);
              --
              if g_debug then
                hr_utility.set_location(' IK2 rounded l_rt_val '||l_rt_val,123);
              end if;
              /**
               when annual value is passed there is no need to compute the annual value
               from defined value - bug#2398448 and bug#2392732
              l_calc_ann_val := ben_distribute_rates.period_to_annual
                    (p_amount                  => l_rt_val,
                     p_enrt_rt_id              => p_enrt_rt_id,
                     p_acty_ref_perd_cd        => p_acty_ref_perd_cd,
                     p_business_group_id       => p_business_group_id,
                     p_effective_date          => l_effective_date,
                     p_complete_year_flag      => 'Y',
                     p_payroll_id              => l_payroll_id);
              **/
              l_calc_ann_val  := l_ann_rt_val;
               if g_debug then
                 hr_utility.set_location('annval'||to_char(l_calc_ann_val), 319);
               end if;
               if g_debug then
                 hr_utility.set_location('rt val'||l_rt_val, 319);
               end if;
               --Bug#3540351
               if l_rt_val < 0 then
                  l_rt_val := 0;
                  l_enrt_rt.cmcd_val := 0;
                  ben_distribute_rates.compare_balances
                    (p_person_id            => p_person_id
                    ,p_effective_date       => l_effective_date
                    ,p_elig_per_elctbl_chc_id  => l_enrt_rt.elig_per_elctbl_chc_id
                    ,p_acty_base_rt_id      => l_enrt_rt.acty_base_rt_id
                    ,p_ann_mn_val           => l_ann_mn_elcn_val
                    ,p_ann_mx_val           => l_ann_mx_elcn_val
                    ,p_perform_edit_flag    => 'N'
                    ,p_entered_ann_val      => l_ann_rt_val
                    ,p_ptd_balance          => l_ptd_balance
                    ,p_clm_balance          => l_clm_balance ) ;
                 --
                 if l_ann_rt_val < l_ptd_balance then
                   --
                   open c_pl_name (p_pl_id);
                   fetch c_pl_name into l_pl_name;
                   close c_pl_name;
                   --
                   ben_warnings.load_warning
                     (p_application_short_name  => 'BEN',
                      p_message_name            => 'BEN_93951_BELOW_PTD',
                      p_parma => l_pl_name,
                      p_parm1 => l_ann_rt_val,
                      p_parm2 => l_ptd_balance,
                      p_person_id => p_person_id);
                 end if;
               else
                 --
                  l_enrt_rt.cmcd_val := ben_distribute_rates.annual_to_period
                    (p_amount                  => l_calc_ann_val,
                    -- p_elig_per_elctbl_chc_id  => l_enrt_rt.elig_per_elctbl_chc_id,
                     p_enrt_rt_id              => p_enrt_rt_id,
                     p_acty_ref_perd_cd        => l_enrt_rt.cmcd_acty_ref_perd_cd,
                     p_business_group_id       => p_business_group_id,
                     p_effective_date          => l_effective_date,
                     p_use_balance_flag        => 'Y',
                    -- p_complete_year_flag      => 'Y',
                     p_start_date              => l_enrt_rt.rt_strt_dt,
                     p_payroll_id              => l_payroll_id,
                     p_element_type_id         => l_element_type_id,
                     p_person_id               => p_person_id
                     );
               end if;
               --
            END IF; --GEVITY
          else
            --
            l_rt_val := l_old_rt_val ;
            l_calc_ann_val  := l_ann_rt_val;
            l_enrt_rt.cmcd_val := l_old_cmcd_rt_val ;
            if g_debug then
              hr_utility.set_location('Continue old rate '||l_old_rt_val,123);
            end if;
            if g_debug then
              hr_utility.set_location(' l_old_cmcd_rt_val '||l_old_cmcd_rt_val,123);
            end if;
            --
          end if ;
        else
          -- Bug 2223694 when the coverage is not enter value at enrollment
          -- we are not getting the defined amount and element entries.
          if g_debug then
            hr_utility.set_location('IK l_enrt_rt.val '||l_enrt_rt.val ,99);
            hr_utility.set_location('IK l_enrt_rt.ann_val '||l_enrt_rt.ann_val,99);
            hr_utility.set_location('IK l_enrt_rt.cmcd_val '||l_enrt_rt.cmcd_val,99);
          end if;
          l_rt_val  := l_enrt_rt.val ;
          l_calc_ann_val := l_enrt_rt.ann_val ;
          --  3547233. Copy annual value to l_ann_rt_val for prtt_rt_val record.
          l_ann_rt_val := l_enrt_rt.ann_val;
          --
       end if;
    end if;
   end if;
  end if;
  --
  -- determine if element type/input val changed
  --
  if p_prtt_rt_val_id is not null then
     if p_ele_changed is null then

        if l_old_element_entry_value_id is not null then
           open c_element_info (l_old_element_entry_value_id,
                                p_prtt_enrt_rslt_id);
           fetch c_element_info into l_element_info;
           close c_element_info;
           --
           --bug#3378865
           --
           if not (l_old_rt_strt_dt between l_enrt_rt.abr_esd and
              l_enrt_rt.abr_eed) then
              open c_abr(l_enrt_rt.acty_base_rt_id, l_old_rt_strt_dt);
              fetch c_abr into l_ele_entry_val_cd,l_element_type_id,l_input_value_id;
              close c_abr;
           else
              l_ele_entry_val_cd := l_enrt_rt.ele_entry_val_cd;
           end if;
           --
        end if;
        --
        --get the new abr assignment and payroll
        --
        ben_element_entry.get_abr_assignment
        (p_person_id       => p_person_id,
         p_effective_date  => l_enrt_rt.rt_strt_dt,
         p_acty_base_rt_id => l_enrt_rt.acty_base_rt_id,
         p_assignment_id   => l_new_assignment_id,
         p_payroll_id      => l_new_payroll_id,
         p_organization_id => l_new_organization_id);

 /* Adding this call below to fix a bug 6132571. When there are two
 * rates having same element type, the first input value is updated
 * with value zero along with element entry. This while processing the second
 * rate,the cursor c_element_info gets the latest payroll id, which while
 * processing the second rate does not set the flag l_element_changed
 * in the condition below, which impact all further processing */

        ben_element_entry.get_abr_assignment
        (p_person_id       => p_person_id,
         p_effective_date  => l_old_rt_strt_dt,
         p_acty_base_rt_id => l_enrt_rt.acty_base_rt_id,
         p_assignment_id   => l_old_assignment_id,
         p_payroll_id      => l_old_payroll_id,
         p_organization_id => l_old_organization_id);


        hr_utility.set_location('ben_element_entry.get_abr_assignment
                                -Old Assignment Id' ||l_old_assignment_id ,101);
        hr_utility.set_location('ben_element_entry.get_abr_assignment
                                -Old Payroll Id' ||l_old_payroll_id ,101);
        hr_utility.set_location('ben_element_entry.get_abr_assignment
                                -Old Org Id' ||l_old_organization_id ,101);

        l_element_changed :=
            (l_old_element_entry_value_id is not null and
            l_enrt_rt.ele_rqd_flag = 'N') or
           (l_enrt_rt.ele_rqd_flag = 'Y' and
            ((nvl(l_element_info.input_value_id,-1) <>
              l_enrt_rt.input_value_id) or
             (nvl(l_element_info.element_type_id,-1) <>
              l_enrt_rt.element_type_id) or
             (not l_non_recurring_rt and
              l_element_info.effective_end_date < l_enrt_rt.rt_strt_dt) or
             (l_old_assignment_id <> nvl(l_new_assignment_id,-1)) or
             (nvl(l_old_payroll_id,-1) <> nvl(l_new_payroll_id,-1)) or
             (nvl(l_enrt_rt.ele_entry_val_cd,'PP') <>
                nvl(l_ele_entry_val_cd,'PP'))));
        --
        -- determine if extra input values changed
        --
        if not l_element_changed then


           --8589355
	   l_get_opt_id := null;
           hr_utility.set_location( 'l_global_pen_rec.oipl_id '||l_global_pen_rec.oipl_id, 20);
           if l_global_pen_rec.oipl_id is not null then
              open c_get_opt_id(l_global_pen_rec.oipl_id, l_enrt_rt.rt_strt_dt);
	      fetch c_get_opt_id into l_get_opt_id;
	      close c_get_opt_id;
           end if;
           hr_utility.set_location( 'l_get_opt_id.opt_id '||l_get_opt_id.opt_id, 20);
  	   --8589355

           l_ext_inpval_tab.delete;
           ben_element_entry.get_extra_ele_inputs
           (p_effective_date         => l_enrt_rt.rt_strt_dt
           ,p_person_id              => p_person_id
           ,p_business_group_id      => p_business_group_id
           ,p_assignment_id          => l_new_assignment_id
           ,p_element_link_id        => null
           ,p_entry_type             => 'E'
           ,p_input_value_id1        => null
           ,p_entry_value1           => null
           ,p_element_entry_id       => null
           ,p_acty_base_rt_id        => l_enrt_rt.acty_base_rt_id
           ,p_input_va_calc_rl       => l_enrt_rt.input_va_calc_rl
           ,p_abs_ler                => null
           ,p_organization_id        => l_new_organization_id
           ,p_payroll_id             => l_new_payroll_id
           ,p_pgm_id                 => l_global_pen_rec.pgm_id
           ,p_pl_id                  => l_global_pen_rec.pl_id
           ,p_pl_typ_id              => l_global_pen_rec.pl_typ_id
           ,p_opt_id                 => l_get_opt_id.opt_id --8589355
           ,p_ler_id                 => l_global_pen_rec.ler_id
           ,p_dml_typ                => 'C'
           ,p_jurisdiction_code      => l_jurisdiction_code
           ,p_ext_inpval_tab         => l_ext_inpval_tab
           ,p_subpriority            => l_subpriority
           );

           l_inpval_tab.delete;
           ben_element_entry.get_inpval_tab
           (p_element_entry_id   => l_element_info.element_entry_id
           ,p_effective_date     => l_enrt_rt.rt_strt_dt
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
     else
        l_element_changed := p_ele_changed;
     end if;
  end if;
  --
  -- delete any future dated rates
  --
  handle_overlap_rates
  (p_acty_base_rt_id                => l_enrt_rt.acty_base_rt_id
  ,p_prtt_enrt_rslt_id              => p_prtt_enrt_rslt_id
  ,p_prtt_rt_val_id                 => p_prtt_rt_val_id
  ,p_per_in_ler_id                  => p_per_in_ler_id
  ,p_person_id                      => p_person_id
  ,p_element_type_id                => l_element_info.element_type_id
  ,p_element_entry_value_id         => l_old_element_entry_value_id
  ,p_unrestricted                   => l_unrestricted
  ,p_rt_strt_dt                     => l_enrt_rt.rt_strt_dt
  ,p_business_group_id              => p_business_group_id
  ,p_effective_date                 => p_effective_date);
  --
  -- if a prtt_rt_val_id is found get the old values
  --
  /* 8716870: Code added for Imp Inc Enh starts*/
    hr_utility.set_location('p_imp_cvg_strt_dt '||p_imp_cvg_strt_dt,7007);
    if p_imp_cvg_strt_dt is not null and p_imp_cvg_strt_dt > l_enrt_rt.rt_strt_dt then
       l_enrt_rt.rt_strt_dt := p_imp_cvg_strt_dt;
       -- The rate end date for prev imputed income rate rec is set to the current rt_strt_dt - 1
       l_xrt_end_dt         := p_imp_cvg_strt_dt - 1;
       hr_utility.set_location('setting l_xrt_end_dt '||l_xrt_end_dt,7007);
    end if;
  /* Code added for Imp Inc Enh ends*/

  --
  if p_prtt_rt_val_id is not null then
     --
     if g_debug then
        hr_utility.set_location(l_proc, 85);
     end if;
      --
      -- compare old and new values if changed do update
      --
      --
      -- date compare below will fix bug 3556
      -- whenever the rate start date changes create a new prv
      -- this will force the element entries to be updated.
      --
      --
      -- Always update per_in_ler_id and create a new rate
      -- when per_in_ler_id changes.
      --
      if ((nvl(l_old_rt_typ_cd,hr_api.g_varchar2)<>
                nvl(l_enrt_rt.rt_typ_cd,hr_api.g_varchar2)) or
        (nvl(l_old_tx_typ_cd,hr_api.g_varchar2)<>
                nvl(l_enrt_rt.tx_typ_cd,hr_api.g_varchar2)) or
        (nvl(l_old_acty_typ_cd,hr_api.g_varchar2)<>
                nvl(l_enrt_rt.acty_typ_cd,hr_api.g_varchar2)) or
        (nvl(l_old_mlt_cd,hr_api.g_varchar2)<>
                nvl(l_enrt_rt.rt_mlt_cd,hr_api.g_varchar2)) or
        (nvl(l_old_acty_ref_perd_cd,hr_api.g_varchar2)<>
                nvl(p_acty_ref_perd_cd,hr_api.g_varchar2)) or
        (nvl(l_old_rt_val,hr_api.g_number)<>
                nvl(l_rt_val,hr_api.g_number)) or
        (nvl(l_old_ann_rt_val,hr_api.g_number) <>
                nvl(l_ann_rt_val,hr_api.g_number)) or
        (nvl(l_old_bnft_rt_typ_cd,hr_api.g_varchar2) <>
                nvl(l_enrt_rt.bnft_rt_typ_cd,hr_api.g_varchar2)) or
        (nvl(l_old_cmcd_ref_perd_cd,hr_api.g_varchar2) <>
                nvl(l_enrt_rt.cmcd_acty_ref_perd_cd,hr_api.g_varchar2)) or
        (nvl(l_old_cmcd_rt_val,hr_api.g_number) <>
                nvl(l_enrt_rt.cmcd_val,hr_api.g_number)) or
        (nvl(l_old_dsply_on_enrt_flag,hr_api.g_varchar2) <>
                nvl(l_enrt_rt.dsply_on_enrt_flag,hr_api.g_varchar2)) or
        (nvl(l_old_cvg_amt_calc_mthd_id,hr_api.g_number) <>
                nvl(l_enrt_rt.cvg_amt_calc_mthd_id,hr_api.g_number)) or
        (nvl(l_old_actl_prem_id,hr_api.g_number) <>
                nvl(l_enrt_rt.actl_prem_id,hr_api.g_number)) or
        (nvl(l_old_comp_lvl_fctr_id,hr_api.g_number) <>
                nvl(l_enrt_rt.comp_lvl_fctr_id,hr_api.g_number)) or
        (nvl(l_old_prtt_enrt_rslt_id,hr_api.g_number) <>
                nvl(p_prtt_enrt_rslt_id,hr_api.g_number)) or
        (nvl(l_old_rt_strt_dt,hr_api.g_date) <>
                nvl(l_enrt_rt.rt_strt_dt,hr_api.g_date)) or
        (nvl(l_old_per_in_ler_id,hr_api.g_number) <>
                nvl(p_per_in_ler_id,hr_api.g_number)) or
        l_global_pen_rec.sspndd_flag = 'Y'  or /*4775760 */
        p_bnft_amt_changed=TRUE or
        l_element_changed ) then
        --
        -- handle old rate
       if g_debug then
         hr_utility.set_location(l_proc||'In the TRUE', 1330);
       end if;
        --
       -- if l_unrestricted = 'Y' and -- commented for 4775760,4871284
        if   l_old_rt_strt_dt >= l_enrt_rt.rt_strt_dt then
          --
          -- delete future dated rate
          --
          if not p_calculate_only_mode then
            --
            ben_prtt_rt_val_api.delete_prtt_rt_val
              (p_prtt_rt_val_id                => p_prtt_rt_val_id
              ,p_enrt_rt_id                    => p_enrt_rt_id
              ,p_person_id                     => p_person_id
              ,p_business_group_id             => l_enrt_rt.business_group_id
              ,p_object_version_number         => l_old_object_version_number
              ,p_effective_date                => p_effective_date
              );
            --
          end if;
          --
        else
          --
          -- set the rate end date on the old one
          --
          if g_debug then
             hr_utility.set_location('BEF ben_determine_date.rate_and_coverage_dates',1999);
             hr_utility.set_location('l_enrt_rt.elig_per_elctbl_chc_id'||l_enrt_rt.elig_per_elctbl_chc_id,1999);
             hr_utility.set_location('l_xenrt_cvg_strt_dt'||l_xenrt_cvg_strt_dt,1999);
             hr_utility.set_location('l_xenrt_cvg_strt_dt_cd'||l_xenrt_cvg_strt_dt_cd,1999);
             hr_utility.set_location('l_xenrt_cvg_strt_dt_rl'||l_xenrt_cvg_strt_dt_rl,1999);
             hr_utility.set_location('l_xrt_strt_dt'||l_xrt_strt_dt,1999);
             hr_utility.set_location('l_xrt_strt_dt_cd'||l_xrt_strt_dt_cd,1999);
             hr_utility.set_location('l_xenrt_cvg_end_dt'||l_xenrt_cvg_end_dt,1999);
             hr_utility.set_location('l_xenrt_cvg_end_dt_cd'||l_xenrt_cvg_end_dt_cd,1999);
             hr_utility.set_location('l_xrt_end_dt'||l_xrt_end_dt,1999);
             hr_utility.set_location('l_xrt_end_dt_cd'||l_xrt_end_dt_cd,1999);
             hr_utility.set_location('l_enrt_rt.acty_base_rt_id'||l_enrt_rt.acty_base_rt_id,1999);
            hr_utility.set_location('p_effective_date'||p_effective_date,1999);
          end if;

          ben_determine_date.rate_and_coverage_dates
            (p_which_dates_cd         => 'R'
            ,p_business_group_id      => p_business_group_id
            ,p_elig_per_elctbl_chc_id => l_enrt_rt.elig_per_elctbl_chc_id
            ,p_enrt_cvg_strt_dt       => l_xenrt_cvg_strt_dt
            ,p_enrt_cvg_strt_dt_cd    => l_xenrt_cvg_strt_dt_cd
            ,p_enrt_cvg_strt_dt_rl    => l_xenrt_cvg_strt_dt_rl
            ,p_rt_strt_dt             => l_xrt_strt_dt
            ,p_rt_strt_dt_cd          => l_xrt_strt_dt_cd
            ,p_rt_strt_dt_rl          => l_xrt_strt_dt_rl
            ,p_enrt_cvg_end_dt        => l_xenrt_cvg_end_dt
            ,p_enrt_cvg_end_dt_cd     => l_xenrt_cvg_end_dt_cd
            ,p_enrt_cvg_end_dt_rl     => l_xenrt_cvg_end_dt_rl
            ,p_rt_end_dt              => l_xrt_end_dt
            ,p_rt_end_dt_cd           => l_xrt_end_dt_cd
            ,p_rt_end_dt_rl           => l_xrt_end_dt_rl
            ,p_acty_base_rt_id        => l_enrt_rt.acty_base_rt_id
            ,p_effective_date         => p_effective_date
	    ,p_lf_evt_ocrd_dt         => l_lf_evt_ocrd_dt); -- bug 5717428
          --

	  /* 8716870: Code added for Imp Inc Enh begins*/
          if p_imp_cvg_strt_dt is not null and p_imp_cvg_strt_dt >= l_enrt_rt.rt_strt_dt then
          -- the rate_end_dt for prev imputed income rate rec is set to the current rt_strt_dt - 1
          l_xrt_end_dt         := p_imp_cvg_strt_dt - 1;
          hr_utility.set_location('setting l_xrt_end_dt '||l_xrt_end_dt,16);
          end if;
          /* 8716870: Code added for Imp Inc Enh ends*/

          -- If the rate end date code is '1 Prior or Enterable' (WAENT),
          -- then the rate end date is 1 Less than the rate start date.
          --
          if l_xrt_end_dt_cd = 'WAENT' and
             p_rt_strt_dt is not null then
             l_xrt_end_dt := p_rt_strt_dt -1;
          elsif l_xrt_end_dt_cd = 'WAENT' and p_rt_strt_dt is null then
             l_xrt_end_dt := l_xrt_strt_dt -1;
          end if;
          --
          -- If the rate end date code is '1 prior or Later of Event ..etc or
          -- codes start with W or LW need to be ended 1 day before rate start date
          -- bug#2055961
          if  (substr(nvl(l_xrt_end_dt_cd, 'X'), 1, 1) = 'W' or
                substr(nvl(l_xrt_end_dt_cd, 'X'), 1, 2) = 'LW' or
                l_xrt_end_dt_cd in ('LDPPFEFD','LDPPOEFD')) and
                not (l_xrt_end_dt_cd = 'WAENT') then
              l_xrt_end_dt := l_xrt_strt_dt -1;
          end if;

          if g_debug then
            hr_utility.set_location('p rate strt date'||p_rt_strt_dt,111);
          end if;
          if p_rt_strt_dt > l_old_rt_end_dt then
             l_xrt_end_dt := l_old_rt_end_dt;
          end if;

          --
          if g_debug then
             hr_utility.set_location('After call to ben_determine_date.rate_and_coverage_dates',1999);
             hr_utility.set_location('l_enrt_rt.elig_per_elctbl_chc_id'||l_enrt_rt.elig_per_elctbl_chc_id,1999);
             hr_utility.set_location('l_xenrt_cvg_strt_dt'||l_xenrt_cvg_strt_dt,1999);
             hr_utility.set_location('l_xenrt_cvg_strt_dt_cd'||l_xenrt_cvg_strt_dt_cd,1999);
             hr_utility.set_location('l_xenrt_cvg_strt_dt_rl'||l_xenrt_cvg_strt_dt_rl,1999);
             hr_utility.set_location('l_xrt_strt_dt'||l_xrt_strt_dt,1999);
             hr_utility.set_location('l_xrt_strt_dt_cd'||l_xrt_strt_dt_cd,1999);
             hr_utility.set_location('l_xenrt_cvg_end_dt'||l_xenrt_cvg_end_dt,1999);
             hr_utility.set_location('l_xenrt_cvg_end_dt_cd'||l_xenrt_cvg_end_dt_cd,1999);
             hr_utility.set_location('l_xrt_end_dt'||l_xrt_end_dt,1999);
             hr_utility.set_location('l_xrt_end_dt_cd'||l_xrt_end_dt_cd,1999);
             hr_utility.set_location('l_enrt_rt.acty_base_rt_id'||l_enrt_rt.acty_base_rt_id,1999);
             hr_utility.set_location('p_effective_date'||p_effective_date,1999);
          end if;
        --
        -- bnft amt changed and entr val flag is N then election rate
        -- information is called after delete enrollment
        --
        if l_old_rt_end_dt < l_xrt_end_dt then
          --
          if not p_calculate_only_mode then
            --
            --Bug 2976103 Non Recurring rates are getting opened when called
            --from benraten. This needs to happed only for recurring rates.
            --
            if not l_non_recurring_rt then
              --
              ben_prtt_rt_val_api.update_prtt_rt_val
              (p_prtt_rt_val_id                 => p_prtt_rt_val_id
              ,p_rt_end_dt                      => hr_api.g_eot
              ,p_acty_base_rt_id                => l_enrt_rt.acty_base_rt_id
              ,p_input_value_id                 => l_enrt_rt.input_value_id
              ,p_element_type_id                => l_enrt_rt.element_type_id
              ,p_person_id                      => p_person_id
              ,p_ended_per_in_ler_id            => null
              ,p_business_group_id              => l_enrt_rt.business_group_id
              ,p_object_version_number          => l_old_object_version_number
              ,p_effective_date                 => p_effective_date
              );
              --
            end if;
            --
          end if;
          --
        end if;

        l_no_end_element := (not l_element_changed) and
                            (l_old_rt_val=l_rt_val);

        if p_bnft_amt_changed and l_enrt_rt.entr_val_At_enrt_flag = 'Y' then

          if g_debug then
            hr_utility.set_location('p_bnft_amt_changed',1999);
          end if;
          if not p_calculate_only_mode then
            --
             --
            ben_prtt_rt_val_api.update_prtt_rt_val
              (p_prtt_rt_val_id                => p_prtt_rt_val_id
              ,p_rt_end_dt                     => l_xrt_end_dt
              ,p_ended_per_in_ler_id           => p_per_in_ler_id
              ,p_acty_base_rt_id               => l_enrt_rt.acty_base_rt_id
              ,p_input_value_id                => l_enrt_rt.input_value_id
              ,p_element_type_id               => l_enrt_rt.element_type_id
              ,p_person_id                     => p_person_id
              ,p_business_group_id             => l_enrt_rt.business_group_id
              ,p_object_version_number         => l_old_object_version_number
              ,p_effective_date                => p_effective_date
              ,p_no_end_element                => l_no_end_element
              );
            --
          end if;
          --
        elsif p_bnft_amt_changed = FALSE then
          --
          -- p_amt_changed is false
          --
          if g_debug then
            hr_utility.set_location('bnft amount false',1999);
          end if;
          if not p_calculate_only_mode then
            --
            if  not l_non_recurring_rt then
              if l_old_rt_end_dt <> l_xrt_end_dt then
                if g_debug then
                  hr_utility.set_location('processing type recurring ',1999);
                end if;
                --

                ben_prtt_rt_val_api.update_prtt_rt_val
                  (p_prtt_rt_val_id                => p_prtt_rt_val_id
                  ,p_rt_end_dt                     => l_xrt_end_dt
                  ,p_ended_per_in_ler_id           => p_per_in_ler_id
                  ,p_acty_base_rt_id               => l_enrt_rt.acty_base_rt_id
                  ,p_input_value_id                => l_enrt_rt.input_value_id
                  ,p_element_type_id               => l_enrt_rt.element_type_id
                  ,p_person_id                     => p_person_id
                  ,p_business_group_id             => l_enrt_rt.business_group_id
                  ,p_object_version_number         => l_old_object_version_number
                  ,p_effective_date                => p_effective_date
                  ,p_no_end_element                => l_no_end_element
                  );
               end if;
            --
            end if;
            --
          end if;

         end if;
        end if;
        --
        -- update rate
        --
        if g_debug then
          hr_utility.set_location(l_proc, 130);
        end if;
        --
        if not p_calculate_only_mode then
          --
          -- Bug 2677804 if the rate has override thru date in the previous
          -- prv and the thru date is on or after the l_enrt_rt.rt_strt_dt
          -- we need to carry forward the information for going forward
          --        l_old_rt_ovridn_flag            varchar2(30);
          --        l_old_rt_ovridn_thru_dt         date;
          if l_old_rt_ovridn_flag = 'Y' and
             nvl(l_old_rt_ovridn_thru_dt, l_enrt_rt.rt_strt_dt+1 ) < l_enrt_rt.rt_strt_dt  then -- bug 5942441
            --
            l_old_rt_ovridn_flag := 'N' ;
            l_old_rt_ovridn_thru_dt := null ;
            --
          end if ;

 -- 7206471 Check if the rates should be adjusted.
  --
  --
  --  Check if there is a life event in the same month.
  --
  /* Bug 8945818 */
  open c_prev_per_in_ler;
  fetch c_prev_per_in_ler into l_prev_pil_id;
  close c_prev_per_in_ler;
  /* End of Bug 8945818 */
  hr_utility.set_location('l_prev_pil_id '||l_prev_pil_id,1119);
  hr_utility.set_location('pen_id '||p_prtt_enrt_rslt_id,1119);
  hr_utility.set_location('l_enrt_rt.rt_strt_dt '||l_enrt_rt.rt_strt_dt,1119);
  open c_get_prior_per_in_ler(l_enrt_rt.rt_strt_dt);
  fetch c_get_prior_per_in_ler into l_exists;
  if c_get_prior_per_in_ler%found then
    --
      --
      open c_get_pgm_extra_info;
      fetch c_get_pgm_extra_info into l_adjust;
      if c_get_pgm_extra_info%found then
        --
        if l_adjust = 'Y' then
          --
          --  Get rt end dt
          --
          hr_utility.set_location('p_enrt_rt_id '||p_enrt_rt_id,1119);
          --for l_epe in c_get_elctbl_chc loop ---- Bug 8507247
            --
            --  Get all results that were de-enrolled for the event.
            --
	    /* Added for Bug 8507247*/
	    open c_get_ptip_id;
	    fetch c_get_ptip_id into l_ptip_id;
	    close c_get_ptip_id;
	    hr_utility.set_location('Before Adjusting ',111);
	    /* End of Bug 8507247*/
            for l_pen in c_get_enrt_rslts(l_enrt_rt.rt_strt_dt
                                       ,l_ptip_id) loop
              hr_utility.set_location('Adjusting rate '||l_enrt_rt.rt_strt_dt,111);
	      open c_prtt_rt_val_adj(p_per_in_ler_id,l_pen.prtt_rt_val_id);
              fetch c_prtt_rt_val_adj into l_exists;
              if c_prtt_rt_val_adj%notfound then
                insert into BEN_LE_CLSN_N_RSTR (
                        BKUP_TBL_TYP_CD,
                        BKUP_TBL_ID,
                        per_in_ler_id,
                        person_id,
                        RT_END_DT,
                        business_group_id,
                        object_version_number)
                      values (
                        'BEN_PRTT_RT_VAL_ADJ',
                        l_pen.prtt_rt_val_id,
                        p_per_in_ler_id,
                        l_pen.person_id,
                        l_pen.rt_end_dt,
                        p_business_group_id,
                        l_pen.object_version_number
                      );
              end if;
              close c_prtt_rt_val_adj;
               --
              ben_prtt_rt_val_api.update_prtt_rt_val
               (P_VALIDATE                => FALSE
               ,P_PRTT_RT_VAL_ID          => l_pen.prtt_rt_val_id
               ,P_RT_END_DT               => l_enrt_rt.rt_strt_dt - 1 --Bug 8507247
               ,p_person_id               => l_pen.person_id
               ,p_input_value_id          => l_pen.input_value_id
               ,p_element_type_id         => l_pen.element_type_id
               ,p_business_group_id       => p_business_group_id
               ,P_OBJECT_VERSION_NUMBER   => l_pen.object_version_number
               ,P_EFFECTIVE_DATE          => p_effective_date
               );
            end loop;  -- c_get_enrt_rslts
          --end loop; -- c_get_elctbl_chc -- Bug 8507247
        end if;  -- l_adjust = 'Y'
      end if;  -- c_get_pgm_extra_info
      close c_get_pgm_extra_info;
    end if;
    close c_get_prior_per_in_ler;
    -- end 7206471

          ben_prtt_rt_val_api.create_prtt_rt_val
            (p_prtt_rt_val_id                 => p_prtt_rt_val_id
            ,p_enrt_rt_id                     => p_enrt_rt_id
            ,p_per_in_ler_id                  => p_per_in_ler_id
            ,p_rt_typ_cd                      => l_enrt_rt.rt_typ_cd
            ,p_tx_typ_cd                      => l_enrt_rt.tx_typ_cd
            ,p_acty_typ_cd                    => l_enrt_rt.acty_typ_cd
            ,p_mlt_cd                         => l_enrt_rt.rt_mlt_cd
            ,p_acty_ref_perd_cd               => p_acty_ref_perd_cd
            ,p_rt_val                         => l_rt_val
            ,p_rt_strt_dt                     => l_enrt_rt.rt_strt_dt
            ,p_rt_end_dt                      => hr_api.g_eot
            ,p_ann_rt_val                     => l_ann_rt_val
            ,p_bnft_rt_typ_cd                 => l_enrt_rt.bnft_rt_typ_cd
            ,p_cmcd_ref_perd_cd               => l_enrt_rt.cmcd_acty_ref_perd_cd
            ,p_cmcd_rt_val                    => l_enrt_rt.cmcd_val
            ,p_dsply_on_enrt_flag             => l_enrt_rt.dsply_on_enrt_flag
            ,p_elctns_made_dt                 => p_effective_date
            ,p_cvg_amt_calc_mthd_id           => l_enrt_rt.cvg_amt_calc_mthd_id
            ,p_actl_prem_id                   => l_enrt_rt.actl_prem_id
            ,p_comp_lvl_fctr_id               => l_enrt_rt.comp_lvl_fctr_id
            ,p_prtt_enrt_rslt_id              => p_prtt_enrt_rslt_id
            ,p_business_group_id              => l_enrt_rt.business_group_id
            ,p_object_version_number          => l_old_object_version_number
            ,p_effective_date                 => p_effective_date
            ,p_acty_base_rt_id                => l_enrt_rt.acty_base_rt_id
            ,p_input_value_id                 => l_enrt_rt.input_value_id
            ,p_element_type_id                => l_enrt_rt.element_type_id
            ,p_person_id                      => p_person_id
            ,p_pp_in_yr_used_num              => l_enrt_rt.pp_in_yr_used_num
            ,p_ordr_num                       => l_enrt_rt.ordr_num
            -- Bug 2677804
            ,p_rt_ovridn_flag                 => l_old_rt_ovridn_flag
            ,p_rt_ovridn_thru_dt              => l_old_rt_ovridn_thru_dt
            --
            );
          if g_debug then
            hr_utility.set_location(l_proc, 135);
          end if;
        end if;
        --
      else
        --
        -- Check for old rate being reused, set end dt to eot.
        -- Re-use the rate only if the rate is continuous (maagrawa 2/24/00)
        --
        if l_old_rt_end_dt is not null and
           l_old_rt_end_dt <> hr_api.g_eot and
           l_enrt_rt.rt_strt_dt <= l_old_rt_end_dt then
          --
          if not p_calculate_only_mode then
            --
            --Bug 2976103 Non Recurring rates are getting opened when called
            --from benraten. This needs to happed only for recurring rates.
            --
            if not l_non_recurring_rt then
              --
              ben_prtt_rt_val_api.update_prtt_rt_val
              (p_prtt_rt_val_id                 => p_prtt_rt_val_id
              ,p_rt_end_dt                      => hr_api.g_eot
              ,p_acty_base_rt_id                => l_enrt_rt.acty_base_rt_id
              ,p_input_value_id                 => l_enrt_rt.input_value_id
              ,p_element_type_id                => l_enrt_rt.element_type_id
              ,p_person_id                      => p_person_id
              ,p_ended_per_in_ler_id            => null
              ,p_business_group_id              => l_enrt_rt.business_group_id
              ,p_object_version_number          => l_old_object_version_number
              ,p_effective_date                 => p_effective_date
              );
              --
            end if;
            --
          end if;
          --
        end if;

        if g_debug then
           hr_utility.set_location(l_proc||'Do nothing if old prv is fine ', 1330);
        end if;

      end if;

    else
      if g_debug then
        hr_utility.set_location(l_proc, 140);
      end if;
      --
      if not p_calculate_only_mode then
        --
        -- Bug 2677804 if the rate has override thru date in the previous
        -- prv and the thru date is on or after the l_enrt_rt.rt_strt_dt
        -- we need to carry forward the information for going forward
        --        l_old_rt_ovridn_flag            varchar2(30);
        --        l_old_rt_ovridn_thru_dt         date;
        if l_old_rt_ovridn_flag = 'Y' and
            nvl(l_old_rt_ovridn_thru_dt, l_enrt_rt.rt_strt_dt+1 ) < l_enrt_rt.rt_strt_dt then -- bug 5942441
          --
          l_old_rt_ovridn_flag := 'N' ;
          l_old_rt_ovridn_thru_dt := null ;
          --
        end if ;
	-- 7206471 Check if the rates should be adjusted.
  --
  --
  --  Check if there is a life event in the same month.
  --
  /* Bug 8945818 */
  open c_prev_per_in_ler;
  fetch c_prev_per_in_ler into l_prev_pil_id;
  close c_prev_per_in_ler;
  /* End of Bug 8945818 */
  hr_utility.set_location('l_prev_pil_id '||l_prev_pil_id,1119);
  hr_utility.set_location('pen_id '||p_prtt_enrt_rslt_id,1119);
  hr_utility.set_location('l_enrt_rt.rt_strt_dt '||l_enrt_rt.rt_strt_dt,1119);
  open c_get_prior_per_in_ler(l_enrt_rt.rt_strt_dt);
  fetch c_get_prior_per_in_ler into l_exists;
  if c_get_prior_per_in_ler%found then
    --
      --
      open c_get_pgm_extra_info;
      fetch c_get_pgm_extra_info into l_adjust;
      if c_get_pgm_extra_info%found then
        --
        if l_adjust = 'Y' then
          --
          --  Get rt end dt
          --
          hr_utility.set_location('p_enrt_rt_id '||p_enrt_rt_id,1119);
          --for l_epe in c_get_elctbl_chc loop -- Bug 8507247
            --
            --  Get all results that were de-enrolled for the event.
            --
	    /* Added for Bug 8507247*/
	    open c_get_ptip_id;
	    fetch c_get_ptip_id into l_ptip_id;
	    close c_get_ptip_id;
	    hr_utility.set_location('Before Adjusting rates ',1119);
	    /* End of Bug 8507247*/
            for l_pen in c_get_enrt_rslts(l_enrt_rt.rt_strt_dt
                                       ,l_ptip_id) loop
              hr_utility.set_location('Adjusting rate '||l_enrt_rt.rt_strt_dt,111);
              open c_prtt_rt_val_adj(p_per_in_ler_id,l_pen.prtt_rt_val_id);
              fetch c_prtt_rt_val_adj into l_exists;
              if c_prtt_rt_val_adj%notfound then
                insert into BEN_LE_CLSN_N_RSTR (
                        BKUP_TBL_TYP_CD,
                        BKUP_TBL_ID,
                        per_in_ler_id,
                        person_id,
                        RT_END_DT,
                        business_group_id,
                        object_version_number)
                      values (
                        'BEN_PRTT_RT_VAL_ADJ',
                        l_pen.prtt_rt_val_id,
                        p_per_in_ler_id,
                        l_pen.person_id,
                        l_pen.rt_end_dt,
                        p_business_group_id,
                        l_pen.object_version_number
                      );
              end if;
              close c_prtt_rt_val_adj;
               --
              ben_prtt_rt_val_api.update_prtt_rt_val
               (P_VALIDATE                => FALSE
               ,P_PRTT_RT_VAL_ID          => l_pen.prtt_rt_val_id
               ,P_RT_END_DT               => l_enrt_rt.rt_strt_dt - 1 --Bug 8507247
               ,p_person_id               => l_pen.person_id
               ,p_input_value_id          => l_pen.input_value_id
               ,p_element_type_id         => l_pen.element_type_id
               ,p_business_group_id       => p_business_group_id
               ,P_OBJECT_VERSION_NUMBER   => l_pen.object_version_number
               ,P_EFFECTIVE_DATE          => p_effective_date
               );
            end loop;  -- c_get_enrt_rslts
          --end loop; -- c_get_elctbl_chc --Bug 8507247
        end if;  -- l_adjust = 'Y'
      end if;  -- c_get_pgm_extra_info
      close c_get_pgm_extra_info;
    end if;
    close c_get_prior_per_in_ler;
    -- end 7206471
        -- if no prtt_rt_val_id passed do insert
        ben_prtt_rt_val_api.create_prtt_rt_val
          (p_prtt_rt_val_id                 => p_prtt_rt_val_id
          ,p_enrt_rt_id                     => p_enrt_rt_id
          ,p_per_in_ler_id                  => p_per_in_ler_id
          ,p_rt_typ_cd                      => l_enrt_rt.rt_typ_cd
          ,p_tx_typ_cd                      => l_enrt_rt.tx_typ_cd
          ,p_acty_typ_cd                    => l_enrt_rt.acty_typ_cd
          ,p_mlt_cd                         => l_enrt_rt.rt_mlt_cd
          ,p_acty_ref_perd_cd               => p_acty_ref_perd_cd
          ,p_rt_val                         => l_rt_val
          ,p_rt_strt_dt                     => l_enrt_rt.rt_strt_dt
          ,p_rt_end_dt                      => hr_api.g_eot
          ,p_ann_rt_val                     => l_ann_rt_val
          ,p_bnft_rt_typ_cd                 => l_enrt_rt.bnft_rt_typ_cd
          ,p_cmcd_ref_perd_cd               => l_enrt_rt.cmcd_acty_ref_perd_cd
          ,p_cmcd_rt_val                    => l_enrt_rt.cmcd_val
          ,p_dsply_on_enrt_flag             => l_enrt_rt.dsply_on_enrt_flag
          ,p_elctns_made_dt                 => p_effective_date
          ,p_cvg_amt_calc_mthd_id           => l_enrt_rt.cvg_amt_calc_mthd_id
          ,p_actl_prem_id                   => l_enrt_rt.actl_prem_id
          ,p_comp_lvl_fctr_id               => l_enrt_rt.comp_lvl_fctr_id
          ,p_prtt_enrt_rslt_id              => p_prtt_enrt_rslt_id
          ,p_business_group_id              => l_enrt_rt.business_group_id
          ,p_object_version_number          => l_old_object_version_number
          ,p_effective_date                 => p_effective_date
          ,p_acty_base_rt_id                => l_enrt_rt.acty_base_rt_id
          ,p_input_value_id                 => l_enrt_rt.input_value_id
          ,p_element_type_id                => l_enrt_rt.element_type_id
          ,p_person_id                      => p_person_id
          ,p_pp_in_yr_used_num              => l_enrt_rt.pp_in_yr_used_num
          ,p_ordr_num               => l_enrt_rt.ordr_num
          -- Bug 2677804
          ,p_rt_ovridn_flag                 => l_old_rt_ovridn_flag
          ,p_rt_ovridn_thru_dt              => l_old_rt_ovridn_thru_dt
          --
          );
        if g_debug then
          hr_utility.set_location(l_proc, 145);
        end if;
      end if;
    end if;
    --
    -- Check of the rate end date is passed in as parameter.
    -- If Yes, then check for the rate end date code.
    -- If it is WAENT, then the rate has to be ended with the
    -- parameter end date.
    --
    if not p_calculate_only_mode and
       l_rt_end_dt is not null and
       l_rt_end_dt <> hr_api.g_eot then
      --
      if l_xrt_end_dt_cd is null then
        ben_determine_date.rate_and_coverage_dates
          (p_which_dates_cd         => 'R'
          ,p_compute_dates_flag     => 'N'
          ,p_business_group_id      => p_business_group_id
          ,p_elig_per_elctbl_chc_id => l_enrt_rt.elig_per_elctbl_chc_id
          ,p_enrt_cvg_strt_dt       => l_xenrt_cvg_strt_dt
          ,p_enrt_cvg_strt_dt_cd    => l_xenrt_cvg_strt_dt_cd
          ,p_enrt_cvg_strt_dt_rl    => l_xenrt_cvg_strt_dt_rl
          ,p_rt_strt_dt             => l_xrt_strt_dt
          ,p_rt_strt_dt_cd          => l_xrt_strt_dt_cd
          ,p_rt_strt_dt_rl          => l_xrt_strt_dt_rl
          ,p_enrt_cvg_end_dt        => l_xenrt_cvg_end_dt
          ,p_enrt_cvg_end_dt_cd     => l_xenrt_cvg_end_dt_cd
          ,p_enrt_cvg_end_dt_rl     => l_xenrt_cvg_end_dt_rl
          ,p_rt_end_dt              => l_xrt_end_dt
          ,p_rt_end_dt_cd           => l_xrt_end_dt_cd
          ,p_rt_end_dt_rl           => l_xrt_end_dt_rl
          ,p_acty_base_rt_id        => l_enrt_rt.acty_base_rt_id
          ,p_effective_date         => p_effective_date);
      end if;
      --
      if l_xrt_end_dt_cd = 'WAENT' then
        ben_prtt_rt_val_api.update_prtt_rt_val
          (p_prtt_rt_val_id                => p_prtt_rt_val_id
          ,p_rt_end_dt                     => l_rt_end_dt
          ,p_ended_per_in_ler_id           => p_per_in_ler_id
          ,p_acty_base_rt_id               => l_enrt_rt.acty_base_rt_id
          ,p_input_value_id                => l_enrt_rt.input_value_id
          ,p_element_type_id               => l_enrt_rt.element_type_id
          ,p_person_id                     => p_person_id
          ,p_business_group_id             => l_enrt_rt.business_group_id
          ,p_object_version_number         => l_old_object_version_number
          ,p_effective_date                => p_effective_date);
      end if;
      --
    end if;

    if l_enrt_rt.decr_bnft_prvdr_pool_id is not null
       and l_global_pen_rec.sspndd_flag = 'N' then
      --
      if not p_calculate_only_mode then
        --
        ben_provider_pools.create_debit_ledger_entry
          (p_person_id               => p_person_id
          ,p_per_in_ler_id           => p_per_in_ler_id
          ,p_elig_per_elctbl_chc_id  => l_enrt_rt.elig_per_elctbl_chc_id
          ,p_prtt_enrt_rslt_id       => p_prtt_enrt_rslt_id
          ,p_decr_bnft_prvdr_pool_id => l_enrt_rt.decr_bnft_prvdr_pool_id
          ,p_acty_base_rt_id         => l_enrt_rt.acty_base_rt_id
          ,p_prtt_rt_val_id          => p_prtt_rt_val_id
          ,p_enrt_mthd_cd            => p_enrt_mthd_cd
          ,p_val                     => l_rt_val
          ,p_bnft_prvdd_ldgr_id      => l_bnft_prvdd_ldgr_id
          ,p_business_group_id       => p_business_group_id
          ,p_effective_date          => p_effective_date
          --
          ,p_bpl_used_val            => l_dummy_number
          );
        --
      end if;
      --
    end if;
    --
    if g_debug then
      hr_utility.set_location('Leaving:'||l_proc, 99);
    end if;

  ben_manage_life_events.fonm := null;
  ben_manage_life_events.g_fonm_cvg_strt_dt := null;
  ben_manage_life_events.g_fonm_rt_strt_dt := null;
  --
  -- Set OUT parameters
  --
  p_prv_rt_val     := l_rt_val;
  p_prv_ann_rt_val := l_ann_rt_val;
  --
end election_rate_information;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< election_information >-------------------------|
-- ----------------------------------------------------------------------------
-- OVERLOADED, SEE BELOW.
-- Do not add new flags to this procedure unless forms need to pass them.
--
procedure election_information
  (p_validate               in boolean default FALSE
  ,p_elig_per_elctbl_chc_id in number
  ,p_prtt_enrt_rslt_id      in out nocopy number
  ,p_effective_date         in date
  ,p_enrt_mthd_cd           in varchar2
  ,p_enrt_bnft_id           in number
  ,p_bnft_val               in number default null
  ,p_enrt_cvg_strt_dt       in  date  default null
  ,p_enrt_cvg_thru_dt       in  date  default null
  ,p_enrt_rt_id1            in number default null
  ,p_prtt_rt_val_id1        in out nocopy number
  ,p_rt_val1                in number default null
  ,p_ann_rt_val1            in number default null
  ,p_rt_strt_dt1            in date   default null
  ,p_rt_end_dt1             in date   default null
  ,p_enrt_rt_id2            in number default null
  ,p_prtt_rt_val_id2        in out nocopy number
  ,p_rt_val2                in number default null
  ,p_ann_rt_val2            in number default null
  ,p_rt_strt_dt2            in date   default null
  ,p_rt_end_dt2             in date   default null
  ,p_enrt_rt_id3            in number default null
  ,p_prtt_rt_val_id3        in out nocopy number
  ,p_rt_val3                in number default null
  ,p_ann_rt_val3            in number default null
  ,p_rt_strt_dt3            in date   default null
  ,p_rt_end_dt3             in date   default null
  ,p_enrt_rt_id4            in number default null
  ,p_prtt_rt_val_id4        in out nocopy number
  ,p_rt_val4                in number default null
  ,p_ann_rt_val4            in number default null
  ,p_rt_strt_dt4            in date   default null
  ,p_rt_end_dt4             in date   default null
  ,p_enrt_rt_id5            in number default null
  ,p_prtt_rt_val_id5        in out nocopy number
  ,p_rt_val5                in number default null
  ,p_ann_rt_val5            in number default null
  ,p_rt_strt_dt5            in date   default null
  ,p_rt_end_dt5             in date   default null
  ,p_enrt_rt_id6            in number default null
  ,p_prtt_rt_val_id6        in out nocopy number
  ,p_rt_val6                in number default null
  ,p_ann_rt_val6            in number default null
  ,p_rt_strt_dt6            in date   default null
  ,p_rt_end_dt6             in date   default null
  ,p_enrt_rt_id7            in number default null
  ,p_prtt_rt_val_id7        in out nocopy number
  ,p_rt_val7                in number default null
  ,p_ann_rt_val7            in number default null
  ,p_rt_strt_dt7            in date   default null
  ,p_rt_end_dt7             in date   default null
  ,p_enrt_rt_id8            in number default null
  ,p_prtt_rt_val_id8        in out nocopy number
  ,p_rt_val8                in number default null
  ,p_ann_rt_val8            in number default null
  ,p_rt_strt_dt8            in date   default null
  ,p_rt_end_dt8             in date   default null
  ,p_enrt_rt_id9            in number default null
  ,p_prtt_rt_val_id9        in out nocopy number
  ,p_rt_val9                in number default null
  ,p_ann_rt_val9            in number default null
  ,p_rt_strt_dt9            in date   default null
  ,p_rt_end_dt9             in date   default null
  ,p_enrt_rt_id10           in number default null
  ,p_prtt_rt_val_id10       in out nocopy number
  ,p_rt_val10               in number default null
  ,p_ann_rt_val10           in number default null
  ,p_rt_strt_dt10           in date   default null
  ,p_rt_end_dt10            in date   default null
  ,p_datetrack_mode         in varchar2
  ,p_suspend_flag           in out nocopy varchar2
  ,p_effective_start_date   out nocopy date
  ,p_effective_end_date     out nocopy date
  ,p_object_version_number  in out nocopy number
  ,p_prtt_enrt_interim_id   out nocopy number
  ,p_business_group_id      in  number
  ,p_pen_attribute_category in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute1         in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute2         in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute3         in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute4         in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute5         in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute6         in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute7         in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute8         in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute9         in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute10        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute11        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute12        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute13        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute14        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute15        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute16        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute17        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute18        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute19        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute20        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute21        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute22        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute23        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute24        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute25        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute26        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute27        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute28        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute29        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute30        in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_actn_warning      out nocopy boolean
  ,p_bnf_actn_warning       out nocopy boolean
  ,p_ctfn_actn_warning      out nocopy boolean)
is
BEGIN
  --
  -- Created this procedure so we could add flags to the proc that the
  -- forms do not need to pass.  They will call this original spec'ed
  -- proc.  The batch processes can call the other one if new flags are needed.
  --

  g_debug := hr_utility.debug_enabled;
--hr_utility. set_location( ' p_rt_val1 '||p_rt_val1 , 211);
--hr_utility. set_location( ' p_ann_rt_val1 '||p_ann_rt_val1,211);
  -- please mark new flags with a comment.
 election_information
  (p_validate               => p_validate
  ,p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id
  ,p_prtt_enrt_rslt_id      => p_prtt_enrt_rslt_id
  ,p_effective_date         => p_effective_date
  ,p_enrt_mthd_cd           => p_enrt_mthd_cd
  ,p_enrt_bnft_id           => p_enrt_bnft_id
  ,p_bnft_val               => p_bnft_val
  ,p_enrt_cvg_strt_dt       => p_enrt_cvg_strt_dt -- bug 1840961
  ,p_enrt_cvg_thru_dt       => p_enrt_cvg_thru_dt -- bug 1840961
  ,p_enrt_rt_id1            => p_enrt_rt_id1
  ,p_prtt_rt_val_id1        => p_prtt_rt_val_id1
  ,p_rt_val1                => p_rt_val1
  ,p_ann_rt_val1            => p_ann_rt_val1
  ,p_rt_strt_dt1            => p_rt_strt_dt1
  ,p_rt_end_dt1             => p_rt_end_dt1
  ,p_enrt_rt_id2            => p_enrt_rt_id2
  ,p_prtt_rt_val_id2        => p_prtt_rt_val_id2
  ,p_rt_val2                => p_rt_val2
  ,p_ann_rt_val2            => p_ann_rt_val2
  ,p_rt_strt_dt2            => p_rt_strt_dt2
  ,p_rt_end_dt2             => p_rt_end_dt2
  ,p_enrt_rt_id3            => p_enrt_rt_id3
  ,p_prtt_rt_val_id3        => p_prtt_rt_val_id3
  ,p_rt_val3                => p_rt_val3
  ,p_ann_rt_val3            => p_ann_rt_val3
  ,p_rt_strt_dt3            => p_rt_strt_dt3
  ,p_rt_end_dt3             => p_rt_end_dt3
  ,p_enrt_rt_id4            => p_enrt_rt_id4
  ,p_prtt_rt_val_id4        => p_prtt_rt_val_id4
  ,p_rt_val4                => p_rt_val4
  ,p_ann_rt_val4            => p_ann_rt_val4
  ,p_rt_strt_dt4            => p_rt_strt_dt4
  ,p_rt_end_dt4             => p_rt_end_dt4
  ,p_enrt_rt_id5            => p_enrt_rt_id5
  ,p_prtt_rt_val_id5        => p_prtt_rt_val_id5
  ,p_rt_val5                => p_rt_val5
  ,p_ann_rt_val5            => p_ann_rt_val5
  ,p_rt_strt_dt5            => p_rt_strt_dt5
  ,p_rt_end_dt5             => p_rt_end_dt5
  ,p_enrt_rt_id6            => p_enrt_rt_id6
  ,p_prtt_rt_val_id6        => p_prtt_rt_val_id6
  ,p_rt_val6                => p_rt_val6
  ,p_ann_rt_val6            => p_ann_rt_val6
  ,p_rt_strt_dt6            => p_rt_strt_dt6
  ,p_rt_end_dt6             => p_rt_end_dt6
  ,p_enrt_rt_id7            => p_enrt_rt_id7
  ,p_prtt_rt_val_id7        => p_prtt_rt_val_id7
  ,p_rt_val7                => p_rt_val7
  ,p_ann_rt_val7            => p_ann_rt_val7
  ,p_rt_strt_dt7            => p_rt_strt_dt7
  ,p_rt_end_dt7             => p_rt_end_dt7
  ,p_enrt_rt_id8            => p_enrt_rt_id8
  ,p_prtt_rt_val_id8        => p_prtt_rt_val_id8
  ,p_rt_val8                => p_rt_val8
  ,p_ann_rt_val8            => p_ann_rt_val8
  ,p_rt_strt_dt8            => p_rt_strt_dt8
  ,p_rt_end_dt8             => p_rt_end_dt8
  ,p_enrt_rt_id9            => p_enrt_rt_id9
  ,p_prtt_rt_val_id9        => p_prtt_rt_val_id9
  ,p_rt_val9                => p_rt_val9
  ,p_ann_rt_val9            => p_ann_rt_val9
  ,p_rt_strt_dt9            => p_rt_strt_dt9
  ,p_rt_end_dt9             => p_rt_end_dt9
  ,p_enrt_rt_id10           => p_enrt_rt_id10
  ,p_prtt_rt_val_id10       => p_prtt_rt_val_id10
  ,p_rt_val10               => p_rt_val10
  ,p_ann_rt_val10           => p_ann_rt_val10
  ,p_rt_strt_dt10           => p_rt_strt_dt10
  ,p_rt_end_dt10            => p_rt_end_dt10
  ,p_datetrack_mode         => p_datetrack_mode
  ,p_suspend_flag           => p_suspend_flag
  ,p_called_from_sspnd      => 'N'               -- flag not in this spec
  ,p_effective_start_date   => p_effective_start_date
  ,p_effective_end_date     => p_effective_end_date
  ,p_object_version_number  => p_object_version_number
  ,p_prtt_enrt_interim_id   => p_prtt_enrt_interim_id
  ,p_business_group_id      =>  p_business_group_id
  ,p_pen_attribute_category =>  p_pen_attribute_category
  ,p_pen_attribute1         =>  p_pen_attribute1
  ,p_pen_attribute2         =>  p_pen_attribute2
  ,p_pen_attribute3         =>  p_pen_attribute3
  ,p_pen_attribute4         =>  p_pen_attribute4
  ,p_pen_attribute5         =>  p_pen_attribute5
  ,p_pen_attribute6         =>  p_pen_attribute6
  ,p_pen_attribute7         =>  p_pen_attribute7
  ,p_pen_attribute8         =>  p_pen_attribute8
  ,p_pen_attribute9         =>  p_pen_attribute9
  ,p_pen_attribute10        =>  p_pen_attribute10
  ,p_pen_attribute11        =>  p_pen_attribute11
  ,p_pen_attribute12        =>  p_pen_attribute12
  ,p_pen_attribute13        =>  p_pen_attribute13
  ,p_pen_attribute14        =>  p_pen_attribute14
  ,p_pen_attribute15        =>  p_pen_attribute15
  ,p_pen_attribute16        =>  p_pen_attribute16
  ,p_pen_attribute17        =>  p_pen_attribute17
  ,p_pen_attribute18        =>  p_pen_attribute18
  ,p_pen_attribute19        =>  p_pen_attribute19
  ,p_pen_attribute20        =>  p_pen_attribute20
  ,p_pen_attribute21        =>  p_pen_attribute21
  ,p_pen_attribute22        =>  p_pen_attribute22
  ,p_pen_attribute23        =>  p_pen_attribute23
  ,p_pen_attribute24        =>  p_pen_attribute24
  ,p_pen_attribute25        =>  p_pen_attribute25
  ,p_pen_attribute26        =>  p_pen_attribute26
  ,p_pen_attribute27        =>  p_pen_attribute27
  ,p_pen_attribute28        =>  p_pen_attribute28
  ,p_pen_attribute29        =>  p_pen_attribute29
  ,p_pen_attribute30        =>  p_pen_attribute30
  ,p_dpnt_actn_warning      =>  p_dpnt_actn_warning
  ,p_bnf_actn_warning       =>  p_bnf_actn_warning
  ,p_ctfn_actn_warning      =>  p_ctfn_actn_warning);


END election_information;
-- ----------------------------------------------------------------------------
-- |--------------------------< decd_attribute >-------------------------|
-- ----------------------------------------------------------------------------
-- This function is used to assign null value to attribute columns
-- if it contains the value $Sys_Def$
-- created for bug# 2714383
function decd_attribute(l_attribute in varchar2) return varchar2 is
     begin
     if l_attribute = hr_api.g_varchar2 then
     	return null;
     else
     	return l_attribute;
     end if;
end decd_attribute;

-- ----------------------------------------------------------------------------
-- |--------------------------< determine_erlst_deenrt_dt >-------------------------|
-- ----------------------------------------------------------------------------


procedure determine_erlst_deenrt_date(p_oipl_id            in   number,
                                 p_pl_id                 in   number  ,
                                 p_pl_typ_id             in   number  ,
                                 p_ptip_id               in   number  ,
                                 p_pgm_id                in   number  ,
                                 p_ler_id                in   number   ,
                                 p_effective_date        in   date  ,
                                 p_business_group_id     in   number    ,
                                 p_orgnl_enrt_dt         in   date   ,
                                 p_person_id             in   number   ,
                                 p_lf_evt_ocrd_dt        in   date   ,
                                 p_enrt_cvg_strt_dt      in   date  ,
                                 p_return_date           in out nocopy date   )

is


    CURSOR c_pl_popl_yr_period_current IS
      SELECT   yp.end_date,
               pyp.ordr_num
      FROM     ben_popl_yr_perd pyp, ben_yr_perd yp
      WHERE    pyp.pl_id = p_pl_id
      AND      pyp.yr_perd_id = yp.yr_perd_id
      AND      pyp.business_group_id = p_business_group_id
      AND      p_lf_evt_ocrd_dt BETWEEN yp.start_date AND yp.end_date
      AND      yp.business_group_id = p_business_group_id;


    Cursor c_oipl is
       select opt_id
       from ben_oipl_f
       where oipl_id = p_oipl_id
        and  business_group_id = p_business_group_id
        and   p_effective_date between EFFECTIVE_START_DATE
        AND  EFFECTIVE_END_DATE;

    cursor c_asg is
    select asg.assignment_id ,
           asg.organization_id
    from   per_all_assignments_f asg
    where  asg.person_id    = p_person_id
    and    asg.assignment_type <> 'C'
    and    asg.primary_flag = 'Y'
    and    p_effective_date between
           asg.effective_start_date and asg.effective_end_date;

     CURSOR c_state IS
      SELECT   loc.region_2
      FROM     hr_locations_all loc, per_all_assignments_f asg
      WHERE    loc.location_id = asg.location_id
      AND      asg.person_id = p_person_id
      and      asg.assignment_type <> 'C'
      AND      asg.primary_flag = 'Y'
      AND      p_lf_evt_ocrd_dt BETWEEN asg.effective_start_date
                   AND asg.effective_end_date
      AND      asg.business_group_id = p_business_group_id;
    --
    l_state                    c_state%ROWTYPE;


     l_opt_id                       number(15) ;
     l_level                       varchar2(5) ;
     l_rqd_perd_enrt_nenrt_uom      VARCHAR2(30);
     l_rqd_perd_enrt_nenrt_val      NUMBER;
     l_rqd_perd_enrt_nenrt_rl       NUMBER;
     l_erlst_deenrt_calc_dt         date  ;
     l_jurisdiction_code            VARCHAR2(30);
     l_popl_yr_perd_ordr_num        NUMBER;
     l_yr_perd_end_date             DATE;
     l_rec_assignment_id            NUMBER;
     l_rec_organization_id          NUMBER;


begin

  g_debug := hr_utility.debug_enabled;
  if p_oipl_id is not  null then
     open c_oipl ;
     fetch c_oipl  into l_opt_id ;
     close c_oipl ;
  end if ;

-- 4031733 - Cursor c_state populates l_state variable which is no longer
-- used in the package. Cursor can be commented
/*
  OPEN c_state;
  FETCH c_state INTO l_state;
  CLOSE c_state;
*/
  --IF l_state.region_2 IS NOT NULL THEN
  --    l_jurisdiction_code :=
  --     pay_mag_utils.lookup_jurisdiction_code(p_state => l_state.region_2);
  --END IF;

  OPEN c_asg;
  FETCH c_asg INTO l_rec_assignment_id, l_rec_organization_id;
  close c_asg;


   OPEN c_pl_popl_yr_period_current;
    --
   FETCH c_pl_popl_yr_period_current INTO  l_yr_perd_end_date,
                                           l_popl_yr_perd_ordr_num;
   CLOSE c_pl_popl_yr_period_current;


  ben_enrolment_requirements.find_rqd_perd_enrt(
      p_oipl_id                 => p_oipl_id,
      p_opt_id                  => l_opt_id,
      p_pl_id                   => p_pl_id,
      p_ptip_id                 => p_ptip_id,
      p_effective_date          => p_effective_date,
      p_business_group_id       => p_business_group_id,
      p_rqd_perd_enrt_nenrt_uom => l_rqd_perd_enrt_nenrt_uom,
      p_rqd_perd_enrt_nenrt_val => l_rqd_perd_enrt_nenrt_val,
      p_rqd_perd_enrt_nenrt_rl  => l_rqd_perd_enrt_nenrt_rl,
      p_level                   => l_level);


     l_erlst_deenrt_calc_dt   :=   p_enrt_cvg_strt_dt ;
  If l_level is not null and l_level not in('OPT','OIPL') then
     l_erlst_deenrt_calc_dt := nvl(p_orgnl_enrt_dt,p_enrt_cvg_strt_dt );
  end if ;

  if g_debug then
    hr_utility.set_location('uom'||l_rqd_perd_enrt_nenrt_uom ,8086.1);
  end if;
  if g_debug then
    hr_utility.set_location('val'||l_rqd_perd_enrt_nenrt_val ,8086.1);
  end if;
  if g_debug then
    hr_utility.set_location('cvg_dt '||l_erlst_deenrt_calc_dt  ,8086.1);
  end if;
  if g_debug then
    hr_utility.set_location('date before calca'||p_return_date ,8086.1);
  end if;
  if (l_rqd_perd_enrt_nenrt_val is  not null and l_rqd_perd_enrt_nenrt_uom is not null )
     or l_rqd_perd_enrt_nenrt_rl is not null then
       p_return_date :=
       ben_enrolment_requirements.determine_erlst_deenrt_dt(
         l_erlst_deenrt_calc_dt,
         l_rqd_perd_enrt_nenrt_val,
         l_rqd_perd_enrt_nenrt_uom,
         l_rqd_perd_enrt_nenrt_rl,
         p_oipl_id,
         p_pl_id,
         p_pl_typ_id,
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
  end if ;
  if g_debug then
    hr_utility.set_location('date after  calca'||p_return_date ,8086.1);
  end if;

END determine_erlst_deenrt_date ;






-- ----------------------------------------------------------------------------
-- |--------------------------< election_information >-------------------------|
-- ----------------------------------------------------------------------------
-- OVERLOADED, SEE ABOVE.
-- If new flags are need for the rco flow and not needed => forms, add them to
-- this procedure.
--
procedure election_information
  (p_validate               in boolean default FALSE
  ,p_elig_per_elctbl_chc_id in number
  ,p_prtt_enrt_rslt_id      in out nocopy number
  ,p_effective_date         in date
  ,p_enrt_mthd_cd           in varchar2
  ,p_enrt_bnft_id           in number
  ,p_bnft_val               in number default null
  ,p_enrt_cvg_strt_dt       in  date  default null
  ,p_enrt_cvg_thru_dt       in  date  default null
  ,p_enrt_rt_id1            in number default null
  ,p_prtt_rt_val_id1        in out nocopy number
  ,p_rt_val1                in number default null
  ,p_ann_rt_val1            in number default null
  ,p_rt_strt_dt1            in date   default null
  ,p_rt_end_dt1             in date   default null
  ,p_enrt_rt_id2            in number default null
  ,p_prtt_rt_val_id2        in out nocopy number
  ,p_rt_val2                in number default null
  ,p_ann_rt_val2            in number default null
  ,p_rt_strt_dt2            in date   default null
  ,p_rt_end_dt2             in date   default null
  ,p_enrt_rt_id3            in number default null
  ,p_prtt_rt_val_id3        in out nocopy number
  ,p_rt_val3                in number default null
  ,p_ann_rt_val3            in number default null
  ,p_rt_strt_dt3            in date   default null
  ,p_rt_end_dt3             in date   default null
  ,p_enrt_rt_id4            in number default null
  ,p_prtt_rt_val_id4        in out nocopy number
  ,p_rt_val4                in number default null
  ,p_ann_rt_val4            in number default null
  ,p_rt_strt_dt4            in date   default null
  ,p_rt_end_dt4             in date   default null
  ,p_enrt_rt_id5            in number default null
  ,p_prtt_rt_val_id5        in out nocopy number
  ,p_rt_val5                in number default null
  ,p_ann_rt_val5            in number default null
  ,p_rt_strt_dt5            in date   default null
  ,p_rt_end_dt5             in date   default null
  ,p_enrt_rt_id6            in number default null
  ,p_prtt_rt_val_id6        in out nocopy number
  ,p_rt_val6                in number default null
  ,p_ann_rt_val6            in number default null
  ,p_rt_strt_dt6            in date   default null
  ,p_rt_end_dt6             in date   default null
  ,p_enrt_rt_id7            in number default null
  ,p_prtt_rt_val_id7        in out nocopy number
  ,p_rt_val7                in number default null
  ,p_ann_rt_val7            in number default null
  ,p_rt_strt_dt7            in date   default null
  ,p_rt_end_dt7             in date   default null
  ,p_enrt_rt_id8            in number default null
  ,p_prtt_rt_val_id8        in out nocopy number
  ,p_rt_val8                in number default null
  ,p_ann_rt_val8            in number default null
  ,p_rt_strt_dt8            in date   default null
  ,p_rt_end_dt8             in date   default null
  ,p_enrt_rt_id9            in number default null
  ,p_prtt_rt_val_id9        in out nocopy number
  ,p_rt_val9                in number default null
  ,p_ann_rt_val9            in number default null
  ,p_rt_strt_dt9            in date   default null
  ,p_rt_end_dt9             in date   default null
  ,p_enrt_rt_id10           in number default null
  ,p_prtt_rt_val_id10       in out nocopy number
  ,p_rt_val10               in number default null
  ,p_ann_rt_val10           in number default null
  ,p_rt_strt_dt10           in date   default null
  ,p_rt_end_dt10            in date   default null
  ,p_datetrack_mode         in varchar2
  ,p_suspend_flag           in out nocopy varchar2
  ,p_called_from_sspnd      in varchar2          -- flag not other spec
  ,p_effective_start_date   out nocopy date
  ,p_effective_end_date     out nocopy date
  ,p_object_version_number  in out nocopy number
  ,p_prtt_enrt_interim_id   out nocopy number
  ,p_business_group_id      in  number
  ,p_pen_attribute_category in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute1         in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute2         in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute3         in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute4         in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute5         in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute6         in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute7         in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute8         in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute9         in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute10        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute11        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute12        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute13        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute14        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute15        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute16        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute17        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute18        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute19        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute20        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute21        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute22        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute23        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute24        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute25        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute26        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute27        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute28        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute29        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute30        in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_actn_warning      out nocopy boolean
  ,p_bnf_actn_warning       out nocopy boolean
  ,p_ctfn_actn_warning      out nocopy boolean
  ,p_imp_cvg_strt_dt        in  date default NULL) -- 8716870
is
  -- Local variable Declarations

  l_prtt_enrt_rslt_id                 number;
  l_old_bnft_val                      number;
  l_old_enrt_cvg_strt_dt              date;
  l_old_enrt_cvg_thru_dt              date;
  l_old_erlst_deenrt_dt               date ;
  l_old_pl_id                         number;
  l_old_oipl_id                       number;
  l_old_per_in_ler_id                 number;
  l_old_ovn                           number;
--  l_prtt_is_cvrd_flag               varchar2(30);
  l_orgnl_enrt_dt                     date;
  l_old_orgnl_enrt_dt                 date;
  l_enrt_mthd_cd                      varchar2(30);
  l_enrt_ovridn_flag                  varchar2(30);
  l_enrt_ovrid_rsn_cd                 varchar2(30);
  l_enrt_ovrid_thru_dt                date;
  l_enrt_cvg_thru_dt                  date;
  l_enrt_cvg_strt_dt                  date;

l_global_epe_rec ben_global_enrt.g_global_epe_rec_type;
l_global_pel_rec ben_global_enrt.g_global_pel_rec_type;
l_global_pil_rec ben_global_enrt.g_global_pil_rec_type;
l_global_enb_rec ben_global_enrt.g_global_enb_rec_type;
l_global_pen_rec ben_prtt_enrt_rslt_f%rowtype;

  l_xenrt_cvg_strt_dt                 date;
  l_xenrt_cvg_strt_dt_cd              varchar2(30);
  l_xenrt_cvg_strt_dt_rl              number;
  l_xrt_strt_dt                       date;
  l_xrt_strt_dt_cd                    varchar2(30);
  l_xrt_strt_dt_rl                    number;
  l_xenrt_cvg_end_dt                  date;
  l_xenrt_cvg_end_dt_cd               varchar2(30);
  l_xenrt_cvg_end_dt_rl               number;
  l_xrt_end_dt                        date;
  l_xrt_end_dt_cd                     varchar2(30);
  l_xrt_end_dt_rl                     number;
  l_prtt_enrt_interim_id              number;
  l_dpnt_actn_warning                 boolean := FALSE;
  l_bnf_actn_warning                  boolean := FALSE;
  l_ctfn_actn_warning                 boolean := FALSE;
  l_action                            varchar2(30);
  --
  l_pl_rec         ben_cobj_cache.g_pl_inst_row;
  l_oipl_rec       ben_cobj_cache.g_oipl_inst_row;
  l_plip_rec       ben_cobj_cache.g_plip_inst_row;
  l_ptip_rec       ben_cobj_cache.g_ptip_inst_row;
  --
  l_bnft_amt_changed                  boolean := FALSE;
  l_use_new_result                    boolean := FALSE;
  l_crntly_enrd_rslt_exists           boolean := false;
  l_elect_cvg_strt_dt                 date    ;
  l_datetrack_mode                    varchar2(30);
  --
  l_proc                              varchar2(72) :=
                                         g_package||'election_information';
  l_object_version_number             number;
  l_dummy_number                      number;
  --
  -- current result info
  -- ben_sspndd_enrollment.g_use_new_result
  --
  cursor c_current_result_info(v_prtt_enrt_rslt_id number) is
    select pen.enrt_cvg_strt_dt,
           pen.enrt_cvg_thru_dt,
           pen.bnft_amt,
           pen.pl_id,
           pen.oipl_id,
           pen.orgnl_enrt_dt,
           pen.per_in_ler_id,
           pen.object_version_number,
           pen.erlst_deenrt_dt ,
           pen.enrt_ovrid_thru_dt,
           pen.enrt_ovrid_rsn_cd,
           pen.enrt_ovridn_flag,
           pen.sspndd_flag
    from   ben_prtt_enrt_rslt_f pen
    where  pen.prtt_enrt_rslt_id=v_prtt_enrt_rslt_id and
           pen.business_group_id=p_business_group_id and
           pen.prtt_enrt_rslt_stat_cd is null        and
           p_effective_date between
             pen.effective_start_date and pen.effective_end_date
    ;
  --
  l_crntly_enrd_rslt_rec  c_current_result_info%rowtype;
  -- Bug 2627078 fixes
  cursor c_delink_interim(v_prtt_enrt_rslt_id number, v_sspnd_result_id number ) is
    select pen.prtt_enrt_rslt_id ,
           pen.object_version_number
    from   ben_prtt_enrt_rslt_f pen
    where  pen.rplcs_sspndd_rslt_id = v_prtt_enrt_rslt_id and
           pen.prtt_enrt_rslt_id = v_sspnd_result_id and
           p_effective_date between
             pen.effective_start_date and pen.effective_end_date
    ;
  --
  l_delink_interim    c_delink_interim%rowtype ;
  --
  cursor oipl_ordr_num_c (p_oipl_id number) is
     select ordr_num
       from ben_oipl_f
      where oipl_id = p_oipl_id and
            business_group_id   = p_business_group_id and
            p_effective_date between
                     effective_start_date and effective_end_date
    ;
    cursor c_regn_125_or_129 is
      select   'Y'
      from     ben_pl_regn_f prg,
               ben_regn_f regn
      where    prg.pl_id=l_global_epe_rec.pl_id
           and p_effective_date between
               prg.effective_start_date and prg.effective_end_date
           and prg.business_group_id=p_business_group_id
           and regn.regn_id=prg.regn_id
           and regn.name in ('IRC Section 125','IRC Section 129')
           and p_effective_date between
               regn.effective_start_date and regn.effective_end_date
           and regn.business_group_id=p_business_group_id
      ;
    l_regn_125_or_129_flag         varchar2(30);
    l_ret number;
    -- Bug 1913254
    -- Following cursor is for getting the annual val for
    -- cvg_mlt_cd of SAAEAR and enter value at enrollment is not checked.
/*
    cursor c_ert is
      select  ann_val
      from    ben_enrt_rt ert
      where   ert.enrt_bnft_id = p_enrt_bnft_id
         and  ENTR_VAL_AT_ENRT_FLAG = 'N'
         and  ann_val is not null ;
    l_ann_enrt_rt number ;
*/
    -- Bug 2212194 to fix the issue of having multiple rates associated
    -- with the comp object.
    --
    -- changed, bug: 5584813
    cursor c_ert is
      select  ert.ann_val,ert.ENTR_VAL_AT_ENRT_FLAG,
	      abr.acty_base_rt_id,
	      abr.rate_periodization_rl,
	      enb.elig_per_elctbl_chc_id,
	      ert.entr_ann_val_flag
      from    ben_enrt_rt ert,
              ben_acty_base_rt_f abr,
	      ben_enrt_bnft enb
      where  enb.enrt_bnft_id = p_enrt_bnft_id
         and ert.enrt_bnft_id = enb.enrt_bnft_id
         and nvl(abr.PARNT_CHLD_CD,'PARNT') = 'PARNT'
         and abr.acty_base_rt_id = ert.acty_base_rt_id
         and p_effective_date between abr.effective_start_date
             and abr.effective_end_date
         and ert.acty_typ_cd not like 'PRD%'
         and ert.acty_typ_cd <> 'PRFRFS' ;
         -- and  ENTR_VAL_AT_ENRT_FLAG = 'Y'
         -- and  ann_val is not null ;
    l_ert c_ert%rowtype;
    l_dummy_rt_val NUMBER;
    --
    --Bug 2172036 populating the assignment_id in the pen
    cursor c_epe is
      select epe.assignment_id ,
             epe.fonm_cvg_strt_dt
      from ben_elig_per_elctbl_chc epe
      where epe.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id ;
    --
    cursor c_enb_pen is
      select enb.prtt_enrt_rslt_id
      from ben_enrt_bnft enb,
           ben_prtt_enrt_rslt_f pen
      where enb.enrt_bnft_id = p_enrt_bnft_id
        and enb.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
        and pen.effective_end_date = hr_api.g_eot
        and pen.enrt_cvg_thru_dt = hr_api.g_eot
        and pen.prtt_enrt_rslt_stat_cd is NULL
        ;
    --
    -- Bug 2600087 fixes to open future dated coverage
    cursor c_enrt_rslt is
      select pen.*
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
   --bug#5032364
    cursor c_enrt_rslt2 is
      select pen.*
      from   ben_prtt_enrt_rslt_f pen
      where  pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
      and    pen.prtt_enrt_rslt_stat_cd is null
      and    pen.effective_end_date = hr_api.g_eot;
   --
    l_enrt_rslt2   c_enrt_rslt2%rowtype;
   --
   -- 5612091 - Added OR condition with p_elig_per_elctbl_chc_id
    cursor c_enrt_rt (p_acty_base_rt_id number) is
      select enrt_rt_id
      from ben_enrt_rt ecr
      where (ecr.enrt_bnft_id = p_enrt_bnft_id
       or ecr.ELIG_PER_ELCTBL_CHC_ID = p_elig_per_elctbl_chc_id)
      and ecr.acty_base_rt_id = p_acty_base_rt_id;
   --
    cursor c_prtt_rt_val_id is
      select prv.prtt_rt_val_id,
             prv.acty_base_rt_id
      from ben_prtt_rt_val prv
      where prv.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
        and prv.prtt_rt_val_stat_cd is null
        order by prv.rt_strt_dt asc;
    --
    -- Bug 5766477.
    --
    cursor c_get_dpnt(p_effective_date in date) is
      select pdp.*
      from   ben_elig_cvrd_dpnt_f pdp
      where  pdp.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
      and    pdp.cvg_thru_dt is not null
      and    pdp.effective_end_date <> hr_api.g_eot
      and    p_effective_date
             between pdp.effective_start_date
             and pdp.effective_end_date;
    --
    cursor c_pen_exists(v_prtt_enrt_rslt_id number) is
      select 'x'
    from  ben_prtt_enrt_rslt_f pen
    where pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and  pen.business_group_id = p_business_group_id
     and  p_effective_date between pen.effective_start_date
                  and pen.effective_end_date ;

    cursor c_wv_opt (p_oipl_id number ) is
       select opt.invk_wv_opt_flag
         from ben_opt_f opt , ben_oipl_f oipl
        where oipl.oipl_id = p_oipl_id
         and  oipl.opt_id = opt.opt_id
         and  oipl.business_group_id   = p_business_group_id
         and  p_effective_date between  oipl.effective_start_date and oipl.effective_end_date
         and  p_effective_date between  opt.effective_start_date and opt.effective_end_date ;

    -- to check the future coverage deleted
    l_wv_flag      varchar2(30);
    l_dummy_char   varchar2(30) ;
    l_enrt_rslt    c_enrt_rslt%rowtype;
    l_enrt_rt_id    number;
    l_prtt_rt_val_id  number;
    l_assignment_id number(15);
    l_start_new_result     boolean := false;
    l_object_version_number2 number := p_object_version_number;
    l_effective_start_date  date;
    l_effective_end_date    date;
    l_acty_base_rt_id2   number;
    l_dlink_effective_start_date  date;
    l_dlink_effective_end_date    date;
    l_old_enrt_ovrid_thru_dt      date;
    l_old_enrt_ovrid_rsn_cd       varchar2(30);
    l_old_enrt_ovridn_flag        varchar2(30) := 'N' ;
    l_old_sspndd_flag             varchar2(30);
    l_new_cvg_strt_dt             date;
    l_fonm_cvg_strt_dt            date ;
    l_fonm_flag                   varchar2(30) := 'N' ;
  --
    l_interim_count number;--3733745
    --
    l_enb_prtt_enrt_rslt_id number ;
    --
    -- Bug 5600697
    --
    cursor c_is_pen_valid(cv_prtt_enrt_rslt_id number) is
      select pen.prtt_enrt_Rslt_stat_Cd
      from   ben_prtt_enrt_rslt_f pen
      where  pen.prtt_enrt_rslt_id = cv_prtt_enrt_rslt_id and
             pen.business_group_id= p_business_group_id and
             p_effective_date between pen.effective_start_date and pen.effective_end_date;
    --
    l_pen_stat_cd varchar2(30);
    --
    cursor c_pen_curr(v_prtt_enrt_rslt_id number,
                         p_effective_date date) is
      select pen.*
      from   ben_prtt_enrt_rslt_f pen
      where  pen.prtt_enrt_rslt_id = v_prtt_enrt_rslt_id
      and    p_effective_date between
             pen.effective_start_date and pen.effective_end_date
      and    pen.effective_end_date <> hr_api.g_eot
      and    pen.prtt_enrt_rslt_stat_cd is null
      and    pen.business_group_id = p_business_group_id
      order by pen.effective_start_date desc ;
    --
    l_pen_curr    c_pen_curr%rowtype;
    l_pen_curr_interim c_pen_curr%rowtype;
    --
    cursor c_prv(p_prtt_enrt_rslt_id number, p_per_in_ler_id number) is
    select prv.*
      from ben_prtt_rt_val prv
     where prv.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
       and prv.per_in_ler_id = p_per_in_ler_id
       and prv.prtt_rt_val_stat_cd is NULL ;
    --
    cursor c_ecr(p_prtt_rt_val_id number) is
    select ecr.rt_strt_dt,
           ecr.rt_strt_dt_cd,
           ecr.rt_strt_dt_rl,
           nvl(ecr.elig_per_elctbl_chc_id,enb.elig_per_elctbl_chc_id) elig_per_elctbl_chc_id
     from ben_enrt_rt ecr,
          ben_enrt_bnft enb
    where ecr.prtt_rt_val_id = p_prtt_rt_val_id
      and ecr.enrt_bnft_id = enb.enrt_bnft_id (+) ;
    --
    l_ecr   c_ecr%rowtype;
    -- bug 5621049
     cursor c_validate_epe_pen(cv_elig_per_elctblc_chc_id number,cv_prtt_enrt_rslt_id number ) is
     select null
     from ben_elig_per_elctbl_chc
     where elig_per_elctbl_chc_id = cv_elig_per_elctblc_chc_id
     and prtt_enrt_rslt_id = cv_prtt_enrt_rslt_id;

   ------Bug 7374973
  cursor c_unrestricted(p_ler_id number) is
   select ler.typ_cd
     from ben_ler_f ler
    where ler_id = p_ler_id
      and ler.business_group_id = p_business_group_id;
   l_unrestricted c_unrestricted%rowtype;

     -- Added for bug 7206471
  --
   /* Added cursor for Bug 8945818: Get the previous per_in_ler_id */

   cursor c_prev_per_in_ler is
    select pil.per_in_ler_id
    from   ben_per_in_ler pil,
           ben_per_in_ler pil1,
           ben_ler_f ler,
	   ben_elig_per_elctbl_chc epe
    where  pil1.per_in_ler_id = epe.per_in_ler_id
    and    epe.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id
    and    pil1.person_id = pil.person_id
    and    pil1.per_in_ler_id <> pil.per_in_ler_id
    and    pil.ler_id        = ler.ler_id
    and    p_effective_date between
           ler.effective_start_date and ler.effective_end_date
    and    ler.typ_cd not in ('IREC', 'SCHEDDU', 'COMP', 'GSP', 'ABS')
    and    pil.per_in_ler_stat_cd not in('BCKDT', 'VOIDD')
    order by pil.lf_evt_ocrd_dt desc;

    l_prev_pil_id number;

   cursor c_get_prior_per_in_ler(c_cvg_strt_dt date) is
   select 'Y'
   from   ben_elig_per_elctbl_chc epe, ben_per_in_ler pil,
          ben_per_in_ler pil2
   where  epe.elig_per_elctbl_chc_id=p_elig_per_elctbl_chc_id
   and    pil.per_in_ler_id <> epe.per_in_ler_id
   /* Bug 8945818: Added 'or' condition. Check for future coverage for the previous life event */
   and    ( (trunc(pil.lf_evt_ocrd_dt, 'MM') = trunc(pil2.lf_evt_ocrd_dt, 'MM')) or
          ('Y' = (select 'Y' from  ben_elig_per_elctbl_chc epe1,
                                  ben_elig_per_elctbl_chc epe2,
                                  ben_prtt_enrt_rslt_f pen
                 where epe1.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id
                       and epe1.per_in_ler_id <> epe2.per_in_ler_id
                       and epe2.per_in_ler_id = l_prev_pil_id
                       and epe1.ptip_id = epe2.ptip_id
                       and epe2.prtt_enrt_rslt_id is not null
                       and epe2.per_in_ler_id = pen.per_in_ler_id
		       and pen.person_id = pil.person_id
                       and epe2.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
                       and c_cvg_strt_dt <= pen.enrt_cvg_strt_dt
		       and rownum = 1) )
          )
   and    pil2.per_in_ler_id = epe.per_in_ler_id
   and    pil.person_id = pil2.person_id -- Bug 8871911: Performance Bug
   and    pil.business_group_id = pil2.business_group_id
   and    pil.business_group_id = p_business_group_id
   and    pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT');

   --
   l_exists varchar2(2);
   --
  cursor c_get_pgm is
  select distinct epe.pgm_id
  from ben_elig_per_elctbl_chc epe
  where epe.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id;
  --
  cursor c_get_pgm_extra_info_cvg(p_pgm_id number) is
  select pgi_information1
  from ben_pgm_extra_info
  where information_type = 'ADJ_CVG_PREV_LF_EVT'
  and pgm_id = p_pgm_id;
  --
  l_cvg_adjust varchar2(2);
  --
  cursor c_get_elctbl_chc_for_cvg is
   select min(epe.enrt_cvg_strt_dt) enrt_cvg_strt_dt
         ,epe.ptip_id
   from ben_elig_per_elctbl_chc  epe
   where epe.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id
   and   epe.business_group_id = p_business_group_id
   group by epe.ptip_id;

   /*Bug 8507247: The ended coverage should not be adjusted based on min(enrt_cvg_strt_dt) on the
   choice since the enrt_cvg_strt_dt is recalculated in election_information for NON FONM plans
   (Ex:First of Pay Period after Effective Date) before creating the new enrollment and is not updated to the choice.
   Since we already know of the new cvg_strt_dt from which we are going to create the new enrollment the same can be used to
   adjust the ended coverage. This will prevent any coverage gaps.*/
   cursor c_get_ptip_id is
      select epe.ptip_id
   from ben_elig_per_elctbl_chc  epe
   where epe.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id
   and   epe.business_group_id = p_business_group_id;

   l_ptip_id number;
   /*End Bug 8507247*/
   --
   cursor c_get_enrt_rslts_for_pen(p_cvg_end_dt date
                         ,p_ptip_id   number
                          ) is
   select pen.*, epe.per_in_ler_id pil_id
   from ben_prtt_enrt_rslt_f pen
       ,ben_ptip_f ptip
       ,ben_per_in_ler pil
       ,ben_elig_per_elctbl_chc epe
   where pen.effective_end_date = hr_api.g_eot -- '31-dec-4712'
   and   pen.enrt_cvg_thru_dt <> hr_api.g_eot -- '31-dec-4712'
   and   pen.prtt_enrt_rslt_stat_cd is null
   and   pen.person_id =  pil.person_id -- 318321
   and   pen.business_group_id = p_business_group_id -- 81545
   and   pen.ptip_id = p_ptip_id -- 54444
   and   pen.enrt_cvg_thru_dt >=  p_cvg_end_dt -- '20-jan-2008'
   and   pen.ptip_id = ptip.ptip_id
   and   pil.per_in_ler_id = epe.per_in_ler_id
   and   epe.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id
   and   p_effective_date between ptip.effective_start_date
                  and ptip.effective_end_date;
   --
   cursor c_prtt_enrt_rslt_adj (p_prtt_enrt_rslt_id number) is
   select null
   from  ben_le_clsn_n_rstr leclr, ben_elig_per_elctbl_chc epe
   where leclr.BKUP_TBL_TYP_CD = 'BEN_PRTT_ENRT_RSLT_F_ADJ'
   AND   leclr.BKUP_TBL_ID = p_prtt_enrt_rslt_id
   AND   leclr.PER_IN_LER_ID  = epe.per_in_ler_id
   AND   epe.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id;
   --
   -- end 7206471
  --  ------------------------------------------------------------
  ---------Bug 9139820
   cursor c_get_pil_enrt(p_pen_id number,p_per_in_ler_id number,
                               p_cvg_strt_dt date) is
  SELECT *
  FROM ben_prtt_enrt_rslt_f pen
 WHERE pen.per_in_ler_id = p_per_in_ler_id
   AND pen.business_group_id = p_business_group_id
   and pen.prtt_enrt_rslt_id = p_pen_id
   AND pen.enrt_cvg_strt_dt =  p_cvg_strt_dt
   and pen.sspndd_flag <> 'Y'
   and not EXISTS(SELECT NULL
                    FROM ben_prtt_enrt_rslt_f pen2
                   WHERE pen2.per_in_ler_id = pen.per_in_ler_id
                     AND pen2.rplcs_sspndd_rslt_id = pen.prtt_enrt_rslt_id
                     AND pen2.sspndd_flag = 'Y'
		     AND pen2.prtt_enrt_rslt_stat_cd IS NULL
                     AND pen2.business_group_id = pen.business_group_id)
   AND pen.prtt_enrt_rslt_stat_cd IS NULL
   order by pen.effective_start_date desc;

  l_get_prev_pil_enrt  c_get_pil_enrt%rowtype;
  l_check_enrt_same_pil  c_get_pil_enrt%rowtype;
  cursor c_bkup_pen_rec(p_pen_id number,p_pil_id number,p_person_id number,p_esd date,p_csd date) is
  SELECT bkup.*
  FROM ben_le_clsn_n_rstr bkup
 WHERE bkup.bkup_tbl_id = p_pen_id
   AND bkup_tbl_typ_cd = 'BEN_PRTT_ENRT_RSLT_F_CORR'
   AND bkup.per_in_ler_id = p_pil_id
   AND bkup.person_id = p_person_id
   AND bkup.business_group_id = p_business_group_id
   AND bkup.effective_start_date = p_esd
   AND bkup.enrt_cvg_strt_dt = p_csd
   AND bkup.effective_end_date = hr_api.g_eot
   AND bkup.enrt_cvg_thru_dt = hr_api.g_eot;

  l_bkup_pen_rec   c_bkup_pen_rec%rowtype;
  l_pil_id         number;

  cursor c_get_ovn(p_pen_id number,p_pil_id number,p_esd date) is
  select max(pen.object_version_number)
    from ben_prtt_enrt_rslt_f pen
   where pen.prtt_enrt_rslt_id = p_pen_id
     and pen.per_in_ler_id = p_pil_id
     and pen.business_group_id = p_business_group_id
     and pen.effective_start_date = p_esd
  order by pen.effective_start_date desc,pen.object_version_number desc;
  -----Enf of Bug 9139820
  ----Bug 8596122
  cursor c_prev_pil(p_person_id number) is
  SELECT pil.per_in_ler_id
  FROM ben_per_in_ler pil
 WHERE pil.business_group_id = p_business_group_id
   AND pil.person_id = p_person_id
   AND pil.per_in_ler_stat_cd = 'PROCD'
ORDER BY pil.lf_evt_ocrd_dt DESC ;

  l_prev_pil    c_prev_pil%rowtype;

  ---Bug 9430735
  cursor c_prev_pil_with_pen(p_person_id number,p_pen_id number) is
  SELECT pil.per_in_ler_id
  FROM ben_per_in_ler pil
 WHERE pil.business_group_id = p_business_group_id
   AND pil.person_id = p_person_id
   AND pil.per_in_ler_stat_cd = 'PROCD'
   and exists(select null
                from ben_prtt_enrt_rslt_f pen
	       where pen.per_in_ler_id = pil.per_in_ler_id
	         and pen.prtt_enrt_rslt_stat_cd is null
		 and pen.prtt_enrt_rslt_id = p_pen_id)
ORDER BY pil.lf_evt_ocrd_dt DESC ;

  ---Bug 9430735

  cursor c_check_int_enr(p_pil_id number,p_pgm_id number,p_pl_id number,p_oipl_id number) is
  SELECT *
  FROM ben_prtt_enrt_rslt_f pen
 WHERE pen.per_in_ler_id = p_pil_id
   AND nvl(pen.pgm_id,-1) = nvl(p_pgm_id,-1)
   AND pen.pl_id = p_pl_id
   AND Nvl(pen.oipl_id ,-1) = nvl(p_oipl_id,-1)
   AND pen.business_group_id = p_business_group_id
   and pen.enrt_cvg_thru_dt = hr_api.g_eot
   AND pen.prtt_enrt_rslt_stat_cd IS NULL
   AND EXISTS(SELECT NULL
                    FROM ben_prtt_enrt_rslt_f pen2
                   WHERE pen2.per_in_ler_id = pen.per_in_ler_id
                     AND pen2.rplcs_sspndd_rslt_id = pen.prtt_enrt_rslt_id
                     AND pen2.sspndd_flag = 'Y'
		     AND pen2.prtt_enrt_rslt_stat_cd IS NULL
		     and pen2.enrt_cvg_thru_dt = hr_api.g_eot
                     AND pen2.business_group_id = pen.business_group_id);
 l_check_int_enr   c_check_int_enr%rowtype;

 l_yenrt_cvg_strt_dt_cd     varchar2(30);
  l_yenrt_cvg_strt_dt_rl     number;
  l_yrt_strt_dt              date;
  l_yrt_strt_dt_cd           varchar2(30);
  l_yrt_strt_dt_rl           number;
  l_yenrt_cvg_end_dt         date;
  l_yenrt_cvg_end_dt_cd      varchar2(30);
  l_yenrt_cvg_end_dt_rl      number;
  l_yrt_end_dt               date;
  l_yrt_end_dt_cd            varchar2(10);
  l_yrt_end_dt_rl            number;

BEGIN
    g_debug := hr_utility.debug_enabled;
    if g_debug then
      hr_utility.set_location('Entering:'||l_proc, 5);
    end if;
    if g_debug then
      hr_utility.set_location(' chc:'|| to_char(p_elig_per_elctbl_chc_id)||' rslt:'|| to_char(p_prtt_enrt_rslt_id), 5);
    end if;
    if g_debug then
      hr_utility.set_location('p_enrt_rt_id1'||p_enrt_rt_id1,1999);
    end if;

  --
  -- Work out if we are being called from a concurrent program
  -- otherwise we need to initialize the environment
  --
  if fnd_global.conc_request_id = -1 then
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
  --
  --
  -- Issue a savepoint depending on where we are called from.  We
  -- must do this because election_information calls create_enrollment
  -- which calls Determine_other_action_items which calls Suspend_enrollment
  -- Which might create an interim result by calling election_information.
  -- When it does, it would reset this save point.
  --
  -- This flag is also passed to create_enrollment
  --
  if p_called_from_sspnd = 'N' then
     savepoint election_information_savepoint;
  else
     savepoint election_information_sspnd;
  end if;

  --
  -- For the case where this is creating an interim enrollment
  -- and the interim choice is the same as the original then
  -- we should create a new result.
  --
  if p_called_from_sspnd = 'Y' then
    if g_elig_per_elctbl_chc_id=p_elig_per_elctbl_chc_id then
      if g_debug then
        hr_utility.set_location(' l_use_new_result:=true ',1223);
      end if;
      l_use_new_result:=true;
    end if;
  end if;
  --
  -- set globals to be used by bensuenr, suspend enrollment
  --
  g_enrt_bnft_id:=p_enrt_bnft_id;
  g_bnft_val:=p_bnft_val;
  g_elig_per_elctbl_chc_id:=p_elig_per_elctbl_chc_id;
  --
  -- begin by getting the choice, bnft, per in ler and pil popl information
  --
  ben_global_enrt.get_epe  -- choice
       (p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id
       ,p_global_epe_rec         => l_global_epe_rec);

  ben_global_enrt.get_pel  -- pil popl
       (p_pil_elctbl_chc_popl_id => l_global_epe_rec.pil_elctbl_chc_popl_id
       ,p_global_pel_rec         => l_global_pel_rec);

  ben_global_enrt.get_pil  -- per in ler
       (p_per_in_ler_id          => l_global_epe_rec.per_in_ler_id
       ,p_global_pil_rec         => l_global_pil_rec);

--Bug#5099296
  if l_global_epe_rec.prtt_enrt_rslt_id is not null then
    ben_global_enrt.get_pen
       (p_prtt_enrt_rslt_id      => l_global_epe_rec.prtt_enrt_rslt_id
       ,p_effective_date         => p_effective_date
       ,p_global_pen_rec         => l_global_pen_rec);
  end if;
--Bug#5099296

  if p_enrt_bnft_id is not null then
     ben_global_enrt.get_enb   -- enrt bnft
       (p_enrt_bnft_id           => p_enrt_bnft_id
       ,p_global_enb_rec         => l_global_enb_rec);
  else
     ben_global_enrt.clear_enb
       (p_global_enb_rec         => l_global_enb_rec);
  end if;

  if l_global_epe_rec.oipl_id is not null and p_enrt_bnft_id is null then
        open oipl_ordr_num_c(p_oipl_id => l_global_epe_rec.oipl_id);
        fetch oipl_ordr_num_c into l_global_enb_rec.ordr_num;
        close oipl_ordr_num_c;
  end if;

  if g_debug then
    hr_utility.set_location(l_proc, 15);
  end if;


  --- determine FONM for election information  # 4510798

  open c_epe ;
  fetch c_epe into l_assignment_id ,
                    l_fonm_cvg_strt_dt;
  close c_epe ;

  if l_fonm_cvg_strt_dt is not null then
     l_fonm_flag :=  'Y'  ;
     ben_manage_life_events.fonm := 'Y';
     ben_manage_life_events.g_fonm_cvg_strt_dt := l_fonm_cvg_strt_dt;
     /* 8716870: Code added for Imp Inc Enh begins*/
     if p_imp_cvg_strt_dt is not NULL and p_imp_cvg_strt_dt > l_fonm_cvg_strt_dt then
        hr_utility.set_location('p_imp_cvg_strt_dt '||p_imp_cvg_strt_dt,20);
        ben_manage_life_events.g_fonm_cvg_strt_dt := p_imp_cvg_strt_dt;
        l_global_epe_rec.enrt_cvg_strt_dt := p_imp_cvg_strt_dt;
     end if;
     /* Code added for Imp Inc Enh ends*/

  else
      l_fonm_flag :=  'N'  ;
      ben_manage_life_events.fonm := 'N';
      ben_manage_life_events.g_fonm_cvg_strt_dt := null ;
  end if ;
  hr_utility.set_location (' FONM ' ||  ben_manage_life_events.fonm , 99 ) ;
  hr_utility.set_location (' FONM CVG  ' ||  ben_manage_life_events.g_fonm_cvg_strt_dt , 99 ) ;

  --
  -- If form code is too lazy to pass in the result id
  -- then get it from the choice.  Note will be null if
  -- the choice has not previously been enrolled in.
  --
  -- Assign only if result id is null - Bug#5369
  -- Bug 2547005 and 2543071 This needs to checked first. In Enter value at enrollment case
  -- with benefit restriction we get the right penid here.
  -- We may have two benefit rows one having the penid and other not. If
  -- we are using the one without penid we can not use the penid from epe
  -- which is not right.
  --
  if g_debug then
    hr_utility.set_location('p_prtt_enrt_rslt_id '||p_prtt_enrt_rslt_id ,9999);
  end if;
  if g_debug then
    hr_utility.set_location('l_global_epe_rec.p_e_r_id '||l_global_epe_rec.prtt_enrt_rslt_id,9999);
  end if;
  if g_debug then
    hr_utility.set_location('p_enrt_bnft_id '||p_enrt_bnft_id,9999);
  end if;
  --
  if p_enrt_bnft_id is not null then
    open  c_enb_pen ;
    fetch c_enb_pen into l_enb_prtt_enrt_rslt_id;
    close c_enb_pen ;
  end if;
  --
  if p_enrt_bnft_id is not null and p_prtt_enrt_rslt_id is null then
    --
    p_prtt_enrt_rslt_id := l_enb_prtt_enrt_rslt_id ;
    --
  elsif l_global_epe_rec.prtt_enrt_rslt_id is not null and p_prtt_enrt_rslt_id is null then
    --
    -- Bug 5600697 - In cases like FONM, if we delete enrollment for a subsequent life event, then
    --               EPE would still hold the PEN_ID but with BCKDT status. So if we again decide
    --               to enrol then 91711 error would occur while querying cursor C_CURRENT_RESULT_INFO
    --               I believe we should set P_PRTT_ENRT_RSLT_ID only if PRTT_ENRT_RSLT_STAT_CD is NULL
    --
    open c_is_pen_valid(l_global_epe_rec.prtt_enrt_rslt_id);
      --
      fetch c_is_pen_valid into l_pen_stat_cd;
      --
      if c_is_pen_valid%found and l_pen_stat_cd is null
      then
        --
        p_prtt_enrt_rslt_id := l_global_epe_rec.prtt_enrt_rslt_id;
        --
      end if;
      --
    close c_is_pen_valid;
    --
    --
  end if;
  --
  if l_enb_prtt_enrt_rslt_id IS NOT NULL and l_global_epe_rec.prtt_enrt_rslt_id <> l_enb_prtt_enrt_rslt_id THEN
    --
    l_global_epe_rec.prtt_enrt_rslt_id := l_enb_prtt_enrt_rslt_id  ;
    --
  end if;
  --
  hr_utility.set_location('l_enb_prtt_enrt_rslt_id'||l_enb_prtt_enrt_rslt_id,222);
  hr_utility.set_location('l_global_epe_rec.prtt_enrt_rslt_id'||l_global_epe_rec.prtt_enrt_rslt_id,222);
  --
  l_prtt_enrt_rslt_id := l_global_epe_rec.prtt_enrt_rslt_id;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 16);
  end if;
  --
  -- override the bnft_val if it's annualized and entered at enrt
  --
  -- Bug 1913254 Present logic works only for enter value at enrollment is
  -- checked for rate. Now added a new cursor to get the annual value for
  -- SAAEAR if the rate is not entered at enrollment.
  --
  --hr_utility. set_location(' cvg_mlt_cd Code '||l_global_enb_rec.cvg_mlt_cd , 17);
  --hr_utility. set_location(' p_ann_rt_val1 '||p_ann_rt_val1 ,18);
  --hr_utility. set_location(' p_bnft_val '||p_bnft_val ,19);
  --hr_utility. set_location(' p_enrt_rt_id1 '||p_enrt_rt_id1 ,19);
  --hr_utility. set_location(' p_enrt_bnft_id '||p_enrt_bnft_id , 20);
  --
  -- Bug 2212194 fixes
  --
  if l_global_enb_rec.cvg_mlt_cd='SAAEAR' then
    --
    open c_ert ;
    fetch c_ert into l_ert ; --l_ann_enrt_rt ;
    if c_ert%found then
      --
      if l_ert.ENTR_VAL_AT_ENRT_FLAG = 'Y' then
        --
	-- changed for bug: 5584813
	  if l_ert.entr_ann_val_flag = 'Y' then
		l_global_enb_rec.val:= p_ann_rt_val1;
          else
	        l_dummy_rt_val := p_rt_val1;
		calc_rt_ann_rt_vals (
		   p_rt_val                  => l_dummy_rt_val,
		   p_ann_rt_val              => l_global_enb_rec.val,
		   p_person_id               => l_global_pil_rec.person_id,
		   p_effective_date          => p_effective_date,
		   p_acty_base_rt_id         => l_ert.acty_base_rt_id,
		   p_rate_periodization_rl   => l_ert.rate_periodization_rl,
		   p_elig_per_elctbl_chc_id  => l_ert.elig_per_elctbl_chc_id,
		   p_business_group_id       => p_business_group_id,
		   p_enrt_rt_id              => p_enrt_rt_id1,
		   p_entr_ann_val_flag       => NULL,
		   p_entr_val_at_enrt_flag   => l_ert.entr_val_at_enrt_flag);
          end if;

	-- l_global_enb_rec.val:=p_ann_rt_val1;
        --
      else
        --
        l_global_enb_rec.val:= l_ert.ann_val ; -- l_ann_enrt_rt ;

        --
      end if;
      --
    /*
    open c_ert ;
    fetch c_ert into l_ann_enrt_rt ;
    if c_ert%found then
      --
      l_global_enb_rec.val:= l_ann_enrt_rt ;
      --
    */
    else
      --
      l_global_enb_rec.val:=p_ann_rt_val1;
      --
    end if;
    close c_ert ;
    --
  elsif p_bnft_val is not null then
    l_global_enb_rec.val := p_bnft_val;
  end if;
  -- Added for bug 4020061
  if p_bnft_val = 0 and p_enrt_bnft_id is null
  then
      l_global_enb_rec.val := null ;
      hr_utility.set_location(' new clause --- l_global_enb_rec.val' || l_global_enb_rec.val , 50);
  end if;

  if g_debug then
    hr_utility.set_location(l_proc, 50);
  end if;
  --
  -- if changing a result get old info
  --
  if g_debug then
    hr_utility.set_location('prtt_enrt_rslt_id'||p_prtt_enrt_rslt_id ,8086.1);
    hr_utility.set_location('new coverage date '||l_global_pil_rec.lf_evt_ocrd_dt ,8086.1);
  end if;
  if p_prtt_enrt_rslt_id is not null then
    if g_debug then
      hr_utility.set_location(l_proc,51);
    end if;
    open c_current_result_info(p_prtt_enrt_rslt_id);
    if g_debug then
      hr_utility.set_location(l_proc,52);
    end if;
    fetch c_current_result_info into
      l_old_enrt_cvg_strt_dt,
      l_old_enrt_cvg_thru_dt,
      l_old_bnft_val,
      l_old_pl_id,
      l_old_oipl_id,
      l_old_orgnl_enrt_dt,
      l_old_per_in_ler_id,
      l_old_ovn,
      l_old_erlst_deenrt_dt,
      l_old_enrt_ovrid_thru_dt,
      l_old_enrt_ovrid_rsn_cd,
      l_old_enrt_ovridn_flag,
      l_old_sspndd_flag ;
    if g_debug then
      hr_utility.set_location(l_proc,53);
      hr_utility.set_location(l_global_epe_rec.enrt_cvg_strt_dt,53);
    end if;
    if c_current_result_info%notfound then
       -- make sure it is not deleted for fiture coverage
          -- null globals to prevent bleeding
          --
          close c_current_result_info;
          --
          g_enrt_bnft_id:=null;
          g_bnft_val:=null;
          g_elig_per_elctbl_chc_id:=null;
          --
          if g_debug then
            hr_utility.set_location('BEN_91711_ENRT_RSLT_NOT_FND'|| to_char(p_prtt_enrt_rslt_id),54);
          end if;
          fnd_message.set_name('BEN','BEN_91711_ENRT_RSLT_NOT_FND');
          fnd_message.set_token('PROC',l_proc);
          fnd_message.set_token('ID', to_char(p_prtt_enrt_rslt_id));
          fnd_message.set_token('PERSON_ID', to_char(l_global_pil_rec.person_id));
          fnd_message.set_token('LER_ID', to_char(l_global_pil_rec.ler_id));
          fnd_message.set_token('EFFECTIVE_DATE',to_char(p_effective_date));
          fnd_message.raise_error;
    else
    --
    close c_current_result_info;
    --
    --IF NVL(ben_sspndd_enrollment.g_cfw_flag,'N') = 'N' THEN
      --
      -- BUG 5985777 This is the case where action items from the past life event
      -- are completed in future.
      --
      open c_pen_curr(p_prtt_enrt_rslt_id,l_global_pil_rec.lf_evt_ocrd_dt);
        fetch c_pen_curr into l_pen_curr;
      close c_pen_curr ;
      --
      IF l_pen_curr.sspndd_flag='Y' AND l_old_sspndd_flag='N' THEN
        --
        --This is the action item completion in future case.
        --
        ben_prtt_enrt_result_api.delete_prtt_enrt_result
              (p_validate                => false,
               p_prtt_enrt_rslt_id       => p_prtt_enrt_rslt_id,
               p_effective_start_date    => l_effective_start_date,
               p_effective_end_date      => l_effective_end_date,
               p_object_version_number   => l_pen_curr.object_version_number,
               p_effective_date          => l_pen_curr.effective_end_date,
               p_datetrack_mode          => hr_api.g_future_change,
               p_multi_row_validate      => FALSE);
        --
        for l_rec in c_prv(l_pen_curr.prtt_enrt_rslt_id,l_pen_curr.per_in_ler_id) loop
            --
            open c_ecr(l_rec.prtt_rt_val_id);
              fetch c_ecr into l_ecr;
            close c_ecr;
            -- if rate start date found.. use it else call bendetdt to compute the date
            IF l_ecr.rt_strt_dt IS NOT NULL THEN
              null ;
            ELSE
              --call bendetdt
              ben_determine_date.main(
               p_date_cd                => l_ecr.rt_strt_dt_cd,
               p_per_in_ler_id          => l_pen_curr.per_in_ler_id,  --Previous Per in ler
               p_person_id              => l_global_pil_rec.person_id,
               p_pgm_id                 => l_global_epe_rec.pgm_id,
               p_pl_id                  => l_global_epe_rec.pl_id,
               p_oipl_id                => l_global_epe_rec.oipl_id,
               p_business_group_id      => p_business_group_id,
               p_formula_id             => l_ecr.rt_strt_dt_rl,
               p_acty_base_rt_id        => l_rec.acty_base_rt_id,
               p_elig_per_elctbl_chc_id => l_ecr.elig_per_elctbl_chc_id,
               p_effective_date         => p_effective_date,
               p_returned_date          => l_ecr.rt_strt_dt
             );
              --
            END IF;
            --
            ben_prtt_rt_val_api.update_prtt_rt_val
              (p_validate                => false,
               p_person_id               => l_global_pil_rec.person_id,
               p_business_group_id       => p_business_group_id,
               p_prtt_rt_val_id          => l_rec.prtt_rt_val_id,
               p_rt_strt_dt              => nvl(l_ecr.rt_strt_dt,l_rec.rt_strt_dt),
               p_rt_end_dt               => hr_api.g_eot,
               p_object_version_number   => l_rec.object_version_number,
               p_effective_date          => p_effective_date );
            --
        end loop;
        --
        --Interim Enrollment
        --
        IF l_pen_curr.rplcs_sspndd_rslt_id is not null THEN
             --
             hr_utility.set_location(' Extend Interim Row',99);
             --
             open c_pen_curr(l_pen_curr.rplcs_sspndd_rslt_id,l_global_pil_rec.lf_evt_ocrd_dt);
                -- 6057157 : Changed the cursor variable to l_pen_curr_interim
               fetch c_pen_curr into l_pen_curr_interim;
             close c_pen_curr;
             --
             --
             hr_utility.set_location('l_pen_curr.prtt_enrt_rslt_id ' || l_pen_curr_interim.prtt_enrt_rslt_id,99);
             --
          IF l_pen_curr_interim.prtt_enrt_rslt_id IS NOT NULL THEN
               ben_prtt_enrt_result_api.delete_prtt_enrt_result
                (p_validate                => false,
                 p_prtt_enrt_rslt_id       => l_pen_curr_interim.prtt_enrt_rslt_id,
                 p_effective_start_date    => l_effective_start_date,
                 p_effective_end_date      => l_effective_end_date,
                 p_object_version_number   => l_pen_curr_interim.object_version_number,
                 p_effective_date          => l_pen_curr_interim.effective_end_date,
                 p_datetrack_mode          => hr_api.g_future_change,
                 p_multi_row_validate      => FALSE);
          END IF;
          --
            -- 6057157 : Reset the Rate End to EOT, as PEN records are done similarly above.
            --
            for l_rec in c_prv(l_pen_curr_interim.prtt_enrt_rslt_id, l_pen_curr_interim.per_in_ler_id)
            loop
                --
                hr_utility.set_location('Interim l_rec.prtt_rt_val_id ' || l_rec.prtt_rt_val_id,99);
                hr_utility.set_location('l_rec.rt_end_dt ' || l_rec.rt_end_dt,99);
                --
                ben_prtt_rt_val_api.update_prtt_rt_val
                  (p_validate                => false,
                   p_person_id               => l_global_pil_rec.person_id,
                   p_business_group_id       => p_business_group_id,
                   p_prtt_rt_val_id          => l_rec.prtt_rt_val_id,
                   p_rt_end_dt               => hr_api.g_eot,
                   p_object_version_number   => l_rec.object_version_number,
                   p_effective_date          => p_effective_date );
                --
            end loop;
          --
        END IF ;
        --
        open c_current_result_info(p_prtt_enrt_rslt_id);
        if g_debug then
          hr_utility.set_location(l_proc,52.2);
        end if;
        fetch c_current_result_info into
          l_old_enrt_cvg_strt_dt,
          l_old_enrt_cvg_thru_dt,
          l_old_bnft_val,
          l_old_pl_id,
          l_old_oipl_id,
          l_old_orgnl_enrt_dt,
          l_old_per_in_ler_id,
          l_old_ovn,
          l_old_erlst_deenrt_dt,
          l_old_enrt_ovrid_thru_dt,
          l_old_enrt_ovrid_rsn_cd,
          l_old_enrt_ovridn_flag,
          l_old_sspndd_flag ;
        close c_current_result_info;
        --
      END IF;
    --END IF;
    --
    -- begin bug 5621049
    /* when u r changing from 'option1 to option2' or 'plan1 to plan2' and 'option1 nd opton2' ,or , 'plan1 nd plan2'
    have same benefit amount then we should not compare the bnft amount of option1 nd option2 . for this bug
    param p_elig_per_elctbl_chc_id belongs to option2/plan2 and
    param p_prtt_enrt_rslt_id belongs to option1/plan1
    */
     if l_old_bnft_val is not NULL
     then
         open c_validate_epe_pen(p_elig_per_elctbl_chc_id,p_prtt_enrt_rslt_id);
         fetch c_validate_epe_pen into l_dummy_char;
            if c_validate_epe_pen%notfound then
               l_old_bnft_val := null;
             end if ;
          close c_validate_epe_pen;
      end if ;

      -- end bug 5621049

     end if;

    if g_debug then
      hr_utility.set_location(  p_prtt_enrt_rslt_id || ' '|| l_proc,55);
    end if;
    if l_old_ovn is not null then
      if g_debug then
        hr_utility.set_location(l_proc,56);
      end if;
      p_object_version_number:=l_old_ovn;
    end if;
    if g_debug then
      hr_utility.set_location(l_proc,57);
    end if;
    -- close c_current_result_info;
    if g_debug then
      hr_utility.set_location(l_proc,58);
    end if;
  end if;
  --
  -- Replacing sec 129 logic to start a new enrollment if the enrollment code is CCKCSNCC
  -- bendenrr populates the new coverage start date
  --
   if (  p_prtt_enrt_rslt_id is not null and
        l_global_epe_rec.prtt_enrt_rslt_id is not null and
        l_global_epe_rec.prtt_enrt_rslt_id=p_prtt_enrt_rslt_id and
        (( ben_sspndd_enrollment.g_use_new_result=false and
        nvl(l_old_bnft_val,hr_api.g_number)=
           nvl(l_global_enb_rec.val,hr_api.g_number)) or
         l_old_sspndd_flag = 'Y')) then
      if g_debug then
        hr_utility.set_location('enrt cvg strt dt'||l_global_epe_rec.enrt_cvg_strt_dt,111);
      end if;
      --bug#3702090 - override enrollment not to create new result
      --bug#4549089 - added per in ler for suspended enrollment
      --bug#4555320 - added per in ler for cvg strt dt also
      if ( (l_global_epe_rec.enrt_cvg_strt_dt <> l_old_enrt_cvg_strt_dt and
            l_old_per_in_ler_id <> l_global_epe_rec.per_in_ler_id)
            OR
           (l_old_sspndd_flag = 'Y' and l_old_per_in_ler_id <>
             l_global_epe_rec.per_in_ler_id))
            and nvl(p_enrt_mthd_cd, 'z') <> 'O' then
         if g_debug then
           hr_utility.set_location('start new result',112);
         end if;
         l_start_new_result := true;
	 /*Bug 9538592: Basing upon the flag set in reinstate enrollments call, set l_start_new_result
	 to true to create a new enrollment result*/
      else
           if(ben_lf_evt_clps_restore.g_create_new_result = 'Y' ) then
              hr_utility.set_location('start new result bcoz of reinstate',112);
              l_start_new_result := true;
	      ben_lf_evt_clps_restore.g_create_new_result := 'N';
           end if;
      end if;
   end if;

  -- if currently enrolled do an update, else create a new result.
  -- If the particpant is staying in the same plan and option, i.e.
  -- (ELIG PER ELCTBL CHC: CRNTLY ENRD FLAG = Y) do not
  -- write a new row.  Do update the  PRTT ENRT RSLT: ENRT MTHD CD
  -- to ENRT MTHD CD parameter (Currently, Explicit if updating from
  -- form or  Default if updatingfrom the default process).
  --
  -- If benefit amount changed treat as comp object change
  --
    if g_debug then
      hr_utility.set_location('l_global_epe_rec.enrt_cvg_strt_dt'||l_global_epe_rec.enrt_cvg_strt_dt,8086.1);
    end if;
    if g_debug then
      hr_utility.set_location('l_old_enrt_cvg_strt_dt'||l_old_enrt_cvg_strt_dt,8086.1);
    end if;
    if g_debug then
      hr_utility.set_location('l_global_epe_rec.erslt_deenrt_dt'||l_global_epe_rec.erlst_deenrt_dt,8086.1);
    end if;
    if g_debug then
      hr_utility.set_location('l_old_erlst_deenrt_dt '||l_old_erlst_deenrt_dt,8086.1);
    end if;
  if g_debug then
    hr_utility.set_location('l_old_bnft_val='||l_old_bnft_val,1963);
  end if;
  if g_debug then
    hr_utility.set_location('l_bnft_val='||l_global_enb_rec.val,1963);
  end if;
  --
  -- Added condition p_enrt_cvg_thru_dt is null. (maagrawa Jan 05,2001)
  -- p_enrt_cvg_thru_dt will be null in normal cases, but it will be populated
  -- when called from individual comp. api's when it is allowed to be enterable
  -- In such cases, we need to call delete_enrollment, to update the result
  -- with the new cvg_thru_dt.
  --
  if (  p_prtt_enrt_rslt_id is not null and
        l_global_epe_rec.prtt_enrt_rslt_id is not null and
        l_global_epe_rec.prtt_enrt_rslt_id=p_prtt_enrt_rslt_id and
        -- l_use_new_result=false and
        ben_sspndd_enrollment.g_use_new_result=false and /*ENH*/
        nvl(l_old_bnft_val,hr_api.g_number)= nvl(l_global_enb_rec.val,hr_api.g_number) and
        p_enrt_cvg_thru_dt is null  and
        l_start_new_result  = false ) then
    if g_debug then
      hr_utility.set_location(l_proc, 80);
    end if;
    --
    l_prtt_enrt_rslt_id:=p_prtt_enrt_rslt_id;
    --
    -- if sched mode and l_crnt_enrt_cvg_strt_dt is not null then
    -- see if plan has regulation of IRC Section 125 or 129.
    --

    if g_debug then
      hr_utility.set_location('if part ' , 8086.1);
    end if;

    l_regn_125_or_129_flag:='N';
   /*
    if l_global_pel_rec.enrt_perd_id is not null and -- same as p_run_mode='C'
       l_old_enrt_cvg_strt_dt is not null then
      open c_regn_125_or_129;
      fetch c_regn_125_or_129 into l_regn_125_or_129_flag;
      hr_utility. set_location('regn_125_or_129='||l_regn_125_or_129_flag,10);
      close c_regn_125_or_129;
    end if;
    */
    if l_regn_125_or_129_flag='N' then
      l_global_epe_rec.enrt_cvg_strt_dt:=l_old_enrt_cvg_strt_dt;
      l_global_epe_rec.erlst_deenrt_dt :=nvl(l_old_erlst_deenrt_dt,
                                             l_global_epe_rec.erlst_deenrt_dt);
    end if;
    --
    if l_global_epe_rec.enrt_cvg_strt_dt_cd = 'ENTRBL' and
       p_enrt_cvg_strt_dt is not null then
      l_global_epe_rec.enrt_cvg_strt_dt := p_enrt_cvg_strt_dt;
    end if;

    --
    --Bug 2600087
    open c_enrt_rslt;
    fetch c_enrt_rslt into l_enrt_rslt;
    if c_enrt_rslt%found then
       if g_debug then
         hr_utility.set_location('Effectve date'||l_enrt_rslt.effective_end_date,11);
       end if;
       if g_debug then
         hr_utility.set_location('object number '||l_enrt_rslt.object_version_number,11);
       end if;
       -- 3733745
       select count(*)
       into   l_interim_count
       from   ben_prtt_enrt_rslt_f pen
       where  pen.rplcs_sspndd_rslt_id = p_prtt_enrt_rslt_id
       and    nvl(pen.sspndd_flag , 'N') = 'Y'
       and    p_effective_date
             between pen.effective_start_date and pen.effective_end_date;
       if l_interim_count = 0 then
       -- end 3733745
       /* bug 5555269
       commented the 5032364 fix as well 5572484. This code became redundant after
       introduction of ben_reopen_ended_results.reopen_routine in benmngle
       package.
       */
       /*
       --bug#5032364
             open c_enrt_rslt2;
             fetch c_enrt_rslt2 into l_enrt_rslt2;
             close c_enrt_rslt2;
             --
             -- Bug 5572484 : Take backup in BEN_LE_CLSN_N_RSTR only if the correction
             --               is due to a new life event. E.g. If you de-enrol in a life
             --               event and again enrol in the same life event, then we need
             --               not take backup of the de-enrolled PEN
             --
             if nvl(l_old_per_in_ler_id, -999) <> l_global_epe_rec.per_in_ler_id
             then
               --
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
                    l_enrt_rslt2.COMP_LVL_CD,
                    l_enrt_rslt2.PEN_ATTRIBUTE16,
                    l_enrt_rslt2.PEN_ATTRIBUTE17,
                    l_enrt_rslt2.PEN_ATTRIBUTE18,
                    l_enrt_rslt2.PEN_ATTRIBUTE19,
                    l_enrt_rslt2.PEN_ATTRIBUTE20,
                    l_enrt_rslt2.PEN_ATTRIBUTE21,
                    l_enrt_rslt2.PEN_ATTRIBUTE22,
                    l_enrt_rslt2.PEN_ATTRIBUTE23,
                    l_enrt_rslt2.PEN_ATTRIBUTE24,
                    l_enrt_rslt2.PEN_ATTRIBUTE25,
                    l_enrt_rslt2.PEN_ATTRIBUTE26,
                    l_enrt_rslt2.PEN_ATTRIBUTE27,
                    l_enrt_rslt2.PEN_ATTRIBUTE28,
                    l_enrt_rslt2.PEN_ATTRIBUTE29,
                    l_enrt_rslt2.PEN_ATTRIBUTE30,
                    l_enrt_rslt2.LAST_UPDATE_DATE,
                    l_enrt_rslt2.LAST_UPDATED_BY,
                    l_enrt_rslt2.LAST_UPDATE_LOGIN,
                    l_enrt_rslt2.CREATED_BY,
                    l_enrt_rslt2.CREATION_DATE,
                    l_enrt_rslt2.REQUEST_ID,
                    l_enrt_rslt2.PROGRAM_APPLICATION_ID,
                    l_enrt_rslt2.PROGRAM_ID,
                    l_enrt_rslt2.PROGRAM_UPDATE_DATE,
                    l_enrt_rslt2.OBJECT_VERSION_NUMBER,
                    l_enrt_rslt2.PRTT_ENRT_RSLT_ID,
                    l_enrt_rslt2.EFFECTIVE_START_DATE,
                    l_enrt_rslt2.EFFECTIVE_END_DATE,
                    l_enrt_rslt2.ENRT_CVG_STRT_DT,
                    l_enrt_rslt2.ENRT_CVG_THRU_DT,
                    l_enrt_rslt2.SSPNDD_FLAG,
                    l_enrt_rslt2.PRTT_IS_CVRD_FLAG,
                    l_enrt_rslt2.BNFT_AMT,
                    l_enrt_rslt2.BNFT_NNMNTRY_UOM,
                    l_enrt_rslt2.BNFT_TYP_CD,
                    l_enrt_rslt2.UOM,
                    l_enrt_rslt2.ORGNL_ENRT_DT,
                    l_enrt_rslt2.ENRT_MTHD_CD,
                    l_enrt_rslt2.ENRT_OVRIDN_FLAG,
                    l_enrt_rslt2.ENRT_OVRID_RSN_CD,
                    l_enrt_rslt2.ERLST_DEENRT_DT,
                    l_enrt_rslt2.ENRT_OVRID_THRU_DT,
                    l_enrt_rslt2.NO_LNGR_ELIG_FLAG,
                    l_enrt_rslt2.BNFT_ORDR_NUM,
                    l_enrt_rslt2.PERSON_ID,
                    l_enrt_rslt2.ASSIGNMENT_ID,
                    l_enrt_rslt2.PGM_ID,
                    l_enrt_rslt2.PRTT_ENRT_RSLT_STAT_CD,
                    l_enrt_rslt2.PL_ID,
                    l_enrt_rslt2.OIPL_ID,
                    l_enrt_rslt2.PTIP_ID,
                    l_enrt_rslt2.PL_TYP_ID,
                    l_enrt_rslt2.LER_ID,
                    l_enrt_rslt2.PER_IN_LER_ID,
                    l_enrt_rslt2.RPLCS_SSPNDD_RSLT_ID,
                    l_enrt_rslt2.BUSINESS_GROUP_ID,
                    l_enrt_rslt2.PEN_ATTRIBUTE_CATEGORY,
                    l_enrt_rslt2.PEN_ATTRIBUTE1,
                    l_enrt_rslt2.PEN_ATTRIBUTE2,
                    l_enrt_rslt2.PEN_ATTRIBUTE3,
                    l_enrt_rslt2.PEN_ATTRIBUTE4,
                    l_enrt_rslt2.PEN_ATTRIBUTE5,
                    l_enrt_rslt2.PEN_ATTRIBUTE6,
                    l_enrt_rslt2.PEN_ATTRIBUTE7,
                    l_enrt_rslt2.PEN_ATTRIBUTE8,
                    l_enrt_rslt2.PEN_ATTRIBUTE9,
                    l_enrt_rslt2.PEN_ATTRIBUTE10,
                    l_enrt_rslt2.PEN_ATTRIBUTE11,
                    l_enrt_rslt2.PEN_ATTRIBUTE12,
                    l_enrt_rslt2.PEN_ATTRIBUTE13,
                    l_enrt_rslt2.PEN_ATTRIBUTE14,
                    l_enrt_rslt2.PEN_ATTRIBUTE15,
                    l_global_epe_rec.per_in_ler_id ,
                    l_enrt_rslt2.PL_ORDR_NUM,
                    l_enrt_rslt2.PLIP_ORDR_NUM,
                    l_enrt_rslt2.PTIP_ORDR_NUM,
                    l_enrt_rslt2.OIPL_ORDR_NUM
                );
               --
             end if;
             --
	     */
	      -- end of bug 5555269

          ben_prtt_enrt_result_api.delete_prtt_enrt_result
              (p_validate                => false,
               p_prtt_enrt_rslt_id       => p_prtt_enrt_rslt_id,
               p_effective_start_date    => l_effective_start_date,
               p_effective_end_date      => l_effective_end_date,
               p_object_version_number   => l_enrt_rslt.object_version_number,
               p_effective_date          => l_enrt_rslt.effective_end_date,
               p_datetrack_mode          => hr_api.g_future_change,
               p_multi_row_validate      => FALSE);
      p_object_version_number := l_enrt_rslt.object_version_number;
      --
      --  Bug 5766477  Also re-open dependent coverage.
      --
      for l_dpnt_rec in  c_get_dpnt(l_enrt_rslt.effective_end_date) loop
      ben_elig_cvrd_dpnt_api.delete_elig_cvrd_dpnt
        (p_validate                => false,
         p_elig_cvrd_dpnt_id       => l_dpnt_rec.elig_cvrd_dpnt_id,
         p_effective_start_date    => l_effective_start_date,
         p_effective_end_date      => l_effective_end_date,
         p_object_version_number   => l_dpnt_rec.object_version_number,
         p_business_group_id       => p_business_group_id,
         p_effective_date          => l_enrt_rslt.effective_end_date,
         p_datetrack_mode          => hr_api.g_future_change,
         p_multi_row_actn          => FALSE);
      end loop;

      if (g_debug) then
          hr_utility.set_location('BKKK p_prtt_enrt_rslt_id '|| p_prtt_enrt_rslt_id, 100);
      end if;
      --
      open c_prtt_rt_val_id;
      fetch c_prtt_rt_val_id into l_prtt_rt_val_id, l_acty_base_rt_id2;
      loop
        if c_prtt_rt_val_id%notfound then
           exit;
        end if;
        --
        if (g_debug) then
            hr_utility.set_location('BKKK l_prtt_rt_val_id '|| l_prtt_rt_val_id, 100);
            hr_utility.set_location('BKKK l_acty_base_rt_id2 '|| l_acty_base_rt_id2, 100);
            hr_utility.set_location('BKKK p_elig_per_elctbl_chc_id  '|| p_elig_per_elctbl_chc_id, 100);
            hr_utility.set_location('BKKK p_enrt_bnft_id '|| p_enrt_bnft_id, 100);
            hr_utility.set_location('BKKK l_enrt_rt_id '|| l_enrt_rt_id, 100);
        end if;
        --
        open c_enrt_rt(l_acty_base_rt_id2);
        fetch c_enrt_rt into l_enrt_rt_id;
        if c_enrt_rt%found then
          update ben_enrt_rt
               set prtt_rt_val_id = l_prtt_rt_val_id
          where enrt_rt_id = l_enrt_rt_id;
          --
          if (g_debug) then
            hr_utility.set_location('BKKK l_enrt_rt_id '|| l_enrt_rt_id, 200);
          end if;
          --
        end if;
        close c_enrt_rt;
        fetch c_prtt_rt_val_id into l_prtt_rt_val_id, l_acty_base_rt_id2;
      end loop;

      close c_prtt_rt_val_id;
      --
      --
      end if ;--l_interim_count > 0--3733745
    end if;
    close c_enrt_rslt;
    --
    if g_debug then
      hr_utility.set_location('bef update cvg '|| l_global_epe_rec.enrt_cvg_strt_dt,8086.2);
    end if;
    if g_debug then
      hr_utility.set_location('bef update erly '||l_global_epe_rec.erlst_deenrt_dt,8086.2);
    end if;
    --Override code
    if l_old_enrt_ovrid_thru_dt is not null then
      --
      if g_debug then
        hr_utility.set_location(' enrt_cvg_strt_dt_cd '||l_global_epe_rec.enrt_cvg_strt_dt_cd,123);
      end if;
      if g_debug then
        hr_utility.set_location(' p_elig_per_elctbl_chc_id '||p_elig_per_elctbl_chc_id,123);
      end if;
      if l_global_epe_rec.enrt_cvg_strt_dt_cd is not null then
        ben_determine_date.main(
          p_date_cd            => l_global_epe_rec.enrt_cvg_strt_dt_cd,
          p_per_in_ler_id      => l_global_epe_rec.per_in_ler_id,
          p_person_id          => l_global_pil_rec.person_id,
          p_pgm_id             => l_global_epe_rec.pgm_id,
          p_pl_id              => l_global_epe_rec.pl_id,
          p_oipl_id            => l_global_epe_rec.oipl_id,
          p_business_group_id  => l_global_epe_rec.business_group_id,
          p_formula_id         => l_global_epe_rec.enrt_cvg_strt_dt_rl,
          p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id,
          p_effective_date     => p_effective_date,
          p_returned_date      => l_new_cvg_strt_dt
          );
      else
        --
        l_new_cvg_strt_dt := l_global_pil_rec.lf_evt_ocrd_dt ;
        --
      end if;
      --
      if l_new_cvg_strt_dt > l_old_enrt_ovrid_thru_dt then
        --
        l_old_enrt_ovrid_thru_dt := null;
        l_old_enrt_ovrid_rsn_cd  := null;
        l_old_enrt_ovridn_flag   := 'N';
        --
      end if;
    end if;
    -- end overrdie code

    ----------Bug 7374973
    open c_unrestricted(l_global_pil_rec.ler_id);
    fetch c_unrestricted into l_unrestricted;
    close c_unrestricted;
    ------write to extract log
    hr_utility.set_location('l_unrestricted : '||l_unrestricted.typ_cd,1);
    if l_unrestricted.typ_cd = 'SCHEDDU' then
    ben_ext_chlg.log_benefit_chg
          (p_action                      =>  'REINSTATE'
          ,p_pl_id                       =>  l_global_epe_rec.pl_id
          ,p_old_pl_id                   =>  l_old_pl_id
          ,p_oipl_id                     =>  l_global_epe_rec.oipl_id
          ,p_old_oipl_id                 =>  l_old_oipl_id
          ,p_old_bnft_amt                =>  l_old_bnft_val
          ,p_bnft_amt                    =>  l_global_enb_rec.val
          ,p_enrt_cvg_strt_dt            =>  l_global_epe_rec.enrt_cvg_strt_dt
          ,p_enrt_cvg_end_dt             =>  hr_api.g_eot
          ,p_prtt_enrt_rslt_id           =>  l_prtt_enrt_rslt_id
          ,p_per_in_ler_id               =>  l_global_epe_rec.per_in_ler_id
          ,p_person_id                   =>  l_global_pil_rec.person_id
          ,p_business_group_id           =>  l_global_epe_rec.business_group_id
          ,p_effective_date              =>  p_effective_date
          );
    end if;
    -----Bug 7374973
    ben_PRTT_ENRT_RESULT_api.update_enrollment(
          p_prtt_enrt_rslt_id        => p_prtt_enrt_rslt_id
        ,p_effective_start_date      => p_effective_start_date
        ,p_effective_end_date        => p_effective_end_date
        ,p_enrt_mthd_cd              => p_enrt_mthd_cd
        ,p_enrt_cvg_strt_dt          => l_global_epe_rec.enrt_cvg_strt_dt
        ,p_enrt_cvg_thru_dt          => hr_api.g_eot
        ,p_enrt_ovrid_thru_dt        => l_old_enrt_ovrid_thru_dt
        ,p_enrt_ovrid_rsn_cd         => l_old_enrt_ovrid_rsn_cd
        ,p_enrt_ovridn_flag          => l_old_enrt_ovridn_flag
        ,p_object_version_number     => p_object_version_number
        ,p_effective_date            => p_effective_date
        ,p_datetrack_mode            => p_datetrack_mode
        ,p_pgm_id                    => l_global_epe_rec.pgm_id
        ,p_ptip_id                   => l_global_epe_rec.ptip_id
        ,p_pl_typ_id                 => l_global_epe_rec.pl_typ_id
        ,p_pl_id                     => l_global_epe_rec.pl_id
        ,p_oipl_id                   => l_global_epe_rec.oipl_id
        ,p_enrt_bnft_id              => p_enrt_bnft_id
        ,p_business_group_id         => p_business_group_id
        ,p_erlst_deenrt_dt           => l_global_epe_rec.erlst_deenrt_dt
        ,p_per_in_ler_id             => l_global_epe_rec.per_in_ler_id
--        ,p_sspndd_flag               => nvl(l_old_sspndd_flag,'N')          --Bug#5099296
        ,p_sspndd_flag               => nvl(l_global_pen_rec.sspndd_flag,'N') --Bug#5099296
        ,p_multi_row_validate        => FALSE

      -- derive from per_in_ler_id
        ,p_ler_id                    =>  l_global_pil_rec.ler_id
        ,p_person_id                 =>  l_global_pil_rec.person_id
        ,p_bnft_amt                  =>  l_global_enb_rec.val
        ,p_uom                       =>  l_global_pel_rec.uom
        ,p_bnft_nnmntry_uom          =>  l_global_enb_rec.nnmntry_uom
        ,p_bnft_typ_cd               =>  l_global_enb_rec.bnft_typ_cd
        ,p_bnft_ordr_num             =>  l_global_enb_rec.ordr_num
        ,p_suspend_flag              =>  p_suspend_flag
        ,p_prtt_enrt_interim_id      =>  l_prtt_enrt_interim_id
	,p_comp_lvl_cd               =>  l_global_pen_rec.comp_lvl_cd -- bug 5417132
        ,p_program_application_id    => fnd_global.prog_appl_id
        ,p_program_id                => fnd_global.conc_program_id
        ,p_request_id                => fnd_global.conc_request_id
        ,p_program_update_date       => sysdate
        ,p_pen_attribute_category    => p_pen_attribute_category
        ,p_pen_attribute1            => p_pen_attribute1
        ,p_pen_attribute2            => p_pen_attribute2
        ,p_pen_attribute3            => p_pen_attribute3
        ,p_pen_attribute4            => p_pen_attribute4
        ,p_pen_attribute5            => p_pen_attribute5
        ,p_pen_attribute6            => p_pen_attribute6
        ,p_pen_attribute7            => p_pen_attribute7
        ,p_pen_attribute8            => p_pen_attribute8
        ,p_pen_attribute9            => p_pen_attribute9
        ,p_pen_attribute10           => p_pen_attribute10
        ,p_pen_attribute11           => p_pen_attribute11
        ,p_pen_attribute12           => p_pen_attribute12
        ,p_pen_attribute13           => p_pen_attribute13
        ,p_pen_attribute14           => p_pen_attribute14
        ,p_pen_attribute15           => p_pen_attribute15
        ,p_pen_attribute16           => p_pen_attribute16
        ,p_pen_attribute17           => p_pen_attribute17
        ,p_pen_attribute18           => p_pen_attribute18
        ,p_pen_attribute19           => p_pen_attribute19
        ,p_pen_attribute20           => p_pen_attribute20
        ,p_pen_attribute21           => p_pen_attribute21
        ,p_pen_attribute22           => p_pen_attribute22
        ,p_pen_attribute23           => p_pen_attribute23
        ,p_pen_attribute24           => p_pen_attribute24
        ,p_pen_attribute25           => p_pen_attribute25
        ,p_pen_attribute26           => p_pen_attribute26
        ,p_pen_attribute27           => p_pen_attribute27
        ,p_pen_attribute28           => p_pen_attribute28
        ,p_pen_attribute29           => p_pen_attribute29
        ,p_pen_attribute30           => p_pen_attribute30
        ,p_dpnt_actn_warning         => l_dpnt_actn_warning
        ,p_bnf_actn_warning          => l_bnf_actn_warning
        ,p_ctfn_actn_warning         => l_ctfn_actn_warning
    );
    p_prtt_enrt_interim_id:=l_prtt_enrt_interim_id;
    if g_debug then
      hr_utility.set_location(l_proc, 90);
    end if;
  --
  -- (maagrawa Jan 05,2001).
  -- Replaced this else with elsif. Normal processing will go as normal as
  -- the p_enrt_cvg_thru_dt will be null.
  -- The additional condition has been added to handle special case in
  -- Individual Comp. when the user enters both the coverage start date
  -- and the coverage through date when creating the result for the
  -- first time. In this case, we want to create a new enrollment and
  -- call delete enrollment in the end to update the coverage through date.
  -- If the result_id already exists and the enrt_thru_dt is not null, it means
  -- we do not have to create a new result, we need to just update the
  -- result record with the entered coverage through date, which will be
  -- done when delete_enrollment is called at the end.
  --
  elsif (l_global_epe_rec.prtt_enrt_rslt_id is null or
         p_enrt_cvg_thru_dt is null) then
    --
    if g_debug then
      hr_utility.set_location('elese part ' , 8086.1);
    end if;
    l_crntly_enrd_rslt_exists := false;
    --
    if l_global_epe_rec.prtt_enrt_rslt_id is not null then
      open  c_current_result_info(l_global_epe_rec.prtt_enrt_rslt_id);
      fetch c_current_result_info into l_crntly_enrd_rslt_rec;
      if c_current_result_info%found then
        l_crntly_enrd_rslt_exists := true;
      end if;
      close c_current_result_info;
    end if;
    --
    --Override code
    if l_crntly_enrd_rslt_rec.enrt_ovrid_thru_dt is not null then
      --
      if l_global_epe_rec.enrt_cvg_strt_dt_cd is not null then
        --
        ben_determine_date.main(
          p_date_cd            => l_global_epe_rec.enrt_cvg_strt_dt_cd,
          p_per_in_ler_id      => l_global_epe_rec.per_in_ler_id,
          p_person_id          => l_global_pil_rec.person_id,
          p_pgm_id             => l_global_epe_rec.pgm_id,
          p_pl_id              => l_global_epe_rec.pl_id,
          p_oipl_id            => l_global_epe_rec.oipl_id,
          p_business_group_id  => l_global_epe_rec.business_group_id,
          p_formula_id         => l_global_epe_rec.enrt_cvg_strt_dt_rl,
          p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id,
          p_effective_date     => p_effective_date,
          p_returned_date      => l_new_cvg_strt_dt
        );
        --
      else
        --
        l_new_cvg_strt_dt := l_global_pil_rec.lf_evt_ocrd_dt ;
        --
      end if;
      --
      if l_new_cvg_strt_dt > l_crntly_enrd_rslt_rec.enrt_ovrid_thru_dt then
        --
        l_crntly_enrd_rslt_rec.enrt_ovrid_thru_dt := null;
        l_crntly_enrd_rslt_rec.enrt_ovrid_rsn_cd  := null;
        l_crntly_enrd_rslt_rec.enrt_ovridn_flag   := 'N';
        --
      end if;
      --
    end if;
    -- end overrdie code
    --
    if l_global_epe_rec.crntly_enrd_flag = 'Y' and
       l_global_epe_rec.prtt_enrt_rslt_id is not null and
       l_crntly_enrd_rslt_exists and
       -- l_use_new_result=false and
       ben_sspndd_enrollment.g_use_new_result=false and /*ENH*/
       nvl(l_crntly_enrd_rslt_rec.bnft_amt,hr_api.g_number)=
           nvl(l_global_enb_rec.val,hr_api.g_number) and
       /* Bug 4954541 - We also need to check if old coverage was non-null and new coverage is null
       nvl(l_crntly_enrd_rslt_rec.bnft_amt,hr_api.g_number)=
           nvl(l_global_enb_rec.val,nvl(l_crntly_enrd_rslt_rec.bnft_amt,
                                            hr_api.g_number)) and
       */
       l_start_new_result = false and
       l_global_epe_rec.enrt_cvg_strt_dt = l_crntly_enrd_rslt_rec.enrt_cvg_strt_dt then  --BUG 4568911
      -- RCHASE Bug#5353 alteration
      --     nvl(l_global_enb_rec.val,hr_api.g_number) then
      --
      -- If they are not staying in the same plan and option
      --  and ELIG PER ELCTBL CHC: CRNTLY ENRD FLAG = Y  then
      -- re-use the enrollment result.
      --
      if g_debug then
        hr_utility.set_location(l_proc, 95);
      end if;
      --
      l_prtt_enrt_rslt_id     := l_global_epe_rec.prtt_enrt_rslt_id;
      --
      -- if sched mode and l_crnt_enrt_cvg_strt_dt is not null then
      -- see if plan has regulation of IRC Section 125 or 129.
      --
      l_regn_125_or_129_flag:='N';
     /*
      if l_global_pel_rec.enrt_perd_id is not null and -- same as p_run_mode='C'
         l_old_enrt_cvg_strt_dt is not null then
        open c_regn_125_or_129;
        fetch c_regn_125_or_129 into l_regn_125_or_129_flag;
        hr_utility. set_location('regn_125_or_129='||l_regn_125_or_129_flag,10);
        close c_regn_125_or_129;
      end if;
    */
      if l_regn_125_or_129_flag='N' then
        l_global_epe_rec.enrt_cvg_strt_dt:= l_crntly_enrd_rslt_rec.enrt_cvg_strt_dt;
        l_global_epe_rec.erlst_deenrt_dt := nvl(l_crntly_enrd_rslt_rec.erlst_deenrt_dt,
                                                l_global_epe_rec.erlst_deenrt_dt);
      end if;
      --
      if l_global_epe_rec.enrt_cvg_strt_dt_cd = 'ENTRBL' and
         p_enrt_cvg_strt_dt is not null then
        l_global_epe_rec.enrt_cvg_strt_dt := p_enrt_cvg_strt_dt;
      end if;
      --
      l_object_version_number := l_crntly_enrd_rslt_rec.object_version_number;
      --
      if g_debug then
        hr_utility.set_location('bef update cvg '|| l_global_epe_rec.enrt_cvg_strt_dt,8086.2);
      end if;
      if g_debug then
        hr_utility.set_location('bef update erly '||l_global_epe_rec.erlst_deenrt_dt,8086.2);
      end if;
      ----Bug 9139820
      open c_get_pil_enrt( l_global_epe_rec.prtt_enrt_rslt_id,l_global_epe_rec.per_in_ler_id,
                                  l_global_epe_rec.enrt_cvg_strt_dt);
      fetch c_get_pil_enrt into l_check_enrt_same_pil;
      close c_get_pil_enrt;
      hr_utility.set_location('l_check_enrt_same_pil.pen ID '||l_check_enrt_same_pil.prtt_enrt_rslt_id,8086.2);
      if l_check_enrt_same_pil.prtt_enrt_rslt_id is not null then
            ---- Bug 9430735,fetch the per_in_ler_id which has the enrt rslt corresponding to pen.
      /*   open c_prev_pil(l_global_pil_rec.person_id);
	 fetch c_prev_pil into l_prev_pil;
	 if c_prev_pil%found then*/
	 open c_prev_pil_with_pen(l_global_pil_rec.person_id,l_check_enrt_same_pil.prtt_enrt_rslt_id);
	 fetch c_prev_pil_with_pen into l_prev_pil;
	 if c_prev_pil_with_pen%found then
	    hr_utility.set_location('previous pil found',2);
	    open c_get_pil_enrt(l_check_enrt_same_pil.prtt_enrt_rslt_id,l_prev_pil.per_in_ler_id,l_check_enrt_same_pil.enrt_cvg_strt_dt);
	    fetch c_get_pil_enrt into l_get_prev_pil_enrt;
	    if c_get_pil_enrt%found then
	       hr_utility.set_location('previous enr found',2);
               ben_prtt_enrt_result_api.delete_prtt_enrt_result
                (p_validate                => false,
                 p_prtt_enrt_rslt_id       => l_get_prev_pil_enrt.prtt_enrt_rslt_id,
                 p_effective_start_date    => l_effective_start_date,
                 p_effective_end_date      => l_effective_end_date,
                 p_object_version_number   => l_get_prev_pil_enrt.object_version_number,
                 p_effective_date          => l_get_prev_pil_enrt.effective_start_date,
                 p_datetrack_mode          => hr_api.g_future_change,
                 p_multi_row_validate      => FALSE);

	    ---Refetch the enrollment result for the Object version number.
	       open c_get_ovn(l_check_enrt_same_pil.prtt_enrt_rslt_id,l_prev_pil.per_in_ler_id,l_get_prev_pil_enrt.effective_start_date);
	       fetch c_get_ovn into l_object_version_number;
	       close c_get_ovn;
	       hr_utility.set_location('l_object_version_number,del pen : '||l_object_version_number,99.3);

	  else
	       --check if any correction record exists in the back-up table.
	       hr_utility.set_location('else part prev enr',99);
               open c_bkup_pen_rec(l_check_enrt_same_pil.prtt_enrt_rslt_id,l_prev_pil.per_in_ler_id,l_check_enrt_same_pil.person_id,
	                           l_check_enrt_same_pil.effective_start_date,l_check_enrt_same_pil.enrt_cvg_strt_dt);
	       fetch c_bkup_pen_rec into l_bkup_pen_rec;
	       if c_bkup_pen_rec%found then
	          hr_utility.set_location('bkup record found : ' || l_object_version_number,99);

		  --Update the pen record with the current pil to previous pil
	          ben_prtt_enrt_result_api.update_prtt_enrt_result
			(p_validate                => FALSE
			,p_prtt_enrt_rslt_id       => l_check_enrt_same_pil.prtt_enrt_rslt_id
			,p_effective_start_date    => l_effective_start_date
			,p_effective_end_date      => l_effective_end_date
			,p_per_in_ler_id           => l_bkup_pen_rec.per_in_ler_id
			,p_enrt_cvg_thru_dt        => l_bkup_pen_rec.enrt_cvg_thru_dt
			,p_object_version_number   => l_check_enrt_same_pil.object_version_number
			,p_effective_date          => l_bkup_pen_rec.effective_start_date
			,p_datetrack_mode          => 'CORRECTION'
			,p_business_group_id       => p_business_group_id
			,p_multi_row_validate      => FALSE );
		  ---Refetch the enrollment result for the Object version number.
	       open c_get_ovn(l_check_enrt_same_pil.prtt_enrt_rslt_id,l_prev_pil.per_in_ler_id,l_check_enrt_same_pil.effective_start_date);
	       fetch c_get_ovn into l_object_version_number;
	       close c_get_ovn;
	       hr_utility.set_location('l_object_version_number,upd pen : '||l_object_version_number,99.1);
	       end if;
	       close c_bkup_pen_rec;
	     end if;
	    close c_get_pil_enrt;

	 end if;
	 /*close c_prev_pil; */ ---Bug 9430735
	 close c_prev_pil_with_pen;
        end if;
      ----End of Bug 9139820
      ben_PRTT_ENRT_RESULT_api.update_enrollment(
           p_prtt_enrt_rslt_id         => l_prtt_enrt_rslt_id
          ,p_effective_start_date      => p_effective_start_date
          ,p_effective_end_date        => p_effective_end_date
          ,p_enrt_mthd_cd              => p_enrt_mthd_cd
          ,p_enrt_cvg_strt_dt          => l_global_epe_rec.enrt_cvg_strt_dt
          ,p_enrt_cvg_thru_dt          => hr_api.g_eot
          ,p_enrt_ovrid_thru_dt        => l_crntly_enrd_rslt_rec.enrt_ovrid_thru_dt
          ,p_enrt_ovrid_rsn_cd         => l_crntly_enrd_rslt_rec.enrt_ovrid_rsn_cd
          ,p_enrt_ovridn_flag          => l_crntly_enrd_rslt_rec.enrt_ovridn_flag
          ,p_object_version_number     => l_object_version_number
          ,p_effective_date            => p_effective_date
          ,p_datetrack_mode            => p_datetrack_mode
          ,p_pgm_id                    => l_global_epe_rec.pgm_id
          ,p_ptip_id                   => l_global_epe_rec.ptip_id
          ,p_pl_typ_id                 => l_global_epe_rec.pl_typ_id
          ,p_pl_id                     => l_global_epe_rec.pl_id
          ,p_oipl_id                   => l_global_epe_rec.oipl_id
          ,p_enrt_bnft_id              => p_enrt_bnft_id
          ,p_business_group_id         => l_global_epe_rec.business_group_id
          ,p_erlst_deenrt_dt           => l_global_epe_rec.erlst_deenrt_dt
          ,p_per_in_ler_id             => l_global_epe_rec.per_in_ler_id
--          ,p_sspndd_flag               => nvl(l_old_sspndd_flag,'N')        --Bug#5099296
        ,p_sspndd_flag               => nvl(l_global_pen_rec.sspndd_flag,'N') --Bug#5099296
          ,p_multi_row_validate        => FALSE

        -- derive from per_in_ler_id
          ,p_ler_id                    =>  l_global_pil_rec.ler_id
          ,p_person_id                 =>  l_global_pil_rec.person_id
          ,p_bnft_amt                  =>  l_global_enb_rec.val
        ,p_uom                       =>  l_global_pel_rec.uom
        ,p_bnft_nnmntry_uom          =>  l_global_enb_rec.nnmntry_uom
        ,p_bnft_typ_cd               =>  l_global_enb_rec.bnft_typ_cd
        ,p_bnft_ordr_num             =>  l_global_enb_rec.ordr_num
          ,p_suspend_flag              =>  p_suspend_flag
          ,p_prtt_enrt_interim_id      =>  l_prtt_enrt_interim_id
	  ,p_comp_lvl_cd               =>  l_global_pen_rec.comp_lvl_cd  -- 5417132
          ,p_program_application_id    => fnd_global.prog_appl_id
          ,p_program_id                => fnd_global.conc_program_id
          ,p_request_id                => fnd_global.conc_request_id
          ,p_program_update_date       => sysdate
          ,p_pen_attribute_category    => p_pen_attribute_category
          ,p_pen_attribute1            => p_pen_attribute1
          ,p_pen_attribute2            => p_pen_attribute2
          ,p_pen_attribute3            => p_pen_attribute3
          ,p_pen_attribute4            => p_pen_attribute4
          ,p_pen_attribute5            => p_pen_attribute5
          ,p_pen_attribute6            => p_pen_attribute6
          ,p_pen_attribute7            => p_pen_attribute7
          ,p_pen_attribute8            => p_pen_attribute8
          ,p_pen_attribute9            => p_pen_attribute9
          ,p_pen_attribute10           => p_pen_attribute10
          ,p_pen_attribute11           => p_pen_attribute11
          ,p_pen_attribute12           => p_pen_attribute12
          ,p_pen_attribute13           => p_pen_attribute13
          ,p_pen_attribute14           => p_pen_attribute14
          ,p_pen_attribute15           => p_pen_attribute15
          ,p_pen_attribute16           => p_pen_attribute16
          ,p_pen_attribute17           => p_pen_attribute17
          ,p_pen_attribute18           => p_pen_attribute18
          ,p_pen_attribute19           => p_pen_attribute19
          ,p_pen_attribute20           => p_pen_attribute20
          ,p_pen_attribute21           => p_pen_attribute21
          ,p_pen_attribute22           => p_pen_attribute22
          ,p_pen_attribute23           => p_pen_attribute23
          ,p_pen_attribute24           => p_pen_attribute24
          ,p_pen_attribute25           => p_pen_attribute25
          ,p_pen_attribute26           => p_pen_attribute26
          ,p_pen_attribute27           => p_pen_attribute27
          ,p_pen_attribute28           => p_pen_attribute28
          ,p_pen_attribute29           => p_pen_attribute29
          ,p_pen_attribute30           => p_pen_attribute30
          ,p_dpnt_actn_warning         => l_dpnt_actn_warning
          ,p_bnf_actn_warning          => l_bnf_actn_warning
          ,p_ctfn_actn_warning         => l_ctfn_actn_warning
      );
      p_prtt_enrt_interim_id:=l_prtt_enrt_interim_id; --CFW
      -- RCHASE Bug#5353 No interim is being passed back
      l_prtt_enrt_interim_id:=nvl(l_prtt_enrt_interim_id,l_prtt_enrt_rslt_id); --CFW
      if g_debug then
        hr_utility.set_location(l_proc, 97);
      end if;
      -- Bug 2627078 fixes
      -- Now If the User selected the Interim as the Main enrollment while
      -- replacing the suspended enrollment, delink the interim from the
      -- suspended enrollment which is going to get deleted. So that it
      -- can become the original enrollment
      open c_delink_interim(l_global_epe_rec.prtt_enrt_rslt_id,p_prtt_enrt_rslt_id );
        fetch c_delink_interim into
              l_delink_interim.prtt_enrt_rslt_id,
              l_delink_interim.object_version_number ;
        if c_delink_interim%found then
            ben_prtt_enrt_result_api.update_prtt_enrt_result
              (p_validate                 => FALSE,
               p_prtt_enrt_rslt_id        => l_delink_interim.prtt_enrt_rslt_id,
               p_effective_start_date     => l_dlink_effective_start_date,
               p_effective_end_date       => l_dlink_effective_end_date,
               p_business_group_id        => p_business_group_id,
               p_RPLCS_SSPNDD_RSLT_ID     => null,
               p_object_version_number    => l_delink_interim.object_version_number,
               p_effective_date           => p_effective_date,
               p_datetrack_mode           => hr_api.g_correction,
               p_multi_row_validate       => FALSE,
               p_program_application_id   => fnd_global.prog_appl_id,
               p_program_id               => fnd_global.conc_program_id,
               p_request_id               => fnd_global.conc_request_id,
               p_program_update_date      => sysdate);
            --
            p_object_version_number := l_delink_interim.object_version_number ;
        end if ;
      close c_delink_interim ;
    else
      if g_debug then
        hr_utility.set_location(l_proc, 100);
      end if;
      -- If they are not staying in the same plan and option
      -- (ELIG PER ELCTBL CHC: CRNTLY ENRD FLAG = N) and
      -- no replacement result is specified, then create a new
      -- enrolment.

      -- need to create a new result

      -- first, resolve previously unknown values.

      if (l_global_epe_rec.enrt_cvg_strt_dt_cd is not null) then
        if g_debug then
          hr_utility.set_location(l_proc, 130);
        end if;
        l_elect_cvg_strt_dt   := l_global_epe_rec.enrt_cvg_strt_dt    ;
        --
        if l_global_epe_rec.enrt_cvg_strt_dt_cd = 'ENTRBL' and
           p_enrt_cvg_strt_dt is not null then
          l_global_epe_rec.enrt_cvg_strt_dt := p_enrt_cvg_strt_dt;
        end if;
        --


        ben_determine_date.main(
          p_date_cd            => l_global_epe_rec.enrt_cvg_strt_dt_cd,
          p_per_in_ler_id      => l_global_epe_rec.per_in_ler_id,
          p_person_id          => l_global_pil_rec.person_id,
          p_pgm_id             => l_global_epe_rec.pgm_id,
          p_pl_id              => l_global_epe_rec.pl_id,
          p_oipl_id            => l_global_epe_rec.oipl_id,
          p_business_group_id  => l_global_epe_rec.business_group_id,
          p_formula_id         => l_global_epe_rec.enrt_cvg_strt_dt_rl,
          p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id,
          p_effective_date     => p_effective_date,
        --  p_returned_date      => l_global_epe_rec.enrt_cvg_strt_dt
          p_returned_date      => l_enrt_cvg_strt_dt
        );

       if g_debug then
           hr_utility.set_location('calc date' || l_enrt_cvg_strt_dt,8086.1);
           hr_utility.set_location('prev calc date' || l_global_epe_rec.enrt_cvg_strt_dt,8086.1);
       end if;
       -- 2982606 when the first time enrolled in waiting plan,after save thge enrollment the date changed back to
       --even date
       if l_enrt_cvg_strt_dt > l_global_epe_rec.enrt_cvg_strt_dt
          -- if the coverage start dt code is election then take the current cacluated code
          OR l_global_epe_rec.enrt_cvg_strt_dt_cd in  ('ODEWM','AFDELD','FDMELD')  then
           l_global_epe_rec.enrt_cvg_strt_dt := l_enrt_cvg_strt_dt;
           hr_utility.set_location('after comparison  calc date' || l_global_epe_rec.enrt_cvg_strt_dt,8086.1);
       end if;


        if g_debug then
           hr_utility.set_location('denrt at elec' ||l_global_epe_rec.erlst_deenrt_dt,8086.1);
         end if;
         if g_debug then
           hr_utility.set_location('prt rslt deent '||l_old_erlst_deenrt_dt , 8086.1);
         end if;
         if g_debug then
           hr_utility.set_location('before calc cvg'||l_elect_cvg_strt_dt,8086.1);
         end if;

        ---calcualte the function to call the erls_denrt_dt
        --- l_old_erlst_deenrt_dt is decide the previous enrolment
        -- bal_epe_rec.epe.erlst_deenrt_dt decide the whether erlst_deenrt_dt is to be calc
        if l_old_erlst_deenrt_dt is null and
           l_global_epe_rec.erlst_deenrt_dt is not null and
           nvl(l_elect_cvg_strt_dt,hr_api.g_eot)
                  <> l_global_epe_rec.enrt_cvg_strt_dt  then
           if g_debug then
             hr_utility.set_location('CALLINGH ERLST DATE ' , 8086.1);
           end if;
           determine_erlst_deenrt_date(p_oipl_id        => l_global_epe_rec.oipl_id,
                                 p_pl_id                => l_global_epe_rec.pl_id,
                                 p_pl_typ_id            => l_global_epe_rec.pl_typ_id ,
                                 p_ptip_id              => l_global_epe_rec.ptip_id,
                                 p_pgm_id               => l_global_epe_rec.pgm_id,
                                 p_ler_id               => l_global_pil_rec.ler_id ,
                                 p_effective_date       => p_effective_date,
                                 p_business_group_id    => p_business_group_id,
                                 p_orgnl_enrt_dt        => l_old_orgnl_enrt_dt,
                                 p_person_id            => l_global_pil_rec.person_id,
                                 p_lf_evt_ocrd_dt       => p_effective_date,
                                 p_enrt_cvg_strt_dt     => l_global_epe_rec.enrt_cvg_strt_dt,
                                 p_return_date          => l_global_epe_rec.erlst_deenrt_dt);
        else
            l_global_epe_rec.erlst_deenrt_dt := nvl(l_old_erlst_deenrt_dt,
                                                        l_global_epe_rec.erlst_deenrt_dt) ;
        end if ;
      end if;

      if g_debug then
        hr_utility.set_location('l_global_epe_recerslt_deenrt_dt'||l_global_epe_rec.erlst_deenrt_dt,8086.1);
      end if;
      if g_debug then
        hr_utility.set_location('l_global_epe_recerslt_deenrt_dt'||l_global_epe_rec.enrt_cvg_strt_dt,8086.1);
      end if;
      if g_debug then
        hr_utility.set_location('l_old_erlst_deenrt_dt '||l_old_erlst_deenrt_dt,8086.1);
      end if;
      if g_debug then
        hr_utility.set_location(l_proc, 150);
      end if;
      if (l_global_epe_rec.enrt_cvg_strt_dt is null) then
        --
        -- null globals to prevent bleeding
        --
        g_enrt_bnft_id:=null;
        g_bnft_val:=null;
        g_elig_per_elctbl_chc_id:=null;
        --
        if g_debug then
          hr_utility.set_location('BEN_91453_CVG_STRT_DT_NOT_FOUN id:'|| to_char(l_global_epe_rec.pl_id), 169);
        end if;
        fnd_message.set_name('BEN','BEN_91453_CVG_STRT_DT_NOT_FOUN');
        fnd_message.set_token('PROC',l_proc);
        fnd_message.set_token('PERSON_ID',to_char(l_global_pil_rec.person_id));
        fnd_message.set_token('PGM_ID',to_char(l_global_epe_rec.pgm_id));
        fnd_message.set_token('PLAN_ID',to_char(l_global_epe_rec.pl_id));
        fnd_message.set_token('OIPL_ID',to_char(l_global_epe_rec.oipl_id));
        fnd_message.raise_error;
      end if; -- date is null
      if g_debug then
        hr_utility.set_location(l_proc, 170);
      end if;
      if (nvl(l_old_bnft_val,hr_api.g_number)<>
             nvl(l_global_enb_rec.val,hr_api.g_number)
         -- Bug#1807450 added and condition
          and p_prtt_enrt_rslt_id is not null) or
         -- Added for Interim Coverage /*ENH*/
         ben_sspndd_enrollment.g_use_new_result  or
         (l_global_epe_rec.crntly_enrd_flag = 'Y' and
             p_prtt_enrt_rslt_id is null) or  -- bug#5105122-called from backout
         l_start_new_result  then
        l_bnft_amt_changed:= TRUE;
        ben_determine_date.rate_and_coverage_dates
              (p_which_dates_cd         => 'C'
              ,p_business_group_id      => l_global_epe_rec.business_group_id
              ,p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id
   --           ,p_enrt_cvg_strt_dt       => l_global_epe_rec.enrt_cvg_strt_dt
              ,p_enrt_cvg_strt_dt       =>l_enrt_cvg_strt_dt
              ,p_enrt_cvg_strt_dt_cd    => l_xenrt_cvg_strt_dt_cd
              ,p_enrt_cvg_strt_dt_rl    => l_xenrt_cvg_strt_dt_rl
              ,p_rt_strt_dt             => l_xrt_strt_dt
              ,p_rt_strt_dt_cd          => l_xrt_strt_dt_cd
              ,p_rt_strt_dt_rl          => l_xrt_strt_dt_rl
              ,p_enrt_cvg_end_dt        => l_xenrt_cvg_end_dt
              ,p_enrt_cvg_end_dt_cd     => l_xenrt_cvg_end_dt_cd
              ,p_enrt_cvg_end_dt_rl     => l_xenrt_cvg_end_dt_rl
              ,p_rt_end_dt              => l_xrt_end_dt
              ,p_rt_end_dt_cd           => l_xrt_end_dt_cd
              ,p_rt_end_dt_rl           => l_xrt_end_dt_rl
              ,p_acty_base_rt_id        => null
              ,p_effective_date         => p_effective_date
              /* Start of Changes for WWBUG: 2141172: added line                */
              ,p_lf_evt_ocrd_dt         => l_global_pil_rec.lf_evt_ocrd_dt
              /* End of Changes for WWBUG: 2141172: added line                  */
        );
        -- if there is any waiting period, the start date returned above override the coverage
        -- start date arrived in the benmngle - bug#1807450
        --
       hr_utility.set_location( 'l_global_epe_rec.enrt_cvg_strt_dt'||l_global_epe_rec.enrt_cvg_strt_dt,444);
       hr_utility.set_location( 'l_enrt_cvg_strt_dt'||l_enrt_cvg_strt_dt,444);
        if l_enrt_cvg_strt_dt > l_global_epe_rec.enrt_cvg_strt_dt then
           l_global_epe_rec.enrt_cvg_strt_dt := l_enrt_cvg_strt_dt;
        end if;
        --
      end if;
      --
      if l_global_epe_rec.enrt_cvg_strt_dt_cd = 'ENTRBL' and
         p_enrt_cvg_strt_dt is not null then
        l_global_epe_rec.enrt_cvg_strt_dt := p_enrt_cvg_strt_dt;
      end if;
      --
      --
      -- if staying in same plan use the old original enrt date
      --
      if (l_old_pl_id=l_global_epe_rec.pl_id) then
        l_orgnl_enrt_dt:=l_old_orgnl_enrt_dt;
          -- Bug 3602579 - now check if previous enrollment was in waive option
         if l_old_oipl_id is not null and l_global_epe_rec.oipl_id is not null then
            hr_utility.set_location( 'Into the new clause l_old_oipl_id '|| l_old_oipl_id ,999);
            hr_utility.set_location( 'Into the new clause l_global_epe_rec.oipl_id '|| l_global_epe_rec.oipl_id ,999);
           if (l_old_oipl_id <> l_global_epe_rec.oipl_id) then
               hr_utility.set_location( 'Into the new clause ',999);
               -- check if old oipl is waive.
               open c_wv_opt (l_old_oipl_id);
               fetch c_wv_opt into l_wv_flag ;
               close  c_wv_opt ;
               hr_utility.set_location( 'Into the new clause l_wv_flag '|| l_wv_flag ,999);
               if nvl(l_wv_flag,'N') = 'Y' then
                  l_wv_flag := 'N' ;
                  l_orgnl_enrt_dt := l_global_epe_rec.enrt_cvg_strt_dt;
               end if ;
           end if ;
         end if ;
      else
        l_orgnl_enrt_dt:=l_global_epe_rec.enrt_cvg_strt_dt;
      end if;
      --
      hr_utility.set_location( 'l_global_pil_rec.lf_evt_ocrd_dt '|| l_global_pil_rec.lf_evt_ocrd_dt ,999);

      -- create the enrolment result
      if l_global_epe_rec.ptip_id is not null then
        ben_cobj_cache.get_ptip_dets
          (p_business_group_id => p_business_group_id
          ,p_effective_date    => l_global_pil_rec.lf_evt_ocrd_dt --Bug 6503304
          ,p_ptip_id           => l_global_epe_rec.ptip_id
          ,p_inst_row          => l_ptip_rec);
      end if;
      if l_global_epe_rec.plip_id is not null then
        ben_cobj_cache.get_plip_dets
          (p_business_group_id => p_business_group_id
          ,p_effective_date    => l_global_pil_rec.lf_evt_ocrd_dt --Bug 6503304
          ,p_plip_id           => l_global_epe_rec.plip_id
          ,p_inst_row          => l_plip_rec);
      end if;
      if l_global_epe_rec.oipl_id is not null then
        ben_cobj_cache.get_oipl_dets
           (p_business_group_id => p_business_group_id
           ,p_effective_date    => l_global_pil_rec.lf_evt_ocrd_dt --Bug 6503304
           ,p_oipl_id           => l_global_epe_rec.oipl_id
           ,p_inst_row          => l_oipl_rec);
      end if;
      if l_global_epe_rec.pl_id is not null then
        ben_cobj_cache.get_pl_dets
          (p_business_group_id => p_business_group_id
          ,p_effective_date    => l_global_pil_rec.lf_evt_ocrd_dt --Bug 6503304
          ,p_pl_id             => l_global_epe_rec.pl_id
          ,p_inst_row          => l_pl_rec);
      end if;
  --
  -- unrestricted changes

     if p_prtt_enrt_rslt_id is not null then
        l_datetrack_mode := hr_api.g_update;
     else
        l_datetrack_mode := p_datetrack_mode;
     end if;
     -- Bug 2172036 pass assignment_id also to create pen
     -- cursor moved 4510798
     --open c_epe ;
     --fetch c_epe into l_assignment_id;
     --close c_epe ;
     if g_debug then
       hr_utility.set_location( 'l_assignment_id '||l_assignment_id,12);
       hr_utility.set_location( 'l_global_epe_rec.enrt_cvg_strt_dt'||l_global_epe_rec.enrt_cvg_strt_dt,12);
     end if;
     --
     --  Bug 7206471. Check if the coverage should be adjusted.
    --
    /* Bug 8945818 */
    open c_prev_per_in_ler;
    fetch c_prev_per_in_ler into l_prev_pil_id;
    close c_prev_per_in_ler;
    /* End of Bug 8945818 */

    open c_get_prior_per_in_ler(l_global_epe_rec.enrt_cvg_strt_dt);
    fetch c_get_prior_per_in_ler into l_exists;
    if c_get_prior_per_in_ler%found then
  --
     for l_pgm in c_get_pgm loop
      --
      open c_get_pgm_extra_info_cvg(l_pgm.pgm_id);
      fetch c_get_pgm_extra_info_cvg into l_cvg_adjust;
      if c_get_pgm_extra_info_cvg%found then
        --
        if l_cvg_adjust = 'Y' then
          --
	  hr_utility.set_location('l_cvg_adjust '||l_cvg_adjust,44333);
	  --
          --  Get cvg end dt
	  -- for l_get_elctbl_chc_for_cvg in c_get_elctbl_chc_for_cvg loop -- Bug 8507247
	  --
          --  Get all results that were de-enrolled for the event.
	  --
	  /*Added for Bug 8507247*/
	  open c_get_ptip_id;
	  fetch c_get_ptip_id into l_ptip_id;
	  close c_get_ptip_id;
	  /*End of Bug 8507247*/
          for l_get_enrt_rslts_for_pen in c_get_enrt_rslts_for_pen(l_global_epe_rec.enrt_cvg_strt_dt
                                       ,l_ptip_id ) loop
              hr_utility.set_location('Adjusting Coverage for '||l_global_epe_rec.enrt_cvg_strt_dt,44333);
              --
	      open c_prtt_enrt_rslt_adj(l_get_enrt_rslts_for_pen.prtt_enrt_rslt_id);
              fetch c_prtt_enrt_rslt_adj into l_exists;
              if c_prtt_enrt_rslt_adj%notfound then
                insert into BEN_LE_CLSN_N_RSTR (
                        BKUP_TBL_TYP_CD,
                        BKUP_TBL_ID,
                        per_in_ler_id,
                        person_id,
                        ENRT_CVG_THRU_DT,
                        business_group_id,
                        object_version_number)
                      values (
                        'BEN_PRTT_ENRT_RSLT_F_ADJ',
                        l_get_enrt_rslts_for_pen.prtt_enrt_rslt_id,
                        l_get_enrt_rslts_for_pen.pil_id,
                        l_get_enrt_rslts_for_pen.person_id,
                        l_get_enrt_rslts_for_pen.enrt_cvg_thru_dt,
                        p_business_group_id,
                        l_get_enrt_rslts_for_pen.object_version_number
                      );
              end if;
              close c_prtt_enrt_rslt_adj;
               --
	        ben_prtt_enrt_result_api.update_prtt_enrt_result
               (p_validate                 => FALSE,
               p_prtt_enrt_rslt_id        => l_get_enrt_rslts_for_pen.prtt_enrt_rslt_id,
               p_effective_start_date     => l_effective_start_date,
               p_effective_end_date       => l_effective_end_date,
               p_business_group_id        => p_business_group_id,
               p_object_version_number    => l_get_enrt_rslts_for_pen.object_version_number,
               p_effective_date           => l_get_enrt_rslts_for_pen.effective_start_date,--p_effective_date,
	                                     /*Bug 9057101: Instead of passing p_effective_date, pass
					      effective start date of the pen_id*/
               p_datetrack_mode           => hr_api.g_correction,
               p_multi_row_validate       => FALSE,
	       p_enrt_cvg_thru_dt         => l_global_epe_rec.enrt_cvg_strt_dt - 1 -- Bug 8507247
               );
            end loop;  -- c_get_enrt_rslts_for_pen
         -- end loop; -- c_get_elctbl_chc_for_cvg  -- Bug 8507247
        end if;  -- l_cvg_adjust = 'Y'
      end if;  -- c_get_pgm_extra_info_cvg
      close c_get_pgm_extra_info_cvg;
    end loop; -- c_get_pgm
    end if;
    close c_get_prior_per_in_ler;
    --
    -- End bug 7206471
    --
    -----Bug 8596122
    hr_utility.set_location('l_global_epe_rec.enrt_cvg_strt_dt : '||l_global_epe_rec.enrt_cvg_strt_dt,1);
    open c_prev_pil(l_global_pil_rec.person_id);
    fetch c_prev_pil into l_prev_pil;
    if c_prev_pil%found then
       hr_utility.set_location('prev pil Id : '||l_prev_pil.per_in_ler_id,1);
       hr_utility.set_location('l_global_epe_rec.pl_id : '||l_global_epe_rec.pl_id,1);
       hr_utility.set_location('l_global_epe_rec.oipl_id : '||l_global_epe_rec.oipl_id,1);
       open c_check_int_enr(l_prev_pil.per_in_ler_id,l_global_epe_rec.pgm_id,l_global_epe_rec.pl_id,l_global_epe_rec.oipl_id);
       fetch c_check_int_enr into l_check_int_enr;
       if c_check_int_enr%found then
	  ben_determine_date.rate_and_coverage_dates
              (p_which_dates_cd         => 'C'
              ,p_business_group_id      => l_global_epe_rec.business_group_id
              ,p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id
              ,p_enrt_cvg_strt_dt       => l_global_epe_rec.enrt_cvg_strt_dt
              ,p_enrt_cvg_strt_dt_cd    => l_yenrt_cvg_strt_dt_cd
              ,p_enrt_cvg_strt_dt_rl    => l_yenrt_cvg_strt_dt_rl
              ,p_rt_strt_dt             => l_yrt_strt_dt
              ,p_rt_strt_dt_cd          => l_yrt_strt_dt_cd
              ,p_rt_strt_dt_rl          => l_yrt_strt_dt_rl
              ,p_enrt_cvg_end_dt        => l_yenrt_cvg_end_dt
              ,p_enrt_cvg_end_dt_cd     => l_yenrt_cvg_end_dt_cd
              ,p_enrt_cvg_end_dt_rl     => l_yenrt_cvg_end_dt_rl
              ,p_rt_end_dt              => l_yrt_end_dt
              ,p_rt_end_dt_cd           => l_yrt_end_dt_cd
              ,p_rt_end_dt_rl           => l_yrt_end_dt_rl
              ,p_acty_base_rt_id        => null
              ,p_effective_date         => p_effective_date
              ,p_lf_evt_ocrd_dt         => l_global_pil_rec.lf_evt_ocrd_dt
        );
	 hr_utility.set_location('l_global_epe_rec.enrt_cvg_strt_dt : '||l_global_epe_rec.enrt_cvg_strt_dt,1);
	  hr_utility.set_location('int enr found',1);
       end if;
       close c_check_int_enr;
    end if;
    close c_prev_pil;

    ------Bug 8596122
      ben_PRTT_ENRT_RESULT_api.create_enrollment
        (p_prtt_enrt_rslt_id              =>  l_prtt_enrt_rslt_id
        ,P_prtt_enrt_rslt_id_o            =>  p_prtt_enrt_rslt_id
        ,p_elig_per_elctbl_chc_id         =>  p_elig_per_elctbl_chc_id
        ,p_assignment_id                  =>  l_assignment_id  --Bug 2172036
        ,p_effective_start_date           =>  p_effective_start_date
        ,p_effective_end_date             =>  p_effective_end_date
        ,p_pgm_id                         =>  l_global_epe_rec.pgm_id
        ,p_ptip_id                        =>  l_global_epe_rec.ptip_id
        ,p_pl_typ_id                      =>  l_global_epe_rec.pl_typ_id
        ,p_pl_id                          =>  l_global_epe_rec.pl_id
        ,p_oipl_id                        =>  l_global_epe_rec.oipl_id
        ,p_pl_ordr_num                    =>  l_pl_rec.ordr_num
        ,p_plip_ordr_num                  =>  l_plip_rec.ordr_num
        ,p_ptip_ordr_num                  =>  l_ptip_rec.ordr_num
        ,p_oipl_ordr_num                  =>  l_oipl_rec.ordr_num
        ,p_business_group_id              =>  l_global_epe_rec.business_group_id
        ,p_erlst_deenrt_dt                =>  l_global_epe_rec.erlst_deenrt_dt
        ,p_enrt_mthd_cd                   =>  p_enrt_mthd_cd
        --
        -- derive from per_in_ler_id
        --
        ,p_ler_id                         =>  l_global_pil_rec.ler_id
        ,p_person_id                      =>  l_global_pil_rec.person_id
        ,p_per_in_ler_id                  =>  l_global_epe_rec.per_in_ler_id
        ,p_bnft_amt                     =>  l_global_enb_rec.val
        ,p_uom                          =>  l_global_pel_rec.uom
        ,p_bnft_nnmntry_uom             =>  l_global_enb_rec.nnmntry_uom
        ,p_comp_lvl_cd                  =>  l_global_epe_rec.comp_lvl_cd
        ,p_bnft_typ_cd                  =>  l_global_enb_rec.bnft_typ_cd
        ,p_bnft_ordr_num                =>  l_global_enb_rec.ordr_num
        ,p_enrt_cvg_strt_dt             =>  l_global_epe_rec.enrt_cvg_strt_dt
        ,p_orgnl_enrt_dt                =>  l_orgnl_enrt_dt
        ,p_object_version_number        =>  l_object_version_number
        ,p_effective_date               =>  p_effective_date
        ,p_suspend_flag                 =>  p_suspend_flag
        ,p_called_from_sspnd            => p_called_from_sspnd
        ,p_prtt_enrt_interim_id         =>  l_prtt_enrt_interim_id
        ,p_datetrack_mode               =>  l_datetrack_mode
        ,p_multi_row_validate           => FALSE
        ,p_program_application_id       => fnd_global.prog_appl_id
        ,p_program_id                   => fnd_global.conc_program_id
        ,p_request_id                   => fnd_global.conc_request_id
        ,p_program_update_date          => sysdate
         -- Bug #2714383
      -- Passing null if the attribute value is $Sys_Def$
        ,p_pen_attribute_category       => decd_attribute(p_pen_attribute_category)
        ,p_pen_attribute1               => decd_attribute(p_pen_attribute1)
        ,p_pen_attribute2               => decd_attribute(p_pen_attribute2)
        ,p_pen_attribute3               => decd_attribute(p_pen_attribute3)
        ,p_pen_attribute4               => decd_attribute(p_pen_attribute4)
        ,p_pen_attribute5               => decd_attribute(p_pen_attribute5)
        ,p_pen_attribute6               => decd_attribute(p_pen_attribute6)
        ,p_pen_attribute7               => decd_attribute(p_pen_attribute7)
        ,p_pen_attribute8               => decd_attribute(p_pen_attribute8)
        ,p_pen_attribute9               => decd_attribute(p_pen_attribute9)
        ,p_pen_attribute10              => decd_attribute(p_pen_attribute10)
        ,p_pen_attribute11              => decd_attribute(p_pen_attribute11)
        ,p_pen_attribute12              => decd_attribute(p_pen_attribute12)
        ,p_pen_attribute13              => decd_attribute(p_pen_attribute13)
        ,p_pen_attribute14              => decd_attribute(p_pen_attribute14)
        ,p_pen_attribute15              => decd_attribute(p_pen_attribute15)
        ,p_pen_attribute16              => decd_attribute(p_pen_attribute16)
        ,p_pen_attribute17              => decd_attribute(p_pen_attribute17)
        ,p_pen_attribute18              => decd_attribute(p_pen_attribute18)
        ,p_pen_attribute19              => decd_attribute(p_pen_attribute19)
        ,p_pen_attribute20              => decd_attribute(p_pen_attribute20)
        ,p_pen_attribute21              => decd_attribute(p_pen_attribute21)
        ,p_pen_attribute22              => decd_attribute(p_pen_attribute22)
        ,p_pen_attribute23              => decd_attribute(p_pen_attribute23)
        ,p_pen_attribute24              => decd_attribute(p_pen_attribute24)
        ,p_pen_attribute25              => decd_attribute(p_pen_attribute25)
        ,p_pen_attribute26              => decd_attribute(p_pen_attribute26)
        ,p_pen_attribute27              => decd_attribute(p_pen_attribute27)
        ,p_pen_attribute28              => decd_attribute(p_pen_attribute28)
        ,p_pen_attribute29              => decd_attribute(p_pen_attribute29)
        ,p_pen_attribute30              => decd_attribute(p_pen_attribute30)
        ,p_dpnt_actn_warning            => l_dpnt_actn_warning
        ,p_bnf_actn_warning             => l_bnf_actn_warning
        ,p_ctfn_actn_warning            => l_ctfn_actn_warning
        ,p_enrt_bnft_id                 => p_enrt_bnft_id
        ,p_source                       => 'benelinf'
      );
        if g_debug then
          hr_utility.set_location( 'l_global_epe_rec.erlst_deenrt_dt'||l_global_epe_rec.erlst_deenrt_dt,1233);
        end if;
        if g_debug then
          hr_utility.set_location( 'l_global_epe_rec.per_in_ler_id'||l_global_epe_rec.per_in_ler_id,1233);
        end if;
        if g_debug then
          hr_utility.set_location( 'l_prtt_enrt_rslt_id '||l_prtt_enrt_rslt_id,1233);
        end if;
        if g_debug then
          hr_utility.set_location( 'p_prtt_enrt_rslt_id '||p_prtt_enrt_rslt_id,1233);
        end if;
        if g_debug then
          hr_utility.set_location( 'p_datetrack_mode '||p_datetrack_mode,1233);
        end if;
        if g_debug then
          hr_utility.set_location( 'p_effective_date '||p_effective_date,1233);
        end if;
        --
        -- write to the change event log.  thayden.  such a mess!
        --
        if l_global_epe_rec.pl_id <> nvl(l_old_pl_id,l_global_epe_rec.pl_id) or
           l_global_epe_rec.oipl_id <>
           nvl(l_old_oipl_id,l_global_epe_rec.oipl_id) then
          ben_ext_chlg.log_benefit_chg
          (p_action                      =>  'UPDATE' --plan and option changes
          ,p_pl_id                       =>  l_global_epe_rec.pl_id
          ,p_old_pl_id                   =>  l_old_pl_id
          ,p_oipl_id                     =>  l_global_epe_rec.oipl_id
          ,p_old_oipl_id                 =>  l_old_oipl_id
          ,p_enrt_cvg_strt_dt            =>  l_global_epe_rec.enrt_cvg_strt_dt
          ,p_old_enrt_cvg_strt_dt        =>  l_old_enrt_cvg_strt_dt
          ,p_old_enrt_cvg_end_dt         =>  l_old_enrt_cvg_thru_dt
          ,p_prtt_enrt_rslt_id           =>  l_prtt_enrt_rslt_id
          ,p_old_prtt_enrt_rslt_id       =>  p_prtt_enrt_rslt_id
          ,p_per_in_ler_id               =>  l_global_epe_rec.per_in_ler_id
          ,p_old_per_in_ler_id           =>  l_old_per_in_ler_id
          ,p_person_id                   =>  l_global_pil_rec.person_id
          ,p_business_group_id           =>  l_global_epe_rec.business_group_id
          ,p_effective_date              =>  p_effective_date
          );
        else
          ben_ext_chlg.log_benefit_chg
          (p_action                      =>  'CREATE'  -- new enrollment
          ,p_pl_id                       =>  l_global_epe_rec.pl_id
          ,p_old_pl_id                   =>  l_old_pl_id
          ,p_oipl_id                     =>  l_global_epe_rec.oipl_id
          ,p_old_oipl_id                 =>  l_old_oipl_id
          ,p_old_bnft_amt                =>  l_old_bnft_val
          ,p_bnft_amt                    =>  l_global_enb_rec.val
          ,p_enrt_cvg_strt_dt            =>  l_global_epe_rec.enrt_cvg_strt_dt
          ,p_enrt_cvg_end_dt             =>  hr_api.g_eot  --?
          ,p_prtt_enrt_rslt_id           =>  l_prtt_enrt_rslt_id
          ,p_per_in_ler_id               =>  l_global_epe_rec.per_in_ler_id
          ,p_person_id                   =>  l_global_pil_rec.person_id
          ,p_business_group_id           =>  l_global_epe_rec.business_group_id
          ,p_effective_date              =>  p_effective_date
          );
        end if;
        --
        ben_ext_chlg.log_benefit_chg
          (p_action                      =>  l_action
          ,p_pl_id                       =>  l_global_epe_rec.pl_id
          ,p_old_pl_id                   =>  l_old_pl_id
          ,p_oipl_id                     =>  l_global_epe_rec.oipl_id
          ,p_old_oipl_id                 =>  l_old_oipl_id
          ,p_enrt_cvg_strt_dt            =>  l_global_epe_rec.enrt_cvg_strt_dt
          ,p_old_enrt_cvg_strt_dt        =>  l_old_enrt_cvg_strt_dt
          ,p_old_enrt_cvg_end_dt         =>  l_old_enrt_cvg_thru_dt
          ,p_prtt_enrt_rslt_id           =>  l_prtt_enrt_rslt_id
          ,p_old_prtt_enrt_rslt_id       =>  p_prtt_enrt_rslt_id
          ,p_per_in_ler_id               =>  l_global_epe_rec.per_in_ler_id
          ,p_person_id                   =>  l_global_pil_rec.person_id
          ,p_business_group_id           =>  l_global_epe_rec.business_group_id
          ,p_effective_date              =>  p_effective_date
          );

      p_prtt_enrt_interim_id:=l_prtt_enrt_interim_id;
      --
    end if;
    --
    if g_debug then
      hr_utility.set_location(l_proc, 330);
    end if;
    --
    if p_prtt_enrt_rslt_id is not null -- and
       -- l_use_new_result=false then
       -- ben_sspndd_enrollment.g_use_new_result=false) Bug 2543071 Needs to delete if the interim
       -- is the old enrollment.We create a new enrollment for interim.
       or l_start_new_result then /*ENH*/
      --
      -- If the old enrollment is now the interim coverage
      -- then don't end it, leave it be.
      --
      hr_utility.set_location('ben_sspndd_enrollment.g_sspnded_rslt_id ' || ben_sspndd_enrollment.g_sspnded_rslt_id, 1212);
      hr_utility.set_location('l_prtt_enrt_interim_id ' || l_prtt_enrt_interim_id, 1212);
      hr_utility.set_location('p_prtt_enrt_rslt_id ' || p_prtt_enrt_rslt_id, 1212);
      if (l_prtt_enrt_interim_id is null or
         l_prtt_enrt_interim_id <> p_prtt_enrt_rslt_id)
         -- 6337803
         and p_prtt_enrt_rslt_id <> nvl(ben_sspndd_enrollment.g_sspnded_rslt_id,-1)
         then
        --
        -- deenrol
        --
        if g_debug then
          hr_utility.set_location(l_proc, 115);
        end if;
        if g_debug then
          hr_utility.set_location( 'p_datetrack_mode '||p_datetrack_mode,1234);
        end if;
        if g_debug then
          hr_utility.set_location( 'p_effective_date '||p_effective_date,1234);
        end if;
        -- Bug 2627078 fixes
        -- Don't try to delete if the result is already got deleted by the earlier
        -- process.
        open c_pen_exists(p_prtt_enrt_rslt_id);
        fetch c_pen_exists into l_dummy_char ;
        if c_pen_exists%found then
          --
          ben_PRTT_ENRT_RESULT_api.delete_enrollment(
             p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
            ,p_per_in_ler_id              => l_global_epe_rec.per_in_ler_id
            ,p_business_group_id          => l_global_epe_rec.business_group_id
            ,p_effective_start_date       => p_effective_start_date
            ,p_effective_end_date         => p_effective_end_date
            ,p_object_version_number      => p_object_version_number
            ,p_effective_date             => p_effective_date
            ,p_datetrack_mode             => nvl(l_datetrack_mode, p_datetrack_mode) /*2483991*/
            ,p_multi_row_validate         => FALSE
            ,p_source                     => 'benelinf'
            ,p_lee_rsn_id                 => l_global_pel_rec.lee_rsn_id
            ,p_enrt_perd_id               => l_global_pel_rec.enrt_perd_id
          );
          --
          -- after delete enrollment the fonm flag back
          -- when the plan replcaed  the dele_enroll might have reset the fonm flag
          ben_manage_life_events.fonm := l_fonm_flag ;
          ben_manage_life_events.g_fonm_cvg_strt_dt := l_fonm_cvg_strt_dt;

          hr_utility.set_location (' aftr del_enrl  FONM ' ||  ben_manage_life_events.fonm , 99 ) ;
          hr_utility.set_location (' FONM CVG  ' ||  ben_manage_life_events.g_fonm_cvg_strt_dt , 99 ) ;


        end if;
        --
        close c_pen_exists ;
        if g_debug then
          hr_utility.set_location(l_proc, 109);
        end if;
      end if;
      if g_debug then
        hr_utility.set_location(l_proc, 110);
      end if;
      -- 6337803 unsetting the pen id to be suspended
      ben_sspndd_enrollment.g_sspnded_rslt_id := null;
      --
    end if;
    --
    -- For the create return the new ovn
    --
    p_object_version_number:=l_object_version_number;
  end if;
  if g_debug then
    hr_utility.set_location(l_proc, 340);
  end if;

  p_prtt_enrt_rslt_id:=l_prtt_enrt_rslt_id;

  -- update, create and delete enrolloment may all change the enrt_bnft row.
  if p_enrt_bnft_id is not null then
     ben_global_enrt.get_enb -- enrt bnft  --CHANGE TO RELOAD_ENB if it's created.
        (p_enrt_bnft_id           => p_enrt_bnft_id
        ,p_global_enb_rec         => l_global_enb_rec);
  else ben_global_enrt.clear_enb
        (p_global_enb_rec         => l_global_enb_rec);
  end if;

  -- update benefit fk in enrt_bnft
  if g_debug then
    hr_utility.set_location(l_proc, 342);
  end if;
  manage_enrt_bnft(
        p_enrt_bnft_id               => p_enrt_bnft_id,
        p_effective_date             => p_effective_date,
        p_object_version_number      => l_global_enb_rec.object_version_number,
        p_business_group_id          => p_business_group_id,
        p_prtt_enrt_rslt_id          => l_prtt_enrt_rslt_id,
        p_per_in_ler_id              => l_global_epe_rec.per_in_ler_id,
        p_creation_date              => null,
        p_created_by                 => null
  );
  if g_debug then
    hr_utility.set_location(l_proc, 346);
  end if;

  -- process all rates

  if p_enrt_rt_id1 is not null then
    if g_debug then
      hr_utility.set_location(l_proc, 350);
    end if;
    election_rate_information(
        p_enrt_mthd_cd            => p_enrt_mthd_cd,
        p_effective_date          => p_effective_date,
        p_prtt_enrt_rslt_id       => p_prtt_enrt_rslt_id,
        p_per_in_ler_id           => l_global_epe_rec.per_in_ler_id,
        p_person_id               => l_global_pil_rec.person_id,
        p_pgm_id                  => l_global_epe_rec.pgm_id,
        p_pl_id                   => l_global_epe_rec.pl_id,
        p_oipl_id                 => l_global_epe_rec.oipl_id,
        p_enrt_rt_id              => p_enrt_rt_id1,
        p_prtt_rt_val_id          => p_prtt_rt_val_id1,
        p_rt_val                  => p_rt_val1,
        p_ann_rt_val              => p_ann_rt_val1,
        p_enrt_cvg_strt_dt        => l_global_epe_rec.enrt_cvg_strt_dt,
        p_acty_ref_perd_cd        => l_global_pel_rec.acty_ref_perd_cd,
        p_datetrack_mode          => p_datetrack_mode,
        p_business_group_id       => p_business_group_id,
        p_bnft_amt_changed        => l_bnft_amt_changed,
        p_rt_strt_dt              => p_rt_strt_dt1,
        p_rt_end_dt               => p_rt_end_dt1,
        --
        p_prv_rt_val              => l_dummy_number,
        p_prv_ann_rt_val          => l_dummy_number,
        p_imp_cvg_strt_dt         => p_imp_cvg_strt_dt); -- 8716870
    if g_debug then
      hr_utility.set_location(l_proc, 360);
    end if;
  end if;

  if g_debug then
    hr_utility.set_location(l_proc, 370);
  end if;

  if p_enrt_rt_id2 is not null then
    if g_debug then
      hr_utility.set_location(l_proc, 380);
    end if;
    election_rate_information(
        p_enrt_mthd_cd           => p_enrt_mthd_cd,
        p_effective_date         => p_effective_date,
        p_prtt_enrt_rslt_id      => p_prtt_enrt_rslt_id,
        p_per_in_ler_id          => l_global_epe_rec.per_in_ler_id,
        p_person_id              => l_global_pil_rec.person_id,
        p_pgm_id                 => l_global_epe_rec.pgm_id,
        p_pl_id                  => l_global_epe_rec.pl_id,
        p_oipl_id                => l_global_epe_rec.oipl_id,
        p_enrt_rt_id             => p_enrt_rt_id2,
        p_prtt_rt_val_id         => p_prtt_rt_val_id2,
        p_rt_val                 => p_rt_val2,
        p_ann_rt_val             => p_ann_rt_val2,
        p_enrt_cvg_strt_dt       => l_global_epe_rec.enrt_cvg_strt_dt,
        p_acty_ref_perd_cd       => l_global_pel_rec.acty_ref_perd_cd,
        p_datetrack_mode         => p_datetrack_mode,
        p_business_group_id      => p_business_group_id,
        p_bnft_amt_changed       => l_bnft_amt_changed,
        p_rt_strt_dt             => p_rt_strt_dt2,
        p_rt_end_dt              => p_rt_end_dt2,
        --
        p_prv_rt_val             => l_dummy_number,
        p_prv_ann_rt_val         => l_dummy_number,
        p_imp_cvg_strt_dt        => p_imp_cvg_strt_dt); -- 8716870
    if g_debug then
      hr_utility.set_location(l_proc, 390);
    end if;
  end if;
  if g_debug then
    hr_utility.set_location(l_proc, 395);
  end if;


  if p_enrt_rt_id3 is not null then
    if g_debug then
      hr_utility.set_location(l_proc, 400);
    end if;
    election_rate_information(
        p_enrt_mthd_cd            => p_enrt_mthd_cd,
        p_effective_date          => p_effective_date,
        p_prtt_enrt_rslt_id       => p_prtt_enrt_rslt_id,
        p_per_in_ler_id           => l_global_epe_rec.per_in_ler_id,
        p_person_id               => l_global_pil_rec.person_id,
        p_pgm_id                  => l_global_epe_rec.pgm_id,
        p_pl_id                   => l_global_epe_rec.pl_id,
        p_oipl_id                 => l_global_epe_rec.oipl_id,
        p_enrt_rt_id              => p_enrt_rt_id3,
        p_prtt_rt_val_id          => p_prtt_rt_val_id3,
        p_rt_val                  => p_rt_val3,
        p_ann_rt_val              => p_ann_rt_val3,
        p_enrt_cvg_strt_dt        => l_global_epe_rec.enrt_cvg_strt_dt,
        p_acty_ref_perd_cd        => l_global_pel_rec.acty_ref_perd_cd,
        p_datetrack_mode          => p_datetrack_mode,
        p_business_group_id       => p_business_group_id,
        p_bnft_amt_changed        => l_bnft_amt_changed,
        p_rt_strt_dt              => p_rt_strt_dt3,
        p_rt_end_dt               => p_rt_end_dt3,
        --
        p_prv_rt_val              => l_dummy_number,
        p_prv_ann_rt_val          => l_dummy_number,
        p_imp_cvg_strt_dt         => p_imp_cvg_strt_dt); -- 8716870
    if g_debug then
      hr_utility.set_location(l_proc, 410);
    end if;
  end if;
  if g_debug then
    hr_utility.set_location(l_proc, 420);
  end if;


  if p_enrt_rt_id4 is not null then
    if g_debug then
      hr_utility.set_location(l_proc, 430);
    end if;
    election_rate_information(
        p_enrt_mthd_cd             => p_enrt_mthd_cd,
        p_effective_date           => p_effective_date,
        p_prtt_enrt_rslt_id        => p_prtt_enrt_rslt_id,
        p_per_in_ler_id            => l_global_epe_rec.per_in_ler_id,
        p_person_id                => l_global_pil_rec.person_id,
        p_pgm_id                   => l_global_epe_rec.pgm_id,
        p_pl_id                    => l_global_epe_rec.pl_id,
        p_oipl_id                  => l_global_epe_rec.oipl_id,
        p_enrt_rt_id               => p_enrt_rt_id4,
        p_prtt_rt_val_id           => p_prtt_rt_val_id4,
        p_rt_val                   => p_rt_val4,
        p_ann_rt_val               => p_ann_rt_val4,
        p_enrt_cvg_strt_dt         => l_global_epe_rec.enrt_cvg_strt_dt,
        p_acty_ref_perd_cd         => l_global_pel_rec.acty_ref_perd_cd,
        p_datetrack_mode           => p_datetrack_mode,
        p_business_group_id        => p_business_group_id,
        p_bnft_amt_changed         => l_bnft_amt_changed,
        p_rt_strt_dt               => p_rt_strt_dt4,
        p_rt_end_dt                => p_rt_end_dt4,
        --
        p_prv_rt_val               => l_dummy_number,
        p_prv_ann_rt_val           => l_dummy_number,
        p_imp_cvg_strt_dt          => p_imp_cvg_strt_dt); -- 8716870
    if g_debug then
      hr_utility.set_location(l_proc, 440);
    end if;
  end if;
  if g_debug then
    hr_utility.set_location(l_proc, 450);
  end if;


  if p_enrt_rt_id5 is not null then
    if g_debug then
      hr_utility.set_location(l_proc, 460);
    end if;
    election_rate_information(
        p_enrt_mthd_cd             => p_enrt_mthd_cd,
        p_effective_date           => p_effective_date,
        p_prtt_enrt_rslt_id        => p_prtt_enrt_rslt_id,
        p_per_in_ler_id            => l_global_epe_rec.per_in_ler_id,
        p_person_id                => l_global_pil_rec.person_id,
        p_pgm_id                   => l_global_epe_rec.pgm_id,
        p_pl_id                    => l_global_epe_rec.pl_id,
        p_oipl_id                  => l_global_epe_rec.oipl_id,
        p_enrt_rt_id               => p_enrt_rt_id5,
        p_prtt_rt_val_id           => p_prtt_rt_val_id5,
        p_rt_val                   => p_rt_val5,
        p_ann_rt_val               => p_ann_rt_val5,
        p_enrt_cvg_strt_dt         => l_global_epe_rec.enrt_cvg_strt_dt,
        p_acty_ref_perd_cd         => l_global_pel_rec.acty_ref_perd_cd,
        p_datetrack_mode           => p_datetrack_mode,
        p_business_group_id        => p_business_group_id,
        p_bnft_amt_changed         => l_bnft_amt_changed,
        p_rt_strt_dt               => p_rt_strt_dt5,
        p_rt_end_dt                => p_rt_end_dt5,
        --
        p_prv_rt_val               => l_dummy_number,
        p_prv_ann_rt_val           => l_dummy_number,
        p_imp_cvg_strt_dt          => p_imp_cvg_strt_dt); -- 8716870
    if g_debug then
      hr_utility.set_location(l_proc, 470);
    end if;
  end if;
  if g_debug then
    hr_utility.set_location(l_proc, 480);
  end if;


  if p_enrt_rt_id6 is not null then
    if g_debug then
      hr_utility.set_location(l_proc, 490);
    end if;
    election_rate_information(
        p_enrt_mthd_cd             => p_enrt_mthd_cd,
        p_effective_date           => p_effective_date,
        p_prtt_enrt_rslt_id        => p_prtt_enrt_rslt_id,
        p_per_in_ler_id            => l_global_epe_rec.per_in_ler_id,
        p_person_id                => l_global_pil_rec.person_id,
        p_pgm_id                   => l_global_epe_rec.pgm_id,
        p_pl_id                    => l_global_epe_rec.pl_id,
        p_oipl_id                  => l_global_epe_rec.oipl_id,
        p_enrt_rt_id               => p_enrt_rt_id6,
        p_prtt_rt_val_id           => p_prtt_rt_val_id6,
        p_rt_val                   => p_rt_val6,
        p_ann_rt_val               => p_ann_rt_val6,
        p_enrt_cvg_strt_dt         => l_global_epe_rec.enrt_cvg_strt_dt,
        p_acty_ref_perd_cd         => l_global_pel_rec.acty_ref_perd_cd,
        p_datetrack_mode           => p_datetrack_mode,
        p_business_group_id        => p_business_group_id,
        p_bnft_amt_changed         => l_bnft_amt_changed,
        p_rt_strt_dt               => p_rt_strt_dt6,
        p_rt_end_dt                => p_rt_end_dt6,
        --
        p_prv_rt_val               => l_dummy_number,
        p_prv_ann_rt_val           => l_dummy_number,
        p_imp_cvg_strt_dt          => p_imp_cvg_strt_dt); -- 8716870
    if g_debug then
      hr_utility.set_location(l_proc, 500);
    end if;
  end if;
  if g_debug then
    hr_utility.set_location(l_proc, 510);
  end if;


  if p_enrt_rt_id7 is not null then
    if g_debug then
      hr_utility.set_location(l_proc, 520);
    end if;
    election_rate_information(
        p_enrt_mthd_cd             => p_enrt_mthd_cd,
        p_effective_date           => p_effective_date,
        p_prtt_enrt_rslt_id        => p_prtt_enrt_rslt_id,
        p_per_in_ler_id            => l_global_epe_rec.per_in_ler_id,
        p_person_id                => l_global_pil_rec.person_id,
        p_pgm_id                   => l_global_epe_rec.pgm_id,
        p_pl_id                    => l_global_epe_rec.pl_id,
        p_oipl_id                  => l_global_epe_rec.oipl_id,
        p_enrt_rt_id               => p_enrt_rt_id7,
        p_prtt_rt_val_id           => p_prtt_rt_val_id7,
        p_rt_val                   => p_rt_val7,
        p_ann_rt_val               => p_ann_rt_val7,
        p_enrt_cvg_strt_dt         => l_global_epe_rec.enrt_cvg_strt_dt,
        p_acty_ref_perd_cd         => l_global_pel_rec.acty_ref_perd_cd,
        p_datetrack_mode           => p_datetrack_mode,
        p_business_group_id        => p_business_group_id,
        p_bnft_amt_changed         => l_bnft_amt_changed,
        p_rt_strt_dt               => p_rt_strt_dt7,
        p_rt_end_dt                => p_rt_end_dt7,
        --
        p_prv_rt_val               => l_dummy_number,
        p_prv_ann_rt_val           => l_dummy_number,
        p_imp_cvg_strt_dt          => p_imp_cvg_strt_dt); -- 8716870
    if g_debug then
      hr_utility.set_location(l_proc, 530);
    end if;
  end if;
  if g_debug then
    hr_utility.set_location(l_proc, 540);
  end if;


  if p_enrt_rt_id8 is not null then
    if g_debug then
      hr_utility.set_location(l_proc, 550);
    end if;
    election_rate_information(
        p_enrt_mthd_cd             => p_enrt_mthd_cd,
        p_effective_date           => p_effective_date,
        p_prtt_enrt_rslt_id        => p_prtt_enrt_rslt_id,
        p_per_in_ler_id            => l_global_epe_rec.per_in_ler_id,
        p_person_id                => l_global_pil_rec.person_id,
        p_pgm_id                   => l_global_epe_rec.pgm_id,
        p_pl_id                    => l_global_epe_rec.pl_id,
        p_oipl_id                  => l_global_epe_rec.oipl_id,
        p_enrt_rt_id               => p_enrt_rt_id8,
        p_prtt_rt_val_id           => p_prtt_rt_val_id8,
        p_rt_val                   => p_rt_val8,
        p_ann_rt_val               => p_ann_rt_val8,
        p_enrt_cvg_strt_dt         => l_global_epe_rec.enrt_cvg_strt_dt,
        p_acty_ref_perd_cd         => l_global_pel_rec.acty_ref_perd_cd,
        p_datetrack_mode           => p_datetrack_mode,
        p_business_group_id        => p_business_group_id,
        p_bnft_amt_changed         => l_bnft_amt_changed,
        p_rt_strt_dt               => p_rt_strt_dt8,
        p_rt_end_dt                => p_rt_end_dt8,
        --
        p_prv_rt_val               => l_dummy_number,
        p_prv_ann_rt_val           => l_dummy_number,
        p_imp_cvg_strt_dt          => p_imp_cvg_strt_dt); -- 8716870
    if g_debug then
      hr_utility.set_location(l_proc, 560);
    end if;
  end if;
  if g_debug then
    hr_utility.set_location(l_proc, 570);
  end if;


  if p_enrt_rt_id9 is not null then
    if g_debug then
      hr_utility.set_location(l_proc, 580);
    end if;
    election_rate_information(
        p_enrt_mthd_cd             => p_enrt_mthd_cd,
        p_effective_date           => p_effective_date,
        p_prtt_enrt_rslt_id        => p_prtt_enrt_rslt_id,
        p_per_in_ler_id            => l_global_epe_rec.per_in_ler_id,
        p_person_id                => l_global_pil_rec.person_id,
        p_pgm_id                   => l_global_epe_rec.pgm_id,
        p_pl_id                    => l_global_epe_rec.pl_id,
        p_oipl_id                  => l_global_epe_rec.oipl_id,
        p_enrt_rt_id               => p_enrt_rt_id9,
        p_prtt_rt_val_id           => p_prtt_rt_val_id9,
        p_rt_val                   => p_rt_val9,
        p_ann_rt_val               => p_ann_rt_val9,
        p_enrt_cvg_strt_dt         => l_global_epe_rec.enrt_cvg_strt_dt,
        p_acty_ref_perd_cd         => l_global_pel_rec.acty_ref_perd_cd,
        p_datetrack_mode           => p_datetrack_mode,
        p_business_group_id        => p_business_group_id,
        p_bnft_amt_changed         => l_bnft_amt_changed,
        p_rt_strt_dt               => p_rt_strt_dt9,
        p_rt_end_dt                => p_rt_end_dt9,
        --
        p_prv_rt_val               => l_dummy_number,
        p_prv_ann_rt_val           => l_dummy_number,
        p_imp_cvg_strt_dt          => p_imp_cvg_strt_dt);  -- 8716870
    if g_debug then
      hr_utility.set_location(l_proc, 590);
    end if;
  end if;
  if g_debug then
    hr_utility.set_location(l_proc, 600);
  end if;


  if p_enrt_rt_id10 is not null then
    if g_debug then
      hr_utility.set_location(l_proc, 610);
    end if;
    election_rate_information(
        p_enrt_mthd_cd              => p_enrt_mthd_cd,
        p_effective_date            => p_effective_date,
        p_prtt_enrt_rslt_id         => p_prtt_enrt_rslt_id,
        p_per_in_ler_id             => l_global_epe_rec.per_in_ler_id,
        p_person_id                 => l_global_pil_rec.person_id,
        p_pgm_id                    => l_global_epe_rec.pgm_id,
        p_pl_id                     => l_global_epe_rec.pl_id,
        p_oipl_id                   => l_global_epe_rec.oipl_id,
        p_enrt_rt_id                => p_enrt_rt_id10,
        p_prtt_rt_val_id            => p_prtt_rt_val_id10,
        p_rt_val                    => p_rt_val10,
        p_ann_rt_val                => p_ann_rt_val10,
        p_enrt_cvg_strt_dt          => l_global_epe_rec.enrt_cvg_strt_dt,
        p_acty_ref_perd_cd          => l_global_pel_rec.acty_ref_perd_cd,
        p_datetrack_mode            => p_datetrack_mode,
        p_business_group_id         => p_business_group_id,
        p_bnft_amt_changed          => l_bnft_amt_changed,
        p_rt_strt_dt                => p_rt_strt_dt10,
        p_rt_end_dt                 => p_rt_end_dt10,
        --
        p_prv_rt_val                => l_dummy_number,
        p_prv_ann_rt_val            => l_dummy_number,
        p_imp_cvg_strt_dt           => p_imp_cvg_strt_dt); -- 8716870
    if g_debug then
      hr_utility.set_location(l_proc, 620);
    end if;
  end if;
  --
  -- If the coverage through date has been passed in, it means we have to update
  -- the result record with the same.
  --
  if p_enrt_cvg_thru_dt is not null and
     p_prtt_enrt_rslt_id is not null then
     --
     -- If the result was created in the same run, then the mode will be insert.
     -- In this case, we can only do update in correction mode.
     --
     if p_datetrack_mode = hr_api.g_insert then
        l_datetrack_mode := hr_api.g_correction;
     else
        l_datetrack_mode := p_datetrack_mode;
     end if;
     --
     ben_PRTT_ENRT_RESULT_api.delete_enrollment(
        p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
       ,p_per_in_ler_id              => l_global_epe_rec.per_in_ler_id
       ,p_business_group_id          => l_global_epe_rec.business_group_id
       ,p_effective_start_date       => p_effective_start_date
       ,p_effective_end_date         => p_effective_end_date
       ,p_object_version_number      => p_object_version_number
       ,p_effective_date             => p_effective_date
       ,p_datetrack_mode             => p_datetrack_mode
       ,p_multi_row_validate         => FALSE
       ,p_source                     => 'benelinf'
       ,p_lee_rsn_id                 => l_global_pel_rec.lee_rsn_id
       ,p_enrt_perd_id               => l_global_pel_rec.enrt_perd_id
       ,p_enrt_cvg_thru_dt           => p_enrt_cvg_thru_dt
       ,p_mode                       => 'CVG_END_DATE_ENTERABLE'
     );
  end if;
  --
  ben_det_enrt_rates.set_global_enrt_rslt
     (p_prtt_enrt_rslt_id         => p_prtt_enrt_rslt_id);
  --
  -- Set the out parameters
  --
  p_dpnt_actn_warning := l_dpnt_actn_warning;
  p_bnf_actn_warning := l_bnf_actn_warning;
  p_ctfn_actn_warning := l_ctfn_actn_warning;
  --
  -- null globals to prevent bleeding
  --
  g_enrt_bnft_id:=null;
  g_bnft_val:=null;
  g_elig_per_elctbl_chc_id:=null;
  ben_global_enrt.clear_enb
       (p_global_enb_rec         => l_global_enb_rec);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;

  if g_debug then
    hr_utility.set_location('Leaving:'||l_proc, 999);
  end if;

exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    if p_called_from_sspnd = 'N' then
       ROLLBACK TO election_information_savepoint;
    else
       ROLLBACK TO election_information_sspnd;
    end if;

    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_prtt_enrt_interim_id:=null;
   ben_sspndd_enrollment.g_use_new_result :=false  ; -- bug 5653168

    if g_debug then
      hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    --
    -- null globals to prevent bleeding
    --
    g_enrt_bnft_id:=null;
    g_bnft_val:=null;
    g_elig_per_elctbl_chc_id:=null;
    ben_sspndd_enrollment.g_use_new_result:=false;   -- bug 5653168
    --
    if p_called_from_sspnd = 'N' then
       ROLLBACK TO election_information_savepoint;
    else
       ROLLBACK TO election_information_sspnd;
    end if;
    raise;
    --

end election_information;
-- ----------------------------------------------------------------------------
-- |-----------------------------< MANAGE_ENRT_BNFT >-------------------------|
-- ----------------------------------------------------------------------------
procedure MANAGE_ENRT_BNFT
              (p_prtt_enrt_rslt_id     IN     number
              ,p_enrt_bnft_id          IN     number default null
              ,p_object_version_number in out nocopy number
              ,p_business_group_id     in     number
              ,p_effective_date        in     date
              ,p_per_in_ler_id         in     number
              ,p_created_by            in     varchar2 default null
              ,p_creation_date         in     date     default null
              )IS
  l_proc         varchar2(72) ;
  cursor c1 is
        select ebr.enrt_bnft_id,
               ebr.object_version_number
          from ben_enrt_bnft ebr,
               ben_elig_per_elctbl_chc epe,
               ben_per_in_ler pil
         where ebr.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id and
               ( p_enrt_bnft_id is null OR
                 ebr.enrt_bnft_id <> p_enrt_bnft_id )
               and epe.elig_per_elctbl_chc_id=ebr.elig_per_elctbl_chc_id
               and pil.per_in_ler_id=epe.per_in_ler_id
               and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
               and pil.per_in_ler_id = p_per_in_ler_id ;
  BEGIN
    g_debug := hr_utility.debug_enabled;
    if g_debug then
      l_proc          := g_package||'manage_enrt_bnft';
      hr_utility.set_location('Entering:'||l_proc, 5);
    end if;
    if g_debug then
      hr_utility.set_location(' bnft:'|| to_char(p_enrt_bnft_id), 5);
    end if;
    if g_debug then
      hr_utility.set_location(' rslt:'|| to_char(p_prtt_enrt_rslt_id), 15);
    end if;
    if g_debug then
      hr_utility.set_location(' enb_ovn:'|| to_char(p_object_version_number), 15);
    end if;

    for rec in c1 loop
        if g_debug then
          hr_utility.set_location(l_proc, 10);
        end if;
        -- Update any enrollment benefit records that may have had the result id
        -- on them from previous enrollments.  Set rslt id = null.
        ben_enrt_bnft_api.update_enrt_bnft
                (p_enrt_bnft_id           => rec.enrt_bnft_id
                ,p_effective_date         => p_effective_date
                ,p_object_version_number  => rec.object_version_number
                ,p_business_group_id      => p_business_group_id
                ,p_prtt_enrt_rslt_id      => NULL
                ,p_program_application_id =>fnd_global.prog_appl_id
                ,p_program_id             =>fnd_global.conc_program_id
                ,p_request_id             =>fnd_global.conc_request_id
                ,p_program_update_date    =>sysdate
                );
        if g_debug then
          hr_utility.set_location(l_proc, 15);
        end if;
    end loop;
    if g_debug then
      hr_utility.set_location(l_proc, 20);
    end if;

    -- need this for the new enrolment

    if (p_enrt_bnft_id is not NULL) then
        if g_debug then
          hr_utility.set_location(l_proc, 30);
        end if;
        ben_enrt_bnft_api.update_enrt_bnft
                (p_enrt_bnft_id           => p_enrt_bnft_id
                ,p_effective_date         => p_effective_date
                ,p_object_version_number  => p_object_version_number
                ,p_business_group_id      => p_business_group_id
                ,p_prtt_enrt_rslt_id      => p_prtt_enrt_rslt_id
                ,p_program_application_id => fnd_global.prog_appl_id
                ,p_program_id             => fnd_global.conc_program_id
                ,p_request_id             => fnd_global.conc_request_id
                ,p_program_update_date    => sysdate
                );
        if g_debug then
          hr_utility.set_location(l_proc, 40);
        end if;
    end if;
    if g_debug then
      hr_utility.set_location('Leaving:'||l_proc, 99);
    end if;
END MANAGE_ENRT_BNFT;
--
--
procedure election_information_w
  (p_validate               in varchar2 default 'N'
  ,p_elig_per_elctbl_chc_id in number
  ,p_prtt_enrt_rslt_id      in number
  ,p_effective_date         in date
  ,p_enrt_mthd_cd           in varchar2
  ,p_enrt_bnft_id           in number
  ,p_bnft_val               in number default null
  ,p_enrt_rt_id             in number default null
  ,p_prtt_rt_val_id         in number
  ,p_rt_val                 in number default null
  ,p_ann_rt_val             in number default null
  ,p_datetrack_mode         in varchar2
  ,p_suspend_flag           in varchar2
  ,p_effective_start_date   in date
  ,p_object_version_number  in number
  ,p_business_group_id      in  number
  ,p_enrt_rt_id2            in number default null
  ,p_prtt_rt_val_id2        in number
  ,p_rt_val2                in number default null
  ,p_ann_rt_val2            in number default null
  ,p_enrt_rt_id3            in number default null
  ,p_prtt_rt_val_id3        in number
  ,p_rt_val3                in number default null
  ,p_ann_rt_val3            in number default null
  ,p_enrt_rt_id4            in number default null
  ,p_prtt_rt_val_id4        in number
  ,p_rt_val4                in number default null
  ,p_ann_rt_val4            in number default null
  ,p_person_id              in number default null
  ,p_enrt_cvg_strt_dt       in date   default null
  ,p_enrt_cvg_thru_dt       in date   default null
  ,p_rt_update_mode         in varchar2 default null
  ,p_rt_strt_dt1            in date   default null
  ,p_rt_end_dt1             in date   default null
  ,p_rt_strt_dt_cd1         in varchar2 default null
  ,p_return_status          out nocopy varchar2
  ) is

  --
  l_effective_date       date := trunc(sysdate);
  l_effective_start_date date := p_effective_start_date;
  l_api_error            boolean;
  l_proc                 varchar2(60) := 'ben_election_information.election_information_w outer';
  l_trace_param          varchar2(30);
  l_trace_on             boolean;

  --
begin
  l_trace_param := null;
  l_trace_on := false;
  --
  fnd_msg_pub.initialize;
--  hr_utility.trace_on(null,'BENELINF');

  l_trace_param := fnd_profile.value('BEN_SS_TRACE_VALUE');

  --
  if l_trace_param = 'BENELINF' then
     l_trace_on := true;
  else
     l_trace_on := false;
  end if;
  --
  if l_trace_on then
    hr_utility.trace_on(null,'BENELINF');
  end if;
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_utility.set_location('l_trace_param : '|| l_trace_param, 5);
  --
  if p_effective_date is not null then
  --  l_effective_date := to_date(p_effective_date, 'YYYY/MM/DD');
    l_effective_date := p_effective_date;
  end if;
  --
  election_information_w
   (p_validate               => p_validate
   ,p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id
   ,p_prtt_enrt_rslt_id      => p_prtt_enrt_rslt_id
   ,p_effective_date         => l_effective_date
   ,p_enrt_mthd_cd           => p_enrt_mthd_cd
   ,p_enrt_bnft_id           => p_enrt_bnft_id
   ,p_bnft_val               => p_bnft_val
   ,p_enrt_rt_id1            => p_enrt_rt_id
   ,p_prtt_rt_val_id1        => p_prtt_rt_val_id
   ,p_rt_val1                => p_rt_val
   ,p_ann_rt_val1            => p_ann_rt_val
   ,p_enrt_rt_id2            => p_enrt_rt_id2
   ,p_prtt_rt_val_id2        => p_prtt_rt_val_id2
   ,p_rt_val2                => p_rt_val2
   ,p_ann_rt_val2            => p_ann_rt_val2
   ,p_enrt_rt_id3            => p_enrt_rt_id3
   ,p_prtt_rt_val_id3        => p_prtt_rt_val_id3
   ,p_rt_val3                => p_rt_val3
   ,p_ann_rt_val3            => p_ann_rt_val3
   ,p_enrt_rt_id4            => p_enrt_rt_id4
   ,p_prtt_rt_val_id4        => p_prtt_rt_val_id4
   ,p_rt_val4                => p_rt_val4
   ,p_ann_rt_val4            => p_ann_rt_val4
   ,p_datetrack_mode         => p_datetrack_mode
   ,p_suspend_flag           => p_suspend_flag
   ,p_effective_start_date   => l_effective_start_date
   ,p_object_version_number  => p_object_version_number
   ,p_business_group_id      => p_business_group_id
   ,p_person_id              => p_person_id
   ,p_enrt_cvg_strt_dt       => p_enrt_cvg_strt_dt
   ,p_enrt_cvg_thru_dt       => p_enrt_cvg_thru_dt
   ,p_rt_update_mode         => p_rt_update_mode
   ,p_rt_strt_dt1            => p_rt_strt_dt1
   ,p_rt_end_dt1             => p_rt_end_dt1
   ,p_rt_strt_dt_cd1         => p_rt_strt_dt_cd1
   ,p_api_error              => l_api_error);

   IF (l_api_error)
    THEN
      p_return_status :='E';
   ELSE
      p_return_status :='S';
   END IF;
   --
   hr_utility.set_location('Leaving:'||l_proc, 10);
   --
   if l_trace_on then
     hr_utility.trace_off;
     l_trace_param := null;
     l_trace_on := false;
   end if;
--
exception
  --
  when app_exception.application_exception then	--Bug 4387247
    p_return_status := 'E';
    fnd_msg_pub.add;
    --Bug 4436578
    ben_det_enrt_rates.clear_globals;
    if l_trace_on then
      hr_utility.trace_off;
      l_trace_on := false;
      l_trace_param := null;
    end if;
  when others then
    p_return_status := 'E';
    --Bug 4387247
    fnd_message.set_name('PER','FFU10_GENERAL_ORACLE_ERROR');
    fnd_message.set_token('2',substr(sqlerrm,1,200));
    fnd_msg_pub.add;
    ben_det_enrt_rates.clear_globals;
    if l_trace_on then
      hr_utility.trace_off;
      l_trace_on := false;
      l_trace_param := null;
    end if;
end election_information_w;
--
--
procedure election_information_w
  (p_validate               in varchar2 default 'N'
  ,p_elig_per_elctbl_chc_id in number
  ,p_prtt_enrt_rslt_id      in number
  ,p_effective_date         in date
  ,p_person_id              in number default null
  ,p_enrt_mthd_cd           in varchar2
  ,p_enrt_bnft_id           in number
  ,p_bnft_val               in number default null
  ,p_enrt_rt_id1            in number default null
  ,p_prtt_rt_val_id1        in number default null
  ,p_rt_val1                in number default null
  ,p_ann_rt_val1            in number default null
  ,p_rt_strt_dt1            in date   default null
  ,p_rt_end_dt1             in date   default null
  ,p_rt_strt_dt_cd1         in varchar2 default null
  ,p_enrt_rt_id2            in number default null
  ,p_prtt_rt_val_id2        in number default null
  ,p_rt_val2                in number default null
  ,p_ann_rt_val2            in number default null
  ,p_rt_strt_dt2            in date   default null
  ,p_rt_end_dt2             in date   default null
  ,p_enrt_rt_id3            in number default null
  ,p_prtt_rt_val_id3        in number default null
  ,p_rt_val3                in number default null
  ,p_ann_rt_val3            in number default null
  ,p_rt_strt_dt3            in date   default null
  ,p_rt_end_dt3             in date   default null
  ,p_enrt_rt_id4            in number default null
  ,p_prtt_rt_val_id4        in number default null
  ,p_rt_val4                in number default null
  ,p_ann_rt_val4            in number default null
  ,p_rt_strt_dt4            in date   default null
  ,p_rt_end_dt4             in date   default null
  ,p_datetrack_mode         in varchar2
  ,p_suspend_flag           in varchar2
  ,p_effective_start_date   in date
  ,p_object_version_number  in number
  ,p_business_group_id      in number
  ,p_enrt_cvg_strt_dt       in date
  ,p_enrt_cvg_thru_dt       in date
  ,p_rt_update_mode         in varchar2 default null
  ,p_api_error              out nocopy boolean)
is
  l_validate boolean := false;
  l_datetrack_mode   varchar2(30) := p_datetrack_mode;
  l_suspend_flag     varchar2(30) := p_suspend_flag;
  l_dpnt_actn_warning boolean;
  l_bnf_actn_warning  boolean;
  l_ctfn_actn_warning boolean;
  l_object_version_number number := p_object_version_number;
  l_prtt_enrt_rslt_id number := p_prtt_enrt_rslt_id;
  l_prtt_rt_val_id1   number := p_prtt_rt_val_id1;
  l_prtt_rt_val_id2   number := p_prtt_rt_val_id2;
  l_prtt_rt_val_id3   number := p_prtt_rt_val_id3;
  l_prtt_rt_val_id4   number;
  l_prtt_rt_val_id5   number;
  l_prtt_rt_val_id6   number;
  l_prtt_rt_val_id7   number;
  l_prtt_rt_val_id8   number;
  l_prtt_rt_val_id9   number;
  l_prtt_rt_val_id10  number;
  l_prtt_enrt_interim_id number;
  l_effective_start_date date;
  l_effective_end_date   date;
  --
    -- Bug 4216475
  -- Changing the cursor to bring up val alone for validation
  -- to handle cases where the default is outside the coverage
  -- range and the benefit val is not defined (Enterable)

  cursor c_bnft is
     select enb.val val,-- nvl(enb.val, enb.dflt_val) val, Bug 4216475
            enb.mn_val,
            enb.mx_val,
            enb.incrmt_val
     from   ben_enrt_bnft enb
     where  enb.enrt_bnft_id = p_enrt_bnft_id;
  --
  -- open c_pl_opt_name cursor only if error needs to be displayed.
  --
  cursor c_pl_opt_name is
     select pln.name || ' '|| opt.name
     from   ben_elig_per_elctbl_chc epe,
            ben_pl_f                pln,
            ben_oipl_f              oipl,
            ben_opt_f               opt
     where  epe.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id
     and    epe.pl_id                  = pln.pl_id
     and    epe.oipl_id                = oipl.oipl_id(+)
     and    oipl.opt_id                = opt.opt_id(+)
     and    p_effective_date between
            pln.effective_start_date and pln.effective_end_date
     and    p_effective_date between
            oipl.effective_start_date(+) and oipl.effective_end_date(+)
     and    p_effective_date between
            opt.effective_start_date(+) and opt.effective_end_date(+);
	--
	-- 4543745
	cursor c_elinf is
	   select epe.crntly_enrd_flag
           ,epe.elctbl_flag
           ,epe.mndtry_flag
		 from		ben_elig_per_elctbl_chc epe
		 where	epe.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id;
  --
  l_bnft              c_bnft%rowtype;
	l_elinf							c_elinf%rowtype;
  l_pl_opt_name       varchar2(600) := null; -- UTF8 Change Bug 2254683
  l_proc              varchar2(60)  := 'ben_election_information.election_information_w inner';
  --
begin
  --
  hr_utility.set_location('Entering : '||l_proc, 10);
  p_api_error := false;
  --
	-- 4543745
	--
	open c_elinf;
	fetch c_elinf into l_elinf;
  close c_elinf;

	if (l_elinf.crntly_enrd_flag = 'Y' and l_elinf.elctbl_flag = 'N' and l_elinf.mndtry_flag = 'N') then
    hr_utility.set_location('Returning without calling election_information for cannot change enrollment', 80.1);
	  return;
	end if;

  if p_validate = 'Y' then
    l_validate := true;
  end if;
  --
  if l_datetrack_mode = hr_api.g_correction then
    if p_effective_date = p_effective_start_date then
      null;
    else
      l_datetrack_mode := hr_api.g_update;
    end if;
  end if;
  --
  ben_env_object.init(p_business_group_id  => p_business_group_id,
                        p_effective_date     => p_effective_date,
                        p_thread_id          => 1,
                        p_chunk_size         => 1,
                        p_threads            => 1,
                        p_max_errors         => 1,
                        p_benefit_action_id  => null);

  --
  if p_enrt_bnft_id is not null and p_bnft_val is not null then
    --
    open c_bnft;
    fetch c_bnft into l_bnft;
    close c_bnft;
    --
    if nvl(l_bnft.val,-999) <> p_bnft_val then
      --
      --  Bug 3181158, added nvl in 'if' to handle
      --  'EnrtValAtEnrt + no default value' condition
      --
      if ((l_bnft.mn_val is not null and p_bnft_val < l_bnft.mn_val) or
          (l_bnft.mx_val is not null and p_bnft_val > l_bnft.mx_val)) then
        --
        -- Open the c_pl_opt_name cursor only if error needs to be displayed.
        --
        open  c_pl_opt_name;
        fetch c_pl_opt_name into l_pl_opt_name;
        close c_pl_opt_name;
        --
        fnd_message.set_name('BEN','BEN_92394_OUT_OF_RANGE');
        fnd_message.set_token('MINIMUM', l_bnft.mn_val);
        fnd_message.set_token('MAXIMUM', l_bnft.mx_val);
        fnd_message.set_token('PLAN', l_pl_opt_name);
        fnd_message.raise_error;
        --
      end if;
      --
      if l_bnft.mn_val is not null and
         l_bnft.incrmt_val is not null and
         mod(p_bnft_val-l_bnft.mn_val, l_bnft.incrmt_val) <> 0 then
        --
        -- Open the c_pl_opt_name cursor only if error needs to be displayed.
        --
        open  c_pl_opt_name;
        fetch c_pl_opt_name into l_pl_opt_name;
        close c_pl_opt_name;
        --
        fnd_message.set_name('BEN','BEN_92395_NOT_IN_INCR');
        fnd_message.set_token('INCREMENT', l_bnft.incrmt_val);
        fnd_message.set_token('PLAN', l_pl_opt_name);
        fnd_message.raise_error;
        --
      end if;
      --
    end if;
    --
  end if;
  --

 if p_prtt_rt_val_id1 is not null and
     p_rt_strt_dt_cd1 is not null and
     p_rt_strt_dt_cd1 = 'ENTRBL'        then

    ben_determine_rate_chg.prv_delete
      (p_prtt_rt_val_id     => p_prtt_rt_val_id1
      ,p_enrt_rt_id         => p_enrt_rt_id1
      ,p_rt_val             => p_rt_val1
      ,p_rt_strt_dt         => p_rt_strt_dt1
      ,p_business_group_id  => p_business_group_id
      ,p_prtt_enrt_rslt_id  => p_prtt_enrt_rslt_id
      ,p_person_id          => p_person_id
      ,p_effective_date     => p_effective_date
      ,p_mode               => p_rt_update_mode);
 end if;
 --
 ben_election_information.election_information
  (p_validate               => l_validate
  ,p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id
  ,p_prtt_enrt_rslt_id      => l_prtt_enrt_rslt_id
  ,p_effective_date         => p_effective_date
  ,p_enrt_mthd_cd           => p_enrt_mthd_cd
  ,p_enrt_bnft_id           => p_enrt_bnft_id
  ,p_bnft_val               => p_bnft_val
  ,p_enrt_cvg_strt_dt       => p_enrt_cvg_strt_dt
  ,p_enrt_cvg_thru_dt       => p_enrt_cvg_thru_dt
  ,p_enrt_rt_id1            => p_enrt_rt_id1
  ,p_prtt_rt_val_id1        => l_prtt_rt_val_id1
  ,p_rt_val1                => p_rt_val1
  ,p_ann_rt_val1            => p_ann_rt_val1
  ,p_rt_strt_dt1            => p_rt_strt_dt1
  ,p_rt_end_dt1             => p_rt_end_dt1
  ,p_enrt_rt_id2            => p_enrt_rt_id2
  ,p_prtt_rt_val_id2        => l_prtt_rt_val_id2
  ,p_rt_val2                => p_rt_val2
  ,p_ann_rt_val2            => p_ann_rt_val2
  ,p_rt_strt_dt2            => p_rt_strt_dt2
  ,p_rt_end_dt2             => p_rt_end_dt2
  ,p_enrt_rt_id3            => p_enrt_rt_id3
  ,p_prtt_rt_val_id3        => l_prtt_rt_val_id3
  ,p_rt_val3                => p_rt_val3
  ,p_ann_rt_val3            => p_ann_rt_val3
  ,p_rt_strt_dt3            => p_rt_strt_dt3
  ,p_rt_end_dt3             => p_rt_end_dt3
  ,p_enrt_rt_id4            => p_enrt_rt_id4
  ,p_prtt_rt_val_id4        => l_prtt_rt_val_id4
  ,p_rt_val4                => p_rt_val4
  ,p_ann_rt_val4            => p_ann_rt_val4
  ,p_rt_strt_dt4            => p_rt_strt_dt4
  ,p_rt_end_dt4             => p_rt_end_dt4
  ,p_enrt_rt_id5            => null
  ,p_prtt_rt_val_id5        => l_prtt_rt_val_id5
  ,p_rt_val5                => null
  ,p_ann_rt_val5            => null
  ,p_enrt_rt_id6            => null
  ,p_prtt_rt_val_id6        => l_prtt_rt_val_id6
  ,p_rt_val6                => null
  ,p_ann_rt_val6            => null
  ,p_enrt_rt_id7            => null
  ,p_prtt_rt_val_id7        => l_prtt_rt_val_id7
  ,p_rt_val7                => null
  ,p_ann_rt_val7            => null
  ,p_enrt_rt_id8            => null
  ,p_prtt_rt_val_id8        => l_prtt_rt_val_id8
  ,p_rt_val8                => null
  ,p_ann_rt_val8            => null
  ,p_enrt_rt_id9            => null
  ,p_prtt_rt_val_id9        => l_prtt_rt_val_id9
  ,p_rt_val9                => null
  ,p_ann_rt_val9            => null
  ,p_enrt_rt_id10           => null
  ,p_prtt_rt_val_id10       => l_prtt_rt_val_id10
  ,p_rt_val10               => null
  ,p_ann_rt_val10           => null
  ,p_datetrack_mode         => l_datetrack_mode
  ,p_suspend_flag           => l_suspend_flag
  ,p_called_from_sspnd      => 'N'
  ,p_effective_start_date   => l_effective_start_date
  ,p_effective_end_date     => l_effective_end_date
  ,p_object_version_number  => l_object_version_number
  ,p_prtt_enrt_interim_id   => l_prtt_enrt_interim_id
  ,p_business_group_id      => p_business_group_id
  ,p_pen_attribute_category =>  null
  ,p_pen_attribute1         =>  null
  ,p_pen_attribute2         =>  null
  ,p_pen_attribute3         =>  null
  ,p_pen_attribute4         =>  null
  ,p_pen_attribute5         =>  null
  ,p_pen_attribute6         =>  null
  ,p_pen_attribute7         =>  null
  ,p_pen_attribute8         =>  null
  ,p_pen_attribute9         =>  null
  ,p_pen_attribute10        =>  null
  ,p_pen_attribute11        =>  null
  ,p_pen_attribute12        =>  null
  ,p_pen_attribute13        =>  null
  ,p_pen_attribute14        =>  null
  ,p_pen_attribute15        =>  null
  ,p_pen_attribute16        =>  null
  ,p_pen_attribute17        =>  null
  ,p_pen_attribute18        =>  null
  ,p_pen_attribute19        =>  null
  ,p_pen_attribute20        =>  null
  ,p_pen_attribute21        =>  null
  ,p_pen_attribute22        =>  null
  ,p_pen_attribute23        =>  null
  ,p_pen_attribute24        =>  null
  ,p_pen_attribute25        =>  null
  ,p_pen_attribute26        =>  null
  ,p_pen_attribute27        =>  null
  ,p_pen_attribute28        =>  null
  ,p_pen_attribute29        =>  null
  ,p_pen_attribute30        =>  null
  ,p_dpnt_actn_warning      =>  l_dpnt_actn_warning
  ,p_bnf_actn_warning       =>  l_bnf_actn_warning
  ,p_ctfn_actn_warning      =>  l_ctfn_actn_warning);

  hr_utility.set_location('Leaving:'||l_proc, 20);
  --
end election_information_w;

end ben_election_information;

/
