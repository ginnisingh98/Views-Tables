--------------------------------------------------------
--  DDL for Package Body HRI_OPL_UTL_ABSNC_FACT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OPL_UTL_ABSNC_FACT" AS
/* $Header: hriouabf.pkb 120.5 2005/11/16 01:03:14 jtitmas noship $ */

  -- Simple table types
  TYPE g_date_tab_type IS TABLE OF DATE INDEX BY BINARY_INTEGER;
  TYPE g_number_tab_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE g_varchar2_tab_type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

  -- PL/SQL table representing database table
  g_tab_abs_sk_fk        g_number_tab_type;
  g_tab_effective_date   g_date_tab_type;
  g_tab_drtn_days        g_number_tab_type;
  g_tab_drtn_hours       g_number_tab_type;
  g_tab_start_ind        g_number_tab_type;
  g_tab_end_ind          g_number_tab_type;
  g_tab_ntfctn_blnc      g_number_tab_type;
  g_tab_abs_prsn_id      g_number_tab_type;
  g_tab_index            PLS_INTEGER;

  -- End of time
  g_end_of_time                DATE := hr_general.end_of_time;

  -- Global HRI Multithreading Array
  g_mthd_action_array          HRI_ADM_MTHD_ACTIONS%rowtype;

  -- Rounding constant
  g_rounding                   NUMBER := 15;

  -- Global parameters
  g_refresh_start_date         DATE;
  g_full_refresh               VARCHAR2(30);
  g_dbi_collection_start_date  DATE;
  g_sysdate                    DATE;
  g_user                       NUMBER;

-- ----------------------------------------------------------------------------
-- Runs given sql statement dynamically
-- ----------------------------------------------------------------------------
PROCEDURE run_sql_stmt_noerr(p_sql_stmt   VARCHAR2) IS

BEGIN

  EXECUTE IMMEDIATE p_sql_stmt;

EXCEPTION WHEN OTHERS THEN

  null;

END run_sql_stmt_noerr;

-- ----------------------------------------------------------------------------
-- Sets global parameters from multi-threading process parameters
-- ----------------------------------------------------------------------------
PROCEDURE set_parameters(p_mthd_action_id   IN NUMBER,
                         p_mthd_stage_code  IN VARCHAR2) IS

BEGIN

-- If parameters haven't already been set, then set them
  IF (g_refresh_start_date IS NULL OR
      p_mthd_stage_code = 'PRE_PROCESS') THEN

    g_dbi_collection_start_date :=
              hri_oltp_conc_param.get_date_parameter_value
               (p_parameter_name     => 'FULL_REFRESH_FROM_DATE',
                p_process_table_name => 'HRI_MB_UTL_ABSNC_CT');

    -- If called for the first time set the defaulted parameters
    IF (p_mthd_stage_code = 'PRE_PROCESS') THEN

      g_full_refresh :=
              hri_oltp_conc_param.get_parameter_value
               (p_parameter_name     => 'FULL_REFRESH',
                p_process_table_name => 'HRI_MB_UTL_ABSNC_CT');

      -- Log defaulted parameters so the slave processes pick up
      hri_opl_multi_thread.update_parameters
       (p_mthd_action_id    => p_mthd_action_id,
        p_full_refresh      => g_full_refresh,
        p_global_start_date => g_dbi_collection_start_date);

    END IF;

    g_mthd_action_array    := hri_opl_multi_thread.get_mthd_action_array
                               (p_mthd_action_id);
    g_refresh_start_date   := g_mthd_action_array.collect_from_date;
    g_full_refresh := g_mthd_action_array.full_refresh_flag;
    g_sysdate := sysdate;
    g_user := fnd_global.user_id;
    g_end_of_time := hr_general.end_of_time;

    hri_bpl_conc_log.dbg('Full refresh:   ' || g_full_refresh);
    hri_bpl_conc_log.dbg('Collect from:   ' ||
                         to_char(g_dbi_collection_start_date));
  END IF;

END set_parameters;

-- ----------------------------------------------------------------------------
-- Inserts a record into the global pl/sql table
-- ----------------------------------------------------------------------------
PROCEDURE insert_fact_record(p_abs_sk_fk       IN NUMBER,
                             p_effective_date  IN DATE,
                             p_drtn_days       IN NUMBER,
                             p_drtn_hours      IN NUMBER,
                             p_start_ind       IN NUMBER,
                             p_end_ind         IN NUMBER,
                             p_ntfctn_blnc     IN NUMBER,
                             p_abs_prsn_id     IN NUMBER) IS

BEGIN

  -- Increment index and store new row
  g_tab_index := g_tab_index + 1;
  g_tab_abs_sk_fk(g_tab_index)      := p_abs_sk_fk;
  g_tab_effective_date(g_tab_index) := p_effective_date;
  g_tab_drtn_days(g_tab_index)      := p_drtn_days;
  g_tab_drtn_hours(g_tab_index)     := p_drtn_hours;
  g_tab_start_ind(g_tab_index)      := p_start_ind;
  g_tab_end_ind(g_tab_index)        := p_end_ind;
  g_tab_ntfctn_blnc(g_tab_index)    := p_ntfctn_blnc;
  g_tab_abs_prsn_id(g_tab_index)    := p_abs_prsn_id;

END insert_fact_record;

-- ----------------------------------------------------------------------------
-- Bulk inserts from pl/sql table to database table
-- ----------------------------------------------------------------------------
PROCEDURE bulk_insert_rows IS

BEGIN

  -- Set constants
  g_sysdate := sysdate;
  g_user := fnd_global.user_id;

  -- Bulk insert rows if any exist
  IF g_tab_index > 0 THEN

    FORALL i IN 1..g_tab_index
     INSERT INTO hri_mb_utl_absnc_ct
     (absence_sk_fk
     ,effective_date
     ,abs_drtn_days
     ,abs_drtn_hrs
     ,abs_blnc_ind
     ,abs_start_ind
     ,abs_end_ind
     ,abs_ntfctn_days_blnc
     ,abs_person_id
     ,last_update_date
     ,last_updated_by
     ,last_update_login
     ,created_by
     ,creation_date)
     VALUES
      (g_tab_abs_sk_fk(i),
       g_tab_effective_date(i),
       g_tab_drtn_days(i),
       g_tab_drtn_hours(i),
       1,
       g_tab_start_ind(i),
       g_tab_end_ind(i),
       g_tab_ntfctn_blnc(i),
       g_tab_abs_prsn_id(i),
       g_sysdate,
       g_user,
       g_user,
       g_user,
       g_sysdate);

    -- Commit
    COMMIT;

  END IF;

  -- Reset index
  g_tab_index := 0;

END bulk_insert_rows;

-- -----------------------------------------------------------------------------
-- Processes either:
--    FULL REFRESH - All absences for a person within collection range
--    INCR REFRESH - All absences within given range of absence ids
--
-- The corresponding input parameters should be set, either
--    p_person_id - for full refresh
--  OR
--   p_start/end_abs_id - for incr refresh
--  NOT BOTH
--
-- Pushing down of day into absence occurs in PL/SQL to reduce buffer reads
-- -----------------------------------------------------------------------------
PROCEDURE process_set(p_person_id     IN NUMBER,
                      p_start_abs_id  IN NUMBER,
                      p_end_abs_id    IN NUMBER) IS

  -- Absence details per person
  CURSOR full_absence_csr IS
  SELECT
   dim.absence_sk_pk                    absence_sk_fk
  ,GREATEST(dim.abs_start_date, g_dbi_collection_start_date)
                                        start_date
  ,LEAST(NVL(dim.abs_end_date, TRUNC(SYSDATE)),
         TRUNC(SYSDATE))                end_date
  ,dim.abs_start_date                   start_date_actual
  ,dim.abs_end_date                     end_date_actual
  ,ROUND(CASE WHEN dim.abs_end_date = g_end_of_time
              THEN dim.abs_drtn_days / (trunc(sysdate) - dim.abs_start_date + 1)
              ELSE dim.abs_drtn_days / (dim.abs_end_date - dim.abs_start_date + 1)
         END, g_rounding)               abs_drtn_days
  ,ROUND(CASE WHEN dim.abs_end_date = g_end_of_time
              THEN dim.abs_drtn_hrs / (trunc(sysdate) - dim.abs_start_date + 1)
              ELSE dim.abs_drtn_hrs / (dim.abs_end_date - dim.abs_start_date + 1)
         END, g_rounding)               abs_drtn_hrs
  ,CASE WHEN (dim.abs_start_date < dim.abs_notification_date)
        THEN 0
        ELSE dim.abs_start_date - dim.abs_notification_date
   END                                  abs_ntfctn_days_blnc
  ,dim.abs_person_id                    abs_person_id
  FROM
   hri_cs_absence_ct  dim
  WHERE dim.abs_person_id = p_person_id
  AND dim.abs_start_date <= trunc(sysdate);

  -- Absence details per absence range
  CURSOR incr_absence_csr IS
  SELECT
   dim.absence_sk_pk                    absence_sk_fk
  ,GREATEST(dim.abs_start_date, g_dbi_collection_start_date)
                                        start_date
  ,LEAST(NVL(dim.abs_end_date, TRUNC(SYSDATE)),
         TRUNC(SYSDATE))                end_date
  ,dim.abs_start_date                   start_date_actual
  ,dim.abs_end_date                     end_date_actual
  ,ROUND(CASE WHEN dim.abs_end_date = g_end_of_time
              THEN dim.abs_drtn_days / (trunc(sysdate) - dim.abs_start_date + 1)
              ELSE dim.abs_drtn_days / (dim.abs_end_date - dim.abs_start_date + 1)
         END, g_rounding)               abs_drtn_days
  ,ROUND(CASE WHEN dim.abs_end_date = g_end_of_time
              THEN dim.abs_drtn_hrs / (trunc(sysdate) - dim.abs_start_date + 1)
              ELSE dim.abs_drtn_hrs / (dim.abs_end_date - dim.abs_start_date + 1)
         END, g_rounding)               abs_drtn_hrs
  ,CASE WHEN (dim.abs_start_date < dim.abs_notification_date)
        THEN 0
        ELSE dim.abs_start_date - dim.abs_notification_date
   END                                  abs_ntfctn_days_blnc
  ,dim.abs_person_id                    abs_person_id
  FROM
   hri_cs_absence_ct      dim
  ,hri_eq_utl_absnc_fact  eq
  WHERE dim.absence_sk_pk = eq.absence_sk_fk
  AND eq.absence_sk_fk BETWEEN p_start_abs_id
                       AND p_end_abs_id
  AND dim.abs_start_date <= trunc(sysdate);

  -- Number of days spanned by absences
  l_abs_length       NUMBER;

  -- Indicators
  l_abs_start_ind    PLS_INTEGER;
  l_abs_end_ind      PLS_INTEGER;

  -- PL/SQL table for cursor fetch
  l_abs_sk_fk            g_number_tab_type;
  l_abs_start_date       g_date_tab_type;
  l_abs_end_date         g_date_tab_type;
  l_abs_start_date_act   g_date_tab_type;
  l_abs_end_date_act     g_date_tab_type;
  l_abs_drtn_days        g_number_tab_type;
  l_abs_drtn_hrs         g_number_tab_type;
  l_abs_ntfctn_blnc      g_number_tab_type;
  l_abs_person_id        g_number_tab_type;

BEGIN

  -- Split out full and incremental refresh
  IF (p_person_id IS NOT NULL) THEN

    -- Fetch records from full refresh cursor
    OPEN full_absence_csr;
    FETCH full_absence_csr BULK COLLECT INTO
      l_abs_sk_fk,
      l_abs_start_date,
      l_abs_end_date,
      l_abs_start_date_act,
      l_abs_end_date_act,
      l_abs_drtn_days,
      l_abs_drtn_hrs,
      l_abs_ntfctn_blnc,
      l_abs_person_id;
    CLOSE full_absence_csr;

  ELSE

    -- Fetch records from incremental refresh cursor
    OPEN incr_absence_csr;
    FETCH incr_absence_csr BULK COLLECT INTO
      l_abs_sk_fk,
      l_abs_start_date,
      l_abs_end_date,
      l_abs_start_date_act,
      l_abs_end_date_act,
      l_abs_drtn_days,
      l_abs_drtn_hrs,
      l_abs_ntfctn_blnc,
      l_abs_person_id;
    CLOSE incr_absence_csr;

  END IF;

  -- Check if rows were returned by cursor
  IF (l_abs_sk_fk.exists(1)) THEN

    -- Loop through absences in range
    FOR i IN l_abs_sk_fk.FIRST..l_abs_sk_fk.LAST LOOP

      -- How many days spanned by absence
      l_abs_length := l_abs_end_date(i) - l_abs_start_date(i) + 1;

      -- Loop through days in each absence
      FOR j IN 1..l_abs_length LOOP

        -- Set Indicators
        -- --------------
        -- Set/reset indicators to 0
        l_abs_start_ind := 0;
        l_abs_end_ind := 0;

        -- Check for start indicator
        IF (j = 1) THEN
          -- Start record on first day
          IF (l_abs_start_date_act(i) = l_abs_start_date(i)) THEN
            l_abs_start_ind := 1;
          ELSE
            l_abs_start_ind := 0;
          END IF;
        END IF;

        -- Check for end indicator
        IF (j = l_abs_length) THEN
          -- End record on last day
          IF (l_abs_end_date_act(i) = l_abs_end_date(i)) THEN
            l_abs_end_ind := 1;
          ELSE
            l_abs_end_ind := 0;
          END IF;
        END IF;

        -- Add fact row to PL/SQL table
        insert_fact_record
         (p_abs_sk_fk      => l_abs_sk_fk(i),
          p_effective_date => l_abs_start_date(i) + j - 1,
          p_drtn_days      => l_abs_drtn_days(i),
          p_drtn_hours     => l_abs_drtn_hrs(i),
          p_start_ind      => l_abs_start_ind,
          p_end_ind        => l_abs_end_ind,
          p_ntfctn_blnc    => l_abs_ntfctn_blnc(i),
          p_abs_prsn_id    => l_abs_person_id(i));

      END LOOP;

    END LOOP;

  END IF;

  -- Insert rows if a limit is reached
  IF (g_tab_index > 2000) THEN
    bulk_insert_rows;
  END IF;

END process_set;

-- ----------------------------------------------------------------------------
-- PROCESS_RANGE for incremental refresh
-- ----------------------------------------------------------------------------
PROCEDURE process_range_incr(p_start_abs_id    IN NUMBER,
                             p_end_abs_id      IN NUMBER) IS

BEGIN

  -- Delete old records
  DELETE FROM hri_mb_utl_absnc_ct fact
  WHERE fact.absence_sk_fk IN
   (SELECT eq.absence_sk_fk
    FROM hri_eq_utl_absnc_fact  eq
    WHERE eq.absence_sk_fk BETWEEN p_start_abs_id AND p_end_abs_id);

  -- Reset PL/SQL tables
  g_tab_index := 0;

  -- Process set of absences in range
  process_set
   (p_person_id    => to_number(null),
    p_start_abs_id => p_start_abs_id,
    p_end_abs_id   => p_end_abs_id);

  -- Insert rows
  bulk_insert_rows;

END process_range_incr;

-- ----------------------------------------------------------------------------
-- PROCESS_RANGE for full refresh
-- ----------------------------------------------------------------------------
PROCEDURE process_range_full(p_start_psn_id    IN NUMBER,
                             p_end_psn_id      IN NUMBER) IS

  -- Person in range
  CURSOR person_csr IS
  SELECT DISTINCT
   abs_person_id
  FROM hri_cs_absence_ct
  WHERE abs_person_id BETWEEN p_start_psn_id AND p_end_psn_id;

BEGIN

  -- Reset PL/SQL tables
  g_tab_index := 0;

  -- Loop through people in range
  FOR person_rec IN person_csr LOOP

    -- Process set of absences for each person
    process_set
     (p_person_id    => person_rec.abs_person_id,
      p_start_abs_id => to_number(null),
      p_end_abs_id   => to_number(null));

  END LOOP;

  -- Insert rows
  bulk_insert_rows;

END process_range_full;

-- ----------------------------------------------------------------------------
-- PROCESS_RANGE
-- This procedure includes the logic required for processing the assignments
-- which have been included in the range. It is dynamically invoked by the
-- multithreading child process. It manages the multithreading ranges.
-- ----------------------------------------------------------------------------
PROCEDURE process_range(errbuf             OUT NOCOPY VARCHAR2
                       ,retcode            OUT NOCOPY NUMBER
                       ,p_mthd_action_id   IN NUMBER
                       ,p_mthd_range_id    IN NUMBER
                       ,p_start_object_id  IN NUMBER
                       ,p_end_object_id    IN NUMBER) IS

BEGIN

-- Set the parameters
  set_parameters
   (p_mthd_action_id  => p_mthd_action_id,
    p_mthd_stage_code => 'PROCESS_RANGE');

-- Process range in corresponding refresh mode
  IF g_full_refresh = 'Y' THEN
    process_range_full
     (p_start_psn_id => p_start_object_id,
      p_end_psn_id   => p_end_object_id);
  ELSE
    process_range_incr
     (p_start_abs_id => p_start_object_id,
      p_end_abs_id   => p_end_object_id);
  END IF;

END process_range;

-- ----------------------------------------------------------------------------
-- Pre process entry point
-- ----------------------------------------------------------------------------
PROCEDURE pre_process(p_mthd_action_id  IN NUMBER,
                      p_sqlstr          OUT NOCOPY VARCHAR2) IS

  l_sql_stmt      VARCHAR2(2000);
  l_dummy1        VARCHAR2(2000);
  l_dummy2        VARCHAR2(2000);
  l_schema        VARCHAR2(400);

BEGIN

  -- Set parameter globals
  set_parameters
   (p_mthd_action_id  => p_mthd_action_id,
    p_mthd_stage_code => 'PRE_PROCESS');

  -- Get HRI schema name - get_app_info populates l_schema
  IF fnd_installation.get_app_info('HRI',l_dummy1, l_dummy2, l_schema) THEN
    null;
  END IF;

  -- Disable WHO trigger
  run_sql_stmt_noerr('ALTER TRIGGER HRI_MB_UTL_ABSNC_CT_WHO DISABLE');

  -- ********************
  -- Full Refresh Section
  -- ********************
  IF (g_full_refresh = 'Y' OR
      g_mthd_action_array.foundation_hr_flag = 'Y') THEN

    -- Empty out absence fact table
    l_sql_stmt := 'TRUNCATE TABLE ' || l_schema || '.HRI_MB_UTL_ABSNC_CT';
    EXECUTE IMMEDIATE(l_sql_stmt);

    -- In shared HR mode do not return a SQL statement so that the
    -- process_range and post_process will not be executed
    IF (g_mthd_action_array.foundation_hr_flag = 'Y') THEN

      -- Call post processing API
      post_process
       (p_mthd_action_id => p_mthd_action_id);

    ELSE

      -- Drop indexes
        hri_utl_ddl.log_and_drop_indexes
         (p_application_short_name => 'HRI',
          p_table_name             => 'HRI_MB_UTL_ABSNC_CT',
          p_table_owner            => l_schema);

      -- Set the SQL statement for the entire range
      p_sqlstr :=
        'SELECT /*+ PARALLEL(abs, DEFAULT, DEFAULT) */ DISTINCT
           abs.abs_person_id object_id
         FROM hri_cs_absence_ct abs
         ORDER BY abs.abs_person_id';

    END IF;

  ELSE

    -- Set the SQL statement for the incremental range
    p_sqlstr :=
      'SELECT /*+ PARALLEL(eq, DEFAULT, DEFAULT) */
         absence_sk_fk object_id
       FROM hri_eq_utl_absnc_fact eq
       ORDER BY absence_sk_fk';

  END IF;

END pre_process;

-- ----------------------------------------------------------------------------
-- Post process entry point
-- ----------------------------------------------------------------------------
PROCEDURE post_process(p_mthd_action_id NUMBER) IS

  l_sql_stmt      VARCHAR2(2000);
  l_dummy1        VARCHAR2(2000);
  l_dummy2        VARCHAR2(2000);
  l_schema        VARCHAR2(400);

BEGIN

  -- Check parameters are set
  set_parameters
   (p_mthd_action_id  => p_mthd_action_id,
    p_mthd_stage_code => 'POST_PROCESS');

  IF (p_mthd_action_id > -1) THEN

    -- Log process end
    hri_bpl_conc_log.record_process_start('HRI_MB_UTL_ABSNC_CT');
    hri_bpl_conc_log.log_process_end(
       p_status         => TRUE
      ,p_period_from    => TRUNC(g_refresh_start_date)
      ,p_period_to      => TRUNC(SYSDATE)
      ,p_attribute1     => g_full_refresh);

  END IF;

  -- Enable WHO trigger
  run_sql_stmt_noerr('ALTER TRIGGER HRI_MB_UTL_ABSNC_CT_WHO ENABLE');

  -- Get HRI schema name - get_app_info populates l_schema
  IF fnd_installation.get_app_info('HRI',l_dummy1, l_dummy2, l_schema) THEN
    null;
  END IF;

  -- Recreate indexes
  IF (g_full_refresh = 'Y') THEN
    hri_utl_ddl.recreate_indexes
     (p_application_short_name => 'HRI',
      p_table_name             => 'HRI_MB_UTL_ABSNC_CT',
      p_table_owner            => l_schema);
  END IF;

  -- Empty out absence dimension event queue
  l_sql_stmt := 'TRUNCATE TABLE ' || l_schema || '.HRI_EQ_UTL_ABSNC_FACT';
  EXECUTE IMMEDIATE(l_sql_stmt);

END post_process;

-- Populates table in a single thread
PROCEDURE single_thread_process(p_full_refresh_flag  IN VARCHAR2) IS

  l_end_abs_id  NUMBER;
  l_end_psn_id  NUMBER;
  l_dummy       VARCHAR2(32000);
  l_from_date   DATE := hri_bpl_parameter.get_bis_global_start_date;

BEGIN

-- get max assignment id
  SELECT max(person_id) INTO l_end_psn_id
  FROM per_all_people_f;
  SELECT max(absence_attendance_id) INTO l_end_abs_id
  FROM per_absence_attendances;

-- Set globals
  g_full_refresh              := p_full_refresh_flag;
  g_refresh_start_date        := l_from_date;
  g_dbi_collection_start_date := l_from_date;
  g_end_of_time               := hr_general.end_of_time;
  l_dummy := 'HRI';

-- Truncate table
  EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || l_dummy || '.hri_mb_utl_absnc_ct';

-- Process range
  IF (p_full_refresh_flag = 'Y') THEN
    process_range_full(0, l_end_psn_id);
  ELSE
    process_range_incr(0, l_end_abs_id);
  END IF;

-- Truncate table
  EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || l_dummy || '.hri_eq_utl_absnc_fact';

END single_thread_process;

END hri_opl_utl_absnc_fact;

/
