--------------------------------------------------------
--  DDL for Package Body BEN_DERIVE_PART_AND_RATE_FACTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_DERIVE_PART_AND_RATE_FACTS" AS
/* $Header: bendrpar.pkb 120.4.12000000.3 2007/06/22 07:30:06 nhunur ship $ */
/*
+==============================================================================+
|            Copyright (c) 1997 Oracle Corporation                            |
|               Redwood Shores, California, USA                               |
|                    All rights reserved.                                     |
+==============================================================================+
--
Name
    Derive participation and rate factors
Purpose
        This package is used to derive the participation and rate factors
        that are applicable to a person who is eligible for a particular
        comp object.
History
        Date             Who        Version    What?
        ----             ---        -------    -----
        14 Dec 97        G Perry    110.0      Created.
        15 Dec 97        G Perry    110.1      Changed how we handle a breach
                                               and moved the cache structure to
                                               the header thus making it more
                                               accessible.
        04 Jan 98        G Perry    110.2      Corrections following review
                                               with DW, TM, WS. Added logging
                                               information.
        05 Jan 98        G Perry    110.3      Changed references of
                                               ben_derive_part_rate_and_facts.
                                               g_record_error to
                                               ben_manage_life_events.
                                               g_record_error.
        06 Jan 98        G Perry    110.4      No changes, someone arcsed this
                                               in as gperry, probably udatta.
        13 Jan 98        G Perry    110.5      Commented out nocopy certain sections
                                               as these will be corrected for
                                               beta drop 2.
        18 Jan 98        G Perry    110.6      Added in real error messages
                                               which are seeded in seed11.
        20 Jan 98        G Perry    110.7      Changed 805 application_id to use
                                               'BEN' for fnd_message.set_name.
        21 Jan 98        G Perry    110.8      Made caching more efficent such
                                               that it doesn't bother recaching
                                               when person hasn't changed.
        21 Jan 98        G Perry    110.9      Fixed calls to do_rounding so
                                               they use genutils function.
        24 Jan 98        G Perry    110.10     Added in extra cache details
                                               and added in extra codes for
                                               derivable factor processing.
        25 Jan 98        G Perry    110.11     Using lf_evt_ocrd_dt instead
                                               of strt_dt for c_le_date cursor.
        25 Jan 98        G Perry    110.12     Changed l_result to number so
                                               formula calls handle correctly.
        25 Jan 98        G Perry    110.13     Added call to do_uom to round by
                                               uom code.
        25 Jan 98        G Perry    110.14     Corrected logic in calculate_los.
        02 Feb 98        G Perry    110.15     Added real message for get_ler_id
                                               function.
        03 Feb 98        G Perry    110.16     Fixed period of service stuff so
                                               it creates a message in the log
                                               and sets the value of the los to
                                               null. Also added logic so that a
                                               derivable factor only gets added
                                               once.
        06 Mar 98        G Perry    110.17     Added new caching functions in
                                               order to minimize database hits.
                                               Additionally changed life events
                                               so they only fire once per person
        08 Apr 98        G Perry    110.18     Added get_calculated_age proc
                                               and added parameter to cache
                                               _data_structures.
        09 Apr 98        G Perry    110.19     Backport for BD2.
        13 Apr 98        G Perry    110.20     Changed do_uom call to genutils.
                                               Default calculations to months
                                               when no uom supplied.
        20 Apr 98        G Perry    110.21     Added in logic so we can trap
                                               cache retrieval bugs and also
                                               added in error messages where
                                               person has no DOB.
        22-Apr-98        THAYDEN    110.22     Rounding_uom to Rounding_cd
        29-Apr-98        G Perry    110.23     Derived values written to the
                                               log every time even when a
                                               temporal life event does not
                                               take place.
        18-May-98        G Perry    110.24     dbsynch up.
        27-May-98        G Perry    110.25     Added formula cover calls.
        03-Jun-98        G Perry    110.26     Corrected formula return types
                                               following meeting with WDS.
        04-Jun-98        G Perry    110.27     Fixed percent_fulltime so it
                                               uses budget_values correctly.
        11-Jun-98        G Perry    110.28     Added cache structures to
                                               handle temporal life events
                                               correctly so we only create
                                               them once.
        07-Jul-98        J Mohapatra 110.29    Added batch who cols to call
                                               of ben_ptnl_ler_for_per_api.creat
                                               e_ptnl_ler_for_per
        30-Jul-98        G Perry    110.30     Fixed error in calculate_percent
                                               _fulltime procedure.
        24-Aug-98        G Perry    110.31     Fixed 'STTDCOMP' for calulating
                                               comp level. Reorganised some
                                               code, improved calling to use
                                               ben_determine_date.
        26-Aug-98        G Perry    115.12     Changed comb_age_and_los to
                                               return cache structure frozen
                                               value.
        28-Aug-98        G Perry    115.13     Removed storing of old temporal
                                               life event dates. Used new logic
                                               per WDS. Now only create life
                                               events if prev elig per f rec.
                                               Uses real life event occured
                                               dates except for cmbn which
                                               has to compare to current life
                                               event and see if same scenario
                                               unfolds, i.e. same boundary
                                               broken.
        24-Oct-98        G Perry    115.14     Added c_elig_per_opt cursor
                                               for particpation override stuff
                                               for oipls.
        25-Oct-98        G Perry    115.15     Added support for benefits
                                               balance.
        26-Oct-98        G Perry    115.16     Fixed c_elig_per cursor
                                               so it uses parent for pgm
                                               where plan is in program.
        30-Oct-98        G Perry    115.17     Added fix to get a comp
                                               value at effective date if it
                                               does not exist for calculated
                                               date.
        23-Nov-98        G Perry    115.18     Added in caching routines for
                                               all factors and rates.
        24-Nov-98        G Perry    115.19     Added in routines to put
                                               derived factors to the log file.
                                               Fixed bug 1230.
        20-Dec-98        G Perry    115.20     Support for hours worked.
        18-Jan-99        G Perry    115.21     LED V ED
        08-Feb-99        G Perry    115.22     Added in ptnl_ler_trtmt_cd for
                                               when life events are created.
                                               Fixed logic per LM and WDS.
        15-Feb-99        G Perry    115.23     Changed way dates are calculated
                                               so that the calculated date for
                                               a temporal life event will always
                                               cross the boundary. This is used
                                               for codes APOCT1, AFDCM, AFDCPPY
                                               which can cause dates to be
                                               calced incorrectly.
        17-Feb-99        G Perry    115.24     Added columns ben_once_r_cntug_cd
                                               and elig_flag to allow once or
                                               continuing eligiblity to work.
        09-APR-99        mhoyes     115.26     Un-datetrack per_in_ler_f changes
        14-Apr-99        G Perry    115.27     Changed salary routine to
                                               reflect HR model changes.
        21-Apr-99        G Perry    115.28     Changes for temporal mode.
                                               set_temporal_ler_id
                                               get_temporal_ler_id
                                               Proc and Function above used in
                                               create_ptl_ler procedure.
        21-APR-1999      mhoyes     115.29   - Modified call to
                                               create_ptnl_ler_for_per.
        28-APR-1999      shdas      115.30     Added contexts to rule calls.
                                               (genutils.formula)
        05-MAY-1999      G Perry    115.31     Added support for PTIP and PLIP
                                               Added ben_comp_object calls.
        07-May-1999      T Guy      115.32     backport for Fidelity.
        07-May-1999      T Guy      115.33     Leapfrog
        06-MAY-1999      shdas      115.34     Added jurisdiction code and
                                               set_location messages before all
                                               rule calls.
        17-May-1999      bbulusu    115.35     Modified calls to ben_determine
                                               _date to pass in comp obj ids.
        17-May-1999      G Perry    115.36     Fixed bug 2027.
                                               LOS Calculation now uses ASD
                                               but if there is not one it uses
                                               DOH.
        18-Jun-1999      G Perry    115.37     Performance fixes.
                                               Added calls to ben_person_object
                                               and ben_seeddata_object.
        23-Jun-1999      G Perry    115.38     Added calls to ben_env_object
                                               so we no longer need g_last_pgm
                                               _id.
        01-Jul-1999      maagrawa   115.39     Modified min_max_breach procedure
                                               to check minimum and maximum
                                               boundary crossing from both
                                               sides. Also made changes in
                                               genutils.min_max_breach to
                                               check the same.
        09-Jul-1999      jcarpent   115.40     Added per_in_ler_restriction to
                                               elig_per(_opt) queries.
        20-JUL-1999      Gperry     115.41     genutils -> benutils package
                                               rename.
        22-JUL-1999      mhoyes     115.42   - Added new trace messages.
                                             - Replaced +0s.
        12-AUG-1999      tguy       115.43     Sync of version numbers
        12-AUG-1999      tguy       115.44     Added spouse/dependent age calc
                                               for imputed income
        18-AUG-1999      Gperry     115.45     Bug fix for bug 216.
        23-AUG-1999      Gperry     115.46     Performance fixes.
        26-AUG-1999      Gperry     115.47     Added benefits assignment calls
                                               when no employee assignment
                                               is found.
        31-AUG-1999      Pbodla     115.48     When called as part of what if
                                               analysis for compensation calc,
                                               hours worked return user entered
                                               values and do not call min_max_*
        15-SEP-1999      Gperry     115.49     Removed rates and factors from
                                               log. Performance increase.
        15-SEP-1999      Gperry     115.50     Added in use of environment
                                               program for cases where we are
                                               deriving dates at PLIP and PTIP
                                               levels.
        02-OCT-1999      Stee       115.51     Added new COBRA temporal events.
        07-OCT-1999      Stee       115.52     Added COBRA temporal event for
                                               disablity rate change.
        07-OCT-1999      Stee       115.53     Close c_get_dsblity_evt cursor.
        11-OCT-1999      Stee       115.54     Added a temporal event for cobra
                                               non-payment.
        03-NOV-1999      Tguy       115.55     Changes for added date codes for
                                               determining factors.
        09-NOV-1999      GPerry     115.56     Fix for bug 3855.
                                               Returns a null when a persons
                                               dob can not be found thus the
                                               error is hanlded by eligibility.
        09-NOV-1999      STee       115.57     Trigger cobra life events
                                               based on the cbr_inelg_rsn_cd
                                               if applicable. Fixed to only
                                               process COBRA temporal events if
                                               effective_date is <= to today's
                                               date.  Add temporal event for non
                                               or late first payment.
        15-NOV-1999      STee       115.58     Fix due date for subsequent
                                               payments.
        19-NOV-1999      GPERRY     115.59     Added new flags.
        22-NOV-1999      pbodla     115.60     Bug 3299 : Passed bnfts_bal_id to
                                               ben_determine_date.main when
                                               comp_lvl_det_cd, hrs_wkd_det_cd
                                               are evaluated.
        09-DEC-1999      pbodla     115.61   - Bug 3034 : When age, los, hwf, comp
                                               are calculated the rules are passed
                                               to ben_determine_date.main.
                                             - min_max_breach : added formula_id
                                               parameter.
        22-Dec-1999     lmcdonal    115.62     Add comment and remove duplicate
                                               join in get_pymt.
        10-jan-2000     pbodla      115.63   - run_rule function added to evaluate
                                               los_calc_rl. Code added to evaluate
                                               los_calc_rl.
        24-Jan-2000     lmcdonal    115.64     Add:
                                               los ohd calc, Bug 4069.
                                               los los_dt_to_use_cd rule call.
                                               hrs_wkd_calc_rl, Bug 1118113.
                                               comp_calc_rl, Bug 118118.
                                               Modify run_rule to handle dates.
        26-Jan-2000     stee        115.65     COBRA: Change the period of
                                               enrollment reached life event
                                               occurred date to be the day
                                               after the cobra eligibility end
                                               date. WWBUG# 1166172
        29-Jan-2000     lmcdonal    115.66     Determine_date.main needs person_id
                                               passed in.  Bug 1155064.
        04-Feb-2000     gperry      115.67     Moved cache_data_structures
                                               above the flags_exist call.
                                               This sets the ovridn_thru_dt so
                                               that override works when
                                               derivable factors do not exist.
                                               Fix for WWBUG 1169423.
        11-Feb-2000     jcarpent    115.68   - Pass los_dt_to_use_rl to rule fn
        14-Feb-2000     stee        115.69   - Added check when selecting
                                               cobra qualified beneficiary
                                               to ignore backed out nocopy event.
                                               bug# 1178633.
        18-Feb-2000     mhoyes      115.70   - Fixed bugs 4707 and 4708.
                                               Synched up nullification
                                               of LOS and AGE values and
                                               UOMs.
        22-Feb-2000     gperry      115.71     Fixed WWBUG 1118118.
        23-Feb-00       tguy        115.72     Fixed WWBUG 1178659,1161287,1120685
        23-Feb-00       gperry      115.73     Fixed WWBUG 1118113.
        26-Feb-00       mhoyes      115.74   - Added p_comp_obj_tree_row parameter
                                               to derive_rates_and_factors.
                                             - Phased out nocopy ben_env_object for comp
                                               object values.
        28-Feb-00       stee        115.75   - Added p_cbr_tmprl_evt_flag
                                               parameter.
        28-Feb-00       tguy        115.76     Fixed WWBUG 1179545.
        03-Mar-00       gperry      115.77     Fixed bugs caused by 115.76
        04-Mar-00       stee        115.78     Added ptip_id to
                                               determine_cobra_eligibility.
                                               COBRA by plan type.
        07-Mar-00       tguy        115.79     Fixed Inherited codes in LOS
                                               determination
        07-Mar-00       gperry      115.80     Fixed WWBUG 1195803.
        09-Mar-00       gperry      115.81     Added flag bit val for
                                               performance.
        23-Mar-00       gperry      115.82     Added in rate derivation for
                                               coverages and premiums.
        24-Mar-00       gperry      115.83     Added in handling for min and
                                               max cases where the min is null
                                               or max is null i.e. no max or
                                               no min flag has been set.
                                               Fix for WWBUG 1173013.
        31-Mar-00       gperry      115.84     Added oiplip support.
        04-Apr-00       mmogel      115.85     Added a token to message
                                               BEN_91340_CREATE_PTNL_LER
        05-Apr-00       stee        115.86     COBRA: get program type
                                               is program id is passed in.
        06-Apr-00       lmcdonal    115.87     debugging messages.
        06-Apr-00       gperry      115.88     Return the comp_rec and the
                                               oiplip_rec when no derivable
                                               factors exists. (1169423)
        13-Apr-00       pbodla      115.89   - Bug 5093 : p_ntfn_dt populated
                                               when the potential le is created.
        17-Apr-00       stee        115.90   - Trigger a period of
                                               enrollment change event
                                               when person is disabled at the
                                               time of the qualifying event.
                                               wwbug(1274212).
        03-May-00       stee        115.91   - Trigger the voluntary end
                                               of coverage event 2 days later
                                               if an event exist on the day
                                               after the cobra eligibiliy end
                                               date wwbug(1274211).
        22-May-00       mhoyes      115.92   - Added profiling messages.
        06-Jun-00       stee        115.93   - Trigger non-late payment event
                                               for cobra by plan type.
                                               Bug 5261.
        14-Jun-00       stee        115.94   - Use the system date to Trigger
                                               the cobra ineligible to
                                               participate event if this
                                               process is run ahead of time.
                                               bug #5263.
        20-Jun-00       stee        115.95   - Check derived factors based on
                                               a code selected by the user.
                                               Split cobra events into
                                               payments and non-payment events.
        27-Jun-00       mhoyes      115.96   - Removed nvls from c_elig_per_opt.
                                             - Reduced sysdate references.
                                             - Cached c_elig_per_opt for oiplips
                                               and plan in programs.
                                             - Cached c_elig_per for plips
                                               and plan in programs.
        27-Jun-00       gperry      115.97     Added age_calc_rl
        28-Jun-00       stee        115.98     COBRA: for first payment,
                                               check that the person paid
                                               within 45 days i.e. the due
                                               date is >= the date earned
                                               (date payment made).
        29-Jun-00       mhoyes      115.99   - Fixed numeric or value error
                                               problem for contacts who have no
                                               assignments.
                                             - Added context parameters.
        06-Jul-00       mhoyes      115.100  - Fixed null assignment id
                                               problem from 115.99.
        10-Jul-00       mhoyes      115.101  - p_oiplip_rec problem in
                                               cache_data_structures.
                                             - Passed in person context row.
        03-Aug-00       dharris     115.102  - modified create_ptl_ler to
                                               get the g_temp_ler_id instead of
                                               calling the fuction
                                               get_temporal_ler_id
                                             - Removed get_temporal_ler_id.
        18-Aug-00       jcarpent    115.103  - Fixed formula context to
                                               los_dt_to_use_rl.
                                               Tar 1052406.996.
        19-Aug-00       jcarpent    115.104  - 1385506. (same as above bug)
                                               but ptip level was not working.
                                               added cursor to run_rule.
        05-Sep-00       rchase      115.105  - Included person_id as an input
                                               to formual calls.  This resolves
                                               issues when processing dependents
                                               without assignment_ids. 1396949.
        14-SEP-00       gperry      115.106    Fixed bug 1237211 where combo
                                               age and los was not working.
        14-SEP-00       gperry      115.107    Fixed comp error.
        11-OCT-00       rchase      115.108  - Added the parameter pl typ id
                                               for context passing to underlying
                                               formula calls.
        06-NOV-00       rchase      115.109  - Added parameters to cvg and prem cache
                                               calls to trigger lf_evts.
                                               Bug 1433338 + 1350957.
        17-jan-01       tilak       115.110    derived facor calidation changed from
                                               < max to < max +1
        06-Apr-01       mhoyes      115.111  - Added p_calculate_only_mode for EFC.
        27-Aug-01       ikasire     115.113    Bug 1949361 fixes
        05-Sep-01       ikasire     115.114    Bug 1927010 Fixes
                                               1. calculate_age is modified completely.
                                               The existing process was checking
                                               the following execution order for
                                               derived factors in the rt_age_val
                                               calculation process.
                                               Rate->Coverage->Premium.
                                               When we found a df at rate and even if
                                               doesn't cross the boundary, we are then
                                               ignoring the dfs defined at Coverage and
                                               Premiums. Similary if there is one
                                               defined at coverage level, the process
                                               ignores the dfs defined at premium level.
                                               -- This is now fixed.
                                               2. age determination Code AFDCM.
                                               We were adding a month for the derived date
                                               in certain cases. Now that condition has
                                               been removed as it is not correct.
                                               3.We need to fix other procedures also,
                                               see bug for more details.
        10-Sep-01       ikasire     115.115    Bug 1977901 fixing the process as noted in
                                               115.114 modifications for the following
                                               derived factors.
                                               1. Length of Service
                                               2. Compensation Level
                                               3. Combined age and los
                                               4. Percent Full time
                                               5. Hours Worked
                                               Added the following new private procedures
                                               comp_level_min_max, percent_fulltime_min_max and
                                               hours_worked_min_max
        13-Sep-01       ikasire     115.116    Bug 1977901 to avoid getting the salary from
                                               the future records chages are made to the
                                               cursor in procedure - get_persons_salary
        18-Sep-01       ikasire     115.117    Bug 1977901 fixed the percent full time parttime
        09-Oct-01       kmahendr    115.118    Bug#2034617 - wrong assignment value fixed at line
                                               p_comp_rec.rt_age_uom - l_rate_prem_rec.age_uom
        17-Nov-01       ikasire     115.119    Bug2101937 fixed the calls to coverage
                                               and premium routines in calculate_age
                                               procedures.
        03-Dec-2001     ikasire     115.120    Bug 2101937 changed the group function min to max
                                               in the four cursors of get_salary_date function,
                                               as we always want only the record changed recently.
                                               Also added ppp.change_date <= p_effective_date
                                               to avoid getting the future dated salary rows.
        06-dec-01      tjesumic     115.121     Salary calcualtion date determination changed ,
                                                bug 2124453, first look for date of code
                                                then for join date  then effective date
        07-dec-01      tjesumic     115.122     dbdrv fixed
        12-dec-01      tjesumic     115.123     changed the condition to ppp.approved='Y'
                                                in cursor c1 to fetch approved salary
        16-dec-01     tjesumic      115.124     cwb changes
        20-dec-01      ikasire      115.125     Bug 2145966 formula type hours worked not
                                                triggering temporal life event
                                                added code for rule in calculate_hours_worked
        09-jan-02     tjesumic      115.126     bug 2169319 Salary calcualtion date determination changed
        30-jan-02     tjesumic      115.127     bug 2180602 new procedure added to set the tax_unit_id
                                                context before calling get_value
        01-feb-02     tjesumic      115.128     dbdrv fixed
        14-Mar-02     pabodla       115.129     UTF8 Changes Bug 2254683
        03-Jun-02     pabodla       115.130     Bug 2367556 : Changed STANDARD.bitand to just bitand
        08-Jun-02     pabodla       115.131     Do not select the contingent worker
                                                assignment when assignment data is
                                                fetched.
        19-Jun-02     ikasire       115.132     In call to to comp_level_min_max for Coverage
                                                l_rate_result was passed instead of
                                                passing l_rate_cvg_result
                                                which results in passing null to new_val
        08-Oct-02     kmahendr      115.133     Bug#2613307-added codes in calculate_los proc.
        18-Oct-02     kmahendr      115.134     Added to codes in other calculate factors
        22-Oct-02     ikasire       115.135     Bug 2502763 Changes to get_salary_date function
                                                to compute with right boundaries.
                                                Added parameter to comp_level_min_max.
                                                Removed the calls to hr_ and
                                                using the call to
                                                 BEN_DERIVE_FACTORS.determine_compensation to
                                                determine compensation.

        31-Mar-02     pbodla/       115.138     Bug 2881136 Pass formula id in
                      ikasire                   min_max_breach routine. Also
                                                pass correct rule id while
                                                calling min_max_breach.
        14-Apr-03     kmahendra     115.139     Bug#2507053 - the condition to check min_max breach
                                                for only Person is removed in age_calculation.
        08-may-2003   nhunur        115.40      Bug - 2946985 passed the oipl_id retrieved from the oiplip record
                                                structure to ben_derive_factors.determine_compensation call.
        01-jul-03     pabodla       115.141    Grade/Step Added code, variables
                                               to support grade/step life event
                                               triggering.
        28-aug-03      rpillay       115.142   Bug 3097501 - Cobra - Changed
                                               cursors getting payment and
                                               amount due to sum up values
                                               in determine_cobra_payments
        02-sep-03      rpillay       115.143   Bug 3097501- changed l_pymt_amt
                                               to data type number in
                                               determine_cobra_payments
        03-sep-03      rpillay       115.144   Bug 3125085 - check if all dues
                                               upto previous month have been paid
        25-Sep-03      rpillay       115.145   Bug 3097501 - Changes to make
                                               NOLP work for all payrolls
        03-Oct-03      ikasire       115.146   Bug 3174453 we need to pass pgm/pl/oipl
                                               to ben_derive_factors.determine_compensation
        13-Oct-03      rpillay       115.147   Bug 3097501 - Changes to handle FSA rates
                                               and rounding issues
        15-Oct-03      rpillay       115.148   Bug 3097501 - Changes to handle enrollment
                                               and rate changes
        22-Oct-03      rpillay       115.149   Bug 3097501 - Added p_element_entry_value_id
                                               in call to get_amount_due
        29-Oct-03      rpillay       115.150   Bug 3097501 - Changes to
                                               determine_cobra_payments to not
                                               check for payments not yet due
        04-Nov-03      rpillay       115.151   Bug 3235738 - Undo changes made
                                               for Bug 3097501 for PF.G
        11-Nov-03      ikasire       115.152   Using filter g_no_ptnl_ler_id for
                                               not to trigger potentials as part of
                                               Unrestricted U,W,M,I,P,A BUG 3243960
        11-Nov-03      rpillay       115.153   Added back changes for Bug 3097501
                                               (from v115.150)
        13-Nov-03      rpillay       115.154   Bug 3097501 - Changes for insignificant
                                               underpayments
        01-Dec-03      rpillay       115.155   Bug 3097501 -Changed DFF context
                                               to 'BENEFIT UNDERPAY' in cursor
                                               c_allwd_underpymt
        01-Dec-03      kmahendr      115.156   Bug#3274130 - added date condition to
                                               cursor c_per_spouse.
        02-Dec-03      ikasire       115.157   Bug 3291639 temporal not detected for
                                               combined LOS and Age derived factor
        05-Dec-03      ikasire       115.158   Bug 3275501 New Code introduced to supress
                                               firing of temporals - IGNRALL
        19-Jan-04      rpillay       115.159   Bug 3097501 - Set LE Ocrd Date to COBRA
                                               Due Date when triggering NOLP for first
                                               payment
        17-Dec-03   vvprabhu         115.32    Added the assignment for g_debug at the start
                                               of each public procedure
        05-Jan-04      ikasire       115.161   Bug 3275501 Added new Code IGNRTHIS
                                               Never to detect a potential for
                                               potential life event
        11-mar-04      nhunur        115.162   added business_group_id clause for c_get_gsp_ler
        09-apr-04      ikasire       115.163   fonm changes
        16-apr-04      ikasire       115.164   more fonm changes
        05-Aug-04      tjesumic      115.165   fonm changes
        16-Aug-04      tjesumic      115.167   fonm changes
        27-Sep-04      tjesumic      115.168   new param p_cvrd_today added in chk_enrld_or_cvrd
        12-Oct04       nhunur        115.169   pl_id needs to be passed as context for derived factor rules
                                               based elpros set at plip,oipl levels. Bug - 3944795
        21-Oct-04       bmanyam     115.170    Bug: 3962514, In los_calculation
                                               for coverages l_rate_cvg_result is
                                               passed to min_max_breach() as parameter
                                               [ previously l_rate_result was
                                                 passed, as a result temporal was not getting deducted ].
        26-oct-04       pbodla      115.171    Merging the code from version
                                               115.161.11510.5. As pkh have the function
                                               get_latest_paa_id
                       mmudigon                Bug 3818453. Added funcion
                                               get_latest_paa_id()
        27-oct-04      nhunur       115.173    moved get_latest_paa_id() to the top.
        07-apr-05      nhunur       115.174    apply fnd_number on what FF returns in run_rule.
        24-May-2004    bmanyam      115.175    BUG: 4380180. IF l_lf_evt_ocrd_dt IS NULL,
                                               avoid determining the date
        08-Jun-05      kmahendr     115.176    Bug#4393676 - nvl added to old value in
                                               hoursworked min/max breach
        12-Dec-05      stee         115.177    Bug#4338471 - COBRA: get the most recent
                                               enrollment period when evaluating
                                               loss of eligibility event.
       28-Mar-06       kmahendr     115.178    Bug#5044005 - recompute lf_evt_ocr_dt
                                               if the code is AFDECY
       24-Apr-06       abparekh     115.179    No changes - ver same as 178
       17-Jul-06       abparekh     115.180    Bug 5392019 : For LOS Date to use codes like 'Inherited%'
                                                             use benefits assignment
       25-Aug-06         swjain     115.181    Bug 5478918 : Added function skip_min_max_le_calc and called
                                               it from different calculate procedures. If true, then all the min
					       max calculations and LE creation would be skipped.
       09-Jan-07         stee       115.182    Bug 5731828: If date determination
                                               code is 'End of Calendar Year'(ALDECLY').
                                               Trigger the event as of January 1.
*/
--------------------------------------------------------------------------------
--
--
  g_package     VARCHAR2(80)             := 'ben_derive_part_and_rate_facts';
  g_debug  boolean := hr_utility.debug_enabled;
  g_rec         benutils.g_batch_ler_rec;
  g_lf_evt_exists         boolean;
  --
  --FONM
  g_fonm_cvg_strt_dt DATE ;
  --END FONM
  --
  -- Returns the latest assignment_action_id
  -- Set tax_unit_id context before calling this function
  --
  function get_latest_paa_id
  (p_person_id           in     number
  ,p_business_group_id   in     number
  ,p_effective_date      in     date
  ) return number
  is
    --
    l_package              varchar2(80)   := g_package||'.get_latest_paa_id';
    l_assignment_action_id number;
    l_tax_unit_id          number;
    --
    cursor c_paa is
    select paa.assignment_action_id
      from pay_assignment_actions     paa,
           per_all_assignments_f      paf,
           pay_payroll_actions        ppa,
           pay_action_classifications pac
     where paf.person_id     = p_person_id
       and paa.assignment_id = paf.assignment_id
       and paa.tax_unit_id   = l_tax_unit_id
       and paa.payroll_action_id = ppa.payroll_action_id
       and ppa.action_type = pac.action_type
       and pac.classification_name = 'SEQUENCED'
       and ppa.effective_date between paf.effective_start_date
                                  and paf.effective_end_date
       and ppa.effective_date <= p_effective_date
       and ((nvl(paa.run_type_id, ppa.run_type_id) is null
       and  paa.source_action_id is null)
        or (nvl(paa.run_type_id, ppa.run_type_id) is not null
       and paa.source_action_id is not null )
       or (ppa.action_type = 'V' and ppa.run_type_id is null
            and paa.run_type_id is not null
            and paa.source_action_id is null))
       order by ppa.effective_date desc,paa.action_sequence desc;

  begin
    --
    if g_debug then
       hr_utility.set_location('Entering ' || l_package,10);
    end if;

    l_tax_unit_id := pay_balance_pkg.get_context ('TAX_UNIT_ID');

    open c_paa ;
    fetch c_paa into  l_assignment_action_id ;
    close c_paa ;

    if g_debug then
       hr_utility.set_location('paa id ' || l_assignment_action_id,10);
       hr_utility.set_location('Leaving ' || l_package,10);
    end if;

    return l_assignment_action_id;

  end get_latest_paa_id;

--
  /* Bug 5478918
   To check if all the min max breach conditions can be skipped */
FUNCTION skip_min_max_le_calc (p_ler_id              IN     NUMBER default null
                              ,p_business_group_id   IN     NUMBER
                              ,p_ptnl_ler_trtmt_cd   IN     VARCHAR2
                              ,p_effective_date      IN     DATE)
RETURN BOOLEAN is
    --
    CURSOR c1 IS
      SELECT   ler.name,
               ler.ptnl_ler_trtmt_cd
      FROM     ben_ler_f ler
      WHERE    ler.ler_id = p_ler_id
      AND      ler.business_group_id = p_business_group_id
      AND      p_effective_date BETWEEN ler.effective_start_date
               AND ler.effective_end_date;
    l_ler_name              VARCHAR2(240);
    l_ptnl_ler_trtmt_cd     VARCHAR2(30);
    l_package               VARCHAR2(80)        := g_package || '.skip_min_max_le_calc';
--
BEGIN
--
    if g_debug then
      hr_utility.set_location('Entering ' || l_package,10);
    end if;
    hr_utility.set_location('p_ptnl_ler_trtmt_cd '||p_ptnl_ler_trtmt_cd , 99);
    hr_utility.set_location('p_ler_id '||p_ler_id ,99) ;
    hr_utility.set_location('p_effective_date '||p_effective_date ,99);
    hr_utility.set_location('p_business_group_id '||p_business_group_id ,99);
    --
    -- Test to make sure we are only creating life events of a
    -- certain type. This is specifically for temporal mode.
    -- Dont trigger Potential if called from Unrestricted U,W,M,I,P,A
    --
    IF (NVL(ben_derive_part_and_rate_facts.g_temp_ler_id,p_ler_id) <> p_ler_id ) OR
       (NVL(g_pgm_typ_cd, 'KKKK') = 'GSP' and
        (NVL(ben_derive_part_and_rate_facts.g_temp_ler_id,g_gsp_ler_id) <> g_gsp_ler_id )) OR
        (NVL(ben_derive_part_and_rate_facts.g_no_ptnl_ler_id,p_ler_id) <> p_ler_id )
    THEN
      --
      hr_utility.set_location('Dont trigger Potential if called from Unrestricted U,W,M,I,P,A.',11);
      RETURN TRUE;
      --
    END IF;
    --

    IF(NVL(p_ptnl_ler_trtmt_cd,'-1') = 'IGNRALL') THEN
     --
      hr_utility.set_location('Life Event Treatment code set to IGNR.',11);
      RETURN TRUE;
      --
    END IF;

   if(p_ler_id is not null) then
    --
    OPEN c1;
    FETCH c1 INTO l_ler_name,l_ptnl_ler_trtmt_cd ;
    CLOSE c1;
    --
    IF (NVL(l_ptnl_ler_trtmt_cd ,'-1') in ('IGNRTHIS','IGNRALL')) THEN
     --
      hr_utility.set_location('Life Event Treatment code for '|| l_ler_name ||' set to IGNRTHIS/IGNRALL.',11);
      RETURN TRUE;
      --
    END IF;
    --
   end if;
   --
    if g_debug then
      hr_utility.set_location('Leaving ' || l_package,10);
    end if;
    --
    RETURN FALSE;
    --
END skip_min_max_le_calc;
/* End Bug 5478918 */
--

  PROCEDURE run_rule(
    p_formula_id        IN     NUMBER
   --
   ,p_empasg_row        IN     per_all_assignments_f%ROWTYPE
   ,p_benasg_row        IN     per_all_assignments_f%ROWTYPE
   ,p_pil_row           IN     ben_per_in_ler%ROWTYPE
   --
   ,p_curroipl_row      IN     ben_cobj_cache.g_oipl_inst_row
   ,p_curroiplip_row    IN     ben_cobj_cache.g_oiplip_inst_row
   --
   ,p_rule_type         IN     VARCHAR2 DEFAULT 'NUMBER'
   ,p_effective_date    IN     DATE
   ,p_lf_evt_ocrd_dt    IN     DATE
   ,p_business_group_id IN     NUMBER
   ,p_person_id         IN     NUMBER
   ,p_pgm_id            IN     NUMBER
   ,p_pl_id             IN     NUMBER
   ,p_oipl_id           IN     NUMBER
   ,p_plip_id           IN     NUMBER
   ,p_ptip_id           IN     NUMBER
   ,p_oiplip_id         IN     NUMBER
   ,p_ret_date          OUT NOCOPY    DATE
   ,p_ret_val           OUT NOCOPY    NUMBER) IS
    --
    l_package           VARCHAR2(80)               := g_package || '.run_rule';
    l_result            NUMBER;
    l_outputs           ff_exec.outputs_t;
    l_loc_rec           hr_locations_all%ROWTYPE;
    l_ass_rec           per_all_assignments_f%ROWTYPE;
    l_pl_rec            ben_pl_f%ROWTYPE;
    l_oipl_rec          ben_oipl_f%ROWTYPE;
    l_oiplip_rec        ben_cobj_cache.g_oiplip_inst_row;
    l_effective_date   date ;
    l_jurisdiction_code VARCHAR2(30);
    cursor c_ptip(p_effective_date date) is
      select pl_typ_id
      from ben_ptip_f
      where ptip_id=p_ptip_id and
            business_group_id=p_business_group_id and
            p_effective_date between
              effective_start_date and effective_end_date;
    cursor c_plip(p_effective_date date) is
      select pl.pl_typ_id , pl.pl_id
      from ben_plip_f plip,
           ben_pl_f pl
      where plip.plip_id=p_plip_id and
            plip.business_group_id=p_business_group_id and
            p_effective_date between
              plip.effective_start_date and plip.effective_end_date
            and pl.pl_id = plip.pl_id and
            pl.business_group_id=p_business_group_id and
            p_effective_date between
              pl.effective_start_date and pl.effective_end_date;
    cursor c_oipl(p_effective_date date) is
      select pl.pl_typ_id , pl.pl_id
      from ben_oipl_f oipl,
           ben_pl_f pl
      where oipl.oipl_id=p_oipl_id and
            oipl.business_group_id=p_business_group_id and
            p_effective_date between
              oipl.effective_start_date and oipl.effective_end_date
            and pl.pl_id = oipl.pl_id and
            pl.business_group_id=p_business_group_id and
            p_effective_date between
              pl.effective_start_date and pl.effective_end_date;
    cursor c_oiplip(p_effective_date date) is
      select pl.pl_typ_id , pl.pl_id
      from ben_oiplip_f oiplip,
           ben_oipl_f oipl,
           ben_pl_f pl
      where oiplip.oiplip_id=p_oiplip_id and
            oiplip.business_group_id=p_business_group_id and
            p_effective_date between
              oiplip.effective_start_date and oiplip.effective_end_date
            and oipl.oipl_id = oiplip.oipl_id and
            oipl.business_group_id=p_business_group_id and
            p_effective_date between
              oipl.effective_start_date and oipl.effective_end_date
            and pl.pl_id = oipl.pl_id and
            pl.business_group_id=p_business_group_id and
            p_effective_date between
              pl.effective_start_date and pl.effective_end_date;
    cursor c_pl(p_effective_date date) is
      select pl_typ_id
      from ben_pl_f
      where pl_id=p_pl_id and
            business_group_id=p_business_group_id and
            p_effective_date between
              effective_start_date and effective_end_date;
  --
  BEGIN
    --
   if g_debug then
      hr_utility.set_location('Entering ' || l_package,10);
   end if;

   l_effective_date  := nvl(g_fonm_cvg_strt_dt , p_effective_date );
    --
    IF p_pl_id IS NOT NULL THEN
      --
      ben_comp_object.get_object(p_rec=> l_pl_rec
       ,p_pl_id => p_pl_id);
      if l_pl_rec.pl_typ_id is null then
        open c_pl(l_effective_date);
        fetch c_pl into l_pl_rec.pl_typ_id;
        close c_pl;
      end if;
    elsif p_ptip_id is not null then
      open c_ptip(l_effective_date);
      fetch c_ptip into l_pl_rec.pl_typ_id;
      close c_ptip;
    elsif p_plip_id is not null then
      open c_plip(l_effective_date);
      fetch c_plip into l_pl_rec.pl_typ_id, l_pl_rec.pl_id; -- 3944795
      close c_plip;
    elsif p_oipl_id is not null then
      open c_oipl(l_effective_date);
      fetch c_oipl into l_pl_rec.pl_typ_id , l_pl_rec.pl_id;
      close c_oipl;
    elsif p_oiplip_id is not null then
      open c_oiplip(l_effective_date);
      fetch c_oiplip into l_pl_rec.pl_typ_id , l_pl_rec.pl_id;
      close c_oiplip;
    END IF;
      hr_utility.set_location(' pl_id ' || l_pl_rec.pl_id ,10);
      hr_utility.set_location(' pl_typ_id ' || l_pl_rec.pl_typ_id ,10);
    --
    -- Call formula initialise routine
    --
    l_ass_rec  := p_empasg_row;
    --
    IF l_ass_rec.assignment_id IS NULL THEN
      --
      l_ass_rec  := p_benasg_row;
    --
    END IF;
    --
    IF l_ass_rec.location_id IS NOT NULL THEN
      --
      ben_location_object.get_object(p_location_id=> l_ass_rec.location_id
       ,p_rec         => l_loc_rec);
      --
    --Bug 1949361 fixes
/*
      IF l_loc_rec.region_2 IS NOT NULL THEN
        --
        l_jurisdiction_code  :=
          pay_mag_utils.lookup_jurisdiction_code(p_state=> l_loc_rec.region_2);
      --
      END IF;
*/
    --
    END IF;
    --
    l_outputs  :=
      benutils.formula(p_formula_id=> p_formula_id
       ,p_effective_date    => NVL(p_lf_evt_ocrd_dt
                                ,p_effective_date)
       ,p_assignment_id     => l_ass_rec.assignment_id
       ,p_organization_id   => l_ass_rec.organization_id
       ,p_business_group_id => p_business_group_id
       ,p_pgm_id            => p_pgm_id
       ,p_pl_id             => nvl(p_pl_id, l_pl_rec.pl_id )
       ,p_pl_typ_id         => l_pl_rec.pl_typ_id
       ,p_opt_id            => p_curroipl_row.opt_id
       ,p_ler_id            => p_pil_row.ler_id
       ,p_jurisdiction_code => l_jurisdiction_code
       --RCHASE Bug#Fix - pass PERSON_ID
       ,p_param1            => 'PERSON_ID'
       ,p_param1_value      => to_char(nvl(p_person_id,-1))
       ,p_param2             => 'BEN_IV_RT_STRT_DT'
       ,p_param2_value       => fnd_date.date_to_canonical(ben_manage_life_events.g_fonm_rt_strt_dt)
       ,p_param3             => 'BEN_IV_CVG_STRT_DT'
       ,p_param3_value       => fnd_date.date_to_canonical(g_fonm_cvg_strt_dt)
       );
    --
    IF p_rule_type = 'NUMBER' THEN
      --
      -- Test for type casting exceptions
      --
      BEGIN
        --
        p_ret_val   := fnd_number.canonical_to_number(l_outputs(l_outputs.FIRST).VALUE);
        p_ret_date  := NULL;
      --
      EXCEPTION
        --
        WHEN OTHERS THEN
          --
          fnd_message.set_name('BEN'
           ,'BEN_92311_FORMULA_VAL_PARAM');
          fnd_message.set_token('PROC'
           ,l_package);
          fnd_message.set_token('FORMULA'
           ,p_formula_id);
          fnd_message.set_token('PARAMETER'
           ,l_outputs(l_outputs.FIRST).name);
          fnd_message.raise_error;
      --
      END;
    --
    ELSIF p_rule_type = 'DATE' THEN
      --
      -- Test for type casting exceptions
      --
      BEGIN
        --
        p_ret_date  :=
                 fnd_date.canonical_to_date(l_outputs(l_outputs.FIRST).VALUE);
        p_ret_val   := NULL;
      --
      EXCEPTION
        --
        WHEN OTHERS THEN
          --
          fnd_message.set_name('BEN'
           ,'BEN_92311_FORMULA_VAL_PARAM');
          fnd_message.set_token('PROC'
           ,l_package);
          fnd_message.set_token('FORMULA'
           ,p_formula_id);
          fnd_message.set_token('PARAMETER'
           ,l_outputs(l_outputs.FIRST).name);
          fnd_message.raise_error;
      --
      END;
    --
    ELSE
      --
       if g_debug then
         hr_utility.set_location('INV RULE TYPE PASSED: '||p_rule_type||' '||l_package,99);
       end if;
    --
    END IF;
    --
   -- hr_utility.set_location('Leaving ' || l_package,99);
  --
  END run_rule;
--
-- This procedure has to be called first in order to initialise the data
-- structures that the code requires.
--
  PROCEDURE cache_data_structures(
    p_comp_obj_tree_row IN OUT NOCOPY ben_manage_life_events.g_cache_proc_objects_rec
   ,p_empasg_row        IN OUT NOCOPY per_all_assignments_f%ROWTYPE
   ,p_benasg_row        IN OUT NOCOPY per_all_assignments_f%ROWTYPE
   ,p_pil_row           IN OUT NOCOPY ben_per_in_ler%ROWTYPE
   ,p_business_group_id IN            NUMBER
   ,p_effective_date    IN            DATE
   ,p_person_id         IN            NUMBER
   ,p_pgm_id            IN            NUMBER
   ,p_pl_id             IN            NUMBER
   ,p_oipl_id           IN            NUMBER
   ,p_plip_id           IN            NUMBER
   ,p_ptip_id           IN            NUMBER
   ,p_comp_rec          IN OUT NOCOPY g_cache_structure
   ,p_oiplip_rec        IN OUT NOCOPY g_cache_structure) IS
    --
    l_package    VARCHAR2(80)         := g_package || '.cache_data_structures';
    --
    l_comp_rec   g_cache_structure;
    l_oiplip_rec g_cache_structure;
    --
    l_pl_id      NUMBER;
    l_opt_id     NUMBER;
    l_oipl_rec   ben_oipl_f%ROWTYPE;
    l_epo_row    ben_derive_part_and_rate_facts.g_cache_structure;
    --
    -- Cursor to get eligible option details
    --
    CURSOR c_elig_per_opt(
      c_effective_date IN DATE
     ,c_person_id      IN NUMBER
     ,c_pgm_id         IN NUMBER
     ,c_pl_id          IN NUMBER
     ,c_plip_id        IN NUMBER
     ,c_opt_id         IN NUMBER) IS
      SELECT   epo.los_val
              ,epo.age_val
              ,epo.comp_ref_amt
              ,epo.hrs_wkd_val
              ,epo.pct_fl_tm_val
              ,epo.cmbn_age_n_los_val
              ,epo.age_uom
              ,epo.los_uom
              ,epo.comp_ref_uom
              ,epo.hrs_wkd_bndry_perd_cd
              ,epo.frz_los_flag
              ,epo.frz_age_flag
              ,epo.frz_hrs_wkd_flag
              ,epo.frz_cmp_lvl_flag
              ,epo.frz_pct_fl_tm_flag
              ,epo.frz_comb_age_and_los_flag
              ,epo.rt_los_val
              ,epo.rt_age_val
              ,epo.rt_comp_ref_amt
              ,epo.rt_hrs_wkd_val
              ,epo.rt_pct_fl_tm_val
              ,epo.rt_cmbn_age_n_los_val
              ,epo.rt_age_uom
              ,epo.rt_los_uom
              ,epo.rt_comp_ref_uom
              ,epo.rt_hrs_wkd_bndry_perd_cd
              ,epo.rt_frz_los_flag
              ,epo.rt_frz_age_flag
              ,epo.rt_frz_hrs_wkd_flag
              ,epo.rt_frz_cmp_lvl_flag
              ,epo.rt_frz_pct_fl_tm_flag
              ,epo.rt_frz_comb_age_and_los_flag
              ,epo.ovrid_svc_dt
              ,epo.prtn_ovridn_flag
              ,epo.prtn_ovridn_thru_dt
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,epo.once_r_cntug_cd
              ,epo.elig_flag
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,NULL
      FROM     ben_elig_per_opt_f epo, ben_elig_per_f pep, ben_per_in_ler pil
      WHERE    epo.elig_per_id = pep.elig_per_id
      AND      pep.person_id = c_person_id
      AND      NVL(pep.pl_id
                ,-1) = c_pl_id
      AND      NVL(pep.plip_id
                ,-1) = c_plip_id
      AND      NVL(pep.pgm_id
                ,-1) = c_pgm_id
      AND      c_effective_date BETWEEN pep.effective_start_date
                   AND pep.effective_end_date
      AND      epo.opt_id = c_opt_id
      AND      c_effective_date BETWEEN epo.effective_start_date
                   AND epo.effective_end_date
      AND      pil.per_in_ler_id (+) = epo.per_in_ler_id
    --  AND      pil.business_group_id (+) = epo.business_group_id
      AND      (
                    pil.per_in_ler_stat_cd NOT IN ('VOIDD', 'BCKDT')
                 OR pil.per_in_ler_stat_cd IS NULL);
    --
    -- Cursor to get eligible person details
    --
    CURSOR c_elig_per(
      c_effective_date IN DATE
     ,c_person_id      IN NUMBER
     ,c_pgm_id         IN NUMBER
     ,c_plip_id        IN NUMBER
     ,c_pl_id          IN NUMBER) IS
      SELECT   pep.los_val
              ,pep.age_val
              ,pep.comp_ref_amt
              ,pep.hrs_wkd_val
              ,pep.pct_fl_tm_val
              ,pep.cmbn_age_n_los_val
              ,pep.age_uom
              ,pep.los_uom
              ,pep.comp_ref_uom
              ,pep.hrs_wkd_bndry_perd_cd
              ,pep.frz_los_flag
              ,pep.frz_age_flag
              ,pep.frz_hrs_wkd_flag
              ,pep.frz_cmp_lvl_flag
              ,pep.frz_pct_fl_tm_flag
              ,pep.frz_comb_age_and_los_flag
              ,pep.rt_los_val
              ,pep.rt_age_val
              ,pep.rt_comp_ref_amt
              ,pep.rt_hrs_wkd_val
              ,pep.rt_pct_fl_tm_val
              ,pep.rt_cmbn_age_n_los_val
              ,pep.rt_age_uom
              ,pep.rt_los_uom
              ,pep.rt_comp_ref_uom
              ,pep.rt_hrs_wkd_bndry_perd_cd
              ,pep.rt_frz_los_flag
              ,pep.rt_frz_age_flag
              ,pep.rt_frz_hrs_wkd_flag
              ,pep.rt_frz_cmp_lvl_flag
              ,pep.rt_frz_pct_fl_tm_flag
              ,pep.rt_frz_comb_age_and_los_flag
              ,pep.ovrid_svc_dt
              ,pep.prtn_ovridn_flag
              ,pep.prtn_ovridn_thru_dt
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,pep.once_r_cntug_cd
              ,pep.elig_flag
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,NULL
      FROM     ben_elig_per_f pep, ben_per_in_ler pil
      WHERE    pep.person_id = c_person_id
      AND      NVL(pep.pl_id
                ,-1) = c_pl_id
      AND      NVL(pep.plip_id
                ,-1) = c_plip_id
      AND      pep.ptip_id IS NULL
      AND      NVL(pep.pgm_id
                ,-1) = c_pgm_id
      AND      c_effective_date BETWEEN pep.effective_start_date
                   AND pep.effective_end_date
      AND      pil.per_in_ler_id (+) = pep.per_in_ler_id
     -- AND      pil.business_group_id (+) = pep.business_group_id
      AND      (
                    pil.per_in_ler_stat_cd NOT IN ('VOIDD', 'BCKDT')
                 OR pil.per_in_ler_stat_cd IS NULL);
  --
  BEGIN
  g_debug := hr_utility.debug_enabled;
  -- hr_utility.set_location('Entering ' || l_package,10);
    --
    -- This cursor caches all the elig per information that
    -- is used by the derivable factor functions
    --
    p_oiplip_rec  := l_oiplip_rec;
    --
    IF p_oipl_id IS NOT NULL THEN
      --
      -- Check for option in a program
      --
      IF p_comp_obj_tree_row.par_pgm_id IS NOT NULL THEN
        --
        ben_pep_cache.get_pilepo_dets(p_person_id=> p_person_id
         ,p_business_group_id => p_business_group_id
         ,p_effective_date    => p_effective_date
         ,p_pgm_id            => p_comp_obj_tree_row.par_pgm_id
         ,p_pl_id             => p_comp_obj_tree_row.par_pl_id
         ,p_opt_id            => p_comp_obj_tree_row.par_opt_id
         ,p_inst_row          => p_comp_rec);
       -- hr_utility.set_location('Dn PILEPO ' || l_package,10);
      --
      -- Plan not in a program
      --
      ELSE
        --
        OPEN c_elig_per_opt(c_effective_date=> p_effective_date
         ,c_person_id      => p_person_id
         ,c_pgm_id         => NVL(p_comp_obj_tree_row.par_pgm_id
                               ,-1)
         ,c_pl_id          => NVL(p_comp_obj_tree_row.par_pl_id
                               ,-1)
         ,c_plip_id        => -1
         ,c_opt_id         => p_comp_obj_tree_row.par_opt_id);
        FETCH c_elig_per_opt INTO p_comp_rec;
        CLOSE c_elig_per_opt;
       -- hr_utility.set_location('Dn c_elig_per_opt ' || l_package,10);
      --
      END IF;
      --
      IF p_comp_obj_tree_row.oiplip_id IS NOT NULL THEN
        --
        ben_pep_cache.get_pilepo_dets(p_person_id=> p_person_id
         ,p_business_group_id => p_business_group_id
         ,p_effective_date    => p_effective_date
         ,p_pgm_id            => p_comp_obj_tree_row.par_pgm_id
         ,p_plip_id           => p_comp_obj_tree_row.par_plip_id
         ,p_opt_id            => p_comp_obj_tree_row.par_opt_id
         ,p_inst_row          => p_oiplip_rec);
       -- hr_utility.set_location('Dn OIPLIP PILEPO ' || l_package,10);
      --
      END IF;
    --
    ELSE
      --
      -- Plan in program or plip
      --
      IF p_comp_obj_tree_row.par_pgm_id IS NOT NULL THEN
        --
        ben_pep_cache.get_pilpep_dets(p_person_id=> p_person_id
         ,p_business_group_id => p_business_group_id
         ,p_effective_date    => p_effective_date
         ,p_pgm_id            => p_comp_obj_tree_row.par_pgm_id
         ,p_pl_id             => p_pl_id
         ,p_plip_id           => p_plip_id
         ,p_ptip_id           => p_ptip_id
         ,p_inst_row          => p_comp_rec);
       -- hr_utility.set_location('Dn PILPEP ' || l_package,10);
      --
      ELSE
        --
        OPEN c_elig_per(c_effective_date=> p_effective_date
         ,c_person_id      => p_person_id
         ,c_pgm_id         => NVL(p_pgm_id
                               ,NVL(p_comp_obj_tree_row.par_pgm_id
                                 ,-1))
         ,c_plip_id        => NVL(p_plip_id
                               ,-1)
         ,c_pl_id          => NVL(p_pl_id
                               ,-1));
        FETCH c_elig_per INTO p_comp_rec;
        CLOSE c_elig_per;
       -- hr_utility.set_location('Dn c_elig_per ' || l_package,10);
      --
      END IF;
    --
    END IF;
    --
   -- hr_utility.set_location('Leaving ' || l_package,10);
  END cache_data_structures;
--
  PROCEDURE clear_down_cache IS
    --
    l_package       VARCHAR2(80)      := g_package || '.clear_down_cache';
    l_cache_details g_cache_structure;
  --
  BEGIN
    --
   -- hr_utility.set_location('Entering ' || l_package,10);
    --
    -- Set cache structure to null
    --
    g_cache_details  := l_cache_details;
    --
   -- hr_utility.set_location('Leaving ' || l_package,10);
  --
  END;
--
  FUNCTION get_balance_date(
    p_effective_date IN DATE
   ,p_bnfts_bal_id   IN NUMBER
   ,p_person_id      IN NUMBER
   ,p_min            IN NUMBER
   ,p_max            IN NUMBER
   ,p_break          IN VARCHAR2)
    RETURN DATE IS
    --
    l_package VARCHAR2(80) := g_package || '.get_balance_date';
    l_salary  DATE;
    --
    -- Cursors to bring back first occurence where min or max was crossed
    --
    CURSOR c_gt_min IS
      SELECT   MIN(pbb.effective_start_date)
      FROM     ben_per_bnfts_bal_f pbb
      WHERE    pbb.val >= p_min
      AND      pbb.bnfts_bal_id = p_bnfts_bal_id
      AND      p_effective_date BETWEEN pbb.effective_start_date
                   AND pbb.effective_end_date
      AND      pbb.person_id = p_person_id;
    --
    CURSOR c_gt_max IS
      SELECT   MIN(pbb.effective_start_date)
      FROM     ben_per_bnfts_bal_f pbb
      WHERE    pbb.val > p_max
      AND      pbb.bnfts_bal_id = p_bnfts_bal_id
      AND      p_effective_date BETWEEN pbb.effective_start_date
                   AND pbb.effective_end_date
      AND      pbb.person_id = p_person_id;
    --
    CURSOR c_lt_max IS
      SELECT   MIN(pbb.effective_start_date)
      FROM     ben_per_bnfts_bal_f pbb
      WHERE    pbb.val <= p_max
      AND      pbb.bnfts_bal_id = p_bnfts_bal_id
      AND      p_effective_date BETWEEN pbb.effective_start_date
                   AND pbb.effective_end_date
      AND      pbb.person_id = p_person_id;
    --
    CURSOR c_lt_min IS
      SELECT   MIN(pbb.effective_start_date)
      FROM     ben_per_bnfts_bal_f pbb
      WHERE    pbb.val < p_min
      AND      pbb.bnfts_bal_id = p_bnfts_bal_id
      AND      p_effective_date BETWEEN pbb.effective_start_date
                   AND pbb.effective_end_date
      AND      pbb.person_id = p_person_id;
  --
  BEGIN
    --
   -- hr_utility.set_location('Entering ' || l_package,10);
    --
    IF p_break = 'GT_MIN' THEN
      --
      OPEN c_gt_min;
      FETCH c_gt_min INTO l_salary;
      CLOSE c_gt_min;
    --
    ELSIF p_break = 'GT_MAX' THEN
      --
      OPEN c_gt_max;
      FETCH c_gt_max INTO l_salary;
      CLOSE c_gt_max;
    --
    ELSIF p_break = 'LT_MAX' THEN
      --
      OPEN c_lt_max;
      FETCH c_lt_max INTO l_salary;
      CLOSE c_lt_max;
    --
    ELSIF p_break = 'LT_MIN' THEN
      --
      OPEN c_lt_min;
      FETCH c_lt_min INTO l_salary;
      CLOSE c_lt_min;
    --
    END IF;
    --
    RETURN l_salary;
    --
   -- hr_utility.set_location('Entering ' || l_package,10);
  --
  END get_balance_date;
--
  FUNCTION get_salary_date(
    p_empasg_row     IN per_all_assignments_f%ROWTYPE
   ,p_benasg_row     IN per_all_assignments_f%ROWTYPE
   ,p_rec            IN ben_derive_part_and_rate_cache.g_cache_clf_rec_obj
   ,p_person_id      IN NUMBER
   ,p_effective_date IN DATE
   ,p_min            IN NUMBER
   ,p_max            IN NUMBER
   ,p_break          IN VARCHAR2)
    RETURN DATE IS
    --
    l_package VARCHAR2(80)                  := g_package || '.get_salary_date';
    l_salary  DATE;
    l_ass_rec per_all_assignments_f%ROWTYPE;
    -- New
    l_pay_annualization_factor  number ;
    l_rate_flag   varchar2(200) := 'N';
    l_not_found boolean := false;
    l_primary_flag   varchar2(1):= 'Y';
    l_assignment_id  number := 0;
    l_min            number ;
    l_max            number ;
    l_input          number ;
    l_output         number ;
  --
  cursor c_stated_salary (v_assignment_id number,v_effective_date date) is
    select ppb.pay_basis,
           ppb.pay_annualization_factor,
           asg.normal_hours,
           asg.frequency,
           asg.assignment_id
    from   per_all_assignments_f asg,
           per_pay_bases ppb
    where  asg.assignment_type <> 'C'
    and    asg.assignment_id = v_assignment_id
    and    ppb.pay_basis_id = asg.pay_basis_id
    and    v_effective_date
           between asg.effective_start_date
           and     asg.effective_end_date
    order  by asg.assignment_id;
  --
  l_stated_salary c_stated_salary%rowtype;
  --
  cursor c_opt_typ_cd (v_effective_date date) is
   select opt.OPT_TYP_CD
   from BEN_PL_F pln, BEN_PL_TYP_f opt
   where opt.pl_typ_id = pln.pl_typ_id
   and   opt.OPT_TYP_CD = 'CWB'
   and   v_effective_date
         between pln.effective_start_date
         and     pln.effective_end_date
   and   v_effective_date
         between opt.effective_start_date
   and   opt.effective_end_date;
   --
   l_opt_typ_cd c_opt_typ_cd%rowtype;
 --
    --
    -- Bug 2101937 changed the min group function to max in the following four
    -- cursors as we always want only the record changed recently.
    -- Also added ppp.change_date <= p_effective_date to avoid getting the
    -- future dated salary rows.
    CURSOR c_gt_min IS
      SELECT   MAX(ppp.change_date)
      FROM     per_pay_proposals ppp, per_all_assignments_f paf
      WHERE    paf.assignment_id = l_ass_rec.assignment_id
      and      paf.assignment_type <> 'C'
      AND      p_effective_date BETWEEN paf.effective_start_date
                   AND paf.effective_end_date
      AND      paf.assignment_id = ppp.assignment_id
      AND      ppp.change_date BETWEEN paf.effective_start_date
                   AND paf.effective_end_date
      AND      ppp.proposed_salary_n >= l_output -- p_min
      AND      ppp.change_date <= p_effective_date ;
    --
    CURSOR c_gt_max IS
      SELECT   MAX(ppp.change_date)
      FROM     per_pay_proposals ppp, per_all_assignments_f paf
      WHERE    paf.assignment_id = l_ass_rec.assignment_id
      and      paf.assignment_type <> 'C'
      AND      p_effective_date BETWEEN paf.effective_start_date
                   AND paf.effective_end_date
      AND      paf.assignment_id = ppp.assignment_id
      AND      ppp.change_date BETWEEN paf.effective_start_date
                   AND paf.effective_end_date
      AND      ppp.proposed_salary_n > l_output -- p_max
      AND      ppp.change_date <= p_effective_date;
    --
    CURSOR c_lt_max IS
      SELECT   MAX(ppp.change_date)
      FROM     per_pay_proposals ppp, per_all_assignments_f paf
      WHERE    paf.assignment_id = l_ass_rec.assignment_id
      and      paf.assignment_type <> 'C'
      AND      p_effective_date BETWEEN paf.effective_start_date
                   AND paf.effective_end_date
      AND      paf.assignment_id = ppp.assignment_id
      AND      ppp.change_date BETWEEN paf.effective_start_date
                   AND paf.effective_end_date
      AND      ppp.proposed_salary_n <= l_output -- p_max
      AND      ppp.change_date <= p_effective_date;
    --
    CURSOR c_lt_min IS
      SELECT   MAX(ppp.change_date)
      FROM     per_pay_proposals ppp, per_all_assignments_f paf
      WHERE    paf.assignment_id = l_ass_rec.assignment_id
      and      paf.assignment_type <> 'C'
      AND      p_effective_date BETWEEN paf.effective_start_date
                   AND paf.effective_end_date
      AND      paf.assignment_id = ppp.assignment_id
      AND      ppp.change_date BETWEEN paf.effective_start_date
                   AND paf.effective_end_date
      AND      ppp.proposed_salary_n < l_output -- p_min
      AND      ppp.change_date <= p_effective_date;
  --
  BEGIN
    --
   -- hr_utility.set_location('Entering ' || l_package,10);
    --
    IF p_empasg_row.assignment_id IS NULL THEN
      --
      l_ass_rec  := p_benasg_row;
    --
    ELSE
      --
      l_ass_rec  := p_empasg_row;
    --
    END IF;
    --
    IF p_break = 'GT_MIN' THEN
      --
      l_input := p_min ;
    --
    ELSIF p_break = 'GT_MAX' THEN
      --
      l_input := p_max ;
    --
    ELSIF p_break = 'LT_MAX' THEN
      --
      l_input := p_max ;
    --
    ELSIF p_break = 'LT_MIN' THEN
      --
      l_input := p_min ;
    --
    END IF;

    open c_stated_salary (l_ass_rec.assignment_id,p_effective_date);
      --
      fetch c_stated_salary into l_stated_salary;
      --
      if c_stated_salary%NOTFOUND then
        --
        /*
        l_opt_typ_cd.opt_typ_cd := 'YYY';
        open c_opt_typ_cd(p_effective_date);
        fetch c_opt_typ_cd into l_opt_typ_cd;
        close c_opt_typ_cd;
        if nvl(l_opt_typ_cd.opt_typ_cd, 'YYY') ='CWB' then
          l_value := 0;
          l_salary.proposed_salary := 0;
        else
          fnd_message.set_name('BEN','BEN_91833_CURSOR_RETURN_NO_ROW');
          fnd_message.set_token('PACKAGE',l_proc);
          fnd_message.set_token('CURSOR','c_stated_salary');
          fnd_message.raise_error;
        end if;
        */
        return l_salary ;
      --
      end if;
      --
    close c_stated_salary;
    --
    if l_stated_salary.pay_basis is not null then
      l_pay_annualization_factor  := l_stated_salary.pay_annualization_factor;
    end if;
    if l_pay_annualization_factor is null then
      l_pay_annualization_factor := to_number(fnd_profile.value('BEN_HRLY_ANAL_FCTR'));
      if l_pay_annualization_factor is null then
        l_pay_annualization_factor := 2080;
      end if;
    end if;
    if g_debug then
      hr_utility.set_location('p_rec.sttd_sal_prdcty_cd :'||p_rec.sttd_sal_prdcty_cd,18);
    end if;
    --
    if p_rec.sttd_sal_prdcty_cd = 'PWK' then
      --
      -- l_value := l_value/52;
      --
      l_output := l_input*52 ;
      --  Bi-Weekly
      --
    elsif p_rec.sttd_sal_prdcty_cd = 'BWK' then
      --
      --l_value := l_value/26;
      l_output := l_input*26;
      --
      --  Semi-Monthly
      --
    elsif p_rec.sttd_sal_prdcty_cd = 'SMO' then
      --
      -- l_value := l_value/24;
      l_output := l_input*24;
      --
      --  Per Quarter
      --
    elsif p_rec.sttd_sal_prdcty_cd = 'PQU' then
      --
      --l_value := l_value/4;
      l_output := l_input*4;
      --
      --  Per Year
      --   don't really need to do this since l_value is already periodized,
      --   but to make it easier to read we'll go ahead and go through the
      --   motions.
      --
    elsif p_rec.sttd_sal_prdcty_cd = 'PYR' then
      --
      --l_value := l_value;
      l_output := l_input;
      --
      --  Semi-Annual
      --
    elsif p_rec.sttd_sal_prdcty_cd = 'SAN' then
      --
      -- l_value := l_value/2;
      l_output := l_input*2;
      --
      --  Monthly
      --
    elsif p_rec.sttd_sal_prdcty_cd = 'MO' then
      --
      --l_value := l_value/12;
      l_output := l_input*12;
      --
      --
    elsif p_rec.sttd_sal_prdcty_cd = 'PHR' then
       --
       -- l_value := l_value/l_pay_annualization_factor;
       l_output := l_input*l_pay_annualization_factor;
       --
    end if;
    --  Now take annualized salary and translate it into the appropriate
    --  acty ref period as defined by the plan or program
    if l_stated_salary.pay_basis is not null then
      --
      -- Assumption no multi assignment for annualization factor
            l_pay_annualization_factor  := l_stated_salary.pay_annualization_factor;
            -- l_value := l_stated_salary.proposed_salary * nvl(l_stated_salary.pay_annualization_factor,1);
            l_output:= l_input/l_pay_annualization_factor ;
            --
    elsif l_stated_salary.frequency is not null and l_stated_salary.normal_hours is not null then
      --
      if l_stated_salary.frequency = 'D' then
        --
        -- assumption is 5 days a week * 52 weeks in a year = 260 working days
        --
        --l_value := l_stated_salary.proposed_salary * (l_stated_salary.normal_hours*260) + nvl(l_value,0);
        l_output := l_input/(l_stated_salary.normal_hours*260);
        --
      elsif l_stated_salary.frequency = 'W' then
        --
        --l_value := l_stated_salary.proposed_salary * (l_stated_salary.normal_hours*52) + nvl(l_value,0);
        l_output := l_input/(l_stated_salary.normal_hours*52);
             --
      elsif l_stated_salary.frequency = 'M' then
        --
        --l_value := l_stated_salary.proposed_salary * (l_stated_salary.normal_hours*12) + nvl(l_value,0);
        l_output := l_input/ (l_stated_salary.normal_hours*12);
        --
      elsif l_stated_salary.frequency = 'Y' then
        --
        --l_value := l_stated_salary.proposed_salary + nvl(l_value,0);
        l_output := l_input ;
        --
      end if;
    end if;
    --
    if g_debug then
      hr_utility.set_location('Input Value  '||l_input ,100);
    end if;
    if g_debug then
      hr_utility.set_location('Output Value '||l_output,100);
    end if;
    --
    IF p_break = 'GT_MIN' THEN
      --
      OPEN c_gt_min;
      FETCH c_gt_min INTO l_salary;
      CLOSE c_gt_min;
    --
    ELSIF p_break = 'GT_MAX' THEN
      --
      OPEN c_gt_max;
      FETCH c_gt_max INTO l_salary;
      CLOSE c_gt_max;
    --
    ELSIF p_break = 'LT_MAX' THEN
      --
      OPEN c_lt_max;
      FETCH c_lt_max INTO l_salary;
      CLOSE c_lt_max;
    --
    ELSIF p_break = 'LT_MIN' THEN
      --
      OPEN c_lt_min;
      FETCH c_lt_min INTO l_salary;
      CLOSE c_lt_min;
    --
    END IF;
    --
    RETURN l_salary;
    --
   -- hr_utility.set_location('Entering ' || l_package,10);
  --
  END get_salary_date;
--
  FUNCTION get_percent_date(
    p_empasg_row     IN per_all_assignments_f%ROWTYPE
   ,p_benasg_row     IN per_all_assignments_f%ROWTYPE
   ,p_person_id      IN NUMBER
   ,p_percent        IN NUMBER
   ,p_effective_date IN DATE
   ,p_min            IN NUMBER
   ,p_max            IN NUMBER
   ,p_break          IN VARCHAR2)
    RETURN DATE IS
    --
    l_package VARCHAR2(80)                 := g_package || '.get_percent_date';
    l_percent DATE;
    l_ass_rec per_all_assignments_f%ROWTYPE;
    --
    -- Assignment has been validated as primary already therefore no need
    -- to include join to per_assignments_f
    --
    CURSOR c_gt_min IS
      SELECT   MIN(pab.effective_start_date)
      FROM     per_assignment_budget_values_f pab
      WHERE    pab.assignment_id = l_ass_rec.assignment_id
      AND      pab.effective_start_date BETWEEN l_ass_rec.effective_start_date
                   AND l_ass_rec.effective_end_date
      AND      pab.unit = 'FTE'
      AND      pab.VALUE >= p_min;
    --
    CURSOR c_gt_max IS
      SELECT   MIN(pab.effective_start_date)
      FROM     per_assignment_budget_values_f pab
      WHERE    pab.assignment_id = l_ass_rec.assignment_id
      AND      pab.effective_start_date BETWEEN l_ass_rec.effective_start_date
                   AND l_ass_rec.effective_end_date
      AND      pab.unit = 'FTE'
      AND      pab.VALUE > p_max;
    --
    CURSOR c_lt_max IS
      SELECT   MIN(pab.effective_start_date)
      FROM     per_assignment_budget_values_f pab
      WHERE    pab.assignment_id = l_ass_rec.assignment_id
      AND      pab.effective_start_date BETWEEN l_ass_rec.effective_start_date
                   AND l_ass_rec.effective_end_date
      AND      pab.unit = 'FTE'
      AND      pab.VALUE <= p_max;
    --
    CURSOR c_lt_min IS
      SELECT   MIN(pab.effective_start_date)
      FROM     per_assignment_budget_values_f pab
      WHERE    pab.assignment_id = l_ass_rec.assignment_id
      AND      pab.effective_start_date BETWEEN l_ass_rec.effective_start_date
                   AND l_ass_rec.effective_end_date
      AND      pab.unit = 'FTE'
      AND      pab.VALUE < p_min;
  --
  BEGIN
    --
   -- hr_utility.set_location('Entering ' || l_package,10);
    --
    IF p_empasg_row.assignment_id IS NULL THEN
      --
      l_ass_rec  := p_benasg_row;
    --
    ELSE
      --
      l_ass_rec  := p_empasg_row;
    --
    END IF;
    --
    IF p_break = 'GT_MIN' THEN
      --
      OPEN c_gt_min;
      FETCH c_gt_min INTO l_percent;
      CLOSE c_gt_min;
    --
    ELSIF p_break = 'GT_MAX' THEN
      --
      OPEN c_gt_max;
      FETCH c_gt_max INTO l_percent;
      CLOSE c_gt_max;
    --
    ELSIF p_break = 'LT_MAX' THEN
      --
      OPEN c_lt_max;
      FETCH c_lt_max INTO l_percent;
      CLOSE c_lt_max;
    --
    ELSIF p_break = 'LT_MIN' THEN
      --
      OPEN c_lt_min;
      FETCH c_lt_min INTO l_percent;
      CLOSE c_lt_min;
    --
    END IF;
    --
    RETURN l_percent;
    --
   -- hr_utility.set_location('Leaving ' || l_package,10);
  --
  END get_percent_date;
--
  FUNCTION get_persons_salary(
    p_empasg_row        IN per_all_assignments_f%ROWTYPE
   ,p_benasg_row        IN per_all_assignments_f%ROWTYPE
   ,p_person_id         IN NUMBER
   ,p_business_group_id IN NUMBER
   ,p_effective_date    IN DATE)
    RETURN NUMBER IS
    --
    l_package VARCHAR2(80)               := g_package || '.get_persons_salary';
    l_salary  NUMBER(38);
    l_ass_rec per_all_assignments_f%ROWTYPE;
    --
    CURSOR c1 IS
      SELECT   ppp.proposed_salary_n
      FROM     per_pay_proposals ppp, per_all_assignments_f paf
      WHERE    paf.assignment_id = l_ass_rec.assignment_id
      and      paf.assignment_type <> 'C'
      AND      paf.business_group_id = p_business_group_id
      AND      p_effective_date BETWEEN paf.effective_start_date
                   AND paf.effective_end_date
      AND      paf.assignment_id = ppp.assignment_id
      AND      paf.business_group_id = ppp.business_group_id
      AND      ppp.change_date BETWEEN paf.effective_start_date
                   AND paf.effective_end_date
      --AND      ppp.approved IN ('Y', 'A', 'P')
      --approved is check box accpet Y/N
      and nvl(ppp.approved,'N')  = 'Y'
     -- Bug 1977901  added the following condition
     -- otherwise we get the future salaries also which we should not do
      AND      ppp.change_date <= p_effective_date
       ORDER BY ppp.change_date DESC;
  --
  BEGIN
    --
    if g_debug then
      hr_utility.set_location('Leaving ' || l_package,10);
    end if;
    --
    IF p_empasg_row.assignment_id IS NULL THEN
      --
      l_ass_rec  := p_benasg_row;
    --
    ELSE
      --
      l_ass_rec  := p_empasg_row;
    --
    END IF;
    --
    -- Get persons salary and return value
    --
    OPEN c1;
    --
    FETCH c1 INTO l_salary;
    --
    -- note we don't care if we can't find a salary we just return a null
    --
    if g_debug then
      hr_utility.set_location('Salary is ' || l_salary,10);
    end if;
    --
    CLOSE c1;
    --
    RETURN l_salary;
  --
  END get_persons_salary;
--
  PROCEDURE create_ptl_ler
    (p_calculate_only_mode in     boolean default false
    ,p_ler_id              IN     NUMBER
    ,p_lf_evt_ocrd_dt      IN     DATE
    ,p_person_id           IN     NUMBER
    ,p_business_group_id   IN     NUMBER
    ,p_effective_date      IN     DATE
    )
  IS
    --
    CURSOR c1 IS
      SELECT   ler.name,
               ler.ptnl_ler_trtmt_cd
      FROM     ben_ler_f ler
      WHERE    ler.ler_id = p_ler_id
      AND      ler.business_group_id = p_business_group_id
      AND      p_effective_date BETWEEN ler.effective_start_date
                   AND ler.effective_end_date;
    --
    -- Create local variables required for API call
    --
    l_ptnl_ler_for_per_id   ben_ptnl_ler_for_per.ptnl_ler_for_per_id%TYPE;
    l_object_version_number ben_ptnl_ler_for_per.object_version_number%TYPE;
    --
    l_package               VARCHAR2(80)     := g_package || '.create_ptl_ler';
    --
    l_ler_name              VARCHAR2(240);
    l_ptnl_ler_trtmt_cd     VARCHAR2(30);
    l_ler_id                number;
    l_mnl_dt                DATE;
    l_dtctd_dt              DATE;
    l_procd_dt              DATE;
    l_unprocd_dt            DATE;
    l_voidd_dt              DATE;
    --
    l_sysdate               DATE;
  --
  BEGIN
    --
    -- Set sysdate to local
    --
    l_sysdate                 := SYSDATE;
    --
    hr_utility.set_location('Entering ' || l_package,10);
    --
    -- Quick test to make sure we are only creating life events of a
    -- certain type. This is specifically for temporal mode.
    --
    -- GRADE/STEP : Added or condition for GSP
    -- Dont trigget Potential if called from Unrestricted U,W,M,I,P,A
    --
    IF (NVL(ben_derive_part_and_rate_facts.g_temp_ler_id,p_ler_id) <> p_ler_id ) OR
       (NVL(g_pgm_typ_cd, 'KKKK') = 'GSP' and
        (NVL(ben_derive_part_and_rate_facts.g_temp_ler_id,g_gsp_ler_id) <> g_gsp_ler_id )) OR
        (NVL(ben_derive_part_and_rate_facts.g_no_ptnl_ler_id,p_ler_id) <> p_ler_id )
    THEN
      --
      -- We are creating life events of this type.
      --
    hr_utility.set_location('Entering ' || l_package,11);
      RETURN;
    --
    END IF;
    --
    -- Added if condition for GSP.
    --
    if g_pgm_typ_cd = 'GSP' then
       --
    hr_utility.set_location('Entering GSP ' || l_package,11);
       l_ler_id   := g_gsp_ler_id;
       l_ler_name := g_gsp_ler_name;
       --
    else
       --
    hr_utility.set_location('Entering Normal ' || l_package,11);
       l_ler_id   := p_ler_id;
       OPEN c1;
       FETCH c1 INTO l_ler_name,l_ptnl_ler_trtmt_cd ;
       CLOSE c1;
       --
      -- BUG 3275501 fixes
      --
      IF NVL(l_ptnl_ler_trtmt_cd ,'-1') = 'IGNRTHIS'  THEN
        --
        if g_debug then
          hr_utility.set_location('IGNRTHIS l_ptnl_ler_trtmt_cd '||l_ptnl_ler_trtmt_cd, 80);
        end if;
        --
        -- We are not creating life events or for IGNRTHIS cases
        --
        RETURN;
        --
      END IF;
      --
    end if;
    --
    -- We need to create a life event for the min max breach that
    -- has occured.
    --
    fnd_message.set_name('BEN'
     ,'BEN_91340_CREATE_PTNL_LER');
    fnd_message.set_token('LF_EVT'
     ,l_ler_name);
    benutils.write(p_text=> fnd_message.get);
    --
    if not p_calculate_only_mode then
      --
      ben_ptnl_ler_for_per_api.create_ptnl_ler_for_per_perf(p_validate=> FALSE
       ,p_ptnl_ler_for_per_id      => l_ptnl_ler_for_per_id
       ,p_lf_evt_ocrd_dt           => p_lf_evt_ocrd_dt
       ,p_ptnl_ler_for_per_stat_cd => 'DTCTD'
       ,p_ler_id                   => l_ler_id
       ,p_person_id                => p_person_id
       ,p_business_group_id        => p_business_group_id
       ,p_object_version_number    => l_object_version_number
       ,p_effective_date           => p_effective_date
       ,p_program_application_id   => fnd_global.prog_appl_id
       ,p_program_id               => fnd_global.conc_program_id
       ,p_request_id               => fnd_global.conc_request_id
       ,p_program_update_date      => l_sysdate
       ,p_ntfn_dt                  => TRUNC(l_sysdate)
       ,p_dtctd_dt                 => p_effective_date
       );
      --
    end if;
    --
    g_rec.person_id           := p_person_id;
    g_rec.ler_id              := l_ler_id;
    g_rec.lf_evt_ocrd_dt      := p_lf_evt_ocrd_dt;
    g_rec.replcd_flag         := 'N';
    g_rec.crtd_flag           := 'N';
    g_rec.tmprl_flag          := 'Y';
    g_rec.dltd_flag           := 'N';
    g_rec.open_and_clsd_flag  := 'N';
    g_rec.clsd_flag           := 'N';
    g_rec.not_crtd_flag       := 'N';
    g_rec.stl_actv_flag       := 'N';
    g_rec.clpsd_flag          := 'N';
    g_rec.clsn_flag           := 'N';
    g_rec.no_effect_flag      := 'N';
    g_rec.cvrge_rt_prem_flag  := 'N';
    g_rec.business_group_id   := p_business_group_id;
    g_rec.per_in_ler_id       := NULL;
    g_rec.effective_date      := p_effective_date;
    --
    benutils.write(p_rec=> g_rec);
    --
   -- hr_utility.set_location('Leaving ' || l_package,10);
  --
  END create_ptl_ler;
--
  FUNCTION no_life_event(
    p_lf_evt_ocrd_dt IN DATE
   ,p_person_id      IN NUMBER
   ,p_ler_id         IN NUMBER
   ,p_effective_date IN DATE)
    RETURN BOOLEAN IS
    --
    l_package VARCHAR2(80) := g_package || '.no_life_event';
    l_dummy   VARCHAR2(1);
    l_ler_id  number := p_ler_id;
    --
    -- Note this cursor should not consider dates or status of the potential
    -- life event as it could be someone was running in the past or future.
    --
    CURSOR c1 IS
      SELECT   NULL
      FROM     ben_ptnl_ler_for_per pil
      WHERE    pil.person_id = p_person_id
      AND      pil.ler_id = l_ler_id
      AND      pil.lf_evt_ocrd_dt = p_lf_evt_ocrd_dt;
  --
  BEGIN
    --
   -- hr_utility.set_location('Entering ' || l_package,10);
    --
    -- GRADE/STEP : check for grade/step le in case of GSP program.
    --
    if g_pgm_typ_cd = 'GSP' then
       l_ler_id := g_gsp_ler_id;
    end if;
    --
    OPEN c1;
    --
    FETCH c1 INTO l_dummy;
    IF c1%FOUND THEN
      --
      CLOSE c1;
     -- hr_utility.set_location('Life event exists ' || l_package,10);
      RETURN FALSE;
    --
    END IF;
    --
    CLOSE c1;
    --
   -- hr_utility.set_location('No Life event exists ' || l_package,10);
    --
    RETURN TRUE;
    --
   -- hr_utility.set_location('Leaving ' || l_package,10);
  --
  END no_life_event;
--
  PROCEDURE min_max_breach
    (p_calculate_only_mode in     boolean default false
    ,p_comp_obj_tree_row   IN     ben_manage_life_events.g_cache_proc_objects_rec
    ,p_curroiplip_row      IN     ben_cobj_cache.g_oiplip_inst_row
    ,p_person_id           IN     NUMBER
    ,p_pgm_id              IN     NUMBER
    ,p_pl_id               IN     NUMBER
    ,p_oipl_id             IN     NUMBER
    ,p_oiplip_id           IN     NUMBER
    ,p_plip_id             IN     NUMBER
    ,p_ptip_id             IN     NUMBER
    ,p_business_group_id   IN     NUMBER
    ,p_ler_id              IN     NUMBER
    ,p_min_value           IN     NUMBER
    ,p_max_value           IN     NUMBER
    ,p_new_value           IN     NUMBER
    ,p_old_value           IN     NUMBER
    ,p_uom                 IN     VARCHAR2
    ,p_subtract_date       IN     DATE
    ,p_det_cd              IN     VARCHAR2
    ,p_formula_id          IN     NUMBER DEFAULT NULL
    ,p_ptnl_ler_trtmt_cd   IN     VARCHAR2
    ,p_effective_date      IN     DATE
    )
  IS
    --
    l_package            VARCHAR2(80)        := g_package || '.min_max_breach';
    l_break              VARCHAR2(30);
    l_det_cd             VARCHAR2(30);
    l_lf_evt_ocrd_dt     DATE;
    l_new_lf_evt_ocrd_dt DATE;
    l_start_date         DATE;
    l_rec                ben_person_object.g_person_date_info_rec;
    l_oiplip_rec         ben_cobj_cache.g_oiplip_inst_row;
  --
  BEGIN
    --
    if g_debug then
      hr_utility.set_location('Entering ' || l_package,10);
    end if;
    --
    -- Check if we break a boundary
    --
    if g_debug then
      hr_utility.set_location('min_max_breach '||p_max_value , 99);
    end if;
    if g_debug then
      hr_utility.set_location('p_new_value '||p_new_value ,99) ;
    end if;
    if g_debug then
      hr_utility.set_location('p_old_value '||p_old_value ,99);
    end if;
    hr_utility.set_location('pgm id = ' || p_pgm_id, 9876);
    hr_utility.set_location('pgm id = ' ||p_comp_obj_tree_row.par_pgm_id, 9876);
    --
    /* Bug 5478918 */
    if (skip_min_max_le_calc(p_ler_id,
                             p_business_group_id,
                             p_ptnl_ler_trtmt_cd,
                             p_effective_date)) THEN
       --
       /* Simply return as no further calculations need to be done */
       hr_utility.set_location(l_package||' Returning from here.', 9877);
       RETURN;
       --
    end if;
    /* End Bug 5478918 */
    --
    IF benutils.min_max_breach(p_min_value=> NVL(p_min_value
                                              ,-1)
        ,p_max_value => NVL(p_max_value
                         ,99999999)
        ,p_new_value => p_new_value
        ,p_old_value => p_old_value
        ,p_break     => l_break) THEN
      --
      -- Derive life event occured date based on the value of l_break
      -- This will return either the min or max evaluated date.
      --
      IF p_oiplip_id IS NOT NULL THEN
        --
        l_oiplip_rec  := p_curroiplip_row;
      --
      END IF;
      --
      l_lf_evt_ocrd_dt      :=
        benutils.derive_date(p_date=> p_subtract_date
         ,p_uom   => p_uom
         ,p_min   => p_min_value
         ,p_max   => p_max_value
         ,p_value => l_break);

      l_new_lf_evt_ocrd_dt  := l_lf_evt_ocrd_dt;
      --
      --hr_utility.set_location(' l_lf_evt_ocrd_dt '||l_lf_evt_ocrd_dt , 30);
      --hr_utility.set_location(' l_new_lf_evt_ocrd_dt'||l_new_lf_evt_ocrd_dt,40);
      --
      -- Now apply the date mask on top of the derived life event occured date
      -- E.G. This could mean that we calculate the Previous October 1 of the
      -- derived life event occured date. Do not do this if the det_cd = 'AED'
      -- as it will reset the date to the life event occured on date.
      --
      IF p_det_cd <> 'AED' THEN
        --
        ben_determine_date.main(p_date_cd=> p_det_cd
         ,p_formula_id        => p_formula_id
         ,p_person_id         => p_person_id
         ,p_pgm_id            => NVL(p_pgm_id
                                  ,p_comp_obj_tree_row.par_pgm_id)
         ,p_pl_id             => p_pl_id
         ,p_oipl_id           => NVL(p_oipl_id
                                  ,l_oiplip_rec.oipl_id)
         ,p_business_group_id => p_business_group_id
         ,p_returned_date     => l_new_lf_evt_ocrd_dt
         ,p_lf_evt_ocrd_dt    => l_lf_evt_ocrd_dt
         ,p_effective_date    => l_lf_evt_ocrd_dt);
        --
        hr_utility.set_location(' l_new_lf_evt_ocrd_dt'||l_new_lf_evt_ocrd_dt,50);
        --
        -- The derived life event occured date must be greater than the
        -- life event occured date as otherwise in reality a boundary has not
        -- been passed.
        -- This can only happen if the det_cd is one of the following :
        -- AFDCPPY = As of first day of current program or plan year
        -- APOCT1 = As of previous october 1st
        -- AFDCM = As of first day of the current month
        --
        IF     l_new_lf_evt_ocrd_dt < l_lf_evt_ocrd_dt
           AND p_det_cd IN ('AFDCPPY', 'APOCT1', 'AFDCM','AFDECY') THEN
          --
          -- These are special cases where we need to rederive the LED
          -- so that we are actually still passing the correct boundary
          --
          l_det_cd  := p_det_cd;
          --
          IF p_det_cd = 'APOCT1' or p_det_cd = 'AFDECY' THEN
            --
            l_lf_evt_ocrd_dt  := ADD_MONTHS(l_lf_evt_ocrd_dt
                                  ,12);
          --
          ELSIF p_det_cd = 'AFDCM' THEN
            --
            -- Why this is required ??? causing Bug 1927010
            --
            -- l_lf_evt_ocrd_dt  := ADD_MONTHS(l_lf_evt_ocrd_dt ,1);
            null ;
            --hr_utility.set_location(' l_lf_evt_ocrd_dt '||l_lf_evt_ocrd_dt , 60);
          --
          ELSIF p_det_cd = 'AFDCPPY' THEN
            --
            l_det_cd  := 'AFDFPPY';
          --
          END IF;
          --
          -- Reapply logic back to determination of date routine.
          --
          ben_determine_date.main(p_date_cd=> l_det_cd
           ,p_formula_id        => p_formula_id
           ,p_person_id         => p_person_id
           ,p_pgm_id            => NVL(p_pgm_id
                                    ,p_comp_obj_tree_row.par_pgm_id)
           ,p_pl_id             => p_pl_id
           ,p_oipl_id           => NVL(p_oipl_id
                                    ,l_oiplip_rec.oipl_id)
           ,p_business_group_id => p_business_group_id
           ,p_returned_date     => l_new_lf_evt_ocrd_dt
           ,p_lf_evt_ocrd_dt    => l_lf_evt_ocrd_dt
           ,p_effective_date    => l_lf_evt_ocrd_dt);
         --
         hr_utility.set_location(' l_lf_evt_ocrd_dt '||l_lf_evt_ocrd_dt ,70);
         hr_utility.set_location(' l_new_lf_evt_ocrd_dt'||l_new_lf_evt_ocrd_dt,80);
        --
        END IF;
      --
      END IF;
      --
      --  If date determination code is ALDECLY (End of Calendar Year), set
      --  the life event occurred date to the start of the calendar year.
      --  Bug 5731828.
      IF p_det_cd = 'ALDECLY' then
        l_new_lf_evt_ocrd_dt := trunc(l_new_lf_evt_ocrd_dt, 'YYYY');
        --
        ben_person_object.get_object(p_person_id=> p_person_id
         ,p_rec       => l_rec);
        --
        --  If the person is hired after Jan 1, then set the occurred date
        --  to the effective start date.
        --
        if l_new_lf_evt_ocrd_dt < l_rec.min_per_effective_start_date THEN
           l_new_lf_evt_ocrd_dt := l_rec.min_per_effective_start_date;
        end if;
      end if;
      --
      -- Check if we can ignore the life event that is attempted to be created
      --
      if g_debug then
        hr_utility.set_location(' l_new_lf_evt_ocrd_dt'||l_new_lf_evt_ocrd_dt,90);
        hr_utility.set_location(' p_effective_date'||p_effective_date,100);
      end if;
      --
      IF   (  l_new_lf_evt_ocrd_dt < p_effective_date
         AND NVL(p_ptnl_ler_trtmt_cd,'-1') = 'IGNR')  THEN
        --
        -- We ignore life events that are to be created in the past
        --
        RETURN;
      --
      END IF;
      --
      -- We need to work out if the life event date is valid.
      -- The following rules apply.
      -- 1) Determined date must exist
      -- 2) Minimum life event occured dates are as follows :
      --    AGE - LED must be greater than min(effective_start_date) of person
      --    LOS - LED must be greater than min(effective_start_date) of person
      --
      IF l_new_lf_evt_ocrd_dt IS NOT NULL THEN
        --
        ben_person_object.get_object(p_person_id=> p_person_id
         ,p_rec       => l_rec);
        --
        IF l_new_lf_evt_ocrd_dt < l_rec.min_per_effective_start_date THEN
          --
          RETURN;
        --
        END IF;
      --
      ELSE
        --
        -- Defensive in case the date routine returned a null
        --
        RETURN;
      --
      END IF;
      --
      -- At this point we need to check whether there is an existing life
      -- event out there with the same life event occured date.
      -- If not we create a life event only if the person has an elig per
      -- f record.
      --
      if g_debug then
        hr_utility.set_location(' no_life_event ',110);
      end if;
      --
      IF no_life_event(p_lf_evt_ocrd_dt=> l_new_lf_evt_ocrd_dt
          ,p_person_id      => p_person_id
          ,p_ler_id         => p_ler_id
          ,p_effective_date => p_effective_date) THEN
        --
        if g_debug then
          hr_utility.set_location(' call to create_ptl_ler' , 120);
        end if;
        create_ptl_ler
          (p_calculate_only_mode => p_calculate_only_mode
          ,p_ler_id              => p_ler_id
          ,p_lf_evt_ocrd_dt      => l_new_lf_evt_ocrd_dt
          ,p_person_id           => p_person_id
          ,p_business_group_id   => p_business_group_id
          ,p_effective_date      => p_effective_date
          );
      Else
         --
         g_lf_evt_exists  := true;
      --
      END IF;
    --
    END IF;
    --
   if g_debug then
     hr_utility.set_location('Leaving ' || l_package,10);
   end if;
  --
  END min_max_breach;
--
  FUNCTION los_calculation(
    p_comp_obj_tree_row IN            ben_manage_life_events.g_cache_proc_objects_rec
   ,p_empasg_row        IN            per_all_assignments_f%ROWTYPE
   ,p_benasg_row        IN            per_all_assignments_f%ROWTYPE
   ,p_pil_row           IN            ben_per_in_ler%ROWTYPE
   ,p_curroipl_row      IN            ben_cobj_cache.g_oipl_inst_row
   ,p_curroiplip_row    IN            ben_cobj_cache.g_oiplip_inst_row
   ,p_rec               IN            ben_derive_part_and_rate_cache.g_cache_los_rec_obj
   ,p_comp_rec          IN OUT NOCOPY g_cache_structure
   ,p_effective_date    IN            DATE
   ,p_lf_evt_ocrd_dt    IN            DATE
   ,p_business_group_id IN            NUMBER
   ,p_person_id         IN            NUMBER
   ,p_pgm_id            IN            NUMBER
   ,p_pl_id             IN            NUMBER
   ,p_oipl_id           IN            NUMBER
   ,p_oiplip_id         IN            NUMBER
   ,p_plip_id           IN            NUMBER
   ,p_ptip_id           IN            NUMBER
   ,p_subtract_date     OUT NOCOPY    DATE
   ,p_fonm_cvg_strt_dt  IN            Date default null)
    RETURN NUMBER IS
    --
    l_package       VARCHAR2(80)            := g_package || '.los_calculation';
    l_subtract_date DATE;
    l_start_date    DATE;
    l_result        NUMBER;
    l_pps_rec       per_periods_of_service%ROWTYPE;
    l_per_rec       per_all_people_f%ROWTYPE;
    l_dummy_num     NUMBER;
    l_aei_rec       per_assignment_extra_info%ROWTYPE;
    l_ass_rec       per_all_assignments_f%ROWTYPE;
    l_oiplip_rec    ben_cobj_cache.g_oiplip_inst_row;
  --
  BEGIN
   -- hr_utility.set_location('Entering ' || l_package,10);
    --
    -- Steps to perform process
    --
    -- 1) Work out the start date
    -- 2) Work out the date we are subtracting
    -- 3) Perform subtraction using correct unit of measure
    -- 4) Perform Rounding
    -- 5) Check if a boundary has been broken
    --
    IF p_oiplip_id IS NOT NULL THEN
      --
      l_oiplip_rec  := p_curroiplip_row;
    --
    END IF;
    --
    ben_determine_date.main(p_date_cd=> p_rec.los_det_cd
     ,p_formula_id        => p_rec.los_det_rl
     ,p_person_id         => p_person_id
     ,p_pgm_id            => NVL(p_pgm_id
                              ,p_comp_obj_tree_row.par_pgm_id)
     ,p_pl_id             => p_pl_id
     ,p_oipl_id           => NVL(p_oipl_id
                              ,l_oiplip_rec.oipl_id)
     ,p_business_group_id => p_business_group_id
     ,p_returned_date     => l_start_date
      --fonm2
     ,p_lf_evt_ocrd_dt    =>  p_lf_evt_ocrd_dt
     ,p_effective_date    =>  nvl(p_lf_evt_ocrd_dt,p_effective_date)
     ,p_fonm_cvg_strt_dt  => p_fonm_cvg_strt_dt
     );
    --
    ben_person_object.get_object(p_person_id=> p_person_id
     ,p_rec       => l_pps_rec);
    --
    -- Bug 5392019 : For Date to use codes like 'Inherited%' use benefits assignment
    --
    if p_rec.los_dt_to_use_cd in ('IASD', 'IDOH', 'IOHD')
    then
      l_ass_rec := p_benasg_row;
    else
      l_ass_rec := p_empasg_row;
    end if;
    --
    IF l_ass_rec.assignment_id IS NOT NULL THEN
     -- hr_utility.set_location('get extra info',10);
      --
      -- Fix for 115.77
      --
      ben_person_object.get_object(p_assignment_id=> l_ass_rec.assignment_id
       ,p_rec           => l_aei_rec);
    --
    END IF;
    --
    IF p_rec.los_dt_to_use_cd = 'OHD' THEN
      -- Original hire date
      ben_person_object.get_object(p_person_id=> p_person_id
       ,p_rec       => l_per_rec);
      --
      IF l_per_rec.original_date_of_hire IS NOT NULL THEN
        --
        l_subtract_date  := l_per_rec.original_date_of_hire;
      --
      ELSE
        --
        l_subtract_date  := l_pps_rec.date_start;
      --
      END IF;
    --
    ELSIF p_rec.los_dt_to_use_cd = 'DOH' THEN
      -- Get the persons hire date only if the override service date flag is 'N'
      IF p_rec.use_overid_svc_dt_flag = 'N' THEN
        -- Get the persons hire date
        l_subtract_date  := l_pps_rec.date_start;
      --
      ELSIF p_comp_rec.ovrid_svc_dt IS NULL THEN
        --
        l_subtract_date  := l_pps_rec.date_start;
      --
      ELSE
        --
        l_subtract_date  := p_comp_rec.ovrid_svc_dt;
      --
      END IF;
    --
    ELSIF p_rec.los_dt_to_use_cd = 'ASD' THEN
      --
      -- Get the persons adjusted service date
      -- only if the override service date flag is 'N'
      --
      IF p_rec.use_overid_svc_dt_flag = 'N' THEN
        -- get person adjusted start date if its not null
        IF l_pps_rec.adjusted_svc_date IS NULL THEN
          --
          l_subtract_date  := l_pps_rec.date_start;
        --
        ELSE
          --
          l_subtract_date  := l_pps_rec.adjusted_svc_date;
        --
        END IF;
      --
      ELSE
        --
        -- We set the start date to the override value
        --
        IF p_comp_rec.ovrid_svc_dt IS NOT NULL THEN
          --
          l_subtract_date  := p_comp_rec.ovrid_svc_dt;
        --
        ELSE
          --
          l_subtract_date  := l_pps_rec.date_start;
        --
        END IF;
      --
      END IF;
    --
    ELSIF p_rec.los_dt_to_use_cd = 'IASD' THEN
      --
      -- inherited adjusted start date
      --
      IF p_rec.use_overid_svc_dt_flag = 'Y' THEN
        --
        l_subtract_date  := p_comp_rec.ovrid_svc_dt;
        --
        IF l_subtract_date IS NULL THEN
          --
          l_subtract_date  :=
                       fnd_date.canonical_to_date(l_aei_rec.aei_information2);
        --
        END IF;
      --
      ELSE
        --
        l_subtract_date  :=
                       fnd_date.canonical_to_date(l_aei_rec.aei_information2);
      --
      END IF;
    --
    ELSIF p_rec.los_dt_to_use_cd = 'IDOH' THEN
      --
      -- inherited date of hire
      --
      IF p_rec.use_overid_svc_dt_flag = 'Y' THEN
        --
        l_subtract_date  := p_comp_rec.ovrid_svc_dt;
        --
        IF l_subtract_date IS NULL THEN
          --
          l_subtract_date  :=
                      fnd_date.canonical_to_date(l_aei_rec.aei_information13);
        --
        END IF;
      --
      ELSE
        --
        l_subtract_date  :=
                      fnd_date.canonical_to_date(l_aei_rec.aei_information13);
      --
      END IF;
    --
    ELSIF p_rec.los_dt_to_use_cd = 'IOHD' THEN
      --
      -- inherited original hire date
      --
      l_subtract_date  :=
                       fnd_date.canonical_to_date(l_aei_rec.aei_information3);
    --
    ELSIF p_rec.los_dt_to_use_cd = 'RL' THEN
      --
      run_rule(p_formula_id => p_rec.los_dt_to_use_rl
       ,p_empasg_row        => p_empasg_row
       ,p_benasg_row        => p_benasg_row
       ,p_pil_row           => p_pil_row
       ,p_curroipl_row      => p_curroipl_row
       ,p_curroiplip_row    => p_curroiplip_row
       ,p_rule_type         => 'DATE'
       ,p_effective_date    => p_effective_date
       ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
       ,p_business_group_id => p_business_group_id
       ,p_person_id         => p_person_id
       ,p_pgm_id            => nvl(p_pgm_id,
                                   p_comp_obj_tree_row.par_pgm_id)
       ,p_pl_id             => nvl(p_pl_id,
                                   p_comp_obj_tree_row.par_pl_id)
       ,p_oipl_id           => p_oipl_id
       ,p_oiplip_id         => p_oiplip_id
       ,p_plip_id           => nvl(p_plip_id,
                                   p_comp_obj_tree_row.par_plip_id)
       ,p_ptip_id           => nvl(p_ptip_id,
                                   p_comp_obj_tree_row.par_ptip_id)
       ,p_ret_date          => l_subtract_date
       ,p_ret_val           => l_dummy_num);
    --
    ELSE
      --
      fnd_message.set_name('BEN'
       ,'BEN_91342_UNKNOWN_CODE_1');
      fnd_message.set_token('PROC'
       ,l_package);
      fnd_message.set_token('CODE1'
       ,p_rec.los_dt_to_use_cd);
      RAISE ben_manage_life_events.g_record_error;
    --
    END IF;
    --
    -- Account for case where person is not an employee thus has
    -- no override_service_date, hire_date or adjusted_service_date
    --
    IF l_subtract_date IS NULL THEN
      --
     -- hr_utility.set_location('Leaving ' || l_package,10);
      RETURN NULL;
    --
    END IF;
    --
    IF p_rec.los_uom IS NOT NULL THEN
      --
      l_result  :=
        benutils.do_uom(p_date1=> l_start_date
         ,p_date2 => l_subtract_date
         ,p_uom   => p_rec.los_uom);
    --
    ELSE
      --
      l_result  := MONTHS_BETWEEN(l_start_date
                    ,l_subtract_date);
    --
    END IF;
    --
    IF    p_rec.rndg_cd IS NOT NULL
       OR p_rec.rndg_rl IS NOT NULL THEN
      -- dont use fonm date , the date only used for formula
      l_result  :=
        benutils.do_rounding(p_rounding_cd=> p_rec.rndg_cd
         ,p_rounding_rl    => p_rec.rndg_rl
         ,p_value          => l_result
         ,p_effective_date => NVL(p_lf_evt_ocrd_dt
                               ,p_effective_date) );
    --
    END IF;
    --
    hr_utility.set_location('p_subtract_date -> ' || p_subtract_date,99);
    --
    p_subtract_date  := l_subtract_date;
    hr_utility.set_location('Leaving ' || l_package,99);
    RETURN l_result;
  --
  END los_calculation;
--
  FUNCTION age_calculation(
    p_comp_obj_tree_row IN     ben_manage_life_events.g_cache_proc_objects_rec
   ,p_per_row           IN     per_all_people_f%ROWTYPE
   ,p_empasg_row        IN     per_all_assignments_f%ROWTYPE
   ,p_benasg_row        IN     per_all_assignments_f%ROWTYPE
   ,p_pil_row           IN     ben_per_in_ler%ROWTYPE
   ,p_curroipl_row      IN     ben_cobj_cache.g_oipl_inst_row
   ,p_curroiplip_row    IN     ben_cobj_cache.g_oiplip_inst_row
   ,p_rec               IN     ben_derive_part_and_rate_cache.g_cache_age_rec_obj
   ,p_effective_date    IN     DATE
   ,p_lf_evt_ocrd_dt    IN     DATE
   ,p_business_group_id IN     NUMBER
   ,p_person_id         IN     NUMBER
   ,p_pgm_id            IN     NUMBER
   ,p_pl_id             IN     NUMBER
   ,p_oipl_id           IN     NUMBER
   ,p_oiplip_id         IN     NUMBER
   ,p_plip_id           IN     NUMBER
   ,p_ptip_id           IN     NUMBER
   ,p_subtract_date     OUT NOCOPY    DATE
   ,p_fonm_cvg_strt_dt  IN     date default null  )
    RETURN NUMBER IS
    --
    l_package           VARCHAR2(80)        := g_package || '.age_calculation';
    --
    l_effective_date    DATE;
    l_proc              VARCHAR2(80)                      := 'age_calculation';
    l_subtract_date     DATE;
    l_start_date        DATE;
    l_result            NUMBER;
    l_dummy_num         NUMBER;
    l_outputs           ff_exec.outputs_t;
    l_pil_rec           ben_per_in_ler%ROWTYPE;
    l_pl_rec            ben_pl_f%ROWTYPE;
    l_oipl_rec          ben_oipl_f%ROWTYPE;
    l_oiplip_rec        ben_cobj_cache.g_oiplip_inst_row;
    l_ass_rec           per_all_assignments_f%ROWTYPE;
    l_loc_rec           hr_locations_all%ROWTYPE;
    l_per_rec           per_all_people_f%ROWTYPE;
    l_person_id         NUMBER;
    l_jurisdiction_code VARCHAR2(30);
    l_aei_rec           per_assignment_extra_info%ROWTYPE;
    --
    --bug#3274130 - added date condition for relationship to pick the right spouse
    CURSOR c_per_spouse IS
      SELECT   per.person_id
              ,per.date_of_birth
      FROM     per_contact_relationships ctr, per_all_people_f per
      WHERE    ctr.person_id = p_person_id
      AND      per.person_id = ctr.contact_person_id
      AND      ctr.personal_flag = 'Y'
      AND      ctr.contact_type = 'S'
      and      l_effective_date between nvl(ctr.date_start, hr_api.g_sot)
               and  nvl(ctr.date_end, hr_api.g_eot)
      AND      l_effective_date BETWEEN per.effective_start_date
                   AND per.effective_end_date;
    --
    CURSOR c_per_depen_first IS
      SELECT   per.person_id
              ,per.date_of_birth
      FROM     per_contact_relationships ctr, per_all_people_f per
      WHERE    ctr.person_id = p_person_id
      AND      per.person_id = ctr.contact_person_id
      AND      ctr.personal_flag = 'Y'
      AND      ctr.dependent_flag = 'Y'
      AND      l_effective_date BETWEEN per.effective_start_date
                   AND per.effective_end_date;
    --
    CURSOR c_per_child_first IS
      SELECT   per.person_id
              ,per.date_of_birth
      FROM     per_contact_relationships ctr, per_all_people_f per
      WHERE    ctr.person_id = p_person_id
      AND      per.person_id = ctr.contact_person_id
      AND      ctr.personal_flag = 'Y'
      AND      ctr.contact_type IN ('C', 'O', 'A', 'T')
      AND      l_effective_date BETWEEN per.effective_start_date
                   AND per.effective_end_date;
    --
    CURSOR c_per_depen_oldest IS
      SELECT   per.person_id
              ,per.date_of_birth
      FROM     per_contact_relationships ctr, per_all_people_f per
      WHERE    ctr.person_id = p_person_id
      AND      per.person_id = ctr.contact_person_id
      AND      ctr.personal_flag = 'Y'
      AND      ctr.dependent_flag = 'Y'
      AND      l_effective_date BETWEEN per.effective_start_date
                   AND per.effective_end_date
       ORDER BY per.date_of_birth;
    --
    CURSOR c_per_child_oldest IS
      SELECT   per.person_id
              ,per.date_of_birth
      FROM     per_contact_relationships ctr, per_all_people_f per
      WHERE    ctr.person_id = p_person_id
      AND      per.person_id = ctr.contact_person_id
      AND      ctr.personal_flag = 'Y'
      AND      ctr.contact_type IN ('C', 'O', 'A', 'T')
      AND      l_effective_date BETWEEN per.effective_start_date
                   AND per.effective_end_date
       ORDER BY per.date_of_birth;
    --
    CURSOR c_per_depen_young IS
      SELECT   per.person_id
              ,per.date_of_birth
      FROM     per_contact_relationships ctr, per_all_people_f per
      WHERE    ctr.person_id = p_person_id
      AND      per.person_id = ctr.contact_person_id
      AND      ctr.personal_flag = 'Y'
      AND      ctr.dependent_flag = 'Y'
      AND      l_effective_date BETWEEN per.effective_start_date
                   AND per.effective_end_date
       ORDER BY per.date_of_birth DESC;
    --
    CURSOR c_per_child_young IS
      SELECT   per.person_id
              ,per.date_of_birth
      FROM     per_contact_relationships ctr, per_all_people_f per
      WHERE    ctr.person_id = p_person_id
      AND      per.person_id = ctr.contact_person_id
      AND      ctr.personal_flag = 'Y'
      AND      ctr.contact_type IN ('C', 'O', 'A', 'T')
      AND      l_effective_date BETWEEN per.effective_start_date
                   AND per.effective_end_date
       ORDER BY per.date_of_birth DESC;
    --
    l_per               c_per_spouse%ROWTYPE;
  --
  BEGIN
    --
   -- hr_utility.set_location('Entering ' || l_package,10);
    --
    -- Steps to perform process
    --
    -- 1) Work out the start date
    -- 2) Work out the date we are subtracting
    -- 3) Perform subtraction using correct unit of measure
    -- 4) Perform Rounding
    -- 5) Check if a boundary has been broken
    --
    IF p_lf_evt_ocrd_dt IS NOT NULL THEN
      --
      l_effective_date  := p_lf_evt_ocrd_dt;
    --
    ELSE
      --
      l_effective_date  := p_effective_date;
    --
    END IF;

    -- fonm2
    l_effective_date := NVL(g_fonm_cvg_strt_dt,l_effective_date);
    --
    IF p_oiplip_id IS NOT NULL THEN
      --
      l_oiplip_rec  := p_curroiplip_row;
    --
    END IF;
  --
-- -- hr_utility.set_location('Age to use code '||p_rec.age_to_use_cd,10);
  --
    IF    p_rec.age_to_use_cd = 'P'
       OR (    p_rec.age_to_use_cd IS NULL
           AND p_rec.age_calc_rl IS NULL) THEN
      --  we already have the person_id so use it
      l_person_id  := p_person_id;
    --
    ELSIF p_rec.age_calc_rl IS NOT NULL THEN
      --
      run_rule(p_formula_id => p_rec.age_calc_rl
       ,p_empasg_row        => p_empasg_row
       ,p_benasg_row        => p_benasg_row
       ,p_pil_row           => p_pil_row
       ,p_curroipl_row      => p_curroipl_row
       ,p_curroiplip_row    => p_curroiplip_row
       ,p_rule_type         => 'DATE'
       ,p_effective_date    => p_effective_date
       ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
       ,p_business_group_id => p_business_group_id
       ,p_person_id         => p_person_id
       ,p_pgm_id            => p_pgm_id
       ,p_pl_id             => p_pl_id
       ,p_oipl_id           => p_oipl_id
       ,p_oiplip_id         => p_oiplip_id
       ,p_plip_id           => p_plip_id
       ,p_ptip_id           => p_ptip_id
       ,p_ret_date          => l_per.date_of_birth
       ,p_ret_val           => l_dummy_num);
      --
      IF l_per.date_of_birth IS NULL THEN
        --
        RETURN NULL;
      --
      END IF;
      --
      l_per_rec.date_of_birth  := l_per.date_of_birth;
    --
    ELSIF p_rec.age_to_use_cd = 'PS' THEN
      --
      OPEN c_per_spouse;
      --
      FETCH c_per_spouse INTO l_per;
      --
      CLOSE c_per_spouse;
      --
      IF l_per.date_of_birth IS NOT NULL THEN
        --
        l_person_id  := l_per.person_id;
      --
      ELSE
        --
        RETURN NULL;
      --
      END IF;
      --
      l_per_rec.date_of_birth  := l_per.date_of_birth;
    --
    ELSIF p_rec.age_to_use_cd = 'PD1' THEN
      --
      OPEN c_per_depen_first;
      --
      FETCH c_per_depen_first INTO l_per;
      --
      CLOSE c_per_depen_first;
      --
      IF l_per.date_of_birth IS NOT NULL THEN
        --
        l_person_id  := l_per.person_id;
      --
      ELSE
        --
        RETURN NULL;
      --
      END IF;
      --
      l_per_rec.date_of_birth  := l_per.date_of_birth;
    --
    ELSIF p_rec.age_to_use_cd = 'PDO' THEN
      --
      OPEN c_per_depen_oldest;
      --
      FETCH c_per_depen_oldest INTO l_per;
      --
      CLOSE c_per_depen_oldest;
      --
      IF l_per.date_of_birth IS NOT NULL THEN
        --
        l_person_id  := l_per.person_id;
      --
      ELSE
        --
        RETURN NULL;
      --
      END IF;
      --
      l_per_rec.date_of_birth  := l_per.date_of_birth;
    --
    ELSIF p_rec.age_to_use_cd = 'PC1' THEN
      --
      OPEN c_per_child_first;
      --
      FETCH c_per_child_first INTO l_per;
      --
      CLOSE c_per_child_first;
      --
      IF l_per.date_of_birth IS NOT NULL THEN
        --
        l_person_id  := l_per.person_id;
      --
      ELSE
        --
        RETURN NULL;
      --
      END IF;
      --
      l_per_rec.date_of_birth  := l_per.date_of_birth;
    --
    ELSIF p_rec.age_to_use_cd = 'PCO' THEN
      --
      OPEN c_per_child_oldest;
      --
      FETCH c_per_child_oldest INTO l_per;
      --
      CLOSE c_per_child_oldest;
      --
      IF l_per.date_of_birth IS NOT NULL THEN
        --
        l_person_id  := l_per.person_id;
      --
      ELSE
        --
        RETURN NULL;
      --
      END IF;
      --
      l_per_rec.date_of_birth  := l_per.date_of_birth;
    --
    ELSIF p_rec.age_to_use_cd = 'PCY' THEN
      --
      OPEN c_per_child_young;
      --
      FETCH c_per_child_young INTO l_per;
      --
      CLOSE c_per_child_young;
      --
      IF l_per.date_of_birth IS NOT NULL THEN
        --
        l_person_id  := l_per.person_id;
      --
      ELSE
        --
        RETURN NULL;
      --
      END IF;
      --
      l_per_rec.date_of_birth  := l_per.date_of_birth;
    --
    ELSIF p_rec.age_to_use_cd = 'PDY' THEN
      --
      OPEN c_per_depen_young;
      --
      FETCH c_per_depen_young INTO l_per;
      --
      CLOSE c_per_depen_young;
      --
      IF l_per.date_of_birth IS NOT NULL THEN
        --
        l_person_id  := l_per.person_id;
      --
      ELSE
        --
        RETURN NULL;
      --
      END IF;
      --
      l_per_rec.date_of_birth  := l_per.date_of_birth;
    --
    ELSIF p_rec.age_to_use_cd = 'IA' THEN
      --
      l_ass_rec  := p_benasg_row;
      --
      IF l_ass_rec.assignment_id IS NOT NULL THEN
        --
        ben_person_object.get_object(p_assignment_id=> l_ass_rec.assignment_id
         ,p_rec           => l_aei_rec);
      --
      END IF;
      --
      IF l_aei_rec.aei_information1 IS NULL THEN
        --
        RETURN NULL;
      --
      ELSE
        --
        IF p_rec.age_uom = 'YR' THEN
          l_result  := TO_NUMBER(l_aei_rec.aei_information1);
        ELSIF p_rec.age_uom = 'MO' THEN
          l_result  := TO_NUMBER(l_aei_rec.aei_information1) * 12;
        ELSIF p_rec.age_uom = 'WK' THEN
          l_result  := (TO_NUMBER(l_aei_rec.aei_information1) * 365) / 7;
        ELSIF p_rec.age_uom = 'DY' THEN
          l_result  := TO_NUMBER(l_aei_rec.aei_information1) * 365;
        ELSE
          l_result  := TO_NUMBER(l_aei_rec.aei_information1);
        END IF;
      --
      END IF;
    --
    END IF;
    --
    IF    p_rec.age_to_use_cd <> 'IA'
       OR p_rec.age_calc_rl IS NOT NULL THEN
      --
      if g_debug then
        hr_utility.set_location(' BDD_Mn ' || l_package,10);
      end if;
      ben_determine_date.main(p_date_cd=> p_rec.age_det_cd
       ,p_formula_id        => p_rec.age_det_rl
       ,p_person_id         => p_person_id
       ,p_pgm_id            => NVL(p_pgm_id
                                ,p_comp_obj_tree_row.par_pgm_id)
       ,p_pl_id             => p_pl_id
       ,p_oipl_id           => NVL(p_oipl_id
                                ,l_oiplip_rec.oipl_id)
       ,p_returned_date     => l_start_date
       -- fonm2
       ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
       ,p_business_group_id => p_business_group_id
       ,p_effective_date    => NVL(p_lf_evt_ocrd_dt ,p_effective_date )
       ,p_fonm_cvg_strt_dt  => p_fonm_cvg_strt_dt );
      --
      IF p_rec.age_to_use_cd = 'P' THEN
        --
        l_per_rec  := p_per_row;
      --
/*
      ben_person_object.get_object(p_person_id => l_person_id,
                                   p_rec       => l_per_rec);
      --
*/
      --hr_utility.set_location(' Dn BPO_GO ' || l_package,10);
      END IF;
      --
      l_subtract_date  := l_per_rec.date_of_birth;
      --
      IF l_subtract_date IS NULL THEN
        --
        RETURN NULL;
      --
      END IF;
      --
      IF p_rec.age_uom IS NOT NULL THEN
        --
        l_result  :=
          benutils.do_uom(p_date1=> l_start_date
           ,p_date2 => l_subtract_date
           ,p_uom   => p_rec.age_uom);
      --
      ELSE
        --
        l_result  := MONTHS_BETWEEN(l_start_date
                      ,l_subtract_date);
      --
      END IF;
      --
      --hr_utility.set_location(' Dn <> IA ' ||l_result,10);
    END IF;
    --
    IF    p_rec.rndg_cd IS NOT NULL
       OR p_rec.rndg_rl IS NOT NULL THEN
      --
      l_result  :=
        benutils.do_rounding(p_rounding_cd=> p_rec.rndg_cd
         ,p_rounding_rl    => p_rec.rndg_rl
         ,p_value          => l_result
         ,p_effective_date =>  NVL(p_lf_evt_ocrd_dt
                               ,p_effective_date));
    --
    END IF;
    --
   hr_utility.set_location('return  ' || l_subtract_date,10);
   hr_utility.set_location('Leaving ' || l_package,10);
    --
    p_subtract_date  := l_subtract_date;
    RETURN l_result;
  --
  END age_calculation;
--
  FUNCTION hours_calculation(
    p_comp_obj_tree_row IN ben_manage_life_events.g_cache_proc_objects_rec
   ,p_empasg_row        IN per_all_assignments_f%ROWTYPE
   ,p_benasg_row        IN per_all_assignments_f%ROWTYPE
   ,p_curroiplip_row    IN ben_cobj_cache.g_oiplip_inst_row
   ,p_rec               IN ben_derive_part_and_rate_cache.g_cache_hwf_rec_obj
   ,p_business_group_id IN NUMBER
   ,p_person_id         IN NUMBER
   ,p_pgm_id            IN NUMBER
   ,p_pl_id             IN NUMBER
   ,p_oipl_id           IN NUMBER
   ,p_oiplip_id         IN NUMBER
   ,p_plip_id           IN NUMBER
   ,p_ptip_id           IN NUMBER
   ,p_effective_date    IN DATE
   ,p_lf_evt_ocrd_dt    IN DATE)
    RETURN NUMBER IS
    --
    l_package           VARCHAR2(80)      := g_package || '.hours_calculation';
    l_start_date        DATE;
    l_result            NUMBER;
    l_outputs           ff_exec.outputs_t;
    l_pil_rec           ben_per_in_ler%ROWTYPE;
    l_pl_rec            ben_pl_f%ROWTYPE;
    l_oipl_rec          ben_oipl_f%ROWTYPE;
    l_oiplip_rec        ben_cobj_cache.g_oiplip_inst_row;
    l_loc_rec           hr_locations_all%ROWTYPE;
    l_ass_rec           per_all_assignments_f%ROWTYPE;
    l_bal_rec           ben_per_bnfts_bal_f%ROWTYPE;
    l_bnb_rec           ben_bnfts_bal_f%ROWTYPE;
    l_jurisdiction_code VARCHAR2(30);
    l_assignment_action_id  number;


    Cursor c_ass is
      select min(effective_start_date)
      From  per_all_assignments_f ass
      where person_id = p_person_id
      and   ass.assignment_type <> 'C'
      and primary_flag = 'Y' ;

    l_min_ass_date date ;

  --
  BEGIN
    --
    if g_debug then
      hr_utility.set_location('Entering ' || l_package,10);
    end if;
    --
    -- Steps to perform process
    --
    -- 1) Work out the start date
    -- 2) Perform Rounding
    --
    IF p_oiplip_id IS NOT NULL THEN
      --
      l_oiplip_rec  := p_curroiplip_row;
    --
    END IF;
    --
    ben_determine_date.main(p_date_cd=> p_rec.hrs_wkd_det_cd
     ,p_formula_id        => p_rec.hrs_wkd_det_rl
     ,p_person_id         => p_person_id
     ,p_bnfts_bal_id      => p_rec.bnfts_bal_id
     ,p_pgm_id            => NVL(p_pgm_id
                              ,p_comp_obj_tree_row.par_pgm_id)
     ,p_pl_id             => p_pl_id
     ,p_oipl_id           => NVL(p_oipl_id
                              ,l_oiplip_rec.oipl_id)
     ,p_business_group_id => p_business_group_id
     ,p_returned_date     => l_start_date
     ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
     ,p_effective_date    => NVL(p_lf_evt_ocrd_dt ,p_effective_date)
     ,p_fonm_cvg_strt_dt  => g_fonm_cvg_strt_dt);
    --
    if g_debug then
      hr_utility.set_location('p_rec.hrs_src_cd '||p_rec.hrs_src_cd ,20);
    end if;
    IF p_rec.hrs_src_cd = 'BNFTBALTYP' THEN
      --
      IF ben_whatif_elig.g_bnft_bal_hwf_val IS NOT NULL THEN
        --
        -- This is the case where benmngle is called from the
        -- watif form and user wants to simulate hours worked
        -- changed. Use the user supplied simulate hours value rather
        -- than the fetched value.
        --
        l_result  := ben_whatif_elig.g_bnft_bal_hwf_val;
      --
      ELSE
        --
        -- Get the persons balance
        if g_debug then
          hr_utility.set_location(' p_rec.bnfts_bal_id '||p_rec.bnfts_bal_id , 30);
        end if;
        if g_debug then
          hr_utility.set_location(' p_person_id '||p_person_id , 30);
        end if;
        if g_debug then
          hr_utility.set_location(' l_start_date '||l_start_date, 30);
        end if;
        --
        ben_person_object.get_object(p_person_id=> p_person_id
         ,p_effective_date => l_start_date
         ,p_bnfts_bal_id   => p_rec.bnfts_bal_id
         ,p_rec            => l_bal_rec);
        --
        l_result  := l_bal_rec.val;
        --
        IF l_result IS NULL THEN

           if p_rec.hrs_wkd_det_cd in
              ('AFDCPPY','AFDCSPPY','AFDCPPQ','AFDCM','AFDCSM','APOCT1','AFDECY' ) then

              open c_ass ;
              fetch c_ass into l_min_ass_date ;
              close c_ass ;

              if g_debug then
                hr_utility.set_location (' l_min_ass_date ' || l_min_ass_date, 1999);
              end if;
              if l_min_ass_date  is not null then
                 ben_person_object.get_object(p_person_id=> p_person_id
                       ,p_effective_date => l_min_ass_date
                       ,p_bnfts_bal_id   => p_rec.bnfts_bal_id
                       ,p_rec            => l_bal_rec);
                 --
                 l_result  := l_bal_rec.val;
              end if ;
           end if ;

        end if ;

        IF l_result IS NULL THEN
          --
          if g_debug then
            hr_utility.set_location(' Person does not have a balance ',40);
          end if;
          --
          -- Person does not have a balance, recheck if they have a balance
          -- as of the life event occurred date or effective date.
          -- Fix for bug 216.
          --
          ben_person_object.get_object(p_bnfts_bal_id=> p_rec.bnfts_bal_id
           ,p_rec          => l_bnb_rec);
          --
          fnd_message.set_name('BEN'
           ,'BEN_92317_PER_BALANCE_NULL');
          fnd_message.set_token('NAME'
           ,l_bnb_rec.name);
          fnd_message.set_token('DATE'
           ,l_start_date);
          benutils.write(p_text=> fnd_message.get);
          --
          ben_person_object.get_object(p_person_id=> p_person_id
           ,p_effective_date => nvl(g_fonm_cvg_strt_dt,NVL(p_lf_evt_ocrd_dt
                                 ,p_effective_date))
           ,p_bnfts_bal_id   => p_rec.bnfts_bal_id
           ,p_rec            => l_bal_rec);
          --
          l_result  := l_bal_rec.val;
          if g_debug then
            hr_utility.set_location(' Person does not l_bal_rec.val  '||l_bal_rec.val ,50);
          end if;
          --
          IF l_result IS NULL THEN
            --
            fnd_message.set_name('BEN'
             ,'BEN_92317_PER_BALANCE_NULL');
            fnd_message.set_token('NAME'
             ,l_bnb_rec.name);
            fnd_message.set_token('DATE'
             ,NVL(p_lf_evt_ocrd_dt
               ,p_effective_date));
            benutils.write(p_text=> fnd_message.get);
            RETURN NULL;
          --
          END IF;
        --
        END IF;
      --
      END IF;                           -- whatif hours worked existence check
    --
    ELSIF p_rec.hrs_src_cd = 'BALTYP' THEN
      --
      IF ben_whatif_elig.g_bal_hwf_val IS NOT NULL THEN
        --
        -- This is the case where benmngle is called from the
        -- watif form and user wants to simulate hours worked
        -- changed. Use the user supplied simulate hours value rather
        -- than the fetched value.
        --
        l_result  := ben_whatif_elig.g_bal_hwf_val;
      --
      ELSE
        --
        -- Get the persons balance
        --
        IF p_empasg_row.assignment_id IS NULL THEN
          --
          l_ass_rec  := p_benasg_row;
        --
        ELSE
          --
          l_ass_rec  := p_empasg_row;
        --
        END IF;
        -- before calling the get_value set the tax_unit_id context
        set_taxunit_context
            (p_person_id           =>     p_person_id
            ,p_business_group_id   =>     p_business_group_id
            ,p_effective_date      =>     nvl(g_fonm_cvg_strt_dt,p_effective_date)
             ) ;
        --
        -- Bug 3818453. Pass assignment_action_id to get_value() to
        -- improve performance
        --
        l_assignment_action_id :=
                          get_latest_paa_id
                          (p_person_id         => p_person_id
                          ,p_business_group_id => p_business_group_id
                          ,p_effective_date    => l_start_date);

        if l_assignment_action_id is not null then
           --
           begin
              l_result  :=
              pay_balance_pkg.get_value(p_rec.defined_balance_id
              ,l_assignment_action_id);
           exception
             when others then
             l_result := null ;
           end ;
           --
        end if;
        if l_result is null then
           fnd_message.set_name('BEN' ,'BEN_92318_BEN_BALANCE_NULL');
           fnd_message.set_token('DATE' ,l_start_date);
           benutils.write(p_text=> fnd_message.get);
           return null;
        end if;

        --
        -- old code prior to 3818453
        --
/*        --
        begin
           l_result  :=
           pay_balance_pkg.get_value(p_rec.defined_balance_id
           ,l_ass_rec.assignment_id
           ,l_start_date);
        exception
          when others then
          l_result := null ;
        end ;

        IF l_result IS NULL THEN
            if p_rec.hrs_wkd_det_cd in
                 ('AFDCPPY','AFDCSPPY','AFDCPPQ','AFDCM','AFDCSM','APOCT1','AFDECY' ) then
                 open c_ass ;
                 fetch c_ass into l_min_ass_date ;
                 close c_ass ;
                 if g_debug then
                   hr_utility.set_location (' l_min_ass_date ' || l_min_ass_date, 1999);
                 end if;
                 l_result  :=
                     pay_balance_pkg.get_value(p_rec.defined_balance_id
                    ,l_ass_rec.assignment_id
                    ,l_min_ass_date);

              end if ;
        end if ;

        --
        IF l_result IS NULL THEN
          --
          -- Person does not have a balance, recheck if they have a balance
          -- as of the life event occurred date or effective date.
          -- Fix for bug 216.
          --
          fnd_message.set_name('BEN'
           ,'BEN_92318_BEN_BALANCE_NULL');
          fnd_message.set_token('DATE'
           ,l_start_date);
          benutils.write(p_text=> fnd_message.get);
          --
          l_result  :=
            pay_balance_pkg.get_value(p_rec.defined_balance_id
             ,l_ass_rec.assignment_id
             ,NVL(p_lf_evt_ocrd_dt
               ,p_effective_date));
          --
          IF l_result IS NULL THEN
            --
            fnd_message.set_name('BEN'
             ,'BEN_92318_BEN_BALANCE_NULL');
            fnd_message.set_token('DATE'
             ,NVL(p_lf_evt_ocrd_dt
               ,p_effective_date));
            benutils.write(p_text=> fnd_message.get);
            RETURN NULL;
          --
          END IF;
        --
        END IF; */
      --
      END IF;                          -- whatif hours worked existence check.
    --
    END IF;
    --
    IF    p_rec.rndg_cd IS NOT NULL
       OR p_rec.rndg_rl IS NOT NULL THEN
      --
      l_result  :=
        benutils.do_rounding(p_rounding_cd=> p_rec.rndg_cd
         ,p_rounding_rl    => p_rec.rndg_rl
         ,p_value          => l_result
         ,p_effective_date => NVL(p_lf_evt_ocrd_dt
                               ,p_effective_date));
    --
    END IF;
    --
    if g_debug then
      hr_utility.set_location(' End of hours_calculation l_result '||l_result, 50);
    end if;
    --
    RETURN l_result;
  --
  END hours_calculation;
  ------------------------------------------------------------------------------
  -- ******THIS IS NOW OBSOLETED ***********************************************
  -- We are now using the call to BEN_DERIVE_FACTORS.determine_compensation
  -- to determine the compensation to avoid maitening the similar code at two
  -- different places.
  -------------------------------------------------------------------------------
  FUNCTION comp_calculation(
    p_comp_obj_tree_row IN ben_manage_life_events.g_cache_proc_objects_rec
   ,p_empasg_row        IN per_all_assignments_f%ROWTYPE
   ,p_benasg_row        IN per_all_assignments_f%ROWTYPE
   ,p_curroiplip_row    IN ben_cobj_cache.g_oiplip_inst_row
   ,p_rec               IN ben_derive_part_and_rate_cache.g_cache_clf_rec_obj
   ,p_person_id         IN NUMBER
   ,p_business_group_id IN NUMBER
   ,p_pgm_id            IN NUMBER
   ,p_pl_id             IN NUMBER
   ,p_oipl_id           IN NUMBER
   ,p_oiplip_id         IN NUMBER
   ,p_plip_id           IN NUMBER
   ,p_ptip_id           IN NUMBER
   ,p_effective_date    IN DATE
   ,p_lf_evt_ocrd_dt    IN DATE)
    RETURN NUMBER IS

   ---
   Cursor c_ass is
      select min(effective_start_date)
      From  per_all_assignments_f ass
      where person_id = p_person_id
      and   ass.assignment_type <> 'C'
      and primary_flag = 'Y' ;

    l_min_ass_date date ;

    --
    l_package           VARCHAR2(80)       := g_package || '.comp_calculation';
    l_start_date        DATE;
    l_result            NUMBER;
    l_outputs           ff_exec.outputs_t;
    l_pil_rec           ben_per_in_ler%ROWTYPE;
    l_pl_rec            ben_pl_f%ROWTYPE;
    l_oipl_rec          ben_oipl_f%ROWTYPE;
    l_oiplip_rec        ben_cobj_cache.g_oiplip_inst_row;
    l_loc_rec           hr_locations_all%ROWTYPE;
    l_ass_rec           per_all_assignments_f%ROWTYPE;
    l_bal_rec           ben_per_bnfts_bal_f%ROWTYPE;
    l_bnb_rec           ben_bnfts_bal_f%ROWTYPE;
    l_jurisdiction_code VARCHAR2(30);
    l_assignment_action_id  number;
  --
  BEGIN
   g_debug := hr_utility.debug_enabled;
   --
   -- hr_utility.set_location('Entering ' || l_package,10);
    --
    -- Steps to perform process
    --
    -- 1) Work out the start date
    -- 2) Perform Rounding
    --
   --FONM2
   if ben_manage_life_events.fonm = 'Y'
      and ben_manage_life_events.g_fonm_cvg_strt_dt  is not null then
     --
     g_fonm_cvg_strt_dt := ben_manage_life_events.g_fonm_cvg_strt_dt ;
     --
   else
    g_fonm_cvg_strt_dt := null ;
   end if;
   -- fonm


    IF p_oiplip_id IS NOT NULL THEN
      --
      l_oiplip_rec  := p_curroiplip_row;
    --
    END IF;
    --
    ben_determine_date.main(p_date_cd=> p_rec.comp_lvl_det_cd
     ,p_formula_id        => p_rec.comp_lvl_det_rl
     ,p_person_id         => p_person_id
     ,p_pgm_id            => NVL(p_pgm_id
                              ,p_comp_obj_tree_row.par_pgm_id)
     ,p_bnfts_bal_id      => p_rec.bnfts_bal_id
     ,p_pl_id             => p_pl_id
     ,p_oipl_id           => NVL(p_oipl_id
                              ,l_oiplip_rec.oipl_id)
     ,p_business_group_id => p_business_group_id
     ,p_returned_date     => l_start_date
     ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
     ,p_effective_date    => NVL(p_lf_evt_ocrd_dt ,p_effective_date)
     ,p_fonm_cvg_strt_dt  => g_fonm_cvg_strt_dt);
    --
    IF p_rec.comp_src_cd = 'STTDCOMP' THEN
      --
      IF ben_whatif_elig.g_stat_comp IS NOT NULL THEN
        --
        -- This is the case where benmngle is called from the
        -- watif form and user wants to simulate compensation level
        -- changed. Use the user supplied compensation value rather
        -- than the fetched value.
        --
        l_result  := ben_whatif_elig.g_stat_comp;
      --
      ELSE
        --
        -- Get the persons salary
        --
        l_result  :=
          get_persons_salary(p_empasg_row=> p_empasg_row
           ,p_benasg_row        => p_benasg_row
           ,p_person_id         => p_person_id
           ,p_business_group_id => p_business_group_id
           ,p_effective_date    => l_start_date);
        --
        IF l_result IS NULL THEN
          --
          -- Person does not have a balance, recheck if they have a balance
          -- as of the life event occurred date or effective date.
          -- Fix for bug 216.
          --
          fnd_message.set_name('BEN'
           ,'BEN_92319_SAL_BALANCE_NULL');
          fnd_message.set_token('DATE'
           ,l_start_date);
          benutils.write(p_text=> fnd_message.get);
          ---if date code is
          -- first of year,half year,quarter,month,semi month,previos oct 1
          -- then take the firstist salary
          if p_rec.comp_lvl_det_cd in
              ('AFDCPPY','AFDCSPPY','AFDCPPQ','AFDCM','AFDCSM','APOCT1','AFDECY' ) then
              open c_ass ;
              fetch c_ass into l_min_ass_date ;
              close c_ass ;
              if g_debug then
                hr_utility.set_location (' l_min_ass_date ' || l_min_ass_date, 1999);
              end if;
              if l_min_ass_date  is not null then
                 l_result  :=
                 get_persons_salary(p_empasg_row=> p_empasg_row
                      ,p_benasg_row        => p_benasg_row
                      ,p_person_id         => p_person_id
                      ,p_business_group_id => p_business_group_id
                      ,p_effective_date    => l_min_ass_date);
                  if g_debug then
                    hr_utility.set_location ('result ' || l_result , 1999);
                  end if;
               end if ;
           end if ;
        End if ;

        IF l_result IS NULL THEN
           --
           l_result  :=
            get_persons_salary(p_empasg_row=> p_empasg_row
             ,p_benasg_row        => p_benasg_row
             ,p_person_id         => p_person_id
             ,p_business_group_id => p_business_group_id
             ,p_effective_date    => NVL(p_lf_evt_ocrd_dt
                                      ,p_effective_date));
          --
           IF l_result IS NULL THEN
            --
            fnd_message.set_name('BEN'
             ,'BEN_92319_SAL_BALANCE_NULL');
            fnd_message.set_token('DATE'
             ,NVL(p_lf_evt_ocrd_dt
               ,p_effective_date));
            benutils.write(p_text=> fnd_message.get);
            RETURN NULL;
            --
           END IF;
        --
        END IF;
      --
      END IF;                          -- whatif compensation existence check.
    --
    ELSIF p_rec.comp_src_cd = 'BNFTBALTYP' THEN
      --
      IF ben_whatif_elig.g_bnft_bal_comp IS NOT NULL THEN
        --
        -- This is the case where benmngle is called from the
        -- watif form and user wants to simulate compensation level
        -- changed. Use the user supplied compensation value rather
        -- than the fetched value.
        --
        l_result  := ben_whatif_elig.g_bnft_bal_comp;
      --
      ELSE
        --
        -- Get the persons balance
        --
        ben_person_object.get_object(p_person_id=> p_person_id
         ,p_effective_date => l_start_date
         ,p_bnfts_bal_id   => p_rec.bnfts_bal_id
         ,p_rec            => l_bal_rec);
        --
        l_result  := l_bal_rec.val;
        --
        IF l_result IS NULL THEN
           if p_rec.comp_lvl_det_cd in
              ('AFDCPPY','AFDCSPPY','AFDCPPQ','AFDCM','AFDCSM','APOCT1','AFDECY' ) then

              open c_ass ;
              fetch c_ass into l_min_ass_date ;
              close c_ass ;

              if g_debug then
                hr_utility.set_location (' l_min_ass_date ' || l_min_ass_date, 1999);
              end if;
              if l_min_ass_date  is not null then
                 ben_person_object.get_object(p_person_id=> p_person_id
                       ,p_effective_date => l_min_ass_date
                       ,p_bnfts_bal_id   => p_rec.bnfts_bal_id
                       ,p_rec            => l_bal_rec);
                 --
                 l_result  := l_bal_rec.val;
              end if ;
          end if ;
          IF l_result IS NULL THEN
              --
              -- Person does not have a balance, recheck if they have a balance
              -- as of the life event occurred date or effective date.
              -- Fix for bug 216.
              --
              ben_person_object.get_object(p_bnfts_bal_id=> p_rec.bnfts_bal_id
               ,p_rec          => l_bnb_rec);
              --
              fnd_message.set_name('BEN'
               ,'BEN_92317_PER_BALANCE_NULL');
              fnd_message.set_token('NAME'
               ,l_bnb_rec.name);
              fnd_message.set_token('DATE'
               ,l_start_date);
              benutils.write(p_text=> fnd_message.get);
              --
              ben_person_object.get_object(p_person_id=> p_person_id
               ,p_effective_date => p_effective_date
               ,p_bnfts_bal_id   => p_rec.bnfts_bal_id
               ,p_rec            => l_bal_rec);
              --
              l_result  := l_bal_rec.val;
              --
              IF l_result IS NULL THEN
                --
                fnd_message.set_name('BEN'
                 ,'BEN_92317_PER_BALANCE_NULL');
                fnd_message.set_token('NAME'
                 ,l_bnb_rec.name);
                fnd_message.set_token('DATE'
                 ,NVL(p_lf_evt_ocrd_dt
                   ,p_effective_date));
                benutils.write(p_text=> fnd_message.get);
                RETURN NULL;
              --
              END IF;
            --
            END IF;
          --
        End if ;
      END IF;                          -- whatif compensation existence check.
    --
    ELSIF p_rec.comp_src_cd = 'BALTYP' THEN
      --
      IF ben_whatif_elig.g_bal_comp IS NOT NULL THEN
        --
        -- This is the case where benmngle is called from the
        -- watif form and user wants to simulate compensation level
        -- changed. Use the user supplied compensation value rather
        -- than the fetched value.
        --
        l_result  := ben_whatif_elig.g_bal_comp;
      --
      ELSE
        --
        -- Get the persons balance
        --
        IF p_empasg_row.assignment_id IS NULL THEN
          --
          l_ass_rec  := p_benasg_row;
        --
        ELSE
          --
          l_ass_rec  := p_empasg_row;
        --
        END IF;
          -- before calling the get_value set the tax_unit_id context
        set_taxunit_context
            (p_person_id           =>     p_person_id
            ,p_business_group_id   =>     p_business_group_id
            ,p_effective_date      =>     nvl(g_fonm_cvg_strt_dt,p_effective_date)
             ) ;
        --
        -- Bug 3818453. Pass assignment_action_id to get_value() to
        -- improve performance
        --
        l_assignment_action_id :=
                          get_latest_paa_id
                          (p_person_id         => p_person_id
                          ,p_business_group_id => p_business_group_id
                          ,p_effective_date    => l_start_date);

        if l_assignment_action_id is not null then
           --
           begin
              l_result  :=
              pay_balance_pkg.get_value(p_rec.defined_balance_id
              ,l_assignment_action_id);
           exception
             when others then
             l_result := null ;
           end ;
           --
        end if ;

        if l_result is null then
           fnd_message.set_name('BEN' ,'BEN_92318_BEN_BALANCE_NULL');
           fnd_message.set_token('DATE' ,l_start_date);
           benutils.write(p_text=> fnd_message.get);
           return null;
        end if;
        --
        --
        -- old code prior to 3818453
        --
/*
        --
        l_result  :=
          pay_balance_pkg.get_value(p_rec.defined_balance_id
           ,l_ass_rec.assignment_id
           ,l_start_date);

        IF l_result IS NULL THEN
            if p_rec.comp_lvl_det_cd in
               ('AFDCPPY','AFDCSPPY','AFDCPPQ','AFDCM','AFDCSM','APOCT1','AFDECY' ) then

               open c_ass ;
               fetch c_ass into l_min_ass_date ;
               close c_ass ;

               if g_debug then
                 hr_utility.set_location (' l_min_ass_date ' || l_min_ass_date, 1999);
               end if;
               if l_min_ass_date  is not null then
                  l_result  :=
                     pay_balance_pkg.get_value(p_rec.defined_balance_id
                     ,l_ass_rec.assignment_id
                     ,l_min_ass_date);

               end if ;
               --
            end if ;
            IF l_result IS NULL THEN
               --
               -- Person does not have a balance, recheck if they have a balance
               -- as of the life event occurred date or effective date.
               -- Fix for bug 216.
               --
               fnd_message.set_name('BEN'
                ,'BEN_92318_BEN_BALANCE_NULL');
               fnd_message.set_token('DATE'
                ,l_start_date);
               benutils.write(p_text=> fnd_message.get);
               l_result  :=
                 pay_balance_pkg.get_value(p_rec.defined_balance_id
                  ,l_ass_rec.assignment_id
                  ,NVL(p_lf_evt_ocrd_dt
                    ,p_effective_date));
               --
               IF l_result IS NULL THEN
                 --
                 fnd_message.set_name('BEN'
                  ,'BEN_92318_BEN_BALANCE_NULL');
                 fnd_message.set_token('DATE'
                  ,NVL(p_lf_evt_ocrd_dt
                    ,p_effective_date));
                 benutils.write(p_text=> fnd_message.get);
                 RETURN NULL;
                 --
               END IF;
               --
            END IF;
            --
         End If ; */
      END IF;                          -- whatif compensation existence check.
    --
    END IF;
    --
    IF    p_rec.rndg_cd IS NOT NULL
       OR p_rec.rndg_rl IS NOT NULL THEN
      --
      l_result  :=
        benutils.do_rounding(p_rounding_cd=> p_rec.rndg_cd
         ,p_rounding_rl    => p_rec.rndg_rl
         ,p_value          => l_result
         ,p_effective_date => NVL(p_lf_evt_ocrd_dt
                               ,p_effective_date));
    --
    END IF;
    --
    RETURN l_result;
    --
   -- hr_utility.set_location('Entering ' || l_package,10);
  --
  END comp_calculation;
--
  PROCEDURE calculate_los
    (p_calculate_only_mode in     boolean default false
    ,p_comp_obj_tree_row   IN     ben_manage_life_events.g_cache_proc_objects_rec
    ,p_empasg_row          IN     per_all_assignments_f%ROWTYPE
    ,p_benasg_row          IN     per_all_assignments_f%ROWTYPE
    ,p_pil_row             IN     ben_per_in_ler%ROWTYPE
    ,p_curroipl_row        IN     ben_cobj_cache.g_oipl_inst_row
    ,p_curroiplip_row      IN     ben_cobj_cache.g_oiplip_inst_row
    ,p_person_id           IN     NUMBER
    ,p_business_group_id   IN     NUMBER
    ,p_pgm_id              IN     NUMBER
    ,p_pl_id               IN     NUMBER
    ,p_oipl_id             IN     NUMBER
    ,p_plip_id             IN     NUMBER
    ,p_ptip_id             IN     NUMBER
    ,p_oiplip_id           IN     NUMBER
    ,p_ptnl_ler_trtmt_cd   IN     VARCHAR2
    ,p_los_fctr_id         IN     NUMBER DEFAULT NULL
    ,p_comp_rec            IN OUT NOCOPY g_cache_structure
    ,p_effective_date      IN     DATE
    ,p_lf_evt_ocrd_dt      IN     DATE
    )
  IS
    --
    l_package        VARCHAR2(80)             := g_package || '.calculate_los';
    --
    l_rate_result    NUMBER;
    l_rate_cvg_result NUMBER;
    l_rate_prem_result NUMBER;
    l_elig_result    NUMBER;
    l_subtract_date  DATE;
    l_start_date     DATE;
    l_elig_rec       ben_derive_part_and_rate_cache.g_cache_los_rec_obj;
    l_rate_rec       ben_derive_part_and_rate_cache.g_cache_los_rec_obj;
    l_rate_cvg_rec   ben_derive_part_and_rate_cache.g_cache_los_rec_obj;
    l_rate_prem_rec  ben_derive_part_and_rate_cache.g_cache_los_rec_obj;
    l_der_cvg_rec    ben_seeddata_object.g_derived_factor_info_rec;
    l_der_prem_rec   ben_seeddata_object.g_derived_factor_info_rec;
    l_der_rec        ben_seeddata_object.g_derived_factor_info_rec;
    l_effective_date DATE          := NVL(p_lf_evt_ocrd_dt
                                       ,p_effective_date);
    l_dummy_date     DATE;
    l_rate           BOOLEAN                                         := FALSE;
    l_cvg            BOOLEAN                                         := FALSE;
    l_prem           BOOLEAN                                         := FALSE;
    l_oiplip_rec     ben_cobj_cache.g_oiplip_inst_row;
    l_los_val        number;
    --FONM
    --g_fonm_cvg_strt_dt DATE ;
    --END FONM
  --
  BEGIN
   --
   --
--
-- Calculate LOS process
-- =====================
-- This process will calculate the LOS value for rates and eligibility
-- The sequence of operations is as follows :
-- 1) First check if freeze LOS flag is on in which case
--    we ignore the calculation and just return the frozen values
-- 2) Calculate for eligibility derivable factors
-- 3) Calculate for rate derivable factors
-- 3) Perform rounding
-- 4) Test for min/max breach
-- 5) If a breach did occur then create a ptnl_ler_for_per.
    --
    IF bitand(p_comp_obj_tree_row.flag_bit_val
           ,ben_manage_life_events.g_los_flag) <> 0
       OR     p_los_fctr_id IS NOT NULL
          AND bitand(p_comp_obj_tree_row.flag_bit_val
               ,ben_manage_life_events.g_cal_flag) <> 0 THEN
      --
     -- hr_utility.set_location('LOS for ELIG',10);
      IF p_comp_rec.frz_los_flag = 'Y' THEN
        --
        -- No calulation required just return the frozen value
        --
        NULL;
      --
      ELSE
        --
        IF p_los_fctr_id IS NOT NULL THEN
          --
          ben_derive_part_and_rate_cache.get_los_stated(p_los_fctr_id=> p_los_fctr_id
           ,p_business_group_id => p_business_group_id
           ,p_rec               => l_elig_rec);
        --
        ELSE
          --
          ben_derive_part_and_rate_cache.get_los_elig(p_pgm_id=> p_pgm_id
           ,p_pl_id             => p_pl_id
           ,p_oipl_id           => p_oipl_id
           ,p_plip_id           => p_plip_id
           ,p_ptip_id           => p_ptip_id
           ,p_business_group_id => p_business_group_id
           ,p_effective_date    => NVL(g_fonm_cvg_strt_dt,l_effective_date)
           ,p_rec               => l_elig_rec);
        --
        END IF;
        --
        IF l_elig_rec.exist = 'Y' THEN
          -- los based on los_calc_rl takes precedence
          IF l_elig_rec.los_calc_rl IS NOT NULL THEN
            --
            ben_determine_date.main(p_date_cd=> l_elig_rec.los_det_cd
             ,p_formula_id        => l_elig_rec.los_det_rl
             ,p_person_id         => p_person_id
             ,p_pgm_id            => NVL(p_pgm_id
                                      ,p_comp_obj_tree_row.par_pgm_id)
             ,p_pl_id             => p_pl_id
             ,p_oipl_id           => p_oipl_id
             ,p_business_group_id => p_business_group_id
             ,p_returned_date     => l_start_date
             ,p_lf_evt_ocrd_dt    =>  p_lf_evt_ocrd_dt
             ,p_effective_date    =>  NVL(p_lf_evt_ocrd_dt ,p_effective_date)
            );
            --
            run_rule(p_formula_id => l_elig_rec.los_calc_rl
             ,p_empasg_row        => p_empasg_row
             ,p_benasg_row        => p_benasg_row
             ,p_pil_row           => p_pil_row
             ,p_curroipl_row      => p_curroipl_row
             ,p_curroiplip_row    => p_curroiplip_row
             ,p_effective_date    => l_start_date
             ,p_lf_evt_ocrd_dt    => l_start_date
             ,p_business_group_id => p_business_group_id
             ,p_person_id         => p_person_id
             ,p_pgm_id            => p_pgm_id
             ,p_pl_id             => p_pl_id
             ,p_oipl_id           => p_oipl_id
             ,p_oiplip_id         => p_oiplip_id
             ,p_plip_id           => p_plip_id
             ,p_ptip_id           => p_ptip_id
             ,p_ret_date          => l_dummy_date
             ,p_ret_val           => l_elig_result);
            --
            -- Round value if rounding needed
            --
            IF    l_elig_rec.rndg_cd IS NOT NULL
               OR l_elig_rec.rndg_rl IS NOT NULL THEN
              --
              l_elig_result  :=
                benutils.do_rounding(p_rounding_cd=> l_elig_rec.rndg_cd
                 ,p_rounding_rl    => l_elig_rec.rndg_rl
                 ,p_value          => l_elig_result
                 ,p_effective_date => NVL(g_fonm_cvg_strt_dt,
                                          NVL(p_lf_evt_ocrd_dt ,p_effective_date))
               );
            --
            END IF;
          --
          ELSE
            l_elig_result  :=
              los_calculation(p_comp_obj_tree_row=> p_comp_obj_tree_row
               ,p_empasg_row        => p_empasg_row
               ,p_benasg_row        => p_benasg_row
               ,p_pil_row           => p_pil_row
               ,p_curroipl_row      => p_curroipl_row
               ,p_curroiplip_row    => p_curroiplip_row
               ,p_rec               => l_elig_rec
               ,p_comp_rec          => p_comp_rec
               ,p_effective_date    => p_effective_date
               ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
               ,p_business_group_id => p_business_group_id
               ,p_person_id         => p_person_id
               ,p_pgm_id            => p_pgm_id
               ,p_pl_id             => p_pl_id
               ,p_oipl_id           => p_oipl_id
               ,p_oiplip_id         => p_oiplip_id
               ,p_plip_id           => p_plip_id
               ,p_ptip_id           => p_ptip_id
               ,p_subtract_date     => l_subtract_date
               ,p_fonm_cvg_strt_dt  => g_fonm_cvg_strt_dt);
          END IF;
          --
          IF     l_elig_result IS NOT NULL
             AND p_los_fctr_id IS NULL THEN
             --
             --
             -- if person is still ineligible elig_per rows are not updated - to simulate the
             -- elig_per data the old val is assigned the min value if the temporal life event
             -- was created before for the same breach
             l_los_val         := p_comp_rec.los_val;
             Loop
               g_lf_evt_exists   := false;
               ben_derive_part_and_rate_cache.get_los_elig(p_pgm_id=> p_pgm_id
              ,p_pl_id             => p_pl_id
              ,p_oipl_id           => p_oipl_id
              ,p_plip_id           => p_plip_id
              ,p_ptip_id           => p_ptip_id
              ,p_new_val           => l_elig_result
              ,p_old_val           => l_los_val
              ,p_business_group_id => p_business_group_id
              ,p_effective_date    => NVL(g_fonm_cvg_strt_dt,l_effective_date)
              ,p_rec               => l_elig_rec);
            --

            ben_seeddata_object.get_object(p_rec=> l_der_rec);
            --
            min_max_breach
              (p_calculate_only_mode => p_calculate_only_mode
              ,p_comp_obj_tree_row   => p_comp_obj_tree_row
              ,p_curroiplip_row      => p_curroiplip_row
              ,p_person_id           => p_person_id
              ,p_pgm_id              => p_pgm_id
              ,p_pl_id               => p_pl_id
              ,p_oipl_id             => p_oipl_id
              ,p_oiplip_id           => p_oiplip_id
              ,p_plip_id             => p_plip_id
              ,p_ptip_id             => p_ptip_id
              ,p_business_group_id   => p_business_group_id
              ,p_ler_id              => l_der_rec.drvdlos_id
              ,p_min_value           => l_elig_rec.mn_los_num
              ,p_max_value           => l_elig_rec.mx_los_num
              ,p_new_value           => l_elig_result
              ,p_old_value           => l_los_val
              ,p_uom                 => l_elig_rec.los_uom
              ,p_subtract_date       => l_subtract_date
              ,p_det_cd              => l_elig_rec.los_det_cd
              ,p_formula_id          => l_elig_rec.los_det_rl
              ,p_ptnl_ler_trtmt_cd   => p_ptnl_ler_trtmt_cd
              ,p_effective_date      => p_effective_date
              );
            --
              if not g_lf_evt_exists or l_los_val = l_elig_rec.mn_los_num or
                    l_elig_rec.mn_los_num is null then
                 exit;
              else
                 l_los_val := l_elig_rec.mn_los_num;
              end if;
            End Loop;
            g_lf_evt_exists := false;
            p_comp_rec.los_val  := l_elig_result;
            p_comp_rec.los_uom  := l_elig_rec.los_uom;
          --
          ELSIF l_elig_result IS NULL THEN
            --
            p_comp_rec.los_val  := NULL;
            p_comp_rec.los_uom  := NULL;
          --
          ELSE
            --
            p_comp_rec.los_val  := l_elig_result;
            p_comp_rec.los_uom  := l_elig_rec.los_uom;
          --
          END IF;
        --
        ELSE
          --
          p_comp_rec.los_val  := NULL;
          p_comp_rec.los_uom  := NULL;
        --
        END IF;
      --
      END IF;
    --
    END IF;
    --
    IF    bitand(p_comp_obj_tree_row.flag_bit_val
           ,ben_manage_life_events.g_los_rt_flag) <> 0
       OR     p_los_fctr_id IS NOT NULL
          AND bitand(p_comp_obj_tree_row.flag_bit_val
               ,ben_manage_life_events.g_cal_rt_flag) <> 0
       OR     p_oiplip_id IS NOT NULL
          AND bitand(p_comp_obj_tree_row.oiplip_flag_bit_val
               ,ben_manage_life_events.g_los_rt_flag) <> 0 THEN
      --
     -- hr_utility.set_location('LOS for RT',10);
      IF p_comp_rec.rt_frz_los_flag = 'Y' THEN
        --
        -- No calulation required just return the frozen value
        --
        NULL;
      --
      ELSE
        --
        IF p_los_fctr_id IS NOT NULL THEN
          --
          ben_derive_part_and_rate_cache.get_los_stated(p_los_fctr_id=> p_los_fctr_id
           ,p_business_group_id => p_business_group_id
           ,p_rec               => l_rate_rec);
        --
        ELSE
          --
          ben_derive_part_and_rate_cache.get_los_rate(p_pgm_id=> p_pgm_id
           ,p_pl_id             => p_pl_id
           ,p_oipl_id           => p_oipl_id
           ,p_plip_id           => p_plip_id
           ,p_ptip_id           => p_ptip_id
           ,p_oiplip_id         => p_oiplip_id
           ,p_business_group_id => p_business_group_id
           ,p_effective_date    => NVL(g_fonm_cvg_strt_dt,l_effective_date)
           ,p_rec               => l_rate_rec);
          --
          IF l_rate_rec.exist = 'Y' THEN
            --
            l_rate  := TRUE;
            --
            IF p_oiplip_id IS NOT NULL THEN
              --
              l_oiplip_rec  := p_curroiplip_row;
            --
            END IF;
            --
                     -- los based on los_calc_rl takes precedence
            IF l_rate_rec.los_calc_rl IS NOT NULL THEN
              --
              ben_determine_date.main(p_date_cd=> l_rate_rec.los_det_cd
               ,p_formula_id        => l_rate_rec.los_det_rl
               ,p_person_id         => p_person_id
               ,p_pgm_id            => NVL(p_pgm_id
                                        ,p_comp_obj_tree_row.par_pgm_id)
               ,p_pl_id             => p_pl_id
               ,p_oipl_id           => NVL(p_oipl_id
                                        ,l_oiplip_rec.oipl_id)
               ,p_business_group_id => p_business_group_id
               ,p_returned_date     => l_start_date
               ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
               ,p_effective_date    => NVL(p_lf_evt_ocrd_dt ,p_effective_date));
              --
              run_rule(p_formula_id => l_rate_rec.los_calc_rl
               ,p_empasg_row        => p_empasg_row
               ,p_benasg_row        => p_benasg_row
               ,p_pil_row           => p_pil_row
               ,p_curroipl_row      => p_curroipl_row
               ,p_curroiplip_row    => p_curroiplip_row
               ,p_effective_date    => p_effective_date
               ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
               ,p_business_group_id => p_business_group_id
               ,p_person_id         => p_person_id
               ,p_pgm_id            => p_pgm_id
               ,p_pl_id             => p_pl_id
               ,p_oipl_id           => NVL(p_oipl_id
                                        ,l_oiplip_rec.oipl_id)
               ,p_oiplip_id         => p_oiplip_id
               ,p_plip_id           => p_plip_id
               ,p_ptip_id           => p_ptip_id
               ,p_ret_date          => l_dummy_date
               ,p_ret_val           => l_rate_result);
                --
               IF    l_rate_rec.rndg_cd IS NOT NULL
                 OR l_rate_rec.rndg_rl IS NOT NULL THEN
                 --
                 l_rate_result  :=
                      benutils.do_rounding(p_rounding_cd=> l_rate_rec.rndg_cd
                       ,p_rounding_rl    => l_rate_rec.rndg_rl
                       ,p_value          => l_rate_result
                       ,p_effective_date => NVL(g_fonm_cvg_strt_dt,NVL(p_lf_evt_ocrd_dt
                                          ,p_effective_date)));
                 --
               END IF;
             ELSE   -- l_rate_rec.los_calc_rl
               --
               l_rate_result  :=
                 los_calculation(p_comp_obj_tree_row=> p_comp_obj_tree_row
                  ,p_empasg_row        => p_empasg_row
                  ,p_benasg_row        => p_benasg_row
                  ,p_pil_row           => p_pil_row
                  ,p_curroipl_row      => p_curroipl_row
                  ,p_curroiplip_row    => p_curroiplip_row
                  ,p_rec               => l_rate_rec
                  ,p_comp_rec          => p_comp_rec
                  ,p_effective_date    => p_effective_date
                  ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
                  ,p_business_group_id => p_business_group_id
                  ,p_person_id         => p_person_id
                  ,p_pgm_id            => p_pgm_id
                  ,p_pl_id             => p_pl_id
                  ,p_oipl_id           => p_oipl_id
                  ,p_oiplip_id         => p_oiplip_id
                  ,p_plip_id           => p_plip_id
                  ,p_ptip_id           => p_ptip_id
                  ,p_subtract_date     => l_subtract_date
                  ,p_fonm_cvg_strt_dt  => g_fonm_cvg_strt_dt);

                  --
               IF l_rate_result is not null THEN
                 --
                 ben_derive_part_and_rate_cache.get_los_rate(p_pgm_id=> p_pgm_id
                  ,p_pl_id             => p_pl_id
                  ,p_oipl_id           => p_oipl_id
                  ,p_plip_id           => p_plip_id
                  ,p_ptip_id           => p_ptip_id
                  ,p_oiplip_id         => p_oiplip_id
                  ,p_new_val           => l_rate_result
                  ,p_old_val           => p_comp_rec.rt_los_val
                  ,p_business_group_id => p_business_group_id
                  ,p_effective_date    => NVL(g_fonm_cvg_strt_dt,l_effective_date)
                  ,p_rec               => l_rate_rec);
                 --
                 ben_seeddata_object.get_object(p_rec=> l_der_rec);
                 --
                 min_max_breach
                   (p_calculate_only_mode => p_calculate_only_mode
                   ,p_comp_obj_tree_row   => p_comp_obj_tree_row
                   ,p_curroiplip_row      => p_curroiplip_row
                   ,p_person_id           => p_person_id
                   ,p_pgm_id              => p_pgm_id
                   ,p_pl_id               => p_pl_id
                   ,p_oipl_id             => p_oipl_id
                   ,p_oiplip_id           => p_oiplip_id
                   ,p_plip_id             => p_plip_id
                   ,p_ptip_id             => p_ptip_id
                   ,p_business_group_id   => p_business_group_id
                   ,p_ler_id              => l_der_rec.drvdlos_id
                   ,p_min_value           => l_rate_rec.mn_los_num
                   ,p_max_value           => l_rate_rec.mx_los_num
                   ,p_new_value           => l_rate_result
                   ,p_old_value           => p_comp_rec.rt_los_val
                   ,p_uom                 => l_rate_rec.los_uom
                   ,p_subtract_date       => l_subtract_date
                   ,p_det_cd              => l_rate_rec.los_det_cd
                   ,p_formula_id          => l_rate_rec.los_det_rl
                   ,p_ptnl_ler_trtmt_cd   => p_ptnl_ler_trtmt_cd
                   ,p_effective_date      => p_effective_date
                        );
                END IF ; -- l_rate_result
                --
              END IF; -- l_rate_rec.los_calc_rl
              --
           END IF ; -- l_rate_rec.exist
           --
           -- Try and find a coverage first
           --
           IF    p_oipl_id IS NOT NULL
               OR p_pl_id IS NOT NULL
               OR p_plip_id IS NOT NULL THEN
              --
              ben_derive_part_and_rate_cvg.get_los_rate(p_pl_id=> p_pl_id
               ,p_oipl_id           => p_oipl_id
               ,p_plip_id           => p_plip_id
               ,p_business_group_id => p_business_group_id
               ,p_effective_date    => NVL(g_fonm_cvg_strt_dt,l_effective_date)
               ,p_rec               => l_rate_cvg_rec);
              --
             IF l_rate_cvg_rec.exist = 'Y' THEN
               --
               l_cvg  := TRUE;
               --
               -- los based on los_calc_rl takes precedence
               IF l_rate_cvg_rec.los_calc_rl IS NOT NULL THEN
                 --
                 ben_determine_date.main(p_date_cd=> l_rate_cvg_rec.los_det_cd
                  ,p_formula_id        => l_rate_cvg_rec.los_det_rl
                  ,p_person_id         => p_person_id
                  ,p_pgm_id            => NVL(p_pgm_id
                                      ,p_comp_obj_tree_row.par_pgm_id)
                  ,p_pl_id             => p_pl_id
                  ,p_oipl_id           => NVL(p_oipl_id
                                           ,l_oiplip_rec.oipl_id)
                  ,p_business_group_id => p_business_group_id
                  ,p_returned_date     => l_start_date
                  ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
                  ,p_effective_date    => NVL(p_lf_evt_ocrd_dt ,p_effective_date));
                  --
                  run_rule(p_formula_id => l_rate_cvg_rec.los_calc_rl
                  ,p_empasg_row        => p_empasg_row
                  ,p_benasg_row        => p_benasg_row
                  ,p_pil_row           => p_pil_row
                  ,p_curroipl_row      => p_curroipl_row
                  ,p_curroiplip_row    => p_curroiplip_row
                  ,p_effective_date    => p_effective_date
                  ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
                  ,p_business_group_id => p_business_group_id
                  ,p_person_id         => p_person_id
                  ,p_pgm_id            => p_pgm_id
                  ,p_pl_id             => p_pl_id
                  ,p_oipl_id           => NVL(p_oipl_id
                                      ,l_oiplip_rec.oipl_id)
                  ,p_oiplip_id         => p_oiplip_id
                  ,p_plip_id           => p_plip_id
                  ,p_ptip_id           => p_ptip_id
                  ,p_ret_date          => l_dummy_date
                  ,p_ret_val           => l_rate_cvg_result);
                  --
                  -- Round value if rounding needed
                  --
                 IF    l_rate_cvg_rec.rndg_cd IS NOT NULL
                     OR l_rate_cvg_rec.rndg_rl IS NOT NULL THEN
                    --
                    l_rate_cvg_result  :=
                      benutils.do_rounding(p_rounding_cd=> l_rate_cvg_rec.rndg_cd
                       ,p_rounding_rl    => l_rate_cvg_rec.rndg_rl
                       ,p_value          => l_rate_cvg_result
                       ,p_effective_date => NVL(g_fonm_cvg_strt_dt,
                                              NVL(p_lf_evt_ocrd_dt,p_effective_date)));
                        --
                 END IF;
                 --
               ELSE -- l_rate_rec.los_calc_rl
                 --
                 l_rate_cvg_result  :=
                   los_calculation(p_comp_obj_tree_row=> p_comp_obj_tree_row
                    ,p_empasg_row        => p_empasg_row
                    ,p_benasg_row        => p_benasg_row
                    ,p_pil_row           => p_pil_row
                    ,p_curroipl_row      => p_curroipl_row
                    ,p_curroiplip_row    => p_curroiplip_row
                    ,p_rec               => l_rate_cvg_rec
                    ,p_comp_rec          => p_comp_rec
                    ,p_effective_date    => p_effective_date
                    ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
                    ,p_business_group_id => p_business_group_id
                    ,p_person_id         => p_person_id
                    ,p_pgm_id            => p_pgm_id
                    ,p_pl_id             => p_pl_id
                    ,p_oipl_id           => p_oipl_id
                    ,p_oiplip_id         => p_oiplip_id
                    ,p_plip_id           => p_plip_id
                    ,p_ptip_id           => p_ptip_id
                    ,p_subtract_date     => l_subtract_date
                    ,p_fonm_cvg_strt_dt  => g_fonm_cvg_strt_dt) ;
                 --
                 IF l_rate_cvg_result is not null THEN
                   --
                   -- RCHASE added old and new values
                   ben_derive_part_and_rate_cvg.get_los_rate(p_pl_id=> p_pl_id
                                                ,p_oipl_id           => p_oipl_id
                                                ,p_plip_id           => p_plip_id
                                                ,p_business_group_id => p_business_group_id
                                                ,p_new_val           => l_rate_cvg_result
                                                ,p_old_val           => p_comp_rec.rt_los_val
                                                ,p_effective_date    => NVL(g_fonm_cvg_strt_dt,
                                                                        l_effective_date)
                                                ,p_rec               => l_rate_cvg_rec);
                   --
                   ben_seeddata_object.get_object(p_rec=> l_der_cvg_rec);
                   --
                   -- BUG: 3962514: Corrected the parameter below from l_rate_result to l_rate_cvg_rec
                   min_max_breach
                     (p_calculate_only_mode => p_calculate_only_mode
                     ,p_comp_obj_tree_row   => p_comp_obj_tree_row
                     ,p_curroiplip_row      => p_curroiplip_row
                     ,p_person_id           => p_person_id
                     ,p_pgm_id              => p_pgm_id
                     ,p_pl_id               => p_pl_id
                     ,p_oipl_id             => p_oipl_id
                     ,p_oiplip_id           => p_oiplip_id
                     ,p_plip_id             => p_plip_id
                     ,p_ptip_id             => p_ptip_id
                     ,p_business_group_id   => p_business_group_id
                     ,p_ler_id              => l_der_cvg_rec.drvdlos_id
                     ,p_min_value           => l_rate_cvg_rec.mn_los_num
                     ,p_max_value           => l_rate_cvg_rec.mx_los_num
                     ,p_new_value           => l_rate_cvg_result
                     ,p_old_value           => p_comp_rec.rt_los_val
                     ,p_uom                 => l_rate_cvg_rec.los_uom
                     ,p_subtract_date       => l_subtract_date
                     ,p_det_cd              => l_rate_cvg_rec.los_det_cd
                     ,p_formula_id          => l_rate_cvg_rec.los_det_rl
                     ,p_ptnl_ler_trtmt_cd   => p_ptnl_ler_trtmt_cd
                     ,p_effective_date      => p_effective_date
                     );
                    --
                 END IF ; -- l_rate_cvg_result
                 --
               END IF ; --   l_rate_rec.los_calc_rl
               --
             END IF ; -- l_rate_cvg_rec.exist

             --
             ben_derive_part_and_rate_prem.get_los_rate(
                  p_pl_id             => p_pl_id
                 ,p_oipl_id           => p_oipl_id
                 ,p_business_group_id => p_business_group_id
                 ,p_effective_date    => NVL(g_fonm_cvg_strt_dt,l_effective_date)
                 ,p_rec               => l_rate_prem_rec);
               --
             IF l_rate_prem_rec.exist = 'Y' THEN
               --
               l_prem  := TRUE;
               -- los based on los_calc_rl takes precedence
               IF l_rate_prem_rec.los_calc_rl IS NOT NULL THEN
                 --
                 ben_determine_date.main(p_date_cd=> l_rate_prem_rec.los_det_cd
                  ,p_formula_id        => l_rate_prem_rec.los_det_rl
                  ,p_person_id         => p_person_id
                  ,p_pgm_id            => NVL(p_pgm_id
                                           ,p_comp_obj_tree_row.par_pgm_id)
                  ,p_pl_id             => p_pl_id
                  ,p_oipl_id           => NVL(p_oipl_id
                                           ,l_oiplip_rec.oipl_id)
                  ,p_business_group_id => p_business_group_id
                  ,p_returned_date     => l_start_date
                  ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
                  ,p_effective_date    => NVL(p_lf_evt_ocrd_dt ,p_effective_date));
                 --
                 run_rule(p_formula_id => l_rate_prem_rec.los_calc_rl
                  ,p_empasg_row        => p_empasg_row
                  ,p_benasg_row        => p_benasg_row
                  ,p_pil_row           => p_pil_row
                  ,p_curroipl_row      => p_curroipl_row
                  ,p_curroiplip_row    => p_curroiplip_row
                  ,p_effective_date    => p_effective_date
                  ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
                  ,p_business_group_id => p_business_group_id
                  ,p_person_id         => p_person_id
                  ,p_pgm_id            => p_pgm_id
                  ,p_pl_id             => p_pl_id
                  ,p_oipl_id           => NVL(p_oipl_id
                                      ,l_oiplip_rec.oipl_id)
                  ,p_oiplip_id         => p_oiplip_id
                  ,p_plip_id           => p_plip_id
                  ,p_ptip_id           => p_ptip_id
                  ,p_ret_date          => l_dummy_date
                  ,p_ret_val           => l_rate_prem_result);
                 --
                 -- Round value if rounding needed
                 --
                 IF    l_rate_prem_rec.rndg_cd IS NOT NULL
                 OR l_rate_prem_rec.rndg_rl IS NOT NULL THEN
                   --
                   l_rate_prem_result  :=
                     benutils.do_rounding(p_rounding_cd=> l_rate_prem_rec.rndg_cd
                      ,p_rounding_rl    => l_rate_prem_rec.rndg_rl
                      ,p_value          => l_rate_prem_result
                      ,p_effective_date => NVL(g_fonm_cvg_strt_dt,NVL(p_lf_evt_ocrd_dt
                                            ,p_effective_date)));
                   --
                 END IF;
                 --
               ELSE -- l_rate_prem_rec.los_calc_rl
                 --
                 l_rate_prem_result  :=
                    los_calculation(p_comp_obj_tree_row=> p_comp_obj_tree_row
                   ,p_empasg_row        => p_empasg_row
                   ,p_benasg_row        => p_benasg_row
                   ,p_pil_row           => p_pil_row
                   ,p_curroipl_row      => p_curroipl_row
                   ,p_curroiplip_row    => p_curroiplip_row
                   ,p_rec               => l_rate_prem_rec
                   ,p_comp_rec          => p_comp_rec
                   ,p_effective_date    => p_effective_date
                   ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
                   ,p_business_group_id => p_business_group_id
                   ,p_person_id         => p_person_id
                   ,p_pgm_id            => p_pgm_id
                   ,p_pl_id             => p_pl_id
                   ,p_oipl_id           => p_oipl_id
                   ,p_oiplip_id         => p_oiplip_id
                   ,p_plip_id           => p_plip_id
                   ,p_ptip_id           => p_ptip_id
                   ,p_subtract_date     => l_subtract_date
                   ,p_fonm_cvg_strt_dt  => g_fonm_cvg_strt_dt);
                 --
                 IF l_rate_prem_result is not null THEN
                   --
                   ben_derive_part_and_rate_prem.get_los_rate(p_pl_id=> p_pl_id
                     ,p_oipl_id           => p_oipl_id
                     ,p_business_group_id => p_business_group_id
                     ,p_new_val           => l_rate_prem_result
                     ,p_old_val           => p_comp_rec.rt_los_val
                     ,p_effective_date    => NVL(g_fonm_cvg_strt_dt,l_effective_date)
                     ,p_rec               => l_rate_prem_rec);
                   --
                   ben_seeddata_object.get_object(p_rec=> l_der_prem_rec);
                   --
                   min_max_breach
                     (p_calculate_only_mode => p_calculate_only_mode
                     ,p_comp_obj_tree_row   => p_comp_obj_tree_row
                     ,p_curroiplip_row      => p_curroiplip_row
                     ,p_person_id           => p_person_id
                     ,p_pgm_id              => p_pgm_id
                     ,p_pl_id               => p_pl_id
                     ,p_oipl_id             => p_oipl_id
                     ,p_oiplip_id           => p_oiplip_id
                     ,p_plip_id             => p_plip_id
                     ,p_ptip_id             => p_ptip_id
                     ,p_business_group_id   => p_business_group_id
                     ,p_ler_id              => l_der_prem_rec.drvdlos_id
                     ,p_min_value           => l_rate_prem_rec.mn_los_num
                     ,p_max_value           => l_rate_prem_rec.mx_los_num
                     ,p_new_value           => l_rate_prem_result
                     ,p_old_value           => p_comp_rec.rt_los_val
                     ,p_uom                 => l_rate_prem_rec.los_uom
                     ,p_subtract_date       => l_subtract_date
                     ,p_det_cd              => l_rate_prem_rec.los_det_cd
                     ,p_formula_id          => l_rate_prem_rec.los_det_rl
                     ,p_ptnl_ler_trtmt_cd   => p_ptnl_ler_trtmt_cd
                     ,p_effective_date      => p_effective_date
                     );
                   --
                 END IF; -- l_rate_prem_result
                 --
               END IF; -- l_rate_prem_rec.los_calc_rl
               --
             END IF; -- l_rate_prem_rec.exist
             --
           END IF; -- p_oipl_id
           --
           IF l_rate_result IS NULL and l_rate_cvg_result IS NULL and  l_rate_prem_result IS NULL THEN
             --
             p_comp_rec.rt_los_val  := NULL;
             p_comp_rec.rt_los_uom  := NULL;
             --
           ELSIF l_rate_result is NOT NULL THEN
             --hr_utility.set_location(' Step 28',10);
             p_comp_rec.rt_los_val  := l_rate_result;
             p_comp_rec.rt_los_uom  := l_rate_rec.los_uom;
             --
           ELSIF l_rate_cvg_result is NOT NULL then
             --
             p_comp_rec.rt_los_val  := l_rate_cvg_result;
             p_comp_rec.rt_los_uom  := l_rate_cvg_rec.los_uom;
             --hr_utility.set_location(' Step 29',10);
           ELSIF l_rate_prem_result is NOT NULL THEN
             --
             p_comp_rec.rt_los_val  := l_rate_prem_result;
             p_comp_rec.rt_los_uom  := l_rate_prem_rec.los_uom;
             --hr_utility.set_location(' Step 30',10);
           END IF;
           --
           --hr_utility.set_location(' Step 31',10);
         END IF;  -- p_age_fctr_id
--
      --
      END IF;
    --
    END IF;
    --
   -- hr_utility.set_location('Leaving ' || l_package,10);
  --
  END calculate_los;
--
-- Calculate AGE
--
  PROCEDURE calculate_age
    (p_calculate_only_mode in     boolean default false
    ,p_comp_obj_tree_row   IN     ben_manage_life_events.g_cache_proc_objects_rec
    ,p_per_row             IN     per_all_people_f%ROWTYPE
    ,p_empasg_row          IN     per_all_assignments_f%ROWTYPE
    ,p_benasg_row          IN     per_all_assignments_f%ROWTYPE
    ,p_pil_row             IN     ben_per_in_ler%ROWTYPE
    ,p_curroipl_row        IN     ben_cobj_cache.g_oipl_inst_row
    ,p_curroiplip_row      IN     ben_cobj_cache.g_oiplip_inst_row
    ,p_person_id           IN     NUMBER
    ,p_business_group_id   IN     NUMBER
    ,p_pgm_id              IN     NUMBER
    ,p_pl_id               IN     NUMBER
    ,p_oipl_id             IN     NUMBER
    ,p_plip_id             IN     NUMBER
    ,p_ptip_id             IN     NUMBER
    ,p_oiplip_id           IN     NUMBER
    ,p_ptnl_ler_trtmt_cd   IN     VARCHAR2
    ,p_age_fctr_id         IN     NUMBER DEFAULT NULL
    ,p_comp_rec            IN OUT NOCOPY g_cache_structure
    ,p_effective_date      IN     DATE
    ,p_lf_evt_ocrd_dt      IN     DATE
    )
  IS
    --
    l_package       VARCHAR2(80)              := g_package || '.calculate_age';
    l_rate_result   NUMBER;
    l_rate_cvg_result NUMBER;
    l_rate_prem_result NUMBER;
    l_elig_result   NUMBER;
    l_subtract_date DATE;
    l_elig_rec      ben_derive_part_and_rate_cache.g_cache_age_rec_obj;
    l_rate_rec      ben_derive_part_and_rate_cache.g_cache_age_rec_obj;
    l_rate_cvg_rec  ben_derive_part_and_rate_cache.g_cache_age_rec_obj;
    l_rate_prem_rec ben_derive_part_and_rate_cache.g_cache_age_rec_obj;
    l_der_rec       ben_seeddata_object.g_derived_factor_info_rec;
    l_der_cvg_rec   ben_seeddata_object.g_derived_factor_info_rec;
    l_der_prem_rec  ben_seeddata_object.g_derived_factor_info_rec;
    l_rate          BOOLEAN                                          := FALSE;
    l_cvg           BOOLEAN                                          := FALSE;
    l_prem          BOOLEAN                                          := FALSE;
    l_age_val       number;
  --
  BEGIN
    --
    if g_debug then
      hr_utility.set_location('Entering ' || l_package,10);
    end if;
    if g_debug then
      hr_utility.set_location('Start p_oipl_id '||p_oipl_id,15);
    end if;
    if g_debug then
      hr_utility.set_location('Start p_plip_id'||p_plip_id,15);
    end if;
    if g_debug then
      hr_utility.set_location('Start p_ptip_id'||p_ptip_id,15);
    end if;
    if g_debug then
      hr_utility.set_location('Start p_oiplip_id'||p_oiplip_id,15);
    end if;
    if g_debug then
      hr_utility.set_location('Start p_pl_id '||p_pl_id,15);
    end if;
    if g_debug then
      hr_utility.set_location('Start p_pgm_id '||p_pgm_id,15);
    end if;
    if g_debug then
      hr_utility.set_location('p_age_fctr_id '||p_age_fctr_id,15);
    end if;

--
-- Calculate AGE process
-- =====================
-- This process will calculate the AGE value for rates and eligibility.
-- The sequence of operations is as follows :
-- 1) First check if freeze AGE flag is on in which case
--    we ignore the calculation and just return the frozen values
-- 2) Check for eligibility derivable factors
-- 3) Check for rate derivable factors
-- 4) Perform rounding
-- 5) Test for min/max breach
-- 6) If a breach did occur then create a ptl_ler_for_per.
--
    IF    bitand(p_comp_obj_tree_row.flag_bit_val
           ,ben_manage_life_events.g_age_flag) <> 0
       OR     p_age_fctr_id IS NOT NULL
          AND bitand(p_comp_obj_tree_row.flag_bit_val
               ,ben_manage_life_events.g_cal_flag) <> 0 THEN
      --
      --hr_utility.set_location('AGE for ELIG',10);
      IF p_comp_rec.frz_age_flag = 'Y' THEN
        --
        -- No calulation required just return the frozen value
        --
        NULL;
      --
      ELSE
        --
        -- OK we have to calculate the AGE value
        -- so go and grab the values from the ben_age_fctr table
        --
        IF p_age_fctr_id IS NOT NULL THEN
          --
          ben_derive_part_and_rate_cache.get_age_stated(p_age_fctr_id=> p_age_fctr_id
           ,p_business_group_id => p_business_group_id
           ,p_rec               => l_elig_rec);
        --
        ELSE
          --
          ben_derive_part_and_rate_cache.get_age_elig(p_pgm_id=> p_pgm_id
           ,p_pl_id             => p_pl_id
           ,p_oipl_id           => p_oipl_id
           ,p_plip_id           => p_plip_id
           ,p_ptip_id           => p_ptip_id
           ,p_business_group_id => p_business_group_id
           ,p_effective_date    => nvl(g_fonm_cvg_strt_dt,NVL(p_lf_evt_ocrd_dt
                                    ,p_effective_date))
           ,p_rec               => l_elig_rec);
        --
        END IF;
        --
        --hr_utility.set_location('EREX=Y ' || l_package,10);
        IF l_elig_rec.exist = 'Y' THEN
          --
          l_elig_result  :=
            age_calculation(p_comp_obj_tree_row=> p_comp_obj_tree_row
             ,p_per_row           => p_per_row
             ,p_empasg_row        => p_empasg_row
             ,p_benasg_row        => p_benasg_row
             ,p_pil_row           => p_pil_row
             ,p_curroipl_row      => p_curroipl_row
             ,p_curroiplip_row    => p_curroiplip_row
             ,p_rec               => l_elig_rec
             ,p_effective_date    => p_effective_date
             ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
             ,p_business_group_id => p_business_group_id
             ,p_pgm_id            => p_pgm_id
             ,p_person_id         => p_person_id
             ,p_pl_id             => p_pl_id
             ,p_oipl_id           => p_oipl_id
             ,p_oiplip_id         => p_oiplip_id
             ,p_plip_id           => p_plip_id
             ,p_ptip_id           => p_ptip_id
             ,p_subtract_date     => l_subtract_date
             ,p_fonm_cvg_strt_dt  => g_fonm_cvg_strt_dt);
          --
          IF     l_elig_result IS NOT NULL
             AND p_age_fctr_id IS NULL THEN
            --
            l_age_val         := p_comp_rec.age_val;
            Loop
              g_lf_evt_exists   := false;
              ben_derive_part_and_rate_cache.get_age_elig(p_pgm_id=> p_pgm_id
               ,p_pl_id             => p_pl_id
               ,p_oipl_id           => p_oipl_id
               ,p_plip_id           => p_plip_id
               ,p_ptip_id           => p_ptip_id
               ,p_new_val           => l_elig_result
               ,p_old_val           => l_age_val
               ,p_business_group_id => p_business_group_id
               ,p_effective_date    => nvl(g_fonm_cvg_strt_dt,NVL(p_lf_evt_ocrd_dt
                                        ,p_effective_date))
               ,p_rec               => l_elig_rec);
        --

            ben_seeddata_object.get_object(p_rec=> l_der_rec);
            --
    --          IF    l_elig_rec.age_to_use_cd = 'P'
    --             OR l_elig_rec.age_calc_rl IS NOT NULL THEN
              --
                min_max_breach
                  (p_calculate_only_mode => p_calculate_only_mode
                  ,p_comp_obj_tree_row   => p_comp_obj_tree_row
                  ,p_curroiplip_row      => p_curroiplip_row
                  ,p_person_id           => p_person_id
                  ,p_pgm_id              => p_pgm_id
                  ,p_pl_id               => p_pl_id
                  ,p_oipl_id             => p_oipl_id
                  ,p_oiplip_id           => p_oiplip_id
                  ,p_plip_id             => p_plip_id
                  ,p_ptip_id             => p_ptip_id
                  ,p_business_group_id   => p_business_group_id
                  ,p_ler_id              => l_der_rec.drvdage_id
                  ,p_min_value           => l_elig_rec.mn_age_num
                  ,p_max_value           => l_elig_rec.mx_age_num
                  ,p_new_value           => l_elig_result
                  ,p_old_value           => l_age_val
                  ,p_uom                 => l_elig_rec.age_uom
                  ,p_subtract_date       => l_subtract_date
                  ,p_det_cd              => l_elig_rec.age_det_cd
                  ,p_formula_id          => l_elig_rec.age_det_rl
                  ,p_ptnl_ler_trtmt_cd   => p_ptnl_ler_trtmt_cd
                  ,p_effective_date      => p_effective_date
                  );
              --
   --           END IF;
            --
              if not g_lf_evt_exists or l_age_val = l_elig_rec.mn_age_num or
                    l_elig_rec.mn_age_num is null then
                   exit;
              else
                   l_age_val := l_elig_rec.mn_age_num;
              end if;
            End Loop;
            g_lf_evt_exists := false;

            p_comp_rec.age_val  := l_elig_result;
            p_comp_rec.age_uom  := l_elig_rec.age_uom;
          --
          ELSIF l_elig_result IS NULL THEN
            --
            -- Bug 4708
            --
            p_comp_rec.age_val  := NULL;
            p_comp_rec.age_uom  := NULL;
          --
          ELSE
            --
            p_comp_rec.age_val  := l_elig_result;
            p_comp_rec.age_uom  := l_elig_rec.age_uom;
          --
          END IF;
        --
        ELSE
          --
          p_comp_rec.age_val  := NULL;
          p_comp_rec.age_uom  := NULL;
        --
        END IF;
      --
      END IF;
    --
    END IF;
    --
    hr_utility.set_location('Plip_id '||p_plip_id,9);
    hr_utility.set_location('age_val ' || p_comp_rec.age_val,10);
    --
    --
    IF    bitand(p_comp_obj_tree_row.flag_bit_val
           ,ben_manage_life_events.g_age_rt_flag) <> 0
       OR     p_age_fctr_id IS NOT NULL
          AND bitand(p_comp_obj_tree_row.flag_bit_val
               ,ben_manage_life_events.g_cal_rt_flag) <> 0
       OR     p_oiplip_id IS NOT NULL
          AND bitand(p_comp_obj_tree_row.oiplip_flag_bit_val
               ,ben_manage_life_events.g_age_rt_flag) <> 0 THEN
      --
      --hr_utility.set_location('AGE for RT',10);
      IF p_comp_rec.rt_frz_age_flag = 'Y' THEN
        --
        -- No calulation required just return the frozen value
         --hr_utility.set_location(' rt_frz_age_flag '||p_comp_rec.rt_frz_age_flag ,22);
        --
        NULL;
      --
      ELSE
        --
        IF p_age_fctr_id IS NOT NULL THEN
          --
          --hr_utility.set_location(' p_age_fctr_id '||p_age_fctr_id,23);
          ben_derive_part_and_rate_cache.get_age_stated(p_age_fctr_id=> p_age_fctr_id
           ,p_business_group_id => p_business_group_id
           ,p_rec               => l_rate_rec);
        --
        ELSE
          --
          if g_debug then
            hr_utility.set_location('Getting Age for Rate',10);
          end if;
          --
          ben_derive_part_and_rate_cache.get_age_rate(p_pgm_id=> p_pgm_id
           ,p_pl_id             => p_pl_id
           ,p_oipl_id           => p_oipl_id
           ,p_plip_id           => p_plip_id
           ,p_ptip_id           => p_ptip_id
           ,p_oiplip_id         => p_oiplip_id
           ,p_business_group_id => p_business_group_id
           ,p_effective_date    => nvl(g_fonm_cvg_strt_dt,NVL(p_lf_evt_ocrd_dt
                                    ,p_effective_date))
           ,p_rec               => l_rate_rec);
          --
           --hr_utility.set_location(' Rate l_rate_rec.exist '||l_rate_rec.exist,33);
          IF l_rate_rec.exist = 'Y' THEN
            --
            --hr_utility.set_location(' l_rate_rec.exist true ' , 34);
            l_rate  := TRUE;

            l_rate_result  :=
            age_calculation(p_comp_obj_tree_row=> p_comp_obj_tree_row
             ,p_per_row           => p_per_row
             ,p_empasg_row        => p_empasg_row
             ,p_benasg_row        => p_benasg_row
             ,p_pil_row           => p_pil_row
             ,p_curroipl_row      => p_curroipl_row
             ,p_curroiplip_row    => p_curroiplip_row
             ,p_rec               => l_rate_rec
             ,p_effective_date    => p_effective_date
             ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
             ,p_business_group_id => p_business_group_id
             ,p_person_id         => p_person_id
             ,p_pgm_id            => p_pgm_id
             ,p_pl_id             => p_pl_id
             ,p_oipl_id           => p_oipl_id
             ,p_oiplip_id         => p_oiplip_id
             ,p_plip_id           => p_plip_id
             ,p_ptip_id           => p_ptip_id
             ,p_subtract_date     => l_subtract_date
             ,p_fonm_cvg_strt_dt  => g_fonm_cvg_strt_dt);

             --hr_utility.set_location(' Step 10 ',10);
             --
             IF l_rate_result is not null THEN
               --
               --hr_utility.set_location(' Step 11',10 );
               ben_derive_part_and_rate_cache.get_age_rate(
                  p_pgm_id            => p_pgm_id
                 ,p_pl_id             => p_pl_id
                 ,p_oipl_id           => p_oipl_id
                 ,p_plip_id           => p_plip_id
                 ,p_ptip_id           => p_ptip_id
                 ,p_oiplip_id         => p_oiplip_id
                 ,p_new_val           => l_rate_result
                 ,p_old_val           => p_comp_rec.rt_age_val
                 ,p_business_group_id => p_business_group_id
                 ,p_effective_date    => nvl(g_fonm_cvg_strt_dt,NVL(p_lf_evt_ocrd_dt
                                        ,p_effective_date))
                 ,p_rec               => l_rate_rec);
               --
           --    IF    l_rate_rec.age_to_use_cd = 'P'
           --       OR l_elig_rec.age_calc_rl IS NOT NULL THEN
                 --
                 ben_seeddata_object.get_object(p_rec=> l_der_rec);
                 --
                 --hr_utility.set_location(' Step 12 ',10 );
                 min_max_breach
                   (p_calculate_only_mode => p_calculate_only_mode
                   ,p_comp_obj_tree_row   => p_comp_obj_tree_row
                   ,p_curroiplip_row      => p_curroiplip_row
                   ,p_person_id           => p_person_id
                   ,p_pgm_id              => p_pgm_id
                   ,p_pl_id               => p_pl_id
                   ,p_oipl_id             => p_oipl_id
                   ,p_oiplip_id           => p_oiplip_id
                   ,p_plip_id             => p_plip_id
                   ,p_ptip_id             => p_ptip_id
                   ,p_business_group_id   => p_business_group_id
                   ,p_ler_id              => l_der_rec.drvdage_id
                   ,p_min_value           => l_rate_rec.mn_age_num
                   ,p_max_value           => l_rate_rec.mx_age_num
                   ,p_new_value           => l_rate_result
                   ,p_old_value           => p_comp_rec.rt_age_val
                   ,p_uom                 => l_rate_rec.age_uom
                   ,p_subtract_date       => l_subtract_date
                   ,p_det_cd              => l_rate_rec.age_det_cd
                   ,p_formula_id          => l_rate_rec.age_det_rl
                   ,p_ptnl_ler_trtmt_cd   => p_ptnl_ler_trtmt_cd
                   ,p_effective_date      => p_effective_date
                   );
                 --
            --   END IF;  -- Breach
               --
               --p_comp_rec.rt_age_val  := l_rate_result;
               --p_comp_rec.rt_age_uom  := l_rate_rec.age_uom;
               --hr_utility.set_location(' Step 13 ',10);
               --
             END IF; -- l_rate_result
             --hr_utility.set_location(' Step 14 ',10 );
            --
          END IF ;  --l_rate_rec.exist
          --
          --hr_utility.set_location(' Step 15 ',10 );
          -- Try and find a coverage first
          --
          IF    p_oipl_id IS NOT NULL
            OR p_pl_id IS NOT NULL
            OR p_plip_id IS NOT NULL THEN
              --
              --hr_utility.set_location('Getting Age for CVG',10);
              --
              ben_derive_part_and_rate_cvg.get_age_rate(
                p_pl_id             => p_pl_id
               ,p_oipl_id           => p_oipl_id
               ,p_plip_id           => p_plip_id
               ,p_business_group_id => p_business_group_id
               ,p_effective_date    => nvl(g_fonm_cvg_strt_dt,NVL(p_lf_evt_ocrd_dt
                                        ,p_effective_date))
               ,p_rec               => l_rate_cvg_rec);
              --
            IF l_rate_cvg_rec.exist = 'Y' THEN
              --
              --hr_utility.set_location(' Step 16 ',10 );
              l_cvg  := TRUE;
              l_rate_cvg_result  :=
            	age_calculation(p_comp_obj_tree_row=> p_comp_obj_tree_row
                ,p_per_row           => p_per_row
             	,p_empasg_row        => p_empasg_row
                ,p_benasg_row        => p_benasg_row
                ,p_pil_row           => p_pil_row
                ,p_curroipl_row      => p_curroipl_row
                ,p_curroiplip_row    => p_curroiplip_row
                ,p_rec               => l_rate_cvg_rec
                ,p_effective_date    => p_effective_date
                ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
                ,p_business_group_id => p_business_group_id
                ,p_person_id         => p_person_id
                ,p_pgm_id            => p_pgm_id
                ,p_pl_id             => p_pl_id
                ,p_oipl_id           => p_oipl_id
                ,p_oiplip_id         => p_oiplip_id
                ,p_plip_id           => p_plip_id
                ,p_ptip_id           => p_ptip_id
                ,p_subtract_date     => l_subtract_date
                ,p_fonm_cvg_strt_dt  => g_fonm_cvg_strt_dt );

              --
              IF l_rate_cvg_result is not null THEN
                --
                --hr_utility.set_location(' Step 17' ,10);
                ben_derive_part_and_rate_cvg.get_age_rate(
                  p_pl_id             => p_pl_id
                 ,p_oipl_id           => p_oipl_id
                 ,p_plip_id           => p_plip_id
                 ,p_business_group_id => p_business_group_id
                 ,p_new_val           => l_rate_cvg_result
                 ,p_old_val           => p_comp_rec.rt_age_val
                 ,p_effective_date    => nvl(g_fonm_cvg_strt_dt,
                                            NVL(p_lf_evt_ocrd_dt ,p_effective_date))
                 ,p_rec               => l_rate_cvg_rec );
                --
        --        IF    l_rate_cvg_rec.age_to_use_cd = 'P'
        --            OR l_elig_rec.age_calc_rl IS NOT NULL THEN
                  --
                  ben_seeddata_object.get_object(p_rec=> l_der_cvg_rec);
                  --
                  --hr_utility.set_location(' Step 18' , 10);
                  min_max_breach
                     (p_calculate_only_mode => p_calculate_only_mode
                     ,p_comp_obj_tree_row   => p_comp_obj_tree_row
                     ,p_curroiplip_row      => p_curroiplip_row
                     ,p_person_id           => p_person_id
                     ,p_pgm_id              => p_pgm_id
                     ,p_pl_id               => p_pl_id
                     ,p_oipl_id             => p_oipl_id
                     ,p_oiplip_id           => p_oiplip_id
                     ,p_plip_id             => p_plip_id
                     ,p_ptip_id             => p_ptip_id
                     ,p_business_group_id   => p_business_group_id
                     ,p_ler_id              => l_der_cvg_rec.drvdage_id
                     ,p_min_value           => l_rate_cvg_rec.mn_age_num
                     ,p_max_value           => l_rate_cvg_rec.mx_age_num
                     ,p_new_value           => l_rate_cvg_result
                     ,p_old_value           => p_comp_rec.rt_age_val
                     ,p_uom                 => l_rate_cvg_rec.age_uom
                     ,p_subtract_date       => l_subtract_date
                     ,p_det_cd              => l_rate_cvg_rec.age_det_cd
                     ,p_formula_id          => l_rate_cvg_rec.age_det_rl
                     ,p_ptnl_ler_trtmt_cd   => p_ptnl_ler_trtmt_cd
                     ,p_effective_date      => p_effective_date
                     );
                 --
         --      END IF;  -- Breach
               --
               -- p_comp_rec.rt_age_val  := l_rate_cvg_result;
               -- p_comp_rec.rt_age_uom  := l_rate_cvg_rec.age_uom;
               --hr_utility.set_location(' Step 19',10);

              END IF ; -- l_rate_cvg_result
              --
              --hr_utility.set_location(' Step 20',10);
            END IF; --l_rate_cvg_rec.exist
            --
            -- Try and find a premium
            --
            --hr_utility.set_location('Getting Age for Prem',10);
            ben_derive_part_and_rate_prem.get_age_rate(
                  p_pl_id             => p_pl_id
                 ,p_oipl_id           => p_oipl_id
                 ,p_business_group_id => p_business_group_id
                 ,p_effective_date    => nvl(g_fonm_cvg_strt_dt,NVL(p_lf_evt_ocrd_dt
                                          ,p_effective_date))
                 ,p_rec               => l_rate_prem_rec);
                --
              IF l_rate_prem_rec.exist = 'Y' THEN
                --
                l_prem  := TRUE;
                --
                --hr_utility.set_location(' Step 21',10);
                l_rate_prem_result  :=
                  age_calculation(p_comp_obj_tree_row=> p_comp_obj_tree_row
                   ,p_per_row           => p_per_row
                   ,p_empasg_row        => p_empasg_row
                   ,p_benasg_row        => p_benasg_row
                   ,p_pil_row           => p_pil_row
                   ,p_curroipl_row      => p_curroipl_row
                   ,p_curroiplip_row    => p_curroiplip_row
                   ,p_rec               => l_rate_prem_rec
                   ,p_effective_date    => p_effective_date
                   ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
                   ,p_business_group_id => p_business_group_id
                   ,p_person_id         => p_person_id
                   ,p_pgm_id            => p_pgm_id
                   ,p_pl_id             => p_pl_id
                   ,p_oipl_id           => p_oipl_id
                   ,p_oiplip_id         => p_oiplip_id
                   ,p_plip_id           => p_plip_id
                   ,p_ptip_id           => p_ptip_id
                   ,p_subtract_date     => l_subtract_date
                   ,p_fonm_cvg_strt_dt  => g_fonm_cvg_strt_dt);
                 --
                 --hr_utility.set_location('  l_rate_prem_result '||l_rate_prem_result ,123);
                 --
                 IF l_rate_prem_result is not null THEN
                 --
                   --hr_utility.set_location(' in l_prem ' ,133);
                   ben_derive_part_and_rate_prem.get_age_rate(
                     p_pl_id             => p_pl_id
                    ,p_oipl_id           => p_oipl_id
                    ,p_business_group_id => p_business_group_id
                    ,p_new_val           => l_rate_prem_result
                    ,p_old_val           => p_comp_rec.rt_age_val
                    ,p_effective_date    => nvl(g_fonm_cvg_strt_dt,
                                              NVL(p_lf_evt_ocrd_dt ,p_effective_date))
                    ,p_rec               => l_rate_prem_rec);
                 --
         --          IF    l_rate_prem_rec.age_to_use_cd = 'P'
         --            OR l_elig_rec.age_calc_rl IS NOT NULL THEN
                     --
                     ben_seeddata_object.get_object(p_rec=> l_der_prem_rec);
                     --
                     --hr_utility.set_location(' Step 22',10);
                     min_max_breach
                         (p_calculate_only_mode => p_calculate_only_mode
                         ,p_comp_obj_tree_row   => p_comp_obj_tree_row
                         ,p_curroiplip_row      => p_curroiplip_row
                         ,p_person_id           => p_person_id
                         ,p_pgm_id              => p_pgm_id
                         ,p_pl_id               => p_pl_id
                         ,p_oipl_id             => p_oipl_id
                         ,p_oiplip_id           => p_oiplip_id
                         ,p_plip_id             => p_plip_id
                         ,p_ptip_id             => p_ptip_id
                         ,p_business_group_id   => p_business_group_id
                         ,p_ler_id              => l_der_prem_rec.drvdage_id
                         ,p_min_value           => l_rate_prem_rec.mn_age_num
                         ,p_max_value           => l_rate_prem_rec.mx_age_num
                         ,p_new_value           => l_rate_prem_result
                         ,p_old_value           => p_comp_rec.rt_age_val
                         ,p_uom                 => l_rate_prem_rec.age_uom
                         ,p_subtract_date       => l_subtract_date
                         ,p_det_cd              => l_rate_prem_rec.age_det_cd
                         ,p_formula_id          => l_rate_prem_rec.age_det_rl
                         ,p_ptnl_ler_trtmt_cd   => p_ptnl_ler_trtmt_cd
                         ,p_effective_date      => p_effective_date
                         );
                      --
          --          END IF;  -- Breach
                    --
                    --p_comp_rec.rt_age_val  := l_rate_prem_result;
                    --p_comp_rec.rt_age_uom  := l_rate_prem_rec.age_uom;
                    --hr_utility.set_location(' Step 23',10);
                    --
                 END IF; -- l_rate_prem_result
                 --
                 --hr_utility.set_location(' Step 24',10);
              END IF; -- l_rate_prem_rec.exist
              --
              --hr_utility.set_location(' Step 25',10);
          END IF;  -- p_oipl_id
          --
          --hr_utility.set_location(' Step 26',10);
          IF l_rate_result IS NULL and l_rate_cvg_result IS NULL and  l_rate_prem_result IS NULL THEN
            --
            p_comp_rec.rt_age_val  := NULL;
            p_comp_rec.rt_age_uom  := NULL;
            --hr_utility.set_location(' Step 27',10);
            --
          --
          ELSIF l_rate_result is NOT NULL THEN
            --
            --hr_utility.set_location(' Step 28',10);
            p_comp_rec.rt_age_val := l_rate_result;
            p_comp_rec.rt_age_uom  := l_rate_rec.age_uom;
            --
          --
          ELSIF l_rate_cvg_result is NOT NULL then
            --
            --hr_utility.set_location(' Step 29',10);
            p_comp_rec.rt_age_val := l_rate_cvg_result;
            p_comp_rec.rt_age_uom  := l_rate_cvg_rec.age_uom;
          --
          ELSIF l_rate_prem_result is NOT NULL THEN
            --
            --hr_utility.set_location(' Step 30',10);
            p_comp_rec.rt_age_val := l_rate_prem_result;
            p_comp_rec.rt_age_uom := l_rate_prem_rec.age_uom;
            --
          END IF;
          --
          --hr_utility.set_location(' Step 31',10);
        END IF;  -- p_age_fctr_id
        --
        --
        --hr_utility.set_location('Dn AF NN ' ||l_rate_rec.exist,123);
      --
      END IF;  -- p_comp_rec.rt_frz_age_flag
    --
    END IF;  -- STANDARD.bitand
    --
   if g_debug then
     hr_utility.set_location('Leaving ' || l_package,10);
   end if;
  --
  END calculate_age;
--
  --
  PROCEDURE comp_level_min_max
    (p_calculate_only_mode in     boolean default false
    ,p_comp_obj_tree_row   IN     ben_manage_life_events.g_cache_proc_objects_rec
    ,p_curroiplip_row      IN     ben_cobj_cache.g_oiplip_inst_row
    ,p_rec                 IN     ben_derive_part_and_rate_cache.g_cache_clf_rec_obj
   -- ,p_rate_rec          IN OUT ben_derive_part_and_rate_cache.g_cache_clf_rec_obj
   -- ,p_comp_rec          IN OUT NOCOPY g_cache_structure
    ,p_empasg_row          IN     per_all_assignments_f%ROWTYPE
    ,p_benasg_row          IN     per_all_assignments_f%ROWTYPE
    ,p_person_id           IN     NUMBER
    ,p_pgm_id              IN     NUMBER
    ,p_pl_id               IN     NUMBER
    ,p_oipl_id             IN     NUMBER
    ,p_oiplip_id           IN     NUMBER
    ,p_plip_id             IN     NUMBER
    ,p_ptip_id             IN     NUMBER
    ,p_business_group_id   IN     NUMBER
    ,p_ler_id              IN     NUMBER
    ,p_min_value           IN     NUMBER
    ,p_max_value           IN     NUMBER
    ,p_new_value           IN     NUMBER
    ,p_old_value           IN     NUMBER
    ,p_uom                 IN     VARCHAR2
    ,p_subtract_date       IN     DATE
    ,p_det_cd              IN     VARCHAR2
    ,p_formula_id          IN     NUMBER DEFAULT NULL
    ,p_ptnl_ler_trtmt_cd   IN     VARCHAR2
    ,p_effective_date      IN     DATE
    ,p_lf_evt_ocrd_dt      IN     DATE
    ,p_comp_src_cd         IN     VARCHAR2
    ,p_bnfts_bal_id        IN     NUMBER
    )
  IS
    --
    l_package            VARCHAR2(80)        := g_package || '.comp_level_min_max';
    l_break              VARCHAR2(30);
    l_det_cd             VARCHAR2(30);
    l_lf_evt_ocrd_dt     DATE;
    l_new_lf_evt_ocrd_dt DATE;
    l_start_date         DATE;
    l_rec                ben_person_object.g_person_date_info_rec;
    l_oiplip_rec         ben_cobj_cache.g_oiplip_inst_row;
    --
  BEGIN
      if g_debug then
        hr_utility.set_location('Entering comp_level_min_max ', 10 );
      end if;
      /* Bug 5478918 */
        if (skip_min_max_le_calc(p_ler_id,
	                         p_business_group_id,
                                 p_ptnl_ler_trtmt_cd,
                                 p_effective_date)) THEN
        --
        /* Simply return as no further calculations need to be done */
          hr_utility.set_location(l_package||' Do Nothing here.', 9877);
          RETURN;
        end if;
      /* End Bug 5478918 */
      if g_debug then
        hr_utility.set_location('p_max_value '||p_max_value,10);
      end if;
      if g_debug then
        hr_utility.set_location('p_min_value '||p_min_value,10);
      end if;
      if g_debug then
        hr_utility.set_location('p_new_value '||p_new_value,10);
      end if;
      if g_debug then
        hr_utility.set_location('p_old_value '||p_old_value,10);
      end if;
            --
            IF benutils.min_max_breach(p_min_value=> NVL(p_min_value
                                                      ,-1)
                ,p_max_value => NVL(p_max_value
                                 ,99999999)
                ,p_new_value => p_new_value
                ,p_old_value => p_old_value
                ,p_break     => l_break) THEN
              --
              -- Derive life event occured date based on the value of l_break
              --
              if g_debug then
                hr_utility.set_location(' l_break '||l_break , 10);
              end if;
              --
              IF p_comp_src_cd = 'STTDCOMP' THEN
                --
                l_lf_evt_ocrd_dt  :=
                  get_salary_date(p_empasg_row=> p_empasg_row
                   ,p_benasg_row     => p_benasg_row
                   ,p_rec            => p_rec
                   ,p_person_id      => p_person_id
                   ,p_effective_date => NVL(g_fonm_cvg_strt_dt,NVL(p_lf_evt_ocrd_dt ,p_effective_date))
                   ,p_min            => p_min_value
                   ,p_max            => p_max_value
                   ,p_break          => l_break);
                --
                if g_debug then
                  hr_utility.set_location(' l_lf_evt_ocrd_dt '||l_lf_evt_ocrd_dt , 20);
                end if;
                --
                /* BUG: 4380180. IF l_lf_evt_ocrd_dt IS NULL, avoid determining the date */
                IF (p_det_cd <> 'AED' AND l_lf_evt_ocrd_dt IS NOT NULL) THEN
                  --

                  ben_determine_date.main(p_date_cd=> p_det_cd
                   ,p_formula_id        => p_formula_id
                   ,p_person_id         => p_person_id
                   ,p_bnfts_bal_id      => p_bnfts_bal_id
                   ,p_pgm_id            => NVL(p_pgm_id
                                            ,p_comp_obj_tree_row.par_pgm_id)
                   ,p_pl_id             => p_pl_id
                   ,p_oipl_id           => NVL(p_oipl_id
                                            ,l_oiplip_rec.oipl_id)
                   ,p_business_group_id => p_business_group_id
                   ,p_returned_date     => l_new_lf_evt_ocrd_dt
                   ,p_lf_evt_ocrd_dt    => l_lf_evt_ocrd_dt
                   ,p_effective_date    => l_lf_evt_ocrd_dt);
                  if g_debug then
                    hr_utility.set_location('  l_new_lf_evt_ocrd_dt '||l_new_lf_evt_ocrd_dt , 30);
                  end if;
                  --
                  -- The derived life event occured date must be greater than the
                  -- life event occured date as otherwise in reality a boundary
                  -- has not been passed.
                  -- This can only happen if the det_cd is one of the following :
                  -- AFDCPPY = As of first day of current program or plan year
                  -- APOCT1 = As of previous october 1st
                  -- AFDCM = As of first day of the current month
                  --
                  IF     l_new_lf_evt_ocrd_dt < l_lf_evt_ocrd_dt
                     AND p_det_cd IN (
                                                         'AFDCPPY'
                                                        ,'APOCT1'
                                                        ,'AFDCM') THEN
                    --
                    -- These are special cases where we need to rederive the LED
                    -- so that we are actually still passing the correct boundary
                    --
                    l_det_cd := p_det_cd ;
                    --
                    IF p_det_cd = 'APOCT1' THEN
                      --
                      l_lf_evt_ocrd_dt  := ADD_MONTHS(l_lf_evt_ocrd_dt
                                            ,12);
                    --
                    ELSIF p_det_cd = 'AFDCM' THEN
                      --
                      --l_lf_evt_ocrd_dt  := ADD_MONTHS(l_lf_evt_ocrd_dt ,1);
                      -- Bug 1927010. Commented the above manipulation
                      null ;
                      --
                    ELSIF p_det_cd = 'AFDCPPY' THEN
                      --
                      l_det_cd  := 'AFDFPPY';
                    --
                    END IF;
                    --
                    -- Reapply logic back to determination of date routine.
                    --
                    ben_determine_date.main(p_date_cd=> l_det_cd
                     ,p_bnfts_bal_id      => p_bnfts_bal_id
                     ,p_person_id         => p_person_id
                     ,p_pgm_id            => NVL(p_pgm_id
                                              ,p_comp_obj_tree_row.par_pgm_id)
                     ,p_pl_id             => p_pl_id
                     ,p_oipl_id           => NVL(p_oipl_id
                                              ,l_oiplip_rec.oipl_id)
                     ,p_business_group_id => p_business_group_id
                     ,p_returned_date     => l_new_lf_evt_ocrd_dt
                     ,p_lf_evt_ocrd_dt    => l_lf_evt_ocrd_dt
                     ,p_effective_date    => l_lf_evt_ocrd_dt);
                  --
                  END IF;
                  --
                  l_lf_evt_ocrd_dt  := l_new_lf_evt_ocrd_dt;
                --
                END IF;
                --
                if g_debug then
                  hr_utility.set_location('  l_lf_evt_ocrd_dt '||l_lf_evt_ocrd_dt , 40);
                end if;
                --
              ELSIF p_comp_src_cd = 'BNFTBALTYP' THEN
                --
                l_lf_evt_ocrd_dt  :=
                  get_balance_date(p_effective_date=> nvl(g_fonm_cvg_strt_dt,p_effective_date)
                   ,p_bnfts_bal_id   => p_bnfts_bal_id
                   ,p_person_id      => p_person_id
                   ,p_min            => p_min_value
                   ,p_max            => p_max_value
                   ,p_break          => l_break);
                --
                IF p_det_cd <> 'AED' THEN
                  --
                  ben_determine_date.main(p_date_cd=> p_det_cd
                   ,p_formula_id        => p_formula_id
                   ,p_person_id         => p_person_id
                   ,p_bnfts_bal_id      => p_bnfts_bal_id
                   ,p_pgm_id            => NVL(p_pgm_id
                                            ,p_comp_obj_tree_row.par_pgm_id)
                   ,p_pl_id             => p_pl_id
                   ,p_oipl_id           => NVL(p_oipl_id
                                            ,l_oiplip_rec.oipl_id)
                   ,p_business_group_id => p_business_group_id
                   ,p_returned_date     => l_new_lf_evt_ocrd_dt
                   ,p_lf_evt_ocrd_dt    => l_lf_evt_ocrd_dt
                   ,p_effective_date    => l_lf_evt_ocrd_dt);
                  --
                  -- The derived life event occured date must be greater than the
                  -- life event occured date as otherwise in reality a boundary
                  -- has not been passed.
                  -- This can only happen if the det_cd is one of the following :
                  -- AFDCPPY = As of first day of current program or plan year
                  -- APOCT1 = As of previous october 1st
                  -- AFDCM = As of first day of the current month
                  --
                  IF     l_new_lf_evt_ocrd_dt < l_lf_evt_ocrd_dt
                     AND p_det_cd IN (
                                                         'AFDCPPY'
                                                        ,'APOCT1'
                                                        ,'AFDCM') THEN
                    --
                    -- These are special cases where we need to rederive the LED
                    -- so that we are actually still passing the correct boundary
                    --
                    l_det_cd := p_det_cd ;
                    --
                    IF p_det_cd = 'APOCT1' THEN
                      --
                      l_lf_evt_ocrd_dt  := ADD_MONTHS(l_lf_evt_ocrd_dt
                                            ,12);
                    --
                    ELSIF p_det_cd = 'AFDCM' THEN
                      --
                      --l_lf_evt_ocrd_dt  := ADD_MONTHS(l_lf_evt_ocrd_dt ,1);
                      -- Bug 1927010. Commented the above manipulation
                      null ;
                      --
                    ELSIF p_det_cd = 'AFDCPPY' THEN
                      --
                      l_det_cd   := 'AFDFPPY';
                    --
                    END IF;
                    --
                    -- Reapply logic back to determination of date routine.
                    --
                    ben_determine_date.main(p_date_cd=> l_det_cd
                     ,p_bnfts_bal_id      => p_bnfts_bal_id
                     ,p_person_id         => p_person_id
                     ,p_pgm_id            => NVL(p_pgm_id
                                              ,p_comp_obj_tree_row.par_pgm_id)
                     ,p_pl_id             => p_pl_id
                     ,p_oipl_id           => NVL(p_oipl_id
                                              ,l_oiplip_rec.oipl_id)
                     ,p_business_group_id => p_business_group_id
                     ,p_returned_date     => l_new_lf_evt_ocrd_dt
                     ,p_lf_evt_ocrd_dt    => l_lf_evt_ocrd_dt
                     ,p_effective_date    => l_lf_evt_ocrd_dt);
                  --
                  END IF;
                  --
                  l_lf_evt_ocrd_dt  := l_new_lf_evt_ocrd_dt;
                --
                END IF;
              --
              ELSIF p_comp_src_cd = 'BALTYP' THEN
                --
                l_lf_evt_ocrd_dt  := p_effective_date;
              --
              END IF;
              --
              -- Check if the calculated life event occured date breaks the
              -- min assignment date for the person.
              --
              ben_person_object.get_object(p_person_id=> p_person_id
               ,p_rec       => l_rec);
              --
              if g_debug then
              hr_utility.set_location(' l_rec.min_ass_effective_start_date ' ||l_rec.min_ass_effective_start_date, 50);
              end if;
              if g_debug then
                hr_utility.set_location(' l_lf_evt_ocrd_dt '||l_lf_evt_ocrd_dt , 51);
              end if;
              --
              IF l_lf_evt_ocrd_dt >= l_rec.min_ass_effective_start_date THEN
                --
                -- ben_seeddata_object.get_object(p_rec=> p_ler_id);
                --
                if g_debug then
                  hr_utility.set_location(' Before no_life_event ',60);
                end if;
                --
                IF no_life_event(p_lf_evt_ocrd_dt=> l_lf_evt_ocrd_dt
                    ,p_person_id      => p_person_id
                    ,p_ler_id         => p_ler_id
                    ,p_effective_date => p_effective_date) THEN
                  --
                  if g_debug then
                    hr_utility.set_location(' No Life Event ',70);
                  end if;
                  --
                  IF    ( l_lf_evt_ocrd_dt < p_effective_date
                     AND NVL(p_ptnl_ler_trtmt_cd
                          ,'-1') = 'IGNR' OR NVL(p_ptnl_ler_trtmt_cd,'-1') = 'IGNRALL') THEN
                    --
                    if g_debug then
                      hr_utility.set_location('IGNR ' , 80);
                    end if;
                    -- We are not creating past life events
                    --
                    RETURN;
                    --
                  END IF;
                    --
                    if g_debug then
                      hr_utility.set_location('Call create_ptl_ler ' ,90);
                    end if;
                    --
                    create_ptl_ler
                      (p_calculate_only_mode => p_calculate_only_mode
                      ,p_ler_id              => p_ler_id
                      ,p_lf_evt_ocrd_dt      => l_lf_evt_ocrd_dt
                      ,p_person_id           => p_person_id
                      ,p_business_group_id   => p_business_group_id
                      ,p_effective_date      => p_effective_date
                      );
                  --
                END IF; -- no_life_event
              --
              END IF; -- l_lf_evt_ocrd_dt >= l_rec.min_ass_effective_start_date
            --
            END IF;
            --
            if g_debug then
              hr_utility.set_location(' Leaving comp_level_min_max ',100);
            end if;
            --
  END comp_level_min_max ;

-- Calculate compensation level
--
PROCEDURE calculate_compensation_level
  (p_calculate_only_mode in            boolean default false
  ,p_comp_obj_tree_row   in            ben_manage_life_events.g_cache_proc_objects_rec
  ,p_empasg_row          IN            per_all_assignments_f%ROWTYPE
  ,p_benasg_row          IN            per_all_assignments_f%ROWTYPE
  ,p_pil_row             IN            ben_per_in_ler%ROWTYPE
  ,p_curroipl_row        IN            ben_cobj_cache.g_oipl_inst_row
  ,p_curroiplip_row      IN            ben_cobj_cache.g_oiplip_inst_row
  ,p_person_id           IN            NUMBER
  ,p_business_group_id   IN            NUMBER
  ,p_pgm_id              IN            NUMBER
  ,p_pl_id               IN            NUMBER
  ,p_oipl_id             IN            NUMBER
  ,p_plip_id             IN            NUMBER
  ,p_ptip_id             IN            NUMBER
  ,p_oiplip_id           IN            NUMBER
  ,p_ptnl_ler_trtmt_cd   IN            VARCHAR2
  ,p_comp_rec            IN OUT NOCOPY g_cache_structure
  ,p_effective_date      IN            DATE
  ,p_lf_evt_ocrd_dt      IN            DATE
  )
IS
    --
    l_package            VARCHAR2(80)
                               := g_package || '.calculate_compensation_level';
    l_rate_result        NUMBER;
    l_rate_cvg_result    NUMBER;
    l_rate_prem_result   NUMBER;
    l_elig_result        NUMBER;
    l_subtract_date      DATE;
    l_lf_evt_ocrd_dt     DATE;
    l_new_lf_evt_ocrd_dt DATE;
    l_elig_rec           ben_derive_part_and_rate_cache.g_cache_clf_rec_obj;
    l_rate_rec           ben_derive_part_and_rate_cache.g_cache_clf_rec_obj;
    l_rate_cvg_rec       ben_derive_part_and_rate_cache.g_cache_clf_rec_obj;
    l_rate_prem_rec      ben_derive_part_and_rate_cache.g_cache_clf_rec_obj;
    l_break              VARCHAR2(30);
    l_ok                 BOOLEAN;
    l_rec                ben_person_object.g_person_date_info_rec;
    l_der_rec            ben_seeddata_object.g_derived_factor_info_rec;
    l_der_cvg_rec        ben_seeddata_object.g_derived_factor_info_rec;
    l_der_prem_rec       ben_seeddata_object.g_derived_factor_info_rec;
    l_dummy_date         DATE;
    l_start_date         DATE;
    l_rate               BOOLEAN                                     := FALSE;
    l_cvg                BOOLEAN                                     := FALSE;
    l_prem               BOOLEAN                                     := FALSE;
    l_oiplip_rec         ben_cobj_cache.g_oiplip_inst_row;
    --BUG 3174453
    l_pgm_id             number(15) := p_pgm_id;
    l_pl_id              number(15) := p_pl_id;
    l_oipl_id            number(15) := p_oipl_id;
    --
    procedure get_comp_objects(p_comp_obj_tree_row in ben_manage_life_events.g_cache_proc_objects_rec,
                               p_ptip_id         IN number,
                               p_plip_id         IN number,
                               p_oiplip_id       IN number,
                               p_effective_date  IN date,
                               p_pgm_id      IN OUT NOCOPY number,
                               p_pl_id       IN OUT NOCOPY number,
                               p_oipl_id     IN OUT NOCOPY number) is
      --
      l_package            VARCHAR2(80)
                               := g_package || '.get_comp_objects';
      cursor c_ptip is
       select pgm_id
         from ben_ptip_f ptip
        where ptip.ptip_id = p_ptip_id
          and nvl(g_fonm_cvg_strt_dt,p_effective_date)
                 between ptip.effective_start_date and ptip.effective_end_date ;
      --
      cursor c_plip is
       select pl_id
         from ben_plip_f plip
        where plip.plip_id = p_plip_id
          and nvl(g_fonm_cvg_strt_dt,p_effective_date)
                  between plip.effective_start_date
                                   and plip.effective_end_date;
      --
      cursor c_oipl is
       select oipl_id
         from ben_oiplip_f oiplip
        where oiplip.oiplip_id = p_oiplip_id
          and nvl(g_fonm_cvg_strt_dt,p_effective_date)
                  between oiplip.effective_start_date
                                   and oiplip.effective_end_date;
      --
      l_pgm_id             number(15) := p_pgm_id;
      l_pl_id              number(15) := p_pl_id;
      l_oipl_id            number(15) := p_oipl_id;
    begin
      --
      --BUG 3174453. If we don't have pgmid,plid or oipld we need to get them
      --from the p_comp_obj_tree_row cache to pass to determine_compensation
      --in bendefct.pkb
      g_debug := hr_utility.debug_enabled;
      if g_debug then
        hr_utility.set_location('Entering ' || l_package,10);
        hr_utility.set_location('p_pgm_id '||p_pgm_id,20);
        hr_utility.set_location('p_pl_id  '||p_pl_id,20);
        hr_utility.set_location('p_oipl_id '||p_oipl_id,20);
        hr_utility.set_location('p_plip_id '||p_plip_id,20);
        hr_utility.set_location('p_ptip_id '||p_ptip_id,20);
        hr_utility.set_location('p_oiplip_id'||p_oiplip_id,20);
        hr_utility.set_location('p_comp_obj_tree_row.OIPL_ID'||p_comp_obj_tree_row.OIPL_ID,20);
        hr_utility.set_location('p_comp_obj_tree_row.PL_ID'||p_comp_obj_tree_row.PL_ID,20);
        hr_utility.set_location('p_comp_obj_tree_row.PGM_ID'||p_comp_obj_tree_row.PGM_ID,20);
        hr_utility.set_location('p_comp_obj_tree_row.PLIPID'||p_comp_obj_tree_row.PLIP_ID,20);
        hr_utility.set_location('p_comp_obj_tree_row.PTIPID'||p_comp_obj_tree_row.PTIP_ID,20);
        hr_utility.set_location('p_comp_obj_tree_row.OIPLIP'||p_comp_obj_tree_row.OIPLIP_ID,20);
        --
      end if;
      --
      if p_pgm_id IS NULL AND p_pl_id IS NULL AND p_oipl_id IS NULL then
        --
        if p_OIPLIP_id is NOT NULL THEN
          --
          if p_comp_obj_tree_row.OIPL_ID is NOT NULL then
            --
            l_oipl_id := p_comp_obj_tree_row.OIPL_ID;
            --
          else
            --
            open c_oipl ;
            fetch c_oipl into l_oipl_id;
            close c_oipl;
            --
          end if;
          --
        elsif p_PLIP_ID is NOT NULL THEN
          --
          if p_comp_obj_tree_row.PL_ID is NOT NULL then
            --
            l_pl_id := p_comp_obj_tree_row.PL_ID;
            --
          else
            --
            open c_plip;
            fetch c_plip into l_pl_id;
            close c_plip;
          end if;
          --
        elsif p_PTIP_ID is NOT NULL THEN
          --
          if p_comp_obj_tree_row.PGM_ID is NOT NULL then
            --
            l_pgm_id :=  p_comp_obj_tree_row.PGM_ID;
          else
            --
            open c_ptip ;
            fetch c_ptip into l_pgm_id;
            close c_ptip;
            --
          end if;
          --
        end if;
        --
      end if;
      --
      p_pgm_id := l_pgm_id ;
      p_pl_id  := l_pl_id;
      p_oipl_id:= l_oipl_id;
      --
      if g_debug then
        hr_utility.set_location('p_pgm_id '||p_pgm_id,20);
        hr_utility.set_location('p_pl_id  '||p_pl_id,20);
        hr_utility.set_location('p_oipl_id '||p_oipl_id,20);
        hr_utility.set_location('Leaving ' || l_package,10);
        --
      end if;
      --
    end get_comp_objects;
    --
  --
  BEGIN
    --
    if g_debug then
      hr_utility.set_location('Entering ' || l_package,10);
    end if;
--
-- Calculate CLVL process
-- =====================
-- The sequence of operations is as follows :
-- 1) First check if freeze flag is on in which case
--    we ignore the calculation and just return the values
-- 2) Calculate eligibility derivable factors
-- 3) Calculate rate derivable factors
-- 4) Perform rounding
-- 5) Test for min/max breach
-- 6) If a breach did occur then create a ptl_ler_for_per.
--
    IF bitand(p_comp_obj_tree_row.flag_bit_val
        ,ben_manage_life_events.g_cmp_flag) <> 0 THEN
      --
     -- hr_utility.set_location('COMP for ELIG',10);
      IF p_comp_rec.frz_cmp_lvl_flag = 'Y' THEN
        --
        -- No calulation required just return the frozen value
        --
        NULL;
      --
      ELSE
        --
        ben_derive_part_and_rate_cache.get_comp_elig(p_pgm_id=> p_pgm_id
         ,p_pl_id             => p_pl_id
         ,p_oipl_id           => p_oipl_id
         ,p_plip_id           => p_plip_id
         ,p_ptip_id           => p_ptip_id
         ,p_business_group_id => p_business_group_id
         ,p_effective_date    => NVL(g_fonm_cvg_strt_dt,NVL(p_lf_evt_ocrd_dt
                                  ,p_effective_date))
         ,p_rec               => l_elig_rec);
        --
        l_ok  := TRUE;
        --
        IF l_elig_rec.exist = 'Y' THEN
          -- Rule takes precedence
         -- hr_utility.set_location(' Elig exists ' || l_package,10);
          IF l_elig_rec.comp_calc_rl IS NOT NULL THEN
            --
            ben_determine_date.main(p_date_cd=> l_elig_rec.comp_lvl_det_cd
             ,p_formula_id        => l_elig_rec.comp_lvl_det_rl
             ,p_person_id         => p_person_id
             ,p_pgm_id            => NVL(p_pgm_id
                                      ,p_comp_obj_tree_row.par_pgm_id)
             ,p_bnfts_bal_id      => l_elig_rec.bnfts_bal_id
             ,p_pl_id             => p_pl_id
             ,p_oipl_id           => p_oipl_id
             ,p_business_group_id => p_business_group_id
             ,p_returned_date     => l_start_date
             ,p_lf_evt_ocrd_dt    =>  p_lf_evt_ocrd_dt
             ,p_effective_date    =>  NVL(p_lf_evt_ocrd_dt ,p_effective_date)
             );
            --
            run_rule(p_formula_id => l_elig_rec.comp_calc_rl
             ,p_empasg_row        => p_empasg_row
             ,p_benasg_row        => p_benasg_row
             ,p_pil_row           => p_pil_row
             ,p_curroipl_row      => p_curroipl_row
             ,p_curroiplip_row    => p_curroiplip_row
             ,p_effective_date    => l_start_date
             ,p_lf_evt_ocrd_dt    => l_start_date
             ,p_business_group_id => p_business_group_id
             ,p_person_id         => p_person_id
             ,p_pgm_id            => p_pgm_id
             ,p_pl_id             => p_pl_id
             ,p_oipl_id           => p_oipl_id
             ,p_oiplip_id         => p_oiplip_id
             ,p_plip_id           => p_plip_id
             ,p_ptip_id           => p_ptip_id
             ,p_ret_date          => l_dummy_date
             ,p_ret_val           => l_elig_result);
            --
            -- Round value if rounding needed
            --
            IF    l_elig_rec.rndg_cd IS NOT NULL
               OR l_elig_rec.rndg_rl IS NOT NULL THEN
              --
              l_elig_result  :=
                benutils.do_rounding(p_rounding_cd=> l_elig_rec.rndg_cd
                 ,p_rounding_rl    => l_elig_rec.rndg_rl
                 ,p_value          => l_elig_result
                 ,p_effective_date => NVL(p_lf_evt_ocrd_dt
                                       ,p_effective_date));
            --
            END IF;
          --
          ELSE
            --
            /*
            l_elig_result  :=
              comp_calculation(p_comp_obj_tree_row=> p_comp_obj_tree_row
               ,p_empasg_row        => p_empasg_row
               ,p_benasg_row        => p_benasg_row
               ,p_curroiplip_row    => p_curroiplip_row
               ,p_rec               => l_elig_rec
               ,p_person_id         => p_person_id
               ,p_business_group_id => p_business_group_id
               ,p_pgm_id            => p_pgm_id
               ,p_pl_id             => p_pl_id
               ,p_oipl_id           => p_oipl_id
               ,p_oiplip_id         => p_oiplip_id
               ,p_plip_id           => p_plip_id
               ,p_ptip_id           => p_ptip_id
               ,p_effective_date    => p_effective_date
               ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt);
             */
              --
              -- passing the oipl_id from the oiplip record, incase p_oipl_id is null.
              -- passing the oipl_id from the oiplip record, incase p_oipl_id is null.
              -- BUG 3174453
              get_comp_objects( p_comp_obj_tree_row=>p_comp_obj_tree_row
                               ,p_effective_date   => nvl(g_fonm_cvg_strt_dt, p_effective_date)
                               ,p_ptip_id   =>p_ptip_id
                               ,p_plip_id   =>p_plip_id
                               ,p_oiplip_id =>p_oiplip_id
                               ,p_pgm_id    =>l_pgm_id
                               ,p_pl_id     =>l_pl_id
                               ,p_oipl_id   =>l_oipl_id );
              --
              --
              BEN_DERIVE_FACTORS.determine_compensation
              ( p_comp_lvl_fctr_id     => l_elig_rec.comp_lvl_fctr_id -- in number,
               ,p_person_id            => p_person_id            -- in number,
               ,p_pgm_id               => l_pgm_id               -- in number    default null,
               ,p_pl_id                => l_pl_id                -- in number    default null,
               ,p_oipl_id              => l_oipl_id
               ,p_per_in_ler_id        => p_pil_row.per_in_ler_id-- in number,
               ,p_business_group_id    => p_business_group_id    -- in number,
             --   ,p_perform_rounding_flg in boolean default true,
               ,p_effective_date       => p_effective_date      -- in date,
               ,p_lf_evt_ocrd_dt       => p_lf_evt_ocrd_dt       -- in date default null,
             --  ,p_calc_bal_to_date     in date default null,
             --  ,p_cal_for              in varchar2  default null,
               ,p_value                => l_elig_result
               ,p_fonm_cvg_strt_dt     => g_fonm_cvg_strt_dt );
              --
           -- hr_utility.set_location(' Dn comp calc ' || l_package,10);
          --
          END IF;
        --
        /* Bug 5478918 */
          --
          ben_seeddata_object.get_object(p_rec=> l_der_rec);
	  if (skip_min_max_le_calc(l_der_rec.drvdcmp_id,
	                           p_business_group_id,
                                   p_ptnl_ler_trtmt_cd,
                                   p_effective_date)) THEN
            --
            /* Simply return as no further calculations need to be done */
            hr_utility.set_location(l_package||' Do Nothing here.', 9877);
            null;
            --
          else
          --
          -- In case called from watif benmngle then need not create
          -- temporals for any min, max breaches.
          --
          IF     l_elig_result IS NOT NULL
             AND (
                       ben_whatif_elig.g_stat_comp IS NULL
                   AND ben_whatif_elig.g_bnft_bal_comp IS NULL
                   AND ben_whatif_elig.g_bal_comp IS NULL) THEN
            --
                 ben_derive_part_and_rate_cache.get_comp_elig(p_pgm_id=> p_pgm_id
                     ,p_pl_id             => p_pl_id
                     ,p_oipl_id           => p_oipl_id
                     ,p_plip_id           => p_plip_id
                     ,p_ptip_id           => p_ptip_id
                     ,p_new_val           => l_elig_result
                     ,p_old_val           => p_comp_rec.comp_ref_amt
                     ,p_business_group_id => p_business_group_id
                     ,p_effective_date    => NVL(g_fonm_cvg_strt_dt,NVL(p_lf_evt_ocrd_dt
                                              ,p_effective_date))
                     ,p_rec               => l_elig_rec);
        --
            IF benutils.min_max_breach(p_min_value=> NVL(l_elig_rec.mn_comp_val
                                                      ,-1)
                ,p_max_value => NVL(l_elig_rec.mx_comp_val
                                 ,99999999)
                ,p_new_value => l_elig_result
                ,p_old_value => p_comp_rec.comp_ref_amt
                ,p_break     => l_break) THEN
              --
              -- Derive life event occured date based on the value of l_break
              --
              IF l_elig_rec.comp_src_cd = 'STTDCOMP' THEN
                --
                l_lf_evt_ocrd_dt  :=
                  get_salary_date(p_empasg_row=> p_empasg_row
                   ,p_benasg_row     => p_benasg_row
                   ,p_rec            => l_elig_rec
                   ,p_person_id      => p_person_id
                   ,p_effective_date => NVL(g_fonm_cvg_strt_dt,NVL(p_lf_evt_ocrd_dt
                                         ,p_effective_date))
                   ,p_min            => l_elig_rec.mn_comp_val
                   ,p_max            => l_elig_rec.mx_comp_val
                   ,p_break          => l_break);
                --
                -- Reapply life event date logic to derived date
                --
                IF l_elig_rec.comp_lvl_det_cd <> 'AED' THEN
                  --
                  ben_determine_date.main(p_date_cd=> l_elig_rec.comp_lvl_det_cd
                   ,p_formula_id        => l_elig_rec.comp_lvl_det_rl
                   ,p_person_id         => p_person_id
                   ,p_bnfts_bal_id      => l_elig_rec.bnfts_bal_id
                   ,p_pgm_id            => NVL(p_pgm_id
                                            ,p_comp_obj_tree_row.par_pgm_id)
                   ,p_pl_id             => p_pl_id
                   ,p_oipl_id           => p_oipl_id
                   ,p_business_group_id => p_business_group_id
                   ,p_returned_date     => l_lf_evt_ocrd_dt
                   ,p_lf_evt_ocrd_dt    => l_lf_evt_ocrd_dt
                   ,p_effective_date    => l_lf_evt_ocrd_dt
                   );
                  --
                  -- The derived life event occured date must be greater than the
                  -- life event occured date as otherwise in reality a boundary
                  -- has not been passed.
                  -- This can only happen if the det_cd is one of the following :
                  -- AFDCPPY = As of first day of current program oreplan year
                  -- APOCT1 = As of previous october 1st
                  -- AFDCM = As of first day of the current month
                  --
                  IF     l_new_lf_evt_ocrd_dt < l_lf_evt_ocrd_dt
                     AND l_elig_rec.comp_lvl_det_cd IN (
                                                         'AFDCPPY'
                                                        ,'APOCT1'
                                                        ,'AFDCM') THEN
                    --
                    -- These are special cases where we need to rederive the LED
                    -- so that we are actually still passing the correct boundary
                    --
                    IF l_elig_rec.comp_lvl_det_cd = 'APOCT1' THEN
                      --
                      l_lf_evt_ocrd_dt  := ADD_MONTHS(l_lf_evt_ocrd_dt
                                            ,12);
                    --
                    ELSIF l_elig_rec.comp_lvl_det_cd = 'AFDCM' THEN
                      --
                      --l_lf_evt_ocrd_dt  := ADD_MONTHS(l_lf_evt_ocrd_dt ,1);
                      -- Bug 1927010. Commented the above manipulation
                      null ;
                    --
                    ELSIF l_elig_rec.comp_lvl_det_cd = 'AFDCPPY' THEN
                      --
                      l_elig_rec.comp_lvl_det_cd  := 'AFDFPPY';
                    --
                    END IF;
                    --
                    -- Reapply logic back to determination of date routine.
                    --
                    ben_determine_date.main(p_date_cd=> l_elig_rec.comp_lvl_det_cd
                     ,p_bnfts_bal_id      => l_elig_rec.bnfts_bal_id
                     ,p_person_id         => p_person_id
                     ,p_pgm_id            => NVL(p_pgm_id
                                              ,p_comp_obj_tree_row.par_pgm_id)
                     ,p_pl_id             => p_pl_id
                     ,p_oipl_id           => p_oipl_id
                     ,p_business_group_id => p_business_group_id
                     ,p_returned_date     => l_new_lf_evt_ocrd_dt
                     ,p_lf_evt_ocrd_dt    => l_lf_evt_ocrd_dt
                     ,p_effective_date    => l_lf_evt_ocrd_dt
                     );
                  --
                  END IF;
                  --
                  l_lf_evt_ocrd_dt  := l_new_lf_evt_ocrd_dt;
                --
                END IF;
              --
              ELSIF l_elig_rec.comp_src_cd = 'BNFTBALTYP' THEN
                --
                l_lf_evt_ocrd_dt  :=
                  get_balance_date(p_effective_date=> NVL(g_fonm_cvg_strt_dt,
                                                          NVL(p_lf_evt_ocrd_dt,p_effective_date))
                   ,p_bnfts_bal_id   => l_elig_rec.bnfts_bal_id
                   ,p_person_id      => p_person_id
                   ,p_min            => l_elig_rec.mn_comp_val
                   ,p_max            => l_elig_rec.mx_comp_val
                   ,p_break          => l_break);
                --
                IF l_elig_rec.comp_lvl_det_cd <> 'AED' THEN
                  --
                  ben_determine_date.main(p_date_cd=> l_elig_rec.comp_lvl_det_cd
                   ,p_formula_id        => l_elig_rec.comp_lvl_det_rl
                   ,p_bnfts_bal_id      => l_elig_rec.bnfts_bal_id
                   ,p_person_id         => p_person_id
                   ,p_pgm_id            => NVL(p_pgm_id
                                            ,p_comp_obj_tree_row.par_pgm_id)
                   ,p_pl_id             => p_pl_id
                   ,p_oipl_id           => p_oipl_id
                   ,p_business_group_id => p_business_group_id
                   ,p_returned_date     => l_new_lf_evt_ocrd_dt
                   ,p_lf_evt_ocrd_dt    => l_lf_evt_ocrd_dt
                   ,p_effective_date    => l_lf_evt_ocrd_dt
                   );
                  --
                  -- The derived life event occured date must be greater than the
                  -- life event occured date as otherwise in reality a boundary
                  -- has not been passed.
                  -- This can only happen if the det_cd is one of the following :
                  -- AFDCPPY = As of first day of current program or plan year
                  -- APOCT1 = As of previous october 1st
                  -- AFDCM = As of first day of the current month
                  --
                  IF     l_new_lf_evt_ocrd_dt < l_lf_evt_ocrd_dt
                     AND l_elig_rec.comp_lvl_det_cd IN (
                                                         'AFDCPPY'
                                                        ,'APOCT1'
                                                        ,'AFDCM') THEN
                    --
                    -- These are special cases where we need to rederive the LED
                    -- so that we are actually still passing the correct boundary
                    --
                    IF l_elig_rec.comp_lvl_det_cd = 'APOCT1' THEN
                      --
                      l_lf_evt_ocrd_dt  := ADD_MONTHS(l_lf_evt_ocrd_dt
                                            ,12);
                    --
                    ELSIF l_elig_rec.comp_lvl_det_cd = 'AFDCM' THEN
                      --
                      -- l_lf_evt_ocrd_dt  := ADD_MONTHS(l_lf_evt_ocrd_dt ,1);
                      -- Bug 1927010. Commented the above manipulation
                      null ;
                    --
                    ELSIF l_elig_rec.comp_lvl_det_cd = 'AFDCPPY' THEN
                      --
                      l_elig_rec.comp_lvl_det_cd  := 'AFDFPPY';
                    --
                    END IF;
                    --
                    -- Reapply logic back to determination of date routine.
                    --
                    ben_determine_date.main(p_date_cd=> l_elig_rec.comp_lvl_det_cd
                     ,p_bnfts_bal_id      => l_elig_rec.bnfts_bal_id
                     ,p_person_id         => p_person_id
                     ,p_pgm_id            => NVL(p_pgm_id
                                              ,p_comp_obj_tree_row.par_pgm_id)
                     ,p_pl_id             => p_pl_id
                     ,p_oipl_id           => p_oipl_id
                     ,p_business_group_id => p_business_group_id
                     ,p_returned_date     => l_new_lf_evt_ocrd_dt
                     ,p_lf_evt_ocrd_dt    => l_lf_evt_ocrd_dt
                     ,p_effective_date    => l_lf_evt_ocrd_dt
                     );
                  --
                  END IF;
                  --
                  l_lf_evt_ocrd_dt  := l_new_lf_evt_ocrd_dt;
                --
                END IF;
              --
              ELSIF l_elig_rec.comp_src_cd = 'BALTYP' THEN
                --
                l_lf_evt_ocrd_dt  := p_effective_date;
              --
              END IF;
              --
              -- Check if the calculated life event occured date breaks the
              -- min assignment date for the person.
              --
              ben_person_object.get_object(p_person_id=> p_person_id
               ,p_rec       => l_rec);
              --
              IF l_lf_evt_ocrd_dt >= l_rec.min_ass_effective_start_date THEN
                --
                IF no_life_event(p_lf_evt_ocrd_dt=> l_lf_evt_ocrd_dt
                    ,p_person_id      => p_person_id
                    ,p_ler_id         => l_der_rec.drvdcmp_id
                    ,p_effective_date => p_effective_date) THEN
                  --
                  IF   (  l_lf_evt_ocrd_dt < p_effective_date
                     AND NVL(p_ptnl_ler_trtmt_cd
                          ,'-1') = 'IGNR' OR NVL(p_ptnl_ler_trtmt_cd,'-1') = 'IGNRALL')  THEN
                    --
                    -- We are not creating past life events
                    --
                    NULL;
                  --
                  ELSIF l_ok THEN
                    --
                    if not p_calculate_only_mode then
                      --
                      create_ptl_ler
                        (p_calculate_only_mode => p_calculate_only_mode
                        ,p_ler_id              => l_der_rec.drvdcmp_id
                        ,p_lf_evt_ocrd_dt      => l_lf_evt_ocrd_dt
                        ,p_person_id           => p_person_id
                        ,p_business_group_id   => p_business_group_id
                        ,p_effective_date      => p_effective_date
                        );
                      --
                    end if;
                    --
                  END IF;
                --
                END IF;
              --
              END IF;
            --
            END IF;
          --
          END IF;
          --
       END IF; /* End Bug 5478918 */
       --
          p_comp_rec.comp_ref_amt  := l_elig_result;
          p_comp_rec.comp_ref_uom  := l_elig_rec.comp_lvl_uom;
          --
          IF l_elig_result IS NULL THEN
            --
            p_comp_rec.comp_ref_uom  := NULL;
          --
          END IF;
        --
        ELSE
          --
          p_comp_rec.comp_ref_amt  := NULL;
          p_comp_rec.comp_ref_uom  := NULL;
        --
        END IF;
      --
      END IF;
      --
     -- hr_utility.set_location('RFCLF=Y ' || l_package,10);
    --
    END IF;
    --
    if g_debug then
      hr_utility.set_location(' Before entering into Rate Factors ', 15);
    end if;
    IF    bitand(p_comp_obj_tree_row.flag_bit_val
           ,ben_manage_life_events.g_cmp_rt_flag) <> 0
       OR     p_oiplip_id IS NOT NULL
          AND bitand(p_comp_obj_tree_row.oiplip_flag_bit_val
               ,ben_manage_life_events.g_cmp_rt_flag) <> 0 THEN
      --
      if g_debug then
        hr_utility.set_location('COMP for RT',10);
      end if;
      IF p_comp_rec.rt_frz_cmp_lvl_flag = 'Y' THEN
        --
        -- No calulation required just return the frozen value
        --
        NULL;
      --
      ELSE
        --
        if g_debug then
          hr_utility.set_location('ben_derive_part_and_rate_cache '||p_oipl_id , 20);
        end if;
        --
        ben_derive_part_and_rate_cache.get_comp_rate(p_pgm_id=> p_pgm_id
         ,p_pl_id             => p_pl_id
         ,p_oipl_id           => p_oipl_id
         ,p_plip_id           => p_plip_id
         ,p_ptip_id           => p_ptip_id
         ,p_oiplip_id         => p_oiplip_id
         ,p_business_group_id => p_business_group_id
         ,p_effective_date    => NVL(g_fonm_cvg_strt_dt,
                                     NVL(p_lf_evt_ocrd_dt,p_effective_date))
         ,p_rec               => l_rate_rec);
        --
        IF l_rate_rec.exist = 'Y' THEN
          --
          if g_debug then
            hr_utility.set_location(' l_rate_rec.exist ' ,25);
          end if;
          l_rate  := TRUE;
          --
          IF p_oiplip_id IS NOT NULL THEN
            --
            if g_debug then
              hr_utility.set_location(' p_curroiplip_row ',25);
            end if;
            l_oiplip_rec  := p_curroiplip_row;
          --
          END IF;
          --
          IF l_rate_rec.comp_calc_rl IS NOT NULL THEN
            --
            if g_debug then
              hr_utility.set_location('in the comp_calc_rl ' ,30);
            end if;
            --
            ben_determine_date.main(p_date_cd=> l_rate_rec.comp_lvl_det_cd
             ,p_formula_id        => l_rate_rec.comp_lvl_det_rl
             ,p_person_id         => p_person_id
             ,p_pgm_id            => NVL(p_pgm_id
                                      ,p_comp_obj_tree_row.par_pgm_id)
             ,p_bnfts_bal_id      => l_rate_rec.bnfts_bal_id
             ,p_pl_id             => p_pl_id
             ,p_oipl_id           => NVL(p_oipl_id
                                      ,l_oiplip_rec.oipl_id)
             ,p_business_group_id => p_business_group_id
             ,p_returned_date     => l_start_date
             ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
             ,p_effective_date    => NVL(p_lf_evt_ocrd_dt
                                      ,p_effective_date)
             );
            --
            run_rule(p_formula_id => l_rate_rec.comp_calc_rl
             ,p_empasg_row        => p_empasg_row
             ,p_benasg_row        => p_benasg_row
             ,p_pil_row           => p_pil_row
             ,p_curroipl_row      => p_curroipl_row
             ,p_curroiplip_row    => p_curroiplip_row
             ,p_effective_date    => p_effective_date
             ,p_lf_evt_ocrd_dt    => l_start_date
             ,p_business_group_id => p_business_group_id
             ,p_person_id         => p_person_id
             ,p_pgm_id            => p_pgm_id
             ,p_pl_id             => p_pl_id
             ,p_oipl_id           => p_oipl_id
             ,p_oiplip_id         => p_oiplip_id
             ,p_plip_id           => p_plip_id
             ,p_ptip_id           => p_ptip_id
             ,p_ret_date          => l_dummy_date
             ,p_ret_val           => l_rate_result);
            --
            -- Round value if rounding needed
            --
            IF    l_rate_rec.rndg_cd IS NOT NULL
               OR l_rate_rec.rndg_rl IS NOT NULL THEN
              --
              if g_debug then
                hr_utility.set_location('in the comp_calc_rl rndg_cd ' ,35 );
              end if;
              --
              l_rate_result  :=
                benutils.do_rounding(p_rounding_cd=> l_rate_rec.rndg_cd
                 ,p_rounding_rl    => l_rate_rec.rndg_rl
                 ,p_value          => l_rate_result
                 ,p_effective_date => NVL(p_lf_evt_ocrd_dt
                                       ,p_effective_date));
            --
            END IF;
            --
          ELSE -- l_rate_rec.comp_calc_rl
            --
            if g_debug then
              hr_utility.set_location('not rule -  l_rate_result ',30);
            end if;
            /*
            l_rate_result  :=
              comp_calculation(p_comp_obj_tree_row=> p_comp_obj_tree_row
               ,p_empasg_row        => p_empasg_row
               ,p_benasg_row        => p_benasg_row
               ,p_curroiplip_row    => p_curroiplip_row
               ,p_rec               => l_rate_rec
               ,p_person_id         => p_person_id
               ,p_business_group_id => p_business_group_id
               ,p_pgm_id            => p_pgm_id
               ,p_pl_id             => p_pl_id
               ,p_oipl_id           => p_oipl_id
               ,p_oiplip_id         => p_oiplip_id
               ,p_plip_id           => p_plip_id
               ,p_ptip_id           => p_ptip_id
               ,p_effective_date    => p_effective_date
               ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt);
             */
              --
              -- BUG 3174453
              get_comp_objects( p_comp_obj_tree_row=>p_comp_obj_tree_row
                               ,p_effective_date   => nvl(g_fonm_cvg_strt_dt,p_effective_date)
                               ,p_ptip_id   =>p_ptip_id
                               ,p_plip_id   =>p_plip_id
                               ,p_oiplip_id =>p_oiplip_id
                               ,p_pgm_id    =>l_pgm_id
                               ,p_pl_id     =>l_pl_id
                               ,p_oipl_id   =>l_oipl_id );
              --
              BEN_DERIVE_FACTORS.determine_compensation
              ( p_comp_lvl_fctr_id     => l_rate_rec.comp_lvl_fctr_id -- in number,
               ,p_person_id            => p_person_id            -- in number,
               ,p_pgm_id               => l_pgm_id               -- in number    default null,
               ,p_pl_id                => l_pl_id                -- in number    default null,
               ,p_oipl_id              => nvl(p_oipl_id,l_oiplip_rec.oipl_id)  -- 2946985  -- in number    default null,
               ,p_per_in_ler_id        => p_pil_row.per_in_ler_id-- in number,
               ,p_business_group_id    => p_business_group_id    -- in number,
             --   ,p_perform_rounding_flg in boolean default true,
               ,p_effective_date       => p_effective_date       -- in date,
               ,p_lf_evt_ocrd_dt       => p_lf_evt_ocrd_dt       -- in date default null,
             --  ,p_calc_bal_to_date     in date default null,
             --  ,p_cal_for              => 'R'                    -- in varchar2  default null,
               ,p_value                => l_rate_result
                ,p_fonm_cvg_strt_dt     => g_fonm_cvg_strt_dt);

            --
            IF l_rate_result is not null THEN
              --
              --
              ben_derive_part_and_rate_cache.get_comp_rate(p_pgm_id=> p_pgm_id
                ,p_pl_id             => p_pl_id
                ,p_oipl_id           => p_oipl_id
                ,p_plip_id           => p_plip_id
                ,p_ptip_id           => p_ptip_id
                ,p_oiplip_id         => p_oiplip_id
                ,p_new_val           => l_rate_result
                ,p_old_val           => p_comp_rec.rt_comp_ref_amt
                ,p_business_group_id => p_business_group_id
                ,p_effective_date    => NVL(g_fonm_cvg_strt_dt,
                                           NVL(p_lf_evt_ocrd_dt ,p_effective_date))
                ,p_rec               => l_rate_rec);
               --
              IF ( ben_whatif_elig.g_stat_comp IS NULL
                   AND ben_whatif_elig.g_bnft_bal_comp IS NULL
                   AND ben_whatif_elig.g_bal_comp IS NULL)     THEN
                --
                ben_seeddata_object.get_object(p_rec=> l_der_rec);
                --
                if g_debug then
                  hr_utility.set_location(' Call to comp_level_min_max ' ,45 );
                end if;

                comp_level_min_max
                   (p_calculate_only_mode =>p_calculate_only_mode
                   ,p_comp_obj_tree_row   =>p_comp_obj_tree_row
                   ,p_curroiplip_row      =>p_curroiplip_row
                   ,p_rec                 => l_rate_rec
                    --,p_rate_rec            =>l_rate_rec
                    --,p_comp_rec            =>p_comp_rec
                   ,p_empasg_row          =>p_empasg_row
                   ,p_benasg_row          =>p_benasg_row
                   ,p_person_id           =>p_person_id
                   ,p_pgm_id              =>p_pgm_id
                   ,p_pl_id               =>p_pl_id
                   ,p_oipl_id             =>p_oipl_id
                   ,p_oiplip_id           =>p_oiplip_id
                   ,p_plip_id             =>p_plip_id
                   ,p_ptip_id             =>p_ptip_id
                   ,p_business_group_id   =>p_business_group_id
                   ,p_ler_id              =>l_der_rec.drvdcmp_id
                   ,p_min_value           =>l_rate_rec.mn_comp_val
                   ,p_max_value           =>l_rate_rec.mx_comp_val
                   ,p_new_value           =>l_rate_result
                   ,p_old_value           =>p_comp_rec.rt_comp_ref_amt
                   ,p_uom                 =>l_rate_rec.comp_lvl_uom
                   ,p_subtract_date       =>l_subtract_date
                   ,p_det_cd              =>l_rate_rec.comp_lvl_det_cd
                   ,p_formula_id          =>l_rate_rec.comp_lvl_det_rl
                   ,p_ptnl_ler_trtmt_cd   =>p_ptnl_ler_trtmt_cd
                   ,p_effective_date      =>p_effective_date
                   ,p_lf_evt_ocrd_dt      =>p_lf_evt_ocrd_dt
                   ,p_comp_src_cd         =>l_rate_rec.comp_src_cd
                   ,p_bnfts_bal_id        =>l_rate_rec.bnfts_bal_id
                  ) ;
                --
              END IF; -- ben_whatif_elig
              --
            END IF; -- l_rate_result
            --
          END IF; -- l_rate_rec.los_calc_rl
          --
        END IF ; -- l_rate_rec.exist
        -- Try and find a coverage first
        --
        if g_debug then
          hr_utility.set_location(' Now check for Coverage and Premium' ,50 );
        end if;
        --
        IF    p_oipl_id IS NOT NULL
            OR p_pl_id IS NOT NULL
            OR p_plip_id IS NOT NULL THEN
          --
          if g_debug then
            hr_utility.set_location(' ben_derive_part_and_rate_cvg ' , 55);
          end if;
          --
          ben_derive_part_and_rate_cvg.get_comp_rate(p_pl_id=> p_pl_id
             ,p_oipl_id           => p_oipl_id
             ,p_plip_id           => p_plip_id
             ,p_business_group_id => p_business_group_id
             ,p_effective_date    => NVL(g_fonm_cvg_strt_dt,
                                        NVL(p_lf_evt_ocrd_dt ,p_effective_date))
             ,p_rec               => l_rate_cvg_rec);
          --
          IF l_rate_cvg_rec.exist = 'Y' THEN
            --
            if g_debug then
              hr_utility.set_location(' l_rate_cvg_rec.exist' , 60);
            end if;
            l_cvg  := TRUE;
            --
            IF l_rate_cvg_rec.comp_calc_rl IS NOT NULL THEN
            --

              ben_determine_date.main(p_date_cd=> l_rate_cvg_rec.comp_lvl_det_cd
               ,p_formula_id        => l_rate_cvg_rec.comp_lvl_det_rl
               ,p_person_id         => p_person_id
               ,p_pgm_id            => NVL(p_pgm_id
                                        ,p_comp_obj_tree_row.par_pgm_id)
               ,p_bnfts_bal_id      => l_rate_cvg_rec.bnfts_bal_id
               ,p_pl_id             => p_pl_id
               ,p_oipl_id           => NVL(p_oipl_id
                                        ,l_oiplip_rec.oipl_id)
               ,p_business_group_id => p_business_group_id
               ,p_returned_date     => l_start_date
               ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
               ,p_effective_date    => NVL(p_lf_evt_ocrd_dt
                                      ,p_effective_date)
               ) ;
              --
              run_rule(p_formula_id => l_rate_cvg_rec.comp_calc_rl
               ,p_empasg_row        => p_empasg_row
               ,p_benasg_row        => p_benasg_row
               ,p_pil_row           => p_pil_row
               ,p_curroipl_row      => p_curroipl_row
               ,p_curroiplip_row    => p_curroiplip_row
               ,p_effective_date    => p_effective_date
               ,p_lf_evt_ocrd_dt    => l_start_date
               ,p_business_group_id => p_business_group_id
               ,p_person_id         => p_person_id
               ,p_pgm_id            => p_pgm_id
               ,p_pl_id             => p_pl_id
               ,p_oipl_id           => p_oipl_id
               ,p_oiplip_id         => p_oiplip_id
               ,p_plip_id           => p_plip_id
               ,p_ptip_id           => p_ptip_id
               ,p_ret_date          => l_dummy_date
               ,p_ret_val           => l_rate_cvg_result);
              --
              -- Round value if rounding needed
              --
              IF    l_rate_cvg_rec.rndg_cd IS NOT NULL
               OR l_rate_cvg_rec.rndg_rl IS NOT NULL THEN
                --
                l_rate_cvg_result  :=
                  benutils.do_rounding(p_rounding_cd=> l_rate_cvg_rec.rndg_cd
                   ,p_rounding_rl    => l_rate_cvg_rec.rndg_rl
                   ,p_value          => l_rate_cvg_result
                   ,p_effective_date => NVL(p_lf_evt_ocrd_dt
                                         ,p_effective_date));
                  --
              END IF;
            --
          ELSE -- l_rate_cvg_rec.comp_calc_rl
            --
            if g_debug then
              hr_utility.set_location(' call to comp_calculation ' , 65 );
            end if;
            /*
            l_rate_cvg_result  :=
              comp_calculation(p_comp_obj_tree_row=> p_comp_obj_tree_row
               ,p_empasg_row        => p_empasg_row
               ,p_benasg_row        => p_benasg_row
               ,p_curroiplip_row    => p_curroiplip_row
               ,p_rec               => l_rate_cvg_rec
               ,p_person_id         => p_person_id
               ,p_business_group_id => p_business_group_id
               ,p_pgm_id            => p_pgm_id
               ,p_pl_id             => p_pl_id
               ,p_oipl_id           => p_oipl_id
               ,p_oiplip_id         => p_oiplip_id
               ,p_plip_id           => p_plip_id
               ,p_ptip_id           => p_ptip_id
               ,p_effective_date    => p_effective_date
               ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt);
            */
            --
              -- BUG 3174453
              get_comp_objects( p_comp_obj_tree_row=>p_comp_obj_tree_row
                               ,p_effective_date   =>nvl(g_fonm_cvg_strt_dt,p_effective_date)
                               ,p_ptip_id   =>p_ptip_id
                               ,p_plip_id   =>p_plip_id
                               ,p_oiplip_id =>p_oiplip_id
                               ,p_pgm_id    =>l_pgm_id
                               ,p_pl_id     =>l_pl_id
                               ,p_oipl_id   =>l_oipl_id );

              --
              BEN_DERIVE_FACTORS.determine_compensation
              ( p_comp_lvl_fctr_id     => l_rate_cvg_rec.comp_lvl_fctr_id -- in number,
               ,p_person_id            => p_person_id            -- in number,
               ,p_pgm_id               => l_pgm_id               -- in number    default null,
               ,p_pl_id                => l_pl_id                -- in number    default null,
               ,p_oipl_id              => l_oipl_id              -- in number    default null,
               ,p_per_in_ler_id        => p_pil_row.per_in_ler_id-- in number,
               ,p_business_group_id    => p_business_group_id    -- in number,
             --   ,p_perform_rounding_flg in boolean default true,
               ,p_effective_date       => p_effective_date       -- in date,
               ,p_lf_evt_ocrd_dt       => p_lf_evt_ocrd_dt       -- in date default null,
             --  ,p_calc_bal_to_date     in date default null,
             --  ,p_cal_for              => 'R'                    -- in varchar2  default null,
               ,p_value                => l_rate_cvg_result
                ,p_fonm_cvg_strt_dt    => g_fonm_cvg_strt_dt);
              ---
              if g_debug then
                hr_utility.set_location('  l_rate_cvg_result ' ,70);
              end if;
            IF l_rate_cvg_result is not null THEN
              --
              ben_derive_part_and_rate_cvg.get_comp_rate(p_pl_id=> p_pl_id
                ,p_oipl_id           => p_oipl_id
                ,p_plip_id           => p_plip_id
                ,p_old_val           => p_comp_rec.rt_comp_ref_amt
                ,p_new_val           => l_rate_cvg_result
                ,p_business_group_id => p_business_group_id
                ,p_effective_date    => NVL(g_fonm_cvg_strt_dt,
                                            NVL(p_lf_evt_ocrd_dt ,p_effective_date))
                ,p_rec               => l_rate_cvg_rec);

              --
              IF ( ben_whatif_elig.g_stat_comp IS NULL
                   AND ben_whatif_elig.g_bnft_bal_comp IS NULL
                   AND ben_whatif_elig.g_bal_comp IS NULL)     THEN

                 ben_seeddata_object.get_object(p_rec=> l_der_cvg_rec);
                 --
                 if g_debug then
                   hr_utility.set_location('  call comp_level_min_max ' ,75);
                 end if;
                 comp_level_min_max
                   (p_calculate_only_mode =>p_calculate_only_mode
                   ,p_comp_obj_tree_row   =>p_comp_obj_tree_row
                   ,p_curroiplip_row      =>p_curroiplip_row
                   ,p_rec                 =>l_rate_cvg_rec
                --   ,p_rate_rec            =>l_rate_cvg_rec
                --   ,p_comp_rec            =>p_comp_rec
                   ,p_empasg_row          =>p_empasg_row
                   ,p_benasg_row          =>p_benasg_row
                   ,p_person_id           =>p_person_id
                   ,p_pgm_id              =>p_pgm_id
                   ,p_pl_id               =>p_pl_id
                   ,p_oipl_id             =>p_oipl_id
                   ,p_oiplip_id           =>p_oiplip_id
                   ,p_plip_id             =>p_plip_id
                   ,p_ptip_id             =>p_ptip_id
                   ,p_business_group_id   =>p_business_group_id
                   ,p_ler_id              =>l_der_cvg_rec.drvdcmp_id
                   ,p_min_value           =>l_rate_cvg_rec.mn_comp_val
                   ,p_max_value           =>l_rate_cvg_rec.mx_comp_val
                   ,p_new_value           =>l_rate_cvg_result -- l_rate_result
                   ,p_old_value           =>p_comp_rec.rt_comp_ref_amt
                   ,p_uom                 =>l_rate_cvg_rec.comp_lvl_uom
                   ,p_subtract_date       =>l_subtract_date
                   ,p_det_cd              =>l_rate_cvg_rec.comp_lvl_det_cd
                   ,p_formula_id          =>l_rate_cvg_rec.comp_lvl_det_rl
                   ,p_ptnl_ler_trtmt_cd   =>p_ptnl_ler_trtmt_cd
                   ,p_effective_date      =>p_effective_date
                   ,p_lf_evt_ocrd_dt      =>p_lf_evt_ocrd_dt
                   ,p_comp_src_cd         =>l_rate_cvg_rec.comp_src_cd
                   ,p_bnfts_bal_id        =>l_rate_cvg_rec.bnfts_bal_id
                  ) ;
              END IF; -- ben_whatif_elig
              --
            END IF; -- l_rate_cvg_result
            --
          END IF; -- l_rate_cvg_rec.los_calc_rl
          --
        END IF; -- l_rate_cvg_rec.exist
        --
      END IF ; -- oipl for Coverage
      --
      IF p_oipl_id IS NOT NULL
        OR p_pl_id IS NOT NULL THEN
        --
        if g_debug then
          hr_utility.set_location(' Now call ben_derive_part_and_rate_prem ' , 80);
        end if;
        --
        ben_derive_part_and_rate_prem.get_comp_rate(
              p_pl_id             => p_pl_id
             ,p_oipl_id           => p_oipl_id
             ,p_business_group_id => p_business_group_id
             ,p_effective_date    =>  nvl(g_fonm_cvg_strt_dt,NVL(p_lf_evt_ocrd_dt
                                      ,p_effective_date))
             ,p_rec               => l_rate_prem_rec);
              --
        IF l_rate_prem_rec.exist = 'Y' THEN
          --
          if g_debug then
            hr_utility.set_location(' l_rate_prem_rec.exist Y ',85);
          end if;
          l_prem  := TRUE;
          --
          IF l_rate_prem_rec.comp_calc_rl IS NOT NULL THEN
            --
            ben_determine_date.main(p_date_cd=> l_rate_prem_rec.comp_lvl_det_cd
                      ,p_formula_id        => l_rate_prem_rec.comp_lvl_det_rl
                      ,p_person_id         => p_person_id
                      ,p_pgm_id            => NVL(p_pgm_id
                                               ,p_comp_obj_tree_row.par_pgm_id)
                      ,p_bnfts_bal_id      => l_rate_prem_rec.bnfts_bal_id
                      ,p_pl_id             => p_pl_id
                      ,p_oipl_id           => NVL(p_oipl_id
                                               ,l_oiplip_rec.oipl_id)
                      ,p_business_group_id => p_business_group_id
                      ,p_returned_date     => l_start_date
                      ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
                      ,p_effective_date    => NVL(p_lf_evt_ocrd_dt
                                               ,p_effective_date)
                      ) ;
                  --
                  run_rule(p_formula_id => l_rate_prem_rec.comp_calc_rl
                     ,p_empasg_row        => p_empasg_row
                     ,p_benasg_row        => p_benasg_row
                     ,p_pil_row           => p_pil_row
                     ,p_curroipl_row      => p_curroipl_row
                     ,p_curroiplip_row    => p_curroiplip_row
                     ,p_effective_date    => p_effective_date
                     ,p_lf_evt_ocrd_dt    => l_start_date
                     ,p_business_group_id => p_business_group_id
                     ,p_person_id         => p_person_id
                     ,p_pgm_id            => p_pgm_id
                     ,p_pl_id             => p_pl_id
                     ,p_oipl_id           => p_oipl_id
                     ,p_oiplip_id         => p_oiplip_id
                     ,p_plip_id           => p_plip_id
                     ,p_ptip_id           => p_ptip_id
                     ,p_ret_date          => l_dummy_date
                     ,p_ret_val           => l_rate_prem_result);
                    --
                    -- Round value if rounding needed
                    --
            IF    l_rate_prem_rec.rndg_cd IS NOT NULL
               OR l_rate_prem_rec.rndg_rl IS NOT NULL THEN
              --
              l_rate_prem_result  :=
                benutils.do_rounding(p_rounding_cd=> l_rate_prem_rec.rndg_cd
                 ,p_rounding_rl    => l_rate_prem_rec.rndg_rl
                 ,p_value          => l_rate_prem_result
                 ,p_effective_date => NVL(p_lf_evt_ocrd_dt
                                       ,p_effective_date));
            --
            END IF;
            --
          ELSE -- l_rate_prem_rec.comp_calc_rl
            --
            if g_debug then
              hr_utility.set_location(' call to comp_calculation ' , 90);
            end if;
          /*
            l_rate_prem_result  :=
              comp_calculation(p_comp_obj_tree_row=> p_comp_obj_tree_row
               ,p_empasg_row        => p_empasg_row
               ,p_benasg_row        => p_benasg_row
               ,p_curroiplip_row    => p_curroiplip_row
               ,p_rec               => l_rate_prem_rec
               ,p_person_id         => p_person_id
               ,p_business_group_id => p_business_group_id
               ,p_pgm_id            => p_pgm_id
               ,p_pl_id             => p_pl_id
               ,p_oipl_id           => p_oipl_id
               ,p_oiplip_id         => p_oiplip_id
               ,p_plip_id           => p_plip_id
               ,p_ptip_id           => p_ptip_id
               ,p_effective_date    => p_effective_date
               ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt);
            */
              -- BUG 3174453
              get_comp_objects( p_comp_obj_tree_row=>p_comp_obj_tree_row
                               ,p_effective_date   => nvl(g_fonm_cvg_strt_dt,p_effective_date)
                               , p_ptip_id   =>p_ptip_id
                               ,p_plip_id   =>p_plip_id
                               ,p_oiplip_id =>p_oiplip_id
                               ,p_pgm_id    =>l_pgm_id
                               ,p_pl_id     =>l_pl_id
                               ,p_oipl_id   =>l_oipl_id );
              --
              BEN_DERIVE_FACTORS.determine_compensation
              ( p_comp_lvl_fctr_id     => l_rate_prem_rec.comp_lvl_fctr_id -- in number,
               ,p_person_id            => p_person_id            -- in number,
               ,p_pgm_id               => l_pgm_id               -- in number    default null,
               ,p_pl_id                => l_pl_id                -- in number    default null,
               ,p_oipl_id              => l_oipl_id              -- in number    default null,
               ,p_per_in_ler_id        => p_pil_row.per_in_ler_id-- in number,
               ,p_business_group_id    => p_business_group_id    -- in number,
             --   ,p_perform_rounding_flg in boolean default true,
               ,p_effective_date       => p_effective_date       -- in date,
               ,p_lf_evt_ocrd_dt       => p_lf_evt_ocrd_dt       -- in date default null,
             --  ,p_calc_bal_to_date     in date default null,
             --  ,p_cal_for              => 'R'                    -- in varchar2  default null,
               ,p_value                => l_rate_prem_result
               ,p_fonm_cvg_strt_dt     => g_fonm_cvg_strt_dt);
              --
              if g_debug then
                hr_utility.set_location(' l_rate_prem_result '||l_rate_prem_result ,95);
              end if;
              if g_debug then
                hr_utility.set_location(' p_old_val '||p_comp_rec.rt_comp_ref_amt,95);
              end if;
              if g_debug then
                hr_utility.set_location(' p_new_val '||l_rate_prem_result,95);
              end if;
              if g_debug then
                hr_utility.set_location(' p_pl_id  '||p_pl_id,95);
              end if;
              if g_debug then
                hr_utility.set_location(' p_oipl_id '||p_oipl_id,95);
              end if;
              if g_debug then
                hr_utility.set_location(' p_effective_date '||NVL(p_lf_evt_ocrd_dt,p_effective_date) ,95);
              end if;
              --
              IF l_rate_prem_result is not null THEN
                --
                ben_derive_part_and_rate_prem.get_comp_rate(
                    p_pl_id             => p_pl_id
                   ,p_oipl_id           => p_oipl_id
                   ,p_old_val           => p_comp_rec.rt_comp_ref_amt
                   ,p_new_val           => l_rate_prem_result
                   ,p_business_group_id => p_business_group_id
                   ,p_effective_date    =>  nvl(g_fonm_cvg_strt_dt,
                                                NVL(p_lf_evt_ocrd_dt ,p_effective_date))
                   ,p_rec               => l_rate_prem_rec);
                 --
                 IF ( ben_whatif_elig.g_stat_comp IS NULL
                     AND ben_whatif_elig.g_bnft_bal_comp IS NULL
                     AND ben_whatif_elig.g_bal_comp IS NULL)     THEN
                   --
                   ben_seeddata_object.get_object(p_rec=> l_der_prem_rec);
                   --
                   if g_debug then
                     hr_utility.set_location(' call to comp_level_min_max ' ,100);
                   end if;
                   comp_level_min_max
                     (p_calculate_only_mode =>p_calculate_only_mode
                     ,p_comp_obj_tree_row   =>p_comp_obj_tree_row
                     ,p_curroiplip_row      =>p_curroiplip_row
                     ,p_rec                 =>l_rate_prem_rec
                 --      ,p_rate_rec            =>l_rate_prem_rec
                 --    ,p_comp_rec            =>p_comp_rec
                     ,p_empasg_row          =>p_empasg_row
                     ,p_benasg_row          =>p_benasg_row
                     ,p_person_id           =>p_person_id
                     ,p_pgm_id              =>p_pgm_id
                     ,p_pl_id               =>p_pl_id
                     ,p_oipl_id             =>p_oipl_id
                     ,p_oiplip_id           =>p_oiplip_id
                     ,p_plip_id             =>p_plip_id
                     ,p_ptip_id             =>p_ptip_id
                     ,p_business_group_id   =>p_business_group_id
                     ,p_ler_id              =>l_der_prem_rec.drvdcmp_id
                     ,p_min_value           =>l_rate_prem_rec.mn_comp_val
                     ,p_max_value           =>l_rate_prem_rec.mx_comp_val
                     ,p_new_value           =>l_rate_prem_result
                     ,p_old_value           =>p_comp_rec.rt_comp_ref_amt
                     ,p_uom                 =>l_rate_prem_rec.comp_lvl_uom
                     ,p_subtract_date       =>l_subtract_date
                     ,p_det_cd              =>l_rate_prem_rec.comp_lvl_det_cd
                     ,p_formula_id          =>l_rate_prem_rec.comp_lvl_det_rl
                     ,p_ptnl_ler_trtmt_cd   =>p_ptnl_ler_trtmt_cd
                     ,p_effective_date      =>p_effective_date
                     ,p_lf_evt_ocrd_dt      =>p_lf_evt_ocrd_dt
                     ,p_comp_src_cd         =>l_rate_prem_rec.comp_src_cd
                     ,p_bnfts_bal_id        =>l_rate_prem_rec.bnfts_bal_id
                      ) ;
                     --
                 END IF; --ben_whatif_elig
                 --
               END IF; -- l_rate_prem_result
               --
             END IF; -- l_rate_prem_rec.los_calc_rl
             --
           END IF; -- l_rate_prem_rec.exist
           --
         END IF; -- p_oipl_id for Premium
         --
         if g_debug then
           hr_utility.set_location(' Done with Rate, Cvg and Prem ', 110);
         end if;
         --
         IF l_rate_result IS NULL and l_rate_cvg_result IS NULL and  l_rate_prem_result IS NULL THEN
          --
          if g_debug then
            hr_utility.set_location('No record found ' ,120);
          end if;
          --
          p_comp_rec.rt_comp_ref_amt  := NULL;
          p_comp_rec.rt_comp_ref_uom  := NULL;
          --
        ELSIF l_rate_result is NOT NULL THEN
          if g_debug then
            hr_utility.set_location(' Step 28',10);
          end if;
          p_comp_rec.rt_comp_ref_amt  := l_rate_result;
          p_comp_rec.rt_comp_ref_uom  := l_rate_rec.comp_lvl_uom;
          --
        ELSIF l_rate_cvg_result is NOT NULL then
          --
          p_comp_rec.rt_comp_ref_amt  := l_rate_cvg_result;
          p_comp_rec.rt_comp_ref_uom  := l_rate_cvg_rec.comp_lvl_uom;
          if g_debug then
            hr_utility.set_location(' Step 29',10);
          end if;
        ELSIF l_rate_prem_result is NOT NULL THEN
          --
          p_comp_rec.rt_comp_ref_amt  := l_rate_prem_result;
          p_comp_rec.rt_comp_ref_uom  := l_rate_prem_rec.comp_lvl_uom;
          if g_debug then
            hr_utility.set_location(' Step 30',10);
          end if;
        END IF;
/*
          p_comp_rec.rt_comp_ref_amt  := l_rate_result;
          p_comp_rec.rt_comp_ref_uom  := l_rate_rec.comp_lvl_uom;
          --
         IF l_rate_result IS NULL THEN
           --
           p_comp_rec.rt_comp_ref_uom  := NULL;
           --
         END IF;
        --
        ELSE
          --
          p_comp_rec.rt_comp_ref_amt  := NULL;
          p_comp_rec.rt_comp_ref_uom  := NULL;
        --
*/
      --
      END IF;
    --
    END IF;
    --
    if g_debug then
      hr_utility.set_location('Leaving ' || l_package,10);
    end if;
  --
  END calculate_compensation_level;
  --
  --
  PROCEDURE calculate_comb_age_and_los
    (p_calculate_only_mode in     boolean default false
    ,p_comp_obj_tree_row   IN     ben_manage_life_events.g_cache_proc_objects_rec
    ,p_per_row             IN     per_all_people_f%ROWTYPE
    ,p_empasg_row          IN     per_all_assignments_f%ROWTYPE
    ,p_benasg_row          IN     per_all_assignments_f%ROWTYPE
    ,p_pil_row             IN     ben_per_in_ler%ROWTYPE
    ,p_curroipl_row        IN     ben_cobj_cache.g_oipl_inst_row
    ,p_curroiplip_row      IN     ben_cobj_cache.g_oiplip_inst_row
    ,p_person_id           IN     NUMBER
    ,p_business_group_id   IN     NUMBER
    ,p_pgm_id              IN     NUMBER
    ,p_pl_id               IN     NUMBER
    ,p_oipl_id             IN     NUMBER
    ,p_plip_id             IN     NUMBER
    ,p_ptip_id             IN     NUMBER
    ,p_oiplip_id           IN     NUMBER
    ,p_ptnl_ler_trtmt_cd   IN     VARCHAR2
    ,p_comp_rec            IN OUT NOCOPY g_cache_structure
    ,p_effective_date      IN     DATE
    ,p_lf_evt_ocrd_dt      IN     DATE
    )
  IS
    --
    l_package     VARCHAR2(80)   := g_package || '.calculate_comb_age_and_los';
    l_rate_result NUMBER;
    l_rate_cvg_result  NUMBER;
    l_rate_prem_result NUMBER;
    l_elig_result NUMBER;
    l_result      NUMBER;
    l_age         NUMBER;
    l_age_uom     VARCHAR2(30);
    l_rt_age      NUMBER;
    l_rt_age_uom  VARCHAR2(30);
    l_los         NUMBER;
    l_los_uom     VARCHAR2(30);
    l_rt_los      NUMBER;
    l_rt_los_uom  VARCHAR2(30);
    l_ok          BOOLEAN                                            := TRUE;
    l_break       VARCHAR2(30);
    l_elig_rec       ben_derive_part_and_rate_cache.g_cache_cla_rec_obj;
    l_rate_rec       ben_derive_part_and_rate_cache.g_cache_cla_rec_obj;
    l_rate_cvg_rec   ben_derive_part_and_rate_cache.g_cache_cla_rec_obj;
    l_rate_prem_rec  ben_derive_part_and_rate_cache.g_cache_cla_rec_obj;
    l_der_rec        ben_seeddata_object.g_derived_factor_info_rec;
    l_der_cvg_rec    ben_seeddata_object.g_derived_factor_info_rec;
    l_der_prem_rec   ben_seeddata_object.g_derived_factor_info_rec;
    l_rate        BOOLEAN                                            := FALSE;
    l_cvg         BOOLEAN                                            := FALSE;
    l_prem        BOOLEAN                                            := FALSE;
  --
  BEGIN
    --
   -- hr_utility.set_location('Entering ' || l_package,10);
--
-- Calculate Comb AGE LOS process
-- ==============================
-- The sequence of operations is as follows :
-- 1) First check if freeze comb AGE LOS flag is on in which case
--    we ignore the calculation and just return the values
-- 2) Calculate eligibility derivable factors
-- 3) Calculate rate derivable factors
-- 3) Perform rounding
-- 4) Test for min/max breach
-- 5) If a breach did occur then create a ptl_ler_for_per.
--
    IF bitand(p_comp_obj_tree_row.flag_bit_val
        ,ben_manage_life_events.g_cal_flag) <> 0 THEN
      --
     -- hr_utility.set_location('CAL for ELIG',10);
      IF p_comp_rec.frz_comb_age_and_los_flag = 'Y' THEN
        --
        -- No calculation required just return the frozen value
        --
        NULL;
      --
      ELSE
        --
        ben_derive_part_and_rate_cache.get_comb_elig(p_pgm_id=> p_pgm_id
         ,p_pl_id             => p_pl_id
         ,p_oipl_id           => p_oipl_id
         ,p_plip_id           => p_plip_id
         ,p_ptip_id           => p_ptip_id
         ,p_business_group_id => p_business_group_id
         ,p_effective_date    => NVL(g_fonm_cvg_strt_dt,NVL(p_lf_evt_ocrd_dt
                                  ,p_effective_date))
         ,p_rec               => l_elig_rec);
        --
        IF l_elig_rec.exist = 'Y' THEN
          --
          -- Eligibility stuff first
          --
          calculate_los
            (p_calculate_only_mode => p_calculate_only_mode
            ,p_comp_obj_tree_row   => p_comp_obj_tree_row
            ,p_empasg_row          => p_empasg_row
            ,p_benasg_row          => p_benasg_row
            ,p_pil_row             => p_pil_row
            ,p_curroipl_row        => p_curroipl_row
            ,p_curroiplip_row      => p_curroiplip_row
            ,p_person_id           => p_person_id
            ,p_business_group_id   => p_business_group_id
            ,p_pgm_id              => p_pgm_id
            ,p_pl_id               => p_pl_id
            ,p_oipl_id             => p_oipl_id
            ,p_plip_id             => p_plip_id
            ,p_ptip_id             => p_ptip_id
            ,p_oiplip_id           => p_oiplip_id
            ,p_los_fctr_id         => l_elig_rec.los_fctr_id
            ,p_comp_rec            => p_comp_rec
            ,p_effective_date      => p_effective_date
            ,p_ptnl_ler_trtmt_cd   => p_ptnl_ler_trtmt_cd
            ,p_lf_evt_ocrd_dt      => p_lf_evt_ocrd_dt
            );
          --
          calculate_age(p_comp_obj_tree_row=> p_comp_obj_tree_row
           ,p_per_row           => p_per_row
           ,p_empasg_row        => p_empasg_row
           ,p_benasg_row        => p_benasg_row
           ,p_pil_row           => p_pil_row
           ,p_curroipl_row      => p_curroipl_row
           ,p_curroiplip_row    => p_curroiplip_row
           ,p_person_id         => p_person_id
           ,p_business_group_id => p_business_group_id
           ,p_pgm_id            => p_pgm_id
           ,p_pl_id             => p_pl_id
           ,p_oipl_id           => p_oipl_id
           ,p_plip_id           => p_plip_id
           ,p_ptip_id           => p_ptip_id
           ,p_oiplip_id         => p_oiplip_id
           ,p_age_fctr_id       => l_elig_rec.age_fctr_id
           ,p_comp_rec          => p_comp_rec
           ,p_effective_date    => p_effective_date
           ,p_ptnl_ler_trtmt_cd => p_ptnl_ler_trtmt_cd
           ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt);
          --
          p_comp_rec.comb_los            := p_comp_rec.los_val;
          p_comp_rec.comb_age            := p_comp_rec.age_val;
          --
          l_elig_result                  := p_comp_rec.age_val + p_comp_rec.los_val;
          --
        --  p_comp_rec.cmbn_age_n_los_val  := l_elig_result;
          if g_debug then
            hr_utility.set_location('Combined value'||l_elig_result,100);
          end if;
          --
          IF p_comp_rec.cmbn_age_n_los_val IS NOT NULL THEN
            --
            --
           /* Bug 5478918 */
	   ben_seeddata_object.get_object(p_rec=> l_der_rec);
           if (skip_min_max_le_calc(l_der_rec.drvdcal_id,
	                         p_business_group_id,
                                 p_ptnl_ler_trtmt_cd,
                                 p_effective_date)) THEN
            --
           /* Simply return as no further calculations need to be done */
           hr_utility.set_location(l_package||' Do Nothing here.', 9877);
           null;
            --
           else
            --
             ben_derive_part_and_rate_cache.get_comb_elig(p_pgm_id=> p_pgm_id
              ,p_pl_id             => p_pl_id
              ,p_oipl_id           => p_oipl_id
              ,p_plip_id           => p_plip_id
              ,p_ptip_id           => p_ptip_id
              ,p_new_val           => l_elig_result
              ,p_old_val           => p_comp_rec.cmbn_age_n_los_val
              ,p_business_group_id => p_business_group_id
              ,p_effective_date    => NVL(g_fonm_cvg_strt_dt,NVL(p_lf_evt_ocrd_dt
                                       ,p_effective_date))
              ,p_rec               => l_elig_rec);
        --
            IF benutils.min_max_breach(p_min_value=> NVL(l_elig_rec.cmbnd_min_val
                                                      ,-1)
                ,p_max_value => NVL(l_elig_rec.cmbnd_max_val
                                 ,99999999)
                ,p_new_value => l_elig_result
                ,p_old_value => p_comp_rec.cmbn_age_n_los_val
                ,p_break     => l_break) THEN
              --
              -- Now test if cached value breaks same boundary
              --
              l_ok  := TRUE;
              --
              IF     l_ok
                 AND no_life_event(p_lf_evt_ocrd_dt=> p_effective_date
                      ,p_person_id      => p_person_id
                      ,p_ler_id         => l_der_rec.drvdcal_id
                      ,p_effective_date => p_effective_date)
              THEN
                --
                --IF NVL(p_ptnl_ler_trtmt_cd,'-1') = 'IGNRALL'  THEN
                  --
                  -- We are not creating past life events
                  --
                 -- NULL;
                  --
              --  ELSE
                  create_ptl_ler
                    (p_calculate_only_mode => p_calculate_only_mode
                    ,p_ler_id=> l_der_rec.drvdcal_id
                    ,p_lf_evt_ocrd_dt    => p_effective_date
                    ,p_person_id         => p_person_id
                    ,p_business_group_id => p_business_group_id
                    ,p_effective_date    => p_effective_date
                    );
              --  END IF;
                --
              END IF;
            --
            END IF;
           --
	   END IF;  /* End Bug 5478918 */
           --
          END IF;
          --
          --Bug 3291639
          --
          p_comp_rec.cmbn_age_n_los_val  := l_elig_result;
        --
        END IF;
      --
      END IF;
    --
    END IF;
    --
   -- hr_utility.set_location('p_comp_rec ' || p_comp_rec.cmbn_age_n_los_val,10);
    --
    IF    bitand(p_comp_obj_tree_row.flag_bit_val
           ,ben_manage_life_events.g_cal_rt_flag) <> 0
       OR     p_oiplip_id IS NOT NULL
          AND bitand(p_comp_obj_tree_row.oiplip_flag_bit_val
               ,ben_manage_life_events.g_cal_rt_flag) <> 0 THEN
      --
     -- hr_utility.set_location('CAL for RT',10);
      IF p_comp_rec.rt_frz_comb_age_and_los_flag = 'Y' THEN
        --
        -- No calculation required just return the frozen value
        --
        NULL;
      --
      ELSE
        -- Rate calculation
        --
        ben_derive_part_and_rate_cache.get_comb_rate(p_pgm_id=> p_pgm_id
         ,p_pl_id             => p_pl_id
         ,p_oipl_id           => p_oipl_id
         ,p_plip_id           => p_plip_id
         ,p_ptip_id           => p_ptip_id
         ,p_oiplip_id         => p_oiplip_id
         ,p_business_group_id => p_business_group_id
         ,p_effective_date    => NVL(g_fonm_cvg_strt_dt,NVL(p_lf_evt_ocrd_dt
                                  ,p_effective_date))
         ,p_rec               => l_rate_rec);
        --
        IF l_rate_rec.exist = 'Y' THEN
          --
          l_rate  := TRUE;
          --
          -- Rate stuff next
          --
          calculate_los
            (p_calculate_only_mode => p_calculate_only_mode
            ,p_comp_obj_tree_row   => p_comp_obj_tree_row
            ,p_empasg_row          => p_empasg_row
            ,p_benasg_row          => p_benasg_row
            ,p_pil_row             => p_pil_row
            ,p_curroipl_row        => p_curroipl_row
            ,p_curroiplip_row      => p_curroiplip_row
            ,p_person_id           => p_person_id
            ,p_business_group_id   => p_business_group_id
            ,p_pgm_id              => p_pgm_id
            ,p_pl_id               => p_pl_id
            ,p_oipl_id             => p_oipl_id
            ,p_plip_id             => p_plip_id
            ,p_ptip_id             => p_ptip_id
            ,p_oiplip_id           => p_oiplip_id
            ,p_los_fctr_id         => l_rate_rec.los_fctr_id
            ,p_comp_rec            => p_comp_rec
            ,p_effective_date      => p_effective_date
            ,p_ptnl_ler_trtmt_cd   => p_ptnl_ler_trtmt_cd
            ,p_lf_evt_ocrd_dt      => p_lf_evt_ocrd_dt
            );
          --
          calculate_age(p_comp_obj_tree_row=> p_comp_obj_tree_row
           ,p_per_row           => p_per_row
           ,p_empasg_row        => p_empasg_row
           ,p_benasg_row        => p_benasg_row
           ,p_pil_row           => p_pil_row
           ,p_curroipl_row      => p_curroipl_row
           ,p_curroiplip_row    => p_curroiplip_row
           ,p_person_id         => p_person_id
           ,p_business_group_id => p_business_group_id
           ,p_pgm_id            => p_pgm_id
           ,p_pl_id             => p_pl_id
           ,p_oipl_id           => p_oipl_id
           ,p_plip_id           => p_plip_id
           ,p_ptip_id           => p_ptip_id
           ,p_oiplip_id         => p_oiplip_id
           ,p_age_fctr_id       => l_rate_rec.age_fctr_id
           ,p_comp_rec          => p_comp_rec
           ,p_effective_date    => p_effective_date
           ,p_ptnl_ler_trtmt_cd => p_ptnl_ler_trtmt_cd
           ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt);
          --
          p_comp_rec.comb_rt_los            := p_comp_rec.rt_los_val;
          p_comp_rec.comb_rt_age            := p_comp_rec.rt_age_val;
          --
          l_rate_result                     := p_comp_rec.rt_los_val + p_comp_rec.rt_age_val;
          --
          -- p_comp_rec.rt_cmbn_age_n_los_val  := l_rate_result;
        --
        --
          ben_derive_part_and_rate_cache.get_comb_rate(p_pgm_id=> p_pgm_id
           ,p_pl_id             => p_pl_id
           ,p_oipl_id           => p_oipl_id
           ,p_plip_id           => p_plip_id
           ,p_ptip_id           => p_ptip_id
           ,p_oiplip_id         => p_oiplip_id
           ,p_new_val           => l_rate_result
           ,p_old_val           => p_comp_rec.rt_cmbn_age_n_los_val
           ,p_business_group_id => p_business_group_id
           ,p_effective_date    => NVL(g_fonm_cvg_strt_dt,NVL(p_lf_evt_ocrd_dt
                                    ,p_effective_date))
           ,p_rec               => l_rate_rec);
        --
        --
        END IF; -- l_rate_rec.exist
        --
        IF p_comp_rec.rt_cmbn_age_n_los_val IS NOT NULL THEN
          --
        /* Bug 5478918 */
	ben_seeddata_object.get_object(p_rec=> l_der_rec);
        if (skip_min_max_le_calc(l_der_rec.drvdcal_id,
	                         p_business_group_id,
                                 p_ptnl_ler_trtmt_cd,
                                 p_effective_date)) THEN
        --
        /* Simply return as no further calculations need to be done */
          hr_utility.set_location(l_package||' Do Nothing here.', 9877);
          null;
        --
        else
        --
          IF benutils.min_max_breach(p_min_value=> NVL(l_rate_rec.cmbnd_min_val
                                                    ,-1)
              ,p_max_value => NVL(l_rate_rec.cmbnd_max_val
                               ,99999999)
              ,p_new_value => l_rate_result
              ,p_old_value => p_comp_rec.rt_cmbn_age_n_los_val
              ,p_break     => l_break) THEN
            --
            --
            IF  no_life_event(p_lf_evt_ocrd_dt=>nvl(g_fonm_cvg_strt_dt, p_effective_date)
                    ,p_person_id      => p_person_id
                    ,p_ler_id         => l_der_rec.drvdcal_id
                    ,p_effective_date => p_effective_date)
            THEN
              --
             -- IF NVL(p_ptnl_ler_trtmt_cd,'-1') = 'IGNRALL'  THEN
                --
                -- We are not creating past life events
                --
              --  NULL;
                --
             -- ELSE
                -- tilak to be discussed about date
                create_ptl_ler
                (p_calculate_only_mode => p_calculate_only_mode
                ,p_ler_id              => l_der_rec.drvdcal_id
                ,p_lf_evt_ocrd_dt      => nvl(g_fonm_cvg_strt_dt,p_effective_date)
                ,p_person_id           => p_person_id
                ,p_business_group_id   => p_business_group_id
                ,p_effective_date      => p_effective_date
                );
                --
            --  END IF;
              --
            END IF;
          --
          END IF;
         --
	 END IF;  /* End Bug 5478918 */
         --
        END IF; --p_comp_rec.rt_cmbn_age_n_los_val
        --
        -- End of Rate routine
        --
        -- Try and find a coverage
        --
        IF    p_oipl_id IS NOT NULL
             OR p_pl_id IS NOT NULL
             OR p_plip_id IS NOT NULL THEN
          --
          ben_derive_part_and_rate_cvg.get_comb_rate(p_pl_id=> p_pl_id
             ,p_oipl_id           => p_oipl_id
             ,p_plip_id           => p_plip_id
             ,p_business_group_id => p_business_group_id
             ,p_effective_date    => NVL(g_fonm_cvg_strt_dt,NVL(p_lf_evt_ocrd_dt
                                      ,p_effective_date))
             ,p_rec               => l_rate_cvg_rec);
            --
          IF l_rate_cvg_rec.exist = 'Y' THEN
            --
            calculate_los
              (p_calculate_only_mode => p_calculate_only_mode
              ,p_comp_obj_tree_row   => p_comp_obj_tree_row
              ,p_empasg_row          => p_empasg_row
              ,p_benasg_row          => p_benasg_row
              ,p_pil_row             => p_pil_row
              ,p_curroipl_row        => p_curroipl_row
              ,p_curroiplip_row      => p_curroiplip_row
              ,p_person_id           => p_person_id
              ,p_business_group_id   => p_business_group_id
              ,p_pgm_id              => p_pgm_id
              ,p_pl_id               => p_pl_id
              ,p_oipl_id             => p_oipl_id
              ,p_plip_id             => p_plip_id
              ,p_ptip_id             => p_ptip_id
              ,p_oiplip_id           => p_oiplip_id
              ,p_los_fctr_id         => l_rate_cvg_rec.los_fctr_id
              ,p_comp_rec            => p_comp_rec
              ,p_effective_date      => p_effective_date
              ,p_ptnl_ler_trtmt_cd   => p_ptnl_ler_trtmt_cd
              ,p_lf_evt_ocrd_dt      => p_lf_evt_ocrd_dt
              );
              --
            calculate_age(p_comp_obj_tree_row=> p_comp_obj_tree_row
              ,p_per_row           => p_per_row
              ,p_empasg_row        => p_empasg_row
              ,p_benasg_row        => p_benasg_row
              ,p_pil_row           => p_pil_row
              ,p_curroipl_row      => p_curroipl_row
              ,p_curroiplip_row    => p_curroiplip_row
              ,p_person_id         => p_person_id
              ,p_business_group_id => p_business_group_id
              ,p_pgm_id            => p_pgm_id
              ,p_pl_id             => p_pl_id
              ,p_oipl_id           => p_oipl_id
              ,p_plip_id           => p_plip_id
              ,p_ptip_id           => p_ptip_id
              ,p_oiplip_id         => p_oiplip_id
              ,p_age_fctr_id       => l_rate_cvg_rec.age_fctr_id
              ,p_comp_rec          => p_comp_rec
              ,p_effective_date    => p_effective_date
              ,p_ptnl_ler_trtmt_cd => p_ptnl_ler_trtmt_cd
              ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt);
             --
            p_comp_rec.comb_rt_los            := p_comp_rec.rt_los_val;
            p_comp_rec.comb_rt_age            := p_comp_rec.rt_age_val;
            --
            l_rate_cvg_result                     := p_comp_rec.rt_los_val + p_comp_rec.rt_age_val;
            --
            -- p_comp_rec.rt_cmbn_age_n_los_val  := l_rate_cvg_result;
            --
            --
            ben_derive_part_and_rate_cvg.get_comb_rate(p_pl_id=> p_pl_id
             ,p_oipl_id           => p_oipl_id
             ,p_plip_id           => p_plip_id
             ,p_old_val           => p_comp_rec.rt_cmbn_age_n_los_val
             ,p_new_val           => l_rate_cvg_result
             ,p_business_group_id => p_business_group_id
             ,p_effective_date    => NVL(g_fonm_cvg_strt_dt,NVL(p_lf_evt_ocrd_dt
                                      ,p_effective_date))
             ,p_rec               => l_rate_cvg_rec);
            --
          END IF; -- l_rate_cvg_rec.exist
          --
        END IF ; -- oipl_id for coverage
        --
        IF p_comp_rec.rt_cmbn_age_n_los_val IS NOT NULL THEN
          --
        /* Bug 5478918 */
	ben_seeddata_object.get_object(p_rec=> l_der_cvg_rec);
        if (skip_min_max_le_calc(l_der_cvg_rec.drvdcal_id,
	                         p_business_group_id,
                                 p_ptnl_ler_trtmt_cd,
                                 p_effective_date)) THEN
        --
        /* Simply return as no further calculations need to be done */
          hr_utility.set_location(l_package||' Do Nothing here.', 9877);
          null;
        --
        else
        --
          IF benutils.min_max_breach(p_min_value=> NVL(l_rate_cvg_rec.cmbnd_min_val
                                                    ,-1)
              ,p_max_value => NVL(l_rate_cvg_rec.cmbnd_max_val
                               ,99999999)
              ,p_new_value => l_rate_cvg_result
              ,p_old_value => p_comp_rec.rt_cmbn_age_n_los_val
              ,p_break     => l_break) THEN
            --
            IF no_life_event(p_lf_evt_ocrd_dt=> nvl(g_fonm_cvg_strt_dt,p_effective_date)
                    ,p_person_id      => p_person_id
                    ,p_ler_id         => l_der_cvg_rec.drvdcal_id
                    ,p_effective_date => p_effective_date)
            THEN
              --
              --
             -- IF NVL(p_ptnl_ler_trtmt_cd,'-1') = 'IGNRALL'  THEN
                --
                -- We are not creating past life events
                --
             --   NULL;
                --
             -- ELSE
                --
                create_ptl_ler
                  (p_calculate_only_mode => p_calculate_only_mode
                  ,p_ler_id              => l_der_cvg_rec.drvdcal_id
                  ,p_lf_evt_ocrd_dt      => nvl(g_fonm_cvg_strt_dt,p_effective_date)
                  ,p_person_id           => p_person_id
                  ,p_business_group_id   => p_business_group_id
                  ,p_effective_date      => p_effective_date
                  );
             -- END IF;
              --
            END IF;
          --
          END IF;
         --
	 END IF;  /* End Bug 5478918 */
         --
        END IF;
        --
        -- End of coverage
        -- Start of Premium
        --
        IF  p_oipl_id IS NOT NULL
            OR p_pl_id IS NOT NULL THEN
          --
          -- Try and find a premium
          --
          ben_derive_part_and_rate_prem.get_comb_rate(
                p_pl_id             => p_pl_id
               ,p_oipl_id           => p_oipl_id
               ,p_business_group_id => p_business_group_id
               ,p_effective_date    => NVL(g_fonm_cvg_strt_dt,NVL(p_lf_evt_ocrd_dt
                                        ,p_effective_date))
               ,p_rec               => l_rate_prem_rec);
              --
          IF l_rate_prem_rec.exist = 'Y' THEN
            --
            calculate_los
              (p_calculate_only_mode => p_calculate_only_mode
              ,p_comp_obj_tree_row   => p_comp_obj_tree_row
              ,p_empasg_row          => p_empasg_row
              ,p_benasg_row          => p_benasg_row
              ,p_pil_row             => p_pil_row
              ,p_curroipl_row        => p_curroipl_row
              ,p_curroiplip_row      => p_curroiplip_row
              ,p_person_id           => p_person_id
              ,p_business_group_id   => p_business_group_id
              ,p_pgm_id              => p_pgm_id
              ,p_pl_id               => p_pl_id
              ,p_oipl_id             => p_oipl_id
              ,p_plip_id             => p_plip_id
              ,p_ptip_id             => p_ptip_id
              ,p_oiplip_id           => p_oiplip_id
              ,p_los_fctr_id         => l_rate_prem_rec.los_fctr_id
              ,p_comp_rec            => p_comp_rec
              ,p_effective_date      => p_effective_date
              ,p_ptnl_ler_trtmt_cd   => p_ptnl_ler_trtmt_cd
              ,p_lf_evt_ocrd_dt      => p_lf_evt_ocrd_dt
              );
            --
            calculate_age(p_comp_obj_tree_row=> p_comp_obj_tree_row
             ,p_per_row           => p_per_row
             ,p_empasg_row        => p_empasg_row
             ,p_benasg_row        => p_benasg_row
             ,p_pil_row           => p_pil_row
             ,p_curroipl_row      => p_curroipl_row
             ,p_curroiplip_row    => p_curroiplip_row
             ,p_person_id         => p_person_id
             ,p_business_group_id => p_business_group_id
             ,p_pgm_id            => p_pgm_id
             ,p_pl_id             => p_pl_id
             ,p_oipl_id           => p_oipl_id
             ,p_plip_id           => p_plip_id
             ,p_ptip_id           => p_ptip_id
             ,p_oiplip_id         => p_oiplip_id
             ,p_age_fctr_id       => l_rate_prem_rec.age_fctr_id
             ,p_comp_rec          => p_comp_rec
             ,p_effective_date    => p_effective_date
             ,p_ptnl_ler_trtmt_cd => p_ptnl_ler_trtmt_cd
             ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt);
            --
            p_comp_rec.comb_rt_los            := p_comp_rec.rt_los_val;
            p_comp_rec.comb_rt_age            := p_comp_rec.rt_age_val;
            --
            l_rate_prem_result                     := p_comp_rec.rt_los_val + p_comp_rec.rt_age_val;
            --
            -- p_comp_rec.rt_cmbn_age_n_los_val  := l_rate_prem_result;
            --
            --
            ben_derive_part_and_rate_prem.get_comb_rate(
              p_pl_id             => p_pl_id
             ,p_oipl_id           => p_oipl_id
             ,p_new_val           => l_rate_prem_result
             ,p_old_val           => p_comp_rec.rt_cmbn_age_n_los_val
             ,p_business_group_id => p_business_group_id
             ,p_effective_date    => NVL(g_fonm_cvg_strt_dt,NVL(p_lf_evt_ocrd_dt
                                      ,p_effective_date))
             ,p_rec               => l_rate_prem_rec);
            --
          END IF; -- l_rate_prem_rec.exist
          --
        END IF ; -- oipl_id for premium
        --
        IF p_comp_rec.rt_cmbn_age_n_los_val IS NOT NULL THEN
          --
        /* Bug 5478918 */
	ben_seeddata_object.get_object(p_rec=> l_der_prem_rec);
        if (skip_min_max_le_calc(l_der_prem_rec.drvdcal_id,
	                         p_business_group_id,
                                 p_ptnl_ler_trtmt_cd,
                                 p_effective_date)) THEN
        --
        /* Simply return as no further calculations need to be done */
          hr_utility.set_location(l_package||' Do Nothing here.', 9877);
          null;
        --
        else
        --
          IF benutils.min_max_breach(p_min_value=> NVL(l_rate_prem_rec.cmbnd_min_val
                                                    ,-1)
              ,p_max_value => NVL(l_rate_prem_rec.cmbnd_max_val
                               ,99999999)
              ,p_new_value => l_rate_prem_result
              ,p_old_value => p_comp_rec.rt_cmbn_age_n_los_val
              ,p_break     => l_break) THEN
            --
            IF  no_life_event(p_lf_evt_ocrd_dt=> nvl(g_fonm_cvg_strt_dt,p_effective_date)
                    ,p_person_id      => p_person_id
                    ,p_ler_id         => l_der_prem_rec.drvdcal_id
                    ,p_effective_date => p_effective_date)
            THEN
              --
              --
              --IF NVL(p_ptnl_ler_trtmt_cd,'-1') = 'IGNRALL'  THEN
                --
                -- We are not creating past life events
                --
              -- NULL;
                --
              -- ELSE
                --
                create_ptl_ler
                  (p_calculate_only_mode => p_calculate_only_mode
                  ,p_ler_id              => l_der_prem_rec.drvdcal_id
                  ,p_lf_evt_ocrd_dt      => nvl(g_fonm_cvg_strt_dt,p_effective_date)
                  ,p_person_id           => p_person_id
                  ,p_business_group_id   => p_business_group_id
                  ,p_effective_date      => p_effective_date
                  );
              --END IF;
              --
            END IF;
          --
          END IF;
         --
	 END IF;  /* End Bug 5478918 */
         --
        END IF;
        --
        IF l_rate_result IS NULL and l_rate_cvg_result IS NULL and  l_rate_prem_result IS NULL THEN
            --
            p_comp_rec.rt_cmbn_age_n_los_val  := NULL;
            --hr_utility.set_location(' Step 27',10);
            --
          --
        ELSIF l_rate_result is NOT NULL THEN
            --
            --hr_utility.set_location(' Step 28',10);
            p_comp_rec.rt_cmbn_age_n_los_val := l_rate_result;
            --
          --
        ELSIF l_rate_cvg_result is NOT NULL then
            --
            --hr_utility.set_location(' Step 29',10);
            p_comp_rec.rt_cmbn_age_n_los_val := l_rate_cvg_result;
          --
        ELSIF l_rate_prem_result is NOT NULL THEN
            --
            --hr_utility.set_location(' Step 30',10);
            p_comp_rec.rt_cmbn_age_n_los_val:= l_rate_prem_result;
            --
        END IF;
      --
      END IF; --  p_comp_rec.rt_frz_comb_age_and_los_flag
    --
    END IF;
    --
   -- hr_utility.set_location('Leaving ' || l_package,10);
  --
  END calculate_comb_age_and_los;
--
  PROCEDURE percent_fulltime_min_max
    (p_calculate_only_mode in     boolean default false
    ,p_comp_obj_tree_row   IN     ben_manage_life_events.g_cache_proc_objects_rec
    ,p_curroiplip_row      IN     ben_cobj_cache.g_oiplip_inst_row
   --,p_rate_rec           IN OUT ben_derive_part_and_rate_cache.g_cache_clf_rec_obj
    ,p_comp_rec            IN OUT NOCOPY g_cache_structure
    ,p_empasg_row          IN     per_all_assignments_f%ROWTYPE
    ,p_benasg_row          IN     per_all_assignments_f%ROWTYPE
    ,p_person_id           IN     NUMBER
    ,p_pgm_id              IN     NUMBER
    ,p_pl_id               IN     NUMBER
    ,p_oipl_id             IN     NUMBER
    ,p_oiplip_id           IN     NUMBER
    ,p_plip_id             IN     NUMBER
    ,p_ptip_id             IN     NUMBER
    ,p_business_group_id   IN     NUMBER
    ,p_ler_id              IN     NUMBER
    ,p_min_value           IN     NUMBER
    ,p_max_value           IN     NUMBER
    ,p_new_value           IN     NUMBER
    ,p_old_value           IN     NUMBER
  --  ,p_uom                 IN     VARCHAR2
 --   ,p_subtract_date       IN     DATE
 --   ,p_det_cd              IN     VARCHAR2
 --   ,p_formula_id          IN     NUMBER DEFAULT NULL
    ,p_ptnl_ler_trtmt_cd   IN     VARCHAR2
    ,p_effective_date      IN     DATE
    ,p_lf_evt_ocrd_dt      IN     DATE
    --,p_comp_src_cd         IN     VARCHAR2
    --,p_bnfts_bal_id        IN     NUMBER
    )
    IS
    --
    l_package            VARCHAR2(80)        := g_package || '.percent_fulltime_min_max';
    l_break              VARCHAR2(30);
    l_det_cd             VARCHAR2(30);
    l_lf_evt_ocrd_dt     DATE;
    l_new_lf_evt_ocrd_dt DATE;
    l_start_date         DATE;
    l_rec                ben_person_object.g_person_date_info_rec;
    l_oiplip_rec         ben_cobj_cache.g_oiplip_inst_row;
    --
  BEGIN
      if g_debug then
        hr_utility.set_location('Entering percent_fulltime_min_max ', 10 );
      end if;
      /* Bug 5478918 */
        if (skip_min_max_le_calc(p_ler_id,
	                         p_business_group_id,
                                 p_ptnl_ler_trtmt_cd,
                                 p_effective_date)) THEN
        --
        /* Simply return as no further calculations need to be done */
          hr_utility.set_location(l_package||' Do Nothing here.', 9877);
          RETURN;
        end if;
      /* End Bug 5478918 */
      if g_debug then
        hr_utility.set_location('p_max_value '||p_max_value,10);
      end if;
      if g_debug then
        hr_utility.set_location('p_min_value '||p_min_value,10);
      end if;
      if g_debug then
        hr_utility.set_location('p_new_value '||p_new_value,10);
      end if;
      if g_debug then
        hr_utility.set_location('p_old_value '||p_old_value,10);
      end if;
          --
      IF benutils.min_max_breach(p_min_value=> NVL( p_min_value
                                                    ,-1)
              ,p_max_value => NVL( p_max_value
                               ,99999999)
              ,p_new_value => p_new_value
              ,p_old_value => p_old_value
              ,p_break     => l_break
              ,p_decimal_level => 'Y') THEN
            --
            -- Create potential ler for per if the min_max_breach occured
            --
            l_lf_evt_ocrd_dt  :=
              get_percent_date(p_empasg_row=> p_empasg_row
               ,p_benasg_row     => p_benasg_row
               ,p_person_id      => p_person_id
               ,p_percent        => p_new_value
               ,p_effective_date => NVL(g_fonm_cvg_strt_dt,NVL(p_lf_evt_ocrd_dt
                                     ,p_effective_date))
               ,p_min            => p_min_value
               ,p_max            => p_max_value
               ,p_break          => l_break);
            --
            IF   (  l_lf_evt_ocrd_dt < p_effective_date
               AND NVL(p_ptnl_ler_trtmt_cd
                    ,'-1') = 'IGNR' OR NVL(p_ptnl_ler_trtmt_cd,'-1') = 'IGNRALL') THEN
              --
              -- We are not creating life events in this case
              --
              NULL;
            --
            ELSE
              --
              --ben_seeddata_object.get_object(p_rec=> l_der_rec);
              --
              IF no_life_event(p_lf_evt_ocrd_dt=> l_lf_evt_ocrd_dt
                  ,p_person_id      => p_person_id
                  ,p_ler_id         => p_ler_id
                  ,p_effective_date => p_effective_date)
              THEN
                --
                --
                IF NVL(p_ptnl_ler_trtmt_cd,'-1') = 'IGNRALL'  THEN
                  --
                  -- We are not creating past life events
                  --
                  NULL;
                  --
                ELSE
                  --
                  create_ptl_ler
                    (p_calculate_only_mode => p_calculate_only_mode
                    ,p_ler_id              => p_ler_id
                    ,p_lf_evt_ocrd_dt      => l_lf_evt_ocrd_dt
                    ,p_person_id           => p_person_id
                    ,p_business_group_id   => p_business_group_id
                    ,p_effective_date      => p_effective_date
                    );
                  --
                END IF;
                --
              END IF;
            --
            END IF;
          --
          END IF;
  END percent_fulltime_min_max ;

  PROCEDURE calculate_percent_fulltime
    (p_calculate_only_mode in            boolean default false
    ,p_comp_obj_tree_row   IN            ben_manage_life_events.g_cache_proc_objects_rec
    ,p_empasg_row          IN            per_all_assignments_f%ROWTYPE
    ,p_benasg_row          IN            per_all_assignments_f%ROWTYPE
    ,p_pil_row             IN            ben_per_in_ler%ROWTYPE
    ,p_curroipl_row        IN            ben_cobj_cache.g_oipl_inst_row
    ,p_curroiplip_row      IN            ben_cobj_cache.g_oiplip_inst_row
    ,p_person_id           IN            NUMBER
    ,p_business_group_id   IN            NUMBER
    ,p_pgm_id              IN            NUMBER
    ,p_pl_id               IN            NUMBER
    ,p_oipl_id             IN            NUMBER
    ,p_plip_id             IN            NUMBER
    ,p_ptip_id             IN            NUMBER
    ,p_oiplip_id           IN            NUMBER
    ,p_ptnl_ler_trtmt_cd   IN            VARCHAR2
    ,p_comp_rec            IN OUT NOCOPY g_cache_structure
    ,p_effective_date      IN            DATE
    ,p_lf_evt_ocrd_dt      IN            DATE
    )
  IS
    --
    l_package        VARCHAR2(80)
                                 := g_package || '.calculate_percent_fulltime';
    l_elig_result    NUMBER;
    l_rate_result    NUMBER;
    l_rate_cvg_result    NUMBER;
    l_rate_prem_result   NUMBER;
    l_break          VARCHAR2(30);
    l_lf_evt_ocrd_dt DATE;
    l_elig_rec       ben_derive_part_and_rate_cache.g_cache_pff_rec_obj;
    l_rate_rec       ben_derive_part_and_rate_cache.g_cache_pff_rec_obj;
    l_rate_cvg_rec   ben_derive_part_and_rate_cache.g_cache_pff_rec_obj;
    l_rate_prem_rec  ben_derive_part_and_rate_cache.g_cache_pff_rec_obj;
    l_rec            ben_person_object.g_person_fte_info_rec;
    l_der_rec        ben_seeddata_object.g_derived_factor_info_rec;
    l_der_cvg_rec    ben_seeddata_object.g_derived_factor_info_rec;
    l_der_prem_rec   ben_seeddata_object.g_derived_factor_info_rec;
    l_ass_rec        per_all_assignments_f%ROWTYPE;
    l_rate           BOOLEAN                                         := FALSE;
    l_cvg            BOOLEAN                                         := FALSE;
    l_prem           BOOLEAN                                         := FALSE;
  --
  BEGIN
    --
    hr_utility.set_location('Entering ' || l_package,10);
--
-- Calculate PCT FT process
-- =====================
-- The sequence of operations is as follows :
-- 1) First check if freeze PCT FT flag is on in which case
--    we ignore the calculation and just return the values
-- 2) Calculate eligibility derivable factors
-- 3) Calculate rate derivable factors
-- 3) Sum assignment FTE information
-- 4) Perform rounding
-- 5) Test for min/max breach
-- 6) If a breach did occur then create a ptl_ler_for_per.
--
    IF bitand(p_comp_obj_tree_row.flag_bit_val
        ,ben_manage_life_events.g_pft_flag) <> 0 THEN
      --
     -- hr_utility.set_location('PFT for ELIG',10);
      IF p_comp_rec.frz_pct_fl_tm_flag = 'Y' THEN
        --
        -- No calulation required just return the frozen value
        --
        NULL;
      --
      ELSE
        --
        ben_derive_part_and_rate_cache.get_pct_elig(p_pgm_id=> p_pgm_id
         ,p_pl_id             => p_pl_id
         ,p_oipl_id           => p_oipl_id
         ,p_plip_id           => p_plip_id
         ,p_ptip_id           => p_ptip_id
         ,p_business_group_id => p_business_group_id
         ,p_effective_date    => NVL(g_fonm_cvg_strt_dt,NVL(p_lf_evt_ocrd_dt
                                  ,p_effective_date))
         ,p_rec               => l_elig_rec);
        --
        IF l_elig_rec.exist = 'Y' THEN
          --
          IF p_empasg_row.assignment_id IS NULL THEN
            --
            l_ass_rec  := p_benasg_row;
          --
          ELSE
            --
            l_ass_rec  := p_empasg_row;
          --
          END IF;
          --
          -- Check if any assignment exists
          --
          IF l_ass_rec.assignment_id IS NOT NULL THEN
            --
            ben_person_object.get_object(p_assignment_id=> l_ass_rec.assignment_id
             ,p_rec           => l_rec);
            --
            IF l_elig_rec.use_prmry_asnt_only_flag = 'Y' THEN
              --
              -- Get percent fulltime value for persons primary assignment
              --
              l_elig_result  := l_rec.fte;
            --
            ELSIF l_elig_rec.use_sum_of_all_asnts_flag = 'Y' THEN
              --
              -- Get percent fulltime figure for all persons assignments
              --
              l_elig_result  := l_rec.total_fte;
            --
            END IF;
            --
            IF    l_elig_rec.rndg_cd IS NOT NULL
               OR l_elig_rec.rndg_rl IS NOT NULL THEN
              --
              l_elig_result  :=
                benutils.do_rounding(p_rounding_cd=> l_elig_rec.rndg_cd
                 ,p_rounding_rl    => l_elig_rec.rndg_rl
                 ,p_value          => l_elig_result
                 ,p_effective_date => NVL(p_lf_evt_ocrd_dt
                                       ,p_effective_date));
            --
            END IF;
            --
         /* Bug 5478918 */
          --
          ben_seeddata_object.get_object(p_rec=> l_der_rec);
	  if (skip_min_max_le_calc(l_der_rec.drvdtpf_id,
	                           p_business_group_id,
                                   p_ptnl_ler_trtmt_cd,
                                   p_effective_date)) THEN
            --
            /* Simply return as no further calculations need to be done */
            hr_utility.set_location(l_package||' Do Nothing here.', 9877);
            null;
            --
          else
	    --
            ben_derive_part_and_rate_cache.get_pct_elig(p_pgm_id=> p_pgm_id
             ,p_pl_id             => p_pl_id
             ,p_oipl_id           => p_oipl_id
             ,p_plip_id           => p_plip_id
             ,p_ptip_id           => p_ptip_id
             ,p_new_val           => l_elig_result
             ,p_old_val           => p_comp_rec.pct_fl_tm_val
             ,p_business_group_id => p_business_group_id
             ,p_effective_date    => nvl(g_fonm_cvg_strt_dt,NVL(p_lf_evt_ocrd_dt
                                      ,p_effective_date))
             ,p_rec               => l_elig_rec);
        --
            IF benutils.min_max_breach(p_min_value=> NVL(l_elig_rec.mn_pct_val
                                                      ,-1)
                ,p_max_value => NVL(l_elig_rec.mx_pct_val
                                 ,99999999)
                ,p_new_value => l_elig_result
                ,p_old_value => p_comp_rec.pct_fl_tm_val
                ,p_break     => l_break
                ,p_decimal_level => 'Y') THEN
              --
              l_lf_evt_ocrd_dt  :=
                get_percent_date(p_empasg_row=> p_empasg_row
                 ,p_benasg_row     => p_benasg_row
                 ,p_person_id      => p_person_id
                 ,p_percent        => l_elig_result
                 ,p_effective_date => NVL(g_fonm_cvg_strt_dt,NVL(p_lf_evt_ocrd_dt
                                       ,p_effective_date))
                 ,p_min            => l_elig_rec.mn_pct_val
                 ,p_max            => l_elig_rec.mx_pct_val
                 ,p_break          => l_break);
              --
              IF   (  l_lf_evt_ocrd_dt < p_effective_date
                 AND NVL(p_ptnl_ler_trtmt_cd,'-1') = 'IGNR') THEN
                --
                -- We are not creating life events in this case
                --
                NULL;
              --
              ELSE
                --
                IF no_life_event(p_lf_evt_ocrd_dt=> l_lf_evt_ocrd_dt
                    ,p_person_id      => p_person_id
                    ,p_ler_id         => l_der_rec.drvdtpf_id
                    ,p_effective_date => p_effective_date)
                THEN
                  --
                  create_ptl_ler
                    (p_calculate_only_mode => p_calculate_only_mode
                    ,p_ler_id              => l_der_rec.drvdtpf_id
                    ,p_lf_evt_ocrd_dt      => l_lf_evt_ocrd_dt
                    ,p_person_id           => p_person_id
                    ,p_business_group_id   => p_business_group_id
                    ,p_effective_date      => p_effective_date
                    );
                  --
                END IF;
              --
              END IF;
            --
            END IF;
            --
          END IF;   /* End Bug 5478918 */
	  --
            p_comp_rec.pct_fl_tm_val  := l_elig_result;
          --
          ELSE
            --
            p_comp_rec.pct_fl_tm_val  := NULL;
          --
          END IF;
        --
        ELSE
          --
          p_comp_rec.pct_fl_tm_val  := NULL;
        --
        END IF;
      --
      END IF;
    --
    END IF;
    --
    IF    bitand(p_comp_obj_tree_row.flag_bit_val
           ,ben_manage_life_events.g_pft_rt_flag) <> 0
       OR     p_oiplip_id IS NOT NULL
          AND bitand(p_comp_obj_tree_row.oiplip_flag_bit_val
               ,ben_manage_life_events.g_pft_rt_flag) <> 0 THEN
      --
     -- hr_utility.set_location('PFT for RT',10);
      IF p_comp_rec.rt_frz_pct_fl_tm_flag = 'Y' THEN
        --
        -- No calulation required just return the frozen value
        --
        NULL;
      --
      ELSE
        --
        ben_derive_part_and_rate_cache.get_pct_rate(p_pgm_id=> p_pgm_id
         ,p_pl_id             => p_pl_id
         ,p_oipl_id           => p_oipl_id
         ,p_plip_id           => p_plip_id
         ,p_ptip_id           => p_ptip_id
         ,p_oiplip_id         => p_oiplip_id
         ,p_business_group_id => p_business_group_id
         ,p_effective_date    => nvl(g_fonm_cvg_strt_dt,NVL(p_lf_evt_ocrd_dt
                                  ,p_effective_date))
         ,p_rec               => l_rate_rec);
        --
        IF l_rate_rec.exist = 'Y' THEN
          --
          l_rate  := TRUE;
          --
          IF p_empasg_row.assignment_id IS NULL THEN
            --
            l_ass_rec  := p_benasg_row;
          --
          ELSE
            --
            l_ass_rec  := p_empasg_row;
          --
          END IF;
          --
          ben_person_object.get_object(p_assignment_id=> l_ass_rec.assignment_id
           ,p_rec           => l_rec);

          IF l_rate_rec.use_prmry_asnt_only_flag = 'Y' THEN
            --
            -- Get percent fulltime value for persons primary assignment
            --
            l_rate_result  := l_rec.fte;
          --
          ELSIF l_rate_rec.use_sum_of_all_asnts_flag = 'Y' THEN
            --
            -- Get percent fulltime figure for all persons assignments
            --
            l_rate_result  := l_rec.total_fte;
          --
          END IF;
          --
          IF    l_rate_rec.rndg_cd IS NOT NULL
             OR l_rate_rec.rndg_rl IS NOT NULL THEN
            --
            l_rate_result  :=
              benutils.do_rounding(p_rounding_cd=> l_rate_rec.rndg_cd
               ,p_rounding_rl    => l_rate_rec.rndg_rl
               ,p_value          => l_rate_result
               ,p_effective_date => NVL(p_lf_evt_ocrd_dt
                                     ,p_effective_date));
          --
          END IF;
          --
          IF l_rate_result is not null THEN
            --
            ben_derive_part_and_rate_cache.get_pct_rate(p_pgm_id=> p_pgm_id
             ,p_pl_id             => p_pl_id
             ,p_oipl_id           => p_oipl_id
             ,p_plip_id           => p_plip_id
             ,p_ptip_id           => p_ptip_id
             ,p_oiplip_id         => p_oiplip_id
             ,p_new_val           => l_rate_result
             ,p_old_val           => p_comp_rec.rt_pct_fl_tm_val
             ,p_business_group_id => p_business_group_id
             ,p_effective_date    => nvl(g_fonm_cvg_strt_dt,NVL(p_lf_evt_ocrd_dt
                                      ,p_effective_date))
             ,p_rec               => l_rate_rec);
            --
            ben_seeddata_object.get_object(p_rec=> l_der_rec);
            --
            percent_fulltime_min_max
                   (p_calculate_only_mode =>p_calculate_only_mode
                   ,p_comp_obj_tree_row   =>p_comp_obj_tree_row
                   ,p_curroiplip_row      =>p_curroiplip_row
                   ,p_comp_rec            =>p_comp_rec
                   ,p_empasg_row          =>p_empasg_row
                   ,p_benasg_row          =>p_benasg_row
                   ,p_person_id           =>p_person_id
                   ,p_pgm_id              =>p_pgm_id
                   ,p_pl_id               =>p_pl_id
                   ,p_oipl_id             =>p_oipl_id
                   ,p_oiplip_id           =>p_oiplip_id
                   ,p_plip_id             =>p_plip_id
                   ,p_ptip_id             =>p_ptip_id
                   ,p_business_group_id   =>p_business_group_id
                   ,p_ler_id              =>l_der_rec.drvdtpf_id
                   ,p_min_value           =>l_rate_rec.mn_pct_val
                   ,p_max_value           =>l_rate_rec.mx_pct_val
                   ,p_new_value           =>l_rate_result
                   ,p_old_value           =>p_comp_rec.rt_pct_fl_tm_val
                   ,p_ptnl_ler_trtmt_cd   =>p_ptnl_ler_trtmt_cd
                   ,p_effective_date      =>p_effective_date
                   ,p_lf_evt_ocrd_dt      =>p_lf_evt_ocrd_dt
                  ) ;
          END IF; -- l_rate_result
          --
        END IF ; -- l_rate_rec.exist
        --
        -- Try and find a coverage first
        --
        IF    p_oipl_id IS NOT NULL
          OR p_pl_id IS NOT NULL
          OR p_plip_id IS NOT NULL THEN
          --
          ben_derive_part_and_rate_cvg.get_pct_rate(p_pl_id=> p_pl_id
             ,p_oipl_id           => p_oipl_id
             ,p_plip_id           => p_plip_id
             ,p_business_group_id => p_business_group_id
             ,p_effective_date    => nvl(g_fonm_cvg_strt_dt,NVL(p_lf_evt_ocrd_dt
                                      ,p_effective_date))
             ,p_rec               => l_rate_cvg_rec);
            --
          IF l_rate_cvg_rec.exist = 'Y' THEN
            --
            l_cvg  := TRUE;
            --
            IF p_empasg_row.assignment_id IS NULL THEN
              --
              l_ass_rec  := p_benasg_row;
              --
            ELSE
              --
              l_ass_rec  := p_empasg_row;
              --
            END IF;
            --
            ben_person_object.get_object(p_assignment_id=> l_ass_rec.assignment_id
                                       ,p_rec           => l_rec);

            IF l_rate_cvg_rec.use_prmry_asnt_only_flag = 'Y' THEN
              --
              -- Get percent fulltime value for persons primary assignment
              --
              l_rate_cvg_result  := l_rec.fte;
              --
            ELSIF l_rate_rec.use_sum_of_all_asnts_flag = 'Y' THEN
              --
              -- Get percent fulltime figure for all persons assignments
              --
              l_rate_cvg_result  := l_rec.total_fte;
              --
            END IF;
            --
            IF    l_rate_cvg_rec.rndg_cd IS NOT NULL
               OR l_rate_cvg_rec.rndg_rl IS NOT NULL THEN
              --
              l_rate_cvg_result  :=
                benutils.do_rounding(p_rounding_cd=> l_rate_cvg_rec.rndg_cd
                 ,p_rounding_rl    => l_rate_cvg_rec.rndg_rl
                 ,p_value          => l_rate_cvg_result
                 ,p_effective_date => NVL(p_lf_evt_ocrd_dt
                                       ,p_effective_date));
              --
            END IF; -- l_rate_cvg_rec.rndg_cd
            --
            IF l_rate_cvg_result is not null THEN
              --
              ben_derive_part_and_rate_cvg.get_pct_rate(p_pl_id=> p_pl_id
               ,p_oipl_id           => p_oipl_id
               ,p_plip_id           => p_plip_id
               ,p_business_group_id => p_business_group_id
               ,p_effective_date    => nvl(g_fonm_cvg_strt_dt,NVL(p_lf_evt_ocrd_dt
                                        ,p_effective_date))
               ,p_rec               => l_rate_cvg_rec);
              --
              ben_seeddata_object.get_object(p_rec=> l_der_cvg_rec);
              --
              percent_fulltime_min_max
                   (p_calculate_only_mode =>p_calculate_only_mode
                   ,p_comp_obj_tree_row   =>p_comp_obj_tree_row
                   ,p_curroiplip_row      =>p_curroiplip_row
                   ,p_comp_rec            =>p_comp_rec
                   ,p_empasg_row          =>p_empasg_row
                   ,p_benasg_row          =>p_benasg_row
                   ,p_person_id           =>p_person_id
                   ,p_pgm_id              =>p_pgm_id
                   ,p_pl_id               =>p_pl_id
                   ,p_oipl_id             =>p_oipl_id
                   ,p_oiplip_id           =>p_oiplip_id
                   ,p_plip_id             =>p_plip_id
                   ,p_ptip_id             =>p_ptip_id
                   ,p_business_group_id   =>p_business_group_id
                   ,p_ler_id              =>l_der_cvg_rec.drvdtpf_id
                   ,p_min_value           =>l_rate_cvg_rec.mn_pct_val
                   ,p_max_value           =>l_rate_cvg_rec.mx_pct_val
                   ,p_new_value           =>l_rate_cvg_result
                   ,p_old_value           =>p_comp_rec.rt_pct_fl_tm_val
                   ,p_ptnl_ler_trtmt_cd   =>p_ptnl_ler_trtmt_cd
                   ,p_effective_date      =>p_effective_date
                   ,p_lf_evt_ocrd_dt      =>p_lf_evt_ocrd_dt
                  ) ;
              --
            END IF; --l_rate_cvg_result
            --
          END IF; -- l_rate_cvg_rec.exist
          --
        END IF; --p_oipl_id coverage
        -- Now try Premiums
        --
        if g_debug then
          hr_utility.set_location('Entering into premium process ' , 20);
        end if;
        --
        IF  p_oipl_id IS NOT NULL
            OR p_pl_id IS NOT NULL THEN
          --
          -- Try and find a premium
          --
          ben_derive_part_and_rate_prem.get_pct_rate(
                p_pl_id             => p_pl_id
               ,p_oipl_id           => p_oipl_id
               ,p_business_group_id => p_business_group_id
               ,p_effective_date    =>  nvl(g_fonm_cvg_strt_dt,NVL(p_lf_evt_ocrd_dt
                                        ,p_effective_date))
               ,p_rec               => l_rate_prem_rec);
              --
          IF l_rate_prem_rec.exist = 'Y' THEN
            --
            l_prem  := TRUE;
            --
            IF p_empasg_row.assignment_id IS NULL THEN
              --
              l_ass_rec  := p_benasg_row;
              --
            ELSE
              --
              l_ass_rec  := p_empasg_row;
              --
            END IF;
            --

            if g_debug then
              hr_utility.set_location(' l_ass_rec.assignment_id '||l_ass_rec.assignment_id, 30);
            end if;
            ben_person_object.get_object(p_assignment_id=> l_ass_rec.assignment_id
                                       ,p_rec           => l_rec);

            IF l_rate_prem_rec.use_prmry_asnt_only_flag = 'Y' THEN
              --
              -- Get percent fulltime value for persons primary assignment
              --
              if g_debug then
                hr_utility.set_location(' l_rec.fte '||l_rec.fte ,40);
              end if;
              l_rate_prem_result  := l_rec.fte;
              --
            ELSIF l_rate_prem_rec.use_sum_of_all_asnts_flag = 'Y' THEN
              --
              -- Get percent fulltime figure for all persons assignments
              --
              if g_debug then
                hr_utility.set_location(' l_rec.total_fte '||l_rec.total_fte , 50);
              end if;
              l_rate_prem_result  := l_rec.total_fte;
              --
            END IF;
            --
            IF    l_rate_prem_rec.rndg_cd IS NOT NULL
               OR l_rate_prem_rec.rndg_rl IS NOT NULL THEN
              --
              l_rate_prem_result  :=
                benutils.do_rounding(p_rounding_cd=> l_rate_prem_rec.rndg_cd
                 ,p_rounding_rl    => l_rate_prem_rec.rndg_rl
                 ,p_value          => l_rate_prem_result
                 ,p_effective_date => NVL(p_lf_evt_ocrd_dt
                                       ,p_effective_date));
              --
            END IF; -- l_rate_prem_rec.rndg_cd
            --
            IF l_rate_prem_result is not null THEN
              --
              ben_derive_part_and_rate_prem.get_pct_rate(
                p_pl_id             => p_pl_id
               ,p_oipl_id           => p_oipl_id
               ,p_new_val           => l_rate_prem_result
               ,p_old_val           => p_comp_rec.rt_pct_fl_tm_val
               ,p_business_group_id => p_business_group_id
               ,p_effective_date    =>  nvl(g_fonm_cvg_strt_dt,NVL(p_lf_evt_ocrd_dt
                                        ,p_effective_date))
               ,p_rec               => l_rate_prem_rec);
              --
              ben_seeddata_object.get_object(p_rec=> l_der_prem_rec);
              --
              percent_fulltime_min_max
                   (p_calculate_only_mode =>p_calculate_only_mode
                   ,p_comp_obj_tree_row   =>p_comp_obj_tree_row
                   ,p_curroiplip_row      =>p_curroiplip_row
                   ,p_comp_rec            =>p_comp_rec
                   ,p_empasg_row          =>p_empasg_row
                   ,p_benasg_row          =>p_benasg_row
                   ,p_person_id           =>p_person_id
                   ,p_pgm_id              =>p_pgm_id
                   ,p_pl_id               =>p_pl_id
                   ,p_oipl_id             =>p_oipl_id
                   ,p_oiplip_id           =>p_oiplip_id
                   ,p_plip_id             =>p_plip_id
                   ,p_ptip_id             =>p_ptip_id
                   ,p_business_group_id   =>p_business_group_id
                   ,p_ler_id              =>l_der_prem_rec.drvdtpf_id
                   ,p_min_value           =>l_rate_prem_rec.mn_pct_val
                   ,p_max_value           =>l_rate_prem_rec.mx_pct_val
                   ,p_new_value           =>l_rate_prem_result
                   ,p_old_value           =>p_comp_rec.rt_pct_fl_tm_val
                   ,p_ptnl_ler_trtmt_cd   =>p_ptnl_ler_trtmt_cd
                   ,p_effective_date      =>p_effective_date
                   ,p_lf_evt_ocrd_dt      =>p_lf_evt_ocrd_dt
                  ) ;
              --
            END IF; -- l_rate_prem_result
            --
          END IF; -- l_rate_prem_rec.exist
          --
        END IF; -- p_oipl_id prem
        --
        IF l_rate_result IS NULL and l_rate_cvg_result IS NULL and  l_rate_prem_result IS NULL THEN
          --
          p_comp_rec.rt_pct_fl_tm_val  := NULL;
          --
        ELSIF l_rate_result is NOT NULL THEN
          if g_debug then
            hr_utility.set_location(' Step 28',10);
          end if;
          p_comp_rec.rt_pct_fl_tm_val  := l_rate_result;
          --
        ELSIF l_rate_cvg_result is NOT NULL then
          --
          p_comp_rec.rt_pct_fl_tm_val  := l_rate_cvg_result;
          if g_debug then
            hr_utility.set_location(' Step 29',10);
          end if;
        ELSIF l_rate_prem_result is NOT NULL THEN
          --
          p_comp_rec.rt_pct_fl_tm_val  := l_rate_prem_result;
          if g_debug then
            hr_utility.set_location(' Step 30',10);
          end if;
        END IF;
        --
      END IF;
      --
    END IF;
    --

    -- p_comp_rec.rt_pct_fl_tm_val  := l_rate_result ;

    if g_debug then
      hr_utility.set_location('Leaving ' || l_package,10);
    end if;
    --
  END calculate_percent_fulltime;
--
  PROCEDURE hours_worked_min_max
    (p_calculate_only_mode in     boolean default false
    ,p_comp_obj_tree_row   IN     ben_manage_life_events.g_cache_proc_objects_rec
    ,p_curroiplip_row      IN     ben_cobj_cache.g_oiplip_inst_row
   --,p_rate_rec           IN OUT ben_derive_part_and_rate_cache.g_cache_clf_rec_obj
    ,p_comp_rec            IN OUT NOCOPY g_cache_structure
    ,p_empasg_row          IN     per_all_assignments_f%ROWTYPE
    ,p_benasg_row          IN     per_all_assignments_f%ROWTYPE
    ,p_person_id           IN     NUMBER
    ,p_pgm_id              IN     NUMBER
    ,p_pl_id               IN     NUMBER
    ,p_oipl_id             IN     NUMBER
    ,p_oiplip_id           IN     NUMBER
    ,p_plip_id             IN     NUMBER
    ,p_ptip_id             IN     NUMBER
    ,p_business_group_id   IN     NUMBER
    ,p_ler_id              IN     NUMBER
    ,p_min_value           IN     NUMBER
    ,p_max_value           IN     NUMBER
    ,p_new_value           IN     NUMBER
    ,p_old_value           IN     NUMBER
  --  ,p_uom                 IN     VARCHAR2
    ,p_subtract_date       IN     DATE
    ,p_det_cd              IN     VARCHAR2
    ,p_formula_id          IN     NUMBER DEFAULT NULL
    ,p_ptnl_ler_trtmt_cd   IN     VARCHAR2
    ,p_effective_date      IN     DATE
    ,p_lf_evt_ocrd_dt      IN     DATE
    ,p_hrs_src_cd          IN     VARCHAR2
    ,p_bnfts_bal_id        IN     NUMBER )

  IS
    --
    l_package            VARCHAR2(80)        := g_package || '.hours_worked_min_max';
    l_break              VARCHAR2(30);
    l_det_cd             VARCHAR2(30);
    l_lf_evt_ocrd_dt     DATE;
    l_new_lf_evt_ocrd_dt DATE;
    l_start_date         DATE;
    l_rec                ben_person_object.g_person_date_info_rec;
    l_oiplip_rec         ben_cobj_cache.g_oiplip_inst_row;
    --
  BEGIN
      hr_utility.set_location('Entering hours_worked_min_max ', 10 );
      /* Bug 5478918 */
        if (skip_min_max_le_calc(p_ler_id,
	                         p_business_group_id,
                                 p_ptnl_ler_trtmt_cd,
                                 p_effective_date)) THEN
        --
        /* Simply return as no further calculations need to be done */
          hr_utility.set_location(l_package||' Do Nothing here.', 9877);
          RETURN;
        end if;
	/* End Bug 5478918 */
      hr_utility.set_location('p_max_value '||p_max_value,10);
      hr_utility.set_location('p_min_value '||p_min_value,10);
      hr_utility.set_location('p_new_value '||p_new_value,10);
      hr_utility.set_location('p_old_value '||p_old_value,10);
            --
            IF benutils.min_max_breach(p_min_value=> NVL(p_min_value
                                                      ,-1)
                ,p_max_value => NVL(p_max_value
                                 ,99999999)
                ,p_new_value => p_new_value
                ,p_old_value => nvl(p_old_value,0)
                ,p_break     => l_break) THEN
              --
              -- Derive life event occured date based on the value of l_break
              -- Bug 2145966 added Rule
              IF p_hrs_src_cd = 'BNFTBALTYP' OR p_hrs_src_cd = 'RL'  THEN
                --
                IF p_hrs_src_cd = 'BNFTBALTYP' THEN
                  --
                  l_lf_evt_ocrd_dt  :=
                    get_balance_date(p_effective_date=> NVL(g_fonm_cvg_strt_dt,NVL(p_lf_evt_ocrd_dt
                                                         ,p_effective_date))
                     ,p_bnfts_bal_id   => p_bnfts_bal_id
                     ,p_person_id      => p_person_id
                     ,p_min            => p_min_value
                     ,p_max            => p_max_value
                     ,p_break          => l_break);
                  --
                ELSE -- For Rulew
                  --
                  l_lf_evt_ocrd_dt := NVL(p_lf_evt_ocrd_dt,p_effective_date);
                  --
                END IF;
                  -- Reapply calculated life event occured date
                  --
                IF p_det_cd <> 'AED' THEN
                  --
                  ben_determine_date.main(p_date_cd=> p_det_cd
                   ,p_formula_id        => p_formula_id
                   ,p_person_id         => p_person_id
                   ,p_bnfts_bal_id      => p_bnfts_bal_id
                   ,p_pgm_id            => NVL(p_pgm_id
                                            ,p_comp_obj_tree_row.par_pgm_id)
                   ,p_pl_id             => p_pl_id
                   ,p_oipl_id           => NVL(p_oipl_id
                                            ,l_oiplip_rec.oipl_id)
                   ,p_business_group_id => p_business_group_id
                   ,p_returned_date     => l_new_lf_evt_ocrd_dt
                   ,p_lf_evt_ocrd_dt    => l_lf_evt_ocrd_dt
                   ,p_effective_date    => l_lf_evt_ocrd_dt);
                  --
                  -- The derived life event occured date must be greater than the
                  -- life event occured date as otherwise in reality a boundary
                  -- has not been passed.
                  -- This can only happen if the det_cd is one of the following :
                  -- AFDCPPY = As of first day of current program or plan year
                  -- APOCT1 = As of previous october 1st
                  -- AFDCM = As of first day of the current month
                  --
                  IF     l_new_lf_evt_ocrd_dt < l_lf_evt_ocrd_dt
                     AND p_det_cd  IN (
                                                        'AFDCPPY'
                                                       ,'APOCT1'
                                                       ,'AFDCM') THEN
                    --
                    -- These are special cases where we need to rederive the LED
                    -- so that we are actually still passing the correct boundary
                    --
                    l_det_cd := p_det_cd ;
                    --
                    IF p_det_cd = 'APOCT1' THEN
                      --
                      l_lf_evt_ocrd_dt  := ADD_MONTHS(l_lf_evt_ocrd_dt
                                            ,12);
                    --
                    ELSIF p_det_cd = 'AFDCM' THEN
                      --
                      -- l_lf_evt_ocrd_dt  := ADD_MONTHS(l_lf_evt_ocrd_dt ,1);
                      -- Bug 1927010. Commented the above manipulation
                      null ;
                      --
                    ELSIF p_det_cd = 'AFDCPPY' THEN
                      --
                      l_det_cd  := 'AFDFPPY';
                    --
                    END IF;
                    --
                    -- Reapply logic back to determination of date routine.
                    --
                    ben_determine_date.main(p_date_cd=> l_det_cd
                     ,p_bnfts_bal_id      => p_bnfts_bal_id
                     ,p_person_id         => p_person_id
                     ,p_pgm_id            => NVL(p_pgm_id
                                              ,p_comp_obj_tree_row.par_pgm_id)
                     ,p_pl_id             => p_pl_id
                     ,p_oipl_id           => NVL(p_oipl_id
                                              ,l_oiplip_rec.oipl_id)
                     ,p_business_group_id => p_business_group_id
                     ,p_returned_date     => l_new_lf_evt_ocrd_dt
                     ,p_lf_evt_ocrd_dt    => l_lf_evt_ocrd_dt
                     ,p_effective_date    => l_lf_evt_ocrd_dt);
                  --
                  END IF;
                  --
                  l_lf_evt_ocrd_dt  := l_new_lf_evt_ocrd_dt;
                --
                END IF;
              --
              ELSIF p_hrs_src_cd = 'BALTYP' THEN
                --
                l_lf_evt_ocrd_dt  := p_effective_date;
              --
              END IF;
              --
              -- Life event occured date must be less than the minimum
              -- assignment effective start date
              --
              ben_person_object.get_object(p_person_id=> p_person_id
               ,p_rec       => l_rec);
              --
              IF l_lf_evt_ocrd_dt >= l_rec.min_ass_effective_start_date THEN
                --
                IF   (  l_lf_evt_ocrd_dt < p_effective_date
                   AND NVL(p_ptnl_ler_trtmt_cd
                        ,'-1') = 'IGNR' OR NVL(p_ptnl_ler_trtmt_cd,'-1') = 'IGNRALL') THEN
                  --
                  -- We do not create past life events
                  --
                  RETURN ;
                --
                END IF;
                --
                hr_utility.set_location('Got the dates. Now creating the LE',10);
                --
                IF no_life_event(p_lf_evt_ocrd_dt=> l_lf_evt_ocrd_dt
                      ,p_person_id      => p_person_id
                      ,p_ler_id         => p_ler_id
                      ,p_effective_date => p_effective_date)
                THEN
                    --
                    create_ptl_ler
                      (p_calculate_only_mode => p_calculate_only_mode
                      ,p_ler_id              => p_ler_id
                      ,p_lf_evt_ocrd_dt      => l_lf_evt_ocrd_dt
                      ,p_person_id           => p_person_id
                      ,p_business_group_id   => p_business_group_id
                      ,p_effective_date      => p_effective_date
                      );
                    --
                END IF;  -- no_life_event
                  --
              END IF; -- l_lf_evt_ocrd_dt >= l_rec.min_ass_effective_start_date
              --
            END IF; --  benutils.min_max_breach
            --
  END hours_worked_min_max ;
  --
  PROCEDURE calculate_hours_worked
    (p_calculate_only_mode in            boolean default false
    ,p_comp_obj_tree_row   IN            ben_manage_life_events.g_cache_proc_objects_rec
    ,p_empasg_row          IN            per_all_assignments_f%ROWTYPE
    ,p_benasg_row          IN            per_all_assignments_f%ROWTYPE
    ,p_pil_row             IN            ben_per_in_ler%ROWTYPE
    ,p_curroipl_row        IN            ben_cobj_cache.g_oipl_inst_row
    ,p_curroiplip_row      IN            ben_cobj_cache.g_oiplip_inst_row
    ,p_person_id           IN            NUMBER
    ,p_business_group_id   IN            NUMBER
    ,p_pgm_id              IN            NUMBER
    ,p_pl_id               IN            NUMBER
    ,p_oipl_id             IN            NUMBER
    ,p_plip_id             IN            NUMBER
    ,p_ptip_id             IN            NUMBER
    ,p_oiplip_id           IN            NUMBER
    ,p_ptnl_ler_trtmt_cd   IN            VARCHAR2
    ,p_comp_rec            IN OUT NOCOPY g_cache_structure
    ,p_effective_date      IN            DATE
    ,p_lf_evt_ocrd_dt      IN            DATE
    )
  IS
    --
    l_package            VARCHAR2(80)
                                     := g_package || '.calculate_hours_worked';
    l_break              VARCHAR2(30);
    l_elig_result        NUMBER;
    l_rate_result        NUMBER;
    l_rate_cvg_result NUMBER;
    l_rate_prem_result NUMBER;
    l_lf_evt_ocrd_dt     DATE;
    l_new_lf_evt_ocrd_dt DATE;
    l_start_date         DATE;
    l_subtract_date      DATE;
    l_ok                 BOOLEAN;
    l_elig_rec           ben_derive_part_and_rate_cache.g_cache_hwf_rec_obj;
    l_rate_rec           ben_derive_part_and_rate_cache.g_cache_hwf_rec_obj;
    l_rate_cvg_rec       ben_derive_part_and_rate_cache.g_cache_hwf_rec_obj;
    l_rate_prem_rec      ben_derive_part_and_rate_cache.g_cache_hwf_rec_obj;
    l_rec                ben_person_object.g_person_date_info_rec;
    l_der_rec            ben_seeddata_object.g_derived_factor_info_rec;
    l_der_cvg_rec        ben_seeddata_object.g_derived_factor_info_rec;
    l_der_prem_rec       ben_seeddata_object.g_derived_factor_info_rec;
    l_dummy_date         DATE;
    l_rate               BOOLEAN                                     := FALSE;
    l_cvg                BOOLEAN                                     := FALSE;
    l_prem               BOOLEAN                                     := FALSE;
    l_oiplip_rec         ben_cobj_cache.g_oiplip_inst_row;
  --
  BEGIN
    --
    if g_debug then
      hr_utility.set_location('Entering ' || l_package,10);
    end if;
--
-- Calculate HRS WKD process
-- =========================
-- 1) First check if freeze HRS WKD flag is on in which case
--    we ignore the calculation and just return the frozen values
-- 2) Calculate eligibility derivable factors
-- 3) Calculate rate derivable factors
-- 3) Perform rounding
-- 4) Test for min/max breach
-- 5) If a breach did occur then create a ptl_ler_for_per.
--
    IF bitand(p_comp_obj_tree_row.flag_bit_val
        ,ben_manage_life_events.g_hrw_flag) <> 0 THEN
      --
     -- hr_utility.set_location('HRW for ELIG',10);
      IF p_comp_rec.frz_hrs_wkd_flag = 'Y' THEN
        --
        -- No calulation required just return the frozen value
        --
        NULL;
      --
      ELSE
        --
        ben_derive_part_and_rate_cache.get_hours_elig(p_pgm_id=> p_pgm_id
         ,p_pl_id             => p_pl_id
         ,p_oipl_id           => p_oipl_id
         ,p_plip_id           => p_plip_id
         ,p_ptip_id           => p_ptip_id
         ,p_business_group_id => p_business_group_id
         ,p_effective_date    => nvl(g_fonm_cvg_strt_dt,NVL(p_lf_evt_ocrd_dt
                                  ,p_effective_date))
         ,p_rec               => l_elig_rec);
        --
        l_ok  := TRUE;
        --
        IF     l_elig_rec.exist = 'Y'
           AND NVL(l_elig_rec.once_r_cntug_cd
                ,'-1') = 'ONCE'
           AND NVL(p_comp_rec.once_r_cntug_cd
                ,'-1') = 'ONCE'
           AND p_comp_rec.elig_flag = 'Y' THEN
          --
          -- In this case we do not have to derive the hours worked as the
          -- eligibility has been met, just return the frozen values and
          -- ignore the business rule check for the eligbility profile
          --
          NULL;
        --
        ELSIF l_elig_rec.exist = 'Y' THEN
          --
          if g_debug then
            hr_utility.set_location(' l_elig_rec.hrs_wkd_calc_rl '||l_elig_rec.hrs_wkd_calc_rl , 99);
          end if;
          --
          IF l_elig_rec.hrs_wkd_calc_rl IS NOT NULL THEN
            --
            if g_debug then
              hr_utility.set_location(' l_elig_rec.hrs_wkd_calc_rl '||l_elig_rec.hrs_wkd_calc_rl , 99);
            end if;
            --
            ben_determine_date.main(p_date_cd=> l_elig_rec.hrs_wkd_det_cd
             ,p_formula_id        => l_elig_rec.hrs_wkd_calc_rl
             ,p_person_id         => p_person_id
             ,p_pgm_id            => NVL(p_pgm_id
                                      ,p_comp_obj_tree_row.par_pgm_id)
             ,p_bnfts_bal_id      => l_elig_rec.bnfts_bal_id
             ,p_pl_id             => p_pl_id
             ,p_oipl_id           => p_oipl_id
             ,p_business_group_id => p_business_group_id
             ,p_returned_date     => l_start_date
             ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
             ,p_effective_date    => NVL(p_lf_evt_ocrd_dt
                                      ,p_effective_date)
             ,p_fonm_cvg_strt_dt  => g_fonm_cvg_strt_dt );
            --
            if g_debug then
              hr_utility.set_location(' l_start_date '||l_start_date ,99);
            end if;
            --
            run_rule(p_formula_id => l_elig_rec.hrs_wkd_calc_rl
             ,p_empasg_row        => p_empasg_row
             ,p_benasg_row        => p_benasg_row
             ,p_pil_row           => p_pil_row
             ,p_curroipl_row      => p_curroipl_row
             ,p_curroiplip_row    => p_curroiplip_row
             ,p_effective_date    => l_start_date
             ,p_lf_evt_ocrd_dt    => l_start_date
             ,p_business_group_id => p_business_group_id
             ,p_person_id         => p_person_id
             ,p_pgm_id            => p_pgm_id
             ,p_pl_id             => p_pl_id
             ,p_oipl_id           => p_oipl_id
             ,p_oiplip_id         => p_oiplip_id
             ,p_plip_id           => p_plip_id
             ,p_ptip_id           => p_ptip_id
             ,p_ret_date          => l_dummy_date
             ,p_ret_val           => l_elig_result);
            --
            if g_debug then
              hr_utility.set_location(' l_elig_result '||l_elig_result ,99);
            end if;
            --
            -- Round value if rounding needed
            --
            IF    l_elig_rec.rndg_cd IS NOT NULL
               OR l_elig_rec.rndg_rl IS NOT NULL THEN
              --
              l_elig_result  :=
                benutils.do_rounding(p_rounding_cd=> l_elig_rec.rndg_cd
                 ,p_rounding_rl    => l_elig_rec.rndg_rl
                 ,p_value          => l_elig_result
                 ,p_effective_date => NVL(p_lf_evt_ocrd_dt
                                       ,p_effective_date));
            --
            END IF;
          --
          ELSE
            l_elig_result  :=
              hours_calculation(p_comp_obj_tree_row=> p_comp_obj_tree_row
               ,p_empasg_row        => p_empasg_row
               ,p_benasg_row        => p_benasg_row
               ,p_curroiplip_row    => p_curroiplip_row
               ,p_rec               => l_elig_rec
               ,p_business_group_id => p_business_group_id
               ,p_person_id         => p_person_id
               ,p_pgm_id            => p_pgm_id
               ,p_pl_id             => p_pl_id
               ,p_oipl_id           => p_oipl_id
               ,p_oiplip_id         => p_oiplip_id
               ,p_plip_id           => p_plip_id
               ,p_ptip_id           => p_ptip_id
               ,p_effective_date    => p_effective_date
               ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt);
          END IF;
          -- In case called from watif benmngle then need not create
          -- temporals for any min, max breaches.
          --
          --hr_utility.set_location(' p_min_value '||l_elig_rec.mn_hrs_num ,99);
          --hr_utility.set_location(' p_max_value '||l_elig_rec.mx_hrs_num ,99);
          --hr_utility.set_location(' p_new_value '||l_elig_result ,99);
          --hr_utility.set_location(' p_old_value '||p_comp_rec.hrs_wkd_val ,99);
          --hr_utility.set_location(' p_break '||l_break,99);
          --
        /* Bug 5478918 */
	ben_seeddata_object.get_object(p_rec=> l_der_rec);
        if (skip_min_max_le_calc(l_der_rec.drvdhrw_id,
	                         p_business_group_id,
                                 p_ptnl_ler_trtmt_cd,
                                 p_effective_date)) THEN
        --
        /* Simply return as no further calculations need to be done */
          hr_utility.set_location(l_package||' Do Nothing here.', 9877);
          null;
        --
        else
	--
          IF     l_elig_result IS NOT NULL
             AND (
                       ben_whatif_elig.g_bal_hwf_val IS NULL
                   AND ben_whatif_elig.g_bnft_bal_hwf_val IS NULL) THEN
            --
                ben_derive_part_and_rate_cache.get_hours_elig(p_pgm_id=> p_pgm_id
                 ,p_pl_id             => p_pl_id
                 ,p_oipl_id           => p_oipl_id
                 ,p_plip_id           => p_plip_id
                 ,p_ptip_id           => p_ptip_id
                 ,p_new_val           => l_elig_result
                 ,p_old_val           => nvl(p_comp_rec.hrs_wkd_val,0)
                 ,p_business_group_id => p_business_group_id
                 ,p_effective_date    => nvl(g_fonm_cvg_strt_dt,NVL(p_lf_evt_ocrd_dt
                                          ,p_effective_date))
                 ,p_rec               => l_elig_rec);
        --
            IF benutils.min_max_breach(p_min_value=> NVL(l_elig_rec.mn_hrs_num
                                                      ,-1)
                ,p_max_value => NVL(l_elig_rec.mx_hrs_num
                                 ,99999999)
                ,p_new_value => l_elig_result
                ,p_old_value => nvl(p_comp_rec.hrs_wkd_val,0)
                ,p_break     => l_break) THEN
              --
              -- Derive life event occured date based on the value of l_break
              -- Bug 2145966 Formula not working for Hours worked derived factor
              --
              IF l_elig_rec.hrs_src_cd = 'BNFTBALTYP' OR l_elig_rec.hrs_src_cd = 'RL' THEN
                --
                IF l_elig_rec.hrs_src_cd = 'BNFTBALTYP' then
                --
                l_lf_evt_ocrd_dt  :=
                  get_balance_date(p_effective_date=> NVL(g_fonm_cvg_strt_dt,
                                                          NVL(p_lf_evt_ocrd_dt ,p_effective_date))
                   ,p_bnfts_bal_id   => l_elig_rec.bnfts_bal_id
                   ,p_person_id      => p_person_id
                   ,p_min            => l_elig_rec.mn_hrs_num
                   ,p_max            => l_elig_rec.mx_hrs_num
                   ,p_break          => l_break);
                --
                ELSE -- For Rule
                  --
                  l_lf_evt_ocrd_dt  := NVL(p_lf_evt_ocrd_dt,p_effective_date) ;
                  --
                END IF;
                --
                -- Reapply calculated life event occured date
                --
                IF l_elig_rec.hrs_wkd_det_cd <> 'AED' THEN
                  --
                  ben_determine_date.main(p_date_cd=> l_elig_rec.hrs_wkd_det_cd
                   ,p_formula_id        => l_elig_rec.hrs_wkd_det_rl
                   ,p_person_id         => p_person_id
                   ,p_bnfts_bal_id      => l_elig_rec.bnfts_bal_id
                   ,p_pgm_id            => NVL(p_pgm_id
                                            ,p_comp_obj_tree_row.par_pgm_id)
                   ,p_pl_id             => p_pl_id
                   ,p_oipl_id           => p_oipl_id
                   ,p_business_group_id => p_business_group_id
                   ,p_returned_date     => l_new_lf_evt_ocrd_dt
                   ,p_lf_evt_ocrd_dt    => l_lf_evt_ocrd_dt
                   ,p_effective_date    => l_lf_evt_ocrd_dt);
                  --
                  -- The derived life event occured date must be greater than the
                  -- life event occured date as otherwise in reality a boundary
                  -- has not been passed.
                  -- This can only happen if the det_cd is one of the following :
                  -- AFDCPPY = As of first day of current program or plan year
                  -- APOCT1 = As of previous october 1st
                  -- AFDCM = As of first day of the current month
                  --
                  IF     l_new_lf_evt_ocrd_dt < l_lf_evt_ocrd_dt
                     AND l_elig_rec.hrs_wkd_det_cd IN (
                                                        'AFDCPPY'
                                                       ,'APOCT1'
                                                       ,'AFDCM') THEN
                    --
                    -- These are special cases where we need to rederive the LED
                    -- so that we are actually still passing the correct boundary
                    --
                    IF l_elig_rec.hrs_wkd_det_cd = 'APOCT1' THEN
                      --
                      l_lf_evt_ocrd_dt  := ADD_MONTHS(l_lf_evt_ocrd_dt
                                            ,12);
                    --
                    ELSIF l_elig_rec.hrs_wkd_det_cd = 'AFDCM' THEN
                      --
                      -- l_lf_evt_ocrd_dt  := ADD_MONTHS(l_lf_evt_ocrd_dt ,1);
                      -- Bug 1927010. Commented the above manipulation
                      null ;
                    --
                    ELSIF l_elig_rec.hrs_wkd_det_cd = 'AFDCPPY' THEN
                      --
                      l_elig_rec.hrs_wkd_det_cd  := 'AFDFPPY';
                    --
                    END IF;
                    --
                    -- Reapply logic back to determination of date routine.
                    --
                    ben_determine_date.main(p_date_cd=> l_elig_rec.hrs_wkd_det_cd
                     ,p_bnfts_bal_id      => l_elig_rec.bnfts_bal_id
                     ,p_person_id         => p_person_id
                     ,p_pgm_id            => NVL(p_pgm_id
                                              ,p_comp_obj_tree_row.par_pgm_id)
                     ,p_pl_id             => p_pl_id
                     ,p_oipl_id           => p_oipl_id
                     ,p_business_group_id => p_business_group_id
                     ,p_returned_date     => l_new_lf_evt_ocrd_dt
                     ,p_lf_evt_ocrd_dt    => l_lf_evt_ocrd_dt
                     ,p_effective_date    => l_lf_evt_ocrd_dt);
                  --
                  END IF;
                  --
                  l_lf_evt_ocrd_dt  := l_new_lf_evt_ocrd_dt;
                --
                END IF;
              --
              ELSIF l_elig_rec.hrs_src_cd = 'BALTYP' THEN
                --
                l_lf_evt_ocrd_dt  := p_effective_date;
              --
              END IF;
              --
              -- Life event occured date must be less than the minimum
              -- assignment effective start date
              --
              ben_person_object.get_object(p_person_id=> p_person_id
               ,p_rec       => l_rec);
              --
              IF l_lf_evt_ocrd_dt >= l_rec.min_ass_effective_start_date THEN
                --
                IF   (  l_lf_evt_ocrd_dt < p_effective_date
                   AND NVL(p_ptnl_ler_trtmt_cd,'-1') = 'IGNR') THEN
                  --
                  -- We are not creating past life events
                  --
                  NULL;
                --
                ELSIF l_ok THEN
                  --
                  IF no_life_event(p_lf_evt_ocrd_dt=> l_lf_evt_ocrd_dt
                      ,p_person_id      => p_person_id
                      ,p_ler_id         => l_der_rec.drvdhrw_id
                      ,p_effective_date => p_effective_date)
                  THEN
                    --
                    create_ptl_ler
                      (p_calculate_only_mode => p_calculate_only_mode
                      ,p_ler_id              => l_der_rec.drvdhrw_id
                      ,p_lf_evt_ocrd_dt      => l_lf_evt_ocrd_dt
                      ,p_person_id           => p_person_id
                      ,p_business_group_id   => p_business_group_id
                      ,p_effective_date      => p_effective_date
                      );
                    --
                  END IF;
                --
                END IF;
              --
              END IF;
            --
            END IF;
          --
	  END IF;
          --
          END IF; /* End Bug 5478918 */
          --
          p_comp_rec.hrs_wkd_val            := l_elig_result;
          p_comp_rec.hrs_wkd_bndry_perd_cd  := NULL;
          --
          -- This only applies to eligibility
          --
          IF l_elig_result IS NULL THEN
            --
            p_comp_rec.hrs_wkd_bndry_perd_cd  := NULL;
          --
          END IF;
        --
        ELSE
          --
          p_comp_rec.hrs_wkd_val            := NULL;
          p_comp_rec.hrs_wkd_bndry_perd_cd  := NULL;
        --
        END IF;
      --
      END IF;
    --
    END IF;
    --
   -- hr_utility.set_location('RFHWF=Y ' || l_package,10);
    --9999
    IF    bitand(p_comp_obj_tree_row.flag_bit_val
           ,ben_manage_life_events.g_hrw_rt_flag) <> 0
       OR     p_oiplip_id IS NOT NULL
          AND bitand(p_comp_obj_tree_row.oiplip_flag_bit_val
               ,ben_manage_life_events.g_hrw_rt_flag) <> 0 THEN
      --
      if g_debug then
        hr_utility.set_location('HRW for RT',10);
      end if;
      IF    p_comp_rec.rt_frz_hrs_wkd_flag = 'Y'
         OR (
                  NVL(p_comp_rec.once_r_cntug_cd
                   ,'-1') = 'ONCE'
              AND p_comp_rec.elig_flag = 'Y') THEN
        --
        -- No calulation required just return the frozen value
        --
        NULL;
      --
      ELSE
        --
        if g_debug then
          hr_utility.set_location('ben_derive_part_and_rate_cache '||p_oipl_id , 20);
        end if;
        --
        ben_derive_part_and_rate_cache.get_hours_rate(p_pgm_id=> p_pgm_id
         ,p_pl_id             => p_pl_id
         ,p_oipl_id           => p_oipl_id
         ,p_plip_id           => p_plip_id
         ,p_ptip_id           => p_ptip_id
         ,p_oiplip_id         => p_oiplip_id
         ,p_business_group_id => p_business_group_id
         ,p_effective_date    => nvl(g_fonm_cvg_strt_dt,NVL(p_lf_evt_ocrd_dt
                                  ,p_effective_date))
         ,p_rec               => l_rate_rec);
        --
        IF    NVL(l_rate_rec.once_r_cntug_cd ,'-1') = 'ONCE'
            AND NVL(p_comp_rec.once_r_cntug_cd ,'-1') = 'ONCE'
            AND p_comp_rec.elig_flag = 'Y'   THEN
          --
          -- In this case we do not have to derive the hours worked as the
          -- eligibility has been met, just return the frozen values and
          -- ignore the business rule check for the eligbility profile
          --
          null ;
          --
        ELSIF l_rate_rec.exist = 'Y' THEN
          --
          if g_debug then
            hr_utility.set_location(' l_rate_rec.exist ' ,25);
          end if;
          l_rate  := TRUE;
          --
          IF p_oiplip_id IS NOT NULL THEN
            --
            if g_debug then
              hr_utility.set_location(' p_curroiplip_row ',25);
            end if;
            l_oiplip_rec  := p_curroiplip_row;
          --
          END IF;
          --
          IF l_rate_rec.hrs_wkd_calc_rl IS NOT NULL THEN
            --
            if g_debug then
              hr_utility.set_location('in the comp_calc_rl ' ,30);
            end if;
            ben_determine_date.main(p_date_cd=> l_rate_rec.hrs_wkd_det_cd
             ,p_formula_id        => l_rate_rec.hrs_wkd_calc_rl
             ,p_person_id         => p_person_id
             ,p_pgm_id            => NVL(p_pgm_id
                                      ,p_comp_obj_tree_row.par_pgm_id)
             ,p_bnfts_bal_id      => l_rate_rec.bnfts_bal_id
             ,p_pl_id             => p_pl_id
             ,p_oipl_id           => NVL(p_oipl_id
                                      ,l_oiplip_rec.oipl_id)
             ,p_business_group_id => p_business_group_id
             ,p_returned_date     => l_start_date
             ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
             ,p_effective_date    => NVL(p_lf_evt_ocrd_dt
                                      ,p_effective_date)
             ,p_fonm_cvg_strt_dt  => g_fonm_cvg_strt_dt);
            --
            run_rule(p_formula_id => l_rate_rec.hrs_wkd_calc_rl
             ,p_empasg_row        => p_empasg_row
             ,p_benasg_row        => p_benasg_row
             ,p_pil_row           => p_pil_row
             ,p_curroipl_row      => p_curroipl_row
             ,p_curroiplip_row    => p_curroiplip_row
             ,p_effective_date    => l_start_date
             ,p_lf_evt_ocrd_dt    => l_start_date
             ,p_business_group_id => p_business_group_id
             ,p_person_id         => p_person_id
             ,p_pgm_id            => p_pgm_id
             ,p_pl_id             => p_pl_id
             ,p_oipl_id           => p_oipl_id
             ,p_oiplip_id         => p_oiplip_id
             ,p_plip_id           => p_plip_id
             ,p_ptip_id           => p_ptip_id
             ,p_ret_date          => l_dummy_date
             ,p_ret_val           => l_rate_result);
            --
            -- Round value if rounding needed
            --
            --
            IF    l_rate_rec.rndg_cd IS NOT NULL
               OR l_rate_rec.rndg_rl IS NOT NULL THEN
              --
              l_rate_result  :=
                benutils.do_rounding(p_rounding_cd=> l_rate_rec.rndg_cd
                 ,p_rounding_rl    => l_rate_rec.rndg_rl
                 ,p_value          => l_rate_result
                 ,p_effective_date => NVL(p_lf_evt_ocrd_dt
                                       ,p_effective_date));
              if g_debug then
                hr_utility.set_location('in the l_rate_rec.rndg_cd ' , 35 );
              end if;
            --
            END IF;
          --
          ELSE
          --
            if g_debug then
              hr_utility.set_location('not rule -  l_rate_result ',30);
            end if;
            l_rate_result  :=
              hours_calculation(p_comp_obj_tree_row=> p_comp_obj_tree_row
               ,p_empasg_row        => p_empasg_row
               ,p_benasg_row        => p_benasg_row
               ,p_curroiplip_row    => p_curroiplip_row
               ,p_rec               => l_rate_rec
               ,p_business_group_id => p_business_group_id
               ,p_person_id         => p_person_id
               ,p_pgm_id            => p_pgm_id
               ,p_pl_id             => p_pl_id
               ,p_oipl_id           => p_oipl_id
               ,p_oiplip_id         => p_oiplip_id
               ,p_plip_id           => p_plip_id
               ,p_ptip_id           => p_ptip_id
               ,p_effective_date    => p_effective_date
               ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt);
             --
             IF l_rate_result is not null THEN
               --
               if g_debug then
                 hr_utility.set_location(' l_rate_result found '||l_rate_result , 40);
               end if;
               --
               ben_derive_part_and_rate_cache.get_hours_rate(p_pgm_id=> p_pgm_id
                ,p_pl_id             => p_pl_id
                ,p_oipl_id           => p_oipl_id
                ,p_plip_id           => p_plip_id
                ,p_ptip_id           => p_ptip_id
                ,p_oiplip_id         => p_oiplip_id
                ,p_new_val           => l_rate_result
                ,p_old_val           => p_comp_rec.rt_hrs_wkd_val
                ,p_business_group_id => p_business_group_id
                ,p_effective_date    => nvl(g_fonm_cvg_strt_dt,NVL(p_lf_evt_ocrd_dt
                                         ,p_effective_date))
                ,p_rec               => l_rate_rec);
               --
               IF ( ben_whatif_elig.g_bal_hwf_val IS NULL
                   AND ben_whatif_elig.g_bnft_bal_hwf_val IS NULL) THEN
                 --
                 ben_seeddata_object.get_object(p_rec=> l_der_rec);
                 --
                 if g_debug then
                   hr_utility.set_location(' Call to hours_worked_min_max ' ,45 );
                 end if;
                 hours_worked_min_max
                   (p_calculate_only_mode =>p_calculate_only_mode
                   ,p_comp_obj_tree_row   =>p_comp_obj_tree_row
                   ,p_curroiplip_row      =>p_curroiplip_row
                --   ,p_rate_rec            =>l_rate_rec
                   ,p_comp_rec            =>p_comp_rec
                   ,p_empasg_row          =>p_empasg_row
                   ,p_benasg_row          =>p_benasg_row
                   ,p_person_id           =>p_person_id
                   ,p_pgm_id              =>p_pgm_id
                   ,p_pl_id               =>p_pl_id
                   ,p_oipl_id             =>p_oipl_id
                   ,p_oiplip_id           =>p_oiplip_id
                   ,p_plip_id             =>p_plip_id
                   ,p_ptip_id             =>p_ptip_id
                   ,p_business_group_id   =>p_business_group_id
                   ,p_ler_id              =>l_der_rec.drvdhrw_id
                   ,p_min_value           =>l_rate_rec.mn_hrs_num
                   ,p_max_value           =>l_rate_rec.mx_hrs_num
                   ,p_new_value           =>l_rate_result
                   ,p_old_value           =>p_comp_rec.rt_hrs_wkd_val
                   ,p_subtract_date       =>l_subtract_date
                   ,p_det_cd              =>l_rate_rec.hrs_wkd_det_cd
                   ,p_formula_id          =>l_rate_rec.hrs_wkd_det_rl
                   ,p_ptnl_ler_trtmt_cd   =>p_ptnl_ler_trtmt_cd
                   ,p_effective_date      =>p_effective_date
                   ,p_lf_evt_ocrd_dt      =>p_lf_evt_ocrd_dt
                   ,p_hrs_src_cd          =>l_rate_rec.hrs_src_cd
                   ,p_bnfts_bal_id        =>l_rate_rec.bnfts_bal_id
                  ) ;
                --
              END IF; -- ben_whatif_elig
              --
            END IF; -- l_rate_result
            --
          END IF; -- l_rate_rec.los_calc_rl
          --
        END IF ; -- l_rate_rec.exist
        -- Try and find a coverage first
        --
        if g_debug then
          hr_utility.set_location(' Now check for Coverage and Premium' ,50 );
        end if;
        --
        IF    p_oipl_id IS NOT NULL
           OR p_pl_id IS NOT NULL
           OR p_plip_id IS NOT NULL THEN
            --
            ben_derive_part_and_rate_cvg.get_hours_rate(p_pl_id=> p_pl_id
             ,p_oipl_id           => p_oipl_id
             ,p_plip_id           => p_plip_id
             ,p_business_group_id => p_business_group_id
             ,p_effective_date    => nvl(g_fonm_cvg_strt_dt,NVL(p_lf_evt_ocrd_dt
                                      ,p_effective_date))
             ,p_rec               => l_rate_cvg_rec);
          --

          IF   NVL(l_rate_cvg_rec.once_r_cntug_cd ,'-1') = 'ONCE'
               AND NVL(p_comp_rec.once_r_cntug_cd ,'-1') = 'ONCE'
               AND p_comp_rec.elig_flag = 'Y'   THEN
            --
            -- In this case we do not have to derive the hours worked as the
            -- eligibility has been met, just return the frozen values and
            -- ignore the business rule check for the eligbility profile
            --
            null ;
            --
          ELSIF l_rate_cvg_rec.exist = 'Y' THEN     /* Changed from l_rate_rec to l_rate_cvg_rec */
            --
            if g_debug then
              hr_utility.set_location(' l_rate_cvg_rec.exist' , 60);
            end if;
            --
            l_cvg  := TRUE;
            --

            IF l_rate_cvg_rec.hrs_wkd_calc_rl IS NOT NULL THEN
              ben_determine_date.main(p_date_cd=> l_rate_cvg_rec.hrs_wkd_det_cd
               ,p_formula_id        => l_rate_cvg_rec.hrs_wkd_calc_rl
               ,p_person_id         => p_person_id
               ,p_pgm_id            => NVL(p_pgm_id
                                        ,p_comp_obj_tree_row.par_pgm_id)
               ,p_bnfts_bal_id      => l_rate_cvg_rec.bnfts_bal_id
               ,p_pl_id             => p_pl_id
               ,p_oipl_id           => NVL(p_oipl_id
                                        ,l_oiplip_rec.oipl_id)
               ,p_business_group_id => p_business_group_id
               ,p_returned_date     => l_start_date
               ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
               ,p_effective_date    => NVL(p_lf_evt_ocrd_dt
                                        ,p_effective_date));
                --
                run_rule(p_formula_id => l_rate_cvg_rec.hrs_wkd_calc_rl
                 ,p_empasg_row        => p_empasg_row
               ,p_benasg_row        => p_benasg_row
               ,p_pil_row           => p_pil_row
               ,p_curroipl_row      => p_curroipl_row
               ,p_curroiplip_row    => p_curroiplip_row
               ,p_effective_date    => l_start_date
               ,p_lf_evt_ocrd_dt    => l_start_date
               ,p_business_group_id => p_business_group_id
               ,p_person_id         => p_person_id
               ,p_pgm_id            => p_pgm_id
               ,p_pl_id             => p_pl_id
               ,p_oipl_id           => p_oipl_id
               ,p_oiplip_id         => p_oiplip_id
               ,p_plip_id           => p_plip_id
               ,p_ptip_id           => p_ptip_id
               ,p_ret_date          => l_dummy_date
               ,p_ret_val           => l_rate_cvg_result);
                --
                -- Round value if rounding needed
                --
                --
              IF    l_rate_cvg_rec.rndg_cd IS NOT NULL
               OR l_rate_cvg_rec.rndg_rl IS NOT NULL THEN
                --
                l_rate_cvg_result  :=
                  benutils.do_rounding(p_rounding_cd=> l_rate_cvg_rec.rndg_cd
                 ,p_rounding_rl    => l_rate_cvg_rec.rndg_rl
                 ,p_value          => l_rate_cvg_result
                 ,p_effective_date => NVL(p_lf_evt_ocrd_dt
                                       ,p_effective_date));
                --
              END IF;
            --
            ELSE
              --
              if g_debug then
                hr_utility.set_location(' call to hours_calculation ' , 65 );
              end if;
              l_rate_cvg_result  :=
               hours_calculation(p_comp_obj_tree_row=> p_comp_obj_tree_row
               ,p_empasg_row        => p_empasg_row
               ,p_benasg_row        => p_benasg_row
               ,p_curroiplip_row    => p_curroiplip_row
               ,p_rec               => l_rate_cvg_rec
               ,p_business_group_id => p_business_group_id
               ,p_person_id         => p_person_id
               ,p_pgm_id            => p_pgm_id
               ,p_pl_id             => p_pl_id
               ,p_oipl_id           => p_oipl_id
               ,p_oiplip_id         => p_oiplip_id
               ,p_plip_id           => p_plip_id
               ,p_ptip_id           => p_ptip_id
               ,p_effective_date    => p_effective_date
               ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt);
               --
              IF l_rate_cvg_result is not null THEN
                --
                --
                ben_derive_part_and_rate_cvg.get_hours_rate(p_pl_id=> p_pl_id
                 ,p_oipl_id           => p_oipl_id
                 ,p_plip_id           => p_plip_id
                 ,p_business_group_id => p_business_group_id
                 ,p_effective_date    => nvl(g_fonm_cvg_strt_dt,NVL(p_lf_evt_ocrd_dt
                                          ,p_effective_date))
                 ,p_rec               => l_rate_cvg_rec);
                --
                --
                IF ( ben_whatif_elig.g_bal_hwf_val IS NULL
                   AND ben_whatif_elig.g_bnft_bal_hwf_val IS NULL) THEN
                  --
                  ben_seeddata_object.get_object(p_rec=> l_der_cvg_rec);
                  --
                  if g_debug then
                    hr_utility.set_location('  call hours_worked_min_max ' ,75);
                  end if;
                  hours_worked_min_max
                    (p_calculate_only_mode =>p_calculate_only_mode
                    ,p_comp_obj_tree_row   =>p_comp_obj_tree_row
                    ,p_curroiplip_row      =>p_curroiplip_row
                 --   ,p_rate_rec            =>l_rate_rec
                    ,p_comp_rec            =>p_comp_rec
                    ,p_empasg_row          =>p_empasg_row
                    ,p_benasg_row          =>p_benasg_row
                    ,p_person_id           =>p_person_id
                    ,p_pgm_id              =>p_pgm_id
                    ,p_pl_id               =>p_pl_id
                    ,p_oipl_id             =>p_oipl_id
                    ,p_oiplip_id           =>p_oiplip_id
                    ,p_plip_id             =>p_plip_id
                    ,p_ptip_id             =>p_ptip_id
                    ,p_business_group_id   =>p_business_group_id
                    ,p_ler_id              =>l_der_cvg_rec.drvdhrw_id
                    ,p_min_value           =>l_rate_cvg_rec.mn_hrs_num
                    ,p_max_value           =>l_rate_cvg_rec.mx_hrs_num
                    ,p_new_value           =>l_rate_cvg_result
                    ,p_old_value           =>p_comp_rec.rt_hrs_wkd_val
                    ,p_subtract_date       =>l_subtract_date
                    ,p_det_cd              =>l_rate_cvg_rec.hrs_wkd_det_cd
                    ,p_formula_id          =>l_rate_cvg_rec.hrs_wkd_det_rl
                    ,p_ptnl_ler_trtmt_cd   =>p_ptnl_ler_trtmt_cd
                    ,p_effective_date      =>p_effective_date
                    ,p_lf_evt_ocrd_dt      =>p_lf_evt_ocrd_dt
                    ,p_hrs_src_cd          =>l_rate_cvg_rec.hrs_src_cd
                    ,p_bnfts_bal_id        =>l_rate_cvg_rec.bnfts_bal_id
                  ) ;
                END IF; -- ben_whatif_elig
                --
              END IF; -- l_rate_cvg_result
              --
            END IF; -- l_rate_cvg_rec.los_calc_rl
            --
          END IF; -- l_rate_cvg_rec.exist
        --
        END IF ; -- oipl_id
        --
        if g_debug then
          hr_utility.set_location(' Now call ben_derive_part_and_rate_prem ' , 80);
        end if;
        IF  p_oipl_id IS NOT NULL
            OR p_pl_id IS NOT NULL THEN
          --
          -- Try and find a premium
          --
          ben_derive_part_and_rate_prem.get_hours_rate(p_pl_id=> p_pl_id
               ,p_oipl_id           => p_oipl_id
               ,p_business_group_id => p_business_group_id
               ,p_effective_date    =>  nvl(g_fonm_cvg_strt_dt,
                                            NVL(p_lf_evt_ocrd_dt ,p_effective_date))
               ,p_rec               => l_rate_prem_rec);
              --
          IF   NVL(l_rate_prem_rec.once_r_cntug_cd ,'-1') = 'ONCE'
               AND NVL(p_comp_rec.once_r_cntug_cd ,'-1') = 'ONCE'
               AND p_comp_rec.elig_flag = 'Y'   THEN
             --
             null ;
             --
             -- In this case we do not have to derive the hours worked as the
             -- eligibility has been met, just return the frozen values and
             -- ignore the business rule check for the eligbility profile
             --
          ELSIF l_rate_prem_rec.exist = 'Y'  THEN
            --
            if g_debug then
              hr_utility.set_location(' l_rate_prem_rec.exist Y ',85);
            end if;
            l_prem  := TRUE;
            --
            IF l_rate_prem_rec.hrs_wkd_calc_rl IS NOT NULL THEN
              --
              ben_determine_date.main(p_date_cd=> l_rate_prem_rec.hrs_wkd_det_cd
               ,p_formula_id        => l_rate_prem_rec.hrs_wkd_calc_rl
               ,p_person_id         => p_person_id
               ,p_pgm_id            => NVL(p_pgm_id
                                        ,p_comp_obj_tree_row.par_pgm_id)
               ,p_bnfts_bal_id      => l_rate_prem_rec.bnfts_bal_id
               ,p_pl_id             => p_pl_id
               ,p_oipl_id           => NVL(p_oipl_id
                                        ,l_oiplip_rec.oipl_id)
               ,p_business_group_id => p_business_group_id
               ,p_returned_date     => l_start_date
               ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
               ,p_effective_date    => NVL(p_lf_evt_ocrd_dt
                                        ,p_effective_date));
                --
                run_rule(p_formula_id => l_rate_prem_rec.hrs_wkd_calc_rl
                 ,p_empasg_row        => p_empasg_row
               ,p_benasg_row        => p_benasg_row
               ,p_pil_row           => p_pil_row
               ,p_curroipl_row      => p_curroipl_row
               ,p_curroiplip_row    => p_curroiplip_row
               ,p_effective_date    => l_start_date
               ,p_lf_evt_ocrd_dt    => l_start_date
               ,p_business_group_id => p_business_group_id
               ,p_person_id         => p_person_id
               ,p_pgm_id            => p_pgm_id
               ,p_pl_id             => p_pl_id
               ,p_oipl_id           => p_oipl_id
               ,p_oiplip_id         => p_oiplip_id
               ,p_plip_id           => p_plip_id
               ,p_ptip_id           => p_ptip_id
               ,p_ret_date          => l_dummy_date
               ,p_ret_val           => l_rate_prem_result);
                --
                -- Round value if rounding needed
                --
                --
              IF    l_rate_prem_rec.rndg_cd IS NOT NULL
               OR l_rate_prem_rec.rndg_rl IS NOT NULL THEN
                --
                l_rate_prem_result  :=
                  benutils.do_rounding(p_rounding_cd=> l_rate_prem_rec.rndg_cd
                 ,p_rounding_rl    => l_rate_prem_rec.rndg_rl
                 ,p_value          => l_rate_prem_result
                 ,p_effective_date => NVL(p_lf_evt_ocrd_dt
                                       ,p_effective_date));
                --
              END IF;
            --
            ELSE
              --
              if g_debug then
                hr_utility.set_location(' call to hours_calculation ' , 90);
              end if;
              l_rate_prem_result  :=
               hours_calculation(p_comp_obj_tree_row=> p_comp_obj_tree_row
               ,p_empasg_row        => p_empasg_row
               ,p_benasg_row        => p_benasg_row
               ,p_curroiplip_row    => p_curroiplip_row
               ,p_rec               => l_rate_prem_rec
               ,p_business_group_id => p_business_group_id
               ,p_person_id         => p_person_id
               ,p_pgm_id            => p_pgm_id
               ,p_pl_id             => p_pl_id
               ,p_oipl_id           => p_oipl_id
               ,p_oiplip_id         => p_oiplip_id
               ,p_plip_id           => p_plip_id
               ,p_ptip_id           => p_ptip_id
               ,p_effective_date    => p_effective_date
               ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt);
               --
               if g_debug then
                 hr_utility.set_location(' l_rate_prem_result '||l_rate_prem_result ,95);
               end if;
              --
              IF l_rate_prem_result is not null THEN
                --
                --
                ben_derive_part_and_rate_prem.get_hours_rate(
                  p_pl_id             => p_pl_id
                 ,p_oipl_id           => p_oipl_id
                 ,p_old_val           => p_comp_rec.rt_hrs_wkd_val
                 ,p_new_val           => l_rate_prem_result
                 ,p_business_group_id => p_business_group_id
                 ,p_effective_date    =>  nvl(g_fonm_cvg_strt_dt,
                                              NVL(p_lf_evt_ocrd_dt ,p_effective_date))
                 ,p_rec               => l_rate_prem_rec);
                --
                IF ( ben_whatif_elig.g_bal_hwf_val IS NULL
                   AND ben_whatif_elig.g_bnft_bal_hwf_val IS NULL) THEN
                  --
                  ben_seeddata_object.get_object(p_rec=> l_der_prem_rec);
                  --
                  if g_debug then
                    hr_utility.set_location(' call to comp_level_min_max ' ,100);
                  end if;
                  --
                  hours_worked_min_max
                    (p_calculate_only_mode =>p_calculate_only_mode
                    ,p_comp_obj_tree_row   =>p_comp_obj_tree_row
                    ,p_curroiplip_row      =>p_curroiplip_row
                 --   ,p_rate_rec            =>l_rate_rec
                    ,p_comp_rec            =>p_comp_rec
                    ,p_empasg_row          =>p_empasg_row
                    ,p_benasg_row          =>p_benasg_row
                    ,p_person_id           =>p_person_id
                    ,p_pgm_id              =>p_pgm_id
                    ,p_pl_id               =>p_pl_id
                    ,p_oipl_id             =>p_oipl_id
                    ,p_oiplip_id           =>p_oiplip_id
                    ,p_plip_id             =>p_plip_id
                    ,p_ptip_id             =>p_ptip_id
                    ,p_business_group_id   =>p_business_group_id
                    ,p_ler_id              =>l_der_prem_rec.drvdhrw_id
                    ,p_min_value           =>l_rate_prem_rec.mn_hrs_num
                    ,p_max_value           =>l_rate_prem_rec.mx_hrs_num
                    ,p_new_value           =>l_rate_prem_result
                    ,p_old_value           =>p_comp_rec.rt_hrs_wkd_val
                    ,p_subtract_date       =>l_subtract_date
                    ,p_det_cd              =>l_rate_prem_rec.hrs_wkd_det_cd
                    ,p_formula_id          =>l_rate_prem_rec.hrs_wkd_det_rl
                    ,p_ptnl_ler_trtmt_cd   =>p_ptnl_ler_trtmt_cd
                    ,p_effective_date      =>p_effective_date
                    ,p_lf_evt_ocrd_dt      =>p_lf_evt_ocrd_dt
                    ,p_hrs_src_cd          =>l_rate_prem_rec.hrs_src_cd
                    ,p_bnfts_bal_id        =>l_rate_prem_rec.bnfts_bal_id
                  ) ;
                END IF; -- ben_whatif_elig
                --
              END IF; -- l_rate_cvg_result
              --
            END IF; -- l_rate_prem_rec.los_calc_rl
            --
          END IF; -- l_rate_prem_rec.exist
        --
        END IF ; -- oipl_id
--
        IF l_rate_result IS NULL and l_rate_cvg_result IS NULL and  l_rate_prem_result IS NULL THEN
          --
          p_comp_rec.rt_hrs_wkd_val  := NULL;
          p_comp_rec.rt_hrs_wkd_bndry_perd_cd  := NULL;
          --
        ELSIF l_rate_result is NOT NULL THEN
          if g_debug then
            hr_utility.set_location(' Step 28',10);
          end if;
          p_comp_rec.rt_hrs_wkd_val  := l_rate_result;
          p_comp_rec.rt_hrs_wkd_bndry_perd_cd  :=  NULL ;
          --
        ELSIF l_rate_cvg_result is NOT NULL then
          --
          p_comp_rec.rt_hrs_wkd_val  := l_rate_cvg_result;
          p_comp_rec.rt_hrs_wkd_bndry_perd_cd  := NULL ;
          if g_debug then
            hr_utility.set_location(' Step 29',10);
          end if;
        ELSIF l_rate_prem_result is NOT NULL THEN
          --
          p_comp_rec.rt_hrs_wkd_val  := l_rate_prem_result;
          p_comp_rec.rt_hrs_wkd_bndry_perd_cd  :=  NULL ;
          if g_debug then
            hr_utility.set_location(' Step 30',10);
          end if;
        END IF;
      --
      END IF;
    --
    END IF;
    --
    -- Set value of once_r_cntug_cd as this is what will be updated and passed
    -- bendetel.pkb
    --
    IF l_elig_rec.exist = 'Y' THEN
      --
      IF     NVL(l_elig_rec.once_r_cntug_cd
              ,'-1') = 'CNTNG'
         AND NVL(p_comp_rec.once_r_cntug_cd
              ,'-1') = 'ONCE' THEN
        --
        p_comp_rec.once_r_cntug_cd  := 'CNTNG';
      --
      ELSIF     NVL(l_elig_rec.once_r_cntug_cd
                 ,'-1') = 'ONCE'
            AND NVL(p_comp_rec.once_r_cntug_cd
                 ,'-1') = 'CNTNG' THEN
        --
        p_comp_rec.once_r_cntug_cd  := 'ONCE';
        --
        -- Override the elig flag to force the check on bendetel.pkb
        --
        p_comp_rec.elig_flag        := 'N';
      --
      ELSIF     NVL(l_elig_rec.once_r_cntug_cd
                 ,'-1') = 'CNTNG'
            AND NVL(p_comp_rec.once_r_cntug_cd
                 ,'-1') = 'CNTNG' THEN
        --
        p_comp_rec.once_r_cntug_cd  := 'CNTNG';
      --
      ELSIF NVL(l_elig_rec.once_r_cntug_cd
             ,'-1') = '-1' THEN
        --
        p_comp_rec.once_r_cntug_cd  := NULL;
      --
      END IF;
    --
    END IF;
    --
    if g_debug then
      hr_utility.set_location('Leaving ' || l_package,10);
    end if;
  --
  END calculate_hours_worked;
--
  FUNCTION is_payment_late
           (p_amt_due               in number
           ,p_shortfall_amt         in number
           ,p_allwd_underpymt_value in number
           ,p_allwd_underpymt_pct   in number)
  RETURN boolean IS
    l_allwd_underpymt_amt number;
    l_late_pymt_evt       boolean := FALSE;
  BEGIN
    l_allwd_underpymt_amt := (p_allwd_underpymt_pct/100) * p_amt_due;

    l_allwd_underpymt_amt := round(l_allwd_underpymt_amt,2);

    if l_allwd_underpymt_amt > p_allwd_underpymt_value then
      l_allwd_underpymt_amt := p_allwd_underpymt_value;
    end if;

    if g_debug then
      hr_utility.set_location('total amt due'||p_amt_due,11);
      hr_utility.set_location('total shortfall'||p_shortfall_amt,11);
      hr_utility.set_location('allowed underpayment amt'||l_allwd_underpymt_amt,11);
    end if;

    if  p_shortfall_amt > l_allwd_underpymt_amt then
      l_late_pymt_evt := TRUE;
    end if;

    return l_late_pymt_evt;

  END is_payment_late;
  --
  PROCEDURE get_amt_due_and_shortfall
          (p_acty_base_rt_id        in number
          ,p_assignment_id          in number
          ,p_payroll_id             in number
          ,p_due_date               in date
          ,p_effective_date         in date
          ,p_business_group_id      in number
          ,p_from_date              in date
          ,p_to_date                in date
          ,p_ann_rt_val             in number
          ,p_person_id              in number
          ,p_organization_id        in number
          ,p_prtt_enrt_rslt_id      in number
          ,p_rt_strt_dt             in date
          ,p_rt_end_dt              in date
          ,p_rt_mlt_cd              in varchar2
          ,p_amt_due                out nocopy number
          ,p_shortfall_amt          out nocopy number
          ,p_pymt_short             out nocopy boolean
          )
  IS

    CURSOR c_get_pymt(
      c_effective_date    IN DATE
     ,c_business_group_id IN NUMBER
     ,c_acty_base_rt_id   IN NUMBER
     ,c_assignment_id     IN NUMBER
     ,c_payroll_id        IN NUMBER
     ,c_from_date         IN DATE
     ,c_to_date           IN DATE) IS
      SELECT   NVL(SUM(a.result_value),0) result_value
      FROM     pay_run_result_values a
              ,pay_element_types_f b
              ,pay_assignment_actions d
              ,pay_payroll_actions e
              ,per_time_periods g
              ,pay_run_results h
              ,ben_acty_base_rt_f i
              ,pay_input_values_f j
      WHERE    d.assignment_id = c_assignment_id
      AND      d.payroll_action_id = e.payroll_action_id
      AND      i.input_value_id = j.input_value_id
      AND      i.element_type_id = b.element_type_id
      AND      i.acty_base_rt_id = c_acty_base_rt_id
      AND      c_effective_date BETWEEN i.effective_start_date
                   AND i.effective_end_date
      AND      i.business_group_id = c_business_group_id
      AND      g.payroll_id = c_payroll_id
      AND      b.element_type_id = h.element_type_id
      AND      d.assignment_action_id = h.assignment_action_id
      AND      e.date_earned BETWEEN g.start_date AND g.end_date
      AND      e.date_earned BETWEEN c_from_date AND c_to_date
      AND      a.input_value_id = j.input_value_id
      AND      a.run_result_id = h.run_result_id
      AND      j.element_type_id = b.element_type_id
      AND      c_effective_date BETWEEN b.effective_start_date
                   AND b.effective_end_date
      AND      c_effective_date BETWEEN j.effective_start_date
                   AND j.effective_end_date;


      l_pymt_amt      number := 0;
      l_amt_due       number := 0;
      l_shortfall_amt number := 0;
      l_pymt_short    boolean := FALSE;

      l_per_month_amt      number;
      l_first_month_amt    number;
      l_last_month_amt     number;

  BEGIN

    OPEN c_get_pymt
      (c_effective_date    => nvl(g_fonm_cvg_strt_dt,p_effective_date)
      ,c_business_group_id => p_business_group_id
      ,c_acty_base_rt_id   => p_acty_base_rt_id
      ,c_assignment_id     => p_assignment_id
      ,c_payroll_id        => p_payroll_id
      ,c_from_date         => p_from_date
      ,c_to_date           => p_to_date);
    FETCH c_get_pymt INTO l_pymt_amt;
    IF c_get_pymt%NOTFOUND THEN
      l_pymt_amt := 0;
    END IF;
    CLOSE c_get_pymt;

    -- Check if payment is for full amount
    --
    -- Fetch Amount Due
    --

    ben_cobra_requirements.get_amount_due
            (p_person_id         => p_person_id
            ,p_business_group_id => p_business_group_id
            ,p_assignment_id     => p_assignment_id
            ,p_payroll_id        => p_payroll_id
            ,p_organization_id   => p_organization_id
            ,p_effective_date    => nvl(g_fonm_cvg_strt_dt,p_effective_date)
            ,p_prtt_enrt_rslt_id => p_prtt_enrt_rslt_id
            ,p_acty_base_rt_id   => p_acty_base_rt_id
            ,p_ann_rt_val        => p_ann_rt_val
            ,p_mlt_cd            => p_rt_mlt_cd
            ,p_rt_strt_dt        => p_rt_strt_dt
            ,p_rt_end_dt         => p_rt_end_dt
            ,p_first_month_amt   => l_first_month_amt
            ,p_per_month_amt     => l_per_month_amt
            ,p_last_month_amt    => l_last_month_amt);

    --
    -- For first month, the amount due = l_first_month_amt
    -- For subsequent months, the amount due = l_per_month_amt * No. of months
    -- For last month, the amount due = l_last_month_amt
    --

    if (p_from_date = p_rt_strt_dt) then -- First month
      l_amt_due := l_first_month_amt;
    elsif (p_to_date = p_rt_end_dt) then -- Last month
      l_amt_due := l_last_month_amt;
    else
      l_amt_due := l_per_month_amt;
    end if;

    if g_debug then
      hr_utility.set_location('amt due'||l_amt_due,11);
      hr_utility.set_location('pymt_amt'||l_pymt_amt,11);
      hr_utility.set_location('p_from_date'||p_from_date,11);
      hr_utility.set_location('p_to_date'||p_to_date,11);
    end if;

    IF l_amt_due > l_pymt_amt THEN
      l_shortfall_amt := l_amt_due - l_pymt_amt;
      l_pymt_short :=TRUE;
    END IF;

    -- Set Out variables
    p_amt_due := NVL(l_amt_due,0);
    p_shortfall_amt := NVL(l_shortfall_amt,0);
    p_pymt_short := l_pymt_short;

  END get_amt_due_and_shortfall;
  --
  PROCEDURE get_allowed_underpayment
    (p_pgm_id                in number
    ,p_business_group_id     in number
    ,p_effective_date        in date
    ,p_allwd_underpymt_value out nocopy number
    ,p_allwd_underpymt_pct   out nocopy number
    )
  IS

    CURSOR c_allwd_underpymt(c_effective_date in date) is
     select  NVL(to_number(fti.FED_INFORMATION1),0) allwd_underpymt_value
            ,NVL(to_number(fti.FED_INFORMATION2),0) allwd_underpymt_pct
     from   pay_us_federal_tax_info_f fti
     where  fti.fed_information_category = 'BENEFIT UNDERPAY'
     and    c_effective_date between fti.effective_start_date
            and fti.effective_end_date;

    l_allwd_underpymt_value number;
    l_allwd_underpymt_pct   number;
  BEGIN

    open c_allwd_underpymt(c_effective_date =>  nvl(g_fonm_cvg_strt_dt,p_effective_date));
    fetch c_allwd_underpymt into l_allwd_underpymt_value,l_allwd_underpymt_pct;
    if c_allwd_underpymt%notfound then
      l_allwd_underpymt_value := 0;
      l_allwd_underpymt_pct   := 0;
    end if;
    close c_allwd_underpymt;

    -- Set out variables
    p_allwd_underpymt_value := l_allwd_underpymt_value;
    p_allwd_underpymt_pct := l_allwd_underpymt_pct;

  END get_allowed_underpayment;
  --
  PROCEDURE determine_cobra_payments
    (p_calculate_only_mode in     boolean default false
    ,p_person_id           IN     NUMBER
    ,p_business_group_id   IN     NUMBER
    ,p_ptnl_ler_trtmt_cd   IN     VARCHAR2
    ,p_effective_date      IN     DATE
    ,p_pgm_id              IN     NUMBER
    ,p_ptip_id             IN     NUMBER
    ,p_cbr_quald_bnf_id    IN     NUMBER
    )
  IS
    --
    l_package               VARCHAR2(80)
                                   := g_package || '.determine_cobra_payments';
    l_lf_evt_ocrd_dt        DATE;
    l_ok                    BOOLEAN;
    l_exists                VARCHAR2(1);
    l_der_rec               ben_seeddata_object.g_derived_factor_info_rec;
    l_rec                   ben_person_object.g_person_date_info_rec;
    l_due_date              DATE;
    l_eff_due_date          DATE;
    l_elcns_made_dt         DATE;
    l_pymt_amt              number;
    l_amt_due               number;
    l_late_pymt_evt         BOOLEAN                                  := FALSE;
    l_cobra_pymt_due_dy_num ben_pl_f.cobra_pymt_due_dy_num%TYPE;
    l_organization_id       NUMBER;
    l_assignment_id         per_all_assignments_f.assignment_id%TYPE;
    l_payroll_id            per_all_assignments_f.payroll_id%TYPE;
    --
    CURSOR c_get_cbr_due_day(
      p_pl_id NUMBER) IS
      SELECT   pln.cobra_pymt_due_dy_num
      FROM     ben_pl_f pln
      WHERE    pln.pl_id = p_pl_id
      AND       nvl(g_fonm_cvg_strt_dt,p_effective_date)  BETWEEN pln.effective_start_date
                   AND pln.effective_end_date
      AND      pln.business_group_id = p_business_group_id;
--
-- -------------------------------------------------------------
-- If this cursor needs to change, check benelmen.pkb: c_get_end_dt
-- And there is a form that displays payments that uses it too.
-- see oab/flow_charts/run_results.vsd
-- -------------------------------------------------------------

  /* Bug 3097501

    CURSOR c_get_pymt(
      p_acty_base_rt_id IN NUMBER
     ,p_assignment_id   IN NUMBER
     ,p_payroll_id      IN NUMBER
     ,p_first_pymt      IN VARCHAR2) IS
      SELECT   a.result_value
      FROM     pay_run_result_values a
              ,pay_element_types_f b
              ,pay_assignment_actions d
              ,pay_payroll_actions e
              ,per_time_periods g
              ,pay_run_results h
              ,ben_acty_base_rt_f i
              ,pay_input_values_f j
      WHERE    d.assignment_id = p_assignment_id
      AND      d.payroll_action_id = e.payroll_action_id
      AND      i.input_value_id = j.input_value_id
      AND      i.element_type_id = b.element_type_id
      AND      i.acty_base_rt_id = p_acty_base_rt_id
      AND       nvl(g_fonm_cvg_strt_dt,p_effective_date) BETWEEN i.effective_start_date
                   AND i.effective_end_date
      AND      i.business_group_id = p_business_group_id
      AND      g.payroll_id = p_payroll_id
      AND      l_due_date BETWEEN g.start_date AND g.end_date
      AND      b.element_type_id = h.element_type_id
      AND      d.assignment_action_id = h.assignment_action_id
      AND      e.date_earned BETWEEN g.start_date AND g.end_date
      AND      (
                    (    p_first_pymt = 'Y'
                     AND l_due_date >= e.date_earned)
                 OR p_first_pymt = 'N')
      AND      a.input_value_id = j.input_value_id
      AND      a.run_result_id = h.run_result_id
      AND      j.element_type_id = b.element_type_id
      AND       nvl(g_fonm_cvg_strt_dt,p_effective_date) BETWEEN b.effective_start_date
                   AND b.effective_end_date
      AND      p_effective_date BETWEEN j.effective_start_date
                   AND j.effective_end_date;
    --
    CURSOR c_get_element_entry_values(
      p_element_entry_value_id IN NUMBER) IS
      SELECT   eev.screen_entry_value
      FROM     pay_element_entry_values_f eev
      WHERE    eev.element_entry_value_id = p_element_entry_value_id
      AND       nvl(g_fonm_cvg_strt_dt,p_effective_date) BETWEEN eev.effective_start_date
                 AND eev.effective_end_date;
  */

    l_from_date date;
    l_to_date date;
    l_strt_dt date;

    -- Bug 3097501 : End

    --
    CURSOR c_get_prtt_enrt_rslt IS
      SELECT   pen.pl_id
              ,prv.element_entry_value_id
              ,prv.acty_base_rt_id
              ,prv.rt_strt_dt
              ,prv.rt_end_dt
              ,prv.ann_rt_val
              ,pen.prtt_enrt_rslt_id
              ,prv.mlt_cd
              ,prv.per_in_ler_id
              ,pen.enrt_cvg_strt_dt
      FROM     ben_prtt_enrt_rslt_f pen
              ,ben_prtt_rt_val prv
      WHERE    pen.person_id = p_person_id
      AND      pen.pgm_id = p_pgm_id
      AND      pen.prtt_enrt_rslt_stat_cd IS NULL
      AND      pen.sspndd_flag = 'N'
      AND      pen.business_group_id = p_business_group_id
      AND      pen.prtt_enrt_rslt_id = prv.prtt_enrt_rslt_id
      AND      prv.business_group_id = pen.business_group_id
      AND      prv.prtt_rt_val_stat_cd IS NULL
      AND      prv.acty_typ_cd LIKE 'PBC%'
      AND      pen.effective_end_date = hr_api.g_eot
      ORDER BY prv.rt_strt_dt;

    --
    CURSOR c_get_elcns_made_dt IS
      SELECT   pel.elcns_made_dt
              ,crp.per_in_ler_id
      FROM     ben_cbr_per_in_ler crp, ben_pil_elctbl_chc_popl pel
      WHERE    crp.cbr_quald_bnf_id = p_cbr_quald_bnf_id
      AND      crp.init_evt_flag = 'Y'
      AND      crp.business_group_id = p_business_group_id
      AND      crp.per_in_ler_id = pel.per_in_ler_id
      AND      pel.pgm_id = p_pgm_id
      AND      pel.business_group_id = crp.business_group_id;
    --
    l_pen_rec               c_get_prtt_enrt_rslt%ROWTYPE;
    l_date                  date;
    l_cbr_per_in_ler_id     ben_per_in_ler.per_in_ler_id%type;
    l_month_last_day        date;
    l_allwd_underpymt_value number;
    l_allwd_underpymt_pct   number;

    l_first_pymt_shortfall_amt  number;
    l_subseq_pymt_shortfall_amt number;
    l_first_pymt_amt_due        number;
    l_subseq_pymt_amt_due       number;
    l_first_pymt_short          boolean;
    l_subseq_pymt_short         boolean;
    l_first_pymt_due_date       date;
    l_subseq_pymt_due_date      date;
    l_check_first_pymt          boolean := FALSE;
    l_check_subseq_pymt         boolean := FALSE;
    l_shortfall_amt             number;
    l_pymt_due_date             date;
  BEGIN
    g_debug := hr_utility.debug_enabled;
    --
    if g_debug then
      hr_utility.set_location('Entering ' || l_package,10);
    end if;
    --
    --
    --  If the person has not made a payment within the a grace period
    --  generate a late or non-payment life event.
    --
    ben_person_object.get_object(p_person_id=> p_person_id
     ,p_rec       => l_rec);
    --
    --  Check if the person is late with his/her payment.
    --

    -- Bug 3097501 : Start

    get_allowed_underpayment
      (p_pgm_id                => p_pgm_id
      ,p_business_group_id     => p_business_group_id
      ,p_effective_date        => p_effective_date
      ,p_allwd_underpymt_value => l_allwd_underpymt_value
      ,p_allwd_underpymt_pct   => l_allwd_underpymt_pct
      );

    l_first_pymt_shortfall_amt := 0;
    l_subseq_pymt_shortfall_amt := 0;
    l_first_pymt_amt_due := 0;
    l_subseq_pymt_amt_due := 0;

    -- Bug 3097501 : End

    FOR l_pen_rec IN c_get_prtt_enrt_rslt LOOP
      --
      -- hr_utility.set_location('Found results' || l_pen_rec.pl_id,10);
      --
      --  Check if it is the first payment.
      --
      OPEN c_get_elcns_made_dt;
      FETCH c_get_elcns_made_dt INTO l_elcns_made_dt,l_cbr_per_in_ler_id;
      CLOSE c_get_elcns_made_dt;
      --
      -- hr_utility.set_location('l_elcns_made_dt' || l_elcns_made_dt,10);
      --
      l_due_date  := l_elcns_made_dt + 45;
      --
      -- hr_utility.set_location('l_due_date' || l_due_date,10);
      --
      IF p_effective_date > l_due_date THEN
        --
        --  Get the assignment to use.
        --
        ben_element_entry.get_abr_assignment(p_person_id=> p_person_id
         ,p_effective_date  =>  nvl(g_fonm_cvg_strt_dt,p_effective_date)
         ,p_acty_base_rt_id => l_pen_rec.acty_base_rt_id
         ,p_organization_id => l_organization_id
         ,p_payroll_id      => l_payroll_id
         ,p_assignment_id   => l_assignment_id);
        --
        --  Check if a payment has been made.
        --

        -- Bug 3097501 : Start

        OPEN c_get_cbr_due_day(l_pen_rec.pl_id);
        FETCH c_get_cbr_due_day INTO l_cobra_pymt_due_dy_num;
        CLOSE c_get_cbr_due_day;

        -- Check first payment only if its the initial COBRA qualifying event
        IF l_cbr_per_in_ler_id = l_pen_rec.per_in_ler_id then

          l_check_first_pymt := TRUE;

          l_from_date := l_pen_rec.rt_strt_dt; --Rate Start Date
          l_to_date :=   LEAST(l_pen_rec.rt_end_dt,LAST_DAY(l_pen_rec.rt_strt_dt)); --Last day of month

          get_amt_due_and_shortfall (
             p_acty_base_rt_id        => l_pen_rec.acty_base_rt_id
            ,p_assignment_id          => l_assignment_id
            ,p_payroll_id             => l_payroll_id
            ,p_due_date               => l_due_date
            ,p_effective_date         => p_effective_date
            ,p_business_group_id      => p_business_group_id
            ,p_from_date              => l_from_date
            ,p_to_date                => l_to_date
            ,p_ann_rt_val             => l_pen_rec.ann_rt_val
            ,p_person_id              => p_person_id
            ,p_organization_id        => l_organization_id
            ,p_prtt_enrt_rslt_id      => l_pen_rec.prtt_enrt_rslt_id
            ,p_rt_strt_dt             => l_pen_rec.rt_strt_dt
            ,p_rt_end_dt              => l_pen_rec.rt_end_dt
            ,p_rt_mlt_cd              => l_pen_rec.mlt_cd
            ,p_shortfall_amt          => l_shortfall_amt
            ,p_amt_due                => l_amt_due
            ,p_pymt_short             => l_first_pymt_short);

          l_first_pymt_shortfall_amt := l_first_pymt_shortfall_amt + l_shortfall_amt;
          l_first_pymt_amt_due       := l_first_pymt_amt_due + l_amt_due;

          l_pymt_due_date := LAST_DAY(ADD_MONTHS(l_pen_rec.rt_strt_dt,-1))
                             + NVL(l_cobra_pymt_due_dy_num,1);

          -- Life Event Occured Date for NOLP event triggered for the first payment
          -- is to be set to the greater of First Month COBRA Due Date and
          -- Coverage Start Date
          l_pymt_due_date := GREATEST(l_pymt_due_date,l_pen_rec.enrt_cvg_strt_dt);

          IF l_first_pymt_short THEN
            IF l_first_pymt_due_date IS NULL THEN
              l_first_pymt_due_date := l_pymt_due_date;
            ELSIF l_pymt_due_date < l_first_pymt_due_date THEN
              l_first_pymt_due_date := l_pymt_due_date;
            END IF;
          END IF;

        END IF;

        --
        -- if it is not the first payment, check if a payment is
        -- due.
        --
        IF l_cobra_pymt_due_dy_num IS NOT NULL THEN

         -- hr_utility.set_location('Found due day' || l_cobra_pymt_due_dy_num,10);
          -- Get the last due date to check if the person is late with
          --  his/her payment.
          --
          l_due_date := LAST_DAY(ADD_MONTHS(p_effective_date,-2)) +
                      l_cobra_pymt_due_dy_num;

          -- Bug 3208938
          -- If COBRA due day falls outside the month, use last day of month

          l_month_last_day := LAST_DAY(ADD_MONTHS(p_effective_date,-1));

          if l_due_date > l_month_last_day then
            l_due_date := l_month_last_day;
          end if;

          -- Bug 3208938

          l_eff_due_date  := l_due_date + 30;
          --
          -- hr_utility.set_location('l_due_date' || l_due_date,10);
          -- hr_utility.set_location('l_eff_due_date' || l_eff_due_date,10);
          --
          --  if the person has not made a payment by the due date, create
          --  a potential life event.
          --

          if l_cbr_per_in_ler_id = l_pen_rec.per_in_ler_id then
            l_strt_dt := LAST_DAY(l_pen_rec.rt_strt_dt) + 1;
          else
            l_strt_dt := LAST_DAY(ADD_MONTHS(l_pen_rec.rt_strt_dt,-1)) + 1;
          end if;

          IF p_effective_date <= l_eff_due_date THEN
            -- Bug 3125085 - If the temporal process is run before the
            -- last month's payment has become overdue, then
            -- check if payment for month prior to the last
            -- month is paid in full
            l_due_date :=  LAST_DAY(ADD_MONTHS(p_effective_date,-3)) +
                          l_cobra_pymt_due_dy_num;

            -- Bug 3208938
            -- If COBRA due day falls outside the month, use last day of month

            l_month_last_day := LAST_DAY(ADD_MONTHS(p_effective_date,-2));

            if l_due_date > l_month_last_day then
              l_due_date := l_month_last_day;
            end if;

            -- Bug 3208938

            l_eff_due_date  := l_due_date + 30;
          END IF;

          if g_debug then
            hr_utility.set_location('l_due_date '||l_due_date,11);
            hr_utility.set_location('l_strt_dt'||l_strt_dt,11);
          end if;

          IF (l_due_date >= l_strt_dt) AND (l_due_date <= LAST_DAY(l_pen_rec.rt_end_dt)) THEN

            l_check_subseq_pymt := TRUE;

            l_from_date := GREATEST((LAST_DAY(ADD_MONTHS(l_due_date,-1)) + 1),l_pen_rec.rt_strt_dt); --Month Start Date
            l_to_date :=   LEAST(l_pen_rec.rt_end_dt,LAST_DAY(l_due_date)); --Last day of month

            get_amt_due_and_shortfall(
                p_acty_base_rt_id        => l_pen_rec.acty_base_rt_id
               ,p_assignment_id          => l_assignment_id
               ,p_payroll_id             => l_payroll_id
               ,p_due_date               => l_eff_due_date
               ,p_effective_date         => p_effective_date
               ,p_business_group_id      => p_business_group_id
               ,p_from_date              => l_from_date
               ,p_to_date                => l_to_date
               ,p_ann_rt_val             => l_pen_rec.ann_rt_val
               ,p_person_id              => p_person_id
               ,p_organization_id        => l_organization_id
               ,p_prtt_enrt_rslt_id      => l_pen_rec.prtt_enrt_rslt_id
               ,p_rt_strt_dt             => l_pen_rec.rt_strt_dt
               ,p_rt_end_dt              => l_pen_rec.rt_end_dt
               ,p_rt_mlt_cd              => l_pen_rec.mlt_cd
               ,p_shortfall_amt          => l_shortfall_amt
               ,p_amt_due                => l_amt_due
               ,p_pymt_short             => l_subseq_pymt_short);


            l_subseq_pymt_shortfall_amt := l_subseq_pymt_shortfall_amt + l_shortfall_amt;
            l_subseq_pymt_amt_due       := l_subseq_pymt_amt_due + l_amt_due;

            IF l_subseq_pymt_short THEN
              IF l_subseq_pymt_due_date IS NULL THEN
                l_subseq_pymt_due_date := l_due_date;
              ELSIF l_due_date < l_subseq_pymt_due_date THEN
                l_subseq_pymt_due_date := l_due_date;
              END IF;
            END IF;

          END IF;
        END IF;
      END IF;
    END LOOP;

    IF l_check_first_pymt THEN
      l_late_pymt_evt := is_payment_late
                           (p_amt_due               => l_first_pymt_amt_due
                           ,p_shortfall_amt         => l_first_pymt_shortfall_amt
                           ,p_allwd_underpymt_value => l_allwd_underpymt_value
                           ,p_allwd_underpymt_pct   => l_allwd_underpymt_pct);

      l_lf_evt_ocrd_dt := l_first_pymt_due_date;
    END IF;

    IF (NOT l_late_pymt_evt) AND (l_check_subseq_pymt) THEN
      l_late_pymt_evt := is_payment_late
                           (p_amt_due               => l_subseq_pymt_amt_due
                           ,p_shortfall_amt         => l_subseq_pymt_shortfall_amt
                           ,p_allwd_underpymt_value => l_allwd_underpymt_value
                           ,p_allwd_underpymt_pct   => l_allwd_underpymt_pct);

      l_lf_evt_ocrd_dt := l_subseq_pymt_due_date;
    END IF;

    -- Bug 3097501: End
    --
    -- hr_utility.set_location('l_due_date' || l_due_date,10);
    --
    IF l_late_pymt_evt THEN
      --
      IF l_lf_evt_ocrd_dt >= l_rec.min_ass_effective_start_date THEN
        --
        IF  (   l_lf_evt_ocrd_dt < p_effective_date
           AND NVL(p_ptnl_ler_trtmt_cd
                ,'-1') = 'IGNR' OR NVL(p_ptnl_ler_trtmt_cd,'-1') = 'IGNRALL') THEN
          --
          -- We are not creating past life events
          --
          NULL;
        --
        ELSE
          --
          ben_seeddata_object.get_object(p_rec=> l_der_rec);
          --
          IF no_life_event(p_lf_evt_ocrd_dt=> l_lf_evt_ocrd_dt
              ,p_person_id      => p_person_id
              ,p_ler_id         => l_der_rec.drvdnlp_id
              ,p_effective_date => p_effective_date)
          THEN
            --
            create_ptl_ler
              (p_calculate_only_mode => p_calculate_only_mode
              ,p_ler_id              => l_der_rec.drvdnlp_id
              ,p_lf_evt_ocrd_dt      => l_lf_evt_ocrd_dt
              ,p_person_id           => p_person_id
              ,p_business_group_id   => p_business_group_id
              ,p_effective_date      => p_effective_date
              );
          --
          END IF;
        --
        END IF;
      --
      END IF;
    --
    END IF;                                                    -- late payment
    --
    if g_debug then
      hr_utility.set_location('Leaving ' || l_package,10);
    end if;
  --
  END determine_cobra_payments;
--
--
  PROCEDURE determine_cobra_eligibility
    (p_calculate_only_mode in     boolean default false
    ,p_person_id           IN     NUMBER
    ,p_business_group_id   IN     NUMBER
    ,p_pgm_id              IN     NUMBER
    ,p_ptip_id             IN     NUMBER DEFAULT NULL
    ,p_ptnl_ler_trtmt_cd   IN     VARCHAR2
    ,p_effective_date      IN     DATE
    ,p_lf_evt_ocrd_dt      IN     DATE
    ,p_derivable_factors   IN     VARCHAR2
    )
  IS
    --
    l_package                  VARCHAR2(80)
                                := g_package || '.determine_cobra_eligibility';
    l_lf_evt_ocrd_dt           DATE;
    l_end_elig_date            DATE;
    l_dsbld                    BOOLEAN                               := FALSE;
    l_ok                       BOOLEAN;
    l_exists                   VARCHAR2(1);
    l_der_rec                  ben_seeddata_object.g_derived_factor_info_rec;
    l_dys_no_enrl_not_elig_num ben_lee_rsn_f.dys_no_enrl_not_elig_num%TYPE;
    l_rec                      ben_person_object.g_person_date_info_rec;
    l_per_in_ler_id            ben_per_in_ler.per_in_ler_id%TYPE;
    l_object_version_number    ben_cbr_quald_bnf.object_version_number%TYPE;
    l_effective_date           DATE;
    l_due_date                 DATE;
    l_eff_due_date             DATE;
    l_elcns_made_dt            DATE;
    l_cbr_elig_perd_end_dt     ben_cbr_quald_bnf.cbr_elig_perd_end_dt%TYPE;
    l_init_lf_evt_ocrd_dt      ben_per_in_ler.lf_evt_ocrd_dt%TYPE;
    l_ler_id                   ben_per_in_ler.ler_id%TYPE;
    --
    CURSOR c_get_cbr_elig_dates IS
      SELECT   cqb.*
              ,crp.per_in_ler_id
              ,pil.ler_id
      FROM     ben_cbr_quald_bnf cqb
              ,ben_cbr_per_in_ler crp
              ,ben_per_in_ler pil
      WHERE    cqb.quald_bnf_person_id = p_person_id
      AND      cqb.quald_bnf_flag = 'Y'
      AND      cqb.pgm_id = NVL(p_pgm_id
                             ,cqb.pgm_id)
      AND      NVL(cqb.ptip_id
                ,NVL(p_ptip_id
                  ,-1)) = NVL(p_ptip_id
                           ,-1)
      AND      cqb.business_group_id = p_business_group_id
      AND      cqb.cbr_quald_bnf_id = crp.cbr_quald_bnf_id
      AND      crp.init_evt_flag = 'Y'
      AND      crp.per_in_ler_id = pil.per_in_ler_id
      AND      crp.business_group_id = cqb.business_group_id
     -- AND      crp.business_group_id = pil.business_group_id
      AND      pil.per_in_ler_stat_cd NOT IN ('VOIDD', 'BCKDT');
    --
    -- Check if it is not initial event.
    --
    CURSOR c_get_init_evt(
      p_cbr_quald_bnf_id IN NUMBER) IS
      SELECT   NULL
      FROM     ben_cbr_per_in_ler crp, ben_per_in_ler pil
      WHERE    crp.cbr_quald_bnf_id = p_cbr_quald_bnf_id
      AND      crp.per_in_ler_id = pil.per_in_ler_id
      AND      pil.per_in_ler_stat_cd NOT IN ('VOIDD', 'BCKDT')
      AND      crp.business_group_id = pil.business_group_id
      AND      crp.business_group_id = p_business_group_id
      AND      crp.init_evt_flag = 'N';
    CURSOR c_get_per_in_ler(
      p_cbr_quald_bnf_id IN NUMBER) IS
      SELECT   crp.per_in_ler_id
      FROM     ben_cbr_per_in_ler crp, ben_per_in_ler pil
      WHERE    crp.cbr_quald_bnf_id = p_cbr_quald_bnf_id
      AND      crp.per_in_ler_id = pil.per_in_ler_id
      AND      pil.per_in_ler_stat_cd NOT IN ('VOIDD', 'BCKDT')
    -- AND      crp.business_group_id = pil.business_group_id
      AND      crp.business_group_id = p_business_group_id
      AND      crp.init_evt_flag = 'Y';
    --
    CURSOR c_get_enrt_perd_dates(
     p_pgm_id        IN NUMBER) IS
      SELECT   pel.*
      FROM     ben_pil_elctbl_chc_popl pel
              ,ben_per_in_ler pil
      WHERE    pel.pgm_id = p_pgm_id
      AND      pel.per_in_ler_id = pil.per_in_ler_id
      and      pil.person_id = p_person_id
      AND      pel.business_group_id = p_business_group_id
      AND      pel.business_group_id = pil.business_group_id
      AND      pil.per_in_ler_stat_cd NOT IN ('VOIDD', 'BCKDT')
      ORDER BY pel.enrt_perd_end_dt desc;
    --
    CURSOR c_get_elig_days(
      p_lee_rsn_id NUMBER) IS
      SELECT   len.dys_no_enrl_not_elig_num
      FROM     ben_lee_rsn_f len
      WHERE    len.lee_rsn_id = p_lee_rsn_id
      AND      len.business_group_id = p_business_group_id
      AND      NVL(p_lf_evt_ocrd_dt
                ,p_effective_date) BETWEEN len.effective_start_date
                   AND len.effective_end_date;
    --
    CURSOR c_get_dsblity_evt(
      p_cbr_quald_bnf_id NUMBER) IS
      SELECT   crp.*
      FROM     ben_cbr_per_in_ler crp, ben_ler_f ler, ben_per_in_ler pil
      WHERE    crp.cbr_quald_bnf_id = p_cbr_quald_bnf_id
      AND      crp.per_in_ler_id = pil.per_in_ler_id
      AND      pil.ler_id = ler.ler_id
      AND      ler.typ_cd = 'DSBLTY'
      AND      ler.qualg_evt_flag = 'Y'
      AND      NVL(p_lf_evt_ocrd_dt
                ,p_effective_date) BETWEEN ler.effective_start_date
                   AND ler.effective_end_date
      AND      ler.business_group_id = p_business_group_id
      AND      ler.business_group_id = pil.business_group_id
      AND      pil.per_in_ler_stat_cd NOT IN ('VOIDD', 'BCKDT')
      AND      crp.cnt_num =
               (SELECT   MAX(cnt_num)
                FROM     ben_cbr_per_in_ler crp2, ben_per_in_ler pil2
                WHERE    crp2.cbr_quald_bnf_id = p_cbr_quald_bnf_id
                AND      crp2.per_in_ler_id = pil2.per_in_ler_id
                AND      pil2.per_in_ler_stat_cd NOT IN ('VOIDD', 'BCKDT')
                AND      crp2.business_group_id = p_business_group_id
               -- AND      crp2.business_group_id = pil2.business_group_id
               );
    --
    CURSOR c_get_all_quald_bnf(
      p_cvrd_emp_person_id IN NUMBER
     ,p_pgm_id             IN NUMBER
     ,p_ptip_id            IN NUMBER) IS
      SELECT   cqb.*
      FROM     ben_cbr_quald_bnf cqb
              ,ben_cbr_per_in_ler crp
              ,ben_per_in_ler pil
      WHERE    cqb.cvrd_emp_person_id = p_cvrd_emp_person_id
      AND      cqb.quald_bnf_flag = 'Y'
      AND      l_effective_date BETWEEN cqb.cbr_elig_perd_strt_dt
                   AND cqb.cbr_elig_perd_end_dt
      AND      cqb.business_group_id = p_business_group_id
      AND      cqb.cbr_quald_bnf_id = crp.cbr_quald_bnf_id
      AND      cqb.pgm_id = p_pgm_id
      AND      NVL(cqb.ptip_id
                ,-1) = NVL(p_ptip_id
                        ,-1)
      AND      crp.per_in_ler_id = pil.per_in_ler_id
      AND      crp.business_group_id = cqb.business_group_id
      --AND      pil.business_group_id = crp.business_group_id
      AND      crp.init_evt_flag = 'Y'
      AND      pil.per_in_ler_stat_cd NOT IN ('VOIDD', 'BCKDT');
    --
    CURSOR c_get_max_poe(
      p_ler_id  IN NUMBER
     ,p_pgm_id  IN NUMBER
     ,p_ptip_id IN NUMBER) IS
      SELECT   peo.*
      FROM     ben_elig_to_prte_rsn_f peo
      WHERE    peo.ler_id = p_ler_id
      AND      peo.business_group_id = p_business_group_id
      AND      NVL(p_lf_evt_ocrd_dt
                ,p_effective_date) BETWEEN peo.effective_start_date
                   AND peo.effective_end_date
      AND      NVL(peo.pgm_id
                ,p_pgm_id) = p_pgm_id
      AND      NVL(peo.ptip_id
                ,-1) = NVL(p_ptip_id
                        ,-1)
      AND      (   peo.mx_poe_val IS NOT NULL
                OR peo.mx_poe_rl IS NOT NULL);
    --
    CURSOR c_chk_lf_evt IS
      SELECT   NULL
      FROM     ben_per_in_ler pil
      WHERE    pil.person_id = p_person_id
      AND      pil.business_group_id = p_business_group_id
      AND      pil.lf_evt_ocrd_dt = l_lf_evt_ocrd_dt
      AND      pil.ler_id <> l_ler_id
      AND      pil.per_in_ler_stat_cd NOT IN ('VOIDD', 'BCKDT');
    --
    CURSOR c_cbr_quald_bnf IS
      SELECT   cqb.cbr_quald_bnf_id
              ,cqb.pgm_id
              ,cqb.ptip_id
              ,crp.per_in_ler_id
              ,pil.ler_id
      FROM     ben_cbr_quald_bnf cqb
              ,ben_cbr_per_in_ler crp
              ,ben_per_in_ler pil
      WHERE    cqb.quald_bnf_person_id = p_person_id
      AND      cqb.quald_bnf_flag = 'Y'
      AND      cqb.pgm_id = p_pgm_id
      AND      cqb.business_group_id = p_business_group_id
      AND      cqb.cbr_quald_bnf_id = crp.cbr_quald_bnf_id
      AND      crp.init_evt_flag = 'Y'
      AND      crp.per_in_ler_id = pil.per_in_ler_id
      AND      crp.business_group_id = cqb.business_group_id
      AND      pil.per_in_ler_stat_cd NOT IN ('VOIDD', 'BCKDT');
    --
    l_cqb_rec                  c_get_cbr_elig_dates%ROWTYPE;
    l_pel_rec                  c_get_enrt_perd_dates%ROWTYPE;
    l_crp_rec                  c_get_dsblity_evt%ROWTYPE;
    l_poe_rec                  c_get_max_poe%ROWTYPE;
    l_cbr_quald_bnf            c_cbr_quald_bnf%ROWTYPE;
  BEGIN
    --
   -- hr_utility.set_location('Entering ' || l_package,10);
   -- hr_utility.set_location('p_pgm_id ' || p_pgm_id,10);
   -- hr_utility.set_location('p_ptip_id ' || p_ptip_id,10);
    --
    --
    l_effective_date  := NVL(p_lf_evt_ocrd_dt
                          ,p_effective_date);
    --
    -- 1) If person has reached the maximum allowable period of enrollment in
    --    a COBRA program, then create a ptnl_per_in_ler
    -- 2) If a person does not enroll in the COBRA program or waives coverage,
    --    create a potential per_in_ler.
    -- 3) If the person is disabled, check if process needs to recalculate
    --    the rates. For disablity, the rates for the extended period can
    --    be 150% of premium as opposed to 102% of premium for the first 18
    --    months. This is at the discretion of the employer.
    --
    ben_person_object.get_object(p_person_id=> p_person_id
     ,p_rec       => l_rec);
    --
    OPEN c_get_cbr_elig_dates;
    FETCH c_get_cbr_elig_dates INTO l_cqb_rec;
    IF c_get_cbr_elig_dates%FOUND THEN
      CLOSE c_get_cbr_elig_dates;
      --
      IF p_derivable_factors IN ('ALL', 'PBEV', 'BEV', 'BEVASC') THEN
        --
       -- hr_utility.set_location('found ' || l_cqb_rec.cbr_elig_perd_end_dt,10);
       -- hr_utility.set_location('ALL PBEV BEV BEVASC' ||l_cqb_rec.cbr_elig_perd_end_dt,10);
        --
        IF l_effective_date >= l_cqb_rec.cbr_elig_perd_end_dt THEN
          --
         -- hr_utility.set_location('Found ' || l_cqb_rec.cbr_elig_perd_end_dt,10);
          --
          --  WWBUG# 1166172 - Change the life event occurred date to one
          --  day after the date reached.
          --
          l_lf_evt_ocrd_dt  := l_cqb_rec.cbr_elig_perd_end_dt + 1;
          --
          IF l_lf_evt_ocrd_dt >= l_rec.min_ass_effective_start_date THEN
            --
            IF   (  l_lf_evt_ocrd_dt < p_effective_date
               AND NVL(p_ptnl_ler_trtmt_cd
                    ,'-1') = 'IGNR' OR NVL(p_ptnl_ler_trtmt_cd,'-1') = 'IGNRALL') THEN
              --
              -- We are not creating past life events
              --
              NULL;
            --
            ELSE
              --
              ben_seeddata_object.get_object(p_rec=> l_der_rec);
              --
              --  If cobra ineligible reason is null or if
              --  the reason code is Maximum Period of Enrollment reached.
              --  The cobra ineligible reason code is updated on the COBRA
              --  qualified beneficiary form and would be specified if a
              --  user change the cobra eligibility end date for the qualified
              --  beneficiary.
              --
              IF (
                      l_cqb_rec.cbr_inelg_rsn_cd IS NULL
                   OR l_cqb_rec.cbr_inelg_rsn_cd = 'POE') THEN
                --
               -- hr_utility.set_location('POE ' || l_der_rec.drvdpoeelg_id,10);
                IF no_life_event(p_lf_evt_ocrd_dt=> l_lf_evt_ocrd_dt
                    ,p_person_id      => p_person_id
                    ,p_ler_id         => l_der_rec.drvdpoeelg_id
                    ,p_effective_date => p_effective_date)
                THEN
                  --
                  create_ptl_ler
                    (p_calculate_only_mode => p_calculate_only_mode
                    ,p_ler_id              => l_der_rec.drvdpoeelg_id
                    ,p_lf_evt_ocrd_dt      => l_lf_evt_ocrd_dt
                    ,p_person_id           => p_person_id
                    ,p_business_group_id   => p_business_group_id
                    ,p_effective_date      => p_effective_date
                    );
                  --
                END IF;
              --
              ELSIF l_cqb_rec.cbr_inelg_rsn_cd = 'NLP' THEN
                --
                IF no_life_event(p_lf_evt_ocrd_dt=> l_lf_evt_ocrd_dt
                    ,p_person_id      => p_person_id
                    ,p_ler_id         => l_der_rec.drvdnlp_id
                    ,p_effective_date => p_effective_date)
                THEN
                  --
                 -- hr_utility.set_location('NLP ' || l_der_rec.drvdnlp_id,10);
                  --
                  create_ptl_ler
                    (p_calculate_only_mode => p_calculate_only_mode
                    ,p_ler_id              => l_der_rec.drvdnlp_id
                    ,p_lf_evt_ocrd_dt      => l_lf_evt_ocrd_dt
                    ,p_person_id           => p_person_id
                    ,p_business_group_id   => p_business_group_id
                    ,p_effective_date      => p_effective_date
                    );
                  --
                END IF;
              --
              --  Voluntary End of Coverage.
              --
              ELSIF l_cqb_rec.cbr_inelg_rsn_cd = 'VEC' THEN
               -- hr_utility.set_location('VEC ' || l_der_rec.drvdvec_id,10);
                --
                -- Check if a life event exist on the same day.
                --
                l_ler_id  := l_der_rec.drvdvec_id;
                --
                OPEN c_chk_lf_evt;
                FETCH c_chk_lf_evt INTO l_exists;
                IF c_chk_lf_evt%FOUND THEN
                  l_lf_evt_ocrd_dt  := l_lf_evt_ocrd_dt + 1;
                END IF;
                --
                CLOSE c_chk_lf_evt;
                --
                IF no_life_event(p_lf_evt_ocrd_dt=> l_lf_evt_ocrd_dt
                    ,p_person_id      => p_person_id
                    ,p_ler_id         => l_der_rec.drvdvec_id
                    ,p_effective_date => p_effective_date)
                THEN
                  --
                  create_ptl_ler
                    (p_calculate_only_mode => p_calculate_only_mode
                    ,p_ler_id              => l_der_rec.drvdvec_id
                    ,p_lf_evt_ocrd_dt      => l_lf_evt_ocrd_dt
                    ,p_person_id           => p_person_id
                    ,p_business_group_id   => p_business_group_id
                    ,p_effective_date      => p_effective_date
                    );
                  --
                END IF;
              END IF;
            --
            END IF;
          --
          END IF;
        --
        ELSE                            -- If we have not reached the max poe.
          --
          --  Check if this is the initial event and the person did not enroll
          --  in the cobra program.
          --
          OPEN c_get_init_evt(l_cqb_rec.cbr_quald_bnf_id);
          FETCH c_get_init_evt INTO l_exists;
          IF c_get_init_evt%NOTFOUND THEN
            -- hr_utility.set_location('pgm_id ' || l_cqb_rec.pgm_id,10);
            -- hr_utility.set_location('ptip_id ' || l_cqb_rec.ptip_id,10);
            --
            --  Get the most recent enrollment period.
            --
            OPEN c_get_enrt_perd_dates(l_cqb_rec.pgm_id);
            FETCH c_get_enrt_perd_dates INTO l_pel_rec;
            IF c_get_enrt_perd_dates%FOUND THEN
              -- hr_utility.set_location('found enrt perd ' ||l_pel_rec.enrt_perd_end_dt,10);
              CLOSE c_get_enrt_perd_dates;
              --
              --  Get the number days from the start of the enrollment
              --  period before the person is found ineligible.
              --
              OPEN c_get_elig_days(l_pel_rec.lee_rsn_id);
              FETCH c_get_elig_days INTO l_dys_no_enrl_not_elig_num;
              CLOSE c_get_elig_days;
              IF l_dys_no_enrl_not_elig_num IS NULL THEN
                --
                --  If not found, use enrollment period end date.
                --
                l_end_elig_date  := l_pel_rec.enrt_perd_end_dt;
              ELSE
                l_end_elig_date  :=
                   l_pel_rec.enrt_perd_strt_dt + l_dys_no_enrl_not_elig_num;
              END IF;
              --
              -- If running this process ahead of time, the ineligible to
              -- event cannot be triggered. Check if the enrollment period
              -- has passed using the system date.
              --
              -- hr_utility.set_location('l_end_elig_date ' || l_end_elig_date,10);
              --
              -- hr_utility.set_location('effective_date ' ||l_effective_date,10);
              IF LEAST(SYSDATE
                  ,l_effective_date) > l_end_elig_date THEN
                IF (
                  ben_cobra_requirements.chk_enrld_or_cvrd(p_pgm_id=> l_cqb_rec.pgm_id
                 ,p_ptip_id           => l_cqb_rec.ptip_id
                 ,p_person_id         => p_person_id
                 ,p_effective_date    => p_effective_date
                 ,p_business_group_id => p_business_group_id
                 ,p_cvrd_today        => 'Y'
                )) = FALSE THEN
                  --
                  --  If enrollment period has passed,
                  --  created a loss of eligibility
                  --  potential per in ler.
                  --
                  -- hr_utility.set_location('trigger inelig event ',10);
                  --
                  --  Set the COBRA qualified beneficiary flag to 'N' as the
                  --  person is no longer a COBRA qualified beneficiary.
                  --
                  l_object_version_number  := l_cqb_rec.object_version_number;
                  --
                  ben_cbr_quald_bnf_api.update_cbr_quald_bnf
                   (p_cbr_quald_bnf_id=> l_cqb_rec.cbr_quald_bnf_id
                   ,p_quald_bnf_flag        => 'N'
                   ,p_business_group_id     => p_business_group_id
                   ,p_object_version_number => l_object_version_number
                   ,p_effective_date        => p_effective_date);
                  --
                  l_lf_evt_ocrd_dt         := l_end_elig_date + 1;
                  --
                  IF l_lf_evt_ocrd_dt >= l_rec.min_ass_effective_start_date THEN
                    --
                    IF   (  l_lf_evt_ocrd_dt < p_effective_date
                       AND NVL(p_ptnl_ler_trtmt_cd
                            ,'-1') = 'IGNR' OR NVL(p_ptnl_ler_trtmt_cd,'-1') = 'IGNRALL') THEN
                      --
                      -- We are not creating past life events
                      --
                      NULL;
                    --
                    ELSE
                      --
                      ben_seeddata_object.get_object(p_rec=> l_der_rec);
                      --
                      IF no_life_event(p_lf_evt_ocrd_dt=> l_lf_evt_ocrd_dt
                          ,p_person_id      => p_person_id
                          ,p_ler_id         => l_der_rec.drvdlselg_id
                          ,p_effective_date => p_effective_date)
                      THEN
                        --
                        create_ptl_ler
                          (p_calculate_only_mode => p_calculate_only_mode
                          ,p_ler_id              => l_der_rec.drvdlselg_id
                          ,p_lf_evt_ocrd_dt      => l_lf_evt_ocrd_dt
                          ,p_person_id           => p_person_id
                          ,p_business_group_id   => p_business_group_id
                          ,p_effective_date      => p_effective_date
                          );
                        --
                      END IF;
                    --
                    END IF;
                  --
                  END IF;
                END IF; -- End Enrollment check.
              END IF; -- End date check.
            ELSE
              CLOSE c_get_enrt_perd_dates;
            END IF;
          END IF;
          --
          --  Check if we need to trigger an event for a Disability rate change.
          --
          --  Check if any of the qualified beneficiaries are currently disabled.
          --
          FOR l_cqb2_rec IN c_get_all_quald_bnf(l_cqb_rec.cvrd_emp_person_id
                             ,l_cqb_rec.pgm_id
                             ,l_cqb_rec.ptip_id) LOOP
            IF ben_cobra_requirements.chk_dsbld(p_person_id=> l_cqb2_rec.quald_bnf_person_id
                ,p_lf_evt_ocrd_dt    => l_effective_date
                ,p_effective_date    => p_effective_date
                ,p_business_group_id => p_business_group_id) = TRUE THEN
              --
              --  Check if person was disabled at the time of the initial
              --  qualifying event.
              --
              l_init_lf_evt_ocrd_dt  :=
                ben_cobra_requirements.get_lf_evt_ocrd_dt(p_per_in_ler_id=> l_cqb_rec.per_in_ler_id
                 ,p_business_group_id => p_business_group_id);
              --
              IF ben_cobra_requirements.chk_dsbld(p_person_id=> l_cqb2_rec.quald_bnf_person_id
                  ,p_lf_evt_ocrd_dt    => l_init_lf_evt_ocrd_dt
                  ,p_effective_date    => p_effective_date
                  ,p_business_group_id => p_business_group_id) = TRUE THEN
                --
                --   Calculate the original eligibility end date.
                --
                OPEN c_get_max_poe(l_cqb_rec.ler_id
                 ,l_cqb_rec.pgm_id
                 ,l_cqb_rec.ptip_id);
                FETCH c_get_max_poe INTO l_poe_rec;
                IF c_get_max_poe%FOUND THEN
                  --
                  l_dsbld                 := TRUE;
                  --
                  CLOSE c_get_max_poe;
                  l_cbr_elig_perd_end_dt  :=
                    ben_cobra_requirements.get_cbr_elig_end_dt(p_cbr_elig_perd_strt_dt=> l_cqb_rec.cbr_elig_perd_strt_dt
                     ,p_person_id             => p_person_id
                     --RCHASE pass pl typ id
                     ,p_pl_typ_id             => l_cqb_rec.pl_typ_id
                     --RCHASE end
                     ,p_mx_poe_uom            => l_poe_rec.mx_poe_uom
                     ,p_mx_poe_val            => l_poe_rec.mx_poe_val
                     ,p_mx_poe_rl             => l_poe_rec.mx_poe_rl
                     ,p_pgm_id                => l_cqb_rec.pgm_id
                     ,p_effective_date        => l_effective_date
                     ,p_business_group_id     => p_business_group_id
                     ,p_ler_id                => l_poe_rec.ler_id);
                ELSE
                  CLOSE c_get_max_poe;
                END IF;
              --
              -- Check if we are currently in the extended period.
              --
              ELSE
                --
                --  Check if person was disabled within the first 60 days
                --  of the qualifying event.
                --
                OPEN c_get_dsblity_evt(l_cqb_rec.cbr_quald_bnf_id);
                FETCH c_get_dsblity_evt INTO l_crp_rec;
                IF c_get_dsblity_evt%FOUND THEN
                  CLOSE c_get_dsblity_evt;
                  l_dsbld                 := TRUE;
                  l_cbr_elig_perd_end_dt  := l_crp_rec.prvs_elig_perd_end_dt;
                ELSE
                  CLOSE c_get_dsblity_evt;
                END IF;
              --
              END IF;
              --
              IF l_dsbld THEN
                --
                -- If we are currently in the extended period, trigger
                -- a ptnl life event.
                --
                IF l_effective_date > l_cbr_elig_perd_end_dt THEN
                  --
                  l_lf_evt_ocrd_dt  := l_cbr_elig_perd_end_dt + 1;
                  --
                  IF l_lf_evt_ocrd_dt >= l_rec.min_ass_effective_start_date THEN
                    --
                    IF   (  l_lf_evt_ocrd_dt < p_effective_date
                       AND NVL(p_ptnl_ler_trtmt_cd
                            ,'-1') = 'IGNR' OR NVL(p_ptnl_ler_trtmt_cd,'-1') = 'IGNRALL') THEN
                      --
                      -- We are not creating past life events
                      --
                      NULL;
                    --
                    ELSE
                      --
                      ben_seeddata_object.get_object(p_rec=> l_der_rec);
                      --
                      IF no_life_event(p_lf_evt_ocrd_dt=> l_lf_evt_ocrd_dt
                          ,p_person_id      => p_person_id
                          ,p_ler_id         => l_der_rec.drvdpoert_id
                          ,p_effective_date => p_effective_date)
                      THEN
                        --
                        create_ptl_ler
                          (p_calculate_only_mode => p_calculate_only_mode
                          ,p_ler_id              => l_der_rec.drvdpoert_id
                          ,p_lf_evt_ocrd_dt      => l_lf_evt_ocrd_dt
                          ,p_person_id           => p_person_id
                          ,p_business_group_id   => p_business_group_id
                          ,p_effective_date      => p_effective_date
                          );
                        --
                      END IF;
                    --
                    END IF;
                  --
                  END IF;
                --
                END IF;
                --
                EXIT;
              END IF;                                       -- l_dsbld is true
            --
            END IF;
          END LOOP;

        END IF;                                    --  end cbr_elig_date found
      END IF;                          -- p_derivable_factors in 'ALL' etc.. .
      --
    --
    ELSE                             -- cobra qualified beneficiary not found.
     -- hr_utility.set_location('not found ',10);
      CLOSE c_get_cbr_elig_dates;
    END IF;

    -- Bug 3097501
    -- Call determine_cobra_payments only once for the COBRA program
    -- All Plans in the Program will be checked for NOLP in this call
    -- This is required for handling Insignificant Underpayments
    IF p_pgm_id IS NOT NULL THEN

      IF p_derivable_factors IN ('ALL', 'P', 'PASC', 'PBEV') THEN
        OPEN c_cbr_quald_bnf;
        FETCH c_cbr_quald_bnf INTO l_cbr_quald_bnf;
        IF c_cbr_quald_bnf%FOUND THEN
          --
          --  Check if the person is late with his/her payment.
          --
          determine_cobra_payments
            (p_calculate_only_mode => p_calculate_only_mode
            ,p_person_id           => p_person_id
            ,p_business_group_id   => p_business_group_id
            ,p_ptnl_ler_trtmt_cd   => p_ptnl_ler_trtmt_cd
            ,p_effective_date      => l_effective_date
            ,p_pgm_id              => l_cbr_quald_bnf.pgm_id
            ,p_ptip_id             => l_cbr_quald_bnf.ptip_id
            ,p_cbr_quald_bnf_id    => l_cbr_quald_bnf.cbr_quald_bnf_id
            );
        END IF;
        CLOSE c_cbr_quald_bnf;
      END IF;
    END IF;

    --
   -- hr_utility.set_location('Leaving ' || l_package,10);
  --
  END determine_cobra_eligibility;
--
  PROCEDURE derive_rates_and_factors
    (p_calculate_only_mode in     boolean default false
    ,p_comp_obj_tree_row   IN OUT NOCOPY ben_manage_life_events.g_cache_proc_objects_rec
    --
    -- Context info
    --
    ,p_per_row           IN OUT NOCOPY per_all_people_f%ROWTYPE
    ,p_empasg_row        IN OUT NOCOPY per_all_assignments_f%ROWTYPE
    ,p_benasg_row        IN OUT NOCOPY per_all_assignments_f%ROWTYPE
    ,p_pil_row           IN OUT NOCOPY ben_per_in_ler%ROWTYPE
    --
    ,p_mode              IN            VARCHAR2 DEFAULT NULL
    --
    ,p_effective_date    IN            DATE
    ,p_lf_evt_ocrd_dt    IN            DATE
    ,p_person_id         IN            NUMBER
    ,p_business_group_id IN            NUMBER
    ,p_pgm_id            IN            NUMBER DEFAULT NULL
    ,p_pl_id             IN            NUMBER DEFAULT NULL
    ,p_oipl_id           IN            NUMBER DEFAULT NULL
    ,p_plip_id           IN            NUMBER DEFAULT NULL
    ,p_ptip_id           IN            NUMBER DEFAULT NULL
    ,p_ptnl_ler_trtmt_cd IN            VARCHAR2 DEFAULT NULL
    ,p_derivable_factors IN            VARCHAR2 DEFAULT 'ASC'
    ,p_comp_rec          IN OUT NOCOPY g_cache_structure
    ,p_oiplip_rec        IN OUT NOCOPY g_cache_structure
    )
IS
   --
   cursor c_get_pgm_typ(cv_pgm_id in number,
                        cv_effective_date in date ) is
     select pgm_typ_cd
     from ben_pgm_f
     where pgm_id = cv_pgm_id
       and cv_effective_date between effective_start_date
                                 and effective_end_date;
   --
   cursor c_get_gsp_ler(cv_effective_date in date ) is
     select ler_id, name
     from ben_ler_f
     where typ_cd = 'GSP'
       and business_group_id = p_business_group_id
       and cv_effective_date between effective_start_date
                                 and effective_end_date;
    --
    l_package        VARCHAR2(80)   := g_package || '.derive_rate_and_factors';
    --
    l_pgm_rec        ben_pgm_f%ROWTYPE;
    l_ptip_rec       ben_ptip_f%ROWTYPE;
    l_comp_rec       g_cache_structure;
    l_oiplip_rec     g_cache_structure;
    l_curroipl_row   ben_cobj_cache.g_oipl_inst_row;
    l_curroiplip_row ben_cobj_cache.g_oiplip_inst_row;
    l_oipl_id        NUMBER;
    l_oiplip_id      NUMBER;
    l_loop_count     NUMBER                           := 1;
    --FONM
    -- g_fonm_cvg_strt_dt      DATE ;
    --END FONM
  --
  BEGIN
    --
    g_debug := hr_utility.debug_enabled;
    if g_debug then
      hr_utility.set_location('Entering ' || l_package,10);
    end if;
    --FONM This will be implemented as a parameter.
    --only for testing purpose we are using the global
    --variable and needs to be removed.
    --
    g_fonm_cvg_strt_dt := null ;
    if ben_manage_life_events.fonm = 'Y'
       and ben_manage_life_events.g_fonm_cvg_strt_dt  is not null then
      --
      g_fonm_cvg_strt_dt := ben_manage_life_events.g_fonm_cvg_strt_dt ;
      --
    end if;
    --
    --END FONM
    --
    hr_utility.set_location(' drpar main p_pl_id '||p_pl_id, 44);
    --hr_utility.set_location(' drpar main p_oipl_id '||p_oipl_id,44);
    hr_utility.set_location(' drpar main p_plip_id '||p_plip_id,44);
    --hr_utility.set_location(' drpar main p_ptip_id '||p_ptip_id,44);
    --hr_utility.set_location(' drpar main p_pgm_id '||p_pgm_id,44);
    --hr_utility.set_location(' p_derivable_factors '||p_derivable_factors,44);

    --  Check if person is still eligible to participate in
    --  the COBRA program.  He/she may have reached the maximum
    --  period of enrollment or decided not to enroll anymore in
    --  the COBRA program. COBRA eligibility is only checked if
    --  the BENMNGLE effective date is prior to or equal to today's date
    --  as the events are time sensitive.
    --
    IF     (   p_pgm_id IS NOT NULL
            OR p_ptip_id IS NOT NULL)
       AND (p_derivable_factors <> 'ASC') THEN
      --hr_utility.set_location(' COBRA logic  ' || l_package,10);
      --
      IF p_pgm_id IS NULL THEN
        --
        ben_comp_object.get_object(p_ptip_id=> p_ptip_id
         ,p_rec     => l_ptip_rec);
        --
        ben_comp_object.get_object(p_pgm_id=> l_ptip_rec.pgm_id
         ,p_rec    => l_pgm_rec);
      --
      ELSE
        ben_comp_object.get_object(p_pgm_id=> p_pgm_id
         ,p_rec    => l_pgm_rec);
      END IF;
      --
      IF l_pgm_rec.pgm_typ_cd LIKE 'COBRA%' THEN
        --
        determine_cobra_eligibility
          (p_calculate_only_mode => p_calculate_only_mode
          ,p_person_id           => p_person_id
          ,p_business_group_id   => p_business_group_id
          ,p_pgm_id              => p_pgm_id
          ,p_ptip_id             => p_ptip_id
          ,p_ptnl_ler_trtmt_cd   => p_ptnl_ler_trtmt_cd
          ,p_effective_date      => p_effective_date
          ,p_lf_evt_ocrd_dt      => NVL(g_fonm_cvg_strt_dt,p_lf_evt_ocrd_dt)
          ,p_derivable_factors   => p_derivable_factors
          );
        --
      END IF;
      --
      --hr_utility.set_location(' Dn COBRA logic  ' || l_package,10);
    END IF;
    --
    -- Check if we can drop out early. Do not need to calculate oipl
    -- and oiplip values for temporal mode
    --
    IF     (
                (
                      p_comp_obj_tree_row.flag_bit_val = 0
                  AND p_comp_obj_tree_row.oiplip_flag_bit_val = 0)
             OR (p_derivable_factors IN ('P', 'PBEV', 'BEV')))
       AND NVL(p_mode,'Z') = 'T' THEN
      --
      hr_utility.set_location(' Dn RETURN temporal mode ' ,45);
      RETURN;
    --
    -- Need to calculate oipl and oiplip values for any other mode
    -- before we drop out
    --
    ELSIF     (
                   (
                         p_comp_obj_tree_row.flag_bit_val = 0
                     AND p_comp_obj_tree_row.oiplip_flag_bit_val = 0)
                OR (p_derivable_factors IN ('P', 'PBEV', 'BEV')))
          AND NVL(p_mode
               ,'Z') <> 'T' THEN
      hr_utility.set_location(' CDS Not Temp  ' || l_package,10);
      --
      -- exit process as no derivable factors exist!
      -- or no need to check these factors.
      --
      -- Cache all the data values we use in our derivable factor functions
      --
      cache_data_structures(p_comp_obj_tree_row=> p_comp_obj_tree_row
       ,p_empasg_row        => p_empasg_row
       ,p_benasg_row        => p_benasg_row
       ,p_pil_row           => p_pil_row
       ,p_business_group_id => p_business_group_id
       ,p_person_id         => p_person_id
       ,p_pgm_id            => p_pgm_id
       ,p_pl_id             => p_pl_id
       ,p_oipl_id           => p_oipl_id
       ,p_plip_id           => p_plip_id
       ,p_ptip_id           => p_ptip_id
       ,p_comp_rec          => p_comp_rec
       ,p_oiplip_rec        => p_oiplip_rec
       ,p_effective_date    => NVL(g_fonm_cvg_strt_dt, p_effective_date)
       );
      hr_utility.set_location(' Dn CDS Not Temp  ' || l_package,10);
      --
      RETURN;
    --
    ELSE
      --
      hr_utility.set_location(' CDS Other  ' || l_package,10);
      cache_data_structures(p_comp_obj_tree_row=> p_comp_obj_tree_row
       ,p_empasg_row        => p_empasg_row
       ,p_benasg_row        => p_benasg_row
       ,p_pil_row           => p_pil_row
       ,p_business_group_id => p_business_group_id
       ,p_person_id         => p_person_id
       ,p_pgm_id            => p_pgm_id
       ,p_pl_id             => p_pl_id
       ,p_oipl_id           => p_oipl_id
       ,p_plip_id           => p_plip_id
       ,p_ptip_id           => p_ptip_id
       ,p_comp_rec          => l_comp_rec
       ,p_oiplip_rec        => l_oiplip_rec
       ,p_effective_date    => NVL(g_fonm_cvg_strt_dt,p_effective_date)
      );
    --
    END IF;
    hr_utility.set_location('Factors defined ' || l_package,10);
    --
    -- Get context row information from comp object caches
    --
    --hr_utility.set_location(' p_comp_obj_tree_row.oipl_id '||p_comp_obj_tree_row.oipl_id ,55);
    IF p_comp_obj_tree_row.oipl_id IS NOT NULL THEN
      --
      ben_cobj_cache.get_oipl_dets(p_business_group_id=> p_business_group_id
       ,p_effective_date    => g_fonm_cvg_strt_dt -- FONM p_effective_date
       ,p_oipl_id           => p_comp_obj_tree_row.oipl_id
       ,p_inst_row          => l_curroipl_row);
      --
      -- Check oiplip stuff
      --
      --hr_utility.set_location(' p_comp_obj_tree_row.oiplip_id '||p_comp_obj_tree_row.oiplip_id ,55);
      --
      IF p_comp_obj_tree_row.oiplip_id IS NOT NULL THEN
        --
        ben_cobj_cache.get_oiplip_dets(p_business_group_id=> p_business_group_id
         ,p_effective_date    => NVL(g_fonm_cvg_strt_dt, p_effective_date)
         ,p_oiplip_id         => p_comp_obj_tree_row.oiplip_id
         ,p_inst_row          => l_curroiplip_row);
      --
      END IF;
      --
      --hr_utility.set_location('Dn OIPL details ' || l_package,10);
    END IF;
    --
    -- If we are dealing with an oipl that has an oiplip then the count should
    -- be two since we will be looping once for oipl and once for oiplip.
    --
    IF p_comp_obj_tree_row.oiplip_id IS NOT NULL THEN
      --
      l_loop_count  := 2;
    --
    END IF;
    --
    --hr_utility.set_location(' l_loop_count '||l_loop_count ,55);
    --
    FOR l_count IN 1 .. l_loop_count LOOP
      --
      IF l_count = 1 THEN
        --
        l_oipl_id    := p_oipl_id;
        l_oiplip_id  := NULL;
      --
      ELSIF l_count = 2 THEN
        --
        l_oipl_id    := NULL;
        l_oiplip_id  := p_comp_obj_tree_row.oiplip_id;
        l_comp_rec   := l_oiplip_rec;
      --
      END IF;
      --
      -- GADE/STEP : Code to support grade/step le
      --
      if nvl(g_prev_pgm_id, -1) <> nvl(p_pgm_id
                                  ,p_comp_obj_tree_row.par_pgm_id) then
         --
         hr_utility.set_location('GSP pgm id = ' || p_pgm_id, 9876);
         hr_utility.set_location('GSP pgm id = ' ||p_comp_obj_tree_row.par_pgm_id, 9876);
         g_prev_pgm_id      := nvl(p_pgm_id
                                  ,p_comp_obj_tree_row.par_pgm_id);
         --
         g_pgm_typ_cd := null;
         open c_get_pgm_typ(g_prev_pgm_id, p_effective_date);
         fetch c_get_pgm_typ into g_pgm_typ_cd;
         close c_get_pgm_typ;
         --
      end if;
         if g_pgm_typ_cd = 'GSP' and g_gsp_ler_id is null then
            --
            open c_get_gsp_ler(p_effective_date);
            fetch c_get_gsp_ler into g_gsp_ler_id, g_gsp_ler_name;
            close c_get_gsp_ler;
            --
         end if;
         --
         hr_utility.set_location('GSP ler_name  = ' || g_gsp_ler_name, 9876);
      --
      -- END : GADE/STEP : Code to support grade/step le
      --
      -- Get LOS value
      --
      calculate_los
        (p_calculate_only_mode => p_calculate_only_mode
        ,p_comp_obj_tree_row   => p_comp_obj_tree_row
        ,p_empasg_row          => p_empasg_row
        ,p_benasg_row          => p_benasg_row
        ,p_pil_row             => p_pil_row
        ,p_curroipl_row        => l_curroipl_row
        ,p_curroiplip_row      => l_curroiplip_row
        ,p_person_id           => p_person_id
        ,p_business_group_id   => p_business_group_id
        ,p_pgm_id              => p_pgm_id
        ,p_pl_id               => p_pl_id
        ,p_oipl_id             => l_oipl_id
        ,p_plip_id             => p_plip_id
        ,p_ptip_id             => p_ptip_id
        ,p_oiplip_id           => l_oiplip_id
        ,p_ptnl_ler_trtmt_cd   => p_ptnl_ler_trtmt_cd
        ,p_comp_rec            => l_comp_rec
        ,p_effective_date      => p_effective_date
        ,p_lf_evt_ocrd_dt      => p_lf_evt_ocrd_dt
        );
      --
      -- Get Age value
      --
     hr_utility.set_location('pl_id '||p_pl_id , 55);
     hr_utility.set_location('Before call to calculate_age p_plip_id '||p_plip_id,55);
      calculate_age
        (p_calculate_only_mode => p_calculate_only_mode
        ,p_comp_obj_tree_row   => p_comp_obj_tree_row
        ,p_per_row             => p_per_row
        ,p_empasg_row          => p_empasg_row
        ,p_benasg_row          => p_benasg_row
        ,p_pil_row             => p_pil_row
        ,p_curroipl_row        => l_curroipl_row
        ,p_curroiplip_row      => l_curroiplip_row
        ,p_person_id           => p_person_id
        ,p_business_group_id   => p_business_group_id
        ,p_pgm_id              => p_pgm_id
        ,p_pl_id               => p_pl_id
        ,p_oipl_id             => l_oipl_id
        ,p_plip_id             => p_plip_id
        ,p_ptip_id             => p_ptip_id
        ,p_oiplip_id           => l_oiplip_id
        ,p_ptnl_ler_trtmt_cd   => p_ptnl_ler_trtmt_cd
        ,p_comp_rec            => l_comp_rec
        ,p_effective_date      => p_effective_date
        ,p_lf_evt_ocrd_dt      => p_lf_evt_ocrd_dt
        );
      --hr_utility.set_location('After call to calculate_age ' ,55);
      --
      -- Get hours worked
      --
      calculate_hours_worked
        (p_calculate_only_mode => p_calculate_only_mode
        ,p_comp_obj_tree_row=> p_comp_obj_tree_row
        ,p_empasg_row        => p_empasg_row
        ,p_benasg_row        => p_benasg_row
        ,p_pil_row           => p_pil_row
        ,p_curroipl_row      => l_curroipl_row
        ,p_curroiplip_row    => l_curroiplip_row
        ,p_person_id         => p_person_id
        ,p_business_group_id => p_business_group_id
        ,p_pgm_id            => p_pgm_id
        ,p_pl_id             => p_pl_id
        ,p_oipl_id           => l_oipl_id
        ,p_plip_id           => p_plip_id
        ,p_ptip_id           => p_ptip_id
        ,p_oiplip_id         => l_oiplip_id
        ,p_ptnl_ler_trtmt_cd => p_ptnl_ler_trtmt_cd
        ,p_comp_rec          => l_comp_rec
        ,p_effective_date    => p_effective_date
        ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
        );
      --
      -- Get percent fulltime
      --
      calculate_percent_fulltime
        (p_calculate_only_mode => p_calculate_only_mode
        ,p_comp_obj_tree_row   => p_comp_obj_tree_row
        ,p_empasg_row          => p_empasg_row
        ,p_benasg_row          => p_benasg_row
        ,p_pil_row             => p_pil_row
        ,p_curroipl_row        => l_curroipl_row
        ,p_curroiplip_row      => l_curroiplip_row
        ,p_person_id           => p_person_id
        ,p_business_group_id   => p_business_group_id
        ,p_pgm_id              => p_pgm_id
        ,p_pl_id               => p_pl_id
        ,p_oipl_id             => l_oipl_id
        ,p_plip_id             => p_plip_id
        ,p_ptip_id             => p_ptip_id
        ,p_oiplip_id           => l_oiplip_id
        ,p_ptnl_ler_trtmt_cd   => p_ptnl_ler_trtmt_cd
        ,p_comp_rec            => l_comp_rec
        ,p_effective_date      => p_effective_date
        ,p_lf_evt_ocrd_dt      => p_lf_evt_ocrd_dt
        );
      --
      -- Get combination age and los values
      --
      calculate_comb_age_and_los
        (p_calculate_only_mode => p_calculate_only_mode
        ,p_comp_obj_tree_row   => p_comp_obj_tree_row
        ,p_per_row             => p_per_row
        ,p_empasg_row          => p_empasg_row
        ,p_benasg_row          => p_benasg_row
        ,p_pil_row             => p_pil_row
        ,p_curroipl_row        => l_curroipl_row
        ,p_curroiplip_row      => l_curroiplip_row
        ,p_person_id           => p_person_id
        ,p_business_group_id   => p_business_group_id
        ,p_pgm_id              => p_pgm_id
        ,p_pl_id               => p_pl_id
        ,p_oipl_id             => l_oipl_id
        ,p_plip_id             => p_plip_id
        ,p_ptip_id             => p_ptip_id
        ,p_oiplip_id           => l_oiplip_id
        ,p_ptnl_ler_trtmt_cd   => p_ptnl_ler_trtmt_cd
        ,p_comp_rec            => l_comp_rec
        ,p_effective_date      => p_effective_date
        ,p_lf_evt_ocrd_dt      => p_lf_evt_ocrd_dt
        );
      --
      -- Get compensation value
      --
      calculate_compensation_level
        (p_calculate_only_mode => p_calculate_only_mode
        ,p_comp_obj_tree_row   => p_comp_obj_tree_row
        ,p_empasg_row          => p_empasg_row
        ,p_benasg_row          => p_benasg_row
        ,p_pil_row             => p_pil_row
        ,p_curroipl_row        => l_curroipl_row
        ,p_curroiplip_row      => l_curroiplip_row
        ,p_person_id           => p_person_id
        ,p_business_group_id   => p_business_group_id
        ,p_pgm_id              => p_pgm_id
        ,p_pl_id               => p_pl_id
        ,p_oipl_id             => l_oipl_id
        ,p_plip_id             => p_plip_id
        ,p_ptip_id             => p_ptip_id
        ,p_oiplip_id           => l_oiplip_id
        ,p_ptnl_ler_trtmt_cd   => p_ptnl_ler_trtmt_cd
        ,p_comp_rec            => l_comp_rec
        ,p_effective_date      => p_effective_date
        ,p_lf_evt_ocrd_dt      => p_lf_evt_ocrd_dt
        );
      --
      -- Set output values for once_r_cntg_cd and elig_flag
      --
      IF l_count = 1 THEN
        --
        p_comp_rec  := l_comp_rec;
         --hr_utility.set_location('Out p_comp_Rec'||p_comp_rec.cmbn_age_n_los_val,10);
      --
      ELSIF l_count = 2 THEN
        --
        p_oiplip_rec  := l_comp_rec;
      --
      END IF;
    --
    END LOOP;
    --
    --hr_utility.set_location('Leaving ' || l_package,10);
  --
  END derive_rates_and_factors;
--
 --- this procedure set the context_id to tax_unit_id
 --- this avoid the error from the pay_balance_pkg.get_value

  procedure set_taxunit_context
  (p_person_id           in     number
  ,p_business_group_id   in     number
  ,p_effective_date      in     date
  )
  is
    l_package        VARCHAR2(80)   := g_package || '.set_taxunit_context';
    --
    l_tax_unit_id    hr_soft_coding_keyflex.segment1%type ;
    --
    cursor c_tax is
    select cfk.segment1
    from per_all_assignments_f asg, hr_soft_coding_keyflex cfk
    where asg.person_id  = p_person_id
     and   asg.assignment_type <> 'C'
     and  asg.primary_flag = 'Y'
      AND p_effective_date BETWEEN asg.effective_start_date
                   AND asg.effective_end_date
     and asg.soft_coding_keyflex_id = cfk.soft_coding_keyflex_id
     order by asg.effective_start_date ;



  BEGIN
    --
    if g_debug then
      hr_utility.set_location('Entering ' || l_package,10);
    end if;
    open c_tax ;
    fetch c_tax into  l_tax_unit_id ;
    close c_tax ;

    if g_debug then
      hr_utility.set_location('tax_unit_id' || l_tax_unit_id , 10);
    end if;
    if l_tax_unit_id is not null then
       pay_balance_pkg.set_context ('TAX_UNIT_ID',  l_tax_unit_id );
    end if ;

    if g_debug then
      hr_utility.set_location('Leaving ' || l_package,10);
    end if;
  end set_taxunit_context ;
--
END ben_derive_part_and_rate_facts;

/
