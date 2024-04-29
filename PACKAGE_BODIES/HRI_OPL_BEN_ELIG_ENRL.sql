--------------------------------------------------------
--  DDL for Package Body HRI_OPL_BEN_ELIG_ENRL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OPL_BEN_ELIG_ENRL" AS
/* $Header: hripbeec.pkb 120.1 2005/11/14 08:07:22 bmanyam noship $ */
--
/* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	Name	:	HRI_OPL_BEN_ELIG_ENRL
 	Purpose	:	Collect Benefits Election Events Fact and
                Benefits Eligibility and Enrollments Fact.

Description:
We try to use HRI_OPL_MULTI_THREAD utility.
Process Flow
===========
1. BEFORE MULTI-THREADING
--------------------------
1.0 PRE_PROCESS
    Full Refresh
    1.0.1 If 'Collect For Current Open Enrollment' profile is set to 'Yes',
            Fetch PER-IN-LERs corresponding to 'STRTD' LEs.
          ELSE
            Truncate the Events Table.
            Fetch All PER-IN-LERs.
    1.0.2 Generate the Person Ranges SQL. (From PER_IN_LERs)

    Incremental Refresh
    1.0.1 Generate the Person Ranges SQL. (From HRI_BEN_EQ_ELIGENRL_EVTS_CT).

2. MULTI-THREADING
-------------------
2.0 PROCESS_RANGE
    2.0.1 Gets a range of objects (per_in_lers) to process
    2.0.2 Calls process_full_range or process_incr_range for each range.
        2.0.2.1 PROCESS_FULL_RANGE (Full Refresh)
        2.0.2.2 PROCESS_INCR_RANGE (Incremental Refresh)

3. AFTER MULTI-THREADING
-------------------------
3.0 POST_PROCESS
    3.0.1 Logs process end (Success/Failure)
    3.0.2 Purges event queue
    3.0.3 Full Refresh
    3.0.4 Incremental Refres
    3.0.5 Recreates indexes that were dropped in PRE_PROCESS
    3.0.6 Gathers stats
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
--
-- Global variables representing parameters
--
g_package                VARCHAR2(30) := 'HRI_OPL_BEN_ELIG_ENRL.';

g_refresh_start_date     DATE;
g_refresh_end_date       DATE;
g_full_refresh           VARCHAR2(5);
g_concurrent_flag        VARCHAR2(5);
g_debug_flag             VARCHAR2(5);
g_collect_oe_only        VARCHAR2(5);
g_global_start_date      DATE;

--
-- Global end of time date initialization from the package hr_general
--
g_end_of_time            DATE;
--
-- Global DBI collection start date initialization
--
g_dbi_collection_start_date DATE;
--
-- Global Variable for checking if performance rating is to be collected
--
g_collect_perf_rating    VARCHAR2(30);
g_collect_prsn_typ       VARCHAR2(30);
--
-- Global HRI Multithreading Array
--
g_mthd_action_array      HRI_ADM_MTHD_ACTIONS%rowtype;
--
-- Global warning indicator
--
g_raise_warning          VARCHAR2(1);
--
g_eligenrl_evnt_table VARCHAR2(50) := 'HRI_MB_BEN_ELIGENRL_EVNT_CT';
g_elctn_evnt_table VARCHAR2(50) := 'HRI_MB_BEN_ELCTN_EVNT_CT';
--
g_elctn_evts_eq_table VARCHAR2(50) := 'HRI_EQ_BEN_ELCTN_EVTS';
g_eligenrl_evts_eq_table VARCHAR2(50) := 'HRI_EQ_BEN_ELIGENRL_EVTS';

-- -----------------------------------------------------------------------------
-- Inserts row into concurrent program log
-- -----------------------------------------------------------------------------
PROCEDURE output(p_text  VARCHAR2) IS
BEGIN
    --
 --   DBMS_OUTPUT.PUT_LINE(p_text);
    HRI_BPL_CONC_LOG.output(p_text);
    --
END output;

--
-- -----------------------------------------------------------------------------
-- Inserts row into concurrent program log if debugging is enabled
-- -----------------------------------------------------------------------------
PROCEDURE dbg(p_text  VARCHAR2) IS
BEGIN
    --
       HRI_BPL_CONC_LOG.dbg(p_text);
    --   DBMS_OUTPUT.PUT_LINE(p_text);
    --
END dbg;
-- ----------------------------------------------------------------------------
-- SET_PARAMETERS
-- sets up parameters required for the process.
-- ----------------------------------------------------------------------------
--
PROCEDURE set_parameters(p_mthd_action_id  IN NUMBER
                        ,p_mthd_range_id   IN NUMBER DEFAULT NULL) IS
  --
  l_procedure VARCHAR2(100) := g_package || 'set_parameters';
  --
BEGIN
    --
    -- If parameters haven't already been set, then set them
    --
--    dbg('Entering ' || l_procedure);
    --
    --   Default these values..
--    g_full_refresh := 'Y';
    g_collect_oe_only := HRI_BPL_BEN_UTIL.get_curr_oe_coll_mode;
    g_global_start_date := HRI_BPL_PARAMETER.get_bis_global_start_date;
    --
    IF p_mthd_action_id IS NULL THEN
        --
        -- Called from test harness
        --
        g_refresh_start_date   := bis_common_parameters.get_global_start_date;
        g_refresh_end_date     := hr_general.end_of_time;
        g_full_refresh         := 'Y';
        g_concurrent_flag      := 'Y';
        g_debug_flag           := 'Y';
        --
    ELSIF (g_refresh_start_date IS NULL) THEN
        --
        g_mthd_action_array    :=  hri_opl_multi_thread.get_mthd_action_array(p_mthd_action_id);
        g_refresh_start_date   := g_mthd_action_array.collect_from_date;
        g_refresh_end_date     := hr_general.end_of_time;
        g_full_refresh         := g_mthd_action_array.full_refresh_flag;
        g_concurrent_flag      := 'Y';
        g_debug_flag           := g_mthd_action_array.debug_flag;
        --
    END IF;
--    dbg('Leaving ' || l_procedure);
--
END set_parameters;

--
-- ----------------------------------------------------------------------------
-- PRE_PROCESS
-- This procedure includes the logic required for performing the pre_process
-- task of HRI multithreading utility.
-- ----------------------------------------------------------------------------
--

PROCEDURE pre_process
  (p_mthd_action_id    IN NUMBER
  ,p_sqlstr            OUT NOCOPY VARCHAR2) IS
  l_dummy1 VARCHAR2(4000);
  l_dummy2 VARCHAR2(4000);
  l_schema VARCHAR2(10);

  l_procedure VARCHAR2(100) := g_package || 'pre_process';

  l_strtd_events_only VARCHAR2(1000);

BEGIN
    dbg('Entering ' || l_procedure);
    -- Set Initialization Parameters.
    set_parameters(p_mthd_action_id);
    OUTPUT('Full Refresh Flag  : ' || g_full_refresh);
    OUTPUT('Open Enr Only Flag : ' || g_collect_oe_only);
    --
    -- Disable WHO triggers on Events table
    IF (fnd_installation.get_app_info('HRI',l_dummy1, l_dummy2, l_schema)) THEN
    --
    -- ---------------------------------------------------------------------------
    --                       Full Refresh Section
    -- ---------------------------------------------------------------------------
        IF (g_full_refresh = 'Y') THEN
            --
            -- If 'Collect For Current Open Enrollment Only',
            -- Follow the same flow as Full_Refresh,
            -- Only collect PER_IN_LERs STRTD state.
            -- And avoid truncate tables.
            IF (g_collect_oe_only = 'Y') THEN
                --
--                l_strtd_events_only := '   AND pil.per_in_ler_stat_cd = ''STRTD''';
                -- Change in Logic
                -- Return the sql query to fetch PERSON_ID ranges.
                -- Select all PERSONs for whom an Open Enrollment is either in Started or Processed State
                -- for the Latest Open LE in each BG.
                --
                p_sqlstr := ' ';
                p_sqlstr := p_sqlstr || 'SELECT DISTINCT pil.person_id object_id';
                p_sqlstr := p_sqlstr || '  FROM ben_per_in_ler pil,';
                p_sqlstr := p_sqlstr || '       (SELECT MAX(pil.lf_evt_ocrd_dt) lf_evt_ocrd_dt';
                p_sqlstr := p_sqlstr || '               , pil.business_group_id';
                p_sqlstr := p_sqlstr || '               , pil.ler_id';
                p_sqlstr := p_sqlstr || '		   FROM ben_per_in_ler pil, ';
                p_sqlstr := p_sqlstr || '		        ben_ler_f ler ';
                p_sqlstr := p_sqlstr || '		  WHERE pil.ler_id = ler.ler_id ';
                p_sqlstr := p_sqlstr || '		    AND ler.typ_cd = ''SCHEDDO''';
                p_sqlstr := p_sqlstr || '		    AND pil.per_in_ler_stat_cd = ''STRTD''';
                p_sqlstr := p_sqlstr || '          AND pil.lf_evt_ocrd_dt >= ';
                p_sqlstr := p_sqlstr || '               TO_DATE('''||TO_CHAR(g_global_start_date,'MM/DD/YYYY') ||''',''MM/DD/YYYY'') ';
                p_sqlstr := p_sqlstr || '           AND pil.lf_evt_ocrd_dt BETWEEN ler.effective_start_date ';
                p_sqlstr := p_sqlstr || '                                      AND ler.effective_end_date ';
                p_sqlstr := p_sqlstr || '		  GROUP BY pil.business_group_id, pil.ler_id ) pil1';
                p_sqlstr := p_sqlstr || ' WHERE pil.ler_id = pil1.ler_id';
                p_sqlstr := p_sqlstr || '   AND pil.business_group_id = pil1.business_group_id';
                p_sqlstr := p_sqlstr || '   AND pil.lf_evt_ocrd_dt = pil1.lf_evt_ocrd_dt ';
                p_sqlstr := p_sqlstr || ' ORDER BY pil.person_id   ';

                OUTPUT(' Collect For Current Open  ');
                --
            ELSE
                 --
                 OUTPUT(' Collect For All Open');
                 OUTPUT(' Disabling Indexes...');
                 -- Disable Logs and Indexes
                 hri_utl_ddl.log_and_drop_indexes(
                                 p_application_short_name => 'HRI',
                                 p_table_name    => g_eligenrl_evnt_table,
                                 p_table_owner   => l_schema);

                 hri_utl_ddl.log_and_drop_indexes(
                                 p_application_short_name => 'HRI',
                                 p_table_name    => g_elctn_evnt_table,
                                 p_table_owner   => l_schema);
                --
                -- l_strtd_events_only := '';
                -- Return the sql query to fetch PERSON_ID ranges.
                -- Select all PERSONs for whom an Open Enrollment is either in Started or Processed State
                -- Use Profiles to limit entries base on life event occured date.
                p_sqlstr := ' ';
                p_sqlstr := p_sqlstr || 'SELECT DISTINCT pil.person_id object_id ';
                p_sqlstr := p_sqlstr || '  FROM ben_per_in_ler pil, ';
                p_sqlstr := p_sqlstr || '       ben_ler_f ler ';
                p_sqlstr := p_sqlstr || ' WHERE pil.ler_id = ler.ler_id ';
                p_sqlstr := p_sqlstr || '   AND ler.typ_cd = ''SCHEDDO'' ';
                p_sqlstr := p_sqlstr || '   AND pil.lf_evt_ocrd_dt >= ';
                p_sqlstr := p_sqlstr || '  TO_DATE('''||TO_CHAR(g_global_start_date,'MM/DD/YYYY') || ''',''MM/DD/YYYY'') ';
                p_sqlstr := p_sqlstr || ' ORDER BY pil.person_id ';
                --
                -- Truncate the table
                OUTPUT(' Truncating Tables...');
                --
                EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || l_schema || '.' || g_eligenrl_evnt_table;
                EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || l_schema || '.' || g_elctn_evnt_table;
                --
            END IF;
            --
            --
            --                    End of Full Refresh Section
            -- -------------------------------------------------------------------------
            --
            -- -------------------------------------------------------------------------
            --                   Start of Incremental Refresh Section
            --
        ELSE
            --
            -- Return the sql query to fetch PERSON_ID ranges
            --
            p_sqlstr := ' ';
            p_sqlstr := p_sqlstr || ' SELECT penq.person_id object_id ';
            p_sqlstr := p_sqlstr || '   FROM hri_eq_ben_eligenrl_evts penq ';
            p_sqlstr := p_sqlstr || ' UNION '; -- Removes Duplicates
            -- 	4501649 Election Events to be considered for incremental refresh.
            p_sqlstr := p_sqlstr || ' SELECT pelq.person_id object_id ';
            p_sqlstr := p_sqlstr || '   FROM hri_eq_ben_elctn_evts pelq ';
            p_sqlstr := p_sqlstr || ' ORDER BY 1 ';

            --
            --                 End of Incremental Refresh Section
            -- -------------------------------------------------------------------------
            --
        END IF;
    END IF;
    dbg('Leaving ' || l_procedure);
EXCEPTION
    WHEN OTHERS THEN
        dbg('Error ' || l_procedure);
        OUTPUT('SQLERRM '|| SQLERRM);
        RAISE;
END pre_process;
--
-- ----------------------------------------------------------------------------
-- COLLECT_ELIGIBLE_EVT (INCREMENTAL REFRESH)
-- This procedure includes the logic for collecting Only Eligibility
-- during Incremental Refresh.
-- ----------------------------------------------------------------------------
--
PROCEDURE collect_eligible_evt (p_pil_rec G_PIL_REC_TYPE) IS

    dml_errors          EXCEPTION;
    PRAGMA exception_init(dml_errors, -24381);

    l_procedure VARCHAR2(100) := g_package || 'collect_eligible_evt';

BEGIN
--    dbg('Entering ' || l_procedure);

    INSERT INTO HRI_MB_BEN_ELIGENRL_EVNT_CT
            (change_date
            ,effective_start_date
            ,effective_end_date
            ,compobj_sk_pk
            ,asnd_lf_evt_dt
            ,person_id
            ,per_in_ler_id
            ,enrt_perd_id
            ,prtt_enrt_rslt_id
            ,elig_ind
            ,enrt_ind
            ,not_enrt_ind
            ,dflt_ind
            ,waive_expl_ind
            ,waive_dflt_ind)
   (SELECT  ee.change_date change_date,
            ee.change_date effective_start_date,
            NVL(LEAD(ee.change_date - 1)
                  OVER (PARTITION BY compobj_sk_pk
                            ORDER BY compobj_sk_pk, ee.change_date), hr_api.g_eot) effective_end_date,
            ee.compobj_sk_pk,
            p_pil_rec.lf_evt_ocrd_dt asnd_lf_evt_dt ,
            p_pil_rec.person_id person_id,
            p_pil_rec.per_in_ler_id per_in_ler_id,
            ee.enrt_perd_id,
            ee.prtt_enrt_rslt_id,
            ee.elig_ind,
            ee.enrt_ind,
            ee.not_enrt_ind,
            ee.dflt_ind,
            ee.waive_expl_ind,
            ee.waive_dflt_ind
    FROM (  -- Retuns all Electable Choices if Enrollments DOES NOT start on the same day.
            -- First Part of UNION brings all PLIPs and OIPL IS NULL
            SELECT pel.enrt_perd_strt_dt change_date,
                   copd.compobj_sk_pk compobj_sk_pk,
                   pel.enrt_perd_id,
                   epe.prtt_enrt_rslt_id  prtt_enrt_rslt_id,
                   1 elig_ind,
                   (CASE WHEN (epe.crntly_enrd_flag = 'Y')
                         THEN 1
                         ELSE 0 END )  enrt_ind,
                   (CASE WHEN (epe.crntly_enrd_flag = 'Y')
                         THEN 0
                         ELSE 1 END )  not_enrt_ind,
                   -- DFLT_IND -> If Currently Enrolled and Default Comp Object
                   (CASE WHEN (pel.elcns_made_dt IS NULL
                              AND pel.dflt_asnd_dt IS NOT NULL
                              AND epe.crntly_enrd_flag = 'Y'
                              AND epe.dflt_flag = 'Y')
                         THEN 1
                         ELSE 0 END) dflt_ind,
                    -- WAIVE_EXPL_IND -> If Currently Enrolled and Waive Opt/Pln and Not Default Comp.Object
                   (CASE WHEN (pel.elcns_made_dt IS NOT NULL
                               AND epe.crntly_enrd_flag = 'Y'
                               AND pln.invk_dcln_prtn_pl_flag = 'Y')
                         THEN 1
                         ELSE 0 END) waive_expl_ind,
                    -- WAIVE_DFLT_IND -> If Currently Enrolled and Waive Opt/Pln and Default Comp.Object
                   (CASE WHEN (pel.elcns_made_dt IS NULL
                               AND pel.dflt_asnd_dt IS NOT NULL
                               AND epe.dflt_flag = 'Y'
                               AND pln.invk_dcln_prtn_pl_flag = 'Y')
                         THEN 1
                         ELSE 0 END) waive_dflt_ind
              FROM ben_elig_per_elctbl_chc epe,
                   ben_pil_elctbl_chc_popl pel,
                   hri_cs_compobj_ct copd,
                   ben_pl_f pln
             WHERE epe.pil_elctbl_chc_popl_id = pel.pil_elctbl_chc_popl_id
               AND pel.per_in_ler_id = p_pil_rec.per_in_ler_id
               AND epe.elctbl_flag = 'Y'
               AND epe.elig_flag = 'Y'
               AND copd.oipl_id = -1
               AND epe.oipl_id IS NULL
               AND copd.plip_id = epe.plip_id
               AND copd.pgm_id =  epe.pgm_id -- As required for Perf.
               AND copd.pl_id = epe.pl_id -- As required for Perf.
               AND pln.pl_id = copd.pl_id
               AND p_pil_rec.lf_evt_ocrd_dt BETWEEN pln.effective_start_date
                                                AND pln.effective_end_date
               AND (epe.prtt_enrt_rslt_id IS NULL
                    OR NOT EXISTS (
                   SELECT null
                     FROM ben_prtt_enrt_rslt_f pen
                    WHERE pen.prtt_enrt_rslt_id = epe.prtt_enrt_rslt_id
                      AND pen.per_in_ler_id = p_pil_rec.per_in_ler_id
                      AND pen.prtt_enrt_rslt_stat_cd IS NULL
                      AND pen.enrt_cvg_thru_dt = hr_api.g_eot
                      AND pen.effective_end_date = hr_api.g_eot
                      AND pen.effective_start_date = pel.enrt_perd_strt_dt))
            UNION ALL
            -- Second Part of UNION brings all OIPLs
            SELECT pel.enrt_perd_strt_dt change_date,
                   copd.compobj_sk_pk compobj_sk_pk,
                   pel.enrt_perd_id,
                   epe.prtt_enrt_rslt_id  prtt_enrt_rslt_id,
                   1 elig_ind,
                   (CASE WHEN (epe.crntly_enrd_flag = 'Y')
                         THEN 1
                         ELSE 0 END )  enrt_ind,
                   (CASE WHEN (epe.crntly_enrd_flag = 'Y')
                         THEN 0
                         ELSE 1 END )  not_enrt_ind,
                   -- DFLT_IND -> If Currently Enrolled and Default Comp Object
                   (CASE WHEN (pel.elcns_made_dt IS NULL
                              AND pel.dflt_asnd_dt IS NOT NULL
                              AND epe.crntly_enrd_flag = 'Y'
                              AND epe.dflt_flag = 'Y')
                         THEN 1
                         ELSE 0 END) dflt_ind,
                    -- WAIVE_EXPL_IND -> If Currently Enrolled and Waive Opt/Pln and Not Default Comp.Object
                   (CASE WHEN (pel.elcns_made_dt IS NOT NULL
                               AND epe.crntly_enrd_flag = 'Y'
                               AND opt.invk_wv_opt_flag = 'Y')
                         THEN 1
                         ELSE 0 END) waive_expl_ind,
                    -- WAIVE_DFLT_IND -> If Currently Enrolled and Waive Opt/Pln and Default Comp.Object
                   (CASE WHEN (pel.elcns_made_dt IS NULL
                               AND pel.dflt_asnd_dt IS NOT NULL
                               AND epe.dflt_flag = 'Y'
                               AND opt.invk_wv_opt_flag = 'Y')
                         THEN 1
                         ELSE 0 END) waive_dflt_ind
              FROM ben_elig_per_elctbl_chc epe,
                   ben_pil_elctbl_chc_popl pel,
                   hri_cs_compobj_ct copd,
                   ben_opt_f opt
             WHERE epe.pil_elctbl_chc_popl_id = pel.pil_elctbl_chc_popl_id
               AND pel.per_in_ler_id = p_pil_rec.per_in_ler_id
               AND epe.elctbl_flag = 'Y'
               AND epe.elig_flag = 'Y'
               AND copd.oipl_id = epe.oipl_id
               AND copd.plip_id = epe.plip_id
               AND copd.pgm_id =  epe.pgm_id -- As required for perf.
               AND copd.pl_id = epe.pl_id -- As required for perf.
               AND opt.opt_id = copd.opt_id
               AND p_pil_rec.lf_evt_ocrd_dt BETWEEN opt.effective_start_date
                                                AND opt.effective_end_date
               AND (epe.prtt_enrt_rslt_id IS NULL
                    OR NOT EXISTS (
                   SELECT null
                     FROM ben_prtt_enrt_rslt_f pen
                    WHERE pen.prtt_enrt_rslt_id = epe.prtt_enrt_rslt_id
                      AND pen.per_in_ler_id = p_pil_rec.per_in_ler_id
                      AND pen.prtt_enrt_rslt_stat_cd IS NULL
                      AND pen.enrt_cvg_thru_dt = hr_api.g_eot
                      AND pen.effective_end_date = hr_api.g_eot
                      AND pen.effective_start_date = pel.enrt_perd_strt_dt))
            ) ee
        );

--    dbg('Leaving ' || l_procedure);
EXCEPTION
    WHEN OTHERS THEN
        dbg('Error ' || l_procedure);
        OUTPUT ('ERROR '||SQLERRM);
        RAISE;
END collect_eligible_evt;

--
-- ----------------------------------------------------------------------------
-- COLLECT_ELCN_EVT (FULL REFRESH Overloaded)
-- This procedure includes the logic for collection Election Events Fact.
-- ----------------------------------------------------------------------------
--
PROCEDURE collect_elcn_evt (p_pil_rec G_PIL_REC_TYPE) IS
    dml_errors          EXCEPTION;
    PRAGMA exception_init(dml_errors, -24381);

  l_procedure VARCHAR2(100) := g_package || 'collect_elcn_evt';

BEGIN
--    dbg('Entering ' || l_procedure);
    --
    IF (g_collect_oe_only = 'Y' AND g_full_refresh = 'Y') THEN
        -- If Only Current Open Enrollment is being Collected,
        -- Delete any stray records, if present.
        DELETE from hri_mb_ben_elctn_evnt_ct
         WHERE person_id = p_pil_rec.person_id
           AND asnd_lf_evt_dt = p_pil_rec.lf_evt_ocrd_dt;
         --
    END IF;
    -- Populate Benefit Election Event Fact
    INSERT INTO hri_mb_ben_elctn_evnt_ct
        ( elig_ind
        ,enrt_ind
        ,not_enrt_ind
        ,dflt_ind
        ,ler_status_cd
        ,voidd_ind
        ,bckdt_ind
        ,procd_ind
        ,strtd_ind
        ,change_date
        ,effective_start_date
        ,effective_end_date
        ,person_id
        ,asnd_lf_evt_dt
        ,enrt_perd_id
        ,per_in_ler_id
        ,pgm_id
        ,pil_elctbl_chc_popl_id )
        (SELECT DECODE (pel.pil_elctbl_popl_stat_cd,'BCKDT',0,'VOIDD',0,1) elig_ind
               ,(CASE WHEN (pel.pil_elctbl_popl_stat_cd NOT IN ('BCKDT','VOIDD')
                            AND (pel.elcns_made_dt IS NOT NULL)) -- 4721802: Not counting Automatics
                      THEN 1
                      ELSE 0 END) enrt_ind
               ,(CASE WHEN (pel.pil_elctbl_popl_stat_cd NOT IN ('BCKDT','VOIDD')
                            AND pel.elcns_made_dt IS NULL
                            -- AND pel.auto_asnd_dt IS NULL -- 4568414
                            AND pel.dflt_asnd_dt IS NULL)
                      THEN 1
                      ELSE 0 END) not_enrt_ind
               ,(CASE WHEN (pel.pil_elctbl_popl_stat_cd NOT IN ('BCKDT','VOIDD')
                            AND pel.elcns_made_dt IS NULL
                            AND pel.auto_asnd_dt IS NULL -- 4568414
                            AND pel.dflt_asnd_dt IS NOT NULL)
                      THEN 1
                      ELSE 0 END) dflt_ind
               ,(CASE WHEN (pil.per_in_ler_stat_cd = 'BCKDT'
                            AND ppl.ptnl_ler_for_per_stat_cd = 'MNL')  -- 4514159
                      THEN 'MNL'
                      WHEN (pil.per_in_ler_stat_cd = 'BCKDT'
                            AND ppl.ptnl_ler_for_per_stat_cd <> 'MNL') -- 4514159
                      THEN 'BCKDT'
                      ELSE pil.per_in_ler_stat_cd END ) per_in_ler_stat_cd
               ,DECODE(pil.per_in_ler_stat_cd,'VOIDD',1,0) voidd_ind
               ,DECODE(pil.per_in_ler_stat_cd,'BCKDT',1,0) bckdt_ind
               ,DECODE(pil.per_in_ler_stat_cd,'PROCD',1,0) procd_ind
               ,DECODE(pil.per_in_ler_stat_cd,'STRTD',1,0) strtd_ind
               ,pil.lf_evt_ocrd_dt change_date
               ,pil.lf_evt_ocrd_dt effective_start_date
               ,hr_api.g_eot effective_end_date
               ,pil.person_id person_id
               ,pil.lf_evt_ocrd_dt asnd_lf_evt_dt
               ,pel.enrt_perd_id  enrt_perd_id
               ,pil.per_in_ler_id per_in_ler_id
               ,pel.pgm_id pgm_id
               ,pel.pil_elctbl_chc_popl_id pil_elctbl_chc_popl_id
          FROM ben_pil_elctbl_chc_popl pel,
               ben_per_in_ler pil,
               ben_ptnl_ler_for_per ppl
         WHERE pel.per_in_ler_id = pil.per_in_ler_id
           AND ppl.ptnl_ler_for_per_id = pil.ptnl_ler_for_per_id
           AND pil.per_in_ler_id = p_pil_rec.per_in_ler_id
           );
--    dbg('Leaving ' || l_procedure);
EXCEPTION
    WHEN OTHERS THEN
        dbg('Error ' || l_procedure);
        OUTPUT ('ERROR '||SQLERRM);
        RAISE;
END collect_elcn_evt;

--
-- ----------------------------------------------------------------------------
-- COLLECT_ELCN_EVT (INCREMENTAL REFRESH Overloaded)
-- This procedure includes the logic for collection Election Events Fact.
-- ----------------------------------------------------------------------------
--
PROCEDURE collect_elcn_evt (p_person_id NUMBER
                           ,p_per_in_ler_id NUMBER) IS
    dml_errors          EXCEPTION;
    PRAGMA exception_init(dml_errors, -24381);

    l_procedure VARCHAR2(100) := g_package || 'collect_elcn_evt';

    CURSOR c_pil IS
    SELECT  pil.per_in_ler_id
           ,pil.person_id
           ,pil.lf_evt_ocrd_dt
           ,(CASE WHEN (pil.per_in_ler_stat_cd = 'BCKDT'
                        AND ppl.ptnl_ler_for_per_stat_cd = 'MNL')  -- 4514159
                  THEN 'MNL'
                  WHEN (pil.per_in_ler_stat_cd = 'BCKDT'
                       AND ppl.ptnl_ler_for_per_stat_cd <> 'MNL') -- 4514159
                  THEN 'BCKDT'
                  ELSE pil.per_in_ler_stat_cd END ) per_in_ler_stat_cd
           ,pil.business_group_id
      FROM ben_per_in_ler pil,
           ben_ptnl_ler_for_per ppl
     WHERE pil.per_in_ler_id = p_per_in_ler_id
       AND ppl.ptnl_ler_for_per_id = pil.ptnl_ler_for_per_id;

     l_pil_rec G_PIL_REC_TYPE;

     CURSOR c_bckdt_void_pil IS
     SELECT per_in_ler_id,
            pil.per_in_ler_stat_cd
       FROM ben_per_in_ler pil,
            ben_ler_f ler
     WHERE pil.lf_evt_ocrd_dt = l_pil_rec.lf_evt_ocrd_dt
       AND pil.ler_id = ler.ler_id
       AND ler.typ_cd = 'SCHEDDO'
       AND pil.person_id = p_person_id
       AND pil.per_in_ler_stat_cd IN ('BCKDT','VOIDD')
       AND pil.lf_evt_ocrd_dt BETWEEN ler.effective_start_date
                                  AND ler.effective_end_date;

    CURSOR c_elcn_evt IS
    SELECT null
      FROM HRI_EQ_BEN_ELCTN_EVTS pelq
      WHERE pelq.person_id = p_person_id
        AND pelq.lf_evt_ocrd_dt = l_pil_rec.lf_evt_ocrd_dt
        AND pelq.per_in_ler_id = p_per_in_ler_id
        AND event_cd = 'INSERT';

    CURSOR c_upd_elcn IS
    SELECT  1 elig_ind
            ,(CASE WHEN (pelq.elcns_made_dt IS NOT NULL )
                        --OR pelq.auto_asnd_dt IS NOT NULL) -- 4721802: Not Counting Automatics
                   THEN 1
                   ELSE 0 END) enrt_ind
            ,(CASE WHEN (pelq.elcns_made_dt IS NULL
                    AND pelq.dflt_asnd_dt IS NULL) -- 4721802
                    --AND pelq.auto_asnd_dt IS NULL)
                 THEN 1
                 ELSE 0 END) not_enrt_ind
            ,(CASE WHEN (pelq.elcns_made_dt IS NULL
                    AND pelq.auto_asnd_dt IS NULL
                    AND pelq.dflt_asnd_dt IS NOT NULL)
                 THEN 1
                 ELSE 0 END) dflt_ind
            ,NVL(pelq.pil_elctbl_popl_stat_cd,'STRTD') pil_elctbl_popl_stat_cd
            ,DECODE(pelq.pil_elctbl_popl_stat_cd,'VOIDD',1,0) voidd_ind
            ,DECODE(pelq.pil_elctbl_popl_stat_cd,'BCKDT',1,0) bckdt_ind
            ,DECODE(pelq.pil_elctbl_popl_stat_cd,'PROCD',1,0) procd_ind
            ,DECODE(pelq.pil_elctbl_popl_stat_cd,'STRTD',1,NULL,1,0) strtd_ind
            ,pelq.lf_evt_ocrd_dt change_date
            ,pelq.lf_evt_ocrd_dt effective_start_date
            ,hr_api.g_eot effective_end_date
            ,pelq.person_id person_id
            ,pelq.lf_evt_ocrd_dt asnd_lf_evt_dt
            ,enpd.enrt_perd_id  enrt_perd_id
            ,pelq.per_in_ler_id per_in_ler_id
            ,pelq.pgm_id pgm_id
            ,pelq.pil_elctbl_chc_popl_id pil_elctbl_chc_popl_id
       FROM hri_eq_ben_elctn_evts pelq,
            hri_cs_time_benrl_prd_ct enpd
      WHERE pelq.pil_elctbl_popl_stat_cd IN ('STRTD','PROCD')
        AND pelq.event_cd = 'UPDATE'
        AND pelq.per_in_ler_id = p_per_in_ler_id
        AND pelq.person_id = p_person_id
        AND pelq.pgm_id = enpd.pgm_id
        AND enpd.asnd_lf_evt_dt = pelq.lf_evt_ocrd_dt
        AND pelq.last_update_date =
                 (SELECT MAX(pelq1.last_update_date)
                    FROM hri_eq_ben_elctn_evts pelq1
                   WHERE pelq1.per_in_ler_id = p_per_in_ler_id
                     AND pelq1.person_id = p_person_id
                     AND pelq1.pgm_id = pelq.pgm_id
                     AND pelq1.lf_evt_ocrd_dt = pelq.lf_evt_ocrd_dt
                     AND pelq1.event_cd = 'UPDATE'
                     AND pelq1.pil_elctbl_popl_stat_cd IN ('STRTD','PROCD')
                 );
    --
    TYPE g_pel_tab_type IS TABLE OF c_upd_elcn%ROWTYPE
    INDEX BY BINARY_INTEGER;
    --
    l_elcn_evt_tbl g_pel_tab_type;
    --
    l_dummy VARCHAR2(2);
    --
BEGIN
--    dbg('Entering ' || l_procedure);
    --
    OPEN c_pil;
    FETCH c_pil INTO l_pil_rec;
    CLOSE c_pil;

    IF (l_pil_rec.per_in_ler_stat_cd IN ('BCKDT','VOIDD','MNL')) THEN
    -- For Backed/Voided Elections ...

        -- 1. Delete Eligibility/Enrollment events ...
        DELETE FROM hri_mb_ben_eligenrl_evnt_ct penc
         WHERE penc.person_id = p_person_id
           AND penc.asnd_lf_evt_dt = l_pil_rec.lf_evt_ocrd_dt
           AND penc.per_in_ler_id = p_per_in_ler_id;

        -- 2. Update Election Events to Reset Flags.
        UPDATE hri_mb_ben_elctn_evnt_ct pelc
           SET  pelc.elig_ind = 0
               ,pelc.enrt_ind = 0
               ,pelc.not_enrt_ind = 0
               ,pelc.dflt_ind = 0
               ,pelc.ler_status_cd = l_pil_rec.per_in_ler_stat_cd
               ,pelc.voidd_ind = 0
               ,pelc.bckdt_ind = 0
               ,pelc.procd_ind = 0
               ,pelc.strtd_ind = 0
               ,pelc.effective_start_date = l_pil_rec.lf_evt_ocrd_dt
               ,pelc.effective_end_date = hr_api.g_eot
               ,pelc.pil_elctbl_chc_popl_id = NULL
         WHERE pelc.person_id = p_person_id
           AND pelc.asnd_lf_evt_dt = l_pil_rec.lf_evt_ocrd_dt
           AND pelc.per_in_ler_id = l_pil_rec.per_in_ler_id;
        --
    ELSIF (l_pil_rec.per_in_ler_stat_cd IN ('STRTD','PROCD')) THEN
    -- For Started/Process Elections ...

        FOR i IN c_bckdt_void_pil LOOP
        -- 1. Delete Any Back-out / Voided  Enrollment Events
            DELETE FROM hri_mb_ben_eligenrl_evnt_ct penc
             WHERE penc.person_id = p_person_id
               AND penc.asnd_lf_evt_dt = l_pil_rec.lf_evt_ocrd_dt
               AND penc.per_in_ler_id = i.per_in_ler_id;

        -- 2. Delete Any Back-out / Voided  Eligibility Events
            DELETE FROM hri_mb_ben_elctn_evnt_ct pelc
             WHERE pelc.person_id = p_person_id
               AND pelc.asnd_lf_evt_dt = l_pil_rec.lf_evt_ocrd_dt
               AND pelc.per_in_ler_id = i.per_in_ler_id;
        --
        END LOOP;
        -- Check if the Election event is 'INSERT'
        OPEN c_elcn_evt;
        FETCH c_elcn_evt into l_dummy;
        IF c_elcn_evt%FOUND THEN
        -- Check if the Election event is 'INSERT'
            -- 3. Collect Election Event, using Full Refresh Mode.
            collect_elcn_evt (p_pil_rec => l_pil_rec);
            --
            -- 4. Collect Eligibility for the Event..
            collect_eligible_evt(p_pil_rec => l_pil_rec);

        ELSE
        -- If the Election event is 'UPDATE'
            -- Update Flags for Election Events..
            OPEN c_upd_elcn;
            FETCH c_upd_elcn BULK COLLECT INTO l_elcn_evt_tbl;
            CLOSE c_upd_elcn;
            --
            IF (l_elcn_evt_tbl.COUNT > 0) THEN
                FOR i IN l_elcn_evt_tbl.FIRST..l_elcn_evt_tbl.LAST LOOP
                    --
                    UPDATE HRI_MB_BEN_ELCTN_EVNT_CT pelc
                       SET  pelc.elig_ind = l_elcn_evt_tbl(i).elig_ind
                           ,pelc.enrt_ind = l_elcn_evt_tbl(i).enrt_ind
                           ,pelc.not_enrt_ind = l_elcn_evt_tbl(i).not_enrt_ind
                           ,pelc.dflt_ind = l_elcn_evt_tbl(i).dflt_ind
                           ,pelc.ler_status_cd = l_elcn_evt_tbl(i).pil_elctbl_popl_stat_cd
                           ,pelc.voidd_ind = l_elcn_evt_tbl(i).voidd_ind
                           ,pelc.bckdt_ind = l_elcn_evt_tbl(i).bckdt_ind
                           ,pelc.procd_ind = l_elcn_evt_tbl(i).procd_ind
                           ,pelc.strtd_ind = l_elcn_evt_tbl(i).strtd_ind
                           ,pelc.effective_start_date = l_elcn_evt_tbl(i).effective_start_date
                           ,pelc.effective_end_date = l_elcn_evt_tbl(i).effective_end_date
                           ,pelc.enrt_perd_id = l_elcn_evt_tbl(i).enrt_perd_id
                           ,pelc.pil_elctbl_chc_popl_id = l_elcn_evt_tbl(i).pil_elctbl_chc_popl_id
                     WHERE pelc.person_id = l_elcn_evt_tbl(i).person_id
                       AND pelc.asnd_lf_evt_dt = l_elcn_evt_tbl(i).asnd_lf_evt_dt
                       AND pelc.pgm_id = l_elcn_evt_tbl(i).pgm_id;
                    --
                END LOOP;
                --
             END IF;
         END IF;
        CLOSE c_elcn_evt;

        -- 5. If Elections Made Date is populated, set the Default Flag in Eligible Events to 0.
        UPDATE hri_mb_ben_eligenrl_evnt_ct penc
           SET penc.dflt_ind = 0
               ,waive_dflt_ind = 0
               ,waive_expl_ind = DECODE(penc.waive_dflt_ind,1,1,0)
         WHERE penc.enrt_ind = 1
           AND penc.person_id = p_person_id
           AND penc.asnd_lf_evt_dt = l_pil_rec.lf_evt_ocrd_dt
           AND penc.per_in_ler_id = l_pil_rec.per_in_ler_id
           AND EXISTS
                   (SELECT NULL
                      FROM HRI_EQ_BEN_ELCTN_EVTS pelq
                     WHERE pelq.event_cd = 'UPDATE'
                       AND pelq.pil_elctbl_popl_stat_cd IN ('STRTD','PROCD')
                       AND pelq.per_in_ler_id = p_per_in_ler_id
                       AND pelq.person_id = p_person_id
                       AND pelq.lf_evt_ocrd_dt = l_pil_rec.lf_evt_ocrd_dt
                       AND pelq.elcns_made_dt IS NOT NULL);

    END IF;
--    dbg('Leaving ' || l_procedure);
EXCEPTION
    WHEN OTHERS THEN
        dbg('Error ' || l_procedure);
        OUTPUT ('ERROR '||SQLERRM);
        RAISE;
END collect_elcn_evt;

--
-- ----------------------------------------------------------------------------
-- COLLECT_ELIGENRL_EVT (INCREMENTAL REFRESH Overloaded)
-- This procedure includes the logic for collecting Eligibility
-- and Enrollment Events Fact.
-- ----------------------------------------------------------------------------
--
PROCEDURE collect_eligenrl_evt (p_person_id NUMBER
                               ,p_per_in_ler_id NUMBER
                               ,p_lf_evt_ocrd_dt DATE) IS

    CURSOR c_eee_end_date IS
        SELECT PRTTQ.eee_end_dt, penc.rowid row_id
          FROM (SELECT NVL(MIN(penq.event_date-1),hr_api.g_eot) eee_end_dt,
                       copd.compobj_sk_pk,
                       penq.lf_evt_ocrd_dt
                  FROM hri_eq_ben_eligenrl_evts penq,
                       hri_cs_compobj_ct copd
                 WHERE penq.per_in_ler_id = p_per_in_ler_id
                   AND penq.pgm_id = copd.pgm_id
                   AND copd.oipl_id = NVL(penq.oipl_id, -1)
                   AND copd.pl_id = penq.pl_id
                 GROUP BY penq.lf_evt_ocrd_dt, copd.compobj_sk_pk  ) PRTTQ,
               hri_mb_ben_eligenrl_evnt_ct penc
         WHERE penc.asnd_lf_evt_dt = PRTTQ.lf_evt_ocrd_dt
           AND penc.person_id = p_person_id
           AND penc.per_in_ler_id = p_per_in_ler_id
           AND (PRTTQ.eee_end_dt + 1) > penc.effective_start_date
           AND penc.effective_end_date = hr_api.g_eot
           AND PRTTQ.compobj_sk_pk = penc.compobj_sk_pk;

    l_eee_end_dt_tbl g_date_tab_type;
    l_row_id_tbl  g_rowid_tab_type;

    dml_errors          EXCEPTION;
    PRAGMA exception_init(dml_errors, -24381);

  l_procedure VARCHAR2(100) := g_package || 'collect_eligenrl_evt';

BEGIN
--    dbg('Entering ' || l_procedure);
    --1. Update Records for which Results were ZAPPED / DE-ENROLLED
    -- 4579556 - Changed this from Delete to Update.
    UPDATE hri_mb_ben_eligenrl_evnt_ct penc
       SET enrt_ind = 0
           ,not_enrt_ind = 1
           ,dflt_ind = 0
           ,waive_expl_ind = 0
           ,waive_dflt_ind = 0
      WHERE (penc.compobj_sk_pk, penc.asnd_lf_evt_dt, penc.person_id)
               IN  (SELECT copd.compobj_sk_pk
                           ,penq.lf_evt_ocrd_dt
                           ,penq.person_id
                      FROM hri_eq_ben_eligenrl_evts penq,
                           hri_cs_compobj_ct copd
                     WHERE penq.per_in_ler_id = p_per_in_ler_id
                       AND penq.event_cd IN ('ZAP','DE-ENRD')
                       AND penq.pgm_id = copd.pgm_id
                       AND copd.oipl_id = NVL(penq.oipl_id, -1)
                       AND copd.pl_id = penq.pl_id);

    --2. End date exising records to one day prior.
    l_eee_end_dt_tbl.delete;
    l_row_id_tbl.delete;

    OPEN c_eee_end_date;
    FETCH c_eee_end_date BULK COLLECT INTO l_eee_end_dt_tbl, l_row_id_tbl;
    CLOSE c_eee_end_date;
    --
    IF (l_eee_end_dt_tbl.COUNT > 0) THEN
        FORALL i IN l_eee_end_dt_tbl.FIRST..l_eee_end_dt_tbl.LAST SAVE EXCEPTIONS
            UPDATE hri_mb_ben_eligenrl_evnt_ct penc
               SET penc.effective_end_date =  l_eee_end_dt_tbl(i)
             WHERE ROWID = l_row_id_tbl(i);
     END IF;
     --
    --3. Merge remaining events.
    MERGE INTO HRI_MB_BEN_ELIGENRL_EVNT_CT penc
    USING (
            SELECT  copd.compobj_sk_pk
                   ,enpd.enrt_perd_id
                   ,penq.lf_evt_ocrd_dt
                   ,penq.event_date
                   ,penq.event_date effective_start_date
                   ,NVL(LAG(penq.event_date-1)
                    OVER (PARTITION BY penq.lf_evt_ocrd_dt, copd.compobj_sk_pk
                              ORDER BY penq.lf_evt_ocrd_dt, copd.compobj_sk_pk, penq.event_date, penq.creation_date)
                     , hr_api.g_eot) effective_end_date
                   ,penq.person_id
                   ,penq.prtt_enrt_rslt_id
                   ,penq.per_in_ler_id
                   ,1 elig_ind
                   ,penq.enrt_ind
                   ,(CASE WHEN (penq.event_cd IN ('DE-ENRD','ZAP'))  -- Only 'ENRD' events come up.. so this may not be necessary.
                          THEN 1
                          ELSE 0 END ) not_enrt_ind
                   ,penq.dflt_ind
                   ,(CASE WHEN (penq.dflt_ind = 0
                               AND penq.enrt_ind = 1
                               AND (opt.invk_wv_opt_flag = 'Y'
                                   OR (opt.opt_id IS NULL AND pln.invk_dcln_prtn_pl_flag = 'Y')) )
                          THEN 1
                          ELSE 0 END ) waive_expl_ind
                   ,(CASE WHEN (penq.dflt_ind = 1
                               AND penq.enrt_ind = 1
                               AND (opt.invk_wv_opt_flag = 'Y'
                                   OR (opt.opt_id IS NULL AND pln.invk_dcln_prtn_pl_flag = 'Y')) )
                          THEN 1
                          ELSE 0 END ) waive_dflt_ind
              FROM HRI_EQ_BEN_ELIGENRL_EVTS penq,
                   hri_cs_time_benrl_prd_ct enpd,
                   hri_cs_compobj_ct copd,
                   ben_opt_f opt,
                   ben_pl_f pln
             WHERE penq.per_in_ler_id = p_per_in_ler_id
               AND penq.event_cd IN ('ENRD') --,'DE-ENRD')
               AND opt.opt_id(+) = NVL(copd.opt_id,-1)
               AND pln.pl_id = copd.pl_id
               AND penq.pgm_id = copd.pgm_id
               AND enpd.pgm_id = penq.pgm_id
               AND p_lf_evt_ocrd_dt between opt.effective_start_date(+) AND opt.effective_end_date(+)
               AND p_lf_evt_ocrd_dt between pln.effective_start_date AND pln.effective_end_date
               AND enpd.asnd_lf_evt_dt = penq.lf_evt_ocrd_dt
               AND copd.oipl_id = NVL(penq.oipl_id, -1)
               AND copd.pl_id = penq.pl_id
               AND NOT EXISTS
                    (SELECT null -- Picks up only the latest Event from queue.
                       FROM HRI_EQ_BEN_ELIGENRL_EVTS penq1
                      WHERE penq1.per_in_ler_id = p_per_in_ler_id
                        AND NVL(penq1.oipl_id,-1) = NVL(penq.oipl_id,-1)
                        AND penq1.pl_id = penq.pl_id
                        AND penq1.pgm_id = penq.pgm_id
                        AND NVL(penq1.last_update_date,TRUNC(SYSDATE)) > NVL(penq.last_update_date,TRUNC(SYSDATE))
                     )
             ) PRTTQ
      ON (PRTTQ.compobj_sk_pk = penc.compobj_sk_pk
          AND PRTTQ.lf_evt_ocrd_dt = penc.asnd_lf_evt_dt
          AND PRTTQ.event_date = penc.change_date
          AND PRTTQ.person_id = penc.person_id)
      WHEN MATCHED THEN
        UPDATE SET penc.elig_ind = PRTTQ.elig_ind,
                   penc.enrt_ind = PRTTQ.enrt_ind,
                   penc.dflt_ind = PRTTQ.dflt_ind,
                   penc.not_enrt_ind = PRTTQ.not_enrt_ind,
                   penc.waive_expl_ind = PRTTQ.waive_expl_ind,
                   penc.waive_dflt_ind = PRTTQ.waive_dflt_ind
      WHEN NOT MATCHED THEN
           INSERT (compobj_sk_pk
                ,enrt_perd_id
                ,asnd_lf_evt_dt
                ,change_date
                ,effective_start_date
                ,effective_end_date
                ,person_id
                ,prtt_enrt_rslt_id
                ,per_in_ler_id
                ,elig_ind
                ,enrt_ind
                ,not_enrt_ind
                ,dflt_ind
                ,waive_expl_ind
                ,waive_dflt_ind)
           VALUES (PRTTQ.compobj_sk_pk
                ,PRTTQ.enrt_perd_id
                ,PRTTQ.lf_evt_ocrd_dt
                ,PRTTQ.event_date
                ,PRTTQ.effective_start_date
                ,PRTTQ.effective_end_date
                ,PRTTQ.person_id
                ,PRTTQ.prtt_enrt_rslt_id
                ,PRTTQ.per_in_ler_id
                ,PRTTQ.elig_ind
                ,PRTTQ.enrt_ind
                ,PRTTQ.not_enrt_ind
                ,PRTTQ.dflt_ind
                ,PRTTQ.waive_expl_ind
                ,PRTTQ.waive_dflt_ind);

    -- 4. Delete Events which are VOIDED.
     DELETE FROM HRI_MB_BEN_ELIGENRL_EVNT_CT penc
      WHERE penc.person_id = p_person_id
        AND penc.per_in_ler_id = p_per_in_ler_id
        AND penc.effective_start_date > penc.effective_end_date;
        --NULL;
--    dbg('Leaving ' || l_procedure);
EXCEPTION
    WHEN OTHERS THEN
        dbg('Error ' || l_procedure);
        OUTPUT('SQLERRM '|| SQLERRM);
        RAISE;
END collect_eligenrl_evt;
--
-- ----------------------------------------------------------------------------
-- COLLECT_ELIGENRL_EVT (FULL REFRESH Overloaded)
-- This procedure includes the logic for collecting Eligibility
-- and Enrollment Events Fact.
-- ----------------------------------------------------------------------------
--
PROCEDURE collect_eligenrl_evt (p_pil_rec G_PIL_REC_TYPE) IS

    dml_errors          EXCEPTION;
    PRAGMA exception_init(dml_errors, -24381);

    l_procedure VARCHAR2(100) := g_package || 'collect_eligenrl_evt';

BEGIN
--    dbg('Entering ' || l_procedure);
    --
    IF (g_collect_oe_only = 'Y') THEN
        -- If Only Current Open Enrollment is being Collected,
        -- Delete any stray records, if present.
        DELETE from hri_mb_ben_eligenrl_evnt_ct
         WHERE person_id = p_pil_rec.person_id
           AND asnd_lf_evt_dt = p_pil_rec.lf_evt_ocrd_dt
           AND per_in_ler_id = p_pil_rec.per_in_ler_id;
        --
    END IF;
    --
    -- Populate Benefits Eligbility and Enrollment Fact
    INSERT INTO HRI_MB_BEN_ELIGENRL_EVNT_CT
            (change_date
            ,effective_start_date
            ,effective_end_date
            ,compobj_sk_pk
            ,asnd_lf_evt_dt
            ,person_id
            ,per_in_ler_id
            ,enrt_perd_id
            ,prtt_enrt_rslt_id
            ,elig_ind
            ,enrt_ind
            ,not_enrt_ind
            ,dflt_ind
            ,waive_expl_ind
            ,waive_dflt_ind)
   (SELECT  ee.change_date change_date,
            ee.change_date effective_start_date,
            NVL(LEAD(ee.change_date - 1)
                  OVER (PARTITION BY compobj_sk_pk
                            ORDER BY compobj_sk_pk, ee.change_date), hr_api.g_eot) effective_end_date,
            ee.compobj_sk_pk,
            p_pil_rec.lf_evt_ocrd_dt asnd_lf_evt_dt ,
            p_pil_rec.person_id person_id,
            p_pil_rec.per_in_ler_id per_in_ler_id,
            ee.enrt_perd_id,
            ee.prtt_enrt_rslt_id,
            ee.elig_ind,
            ee.enrt_ind,
            ee.not_enrt_ind,
            ee.dflt_ind,
            ee.waive_expl_ind,
            ee.waive_dflt_ind
    FROM (
            -- The FIRST 2 UNIONS.. retuns all Electable Choices if Enrollments DOES NOT start on the same day.
            -- First UNION gets PLIPs and OIPL IS NULL
            SELECT pel.enrt_perd_strt_dt change_date,
                   copd.compobj_sk_pk compobj_sk_pk,
                   pel.enrt_perd_id,
                   epe.prtt_enrt_rslt_id  prtt_enrt_rslt_id,
                   1 elig_ind,
                   (CASE WHEN (epe.crntly_enrd_flag = 'Y')
                         THEN 1
                         ELSE 0 END )  enrt_ind,
                   (CASE WHEN (epe.crntly_enrd_flag = 'Y')
                         THEN 0
                         ELSE 1 END )  not_enrt_ind,
                   -- DFLT_IND -> If Currently Enrolled and Default Comp Object
                   (CASE WHEN (pel.elcns_made_dt IS NULL
                              AND pel.dflt_asnd_dt IS NOT NULL
                              AND epe.crntly_enrd_flag = 'Y'
                              AND epe.dflt_flag = 'Y')
                         THEN 1
                         ELSE 0 END) dflt_ind,
                    -- WAIVE_EXPL_IND -> If Currently Enrolled and Waive Opt/Pln and Not Default Comp.Object
                   (CASE WHEN (pel.elcns_made_dt IS NOT NULL
                               AND epe.crntly_enrd_flag = 'Y'
                               AND pln.invk_dcln_prtn_pl_flag = 'Y')
                         THEN 1
                         ELSE 0 END) waive_expl_ind,
                    -- WAIVE_DFLT_IND -> If Currently Enrolled and Waive Opt/Pln and Default Comp.Object
                   (CASE WHEN (pel.elcns_made_dt IS NULL
                               AND pel.dflt_asnd_dt IS NOT NULL
                               AND epe.dflt_flag = 'Y'
                               AND pln.invk_dcln_prtn_pl_flag = 'Y')
                         THEN 1
                         ELSE 0 END) waive_dflt_ind
              FROM ben_elig_per_elctbl_chc epe,
                   ben_pil_elctbl_chc_popl pel,
                   hri_cs_compobj_ct copd,
                   ben_pl_f pln
             WHERE epe.pil_elctbl_chc_popl_id = pel.pil_elctbl_chc_popl_id
               AND pel.per_in_ler_id = p_pil_rec.per_in_ler_id
               AND epe.elctbl_flag = 'Y'
               AND epe.elig_flag = 'Y'
               AND copd.oipl_id = -1
               AND epe.oipl_id IS NULL
               AND copd.plip_id = epe.plip_id
               AND copd.pgm_id =  epe.pgm_id -- As required for Perf.
               AND copd.pl_id = epe.pl_id -- As required for Perf.
               AND pln.pl_id = copd.pl_id
               AND p_pil_rec.lf_evt_ocrd_dt BETWEEN pln.effective_start_date
                                                AND pln.effective_end_date
               AND (epe.prtt_enrt_rslt_id IS NULL
                    OR NOT EXISTS (
                   SELECT null
                     FROM ben_prtt_enrt_rslt_f pen
                    WHERE pen.prtt_enrt_rslt_id = epe.prtt_enrt_rslt_id
                      AND pen.per_in_ler_Id = p_pil_rec.per_in_ler_id
                      AND pen.prtt_enrt_rslt_stat_cd IS NULL
                      AND pen.enrt_cvg_thru_dt = hr_api.g_eot
                      AND pen.effective_end_date = hr_api.g_eot
                      AND pen.effective_start_date = pel.enrt_perd_strt_dt))
            UNION ALL
            -- Second UNION gets OIPLs
            SELECT pel.enrt_perd_strt_dt change_date,
                   copd.compobj_sk_pk compobj_sk_pk,
                   pel.enrt_perd_id,
                   epe.prtt_enrt_rslt_id  prtt_enrt_rslt_id,
                   1 elig_ind,
                   (CASE WHEN (epe.crntly_enrd_flag = 'Y')
                         THEN 1
                         ELSE 0 END )  enrt_ind,
                   (CASE WHEN (epe.crntly_enrd_flag = 'Y')
                         THEN 0
                         ELSE 1 END )  not_enrt_ind,
                   -- DFLT_IND -> If Currently Enrolled and Default Comp Object
                   (CASE WHEN (pel.elcns_made_dt IS NULL
                              AND pel.dflt_asnd_dt IS NOT NULL
                              AND epe.crntly_enrd_flag = 'Y'
                              AND epe.dflt_flag = 'Y')
                         THEN 1
                         ELSE 0 END) dflt_ind,
                    -- WAIVE_EXPL_IND -> If Currently Enrolled and Waive Opt/Pln and Not Default Comp.Object
                   (CASE WHEN (pel.elcns_made_dt IS NOT NULL
                               AND epe.crntly_enrd_flag = 'Y'
                               AND opt.invk_wv_opt_flag = 'Y' )
                         THEN 1
                         ELSE 0 END) waive_expl_ind,
                    -- WAIVE_DFLT_IND -> If Currently Enrolled and Waive Opt/Pln and Default Comp.Object
                   (CASE WHEN (pel.elcns_made_dt IS NULL
                               AND pel.dflt_asnd_dt IS NOT NULL
                               AND epe.dflt_flag = 'Y'
                               AND opt.invk_wv_opt_flag = 'Y')
                         THEN 1
                         ELSE 0 END) waive_dflt_ind
              FROM ben_elig_per_elctbl_chc epe,
                   ben_pil_elctbl_chc_popl pel,
                   hri_cs_compobj_ct copd,
                   ben_opt_f opt
             WHERE epe.pil_elctbl_chc_popl_id = pel.pil_elctbl_chc_popl_id
               /* AND pel.per_in_ler_id = p_pil_rec.per_in_ler_id : 4552984 - Perf Fix */
               AND EPE.PER_IN_LER_ID = p_pil_rec.per_in_ler_id
               AND epe.elctbl_flag = 'Y'
               AND epe.elig_flag = 'Y'
               AND copd.oipl_id = epe.oipl_id
               AND copd.plip_id = epe.plip_id
               AND copd.pgm_id =  epe.pgm_id
               AND copd.pl_id = epe.pl_id
               AND opt.opt_id = copd.opt_id
               AND p_pil_rec.lf_evt_ocrd_dt BETWEEN opt.effective_start_date
                                                AND opt.effective_end_date
               AND (epe.prtt_enrt_rslt_id IS NULL
                    OR NOT EXISTS (
                   SELECT null
                     FROM ben_prtt_enrt_rslt_f pen
                    WHERE pen.prtt_enrt_rslt_id = epe.prtt_enrt_rslt_id
                      AND pen.per_in_ler_Id = p_pil_rec.per_in_ler_id
                      AND pen.prtt_enrt_rslt_stat_cd IS NULL
                      AND pen.enrt_cvg_thru_dt = hr_api.g_eot
                      AND pen.effective_end_date = hr_api.g_eot
                      AND pen.effective_start_date = pel.enrt_perd_strt_dt))
            UNION ALL
            -- The 3rd and 4th UNIONs.. returns all Enrollment Results.
            -- 3rd Union gets all PLIPs and OIPL IS NULL
           SELECT /*+ INDEX(epe BEN_ELIG_PER_ELCTBL_CHC_N5) */
                  pen.effective_start_date change_date,
                  copd.compobj_sk_pk compobj_sk_pk,
                  pel.enrt_perd_id,
                  pen.prtt_enrt_rslt_id prtt_enrt_rslt_id,
                  1 elig_ind,
                  1 enrt_ind,
                  0 not_enrt_ind,
                  (CASE WHEN (pel.elcns_made_dt IS NULL
                              AND pel.dflt_asnd_dt IS NOT NULL
                              AND epe.dflt_flag = 'Y')
                        THEN 1
                        ELSE 0 END) dflt_ind,
                  (CASE WHEN (pel.elcns_made_dt IS NOT NULL
                              AND pln.invk_dcln_prtn_pl_flag = 'Y')
                        THEN 1
                        ELSE 0 END) waive_expl_ind,
                  (CASE WHEN (pel.elcns_made_dt IS NULL
                              AND pel.dflt_asnd_dt IS NOT NULL
                              AND epe.dflt_flag = 'Y'
                              AND pln.invk_dcln_prtn_pl_flag = 'Y')
                       THEN 1
                       ELSE 0 END) waive_dflt_ind
             FROM ben_prtt_enrt_rslt_f pen,
                  ben_pil_elctbl_chc_popl pel,
                  hri_cs_compobj_ct copd,
                  ben_elig_per_elctbl_chc epe,
                  ben_pl_f pln
            WHERE pel.per_in_ler_id = p_pil_rec.per_in_ler_id
              AND pen.per_in_ler_id = pel.per_in_ler_id
              AND pen.pgm_id = copd.pgm_id
              AND pen.pgm_id = pel.pgm_id
              AND copd.oipl_id = -1
              AND pen.oipl_id IS NULL
              AND copd.pl_id = pen.pl_id
              AND pen.prtt_enrt_rslt_stat_cd IS NULL
              AND pen.enrt_cvg_thru_dt = hr_api.g_eot
              AND pen.effective_end_date = hr_api.g_eot
              AND epe.prtt_enrt_rslt_id(+) = pen.prtt_enrt_rslt_id
              AND epe.per_in_ler_id(+) = pen.per_in_ler_id
              AND pln.pl_id = copd.pl_id
              AND p_pil_rec.lf_evt_ocrd_dt BETWEEN pln.effective_start_date
                                               AND pln.effective_end_date
        UNION ALL
            -- 4th Union gets all OIPLs
           SELECT /*+ INDEX(epe BEN_ELIG_PER_ELCTBL_CHC_N5) */
                  pen.effective_start_date change_date,
                  copd.compobj_sk_pk compobj_sk_pk,
                  pel.enrt_perd_id,
                  pen.prtt_enrt_rslt_id prtt_enrt_rslt_id,
                  1 elig_ind,
                  1 enrt_ind,
                  0 not_enrt_ind,
                  (CASE WHEN (pel.elcns_made_dt IS NULL
                              AND pel.dflt_asnd_dt IS NOT NULL
                              AND epe.dflt_flag = 'Y')
                        THEN 1
                        ELSE 0 END) dflt_ind,
                  (CASE WHEN (pel.elcns_made_dt IS NOT NULL
                              AND opt.invk_wv_opt_flag = 'Y')
                        THEN 1
                        ELSE 0 END) waive_expl_ind,
                  (CASE WHEN (pel.elcns_made_dt IS NULL
                              AND pel.dflt_asnd_dt IS NOT NULL
                              AND epe.dflt_flag = 'Y'
                              AND opt.invk_wv_opt_flag = 'Y' )
                       THEN 1
                       ELSE 0 END) waive_dflt_ind
             FROM ben_prtt_enrt_rslt_f pen,
                  ben_pil_elctbl_chc_popl pel,
                  hri_cs_compobj_ct copd,
                  ben_elig_per_elctbl_chc epe,
                  ben_opt_f opt
            WHERE /* pel.per_in_ler_id = p_pil_rec.per_in_ler_id : 4552984 - Perf Fix */
                  EPE.PER_IN_LER_ID = p_pil_rec.per_in_ler_id
              AND pen.per_in_ler_id = pel.per_in_ler_id
              AND pen.pgm_id = copd.pgm_id
              AND pen.pgm_id = pel.pgm_id
              AND copd.oipl_id = pen.oipl_id
              AND copd.pl_id = pen.pl_id
              AND pen.prtt_enrt_rslt_stat_cd IS NULL
              AND pen.enrt_cvg_thru_dt = hr_api.g_eot
              AND pen.effective_end_date = hr_api.g_eot
              AND epe.prtt_enrt_rslt_id(+) = pen.prtt_enrt_rslt_id
              AND epe.per_in_ler_id(+) = pen.per_in_ler_id
              AND opt.opt_id = copd.opt_id
              AND p_pil_rec.lf_evt_ocrd_dt BETWEEN opt.effective_start_date
                                               AND opt.effective_end_date
        ) ee
    );
--    dbg('Leaving ' || l_procedure);
EXCEPTION
    WHEN OTHERS THEN
        dbg('Error ' || l_procedure);
        OUTPUT('SQLERRM '|| SQLERRM);
        RAISE;
END collect_eligenrl_evt;

--
-- ----------------------------------------------------------------------------
-- PROCESS_FULL_RANGE
-- Is called in FULL REFRESH mode.
-- ----------------------------------------------------------------------------
--
PROCEDURE process_full_range(
 p_start_object_id           IN             NUMBER
,p_end_object_id             IN             NUMBER) IS

    CURSOR c_pil IS
    SELECT pil.per_in_ler_id,
           pil.person_id,
           pil.lf_evt_ocrd_dt,
           pil.per_in_ler_stat_cd,
           pil.business_group_id
      FROM ben_per_in_ler pil,
           ben_ler_f ler
     WHERE pil.ler_id = ler.ler_id
       AND ler.typ_cd = 'SCHEDDO'
       AND pil.per_in_ler_stat_cd IN ('STRTD','PROCD')
       AND pil.lf_evt_ocrd_dt >= g_global_start_date
       AND pil.person_id BETWEEN p_start_object_id AND p_end_object_id
     UNION
    SELECT pil3.per_in_ler_id,
           pil3.person_id,
           pil3.lf_evt_ocrd_dt,
           pil3.per_in_ler_stat_cd,
           pil3.business_group_id
      FROM ben_per_in_ler pil3,
           (SELECT MAX(pil1.per_in_ler_id) per_in_ler_id
              FROM ben_per_in_ler pil1,
                   ben_ler_f ler1
             WHERE pil1.ler_id = ler1.ler_id
               AND ler1.typ_cd = 'SCHEDDO'
               AND pil1.per_in_ler_stat_cd IN ('BCKDT','VOIDD')
               AND pil1.lf_evt_ocrd_dt >= g_global_start_date
               AND pil1.person_id BETWEEN p_start_object_id AND p_end_object_id
               AND NOT EXISTS (SELECT null
               -- DO NOT pick up Backed/Voided events, if a Started/Processed Event exists.
                                 FROM ben_per_in_ler pil2,
                                      ben_ler_f ler2
                                WHERE pil2.lf_evt_ocrd_dt = pil1.lf_evt_ocrd_dt
                                  AND pil2.person_id = pil1.person_id
                                  AND pil2.per_in_ler_stat_cd IN ('STRTD','PROCD')
                                  AND pil2.ler_id = ler2.ler_id
                                  AND ler2.typ_cd = 'SCHEDDO'
                                  AND pil2.lf_evt_ocrd_dt BETWEEN ler2.effective_start_date
                                                              AND ler2.effective_end_date)
           GROUP BY pil1.person_id, pil1.lf_evt_ocrd_dt
           ) pil4
     WHERE pil4.per_in_ler_id = pil3.per_in_ler_id
       AND pil3.lf_evt_ocrd_dt >= g_global_start_date
     ORDER BY 2, 3;
     --
    CURSOR c_pil_oe IS
    SELECT pil.per_in_ler_id,
           pil.person_id,
           pil.lf_evt_ocrd_dt,
           pil.per_in_ler_stat_cd,
           pil.business_group_id
      FROM ben_per_in_ler pil,
          (SELECT MAX(pil.lf_evt_ocrd_dt) lf_evt_ocrd_dt
                , pil.business_group_id
                , pil.ler_id
             FROM ben_per_in_ler pil,
                  ben_ler_f ler
            WHERE pil.ler_id = ler.ler_id
              AND ler.typ_cd = 'SCHEDDO'
              AND pil.per_in_ler_stat_cd = 'STRTD'
              AND pil.lf_evt_ocrd_dt BETWEEN ler.effective_start_date
                                         AND ler.effective_end_date
            GROUP BY pil.business_group_id, pil.ler_id ) pil1
     WHERE pil.ler_id = pil1.ler_id
       AND pil.business_group_id = pil1.business_group_id
       AND pil.lf_evt_ocrd_dt = pil1.lf_evt_ocrd_dt
       AND pil.lf_evt_ocrd_dt >= g_global_start_date
       AND pil.person_id BETWEEN p_start_object_id AND p_end_object_id
     ORDER BY 2, 3;
    --
    l_pil_tbl g_pil_tab_type;
    l_procedure VARCHAR2(100) := g_package || 'pre_process';
    --
BEGIN
--    dbg('Entering ' || l_procedure);
--    output('Range ' || p_start_object_id || ' : ' || p_end_object_id);
    IF (g_collect_oe_only = 'Y') THEN
      --
      OPEN c_pil_oe;
      FETCH c_pil_oe BULK COLLECT INTO l_pil_tbl;
      CLOSE c_pil_oe;
      --
    ELSE
      --
      OPEN c_pil;
      FETCH c_pil BULK COLLECT INTO l_pil_tbl;
      CLOSE c_pil;
      --
    END IF;
    -- For each PIL collect the Election and Enrollment Information
    IF (l_pil_tbl.count > 0 ) THEN
        FOR i IN l_pil_tbl.FIRST..l_pil_tbl.LAST LOOP
            -- 1. Load the Election Events Fact
            COLLECT_ELCN_EVT (p_pil_rec => l_pil_tbl(i));

            -- 2. Load the Elibility and Enrollment Fact
            IF (l_pil_tbl(i).per_in_ler_stat_cd IN ('STRTD','PROCD')) THEN
                COLLECT_ELIGENRL_EVT (p_pil_rec => l_pil_tbl(i));
            END IF;
            --
        END LOOP;
    END IF;
    --
--    dbg('Leaving ' || l_procedure);
EXCEPTION
    WHEN OTHERS THEN
        dbg('Error ' || l_procedure);
        OUTPUT('SQLERRM '|| SQLERRM);
        RAISE;
END process_full_range;

--
-- ----------------------------------------------------------------------------
-- PROCESS_INCR_RANGE
-- This procedure is called in INCREMENTAL REFRESH mode.
-- ----------------------------------------------------------------------------
--
PROCEDURE process_incr_range(
 p_start_object_id           IN             NUMBER
,p_end_object_id             IN             NUMBER) IS

    CURSOR c_per_in_evt IS
    SELECT DISTINCT penq.person_id, penq.per_in_ler_id, lf_evt_ocrd_dt
      FROM HRI_EQ_BEN_ELIGENRL_EVTS penq
     WHERE penq.person_id BETWEEN p_start_object_id AND p_end_object_id
     ORDER BY penq.person_id, penq.per_in_ler_id;

    CURSOR c_elcn_evt IS
    SELECT DISTINCT pelq.person_id, pelq.per_in_ler_id
      FROM HRI_EQ_BEN_ELCTN_EVTS pelq
      WHERE pelq.person_id BETWEEN p_start_object_id AND p_end_object_id
     ORDER BY pelq.person_id, pelq.per_in_ler_id;
     --
    l_person_tbl g_number_tab_type;
    l_pil_tbl g_number_tab_type;
    l_lf_evt_ocrd_dt_tbl g_date_tab_type;

    l_procedure VARCHAR2(100) := g_package || 'process_incr_range';

BEGIN
--    dbg('Entering ' || l_procedure);
--    dbg('start  ' || p_start_object_id || ' end ' || p_end_object_id );
    -- 1. Load the Election Events Fact
    OPEN c_elcn_evt;
    FETCH c_elcn_evt BULK COLLECT INTO l_person_tbl, l_pil_tbl;
    CLOSE c_elcn_evt;
    --
    IF (l_person_tbl.COUNT > 0) THEN
        FOR i IN l_person_tbl.FIRST..l_person_tbl.LAST LOOP
            --
            COLLECT_ELCN_EVT (p_person_id => l_person_tbl(i)
                             ,p_per_in_ler_id => l_pil_tbl(i));
            --
        END LOOP;
    END IF;
    --
    l_person_tbl.delete;
    l_pil_tbl.delete;

    -- 2. Load the Elibility and Enrollment Fact
    OPEN c_per_in_evt;
    FETCH c_per_in_evt BULK COLLECT INTO l_person_tbl, l_pil_tbl, l_lf_evt_ocrd_dt_tbl;
    CLOSE c_per_in_evt;
    --
    IF (l_person_tbl.COUNT > 0) THEN
        FOR i IN l_person_tbl.FIRST..l_person_tbl.LAST LOOP
            --
            COLLECT_ELIGENRL_EVT (p_person_id => l_person_tbl(i)
                                 ,p_per_in_ler_id => l_pil_tbl(i)
                                 ,p_lf_evt_ocrd_dt => l_lf_evt_ocrd_dt_tbl(i));
            --
        END LOOP;
    END IF;
--    dbg('Leaving ' || l_procedure);
EXCEPTION
    WHEN OTHERS THEN
        dbg('Error ' || l_procedure);
        OUTPUT ('SQLERRM ' || SQLERRM );
        RAISE;
END process_incr_range;

-- ----------------------------------------------------------------------------
-- PROCESS_RANGE
-- This procedure is dynamically called from HRI Multithreading utility.
-- Calls Collection procedures for Election Event and Elibility Enrollment Event Facts
-- for All PER_IN_LER_IDs obtained from the thread range.
-- ----------------------------------------------------------------------------
PROCEDURE process_range(
 errbuf                          OUT NOCOPY VARCHAR2
,retcode                         OUT NOCOPY NUMBER
,p_mthd_action_id            IN             NUMBER
,p_mthd_range_id             IN             NUMBER
,p_start_object_id           IN             NUMBER
,p_end_object_id             IN             NUMBER) IS

    l_procedure VARCHAR2(100) := g_package || 'process_range';

BEGIN
--    dbg('Entering ' || l_procedure);
    -- 1. Set parameters for this thread.
    set_parameters(p_mthd_action_id => p_mthd_action_id
                  ,p_mthd_range_id => p_mthd_range_id);
    --
    IF g_full_refresh = 'Y' THEN
        --
        process_full_range(p_start_object_id   => p_start_object_id
                          ,p_end_object_id     => p_end_object_id);
        --
    ELSE
        --
        process_incr_range(p_start_object_id   => p_start_object_id
                          ,p_end_object_id     => p_end_object_id);
        --
    END IF;
    --
    errbuf  := 'SUCCESS';
    retcode := 0;
--    dbg('Leaving ' || l_procedure);
EXCEPTION
    WHEN others THEN
        dbg('Error ' || l_procedure);
        output('Error encountered while processing range = '|| p_mthd_range_id );
        output('SQLERRM ' || SQLERRM);
        errbuf := SQLERRM;
        retcode := SQLCODE;
        ROLLBACK;
        --
        RAISE;
        --
END process_range;
--
-- ----------------------------------------------------------------------------
-- POST_PROCESS
-- This procedure is dynamically invoked by the HRI Multithreading utility.
-- It performs all the clean up action for after collection.
--       Enable the MV logs
--       Purge the Election and Eligibility Events' incremental events queue
--       Update BIS Refresh Log
-- ----------------------------------------------------------------------------
--
PROCEDURE post_process (p_mthd_action_id NUMBER) IS
  --
  l_dummy1           VARCHAR2(2000);
  l_dummy2           VARCHAR2(2000);
  l_schema           VARCHAR2(400);

  l_procedure VARCHAR2(100) := g_package || 'post_process';
--
BEGIN
    --
    dbg('Entering ' || l_procedure);
    --
    set_parameters(p_mthd_action_id);
    OUTPUT('Full Refresh Flag  : ' || g_full_refresh);
    OUTPUT('Open Enr Only Flag : ' || g_collect_oe_only);
    --
    -- Recreate indexes and gather stats for full refresh or shared HR insert
    --
    IF (fnd_installation.get_app_info('HRI',l_dummy1, l_dummy2, l_schema)) THEN

        IF (g_full_refresh = 'Y') THEN
            --
            OUTPUT('Full Refresh selected - Creating indexes');
            --
             HRI_UTL_DDL.recreate_indexes(
                         p_application_short_name => 'HRI',
                         p_table_name    => g_eligenrl_evnt_table,
                         p_table_owner   => l_schema);
             --
             HRI_UTL_DDL.recreate_indexes(
                         p_application_short_name => 'HRI',
                         p_table_name    => g_elctn_evnt_table,
                         p_table_owner   => l_schema);
            --
        ELSE
            -- Incremental Changes
            -- Purge the Events Queue. The events queue needs to be purged
            -- even after the after full refresh. Recollecting incremental changes
            -- will be useless if a full refresh has been run.
            IF (HRI_BPL_BEN_UTIL.get_archive_events = 'Y') THEN
                -- If Event Queue is to be be archived
                -- Devl in Phase-2
                OUTPUT('Archive Event Queue Table..');
                --
            END IF;
            --
        -- Enable the WHO trigger on the events fact table
        END IF;
        OUTPUT('Truncate Event Queue Tables..');
        -- Required in both modes
        EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || l_schema || '.' || g_elctn_evts_eq_table;
        EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || l_schema || '.' || g_eligenrl_evts_eq_table;
        --
        OUTPUT('Gathering Stats for Election Events');
        --
        fnd_stats.gather_table_stats(l_schema, g_elctn_evnt_table);
--        fnd_stats.gather_table_stats(l_schema, g_eligenrl_evnt_table);
        --
    END IF;
    --
    dbg('Leaving ' || l_procedure);
    --
EXCEPTION
    WHEN OTHERS THEN
        --
        dbg('Error ' || l_procedure);
        OUTPUT(' SQLERRM '|| SQLERRM);
        rollback;
        RAISE;
        --
END post_process;
--

END HRI_OPL_BEN_ELIG_ENRL;

/
