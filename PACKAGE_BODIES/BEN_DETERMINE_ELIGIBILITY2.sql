--------------------------------------------------------
--  DDL for Package Body BEN_DETERMINE_ELIGIBILITY2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_DETERMINE_ELIGIBILITY2" as
/* $Header: bendete2.pkb 120.17.12010000.3 2009/11/04 07:59:08 pvelvano ship $ */
/*
+========================================================================+
|             Copyright (c) 1997 Oracle Corporation                      |
|                Redwood Shores, California, USA                         |
|                      All rights reserved.                              |
+========================================================================+
--
Name
    Determine person eligibility
Purpose
        This package is used to determine persons eligibility based on
        elibility profiles or rules associated with any comp object.
History
  Date        Who        Version    What?
  ----        ---        -------    -----
  15 Dec 97   U Datta    110.0      Created
  23 Dec 97   U Datta    110.1      Added flags for ELIG_FOR_PGM_
                                    FLAG, ELIG_FOR_PL_FLAG,
                                    REF_PGM_ID.
  05 Jan 98   U Datta    110.2      No changes.
  14 Jan 98   lmcdonal   110.5      Added or ...%notfound is null.
                                    Chg dec to DEC.
                                    Move all close cursors to after
                                    not found if/end if.
                                    Remove extra close cursors.
                                    Remove elig_for_pgm_flag,
                                    elig_for_pl_flag, ref_pgm_id,
                                    elig_prfl_id.
  19 Jan 98   lmcdonal   110.6      Add real messages.
  20 Jan 98   lmcdonal   110.7      Add concept of first-time elig/inelig.
                                    Don't write to p_elig_per with oipl info.
                                    Add order by to cursors w/rownum criteria.
                                    Add eff dt to cursor w/assignment criteria.

                                    Prtn Start Date changes:

                                    AFDFM: was last_day(p_effective_date +
                                               l_wait_perd_val)+1.
                                           now last_day(p_effective_date) + 1
                                               + l_wait_perd_val.
                                    AFDPPSY:
                                       was last_day(add_months
                                                   (to_date(l_yrp_start_date)
                                                   ,'DD-MON-YYYY'),6)) + 1
                                       now add_months(l_yrp_start_date,6)
                                    AFDCPPY:  was trunc(to_date(l_yrp_start_date
                                                       ,'DD-MON-YYYY'),'MONTH')
                                              now  l_yrp_start_date
                                    AFDFPPY: was to_date(l_yrp_start_date
                                                       ,'DD-MON-YYYY')
                                             now l_yrp_start_date
                                    ALDCPPSY: was last_day(add_months
                                                         (l_yrp_start_date,6))
                                              now (add_months
                                                  (l_yrp_start_date,6)- 1)
                                    Add 'ATFDFPP' code to pl/pgm section of code
                                    AFDPPSY: was add_months(l_yrp_start_date,6)
                                             now it's conditional.

                                    Prtn End Date changes:

                                    ALDCPP:  was last_day(l_pay_period_end_date)
                                             now l_pay_period_end_date
                                    ALDCPPY: was last_day(l_yrp_end_date)
                                             now l_yrp_end_date

                                    If the pay period doesn't exist and the strt
                                    or end date is based on pp criteria, error
                                    If the popl yr doesn't exist and the strt or
                                    end date is based on plan yr criteria, error

                                    Add more real messages.
                                    Chg 'DEC' references to '12', MON-YYYY to
                                    MM-RRRR.

                                    Remove c_track_inelig_flg, use global.
                                    Move checking of this global before
                                    all the computation of strt and end
                                    dates.

                                    Add c_get_elig_id columns to
                                    c_prev_opt_elig_check.
                                    Remove ben_opt_f, ben_pl_f from
                                    c_prev_opt_elig_check.  Add eff dts
                                    Add proc get_start_end_dates by
                                    stripping code from check_prev_elig
                                    Newly elig does update, not insert.
                                    First Elig records have start date.
                                    Newly Elig recs start date
                                    Unless there is an 'overlapping' past rec:
                                    Newly inelig recs update (corr) old rec
                                    with computed end date, then update
                                    record with start date = end date +1.
                                    Newly elig recs update (corr) old rec
                                    with computed (strt date-1), then update
                                    record with computed start date.

                                    First inelig have end date +1 in
                                    start date
  24 Jan 98   lmcdonal   110.8      Add opt_id back into c_elig_per_opt.
                                         Add order by to c_opt_next_popl_yr.
  24 Jan 98   lmcdonal   110.9      Add set_name before all raise
                                    g_record_error.
                                    Remove strt, end dt RL processing.
  03 Feb 98   lmcdonal   110.10     Remove 'when other's in exception.
  06 Mar 98   gperry     110.11     Removed certain cursors so code
                                    now uses global structures. Other
                                    general tidying up of code.
  08 Apr 98   gperry     110.12     Added output string info for
                                    improvements to the log.
  26 May 98   thayden    110.13     Chg AFDPPSY to AFDFPPSY.
  27 May 98   gperry     110.14     Added calls to formula cover
                                    routine.
  06 Jun 98   jmohapat   110.15     Added call to deenroll for newly ineligible
  07 Jun 98   jmohapatra 110.16     procedure name changed to
                                    ben_newly_ineligible.main
  10 Jun 98   lmcdonal   110.17     made header line after create line.
  12 Jun 98   gperry     110.18     Fixed update modes so we can
                                    handle update_overrides.
  14 Jun 98   gperry     110.19     Fixed log messages.
  07 Jul 98   jmohapat   110.20     Added batch who cols to call of
                                    apis like(ben_elig_person_option_api.
                                    create_elig_person_option and update,
                                    ben_eligibile_person_api.create_eligible
                                    _person and update)
  23 Jul 98   thayden    110.21     Added Inelg rsn cd.
  23 Oct 98   gperry     115.11     Added in extra call to
                                    ben_newly_ineligible to handle
                                    plans as well as programs.
  26 Oct 98   gperry     115.12     Corrected ben_elig_per_f so
                                    pgm_id is populated if pl_id has
                                    a program parent.
  23 Nov 98   gperry     115.13     Supports new columns for
                                    ben_elig_per_f and
                                    ben_elig_per_opt_f
  23 Nov 98   gperry     115.14     Added inelg_rsn_cd.
  02 Jan 99   gperry     115.15     Made trk inelig per flag work.
  18 Jan 99   G Perry    115.16     LED V ED
  25 Jan 99   G Perry    115.17     Fixed first time inelig case
                                    for options.
  17 Feb 99   G Perry    115.18     Added once_r_cntug_cd to insert
                                    and update of elig_per and
                                    elig_per_opt.
  25 Feb 99   G Perry    115.19     Converted get_start_end_dates
                                    to use generic call to
                                    ben_determine_date.main.
  09 Mar 99   G Perry    115.20     IS to AS.
  03 May 99   S Das      115.23     Added parameters to genutils.formula.
  04 May 99   S Das      115.24     Added jurisdiction code.
  05 May 99   G Perry    115.25     Changed code to use
                                    ben_comp_object routine.
                                    ben_elig_object routine.
                                    Both routines use hashed indexes.
  06 May 99   G Perry    115.26     Added call to ben_comp_object
                                    that was missed in last arcs in.
  06 May 99   jcarpent   115.27     Fork of 115.19 to change cache
  06 May 99   jcarpent   115.28     Same as 115.26
  14 May 99   bbulusu    115.29     Added waiting period logic in check_prev_el.
                                    Added function get_prtn_st_dt_aftr_wtg.
  14 May 99   G Perry    115.30     Added support for PLIP and PTIP.
  14 Jun 99   T Mathers  115.31     Changed to_dates to be NLS compliant
  17 Jun 99   bbulusu    115.32     Added wait_perd_cmpltn_dt to the Elig per
                                    and elig per opt apis. Added hr_api.g_sot.
  23 Jun 99   G Perry    115.33     performance fixes and fixed balas spurious
                                    use of dates.
  28 Jun 99   jcarpent   115.34     Added per_in_ler_id to elig_per api call.
                                    and added p_per_in_ler_id to check_prev_elg
  08 Jul 99   maagrawa   115.35     Modified c_ptnl_le cursor to look for
                                    non-voided potentials (Bug 2698).
  11 Jul 99   mhoyes     115.36   - Added new trace messages.
                                  - Removed + 0s from all cursors.
  12 Jul 99   jcarpent   115.37   - Added checks for backed out nocopy pil.
  13 Jul 99   mhoyes     115.38   - Added trace messages.
  20-JUL-99   Gperry     115.39     genutils -> benutils package rename.
  28-JUL-99   mhoyes     115.40   - Added trace messages.
                                  - Removed product join from cursor
                                    c_prev_elig_check.
  03-AUG-99   jcarpent   115.41   - changed prev_elig_check cursor to
                                    weed out nocopy backed out nocopy pils.
  10-AUG-99   Gperry     115.42     Removed references to g_cache_person.
                                    Fix all date formula calls to use
                                    fnd_date.canonical_to_date.
  19-AUG-99   Shdas      115.43     Added pl_ordr_num,plip_ordr_num,ptip_ordr_num
                                    in create_eligible_person and oipl_ordr_num
                                    in create_elig_person_option.
              GPerry                Added call to get benefits assignment if no
                                    employee assignment is found.
  17-SEP-99   pbodla     115.44     Bug 2551 fixes. Code reshuffled see comments
  01-OCT-99   gperry     115.45     Backport of 115.42 with Eligibility fixed.
                                    Now still elig records
                                    get created even though eligibility hasn't
                                    changed.
  04-OCT-99   gperry     115.46     Leapfrog of 115.44 with Eligibility fixed.
  03-NOV-99   mhoyes     115.47   - Added eligibility transition state.
                                    OUT NOCOPY parameters to check_prev_elig.
                                  - Added new logic to flag when a non tracked
                                    first time in-eligible occurs. This is only
                                    stored and passed as an OUT NOCOPY parameter. No
                                    elig per is written.
                                  - Passed p_override_validation to EPO and PEP
                                    APIs to bypass insert_validate validation.
                                    This doubles the execution speed of these
                                    two APIs.
  12-NOV-99   mhoyes     115.48   - Added new trace messages.
  12-NOV-99   stee       115.49   - Added business_group_id parameter to some
                                    of the calls to ben_determine_date
                                    procedure.
  10-JAN-00   stee       115.50   - Get per_in_ler info in get_start_end_dates
                                    procedure for date calculations.
                                    WWBUG:1096812
  11-Feb-00   jcarpent   115.51   - Use db mode globals.
                                  - pass pgm_id to beninelg
  21-FEB-00   tguy       115.52     Fixed heirarchy in get_start_end_dates
                                    procedure to walk down levels of comp obj
                                    wwbugs: 1161304,1161305,1183241,1167918
  23-Feb-00   lmcdonal   115.53     Bug 1167918:  Only inherit plip, ptip, pgm
                                    if plan/oipl is in a program.  And if plan
                                    is in pgm, look for plip before pl.
                                    Get ptip inheritance to work.
  24-Feb-00   jcarpent   115.54   - same as 115.51
  24-Feb-00   jcarpent   115.55   - Don't call beninelg unless have oipl, pl,
                                    or pgm. - patch of 115.51
  24-Feb-00   jcarpent   115.56   - Leapfrog. same fix as above to 115.53.
  26-Feb-00   mhoyes     115.57   - Added p_comp_obj_tree_row to
                                    check_prev_elig and passed into
                                    derive_rates_and_factors.
  03-Mar-00   mhoyes     115.58   - Passed p_comp_obj_tree_row into
                                    ben_det_wait_perd_cmpltn.main.
  03-Mar-00   mhoyes     115.59   - Phased out nocopy ben_env_object.
  07-Mar-00   gperry     115.60     Fixed trk_inelig_per_flag for PTIP and PLIP.
  31-Mar-00   gperry     115.61     Added oiplip support hangs off plip.
  03-Apr-00   mmogel     115.62   - Added tokens to message calls to make
                                    messages more meaningful to the user
  07-Apr-00   gperry     115.63     If person fails waiting period make them
                                    ineligible for the object.
                                    WWBUG 1230645, previously it errored rec.
  15-Mar-00   mhoyes     115.64   - Modified calls to create_Eligible_Person to
                                    create_perf_Eligible_Person.
                                  - Re-referenced and cleared junk from get
                                    start and end dates.
                                  - Modified calls to
                                    create_Elig_Person_Option to
                                    create_perf_Elig_Person_Option.
  22-May-00   mhoyes     115.65   - Replaced benutils function call to get the
                                    per in ler with a cache call.
  22-May-00   mhoyes     115.66   - Reduced cache calls in get start and end
                                    dates by using passed in records.
  23-May-00   shdas      115.67   - bug5224 call ben_newly_inelig.main if inelig for
                                    plip and ptip.
  24-May-00   mhoyes     115.68   - Tuned check_prev_elig cursors.
  02-Jun-00   mhoyes     115.70   - Re-instated 115.68.
  28-Jun-00   mhoyes     115.71   - Passed current row information into waiting
                                    periods.
                                  - Cached eligibility cursors.
  30-Jun-00   mhoyes     115.72   - Passed in context parameters into bendrpar.
  13-Jul-00   mhoyes     115.73   - Removed context parameters.
  04-Aug-00   jcarpent   115.74   - 5412. Don't reset override fields
                                    when doing an update.
  14-Sep-00   mhoyes     115.75   - Removed highly executed hr_utility.set_location
                                    statements.
  02-Oct-00   pbodla     115.76   - Bugs : 1412882, part of bug 1412951
                                    When elig per or opt rows are created they
                                    should be created as of least of p_effective_date
                                    and p_lf_evt_ocrd_dt
  06-Oct-00   pbodla     115.77   - Above fix caused problem for selection and
                                    temporal mode of benmngle run : due to null
                                    passed to effective_date while pep/epo
                                    api's are called. So put a nvl around
                                    p_lf_evt_ocrd_dt.
  29-Nov-00   Tmathers   115.78   -  Fixed Invalid cursor error, wwbug
                                  -  1517275, caused by having a Temporal
                                  -  LE created by BENDRPAR then re-closing
                                  -  already closed cursor.
  15-Dec-00   rchase     115.79   -  Bug 1531030. p_comp_rec and p_oiplip_rec
                                     were not being refreshed with updated info.
  01-May-01   mhoyes     115.80   -  Pointed c_prev_oiplip_elig_check to the
                                     EPO cache.
  18-Jul-01   kmahendr   115.81   -  Bug#1871579-Effective date is passed as least of
                                     p_effective_date or lf_evt_ocrd_dt to cursors in
                                     check_prv_eligibility
  01-Aug-01   kmahendr   115.82   -  Plan not in programs not getting deenrolled on selection
                                     mode-bug#1871579. nvl is used to return effective date
                                     for least function in 3 places where it was not there before
  27-aug-01   tilak      115.83      bug:1949361 jurisdiction code is
                                              derived inside benutils.formula.
  26-sep-01   tjesumic   115.84      wait_perd_Strt_dt added
  19-dec-01   pbodla     115.85      CWB Changes - Look for non comp potential
                                     life events when waiting periods are defined.
  20-Dec-01   ikasire    115.86      added dbdrv lines
  07-Jan-02   Rpillay    115.87      Added Set Verify Off.
  11-Mar-02   mhoyes     115.88      Dependent eligibility tuning.
  12-Mar-02   pbodla     115.89      Bug 2284417 : Do not update the per in ler id
                                     with new per in ler id as this peice of
                                     row should belong to previous per in ler.
                                     Next update will update the per in ler id as
                                     well as new prtn strt dt.
  12-Jul-02   mhoyes     115.90    - Added calls to get_curroiplippep_dets and
                                     get_currplnpep_dets.
  20-Aug-02   mhoyes     115.91    - Populated comp object list row eligible values.
  12-Oct-02   ikasire    115.92    - Bug 2551834 fixed the codes ALDCPPSY and ALDCPPY
                                     in get_start_and_end_dates procedure
  29-Jan-03   kmahendr   115.93    - In P mode participation start date and end date are
                                     defaulted to Event and 1 day before event
  10-feb-03   hnarayan   115.94    - Added NOCOPY Changes
  11-Mar-03   rpillay    115.95    - Bug 2806554 - Changed default for
                                     Participation End Date Code from AEOT to
                                     ODBED
  17-Mar-03   vsethi     115.96    - Bug 2650247 - populating the value of inelg_rsn_cd
  				     in p_comp_obj_tree_row record.
  07-Apr-03   mmudigon   115.97   -  Bug#2841136-Effective date is passed as
                                     least of p_effective_date or lf_evt_ocrd_dt
                                     to calls to ben_pep_cache.
                                     Corrected typo in determining DT Track mode
                                     for updating OIPLIP.
  24-Jun-03   hnarayan   115.98   -  Bug 3001411 - changed cursor c_ptnl_le to
                                     ignore LEs of type SCHEDDU, ABS, COMP and GSP
                                     becos the presence of these LE shud not make a
                                     person ineligible in case of waiting period setup.
  02-Sep-03   rpgupta    115.99   -  Bug  3111613  - if cache does'nt return any
  				     elig_per_id, raise an error
  18-Sep-03   mhoyes     115.100  -  Phased in calls to ben_pep_cache1 rather than
                                     ben_pep_cache.
  19 Sep 03   mhoyes     115.101  -  3150329 - Update eligibility APIs.
  26 Sep 03   mhoyes     115.102  -  More update eligibility APIs.
  21 Jan 04   ikasire    115.103     BUG 3327841 - fixed the wrong assignment of epo
                                     data to pep. Also calling clear_down_cache
                                     to get the right data.
  02 Feb 04   ikasire    115.104     BUG 3327841 Using the ben_pep_cache1.get_currplnpep_dets
                                     to get the current pep info instread of depending on
                                     ben_pep_cache.get_pilepo_dets
  30 Mar 04   ikasire    115.105     fonm changes.
  15 Apr 04   ikasire    115.106     Bug 3550789 added a new procedure save_to_restore
                                     to save the PEP EPO data in certain cases when
                                     we loose the data and can't restore as part of
                                     reprocess
  1 June 04   kmahendr   115.108     removed assignment of prtn_strt_dt in fonm
                                     mode per prasad
  4 June 04   rpgupta    115.109     3597303 - Make person eligible even if a ptnl
                                     LE exists before the waiting period end
  28-Sep-04   abparekh   115.110     iRec : Modified procedure check_prev_elig
                                            Modified cursor c_prev_elig_check and
                                            c_prev_opt_elig_check in check_prev_elig
  28-Mar-05   ikasire    115.111     Bug 4241413 fix for the data type of
                                     wait_perd_cmpltn_dt
  26-Apr-05   mmudigon   115.112     Score and Weight
  17-Jun-05   abparekh   115.113     Bug 4438430 : Pass PER_IN_LER_ID while creating
                                                   ESW record
  12-jan-05   ssarkar    115.114     Bug 4947426 : passed  l_effective_dt to update_perf_Eligible_Person
  23-Jan-06   kmahendr   115.115     Bug#4960082 - newly_ineligible process is
                                     added to still_ineligible condition
  27-Jan-06   mhoyes     115.116     Bug#4968123 - hr_utility debug and locally
                                     defined plsql tuning.
  30-Jan-06   mhoyes     115.117     Bug#4968123 - moved out locall defined procs
                                     to ben_determine_eligibility3.
  30-Jan-06   mhoyes     115.118     Bug#4968123 - moved out cursors
                                     to ben_determine_eligibility4.
  28-Jun-06   swjain     115.119     Bug 5331889 Added person_id param in call to
				     benutils.formula in procedure get_start_end_dates
  24-Jul-06   kmahendr   115.120     Bug#5404392-added ben_newly_ineligible call
                                     in the case of first time ineligible.
  25-aug-06   ssarkar    115.121     bug# 5478994 - passed ler_id to update_perf_eligible_person
  11-Dec-06   rgajula    115.122     Bug 5682845 - passed the l_envplipid to the call to ben_pep_Cache.get_pilepo_dets.
  07-Feb-07   kmahendr   115.124     Fidelity Enh to update inelig rows and
                                     reversed fix made for 5682845
  08-Feb-07   kmahendr   115.125     Reversed the condition to update inelig rows
  16-Feb-07   rtagarra   115.126     ICM Changes.
  12-jun-07   rtagarra   115.127     ICM: Bug 6038232. Also incorporated changes of Bug 6000303 : Defer Deenrollment ENH
				     on 04-Dec-07 from branchline.
  23-Jan-2008 sallumwa   115.128     Bug 6601884 : For still ineligible records, when ineligibility is to be tracked,
                                     the records should be updated with correct datetrack mode for both ben_elig_per_f
				     and ben_elig_per_opt_f.
  12-Jan-2009 krupani    120.17.12010000.1   Forward ported fix of 11i bug 8542643
  31-Oct-09   velvanop   120.17.12010000.2   Bug 9081414: Fwd port of Bug 9020962  : If future eligibility record exists for the previous per_in_ler_id, then insert the future eligiblity record
	                             in backup table ben_le_clsn_n_rstr
--------------------------------------------------------------------------------
*/
--
-- -----------------------------------------------------------------------------
-- |----------------------< get_start_end_dates >------------------------------|
-- -----------------------------------------------------------------------------
--
procedure get_start_end_dates
  (p_comp_obj_tree_row    in     ben_manage_life_events.g_cache_proc_objects_rec
  ,p_pil_row              in     ben_per_in_ler%rowtype
  ,p_effective_date       in     date
  ,p_business_group_id    in     number
  ,p_person_id            in     number
  ,p_pl_id                in     number
  ,p_pgm_id               in     number
  ,p_oipl_id              in     number
  ,p_plip_id              in     number
  ,p_ptip_id              in     number
  ,p_prev_prtn_strt_dt    in     date
  ,p_prev_prtn_end_dt     in     date
  ,p_start_or_end         in     varchar2
  ,p_prtn_eff_strt_dt        out nocopy date
  ,p_prtn_eff_strt_dt_cd     out nocopy varchar2
  ,p_prtn_eff_strt_dt_rl     out nocopy number
  ,p_prtn_eff_end_dt         out nocopy date
  )
is
  --
/* 4968123
  l_proc                  varchar2(100):=g_package||'get_start_end_dates';
*/
  --
  l_wait_perd_val         ben_prtn_elig_f.wait_perd_val%TYPE;
  l_wait_perd_uom         ben_prtn_elig_f.wait_perd_uom%TYPE;
  l_prtn_eff_strt_dt_cd   ben_prtn_elig_f.prtn_eff_strt_dt_cd%TYPE;
  l_prtn_eff_end_dt_cd    ben_prtn_elig_f.prtn_eff_end_dt_cd%TYPE;
  l_prtn_eff_strt_dt_rl   ben_prtn_elig_f.prtn_eff_strt_dt_rl%TYPE;
  l_prtn_eff_end_dt_rl    ben_prtn_elig_f.prtn_eff_end_dt_rl%TYPE;
  l_outputs               ff_exec.outputs_t;
  l_oipl_rec           ben_cobj_cache.g_oipl_inst_row;
  l_pl_rec             ben_pl_f%rowtype;
  l_elig_pgm_rec       ben_cobj_cache.g_etpr_inst_row;
  l_elig_ptip_rec      ben_cobj_cache.g_etpr_inst_row;
  l_elig_plip_rec      ben_cobj_cache.g_etpr_inst_row;
  l_elig_pl_rec        ben_cobj_cache.g_etpr_inst_row;
  l_elig_oipl_rec      ben_cobj_cache.g_etpr_inst_row;
  l_prtn_elig_pl_rec   ben_cobj_cache.g_prel_inst_row;
  l_prtn_elig_pgm_rec  ben_cobj_cache.g_prel_inst_row;
  l_prtn_elig_oipl_rec ben_cobj_cache.g_prel_inst_row;
  l_prtn_elig_plip_rec ben_cobj_cache.g_prel_inst_row;
  l_prtn_elig_ptip_rec ben_cobj_cache.g_prel_inst_row;
  l_ass_rec            per_all_assignments_f%rowtype;
  l_loc_rec            hr_locations_all%rowtype;
  l_jurisdiction_code  varchar2(30);
  --
  l_envpgm_id  number;
  l_envptip_id number;
  l_envplip_id number;
  l_envpl_id   number;
  l_env_rec              ben_env_object.g_global_env_rec_type;
  l_benmngle_parm_rec    benutils.g_batch_param_rec;
  --FONM
  l_fonm_cvg_strt_dt DATE ;
  --END FONM
  --
  l_temp_prtn_strt_dt date ;
  --
begin
--  hr_utility.set_location('Entering ben_determine_eligibility2.get_start_end_dates',10);
  --
  -- Performance tuning commented out hr_utility statements
  --
--  hr_utility.set_location('p_pgm_id   -> ' ||p_pgm_id ,123);
--  hr_utility.set_location('p_ptip_id  -> ' ||p_ptip_id,123);
--  hr_utility.set_location('p_plip_id  -> ' ||p_plip_id,123);
--  hr_utility.set_location('p_pl_id    -> ' ||p_pl_id  ,123);
--  hr_utility.set_location('p_oipl_id  -> ' ||p_oipl_id,123);
  --
  if ben_manage_life_events.fonm = 'Y'
      and ben_manage_life_events.g_fonm_cvg_strt_dt is not null then
     --
     l_fonm_cvg_strt_dt := ben_manage_life_events.g_fonm_cvg_strt_dt ;
     --
  end if;
  --
  -- if the mode is Personnel Action - the participation start date and end date needs to be
  -- defaulted to Event and 1 day before event
  ben_env_object.get(p_rec => l_env_rec);
  benutils.get_batch_parameters(p_benefit_action_id => l_env_rec.benefit_action_id
                                ,p_rec => l_benmngle_parm_rec);
  if l_benmngle_parm_rec.mode_cd = 'P' then
     --
     if p_start_or_end = 'S' then
       --
       p_prtn_eff_strt_dt := p_effective_date;
       --
     elsif p_start_or_end = 'E' then
       --
       p_prtn_eff_end_dt  := p_effective_date - 1;
       --
     end if;
     return;
  end if;



  -- Assign comp object locals
  --
  l_envpgm_id  := p_comp_obj_tree_row.par_pgm_id;
  l_envptip_id := p_comp_obj_tree_row.par_ptip_id;
  l_envplip_id := p_comp_obj_tree_row.par_plip_id;
  l_envpl_id   := p_comp_obj_tree_row.par_pl_id;
  --
  -- Read participation dates for the comp object from the cached environment.
  --
  if p_pgm_id is not null then
  --  hr_utility.set_location('get pgm l_prtn_eff_strt_dt_cd',123);
    --
    -- Performance fix to reduce cache calls
    --
    l_elig_pgm_rec := ben_cobj_cache.g_pgmetpr_currow;
    --
    l_prtn_eff_strt_dt_rl := l_elig_pgm_rec.prtn_eff_strt_dt_rl;
    l_prtn_eff_end_dt_rl  := l_elig_pgm_rec.prtn_eff_end_dt_rl;
    l_prtn_eff_strt_dt_cd := l_elig_pgm_rec.prtn_eff_strt_dt_cd;
    l_prtn_eff_end_dt_cd  := l_elig_pgm_rec.prtn_eff_end_dt_cd;
    --
    -- If the date codes are not found in the elig_to_prte_rsn table, look for
    -- them in prtn_elig_f.
    --
    if l_prtn_eff_strt_dt_cd is null then
      --
      l_prtn_elig_pgm_rec := ben_cobj_cache.g_pgmprel_currow;
      --
      l_prtn_eff_strt_dt_cd := l_prtn_elig_pgm_rec.prtn_eff_strt_dt_cd;
      l_prtn_eff_end_dt_cd  := l_prtn_elig_pgm_rec.prtn_eff_end_dt_cd;
      l_prtn_eff_strt_dt_rl := l_prtn_elig_pgm_rec.prtn_eff_strt_dt_rl;
      l_prtn_eff_end_dt_rl  := l_prtn_elig_pgm_rec.prtn_eff_end_dt_rl;
    end if;

--    hr_utility.set_location('Done NN PGM ben_determine_eligibility2.get_start_end_dates',10);
  end if;
--    hr_utility.set_location('PTIP NN ben_determine_eligibility2.get_start_end_dates',10);
  if p_ptip_id is not null then
    --
    -- Performance fix to reduce cache calls
    --
    l_elig_ptip_rec := ben_cobj_cache.g_ptipetpr_currow;
    --
    l_prtn_eff_strt_dt_cd := l_elig_ptip_rec.prtn_eff_strt_dt_cd;
    l_prtn_eff_end_dt_cd  := l_elig_ptip_rec.prtn_eff_end_dt_cd;
    l_prtn_eff_strt_dt_rl := l_elig_ptip_rec.prtn_eff_strt_dt_rl;
    l_prtn_eff_end_dt_rl  := l_elig_ptip_rec.prtn_eff_end_dt_rl;
    --
    -- If the date codes are not found in the elig_to_prte_rsn table, look for
    -- them in prtn_elig_f.
    --
    if l_prtn_eff_strt_dt_cd is null then
      --
      l_prtn_elig_ptip_rec := ben_cobj_cache.g_ptipprel_currow;
      --
      l_prtn_eff_strt_dt_cd := l_prtn_elig_ptip_rec.prtn_eff_strt_dt_cd;
      l_prtn_eff_end_dt_cd  := l_prtn_elig_ptip_rec.prtn_eff_end_dt_cd;
      l_prtn_eff_strt_dt_rl := l_prtn_elig_ptip_rec.prtn_eff_strt_dt_rl;
      l_prtn_eff_end_dt_rl  := l_prtn_elig_ptip_rec.prtn_eff_end_dt_rl;
    end if;
    --
    --  if cd is still null then get it from pgm
    --
    if l_prtn_eff_strt_dt_cd is null then
      l_elig_pgm_rec      := ben_cobj_cache.g_pgmetpr_currow;
      --
      l_prtn_elig_pgm_rec := ben_cobj_cache.g_pgmprel_currow;
      --
      l_prtn_eff_strt_dt_cd := nvl(l_elig_pgm_rec.prtn_eff_strt_dt_cd,l_prtn_elig_pgm_rec.prtn_eff_strt_dt_cd);
      l_prtn_eff_end_dt_cd  := nvl(l_elig_pgm_rec.prtn_eff_end_dt_cd ,l_prtn_elig_pgm_rec.prtn_eff_end_dt_cd );
      l_prtn_eff_strt_dt_rl := nvl(l_elig_pgm_rec.prtn_eff_strt_dt_rl,l_prtn_elig_pgm_rec.prtn_eff_strt_dt_rl);
      l_prtn_eff_end_dt_rl  := nvl(l_elig_pgm_rec.prtn_eff_end_dt_rl ,l_prtn_elig_pgm_rec.prtn_eff_end_dt_rl );
    end if;
--    hr_utility.set_location('Done NN PTIP ben_determine_eligibility2.get_start_end_dates',10);

  end if;
--    hr_utility.set_location('PLIP NN ben_determine_eligibility2.get_start_end_dates',10);
  if p_plip_id is not null then
--    hr_utility.set_location('get plip l_prtn_eff_strt_dt_cd',123);
    --
    l_elig_plip_rec := ben_cobj_cache.g_plipetpr_currow;
    l_prtn_eff_strt_dt_cd := l_elig_plip_rec.prtn_eff_strt_dt_cd;
    l_prtn_eff_end_dt_cd  := l_elig_plip_rec.prtn_eff_end_dt_cd;
    l_prtn_eff_strt_dt_rl := l_elig_plip_rec.prtn_eff_strt_dt_rl;
    l_prtn_eff_end_dt_rl  := l_elig_plip_rec.prtn_eff_end_dt_rl;
    --
    -- If the date codes are not found in the elig_to_prte_rsn table, look for
    -- them in prtn_elig_f.
    --
    if l_prtn_eff_strt_dt_cd is null then
      l_prtn_elig_plip_rec := ben_cobj_cache.g_plipprel_currow;
      l_prtn_eff_strt_dt_cd := l_prtn_elig_plip_rec.prtn_eff_strt_dt_cd;
      l_prtn_eff_end_dt_cd  := l_prtn_elig_plip_rec.prtn_eff_end_dt_cd;
      l_prtn_eff_strt_dt_rl := l_prtn_elig_plip_rec.prtn_eff_strt_dt_rl;
      l_prtn_eff_end_dt_rl  := l_prtn_elig_plip_rec.prtn_eff_end_dt_rl;
    end if;
    --
    --  if cd is still null then look in ptip then pgm
    --
    if l_prtn_eff_strt_dt_cd is null then
      l_elig_ptip_rec      := ben_cobj_cache.g_ptipetpr_currow;
      l_prtn_elig_ptip_rec := ben_cobj_cache.g_ptipprel_currow;
      l_prtn_eff_strt_dt_cd := nvl(l_elig_ptip_rec.prtn_eff_strt_dt_cd,l_prtn_elig_ptip_rec.prtn_eff_strt_dt_cd);
      l_prtn_eff_end_dt_cd  := nvl(l_elig_ptip_rec.prtn_eff_end_dt_cd ,l_prtn_elig_ptip_rec.prtn_eff_end_dt_cd );
      l_prtn_eff_strt_dt_rl := nvl(l_elig_ptip_rec.prtn_eff_strt_dt_rl,l_prtn_elig_ptip_rec.prtn_eff_strt_dt_rl);
      l_prtn_eff_end_dt_rl  := nvl(l_elig_ptip_rec.prtn_eff_end_dt_rl ,l_prtn_elig_ptip_rec.prtn_eff_end_dt_rl );

      if l_prtn_eff_strt_dt_cd is null then
         l_elig_pgm_rec      := ben_cobj_cache.g_pgmetpr_currow;
         l_prtn_elig_pgm_rec := ben_cobj_cache.g_pgmprel_currow;
         l_prtn_eff_strt_dt_cd := nvl(l_elig_pgm_rec.prtn_eff_strt_dt_cd,l_prtn_elig_pgm_rec.prtn_eff_strt_dt_cd);
         l_prtn_eff_end_dt_cd  := nvl(l_elig_pgm_rec.prtn_eff_end_dt_cd ,l_prtn_elig_pgm_rec.prtn_eff_end_dt_cd );
         l_prtn_eff_strt_dt_rl := nvl(l_elig_pgm_rec.prtn_eff_strt_dt_rl,l_prtn_elig_pgm_rec.prtn_eff_strt_dt_rl);
         l_prtn_eff_end_dt_rl  := nvl(l_elig_pgm_rec.prtn_eff_end_dt_rl ,l_prtn_elig_pgm_rec.prtn_eff_end_dt_rl );
      end if;
    end if;

--    hr_utility.set_location('Done NN PLIP ben_determine_eligibility2.get_start_end_dates',10);
  end if;
--    hr_utility.set_location('PLN NN ben_determine_eligibility2.get_start_end_dates',10);
  if p_pl_id is not null then

    -- For plans in pgm, look at plip first.
    if l_envplip_id is not null then
      l_elig_plip_rec      := ben_cobj_cache.g_plipetpr_currow;
      l_prtn_elig_plip_rec := ben_cobj_cache.g_plipprel_currow;
      l_prtn_eff_strt_dt_cd := nvl(l_elig_plip_rec.prtn_eff_strt_dt_cd,l_prtn_elig_plip_rec.prtn_eff_strt_dt_cd);
      l_prtn_eff_end_dt_cd  := nvl(l_elig_plip_rec.prtn_eff_end_dt_cd ,l_prtn_elig_plip_rec.prtn_eff_end_dt_cd );
      l_prtn_eff_strt_dt_rl := nvl(l_elig_plip_rec.prtn_eff_strt_dt_rl,l_prtn_elig_plip_rec.prtn_eff_strt_dt_rl);
      l_prtn_eff_end_dt_rl  := nvl(l_elig_plip_rec.prtn_eff_end_dt_rl ,l_prtn_elig_plip_rec.prtn_eff_end_dt_rl );
    end if;

    -- if plip not found, or plan not in program, look at pl level
    if l_prtn_eff_strt_dt_cd is null then
--    hr_utility.set_location('get pl l_prtn_eff_strt_dt_cd',123);
      --
      l_elig_pl_rec := ben_cobj_cache.g_pletpr_currow;
      l_prtn_eff_strt_dt_cd := l_elig_pl_rec.prtn_eff_strt_dt_cd;
      l_prtn_eff_end_dt_cd  := l_elig_pl_rec.prtn_eff_end_dt_cd;
      l_prtn_eff_strt_dt_rl := l_elig_pl_rec.prtn_eff_strt_dt_rl;
      l_prtn_eff_end_dt_rl  := l_elig_pl_rec.prtn_eff_end_dt_rl;

      -- If the date codes are not found in the elig_to_prte_rsn table, look for
      -- them in prtn_elig_f.
      --
      if l_prtn_eff_strt_dt_cd is null then
        l_prtn_elig_pl_rec := ben_cobj_cache.g_plprel_currow;
        l_prtn_eff_strt_dt_cd := l_prtn_elig_pl_rec.prtn_eff_strt_dt_cd;
        l_prtn_eff_end_dt_cd  := l_prtn_elig_pl_rec.prtn_eff_end_dt_cd;
        l_prtn_eff_strt_dt_rl := l_prtn_elig_pl_rec.prtn_eff_strt_dt_rl;
        l_prtn_eff_end_dt_rl  := l_prtn_elig_pl_rec.prtn_eff_end_dt_rl;
      end if;

      --  if cd is still null and pl is in pgm, get from ptip or pgm.
      --
      if l_prtn_eff_strt_dt_cd is null and l_envptip_id is not null then
          l_elig_ptip_rec      := ben_cobj_cache.g_ptipetpr_currow;
          l_prtn_elig_ptip_rec := ben_cobj_cache.g_ptipprel_currow;
          l_prtn_eff_strt_dt_cd := nvl(l_elig_ptip_rec.prtn_eff_strt_dt_cd,l_prtn_elig_ptip_rec.prtn_eff_strt_dt_cd);
          l_prtn_eff_end_dt_cd  := nvl(l_elig_ptip_rec.prtn_eff_end_dt_cd ,l_prtn_elig_ptip_rec.prtn_eff_end_dt_cd );
          l_prtn_eff_strt_dt_rl := nvl(l_elig_ptip_rec.prtn_eff_strt_dt_rl,l_prtn_elig_ptip_rec.prtn_eff_strt_dt_rl);
          l_prtn_eff_end_dt_rl  := nvl(l_elig_ptip_rec.prtn_eff_end_dt_rl ,l_prtn_elig_ptip_rec.prtn_eff_end_dt_rl );

        if l_prtn_eff_strt_dt_cd is null then
          l_elig_pgm_rec      := ben_cobj_cache.g_pgmetpr_currow;
          l_prtn_elig_pgm_rec := ben_cobj_cache.g_pgmprel_currow;
          l_prtn_eff_strt_dt_cd := nvl(l_elig_pgm_rec.prtn_eff_strt_dt_cd,l_prtn_elig_pgm_rec.prtn_eff_strt_dt_cd);
          l_prtn_eff_end_dt_cd  := nvl(l_elig_pgm_rec.prtn_eff_end_dt_cd ,l_prtn_elig_pgm_rec.prtn_eff_end_dt_cd );
          l_prtn_eff_strt_dt_rl := nvl(l_elig_pgm_rec.prtn_eff_strt_dt_rl,l_prtn_elig_pgm_rec.prtn_eff_strt_dt_rl);
          l_prtn_eff_end_dt_rl  := nvl(l_elig_pgm_rec.prtn_eff_end_dt_rl ,l_prtn_elig_pgm_rec.prtn_eff_end_dt_rl );
        end if;

      end if;
    end if;
--    hr_utility.set_location('Done NN PLN ben_determine_eligibility2.get_start_end_dates',10);
  end if;
--    hr_utility.set_location('OIPL NN ben_determine_eligibility2.get_start_end_dates',10);
  if p_oipl_id is not null then
--    hr_utility.set_location('getting oipl l_prtn_eff_strt_dt_cd',123);
    l_elig_oipl_rec := ben_cobj_cache.g_oipletpr_currow;
    l_prtn_eff_strt_dt_cd := l_elig_oipl_rec.prtn_eff_strt_dt_cd;
    l_prtn_eff_end_dt_cd  := l_elig_oipl_rec.prtn_eff_end_dt_cd;
    l_prtn_eff_strt_dt_rl := l_elig_oipl_rec.prtn_eff_strt_dt_rl;
    l_prtn_eff_end_dt_rl  := l_elig_oipl_rec.prtn_eff_end_dt_rl;
    --
    -- If the date codes are not found in the elig_to_prte_rsn table, look for
    -- them in prtn_elig_f.
    --
    if l_prtn_eff_strt_dt_cd is null then
      l_prtn_elig_oipl_rec := ben_cobj_cache.g_oiplprel_currow;
      l_prtn_eff_strt_dt_cd := l_prtn_elig_oipl_rec.prtn_eff_strt_dt_cd;
      l_prtn_eff_end_dt_cd  := l_prtn_elig_oipl_rec.prtn_eff_end_dt_cd;
      l_prtn_eff_strt_dt_rl := l_prtn_elig_oipl_rec.prtn_eff_strt_dt_rl;
      l_prtn_eff_end_dt_rl  := l_prtn_elig_oipl_rec.prtn_eff_end_dt_rl;
    end if;
    --
    --  if cd is still null then get from plip if in pgm, plan if not
    --
    if l_prtn_eff_strt_dt_cd is null and l_envplip_id is not null then
      l_elig_plip_rec := ben_cobj_cache.g_plipetpr_currow;
      l_prtn_elig_plip_rec := ben_cobj_cache.g_plipprel_currow;
        l_prtn_eff_strt_dt_cd := nvl(l_elig_plip_rec.prtn_eff_strt_dt_cd,l_prtn_elig_plip_rec.prtn_eff_strt_dt_cd);
        l_prtn_eff_end_dt_cd  := nvl(l_elig_plip_rec.prtn_eff_end_dt_cd ,l_prtn_elig_plip_rec.prtn_eff_end_dt_cd );
        l_prtn_eff_strt_dt_rl := nvl(l_elig_plip_rec.prtn_eff_strt_dt_rl,l_prtn_elig_plip_rec.prtn_eff_strt_dt_rl);
        l_prtn_eff_end_dt_rl  := nvl(l_elig_plip_rec.prtn_eff_end_dt_rl ,l_prtn_elig_plip_rec.prtn_eff_end_dt_rl );
    end if;

    if l_prtn_eff_strt_dt_cd is null  then
      l_elig_pl_rec := ben_cobj_cache.g_pletpr_currow;
      l_prtn_elig_pl_rec := ben_cobj_cache.g_plprel_currow;
      l_prtn_eff_strt_dt_cd := nvl(l_elig_pl_rec.prtn_eff_strt_dt_cd,l_prtn_elig_pl_rec.prtn_eff_strt_dt_cd);
      l_prtn_eff_end_dt_cd  := nvl(l_elig_pl_rec.prtn_eff_end_dt_cd ,l_prtn_elig_pl_rec.prtn_eff_end_dt_cd );
      l_prtn_eff_strt_dt_rl := nvl(l_elig_pl_rec.prtn_eff_strt_dt_rl,l_prtn_elig_pl_rec.prtn_eff_strt_dt_rl);
      l_prtn_eff_end_dt_rl  := nvl(l_elig_pl_rec.prtn_eff_end_dt_rl ,l_prtn_elig_pl_rec.prtn_eff_end_dt_rl );

      --  if cd is still null and oipl is in a program then get from ptip or pgm
      if l_prtn_eff_strt_dt_cd is null and l_envptip_id is not null then
          l_elig_ptip_rec      := ben_cobj_cache.g_ptipetpr_currow;
          l_prtn_elig_ptip_rec := ben_cobj_cache.g_ptipprel_currow;
          l_prtn_eff_strt_dt_cd := nvl(l_elig_ptip_rec.prtn_eff_strt_dt_cd,l_prtn_elig_ptip_rec.prtn_eff_strt_dt_cd);
          l_prtn_eff_end_dt_cd  := nvl(l_elig_ptip_rec.prtn_eff_end_dt_cd ,l_prtn_elig_ptip_rec.prtn_eff_end_dt_cd );
          l_prtn_eff_strt_dt_rl := nvl(l_elig_ptip_rec.prtn_eff_strt_dt_rl,l_prtn_elig_ptip_rec.prtn_eff_strt_dt_rl);
          l_prtn_eff_end_dt_rl  := nvl(l_elig_ptip_rec.prtn_eff_end_dt_rl ,l_prtn_elig_ptip_rec.prtn_eff_end_dt_rl );

        if l_prtn_eff_strt_dt_cd is null then
          l_elig_pgm_rec      := ben_cobj_cache.g_pgmetpr_currow;
          l_prtn_elig_pgm_rec := ben_cobj_cache.g_pgmprel_currow;
          l_prtn_eff_strt_dt_cd := nvl(l_elig_pgm_rec.prtn_eff_strt_dt_cd,l_prtn_elig_pgm_rec.prtn_eff_strt_dt_cd);
          l_prtn_eff_end_dt_cd  := nvl(l_elig_pgm_rec.prtn_eff_end_dt_cd ,l_prtn_elig_pgm_rec.prtn_eff_end_dt_cd );
          l_prtn_eff_strt_dt_rl := nvl(l_elig_pgm_rec.prtn_eff_strt_dt_rl,l_prtn_elig_pgm_rec.prtn_eff_strt_dt_rl);
          l_prtn_eff_end_dt_rl  := nvl(l_elig_pgm_rec.prtn_eff_end_dt_rl ,l_prtn_elig_pgm_rec.prtn_eff_end_dt_rl );
        end if;
      end if;
    end if;
--    hr_utility.set_location('Done NN OIPL ben_determine_eligibility2.get_start_end_dates',10);
  end if;
  if l_prtn_eff_strt_dt_cd is null then
--    hr_utility.set_location('Null l_prtn_eff_strt_dt_cd, so assign aed',123);
    l_prtn_eff_strt_dt_cd := 'AED';  -- as of event date
  end if;

  if l_prtn_eff_end_dt_cd is null then
--    hr_utility.set_location('null l_prtn_eff_end_dt_cd, so assign odbed',123);
    -- Bug 2806554 - Changed to ODBED from AEOT
    l_prtn_eff_end_dt_cd := 'ODBED';  -- one day before event date
  end if;
  --
  -- Set the out parameter to the date code that is being used.
  --
  p_prtn_eff_strt_dt_cd := l_prtn_eff_strt_dt_cd;
  p_prtn_eff_strt_dt_rl := l_prtn_eff_strt_dt_rl;
  --
--    hr_utility.set_location('p_start_or_end ben_determine_eligibility2.get_start_end_dates', 10);
  if p_start_or_end = 'S' then
    if l_prtn_eff_strt_dt_cd <> 'RL' then
--    hr_utility.set_location('ben_determine_eligibility2.get_start_end_dates SOE S not RL ben_determine_eligibility2.get_start_end_dates', 10);
    /*  -- FONM START
      if ben_manage_life_events.fonm = 'Y' and
         ben_manage_life_events.g_fonm_cvg_strt_dt is not null then
        --
        p_prtn_eff_strt_dt := ben_manage_life_events.g_fonm_cvg_strt_dt ;
        --
      else
        --
      --FONM END
      */
        ben_determine_date.main
          (p_date_cd           => l_prtn_eff_strt_dt_cd
          ,p_per_in_ler_id     => p_pil_row.per_in_ler_id
          ,p_person_id         => p_person_id
          ,p_pgm_id            => l_envpgm_id
          ,p_pl_id             => l_envpl_id
          ,p_oipl_id           => p_oipl_id
          ,p_business_group_id => p_business_group_id
          ,p_formula_id        => l_prtn_eff_strt_dt_rl
          ,p_lf_evt_ocrd_dt    => p_pil_row.lf_evt_ocrd_dt
          ,p_start_date        => null
          ,p_effective_date    => p_effective_date
          ,p_returned_date     => p_prtn_eff_strt_dt
          );
        --
      -- FONM START
     -- end if;
      -- FONM END
      --
    --  hr_utility.set_location('Done det date ben_determine_eligibility2.get_start_end_dates', 10);

    --
    elsif l_prtn_eff_strt_dt_cd = 'RL' then
--    hr_utility.set_location('ben_determine_eligibility2.get_start_end_dates SOE S RL ben_determine_eligibility2.get_start_end_dates', 10);
      --
      -- Get the date from calling a fast formula rule
      --
      --
      ben_person_object.get_object(p_person_id => p_person_id,
                                   p_rec       => l_ass_rec);
      if l_ass_rec.assignment_id is null then
        ben_person_object.get_benass_object(p_person_id => p_person_id,
                                            p_rec       => l_ass_rec);
      end if;
      if l_ass_rec.location_id is not null then
        ben_location_object.get_object(p_location_id => l_ass_rec.location_id,
                                       p_rec         => l_loc_rec);
--       if l_loc_rec.region_2 is not null then
--         l_jurisdiction_code :=
--           pay_mag_utils.lookup_jurisdiction_code
--             (p_state => l_loc_rec.region_2);
--       end if;
      end if;
      --
      -- Rule = Participation Eligibility Start Date (ID = -82)
      --
      -- Call formula initialise routine
      --
      if l_envpl_id is not null then
        --
        ben_comp_object.get_object
          (p_pl_id => l_envpl_id
          ,p_rec   => l_pl_rec
          );
        --
      end if;
      --
      if p_oipl_id is not null then
        --
        l_oipl_rec := ben_cobj_cache.g_oipl_currow;
        --
      end if;
      --
      l_outputs := benutils.formula
        (p_formula_id        => l_prtn_eff_strt_dt_rl
        ,p_effective_date    => p_effective_date
        ,p_business_group_id => p_business_group_id
        ,p_assignment_id     => l_ass_rec.assignment_id
        ,p_organization_id   => l_ass_rec.organization_id
        ,p_pl_id             => l_envpl_id
        ,p_pl_typ_id         => l_pl_rec.pl_typ_id
        ,p_pgm_id            => l_envpgm_id
        ,p_opt_id            => l_oipl_rec.opt_id
        ,p_ler_id            => p_pil_row.ler_id
        ,p_param1            => 'BEN_IV_RT_STRT_DT'
        ,p_param1_value      => fnd_date.date_to_canonical(ben_manage_life_events.g_fonm_rt_strt_dt)
        ,p_param2            => 'BEN_IV_CVG_STRT_DT'
        ,p_param2_value      => fnd_date.date_to_canonical(ben_manage_life_events.g_fonm_cvg_strt_dt)
	,p_param3            => 'BEN_IV_PERSON_ID'            -- Bug 5331889
        ,p_param3_value      => to_char(p_person_id)
        ,p_jurisdiction_code => l_jurisdiction_code
        );
      --
      -- Formula will return a date but code defensively in case the
      -- date can not be typecast.
      --
      begin
        p_prtn_eff_strt_dt := fnd_date.canonical_to_date
                                (l_outputs(l_outputs.first).value);
      exception
        when others then
          fnd_message.set_name('BEN','BEN_91329_FORMULA_RETURN');
          fnd_message.set_token('RL','prtn_eff_strt_dt_rl');
          fnd_message.set_token('PROC','ben_determine_eligibility2.get_start_end_dates');
          raise ben_manage_life_events.g_record_error;
      end;
    else
      fnd_message.set_name('BEN','BEN_91342_UNKNOWN_CODE_1');
      fnd_message.set_token('PROC','ben_determine_eligibility2.get_start_end_dates');
      fnd_message.set_token('CODE1',l_prtn_eff_strt_dt_cd);
      raise ben_manage_life_events.g_record_error ;
    end if;

  elsif p_start_or_end = 'E' then
    --
--    hr_utility.set_location('ben_determine_eligibility2.get_start_end_dates p_start_or_end is E ' , 10);
    -- FONM START
    if ben_manage_life_events.fonm = 'Y' and
       ben_manage_life_events.g_fonm_cvg_strt_dt is not null then
       --
       p_prtn_eff_end_dt := ben_manage_life_events.g_fonm_cvg_strt_dt - 1 ;
       --
       --END FONM
    elsif l_prtn_eff_end_dt_cd = 'A30DFPSD' then
      hr_utility.set_location('ben_determine_eligibility2.get_start_end_dates SOE E A30DFPSD ben_determine_eligibility2.get_start_end_dates', 10);
      --
      -- as of 30 days from prtn strt date
      -- the start date used here in the case of an oipl is from the
      -- elig_per_opt record, whereas for the pl or pgm the date is from
      -- the elig_per record.
      --
      ben_determine_date.main
        (p_date_cd           => l_prtn_eff_end_dt_cd
        ,p_start_date        => p_prev_prtn_strt_dt
        ,p_business_group_id => p_business_group_id
        ,p_effective_date    => p_effective_date
        ,p_returned_date     => p_prtn_eff_end_dt
        );
      --
    elsif l_prtn_eff_end_dt_cd = 'A12MFPSD' then
--    hr_utility.set_location('ben_determine_eligibility2.get_start_end_dates SOE E A12MFPSD ben_determine_eligibility2.get_start_end_dates', 10);
      --
      -- as of 12 months from prtn strt date
      -- the start date used here in the case of an oipl is from the
      -- elig_per_opt record, whereas for the pl or pgm the date is from
      -- the elig_per record.
      --
      ben_determine_date.main
        (p_date_cd           => l_prtn_eff_end_dt_cd
        ,p_start_date        => p_prev_prtn_strt_dt
        ,p_business_group_id => p_business_group_id
        ,p_effective_date    => p_effective_date
        ,p_returned_date     => p_prtn_eff_end_dt
        );
      --
    elsif l_prtn_eff_end_dt_cd = 'ALDCPP' then
--    hr_utility.set_location('ben_determine_eligibility2.get_start_end_dates SOE E ALDCPP ben_determine_eligibility2.get_start_end_dates', 10);
      --
      -- as of the last day of the pay period where date occurred
      --
      ben_determine_date.main
        (p_date_cd           => l_prtn_eff_end_dt_cd
        ,p_person_id         => p_person_id
        ,p_returned_date     => p_prtn_eff_end_dt
        ,p_business_group_id => p_business_group_id
        ,p_effective_date    => p_effective_date
        );
      --
    elsif l_prtn_eff_end_dt_cd = 'ALDCM' then
--    hr_utility.set_location('ben_determine_eligibility2.get_start_end_dates SOE E ALDCM ben_determine_eligibility2.get_start_end_dates', 10);
      --
      -- as of the last day of the month where date occurred
      --
      ben_determine_date.main
        (p_date_cd           => l_prtn_eff_end_dt_cd
        ,p_person_id         => p_person_id
        ,p_returned_date     => p_prtn_eff_end_dt
        ,p_business_group_id => p_business_group_id
        ,p_effective_date    => p_effective_date
        );
      --
    elsif l_prtn_eff_end_dt_cd = 'ALDCPPSY' then
--    hr_utility.set_location('ben_determine_eligibility2.get_start_end_dates SOE E ALDCPPSY ben_determine_eligibility2.get_start_end_dates', 10);
      --
      -- as of the last day of the pl semi-year where date occurred
      --Bug 2551834 Added nvl cases to handle ptip/plip cases
      ben_determine_date.main
        (p_date_cd        => l_prtn_eff_end_dt_cd
        ,p_person_id      => p_person_id
        ,p_pgm_id         => nvl(p_pgm_id,l_envpgm_id)
        ,p_pl_id          => nvl(p_pl_id,l_envpl_id)
        ,p_oipl_id        => p_oipl_id
        ,p_returned_date  => p_prtn_eff_end_dt
        ,p_business_group_id => p_business_group_id
        ,p_effective_date => p_effective_date
        );
      --
    elsif l_prtn_eff_end_dt_cd = 'ALDCPPY' then
--    hr_utility.set_location('ben_determine_eligibility2.get_start_end_dates SOE E ALDCPPY ben_determine_eligibility2.get_start_end_dates', 10);
      --
      -- as of the last day of the pl yr where date occurred
      --Bug 2551834 Added nvl cases to handle ptip/plip cases
      ben_determine_date.main
        (p_date_cd           => l_prtn_eff_end_dt_cd
        ,p_person_id         => p_person_id
        ,p_pgm_id            => nvl(p_pgm_id,l_envpgm_id)
        ,p_pl_id             => nvl(p_pl_id,l_envpl_id)
        ,p_oipl_id           => p_oipl_id
        ,p_returned_date     => p_prtn_eff_end_dt
        ,p_business_group_id => p_business_group_id
        ,p_effective_date    => p_effective_date
        );
      --
    /* Bug : 2551
       Following elsif is moved from the top as it logically
       belongs here. All the refrences to eff_strt_dt_cd are
       changed to eff_end_dt_cd.
    */
    elsif l_prtn_eff_end_dt_cd <> 'RL' then
      --
--    hr_utility.set_location('ben_determine_eligibility2.get_start_end_dates SOE E <> RL ben_determine_eligibility2.get_start_end_dates', 10);
      hr_utility.set_location(' SOE E <> RLBefore EEDT' || p_prtn_eff_end_dt,20);
      --NOCOPY ISSUE
      l_temp_prtn_strt_dt := p_prtn_eff_end_dt ;
      --
      ben_determine_date.main
        (p_date_cd           => l_prtn_eff_end_dt_cd
        ,p_per_in_ler_id     => p_pil_row.per_in_ler_id
        ,p_person_id         => p_person_id
        ,p_pgm_id            => l_envpgm_id
        ,p_pl_id             => l_envpl_id
        ,p_oipl_id           => p_oipl_id
        ,p_business_group_id => p_business_group_id
        ,p_formula_id        => l_prtn_eff_end_dt_rl
        ,p_lf_evt_ocrd_dt    => p_pil_row.lf_evt_ocrd_dt
        ,p_start_date        => l_temp_prtn_strt_dt -- NOCOPY ISSUE p_prtn_eff_end_dt
        ,p_effective_date    => p_effective_date
        ,p_returned_date     => p_prtn_eff_end_dt
        );
        --
        hr_utility.set_location(' SOE E <> RLAfter EEDT' || p_prtn_eff_end_dt,20);
        --
    elsif l_prtn_eff_end_dt_cd = 'RL' then
--    hr_utility.set_location('ben_determine_eligibility2.get_start_end_dates SOE E RL ben_determine_eligibility2.get_start_end_dates', 10);
      --
      -- Get the date from calling a fast formula rule
      --
      -- Rule = Participation Eligibility End Date (-83)
      --
      ben_person_object.get_object(p_person_id => p_person_id,
                                   p_rec       => l_ass_rec);
      if l_ass_rec.assignment_id is null then
        ben_person_object.get_benass_object(p_person_id => p_person_id,
                                            p_rec       => l_ass_rec);
      end if;
      if l_ass_rec.location_id is not null then
        ben_location_object.get_object(p_location_id => l_ass_rec.location_id,
                                       p_rec         => l_loc_rec);
--       if l_loc_rec.region_2 is not null then
--         l_jurisdiction_code :=
--           pay_mag_utils.lookup_jurisdiction_code
--             (p_state => l_loc_rec.region_2);
--       end if;
      end if;
      --
      -- Call formula initialise routine
      --
      if l_envpl_id is not null then
        --
        ben_comp_object.get_object
          (p_pl_id => l_envpl_id
          ,p_rec   => l_pl_rec
          );
        --
      end if;
      --
      if p_oipl_id is not null then
        --
        l_oipl_rec := ben_cobj_cache.g_oipl_currow;
        --
      end if;
      --
      l_outputs := benutils.formula
        (p_formula_id        => l_prtn_eff_end_dt_rl
        ,p_effective_date    => p_effective_date
        ,p_business_group_id => p_business_group_id
        ,p_assignment_id     => l_ass_rec.assignment_id
        ,p_organization_id   => l_ass_rec.organization_id
        ,p_pl_id             => l_envpl_id
        ,p_pl_typ_id         => l_pl_rec.pl_typ_id
        ,p_pgm_id            => l_envpgm_id
        ,p_opt_id            => l_oipl_rec.opt_id
        ,p_ler_id            => p_pil_row.ler_id
        ,p_param1            => 'BEN_IV_RT_STRT_DT'
        ,p_param1_value      => fnd_date.date_to_canonical(ben_manage_life_events.g_fonm_rt_strt_dt)
        ,p_param2            => 'BEN_IV_CVG_STRT_DT'
        ,p_param2_value      => fnd_date.date_to_canonical(ben_manage_life_events.g_fonm_cvg_strt_dt)
	,p_param3            => 'BEN_IV_PERSON_ID'            -- Bug 5331889
        ,p_param3_value      => to_char(p_person_id)
	,p_jurisdiction_code => l_jurisdiction_code
        );
      --
      -- Formula will return a date but code defensively in case the
      -- date can not be typecast.
      --
      begin
        p_prtn_eff_end_dt := fnd_date.canonical_to_date
                               (l_outputs(l_outputs.first).value);
      exception
        when others then
          fnd_message.set_name('BEN','BEN_91329_FORMULA_RETURN');
          fnd_message.set_token('RL','prtn_eff_end_dt_rl');
          fnd_message.set_token('PROC','ben_determine_eligibility2.get_start_end_dates');
          raise ben_manage_life_events.g_record_error;
      end;

    else
      fnd_message.set_name('BEN','BEN_91342_UNKNOWN_CODE_1');
      fnd_message.set_token('PROC','ben_determine_eligibility2.get_start_end_dates');
      fnd_message.set_token('CODE1',l_prtn_eff_end_dt_cd);
      raise ben_manage_life_events.g_record_error;
    end if;
  else
    fnd_message.set_name('BEN','BEN_91393_STRT_END_ERROR');
    fnd_message.set_token('PROC','ben_determine_eligibility2.get_start_end_dates');
    raise ben_manage_life_events.g_record_error;
  end if;
--  hr_utility.set_location('Leaving ben_determine_eligibility2.get_start_end_dates',10);

end get_start_end_dates;
--

--
-- -----------------------------------------------------------------------------
-- |------------------------< check_prev_elig >--------------------------------|
-- -----------------------------------------------------------------------------
--
procedure check_prev_elig
  (p_comp_obj_tree_row       in out NOCOPY ben_manage_life_events.g_cache_proc_objects_rec
  ,p_per_row                 in out NOCOPY per_all_people_f%rowtype
  ,p_empasg_row              in out NOCOPY per_all_assignments_f%rowtype
  ,p_benasg_row              in out NOCOPY per_all_assignments_f%rowtype
  ,p_pil_row                 in out NOCOPY ben_per_in_ler%rowtype
  ,p_person_id               in     number
  ,p_business_group_id       in     number
  ,p_effective_date          in     date
  ,p_lf_evt_ocrd_dt          in     date
  ,p_pl_id                   in     number
  ,p_pgm_id                  in     number
  ,p_oipl_id                 in     number
  ,p_plip_id                 in     number
  ,p_ptip_id                 in     number
  ,p_ler_id                  in     number
  ,p_comp_rec                in out NOCOPY ben_derive_part_and_rate_facts.g_cache_structure
  ,p_oiplip_rec              in out NOCOPY ben_derive_part_and_rate_facts.g_cache_structure
  ,p_inelg_rsn_cd            in     varchar2
  --
  ,p_elig_flag               in out nocopy boolean
  ,p_newly_elig                 out nocopy boolean
  ,p_newly_inelig               out nocopy boolean
  ,p_first_elig                 out nocopy boolean
  ,p_first_inelig               out nocopy boolean
  ,p_still_elig                 out nocopy boolean
  ,p_still_inelig               out nocopy boolean
  ,p_score_tab               in ben_evaluate_elig_profiles.scoreTab default ben_evaluate_elig_profiles.t_default_score_tbl
  )
is
  --
/* 4968123
  l_proc varchar2(100) := g_package||'check_prev_elig';
*/
  --
  -- There are six things a person can be:
  --
  l_newly_elig            boolean := FALSE;  -- elig   and prev inelig
  l_newly_inelig          boolean := FALSE;  -- inelig and prev elig
  l_first_elig            boolean := FALSE;  -- elig   and prev did not exist
  l_first_inelig          boolean := FALSE;  -- inelig and prev did not exist
  l_still_elig            boolean := FALSE;  -- elig and still elig
  l_still_inelig          boolean := FALSE;  -- elig and still elig
  --
  -- This flag covers the case where a person is first time in-eligible
  -- but we do not want to track in-eligibility.
  --
  /*PLEASE NOTE THE FOLLOWING:

     1.  Option eligibility is written to             ben_elig_per_opt_f
     2.  Plan and Program eligibility is written to   ben_elig_per_f
     3.  When a person is found eligible or ineligible for a pgm, pl or oipl,
         a check for previous eligibility/ineligibility will determine
         whether a new row will be inserted or an existing row will be
         updated.
     4.  If a person is still eligible or ineligible, then nothing is done.
     5.  If a person is newly eligible, then a new row will be inserted.
     6.  If a person is newly ineligible, then an existing row will be
         updated.
     7.  If a person is first-time eligible, then a new row will be inserted.
     8.  If a person is first-time ineligible, and the track ineligible persons
         flag is 'Y' on the program, plan or option we are processing then a
         new row will be inserted with elig_flag of 'N'.
     9.  If a person is found "eligible again"--meaning the history of the
         person shows that they were once eligible, then found ineligible
         and now are eligible again, then that person will be treated as
         though they are newly eligible, i.e. a row will be inserted.
  */
  --
  l_epo_row                   ben_derive_part_and_rate_facts.g_cache_structure;
  l_oiplipepo_row             ben_derive_part_and_rate_facts.g_cache_structure;
  l_oiplippep_row             ben_derive_part_and_rate_facts.g_cache_structure;
  l_pep_row                   ben_derive_part_and_rate_facts.g_cache_structure;
  --
  l_new_per_in_ler_id         ben_elig_per_f.per_in_ler_id%type;
  l_per_in_ler_id             ben_elig_per_f.per_in_ler_id%type;
  l_prev_per_in_ler_id        ben_elig_per_f.per_in_ler_id%type;
  l_elig_per_id               ben_elig_per_f.elig_per_id%TYPE;
  l_elig_per_elig_flag        ben_elig_per_f.elig_flag%TYPE;
  l_object_version_number     ben_elig_per_f.object_version_number%TYPE;
  l_object_version_number_opt ben_elig_per_opt_f.object_version_number%type;
  l_t_object_version_number ben_elig_per_opt_f.object_version_number%type;
  l_p_object_version_number ben_elig_per_f.object_version_number%type;
  l_t_effective_dt       date;
  l_prev_elig                 boolean := FALSE;
  l_prtn_eff_strt_dt          date;
  l_prtn_eff_end_dt           date;
  l_elig_per_prtn_strt_dt     date;
  l_elig_per_prtn_end_dt      date;
  l_prev_prtn_strt_dt         date;
  l_prev_prtn_end_dt          date;
  l_effective_start_date      date;
  l_effective_end_date        date;
  l_datetrack_mode            varchar2(100);
  l_elig_per_opt_id           ben_elig_per_opt_f.elig_per_opt_id%type;
  l_elig_per_oiplip_id        ben_elig_per_opt_f.elig_per_opt_id%type;
  l_effective_start_date_opt  date;
  l_effective_end_date_opt    date;
  l_opt_elig_flag             ben_elig_per_opt_f.elig_flag%type;
  l_opt_id                    ben_opt_f.opt_id%type;
  l_pl_id                     ben_pl_f.pl_id%type;
  l_start_or_end              varchar2(1);
  l_end_dt_plus_one           date;
  l_wait_perd_cmpltn_dt       date;
  l_wait_perd_strt_dt         date;
  l_after_wtg_prtn_strt_dt    date;
  l_correction                boolean;
  l_update                    boolean;
  l_update_override           boolean;
  l_update_change_insert      boolean;
  l_oipl_rec                  ben_cobj_cache.g_oipl_inst_row;
  --
  l_envpgm_id                 number;
  l_envptip_id                number;
  l_envplip_id                number;
  l_envpl_id                  number;
  l_effective_dt              date := least(p_effective_date,nvl(p_lf_evt_ocrd_dt,p_effective_date));
  --
  --FONM
  l_fonm_cvg_strt_dt DATE ;
  --END FONM

  -- iRec
  l_env_rec              ben_env_object.g_global_env_rec_type;
  l_benmngle_parm_rec    benutils.g_batch_param_rec;
  -- End iRec
/* 4968123
  -- Cursor to check previous eligibility for plan/program.
  --
  CURSOR c_prev_elig_check
    (c_person_id      in number
    ,c_pgm_id         in number
    ,c_pl_id          in number
    ,c_ptip_id        in number
    ,c_effective_date in date
    )
  IS
    select pep.elig_per_id,
           pep.elig_flag,
           pep.prtn_strt_dt,
           pep.prtn_end_dt,
           pep.per_in_ler_id,
           pep.object_version_number
    from   ben_elig_per_f pep,
           ben_per_in_ler pil
    where  pep.person_id = c_person_id
    and    nvl(pep.pgm_id,-1)  = c_pgm_id
    and    nvl(pep.pl_id,-1)   = c_pl_id
    and    pep.plip_id is null
    and    nvl(pep.ptip_id,-1) = c_ptip_id
    and    c_effective_date
           between pep.effective_start_date
           and pep.effective_end_date
    and    pil.per_in_ler_id(+)=pep.per_in_ler_id
    and    pil.business_group_id(+)=pep.business_group_id
    and    (   pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT') -- found row condition
            or pil.per_in_ler_stat_cd is null                  -- outer join condition
           )
    and    nvl(pil.assignment_id, -9999) = decode ( l_benmngle_parm_rec.mode_cd,
                                           'I',
				           ben_manage_life_events.g_irec_ass_rec.assignment_id,
				           nvl(pil.assignment_id, -9999) )             -- iRec : Match assignment_id for iRec
  ;
*/
/* 4968123
  --
  -- Cursor to check previous eligibility for option.
  --
  cursor c_prev_opt_elig_check
    (c_person_id      in number
    ,c_effective_date in date
    ,c_pl_id          in number
    ,c_opt_id         in number
    )
  is
    select epo.elig_per_opt_id,
           epo.elig_flag,
           epo.prtn_strt_dt,
           epo.prtn_end_dt,
           epo.object_version_number,
           pep.elig_per_id,
           epo.per_in_ler_id,
           pep.prtn_strt_dt,
           pep.prtn_end_dt
    from   ben_elig_per_opt_f epo,
           ben_per_in_ler pil,
           ben_elig_per_f pep
    where  pep.person_id   = c_person_id
    and    pep.pl_id = c_pl_id
    and    epo.opt_id = c_opt_id
    and    pep.elig_per_id = epo.elig_per_id
    and    pep.pgm_id is null
    and    c_effective_date
           between pep.effective_start_date
           and pep.effective_end_date
    and    c_effective_date
           between epo.effective_start_date
           and epo.effective_end_date
    and    pil.per_in_ler_id(+)=epo.per_in_ler_id
    and    pil.business_group_id(+)=epo.business_group_id
    and    (   pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
            or pil.per_in_ler_stat_cd is null)
    and    nvl(pil.assignment_id,-9999) = decode ( l_benmngle_parm_rec.mode_cd,
                                          'I',
				          ben_manage_life_events.g_irec_ass_rec.assignment_id,
				          nvl(pil.assignment_id, -9999)    );             -- iRec : Match assignment_id for iRec
*/
  --
  cursor c_prev_oiplip_elig_check
    (c_person_id      in number
    ,c_effective_date in date
    ,c_pgm_id         in number
    ,c_plip_id        in number
    ,c_opt_id         in number
    )
  is
    select epo.elig_per_opt_id,
           epo.elig_per_id,
           epo.effective_start_date,
           epo.object_version_number
    from   ben_elig_per_opt_f epo,
           ben_per_in_ler pil,
           ben_elig_per_f pep
    where  pep.person_id = c_person_id
    and    pep.pgm_id    = c_pgm_id
    and    pep.plip_id   = c_plip_id
    and    epo.opt_id    = c_opt_id
    and    pep.elig_per_id = epo.elig_per_id
    and    c_effective_date
           between pep.effective_start_date
           and pep.effective_end_date
    and    c_effective_date
           between epo.effective_start_date
           and epo.effective_end_date
    and    pil.per_in_ler_id(+)=epo.per_in_ler_id
    and    pil.business_group_id(+)=epo.business_group_id
    and    (   pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
            or pil.per_in_ler_stat_cd is null) ;
  --
  l_prev_oiplip_elig_check c_prev_oiplip_elig_check%rowtype;
  --
  -- Cursor to check for overlapping eligiblitiy
  --
  CURSOR c_overlap
    (c_prtn_eff_strt_dt in date
    ,c_elig_flag        in varchar2
    ,c_add_one          in number
    )
  is
    select  pep.prtn_strt_dt
    from    ben_elig_per_f pep,
            ben_per_in_ler pil
    where   pep.person_id = p_person_id
    and     nvl(pep.pgm_id,-1) =
            nvl(p_pgm_id,nvl(l_envpgm_id,-1))
    and     nvl(pep.pl_id,-1) = nvl(p_pl_id,-1)
    and     nvl(pep.plip_id,-1) = nvl(p_plip_id,-1)
    and     nvl(pep.ptip_id,-1) = nvl(p_ptip_id,-1)
    and     c_prtn_eff_strt_dt between pep.prtn_strt_dt
            and (pep.prtn_end_dt + c_add_one)
    and     pep.elig_flag = c_elig_flag
    and     pil.per_in_ler_id(+)=pep.per_in_ler_id
    and     pil.business_group_id(+)=pep.business_group_id
    and     (   pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT') -- found row condition
             or pil.per_in_ler_stat_cd is null                  -- outer join condition
            );
  --
  cursor c_get_pl_id(c_effective_date date) is select pl_id
  from ben_plip_f cpp
  where cpp.plip_id = p_plip_id
  and     c_effective_date
            between cpp.effective_start_date
            and cpp.effective_end_date;
--
  cursor c_get_pl_from_ptip(c_effective_date date) is
  select pl.pl_id
    from ben_ptip_f ctp,ben_pl_f pl
   where ctp.ptip_id = p_ptip_id
     and pl.pl_typ_id = ctp.pl_typ_id
     and     c_effective_date
            between ctp.effective_start_date
            and ctp.effective_end_date
     and     c_effective_date
            between pl.effective_start_date
            and pl.effective_end_date;
  --
  l_overlap       c_overlap%ROWTYPE;
  --
  -- Cursor to check for overlapping eligiblitiy
  --
  cursor c_opt_overlap
    (c_prtn_eff_strt_dt in date
    ,c_elig_flag        in varchar2
    ,c_add_one          in number
    )
  is
    select epo.prtn_strt_dt
    from   ben_elig_per_opt_f epo,
           ben_elig_per_f pep,
           ben_per_in_ler pil
    where  pep.person_id   = p_person_id
    and    pep.pl_id = l_envpl_id
    and    nvl(pep.pgm_id,-1) = nvl(l_envpgm_id,-1)
    and    pep.elig_per_id = epo.elig_per_id
    and    c_prtn_eff_strt_dt
           between epo.prtn_strt_dt
           and (epo.prtn_end_dt + c_add_one)
    and    epo.opt_id = l_oipl_rec.opt_id
    and    epo.elig_flag = c_elig_flag
    and    pil.per_in_ler_id(+)=epo.per_in_ler_id
    and    pil.business_group_id(+)=epo.business_group_id+0
    and    (   pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
            or pil.per_in_ler_stat_cd is null);
  --
  l_opt_overlap       c_opt_overlap%ROWTYPE;
  --
  -- CWB changes : Modified cusrsor
  --
  -- bug 3001411 - Presence of unrestricted LE between eff date and
  -- waiting perd compltn date should not considered as a reason to
  -- make the person ineligible. So added the not in clause for ler.typ_cd
  -- As per PM, we should ignore the 'unrestricted' , Absences, CWB and
  -- any 'Non-Benefits' type of life event.
  --
  -- iRec : Added mode iRecruitmnent (I)
  cursor c_ptnl_le(v_wait_end_dt date) is
    select 's'
    from   ben_ptnl_ler_for_per ptl,
           ben_ler_f ler
    where  ptl.person_id = p_person_id
    and    ptl.ler_id <> p_ler_id
    and    ler.ler_id = ptl.ler_id
    and    ler.typ_cd not in ('COMP', 'ABS', 'SCHEDDU', 'GSP', 'IREC')   -- iRec
    and    ptl.ptnl_ler_for_per_stat_cd <> 'VOIDD'
    and    ptl.lf_evt_ocrd_dt
           between p_effective_date
           and     v_wait_end_dt
    and    ptl.business_group_id   = p_business_group_id;
  --
  cursor c_plip_ordr(c_effective_date date ) is
  select plip.ordr_num from ben_plip_f plip
  where plip.pgm_id = nvl(p_pgm_id,l_envpgm_id)
  and pl_id = p_pl_id
    and     c_effective_date
            between plip.effective_start_date
            and plip.effective_end_date
    and    plip.business_group_id   = p_business_group_id;

  l_ptnl_le c_ptnl_le%rowtype;
  --
  l_trk_inelig_per_flag        varchar2(30);
  l_pgm_rec                    ben_cobj_cache.g_pgm_inst_row;
  l_pl_rec                     ben_cobj_cache.g_pl_inst_row;
  l_plip_rec                   ben_cobj_cache.g_plip_inst_row;
  l_ptip_rec                   ben_cobj_cache.g_ptip_inst_row;
  l_prtn_st_dt_aftr_wtg        date;
  l_prtn_eff_strt_dt_cd        varchar2(80);
  l_prtn_eff_strt_dt_rl        number(15);
  l_plan_ordr_num              ben_pl_f.ordr_num%type;
  --
  l_comp_rec                   ben_derive_part_and_rate_facts.g_cache_structure;
  l_oiplip_rec                 ben_derive_part_and_rate_facts.g_cache_structure;
  l_pil_rec                    ben_per_in_ler%rowtype;
  l_prev_eligibility           boolean;
  --
  l_oiplippep_dets             ben_pep_cache.g_pep_rec;
  l_plnpep_dets                ben_pep_cache.g_pep_rec;
  --
  l_elig_flag                  varchar2(1);
  l_prtn_strt_dt               date;
  l_oiplip_pep_id              number;
  l_oiplip_epo_id              number;
  l_oiplip_elig_flag           varchar2(1);
  l_old_age_val                number;
  l_old_los_val                number;
  l_count_icm1 number;
  l_count_icm number;
  l_count_icm3 number;
  l_count_icm31 number :=0;


  /* Bug 9020962 */
   /* Cursor to get the previous per_in_ler_id*/
   cursor c_prev_pil(c_per_in_ler_id number ) is
    select pil.per_in_ler_id
    from   ben_per_in_ler pil,
           ben_ler_f ler
    where  pil.per_in_ler_id not in (c_per_in_ler_id)
    and    pil.person_id     = p_person_id
    and    pil.ler_id        = ler.ler_id
    and    p_effective_date between
           ler.effective_start_date and ler.effective_end_date
    and    ler.typ_cd not in ('IREC', 'SCHEDDU', 'COMP', 'GSP', 'ABS')
    and    pil.per_in_ler_stat_cd not in('BCKDT', 'VOIDD')
    order by pil.lf_evt_ocrd_dt desc;

  /* Cursor to get the eligibility record */
  cursor c_elig_rec(c_elig_per_id number,c_per_in_ler_id number) is
  select * from ben_elig_per_f
  where elig_per_id = c_elig_per_id
        and per_in_ler_id = c_per_in_ler_id;

  l_prev_pil_id number;

  l_elig_per_rec c_elig_rec%rowtype;

 /* Cursor to check whether future eligibility record exists for the previous
 life event */
  cursor c_elig_per_id(c_per_in_ler_id number,
                      c_pl_id number,
		      c_pgm_id number,
		      c_ptip_id number,
		      c_plip_id number,
		      c_effective_date date) is
 select * from ben_elig_per_f pep
 where  nvl(pep.pgm_id,-1)  = nvl(c_pgm_id,-1)
        and  nvl(pep.pl_id,-1)   = nvl(c_pl_id,-1)
	and  nvl(pep.plip_id,-1) = nvl(c_plip_id ,-1)
        and  nvl(pep.ptip_id,-1) = nvl(c_ptip_id,-1)
	and pep.per_in_ler_id = c_per_in_ler_id
	and c_effective_date < pep.effective_start_date;

 l_ftr_elig_per_rec c_elig_rec%rowtype;
/* End of Bug 9020962*/

  --
begin
  --
  g_debug := hr_utility.debug_enabled;
  --
  if g_debug then
    --
    hr_utility.set_location('Entering : ben_determine_eligibility2.check_prev_elig', 10);
    hr_utility.set_location('p_pgm_id   -> ' ||p_pgm_id ,223);
    hr_utility.set_location('p_ptip_id  -> ' ||p_ptip_id,223);
    hr_utility.set_location('p_plip_id  -> ' ||p_plip_id,223);
    hr_utility.set_location('p_pl_id    -> ' ||p_pl_id  ,223);
    hr_utility.set_location('p_oipl_id  -> ' ||p_oipl_id,223);
    --
  end if;
  --
  -- iRec
  ben_env_object.get(p_rec => l_env_rec);
  benutils.get_batch_parameters( p_benefit_action_id => l_env_rec.benefit_action_id
                                ,p_rec               => l_benmngle_parm_rec);
   hr_utility.set_location('l_benmngle_parm_rec.mode_cd'||l_benmngle_parm_rec.mode_cd,125);
  -- iRec
  if ben_manage_life_events.fonm = 'Y'
      and ben_manage_life_events.g_fonm_cvg_strt_dt is not null then
     --
     l_fonm_cvg_strt_dt := ben_manage_life_events.g_fonm_cvg_strt_dt ;
     --
  end if;
  --
  l_effective_dt := nvl(l_fonm_cvg_strt_dt,l_effective_dt);
  --
  -- First check to see if there is a waiting period for the comp object being
  -- processed. This applies only if the participant is found first-time or
  -- newly eligible (after being ineligible).
  --
  -- Assign comp object locals
  --
  l_envpgm_id  := p_comp_obj_tree_row.par_pgm_id;
  l_envptip_id := p_comp_obj_tree_row.par_ptip_id;
  l_envplip_id := p_comp_obj_tree_row.par_plip_id;
  l_envpl_id   := p_comp_obj_tree_row.par_pl_id;
  --
  -- get the per_in_ler_id
  --
  l_pil_rec := p_pil_row;
  --
  l_new_per_in_ler_id:=l_pil_rec.per_in_ler_id;
  --
  if p_elig_flag = TRUE then
    --
    if g_debug then
      hr_utility.set_location('Wait period: ben_determine_eligibility2.check_prev_elig', 10);
    end if;
    --
   IF nvl(l_env_rec.mode_cd,'~') <> 'D' THEN
    --
    ben_det_wait_perd_cmpltn.main
      (p_comp_obj_tree_row => p_comp_obj_tree_row
      ,p_person_id         => p_person_id
      ,p_effective_date    => p_effective_date
      ,p_business_group_id => p_business_group_id
      ,p_ler_id            => l_pil_rec.ler_id
      ,p_oipl_id           => p_oipl_id
      ,p_pl_id             => p_pl_id
      ,p_pgm_id            => p_pgm_id
      ,p_plip_id           => p_plip_id
      ,p_ptip_id           => p_ptip_id
      ,p_lf_evt_ocrd_dt    => l_pil_rec.lf_evt_ocrd_dt
      ,p_ntfn_dt           => l_pil_rec.ntfn_dt
      ,p_return_date       => l_wait_perd_cmpltn_dt
      ,p_wait_perd_strt_dt => l_wait_perd_strt_dt
      );
    --
    if g_debug then
      hr_utility.set_location('Dn Wait period: ben_determine_eligibility2.check_prev_elig', 10);
      hr_utility.set_location('Wait period strt dt : ' || l_wait_perd_strt_dt, 10);
    end if;
    if l_wait_perd_cmpltn_dt is not null then
      -- If a potential life event exists between the effective date and the
      -- waiting period completion date, then raise an error and stop further
      -- processing of this comp object. Also write a descriptive message to the
      -- log.
      hr_utility.set_location('Checking for ptnl life events ben_determine_eligibility2.check_prev_elig', 10);

      open c_ptnl_le(l_wait_perd_cmpltn_dt);
      fetch c_ptnl_le into l_ptnl_le;
      if c_ptnl_le%found
         and l_benmngle_parm_rec.mode_cd <> 'I'  --iRec:Do not raise the error when BENMNGLE processed in iRecruitment mode
      then
        close c_ptnl_le;
        fnd_message.set_name ('BEN','BEN_93992_PTNL_IN_WTG_PERD'); -- 3597303
        hr_utility.set_location('PTNL LE FOUND ben_determine_eligibility2.check_prev_elig', 10);
        ben_manage_life_events.g_output_string :=
          ben_manage_life_events.g_output_string||
           'Elg: Yes '||-- 3597303
           'Warning:'||fnd_message.get;
        --
        -- DDW change, set object ineligible
        --
        p_elig_flag := true;---false; -- bug 3597303
        --
      else
        hr_utility.set_location('PTNL LE not found. Call BENDRPAR', 10);
        close c_ptnl_le;

        -- There's no potential life event. Re determine temporal factors using
        -- the wait perd cmpltn date as the life event ocrd date or ntfn date.
        ben_derive_part_and_rate_facts.derive_rates_and_factors
          (p_comp_obj_tree_row         => p_comp_obj_tree_row
          --
          ,p_per_row                   => p_per_row
          ,p_empasg_row                => p_empasg_row
          ,p_benasg_row                => p_benasg_row
          ,p_pil_row                   => p_pil_row
          --
          ,p_person_id                 => p_person_id
          ,p_business_group_id         => p_business_group_id
          ,p_pgm_id                    => p_pgm_id
          ,p_pl_id                     => p_pl_id
          ,p_oipl_id                   => p_oipl_id
          ,p_plip_id                   => p_plip_id
          ,p_ptip_id                   => p_ptip_id
          ,p_ptnl_ler_trtmt_cd         => NULL
          ,p_comp_rec                  => l_comp_rec
          ,p_oiplip_rec                => l_oiplip_rec
          ,p_effective_date            => p_effective_date
          ,p_lf_evt_ocrd_dt            => l_wait_perd_cmpltn_dt
          );
          --RCHASE bug 1531030. Was not passing back updated values.
          p_comp_rec:=l_comp_rec;
          p_oiplip_rec:=l_oiplip_rec;
        --
        --
        -- Check if any temporal life events got created because of the call
        -- to BENDRPAR above and if yes, stop processing and log message.
        --
        open c_ptnl_le(l_wait_perd_cmpltn_dt);
        fetch c_ptnl_le into l_ptnl_le;

        if c_ptnl_le%found
           and l_benmngle_parm_rec.mode_cd <> 'I'  --iRec:Do not raise the error when BENMNGLE processed in iRecruitment mode
        then
          close c_ptnl_le;
          fnd_message.set_name ('BEN','BEN_93992_PTNL_IN_WTG_PERD'); -- 3597303
          ben_manage_life_events.g_output_string :=
            ben_manage_life_events.g_output_string||
             'Elg: Yes '||-- 3597303
             'Warning:'||fnd_message.get;
          --
          -- DDW change, set object ineligible
          --
          p_elig_flag := true; -- 3597303
          --
          -- 1517275 : added else and moved end if
          -- and hr_utility.set_location
          -- tm 11/29
        else -- no rows returned
          hr_utility.set_location('TEMPORAL PTNL LE not found.', 15);
          close c_ptnl_le;
        end if;
      end if; -- c_ptnl_le
    end if; -- wait_perd_cmpltn_dt
  end if; --'D' mode
  end if; -- elig_flag
  --
  -- Check for previous eligibility for oipl.
  --
  if p_oipl_id is not null then --a
    --
    l_oipl_rec := ben_cobj_cache.g_oipl_currow;
    --
    if g_debug then
      hr_utility.set_location('open c_prvoptelch ben_determine_eligibility2.check_prev_elig', 10);
    end if;
    --
    -- Check for oipl in a program
    --
    if l_envpgm_id is not null then
      --
      --BUG 3327841 this needs to be cached with right l_effective_dt
      --Remember that as part of PLAN elig process, that record got updated
      --and we need to cache it again so that we get the previus epo records
      --with current pep record which fetched the right l_epo_row.prtn_strt_dt
      --like it is done in the c_prev_opt_elig_check cursor in the else clause
      --below.
      --
      -- ben_pep_cache.clear_down_cache ;
      -- clear_down_cache is not required as we have to use this
      -- output for only the previous eligibility. But keep in mind that the cursor
      -- c_prev_opt_elig_check return the previous elig_per_opt record with current
      -- elig_per record while evaluating the options.
      --
      --reversed the fix made for 5682845 - it creates new set of rows

      ben_pep_cache.get_pilepo_dets
        (p_person_id         => p_person_id
        ,p_business_group_id => p_business_group_id
        ,p_effective_date    => l_effective_dt
        ,p_pgm_id            => l_envpgm_id
       -- ,p_plip_id           => l_envplip_id --Bug 5682845 passed the plipid
        ,p_pl_id             => l_envpl_id
        ,p_opt_id            => l_oipl_rec.opt_id
        ,p_date_sync         => TRUE
        ,p_inst_row	     => l_epo_row
        );
      --
      if g_debug then
        hr_utility.set_location('ik-l_effective_dt '||l_oipl_rec.opt_id,10);
        hr_utility.set_location('ik-l_oipl_rec.opt_id '||l_oipl_rec.opt_id,10);
        hr_utility.set_location('ik-l_epo_row.elig_per_opt_id '||l_epo_row.elig_per_opt_id,10);
      end if;
      --
      if l_epo_row.elig_per_opt_id is null then
        --
        l_prev_eligibility := false;
        --
      else
        --
        l_prev_eligibility := true;
        --
      end if;
      --
      l_elig_per_opt_id           := l_epo_row.elig_per_opt_id;
      l_opt_elig_flag             := l_epo_row.elig_flag;
      l_prev_prtn_strt_dt         := l_epo_row.prtn_strt_dt;
      l_prev_prtn_end_dt          := l_epo_row.prtn_end_dt;
      l_object_version_number_opt := l_epo_row.object_version_number;
      l_elig_per_id               := l_epo_row.elig_per_id;
      l_per_in_ler_id             := l_epo_row.per_in_ler_id;
      l_old_age_val               := l_epo_row.age_val;
      l_old_los_val               := l_epo_row.los_val;
      --
      --BUG 3327841 Getting EOT for EPE and ECR records due wrong
      --assignment we do here.
      --
      /*
      l_elig_per_prtn_strt_dt     := l_epo_row.prtn_strt_dt;
      l_elig_per_prtn_end_dt      := l_epo_row.prtn_end_dt;
      */
      l_elig_per_prtn_strt_dt     :=l_epo_row.pep_prtn_strt_dt;
      l_elig_per_prtn_end_dt      :=l_epo_row.pep_prtn_end_dt;
    --
    -- Check for oipl not in a program
    --
    else
      --
      if g_debug then
        hr_utility.set_location('fetch c_prvoptelch ben_determine_eligibility2.check_prev_elig', 10);
      end if;
      --
      ben_determine_eligibility4.prev_opt_elig_check
        (p_person_id             => p_person_id
        ,p_effective_date        => l_effective_dt
        ,p_pl_id                 => l_envpl_id
        ,p_opt_id                => l_oipl_rec.opt_id
        ,p_mode_cd               => l_benmngle_parm_rec.mode_cd
        ,p_irec_asg_id           => ben_manage_life_events.g_irec_ass_rec.assignment_id
        --
        ,p_prev_eligibility          => l_prev_eligibility
        ,p_elig_per_opt_id           => l_elig_per_opt_id
        ,p_opt_elig_flag             => l_opt_elig_flag
        ,p_prev_prtn_strt_dt         => l_prev_prtn_strt_dt
        ,p_prev_prtn_end_dt          => l_prev_prtn_end_dt
        ,p_object_version_number_opt => l_object_version_number_opt
        ,p_elig_per_id               => l_elig_per_id
        ,p_per_in_ler_id             => l_per_in_ler_id
        ,p_elig_per_prtn_strt_dt     => l_elig_per_prtn_strt_dt
        ,p_elig_per_prtn_end_dt      => l_elig_per_prtn_end_dt
        ,p_prev_age_val              => l_old_age_val
        ,p_prev_los_val              => l_old_los_val
        );
      --
      l_t_object_version_number := l_object_version_number_opt;
      l_t_effective_dt := l_effective_dt;
      --
/* 4968123
      open c_prev_opt_elig_check
        (c_person_id      => p_person_id
        ,c_effective_date => l_effective_dt
        ,c_pl_id          => l_envpl_id
        ,c_opt_id         => l_oipl_rec.opt_id
        );
      fetch c_prev_opt_elig_check into l_elig_per_opt_id,
                                       l_opt_elig_flag,
                                       l_prev_prtn_strt_dt,
                                       l_prev_prtn_end_dt,
                                       l_object_version_number_opt,
                                       l_elig_per_id,
                                       l_per_in_ler_id,
                                       l_elig_per_prtn_strt_dt,
                                       l_elig_per_prtn_end_dt;
      if c_prev_opt_elig_check%notfound then
        --
        l_prev_eligibility := false;
        --
      else
        --
        l_prev_eligibility := true;
        --
      end if;
      close c_prev_opt_elig_check;
      --
*/
      if g_debug then
        hr_utility.set_location('Dn fetch c_prvoptelch ben_determine_eligibility2.check_prev_elig', 10);
      end if;
    end if;
    --
    l_prev_per_in_ler_id := l_per_in_ler_id;
    --
    if l_new_per_in_ler_id is not null then
      --
      l_per_in_ler_id:=l_new_per_in_ler_id;
      --
    end if;
    --
    if not l_prev_eligibility
    then  --b
      -- No record exist Person not previously elig or inelig for selctd oipl
      if p_elig_flag then
        --
	hr_utility.set_location ('oipl first elig',121);
        l_first_elig := true;
        l_start_or_end := 'S';
        fnd_message.set_name ('BEN','BEN_91385_FIRST_ELIG');
        benutils.write(p_text => fnd_message.get);
      --
      else
        --
        fnd_message.set_name ('BEN','BEN_92533_FIRST_INELIG2');
        benutils.write(p_text => fnd_message.get);
        -- only continue with program and call of api if we want to track
        -- inelig people.
        l_trk_inelig_per_flag := l_oipl_rec.trk_inelig_per_flag;
        --
        if l_trk_inelig_per_flag = 'Y' then
          --
	hr_utility.set_location ('first inelig',121);
          l_first_inelig := true;
          l_start_or_end := 'E';
          --
        else
          --
          -- Set transition state for processing only. Elig
          -- per is not written
          p_first_inelig := true;
          -- person is inelig for the first time
          -- and not being recorded.
          if instr(ben_manage_life_events.g_output_string,
                   'Elg:') = 0 then
            --
            ben_manage_life_events.g_output_string :=
            ben_manage_life_events.g_output_string||
                'Elg: No '||
                'Rsn: Inelig FT';
              --
          end if;
          --
          return;
          --
        end if;
        --
      end if;
      --
    elsif l_prev_eligibility
    then--b
      --
       if l_opt_elig_flag = 'Y' and p_elig_flag then  --d
          -- Person still eligible, do nothing.
          fnd_message.set_name ('BEN','BEN_91345_ELIG_PREV_ELIG');
          benutils.write(p_text => fnd_message.get);
          --
          if instr(ben_manage_life_events.g_output_string,
                   'Elg:') = 0 then
            --
            ben_manage_life_events.g_output_string :=
              ben_manage_life_events.g_output_string||
              'Elg: Yes '||
              'Rsn: Still Elig';
            --
          end if;
          --
	hr_utility.set_location ('still elig',121); --Since we clear cache after every run so even though
          l_start_or_end := 'S';                    -- still elig need to build the cache
          l_still_elig := true;
          --
         --return;
          --
      elsif l_opt_elig_flag = 'Y' and p_elig_flag = false then  --d
        -- person is newly inelig
	hr_utility.set_location ('newly inelig',121);
        l_newly_inelig := true;
        l_start_or_end := 'E';
        fnd_message.set_name('BEN','BEN_91347_NOT_ELIG_PREV_ELIG');
        benutils.write(p_text => fnd_message.get);
        --
      elsif l_opt_elig_flag = 'N' and p_elig_flag = false then  --d
        -- person is still inelig, do nothing.
        fnd_message.set_name('BEN','BEN_91348_NOT_ELIG_PREV_NT_ELG');
        benutils.write(p_text => fnd_message.get);
        --
        -- Set transition state for processing only. Elig
        -- per is not written
        --
        l_still_inelig := TRUE;           --changed to l_still_inelig from p_still_inelig
      /*Fidelity enh inelg to inelg */
        if l_benmngle_parm_rec.mode_cd in ('L','C') then
          l_trk_inelig_per_flag := l_oipl_rec.trk_inelig_per_flag;
        end if;
        if g_debug then
          hr_utility.set_location ('Track INelig flag'||l_trk_inelig_per_flag,100);
          hr_utility.set_location ('age val '||p_comp_rec.age_val,101);
        end if;
        -- Bug 8542643: Update the still inelig records irrespective of whether
	-- old value is greater or new value is greater for age or los
        if l_trk_inelig_per_flag = 'Y' then
          if  p_comp_rec.age_val is not null or
	      p_comp_rec.los_val is not null
	    then
	    if g_debug then
              hr_utility.set_location ('New update for elig per opt',100);
            end if;
	    --
       	    l_t_object_version_number := l_object_version_number_opt;
	    --
	    -- Start of changes against bug 6601884

		-- Get the datetrack update mode. If the record already exists and the effective date is
		-- same as start date, then update should be done in correction mode. In that case, the old
		-- record should be inserted in the backup table

		dt_api.find_dt_upd_modes
		  (p_effective_date       => l_effective_dt,
		   p_base_table_name      => 'BEN_ELIG_PER_OPT_F',
		   p_base_key_column      => 'elig_per_opt_id',
		   p_base_key_value       => l_elig_per_opt_id,
		   p_correction           => l_correction,
		   p_update               => l_update,
		   p_update_override      => l_update_override,
		   p_update_change_insert => l_update_change_insert);
		--
		if l_update_override then
		  l_datetrack_mode := hr_api.g_update_override;

		  if g_debug then
		    hr_utility.set_location('EPO l_datetrack_mode '||l_datetrack_mode, 777);
		  end if;

		elsif l_update then
		  l_datetrack_mode := hr_api.g_update;

		  if g_debug then
		    hr_utility.set_location('EPO l_datetrack_mode '||l_datetrack_mode, 777);
		  end if;
		else
		  l_datetrack_mode := hr_api.g_correction;

		  if g_debug then
		    hr_utility.set_location('EPO l_datetrack_mode '||l_datetrack_mode, 777);
		  end if;
		end if;

		hr_utility.set_location('EPO l_per_in_ler_id' || l_per_in_ler_id, 777);

		-- insert into backup table if updating in correction mode

		IF l_datetrack_mode = hr_api.g_correction AND
		   l_per_in_ler_id <> NVL(l_prev_per_in_ler_id,-1) THEN
		  --
		  ben_determine_eligibility3.save_to_restore
		   (p_current_per_in_ler_id  => l_per_in_ler_id
		   ,p_per_in_ler_id          => l_prev_per_in_ler_id
		   ,p_elig_per_id            => NULL
		   ,p_elig_per_opt_id        => l_elig_per_opt_id
		   ,p_effective_date         => l_effective_dt
		   );
		  --
		END IF;
           ben_Eligible_Person_perf_api.update_perf_Elig_Person_Option
            (p_validate                     => FALSE,
             p_elig_per_opt_id              => l_elig_per_opt_id,
             p_elig_per_id                  => l_elig_per_id,
             p_effective_start_date         => l_effective_start_date,
             p_effective_end_date           => l_effective_end_date,
             p_per_in_ler_id                => l_per_in_ler_id,
             p_elig_flag                    => 'N',
             p_prtn_strt_dt                 => l_prtn_strt_dt,
             p_prtn_end_dt                  => null,
             p_rt_comp_ref_amt              => p_comp_rec.rt_comp_ref_amt,
             p_rt_cmbn_age_n_los_val        => p_comp_rec.rt_cmbn_age_n_los_val,
             p_rt_comp_ref_uom              => p_comp_rec.rt_comp_ref_uom,
             p_rt_age_val                   => p_comp_rec.rt_age_val,
             p_rt_los_val                   => p_comp_rec.rt_los_val,
             p_rt_hrs_wkd_val               => p_comp_rec.rt_hrs_wkd_val,
             p_rt_hrs_wkd_bndry_perd_cd     => p_comp_rec.rt_hrs_wkd_bndry_perd_cd,
             p_rt_age_uom                   => p_comp_rec.rt_age_uom,
             p_rt_los_uom                   => p_comp_rec.rt_los_uom,
             p_rt_pct_fl_tm_val             => p_comp_rec.rt_pct_fl_tm_val,
             p_rt_frz_los_flag              => 'N',
             p_rt_frz_age_flag              => 'N',
             p_rt_frz_cmp_lvl_flag          => 'N',
             p_rt_frz_pct_fl_tm_flag        => 'N',
             p_rt_frz_hrs_wkd_flag          => 'N',
             p_rt_frz_comb_age_and_los_flag => 'N',
             p_once_r_cntug_cd              => p_comp_rec.once_r_cntug_cd,
             p_comp_ref_amt                 => p_comp_rec.comp_ref_amt,
             p_cmbn_age_n_los_val           => p_comp_rec.cmbn_age_n_los_val,
             p_comp_ref_uom                 => p_comp_rec.comp_ref_uom,
             p_age_val                      => p_comp_rec.age_val,
             p_los_val                      => p_comp_rec.los_val,
             p_hrs_wkd_val                  => p_comp_rec.hrs_wkd_val,
             p_hrs_wkd_bndry_perd_cd        => p_comp_rec.hrs_wkd_bndry_perd_cd,
             p_age_uom                      => p_comp_rec.age_uom,
             p_los_uom                      => p_comp_rec.los_uom,
             p_pct_fl_tm_val                => p_comp_rec.pct_fl_tm_val,
             p_frz_los_flag                 => 'N',
             p_frz_age_flag                 => 'N',
             p_frz_cmp_lvl_flag             => 'N',
             p_frz_pct_fl_tm_flag           => 'N',
             p_frz_hrs_wkd_flag             => 'N',
             p_frz_comb_age_and_los_flag    => 'N',
             p_wait_perd_strt_dt            => l_wait_perd_strt_dt,
             p_wait_perd_cmpltn_date        => l_wait_perd_cmpltn_dt,
             p_effective_date               => l_effective_dt,
             p_object_version_number        => l_object_version_number_opt,
             p_datetrack_mode               => l_datetrack_mode,
             p_program_application_id       => fnd_global.prog_appl_id,
             p_program_id                   => fnd_global.conc_program_id,
             p_request_id                   => fnd_global.conc_request_id,
             p_program_update_date          => sysdate);
             --

  	   if p_score_tab.count > 0 then
	      hr_utility.set_location('writing score records ',5.6);
              ben_elig_scre_wtg_api.load_score_weight
			(p_validate              => false
			,p_score_tab             => p_score_tab
			,p_effective_date        => l_effective_dt
			,p_per_in_ler_id         => l_per_in_ler_id    /* Bug 4438430 */
			,p_elig_per_id           => l_elig_per_id
			,p_elig_per_opt_id       => l_elig_per_opt_id);
	   end if;

                -- End of changes against bug 6601884
           end if;
-- ICM
IF nvl(l_env_rec.mode_cd,'~') = 'D' THEN
--
IF NOT ben_icm_life_events.g_cache_epo_object.EXISTS(1) THEN
      --
      l_count_icm1  := 1;
    --
    ELSE
      --
      l_count_icm1  := ben_icm_life_events.g_cache_epo_object.LAST + 1;
    --
    END IF;
   --
hr_utility.set_location('Building epo cache1 1'|| l_count_icm1,123);
--
ben_icm_life_events.g_cache_epo_object(l_count_icm1).elig_per_id := l_elig_per_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).elig_per_opt_id := l_elig_per_opt_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).effective_start_date :=l_effective_start_date;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).effective_end_date :=l_effective_end_date;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).business_group_id := p_business_group_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).per_in_ler_id :=l_per_in_ler_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).prtn_strt_dt := l_prtn_strt_dt;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).opt_id := l_oipl_rec.opt_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).prtn_end_dt := null;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).wait_perd_strt_dt := l_wait_perd_strt_dt;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).elig_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).comp_ref_amt := p_comp_rec.comp_ref_amt;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).cmbn_age_n_los_val := p_comp_rec.cmbn_age_n_los_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).comp_ref_uom := p_comp_rec.comp_ref_uom;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).age_val := p_comp_rec.age_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).age_uom := p_comp_rec.age_uom;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).los_val := p_comp_rec.los_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).los_uom := p_comp_rec.los_uom;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).hrs_wkd_val := p_comp_rec.hrs_wkd_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).wait_perd_cmpltn_date := l_wait_perd_cmpltn_dt;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).hrs_wkd_bndry_perd_cd := p_comp_rec.hrs_wkd_bndry_perd_cd;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).pct_fl_tm_val := p_comp_rec.pct_fl_tm_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).frz_los_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).frz_age_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).frz_cmp_lvl_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).frz_pct_fl_tm_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).frz_hrs_wkd_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).frz_comb_age_and_los_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_comp_ref_amt := p_comp_rec.rt_comp_ref_amt;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_cmbn_age_n_los_val := p_comp_rec.rt_cmbn_age_n_los_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_comp_ref_uom := p_comp_rec.rt_comp_ref_uom;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_age_val := p_comp_rec.rt_age_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_age_uom := p_comp_rec.rt_age_uom;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_los_val := p_comp_rec.rt_los_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_los_uom := p_comp_rec.rt_los_uom;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_hrs_wkd_val := p_comp_rec.rt_hrs_wkd_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_hrs_wkd_bndry_perd_cd := p_comp_rec.rt_hrs_wkd_bndry_perd_cd;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_pct_fl_tm_val := p_comp_rec.rt_pct_fl_tm_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_frz_los_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_frz_age_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_frz_cmp_lvl_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_frz_pct_fl_tm_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_frz_hrs_wkd_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_frz_comb_age_and_los_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).once_r_cntug_cd := p_comp_rec.once_r_cntug_cd;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).object_version_number := l_t_object_version_number;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).program_application_id :=fnd_global.prog_appl_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).program_id :=fnd_global.conc_program_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).request_id :=fnd_global.conc_request_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).program_update_date :=sysdate;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).p_datetrack_mode:= 'UPDATE';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).p_effective_date:= l_t_effective_dt;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).p_newly_elig :=  l_newly_elig;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).p_newly_inelig:= l_newly_inelig;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).p_first_elig :=  l_first_elig;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).p_first_inelig := l_first_inelig;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).p_still_elig :=  l_still_elig;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).p_still_inelig:= l_still_inelig;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).p_pl_id := l_envpl_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).prtn_ovridn_flag := 'N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).no_mx_prtn_ovrid_thru_flag := 'N';
--
END IF;
end if;
--ICM
        --
        return;
        --
      elsif l_opt_elig_flag = 'N' and p_elig_flag then  --d
        -- person is newly elig
	hr_utility.set_location('new elig',23);
        l_newly_elig := true;
        l_start_or_end := 'S';
        fnd_message.set_name('BEN','BEN_91346_ELIG_PREV_NOT_ELIG');
        benutils.write(p_text => fnd_message.get);
        --
      else
        fnd_message.set_name('BEN','BEN_91006_INVALID_FLAG');
        fnd_message.set_token('FLAG','epo.elig_flag');
        fnd_message.set_token('PROC','ben_determine_eligibility2.check_prev_elig');
        raise ben_manage_life_events.g_record_error;
        --
      end if; --d
      --
    end if; --b
    --
    if g_debug then
      hr_utility.set_location('Call GSED 1 ben_determine_eligibility2.check_prev_elig', 10);
    end if;
    --
    get_start_end_dates
      (p_comp_obj_tree_row    => p_comp_obj_tree_row
      ,p_pil_row              => l_pil_rec
      ,p_effective_date       => nvl(p_lf_evt_ocrd_dt,p_effective_date)
      ,p_business_group_id    => p_business_group_id
      ,p_person_id            => p_person_id
      ,p_pl_id                => p_pl_id
      ,p_pgm_id               => p_pgm_id
      ,p_oipl_id              => p_oipl_id
      ,p_plip_id              => p_plip_id
      ,p_ptip_id              => p_ptip_id
      ,p_prev_prtn_strt_dt    => l_prev_prtn_strt_dt
      ,p_prev_prtn_end_dt     => l_prev_prtn_end_dt
      ,p_start_or_end         => l_start_or_end
      ,p_prtn_eff_strt_dt     => l_prtn_eff_strt_dt
      ,p_prtn_eff_strt_dt_cd  => l_prtn_eff_strt_dt_cd
      ,p_prtn_eff_strt_dt_rl  => l_prtn_eff_strt_dt_rl
      ,p_prtn_eff_end_dt      => l_prtn_eff_end_dt
      );
    --
    if g_debug then
      --
      hr_utility.set_location('Done GSED 1 ben_determine_eligibility2.check_prev_elig', 10);
      hr_utility.set_location('    l_prtn_eff_strt_dt : ' ||l_prtn_eff_strt_dt, 10);
      hr_utility.set_location('    l_prtn_eff_end_dt : ' ||l_prtn_eff_end_dt, 10);
      --
    end if;
    -- compute end date plus one.
    if to_char(l_prtn_eff_end_dt,'DD-MM-RRRR') = '31-12-4712' then
      --
      l_end_dt_plus_one := l_prtn_eff_end_dt;
      --
    else
      --
      l_end_dt_plus_one := l_prtn_eff_end_dt + 1;
      --
    end if;
    -- Now determine what records to write
    -- Find the elig_per record id that we need to join to.
    -- Have to do this for first timers because cursor for prev elig
    -- would not have brought back a record.
    --
    /* Bug 3327841 This info needs to be derived for the elig_per_opt
       records even in the subsequent life event also as the value
       we are getting from the ben_pep_cache is for the previous
       life event.
    */
    if l_first_elig or l_oipl_rec.opt_id is not null then
      --
      --Get elig id from ben_elig_per_f for the plan
      --
      if g_debug then
        hr_utility.set_location('open c_get_elig_id ben_determine_eligibility2.check_prev_elig', 10);
      end if;
      --
      ben_pep_cache1.get_currplnpep_dets
        (p_comp_obj_tree_row => p_comp_obj_tree_row
        ,p_person_id         => p_person_id
        ,p_effective_date    => l_effective_dt
        --
        ,p_inst_row	     => l_plnpep_dets
        );
      --
      if l_plnpep_dets.elig_per_id is null
      then
        --
        fnd_message.set_name('BEN','BEN_91394_ELIG_NOT_FOUND');
        raise ben_manage_life_events.g_record_error;
        --
      else
        --
        l_elig_per_id           := l_plnpep_dets.elig_per_id;
        l_elig_per_prtn_strt_dt := l_plnpep_dets.prtn_strt_dt;
        l_elig_per_prtn_end_dt  := l_plnpep_dets.prtn_end_dt;
        --
      end if;
      --
      if g_debug then
        hr_utility.set_location('close c_get_elig_id ben_determine_eligibility2.check_prev_elig', 10);
      end if;
      --
      -- Get opt id from cached oipl structure
      --
      l_opt_id := l_oipl_rec.opt_id;
      --
    end if;
    --
    -- In case its a new oiplip get plip row
    --
    if l_prtn_eff_strt_dt < l_elig_per_prtn_strt_dt then --j
      --
      -- prtn strt dt for oipl cannot come before prtn
      -- strt dt for plan
      l_prtn_eff_strt_dt := l_elig_per_prtn_strt_dt;
      --
    end if;--j
    --
    if l_prtn_eff_end_dt > l_elig_per_prtn_end_dt then--k
      -- prtn end dt for oipl cannot come after prtn
      -- end date for plan
      l_prtn_eff_end_dt := l_elig_per_prtn_end_dt;
    end if;--k
    --
    -- compute end date plus one.
    if to_char(l_prtn_eff_end_dt,'DD-MM-RRRR') = '31-12-4712' then
      --
      l_end_dt_plus_one := l_prtn_eff_end_dt;
      --
    else
      --
      l_end_dt_plus_one := l_prtn_eff_end_dt + 1;
      --
    end if;
    --
    if l_first_elig then    --n
	hr_utility.set_location ('first elig',121);
      -- Create Elig Person for Option
      if instr(ben_manage_life_events.g_output_string,
               'Elg:') = 0 then
        --
        ben_manage_life_events.g_output_string :=
          ben_manage_life_events.g_output_string||
          'Elg: Yes '||
          'Rsn: First Time Elig';
        --
      end if;
      -- If a waiting period applies, get the date when participation will begin
      -- after the waiting period ends.
      if l_wait_perd_cmpltn_dt is not null and l_benmngle_parm_rec.mode_cd <> 'D' then
        -- Apply the participation start date code to the l_wait_perd_cmpltn_dt
        l_prtn_st_dt_aftr_wtg :=
          ben_determine_eligibility3.get_prtn_st_dt_aftr_wtg
            (p_person_id           => p_person_id
            ,p_effective_date      => p_effective_date
            ,p_business_group_id   => p_business_group_id
            ,p_prtn_eff_strt_dt_cd => l_prtn_eff_strt_dt_cd
            ,p_prtn_eff_strt_dt_rl => l_prtn_eff_strt_dt_rl
            ,p_wtg_perd_cmpltn_dt  => l_wait_perd_cmpltn_dt
            ,p_pl_id               => p_pl_id
            ,p_pl_typ_id           => l_pl_rec.pl_typ_id
            ,p_pgm_id              => p_pgm_id
            ,p_oipl_id             => p_oipl_id
            ,p_plip_id             => p_plip_id
            ,p_ptip_id             => p_ptip_id
            ,p_opt_id              => l_oipl_rec.opt_id
            );
        --
        -- Use the later of the l_after_wtg_prtn_dt and l_prtn_eff_strt_dt
        -- for the participation start date.
        l_prtn_eff_strt_dt := greatest(nvl(l_prtn_st_dt_aftr_wtg
                                          ,hr_api.g_sot),l_prtn_eff_strt_dt);
        --
      end if;
      --
      if g_debug then
        hr_utility.set_location('Using prtn_eff_strt_dt : ' ||
                               l_prtn_eff_strt_dt, 10);
        hr_utility.set_location('FIR ELIG Cre EPO ben_determine_eligibility2.check_prev_elig', 10);
      end if;
      --
      l_elig_flag    := 'Y';
      l_prtn_strt_dt := l_prtn_eff_strt_dt;
      --
      ben_Eligible_Person_perf_api.create_perf_Elig_Person_Option
        (p_validate                     => FALSE,
         p_elig_per_opt_id              => l_elig_per_opt_id,
         p_elig_per_id                  => l_elig_per_id,
         p_per_in_ler_id                => l_per_in_ler_id,
         p_prtn_ovridn_flag             => 'N',
         p_prtn_ovridn_thru_dt          => null,
         p_no_mx_prtn_ovrid_thru_flag   => 'N',
         p_elig_flag                    => l_elig_flag,
         p_prtn_strt_dt                 => l_prtn_strt_dt,
         p_opt_id                       => l_opt_id,
         p_rt_comp_ref_amt              => p_comp_rec.rt_comp_ref_amt,
         p_rt_cmbn_age_n_los_val        => p_comp_rec.rt_cmbn_age_n_los_val,
         p_rt_comp_ref_uom              => p_comp_rec.rt_comp_ref_uom,
         p_rt_age_val                   => p_comp_rec.rt_age_val,
         p_rt_los_val                   => p_comp_rec.rt_los_val,
         p_rt_hrs_wkd_val               => p_comp_rec.rt_hrs_wkd_val,
         p_rt_hrs_wkd_bndry_perd_cd     => p_comp_rec.rt_hrs_wkd_bndry_perd_cd,
         p_rt_age_uom                   => p_comp_rec.rt_age_uom,
         p_rt_los_uom                   => p_comp_rec.rt_los_uom,
         p_rt_pct_fl_tm_val             => p_comp_rec.rt_pct_fl_tm_val,
         p_rt_frz_los_flag              => 'N',
         p_rt_frz_age_flag              => 'N',
         p_rt_frz_cmp_lvl_flag          => 'N',
         p_rt_frz_pct_fl_tm_flag        => 'N',
         p_rt_frz_hrs_wkd_flag          => 'N',
         p_rt_frz_comb_age_and_los_flag => 'N',
         p_once_r_cntug_cd              => p_comp_rec.once_r_cntug_cd,
         p_comp_ref_amt                 => p_comp_rec.comp_ref_amt,
         p_cmbn_age_n_los_val           => p_comp_rec.cmbn_age_n_los_val,
         p_comp_ref_uom                 => p_comp_rec.comp_ref_uom,
         p_age_val                      => p_comp_rec.age_val,
         p_los_val                      => p_comp_rec.los_val,
         p_hrs_wkd_val                  => p_comp_rec.hrs_wkd_val,
         p_hrs_wkd_bndry_perd_cd        => p_comp_rec.hrs_wkd_bndry_perd_cd,
         p_age_uom                      => p_comp_rec.age_uom,
         p_los_uom                      => p_comp_rec.los_uom,
         p_pct_fl_tm_val                => p_comp_rec.pct_fl_tm_val,
         p_frz_los_flag                 => 'N',
         p_frz_age_flag                 => 'N',
         p_frz_cmp_lvl_flag             => 'N',
         p_frz_pct_fl_tm_flag           => 'N',
         p_frz_hrs_wkd_flag             => 'N',
         p_frz_comb_age_and_los_flag    => 'N',
         -- p_wait_perd_cmpltn_dt          => l_wait_perd_cmpltn_dt,
         p_wait_perd_cmpltn_date        => l_wait_perd_cmpltn_dt,
         p_wait_perd_strt_dt            => l_wait_perd_strt_dt,
         p_effective_start_date         => l_effective_start_date,
         p_effective_end_date           => l_effective_end_date,
         p_object_version_number        => l_object_version_number_opt,
         p_oipl_ordr_num                => l_oipl_rec.ordr_num,
         p_business_group_id            => p_business_group_id,
         p_program_application_id       => fnd_global.prog_appl_id,
         p_program_id                   => fnd_global.conc_program_id,
         p_request_id                   => fnd_global.conc_request_id,
         p_program_update_date          => sysdate,
         --
         -- Bugs : 1412882, part of bug 1412951
         --
         p_effective_date               => l_effective_dt,
         -- p_effective_date               => p_effective_date
         --
         -- Bypass insert validate validation for performance
         --
         p_override_validation          => TRUE
        );
  -- ICM
IF nvl(l_env_rec.mode_cd,'~') = 'D' THEN
  --
   IF NOT ben_icm_life_events.g_cache_epo_object.EXISTS(1) THEN
      --
      l_count_icm1  := 1;
    --
    ELSE
      --
      l_count_icm1  := ben_icm_life_events.g_cache_epo_object.LAST + 1;
    --
    END IF;
   --
hr_utility.set_location('Building epo cache1 2 : count '  || l_count_icm1,123);
--
ben_icm_life_events.g_cache_epo_object(l_count_icm1).elig_per_id := l_elig_per_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).elig_per_opt_id := l_elig_per_opt_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).effective_start_date :=l_effective_start_date;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).effective_end_date :=l_effective_end_date;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).prtn_ovridn_flag := 'N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).no_mx_prtn_ovrid_thru_flag := 'N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).business_group_id := p_business_group_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).per_in_ler_id :=l_per_in_ler_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).prtn_strt_dt := l_prtn_strt_dt;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).prtn_ovridn_thru_dt := null;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).opt_id := l_opt_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).wait_perd_strt_dt := l_wait_perd_strt_dt;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).elig_flag := l_elig_flag;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).comp_ref_amt := p_comp_rec.comp_ref_amt;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).cmbn_age_n_los_val := p_comp_rec.cmbn_age_n_los_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).comp_ref_uom := p_comp_rec.comp_ref_uom;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).age_val := p_comp_rec.age_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).age_uom := p_comp_rec.age_uom;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).los_val := p_comp_rec.los_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).los_uom := p_comp_rec.los_uom;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).hrs_wkd_val := p_comp_rec.hrs_wkd_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).wait_perd_cmpltn_date := l_wait_perd_cmpltn_dt;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).hrs_wkd_bndry_perd_cd := p_comp_rec.hrs_wkd_bndry_perd_cd;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).pct_fl_tm_val := p_comp_rec.pct_fl_tm_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).frz_los_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).frz_age_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).frz_cmp_lvl_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).frz_pct_fl_tm_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).frz_hrs_wkd_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).frz_comb_age_and_los_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_comp_ref_amt := p_comp_rec.rt_comp_ref_amt;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_cmbn_age_n_los_val := p_comp_rec.rt_cmbn_age_n_los_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_comp_ref_uom := p_comp_rec.rt_comp_ref_uom;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_age_val := p_comp_rec.rt_age_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_age_uom := p_comp_rec.rt_age_uom;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_los_val := p_comp_rec.rt_los_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_los_uom := p_comp_rec.rt_los_uom;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_hrs_wkd_val := p_comp_rec.rt_hrs_wkd_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_hrs_wkd_bndry_perd_cd := p_comp_rec.rt_hrs_wkd_bndry_perd_cd;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_pct_fl_tm_val := p_comp_rec.rt_pct_fl_tm_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_frz_los_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_frz_age_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_frz_cmp_lvl_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_frz_pct_fl_tm_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_frz_hrs_wkd_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_frz_comb_age_and_los_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).oipl_ordr_num := l_oipl_rec.ordr_num;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).once_r_cntug_cd := p_comp_rec.once_r_cntug_cd;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).object_version_number := l_object_version_number_opt;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).program_application_id :=fnd_global.prog_appl_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).program_id :=fnd_global.conc_program_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).request_id :=fnd_global.conc_request_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).program_update_date :=sysdate;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).p_effective_date:= l_effective_dt;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).p_newly_elig :=  l_newly_elig;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).p_newly_inelig:= l_newly_inelig;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).p_first_elig :=  l_first_elig;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).p_first_inelig := l_first_inelig;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).p_still_elig :=  l_still_elig;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).p_still_inelig:= l_still_inelig;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).p_pl_id := l_envpl_id;
--
END IF;
--ICM
      --
      if p_score_tab.count > 0 then
         hr_utility.set_location('writing score records ',5.5);
         ben_elig_scre_wtg_api.load_score_weight
         (p_validate              => false
         ,p_score_tab             => p_score_tab
         ,p_effective_date        => l_effective_dt
         ,p_per_in_ler_id         => l_per_in_ler_id    /* Bug 4438430 */
         ,p_elig_per_id           => l_elig_per_id
         ,p_elig_per_opt_id       => l_elig_per_opt_id);
      end if;
      hr_utility.set_location('Dn FIR ELIG Cre EPO ben_determine_eligibility2.check_prev_elig', 10);
      --
    elsif l_still_elig then        --n
      --
	hr_utility.set_location ('still elig',121);
      if instr(ben_manage_life_events.g_output_string,
               'Elg:') = 0 then
        --
        ben_manage_life_events.g_output_string :=
          ben_manage_life_events.g_output_string||
          'Elg: Yes '||
          'Rsn: Prev elig';
        --
      end if;
      --
      -- if the previous row's start date is greater than or equal the computed
      -- start date, then they never really became ineligible.  Go find
      -- another start elig date to use.
      --
      dt_api.find_dt_upd_modes
        (-- p_effective_date       => p_effective_date,
         --
         -- Bugs : 1412882, part of bug 1412951
         --
         p_effective_date               => l_effective_dt,
         --
         p_base_table_name      => 'BEN_ELIG_PER_OPT_F',
         p_base_key_column      => 'elig_per_opt_id',
         p_base_key_value       => l_elig_per_opt_id,
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
      -- If a waiting period applies, get the date when participation will begin
      -- after the waiting period ends.
      --
      if l_wait_perd_cmpltn_dt is not null and l_benmngle_parm_rec.mode_cd <> 'D' then
        --
        -- Apply the participation start date code to the l_wait_perd_cmpltn_dt
        --
        l_prtn_st_dt_aftr_wtg :=
          ben_determine_eligibility3.get_prtn_st_dt_aftr_wtg
            (p_person_id           => p_person_id,
             p_effective_date      => p_effective_date,
             p_business_group_id   => p_business_group_id,
             p_prtn_eff_strt_dt_cd => l_prtn_eff_strt_dt_cd,
             p_prtn_eff_strt_dt_rl => l_prtn_eff_strt_dt_rl,
             p_wtg_perd_cmpltn_dt  => l_wait_perd_cmpltn_dt,
             p_pl_id               => p_pl_id,
             p_pl_typ_id           => l_pl_rec.pl_typ_id,
             p_pgm_id              => p_pgm_id,
             p_oipl_id             => p_oipl_id,
             p_plip_id             => p_plip_id,
             p_ptip_id             => p_ptip_id,
             p_opt_id              => l_oipl_rec.opt_id);
        --
        -- Use the later of the l_after_wtg_prtn_dt and l_prtn_eff_strt_dt
        -- for the participation start date.
        --
        l_prtn_eff_strt_dt :=
          greatest(nvl(l_prtn_st_dt_aftr_wtg,hr_api.g_sot),l_prtn_eff_strt_dt);
        --
      end if;
      --
      l_elig_flag := 'Y';
      l_prtn_strt_dt := l_prtn_eff_strt_dt;
      --
       hr_utility.set_location('SARKAR EPO l_per_in_ler_id' || l_per_in_ler_id, 10);
      IF l_datetrack_mode = hr_api.g_correction AND
         l_per_in_ler_id <> NVL(l_prev_per_in_ler_id,-1) AND l_benmngle_parm_rec.mode_cd <> 'D' THEN
        --
        ben_determine_eligibility3.save_to_restore
        (p_current_per_in_ler_id   => l_per_in_ler_id
        ,p_per_in_ler_id          => l_prev_per_in_ler_id
        ,p_elig_per_id            => NULL
        ,p_elig_per_opt_id        => l_elig_per_opt_id
        ,p_effective_date         => l_effective_dt
        );
        --
      END IF;
      --
      l_t_object_version_number := l_object_version_number_opt;
      --
      ben_Eligible_Person_perf_api.update_perf_Elig_Person_Option
        (p_validate                     => FALSE,
         p_elig_per_opt_id              => l_elig_per_opt_id,
         p_elig_per_id                  => l_elig_per_id,
         p_effective_start_date         => l_effective_start_date,
         p_effective_end_date           => l_effective_end_date,
         p_per_in_ler_id                => l_per_in_ler_id,
         p_elig_flag                    => l_elig_flag,
         p_prtn_strt_dt                 => l_prtn_strt_dt,
         p_prtn_end_dt                  => null,
         p_rt_comp_ref_amt              => p_comp_rec.rt_comp_ref_amt,
         p_rt_cmbn_age_n_los_val        => p_comp_rec.rt_cmbn_age_n_los_val,
         p_rt_comp_ref_uom              => p_comp_rec.rt_comp_ref_uom,
         p_rt_age_val                   => p_comp_rec.rt_age_val,
         p_rt_los_val                   => p_comp_rec.rt_los_val,
         p_rt_hrs_wkd_val               => p_comp_rec.rt_hrs_wkd_val,
         p_rt_hrs_wkd_bndry_perd_cd     => p_comp_rec.rt_hrs_wkd_bndry_perd_cd,
         p_rt_age_uom                   => p_comp_rec.rt_age_uom,
         p_rt_los_uom                   => p_comp_rec.rt_los_uom,
         p_rt_pct_fl_tm_val             => p_comp_rec.rt_pct_fl_tm_val,
         p_rt_frz_los_flag              => 'N',
         p_rt_frz_age_flag              => 'N',
         p_rt_frz_cmp_lvl_flag          => 'N',
         p_rt_frz_pct_fl_tm_flag        => 'N',
         p_rt_frz_hrs_wkd_flag          => 'N',
         p_rt_frz_comb_age_and_los_flag => 'N',
         p_once_r_cntug_cd              => p_comp_rec.once_r_cntug_cd,
         p_comp_ref_amt                 => p_comp_rec.comp_ref_amt,
         p_cmbn_age_n_los_val           => p_comp_rec.cmbn_age_n_los_val,
         p_comp_ref_uom                 => p_comp_rec.comp_ref_uom,
         p_age_val                      => p_comp_rec.age_val,
         p_los_val                      => p_comp_rec.los_val,
         p_hrs_wkd_val                  => p_comp_rec.hrs_wkd_val,
         p_hrs_wkd_bndry_perd_cd        => p_comp_rec.hrs_wkd_bndry_perd_cd,
         p_age_uom                      => p_comp_rec.age_uom,
         p_los_uom                      => p_comp_rec.los_uom,
         p_pct_fl_tm_val                => p_comp_rec.pct_fl_tm_val,
         p_frz_los_flag                 => 'N',
         p_frz_age_flag                 => 'N',
         p_frz_cmp_lvl_flag             => 'N',
         p_frz_pct_fl_tm_flag           => 'N',
         p_frz_hrs_wkd_flag             => 'N',
         p_frz_comb_age_and_los_flag    => 'N',
         -- p_wait_perd_cmpltn_dt          => l_wait_perd_cmpltn_dt,
         p_wait_perd_strt_dt            => l_wait_perd_strt_dt,
         p_wait_perd_cmpltn_date        => l_wait_perd_cmpltn_dt,
         --
         -- Bugs : 1412882, part of bug 1412951
         --
         p_effective_date               => l_effective_dt,
         -- p_effective_date               => p_effective_date,
         p_object_version_number        => l_object_version_number_opt,
         p_datetrack_mode               => l_datetrack_mode,
         p_program_application_id       => fnd_global.prog_appl_id,
         p_program_id                   => fnd_global.conc_program_id,
         p_request_id                   => fnd_global.conc_request_id,
         p_program_update_date          => sysdate);
      --
IF nvl(l_env_rec.mode_cd,'~') = 'D' THEN
--
 IF NOT ben_icm_life_events.g_cache_epo_object.EXISTS(1) THEN
      --
      l_count_icm1  := 1;
    --
    ELSE
      --
      l_count_icm1  := ben_icm_life_events.g_cache_epo_object.LAST + 1;
    --
 END IF;
   --
   hr_utility.set_location('Building epo cache1 3 : count ',123);
--ICM
ben_icm_life_events.g_cache_epo_object(l_count_icm1).elig_per_id := l_elig_per_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).elig_per_opt_id := l_elig_per_opt_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).effective_start_date :=l_effective_start_date;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).effective_end_date :=l_effective_end_date;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).business_group_id := p_business_group_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).per_in_ler_id :=l_per_in_ler_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).prtn_strt_dt := l_prtn_strt_dt;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).prtn_end_dt := null;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).wait_perd_strt_dt := l_wait_perd_strt_dt;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).elig_flag := l_elig_flag;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).comp_ref_amt := p_comp_rec.comp_ref_amt;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).cmbn_age_n_los_val := p_comp_rec.cmbn_age_n_los_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).comp_ref_uom := p_comp_rec.comp_ref_uom;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).age_val := p_comp_rec.age_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).age_uom := p_comp_rec.age_uom;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).los_val := p_comp_rec.los_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).los_uom := p_comp_rec.los_uom;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).hrs_wkd_val := p_comp_rec.hrs_wkd_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).wait_perd_cmpltn_date := l_wait_perd_cmpltn_dt;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).hrs_wkd_bndry_perd_cd := p_comp_rec.hrs_wkd_bndry_perd_cd;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).pct_fl_tm_val := p_comp_rec.pct_fl_tm_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).frz_los_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).frz_age_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).frz_cmp_lvl_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).frz_pct_fl_tm_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).frz_hrs_wkd_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).frz_comb_age_and_los_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_comp_ref_amt := p_comp_rec.rt_comp_ref_amt;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_cmbn_age_n_los_val := p_comp_rec.rt_cmbn_age_n_los_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_comp_ref_uom := p_comp_rec.rt_comp_ref_uom;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_age_val := p_comp_rec.rt_age_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_age_uom := p_comp_rec.rt_age_uom;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_los_val := p_comp_rec.rt_los_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_los_uom := p_comp_rec.rt_los_uom;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_hrs_wkd_val := p_comp_rec.rt_hrs_wkd_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_hrs_wkd_bndry_perd_cd := p_comp_rec.rt_hrs_wkd_bndry_perd_cd;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_pct_fl_tm_val := p_comp_rec.rt_pct_fl_tm_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_frz_los_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_frz_age_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_frz_cmp_lvl_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_frz_pct_fl_tm_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_frz_hrs_wkd_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_frz_comb_age_and_los_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).once_r_cntug_cd := p_comp_rec.once_r_cntug_cd;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).object_version_number := l_t_object_version_number;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).program_application_id :=fnd_global.prog_appl_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).program_id :=fnd_global.conc_program_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).request_id :=fnd_global.conc_request_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).program_update_date :=sysdate;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).p_datetrack_mode:= l_datetrack_mode;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).p_effective_date:= l_effective_dt;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).p_newly_elig :=  l_newly_elig;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).p_newly_inelig:= l_newly_inelig;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).p_first_elig :=  l_first_elig;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).p_first_inelig := l_first_inelig;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).p_still_elig :=  l_still_elig;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).p_still_inelig:= l_still_inelig;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).p_pl_id := l_envpl_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).prtn_ovridn_flag := 'N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).no_mx_prtn_ovrid_thru_flag := 'N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).opt_id := l_oipl_rec.opt_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).wait_perd_cmpltn_dt :=l_wait_perd_cmpltn_dt;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).prtn_ovridn_thru_dt := null;
--
END IF;
--ICM
      if p_score_tab.count > 0 then
         hr_utility.set_location('writing score records ',5.6);
         ben_elig_scre_wtg_api.load_score_weight
         (p_validate              => false
         ,p_score_tab             => p_score_tab
         ,p_effective_date        => l_effective_dt
         ,p_per_in_ler_id         => l_per_in_ler_id    /* Bug 4438430 */
         ,p_elig_per_id           => l_elig_per_id
         ,p_elig_per_opt_id       => l_elig_per_opt_id);
      end if;
    elsif l_newly_elig then        --n
      --
      	hr_utility.set_location('new elig',23);
      if instr(ben_manage_life_events.g_output_string,
               'Elg:') = 0 then
        --
        ben_manage_life_events.g_output_string :=
          ben_manage_life_events.g_output_string||
          'Elg: Yes '||
          'Rsn: Prev Inelig';
        --
      end if;
      --
      l_t_object_version_number := l_object_version_number_opt;
      --
      -- if the previous row's start date is greater than or equal the computed
      -- start date, then they never really became ineligible.  Go find
      -- another start elig date to use.
      --
      if l_prev_prtn_strt_dt >= l_prtn_eff_strt_dt then                    --p
        --
        -- Check for an existing eligible record where our computed start
        -- date falls between existing records start and end dates.
        -- If there is one, then the person never really lost eligiblity
        -- and we need to use the old start date.
        --
        open c_opt_overlap (c_prtn_eff_strt_dt => l_prtn_eff_strt_dt
                           ,c_elig_flag        => 'Y'
                           ,c_add_one          => 1);
          --
          fetch c_opt_overlap into l_opt_overlap;
          --
        close c_opt_overlap;
        --
        if l_opt_overlap.prtn_strt_dt is not null then
          --
          l_prtn_eff_strt_dt := l_opt_overlap.prtn_strt_dt;
          --
        end if;
        --
      else
        --
        -- Call API to Update old inelig record with end date of computed
        -- start date - 1 (correction) unless the old inelig record has a
        -- start date greater than our computed start date.
        --
        if l_prev_prtn_strt_dt < l_prtn_eff_strt_dt then
          --
          ben_Eligible_Person_perf_api.update_perf_Elig_Person_Option
            (p_validate                     => FALSE,
             p_elig_per_opt_id              => l_elig_per_opt_id,
             p_elig_per_id                  => l_elig_per_id,
             --
             -- Bug 2284417 : Do not update the per in ler id with new
             -- per in ler id as this row peice of row should belong to
             -- previous per in ler. Next update will update the
             -- per in ler id as well as new prtn strt dt.
             --
             -- p_per_in_ler_id                => l_per_in_ler_id,
             p_effective_start_date         => l_effective_start_date,
             p_effective_end_date           => l_effective_end_date,
             p_prtn_end_dt                  => l_prtn_eff_strt_dt-1,
        --     p_effective_date               => p_effective_date,
             p_effective_date               => l_effective_dt,
             p_object_version_number        => l_object_version_number_opt,
             p_datetrack_mode               => hr_api.g_correction,
             p_program_application_id       => fnd_global.prog_appl_id,
             p_program_id                   => fnd_global.conc_program_id,
             p_request_id                   => fnd_global.conc_request_id,
             p_program_update_date          => sysdate);
          --
        --
        end if;
      end if;         --p
      --
      -- Then call in update mode to create a new elig record with
      -- computed start date.
      --
      dt_api.find_dt_upd_modes
        (-- p_effective_date       => p_effective_date,
         --
         -- Bugs : 1412882, part of bug 1412951
         --
         p_effective_date               => l_effective_dt,
         --
         p_base_table_name      => 'BEN_ELIG_PER_OPT_F',
         p_base_key_column      => 'elig_per_opt_id',
         p_base_key_value       => l_elig_per_opt_id,
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
      -- If a waiting period applies, get the date when participation will begin
      -- after the waiting period ends.
      --
      if l_wait_perd_cmpltn_dt is not null then
        --
        -- Apply the participation start date code to the l_wait_perd_cmpltn_dt
        --
        l_prtn_st_dt_aftr_wtg :=
          ben_determine_eligibility3.get_prtn_st_dt_aftr_wtg
            (p_person_id           => p_person_id,
             p_effective_date      => p_effective_date,
             p_business_group_id   => p_business_group_id,
             p_prtn_eff_strt_dt_cd => l_prtn_eff_strt_dt_cd,
             p_prtn_eff_strt_dt_rl => l_prtn_eff_strt_dt_rl,
             p_wtg_perd_cmpltn_dt  => l_wait_perd_cmpltn_dt,
             p_pl_id               => p_pl_id,
             p_pl_typ_id           => l_pl_rec.pl_typ_id,
             p_pgm_id              => p_pgm_id,
             p_oipl_id             => p_oipl_id,
             p_plip_id             => p_plip_id,
             p_ptip_id             => p_ptip_id,
             p_opt_id              => l_oipl_rec.opt_id);
        --
        -- Use the later of the l_after_wtg_prtn_dt and l_prtn_eff_strt_dt
        -- for the participation start date.
        --
        l_prtn_eff_strt_dt :=
          greatest(nvl(l_prtn_st_dt_aftr_wtg,hr_api.g_sot),l_prtn_eff_strt_dt);
        --
      end if;
      --
      l_elig_flag    := 'Y';
      l_prtn_strt_dt := l_prtn_eff_strt_dt;
      --
      --
      IF l_datetrack_mode = hr_api.g_correction AND
         l_per_in_ler_id <> NVL(l_prev_per_in_ler_id,-1) THEN
        --
        ben_determine_eligibility3.save_to_restore
        (p_current_per_in_ler_id   => l_per_in_ler_id
        ,p_per_in_ler_id          => l_prev_per_in_ler_id
        ,p_elig_per_id            => NULL
        ,p_elig_per_opt_id        => l_elig_per_opt_id
        ,p_effective_date         => l_effective_dt
        );
        --
      END IF;
      --
    ben_Eligible_Person_perf_api.update_perf_Elig_Person_Option
        (p_validate                     => FALSE,
         p_elig_per_opt_id              => l_elig_per_opt_id,
         p_elig_per_id                  => l_elig_per_id,
         p_effective_start_date         => l_effective_start_date,
         p_effective_end_date           => l_effective_end_date,
         p_per_in_ler_id                => l_per_in_ler_id,
         p_elig_flag                    => l_elig_flag,
         p_prtn_strt_dt                 => l_prtn_strt_dt,
         p_prtn_end_dt                  => null,
         p_rt_comp_ref_amt              => p_comp_rec.rt_comp_ref_amt,
         p_rt_cmbn_age_n_los_val        => p_comp_rec.rt_cmbn_age_n_los_val,
         p_rt_comp_ref_uom              => p_comp_rec.rt_comp_ref_uom,
         p_rt_age_val                   => p_comp_rec.rt_age_val,
         p_rt_los_val                   => p_comp_rec.rt_los_val,
         p_rt_hrs_wkd_val               => p_comp_rec.rt_hrs_wkd_val,
         p_rt_hrs_wkd_bndry_perd_cd     => p_comp_rec.rt_hrs_wkd_bndry_perd_cd,
         p_rt_age_uom                   => p_comp_rec.rt_age_uom,
         p_rt_los_uom                   => p_comp_rec.rt_los_uom,
         p_rt_pct_fl_tm_val             => p_comp_rec.rt_pct_fl_tm_val,
         p_rt_frz_los_flag              => 'N',
         p_rt_frz_age_flag              => 'N',
         p_rt_frz_cmp_lvl_flag          => 'N',
         p_rt_frz_pct_fl_tm_flag        => 'N',
         p_rt_frz_hrs_wkd_flag          => 'N',
         p_rt_frz_comb_age_and_los_flag => 'N',
         p_once_r_cntug_cd              => p_comp_rec.once_r_cntug_cd,
         p_comp_ref_amt                 => p_comp_rec.comp_ref_amt,
         p_cmbn_age_n_los_val           => p_comp_rec.cmbn_age_n_los_val,
         p_comp_ref_uom                 => p_comp_rec.comp_ref_uom,
         p_age_val                      => p_comp_rec.age_val,
         p_los_val                      => p_comp_rec.los_val,
         p_hrs_wkd_val                  => p_comp_rec.hrs_wkd_val,
         p_hrs_wkd_bndry_perd_cd        => p_comp_rec.hrs_wkd_bndry_perd_cd,
         p_age_uom                      => p_comp_rec.age_uom,
         p_los_uom                      => p_comp_rec.los_uom,
         p_pct_fl_tm_val                => p_comp_rec.pct_fl_tm_val,
         p_frz_los_flag                 => 'N',
         p_frz_age_flag                 => 'N',
         p_frz_cmp_lvl_flag             => 'N',
         p_frz_pct_fl_tm_flag           => 'N',
         p_frz_hrs_wkd_flag             => 'N',
         p_frz_comb_age_and_los_flag    => 'N',
         -- p_wait_perd_cmpltn_dt          => l_wait_perd_cmpltn_dt,
         p_wait_perd_cmpltn_date        => l_wait_perd_cmpltn_dt,
         p_wait_perd_strt_dt            => l_wait_perd_strt_dt,
         --
         -- Bugs : 1412882, part of bug 1412951
         --
         p_effective_date               => l_effective_dt,
         -- p_effective_date               => p_effective_date,
         p_object_version_number        => l_object_version_number_opt,
         p_datetrack_mode               => l_datetrack_mode,
         p_program_application_id       => fnd_global.prog_appl_id,
         p_program_id                   => fnd_global.conc_program_id,
         p_request_id                   => fnd_global.conc_request_id,
         p_program_update_date          => sysdate);
      --
IF nvl(l_env_rec.mode_cd,'~') = 'D' THEN
 --
 IF NOT ben_icm_life_events.g_cache_epo_object.EXISTS(1) THEN
      --
      l_count_icm1  := 1;
    --
    ELSE
      --
      l_count_icm1  := ben_icm_life_events.g_cache_epo_object.LAST + 1;
    --
    END IF;
   --
   hr_utility.set_location('Building epo cache1 4 : count '  || l_count_icm1,123);
--ICM
ben_icm_life_events.g_cache_epo_object(l_count_icm1).elig_per_id := l_elig_per_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).elig_per_opt_id := l_elig_per_opt_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).effective_start_date :=l_effective_start_date;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).effective_end_date :=l_effective_end_date;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).business_group_id := p_business_group_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).per_in_ler_id :=l_per_in_ler_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).prtn_strt_dt := l_prtn_strt_dt;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).prtn_end_dt := null;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).opt_id := l_oipl_rec.opt_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).wait_perd_strt_dt := l_wait_perd_strt_dt;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).elig_flag :=l_elig_flag;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).comp_ref_amt := p_comp_rec.comp_ref_amt;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).cmbn_age_n_los_val := p_comp_rec.cmbn_age_n_los_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).comp_ref_uom := p_comp_rec.comp_ref_uom;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).age_val := p_comp_rec.age_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).age_uom := p_comp_rec.age_uom;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).los_val := p_comp_rec.los_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).los_uom := p_comp_rec.los_uom;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).hrs_wkd_val := p_comp_rec.hrs_wkd_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).wait_perd_cmpltn_date := l_wait_perd_cmpltn_dt;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).hrs_wkd_bndry_perd_cd := p_comp_rec.hrs_wkd_bndry_perd_cd;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).pct_fl_tm_val := p_comp_rec.pct_fl_tm_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).frz_los_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).frz_age_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).frz_cmp_lvl_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).frz_pct_fl_tm_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).frz_hrs_wkd_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).frz_comb_age_and_los_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_comp_ref_amt := p_comp_rec.rt_comp_ref_amt;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_cmbn_age_n_los_val := p_comp_rec.rt_cmbn_age_n_los_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_comp_ref_uom := p_comp_rec.rt_comp_ref_uom;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_age_val := p_comp_rec.rt_age_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_age_uom := p_comp_rec.rt_age_uom;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_los_val := p_comp_rec.rt_los_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_los_uom := p_comp_rec.rt_los_uom;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_hrs_wkd_val := p_comp_rec.rt_hrs_wkd_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_hrs_wkd_bndry_perd_cd := p_comp_rec.rt_hrs_wkd_bndry_perd_cd;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_pct_fl_tm_val := p_comp_rec.rt_pct_fl_tm_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_frz_los_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_frz_age_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_frz_cmp_lvl_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_frz_pct_fl_tm_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_frz_hrs_wkd_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_frz_comb_age_and_los_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).once_r_cntug_cd := p_comp_rec.once_r_cntug_cd;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).object_version_number := l_t_object_version_number;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).program_application_id :=fnd_global.prog_appl_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).program_id :=fnd_global.conc_program_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).request_id :=fnd_global.conc_request_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).program_update_date :=sysdate;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).p_datetrack_mode:= l_datetrack_mode;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).p_effective_date:= l_effective_dt;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).p_newly_elig :=  l_newly_elig;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).p_newly_inelig:= l_newly_inelig;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).p_first_elig :=  l_first_elig;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).p_first_inelig := l_first_inelig;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).p_still_elig :=  l_still_elig;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).p_still_inelig:= l_still_inelig;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).p_pl_id := l_envpl_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).prtn_ovridn_flag := 'N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).no_mx_prtn_ovrid_thru_flag := 'N';
--
END IF;
--ICM
      if p_score_tab.count > 0 then
         hr_utility.set_location('writing score records ',5.7);
         ben_elig_scre_wtg_api.load_score_weight
         (p_validate              => false
         ,p_score_tab             => p_score_tab
         ,p_effective_date        => l_effective_dt
         ,p_per_in_ler_id         => l_per_in_ler_id    /* Bug 4438430 */
         ,p_elig_per_id           => l_elig_per_id
         ,p_elig_per_opt_id       => l_elig_per_opt_id);
      end if;
    elsif l_newly_inelig then        --n
      --
	hr_utility.set_location ('newly inelig',121);
      -- Person was found not eligible for this oipl.
      -- Person was prev eligible.  Now is newly ineligible.
      -- Call API to Update old record with end date (correction)
      -- Then call in update mode to create a new inelig record with
      -- start date = computed end date plus 1.
      -- if the previous row's start date is greater than the computed
      -- end date, then they never really became eligible.  Go find
      -- another 'start' inelig date to use.
      --
      l_t_object_version_number := l_object_version_number_opt;
      --
      if l_prev_prtn_strt_dt > l_prtn_eff_end_dt then               --p
        --
        -- Check for an existing ineligible record where our computed end
        -- date falls between existing records start and end dates.
        --
        open c_opt_overlap (c_prtn_eff_strt_dt => l_prtn_eff_end_dt
                           ,c_elig_flag        => 'N'
                           ,c_add_one          => 0);
          --
          fetch c_opt_overlap into l_opt_overlap;
          --
        close c_opt_overlap;
        --
        if l_opt_overlap.prtn_strt_dt is not null then
          --
          l_end_dt_plus_one := l_opt_overlap.prtn_strt_dt;
          --
        end if;
        --
      else                               --p
        --
        ben_Eligible_Person_perf_api.update_perf_Elig_Person_Option
          (p_validate                     => FALSE,
           p_elig_per_opt_id              => l_elig_per_opt_id,
           p_elig_per_id                  => l_elig_per_id,
           --
           -- Bug 2284417 : Do not update the per in ler id with new
           -- per in ler id as this row peice of row should belong to
           -- previous per in ler. Next update will update the
           -- per in ler id as well as new prtn strt dt.
           --
           -- p_per_in_ler_id                => l_per_in_ler_id,
           p_effective_start_date         => l_effective_start_date,
           p_effective_end_date           => l_effective_end_date,
           p_prtn_end_dt                  => l_prtn_eff_end_dt,
     --      p_effective_date               => p_effective_date,
           p_effective_date               => l_effective_dt,
           p_object_version_number        => l_object_version_number_opt,
           p_datetrack_mode               => hr_api.g_correction,
           p_program_application_id       => fnd_global.prog_appl_id,
           p_program_id                   => fnd_global.conc_program_id,
           p_request_id                   => fnd_global.conc_request_id,
           p_program_update_date          => sysdate);
        --
      end if;            --p
      --
      dt_api.find_dt_upd_modes
        (-- p_effective_date       => p_effective_date,
         --
         -- Bugs : 1412882, part of bug 1412951
         --
         p_effective_date               => l_effective_dt,
         --
         p_base_table_name      => 'BEN_ELIG_PER_OPT_F',
         p_base_key_column      => 'elig_per_opt_id',
         p_base_key_value       => l_elig_per_opt_id,
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
      --
      IF l_datetrack_mode = hr_api.g_correction AND
         l_per_in_ler_id <> NVL(l_prev_per_in_ler_id,-1) THEN
        --
        ben_determine_eligibility3.save_to_restore
        (p_current_per_in_ler_id   => l_per_in_ler_id
        ,p_per_in_ler_id          => l_prev_per_in_ler_id
        ,p_elig_per_id            => NULL
        ,p_elig_per_opt_id        => l_elig_per_opt_id
        ,p_effective_date         => l_effective_dt
        );
        --
      END IF;
      --
      l_elig_flag := 'N';
      l_prtn_strt_dt := l_end_dt_plus_one;
      --
      ben_Eligible_Person_perf_api.update_perf_Elig_Person_Option
        (p_validate                     => FALSE,
         p_elig_per_opt_id              => l_elig_per_opt_id,
         p_elig_per_id                  => l_elig_per_id,
         p_per_in_ler_id                => l_per_in_ler_id,
         p_effective_start_date         => l_effective_start_date,
         p_effective_end_date           => l_effective_end_date,
         p_elig_flag                    => l_elig_flag,
         p_prtn_strt_dt                 => l_prtn_strt_dt,
         p_prtn_end_dt                  => null,
         p_rt_comp_ref_amt              => p_comp_rec.rt_comp_ref_amt,
         p_rt_cmbn_age_n_los_val        => p_comp_rec.rt_cmbn_age_n_los_val,
         p_rt_comp_ref_uom              => p_comp_rec.rt_comp_ref_uom,
         p_rt_age_val                   => p_comp_rec.rt_age_val,
         p_rt_los_val                   => p_comp_rec.rt_los_val,
         p_rt_hrs_wkd_val               => p_comp_rec.rt_hrs_wkd_val,
         p_rt_hrs_wkd_bndry_perd_cd     => p_comp_rec.rt_hrs_wkd_bndry_perd_cd,
         p_rt_age_uom                   => p_comp_rec.rt_age_uom,
         p_rt_los_uom                   => p_comp_rec.rt_los_uom,
         p_rt_pct_fl_tm_val             => p_comp_rec.rt_pct_fl_tm_val,
         p_rt_frz_los_flag              => 'N',
         p_rt_frz_age_flag              => 'N',
         p_rt_frz_cmp_lvl_flag          => 'N',
         p_rt_frz_pct_fl_tm_flag        => 'N',
         p_rt_frz_hrs_wkd_flag          => 'N',
         p_rt_frz_comb_age_and_los_flag => 'N',
         p_once_r_cntug_cd              => p_comp_rec.once_r_cntug_cd,
         p_comp_ref_amt                 => p_comp_rec.comp_ref_amt,
         p_cmbn_age_n_los_val           => p_comp_rec.cmbn_age_n_los_val,
         p_comp_ref_uom                 => p_comp_rec.comp_ref_uom,
         p_age_val                      => p_comp_rec.age_val,
         p_los_val                      => p_comp_rec.los_val,
         p_hrs_wkd_val                  => p_comp_rec.hrs_wkd_val,
         p_hrs_wkd_bndry_perd_cd        => p_comp_rec.hrs_wkd_bndry_perd_cd,
         p_age_uom                      => p_comp_rec.age_uom,
         p_los_uom                      => p_comp_rec.los_uom,
         p_pct_fl_tm_val                => p_comp_rec.pct_fl_tm_val,
         p_frz_los_flag                 => 'N',
         p_frz_age_flag                 => 'N',
         p_frz_cmp_lvl_flag             => 'N',
         p_frz_pct_fl_tm_flag           => 'N',
         p_frz_hrs_wkd_flag             => 'N',
         p_frz_comb_age_and_los_flag    => 'N',
         --
         -- Bugs : 1412882, part of bug 1412951
         --
         p_effective_date               => l_effective_dt,
         -- p_effective_date                => p_effective_date,
         p_object_version_number        => l_object_version_number_opt,
         p_datetrack_mode               => l_datetrack_mode,
         p_program_application_id       => fnd_global.prog_appl_id,
         p_program_id                   => fnd_global.conc_program_id,
         p_request_id                   => fnd_global.conc_request_id,
         p_program_update_date          => sysdate,
         p_inelg_rsn_cd                 => p_inelg_rsn_cd);
      --

IF nvl(l_env_rec.mode_cd,'~') = 'D' THEN
      IF NOT ben_icm_life_events.g_cache_epo_object.EXISTS(1) THEN
      --
      l_count_icm1  := 1;
    --
    ELSE
      --
      l_count_icm1  := ben_icm_life_events.g_cache_epo_object.LAST + 1;
    --
    END IF;
   --
   hr_utility.set_location('Building epo cache1 6 : count '  || l_count_icm1,123);
--ICM
ben_icm_life_events.g_cache_epo_object(l_count_icm1).elig_per_id := l_elig_per_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).elig_per_opt_id := l_elig_per_opt_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).effective_start_date :=l_effective_start_date;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).effective_end_date :=l_effective_end_date;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).business_group_id := p_business_group_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).per_in_ler_id :=l_per_in_ler_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).prtn_strt_dt := l_prtn_strt_dt;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).prtn_end_dt := null;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).opt_id := l_oipl_rec.opt_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).elig_flag :=l_elig_flag;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).comp_ref_amt := p_comp_rec.comp_ref_amt;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).cmbn_age_n_los_val := p_comp_rec.cmbn_age_n_los_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).comp_ref_uom := p_comp_rec.comp_ref_uom;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).age_val := p_comp_rec.age_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).age_uom := p_comp_rec.age_uom;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).los_val := p_comp_rec.los_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).los_uom := p_comp_rec.los_uom;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).hrs_wkd_val := p_comp_rec.hrs_wkd_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).hrs_wkd_bndry_perd_cd := p_comp_rec.hrs_wkd_bndry_perd_cd;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).pct_fl_tm_val := p_comp_rec.pct_fl_tm_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).frz_los_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).frz_age_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).frz_cmp_lvl_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).frz_pct_fl_tm_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).frz_hrs_wkd_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).frz_comb_age_and_los_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_comp_ref_amt := p_comp_rec.rt_comp_ref_amt;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_cmbn_age_n_los_val := p_comp_rec.rt_cmbn_age_n_los_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_comp_ref_uom := p_comp_rec.rt_comp_ref_uom;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_age_val := p_comp_rec.rt_age_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_age_uom := p_comp_rec.rt_age_uom;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_los_val := p_comp_rec.rt_los_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_los_uom := p_comp_rec.rt_los_uom;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_hrs_wkd_val := p_comp_rec.rt_hrs_wkd_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_hrs_wkd_bndry_perd_cd := p_comp_rec.rt_hrs_wkd_bndry_perd_cd;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_pct_fl_tm_val := p_comp_rec.rt_pct_fl_tm_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_frz_los_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_frz_age_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_frz_cmp_lvl_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_frz_pct_fl_tm_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_frz_hrs_wkd_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_frz_comb_age_and_los_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).once_r_cntug_cd := p_comp_rec.once_r_cntug_cd;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).object_version_number := l_t_object_version_number;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).oipl_ordr_num := null;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).program_application_id :=fnd_global.prog_appl_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).program_id :=fnd_global.conc_program_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).request_id :=fnd_global.conc_request_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).program_update_date :=sysdate;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).p_datetrack_mode:= l_datetrack_mode;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).p_effective_date:= l_effective_dt;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).inelg_rsn_cd :=  p_inelg_rsn_cd;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).p_newly_elig :=  l_newly_elig;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).p_newly_inelig:= l_newly_inelig;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).p_first_elig :=  l_first_elig;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).p_first_inelig := l_first_inelig;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).p_still_elig :=  l_still_elig;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).p_still_inelig:= l_still_inelig;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).p_pl_id := l_envpl_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).prtn_ovridn_flag := 'N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).no_mx_prtn_ovrid_thru_flag := 'N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).prtn_ovridn_thru_dt := null;
--
END IF;
--ICM
      -- ben_newly_ineligible does not handle levels other than
      -- plan,option in plan, or program.  Don't call it if not
      -- necessary.
      --
      if p_score_tab.count > 0 then
         hr_utility.set_location('writing score records ',5.5);
         ben_elig_scre_wtg_api.load_score_weight
         (p_validate              => false
         ,p_score_tab             => p_score_tab
         ,p_effective_date        => l_effective_dt
         ,p_per_in_ler_id         => l_per_in_ler_id    /* Bug 4438430 */
         ,p_elig_per_id           => l_elig_per_id
         ,p_elig_per_opt_id       => l_elig_per_opt_id);
      end if;
      --
      if p_plip_id is not null then
         open c_get_pl_id(nvl(l_fonm_cvg_strt_dt,p_effective_date));
         fetch c_get_pl_id into l_pl_id;
         close c_get_pl_id;
      end if;
      if p_pl_id is not null then
         l_pl_id := p_pl_id;
      end if;
      if (l_pl_id is not null or
          p_oipl_id is not null or
          p_pgm_id is not null) then
          --
       if nvl(ben_manage_life_events.g_defer_deenrol_flag,'N') <> 'Y' then  -- Defer ENH
        --
        ben_newly_ineligible.main
          (p_person_id         => p_person_id,
           p_pl_id             => l_pl_id,
           p_pgm_id            => nvl(p_pgm_id,l_envpgm_id),
           p_oipl_id           => p_oipl_id,
           p_business_group_id => p_business_group_id,
           p_ler_id            => p_ler_id,
           p_effective_date   => l_effective_dt);
         --  p_effective_date    => p_effective_date);
        --
       end if;
       --
      end if;
      --
      if p_ptip_id is not null then
       if nvl(ben_manage_life_events.g_defer_deenrol_flag,'N') <> 'Y'  then   -- Defer ENH
         --
         for l_rec in c_get_pl_from_ptip(nvl(l_fonm_cvg_strt_dt,p_effective_date))  loop
          ben_newly_ineligible.main
          (p_person_id         => p_person_id,
           p_pl_id             => l_rec.pl_id,
           p_pgm_id            => nvl(p_pgm_id,l_envpgm_id),
           p_oipl_id           => p_oipl_id,
           p_business_group_id => p_business_group_id,
           p_ler_id            => p_ler_id,
           p_effective_date    => l_effective_dt);
   --        p_effective_date    => p_effective_date);
          end loop;
        --
	 --
       end if;
       --

      end if;

    elsif l_first_inelig then      --n
      --
      	hr_utility.set_location ('first inelig',121);
      -- Get elig id from ben_elig_per_f for the plan
      --
      ben_pep_cache1.get_currplnpep_dets
        (p_comp_obj_tree_row => p_comp_obj_tree_row
        ,p_person_id         => p_person_id
        ,p_effective_date    => l_effective_dt
        --
        ,p_inst_row	     => l_plnpep_dets
        );
      --
      if l_plnpep_dets.elig_per_id is null
      then
        --
        fnd_message.set_name('BEN','BEN_91394_ELIG_NOT_FOUND');
        raise ben_manage_life_events.g_record_error;
        --
      else
        --
        l_elig_per_id           := l_plnpep_dets.elig_per_id;
        l_elig_per_prtn_strt_dt := l_plnpep_dets.prtn_strt_dt;
        l_elig_per_prtn_end_dt  := l_plnpep_dets.prtn_end_dt;
        --
      end if;
      --
      l_opt_id := l_oipl_rec.opt_id;
      --
      hr_utility.set_location('l_elig_per_id '||l_elig_per_id,10);
      hr_utility.set_location('l_elig_per_opt_id '||l_elig_per_opt_id,10);
      hr_utility.set_location('l_opt_id '||l_opt_id,10);
      hr_utility.set_location('p_effective_date '||p_effective_date,10);
      --
      -- Person not eligible now or in the past.
      -- Create elig person with elig flag = 'n'
      -- Call API
      --
      if instr(ben_manage_life_events.g_output_string,
               'Elg:') = 0 then
        --
        ben_manage_life_events.g_output_string :=
          ben_manage_life_events.g_output_string||
          'Elg: No '||
          'Rsn: Not Elig FTIME';
        --
      end if;
      --
      hr_utility.set_location('ben_determine_eligibility2.check_prev_elig Fir inel Cre EPO ' , 10);
      --
      l_elig_flag := 'N';
      l_prtn_strt_dt := l_end_dt_plus_one;
      --
      ben_Eligible_Person_perf_api.create_perf_Elig_Person_Option
        (p_validate                     => FALSE,
         p_elig_per_opt_id              => l_elig_per_opt_id,
         p_elig_per_id                  => l_elig_per_id,
         p_per_in_ler_id                => l_per_in_ler_id,
         p_effective_start_date         => l_effective_start_date,
         p_effective_end_date           => l_effective_end_date,
         p_prtn_ovridn_flag             => 'N',
         p_prtn_ovridn_thru_dt          => null,
         p_no_mx_prtn_ovrid_thru_flag   => 'N',
         p_elig_flag                    => l_elig_flag,
         p_prtn_strt_dt                 => l_prtn_strt_dt,
         p_opt_id                       => l_opt_id,
         p_rt_comp_ref_amt              => p_comp_rec.rt_comp_ref_amt,
         p_rt_cmbn_age_n_los_val        => p_comp_rec.rt_cmbn_age_n_los_val,
         p_rt_comp_ref_uom              => p_comp_rec.rt_comp_ref_uom,
         p_rt_age_val                   => p_comp_rec.rt_age_val,
         p_rt_los_val                   => p_comp_rec.rt_los_val,
         p_rt_hrs_wkd_val               => p_comp_rec.rt_hrs_wkd_val,
         p_rt_hrs_wkd_bndry_perd_cd     => p_comp_rec.rt_hrs_wkd_bndry_perd_cd,
         p_rt_age_uom                   => p_comp_rec.rt_age_uom,
         p_rt_los_uom                   => p_comp_rec.rt_los_uom,
         p_rt_pct_fl_tm_val             => p_comp_rec.rt_pct_fl_tm_val,
         p_rt_frz_los_flag              => 'N',
         p_rt_frz_age_flag              => 'N',
         p_rt_frz_cmp_lvl_flag          => 'N',
         p_rt_frz_pct_fl_tm_flag        => 'N',
         p_rt_frz_hrs_wkd_flag          => 'N',
         p_rt_frz_comb_age_and_los_flag => 'N',
         p_once_r_cntug_cd              => p_comp_rec.once_r_cntug_cd,
         p_comp_ref_amt                 => p_comp_rec.comp_ref_amt,
         p_cmbn_age_n_los_val           => p_comp_rec.cmbn_age_n_los_val,
         p_comp_ref_uom                 => p_comp_rec.comp_ref_uom,
         p_age_val                      => p_comp_rec.age_val,
         p_los_val                      => p_comp_rec.los_val,
         p_hrs_wkd_val                  => p_comp_rec.hrs_wkd_val,
         p_hrs_wkd_bndry_perd_cd        => p_comp_rec.hrs_wkd_bndry_perd_cd,
         p_age_uom                      => p_comp_rec.age_uom,
         p_los_uom                      => p_comp_rec.los_uom,
         p_pct_fl_tm_val                => p_comp_rec.pct_fl_tm_val,
         p_frz_los_flag                 => 'N',
         p_frz_age_flag                 => 'N',
         p_frz_cmp_lvl_flag             => 'N',
         p_frz_pct_fl_tm_flag           => 'N',
         p_frz_hrs_wkd_flag             => 'N',
         p_frz_comb_age_and_los_flag    => 'N',
         p_oipl_ordr_num                => l_oipl_rec.ordr_num,
         p_business_group_id            => p_business_group_id,
         --
         -- Bugs : 1412882, part of bug 1412951
         --
         p_effective_date               => l_effective_dt,
         -- p_effective_date               => p_effective_date,
         p_object_version_number        => l_object_version_number_opt,
         p_program_application_id       => fnd_global.prog_appl_id,
         p_program_id                   => fnd_global.conc_program_id,
         p_request_id                   => fnd_global.conc_request_id,
         p_program_update_date          => sysdate,
         p_inelg_rsn_cd                 => p_inelg_rsn_cd
         --
         -- Bypass insert validate validation for performance
         --
        ,p_override_validation          => TRUE);
      --
      hr_utility.set_location('ben_determine_eligibility2.check_prev_elig Dn Fir inel Cre EPO ' , 10);
      --
  -- ICM
IF nvl(l_env_rec.mode_cd,'~') = 'D' THEN
   IF NOT ben_icm_life_events.g_cache_epo_object.EXISTS(1) THEN
      --
      l_count_icm1  := 1;
    --
    ELSE
      --
      l_count_icm1  := ben_icm_life_events.g_cache_epo_object.LAST + 1;
    --
    END IF;
   --
hr_utility.set_location('Building epo cache1 7 : count '  || l_count_icm1,123);
--
ben_icm_life_events.g_cache_epo_object(l_count_icm1).elig_per_id := l_elig_per_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).elig_per_opt_id := l_elig_per_opt_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).effective_start_date :=l_effective_start_date;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).effective_end_date :=l_effective_end_date;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).business_group_id := p_business_group_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).prtn_ovridn_thru_dt := null;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).per_in_ler_id :=l_per_in_ler_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).prtn_ovridn_flag := 'N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).no_mx_prtn_ovrid_thru_flag := 'N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).prtn_strt_dt := l_prtn_strt_dt;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).opt_id := l_opt_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).elig_flag :=l_elig_flag;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).comp_ref_amt := p_comp_rec.comp_ref_amt;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).cmbn_age_n_los_val := p_comp_rec.cmbn_age_n_los_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).comp_ref_uom := p_comp_rec.comp_ref_uom;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).age_val := p_comp_rec.age_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).age_uom := p_comp_rec.age_uom;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).los_val := p_comp_rec.los_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).los_uom := p_comp_rec.los_uom;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).hrs_wkd_val := p_comp_rec.hrs_wkd_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).hrs_wkd_bndry_perd_cd := p_comp_rec.hrs_wkd_bndry_perd_cd;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).pct_fl_tm_val := p_comp_rec.pct_fl_tm_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).frz_los_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).frz_age_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).frz_cmp_lvl_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).frz_pct_fl_tm_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).frz_hrs_wkd_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).frz_comb_age_and_los_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_comp_ref_amt := p_comp_rec.rt_comp_ref_amt;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_cmbn_age_n_los_val := p_comp_rec.rt_cmbn_age_n_los_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_comp_ref_uom := p_comp_rec.rt_comp_ref_uom;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_age_val := p_comp_rec.rt_age_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_age_uom := p_comp_rec.rt_age_uom;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_los_val := p_comp_rec.rt_los_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_los_uom := p_comp_rec.rt_los_uom;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_hrs_wkd_val := p_comp_rec.rt_hrs_wkd_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_hrs_wkd_bndry_perd_cd := p_comp_rec.rt_hrs_wkd_bndry_perd_cd;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_pct_fl_tm_val := p_comp_rec.rt_pct_fl_tm_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_frz_los_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_frz_age_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_frz_cmp_lvl_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_frz_pct_fl_tm_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_frz_hrs_wkd_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_frz_comb_age_and_los_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).once_r_cntug_cd := p_comp_rec.once_r_cntug_cd;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).oipl_ordr_num := l_oipl_rec.ordr_num;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).object_version_number := l_object_version_number_opt;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).program_application_id :=fnd_global.prog_appl_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).program_id :=fnd_global.conc_program_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).request_id :=fnd_global.conc_request_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).program_update_date :=sysdate;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).p_effective_date:= l_effective_dt;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).inelg_rsn_cd := p_inelg_rsn_cd;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).p_newly_elig :=  l_newly_elig;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).p_newly_inelig:= l_newly_inelig;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).p_first_elig :=  l_first_elig;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).p_first_inelig := l_first_inelig;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).p_still_elig :=  l_still_elig;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).p_still_inelig:= l_still_inelig;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).p_pl_id := l_envpl_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).wait_perd_cmpltn_dt := null;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).wait_perd_strt_dt := null;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).wait_perd_cmpltn_date := null;
--
END IF;
      if p_score_tab.count > 0 then
         hr_utility.set_location('writing score records ',5.5);
         ben_elig_scre_wtg_api.load_score_weight
         (p_validate              => false
         ,p_score_tab             => p_score_tab
         ,p_effective_date        => l_effective_dt
         ,p_per_in_ler_id         => l_per_in_ler_id    /* Bug 4438430 */
         ,p_elig_per_id           => l_elig_per_id
         ,p_elig_per_opt_id       => l_elig_per_opt_id);
      end if;
    else
      --
      fnd_message.set_name('BEN','BEN_91392_ELIG_FLAG_ERROR');
      raise ben_manage_life_events.g_record_error;
      --
    end if; --n
    --
    -- Now check for the oiplip case.
    -- 1) Check if there is an oiplip for the oipl
    -- 2) Check if a prev oiplip row existed
    -- 3) If effective date is the same do a correction
    -- 4) If effective start date is another date so an update or update
    --    override
    -- 5) If the effective date is null then do an insert
    --
    if p_comp_obj_tree_row.oiplip_id is not null then
      --
      if g_debug then
        hr_utility.set_location('Creating OIPLIP',10);
      end if;
      l_object_version_number := null;
      --
      if g_debug then
        hr_utility.set_location('PLIP'||l_envplip_id,10);
        hr_utility.set_location('PGM'||l_envpgm_id,10);
        hr_utility.set_location('PERSON'||p_person_id,10);
        hr_utility.set_location('OPT_ID'||l_oipl_rec.opt_id,10);
      end if;
      --
      -- Check for previous OIPLIP
      --
      ben_pep_cache.get_pilepo_dets
        (p_person_id         => p_person_id
        ,p_business_group_id => p_business_group_id
        ,p_effective_date    => l_effective_dt
        ,p_pgm_id            => l_envpgm_id
        ,p_plip_id           => l_envplip_id
        ,p_opt_id            => l_oipl_rec.opt_id
        ,p_date_sync         => TRUE
        ,p_inst_row	     => l_oiplipepo_row
        );
      --
      if l_oiplipepo_row.elig_per_opt_id is null then
        --
        if g_debug then
          hr_utility.set_location('Record not found',10);
        end if;
        --
        ben_pep_cache1.get_curroiplippep_dets
          (p_comp_obj_tree_row => p_comp_obj_tree_row
          ,p_person_id         => p_person_id
          ,p_effective_date    => l_effective_dt
          --
          ,p_inst_row	       => l_oiplippep_dets
          );
        --
        l_prev_oiplip_elig_check.elig_per_id := l_oiplippep_dets.elig_per_id;
        --
      else
        --
        l_prev_oiplip_elig_check.elig_per_opt_id       := l_oiplipepo_row.elig_per_opt_id;
        l_prev_oiplip_elig_check.elig_per_id           := l_oiplipepo_row.elig_per_id;
        l_prev_oiplip_elig_check.object_version_number := l_oiplipepo_row.object_version_number;
        --
      end if;
      --
      if l_prev_oiplip_elig_check.elig_per_opt_id is null then
        --
        -- Bug 3111613
	-- if cache reeturns a null here, raise an error
        if l_prev_oiplip_elig_check.elig_per_id is null then
                fnd_message.set_name('BEN','BEN_91394_ELIG_NOT_FOUND');
	        raise ben_manage_life_events.g_record_error;
	end if;


        -- Create oiplip record
        --
        if g_debug then
          hr_utility.set_location('ben_determine_eligibility2.check_prev_elig BEPOAPI_CreOIPLIP ' , 10);
        end if;
        --
        ben_Eligible_Person_perf_api.create_perf_Elig_Person_Option
          (p_validate                     => FALSE,
           p_elig_per_opt_id              => l_prev_oiplip_elig_check.elig_per_opt_id,
           p_elig_per_id                  => l_prev_oiplip_elig_check.elig_per_id,
           p_per_in_ler_id                => l_per_in_ler_id,
           p_prtn_ovridn_flag             => 'N',
           p_prtn_ovridn_thru_dt          => null,
           p_no_mx_prtn_ovrid_thru_flag   => 'N',
           p_elig_flag                    => 'Y',
           p_prtn_strt_dt                 => null,
           p_opt_id                       => l_oipl_rec.opt_id,
           p_rt_comp_ref_amt              => p_oiplip_rec.rt_comp_ref_amt,
           p_rt_cmbn_age_n_los_val        => p_oiplip_rec.rt_cmbn_age_n_los_val,
           p_rt_comp_ref_uom              => p_oiplip_rec.rt_comp_ref_uom,
           p_rt_age_val                   => p_oiplip_rec.rt_age_val,
           p_rt_los_val                   => p_oiplip_rec.rt_los_val,
           p_rt_hrs_wkd_val               => p_oiplip_rec.rt_hrs_wkd_val,
           p_rt_hrs_wkd_bndry_perd_cd     => p_oiplip_rec.rt_hrs_wkd_bndry_perd_cd,
           p_rt_age_uom                   => p_oiplip_rec.rt_age_uom,
           p_rt_los_uom                   => p_oiplip_rec.rt_los_uom,
           p_rt_pct_fl_tm_val             => p_oiplip_rec.rt_pct_fl_tm_val,
           p_rt_frz_los_flag              => 'N',
           p_rt_frz_age_flag              => 'N',
           p_rt_frz_cmp_lvl_flag          => 'N',
           p_rt_frz_pct_fl_tm_flag        => 'N',
           p_rt_frz_hrs_wkd_flag          => 'N',
           p_rt_frz_comb_age_and_los_flag => 'N',
           p_once_r_cntug_cd              => p_oiplip_rec.once_r_cntug_cd,
           p_comp_ref_amt                 => p_oiplip_rec.comp_ref_amt,
           p_cmbn_age_n_los_val           => p_oiplip_rec.cmbn_age_n_los_val,
           p_comp_ref_uom                 => p_oiplip_rec.comp_ref_uom,
           p_age_val                      => p_oiplip_rec.age_val,
           p_los_val                      => p_oiplip_rec.los_val,
           p_hrs_wkd_val                  => p_oiplip_rec.hrs_wkd_val,
           p_hrs_wkd_bndry_perd_cd        => p_oiplip_rec.hrs_wkd_bndry_perd_cd,
           p_age_uom                      => p_oiplip_rec.age_uom,
           p_los_uom                      => p_oiplip_rec.los_uom,
           p_pct_fl_tm_val                => p_oiplip_rec.pct_fl_tm_val,
           p_frz_los_flag                 => 'N',
           p_frz_age_flag                 => 'N',
           p_frz_cmp_lvl_flag             => 'N',
           p_frz_pct_fl_tm_flag           => 'N',
           p_frz_hrs_wkd_flag             => 'N',
           p_frz_comb_age_and_los_flag    => 'N',
           -- p_wait_perd_cmpltn_dt          => null,
           p_wait_perd_cmpltn_date        => null,
           p_wait_perd_strt_dt            => null,
           p_effective_start_date         => l_effective_start_date,
           p_effective_end_date           => l_effective_end_date,
           p_object_version_number        => l_prev_oiplip_elig_check.object_version_number,
           p_oipl_ordr_num                => null,
           p_business_group_id            => p_business_group_id,
           p_program_application_id       => fnd_global.prog_appl_id,
           p_program_id                   => fnd_global.conc_program_id,
           p_request_id                   => fnd_global.conc_request_id,
           p_program_update_date          => sysdate,
           --
           -- Bugs : 1412882, part of bug 1412951
           --
           p_effective_date               => l_effective_dt,
           -- p_effective_date               => p_effective_date
           p_override_validation          => TRUE);
        --
	  -- ICM
IF nvl(l_env_rec.mode_cd,'~') = 'D' THEN
   IF NOT ben_icm_life_events.g_cache_epo_object.EXISTS(1) THEN
      --
      l_count_icm1  := 1;
    --
    ELSE
      --
      l_count_icm1  := ben_icm_life_events.g_cache_epo_object.LAST + 1;
    --
    END IF;
   --
   hr_utility.set_location('Building epo cache1 8 : count '  || l_count_icm1,123);
--
ben_icm_life_events.g_cache_epo_object(l_count_icm1).elig_per_id := l_prev_oiplip_elig_check.elig_per_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).elig_per_opt_id := l_prev_oiplip_elig_check.elig_per_opt_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).effective_start_date :=l_effective_start_date;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).effective_end_date :=l_effective_end_date;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).prtn_ovridn_flag  := 'N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).business_group_id := p_business_group_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).per_in_ler_id := l_per_in_ler_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).prtn_strt_dt := null;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).opt_id := l_oipl_rec.opt_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).prtn_ovridn_thru_dt := null;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).wait_perd_strt_dt :=null;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).wait_perd_cmpltn_date :=null;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).no_mx_prtn_ovrid_thru_flag := 'N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).elig_flag := 'Y';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).comp_ref_amt := p_oiplip_rec.comp_ref_amt;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).cmbn_age_n_los_val := p_oiplip_rec.cmbn_age_n_los_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).comp_ref_uom := p_oiplip_rec.comp_ref_uom;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).age_val := p_oiplip_rec.age_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).age_uom := p_oiplip_rec.age_uom;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).los_val := p_oiplip_rec.los_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).los_uom := p_oiplip_rec.los_uom;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).hrs_wkd_val := p_oiplip_rec.hrs_wkd_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).hrs_wkd_bndry_perd_cd := p_oiplip_rec.hrs_wkd_bndry_perd_cd;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).pct_fl_tm_val := p_oiplip_rec.pct_fl_tm_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).frz_los_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).frz_age_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).frz_cmp_lvl_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).frz_pct_fl_tm_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).frz_hrs_wkd_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).frz_comb_age_and_los_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_comp_ref_amt := p_oiplip_rec.rt_comp_ref_amt;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_cmbn_age_n_los_val := p_oiplip_rec.rt_cmbn_age_n_los_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_comp_ref_uom := p_oiplip_rec.rt_comp_ref_uom;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_age_val := p_oiplip_rec.rt_age_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_age_uom := p_oiplip_rec.rt_age_uom;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_los_val := p_oiplip_rec.rt_los_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_los_uom := p_oiplip_rec.rt_los_uom;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_hrs_wkd_val := p_oiplip_rec.rt_hrs_wkd_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_hrs_wkd_bndry_perd_cd := p_oiplip_rec.rt_hrs_wkd_bndry_perd_cd;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_pct_fl_tm_val := p_oiplip_rec.rt_pct_fl_tm_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_frz_los_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_frz_age_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_frz_cmp_lvl_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_frz_pct_fl_tm_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_frz_hrs_wkd_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_frz_comb_age_and_los_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).once_r_cntug_cd := p_oiplip_rec.once_r_cntug_cd;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).oipl_ordr_num := null;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).program_application_id :=fnd_global.prog_appl_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).program_id :=fnd_global.conc_program_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).request_id :=fnd_global.conc_request_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).object_version_number := l_prev_oiplip_elig_check.object_version_number;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).program_update_date :=sysdate;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).p_effective_date:= l_effective_dt;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).p_pl_id := l_envpl_id;
--
END IF;
        if g_debug then
          hr_utility.set_location('ben_determine_eligibility2.check_prev_elig Dn BEPOAPI_CreOIPLIP ' , 10);
        end if;
        --
      else
        --
	l_t_object_version_number := l_prev_oiplip_elig_check.object_version_number;
	--
        dt_api.find_dt_upd_modes
          (-- p_effective_date       => p_effective_date,
           --
           -- Bugs : 1412882, part of bug 1412951
           --
           p_effective_date               => l_effective_dt,
           --
           p_base_table_name      => 'BEN_ELIG_PER_OPT_F',
           p_base_key_column      => 'elig_per_opt_id',
           p_base_key_value       => l_prev_oiplip_elig_check.elig_per_opt_id,
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
        -- Update oiplip record with correct mode
        --
        IF l_datetrack_mode = hr_api.g_correction AND
           l_per_in_ler_id <> NVL(l_prev_per_in_ler_id,-1) THEN
          --
          ben_determine_eligibility3.save_to_restore
          (p_current_per_in_ler_id   => l_per_in_ler_id
          ,p_per_in_ler_id          => l_prev_per_in_ler_id
          ,p_elig_per_id            => NULL
          ,p_elig_per_opt_id        => l_prev_oiplip_elig_check.elig_per_opt_id
          ,p_effective_date         => l_effective_dt
          );
          --
        END IF;
        --
        ben_Eligible_Person_perf_api.update_perf_Elig_Person_Option
          (p_validate                     => FALSE,
           p_elig_per_opt_id              => l_prev_oiplip_elig_check.elig_per_opt_id,
           p_elig_per_id                  => l_prev_oiplip_elig_check.elig_per_id,
           p_effective_start_date         => l_effective_start_date,
           p_effective_end_date           => l_effective_end_date,
           p_per_in_ler_id                => l_per_in_ler_id,
           p_elig_flag                    => 'Y',
           p_prtn_strt_dt                 => null,
           p_prtn_end_dt                  => null,
           p_rt_comp_ref_amt              => p_oiplip_rec.rt_comp_ref_amt,
           p_rt_cmbn_age_n_los_val        => p_oiplip_rec.rt_cmbn_age_n_los_val,
           p_rt_comp_ref_uom              => p_oiplip_rec.rt_comp_ref_uom,
           p_rt_age_val                   => p_oiplip_rec.rt_age_val,
           p_rt_los_val                   => p_oiplip_rec.rt_los_val,
           p_rt_hrs_wkd_val               => p_oiplip_rec.rt_hrs_wkd_val,
           p_rt_hrs_wkd_bndry_perd_cd     => p_oiplip_rec.rt_hrs_wkd_bndry_perd_cd,
           p_rt_age_uom                   => p_oiplip_rec.rt_age_uom,
           p_rt_los_uom                   => p_oiplip_rec.rt_los_uom,
           p_rt_pct_fl_tm_val             => p_oiplip_rec.rt_pct_fl_tm_val,
           p_rt_frz_los_flag              => 'N',
           p_rt_frz_age_flag              => 'N',
           p_rt_frz_cmp_lvl_flag          => 'N',
           p_rt_frz_pct_fl_tm_flag        => 'N',
           p_rt_frz_hrs_wkd_flag          => 'N',
           p_rt_frz_comb_age_and_los_flag => 'N',
           p_once_r_cntug_cd              => p_oiplip_rec.once_r_cntug_cd,
           p_comp_ref_amt                 => p_oiplip_rec.comp_ref_amt,
           p_cmbn_age_n_los_val           => p_oiplip_rec.cmbn_age_n_los_val,
           p_comp_ref_uom                 => p_oiplip_rec.comp_ref_uom,
           p_age_val                      => p_oiplip_rec.age_val,
           p_los_val                      => p_oiplip_rec.los_val,
           p_hrs_wkd_val                  => p_oiplip_rec.hrs_wkd_val,
           p_hrs_wkd_bndry_perd_cd        => p_oiplip_rec.hrs_wkd_bndry_perd_cd,
           p_age_uom                      => p_oiplip_rec.age_uom,
           p_los_uom                      => p_oiplip_rec.los_uom,
           p_pct_fl_tm_val                => p_oiplip_rec.pct_fl_tm_val,
           p_frz_los_flag                 => 'N',
           p_frz_age_flag                 => 'N',
           p_frz_cmp_lvl_flag             => 'N',
           p_frz_pct_fl_tm_flag           => 'N',
           p_frz_hrs_wkd_flag             => 'N',
           p_frz_comb_age_and_los_flag    => 'N',
           -- p_wait_perd_cmpltn_dt          => null,
           p_wait_perd_cmpltn_date          => null,
           p_wait_perd_strt_dt            => null,
           --
           -- Bugs : 1412882, part of bug 1412951
           --
           p_effective_date               => l_effective_dt,
           -- p_effective_date               => p_effective_date,
           p_object_version_number        => l_prev_oiplip_elig_check.object_version_number,
           p_datetrack_mode               => l_datetrack_mode,
           p_program_application_id       => fnd_global.prog_appl_id,
           p_program_id                   => fnd_global.conc_program_id,
           p_request_id                   => fnd_global.conc_request_id,
           p_program_update_date          => sysdate);
        --
IF nvl(l_env_rec.mode_cd,'~') = 'D' THEN
  IF NOT ben_icm_life_events.g_cache_epo_object.EXISTS(1) THEN
      --
      l_count_icm1  := 1;
    --
    ELSE
      --
      l_count_icm1  := ben_icm_life_events.g_cache_epo_object.LAST + 1;
    --
  END IF;
   --
   hr_utility.set_location('Building epo cache1 9 : count ',123);
   --
--ICM
ben_icm_life_events.g_cache_epo_object(l_count_icm1).elig_per_id := l_prev_oiplip_elig_check.elig_per_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).elig_per_opt_id := l_prev_oiplip_elig_check.elig_per_opt_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).effective_start_date :=l_effective_start_date;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).effective_end_date :=l_effective_end_date;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).business_group_id := p_business_group_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).per_in_ler_id :=l_per_in_ler_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).prtn_strt_dt := null;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).prtn_end_dt := null;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).opt_id := l_oipl_rec.opt_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).wait_perd_cmpltn_date := null;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).wait_perd_strt_dt := null;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).elig_flag := 'Y';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).comp_ref_amt := p_oiplip_rec.comp_ref_amt;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).cmbn_age_n_los_val := p_oiplip_rec.cmbn_age_n_los_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).comp_ref_uom := p_oiplip_rec.comp_ref_uom;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).age_val := p_oiplip_rec.age_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).age_uom := p_oiplip_rec.age_uom;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).los_val := p_oiplip_rec.los_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).los_uom := p_oiplip_rec.los_uom;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).hrs_wkd_val := p_oiplip_rec.hrs_wkd_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).hrs_wkd_bndry_perd_cd := p_oiplip_rec.hrs_wkd_bndry_perd_cd;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).pct_fl_tm_val := p_oiplip_rec.pct_fl_tm_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).frz_los_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).frz_age_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).frz_cmp_lvl_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).frz_pct_fl_tm_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).frz_hrs_wkd_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).frz_comb_age_and_los_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_comp_ref_amt := p_oiplip_rec.rt_comp_ref_amt;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_cmbn_age_n_los_val := p_oiplip_rec.rt_cmbn_age_n_los_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_comp_ref_uom := p_oiplip_rec.rt_comp_ref_uom;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_age_val := p_oiplip_rec.rt_age_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_age_uom := p_oiplip_rec.rt_age_uom;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_los_val := p_oiplip_rec.rt_los_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_los_uom := p_oiplip_rec.rt_los_uom;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_hrs_wkd_val := p_oiplip_rec.rt_hrs_wkd_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_hrs_wkd_bndry_perd_cd := p_oiplip_rec.rt_hrs_wkd_bndry_perd_cd;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_pct_fl_tm_val := p_oiplip_rec.rt_pct_fl_tm_val;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_frz_los_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_frz_age_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_frz_cmp_lvl_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_frz_pct_fl_tm_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_frz_hrs_wkd_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).rt_frz_comb_age_and_los_flag :='N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).once_r_cntug_cd := p_oiplip_rec.once_r_cntug_cd;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).object_version_number := l_t_object_version_number; --l_prev_oiplip_elig_check.object_version_number-1;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).program_application_id :=fnd_global.prog_appl_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).program_id :=fnd_global.conc_program_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).request_id :=fnd_global.conc_request_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).program_update_date :=sysdate;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).p_effective_date:= l_effective_dt;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).p_datetrack_mode:=l_datetrack_mode;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).p_pl_id := l_envpl_id;
ben_icm_life_events.g_cache_epo_object(l_count_icm1).prtn_ovridn_flag := 'N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).no_mx_prtn_ovrid_thru_flag := 'N';
ben_icm_life_events.g_cache_epo_object(l_count_icm1).prtn_ovridn_thru_dt := null;
--
END IF;
--ICM
      end if;
      --
    end if;
    --
  else --a
    --
    if g_debug then
      hr_utility.set_location(' Chk Prev Oipl ben_determine_eligibility2.check_prev_elig ', 10);
    end if;
    --
    -- Check for a plan in program or a plip
    --
    if l_envpgm_id is not null
      and (p_pl_id is not null
        or p_plip_id is not null)
    then
      --
      if g_debug then
        hr_utility.set_location(' before pilpep  ',111);
      end if;
      ben_pep_cache.get_pilpep_dets
        (p_person_id         => p_person_id
        ,p_business_group_id => p_business_group_id
        ,p_effective_date    => l_effective_dt
        ,p_pgm_id            => l_envpgm_id
        ,p_pl_id             => p_pl_id
        ,p_plip_id           => p_plip_id
        ,p_date_sync         => TRUE
        ,p_inst_row	     => l_pep_row
        );
      --
      l_elig_per_id           := l_pep_row.elig_per_id;
      l_elig_per_elig_flag    := l_pep_row.elig_flag;
      l_prev_prtn_strt_dt     := l_pep_row.prtn_strt_dt;
      l_prev_prtn_end_dt      := l_pep_row.prtn_end_dt;
      l_per_in_ler_id         := l_pep_row.per_in_ler_id;
      l_object_version_number := l_pep_row.object_version_number;
      --
      if g_debug then
        hr_utility.set_location('elig per id'||l_elig_per_id,11);
        hr_utility.set_location('per in ler id'||l_per_in_ler_id,11);
        hr_utility.set_location('prtn start date'||l_prev_prtn_strt_dt,12);
        hr_utility.set_location(' effective date '|| l_effective_dt,111);
      end if;
      if l_pep_row.elig_per_id is null then
        --
        l_prev_eligibility := false;
        --
      else
        --
        l_prev_eligibility := true;
        --
      end if;
    --
    -- plan not in a program, pgm or ptip
    --
    else
      --
      if g_debug then
        hr_utility.set_location('l effective date'|| l_effective_dt,11);
        hr_utility.set_location('lf evt ocrd date'|| p_lf_evt_ocrd_dt,11);
      end if;
      --
      ben_determine_eligibility4.prev_elig_check
        (p_person_id             => p_person_id
        ,p_pgm_id                => nvl(p_pgm_id,nvl(l_envpgm_id,-1))
        ,p_pl_id                 => nvl(p_pl_id,-1)
        ,p_ptip_id               => nvl(p_ptip_id,-1)
        ,p_effective_date        => l_effective_dt
        ,p_mode_cd               => l_benmngle_parm_rec.mode_cd
        ,p_irec_asg_id           => ben_manage_life_events.g_irec_ass_rec.assignment_id
        --
        ,p_prev_eligibility      => l_prev_eligibility
        ,p_elig_per_id           => l_elig_per_id
        ,p_elig_per_elig_flag    => l_elig_per_elig_flag
        ,p_prev_prtn_strt_dt     => l_prev_prtn_strt_dt
        ,p_prev_prtn_end_dt      => l_prev_prtn_end_dt
        ,p_per_in_ler_id         => l_per_in_ler_id
        ,p_object_version_number => l_object_version_number
        ,p_prev_age_val          => l_old_age_val
        ,p_prev_los_val          => l_old_los_val
        );
      --
--	l_p_object_version_number := l_object_version_number;
    end if;
    --
    if g_debug then
      hr_utility.set_location('object version number'||l_object_version_number,11);
      hr_utility.set_location('Dn fetch c_prvelgchk ben_determine_eligibility2.check_prev_elig', 10);
    end if;
    --
    l_prev_per_in_ler_id := l_per_in_ler_id;
    --
    if l_new_per_in_ler_id is not null then
      l_per_in_ler_id:=l_new_per_in_ler_id;
    end if;
    --
    if g_debug then
      hr_utility.set_location('before prev notfound check ben_determine_eligibility2.check_prev_elig', 10);
    end if;
    --
    if p_pgm_id is not null then
      --
      l_pgm_rec := ben_cobj_cache.g_pgm_currow;
      --
    end if;
    --
    if p_pl_id is not null then
      --
      l_pl_rec := ben_cobj_cache.g_pl_currow;
      --
    end if;
    --
    if p_plip_id is not null then
      --
      l_plip_rec := ben_cobj_cache.g_plip_currow;
      --
    end if;
    --
    if p_ptip_id is not null then
      --
      l_ptip_rec := ben_cobj_cache.g_ptip_currow;
      --
    end if;
    --
    if not l_prev_eligibility
    then
      --
      --No record exists. Person not previously elig or inelig.
      --
      if g_debug then
        hr_utility.set_location('prev elig notfound ben_determine_eligibility2.check_prev_elig', 10);
      end if;

      if p_elig_flag then
        --
        if g_debug then
          hr_utility.set_location('elig is true ben_determine_eligibility2.check_prev_elig', 10);
        end if;
        l_first_elig := true;
	hr_utility.set_location ('first elig',121);
        l_start_or_end := 'S';
        fnd_message.set_name ('BEN','BEN_91385_FIRST_ELIG');
        benutils.write(p_text => fnd_message.get);
        --
      else
        --
        hr_utility.set_location('elig is false ben_determine_eligibility2.check_prev_elig', 10);
        fnd_message.set_name ('BEN','BEN_92533_FIRST_INELIG2');
        benutils.write(p_text => fnd_message.get);
        --
        -- only continue with program and call of api if we want to track
        -- inelig people.
        --
        if p_pgm_id is not null then
          --
          l_trk_inelig_per_flag := l_pgm_rec.trk_inelig_per_flag;
          hr_utility.set_location('Dn p_pgm_id NN ben_determine_eligibility2.check_prev_elig', 10);
          --
        elsif p_pl_id is not null then
          --
          l_trk_inelig_per_flag := l_pl_rec.trk_inelig_per_flag;
          hr_utility.set_location('Dn p_pl_id NN ben_determine_eligibility2.check_prev_elig', 10);
          --
        elsif p_plip_id is not null then
          --
          l_trk_inelig_per_flag := l_plip_rec.trk_inelig_per_flag;
          --
          hr_utility.set_location('Dn p_plip_id NN ben_determine_eligibility2.check_prev_elig', 10);
        elsif p_ptip_id is not null then
          --
          l_trk_inelig_per_flag := l_ptip_rec.trk_inelig_per_flag;
          --
          hr_utility.set_location('Dn p_ptip_id NN ben_determine_eligibility2.check_prev_elig', 10);
        end if;
        --
        if l_trk_inelig_per_flag = 'Y' then
          --
	hr_utility.set_location ('first inelig',121);
          l_first_inelig := true;
          l_start_or_end := 'E';
          --
        else
          --
          if instr(ben_manage_life_events.g_output_string,
                   'Elg:') = 0 then
            --
            ben_manage_life_events.g_output_string :=
              ben_manage_life_events.g_output_string||
              'Elg: No '||
              'Rsn: Not Elig FTIME';
            --
          end if;
          --
          -- Set transition state for processing only. Elig
          -- per is not written
          --
          hr_utility.set_location('NT Fir InEl TRUE ben_determine_eligibility2.check_prev_elig', 10);
          p_first_inelig := true;
          --
          -- bug#5404392 - previous FONM event creates the elig per row in future
         -- the subsequent finds first ineligible
          if p_pgm_id is not null then
	    if nvl(ben_manage_life_events.g_defer_deenrol_flag,'N') <> 'Y' then -- Defer ENH
            --
            ben_newly_ineligible.main
            (p_person_id         => p_person_id,
             p_pl_id             => null,
             p_pgm_id            => p_pgm_id,
             p_oipl_id           => null,
             p_business_group_id => p_business_group_id,
             p_ler_id            => p_ler_id,
             p_effective_date               => l_effective_dt);
            --
	 --
       end if;
       --
          end if;
           --
          return;
          --
        end if;
        --
      end if;
      --
    elsif l_prev_eligibility
    then
      --
      hr_utility.set_location('Prev eligibility true ',100);
      hr_utility.set_location( 'l_elig_per_elig_flag'||l_elig_per_elig_flag,123);
      if l_elig_per_elig_flag = 'Y' and p_elig_flag then  --d
        --
	hr_utility.set_location ('still elig',121);
        -- Person still eligible, do nothing.
        --
        fnd_message.set_name ('BEN','BEN_91345_ELIG_PREV_ELIG');
        benutils.write(p_text => fnd_message.get);
        l_start_or_end := 'S';
        l_still_elig := true;
  --
       --return;
        --
      elsif l_elig_per_elig_flag = 'Y' and p_elig_flag = false then  --d
        -- person is newly inelig
	hr_utility.set_location ('newly inelig',121);
        l_newly_inelig := true;
        l_start_or_end := 'E';
        fnd_message.set_name('BEN','BEN_91347_NOT_ELIG_PREV_ELIG');
        benutils.write(p_text => fnd_message.get);
        --
      elsif l_elig_per_elig_flag = 'N' and p_elig_flag = false then  --d
        -- person is still inelig, do nothing.
        fnd_message.set_name('BEN','BEN_91348_NOT_ELIG_PREV_NT_ELG');
        benutils.write(p_text => fnd_message.get);
        --
        -- Set transition state for processing only. Elig
        -- per is not written
        --
        l_still_inelig := TRUE;
        --
        /* Fidelity Enh  - inelig to inelig */
        if l_benmngle_parm_rec.mode_cd in ('L','C') then
          if p_pgm_id is not null then
          --
            l_trk_inelig_per_flag := l_pgm_rec.trk_inelig_per_flag;
          --
          elsif p_pl_id is not null then
            --
            l_trk_inelig_per_flag := l_pl_rec.trk_inelig_per_flag;
          --
          elsif p_plip_id is not null then
            --
            l_trk_inelig_per_flag := l_plip_rec.trk_inelig_per_flag;
            --
          elsif p_ptip_id is not null then
            --
            l_trk_inelig_per_flag := l_ptip_rec.trk_inelig_per_flag;
            --
          end if;
         end if;

        if g_debug then
          hr_utility.set_location ('New update for elig per'||l_elig_per_id,101);
          hr_utility.set_location ('Update mode'||l_datetrack_mode,102);
        end if;
        --
        if l_trk_inelig_per_flag = 'Y' then
          if l_envpgm_id is not null
             and (p_pl_id is not null
                  or p_plip_id is not null) then
             l_old_age_val := l_pep_row.age_val;
             l_old_los_val := l_pep_row.los_val;
           end if;
           --
	   -- Bug 8542643: Update the still inelig records irrespective of whether
	   -- old value is greater or new value is greater for age or los
           if p_comp_rec.age_val is not null or
	      p_comp_rec.los_val is not null
              then
	      --
	      l_p_object_version_number := l_object_version_number;
	      --
	    -- start of changes against bug 6601884
	      --

              -- Get the datetrack update mode. If the record already exists and the effective date is
	      -- same as start date, then update should be done in correction mode. In that case, the old
	      -- record should be inserted in the backup table

	      if g_debug then
		hr_utility.set_location('ben_determine_eligibility2.check_prev_elig DTAPI_FDUM ', 889);
		hr_utility.set_location('l_elig_per_id '||l_elig_per_id, 889);
		hr_utility.set_location('l_object_version_number '||l_object_version_number, 889);
		hr_utility.set_location('l_effective_dt '||l_effective_dt, 889);
	      end if;

	      dt_api.find_dt_upd_modes
		(p_effective_date       => l_effective_dt,
		 p_base_table_name      => 'BEN_ELIG_PER_F',
		 p_base_key_column      => 'elig_per_id',
		 p_base_key_value       => l_elig_per_id,
		 p_correction           => l_correction,
		 p_update               => l_update,
		 p_update_override      => l_update_override,
		 p_update_change_insert => l_update_change_insert);

	      if g_debug then
	        hr_utility.set_location('ben_determine_eligibility2.check_prev_elig Dn DTAPI_FDUM ', 10);
	      end if;

              if l_update_override then
 	        l_datetrack_mode := hr_api.g_update_override;

                if g_debug then
                  hr_utility.set_location('ben_elig_per_f l_datetrack_mode '|| l_datetrack_mode, 777);
		end if;

              elsif l_update then
                l_datetrack_mode := hr_api.g_update;

                if g_debug then
                  hr_utility.set_location('ben_elig_per_f l_datetrack_mode '|| l_datetrack_mode, 777);
		end if;

              else
                l_datetrack_mode := hr_api.g_correction;

                if g_debug then
                  hr_utility.set_location('ben_elig_per_f l_datetrack_mode '|| l_datetrack_mode, 777);
	        end if;

              end if;


	      hr_utility.set_location('l_per_in_ler_id'||l_per_in_ler_id,112);
	      hr_utility.set_location('l_prev_per_in_ler_id'|| l_prev_per_in_ler_id,112);
	      hr_utility.set_location('p_ler_id '|| p_ler_id,112);

	      IF l_datetrack_mode = hr_api.g_correction AND
		 l_per_in_ler_id <> NVL(l_prev_per_in_ler_id,-1) THEN

		 ben_determine_eligibility3.save_to_restore
		   (p_current_per_in_ler_id  => l_per_in_ler_id
		   ,p_per_in_ler_id          => l_prev_per_in_ler_id
		   ,p_elig_per_id            => l_elig_per_id
		   ,p_elig_per_opt_id        => NULL
		   ,p_effective_date         => l_effective_dt
		   );

	      END IF;

	      /* Bug 9020962: If future eligibility record exists, then insert the record
	   in backup table ben_le_clsn_n_rstr */
	 IF (l_datetrack_mode = hr_api.g_update_override) AND
           l_per_in_ler_id <> NVL(l_prev_per_in_ler_id,-1) THEN
          --

             open c_prev_pil(p_pil_row.per_in_ler_id);
	     fetch c_prev_pil into l_prev_pil_id;
	     close c_prev_pil;
             hr_utility.set_location('l_prev_pil_id ' || l_prev_pil_id, 7776);

	     open c_elig_rec(l_elig_per_id,l_prev_per_in_ler_id);
             fetch c_elig_rec into l_elig_per_rec;
	     close c_elig_rec;

	     open c_elig_per_id(l_prev_pil_id,
                      l_elig_per_rec.pl_id,
		      l_elig_per_rec.pgm_id,
		      l_elig_per_rec.ptip_id,
		      l_elig_per_rec.plip_id,
		      p_effective_date);
	     fetch c_elig_per_id into l_ftr_elig_per_rec;
	     close c_elig_per_id;
             if(l_ftr_elig_per_rec.elig_per_id is not null) then
		ben_determine_eligibility3.save_to_restore
			  (p_current_per_in_ler_id   => l_per_in_ler_id
			  ,p_per_in_ler_id          => l_prev_pil_id
			  ,p_elig_per_id            => l_ftr_elig_per_rec.elig_per_id
			  ,p_elig_per_opt_id        => NULL
			  ,p_effective_date         => l_ftr_elig_per_rec.effective_start_date
			  );
	     else
	         ben_determine_eligibility3.save_to_restore
		  (p_current_per_in_ler_id   => l_per_in_ler_id
		  ,p_per_in_ler_id          => l_prev_per_in_ler_id
		  ,p_elig_per_id            => l_elig_per_id
		  ,p_elig_per_opt_id        => NULL
		  ,p_effective_date         => l_effective_dt
		  );
	     end if;
          --
      END IF;
      /* End of Bug 9020962 */

	      hr_utility.set_location('Updating pep with l_per_in_ler_id'||l_per_in_ler_id,112);

          ben_Eligible_Person_perf_api.update_perf_Eligible_Person
            (p_validate                     => FALSE,
             p_elig_per_id                  => l_elig_per_id,
             p_per_in_ler_id                => l_per_in_ler_id,
             p_effective_start_date         => l_effective_start_date,
             p_effective_end_date           => l_effective_end_date,
             p_elig_flag                    => 'N', --l_elig_flag,
             p_prtn_strt_dt                 => l_prtn_strt_dt,
             p_prtn_end_dt                  => null,
	     p_ler_id                       => p_ler_id,  -- bug 5478994
             p_rt_comp_ref_amt              => p_comp_rec.rt_comp_ref_amt,
             p_rt_cmbn_age_n_los_val        => p_comp_rec.rt_cmbn_age_n_los_val,
             p_rt_comp_ref_uom              => p_comp_rec.rt_comp_ref_uom,
             p_rt_age_val                   => p_comp_rec.rt_age_val,
             p_rt_los_val                   => p_comp_rec.rt_los_val,
             p_rt_hrs_wkd_val               => p_comp_rec.rt_hrs_wkd_val,
             p_rt_hrs_wkd_bndry_perd_cd     => p_comp_rec.rt_hrs_wkd_bndry_perd_cd,
             p_rt_age_uom                   => p_comp_rec.rt_age_uom,
             p_rt_los_uom                   => p_comp_rec.rt_los_uom,
             p_rt_pct_fl_tm_val             => p_comp_rec.rt_pct_fl_tm_val,
             p_rt_frz_los_flag              => 'N',
             p_rt_frz_age_flag              => 'N',
             p_rt_frz_cmp_lvl_flag          => 'N',
             p_rt_frz_pct_fl_tm_flag        => 'N',
             p_rt_frz_hrs_wkd_flag          => 'N',
             p_rt_frz_comb_age_and_los_flag => 'N',
             p_once_r_cntug_cd              => p_comp_rec.once_r_cntug_cd,
             p_comp_ref_amt                 => p_comp_rec.comp_ref_amt,
             p_cmbn_age_n_los_val           => p_comp_rec.cmbn_age_n_los_val,
             p_comp_ref_uom                 => p_comp_rec.comp_ref_uom,
             p_age_val                      => p_comp_rec.age_val,
             p_los_val                      => p_comp_rec.los_val,
             p_hrs_wkd_val                  => p_comp_rec.hrs_wkd_val,
             p_hrs_wkd_bndry_perd_cd        => p_comp_rec.hrs_wkd_bndry_perd_cd,
             p_age_uom                      => p_comp_rec.age_uom,
             p_los_uom                      => p_comp_rec.los_uom,
             p_pct_fl_tm_val                => p_comp_rec.pct_fl_tm_val,
             p_frz_los_flag                 => 'N',
             p_frz_age_flag                 => 'N',
             p_frz_cmp_lvl_flag             => 'N',
             p_frz_pct_fl_tm_flag           => 'N',
             p_frz_hrs_wkd_flag             => 'N',
             p_frz_comb_age_and_los_flag    => 'N',
             p_wait_perd_cmpltn_dt          => l_wait_perd_cmpltn_dt,
             p_wait_perd_strt_dt            => l_wait_perd_strt_dt,
             p_object_version_number        => l_object_version_number,
             p_effective_date               => l_effective_dt,
             p_datetrack_mode               => l_datetrack_mode,
             p_program_application_id       => fnd_global.prog_appl_id,
             p_program_id                   => fnd_global.conc_program_id,
             p_request_id                   => fnd_global.conc_request_id,
             p_program_update_date          => sysdate);
            --

	      if g_debug then
	        hr_utility.set_location('Dn Still El Upd PEP  ben_determine_eligibility2.check_prev_elig', 10);
	      end if;

	      if p_score_tab.count > 0 then
	        hr_utility.set_location('writing score records ',5.5);
		ben_elig_scre_wtg_api.load_score_weight
		  (p_validate              => false
		  ,p_score_tab             => p_score_tab
		  ,p_per_in_ler_id         => l_per_in_ler_id
		  ,p_effective_date        => l_effective_dt
		  ,p_elig_per_id           => l_elig_per_id);
	      end if;

	      -- end of changes against bug 6601884

           end if;
--ICM
IF nvl(l_env_rec.mode_cd,'~') = 'D' THEN
hr_utility.set_location('Building PEP1',214);
   IF NOT ben_icm_life_events.g_cache_pep_object.EXISTS(1) THEN
      --
      l_count_icm  := 1;
    --
    ELSE
      --
      l_count_icm  := ben_icm_life_events.g_cache_pep_object.LAST + 1;
    --
   END IF;
   --
ben_icm_life_events.g_cache_pep_object(l_count_icm).elig_per_id := l_elig_per_id;
ben_icm_life_events.g_cache_pep_object(l_count_icm).effective_start_date :=l_effective_start_date;
ben_icm_life_events.g_cache_pep_object(l_count_icm).effective_end_date :=l_effective_end_date;
ben_icm_life_events.g_cache_pep_object(l_count_icm).business_group_id := p_business_group_id;
ben_icm_life_events.g_cache_pep_object(l_count_icm).ler_id := p_ler_id;
ben_icm_life_events.g_cache_pep_object(l_count_icm).pl_id := p_pl_id;
ben_icm_life_events.g_cache_pep_object(l_count_icm).plip_id := p_plip_id;
ben_icm_life_events.g_cache_pep_object(l_count_icm).ptip_id := p_ptip_id;
ben_icm_life_events.g_cache_pep_object(l_count_icm).pgm_id:= nvl(p_pgm_id,l_envpgm_id);
ben_icm_life_events.g_cache_pep_object(l_count_icm).per_in_ler_id :=l_per_in_ler_id;
ben_icm_life_events.g_cache_pep_object(l_count_icm).prtn_strt_dt :=l_prtn_strt_dt;
ben_icm_life_events.g_cache_pep_object(l_count_icm).prtn_end_dt := null;
ben_icm_life_events.g_cache_pep_object(l_count_icm).wait_perd_cmpltn_dt :=l_wait_perd_cmpltn_dt;
ben_icm_life_events.g_cache_pep_object(l_count_icm).wait_perd_strt_dt :=l_wait_perd_strt_dt;
ben_icm_life_events.g_cache_pep_object(l_count_icm).elig_flag := 'N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).comp_ref_amt :=p_comp_rec.comp_ref_amt;
ben_icm_life_events.g_cache_pep_object(l_count_icm).cmbn_age_n_los_val :=p_comp_rec.cmbn_age_n_los_val;
ben_icm_life_events.g_cache_pep_object(l_count_icm).comp_ref_uom :=p_comp_rec.comp_ref_uom;
ben_icm_life_events.g_cache_pep_object(l_count_icm).age_val :=p_comp_rec.age_val;
ben_icm_life_events.g_cache_pep_object(l_count_icm).age_uom :=p_comp_rec.age_uom;
ben_icm_life_events.g_cache_pep_object(l_count_icm).los_val :=p_comp_rec.los_val;
ben_icm_life_events.g_cache_pep_object(l_count_icm).los_uom :=p_comp_rec.los_uom;
ben_icm_life_events.g_cache_pep_object(l_count_icm).hrs_wkd_val :=p_comp_rec.hrs_wkd_val;
ben_icm_life_events.g_cache_pep_object(l_count_icm).hrs_wkd_bndry_perd_cd :=p_comp_rec.hrs_wkd_bndry_perd_cd;
ben_icm_life_events.g_cache_pep_object(l_count_icm).pct_fl_tm_val :=p_comp_rec.pct_fl_tm_val;
ben_icm_life_events.g_cache_pep_object(l_count_icm).frz_los_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).frz_age_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).frz_cmp_lvl_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).frz_pct_fl_tm_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).frz_hrs_wkd_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).frz_comb_age_and_los_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_comp_ref_amt :=p_comp_rec.rt_comp_ref_amt;
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_cmbn_age_n_los_val :=p_comp_rec.rt_cmbn_age_n_los_val;
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_comp_ref_uom :=p_comp_rec.rt_comp_ref_uom;
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_age_val :=p_comp_rec.rt_age_val;
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_age_uom :=p_comp_rec.rt_age_uom;
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_los_val :=p_comp_rec.rt_los_val;
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_los_uom :=p_comp_rec.rt_los_uom;
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_hrs_wkd_val :=p_comp_rec.rt_hrs_wkd_val;
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_hrs_wkd_bndry_perd_cd :=p_comp_rec.rt_hrs_wkd_bndry_perd_cd;
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_pct_fl_tm_val :=p_comp_rec.rt_pct_fl_tm_val;
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_frz_los_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_frz_age_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_frz_cmp_lvl_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_frz_pct_fl_tm_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_frz_hrs_wkd_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_frz_comb_age_and_los_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).once_r_cntug_cd :=p_comp_rec.once_r_cntug_cd;
ben_icm_life_events.g_cache_pep_object(l_count_icm).object_version_number := l_p_object_version_number;
ben_icm_life_events.g_cache_pep_object(l_count_icm).program_application_id :=fnd_global.prog_appl_id;
ben_icm_life_events.g_cache_pep_object(l_count_icm).program_id :=fnd_global.conc_program_id;
ben_icm_life_events.g_cache_pep_object(l_count_icm).request_id :=fnd_global.conc_request_id;
ben_icm_life_events.g_cache_pep_object(l_count_icm).program_update_date :=sysdate;
ben_icm_life_events.g_cache_pep_object(l_count_icm).p_newly_elig :=  l_newly_elig;
ben_icm_life_events.g_cache_pep_object(l_count_icm).p_newly_inelig:= l_newly_inelig;
ben_icm_life_events.g_cache_pep_object(l_count_icm).p_first_elig :=  l_first_elig;
ben_icm_life_events.g_cache_pep_object(l_count_icm).p_first_inelig := l_first_inelig;
ben_icm_life_events.g_cache_pep_object(l_count_icm).p_still_elig :=  l_still_elig;
ben_icm_life_events.g_cache_pep_object(l_count_icm).p_still_inelig:= l_still_inelig;
ben_icm_life_events.g_cache_pep_object(l_count_icm).p_datetrack_mode:= 'UPDATE';
ben_icm_life_events.g_cache_pep_object(l_count_icm).p_effective_date:= l_effective_dt;
ben_icm_life_events.g_cache_pep_object(l_count_icm).dpnt_othr_pl_cvrd_rl_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).pl_key_ee_flag := 'N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).pl_hghly_compd_flag:= 'N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).prtn_ovridn_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).no_mx_prtn_ovrid_thru_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).dstr_rstcn_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).pl_wvd_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).person_id := p_person_id;

--
END IF;
--ICM
         end if;

        hr_utility.set_location('still eligibility true ',100);
        --bug#4960082

        if p_plip_id is not null then
           open c_get_pl_id(nvl(l_fonm_cvg_strt_dt,p_effective_date));
           fetch c_get_pl_id into l_pl_id;
           close c_get_pl_id;
        end if;
        if p_pl_id is not null then
           l_pl_id := p_pl_id;
        end if;

          if (l_pl_id is not null or
              p_oipl_id is not null or
              p_pgm_id is not null) then

	     if  nvl(ben_manage_life_events.g_defer_deenrol_flag,'N') <> 'Y' then  -- Defer ENH
            ben_newly_ineligible.main
              (p_person_id         => p_person_id,
             p_pl_id             => l_pl_id,
             p_pgm_id            => nvl(p_pgm_id,l_envpgm_id),
             p_oipl_id           => p_oipl_id,
             p_business_group_id => p_business_group_id,
             p_ler_id            => p_ler_id,
             p_effective_date               => l_effective_dt);
           --  p_effective_date    => p_effective_date);
	 --
       end if;
       --

        end if;
        --
        if p_ptip_id is not null then
	 if nvl(ben_manage_life_events.g_defer_deenrol_flag,'N') <> 'Y'  then  -- Defer ENH
	    for l_rec in c_get_pl_from_ptip(nvl(l_fonm_cvg_strt_dt,p_effective_date)) loop
            ben_newly_ineligible.main
            (p_person_id         => p_person_id,
             p_pl_id             => l_rec.pl_id,
               p_pgm_id            => nvl(p_pgm_id,l_envpgm_id),
             p_oipl_id           => p_oipl_id,
             p_business_group_id => p_business_group_id,
             p_ler_id            => p_ler_id,
             p_effective_date               => l_effective_dt);
          --   p_effective_date    => p_effective_date);
            end loop;
	 --
       end if;
       --
        end if;
        return;
        --
      elsif l_elig_per_elig_flag = 'N' and p_elig_flag then  --d
        -- person is newly elig
	hr_utility.set_location('new elig',23);
        l_newly_elig := true;
        l_start_or_end := 'S';
        fnd_message.set_name('BEN','BEN_91346_ELIG_PREV_NOT_ELIG');
        benutils.write(p_text => fnd_message.get);
        --
      else
        --
        fnd_message.set_name('BEN','BEN_91392_ELIG_FLAG_ERROR');
        raise ben_manage_life_events.g_record_error;
        --
      end if; --d
      --
    end if; --a2
    --
    if g_debug then
      hr_utility.set_location('Call GSED 2 ben_determine_eligibility2.check_prev_elig', 10);
    end if;
    --
    get_start_end_dates
      (p_comp_obj_tree_row    => p_comp_obj_tree_row
      ,p_pil_row              => l_pil_rec
      ,p_effective_date       => nvl(p_lf_evt_ocrd_dt,p_effective_date)
      ,p_business_group_id    => p_business_group_id
      ,p_person_id            => p_person_id
      ,p_pl_id                => p_pl_id
      ,p_pgm_id               => p_pgm_id
      ,p_oipl_id              => p_oipl_id
      ,p_plip_id              => p_plip_id
      ,p_ptip_id              => p_ptip_id
      ,p_prev_prtn_strt_dt    => l_prev_prtn_strt_dt
      ,p_prev_prtn_end_dt     => l_prev_prtn_end_dt
      ,p_start_or_end         => l_start_or_end
      ,p_prtn_eff_strt_dt     => l_prtn_eff_strt_dt
      ,p_prtn_eff_strt_dt_cd  => l_prtn_eff_strt_dt_cd
      ,p_prtn_eff_strt_dt_rl  => l_prtn_eff_strt_dt_rl
      ,p_prtn_eff_end_dt      => l_prtn_eff_end_dt
      );
    --
    if g_debug then
      hr_utility.set_location('Done GSED 2 ben_determine_eligibility2.check_prev_elig', 10);
      --
      hr_utility.set_location('    l_prtn_eff_strt_dt : ' ||l_prtn_eff_strt_dt, 10);
      hr_utility.set_location('    l_prtn_eff_end_dt : ' ||l_prtn_eff_end_dt, 10);
    end if;
    --
    -- compute end date plus one.
    --
    if to_char(l_prtn_eff_end_dt,'DD-MM-RRRR') = '31-12-4712' then
      --
      l_end_dt_plus_one := l_prtn_eff_end_dt;
      --
    else
      --
      l_end_dt_plus_one := l_prtn_eff_end_dt+ 1;
      --
    end if;
    --
    if l_first_elig then --c
      --
	hr_utility.set_location ('first elig',121);
      if instr(ben_manage_life_events.g_output_string,
               'Elg:') = 0 then
        --
        ben_manage_life_events.g_output_string :=
          ben_manage_life_events.g_output_string||
          'Elg: Yes '||
          'Rsn: FTIME Elig';
        --
      end if;
      --
      -- If a waiting period applies, get the date when participation will begin
      -- after the waiting period ends.
      --
      if l_wait_perd_cmpltn_dt is not null then
        --
        -- Apply the participation start date code to the l_wait_perd_cmpltn_dt
        --
        l_prtn_st_dt_aftr_wtg :=
          ben_determine_eligibility3.get_prtn_st_dt_aftr_wtg
            (p_person_id           => p_person_id,
             p_effective_date      => p_effective_date,
             p_business_group_id   => p_business_group_id,
             p_prtn_eff_strt_dt_cd => l_prtn_eff_strt_dt_cd,
             p_prtn_eff_strt_dt_rl => l_prtn_eff_strt_dt_rl,
             p_wtg_perd_cmpltn_dt  => l_wait_perd_cmpltn_dt,
             p_pl_id               => p_pl_id,
             p_pl_typ_id           => l_pl_rec.pl_typ_id,
             p_pgm_id              => p_pgm_id,
             p_oipl_id             => p_oipl_id,
             p_plip_id             => p_plip_id,
             p_ptip_id             => p_ptip_id,
             p_opt_id              => l_oipl_rec.opt_id);
        --
        -- Use the later of the l_after_wtg_prtn_dt and l_prtn_eff_strt_dt
        -- for the participation start date.
        --
        l_prtn_eff_strt_dt :=
          greatest(nvl(l_prtn_st_dt_aftr_wtg,hr_api.g_sot),l_prtn_eff_strt_dt);
        --
      end if;
      --
      hr_utility.set_location('Using prtn_eff_strt_dt : ' ||
                              l_prtn_eff_strt_dt, 10);
      --
      if (p_pgm_id is not null or l_envpgm_id is not null) and
        p_pl_id is not null then
        --
        open c_plip_ordr(nvl(l_fonm_cvg_strt_dt,p_effective_date));
          --
          fetch c_plip_ordr into l_plan_ordr_num;
          --
        close c_plip_ordr;
        --
      elsif p_pgm_id is null and l_envpgm_id is null and
        p_pl_id is not null then
        --
        l_plan_ordr_num := l_pl_rec.ordr_num;
        --
      end if;
      --
      if g_debug then
        hr_utility.set_location('l_prtn_eff_strt_dt -> '||l_prtn_eff_strt_dt, 123);
        hr_utility.set_location('ben_determine_eligibility2.check_prev_elig Fir El Cre PEP ', 10);
      end if;
      --
      l_elig_flag    := 'Y';
      l_prtn_strt_dt := l_prtn_eff_strt_dt;
      --
      ben_Eligible_Person_perf_api.create_perf_Eligible_Person
        (p_validate                     => FALSE,
         p_elig_per_id                  => l_elig_per_id,
         p_effective_start_date         => l_effective_start_date,
         p_effective_end_date           => l_effective_end_date,
         p_business_group_id            => p_business_group_id,
         p_pl_id                        => p_pl_id,
         p_plip_id                      => p_plip_id,
         p_ptip_id                      => p_ptip_id,
         p_pgm_id                       => nvl(p_pgm_id,l_envpgm_id),
         p_ler_id                       => p_ler_id,
         p_person_id                    => p_person_id,
         p_per_in_ler_id                => l_per_in_ler_id,
         p_dpnt_othr_pl_cvrd_rl_flag    => 'N',
         p_pl_key_ee_flag               => 'N',
         p_pl_hghly_compd_flag          => 'N',
         p_prtn_ovridn_flag             => 'N',
         p_prtn_ovridn_thru_dt          => null,
         p_no_mx_prtn_ovrid_thru_flag   => 'N',
         p_prtn_strt_dt                 => l_prtn_strt_dt,
         p_dstr_rstcn_flag              => 'N',
         p_pl_wvd_flag                  => 'N',
         p_wait_perd_cmpltn_dt          => l_wait_perd_cmpltn_dt,
         p_wait_perd_strt_dt            => l_wait_perd_strt_dt,
         p_elig_flag                    => l_elig_flag,
         p_comp_ref_amt                 => p_comp_rec.comp_ref_amt,
         p_cmbn_age_n_los_val           => p_comp_rec.cmbn_age_n_los_val,
         p_comp_ref_uom                 => p_comp_rec.comp_ref_uom,
         p_age_val                      => p_comp_rec.age_val,
         p_age_uom                      => p_comp_rec.age_uom,
         p_los_val                      => p_comp_rec.los_val,
         p_los_uom                      => p_comp_rec.los_uom,
         p_hrs_wkd_val                  => p_comp_rec.hrs_wkd_val,
         p_hrs_wkd_bndry_perd_cd        => p_comp_rec.hrs_wkd_bndry_perd_cd,
         p_pct_fl_tm_val                => p_comp_rec.pct_fl_tm_val,
         p_frz_los_flag                 => 'N',
         p_frz_age_flag                 => 'N',
         p_frz_cmp_lvl_flag             => 'N',
         p_frz_pct_fl_tm_flag           => 'N',
         p_frz_hrs_wkd_flag             => 'N',
         p_frz_comb_age_and_los_flag    => 'N',
         p_rt_comp_ref_amt              => p_comp_rec.rt_comp_ref_amt,
         p_rt_cmbn_age_n_los_val        => p_comp_rec.rt_cmbn_age_n_los_val,
         p_rt_comp_ref_uom              => p_comp_rec.rt_comp_ref_uom,
         p_rt_age_val                   => p_comp_rec.rt_age_val,
         p_rt_age_uom                   => p_comp_rec.rt_age_uom,
         p_rt_los_val                   => p_comp_rec.rt_los_val,
         p_rt_los_uom                   => p_comp_rec.rt_los_uom,
         p_rt_hrs_wkd_val               => p_comp_rec.rt_hrs_wkd_val,
         p_rt_hrs_wkd_bndry_perd_cd     => p_comp_rec.rt_hrs_wkd_bndry_perd_cd,
         p_rt_pct_fl_tm_val             => p_comp_rec.rt_pct_fl_tm_val,
         p_rt_frz_los_flag              => 'N',
         p_rt_frz_age_flag              => 'N',
         p_rt_frz_cmp_lvl_flag          => 'N',
         p_rt_frz_pct_fl_tm_flag        => 'N',
         p_rt_frz_hrs_wkd_flag          => 'N',
         p_rt_frz_comb_age_and_los_flag => 'N',
         p_once_r_cntug_cd              => p_comp_rec.once_r_cntug_cd,
         p_pl_ordr_num                  => l_plan_ordr_num,
         p_plip_ordr_num                => l_plip_rec.ordr_num,
         p_ptip_ordr_num                => l_ptip_rec.ordr_num,
         p_object_version_number        => l_object_version_number,
         --
         -- Bugs : 1412882, part of bug 1412951
         --
         p_effective_date               => l_effective_dt,
         -- p_effective_date               => p_effective_date,
         p_program_application_id       => fnd_global.prog_appl_id,
         p_program_id                   => fnd_global.conc_program_id,
         p_request_id                   => fnd_global.conc_request_id,
         p_program_update_date          => sysdate
         --
         -- Bypass insert validate validation for performance
         --
        ,p_override_validation          => TRUE);
      --
--ICM
IF nvl(l_env_rec.mode_cd,'~') = 'D' THEN
hr_utility.set_location('Building PEP2',214);
   IF NOT ben_icm_life_events.g_cache_pep_object.EXISTS(1) THEN
      --
      l_count_icm  := 1;
    --
    ELSE
      --
      l_count_icm  := ben_icm_life_events.g_cache_pep_object.LAST + 1;
    --
    END IF;
   --
ben_icm_life_events.g_cache_pep_object(l_count_icm).elig_per_id := l_elig_per_id;
ben_icm_life_events.g_cache_pep_object(l_count_icm).effective_start_date :=l_effective_start_date;
ben_icm_life_events.g_cache_pep_object(l_count_icm).effective_end_date :=l_effective_end_date;
ben_icm_life_events.g_cache_pep_object(l_count_icm).business_group_id := p_business_group_id;
ben_icm_life_events.g_cache_pep_object(l_count_icm).pl_id :=p_pl_id;
ben_icm_life_events.g_cache_pep_object(l_count_icm).plip_id :=p_plip_id;
ben_icm_life_events.g_cache_pep_object(l_count_icm).ptip_id :=p_ptip_id;
ben_icm_life_events.g_cache_pep_object(l_count_icm).pgm_id:=nvl(p_pgm_id,l_envpgm_id);
ben_icm_life_events.g_cache_pep_object(l_count_icm).ler_id :=p_ler_id;
ben_icm_life_events.g_cache_pep_object(l_count_icm).person_id :=p_person_id;
ben_icm_life_events.g_cache_pep_object(l_count_icm).per_in_ler_id :=l_per_in_ler_id;
ben_icm_life_events.g_cache_pep_object(l_count_icm).dpnt_othr_pl_cvrd_rl_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).prtn_ovridn_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).prtn_ovridn_thru_dt := null;
ben_icm_life_events.g_cache_pep_object(l_count_icm).no_mx_prtn_ovrid_thru_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).prtn_strt_dt :=l_prtn_strt_dt;
ben_icm_life_events.g_cache_pep_object(l_count_icm).dstr_rstcn_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).pl_wvd_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).pl_key_ee_flag := 'N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).wait_perd_cmpltn_dt :=l_wait_perd_cmpltn_dt;
ben_icm_life_events.g_cache_pep_object(l_count_icm).wait_perd_strt_dt :=l_wait_perd_strt_dt;
ben_icm_life_events.g_cache_pep_object(l_count_icm).elig_flag :=l_elig_flag;
ben_icm_life_events.g_cache_pep_object(l_count_icm).comp_ref_amt :=p_comp_rec.comp_ref_amt;
ben_icm_life_events.g_cache_pep_object(l_count_icm).cmbn_age_n_los_val :=p_comp_rec.cmbn_age_n_los_val;
ben_icm_life_events.g_cache_pep_object(l_count_icm).comp_ref_uom :=p_comp_rec.comp_ref_uom;
ben_icm_life_events.g_cache_pep_object(l_count_icm).age_val :=p_comp_rec.age_val;
ben_icm_life_events.g_cache_pep_object(l_count_icm).age_uom :=p_comp_rec.age_uom;
ben_icm_life_events.g_cache_pep_object(l_count_icm).los_val :=p_comp_rec.los_val;
ben_icm_life_events.g_cache_pep_object(l_count_icm).los_uom :=p_comp_rec.los_uom;
ben_icm_life_events.g_cache_pep_object(l_count_icm).hrs_wkd_val :=p_comp_rec.hrs_wkd_val;
ben_icm_life_events.g_cache_pep_object(l_count_icm).hrs_wkd_bndry_perd_cd :=p_comp_rec.hrs_wkd_bndry_perd_cd;
ben_icm_life_events.g_cache_pep_object(l_count_icm).pct_fl_tm_val :=p_comp_rec.pct_fl_tm_val;
ben_icm_life_events.g_cache_pep_object(l_count_icm).frz_los_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).frz_age_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).frz_cmp_lvl_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).frz_pct_fl_tm_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).frz_hrs_wkd_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).frz_comb_age_and_los_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_comp_ref_amt :=p_comp_rec.rt_comp_ref_amt;
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_cmbn_age_n_los_val :=p_comp_rec.rt_cmbn_age_n_los_val;
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_comp_ref_uom :=p_comp_rec.rt_comp_ref_uom;
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_age_val :=p_comp_rec.rt_age_val;
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_age_uom :=p_comp_rec.rt_age_uom;
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_los_val :=p_comp_rec.rt_los_val;
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_los_uom :=p_comp_rec.rt_los_uom;
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_hrs_wkd_val :=p_comp_rec.rt_hrs_wkd_val;
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_hrs_wkd_bndry_perd_cd :=p_comp_rec.rt_hrs_wkd_bndry_perd_cd;
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_pct_fl_tm_val :=p_comp_rec.rt_pct_fl_tm_val;
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_frz_los_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_frz_age_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_frz_cmp_lvl_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_frz_pct_fl_tm_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_frz_hrs_wkd_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_frz_comb_age_and_los_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).once_r_cntug_cd :=p_comp_rec.once_r_cntug_cd;
ben_icm_life_events.g_cache_pep_object(l_count_icm).pl_ordr_num :=l_plan_ordr_num;
ben_icm_life_events.g_cache_pep_object(l_count_icm).plip_ordr_num := l_plip_rec.ordr_num;
ben_icm_life_events.g_cache_pep_object(l_count_icm).ptip_ordr_num := l_ptip_rec.ordr_num;
ben_icm_life_events.g_cache_pep_object(l_count_icm).object_version_number := l_object_version_number;
ben_icm_life_events.g_cache_pep_object(l_count_icm).program_application_id :=fnd_global.prog_appl_id;
ben_icm_life_events.g_cache_pep_object(l_count_icm).program_id := fnd_global.conc_program_id;
ben_icm_life_events.g_cache_pep_object(l_count_icm).request_id := fnd_global.conc_request_id;
ben_icm_life_events.g_cache_pep_object(l_count_icm).program_update_date :=sysdate;
ben_icm_life_events.g_cache_pep_object(l_count_icm).p_newly_elig :=  l_newly_elig;
ben_icm_life_events.g_cache_pep_object(l_count_icm).p_newly_inelig:= l_newly_inelig;
ben_icm_life_events.g_cache_pep_object(l_count_icm).p_first_elig :=  l_first_elig;
ben_icm_life_events.g_cache_pep_object(l_count_icm).p_first_inelig:= l_first_inelig;
ben_icm_life_events.g_cache_pep_object(l_count_icm).p_still_elig :=  l_still_elig;
ben_icm_life_events.g_cache_pep_object(l_count_icm).p_still_inelig:= l_still_inelig;
ben_icm_life_events.g_cache_pep_object(l_count_icm).p_effective_date:= l_effective_dt;
ben_icm_life_events.g_cache_pep_object(l_count_icm).pl_hghly_compd_flag:= 'N';
--
END IF;
--ICM
      if g_debug then
        hr_utility.set_location('ben_determine_eligibility2.check_prev_elig Dn Cre PEP Fir El ', 10);
      end if;
        --
      if p_score_tab.count > 0 then
         hr_utility.set_location('writing score records ',5.5);
         ben_elig_scre_wtg_api.load_score_weight
         (p_validate              => false
         ,p_score_tab             => p_score_tab
         ,p_per_in_ler_id         => l_per_in_ler_id    /* Bug 4438430 */
         ,p_effective_date        => l_effective_dt
         ,p_elig_per_id           => l_elig_per_id);
      end if;
    elsif l_still_elig then --c
      --
      hr_utility.set_location('ben_determine_eligibility2.check_prev_elig l_still_elig ', 10);
      if instr(ben_manage_life_events.g_output_string,
               'Elg:') = 0 then
        --
        ben_manage_life_events.g_output_string :=
          ben_manage_life_events.g_output_string||
          'Elg: Yes '||
          'Rsn: Prev Elig';
        --
      end if;
      --
      -- if the previous row's start date is greater than or equal the computed
      -- start date, then they never really became ineligible.  Go find
      -- another start elig date to use.
      --
      hr_utility.set_location('ben_determine_eligibility2.check_prev_elig DTAPI_FDUM ', 10);
      dt_api.find_dt_upd_modes
        (-- p_effective_date       => p_effective_date,
         --
         -- Bugs : 1412882, part of bug 1412951
         --
         p_effective_date               => l_effective_dt,
         --
         p_base_table_name      => 'BEN_ELIG_PER_F',
         p_base_key_column      => 'elig_per_id',
         p_base_key_value       => l_elig_per_id,
         p_correction           => l_correction,
         p_update               => l_update,
         p_update_override      => l_update_override,
         p_update_change_insert => l_update_change_insert);
      hr_utility.set_location('ben_determine_eligibility2.check_prev_elig Dn DTAPI_FDUM ', 10);
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
      -- If a waiting period applies, get the date when participation will begin
      -- after the waiting period ends.
      --
      if l_wait_perd_cmpltn_dt is not null then
        --
        -- Apply the participation start date code to the l_wait_perd_cmpltn_dt
        --
        hr_utility.set_location('ben_determine_eligibility2.check_prev_elig GET_PSDAWTG ', 10);
        l_prtn_st_dt_aftr_wtg :=
          ben_determine_eligibility3.get_prtn_st_dt_aftr_wtg
            (p_person_id           => p_person_id,
             p_effective_date      => p_effective_date,
             p_business_group_id   => p_business_group_id,
             p_prtn_eff_strt_dt_cd => l_prtn_eff_strt_dt_cd,
             p_prtn_eff_strt_dt_rl => l_prtn_eff_strt_dt_rl,
             p_wtg_perd_cmpltn_dt  => l_wait_perd_cmpltn_dt,
             p_pl_id               => p_pl_id,
             p_pl_typ_id           => l_pl_rec.pl_typ_id,
             p_pgm_id              => p_pgm_id,
             p_oipl_id             => p_oipl_id,
             p_plip_id             => p_plip_id,
             p_ptip_id             => p_ptip_id,
             p_opt_id              => l_oipl_rec.opt_id);
        hr_utility.set_location('ben_determine_eligibility2.check_prev_elig GET_PSDAWTG ', 10);
        --
        -- Use the later of the l_after_wtg_prtn_dt and l_prtn_eff_strt_dt
        -- for the participation start date.
        --
        l_prtn_eff_strt_dt := greatest(nvl(l_prtn_st_dt_aftr_wtg, hr_api.g_sot)
                                      ,l_prtn_eff_strt_dt);
        --
      end if;
      --
      hr_utility.set_location('Using prtn_eff_strt_dt : ' ||
                              l_prtn_eff_strt_dt, 10);
      --
      hr_utility.set_location('Still El Upd PEP  ben_determine_eligibility2.check_prev_elig', 10);
       hr_utility.set_location('elig per id'||l_elig_per_id,111);
       hr_utility.set_location('object version number'||l_object_version_number,112);
      --
      l_elig_flag    := 'Y';
      l_prtn_strt_dt := l_prtn_eff_strt_dt;
      --
      --
       hr_utility.set_location('SARKAR l_per_in_ler_id'||l_per_in_ler_id,112);
       hr_utility.set_location('SARKAR l_prev_per_in_ler_id'|| l_prev_per_in_ler_id,112);
        hr_utility.set_location('SARKAR p_ler_id '|| p_ler_id,112);
      IF l_datetrack_mode = hr_api.g_correction AND
           l_per_in_ler_id <> NVL(l_prev_per_in_ler_id,-1) THEN
          --
          ben_determine_eligibility3.save_to_restore
          (p_current_per_in_ler_id   => l_per_in_ler_id
          ,p_per_in_ler_id          => l_prev_per_in_ler_id
          ,p_elig_per_id            => l_elig_per_id
          ,p_elig_per_opt_id        => NULL
          ,p_effective_date         => l_effective_dt
          );
          --
      END IF;
/* Bug 9020962: If future eligibility record exists, then insert the record
	   in backup table ben_le_clsn_n_rstr */
      IF (l_datetrack_mode = hr_api.g_update_override) AND
           l_per_in_ler_id <> NVL(l_prev_per_in_ler_id,-1) THEN
          --
             open c_prev_pil(p_pil_row.per_in_ler_id);
	     fetch c_prev_pil into l_prev_pil_id;
	     close c_prev_pil;
             hr_utility.set_location('l_prev_pil_id ' || l_prev_pil_id, 7777);

	     open c_elig_rec(l_elig_per_id,l_prev_per_in_ler_id);
             fetch c_elig_rec into l_elig_per_rec;
	     close c_elig_rec;
	     open c_elig_per_id(l_prev_pil_id,
                      l_elig_per_rec.pl_id,
		      l_elig_per_rec.pgm_id,
		      l_elig_per_rec.ptip_id,
		      l_elig_per_rec.plip_id,
		      p_effective_date);
	     fetch c_elig_per_id into l_ftr_elig_per_rec;
	     close c_elig_per_id;

             if(l_ftr_elig_per_rec.elig_per_id is not null) then
		ben_determine_eligibility3.save_to_restore
			  (p_current_per_in_ler_id   => l_per_in_ler_id
			  ,p_per_in_ler_id          => l_prev_pil_id
			  ,p_elig_per_id            => l_ftr_elig_per_rec.elig_per_id
			  ,p_elig_per_opt_id        => NULL
			  ,p_effective_date         => l_ftr_elig_per_rec.effective_start_date
			  );
	     else
	         ben_determine_eligibility3.save_to_restore
		  (p_current_per_in_ler_id   => l_per_in_ler_id
		  ,p_per_in_ler_id          => l_prev_per_in_ler_id
		  ,p_elig_per_id            => l_elig_per_id
		  ,p_elig_per_opt_id        => NULL
		  ,p_effective_date         => l_effective_dt
		  );
	     end if;
          --
      END IF;
      /* End of Bug 9020962 */
      --
       hr_utility.set_location('SARKAR updating pep with l_per_in_ler_id'||l_per_in_ler_id,112);
      --
      l_p_object_version_number := l_object_version_number;
      --
      ben_Eligible_Person_perf_api.update_perf_Eligible_Person
        (p_validate                     => FALSE,
         p_elig_per_id                  => l_elig_per_id,
         p_per_in_ler_id                => l_per_in_ler_id,
         p_effective_start_date         => l_effective_start_date,
         p_effective_end_date           => l_effective_end_date,
         p_elig_flag                    => l_elig_flag,
         p_prtn_strt_dt                 => l_prtn_strt_dt,
         p_prtn_end_dt                  => null,
	 p_ler_id                       => p_ler_id,  -- bug 5478994
         p_rt_comp_ref_amt              => p_comp_rec.rt_comp_ref_amt,
         p_rt_cmbn_age_n_los_val        => p_comp_rec.rt_cmbn_age_n_los_val,
         p_rt_comp_ref_uom              => p_comp_rec.rt_comp_ref_uom,
         p_rt_age_val                   => p_comp_rec.rt_age_val,
         p_rt_los_val                   => p_comp_rec.rt_los_val,
         p_rt_hrs_wkd_val               => p_comp_rec.rt_hrs_wkd_val,
         p_rt_hrs_wkd_bndry_perd_cd     => p_comp_rec.rt_hrs_wkd_bndry_perd_cd,
         p_rt_age_uom                   => p_comp_rec.rt_age_uom,
         p_rt_los_uom                   => p_comp_rec.rt_los_uom,
         p_rt_pct_fl_tm_val             => p_comp_rec.rt_pct_fl_tm_val,
         p_rt_frz_los_flag              => 'N',
         p_rt_frz_age_flag              => 'N',
         p_rt_frz_cmp_lvl_flag          => 'N',
         p_rt_frz_pct_fl_tm_flag        => 'N',
         p_rt_frz_hrs_wkd_flag          => 'N',
         p_rt_frz_comb_age_and_los_flag => 'N',
         p_once_r_cntug_cd              => p_comp_rec.once_r_cntug_cd,
         p_comp_ref_amt                 => p_comp_rec.comp_ref_amt,
         p_cmbn_age_n_los_val           => p_comp_rec.cmbn_age_n_los_val,
         p_comp_ref_uom                 => p_comp_rec.comp_ref_uom,
         p_age_val                      => p_comp_rec.age_val,
         p_los_val                      => p_comp_rec.los_val,
         p_hrs_wkd_val                  => p_comp_rec.hrs_wkd_val,
         p_hrs_wkd_bndry_perd_cd        => p_comp_rec.hrs_wkd_bndry_perd_cd,
         p_age_uom                      => p_comp_rec.age_uom,
         p_los_uom                      => p_comp_rec.los_uom,
         p_pct_fl_tm_val                => p_comp_rec.pct_fl_tm_val,
         p_frz_los_flag                 => 'N',
         p_frz_age_flag                 => 'N',
         p_frz_cmp_lvl_flag             => 'N',
         p_frz_pct_fl_tm_flag           => 'N',
         p_frz_hrs_wkd_flag             => 'N',
         p_frz_comb_age_and_los_flag    => 'N',
         p_wait_perd_cmpltn_dt          => l_wait_perd_cmpltn_dt,
         p_wait_perd_strt_dt            => l_wait_perd_strt_dt,
         p_object_version_number        => l_object_version_number,
         --
         -- Bugs : 1412882, part of bug 1412951
         --
         p_effective_date               => l_effective_dt,
         -- p_effective_date               => p_effective_date,
         p_datetrack_mode               => l_datetrack_mode,
         p_program_application_id       => fnd_global.prog_appl_id,
         p_program_id                   => fnd_global.conc_program_id,
         p_request_id                   => fnd_global.conc_request_id,
         p_program_update_date          => sysdate);
--ICM
IF nvl(l_env_rec.mode_cd,'~') = 'D' THEN
 --
hr_utility.set_location('Building PEP3',214);
 --
 IF NOT ben_icm_life_events.g_cache_pep_object.EXISTS(1) THEN
      --
      l_count_icm  := 1;
    --
    ELSE
      --
      l_count_icm  := ben_icm_life_events.g_cache_pep_object.LAST + 1;
    --
 END IF;
   --
ben_icm_life_events.g_cache_pep_object(l_count_icm).elig_per_id := l_elig_per_id;
ben_icm_life_events.g_cache_pep_object(l_count_icm).effective_start_date := l_effective_start_date;
ben_icm_life_events.g_cache_pep_object(l_count_icm).effective_end_date := l_effective_end_date;
ben_icm_life_events.g_cache_pep_object(l_count_icm).business_group_id := p_business_group_id;
ben_icm_life_events.g_cache_pep_object(l_count_icm).pl_id := p_pl_id;
ben_icm_life_events.g_cache_pep_object(l_count_icm).ler_id := p_ler_id;
ben_icm_life_events.g_cache_pep_object(l_count_icm).per_in_ler_id := l_per_in_ler_id;
ben_icm_life_events.g_cache_pep_object(l_count_icm).prtn_strt_dt := l_prtn_strt_dt;
ben_icm_life_events.g_cache_pep_object(l_count_icm).prtn_end_dt := null;
ben_icm_life_events.g_cache_pep_object(l_count_icm).wait_perd_cmpltn_dt := l_wait_perd_cmpltn_dt;
ben_icm_life_events.g_cache_pep_object(l_count_icm).wait_perd_strt_dt := l_wait_perd_strt_dt;
ben_icm_life_events.g_cache_pep_object(l_count_icm).elig_flag := l_elig_flag;
ben_icm_life_events.g_cache_pep_object(l_count_icm).comp_ref_amt := p_comp_rec.comp_ref_amt;
ben_icm_life_events.g_cache_pep_object(l_count_icm).cmbn_age_n_los_val := p_comp_rec.rt_cmbn_age_n_los_val;
ben_icm_life_events.g_cache_pep_object(l_count_icm).comp_ref_uom := p_comp_rec.comp_ref_uom;
ben_icm_life_events.g_cache_pep_object(l_count_icm).age_val := p_comp_rec.age_val;
ben_icm_life_events.g_cache_pep_object(l_count_icm).age_uom := p_comp_rec.age_uom;
ben_icm_life_events.g_cache_pep_object(l_count_icm).los_val := p_comp_rec.los_val;
ben_icm_life_events.g_cache_pep_object(l_count_icm).los_uom := p_comp_rec.los_uom;
ben_icm_life_events.g_cache_pep_object(l_count_icm).hrs_wkd_val := p_comp_rec.hrs_wkd_val;
ben_icm_life_events.g_cache_pep_object(l_count_icm).hrs_wkd_bndry_perd_cd := p_comp_rec.hrs_wkd_bndry_perd_cd;
ben_icm_life_events.g_cache_pep_object(l_count_icm).pct_fl_tm_val := p_comp_rec.pct_fl_tm_val;
ben_icm_life_events.g_cache_pep_object(l_count_icm).frz_los_flag := 'N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).frz_age_flag :=  'N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).frz_cmp_lvl_flag := 'N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).frz_pct_fl_tm_flag := 'N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).frz_hrs_wkd_flag := 'N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).frz_comb_age_and_los_flag := 'N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_comp_ref_amt := p_comp_rec.rt_comp_ref_amt;
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_cmbn_age_n_los_val := p_comp_rec.rt_cmbn_age_n_los_val;
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_comp_ref_uom := p_comp_rec.rt_comp_ref_uom;
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_age_val := p_comp_rec.rt_age_val;
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_age_uom := p_comp_rec.rt_age_uom;
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_los_val := p_comp_rec.rt_los_val;
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_los_uom := p_comp_rec.rt_los_uom;
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_hrs_wkd_val := p_comp_rec.rt_hrs_wkd_val;
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_hrs_wkd_bndry_perd_cd := p_comp_rec.rt_hrs_wkd_bndry_perd_cd;
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_pct_fl_tm_val := p_comp_rec.rt_pct_fl_tm_val;
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_frz_los_flag := 'N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_frz_age_flag := 'N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_frz_cmp_lvl_flag := 'N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_frz_pct_fl_tm_flag := 'N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_frz_hrs_wkd_flag := 'N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_frz_comb_age_and_los_flag := 'N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).once_r_cntug_cd := p_comp_rec.once_r_cntug_cd;
ben_icm_life_events.g_cache_pep_object(l_count_icm).object_version_number := l_p_object_version_number;
ben_icm_life_events.g_cache_pep_object(l_count_icm).program_application_id :=fnd_global.prog_appl_id;
ben_icm_life_events.g_cache_pep_object(l_count_icm).program_id :=fnd_global.conc_program_id;
ben_icm_life_events.g_cache_pep_object(l_count_icm).request_id :=fnd_global.conc_request_id;
ben_icm_life_events.g_cache_pep_object(l_count_icm).program_update_date :=sysdate;
ben_icm_life_events.g_cache_pep_object(l_count_icm).p_newly_elig :=  l_newly_elig;
ben_icm_life_events.g_cache_pep_object(l_count_icm).p_newly_inelig:= l_newly_inelig;
ben_icm_life_events.g_cache_pep_object(l_count_icm).p_first_elig :=  l_first_elig;
ben_icm_life_events.g_cache_pep_object(l_count_icm).p_first_inelig := l_first_inelig;
ben_icm_life_events.g_cache_pep_object(l_count_icm).p_still_elig :=  l_still_elig;
ben_icm_life_events.g_cache_pep_object(l_count_icm).p_still_inelig:= l_still_inelig;
ben_icm_life_events.g_cache_pep_object(l_count_icm).p_effective_date := l_effective_dt;
ben_icm_life_events.g_cache_pep_object(l_count_icm).p_datetrack_mode:= l_datetrack_mode;
ben_icm_life_events.g_cache_pep_object(l_count_icm).dpnt_othr_pl_cvrd_rl_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).pl_key_ee_flag := 'N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).pl_hghly_compd_flag:= 'N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).prtn_ovridn_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).no_mx_prtn_ovrid_thru_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).dstr_rstcn_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).pl_wvd_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).person_id := p_person_id;
--
END IF;
      hr_utility.set_location('Dn Still El Upd PEP  ben_determine_eligibility2.check_prev_elig', 10);
      --
      if p_score_tab.count > 0 then
         hr_utility.set_location('writing score records ',5.5);
         ben_elig_scre_wtg_api.load_score_weight
         (p_validate              => false
         ,p_score_tab             => p_score_tab
         ,p_per_in_ler_id         => l_per_in_ler_id    /* Bug 4438430 */
         ,p_effective_date        => l_effective_dt
         ,p_elig_per_id           => l_elig_per_id);
      end if;
    elsif l_newly_elig then --c
      --
       hr_utility.set_location('newly eligible',23);
       --
       l_p_object_version_number := l_object_version_number;
       --
      if instr(ben_manage_life_events.g_output_string,
               'Elg:') = 0 then
        --
       ben_manage_life_events.g_output_string :=
          ben_manage_life_events.g_output_string||
          'Elg: Yes '||
          'Rsn: Prev InElig';
        --
      end if;
      --
      -- if the previous row's start date is greater than or equal the computed
      -- start date, then they never really became ineligible.  Go find
      -- another start elig date to use.
      --
      if l_prev_prtn_strt_dt >= l_prtn_eff_strt_dt then          --p
        --
        -- Check for an existing eligible record where our computed start
        -- date falls between existing records start and end dates.
        -- If there is one, then the person never really lost eligiblity
        -- and we need to use the old start date.
        --
        open c_overlap (c_prtn_eff_strt_dt => l_prtn_eff_strt_dt
                       ,c_elig_flag        => 'Y'
                       ,c_add_one          => 1);
          --
          fetch c_overlap into l_overlap;
          --
        close c_overlap;
        --
        if l_overlap.prtn_strt_dt is not null then
          --
          -- Use old records start date
          --
          l_prtn_eff_strt_dt := l_overlap.prtn_strt_dt;
          --
        end if;
        --
      else
        --
        -- if the previous row's start date is less than the computed
        -- start date,
        -- Call API to Update old inelig record with end date of computed
        -- start date - 1 (correction) unless the old inelig record has a
        -- start date greater than our computed start date.
        --
         hr_utility.set_location('elig per id'||l_elig_per_id,211);
       hr_utility.set_location('object version number'||l_object_version_number,212);
        ben_Eligible_Person_perf_api.update_perf_Eligible_Person
          (p_validate                   => FALSE,
           p_elig_per_id                => l_elig_per_id,
           p_effective_start_date       => l_effective_start_date,
           p_effective_end_date         => l_effective_end_date,
           p_prtn_end_dt                => (l_prtn_eff_strt_dt -1),
           p_object_version_number      => l_object_version_number,
           p_effective_date             => l_effective_dt,  -- 4947426
           p_datetrack_mode             => hr_api.g_correction,
           p_program_application_id     => fnd_global.prog_appl_id,
           p_program_id                 => fnd_global.conc_program_id,
           p_request_id                 => fnd_global.conc_request_id,
           p_program_update_date        => sysdate);
          --
      end if;  --p
      --
      -- Then call in update mode to create a new elig record with
      -- computed start date.
      --
      dt_api.find_dt_upd_modes
        (-- p_effective_date       => p_effective_date,
         --
         -- Bugs : 1412882, part of bug 1412951
         --
         p_effective_date               => l_effective_dt,
         --
         p_base_table_name      => 'BEN_ELIG_PER_F',
         p_base_key_column      => 'elig_per_id',
         p_base_key_value       => l_elig_per_id,
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
      -- If a waiting period applies, get the date when participation will begin
      -- after the waiting period ends.
      --
      if l_wait_perd_cmpltn_dt is not null then
        --
        -- Apply the participation start date code to the l_wait_perd_cmpltn_dt
        --
        l_prtn_st_dt_aftr_wtg :=
          ben_determine_eligibility3.get_prtn_st_dt_aftr_wtg
            (p_person_id           => p_person_id,
             p_effective_date      => p_effective_date,
             p_business_group_id   => p_business_group_id,
             p_prtn_eff_strt_dt_cd => l_prtn_eff_strt_dt_cd,
             p_prtn_eff_strt_dt_rl => l_prtn_eff_strt_dt_rl,
             p_wtg_perd_cmpltn_dt  => l_wait_perd_cmpltn_dt,
             p_pl_id               => p_pl_id,
             p_pl_typ_id           => l_pl_rec.pl_typ_id,
             p_pgm_id              => p_pgm_id,
             p_oipl_id             => p_oipl_id,
             p_plip_id             => p_plip_id,
             p_ptip_id             => p_ptip_id,
             p_opt_id              => l_oipl_rec.opt_id);
        --
        -- Use the later of the l_after_wtg_prtn_dt and l_prtn_eff_strt_dt
        -- for the participation start date.
        --
        l_prtn_eff_strt_dt := greatest(nvl(l_prtn_st_dt_aftr_wtg, hr_api.g_sot)
                                      ,l_prtn_eff_strt_dt);
        --
      end if;
      --
      hr_utility.set_location('Using prtn_eff_strt_dt : ' ||
                              l_prtn_eff_strt_dt, 10);
      --
      hr_utility.set_location('New El Upd PEP  ben_determine_eligibility2.check_prev_elig', 10);
      hr_utility.set_location('elig per id'||l_elig_per_id,311);
       hr_utility.set_location('object version number'||l_object_version_number,312);
      --
      l_elig_flag    := 'Y';
      l_prtn_strt_dt := l_prtn_eff_strt_dt;
      --
      --
      IF l_datetrack_mode = hr_api.g_correction AND
           l_per_in_ler_id <> NVL(l_prev_per_in_ler_id,-1) THEN
          --
          ben_determine_eligibility3.save_to_restore
          (p_current_per_in_ler_id   => l_per_in_ler_id
          ,p_per_in_ler_id          => l_prev_per_in_ler_id
          ,p_elig_per_id            => l_elig_per_id
          ,p_elig_per_opt_id        => NULL
          ,p_effective_date         => l_effective_dt
          );
       end if;

      /* Bug 9020962: If future eligibility record exists, then insert the record
	   in backup table ben_le_clsn_n_rstr */
      IF (l_datetrack_mode = hr_api.g_update_override) AND
           l_per_in_ler_id <> NVL(l_prev_per_in_ler_id,-1) THEN
          --
             open c_prev_pil(p_pil_row.per_in_ler_id);
	     fetch c_prev_pil into l_prev_pil_id;
	     close c_prev_pil;
             hr_utility.set_location('l_prev_pil_id ' || l_prev_pil_id, 7778);

	     open c_elig_rec(l_elig_per_id,l_prev_per_in_ler_id);
             fetch c_elig_rec into l_elig_per_rec;
	     close c_elig_rec;
	     open c_elig_per_id(l_prev_pil_id,
                      l_elig_per_rec.pl_id,
		      l_elig_per_rec.pgm_id,
		      l_elig_per_rec.ptip_id,
		      l_elig_per_rec.plip_id,
		      p_effective_date);
	     fetch c_elig_per_id into l_ftr_elig_per_rec;
	     close c_elig_per_id;
             if(l_ftr_elig_per_rec.elig_per_id is not null) then
		ben_determine_eligibility3.save_to_restore
			  (p_current_per_in_ler_id   => l_per_in_ler_id
			  ,p_per_in_ler_id          => l_prev_pil_id
			  ,p_elig_per_id            => l_ftr_elig_per_rec.elig_per_id
			  ,p_elig_per_opt_id        => NULL
			  ,p_effective_date         => l_ftr_elig_per_rec.effective_start_date
			  );
	     else
	         ben_determine_eligibility3.save_to_restore
		  (p_current_per_in_ler_id   => l_per_in_ler_id
		  ,p_per_in_ler_id          => l_prev_per_in_ler_id
		  ,p_elig_per_id            => l_elig_per_id
		  ,p_elig_per_opt_id        => NULL
		  ,p_effective_date         => l_effective_dt
		  );
	     end if;
          --
      END IF;
      /* End of Bug 9020962 */
      --
      ben_Eligible_Person_perf_api.update_perf_Eligible_Person
        (p_validate                     => FALSE,
         p_elig_per_id                  => l_elig_per_id,
         p_per_in_ler_id                => l_per_in_ler_id,
         p_effective_start_date         => l_effective_start_date,
         p_effective_end_date           => l_effective_end_date,
         p_elig_flag                    => l_elig_flag,
         p_prtn_strt_dt                 => l_prtn_strt_dt,
         p_prtn_end_dt                  => null,
	 p_ler_id                       => p_ler_id,  -- bug 5478994
         p_rt_comp_ref_amt              => p_comp_rec.rt_comp_ref_amt,
         p_rt_cmbn_age_n_los_val        => p_comp_rec.rt_cmbn_age_n_los_val,
         p_rt_comp_ref_uom              => p_comp_rec.rt_comp_ref_uom,
         p_rt_age_val                   => p_comp_rec.rt_age_val,
         p_rt_los_val                   => p_comp_rec.rt_los_val,
         p_rt_hrs_wkd_val               => p_comp_rec.rt_hrs_wkd_val,
         p_rt_hrs_wkd_bndry_perd_cd     => p_comp_rec.rt_hrs_wkd_bndry_perd_cd,
         p_rt_age_uom                   => p_comp_rec.rt_age_uom,
         p_rt_los_uom                   => p_comp_rec.rt_los_uom,
         p_rt_pct_fl_tm_val             => p_comp_rec.rt_pct_fl_tm_val,
         p_rt_frz_los_flag              => 'N',
         p_rt_frz_age_flag              => 'N',
         p_rt_frz_cmp_lvl_flag          => 'N',
         p_rt_frz_pct_fl_tm_flag        => 'N',
         p_rt_frz_hrs_wkd_flag          => 'N',
         p_rt_frz_comb_age_and_los_flag => 'N',
         p_once_r_cntug_cd              => p_comp_rec.once_r_cntug_cd,
         p_comp_ref_amt                 => p_comp_rec.comp_ref_amt,
         p_cmbn_age_n_los_val           => p_comp_rec.cmbn_age_n_los_val,
         p_comp_ref_uom                 => p_comp_rec.comp_ref_uom,
         p_age_val                      => p_comp_rec.age_val,
         p_los_val                      => p_comp_rec.los_val,
         p_hrs_wkd_val                  => p_comp_rec.hrs_wkd_val,
         p_hrs_wkd_bndry_perd_cd        => p_comp_rec.hrs_wkd_bndry_perd_cd,
         p_age_uom                      => p_comp_rec.age_uom,
         p_los_uom                      => p_comp_rec.los_uom,
         p_pct_fl_tm_val                => p_comp_rec.pct_fl_tm_val,
         p_frz_los_flag                 => 'N',
         p_frz_age_flag                 => 'N',
         p_frz_cmp_lvl_flag             => 'N',
         p_frz_pct_fl_tm_flag           => 'N',
         p_frz_hrs_wkd_flag             => 'N',
         p_frz_comb_age_and_los_flag    => 'N',
         p_wait_perd_cmpltn_dt          => l_wait_perd_cmpltn_dt,
         p_wait_perd_strt_dt            => l_wait_perd_strt_dt,
         p_object_version_number        => l_object_version_number,
         --
         -- Bugs : 1412882, part of bug 1412951
         --
         p_effective_date               => l_effective_dt,
         -- p_effective_date               => p_effective_date,
         p_datetrack_mode               => l_datetrack_mode,
         p_program_application_id       => fnd_global.prog_appl_id,
         p_program_id                   => fnd_global.conc_program_id,
         p_request_id                   => fnd_global.conc_request_id,
         p_program_update_date          => sysdate);
--ICM
IF nvl(l_env_rec.mode_cd,'~') = 'D' THEN
hr_utility.set_location('Building PEP5',214);
   IF NOT ben_icm_life_events.g_cache_pep_object.EXISTS(1) THEN
      --
      l_count_icm  := 1;
    --
    ELSE
      --
      l_count_icm  := ben_icm_life_events.g_cache_pep_object.LAST + 1;
    --
    END IF;
   --
ben_icm_life_events.g_cache_pep_object(l_count_icm).elig_per_id := l_elig_per_id;
ben_icm_life_events.g_cache_pep_object(l_count_icm).effective_start_date :=l_effective_start_date;
ben_icm_life_events.g_cache_pep_object(l_count_icm).effective_end_date :=l_effective_end_date;
ben_icm_life_events.g_cache_pep_object(l_count_icm).business_group_id := p_business_group_id;
ben_icm_life_events.g_cache_pep_object(l_count_icm).ler_id :=p_ler_id;
ben_icm_life_events.g_cache_pep_object(l_count_icm).per_in_ler_id :=l_per_in_ler_id;
ben_icm_life_events.g_cache_pep_object(l_count_icm).prtn_strt_dt :=l_prtn_strt_dt;
ben_icm_life_events.g_cache_pep_object(l_count_icm).prtn_end_dt := null;
ben_icm_life_events.g_cache_pep_object(l_count_icm).pl_id :=p_pl_id;
ben_icm_life_events.g_cache_pep_object(l_count_icm).plip_id :=p_plip_id;
ben_icm_life_events.g_cache_pep_object(l_count_icm).ptip_id :=p_ptip_id;
ben_icm_life_events.g_cache_pep_object(l_count_icm).pgm_id:=nvl(p_pgm_id,l_envpgm_id);
ben_icm_life_events.g_cache_pep_object(l_count_icm).dpnt_othr_pl_cvrd_rl_flag := 'N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).wait_perd_cmpltn_dt :=l_wait_perd_cmpltn_dt;
ben_icm_life_events.g_cache_pep_object(l_count_icm).wait_perd_strt_dt :=l_wait_perd_strt_dt;
ben_icm_life_events.g_cache_pep_object(l_count_icm).elig_flag :=l_elig_flag;
ben_icm_life_events.g_cache_pep_object(l_count_icm).comp_ref_amt :=p_comp_rec.comp_ref_amt;
ben_icm_life_events.g_cache_pep_object(l_count_icm).cmbn_age_n_los_val :=p_comp_rec.cmbn_age_n_los_val;
ben_icm_life_events.g_cache_pep_object(l_count_icm).comp_ref_uom :=p_comp_rec.comp_ref_uom;
ben_icm_life_events.g_cache_pep_object(l_count_icm).age_val :=p_comp_rec.age_val;
ben_icm_life_events.g_cache_pep_object(l_count_icm).pl_key_ee_flag := 'N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).age_uom :=p_comp_rec.age_uom;
ben_icm_life_events.g_cache_pep_object(l_count_icm).los_val :=p_comp_rec.los_val;
ben_icm_life_events.g_cache_pep_object(l_count_icm).los_uom :=p_comp_rec.los_uom;
ben_icm_life_events.g_cache_pep_object(l_count_icm).hrs_wkd_val :=p_comp_rec.hrs_wkd_val;
ben_icm_life_events.g_cache_pep_object(l_count_icm).hrs_wkd_bndry_perd_cd :=p_comp_rec.hrs_wkd_bndry_perd_cd;
ben_icm_life_events.g_cache_pep_object(l_count_icm).pct_fl_tm_val :=p_comp_rec.pct_fl_tm_val;
ben_icm_life_events.g_cache_pep_object(l_count_icm).frz_los_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).frz_age_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).frz_cmp_lvl_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).frz_pct_fl_tm_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).frz_hrs_wkd_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).frz_comb_age_and_los_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_comp_ref_amt :=p_comp_rec.rt_comp_ref_amt;
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_cmbn_age_n_los_val :=p_comp_rec.rt_cmbn_age_n_los_val;
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_comp_ref_uom :=p_comp_rec.rt_comp_ref_uom;
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_age_val :=p_comp_rec.rt_age_val;
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_age_uom :=p_comp_rec.rt_age_uom;
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_los_val :=p_comp_rec.rt_los_val;
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_los_uom :=p_comp_rec.rt_los_uom;
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_hrs_wkd_val :=p_comp_rec.rt_hrs_wkd_val;
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_hrs_wkd_bndry_perd_cd :=p_comp_rec.rt_hrs_wkd_bndry_perd_cd;
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_pct_fl_tm_val :=p_comp_rec.rt_pct_fl_tm_val;
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_frz_los_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_frz_age_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_frz_cmp_lvl_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_frz_pct_fl_tm_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_frz_hrs_wkd_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_frz_comb_age_and_los_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).once_r_cntug_cd :=p_comp_rec.once_r_cntug_cd;
ben_icm_life_events.g_cache_pep_object(l_count_icm).object_version_number := l_p_object_version_number;
ben_icm_life_events.g_cache_pep_object(l_count_icm).program_application_id :=fnd_global.prog_appl_id;
ben_icm_life_events.g_cache_pep_object(l_count_icm).program_id :=fnd_global.conc_program_id;
ben_icm_life_events.g_cache_pep_object(l_count_icm).request_id :=fnd_global.conc_request_id;
ben_icm_life_events.g_cache_pep_object(l_count_icm).program_update_date :=sysdate;
ben_icm_life_events.g_cache_pep_object(l_count_icm).p_newly_elig :=  l_newly_elig;
ben_icm_life_events.g_cache_pep_object(l_count_icm).p_newly_inelig:= l_newly_inelig;
ben_icm_life_events.g_cache_pep_object(l_count_icm).p_first_elig :=  l_first_elig;
ben_icm_life_events.g_cache_pep_object(l_count_icm).p_first_inelig:= l_first_inelig;
ben_icm_life_events.g_cache_pep_object(l_count_icm).p_still_elig :=  l_still_elig;
ben_icm_life_events.g_cache_pep_object(l_count_icm).p_still_inelig:= l_still_inelig;
ben_icm_life_events.g_cache_pep_object(l_count_icm).p_datetrack_mode:= l_datetrack_mode;
ben_icm_life_events.g_cache_pep_object(l_count_icm).p_effective_date:= l_effective_dt;
ben_icm_life_events.g_cache_pep_object(l_count_icm).dpnt_othr_pl_cvrd_rl_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).pl_key_ee_flag := 'N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).pl_hghly_compd_flag:= 'N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).prtn_ovridn_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).no_mx_prtn_ovrid_thru_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).dstr_rstcn_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).pl_wvd_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).person_id := p_person_id;
--
END IF;
--ICM
      hr_utility.set_location('Dn New El Upd PEP  ben_determine_eligibility2.check_prev_elig', 10);
      --
      if p_score_tab.count > 0 then
         hr_utility.set_location('writing score records ',5.5);
         ben_elig_scre_wtg_api.load_score_weight
         (p_validate              => false
         ,p_score_tab             => p_score_tab
         ,p_per_in_ler_id         => l_per_in_ler_id    /* Bug 4438430 */
         ,p_effective_date        => l_effective_dt
         ,p_elig_per_id           => l_elig_per_id);
      end if;
    elsif l_newly_inelig then --c
      --
	hr_utility.set_location ('newly inelig',121);
      --
      l_p_object_version_number := l_object_version_number;
      --
      if instr(ben_manage_life_events.g_output_string,
               'Elg:') = 0 then
        --
        ben_manage_life_events.g_output_string :=
          ben_manage_life_events.g_output_string||
          'Elg: No '||
          'Rsn: Prev Elig';
        --
      end if;
      --
      -- if the previous row's start date is greater than the computed
      -- end date, then they never really became eligible.  Go find
      -- another 'start' inelig date to use.
      --
      if l_prev_prtn_strt_dt > l_prtn_eff_end_dt then  --p
        -- Check for an existing ineligible record where our computed end
        -- date falls between existing records start and end dates.
        open c_overlap (c_prtn_eff_strt_dt => l_prtn_eff_end_dt
                       ,c_elig_flag        => 'N'
                       ,c_add_one          => 0);
          --
          fetch c_overlap into l_overlap;
          --
        close c_overlap;
        --
        if l_overlap.prtn_strt_dt is not null then
          --
          l_end_dt_plus_one := l_overlap.prtn_strt_dt;
          --
          -- Using old records start date.
          --
        end if;
        --
      else                               --p
        -- If the previous row's start date is less than or equal the commputed
        -- they were eligible for at least a day.  Update the old record with
        -- an end date in correction mode, then update (to create a new inelig
        -- record.
          hr_utility.set_location('elig per id'||l_elig_per_id,411);
       hr_utility.set_location('object version number'||l_object_version_number,412);
       hr_utility.set_location('l_elig_flag'|| l_elig_flag,412);
        ben_Eligible_Person_perf_api.update_perf_Eligible_Person
          (p_validate                   => FALSE,
           p_elig_per_id                => l_elig_per_id,
           p_effective_start_date       => l_effective_start_date,
           p_effective_end_date         => l_effective_end_date,
           p_prtn_end_dt                => l_prtn_eff_end_dt,
           p_object_version_number      => l_object_version_number,
        --   p_effective_date             => p_effective_date,
           p_effective_date               => l_effective_dt,
           p_datetrack_mode             => hr_api.g_correction,
           p_program_application_id     => fnd_global.prog_appl_id,
           p_program_id                 => fnd_global.conc_program_id,
           p_request_id                 => fnd_global.conc_request_id,
           p_program_update_date        => sysdate);
        --
 hr_utility.set_location('Building epo cache1 10 : count '  || l_count_icm1,123);
hr_utility.set_location('Building epo cache1 1'|| l_count_icm1,123);
     end if;          --p
      --
      dt_api.find_dt_upd_modes
        (-- p_effective_date       => p_effective_date,
         --
         -- Bugs : 1412882, part of bug 1412951
         --
         p_effective_date               => l_effective_dt,
         --
         p_base_table_name      => 'BEN_ELIG_PER_F',
         p_base_key_column      => 'elig_per_id',
         p_base_key_value       => l_elig_per_id,
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
      -- Update pil_id also since new row added due to current pil
      --
      hr_utility.set_location('New InEl Upd PEP  ben_determine_eligibility2.check_prev_elig', 10);
      hr_utility.set_location('elig per id'||l_elig_per_id,511);
       hr_utility.set_location('object version number'||l_object_version_number,512);
      --
      l_elig_flag := 'N';
      l_prtn_strt_dt := l_end_dt_plus_one;
      --
      --
      IF l_datetrack_mode = hr_api.g_correction AND
           l_per_in_ler_id <> NVL(l_prev_per_in_ler_id,-1) THEN
          --
          ben_determine_eligibility3.save_to_restore
          (p_current_per_in_ler_id   => l_per_in_ler_id
          ,p_per_in_ler_id          => l_prev_per_in_ler_id
          ,p_elig_per_id            => l_elig_per_id
          ,p_elig_per_opt_id        => NULL
          ,p_effective_date         => l_effective_dt
          );
          --
      END IF;

      /* Bug 9020962: If future eligibility record exists, then insert the record
	   in backup table ben_le_clsn_n_rstr */
      IF (l_datetrack_mode = hr_api.g_update_override) AND
           l_per_in_ler_id <> NVL(l_prev_per_in_ler_id,-1) THEN
          --
             open c_prev_pil(p_pil_row.per_in_ler_id);
	     fetch c_prev_pil into l_prev_pil_id;
	     close c_prev_pil;
             hr_utility.set_location('l_prev_pil_id ' || l_prev_pil_id, 7779);

	     open c_elig_rec(l_elig_per_id,l_prev_per_in_ler_id);
             fetch c_elig_rec into l_elig_per_rec;
	     close c_elig_rec;

	     open c_elig_per_id(l_prev_pil_id,
                      l_elig_per_rec.pl_id,
		      l_elig_per_rec.pgm_id,
		      l_elig_per_rec.ptip_id,
		      l_elig_per_rec.plip_id,
		      p_effective_date);
	     fetch c_elig_per_id into l_ftr_elig_per_rec;
	     close c_elig_per_id;

             if(l_ftr_elig_per_rec.elig_per_id is not null) then
		ben_determine_eligibility3.save_to_restore
			  (p_current_per_in_ler_id   => l_per_in_ler_id
			  ,p_per_in_ler_id          => l_prev_pil_id
			  ,p_elig_per_id            => l_ftr_elig_per_rec.elig_per_id
			  ,p_elig_per_opt_id        => NULL
			  ,p_effective_date         => l_ftr_elig_per_rec.effective_start_date
			  );
	     else
	         ben_determine_eligibility3.save_to_restore
		  (p_current_per_in_ler_id   => l_per_in_ler_id
		  ,p_per_in_ler_id          => l_prev_per_in_ler_id
		  ,p_elig_per_id            => l_elig_per_id
		  ,p_elig_per_opt_id        => NULL
		  ,p_effective_date         => l_effective_dt
		  );
	     end if;
          --
      END IF;
      --
      ben_Eligible_Person_perf_api.update_perf_Eligible_Person
        (p_validate                     => FALSE,
         p_elig_per_id                  => l_elig_per_id,
         p_effective_start_date         => l_effective_start_date,
         p_effective_end_date           => l_effective_end_date,
         p_per_in_ler_id                => l_per_in_ler_id,
         p_elig_flag                    => l_elig_flag,
         p_prtn_strt_dt                 => l_prtn_strt_dt,
         p_prtn_end_dt                  => null,
	 p_ler_id                       => p_ler_id,  -- bug 5478994
         p_rt_comp_ref_amt              => p_comp_rec.rt_comp_ref_amt,
         p_rt_cmbn_age_n_los_val        => p_comp_rec.rt_cmbn_age_n_los_val,
         p_rt_comp_ref_uom              => p_comp_rec.rt_comp_ref_uom,
         p_rt_age_val                   => p_comp_rec.rt_age_val,
         p_rt_los_val                   => p_comp_rec.rt_los_val,
         p_rt_hrs_wkd_val               => p_comp_rec.rt_hrs_wkd_val,
         p_rt_hrs_wkd_bndry_perd_cd     => p_comp_rec.rt_hrs_wkd_bndry_perd_cd,
         p_rt_age_uom                   => p_comp_rec.rt_age_uom,
         p_rt_los_uom                   => p_comp_rec.rt_los_uom,
         p_rt_pct_fl_tm_val             => p_comp_rec.rt_pct_fl_tm_val,
         p_rt_frz_los_flag              => 'N',
         p_rt_frz_age_flag              => 'N',
         p_rt_frz_cmp_lvl_flag          => 'N',
         p_rt_frz_pct_fl_tm_flag        => 'N',
         p_rt_frz_hrs_wkd_flag          => 'N',
         p_rt_frz_comb_age_and_los_flag => 'N',
         p_once_r_cntug_cd              => p_comp_rec.once_r_cntug_cd,
         p_comp_ref_amt                 => p_comp_rec.comp_ref_amt,
         p_cmbn_age_n_los_val           => p_comp_rec.cmbn_age_n_los_val,
         p_comp_ref_uom                 => p_comp_rec.comp_ref_uom,
         p_age_val                      => p_comp_rec.age_val,
         p_los_val                      => p_comp_rec.los_val,
         p_hrs_wkd_val                  => p_comp_rec.hrs_wkd_val,
         p_hrs_wkd_bndry_perd_cd        => p_comp_rec.hrs_wkd_bndry_perd_cd,
         p_age_uom                      => p_comp_rec.age_uom,
         p_los_uom                      => p_comp_rec.los_uom,
         p_pct_fl_tm_val                => p_comp_rec.pct_fl_tm_val,
         p_frz_los_flag                 => 'N',
         p_frz_age_flag                 => 'N',
         p_frz_cmp_lvl_flag             => 'N',
         p_frz_pct_fl_tm_flag           => 'N',
         p_frz_hrs_wkd_flag             => 'N',
         p_frz_comb_age_and_los_flag    => 'N',
         p_object_version_number        => l_object_version_number,
         --
         -- Bugs : 1412882, part of bug 1412951
         --
         p_effective_date               => l_effective_dt,
         -- p_effective_date               => p_effective_date,
         p_datetrack_mode               => l_datetrack_mode,
         p_program_application_id       => fnd_global.prog_appl_id,
         p_program_id                   => fnd_global.conc_program_id,
         p_request_id                   => fnd_global.conc_request_id,
         p_program_update_date          => sysdate,
         p_inelg_rsn_cd                 => p_inelg_rsn_cd);
--ICM
IF nvl(l_env_rec.mode_cd,'~') = 'D' THEN
hr_utility.set_location('Building PEP7',214);
   IF NOT ben_icm_life_events.g_cache_pep_object.EXISTS(1) THEN
      --
      l_count_icm  := 1;
    --
    ELSE
      --
      l_count_icm  := ben_icm_life_events.g_cache_pep_object.LAST + 1;
    --
    END IF;
   --
ben_icm_life_events.g_cache_pep_object(l_count_icm).elig_per_id := l_elig_per_id;
ben_icm_life_events.g_cache_pep_object(l_count_icm).effective_start_date :=l_effective_start_date;
ben_icm_life_events.g_cache_pep_object(l_count_icm).effective_end_date :=l_effective_end_date;
ben_icm_life_events.g_cache_pep_object(l_count_icm).business_group_id := p_business_group_id;
ben_icm_life_events.g_cache_pep_object(l_count_icm).ler_id :=p_ler_id;
ben_icm_life_events.g_cache_pep_object(l_count_icm).pl_id :=p_pl_id;
ben_icm_life_events.g_cache_pep_object(l_count_icm).plip_id :=p_plip_id;
ben_icm_life_events.g_cache_pep_object(l_count_icm).ptip_id :=p_ptip_id;
ben_icm_life_events.g_cache_pep_object(l_count_icm).pgm_id:=nvl(p_pgm_id,l_envpgm_id);
ben_icm_life_events.g_cache_pep_object(l_count_icm).per_in_ler_id :=l_per_in_ler_id;
ben_icm_life_events.g_cache_pep_object(l_count_icm).prtn_strt_dt :=l_prtn_strt_dt;
ben_icm_life_events.g_cache_pep_object(l_count_icm).wait_perd_cmpltn_dt :=l_wait_perd_cmpltn_dt;
ben_icm_life_events.g_cache_pep_object(l_count_icm).wait_perd_strt_dt :=l_wait_perd_strt_dt;
ben_icm_life_events.g_cache_pep_object(l_count_icm).elig_flag :=l_elig_flag;
ben_icm_life_events.g_cache_pep_object(l_count_icm).comp_ref_amt :=p_comp_rec.comp_ref_amt;
ben_icm_life_events.g_cache_pep_object(l_count_icm).cmbn_age_n_los_val :=p_comp_rec.cmbn_age_n_los_val;
ben_icm_life_events.g_cache_pep_object(l_count_icm).dpnt_othr_pl_cvrd_rl_flag := 'N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).comp_ref_uom :=p_comp_rec.comp_ref_uom;
ben_icm_life_events.g_cache_pep_object(l_count_icm).age_val :=p_comp_rec.age_val;
ben_icm_life_events.g_cache_pep_object(l_count_icm).pl_key_ee_flag := 'N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).age_uom :=p_comp_rec.age_uom;
ben_icm_life_events.g_cache_pep_object(l_count_icm).los_val :=p_comp_rec.los_val;
ben_icm_life_events.g_cache_pep_object(l_count_icm).los_uom :=p_comp_rec.los_uom;
ben_icm_life_events.g_cache_pep_object(l_count_icm).hrs_wkd_val :=p_comp_rec.hrs_wkd_val;
ben_icm_life_events.g_cache_pep_object(l_count_icm).hrs_wkd_bndry_perd_cd :=p_comp_rec.hrs_wkd_bndry_perd_cd;
ben_icm_life_events.g_cache_pep_object(l_count_icm).pct_fl_tm_val :=p_comp_rec.pct_fl_tm_val;
ben_icm_life_events.g_cache_pep_object(l_count_icm).frz_los_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).frz_age_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).frz_cmp_lvl_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).frz_pct_fl_tm_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).frz_hrs_wkd_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).frz_comb_age_and_los_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_comp_ref_amt :=p_comp_rec.rt_comp_ref_amt;
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_cmbn_age_n_los_val :=p_comp_rec.rt_cmbn_age_n_los_val;
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_comp_ref_uom :=p_comp_rec.rt_comp_ref_uom;
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_age_val :=p_comp_rec.rt_age_val;
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_age_uom :=p_comp_rec.rt_age_uom;
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_los_val :=p_comp_rec.rt_los_val;
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_los_uom :=p_comp_rec.rt_los_uom;
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_hrs_wkd_val :=p_comp_rec.rt_hrs_wkd_val;
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_hrs_wkd_bndry_perd_cd :=p_comp_rec.rt_hrs_wkd_bndry_perd_cd;
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_pct_fl_tm_val :=p_comp_rec.rt_pct_fl_tm_val;
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_frz_los_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_frz_age_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_frz_cmp_lvl_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_frz_pct_fl_tm_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_frz_hrs_wkd_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_frz_comb_age_and_los_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).once_r_cntug_cd :=p_comp_rec.once_r_cntug_cd;
ben_icm_life_events.g_cache_pep_object(l_count_icm).object_version_number := l_p_object_version_number;
ben_icm_life_events.g_cache_pep_object(l_count_icm).program_application_id :=fnd_global.prog_appl_id;
ben_icm_life_events.g_cache_pep_object(l_count_icm).program_id :=fnd_global.conc_program_id;
ben_icm_life_events.g_cache_pep_object(l_count_icm).request_id :=fnd_global.conc_request_id;
ben_icm_life_events.g_cache_pep_object(l_count_icm).program_update_date :=sysdate;
ben_icm_life_events.g_cache_pep_object(l_count_icm).p_newly_elig :=  l_newly_elig;
ben_icm_life_events.g_cache_pep_object(l_count_icm).p_newly_inelig:= l_newly_inelig;
ben_icm_life_events.g_cache_pep_object(l_count_icm).p_first_elig :=  l_first_elig;
ben_icm_life_events.g_cache_pep_object(l_count_icm).p_first_inelig:= l_first_inelig;
ben_icm_life_events.g_cache_pep_object(l_count_icm).p_still_elig :=  l_still_elig;
ben_icm_life_events.g_cache_pep_object(l_count_icm).p_still_inelig:= l_still_inelig;
ben_icm_life_events.g_cache_pep_object(l_count_icm).p_datetrack_mode:= l_datetrack_mode;
ben_icm_life_events.g_cache_pep_object(l_count_icm).p_effective_date:= l_effective_dt;
ben_icm_life_events.g_cache_pep_object(l_count_icm).dpnt_othr_pl_cvrd_rl_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).pl_key_ee_flag := 'N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).pl_hghly_compd_flag:= 'N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).prtn_ovridn_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).no_mx_prtn_ovrid_thru_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).dstr_rstcn_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).pl_wvd_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).person_id := p_person_id;
END IF;
--
--ICM
      hr_utility.set_location('Dn New InEl Upd PEP  ben_determine_eligibility2.check_prev_elig', 10);
      if p_score_tab.count > 0 then
         hr_utility.set_location('writing score records ',5.5);
         ben_elig_scre_wtg_api.load_score_weight
         (p_validate              => false
         ,p_score_tab             => p_score_tab
         ,p_per_in_ler_id         => l_per_in_ler_id    /* Bug 4438430 */
         ,p_effective_date        => l_effective_dt
         ,p_elig_per_id           => l_elig_per_id);
      end if;
       --
      -- ben_newly_ineligible does not handle levels other than
      -- plan,option in plan, or program.  Don't call it if not
      -- necessary.
      --
      if p_plip_id is not null then
         open c_get_pl_id(nvl(l_fonm_cvg_strt_dt,p_effective_date));
         fetch c_get_pl_id into l_pl_id;
         close c_get_pl_id;
      end if;
      if p_pl_id is not null then
         l_pl_id := p_pl_id;
      end if;

      if (l_pl_id is not null or
          p_oipl_id is not null or
          p_pgm_id is not null) then
	   if nvl(ben_manage_life_events.g_defer_deenrol_flag,'N') <> 'Y' then  -- Defer ENH
        ben_newly_ineligible.main
          (p_person_id         => p_person_id,
           p_pl_id             => l_pl_id,
           p_pgm_id            => nvl(p_pgm_id,l_envpgm_id),
           p_oipl_id           => p_oipl_id,
           p_business_group_id => p_business_group_id,
           p_ler_id            => p_ler_id,
           p_effective_date               => l_effective_dt);
         --  p_effective_date    => p_effective_date);

	 --
       end if;
       --
      end if;
      --
      if p_ptip_id is not null then
       if nvl(ben_manage_life_events.g_defer_deenrol_flag,'N') <> 'Y' then  -- Defer ENH
         for l_rec in c_get_pl_from_ptip(nvl(l_fonm_cvg_strt_dt,p_effective_date)) loop
          ben_newly_ineligible.main
          (p_person_id         => p_person_id,
           p_pl_id             => l_rec.pl_id,
           p_pgm_id            => nvl(p_pgm_id,l_envpgm_id),
           p_oipl_id           => p_oipl_id,
           p_business_group_id => p_business_group_id,
           p_ler_id            => p_ler_id,
           p_effective_date               => l_effective_dt);
        --   p_effective_date    => p_effective_date);
          end loop;
	 --
       end if;
       --
      end if;
    elsif l_first_inelig then       --c
      --
	hr_utility.set_location ('first inelig',121);
      if instr(ben_manage_life_events.g_output_string,
               'Elg:') = 0 then
        --
        ben_manage_life_events.g_output_string :=
          ben_manage_life_events.g_output_string||
          'Elg: No '||
          'Rsn: FTIME InElig';
        --
      end if;
      --
      if p_pgm_id is not null or l_envpgm_id is not null and p_pl_id is not null then
       open c_plip_ordr(nvl(l_fonm_cvg_strt_dt,p_effective_date));
       fetch c_plip_ordr into l_plan_ordr_num;
       close c_plip_ordr;
      elsif p_pgm_id is null and l_envpgm_id is null and p_pl_id is not null then
        l_plan_ordr_num := l_pl_rec.ordr_num;
       end if;
      hr_utility.set_location('Fir InEl Cre PEP  ben_determine_eligibility2.check_prev_elig', 10);
      hr_utility.set_location('l_prtn_eff_strt_dt -> '||l_prtn_eff_strt_dt, 123);
      --
      l_elig_flag := 'N';
      l_prtn_strt_dt := l_end_dt_plus_one;
      --
      ben_Eligible_Person_perf_api.create_perf_Eligible_Person
        (p_validate                     => FALSE,
         p_elig_per_id                  => l_elig_per_id,
         p_per_in_ler_id                => l_per_in_ler_id,
         p_effective_start_date         => l_effective_start_date,
         p_effective_end_date           => l_effective_end_date,
         p_business_group_id            => p_business_group_id,
         p_pl_id                        => p_pl_id,
         p_plip_id                      => p_plip_id,
         p_ptip_id                      => p_ptip_id,
         p_pgm_id                       => nvl(p_pgm_id,l_envpgm_id),
         p_ler_id                       => p_ler_id,
         p_person_id                    => p_person_id,
         p_dpnt_othr_pl_cvrd_rl_flag    => 'N',
         p_pl_key_ee_flag               => 'N',
         p_pl_hghly_compd_flag          => 'N',
         p_elig_flag                    => l_elig_flag,
         p_prtn_strt_dt                 => l_prtn_strt_dt,
         p_prtn_ovridn_flag             => 'N',
         p_no_mx_prtn_ovrid_thru_flag   => 'N',
         p_prtn_ovridn_thru_dt          => null,
         p_dstr_rstcn_flag              => 'N',
         p_pl_wvd_flag                  => 'N',
         p_rt_comp_ref_amt              => p_comp_rec.rt_comp_ref_amt,
         p_rt_cmbn_age_n_los_val        => p_comp_rec.rt_cmbn_age_n_los_val,
         p_rt_comp_ref_uom              => p_comp_rec.rt_comp_ref_uom,
         p_rt_age_val                   => p_comp_rec.rt_age_val,
         p_rt_los_val                   => p_comp_rec.rt_los_val,
         p_rt_hrs_wkd_val               => p_comp_rec.rt_hrs_wkd_val,
         p_rt_hrs_wkd_bndry_perd_cd     => p_comp_rec.rt_hrs_wkd_bndry_perd_cd,
         p_rt_age_uom                   => p_comp_rec.rt_age_uom,
         p_rt_los_uom                   => p_comp_rec.rt_los_uom,
         p_rt_pct_fl_tm_val             => p_comp_rec.rt_pct_fl_tm_val,
         p_rt_frz_los_flag              => 'N',
         p_rt_frz_age_flag              => 'N',
         p_rt_frz_cmp_lvl_flag          => 'N',
         p_rt_frz_pct_fl_tm_flag        => 'N',
         p_rt_frz_hrs_wkd_flag          => 'N',
         p_rt_frz_comb_age_and_los_flag => 'N',
         p_once_r_cntug_cd              => p_comp_rec.once_r_cntug_cd,
         p_comp_ref_amt                 => p_comp_rec.comp_ref_amt,
         p_cmbn_age_n_los_val           => p_comp_rec.cmbn_age_n_los_val,
         p_comp_ref_uom                 => p_comp_rec.comp_ref_uom,
         p_age_val                      => p_comp_rec.age_val,
         p_los_val                      => p_comp_rec.los_val,
         p_hrs_wkd_val                  => p_comp_rec.hrs_wkd_val,
         p_hrs_wkd_bndry_perd_cd        => p_comp_rec.hrs_wkd_bndry_perd_cd,
         p_age_uom                      => p_comp_rec.age_uom,
         p_los_uom                      => p_comp_rec.los_uom,
         p_pct_fl_tm_val                => p_comp_rec.pct_fl_tm_val,
         p_frz_los_flag                 => 'N',
         p_frz_age_flag                 => 'N',
         p_frz_cmp_lvl_flag             => 'N',
         p_frz_pct_fl_tm_flag           => 'N',
         p_frz_hrs_wkd_flag             => 'N',
         p_frz_comb_age_and_los_flag    => 'N',
         p_object_version_number        => l_object_version_number,
         p_pl_ordr_num                  => l_plan_ordr_num,
         p_plip_ordr_num                => l_plip_rec.ordr_num,
         p_ptip_ordr_num                => l_ptip_rec.ordr_num,
         --
         -- Bugs : 1412882, part of bug 1412951
         --
         p_effective_date               => l_effective_dt,
         -- p_effective_date               => p_effective_date,
         p_program_application_id       => fnd_global.prog_appl_id,
         p_program_id                   => fnd_global.conc_program_id,
         p_request_id                   => fnd_global.conc_request_id,
         p_program_update_date          => sysdate,
         p_inelg_rsn_cd                 => p_inelg_rsn_cd
         --
         -- Bypass insert validate validation for performance
         --
        ,p_override_validation          => TRUE
        );
--ICM
IF nvl(l_env_rec.mode_cd,'~') = 'D' THEN
hr_utility.set_location('Building PEP8',214);
   IF NOT ben_icm_life_events.g_cache_pep_object.EXISTS(1) THEN
      --
      l_count_icm  := 1;
    --
    ELSE
      --
      l_count_icm  := ben_icm_life_events.g_cache_pep_object.LAST + 1;
    --
    END IF;
   --
ben_icm_life_events.g_cache_pep_object(l_count_icm).elig_per_id := l_elig_per_id;
ben_icm_life_events.g_cache_pep_object(l_count_icm).effective_start_date :=l_effective_start_date;
ben_icm_life_events.g_cache_pep_object(l_count_icm).effective_end_date :=l_effective_end_date;
ben_icm_life_events.g_cache_pep_object(l_count_icm).business_group_id := p_business_group_id;
ben_icm_life_events.g_cache_pep_object(l_count_icm).pl_id :=p_pl_id;
ben_icm_life_events.g_cache_pep_object(l_count_icm).plip_id :=p_plip_id;
ben_icm_life_events.g_cache_pep_object(l_count_icm).ptip_id :=p_ptip_id;
ben_icm_life_events.g_cache_pep_object(l_count_icm).pgm_id:=nvl(p_pgm_id,l_envpgm_id);
ben_icm_life_events.g_cache_pep_object(l_count_icm).ler_id :=p_ler_id;
ben_icm_life_events.g_cache_pep_object(l_count_icm).person_id :=p_person_id;
ben_icm_life_events.g_cache_pep_object(l_count_icm).per_in_ler_id :=l_per_in_ler_id;
ben_icm_life_events.g_cache_pep_object(l_count_icm).dpnt_othr_pl_cvrd_rl_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).pl_key_ee_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).prtn_ovridn_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).prtn_ovridn_thru_dt := null;
ben_icm_life_events.g_cache_pep_object(l_count_icm).no_mx_prtn_ovrid_thru_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).prtn_strt_dt :=l_prtn_strt_dt;
ben_icm_life_events.g_cache_pep_object(l_count_icm).dstr_rstcn_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).pl_wvd_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).wait_perd_cmpltn_dt :=l_wait_perd_cmpltn_dt;
ben_icm_life_events.g_cache_pep_object(l_count_icm).wait_perd_strt_dt :=l_wait_perd_strt_dt;
ben_icm_life_events.g_cache_pep_object(l_count_icm).elig_flag :=l_elig_flag;
ben_icm_life_events.g_cache_pep_object(l_count_icm).comp_ref_amt :=p_comp_rec.comp_ref_amt;
ben_icm_life_events.g_cache_pep_object(l_count_icm).cmbn_age_n_los_val :=p_comp_rec.cmbn_age_n_los_val;
ben_icm_life_events.g_cache_pep_object(l_count_icm).comp_ref_uom :=p_comp_rec.comp_ref_uom;
ben_icm_life_events.g_cache_pep_object(l_count_icm).age_val :=p_comp_rec.age_val;
ben_icm_life_events.g_cache_pep_object(l_count_icm).age_uom :=p_comp_rec.age_uom;
ben_icm_life_events.g_cache_pep_object(l_count_icm).los_val :=p_comp_rec.los_val;
ben_icm_life_events.g_cache_pep_object(l_count_icm).los_uom :=p_comp_rec.los_uom;
ben_icm_life_events.g_cache_pep_object(l_count_icm).hrs_wkd_val :=p_comp_rec.hrs_wkd_val;
ben_icm_life_events.g_cache_pep_object(l_count_icm).hrs_wkd_bndry_perd_cd :=p_comp_rec.hrs_wkd_bndry_perd_cd;
ben_icm_life_events.g_cache_pep_object(l_count_icm).pct_fl_tm_val :=p_comp_rec.pct_fl_tm_val;
ben_icm_life_events.g_cache_pep_object(l_count_icm).frz_los_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).frz_age_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).frz_cmp_lvl_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).frz_pct_fl_tm_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).frz_hrs_wkd_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).frz_comb_age_and_los_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_comp_ref_amt :=p_comp_rec.rt_comp_ref_amt;
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_cmbn_age_n_los_val :=p_comp_rec.rt_cmbn_age_n_los_val;
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_comp_ref_uom :=p_comp_rec.rt_comp_ref_uom;
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_age_val :=p_comp_rec.rt_age_val;
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_age_uom :=p_comp_rec.rt_age_uom;
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_los_val :=p_comp_rec.rt_los_val;
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_los_uom :=p_comp_rec.rt_los_uom;
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_hrs_wkd_val :=p_comp_rec.rt_hrs_wkd_val;
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_hrs_wkd_bndry_perd_cd :=p_comp_rec.rt_hrs_wkd_bndry_perd_cd;
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_pct_fl_tm_val :=p_comp_rec.rt_pct_fl_tm_val;
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_frz_los_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_frz_age_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_frz_cmp_lvl_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_frz_pct_fl_tm_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_frz_hrs_wkd_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).rt_frz_comb_age_and_los_flag :='N';
ben_icm_life_events.g_cache_pep_object(l_count_icm).once_r_cntug_cd :=p_comp_rec.once_r_cntug_cd;
ben_icm_life_events.g_cache_pep_object(l_count_icm).pl_ordr_num :=l_plan_ordr_num;
ben_icm_life_events.g_cache_pep_object(l_count_icm).plip_ordr_num :=l_plip_rec.ordr_num;
ben_icm_life_events.g_cache_pep_object(l_count_icm).ptip_ordr_num :=l_ptip_rec.ordr_num;
ben_icm_life_events.g_cache_pep_object(l_count_icm).object_version_number :=l_object_version_number;
ben_icm_life_events.g_cache_pep_object(l_count_icm).program_application_id :=fnd_global.prog_appl_id;
ben_icm_life_events.g_cache_pep_object(l_count_icm).program_id :=fnd_global.conc_program_id;
ben_icm_life_events.g_cache_pep_object(l_count_icm).request_id :=fnd_global.conc_request_id;
ben_icm_life_events.g_cache_pep_object(l_count_icm).program_update_date :=sysdate;
ben_icm_life_events.g_cache_pep_object(l_count_icm).p_newly_elig :=  l_newly_elig;
ben_icm_life_events.g_cache_pep_object(l_count_icm).p_newly_inelig:= l_newly_inelig;
ben_icm_life_events.g_cache_pep_object(l_count_icm).p_first_elig :=  l_first_elig;
ben_icm_life_events.g_cache_pep_object(l_count_icm).p_first_inelig:= l_first_inelig;
ben_icm_life_events.g_cache_pep_object(l_count_icm).p_still_elig :=  l_still_elig;
ben_icm_life_events.g_cache_pep_object(l_count_icm).p_still_inelig:= l_still_inelig;
ben_icm_life_events.g_cache_pep_object(l_count_icm).p_effective_date:= l_effective_dt;
ben_icm_life_events.g_cache_pep_object(l_count_icm).pl_hghly_compd_flag:= 'N';
--
END IF;
--ICM
        hr_utility.set_location('Dn Fir InEl Cre PEP  ben_determine_eligibility2.check_prev_elig', 10);
        --
      if p_score_tab.count > 0 then
         hr_utility.set_location('writing score records ',5.5);
         ben_elig_scre_wtg_api.load_score_weight
         (p_validate              => false
         ,p_score_tab             => p_score_tab
         ,p_per_in_ler_id         => l_per_in_ler_id    /* Bug 4438430 */
         ,p_effective_date        => l_effective_dt
         ,p_elig_per_id           => l_elig_per_id);
      end if;
    end if;  --c
    --
  end if; --a if p_oipl_id is not null
  --
  if g_debug then
    hr_utility.set_location('Leaving : ben_determine_eligibility2.check_prev_elig', 10);
  end if;
  --
  -- Set eligbility transition states
  --

  p_newly_elig   := l_newly_elig;
  p_newly_inelig := l_newly_inelig;
  p_first_elig   := l_first_elig;
  p_first_inelig := l_first_inelig;
  p_still_elig   := l_still_elig;
  p_still_inelig := l_still_inelig;
  --
  -- Set PEP and EPO details on comp object list row
  --
  p_comp_obj_tree_row.elig_per_id           := l_elig_per_id;
  p_comp_obj_tree_row.elig_per_opt_id       := l_elig_per_opt_id;
  p_comp_obj_tree_row.elig_flag             := l_elig_flag;
  p_comp_obj_tree_row.prtn_strt_dt          := l_prtn_strt_dt;
  p_comp_obj_tree_row.inelg_rsn_cd    	    := p_inelg_rsn_cd; -- 2650247
  --
end check_prev_elig;
--
end ben_determine_eligibility2;

/
