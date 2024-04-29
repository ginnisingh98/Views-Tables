--------------------------------------------------------
--  DDL for Package Body HRI_OPL_ASGN_EVENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OPL_ASGN_EVENTS" AS
/* $Header: hrioaevt.pkb 120.21 2007/01/12 09:10:04 jtitmas noship $ */
--
-- -----------------------------------------------------------------------------
-- Process flow
-- ============
--
-- BEFORE MULTI-THREADING
-- ----------------------
-- PRE_PROCESS
--   - Shared HR mode
--     - Truncates table
--     - Repopulates table with data for current period of work
--       as of system date
--
--   - Other modes
--     - returns list of all assignments to process. These are
--       split into chunks by multi-threading master process
--     - disables WHO trigger
--     - checks seeded fast formulas are compiled
--     - Full Refresh
--       - stores index definitions and drops indexes (full refresh)
--       - truncates table
--     - Incremental Refresh
--       - updates event queue with any period of work band change events
--
-- MULTI-THREADING
-- ---------------
-- 1) PROCESS_RANGE
--     - Gets a range of objects (assignments) to process
--     - Calls COLLECT for each one
--     - bulk inserts any remaining rows
--
-- 2) COLLECT
--     - Entry point for processing each assignment
--     - Calls below procedures to process the assignment
--     - Checks whether enough rows are stored up to bulk insert
--
-- 4) IDENTIFY_ASSIGNMENT_CHANGES
--     - creates an assignment change history array for a given assignment
--     - inserts a record in the combined event list array for each change
--
-- 5) IDENTIFY_ABV_CHANGES
--     - inserts a record in the combined event list array for each ABV change
--       for Headcount or FTE
--
-- 6) FILL_GAPS_IN_ABV_HISTORY
--     - closes the gap where there is no data for an assignment in
--       PER_ASSIGNMENT_BUDGET_VALUES_F. This is achieved by using fast formula
--       at every point where theres an assignment change to calculate the value
--
-- 7) IDENTIFY_SALARY_CHANGES
--     - creates a list of salary changes
--     - inserts a record in the combined event list PLSQL table for each change
--
-- 8) IDENTIFY_PERF_RATING_CHANGES
--     - creates a list of performance rating changes
--     - inserts a record in the combined event list PLSQL table for each change
--
-- 9) IDENTIFY_POW_BAND_CHANGES
--     - creates a list of period of work changes
--     - inserts a record in the combined event list PLSQL table for each change
--
-- 10) SET_PREVIOUS_VALUES
--     - Full Refresh
--       - set up a default record for values before the refresh start date
--     - Incremental Refresh
--       - sets the previous values of various columns as they exists one day
--         before the incremental refresh
--
-- 11) MERGE_AND_INSERT_DATA
--     - sets the indicators
--     - merges the data in the master table into a PL/SQL table ready to insert
--       into the main database table HRI_MB_ASGN_EVENTS
--
-- 12) UPDATE_END_RECORD (Incremental only)
--     - During incremental proceesing it end dates the assignment
--       records for the assignment that ovelap the earliest event date
--
-- 3) DELETE_RECORDS (Incremental only)
--     - During Incremental processing deletes all the records from the table
--       HRI_MB_ASGN_EVENTS that start on or after the refresh start date for
--       each assignment in the range
--
-- 3) BULK_INSERT
--     - Bulk inserts stored rows once per range
--
-- AFTER MULTI-THREADING
-- ----------------------
-- POST_PROCESS
--   - Logs process end (success/failure)
--
--   - Enables WHO trigger
--
--   - Purges event queue
--
--   - Full Refresh
--     - Recreates indexes that were dropped in PRE_PROCESS
--     - Gathers stats
--
--
-- Event Merging
-- =============
-- All events processed occur on or after the global collection start date
-- (collect from date). So each event date can be converted to a positive
-- number by calculating the number of days between the event date and the
-- collection start date. This number is then used to index the master table
-- by date so that events which occur on the same date are merged.
--
-- -----------------------------------------------------------------------------
  --
  -- MAIN PL/SQL TABLE FOR BULK INSERT
  TYPE g_asgn_events_tab_type IS TABLE OF hri_mb_asgn_events_ct%ROWTYPE
                 INDEX BY BINARY_INTEGER;
  --
  -- Number table type with varchar2 indexing.
  --
  TYPE g_index_by_varchar2_num_tab IS TABLE OF NUMBER INDEX BY VARCHAR2(30);
  --
  -- Type for service dates containing hire date, termination date, secondary
  -- assignment start date, secondary assignment end date, primary assignment
  -- start date and primary assignment end date.
  --
  TYPE g_asg_date_type IS RECORD
    (hire_date                    DATE
    ,termination_date             DATE
    ,post_hire_asgn_start_date    DATE
    ,pre_sprtn_asgn_end_date      DATE
    ,start_date_active            DATE
    ,end_date_active              DATE
    ,pow_start_date_adj           DATE);
  --
  -- Type for merging the assignment, ABV ,salary, performance and period of work events.
  --
  TYPE g_master_record IS RECORD
    (asg_index                  PLS_INTEGER
    ,sal_index                  PLS_INTEGER
    ,perf_index                 PLS_INTEGER
    ,fte                        NUMBER
    ,headcount                  NUMBER
    ,primary_flag               VARCHAR2(30)
    ,rtrspctv_strt_ind          PLS_INTEGER
    ,asg_evt_ind                PLS_INTEGER
    ,sal_evt_ind                PLS_INTEGER
    ,perf_evt_ind               PLS_INTEGER
    ,fte_record_ind             PLS_INTEGER
    ,hdc_record_ind             PLS_INTEGER
    ,pow_evt_ind                PLS_INTEGER
    ,pow_band_sk_fk             PLS_INTEGER
    ,pow_extn_strt_dt           DATE
    ,prsntyp_evt_ind            PLS_INTEGER
    );
  --
  -- Type for ABV, ptu and period of work records containing info on event date before the
  -- event occurs.
  --
  TYPE g_placeholder_rec IS RECORD
    (fte                             NUMBER
    ,fte_prv                         NUMBER
    ,headcount                       NUMBER
    ,headcount_prv                   NUMBER
    ,pow_band_sk_fk                  NUMBER
    ,pow_band_sk_fk_prv              NUMBER
    ,pow_extn_strt_dt                DATE);
  --
  -- Type for various indexes used for storing the current indexes of the master
  -- record table( while looping) as well as storing the previous indexes for
  -- assignment, salary records and the index for next date.
  --
  TYPE g_index_record IS RECORD
    (asg_index            PLS_INTEGER
    ,asg_index_prev       PLS_INTEGER
    ,sal_index            PLS_INTEGER
    ,sal_index_prev       PLS_INTEGER
    ,perf_index           PLS_INTEGER
    ,perf_index_prev      PLS_INTEGER
    ,date_index           PLS_INTEGER
    ,next_date_index      PLS_INTEGER);
  --
  -- Type for various indicators, which gets set in the procedure set_indicators.
  --
  TYPE g_indicator_record IS RECORD
    (asg_rtrspctv_strt_event_ind      PLS_INTEGER
    ,assignment_change_ind            PLS_INTEGER
    ,salary_change_ind                PLS_INTEGER
     --
     -- Performance Indicators
     --
    ,perf_change_ind                  PLS_INTEGER
    ,perf_band_change_ind             PLS_INTEGER
     --
     -- POW Indicators
     --
    ,pow_band_change_ind              PLS_INTEGER
    ,headcount_gain_ind               PLS_INTEGER
    ,headcount_loss_ind               PLS_INTEGER
    ,fte_gain_ind                     PLS_INTEGER
    ,fte_loss_ind                     PLS_INTEGER
    ,contingent_ind                   PLS_INTEGER
    ,employee_ind                     PLS_INTEGER
    ,grade_change_ind                 PLS_INTEGER
    ,job_change_ind                   PLS_INTEGER
    ,position_change_ind              PLS_INTEGER
    ,location_change_ind              PLS_INTEGER
    ,organization_change_ind          PLS_INTEGER
    ,supervisor_change_ind            PLS_INTEGER
    ,worker_hire_ind                  PLS_INTEGER
    ,post_hire_asgn_start_ind         PLS_INTEGER
    ,pre_sprtn_asgn_end_ind           PLS_INTEGER
    ,term_voluntary_ind               PLS_INTEGER
    ,term_involuntary_ind             PLS_INTEGER
    ,worker_term_ind                  PLS_INTEGER
    ,start_asg_sspnsn_ind             PLS_INTEGER
    ,end_asg_sspnsn_ind               PLS_INTEGER
    ,promotion_ind                    PLS_INTEGER
    --
    -- Person Type Summarization Indicators
    --
    ,summarization_rqd_ind            PLS_INTEGER
    ,summarization_rqd_chng_ind       PLS_INTEGER
    ,summarization_rqd_chng_nxt_ind   PLS_INTEGER
    );
  --
  -- Type for storing previous records during incremental refresh
  --
  TYPE g_prv_record IS RECORD
    (grade_prv_id                     NUMBER
    ,job_prv_id                       NUMBER
    ,location_prv_id                  NUMBER
    ,organization_prv_id              NUMBER
    ,supervisor_prv_id                NUMBER
    ,position_prv_id                  NUMBER
    ,primary_flag_prv                 VARCHAR2(30)
    ,fte_prv                          NUMBER
    ,headcount_prv                    NUMBER
    ,anl_slry_prv                     NUMBER
    ,anl_slry_currency_prv            VARCHAR2(30)
     --
     -- Performance Records
     --
    ,perf_nrmlsd_rating_prv           NUMBER
    ,perf_band_prv                    NUMBER
    ,fte_end_date_prv                 DATE
    ,hdc_end_date_prv                 DATE
    --
    -- Period of work Record
    --
    ,pow_band_sk_fk_prv               NUMBER
    ,summarization_rqd_ind_prv        NUMBER
    ,row_id                           ROWID
    );
  --
  -- Type for storing the different next indicator columns for updating the
  -- table HRI_MB_ASGN_EVENTS_CT during incremental refresh
  --
  TYPE g_nxt_ind_record IS RECORD
    (worker_term_nxt_ind            PLS_INTEGER
    ,term_voluntary_nxt_ind         PLS_INTEGER
    ,term_involuntary_nxt_ind       PLS_INTEGER
    ,supervisor_change_nxt_ind      PLS_INTEGER
    ,pre_sprtn_asgn_end_nxt_ind     PLS_INTEGER
    ,separation_category_nxt        VARCHAR2(30)
    ,summarization_rqd_chng_nxt_ind PLS_INTEGER
    );
  --
  -- Table type for merging the assignment, ABV and salary events. This is
  -- loaded in the procedures identify_assignment_changes, identify_abv_changes,
  -- fill_gaps_in_abv_history, identify_salary_changes and merged in the
  -- procedure merge_and_insert_data.
  --
  TYPE g_master_tab_type IS TABLE OF g_master_record INDEX BY BINARY_INTEGER;
  --
  -- Global variables representing parameters
  --
  g_refresh_start_date     DATE;
  g_refresh_end_date       DATE;
  g_collect_fte            VARCHAR2(5);
  g_collect_hdc            VARCHAR2(5);
  g_full_refresh           VARCHAR2(5);
  g_assignment_id          NUMBER;
  --
  -- Global end of time date initialization from the package hr_general
  --
  g_end_of_time            DATE;
  --
  -- Global DBI collection start date initialization
  --
  g_dbi_collection_start_date DATE;
  --
  -- Global to the value of the Adjusted Service Date calculation profile
  --
  g_adj_svc_profile VARCHAR2(30);
  --
  -- Bug 4105868: Global to store msg_sub_group
  --
  g_msg_sub_group          VARCHAR2(400);
  --
  -- Global flag which determines the existence of materialized view logs
  --
  g_mv_log_exists_flag     VARCHAR2(1);
  g_drop_mv_log            VARCHAR2(30);
  --
  -- Global Variable for checking if performance rating is to be collected
  --
  g_collect_perf_rating    VARCHAR2(30);
  g_collect_prsn_typ       VARCHAR2(30);
  --
  -- Global variable for storing the manner in which the appraisals are stored
  --
  g_perf_query    VARCHAR2(10000);
  --
  -- Global HRI Multithreading Array
  --
  g_mthd_action_array      HRI_ADM_MTHD_ACTIONS%rowtype;
  --
  -- Global warning indicator
  --
  g_raise_warning          VARCHAR2(1);
  --
  -- Stores the value to be stored in the performance band columns for not rated records
  --
  g_perf_not_rated_id      NUMBER;
  --
  g_rtn VARCHAR2(200);
  --
  -- Global Variable which is set if the person type has been classigied as a CWK in
  -- the ptu dimension includes. It is used to detemine if the extension period is to
  -- be calculated for the asg
  --
  g_cwk_asg                BOOLEAN;
  --
  -- Globals for DBI
  --
  g_implement_dbi          VARCHAR2(30);
  --
  -- Globals for OBIEE
  --
  g_implement_obiee        VARCHAR2(30);
  g_implement_obiee_orgh   VARCHAR2(30);
  g_implement_obiee_mgrh   VARCHAR2(30);
  --
  -- Exceptions
  --
  no_assignment_record_found EXCEPTION;
  --
  -- Forward Declaration of procedures
  --
  PROCEDURE process_range(
     p_object_range_id   IN NUMBER
    ,p_start_object_id   IN NUMBER
    ,p_end_object_id     IN NUMBER ) ;
--
-- -----------------------------------------------------------------------------
-- Inserts row into concurrent program log
-- -----------------------------------------------------------------------------
--
PROCEDURE output(p_text  VARCHAR2) IS
--
BEGIN
  --
  -- Bug 4105868: Collection Diagnostics
  --
  HRI_BPL_CONC_LOG.output(p_text);
  --
END output;
--
-- -----------------------------------------------------------------------------
-- Inserts row into concurrent program log if debugging is enabled
-- -----------------------------------------------------------------------------
--
PROCEDURE dbg(p_text  VARCHAR2) IS
--
BEGIN
  --
  -- Bug 4105868: Collection Diagnostics
  --
  HRI_BPL_CONC_LOG.dbg(p_text);
  --
END dbg;
--
--
-- ----------------------------------------------------------------------------
-- Adds change records to workforce events queue
-- ----------------------------------------------------------------------------
--
PROCEDURE populate_wrkfc_evt_eq IS

BEGIN

  -- Only insert event queue records if OBIEE is implemented
  IF g_implement_obiee = 'Y' THEN

    INSERT INTO hri_eq_wrkfc_evt
     (assignment_id
     ,erlst_evnt_effective_date)
     SELECT
      assignment_id
     ,erlst_evnt_effective_date
     FROM
      hri_eq_asgn_evnts;

    INSERT INTO hri_eq_wrkfc_mnth
     (assignment_id
     ,erlst_evnt_effective_date)
     SELECT
      assignment_id
     ,erlst_evnt_effective_date
     FROM
      hri_eq_asgn_evnts;

  END IF;

END populate_wrkfc_evt_eq;
--
--
-- ----------------------------------------------------------------------------
-- Adds change records to workforce events by organization hierarchy queue
-- ----------------------------------------------------------------------------
--
PROCEDURE populate_wrkfc_evt_orgh_eq IS

BEGIN

  -- Only insert event queue records if OBIEE is implemented
  IF g_implement_obiee_orgh = 'Y' THEN

    INSERT INTO hri_eq_wrkfc_evt_orgh
     (organization_id
     ,erlst_evnt_effective_date)
-- Previous organization chains
     SELECT /*+ ORDERED */
      orgh.orgh_sup_organztn_fk
     ,GREATEST(eq.erlst_evnt_effective_date, evt.effective_change_date)
     FROM
      hri_eq_asgn_evnts      eq
     ,hri_mb_asgn_events_ct  evt
     ,hri_cs_orgh_ct         orgh
     WHERE eq.assignment_id = evt.assignment_id
     AND eq.erlst_evnt_effective_date <= evt.effective_change_end_date
     AND evt.organization_id = orgh.orgh_organztn_fk
     UNION ALL
-- New organization chains
     SELECT /*+ ORDERED */
      orgh.orgh_sup_organztn_fk
     ,GREATEST(eq.erlst_evnt_effective_date, asg.effective_start_date)
     FROM
      hri_eq_asgn_evnts      eq
     ,per_all_assignments_f  asg
     ,hri_cs_orgh_ct         orgh
     WHERE eq.assignment_id = asg.assignment_id
     AND eq.erlst_evnt_effective_date <= asg.effective_end_date
     AND asg.organization_id = orgh.orgh_organztn_fk;

  END IF;

END populate_wrkfc_evt_orgh_eq;
--
--
-- ----------------------------------------------------------------------------
-- Adds change records to workforce events by manager hierarchy queue
-- ----------------------------------------------------------------------------
--
PROCEDURE populate_wrkfc_evt_mgrh_eq IS

BEGIN

  -- Only insert event queue records if OBIEE is implemented
  IF g_implement_obiee_mgrh = 'Y' THEN

    INSERT INTO hri_eq_wrkfc_evt_mgrh
     (sup_person_id
     ,erlst_evnt_effective_date
     ,source_code)
-- Previous manager chains
     SELECT /*+ ORDERED */
      suph.sup_person_id
     ,GREATEST(eq.erlst_evnt_effective_date, evt.effective_change_date)
     ,'ASG_EVENT_PREV'
     FROM
      hri_eq_asgn_evnts      eq
     ,hri_mb_asgn_events_ct  evt
     ,hri_cs_suph            suph
     WHERE eq.assignment_id = evt.assignment_id
     AND evt.supervisor_id = suph.sub_person_id
     AND eq.erlst_evnt_effective_date <= evt.effective_change_end_date
     AND eq.erlst_evnt_effective_date - 1 <= suph.effective_end_date
     UNION ALL
-- New manager chains
     SELECT /*+ ORDERED */
      suph.sup_person_id
     ,GREATEST(eq.erlst_evnt_effective_date, asg.effective_start_date)
     ,'ASG_EVENT_CURR'
     FROM
      hri_eq_asgn_evnts      eq
     ,per_all_assignments_f  asg
     ,hri_cs_suph            suph
     WHERE eq.assignment_id = asg.assignment_id
     AND eq.erlst_evnt_effective_date <= asg.effective_end_date
     AND asg.supervisor_id = suph.sub_person_id
     AND eq.erlst_evnt_effective_date <= suph.effective_end_date;

  END IF;

END populate_wrkfc_evt_mgrh_eq;
--
-- ----------------------------------------------------------------------------
-- POPULATE_ASG_DELTA_EQ (4259598 Incremental Changes)
-- This procedure inserts all records from the assignment event queue into the
-- assignment event delta queue, which is used to incrementally refresh
-- the assignment delta table
-- ----------------------------------------------------------------------------
--
PROCEDURE populate_asg_delta_eq IS
  --
BEGIN
  --
  -- 4259598 Incremental Changes
  -- Populate the assignment event delta queue using which the assignment delta
  -- table can be refrshed incrementally. It should be noted that any point in
  -- time there should only be one record for an assingment in the event queue
  -- which contains the earliest event date for the assignment. Therefore, if
  -- a record exists for the asg then update the record otherwise, insert a
  -- new record for the assignment
  --
  -- Only do if DBI is implemented
  --
  IF g_implement_dbi = 'Y' THEN

    MERGE INTO hri_eq_asg_sup_wrfc delta_eq
    USING (SELECT assignment_id,
                  erlst_evnt_effective_date,
                  'ASG_EVENT' source_type
           FROM   hri_eq_asgn_evnts) asg_eq
    ON    (       delta_eq.source_type = 'ASG_EVENT'
           AND    asg_eq.assignment_id = delta_eq.source_id)
    WHEN MATCHED THEN
      UPDATE SET delta_eq.erlst_evnt_effective_date =
                 least(delta_eq.erlst_evnt_effective_date,asg_eq.erlst_evnt_effective_date)
    WHEN NOT MATCHED THEN
      INSERT (delta_eq.source_type,
              delta_eq.source_id,
              delta_eq.erlst_evnt_effective_date
              )
      VALUES (asg_eq.source_type,
              asg_eq.assignment_id,
              asg_eq.erlst_evnt_effective_date);
    --
    COMMIT;
    --
  END IF;
  --
END populate_asg_delta_eq;
--
-- ----------------------------------------------------------------------------
-- PROCEDURE insert_pow_change_events inserts period of work band changes in
-- the assignment events queue. If a record for the assignment id already
-- exists in the event queue, it updates if the POW band change occurs at an
-- earlier date. This procedure collects the period of work changes for
-- employees and contingent workers.
-- ----------------------------------------------------------------------------
--
PROCEDURE insert_pow_change_events
IS
  --
  -- Cursor to fetch the Period of work band change records
  -- for employees and contingent workers
  -- 4086548 changed the SQL for performance reasons
  -- Drive the query off asg events fact table. This also prevents the process
  -- from creating stray events for terminated person's and unrequired assignments.
  --
  CURSOR c_pow_changes IS
  SELECT DISTINCT asgn.assignment_id,
         add_months(pow_start_date_adj, band_range_high) first_event
  FROM   hri_mb_Asgn_events_ct asgn,
         hri_cs_pow_band_ct    powb
  WHERE  asgn.pow_band_sk_fk = powb.pow_band_sk_pk
  AND    powb.band_range_high is not null
  AND    asgn.worker_term_ind = 0
  AND    g_refresh_start_date <= asgn.effective_change_end_date
  AND    asgn.pow_start_date_adj BETWEEN add_months(g_refresh_start_date,-powb.band_range_high) AND
                              add_months(SYSDATE,-powb.band_range_high);
  --
  -- PLSQL tables for storing the assignment id and the date when a POW band
  -- change event occurs
  --
  l_pow_event_asg_id  g_number_tab_type;
  l_pow_event_date    g_date_tab_type;
  --
  l_upd_asg_id        NUMBER;
  l_upd_asg_date      DATE;
  --
  dml_errors          EXCEPTION;
  PRAGMA exception_init(dml_errors, -24381);
  --
BEGIN
  --
  dbg('Fetching pow band change records after previous refresh ' ||
      g_refresh_start_date || ' till ' || sysdate);
  --
  -- Open the cursor to fetch the period of work band changes
  --
  OPEN  c_pow_changes;
  FETCH c_pow_changes
    BULK COLLECT INTO
      l_pow_event_asg_id,
      l_pow_event_date;
  --
  CLOSE c_pow_changes;
  --
  IF l_pow_event_date.count = 0 THEN
    --
    dbg('no incremental pow events created' );
    RETURN;
    --
  END IF;
  --
  -- Loop though all the POW events and insert them in assignment events queue
  -- Those assignments which are already present in the queue will cause an exception to be
  -- raised. These assignments are handled in the exception section where they are updated
  -- if the event date in the PLSQL table is before the event date in the evetns queue
  --
  dbg('g_refresh_start_date = '||g_refresh_start_date);
  dbg('fetched '||l_pow_event_date.count||' records for writing to events queue');
  --
  FORALL l_loop IN l_pow_event_asg_id.FIRST..l_pow_event_asg_id.LAST SAVE EXCEPTIONS
    --
    INSERT /*+ APPEND */ INTO hri_eq_asgn_evnts(
      assignment_id,
      erlst_evnt_effective_date
    )
    VALUES(
      l_pow_event_asg_id(l_loop),
      l_pow_event_date(l_loop)
    );
  --
  -- Commit the transaction
  --
  COMMIT;
  --
  dbg('done inserting into events queue');
EXCEPTION
  --
  -- The case when the insertion was not possible because the assignment id was already present
  -- in the events queue.
  --
  WHEN dml_errors THEN
    --
    dbg('Updating some assignments');
    --
    -- Loop through all the assignments that could not ben inserted and caused
    -- the exception to be raised. They are updated if the event date in the PLSQL
    -- table is before the event date in the evetns queue
    --
    FOR l_loop IN 1..sql%bulk_exceptions.count LOOP
      --
      l_upd_asg_id   := l_pow_event_asg_id(sql%bulk_exceptions(l_loop).error_index);
      l_upd_asg_date := l_pow_event_date(sql%bulk_exceptions(l_loop).error_index);
      --
      UPDATE hri_eq_asgn_evnts
      SET    erlst_evnt_effective_date = least(erlst_evnt_effective_date,l_upd_asg_date)
      WHERE  assignment_id = l_upd_asg_id;
      --
    END LOOP;
    --
    COMMIT;
    --
  WHEN OTHERS THEN
    --
    dbg(SQLERRM);
    --
    -- Bug 4105868: Collection Diagnostic Call
    --
    g_msg_sub_group := NVL(g_msg_sub_group, 'INSERT_POW_CHANGE_EVENTS');
    --
    RAISE;
   --
END insert_pow_change_events;
--
--
-- Procedure to update the summarization related indicators for person
-- hiding purpose when the fast formula HRI_MAP_ASG_SUMMARIZATION exists
--
PROCEDURE check_update_smrztn_rqrmnt
 (p_effective_start_date    IN DATE,
  p_indicator_rec           IN OUT NOCOPY g_indicator_record,
  p_summarization_ind_prev  IN NUMBER
 ) IS
  --
  l_ff_exists         NUMBER;
  l_summarization_rqd VARCHAR2(1);
  l_summarization_ind  NUMBER;
  --
BEGIN
    --
    -- Call fast formula HRI_MAP_ASG_SUMMARIZATION  to get the summarization
    -- indicator
    --
    l_summarization_rqd := hri_bpl_asg_summarization.is_summarization_rqd(g_assignment_id,
                                                                          p_effective_start_date);
    --
    IF (l_summarization_rqd = 'N') THEN
      --
      l_summarization_ind := 0;
      --
    ELSE
      --
      l_summarization_ind := 1;
      --
    END IF;
    --
  --
  -- Determine the summarization change indicator
  --
  IF p_indicator_rec.worker_term_ind <> 1 THEN
    --
    p_indicator_rec.summarization_rqd_ind := l_summarization_ind;
    --
    IF NVL(l_summarization_ind,-1) <>
       NVL(p_summarization_ind_prev,-1) AND
       p_indicator_rec.asg_rtrspctv_strt_event_ind <> 1 AND
       p_indicator_rec.worker_hire_ind <> 1
    THEN
      --
      p_indicator_rec.summarization_rqd_chng_ind := 1;
      --
    END IF;
    --
  ELSE
    --
    -- In case of termination set the summarization_rqd_ind to the previous
    -- value so that the record is included in delta collection
    --
    p_indicator_rec.summarization_rqd_ind := p_summarization_ind_prev;
    --
  END IF;
  --
END check_update_smrztn_rqrmnt;
--
--------------------------------------------------------------------------------
-- Bulk insert the rows stored in the master pl/sql table
--------------------------------------------------------------------------------
PROCEDURE bulk_insert_rows
 (p_asgn_events_tab           IN g_asgn_events_tab_type) IS

  --
  -- Row count
  --
  l_row_count                           PLS_INTEGER;
  --
  -- Primary Key
  --
  l_tab_assignment_id                   g_number_tab_type;
  l_tab_change_date                     g_date_tab_type;
  l_tab_change_end_date                 g_date_tab_type;
  l_tab_pow_start_date_adj              g_date_tab_type;
  --
  --Id Keys
  --
  l_tab_person_id                       g_number_tab_type;
  --
  -- Assignment related FK ID's which are present in the
  -- assignment records after the event
  --
  l_tab_bus_grp_id                      g_number_tab_type;
  l_tab_grade_id                        g_number_tab_type;
  l_tab_job_id                          g_number_tab_type;
  l_tab_location_id                     g_number_tab_type;
  l_tab_organization_id                 g_number_tab_type;
  l_tab_supervisor_id                   g_number_tab_type;
  l_tab_position_id                     g_number_tab_type;
  l_tab_primary_flag                    g_varchar2_tab_type;
  l_tab_asg_type_code                   g_varchar2_tab_type;
  --
  -- Assignment releated FK ID's existing prior to the event
  --
  l_tab_grade_prv_id                    g_number_tab_type;
  l_tab_job_prv_id                      g_number_tab_type;
  l_tab_location_prv_id                 g_number_tab_type;
  l_tab_organization_prv_id             g_number_tab_type;
  l_tab_supervisor_prv_id               g_number_tab_type;
  l_tab_position_prv_id                 g_number_tab_type;
  l_tab_primary_flag_prv                g_varchar2_tab_type;
  --
  -- Other assignment related values
  --
  l_tab_change_reason_code              g_varchar2_tab_type;
  l_tab_leaving_reason_code             g_varchar2_tab_type;
  l_tab_pow_days_on_event_date          g_number_tab_type;
  l_tab_pow_months_on_event_date        g_number_tab_type;
  l_tab_days_since_last_prmtn           g_number_tab_type;
  l_tab_months_since_last_prmtn         g_number_tab_type;
  --
  -- Headcount related Measures and information for an assignment
  --
  l_tab_fte                             g_number_tab_type;
  l_tab_fte_prv                         g_number_tab_type;
  l_tab_headcount                       g_number_tab_type;
  l_tab_headcount_prv                   g_number_tab_type;
  --
  -- Salary related Measures and information for a person
  --
  l_tab_anl_slry                        g_number_tab_type;
  l_tab_anl_slry_prv                    g_number_tab_type;
  l_tab_anl_slry_currency               g_varchar2_tab_type;
  l_tab_anl_slry_currency_prv           g_varchar2_tab_type;
  l_tab_pay_proposal_id                 g_number_tab_type;
  --
  -- Separation Category related measure for a person
  --
  l_tab_separation_category             g_varchar2_tab_type;
  l_tab_separation_category_nxt         g_varchar2_tab_type;
  --
  -- Person Type Usage related measures
  --
  l_tab_prsntyp_sk_fk                   g_number_tab_type;
  l_tab_summarization_rqd_ind           g_number_tab_type;
  l_tab_sum_rqd_chng_ind                g_number_tab_type;
  l_tab_sum_rqd_chng_nxt_ind            g_number_tab_type;
  --
  -- Performance related measures and information for a person
  --
  l_tab_perf_nrmlsd_rating              g_number_tab_type;
  l_tab_perf_nrmlsd_rating_prv          g_number_tab_type;
  l_tab_perf_review_id                  g_number_tab_type;
  l_tab_perf_review_type_cd             g_varchar2_tab_type;
  l_tab_performance_rating_cd           g_varchar2_tab_type;
  l_tab_perf_change_ind                 g_number_tab_type;
  l_tab_perf_band                       g_number_tab_type;
  l_tab_perf_band_prv                   g_number_tab_type;
  l_tab_perf_band_change_ind            g_number_tab_type;
  --
  -- Peiord of Work related measures and information for a person
  --
  l_tab_pow_start_date                  g_date_tab_type;
  l_tab_pow_band_sk_fk                  g_number_tab_type;
  l_tab_pow_band_prv_sk_fk              g_number_tab_type;
  l_tab_pow_extn_strt_dt                g_date_tab_type;
  --
  l_tab_pow_change_ind                  g_number_tab_type;
  l_tab_pow_band_change_ind             g_number_tab_type;
  --
  -- Various Indicators
  --
  l_tab_asg_rtr_strt_event_ind          g_number_tab_type;
  l_tab_assignment_change_ind           g_number_tab_type;
  l_tab_salary_change_ind               g_number_tab_type;
  l_tab_headcount_gain_ind              g_number_tab_type;
  l_tab_headcount_loss_ind              g_number_tab_type;
  l_tab_fte_gain_ind                    g_number_tab_type;
  l_tab_fte_loss_ind                    g_number_tab_type;
  l_tab_contingent_ind                  g_number_tab_type;
  l_tab_employee_ind                    g_number_tab_type;
  l_tab_grade_change_ind                g_number_tab_type;
  l_tab_job_change_ind                  g_number_tab_type;
  l_tab_position_change_ind             g_number_tab_type;
  l_tab_location_change_ind             g_number_tab_type;
  l_tab_organization_change_ind         g_number_tab_type;
  l_tab_supervisor_change_ind           g_number_tab_type;
  l_tab_worker_hire_ind                 g_number_tab_type;
  l_tab_post_hire_asgn_start_ind        g_number_tab_type;
  l_tab_pre_sprtn_asgn_end_ind          g_number_tab_type;
  l_tab_term_voluntary_ind              g_number_tab_type;
  l_tab_term_involuntary_ind            g_number_tab_type;
  l_tab_worker_term_ind                 g_number_tab_type;
  l_tab_start_asg_sspnsn_ind            g_number_tab_type;
  l_tab_end_asg_sspnsn_ind              g_number_tab_type;
  l_tab_worker_term_nxt_ind             g_number_tab_type;
  l_tab_term_voluntary_nxt_ind          g_number_tab_type;
  l_tab_term_involuntary_nxt_ind        g_number_tab_type;
  l_tab_sup_change_nxt_ind              g_number_tab_type;
  l_tab_pre_sep_asgn_end_nxt_ind        g_number_tab_type;
  l_tab_promotion_ind                   g_number_tab_type;
  --
  -- Variable to store the WHO information
  --
  l_user_id                 NUMBER;
  l_current_time            DATE;
  --
BEGIN
  --
  -- Set row count
  --
  l_user_id         := fnd_global.user_id;
  l_current_time    := SYSDATE;
  --
  IF (p_asgn_events_tab.EXISTS(1)) THEN
    l_row_count := p_asgn_events_tab.LAST;
  ELSE
    l_row_count := 0;
  END IF;
  --
  -- Transfer rows from record to PL/SQL table for bulk insert
  --
  FOR i IN 1..l_row_count LOOP
    l_tab_assignment_id(i) := p_asgn_events_tab(i).assignment_id;
    l_tab_change_date(i) := p_asgn_events_tab(i).effective_change_date;
    l_tab_change_end_date(i) := p_asgn_events_tab(i).effective_change_end_date;
    l_tab_person_id(i) := p_asgn_events_tab(i).person_id;
    l_tab_bus_grp_id(i) := p_asgn_events_tab(i).business_group_id;
    l_tab_grade_id(i) := p_asgn_events_tab(i).grade_id;
    l_tab_job_id(i) := p_asgn_events_tab(i).job_id;
    l_tab_location_id(i) := p_asgn_events_tab(i).location_id;
    l_tab_organization_id(i) := p_asgn_events_tab(i).organization_id;
    l_tab_supervisor_id(i) := p_asgn_events_tab(i).supervisor_id;
    l_tab_position_id(i) := p_asgn_events_tab(i).position_id;
    l_tab_primary_flag(i) := p_asgn_events_tab(i).primary_flag;
    l_tab_asg_type_code(i) := p_asgn_events_tab(i).asg_type_code;
    l_tab_pow_start_date_adj(i) := p_asgn_events_tab(i).pow_start_date_adj;
    l_tab_grade_prv_id(i) := p_asgn_events_tab(i).grade_prv_id;
    l_tab_job_prv_id(i) := p_asgn_events_tab(i).job_prv_id;
    l_tab_location_prv_id(i) := p_asgn_events_tab(i).location_prv_id;
    l_tab_organization_prv_id(i) := p_asgn_events_tab(i).organization_prv_id;
    l_tab_supervisor_prv_id(i) := p_asgn_events_tab(i).supervisor_prv_id;
    l_tab_position_prv_id(i) := p_asgn_events_tab(i).position_prv_id;
    l_tab_primary_flag_prv(i) := p_asgn_events_tab(i).primary_flag_prv;
    l_tab_change_reason_code(i) := p_asgn_events_tab(i).change_reason_code;
    l_tab_leaving_reason_code(i) := p_asgn_events_tab(i).leaving_reason_code;
    l_tab_pow_days_on_event_date(i) := p_asgn_events_tab(i).pow_days_on_event_date;
    l_tab_pow_months_on_event_date(i) := p_asgn_events_tab(i).pow_months_on_event_date;
    l_tab_days_since_last_prmtn(i) := p_asgn_events_tab(i).days_since_last_prmtn;
    l_tab_months_since_last_prmtn(i) := p_asgn_events_tab(i).months_since_last_prmtn;
    l_tab_fte(i) := p_asgn_events_tab(i).fte;
    l_tab_fte_prv(i) := p_asgn_events_tab(i).fte_prv;
    l_tab_headcount(i) := p_asgn_events_tab(i).headcount;
    l_tab_headcount_prv(i) := p_asgn_events_tab(i).headcount_prv;
    l_tab_anl_slry(i) := p_asgn_events_tab(i).anl_slry;
    l_tab_anl_slry_prv(i) := p_asgn_events_tab(i).anl_slry_prv;
    l_tab_anl_slry_currency(i) := p_asgn_events_tab(i).anl_slry_currency;
    l_tab_anl_slry_currency_prv(i) := p_asgn_events_tab(i).anl_slry_currency_prv;
    l_tab_pay_proposal_id(i) := p_asgn_events_tab(i).pay_proposal_id;
    l_tab_separation_category(i) := p_asgn_events_tab(i).separation_category;
    l_tab_separation_category_nxt(i) := p_asgn_events_tab(i).separation_category_nxt;
    --
    -- Person Type Related
    --
    l_tab_prsntyp_sk_fk(i) := p_asgn_events_tab(i).prsntyp_sk_fk;
    l_tab_summarization_rqd_ind(i) := p_asgn_events_tab(i).summarization_rqd_ind;
    l_tab_sum_rqd_chng_ind(i) := p_asgn_events_tab(i).summarization_rqd_chng_ind;
    l_tab_sum_rqd_chng_nxt_ind(i) := p_asgn_events_tab(i).summarization_rqd_chng_nxt_ind;
    --
    -- Performance Related
    --
    l_tab_perf_nrmlsd_rating(i) := p_asgn_events_tab(i).perf_nrmlsd_rating;
    l_tab_perf_nrmlsd_rating_prv(i) := p_asgn_events_tab(i).perf_nrmlsd_rating_prv;
    l_tab_perf_review_id(i) := p_asgn_events_tab(i).performance_review_id;
    l_tab_perf_review_type_cd(i) := p_asgn_events_tab(i).perf_review_type_cd;
    l_tab_performance_rating_cd(i) := p_asgn_events_tab(i).performance_rating_cd;
    l_tab_perf_change_ind(i) := p_asgn_events_tab(i).perf_rating_change_ind;
    l_tab_perf_band(i) := p_asgn_events_tab(i).perf_band;
    l_tab_perf_band_prv(i) := p_asgn_events_tab(i).perf_band_prv;
    l_tab_perf_band_change_ind(i) := p_asgn_events_tab(i).perf_band_change_ind;
    l_tab_pow_start_date(i) := p_asgn_events_tab(i).pow_start_date;
    l_tab_pow_band_sk_fk(i) := p_asgn_events_tab(i).pow_band_sk_fk;
    l_tab_pow_band_prv_sk_fk(i) := p_asgn_events_tab(i).pow_band_prv_sk_fk;
    l_tab_pow_extn_strt_dt(i) := p_asgn_events_tab(i).pow_extn_strt_dt;
    l_tab_pow_change_ind(i) := p_asgn_events_tab(i).pow_band_change_ind;
    l_tab_pow_band_change_ind(i) := p_asgn_events_tab(i).pow_band_change_ind;
    l_tab_asg_rtr_strt_event_ind(i) := p_asgn_events_tab(i).asg_rtrspctv_strt_event_ind;
    l_tab_assignment_change_ind(i) := p_asgn_events_tab(i).assignment_change_ind;
    l_tab_salary_change_ind(i) := p_asgn_events_tab(i).salary_change_ind;
    l_tab_headcount_gain_ind(i) := p_asgn_events_tab(i).headcount_gain_ind;
    l_tab_headcount_loss_ind(i) := p_asgn_events_tab(i).headcount_loss_ind;
    l_tab_fte_gain_ind(i) := p_asgn_events_tab(i).fte_gain_ind;
    l_tab_fte_loss_ind(i) := p_asgn_events_tab(i).fte_loss_ind;
    l_tab_contingent_ind(i) := p_asgn_events_tab(i).contingent_ind;
    l_tab_employee_ind(i) := p_asgn_events_tab(i).employee_ind;
    l_tab_grade_change_ind(i) := p_asgn_events_tab(i).grade_change_ind;
    l_tab_job_change_ind(i) := p_asgn_events_tab(i).job_change_ind;
    l_tab_position_change_ind(i) := p_asgn_events_tab(i).position_change_ind;
    l_tab_location_change_ind(i) := p_asgn_events_tab(i).location_change_ind;
    l_tab_organization_change_ind(i) := p_asgn_events_tab(i).organization_change_ind;
    l_tab_supervisor_change_ind(i) := p_asgn_events_tab(i).supervisor_change_ind;
    l_tab_worker_hire_ind(i) := p_asgn_events_tab(i).worker_hire_ind;
    l_tab_post_hire_asgn_start_ind(i) := p_asgn_events_tab(i).post_hire_asgn_start_ind;
    l_tab_pre_sprtn_asgn_end_ind(i) := p_asgn_events_tab(i).pre_sprtn_asgn_end_ind;
    l_tab_term_voluntary_ind(i) := p_asgn_events_tab(i).term_voluntary_ind;
    l_tab_term_involuntary_ind(i) := p_asgn_events_tab(i).term_involuntary_ind;
    l_tab_worker_term_ind(i) := p_asgn_events_tab(i).worker_term_ind;
    l_tab_start_asg_sspnsn_ind(i) := p_asgn_events_tab(i).start_asg_sspnsn_ind;
    l_tab_end_asg_sspnsn_ind(i) := p_asgn_events_tab(i).end_asg_sspnsn_ind;
    l_tab_worker_term_nxt_ind(i) := p_asgn_events_tab(i).worker_term_nxt_ind;
    l_tab_term_voluntary_nxt_ind(i) := p_asgn_events_tab(i).term_voluntary_nxt_ind;
    l_tab_term_involuntary_nxt_ind(i) := p_asgn_events_tab(i).term_involuntary_nxt_ind;
    l_tab_sup_change_nxt_ind(i) := p_asgn_events_tab(i).supervisor_change_nxt_ind;
    l_tab_pre_sep_asgn_end_nxt_ind(i) := p_asgn_events_tab(i).pre_sprtn_asgn_end_nxt_ind;
    l_tab_promotion_ind(i) := p_asgn_events_tab(i).promotion_ind;

  END LOOP;
  --
  -- ------------------------------------------------------------------
  -- Starting bulk insert of all assignment events identified
  --
  dbg('Inserting data into table');
  --
  FORALL i IN 1..l_row_count
    INSERT INTO HRI_MB_ASGN_EVENTS_CT (
        --
        -- Unique key generated for the events fact
        --
         event_id
        --
        -- Effective Dates
        --
        ,effective_change_date
        ,effective_change_end_date
        --
        -- Id Keys
        --
        ,assignment_id
        ,person_id
        --
        -- Assignment related FK ID's which are present in the
        -- assignment records after the event
        --
        ,business_group_id
        ,grade_id
        ,job_id
        ,location_id
        ,organization_id
        ,supervisor_id
        ,position_id
        ,primary_flag
        ,asg_type_code
        ,pow_start_date_adj
       --
       -- Period of work related changes
       --
        ,pow_start_date
        --
        -- Assignment releated FK ID's existing prior to the event
        --
        ,grade_prv_id
        ,job_prv_id
        ,location_prv_id
        ,organization_prv_id
        ,supervisor_prv_id
        ,position_prv_id
        ,primary_flag_prv
        --
        -- Other assignment related values
        --
        ,change_reason_code
        ,leaving_reason_code
       --
       -- Separation Category related information for a person
       --
        ,separation_category
        ,separation_category_nxt
        ,pow_days_on_event_date
        ,pow_months_on_event_date
        ,days_since_last_prmtn
        ,months_since_last_prmtn
        --
        -- Headcount related Measures and information for an assignment
        --
        ,fte
        ,fte_prv
        ,headcount
        ,headcount_prv
        --
        -- Salary related Measures and information for a person
        --
        ,anl_slry
        ,anl_slry_prv
        ,anl_slry_currency
        ,anl_slry_currency_prv
        ,pay_proposal_id
        --
        -- Performance Related measures and information for a person
        --
        ,perf_nrmlsd_rating
        ,perf_nrmlsd_rating_prv
        ,perf_band
        ,perf_band_prv
        ,performance_review_id
        ,perf_review_type_cd
        ,performance_rating_cd
        --
        -- Period of work related measure and information for a person
        --
        ,pow_band_sk_fk
        ,pow_band_prv_sk_fk
        ,pow_extn_strt_dt
        --
        -- Person type usage related measures
        --
        ,prsntyp_sk_fk
        ,summarization_rqd_ind
        ,summarization_rqd_chng_ind
        ,summarization_rqd_chng_nxt_ind
        --
        --
        -- Indicators
        --
        ,asg_rtrspctv_strt_event_ind
        ,assignment_change_ind
        ,salary_change_ind
        --
        -- Performance related indicators
        --
        ,perf_rating_change_ind
        ,perf_band_change_ind
        --
        -- Period of work related indicators
        --
        ,pow_band_change_ind
        --
        -- Various Indicators
        --
        ,headcount_gain_ind
        ,headcount_loss_ind
        ,fte_gain_ind
        ,fte_loss_ind
        ,contingent_ind
        ,employee_ind
        ,grade_change_ind
        ,job_change_ind
        ,position_change_ind
        ,location_change_ind
        ,organization_change_ind
        ,supervisor_change_ind
        ,worker_hire_ind
        ,post_hire_asgn_start_ind
        ,pre_sprtn_asgn_end_ind
        ,term_voluntary_ind
        ,term_involuntary_ind
        ,worker_term_ind
        ,start_asg_sspnsn_ind
        ,end_asg_sspnsn_ind
        ,worker_term_nxt_ind
        ,term_voluntary_nxt_ind
        ,term_involuntary_nxt_ind
        ,supervisor_change_nxt_ind
        ,pre_sprtn_asgn_end_nxt_ind
        ,promotion_ind
        ,last_update_date
        ,last_update_login
        ,last_updated_by
        ,created_by
        ,creation_date)
    VALUES
      --
      -- Unique key generated for the events fact
      --
          (hri_mb_asgn_events_ct_s.nextval
      --
      -- Effective Dates
      --
          ,l_tab_change_date(i)
          ,l_tab_change_end_date(i)
      --
      -- Id Keys
      --
          ,l_tab_assignment_id(i)
          ,l_tab_person_id(i)
      --
      -- Assignment related FK ID's which are present in the
      -- assignment records after the event
      --
          ,l_tab_bus_grp_id(i)
          ,l_tab_grade_id(i)
          ,l_tab_job_id(i)
          ,l_tab_location_id(i)
          ,l_tab_organization_id(i)
          ,l_tab_supervisor_id(i)
          ,l_tab_position_id(i)
          ,l_tab_primary_flag(i)
          ,l_tab_asg_type_code(i)
          ,l_tab_pow_start_date_adj(i)
      --
      -- Period of work start date
      --
          ,l_tab_pow_start_date(i)
       --
       -- Assignment releated FK ID's existing prior to the event
       --
          ,l_tab_grade_prv_id(i)
          ,l_tab_job_prv_id(i)
          ,l_tab_location_prv_id(i)
          ,l_tab_organization_prv_id(i)
          ,l_tab_supervisor_prv_id(i)
          ,l_tab_position_prv_id(i)
          ,l_tab_primary_flag_prv(i)
       --
       -- Other assignment related values
       --
          ,l_tab_change_reason_code(i)
          ,l_tab_leaving_reason_code(i)
       --
       -- Separation Category related information
       --
          ,l_tab_separation_category(i)
          ,l_tab_separation_category_nxt(i)
          ,l_tab_pow_days_on_event_date(i)
          ,l_tab_pow_months_on_event_date(i)
          ,l_tab_days_since_last_prmtn(i)
          ,l_tab_months_since_last_prmtn(i)
       --
       -- Headcount related Measures and information for an assignment
       --
          ,l_tab_fte(i)
          ,l_tab_fte_prv(i)
          ,l_tab_headcount(i)
          ,l_tab_headcount_prv(i)
       --
       -- Salary related Measures and information for a person
       --
          ,l_tab_anl_slry(i)
          ,l_tab_anl_slry_prv(i)
          ,l_tab_anl_slry_currency(i)
          ,l_tab_anl_slry_currency_prv(i)
          ,l_tab_pay_proposal_id(i)
       --
       -- Performance rating related measures
       --
          ,l_tab_perf_nrmlsd_rating(i)
          ,l_tab_perf_nrmlsd_rating_prv(i)
          ,l_tab_perf_band(i)
          ,l_tab_perf_band_prv(i)
          ,l_tab_perf_review_id(i)
          ,l_tab_perf_review_type_cd(i)
          ,l_tab_performance_rating_cd(i)
       --
       -- Period of work related measures
       --
          ,l_tab_pow_band_sk_fk(i)
          ,l_tab_pow_band_prv_sk_fk(i)
          ,l_tab_pow_extn_strt_dt(i)
       --
       -- Person type related measures
       --
          ,l_tab_prsntyp_sk_fk(i)
          ,l_tab_summarization_rqd_ind(i)
          ,l_tab_sum_rqd_chng_ind(i)
          ,l_tab_sum_rqd_chng_nxt_ind(i)
       --
       -- Various Indicators
       --
          ,l_tab_asg_rtr_strt_event_ind(i)
          ,l_tab_assignment_change_ind(i)
          ,l_tab_salary_change_ind(i)
       --
       -- Performance Rating related indicators
       --
          ,l_tab_perf_change_ind(i)
          ,l_tab_perf_band_change_ind(i)
       --
       -- Period of work related indicators
       --
          ,l_tab_pow_band_change_ind(i)
        --
        -- Various Indicators
        --
          ,l_tab_headcount_gain_ind(i)
          ,l_tab_headcount_loss_ind(i)
          ,l_tab_fte_gain_ind(i)
          ,l_tab_fte_loss_ind(i)
          ,l_tab_contingent_ind(i)
          ,l_tab_employee_ind(i)
          ,l_tab_grade_change_ind(i)
          ,l_tab_job_change_ind(i)
          ,l_tab_position_change_ind(i)
          ,l_tab_location_change_ind(i)
          ,l_tab_organization_change_ind(i)
          ,l_tab_supervisor_change_ind(i)
          ,l_tab_worker_hire_ind(i)
          ,l_tab_post_hire_asgn_start_ind(i)
          ,l_tab_pre_sprtn_asgn_end_ind(i)
          ,l_tab_term_voluntary_ind(i)
          ,l_tab_term_involuntary_ind(i)
          ,l_tab_worker_term_ind(i)
          ,l_tab_start_asg_sspnsn_ind(i)
          ,l_tab_end_asg_sspnsn_ind(i)
          ,l_tab_worker_term_nxt_ind(i)
          ,l_tab_term_voluntary_nxt_ind(i)
          ,l_tab_term_involuntary_nxt_ind(i)
          ,l_tab_sup_change_nxt_ind(i)
          ,l_tab_pre_sep_asgn_end_nxt_ind(i)
          ,l_tab_promotion_ind(i)
          ,l_current_time
          ,l_user_id
          ,l_user_id
          ,l_user_id
          ,l_current_time);
  --
  -- End of bulk insert of all assignment changes.
  -- ------------------------------------------------------------------
  dbg('Done insert ok');
  --
END bulk_insert_rows;

--
-- -----------------------------------------------------------------------------
-- 5A Delete Records
--    This Procedure deletes all records for the chunk of assignments that are
--    on or later than the earliest change date for each assignment
-- ----------------------------------------------------------------------------
--
PROCEDURE delete_records
  (p_start_assignment_id   IN NUMBER,
   p_end_assignment_id     IN NUMBER) IS
--
BEGIN
--
  --
  dbg('Entering delete_records');
  --
  -- Delete all assingment event records for the events that have occurred on or
  -- after the refresh date.
  --
  DELETE FROM hri_mb_asgn_events_ct evt
  WHERE evt.rowid IN
   (SELECT evt2.rowid
    FROM hri_eq_asgn_evnts      eq
       , hri_mb_asgn_events_ct  evt2
    WHERE eq.assignment_id = evt2.assignment_id
    AND evt2.effective_change_date >= eq.erlst_evnt_effective_date
    AND eq.assignment_id BETWEEN p_start_assignment_id AND p_end_assignment_id);
  --
  dbg('Deleted records occuring on or after '||g_refresh_start_date);
  --
--
END delete_records;
--
-- -----------------------------------------------------------------------------
-- 5B Identify Assignment Changes
--    This Procedure creates an assignment change history array for a given
--    assignment. It also inserts a record in the combined event list array
--    for each change.
-- ----------------------------------------------------------------------------
--
PROCEDURE identify_assignment_changes(
  p_date_master_tab  OUT NOCOPY g_master_tab_type,
  p_asg_change_tab   OUT NOCOPY g_asg_change_tab_type,
  p_asg_dates        OUT NOCOPY g_asg_date_type) IS
  --
  -- Cursor to get the assignment details of the assignment_id for assignment
  -- type 'Employee' and 'Contingent'. The hiring date, termination date and
  -- leaving reason for 'Employee' assignments collected from the table
  -- per_periods_of_service while the same details for the 'Contingent'
  -- assignments are collected from the table per_periods_of_placement.
  --
  CURSOR asg_csr IS
  SELECT
   GREATEST(ptu.effective_start_date, asg.effective_start_date) effective_start_date
  ,least(ptu.effective_end_date, asg.effective_end_date) effective_end_date
  ,NVL(pos.date_start,pop.date_start)     hire_date
  ,NVL(pos.actual_termination_date,pop.actual_termination_date)
                                          termination_date
  ,asg.assignment_id                      assignment_id
  ,asg.person_id                          person_id
  ,asg.business_group_id                  business_group_id
  ,NVL(asg.organization_id,-1)            organization_id
  ,NVL(asg.location_id,-1)                location_id
  ,NVL(asg.job_id,-1)                     job_id
  ,NVL(asg.grade_id,-1)                   grade_id
  ,NVL(asg.position_id,-1)                position_id
  ,NVL(asg.supervisor_id,-1)              supervisor_id
  ,NVL(asg.primary_flag,'N')              primary_flag
  ,asg.assignment_type                    assignment_type
  ,NVL(NVL(pos.leaving_reason,pop.termination_reason),'NA_EDW')
                                          separation_reason_code
  ,NVL(asg.change_reason,'NA_EDW')        assignment_reason_code
  ,ast.per_system_status                  assignment_status_code
  ,NVL(asg.payroll_id,-1)                 payroll_id
  ,NVL(asg.pay_basis_id,-1)               pay_basis_id
  ,pos.adjusted_svc_date                  pow_start_date_adj
  ,hpt.prsntyp_sk_pk                      prsntyp_sk_fk
  ,nvl(decode(hpt.include_flag_code,'Y',1,0),1)  summarization_rqd_ind
  ,hpt.wkth_wktyp_code                    wkth_wktyp_code
  FROM   per_all_assignments_f        asg
        ,per_assignment_status_types  ast
        ,per_periods_of_service       pos
        ,per_periods_of_placement     pop
        ,per_person_type_usages_f     ptu
        ,hri_cs_prsntyp_ct            hpt
  WHERE  asg.assignment_id = g_assignment_id
  AND    ast.assignment_status_type_id = asg.assignment_status_type_id
  AND    pos.period_of_service_id(+) = asg.period_of_service_id
  AND    pop.person_id(+) = asg.person_id
  AND    pop.date_start(+) = asg.period_of_placement_date_start
  AND    ast.per_system_status <> 'TERM_ASSIGN'
  AND    asg.assignment_type IN ('E','C')
  --
  -- Need assignment details on refresh date - 1 otherwise it would be
  -- difficult to tell whether an assignment that starts on refresh start
  -- date was an assignment start or an assignment change
  --
  AND (asg.effective_start_date >= (g_refresh_start_date - 1)
    OR (g_refresh_start_date - 1) BETWEEN asg.effective_start_date
                                  AND asg.effective_end_date)
  AND    (asg.effective_start_date between ptu.effective_start_date and ptu.effective_end_date OR
          ptu.effective_start_date between asg.effective_start_date and asg.effective_end_date)
  AND    ptu.person_id      = asg.person_id
  AND    hpt.person_type_id = ptu.person_type_id
  AND    hpt.employment_category_code = nvl(asg.employment_category,'NA_EDW')
  AND    hpt.primary_flag_code = nvl(asg.primary_flag,'NA_EDW')
  AND    hpt.assignment_type_code = asg.assignment_type
  ORDER BY 1;
  --
  -- ---------------------------------------------------------------------------
  -- Local Package Variables - reset every time procedure is called
  --
  -- Local PL/SQL tables to fetch cursor
  -- Note in 9i bulk fetch directly into table of records is supported
  --
  l_asg_change_date           g_date_tab_type;
  l_asg_change_end_date       g_date_tab_type;
  l_asg_hire_date             g_date_tab_type;
  l_asg_termination_date      g_date_tab_type;
  l_pow_start_date_adj        g_date_tab_type;
  l_asg_assignment_id         g_number_tab_type;
  l_asg_person_id             g_number_tab_type;
  l_asg_business_group_id     g_number_tab_type;
  l_asg_organization_id       g_number_tab_type;
  l_asg_location_id           g_number_tab_type;
  l_asg_job_id                g_number_tab_type;
  l_asg_grade_id              g_number_tab_type;
  l_asg_position_id           g_number_tab_type;
  l_asg_supervisor_id         g_number_tab_type;
  l_asg_primary_flag          g_varchar2_tab_type;
  l_asg_type                  g_varchar2_tab_type;
  l_asg_leaving_reason_code   g_varchar2_tab_type;
  l_asg_change_reason_code    g_varchar2_tab_type;
  l_asg_status_code           g_varchar2_tab_type;
  l_payroll_id                g_number_tab_type;
  l_pay_basis_id              g_number_tab_type;
  l_prsntyp_sk_fk             g_number_tab_type;
  l_summarization_rqd_ind     g_number_tab_type;
  l_wkth_wktyp_code           g_varchar2_tab_type;
  --
  -- Variable to collect the total number of records in the assignment cursor
  --
  l_asg_no_records               PLS_INTEGER;
  --
  -- Index variables used to load the master record table for assignment changes
  --
  l_asg_index                    PLS_INTEGER;
  l_date_index                   PLS_INTEGER;
  --
  -- Indicator variable which determmines if an assignment started before the DBI
  -- collection start date
  --
  l_rtrspctv_strt_ind             PLS_INTEGER := 0;
  --
  -- Indicator variable which determines if an assignment event has occured on
  -- the relevant date
  --
  l_asg_evt_ind                   PLS_INTEGER := 1;
  --
BEGIN
  --
  dbg('Entering identify_assignment_changes');
  --
  -- Bulk load cursor into PLSQL table
  --
  OPEN asg_csr;
  FETCH asg_csr BULK COLLECT INTO
     l_asg_change_date
    ,l_asg_change_end_date
    ,l_asg_hire_date
    ,l_asg_termination_date
    ,l_asg_assignment_id
    ,l_asg_person_id
    ,l_asg_business_group_id
    ,l_asg_organization_id
    ,l_asg_location_id
    ,l_asg_job_id
    ,l_asg_grade_id
    ,l_asg_position_id
    ,l_asg_supervisor_id
    ,l_asg_primary_flag
    ,l_asg_type
    ,l_asg_leaving_reason_code
    ,l_asg_change_reason_code
    ,l_asg_status_code
    ,l_payroll_id
    ,l_pay_basis_id
    ,l_pow_start_date_adj
    ,l_prsntyp_sk_fk
    ,l_summarization_rqd_ind
    ,l_wkth_wktyp_code;
  --
  l_asg_no_records := asg_csr%ROWCOUNT;
  --
  CLOSE asg_csr;
  --
  -- Bail out if no assignment rows are returned
  --
  IF (l_asg_no_records = 0
      OR l_asg_no_records IS NULL) THEN
    --
    dbg('No records founds therefore exiting');
    --
    RAISE NO_ASSIGNMENT_RECORD_FOUND;
    --
  ELSE
    -- Translate to table of records
    FOR i IN 1..l_asg_no_records LOOP
      p_asg_change_tab(i).change_date := l_asg_change_date(i);
      p_asg_change_tab(i).change_end_date := l_asg_change_end_date(i);
      p_asg_change_tab(i).hire_date := l_asg_hire_date(i);
      p_asg_change_tab(i).termination_date := l_asg_termination_date(i);
      p_asg_change_tab(i).assignment_id := l_asg_assignment_id(i);
      p_asg_change_tab(i).person_id := l_asg_person_id(i);
      p_asg_change_tab(i).business_group_id := l_asg_business_group_id(i);
      p_asg_change_tab(i).organization_id := l_asg_organization_id(i);
      p_asg_change_tab(i).location_id := l_asg_location_id(i);
      p_asg_change_tab(i).job_id := l_asg_job_id(i);
      p_asg_change_tab(i).grade_id := l_asg_grade_id(i);
      p_asg_change_tab(i).position_id := l_asg_position_id(i);
      p_asg_change_tab(i).supervisor_id := l_asg_supervisor_id(i);
      p_asg_change_tab(i).primary_flag := l_asg_primary_flag(i);
      p_asg_change_tab(i).type := l_asg_type(i);
      p_asg_change_tab(i).leaving_reason_code := l_asg_leaving_reason_code(i);
      p_asg_change_tab(i).change_reason_code := l_asg_change_reason_code(i);
      p_asg_change_tab(i).status_code := l_asg_status_code(i);
      p_asg_change_tab(i).payroll_id := l_payroll_id(i);
      p_asg_change_tab(i).pay_basis_id := l_pay_basis_id(i);
      p_asg_change_tab(i).pow_start_date_adj := l_pow_start_date_adj(i);
      --
      -- Person Type Change
      --
      p_asg_change_tab(i).prsntyp_sk_fk := l_prsntyp_sk_fk(i);
      p_asg_change_tab(i).summarization_rqd_ind := l_summarization_rqd_ind(i);
      p_asg_change_tab(i).wkth_wktyp_code := l_wkth_wktyp_code(i);
    END LOOP;
  END IF;
  --
  -- Insert termination record if assignment is ended or separated
  -- and set assignment end date if it is the former
  --
  IF (p_asg_change_tab(l_asg_no_records).change_end_date < g_end_of_time) THEN
    --
    dbg('Inserting a termination record');
    --
    -- Increment counter to index the termination record
    --
    l_asg_no_records := l_asg_no_records + 1;
    --
    -- Add termination record for assignment end or separation
    --
    p_asg_change_tab(l_asg_no_records).change_date :=
                    p_asg_change_tab(l_asg_no_records - 1).change_end_date + 1;
    p_asg_change_tab(l_asg_no_records).change_end_date := g_end_of_time;
    p_asg_change_tab(l_asg_no_records).hire_date :=
                    p_asg_change_tab(l_asg_no_records - 1).hire_date;
    p_asg_change_tab(l_asg_no_records).termination_date :=
                    p_asg_change_tab(l_asg_no_records - 1).termination_date;
    p_asg_change_tab(l_asg_no_records).assignment_id :=
                    p_asg_change_tab(l_asg_no_records - 1).assignment_id;
    p_asg_change_tab(l_asg_no_records).person_id :=
                    p_asg_change_tab(l_asg_no_records - 1).person_id;
    p_asg_change_tab(l_asg_no_records).business_group_id :=
                    p_asg_change_tab(l_asg_no_records - 1).business_group_id;
    p_asg_change_tab(l_asg_no_records).leaving_reason_code :=
                    p_asg_change_tab(l_asg_no_records - 1).leaving_reason_code;
    p_asg_change_tab(l_asg_no_records).change_reason_code :=
                    p_asg_change_tab(l_asg_no_records - 1).change_reason_code;
    p_asg_change_tab(l_asg_no_records).primary_flag :=
                    p_asg_change_tab(l_asg_no_records - 1).primary_flag;
    p_asg_change_tab(l_asg_no_records).type :=
                    p_asg_change_tab(l_asg_no_records - 1).type;
    --
    p_asg_change_tab(l_asg_no_records).organization_id := -1;
    p_asg_change_tab(l_asg_no_records).location_id := -1;
    p_asg_change_tab(l_asg_no_records).job_id := -1;
    p_asg_change_tab(l_asg_no_records).grade_id := -1;
    p_asg_change_tab(l_asg_no_records).position_id := -1;
    p_asg_change_tab(l_asg_no_records).supervisor_id := -1;
    p_asg_change_tab(l_asg_no_records).status_code := 'NA_EDW';
    --
    -- If the assignment is ended and not separated then set the assignment end date
    -- (secondary assignment end date)
    --
    IF ((p_asg_change_tab(l_asg_no_records - 1).change_end_date <
                    p_asg_change_tab(l_asg_no_records - 1).termination_date)
     OR (p_asg_change_tab(l_asg_no_records - 1).termination_date IS NULL)) THEN
      --
      p_asg_dates.pre_sprtn_asgn_end_date :=
                    p_asg_change_tab(l_asg_no_records - 1).change_end_date;
      --
    END IF;
    --
    -- Set refresh range for salary and ABV to active assignment date range
    -- In case a person has an EMP_APL assignment, the person can have a
    -- primary assignment starting after the hire_date and also he can have
    -- a assignment budget value. In such a case if the start_date_active is
    -- not set to the assignment_start_date the abv and asg records in the date
    -- master table may go out of sync.
    --
    IF (p_asg_change_tab(1).change_date >=
        NVL(p_asg_change_tab(1).hire_date, p_asg_change_tab(1).change_date)) THEN
      --
      p_asg_dates.start_date_active :=
        GREATEST(p_asg_change_tab(1).change_date, g_refresh_start_date);
      --
    ELSE
      --
      p_asg_dates.start_date_active :=
        GREATEST(p_asg_change_tab(1).hire_date, g_refresh_start_date);
    END IF;
    --
    p_asg_dates.end_date_active :=
        p_asg_change_tab(l_asg_no_records - 1).change_end_date;
    --
  --
  -- If the assignment has not ended or seperated
  --
  ELSE
    --
    -- Set refresh range for salary and ABV events
    --
    IF (p_asg_change_tab(1).change_date >=
        NVL(p_asg_change_tab(1).hire_date, p_asg_change_tab(1).change_date)) THEN
      --
      p_asg_dates.start_date_active :=
        GREATEST(p_asg_change_tab(1).change_date, g_refresh_start_date);
      --
    ELSE
      --
      p_asg_dates.start_date_active :=
        GREATEST(p_asg_change_tab(1).hire_date, g_refresh_start_date);
      --
    END IF;
    --
    p_asg_dates.end_date_active    := g_end_of_time;
    --
  END IF;
  --
  -- Set assignment table pointer at second record (see comment in asg_csr)
  -- if the first record ends before the refresh period
  --
  IF (p_asg_change_tab(1).change_end_date < g_refresh_start_date) THEN
    --
    l_asg_index := 2;
    --
  --
  -- If the first record does not end before the refresh period
  --
  ELSE
    --
    -- Point at first record
    --
    l_asg_index := 1;
    --
    -- If the first record starts after the hire date then it is an assignment
    -- start (new secondary assignment)
    --
    IF (p_asg_change_tab(1).change_date > p_asg_change_tab(l_asg_index).hire_date
        AND (p_asg_change_tab(1).change_date >= g_refresh_start_date)) THEN
      --
      -- Assign the secondary assignment start date
      --
      p_asg_dates.post_hire_asgn_start_date :=
         p_asg_change_tab(l_asg_index).change_date;
      --
    END IF;
    --
  END IF;
  --
  -- If the record starts before the dbi collection start date
  --
  IF (p_asg_change_tab(1).change_date < g_dbi_collection_start_date) THEN
    --
    -- Assign the retrospective start event indicator to 1.
    --
    l_rtrspctv_strt_ind := 1;
    --
  END IF;
  --
  -- If there is no assignment event on refresh start
  --
  IF (p_asg_change_tab(l_asg_index).change_date < g_refresh_start_date) THEN
    --
    -- Assign the assignment start date for the record as refresh start date
    --
    p_asg_change_tab(l_asg_index).change_date := g_refresh_start_date;
    --
    -- Set the assignment event indicator to 0
    --
    l_asg_evt_ind := 0;
    --
  END IF;
  --
  -- Store hire and termination dates
  --
  p_asg_dates.hire_date        := p_asg_change_tab(1).hire_date;
  p_asg_dates.termination_date := p_asg_change_tab(1).termination_date;
  --
  -- The period of service is calculated based on the profile option
  -- HRI:Period of Service / Placement Date Start Source
  -- The asg delta table calculates the pow based on pow_start_date_adj
  -- Based on the value of the profile the columns should be populated
  -- as either hire date or least of hire date and adjusted service date
  --
  dbg('g_adj_svc_profile='||g_adj_svc_profile);
  IF g_adj_svc_profile = 'ADJSTD_SVC_DT' THEN
    --
    p_asg_dates.pow_start_date_adj :=  LEAST(NVL(p_asg_change_tab(1).pow_start_date_adj,
                                                 p_asg_dates.hire_date),
                                             p_asg_dates.hire_date);
    --
  ELSE
    --
    p_asg_dates.pow_start_date_adj := p_asg_dates.hire_date;
    --
  END IF;
  --
dbg('p_asg_dates.pow_start_date_adj='||p_asg_dates.pow_start_date_adj);
  --
  --  Transpose assignment records to master records PLSQL table
  --  Start of the loop
  --
  FOR i IN l_asg_index..l_asg_no_records LOOP
    --
    -- 3900275 The assignment table contains a lot of records which are not
    -- relevant in DBI. Collect only those records which contains changes that
    -- impacts DBI. Ignore all other records
    --
    IF (l_asg_index = i OR
  (p_asg_change_tab(i).organization_id     <> p_asg_change_tab(i-1).organization_id OR
   p_asg_change_tab(i).location_id         <> p_asg_change_tab(i-1).location_id OR
   p_asg_change_tab(i).job_id              <> p_asg_change_tab(i-1).job_id OR
   p_asg_change_tab(i).grade_id            <> p_asg_change_tab(i-1).grade_id OR
   p_asg_change_tab(i).position_id         <> p_asg_change_tab(i-1).position_id OR
   p_asg_change_tab(i).supervisor_id       <> p_asg_change_tab(i-1).supervisor_id OR
   p_asg_change_tab(i).primary_flag        <> p_asg_change_tab(i-1).primary_flag OR
   p_asg_change_tab(i).type                <> p_asg_change_tab(i-1).type OR
   p_asg_change_tab(i).leaving_reason_code <> p_asg_change_tab(i-1).leaving_reason_code OR
   p_asg_change_tab(i).change_reason_code  <> p_asg_change_tab(i-1).change_reason_code OR
   p_asg_change_tab(i).status_code         <> p_asg_change_tab(i-1).status_code OR
   p_asg_change_tab(i).payroll_id          <> p_asg_change_tab(i-1).payroll_id OR
   p_asg_change_tab(i).pay_basis_id        <> p_asg_change_tab(i-1).pay_basis_id OR
   p_asg_change_tab(i).prsntyp_sk_fk       <> p_asg_change_tab(i-1).prsntyp_sk_fk
  )
       ) THEN
      --
      -- Calculate date index value as the difference between the assignment
      -- start date and refresh start date. Being the difference between two
      -- dates, this will be an integer
      --
      l_date_index := p_asg_change_tab(i).change_date - g_refresh_start_date;
      --
      -- Assignment of the assignment index value
      --
      p_date_master_tab(l_date_index).asg_index := i;
      --
      -- Assignment of primary flag value for use in ABV calculations (FF bypass)
      --
      p_date_master_tab(l_date_index).primary_flag := p_asg_change_tab(i).primary_flag;
      --
      -- Store a null ABV value for FTE and Headcounts for time being. These will
      -- be updated in procedures identify_abv_changes and fill_gaps_in_abv_history.
      --
      p_date_master_tab(l_date_index).fte := to_number(null);
      p_date_master_tab(l_date_index).headcount := to_number(null);
      --
      -- Set the retrospective start indicator in the master table based on the
      -- value of the indicator variable l_rtrspctv_strt_ind.
      --
      IF (l_asg_evt_ind = 0) THEN
        --
        p_date_master_tab(l_date_index).rtrspctv_strt_ind := l_rtrspctv_strt_ind;
        --
      END IF;
      --
      -- After first record this indicator will be 0
      --
      l_rtrspctv_strt_ind := 0;
      --
      -- Set the assignment event indicator in the master table based on the
      -- value of the indicator varable l_asg_evt_ind
      --
      p_date_master_tab(l_date_index).asg_evt_ind := l_asg_evt_ind;
      --
      -- After first record all records are assignment events
      --
      l_asg_evt_ind := 1;
      --
      -- In case if the person type dimension code of the the record is CWK
      -- then in order to determine the extension period, person's projected end date
      -- should be also be stored. Store it in a global variable which is used in
      -- identify_pow_band_changes procedure
      --
      IF p_asg_change_tab(i).wkth_wktyp_code = 'CWK' THEN
        --
        g_cwk_asg := TRUE;
        --
      END IF;
      --
    END IF;
    --
  END LOOP;
  --
  -- End of the loop for transposing the assignment record to master record
  -- PL/SQL table
  --
  dbg('Exiting identify_assignment_changes');
--
--
-- When an exception is raised, the cursor is closed and the exception is passed
-- out of this block and it is handled in the collect procedure where an entry
-- of this is made in the concurrent log
--
EXCEPTION
  --
  WHEN NO_ASSIGNMENT_RECORD_FOUND THEN
    --
    -- Bug 4105868: Collection Diagnostic Call
    --
    g_msg_sub_group := NVL(g_msg_sub_group, 'IDENTIFY_ASSIGNMENT_CHANGES');
    --
    -- Raise the error and so that it is handled in the process_range procedure
    --
    RAISE NO_ASSIGNMENT_RECORD_FOUND;
    --
  WHEN OTHERS THEN
    --
    dbg('Error encountered in identify_assignment_changes');
    dbg(SQLERRM);
    --
    IF asg_csr%ISOPEN THEN
      --
      CLOSE asg_csr;
      --
    END IF;
    --
    g_msg_sub_group := NVL(g_msg_sub_group, 'IDENTIFY_ASSIGNMENT_CHANGES');
    --
    RAISE;
    --
--
END identify_assignment_changes;
--
-- ----------------------------------------------------------------------------
-- 5C Identify ABV Changes
--    Inserts a record in the combined event list array for each ABV change
--    for Headcount or FTE.
-- ----------------------------------------------------------------------------
--
PROCEDURE identify_abv_changes(
  p_asg_dates              IN g_asg_date_type,
  p_date_master_tab        IN OUT NOCOPY g_master_tab_type,
  p_prv_rec                IN OUT NOCOPY g_prv_record) IS
  --
  -- Cursor for assignment budget value changes
  --
  CURSOR abv_csr
  IS
  SELECT
  abv.value                         value
  ,abv.unit                         unit
  ,abv.effective_start_date         abv_start_date
  ,GREATEST(abv.effective_start_date, p_asg_dates.start_date_active)
                                    effective_start_date
  ,LEAST(abv.effective_end_date, p_asg_dates.end_date_active)
                                    effective_end_date
  ,DECODE(SIGN(p_asg_dates.start_date_active - abv.effective_start_date),1,0,1)
                                    abv_evt_ind
  FROM   per_assignment_budget_values_f   abv
  WHERE  abv.assignment_id = g_assignment_id
  AND    abv.unit IN ('HEAD','FTE')
  --
  -- Only ABVs in collection period needs to be selected
  --
  AND   (abv.effective_start_date BETWEEN p_asg_dates.start_date_active AND p_asg_dates.end_date_active
       OR p_asg_dates.start_date_active BETWEEN abv.effective_start_date AND abv.effective_end_date)
  ORDER BY abv.unit, abv.effective_start_date;
  --
  -- Index variables for indexing the master records PL/SQL table
  --
  l_start_date_index             PLS_INTEGER;
  l_end_date_index               PLS_INTEGER;
  --
--
BEGIN
  --
  dbg('Entering identify_abv_changes');
  --
  -- Load up the assignment budget value records for the assignment
  --
  -- =============================================================================
  -- Start of loop for ABV cursor
  -- Loop through the ABV cursor records and add in ABV change events
  -- clashes with assignment events will be overwritten by the ABV events
  --
  FOR abv_rec IN  abv_csr LOOP
    --
    -- Calculate index value as the difference between the ABV event
    -- start date and refresh start date. Being the difference between two
    -- dates, this will be an integer
    --
    l_start_date_index := abv_rec.effective_start_date - g_refresh_start_date;
    --
    -- If  the ABV values for the record ends at end of time, do not process them
    --
    IF (abv_rec.effective_end_date < g_end_of_time) THEN
      --
      l_end_date_index   := abv_rec.effective_end_date + 1 - g_refresh_start_date;
      --
    ELSE
      --
      l_end_date_index := to_number(null);
      --
    END IF;
    --
    -- Split out on measurement type and store in master date-indexed PLSQL table
    --
    IF abv_rec.unit = 'FTE'
       AND g_collect_fte = 'Y' THEN
      --
      -- If there is a FTE change event on DBI collection start date then do
      -- not set the retrospective start indicator.
      --
      IF abv_rec.abv_start_date = g_dbi_collection_start_date THEN
        --
        p_date_master_tab(l_start_date_index).rtrspctv_strt_ind := 0;
        --
      END IF;
      --
      -- Store new ABV value at start
      --
      p_date_master_tab(l_start_date_index).fte         := abv_rec.value;
      --
      -- If an abv event has occurred then only set the fte record indicator to
      -- 1, else set the fte record indicator to 0
      --
      IF abv_rec.abv_evt_ind = 1 THEN
        --
        p_date_master_tab(l_start_date_index).fte_record_ind  := 1;
        --
      ELSE
        --
        p_date_master_tab(l_start_date_index).fte_record_ind  := 0;
        --
      END IF;
      --
      -- Blank out ABV value at end (this may be overwritten by next ABV start)
      --
      IF (l_end_date_index IS NOT NULL) THEN
        --
        p_date_master_tab(l_end_date_index).fte := to_number(null);
        --
        -- If an abv event has occurred then only set the fte record indicator
        -- to 1, else set the fte_record_indicator to 0
        --
        IF abv_rec.abv_evt_ind = 1 THEN
          --
          p_date_master_tab(l_end_date_index).fte_record_ind  := 1;
          --
        ELSE
          --
          p_date_master_tab(l_end_date_index).fte_record_ind  := 0;
          --
        END IF;
        --
      END IF;
    --
    ELSIF abv_rec.unit = 'HEAD' AND
          g_collect_hdc = 'Y'
    THEN
      --
      -- If there is a headcount change event on DBI collection start date then
      -- do not set the retrospective start indicator.
      --
      IF abv_rec.abv_start_date = g_dbi_collection_start_date THEN
        --
        p_date_master_tab(l_start_date_index).rtrspctv_strt_ind := 0;
        --
      END IF;
      --
      -- Store new ABV value at start
      --
      p_date_master_tab(l_start_date_index).headcount  := abv_rec.value;
      --
      -- If an abv event has occurred then only set the headcount record indicator
      -- to 1, else set the headcount record indicator to 0
      --
      IF abv_rec.abv_evt_ind = 1 THEN
        --
        p_date_master_tab(l_start_date_index).hdc_record_ind  := 1;
        --
      ELSE
        --
        p_date_master_tab(l_start_date_index).hdc_record_ind  := 0;
        --
      END IF;
      --
      -- Blank out ABV value at end (this may be overwritten by next ABV start)
      --
      IF (l_end_date_index IS NOT NULL) THEN
        --
        p_date_master_tab(l_end_date_index).headcount := to_number(null);
        --
        -- If an abv event has occurred then only set the headcount record indicator
        -- to 1, else set the headcount record indicator to 0
        --
        IF abv_rec.abv_evt_ind = 1 THEN
          --
          p_date_master_tab(l_end_date_index).hdc_record_ind  := 1;
          --
        ELSE
          --
          p_date_master_tab(l_end_date_index).hdc_record_ind  := 0;
          --
        END IF;
      --
      END IF;
      --
    END IF;
    --
  END LOOP;
  --
--
-- End of loop for ABV cursor
-- =============================================================================
--
--
-- When an exception is raised, the cursor is closed and the exception is passed
-- out of this block and it is handled in the collect procedure where an entry
-- of this is made in the concurrent log
--
dbg('Exiting identify_abv_changes');
--
EXCEPTION
--
  WHEN OTHERS THEN
    --
    dbg('Error encountered in identify_abv_changes');
    dbg(SQLERRM);
    --
    IF abv_csr%ISOPEN THEN
      --
      CLOSE abv_csr;
      --
    END IF;
    --
    -- Bug 4105868: Collection Diagnostic Call
    --
    g_msg_sub_group := NVL(g_msg_sub_group, 'IDENTIFY_ABV_CHANGES');
    --
    RAISE;
    --
--
END identify_abv_changes;
--
-- -----------------------------------------------------------------------------
-- 5D Fill gaps in ABV history
--    Where there is no data for an assignment in PER_ASSIGNMENT_BUDGET_VALUES_F
--    close the gap. This is achieved by using fast formula at every point
--    where there is an assignment change to calculate the value.
-- ----------------------------------------------------------------------------
--
PROCEDURE fill_gaps_in_abv_history(
  p_date_master_tab    IN OUT NOCOPY g_master_tab_type,
  p_business_group_id  IN NUMBER,
  p_asg_dates          IN g_asg_date_type) IS
  --
  -- Index variables
  --
  l_date_index                   PLS_INTEGER;
  --
  -- ABV values from ABV table
  --
  l_fte_active                   NUMBER;
  l_headcount_active             NUMBER;
  --
  -- Assignment Primary Flag value
  --
  l_primary_flag                 VARCHAR2(30);
--
BEGIN
--
dbg('Entering fill_gaps_in_abv_history');
--
--
-- Calculate any unknown Assignment Budget Values
--
-- ----------------------------------------------------------------------------
-- At this point the date-indexed master PL/SQL table might look like:
--
-- Date Index    ABV Value  Indiacators              Meaning
-- ============  =========  =====================    ==========================
-- 1) 01-Jan-00  (null)     asg_evt_ind not null     Asg started with no ABV
-- 2) 01-Feb-00  (null)     asg_evt_ind not null     Asg change with no ABV
-- 3) 01-Mar-00  1          fte_record_ind set to 1  ABV value started 01-Mar-00
-- 4) 01-Apr-00  (null)     asg_evt_ind not null     Asg change with ABV
-- 5) 01-May-00  (null)     fte_record_ind set to 1  ABV value ended 30-Apr-00
-- 6) 01-Jun-00  (null)     asg_evt_ind not null     Asg change with no ABV
-- 7) 01-Jul-00  2          fte_record_ind set to 1  ABV value started 01-Jul-00
-- 8) 01-Aug-00  3          fte_record_ind set to 1  ABV value updated 01-Aug-00
-- 9) 01-Sep-00  (null)     Not required             Asg terminated 31-Aug-2000
--
-- The Fast Formula for the ABV should be run to calculate the ABV whenever
-- there is no ABV value in the table. In the above example, this should be
-- done:
--
-- 1) Yes - assignment started with no ABV because source is still Assignment
-- 2) Yes - assignment changed with no ABV because source is still Assignment
-- 4) No  - ABV value from 3) is still active
-- 5) Yes - ABV value from 3) ends here and needs recalculating on 01-May-00
-- 6) Yes - still no ABV value
-- 9) No  - ABV value will be unchanged on termination
--
-- So the fast formula will be called 4 times in the above example. Each time
-- it is called there is no ABV value so the "run_formula" flag is set to 'Y'
-- so that the calc_abv formula does not recheck the table. The primary flag
-- value is also passed in to allow the TEMPLATE_HEAD bypass performance
-- enhancement.
--
-- -----------------------------------------------------------------------------
--
  --
  -- Local variable Initialization
  --
  l_date_index       := p_date_master_tab.FIRST;
  l_fte_active       := TO_NUMBER(NULL);
  l_headcount_active := TO_NUMBER(NULL);
  l_primary_flag     := NULL;
  --
  -- Start looping through master PL/SQL table in date order
  --
  WHILE (l_date_index IS NOT NULL) LOOP
    --
    -- Keep track of primary flag value every time it changes
    -- This is used in calling calc_abv to bypass TEMPLATE_HEAD
    --
    IF (p_date_master_tab(l_date_index).primary_flag IS NOT NULL) THEN
      --
      l_primary_flag := p_date_master_tab(l_date_index).primary_flag;
      --
    END IF;
  --
  --  --------------------------------------------------------------------------
  --  Start calculating FTE values
  --
  --  Need to calculate an FTE value using fast formula if
  --  active FTE record ends or assignment changes whilst
  --  there is no active FTE record
  --
    -- If the record is the termination record then force an
    -- ABV value of 0
    --
    IF (l_date_index = (p_asg_dates.end_date_active - g_refresh_start_date) + 1) THEN
      --
      p_date_master_tab(l_date_index).fte := 0;
      --
    --
    -- If there is an assignment event on this date and there exists no fte
    -- record on this date
    --
    ELSIF (((l_fte_active IS NULL AND
             p_date_master_tab(l_date_index).asg_evt_ind IS NOT NULL AND
             p_date_master_tab(l_date_index).fte_record_ind IS NULL)
             --
             --  Or the FTE value is ended
             --
             OR
             (p_date_master_tab(l_date_index).fte IS NULL AND
              p_date_master_tab(l_date_index).fte_record_ind IS NOT NULL))
           --
           -- And FTE collection is required
           --
           AND (g_collect_fte = 'Y')) THEN
      --
      -- No active FTE value
      --
      l_fte_active := to_number(null);
      --
      -- Calculate the FTE value through Fast Formula
      --
      p_date_master_tab(l_date_index).fte  := hri_bpl_abv.calc_abv(
         p_assignment_id => g_assignment_id
        ,p_business_group_id => p_business_group_id
        ,p_budget_type => 'FTE'
        ,p_effective_date => (g_refresh_start_date + l_date_index)
        ,p_primary_flag => l_primary_flag
        ,p_run_formula => 'Y');
    --
    -- Otherwise there is a new active FTE value
    --
    ELSIF (p_date_master_tab(l_date_index).fte IS NOT NULL) THEN
      --
      -- Store the new active FTE value
      --
      l_fte_active := p_date_master_tab(l_date_index).fte;
      --
    END IF;
    --
    -- End calculating FTE values
    -- -------------------------------------------------------------------------
    --
    -- -------------------------------------------------------------------------
    -- Start calculating headcounts values
    --
    -- Need to calculate an HEAD value using fast formula if
    -- active HEAD record ends or assignment changes whilst
    -- there is no active HEAD record
    --
    -- If the record is the termination record then force an
    -- ABV value of 0
    --
    IF (l_date_index = (p_asg_dates.end_date_active - g_refresh_start_date) + 1) THEN
      --
      p_date_master_tab(l_date_index).headcount := 0;
      --
    --
    -- If there is an assignment event on this date and there exists no headcount
    -- record on this date
    --
    ELSIF ( ( (l_headcount_active IS NULL AND
               p_date_master_tab(l_date_index).asg_evt_ind IS NOT NULL AND
               p_date_master_tab(l_date_index).hdc_record_ind IS NULL
               )
              --
              --  Or the headcount value is ended
              --
              OR
              (p_date_master_tab(l_date_index).headcount IS NULL AND
               p_date_master_tab(l_date_index).hdc_record_ind IS NOT NULL
               )
             )
           --
           -- And collection of headcount value is required
           --
           AND
            (g_collect_hdc = 'Y')
      ) THEN
      --
      -- No active HEAD value
      --
      l_headcount_active := to_number(null);
      --
      -- Calculate the headcount value through the formula
      --
      p_date_master_tab(l_date_index).headcount  := hri_bpl_abv.calc_abv(
        p_assignment_id => g_assignment_id
        ,p_business_group_id => p_business_group_id
        ,p_budget_type => 'HEAD'
        ,p_effective_date => (g_refresh_start_date + l_date_index)
        ,p_primary_flag => l_primary_flag
        ,p_run_formula => 'Y');
    --
    -- Otherwise there is a new active HEAD value
    --
    ELSIF (p_date_master_tab(l_date_index).headcount IS NOT NULL) THEN
      --
      -- Store the new active HEAD value
      --
      l_headcount_active := p_date_master_tab(l_date_index).headcount;
      --
    END IF;
    --
    -- End calculating headcount values
    -- -------------------------------------------------------------------------
    --
    -- Increment the date index
    --
    l_date_index := p_date_master_tab.NEXT(l_date_index);
    --
  END LOOP;
  --
  -- End looping through master PL/SQL table in date order
  --
  dbg('Exiting fill_gaps_in_abv_history');
  --
--
END fill_gaps_in_abv_history;
--
-- -----------------------------------------------------------------------------
-- 5E Identify Salary Changes
--    Creates a list of salary changes, and inserts a record in the combined
--    event list PLSQL table for each change
-- -----------------------------------------------------------------------------
--
PROCEDURE identify_salary_changes(
  p_asg_dates         IN g_asg_date_type,
  p_date_master_tab   IN OUT NOCOPY g_master_tab_type,
  p_sal_change_tab    OUT NOCOPY g_sal_change_tab_type) IS
  --
  -- Cursor for salary changes
  --
  CURSOR sal_csr IS
  SELECT
   CASE WHEN ppb.pay_annualization_factor IS NULL
        AND  ppb.pay_basis = 'PERIOD' THEN
          --
          -- When the salary basis is PERIOD, the annualization can be
          -- null in such a case the the annualization factor is
          -- equal to the payroll frequency or the numer of paroll in a
          -- year. The function returns the payroll frequency
          --
          pro.proposed_salary_n *
          hri_bpl_sal.get_perd_annualization_factor
            (asg.assignment_id, pro.change_date)
        ELSE
          pro.proposed_salary_n * ppb.pay_annualization_factor
   END  salary
  --
  -- Time
  --
  ,pro.change_date                           change_date
  --
  -- Dimensions
  --
  ,NVL(pro.pay_proposal_id,-1)               pay_proposal_id
  ,NVL(pet.input_currency_code, 'NA_EDW')    currency_code
  FROM
   per_all_assignments_f    asg
  ,per_pay_bases            ppb
  ,per_pay_proposals        pro
  ,pay_input_values_f       piv
  ,pay_element_types_f      pet
  WHERE pro.approved = 'Y'
  AND asg.assignment_id = g_assignment_id
  AND asg.assignment_id = pro.assignment_id
  AND asg.pay_basis_id = ppb.pay_basis_id
  AND ppb.input_value_id = piv.input_value_id
  AND piv.element_type_id = pet.element_type_id
  AND pro.change_date BETWEEN piv.effective_start_date AND piv.effective_end_date
  AND pro.change_date BETWEEN pet.effective_start_date AND pet.effective_end_date
  AND pro.change_date BETWEEN asg.effective_start_date AND asg.effective_end_date
  --
  -- Only Salary changes before assignment end
  --
  AND pro.change_date <= p_asg_dates.end_date_active
  ORDER BY pro.change_date;
  --
  -- Local Package Variables - reset every time procedure is called
  --
  -- Tables for bulk fetch
  -- Note in 9i bulk fetch directly into table of records is supported
  --
  l_sal_effective_start_date     g_date_tab_type;
  l_sal_effective_end_date       g_date_tab_type;
  l_sal_anl_slry                 g_number_tab_type;
  l_sal_pay_proposal_id          g_number_tab_type;
  l_sal_anl_slry_currency        g_varchar2_tab_type;
  --
  -- Variable to collect the total number of record fetched by the salary cursor
  --
  l_sal_no_records               PLS_INTEGER;
  --
  -- Index variables
  --
  l_sal_index                    PLS_INTEGER;
  l_date_index                   PLS_INTEGER;
  --
  -- Indicator variable which determines if a salary event has occured on the
  -- relevant date
  --
  l_sal_evt_ind                  PLS_INTEGER := 1;
  --
--
BEGIN
--
  dbg('Inside identify_salary_changes');
  --
  -- Load up the salary records for the assignment
  -- Bulk load cursor into PLSQL table
  --
  dbg('Opening the salary cursor');
  OPEN sal_csr;
  FETCH sal_csr
  BULK COLLECT INTO
     l_sal_anl_slry
    ,l_sal_effective_start_date
    ,l_sal_pay_proposal_id
    ,l_sal_anl_slry_currency;
  --
  l_sal_no_records := sal_csr%ROWCOUNT;
  --
  CLOSE sal_csr;
  --
  IF (l_sal_no_records > 0) THEN
    --
    -- Set the effective end date of the salary record to that of end of time
    -- for the last record
    --
    p_sal_change_tab(l_sal_no_records).effective_end_date := g_end_of_time;
    --
    l_sal_index := 1;
    --
    FOR i IN 1..l_sal_no_records LOOP
      --
      -- Transfer data to output table of records
      --
      p_sal_change_tab(i).anl_slry := l_sal_anl_slry(i);
      p_sal_change_tab(i).effective_start_date := l_sal_effective_start_date(i);
      p_sal_change_tab(i).pay_proposal_id := l_sal_pay_proposal_id(i);
      p_sal_change_tab(i).anl_slry_currency := l_sal_anl_slry_currency(i);
      --
      -- Set the effective end date for salary records
      --
      IF i < l_sal_no_records THEN
        --
        p_sal_change_tab(i).effective_end_date := l_sal_effective_start_date(i+1) - 1;
        --
      END IF;
      --
      -- The salary cursor will get all salary records for the person,
      -- we are only interested in ones that are valid on/after the refresh_date
      --
      IF p_sal_change_tab(i).effective_end_date < p_asg_dates.start_date_active THEN
        --
        -- The record starts before the start_date_active
        --
        l_sal_index := i + 1;
        --
      ELSE
        IF (l_sal_index = i) THEN
          --
          -- This should happen only for the first record after the dbi collection
          -- date
          --
          IF (p_sal_change_tab(l_sal_index).effective_start_date <
                         p_asg_dates.start_date_active) THEN
            --
            p_sal_change_tab(l_sal_index).effective_start_date :=
                         p_asg_dates.start_date_active;
            --
            -- If the first record starts on the day of the assignment start date then
            -- set the indicator for salary
            --
            l_sal_evt_ind := 0;
            --
          ELSIF (p_sal_change_tab(l_sal_index).effective_start_date =
                         g_dbi_collection_start_date) THEN
            --
            -- salary change was done on dbi collection date, so unset the retrospective
            -- indicator
            --
            p_date_master_tab(p_sal_change_tab(l_sal_index).effective_start_date -
                              g_refresh_start_date).rtrspctv_strt_ind := 0;
            --
          END IF;
          --
        END IF;
        --
        -- Calculate date index value as the difference between the effective
        -- start date and refresh start date. Being the difference between two
        -- dates, this will be an integer
        --
        l_date_index := p_sal_change_tab(i).effective_start_date - g_refresh_start_date;
        --
        -- Assign the salary index in date-indexed PLSQL table
        --
        p_date_master_tab(l_date_index).sal_index := i;
        --
        -- Set the salary event indicator in the master table based on the
        -- value of the indicator varable l_sal_evt_ind
        --
        p_date_master_tab(l_date_index).sal_evt_ind := l_sal_evt_ind;
        --
        -- After first record this indicator will be 1
        --
        l_sal_evt_ind := 1;
        --
      END IF;
      --
    END LOOP;
    --
    -- End of the loop for transposing salary records to master date-indexed
    -- PLSQL table
    -- -----------------------------------------------------------------------
    --
  END IF;
  --
  dbg('Exiting identify_salary_changes');
  --
--
-- When an exception is raised, the cursor is closed and the exception is passed
-- out of this block and it is handled in the collect procedure where an entry
-- of this is made in the concurrent log
--
EXCEPTION
--
  WHEN OTHERS THEN
    --
    dbg('Error encountered in identify_salary_changes');
    dbg(SQLERRM);
    --
    IF sal_csr%ISOPEN THEN
      --
      CLOSE sal_csr;
      --
    END IF;
    --
    -- Bug 4105868: Collection Diagnostic Call
    --
    g_msg_sub_group := NVL(g_msg_sub_group, 'IDENTIFY_SALARY_CHANGES');
    --
    RAISE;
    --
--
END identify_salary_changes;
--
-- -----------------------------------------------------------------------------
-- 5F Identify Performance Rating Changes
--    Creates a list of performance rating changes, and inserts a record in the
--    combined event list PLSQL table for each change
-- ----------------------------------------------------------------------------
--
PROCEDURE identify_perf_rating_changes(
  p_asg_dates          IN g_asg_date_type,
  p_person_id          IN NUMBER,
  p_business_group_id  IN NUMBER,
  p_date_master_tab    IN OUT NOCOPY g_master_tab_type,
  p_perf_change_tab    OUT NOCOPY g_perf_change_tab_type)
IS
  --
  -- Local Package Variables - reset every time procedure is called
  --
  -- Tables for cursor fetch
  --
  l_perf_effective_start_date    g_date_tab_type;
  l_perf_effective_end_date      g_date_tab_type;
  l_last_update_date             g_date_tab_type;
  l_perf_nrmlsd_rating           g_number_tab_type;
  l_perf_band                    g_number_tab_type;
  l_perf_review_id               g_number_tab_type;
  l_perf_review_type_cd          g_varchar2_tab_type;
  l_perf_rating_cd               g_varchar2_tab_type;
  --
  -- Variable to store ranks for reviews done on the same date
  --
  l_same_day_rank                g_number_tab_type;
  --
  -- Variable to collect the total number of record fetched by the rating cursor
  --
  l_perf_no_records              PLS_INTEGER;
  --
  -- Index variables
  --
  l_rating_index                 PLS_INTEGER;
  l_date_index                   PLS_INTEGER;
  l_dummy                        PLS_INTEGER;
  --
  -- Indicator variable which determines if a rating event has occured on the
  -- relevant date
  --
  l_perf_evt_ind                 PLS_INTEGER := 1;
  --
  -- PLSQL table to store the appraisal template name
  --
  l_app_temp_name                g_varchar2_240_tab_type;
  l_normalized_rating            NUMBER;
  l_appraisal_ff_id              NUMBER;
  --
  -- Reference Cursor type to be used to fetch the performance sql
  --
  TYPE ref_cursor_type   IS REF CURSOR;
  --
  -- Reference cursor to be used to fetch performance records
  --
  perf_csr                      ref_cursor_type;
  --
--
BEGIN
--
  dbg('Inside identify_perf_rating_changes');
  --
  -- Do not collected performance rating information in case g_collect_perf_rating
  -- is set to N.
  --
  IF g_collect_perf_rating = 'N' THEN
    --
    RETURN;
    --
  END IF;
  --
  -- Load up the performance rating records for the assignment
  --
  -- Bulk load cursor into PLSQL table
  --
  dbg('p_asg_dates.end_date_active ='||p_asg_dates.end_date_active);
  dbg('Opening the performance cursor');
  --
  OPEN  perf_csr
  FOR   g_perf_query
  USING p_business_group_id,
        p_person_id,
        p_business_group_id,         -- perf select
        p_person_id,                 -- perf where
        p_asg_dates.end_date_active, -- perf where
        p_asg_dates.hire_date,       -- perf where
        p_business_group_id,         -- app select
        p_person_id,                 -- app where
        p_asg_dates.end_date_active, -- app where
        p_asg_dates.hire_date,       -- app where
        g_assignment_id;
  --
  FETCH perf_csr
  BULK  COLLECT INTO
         l_perf_rating_cd
        ,l_perf_effective_start_date
        ,l_last_update_date
        ,l_perf_effective_end_date
        ,l_perf_review_id
        ,l_perf_review_type_cd
        ,l_app_temp_name
        ,l_perf_nrmlsd_rating
        ,l_perf_band
        ,l_same_day_rank;
  --
  -- Store the total number of records fetched by the cursor
  --
  l_perf_no_records := perf_csr%ROWCOUNT;
  --
  CLOSE perf_csr;
  --
  dbg('Number of records fetched(l_perf_no_records) ='||l_perf_no_records);
  --
  IF (l_perf_no_records > 0) THEN
    --
    l_rating_index := 1;
    --
    FOR i IN 1..l_perf_no_records LOOP
      --
      -- 4259647, 4300665 In case there are multiple appraisals on the same date, the
      -- last updated record should be used for collection. A warning should
      -- be displayed in this case, so that users are aware of the issue
      -- The query ranks the records based on the last update date of the record
      -- In case the rank for the record is > 1 then display a warning
      --
      IF l_same_day_rank(i) = 1 THEN
        --
        -- Transfer the data to the output table of records
        --
        p_perf_change_tab(i).rating_cd := l_perf_rating_cd(i);
        p_perf_change_tab(i).effective_start_date := l_perf_effective_start_date(i);
        p_perf_change_tab(i).effective_end_date := l_perf_effective_end_date(i);
        p_perf_change_tab(i).review_id := l_perf_review_id(i);
        p_perf_change_tab(i).review_type_cd := l_perf_review_type_cd(i);
        p_perf_change_tab(i).nrmlsd_rating := l_perf_nrmlsd_rating(i);
        p_perf_change_tab(i).band := l_perf_band(i);
        --
        -- The rating cursor will get all performance rating records for the person,
        -- we are only interested in ones that are valid on/after the refresh_date
        --
        IF p_perf_change_tab(i).effective_end_date < p_asg_dates.start_date_active THEN
          --
          -- The record starts before the start_date_active
          --
          l_rating_index := i + 1;
          --
          dbg('review date before the event date, skipping collection');
          --
        ELSE
          --
          dbg('writing review detials in the arrays');
          --
          IF (l_rating_index = i) THEN
            --
            -- This should happen only for the first record after the dbi collection
            -- date
            --
            IF (p_perf_change_tab(l_rating_index).effective_start_date <
                             p_asg_dates.start_date_active)
            THEN
              --
              p_perf_change_tab(l_rating_index).effective_start_date :=
                           p_asg_dates.start_date_active;
              --
              -- If the first record starts on the day of the assignment start date then
              -- set the indicator for performance
              --
              l_perf_evt_ind := 0;
              --
            END IF;
            --
          END IF;
          --
          dbg('Normalized performance rating '||p_perf_change_tab(i).nrmlsd_rating);
          --
          -- Calculate date index value as the difference between the effective
          -- start date and refresh start date. Being the difference between two
          -- dates, this will be an integer
          --
          l_date_index := p_perf_change_tab(i).effective_start_date - g_refresh_start_date;
          --
          -- Assign the perf index in date-indexed PLSQL table
          --
          p_date_master_tab(l_date_index).perf_index := i;
          --
          -- Set the perf event indicator in the master table based on the
          -- value of the indicator varable l_perf_evt_ind
          --
          p_date_master_tab(l_date_index).perf_evt_ind := l_perf_evt_ind;
          --
          -- After first record this indicator will be 1
          --
          l_perf_evt_ind := 1;
          --
        END IF;
        --
      ELSIF l_perf_effective_end_date(i) >= p_asg_dates.start_date_active AND
            l_same_day_rank(i) > 1
      THEN
        --
        -- The rank of the record is not one, so there are multiple appraisals existing
        -- for the person on the same date
        --
        output('WARNING! Multiple performance ratings exists for the person on the '||
	       'same date. The rating given for the last updated record will '||
	       'be considered for collection.');
        --
      END IF;
      --
    END LOOP;
    --
    -- End of the loop for transposing performance records to master date-indexed
    -- PLSQL table
    -- -----------------------------------------------------------------------
    --
  END IF;
  --
  dbg('Exiting identify_perf_rating_changes');
  --
--
-- When an exception is raised, the cursor is closed and the exception is passed
-- out of this block and it is handled in the collect procedure where an entry
-- of this is made in the concurrent log
--
EXCEPTION
  --
  WHEN OTHERS THEN
     --
     IF perf_csr%ISOPEN THEN
       --
       CLOSE perf_csr;
       --
     END IF;
     --
     dbg('Exception raised in identify_perf_rating_changes');
     dbg(sqlerrm);
     --
     -- Bug 4105868: Collection Diagnostic Call
     --
     g_msg_sub_group := NVL(g_msg_sub_group, 'IDENTIFY_PERF_RATING_CHANGES');
     --
     RAISE;
  --
END identify_perf_rating_changes;
--
-- ----------------------------------------------------------------------------
-- 5G Identify POW Band Changes
--    Inserts a record in the combined event list array for each POW Band change
--    The procedure also implements the logic for period of extension
-- ----------------------------------------------------------------------------
--
PROCEDURE identify_pow_band_changes(
  p_asg_dates              IN g_asg_date_type,
  p_person_id              IN NUMBER,
  p_date_master_tab        IN OUT NOCOPY g_master_tab_type,
  p_assignment_type        IN VARCHAR2)
IS
  --
  l_total_bands                          NUMBER := 5;
  l_pow_band_start_date                  DATE;
  l_pow_band_end_date                    DATE;
  l_prjctd_end_dt                        DATE;
  l_pow_extn_strt_dt                     DATE;
  l_date_index                           NUMBER;
  l_pow_band_high_val                    NUMBER;
  l_pow_band_sk_fk                       NUMBER;
  --
  CURSOR c_prjctd_end_dt IS
  SELECT min(asg.projected_assignment_end)
  FROM   per_all_assignments_f asg
  WHERE  asg.person_id = p_person_id
  AND    asg.primary_flag = 'Y'
  --
  -- 4469175 incase if rehire of placement, the extension date should be
  -- derived from asg records in the same term. placement start date
  -- is the fk to placement table
  --
  AND    asg.period_of_placement_date_start = p_asg_dates.hire_date;
  --
BEGIN
  --
  dbg('Inside identify_pow_band_changes ');
  --
  -- Generate POW band change events in the date master tab array
  --
  -- Loop through the 5 POW bands and capture the band change date event dates
  -- in the master array till the ealrier of sysdate or the termination date of the person
  --
  dbg('p_asg_dates.start_date_active ='||p_asg_dates.start_date_active);
  dbg('p_asg_dates.termination_date  ='||p_asg_dates.termination_date);
  dbg('p_asg_dates.pow_start_date_adj='||p_asg_dates.pow_start_date_adj);
  --
  -- Projected End Date
  --
  IF g_cwk_asg THEN
    --
    OPEN  c_prjctd_end_dt;
    FETCH c_prjctd_end_dt into l_prjctd_end_dt;
    CLOSE c_prjctd_end_dt;
    --
    g_cwk_asg := FALSE;
    --
  END IF;
  --
  FOR l_loop_count in 1 .. l_total_bands LOOP
    --
    -- Determine the start date of the band
    --
    -- The start date of the first band is set to hire date
    --
    IF l_pow_band_start_date is null THEN
      --
      l_pow_band_start_date := p_asg_dates.pow_start_date_adj;
      --
    --
    -- The start date of subsequent band is set ot the end date+1 of thr previous band
    --
    ELSE
      --
      l_pow_band_start_date := l_pow_band_end_date + 1;
      --
    END IF;
    --
    -- Get end range of the band
    --
    BEGIN
      l_pow_band_high_val := hri_bpl_period_of_work.get_pow_band_high_val
                              (p_band_number       => l_loop_count,
                               p_assignment_type   => p_assignment_type);
    EXCEPTION
      WHEN OTHERS THEN
        g_msg_sub_group := NVL(g_msg_sub_group, 'GET_POW_BAND_HIGH_VAL');
        RAISE;
    END;
    --
    dbg('l_pow_band_high_val:'||l_pow_band_high_val);
    --
    -- Find the end date of the band
    --
    l_pow_band_end_date := add_months(p_asg_dates.pow_start_date_adj,l_pow_band_high_val)-1;
    --
    dbg('pow_start_dt='||to_char(l_pow_band_start_date,'DD-MON-RRRR') || ' '||
        'pow_end='||to_char(l_pow_band_end_date,'DD-MON-RRRR'));
    --
    -- Do not create any events if the end date is null or end of time
    --
    IF p_asg_dates.start_date_active <= nvl(l_pow_band_end_date,hr_general.end_of_time) AND
       l_pow_band_start_date <= nvl(p_asg_dates.termination_date,hr_general.end_of_time)
    THEN
      --
      l_date_index := greatest(l_pow_band_start_date,p_asg_dates.start_date_active) - g_refresh_start_date;
      --
      -- The master date always starts with index 1. Incase the date_index is 0 then
      -- array should be initialized from 1 and not 0
      --
      IF l_date_index = 0 THEN
        --
        l_date_index  := p_date_master_tab.first;
        --
      END IF;
      --
      -- Determine the low band
      --
      l_pow_band_sk_fk := hri_bpl_period_of_work.get_pow_band_sk_fk
                              (p_band_number       => l_loop_count
			      ,p_assignment_type   => p_assignment_type);
      --
      dbg('inserting pow band info in master index at index '||l_date_index);
      --
      -- Set the pow band change event indicator in the master table based on the
      -- value of the indicator varable l_perf_evt_ind
      --
      p_date_master_tab(l_date_index).pow_evt_ind       := 1;
      p_date_master_tab(l_date_index).pow_band_sk_fk    := l_pow_band_sk_fk;
      p_date_master_tab(l_date_index).pow_extn_strt_dt  := l_pow_extn_strt_dt;
      --
      dbg('asg value at the index val='||p_date_master_tab(l_date_index).asg_index);
    --
    END IF;
    --
    -- PERIOD OF EXTENSION START DATE
    --
    -- A record should be created on the extension start date. The condition will only
    -- be true once, at which point a new record is created and the variable
    -- l_pow_extn_strt_dt is also populated. All subsequent records will be populated
    -- by referencing the l_pow_extn_strt_dt variable
    --
    IF l_prjctd_end_dt < g_refresh_start_date THEN
      --
      l_pow_extn_strt_dt := l_prjctd_end_dt + 1;
      p_date_master_tab(nvl(l_date_index,0)).pow_extn_strt_dt  := l_pow_extn_strt_dt;
      --
    ELSIF l_prjctd_end_dt + 1 BETWEEN l_pow_band_start_date AND
                                      nvl(l_pow_band_end_date,hr_general.end_of_time)
    THEN
      --
      l_pow_extn_strt_dt := l_prjctd_end_dt + 1;
      --
      dbg('inside pow extn='||l_pow_extn_strt_dt);
      --
      l_date_index := l_pow_extn_strt_dt - g_refresh_start_date;
      p_date_master_tab(l_date_index).pow_evt_ind      := 1;
      p_date_master_tab(l_date_index).pow_band_sk_fk   := l_pow_band_sk_fk;
      p_date_master_tab(l_date_index).pow_extn_strt_dt := l_pow_extn_strt_dt;
      --
    ELSE
      --
      dbg('extn start='||l_prjctd_end_dt||' pow band start='||l_pow_band_start_date ||' end = '|| l_pow_band_end_date);
      --
    END IF;
    --
    -- Exit when the band end date is greater than the termination date or sysdate
    --
    IF l_pow_band_end_date is null OR
       l_pow_band_end_date > p_asg_dates.termination_date  OR
       l_pow_band_end_date + 1 > SYSDATE
    THEN
      --
      EXIT;
      --
    END IF;
    --
  END LOOP;
  --
  dbg('Exiting identify_pow_band_changes ');
  --
END identify_pow_band_changes;
--
-- ----------------------------------------------------------------------------
-- Set Previous Values
-- This procedure finds the previous values of columns such as grade, abv,
-- salary etc. on a day before the incremental changes are being made to the
-- assignment events
-- ----------------------------------------------------------------------------
--
PROCEDURE set_previous_values(p_prv_rec IN OUT NOCOPY g_prv_record
                              ,p_business_group_id IN NUMBER
                              ,p_date_master_tab IN g_master_tab_type
                              ,p_hire_date DATE)  IS
  --
  -- Cursor to hold the values existing one day before the refresh start date
  --
  CURSOR prv_val_csr IS
  SELECT
  grade_id
  ,job_id
  ,location_id
  ,organization_id
  ,supervisor_id
  ,position_id
  ,primary_flag
  ,fte
  ,headcount
  ,anl_slry
  ,anl_slry_currency
  --
  -- Performance Values
  --
  ,perf_nrmlsd_rating
  ,perf_band
  ,to_date(null)
  ,to_date(null)
  --
  -- Period of Work Value
  --
  ,pow_band_sk_fk
  ,summarization_rqd_ind
  ,ROWID
  FROM HRI_MB_ASGN_EVENTS_CT
  WHERE assignment_id = g_assignment_id
  AND   (g_refresh_start_date - 1) BETWEEN effective_change_date AND effective_change_end_date;
  --
  l_effective_start_date DATE;
  l_date_index NUMBER;
  --
--
BEGIN
  --
  dbg('Entering set_previous_values');
  --
  -- Set up a default record for previous assignment for values before the
  -- refresh start date
  --
  p_prv_rec.organization_prv_id := -1;
  p_prv_rec.location_prv_id := -1;
  p_prv_rec.job_prv_id := -1;
  p_prv_rec.grade_prv_id :=  -1;
  p_prv_rec.position_prv_id := -1;
  p_prv_rec.supervisor_prv_id := -1;
  p_prv_rec.primary_flag_prv := 'NA_EDW';
  --
  -- Set up a default no-salary record for values before the refresh start date
  --
  p_prv_rec.anl_slry_prv := TO_NUMBER(NULL);
  p_prv_rec.anl_slry_currency_prv := 'NA_EDW';
  --
  -- Set up a default no-performance record for values before the refresh start date
  --
  p_prv_rec.perf_nrmlsd_rating_prv := TO_NUMBER(NULL);
  p_prv_rec.perf_band_prv          := TO_NUMBER(NULL);
  --
  -- Set up a default no-period of work record for values before the refresh start date
  --
  p_prv_rec.pow_band_sk_fk_prv     := TO_NUMBER(NULL);
  --
  -- Set up a default ABV record for values before the refresh start date
  --
  p_prv_rec.fte_prv := 0;
  p_prv_rec.headcount_prv := 0;
  --
  l_date_index := p_date_master_tab.FIRST;
  l_effective_start_date := g_refresh_start_date + l_date_index;
  --
  -- Calculate the value of FTE before the DBI collection start date in cases where there
  -- is a FTE change event on DBI collection start date
  --
  IF g_collect_fte = 'Y'  AND
     l_effective_start_date = g_dbi_collection_start_date
  THEN
    --
    IF (l_effective_start_date > p_hire_date) THEN
      --
      IF (p_date_master_tab(l_date_index).fte_record_ind = 1) THEN
        --
        -- FTE Changed on DBI Collection date, recalculate the pervious value
        --
        p_prv_rec.fte_prv := hri_bpl_abv.calc_abv(
             p_assignment_id      => g_assignment_id
             ,p_business_group_id => p_business_group_id
             ,p_budget_type       => 'FTE'
             ,p_effective_date    => g_dbi_collection_start_date - 1
             ,p_primary_flag      => null
             ,p_run_formula       => null);
        --
      ELSE
        --
        -- The FTE Change was made before DBI Collection date, set the
        -- previous value as the current value
        --
        p_prv_rec.fte_prv := p_date_master_tab(l_date_index).fte;
        --
      END IF;
      --
    ELSIF (l_effective_start_date = p_hire_date) THEN
      --
      -- On hire date the prv value should be set to 0
      --
      p_prv_rec.fte_prv := 0;
      --
    END IF;
    --
  END IF;
  --
  -- Calculate the value of Headcount before the DBI collection start date on cases where
  -- there is a Headcount change event on DBI collection start date
  --
  IF g_collect_hdc = 'Y' AND
     l_effective_start_date = g_dbi_collection_start_date
  THEN
    --
    IF (l_effective_start_date > p_hire_date) THEN
      --
      IF (p_date_master_tab(l_date_index).hdc_record_ind = 1) THEN
        --
        -- HDC Changed on DBI Collection date, recalculate the pervious value
        --
        p_prv_rec.headcount_prv := hri_bpl_abv.calc_abv(
            p_assignment_id      => g_assignment_id
            ,p_business_group_id => p_business_group_id
            ,p_budget_type       => 'HEAD'
            ,p_effective_date    => g_dbi_collection_start_date - 1
            ,p_primary_flag      => null
            ,p_run_formula       => null);
      ELSE
        --
        -- The HDC Change was made before DBI Collection date, set the
        -- previous value as the current value
        --
        p_prv_rec.headcount_prv := p_date_master_tab(l_date_index).headcount;
        --
      END IF;
      --
    ELSIF (l_effective_start_date = p_hire_date) THEN
      --
      -- On hire date the prv value should be set to 0
      --
      p_prv_rec.headcount_prv := 0;
      --
    END IF;
    --
  END IF;
  --
  -- If incremental refresh
  --
  IF g_full_refresh = 'N' THEN
    --
    -- Open the cursor and fetch the value of the columns into the record variable
    --
    OPEN  prv_val_csr;
    FETCH prv_val_csr INTO p_prv_rec;
    CLOSE prv_val_csr;
    --
  END IF;
  --
  dbg('Exiting set_previous_values');
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    -- If the cursot is open then close it
    --
    IF prv_val_csr%ISOPEN THEN
      --
      CLOSE prv_val_csr;
      --
    END IF;
    --
    dbg('Error encountered in set_previous_values');
    dbg(SQLERRM);
    --
    -- Bug 4105868: Collection Diagnostic Call
    --
    g_msg_sub_group := NVL(g_msg_sub_group, 'SET_PREVIOUS_VALUES');
    --
    RAISE;
    --
--
END set_previous_values;
--
-- -----------------------------------------------------------------------------
-- This procedure sets the value for various indicators based on the the values
-- various arrays passed. It returns an array p_indicator_rec which contains
-- the value of various indicators on every event date
-- -----------------------------------------------------------------------------
--
PROCEDURE set_indicators(
  p_asg_dates               IN    g_asg_date_type,
  p_asg_change_tab          IN    g_asg_change_tab_type,
  p_sal_change_tab          IN    g_sal_change_tab_type,
  p_perf_change_tab         IN    g_perf_change_tab_type,
  p_date_master_tab         IN    g_master_tab_type,
  p_index_rec               IN    g_index_record,
  p_placeholder_rec         IN    g_placeholder_rec,
  p_indicator_rec           OUT NOCOPY g_indicator_record,
  p_effective_start_date    IN DATE,
  p_effective_end_date      IN DATE)
IS
--
  --
  l_ret_val                      BOOLEAN;
  --
--
BEGIN
--
  dbg('Entering set_indicators');
  --
  -- ---------------------------------------------------------------------------
  -- Start of initializing of indicators
  --
  p_indicator_rec.asg_rtrspctv_strt_event_ind      := 0;
  p_indicator_rec.assignment_change_ind            := 0;
  p_indicator_rec.salary_change_ind                := 0;
  --
  -- Setting the performance rating indicators
  --
  p_indicator_rec.perf_change_ind                  := 0;
  p_indicator_rec.perf_band_change_ind             := 0;
  --
  -- Setting the Period of Work band inidcators
  --
  p_indicator_rec.pow_band_change_ind              := 0;
  --
  p_indicator_rec.headcount_gain_ind               := 0;
  p_indicator_rec.headcount_loss_ind               := 0;
  p_indicator_rec.fte_gain_ind                     := 0;
  p_indicator_rec.fte_loss_ind                     := 0;
  p_indicator_rec.contingent_ind                   := 0;
  p_indicator_rec.employee_ind                     := 0;
  p_indicator_rec.grade_change_ind                 := 0;
  p_indicator_rec.job_change_ind                   := 0;
  p_indicator_rec.position_change_ind              := 0;
  p_indicator_rec.location_change_ind              := 0;
  p_indicator_rec.organization_change_ind          := 0;
  p_indicator_rec.supervisor_change_ind            := 0;
  p_indicator_rec.worker_hire_ind                  := 0;
  p_indicator_rec.post_hire_asgn_start_ind         := 0;
  p_indicator_rec.pre_sprtn_asgn_end_ind           := 0;
  p_indicator_rec.term_voluntary_ind               := 0;
  p_indicator_rec.term_involuntary_ind             := 0;
  p_indicator_rec.worker_term_ind                  := 0;
  p_indicator_rec.start_asg_sspnsn_ind             := 0;
  p_indicator_rec.end_asg_sspnsn_ind               := 0;
  p_indicator_rec.promotion_ind                    := 0;
  --
  -- Person Type Indicators
  --
  p_indicator_rec.summarization_rqd_ind            := 0;
  p_indicator_rec.summarization_rqd_chng_ind       := 0;
  p_indicator_rec.summarization_rqd_chng_nxt_ind   := 0;
  --
  -- If fte collection is not required then initialize the fte gain indicator
  -- and fte loss indicator variables to null
  --
  IF g_collect_fte = 'N' THEN
    --
    p_indicator_rec.fte_gain_ind                     := NULL;
    p_indicator_rec.fte_loss_ind                     := NULL;
    --
  END IF;
  --
  -- If headcount collection is not required then initialize the headcount gain
  -- indicator and headcount loss indicator variables to null
  --
  IF g_collect_hdc = 'N' THEN
    --
    p_indicator_rec.headcount_gain_ind               := NULL;
    p_indicator_rec.headcount_loss_ind               := NULL;
    --
  END IF;
  --
  -- End of initializing of indicators
  -- ---------------------------------------------------------------------------
  --
  -- Set the retrospective start event indicator. This is set to 1 if the
  -- assignment start date is before the DBI collection start date
  --
  IF ((
       p_date_master_tab(p_index_rec.date_index).rtrspctv_strt_ind = 1
       )
     AND
      (p_effective_start_date = g_dbi_collection_start_date
       )
      ) THEN
    --
    p_indicator_rec.asg_rtrspctv_strt_event_ind := 1;
    --
  END IF;
  --
  -- Set the contingent indicator to 1 if the assignment type is 'C'
  -- Set the employee indicator to 1 if the assignment type is 'E'
  --
  IF (p_asg_change_tab(p_index_rec.asg_index).type = 'C') THEN
    --
    p_indicator_rec.contingent_ind := 1;
    --
  ELSIF (p_asg_change_tab(p_index_rec.asg_index).type = 'E') THEN
    --
    p_indicator_rec.employee_ind  := 1;
    --
  END IF;
  --
  -- Set the worker hire indicator to 1 when the effective start date of the
  -- assignment record is the same as hire date
  --
  IF (p_effective_start_date = p_asg_dates.hire_date) THEN
    --
    p_indicator_rec.worker_hire_ind      := 1;
    --
  --
  -- Set the secondary assignment start indicator as 1 when the effective start
  -- date of the assignment record is same as the secondary assignment start date
  --
  ELSIF (p_effective_start_date = p_asg_dates.post_hire_asgn_start_date) THEN
    --
    p_indicator_rec.post_hire_asgn_start_ind := 1;
    --
  --
  -- Set the worker termination indicator as 1 when the effective start date of
  -- the assignment record is one day after the termination date
  --
  ELSIF (p_effective_start_date = p_asg_dates.termination_date + 1) THEN
    --
    p_indicator_rec.worker_term_ind      := 1;
    --
    -- Set the voluntary and involuntary temination indicators
    -- The termination is voluntary if the assignment type is not 'E'
    -- or if the employee separation category is 'SEP_VOL'
    --
    IF (p_asg_change_tab(p_index_rec.asg_index_prev).type <> 'E' OR
        hri_bpl_termination.get_separation_category
         (p_asg_change_tab(p_index_rec.asg_index).leaving_reason_code) = 'SEP_VOL')
    THEN
      --
      p_indicator_rec.term_voluntary_ind    := 1;
      --
    ELSE
      --
      p_indicator_rec.term_involuntary_ind  := 1;
      --
    END IF;
  --
  -- Set the secondary assignment end indicator to 1 when the effective start
  -- date of the assignment record is same as the next date of secondary
  -- assignment end date
  --
  ELSIF (p_effective_start_date = p_asg_dates.pre_sprtn_asgn_end_date + 1) THEN
    --
    p_indicator_rec.pre_sprtn_asgn_end_ind := 1;
    --
  --
  -- Set all other indicators only if the the effective start date of the
  -- assignment record is after the refresh start date or a change event
  -- has occured on the refresh start date
  --
  ELSIF ( (p_effective_start_date > g_refresh_start_date)
          OR
          (p_date_master_tab(p_index_rec.date_index).asg_evt_ind = 1)
          OR
          (p_date_master_tab(p_index_rec.date_index).sal_evt_ind = 1)
          OR
          (p_date_master_tab(p_index_rec.date_index).fte_record_ind = 1)
          OR
          (p_date_master_tab(p_index_rec.date_index).hdc_record_ind = 1)
          ) THEN
    --
    -- Set the assignment related indicators only if the the effective start date
    -- of the assignment record is after the refresh start date or an assignment
    -- related change has occured on the refresh date
    --
    IF  p_date_master_tab(p_index_rec.date_index).asg_evt_ind = 1 THEN
      --
      -- Set the assignment change indicator whenever an assignment change occurs
      -- ( Assignment event indicator set to 1)
      --
      p_indicator_rec.assignment_change_ind := 1;
      --
      IF ( p_asg_change_tab(p_index_rec.asg_index).status_code <>
           p_asg_change_tab(p_index_rec.asg_index_prev).status_code) THEN
        --
        -- Set the start assignment suspension indicator if the status code of
        -- the currect assignment record is active assignment and the status
        -- code of the previous assignment record is suspended assignment.
        --
        IF ((p_asg_change_tab(p_index_rec.asg_index).status_code = 'ACTIVE_ASSIGN' AND
             p_asg_change_tab(p_index_rec.asg_index_prev).status_code = 'SUSP_ASSIGN'
            )
           OR
            (p_asg_change_tab(p_index_rec.asg_index).status_code = 'ACTIVE_CWK' AND
             p_asg_change_tab(p_index_rec.asg_index_prev).status_code = 'SUSP_CWK_ASG'
            )
           ) THEN
          --
          p_indicator_rec.end_asg_sspnsn_ind := 1;
          --
        --
        -- Set the end assignment suspension indicator if the status code of
        -- the currect assignment record is suspended assignment and the status
        -- code of the previous assignment record is active assignment.
        --
        ELSIF ((p_asg_change_tab(p_index_rec.asg_index).status_code = 'SUSP_ASSIGN' AND
                p_asg_change_tab(p_index_rec.asg_index_prev).status_code = 'ACTIVE_ASSIGN'
               )
              OR
               (p_asg_change_tab(p_index_rec.asg_index).status_code = 'SUSP_CWK_ASG' AND
                p_asg_change_tab(p_index_rec.asg_index_prev).status_code = 'ACTIVE_CWK'
               )
              ) THEN
          --
          p_indicator_rec.start_asg_sspnsn_ind := 1;
          --
        END IF;
        --
      END IF;
      --
      -- Set the job change indicator to 1 if the job id of the current
      -- assignment record is not the same as the job id of the previous
      -- assignment record
      --
      IF ( p_asg_change_tab(p_index_rec.asg_index).job_id <>
           p_asg_change_tab(p_index_rec.asg_index_prev).job_id) THEN
        --
        p_indicator_rec.job_change_ind := 1;
        --
      END IF;
      --
      -- Set the location change indicator to 1 if the location id of the current
      -- assignment record is not the same as the location id of the previous
      -- assignment record
      --
      IF (p_asg_change_tab(p_index_rec.asg_index).location_id <>
          p_asg_change_tab(p_index_rec.asg_index_prev).location_id) THEN
        --
        p_indicator_rec.location_change_ind := 1;
        --
      END IF;
      --
      -- Set the supervisor change indicator to 1 if the supervisor id of the
      -- current assignment record is not the same as the supervisor id of the
      -- previous assignment record
      --
      IF (p_asg_change_tab(p_index_rec.asg_index).supervisor_id <>
          p_asg_change_tab(p_index_rec.asg_index_prev).supervisor_id) THEN
        --
        p_indicator_rec.supervisor_change_ind := 1;
        --
        -- For a secondary assignment supervisor change event,
        -- process manager hierarchy transfer
        --
        IF (p_asg_change_tab(p_index_rec.asg_index).primary_flag = 'N' OR
            p_asg_change_tab(p_index_rec.asg_index_prev).primary_flag = 'N') THEN

        hri_opl_wrkfc_trnsfr_events.process_mgrh_transfer
         (p_manager_from_id => p_asg_change_tab(p_index_rec.asg_index_prev).supervisor_id
         ,p_manager_to_id   => p_asg_change_tab(p_index_rec.asg_index).supervisor_id
         ,p_transfer_psn_id => p_asg_change_tab(p_index_rec.asg_index).person_id
         ,p_transfer_asg_id => p_asg_change_tab(p_index_rec.asg_index).assignment_id
         ,p_transfer_wty_fk => p_asg_change_tab(p_index_rec.asg_index).wkth_wktyp_code
         ,p_transfer_date   => p_asg_change_tab(p_index_rec.asg_index).change_date
         ,p_transfer_hdc    => p_date_master_tab(p_index_rec.date_index).headcount
         ,p_transfer_fte    => p_date_master_tab(p_index_rec.date_index).fte);

        END IF;
        --
      END IF;
      --
      -- Set the grade change indicator to 1 if the grade id of the current
      -- assignment record is not the same as the grade id of the previous
      -- assignment record
      --
      IF (p_asg_change_tab(p_index_rec.asg_index).grade_id <>
          p_asg_change_tab(p_index_rec.asg_index_prev).grade_id) THEN
        --
        p_indicator_rec.grade_change_ind  := 1;
        --
      END IF;
      --
      -- Set the position change indicator to 1 if the position id of the current
      -- assignment record is not the same as the position id of the previous
      -- assignment record
      --
      IF (p_asg_change_tab(p_index_rec.asg_index).position_id <>
          p_asg_change_tab(p_index_rec.asg_index_prev).position_id) THEN
        --
        p_indicator_rec.position_change_ind  := 1;
        --
      END IF;
      --
      -- Set the organization change indicator to 1 if the organization id of the
      -- current assignment record is not the same as the organization id of the
      -- previous assignment record
      --
      IF (p_asg_change_tab(p_index_rec.asg_index).organization_id <>
          p_asg_change_tab(p_index_rec.asg_index_prev).organization_id) THEN
        --
        p_indicator_rec.organization_change_ind  := 1;
        --
        -- For an organization change event, process org hierarchy transfer
        --
        hri_opl_wrkfc_trnsfr_events.process_orgh_transfer
         (p_organization_from_id => p_asg_change_tab(p_index_rec.asg_index_prev).organization_id
         ,p_organization_to_id   => p_asg_change_tab(p_index_rec.asg_index).organization_id
         ,p_transfer_psn_id      => p_asg_change_tab(p_index_rec.asg_index).person_id
         ,p_transfer_asg_id      => p_asg_change_tab(p_index_rec.asg_index).assignment_id
         ,p_transfer_wty_fk      => p_asg_change_tab(p_index_rec.asg_index).wkth_wktyp_code
         ,p_transfer_date        => p_asg_change_tab(p_index_rec.asg_index).change_date
         ,p_transfer_hdc         => p_date_master_tab(p_index_rec.date_index).headcount
         ,p_transfer_fte         => p_date_master_tab(p_index_rec.date_index).fte);
        --
      END IF;
      --
    END IF;
    --
    -- Set the salary change indicator only if the the effective start date
    -- of the record is after the refresh start date or a salary related change
    -- has occured on the refresh date
    --
    IF p_date_master_tab(p_index_rec.date_index).sal_evt_ind = 1 THEN
      --
      -- Set the salary change indicator to 1 if the salary of the current record
      -- is not the same as the salary of the previous record
      --
      IF (NVL(p_sal_change_tab(p_index_rec.sal_index).anl_slry, -1) <>
          NVL(p_sal_change_tab(p_index_rec.sal_index_prev).anl_slry, -1)) THEN
        --
        p_indicator_rec.salary_change_ind := 1;
        --
      END IF;
      --
    END IF;
    --
    -- Set the fte indicators only if a fte change has occured
    --
    -- Set the fte gain indicator to 1 if the fte of the current record is
    -- greater than the fte of previous record and the asg record is not
    -- retrospective
    --
    IF p_indicator_rec.asg_rtrspctv_strt_event_ind <> 1 THEN
      --
      IF (p_placeholder_rec.fte > p_placeholder_rec.fte_prv) THEN
        --
        p_indicator_rec.fte_gain_ind := 1;
        --
      --
      -- Set the fte loss indicator to 1 if the fte of the current record is less
      -- than the fte of previous record
      --
      ELSIF (p_placeholder_rec.fte  < p_placeholder_rec.fte_prv) THEN
        --
        p_indicator_rec.fte_loss_ind := 1;
        --
      END IF;
      --
    END IF;
    --
    -- Set the headcount gain indicator to 1 if the headcount of the current
    -- record is greater than the headcount of previous record and the asg
    -- record is not retrospective
    --
    IF p_indicator_rec.asg_rtrspctv_strt_event_ind <> 1 THEN
      --
      IF (p_placeholder_rec.headcount > p_placeholder_rec.headcount_prv) THEN
        --
        p_indicator_rec.headcount_gain_ind := 1;
        --
      --
      -- Set the headcount loss indicator to 1 if the headcount of the current
      -- record is less than the headcount of previous record
      --
      ELSIF (p_placeholder_rec.headcount  < p_placeholder_rec.headcount_prv) THEN
        --
        p_indicator_rec.headcount_loss_ind := 1;
        --
      END IF;
      --
    END IF;
    --
    -- If a promotion check is required, test for it
    --
    IF p_indicator_rec.employee_ind = 1 THEN
    --
      p_indicator_rec.promotion_ind :=
        hri_bpl_wrkfc_evt.get_promotion_ind
         (p_assignment_id     => p_asg_change_tab(p_index_rec.asg_index).assignment_id,
          p_business_group_id => p_asg_change_tab(p_index_rec.asg_index).business_group_id,
          p_effective_date    => p_asg_change_tab(p_index_rec.asg_index).change_date,
          p_new_job_id        => p_asg_change_tab(p_index_rec.asg_index).job_id,
          p_new_pos_id        => p_asg_change_tab(p_index_rec.asg_index).position_id,
          p_new_grd_id        => p_asg_change_tab(p_index_rec.asg_index).grade_id,
          p_old_job_id        => p_asg_change_tab(p_index_rec.asg_index_prev).job_id,
          p_old_pos_id        => p_asg_change_tab(p_index_rec.asg_index_prev).position_id,
          p_old_grd_id        => p_asg_change_tab(p_index_rec.asg_index_prev).grade_id);
    --
    END IF;
    --
  END IF;
  --
  --
  -- Determine the person type change indicator
  --
  IF p_indicator_rec.worker_term_ind <> 1 THEN
    --
    p_indicator_rec.summarization_rqd_ind := p_asg_change_tab(p_index_rec.asg_index).summarization_rqd_ind;
    --
    IF NVL(p_asg_change_tab(p_index_rec.asg_index).summarization_rqd_ind,-1) <>
       NVL(p_asg_change_tab(p_index_rec.asg_index_prev).summarization_rqd_ind,-1) AND
       p_indicator_rec.asg_rtrspctv_strt_event_ind <> 1 AND
       p_indicator_rec.worker_hire_ind <> 1
    THEN
      --
      p_indicator_rec.summarization_rqd_chng_ind := 1;
      --
    END IF;
    --
  ELSE
    --
    -- In case of termination set the summarization_rqd_ind to the previous
    -- value so that the record is included in delta collection
    --
    p_indicator_rec.summarization_rqd_ind := p_asg_change_tab(p_index_rec.asg_index_prev).summarization_rqd_ind;
    --
  END IF;
  --
  -- Determine if there is a POW band change
  --
  IF NVL(p_placeholder_rec.pow_band_sk_fk,-1) <> NVL(p_placeholder_rec.pow_band_sk_fk_prv,-1) THEN
    --
    p_indicator_rec.pow_band_change_ind := 1;
    --
  ELSE
    --
    p_indicator_rec.pow_band_change_ind := 0;
    --
  END IF;
  --
  -- Set the performance rating change indicator
  --
  IF (NVL(p_perf_change_tab(p_index_rec.perf_index).nrmlsd_rating, -1) <>
      NVL(p_perf_change_tab(p_index_rec.perf_index_prev).nrmlsd_rating, -1)) THEN
    --
    p_indicator_rec.perf_change_ind := 1;
    --
  END IF;
  --
  -- Set the performance band change indicator
  --
  IF (NVL(p_perf_change_tab(p_index_rec.perf_index).band, -1) <>
      NVL(p_perf_change_tab(p_index_rec.perf_index_prev).band, -1))
   THEN
    --
    p_indicator_rec.perf_band_change_ind       := 1;
    --
  END IF;
  --
  dbg('Exiting set_indicators');
END set_indicators;
--
-- -----------------------------------------------------------------------------
-- 5G. MERGE_AND_INSERT_DATA
--     Set the indicators, merge the data in the master table and insert into
--     the table HRI_MB_ASGN_EVENTS
-- -----------------------------------------------------------------------------
--
PROCEDURE merge_and_insert_data(
  p_date_master_tab    IN  g_master_tab_type,
  p_asg_change_tab     IN  g_asg_change_tab_type,
  p_sal_change_tab     IN  g_sal_change_tab_type,
  p_perf_change_tab    IN  g_perf_change_tab_type,
  p_asg_dates          IN  g_asg_date_type,
  p_prv_rec            IN  g_prv_record,
  p_nxt_ind_rec        OUT NOCOPY g_nxt_ind_record,
  p_asgn_events_tab    IN OUT NOCOPY g_asgn_events_tab_type) IS
--
-- -----------------------------------------------------------------------------
--  Start of Local Package Variable eclaration
--
--  Reset every time procedure is called
--
  --
  -- Date track period dates
  --
  l_effective_start_date                DATE;
  l_effective_end_date                  DATE;
  --
  -- Passed to the set_indicators procedure in order to collect the
  -- indicator values from the procedure
  --
  l_indicator_rec                       g_indicator_record;
  --
  -- Used to hold the previous and curerent ABV records
  --
  l_placeholder_rec                     g_placeholder_rec;
  --
  -- Holds various indexes and their previous/next values and is passed to the
  -- set_indicator procedure to set the indicator
  --
  l_index_rec                           g_index_record;
  --
  -- Holds the next indicator columns for updating of HRI_MB_ASGN_EVENTS_CT
  -- table during incremental refresh
  --
  l_nxt_ind_rec                         g_nxt_ind_record;
  --
  -- Number of rows in PL/SQL table for insert
  --
  l_row_count                     PLS_INTEGER;
  l_first_row_index               PLS_INTEGER;
  --
  -- ID of fast formula HRI_MAP_ASG_SUMMARIZATION
  --
  l_asg_sumrzn_ff_id              NUMBER;
  --
  -- Variable to hold the previous value of summarization indicator if the fast
  -- formula HRI_MAP_ASG_SUMMARIZATION exists
  --
  l_summarization_ind_prev        PLS_INTEGER;
  --
  -- Holds date of last promotion
  --
  l_last_promotion_date           DATE;
--
BEGIN
  --
  dbg('Inside merge_and_insert_data');
  --
  -- ---------------------------------------------------------------------------
  --                       Insert results into tables
  --
  -- Initialise variables
  --
  l_index_rec.date_index      := p_date_master_tab.FIRST;
  --
  IF (p_asgn_events_tab.EXISTS(1)) THEN
    l_row_count := p_asgn_events_tab.LAST;
  ELSE
    l_row_count := 0;
  END IF;
  l_first_row_index := l_row_count + 1;
  --
  -- If assignment has no salary then initialise salary record
  -- to null record
  --
  l_index_rec.sal_index       := 0;
  l_index_rec.sal_index_prev  := 0;
  --
  -- Set the performance indexes
  --
  l_index_rec.perf_index       := 0;
  l_index_rec.perf_index_prev  := 0;

  l_placeholder_rec.fte_prv           := p_prv_rec.fte_prv;
  l_placeholder_rec.headcount_prv     := p_prv_rec.headcount_prv;
  --
  -- Set the previous period of work band
  --
  l_placeholder_rec.pow_band_sk_fk_prv := p_prv_rec.pow_band_sk_fk_prv;
  --
  -- Call to find out if the fast formula HRI_MAP_ASG_SUMMARIZATION exists
  --
  l_asg_sumrzn_ff_id  := hri_bpl_asg_summarization.ff_exists_and_compiled (p_business_group_id   => 0
                                                                          ,p_date => trunc(SYSDATE)
                                                                          ,p_ff_name => 'HRI_MAP_ASG_SUMMARIZATION'
                                                                          );
  --
  -- ---------------------------------------------------------------------------
  --  Start Looping through all changes in the date index table
  --
  dbg('Before start of the loop');
  WHILE (l_index_rec.date_index IS NOT NULL) LOOP
    --
    -- Finds the index for the next record in the date index table
    --
    l_index_rec.next_date_index := p_date_master_tab.NEXT(l_index_rec.date_index);
    --
    -- Set up start date variable
    -- Since the date index is calculated as
    -- (effective start date - g_refresh_start_date)
    --
    l_effective_start_date := g_refresh_start_date + l_index_rec.date_index;
    --
    -- For the last record in the date index table set up end date variable
    --
    IF (l_index_rec.next_date_index IS NULL) THEN
      --
      -- Assign effective end date to end of time value
      --
      l_effective_end_date := g_end_of_time;
      --
    --
    -- If the record in the date index table is not the last record
    --
    ELSE
      --
      -- Assign effective end date to one day before the effective start date of
      -- the next record
      --
      l_effective_end_date := g_refresh_start_date + l_index_rec.next_date_index - 1;
      --
    END IF;
    --
    -- Store any changes to asg_index
    -- Store the previous value of the assignment index into another variable
    -- which will be required for comparison purpose during setting up of
    -- indicators in set_indicator procedure
    --
    IF (p_date_master_tab(l_index_rec.date_index).asg_index IS NOT NULL) THEN
      --
      l_index_rec.asg_index := p_date_master_tab(l_index_rec.date_index).asg_index;
      l_index_rec.asg_index_prev  :=  l_index_rec.asg_index - 1;
      --
    END IF;
    --
    -- Store any changes to sal_index
    -- Store the previous value of the salary index into another variable
    -- which will be required for comparison purpose during setting up of
    -- indicators in set_indicator procedure
    --
    IF (p_date_master_tab(l_index_rec.date_index).sal_index IS NOT NULL) THEN
      --
      l_index_rec.sal_index       := p_date_master_tab(l_index_rec.date_index).sal_index;
      --
      -- For incremental refresh the previous salary values are populated
      -- in 0th node of the salary arrays. Therefore for the first
      -- iteration of the loop, get the previous salary values from the 0th
      -- node in the salary arrays
      --
      IF l_index_rec.date_index = p_date_master_tab.FIRST THEN
        --
        IF (g_full_refresh = 'N' AND g_refresh_start_date > g_dbi_collection_start_date) THEN
          --
          l_index_rec.sal_index_prev  := 0;
          --
          -- If the refresh start on the DBI collection start date and there is a salary
          -- event on the same day, then set the previous salary value to the value of
          -- salary that existed before the DBI collection start date. Else, set the
          -- value of the previous salary to the value of salary as it exists on
          -- DBI collection start date
          --
        ELSIF (g_refresh_start_date = g_dbi_collection_start_date) THEN
          --
          IF (p_date_master_tab(l_index_rec.date_index).sal_evt_ind = 1) THEN
            --
            l_index_rec.sal_index_prev  := l_index_rec.sal_index - 1;
            --
          ELSE
            --
            l_index_rec.sal_index_prev  := l_index_rec.sal_index;
            --
          END IF;
          --
        END IF;
        --
      --
      -- From the second iteration onwards  assign the index for previous salary by
      -- subtracting 1 from the current salary index
      --
      ELSE
        --
        l_index_rec.sal_index_prev  := l_index_rec.sal_index - 1;
        --
      END IF;
      --
    END IF;
    --
    -- Store any changes to FTE value
    -- Only store when  fte collection is required
    --
    IF p_date_master_tab(l_index_rec.date_index).fte IS NOT NULL AND
       g_collect_fte = 'Y'
    THEN
      --
      l_placeholder_rec.fte := p_date_master_tab(l_index_rec.date_index).fte;
      --
    END IF;
    --
    -- Store any changes to HEAD value
    -- Only store when headcount collection is required
    --
    IF p_date_master_tab(l_index_rec.date_index).headcount IS NOT NULL AND
       g_collect_hdc = 'Y'
    THEN
      --
      l_placeholder_rec.headcount := p_date_master_tab(l_index_rec.date_index).headcount;
      --
    END IF;
    --
    -- Store any changes to period of work band
    --
    IF p_date_master_tab(l_index_rec.date_index).pow_evt_ind IS NOT NULL
    THEN
      --
      l_placeholder_rec.pow_band_sk_fk := p_date_master_tab(l_index_rec.date_index).pow_band_sk_fk;
      l_placeholder_rec.pow_extn_strt_dt := p_date_master_tab(l_index_rec.date_index).pow_extn_strt_dt;
      --
    END IF;
    --
    -- Store any changes to perf_index
    -- Store the previous value of the performance index into another variable
    -- which will be required for comparison purpose during setting up of
    -- indicators in set_indicator procedure
    --
    IF (p_date_master_tab(l_index_rec.date_index).perf_index IS NOT NULL) THEN
      --
      l_index_rec.perf_index_prev  := l_index_rec.perf_index;
      l_index_rec.perf_index       := p_date_master_tab(l_index_rec.date_index).perf_index;
      --
      -- For incremental refresh the previous performance values are populated
      -- in 0th node of the perfomance arrays. Therefore for the first
      -- iteration of the loop, get the previous performance rating values from the 0th
      -- node in the performance rating arrays
      --
      IF l_index_rec.date_index = p_date_master_tab.FIRST THEN
        --
        IF (g_full_refresh = 'N' AND g_refresh_start_date > g_dbi_collection_start_date) THEN
          --
          l_index_rec.perf_index_prev  := 0;
          --
          -- If the refresh start on the DBI collection start date and there is a perf
          -- event on the same day, then set the previous perf value to the value of
          -- perf that existed before the DBI collection start date. Else, set the
          -- value of the previous perf to the value of perf as it exists on
          -- DBI collection start date
          --
        ELSIF (g_refresh_start_date = g_dbi_collection_start_date) THEN
          --
          IF (p_date_master_tab(l_index_rec.date_index).perf_evt_ind = 1) THEN
            --
            l_index_rec.perf_index_prev  := l_index_rec.perf_index - 1;
            --
          ELSE
            --
            l_index_rec.perf_index_prev  := l_index_rec.perf_index;
            --
          END IF;
          --
        END IF;
        --
      END IF;
      --
    END IF;
    --
    -- Call to the set_indicator procedure which sets all the indicators and
    -- return their values
    --
    SET_INDICATORS(
       p_asg_dates                    =>  p_asg_dates
      ,p_asg_change_tab               =>  p_asg_change_tab
      ,p_sal_change_tab               =>  p_sal_change_tab
      ,p_perf_change_tab              =>  p_perf_change_tab
      ,p_date_master_tab              =>  p_date_master_tab
      ,p_index_rec                    =>  l_index_rec
      ,p_placeholder_rec              =>  l_placeholder_rec
      ,p_indicator_rec                =>  l_indicator_rec
      ,p_effective_start_date         =>  l_effective_start_date
      ,p_effective_end_date           =>  l_effective_end_date);
    --
    -- Change the summarization related indicators only if the fast formula
    -- HRI_MAP_ASG_SUMMARIZATION exists
    --
    IF (l_asg_sumrzn_ff_id IS NOT NULL) THEN
      --
      -- Call to find out the summarization related indicators
      --
      check_update_smrztn_rqrmnt(p_effective_start_date => l_effective_start_date,
                                   p_indicator_rec =>  l_indicator_rec,
                                   p_summarization_ind_prev => l_summarization_ind_prev);
      --
      -- Store the previous indicator value for comparison purpose in the next
      -- iteration
      --
      l_summarization_ind_prev := l_indicator_rec.summarization_rqd_ind;
      --
    END IF;
    --
    -- Store the last promotion date (to calculate days since last promotion)
    --
    IF (l_indicator_rec.promotion_ind = 1 OR
        l_last_promotion_date IS NULL) THEN
      l_last_promotion_date := l_effective_start_date;
    END IF;
    --
    -- -------------------------------------------------------------------------
    -- Store the value of columns into  PL/SQL tables for bulk insert
    -- -------------------------------------------------------------------------
    --
    -- Maintain counter of rows to insert
    --
    l_row_count := l_row_count + 1;
    --
    -- Primary Key
    --
    p_asgn_events_tab(l_row_count).assignment_id := g_assignment_id;
    p_asgn_events_tab(l_row_count).effective_change_date := l_effective_start_date;
    p_asgn_events_tab(l_row_count).effective_change_end_date := l_effective_end_date;
    --
    --Id Keys
    --
    p_asgn_events_tab(l_row_count).person_id :=
               p_asg_change_tab(l_index_rec.asg_index).person_id;
    --
    -- Assignment related FK ID's which are present in the
    -- assignment records after the event
    --
    p_asgn_events_tab(l_row_count).business_group_id :=
               p_asg_change_tab(l_index_rec.asg_index).business_group_id;
    p_asgn_events_tab(l_row_count).grade_id :=
               p_asg_change_tab(l_index_rec.asg_index).grade_id;
    p_asgn_events_tab(l_row_count).job_id :=
               p_asg_change_tab(l_index_rec.asg_index).job_id;
    p_asgn_events_tab(l_row_count).location_id :=
               p_asg_change_tab(l_index_rec.asg_index).location_id;
    p_asgn_events_tab(l_row_count).organization_id :=
               p_asg_change_tab(l_index_rec.asg_index).organization_id;
    p_asgn_events_tab(l_row_count).supervisor_id :=
               p_asg_change_tab(l_index_rec.asg_index).supervisor_id;
    p_asgn_events_tab(l_row_count).position_id :=
               p_asg_change_tab(l_index_rec.asg_index).position_id;
    p_asgn_events_tab(l_row_count).primary_flag :=
               p_asg_change_tab(l_index_rec.asg_index).primary_flag;
    p_asgn_events_tab(l_row_count).pow_start_date :=
               p_asg_change_tab(l_index_rec.asg_index).hire_date;
    p_asgn_events_tab(l_row_count).pow_start_date_adj :=
               p_asg_dates.pow_start_date_adj;
    p_asgn_events_tab(l_row_count).change_reason_code :=
               p_asg_change_tab(l_index_rec.asg_index).change_reason_code;
    p_asgn_events_tab(l_row_count).leaving_reason_code :=
               p_asg_change_tab(l_index_rec.asg_index).leaving_reason_code;
    p_asgn_events_tab(l_row_count).asg_type_code :=
               p_asg_change_tab(l_index_rec.asg_index).type;
    --
    -- Assignment releated FK ID's existing prior to the event
    --
    p_asgn_events_tab(l_row_count).grade_prv_id :=
               p_asg_change_tab(l_index_rec.asg_index_prev).grade_id;
    p_asgn_events_tab(l_row_count).job_prv_id :=
               p_asg_change_tab(l_index_rec.asg_index_prev).job_id;
    p_asgn_events_tab(l_row_count).location_prv_id :=
               p_asg_change_tab(l_index_rec.asg_index_prev).location_id;
    p_asgn_events_tab(l_row_count).organization_prv_id :=
               p_asg_change_tab(l_index_rec.asg_index_prev).organization_id;
    p_asgn_events_tab(l_row_count).supervisor_prv_id :=
               p_asg_change_tab(l_index_rec.asg_index_prev).supervisor_id;
    p_asgn_events_tab(l_row_count).position_prv_id :=
               p_asg_change_tab(l_index_rec.asg_index_prev).position_id;
    p_asgn_events_tab(l_row_count).primary_flag_prv :=
               p_asg_change_tab(l_index_rec.asg_index_prev).primary_flag;
    --
    -- Separation Category related measure for a person
    -- Bug 4519711 - only call function if assignment type is 'E' and there
    --               is a separation
    --
    IF (p_asg_change_tab(l_index_rec.asg_index_prev).type = 'E' AND
        (l_indicator_rec.term_voluntary_ind = 1 OR
         l_indicator_rec.term_involuntary_ind = 1))
    THEN
      --
      p_asgn_events_tab(l_row_count).separation_category :=
               hri_bpl_termination.get_separation_category
                (p_asg_change_tab(l_index_rec.asg_index).leaving_reason_code);
      --
    ELSE
      --
      p_asgn_events_tab(l_row_count).separation_category := 'NA_EDW';
      --
    END IF;
    --
    -- bug 4558443 - use pow_start_date_adj
    --
    p_asgn_events_tab(l_row_count).pow_days_on_event_date :=
          l_effective_start_date - p_asg_dates.pow_start_date_adj;
    p_asgn_events_tab(l_row_count).pow_months_on_event_date :=
          MONTHS_BETWEEN(l_effective_start_date,
                         p_asg_dates.pow_start_date_adj);
    --
    -- Headcount related Measures and information for an assignment
    --
    p_asgn_events_tab(l_row_count).fte := l_placeholder_rec.fte;
    p_asgn_events_tab(l_row_count).fte_prv := l_placeholder_rec.fte_prv;
    p_asgn_events_tab(l_row_count).headcount := l_placeholder_rec.headcount;
    p_asgn_events_tab(l_row_count).headcount_prv := l_placeholder_rec.headcount_prv;
    --
    -- Salary related Measures and information for a person
    --
    p_asgn_events_tab(l_row_count).anl_slry :=
               p_sal_change_tab(l_index_rec.sal_index).anl_slry;
    p_asgn_events_tab(l_row_count).anl_slry_prv :=
               p_sal_change_tab(l_index_rec.sal_index_prev).anl_slry;
    p_asgn_events_tab(l_row_count).anl_slry_currency :=
               p_sal_change_tab(l_index_rec.sal_index).anl_slry_currency;
    p_asgn_events_tab(l_row_count).anl_slry_currency_prv :=
               p_sal_change_tab(l_index_rec.sal_index_prev).anl_slry_currency;
    p_asgn_events_tab(l_row_count).pay_proposal_id :=
               p_sal_change_tab(l_index_rec.sal_index).pay_proposal_id;
    --
    -- Performance related measure for a person
    --
    p_asgn_events_tab(l_row_count).perf_nrmlsd_rating :=
       NVL(p_perf_change_tab(l_index_rec.perf_index).nrmlsd_rating, -1);
    p_asgn_events_tab(l_row_count).perf_nrmlsd_rating_prv :=
       NVL(p_perf_change_tab(l_index_rec.perf_index_prev).nrmlsd_rating, -1);
    p_asgn_events_tab(l_row_count).perf_band :=
       NVL(p_perf_change_tab(l_index_rec.perf_index).band, g_perf_not_rated_id);
    p_asgn_events_tab(l_row_count).perf_band_prv :=
       NVL(p_perf_change_tab(l_index_rec.perf_index_prev).band, g_perf_not_rated_id);
    p_asgn_events_tab(l_row_count).performance_review_id :=
               p_perf_change_tab(l_index_rec.perf_index).review_id;
    p_asgn_events_tab(l_row_count).perf_review_type_cd :=
               p_perf_change_tab(l_index_rec.perf_index).review_type_cd;
    p_asgn_events_tab(l_row_count).performance_rating_cd :=
               p_perf_change_tab(l_index_rec.perf_index).rating_cd;
    p_asgn_events_tab(l_row_count).days_since_last_prmtn   :=
               l_effective_start_date - l_last_promotion_date;
    p_asgn_events_tab(l_row_count).months_since_last_prmtn :=
               MONTHS_BETWEEN(l_effective_start_date, l_last_promotion_date);
    --
    -- Person type related measures for a person
    --
    p_asgn_events_tab(l_row_count).prsntyp_sk_fk :=
               NVL(p_asg_change_tab(l_index_rec.asg_index).prsntyp_sk_fk,-1);
    p_asgn_events_tab(l_row_count).summarization_rqd_ind :=
               NVL(l_indicator_rec.summarization_rqd_ind, 1);
    p_asgn_events_tab(l_row_count).summarization_rqd_chng_ind :=
               NVL(l_indicator_rec.summarization_rqd_chng_ind, 0);
    p_asgn_events_tab(l_row_count).summarization_rqd_chng_nxt_ind :=
               NVL(l_indicator_rec.summarization_rqd_chng_nxt_ind, 0);
    --
    -- Indicator assignment with values that gets set in  the set_indicators procedure
    --
    p_asgn_events_tab(l_row_count).asg_rtrspctv_strt_event_ind :=
               l_indicator_rec.asg_rtrspctv_strt_event_ind;
    p_asgn_events_tab(l_row_count).assignment_change_ind :=
               l_indicator_rec.assignment_change_ind;
    p_asgn_events_tab(l_row_count).salary_change_ind :=
               l_indicator_rec.salary_change_ind;
    --
    -- Setting the performance rating indicators
    --
    p_asgn_events_tab(l_row_count).perf_rating_change_ind :=
               l_indicator_rec.perf_change_ind;
    p_asgn_events_tab(l_row_count).perf_band_change_ind :=
               l_indicator_rec.perf_band_change_ind;
    --
    -- Setting the period of work related measure for a person
    --
    p_asgn_events_tab(l_row_count).pow_band_sk_fk :=
               l_placeholder_rec.pow_band_sk_fk;
    p_asgn_events_tab(l_row_count).pow_band_prv_sk_fk :=
               l_placeholder_rec.pow_band_sk_fk_prv;

    p_asgn_events_tab(l_row_count).pow_extn_strt_dt :=
               l_placeholder_rec.pow_extn_strt_dt;
    --
    -- Setting the period of work related indicators
    --
    p_asgn_events_tab(l_row_count).pow_band_change_ind :=
               l_indicator_rec.pow_band_change_ind;
    --
    p_asgn_events_tab(l_row_count).headcount_gain_ind :=
               l_indicator_rec.headcount_gain_ind;
    p_asgn_events_tab(l_row_count).headcount_loss_ind :=
               l_indicator_rec.headcount_loss_ind;
    p_asgn_events_tab(l_row_count).fte_gain_ind :=
               l_indicator_rec.fte_gain_ind;
    p_asgn_events_tab(l_row_count).fte_loss_ind :=
               l_indicator_rec.fte_loss_ind;
    p_asgn_events_tab(l_row_count).contingent_ind :=
               l_indicator_rec.contingent_ind;
    p_asgn_events_tab(l_row_count).employee_ind :=
               l_indicator_rec.employee_ind;
    p_asgn_events_tab(l_row_count).grade_change_ind :=
               l_indicator_rec.grade_change_ind;
    p_asgn_events_tab(l_row_count).job_change_ind :=
               l_indicator_rec.job_change_ind;
    p_asgn_events_tab(l_row_count).position_change_ind :=
               l_indicator_rec.position_change_ind;
    p_asgn_events_tab(l_row_count).location_change_ind :=
               l_indicator_rec.location_change_ind;
    p_asgn_events_tab(l_row_count).organization_change_ind :=
               l_indicator_rec.organization_change_ind;
    p_asgn_events_tab(l_row_count).supervisor_change_ind :=
               l_indicator_rec.supervisor_change_ind;
    p_asgn_events_tab(l_row_count).worker_hire_ind :=
               l_indicator_rec.worker_hire_ind;
    p_asgn_events_tab(l_row_count).post_hire_asgn_start_ind :=
               l_indicator_rec.post_hire_asgn_start_ind;
    p_asgn_events_tab(l_row_count).pre_sprtn_asgn_end_ind :=
               l_indicator_rec.pre_sprtn_asgn_end_ind;
    p_asgn_events_tab(l_row_count).term_voluntary_ind :=
               l_indicator_rec.term_voluntary_ind;
    p_asgn_events_tab(l_row_count).term_involuntary_ind :=
               l_indicator_rec.term_involuntary_ind;
    p_asgn_events_tab(l_row_count).worker_term_ind :=
               l_indicator_rec.worker_term_ind;
    p_asgn_events_tab(l_row_count).start_asg_sspnsn_ind :=
               l_indicator_rec.start_asg_sspnsn_ind;
    p_asgn_events_tab(l_row_count).end_asg_sspnsn_ind :=
               l_indicator_rec.end_asg_sspnsn_ind;
    p_asgn_events_tab(l_row_count).promotion_ind :=
               l_indicator_rec.promotion_ind;
    --
    IF (l_row_count > l_first_row_index) THEN
      --
      p_asgn_events_tab(l_row_count - 1).worker_term_nxt_ind :=
               l_indicator_rec.worker_term_ind;
      p_asgn_events_tab(l_row_count - 1).term_voluntary_nxt_ind :=
               l_indicator_rec.term_voluntary_ind;
      p_asgn_events_tab(l_row_count - 1).term_involuntary_nxt_ind :=
               l_indicator_rec.term_involuntary_ind;
      p_asgn_events_tab(l_row_count - 1).supervisor_change_nxt_ind :=
               l_indicator_rec.supervisor_change_ind;
      p_asgn_events_tab(l_row_count - 1).pre_sprtn_asgn_end_nxt_ind :=
               l_indicator_rec.pre_sprtn_asgn_end_ind;
      --
      -- Separation Category Changes
      --
      p_asgn_events_tab(l_row_count - 1).separation_category_nxt :=
               p_asgn_events_tab(l_row_count).separation_category;
      --
      --
      --
      p_asgn_events_tab(l_row_count - 1).summarization_rqd_chng_nxt_ind :=
               p_asgn_events_tab(l_row_count).summarization_rqd_chng_ind;
      --
    END IF;
    --
    -- End of populate Events table with change details
    --
    -- -------------------------------------------------------------------------
    --  Setting up variables to be used in the next loop iteration
    --
    -- Assign the previous assignment and salary index values to be
    -- used for the next iteration of the loop
    --
    l_index_rec.asg_index_prev := l_index_rec.asg_index;
    l_index_rec.sal_index_prev := l_index_rec.sal_index;
    --
    -- Assign the previous performance index values to be
    -- used for the next iteration of the loop
    --
    l_index_rec.perf_index_prev := l_index_rec.perf_index;
    --
    -- Store the previous ABV values for use in the next iteration of the loop
    --
    l_placeholder_rec.fte_prv          := l_placeholder_rec.fte;
    l_placeholder_rec.headcount_prv    := l_placeholder_rec.headcount;
    --
    -- Assign the previous period of work index values to be
    -- used for the next iteration of the loop
    --
    l_placeholder_rec.pow_band_sk_fk_prv := l_placeholder_rec.pow_band_sk_fk;
    --
    -- Move to next record
    --
    l_index_rec.date_index     := p_date_master_tab.NEXT(l_index_rec.date_index);
    --
    dbg('change date='||p_asgn_events_tab(l_row_count).effective_change_date);
    --
  END LOOP;
  --
  --  Finished Looping through all changes in the date index table
  --
  -- Add missing indicators
  p_asgn_events_tab(l_row_count).worker_term_nxt_ind := TO_NUMBER(NULL);
  p_asgn_events_tab(l_row_count).term_voluntary_nxt_ind := TO_NUMBER(NULL);
  p_asgn_events_tab(l_row_count).term_involuntary_nxt_ind := TO_NUMBER(NULL);
  p_asgn_events_tab(l_row_count).supervisor_change_nxt_ind := TO_NUMBER(NULL);
  p_asgn_events_tab(l_row_count).pre_sprtn_asgn_end_nxt_ind := TO_NUMBER(NULL);
  p_asgn_events_tab(l_row_count).separation_category_nxt := 'NA_EDW';
  --
  -- Assigning the indicator values for updating the next indicator columns in
  -- table HRI_MB_ASGN_EVENTS
  --
  p_nxt_ind_rec.worker_term_nxt_ind :=
          p_asgn_events_tab(l_first_row_index).worker_term_ind;
  p_nxt_ind_rec.term_voluntary_nxt_ind :=
          p_asgn_events_tab(l_first_row_index).term_voluntary_ind;
  p_nxt_ind_rec.term_involuntary_nxt_ind :=
          p_asgn_events_tab(l_first_row_index).term_involuntary_ind;
  p_nxt_ind_rec.supervisor_change_nxt_ind :=
          p_asgn_events_tab(l_first_row_index).supervisor_change_ind;
  p_nxt_ind_rec.pre_sprtn_asgn_end_nxt_ind :=
          p_asgn_events_tab(l_first_row_index).pre_sprtn_asgn_end_ind;
  p_nxt_ind_rec.summarization_rqd_chng_nxt_ind :=
          p_asgn_events_tab(l_first_row_index).summarization_rqd_chng_ind;
  --
END merge_and_insert_data;
--
-- ----------------------------------------------------------------------------
-- 5H Update End Record
--    For Incremental Refresh, this process end dates the previous assignment
--    record (with change_date < earliest_change_date) and populates the
--    NXT type indicator columns
-- ----------------------------------------------------------------------------
--
PROCEDURE update_end_record(p_nxt_ind_rec IN g_nxt_ind_record
                           ,p_row_id      IN ROWID) IS
BEGIN
  --
  dbg('Entering update_end_record');
  --
  -- End date the assignment records for the assignment that ovelap the
  -- earliest event date
  --
  UPDATE hri_mb_asgn_events_ct
  SET    effective_change_end_date     = (g_refresh_start_date - 1),
         worker_term_nxt_ind           = p_nxt_ind_rec.worker_term_nxt_ind,
         term_voluntary_nxt_ind        = p_nxt_ind_rec.term_voluntary_nxt_ind,
         term_involuntary_nxt_ind      = p_nxt_ind_rec.term_involuntary_nxt_ind,
         supervisor_change_nxt_ind     = p_nxt_ind_rec.supervisor_change_nxt_ind,
         pre_sprtn_asgn_end_nxt_ind    = p_nxt_ind_rec.pre_sprtn_asgn_end_nxt_ind,
         summarization_rqd_chng_nxt_ind= p_nxt_ind_rec.summarization_rqd_chng_nxt_ind
  WHERE  ROWID = p_row_id;
  --
  dbg('Existing update_end_record');
  --
END update_end_record;
--
-- ----------------------------------------------------------------------------
-- 5 Collect
--   The Main Collection Process which is called from archive_code.
--   It calls procedures 5A to 5H
-- ----------------------------------------------------------------------------
--
PROCEDURE collect(p_assignment_id      IN NUMBER,
                  p_asgn_events_tab    IN OUT NOCOPY g_asgn_events_tab_type) IS
--
-- Data structures that are passed to the assignment, abv and
-- salary routines. These variables cannot be included in a single
-- array to facilitate bulk fetch from cursors and bulk insert into
-- the events table.
--
  --
  -- Assignment related pl/sql tables
  --
  l_asg_change_tab               g_asg_change_tab_type;
  --
  -- Salary related pl/sql tables
  --
  l_sal_change_tab               g_sal_change_tab_type;
  --
  -- Performance rating related PLSQL tables
  --
  l_perf_change_tab              g_perf_change_tab_type;
  --
  -- PLSQL table representing master date-transposed database table
  --
  l_date_master_tab              g_master_tab_type;

  --
  -- Type containing hiring date, termination date, secondary assignment start
  -- date, secondary assignment end date, assignment start date, assignment end
  -- date
  --
  l_asg_dates                    g_asg_date_type;
  --
  -- Type for previous records
  --
  l_prv_rec                      g_prv_record;
  --
  -- Holds the present and previous fte and headcount values and is passed to
  -- set_indicators procedure to set the indicators
  --
  l_placeholder_rec              g_placeholder_rec;
  --
  -- Holds the indicator values to update the next indicator columns in the
  -- table HRI_MB_ASGN_EVENTS_CT during incremental refresh
  --
  l_nxt_ind_rec                  g_nxt_ind_record;
  --
--
BEGIN
  --
  dbg('Inside collect');
  dbg('-------------------------------------------------------------------');
  dbg('Collecting assignment events data for assignment_id:'||p_assignment_id);
  --
  -- Initialize global variables
  --
  g_assignment_id := p_assignment_id;
  g_refresh_start_date := GREATEST(g_refresh_start_date, g_dbi_collection_start_date);
  dbg('Collecting data from '||g_refresh_start_date);
  --
  -- 5B Identify Assignment Changes
  --
  dbg('Calling identify_assignment_changes');
  --
  IDENTIFY_ASSIGNMENT_CHANGES(
     p_date_master_tab  => l_date_master_tab
    ,p_asg_change_tab   => l_asg_change_tab
    ,p_asg_dates        => l_asg_dates);
  --
  -- 5C Identify ABV Changes
  --
  dbg('Calling identify_abv_changes');
  --
  IDENTIFY_ABV_CHANGES(
     p_asg_dates               => l_asg_dates
    ,p_date_master_tab         => l_date_master_tab
    ,p_prv_rec                 => l_prv_rec);
  --
  -- 5D Fill gaps in ABV history
  -- Fill the gaps through fast formula if ABV is not assignned for the period
  --
  dbg('Calling fill_gaps_in_abv_history');
  --
  FILL_GAPS_IN_ABV_HISTORY(
     p_asg_dates               => l_asg_dates
    ,p_date_master_tab         => l_date_master_tab
    ,p_business_group_id       => l_asg_change_tab(1).business_group_id);
  --
  -- 5E Identify Salary Changes
  --
  dbg('Calling identify_salary_changes');
  --
  IDENTIFY_SALARY_CHANGES(
     p_asg_dates        => l_asg_dates
    ,p_date_master_tab  => l_date_master_tab
    ,p_sal_change_tab   => l_sal_change_tab);
  --
  -- 5F Identify Performance Rating Changes
  --
  dbg('Calling identify_perf_rating_changes');
  --
  IDENTIFY_PERF_RATING_CHANGES  (
    p_asg_dates                  => l_asg_dates,
    p_person_id                  => l_asg_change_tab(1).person_id,
    p_business_group_id          => l_asg_change_tab(1).business_group_id,
    p_date_master_tab            => l_date_master_tab,
    p_perf_change_tab            => l_perf_change_tab);
  --
  -- 5G Identify Period Of Work Band Changes
  --
  dbg('Calling identify_pow_band_changes');
  --
  IDENTIFY_POW_BAND_CHANGES(
     p_asg_dates        => l_asg_dates,
     p_person_id        => l_asg_change_tab(1).person_id,
     p_date_master_tab  => l_date_master_tab,
     p_assignment_type  => l_asg_change_tab(1).type);
  --
  -- 5G1 Identify Person Type Changes
  --
  dbg('Calling identify_prsn_typ_changes');
  --
   --
   -- 5H Set Previous Values
   --
   -- Set the previous values of grade_id, job_id, location_id, organization_id,
   -- supervisor_id, position_id, primary_flag, fte, headcount, anl_slry and
   -- anl_slry_currency, as they exists one day before the incremental refresh
   -- For full refresh set up a default record for values before the refresh
   -- start date
   --
   dbg('Calling set_previous_values');
   --
   SET_PREVIOUS_VALUES(
      p_prv_rec             => l_prv_rec
      ,p_business_group_id  => l_asg_change_tab(1).business_group_id
      ,p_date_master_tab    => l_date_master_tab
      ,p_hire_date          => l_asg_dates.hire_date);
   --
   -- Set the values that existed before the refresh start date. The values were
   -- set in the procedure set_previous_values
   --
   --
   -- Set the assignment related values
   --
   dbg('Assigning assignment related previous values to local arrays');
   l_asg_change_tab(0).organization_id := l_prv_rec.organization_prv_id;
   l_asg_change_tab(0).location_id     := l_prv_rec.location_prv_id;
   l_asg_change_tab(0).job_id          := l_prv_rec.job_prv_id;
   l_asg_change_tab(0).grade_id        := l_prv_rec.grade_prv_id;
   l_asg_change_tab(0).position_id     := l_prv_rec.position_prv_id;
   l_asg_change_tab(0).supervisor_id   := l_prv_rec.supervisor_prv_id;
   l_asg_change_tab(0).primary_flag    := l_prv_rec.primary_flag_prv;
   l_asg_change_tab(0).summarization_rqd_ind := l_prv_rec.summarization_rqd_ind_prv;
   l_asg_change_tab(0).status_code     := 'NA_EDW';
   --
   -- Set the salary related values
   --
   dbg('Assigning salary related previous values to local arrays');
   l_sal_change_tab(0).anl_slry          := l_prv_rec.anl_slry_prv;
   l_sal_change_tab(0).pay_proposal_id   := -1;
   l_sal_change_tab(0).anl_slry_currency := l_prv_rec.anl_slry_currency_prv ;
   --
   -- Set the performance change related values
   --
   l_perf_change_tab(0).review_id       := -1;
   l_perf_change_tab(0).review_type_cd  := -1;
   l_perf_change_tab(0).rating_cd       := -1;
   l_perf_change_tab(0).nrmlsd_rating   := l_prv_rec.perf_nrmlsd_rating_prv;
   l_perf_change_tab(0).band            := l_prv_rec.perf_band_prv;
   --
   -- Set the period of work change related changes
   --
   --
   -- Set the ABV related values
   --
   dbg('Assigning ABV related previous values to local arrays');
   l_placeholder_rec.fte_prv           := l_prv_rec.fte_prv;
   l_placeholder_rec.headcount_prv     := l_prv_rec.headcount_prv;
   --
   -- Assign the person type fk's
   --
   l_placeholder_rec.pow_band_sk_fk_prv := l_prv_rec.pow_band_sk_fk_prv;
   --
   -- 5I Merge and insert data
   -- Merge the data collected and insert into the table HRI_MB_ASGN_EVENTS_CT
   --
   dbg('Calling merge_and_insert_data');
   --
   MERGE_AND_INSERT_DATA(
     p_date_master_tab  => l_date_master_tab
     ,p_asg_change_tab  => l_asg_change_tab
     ,p_sal_change_tab  => l_sal_change_tab
     ,p_perf_change_tab => l_perf_change_tab
     ,p_asg_dates       => l_asg_dates
     ,p_prv_rec         => l_prv_rec
     ,p_nxt_ind_rec     => l_nxt_ind_rec
     ,p_asgn_events_tab => p_asgn_events_tab);
   --
   -- If incremental refresh
   --
   IF g_full_refresh = 'N' THEN
     --
     -- 5J Update End Record
     --
     -- End date the assignment records for the assignment that ovelap the earliest
     -- event date
     --
     dbg('Calling update_end_record');
     --
     UPDATE_END_RECORD(p_nxt_ind_rec => l_nxt_ind_rec
                      ,p_row_id      => l_prv_rec.row_id );
     --
   END IF;
   --
   dbg('Finished collecting assignment events for assignment_id:'||p_assignment_id);
   dbg('-------------------------------------------------------------------');
   --
END collect;
--
-- ----------------------------------------------------------------------------
-- shared_hrms_dflt_prcss
-- This process will be launched by shared_hrms_dflt_prcss (OVERLOADED).
-- ============================================================================
-- This procedure contains the code required to populate hri_mb_asgn_events_ct in shared
-- HR.
--
PROCEDURE shared_hrms_dflt_prcss
IS
  --
  l_dummy1           VARCHAR2(2000);
  l_dummy2           VARCHAR2(2000);
  l_schema           VARCHAR2(400);
  l_sql_stmt         VARCHAR2(500);
  l_user_id          NUMBER;
  l_current_time     DATE;
  --
BEGIN
  --
  dbg('Populating hri_mb_asgn_events_ct in shared HR');
  --
  l_user_id          := fnd_global.user_id;
  l_current_time     := SYSDATE;
  --
  -- 4126398, Added new columns and changed all default values for indicators to 0
  -- Inserts row
  --
  INSERT /*+ APPEND */ INTO hri_mb_asgn_events_ct
    (event_id,
     effective_change_date,
     effective_change_end_date,
     assignment_id,
     person_id,
     grade_id,
     grade_prv_id,
     job_id,
     job_prv_id,
     location_id,
     location_prv_id,
     organization_id,
     organization_prv_id,
     supervisor_id,
     supervisor_prv_id,
     position_id,
     position_prv_id,
     primary_flag,
     primary_flag_prv,
     pow_start_date_adj,
     change_reason_code,
     leaving_reason_code,
     fte,
     fte_prv,
     headcount,
     headcount_prv,
     anl_slry,
     anl_slry_prv,
     anl_slry_currency,
     anl_slry_currency_prv,
     pay_proposal_id,
     asg_rtrspctv_strt_event_ind,
     assignment_change_ind,
     salary_change_ind,
     headcount_gain_ind,
     headcount_loss_ind,
     fte_gain_ind,
     fte_loss_ind,
     contingent_ind,
     employee_ind,
     grade_change_ind,
     job_change_ind,
     position_change_ind,
     location_change_ind,
     organization_change_ind,
     supervisor_change_ind,
     worker_hire_ind,
     post_hire_asgn_start_ind,
     pre_sprtn_asgn_end_ind,
     term_voluntary_ind,
     term_involuntary_ind,
     worker_term_ind,
     start_asg_sspnsn_ind,
     end_asg_sspnsn_ind,
     last_update_date,
     last_updated_by,
     last_update_login,
     created_by,
     creation_date,
     effective_change_date_prv,
     worker_term_nxt_ind,
     pre_sprtn_asgn_end_nxt_ind,
     supervisor_change_nxt_ind,
     term_voluntary_nxt_ind,
     term_involuntary_nxt_ind,
     pow_days_on_event_date,
     separation_category,
     separation_category_nxt,
     pow_months_on_event_date,
     pow_start_date,
     pow_band_change_ind,
     perf_nrmlsd_rating,
     perf_nrmlsd_rating_prv,
     performance_review_id,
     perf_review_type_cd,
     performance_rating_cd,
     perf_band,
     perf_band_prv,
     perf_rating_change_ind,
     perf_band_change_ind,
     prsntyp_sk_fk,
     summarization_rqd_ind
     )
  SELECT
     hri_mb_asgn_events_ct_s.nextval   event_id,
     GREATEST(pos.date_start, g_dbi_collection_start_date)    effective_change_date,
     NVL(pos.actual_termination_date,g_end_of_time)  effective_change_end_date,
     asg.assignment_id                 assignment_id,
     asg.person_id                     person_id,
     -1                                grade_id,
     -1                                grade_prv_id,
     NVL(asg.job_id,-1)                job_id,
     -1                                job_prv_id,
     NVL(asg.location_id,-1)           location_id,
     -1                                location_prv_id,
     NVL(asg.organization_id,-1)       organization_id,
     -1                                organization_prv_id,
     NVL(asg.supervisor_id,-1)         supervisor_id,
     -1                                supervisor_prv_id,
     NVL(asg.position_id,-1)           position_id,
     -1                                position_prv_id,
     asg.primary_flag                  primary_flag,
     'NA_EDW'                          primary_flag_prv,
     pos.adjusted_svc_date             adjusted_svc_date,
     'NA_EDW'                          change_reason_code,
     'NA_EDW'                          leaving_reason_code,
     1                                 fte,
     0                                 fte_prv,
     1                                 headcount,
     0                                 headcount_prv,
     0                                 anl_slry,
     0                                 anl_slry_prv,
     'NA_EDW'                          anl_slry_currency,
     'NA_EDW'                          anl_slry_currency_prv,
     -1                                pay_proposal_id,
     0                                 asg_rtrspctv_strt_event_ind,
     0                                 assignment_change_ind,
     0                                 salary_change_ind,
     0                                 headcount_gain_ind,
     0                                 headcount_loss_ind,
     0                                 fte_gain_ind,
     0                                 fte_loss_ind,
     0                                 contingent_ind,
     1                                 employee_ind,
     0                                 grade_change_ind,
     0                                 job_change_ind,
     0                                 position_change_ind,
     0                                 location_change_ind,
     0                                 organization_change_ind,
     0                                 supervisor_change_ind,
     0                                 worker_hire_ind,
     0                                 post_hire_asgn_start_ind,
     0                                 pre_sprtn_asgn_end_ind,
     0                                 term_voluntary_ind,
     0                                 term_involuntary_ind,
     0                                 worker_term_ind,
     0                                 start_asg_sspnsn_ind,
     0                                 end_asg_sspnsn_ind,
     l_current_time                    last_update_date,
     l_user_id                         last_updated_by,
     l_user_id                         last_update_login,
     l_user_id                         created_by,
     l_current_time                    creation_date,
     null                              effective_change_date_prv,
     0                                 worker_term_nxt_ind,
     0                                 pre_sprtn_asgn_end_nxt_ind,
     0                                 supervisor_change_nxt_ind,
     0                                 term_voluntary_nxt_ind,
     0                                 term_involuntary_nxt_ind,
     0                                 pow_days_on_event_date,
     'NA_EDW'                          separation_category,
     'NA_EDW'                          separation_category_nxt,
     months_between(SYSDATE,pos.date_start) pow_months_on_event_date,
     pos.date_start                    pow_start_date,
     0                                 pow_band_change_ind,
     -1                                perf_nrmlsd_rating,
     -1                                perf_nrmlsd_rating_prv,
     -1                                performance_review_id,
     'NA_EDW'                          perf_review_type_cd,
     'NA_EDW'                          performance_rating_cd,
     g_perf_not_rated_id               perf_band,
     g_perf_not_rated_id               perf_band_prv,
     0                                 perf_rating_change_ind,
     0                                 perf_band_change_ind,
     hpt.prsntyp_sk_pk                 prsntyp_sk_fk,
     1                                 summarization_rqd_ind
  FROM  per_all_assignments_f             asg,
        per_periods_of_service            pos,
        hri_cs_prsntyp_ct                 hpt,
        per_person_type_usages_f          ptu
  WHERE asg.assignment_type = 'E'
  AND   asg.primary_flag = 'Y'
  AND   asg.period_of_service_id = pos.period_of_service_id
  AND   ptu.person_id      = asg.person_id
  AND   hpt.person_type_id = ptu.person_type_id
  AND   hpt.employment_category_code = NVL(asg.employment_category,'NA_EDW')
  AND   hpt.primary_flag_code = NVL(asg.primary_flag,'NA_EDW')
  AND   hpt.assignment_type_code = asg.assignment_type
  AND   TRUNC(SYSDATE) BETWEEN asg.effective_start_date
                       AND asg.effective_end_date
  AND   TRUNC(SYSDATE) BETWEEN ptu.effective_start_date
                       AND ptu.effective_end_date;
  --
END shared_hrms_dflt_prcss;
--
-- ----------------------------------------------------------------------------
-- shared_hrms_dflt_prcss (OVERLOADED)
-- Default process executed when PYUGEN is not available.
-- ============================================================================
-- This process will be launched by the package HRI_BPL_PYUGEN_WRAPPER
-- whenever it detects PYUGEN is not installed.
--
-- The parameters of this function are standard for all default processes
-- called where PYUGEN does not exist. This particular package IGNORES THEM
--
PROCEDURE shared_hrms_dflt_prcss
  (
   errbuf              OUT NOCOPY VARCHAR2
  ,retcode             OUT NOCOPY NUMBER
  ,p_collect_from_date IN VARCHAR2 DEFAULT NULL -- Optional Param default NULL
  ,p_collect_to_date   IN VARCHAR2 DEFAULT NULL -- Optional Param default NULL
  ,p_full_refresh      IN VARCHAR2 DEFAULT NULL -- Optional Param default NULL
  ,p_attribute1        IN VARCHAR2 DEFAULT NULL -- Optional Param default NULL
  ,p_attribute2        IN VARCHAR2 DEFAULT NULL -- Optional Param default NULL
  )
IS
  --
BEGIN
  --
  -- Do not pass throuh IN parameters, as they are not used.
  --
  dbg('Entering the default collection process,'||
         ' called when foundation HR is detected.');
  shared_hrms_dflt_prcss;
  --
EXCEPTION
  WHEN OTHERS
  THEN
    --
    errbuf := SQLERRM;
    retcode := SQLCODE;
    --
    RAISE;
    --
  --
END shared_hrms_dflt_prcss;
--
-- -----------------------------------------------------------------------------
--                         Multithreading Calls                               --
-- -----------------------------------------------------------------------------
-- The Multithreading Utility Provides the Framework for processing collection
-- using multiple threads. The utility dynamically invokes the following
-- procedure to complete the collection process
--   a) Invoke the PRE_PROCESS procedure to
--         Initialize the global variables
--         Manage the Indexes, MV logs and Trigger
--         Return a SQL based on which the processing ranges will be created.
--
--      In case of Foundation HR environment the pre-process will not return
--      any SQL. This will prompt the mulithtreading utility to stop processing
--      without invoking the PROCESS_RANGE and POST_PROCESS procedures.
--   b) Invoke the PROCESS_RANGE procedure to process the assignments in the range.
--      This procedure will be invoked by all the threads that are running in
--      parallel.
--   c) Invoke the POST_PROCESS procedure to perform the post processing tasks
--         Initialize the global variables
--         Manage the Indexes, MV logs and Trigger
--         Update BIS refresh Log table
-- ----------------------------------------------------------------------------
-- SET_PARAMETERS
-- sets up global variables required for the assignment events process
-- ----------------------------------------------------------------------------
--
PROCEDURE set_parameters(p_mthd_action_id   IN NUMBER,
                         p_mthd_stage_code  IN VARCHAR2) IS
 --
 l_assignment_id  NUMBER;
 --
BEGIN

  -- If parameters haven't already been set, then set them
  IF (g_refresh_start_date IS NULL) THEN

    g_dbi_collection_start_date := hri_oltp_conc_param.get_date_parameter_value
                                    (p_parameter_name     => 'FULL_REFRESH_FROM_DATE',
                                     p_process_table_name => 'HRI_MB_ASGN_EVENTS_CT');

    -- If called for the first time set the defaulted parameters
    IF (p_mthd_stage_code = 'PRE_PROCESS') THEN

      g_full_refresh := hri_oltp_conc_param.get_parameter_value
                         (p_parameter_name     => 'FULL_REFRESH',
                          p_process_table_name => 'HRI_MB_ASGN_EVENTS_CT');

      -- Log defaulted parameters so the slave processes pick up
      hri_opl_multi_thread.update_parameters
       (p_mthd_action_id    => p_mthd_action_id,
        p_full_refresh      => g_full_refresh,
        p_global_start_date => g_dbi_collection_start_date);

    END IF;

    g_mthd_action_array    := hri_opl_multi_thread.get_mthd_action_array
                               (p_mthd_action_id);
    --
    g_full_refresh         := g_mthd_action_array.full_refresh_flag;
    g_refresh_start_date   := g_mthd_action_array.collect_from_date;
    g_refresh_end_date     := hr_general.end_of_time;

    -- Set FTE/HDC parameters from profiles
    IF (fnd_profile.value('HRI_COLLECT_FTE') = 'Y') THEN
      g_collect_fte := 'Y';
    ELSE
      g_collect_fte := 'N';
    END IF;
    IF (fnd_profile.value('HRI_COLLECT_HDC') = 'Y') THEN
      g_collect_hdc := 'Y';
    ELSE
      g_collect_hdc := 'N';
    END IF;

    -- Set DBI parameters
    IF (fnd_profile.value('HRI_IMPL_DBI') = 'Y') THEN
      g_implement_dbi        := 'Y';
    END IF;

    -- Set OBIEE parameters
    IF (fnd_profile.value('HRI_IMPL_OBIEE') = 'Y') THEN
      g_implement_obiee      := 'Y';
      IF (fnd_profile.value('HRI_COL_SUP_HRCHY_EQ') = 'Y') THEN
        g_implement_obiee_mgrh := 'Y';
      ELSE
        g_implement_obiee_mgrh := 'N';
      END IF;
      IF (fnd_profile.value('HRI_COL_ORG_HRCHY_EQ') = 'Y') THEN
        g_implement_obiee_orgh := 'Y';
      ELSE
        g_implement_obiee_orgh := 'N';
      END IF;
    ELSE
      g_implement_obiee      := 'N';
      g_implement_obiee_mgrh := 'N';
      g_implement_obiee_orgh := 'N';
    END IF;

    hri_bpl_conc_log.dbg('Full refresh:   ' || g_full_refresh);
    hri_bpl_conc_log.dbg('Collect from:   ' || to_char(g_refresh_start_date));
    --
    -- Set the global variable to the performance rating query
    --
    BEGIN
      g_perf_query := hri_bpl_perf_rating.get_perf_sql;
    EXCEPTION WHEN OTHERS THEN
      g_msg_sub_group := NVL(g_msg_sub_group, 'GET_PERF_SQL');
      RAISE;
    END;
    --
  --
  END IF;
--
END set_parameters;
--
-- ----------------------------------------------------------------------------
-- PRE_PROCESS
-- This procedure includes the logic required for performing the pre_process
-- task of HRI multithreading utility.
-- ----------------------------------------------------------------------------
--
PROCEDURE PRE_PROCESS(
  p_mthd_action_id    IN NUMBER,
  p_sqlstr            OUT NOCOPY VARCHAR2) IS
  --
  l_dummy1           VARCHAR2(2000);
  l_dummy2           VARCHAR2(2000);
  l_schema           VARCHAR2(400);
  l_message       fnd_new_messages.message_text%type;
--
BEGIN
  --
  -- Initialize the global to hold the procedure name
  --
  -- Record the process start
  -- Set up the parameters
  --
  set_parameters
   (p_mthd_action_id  => p_mthd_action_id,
    p_mthd_stage_code => 'PRE_PROCESS');
  --
  -- Feedback parameters selected
  --
  dbg('Parameters selected:');
  dbg('  Full Refresh:     ' || g_full_refresh);
  dbg('  Collect HEAD:     ' || g_collect_hdc);
  dbg('  Collect FTE:      ' || g_collect_fte);
  --
  -- Raise a ff compile error if either of the seeded ffs to be used are not
  -- compiled (these are not used in shared HR mode)
  --
  IF (g_mthd_action_array.foundation_hr_flag = 'N') THEN
    IF (g_collect_fte = 'Y') THEN
      --
      hri_bpl_abv.check_ff_name_compiled( p_formula_name => 'TEMPLATE_FTE' );
      --
    END IF;
    --
    IF (g_collect_hdc = 'Y') THEN
      --
      hri_bpl_abv.check_ff_name_compiled( p_formula_name => 'TEMPLATE_HEAD' );
      --
    END IF;
  END IF;
  --
  -- Disable the WHO trigger
  --
  EXECUTE IMMEDIATE 'ALTER TRIGGER HRI_MB_ASGN_EVENTS_CT_WHO DISABLE';
  EXECUTE IMMEDIATE 'ALTER TRIGGER HRI_MDP_ORGH_TRANSFERS_CT_WHO DISABLE';
  --
  -- ---------------------------------------------------------------------------
  -- Full Refresh Section (including shared HR)
  -- ---------------------------------------------------------------------------
  --
  IF (fnd_installation.get_app_info('HRI',l_dummy1, l_dummy2, l_schema)) THEN
    --
    -- If it's a full refresh or shared HR
    --
    IF (g_full_refresh = 'Y' OR
        g_mthd_action_array.foundation_hr_flag = 'Y') THEN
      --
      -- Drop Indexes
      --
      hri_utl_ddl.log_and_drop_indexes(
                        p_application_short_name => 'HRI',
                        p_table_name    => 'HRI_MB_ASGN_EVENTS_CT',
                        p_table_owner   => l_schema);
      hri_utl_ddl.log_and_drop_indexes(
                        p_application_short_name => 'HRI',
                        p_table_name    => 'HRI_MDP_ORGH_TRANSFERS_CT',
                        p_table_owner   => l_schema);
      --
      -- Truncate the tables
      --
      EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || l_schema || '.HRI_MB_ASGN_EVENTS_CT';
      EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || l_schema || '.HRI_MDP_ORGH_TRANSFERS_CT';
      --
      -- In shared HR mode populate the table in a single direct insert
      -- Do not return a SQL statement so that the process_range and
      -- post_process will not be executed
      --
      IF (g_mthd_action_array.foundation_hr_flag = 'Y') THEN
        --
        -- Call API to insert rows
        --
        shared_hrms_dflt_prcss;
        --
        -- Call post processing API
        --
        POST_PROCESS(p_mthd_action_id => p_mthd_action_id);
        --
      --
      -- Else full refresh in full HR mode
      --
      ELSE
        --
        --
        -- Select all people with employee assignments in the collection range.
        -- The bind variable must be present for this sql to work when called
        -- by PYUGEN, else itwill give error.
        --
        p_sqlstr :=
          'SELECT  /*+ PARALLEL(asgn, DEFAULT, DEFAULT) */
                   DISTINCT
                   asgn.assignment_id object_id
          FROM     per_all_assignments_f   asgn
          WHERE    asgn.assignment_type in (''E'',''C'')
          AND      asgn.effective_end_date >= to_date(''' ||
                       to_char(g_refresh_start_date, 'DD-MM-YYYY') ||
                       ''',''DD-MM-YYYY'') - 1
          ORDER BY asgn.assignment_id';
        --
      END IF;
    --
    -- Return the Incremental Refresh SQL based on the asg events queue
    --
    ELSE
      --
      -- Insert the period of work related incremental chnages to the assignment
      -- events queue.
      --
      insert_pow_change_events;
      --
      -- Populate workforce event queues
      --
      populate_wrkfc_evt_eq;
      populate_wrkfc_evt_mgrh_eq;
      populate_wrkfc_evt_orgh_eq;
      --
      -- Select all people  for whom events have occurred. The bind variable must
      -- be present for this sql to work when called by PYUGEN, else it will
      -- give error.
      --
      p_sqlstr :=
        'SELECT /*+ PARALLEL(evt, DEFAULT, DEFAULT) */
                evt.assignment_id object_id
         FROM   hri_eq_asgn_evnts evt
         ORDER  BY evt.assignment_id';
      --
    END IF;
    --
  END IF;
  --
EXCEPTION
  --
  WHEN others THEN
    --
    dbg('Exception raised in procedure PRE_PROCESS');
    --
    l_message := nvl(fnd_message.get,sqlerrm);
    --
    dbg(l_message);
    --
    -- Bug 4105868: Collection Diagnostic Call
    --
    g_msg_sub_group := NVL(g_msg_sub_group, 'PRE_PROCESS');
    --
    hri_bpl_conc_log.log_process_info
            (p_package_name  => 'HRI_OPL_ASGN_EVENTS'
            ,p_msg_type      => 'ERROR'
            ,p_note          => l_message
            ,p_msg_group     => 'ASG_EVT_FCT'
            ,p_msg_sub_group => g_msg_sub_group
            ,p_sql_err_code  => SQLCODE);
    --
    raise;
    --
--
END PRE_PROCESS;
--
-- ----------------------------------------------------------------------------
-- PROCESS_RANGE
-- This procedure includes the logic required for processing the assignments
-- which have been included in the range. It is dynamically invoked by the
-- multithreading child process. It manages the multithreading ranges and
-- for each range it invokes the overaloaded process_range procedure defined below.
-- ----------------------------------------------------------------------------
--
PROCEDURE process_range(
   errbuf                          OUT NOCOPY VARCHAR2
  ,retcode                         OUT NOCOPY NUMBER
  ,p_mthd_action_id            IN             NUMBER
  ,p_mthd_range_id             IN             NUMBER
  ,p_start_object_id           IN             NUMBER
  ,p_end_object_id             IN             NUMBER)
IS
  --
  l_sql               VARCHAR2(2000);
  l_assignment_id     NUMBER;
  l_change_date       DATE;
  l_error_step        NUMBER;
  l_mthd_range_id     NUMBER;
  l_start_object_id   NUMBER;
  l_end_object_id     NUMBER;
  --
BEGIN
  --
  --
  --
  set_parameters
   (p_mthd_action_id  => p_mthd_action_id,
    p_mthd_stage_code => 'PROCESS_RANGE');
  --
  dbg('calling process_range code');
  process_range(p_object_range_id    => p_mthd_range_id
                ,p_start_object_id   => p_start_object_id
                ,p_end_object_id     => p_end_object_id);
  --
  IF g_raise_warning = 'Y' THEN
    --
    errbuf  := 'SUCCESS';
    retcode := 0;
    --
  ELSE
    --
    errbuf  := 'SUCCESS';
    retcode := 0;
    --
  END IF;
  --
EXCEPTION
  when hri_opl_multi_thread.other_thread_in_error THEN
    --
    errbuf  := SQLERRM;
    retcode := 2;
    --
    raise hri_opl_multi_thread.child_process_failure;
  when others then
    --
    dbg('Error at step '||l_error_step );
    output(sqlerrm);
    --
    errbuf := SQLERRM;
    retcode := SQLCODE;
    --
    raise;
    --
  --
END process_range;
--
-- ----------------------------------------------------------------------------
-- PROCESS_RANGE
-- This is an overloaded procedure which is invoked by PROCESS_RANGE above.
-- For each of the assignment in the range, this procedure invokes the
-- collect procedure to populate the assingment events fact table.
-- ----------------------------------------------------------------------------
--
PROCEDURE process_range(
   p_object_range_id   IN NUMBER
  ,p_start_object_id   IN NUMBER
  ,p_end_object_id     IN NUMBER )
IS
  --
  -- Cursor to get the assignment_id for the assignment action for full refresh
  --
  -- Declare the ref cursor
  --
  type asg_to_process is ref cursor;
  --
  c_asg_to_process    ASG_TO_PROCESS;
  --
  -- Holds assignment from the cursor
  --
  l_assignment_id     NUMBER;
  l_change_date       DATE;
  l_error_step        NUMBER;
  l_message           fnd_new_messages.message_text%type;
  l_system_date       DATE;
  --
  -- PL/SQL of rows to insert into database table for the range
  --
  l_asgn_events_tab   g_asgn_events_tab_type;
  --
BEGIN
  --
  dbg('Inside Process_Range');
  --
  l_system_date       := TRUNC(SYSDATE);
  hri_opl_wrkfc_trnsfr_events.initialize_globals;
  --
  -- Depending on the type of refresh, open the ref cursor to determine the assignments
  -- in a range.
  --
  IF (g_full_refresh = 'Y') THEN
    --
    l_error_step := 30;
    --
    OPEN c_asg_to_process FOR
         SELECT DISTINCT
                asg.assignment_id  assignment_id,
                l_system_date     change_date
         FROM   per_all_assignments_f   asg
                ,per_assignment_status_types  ast
         WHERE  asg.assignment_type in ('E','C')
         AND    asg.assignment_id BETWEEN p_start_object_id and p_end_object_id
         AND    ast.assignment_status_type_id = asg.assignment_status_type_id
         AND    ast.per_system_status <> 'TERM_ASSIGN'
         AND    asg.effective_end_date >= g_refresh_start_date - 1;
    --
  ELSE
    --
    -- Open the ref cursor for incremental assingments events. For incremental
    -- collection the range is created based on the events queue.
    --
    l_error_step := 40;
    --
    -- Bug 4299875
    -- The query for determining the list of assingments in the range should
    -- not connect to asg table as this prevents some of the records from
    -- getting processed e.g. when the person record is delete etc.
    --
    OPEN c_asg_to_process FOR
         SELECT DISTINCT
                evts.assignment_id        assignment_id,
                erlst_evnt_effective_date change_date
         FROM   hri_eq_asgn_evnts evts
         WHERE  evts.assignment_id BETWEEN p_start_object_id and p_end_object_id;
    --
  END IF;
  --
  l_error_step := 50;
  --
  -- Collect the assignment event details for every assingment in the
  -- multithreading range.
  --
  LOOP
    --
    FETCH c_asg_to_process INTO l_assignment_id,l_change_date;
    EXIT WHEN c_asg_to_process%NOTFOUND;
    --
    IF g_full_refresh = 'N' THEN
       --
       g_refresh_start_date := l_change_date;
       --
    END IF;
    --
    dbg('asg = '||l_assignment_id||' l_change_date= '||l_change_date);
    --
    BEGIN
      --
      -- Call the collect procedure which collects the assignments events
      -- records for the assignment
      --
      COLLECT
       (p_assignment_id   => l_assignment_id,
        p_asgn_events_tab => l_asgn_events_tab);
      --
    EXCEPTION
      --
      WHEN hri_bpl_abv.ff_not_compiled OR
           hri_bpl_perf_rating.ff_returned_invalid_value OR
           hri_bpl_perf_rating.ff_perf_rating_not_compiled
      THEN
        --
        -- Incase the fast fromula raises an exception then raise the error
        --
        l_message := fnd_message.get;
        --
        output(l_message);
        --
        raise;
        --
      WHEN NO_ASSIGNMENT_RECORD_FOUND THEN
        --
        -- Bug 4299875
        -- This exception is raised by procedure identify_assignment_changes
        -- when no records are found for assignment that are valid on the
        -- event date. This will occur in following cases
        --    a. The assignment is not a employee or congtingent asg
        --    b. The persson has been terminated and asg rec is updated
        --       after the termination date
        -- Details pertaining to such events need not be tracked in assignment
        -- event fact and can be rejected. Therefore do not throw any error
        --
        dbg('No valid assignment records found for assignment_id = '||g_assignment_id);
        --
      WHEN OTHERS THEN
        --
        g_raise_warning := 'Y';
        --
        fnd_message.set_name('HRI', 'HRI_407288_NO_ASG_RCRD_FND');
        fnd_message.set_token('ASSIGNMENT_ID', g_assignment_id);
        --
        l_message := fnd_message.get;
        --
        output(l_message);
        output(sqlerrm);
        --
        g_msg_sub_group := NVL(g_msg_sub_group, 'PROCESS_RANGE');
        --
        hri_bpl_conc_log.log_process_info
                (p_package_name  => 'HRI_OPL_ASGN_EVENTS'
                ,p_msg_type      => 'WARNING'
                ,p_note          => l_message
                ,p_msg_group     => 'ASG_EVT_FCT'
                ,p_msg_sub_group => g_msg_sub_group
                ,p_assignment_id   => g_assignment_id
                ,p_sql_err_code  => SQLCODE
                );
        --
    END;
    --
  END LOOP;
  --
  dbg('Done processing all assignments in the range.');
  --
  IF c_asg_to_process%ISOPEN THEN
    --
    l_error_step := 60;
    CLOSE c_asg_to_process;
    --
  END IF;
  --
  -- If incremental refresh
  --
  IF g_full_refresh = 'N' then
    --
    -- 5A Delete Records
    -- Delete all the records from the table HRI_MB_ASGN_EVENTS that starts on
    -- or after the refresh start date
    --
    DELETE_RECORDS
     (p_start_assignment_id => p_start_object_id,
      p_end_assignment_id   => p_end_object_id);
    hri_opl_wrkfc_trnsfr_events.delete_transfers
     (p_start_object_id => p_start_object_id,
      p_end_object_id   => p_end_object_id);
    --
  END IF;
  --
  -- Bulk insert stored rows
  --
  bulk_insert_rows(p_asgn_events_tab => l_asgn_events_tab);
  --
  hri_opl_wrkfc_trnsfr_events.bulk_insert_transfers;
  --
  -- Commit
  Commit;
  --
EXCEPTION
  WHEN OTHERS THEN
    --
    --
    -- Set the warning global so the request raises a warning
    --
    g_raise_warning := 'Y';
    output('WARNING: Error processing assignment_id ' || TO_CHAR(g_assignment_id));
    output(sqlerrm);
    --
    IF c_asg_to_process%ISOPEN THEN
      --
      l_error_step := 60;
      CLOSE c_asg_to_process;
      --
    END IF;
    --
    -- Bug 4105868: Collection Diagnostic Call
    --
    g_msg_sub_group := NVL(g_msg_sub_group, 'PROCESS_RANGE');
    --
    hri_bpl_conc_log.log_process_info
            (p_package_name  => 'HRI_OPL_ASGN_EVENTS'
            ,p_msg_type      => 'ERROR'
            ,p_note          => nvl(l_message, SQLERRM)
            ,p_msg_group     => 'ASG_EVT_FCT'
            ,p_msg_sub_group => g_msg_sub_group
            ,p_sql_err_code  => SQLCODE);
    --
    RAISE;
--
END process_range;
--
-- ----------------------------------------------------------------------------
-- POST_PROCESS
-- This procedure is dynamically invoked by the HRI Multithreading utility.
-- It performs all the clean up action for assignment events collection program
-- like  Instate the indexes and triggers
--       Enable the MV logs
--       Purge the assignment events incremental events queue
--       Update BIS Refresh Log
-- ----------------------------------------------------------------------------
--
PROCEDURE post_process (p_mthd_action_id NUMBER) IS
  --
  l_dummy1           VARCHAR2(2000);
  l_dummy2           VARCHAR2(2000);
  l_schema           VARCHAR2(400);
  --
--
BEGIN
  --
  dbg('Inside post_process');
  --
  set_parameters
   (p_mthd_action_id  => p_mthd_action_id,
    p_mthd_stage_code => 'POST_PROCESS');
  --
  hri_bpl_conc_log.record_process_start('HRI_MB_ASGN_EVENTS_CT');
  --
  -- Recreate indexes and gather stats for full refresh or shared HR insert
  --
  IF (g_full_refresh = 'Y' OR
      g_mthd_action_array.foundation_hr_flag = 'Y') THEN
    --
    IF (fnd_installation.get_app_info('HRI',l_dummy1, l_dummy2, l_schema)) THEN
      --
      dbg('Full Refresh selected - Creating indexes');
      --
      HRI_UTL_DDL.recreate_indexes(
                        p_application_short_name => 'HRI',
                        p_table_name    => 'HRI_MB_ASGN_EVENTS_CT',
                        p_table_owner   => l_schema);
      hri_utl_ddl.recreate_indexes(
                        p_application_short_name => 'HRI',
                        p_table_name    => 'HRI_MDP_ORGH_TRANSFERS_CT',
                        p_table_owner   => l_schema);
      --
      dbg('Full Refresh selected - gathering stats');
      --
      fnd_stats.gather_table_stats(l_schema,'HRI_MB_ASGN_EVENTS_CT');
      --
    END IF;
    --
  ELSE
    --
    -- 4259598 Incremental Changes
    -- Populate the assignment event delta queue in order to incrementally refresh
    -- the assignment delta table
    --
    dbg('populating the assignment delta events queue...');
    --
    populate_asg_delta_eq;
    --
  END IF;
  --
  -- Enable the WHO trigger on the events fact table
  --
  dbg('Enabling the who trigger');
  EXECUTE IMMEDIATE 'ALTER TRIGGER HRI_MB_ASGN_EVENTS_CT_WHO ENABLE';
  EXECUTE IMMEDIATE 'ALTER TRIGGER HRI_MDP_ORGH_TRANSFERS_CT_WHO ENABLE';
  --
  -- Purge the Events Queue. The events queue needs to be purged
  -- even after the after full refresh. Recollecting incremental changes
  -- will be useless if a full refresh has been run.
  --
  dbg('Purging the events queue');
  hri_opl_event_capture.purge_queue('HRI_EQ_ASGN_EVNTS');
  --
  hri_bpl_conc_log.log_process_end(
     p_status         => TRUE
    ,p_period_from    => TRUNC(g_refresh_start_date)
    ,p_period_to      => TRUNC(SYSDATE)
    ,p_attribute1     => g_collect_fte
    ,p_attribute2     => g_collect_hdc
    ,p_attribute3     => g_full_refresh);
  --
  dbg('Exiting post_process');
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    g_msg_sub_group := NVL(g_msg_sub_group, 'POST_PROCESS');
    --
    hri_bpl_conc_log.log_process_info
            (p_package_name  => 'HRI_OPL_ASGN_EVENTS'
            ,p_msg_type      => 'ERROR'
            ,p_note          => SQLERRM
            ,p_msg_group     => 'ASG_EVT_FCT'
            ,p_msg_sub_group => g_msg_sub_group
            ,p_sql_err_code  => SQLCODE);
    --
    RAISE;
    --
END post_process;
--
-- -----------------------------------------------------------------------------
-- Debugging procedure to run for a single assignment
-- -----------------------------------------------------------------------------
--
PROCEDURE run_for_asg(p_assignment_id  IN NUMBER) IS
--
l_asgn_events_tab  g_asgn_events_tab_type;
--
BEGIN
  --
  g_refresh_start_date   := g_dbi_collection_start_date;
  g_refresh_end_date     := hr_general.end_of_time;
  g_full_refresh         := 'Y';
  g_collect_fte          := 'N';
  g_collect_hdc          := 'Y';
  g_perf_query           := hri_bpl_perf_rating.get_perf_sql;
  --
  DELETE
  FROM   hri_mb_asgn_events_ct
  WHERE  assignment_id = p_assignment_id;
  --
  collect(p_assignment_id  => p_assignment_id,
          p_asgn_events_tab => l_asgn_events_tab) ;
  --
  bulk_insert_rows(l_asgn_events_tab);
  --
  COMMIT;
  --
END run_for_asg;
--
-- Initialization Block
--
BEGIN
  --
  g_dbi_collection_start_date  := bis_common_parameters.get_global_start_date;
  g_end_of_time                := hr_general.end_of_time;
  --
  -- This profile is used for POW calculations.
  --
  g_adj_svc_profile            := NVL(fnd_profile.value('HRI_POW_DT_STRT_SRC'),'STRT_DT');
  --
  -- For future usage
  --
  g_collect_perf_rating        := 'Y';
  g_collect_prsn_typ           := 'Y';
  --
  -- Not Rated records should have the performance band set to -5
  --
  g_perf_not_rated_id          := hri_bpl_dimension_utilities.get_not_rated_id;
  --
  -- CAUTION : Don't change the underlying intialization. Used in dynamic SQL
  --
  g_rtn :=  '
  ';
  --
END HRI_OPL_ASGN_EVENTS;

/
