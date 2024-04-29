--------------------------------------------------------
--  DDL for Package Body BEN_MANAGE_LIFE_EVENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_MANAGE_LIFE_EVENTS" as
/* $Header: benmngle.pkb 120.28.12010000.7 2009/07/10 11:56:45 vaibgupt ship $ */
--
/*
+========================================================================+
|             Copyright (c) 1997 Oracle Corporation                      |
|                Redwood Shores, California, USA                         |
|                      All rights reserved.                              |
+========================================================================+
*/
/*
Name
    Manage Life Events
Purpose
        This package is used to check validity of parameters passed in via SRS
        or via a PL/SQL function or procedure. This package will then run the
        BENMNGLE process.
History
     Date             Who        Version    What?
     ----             ---        -------    -----
     14 Dec 97        G Perry    110.0      Created.
     15 Dec 97        G Perry    110.1      Changed call to
                                            derive_rates_and_facts.
     04 Jan 98        G Perry    110.2      Added in exception handling
                                            and log file reporting.
     05 Jan 98        G Perry    110.3      Altered parameters so that
                                            they are in a more logical
                                            order.
     07 Jan 98        lmcdonal   110.4      Added call to
                                            create_related_person_ler
     13 Jan 98        G Perry    110.5      Fixed parameter names in main
                                            process_life_events procedure.
                                            Added extra parameters for
                                            person_selection_rule_id and
                                            comp_selection_rule_id in to
                                            called PL/SQL process.
     14 Jan 98        G Perry    110.6      Added caching of comp object
                                            types and messages.
     14 Jan 98        T Mathers  110.7      Added calls to Pate04r5.
     15 Jan 98        G Perry    110.8      Changed cache objects
                                            variables to match real
                                            lookup codes.
     15 Jan 98        G Perry    110.9      Changed p_validate from a
                                            boolean to a character due
                                            to SRS not supporting boolean.
     15 Jan 98        lmcdonal   110.10     Added call to
                                            determine_eligibility.
     16 Jan 98        G Perry    110.11     Added retcode and errbuf
                                            which are needed by SRS.
     18 Jan 98        G Perry    110.12     Added in real messages now
                                            seeded in seed11.
     19 Jan 98        lmcdonal   110.13     Created globals for person,
                                            assignment and life event name.
                                            Add get_ler_name.
     21 Jan 98        G Perry    110.14     Created globals
                                            g_last_person_failed
                                            g_last_plan_failed
                                            g_last_prog_failed
                                            to handle propergation of comp
                                            object failures.
     22 Jan 98        lmcdonal   110.15     Uncomment determine elig.
     24 Jan 98        G Perry    110.16     Fixed call to determine elig
                                            so runs in every mode bar
                                            derivable factor mode.
                                            Added id function which
                                            returns a bracketed number.
     25 Jan 98        G Perry    110.17     Added banner for lers.
     25 Jan 98        G Perry    110.18     Added app_exception exception
                                            handler for row handler errors.
     25 Jan 98        lmcdonal   110.19     Add setting of g_last...failed
                                            to exception routine.
                                            Change 6 locals from number(38)
                                            to number.
     26 Jan 98        lmcdonal   110.20     Call determine elig and evaluate
                                            lers only if person has changed.
     27 Jan 98        G Perry    110.21     Set g_person_changed so that it
                                            takes into account when we get
                                            several identical person_ids
                                            and ler_ids.
     27 Jan 98        G Perry    110.22     Changed commit_all_data proc.
     02 Feb 98        G Perry    110.23     Moved Commit into C code and
                                            passed p_validate to C code.
     02 Feb 98        G Perry    110.24     Changed exception app_exception
                                            call so it just raises an error.
     03 Feb 98        G Perry    110.25     Completely removed
                                            app_exception call and capture
                                            via when others call.
     06 Mar 98        G Perry    110.26     Removed commit_all_data procedure
                                            Added log_benmngle_statistics
                                            Restart, removed lots of logging
                                            messages. Chng looping mechanism
                                            for comp objects so they are done
                                            in one call rather than lots of
                                            seperate calls. Added lots of
                                            caching routines.
     16 Mar 98        G Perry    110.27     Added prtn_eff_strt_dt_rl and
                                            prtn_eff_end_dt_rl into object
                                            cache structure for pl,pgm,oipl.
     08 Apr 98        G Perry    110.28     Added all multithread logic into
                                            package. Added Conc defintion
                                            to allow restart and multithread.
                                            Cached objects only once now.
     09 Apr 98        G Perry    110.29     Backport for BD2.
     09 Apr 98        G Perry    110.30     remove commit in logging part.
     13 Apr 98        G Perry    110.31     Added logging to PLSQL.
     20 Apr 98        G Perry    110.32     Fixed cache errors.
                                            Added error handling to trap
                                            where error occured.
                                            Added exception g_life_event
                                            _after Clears cache each time.
     21 Apr 98        G Perry    110.33     Fixed problem with restart.
     18 May 98        G Perry    110.34     dbsynch up.
     21 May 98        jcarpent   110.35     Added determine enrolment rqmts
     27 May 98        G Perry    110.36     Added in fast formula cover calls.
     27 May 98        jcarpent   110.38     Added elig_per_elctbl_chc_id arg.
     04 Jun 98        G Perry    110.39     Added in reference to fte_value
                                            and total_fte_value. This way we
                                            can cache full time equivalents
                                            this can be used by BENDRPAR.
     04 Jun 98       jcarpent    110.40     Restricted call to bendenrr.
     04 Jun 98       G Perry     110.41     Fixed compilation error and
                                            moved output string to correct
                                            position following change 110.40
     05 Jun 98       G Perry     110.42     Add last place variable to
                                            call before deenrollment.
     07 Jun 98       G Perry     110.43     Changed name of package/proc for
                                            dependent eligibility Added
                                            global for last_pgm_id.
                                            Fixed elig_to_prte_rsn_f bug,
                                            this is only derived in life
                                            event mode.
     07 Jun 98       Ty Hayden   110.44     Added call to ben_determine_coverage
     07 Jun 98       G Perry     110.46     Added in scheduled enrollment
                                            logic.
     08 Jun 98       G Perry     110.47     Removed exit statement.
     08 Jun 98       G Perry     110.48     Fixed skipping of comp objects
                                            when eligibility fails for a plan
                                            or program.
     11 Jun 98       G Perry     110.49     Including logic for temporal
                                            life event processing.
     12 Jun 98       Ty Hayden   110.50     Added call to ben_determine_rates
     12 Jun 98       G Perry     110.51     Fixed error when defaulting
                                            person types for contacts.
     13 Jun 98       G Perry     110.52     Added Message names
                                            Added parameter output.
     14 Jun 98       G Perry     110.53     Added procedure
                                            ben_determine_elct_chc_flx_imp.
     14 Jun 98       G Perry     110.54     Improved life event cursor.
     18 Jun 98       G Perry     110.55     Fixed when ineligible for
                                            program ineligible for plan.
                                            Fixed so that scheduled life
                                            event is not commited.
     08 Jul 98       jcarpent    110.56     Added p_popl_enrt_typ_cycl_id arg
     21 Jul 98       G Perry     110.57     Fixed c_person_life cursor so
                                            subselect only picks up detected
                                            or unprocessed life events.
     30 Jul 98       G Perry     110.58     Fixed cursor for percent full
                                            time stuff from budget values.
                                            Removed hr_lookups from
                                            assignment cursor, this is not
                                            needed.
     03 Aug 98       F Martin    110.59     Reordered queries for greater
                                            efficiency. These now utilise
                                            more efficient indexes.
     06 Aug 98       G Perry     110.60     Added check_business_rules
                                            procedure to easily collate all
                                            business rules.
                                            Fixed bugs 490,491,492,493,494
     10 Aug 98       G Perry     110.61     Added in concurrent request
                                            columns to create_benefit
                                            _actions_api call.
     11 Aug 98       G Perry     110.62     Validate mode now multi-threads.
                                            Moved person_actions code to
                                            new module benbatpe.pkb.
     24 Aug 98       G Perry     110.63     Added new globals to structure
                                            for use in bendenrr.
     26 Aug 98       G Perry     115.33     Moved person_selection_rule
                                            into benbatpe.pkb.
                                            Fixed wwbug 1129.
     27 Aug 98       G Perry     115.34     Fixed bug 608.
                                            problem was outer-join to
                                            per_assignment_budget_values.
     28 Aug 98       G Perry     115.35     Added check to test for whether
                                            electable choices were written
                                            for a life event that was being
                                            processed.
     28 Aug 98       G Perry     115.36     Removed logic where we store all
                                            old potential life event info.
     23 Sep 98       G Perry     115.37     Split up code so Prasad can do
                                            his whatif functionality in
                                            stages.
     24 Sep 98       G Perry     115.38     Added in code to copy action id
                                            to global structure for Prasad.
     07 Oct 98       G Perry     115.39     Corrections following schema
                                            issues. Added slave logic.
     15 Oct 98       G Perry     115.40     Added new cache info for oipl.
     20 Oct 98       J Carpenter 115.41     Added new cache info for pl+pgm.
     20 Oct 98       J Carpenter 115.42     Added new columns to pgm cache
     24 Oct 98       T Guy       115.43     Moved call to ben_determine_rate
                                            inside people loop.  Added column
                                            person_id to call.
     25 Oct 98       G Perry     115.45     Added ben_generate_communications
     26 Oct 98       G Perry     115.46     Added hourly_salaried_code to
                                            assignment select to go in cache
     30 Oct 98       G Perry     115.47     Added in logic for unrestricted
                                            enrollment and multiple scheduled
                                            enrollment.
     31 Oct 98       G Perry     115.49     Fixed error messages.
     02 Nov 98       G Perry     115.50     Used new call to get parameters.
     10 Nov 98       G Perry     115.51     Validate mode now regularly
                                            commits to the logfile. All
                                            modes now use true
                                            multithreading. Made master
                                            process drive from a cursor
                                            rather than a global. Used
                                            new mathod of writing to cache
                                            structure rather than
                                            ben_reporting table.
     23 Nov 98       G Perry     115.52     Added support for rates and
                                            factors which means that call
                                            to determine_elig_prfls and
                                            derive_rates_and_factors have
                                            new parameters.
     07 Dec 98       G Perry     115.53     Added support for object
                                            selection rule.
     17 Dec 98       G Perry     115.54     Added caching logic for logging
                                            info.
     21 Dec 98       G Perry     115.55     Fixed cussor to just bring back
                                            unrestricted for unrestricted
                                            mode.
     22 Dec 98       T Guy       115.56     Added ben_determine_rate_chg

     28 Dec 98       J Lamoureux 115.57     Commented out nocopy parameters dflt_
                                            enrt_dt and elcn_made_dt in call
                                            to person_life_event.
     31 Dec 98       G Perry     115.58     Added people group to cache
                                            and commented out nocopy rate change
                                            call. tanie to fix.
     01 Jan 99       G Perry     115.59     Global g_number_proc_objects was
                                            not being reset to 0 in multi-
                                            thread process.
     02 Jan 99       G Perry     115.60     Added call to ben_cel_cache proc.
     02 Jan 99       G Perry     115.61     Fixed cache_person_ler_information.
     18 Jan 99       G Perry     115.62     LED V ED
     18 Jan 99       T Guy       115.63     added lf_evt_ocrd_dt to rate change
                                            call.
     25 Jan 99       G Perry     115.64     Added p_mode variable so that
                                            we only call certain stuff under
                                            certain conditions. Makes the
                                            run faster.
     08 Feb 99       G Perry     115.65     Added in parameter
                                            ptnl_ler_trtmt_cd in call to
                                            derive rates and factors.
     11 Feb 99       G Perry     115.66     Fixed error trace message prior
                                            to evaluate life events call.
     17 Feb 99       G Perry     115.67     Added once_r_cntug_cd and elig
                                            flag param to determine_elig_
                                            prfls and derive_part_and_rate_
                                            facts.
     18 Feb 99       G Perry     115.68     Support for canonical dates.
     24 Feb 99       G Perry     115.69     Support for restart process.
     26 Feb 99       T Guy       115.70     Added ben_determine_chc_ctfn
     27 Feb 99       G Perry     115.71     Added Concurrent request id to
                                            log. Added business_group_id
                                            parameter to check_all_slaves
                                            _finished procedure.
     03 Mar 99       G Perry     115.72     Fixed unrestricted mode so it
                                            creates batch_ler_info record.
     09 Mar 99       G Perry     115.73     Changed c_pln cursor so it
                                            picks up all plans if none are
                                            specified for an enrollment
                                            period. Bug 1924.
     15 Mar 99       G Perry     115.75     Changed parameter order of
                                            process procedure per bug 1529.
     22 Mar 99       Tmathers    115.76     Changed -MON- to /MM/
     05 Apr 99       mhoyes      115.78   - Un-datetrack of per_in_ler_f changes
                                          - Removed DT restriction from
                                            process_rows/c_ler_exists.
                                          - Modified calls to per_in_ler and
                                            ptnl_ler_for_per APIs
     16-mar-99       pbodla      115.79   - If the supplied mode  and mode of
                                            winning life event differ, raise
                                            error. p_enrt_perd_id parameter
                                            added to create_ptnl_ler_for_per
                                            in C mode.
     21-APR-99       mhoyes      115.80   - Added p_popl_enrt_typ_cycl_id to
                                            all calls to create_ptnl_ler_for_per
     22-APR-99       GPerry      115.81     Added call set_potential_ler_id.
                                            for temporal mode.
     22-APR-99       mhoyes      115.82   - Modified call to
                                            create_ptnl_ler_for_per and
                                            update_ptnl_ler_for_per
     23-APR-99       GPerry      115.83     Added p_mode to evaluate life
                                            event call.
     22-APR-99       mhoyes      115.84     Modified per in ler calls.
     29-APR-99       shdas       115.85     Added to parameter list of
                                            benutils.formula.
     06-May-99       TGuy        115.86     uncommented rate change call
     06-MAY-99       shdas       115.87     Added jurisdiction_code.
     06-May-99       bbulusu     115.89     Added original_hire_date to the
                                            person cache.
     06-May-99       GPerry      115.90     Backport for Fidelity.
     06-May-99       GPerry      115.91     Leapfrog from 115.89
     10-May-99       GPerry      115.92     Backport Fix.
     10-May-99       GPerry      115.93     Leapfrog from 115.91
     14-May-99       GPerry      115.94     Support for PLIP and PTIP.
     15-May-99       GPerry      115.95     Fix for Bug 2107. Ensure only
                                            active comp objects are included.
     18-May-99       GPerry      115.96     Added calls to environment routine.
                                            Now we capture the message correctly
                                            through the app_exception and
                                            g_record_error exceptions.
                     lmcdonal    115.97     Added rudimentary p_comp_object_name
                                            for ptip and plip.  Also increase
                                            length of comp object name in log.
     20-May-99       jcarpent    115.98     Change enrt_perd_for_pl query to
                                            handle no record condition and
                                            allow no rows for flex and impt inc
     27-May-99       G Perry     115.99     Changed c_pgm cursor so we pick
                                            up cobra programs last.
     02-May-99       bbulusu     115.100    Added 3 columns to c_person cursor
                                            to fetch into the g_cache_person.
     06-Jun-99       stee        115.101    Added 3 new cursors,c_pgm2,c_pln2,
                                            c_oipl2 to build_comp_object
                                            to process the COBRA program last.
     09-Jun-99       stee        115.102    Only process COBRA last if in
                                            life event or unrestricted mode.
     16-Jun-99       bbulusu     115.103    Added call to ben_person_object to
                                            cache info for person being procssed
     18-Jun-99       G Perry     115.104    Removed FTE code and derived factor
                                            life event stuff. This is all
                                            cache on demand in the
                                            ben_person_object and
                                            ben_seeddata_object packages.
     21-Jun-99       mhoyes      115.105    Added new trace messages.
     23-Jun-99       G Perry     115.106    Added resetting calls to setenv
                                            so that flags are reset correctly.
     25-Jun-99       G Perry     115.107    Added call to ben_life_object.
                                            Removed ben_person_object routine
                                            as cache is cache on demand.
     25-Jun-99       G Perry     115.108    Added p_rec to ben_comp_object.
                                            set_object call.
     28-Jun-99       mhoyes      115.109    Added new trace messages.
     28-Jun-99       tguy        115.110    Added new call to
                                            ben_determine_actual_premium.main
     01-JUL-99       pbodla      115.111    Changes related with << Life Event Collision >>
                                            added call to get_ori_bckdt_pil()
                                            added call to p_lf_evt_clps_restore()
     05-JUL-99       mhoyes      115.112  - Externalised c_pln_nip to
                                            ben_pln_cache.nipplnpln_getdets.
                                          - Added new trace messages.
     07-JUL-99       mhoyes      115.113  - Backed out nocopy c_pln_nip cache.
     07-JUL-99       shdas       115.114    Added setenv for business_group in evaluate_life_events.
     08-JUL-99       mhoyes      115.115  - Added new trace messages.
     09-JUL-99       mhoyes      115.116  - Added new trace messages.
                                          - Removed + 0s from all cursors.
     19-JUL-99       stee        115.117  - Fixed c_pln cursor to limit
                                            check for enrd_perd_for_pl by
                                            business_group_id. Also, do
                                            not call actual premium if
                                            no choices are created.
     20-JUL-99       GPerry      115.118    genutils -> benutils package rename
     26-JUL-99       GPerry      115.119    Removed ben_timing stuff.
     26-JUL-99       GPerry      115.120    Added calls to dt_fndate.
                                            Added call to new
                                            create_perf_benefit_actions to
                                            reduce bottleneck.
                                            Added call to clear_down_cache in
                                            benutils package.
     26-JUL-99       GPerry      115.121    Removed setenv for business_group
                                            in evaluate_life_events.
     27-JUL-99       mhoyes      115.122  - Fixed genutil problems.
     29-JUL-99       mhoyes      115.123  - Assigned globals to locals in
                                            process_comp_objects.
                                          - Added new trace messages.
                                          - Modified references to benutils.
                                            to bentype.
     10-AUG-99       Gperry      115.124    Removed global references to
                                            g_cache_person and the like.
                                            Rewrote person_header.
     24-AUG-99       Gperry      115.125    Fixed p_no_plans flag so it
                                            only applies to plans not in
                                            programs.
     26-AUG-99       Gperry      115.126    Added call to benefits assignment
                                            if employee assignment is null.
     31-AUG-99       Gperry      115.127    Changed call to ptnl_ler_for_per.
     31-AUG-99       mhoyes      115.128  - Added new trace message.
     01-SEP-99       Gperry      115.129    Changed call to determine
                                            eligibility.
     14-SEP-99       Gperry      115.130    Fixed bug 2907. Life event occurred
                                            date is now passed to automatic
                                            enrollment routine.
     15-SEP-99       Gperry      115.131    Added audit log flag to main
                                            process procedure.
     28-SEP-99       Stee        115.132    Changed where clause to select
                                            COBRA pgms with a pgm_typ like
                                            'COBRA%' instead of COBRA.
     28-SEP-99       tguy        115.133    Moved closing of per_in_ler to
                                            after rate change check.  This
                                            allows us to avoid duplication
                                            and throughing off counts for
                                            reporting purposes
     04-OCT-99       mhoyes      115.134  - Tuned build_comp_object_list.
                                            Replaced c_pln and c_oipl with
                                            bgpcpp_getdets and bgpcop_getdets.
     04-OCT-99       stee        115.135  - Added ptip_id to
                                            g_cache_person_prtn.
     04-OCT-99       mhoyes      115.136  - Added calls to flush_global_structures
                                            to clear build_comp_object_list
                                            plip and oipl caches.
     08-OCT-99       jcarpent    115.137  - Moved auto_enrt to after rates
                                            are created. Fixed some calling_
                                            proc tokens
     13-OCT-99       gperry      115.138    Fix bug 2703.
     13-OCT-99       gperry      115.139    Fix bug 2960.
     25-OCT-99       gperry      115.140    Fix bug 3103.
     03-NOV-99       mhoyes      115.141  - Added comp object filtering
                                            to improve performance. After
                                            BENDETEL when the comp object
                                            for the person is still in-eligible
                                            or first time in-eligible then all
                                            other processing in the loop is
                                            skipped.
     13-NOV-99       mhoyes      115.142  - Added trace messages.
     14-NOV-99       gperry      115.143    Added mode to ben_batch_reporting
                                            package call.
     19-NOV-99       GPERRY      115.144    Added new flags.
     22-NOV-99       PBODLA      115.145    Bug : 3511 : When a potential already
                                            sitting and benmngle is ran in scheduled
                                            mode with a effective date other than
                                            life event occured date a duplicate
                                            potential is being created and benmngle
                                            is stopping. Use lf_evt_ocrd_dt instead
                                            of effective_date in the where clause
                                            of c_ler_exists.
     24-NOV-99       mhoyes      115.146  - Bug : 3511 : Modified c_ler_exists
                                            to restict by not in VOIDD and PROCD
                                            rather than only DTCTD or UNPROCD
                                          - Removed obsolete c_ler_exists cursor
                                            from c_ler_exists.
     24-NOV-99       jcarpent    115.147  - Added more bendenrr globals so pil can
                                            be closed when no auto/electable epes
                                            are created.
     12-DEC-99       pbodla      115.148  - Modified c_ler_exists to look for
                                            DTCTD or UNPROCD ( chaged not in to in
                                            part of where clause)
     22-DEC-99       gperry      115.149    Modified create_life_person_actions
                                            call which occurred due to fix in
                                            1096742.
     30-DEC-99       maagrawa    115.150    Added parameter business_group_id.
                                            to ben_determine_rate_chg.main
     03-FEB-00       mhoyes      115.156  - Added HPAPRTTDE and HPADPNTLC to
                                            call to generate communications.
                                          - Modified process_comp_object to
                                            process local l_comp_obj_tree.
                                          - Fixed problem with app_exception. The
                                            error from process_life_events is
                                            now suppressed rather than raised. The
                                            error is raised when max errors is
                                            reached.
                                          - Rolled back to pre-filtering.
     07-FEB-00       mhoyes      115.157  - Modified/Added trace messages for
                                            profiling.
                                          - Fixed bug 1178659. Error was being
                                            raised from the g_record_error
                                            exception because life event occured
                                            date had not been derived. Set the
                                            life event occured date to the
                                            effective date.
     10-FEB-00       mhoyes      115.158  - Fixed bug 1169238. The eligibility
                                            profile cache was not being cleared
                                            down from build_comp_object_list.
                                            Called ben_elp_cache.clear_down_cache
                                            when comp object list is re-built.
                                          - Added clear_init_benmngle_caches to
                                            clear caches and globals at the
                                            benmngle level. This should also be
                                            called from on-line benmngle.
                                          - Added call to
                                            ben_person_object.clear_down_cache
                                            from flush_global_structures. This
                                            means that person cache information
                                            is cleared between multiple benmngle
                                            runs.
     21-Feb-00     lmcdonal      115.159    load ptip id thru calls to setenv.
                                            Bug 1179550.
     25-Feb-00     mhoyes        115.160  - Added trace messages.
                                          - Bug 1179550. Nullified ptip id and
                                            plip_id values to avoid multiple
                                            program issues.
                                          - Revamped elig flags to uses a local
                                            record structure rather than globals.
                                          - Passed p_comp_obj_tree_row into
                                            determine_eligibility. Currently
                                            dual supporting ben_env_object
                                            comp object globals in parallel
                                            with p_comp_obj_tree_row. Bendrpar
                                            totally uses p_comp_obj_tree_row but
                                            bendetel, bendete2 and benwtprc still
                                            need to be moved over.
     27-Feb-00     stee         115.161  -  Added new parameter,
                                            p_cbr_tmprl_evt_flag.
     28-Feb-00     stee         115.162  -  Pass p_cbr_tmprl_evt_flag to
                                            update benefits action.
     28-Feb-00     stee         115.163  -  Pass p_cbr_tmprl_evt_flag to
                                            all relevant procedures.
     01-MAR-00     pbodla       115.164  -  Bug 4186 : Added csd_by_ptnl_ler_for_per
                                            to create_related_person_ler call.
     01-MAR-00     pbodla       115.165  -  Do not run restore if electable choices
                                            are not created
     01-MAR-00     pbodla       115.166  -  Bug : 4293/1172230 : Message to indicate
                                            in what mode benmngle to run in case the
                                            supplied mode is different.
     02-MAR-00     stee         115.167  -  Update COBRA qualified beneficiary
                                            information if COBRA electable
                                            choices exist.
     03-MAR-00     mhoyes       115.168  -  Phased out nocopy ben_env_object for comp
                                            objects.
     04-MAR-00     mhoyes       115.169  -  Added comp object cache parameters to
                                            load_cache.
                                         -  Stored parent comp object ID values
                                            on the comp object cache.
                                         -  Added support for elig_tran_state.
                                            Phased out nocopy first_inelig and
                                            still_inelig flags.
     04-MAR-00     mhoyes       115.170  -  Modified build_comp_object_list to
                                            process one comp object per cache
                                            row.
                                         -  Revamped comp object list to reflect
                                            the new cache struture.
     04-MAR-00     mhoyes       115.171  -  Fixed problem with parent elig flag
                                            at ptip and plip levels.
     05-MAR-00     mhoyes       115.172  -  Fixed problem with cobra oipls
                                            in build comp object list. The
                                            parent comp object information
                                            was not being populated.
     05-MAR-00     stee         115.173  -  Update cobra eligibility
                                            only in life event or
                                            unrestricted mode.
     06-MAR-00     gperry       115.174     Changed process_life_events to use
                                            nocopy so that we can use locals
                                            to trap the number of errors.
                                            Also made sure that when max errors
                                            is hit the process stops.
     07-MAR-00     mhoyes       115.175   - Moved build comp object list out
                                            to ben_comp_object_list package
                                            file bebmbcol.pkh.
     08-MAR-00     mhoyes       115.176   - Added trace messages for profiling.
     13-MAR-00     mhoyes       115.177   - Phase 5 performance. Implemented
                                            PTIP level comp object filtering
                                            in process_comp_objects.
     14-MAR-00     mhoyes       115.178   - Phase 7 performance. Implemented
                                            PLIP level comp object filtering
                                            in process_comp_objects.
                                          - Initialised comp object cache
                                            global from
                                            clear_init_benmngle_caches.
                                          - Phase 8 performance. Implemented
                                            plan and oipl level comp object
                                            filtering in process_comp_objects.
                                          - created set_up_cobj_part_elig and
                                            moved set_up_part_elig from
                                            build comp object list to
                                            process comp objects.
     15-MAR-00     mhoyes       115.179   - Modified get_comp_object_name so
                                            that comp object ids are not
                                            truncated from the audit log.
     17-MAR-00     mhoyes       115.190   - Fixed eligible parent flag problems.
     18-MAR-00     mhoyes       115.181   - Fixed filtering problems at PTIP
                                            and PLIP levels.
     21-MAR-00     pbodla       115.182   - Bug : 4919 :  c_ler_exists modified
                                           ; do not create potential even if a
                                            processed potetial exists.
     23-MAR-00     mhoyes       115.183   - Bug : 4965 :  Fixed PLIP and Plan
                                            level newly in-eligible problems.
                                          - Fixes COBRA related coverage problem.
     24-MAR-00     mmogel       115.184   - Added p_ntfn_dt to the call to
                                            ben_ptnl_ler_for_per_api.create_
                                            ptnl_ler_for_per in Procedure
                                            evaluate_life_events (bug 4806/
                                            1247107)
     28-MAR-00     mhoyes       115.185   - Fixed benmngle caching issue. Added
                                            pgm_id restriction to plan and oipl
                                            level restrictions when checking
                                            previous eligibility in
                                            check_prevelig_compobj.
     29-MAR-00     mhoyes       115.186   - Fixed 5009. Modified cursors in
                                            check_prevelig_compobj to use
                                            par_pgm_id rather than pgm_id.
     30-MAR-00     mhoyes       115.187   - Fixed 1190876. Added logic and
                                            routines to eliminate duplicate
                                            PTIP processing.
                                          - Turned off filtering in temporal
                                            mode.
     30-Mar-00     maagrawa     115.188   - For reporting purposes, to get
                                            total person persons processed, add
                                            persons processed successfully
                                            and persons errored. (1133281).
     31-Mar-00     gperry       115.189     Added oiplip support.
     31-Mar-00     gperry       115.190     Fixed WWBUG 1178676.
     01-Apr-00     stee         115.191     Create benefit assignment
                                            for dependent if he/she
                                            is found ineligible.
     04-Apr-00     mhoyes       115.192   - Fixed duplicate PTIP problem at
                                            PTIP filtering level for multiple
                                            PTIPs wnen track in-eligibility is
                                            Y.
    06-Apr-00      lmcdonal     115.193     debugging messages.
    06-Apr-00      stee         115.194     Check cobra requirements even
                                            if choices are not electable.
    10-Apr-00      stee         115.195     Only update cobra eligibility
                                            dates if event is a cobra qualifying
                                            event.
    12-Apr-00      mhoyes       115.196   - Fixed 5075. Initialised eligible flag
                                            on the duplicate PTIP global in
                                            check_dupproc_ptip so that
                                            it defaults to false. This prevents
                                            parent eligibility flags being set
                                            incorrectly when the PTIP is filtered.
                                            Previously un-initialised the value
                                            defaulted to true causing the PTIP
                                            to be filtered and the plip below to be
                                            processed.
    14-Apr-00      pbodla       115.197   - Fixed 5093 : When unrestircted ptnl's
                                            created notification date is populated.
    14-Apr-00      stee         115.198     Update cobra info if mode is
                                            Unrestricted( for core customers).
    21-Apr-00      gperry       115.199     Fixed bug 5062 by testing for
                                            whether a PTIP has been found when
                                            filtering happened at the PTIP
                                            level.
    01 May 00      pbodla       115.200  -  Task 131 : Elig dependent rows are
                                            created before creating the electable
                                            choice rows. Called procedures
                                            ben_determine_dpnt_eligibility.main()after
                                            calling ben_determine_eligibility.determine_elig_prfls.
                                            p_upd_egd_with_epe_id called after
                                            electable choice is created to set
                                            electable choice id on dependent rows.
    12 May 00      mhoyes       115.201  -  Pulled filtering out nocopy of benmngle into
                                            ben_comp_obj_filter.
    12 May 00      stee         115.202  -  Fix c_get_inelig_dpnt_info cursor.
    15 May 00      mhoyes       115.203  -  Called get_comp_object_name
                                            procedure only when audit log flag
                                            is Y.
    22 May 00      mhoyes       115.204  -  Revamped set_up_cobj_part_elig so that
                                            cached current and parent rows are
                                            passed down through bendetel and
                                            bendete2.
    23 May 00      mhoyes       115.205  -  Passed p_comp_obj_tree_row into
                                            enrolment_requirements.
    24 May 00      mhoyes       115.206  -  Called ben_pil_object.clear_down_cache
                                            from flush_global_structures.
    26 May 00      pbodla       115.207  -  Bug 5123 : Added p_run_mode, p_enrt_perd_id
                                            parameters to determine_elig_prfl proc.
    31-May-00      gperry       115.208     BP of 115.198 with thread fix.
    31 May 00      mhoyes       115.209  -  Passed through cuurent comp object rows
                                            into bendenrr.
    05 Jun 00      stee         115.210  -  Move electable chc certification
                                            process into the comp object loop.
                                            wwbug #1308629.
    22 Jun 00     kmahendr      115.211  -  Added a cursor in process_comp_objects procedure
                                            to check whether pil_elctbl_popl_stat is to be
                                            updated to PROCD - wwbug #1277369
    26 Jun 00     stee          115.212  -  Change p_derivable_factors to a
                                            code.
    27 Jun 00     mhoyes        115.213  -  Fixed temporal mode audit log problem.
                                         -  Moved person cache calls out nocopy of bendetel
                                            and into process_comp_objects.
    28 Jun 00     jcarpent      115.214  -  Bug 5176, 1329041. Pass more args
                                            to bebmfilt.pkb filter_comp_objects.
    29 Jun 00     mhoyes        115.215  -  Passed mode_cd to create_normal_person_actions.
    05 Jul 00     mhoyes        115.216  -  Passed context parameters through to bendrpar.
    10 Jul 00     mhoyes        115.217  -  Bypassed filtering in temporal mode.
    13 Jul 00     mhoyes        115.218  -  Removed context parameters.
    19 Jul 00     jcarpent      115.218  -  5241,1343362. Added update_defaults
    26 Jul 00     gperry        115.219     Fixed BUG 5422/1365397.
                                            SCheduled enrollment now voided
                                            when no changes made to elig,
                                            elect, rates, etc.
    02 Aug 00     mhoyes        115.220  -  Moved call to set_temporal_ler_id
                                            outside of process_comp_object loop.

    24 Aug 00     mhoyes        115.221  -  Memory leaking fixes for bug 1387371.
    05 Sep 00     pbodla        115.222  -  Bug 5422 : Allow different enrollment periods
                                            for programs for a scheduled  enrollment.
                                            p_popl_enrt_typ_cycl_id is removed.
    06 Sep 00     jcarpent      115.223  -  Leapfrog version based on 115.221
                                            Fixes bug 1398444.  Participation
                                            cache was not cleared between people
    06 Sep 00     jcarpent      115.224  -  Merged version of 115.222 with 115.223.
    18-Sep-00     pbodla        115.225  - Healthnet changes : PB : Added parameter
                                           p_lmt_prpnip_by_org_typ_id to
                                           Comp objects are now selected based on person's
                                           organization id if p_lmt_prpnip_by_org_typ_id is
                                           Y.
    22-Sep-00     gperry        115.226    Added back param
                                           p_popl_enrt_typ_cycl_id as otherwise
                                           do_multithread bombs.
                                           WWBUG 1412825.
    25-Sep-00     gperry        115.227    Added call to reset life event
                                           occurred date when BENMNGLE errors
                                           in eveluate_life_events procedure.
                                           WWBUG 1412614.
    26-Sep-00     gperry        115.228    Fixed WWBUG 1412808.
                                           Clear pil_cache for cases where a
                                           backout may have occurred that
                                           called communications.

    27 Sep 00     pbodla        115.229    - Code added due to BUG 5422/1365397,
                                            in version 115.219 is removed.
                                           - Pil no longer required to be voided
                                             if there is no impact of it on
                                             eligibility, rates etc.,. It should
                                             become processed.
    05 Oct 00     gperry        115.230    Fixed call to ben_determine_eligibility
                                           so that it passes the life event
                                           occurred date as p_effective_date
                                           when run in selection mode. This
                                           is due to how least work in bendete2
                                           for Prasads fixes.
    06 Oct 00     pbodla        115.231    -- Above fix is removed as, the
                                           fix should be in bendete2.pkb
    13 Oct 00     rchase        115.232    ensure caches are cleared properly
                                           when processing comp objects.
    19 OCT 00     rchase        115.233    wwBug1427383 - return correct date for
                                           creating dependent benefit assignment
    07 Nov 00     mhoyes        115.234  - Added comp object loop electable choice
                                           context global.
                                         - Added clear down cache call for the
                                           electable choice list.
    08 Nov 00     vputtiga      115.235  - Fixed Bug 1485814.
                                           g_enrollment_change global set to FALSE.
                                           added a call at end of process_comp_objects to
                       ben_prtt_enrt_result.update_person_type_usages
                                           Leapfrog based on 115.233.
    15 Nov 00     jcarpent      115.236    Merged version of 115.235 and 115.234
    22 Nov 00     tmathers      115.238    Merged version of 115.236 and 115.237
    05 Jan 01     kmahendr      115.239    Unrestricted life event process changes
    16 Jan 01     mhoyes        115.240  - Raised the oracle error code for the
                                           generic 91665 error.
    18 Jan 01     mhoyes        115.242  - Leapfrog of 115.240.
    23 Jan 01     mhoyes        115.242  - Modified the call to coverage for EFC.
    22 Mar 01     mhoyes        115.244  - Fixed multi-threading problem with
                                           g_ler_id which was only being set in
                                           the master and not the slaves.
    28 Mar 01     gvenkata      115.245  - Bug 1696526.  Was using lf_evt_ocrd_dt
                                           from previous person for caching assignment.
                                         - Bug 1636071.  In call to benmgle from
                                           benauthe g_modified_mode was not being
                                           used so open events were not working.
   09 Apr  01    kmahendr       115.246  - Bug 1543462 - If life event is opened and closed
                                           in the same run, benmngle is to use least of sysdate or
                                           effective_date to update processed date for active
                                           life event
   23 May  01    mhoyes         115.247  - Added refresh cache call for benelmen cache.
   01 Jul  01    kmahendr       115.248  - Unrestricted process changes
   18 Jul  01    ikasire        115.249    Commented the call to default enrollment
                                           see details in bug 1874263 or in this
                                           package at the place of call to
                                           ben_manage_default_enrt.Process_default_enrt
  19 Jul  01     kmahendr        115.250 - Bug#1871579- Effective date is greater
                                           than unrestricted life event started date
                                           benmngle errors out. made changes to
                                           call ben_person_object.get_object and
                                           ben_determine_derive_factors
  30 Jul  01     pbodla          115.251 - Bug : 1894718 Also treat the electable
                                           choices associated with suspended
                                           enrollments as in pending work flow.
                                           In other words do not delete the electable
                                           choices data and other data if the
                                           enrollment is in suspended state.
  02-Aug-01      ikasire         115.251   Bug 1895846 added two new procedures
                                           delete_in_pndg_elig_dpnt and
                                           reset_elctbl_chc_inpng_flag
                                           see bug for more details
  28-Aug-01      kmahendr        115.252   updating of ben_enrt_rt in U mode
                                           removed - Bug#1936976
  11-Aug-01      kmahendr        115.253   Bug#1900657-Added codes in procedure
                                           process_comp_objects
  25-Sep-01      kmahendr        115.254   Made changes for R mode - private
                                           procedure update_elig_row added
  26-Sep-01      kmahendr        115.255   In R mode report for error not called
  26-Sep-01      kmahendr        115.256   Only Activity Summary not called
  05-Oct-01      kmahendr        115.257   Bug#2032672-added l_mode = C before
                                           checking of electbl choice created
                                           call
  08-Oct-01      kmahendr        115.259   115.257 brought forward as version
                                           115.258 was a leap frog version of
                                           115.251 and fix of 115.257
  26-Oct-01      maagrawa        115.260   Backported to 115.252
                                           Do not create choices for "Save for
                                           Later" ICD entries.
  26-Oct-01      maagrawa        115.261   115.259 + 115.260.
  09-Nov-01      mhoyes          115.262 - Fixed 2105125. Added hint to always
                                           use index in cursor c_range_thread.
                                           This avoids a full table lock on
                                           ben_batch_ranges when running
                                           multi-threaded.
  30-Nov-01      mhoyes          115.263 - Made p_benefit_action_id in/out on
                                           process.
  03-Dec-01      mhoyes          115.264 - Re-enabled mode validation.
  03-Dec-01      mhoyes          115.265 - dbdrv line.
  04-Dec-01      kmahendr        115.266 - Bug#2097833 - parameter -p_per_in_ler_id
                                           is added to ben_determine_dpnt_eligibility.
                                           main call
  06-Dec-01      mhoyes          115.267 - Fixed concurrent manager problem
                                           with new CAGR OUT NOCOPY parameter on process.
                                           Added new routine inner_process.
  07-Dec-01      mhoyes          115.268 - Passed p_per_in_ler_id to
                                           enrolment_requirements.
  11-Dec-01      mhoyes          115.269 - Passed p_per_in_ler_id to
                                           update_defaults.
  19-Dec-01      pbodla          115.270 - CWB Changes : New mode W added for
                                           processing comp work bench events.
  27-Dec-01      pbodla          115.271 - CWB Changes : Added
                                           popu_cross_gb_epe_data - to create
                                           pil, epe, pel, ecr data for managers
                                           who are in different business group
                 ikasire         115.271 - CWB Changes : Added popu_epe_heir
                                           to populate performace table.
  04-Jan-02      pbodla          115.272 - CWB Changes : Call procedure
                                           popu_cross_gb_epe_data only in W
                                           mode
  07-Jan-02      rpillay         115.273 - Added Set Verify Off.
  07-Jan-02      pbodla          115.274 - CWB Changes : Also delete the rows
                                           for employees who do not have
                                           subordinates and with level -1
  08-Jan-02      ikasire         115.275   Bug 2172031 changes the order of
                                           parameters in cwb_process
  11-Jan-02      ikasire         115.276   Added a new public procedure
                                           rebuild_heirarchy for rebuilding
                                           the CWB hierarchy.
  11-Jan-02      ikasire         115.277   More changes to popu_epe_heir and
                                           rebuild_heirarchy
  11-Jan-02      ikasire         115.278   Bug 2172036 changed a call to
                                           after making it from function to
                                           procedure with extra assignment_id
                                           column.
  18-Jan-02      mhoyes          115.279 - Fixed restart null benefit action
                                           problem. Introduced by CAGR.
  01-Feb-02      stee            115.280 - Update cobra information for
                                           a life event type of 'ENDDSBLTY'.
                                           Bug#2068332.
  12-Feb-02      mhoyes          115.281 - Added write_bft_statistics and
                                           init_bft_statistics.
                                         - Moved delete_elctbl_choice and
                                           update_in_pend_flag to
                                           ben_manage_unres_life_events.
  12-Feb-02      mhoyes          115.282 - Removed dbms_output.
  15-Feb-02      rpillay         115.283 - Bug# 2214961 removed check for
                                           Ineligibility (l_continue_loop)
                                           for CWB (l_mode = 'W')
  19-Feb-02     ikasire          115.284   Bug 2172036 and 2231371 fixes
                                           popu_cross_gb_epe_data was not
                                           passing assignment_id in the
                                           creation of epe
  27-Feb-02     pabodla          115.285   Bug 2237993 CWB - moved
                                           popu_cross_gb_epe_data call form
                                           process_rows to internal_process
                                           to avoid creating duplicate records
                                           for the cross business group.
  11-Mar-02     mhoyes           115.286   Dependent eligibility tuning.
  20 Mar 02     tjesumic         115.287   PTIP caching data is refreshed when the
                                           current row ptip_id is not matching with
                                           cached ptip_id  bug 2228464
  25-Mar-02     rpillay          115.289   Fixed CWB Bugs 2270672 and 2275257
  13-Jun-02     mhoyes           115.290 - Test harness changes for family Pack C.
                                           Called populate_benmngle_rbvs.
  15-Jul-02     mhoyes           115.291 - Moved out nocopy start_slaves, grab_next_batch_range
                                           and check_all_slaves_finished to
                                           ben_maintain_benefit_actions.
  26-Jul-02     pbodla           115.292 - ABSENCES - Added procedure abse_process
                                           to process absences. All the changes for
                                           absence processing are identified with
                                           ABSENCES tag.
  17-Jul-02     kmahendr         115.293 - ABSENCES - Added looping in process_rows.
  24-Jul-02     mmudigon         115.294 - ABSENCES - Added logic for exiting out nocopy of loop
                                           in case of error
  14-Aug-02     stee             115.295   COBRA: If person is no longer
                                           enrolled in a COBRA program and
                                           has no enrollment opportunity,
                                           terminate COBRA eligibility.
                                           Bug: 1794808.
  30-Aug-02     ikasire          115.296   CWB Hierarcy changes Bugs 2541072 and 2541065
  05-Sep-02     lakrish          115.297   Exception g_record_error handled in do_multithread
                                           - raised by build_comp_object_list
  13-Sep-02     pbodla           115.298   2288042 Create 0 level heirarchy data if
                                           manager is processed first and
                                           employee is processed later benmngle run.
  18-Sep-02     pbodla           115.299   2288042 Create 0 level heirarchy :
                                           tested in hrcwbdvl.
  25-Sep-02     pbodla           115.300   Bug 2574791 : modified popu_hrchy and
                                           rebuild_hrchy to make reassign employee
                                           work.
  28-Oct-02     kmahendr         115.301   Bug#2638681 - effective date is passed instead
                                           of lf_evt_ocrd_dt for creating person actions
  29-Oct-02     mmudigon         115.302   CWB: Bug 2526595 Added proc
                                           del_cwb_pil()
  18-Nov-02     pbodla           115.303   ABSE: 2673323 For every absence life event
                                           recache the person data.
                                           In absence mode several life events
                                           may be processed in single run, so
                                           lf_evt_ocrd_dt may change, so recache
                                           the person data as of current life
                                           event otherwise leads to inconsistent
                                           eligibility.
  01-Dec-02     pabodla          115.304   Arcsing the file with CWB itemization
                                           code as commented.
  09-Dec-02     mmudigon         115.305   CWB itemization code uncommented.
  18-Dec-02     kmahendr         115.306   Bug#2718215 - logic for updating elcns_made_dt
                                           in update_enrt_rt procedure changed
  31-Dec-02     pbodla           115.307   Bug#2712602 - CWB : When a comp
                                           per in ler is backed out nocopy and rerun
                                           again rebuild the heirarchy.
  23-Jan-03     mmudigon         115.308   CWB itemization: Added rt edits.
  25-Jan-03     pbodla           115.309   GRADE/STEP : added code to support
                                           grade/step processing.
  25-Jan-03     pbodla           115.310   Modified cursor c3 to remove errors.
  29-Jan-03     kmahendr         115.311   Added a wrapper for Personnel Action Mode
  30-Jan-03     pbodla           115.312   Added a wrapper for Grade/step
                                           progression participation process.
  06-feb-2003   nhunur           115.313   Commented cursor c2 and an validation in
                                           check_business_rules for bug - 2784150
  10-feb-2003   pbodla           115.314   GRADE/STEP : Added code to support
                                           grade/step processing.
  14-Feb-2003   mmudigon         115.315   CWB itemization: bug fix 2793785
                                           modified cursor c5 in check_business
  14-Feb-2003   rpillay          115.316   HRMS Debug Performance changes to
                                           hr_utility.set_location calls
  24-Feb-2003   mmudigon         115.317   CWB itemization: Bug fix 2801671
                                           Make ineligible for plan if not elig
                                           for any options
  07-Mar-2003   nhunur           115.318   Modified code to handle error messages
                                           properly. Bug - 2836770.
  14-Mar-2003   lakrish          115.319   Bug 2840078 check that cwb plans/options
                                           do not have coverages attached
  10-Apr-2003   mhoyes           115.320 - Bug 2900255 - enabled baseline mode
                                           for the test harness.
  11-Apr-2003   tjesumic         115.321 - # 2899702 if the setup is auto enrollment Person Type usages
                                            are not create.created in close enrollement
                                            because the multi edit is not called , Person Type usages
                                            created in multiedit
                                            autoenrollment calls update_person_type_usages
                                            with  g_enrollment_change true
  27-Apr-03     mmudigon         115.322 - Absences July FP enhancements.
                                           Additional param p_abs_historical_mode
  01-Aug-03     rpgupta		 115.323 - 2940151 Grade/ step
  					   1. added some parameters to grade_step_process
  					   2. Added some checks to procedure
  					      check_business_rules
  19-Aug-03     ikasire          115.324   2940151 GSP Added New Procedure gsp_proc_dflt_auten
                                           and call after determine_rates.
                                           Need to include pqgspdef.pkh and pqhgsppp.pkh files
                                           along with this version.
  20-Aug-03     rpgupta		 115.325 - 2940151 Grade/ step
  					   Fixed issues in check_business_rule
  21-Aug-03     mmudigon         115.326 - 2940151 Grade/ step. Loop through
                                           all GSP potential LEs
  01-Sep-03     hmani            115.327 - 3087889 Passed lf_evt_ocrd_dt to
					   set_up_cobj_part_elig proc instead of effective_date
  16-Sep-03     pbodla           115.328 - GSP : mode specific get_active_life_
                                           event procedure is called.
  22-Sep-03     rpgupta          115.329 - GSP: Passed GSP parameters from procedure
                                                grade_step_process to procedure
process
  26-Sep-03     stee             115.330 - 2894200: If derivable factors
                                           parameter is 'NONE' and there are
                                           derived factors attached to a
                                           compensation object, set it to the
                                           default parameter.
  11-Nov-03     ikasire          115.331   setting g_no_ptnl_ler_id to evaluate in drpar
                                           not to trigger potential life events for
                                           U,M,W,I,P,A Modes - BUG 3243960
  26-Nov-03     pbodla           115.332   3216667 : iss_val, mx_elcn_val,
                                           mn_elcn_val are passed to cloned rows.
  22-Dec-03     Indrasen         115.333   CWBGLOBAL New Procedure
  10-Jan-04     tjesumic         115.334   new cursor c9 added in check_business_rule to validate
                                           the cwb task for the budget flag
  20-Jan-04     ikasire      115.335/338   ben_pep_cache.clear_down_cache called after call to
                                           ben_enrolment_requirements.update_defaults as it uses
                                           a different effective date
  21-Jan-04     ikasire          115.339   Added p_trace_plans_flag to CWBGLOBAL procedure

  02-Feb-04     pbodla           115.340   GLOBALCWB : Error
                                           BEN_91769_NOONE_TO_PROCESS is not
                                           relevant for CWB.
                                           Cursor C5 modified such that
                                           worksheet rates are not relevant for
                                           group plan.
 16-Feb-04      kmahendr         115.341   Bug#3420298 - dpnt_eligibility calls made in R
                                           mode
 17-Feb-04      kmahendr         115.343   Leapfrog version of 115.341
 18-Feb-04      tjesumic         115.344   cwb edit , cursor c10,c11 created , c5 edited
 18-Feb-04      tjesumic         115.345   cwb edit
 23-Feb-04      mmudigon         115.346   GSP: Selective Eligibility evaluation
                                           Changes in process_comp_objects proc
 27-Feb-04      pbodla           115.347   GLOBALCWB: procedure update_cwb_epe
                                           modified not to delete the epe,
                                           calls to del_cwb_pil etc are commented.
 02-Mar-04      tjesumic         115.348   cwb cursor c6 validation removed
 08-Mar-04      abparekh         115.349   Modified Cursor c2 in check_business_rules to check
                                           that more than one similar type of CWB Rates (except
                                           CWBAHE, CWBGP, CWBRA)  are not attached to the same
                                           Plan : Bug 3482033
 07-Apr-04      pbodla           115.350   FONM : Added fonm functionality.
                Tilak
 12-Apr-2004    nhunur           115.351   Bypass generate_communication for GSP mode.
 22-Apr-2004    pbodla           115.352   FONM : clear the caches if previous
                                           coverage date is different from current.
                                           New GLOBALCWB messages  added.
                                           Some Commented code is deleted.
 28-May-04      mmudigon         115.353   OSP fixes to process multiple LEs
 31-May-04      abparekh         115.354   Bug : 3658807 Set the message name in evaluate_life_events
                                           before raising exception g_record_error.
 16-Jun-04      mmudigon         115.355   GSP fixes to process multiple LEs
 18 Aug 04      tjesumic         115.356   ptip_id  parameter added for csd_rsd determination
                                           fonm validated for every comp object
 23 Aug 04      mmudigon         115.357   CFW. Call to ben_carry_forward
                                           2534391 :NEED TO LEAVE ACTION ITEMS
 03-Sep-04      abparekh         115.358   3870204 : Don't error out when criteria does not select
                                           any person. Give message in audit log and complete with Normal status.
 28-Sep-04      hmani            115.359   IREC - Front Port of 115.343.15102.4
 30-Sep-04      abparekh         115.360   IREC - Set G_LER_ID in do_multithread for subsequent use.
 15-Oct-04      abparekh         115.361   GSP Rate Sync changes
 18-Oct-04      abparekh         115.362   GSP Rate Sync changes
 18-Oct-04      abparekh         115.363   Bug 3964719 : GSP : Get employee step only when progression style
                                           is not Grade Progression.
 03-Nov-04      abparekh         115.364   Bug 3975857 Changed definition and usage of cursor C2 in
                                           check_business_rules procedure so that validation works correctly
 03-Nov-04      kmahendr         115.365   Bug#3903126 - global variable g_derivable_factor
                                           assigned value inside do_multithread procedure
 03-Nov-04      pbodla           115.366   GLOBALCWB :Bug#3968065-Added call to
                                           sum_oipl_rates_and_upd_pl_rate
 15-Nov-04      kmahendr         115.367   Unrest. enh changes
 03-Dec-04      ikasire          115.368   BUG 4046914
 14-Dec-04      pbodla           115.369   bug 4040013 - when sum_oipl_rates_an...
                                           procedure is called, plan id is going as null
                                           so l_cwb_pl_id is passed.
 06-Jan-05      ikasire          115.370   Bug 4064635 a call to new Procedure got added
                                           Look for dependent package changes
 31-Jan-05      abparekh         115.371   Bug 4149182 Commented the check to prevent rates at plan level
                                           when options attached to the plan.
 14-Jan-05      bmanyam          115.372/373 Bug: 4128034. CWB Mode fnd_session needs to be set.
 22-feb-05      nhunur           115.374   Bug : 4199099 - Task for group plan need not be 'A'
 24-feb-05      tjesumic         115.375   Bug : 4204020 - cache_person_information called after determing LE date
 25-Feb-05      abparekh         115.376   Added procedure person_header_new and called it
                                           from process_life_events to separate caching from peson header
 29-Feb-05      pbodla           115.377   4214845 : To not skip the comp object
                                           processing if parent object is ineligible.
 08-mar-05      nhunur           115.378   GSI Netherlands issue. Added condition to get GRE info
                                           only for US leg code.
 10-Mar-05      mmudigon         115.380   Bug 4194337. Added calls to
                                           set_parent_elig_flags in proc
                                           update_elig_per_rows
 24-Mar-05      pbodla           115.381   Bug 4258498 - Moved the carry forward results call
                                           after the reinstate call, so that reinstate first
                                           attempt to get back the enrollments first.
 25-Mar-05      abparekh         115.382   Bug 4245975 : Rollback in exception g_life_event_after
                                           only for G, M modes
 07-Apr-05      mmudigon         115.383   Bug 4234501. Removed Rollback in
                                           exception  g_life_event_after
 14-Apr-05      kmahendr         115.384   Bug#4291122 - added newly_ineligible condition
                                           to call enrolment_requirement
 22-apr-05      nhunur           115.385   All threads should have fnd_sessions populated for FF.
 05-May-05      tjesumic         115.386   Fonm Clearing cache for fonm date date is fixed
 23-May-05      mmudigon         115.387   Rank and Score Call added
 01-jun-05      pbodla           115.388   Bug 4258200 : Budget and reserve rates
                                           can be attached to local plans so that the
                                           data is copied over in the event of
                                           cloning of cwb data.
 28-jun-05      nhunur           115.389   for GSP chk elig at PGM level for all prog styles.
 26-jul-05      ssarkar          115.390   Bug 4496944 : Handled exception thrown by person_header_new .
 03-Aug-05      rbingi           115.391   Bug 4394545: Erroring if cwb_process(BENCOMOD) is submitted through SRS
                                                        (Not by other Conc Request)
 12-Sep-05      ikasire          115.392   Bug 4463267 added new procedure call update_susp_if_ctfn_flag
 22-sep-05      ssarkar          115.393   Bug 4621751 irec2 -- offer assignment
 06-Oct-05      rbingi           115.394   Bug 4640014 Added call to ben_manage_unres_life_events.clear_epe_cache
 10-nov-05      ssarkar          115.395   IREC2: Called post_irec_process_update.
 17-nov-05      nhunur           115.396   bug - 4743143 - gsp changes in check_business_rules, grade_step_process.
 03-Jan-06      nhunur           115.397   cwb - changes for person type param.
 02-Feb-06      swjain           115.398   CWB Thread Num Enhancement
 08-Feb-06      abparekh         115.399   Bug 4875181 - Added p_run_rollup_only to cwb_global_process
 28-Feb-06      kmahendr         115.400   Added ben_reopen_ended_result call for
                                           GM issue - Fidelity
 14-mar-06      nhunur           115.401   bug 5090149 for cwb
 16-Mar-06      kmahendr         115.402   Bug#5089721-added codes to update_elig_per
                                           proc
 23-Mar-06      kmahendr         115.403   Bug#5100083 - added parameters to call
                                           ben_reopen_ended_result
 04-APR-06      ssarkar          115.404   Bug 5055119 - added end_date_elig_per_rows
 22-May-06      pbodla           115.405   Bug 5232223 - Added code to handle the trk inelig flag
                                           If trk inelig flag is set to N at group plan level
                                           then do not create cwb per in ler and all associated data.
 29-jul-06      nhunur           115.406   CAGR fix for person selection
 20-Sep-06      abparekh         115.407   Bug 5550359 : Passed p_validate correctly to benptnle
                                                         Added p_validate to PROCESS_LIFE_EVENTS
                                                         and EVALUATE_LIFE_EVENTS
 21-sep-06      nhunur           115.408   bug 5534550 - call reopen only for L or C modes
 17-oct-06      stee             115.409   bug 5364920 - pass per_in_ler_id to
                                           ben_generate_communication.
 30-oct-06      gsehgal          115.410   bug 5618436 - changed in print parameters
 16-Nov-06      maagrawa         115.411   5666180. Remove the cwb check (c7)
                                           which prevented plan with only one
                                           salary component.
 22-Jan-07      rtagarra         115.412   ICM Changes.
 06-Aug-07      rtagarra         115.415   Bug 6321565 : For 'R' mode corrected the if condition to call benutils.get_ler.
 04-Dec-07	krupani		 115.419   Incorporated changes of defer deenrollment, Bug 6519622, Bug 6373951,
					   Bug 6373951 and Bug 6390880 from branchline to mainline
 10-Mar-08      krupani          115.421   Bug 6404338.  Min Max enhancement incorporated in R12 mainline
 12-Aug-08      pvelugul         120.28.12010000.2 Bug 6872010: Cleared global variables
                                           g_fonm_cvg_strt_dt and  g_fonm_rt_strt_dt
                                           in clear_init_benmngle_caches
 12-Aug-08      pvelugul         120.28.12010000.3 Bug 6806014: While processing open, if the winner life event is
                                           a normal life event(mode 'L'), then change the mode on the fly
                                           to 'L' from 'C', instead of raising an exception
 17-Apr-09    ksridhar          120.28.12010000.4   Bug 7374364: Added calls to ben_use_cvg_rt_date.clear_fonm_globals
 17-Apr-09      ksridhar        120.28.12010000.5   Bug 6491682: For mode S (MPE), passed per_in_ler_id while calling
                                           ben_person_object.get_object to fetch pil row.
 30-Apr-09     krupani          120.28.12010000.6   Forward ported fix of bug 8290746
*/
--------------------------------------------------------------------------------
--
g_package             varchar2(80) := 'ben_manage_life_events';
g_max_errors_allowed  number;
--
-- Process information
--
g_proc_rec ben_type.g_batch_proc_rec;
g_action_rec ben_type.g_batch_action_rec;
g_strt_tm_numeric number;
g_end_tm_numeric number;
g_prev_sysdate date := sysdate;
g_opt_exists boolean;
--
-- Bug 2574791
--
g_rebuild_pl_id            number := null;
g_rebuild_lf_evt_ocrd_dt   date := null;
g_rebuild_business_group_id   number := null;
--
g_debug boolean := hr_utility.debug_enabled;
--

procedure clear_init_benmngle_caches
  (p_business_group_id in     number
  ,p_effective_date    in     date
  ,p_threads           in     number default null
  ,p_chunk_size        in     number default null
  ,p_max_errors        in     number default null
  ,p_benefit_action_id in     number default null
  ,p_thread_id         in     number default null
  )

is
  --
begin
  g_debug := hr_utility.debug_enabled;
  --
  -- Set up benefits environment
  --
  ben_env_object.init
    (p_business_group_id => p_business_group_id
    ,p_effective_date    => p_effective_date
    ,p_thread_id         => p_thread_id
    ,p_chunk_size        => p_chunk_size
    ,p_threads           => p_threads
    ,p_max_errors        => p_max_errors
    ,p_benefit_action_id => p_benefit_action_id
    );
  --
  -- Reset value of globals
  --
  g_elig_for_pgm_flag   := null;
  g_elig_for_pl_flag    := null;
  g_trk_inelig_flag     := null;
  g_last_pgm_id         := null;
  g_output_string       := null;
  --
  -- Flush all global structures
  --
  -- bug 6872010
  g_fonm_cvg_strt_dt    := null;
  g_fonm_rt_strt_dt     := null;
  -- bug 6872010

  flush_global_structures;
  benutils.g_benefit_action_id := p_benefit_action_id;
  benutils.g_thread_id := p_thread_id;
  --
  -- Initialise comp object list globals
  --
  ben_comp_object_list.init_comp_object_list_globals;
  --
end clear_init_benmngle_caches;
--
/*  GSP Rate Sync */
procedure get_grade_step_placement
  (p_person_id          in number,
   p_assignment_id      in number,
   p_business_group_id  in number,
   p_effective_date     in date,
   p_gsp_pgm_id         out nocopy number,
   p_gsp_plip_id        out nocopy number,
   p_gsp_oipl_id        out nocopy number,
   p_prgr_style         out nocopy varchar2,
   p_gsp_emp_step_id    out nocopy number,
   p_gsp_num_incr       out nocopy number) is
--
l_proc          varchar2(80);
l_exc_grade     EXCEPTION;
l_exc_step      EXCEPTION;
--
begin
  --
  l_proc := g_package || '.get_grade_step_placement';
  --
  hr_utility.set_location('Entering : ' || l_proc, 10);
  --
  -- Get Grade Ladder (PGM_ID) and Grade (PLIP_ID) placement
  pqh_gsp_post_process.get_persons_gl_and_grade
  (p_person_id            => p_person_id,
   p_business_group_id    => p_business_group_id,
   p_effective_date       => p_effective_date,
   p_persons_pgm_id       => p_gsp_pgm_id,
   p_persons_plip_id      => p_gsp_plip_id,
   p_prog_style           => p_prgr_style);

  if p_prgr_style not in ('PQH_GSP_GP')
  then
    --
    -- Get Step placement
    pqh_gsp_default.get_emp_step_placement
    (p_assignment_id        => p_assignment_id,
     p_effective_date       => p_effective_date,
     p_emp_step_id          => p_gsp_emp_step_id,
     p_num_incr             => p_gsp_num_incr);

    -- Get the OIPL_ID (Step)
    p_gsp_oipl_id := pqh_gsp_hr_to_stage.get_oipl_for_step
                             (p_step_id        => p_gsp_emp_step_id,
                              p_effective_date => p_effective_date);
    --
  end if;
  --
  hr_utility.set_location('Leaving : ' || l_proc, 20);
  --
exception
  --
  when others
  then
    --
    if p_gsp_plip_id is null or p_gsp_pgm_id is null
    then
      --
      fnd_message.set_name('BEN','BEN_94094_PERSON_GRADE_NOT_FND');
      --
    elsif p_gsp_emp_step_id is null or p_gsp_oipl_id is null
    then
      --
      fnd_message.set_name('BEN','BEN_94095_PERSON_STEP_NOT_FND');
      --
    end if;
    --
    raise g_record_error;
    --
end get_grade_step_placement;
--
procedure check_business_rules
    (p_business_group_id        in number,
     p_derivable_factors        in varchar2,
     p_validate                 in varchar2,
     p_no_programs              in varchar2,
     p_no_plans                 in varchar2,
     p_mode                     in varchar2,
     p_effective_date           in date,
     p_person_id                in number,
     p_person_selection_rule_id in number,
     p_person_type_id           in number,
     p_pgm_id                   in number,
     p_pl_id                    in number,
     p_ler_id                   in number,
     p_pl_typ_id                in number,
     p_opt_id                   in number,
     p_lf_evt_ocrd_dt           in date,
     p_org_heirarchy_id         in number   default null,
     p_org_starting_node_id     in number   default null,
     p_asg_events_to_all_sel_dt in date   default null,
     p_per_sel_dt_cd            in varchar2   default null,
     p_per_sel_dt_from          in date default null,
     p_per_sel_dt_to            in date default null,
     p_year_from                in number default null,
     p_year_to                  in number default null,
     p_qual_type                in number default null,
     p_qual_status              in varchar2 default null,
     p_lf_evt_oper_cd           in varchar2 default null
  ) is
     -- PB : 5422 :
     -- p_popl_enrt_typ_cycl_id    in number) is
  --
  l_package               varchar2(80) := g_package||'.check_business_rules';
  l_dummy                 varchar2(1);
  l_rec                   benutils.g_active_life_event;
  l_ler_rec               benutils.g_ler;
  l_effective_start_date  date;
  l_effective_end_date    date;
  l_ptnl_ler_for_per_id   number;
  l_object_version_number number;
  l_per_in_ler_id         number;
  l_opt_count             number;
  l_cwbdb_count           number;
  l_cwbwb_count           number;
  l_cwbr_count            number;

  --
  cursor c1 is
    select null
    from   per_person_type_usages_f ppu
    where  ppu.person_id = p_person_id
    and    ppu.person_type_id = p_person_type_id
    and    p_effective_date
           between ppu.effective_start_date
           and     ppu.effective_end_date;
  --
  -- CWB Change Bug 2275257
  --
  --Bug : 3482033
  cursor c2 is
    select null
    from ben_acty_base_rt_f abr
    where abr.pl_id = p_pl_id
    and abr.acty_typ_cd like 'CWB%'
    and abr.acty_typ_cd not in ('CWBAHE')    -- Bug 3975857 - Removed codes CWBRA,CWBGP
    and abr.acty_base_rt_stat_cd = 'A'
    and abr.business_group_id = p_business_group_id
    and nvl(p_lf_evt_ocrd_dt,p_effective_date)
        between abr.effective_start_date
        and     abr.effective_end_date
    group by abr.acty_typ_cd
    having count(*) > 1;
  --Bug : 3482033
  --
  cursor c3 is
  select enp.uses_bdgt_flag,
         enp.prsvr_bdgt_cd,
         DECODE(pln.pl_id,pln.group_pl_id,'Y','N') Group_plan
    from ben_enrt_perd enp,
         ben_popl_enrt_typ_cycl_f pet,
         ben_pl_f  pln
   where pet.pl_id = p_pl_id
     and pet.business_group_id = p_business_group_id
     and enp.popl_enrt_typ_cycl_id = pet.popl_enrt_typ_cycl_id
     and enp.asnd_lf_evt_dt  = p_lf_evt_ocrd_dt
     and pln.pl_id   = p_pl_id
     and nvl(p_lf_evt_ocrd_dt,p_effective_date) between
         pet.effective_start_date and pet.effective_end_date
     and nvl(p_lf_evt_ocrd_dt,p_effective_date) between
         pln.effective_start_date and pln.effective_end_date
     ;
  c3_rec c3%rowtype;

  cursor c4 is
  select count(decode(abr.acty_typ_cd,'CWBDB',1,0)),
         count(decode(abr.acty_typ_cd,'CWBWB',1,0)),
         count(decode(abr.acty_typ_cd,'CWBR',1,0))
    from ben_acty_base_rt_f abr
   where abr.acty_typ_cd in ('CWBDB','CWBWB','CWBR')
     and abr.acty_base_rt_stat_cd = 'A'
     and abr.business_group_id = p_business_group_id
     and nvl(p_lf_evt_ocrd_dt,p_effective_date) between
         abr.effective_start_date and abr.effective_end_date
     and (abr.pl_id = p_pl_id or
          abr.oipl_id in
              (select oipl.oipl_id
                 from ben_oipl_f oipl
                where oipl.pl_id = p_pl_id
                  and oipl.business_group_id = p_business_group_id
                  and nvl(p_lf_evt_ocrd_dt,p_effective_date) between
                      oipl.effective_start_date and oipl.effective_end_date
              )
         );

  --if plan or option has CWBDB and it should have CWBWB
  cursor c5 is
  select 'x'
    from ben_acty_base_rt_f abr1
   where
    ( abr1.acty_typ_cd in ('CWBDB')
      and abr1.acty_base_rt_stat_cd = 'A'
      and abr1.business_group_id = p_business_group_id
      and nvl(p_lf_evt_ocrd_dt,p_effective_date) between
         abr1.effective_start_date and abr1.effective_end_date
      and (abr1.pl_id = p_pl_id or
          abr1.oipl_id in
              (select oipl.oipl_id
                 from ben_oipl_f oipl
                where oipl.pl_id = p_pl_id
                  and oipl.business_group_id = p_business_group_id
                  and nvl(p_lf_evt_ocrd_dt,p_effective_date) between
                      oipl.effective_start_date and oipl.effective_end_date
              )
         )
      and not exists
         (select 'x'
            from ben_acty_base_rt_f abr2
           where abr2.acty_typ_cd = 'CWBWB'
             and abr2.acty_base_rt_stat_cd = 'A'
             and abr2.business_group_id = p_business_group_id
             and nvl(p_lf_evt_ocrd_dt,p_effective_date) between
                 abr2.effective_start_date and abr2.effective_end_date
             and nvl(abr2.pl_id,-1) = nvl(abr1.pl_id,-1)
             and nvl(abr2.oipl_id,-1) = nvl(abr1.oipl_id,-1)
         )
      ) OR
     --if plan or option has CWBWB and it should have CWBDB
     ( abr1.acty_typ_cd in ('CWBWB')
      and abr1.acty_base_rt_stat_cd = 'A'
      and abr1.business_group_id = p_business_group_id
      and nvl(p_lf_evt_ocrd_dt,p_effective_date) between
         abr1.effective_start_date and abr1.effective_end_date
      and (abr1.pl_id = p_pl_id or
          abr1.oipl_id in
              (select oipl.oipl_id
                 from ben_oipl_f oipl
                where oipl.pl_id = p_pl_id
                  and oipl.business_group_id = p_business_group_id
                  and nvl(p_lf_evt_ocrd_dt,p_effective_date) between
                      oipl.effective_start_date and oipl.effective_end_date
              )
         )
      and not exists
         (select 'x'
            from ben_acty_base_rt_f abr2
           where abr2.acty_typ_cd = 'CWBDB'
             and abr2.acty_base_rt_stat_cd = 'A'
             and abr2.business_group_id = p_business_group_id
             and nvl(p_lf_evt_ocrd_dt,p_effective_date) between
                 abr2.effective_start_date and abr2.effective_end_date
             and nvl(abr2.pl_id,-1) = nvl(abr1.pl_id,-1)
             and nvl(abr2.oipl_id,-1) = nvl(abr1.oipl_id,-1)
         )
      )  ;


  cursor c6 is
  select 'x'
    from ben_acty_base_rt_f abr1
   where abr1.acty_typ_cd in ('CWBDB')
     and abr1.acty_base_rt_stat_cd = 'A'
     and abr1.business_group_id = p_business_group_id
     and nvl(p_lf_evt_ocrd_dt,p_effective_date) between
         abr1.effective_start_date and abr1.effective_end_date
     and (abr1.pl_id = p_pl_id or
          abr1.oipl_id in
              (select oipl.oipl_id
                 from ben_oipl_f oipl
                where oipl.pl_id = p_pl_id
                  and oipl.business_group_id = p_business_group_id
                  and nvl(p_lf_evt_ocrd_dt,p_effective_date) between
                      oipl.effective_start_date and oipl.effective_end_date
              )
         )
     and not exists
         (select 'x'
            from ben_acty_base_rt_f abr2
           where abr2.acty_typ_cd in ('CWBES')
             and abr2.acty_base_rt_stat_cd = 'A'
             and abr2.business_group_id = p_business_group_id
             and nvl(p_lf_evt_ocrd_dt,p_effective_date) between
                 abr2.effective_start_date and abr2.effective_end_date
             and nvl(abr2.pl_id,-1) = nvl(abr1.pl_id,-1)
             and nvl(abr2.oipl_id,-1) = nvl(abr1.oipl_id,-1)
         );

  cursor c7 is
  select count(opt.opt_id)
    from ben_opt_f opt
   where opt.component_reason is not null
     and nvl(p_lf_evt_ocrd_dt,p_effective_date) between
         opt.effective_start_date and opt.effective_end_date
     and opt.opt_id in
         (select oipl.opt_id
            from ben_oipl_f oipl
           where oipl.pl_id = p_pl_id
             and oipl.business_group_id = p_business_group_id
             and nvl(p_lf_evt_ocrd_dt,p_effective_date) between
                 oipl.effective_start_date and oipl.effective_end_date);

 --
 -- Cursor c8 added for Bug 2840078
 --
 cursor c8 is
 select 'x' found
   from ben_cvg_amt_calc_mthd_f ccm,
        ben_pl_typ_f pt,
        ben_pl_f pl
  where pl.pl_id  =  p_pl_id
    and pt.pl_typ_id =  pl.pl_typ_id
    and pt.opt_typ_cd = 'CWB'
    and (ccm.pl_id = pl.pl_id or
           ccm.oipl_id in
              (select oipl.oipl_id
                 from ben_oipl_f oipl
                where oipl.pl_id = pl.pl_id
                  and oipl.business_group_id = p_business_group_id
                  and nvl(p_lf_evt_ocrd_dt,p_effective_date) between
                      oipl.effective_start_date and oipl.effective_end_date
              )
        )
    and ccm.business_group_id = p_business_group_id
    and nvl(p_lf_evt_ocrd_dt,p_effective_date) between ccm.effective_start_date and ccm.effective_end_date
    and pl.business_group_id = p_business_group_id
    and nvl(p_lf_evt_ocrd_dt,p_effective_date) between pl.effective_start_date and pl.effective_end_date
    and pt.business_group_id = p_business_group_id
    and nvl(p_lf_evt_ocrd_dt,p_effective_date) between pt.effective_start_date and pt.effective_end_date;


   cursor c9 is
   select 'x'
     from  ben_cwb_wksht_grp cwg
    where  cwg.pl_id = p_pl_id ;
      -- and  cwg.status_cd = 'A'  ; bug 4199099

   -- to find wheether there is any option
  cursor c10 is
    select 'x' found
    from   ben_oipl_f oipl
    where  oipl.pl_id = p_pl_id
      and  oipl.business_group_id = p_business_group_id
      and  nvl(p_lf_evt_ocrd_dt,p_effective_date) between
           oipl.effective_start_date and oipl.effective_end_date ;


  -- rate is attached to plan
  cursor c11 is
  select  'x' found
    from ben_acty_base_rt_f abr
   where abr.acty_typ_cd in ('CWBDB','CWBWB','CWBR')
     and abr.acty_base_rt_stat_cd = 'A'
     and abr.business_group_id = p_business_group_id
     and nvl(p_lf_evt_ocrd_dt,p_effective_date) between
         abr.effective_start_date and abr.effective_end_date
     and abr.pl_id = p_pl_id
         ;
 -- iRec
 cursor c_irec_rptg_grp is
 select null
   from ben_rptg_grp bnr
  where bnr.business_group_id = p_business_group_id
    and bnr.rptg_prps_cd = 'IREC';
 --

 -- GSP Rate Sync
 cursor c_gsp_rate_sync_ler is
 select null
   from ben_ler_f ler
  where ler.typ_cd = 'GSP'
    and ler.lf_evt_oper_cd = 'SYNC'
    and ler.business_group_id = p_business_group_id
    and p_effective_date between ler.effective_start_date
                             and ler.effective_end_date;
 --
begin
  --
  if g_debug then
    hr_utility.set_location ('Entering '||l_package,10);
  end if;
  --
  -- This procedure checks validity of parameters that have been passed to the
  -- BENMNGLE process.
  --
  -- Check if mandatory arguments have been stipulated
  --
  hr_api.mandatory_arg_error(p_api_name       => l_package,
                             p_argument       => 'p_business_group_id',
                             p_argument_value => p_business_group_id);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_package,
                             p_argument       => 'p_mode',
                             p_argument_value => p_mode);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_package,
                             p_argument       => 'p_effective_date',
                             p_argument_value => p_effective_date);
  --
  --
  hr_api.mandatory_arg_error(p_api_name       => l_package,
                             p_argument       => 'p_no_programs',
                             p_argument_value => p_no_programs);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_package,
                             p_argument       => 'p_no_plans',
                             p_argument_value => p_no_plans);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_package,
                             p_argument       => 'p_validate',
                             p_argument_value => p_validate);
  --
  -- Business Rule Checks
  --
  -- p_no_plans and p_no_programs can not be both 'Y'
  --
  if p_no_plans = 'Y' and
     p_no_programs = 'Y' then
    --
    fnd_message.set_name('BEN','BEN_91391_NO_PLAN_PROG');
    fnd_message.raise_error;
    --
  end if;
  --
  -- p_person_selection_rule_id and p_person_id are mutually exclusive
  --
  if p_person_id is not null and
     p_person_selection_rule_id is not null then
    --
    fnd_message.set_name('BEN','BEN_91745_RULE_AND_PERSON');
    fnd_message.raise_error;
    --
  end if;
  --
  -- p_no_plans = 'Y' then p_pl_id and p_opt_id must be null
  --
  if p_no_plans = 'Y' and
    (p_pl_id is not null or
     p_opt_id is not null) then
    --
    fnd_message.set_name('BEN','BEN_91746_PROGRAMS_ONLY');
    fnd_message.raise_error;
    --
  end if;
  --
  -- p_no_programs = 'Y' then p_pgm_id must be null
  --
  if p_no_programs = 'Y' and
     p_pgm_id is not null then
    --
    fnd_message.set_name('BEN','BEN_91747_PLANS_ONLY');
    fnd_message.raise_error;
    --
  end if;
  --
  -- p_person_id must be of p_person_type_id
  --
  if p_person_id is not null and
     p_person_type_id is not null then
    --
    -- Make sure person is of type person type
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        fnd_message.set_name('BEN','BEN_91748_PERSON_TYPE');
        fnd_message.raise_error;
        --
      end if;
      --
    close c1;
    if g_debug then
      hr_utility.set_location ('close c1: '||l_package,50);
    end if;
    --
  end if;
  --
  -- p_pl_typ_id not null then no_plans, plan and option name must be blank
  --
  if p_pl_typ_id is not null and
    (p_no_plans = 'Y' or
     p_opt_id is not null or
     p_pl_id is not null) then
    --
    fnd_message.set_name('BEN','BEN_91749_PLAN_TYPE');
    fnd_message.raise_error;
    --
  end if;
  --
  -- p_mode = 'C' and p_popl_enrt_typ_cycl_id is null
  --
  -- CWB Changes
  --
  if p_mode in  ('C', 'W') and
    -- PB : 5422 :
    -- Now check for p_lf_evt_ocrd_dt
    --
    --  p_popl_enrt_typ_cycl_id is null then
    p_lf_evt_ocrd_dt is null then
     --
    fnd_message.set_name('BEN','BEN_91667_SCHED_NO_POPL_ENRT');
    fnd_message.raise_error;
    --
  end if;
  --
  -- CWB Changes
  --
  if p_mode = 'W' and p_pl_id is null then
     --
     fnd_message.set_name('BEN','BEN_91667_SCHED_NO_POPL_ENRT');
     fnd_message.raise_error;
     --
  end if;

  --
  -- CWB Changes Bug 2270672
  -- Effective date must be greater than or equal to Life Event Occurred Date
  --
  if p_mode = 'W' and p_effective_date < p_lf_evt_ocrd_dt then
    --
    fnd_message.set_name('BEN','BEN_93017_INVALID_EFF_DATE');
    fnd_message.raise_error;
    --
  end if;

  --
  -- CWB Changes Bug 2275257
  -- There must be exactly one rate defined for a Plan with the Activity Type
  -- of 'CWBWS'
  --
  if p_mode = 'W' then

    --Bug : 3482033
    --For a plan or option, you cannot have more than one of each of the following rates:  CWB
    --Worksheet Budget, CWB Distribution Budget, CWB Reserve, CWB Worksheet Amount, CWB Eligible
    --Salary, CWB Stated Salary, CWB Other Salary, CWB Total Compensation, CWB Misc Rate 1, CWB
    --Misc Rate 2, CWB Misc Rate 3.
    open c2;
    --
    fetch c2 into l_dummy;
    if c2%found then    -- Bug 3975857 Changed "notfound" to "found"
      --
      close c2;
      fnd_message.set_name('BEN','BEN_93015_CWB_NO_WS_RATE');
      fnd_message.raise_error;
      --
    end if;
    --
    close c2;
    --Bug : 3482033

    -- if plan or option rate  has CWBDB and it should have CWBWB
    -- if plan or option rqte  has CWBWB and it should have CWBDB
    open c5;
    fetch c5 into l_dummy;
    if c5%found then
      --
      close c5;
      fnd_message.set_name('BEN','BEN_93968_CWB_BDGT_RT_AMT_CB');
      fnd_message.raise_error;
      --
    end if;
    close c5;
    --


    open c3;
    fetch c3 into c3_rec;
    close c3;

    open c4;
    fetch c4 into l_cwbdb_count,l_cwbwb_count,l_cwbr_count;
    close c4;

    -- the assumption is if the plan is group then option is group so plan alone is checked
    -- whether it is group or not. verified with manish

    if c3_rec.group_plan = 'Y' then

       /* Bug 4149182 : Commented the following Check
       *
       * -- if the groip plan has option then the rate should be attached to option
       * open c10 ;
       * fetch c10 into  l_dummy ;
       * if c10%found then
       *     open c11 ;
       *     fetch c11 into  l_dummy ;
       *     if c11%found then
       *        close c11 ;
       *        close c10 ;
       *        fnd_message.set_name('BEN','BEN_93742_CWB_RATE_TO_CHILD');
       *        fnd_message.raise_error;
       *     end if ;
       *     close c11 ;
       * end if ;
       * close c10 ;
       */


       -- if the budget flag is 'y'  there should be a rate
       if c3_rec.uses_bdgt_flag = 'Y' then
          if l_cwbdb_count < 1 or
             l_cwbwb_count < 1 then
            --
            fnd_message.set_name('BEN','BEN_93967_CWB_BDGT_RT_PLAN_CB');
            fnd_message.raise_error;
            --
          end if;
       end if ;
 /*    -- bug 5090149
       -- if the budget flag is 'y' there should be  budget task
       open c9 ;
       fetch c9 into  l_dummy ;
       if c9%notfound then
          close c9 ;
          fnd_message.set_name('BEN','BEN_93740_CWB_BDGT_TASK_NOT');
          fnd_message.raise_error;
       end if ;
       close c9 ;
 */

    /*
      Bug 4258200 : Budget and reserve rates can be attached to local plans
      so that the data is copied over in the event of cloning of cwb data.

    else
       -- if the  plan is not group and date DB/WB/reserve attached then error
       if l_cwbdb_count > 0 or
          l_cwbwb_count > 0 or
          l_cwbr_count  > 0  then
          fnd_message.set_name('BEN','BEN_93743_CWB_RATE_TO_GROUP');
          fnd_message.raise_error;
       end if ;
    */
    end if ;
    --

    /* elibile salary are attached to actual plan and DB are attached to group pls
      this condition is no more valid
    if c3_rec.prsvr_bdgt_cd = 'P' then
       open c6;
       fetch c6 into l_dummy;
       if c6%found then
         --
         close c6;
         fnd_message.set_name('BEN','BEN_93319_CWB_BDGT_RT_SAL');
         fnd_message.raise_error;
         --
       end if;
       --
       close c6;
    end if;
    */

    /* Bug 5666180
    Allow customers to setup salary plan with only one salary component.
    In this case, customers uses salary components but the other
    components come from some other place or is entered by admin

    Removing the below check.

    open c7;
    fetch c7 into l_opt_count;
    close c7;

    if l_opt_count = 1 then
       fnd_message.set_name('BEN','BEN_93320_CWB_OPT_COMP_RSN');
       fnd_message.raise_error;
    end if;
    */

    --
    -- Bug 2840078 check that cwb plans/options do not have coverages,
    -- raise error if coverages are attached.
    --
    open c8;
    fetch c8 into l_dummy;
    if c8%found then
      --
      close c8;
      fnd_message.set_name('BEN','BEN_93356_CWB_NO_CVG');
      fnd_message.raise_error;
      --
    end if;
    --
    close c8;

    -- End of fix Bug 2840078

  end if;

  --
  -- iRec : For p_mode = I : iRecruitment, check that atleast one Reporting Group
  -- with purpose "iRecruitment" exists in the Business Group.
  --
  if p_mode = 'I' then
    --
    open c_irec_rptg_grp;
      --
      fetch c_irec_rptg_grp into l_dummy;
      if c_irec_rptg_grp%notfound then
        --
        close c_irec_rptg_grp;
        fnd_message.set_name('BEN','BEN_94026_NO_RPTG_GRP_DFND');
        fnd_message.raise_error;
        --
      end if;
      --
    close c_irec_rptg_grp;
    --
  end if;
  -- iRec

  -- GSP Rate Sync
  -- If for GSP, the operation code = Rate Synchronization, then check that one Life event
  -- of type GSP with operation code = SYNC exists in the Business Group
  if p_mode = 'G' and p_lf_evt_oper_cd = 'SYNC'
  then
    --
    open c_gsp_rate_sync_ler;
     --
     fetch c_gsp_rate_sync_ler into l_dummy;
     if c_gsp_rate_sync_ler%notfound
     then
       --
       close c_gsp_rate_sync_ler;
       fnd_message.set_name('BEN','BEN_94090_NO_GSP_RS_LER_DFND');
       fnd_message.raise_error;
       --
     end if;
     --
   close c_gsp_rate_sync_ler;
   --
  end if;
  -- GSP Rate Sync
  --

  -- p_mode = 'U' make sure any open life event is an unrestricted one -modified
  -- any open unrestricted life event on the same day will be checked at the client side
  --
  --
  -- p_mode not in L,S,C,U
  --
  if g_debug then
    hr_utility.set_location ('BEN_BENMNGLE_MD '||l_package,50);
  end if;
  --
  if hr_api.not_exists_in_hr_lookups
     (p_lookup_type    => 'BEN_BENMNGLE_MD',
      p_lookup_code    => p_mode,
      p_effective_date => p_effective_date) then
    --
    fnd_message.set_name('BEN','BEN_91326_MODE_INVALID');
    fnd_message.raise_error;
    --
  end if;
  --
  -- 2940151 grade/step
  -- 1. If business rule param is null and business rule strt or end dts
  -- are not null, raise error
  if p_per_sel_dt_cd is null and
    ( p_per_sel_dt_from is not null or
      p_per_sel_dt_to is not null) then

        fnd_message.set_name('PER','HR_289506_SPP_BR_NULL');
        fnd_message.raise_error;
  end if;

  -- 2. If business rule param is not null and business rule strt or end dts
  -- are null, raise error
  if p_per_sel_dt_cd is not null and
      ( p_per_sel_dt_from is null or
        p_per_sel_dt_to is null) then

          fnd_message.set_name('PER','HR_289510_SPP_BR_DATE_NULL');
          fnd_message.raise_error;
  end if;
  --
  -- 3. If business rule param is neither of the four values, raise error

  if p_per_sel_dt_cd  not in  ('AOJ', 'DOB', 'ASD', 'LHD') then
    fnd_message.set_name('PER','HR_289507_SPP_BR_INVALID');
    fnd_message.raise_error;
  end if;
  --
  -- 4. If date from is greater than date to, raise error

  if p_per_sel_dt_from > p_per_sel_dt_to then
    fnd_message.set_name('PER','HR_289500_SPP_BR_DATE');
    fnd_message.raise_error;
  end if;
  --
  -- 5. If the dates are more than 12 months apart, raise error

  if ( months_between( p_per_sel_dt_to, p_per_sel_dt_from) > 12 ) then
    fnd_message.set_name('PER','HR_289501_SPP_BR_YEAR_GREATER');
    fnd_message.raise_error;
  end if;
  --
  -- 6. If effective date does not fall between the from and to dates, raise error

  if not ( p_effective_date between  p_per_sel_dt_from and p_per_sel_dt_to ) then
    fnd_message.set_name('PER','HR_289503_SPP_EFF_BR_DATE');
    fnd_message.raise_error;
  end if;
  --
  -- 7. If year from is greater than year to, raise error

  if p_year_from > p_year_to then
    fnd_message.set_name('PER','HR_289504_SPP_BR_YEAR_FROM_TO');
    fnd_message.raise_error;
  end if;
  --
  -- end 2940151

  --
  if g_debug then
    hr_utility.set_location ('Leaving '||l_package,10);
  end if;
  --
end check_business_rules;
--
procedure update_elig_per_rows
(p_comp_obj_tree_row  in ben_manage_life_events.g_cache_proc_objects_rec
,p_comp_rec           in ben_derive_part_and_rate_facts.g_cache_structure
,p_person_id          in number
,p_par_elig_state     in out nocopy ben_comp_obj_filter.g_par_elig_state_rec
,p_treeele_num        in number
,p_business_group_id  in number
,p_effective_date     in date
,p_lf_evt_ocrd_dt     in date
,p_per_in_ler_id      in number
,p_continue_loop      out nocopy boolean) is
--
  l_envpgm_id   number := p_comp_obj_tree_row.par_pgm_id;
  l_envptip_id  number := p_comp_obj_tree_row.par_ptip_id;
  l_envplip_id  number := p_comp_obj_tree_row.par_plip_id;
  l_envpl_id    number := p_comp_obj_tree_row.par_pl_id;
  l_oipl_id     number := p_comp_obj_tree_row.oipl_id;
  l_pl_id       number := p_comp_obj_tree_row.pl_id;
  l_oiplip_id   number := p_comp_obj_tree_row.oiplip_id;
  l_plip_id     number := p_comp_obj_tree_row.plip_id;
  l_ptip_id     number := p_comp_obj_tree_row.ptip_id;

  l_elig_per_id               ben_elig_per_f.elig_per_id%TYPE;
  l_object_version_number     ben_elig_per_f.object_version_number%TYPE;
  l_object_version_number_opt ben_elig_per_opt_f.object_version_number%type;
  l_effective_start_date      date;
  l_effective_end_date        date;
  l_datetrack_mode            varchar2(100);
  l_elig_per_opt_id           ben_elig_per_opt_f.elig_per_opt_id%type;
  l_elig_per_oiplip_id        ben_elig_per_opt_f.elig_per_opt_id%type;
  l_effective_start_date_opt  date;
  l_effective_end_date_opt    date;
  l_correction                boolean;
  l_update                    boolean;
  l_update_override           boolean;
  l_update_change_insert      boolean;

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
  ;
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
           pep.prtn_strt_dt strt_dt,
           pep.prtn_end_dt end_dt
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
            or pil.per_in_ler_stat_cd is null);
   --
   cursor c_epe (p_pgm_id number) is
     select null
     from ben_elig_per_f
     where person_id = p_person_id
     and   p_effective_date between effective_start_date and
           effective_end_date
     and   per_in_ler_id is null
     and   pgm_id = p_pgm_id;
  --
  cursor c_epe2 (p_pl_id number) is
     select null
     from ben_elig_per_f
     where person_id = p_person_id
     and   p_effective_date between effective_start_date and
           effective_end_date
     and   per_in_ler_id is null
     and   pgm_id is null
     and   pl_id = p_pl_id;
  --
  cursor c_epo (p_pgm_id number) is
    select null
    from ben_elig_per_opt_f epo
    where epo.per_in_ler_id is null
    and   p_effective_date between epo.effective_start_date
          and epo.effective_end_date
    and   epo.elig_per_id in
         (select elig_per_id
          from ben_elig_per_f
          where person_id = p_person_id
          and   p_effective_date between effective_start_date and
                effective_end_date
          and   per_in_ler_id = p_per_in_ler_id
          and   pgm_id = p_pgm_id);
  --
  cursor c_epo2 (p_pl_id number) is
    select null
    from ben_elig_per_opt_f epo
    where epo.per_in_ler_id is null
    and   p_effective_date between epo.effective_start_date
          and epo.effective_end_date
    and   epo.elig_per_id in
         (select elig_per_id
          from ben_elig_per_f
          where person_id = p_person_id
          and   p_effective_date between effective_start_date and
                effective_end_date
          and   per_in_ler_id = p_per_in_ler_id
          and   pgm_id is null
          and   pl_id = p_pl_id);

   l_prev_opt_elig_check       c_prev_opt_elig_check%rowtype;
   l_prev_elig_check           c_prev_elig_check%rowtype;
   l_oipl_rec                  ben_cobj_cache.g_oipl_inst_row;
   l_epo_row                   ben_derive_part_and_rate_facts.g_cache_structure;
   l_pep_row                   ben_derive_part_and_rate_facts.g_cache_structure;
   l_proc                         VARCHAR2(72);
   l_par_elig_state ben_comp_obj_filter.g_par_elig_state_rec := p_par_elig_state;
   l_dummy      varchar2(100);
   --

begin
  --
  p_continue_loop := false;
  if g_debug then
    l_proc := g_package ||'.update_elig_per_rows';
    hr_utility.set_location('Entering:' || l_proc, 10);
  end if;
  --
  if l_envpgm_id is not null then
    --
    open c_epe (l_envpgm_id);
    fetch c_epe into l_dummy;
    if c_epe%found then
      --
      update ben_elig_per_f pep set per_in_ler_id = p_per_in_ler_id
        where pep.person_id = p_person_id
        and   pep.per_in_ler_id is null
        and   pep.pgm_id = l_envpgm_id
        and   p_effective_date between pep.effective_start_date
            and pep.effective_end_date;
      ben_pep_cache.clear_down_pepcache;
    end if;
    close c_epe;
    --
    if l_oipl_id is not null then
     --
      open c_epo(l_envpgm_id);
      fetch c_epo into l_dummy;
      if c_epo%found then
        l_oipl_rec := ben_cobj_cache.g_oipl_currow;
        --
        update ben_elig_per_opt_f epo
          set per_in_ler_id = p_per_in_ler_id
          where epo.per_in_ler_id is null
          and   epo.elig_per_id in
                 (select elig_per_id from ben_elig_per_f pep
                  where pep.pgm_id = l_envpgm_id
                  and pep.per_in_ler_id = p_per_in_ler_id
                  and p_effective_date between pep.effective_start_date
                  and pep.effective_end_date)
         and   p_effective_date between epo.effective_start_date and
               epo.effective_end_date
         and   epo.opt_id = l_oipl_rec.opt_id;
        ben_pep_cache.clear_down_epocache;
      end if;
      close c_epo;
    end if;
    --
  else
    --
    open c_epe2(l_envpl_id);
    fetch c_epe2 into l_dummy;
    if c_epe2%found then
      --
      update ben_elig_per_f pep set per_in_ler_id = p_per_in_ler_id
        where pep.person_id = p_person_id
        and   pep.per_in_ler_id is null
        and   pep.pgm_id is null
        and   pep.pl_id = l_envpl_id
        and   p_effective_date between pep.effective_start_date
              and pep.effective_end_date;
      ben_pep_cache.clear_down_pepcache;
    end if;
    close c_epe2;
    --
    if l_oipl_id is not null then
     --
      open c_epo2(l_envpl_id);
      fetch c_epo2 into l_dummy;
      if c_epo2%found then

        l_oipl_rec := ben_cobj_cache.g_oipl_currow;
        --
        update ben_elig_per_opt_f epo
          set per_in_ler_id = p_per_in_ler_id
          where epo.per_in_ler_id is null
          and   epo.elig_per_id in
                    (select elig_per_id from ben_elig_per_f pep
                     where pep.pgm_id is null
                     and pep.pl_id = l_envpl_id
                     and pep.per_in_ler_id = p_per_in_ler_id
                     and p_effective_date between pep.effective_start_date
                     and pep.effective_end_date)
         and   p_effective_date between epo.effective_start_date and
               epo.effective_end_date
         and   epo.opt_id = l_oipl_rec.opt_id;
         ben_pep_cache.clear_down_epocache;
      end if;
      close c_epo2;
      --
    end if;
    --
  end if;
  --
  if l_oipl_id is not null then
     --
     hr_utility.set_location('OIPL ID-update'||l_oipl_id,111);
     l_oipl_rec := ben_cobj_cache.g_oipl_currow;
     if l_envpgm_id is not null then
      --
        ben_pep_cache.get_pilepo_dets
        (p_person_id         => p_person_id
        ,p_business_group_id => p_business_group_id
        ,p_effective_date    => p_effective_date
        ,p_pgm_id            => l_envpgm_id
        ,p_pl_id             => l_envpl_id
        ,p_opt_id            => l_oipl_rec.opt_id
        ,p_inst_row          => l_epo_row
        );
      --
      --
      if l_epo_row.elig_per_opt_id is null then
         p_continue_loop := false;
         hr_utility.set_location('elig per id is null' ||l_oipl_id,111);
         return;
      else
        l_elig_per_opt_id           := l_epo_row.elig_per_opt_id;
        l_object_version_number_opt := l_epo_row.object_version_number;
        l_elig_per_id               := l_epo_row.elig_per_id;

      end if;
    else  -- pgm_id is null
       open c_prev_opt_elig_check
        (c_person_id      => p_person_id
        ,c_effective_date => p_effective_date
        ,c_pl_id          => l_envpl_id
        ,c_opt_id         => l_oipl_rec.opt_id
        );
      if g_debug then
        hr_utility.set_location('fetch c_prvoptelch ' || l_proc, 10);
      end if;
      fetch c_prev_opt_elig_check into l_prev_opt_elig_check;
      if c_prev_opt_elig_check%notfound then
        --
        close c_prev_opt_elig_check;
        p_continue_loop := false;
        return;
        --
      else
        --
        l_elig_per_opt_id           := l_prev_opt_elig_check.elig_per_opt_id;
        l_object_version_number_opt := l_prev_opt_elig_check.object_version_number;
        l_elig_per_id               := l_prev_opt_elig_check.elig_per_id;
        --
      end if;
      close c_prev_opt_elig_check;


    end if;
    p_continue_loop := true;

   else  -- oipl_id is null
    --
    -- Check for a plan in program
    --
    if l_envpgm_id is not null and
         l_pl_id is not null
    then
      --
      if g_debug then
        hr_utility.set_location(' before pilpep  ',111);
      end if;
      ben_pep_cache.get_pilpep_dets
        (p_person_id         => p_person_id
        ,p_business_group_id => p_business_group_id
        ,p_effective_date    => p_effective_date
        ,p_pgm_id            => l_envpgm_id
        ,p_pl_id             => l_pl_id
        ,p_plip_id           => l_plip_id
        ,p_inst_row          => l_pep_row
        );
      --
      if  l_pep_row.elig_per_id is not null then
         --
         l_elig_per_id           := l_pep_row.elig_per_id;
         l_object_version_number := l_pep_row.object_version_number;
         --
         if l_pep_row.elig_flag = 'Y' then
            ben_comp_obj_filter.set_parent_elig_flags
            (p_comp_obj_tree_row => p_comp_obj_tree_row
            ,p_eligible          => TRUE
            ,p_treeele_num       => p_treeele_num
            ,p_par_elig_state    => l_par_elig_state
            );
         else
            ben_comp_obj_filter.set_parent_elig_flags
            (p_comp_obj_tree_row => p_comp_obj_tree_row
            ,p_eligible          => FALSE
            ,p_treeele_num       => p_treeele_num
            ,p_par_elig_state    => l_par_elig_state
            );
         end if;
      else
        --
        p_continue_loop := false;
        return;
        --
      end if;
      --
    else -- pgm_id is null
      --
      open c_prev_elig_check
        (c_person_id      => p_person_id
        ,c_pgm_id         => nvl(l_envpgm_id,-1)
        ,c_pl_id          => nvl(l_pl_id,-1)
        ,c_ptip_id        => nvl(l_ptip_id,-1)
        ,c_effective_date => p_effective_date
        );
      fetch c_prev_elig_check into l_prev_elig_check;
      --
      if c_prev_elig_check%found then
        l_elig_per_id           := l_prev_elig_check.elig_per_id;
        l_object_version_number := l_prev_elig_check.object_version_number;

        if l_prev_elig_check.elig_flag = 'Y' then
           ben_comp_obj_filter.set_parent_elig_flags
           (p_comp_obj_tree_row => p_comp_obj_tree_row
           ,p_eligible          => TRUE
           ,p_treeele_num       => p_treeele_num
           ,p_par_elig_state    => l_par_elig_state
           );
        else
           ben_comp_obj_filter.set_parent_elig_flags
           (p_comp_obj_tree_row => p_comp_obj_tree_row
           ,p_eligible          => FALSE
           ,p_treeele_num       => p_treeele_num
           ,p_par_elig_state    => l_par_elig_state
           );
         end if;
      else
        close c_prev_elig_check;
        p_continue_loop := false;
        return;
        --
      end if;
      --
    end if;
     --
    p_continue_loop := true;

  end if;
   --
  p_par_elig_state := l_par_elig_state;
   if g_debug then
     hr_utility.set_location('Leaving:' || l_proc, 10);
   end if;
end;
--
procedure update_enrt_rt (p_per_in_ler_id number) is
  --
   cursor c_enrt_rt is
    select *
    from ben_enrt_rt
    where elig_per_elctbl_chc_id in
       (select elig_per_elctbl_chc_id from ben_elig_per_elctbl_chc
          where per_in_ler_id = p_per_in_ler_id)
  union
    select *
    from ben_enrt_rt
     where enrt_bnft_id in
       (select enrt_bnft_id from ben_enrt_bnft
          where elig_per_elctbl_chc_id in
          (select elig_per_elctbl_chc_id from ben_elig_per_elctbl_chc
             where per_in_ler_id = p_per_in_ler_id));

  --
  cursor c_pil_popl is
    select *
    from ben_pil_elctbl_chc_popl
    where per_in_ler_id = p_per_in_ler_id;
  --
  --bug#2718215
  cursor c_result_pgm (p_pgm_id number) is
    select effective_start_date
    from ben_prtt_enrt_rslt_f pen,
         ben_per_in_ler pil
    where pen.pgm_id = p_pgm_id
    and   pen.person_id = pil.person_id
    and   pil.per_in_ler_id = p_per_in_ler_id
    and   pen.prtt_enrt_rslt_stat_cd is null
    and   pen.effective_end_date = hr_api.g_eot;
 --
  cursor c_result_pln (p_pl_id number) is
    select effective_start_date
    from ben_prtt_enrt_rslt_f pen,
         ben_per_in_ler pil
    where pen.pl_id = p_pl_id
    and   pen.person_id = pil.person_id
    and   pil.per_in_ler_id = p_per_in_ler_id
    and   pen.prtt_enrt_rslt_stat_cd is null
    and   pen.effective_end_date = hr_api.g_eot;
  --
  l_effective_start_date date;

begin
  --
  if g_debug then
    hr_utility.set_location('Entering ',10);
  end if;
/*
bug#1936976 prtt_rt_val_id is already populated in benactbr - this process is redundant
and if coverage is %rng multiple rate for same acty_base_rt is possible
  for i in c_enrt_rt loop
    --
      if g_debug then
        hr_utility.set_location('Entering ',10);
      end if;
    if ben_manage_life_events.g_enrt_rt_tbl.count = 0 then
       return;
    end if;
    --
    for j in ben_manage_life_events.g_enrt_rt_tbl.first .. ben_manage_life_events.g_enrt_rt_tbl.last loop
      --
       if g_debug then
         hr_utility.set_location('Entering ',10);
       end if;
      if i.acty_base_rt_id = ben_manage_life_events.g_enrt_rt_tbl(j).acty_base_rt_id then
         --
         if ben_manage_life_events.g_enrt_rt_tbl(j).prtt_rt_val_id is not null then
            update ben_enrt_rt
              set prtt_rt_val_id =  ben_manage_life_events.g_enrt_rt_tbl(j).prtt_rt_val_id
              where enrt_rt_id = i.enrt_rt_id;
         end if;
         --
         exit;
         --
       end if;
      --
     end loop;
      --
  end loop;
*/
  --
  for i in c_pil_popl  loop
    --
    /* The logic of updating the elections made date is changed to take care of situations
       after running recalculate process and after conversion  because after conversion
       there is no pil elctble choice record.  Now, the cursors fetch the election made
       date from enrollment result table.

      if g_debug then
        hr_utility.set_location('Entering  popl update',10);
      end if;
    if ben_manage_life_events.g_pil_popl_tbl.count = 0 then
       return;
    end if;
    --
    for j in ben_manage_life_events.g_pil_popl_tbl.first .. ben_manage_life_events.g_pil_popl_tbl.last loop
      --
      if i.pgm_id = ben_manage_life_events.g_pil_popl_tbl(j).pgm_id or
          i.pl_id = ben_manage_life_events.g_pil_popl_tbl(j).pl_id then
         --
            update ben_pil_elctbl_chc_popl
              set elcns_made_dt =  ben_manage_life_events.g_pil_popl_tbl(j).elcns_made_dt
              where pil_elctbl_chc_popl_id  = i.pil_elctbl_chc_popl_id;
         --
         --
         --
       end if;
      --
     end loop;
      --
     */
     if i.pgm_id is not null then
        open c_result_pgm (i.pgm_id);
        fetch c_result_pgm into l_effective_start_date;
        if c_result_pgm%found then
           update ben_pil_elctbl_chc_popl
             set elcns_made_dt = l_effective_start_date
             where pil_elctbl_chc_popl_id  = i.pil_elctbl_chc_popl_id;
        end if;
        close c_result_pgm;
     elsif i.pl_id is not null then
        open c_result_pln (i.pl_id);
        fetch c_result_pln into l_effective_start_date;
        if c_result_pln%found then
           update ben_pil_elctbl_chc_popl
             set elcns_made_dt = l_effective_start_date
             where pil_elctbl_chc_popl_id  = i.pil_elctbl_chc_popl_id;
        end if;
        close c_result_pln;
     end if;

  end loop;

  if g_debug then
    hr_utility.set_location('Leaving update enrt',10);
  end if;
end;
-- GSP New Procedure for updating the epe for default/auto
-- enrollments.
procedure gsp_proc_dflt_auten(p_per_in_ler_id number,
                              p_effective_date date ) is
  --local variables
  l_package               varchar2(80) := g_package||'.gsp_proc_dflt_auten';
  l_return_cd                varchar2(30);
  l_elig_per_elctbl_chc_id   number(15);
  l_dflt_flag                varchar2(30) := 'N';
  l_auto_enrt_flag           varchar2(30) := 'N';
  --cursors
  cursor c_epe is
    select elig_per_elctbl_chc_id,
           object_version_number
    from ben_elig_per_elctbl_chc epe
    where elig_per_elctbl_chc_id = l_elig_per_elctbl_chc_id
      and per_in_ler_id          = p_per_in_ler_id ;
  --
  l_epe                      c_epe%ROWTYPE;
  --
begin
  --
  hr_utility.set_location('Entering '||l_package,10);
  --
  --Call the GSP Default procedure to get the epe and return code
  pqh_gsp_default.get_def_auto_code(
    p_per_in_ler_id       => p_per_in_ler_id,
    p_effective_date      => p_effective_date,
    p_return_code         => l_return_cd,
    p_electbl_chc_id       => l_elig_per_elctbl_chc_id
  );
  --
  if l_elig_per_elctbl_chc_id is not null then
    --
    open c_epe ;
      fetch c_epe into l_epe ;
    close c_epe ;
    --
    if l_return_cd = 'D' then
      --
      l_dflt_flag   := 'Y' ;
      --
    elsif l_return_cd = 'A' then
      --
      l_auto_enrt_flag := 'Y' ;
      l_dflt_flag      := 'Y' ;
      --
    end if;
    --
    if l_epe.elig_per_elctbl_chc_id is not null then
      ben_elig_per_elc_chc_api.update_perf_ELIG_PER_ELC_CHC
        (p_elig_per_elctbl_chc_id    => l_epe.elig_per_elctbl_chc_id
        ,p_object_version_number     => l_epe.object_version_number
        ,p_dflt_flag                 => l_dflt_flag
        ,p_auto_enrt_flag            => l_auto_enrt_flag
        ,p_effective_date            => p_effective_date
      );
      --
      --Call the GSP Post process for Automatic enrollment
      if l_auto_enrt_flag = 'Y' then
        --
        pqh_gsp_post_process.Call_PP_From_Benmngle(
           P_Effective_Date            =>p_effective_date,
           P_Elig_per_Elctbl_Chc_Id    =>l_epe.elig_per_elctbl_chc_id
        )   ;
        --
      end if;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving '||l_package,20);
  --
end gsp_proc_dflt_auten ;
--
-- Bug 1895846
procedure reset_elctbl_chc_inpng_flag(p_per_in_ler_id number,
                                      p_effective_date date ) is
  --
  l_object_version_number number ;
  l_package               varchar2(100);
  cursor c_epe is
  select
    elig_per_elctbl_chc_id
  from
    ben_elig_per_elctbl_chc epe
  where
    per_in_ler_id = p_per_in_ler_id and
    in_pndg_wkflow_flag = 'S';
  --
begin
  --
/*
  update ben_elig_per_elctbl_chc
  set in_pndg_wkflow_flag = 'N'
  where in_pndg_wkflow_flag = 'S'
  and per_in_ler_id = p_per_in_ler_id;
*/
  if g_debug then
    l_package := 'reset_elctbl_chc_inpng_flag' ;
    hr_utility.set_location('Entering '||l_package , 10);
  end if;
  --
  for l_epe in c_epe loop
    --
    ben_elig_per_elc_chc_api.update_perf_ELIG_PER_ELC_CHC
      (p_elig_per_elctbl_chc_id    => l_epe.elig_per_elctbl_chc_id
      ,p_object_version_number      => l_object_version_number
      ,p_in_pndg_wkflow_flag        => 'N'
      ,p_effective_date             => p_effective_date
    );
    --
  end loop ;
  --
  if g_debug then
    hr_utility.set_location('Leaving '||l_package , 10);
  end if;
  --
end;
--
-- Bug 1895846
procedure delete_in_pndg_elig_dpnt( p_per_in_ler_id in number,
                                    p_effective_date     in date) is
  l_object_version_number number ;
  l_package               varchar2(100);
  --
  cursor c_in_pndg_edg is
  select
    elig_dpnt_id
  from
    ben_elig_dpnt egd
  where
    egd.per_in_ler_id = p_per_in_ler_id and
    egd.elig_per_elctbl_chc_id is null ;

begin
  --
  if g_debug then
    l_package := 'delete_in_pndg_elig_dpnt' ;
    hr_utility.set_location('Entering '||l_package , 10);
  end if;
  for l_in_pndg_edg in c_in_pndg_edg loop
    --
    ben_elig_dpnt_api.delete_elig_dpnt
      (p_elig_dpnt_id                   => l_in_pndg_edg.elig_dpnt_id
      ,p_object_version_number          => l_object_version_number
      ,p_effective_date                 => p_effective_date
      ) ;
    --
  end loop;
  --
  if g_debug then
    hr_utility.set_location('Leaving '||l_package , 10);
  end if;
end ;
--
procedure write_logfile(p_benefit_action_id   in number,
                        p_thread_id           in number,
                        p_validate            in varchar2,
                        p_person_count        in number,
                        p_error_person_count  in number) is
  --
  l_package        varchar2(80);
  --
  table_full EXCEPTION;
  index_full EXCEPTION;
  pragma exception_init(table_full,-1653);
  pragma exception_init(index_full,-1654);
begin
  --
  if g_debug then
    l_package := g_package||'.write_logfile';
    hr_utility.set_location ('Entering '||l_package,10);
  end if;
  --
  benutils.write(p_text => benutils.g_banner_minus);
  benutils.write(p_text => 'Benefits Statistical Information');
  benutils.write(p_text => benutils.g_banner_minus);
  benutils.write(p_text => 'Processed persons     '||p_person_count);
  benutils.write(p_text => 'Errored persons       '||p_error_person_count);
  benutils.write(p_text => benutils.g_banner_minus);
  --
  benutils.write_table_and_file(p_table => true,
                                p_file  => true);
  commit;
  --
  if g_debug then
    hr_utility.set_location ('Leaving '||l_package,10);
  end if;
  --
exception
  --
 --
 when table_full then
   benutils.write(fnd_message.get);
   fnd_message.raise_error;
 when index_full then
   benutils.write(fnd_message.get);
   fnd_message.raise_error;
 --
  when others then
    --
    fnd_message.set_name('BEN','BEN_91663_BENMNGLE_LOGGING');
    benutils.write(fnd_message.get);
    fnd_message.raise_error;
    --
end write_logfile;
--
procedure flush_global_structures is
  --
  l_package varchar2(80);
  --
begin
  --
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_package := g_package||'.flush_global_structures';
    hr_utility.set_location ('Entering '||l_package,10);
  end if;
  --
  g_cache_person_process.delete;
  benutils.clear_down_cache;
  benutils.g_batch_param_table_object.delete;
  ben_elig_rl_cache.clear_down_cache;
  ben_location_object.clear_down_cache;
  ben_org_object.clear_down_cache;
  ben_life_object.clear_down_cache;
  --
  -- Clear down comp object cache
  --
  ben_pln_cache.clear_down_cache;
  ben_cop_cache.clear_down_cache;
  ben_cobj_cache.clear_down_cache;
  ben_element_entry.clear_down_cache;
  --
  -- Clear down person object caches
  --
  ben_person_object.clear_down_cache;
  ben_batch_dt_api.clear_down_cache;
  --
  ben_pil_object.clear_down_cache;
  --
  if g_debug then
    hr_utility.set_location ('Leaving '||l_package,10);
  end if;
  --
end flush_global_structures;
--
procedure print_parameters
   (p_benefit_action_id in number) is
  --
  l_package varchar2(80);
  l_rec     benutils.g_batch_param_rec;
  -- added bug: 5618436
  CURSOR c_conc_pgm_name is
  SELECT fcp.concurrent_program_name
    FROM ben_benefit_actions bft, fnd_concurrent_programs fcp
   WHERE bft.program_id = fcp.concurrent_program_id
     AND bft.benefit_action_id = p_benefit_action_id;

  l_source_program fnd_concurrent_programs.concurrent_program_name%TYPE;
  --
begin
  --
  if g_debug then
    l_package := g_package||'.print_parameters';
    hr_utility.set_location ('Entering '||l_package,10);
  end if;
  open c_conc_pgm_name;
  fetch c_conc_pgm_name into l_source_program;
  close c_conc_pgm_name;
  --
  if fnd_global.conc_request_id = -1 then
    return;
  end if;
  --
  benutils.get_batch_parameters
    (p_benefit_action_id => p_benefit_action_id,
     p_rec               => l_rec);
  --
  fnd_file.put_line(which => fnd_file.log,
                    buff  => 'Runtime Parameters');
  fnd_file.put_line(which => fnd_file.log,
                    buff  => '------------------');
  fnd_file.put_line(which => fnd_file.log,
                    buff  => 'Concurrent Request ID      :'||
                    fnd_global.conc_request_id);
  fnd_file.put_line(which => fnd_file.log,
                    buff  => 'Run Mode                   :'||
                    hr_general.decode_lookup('BEN_BENMNGLE_MD',l_rec.mode_cd));
  fnd_file.put_line(which => fnd_file.log,
                    buff  => 'Validation Mode            :'||
                    hr_general.decode_lookup('YES_NO',l_rec.validate_flag));
  -- bug: 5618436
  if l_source_program
	not in ('BENLIMOD','BENSCMOD','BENSEMOD','BENPAMOD','BENGSMOD','BENTEMOD')
	then
		  fnd_file.put_line(which => fnd_file.log,
                    buff  => 'Limit By Person''s Organization :'||
                    hr_general.decode_lookup('YES_NO',l_rec.lmt_prpnip_by_org_flag));
  end if;

  fnd_file.put_line(which => fnd_file.log,
                    buff  => 'Benefit Action ID          :'||
                    p_benefit_action_id);
  fnd_file.put_line(which => fnd_file.log,
                    buff  => 'Effective Date             :'||
                    to_char(l_rec.process_date,'DD/MM/YYYY'));
  fnd_file.put_line(which => fnd_file.log,
                    buff  => 'Derivable Factors          :'||
                    hr_general.decode_lookup('BEN_DTCT_TMPRL_LER_TYP',l_rec.derivable_factors_flag));
  fnd_file.put_line(which => fnd_file.log,
                    buff  => 'Business Group ID          :'||
                    l_rec.business_group_id);
  fnd_file.put_line(which => fnd_file.log,
                    buff  => 'Program ID                 :'||
                    benutils.iftrue
                     (p_expression => l_rec.pgm_id is null,
                      p_true       => 'All',
                      p_false      => l_rec.pgm_id));
  fnd_file.put_line(which => fnd_file.log,
                    buff  => 'Plan ID                    :'||
                    benutils.iftrue
                     (p_expression => l_rec.pl_id is null,
                      p_true       => 'All',
                      p_false      => l_rec.pl_id));
  fnd_file.put_line(which => fnd_file.log,
                    buff  => 'Plan Type ID               :'||
                    benutils.iftrue
                     (p_expression => l_rec.pl_typ_id is null,
                      p_true       => 'All',
                      p_false      => l_rec.pl_typ_id));
  fnd_file.put_line(which => fnd_file.log,
                    buff  => 'Option ID                  :'||
                    benutils.iftrue
                     (p_expression => l_rec.opt_id is null,
                      p_true       => 'All',
                      p_false      => l_rec.opt_id));
  --
  -- PB : 5422 : Need to dump the lf_evt_dt
  -- popl_enrt_typ_cycl_id is no longer available.
  --
  /*
  fnd_file.put_line(which => fnd_file.log,
                    buff  => 'Enrollment Type Cycle      :'||
                    benutils.iftrue
                     (p_expression => l_rec.popl_enrt_typ_cycl_id is null,
                      p_true       => 'All',
                      p_false      => l_rec.popl_enrt_typ_cycl_id));
  */
  fnd_file.put_line(which => fnd_file.log,
                    buff  => 'Just Plans not in Programs :'||
                    hr_general.decode_lookup('YES_NO',l_rec.no_programs_flag));
  fnd_file.put_line(which => fnd_file.log,
                    buff  => 'Just Programs              :'||
                    hr_general.decode_lookup('YES_NO',l_rec.no_plans_flag));
  fnd_file.put_line(which => fnd_file.log,
                    buff  => 'Reporting Group            :'||
                    benutils.iftrue
                     (p_expression => l_rec.rptg_grp_id is null,
                      p_true       => 'All',
                      p_false      => l_rec.rptg_grp_id));
  fnd_file.put_line(which => fnd_file.log,
                    buff  => 'Eligiblity Profile         :'||
                    benutils.iftrue
                     (p_expression => l_rec.eligy_prfl_id is null,
                      p_true       => 'All',
                      p_false      => l_rec.eligy_prfl_id));
  fnd_file.put_line(which => fnd_file.log,
                    buff  => 'Variable Rate Profile      :'||
                    benutils.iftrue
                     (p_expression => l_rec.vrbl_rt_prfl_id is null,
                      p_true       => 'All',
                      p_false      => l_rec.vrbl_rt_prfl_id));
  fnd_file.put_line(which => fnd_file.log,
                    buff  => 'Person Selection Rule      :'||
                    benutils.iftrue
                     (p_expression => l_rec.person_selection_rl is null,
                      p_true       => 'None',
                      p_false      => l_rec.person_selection_rl));
  fnd_file.put_line(which => fnd_file.log,
                    buff  => 'Comp Object Selection Rule :'||
                    benutils.iftrue
                     (p_expression => l_rec.comp_selection_rl is null,
                      p_true       => 'None',
                      p_false      => l_rec.comp_selection_rl));
  --
  if g_debug then
    hr_utility.set_location ('Leaving '||l_package,10);
  end if;
  --
end print_parameters;
--
-- CWBITEM
--
--
-- CWB Procedure for population of the CWB Hierarchy table
--
procedure popu_pel_heir is
  --
  l_proc         VARCHAR2(80);
  l_level        number             := 1 ;
  l_emp_pel           number ;
  l_mgr_pel           number ;
  l_mgr_person_id     number ;
  l_mgr_person_id_out number ;
  l_business_group_id number ;
  l_pl_id             number;
  l_lf_evt_ocrd_dt    date;
  l_ler_id            number;
  l_rec             benutils.g_batch_param_rec;
  lv_pl_id          number;
  lv_business_group_id number;
  lv_ler_id            number;
  lv_lf_evt_ocrd_dt date;
  --
  -- Bug 2288042 : Create 0 level heirarchy data if manager is
  -- is processed first and employee is processed later.
  --
  cursor c_no_0_hrchy(p_pl_id number,
                      p_lf_evt_ocrd_dt date,
                      p_business_group_id number) is
  select unique pel_0.mgr_pil_elctbl_chc_popl_id
  from ben_cwb_hrchy pel_0,
     ben_pil_elctbl_chc_popl mgr_pel_0,
     ben_per_in_ler pil_0
  where
      mgr_pel_0.pil_elctbl_chc_popl_id = pel_0.mgr_pil_elctbl_chc_popl_id
      and mgr_pel_0.per_in_ler_id = pil_0.per_in_ler_id
      and mgr_pel_0.pl_id         = p_pl_id
      and pil_0.lf_evt_ocrd_dt = p_lf_evt_ocrd_dt
      -- and pil_0.ler_id = p_ler_id
      and pil_0.business_group_id = p_business_group_id
      and pil_0.per_in_ler_stat_cd = 'STRTD'
  and pel_0.lvl_num > 0
  and pel_0.mgr_pil_elctbl_chc_popl_id not in
  ( select mgr_pel.pil_elctbl_chc_popl_id
    from ben_cwb_hrchy hrh,
         ben_pil_elctbl_chc_popl mgr_pel,
         ben_per_in_ler pil
    where hrh.mgr_pil_elctbl_chc_popl_id =
                        hrh.emp_pil_elctbl_chc_popl_id
      and mgr_pel.pil_elctbl_chc_popl_id = hrh.mgr_pil_elctbl_chc_popl_id
      and hrh.lvl_num = 0
      and mgr_pel.per_in_ler_id = pil.per_in_ler_id
      and mgr_pel.pl_id         = p_pl_id
      and pil.lf_evt_ocrd_dt = p_lf_evt_ocrd_dt
      -- and pil.ler_id         = p_ler_id
      and pil.business_group_id = p_business_group_id
      and pil.per_in_ler_stat_cd = 'STRTD'
  );
  --
  -- Cursor to select the pel records for emp
  -- These are the records created initially with mgr_pil_elctbl_chc_popl_id and
  -- lvl_num as '-1'
  --
  cursor c_pel(cv_pl_id number, cv_lf_evt_ocrd_dt date) is
    select
      cwb.emp_pil_elctbl_chc_popl_id,
      pel.ws_mgr_id
    from
      ben_cwb_hrchy  cwb,
      ben_pil_elctbl_chc_popl pel ,
      ben_per_in_ler pil
    where
          cwb.mgr_pil_elctbl_chc_popl_id = -1
      and pel.pil_elctbl_chc_popl_id = cwb.emp_pil_elctbl_chc_popl_id
      --
      -- Bug 2541072 : Do not consider all per in ler's.
      --
      and pel.per_in_ler_id = pil.per_in_ler_id
      and pil.per_in_ler_stat_cd = 'STRTD'
      and ((cv_pl_id = -1 and cv_lf_evt_ocrd_dt = hr_api.g_eot)
            or
           (pil.lf_evt_ocrd_dt = cv_lf_evt_ocrd_dt and pel.pl_id = cv_pl_id)
          )
      and cwb.lvl_num = -1;
  --
  -- To get the pl_id, lf_evt_ocrd_dt, ler_id and business_group_id of the first records.
  -- This is the criteria used for finding the pel records in the hierarchy.
  --
  cursor c_pl_ler(p_pil_elctbl_chc_popl_id number) is
    select
      pel.pl_id,
      pil.lf_evt_ocrd_dt,
      pil.ler_id,
      pil.business_group_id
    from
      ben_pil_elctbl_chc_popl pel,
      ben_per_in_ler pil
    where
       pel.per_in_ler_id = pil.per_in_ler_id
   and pel.pil_elctbl_chc_popl_id = p_pil_elctbl_chc_popl_id
   and pil.per_in_ler_stat_cd = 'STRTD';
  --
  -- This private procedure determines the Manager pel
  -- This will get the manager pel record for a given emp - cascading
  procedure mgr( p_person_id number,
                p_business_group_id number,
                p_pl_id number,
                p_lf_evt_ocrd_dt date,
                p_ler_id number,
                p_ws_mgr_id out nocopy number,
                p_pil_elctbl_chc_popl_id out nocopy number ) is
    --
    cursor c_mgr(p_person_id number,
                 p_pl_id number,
                 p_lf_evt_ocrd_dt date,
                 p_ler_id number,
                 p_business_group_id number) is
      select pel.ws_mgr_id,
             pel.pil_elctbl_chc_popl_id
      from ben_pil_elctbl_chc_popl pel,
           ben_per_in_ler pil
      where pel.per_in_ler_id = pil.per_in_ler_id
      and   pel.pl_id         = p_pl_id
      and   pil.lf_evt_ocrd_dt = p_lf_evt_ocrd_dt
      and   pil.ler_id        = p_ler_id
      and   pil.person_id     = p_person_id
      and   pil.business_group_id = p_business_group_id
      and   pil.per_in_ler_stat_cd = 'STRTD';
    --
  l_ws_mgr_id number := null ;
  l_pil_elctbl_chc_popl_id number := null ;
  begin
    --
    g_debug := hr_utility.debug_enabled;
    if g_debug then
      hr_utility.set_location('MGR p_person_id '||p_person_id,22);
      hr_utility.set_location('MGR p_business_group_id '||p_business_group_id,23);
    end if;
    --
    open c_mgr (p_person_id,p_pl_id,p_lf_evt_ocrd_dt,p_ler_id,p_business_group_id);
    fetch c_mgr into l_ws_mgr_id,l_pil_elctbl_chc_popl_id ;
    close c_mgr ;
    --
    if g_debug then
      hr_utility.set_location('MGR OUT l_pil_elctbl_chc_popl_id '||l_pil_elctbl_chc_popl_id,30);
      hr_utility.set_location('MGR OUT l_ws_mgr_id '||l_ws_mgr_id,40);
    end if;
    --
    p_pil_elctbl_chc_popl_id := l_pil_elctbl_chc_popl_id ;
    p_ws_mgr_id := l_ws_mgr_id ;
  end;
  --
  -- This procedure inserts records into hierarchy table
  --
  procedure insert_mgr_hrchy ( p_emp_pil_elctbl_chc_popl_id number,
                               p_mgr_pil_elctbl_chc_popl_id number,
                               p_lvl_num number ) is
  begin
    --
    if g_debug then
      hr_utility.set_location('insert_mgr_hrchy p_emp_pil_elctbl_chc_popl_id '
                                     ||p_emp_pil_elctbl_chc_popl_id,10);
      hr_utility.set_location('insert_mgr_hrchy p_mgr_pil_elctbl_chc_popl_id '
                                     ||p_mgr_pil_elctbl_chc_popl_id || ' lvl = ' || p_lvl_num, 20);
    end if;
    insert into ben_cwb_hrchy (
          emp_pil_elctbl_chc_popl_id,
          mgr_pil_elctbl_chc_popl_id,
          lvl_num  )
    values (
          p_emp_pil_elctbl_chc_popl_id,
          p_mgr_pil_elctbl_chc_popl_id,
          p_lvl_num );
    --
  exception when others then
    --
    -- raise;
    null; -- For Bug 2712602
    --
  end insert_mgr_hrchy;
  --
  procedure update_init_pel(cv_pl_id number, cv_lf_evt_ocrd_dt date)  is
    --
    -- CWB bug : 2712602
    --
    cursor c_cwh is
     select rowid
     from ben_cwb_hrchy cwh
           where cwh.lvl_num = -1 and
             cwh.mgr_pil_elctbl_chc_popl_id = -1
         --
         -- Bug 2541072 : Do not consider all per in ler's.
         --
        and exists
         (select null
          from ben_pil_elctbl_chc_popl pel ,
               ben_per_in_ler pil
          where pel.pil_elctbl_chc_popl_id = cwh.emp_pil_elctbl_chc_popl_id
          and   pel.per_in_ler_id          = pil.per_in_ler_id
          and   pil.per_in_ler_stat_cd = 'STRTD'
          and ((cv_pl_id = -1 and cv_lf_evt_ocrd_dt = hr_api.g_eot)
                 or
               (pil.lf_evt_ocrd_dt = cv_lf_evt_ocrd_dt and pel.pl_id = cv_pl_id)
              )
         ) ;
    --
    begin
      --
      -- Also delete the rows for employees who do not have
      -- subordinates and with level -1 .
      -- And also the last subordinate is now reporting to another manager
      -- we need to delete the pel,0,0 row of the employee.
      --
      delete
      from ben_cwb_hrchy cwh
      where (( cwh.lvl_num = -1
              and cwh.mgr_pil_elctbl_chc_popl_id = -1) OR
             ( cwh.lvl_num = 0 and
              cwh.mgr_pil_elctbl_chc_popl_id = cwh.emp_pil_elctbl_chc_popl_id ) )
        and not exists
        (select null
         from ben_cwb_hrchy cwh1
         where cwh1.mgr_pil_elctbl_chc_popl_id = cwh.emp_pil_elctbl_chc_popl_id
         and cwh1.lvl_num <> 0
        )
         --
         -- Bug 2541072 : Do not consider all per in ler's.
         --
        and exists
         (select null
          from ben_pil_elctbl_chc_popl pel ,
               ben_per_in_ler pil
          where pel.pil_elctbl_chc_popl_id = cwh.emp_pil_elctbl_chc_popl_id
          and   pel.per_in_ler_id          = pil.per_in_ler_id
          and   pil.per_in_ler_stat_cd = 'STRTD'
          and ((cv_pl_id = -1 and cv_lf_evt_ocrd_dt = hr_api.g_eot)
                 or
               (pil.lf_evt_ocrd_dt = cv_lf_evt_ocrd_dt and pel.pl_id = cv_pl_id)
              )
         ) ;
      --
      -- Bug 2712602
      --
      for l_cwh in c_cwh loop
        --
        begin
          --
          update ben_cwb_hrchy cwh
          set cwh.mgr_pil_elctbl_chc_popl_id = cwh.emp_pil_elctbl_chc_popl_id,
              cwh.lvl_num = 0
          where cwh.lvl_num = -1
            and cwh.mgr_pil_elctbl_chc_popl_id = -1
            and cwh.rowid = l_cwh.rowid;
        exception
         when others then
           delete from ben_cwb_hrchy where rowid = l_cwh.rowid;null;
        end;
        --
      end loop;
      --
    exception when others then
      raise ;
    end ;
  --
begin
  --
  if g_debug then
    l_proc := g_package||  '.popu_pel_heir';
    hr_utility.set_location('Entering: '||l_proc,10);
  end if;
  --
  lv_pl_id := -1;
  lv_lf_evt_ocrd_dt := hr_api.g_eot;
  --
  if benutils.g_benefit_action_id is not null then
     --
     benutils.get_batch_parameters
      (p_benefit_action_id => benutils.g_benefit_action_id,
       p_rec               => l_rec);
     --
     lv_pl_id             := l_rec.pl_id;
     lv_lf_evt_ocrd_dt    := l_rec.lf_evt_ocrd_dt;
     lv_business_group_id := l_rec.business_group_id;
     lv_ler_id            := l_rec.ler_id;
     --
  -- Bug 2574791
  else
     --
     lv_pl_id             := g_rebuild_pl_id;
     lv_lf_evt_ocrd_dt    := g_rebuild_lf_evt_ocrd_dt;
     lv_business_group_id := g_rebuild_business_group_id;
     --
  end if;
  --
  if g_debug then
    hr_utility.set_location(l_proc || ' lv_pl_id = ' || lv_pl_id, 9876);
    hr_utility.set_location(l_proc || ' lv_lf_evt_ocrd_dt = ' || lv_lf_evt_ocrd_dt, 9876);
    hr_utility.set_location(l_proc || ' lv_business_group_id = ' || lv_business_group_id, 9876);
    hr_utility.set_location(l_proc || ' lv_ler_id = ' || lv_ler_id, 9876);
  end if;
  open c_pel(lv_pl_id, lv_lf_evt_ocrd_dt);
  fetch c_pel into l_emp_pel,l_mgr_person_id ;
  --
  if g_debug then
    hr_utility.set_location(' l_emp_pel '||l_emp_pel,99);
    hr_utility.set_location(' l_mgr_person_id '||l_mgr_person_id,99);
  end if;
  if c_pel%found then
    --
    open c_pl_ler(l_emp_pel);
    fetch c_pl_ler into l_pl_id, l_lf_evt_ocrd_dt, l_ler_id, l_business_group_id ;
    close c_pl_ler ;
    --
  end if;
  --
  if g_debug then
    hr_utility.set_location(' l_pl_id '||l_pl_id,99);
    hr_utility.set_location(' l_lf_evt_ocrd_dt '||l_lf_evt_ocrd_dt,99);
    hr_utility.set_location(' l_ler_id '||l_ler_id,99);
    hr_utility.set_location(' l_business_group_id '||l_business_group_id,99);
  end if;
  <<pel>>
  loop
    --
    exit pel when c_pel%notfound ;
    l_level := 1 ;
      --
      <<mgr_loop>>
      loop
        --
        if g_debug then
          hr_utility.set_location('Before mgr l_mgr_person_id '||l_mgr_person_id,10);
        end if;
        mgr(l_mgr_person_id,
            l_business_group_id,
            l_pl_id,
            l_lf_evt_ocrd_dt,
            l_ler_id,
            l_mgr_person_id_out,
            l_mgr_pel);
        if g_debug then
          hr_utility.set_location('After Mgr l_mgr_person_id '||l_mgr_person_id,20);
          hr_utility.set_location('After Mgr l_mgr_person_id_out '||l_mgr_person_id_out,20);
          hr_utility.set_location('After Mgr l_mgr_pel '||l_mgr_pel,30);
        end if;
        --
        if l_mgr_pel is not null then
          --
          insert_mgr_hrchy(l_emp_pel,l_mgr_pel,l_level);
          --
        end if;
        --
        exit mgr_loop when (l_mgr_person_id = l_mgr_person_id_out
                            OR l_mgr_person_id_out is null ) ;
        --call to insert routne
        if g_debug then
          hr_utility.set_location('Emp EPE '||l_emp_pel , 20);
          hr_utility.set_location('Mgr EPE '||l_mgr_pel , 30);
          hr_utility.set_location('Level   '||l_level   , 40);
        end if;
        --
        -- insert_mgr_hrchy(l_emp_pel,l_mgr_pel,l_level);
        --
        --after call to insert routine
        --
        l_mgr_person_id := l_mgr_person_id_out ;
        l_level         := l_level + 1 ;
        l_mgr_pel       := null ;
        --
      end loop mgr_loop;
    --
    fetch c_pel into l_emp_pel,l_mgr_person_id ;
    --
    if c_pel%found then
      --
      open c_pl_ler(l_emp_pel);
      fetch c_pl_ler into l_pl_id, l_lf_evt_ocrd_dt, l_ler_id, l_business_group_id ;
      close c_pl_ler ;
      --
    end if;
    --
    if g_debug then
      hr_utility.set_location(' End of mgr_loop ',99);
    end if;
  end loop pel ;
  --
  close c_pel ;
  --
  --call to delete the intial pel records
  if g_debug then
    hr_utility.set_location('Before call to delete_init_pel',10);
  end if;
  update_init_pel(lv_pl_id, lv_lf_evt_ocrd_dt) ;
  if g_debug then
    hr_utility.set_location('After  call to delete_init_pel',10);
  end if;
  --
  -- CWB 2712602 : Delete all the hrchy data linked to backed out per in ler.
  --
  delete from ben_cwb_hrchy
  where emp_pil_elctbl_chc_popl_id in (
     select pel.pil_elctbl_chc_popl_id
     from ben_pil_elctbl_chc_popl pel,
          ben_per_in_ler pil
     where pel.pl_id = lv_pl_id
       and pil.lf_evt_ocrd_dt = lv_lf_evt_ocrd_dt
       and pil.per_in_ler_id  = pel.per_in_ler_id
       and pil.per_in_ler_stat_cd = 'BCKDT');
  --
  delete from ben_cwb_hrchy
  where mgr_pil_elctbl_chc_popl_id in (
     select pel.pil_elctbl_chc_popl_id
     from ben_pil_elctbl_chc_popl pel,
          ben_per_in_ler pil
     where pel.pl_id = lv_pl_id
       and pil.lf_evt_ocrd_dt = lv_lf_evt_ocrd_dt
       and pil.per_in_ler_id  = pel.per_in_ler_id
       and pil.per_in_ler_stat_cd = 'BCKDT');
  --
  -- After testing on hrcwbdvl uncomment the code.
  --
  -- Bug 2288042
  -- Create 0 level heirarchy data for managers for whom this data
  -- is missing.
  --
  for l_no_0_hrchy in  c_no_0_hrchy(lv_pl_id, lv_lf_evt_ocrd_dt, lv_business_group_id) loop
      --
      begin
        --
        insert into ben_cwb_hrchy (
          emp_pil_elctbl_chc_popl_id,
          mgr_pil_elctbl_chc_popl_id,
          lvl_num  )
        values (
          l_no_0_hrchy.mgr_pil_elctbl_chc_popl_id,
          l_no_0_hrchy.mgr_pil_elctbl_chc_popl_id,
          0 );
        --
      exception when others then
        null;
      end;
      --
  end loop;
  if g_debug then
    hr_utility.set_location('Leaving: '||l_proc,10);
  end if;
  --
end popu_pel_heir;
--
--
-- CWB Procedure for population of the CWB Hierarchy table
--
/*
procedure popu_epe_heir is
  --
  l_proc         VARCHAR2(80);
  l_level        number             := 1 ;
  l_emp_epe           number ;
  l_mgr_epe           number ;
  l_mgr_person_id     number ;
  l_mgr_person_id_out number ;
  l_business_group_id number ;
  l_pl_id             number;
  l_lf_evt_ocrd_dt    date;
  l_ler_id            number;
  l_rec             benutils.g_batch_param_rec;
  lv_pl_id          number;
  lv_business_group_id number;
  lv_ler_id            number;
  lv_lf_evt_ocrd_dt date;
  --
  -- Bug 2288042 : Create 0 level heirarchy data if manager is
  -- is processed first and employee is processed later.
  --
  cursor c_no_0_hrchy(p_pl_id number,
                      p_lf_evt_ocrd_dt date,
                      p_business_group_id number) is
  select unique epe_0.mgr_elig_per_elctbl_chc_id
  from ben_cwb_mgr_hrchy epe_0,
     ben_elig_per_elctbl_chc mgr_epe_0,
     ben_per_in_ler pil_0
  where
      mgr_epe_0.elig_per_elctbl_chc_id = epe_0.mgr_elig_per_elctbl_chc_id
      and mgr_epe_0.per_in_ler_id = pil_0.per_in_ler_id
      and mgr_epe_0.pl_id         = p_pl_id
      and pil_0.lf_evt_ocrd_dt = p_lf_evt_ocrd_dt
      -- and pil_0.ler_id = p_ler_id
      and pil_0.business_group_id = p_business_group_id
      and pil_0.per_in_ler_stat_cd = 'STRTD'
  and epe_0.lvl_num > 0
  and epe_0.mgr_elig_per_elctbl_chc_id not in
  ( select mgr_epe.elig_per_elctbl_chc_id
    from ben_cwb_mgr_hrchy hrh,
         ben_elig_per_elctbl_chc mgr_epe,
         ben_per_in_ler pil
    where hrh.mgr_elig_per_elctbl_chc_id =
                        hrh.emp_elig_per_elctbl_chc_id
      and mgr_epe.elig_per_elctbl_chc_id = hrh.mgr_elig_per_elctbl_chc_id
      and hrh.lvl_num = 0
      and mgr_epe.per_in_ler_id = pil.per_in_ler_id
      and mgr_epe.pl_id         = p_pl_id
      and pil.lf_evt_ocrd_dt = p_lf_evt_ocrd_dt
      -- and pil.ler_id         = p_ler_id
      and pil.business_group_id = p_business_group_id
      and pil.per_in_ler_stat_cd = 'STRTD'
  );
  --
  -- Cursor to select the epe records for emp
  -- These are the records created initially with mgr_elig_per_elctbl_chc_id and
  -- lvl_num as '-1'
  --
  cursor c_epe(cv_pl_id number, cv_lf_evt_ocrd_dt date) is
    select
      cwb.emp_elig_per_elctbl_chc_id,
      epe.ws_mgr_id
    from
      ben_cwb_mgr_hrchy  cwb,
      ben_elig_per_elctbl_chc epe ,
      ben_per_in_ler pil
    where
          cwb.mgr_elig_per_elctbl_chc_id = -1
      and epe.elig_per_elctbl_chc_id = cwb.emp_elig_per_elctbl_chc_id
      --
      -- Bug 2541072 : Do not consider all per in ler's.
      --
      and epe.per_in_ler_id = pil.per_in_ler_id
      and pil.per_in_ler_stat_cd = 'STRTD'
      and ((cv_pl_id = -1 and cv_lf_evt_ocrd_dt = hr_api.g_eot)
            or
           (pil.lf_evt_ocrd_dt = cv_lf_evt_ocrd_dt and epe.pl_id = cv_pl_id)
          )
      and cwb.lvl_num = -1;
  --
  -- To get the pl_id, lf_evt_ocrd_dt, ler_id and business_group_id of the first records.
  -- This is the criteria used for finding the epe records in the hierarchy.
  --
  cursor c_pl_ler(p_elig_per_elctbl_chc_id number) is
    select
      epe.pl_id,
      pil.lf_evt_ocrd_dt,
      pil.ler_id,
      pil.business_group_id
    from
      ben_elig_per_elctbl_chc epe,
      ben_per_in_ler pil
    where
       epe.per_in_ler_id = pil.per_in_ler_id
   and epe.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id
   and pil.per_in_ler_stat_cd = 'STRTD';
  --
  -- This private procedure determines the Manager epe
  -- This will get the manager epe record for a given emp - cascading
  procedure mgr( p_person_id number,
                p_business_group_id number,
                p_pl_id number,
                p_lf_evt_ocrd_dt date,
                p_ler_id number,
                p_ws_mgr_id out nocopy number,
                p_elig_per_elctbl_chc_id out nocopy number ) is
    --
    cursor c_mgr(p_person_id number,
                 p_pl_id number,
                 p_lf_evt_ocrd_dt date,
                 p_ler_id number,
                 p_business_group_id number) is
      select epe.ws_mgr_id,
             epe.elig_per_elctbl_chc_id
      from ben_elig_per_elctbl_chc epe,
           ben_per_in_ler pil
      where epe.per_in_ler_id = pil.per_in_ler_id
      and   epe.pl_id         = p_pl_id
      and   pil.lf_evt_ocrd_dt = p_lf_evt_ocrd_dt
      and   pil.ler_id        = p_ler_id
      and   pil.person_id     = p_person_id
      and   pil.business_group_id = p_business_group_id
      and   pil.per_in_ler_stat_cd = 'STRTD';
    --
  l_ws_mgr_id number := null ;
  l_elig_per_elctbl_chc_id number := null ;
  begin
    --
    if g_debug then
      hr_utility.set_location('MGR p_person_id '||p_person_id,22);
      hr_utility.set_location('MGR p_business_group_id '||p_business_group_id,23);
    end if;
    --
    open c_mgr (p_person_id,p_pl_id,p_lf_evt_ocrd_dt,p_ler_id,p_business_group_id);
    fetch c_mgr into l_ws_mgr_id,l_elig_per_elctbl_chc_id ;
    close c_mgr ;
    --
    if g_debug then
      hr_utility.set_location('MGR OUT  l_elig_per_elctbl_chc_id '||l_elig_per_elctbl_chc_id,30);
      hr_utility.set_location('MGR OUT  l_ws_mgr_id '||l_ws_mgr_id,40);
    end if;
    --
    p_elig_per_elctbl_chc_id := l_elig_per_elctbl_chc_id ;
    p_ws_mgr_id := l_ws_mgr_id ;
  end;
  --
  -- This procedure inserts records into hierarchy table
  --
  procedure insert_mgr_hrchy ( p_emp_elig_per_elctbl_chc_id number,
                               p_mgr_elig_per_elctbl_chc_id number,
                               p_lvl_num number ) is
  begin
    --
    if g_debug then
      hr_utility.set_location('insert_mgr_hrchy p_emp_elig_per_elctbl_chc_id '
                                     ||p_emp_elig_per_elctbl_chc_id,10);
      hr_utility.set_location('insert_mgr_hrchy p_mgr_elig_per_elctbl_chc_id '
                                     ||p_mgr_elig_per_elctbl_chc_id || ' lvl = ' || p_lvl_num, 20);
    end if;
    insert into ben_cwb_mgr_hrchy (
          emp_elig_per_elctbl_chc_id,
          mgr_elig_per_elctbl_chc_id,
          lvl_num  )
    values (
          p_emp_elig_per_elctbl_chc_id,
          p_mgr_elig_per_elctbl_chc_id,
          p_lvl_num );
    --
  exception when others then
    --
    raise;
    --
  end insert_mgr_hrchy;
  --
  procedure update_init_epe(cv_pl_id number, cv_lf_evt_ocrd_dt date)  is
    begin
      --
      -- Also delete the rows for employees who do not have
      -- subordinates and with level -1 .
      -- And also the last subordinate is now reporting to another manager
      -- we need to delete the epe,0,0 row of the employee.
      --
      delete
      from ben_cwb_mgr_hrchy cwh
      where (( cwh.lvl_num = -1
              and cwh.mgr_elig_per_elctbl_chc_id = -1) OR
             ( cwh.lvl_num = 0 and
              cwh.mgr_elig_per_elctbl_chc_id = cwh.emp_elig_per_elctbl_chc_id ) )
        and not exists
        (select null
         from ben_cwb_mgr_hrchy cwh1
         where cwh1.mgr_elig_per_elctbl_chc_id = cwh.emp_elig_per_elctbl_chc_id
         and cwh1.lvl_num <> 0
        )
         --
         -- Bug 2541072 : Do not consider all per in ler's.
         --
        and exists
         (select null
          from ben_elig_per_elctbl_chc epe ,
               ben_per_in_ler pil
          where epe.elig_per_elctbl_chc_id = cwh.emp_elig_per_elctbl_chc_id
          and   epe.per_in_ler_id          = pil.per_in_ler_id
          and   pil.per_in_ler_stat_cd = 'STRTD'
          and ((cv_pl_id = -1 and cv_lf_evt_ocrd_dt = hr_api.g_eot)
                 or
               (pil.lf_evt_ocrd_dt = cv_lf_evt_ocrd_dt and epe.pl_id = cv_pl_id)
              )
         ) ;
      --
      update ben_cwb_mgr_hrchy cwh
       set cwh.mgr_elig_per_elctbl_chc_id = cwh.emp_elig_per_elctbl_chc_id,
           cwh.lvl_num = 0
       where cwh.lvl_num = -1 and
             cwh.mgr_elig_per_elctbl_chc_id = -1
         --
         -- Bug 2541072 : Do not consider all per in ler's.
         --
        and exists
         (select null
          from ben_elig_per_elctbl_chc epe ,
               ben_per_in_ler pil
          where epe.elig_per_elctbl_chc_id = cwh.emp_elig_per_elctbl_chc_id
          and   epe.per_in_ler_id          = pil.per_in_ler_id
          and   pil.per_in_ler_stat_cd = 'STRTD'
          and ((cv_pl_id = -1 and cv_lf_evt_ocrd_dt = hr_api.g_eot)
                 or
               (pil.lf_evt_ocrd_dt = cv_lf_evt_ocrd_dt and epe.pl_id = cv_pl_id)
              )
         ) ;
      --
    exception when others then
      raise ;
    end ;
  --
begin
  --
  if g_debug then
    l_proc := g_package||  '.popu_epe_heir';
    hr_utility.set_location('Entering: '||l_proc,10);
  end if;
  --
  lv_pl_id := -1;
  lv_lf_evt_ocrd_dt := hr_api.g_eot;
  --
  if benutils.g_benefit_action_id is not null then
     --
     benutils.get_batch_parameters
      (p_benefit_action_id => benutils.g_benefit_action_id,
       p_rec               => l_rec);
     --
     lv_pl_id             := l_rec.pl_id;
     lv_lf_evt_ocrd_dt    := l_rec.lf_evt_ocrd_dt;
     lv_business_group_id := l_rec.business_group_id;
     lv_ler_id            := l_rec.ler_id;
     --
  -- Bug 2574791
  else
     --
     lv_pl_id             := g_rebuild_pl_id;
     lv_lf_evt_ocrd_dt    := g_rebuild_lf_evt_ocrd_dt;
     lv_business_group_id := g_rebuild_business_group_id;
     --
  end if;
  --
  if g_debug then
    hr_utility.set_location(l_proc || ' lv_pl_id = ' || lv_pl_id, 9876);
    hr_utility.set_location(l_proc || ' lv_lf_evt_ocrd_dt = ' || lv_lf_evt_ocrd_dt, 9876);
    hr_utility.set_location(l_proc || ' lv_business_group_id = ' || lv_business_group_id, 9876);
    hr_utility.set_location(l_proc || ' lv_ler_id = ' || lv_ler_id, 9876);
  end if;
  open c_epe(lv_pl_id, lv_lf_evt_ocrd_dt);
  fetch c_epe into l_emp_epe,l_mgr_person_id ;
  --
  if g_debug then
    hr_utility.set_location(' l_emp_epe '||l_emp_epe,99);
    hr_utility.set_location(' l_mgr_person_id '||l_mgr_person_id,99);
  end if;
  if c_epe%found then
    --
    open c_pl_ler(l_emp_epe);
    fetch c_pl_ler into l_pl_id, l_lf_evt_ocrd_dt, l_ler_id, l_business_group_id ;
    close c_pl_ler ;
    --
  end if;
  --
  if g_debug then
    hr_utility.set_location(' l_pl_id '||l_pl_id,99);
    hr_utility.set_location(' l_lf_evt_ocrd_dt '||l_lf_evt_ocrd_dt,99);
    hr_utility.set_location(' l_ler_id '||l_ler_id,99);
    hr_utility.set_location(' l_business_group_id '||l_business_group_id,99);
  end if;
  <<epe>>
  loop
    --
    exit epe when c_epe%notfound ;
    l_level := 1 ;
      --
      <<mgr_loop>>
      loop
        --
        if g_debug then
          hr_utility.set_location('Before mgr l_mgr_person_id '||l_mgr_person_id,10);
        end if;
        mgr(l_mgr_person_id,
            l_business_group_id,
            l_pl_id,
            l_lf_evt_ocrd_dt,
            l_ler_id,
            l_mgr_person_id_out,
            l_mgr_epe);
        if g_debug then
          hr_utility.set_location('After Mgr l_mgr_person_id '||l_mgr_person_id,20);
          hr_utility.set_location('After Mgr l_mgr_person_id_out '||l_mgr_person_id_out,20);
          hr_utility.set_location('After Mgr l_mgr_epe '||l_mgr_epe,30);
        end if;
        --
        if l_mgr_epe is not null then
          --
          insert_mgr_hrchy(l_emp_epe,l_mgr_epe,l_level);
          --
        end if;
        --
        exit mgr_loop when (l_mgr_person_id = l_mgr_person_id_out
                            OR l_mgr_person_id_out is null ) ;
        --call to insert routne
        if g_debug then
          hr_utility.set_location('Emp EPE '||l_emp_epe , 20);
          hr_utility.set_location('Mgr EPE '||l_mgr_epe , 30);
          hr_utility.set_location('Level   '||l_level   , 40);
        end if;
        --
        -- insert_mgr_hrchy(l_emp_epe,l_mgr_epe,l_level);
        --
        --after call to insert routine
        --
        l_mgr_person_id := l_mgr_person_id_out ;
        l_level         := l_level + 1 ;
        l_mgr_epe       := null ;
        --
      end loop mgr_loop;
    --
    fetch c_epe into l_emp_epe,l_mgr_person_id ;
    --
    if c_epe%found then
      --
      open c_pl_ler(l_emp_epe);
      fetch c_pl_ler into l_pl_id, l_lf_evt_ocrd_dt, l_ler_id, l_business_group_id ;
      close c_pl_ler ;
      --
    end if;
    --
    if g_debug then
      hr_utility.set_location(' End of mgr_loop ',99);
    end if;
  end loop epe ;
  --
  close c_epe ;
  --
  --call to delete the intial epe records
  if g_debug then
    hr_utility.set_location('Before call to delete_init_epe',10);
  end if;
  update_init_epe(lv_pl_id, lv_lf_evt_ocrd_dt) ;
  if g_debug then
    hr_utility.set_location('After  call to delete_init_epe',10);
  end if;
  -- After testing on hrcwbdvl uncomment the code.
  --
  -- Bug 2288042
  -- Create 0 level heirarchy data for managers for whom this data
  -- is missing.
  --
  for l_no_0_hrchy in  c_no_0_hrchy(lv_pl_id, lv_lf_evt_ocrd_dt, lv_business_group_id) loop
      --
      begin
        --
        insert into ben_cwb_mgr_hrchy (
          emp_elig_per_elctbl_chc_id,
          mgr_elig_per_elctbl_chc_id,
          lvl_num  )
        values (
          l_no_0_hrchy.mgr_elig_per_elctbl_chc_id,
          l_no_0_hrchy.mgr_elig_per_elctbl_chc_id,
          0 );
        --
      exception when others then
        null;
      end;
      --
  end loop;
  if g_debug then
    hr_utility.set_location('Leaving: '||l_proc,10);
  end if;
  --
end popu_epe_heir;
--
*/
procedure popu_cross_gb_epe_pel_data(
         p_mode                     in varchar2,
         p_person_id                in number,
         p_business_group_id        in number,
         p_ler_id                   in number,
         p_pl_id                    in number,
         p_effective_date           in date,
         p_lf_evt_ocrd_dt           in date
) is
 --
 l_package varchar2(80);
 --
 l_rec                        benutils.g_active_life_event;
 l_mgr_rec                    benutils.g_active_life_event;
 l_mgr_rec_temp               benutils.g_active_life_event;
 l_effective_date             date := nvl(p_lf_evt_ocrd_dt, p_effective_date);
 l_procd_dt                   date;
 l_strtd_dt                   date;
 l_voidd_dt                   date;
 l_ptnl_ler_for_per_id        number;
 l_object_version_number      number;
 l_dummy_per_in_ler_id        number;
 l_mgr_per_in_ler_not_found   boolean;
 l_mgr_person_id              number;
 l_mgr_person_id_temp         number;
 l_assignment_id              number;
 l_elig_per_elctbl_chc_id     number;
 --
 l_created_by                 ben_elig_per_elctbl_chc.created_by%TYPE;
 l_creation_date              ben_elig_per_elctbl_chc.creation_date%TYPE;
 l_last_update_date           ben_elig_per_elctbl_chc.last_update_date%TYPE;
 l_last_updated_by            ben_elig_per_elctbl_chc.last_updated_by%TYPE;
 l_last_update_login          ben_elig_per_elctbl_chc.last_update_login%TYPE;
 -- CWBITEM
 l_emp_pel_id                 number;
 l_pel_id                     number;
 --
 -- 9999 Why not use the pl_id, so that the data from the
 -- other conc program will not be picked up.
 --
 cursor c_pel(cv_per_in_ler_id in number) is
  select pel.dflt_enrt_dt,
         pel.cls_enrt_dt_to_use_cd,
         pel.enrt_typ_cycl_cd,
         pel.enrt_perd_strt_dt,
         pel.enrt_perd_end_dt,
         pel.lee_rsn_id,
         pel.enrt_perd_id,
         pel.uom,
         pel.acty_ref_perd_cd,
         pel.business_group_id per_business_group_id,
         per.business_group_id mgr_business_group_id,
         pel.ws_mgr_id
  from   ben_pil_elctbl_chc_popl pel,
         per_all_people_f per
  where  pel.per_in_ler_id = cv_per_in_ler_id
    and  pel.ws_mgr_id     = per.person_id (+)
    and  l_effective_date between effective_start_date
                              and effective_end_date;
 --
 cursor c_epe(cv_per_in_ler_id in number) is
  select epe.* ,
         pel.dflt_enrt_dt,
         pel.cls_enrt_dt_to_use_cd,
         pel.enrt_typ_cycl_cd,
         pel.enrt_perd_strt_dt,
         pel.enrt_perd_end_dt,
         pel.lee_rsn_id,
         pel.enrt_perd_id,
         pel.uom,
         pel.acty_ref_perd_cd,
         epe.business_group_id per_business_group_id,
         per.business_group_id mgr_business_group_id
  from   ben_elig_per_elctbl_chc epe,
         ben_pil_elctbl_chc_popl pel,
         per_all_people_f per
  where  epe.per_in_ler_id = cv_per_in_ler_id
    and  epe.per_in_ler_id = pel.per_in_ler_id
    and  epe.pl_id         = pel.pl_id
    and  epe.ws_mgr_id     = per.person_id (+)
    and  l_effective_date between effective_start_date
                              and effective_end_date;
 --
 cursor c_ecr(cv_elig_per_elctbl_chc_id in number) is
   select ecr.*
   from ben_enrt_rt ecr
   where ecr.elig_per_elctbl_chc_id = cv_elig_per_elctbl_chc_id;
 --
 l_curr_pel c_pel%rowtype;
 l_curr_epe c_epe%rowtype;
 --
 -- Gets the enrolment information for this plan
 --
 CURSOR c_plan_enrolment_info(cv_person_id in number,
                              cv_business_group_id in number,
                              cv_lf_evt_ocrd_dt    in date,
                              cv_pl_id             in number,
                              cv_pgm_id            in number)
 IS
      SELECT   pen.prtt_enrt_rslt_id
      FROM     ben_prtt_enrt_rslt_f pen
      WHERE    pen.person_id         = cv_person_id
      AND      pen.business_group_id = cv_business_group_id
      AND      pen.sspndd_flag       = 'N'
      AND      pen.prtt_enrt_rslt_stat_cd IS NULL
      AND      pen.effective_end_date = hr_api.g_eot
      AND      cv_lf_evt_ocrd_dt <= pen.enrt_cvg_thru_dt
      AND      pen.enrt_cvg_strt_dt < pen.effective_end_date
      AND      cv_pl_id = pen.pl_id
      AND      (
                    (    pen.pgm_id = cv_pgm_id
                     AND cv_pgm_id IS NOT NULL)
                 OR (    pen.pgm_id IS NULL
                     AND cv_pgm_id IS NULL));
 --
 l_prtt_enrt_rslt_id number := null;
 --
 l_emp_epe_id   number;
 --
 cursor c_cwb_hrchy(cv_emp_epe_id in number) is
   select emp_elig_per_elctbl_chc_id
   from ben_cwb_mgr_hrchy
   where emp_elig_per_elctbl_chc_id = cv_emp_epe_id;
  --
  cursor c_hrchy(cv_emp_epe_id in number) is
   select hrc.emp_pil_elctbl_chc_popl_id,
          epe.pil_elctbl_chc_popl_id
   from ben_elig_per_elctbl_chc epe,
        ben_cwb_hrchy hrc
   where epe.elig_per_elctbl_chc_id = cv_emp_epe_id
     and hrc.emp_pil_elctbl_chc_popl_id(+) = epe.pil_elctbl_chc_popl_id;
  --
begin
 --
 if g_debug then
   l_package := g_package||'.popu_cross_gb_epe_data';
   hr_utility.set_location ('Entering '||l_package,10);
 end if;
 --
 benutils.get_active_life_event
   (p_person_id         => p_person_id,
   p_business_group_id => p_business_group_id,
   p_effective_date    => p_effective_date,
   p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
   p_ler_id            => p_ler_id,
   p_rec               => l_rec);
 --
 -- Get the manager information.
 --
 open c_pel(l_rec.per_in_ler_id);
 fetch c_pel into l_curr_pel;
 close c_pel;
 --
 -- Now loop through the manager heirarchy and duplicate the data.
 --
 l_mgr_per_in_ler_not_found := true;
 l_mgr_person_id            := l_curr_pel.ws_mgr_id;
 --
 while l_mgr_per_in_ler_not_found loop
   --
   -- Get per in ler for manager in per_business_group_id.
   --
   l_mgr_rec       := l_mgr_rec_temp;
   --
   benutils.get_active_life_event
       (p_person_id         => l_mgr_person_id,
        p_business_group_id => l_curr_pel.per_business_group_id,
        p_effective_date    => p_effective_date,
        p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
        p_ler_id            => p_ler_id,
        p_rec               => l_mgr_rec);
   --
   if l_mgr_rec.per_in_ler_id is not null  or l_mgr_person_id is null then
         l_mgr_per_in_ler_not_found := false;
   else
     --
     -- Now duplicate the pil, pel, epe, ecr data.
     --
     l_mgr_per_in_ler_not_found := true;
     --
     -- Need to copy potential ler for per.
     --
     ben_ptnl_ler_for_per_api.create_ptnl_ler_for_per_perf
           (p_validate                 => false,
            p_ptnl_ler_for_per_id      => l_ptnl_ler_for_per_id,
            p_lf_evt_ocrd_dt           => l_effective_date,
            p_ptnl_ler_for_per_stat_cd => 'PROCD' ,
                                          --l_ptnl_ler_for_per_stat_cd_use,
            p_ler_id                   => p_ler_id,
            p_person_id                => l_mgr_person_id,
            p_ntfn_dt                  => p_effective_date, -- l_ntfn_dt,
            p_procd_dt                 => p_effective_date,
            p_dtctd_dt                 => p_effective_date,
            p_business_group_id        => l_curr_pel.per_business_group_id,
            p_object_version_number    => l_object_version_number,
            p_effective_date           => l_effective_date,
            p_program_application_id   => fnd_global.prog_appl_id,
            p_program_id               => fnd_global.conc_program_id,
            p_request_id               => fnd_global.conc_request_id,
            p_program_update_date      => l_effective_date);
     --
     ben_Person_Life_Event_api.create_Person_Life_Event_perf
           (p_validate                => false
           ,p_per_in_ler_id           => l_dummy_per_in_ler_id
           ,p_ler_id                  => p_ler_id
           ,p_person_id               => l_mgr_person_id
           ,p_per_in_ler_stat_cd      => 'STRTD'
           ,p_ptnl_ler_for_per_id     => l_ptnl_ler_for_per_id
           ,p_lf_evt_ocrd_dt          => p_lf_evt_ocrd_dt
           ,p_business_group_id       => l_curr_pel.per_business_group_id
           ,p_ntfn_dt                 => trunc(sysdate)
           ,p_object_version_number   => l_object_version_number
           ,p_effective_date          => l_effective_date
           ,p_program_application_id  => fnd_global.prog_appl_id
           ,p_program_id              => fnd_global.conc_program_id
           ,p_request_id              => fnd_global.conc_request_id
           ,p_program_update_date     => trunc(sysdate)
           ,p_procd_dt                => l_procd_dt
           ,p_strtd_dt                => l_strtd_dt
           ,p_voidd_dt                => l_voidd_dt);
     --
     --
     -- Now get the manager for l_mgr_person_id.
     --
     -- But 2172036 addition of assignment_id to epe
     --
     ben_enrolment_requirements.get_cwb_manager_and_assignment(
             p_person_id                => l_mgr_person_id,
             p_hrchy_to_use_cd          =>
                  ben_enrolment_requirements.g_ple_hrchy_to_use_cd,
             p_pos_structure_version_id =>
                  ben_enrolment_requirements.g_ple_pos_structure_version_id,
             p_effective_date            => l_effective_date,
             p_manager_id                => l_mgr_person_id_temp,
             p_assignment_id             => l_assignment_id );
     --
     l_prtt_enrt_rslt_id  := null;
     --
     -- Now loop through all the epe's associated with current pel and
     -- duplicate the data.
     --
     for l_curr_epe in c_epe(l_rec.per_in_ler_id) loop
         --
         if g_debug then
           hr_utility.set_location('EPEC_CRE: Cross BG ' || l_package, 10);
         end if;
         ben_elig_per_elc_chc_api.create_perf_elig_per_elc_chc(
           p_elig_per_elctbl_chc_id => l_elig_per_elctbl_chc_id,
           p_business_group_id      => l_curr_epe.per_business_group_id,
           p_auto_enrt_flag         => l_curr_epe.auto_enrt_flag,
           p_per_in_ler_id          => l_dummy_per_in_ler_id,
           p_yr_perd_id             => l_curr_epe.yr_perd_id,
           p_pl_id                  => l_curr_epe.pl_id,
           p_pl_typ_id              => l_curr_epe.pl_typ_id,
           p_oipl_id                => l_curr_epe.oipl_id,
           p_pgm_id                 => l_curr_epe.pgm_id,
           -- p_pgm_typ_cd             => l_curr_epe.pgm_typ_cd,
           p_must_enrl_anthr_pl_id  => l_curr_epe.must_enrl_anthr_pl_id,
           p_plip_id                => l_curr_epe.plip_id,
           p_ptip_id                => l_curr_epe.ptip_id,
           -- As per CWB team l_prtt_enrt_rslt_id can go as null.
           p_prtt_enrt_rslt_id      => l_prtt_enrt_rslt_id,
           --
           p_enrt_typ_cycl_cd       => l_curr_epe.enrt_typ_cycl_cd,
           p_comp_lvl_cd            => l_curr_epe.comp_lvl_cd,
           p_enrt_cvg_strt_dt_cd    => l_curr_epe.enrt_cvg_strt_dt_cd,
           p_enrt_perd_end_dt       => l_curr_epe.enrt_perd_end_dt,
           p_enrt_perd_strt_dt      => l_curr_epe.enrt_perd_strt_dt,
           p_enrt_cvg_strt_dt_rl    => l_curr_epe.enrt_cvg_strt_dt_rl,
           p_roll_crs_flag          => 'N',
           p_ctfn_rqd_flag          => l_curr_epe.ctfn_rqd_flag,
           p_crntly_enrd_flag       => 'N',-- l_curr_epe.crntly_enrd_flag,
           p_dflt_flag              => l_curr_epe.dflt_flag,
           p_elctbl_flag            => 'N',-- l_curr_epe.elctbl_flag,
           p_mndtry_flag            => l_curr_epe.mndtry_flag,
           p_dflt_enrt_dt           => l_curr_epe.dflt_enrt_dt,
           p_dpnt_cvg_strt_dt_cd    => NULL,
           p_dpnt_cvg_strt_dt_rl    => NULL,
           p_enrt_cvg_strt_dt       => l_curr_epe.enrt_cvg_strt_dt,
           p_alws_dpnt_dsgn_flag    => 'N',
           p_erlst_deenrt_dt        => l_curr_epe.erlst_deenrt_dt,
           p_procg_end_dt           => l_curr_epe.procg_end_dt,
           p_pl_ordr_num            => l_curr_epe.pl_ordr_num,
           p_plip_ordr_num          => l_curr_epe.plip_ordr_num,
           p_ptip_ordr_num          => l_curr_epe.ptip_ordr_num,
           p_oipl_ordr_num          => l_curr_epe.oipl_ordr_num,
           p_object_version_number  => l_object_version_number,
           p_effective_date         => l_effective_date,
           p_program_application_id => fnd_global.prog_appl_id,
           p_program_id             => fnd_global.conc_program_id,
           p_request_id             => fnd_global.conc_request_id,
           p_program_update_date    => trunc(SYSDATE),
           p_enrt_perd_id           => l_curr_epe.enrt_perd_id,
           p_lee_rsn_id             => l_curr_epe.lee_rsn_id,
           p_cls_enrt_dt_to_use_cd  => l_curr_epe.cls_enrt_dt_to_use_cd,
           p_uom                    => l_curr_epe.uom,
           p_acty_ref_perd_cd       => l_curr_epe.acty_ref_perd_cd,
           p_cryfwd_elig_dpnt_cd    => l_curr_epe.cryfwd_elig_dpnt_cd,
           -- added for cwb
           p_mode                   => p_mode,
           p_ws_mgr_id              => l_mgr_person_id_temp,
           p_elig_flag              => 'N',
           p_assignment_id          => l_assignment_id  ); -- l_curr_epe.elig_flag);
         -- Bug 2172036 and 2231371 added assignment_id in the above call
         --
         -- Populate the heirarchy table.
         --
         open c_hrchy(l_elig_per_elctbl_chc_id);
         fetch c_hrchy into l_emp_pel_id, l_pel_id;
         --
         if l_pel_id is not null and l_emp_pel_id is null then
            --
            begin
              insert into ben_cwb_hrchy (
               emp_pil_elctbl_chc_popl_id,
               mgr_pil_elctbl_chc_popl_id,
               lvl_num  )
              values(
               l_pel_id,
               -1,
               -1);
            exception
              when others then
                   null; -- For 2712602
            end;
            --
         end if;
         --
         close c_hrchy;
         --
         if g_debug then
           hr_utility.set_location('Done EPEC_CRE Cross BG : ' || l_package, 10);
         end if;
         --
         for l_ecr_rec in c_ecr(l_curr_epe.elig_per_elctbl_chc_id)
         loop
            --
                  INSERT INTO ben_enrt_rt
                  (
                    enrt_rt_id,
                    acty_typ_cd,
                    tx_typ_cd,
                    ctfn_rqd_flag,
                    dflt_flag,
                    dflt_pndg_ctfn_flag,
                    dsply_on_enrt_flag,
                    use_to_calc_net_flx_cr_flag,
                    entr_val_at_enrt_flag,
                    asn_on_enrt_flag,
                    rl_crs_only_flag,
                    dflt_val,
                    ann_val,
                    ann_mn_elcn_val,
                    ann_mx_elcn_val,
                    val,
                    ISS_VAL,
                    nnmntry_uom,
                    mx_elcn_val,
                    mn_elcn_val,
                    incrmt_elcn_val,
                    cmcd_acty_ref_perd_cd,
                    cmcd_mn_elcn_val,
                    cmcd_mx_elcn_val,
                    cmcd_val,
                    cmcd_dflt_val,
                    rt_usg_cd,
                    ann_dflt_val,
                    bnft_rt_typ_cd,
                    rt_mlt_cd,
                    dsply_mn_elcn_val,
                    dsply_mx_elcn_val,
                    entr_ann_val_flag,
                    rt_strt_dt,
                    rt_strt_dt_cd,
                    rt_strt_dt_rl,
                    rt_typ_cd,
                    elig_per_elctbl_chc_id,
                    acty_base_rt_id,
                    spcl_rt_enrt_rt_id,
                    enrt_bnft_id,
                    prtt_rt_val_id,
                    decr_bnft_prvdr_pool_id,
                    cvg_amt_calc_mthd_id,
                    actl_prem_id,
                    comp_lvl_fctr_id,
                    ptd_comp_lvl_fctr_id,
                    clm_comp_lvl_fctr_id,
                    business_group_id,
                    ecr_attribute_category,
                    ecr_attribute1,
                    ecr_attribute2,
                    ecr_attribute3,
                    ecr_attribute4,
                    ecr_attribute5,
                    ecr_attribute6,
                    ecr_attribute7,
                    ecr_attribute8,
                    ecr_attribute9,
                    ecr_attribute10,
                    ecr_attribute11,
                    ecr_attribute12,
                    ecr_attribute13,
                    ecr_attribute14,
                    ecr_attribute15,
                    ecr_attribute16,
                    ecr_attribute17,
                    ecr_attribute18,
                    ecr_attribute19,
                    ecr_attribute20,
                    ecr_attribute21,
                    ecr_attribute22,
                    ecr_attribute23,
                    ecr_attribute24,
                    ecr_attribute25,
                    ecr_attribute26,
                    ecr_attribute27,
                    ecr_attribute28,
                    ecr_attribute29,
                    ecr_attribute30,
                    last_update_login,
                    created_by,
                    creation_date,
                    last_updated_by,
                    last_update_date,
                    request_id,
                    program_application_id,
                    program_id,
                    program_update_date,
                    object_version_number)
           VALUES(
             ben_enrt_rt_s.nextval,
             l_ecr_rec.acty_typ_cd,
             l_ecr_rec.tx_typ_cd,
             l_ecr_rec.ctfn_rqd_flag,
             l_ecr_rec.dflt_flag,
             l_ecr_rec.dflt_pndg_ctfn_flag,
             l_ecr_rec.dsply_on_enrt_flag,
             l_ecr_rec.use_to_calc_net_flx_cr_flag,
             l_ecr_rec.entr_val_at_enrt_flag,
             l_ecr_rec.asn_on_enrt_flag,
             l_ecr_rec.rl_crs_only_flag,
             l_ecr_rec.dflt_val,
             l_ecr_rec.ann_val,
             l_ecr_rec.ann_mn_elcn_val,
             l_ecr_rec.ann_mx_elcn_val,
             l_ecr_rec.val,
             -- 3216667 : iss_val, mx_elcn_val, mn_elcn_val are passed to
             -- cloned rows.
             l_ecr_rec.ISS_VAL,
             l_ecr_rec.nnmntry_uom,
             -- Initially they have to go null.
             l_ecr_rec.mx_elcn_val,
             l_ecr_rec.mn_elcn_val,
             l_ecr_rec.incrmt_elcn_val,
             l_ecr_rec.cmcd_acty_ref_perd_cd,
             -- Initially they have to go null.
             null, --l_ecr_rec.cmcd_mn_elcn_val,
             null, --l_ecr_rec.cmcd_mx_elcn_val,
             l_ecr_rec.cmcd_val,
             null,
             l_ecr_rec.rt_usg_cd,
             l_ecr_rec.ann_dflt_val,
             l_ecr_rec.bnft_rt_typ_cd,
             l_ecr_rec.rt_mlt_cd,
             -- Initially they have to go null.
             null, -- l_ecr_rec.dsply_mn_elcn_val,
             null, -- l_ecr_rec.dsply_mx_elcn_val,
             l_ecr_rec.entr_ann_val_flag,
             l_ecr_rec.rt_strt_dt,
             l_ecr_rec.rt_strt_dt_cd,
             l_ecr_rec.rt_strt_dt_rl,
             l_ecr_rec.rt_typ_cd,
             l_elig_per_elctbl_chc_id,
             l_ecr_rec.acty_base_rt_id,
             null,
             null, -- enrt_bnft_id : Should be null
             null, -- prtt_rt_val_id : should be null
             l_ecr_rec.decr_bnft_prvdr_pool_id,
             l_ecr_rec.cvg_amt_calc_mthd_id,
             l_ecr_rec.actl_prem_id,
             l_ecr_rec.comp_lvl_fctr_id,
             l_ecr_rec.ptd_comp_lvl_fctr_id,
             l_ecr_rec.clm_comp_lvl_fctr_id,
             l_curr_epe.per_business_group_id,
             l_ecr_rec.ecr_attribute_category,
             l_ecr_rec.ecr_attribute1,
             l_ecr_rec.ecr_attribute2,
             l_ecr_rec.ecr_attribute3,
             l_ecr_rec.ecr_attribute4,
             l_ecr_rec.ecr_attribute5,
             l_ecr_rec.ecr_attribute6,
             l_ecr_rec.ecr_attribute7,
             l_ecr_rec.ecr_attribute8,
             l_ecr_rec.ecr_attribute9,
             l_ecr_rec.ecr_attribute10,
             l_ecr_rec.ecr_attribute11,
             l_ecr_rec.ecr_attribute12,
             l_ecr_rec.ecr_attribute13,
             l_ecr_rec.ecr_attribute14,
             l_ecr_rec.ecr_attribute15,
             l_ecr_rec.ecr_attribute16,
             l_ecr_rec.ecr_attribute17,
             l_ecr_rec.ecr_attribute18,
             l_ecr_rec.ecr_attribute19,
             l_ecr_rec.ecr_attribute20,
             l_ecr_rec.ecr_attribute21,
             l_ecr_rec.ecr_attribute22,
             l_ecr_rec.ecr_attribute23,
             l_ecr_rec.ecr_attribute24,
             l_ecr_rec.ecr_attribute25,
             l_ecr_rec.ecr_attribute26,
             l_ecr_rec.ecr_attribute27,
             l_ecr_rec.ecr_attribute28,
             l_ecr_rec.ecr_attribute29,
             l_ecr_rec.ecr_attribute30,
             l_last_update_login,
             l_created_by,
             l_creation_date,
             l_last_updated_by,
             trunc(SYSDATE),
             fnd_global.conc_request_id,
             fnd_global.prog_appl_id,
             fnd_global.conc_program_id,
             trunc(SYSDATE),
             l_object_version_number);
            --
         end loop; -- Rates for loop
         --
     end loop; -- epe for loop
     l_mgr_person_id          := l_mgr_person_id_temp;
     --
   end if;
   --
 end loop; -- while loop
 --
 if g_debug then
   hr_utility.set_location ('Leaving '||l_package,10);
 end if;
 --
end popu_cross_gb_epe_pel_data;
--
/*
procedure popu_cross_gb_epe_data(
         p_mode                     in varchar2,
         p_person_id                in number,
         p_business_group_id        in number,
         p_ler_id                   in number,
         p_pl_id                    in number,
         p_effective_date           in date,
         p_lf_evt_ocrd_dt           in date
) is
 --
 l_package               varchar2(80);
 --
 l_rec                        benutils.g_active_life_event;
 l_mgr_rec                    benutils.g_active_life_event;
 l_mgr_rec_temp               benutils.g_active_life_event;
 l_effective_date             date := nvl(p_lf_evt_ocrd_dt, p_effective_date);
 l_procd_dt                   date;
 l_strtd_dt                   date;
 l_voidd_dt                   date;
 l_ptnl_ler_for_per_id        number;
 l_object_version_number      number;
 l_dummy_per_in_ler_id        number;
 l_mgr_per_in_ler_not_found   boolean;
 l_mgr_person_id              number;
 l_mgr_person_id_temp         number;
 l_assignment_id              number;
 l_elig_per_elctbl_chc_id     number;
 --
 l_created_by             ben_elig_per_elctbl_chc.created_by%TYPE;
 l_creation_date          ben_elig_per_elctbl_chc.creation_date%TYPE;
 l_last_update_date       ben_elig_per_elctbl_chc.last_update_date%TYPE;
 l_last_updated_by        ben_elig_per_elctbl_chc.last_updated_by%TYPE;
 l_last_update_login      ben_elig_per_elctbl_chc.last_update_login%TYPE;
 --
 cursor c_epe(cv_per_in_ler_id in number) is
  select epe.* ,
         pel.dflt_enrt_dt,
         pel.cls_enrt_dt_to_use_cd,
         pel.enrt_typ_cycl_cd,
         pel.enrt_perd_strt_dt,
         pel.enrt_perd_end_dt,
         pel.lee_rsn_id,
         pel.enrt_perd_id,
         pel.uom,
         pel.acty_ref_perd_cd,
         epe.business_group_id per_business_group_id,
         per.business_group_id mgr_business_group_id
  from   ben_elig_per_elctbl_chc epe,
         ben_pil_elctbl_chc_popl pel,
         per_all_people_f per
  where  epe.per_in_ler_id = cv_per_in_ler_id
    and  epe.per_in_ler_id = pel.per_in_ler_id
    and  epe.pl_id         = pel.pl_id
    and  epe.ws_mgr_id     = per.person_id (+)
    and  l_effective_date between effective_start_date
                              and effective_end_date;
 --
 cursor c_ecr(cv_elig_per_elctbl_chc_id in number) is
   select ecr.*
   from ben_enrt_rt ecr
   where ecr.elig_per_elctbl_chc_id = cv_elig_per_elctbl_chc_id;
 --
 l_curr_epe c_epe%rowtype;
 --
 -- Gets the enrolment information for this plan
 --
 CURSOR c_plan_enrolment_info(cv_person_id in number,
                              cv_business_group_id in number,
                              cv_lf_evt_ocrd_dt    in date,
                              cv_pl_id             in number,
                              cv_pgm_id            in number)
 IS
      SELECT   pen.prtt_enrt_rslt_id
      FROM     ben_prtt_enrt_rslt_f pen
      WHERE    pen.person_id         = cv_person_id
      AND      pen.business_group_id = cv_business_group_id
      AND      pen.sspndd_flag       = 'N'
      AND      pen.prtt_enrt_rslt_stat_cd IS NULL
      AND      pen.effective_end_date = hr_api.g_eot
      AND      cv_lf_evt_ocrd_dt <= pen.enrt_cvg_thru_dt
      AND      pen.enrt_cvg_strt_dt < pen.effective_end_date
      AND      cv_pl_id = pen.pl_id
      AND      (
                    (    pen.pgm_id = cv_pgm_id
                     AND cv_pgm_id IS NOT NULL)
                 OR (    pen.pgm_id IS NULL
                     AND cv_pgm_id IS NULL));
 --
 l_prtt_enrt_rslt_id number := null;
 --
 l_emp_epe_id   number;
 --
 cursor c_cwb_hrchy(cv_emp_epe_id in number) is
   select emp_elig_per_elctbl_chc_id
   from ben_cwb_mgr_hrchy
   where emp_elig_per_elctbl_chc_id = cv_emp_epe_id;
  --
begin
 --
 if g_debug then
   l_package := g_package||'.popu_cross_gb_epe_data';
   hr_utility.set_location ('Entering '||l_package,10);
 end if;
 --
 benutils.get_active_life_event
   (p_person_id         => p_person_id,
   p_business_group_id => p_business_group_id,
   p_effective_date    => p_effective_date,
   p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
   p_ler_id            => p_ler_id,
   p_rec               => l_rec);
 --
 -- Get the manager information.
 --
 open c_epe(l_rec.per_in_ler_id);
 fetch c_epe into l_curr_epe;
 close c_epe;
 --
 -- Bug 2541072 for person selection rule dummy le is not created. We need to
 -- do this for same business group also.
 --
 -- if l_curr_epe.per_business_group_id <> l_curr_epe.mgr_business_group_id
 -- then
    --
    -- Now loop through the manager heirarchy and duplicate the data.
    --
    l_mgr_per_in_ler_not_found := true;
    l_mgr_person_id            := l_curr_epe.ws_mgr_id;
    --
    while l_mgr_per_in_ler_not_found loop
      --
      -- Get per in ler for manager in per_business_group_id.
      --
      l_mgr_rec       := l_mgr_rec_temp;
      --
      benutils.get_active_life_event
       (p_person_id         => l_mgr_person_id,
        p_business_group_id => l_curr_epe.per_business_group_id,
        p_effective_date    => p_effective_date,
        p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
        p_ler_id            => p_ler_id,
        p_rec               => l_mgr_rec);
      --
      if l_mgr_rec.per_in_ler_id is not null  or l_mgr_person_id is null then
         l_mgr_per_in_ler_not_found := false;
      else
         --
         -- Now duplicate the pil, pel, epe, ecr data.
         --
         l_mgr_per_in_ler_not_found := true;
         --
         -- Need to copy potential ler for per.
         --
         ben_ptnl_ler_for_per_api.create_ptnl_ler_for_per_perf
           (p_validate                 => false,
            p_ptnl_ler_for_per_id      => l_ptnl_ler_for_per_id,
            p_lf_evt_ocrd_dt           => l_effective_date,
            p_ptnl_ler_for_per_stat_cd => 'PROCD' ,
                                          --l_ptnl_ler_for_per_stat_cd_use,
            p_ler_id                   => p_ler_id,
            p_person_id                => l_mgr_person_id,
            p_ntfn_dt                  => p_effective_date, -- l_ntfn_dt,
            p_procd_dt                 => p_effective_date,
            p_dtctd_dt                 => p_effective_date,
            p_business_group_id        => l_curr_epe.per_business_group_id,
            p_object_version_number    => l_object_version_number,
            p_effective_date           => l_effective_date,
            p_program_application_id   => fnd_global.prog_appl_id,
            p_program_id               => fnd_global.conc_program_id,
            p_request_id               => fnd_global.conc_request_id,
            p_program_update_date      => l_effective_date);
         --
         ben_Person_Life_Event_api.create_Person_Life_Event_perf
           (p_validate                => false
           ,p_per_in_ler_id           => l_dummy_per_in_ler_id
           ,p_ler_id                  => p_ler_id
           ,p_person_id               => l_mgr_person_id
           ,p_per_in_ler_stat_cd      => 'STRTD'
           ,p_ptnl_ler_for_per_id     => l_ptnl_ler_for_per_id
           ,p_lf_evt_ocrd_dt          => p_lf_evt_ocrd_dt
           ,p_business_group_id       => l_curr_epe.per_business_group_id
           ,p_ntfn_dt                 => trunc(sysdate)
           ,p_object_version_number   => l_object_version_number
           ,p_effective_date          => l_effective_date
           ,p_program_application_id  => fnd_global.prog_appl_id
           ,p_program_id              => fnd_global.conc_program_id
           ,p_request_id              => fnd_global.conc_request_id
           ,p_program_update_date     => trunc(sysdate)
           ,p_procd_dt                => l_procd_dt
           ,p_strtd_dt                => l_strtd_dt
           ,p_voidd_dt                => l_voidd_dt);
         --
         --
         -- Now get the manager for l_mgr_person_id.
         --

         --l_mgr_person_id_temp := ben_enrolment_requirements.get_manager_id(
         --    p_person_id             => l_mgr_person_id,
         --    p_hrchy_to_use_cd       =>
         --         ben_enrolment_requirements.g_ple_hrchy_to_use_cd,
         --    p_pos_structure_version_id =>
         --         ben_enrolment_requirements.g_ple_pos_structure_version_id,
         --    p_effective_date        => l_effective_date);

         -- But 2172036 addition of assignment_id to epe
         --
         ben_enrolment_requirements.get_cwb_manager_and_assignment(
             p_person_id                => l_mgr_person_id,
             p_hrchy_to_use_cd          =>
                  ben_enrolment_requirements.g_ple_hrchy_to_use_cd,
             p_pos_structure_version_id =>
                  ben_enrolment_requirements.g_ple_pos_structure_version_id,
             p_effective_date            => l_effective_date,
             p_manager_id                => l_mgr_person_id_temp,
             p_assignment_id             => l_assignment_id );
         --
         l_prtt_enrt_rslt_id  := null;
         --
         -- For Dummy rows no need to determine previous result
         -- open c_plan_enrolment_info(
         --   cv_person_id         => l_mgr_person_id,
         --   cv_business_group_id => l_curr_epe.mgr_business_group_id,
         --   cv_lf_evt_ocrd_dt    => l_effective_date,
         --   cv_pl_id             => l_curr_epe.pl_id,
         --   cv_pgm_id            => l_curr_epe.pgm_id);
         -- fetch c_plan_enrolment_info into l_prtt_enrt_rslt_id;
         -- close c_plan_enrolment_info;
         --
         if g_debug then
           hr_utility.set_location('EPEC_CRE: Cross BG ' || l_package, 10);
         end if;
         ben_elig_per_elc_chc_api.create_perf_elig_per_elc_chc(
           p_elig_per_elctbl_chc_id => l_elig_per_elctbl_chc_id,
           p_business_group_id      => l_curr_epe.per_business_group_id,
           p_auto_enrt_flag         => l_curr_epe.auto_enrt_flag,
           p_per_in_ler_id          => l_dummy_per_in_ler_id,
           p_yr_perd_id             => l_curr_epe.yr_perd_id,
           p_pl_id                  => l_curr_epe.pl_id,
           p_pl_typ_id              => l_curr_epe.pl_typ_id,
           p_oipl_id                => l_curr_epe.oipl_id,
           p_pgm_id                 => l_curr_epe.pgm_id,
           -- p_pgm_typ_cd             => l_curr_epe.pgm_typ_cd,
           p_must_enrl_anthr_pl_id  => l_curr_epe.must_enrl_anthr_pl_id,
           p_plip_id                => l_curr_epe.plip_id,
           p_ptip_id                => l_curr_epe.ptip_id,
           -- As per CWB team l_prtt_enrt_rslt_id can go as null.
           p_prtt_enrt_rslt_id      => l_prtt_enrt_rslt_id,
           --
           p_enrt_typ_cycl_cd       => l_curr_epe.enrt_typ_cycl_cd,
           p_comp_lvl_cd            => l_curr_epe.comp_lvl_cd,
           p_enrt_cvg_strt_dt_cd    => l_curr_epe.enrt_cvg_strt_dt_cd,
           p_enrt_perd_end_dt       => l_curr_epe.enrt_perd_end_dt,
           p_enrt_perd_strt_dt      => l_curr_epe.enrt_perd_strt_dt,
           p_enrt_cvg_strt_dt_rl    => l_curr_epe.enrt_cvg_strt_dt_rl,
           p_roll_crs_flag          => 'N',
           p_ctfn_rqd_flag          => l_curr_epe.ctfn_rqd_flag,
           p_crntly_enrd_flag       => 'N',-- l_curr_epe.crntly_enrd_flag,
           p_dflt_flag              => l_curr_epe.dflt_flag,
           p_elctbl_flag            => 'N',-- l_curr_epe.elctbl_flag,
           p_mndtry_flag            => l_curr_epe.mndtry_flag,
           p_dflt_enrt_dt           => l_curr_epe.dflt_enrt_dt,
           p_dpnt_cvg_strt_dt_cd    => NULL,
           p_dpnt_cvg_strt_dt_rl    => NULL,
           p_enrt_cvg_strt_dt       => l_curr_epe.enrt_cvg_strt_dt,
           p_alws_dpnt_dsgn_flag    => 'N',
           p_erlst_deenrt_dt        => l_curr_epe.erlst_deenrt_dt,
           p_procg_end_dt           => l_curr_epe.procg_end_dt,
           p_pl_ordr_num            => l_curr_epe.pl_ordr_num,
           p_plip_ordr_num          => l_curr_epe.plip_ordr_num,
           p_ptip_ordr_num          => l_curr_epe.ptip_ordr_num,
           p_oipl_ordr_num          => l_curr_epe.oipl_ordr_num,
           p_object_version_number  => l_object_version_number,
           p_effective_date         => l_effective_date,
           p_program_application_id => fnd_global.prog_appl_id,
           p_program_id             => fnd_global.conc_program_id,
           p_request_id             => fnd_global.conc_request_id,
           p_program_update_date    => trunc(SYSDATE),
           p_enrt_perd_id           => l_curr_epe.enrt_perd_id,
           p_lee_rsn_id             => l_curr_epe.lee_rsn_id,
           p_cls_enrt_dt_to_use_cd  => l_curr_epe.cls_enrt_dt_to_use_cd,
           p_uom                    => l_curr_epe.uom,
           p_acty_ref_perd_cd       => l_curr_epe.acty_ref_perd_cd,
           p_cryfwd_elig_dpnt_cd    => l_curr_epe.cryfwd_elig_dpnt_cd,
           -- added for cwb
           p_mode                   => p_mode,
           p_ws_mgr_id              => l_mgr_person_id_temp,
           p_elig_flag              => 'N',
           p_assignment_id          => l_assignment_id  ); -- l_curr_epe.elig_flag);
         -- Bug 2172036 and 2231371 added assignment_id in the above call
         --
         -- Populate the heirarchy table.
         --
         open c_cwb_hrchy(l_elig_per_elctbl_chc_id);
         fetch c_cwb_hrchy into l_emp_epe_id;
         --
         if c_cwb_hrchy%notfound then
          --
          insert into ben_cwb_mgr_hrchy (
             emp_elig_per_elctbl_chc_id,
             mgr_elig_per_elctbl_chc_id,
             lvl_num  )
          values(
             l_elig_per_elctbl_chc_id,
             -1,
             -1);
          --
         end if;
         --
         close c_cwb_hrchy;
         --
         if g_debug then
           hr_utility.set_location('Done EPEC_CRE Cross BG : ' || l_package, 10);
         end if;
         --
         for l_ecr_rec in c_ecr(l_curr_epe.elig_per_elctbl_chc_id)
         loop
            --
                  INSERT INTO ben_enrt_rt
                  (
                    enrt_rt_id,
                    acty_typ_cd,
                    tx_typ_cd,
                    ctfn_rqd_flag,
                    dflt_flag,
                    dflt_pndg_ctfn_flag,
                    dsply_on_enrt_flag,
                    use_to_calc_net_flx_cr_flag,
                    entr_val_at_enrt_flag,
                    asn_on_enrt_flag,
                    rl_crs_only_flag,
                    dflt_val,
                    ann_val,
                    ann_mn_elcn_val,
                    ann_mx_elcn_val,
                    val,
                    nnmntry_uom,
                    mx_elcn_val,
                    mn_elcn_val,
                    incrmt_elcn_val,
                    cmcd_acty_ref_perd_cd,
                    cmcd_mn_elcn_val,
                    cmcd_mx_elcn_val,
                    cmcd_val,
                    cmcd_dflt_val,
                    rt_usg_cd,
                    ann_dflt_val,
                    bnft_rt_typ_cd,
                    rt_mlt_cd,
                    dsply_mn_elcn_val,
                    dsply_mx_elcn_val,
                    entr_ann_val_flag,
                    rt_strt_dt,
                    rt_strt_dt_cd,
                    rt_strt_dt_rl,
                    rt_typ_cd,
                    elig_per_elctbl_chc_id,
                    acty_base_rt_id,
                    spcl_rt_enrt_rt_id,
                    enrt_bnft_id,
                    prtt_rt_val_id,
                    decr_bnft_prvdr_pool_id,
                    cvg_amt_calc_mthd_id,
                    actl_prem_id,
                    comp_lvl_fctr_id,
                    ptd_comp_lvl_fctr_id,
                    clm_comp_lvl_fctr_id,
                    business_group_id,
                    ecr_attribute_category,
                    ecr_attribute1,
                    ecr_attribute2,
                    ecr_attribute3,
                    ecr_attribute4,
                    ecr_attribute5,
                    ecr_attribute6,
                    ecr_attribute7,
                    ecr_attribute8,
                    ecr_attribute9,
                    ecr_attribute10,
                    ecr_attribute11,
                    ecr_attribute12,
                    ecr_attribute13,
                    ecr_attribute14,
                    ecr_attribute15,
                    ecr_attribute16,
                    ecr_attribute17,
                    ecr_attribute18,
                    ecr_attribute19,
                    ecr_attribute20,
                    ecr_attribute21,
                    ecr_attribute22,
                    ecr_attribute23,
                    ecr_attribute24,
                    ecr_attribute25,
                    ecr_attribute26,
                    ecr_attribute27,
                    ecr_attribute28,
                    ecr_attribute29,
                    ecr_attribute30,
                    last_update_login,
                    created_by,
                    creation_date,
                    last_updated_by,
                    last_update_date,
                    request_id,
                    program_application_id,
                    program_id,
                    program_update_date,
                    object_version_number)
           VALUES(
             ben_enrt_rt_s.nextval,
             l_ecr_rec.acty_typ_cd,
             l_ecr_rec.tx_typ_cd,
             l_ecr_rec.ctfn_rqd_flag,
             l_ecr_rec.dflt_flag,
             l_ecr_rec.dflt_pndg_ctfn_flag,
             l_ecr_rec.dsply_on_enrt_flag,
             l_ecr_rec.use_to_calc_net_flx_cr_flag,
             l_ecr_rec.entr_val_at_enrt_flag,
             l_ecr_rec.asn_on_enrt_flag,
             l_ecr_rec.rl_crs_only_flag,
             l_ecr_rec.dflt_val,
             l_ecr_rec.ann_val,
             l_ecr_rec.ann_mn_elcn_val,
             l_ecr_rec.ann_mx_elcn_val,
             l_ecr_rec.val,
             l_ecr_rec.nnmntry_uom,
             -- Initially they have to go null.
             null, -- l_ecr_rec.mx_elcn_val,
             null, -- l_ecr_rec.mn_elcn_val,
             l_ecr_rec.incrmt_elcn_val,
             l_ecr_rec.cmcd_acty_ref_perd_cd,
             -- Initially they have to go null.
             null, --l_ecr_rec.cmcd_mn_elcn_val,
             null, --l_ecr_rec.cmcd_mx_elcn_val,
             l_ecr_rec.cmcd_val,
             null,
             l_ecr_rec.rt_usg_cd,
             l_ecr_rec.ann_dflt_val,
             l_ecr_rec.bnft_rt_typ_cd,
             l_ecr_rec.rt_mlt_cd,
             -- Initially they have to go null.
             null, -- l_ecr_rec.dsply_mn_elcn_val,
             null, -- l_ecr_rec.dsply_mx_elcn_val,
             l_ecr_rec.entr_ann_val_flag,
             l_ecr_rec.rt_strt_dt,
             l_ecr_rec.rt_strt_dt_cd,
             l_ecr_rec.rt_strt_dt_rl,
             l_ecr_rec.rt_typ_cd,
             l_elig_per_elctbl_chc_id,
             l_ecr_rec.acty_base_rt_id,
             null,
             null, -- enrt_bnft_id : Should be null
             null, -- prtt_rt_val_id : should be null
             l_ecr_rec.decr_bnft_prvdr_pool_id,
             l_ecr_rec.cvg_amt_calc_mthd_id,
             l_ecr_rec.actl_prem_id,
             l_ecr_rec.comp_lvl_fctr_id,
             l_ecr_rec.ptd_comp_lvl_fctr_id,
             l_ecr_rec.clm_comp_lvl_fctr_id,
             l_curr_epe.per_business_group_id,
             l_ecr_rec.ecr_attribute_category,
             l_ecr_rec.ecr_attribute1,
             l_ecr_rec.ecr_attribute2,
             l_ecr_rec.ecr_attribute3,
             l_ecr_rec.ecr_attribute4,
             l_ecr_rec.ecr_attribute5,
             l_ecr_rec.ecr_attribute6,
             l_ecr_rec.ecr_attribute7,
             l_ecr_rec.ecr_attribute8,
             l_ecr_rec.ecr_attribute9,
             l_ecr_rec.ecr_attribute10,
             l_ecr_rec.ecr_attribute11,
             l_ecr_rec.ecr_attribute12,
             l_ecr_rec.ecr_attribute13,
             l_ecr_rec.ecr_attribute14,
             l_ecr_rec.ecr_attribute15,
             l_ecr_rec.ecr_attribute16,
             l_ecr_rec.ecr_attribute17,
             l_ecr_rec.ecr_attribute18,
             l_ecr_rec.ecr_attribute19,
             l_ecr_rec.ecr_attribute20,
             l_ecr_rec.ecr_attribute21,
             l_ecr_rec.ecr_attribute22,
             l_ecr_rec.ecr_attribute23,
             l_ecr_rec.ecr_attribute24,
             l_ecr_rec.ecr_attribute25,
             l_ecr_rec.ecr_attribute26,
             l_ecr_rec.ecr_attribute27,
             l_ecr_rec.ecr_attribute28,
             l_ecr_rec.ecr_attribute29,
             l_ecr_rec.ecr_attribute30,
             l_last_update_login,
             l_created_by,
             l_creation_date,
             l_last_updated_by,
             trunc(SYSDATE),
             fnd_global.conc_request_id,
             fnd_global.prog_appl_id,
             fnd_global.conc_program_id,
             trunc(SYSDATE),
             l_object_version_number);
            --
         end loop;
         --
         l_mgr_person_id          := l_mgr_person_id_temp;
         --
      end if;
    end loop;
 -- end if;
 --
 if g_debug then
   hr_utility.set_location ('Leaving '||l_package,10);
 end if;
 --
end popu_cross_gb_epe_data;
*/
--
-- checks if there are any eligible options for the plan
-- if No then
--    if trk_inelig_flag is set to 'N' at plan level then
--       delete the elctbl chc for the plan
--    else if trk_inelig_flag is set to 'Y' at plan level then
--       update the elctbl chc for the plan to ineligible
--    end
--  end
--
procedure update_cwb_epe
(p_per_in_ler_id number,
 p_effective_date date) is

  l_elig_per_elctbl_chc_id   number;
  l_ovn number;
  l_pl_id number;
  l_dummy varchar2(1);
  l_package varchar2(80) := g_package||'.update_cwb_epe';

  cursor c_pln is
  select pl.trk_inelig_per_flag
    from ben_pl_f pl
   where pl.pl_id = l_pl_id
     and p_effective_date between pl.effective_start_date and
         pl.effective_end_date;

  cursor c_pln_opt is
  select 'x'
    from ben_oipl_f oipl
   where oipl.pl_id = l_pl_id
     and p_effective_date between oipl.effective_start_date and
         oipl.effective_end_date;

  cursor c_epe1 is
  select epe1.elig_per_elctbl_chc_id,
         epe1.object_version_number,
         epe1.pl_id
    from ben_elig_per_elctbl_chc epe1
   where epe1.per_in_ler_id = p_per_in_ler_id
     and epe1.pl_id is not null
     and epe1.oipl_id is null;

  cursor c_epe2 is
  select 'x'
    from ben_elig_per_elctbl_chc epe2
   where epe2.per_in_ler_id = p_per_in_ler_id
     and epe2.oipl_id is not null
     and epe2.pl_id = l_pl_id
     and epe2.elig_flag ='Y';


begin

  if g_debug then
     hr_utility.set_location ('Entering '||l_package,10);
  end if;

  open c_epe1;
  fetch c_epe1 into
  l_elig_per_elctbl_chc_id,
  l_ovn,
  l_pl_id;
  if c_epe1%notfound then
     return;
  end if;
  close c_epe1;

  if g_trk_inelig_flag is null then
     open c_pln;
     fetch c_pln into g_trk_inelig_flag;
     close c_pln;
  end if;

  if g_opt_exists is null then
     open c_pln_opt;
     fetch c_pln_opt into l_dummy;
     g_opt_exists := c_pln_opt%found;
     close c_pln_opt;
  end if;

  if g_opt_exists then
     open c_epe2;
     fetch c_epe2 into l_dummy;
     if c_epe2%notfound then
        if g_trk_inelig_flag ='N' then
          /* GLOBALCWB : If this data is deleted then no cwb rates are written
             co do not delete
          ben_elig_per_elc_chc_api.delete_ELIG_PER_ELC_CHC
          (p_elig_per_elctbl_chc_id   => l_elig_per_elctbl_chc_id
          ,p_object_version_number    => l_ovn
          ,p_effective_date           => p_effective_date);
          */
          null;
        else
          ben_elig_per_elc_chc_api.update_perf_ELIG_PER_ELC_CHC
          (p_elig_per_elctbl_chc_id   => l_elig_per_elctbl_chc_id
          ,p_elig_flag                => 'N'
          ,p_inelig_rsn_cd            => 'OTH'
          ,p_object_version_number    => l_ovn
          ,p_effective_date           => p_effective_date);
        end if;
     end if;
     close c_epe2;
  end if;

  if g_debug then
     hr_utility.set_location ('Leaving '||l_package,10);
  end if;

exception
  when others then
       if c_epe2%isopen then
          close c_epe2;
       end if;
       raise;
end;

--
-- deletes per in ler for people with no elctble chc when
-- trk_inelig_per_flag is set to N
--
procedure del_cwb_pil
(p_person_id      in  number,
 p_pl_id          in  number,
 p_effective_date in  date,
 p_ler_id         in  number,
 p_lf_evt_ocrd_dt in  date) is

cursor c_pil is
select pil.per_in_ler_id,
       ptnl.ptnl_ler_for_per_id,
       ptnl.object_version_number ptnl_ovn,
       pil.object_version_number pil_ovn
  from ben_per_in_ler pil,
       ben_ptnl_ler_for_per ptnl
 where pil.ler_id = p_ler_id
   and pil.lf_evt_ocrd_dt = p_lf_evt_ocrd_dt
   and pil.person_id = p_person_id
   and ptnl.ptnl_ler_for_per_id = pil.ptnl_ler_for_per_id
   and not exists
       (select 'x'
          from ben_elig_per_elctbl_chc epe
         where epe.per_in_ler_id = pil.per_in_ler_id);
l_pil_rec c_pil%rowtype;

cursor c_popl is
select pil_elctbl_chc_popl_id,
       object_version_number
  from ben_pil_elctbl_chc_popl
 where per_in_ler_id = l_pil_rec.per_in_ler_id;
l_popl_rec c_popl%rowtype;

l_package varchar2(80);

begin

   if g_debug then
     l_package := g_package||'.del_cwb_pil';
     hr_utility.set_location ('Entering '||l_package,10);
   end if;

   open c_pil;
   fetch c_pil into l_pil_rec;
   if c_pil%found then

      open c_popl;
      loop
           fetch c_popl into l_popl_rec;
           if c_popl%notfound then
              exit;
           end if;

           ben_Pil_Elctbl_chc_Popl_api.delete_Pil_Elctbl_chc_Popl
          (p_pil_elctbl_chc_popl_id   => l_popl_rec.pil_elctbl_chc_popl_id,
           p_object_version_number  => l_popl_rec.object_version_number,
           p_effective_date         => p_effective_date);

      end loop;
      close c_popl;

      ben_Person_Life_Event_api.delete_Person_Life_Event
     (p_per_in_ler_id          => l_pil_rec.per_in_ler_id,
      p_object_version_number  => l_pil_rec.pil_ovn,
      p_effective_date         => p_effective_date);

      ben_ptnl_ler_for_per_api.delete_ptnl_ler_for_per
     (p_ptnl_ler_for_per_id    => l_pil_rec.ptnl_ler_for_per_id,
      p_object_version_number  => l_pil_rec.ptnl_ovn,
      p_effective_date         => p_effective_date);

   end if;
   close c_pil;

   if g_debug then
     hr_utility.set_location ('Leaving '||l_package,10);
   end if;

end;
--
procedure process_rows(p_benefit_action_id        in number,
                       p_start_person_action_id   in number,
                       p_end_person_action_id     in number,
                       p_business_group_id        in number,
                       p_mode                     in varchar2,
                       p_person_selection_rule_id in number,
                       p_comp_selection_rule_id   in number,
                       -- PB : 5422 :
               --  p_popl_enrt_typ_cycl_id    in number,
                       p_derivable_factors        in varchar2,
                       p_cbr_tmprl_evt_flag       in varchar2,
                       p_person_count             in out nocopy number,
                       p_error_person_count       in out nocopy number,
                       p_thread_id                in number,
                       p_validate                 in varchar2,
                       p_effective_date           in date,
                       p_lf_evt_ocrd_dt           in date,
                       p_gsp_eval_elig_flag       in varchar2 default null,      /* GSP Rate Sync */
                       p_lf_evt_oper_cd           in varchar2 default null       /* GSP Rate Sync */
                       ) is
  --
  l_ler_id                ben_person_actions.ler_id%type;
  l_person_id             ben_person_actions.person_id%type;
  l_person_action_id      ben_person_actions.person_action_id%type;
  l_object_version_number ben_person_actions.object_version_number%type;
  l_ptnl_ler_for_per_id   ben_ptnl_ler_for_per.ptnl_ler_for_per_id%type;
  l_effective_start_date  date;
  l_effective_end_date    date;
  l_dummy                 varchar2(1);
  l_count                 number := 0;
  l_threads               number;
  l_chunk_size            number;
  l_max_errors            number;
  l_package               varchar2(80);
  l_mnl_dt date;
  l_dtctd_dt   date;
  l_procd_dt   date;
  l_unprocd_dt date;
  l_voidd_dt   date;
  l_rec                   ben_env_object.g_global_env_rec_type;
  --
  cursor c_person_thread is
    select ben.person_id,
           ben.person_action_id,
           ben.object_version_number,
           ben.ler_id
    from   ben_person_actions ben
    where  ben.benefit_action_id = p_benefit_action_id
    and    ben.action_status_cd <> 'P'
    and    ben.person_action_id
           between p_start_person_action_id
           and     p_end_person_action_id
    order  by ben.person_action_id;
  --
  -- absences,gsp
  --
  cursor c_potential (p_person_id number) is
    select ptnl_ler_for_per_id
    from ben_ptnl_ler_for_per pfl,
         ben_ler_f ler
    where  pfl.ptnl_ler_for_per_stat_cd not in ('VOIDD','PROCD')
    and    pfl.person_id = p_person_id
    and    pfl.ler_id = ler.ler_id
    and    p_effective_date
           between ler.effective_start_date
           and     ler.effective_end_date
    and    pfl.lf_evt_ocrd_dt <= p_effective_date
    and    ler.typ_cd = decode(p_mode,'M','ABS','G','GSP',null)
    order  by pfl.lf_evt_ocrd_dt asc, ler.lf_evt_oper_cd desc;

  cursor c_pil (p_person_id number) is
    select 'x'
      from ben_per_in_ler pil,
           ben_ler_f ler
     where pil.per_in_ler_stat_cd = 'STRTD'
     and   pil.person_id = p_person_id
     and   pil.ler_id = ler.ler_id
     and   p_effective_date between ler.effective_start_date
     and   ler.effective_end_date
     and   ler.typ_cd = decode(p_mode,'M','ABS','G','GSP',null);

  l_potential_o number ;
  l_potential   number ;

begin
  --
  if g_debug then
    l_package := g_package||'.process_rows';
    hr_utility.set_location ('Entering '||l_package,10);
  end if;
  --
  open c_person_thread;
    --
    loop
      --
      if g_debug then
        hr_utility.set_location (l_package||' Start c_person_thread ',20);
      end if;
      fetch c_person_thread into l_person_id,
                                 l_person_action_id,
                                 l_object_version_number,
                                 l_ler_id;
      if g_debug then
        hr_utility.set_location (l_package||' fetch c_person_thread ',20);
      end if;
      exit when c_person_thread%notfound;
      --
      l_count := l_count + 1;
      --
      -- absence changes
      l_potential_o := null;
      l_potential := null;

      Loop
        --
        process_life_events
          (p_person_id                => l_person_id,
           p_person_action_id         => l_person_action_id,
           p_object_version_number    => l_object_version_number,
           p_business_group_id        => p_business_group_id,
           p_mode                     => p_mode,
           p_ler_id                   => l_ler_id,
           p_person_selection_rule_id => p_person_selection_rule_id,
           p_comp_selection_rule_id   => p_comp_selection_rule_id,
           p_derivable_factors        => p_derivable_factors,
           p_cbr_tmprl_evt_flag       => p_cbr_tmprl_evt_flag,
           p_person_count             => p_person_count,
           p_error_person_count       => p_error_person_count,
           p_effective_date           => p_effective_date,
           p_lf_evt_ocrd_dt           => p_lf_evt_ocrd_dt,
           p_validate                 => p_validate,                /* Bug 5550359 */
           p_gsp_eval_elig_flag       => p_gsp_eval_elig_flag,      /* GSP Rate Sync */
           p_lf_evt_oper_cd           => p_lf_evt_oper_cd           /* GSP Rate Sync */
           );
        --
        if p_mode in ('G','M') then
          -- absence mode loop
          -- if there are no ABS life events unprocessed
          --                   (or)
          -- if the processing of previous life event errored,
          -- then exit out of the loop
          open c_potential ( l_person_id );
          fetch c_potential into l_potential;
          if c_potential%notfound or
             l_potential = l_potential_o then
             close c_potential;
             exit;
          else
             open c_pil(l_person_id);
             fetch c_pil into l_dummy;
             if c_pil%found then
                close c_potential;
                close c_pil;
                exit;
             end if;
             close c_pil;
          end if;
          close c_potential;
          l_potential_o := l_potential;
        else
          -- exit out of the loop after one iteration
          exit;
        end if;
        --
      End loop;
      --
      --
      if g_debug then
        hr_utility.set_location('End c_person_thread loop '||l_package,10);
      end if;
      --
      -- We need to commit the validate mode stuff to the log and
      -- table at regular intervals, that way users can view the log
      -- before the process has finished
         --
         -- Populate rollback value tables
         --
         ben_populate_rbv.populate_benmngle_rbvs
           (p_benefit_action_id => p_benefit_action_id
           ,p_person_action_id  => l_person_action_id
           ,p_validate_flag     => p_validate
           );
         --
    end loop;
    --
  close c_person_thread;
  if g_debug then
    hr_utility.set_location (l_package||' close c_person_thread ',20);
  end if;
  --
  if ben_populate_rbv.validate_mode
    (p_validate => p_validate
    )
  then
    --
    rollback;
    --
  end if;
  --
/*
  if p_validate in ('Y','C')
  then
    --
    rollback;
    --
  end if;
  --
*/
  if g_debug then
    hr_utility.set_location (l_package||' Write TAF ',20);
  end if;
  benutils.write_table_and_file(p_table => true,
                                p_file  => true);
  commit;
  --
  if g_debug then
    hr_utility.set_location ('Leaving '||l_package,10);
  end if;
  --
end process_rows;
--

procedure set_up_cobj_part_elig
  (p_comp_obj_tree_row in out NOCOPY ben_manage_life_events.g_cache_proc_objects_rec
  ,p_ler_id            in     number
  ,p_business_group_id in     number
  ,p_effective_date    in     date
  )
is
  --
  l_proc varchar2(80);
  --
begin
  --
  if g_debug then
    l_proc := g_package || '.set_up_cobj_part_elig';
    hr_utility.set_location('Entering '||l_proc,10);
  end if;
  if p_comp_obj_tree_row.pgm_id is not null then
    --
    if g_debug then
      hr_utility.set_location('Setting up eligibility at the PGM level',10);
    end if;
    --
    ben_cobj_cache.get_pgm_dets
      (p_business_group_id => p_business_group_id
      ,p_effective_date    => p_effective_date
      ,p_pgm_id            => p_comp_obj_tree_row.pgm_id
      ,p_inst_row      => ben_cobj_cache.g_pgm_currow
      );
    --
    ben_cobj_cache.get_etpr_dets
      (p_business_group_id => p_business_group_id
      ,p_effective_date    => p_effective_date
      ,p_ler_id            => p_ler_id
      ,p_pgm_id            => p_comp_obj_tree_row.pgm_id
      ,p_inst_row      => ben_cobj_cache.g_pgmetpr_currow
      );
    --
    ben_cobj_cache.get_prel_dets
      (p_business_group_id => p_business_group_id
      ,p_effective_date    => p_effective_date
      ,p_pgm_id            => p_comp_obj_tree_row.pgm_id
      ,p_inst_row      => ben_cobj_cache.g_pgmprel_currow
      );
    --
    if g_debug then
      hr_utility.set_location('Done pgm setobjs '||l_proc,20);
    end if;
    --
  elsif p_comp_obj_tree_row.ptip_id is not null then
    --
    if g_debug then
      hr_utility.set_location('Setting up eligibility at the PTIP level',10);
    end if;
    --
    ben_cobj_cache.get_ptip_dets
      (p_business_group_id => p_business_group_id
      ,p_effective_date    => p_effective_date
      ,p_ptip_id           => p_comp_obj_tree_row.ptip_id
      ,p_inst_row      => ben_cobj_cache.g_ptip_currow
      );
    --
    ben_cobj_cache.get_etpr_dets
      (p_business_group_id => p_business_group_id
      ,p_effective_date    => p_effective_date
      ,p_ler_id            => p_ler_id
      ,p_ptip_id           => p_comp_obj_tree_row.ptip_id
      ,p_inst_row      => ben_cobj_cache.g_ptipetpr_currow
      );
    --
    ben_cobj_cache.get_prel_dets
      (p_business_group_id => p_business_group_id
      ,p_effective_date    => p_effective_date
      ,p_ptip_id           => p_comp_obj_tree_row.ptip_id
      ,p_inst_row      => ben_cobj_cache.g_ptipprel_currow
      );
    --
  elsif p_comp_obj_tree_row.plip_id is not null then
    --
    if g_debug then
      hr_utility.set_location('Setting up eligibility at the PLIP level',10);
    end if;
    --
    ben_cobj_cache.get_plip_dets
      (p_business_group_id => p_business_group_id
      ,p_effective_date    => p_effective_date
      ,p_plip_id           => p_comp_obj_tree_row.plip_id
      ,p_inst_row      => ben_cobj_cache.g_plip_currow
      );
    --
    ben_cobj_cache.get_etpr_dets
      (p_business_group_id => p_business_group_id
      ,p_effective_date    => p_effective_date
      ,p_ler_id            => p_ler_id
      ,p_plip_id           => p_comp_obj_tree_row.plip_id
      ,p_inst_row      => ben_cobj_cache.g_plipetpr_currow
      );
    --
    ben_cobj_cache.get_prel_dets
      (p_business_group_id => p_business_group_id
      ,p_effective_date    => p_effective_date
      ,p_plip_id           => p_comp_obj_tree_row.plip_id
      ,p_inst_row      => ben_cobj_cache.g_plipprel_currow
      );
    --
    if g_debug then
      hr_utility.set_location(' current ptip ' ||  p_comp_obj_tree_row.par_ptip_id, 99 );
      hr_utility.set_location(' current hash ' ||  ben_cobj_cache.g_ptip_currow.ptip_id, 99 ) ;
    end if;
    ---- bug : 2228464  tilak
    ---- Compensation object tree was populated in PGM,PL name  order
    ---- there cane a possibility of ptip falls in different levl
    ---- PRG1    MEDICAL ptip   mediacl plan1
    ---- PRG1    DEntal  ptip   DEntal Plan 1
    ---  PRG1    MEDICAL Ptip   Medical Plan2
    ---- in the above case of Medical Plan2  cached ptip is DENTAL but the current ptip is
    ---  Medical so the eligibility of PTIP validated for DENTAL not for MEDIACL
    ---  so if the ptip_id of current row is not matching with cached  then PTIP level
    ---  is refreshed , discussed with martin and he agreed that


    if p_comp_obj_tree_row.par_ptip_id <> ben_cobj_cache.g_ptip_currow.ptip_id then
        ben_cobj_cache.get_ptip_dets
          (p_business_group_id => p_business_group_id
          ,p_effective_date    => p_effective_date
          ,p_ptip_id           => p_comp_obj_tree_row.par_ptip_id
          ,p_inst_row      => ben_cobj_cache.g_ptip_currow
          );
        --
         ben_cobj_cache.get_etpr_dets
          (p_business_group_id => p_business_group_id
          ,p_effective_date    => p_effective_date
          ,p_ler_id            => p_ler_id
          ,p_ptip_id           => p_comp_obj_tree_row.par_ptip_id
          ,p_inst_row      => ben_cobj_cache.g_ptipetpr_currow
          );
         --
        ben_cobj_cache.get_prel_dets
          (p_business_group_id => p_business_group_id
          ,p_effective_date    => p_effective_date
          ,p_ptip_id           => p_comp_obj_tree_row.par_ptip_id
          ,p_inst_row      => ben_cobj_cache.g_ptipprel_currow
          );
    end if ;

    if g_debug then
      hr_utility.set_location('Done PLIP '||l_proc,30);
    end if;
    --
  elsif p_comp_obj_tree_row.pl_id is not null then
    --
    if g_debug then
      hr_utility.set_location('Setting up eligibility at the PLN level',10);
    end if;
    --
    ben_cobj_cache.get_pl_dets
      (p_business_group_id => p_business_group_id
      ,p_effective_date    => p_effective_date
      ,p_pl_id             => p_comp_obj_tree_row.pl_id
      ,p_inst_row      => ben_cobj_cache.g_pl_currow
      );
    --
    ben_cobj_cache.get_etpr_dets
      (p_business_group_id => p_business_group_id
      ,p_effective_date    => p_effective_date
      ,p_ler_id            => p_ler_id
      ,p_pl_id             => p_comp_obj_tree_row.pl_id
      ,p_inst_row      => ben_cobj_cache.g_pletpr_currow
      );
    --
    ben_cobj_cache.get_prel_dets
      (p_business_group_id => p_business_group_id
      ,p_effective_date    => p_effective_date
      ,p_pl_id             => p_comp_obj_tree_row.pl_id
      ,p_inst_row      => ben_cobj_cache.g_plprel_currow
      );
    --
    if g_debug then
      hr_utility.set_location('Done pln setobjs '||l_proc,20);
    end if;
    --
  elsif p_comp_obj_tree_row.oipl_id is not null then
    --
    if g_debug then
      hr_utility.set_location(l_proc||' OIPL NN ',20);
    end if;
    --
    ben_cobj_cache.get_oipl_dets
      (p_business_group_id => p_business_group_id
      ,p_effective_date    => p_effective_date
      ,p_oipl_id           => p_comp_obj_tree_row.oipl_id
      ,p_inst_row      => ben_cobj_cache.g_oipl_currow
      );
    --
    ben_cobj_cache.get_opt_dets
      (p_business_group_id => p_business_group_id
      ,p_effective_date    => p_effective_date
      ,p_opt_id            => ben_cobj_cache.g_oipl_currow.opt_id
      ,p_inst_row      => ben_cobj_cache.g_opt_currow
      );
    --
    ben_cobj_cache.get_etpr_dets
      (p_business_group_id => p_business_group_id
      ,p_effective_date    => p_effective_date
      ,p_ler_id            => p_ler_id
      ,p_oipl_id           => p_comp_obj_tree_row.oipl_id
      ,p_inst_row      => ben_cobj_cache.g_oipletpr_currow
      );
    --
    ben_cobj_cache.get_prel_dets
      (p_business_group_id => p_business_group_id
      ,p_effective_date    => p_effective_date
      ,p_oipl_id           => p_comp_obj_tree_row.oipl_id
      ,p_inst_row      => ben_cobj_cache.g_oiplprel_currow
      );
    --
    -- Check oiplip stuff
    --
    if p_comp_obj_tree_row.oiplip_id is not null then
      --
      ben_cobj_cache.get_oiplip_dets
        (p_business_group_id => p_business_group_id
        ,p_effective_date    => p_effective_date
        ,p_oiplip_id         => p_comp_obj_tree_row.oiplip_id
        ,p_inst_row      => ben_cobj_cache.g_oiplip_currow
        );
      --
    end if;
    --
    if g_debug then
      hr_utility.set_location('Done oipl setobjs '||l_proc,20);
    end if;
    --
  end if;
  --
  if g_debug then
    hr_utility.set_location('Leaving '||l_proc,10);
  end if;
  --
end set_up_cobj_part_elig;
--
procedure set_up_list_part_elig
  (p_ler_id            in number
  ,p_business_group_id in number
  ,p_effective_date    in date
  )
is
  --
  l_proc varchar2(80);
  --
  l_rec  ben_elig_to_prte_rsn_f%rowtype;
  --
begin
  --
  if g_debug then
    l_proc := g_package || '.set_up_list_part_elig';
    hr_utility.set_location('Entering '||l_proc,10);
  end if;
  --
  -- Loop through all comp objects and making a call to set up the eligibility
  -- cache.
  --
  for l_count in g_cache_proc_object.first..g_cache_proc_object.last loop
    --
    if g_debug then
      hr_utility.set_location('Start loop '||l_proc,20);
    end if;
    if g_cache_proc_object(l_count).pgm_id is not null then
      --
      if g_debug then
        hr_utility.set_location('Setting up eligibility at the PGM level',10);
      end if;
      --
      ben_elig_object.set_object
          (p_pgm_id            => g_cache_proc_object(l_count).pgm_id,
           p_ler_id            => p_ler_id,
           p_business_group_id => p_business_group_id,
           p_effective_date    => p_effective_date
          ,p_rec               => l_rec
           );
      --
      ben_elig_object.set_object
          (p_pgm_id            => g_cache_proc_object(l_count).pgm_id,
           p_business_group_id => p_business_group_id,
           p_effective_date    => p_effective_date);

      if g_debug then
        hr_utility.set_location('Done pgm setobjs '||l_proc,20);
      end if;
      --
    elsif g_cache_proc_object(l_count).pl_id is not null then
      --
      if g_debug then
        hr_utility.set_location('Setting up eligibility at the PLN level',10);
      end if;
      --
      ben_elig_object.set_object
          (p_pl_id             => g_cache_proc_object(l_count).pl_id,
           p_ler_id            => p_ler_id,
           p_business_group_id => p_business_group_id,
           p_effective_date    => p_effective_date
          ,p_rec               => l_rec
          );
      --
      ben_elig_object.set_object
          (p_pl_id             => g_cache_proc_object(l_count).pl_id,
           p_business_group_id => p_business_group_id,
           p_effective_date    => p_effective_date);
      if g_debug then
        hr_utility.set_location('Done pln setobjs '||l_proc,20);
      end if;
      --
    --
    elsif g_cache_proc_object(l_count).plip_id is not null then
      --
      if g_debug then
        hr_utility.set_location('Setting up eligibility at the PLIP level',10);
      end if;
      --
      ben_elig_object.set_object
          (p_plip_id           => g_cache_proc_object(l_count).plip_id,
           p_ler_id            => p_ler_id,
           p_business_group_id => p_business_group_id,
           p_effective_date    => p_effective_date
          ,p_rec               => l_rec
          );
      --
      if g_debug then
        hr_utility.set_location('Done plip ler sobjs '||l_proc,20);
      end if;
      ben_elig_object.set_object
          (p_plip_id           => g_cache_proc_object(l_count).plip_id,
           p_business_group_id => p_business_group_id,
           p_effective_date    => p_effective_date);
      --
      if g_debug then
        hr_utility.set_location('Done PLIP '||l_proc,30);
      end if;
      --
    elsif g_cache_proc_object(l_count).ptip_id is not null then
      --
      if g_debug then
        hr_utility.set_location('Setting up eligibility at the PTIP level',10);
        hr_utility.set_location('Current PTIP = '||
                              g_cache_proc_object(l_count).ptip_id,10);
        --
        hr_utility.set_location('ELOBJ_SOBJ '||l_proc,30);
      end if;
      ben_elig_object.set_object
          (p_ptip_id           => g_cache_proc_object(l_count).ptip_id,
           p_ler_id            => p_ler_id,
           p_business_group_id => p_business_group_id,
           p_effective_date    => p_effective_date
          ,p_rec               => l_rec
          );
      --
      ben_elig_object.set_object
          (p_ptip_id           => g_cache_proc_object(l_count).ptip_id,
           p_business_group_id => p_business_group_id,
           p_effective_date    => p_effective_date);
      --
    elsif g_cache_proc_object(l_count).oipl_id is not null then
      --
      if g_debug then
        hr_utility.set_location('Setting up eligibility at the OIPL level',10);
      end if;
      --
      if g_debug then
        hr_utility.set_location(l_proc||' OIPL NN ',20);
      end if;
      ben_elig_object.set_object
          (p_oipl_id           => g_cache_proc_object(l_count).oipl_id,
           p_ler_id            => p_ler_id,
           p_business_group_id => p_business_group_id,
           p_effective_date    => p_effective_date
          ,p_rec               => l_rec
          );
      --
      ben_elig_object.set_object
          (p_oipl_id           => g_cache_proc_object(l_count).oipl_id,
           p_business_group_id => p_business_group_id,
           p_effective_date    => p_effective_date);
      if g_debug then
        hr_utility.set_location('Done oipl setobjs '||l_proc,20);
      end if;
      --
    end if;
    --
  end loop;
  --
  if g_debug then
    hr_utility.set_location('Leaving '||l_proc,10);
  end if;
  --
end set_up_list_part_elig;
--
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
   p_lf_evt_oper_cd           in varchar2 default null       /* GSP Rate Sync */
   ) is
  --
  l_package                varchar2(80);
  l_row_id                 rowid;
  l_rows_found             boolean := false;
  l_record_number          number := 0;
  l_start_person_action_id number := 0;
  l_end_person_action_id   number := 0;
  l_person_count           number := 0;
  l_error_person_count     number := 0;
  l_chunk_size             number := 0;
  l_threads                number := 0;
  --
  l_effective_date         date;
  l_lf_evt_ocrd_dt         date;
  l_max_errors             number;
  l_commit                 number;
  l_slave_errored          boolean := false;
  --
  l_ler_rec                benutils.g_ler;
  --
begin
  --
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_package := g_package||'.do_multithread';
    hr_utility.set_location ('Entering '||l_package,10);
    hr_utility.set_location ('p_mode : '||p_mode,20);
  end if;
  --
  -- Convert varchar2 dates to real dates
  -- 1) First remove time component
  -- 2) Next convert format
  --
  /*
  l_effective_date := to_date(p_effective_date,'YYYY/MM/DD HH24:MI:SS');
  l_effective_date := to_date(to_char(trunc(l_effective_date),'DD/MM/RRRR'),'DD/MM/RRRR');
  l_lf_evt_ocrd_dt := to_date(p_lf_evt_ocrd_dt,'YYYY/MM/DD HH24:MI:SS');
  l_lf_evt_ocrd_dt := to_date(to_char(trunc(l_lf_evt_ocrd_dt),'DD/MM/RRRR'),'DD/MM/RRRR');
  */
  l_effective_date := trunc(fnd_date.canonical_to_date(p_effective_date));
  l_lf_evt_ocrd_dt := trunc(fnd_date.canonical_to_date(p_lf_evt_ocrd_dt));
  --
  benutils.get_ler
    (p_business_group_id     => p_business_group_id
    ,p_typ_cd                => 'SCHEDDU'
    ,p_effective_date        => l_effective_date
    ,p_rec                   => l_ler_rec
    );
  --
  g_ler_id := l_ler_rec.ler_id;
  g_derivable_factors := p_derivable_factors;
  --
  -- iRec
  if p_mode = 'I' then
    --
    -- Set G_LER_ID to iRecruitment LER_ID for subsequent use in ben_evaluate_ptnl_lf_evt
    --
    benutils.get_ler (p_business_group_id      => p_business_group_id,
    		    p_typ_cd                 => 'IREC',
    		    p_effective_date         => l_effective_date,
    		    p_rec                    => l_ler_rec
    		   );
    --
    g_ler_id := l_ler_rec.ler_id;
    --
  end if;
  -- iRec
  benutils.get_parameter
    (p_business_group_id => p_business_group_id,
     p_batch_exe_cd      => 'BENMNGLE',
     p_threads           => l_threads,
     p_chunk_size        => l_chunk_size,
     p_max_errors        => g_max_errors_allowed);

  if g_debug then
    hr_utility.set_location ('Dn get_parameter '||l_package,10);
  end if;
  --
  -- Clear benmngle level caches
  --
  ben_manage_life_events.clear_init_benmngle_caches
    (p_business_group_id => p_business_group_id
    ,p_effective_date    => l_effective_date
    ,p_threads           => l_threads
    ,p_chunk_size        => l_chunk_size
    ,p_max_errors        => g_max_errors_allowed
    ,p_benefit_action_id => p_benefit_action_id
    ,p_thread_id         => p_thread_id
    );
  --
  print_parameters
     (p_benefit_action_id        => p_benefit_action_id);
  --
  -- Bug: 4128034. CWB Mode fnd_session needs to be set.
  if p_mode in ('L' , 'W' ) then
    dt_fndate.change_ses_date
      (p_ses_date => l_effective_date
      ,p_commit   => l_commit
      );
  end if;
  --
  if p_mode in ('A','P','S','T') then
    --
    dt_fndate.change_ses_date
      (p_ses_date => l_effective_date
      ,p_commit   => l_commit
      );
    --
    -- PB : Healthnet changes
    -- Build the comp object list in evaluate_life_events
    -- if comp objects selection is based on person's org id.
    --
    if p_lmt_prpnip_by_org_flag = 'N' then
       --
       if g_debug then
         hr_utility.set_location (' Temp BCOL '||l_package,10);
       end if;
       ben_comp_object_list.build_comp_object_list
         (p_benefit_action_id      => p_benefit_action_id
         ,p_comp_selection_rule_id => p_comp_selection_rule_id
         ,p_effective_date         => l_effective_date
         ,p_pgm_id                 => p_pgm_id
         ,p_business_group_id      => p_business_group_id
         ,p_pl_id                  => p_pl_id

         -- PB : 5422 :
         -- Pass on the asnd_lf_evt_dt
         --
         ,p_asnd_lf_evt_dt         => null
         -- ,p_popl_enrt_typ_cycl_id  => p_popl_enrt_typ_cycl_id
         ,p_no_programs            => p_no_programs
         ,p_no_plans               => p_no_plans
         ,p_rptg_grp_id            => p_rptg_grp_id
         ,p_pl_typ_id              => p_pl_typ_id
         ,p_opt_id                 => p_opt_id
         ,p_eligy_prfl_id          => p_eligy_prfl_id
         ,p_vrbl_rt_prfl_id        => p_vrbl_rt_prfl_id
         ,p_thread_id              => p_thread_id
         ,p_mode                   => p_mode
         );
       --
       -- Set up participation eligibility for all comp objects in the list
       --
       set_up_list_part_elig
         (p_ler_id            => null
         ,p_business_group_id => p_business_group_id
         ,p_effective_date    => l_effective_date
         );
       if g_debug then
         hr_utility.set_location (' Dn Temp BCOL '||l_package,10);
       end if;
       --
    end if;
    --
  end if;
  --
  -- Non Validate Mode process
  -- -------------------------
  -- The process is as follows :
  -- 1) Lock the rows that are not processed
  -- 2) Grab the start and end person action id.
  -- 3) Process the person range
  -- 4) Go to number 1 again.
  --
  loop
    if g_debug then
      hr_utility.set_location (l_package||' START process_rows loop  ',20);
    end if;
    --
    -- Chunk scheduling changes
    --
    if g_debug then
      hr_utility.set_location (l_package||' open c_range_thread  ',22);
    end if;
    ben_maintain_benefit_actions.grab_next_batch_range
      (p_benefit_action_id      => p_benefit_action_id
      --
      ,p_start_person_action_id => l_start_person_action_id
      ,p_end_person_action_id   => l_end_person_action_id
      ,p_rows_found             => l_rows_found
      );
    --
    if g_debug then
      hr_utility.set_location (l_package||' Done c_range_thread ',25);
    end if;
    --
    if not l_rows_found then
      --
      exit;
      --
    end if;
    --
    commit;
    --
    -- Bug 1387371: Added to cure memory leaking problems.
    --              The date dependent comp object list caches are flushed
    --              every 15 minutes.
    --
    if (sysdate-g_prev_sysdate) > (1/96) then
      --
      ben_pln_cache.clear_down_cache;
      ben_cop_cache.clear_down_cache;
      --
      g_prev_sysdate := sysdate;
      --
    end if;
    --
    if g_debug then
      hr_utility.set_location ('p_mode : '||p_mode,25);
    end if;
    process_rows
      (p_benefit_action_id        => p_benefit_action_id,
       p_start_person_action_id   => l_start_person_action_id,
       p_end_person_action_id     => l_end_person_action_id,
       p_business_group_id        => p_business_group_id,
       p_mode                     => p_mode,
       p_person_selection_rule_id => p_person_selection_rule_id,
       p_comp_selection_rule_id   => p_comp_selection_rule_id,
       --
       -- PB : 5422 :
       -- Following parameter is no longer needed,
       --
       -- p_popl_enrt_typ_cycl_id    => p_popl_enrt_typ_cycl_id,
       p_derivable_factors        => p_derivable_factors,
       p_cbr_tmprl_evt_flag       => p_cbr_tmprl_evt_flag,
       p_person_count             => l_person_count,
       p_error_person_count       => l_error_person_count,
       p_thread_id                => p_thread_id,
       p_validate                 => p_validate,
       p_effective_date           => l_effective_date,
       p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt,
       p_gsp_eval_elig_flag       => p_gsp_eval_elig_flag,      /* GSP Rate Sync */
       p_lf_evt_oper_cd           => p_lf_evt_oper_cd           /* GSP Rate Sync */
       );
    --
    if g_debug then
      hr_utility.set_location (l_package||' END process_rows loop  ',50);
    end if;
  end loop;
  if g_debug then
    hr_utility.set_location (l_package||' Dn process_rows loop  ',50);
  end if;
  --
  -- Output log information to log file
  --
  write_logfile(p_benefit_action_id  => p_benefit_action_id,
                p_thread_id          => p_thread_id,
                p_validate           => p_validate,
                p_person_count       => l_person_count,
                p_error_person_count => l_error_person_count);
  --
  ben_maintain_benefit_actions.check_all_slaves_finished
    (p_benefit_action_id => p_benefit_action_id
    ,p_business_group_id => p_business_group_id
    ,p_slave_errored     => l_slave_errored
    );
  --
  if l_slave_errored  then
    --
    fnd_message.raise_error;
    --
  end if;
  --
  if g_debug then
    hr_utility.set_location ('Leaving '||l_package,10);
  end if;
  --
exception
  --
  when g_record_error then
     if g_debug then
       hr_utility.set_location (l_package||' Exception g_record_error ',50);
     end if;
     benutils.write(p_text => fnd_message.get);
      --
      -- Write the last bit of information for the thread
      --
      benutils.write_table_and_file(p_table => true,
                                    p_file  => true);
      commit;
      --
      -- Output log information to log file
      --
      write_logfile(p_benefit_action_id  => p_benefit_action_id,
                    p_thread_id          => p_thread_id,
                    p_validate           => 'Y',
                    p_person_count       => l_person_count,
                    p_error_person_count => l_error_person_count);

      ben_maintain_benefit_actions.check_all_slaves_finished
        (p_benefit_action_id => p_benefit_action_id
        ,p_business_group_id => p_business_group_id
        ,p_slave_errored     => l_slave_errored
        );
  --
  when others then
    --
    if not l_slave_errored then
      --
      if g_debug then
        hr_utility.set_location (l_package||' OTHERS Exc ',60);
      end if;
      rollback;
      if g_debug then
        hr_utility.set_location ('BENMNGLE Super Error '||l_package,10);
      end if;
      g_rec.rep_typ_cd := 'FATAL';
      g_rec.text := nvl(fnd_message.get,sqlerrm);
      if g_debug then
        hr_utility.set_location(substr(g_rec.text,1,100),10);
      end if;
      benutils.write(p_rec => g_rec);
      --
      -- Output log information to log file
      --
      write_logfile(p_benefit_action_id  => p_benefit_action_id,
                    p_thread_id          => p_thread_id,
                    p_validate           => 'Y',
                    p_person_count       => l_person_count,
                    p_error_person_count => l_error_person_count);
      --
      ben_maintain_benefit_actions.check_all_slaves_finished
        (p_benefit_action_id => p_benefit_action_id
        ,p_business_group_id => p_business_group_id
        ,p_slave_errored     => l_slave_errored
        );
      --
    end if;
    --
    -- Set generic system error with oracle SQLCODE as the token
    --
    fnd_message.set_name('BEN','BEN_91665_BENMNGLE_ERRORED');
    fnd_message.set_token('ORA_ERRCODE',SQLCODE);
    --
    benutils.write(p_text => fnd_message.get);
    benutils.write_table_and_file(p_table => true,
                                  p_file  => true);
    commit;
    if g_debug then
      hr_utility.set_location ('Others error '||l_package,100);
    end if;
    fnd_message.raise_error;
    --
end do_multithread;
--
procedure restart
          (errbuf                     out nocopy varchar2,
           retcode                    out nocopy number,
           p_benefit_action_id        in  number) is
  --
  l_package        varchar2(80);
  --
  cursor c_parameters is
    select process_date,
           mode_cd,
           derivable_factors_flag,
           validate_flag,
           person_id,
           person_type_id,
           pgm_id,
           business_group_id,
           pl_id,
           --
           -- PB : 5422 : No longer needed.
           -- popl_enrt_typ_cycl_id,
           --
           no_programs_flag,
           no_plans_flag,
           comp_selection_rl,
           person_selection_rl,
           ler_id,
           organization_id,
           benfts_grp_id,
           location_id,
           pstl_zip_rng_id,
           rptg_grp_id,
           pl_typ_id,
           opt_id,
           eligy_prfl_id,
           vrbl_rt_prfl_id,
           legal_entity_id,
           payroll_id,
           audit_log_flag,
           debug_messages_flag,
           -- PB : 5422 :
           -- Add lf_evt_ocrd_dt
           lf_evt_ocrd_dt,
           lmt_prpnip_by_org_flag,
           inelg_action_cd
    from   ben_benefit_actions ben
    where  ben.benefit_action_id = p_benefit_action_id;
  --
  l_parameters c_parameters%rowtype;
  l_errbuf     varchar2(80);
  l_retcode    number;
  --
begin
  --
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_package := g_package||'.restart';
    hr_utility.set_location ('Entering '||l_package,10);
  end if;
  --
  -- get the parameters for a previous run and do a restart
  --
  open c_parameters;
    --
    fetch c_parameters into l_parameters;
    if c_parameters%notfound then
      --
      fnd_message.set_name('BEN','BEN_91666_BENMNGLE_NO_RESTART');
      fnd_message.raise_error;
      --
    end if;
    --
  close c_parameters;
  --
  -- Call process procedure with parameters for restart
  --
  process
    (errbuf                     => l_errbuf,
     retcode                    => l_retcode,
     p_benefit_action_id        => p_benefit_action_id,
     p_effective_date           => fnd_date.date_to_canonical(l_parameters.process_date),
     p_mode                     => l_parameters.mode_cd,
     p_derivable_factors        => l_parameters.derivable_factors_flag,
     p_validate                 => l_parameters.validate_flag,
     p_person_id                => l_parameters.person_id,
     p_person_type_id           => l_parameters.person_type_id,
     p_pgm_id                   => l_parameters.pgm_id,
     p_business_group_id        => l_parameters.business_group_id,
     p_pl_id                    => l_parameters.pl_id,
     -- PB : 5422 :
     -- p_popl_enrt_typ_cycl_id    => l_parameters.popl_enrt_typ_cycl_id,
     p_no_programs              => l_parameters.no_programs_flag,
     p_no_plans                 => l_parameters.no_plans_flag,
     p_comp_selection_rule_id   => l_parameters.comp_selection_rl,
     p_person_selection_rule_id => l_parameters.person_selection_rl,
     p_ler_id                   => l_parameters.ler_id,
     p_organization_id          => l_parameters.organization_id,
     p_benfts_grp_id            => l_parameters.benfts_grp_id,
     p_location_id              => l_parameters.location_id,
     p_pstl_zip_rng_id          => l_parameters.pstl_zip_rng_id,
     p_rptg_grp_id              => l_parameters.rptg_grp_id,
     p_pl_typ_id                => l_parameters.pl_typ_id,
     p_opt_id                   => l_parameters.opt_id,
     p_eligy_prfl_id            => l_parameters.eligy_prfl_id,
     p_vrbl_rt_prfl_id          => l_parameters.vrbl_rt_prfl_id,
     p_legal_entity_id          => l_parameters.legal_entity_id,
     p_payroll_id               => l_parameters.payroll_id,
     p_commit_data              => 'Y',
     p_audit_log_flag           => l_parameters.audit_log_flag,
     p_cbr_tmprl_evt_flag       => l_parameters.debug_messages_flag,--cobra
     p_abs_historical_mode      => l_parameters.inelg_action_cd,
     p_lmt_prpnip_by_org_flag   => l_parameters.lmt_prpnip_by_org_flag,
     -- PB : 5422 :
     -- Now pass on the lf_evt_ocrd_dt
     p_lf_evt_ocrd_dt           => fnd_date.date_to_canonical(l_parameters.lf_evt_ocrd_dt));
  --
  -- The p_lf_evt_ocrd_dt needs to use lf_evt_ocrd_dt but that needs a schema
  -- change.
  --
  if g_debug then
    hr_utility.set_location ('Leaving '||l_package,10);
  end if;
  --
end restart;
--
-- wrapper for procedure process
--
procedure cwb_process
          (errbuf                     out nocopy varchar2,
           retcode                    out nocopy number,
           p_benefit_action_id        in number   default null,
           p_effective_date           in varchar2,
           p_mode                     in varchar2 default 'W',
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
           p_cbr_tmprl_evt_flag       in varchar2 default 'N',
	   p_cwb_person_type          in varchar2 default null) is
  --
  l_retcode number;
  l_errbuf  varchar2(1000);
  -- Bug 4394545 . This program is now cannot be submitted directly through SRS.
  l_exc_no_parent_req exception ;
  l_parent_req_id number ;
  l_temp BOOLEAN ;
  l_text varchar2(1000) ;
  --
  cursor c_get_parent_req_id is
   select parent_request_id
   from fnd_concurrent_requests
   where request_id = fnd_global.conc_request_id;
  --
begin
  --
  g_debug := hr_utility.debug_enabled;
  --
    open c_get_parent_req_id ;
    fetch c_get_parent_req_id into l_parent_req_id ;
    close c_get_parent_req_id ;
    -- Check for Parent request 4394545
    if l_parent_req_id is not null and
       l_parent_req_id = '-1' then
      -- Submitted by user
      raise l_exc_no_parent_req;
      --
    else
     -- Submitted by another Conc program, Continue processing
      process
          (errbuf                     =>l_errbuf,
           retcode                    =>l_retcode,
           p_benefit_action_id        =>p_benefit_action_id ,
           p_effective_date           =>p_effective_date,
           p_mode                     =>p_mode,
           p_derivable_factors        =>p_derivable_factors,
           p_validate                 =>p_validate,
           p_person_id                =>p_person_id,
           p_person_type_id           =>p_person_type_id,
           p_pgm_id                   =>p_pgm_id,
           p_business_group_id        =>p_business_group_id,
           p_pl_id                    =>p_pl_id,
           p_popl_enrt_typ_cycl_id    =>p_popl_enrt_typ_cycl_id,
           p_lf_evt_ocrd_dt           =>p_lf_evt_ocrd_dt,
           p_no_programs              =>p_no_programs,
           p_no_plans                 =>p_no_plans,
           p_comp_selection_rule_id   =>p_comp_selection_rule_id,
           p_person_selection_rule_id =>p_person_selection_rule_id,
           p_ler_id                   =>p_ler_id,
           p_organization_id          =>p_organization_id,
           p_benfts_grp_id            =>p_benfts_grp_id,
           p_location_id              =>p_location_id,
           p_pstl_zip_rng_id          =>p_pstl_zip_rng_id,
           p_rptg_grp_id              =>p_rptg_grp_id,
           p_pl_typ_id                =>p_pl_typ_id,
           p_opt_id                   =>p_opt_id,
           p_eligy_prfl_id            =>p_eligy_prfl_id,
           p_vrbl_rt_prfl_id          =>p_vrbl_rt_prfl_id,
           p_legal_entity_id          =>p_legal_entity_id,
           p_payroll_id               =>p_payroll_id,
           p_commit_data              =>p_commit_data,
           p_audit_log_flag           =>p_audit_log_flag,
           p_lmt_prpnip_by_org_flag   =>p_lmt_prpnip_by_org_flag,
           p_cbr_tmprl_evt_flag       =>p_cbr_tmprl_evt_flag ,
	   p_cwb_person_type          => p_cwb_person_type);
    --
    end if;
  --
Exception
when l_exc_no_parent_req then
  -- 4394545
  fnd_message.set_name('BEN','BEN_94272_COMOD_NO_SRS_SUBMIT');
  l_text := fnd_message.get ;
  FND_FILE.PUT_LINE(FND_FILE.LOG, l_text);
  l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', l_text) ;
  --
end cwb_process;
--
-- wrapper for CWB GLOBAL procedure process
--
procedure cwb_global_process
          (errbuf                     out nocopy varchar2,
           retcode                    out nocopy number,
           p_benefit_action_id        in number   default null,
           p_effective_date           in varchar2,
           p_mode                     in varchar2 default 'W',
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
           p_cbr_tmprl_evt_flag       in varchar2 default 'N',
           p_trace_plans_flag         in varchar2 default 'N',
	   p_cwb_person_type          in varchar2 default null,
           p_run_rollup_only          in varchar2 default 'N'    /* Bug 4875181 */
           ) is
  --
  l_retcode number;
  l_errbuf  varchar2(1000);
  l_commit number;
begin
  --
  g_debug := hr_utility.debug_enabled;
  --
  -- Bug: 4128034. CWB Mode fnd_session needs to be set.
  if p_mode = 'W' then
    dt_fndate.change_ses_date
      (p_ses_date => fnd_date.canonical_to_date(p_effective_date)
      ,p_commit   => l_commit
      );
  end if;
  --
  ben_manage_cwb_life_events.global_process
          (errbuf                     =>l_errbuf,
           retcode                    =>l_retcode,
           p_benefit_action_id        =>p_benefit_action_id ,
           p_effective_date           =>p_effective_date,
           p_mode                     =>p_mode,
           p_derivable_factors        =>p_derivable_factors,
           p_validate                 =>p_validate,
           p_person_id                =>p_person_id,
           p_person_type_id           =>p_person_type_id,
           p_pgm_id                   =>p_pgm_id,
           p_business_group_id        =>p_business_group_id,
           p_pl_id                    =>p_pl_id,
           p_popl_enrt_typ_cycl_id    =>p_popl_enrt_typ_cycl_id,
           p_lf_evt_ocrd_dt           =>p_lf_evt_ocrd_dt,
           p_no_programs              =>p_no_programs,
           p_no_plans                 =>p_no_plans,
           p_comp_selection_rule_id   =>p_comp_selection_rule_id,
           p_person_selection_rule_id =>p_person_selection_rule_id,
           p_ler_id                   =>p_ler_id,
           p_organization_id          =>p_organization_id,
           p_benfts_grp_id            =>p_benfts_grp_id,
           p_location_id              =>p_location_id,
           p_pstl_zip_rng_id          =>p_pstl_zip_rng_id,
           p_rptg_grp_id              =>p_rptg_grp_id,
           p_pl_typ_id                =>p_pl_typ_id,
           p_opt_id                   =>p_opt_id,
           p_eligy_prfl_id            =>p_eligy_prfl_id,
           p_vrbl_rt_prfl_id          =>p_vrbl_rt_prfl_id,
           p_legal_entity_id          =>p_legal_entity_id,
           p_payroll_id               =>p_payroll_id,
           p_commit_data              =>p_commit_data,
           p_audit_log_flag           =>p_audit_log_flag,
           p_lmt_prpnip_by_org_flag   =>p_lmt_prpnip_by_org_flag,
           p_cbr_tmprl_evt_flag       =>p_cbr_tmprl_evt_flag,
           p_trace_plans_flag         =>p_trace_plans_flag,
	   p_cwb_person_type          => p_cwb_person_type,
           p_run_rollup_only          =>p_run_rollup_only        /* Bug 4875181 */
           );
    --
end cwb_global_process;
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
  ,p_per_sel_freq_cd          in     varchar2 default null -- 2940151
  ,p_year_from                in     number   default null -- business rule year from
  ,p_year_to                  in     number   default null -- business rule year to
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
  )is
  --
  l_bin  binary_integer ;
  l_retcode number;
  l_errbuf  varchar2(1000);

begin
  --
--  hr_utility.trace_on(null, 'GSPRS');
  g_debug := hr_utility.debug_enabled;
/*
fnd_file.put_line(fnd_file.log,'p_benefit_action_id '||nvl(p_benefit_action_id, -1));
fnd_file.put_line(fnd_file.log,'p_effective_date '||p_effective_date);
fnd_file.put_line(fnd_file.log,'p_mode '||nvl(p_mode,'null'));
fnd_file.put_line(fnd_file.log,'p_business_group_id '||p_business_group_id);
fnd_file.put_line(fnd_file.log,'p_business_group_id '||p_business_group_id);
fnd_file.put_line(fnd_file.log,'p_business_group_id '||p_business_group_id);
fnd_file.put_line(fnd_file.log,'p_business_group_id '||p_business_group_id);
fnd_file.put_line(fnd_file.log,'p_business_group_id '||p_business_group_id);
fnd_file.put_line(fnd_file.log,'p_business_group_id '||p_business_group_id);
fnd_file.put_line(fnd_file.log,'p_business_group_id '||p_business_group_id);
fnd_file.put_line(fnd_file.log,'p_business_group_id '||p_business_group_id);
fnd_file.put_line(fnd_file.log,'p_business_group_id '||p_business_group_id);
fnd_file.put_line(fnd_file.log,'p_business_group_id '||p_business_group_id);
fnd_file.put_line(fnd_file.log,'p_business_group_id '||p_business_group_id);
fnd_file.put_line(fnd_file.log,'p_business_group_id '||p_business_group_id);
fnd_file.put_line(fnd_file.log,'p_business_group_id '||p_business_group_id);


  hr_utility.set_location ('Before Step 1',20);
  hr_utility.set_location ('p_effective_date '||p_effective_date,20);
  hr_utility.set_location ('p_business_group_id '||p_business_group_id,20);
  hr_utility.set_location ('p_commit_data '||p_commit_data,20);
  hr_utility.set_location ('p_audit_log_flag '||p_audit_log_flag,20);
  hr_utility.set_location ('p_lmt_prpnip_by_org_flag '||p_lmt_prpnip_by_org_flag,20);
*/
  --
  process
          (errbuf                     =>l_errbuf,
           retcode                    =>l_retcode,
           p_benefit_action_id        =>p_benefit_action_id ,
           p_effective_date           =>p_effective_date,
           p_mode                     =>p_mode,
           p_derivable_factors        =>p_derivable_factors,
           p_validate                 =>p_validate,
           p_person_id                =>p_person_id,
           p_person_type_id           =>p_person_type_id,
           p_pgm_id                   =>p_pgm_id,
           p_business_group_id        =>p_business_group_id,
           p_pl_id                    =>p_pl_id,
           p_popl_enrt_typ_cycl_id    =>p_popl_enrt_typ_cycl_id,
           p_lf_evt_ocrd_dt           =>p_lf_evt_ocrd_dt,
           p_no_programs              =>p_no_programs,
           p_no_plans                 =>p_no_plans,
           p_comp_selection_rule_id   =>p_comp_selection_rule_id,
           p_person_selection_rule_id =>p_person_selection_rule_id,
           p_ler_id                   =>p_ler_id,
           p_organization_id          =>p_organization_id,
           p_benfts_grp_id            =>p_benfts_grp_id,
           p_location_id              =>p_location_id,
           p_pstl_zip_rng_id          =>p_pstl_zip_rng_id,
           p_rptg_grp_id              =>p_rptg_grp_id,
           p_pl_typ_id                =>p_pl_typ_id,
           p_opt_id                   =>p_opt_id,
           p_eligy_prfl_id            =>p_eligy_prfl_id,
           p_vrbl_rt_prfl_id          =>p_vrbl_rt_prfl_id,
           p_legal_entity_id          =>p_legal_entity_id,
           p_payroll_id               =>p_payroll_id,
           p_commit_data              =>p_commit_data,
           p_audit_log_flag           =>p_audit_log_flag,
           p_lmt_prpnip_by_org_flag   =>p_lmt_prpnip_by_org_flag,
           p_cbr_tmprl_evt_flag       =>p_cbr_tmprl_evt_flag ,
           -- passed these gsp parameters
           -- version 115.329
           p_org_heirarchy_id	      =>p_org_heirarchy_id,
           p_org_starting_node_id     =>p_org_starting_node_id,
           p_grade_ladder_id	      =>p_grade_ladder_id,
           p_asg_events_to_all_sel_dt =>p_asg_events_to_all_sel_dt,
           p_rate_id		      =>p_rate_id,
           p_per_sel_dt_cd	      =>p_per_sel_dt_cd,
           p_per_sel_dt_from	      => fnd_date.canonical_to_date(p_per_sel_dt_from),
           p_per_sel_dt_to	      => fnd_date.canonical_to_date(p_per_sel_dt_to),
           p_year_from		      =>p_year_from,
           p_year_to		      =>p_year_to,
           p_cagr_id		      =>p_cagr_id,
           p_qual_type		      =>p_qual_type,
           p_qual_status	      =>p_qual_status,
           -- 2940151
           p_per_sel_freq_cd      =>p_per_sel_freq_cd,
	   p_concat_segs 	      =>p_concat_segs,
           p_gsp_eval_elig_flag       => 'Y',      /* GSP Rate Sync */
           p_lf_evt_oper_cd           => 'PROG'    /* GSP Rate Sync */
           -- end 2940151
           );
    --
end grade_step_process;
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
  )is
  --
  l_bin  binary_integer ;
  l_retcode number;
  l_errbuf  varchar2(1000);

begin
  --
--  hr_utility.trace_on(null, 'GSPRS');
  g_debug := hr_utility.debug_enabled;
  --
  process
          (errbuf                     => l_errbuf,
           retcode                    => l_retcode,
           p_benefit_action_id        => p_benefit_action_id,
           p_effective_date           => p_effective_date,
           p_mode                     => p_mode,
           p_derivable_factors        => p_derivable_factors,
           p_validate                 => p_validate,
           p_person_id                => p_person_id,
           p_pgm_id                   => p_pgm_id,
           p_business_group_id        => p_business_group_id,
           p_person_type_id           => p_person_type_id,
           p_comp_selection_rule_id   => p_comp_selection_rule_id,
           p_person_selection_rule_id => p_person_selection_rule_id,
           p_organization_id          => p_organization_id,
           p_benfts_grp_id            => p_benfts_grp_id,
           p_location_id              => p_location_id,
           p_pstl_zip_rng_id          => p_pstl_zip_rng_id,
           p_rptg_grp_id              => p_rptg_grp_id,
           p_legal_entity_id          => p_legal_entity_id,
           p_payroll_id               => p_payroll_id,
           p_org_heirarchy_id	      => p_org_heirarchy_id,
           p_org_starting_node_id     => p_org_starting_node_id,
           p_grade_ladder_id	      => p_grade_ladder_id,
           p_rate_id		      => p_rate_id,
           p_per_sel_dt_cd	      => p_per_sel_dt_cd,
           p_per_sel_dt_from	      => p_per_sel_dt_from,
           p_per_sel_dt_to	      => p_per_sel_dt_to,
           p_per_sel_freq_cd          => p_per_sel_freq_cd,
           p_year_from		      => p_year_from,
           p_year_to		      => p_year_to,
           p_cagr_id		      => p_cagr_id,
           p_qual_type		      => p_qual_type,
           p_qual_status	      => p_qual_status,
	   p_concat_segs 	      => p_concat_segs,
           p_commit_data              => p_commit_data,
           p_audit_log_flag           => p_audit_log_flag,
           p_lmt_prpnip_by_org_flag   => p_lmt_prpnip_by_org_flag,
           p_asg_events_to_all_sel_dt => p_effective_date, -- Pass Effective Date as PTNL Life Event Occurred Date
           p_gsp_eval_elig_flag       => p_gsp_eval_elig_flag,
           p_lf_evt_oper_cd           => 'SYNC'    -- Life Event Operation code for Rate Synchronization
           );
    hr_utility.trace_off;
    --
end grade_step_rate_sync_process;
--
-- wrapper for procedure process - ABSENCES
--
procedure abse_process
          (errbuf                     out nocopy varchar2,
           retcode                    out nocopy number,
           p_benefit_action_id        in number   default null,
           p_effective_date           in varchar2,
           p_mode                     in varchar2 default 'M',
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
           p_cbr_tmprl_evt_flag       in varchar2 default 'N') is
  --
  l_retcode number;
  l_errbuf  varchar2(1000);
begin
  --
  g_debug := hr_utility.debug_enabled;
  --
  process
          (errbuf                     =>l_errbuf,
           retcode                    =>l_retcode,
           p_benefit_action_id        =>p_benefit_action_id ,
           p_effective_date           =>p_effective_date,
           p_mode                     =>p_mode,
           p_derivable_factors        =>p_derivable_factors,
           p_validate                 =>p_validate,
           p_person_id                =>p_person_id,
           p_person_type_id           =>p_person_type_id,
           p_pgm_id                   =>p_pgm_id,
           p_business_group_id        =>p_business_group_id,
           p_pl_id                    =>p_pl_id,
           p_popl_enrt_typ_cycl_id    =>p_popl_enrt_typ_cycl_id,
           p_lf_evt_ocrd_dt           =>p_lf_evt_ocrd_dt,
           p_no_programs              =>p_no_programs,
           p_no_plans                 =>p_no_plans,
           p_comp_selection_rule_id   =>p_comp_selection_rule_id,
           p_person_selection_rule_id =>p_person_selection_rule_id,
           p_ler_id                   =>p_ler_id,
           p_organization_id          =>p_organization_id,
           p_benfts_grp_id            =>p_benfts_grp_id,
           p_location_id              =>p_location_id,
           p_pstl_zip_rng_id          =>p_pstl_zip_rng_id,
           p_rptg_grp_id              =>p_rptg_grp_id,
           p_pl_typ_id                =>p_pl_typ_id,
           p_opt_id                   =>p_opt_id,
           p_eligy_prfl_id            =>p_eligy_prfl_id,
           p_vrbl_rt_prfl_id          =>p_vrbl_rt_prfl_id,
           p_legal_entity_id          =>p_legal_entity_id,
           p_payroll_id               =>p_payroll_id,
           p_commit_data              =>p_commit_data,
           p_audit_log_flag           =>p_audit_log_flag,
           p_lmt_prpnip_by_org_flag   =>p_lmt_prpnip_by_org_flag,
           p_cbr_tmprl_evt_flag       =>p_cbr_tmprl_evt_flag,
           p_abs_historical_mode      =>p_abs_historical_mode);
    --
end abse_process;
--
-- iRec
-- wrapper for procedure internal_process - iRecruitment
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
           p_offer_assignment_rec     in  per_all_assignments_f%rowtype) ----bug 4621751 irec2
       is
  --
  l_retcode     number;
  l_errbuf      varchar2(1000);
  l_benefit_action_id   number;
  l_old_data_migrator_mode varchar2(1) ;-- irec2

  --
  cursor c_irec_ass_rec is
  select ass.*
    from per_all_assignments_F ass
   where assignment_id = p_assignment_id
     and to_date(p_effective_date,'YYYY/MM/DD HH24:MI:SS') between ass.effective_start_date
                                                               and ass.effective_end_date;

  cursor c_irec_ass_rec_upd is
  select ass.*
    from per_all_assignments_F ass
   where assignment_id = p_assignment_id
     and to_date(p_effective_date,'YYYY/MM/DD HH24:MI:SS') between ass.effective_start_date
                                                               and ass.effective_end_date;

  --
begin
  --
  g_debug := hr_utility.debug_enabled;
  --
  -- Bug 5857493
  if p_audit_log_flag ='Y' then
     ben_benbatch_persons.g_audit_flag := true;
  else
     ben_benbatch_persons.g_audit_flag := false;
  end if;
  --
  -- Populate global assignment record of the applicant being processed
  -- by BENMNGLE in mode I into g_irec_ass_rec
  -- irec2 : 1.  copy c_irec_ass_rec to g_irec_old_ass_rec
  --         2.  update per_all_assignments_F with p_offer_assignment_rec
  open c_irec_ass_rec;
    --
    fetch c_irec_ass_rec into ben_manage_life_events.g_irec_old_ass_rec; -- irec2
    if c_irec_ass_rec%notfound then
      --
      close c_irec_ass_rec;
      fnd_message.set_name('BEN','BEN_94027_NO_ACT_APL_ASS_FOUND');
      fnd_message.raise_error;
      --
    else -- begin irec2
     begin
     l_old_data_migrator_mode := hr_general.g_data_migrator_mode ;
     hr_general.g_data_migrator_mode := 'Y' ;
     -- update starts
     update per_all_assignments_F
        set
  BUSINESS_GROUP_ID              =   p_offer_assignment_rec.BUSINESS_GROUP_ID
 ,RECRUITER_ID                   =   p_offer_assignment_rec.RECRUITER_ID
 ,GRADE_ID                       =   p_offer_assignment_rec.GRADE_ID
 ,POSITION_ID                    =   p_offer_assignment_rec.POSITION_ID
 ,JOB_ID                         =   p_offer_assignment_rec.JOB_ID
 ,ASSIGNMENT_STATUS_TYPE_ID      =   p_offer_assignment_rec.ASSIGNMENT_STATUS_TYPE_ID
 ,PAYROLL_ID                     =   p_offer_assignment_rec.PAYROLL_ID
 ,LOCATION_ID                    =   p_offer_assignment_rec.LOCATION_ID
 ,PERSON_REFERRED_BY_ID          =   p_offer_assignment_rec.PERSON_REFERRED_BY_ID
 ,SUPERVISOR_ID                  =   p_offer_assignment_rec.SUPERVISOR_ID
 ,SPECIAL_CEILING_STEP_ID        =   p_offer_assignment_rec.SPECIAL_CEILING_STEP_ID
 ,PERSON_ID                      =   p_offer_assignment_rec.PERSON_ID
 ,RECRUITMENT_ACTIVITY_ID        =   p_offer_assignment_rec.RECRUITMENT_ACTIVITY_ID
 ,SOURCE_ORGANIZATION_ID         =   p_offer_assignment_rec.SOURCE_ORGANIZATION_ID
 ,ORGANIZATION_ID                =   p_offer_assignment_rec.ORGANIZATION_ID
 ,PEOPLE_GROUP_ID                =   p_offer_assignment_rec.PEOPLE_GROUP_ID
 ,SOFT_CODING_KEYFLEX_ID         =   p_offer_assignment_rec.SOFT_CODING_KEYFLEX_ID
 ,VACANCY_ID                     =   p_offer_assignment_rec.VACANCY_ID
 ,PAY_BASIS_ID                   =   p_offer_assignment_rec.PAY_BASIS_ID
 ,ASSIGNMENT_SEQUENCE		 =   p_offer_assignment_rec.ASSIGNMENT_SEQUENCE
 ,APPLICATION_ID                 =   p_offer_assignment_rec.APPLICATION_ID
 ,ASSIGNMENT_NUMBER              =   p_offer_assignment_rec.ASSIGNMENT_NUMBER
 ,CHANGE_REASON                  =   p_offer_assignment_rec.CHANGE_REASON
 ,COMMENT_ID                     =   p_offer_assignment_rec.COMMENT_ID
 ,DATE_PROBATION_END             =   p_offer_assignment_rec.DATE_PROBATION_END
 ,DEFAULT_CODE_COMB_ID           =   p_offer_assignment_rec.DEFAULT_CODE_COMB_ID
 ,EMPLOYMENT_CATEGORY            =   p_offer_assignment_rec.EMPLOYMENT_CATEGORY
 ,FREQUENCY                      =   p_offer_assignment_rec.FREQUENCY
 ,INTERNAL_ADDRESS_LINE          =   p_offer_assignment_rec.INTERNAL_ADDRESS_LINE
 ,MANAGER_FLAG                   =   p_offer_assignment_rec.MANAGER_FLAG
 ,NORMAL_HOURS                   =   p_offer_assignment_rec.NORMAL_HOURS
 ,PERF_REVIEW_PERIOD             =   p_offer_assignment_rec.PERF_REVIEW_PERIOD
 ,PERF_REVIEW_PERIOD_FREQUENCY   =   p_offer_assignment_rec.PERF_REVIEW_PERIOD_FREQUENCY
 ,PERIOD_OF_SERVICE_ID           =   p_offer_assignment_rec.PERIOD_OF_SERVICE_ID
 ,PROBATION_PERIOD               =   p_offer_assignment_rec.PROBATION_PERIOD
 ,PROBATION_UNIT                 =   p_offer_assignment_rec.PROBATION_UNIT
 ,SAL_REVIEW_PERIOD              =   p_offer_assignment_rec.SAL_REVIEW_PERIOD
 ,SAL_REVIEW_PERIOD_FREQUENCY    =   p_offer_assignment_rec.SAL_REVIEW_PERIOD_FREQUENCY
 ,SET_OF_BOOKS_ID                =   p_offer_assignment_rec.SET_OF_BOOKS_ID
 ,SOURCE_TYPE                    =   p_offer_assignment_rec.SOURCE_TYPE
 ,TIME_NORMAL_FINISH             =   p_offer_assignment_rec.TIME_NORMAL_FINISH
 ,TIME_NORMAL_START              =   p_offer_assignment_rec.TIME_NORMAL_START
 ,REQUEST_ID                     =   p_offer_assignment_rec.REQUEST_ID
 ,PROGRAM_APPLICATION_ID         =   p_offer_assignment_rec.PROGRAM_APPLICATION_ID
 ,PROGRAM_ID                     =   p_offer_assignment_rec.PROGRAM_ID
 ,PROGRAM_UPDATE_DATE            =   p_offer_assignment_rec.PROGRAM_UPDATE_DATE
 ,ASS_ATTRIBUTE_CATEGORY         =   p_offer_assignment_rec.ASS_ATTRIBUTE_CATEGORY
 ,ASS_ATTRIBUTE1                 =   p_offer_assignment_rec.ASS_ATTRIBUTE1
 ,ASS_ATTRIBUTE2                 =   p_offer_assignment_rec.ASS_ATTRIBUTE2
 ,ASS_ATTRIBUTE3                 =   p_offer_assignment_rec.ASS_ATTRIBUTE3
 ,ASS_ATTRIBUTE4                 =   p_offer_assignment_rec.ASS_ATTRIBUTE4
 ,ASS_ATTRIBUTE5                 =   p_offer_assignment_rec.ASS_ATTRIBUTE5
 ,ASS_ATTRIBUTE6                 =   p_offer_assignment_rec.ASS_ATTRIBUTE6
 ,ASS_ATTRIBUTE7                 =   p_offer_assignment_rec.ASS_ATTRIBUTE7
 ,ASS_ATTRIBUTE8                 =   p_offer_assignment_rec.ASS_ATTRIBUTE8
 ,ASS_ATTRIBUTE9                 =   p_offer_assignment_rec.ASS_ATTRIBUTE9
 ,ASS_ATTRIBUTE10                =   p_offer_assignment_rec.ASS_ATTRIBUTE10
 ,ASS_ATTRIBUTE11                =   p_offer_assignment_rec.ASS_ATTRIBUTE11
 ,ASS_ATTRIBUTE12                =   p_offer_assignment_rec.ASS_ATTRIBUTE12
 ,ASS_ATTRIBUTE13                =   p_offer_assignment_rec.ASS_ATTRIBUTE13
 ,ASS_ATTRIBUTE14                =   p_offer_assignment_rec.ASS_ATTRIBUTE14
 ,ASS_ATTRIBUTE15                =   p_offer_assignment_rec.ASS_ATTRIBUTE15
 ,ASS_ATTRIBUTE16                =   p_offer_assignment_rec.ASS_ATTRIBUTE16
 ,ASS_ATTRIBUTE17                =   p_offer_assignment_rec.ASS_ATTRIBUTE17
 ,ASS_ATTRIBUTE18                =   p_offer_assignment_rec.ASS_ATTRIBUTE18
 ,ASS_ATTRIBUTE19                =   p_offer_assignment_rec.ASS_ATTRIBUTE19
 ,ASS_ATTRIBUTE20                =   p_offer_assignment_rec.ASS_ATTRIBUTE20
 ,ASS_ATTRIBUTE21                =   p_offer_assignment_rec.ASS_ATTRIBUTE21
 ,ASS_ATTRIBUTE22                =   p_offer_assignment_rec.ASS_ATTRIBUTE22
 ,ASS_ATTRIBUTE23                =   p_offer_assignment_rec.ASS_ATTRIBUTE23
 ,ASS_ATTRIBUTE24                =   p_offer_assignment_rec.ASS_ATTRIBUTE24
 ,ASS_ATTRIBUTE25                =   p_offer_assignment_rec.ASS_ATTRIBUTE25
 ,ASS_ATTRIBUTE26                =   p_offer_assignment_rec.ASS_ATTRIBUTE26
 ,ASS_ATTRIBUTE27                =   p_offer_assignment_rec.ASS_ATTRIBUTE27
 ,ASS_ATTRIBUTE28                =   p_offer_assignment_rec.ASS_ATTRIBUTE28
 ,ASS_ATTRIBUTE29                =   p_offer_assignment_rec.ASS_ATTRIBUTE29
 ,ASS_ATTRIBUTE30                =   p_offer_assignment_rec.ASS_ATTRIBUTE30
 ,TITLE                          =   p_offer_assignment_rec.TITLE
 ,OBJECT_VERSION_NUMBER          =   p_offer_assignment_rec.OBJECT_VERSION_NUMBER
 ,BARGAINING_UNIT_CODE           =   p_offer_assignment_rec.BARGAINING_UNIT_CODE
 ,LABOUR_UNION_MEMBER_FLAG       =   p_offer_assignment_rec.LABOUR_UNION_MEMBER_FLAG
 ,HOURLY_SALARIED_CODE           =   p_offer_assignment_rec.HOURLY_SALARIED_CODE
 ,CONTRACT_ID                    =   p_offer_assignment_rec.CONTRACT_ID
 ,COLLECTIVE_AGREEMENT_ID        =   p_offer_assignment_rec.COLLECTIVE_AGREEMENT_ID
 ,CAGR_ID_FLEX_NUM               =   p_offer_assignment_rec.CAGR_ID_FLEX_NUM
 ,CAGR_GRADE_DEF_ID              =   p_offer_assignment_rec.CAGR_GRADE_DEF_ID
 ,ESTABLISHMENT_ID               =   p_offer_assignment_rec.ESTABLISHMENT_ID
 ,NOTICE_PERIOD                  =   p_offer_assignment_rec.NOTICE_PERIOD
 ,NOTICE_PERIOD_UOM              =   p_offer_assignment_rec.NOTICE_PERIOD_UOM
 ,EMPLOYEE_CATEGORY              =   p_offer_assignment_rec.EMPLOYEE_CATEGORY
 ,WORK_AT_HOME                   =   p_offer_assignment_rec.WORK_AT_HOME
 ,JOB_POST_SOURCE_NAME           =   p_offer_assignment_rec.JOB_POST_SOURCE_NAME
 ,POSTING_CONTENT_ID             =   p_offer_assignment_rec.POSTING_CONTENT_ID
 ,PERIOD_OF_PLACEMENT_DATE_START =   p_offer_assignment_rec.PERIOD_OF_PLACEMENT_DATE_START
 ,VENDOR_ID                      =   p_offer_assignment_rec.VENDOR_ID
 ,VENDOR_EMPLOYEE_NUMBER         =   p_offer_assignment_rec.VENDOR_EMPLOYEE_NUMBER
 ,VENDOR_ASSIGNMENT_NUMBER       =   p_offer_assignment_rec.VENDOR_ASSIGNMENT_NUMBER
 ,ASSIGNMENT_CATEGORY            =   p_offer_assignment_rec.ASSIGNMENT_CATEGORY
 ,PROJECT_TITLE                  =   p_offer_assignment_rec.PROJECT_TITLE
 ,APPLICANT_RANK                 =   p_offer_assignment_rec.APPLICANT_RANK
 ,GRADE_LADDER_PGM_ID            =   p_offer_assignment_rec.GRADE_LADDER_PGM_ID
 ,SUPERVISOR_ASSIGNMENT_ID       =   p_offer_assignment_rec.SUPERVISOR_ASSIGNMENT_ID
 ,VENDOR_SITE_ID                 =   p_offer_assignment_rec.VENDOR_SITE_ID
 ,PO_HEADER_ID                   =   p_offer_assignment_rec.PO_HEADER_ID
 ,PO_LINE_ID                     =   p_offer_assignment_rec.PO_LINE_ID
 ,PROJECTED_ASSIGNMENT_END       =   p_offer_assignment_rec.PROJECTED_ASSIGNMENT_END

 where assignment_id = p_assignment_id ;
 -- update ends
 hr_general.g_data_migrator_mode := l_old_data_migrator_mode ;

  -- move updated per_all_assignments_f record to g_irec_ass_rec.
  open c_irec_ass_rec_upd;
  fetch c_irec_ass_rec_upd into g_irec_ass_rec;
  close c_irec_ass_rec_upd;

  -- end irec2
  exception
    when others then
      raise;
  end;

 end if;
    --
  close c_irec_ass_rec;
  --
  --
  internal_process
          (errbuf                     =>l_errbuf,
           retcode                    =>l_retcode,
           p_benefit_action_id        =>l_benefit_action_id ,
           p_effective_date           =>p_effective_date,
           p_mode                     =>p_mode,
           p_derivable_factors        =>p_derivable_factors,
           p_validate                 =>p_validate,
           p_person_id                =>p_person_id,
           p_person_type_id           =>p_person_type_id,
           p_pgm_id                   =>p_pgm_id,
           p_business_group_id        =>p_business_group_id,
           p_pl_id                    =>p_pl_id,
           p_popl_enrt_typ_cycl_id    =>p_popl_enrt_typ_cycl_id,
           p_lf_evt_ocrd_dt           =>p_lf_evt_ocrd_dt,
           p_no_programs              =>p_no_programs,
           p_no_plans                 =>p_no_plans,
           p_comp_selection_rule_id   =>p_comp_selection_rule_id,
           p_person_selection_rule_id =>p_person_selection_rule_id,
           p_ler_id                   =>p_ler_id,
           p_organization_id          =>p_organization_id,
           p_benfts_grp_id            =>p_benfts_grp_id,
           p_location_id              =>p_location_id,
           p_pstl_zip_rng_id          =>p_pstl_zip_rng_id,
           p_rptg_grp_id              =>p_rptg_grp_id,
           p_pl_typ_id                =>p_pl_typ_id,
           p_opt_id                   =>p_opt_id,
           p_eligy_prfl_id            =>p_eligy_prfl_id,
           p_vrbl_rt_prfl_id          =>p_vrbl_rt_prfl_id,
           p_legal_entity_id          =>p_legal_entity_id,
           p_payroll_id               =>p_payroll_id,
           p_commit_data              =>p_commit_data,
           p_audit_log_flag           =>p_audit_log_flag,
           p_lmt_prpnip_by_org_flag   =>p_lmt_prpnip_by_org_flag,
           p_cbr_tmprl_evt_flag       =>p_cbr_tmprl_evt_flag,
           p_abs_historical_mode      =>p_abs_historical_mode
	   );
    --
end irec_process;
--
--
procedure rebuild_heirarchy
          (p_pil_elctbl_chc_popl_id in number ) is
  --
  l_package    varchar2(80) := g_package||'.rebuild_heirarchy' ;
  -- Bug 2574791
  cursor c_pel is
     select pel.pl_id, pil.lf_evt_ocrd_dt, pel.business_group_id
     from ben_pil_elctbl_chc_popl pel
          ,ben_per_in_ler pil
     where pel.per_in_ler_id = pil.per_in_ler_id
       and pel.pil_elctbl_chc_popl_id = p_pil_elctbl_chc_popl_id;
  --
begin
  --
  g_debug := hr_utility.debug_enabled;
  --
  -- Steps
  --
  -- 1. create pel,-1,-1 record for the p_pil_elctbl_chc_popl_id.
  -- 2. create pel,-1,-1 records for
  --    empoyees whose mgr_pel is = to  p_pil_elctbl_chc_popl_id.
  -- 3. Delete all records from hierarchy table of the managers of the
  --    p_pil_elctbl_chc_popl_id and the employees reporting to this
  --    p_pil_elctbl_chc_popl_id.
  -- 4. call the popu_pel_heir to rebuild the table.
  --
  -- 5. When the first direct reportee is added to a new Manager
  --    we need two insert a mgr_pel,0,0 with level 1
  --
 if p_pil_elctbl_chc_popl_id is not null then
  --
  -- Bug 2574791
  open c_pel;
  fetch c_pel into g_rebuild_pl_id, g_rebuild_lf_evt_ocrd_dt, g_rebuild_business_group_id;
  close c_pel;

  if g_debug then
    hr_utility.set_location ('Before Step 1',20);
  end if;
  --
  -- Step 1
  begin
    --
    insert into ben_cwb_hrchy (
       emp_pil_elctbl_chc_popl_id,
       mgr_pil_elctbl_chc_popl_id,
       lvl_num  )
    values (
       p_pil_elctbl_chc_popl_id,
       -1,
       -1 );
    --
    exception when no_data_found then
      --
      null;
      --
    when others then
    --
    null; -- raise ;
    --
  end;
  --
  if g_debug then
    hr_utility.set_location ('After Step 1',20);
    --
    hr_utility.set_location ('Before Step 2 ',20);
  end if;
  --
  --Step 2
  -- Don't insert for the pel,0,0 record since it is
  -- Already handled in Step 1 above.
  --
  declare
    cursor c_emp_repo is
              select
          emp_pil_elctbl_chc_popl_id
       from ben_cwb_hrchy
       where mgr_pil_elctbl_chc_popl_id = p_pil_elctbl_chc_popl_id
       and  lvl_num > 0;
  begin
    --
     for r_emp_repo in c_emp_repo loop
       --
       begin
       -- Bug 2574791
       insert into ben_cwb_hrchy (
          emp_pil_elctbl_chc_popl_id,
          mgr_pil_elctbl_chc_popl_id,
          lvl_num  )  values (r_emp_repo.emp_pil_elctbl_chc_popl_id, -1, -1);
       exception when others then
         null;
       end;
     end loop;
    --
  exception when no_data_found then
      --
      null;
      --
    when others then
    --
    raise ;
    --
  end;
  --
  if g_debug then
    hr_utility.set_location ('After Step 2 ',20);
    --
    hr_utility.set_location ('Before Step 3 ',20);
  end if;
  --
  begin
    --
    --First Delete the Managers in the Hierarchy
    --
    delete from ben_cwb_hrchy
    where emp_pil_elctbl_chc_popl_id = p_pil_elctbl_chc_popl_id
    and lvl_num >= 0;
    --
    -- Now delete the Employees reporting to this manager(if he is a manager).
    --
    delete from ben_cwb_hrchy
    where emp_pil_elctbl_chc_popl_id in (
                select emp_pil_elctbl_chc_popl_id
                from ben_cwb_hrchy
                where mgr_pil_elctbl_chc_popl_id = p_pil_elctbl_chc_popl_id )
    and lvl_num >= 0;
    --
  exception when others then
    --
    raise ;
    --
  end;
  --
  if g_debug then
    hr_utility.set_location ('After  Step 3 ',20);
    --
    hr_utility.set_location ('Before Calling popu_pel_heir',20);
  end if;
  begin
    --
    ben_manage_life_events.popu_pel_heir ;
    --
  exception when others then
    --
    raise ;
    --
  end;
  --
  if g_debug then
    hr_utility.set_location ('Before Step 5',20);
  end if;
  --
  begin
    --
    insert into ben_cwb_hrchy(
       emp_pil_elctbl_chc_popl_id,
       mgr_pil_elctbl_chc_popl_id,
       lvl_num  )
      select
       distinct emp_pil_elctbl_chc_popl_id,
       emp_pil_elctbl_chc_popl_id,
       0
      from ben_cwb_hrchy cwb1
      where emp_pil_elctbl_chc_popl_id =
                   ( select mgr_pil_elctbl_chc_popl_id from ben_cwb_hrchy
                     where emp_pil_elctbl_chc_popl_id = p_pil_elctbl_chc_popl_id
                     and lvl_num = 1 )
      and not exists ( select null from ben_cwb_hrchy cwb2
                     where cwb1.emp_pil_elctbl_chc_popl_id = cwb2.emp_pil_elctbl_chc_popl_id
                     and lvl_num  = 0 ) ;
    --
    exception when no_data_found then
      --
      null;
      --
    when others then
    --
    raise ;
    --
  end;
  --
  -- Bug 2574791
  g_rebuild_pl_id            := null;
  g_rebuild_lf_evt_ocrd_dt   := null;
  g_rebuild_business_group_id := null;
  --
 end if;
  --
  if g_debug then
    hr_utility.set_location ('Afert Step 5',20);
    hr_utility.set_location ('After Calling popu_pel_heir',20);
  end if;
  --
  --
end rebuild_heirarchy ;

--
-- Wrapper for Personnel Action mode

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
           p_cbr_tmprl_evt_flag       in varchar2 default 'N') is
  --
  l_retcode number;
  l_errbuf  varchar2(1000);
  --
begin
  --
  g_debug := hr_utility.debug_enabled;
  --
  process
          (errbuf                     =>l_errbuf,
           retcode                    =>l_retcode,
           p_benefit_action_id        => null,
           p_effective_date           =>p_effective_date,
           p_mode                     =>p_mode,
           p_derivable_factors        =>'ASC',
           p_validate                 =>p_validate,
           p_person_id                =>p_person_id,
           p_person_type_id           =>p_person_type_id,
           p_pgm_id                   =>p_pgm_id,
           p_business_group_id        =>p_business_group_id,
           p_pl_id                    =>p_pl_id,
           p_popl_enrt_typ_cycl_id    =>p_popl_enrt_typ_cycl_id,
           p_lf_evt_ocrd_dt           =>p_lf_evt_ocrd_dt,
           p_no_programs              =>p_no_programs,
           p_no_plans                 =>p_no_plans,
           p_comp_selection_rule_id   =>p_comp_selection_rule_id,
           p_person_selection_rule_id =>p_person_selection_rule_id,
           p_ler_id                   =>p_ler_id,
           p_organization_id          =>p_organization_id,
           p_benfts_grp_id            =>p_benfts_grp_id,
           p_location_id              =>p_location_id,
           p_pstl_zip_rng_id          =>p_pstl_zip_rng_id,
           p_rptg_grp_id              =>p_rptg_grp_id,
           p_pl_typ_id                =>p_pl_typ_id,
           p_opt_id                   =>p_opt_id,
           p_eligy_prfl_id            =>p_eligy_prfl_id,
           p_vrbl_rt_prfl_id          =>p_vrbl_rt_prfl_id,
           p_legal_entity_id          =>p_legal_entity_id,
           p_payroll_id               =>p_payroll_id,
           p_commit_data              =>p_commit_data,
           p_audit_log_flag           =>p_audit_log_flag,
           p_lmt_prpnip_by_org_flag   =>p_lmt_prpnip_by_org_flag,
           p_cbr_tmprl_evt_flag       =>p_cbr_tmprl_evt_flag );
end;
----
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
           p_cbr_tmprl_evt_flag       in varchar2 default 'N') is
  --
  l_retcode number;
  l_errbuf  varchar2(1000);
  --
begin
  --
  g_debug := hr_utility.debug_enabled;
  --
  process
          (errbuf                     =>l_errbuf,
           retcode                    =>l_retcode,
           p_benefit_action_id        => null,
           p_effective_date           =>p_effective_date,
           p_mode                     =>p_mode,
           p_derivable_factors        =>'NONE',
           p_validate                 =>p_validate,
           p_person_id                =>p_person_id,
           p_person_type_id           =>p_person_type_id,
           p_pgm_id                   =>p_pgm_id,
           p_business_group_id        =>p_business_group_id,
           p_pl_id                    =>p_pl_id,
           p_popl_enrt_typ_cycl_id    =>p_popl_enrt_typ_cycl_id,
           p_lf_evt_ocrd_dt           =>p_lf_evt_ocrd_dt,
           p_no_programs              =>p_no_programs,
           p_no_plans                 =>p_no_plans,
           p_comp_selection_rule_id   =>p_comp_selection_rule_id,
           p_person_selection_rule_id =>p_person_selection_rule_id,
           p_ler_id                   =>p_ler_id,
           p_organization_id          =>p_organization_id,
           p_benfts_grp_id            =>p_benfts_grp_id,
           p_location_id              =>p_location_id,
           p_pstl_zip_rng_id          =>p_pstl_zip_rng_id,
           p_rptg_grp_id              =>p_rptg_grp_id,
           p_pl_typ_id                =>p_pl_typ_id,
           p_opt_id                   =>p_opt_id,
           p_eligy_prfl_id            =>p_eligy_prfl_id,
           p_vrbl_rt_prfl_id          =>p_vrbl_rt_prfl_id,
           p_legal_entity_id          =>p_legal_entity_id,
           p_payroll_id               =>p_payroll_id,
           p_commit_data              =>p_commit_data,
           p_audit_log_flag           =>p_audit_log_flag,
           p_lmt_prpnip_by_org_flag   =>p_lmt_prpnip_by_org_flag,
           p_cbr_tmprl_evt_flag       =>p_cbr_tmprl_evt_flag );
    --
  end;

----
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
      ,p_year_from                in     number   default null -- business rule year from
      ,p_year_to                  in     number   default null -- business rule year to
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
      ,p_cwb_person_type          in     varchar2 default null
      )
    is
      --
      l_package                varchar2(80);
      --
      l_effective_date         date;
      l_lf_evt_ocrd_dt         date;
      l_asg_events_to_all_sel_dt date;
      l_per_sel_dt_from          date;
      l_per_sel_dt_to            date;
      l_commit                 number;
      l_gsp_eval_elig_flag     varchar2(30);
      --
          -- Bug:2237993 CWB
          --
          l_person_id      per_all_people_f.person_id%type;
          cursor c_person_info is
           select person_id
           from ben_person_actions
           where benefit_action_id = p_benefit_action_id
                 and action_status_cd = 'P';

          cursor c_pln is
          select pl.trk_inelig_per_flag
            from ben_pl_f pl
           where pl.pl_id = p_pl_id
             and l_effective_date between pl.effective_start_date and
                 pl.effective_end_date;
          --
      cursor c_popl_enrt_typ_cycl is
        select ler.ler_id, pet.popl_enrt_typ_cycl_id
        from   ben_popl_enrt_typ_cycl_f pet,
           ben_enrt_perd enp,
           ben_ler_f ler
        where  enp.business_group_id  = p_business_group_id
        -- PB : 5422 :
        and    enp.asnd_lf_evt_dt  = l_lf_evt_ocrd_dt
        -- and    enp.enrt_perd_id = p_popl_enrt_typ_cycl_id
        and    enp.popl_enrt_typ_cycl_id = pet.popl_enrt_typ_cycl_id
        and    pet.business_group_id  = enp.business_group_id
        and    l_effective_date
           between pet.effective_start_date
           and     pet.effective_end_date
        -- CWB Changes
        and    ((ler.typ_cd = 'SCHEDD'||pet.enrt_typ_cycl_cd and p_mode = 'C')  or
            (ler.typ_cd = 'COMP' and p_mode = 'W')
           )
        -- CWB Changes end
        and    ler.business_group_id  = pet.business_group_id
        and    l_effective_date
           between ler.effective_start_date
           and     ler.effective_end_date
        -- CWB Change
        and    ((p_mode = 'W' and ler.ler_id = enp.ler_id
             and pet.pl_id = p_pl_id) or p_mode <> 'W');
      -- 2940151
      -- Grade Step- cursor for fetching people group kff structure
      --
      l_popl_enrt_typ_cycl_id number ;
      --
      cursor c_people_group_structure is
      select people_group_structure
      from per_business_groups
      where business_group_id = p_business_group_id;
      --
      l_id_flex_num per_business_groups.people_group_structure%TYPE;
      --
      --
      l_ler_override_id        number;
          l_trk_inelig_per_flag    ben_pl_f.trk_inelig_per_flag%type;
      l_request_id             number;
      l_object_version_number  ben_benefit_actions.object_version_number%type;
      l_benefit_action_id      ben_benefit_actions.benefit_action_id%type;
      l_chunk_size             number;
      l_threads                number;
      l_max_errors             number;
      l_num_ranges             number := 0;
      l_num_persons            number := 0;
      l_person_action_id       number;
      l_range_id               number;
      l_ler_rec                benutils.g_ler;
      l_retcode                number;
      l_errbuf                 varchar2(1000);
      l_no_one_to_process      exception;          -- Bug 3870204
      -- iRec
      l_ler_id                 number;
      --
      --
    begin
      --
        g_debug := hr_utility.debug_enabled;
        l_package := g_package||'.internal_process';
        if g_debug then
          hr_utility.set_location ('Entering '||l_package,10);
          hr_utility.set_location ('p_mode : '||p_mode,5);
        end if;
        --
        g_derivable_factors := p_derivable_factors;
      --
      -- Convert varchar2 dates to real dates
      -- 1) First remove time component
      -- 2) Next convert format
      /*
      l_effective_date := to_date(p_effective_date,'YYYY/MM/DD HH24:MI:SS');
      l_effective_date := to_date(to_char(trunc(l_effective_date),'DD/MM/RRRR'),'DD/MM/RRRR');
      l_lf_evt_ocrd_dt := to_date(p_lf_evt_ocrd_dt,'YYYY/MM/DD HH24:MI:SS');
      l_lf_evt_ocrd_dt := to_date(to_char(trunc(l_lf_evt_ocrd_dt),'DD/MM/RRRR'),'DD/MM/RRRR');
      */
      l_effective_date := trunc(fnd_date.canonical_to_date(p_effective_date));
      l_lf_evt_ocrd_dt := trunc(fnd_date.canonical_to_date(p_lf_evt_ocrd_dt));
          --
          if p_asg_events_to_all_sel_dt is not null then
             /*
             l_asg_events_to_all_sel_dt := to_date(p_asg_events_to_all_sel_dt,'YYYY/MM/DD HH24:MI:SS');
             l_asg_events_to_all_sel_dt := to_date(to_char(trunc(l_asg_events_to_all_sel_dt),'DD/MM/RRRR'),'DD/MM/RRRR');
             */
             l_asg_events_to_all_sel_dt := trunc(fnd_date.canonical_to_date(p_asg_events_to_all_sel_dt));
             --
          end if;
          --
          if p_per_sel_dt_from is not null then
             --
             /*
             l_per_sel_dt_from := to_date(p_per_sel_dt_from,'YYYY/MM/DD HH24:MI:SS');
             l_per_sel_dt_from := to_date(to_char(trunc(l_per_sel_dt_from),'DD/MM/RRRR'),'DD/MM/RRRR');
             */
             l_per_sel_dt_from :=trunc(p_per_sel_dt_from);
             --
          end if;
          --
          if p_per_sel_dt_to is not null then
             --
             /*
             l_per_sel_dt_to := to_date(p_per_sel_dt_to,'YYYY/MM/DD HH24:MI:SS');
             l_per_sel_dt_to := to_date(to_char(trunc(l_per_sel_dt_to),'DD/MM/RRRR'),'DD/MM/RRRR');
             */
             l_per_sel_dt_to := trunc(p_per_sel_dt_to);
             --
          end if;
      --
      -- Put row in fnd_sessions
      --
      dt_fndate.change_ses_date
        (p_ses_date => nvl(l_lf_evt_ocrd_dt,l_effective_date),
         p_commit   => l_commit);
      --
      -- Log start time of process
      --
          ben_manage_life_events.init_bft_statistics
            (p_business_group_id => p_business_group_id
            );
      -- GSP Rate Sync
      if p_mode = 'G' and p_gsp_eval_elig_flag is null
      then
        --
	if p_lf_evt_oper_cd = 'SYNC'
	then
	  l_gsp_eval_elig_flag := 'N';
	else
	  l_gsp_eval_elig_flag := 'Y';
	end if;
	--
      else
        --
	l_gsp_eval_elig_flag := p_gsp_eval_elig_flag;
	--
      end if;
      --
      --
      -- Check that business rules that apply to BENMNGLE are being adhered to.
      --
      check_business_rules
        (p_business_group_id        => p_business_group_id,
         p_derivable_factors        => p_derivable_factors,
         p_validate                 => p_validate,
         p_no_programs              => p_no_programs,
         p_no_plans                 => p_no_plans,
         p_mode                     => p_mode,
         p_effective_date           => l_effective_date,
         p_person_id                => p_person_id,
         p_person_selection_rule_id => p_person_selection_rule_id,
         p_person_type_id           => p_person_type_id,
         p_pgm_id                   => p_pgm_id,
         p_pl_id                    => p_pl_id,
         p_ler_id                   => p_ler_id,
         p_pl_typ_id                => p_pl_typ_id,
         p_opt_id                   => p_opt_id,
         p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt,
             -- Grade/Step progression
             p_org_heirarchy_id         => p_org_heirarchy_id,
             p_org_starting_node_id     => p_org_starting_node_id,
             p_asg_events_to_all_sel_dt => l_asg_events_to_all_sel_dt,
             p_per_sel_dt_cd            => p_per_sel_dt_cd,
             p_per_sel_dt_from          => l_per_sel_dt_from,
             p_per_sel_dt_to            => l_per_sel_dt_to,
             p_year_from                => p_year_from,
             p_year_to                  => p_year_to,
             p_qual_type                => p_qual_type,
             p_qual_status              => p_qual_status,
             p_lf_evt_oper_cd           => p_lf_evt_oper_cd    /* GSP Rate Sync */
            );

         -- p_popl_enrt_typ_cycl_id    => p_popl_enrt_typ_cycl_id);
        if g_debug then
        hr_utility.set_location (l_package||' Check business rules',20);
        end if;
      --
      -- Get ler_id for Unrestricted Mode and store it in globle variable so that procedures down the road can
      -- access it
       --
       benutils.get_ler
          (p_business_group_id     => p_business_group_id,
           p_typ_cd                => 'SCHEDDU',
           p_effective_date        => l_effective_date,
           p_rec                   => l_ler_rec);
        --
        g_ler_id := l_ler_rec.ler_id;
       --
     -- iRec
      if p_mode = 'I' then
        --
        -- Set G_LER_ID to iRecruitment LER_ID for subsequent use in ben_evaluate_ptnl_lf_evt
         --
        benutils.get_ler (p_business_group_id      => p_business_group_id,
                          p_typ_cd                 => 'IREC',
                          p_effective_date         => l_effective_date,
                          p_rec                    => l_ler_rec
                         );
        --
       g_ler_id := l_ler_rec.ler_id;
        --
      end if;
      -- iRec
      --
      -- Get override ler_id for Scheduled mode.
      --
      -- CWB Changes
      --
      if p_mode in  ('C', 'W') and
        p_lf_evt_ocrd_dt is not null then
        -- PB : 5422 :
        -- p_popl_enrt_typ_cycl_id is not null then
        --
        open c_popl_enrt_typ_cycl;
          --
          fetch c_popl_enrt_typ_cycl into l_ler_override_id, l_popl_enrt_typ_cycl_id;
          if c_popl_enrt_typ_cycl%notfound then
        --
        close c_popl_enrt_typ_cycl;
        fnd_message.set_name('BEN','BEN_91668_NO_FIND_POPL_ENRT');
        fnd_message.raise_error;
        --
          end if;
          --
        close c_popl_enrt_typ_cycl;

          if g_debug then
          hr_utility.set_location (l_popl_enrt_typ_cycl_id || ' Done c_popl_enrt_typ_cycl ',30);
          hr_utility.set_location (p_popl_enrt_typ_cycl_id || ' Done c_popl_enrt_typ_cycl ',30);
          end if;
        --
      end if;
      --
      -- Get ler id for unrestricted
      --
      if p_mode in ('U','D') then
        --
        benutils.get_ler
          (p_business_group_id     => p_business_group_id,
           p_typ_cd                => 'SCHEDDU',
           p_effective_date        => l_effective_date,
           p_rec                   => l_ler_rec);
        --
        l_ler_override_id := l_ler_rec.ler_id;
	--
          if g_debug then
          hr_utility.set_location (l_package||' benutils.get_ler ',30);
          end if;
        --
      end if;
/*
          --
          -- Get ler id for Grade/Step
          --
          if p_mode = 'G' then
            --
            benutils.get_ler
              (p_business_group_id     => p_business_group_id,
               p_typ_cd                => 'GSP',
               p_effective_date        => l_effective_date,
               p_rec                   => l_ler_rec);
            --
            l_ler_override_id := l_ler_rec.ler_id;
            --
            if g_debug then
              hr_utility.set_location (l_package||' benutils.get_ler ',31);
            end if;
          end if;
*/
      --
      -- Get parameters so we know how many slaves to start and what size the
      -- chunk size we will be processing is.
      --
        if g_debug then
        hr_utility.set_location (l_package||' get_parameter',20);
        end if;
       /* Start: CWB Thread Num Enhancement */
        if(p_mode = 'W') then
          benutils.get_parameter(p_business_group_id => p_business_group_id,
                                 p_batch_exe_cd      => 'BENGCMOD',
                                 p_threads           => l_threads,
                                 p_chunk_size        => l_chunk_size,
                                 p_max_errors        => l_max_errors);
        else
          benutils.get_parameter(p_business_group_id => p_business_group_id,
		  	         p_batch_exe_cd      => 'BENMNGLE',
		                 p_threads           => l_threads,
		                 p_chunk_size        => l_chunk_size,
		                 p_max_errors        => l_max_errors);
        end if;
       /* End: CWB Thread Num Enhancement */
        if g_debug then
        hr_utility.set_location (l_package||' Done get pm ',30);
        --
        hr_utility.set_location('Num Threads = '||l_threads,10);
        hr_utility.set_location('Chunk Size = '||l_chunk_size,10);
        hr_utility.set_location('Max Errors = '||l_max_errors,10);
        --
        end if;
      --
      benutils.g_benefit_action_id := l_benefit_action_id;  -- Bug 3870204
      --
      -- Create benefit actions parameters in the benefit action table.
      -- Do not create if a benefit action already exists, in other words
      -- we are doing a restart.
      --
      if p_benefit_action_id is null then
        --
          if g_debug then
          hr_utility.set_location (l_package||' Create BFT ',30);
          end if;
        --
        --
        ben_benefit_actions_api.create_perf_benefit_actions
          (p_validate               => false,
           p_benefit_action_id      => l_benefit_action_id,
           p_process_date           => l_effective_date,
           p_mode_cd                => p_mode,
           p_derivable_factors_flag => p_derivable_factors,
           p_validate_flag          => p_validate,
           p_person_id              => p_person_id,
           p_person_type_id         => p_person_type_id,
           p_pgm_id                 => p_pgm_id,
           p_business_group_id      => p_business_group_id,
           p_pl_id                  => p_pl_id,
           -- PB : 5422 :
           -- No longer needed.
           --  p_popl_enrt_typ_cycl_id  => p_popl_enrt_typ_cycl_id,
           p_no_programs_flag       => p_no_programs,
           p_no_plans_flag          => p_no_plans,
           p_comp_selection_rl      => p_comp_selection_rule_id,
           p_person_selection_rl    => p_person_selection_rule_id,
           p_ler_id                 => p_ler_id,
           p_organization_id        => p_organization_id,
           p_benfts_grp_id          => p_benfts_grp_id,
           p_location_id            => p_location_id,
           p_pstl_zip_rng_id        => p_pstl_zip_rng_id,
           p_rptg_grp_id            => p_rptg_grp_id,
           p_pl_typ_id              => p_pl_typ_id,
           p_opt_id                 => p_opt_id,
           p_eligy_prfl_id          => p_eligy_prfl_id,
           p_vrbl_rt_prfl_id        => p_vrbl_rt_prfl_id,
           p_legal_entity_id        => p_legal_entity_id,
           p_payroll_id             => p_payroll_id,
           p_debug_messages_flag    => p_cbr_tmprl_evt_flag,
           p_audit_log_flag         => p_audit_log_flag,
           --
           -- PB : Healthnet change : Limit comp object selection
           -- based on the org id.
           --
           p_lmt_prpnip_by_org_flag => p_lmt_prpnip_by_org_flag,
               --
               -- GRADE/STEP : Reuse date_from to store l_asg_events_to_all_sel_dt
               -- Later add this column to bft table use proper column
               -- We may need to add other grade/step paramters to this table
               -- for now just reuse.
               --
               p_date_from              => l_asg_events_to_all_sel_dt,
           p_request_id             => fnd_global.conc_request_id,
           p_program_application_id => fnd_global.prog_appl_id,
           p_program_id             => fnd_global.conc_program_id,
           p_program_update_date    => sysdate,
           p_object_version_number  => l_object_version_number,
           p_lf_evt_ocrd_dt         => l_lf_evt_ocrd_dt,
           p_inelg_action_cd        => p_abs_historical_mode,
           p_effective_date         => l_effective_date,
           -- 2940151
           p_org_hierarchy_id         => p_org_heirarchy_id, -- note the spelling for hierarchy
           p_org_starting_node_id     => p_org_starting_node_id,
           p_grade_ladder_id          => p_grade_ladder_id,
           p_asg_events_to_all_sel_dt => p_asg_events_to_all_sel_dt,
           p_rate_id                  => p_rate_id,
           p_per_sel_dt_cd            => p_per_sel_dt_cd,
           p_per_sel_dt_from          => p_per_sel_dt_from,
           p_per_sel_dt_to            => p_per_sel_dt_to,
           p_year_from                => p_year_from,
           p_year_to                  => p_year_to,
           p_cagr_id                  => p_cagr_id,
           p_qual_type                => p_qual_type,
           p_qual_status              => p_qual_status,
           p_per_sel_freq_cd          => p_per_sel_freq_cd ,
           p_concat_segs 	      => p_concat_segs
           -- end 2940151
           );
          --
          benutils.g_benefit_action_id := l_benefit_action_id;  -- Bug 3870204
          --
          if g_debug then
          hr_utility.set_location (l_package||' Dn Create BFT ',20);
          end if;
        --
        -- This must be committed to the database
        --
        if p_commit_data = 'Y' then
          --
          commit;
          --
        end if;
        --
        -- Now lets create person actions for all the people we are going to
        -- process in the BENMNGLE run.
            --
            -- ABSENCES mode M added. Added GRADE/STEP mode
        --
        if p_mode in ('L','M', 'G', 'I', 'A') then
          --
            -- iRec
	    if p_mode = 'I' then
	      --
	      l_ler_id := g_ler_id;
	      --
	    else
	      --
	      l_ler_id := p_ler_id;
	      --
	    end if;
	    --

            -- 2940151
            -- get the people group kff structure and pass it

            open c_people_group_structure;
            fetch c_people_group_structure into l_id_flex_num;
            close c_people_group_structure;

            if g_debug then
            hr_utility.set_location (l_package||' Create L PER ACTs ',20);
            hr_utility.set_location ('p_mode : '||p_mode,6);
            end if;
          ben_benbatch_persons.create_life_person_actions
        (p_benefit_action_id        => l_benefit_action_id,
         p_business_group_id        => p_business_group_id,
         p_person_id                => p_person_id,
         p_ler_id                   => nvl(l_ler_id,l_ler_override_id),   -- irec
         p_person_type_id           => p_person_type_id,
         p_benfts_grp_id            => p_benfts_grp_id,
         p_location_id              => p_location_id,
         p_legal_entity_id          => p_legal_entity_id,
         p_payroll_id               => p_payroll_id,
         p_pstl_zip_rng_id          => p_pstl_zip_rng_id,
         p_organization_id          => p_organization_id,
         p_person_selection_rule_id => p_person_selection_rule_id,
         -- GRADE/STEP
         p_org_heirarchy_id         => p_org_heirarchy_id,
         p_org_starting_node_id     => p_org_starting_node_id,
         p_grade_ladder_id          => p_grade_ladder_id,
         p_asg_events_to_all_sel_dt => l_asg_events_to_all_sel_dt,
         p_rate_id                  => p_rate_id,
         p_per_sel_dt_cd            => p_per_sel_dt_cd,
         p_per_sel_dt_from          => l_per_sel_dt_from,
         p_per_sel_dt_to            => l_per_sel_dt_to,
         p_year_from                => p_year_from,
         p_year_to                  => p_year_to,
         p_cagr_id                  => p_cagr_id,
         p_qual_type                => p_qual_type,
         p_qual_status              => p_qual_status,
         -- 2940151
         p_per_sel_freq_cd    =>p_per_sel_freq_cd,
	 p_id_flex_num	      =>l_id_flex_num,
	 p_concat_segs 	      =>p_concat_segs,
         -- end 2940151
         -- End GRADE/STEP
         p_effective_date           => l_effective_date,
         p_chunk_size               => l_chunk_size,
         p_threads                  => l_threads,
         p_num_ranges               => l_num_ranges,
         p_num_persons              => l_num_persons,
         --
         -- PB : Healthnet change : Limit comp object selection
         -- based on the org id.
         --
         p_lmt_prpnip_by_org_flag   => p_lmt_prpnip_by_org_flag,
         p_commit_data              => p_commit_data,
                 -- ABSENCES : p_mode added
         p_mode                     => p_mode,
         p_lf_evt_oper_cd           => p_lf_evt_oper_cd   /* GSP Rate Sync */
         );

            if g_debug then
            hr_utility.set_location (l_package||' Dn Create L PER ACTs ',20);
            end if;
          --
        elsif p_mode in ('U','D') then
          --
          benutils.get_ler
        (p_business_group_id     => p_business_group_id,
         p_typ_cd                => 'SCHEDDU',
         p_effective_date        => l_effective_date,
         p_rec                   => l_ler_rec);
          --
          -- A bit of a hack to force the creation of a person action as we
          -- don't have a potential life event at this point and we want to be
          -- able to safely roll the person back should an error occur.
          --
          ben_person_actions_api.create_person_actions
        (p_validate              => false,
         p_person_action_id      => l_person_action_id,
         p_person_id             => p_person_id,
         p_ler_id                => l_ler_rec.ler_id,
         p_benefit_action_id     => l_benefit_action_id,
         p_action_status_cd      => 'U',
         p_chunk_number          => 1,
         p_object_version_number => l_object_version_number,
         p_effective_date        => l_effective_date);
          --
          ben_batch_ranges_api.create_batch_ranges
        (p_validate                  => false,
         p_benefit_action_id         => l_benefit_action_id,
         p_range_id                  => l_range_id,
         p_range_status_cd           => 'U',
         p_starting_person_action_id => l_person_action_id,
         p_ending_person_action_id   => l_person_action_id,
         p_object_version_number     => l_object_version_number,
         p_effective_date            => l_effective_date);
          --
          l_num_ranges := 1;
          l_num_persons := 1;
          --
	else
          --
          ben_benbatch_persons.create_normal_person_actions
        (p_benefit_action_id        => l_benefit_action_id
        --
        ,p_mode_cd                  => p_mode
        --
        ,p_business_group_id        => p_business_group_id
        ,p_person_id                => p_person_id
        ,p_ler_id                   => p_ler_id
        ,p_person_type_id           => p_person_type_id
        ,p_benfts_grp_id            => p_benfts_grp_id
        ,p_location_id              => p_location_id
        ,p_legal_entity_id          => p_legal_entity_id
        ,p_payroll_id               => p_payroll_id
        ,p_pstl_zip_rng_id          => p_pstl_zip_rng_id
        ,p_organization_id          => p_organization_id
        ,p_ler_override_id          => l_ler_override_id
        ,p_person_selection_rule_id => p_person_selection_rule_id
        --
        -- PB : Healthnet Change
        -- Pass the l_lf_evt_ocrd_dt for scheduled mode
        -- Bug#2638681 - Healthnet change reversed
        --,p_effective_date           => nvl(l_lf_evt_ocrd_dt, l_effective_date)
        ,p_effective_date           => l_effective_date
        ,p_lmt_prpnip_by_org_flag   => p_lmt_prpnip_by_org_flag
        ,p_mode                     => p_mode
        ,p_chunk_size               => l_chunk_size
        ,p_threads                  => l_threads
        ,p_num_ranges               => l_num_ranges
        ,p_num_persons              => l_num_persons
        ,p_commit_data              => p_commit_data
	,p_popl_enrt_typ_cycl_id  => l_popl_enrt_typ_cycl_id
	,p_cwb_person_type          => p_cwb_person_type
	,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
        );
          --
        end if;
        --
      else
        --
        ben_benbatch_persons.create_restart_person_actions
          (p_benefit_action_id        => p_benefit_action_id,
           p_effective_date           => l_effective_date,
           p_chunk_size               => l_chunk_size,
           p_threads                  => l_threads,
           p_num_ranges               => l_num_ranges,
           p_num_persons              => l_num_persons,
           p_commit_data              => p_commit_data);
        --
        l_benefit_action_id := p_benefit_action_id;
        --
      end if;
        if g_debug then
        hr_utility.set_location (l_package,30);
        end if;
      --
      if l_num_ranges = 0 then
        --
        if nvl(p_mode, 'X') <> 'W' then
           fnd_message.set_name('BEN','BEN_91769_NOONE_TO_PROCESS');
           -- Bug 3870204 : If no persons are selected then, dont error out, but just write the message
           -- in Audit Log and finish the process with Status = Normal
           -- fnd_message.raise_error;
           fnd_message.set_token('PROC' , l_package);
           raise l_no_one_to_process;
        end if;
        --
      end if;
      --

      -- No point in starting of ten threads if there is only one range of data.
      --
      -- Only run this if we are using concurrent manager and not doing WHAT IF
      -- Functionality
      --

      if p_commit_data = 'Y' then
        --
          if g_debug then
          hr_utility.set_location ('Threads = '||l_threads,10);
          hr_utility.set_location ('Ranges = '||l_num_ranges,10);
          end if;
        --
        -- Set l_threads = l_threads - 1 as the master becomes a thread
        --
        commit;
        --
        l_threads := least(l_threads,l_num_ranges)-1;
        --
        ben_maintain_benefit_actions.start_slaves
              (p_threads                  => l_threads
              ,p_num_ranges               => l_num_ranges
              ,p_validate                 => p_validate
              ,p_benefit_action_id        => l_benefit_action_id
              ,p_effective_date           => p_effective_date
              ,p_pgm_id                   => p_pgm_id
              ,p_business_group_id        => p_business_group_id
              ,p_pl_id                    => p_pl_id
              ,p_no_programs              => p_no_programs
              ,p_no_plans                 => p_no_plans
              ,p_rptg_grp_id              => p_rptg_grp_id
              ,p_pl_typ_id                => p_pl_typ_id
              ,p_opt_id                   => p_opt_id
              ,p_eligy_prfl_id            => p_eligy_prfl_id
              ,p_vrbl_rt_prfl_id          => p_vrbl_rt_prfl_id
              ,p_mode                     => p_mode
              ,p_person_selection_rule_id => p_person_selection_rule_id
              ,p_comp_selection_rule_id   => p_comp_selection_rule_id
              ,p_derivable_factors        => p_derivable_factors
              ,p_cbr_tmprl_evt_flag       => p_cbr_tmprl_evt_flag
              ,p_lmt_prpnip_by_org_flag   => p_lmt_prpnip_by_org_flag
              ,p_lf_evt_ocrd_dt           => p_lf_evt_ocrd_dt
	      ,p_gsp_eval_elig_flag       => l_gsp_eval_elig_flag     /* GSP Rate Sync */
	      ,p_lf_evt_oper_cd           => p_lf_evt_oper_cd         /* GSP Rate Sync */
              );
        --
        -- Always carry on with the master but make the master act as a slave
        -- as well. Only this thread can see the cache structure that we use to
        -- store the concurrent request id's. This ensures that the master thread
        -- always finishes last. GOOD THREADS ALWAYS FINISH LAST.
        --
        do_multithread
          (errbuf                     => l_errbuf,
           retcode                    => l_retcode,
           p_validate                 => p_validate,
           p_benefit_action_id        => l_benefit_action_id,
           p_effective_date           => p_effective_date,
           p_pgm_id                   => p_pgm_id,
           p_business_group_id        => p_business_group_id,
           p_pl_id                    => p_pl_id,
           -- PB : 5422 :
           p_popl_enrt_typ_cycl_id    => p_popl_enrt_typ_cycl_id,
           p_no_programs              => p_no_programs,
           p_no_plans                 => p_no_plans,
           p_rptg_grp_id              => p_rptg_grp_id,
           p_pl_typ_id                => p_pl_typ_id,
           p_opt_id                   => p_opt_id,
           p_eligy_prfl_id            => p_eligy_prfl_id,
           p_vrbl_rt_prfl_id          => p_vrbl_rt_prfl_id,
           p_mode                     => p_mode,
           p_person_selection_rule_id => p_person_selection_rule_id,
           p_comp_selection_rule_id   => p_comp_selection_rule_id,
           p_derivable_factors        => p_derivable_factors,
           p_thread_id                => l_threads+1,
           p_lf_evt_ocrd_dt           => p_lf_evt_ocrd_dt,
           p_lmt_prpnip_by_org_flag   => p_lmt_prpnip_by_org_flag,
           p_cbr_tmprl_evt_flag       => p_cbr_tmprl_evt_flag,
	   p_gsp_eval_elig_flag       => l_gsp_eval_elig_flag,    /* GSP Rate Sync */
	   p_lf_evt_oper_cd           => p_lf_evt_oper_cd         /* GSP Rate Sync */
	   );
        --
      end if;
      --
      -- Prasad special case
      --
      benutils.g_benefit_action_id := l_benefit_action_id;
      p_benefit_action_id := l_benefit_action_id;
      --
      /* GLOBALCWB : The issue of track ineligible flag have to be addressed
         later after drop 3, currently it has no meaning
          -- CWB Changes.
          -- Populate the heirarchy table.
          --
          if p_mode = 'W' then
            --
            open c_pln;
            fetch c_pln into l_trk_inelig_per_flag;
            close c_pln;

            if nvl(l_trk_inelig_per_flag,'N') = 'N' then
               for l_person_rec in c_person_info
               loop
                  --
                  del_cwb_pil
                 (l_person_rec.person_id,
                  p_pl_id,
                  l_effective_date,
                  l_ler_override_id,
                  l_lf_evt_ocrd_dt);
                  --
               end loop;
            end if;

            -- Bug 2237993 CWB fix: moved popu_cross_gb_epe_data call form
            -- process_rows to internal_process to avoid creating duplicate records
            -- for the cross business group.
            --
            for l_per_rec in c_person_info loop
               --
               --popu_cross_gb_epe_data(
               --   p_mode                     => p_mode,
               --   p_person_id                => l_per_rec.person_id,
               --   p_business_group_id        => p_business_group_id,
               --   p_ler_id                   => l_ler_override_id,
               --   p_pl_id                    => null, -- Currently not used by proc
               --   p_effective_date           => l_effective_date,
               --   p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
               -- );
               --
               popu_cross_gb_epe_pel_data(
                  p_mode                     => p_mode,
                  p_person_id                => l_per_rec.person_id,
                  p_business_group_id        => p_business_group_id,
                  p_ler_id                   => l_ler_override_id,
                  p_pl_id                    => null, -- Currently not used by proc
                  p_effective_date           => l_effective_date,
                  p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
                );
               --
            end loop;
            --
            --CWBITEM
            --popu_epe_heir();
            --CWBITEM
            popu_pel_heir();
            --
          end if;
          */
          --
          if p_commit_data = 'Y' then
             --
             commit;
             --
          end if;
          --
        if g_debug then
        hr_utility.set_location ('Leaving '||l_package,10);
        end if;
      --
      exception
         -- Bug 3870204
         when l_no_one_to_process then
            benutils.write(p_text => fnd_message.get);
            benutils.write_table_and_file(p_table => TRUE, p_file  => TRUE);
            rollback;
    end internal_process;
    --
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
      ,p_year_from                in     number   default null -- business rule year from
      ,p_year_to                  in     number   default null -- business rule year to
      ,p_cagr_id                  in     number   default null -- Coll agreement id
      ,p_qual_type                in     number   default null
      ,p_qual_status              in     varchar2 default null
      -- 2940151
      ,p_per_sel_freq_cd    	  in     varchar2 default null
      ,p_concat_segs              in     varchar2 default null
      -- end 2940151
      ,p_abs_historical_mode      in     varchar2 default 'N'
      ,p_gsp_eval_elig_flag       in     varchar2 default null  -- GSP Rate Sync : Evaluate Eligibility
      ,p_lf_evt_oper_cd           in     varchar2 default null  -- GSP Rate Sync : Life Event Operation code
      ,p_cwb_person_type          in     varchar2 default null)
    is
      --
      l_package                varchar2(80);
      --
      l_bft_id                 number;
      --
    begin
      --
        g_debug := hr_utility.debug_enabled;
        if g_debug then
          l_package := g_package||'.process';
        hr_utility.set_location ('Entering '||l_package,10);
        end if;
      --
      l_bft_id := p_benefit_action_id;
      --
        if g_debug then
        hr_utility.set_location ('p_mode : '||p_mode,4);
	end if;
        -- Bug 5857493
	if p_audit_log_flag ='Y' then
          ben_benbatch_persons.g_audit_flag := true;
        else
          ben_benbatch_persons.g_audit_flag := false;
        end if;
      internal_process
        (errbuf                     => errbuf
        ,retcode                    => retcode
        ,p_benefit_action_id        => l_bft_id
        ,p_effective_date           => p_effective_date
        ,p_mode                     => p_mode
        ,p_derivable_factors        => p_derivable_factors
        ,p_validate                 => p_validate
        ,p_person_id                => p_person_id
        ,p_person_type_id           => p_person_type_id
        ,p_pgm_id                   => p_pgm_id
        ,p_business_group_id        => p_business_group_id
        ,p_pl_id                    => p_pl_id
        ,p_popl_enrt_typ_cycl_id    => p_popl_enrt_typ_cycl_id
        ,p_lf_evt_ocrd_dt           => p_lf_evt_ocrd_dt
        ,p_no_programs              => p_no_programs
        ,p_no_plans                 => p_no_plans
        ,p_comp_selection_rule_id   => p_comp_selection_rule_id
        ,p_person_selection_rule_id => p_person_selection_rule_id
        ,p_ler_id                   => p_ler_id
        ,p_organization_id          => p_organization_id
        ,p_benfts_grp_id            => p_benfts_grp_id
        ,p_location_id              => p_location_id
        ,p_pstl_zip_rng_id          => p_pstl_zip_rng_id
        ,p_rptg_grp_id              => p_rptg_grp_id
        ,p_pl_typ_id                => p_pl_typ_id
        ,p_opt_id                   => p_opt_id
        ,p_eligy_prfl_id            => p_eligy_prfl_id
        ,p_vrbl_rt_prfl_id          => p_vrbl_rt_prfl_id
        ,p_legal_entity_id          => p_legal_entity_id
        ,p_payroll_id               => p_payroll_id
        ,p_commit_data              => p_commit_data
        ,p_audit_log_flag           => p_audit_log_flag
        ,p_lmt_prpnip_by_org_flag   => p_lmt_prpnip_by_org_flag
        ,p_cbr_tmprl_evt_flag       => p_cbr_tmprl_evt_flag
        -- GRADE/STEP : Added for grade/step benmngle
        ,p_org_heirarchy_id         => p_org_heirarchy_id
        ,p_org_starting_node_id     => p_org_starting_node_id
        ,p_grade_ladder_id          => p_grade_ladder_id
        ,p_asg_events_to_all_sel_dt => p_asg_events_to_all_sel_dt
        ,p_rate_id                  => p_rate_id
        ,p_per_sel_dt_cd            => p_per_sel_dt_cd
        ,p_per_sel_dt_from          => p_per_sel_dt_from
        ,p_per_sel_dt_to            => p_per_sel_dt_to
        ,p_year_from                => p_year_from
        ,p_year_to                  => p_year_to
        ,p_cagr_id                  => p_cagr_id
        ,p_qual_type                => p_qual_type
        ,p_qual_status              => p_qual_status
        ,p_abs_historical_mode      => p_abs_historical_mode
        -- 2940151
        ,p_per_sel_freq_cd    	    => p_per_sel_freq_cd
        ,p_concat_segs 	            => p_concat_segs
        -- end 2940151
        ,p_gsp_eval_elig_flag       => p_gsp_eval_elig_flag         -- GSP Rate Sync : Evaluate Eligibility
        ,p_lf_evt_oper_cd           => p_lf_evt_oper_cd             -- GSP Rate Sync : Life Event Operation code
        ,p_cwb_person_type          => p_cwb_person_type);
      --
  if g_debug then
    hr_utility.set_location ('Leaving '||l_package,10);
  end if;
  --
end process;
--
-- This procedure caches comp object names which can be referenced by
-- all other batch processes
--
procedure get_comp_object_name
  (p_oipl_id           in     number
  ,p_pgm_id            in     number
  ,p_pl_id             in     number
  ,p_plip_id           in     number
  ,p_ptip_id           in     number
  ,p_pl_nip            in     varchar2
  ,p_comp_object_name     out nocopy varchar2
  ,p_comp_object_value    out nocopy varchar2
  )
is
  --
  l_package           varchar2(80);
  l_comp_object_name  varchar2(80);
  l_pgm_rec           ben_pgm_f%rowtype;
  l_pl_rec            ben_pl_f%rowtype;
  l_oipl_rec          ben_oipl_f%rowtype;
  l_opt_rec           ben_opt_f%rowtype;
  l_plip_rec          ben_plip_f%rowtype;
  l_ptip_rec          ben_ptip_f%rowtype;
  --
begin
  --
  if g_debug then
    l_package := g_package||'.get_comp_object_name';
    hr_utility.set_location ('Entering '||l_package,10);
  end if;
  --
  if p_oipl_id is not null then
    --
    p_comp_object_value := g_cache_comp_objects.oipl;
    --
    ben_comp_object.get_object(p_rec     => l_oipl_rec,
                               p_oipl_id => p_oipl_id);
    ben_comp_object.get_object(p_rec     => l_opt_rec,
                               p_opt_id  => l_oipl_rec.opt_id);
    p_comp_object_name := rpad(substr(l_opt_rec.name,1,18),18,' ')||
                          benutils.id(p_oipl_id);
    --
  elsif p_pl_id is not null then
    --
    -- Test if plan is in program or not
    --
    if p_pl_nip = 'Y' then
      --
      p_comp_object_value := g_cache_comp_objects.pl;
      --
    else
      --
      p_comp_object_value := g_cache_comp_objects.plip;
      --
    end if;
    --
    ben_comp_object.get_object(p_rec   => l_pl_rec,
                               p_pl_id => p_pl_id);
    p_comp_object_name := rpad(substr(l_pl_rec.name,1,18),18,' ')||
                          benutils.id(p_pl_id);
    --
  elsif p_pgm_id is not null then
    --
    p_comp_object_value := g_cache_comp_objects.pgm;
    --
    ben_comp_object.get_object(p_rec    => l_pgm_rec,
                               p_pgm_id => p_pgm_id);
    p_comp_object_name := rpad(substr(l_pgm_rec.name,1,18),18,' ')||
                          benutils.id(p_pgm_id);
    --
  elsif p_plip_id is not null then
    --
    p_comp_object_value := g_cache_comp_objects.plip;
    --
    p_comp_object_name := rpad('Plip',15,' ')||
                          benutils.id(p_plip_id);
    --
  elsif p_ptip_id is not null then
    --
    p_comp_object_value := g_cache_comp_objects.ptip;
    --
    p_comp_object_name := rpad('Ptip',15,' ')||
                          benutils.id(p_ptip_id);
    --
  end if;
  --
  if g_debug then
    hr_utility.set_location ('Leaving '||l_package,10);
  end if;
  --
end get_comp_object_name;
--
procedure cache_person_information
        (p_person_id         in number,
         p_business_group_id in number,
         p_effective_date    in date) is
  --
  cursor c_person_prtn is
    select pen.pl_id,
           pen.oipl_id,
           pen.pgm_id,
           pen.ptip_id,
           pen.enrt_cvg_strt_dt,
           pen.enrt_cvg_thru_dt
    from   ben_prtt_enrt_rslt_f pen
    where  pen.person_id = p_person_id
    and    pen.business_group_id  = p_business_group_id
    and    p_effective_date
           between pen.enrt_cvg_strt_dt
           and     pen.enrt_cvg_thru_dt
    and    pen.enrt_cvg_thru_dt <= pen.effective_end_date
    and    pen.prtt_enrt_rslt_stat_cd is null
    and    pen.sspndd_flag = 'N';
  --
  l_package     varchar2(80);
  l_count       number(9) := 0;
  l_person_prtn c_person_prtn%rowtype;
  --
begin
  --
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_package := g_package||'.cache_person_information';
    hr_utility.set_location ('Entering '||l_package,10);
    hr_utility.set_location ('Entering '||p_effective_date,10);
  end if;
  --
  -- Open cursor to see if the person holds emp person type status
  --
  g_cache_person_prtn.delete;
  --
  l_count := 0;
  --
  open c_person_prtn;
    --
    loop
      --
      fetch c_person_prtn into l_person_prtn;
      exit when c_person_prtn%notfound;
      l_count := l_count + 1;
      --
      g_cache_person_prtn(l_count).pl_id
        := l_person_prtn.pl_id;
      g_cache_person_prtn(l_count).oipl_id
        := l_person_prtn.oipl_id;
      g_cache_person_prtn(l_count).pgm_id
        := l_person_prtn.pgm_id;
      g_cache_person_prtn(l_count).ptip_id
        := l_person_prtn.ptip_id;
      g_cache_person_prtn(l_count).enrt_cvg_strt_dt
        := l_person_prtn.enrt_cvg_strt_dt;
      g_cache_person_prtn(l_count).enrt_cvg_thru_dt
        := l_person_prtn.enrt_cvg_thru_dt;
      --
    end loop;
    --
  close c_person_prtn;

  if g_debug then
    hr_utility.set_location ('Done c_person_prtn '||l_package,40);
  end if;
  --
  -- We need to do the assignment stuff seperately as we can't outer join
  -- as we need assignments with primary flags and applicants have non
  -- primary flag assignments so the hack is to do the select in two
  -- statements, although a fix could be to do a union to get the value
  -- for the assignment id.
  --
  if g_debug then
    hr_utility.set_location ('Leaving '||l_package,100);
  end if;
  --
end cache_person_information;
-- ---------------------------------------------------------------------
procedure person_header
  (p_person_id                in number default null,
   p_business_group_id        in number,
   p_effective_date           in date) is
  --
  l_package           varchar2(80);
  l_output_string     varchar2(100);
  l_per_rec           per_all_people_f%rowtype;
  l_ass_rec           per_all_assignments_f%rowtype;
  l_bus_rec           per_business_groups%rowtype;
  l_org_rec           hr_all_organization_units%rowtype;
  l_org2_rec          hr_all_organization_units%rowtype;
  l_pad_rec           per_addresses%rowtype;
  l_loc_rec           hr_locations_all%rowtype;
  l_pay_rec           pay_all_payrolls_f%rowtype;
  l_ben_rec           ben_benfts_grp%rowtype;
  l_hsc_rec           hr_soft_coding_keyflex%rowtype;
  l_typ_rec           ben_person_object.g_cache_typ_table;
  --
begin
  --
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_package := g_package||'.person_header';
    hr_utility.set_location ('Entering '||l_package,10);
  end if;
  --
  -- Cache person data
  --
  cache_person_information
    (p_person_id         => p_person_id,
     p_business_group_id => p_business_group_id,
     p_effective_date    => p_effective_date);
    if g_debug then
      hr_utility.set_location ('Dn Cac Per Inf '||l_package,10);
    end if;
  --
  -- This should display something like this
  --
  -- *********************************************************************
  -- Name : John Smith (100) Type : Employee (1)  Grp : Benefits Group (1)
  -- BG   : Freds BG   (100) Org  : Freds Org(1)  GRE : Retiree
  -- Loc  : HQ         (100) Pst  : 86727         Pyr : Payroll 3B     (1)
  --
  ben_person_object.get_object(p_person_id => p_person_id,
                               p_rec       => l_per_rec);
  --
  if l_per_rec.benefit_group_id is not null then
    --
    ben_org_object.get_object(p_benfts_grp_id => l_per_rec.benefit_group_id,
                              p_rec           => l_ben_rec);
    --
  end if;
  --
  ben_person_object.get_object(p_person_id => p_person_id,
                               p_rec       => l_ass_rec);
  --
  if l_ass_rec.assignment_id is null then
    --
    ben_person_object.get_benass_object(p_person_id => p_person_id,
                                        p_rec       => l_ass_rec);
    --
  end if;
  --
  if l_ass_rec.location_id is not null then
    --
    ben_location_object.get_object(p_location_id => l_ass_rec.location_id,
                                   p_rec         => l_loc_rec);
    --
  end if;
  --
  if l_ass_rec.organization_id is not null then
    --
    ben_org_object.get_object(p_organization_id => l_ass_rec.organization_id,
                              p_rec             => l_org_rec);
    --
  end if;
  --
  if l_ass_rec.payroll_id is not null then
    --
    ben_org_object.get_object(p_payroll_id => l_ass_rec.payroll_id,
                              p_rec        => l_pay_rec);
    --
  end if;
  --
  if l_ass_rec.soft_coding_keyflex_id is not null then
    --
    ben_person_object.get_object
       (p_soft_coding_keyflex_id => l_ass_rec.soft_coding_keyflex_id,
        p_rec                    => l_hsc_rec);
    --
    if l_hsc_rec.segment1 is not null and hr_api.return_legislation_code(p_business_group_id) = 'US'
    then
      --
      ben_org_object.get_object(p_organization_id => l_hsc_rec.segment1,
                                p_rec             => l_org2_rec);
      --
    end if;
    --
  end if;
  --
    if g_debug then
      hr_utility.set_location ('BPO_GO PAD '||l_package,10);
    end if;
  ben_person_object.get_object(p_person_id => p_person_id,
                               p_rec       => l_pad_rec);
  --
  ben_person_object.get_object(p_person_id => p_person_id,
                               p_rec       => l_typ_rec);
  --
  ben_org_object.get_object(p_business_group_id => p_business_group_id,
                            p_rec               => l_bus_rec);
  --
  benutils.write(p_text => benutils.g_banner_asterix);
  l_output_string := 'Name: '||
                     substr(l_per_rec.full_name,1,45)||
                     benutils.id(p_person_id);
  benutils.write(p_text => l_output_string);
  l_output_string := ' Typ: '||
                     substr(l_typ_rec(1).user_person_type,1,45);
  --
  -- loop through the rest of the person_types
  --
  for l_count in 2..l_typ_rec.last loop
    --
    l_output_string := rpad(' ',6,' ');
    l_output_string := l_output_string||
                       substr(l_typ_rec(l_count).user_person_type,1,45);
    benutils.write(l_output_string);
    --
  end loop;
  l_output_string := 'Grp:  '||
                     substr(l_ben_rec.name,1,45)||
                     benutils.id(l_per_rec.benefit_group_id);
  benutils.write(p_text => l_output_string);
  --
  l_output_string := 'BG:   '||
                     substr(l_bus_rec.name,1,45)||
                     benutils.id(p_business_group_id);
  benutils.write(p_text => l_output_string);
  --
  l_output_string := 'Org:  '||
                     substr(l_org_rec.name,1,45)||
                     benutils.id(l_ass_rec.organization_id);
  benutils.write(p_text => l_output_string);
  --
  if hr_api.return_legislation_code(p_business_group_id) = 'US'
  then
    l_output_string := 'Gre:  '||
                     substr(l_org2_rec.name,1,45);
    benutils.write(p_text => l_output_string);
  else
    l_output_string := 'Gre:  '|| 'Not applicable' ;
    benutils.write(p_text => l_output_string);
  end if;
  --
  l_output_string := 'Loc:  '||
                     substr(l_loc_rec.address_line_1,1,45)||
                     benutils.id(l_loc_rec.location_id);
  benutils.write(p_text => l_output_string);
  --
  l_output_string := 'Pst:  '||
                     substr(l_pad_rec.postal_code,1,45);
  benutils.write(p_text => l_output_string);
  --
  l_output_string := 'Pyr:  '||
                     substr(l_pay_rec.payroll_name,1,45)||
                     benutils.id(l_pay_rec.payroll_id);
  benutils.write(p_text => l_output_string);
  --
  if g_debug then
    hr_utility.set_location ('Leaving '||l_package,10);
  end if;
  --
end person_header;
--
--
----------------------------------------------------------
-----------------< person_header_new >--------------------
----------------------------------------------------------
--
-- This is same procedure as PERSON_HEADER except that the call to
-- CACHE_PERSON_INFORMATION was removed to separate CACHE Logic
-- from displaying of person header
--
PROCEDURE person_header_new (
   p_person_id           IN   NUMBER DEFAULT NULL,
   p_business_group_id   IN   NUMBER
)
IS
   --
   l_package         VARCHAR2 (80);
   l_output_string   VARCHAR2 (100);
   l_per_rec         per_all_people_f%ROWTYPE;
   l_ass_rec         per_all_assignments_f%ROWTYPE;
   l_bus_rec         per_business_groups%ROWTYPE;
   l_org_rec         hr_all_organization_units%ROWTYPE;
   l_org2_rec        hr_all_organization_units%ROWTYPE;
   l_pad_rec         per_addresses%ROWTYPE;
   l_loc_rec         hr_locations_all%ROWTYPE;
   l_pay_rec         pay_all_payrolls_f%ROWTYPE;
   l_ben_rec         ben_benfts_grp%ROWTYPE;
   l_hsc_rec         hr_soft_coding_keyflex%ROWTYPE;
   l_typ_rec         ben_person_object.g_cache_typ_table;
--
BEGIN
   --
   g_debug := hr_utility.debug_enabled;

   IF g_debug
   THEN
      l_package := g_package || '.person_header';
      hr_utility.set_location ('Entering ' || l_package, 10);
   END IF;

--
-- This should display something like this
--
-- *********************************************************************
-- Name : John Smith (100) Type : Employee (1)  Grp : Benefits Group (1)
-- BG   : Freds BG   (100) Org  : Freds Org(1)  GRE : Retiree
-- Loc  : HQ         (100) Pst  : 86727         Pyr : Payroll 3B     (1)
--
   ben_person_object.get_object (p_person_id      => p_person_id,
                                 p_rec            => l_per_rec
                                );

   --
   IF l_per_rec.benefit_group_id IS NOT NULL
   THEN
      --
      ben_org_object.get_object (p_benfts_grp_id      => l_per_rec.benefit_group_id,
                                 p_rec                => l_ben_rec
                                );
   --
   END IF;

   --
   ben_person_object.get_object (p_person_id      => p_person_id,
                                 p_rec            => l_ass_rec
                                );

   --
   IF l_ass_rec.assignment_id IS NULL
   THEN
      --
      ben_person_object.get_benass_object (p_person_id      => p_person_id,
                                           p_rec            => l_ass_rec
                                          );
   --
   END IF;

   --
   IF l_ass_rec.location_id IS NOT NULL
   THEN
      --
      ben_location_object.get_object (p_location_id      => l_ass_rec.location_id,
                                      p_rec              => l_loc_rec
                                     );
   --
   END IF;

   --
   IF l_ass_rec.organization_id IS NOT NULL
   THEN
      --
      ben_org_object.get_object (p_organization_id      => l_ass_rec.organization_id,
                                 p_rec                  => l_org_rec
                                );
   --
   END IF;

   --
   IF l_ass_rec.payroll_id IS NOT NULL
   THEN
      --
      ben_org_object.get_object (p_payroll_id      => l_ass_rec.payroll_id,
                                 p_rec             => l_pay_rec
                                );
   --
   END IF;

   --
   IF l_ass_rec.soft_coding_keyflex_id IS NOT NULL
   THEN
      --
      ben_person_object.get_object (p_soft_coding_keyflex_id      => l_ass_rec.soft_coding_keyflex_id,
                                    p_rec                         => l_hsc_rec
                                   );

      --
      IF l_hsc_rec.segment1 IS NOT NULL and hr_api.return_legislation_code(p_business_group_id) = 'US'
      THEN
         --
         ben_org_object.get_object (p_organization_id      => l_hsc_rec.segment1,
                                    p_rec                  => l_org2_rec
                                   );
      --
      END IF;
   --
   END IF;

   --
   IF g_debug
   THEN
      hr_utility.set_location ('BPO_GO PAD ' || l_package, 10);
   END IF;

   ben_person_object.get_object (p_person_id      => p_person_id,
                                 p_rec            => l_pad_rec
                                );
   --
   ben_person_object.get_object (p_person_id      => p_person_id,
                                 p_rec            => l_typ_rec
                                );
   --
   ben_org_object.get_object (p_business_group_id      => p_business_group_id,
                              p_rec                    => l_bus_rec
                             );
   --
   benutils.WRITE (p_text => benutils.g_banner_asterix);
   --
   l_output_string :=
          'Name: '
       || SUBSTR (l_per_rec.full_name, 1, 45)
       || benutils.ID (p_person_id);
   --
   benutils.WRITE (p_text => l_output_string);
   --
   l_output_string :=
                     ' Typ: '
                     || SUBSTR (l_typ_rec (1).user_person_type, 1, 45);

   --
   -- loop through the rest of the person_types
   --
   FOR l_count IN 2 .. l_typ_rec.LAST
   LOOP
      --
      l_output_string := RPAD (' ', 6, ' ');
      l_output_string :=
             l_output_string
          || SUBSTR (l_typ_rec (l_count).user_person_type, 1, 45);
      benutils.WRITE (l_output_string);
   --
   END LOOP;

   l_output_string :=
          'Grp:  '
       || SUBSTR (l_ben_rec.NAME, 1, 45)
       || benutils.ID (l_per_rec.benefit_group_id);
   benutils.WRITE (p_text => l_output_string);
   --
   l_output_string :=
          'BG:   '
       || SUBSTR (l_bus_rec.NAME, 1, 45)
       || benutils.ID (p_business_group_id);
   benutils.WRITE (p_text => l_output_string);
   --
   l_output_string :=
          'Org:  '
       || SUBSTR (l_org_rec.NAME, 1, 45)
       || benutils.ID (l_ass_rec.organization_id);
   benutils.WRITE (p_text => l_output_string);
   --
   if hr_api.return_legislation_code(p_business_group_id) = 'US'
   then
       l_output_string := 'Gre:  ' || SUBSTR (l_org2_rec.NAME, 1, 45);
       benutils.WRITE (p_text => l_output_string);
   else
       l_output_string := 'Gre:  ' || 'Not applicable' ;
       benutils.WRITE (p_text => l_output_string);
   end if;
   --
   l_output_string :=
          'Loc:  '
       || SUBSTR (l_loc_rec.address_line_1, 1, 45)
       || benutils.ID (l_loc_rec.location_id);
   benutils.WRITE (p_text => l_output_string);
   --
   l_output_string := 'Pst:  ' || SUBSTR (l_pad_rec.postal_code, 1, 45);
   benutils.WRITE (p_text => l_output_string);
   --
   l_output_string :=
          'Pyr:  '
       || SUBSTR (l_pay_rec.payroll_name, 1, 45)
       || benutils.ID (l_pay_rec.payroll_id);
   benutils.WRITE (p_text => l_output_string);

   --
   IF g_debug
   THEN
      hr_utility.set_location ('Leaving ' || l_package, 10);
   END IF;
--
END person_header_new;
--
--
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
   p_lf_evt_oper_cd           in varchar2 default null) is       /* GSP Rate Sync */
  --
  l_package               varchar2(80);
  l_created_ler_id        ben_ler_f.ler_id%type := null;
  l_per_in_ler_id         ben_per_in_ler.per_in_ler_id%type;
  l_ptnl_ler              benutils.g_ptnl_ler;
  l_effective_start_date  date;
  l_effective_end_date    date;
  l_rec                   benutils.g_active_life_event;
  l_param_rec             benutils.g_batch_param_rec;
  l_ler_rec               benutils.g_ler;
  l_ler_batch_rec         benutils.g_batch_ler_rec;
  l_ptnl_ler_for_per_id   number;
  l_object_version_number number;
  l_ovn                   number;
  l_commit                number;
  l_mnl_dt                date;
  l_dtctd_dt              date;
  l_procd_dt              date;
  l_unprocd_dt            date;
  l_voidd_dt              date;
  l_strtd_dt              date;
  l_dummy                 varchar2(1);
  --
  -- Bug : 3511 : When a potential already sitting and
  --       benmngle is ran in scheduled mode with a effective
  --       date other than life event occured date a duplicate
  --       potential is being created and benmngle is stopping.
  --       Use lf_evt_ocrd_dt instead of effective_date in the
  --       where clause of c_ler_exists.
  -- Bug : 4919 : When a open potential is processed, do not create
  --       a new potential, the processed one will be backed out and it will
  --       be used for the current run.
  --
  -- Unrestricted enrollment enhancement-there can be more than one life event on the same day
  --
  cursor c_ler_exists(cv_ler_id in number,
                       cv_person_id in number,
                       cv_business_group_id in number,
                       cv_lf_evt_ocrd_dt in date) is
    select ptn.ptnl_ler_for_per_id
    from   ben_ptnl_ler_for_per ptn
    where  ptn.ler_id = cv_ler_id
    and    ptn.person_id = cv_person_id
    and    ptn.business_group_id  = cv_business_group_id
    and    ptn.lf_evt_ocrd_dt = cv_lf_evt_ocrd_dt
    and    ptn.ptnl_ler_for_per_stat_cd in ('DTCTD','UNPROCD', 'PROCD');
  --
  l_use_mode          varchar2(80);
  l_asnd_lf_evt_dt    date;
  l_cv_ler_id         number;
  l_cv_lf_evt_ocrd_dt date;
  l_gsp_ler_rec           benutils.g_ler;
  l_validate         boolean;
  --
begin
  --
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_package := g_package||'.evaluate_life_events';
    hr_utility.set_location ('Entering ' || l_package,10);
    hr_utility.set_location ('p_mode : ' || p_mode,10);
  end if;
  --
  -- Method of Operation
  -- ===================
  --
  -- In life event mode it is imperative that we recreate the set of comp
  -- objects for each person based on the life event occured date of the
  -- persons life event. To do this we simply rebuild the set of comp objects
  -- using the life event occured on date to derive which objects to use.
  -- Certain operations must be done using the life event occured date and
  -- certain operations must be done using the effective date. In general when
  -- creating records we use the effective date but when looking at reference
  -- information we use the life event occured date.
  --
  -- (1) Log the life event we are attempting to process
  -- (2) Evaluate the potential life events
  -- (3) If a new winning life event is found then log it
  --
  ben_env_object.setenv(p_person_id => p_person_id);

  -- Bug 1696526.  Added by Gopal Venkataraman 3/20/01 - This is was done
  -- to set the p_lf_evt_ocrd_dt until the real one is determined.
  -- Better than using the one from the previous person as is what happens
  -- without this.
  ben_env_object.setenv(p_lf_evt_ocrd_dt => p_effective_date);
  -- Add ended
  --
  benutils.get_batch_parameters
    (p_benefit_action_id => benutils.g_benefit_action_id
    ,p_rec               => l_param_rec
    );
  --
  benutils.get_batch_parameters
      (p_benefit_action_id => benutils.g_benefit_action_id
      ,p_rec               => l_param_rec
      );
  --
  -- CWB Changes : Added mode ABSENCES mode(M) added. Added GRADE/STEP mode
  -- added irec mode also
  if p_mode in ('G', 'L','C','U','R', 'W', 'M','I','D') then
    --
    -- CWB Changes : Added mode
    -- added irec mode
    if p_mode in ('G', 'L','C','W', 'M','I') then
      --
      --
      -- Create life event if person does not currently have an open
      -- enrollment.
      --
      -- CWB Changes : Added mode
      -- For Grade/Step : If the date is not null then create potential
      -- life events to every one.
      --
      if (p_mode in ('C', 'W')) or
         (p_mode = 'G' and l_param_rec.date_from is not null) then
        --
        if g_debug then
          hr_utility.set_location('Create potential',10);
        end if;
        if p_mode in ('C', 'W') then
           --
           l_cv_ler_id := p_ler_id;
           l_cv_lf_evt_ocrd_dt := nvl(p_lf_evt_ocrd_dt,
                                      p_effective_date);
           --
        elsif p_mode = 'G' then
           --
           benutils.get_ler
              (p_business_group_id     => p_business_group_id,
               p_typ_cd                => 'GSP',
               p_effective_date        => p_effective_date,
               p_lf_evt_oper_cd        => p_lf_evt_oper_cd,          /* GSP Rate Sync */
               p_rec                   => l_gsp_ler_rec);
           --
           l_cv_ler_id        := l_gsp_ler_rec.ler_id;
           --
           -- Here date_from is mapped to asg_events_to_all_sel_dt
           -- When all GRADE/STEP parameters are added to bft table use
           -- the actual column.
           --
           l_cv_lf_evt_ocrd_dt := l_param_rec.date_from;
           --
        end if;
        --
        open c_ler_exists(l_cv_ler_id,
                       p_person_id,
                       p_business_group_id,
                       l_cv_lf_evt_ocrd_dt);
          --
          fetch c_ler_exists into l_ptnl_ler_for_per_id;
          if c_ler_exists%notfound then
            --
            -- Create potential life event
            --
            if g_debug then
              hr_utility.set_location('Really created GSP potential',10);
            end if;
            ben_ptnl_ler_for_per_api.create_ptnl_ler_for_per
             (p_validate                 => false
             ,p_ptnl_ler_for_per_id      => l_ptnl_ler_for_per_id
             ,p_lf_evt_ocrd_dt           => l_cv_lf_evt_ocrd_dt
             --
             -- PB : 5422 : need to modify the form.
             -- 99999 Will this affect any where
             --
             ,p_enrt_perd_id             => null --  p_popl_enrt_typ_cycl_id
             ,p_ptnl_ler_for_per_stat_cd => 'DTCTD'
             ,p_ntfn_dt                  => trunc(sysdate)
             ,p_ler_id                   => l_cv_ler_id
             ,p_person_id                => p_person_id
             ,p_business_group_id        => p_business_group_id
             ,p_object_version_number    => l_ovn
             ,p_effective_date           => p_effective_date
             ,p_dtctd_dt                 => p_effective_date);
             --
             if g_debug then
               hr_utility.set_location('Finished created potential',10);
             end if;
             --
          end if;
          --
        close c_ler_exists;
        --
      end if;
      --
      fnd_message.set_name('BEN','BEN_91333_CALLING_PROC');
      --
      -- CWB Changes : Added mode
      --
      if p_mode in ('C', 'L') then
         --
         if g_debug then
           hr_utility.set_location('Evaluate potential',10);
         end if;
         fnd_message.set_token('PROC','ben_evaluate_ptnl_lf_evt');
         --
         if p_validate = 'Y'
         then
           l_validate := TRUE;
         else
           l_validate := FALSE;
         end if;
         --
         ben_evaluate_ptnl_lf_evt.eval_ptnl_per_for_ler
        (p_validate            => l_validate,   /* Bug 5550359 */
         p_person_id           => p_person_id,
         p_business_group_id   => p_business_group_id,
         p_ler_id              => p_ler_id,
         p_mode                => p_mode,
         p_effective_date      => p_effective_date,
         p_created_ler_id      => l_created_ler_id);
      --
       --
      elsif p_mode = 'I' then
         --
         -- iRec
         if g_debug then
           hr_utility.set_location('Evaluate iRec Potential LER',10);
         end if;
	 --
         fnd_message.set_token('PROC','ben_evaluate_ptnl_lf_evt');
         --
         ben_evaluate_ptnl_lf_evt.irec_eval_ptnl_per_for_ler
		(p_validate            => false,
		 p_person_id           => p_person_id,
		 p_business_group_id   => p_business_group_id,
		 p_ler_id              => g_ler_id,
		 p_mode                => p_mode,
		 p_effective_date      => p_effective_date,
		 p_lf_evt_ocrd_dt      => p_effective_date,
		 p_assignment_id       => g_irec_ass_rec.assignment_id,
		 p_ptnl_ler_for_per_id => null,
		 p_created_ler_id      => l_created_ler_id);
	 --
	 -- iRec
      --
      --
      elsif p_mode = 'W' then
         --
         if g_debug then
           hr_utility.set_location('CWB Evaluate potential',10);
         end if;
         fnd_message.set_token('PROC','cwb_eval_ptnl_per_for_ler');
         --
         ben_evaluate_ptnl_lf_evt.cwb_eval_ptnl_per_for_ler
        (p_validate            => false,
         p_person_id           => p_person_id,
         p_business_group_id   => p_business_group_id,
         p_ler_id              => p_ler_id,
         p_mode                => p_mode,
         p_effective_date      => p_effective_date,
         p_lf_evt_ocrd_dt      => nvl(p_lf_evt_ocrd_dt,
                                                p_effective_date),
         p_ptnl_ler_for_per_id => l_ptnl_ler_for_per_id,
         p_created_ler_id      => l_created_ler_id);
         --
      --
      -- ABSENCES mode
      --
      elsif p_mode = 'M' then
         --
         ben_evaluate_ptnl_lf_evt.absences_eval_ptnl_per_for_ler
        (p_validate            => false,
         p_person_id           => p_person_id,
         p_business_group_id   => p_business_group_id,
         p_ler_id              => p_ler_id,
         p_mode                => p_mode,
         p_effective_date      => p_effective_date,
         p_created_ler_id      => l_created_ler_id);
         --
      -- GRADE/STEP mode
      --
      elsif p_mode = 'G' then
         --
          ben_evaluate_ptnl_lf_evt.grd_stp_eval_ptnl_per_for_ler
         (p_validate            => false,
          p_person_id           => p_person_id,
          p_business_group_id   => p_business_group_id,
          p_ler_id              => p_ler_id,
          p_mode                => p_mode,
          p_effective_date      => p_effective_date,
          p_created_ler_id      => l_created_ler_id,
          p_lf_evt_oper_cd      => p_lf_evt_oper_cd);   /* GSP Rate Sync */
          --
      end if;
      --
    -- Unrestricted Mode should ignore active or potential non-unrestricted mode
    -- the following common codes for L,C or U mode is now made only for L or C mode
    --
    -- CWB Changes 9999 GRADE???? Need a seperate proc?
    --
    if p_mode <> 'W' then
       --
       if p_mode = 'G' then
          --
          benutils.get_active_life_event
          (p_person_id         => p_person_id,
           p_business_group_id => p_business_group_id,
           p_effective_date    => p_effective_date,
           p_lf_event_mode   => 'G',
           p_rec               => l_rec);
          --
       elsif p_mode = 'M' then
          --
          benutils.get_active_life_event
          (p_person_id         => p_person_id,
           p_business_group_id => p_business_group_id,
           p_effective_date    => p_effective_date,
           p_lf_event_mode   => 'M',
           p_rec               => l_rec);
          --
       elsif p_mode = 'I' then
          --
          -- iRec
          benutils.get_active_life_event
          (p_person_id         => p_person_id,
           p_business_group_id => p_business_group_id,
           p_effective_date    => p_effective_date,
           p_lf_event_mode     => 'I',
           p_rec               => l_rec);
          --
       else
          --
          benutils.get_active_life_event
         (p_person_id             => p_person_id,
          p_business_group_id     => p_business_group_id,
          p_effective_date        => p_effective_date,
          p_rec                   => l_rec);
          --
       end if;
       --
    else
      --
      -- Is it necessary in this procedure as this proc may not be called in W mode.
       benutils.get_active_life_event
      (p_person_id             => p_person_id,
       p_business_group_id     => p_business_group_id,
       p_effective_date        => p_effective_date,
       p_lf_evt_ocrd_dt        => p_lf_evt_ocrd_dt,
       p_ler_id                => p_ler_id,
       p_rec                   => l_rec);
      --
    end if;
    --
    if g_debug then
      hr_utility.set_location ('Done get ale ' || l_package,30);
    end if;
    --
    -- For life event collision detect any life event
    -- which was backed out and occured on same day.
    --
    g_bckdt_per_in_ler_id  := null;
    --
    -- CWB Changes ABSENCES changes  , GRADE/STEP no restore for Grade life events
    -- added irec
    if p_mode not in ('W', 'M', 'G','I') then
       --
       ben_lf_evt_clps_restore.get_ori_bckdt_pil(
                            p_person_id            => p_person_id
                            ,p_business_group_id   => p_business_group_id
                            ,p_ler_id              => l_rec.ler_id
                            ,p_effective_date      => l_rec.lf_evt_ocrd_dt
                            ,p_bckdt_per_in_ler_id => g_bckdt_per_in_ler_id
                           );
    end if;
    --
    if g_debug then
      hr_utility.set_location ('Dn BLECR_GOBP ' || l_package,30);
    end if;
    --
    -- PB : 5422 :
    -- Now if benmngle is run in Life event mode and the winner
    -- is open then change the mode of benmngle run for this
    -- person and proceed. Means the mode to be changed on the fly.
    --
    if (p_mode = 'L' and l_rec.typ_cd in ('SCHEDDO', 'SCHEDDA'))
    then
       --
       ben_manage_life_events.g_modified_mode := 'C';
       --
    -- 6806014

    -- Now if benmngle is run in Open mode (C) and the winner
    -- is a normal life event (which would be processed in mode 'L')
    -- then change the mode of benmngle run from 'C' to 'L'  for this
    -- person and proceed. Means the mode to be changed on the fly.

    elsif (p_mode = 'C' and l_rec.typ_cd not like 'SCHEDD%') then

       ben_manage_life_events.g_modified_mode := 'L';
    -- 6806014
    end if;
    --
    -- PB : If the supplied mode  and mode of winning life event
    --      differ, raise error.
    --
    -- if (p_mode = 'U' and l_rec.typ_cd <> 'SCHEDDU') or
    --
    if /*(p_mode = 'C' and l_rec.typ_cd not like 'SCHEDD%') or --commented for bug 6806014 */
       (p_mode = 'L' and l_rec.typ_cd in ('SCHEDDU','UNRSTR'))
       -- PB : 5422 :
       -- If benmngle is run in Life event mode and the winner
       -- is open then still proceed further.
       --
       -- PB : 5422 : (p_mode = 'L' and l_rec.typ_cd in ('SCHEDDO', 'SCHEDDA','SCHEDDU','UNRSTR'))
    then
      --
      benutils.write(p_text => 'Winner Life Event : '|| l_rec.name||
                               benutils.id(l_rec.ler_id) ||
                               ' , Supplied Mode : ' || p_mode);
      --
      -- Raise error for this person.
      --
      if (l_rec.typ_cd like 'SCHEDD%' or l_rec.typ_cd = 'UNRSTR') then
         l_use_mode := 'Scheduled mode';
      else
         l_use_mode := 'Life event mode';
      end if;
      fnd_message.set_name('BEN','BEN_92145_MODE_LE_DIFFER');
      fnd_message.set_token('MODE',l_use_mode);
      --
      -- Bug 2836770
      -- Set proper values to global variables before raising error
      -- Once value is retrieved from fnd_message.get, the next call
      -- return null value. Hence set the values.
      --
      g_rec.text := fnd_message.get;
      g_rec.error_message_code := 'BEN_92145_MODE_LE_DIFFER';
      benutils.write(p_text => g_rec.text );
      --
      -- Bug 2836770
      --
      -- Bug : 3658807
      -- Set the message name so that correct message is displayed in
      -- BENAUTHE.pld (Life Events Evaluation Processing Summary) - Messages
      --
      fnd_message.set_name('BEN','BEN_92145_MODE_LE_DIFFER');
      fnd_message.set_token('MODE',l_use_mode);
      raise g_record_error;
      --
    end if;
    --
    benutils.write(p_text => 'Life Event Occured Date: '||
                              l_rec.lf_evt_ocrd_dt);
    if l_created_ler_id <> nvl(p_ler_id,-1) then
      --
      -- Get life event name we are dealing with, put in global structure
      --
      p_ler_id := l_created_ler_id;
      benutils.write(p_text => 'Winner Life Event : '||
                                l_rec.name||
                                benutils.id(l_rec.ler_id));
      --
    end if;
    --
    ben_env_object.setenv(p_lf_evt_ocrd_dt => l_rec.lf_evt_ocrd_dt);
    dt_fndate.change_ses_date
      (p_ses_date => l_rec.lf_evt_ocrd_dt,
       p_commit   => l_commit);
    fnd_message.set_name('BEN','BEN_91333_CALLING_PROC');
    fnd_message.set_token('PROC','ben_related_person_ler_api');
    if g_debug then
      hr_utility.set_location (l_package||' create_rel_per_ler ' ,20);
    end if;
    --
    -- CWB Changes ABSENCES , GRADE/STEP : no need to create related ler's
    --
    if p_mode not in ('W', 'M', 'G','I') then
      --
      ben_related_person_ler_api.create_related_person_ler
      (p_validate          => false,
       p_person_id         => p_person_id,
       p_ler_id            => p_ler_id,
       p_effective_date    => p_effective_date,
       p_business_group_id => p_business_group_id,
       p_csd_by_ptnl_ler_for_per_id => l_rec.ptnl_ler_for_per_id,
       p_from_form         => 'N' );
      --
    end if;
    --
    -- CWB Changes
    --
    if nvl(ben_manage_life_events.g_modified_mode, p_mode) in ('C','W') then
       l_asnd_lf_evt_dt := l_rec.lf_evt_ocrd_dt;
    end if;
    --
    if p_mode = 'G' and p_lf_evt_oper_cd = 'SYNC'
    then
      --
      -- GSP Rate Sync : For this case we would not build compensation object list, but get current grade ladder / grade step
      -- and populate g_cache_proc_object in procedure process_comp_objects later
      hr_utility.set_location('GSP Rate Sync : Do not build comp obj list here', 23);
      --
    else
      if g_debug then
        hr_utility.set_location (l_package||' Bef BCOL ' ,25);
      end if;

      ben_comp_object_list.build_comp_object_list
        (p_benefit_action_id      => benutils.g_benefit_action_id
        ,p_comp_selection_rule_id => l_param_rec.comp_selection_rl
        ,p_effective_date         => l_rec.lf_evt_ocrd_dt
        ,p_pgm_id                 => l_param_rec.pgm_id
        ,p_business_group_id      => l_param_rec.business_group_id
        ,p_pl_id                  => l_param_rec.pl_id
        -- PB : 5422 :
        -- ,p_popl_enrt_typ_cycl_id  => l_param_rec.popl_enrt_typ_cycl_id
        ,p_asnd_lf_evt_dt         => l_asnd_lf_evt_dt
        ,p_no_programs            => l_param_rec.no_programs_flag
        ,p_no_plans               => l_param_rec.no_plans_flag
        ,p_rptg_grp_id            => l_param_rec.rptg_grp_id
        ,p_pl_typ_id              => l_param_rec.pl_typ_id
        ,p_opt_id                 => l_param_rec.opt_id
        ,p_eligy_prfl_id          => l_param_rec.eligy_prfl_id
        ,p_vrbl_rt_prfl_id        => l_param_rec.vrbl_rt_prfl_id
        ,p_thread_id              => benutils.g_thread_id
        -- PB : 5422 :
        ,p_mode                   => nvl(ben_manage_life_events.g_modified_mode,l_param_rec.mode_cd)
        -- ,p_mode                   => l_param_rec.mode_cd
        ,p_lmt_prpnip_by_org_flag => l_param_rec.lmt_prpnip_by_org_flag
        ,p_person_id              => p_person_id
        );
      if g_debug then
        hr_utility.set_location (l_package||' Dn BCOL ' ,27);
      end if;
      --
    end if;
      --
      -- if mode is 'U' unrestricted
      -- Get life event reason information for the passed in typ_cd.
      --
    elsif (p_mode = 'U' or p_mode = 'R' or p_mode = 'D') then /* IF p_mode IN ('G', 'L', 'C', 'U', 'R', 'W', 'M', 'I') */
      --
     if p_mode = 'D' then
      --
    benutils.get_active_life_event
       (p_person_id         => p_person_id,
        p_business_group_id => p_business_group_id,
        p_effective_date    => p_effective_date,
        p_lf_event_mode     => 'U',
        p_rec               => l_rec);
       --
     else
      --
      ben_manage_unres_life_events.delete_elctbl_choice
        (p_person_id         => p_person_id
        ,p_effective_date    => p_effective_date
        ,p_business_group_id => p_business_group_id
        ,p_rec               => l_rec
        );
      --
   end if;
    --
--   if p_mode in ('U','D') then -- Bug 6321565
      --
      benutils.get_ler
          (p_business_group_id     => p_business_group_id,
           p_typ_cd                => 'SCHEDDU',
           p_effective_date        => p_effective_date,
           p_rec                   => l_ler_rec);
      --
  --  end if;
    --
     if l_rec.per_in_ler_id is null then
         --
         ben_ptnl_ler_for_per_api.create_ptnl_ler_for_per
             (p_validate                 => false
             ,p_ptnl_ler_for_per_id      => l_ptnl_ler_for_per_id
                --
                -- PB : 5422 : need to modify the form.
                --
             ,p_enrt_perd_id             => null  -- p_popl_enrt_typ_cycl_id
             ,p_lf_evt_ocrd_dt           => p_effective_date
             ,p_ptnl_ler_for_per_stat_cd => 'DTCTD'
             ,p_ler_id                   => l_ler_rec.ler_id
             ,p_person_id                => p_person_id
             ,p_business_group_id        => p_business_group_id
             ,p_object_version_number    => l_object_version_number
             ,p_effective_date           => p_effective_date
             ,p_ntfn_dt                  => trunc(sysdate)
             ,p_dtctd_dt                 => p_effective_date);
         --
         l_rec.ptnl_ler_for_per_id := l_ptnl_ler_for_per_id;
         --
      end if;
      --
      -- Update the ptnl per for ler for the person
      --
      if p_ler_id is null then
         p_ler_id := l_ler_rec.ler_id;
      end if;
      --
      ben_ptnl_ler_for_per_api.update_ptnl_ler_for_per
        (p_validate                 => false
        ,p_object_version_number    => l_object_version_number
        ,p_ptnl_ler_for_per_id      => l_rec.ptnl_ler_for_per_id
        ,p_lf_evt_ocrd_dt           => p_effective_date
        ,p_ptnl_ler_for_per_stat_cd => 'PROCD'
        ,p_ler_id                   => p_ler_id
        ,p_person_id                => p_person_id
        ,p_business_group_id        => p_business_group_id
        ,p_effective_date           => p_effective_date
        ,p_program_application_id   => fnd_global.prog_appl_id
        ,p_program_id               => fnd_global.conc_program_id
        ,p_request_id               => fnd_global.conc_request_id
        ,p_program_update_date      => sysdate
        ,p_ntfn_dt                  => trunc(sysdate)
        ,p_procd_dt                 => p_effective_date);
      --
      -- Since this process does not go through the evaluate life event
      -- process we need to make this the active life event
      --
      l_ler_batch_rec.person_id := p_person_id;
      l_ler_batch_rec.ler_id := p_ler_id;
      l_ler_batch_rec.lf_evt_ocrd_dt := p_effective_date;
      l_ler_batch_rec.replcd_flag := 'N';
      l_ler_batch_rec.crtd_flag := 'Y';
      l_ler_batch_rec.tmprl_flag := 'N';
      l_ler_batch_rec.dltd_flag := 'N';
      l_ler_batch_rec.open_and_clsd_flag := 'N';
      l_ler_batch_rec.not_crtd_flag := 'N';
      l_ler_batch_rec.clsd_flag := 'N';
      l_ler_batch_rec.stl_actv_flag := 'N';
      l_ler_batch_rec.clpsd_flag := 'N';
      l_ler_batch_rec.clsn_flag := 'N';
      l_ler_batch_rec.no_effect_flag := 'N';
      l_ler_batch_rec.cvrge_rt_prem_flag := 'N';
      l_ler_batch_rec.business_group_id := p_business_group_id;
      l_ler_batch_rec.effective_date := p_effective_date;
      --
      benutils.write(p_rec => l_ler_batch_rec);
      if g_debug then
        hr_utility.set_location (l_package,60);
      end if;
      if l_rec.per_in_ler_id is null then
         ben_person_life_event_api.create_person_life_Event
           (p_validate                => false,
            p_per_in_ler_id           => l_per_in_ler_id,
            p_ler_id                  => p_ler_id,
            p_person_id               => p_person_id,
            p_ptnl_ler_for_per_id     => l_ptnl_ler_for_per_id,
            p_per_in_ler_stat_cd      => 'STRTD',
            p_lf_evt_ocrd_dt          => p_effective_date,
            p_business_group_id       => p_business_group_id,
            p_object_version_number   => l_object_version_number,
            p_effective_date          => p_effective_date,
            p_program_application_id  => fnd_global.prog_appl_id,
            p_program_id              => fnd_global.conc_program_id,
            p_request_id              => fnd_global.conc_request_id,
            p_program_update_date     => sysdate
           ,p_procd_dt                => l_procd_dt
           ,p_strtd_dt                => l_strtd_dt
           ,p_voidd_dt                => l_voidd_dt
           );
          -- only one started unrestricted for a person
          if p_mode = 'U' then
            commit;
          end if;
       else
          ben_person_life_event_api.update_person_life_event
            (p_per_in_ler_id           => l_rec.per_in_ler_id,
             p_per_in_ler_stat_cd      => 'STRTD',
             p_object_version_number   => l_rec.object_version_number,
             p_lf_evt_ocrd_dt          => p_effective_date,
             p_effective_date          => p_effective_date,
             p_procd_dt                => l_procd_dt,
             p_strtd_dt                => l_strtd_dt,
             p_voidd_dt                => l_voidd_dt);
       end if;
       --
       if p_mode = 'R' then
         --
          ben_comp_object_list.build_comp_object_list
         (p_benefit_action_id      => benutils.g_benefit_action_id
         ,p_comp_selection_rule_id => l_param_rec.comp_selection_rl
         ,p_effective_date         => p_effective_date
         ,p_pgm_id                 => l_param_rec.pgm_id
         ,p_business_group_id      => l_param_rec.business_group_id
         ,p_pl_id                  => l_param_rec.pl_id
         ,p_asnd_lf_evt_dt         => l_asnd_lf_evt_dt
         ,p_no_programs            => l_param_rec.no_programs_flag
         ,p_no_plans               => l_param_rec.no_plans_flag
         ,p_rptg_grp_id            => l_param_rec.rptg_grp_id
         ,p_pl_typ_id              => l_param_rec.pl_typ_id
         ,p_opt_id                 => l_param_rec.opt_id
         ,p_eligy_prfl_id          => l_param_rec.eligy_prfl_id
         ,p_vrbl_rt_prfl_id        => l_param_rec.vrbl_rt_prfl_id
         ,p_thread_id              => benutils.g_thread_id
         ,p_mode                   => 'U'
         ,p_lmt_prpnip_by_org_flag => l_param_rec.lmt_prpnip_by_org_flag
         ,p_person_id              => p_person_id
         );
        --
      end if;
      --
    end if;
    --
    fnd_message.set_name('BEN','BEN_91333_CALLING_PROC');
    fnd_message.set_token('PROC','benutils.get_batch_parameters');
    ben_enrolment_requirements.g_electable_choice_created := false;
    ben_enrolment_requirements.g_any_choice_created := false;
    ben_enrolment_requirements.g_auto_choice_created := false;
    ben_determine_dpnt_eligibility.g_dpnt_ineligible := false;
    --
  elsif l_param_rec.lmt_prpnip_by_org_flag = 'Y'
        and p_mode in ('A','P','S','T') then
    --
    -- PB : Healthnet changes
    -- Build the comp object list in evaluate_life_events
    -- if comp objects selection is based on person's org id.
    --
    if g_debug then
      hr_utility.set_location (' Temp BCOL '||l_package,10);
    end if;
    ben_comp_object_list.build_comp_object_list
      (p_benefit_action_id      => benutils.g_benefit_action_id
      ,p_comp_selection_rule_id => l_param_rec.comp_selection_rl
      ,p_effective_date         => p_effective_date
      ,p_pgm_id                 => l_param_rec.pgm_id
      ,p_business_group_id      => l_param_rec.business_group_id
      ,p_pl_id                  => l_param_rec.pl_id
      -- PB : 5422 :
      -- ,p_popl_enrt_typ_cycl_id  => l_param_rec.popl_enrt_typ_cycl_id
      ,p_asnd_lf_evt_dt         => null
      ,p_no_programs            => l_param_rec.no_programs_flag
      ,p_no_plans               => l_param_rec.no_plans_flag
      ,p_rptg_grp_id            => l_param_rec.rptg_grp_id
      ,p_pl_typ_id              => l_param_rec.pl_typ_id
      ,p_opt_id                 => l_param_rec.opt_id
      ,p_eligy_prfl_id          => l_param_rec.eligy_prfl_id
      ,p_vrbl_rt_prfl_id        => l_param_rec.vrbl_rt_prfl_id
      ,p_thread_id              => benutils.g_thread_id
      -- PB : 5422 :
      ,p_mode                   => p_mode
      -- ,p_mode                   => l_param_rec.mode_cd
      ,p_lmt_prpnip_by_org_flag => l_param_rec.lmt_prpnip_by_org_flag
      ,p_person_id              => p_person_id
      );
    --
    -- Set up participation eligibility for all comp objects in the list
    --
    set_up_list_part_elig
         (p_ler_id            => null
         ,p_business_group_id => p_business_group_id
         ,p_effective_date    => p_effective_date
         );
    if g_debug then
      hr_utility.set_location (' Dn Temp BCOL '||l_package,10);
    end if;
    --
  end if;
  --
  if g_debug then
    hr_utility.set_location ('Leaving '||l_package,10);
  end if;
  --
  exception
    --
    when others then
      raise;
    --
end evaluate_life_events;
--
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
  )
is
  --
  -- PB : 5422 :
  -- This is not being used
  --
  /*
  cursor c_strt_dt is
    select strt_dt
    from   ben_enrt_perd
    where  enrt_perd_id = p_popl_enrt_typ_cycl_id;
  */
  --
  cursor c_get_inelig_dpnt_info(p_per_in_ler_id in number) is
  -- RCHASE - wwBug1427383 - return correct date for creating dependent benefit assignment
    select pdp.dpnt_person_id, min(egd.elig_thru_dt) cvg_thru_dt--min(pdp.cvg_thru_dt) cvg_thru_dt
    from   ben_elig_cvrd_dpnt_f pdp
          ,ben_elig_dpnt egd
          ,ben_prtt_enrt_rslt_f pen
    where pdp.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
    and   pen.person_id = p_person_id
    and   pen.effective_end_date = hr_api.g_eot
    and   pen.business_group_id = p_business_group_id
    and   nvl(pdp.cvg_thru_dt,hr_api.g_eot) <> hr_api.g_eot
    and   pdp.business_group_id = pen.business_group_id
    and   pdp.elig_cvrd_dpnt_id = egd.elig_cvrd_dpnt_id
    and   egd.dpnt_inelig_flag = 'Y'
    and   egd.per_in_ler_id = p_per_in_ler_id
    and   egd.business_group_id = pdp.business_group_id
    group by pdp.dpnt_person_id;
  --
  cursor c_pil_elctbl_chc_popl (p_per_in_ler_id in number) is
   select popl.pil_elctbl_chc_popl_id,
          popl.object_version_number
   from   ben_pil_elctbl_chc_popl popl
   where  per_in_ler_id =  p_per_in_ler_id
   and    not exists
          (select null
           from ben_elig_per_elctbl_chc epe
           where epe.pil_elctbl_chc_popl_id = popl.pil_elctbl_chc_popl_id
           and   elctbl_flag = 'Y');
  --
  cursor c_pil (p_per_in_ler_id number, p_pgm_id number, p_pl_id number) is
    select 'Y'
    from ben_pil_elctbl_chc_popl popl
    where  per_in_ler_id =  p_per_in_ler_id
    and    (popl.pgm_id = p_pgm_id  or
            popl.pl_id  = p_pl_id);
  --
  l_rec                        benutils.g_active_life_event;
  l_lf_rec                     benutils.g_active_life_event;
  --
  cursor c_ptnl is
    select a.ptnl_ler_for_per_id ptnl_ler_for_per_id,
           a.object_version_number object_version_number
    from   ben_ptnl_ler_for_per a,
           ben_per_in_ler b
    where  b.per_in_ler_id = l_rec.per_in_ler_id
    and    b.ptnl_ler_for_per_id = a.ptnl_ler_for_per_id;
  --
  cursor c_ptip_pl_id(p_gsp_pgm_id  number,
                      p_gsp_plip_id number) is
  select ptip.ptip_id,
         pln.pl_id
    from ben_ptip_f ptip,
         ben_pl_f pln,
         ben_plip_f plip
   where plip.plip_id = p_gsp_plip_id
     and plip.pgm_id = p_gsp_pgm_id
     and p_effective_date between plip.effective_start_date
     and plip.effective_end_date
     and pln.pl_id = plip.pl_id
     and plip.effective_start_date between pln.effective_start_date
     and pln.effective_end_date
     and ptip.pl_typ_id = pln.pl_typ_id
     and ptip.pgm_id = p_gsp_pgm_id
     and p_effective_date between ptip.effective_start_date
     and ptip.effective_end_date;
  --
  --  Min Max enhancement.
  --
  cursor c_get_ended_enrt_rslts(p_per_in_ler_id number) is
    select pen.*
    from ben_prtt_enrt_rslt_f pen
    where pen.person_id = p_person_id
    and pen.prtt_enrt_rslt_stat_cd is null
    and pen.sspndd_flag = 'N'
    and pen.enrt_cvg_thru_dt <> hr_api.g_eot
    and pen.effective_end_date = hr_api.g_eot
    and p_effective_date between pen.effective_start_date
                             and pen.effective_end_date
    and pen.business_group_id = p_business_group_id
    and pen.comp_lvl_cd not in ('PLANFC', 'PLANIMP')
    and pen.per_in_ler_id = p_per_in_ler_id
    ;
  cursor c_get_ptip_tot_enrd(p_ptip_id number) is
    select count(*)
    from ben_prtt_enrt_rslt_f pen
    where pen.person_id = p_person_id
    and pen.prtt_enrt_rslt_stat_cd is null
    and pen.sspndd_flag = 'N'
    and pen.ptip_id = p_ptip_id
    and pen.comp_lvl_cd not in ('PLANFC', 'PLANIMP')
    and (   pen.enrt_cvg_thru_dt =  hr_api.g_eot
         or (    pen.enrt_cvg_thru_dt >= p_effective_date
             and nvl(pen.enrt_ovridn_flag,'N') = 'Y'
            )
        )
    and pen.effective_end_date = hr_api.g_eot
    and p_effective_date between pen.effective_start_date
                             and pen.effective_end_date
    and pen.business_group_id = p_business_group_id
    ;

  cursor c_get_ptip(p_ptip_id number) is
    select ptip.ptip_id,
           ptip.pgm_id,
           ptip.pl_typ_id,
           ptip.Mx_ENRD_ALWD_OVRID_NUM,
           ptip.no_mx_pl_typ_ovrid_flag,
           ptip.MN_ENRD_RQD_OVRID_NUM,
           ptip.no_mn_pl_typ_overid_flag,
           plt.name,
           Plt.MN_ENRL_RQD_NUM,
           plt.MX_ENRL_ALWD_NUM
      from ben_ptip_f ptip
         , ben_pl_typ_f plt
     where ptip.ptip_id = p_ptip_id
       and ptip.pl_typ_id = plt.pl_typ_id
       and ptip.business_group_id = p_business_group_id
       and p_effective_date between
               ptip.effective_start_date and ptip.effective_end_date
       and p_effective_date between
               plt.effective_start_date and plt.effective_end_date
           ;
  --
  cursor c_get_ptip_elig(p_ptip_id       number
                        ,p_per_in_ler_id number
                         ) is
    select pep.elig_flag
      from ben_elig_per_f pep
     where pep.per_in_ler_id = p_per_in_ler_id
       and pep.ptip_id = p_ptip_id
       and pep.business_group_id = p_business_group_id
       and p_effective_date between pep.effective_start_date
                            and pep.effective_end_date
           ;

  l_ptip_rec                   c_get_ptip%rowtype;
  l_count                      number(15);
  l_pep_row                    ben_derive_part_and_rate_facts.g_cache_structure;
  l_chk_min_max                varchar2(30);
  l_ptip_elig_flag             varchar2(30);
  l_MN_ENRD_RQD_OVRID_NUM      ben_ptip_f.MN_ENRD_RQD_OVRID_NUM%type;
  --
  -- End Min Max enhancement.
  --
  l_rec_ptnl_ler_for_per_id number;
  l_rec_object_version_number number;
  --
  l_package                    varchar2(80);
  --
  l_enb_valrow                 ben_determine_coverage.ENBValType;
  --
  l_env                        ben_env_object.g_global_env_rec_type;
  l_comp_obj_tree              ben_manage_life_events.g_cache_proc_object_table;
  l_par_elig_state             ben_comp_obj_filter.g_par_elig_state_rec;
  l_comp_obj_tree_row          ben_manage_life_events.g_cache_proc_objects_rec;
  l_parpepgm_row               ben_prtn_elig_f%rowtype;
  l_parpeptip_row              ben_prtn_elig_f%rowtype;
  l_parpeplip_row              ben_prtn_elig_f%rowtype;
  l_parpepl_row                ben_prtn_elig_f%rowtype;
  l_paretprpgm_row             ben_elig_to_prte_rsn_f%rowtype;
  l_paretprptip_row            ben_elig_to_prte_rsn_f%rowtype;
  l_paretprplip_row            ben_elig_to_prte_rsn_f%rowtype;
  l_paretprpl_row              ben_elig_to_prte_rsn_f%rowtype;
  l_currpe_row                 ben_prtn_elig_f%rowtype;
  l_curretpr_row               ben_elig_to_prte_rsn_f%rowtype;
  l_currpgm_row                ben_pgm_f%rowtype;
  l_currptip_row               ben_ptip_f%rowtype;
  l_currplip_row               ben_plip_f%rowtype;
  l_currpl_row                 ben_pl_f%rowtype;
  l_curroipl_row               ben_cobj_cache.g_oipl_inst_row;
  l_curroiplip_row             ben_cobj_cache.g_oiplip_inst_row;
  l_parpgm_row                 ben_pgm_f%rowtype;
  l_parptip_row                ben_ptip_f%rowtype;
  l_parplip_row                ben_plip_f%rowtype;
  l_parpl_row                  ben_pl_f%rowtype;
  l_paropt_row                 ben_cobj_cache.g_opt_inst_row;
  l_paroipl_row                ben_cobj_cache.g_oipl_inst_row;
  l_per_row                    per_all_people_F%rowtype;
  l_pil_row                    ben_per_in_ler%rowtype;
  l_empasg_row                 per_all_assignments_f%rowtype;
  l_benasg_row                 per_all_assignments_f%rowtype;
  l_appasg_row                 ben_person_object.g_cache_ass_table;
  l_empasgast_row              per_assignment_status_types%rowtype;
  l_benasgast_row              per_assignment_status_types%rowtype;
  --
  l_comp_object_value          varchar2(80);
  l_comp_object_name           varchar2(80);
  l_output_string              varchar2(100);
  l_per_grade                  number := null;
  l_per_job                    number := null;
  l_per_per_typ                varchar2(30) := null;
  l_per_pay_basis_id           number := null;
  l_per_benfts_grp_id          number := null;
  l_per_pyrl_id                number := null;
  l_per_location_id            number := null;
  l_per_org_id                 number := null;
  l_per_peo_group_id           number := null;
  l_postal_code                varchar2(30) := null;
  l_py_freq                    varchar2(30) := null;
  l_normal_hours               number := null;
  l_frequency                  varchar2(30) := null;
  l_bargaining_unit_code       varchar2(30) := null;
  l_assignment_status_type_id  number := null;
  l_change_rsn                 varchar2(30) := null;
  l_gre_cd                     varchar2(150) := null;
  l_enrlt_pl_id                number := null;
  l_employment_category        varchar2(30) := null;
  l_prtt_is_cvrd_flag          varchar2(30) := null;
  l_sspndd_flag                varchar2(30) := null;
  l_electable_flag             varchar2(30) := null;
  l_once_r_cntug_cd            varchar2(30) := null;
  l_elig_flag                  varchar2(30) := null;
  l_elig_per_elctbl_chc_id     number :=null;
  l_strt_dt                    date :=null;
  l_effective_start_date       date;
  l_effective_end_date         date;
  l_loop_count                 number;
  l_commit                     number;
  l_procd_dt                   date;
  l_voidd_dt                   date;
  l_strtd_dt                   date;
  l_pl_id                      number;
  l_cwb_pl_id                  number;
  l_plip_id                    number;
  l_ptip_id                    number;
  l_pgm_id                     number;
  l_oipl_id                    number;
  --
  l_newly_elig    boolean;
  l_newly_inelig  boolean;
  l_first_elig    boolean;
  l_first_inelig  boolean;
  l_still_elig    boolean;
  l_still_inelig  boolean;
  l_continue_loop boolean;
  l_eligible      boolean;
  l_not_eligible  boolean;
  l_elig_state_change boolean := false;
  --
  l_pl_nip         varchar2(30);
  --
  l_treeele_num    pls_integer;
  l_maxtreeele_num pls_integer;
  l_treeloop       boolean;
  l_boundary       boolean;
  l_comp_rec       ben_derive_part_and_rate_facts.g_cache_structure;
  l_d_comp_rec       ben_derive_part_and_rate_facts.g_cache_structure;
  l_oiplip_rec     ben_derive_part_and_rate_facts.g_cache_structure;
  l_d_oiplip_rec     ben_derive_part_and_rate_facts.g_cache_structure;
  --
  l_object_version_number number;
  l_perhasmultptus        boolean;
  l_assignment_id         number;
  l_pil_elctbl_chc_popl  c_pil_elctbl_chc_popl%rowtype;
  l_asnd_lf_evt_dt        date;
  --
  l_mode                varchar2(1); -- Added by Gopal Venkataraman 3/27/01 bug 1636071.
  l_pil                  varchar2(1);
  l_gsp_pgm_id           number;
  l_gsp_ptip_id          number;
  l_gsp_plip_id          number;
  l_gsp_pl_id            number;
  l_prgr_style           varchar2(30);
  l_evaluate_eligibility boolean := true;

  --
  -- FONM : Begin
  --
  l_rec_enrt_cvg_strt_dt         DATE;
  l_fonm_cvg_strt_dt             DATE;
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
  l_rec_lee_rsn_id               NUMBER;
  l_rec_enrt_perd_id             NUMBER;
  l_dummy                        VARCHAR2(30);

  l_old_data_migrator_mode varchar2(1) ;-- irec2

  -- to get the le_resn id
  cursor c_lee_rsn(c_pl_id number ,
                   c_pgm_id number,
                   c_effective_date date) is
  select 1 ordr_num ,
         leer.lee_rsn_id,
        NVL(leer.defer_deenrol_flag,'N')
    FROM     ben_lee_rsn_f leer, ben_popl_enrt_typ_cycl_f petc
      WHERE    leer.ler_id = p_ler_id
      AND      leer.business_group_id = p_business_group_id
      AND      c_effective_date BETWEEN leer.effective_start_date
                   AND leer.effective_end_date
      AND      leer.popl_enrt_typ_cycl_id = petc.popl_enrt_typ_cycl_id
      AND      petc.pl_id = c_pl_id
      AND      petc.enrt_typ_cycl_cd = 'L'                        -- life event
      AND      petc.business_group_id = p_business_group_id
      AND      c_effective_date BETWEEN petc.effective_start_date
                   AND petc.effective_end_date
   UNION
    select 2 ordr_num ,
         leer.lee_rsn_id,
        NVL(leer.defer_deenrol_flag,'N')
     FROM     ben_lee_rsn_f leer, ben_popl_enrt_typ_cycl_f petc
      WHERE    leer.ler_id = p_ler_id
      AND      leer.business_group_id = p_business_group_id
      AND      c_effective_date BETWEEN leer.effective_start_date
                   AND leer.effective_end_date
      AND      leer.popl_enrt_typ_cycl_id = petc.popl_enrt_typ_cycl_id
      AND      petc.pgm_id = c_pgm_id
      AND      petc.enrt_typ_cycl_cd = 'L'                        -- life event
      AND      petc.business_group_id = p_business_group_id
      AND      c_effective_date BETWEEN petc.effective_start_date
                   AND petc.effective_end_date
   order by 1 ;

  -- to get the enrol_period id
  cursor c_enrt_perd_id (c_pl_id number ,
                   c_pgm_id number,
                   c_effective_date date) is
   select 1 ordr_num ,
          enrtp.enrt_perd_id,
          NVL(enrtp.defer_deenrol_flag,'N')
    FROM  ben_popl_enrt_typ_cycl_f petc,
          ben_enrt_perd enrtp,
                ben_ler_f ler
   WHERE  petc.pl_id = c_pl_id
     AND  petc.business_group_id = p_business_group_id
     AND  c_effective_date BETWEEN petc.effective_start_date
          AND petc.effective_end_date
     AND  petc.enrt_typ_cycl_cd <> 'L'
     AND  enrtp.business_group_id = p_business_group_id
     AND  enrtp.asnd_lf_evt_dt  = c_effective_date
     AND  enrtp.popl_enrt_typ_cycl_id  = petc.popl_enrt_typ_cycl_id
     -- comp work bench changes
     and  ler.ler_id (+) = enrtp.ler_id
     and  ler.ler_id (+) = p_ler_id
     and  c_effective_date between ler.effective_start_date (+)
          and ler.effective_end_date (+)
   UNION
   select 2 ordr_num ,
          enrtp.enrt_perd_id,
          NVL(enrtp.defer_deenrol_flag,'N')
    FROM  ben_popl_enrt_typ_cycl_f petc,
          ben_enrt_perd enrtp,
                ben_ler_f ler
   WHERE  petc.pgm_id = c_pgm_id
     AND  petc.business_group_id = p_business_group_id
     AND  c_effective_date BETWEEN petc.effective_start_date
          AND petc.effective_end_date
     AND  petc.enrt_typ_cycl_cd <> 'L'
     AND  enrtp.business_group_id = p_business_group_id
     AND  enrtp.asnd_lf_evt_dt  = c_effective_date
     AND  enrtp.popl_enrt_typ_cycl_id  = petc.popl_enrt_typ_cycl_id
     -- comp work bench changes
     and  ler.ler_id (+) = enrtp.ler_id
     and  ler.ler_id (+) = p_ler_id
     and  c_effective_date between ler.effective_start_date (+)
          and ler.effective_end_date (+)
    order by 1 ;
  -- bug 6491682
  -- cursor to fetch per_in_ler_id in mode S (MPE conc program)

  cursor c_get_unres_per_in_ler is
    select pil.per_in_ler_id
    from   ben_per_in_ler pil,
           ben_ler_f ler
    where  pil.person_id = p_person_id
    and    pil.business_group_id = p_business_group_id
    and    ler.ler_id = pil.ler_id
    and    ler.business_group_id = pil.business_group_id
    and    p_effective_date
           between ler.effective_start_date
           and     ler.effective_end_date
    and    pil.per_in_ler_stat_cd = 'STRTD'
    and    ler.typ_cd = 'SCHEDDU';

   l_get_unres_per_in_ler c_get_unres_per_in_ler%ROWTYPE;

  -- bug 6491682

  --
  l_last_ptip_id    number  ;
  l_pgm_fonm   varchar2(1) ;
  l_ptip_fonm  varchar2(1) ;
  -- FONM : End

  --
  -- GSP Rate Sync
  l_gsp_emp_step_id                     number(30);
  l_gsp_num_incr                        number(30);
  l_gsp_oipl_id                         number(30);
  l_gsp_oiplip_id                       number(30);
  l_gsp_opt_id                          number(30);
  --
  cursor c_get_oiplip_opt_id (cv_oipl_id number,
                              cv_plip_id number) is
    select opp.oiplip_id, opt_id
      from ben_oiplip_f opp, ben_oipl_f cop
     where opp.oipl_id = cv_oipl_id
       and opp.plip_id = cv_plip_id
       and p_effective_date between opp.effective_start_date and opp.effective_end_date
       and cop.oipl_id = opp.oipl_id
       and p_effective_date between cop.effective_start_date and cop.effective_end_date;
  -- GSP Rate Sync
  --
-- Defer ENH.
  cursor c_pel_defer(p_pgm_id number,p_per_in_ler_id in number) is
    select pel.*
    from   ben_pil_elctbl_chc_popl pel
    where  pel.pgm_id = p_pgm_id
     and   pel.pl_id is null
     and   pel.pil_elctbl_popl_stat_cd not in ('VOIDD','BCKDT')
     and   pel.per_in_ler_id = p_per_in_ler_id;
  --
  l_pel_defer c_pel_defer%ROWTYPE;
  --
  cursor c_pel_pnip_defer (p_pl_id number,p_per_in_ler_id in number) is
  --
    select  pel.*
    from    ben_pil_elctbl_chc_popl pel
    where   pel.pl_id = p_pl_id
     and    pel.pgm_id is null
     and    pel.pil_elctbl_popl_stat_cd not in ('VOIDD','BCKDT')
     and    pel.per_in_ler_id = p_per_in_ler_id;
  --
 l_pel_pnip_defer c_pel_pnip_defer%ROWTYPE;
 l_defer_popl_id NUMBER;
 l_defer_popl_ovn NUMBER;

 type l_defer_deenrl_rec is record
  (pl_id               ben_pl_f.pl_id%type
  ,pgm_id              ben_pgm_f.pgm_id%type
  ,chc_exists          boolean
  ,newly_inelig_exists boolean
  );

  type l_defer_deenrl_table is table of l_defer_deenrl_rec
  index by binary_integer;

l_defer_deenrl_tbl l_defer_deenrl_table;
l_defer_count number := 0;

  --
-- Defer ENH.
begin
  --
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_package :=g_package||'.process_comp_objects';
    hr_utility.set_location ('Entering '||l_package,10);
  end if;
  --
  -- Start -  Added by Gopal Venkataraman 3/27/01 bug 1636071
  -- also changed all following p_mode to l_mode.
  l_mode := nvl(ben_manage_life_events.g_modified_mode,p_mode);
  l_defer_deenrl_tbl.delete;
  -- End
  dbms_session.free_unused_user_memory;
  --
  -- ben_prtt_enrt_result_api.g_enrollment_change := FALSE; -- VP 11/08/00
  -- p_mode changed to l_mode in following line by Gopal Venkataraman 3/27/01 bug 1636071
  if l_mode not in ('A','P','S','T') then
    -- p_mode changed to l_mode in following line by Gopal Venkataraman 3/27/01 bug 1636071
    if g_debug then
      hr_utility.set_location('mode'||l_mode,11);
    end if;
    --
    -- p_mode changed to l_mode in following line by Gopal Venkataraman 3/27/01 bug 1636071
    if (l_mode = 'U'or l_mode = 'R' or l_mode = 'D') then
     --
     if l_mode <> 'D' then
      benutils.get_active_life_event
      (p_person_id         => p_person_id,
       p_business_group_id => p_business_group_id,
       p_effective_date    => p_effective_date,
       p_lf_event_mode   =>  'U',
       p_rec               => l_rec);
      --
     else
      --
      benutils.get_active_life_event
      (p_person_id         => p_person_id,
       p_business_group_id => p_business_group_id,
       p_effective_date    => p_effective_date,
       p_lf_event_mode   =>  'D',
       p_rec               => l_rec);
     --
    end if;
     --
       benutils.get_active_life_event
       (p_person_id         => p_person_id,
        p_business_group_id => p_business_group_id,
        p_effective_date    => p_effective_date,
        p_rec               => l_lf_rec);

    --
    else
      --
      -- CWB Changes .
      --
     if l_mode = 'W' then
       --
       benutils.get_active_life_event
      (p_person_id             => p_person_id,
       p_business_group_id     => p_business_group_id,
       p_effective_date        => p_effective_date,
       p_lf_evt_ocrd_dt        => p_lf_evt_ocrd_dt,
       p_ler_id                => p_ler_id,
       p_rec                   => l_rec);
      --
     elsif l_mode = 'G' then
      --
      benutils.get_active_life_event
      (p_person_id         => p_person_id,
       p_business_group_id => p_business_group_id,
       p_effective_date    => p_effective_date,
       p_lf_event_mode   => 'G',
       p_rec               => l_rec);
      --
     elsif l_mode = 'M' then
      --
      benutils.get_active_life_event
      (p_person_id         => p_person_id,
       p_business_group_id => p_business_group_id,
       p_effective_date    => p_effective_date,
       p_lf_event_mode   => 'M',
       p_rec               => l_rec);
      --
    elsif l_mode = 'I' then
      --
      -- iRec
      benutils.get_active_life_event
      (p_person_id         => p_person_id,
       p_business_group_id => p_business_group_id,
       p_effective_date    => p_effective_date,
       p_lf_event_mode     => 'I',
       p_rec               => l_rec);
      --
     else
       --
       benutils.get_active_life_event
       (p_person_id         => p_person_id,
        p_business_group_id => p_business_group_id,
        p_effective_date    => p_effective_date,
        p_rec               => l_rec);
       --
     end if;
     --
    end if;
    if g_debug then
      hr_utility.set_location('Current OVN '||l_rec.object_version_number,10);
      hr_utility.set_location('lf evt date '||l_rec.lf_evt_ocrd_dt,11);
    end if;
  end if;
  --
  -- Setup environment for person being processed.
  --
  if g_debug then
    hr_utility.set_location (l_package||' Set env ',20);
  end if;
  ben_env_object.setenv(p_lf_evt_ocrd_dt => l_rec.lf_evt_ocrd_dt);
  --
  -- Clear eligibility caches
  --
  ben_pep_cache.clear_down_cache;
  ben_epe_cache.clear_down_cache;
  --
  dt_fndate.change_ses_date
    (p_ses_date => nvl(l_rec.lf_evt_ocrd_dt,p_effective_date)
    ,p_commit   => l_commit
    );
  --
  -- Get environment values
  --
  ben_env_object.get
    (p_rec => l_env
    );
  --
  -- Get person info
  --
  ben_person_object.get_object
    (p_person_id => p_person_id
    ,p_rec       => l_per_row
    );
  --
  ben_person_object.get_object
    (p_person_id => p_person_id
    ,p_rec       => l_empasg_row
    );
  --
  if l_empasg_row.assignment_id is not null then
    --
    ben_person_object.get_object
      (p_assignment_status_type_id => l_empasg_row.assignment_status_type_id
      ,p_rec                       => l_empasgast_row
      );
    --
  end if;
  --
  ben_person_object.get_benass_object
    (p_person_id => p_person_id
    ,p_rec       => l_benasg_row
    );
  --
  if l_benasg_row.assignment_id is not null then
    --
    ben_person_object.get_object
      (p_assignment_status_type_id => l_benasg_row.assignment_status_type_id
      ,p_rec                       => l_benasgast_row
      );
    --
  end if;
  --
  -- If benefit assignment not found, get applicant assignment.
  --
  if l_benasg_row.assignment_id is null then
    --
    ben_person_object.get_object
      (p_person_id => p_person_id
      ,p_rec       => l_appasg_row
      );
    --
  end if;
   -- bug 6491682

  if l_mode = 'S' then

    open c_get_unres_per_in_ler;
    fetch c_get_unres_per_in_ler into l_get_unres_per_in_ler;
    close c_get_unres_per_in_ler;

  end if;

  -- bug 6491682
  --
  -- Fixes WWBUG 1412808.
  -- In case a backout has occurred that uses communications we need to
  -- reset the cache for ther person life event object
  --
  ben_person_object.g_cache_last_pil_rec := l_pil_row;
  ben_person_object.g_cache_pil_rec.delete;
  --
  -- bug 6491682 - For mode S, passed the per_in_ler_id derived by cursor c_get_unres_per_in_ler

  if l_mode = 'S' then

    ben_person_object.get_object
      (p_person_id => p_person_id
  --  unrestricted  change
      ,p_per_in_ler_id => l_get_unres_per_in_ler.per_in_ler_id
      ,p_rec       => l_pil_row
      );

  else
  ben_person_object.get_object
    (p_person_id => p_person_id
--  unrestricted  change
    ,p_per_in_ler_id =>l_rec.per_in_ler_id
    ,p_rec       => l_pil_row
    );
  end if;
  --
  if g_debug then
    hr_utility.set_location ('Life event occured datee'||l_pil_row.lf_evt_ocrd_dt,11);
  end if;
  -- Assign comp object cache to a local variable
  --
  l_comp_obj_tree  := g_cache_proc_object;
  --
  -- Flush duplicate ptip list
  --
  ben_comp_obj_filter.flush_dupproc_ptip_list;
  --
  l_treeele_num    := l_comp_obj_tree.first;
  l_treeloop       := TRUE;
  l_maxtreeele_num := l_comp_obj_tree.last;
  --
  -- If we are running in temporal mode then we may only want to
  -- create certain temporal events so set the temporal ler id we
  -- want to test
  --
  -- p_mode changed to l_mode in following line by Gopal Venkataraman 3/27/01 bug 1636071
  --
  ben_derive_part_and_rate_facts.g_no_ptnl_ler_id := null ;
  --
  if l_mode = 'T' then
    --
    ben_derive_part_and_rate_facts.g_temp_ler_id  := p_ler_id;
    --
  else
    --
    --For unrestricted enrollment we dont want to trigger the pdpar potentials
    --Also don't trigger potentials for the following modes
    --
    if l_mode in ('U','W','M','I','P','A','D') then
      ben_derive_part_and_rate_facts.g_no_ptnl_ler_id := p_ler_id ;
    end if;
    --
    -- Globals are kept for a session so reset the global in the package
    --
    ben_derive_part_and_rate_facts.g_temp_ler_id  := null;
    --
  end if;
  --
  --GSP: do not need to evaluate eligibility for entire comp object list
  --
  if l_mode ='G' then
     /* GSP Rate Sync
     *  The following function fetches current Grade Ladder and Grade for a person being processed
     *  If the person does not have any assigned grade ladder or grade, then default grade ladder and grade
     *  for the business group are returned. In case of GSP Rate Sync, always current (assigned) Grade Ladder and Grade
     *  will be returned because GSP Rate Sync process will reach here only if person has GSP Prog processed once
     *  in the past.
     */
     get_grade_step_placement
          (p_person_id          => p_person_id,
           p_assignment_id      => l_empasg_row.assignment_id,
           p_business_group_id  => p_business_group_id,
           p_effective_date     => p_effective_date,
           p_gsp_pgm_id         => l_gsp_pgm_id,
           p_gsp_plip_id        => l_gsp_plip_id,
           p_gsp_oipl_id        => l_gsp_oipl_id,
           p_prgr_style         => l_prgr_style,
           p_gsp_emp_step_id    => l_gsp_emp_step_id,
           p_gsp_num_incr       => l_gsp_num_incr);
     /*
     pqh_gsp_post_process.get_persons_gl_and_grade
     (p_person_id            => p_person_id,
      p_business_group_id    => p_business_group_id,
      p_effective_date       => p_effective_date,
      p_persons_pgm_id       => l_gsp_pgm_id,
      p_persons_plip_id      => l_gsp_plip_id,
      p_prog_style           => l_prgr_style);
     */
     if g_debug then
        hr_utility.set_location('p_persons_pgm_id :'||l_gsp_pgm_id,20);
        hr_utility.set_location('p_persons_plip_id :'||l_gsp_plip_id,20);
        hr_utility.set_location('p_prog_style :'||l_prgr_style,20);
        hr_utility.set_location('l_gsp_oipl_id :' || l_gsp_oipl_id,20);
     end if;
     --
     -- no grade ladder defined (or) no grade, then skip the person
     --
     if l_gsp_pgm_id is null or
        l_gsp_plip_id is null
     then
        hr_utility.set_location('Current GSP Grade Ladder / Grade / PLIP for person not found', 15);
        fnd_message.set_name('BEN','BEN_94094_PERSON_GRADE_NOT_FND');
        raise g_record_error;
     elsif l_prgr_style not in ('PQH_GSP_GP') and l_gsp_oipl_id is null  /* Bug 3964719 */
     then
        hr_utility.set_location('Current GSP OIPL for person not found', 15);
        fnd_message.set_name('BEN','BEN_94095_PERSON_STEP_NOT_FND');
        raise g_record_error;
     end if;
     --
     open c_ptip_pl_id(l_gsp_pgm_id,l_gsp_plip_id);
       fetch c_ptip_pl_id into l_gsp_ptip_id,l_gsp_pl_id;
     close c_ptip_pl_id;
     --
     if l_prgr_style not in ('PQH_GSP_GP')
     then
       --
       open c_get_oiplip_opt_id(l_gsp_plip_id,l_gsp_oipl_id );
         fetch c_get_oiplip_opt_id into l_gsp_oiplip_id, l_gsp_opt_id;
       close c_get_oiplip_opt_id;
       --
     end if;
     --
     /*
     *  The following call will populate G_CACHE_PROC_OBJECT with the PGM_ID, PL_ID, PLIP_ID and OIPL_ID records
     *  corresponding to the current Grade / Step Placement of the person.
     */
     if p_lf_evt_oper_cd = 'SYNC'
     then
       --
       ben_comp_object_list.build_gsp_rate_sync_coobj_list
         (p_effective_date         => p_effective_date
         ,p_business_group_id      => p_business_group_id
         ,p_pgm_id                 => l_gsp_pgm_id
         ,p_pl_id                  => l_gsp_pl_id
         ,p_opt_id                 => l_gsp_opt_id
         ,p_plip_id                => l_gsp_plip_id
         ,p_ptip_id                => l_gsp_ptip_id
         ,p_oipl_id                => l_gsp_oipl_id
         ,p_oiplip_id              => l_gsp_oiplip_id
         ,p_person_id              => p_person_id
         ) ;
       --
       l_comp_obj_tree  := g_cache_proc_object;
       l_treeele_num    := l_comp_obj_tree.first;
       l_treeloop       := TRUE;
       l_maxtreeele_num := l_comp_obj_tree.last;
       --
     end if;
     --
  end if;
  --
  fnd_message.set_name('BEN','BEN_91333_CALLING_PROC');
  fnd_message.set_token('PROC','BEN_CARRY_FORWARD_ITEMS');
  --
  -- If the event is staying open, then delete the suspended enrollments
  -- and action items
  --
  if l_mode = 'L' or l_mode = 'C' then
    if p_ler_id is not null then
         --
         ben_carry_forward_items.main
         (p_effective_date => p_effective_date
         ,p_lf_evt_ocrd_dt => l_rec.lf_evt_ocrd_dt
         ,p_per_in_ler_id  => l_rec.per_in_ler_id
         ,p_ler_id  => p_ler_id
         ,p_business_group_id => p_business_group_id
         ,p_person_id => p_person_id);
        --
    end if;
  end if;
  --
  loop
    if g_debug then
      hr_utility.set_location (l_package||' Start Proc loop ',20);
    end if;
    --
    -- Comp object filtering. Navigate to the next comp object to be processed
    -- We do not need to filter in temporal mode because we do not check
    -- eligibility.
    --
    -- p_mode changed to l_mode in following line by Gopal Venkataraman 3/27/01 bug 1636071
    if l_mode <> 'T' then
      --
      if g_debug then
        hr_utility.set_location (l_package||' Filtering ',20);
      end if;
      -- Bug#1900657
      if l_mode in ('U','D') then
        if l_lf_rec.per_in_ler_id is not null then
          loop
            --
            open c_pil(l_lf_rec.per_in_ler_id,
                       l_comp_obj_tree(l_treeele_num).par_pgm_id,
                       l_comp_obj_tree(l_treeele_num).par_pl_id);
            fetch c_pil into l_pil;
            if c_pil%found then
              close c_pil;
              if l_treeele_num = l_maxtreeele_num then
                --
                l_treeloop := FALSE;
                exit;
                --
              else
                --
                l_treeele_num := l_treeele_num+1;
                --
              end if;
              --
            else
              close c_pil;
              exit;
            end if;
            --
          end loop;
          --
        end if;
        --
      end if;
      --
      if not l_treeloop then
         exit;
      end if;
      --
      -- GLOBALCWB : Bug 4214845 : All comp objects must be processed, in
      -- cwb mode as data have to be created with elig flag = N in case of in-eligibility.
      --
      if l_mode <> 'W' then
        --
        ben_comp_obj_filter.filter_comp_objects
        (p_comp_obj_tree         => l_comp_obj_tree
        -- p_mode changed to l_mode in following line by Gopal Venkataraman 3/27/01 bug 1636071
        ,p_mode                  => l_mode
        ,p_person_id             => p_person_id
        ,p_effective_date        => nvl(l_rec.lf_evt_ocrd_dt,p_effective_date)
        ,p_maxtreeele_num        => l_maxtreeele_num
        --
        ,p_par_elig_state        => l_par_elig_state
        ,p_treeele_num           => l_treeele_num
        --
        ,p_treeloop              => l_treeloop
        ,p_ler_id                => p_ler_id
        -- PB : 5422 :
        ,p_lf_evt_ocrd_dt        => p_lf_evt_ocrd_dt
        -- ,p_popl_enrt_typ_cycl_id => p_popl_enrt_typ_cycl_id
        ,p_business_group_id     => p_business_group_id
        );
        --
      end if;
      if g_debug then
        hr_utility.set_location (l_package||' Dn Filtering ',20);
      end if;
      --
    end if;
    --
    -- Check if the end of the comp object list was reached
    -- otherwise refresh environment globals. These globals
    -- are referenced in BENDETE2.
    --
    if not l_treeloop then
      --
      exit;
      --
    else
      --
      -- Reset locals to new tree location values
      --
      l_pgm_id            := l_comp_obj_tree(l_treeele_num).pgm_id;
      l_ptip_id           := l_comp_obj_tree(l_treeele_num).ptip_id;
      l_plip_id           := l_comp_obj_tree(l_treeele_num).plip_id;
      l_pl_id             := l_comp_obj_tree(l_treeele_num).pl_id;
      l_oipl_id           := l_comp_obj_tree(l_treeele_num).oipl_id;
      l_pl_nip            := l_comp_obj_tree(l_treeele_num).pl_nip;
      l_comp_obj_tree_row := l_comp_obj_tree(l_treeele_num);
      --
    end if;
    --

    -- bof  FONM  Determine whther the  pgm/pl set for FONM

   if g_debug then
     hr_utility.set_location ('OIpl Id '||l_oipl_id,31);
     hr_utility.set_location (' l_pl_nip ' || l_pl_nip,30);
     hr_utility.set_location (' g_last_pgm_id ' || g_last_pgm_id,30);
     hr_utility.set_location (' l_last_ptip_id ' || l_last_ptip_id,30);
     hr_utility.set_location (' pgm ' ||l_comp_obj_tree(l_treeele_num).par_pgm_id ,30);
     hr_utility.set_location (' ptip ' ||l_comp_obj_tree(l_treeele_num).par_ptip_id ,30);
     hr_utility.set_location (' pl ' ||l_comp_obj_tree(l_treeele_num).par_pl_id ,30);
     hr_utility.set_location (' plip ' ||l_comp_obj_tree(l_treeele_num).par_plip_id ,30);
     hr_utility.set_location ('Old fonm ' ||ben_manage_life_events.fonm ,30);
     hr_utility.set_location ('Old pgm fonm ' || l_pgm_fonm ,30);
     hr_utility.set_location ('Old ptip fonm ' || l_ptip_fonm ,30);
   end if;
   -- FONM II
   if l_pl_nip = 'Y'
         -- whne the new program
      or (  nvl(g_last_pgm_id,-1) <>  l_comp_obj_tree(l_treeele_num).par_pgm_id )
         -- if the pgm level fonm determined as no  then dont look below
         -- and if there is ptip then look @ ptip , there can be one ptip fonm other non fonm
         -- that case pgm is allways FONM
      or (  nvl(g_last_pgm_id,-1) =  l_comp_obj_tree(l_treeele_num).par_pgm_id and
            l_pgm_fonm  = 'Y'  and l_ptip_fonm is  null
          )
         -- new ptip
         -- when the pgm is fonm then validate for ptip fonm
      or ( l_pgm_fonm  = 'Y'  and
           (  l_ptip_fonm   =  'Y' or nvl(l_last_ptip_id,-1) <>  l_comp_obj_tree(l_treeele_num).par_ptip_id
           )
         )
      or ben_manage_life_events.fonm is null then

            hr_utility.set_location (' calling  fonm status  ' ,30);
            ben_use_cvg_rt_date.get_csd_rsd_Status
                                   (p_pgm_id         => l_comp_obj_tree(l_treeele_num).par_pgm_id
                                   ,p_ptip_id        => l_comp_obj_tree(l_treeele_num).par_ptip_id
                                   ,p_plip_id        => l_comp_obj_tree(l_treeele_num).par_plip_id
                                   ,p_pl_id          => l_comp_obj_tree(l_treeele_num).par_pl_id
                                   ,p_effective_date => p_effective_date
                                   ,p_status         => ben_manage_life_events.fonm
                                   ) ;
             hr_utility.set_location (' fonm ' ||ben_manage_life_events.fonm ,30);
   end if ;
   -- eof FONM

    -- Set up environment for retrieval of comp object information
    --
    if l_pl_nip = 'Y' then
      --
      g_last_pgm_id := null;
      --
    elsif l_comp_obj_tree(l_treeele_num).par_pgm_id is not null then
      --
      g_last_pgm_id := l_comp_obj_tree(l_treeele_num).par_pgm_id;

      hr_utility.set_location (' fonm ptip ' || l_comp_obj_tree(l_treeele_num).par_ptip_id ,30);

      if l_comp_obj_tree(l_treeele_num).par_ptip_id is not null then
         l_last_ptip_id := l_comp_obj_tree(l_treeele_num).par_ptip_id ;
         hr_utility.set_location (' fonm plip ' ||l_comp_obj_tree(l_treeele_num).par_plip_id ,30);
         -- if the plip is null then the fonm for ptio
         if l_comp_obj_tree(l_treeele_num).par_plip_id is  null then

            l_ptip_fonm := ben_manage_life_events.fonm ;
         end if ;
      else
         l_pgm_fonm     := ben_manage_life_events.fonm ;
         l_ptip_fonm    := null ;
      end if ;
      --
    end if;
    --
    -- Check if the audit log flag is on
    --
    if g_debug then
      hr_utility.set_location (l_package||' get_comp_object_name ',30);
    end if;
    if l_env.audit_log_flag = 'Y' then
      --
      get_comp_object_name
        (p_oipl_id           => l_oipl_id
        ,p_pgm_id            => l_pgm_id
        ,p_pl_id             => l_pl_id
        ,p_plip_id           => l_plip_id
        ,p_ptip_id           => l_ptip_id
        ,p_pl_nip            => l_pl_nip
        ,p_comp_object_name  => l_comp_object_name
        ,p_comp_object_value => l_comp_object_value
        );
      --
      g_output_string := rpad(l_comp_object_value,21,' ')||rpad(l_comp_object_name,30,' ');
    end if;

    l_evaluate_eligibility := true;

    if l_mode ='G' then

/*      l_evaluate_eligibility := (l_comp_obj_tree_row.par_pgm_id = l_gsp_pgm_id)
                                and
                                (    (nvl(l_prgr_style,'PQH_GSP_SP') <> 'PQH_GSP_SP')
                                  or (     l_comp_obj_tree_row.par_ptip_id = l_gsp_ptip_id
                                       and nvl(l_comp_obj_tree_row.par_plip_id,l_gsp_plip_id) = l_gsp_plip_id
                                       and nvl(l_comp_obj_tree_row.par_pl_id,l_gsp_pl_id) = l_gsp_pl_id
                                      )
                                );
*/
      l_evaluate_eligibility :=  ( (nvl(l_prgr_style,'PQH_GSP_SP') = 'PQH_GSP_SP' )
                                   and
				   ( l_comp_obj_tree_row.par_pgm_id = l_gsp_pgm_id
				     and nvl(l_comp_obj_tree_row.par_ptip_id,l_gsp_ptip_id) = l_gsp_ptip_id
                                     and nvl(l_comp_obj_tree_row.par_plip_id,l_gsp_plip_id) = l_gsp_plip_id
                                     and nvl(l_comp_obj_tree_row.par_pl_id,l_gsp_pl_id) = l_gsp_pl_id )
				  or
				   ( nvl(l_prgr_style,'PQH_GSP_SP') <> 'PQH_GSP_SP' )
                                       and ( l_comp_obj_tree_row.par_pgm_id = l_gsp_pgm_id )
				   );

      if g_debug then
         if l_evaluate_eligibility then
            hr_utility.set_location('Processing '||l_comp_obj_tree_row.par_pgm_id||','||l_comp_obj_tree_row.par_ptip_id||','||l_comp_obj_tree_row.par_plip_id||','||l_comp_obj_tree_row.par_pl_id||','||l_oipl_id,80);
         else
            hr_utility.set_location('Skipping '||l_comp_obj_tree_row.par_pgm_id||','||l_comp_obj_tree_row.par_ptip_id||','||l_comp_obj_tree_row.par_plip_id||','||l_comp_obj_tree_row.par_pl_id||','||l_oipl_id,80);
         end if;
      end if;

    end if;

    /* GSP Rate Sync */
    if p_mode = 'G' and p_lf_evt_oper_cd = 'SYNC' and p_gsp_eval_elig_flag = 'N'
    then
      --
      /* GSP Rate Sync :
      *  If Evaluate Eligibility is No, then do not go through evaluate eligibility process
      *  If Evaluate Eligibility is Yes, then through evaluate eligibility process for current
      *                                  grade ladder, grade and step
      *  Make a call to PQHGSP package, that will create electable choices and rates.
      */
      hr_utility.set_location('GSP Rate Sync Do Not Evaluate Eligibility', 45);
      hr_utility.set_location('GSPRS p_effective_date = ' || p_effective_date, 45);
      hr_utility.set_location('GSPRS l_pil_row.per_in_ler_id = ' || l_pil_row.per_in_ler_id, 45);
      hr_utility.set_location('GSPRS p_person_id = ' || p_person_id, 45);
      hr_utility.set_location('GSPRS l_empasg_row.assignment_id = ' || l_empasg_row.assignment_id, 45);
      --

      -- This procedure will create Electable Choices and Rates
      pqh_gsp_post_process.gsp_rate_sync
        (p_effective_date     => p_effective_date
        ,p_per_in_ler_id      => l_pil_row.per_in_ler_id
        ,p_person_id          => p_person_id
        ,p_assignment_id      => l_empasg_row.assignment_id
        );

      -- This procedure will update salary if at all new salary has changed from current salary
      pqh_gsp_post_process.update_rate_sync_salary
         (p_per_in_ler_id   => l_pil_row.per_in_ler_id
         ,p_effective_date  => p_effective_date
         );

      --
      p_person_count := p_person_count +1;
      --
      g_action_rec.person_action_id := p_person_action_id;
      g_action_rec.action_status_cd := 'P';
      g_action_rec.ler_id := p_ler_id;
      g_action_rec.object_version_number := p_object_version_number;
      g_action_rec.effective_date := p_effective_date;
      --
      benutils.write(p_rec => g_action_rec);
      --
      return;
      --
    elsif l_evaluate_eligibility
    then

      --
      -- Set up participation eligibility
      --
      if g_debug then
         hr_utility.set_location (l_package||' Set Part Elig  ',80);
      end if;
      --
      -- Set up comp object context rows
      --
      -- p_mode changed to l_mode in following line by Gopal Venkataraman 3/27/01 bug 1636071
      if l_mode <> 'T' then
        --
        set_up_cobj_part_elig
        (p_comp_obj_tree_row => l_comp_obj_tree_row
        ,p_ler_id            => p_ler_id
        ,p_business_group_id => p_business_group_id
        -- Bug 3087889 Passing lf_evt_ocrd_dt
      	,p_effective_date        => nvl(l_rec.lf_evt_ocrd_dt,p_effective_date)
        -- End of Bug 3087889
          );
        --
      end if;
      --
      if l_mode in ('L', 'C', 'A') then
       --
       g_defer_deenrol_flag := 'N';
       --
	 if  l_mode in  ('L') then

              open  c_lee_rsn(c_pl_id => l_comp_obj_tree(l_treeele_num).par_pl_id,
                        c_pgm_id=> l_comp_obj_tree(l_treeele_num).par_pgm_id,
                        c_effective_date => nvl(l_rec.lf_evt_ocrd_dt, p_effective_date)
                        ) ;
              fetch c_lee_rsn into l_dummy , l_rec_lee_rsn_id ,g_defer_deenrol_flag ;
              close  c_lee_rsn  ;

         elsif l_mode in ( 'C' , 'A') then
              open  c_enrt_perd_id(c_pl_id => l_comp_obj_tree(l_treeele_num).par_pl_id,
                        c_pgm_id=> l_comp_obj_tree(l_treeele_num).par_pgm_id,
                        c_effective_date => nvl(l_rec.lf_evt_ocrd_dt, p_effective_date)
                        ) ;
              fetch c_enrt_perd_id into l_dummy ,l_rec_enrt_perd_id ,g_defer_deenrol_flag  ;
              close c_enrt_perd_id ;
        --
	end if ;
      --
    end if;
     --
    if g_debug then
      hr_utility.set_location(' g_defer_deenrol_flag' || g_defer_deenrol_flag, 9653);
    end if;
      hr_utility.set_location (' FONM : ' || ben_manage_life_events.fonm  ,80);
      -- BOF  FONM
    if  l_mode in ('L','C') and -- Bug 6390880
        ben_manage_life_events.fonm = 'Y'   then

           hr_utility.set_location (' FONM : Begin  ',80);
            hr_utility.set_location(' l_pgm_id = ' || l_pgm_id, 4444);
            hr_utility.set_location(' l_pl_id = ' || l_pl_id, 4444);
            hr_utility.set_location(' l_oipl_id = ' || l_oipl_id, 4444);
            hr_utility.set_location(' l_ptip_id = ' || l_ptip_id, 4444);
            hr_utility.set_location(' l_plip_id = ' || l_plip_id, 4444);
          if g_debug then
            hr_utility.set_location('p_pgm_id'||l_comp_obj_tree(l_treeele_num).par_pgm_id,1234);
            hr_utility.set_location('p_pl_id'||l_comp_obj_tree(l_treeele_num).par_pl_id,1234);
            hr_utility.set_location('p_plip_id'||l_comp_obj_tree(l_treeele_num).par_plip_id,1234);
            hr_utility.set_location('p_ptip_id'||l_comp_obj_tree(l_treeele_num).par_ptip_id,1234);
            hr_utility.set_location('p_oipl_id'||l_oipl_id,1234);
          end if;

       /*   if  l_mode in  ('L') then

              open  c_lee_rsn(c_pl_id => l_comp_obj_tree(l_treeele_num).par_pl_id,
                        c_pgm_id=> l_comp_obj_tree(l_treeele_num).par_pgm_id,
                        c_effective_date => nvl(l_rec.lf_evt_ocrd_dt, p_effective_date)
                        ) ;
              fetch c_lee_rsn into l_dummy , l_rec_lee_rsn_id ;
              close  c_lee_rsn  ;

          elsif l_mode in ( 'C' , 'A') then
              open  c_enrt_perd_id(c_pl_id => l_comp_obj_tree(l_treeele_num).par_pl_id,
                        c_pgm_id=> l_comp_obj_tree(l_treeele_num).par_pgm_id,
                        c_effective_date => nvl(l_rec.lf_evt_ocrd_dt, p_effective_date)
                        ) ;
              fetch c_enrt_perd_id into l_dummy ,l_rec_enrt_perd_id  ;
              close c_enrt_perd_id ;


          end if ;*/
          hr_utility.set_location(' l_rec_lee_rsn_id ' || l_rec_lee_rsn_id, 99 );
          hr_utility.set_location(' c_enrt_perd_id '   || l_rec_enrt_perd_id , 99 );
          hr_utility.set_location(' p_ler_id  '   || p_ler_id , 99 );
          hr_utility.set_location(' p_pgm_id  '   || l_comp_obj_tree(l_treeele_num).par_pgm_id , 99 );
          hr_utility.set_location(' p_pl_id  '   || l_comp_obj_tree(l_treeele_num).par_pl_id , 99 );
          hr_utility.set_location(' p_ptip  '   ||  l_comp_obj_tree(l_treeele_num).par_ptip_id , 99 );
          hr_utility.set_location(' p_plip  '   ||  l_comp_obj_tree(l_treeele_num).par_plip_id , 99 );
          hr_utility.set_location(' p_oipl  '   ||  l_oipl_id , 99 );

           ben_determine_date.rate_and_coverage_dates
             (p_cache_mode          => TRUE
             ,p_per_in_ler_id       => l_rec.per_in_ler_id
             ,p_person_id           => p_person_id
             ,p_pgm_id              => l_comp_obj_tree(l_treeele_num).par_pgm_id
             ,p_pl_id               => l_comp_obj_tree(l_treeele_num).par_pl_id
             ,p_oipl_id             => l_oipl_id
             ,p_par_ptip_id         => l_comp_obj_tree(l_treeele_num).par_ptip_id
             ,p_par_plip_id         => l_comp_obj_tree(l_treeele_num).par_plip_id
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
             ,p_lf_evt_ocrd_dt      => nvl(l_rec.lf_evt_ocrd_dt, p_effective_date)
             );
           hr_utility.set_location('l_rec_enrt_cvg_strt_dt = ' || l_rec_enrt_cvg_strt_dt, 4444);
           hr_utility.set_location('l_dummy_rt_strt_dt = ' || l_dummy_rt_strt_dt, 4444);
           hr_utility.set_location('l_dummy_rt_strt_dt_cd = ' || l_dummy_rt_strt_dt_cd, 4444);
           hr_utility.set_location('l_dummy_rt_strt_dt_rl = ' || l_dummy_rt_strt_dt_rl, 4444);
           hr_utility.set_location('l_dummy_enrt_cvg_end_dt = ' || l_dummy_enrt_cvg_end_dt, 4444);
           hr_utility.set_location('l_dummy_enrt_cvg_end_dt_cd = ' || l_dummy_enrt_cvg_end_dt_cd, 4444);
           hr_utility.set_location('l_dummy_enrt_cvg_end_dt_rl = ' || l_dummy_enrt_cvg_end_dt_rl, 4444);
           hr_utility.set_location('l_dummy_rt_end_dt = ' || l_dummy_rt_end_dt, 4444);
           hr_utility.set_location('l_dummy_rt_end_dt_cd = ' || l_dummy_rt_end_dt_cd, 4444);
           hr_utility.set_location('l_dummy_rt_end_dt_rl = ' || l_dummy_rt_end_dt_rl, 4444);
           --
           -- If previous cvg start date and current date is different then
           -- clear the caches.
           --
           if nvl(l_fonm_cvg_strt_dt, hr_api.g_sot) <>
              l_rec_enrt_cvg_strt_dt
           then
             --
             hr_utility.set_location('clearing cache bnmngle '||l_fonm_cvg_strt_dt || '  / ' || l_rec_enrt_cvg_strt_dt  ,10);
             ben_use_cvg_rt_date.fonm_clear_down_cache;
             --
           end if;
           --
           ben_manage_life_events.g_fonm_cvg_strt_dt := l_rec_enrt_cvg_strt_dt ;
           l_fonm_cvg_strt_dt := l_rec_enrt_cvg_strt_dt ;
           --
           hr_utility.set_location(' g_fonm_cvg_strt_dt '||g_fonm_cvg_strt_dt,110);
           --
      end if;
        --
      -- EOF  FONM
      if g_debug then
        hr_utility.set_location (l_package||' FND Mess  ',80);
        hr_utility.set_location ('p_derivable_factors '||p_derivable_factors,80);
      end if;
      l_comp_rec:=l_d_comp_rec;
      l_oiplip_rec:=l_d_oiplip_rec;
       --
      if p_derivable_factors <> 'NONE' then
        --
        if g_debug then
          hr_utility.set_location (l_package||' fnd_message_call ',30);
        end if;
        fnd_message.set_name('BEN','BEN_91333_CALLING_PROC');
        fnd_message.set_token('PROC','ben_derive_part_and_rate_facts');
        if g_debug then
          hr_utility.set_location (l_package||' done fnd_message_call ',30);
          hr_utility.set_location (l_package||' DRAF ',15);
        end if;
        ben_derive_part_and_rate_facts.derive_rates_and_factors
          (p_comp_obj_tree_row         => l_comp_obj_tree_row
          --
          ,p_per_row                   => l_per_row
          ,p_empasg_row                => l_empasg_row
          ,p_benasg_row                => l_benasg_row
          ,p_pil_row                   => l_pil_row
          --
          -- p_mode changed to l_mode in following line by Gopal Venkataraman 3/27/01 bug 1636071
          ,p_mode                      => l_mode
          --
          ,p_person_id                 => p_person_id
          ,p_business_group_id         => p_business_group_id
          ,p_pgm_id                    => l_pgm_id
          ,p_pl_id                     => l_pl_id
          ,p_oipl_id                   => l_oipl_id
          ,p_plip_id                   => l_plip_id
          ,p_ptip_id                   => l_ptip_id
          ,p_ptnl_ler_trtmt_cd         => l_rec.ptnl_ler_trtmt_cd
          ,p_derivable_factors         => p_derivable_factors
          ,p_comp_rec                  => l_comp_rec
          ,p_oiplip_rec                => l_oiplip_rec
        --  ,p_effective_date            => p_effective_date
          ,p_effective_date           => least(p_effective_date, nvl(l_rec.lf_evt_ocrd_dt,p_effective_date))
          ,p_lf_evt_ocrd_dt            => nvl(l_rec.lf_evt_ocrd_dt,p_effective_date)
          );
        if g_debug then
          hr_utility.set_location (l_package||' Done DRAF ',15);
        end if;
        --
      else
        --
        -- Derive factor direct from the previous eligibility records.
        --
        if g_debug then
          hr_utility.set_location (l_package||' Ass Der facts  ',50);
        end if;
        --
        ben_derive_part_and_rate_facts.cache_data_structures
          (p_comp_obj_tree_row => l_comp_obj_tree_row
          --
          ,p_empasg_row        => l_empasg_row
          ,p_benasg_row        => l_benasg_row
          ,p_pil_row           => l_pil_row
          --
          ,p_business_group_id => p_business_group_id
          ,p_person_id         => p_person_id
          ,p_pgm_id            => l_pgm_id
          ,p_pl_id             => l_pl_id
          ,p_oipl_id           => l_oipl_id
          ,p_plip_id           => l_plip_id
          ,p_ptip_id           => l_ptip_id
          ,p_comp_rec          => l_comp_rec
          ,p_oiplip_rec        => l_oiplip_rec
          ,p_effective_date    => p_effective_date);
        --
      end if;
      --
      -- p_mode changed to l_mode in following line by Gopal Venkataraman 3/27/01 bug 1636071
      if l_mode not in ('R','T') then
        --
        fnd_message.set_name('BEN','BEN_91333_CALLING_PROC');
        fnd_message.set_token('PROC','ben_determine_eligibility');
        if g_debug then
          hr_utility.set_location (l_package||' Dn FND Mess  ',80);
        end if;
        --
        -- Initialise the dependent eligibility related globals.
        -- They should be initialised for every comp object.
        -- All these globals are used in bendepen.pkb.
        --
        ben_determine_dpnt_eligibility.g_egd_table.delete;
        ben_determine_dpnt_eligibility.g_egd_table :=
                                 ben_determine_dpnt_eligibility.g_egd_table_temp;
        --
        if g_debug then
          hr_utility.set_location (l_package||' BENDETEL  ',80);
        end if;
        --
        ben_determine_eligibility.determine_elig_prfls
          (p_comp_obj_tree_row         => l_comp_obj_tree_row
          ,p_par_elig_state            => l_par_elig_state
          --
          ,p_per_row                   => l_per_row
          ,p_empasg_row                => l_empasg_row
          ,p_benasg_row                => l_benasg_row
          ,p_appasg_row                => l_appasg_row
          ,p_empasgast_row             => l_empasgast_row
          ,p_benasgast_row             => l_benasgast_row
          ,p_pil_row                   => l_pil_row
          --
          ,p_person_id                 => p_person_id
          ,p_business_group_id         => p_business_group_id
          ,p_effective_date            => p_effective_date
          ,p_lf_evt_ocrd_dt            => l_rec.lf_evt_ocrd_dt
          ,p_pl_id                     => l_pl_id
          ,p_pgm_id                    => l_pgm_id
          ,p_oipl_id                   => l_oipl_id
          ,p_plip_id                   => l_plip_id
          ,p_ptip_id                   => l_ptip_id
          ,p_ler_id                    => p_ler_id
          ,p_comp_rec                  => l_comp_rec
          ,p_oiplip_rec                => l_oiplip_rec
          --
          ,p_eligible                  => l_eligible
          ,p_not_eligible              => l_not_eligible
          --
          ,p_newly_elig                => l_newly_elig
          ,p_newly_inelig              => l_newly_inelig
          ,p_first_elig                => l_first_elig
          ,p_first_inelig              => l_first_inelig
          ,p_still_elig                => l_still_elig
          ,p_still_inelig              => l_still_inelig
          );
        if g_debug then
          hr_utility.set_location (l_package||' Done BENDETEL  ',85);
        end if;
        --
        -- Bug 5232223
        --
        if l_not_eligible and l_mode = 'W'
           and ben_manage_cwb_life_events.g_cache_group_plan_rec.trk_inelig_per_flag = 'N'
           and l_oipl_id is null and l_pl_id is not null
--           and fnd_global.conc_request_id > 0    /* Bug 8290746 */
        then
          --
          --  No need to write the data.
          --
          raise g_cwb_trk_ineligible;
          --
        end if;
        --
        -- Set comp object parent eligibility flags
        --
        if l_eligible then
          --
          ben_comp_obj_filter.set_parent_elig_flags
            (p_comp_obj_tree_row => l_comp_obj_tree_row
            ,p_eligible          => TRUE
            ,p_treeele_num       => l_treeele_num
            --
            ,p_par_elig_state    => l_par_elig_state
            );
          --
          if g_debug then
            hr_utility.set_location('p_pgm_id'||l_comp_obj_tree(l_treeele_num).par_pgm_id,1234);
            hr_utility.set_location('p_pl_id'||l_comp_obj_tree(l_treeele_num).par_pl_id,1234);
            hr_utility.set_location('p_plip_id'||l_comp_obj_tree(l_treeele_num).par_plip_id,1234);
            hr_utility.set_location('p_ptip_id'||l_comp_obj_tree(l_treeele_num).par_ptip_id,1234);
            hr_utility.set_location('p_oipl_id'||l_oipl_id,1234);
          end if;
          --
          -- Don't run enrolment_requirements for levels other than plan and oipl.
          -- Don't run it if the ler_id is null.
          --
          if (l_pl_id is not null
              or l_oipl_id is not null)
            and p_ler_id is not null
            and not nvl(l_first_inelig, FALSE)
            and not nvl(l_still_inelig, FALSE)
            --
            -- CWB Changes.ABSENCES, GRADE/STEP avoid dependent eligibility
            -- added irec
            and l_mode not in ( 'W', 'M', 'G','I','D')
          then
            --
            --
            -- Task 131 : Eligible dependent rows are already created.
            -- Now update them with electable choice id.
            --
            if g_debug then
              hr_utility.set_location (l_package||' St BENDEPEN  ',85);
            end if;
            ben_determine_dpnt_eligibility.main
              (p_pgm_id            => l_comp_obj_tree(l_treeele_num).par_pgm_id
              ,p_pl_id             => l_comp_obj_tree(l_treeele_num).par_pl_id
              ,p_plip_id           => l_comp_obj_tree(l_treeele_num).par_plip_id
              ,p_ptip_id           => l_comp_obj_tree(l_treeele_num).par_ptip_id
              ,p_oipl_id           => l_oipl_id
              ,p_pl_typ_id         => null
              ,p_business_group_id => p_business_group_id
              ,p_person_id         => p_person_id
              ,p_effective_date    => p_effective_date
              ,p_per_in_ler_id     => l_rec.per_in_ler_id
              ,p_elig_per_id       => l_comp_obj_tree_row.elig_per_id
              ,p_elig_per_opt_id   => l_comp_obj_tree_row.elig_per_opt_id
              ,p_lf_evt_ocrd_dt    => l_rec.lf_evt_ocrd_dt
              );
            if g_debug then
              hr_utility.set_location (l_package||' Dn BENDEPEN  ',85);
            end if;
             --
          end if;
          --
        elsif l_not_eligible then
          --
          ben_comp_obj_filter.set_parent_elig_flags
            (p_comp_obj_tree_row => l_comp_obj_tree_row
            ,p_eligible          => FALSE
            ,p_treeele_num       => l_treeele_num
            --
            ,p_par_elig_state    => l_par_elig_state
            );
          --
        end if;
        --
        if l_first_inelig then
          --
          --l_elig_state_change := true;
          l_comp_obj_tree(l_treeele_num).elig_tran_state := 'FT_INELIG';
          --
        elsif l_still_inelig then
          --
          l_comp_obj_tree(l_treeele_num).elig_tran_state := 'ST_INELIG';
          --
        elsif l_newly_inelig then
          --
          l_elig_state_change := true;
          l_comp_obj_tree(l_treeele_num).elig_tran_state := 'NW_INELIG';
          --
        elsif l_first_elig then
          --
          l_comp_obj_tree(l_treeele_num).elig_tran_state := 'FT_ELIG';
          --
        elsif l_still_elig then
          --
          l_comp_obj_tree(l_treeele_num).elig_tran_state := 'ST_ELIG';
          --
        elsif l_newly_elig then
          --
          l_elig_state_change := true;
          l_comp_obj_tree(l_treeele_num).elig_tran_state := 'NW_ELIG';
          --
        end if;
        --
      end if;
    end if;
    --
    -- p_mode changed to l_mode in following line by Gopal Venkataraman 3/27/01 bug 1636071
    if l_mode not in ('R','T') then
      --
      -- Check for first in-eligible or still in-eligible
      --
      l_continue_loop := false;
      --
      if l_comp_obj_tree(l_treeele_num).elig_tran_state = 'FT_INELIG'
        or l_comp_obj_tree(l_treeele_num).elig_tran_state = 'ST_INELIG'
        or l_comp_obj_tree(l_treeele_num).elig_tran_state = 'NW_INELIG'
        or not l_evaluate_eligibility
      then
        --
        if g_debug then
          hr_utility.set_location (' First In-Eligible  BENMNGLE ',85);
        end if;
        --
        l_continue_loop := false;
        --
      else
        --
        if g_debug then
          hr_utility.set_location (' Non-filter eligibility  BENMNGLE ',85);
        end if;
        --
        l_continue_loop := true;
        --
      end if;
      --
      -- Defer Deenrollment cases
        -- If defer_deenrol_flag is set at len/enp, then
        -- populate pl/sql table l_defer_deenrl_tbl with pgm_id/pl_id
        -- if any comp.obj has newly_inligible status, update newly_inelig_exists to true.
        -- if any epe was created in pgm/pnip, update chc_exists to true
        --
        if (g_defer_deenrol_flag = 'Y') then
            -- Add pgm/pln to cache
            if (g_debug) then
                hr_utility.set_location('DEFER Starts', 1039);
                hr_utility.set_location('DEFER l_defer_count ' || l_defer_count , 1039);
                hr_utility.set_location('DEFER par_pl_id ' || l_comp_obj_tree(l_treeele_num).par_pl_id , 1039);
                hr_utility.set_location('DEFER pl_id ' || l_comp_obj_tree(l_treeele_num).pl_id , 1039);
                hr_utility.set_location('DEFER par_pgm_id ' || l_comp_obj_tree(l_treeele_num).par_pgm_id , 1039);
                hr_utility.set_location('DEFER pgm_id ' || l_comp_obj_tree(l_treeele_num).pgm_id , 1039);
            end if;
            --
            if (l_defer_deenrl_tbl.COUNT > 0) then
                if (l_comp_obj_tree(l_treeele_num).pl_nip <> 'Y') then
                    --
                    if (g_debug) then
                        hr_utility.set_location('DEFER tab_pgm_id '
                                || l_defer_deenrl_tbl(l_defer_count).pgm_id , 1039);
                    end if;
                    --
                    if (NVL(l_defer_deenrl_tbl(l_defer_count).pgm_id,-1) <>
                           NVL(l_comp_obj_tree(l_treeele_num).par_pgm_id,
                                    l_comp_obj_tree(l_treeele_num).pgm_id) ) then
                        --
                        l_defer_count := l_defer_count +1;
                        l_defer_deenrl_tbl(l_defer_count).pgm_id :=
                                         l_comp_obj_tree(l_treeele_num).par_pgm_id;
                        l_defer_deenrl_tbl(l_defer_count).pl_id := null;
                        l_defer_deenrl_tbl(l_defer_count).chc_exists := false;
                        l_defer_deenrl_tbl(l_defer_count).newly_inelig_exists := false;
                        --
                    end if;
                 else
                    --
                    if (g_debug) then
                        hr_utility.set_location('DEFER tab_pl_id '
                            || l_defer_deenrl_tbl(l_defer_count).pl_id , 1039);
                    end if;
                    --
                    if (NVL(l_defer_deenrl_tbl(l_defer_count).pl_id,-1) <>
                            NVL(l_comp_obj_tree(l_treeele_num).par_pl_id,
                                   l_comp_obj_tree(l_treeele_num).pl_id)) then
                        --
                        l_defer_count := l_defer_count +1;
                        l_defer_deenrl_tbl(l_defer_count).pl_id :=
                                         l_comp_obj_tree(l_treeele_num).par_pl_id;
                        l_defer_deenrl_tbl(l_defer_count).pgm_id := null;
                        l_defer_deenrl_tbl(l_defer_count).chc_exists := false;
                        l_defer_deenrl_tbl(l_defer_count).newly_inelig_exists := false;
                        --
                    end if;
                end if;
            else
                hr_utility.set_location('DEFER First PGM/PLN '  , 1039);
                --
                l_defer_count := l_defer_count +1;
                if (l_comp_obj_tree(l_treeele_num).pl_nip <> 'Y') then
                    l_defer_deenrl_tbl(l_defer_count).pgm_id :=
                                        NVL(l_comp_obj_tree(l_treeele_num).par_pgm_id,
                                               l_comp_obj_tree(l_treeele_num).pgm_id);
                    l_defer_deenrl_tbl(l_defer_count).pl_id := null;
                else
                    l_defer_deenrl_tbl(l_defer_count).pgm_id := null;
                    l_defer_deenrl_tbl(l_defer_count).pl_id :=
                                        NVL(l_comp_obj_tree(l_treeele_num).par_pl_id,
                                               l_comp_obj_tree(l_treeele_num).pl_id);
                end if;
                l_defer_deenrl_tbl(l_defer_count).chc_exists := false;
                l_defer_deenrl_tbl(l_defer_count).newly_inelig_exists := false;
            end if;
            --
            -- If Newly Inelig set Flag
            if (l_comp_obj_tree(l_treeele_num).elig_tran_state = 'NW_INELIG' ) then
                l_defer_deenrl_tbl(l_defer_count).newly_inelig_exists := true;
                hr_utility.set_location('DEFER NEWLY INELIG ' , 1039);
            end if;
            --
        end if;
        -- Defer enrollments ends;

      --
      -- Don't run enrolment_requirements for levels other than plan and oipl.
      -- Don't run it if the ler_id is null.
      --
      if g_debug then
        hr_utility.set_location ('Before enrollment call. pl id :'||l_pl_id,10);
        hr_utility.set_location ('Before enrollment call. oipl id :'||l_oipl_id,10);
        hr_utility.set_location ('Before enrollment call. ler id :'||p_ler_id,10);
        hr_utility.set_location ('Before enrollment call. l_mode :'||l_mode,10);
      end if;
      if (l_pl_id is not null
          or l_oipl_id is not null)
        and p_ler_id is not null
        and ((l_continue_loop and l_mode <> 'W') or (l_mode = 'W')) --Changed for Bug #2214961
      then
        --
        -- Initialise the current EPE row for the comp object loop
        --
        ben_epe_cache.init_context_cobj_pileperow;
        --
        if g_debug then
          hr_utility.set_location (l_package||' FND Bf BENDENRR ',85);
        end if;
        fnd_message.set_name('BEN','BEN_91333_CALLING_PROC');
        fnd_message.set_token('PROC','ben_enrolment_requirements');
        --
        -- p_mode changed to l_mode in following line by Gopal Venkataraman
        -- 3/27/01 bug 1636071
        --
        -- CWB Change
        --
        if l_mode in ('C', 'W') then
           l_asnd_lf_evt_dt := l_rec.lf_evt_ocrd_dt;
           if l_mode = 'W' and l_cwb_pl_id is null then
              l_cwb_pl_id := l_pl_id;
           end if;
        end if;
        --
        if g_debug then
          hr_utility.set_location (l_package||' FND Af BENDENRR  ',100);
        end if;
        ben_enrolment_requirements.enrolment_requirements
          (p_comp_obj_tree_row         => l_comp_obj_tree_row
          -- p_mode changed to l_mode in following line by Gopal Venkataraman 3/27/01 bug 1636071
          ,p_run_mode                  => l_mode
          ,p_business_group_id         => p_business_group_id
          ,p_effective_date            => p_effective_date
          ,p_lf_evt_ocrd_dt            => l_rec.lf_evt_ocrd_dt
          ,p_ler_id                    => p_ler_id
          ,p_per_in_ler_id             => l_pil_row.per_in_ler_id
          ,p_person_id                 => p_person_id
          ,p_pl_id                     => l_pl_id
          ,p_pgm_id                    => l_comp_obj_tree(l_treeele_num).par_pgm_id
          ,p_oipl_id                   => l_oipl_id
          ,p_elig_per_elctbl_chc_id    => l_elig_per_elctbl_chc_id
          ,p_electable_flag            => l_electable_flag
          -- PB : 5422 :
          --  ,p_popl_enrt_typ_cycl_id => p_popl_enrt_typ_cycl_id
          ,p_asnd_lf_evt_dt            => l_asnd_lf_evt_dt
          );
        if g_debug then
          hr_utility.set_location (l_package||' Dn BENDENRR  ',100);
        end if;
        --
        -- If choice has not been created don't do dependent stuff
        --
        if l_elig_per_elctbl_chc_id is not null then
        --
            -- Defer Deenrollment
            if (g_defer_deenrol_flag = 'Y') then
                hr_utility.set_location('DEFER CHOICE EXISTS ' , 1039);
                l_defer_deenrl_tbl(l_defer_count).chc_exists := true;
            end if;
          --
          -- Set electable choice context row details
          --
          ben_epe_cache.g_currcobjepe_row.ler_id := p_ler_id;
          ben_epe_cache.g_currcobjepe_row.opt_id := l_comp_obj_tree(l_treeele_num).par_opt_id;
          --
          fnd_message.set_name('BEN','BEN_91333_CALLING_PROC');
          fnd_message.set_token('PROC','ben_determine_dpnt_eligibility');
          --
          if g_debug then
            hr_utility.set_location (l_package||' BDDE_PUEWEID ',110);
          end if;
          --
          -- Task 131 : Eligible dependent rows are already created.
          -- Now update them with electable choice id.
          --
          --
          -- CWB Changes. ABSENCES : Dependents are not processed
          --
          if l_mode not in ('W', 'M','I','D') then
             --
             ben_determine_dpnt_eligibility.p_upd_egd_with_epe_id
               (p_elig_per_elctbl_chc_id => l_elig_per_elctbl_chc_id
               ,p_person_id              => p_person_id
               ,p_effective_date         => p_effective_date
               ,p_lf_evt_ocrd_dt         => l_rec.lf_evt_ocrd_dt
               );
             --
          end if;
          --
          fnd_message.set_name('BEN','BEN_91333_CALLING_PROC');
          fnd_message.set_token('PROC','BEN_DETERMINE_CHC_CTFN');
          --
          if g_debug then
            hr_utility.set_location ('BDCC_MN '||l_package,10);
          end if;
	  if l_mode <> 'D' then
          ben_determine_chc_ctfn.main
            (p_effective_date         => p_effective_date,
             p_person_id              => p_person_id,
             p_elig_per_elctbl_chc_id => l_elig_per_elctbl_chc_id,
             p_mode                   => l_mode);
	  end if;
          if g_debug then
            hr_utility.set_location ('Dn BDCC_MN '||l_package,10);
          end if;
          --
          fnd_message.set_name('BEN','BEN_91333_CALLING_PROC');
          fnd_message.set_token('PROC','ben_determine_coverage');
          --
          if g_debug then
            hr_utility.set_location (l_package||' ben_determine_coverage.main  ',110);
          end if;
          --
	  if l_mode <> 'D' then
          ben_determine_coverage.main
            (p_elig_per_elctbl_chc_id => l_elig_per_elctbl_chc_id
            ,p_effective_date         => p_effective_date
            ,p_lf_evt_ocrd_dt         => l_rec.lf_evt_ocrd_dt
            ,p_perform_rounding_flg   => true
            --
            ,p_enb_valrow             => l_enb_valrow
            );
        end if;
          if g_debug then
            hr_utility.set_location (l_package||' Dn DetCov_MN ',110);
          end if;
          --
          -- Initialise the current EPE row for the comp object loop
          --
          ben_epe_cache.init_context_cobj_pileperow;
          --
        end if;
        --
      end if; -- pl_id is not null
      --
    end if;
    --
    if l_mode = 'R' then
       --
       update_elig_per_rows
         (p_comp_obj_tree_row          => l_comp_obj_tree_row
          ,p_comp_rec                  => l_comp_rec
          ,p_person_id                 => p_person_id
          ,p_treeele_num               => l_treeele_num
          ,p_par_elig_state            => l_par_elig_state
          ,p_business_group_id         => p_business_group_id
          ,p_effective_date            => p_effective_date
          ,p_lf_evt_ocrd_dt            => l_rec.lf_evt_ocrd_dt
          ,p_per_in_ler_id             => l_pil_row.per_in_ler_id
          ,p_continue_loop             => l_continue_loop);
       --
       if (l_pl_id is not null
          or l_oipl_id is not null)
          and p_ler_id is not null
          and l_continue_loop
         then
         --
         -- Initialise the current EPE row for the comp object loop
         --
         ben_epe_cache.init_context_cobj_pileperow;
         --
         if g_debug then
           hr_utility.set_location (l_package||' FND Bf BENDENRR ',86);
           hr_utility.set_location ('l_oipl_id' ||l_oipl_id,87);
         end if;
         fnd_message.set_name('BEN','BEN_91333_CALLING_PROC');
         fnd_message.set_token('PROC','ben_enrolment_requirements');
         --
         ben_enrolment_requirements.enrolment_requirements
          (p_comp_obj_tree_row         => l_comp_obj_tree_row
          ,p_run_mode                  => 'U'  --l_mode
          ,p_business_group_id         => p_business_group_id
          ,p_effective_date            => p_effective_date
          ,p_lf_evt_ocrd_dt            => l_rec.lf_evt_ocrd_dt
          ,p_ler_id                    => p_ler_id
          ,p_per_in_ler_id             => l_pil_row.per_in_ler_id
          ,p_person_id                 => p_person_id
          ,p_pl_id                     => l_pl_id
          ,p_pgm_id                    => l_comp_obj_tree(l_treeele_num).par_pgm_id
          ,p_oipl_id                   => l_oipl_id
          ,p_elig_per_elctbl_chc_id    => l_elig_per_elctbl_chc_id
          ,p_electable_flag            => l_electable_flag
          ,p_asnd_lf_evt_dt            => l_asnd_lf_evt_dt
          );
         if g_debug then
           hr_utility.set_location (l_package||' Dn BENDENRR  ',200);
         end if;
        --
        -- If choice has not been created don't do dependent stuff
        --
        if l_elig_per_elctbl_chc_id is not null then
          --
          -- Set electable choice context row details
          --
          ben_epe_cache.g_currcobjepe_row.ler_id := p_ler_id;
          ben_epe_cache.g_currcobjepe_row.opt_id := l_comp_obj_tree(l_treeele_num).par_opt_id;
          --bug#3420298
          ben_determine_dpnt_eligibility.g_egd_table.delete;
          ben_determine_dpnt_eligibility.g_egd_table :=
                               ben_determine_dpnt_eligibility.g_egd_table_temp;
          --
          ben_determine_dpnt_eligibility.main
            (p_pgm_id            => l_comp_obj_tree(l_treeele_num).par_pgm_id
            ,p_pl_id             => l_comp_obj_tree(l_treeele_num).par_pl_id
            ,p_plip_id           => l_comp_obj_tree(l_treeele_num).par_plip_id
            ,p_ptip_id           => l_comp_obj_tree(l_treeele_num).par_ptip_id
            ,p_oipl_id           => l_oipl_id
            ,p_pl_typ_id         => null
            ,p_business_group_id => p_business_group_id
            ,p_person_id         => p_person_id
            ,p_effective_date    => p_effective_date
            ,p_per_in_ler_id     => l_pil_row.per_in_ler_id
            ,p_elig_per_id       => l_comp_obj_tree_row.elig_per_id
            ,p_elig_per_opt_id   => l_comp_obj_tree_row.elig_per_opt_id
            ,p_lf_evt_ocrd_dt    => l_rec.lf_evt_ocrd_dt
            );
          --

          ben_determine_dpnt_eligibility.p_upd_egd_with_epe_id
               (p_elig_per_elctbl_chc_id => l_elig_per_elctbl_chc_id
               ,p_person_id              => p_person_id
               ,p_effective_date         => p_effective_date
               ,p_lf_evt_ocrd_dt         => l_rec.lf_evt_ocrd_dt
               );
          -- end of bug#3420298
          ben_determine_coverage.main
            (p_elig_per_elctbl_chc_id => l_elig_per_elctbl_chc_id
            ,p_effective_date         => p_effective_date
            ,p_lf_evt_ocrd_dt         => l_rec.lf_evt_ocrd_dt
            ,p_perform_rounding_flg   => true
            ,p_enb_valrow             => l_enb_valrow
            );
          --
          -- Initialise the current EPE row for the comp object loop
          --
          ben_epe_cache.init_context_cobj_pileperow;
          --
        end if;
        --
      end if;
      --
   end if;
   -- end of mode 'R'
    benutils.write(p_text => g_output_string);
    --
    -- Check if the last row of the comp object list has been reached
    -- otherwise navigate to the next row
    --
    if l_treeele_num = l_maxtreeele_num then
      --
      l_treeloop := FALSE;
      exit;
      --
    else
      --
      l_treeele_num := l_treeele_num+1;
      --
    end if;
    --
    if g_debug then
      hr_utility.set_location (l_package||' End Proc loop ',20);
    end if;
    --
  end loop;
  --
  if g_debug then
    hr_utility.set_location (l_package||' OUT  Proc loop ',25);
  end if;
    --
    -- Defer Deenrollment
    -- 1. Loop thru the l_defer_deenrl_tbl
    -- 2. If any choice was created in pgm/pnip and
    --      if any pl/oipl was newly_ineligible and we deferred the de-enrollment
    --     then update corresponding PEL record with defer_deenrol_flag = Y
    -- 3. If no choice was created in pgm/pnip, then run newly_ineligible.main
    --      and de-enroll immediately.
    --
    if (l_defer_deenrl_tbl.COUNT > 0) then
        --
        for defer_indx in l_defer_deenrl_tbl.FIRST..l_defer_deenrl_tbl.LAST loop
            --
            hr_utility.set_location ('DEFER loop '|| defer_indx, 1039);
            --
            if l_defer_deenrl_tbl(defer_indx).chc_exists then
                --
                hr_utility.set_location ('DEFER chc_exists' ,9653);
                --
                if l_defer_deenrl_tbl(defer_indx).newly_inelig_exists then
                    --
                    l_defer_popl_id := null;
                    l_defer_popl_ovn := null;
                    hr_utility.set_location ('DEFER newly_inelig_exists' ,9653);

                    --
                    if (l_defer_deenrl_tbl(defer_indx).pgm_id is not null) then
                        --
                        hr_utility.set_location ('DEFER INSIDE PGM ' ,9653);
                        open c_pel_defer (l_defer_deenrl_tbl(defer_indx).pgm_id, l_rec.per_in_ler_id);
                        fetch c_pel_defer into l_pel_defer;
                        if c_pel_defer%FOUND then
                            --
                            l_defer_popl_id := l_pel_defer.pil_elctbl_chc_popl_id;
                            l_defer_popl_ovn := l_pel_defer.object_version_number;
                            --
                        end if;
                        close c_pel_defer;
                        hr_utility.set_location ('DEFER PGM' || l_pel_defer.pgm_id,9653);
                        --
                    elsif (l_defer_deenrl_tbl(defer_indx).pl_id is not null) then
                        --
                        hr_utility.set_location ('DEFER INSIDE PLN ' ,9653);

                        open c_pel_pnip_defer (l_defer_deenrl_tbl(defer_indx).pl_id, l_rec.per_in_ler_id);
                        fetch c_pel_pnip_defer into l_pel_pnip_defer;
                        if c_pel_pnip_defer%FOUND then
                            --
                            l_defer_popl_id := l_pel_pnip_defer.pil_elctbl_chc_popl_id;
                            l_defer_popl_ovn := l_pel_pnip_defer.object_version_number;
                            --
                        end if;
                        close c_pel_pnip_defer;
                        hr_utility.set_location ('DEFER PL' || l_pel_pnip_defer.pl_id,9653);
                        --
                    end if;
                    --
                    if l_defer_popl_id IS NOT NULL then
                        --
                        hr_utility.set_location ('DEFER UPDATED ' || l_defer_popl_id,9653);
                        hr_utility.set_location ('DEFER OVN ' || l_defer_popl_ovn,9653);
                        --
                        ben_pil_elctbl_chc_popl_api.update_pil_elctbl_chc_popl
                           (p_validate                    => FALSE,
                            p_pil_elctbl_chc_popl_id      => l_defer_popl_id,
                            p_object_version_number       => l_defer_popl_ovn,
                            p_effective_date              => p_effective_date,
                            p_defer_deenrol_flag          => 'Y'
                            );
                    end if;
                    --
                end if;
            else
                --
                hr_utility.set_location ('DEFER NEWLYINELIG ' ,9653);
                --
                if l_defer_deenrl_tbl(defer_indx).newly_inelig_exists then
                    ben_newly_ineligible.main
                        (p_person_id              => p_person_id,
                        p_pgm_id                 => l_defer_deenrl_tbl(defer_indx).pgm_id,
                        p_pl_id                  => l_defer_deenrl_tbl(defer_indx).pl_id,
                        p_oipl_id                => NULL,
                        p_business_group_id      => p_business_group_id,
                        p_ler_id                 => p_ler_id,
                        p_effective_date         => p_effective_date
                        );
                end if;
                 --
            end if;
            --
            hr_utility.set_location ('DEFER End loop ' ,9653);
            --
        end loop;
        --
    end if;
    -- Defer Deenrollment ends

  if l_mode = 'W' then

     update_cwb_epe
    (p_per_in_ler_id => l_rec.per_in_ler_id
    ,p_effective_date => p_effective_date);

  end if;

  --
  -- p_mode changed to l_mode in following line by Gopal Venkataraman 3/27/01 bug 1636071
  if l_mode <> 'T' then
    --
    -- Clear eligibility caches
    --
    ben_pep_cache.clear_down_cache;
    ben_epe_cache.clear_down_cache;
    --
    -- PB : 5422 :
    -- l_strt_dt is not being used by the process to which it is passed.
    -- May be necessary to remove this code.
    --
    /*
    open c_strt_dt;
      --
      fetch c_strt_dt into l_strt_dt;
      --
    close c_strt_dt;
    */
    --
    --  Start 5055119
     IF l_mode IN ('U', 'R', 'S', 'P','D')

      THEN
      hr_utility.set_location('SSARKAR p_person_id '|| p_person_id,9909);
      hr_utility.set_location('SSARKAR l_pil_row.per_in_ler_id '|| l_pil_row.per_in_ler_id,9909);
      hr_utility.set_location('SSARKAR p_effective_date '|| p_effective_date,9909);

         ben_manage_unres_life_events.end_date_elig_per_rows (p_person_id           => p_person_id,
                                                              p_per_in_ler_id       => l_pil_row.per_in_ler_id,
                                                              p_effective_date      => p_effective_date
                                                             );
      END IF;
    -- End 5055119
    -- p_mode changed to l_mode in following line by Gopal Venkataraman 3/27/01 bug 1636071
    if l_mode not in ('A','P','S','T') then
      -- Bug 4640014, deleting EPEs before update_defaults
      if l_mode in ('U','R') then
        --
        ben_manage_unres_life_events.clear_epe_cache ;
        --
      end if;
      --
      -- If defaults have changed due to deenrollments then
      -- check to see if choice defaults have changed.
      --
      if ben_enrolment_requirements.g_any_choice_created then
      if l_mode <> 'D' then
        ben_enrolment_requirements.update_defaults
          (p_run_mode               => l_mode
          ,p_business_group_id      => p_business_group_id
          ,p_effective_date         => p_effective_date
          ,p_lf_evt_ocrd_dt         => l_rec.lf_evt_ocrd_dt
          ,p_ler_id                 => p_ler_id
          ,p_person_id              => p_person_id
          ,p_per_in_ler_id          => l_pil_row.per_in_ler_id
          );
	  end if;
      end if;
      --BUG 4463267 Need to update the flag
      if l_mode <> 'D' then
      --
      BEN_DETERMINE_CHC_CTFN.update_susp_if_ctfn_flag
        (p_effective_date         => p_effective_date,
         p_lf_evt_ocrd_dt         => l_rec.lf_evt_ocrd_dt,
         p_person_id              => p_person_id,
         p_per_in_ler_id          => l_pil_row.per_in_ler_id
        );
      -- 1895846 call
      -- to delete the egd records create for the suspended pen or in pending wkflow epe records
      --
      fnd_message.set_name('BEN','BEN_91333_CALLING_PROC');
      fnd_message.set_token('PROC','delete_in_pndg_elig_dpnt');
      --
      delete_in_pndg_elig_dpnt( l_rec.per_in_ler_id,p_effective_date ) ;
      --
     end if;
      fnd_message.set_name('BEN','BEN_91333_CALLING_PROC');
      fnd_message.set_token('PROC','ben_determine_elct_chc_flx_imp');
      if g_debug then
        hr_utility.set_location('lf evt ocrd dt'||l_rec.lf_evt_ocrd_dt,11);
      end if;
      --
      -- CWB Changes. ABSENCES, GRADE/STEP  : no need to run flex logic
      -- added irec
      if l_mode not in ( 'W', 'M', 'G','I','D') then
         --
         ben_determine_elct_chc_flx_imp.main
           (p_person_id         => p_person_id,
            p_business_group_id => p_business_group_id,
            p_per_in_ler_id     => l_rec.per_in_ler_id,
            p_lf_evt_ocrd_dt    => l_rec.lf_evt_ocrd_dt,
            p_enrt_perd_strt_dt => l_strt_dt,
            p_effective_date    => p_effective_date,
            p_mode              => l_mode);
         --
      end if;
      --
      -- Assumption is that ben_determine_actual_premium.main and
      -- ben_determine_rates.main do not perform any updates to
      -- electable choices. Be aware of this assumption when modifying
      -- ben_determine_actual_premium and ben_determine_rates.
      --
      -- Clear electability caches
      --
      ben_epe_cache.clear_down_cache;
      --
      -- Clear Elig per Cache as ben_enrolment_requirements.update_defaults
      -- build the cache for previous eligibility.
      -- And in the benrates we need the current elig records.
      --
      ben_pep_cache.clear_down_cache;
      --
      -- Clear distribute rates function caches
      --
      ben_distribute_rates.clear_down_cache;
      --
      -- Do premium stuff if choices are created.
      --
      -- CWB Changes. ABSENCES ,GRADE/STEP : No need to run premium logic
      --
      if ben_enrolment_requirements.g_any_choice_created
         and l_mode not in( 'W', 'M', 'G','I','D')   -- added irec
      then
        if g_debug then
          hr_utility.set_location (l_package||'.ben_determine_actual_premium ',10);
        end if;
        fnd_message.set_name('BEN','BEN_91333_CALLING_PROC');
        fnd_message.set_token('PROC','ben_determine_actual_premium');
        --
        ben_determine_actual_premium.main
          (p_person_id         => p_person_id,
           p_effective_date    => p_effective_date,
        -- added per_in_ler_id for unrestricted enhancement
           p_per_in_ler_id     => l_rec.per_in_ler_id,
           p_lf_evt_ocrd_dt    => l_rec.lf_evt_ocrd_dt,
           p_mode              => l_mode
        );
        --
      end if;
      --
      -- Do rates stuff
      --
      if g_debug then
        hr_utility.set_location ('FND mess '||l_package,10);
      end if;
      fnd_message.set_name('BEN','BEN_91333_CALLING_PROC');
      fnd_message.set_token('PROC','ben_determine_rates');
      --
      if g_debug then
        hr_utility.set_location ('ben_determine_rates '||l_package,10);
      end if;
      ben_determine_rates.main
        (p_effective_date => p_effective_date,
         p_lf_evt_ocrd_dt => l_rec.lf_evt_ocrd_dt,
         p_person_id      => p_person_id,
         p_mode           => l_mode,
         -- added per_in_ler_id for unrestricted enhancement
         p_per_in_ler_id  => l_rec.per_in_ler_id);
      --
      -- Bug 3968065 : in CWB mode summ the rates defined at oipls and
      -- write into ben_cwb_person_rates.
      --
      if l_mode = 'W' then
         --
         BEN_MANAGE_CWB_LIFE_EVENTS.sum_oipl_rates_and_upd_pl_rate (
            p_pl_id          => l_cwb_pl_id,
            p_group_pl_id    => ben_manage_cwb_life_events.g_cache_group_plan_rec.group_pl_id,
            p_lf_evt_ocrd_dt => ben_manage_cwb_life_events.g_cache_group_plan_rec.group_lf_evt_ocrd_dt,
            p_person_id      => p_person_id,
            p_assignment_id  => null
            );
         --
      end if;
      --
      /* GSP Rate Sync */
      if l_mode = 'G'
      then
        --
        if p_lf_evt_oper_cd = 'SYNC'
        then
          --
          hr_utility.set_location('Calling GSP Rate Sync Post Process in PQH', 45);
          pqh_gsp_post_process.update_rate_sync_salary
            (p_per_in_ler_id   => l_pil_row.per_in_ler_id
            ,p_effective_date  => p_effective_date
            );
          --
        else /* p_lf_evt_oper_cd = 'PROG' */
          --
          gsp_proc_dflt_auten(l_rec.per_in_ler_id, p_effective_date) ;
          --
        end if;
      end if ;
      --
      if l_mode in ('U', 'R') then
        --
        update_enrt_rt (p_per_in_ler_id => l_rec.per_in_ler_id);
        ben_manage_unres_life_events.clear_cache;
        --
      end if;
      if g_debug then
        hr_utility.set_location ('ben_determine_rate_chg '||l_package,10);
      end if;
      fnd_message.set_name('BEN','BEN_91333_CALLING_PROC');
      fnd_message.set_token('PROC','ben_determine_rate_chg');
      --
      -- Turn off distribute rates function caching because cached information
      -- is updated in later RCOs. Any further RCOs will hit the DB rather the
      -- function cache.
      --
      ben_distribute_rates.set_no_cache_context;
      --
      --
      -- CWB Changes. ABSENCES, GRADE/STEP
      -- added irec
      if l_mode not in ('W', 'M', 'G','I','D')  then
         --
         ben_determine_rate_chg.main
           (p_effective_date    => p_effective_date,
            p_lf_evt_ocrd_dt    => l_rec.lf_evt_ocrd_dt,
            p_business_group_id => p_business_group_id,
            p_person_id         => p_person_id,
             -- added per_in_ler_id for unrestricted enhancement
            p_per_in_ler_id     => l_rec.per_in_ler_id,
            p_mode              => l_mode);
         --
      end if;
      --
    end if;
    --
    fnd_message.set_name('BEN','BEN_91333_CALLING_PROC');
    fnd_message.set_token('PROC','reset_elctbl_chc_inpng_flag');
    --
    -- Reset the in_pndg_wkflow_flag to 'N' for the suspended enrollment cases
    --
    reset_elctbl_chc_inpng_flag(l_rec.per_in_ler_id,p_effective_date );
    -- reopen already ended results if elecatble choice with flag Y
    -- Fidelity GM issue
    --
    -- bug 5534550 - call reopen only for L or C modes
    if  l_mode in ('L', 'C')  then
    --
    ben_reopen_ended_results.reopen_routine(
          p_per_in_ler_id     => l_rec.per_in_ler_id,
          p_business_group_id => p_business_group_id,
          p_lf_evt_ocrd_dt    => l_rec.lf_evt_ocrd_dt,
          p_person_id         => p_person_id,
          p_effective_date    => l_rec.lf_evt_ocrd_dt);
    --
    end if;
    --
    fnd_message.set_name('BEN','BEN_91333_CALLING_PROC');
    fnd_message.set_token('PROC','ben_automatic_enrollments');
    --
    -- Do the automatic enrollments
    --
    -- CWB Changes.
    --
    if g_debug then
      hr_utility.set_location ('BENAUTEN '||l_package,10);
    end if;
    if ben_enrolment_requirements.g_auto_choice_created
       and l_mode not in ('W','D')
    then
      ben_automatic_enrollments.main(
         p_person_id         => p_person_id,
         p_ler_id            => p_ler_id,
         p_business_group_id => p_business_group_id,
         -- p_mode changed to l_mode in following line by Gopal Venkataraman 3/27/01 bug 1636071
         p_mode              => l_mode,
         p_effective_date    => l_rec.lf_evt_ocrd_dt
      );
    end if;
    if g_debug then
      hr_utility.set_location ('Dn BENAUTEN '||l_package,10);
    end if;
    --
    --
    -- Check for reqired communications
    --
    fnd_message.set_name('BEN','BEN_91333_CALLING_PROC');
    fnd_message.set_token('PROC','ben_generate_communications');
    --
    if g_debug then
      hr_utility.set_location ('Comms '||l_package,10);
    end if;
    --
    -- p_mode changed to l_mode in following line by Gopal Venkataraman 3/27/01 bug 1636071
    -- CWB Changes.
    --
    if l_mode in ('C', 'W') then
       l_asnd_lf_evt_dt := l_rec.lf_evt_ocrd_dt;
    end if;
    --
    -- call communications for all modes other than GSP
    -- bypass communications call for irec
    if l_mode not in ( 'G','I','D') then
    --
    ben_generate_communications.main
      (p_person_id             => p_person_id,
       p_ler_id                => p_ler_id,
       p_per_in_ler_id         => l_rec.per_in_ler_id,
       p_prtt_enrt_actn_id     => null,
       p_bnf_person_id         => null,
       p_dpnt_person_id        => null,
       -- PB : 5422 :
       -- As enrt_perd_id is not passed, so pass the null value.
       --
       -- p_enrt_perd_id          => p_popl_enrt_typ_cycl_id,
       p_asnd_lf_evt_dt        => l_asnd_lf_evt_dt,
       p_actn_typ_id           => null,
       p_enrt_mthd_cd          => null,
       p_business_group_id     => p_business_group_id,
       -- p_mode changed to l_mode in following line by Gopal Venkataraman 3/27/01 bug 1636071
       p_proc_cd1              => benutils.iftrue(l_mode = 'U'
                                                 ,null
                                                 ,'MLEPECP'),
       -- p_mode changed to l_mode in following line by Gopal Venkataraman 3/27/01 bug 1636071
       p_proc_cd2              => benutils.iftrue(l_mode = 'U'
                                                 ,null
                                                 ,'MLEAUTOENRT'),
       -- p_mode changed to l_mode in following line by Gopal Venkataraman 3/27/01 bug 1636071
       p_proc_cd3              => benutils.iftrue(l_mode = 'U'
                                                 ,null
                                                 ,'MLERTCHG'),
       p_proc_cd4              => 'MLEENDENRT',
       -- p_mode changed to l_mode in following line by Gopal Venkataraman 3/27/01 bug 1636071
       p_proc_cd5              => benutils.iftrue(l_mode = 'U'
                                                 ,null
                                                 ,'MLENOIMP'),
       p_proc_cd6              => 'MLEELIG',
       p_proc_cd7              => 'MLEINELIG',
       p_proc_cd8              => 'HPAPRTTDE',
       p_proc_cd9              => 'HPADPNTLC',
       p_proc_cd10             => null,
       p_effective_date        => p_effective_date,
       p_lf_evt_ocrd_dt        => l_rec.lf_evt_ocrd_dt
    );
   --
   end if;
   --
    if g_debug then
      hr_utility.set_location ('Dn Comms '||l_package,10);
    end if;
    --
    --  Create benefit assignment for dependents if they were
    --  found ineligible.
    --
    -- CWB Changes. ABSENCES, GRADE/STEP
    -- added irec
    if ben_determine_dpnt_eligibility.g_dpnt_ineligible
       and (l_mode not in ( 'W', 'M', 'G','I','D'))
    then
      if g_debug then
        hr_utility.set_location ('Dpnt ineligible '||l_package,10);
      end if;
      for l_dpnt_rec in c_get_inelig_dpnt_info(l_rec.per_in_ler_id) loop
        if g_debug then
          hr_utility.set_location ('Dpnt person_id '||l_dpnt_rec.dpnt_person_id,10);
          hr_utility.set_location ('cvg_thru_dt '||l_dpnt_rec.cvg_thru_dt,10);
        end if;
        ben_assignment_internal.copy_empasg_to_benasg
          (p_person_id             => p_person_id
          ,p_dpnt_person_id        => l_dpnt_rec.dpnt_person_id
          ,p_effective_date        => l_dpnt_rec.cvg_thru_dt + 1
          ,p_assignment_id         => l_assignment_id
          ,p_object_version_number => l_object_version_number
          ,p_perhasmultptus        => l_perhasmultptus
          );
      end loop;
    end if;
    --
    -- COBRA:  If person is no longer enrolled in the COBRA program and has no
    -- opportunity to elect then, end COBRA eligibility.
    --
    if ben_cobra_requirements.g_cobra_enrollment_change then
      ben_cobra_requirements.end_prtt_cobra_eligibility
        (p_per_in_ler_id     => l_rec.per_in_ler_id
        ,p_person_id         => p_person_id
        ,p_business_group_id => p_business_group_id
        ,p_effective_date    => p_effective_date
        );
    end if;
    -- p_mode changed to l_mode in following line by Gopal Venkataraman 3/27/01 bug 1636071
    if l_mode in ('L','U') then
      --
      --  If electable choices are created, check if we need to create
      --  cobra qualified beneficiaries.
      --
      if (p_ler_id is not null and
          (l_rec.qualg_evt_flag = 'Y' or
           l_rec.typ_cd = 'ENDDSBLTY' or
           -- p_mode changed to l_mode in following line by Gopal Venkataraman 3/27/01 bug 1636071
           l_mode = 'U')) then
        ben_cobra_requirements.update_cobra_elig_info
        (p_person_id         => p_person_id
        ,p_per_in_ler_id     => l_rec.per_in_ler_id
        ,p_lf_evt_ocrd_dt    => l_rec.lf_evt_ocrd_dt
        ,p_effective_date    => p_effective_date
        ,p_business_group_id => p_business_group_id
        );
      end if;
    end if;
    --
  -- if condition added for unrestricted enhancement
    -- p_mode changed to l_mode in following line by Gopal Venkataraman 3/27/01 bug 1636071
   --
   -- iRec (OI) : Even if the person is not eligible to any plan, still the Life Event status in PIL
   -- should be Started (and should not be changed to Processed). Hence mode iRecruitment (I) not
   -- added in the following "if statement".

   -- ABSENCES : Close the life event.
   --
   if l_mode = 'L' or l_mode = 'C' or l_mode = 'M' then
    if (p_ler_id is not null and
      not ben_enrolment_requirements.g_electable_choice_created and
      not ben_enrolment_requirements.g_auto_choice_created ) or (l_mode = 'M')
    then
      --
      -- Set life event to processed, only update the per_in_ler_stat_cd
      --
      if l_mode = 'M' then
         --
         benutils.get_active_life_event
         (p_person_id         => p_person_id,
          p_business_group_id => p_business_group_id,
          p_effective_date    => p_effective_date,
          p_lf_event_mode   => 'M',
          p_rec               => l_rec);
         --
      else
         --
         benutils.get_active_life_event
        (p_person_id         => p_person_id,
         p_business_group_id => p_business_group_id,
         p_effective_date    => p_effective_date,
         p_rec               => l_rec);
         --
      end if;
      --
      if l_rec.lf_evt_ocrd_dt is not null then
        --
        if g_debug then
          hr_utility.set_location('processing event',10);
        end if;
        ben_person_life_event_api.update_person_life_event
            (p_per_in_ler_id           => l_rec.per_in_ler_id,
             p_per_in_ler_stat_cd      => 'PROCD',
             p_object_version_number   => l_rec.object_version_number,
             -- p_effective_date          => p_effective_date,
             -- Bug#1543462
             p_effective_date          => least(p_effective_date,trunc(sysdate)),
             p_procd_dt                => l_procd_dt,
             p_strtd_dt                => l_strtd_dt,
             p_voidd_dt                => l_voidd_dt);
        --
        --  Bug 6404338.  Min Max enhancement.
        l_chk_min_max := fnd_profile.value('BEN_CHK_MIN_MAX');
        --
        if g_debug then
          hr_utility.set_location ('l_chk_min_max '||l_chk_min_max,10);
        end if;
        --
        if l_chk_min_max = 'Y' then
          --
          --  Check if coverage was terminated in this event.
          --
          if ben_prtt_enrt_result_api.g_enrollment_change = true then
            if g_debug then
              hr_utility.set_location ('Enrollment ended ',10);
            end if;
            for l_rslt_rec in c_get_ended_enrt_rslts(l_rec.per_in_ler_id) loop
              --
              --  Check if person is still eligible for the plan type in
              --  program.
              --
              l_ptip_elig_flag := 'N';
              open c_get_ptip_elig(l_rslt_rec.ptip_id, l_rec.per_in_ler_id);
              fetch c_get_ptip_elig into l_ptip_elig_flag;
              close c_get_ptip_elig;
              --
              if g_debug then
                hr_utility.set_location (' Elig flag '||l_ptip_elig_flag,10);
              end if;
             --
              if l_ptip_elig_flag = 'Y' then
                --
                --  Get the ptip min and max.
                --
                open c_get_ptip(l_rslt_rec.ptip_id);
                fetch c_get_ptip into l_ptip_rec;
                if c_get_ptip%notfound then
                  close c_get_ptip;
                  fnd_message.set_name('BEN','BEN_91462_PTIP_MISSING');
                  fnd_message.set_token('ID', to_char(l_rslt_rec.ptip_id) );
                  fnd_message.raise_error;
                end if;
                --
                close c_get_ptip;
                --
                if (l_ptip_rec.no_mn_pl_typ_overid_flag = 'Y' or
                    (l_ptip_rec.no_mn_pl_typ_overid_flag = 'N' and
                    l_ptip_rec.MN_ENRD_RQD_OVRID_NUM is null)) then
                  l_mn_enrd_rqd_ovrid_num := l_ptip_rec.MN_ENRL_RQD_NUM;
                else
                  l_mn_enrd_rqd_ovrid_num := l_ptip_rec.MN_ENRD_RQD_OVRID_NUM;
                end if;
                --
                --  Get the total enrolled in the ptip
                --
                open c_get_ptip_tot_enrd(l_rslt_rec.ptip_id);
                fetch c_get_ptip_tot_enrd into l_count;
                close c_get_ptip_tot_enrd;
                hr_utility.set_location (' MN_ENRD_RQD_OVRID_NUM '||l_ptip_rec.MN_ENRD_RQD_OVRID_NUM,10);
                if (l_count < l_MN_ENRD_RQD_OVRID_NUM ) then
                  hr_utility.set_location (' error '||l_count,10);
                  fnd_message.set_name('BEN','BEN_91588_PL_ENRD_LT_MN_RQD');
                  fnd_message.set_token('MN_ENRL', to_char(l_MN_ENRD_RQD_OVRID_NUM));
                  fnd_message.set_token('PL_TYP_NAME', l_ptip_rec.name);
                  fnd_message.raise_error;
                end if;
              end if;
            end loop;
          end if;
        end if; -- l_chk_min_max = 'Y'
         --
         -- End min max enhancement.
         --
      end if;
      --
      -- Update status of life event to opened and closed as this is what has
      -- happened unless the life event was replaced.
      --
      benutils.update_life_event_cache(p_open_and_closed => 'Y');
      --
    end if;
    --
    if (p_ler_id is not null and
        ben_enrolment_requirements.g_electable_choice_created ) or
        l_mode = 'M' -- ABSENCES : close life event in absences mode.
    then
       open c_pil_elctbl_chc_popl(l_rec.per_in_ler_id);
       loop
          fetch c_pil_elctbl_chc_popl into l_pil_elctbl_chc_popl;
          if c_pil_elctbl_chc_popl%notfound then
            close c_pil_elctbl_chc_popl;
            exit;
          else
            ben_pil_elctbl_chc_popl_api.update_pil_elctbl_chc_popl
              (p_pil_elctbl_chc_popl_id     => l_pil_elctbl_chc_popl.pil_elctbl_chc_popl_id
              ,p_pil_elctbl_popl_stat_cd    => 'PROCD'
              ,p_business_group_id          => p_business_group_id
              ,p_object_version_number      => l_pil_elctbl_chc_popl.object_version_number
              ,p_effective_date             => p_effective_date);
          end if;
       end loop;
    end if;

  end if;
  --
  -- Do not run restore if electable choices are not created.
  --
  -- CWB Changes. -- ABSENCES : no restore logic.
  -- added irec
  if g_bckdt_per_in_ler_id is not null and
     ben_enrolment_requirements.g_electable_choice_created and
     l_mode not in ('W', 'M','I','D')
  then
    --
    ben_lf_evt_clps_restore.p_lf_evt_clps_restore
      (p_person_id              => p_person_id
      ,p_business_group_id      => p_business_group_id
      ,p_effective_date         => p_effective_date
      ,p_per_in_ler_id          => l_rec.per_in_ler_id
      ,p_bckdt_per_in_ler_id    => g_bckdt_per_in_ler_id);
    --
  end if;
  --
  -- Bug 4258498 : moved carry forward after reinstate, so that reinstate
  -- try to restore back what was previous state first.
  --Bug 4064635. New Procedure call to carry forward suspended enrollments
  --
  if l_mode not in ('W', 'M', 'G','I','D')  then
      --
      if g_debug then
        hr_utility.set_location ('carry_farward_results '||l_package,10);
      end if;
      --
      ben_carry_forward_items.carry_farward_results(
                p_person_id           => p_person_id
               ,p_per_in_ler_id       => l_rec.per_in_ler_id
               ,p_ler_id              => p_ler_id
               ,p_business_group_id   => p_business_group_id
               ,p_mode                => l_mode
               ,p_effective_date      => p_effective_date
                );
      --
      if g_debug then
        hr_utility.set_location ('Dn carry_farward_results '||l_package,10);
      end if;
      --
  end if;
  --
  end if;
  --
  -- GRADE/STEP - Bypass this for absences and grade modes V.Puttigampala 11/08/00
  -- added irec
  if l_mode not in  ('W', 'M', 'G','I','D') then
    --
     --- # 2899702 if the setup is autoenrollment Person Type usages are not create
     --- because the multi edit is not called , Person Type usages created in multiedit
     --- this is called for autoenrollment to created person type usaged
     if ben_enrolment_requirements.g_auto_choice_created
       and l_mode <> 'W' then

         ben_prtt_enrt_result_api.g_enrollment_change := true ;
    end if ;

    ben_prtt_enrt_result_api.update_person_type_usages
    (p_person_id        => p_person_id
    ,p_business_group_id    => p_business_group_id
    ,p_effective_date   => p_effective_date
    );
    --
  end if;
  -- bug 4621751 irec2 updating per_all_assignments_f with g_irec_old_ass_rec
  if l_mode = 'I' then
   begin
        -- dbms_output.put_line('***  G_IREC_OLD_ASS_REC.assignment_id '||G_IREC_OLD_ASS_REC.assignment_id);
    ben_irc_util.post_irec_process_update
    (p_person_id          => p_person_id,
     p_business_group_id  => p_business_group_id,
     p_assignment_id      => G_IREC_OLD_ASS_REC.assignment_id,
     p_effective_date     => p_effective_date);

    l_old_data_migrator_mode := hr_general.g_data_migrator_mode ;
    hr_general.g_data_migrator_mode := 'Y' ;

     -- update starts
     update per_all_assignments_F
     set
  BUSINESS_GROUP_ID              =   G_IREC_OLD_ASS_REC.BUSINESS_GROUP_ID
 ,RECRUITER_ID                   =   G_IREC_OLD_ASS_REC.RECRUITER_ID
 ,GRADE_ID                       =   G_IREC_OLD_ASS_REC.GRADE_ID
 ,POSITION_ID                    =   G_IREC_OLD_ASS_REC.POSITION_ID
 ,JOB_ID                         =   G_IREC_OLD_ASS_REC.JOB_ID
 ,ASSIGNMENT_STATUS_TYPE_ID      =   G_IREC_OLD_ASS_REC.ASSIGNMENT_STATUS_TYPE_ID
 ,PAYROLL_ID                     =   G_IREC_OLD_ASS_REC.PAYROLL_ID
 ,LOCATION_ID                    =   G_IREC_OLD_ASS_REC.LOCATION_ID
 ,PERSON_REFERRED_BY_ID          =   G_IREC_OLD_ASS_REC.PERSON_REFERRED_BY_ID
 ,SUPERVISOR_ID                  =   G_IREC_OLD_ASS_REC.SUPERVISOR_ID
 ,SPECIAL_CEILING_STEP_ID        =   G_IREC_OLD_ASS_REC.SPECIAL_CEILING_STEP_ID
 ,PERSON_ID                      =   G_IREC_OLD_ASS_REC.PERSON_ID
 ,RECRUITMENT_ACTIVITY_ID        =   G_IREC_OLD_ASS_REC.RECRUITMENT_ACTIVITY_ID
 ,SOURCE_ORGANIZATION_ID         =   G_IREC_OLD_ASS_REC.SOURCE_ORGANIZATION_ID
 ,ORGANIZATION_ID                =   G_IREC_OLD_ASS_REC.ORGANIZATION_ID
 ,PEOPLE_GROUP_ID                =   G_IREC_OLD_ASS_REC.PEOPLE_GROUP_ID
 ,SOFT_CODING_KEYFLEX_ID         =   G_IREC_OLD_ASS_REC.SOFT_CODING_KEYFLEX_ID
 ,VACANCY_ID                     =   G_IREC_OLD_ASS_REC.VACANCY_ID
 ,PAY_BASIS_ID                   =   G_IREC_OLD_ASS_REC.PAY_BASIS_ID
 ,ASSIGNMENT_SEQUENCE		 =   G_IREC_OLD_ASS_REC.ASSIGNMENT_SEQUENCE
 ,APPLICATION_ID                 =   G_IREC_OLD_ASS_REC.APPLICATION_ID
 ,ASSIGNMENT_NUMBER              =   G_IREC_OLD_ASS_REC.ASSIGNMENT_NUMBER
 ,CHANGE_REASON                  =   G_IREC_OLD_ASS_REC.CHANGE_REASON
 ,COMMENT_ID                     =   G_IREC_OLD_ASS_REC.COMMENT_ID
 ,DATE_PROBATION_END             =   G_IREC_OLD_ASS_REC.DATE_PROBATION_END
 ,DEFAULT_CODE_COMB_ID           =   G_IREC_OLD_ASS_REC.DEFAULT_CODE_COMB_ID
 ,EMPLOYMENT_CATEGORY            =   G_IREC_OLD_ASS_REC.EMPLOYMENT_CATEGORY
 ,FREQUENCY                      =   G_IREC_OLD_ASS_REC.FREQUENCY
 ,INTERNAL_ADDRESS_LINE          =   G_IREC_OLD_ASS_REC.INTERNAL_ADDRESS_LINE
 ,MANAGER_FLAG                   =   G_IREC_OLD_ASS_REC.MANAGER_FLAG
 ,NORMAL_HOURS                   =   G_IREC_OLD_ASS_REC.NORMAL_HOURS
 ,PERF_REVIEW_PERIOD             =   G_IREC_OLD_ASS_REC.PERF_REVIEW_PERIOD
 ,PERF_REVIEW_PERIOD_FREQUENCY   =   G_IREC_OLD_ASS_REC.PERF_REVIEW_PERIOD_FREQUENCY
 ,PERIOD_OF_SERVICE_ID           =   G_IREC_OLD_ASS_REC.PERIOD_OF_SERVICE_ID
 ,PROBATION_PERIOD               =   G_IREC_OLD_ASS_REC.PROBATION_PERIOD
 ,PROBATION_UNIT                 =   G_IREC_OLD_ASS_REC.PROBATION_UNIT
 ,SAL_REVIEW_PERIOD              =   G_IREC_OLD_ASS_REC.SAL_REVIEW_PERIOD
 ,SAL_REVIEW_PERIOD_FREQUENCY    =   G_IREC_OLD_ASS_REC.SAL_REVIEW_PERIOD_FREQUENCY
 ,SET_OF_BOOKS_ID                =   G_IREC_OLD_ASS_REC.SET_OF_BOOKS_ID
 ,SOURCE_TYPE                    =   G_IREC_OLD_ASS_REC.SOURCE_TYPE
 ,TIME_NORMAL_FINISH             =   G_IREC_OLD_ASS_REC.TIME_NORMAL_FINISH
 ,TIME_NORMAL_START              =   G_IREC_OLD_ASS_REC.TIME_NORMAL_START
 ,REQUEST_ID                     =   G_IREC_OLD_ASS_REC.REQUEST_ID
 ,PROGRAM_APPLICATION_ID         =   G_IREC_OLD_ASS_REC.PROGRAM_APPLICATION_ID
 ,PROGRAM_ID                     =   G_IREC_OLD_ASS_REC.PROGRAM_ID
 ,PROGRAM_UPDATE_DATE            =   G_IREC_OLD_ASS_REC.PROGRAM_UPDATE_DATE
 ,ASS_ATTRIBUTE_CATEGORY         =   G_IREC_OLD_ASS_REC.ASS_ATTRIBUTE_CATEGORY
 ,ASS_ATTRIBUTE1                 =   G_IREC_OLD_ASS_REC.ASS_ATTRIBUTE1
 ,ASS_ATTRIBUTE2                 =   G_IREC_OLD_ASS_REC.ASS_ATTRIBUTE2
 ,ASS_ATTRIBUTE3                 =   G_IREC_OLD_ASS_REC.ASS_ATTRIBUTE3
 ,ASS_ATTRIBUTE4                 =   G_IREC_OLD_ASS_REC.ASS_ATTRIBUTE4
 ,ASS_ATTRIBUTE5                 =   G_IREC_OLD_ASS_REC.ASS_ATTRIBUTE5
 ,ASS_ATTRIBUTE6                 =   G_IREC_OLD_ASS_REC.ASS_ATTRIBUTE6
 ,ASS_ATTRIBUTE7                 =   G_IREC_OLD_ASS_REC.ASS_ATTRIBUTE7
 ,ASS_ATTRIBUTE8                 =   G_IREC_OLD_ASS_REC.ASS_ATTRIBUTE8
 ,ASS_ATTRIBUTE9                 =   G_IREC_OLD_ASS_REC.ASS_ATTRIBUTE9
 ,ASS_ATTRIBUTE10                =   G_IREC_OLD_ASS_REC.ASS_ATTRIBUTE10
 ,ASS_ATTRIBUTE11                =   G_IREC_OLD_ASS_REC.ASS_ATTRIBUTE11
 ,ASS_ATTRIBUTE12                =   G_IREC_OLD_ASS_REC.ASS_ATTRIBUTE12
 ,ASS_ATTRIBUTE13                =   G_IREC_OLD_ASS_REC.ASS_ATTRIBUTE13
 ,ASS_ATTRIBUTE14                =   G_IREC_OLD_ASS_REC.ASS_ATTRIBUTE14
 ,ASS_ATTRIBUTE15                =   G_IREC_OLD_ASS_REC.ASS_ATTRIBUTE15
 ,ASS_ATTRIBUTE16                =   G_IREC_OLD_ASS_REC.ASS_ATTRIBUTE16
 ,ASS_ATTRIBUTE17                =   G_IREC_OLD_ASS_REC.ASS_ATTRIBUTE17
 ,ASS_ATTRIBUTE18                =   G_IREC_OLD_ASS_REC.ASS_ATTRIBUTE18
 ,ASS_ATTRIBUTE19                =   G_IREC_OLD_ASS_REC.ASS_ATTRIBUTE19
 ,ASS_ATTRIBUTE20                =   G_IREC_OLD_ASS_REC.ASS_ATTRIBUTE20
 ,ASS_ATTRIBUTE21                =   G_IREC_OLD_ASS_REC.ASS_ATTRIBUTE21
 ,ASS_ATTRIBUTE22                =   G_IREC_OLD_ASS_REC.ASS_ATTRIBUTE22
 ,ASS_ATTRIBUTE23                =   G_IREC_OLD_ASS_REC.ASS_ATTRIBUTE23
 ,ASS_ATTRIBUTE24                =   G_IREC_OLD_ASS_REC.ASS_ATTRIBUTE24
 ,ASS_ATTRIBUTE25                =   G_IREC_OLD_ASS_REC.ASS_ATTRIBUTE25
 ,ASS_ATTRIBUTE26                =   G_IREC_OLD_ASS_REC.ASS_ATTRIBUTE26
 ,ASS_ATTRIBUTE27                =   G_IREC_OLD_ASS_REC.ASS_ATTRIBUTE27
 ,ASS_ATTRIBUTE28                =   G_IREC_OLD_ASS_REC.ASS_ATTRIBUTE28
 ,ASS_ATTRIBUTE29                =   G_IREC_OLD_ASS_REC.ASS_ATTRIBUTE29
 ,ASS_ATTRIBUTE30                =   G_IREC_OLD_ASS_REC.ASS_ATTRIBUTE30
 ,TITLE                          =   G_IREC_OLD_ASS_REC.TITLE
 ,OBJECT_VERSION_NUMBER          =   G_IREC_OLD_ASS_REC.OBJECT_VERSION_NUMBER
 ,BARGAINING_UNIT_CODE           =   G_IREC_OLD_ASS_REC.BARGAINING_UNIT_CODE
 ,LABOUR_UNION_MEMBER_FLAG       =   G_IREC_OLD_ASS_REC.LABOUR_UNION_MEMBER_FLAG
 ,HOURLY_SALARIED_CODE           =   G_IREC_OLD_ASS_REC.HOURLY_SALARIED_CODE
 ,CONTRACT_ID                    =   G_IREC_OLD_ASS_REC.CONTRACT_ID
 ,COLLECTIVE_AGREEMENT_ID        =   G_IREC_OLD_ASS_REC.COLLECTIVE_AGREEMENT_ID
 ,CAGR_ID_FLEX_NUM               =   G_IREC_OLD_ASS_REC.CAGR_ID_FLEX_NUM
 ,CAGR_GRADE_DEF_ID              =   G_IREC_OLD_ASS_REC.CAGR_GRADE_DEF_ID
 ,ESTABLISHMENT_ID               =   G_IREC_OLD_ASS_REC.ESTABLISHMENT_ID
 ,NOTICE_PERIOD                  =   G_IREC_OLD_ASS_REC.NOTICE_PERIOD
 ,NOTICE_PERIOD_UOM              =   G_IREC_OLD_ASS_REC.NOTICE_PERIOD_UOM
 ,EMPLOYEE_CATEGORY              =   G_IREC_OLD_ASS_REC.EMPLOYEE_CATEGORY
 ,WORK_AT_HOME                   =   G_IREC_OLD_ASS_REC.WORK_AT_HOME
 ,JOB_POST_SOURCE_NAME           =   G_IREC_OLD_ASS_REC.JOB_POST_SOURCE_NAME
 ,POSTING_CONTENT_ID             =   G_IREC_OLD_ASS_REC.POSTING_CONTENT_ID
 ,PERIOD_OF_PLACEMENT_DATE_START =   G_IREC_OLD_ASS_REC.PERIOD_OF_PLACEMENT_DATE_START
 ,VENDOR_ID                      =   G_IREC_OLD_ASS_REC.VENDOR_ID
 ,VENDOR_EMPLOYEE_NUMBER         =   G_IREC_OLD_ASS_REC.VENDOR_EMPLOYEE_NUMBER
 ,VENDOR_ASSIGNMENT_NUMBER       =   G_IREC_OLD_ASS_REC.VENDOR_ASSIGNMENT_NUMBER
 ,ASSIGNMENT_CATEGORY            =   G_IREC_OLD_ASS_REC.ASSIGNMENT_CATEGORY
 ,PROJECT_TITLE                  =   G_IREC_OLD_ASS_REC.PROJECT_TITLE
 ,APPLICANT_RANK                 =   G_IREC_OLD_ASS_REC.APPLICANT_RANK
 ,GRADE_LADDER_PGM_ID            =   G_IREC_OLD_ASS_REC.GRADE_LADDER_PGM_ID
 ,SUPERVISOR_ASSIGNMENT_ID       =   G_IREC_OLD_ASS_REC.SUPERVISOR_ASSIGNMENT_ID
 ,VENDOR_SITE_ID                 =   G_IREC_OLD_ASS_REC.VENDOR_SITE_ID
 ,PO_HEADER_ID                   =   G_IREC_OLD_ASS_REC.PO_HEADER_ID
 ,PO_LINE_ID                     =   G_IREC_OLD_ASS_REC.PO_LINE_ID
 ,PROJECTED_ASSIGNMENT_END       =   G_IREC_OLD_ASS_REC.PROJECTED_ASSIGNMENT_END

 where assignment_id = G_IREC_OLD_ASS_REC.assignment_id ;
 -- update ends
hr_general.g_data_migrator_mode := l_old_data_migrator_mode ;

 exception
    when others then
      raise;
  end;
end if; --end irec2
  --
  benutils.write(p_text => benutils.g_banner_asterix);
  --
  p_person_count := p_person_count +1;
  --
  g_action_rec.person_action_id := p_person_action_id;
  g_action_rec.action_status_cd := 'P';
  g_action_rec.ler_id := p_ler_id;
  g_action_rec.object_version_number := p_object_version_number;
  g_action_rec.effective_date := p_effective_date;
  --
  benutils.write(p_rec => g_action_rec);
  --
  if g_debug then
    hr_utility.set_location ('Leaving '||l_package,10);
  end if;
  --
end process_comp_objects;
--
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
   --    p_popl_enrt_typ_cycl_id    in number default null,
   p_derivable_factors        in varchar2 default 'ASC',
   p_cbr_tmprl_evt_flag       in varchar2 default 'N',
   p_person_count             in out nocopy number,
   p_error_person_count       in out nocopy number,
   p_lf_evt_ocrd_dt           in date,
   p_effective_date           in date,
   p_validate                 in varchar2 default 'N',       /* Bug 5550359 */
   p_gsp_eval_elig_flag       in varchar2 default null,      /* GSP Rate Sync */
   p_lf_evt_oper_cd           in varchar2 default null       /* GSP Rate Sync */
   ) is
  --
  l_package           varchar2(80);
  l_ler_id            number := p_ler_id;
  l_rec               benutils.g_active_life_event;
  l_env               ben_env_object.g_global_env_rec_type;
  l_encoded_message   varchar2(2000);
  l_app_short_name    varchar2(2000);
  l_message_name      varchar2(2000);
  l_per_rec           per_all_people_f%rowtype;
  p_prtt_cache        varchar2(1) ;
  l_module            varchar2(30);
  --
begin
  --
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_package := g_package||'.process_life_events';
    hr_utility.set_location ('Entering '||l_package,10);
  end if;
  --
  -- Create savepoint for error handling purposes
  --
  savepoint process_life_event_savepoint;
  benutils.set_cache_record_position;

  -- iRec
  -- In iRecruitment mode, as multiple life events for a person could be processed for
  -- single person on a given day, clear down person cache. This change is necessary as
  -- same session could be used to process the person using different applicant assignments.
  if p_mode = 'I' then
    --
    ben_person_object.clear_down_cache;
    --
  end if;
  --
  -- iRec

  -- bug 7374364
  ben_use_cvg_rt_date.clear_fonm_globals;
  --
  --
  if g_debug then
    hr_utility.set_location (l_package||' Bef evaluate_life_events ',13);
  end if;
  --
  -- PB : 5422 :
  -- Now if benmngle is run in Life event mode and the winner
  -- is open then change the mode of benmngle run for this
  -- person and proceed. Means the mode to be changed on the fly.
  -- To make above logic work store the mode in global. Which
  -- may change later.
  --
  ben_manage_life_events.g_modified_mode := p_mode;
  --
  /* GSP Rate Sync */
  p_prtt_cache := 'N'  ;
  -- begin 4496944
  begin
       person_header_new
            (p_person_id            => p_person_id,
             p_business_group_id    => p_business_group_id);
  exception
     when others then
             --
         if g_debug then
           hr_utility.set_location ('Not Logging Person Header information for person_id : '||p_person_id ||' p_business_group_id : '||p_business_group_id,12);
         end if;

  end;
  -- end 4496944
  if g_cache_person_prtn.last is not null  then
     p_prtt_cache := 'Y'  ;
  end if ;

  evaluate_life_events
    (p_person_id                => p_person_id,
     p_business_group_id        => p_business_group_id,
     p_mode                     => p_mode,
     p_ler_id                   => l_ler_id,
     -- PB : 5422 :
     -- p_popl_enrt_typ_cycl_id    => p_popl_enrt_typ_cycl_id,
     p_lf_evt_ocrd_dt           => p_lf_evt_ocrd_dt,
     p_effective_date           => p_effective_date,
     p_validate                 => p_validate,                /* Bug 5550359 */
     p_gsp_eval_elig_flag       => p_gsp_eval_elig_flag,      /* GSP Rate Sync */
     p_lf_evt_oper_cd           => p_lf_evt_oper_cd           /* GSP Rate Sync */
     );

  if g_debug then
    hr_utility.set_location (l_package||' Dn evaluate_life_events ',15);
  end if;
  --
  if p_mode not in ('A','P','S','T') then
    --
    if p_mode in ( 'R', 'U') then
      --
      benutils.get_active_life_event
      (p_person_id         => p_person_id,
       p_business_group_id => p_business_group_id,
       p_effective_date    => p_effective_date,
       p_lf_event_mode   => 'U',
       p_rec               => l_rec);
    else
      --
      --
      -- CWB Changes .
      --
      if p_mode = 'W' then
       --
       benutils.get_active_life_event
       (p_person_id         => p_person_id,
        p_business_group_id => p_business_group_id,
        p_effective_date    => p_effective_date,
        p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
        p_ler_id            => p_ler_id,
        p_rec               => l_rec);
       --
      elsif p_mode = 'G' then
       --
       benutils.get_active_life_event
       (p_person_id         => p_person_id,
        p_business_group_id => p_business_group_id,
        p_effective_date    => p_effective_date,
        p_lf_event_mode     => 'G',
        p_rec               => l_rec);
       --
      elsif p_mode = 'M' then
       --
       benutils.get_active_life_event
       (p_person_id         => p_person_id,
        p_business_group_id => p_business_group_id,
        p_effective_date    => p_effective_date,
        p_lf_event_mode     => 'M',
        p_rec               => l_rec);
       --
      else
       --
       benutils.get_active_life_event
       (p_person_id         => p_person_id,
        p_business_group_id => p_business_group_id,
        p_effective_date    => p_effective_date,
        p_rec               => l_rec);
       --
      end if;
      --
      if g_debug then
        hr_utility.set_location (l_package||' Dn get_active_life_event ',17);
      end if;
      --
   end if;
   --
  end if;
  --
  -- ABSE : 2652690 : For every absence life event recache the person data.
  --
  if nvl(ben_manage_life_events.g_modified_mode, p_mode) in ('G', 'M') then
     --
     ben_person_object.clear_down_cache;
     --
  end if;
  --


  --- build comp object clear the person level cacahe
  --  then build it again 4204020
  --if p_prtt_cache = 'Y' and   g_cache_person_prtn.last is  null then
     cache_person_information
      (p_person_id         => p_person_id,
       p_business_group_id => p_business_group_id,
       p_effective_date    => nvl(l_rec.lf_evt_ocrd_dt,p_effective_date));

    if g_debug then
      hr_utility.set_location ('Dn Cac Per Inf '||l_package,10);
    end if;
  --
  --end if ;


  /* Moved call to person_header before evaluate_life_events
  person_header
       (p_person_id            => p_person_id,
        p_business_group_id    => p_business_group_id,
        p_effective_date       => nvl(l_rec.lf_evt_ocrd_dt,p_effective_date));
  */
  --
  if g_debug then
    hr_utility.set_location (l_package||' Bef process_comp_objects ',17);
  end if;
  process_comp_objects
    (p_person_id                => p_person_id,
     p_person_action_id         => p_person_action_id,
     p_object_version_number    => p_object_version_number,
     p_business_group_id        => p_business_group_id,
     p_mode                     => nvl(ben_manage_life_events.g_modified_mode, p_mode),
     p_ler_id                   => l_ler_id,
     p_derivable_factors        => g_derivable_factors,
     p_cbr_tmprl_evt_flag       => p_cbr_tmprl_evt_flag,
     p_person_count             => p_person_count,
     -- PB : 5422 :
     p_lf_evt_ocrd_dt           => p_lf_evt_ocrd_dt,
     -- p_popl_enrt_typ_cycl_id    => p_popl_enrt_typ_cycl_id,
     p_effective_date           => p_effective_date,
     p_gsp_eval_elig_flag       => p_gsp_eval_elig_flag,      /* GSP Rate Sync */
     p_lf_evt_oper_cd           => p_lf_evt_oper_cd           /* GSP Rate Sync */
     );
  --
  if p_mode in ('W','G') then
     if p_mode = 'W' then
        l_module := 'CWB';
     elsif p_mode = 'G' then
        l_module := 'GSP';
     end if;
     --
     if g_debug then
        hr_utility.set_location ('Calling pqh ranking proc ',10);
        hr_utility.set_location ('p_benefit_action_id=>'||benutils.g_benefit_action_id,10);
        hr_utility.set_location ('p_module=>'||l_module,10);
        hr_utility.set_location ('p_per_in_ler_id=>'||l_rec.per_in_ler_id,10);
        hr_utility.set_location ('p_person_id=>'||p_person_id,10);
        hr_utility.set_location ('p_effective_date=>'||l_rec.lf_evt_ocrd_dt,10);
     end if;
     --
     pqh_ranking.compute_total_score (
       p_benefit_action_id =>  benutils.g_benefit_action_id
      ,p_module         => l_module
      ,p_per_in_ler_id  => l_rec.per_in_ler_id
      ,p_person_id      => p_person_id
      ,p_effective_date => l_rec.lf_evt_ocrd_dt );
     --
  end if;
  if g_debug then
    hr_utility.set_location ('Leaving '||l_package,10);
  end if;
  --
exception
  --
  when g_record_error then
    --
    if g_debug then
      hr_utility.set_location ('PLE g_record_error '||l_package,10);
    end if;
    --
    -- An error has occured so rollback anything that could have been
    -- inserted into tables at this point.
    --
    if g_debug then
      hr_utility.set_location ('PERSON ERROR '||l_package,10);
    end if;
    rollback to process_life_event_savepoint;
    --
    -- Roll cache to savepoint
    --
    benutils.rollback_cache;
    --
    -- WW1178659 - Set the life event occured date to the effective
    -- date because the life event occured date may not have been
    -- derived. We can do this because national identifier is
    -- non-updateable so the effective date is irrelevant when
    -- getting person information.
    --
    ben_env_object.setenv(p_lf_evt_ocrd_dt => p_effective_date);
    ben_env_object.get(p_rec => l_env);
    ben_person_object.get_object(p_person_id => p_person_id,
                                 p_rec       => l_per_rec);

    g_rec.person_id := p_person_id;
    g_rec.pgm_id := l_env.pgm_id;
    g_rec.pl_id := l_env.pl_id;
    g_rec.oipl_id := l_env.oipl_id;
    l_encoded_message := fnd_message.get_encoded;
    fnd_message.parse_encoded(encoded_message => l_encoded_message,
                              app_short_name  => l_app_short_name,
                              message_name    => l_message_name);
    fnd_message.set_encoded(encoded_message => l_encoded_message);

    g_rec.rep_typ_cd := 'ERROR';
    g_rec.national_identifier := l_per_rec.national_identifier;

    -- Bug 2836770
    -- Added nvl's for l_message_name and fnd_message.get
    -- made call to write_table_and_file
    --
    g_rec.error_message_code := nvl(l_message_name , g_rec.error_message_code);
    g_rec.text := nvl(fnd_message.get , g_rec.text );
    --
    --benutils.write(p_text => g_rec.text); /* GSP Rate Sync */
    benutils.write(p_rec => g_rec);
    --
    -- benutils.write_table_and_file(p_table => true,
    --                              p_file  => true);

    -- Bug 2836770
    g_action_rec.person_action_id := p_person_action_id;
    g_action_rec.action_status_cd := 'E';
    g_action_rec.ler_id := p_ler_id;
    g_action_rec.object_version_number := p_object_version_number;
    g_action_rec.effective_date := p_effective_date;
    --
    benutils.write(p_rec => g_action_rec);
    --
    p_error_person_count := p_error_person_count +1;
    --
    -- bug 7374364
    ben_use_cvg_rt_date.clear_fonm_globals;
    --
    if p_error_person_count = g_max_errors_allowed then
      --
      fnd_message.set_name('BEN','BEN_91662_BENMNGLE_ERROR_LIMIT');
      benutils.write(p_text => fnd_message.get);
      if g_debug then
        hr_utility.set_location ('PLE g_record_error Err Lim '||l_package,10);
      end if;
      --
      -- Write the last bit of information for the thread before
      -- the rollback fires when we raise the error.
      --
      benutils.write_table_and_file(p_table => true,
                                    p_file  => true);
      commit;
      --
      raise;
      --
    end if;
    --
    -- Bug 5232223
    --
  when g_cwb_trk_ineligible then
    --
    if g_debug then
      hr_utility.set_location ('PLE g_life_event_after '||l_package,10);
    end if;
    --
    rollback to process_life_event_savepoint;
    --
    -- process.
    --
    g_action_rec.person_action_id := p_person_action_id;
    g_action_rec.action_status_cd := 'P';
    g_action_rec.ler_id := p_ler_id;
    g_action_rec.object_version_number := p_object_version_number;
    g_action_rec.effective_date := p_effective_date;
    --
    -- bug 7374364
    ben_use_cvg_rt_date.clear_fonm_globals;
    --
    benutils.write(p_rec => g_action_rec);
    --
    p_person_count := p_person_count +1;
    --
  when g_life_event_after then
    --
    if g_debug then
      hr_utility.set_location ('PLE g_life_event_after '||l_package,10);
    end if;
    --
    -- We don't want to roll back the transaction, just carry on with the
    -- process.
    --
    g_action_rec.person_action_id := p_person_action_id;
    g_action_rec.action_status_cd := 'P';
    g_action_rec.ler_id := p_ler_id;
    g_action_rec.object_version_number := p_object_version_number;
    g_action_rec.effective_date := p_effective_date;
    --
     -- bug 7374364
    ben_use_cvg_rt_date.clear_fonm_globals;
    --
    benutils.write(p_rec => g_action_rec);
    --
    p_person_count := p_person_count +1;
    --
  when app_exception.application_exception then
    --
    if g_debug then
      hr_utility.set_location ('PLE application_exception '||l_package,12);
    end if;
    --
    -- Update person action to errored as record has an error
    --
    rollback to process_life_event_savepoint;
    benutils.rollback_cache;
    --
    -- Roll cache to savepoint
    --
    ben_env_object.setenv(p_lf_evt_ocrd_dt => p_effective_date);
    ben_env_object.get(p_rec => l_env);
    ben_person_object.get_object(p_person_id => p_person_id,
                                 p_rec       => l_per_rec);
    g_rec.person_id := p_person_id;
    g_rec.pgm_id := l_env.pgm_id;
    g_rec.pl_id := l_env.pl_id;
    g_rec.oipl_id := l_env.oipl_id;
    l_encoded_message := fnd_message.get_encoded;
    fnd_message.parse_encoded(encoded_message => l_encoded_message,
                              app_short_name  => l_app_short_name,
                              message_name    => l_message_name);
    fnd_message.set_encoded(encoded_message => l_encoded_message);
    g_rec.rep_typ_cd := 'ERROR';
    g_rec.error_message_code := l_message_name;
    g_rec.national_identifier := l_per_rec.national_identifier;
    g_rec.text := fnd_message.get;
    benutils.write(p_text => g_rec.text);
    benutils.write(p_rec => g_rec);
    --
    g_action_rec.person_action_id := p_person_action_id;
    g_action_rec.action_status_cd := 'E';
    g_action_rec.ler_id := p_ler_id;
    g_action_rec.object_version_number := p_object_version_number;
    g_action_rec.effective_date := p_effective_date;
    -- bug 7374364
    ben_use_cvg_rt_date.clear_fonm_globals;
    --
    --
    benutils.write(p_rec => g_action_rec);
    --
    p_error_person_count := p_error_person_count +1;
    --
    if p_error_person_count = g_max_errors_allowed then
      --
      fnd_message.set_name('BEN','BEN_91662_BENMNGLE_ERROR_LIMIT');
      benutils.write(p_text => fnd_message.get);
      --
      -- Write the last bit of information for the thread before
      -- the rollback fires when we raise the error.
      --
      benutils.write_table_and_file(p_table => true,
                                    p_file  => true);
      commit;
      --
      raise;
      --
    end if;
    --
  when others then
    --
    if g_debug then
      hr_utility.set_location ('SERIOUS Error '||l_package,10);
    end if;
    --
    -- Update person action to errored as record has an error
    --
    rollback to process_life_event_savepoint;
    benutils.rollback_cache;
    --
    g_rec.rep_typ_cd := 'FATAL';
    g_rec.text := sqlerrm;
    benutils.write(p_rec => g_rec);
    --
    g_action_rec.person_action_id := p_person_action_id;
    g_action_rec.action_status_cd := 'E';
    g_action_rec.ler_id := p_ler_id;
    g_action_rec.object_version_number := p_object_version_number;
    g_action_rec.effective_date := p_effective_date;

    -- bug 7374364
    ben_use_cvg_rt_date.clear_fonm_globals;
    --
    --
    benutils.write(p_rec => g_action_rec);
    --

    p_error_person_count := p_error_person_count +1;
    --
    raise;
    --
end process_life_events;
--
procedure init_bft_statistics
  (p_business_group_id in number
  )
is
  --
  l_proc varchar2(80) := g_package||'.init_bft_statistics';
  --
begin
  --
  g_debug := hr_utility.debug_enabled;
  --
  g_proc_rec.business_group_id := p_business_group_id;
  g_proc_rec.strt_dt := sysdate;
  g_proc_rec.strt_tm := to_char(sysdate,'HH24:MI:SS');
  g_strt_tm_numeric := dbms_utility.get_time;
  --
end init_bft_statistics;
--
procedure write_bft_statistics
  (p_business_group_id in number
  ,p_benefit_action_id in number
  )
is
  --
  l_proc varchar2(80);
  --
  cursor c_person_actions(p_status_cd varchar2) is
    select count(*)
    from   ben_person_actions pac
    where  pac.benefit_action_id = p_benefit_action_id
    and    pac.action_status_cd = nvl(p_status_cd,pac.action_status_cd);
  --
begin
  --
  g_debug := hr_utility.debug_enabled;
  --
  g_proc_rec.end_dt := sysdate;
  g_proc_rec.end_tm := to_char(sysdate,'HH24:MI:SS');
  g_end_tm_numeric := dbms_utility.get_time;
  g_proc_rec.elpsd_tm := (g_end_tm_numeric-g_strt_tm_numeric)/100;
  --
  if g_debug then
    l_proc := g_package||'.write_bft_statistics';
    hr_utility.set_location (l_proc||' Master process ',30);
  end if;
  open c_person_actions(null);
    fetch c_person_actions into g_proc_rec.per_slctd;
  close c_person_actions;
  if g_debug then
    hr_utility.set_location (l_proc||' c_person_actions(null)',31);
  end if;
  --
  open c_person_actions('E');
    fetch c_person_actions into g_proc_rec.per_err;
  close c_person_actions;
  if g_debug then
    hr_utility.set_location (l_proc||' c_person_actions(E) ',32);
  end if;
  --
  open c_person_actions('P');
    fetch c_person_actions into g_proc_rec.per_proc_succ;
  close c_person_actions;
  if g_debug then
    hr_utility.set_location (l_proc||' c_person_actions(P) ',33);
  end if;
  --
  open c_person_actions('U');
    fetch c_person_actions into g_proc_rec.per_unproc;
  close c_person_actions;
  --
  if g_debug then
    hr_utility.set_location (l_proc||' Done c_person_actions ',35);
  end if;
  g_proc_rec.business_group_id := p_business_group_id;
  g_proc_rec.per_proc := nvl(g_proc_rec.per_proc_succ,0)+
                         nvl(g_proc_rec.per_err,0);
  --
  if g_debug then
    hr_utility.set_location (l_proc||' Write ',35);
  end if;
  benutils.write(p_rec => g_proc_rec);
  --
end write_bft_statistics;
--
end ben_manage_life_events;

/
