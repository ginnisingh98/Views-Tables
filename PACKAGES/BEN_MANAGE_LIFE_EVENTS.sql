--------------------------------------------------------
--  DDL for Package BEN_MANAGE_LIFE_EVENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_MANAGE_LIFE_EVENTS" AUTHID CURRENT_USER as
/* $Header: benmngle.pkh 120.7.12010000.1 2008/07/29 12:27:00 appldev ship $ */
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation		       |
|			   Redwood Shores, California, USA		       |
|			        All rights reserved.			       |
+==============================================================================+

Name
	Manage Life Events
Purpose
	This package is used to check validity of parameters passed in via SRS
        or via a PL/SQL function or procedure.
History
        Date             Who        Version    What?
        ----             ---        -------    -----
        14 Dec 97        G Perry    110.0      Created.
        04 Jan 98        G Perry    110.1      Added extra parameters to
                                               main process_life_events
                                               call.
        05 Jan 98        G Perry    110.2      Altered parameters so they
                                               are in a more logical order.
                                               Added exception g_record_error.
        13 Jan 98        G Perry    110.3      Added globals g_person_id and
                                               changed l_validate to
                                               g_validate. Added in two
                                               new parameters to handle
                                               person_selection_rule_id
                                               and
                                               comp_selection_rule_id
        14 Jan 98        G Perry    110.4      Cached comp object names
                                               structure added and boolean
                                               to notify when a person has
                                               changed.
        15 Jan 98        G Perry    110.5      Changed cache comp object
                                               from ptyp to pltyp to tie
                                               in with altered domain
                                               lookup code.
        15 Jan 98        G Perry    110.6      Changed p_validate to a
                                               varchar2 from a boolean due
                                               to SRS.
        15 Jan 98        lmcdonal   110.7      Added g_elig_for_pgm,
                                                     g_elig_for_pl,
                                                     g_pl_nip.
        16 Jan 98        G Perry    110.8      Added retcode and errbuf
                                               which are needed by SRS.
        19 Jan 98        lmcdonal   110.9      created globals for person,
                                               assignment and
                                               life event name.
        21 Jan 98        G Perry    110.10     Created globals
                                               g_last_person_failed
                                               g_last_plan_failed
                                               g_last_prog_failed
                                               to handle propergation of comp
                                               object failures.
        24 Jan 98        G Perry    110.11     Changed g_validate to false.
        27 Jan 98        G Perry    110.12     Added g_ler_id as global.
        27 Jan 98        G Perry    110.13     g_validate change didn't get
                                               made before.
        06 Mar 98        G Perry    110.14     Added restart procedure. Added
                                               benefit_action_id parameter to
                                               process procedure. removed proc
                                               commit_all_data. Added build_comp
                                               object_list so the list of
                                               objects is available for
                                               what-if functionality.
                                               Added data structures for
                                               caching person related data and
                                               comp object related data. Removed
                                               globals that were no longer needed.
        16 Mar 98        G Perry    110.15     Added prtn_eff_strt_dt_rl and
                                               prtn_eff_strt_dt_rl into object
                                               cache structure for pl,pgm,oipl.
        08 Apr 98        G Perry    110.16     Added new global structures and
                                               made several functions and
                                               procedures public.
        11 Apr 98        G Perry    110.17     Added cache structure for
                                               reporting.
        20 Apr 98        G Perry    110.18     Added g_life_event_after
                                               exception.
        04 Jun 98        G Perry    110.19     Added fte_value and total_fte_
                                               value
                                               to person_rec structure.
	05 Jun 98	 jcarpent   110.20     Added global for g_last_pgm_id.
        24 Aug 98        G Perry    110.22     Added extra globals to
                                               structure for bendenrr.pkb.
        23 Sep 98        G Perry    115.6      Made private procedures public
                                               for Prasad.
        07 Oct 98        G Perry    115.7      Fixed a few schema changes and
                                               editted cache record structure.
        15 Oct 98        G Perry    115.8      Added new columns to oipl rec.
        20 Oct 98        jcarpent   115.9      Added new columns to pl+pgm recs
        20 Oct 98        jcarpent   115.10     Added new columns to pgm cache
        21 Oct 98        jcarpent   115.11     Added alws_unrstrctd_enrt_flag.
                                               Allow flush_global_structs access
        24 Oct 98        G Perry    115.12     Added elig_apls_flag to all cache
                                               structures.
        26 Oct 98        G Perry    115.13     Added hourly_salaried_code to
                                               person cache.
        30 Oct 98        G Perry    115.14     Changed parameter name for
                                               build_comp_object_list from
                                               p_cache_single_object to
                                               p_mode, this was for unrestricted
                                               enrollment needs.
        31 Oct 98        G Perry    115.15     Added p_lf_evt_ocrd_dt param.
        31 Dec 98        G Perry    115.16     Added people_group_id to cache.
        18 Jan 99        G Perry    115.17     LED V ED
        08 Feb 99        G Perry    115.18     Added in new columns to cache
                                               min_per_effective_start_date and
                                               min_ass_effective_start_date
        18 Feb 99        G Perry    115.19     Support for canonical dates.
        15 Mar 99        G Perry    115.20     Changed order of process
                                               procedure per bug 1529
        16 Mar 99        mhoyes     115.21     Added p_popl_enrt_typ_cycl_id to
                                               evaluate_life_events.
        06-May-99        bbulusu    115.24     Added original_date_of_hire to
                                               the g_cache_person_object record.
        14-May-99        P Bodla    115.25     Added p_lf_evt_ocrd_dt to
                                               procedure calls.
                                               evaluate_life_events
                                               process_life_events
        02-Jun-99        bbulusu    115.26     Added 3 columns to g_cache_person
        03-Jun-99        stee       115.27     Added 3 columns to
                                               g_cache_person_prtn.
        18-Jun-99        G Perry    115.28     Removed derived_factor cache
                                               This is now handled in the
                                               ben_seeddata_object package.
        23-Jun-99        G Perry    115.29     Removed plan, option and program
                                               cache.
        01-JUL-99        pbodla     115.30     Changes related with << Life Event Collision >>
                                               added g_bckdt_per_in_ler_id
        20-JUL-99        Gperry     115.31     genutils -> benutils package
                                               rename.
        27-JUL-99        mhoyes     115.32   - Fixed genutil problems.
        10-AUG-99        Gperry     115.33     Removed cache structures that
                                               are no longer required.
        15-SEP-99        Gperry     115.34     Added audit_log_flag as param
                                               for concurrent program call.
        04-OCT-99        Stee       115.35     Added ptip_id to
                                               g_cache_person_prtn_object.
        03-NOV-99        mhoyes     115.36   - Added eligibility transition
                                               states to g_cache_proc_objects_rec.
        03-FEB-00        mhoyes     115.40   - Rolled back to pre-filtering.
        10-FEB-00        mhoyes     115.41   - Added clear_init_benmngle_caches.
        26-FEB-00        mhoyes     115.42   - Added new type g_par_elig_state_rec
                                               to store parent eligibility state
                                               information.
                                             - Added parent comp object IDs to
                                               g_cache_proc_objects_rec.
        27-FEB-00        stee       115.43   - Added new parameter,
                                               p_cbr_tmprl_evt_flag.
        28-FEB-00        stee       115.44   - Added p_cbr_tmprl_evt_flag
                                               parameter to all relevant
                                               procedures.
        04-MAR-00        mhoyes     115.45   - Added elig_tran_state and
                                               trk_inelig_per_flag to comp
                                               object cache.
                                             - Removed first_inelig and
                                               still_inelig attributes.
        06-MAR-00        gperry     115.46     Changed procedure process_life
                                               _events to use nocopy references
                                               so we can use local variables to
                                               find the number of errors.
        07-MAR-00        mhoyes     115.47   - Removed build_comp_object_list.
        09-MAR-00        gperry     115.48     Added flag_bit_val for
                                               performance and binary globals.
        31-MAR-00        gperry     115.49     Added oiplip support.
        12-MAY-00        mhoyes     115.50   - Moved type g_par_elig_state_rec
                                               to ben_comp_obj_filter.
        26-JUN-00        stee       115.51   - Default p_derivable_factors to
                                               a code.
        03-Jul-00        mhoyes     115.52   - Added opt_id to g_cache_proc_objects_rec.
        05-sep-00        pbodla     115.53   - Bug 5422 : Allow different enrollment periods
                                               for programs for a scheduled  enrollment.
                                               p_popl_enrt_typ_cycl_id is removed.
        18-Sep-00        pbodla     115.54   - Healthnet changes : PB : Added parameter
                                               p_lmt_prpnip_by_org_typ_id to
                                               Comp objects are now selected based on person's
                                               organization id if p_lmt_prpnip_by_org_typ_id is
                                               Y.
        22-Sep-00        gperry     115.55     Added back param
                                               p_popl_enrt_typ_cycl_id as
                                               otherwise multithread fails.
                                               WWBUG 1412825.
        05-Jan-01        kmahendr   115.56     Added g_ler_id
        01-Jul-01        kmahendr   115.57     Added g_enrt_rt_tbl and g_pil_popl_tbl
        25-Sep-01        kmahendr   115.58     Added procedure process_recalculate as
                                               wrapper to procedure process
        30-Nov-01        mhoyes     115.59   - Made p_benefit_action_id in/out on
                                               process.
        06-Dec-01        mhoyes     115.60   - Fixed concurrent manager problem
                                               with new CAGR OUT NOCOPY parameter on process.
                                               Added new routine inner_process.
        19-Dec-01        pbodla     115.61   - Added cwb_process wrapper.
        07-Jan-02        rpillay    115.62   - Added Set Verify Off.
        08-jan-02        ikasire    115.63     Bug 2172031 cwb_change of order in parameters
        10-jan-02        ikasire    115.64     Bug 2172028 adding new procedure for
                                               rebuilding the hierarchy when a
                                               manager is changed from the view person
                                               life events form.
                                               Made the procedure popu_epe_heir as
                                               a public procedure
        12-Feb-02        mhoyes     115.65   - Added write_bft_statistics and
                                               init_bft_statistics.
        11-Mar-02        mhoyes     115.66   - Dependent eligibility tuning.
        26-Jun-02        pbodla     115.67   - ABSENCES - Added procedure abse_process
        23-Aug-02        mhoyes     115.68   - Added elig_flag, must_enrl_anthr_pl_id
                                               and prtn_strt_dt to g_cache_proc_objects_rec.
        10-Dec-02        pabodla    115.69   - CWBITEM:
                         mmudigon              1) Change in parameters for
                                               rebuild_heirarchy
                                               2) new proc popu_pel_heir
                                               3) Commented proc popu_epe_heir
        29-Jan-03        kmahendr   115.70   - Added a wrapper for Personnel Action Mode
        30-Jan-03        pbodla     115.71   - Added a wrapper for Grade/step
                                               progression participation process.
        17-Mar-03        vsethi     115.73   - Bug 2650247 added inelg_rsn_cd to record type
        				       g_cache_proc_objects_rec
        27-Apr-03        mmudigon   115.74   - Absences July FP enhancements.
                                               Additional param
                                               p_abs_historical_mode
        01-Aug-03        rpgupta    115.75   - 2940151 Grade/ step
  					       added some parameters to grade_step_process
        26-Sep-03        stee       115.76   - 2894200: Added g_derivable_factors.
        22-Dec-03        Indrasen   115.77     CWBGLOBAL New Procedure
        21-Jan-04        ikasire    115.78     Added p_trace_plans_flag to CWBGLOBAL
                                               procedure
        07-Apr-04        pbodla     115.79     FONM :Added globals to support FONM
                                               functionality.
        28-Sep-04        hmani      115.80     IREC Main Line FP of 115.77.15102.3
        06-Oct-04        abparekh   115.81     GSP Rate Sync changes
	22-sep-05        ssarkar    115.82     Bug 4621751 irec2 -- offer assignment
	03-Jan-06        nhunur     115.83     cwb - changes for person type param.
        08-Feb-06        abparekh   115.84     Bug 4875181 - Added p_run_rollup_only to cwb_global_process
        22-May-06        pbodla     115.25     Bug 5232223 - Added code to handle the trk inelig flag
                                               If trk inelig flag is set to N at group plan level
                                               then do not create cwb per in ler and all associated data.
        20-Sep-06        abparekh   115.86     Bug 5550359 : Added p_validate to PROCESS_LIFE_EVENTS
                                                             and EVALUATE_LIFE_EVENTS
	05-Apr-07        rtagarra   115.87     Bug 6000303 : Defer Deenroll ENH.Added g_defer_deenrol_flag
						             g_defer_enr_exists_in_pgm,g_defer_enr_exists_in_pl.
	16-May-07        rtagarra   115.88        -- DO --
*/
--------------------------------------------------------------------------------
--
g_record_error        exception;
g_life_event_after    exception;
-- Bug 5232223
g_cwb_trk_ineligible    exception;
g_cached_objects      boolean:= false;
g_elig_for_pgm_flag   varchar2(1);
g_elig_for_pl_flag    varchar2(1);
g_trk_inelig_flag     varchar2(1);
g_pl_nip              varchar2(1);
g_last_pgm_id         number := null;
g_modified_mode       varchar2(1);
--  added g_ler_id for unrestricted enhancement
g_ler_id              number;
g_derivable_factors   varchar2(30) := 'ASC';
fonm                  varchar2(30) ;
g_fonm_cvg_strt_dt    date ;
g_fonm_rt_strt_dt     date ;
--
-- PB :Backed out per in ler id required for life event collision and restoration
--
g_bckdt_per_in_ler_id number := null;
--
g_output_string       varchar2(1000);
g_rec                 ben_type.g_report_rec;
--
g_defer_deenrol_flag      varchar2(1);
-- iRec
-- This global variable would store assignment record for an applicant's assignment
-- being processed by BENMNGLE for mode = I : iRecruitment. The variable is exclusively
-- for BENMNGLE processing in iRec mode for a single Applicant. If BENMNGLE is modified
-- to process multiple applicants in single run, then this variable may not be valid to use.
g_irec_ass_rec       per_all_assignments_f%rowtype;
g_irec_old_ass_rec   per_all_assignments_f%rowtype; -- irec2
g_irec_off_ass_id    number ;-- Note:g_irec_off_ass_id is to hold irc_offers.offer_assignment_id%type data. -- irec2
--

--
type g_cache_proc_objects_rec is record
  (pl_id               ben_pl_f.pl_id%type
  ,pgm_id              ben_pgm_f.pgm_id%type
  ,oipl_id             ben_oipl_f.oipl_id%type
  ,ptip_id             ben_ptip_f.ptip_id%type
  ,plip_id             ben_plip_f.plip_id%type
  ,pl_nip              varchar2(1)
  ,elig_tran_state     varchar2(100)
  ,trk_inelig_per_flag varchar2(1)
  ,par_pgm_id          number
  ,par_ptip_id         number
  ,par_plip_id         number
  ,par_pl_id           number
  ,par_opt_id          number
  ,flag_bit_val        binary_integer
  ,oiplip_flag_bit_val binary_integer
  ,oiplip_id           number
  ,elig_per_id         number
  ,elig_per_opt_id     number
  ,elig_flag             varchar2(1)
  ,must_enrl_anthr_pl_id number
  ,prtn_strt_dt          date
  ,inelg_rsn_cd	       varchar2(30) -- 2650247
  );
--
-- Binary flag values for the cwflag bit val
--
g_age_flag number := 1;
g_age_rt_flag number := 2;
g_los_flag number := 4;
g_los_rt_flag number := 8;
g_cmp_flag number := 16;
g_cmp_rt_flag number := 32;
g_pft_flag number := 64;
g_pft_rt_flag number := 128;
g_hrw_flag number := 256;
g_hrw_rt_flag number := 512;
g_cal_flag number := 1024;
g_cal_rt_flag number := 2048;
--
type g_cache_proc_object_table is table of g_cache_proc_objects_rec
  index by binary_integer;
--
-- Variable to hold table structure
--
g_cache_proc_object g_cache_proc_object_table;
--
type g_cache_comp_objects_rec is record
(pgm   hr_lookups.meaning%type,
 pltyp hr_lookups.meaning%type,
 ptip  hr_lookups.meaning%type,
 pl    hr_lookups.meaning%type,
 plip  hr_lookups.meaning%type,
 oipl  hr_lookups.meaning%type);
--
-- Variable to hold cached comp objects structure
--
g_cache_comp_objects g_cache_comp_objects_rec;
--
type g_cache_person_process_object is record
(person_id                ben_person_actions.person_id%type,
 person_action_id         ben_person_actions.person_action_id%type,
 object_version_number    ben_person_actions.object_version_number%type,
 ler_id                   ben_person_actions.ler_id%type);
--
type g_cache_person_process_rec is table of g_cache_person_process_object
  index by binary_integer;
--
g_cache_person_process g_cache_person_process_rec;
--
type g_cache_person_prtn_object is record
(pl_id                 ben_prtt_enrt_rslt_f.pl_id%type,
 oipl_id               ben_prtt_enrt_rslt_f.oipl_id%type,
 pgm_id                ben_prtt_enrt_rslt_f.pgm_id%type,
 ptip_id               ben_prtt_enrt_rslt_f.ptip_id%type,
 enrt_cvg_strt_dt      ben_prtt_enrt_rslt_f.enrt_cvg_strt_dt%type,
 enrt_cvg_thru_dt      ben_prtt_enrt_rslt_f.enrt_cvg_thru_dt%type);
-- enrld_cvrd_flag       ben_prtt_enrt_rslt_f.enrld_cvrd_flag%type);
--
type g_cache_person_prtn_rec is table of g_cache_person_prtn_object
  index by binary_integer;
--
g_cache_person_prtn g_cache_person_prtn_rec;
--
type g_enrt_rt_object is record
(enrt_rt_id           ben_enrt_rt.enrt_rt_id%type,
 acty_base_rt_id      ben_enrt_rt.acty_base_rt_id%type,
 prtt_rt_val_id       ben_enrt_rt.prtt_rt_val_id%type);

type g_enrt_rt_rec is table of g_enrt_rt_object
  index by binary_integer;

g_enrt_rt_tbl     g_enrt_rt_rec;
--
type g_pil_popl_object is record
(pgm_id              ben_pil_elctbl_chc_popl.pgm_id%type,
 pl_id               ben_pil_elctbl_chc_popl.pl_id%type,
 elcns_made_dt       ben_pil_elctbl_chc_popl.elcns_made_dt%type);

type g_pil_popl_rec is table of g_pil_popl_object
  index by binary_integer;

g_pil_popl_tbl    g_pil_popl_rec;
---------------------------------------------------------------------
procedure clear_init_benmngle_caches
  (p_business_group_id in     number
  ,p_effective_date    in     date
  ,p_threads           in     number default null
  ,p_chunk_size        in     number default null
  ,p_max_errors        in     number default null
  ,p_benefit_action_id in     number default null
  ,p_thread_id         in     number default null
  );

--
-- CWB wrapper header for benmngle process
--
procedure cwb_process
  (errbuf                     out nocopy varchar2
  ,retcode                    out nocopy number
  ,p_benefit_action_id        in     number   default null
  ,p_effective_date           in     varchar2
  ,p_mode                     in     varchar2 default 'W'
  ,p_derivable_factors        in     varchar2 default 'ASC'
  ,p_validate                 in     varchar2 default 'N'
  ,p_person_id                in     number   default null
  ,p_pgm_id                   in     number   default null
  ,p_business_group_id        in     number
  ,p_pl_id                    in     number   default null
  ,p_popl_enrt_typ_cycl_id    in     number   default null
  ,p_lf_evt_ocrd_dt           in     varchar2 default null
  ,p_person_type_id           in     number   default null
  ,p_no_programs              in     varchar2 default 'N'
  ,p_no_plans                 in     varchar2 default 'N'
  ,p_comp_selection_rule_id   in     number   default null
  ,p_person_selection_rule_id in     number   default null
  ,p_ler_id                   in     number   default null
  ,p_organization_id          in     number   default null
  ,p_benfts_grp_id            in     number   default null
  ,p_location_id              in     number   default null
  ,p_pstl_zip_rng_id          in     number   default null
  ,p_rptg_grp_id              in     number   default null
  ,p_pl_typ_id                in     number   default null
  ,p_opt_id                   in     number   default null
  ,p_eligy_prfl_id            in     number   default null
  ,p_vrbl_rt_prfl_id          in     number   default null
  ,p_legal_entity_id          in     number   default null
  ,p_payroll_id               in     number   default null
  ,p_commit_data              in     varchar2 default 'Y'
  ,p_audit_log_flag           in     varchar2 default 'N'
  ,p_lmt_prpnip_by_org_flag   in     varchar2 default 'N'
  ,p_cbr_tmprl_evt_flag       in     varchar2 default 'N'
  ,p_cwb_person_type          in     varchar2 default null
  );
--
--
-- CWBGLOBAL wrapper header for benmngle process
--
procedure cwb_global_process
  (errbuf                     out nocopy varchar2
  ,retcode                    out nocopy number
  ,p_benefit_action_id        in     number   default null
  ,p_effective_date           in     varchar2
  ,p_mode                     in     varchar2 default 'W'
  ,p_derivable_factors        in     varchar2 default 'ASC'
  ,p_validate                 in     varchar2 default 'N'
  ,p_person_id                in     number   default null
  ,p_pgm_id                   in     number   default null
  ,p_business_group_id        in     number
  ,p_pl_id                    in     number   default null
  ,p_popl_enrt_typ_cycl_id    in     number   default null
  ,p_lf_evt_ocrd_dt           in     varchar2 default null
  ,p_person_type_id           in     number   default null
  ,p_no_programs              in     varchar2 default 'N'
  ,p_no_plans                 in     varchar2 default 'N'
  ,p_comp_selection_rule_id   in     number   default null
  ,p_person_selection_rule_id in     number   default null
  ,p_ler_id                   in     number   default null
  ,p_organization_id          in     number   default null
  ,p_benfts_grp_id            in     number   default null
  ,p_location_id              in     number   default null
  ,p_pstl_zip_rng_id          in     number   default null
  ,p_rptg_grp_id              in     number   default null
  ,p_pl_typ_id                in     number   default null
  ,p_opt_id                   in     number   default null
  ,p_eligy_prfl_id            in     number   default null
  ,p_vrbl_rt_prfl_id          in     number   default null
  ,p_legal_entity_id          in     number   default null
  ,p_payroll_id               in     number   default null
  ,p_commit_data              in     varchar2 default 'Y'
  ,p_audit_log_flag           in     varchar2 default 'N'
  ,p_lmt_prpnip_by_org_flag   in     varchar2 default 'N'
  ,p_cbr_tmprl_evt_flag       in     varchar2 default 'N'
  ,p_trace_plans_flag         in     varchar2 default 'N'
  ,p_cwb_person_type          in     varchar2 default null
  ,p_run_rollup_only          in     varchar2 default 'N'
  );
--
-- Added process so that more IN OUT and OUT parameters can be added
-- to benmngle for PLSQL calls. Concurrent manager still calls process because
-- it must have only errbuf and retcode as OUT parameters.
--
procedure internal_process
  (errbuf                        out nocopy varchar2
  ,retcode                       out nocopy number
  ,p_benefit_action_id        in out nocopy number
  ,p_effective_date           in     varchar2
  ,p_mode                     in     varchar2
  ,p_derivable_factors        in     varchar2 default 'ASC'
  ,p_validate                 in     varchar2 default 'N'
  ,p_person_id                in     number   default null
  ,p_person_type_id           in     number   default null
  ,p_pgm_id                   in     number   default null
  ,p_business_group_id        in     number
  ,p_pl_id                    in     number   default null
  ,p_popl_enrt_typ_cycl_id    in     number   default null
  ,p_lf_evt_ocrd_dt           in     varchar2 default null
  ,p_no_programs              in     varchar2 default 'N'
  ,p_no_plans                 in     varchar2 default 'N'
  ,p_comp_selection_rule_id   in     number   default null
  ,p_person_selection_rule_id in     number   default null
  ,p_ler_id                   in     number   default null
  ,p_organization_id          in     number   default null
  ,p_benfts_grp_id            in     number   default null
  ,p_location_id              in     number   default null
  ,p_pstl_zip_rng_id          in     number   default null
  ,p_rptg_grp_id              in     number   default null
  ,p_pl_typ_id                in     number   default null
  ,p_opt_id                   in     number   default null
  ,p_eligy_prfl_id            in     number   default null
  ,p_vrbl_rt_prfl_id          in     number   default null
  ,p_legal_entity_id          in     number   default null
  ,p_payroll_id               in     number   default null
  ,p_commit_data              in     varchar2 default 'Y'
  ,p_audit_log_flag           in     varchar2 default 'N'
  ,p_lmt_prpnip_by_org_flag   in     varchar2 default 'N'
  ,p_cbr_tmprl_evt_flag       in     varchar2 default 'N'
  -- GRADE/STEP : Added for grade/step benmngle
  ,p_org_heirarchy_id         in     number   default null
  ,p_org_starting_node_id     in     number   default null
  ,p_grade_ladder_id          in     number   default null
  ,p_asg_events_to_all_sel_dt in     varchar2 default null
  ,p_rate_id                  in     number   default null -- pay scale
  ,p_per_sel_dt_cd            in     varchar2 default null -- business rule
  ,p_per_sel_dt_from          in     date     default null -- business rule date from
  ,p_per_sel_dt_to            in     date     default null -- business rule date to
  ,p_year_from                in     number     default null -- business rule year from
  ,p_year_to                  in     number     default null -- business rule year to
  ,p_cagr_id                  in     number   default null -- Coll agreement id
  ,p_qual_type                in     number   default null
  ,p_qual_status              in     varchar2 default null
  -- 2940151
  ,p_per_sel_freq_cd          in     varchar2 default null
  ,p_concat_segs              in     varchar2 default null
  -- end 2940151
  ,p_abs_historical_mode      in     varchar2 default 'N'
  ,p_gsp_eval_elig_flag       in     varchar2 default null -- GSP Rate Sync : Evaluate Eligibility
  ,p_lf_evt_oper_cd           in     varchar2 default null -- GSP Rate Sync : Life Event Operation code
  ,p_cwb_person_type          in varchar2 default null
  );
-----------------------------------------------------------------------
procedure process
  (errbuf                        out nocopy varchar2
  ,retcode                       out nocopy number
  ,p_benefit_action_id        in     number
  ,p_effective_date           in     varchar2
  ,p_mode                     in     varchar2
  ,p_derivable_factors        in     varchar2 default 'ASC'
  ,p_validate                 in     varchar2 default 'N'
  ,p_person_id                in     number   default null
  ,p_person_type_id           in     number   default null
  ,p_pgm_id                   in     number   default null
  ,p_business_group_id        in     number
  ,p_pl_id                    in     number   default null
  ,p_popl_enrt_typ_cycl_id    in     number   default null
  ,p_lf_evt_ocrd_dt           in     varchar2 default null
  ,p_no_programs              in     varchar2 default 'N'
  ,p_no_plans                 in     varchar2 default 'N'
  ,p_comp_selection_rule_id   in     number   default null
  ,p_person_selection_rule_id in     number   default null
  ,p_ler_id                   in     number   default null
  ,p_organization_id          in     number   default null
  ,p_benfts_grp_id            in     number   default null
  ,p_location_id              in     number   default null
  ,p_pstl_zip_rng_id          in     number   default null
  ,p_rptg_grp_id              in     number   default null
  ,p_pl_typ_id                in     number   default null
  ,p_opt_id                   in     number   default null
  ,p_eligy_prfl_id            in     number   default null
  ,p_vrbl_rt_prfl_id          in     number   default null
  ,p_legal_entity_id          in     number   default null
  ,p_payroll_id               in     number   default null
  ,p_commit_data              in     varchar2 default 'Y'
  ,p_audit_log_flag           in     varchar2 default 'N'
  ,p_lmt_prpnip_by_org_flag   in     varchar2 default 'N'
  ,p_cbr_tmprl_evt_flag       in     varchar2 default 'N'
  -- GRADE/STEP : Added for grade/step benmngle
  ,p_org_heirarchy_id         in     number   default null
  ,p_org_starting_node_id     in     number   default null
  ,p_grade_ladder_id          in     number   default null
  ,p_asg_events_to_all_sel_dt in     varchar2 default null
  ,p_rate_id                  in     number   default null -- pay scale
  ,p_per_sel_dt_cd            in     varchar2 default null -- business rule
  ,p_per_sel_dt_from          in     date     default null -- business rule date from
  ,p_per_sel_dt_to            in     date     default null -- business rule date to
  ,p_year_from                in     number     default null -- business rule year from
  ,p_year_to                  in     number     default null -- business rule year to
  ,p_cagr_id                  in     number   default null -- Coll agreement id
  ,p_qual_type                in     number   default null
  ,p_qual_status              in     varchar2 default null
  -- 2940151
  ,p_per_sel_freq_cd          in     varchar2 default null
  ,p_concat_segs              in     varchar2 default null
  -- end 2940151
  ,p_abs_historical_mode      in     varchar2 default 'N'
  ,p_gsp_eval_elig_flag       in     varchar2 default null  -- GSP Rate Sync : Evaluate Eligibility
  ,p_lf_evt_oper_cd           in     varchar2 default null  -- GSP Rate Sync : Life Event Operation code
  ,p_cwb_person_type          in varchar2 default null
  );
--
procedure restart
          (errbuf                     out nocopy varchar2,
           retcode                    out nocopy number,
           p_benefit_action_id        in  number);
-----------------------------------------------------------------------
procedure person_header
  (p_person_id                in number default null,
   p_business_group_id        in number,
   p_effective_date           in date);
-----------------------------------------------------------------------
procedure evaluate_life_events
  (p_person_id                in number default null,
   p_business_group_id        in number,
   p_mode                     in varchar2,
   p_ler_id                   in out nocopy number,
   -- PB : 5422 :
   -- p_popl_enrt_typ_cycl_id    in number,
   p_lf_evt_ocrd_dt           in date,
   p_effective_date           in date,
   p_validate                 in varchar2 default 'N',           /* Bug 5550359 */
   p_gsp_eval_elig_flag       in varchar2 default null,          /* GSP Rate Sync */
   p_lf_evt_oper_cd           in varchar2 default null);         /* GSP Rate Sync */
-----------------------------------------------------------------------
procedure process_comp_objects
  (p_person_id                in number default null
  ,p_person_action_id         in number
  ,p_object_version_number    in out nocopy number
  ,p_business_group_id        in number
  ,p_mode                     in varchar2
  ,p_ler_id                   in number default null
  ,p_derivable_factors        in varchar2 default 'ASC'
  ,p_cbr_tmprl_evt_flag       in varchar2 default 'N'
  ,p_person_count             in out nocopy number
  -- PB : 5422 :
  ,p_lf_evt_ocrd_dt           in date default null
  -- ,p_popl_enrt_typ_cycl_id    in number
  ,p_effective_date           in date
  ,p_gsp_eval_elig_flag       in varchar2 default null      /* GSP Rate Sync */
  ,p_lf_evt_oper_cd           in varchar2 default null      /* GSP Rate Sync */
  );
-----------------------------------------------------------------------
procedure flush_global_structures;
-----------------------------------------------------------------------
procedure process_life_events
          (p_person_id                in number default null,
           p_person_action_id         in number default null,
           p_object_version_number    in out nocopy number,
           p_business_group_id        in number,
           p_mode                     in varchar2,
           p_ler_id                   in number default null,
           p_person_selection_rule_id in number default null,
           p_comp_selection_rule_id   in number default null,
           -- PB : 5422 :
           -- p_popl_enrt_typ_cycl_id    in number default null,
           p_derivable_factors        in varchar2 default 'ASC',
           p_cbr_tmprl_evt_flag       in varchar2 default 'N',
           p_person_count             in out nocopy number,
           p_error_person_count       in out nocopy number,
           p_lf_evt_ocrd_dt           in date,
           p_effective_date           in date,
           p_validate                 in varchar2 default 'N',       /* Bug 5550359 */
           p_gsp_eval_elig_flag       in varchar2 default null,      /* GSP Rate Sync */
           p_lf_evt_oper_cd           in varchar2 default null );    /* GSP Rate Sync */
-----------------------------------------------------------------------
procedure do_multithread
          (errbuf                     out nocopy varchar2,
           retcode                    out nocopy number,
           p_validate                 in varchar2,
           p_benefit_action_id        in number,
           p_effective_date           in varchar2,
           p_pgm_id                   in number,
           p_business_group_id        in number,
           p_pl_id                    in number,
   -- PB : 5422 :
           p_popl_enrt_typ_cycl_id    in number,
           p_no_programs              in varchar2,
           p_no_plans                 in varchar2,
           p_rptg_grp_id              in number,
           p_pl_typ_id                in number,
           p_opt_id                   in number,
           p_eligy_prfl_id            in number,
           p_vrbl_rt_prfl_id          in number,
           p_mode                     in varchar2,
           p_person_selection_rule_id in number,
           p_comp_selection_rule_id   in number,
           p_derivable_factors        in varchar2,
           p_thread_id                in number,
           p_lf_evt_ocrd_dt           in varchar2,
           p_cbr_tmprl_evt_flag       in varchar2,
           p_lmt_prpnip_by_org_flag   in varchar2,
           p_gsp_eval_elig_flag       in varchar2 default null,      /* GSP Rate Sync */
           p_lf_evt_oper_cd           in varchar2 default null );    /* GSP Rate Sync */
-----------------------------------------------------------------------
procedure cache_person_information
          (p_person_id         in number,
           p_business_group_id in number,
           p_effective_date    in date);
-----------------------------------------------------------------------
/*procedure rebuild_heirarchy
          (p_elig_per_elctbl_chc_id in number);*/
procedure rebuild_heirarchy
          (p_pil_elctbl_chc_popl_id in number);
-----------------------------------------------------------------------
--procedure popu_epe_heir ;
procedure popu_pel_heir ;
-----------------------------------------------------------------------
procedure process_recalculate
          (errbuf                     out nocopy varchar2,
           retcode                    out nocopy number,
           p_benefit_action_id        in number   default null,
           p_effective_date           in varchar2,
           p_mode                     in varchar2,
           p_derivable_factors        in varchar2 default 'ASC',
           p_validate                 in varchar2 default 'N',
           p_person_id                in number   default null,
           p_person_type_id           in number   default null,
           p_pgm_id                   in number   default null,
           p_business_group_id        in number,
           p_pl_id                    in number   default null,
           p_popl_enrt_typ_cycl_id    in number   default null,
           p_lf_evt_ocrd_dt           in varchar2 default null,
           p_no_programs              in varchar2 default 'N',
           p_no_plans                 in varchar2 default 'N',
           p_comp_selection_rule_id   in number   default null,
           p_person_selection_rule_id in number   default null,
           p_ler_id                   in number   default null,
           p_organization_id          in number   default null,
           p_benfts_grp_id            in number   default null,
           p_location_id              in number   default null,
           p_pstl_zip_rng_id          in number   default null,
           p_rptg_grp_id              in number   default null,
           p_pl_typ_id                in number   default null,
           p_opt_id                   in number   default null,
           p_eligy_prfl_id            in number   default null,
           p_vrbl_rt_prfl_id          in number   default null,
           p_legal_entity_id          in number   default null,
           p_payroll_id               in number   default null,
           p_commit_data              in varchar2 default 'Y',
           p_audit_log_flag           in varchar2 default 'N',
           p_lmt_prpnip_by_org_flag   in varchar2 default 'N',
           p_cbr_tmprl_evt_flag       in varchar2 default 'N');
-----------------------------------------------------------------------
procedure init_bft_statistics
  (p_business_group_id in number
  );
-----------------------------------------------------------------------
procedure write_bft_statistics
  (p_business_group_id in number
  ,p_benefit_action_id in number
  );
-----------------------------------------------------------------------
--
-- ABSENCES wrapper header for benmngle process
--
procedure abse_process
  (errbuf                        out nocopy varchar2
  ,retcode                       out nocopy number
  ,p_benefit_action_id        in     number   default null
  ,p_effective_date           in     varchar2
  ,p_mode                     in     varchar2 default 'M'
  ,p_derivable_factors        in     varchar2 default 'ASC'
  ,p_validate                 in     varchar2 default 'N'
  ,p_person_id                in     number   default null
  ,p_pgm_id                   in     number   default null
  ,p_business_group_id        in     number
  ,p_pl_id                    in     number   default null
  ,p_popl_enrt_typ_cycl_id    in     number   default null
  ,p_lf_evt_ocrd_dt           in     varchar2 default null
  ,p_person_type_id           in     number   default null
  ,p_no_programs              in     varchar2 default 'N'
  ,p_no_plans                 in     varchar2 default 'N'
  ,p_comp_selection_rule_id   in     number   default null
  ,p_person_selection_rule_id in     number   default null
  ,p_ler_id                   in     number   default null
  ,p_organization_id          in     number   default null
  ,p_benfts_grp_id            in     number   default null
  ,p_location_id              in     number   default null
  ,p_pstl_zip_rng_id          in     number   default null
  ,p_rptg_grp_id              in     number   default null
  ,p_pl_typ_id                in     number   default null
  ,p_opt_id                   in     number   default null
  ,p_eligy_prfl_id            in     number   default null
  ,p_vrbl_rt_prfl_id          in     number   default null
  ,p_legal_entity_id          in     number   default null
  ,p_payroll_id               in     number   default null
  ,p_commit_data              in     varchar2 default 'Y'
  ,p_audit_log_flag           in     varchar2 default 'N'
  ,p_lmt_prpnip_by_org_flag   in     varchar2 default 'N'
  ,p_abs_historical_mode      in     varchar2 default 'N'
  ,p_cbr_tmprl_evt_flag       in     varchar2 default 'N'
  );
--
-----------------------------------------------------------------------
--
-- iRecruitment wrapper header for benmngle process
--
procedure irec_process
          (errbuf                     out nocopy varchar2,
           retcode                    out nocopy number,
           p_effective_date           in varchar2,
           p_mode                     in varchar2 default 'I',
           p_derivable_factors        in varchar2 default 'ASC',
           p_validate                 in varchar2 default 'N',
           p_person_id                in number   default null,
           p_pgm_id                   in number   default null,
           p_business_group_id        in number,
           p_pl_id                    in number   default null,
           p_popl_enrt_typ_cycl_id    in number   default null,
           p_lf_evt_ocrd_dt           in varchar2 default null,
           p_person_type_id           in number   default null,
           p_no_programs              in varchar2 default 'N',
           p_no_plans                 in varchar2 default 'N',
           p_comp_selection_rule_id   in number   default null,
           p_person_selection_rule_id in number   default null,
           p_ler_id                   in number   default null,
           p_organization_id          in number   default null,
           p_benfts_grp_id            in number   default null,
           p_location_id              in number   default null,
           p_pstl_zip_rng_id          in number   default null,
           p_rptg_grp_id              in number   default null,
           p_pl_typ_id                in number   default null,
           p_opt_id                   in number   default null,
           p_eligy_prfl_id            in number   default null,
           p_vrbl_rt_prfl_id          in number   default null,
           p_legal_entity_id          in number   default null,
           p_payroll_id               in number   default null,
           p_commit_data              in varchar2 default 'Y',
           p_audit_log_flag           in varchar2 default 'N',
           p_lmt_prpnip_by_org_flag   in varchar2 default 'N',
           p_abs_historical_mode      in varchar2 default 'N',
           p_cbr_tmprl_evt_flag       in varchar2 default 'N',
	   p_assignment_id            in number   default null,
	   p_offer_assignment_rec     in  per_all_assignments_f%rowtype) ; ----bug 4621751 irec2
--

procedure Personnel_action_process
          (errbuf                     out nocopy varchar2,
           retcode                    out nocopy number,
           p_benefit_action_id        in number   default null,
           p_effective_date           in varchar2,
           p_mode                     in varchar2,
           p_derivable_factors        in varchar2 default 'ASC',
           p_validate                 in varchar2 default 'N',
           p_person_id                in number   default null,
           p_person_type_id           in number   default null,
           p_pgm_id                   in number   default null,
           p_business_group_id        in number,
           p_pl_id                    in number   default null,
           p_popl_enrt_typ_cycl_id    in number   default null,
           p_lf_evt_ocrd_dt           in varchar2 default null,
           p_no_programs              in varchar2 default 'N',
           p_no_plans                 in varchar2 default 'N',
           p_comp_selection_rule_id   in number   default null,
           p_person_selection_rule_id in number   default null,
           p_ler_id                   in number   default null,
           p_organization_id          in number   default null,
           p_benfts_grp_id            in number   default null,
           p_location_id              in number   default null,
           p_pstl_zip_rng_id          in number   default null,
           p_rptg_grp_id              in number   default null,
           p_pl_typ_id                in number   default null,
           p_opt_id                   in number   default null,
           p_eligy_prfl_id            in number   default null,
           p_vrbl_rt_prfl_id          in number   default null,
           p_legal_entity_id          in number   default null,
           p_payroll_id               in number   default null,
           p_commit_data              in varchar2 default 'Y',
           p_audit_log_flag           in varchar2 default 'N',
           p_lmt_prpnip_by_org_flag   in varchar2 default 'N',
           p_cbr_tmprl_evt_flag       in varchar2 default 'N');
--
-- GRADE/STEP : wrapper header for G mode Operation Code = Progression
--
procedure grade_step_process
  (errbuf                        out nocopy varchar2
  ,retcode                       out nocopy number
  ,p_benefit_action_id        in     number   default null
  ,p_effective_date           in     varchar2
  ,p_mode                     in     varchar2 default 'G'
  ,p_derivable_factors        in     varchar2 default 'ASC'
  ,p_validate                 in     varchar2 default 'N'
  ,p_person_id                in     number   default null
  ,p_pgm_id                   in     number   default null
  ,p_business_group_id        in     number
  ,p_pl_id                    in     number   default null
  ,p_popl_enrt_typ_cycl_id    in     number   default null
  ,p_lf_evt_ocrd_dt           in     varchar2 default null
  ,p_person_type_id           in     number   default null
  ,p_no_programs              in     varchar2 default 'N'
  ,p_no_plans                 in     varchar2 default 'N'
  ,p_comp_selection_rule_id   in     number   default null
  ,p_person_selection_rule_id in     number   default null
  ,p_ler_id                   in     number   default null
  ,p_organization_id          in     number   default null
  ,p_benfts_grp_id            in     number   default null
  ,p_location_id              in     number   default null
  ,p_pstl_zip_rng_id          in     number   default null
  ,p_rptg_grp_id              in     number   default null
  ,p_pl_typ_id                in     number   default null
  ,p_opt_id                   in     number   default null
  ,p_eligy_prfl_id            in     number   default null
  ,p_vrbl_rt_prfl_id          in     number   default null
  ,p_legal_entity_id          in     number   default null
  ,p_payroll_id               in     number   default null
  -- GRADE/STEP : Added for grade/step benmngle
  ,p_org_heirarchy_id         in     number   default null
  ,p_org_starting_node_id     in     number   default null
  ,p_grade_ladder_id          in     number   default null
  ,p_asg_events_to_all_sel_dt in     varchar2 default null
  ,p_rate_id                  in     number   default null -- pay scale
  ,p_per_sel_dt_cd            in     varchar2 default null -- business rule
  ,p_per_sel_dt_from          in     varchar2 default null -- business rule date from
  ,p_per_sel_dt_to            in     varchar2 default null -- business rule date to
  ,p_per_sel_freq_cd          in     varchar2  default null -- 2940151
  ,p_year_from                in     number    default null -- business rule year from
  ,p_year_to                  in     number    default null -- business rule year to
  ,p_cagr_id                  in     number   default null -- Coll agreement id
  ,p_qual_type                in     number   default null
  ,p_qual_status              in     varchar2 default null
  -- 2940151
  ,p_id_flex_num              in     number   default null
  ,p_concat_segs              in     varchar2 default null
  -- end 2940151
  -- GRADE/STEP : End
  ,p_commit_data              in     varchar2 default 'Y'
  ,p_audit_log_flag           in     varchar2 default 'N'
  ,p_lmt_prpnip_by_org_flag   in     varchar2 default 'N'
  ,p_cbr_tmprl_evt_flag       in     varchar2 default 'N'
  );
  --
--
-- GRADE/STEP : wrapper header for G mode Operation Code = Rate Synchronization
-- GSP Rate Sync
procedure grade_step_rate_sync_process
  (errbuf                        out nocopy varchar2
  ,retcode                       out nocopy number
  ,p_benefit_action_id        in     number   default null
  ,p_effective_date           in     varchar2
  ,p_mode                     in     varchar2 default 'G'
  ,p_derivable_factors        in     varchar2 default 'ASC'
  ,p_validate                 in     varchar2 default 'N'
  ,p_person_id                in     number   default null
  ,p_pgm_id                   in     number   default null
  ,p_business_group_id        in     varchar2
  ,p_person_type_id           in     number   default null
  ,p_comp_selection_rule_id   in     number   default null
  ,p_person_selection_rule_id in     number   default null
  ,p_organization_id          in     number   default null
  ,p_benfts_grp_id            in     number   default null
  ,p_location_id              in     number   default null
  ,p_pstl_zip_rng_id          in     number   default null
  ,p_rptg_grp_id              in     number   default null
  ,p_legal_entity_id          in     number   default null
  ,p_payroll_id               in     number   default null
  ,p_org_heirarchy_id         in     number   default null
  ,p_org_starting_node_id     in     number   default null
  ,p_grade_ladder_id          in     number   default null
  ,p_rate_id                  in     number   default null -- pay scale
  ,p_per_sel_dt_cd            in     varchar2 default null -- business rule
  ,p_per_sel_dt_from          in     varchar2 default null -- business rule date from
  ,p_per_sel_dt_to            in     varchar2 default null -- business rule date to
  ,p_per_sel_freq_cd          in     varchar2 default null -- 2940151
  ,p_year_from                in     number   default null -- business rule year from
  ,p_year_to                  in     number   default null -- business rule year to
  ,p_cagr_id                  in     number   default null -- Coll agreement id
  ,p_qual_type                in     number   default null
  ,p_qual_status              in     varchar2 default null
  ,p_id_flex_num              in     number   default null
  ,p_concat_segs              in     varchar2 default null
  ,p_commit_data              in     varchar2 default 'Y'
  ,p_gsp_eval_elig_flag       in     varchar2 default 'N' -- Evaluate Eligibility
  ,p_audit_log_flag           in     varchar2 default 'N'
  ,p_lmt_prpnip_by_org_flag   in     varchar2 default 'N'
  );
end ben_manage_life_events;

/
