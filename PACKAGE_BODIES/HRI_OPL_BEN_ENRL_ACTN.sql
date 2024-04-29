--------------------------------------------------------
--  DDL for Package Body HRI_OPL_BEN_ENRL_ACTN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OPL_BEN_ENRL_ACTN" AS
/* $Header: hripbeea.pkb 120.1 2005/11/17 03:14:52 bmanyam noship $ */
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   Name  :  HRI_OPL_BEN_ENRL_ACTN
   Purpose  :  Collect Benefits Enrollments Action Fact.

Description:
We try to use HRI_OPL_MULTI_THREAD utility.
Process Flow
===========
1. BEFORE MULTI-THREADING
--------------------------
1.0 PRE_PROCESS
    Full Refresh
    1.0.1 Truncate the Events Table.
    1.0.2 Generate the Person Ranges SQL. (From BEN_PER_IN_LER)

    Incremental Refresh
    1.0.1 Generate the Person Ranges SQL. (From HRI_MB_BEN_ENRLACTN_CT).

2. MULTI-THREADING
-------------------
2.0 PROCESS_RANGE
    2.0.1 Gets a range of objects (per_in_lers) to process
    2.0.2 Calls process_range or process_incr_range for each range.
        2.0.2.1 PROCESS_RANGE (FULL REFRESH)
        2.0.2.2 PROCESS_INCR_RANGE (INCREMENTAL REFRESH)

3. AFTER MULTI-THREADING
-------------------------
3.0 POST_PROCESS
    3.0.1 Logs process end (success/failure)
    3.0.2 Purges event queue
    3.0.3 Full Refresh
    3.0.4 Incremental Refres
    3.0.5 Recreates indexes that were dropped in PRE_PROCESS
    3.0.6 Gathers stats
-- ------------------------------------------------------------------------------
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

--
-- Global variables representing parameters
--
   g_refresh_start_date          DATE;
   g_refresh_end_date            DATE;
   g_full_refresh                VARCHAR2 (5);
   g_collect_oe_only             VARCHAR2 (5);
   g_concurrent_flag             VARCHAR2 (5);
   g_debug_flag                  VARCHAR2 (5);
   g_global_start_date           DATE;

--
-- Set to true to output to a concurrent log file
--
   g_conc_request_flag           BOOLEAN       := FALSE;
--
--
-- Global end of time date initialization from the package hr_general
--
   g_end_of_time                 DATE;
--
-- Global DBI collection start date initialization
--
   g_dbi_collection_start_date   DATE;
--
-- Global Variable for checking if performance rating is to be collected
--
   g_collect_perf_rating         VARCHAR2 (30);
   g_collect_prsn_typ            VARCHAR2 (30);
--
-- Global HRI Multithreading Array
--
   g_mthd_action_array      HRI_ADM_MTHD_ACTIONS%rowtype;
--
-- Global warning indicator
--
   g_raise_warning               VARCHAR2 (1);
--
   g_enrlactn_evnt_table         VARCHAR2 (50) := 'HRI_MB_BEN_ENRLACTN_CT';
   g_package                     VARCHAR2 (50) := 'HRI_OPL_BEN_ENRL_ACTN';
-- -----------------------------------------------------------------------------
-- Inserts row into concurrent program log if debugging is enabled
-- -----------------------------------------------------------------------------
PROCEDURE dbg(p_text  VARCHAR2) IS
BEGIN
    --
       HRI_BPL_CONC_LOG.dbg(p_text);
    --
END dbg;
--
-- -----------------------------------------------------------------------------
-- Inserts row into concurrent program log
-- -----------------------------------------------------------------------------
   PROCEDURE output (p_text VARCHAR2)
   IS
   --
   BEGIN
      --
      -- Write to the concurrent request log if called from a concurrent request
      --
      IF (g_conc_request_flag = TRUE)
      THEN
         --
         -- Put text to log file
         --
         fnd_file.put_line (fnd_file.LOG, p_text);
      --
      ELSE
         --
         hr_utility.set_location (p_text, 999);
      --
      END IF;
   --
   END output;

  -- ----------------------------------------------------------------------------
  -- |--------------------------< RUN_SQL_STMT_NOERR >--------------------------|
  -- ----------------------------------------------------------------------------
  --
  -- Runs given sql statement dynamically without raising an error
  --
  PROCEDURE run_sql_stmt_noerr( p_sql_stmt   VARCHAR2 )
  IS
  --
  BEGIN
    --
    EXECUTE IMMEDIATE p_sql_stmt;
    --
  EXCEPTION WHEN OTHERS THEN
    --
    dbg('Error running sql:');
    dbg(SUBSTR(p_sql_stmt,1,230));
    --
  END run_sql_stmt_noerr;
  --
--
-- ----------------------------------------------------------------------------
-- SET_PARAMETERS
-- sets up parameters required for the process.
-- ----------------------------------------------------------------------------
--
   PROCEDURE set_parameters (
      p_mthd_action_id   IN   NUMBER,
      p_mthd_range_id    IN   NUMBER DEFAULT NULL
   )
   IS
   --
   l_procedure                          VARCHAR2(100) := g_package || '.set_parameters';
   --
   BEGIN
      --
      -- If parameters haven't already been set, then set them
      --
--      dbg('Entering ' || l_procedure);
      --
      g_collect_oe_only := HRI_BPL_BEN_UTIL.get_curr_oe_coll_mode;
      g_global_start_date := HRI_BPL_PARAMETER.get_bis_global_start_date;
      --
      IF p_mthd_action_id IS NULL
      THEN
         --
         -- Called from test harness
         --
         g_refresh_start_date   := bis_common_parameters.get_global_start_date;
         g_refresh_end_date     := hr_general.end_of_time;
         g_full_refresh         := 'Y';
         g_concurrent_flag      := 'Y';
         g_debug_flag           := 'Y';
         --
      ELSIF (g_refresh_start_date IS NULL)
      THEN
         --
         g_mthd_action_array    := hri_opl_multi_thread.get_mthd_action_array(p_mthd_action_id);
         g_refresh_start_date   := g_mthd_action_array.collect_from_date;
         g_refresh_end_date     := hr_general.end_of_time;
         g_full_refresh         := g_mthd_action_array.full_refresh_flag;
         g_concurrent_flag      := 'Y';
         g_debug_flag           := g_mthd_action_array.debug_flag;
         --
      END IF;
      --
--      dbg('Leaving ' || l_procedure);
      --
   END set_parameters;
   --
--
-- ----------------------------------------------------------------------------
-- PRE_PROCESS
-- This procedure includes the logic required for performing the pre_process
-- task of HRI multithreading utility.
-- ----------------------------------------------------------------------------
--

    PROCEDURE pre_process (
      p_mthd_action_id   IN              NUMBER,
      p_sqlstr           OUT NOCOPY      VARCHAR2
    )
    IS
      l_dummy1   VARCHAR2 (4000);
      l_dummy2   VARCHAR2 (4000);
      l_schema   VARCHAR2 (10);
      l_procedure VARCHAR2(100) := g_package || '.pre_process';
BEGIN
    --
    dbg('Entering ' || l_procedure);
    --
    -- Set Initialization Parameters.
    set_parameters (p_mthd_action_id);
    OUTPUT('Full Refresh Flag  : ' || g_full_refresh);
    OUTPUT('Open Enr Only Flag : ' || g_collect_oe_only);



      --
      IF (fnd_installation.get_app_info ('HRI', l_dummy1, l_dummy2, l_schema)) THEN
         --
         -- output ('Schema Found: ' || l_schema);
         -- l_schema := 'BEN';

         -- ---------------------------------------------------------------------------
         --                       Full Refresh Section
         -- ---------------------------------------------------------------------------
         IF (g_full_refresh = 'Y') THEN
            --
                --
            -- If 'Collect For Current Open Enrollment Only',
            -- Follow the same flow as Full_Refresh,
            -- And avoid truncate tables.
            IF (g_collect_oe_only = 'Y') THEN
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
                --
                OUTPUT(' Collect For Current Open  ');
                --
            ELSE
                --
                 OUTPUT(' Collect For All Open');
                 OUTPUT(' Disabling Indexes...');
                -- Disable WHO triggers on Events table
                --
                run_sql_stmt_noerr('ALTER TRIGGER ' || g_enrlactn_evnt_table || '_WHO DISABLE');
                --
                -- Disable Logs and Indexes
                --
                hri_utl_ddl.log_and_drop_indexes(
                                 p_application_short_name => 'HRI',
                                 p_table_name    => g_enrlactn_evnt_table,
                                 p_table_owner   => l_schema);

                --
                -- Truncate the table
                --
                OUTPUT(' Truncating Tables...');
                --
                EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || l_schema || '.' || g_enrlactn_evnt_table;
                --
                -- Return the sql query to fetch PERSON_ID ranges.
                -- Select all PERSONs for whom an Open Enrollment is either in Started or Processed State
                -- Use Profiles to limit entries base on life event occured date.
                p_sqlstr := ' ';
                p_sqlstr := p_sqlstr || 'SELECT DISTINCT pil.person_id object_id ';
                p_sqlstr := p_sqlstr || '  FROM ben_per_in_ler pil, ';
                p_sqlstr := p_sqlstr || '       ben_ler_f ler ';
                p_sqlstr := p_sqlstr || ' WHERE pil.ler_id = ler.ler_id ';
                p_sqlstr := p_sqlstr || '   AND ler.typ_cd = ''SCHEDDO'' ';
                p_sqlstr := p_sqlstr || '   AND pil.per_in_ler_stat_cd IN (''STRTD'',''PROCD'') ';
                p_sqlstr := p_sqlstr || '   AND pil.lf_evt_ocrd_dt >= ';
                p_sqlstr := p_sqlstr || '  TO_DATE('''||TO_CHAR(g_global_start_date,'MM/DD/YYYY') || ''',''MM/DD/YYYY'') ';
                p_sqlstr := p_sqlstr || '   AND EXISTS (SELECT 1 ';
                p_sqlstr := p_sqlstr || '                 FROM ben_prtt_enrt_actn_f pea ';
                p_sqlstr := p_sqlstr || '                WHERE pea.per_in_ler_id = pil.per_in_ler_id ) ';
                p_sqlstr := p_sqlstr || ' ORDER BY pil.person_id ';
                --
            END IF;
         ELSE
         -- ---------------------------------------------------------------------------
         --                   Start of Incremental Refresh Section
         -- ---------------------------------------------------------------------------
            --
            -- Return the sql query to fetch PERSON_ID ranges
            --
            p_sqlstr := ' ';
            p_sqlstr := p_sqlstr || ' SELECT DISTINCT peaq.person_id object_id ';
            p_sqlstr := p_sqlstr || ' FROM hri_eq_ben_enrlactn_evts peaq ';
            p_sqlstr := p_sqlstr || ' ORDER BY peaq.person_id ';
            --
            --
         END IF;
      END IF;
      --
      dbg('Leaving ' || l_procedure);
      --
   EXCEPTION
      --
      WHEN OTHERS
      THEN
         output ('Exception in pre_process: ' || substr(SQLERRM,1,200));
      --
   END pre_process;

--
-- ----------------------------------------------------------------------------
-- COLLECT_ENRLACTN_EVT (INCREMENTAL REFRESH Overloaded)
-- This procedure includes the logic for collecting Eligibility
-- and Enrollment Events Fact.
-- ----------------------------------------------------------------------------
--
   PROCEDURE collect_enrlactn_evt (p_person_id NUMBER, p_per_in_ler_id NUMBER)
   IS
      --
      -- Cursor to select all the action items that were completed
      -- after last refresh
      --
      CURSOR c_eac_end_date
      IS
         SELECT per_in_ler_id, prtt_enrt_rslt_id, person_id, actn_typ_id,
                event_date, lf_evt_ocrd_dt, due_dt, actn_typ_cd, rqd_flag,
                cmpltd_dt, prtt_enrt_actn_id
           FROM hri_eq_ben_enrlactn_evts peaq
          WHERE per_in_ler_id = p_per_in_ler_id
            AND event_cd = 'COMPLETED'
            AND cmpltd_dt IS NOT NULL;
      --
      -- Cursor to select all the action items that were created since
      -- last refresh
      --
      CURSOR c_eac_optional_actn
      IS
         SELECT per_in_ler_id, prtt_enrt_rslt_id, person_id, actn_typ_id,
                event_date, lf_evt_ocrd_dt, due_dt, actn_typ_cd, rqd_flag,
                cmpltd_dt, prtt_enrt_actn_id
           FROM hri_eq_ben_enrlactn_evts peaq
          WHERE per_in_ler_id = p_per_in_ler_id AND event_cd = 'INSERTED';
      --
      -- Cursor to select all action items that were zapped since last refresh
      --    1. Delete the enrollment (bepearhi.pkb logs the event in queue)
      --    2. Void the life event (bepilrhi.pkb logs the event in queue)
      --
      cursor c_peac is
         SELECT peaq.lf_evt_ocrd_dt, peaq.person_id,
                peaq.per_in_ler_id, peaq.PRTT_ENRT_ACTN_ID
           FROM hri_eq_ben_enrlactn_evts peaq
          WHERE peaq.per_in_ler_id = p_per_in_ler_id
            AND peaq.person_id = p_person_id
            AND peaq.event_cd IN ('ZAP');
      --
      -- Variables for HRI_EQ_BEN_ENRLACTN_EVTS
      --
      l_per_in_ler_id_tab       g_per_in_ler_id_tab_type;
      l_prtt_enrt_rslt_id_tab   g_prtt_enrt_rslt_id_tab_type;
      l_person_id_tab           g_person_id_tab_type;
      l_actn_typ_id_tab         g_actn_typ_id_tab_type;
      l_event_date_tab          g_event_date_tab_type;
      l_lf_evt_ocrd_dt_tab      g_lf_evt_ocrd_dt_tab_type;
      l_due_dt_tab              g_due_dt_tab_type;
      l_actn_typ_cd_tab         g_actn_typ_cd_tab_type;
      l_rqd_flag_tab            g_rqd_flag_tab_type;
      l_cmpltd_dt_tab           g_cmpltd_dt_tab_type;
      l_prtt_enrt_actn_id_tab   g_prtt_enrt_actn_id_tab_type;
      l_procedure VARCHAR2(100) := g_package || '.collect_enrlactn_evt [IR]';
      --
      -- End of Variables for HRI_EQ_BEN_ENRLACTN_EVTS
      --
      dml_errors                EXCEPTION;
      PRAGMA EXCEPTION_INIT (dml_errors, -24381);
      --
   --
   BEGIN
      --
      dbg('Entering ' || l_procedure);
      --
      -- Step 1. Create action items which are newly created
      --
      OPEN c_eac_optional_actn;
         --
         FETCH c_eac_optional_actn BULK COLLECT INTO l_per_in_ler_id_tab,
                                                     l_prtt_enrt_rslt_id_tab,
                                                     l_person_id_tab,
                                                     l_actn_typ_id_tab,
                                                     l_event_date_tab,
                                                     l_lf_evt_ocrd_dt_tab,
                                                     l_due_dt_tab,
                                                     l_actn_typ_cd_tab,
                                                     l_rqd_flag_tab,
                                                     l_cmpltd_dt_tab,
                                                     l_prtt_enrt_actn_id_tab;
         --
      CLOSE c_eac_optional_actn;
      --
      IF l_per_in_ler_id_tab.COUNT > 0
      THEN
         --
         FORALL i IN l_per_in_ler_id_tab.FIRST .. l_per_in_ler_id_tab.LAST SAVE EXCEPTIONS
            --
            INSERT INTO hri_mb_ben_enrlactn_ct
                        ( sspnd_ind,
                          actn_item_ind,
                          interim_ind,
                          change_date,
                          effective_start_date,
                          effective_end_date,
                          person_id,
                          asnd_lf_evt_dt,
                          actn_typ_cd,
                          compobj_sk_pk,
                          enrt_perd_id,
                          actn_typ_id,
                          prtt_enrt_rslt_id,
                          prtt_enrt_actn_id,
                          per_in_ler_id,
                          interim_enrt_rslt_id,
                          interim_compobj_sk_pk, due_dt
                         )
                         ( SELECT (CASE WHEN (l_rqd_flag_tab (i) = 'Y'
                                             AND l_cmpltd_dt_tab (i) IS NULL)
                                        THEN 1
                                        ELSE 0 END) sspnd_ind,
                                  (CASE WHEN (l_cmpltd_dt_tab (i) IS NULL) -- 4541338
                                        THEN 1
                                        ELSE 0 END ) actn_item_ind,
                                  DECODE (pen.rplcs_sspndd_rslt_id, NULL, 0, 1),
                                  l_event_date_tab (i),
                                  --l_event_date_tab (i),
                                  pen.effective_start_Date,
                                  hr_api.g_eot,
                                  l_person_id_tab (i),
                                  l_lf_evt_ocrd_dt_tab (i),
                                  l_actn_typ_cd_tab (i),
                                  copd.compobj_sk_pk compobj_sk_pk,
                                  enpd.enrt_perd_id,
                                  l_actn_typ_id_tab (i),
                                  pen.prtt_enrt_rslt_id,
                                  l_prtt_enrt_actn_id_tab (i),
                                  l_per_in_ler_id_tab (i),
                                  pen.rplcs_sspndd_rslt_id,
                                  copd_int.compobj_sk_pk interim_compobj_sk_pk,
                                  l_due_dt_tab (i)
                             FROM ben_prtt_enrt_rslt_f pen,
                                  hri_cs_time_benrl_prd_ct enpd,
                                  ben_prtt_enrt_rslt_f pen_int,
                                  hri_cs_compobj_ct copd_int,
                                  hri_cs_compobj_ct copd,
                                  ben_opt_f opt,
                                  ben_pl_f pln
                            WHERE pen.per_in_ler_id = l_per_in_ler_id_tab (i)
                              AND pen.prtt_enrt_rslt_id = l_prtt_enrt_rslt_id_tab (i)
                              AND enpd.pgm_id = pen.pgm_id
                              AND l_lf_evt_ocrd_dt_tab (i) = enpd.asnd_lf_evt_dt
                              AND (   copd.oipl_id = pen.oipl_id
                                   OR (pen.oipl_id IS NULL AND copd.oipl_id = -1)
                                  )
                              AND copd.pl_id = pen.pl_id
                              AND copd.pgm_id = pen.pgm_id
                              AND opt.opt_id(+) = copd.opt_id
                              AND pln.pl_id = copd.pl_id
                              AND l_lf_evt_ocrd_dt_tab (i) BETWEEN opt.effective_start_date(+)
                                                               AND opt.effective_end_date(+)
                              AND l_lf_evt_ocrd_dt_tab (i) BETWEEN pln.effective_start_date
                                                               AND pln.effective_end_date
                              AND pen.rplcs_sspndd_rslt_id = pen_int.prtt_enrt_rslt_id(+)
                              /* AND copd_int.oipl_id(+) = NVL (pen_int.oipl_id, -1) */
                              AND (   copd_int.oipl_id = pen_int.oipl_id
                                   OR (pen_int.oipl_id IS NULL AND NVL(copd_int.oipl_id,-1) = -1)
                                  )
                              AND copd_int.pgm_id(+) = pen_int.pgm_id
                              AND copd_int.pl_id(+) = pen_int.pl_id
                              AND pen.prtt_enrt_rslt_stat_cd IS NULL
                              /* Bug 4562628 */
                              and (    pen_int.effective_start_date is null
                                    or (pen.effective_Start_date between pen_int.effective_Start_date
                                                                     and pen_int.effective_end_date)
                               )
                              /* Bug 4562628 */
                         );
            --
         --
      END IF;
      --
      dbg('Created New Action Items');
      --
      -- Step 2. End date exising records to one day prior.
      --
      OPEN c_eac_end_date;
        --
        FETCH c_eac_end_date BULK COLLECT INTO l_per_in_ler_id_tab,
                                               l_prtt_enrt_rslt_id_tab,
                                               l_person_id_tab,
                                               l_actn_typ_id_tab,
                                               l_event_date_tab,
                                               l_lf_evt_ocrd_dt_tab,
                                               l_due_dt_tab,
                                               l_actn_typ_cd_tab,
                                               l_rqd_flag_tab,
                                               l_cmpltd_dt_tab,
                                               l_prtt_enrt_actn_id_tab;
        --
      CLOSE c_eac_end_date;

      IF l_per_in_ler_id_tab.COUNT > 0
      THEN
         --
         FORALL i IN l_per_in_ler_id_tab.FIRST .. l_per_in_ler_id_tab.LAST SAVE EXCEPTIONS
            UPDATE hri_mb_ben_enrlactn_ct peac
               SET peac.effective_end_date = l_event_date_tab (i) - 1
             WHERE peac.per_in_ler_id = l_per_in_ler_id_tab (i)
               AND peac.prtt_enrt_rslt_id = l_prtt_enrt_rslt_id_tab (i)
               AND peac.prtt_enrt_actn_id = l_prtt_enrt_actn_id_tab (i)
               AND peac.actn_typ_id = l_actn_typ_id_tab (i)
               AND peac.asnd_lf_evt_dt = l_lf_evt_ocrd_dt_tab (i);
         --
      END IF;
      --
      dbg ('End-dated Existing Records To A Day Prior');
      --
      -- Step 3. Delete Records for which Results were ZAPPED.
      --
      -- Case (i) The ZAP event logged by bepilrhi.pkb >> hrieqele.pkb
      --          The record in event queue will not have PRTT_ENRT_ACTN_ID
      --          and PRTT_ENRT_RSLT_ID populated.
      --          But will have only PER_IN_LER_ID populated. In such case
      --          delete all records from fact for the given PER_IN_LER_ID
      -- Case (ii) The ZAP event logged by benelinf.pkb >> bepearhi.pkb >> hrieqeea.pkb
      --           The record in event queue will have both PRTT_ENRT_RSLT_ID
      --           and PRTT_ENRT_ACTN_ID. Hence delete records in the fact table
      --           for the given PRTT_ENRT_ACTN_ID
      --
      OPEN c_peac;
        --
        FETCH c_peac BULK COLLECT INTO l_lf_evt_ocrd_dt_tab,
                                       l_person_id_tab,
                                       l_per_in_ler_id_tab,
                                       l_prtt_enrt_actn_id_tab;
        --
      CLOSE c_peac;
      --
      IF l_per_in_ler_id_tab.COUNT > 0
      THEN
         --
         FORALL i IN l_per_in_ler_id_tab.FIRST .. l_per_in_ler_id_tab.LAST SAVE EXCEPTIONS
              DELETE FROM hri_mb_ben_enrlactn_ct peac
              WHERE peac.asnd_lf_evt_dt = l_lf_evt_ocrd_dt_tab (i)
                and  peac.person_id = l_person_id_tab(i)
                and  peac.per_in_ler_id = l_per_in_ler_id_tab (i)
                /* See Case(i) and Case(ii) above for clause below */
                and  peac.PRTT_ENRT_ACTN_ID  = nvl(l_prtt_enrt_actn_id_tab (i),peac.PRTT_ENRT_ACTN_ID ) ;
         --
      end if;
      --
      dbg ('Deleted Zapped Records');
      --
      --
      -- output('Incremental Update Completed');
      --
      dbg('Leaving ' || l_procedure);
      --
   --
   EXCEPTION
      --
      WHEN dml_errors
      THEN
         output ('Exception in collect_enrlactn_evt: ' || SUBSTR (SQLERRM, 1, 190));
      --
   END collect_enrlactn_evt;

--
-- ----------------------------------------------------------------------------
-- COLLECT_ENRLACTN_EVT (FULL REFRESH Overloaded)
-- This procedure includes the logic for collecting Eligibility
-- and Enrollment Events Fact.
-- ----------------------------------------------------------------------------
--
   PROCEDURE collect_enrlactn_evt (p_pil_rec g_pil_rec_type)
   IS
      --
      dml_errors   EXCEPTION;
      PRAGMA EXCEPTION_INIT (dml_errors, -24381);
      l_procedure VARCHAR2(100) := g_package || '.collect_enrlactn_evt [FR]';
      --
   BEGIN
      --
      dbg('Entering ' || l_procedure);
      --
      IF (g_collect_oe_only = 'Y') THEN
        -- If Only Current Open Enrollment is being Collected,
        -- Delete any prior run's stray records, if present.
        DELETE from hri_mb_ben_enrlactn_ct
         WHERE person_id = p_pil_rec.person_id
           AND asnd_lf_evt_dt = p_pil_rec.lf_evt_ocrd_dt
           AND per_in_ler_id = p_pil_rec.per_in_ler_id;
        --
      END IF;
      -- output('Start Of Full Refresh');
      -- Populate Benefits Enrollment Actions Fact
      -- Insert Actions (From Enrollment Action Items BEN_PRTT_ENRT_ACT_F)
      --
      INSERT INTO hri_mb_ben_enrlactn_ct
                  (
                    sspnd_ind,
                    actn_item_ind,
                    interim_ind,
                    change_date,
                    effective_start_date,
                    effective_end_date,
                    person_id,
                    asnd_lf_evt_dt,
                    actn_typ_cd,
                    compobj_sk_pk,
                    enrt_perd_id,
                    actn_typ_id,
                    prtt_enrt_rslt_id,
                    prtt_enrt_actn_id,
                    per_in_ler_id,
                    interim_enrt_rslt_id,
                    interim_compobj_sk_pk,
                    due_dt
                   )
                   (
                     SELECT (CASE WHEN (pea.rqd_flag = 'Y'
                                        AND pea.cmpltd_dt IS NULL)
                                  THEN 1
                                  ELSE 0 END) sspnd_ind,
                             (CASE WHEN (pea.cmpltd_dt IS NULL) -- 4541338
                                   THEN 1
                                   ELSE 0 END ) actn_item_ind,
                             DECODE (pen.rplcs_sspndd_rslt_id, NULL, 0, 1),
                             pea.effective_start_date,
                             pea.effective_start_date,
                             pea.effective_end_date,
                             p_pil_rec.person_id,
                             p_pil_rec.lf_evt_ocrd_dt,
                             act.type_cd,
                             copd.compobj_sk_pk compobj_sk_pk,
                             enpd.enrt_perd_id,
                             pea.actn_typ_id,
                             pen.prtt_enrt_rslt_id,
                             pea.prtt_enrt_actn_id,
                             p_pil_rec.per_in_ler_id,
                             pen.rplcs_sspndd_rslt_id,
                             copd_int.compobj_sk_pk interim_compobj_sk_pk, pea.due_dt
                        FROM ben_prtt_enrt_rslt_f pen,
                             ben_prtt_enrt_actn_f pea,
                             hri_cs_time_benrl_prd_ct enpd,
                             ben_actn_typ act,
                             ben_prtt_enrt_rslt_f pen_int,
                             hri_cs_compobj_ct copd_int,
                             hri_cs_compobj_ct copd,
                             ben_opt_f opt,
                             ben_pl_f pln
                       WHERE pen.per_in_ler_id = p_pil_rec.per_in_ler_id
                         AND pen.prtt_enrt_rslt_id = pea.prtt_enrt_rslt_id
                         AND pea.actn_typ_id = act.actn_typ_id
                         AND enpd.pgm_id = pen.pgm_id
                         AND p_pil_rec.lf_evt_ocrd_dt = enpd.asnd_lf_evt_dt
                         AND (   copd.oipl_id = pen.oipl_id
                              OR (pen.oipl_id IS NULL AND copd.oipl_id = -1)
                             )
                         AND copd.pl_id = pen.pl_id
                         AND copd.pgm_id = pen.pgm_id
                         AND opt.opt_id(+) = copd.opt_id
                         AND pln.pl_id = copd.pl_id
                         AND p_pil_rec.lf_evt_ocrd_dt BETWEEN opt.effective_start_date(+)
                                                          AND opt.effective_end_date(+)
                         AND p_pil_rec.lf_evt_ocrd_dt BETWEEN pln.effective_start_date
                                                          AND pln.effective_end_date
                         AND pen.rplcs_sspndd_rslt_id = pen_int.prtt_enrt_rslt_id(+)
                         /* AND copd_int.oipl_id(+) = NVL(pen_int.oipl_id, -1) */
                         AND (   copd_int.oipl_id = pen_int.oipl_id
                              OR (pen_int.oipl_id IS NULL AND NVL(copd_int.oipl_id,-1) = -1)
                             )
                         AND copd_int.pgm_id(+) = pen_int.pgm_id
                         AND copd_int.pl_id(+) = pen_int.pl_id
                         -- AND pen.effective_end_date = hr_api.g_eot  /* Bug 4562628 */
                         AND pen.enrt_cvg_thru_dt = hr_api.g_eot
                         AND pen.prtt_enrt_rslt_stat_cd IS NULL
                         /* Bug 4562628 */
                         and pea.effective_Start_date between pen.effective_Start_date and pen.effective_end_date
                         and (    pen_int.effective_start_date is null
                               or (pen.effective_Start_date between pen_int.effective_Start_date
                                                                and pen_int.effective_end_date)
                          )
                         /* Bug 4562628 */
                   );
      --
      -- output ('Full Refresh Completed');
      --
      dbg('Leaving ' || l_procedure);
      --
   EXCEPTION
      WHEN dml_errors
      THEN
         --
         output ('Exception in collect_enrlactn_evt : ' || SUBSTR (SQLERRM, 1, 200));
         --
   END collect_enrlactn_evt;

--
-- ----------------------------------------------------------------------------
-- PROCESS_FULL_RANGE
-- Is called in FULL REFRESH mode.
-- ----------------------------------------------------------------------------
--
   PROCEDURE process_full_range (
      p_start_object_id   IN   NUMBER,
      p_end_object_id     IN   NUMBER
   )
   IS
      --
      CURSOR c_pil
      IS
           SELECT pil.per_in_ler_id,
                  pil.person_id,
                  pil.lf_evt_ocrd_dt,
                  pil.per_in_ler_stat_cd,
                  pil.business_group_id
             FROM ben_per_in_ler pil, ben_ler_f ler
            WHERE pil.ler_id = ler.ler_id
              AND ler.typ_cd = 'SCHEDDO'
              AND pil.per_in_ler_stat_cd IN ('STRTD', 'PROCD')
              AND pil.lf_evt_ocrd_dt >= g_global_start_date
              AND pil.person_id BETWEEN p_start_object_id
                                    AND p_end_object_id
         ORDER BY pil.person_id;
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
         ORDER BY pil.person_id;
      --
      l_pil_tbl   g_pil_tab_type;
      --
   BEGIN
      --
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

      --
      -- For each PIL collect the Election and Enrollment Information
      --
      IF (l_pil_tbl.COUNT > 0)
      THEN
         FOR i IN l_pil_tbl.FIRST .. l_pil_tbl.LAST
         LOOP
            --
            -- 1. Load the Enrollments Action Fact
            --
            collect_enrlactn_evt (p_pil_rec => l_pil_tbl (i));
            --
         END LOOP;
      END IF;
      --
   EXCEPTION
      WHEN OTHERS
      THEN
          output ('Exception in process_range : ' || SUBSTR (SQLERRM, 1, 200));
   END process_full_range;

--
-- ----------------------------------------------------------------------------
-- PROCESS_INCR_RANGE
-- This procedure is called in INCREMENTAL REFRESH mode.
-- ----------------------------------------------------------------------------
--
   PROCEDURE process_incr_range (
      p_start_object_id   IN   NUMBER,
      p_end_object_id     IN   NUMBER
   )
   IS
      --
      CURSOR c_per_in_evt
      IS
         SELECT DISTINCT penq.person_id, penq.per_in_ler_id
                    FROM hri_eq_ben_enrlactn_evts penq
                   WHERE penq.person_id BETWEEN p_start_object_id
                                            AND p_end_object_id
                ORDER BY penq.person_id;
      --
      l_person_tbl   g_number_tab_type;
      l_pil_tbl      g_number_tab_type;
      --
   BEGIN
      --
      -- 1. Load the Election Events Fact
      --
      OPEN c_per_in_evt;
      FETCH c_per_in_evt BULK COLLECT INTO l_person_tbl, l_pil_tbl;
      CLOSE c_per_in_evt;
      --
      FOR i IN l_person_tbl.FIRST .. l_person_tbl.LAST
      LOOP
         --
         collect_enrlactn_evt (p_person_id          => l_person_tbl (i),
                               p_per_in_ler_id      => l_pil_tbl (i)
                              );
         --
      END LOOP;
      --
      l_person_tbl.DELETE;
      l_pil_tbl.DELETE;
      --
   EXCEPTION
      WHEN OTHERS
      THEN
          output ('Exception in process_incr_range : ' || SUBSTR (SQLERRM, 1, 200));
   END process_incr_range;

-- ----------------------------------------------------------------------------
-- PROCESS_RANGE
-- This procedure is dynamically called from HRI Multithreading utility.
-- Calls Collection procedures for Election Event and Elibility Enrollment Event Facts
-- for All PER_IN_LER_IDs obtained from the thread range.
-- ----------------------------------------------------------------------------
   PROCEDURE process_range (
      errbuf              OUT NOCOPY      VARCHAR2,
      retcode             OUT NOCOPY      NUMBER,
      p_mthd_action_id    IN              NUMBER,
      p_mthd_range_id     IN              NUMBER,
      p_start_object_id   IN              NUMBER,
      p_end_object_id     IN              NUMBER
   )
   IS
      --
      l_procedure                    VARCHAR2(100) := g_package || 'process_range';
      --
   BEGIN
      --
      -- Enable output to concurrent request log
      --
      dbg('Entering ' || l_procedure);
      --
      g_conc_request_flag := TRUE;
      --
      -- 1. Set parameters for this thread.
      --
      set_parameters (p_mthd_action_id      => p_mthd_action_id,
                      p_mthd_range_id       => p_mthd_range_id);
      --
      IF g_full_refresh = 'Y'
      THEN
         --
         process_full_range (p_start_object_id      => p_start_object_id,
                             p_end_object_id        => p_end_object_id);
         --
      ELSE
         --
         process_incr_range (p_start_object_id      => p_start_object_id,
                             p_end_object_id        => p_end_object_id);
         --
      END IF;
      --
      errbuf := 'SUCCESS';
      retcode := 0;
      --
      dbg('Leaving ' || l_procedure);
      --
   EXCEPTION
      WHEN OTHERS
      THEN
         --
         dbg('Error ' || l_procedure);
         output ('Error encountered while processing range = ' || p_mthd_range_id );
         output (SQLERRM);
         errbuf := SQLERRM;
         retcode := SQLCODE;
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
   PROCEDURE post_process (p_mthd_action_id NUMBER)
    IS
        --
        l_dummy1   VARCHAR2 (2000);
        l_dummy2   VARCHAR2 (2000);
        l_schema   VARCHAR2 (400);
        --
    BEGIN
        --
        dbg ('Inside post_process');
        --
        set_parameters (p_mthd_action_id);
        OUTPUT('Full Refresh Flag  : ' || g_full_refresh);
        OUTPUT('Open Enr Only Flag : ' || g_collect_oe_only);
        --
        IF (fnd_installation.get_app_info ('HRI',l_dummy1,l_dummy2,l_schema)) THEN
            --
            IF (g_full_refresh = 'Y') THEN
            --
                -- output ('Full Refresh selected - Creating indexes');
                --
                HRI_UTL_DDL.recreate_indexes(
                p_application_short_name => 'HRI',
                p_table_name    => g_enrlactn_evnt_table,
                p_table_owner   => l_schema);
                --
                run_sql_stmt_noerr('ALTER TRIGGER ' || g_enrlactn_evnt_table || '_WHO ENABLE');
                --
            ELSE
                --
                -- Incremental Changes
                -- Enable the WHO trigger on the events fact table
                --
                IF (HRI_BPL_BEN_UTIL.get_archive_events = 'Y') THEN
                    -- If Event Queue is to be be archived add code here
                    dbg ('Archive the events queue');
                END IF;
                --
            END IF;
            --
            -- Purge the Events Queue. The events queue needs to be purged
            -- even after the after full refresh. Recollecting incremental changes
            -- will be useless if a full refresh has been run.
            EXECUTE IMMEDIATE 'truncate table ' || l_schema || '.HRI_EQ_BEN_ENRLACTN_EVTS';
        --
        END IF;
        --
        dbg ('Exiting post_process');
        --
    EXCEPTION
    --
    WHEN OTHERS THEN
        --
        RAISE;
        --
    END post_process;
--
END hri_opl_ben_enrl_actn;

/
