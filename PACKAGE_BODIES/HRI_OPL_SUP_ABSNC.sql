--------------------------------------------------------
--  DDL for Package Body HRI_OPL_SUP_ABSNC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OPL_SUP_ABSNC" AS
/* $Header: hriouaba.pkb 120.7 2006/02/20 07:17:30 jtitmas noship $ */

  -- Simple table types
  TYPE g_date_tab_type IS TABLE OF DATE INDEX BY BINARY_INTEGER;
  TYPE g_number_tab_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE g_varchar2_tab_type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

  -- PL/SQL table representing database table
  g_tab_sup_person_id         g_number_tab_type;
  g_tab_effective_date        g_date_tab_type;
  g_tab_abs_sk_fk             g_number_tab_type;
  g_tab_sup_direct_ind        g_number_tab_type;
  g_tab_abs_drtn_days         g_number_tab_type;
  g_tab_abs_drtn_hrs          g_number_tab_type;
  g_tab_abs_start_blnc        g_number_tab_type;
  g_tab_abs_nstart_blnc       g_number_tab_type;
  g_tab_abs_ntfctn_start      g_number_tab_type;
  g_tab_abs_ntfctn_nstart     g_number_tab_type;
  g_tab_abs_category_code     g_varchar2_tab_type;
  g_tab_abs_reason_code       g_varchar2_tab_type;
  g_tab_abs_person_id         g_number_tab_type;
  g_tab_index                 PLS_INTEGER;

  -- End of time
  g_end_of_time    DATE := hr_general.end_of_time;

  -- Global HRI Multithreading Array
  g_mthd_action_array       HRI_ADM_MTHD_ACTIONS%rowtype;

  -- Global parameters
  g_refresh_start_date      DATE;
  g_full_refresh            VARCHAR2(30);

  g_sysdate                 DATE;
  g_user                    NUMBER;

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

  l_dbi_collection_start_date     DATE;

BEGIN

-- If parameters haven't already been set, then set them
  IF (g_refresh_start_date IS NULL OR
      p_mthd_stage_code = 'PRE_PROCESS') THEN

    l_dbi_collection_start_date :=
           hri_oltp_conc_param.get_date_parameter_value
            (p_parameter_name     => 'FULL_REFRESH_FROM_DATE',
             p_process_table_name => 'HRI_MDP_SUP_ABSNC_OCC_CT');

    -- If called for the first time set the defaulted parameters
    IF (p_mthd_stage_code = 'PRE_PROCESS') THEN

      g_full_refresh :=
           hri_oltp_conc_param.get_parameter_value
            (p_parameter_name     => 'FULL_REFRESH',
             p_process_table_name => 'HRI_MDP_SUP_ABSNC_OCC_CT');

      -- Log defaulted parameters so the slave processes pick up
      hri_opl_multi_thread.update_parameters
       (p_mthd_action_id    => p_mthd_action_id,
        p_full_refresh      => g_full_refresh,
        p_global_start_date => l_dbi_collection_start_date);

    END IF;

    g_mthd_action_array    := hri_opl_multi_thread.get_mthd_action_array
                               (p_mthd_action_id);
    g_refresh_start_date   := g_mthd_action_array.collect_from_date;
    g_full_refresh         := g_mthd_action_array.full_refresh_flag;
    g_sysdate              := sysdate;
    g_user                 := fnd_global.user_id;

    hri_bpl_conc_log.dbg('Full refresh:   ' || g_full_refresh);
    hri_bpl_conc_log.dbg('Collect from:    N/A');
  END IF;

END set_parameters;

-- ----------------------------------------------------------------------------
-- Inserts row into PL/SQL table for future bulk insert
-- ----------------------------------------------------------------------------
PROCEDURE insert_row
 (p_sup_person_id         IN NUMBER,
  p_effective_date        IN DATE,
  p_abs_sk_fk             IN NUMBER,
  p_sup_direct_ind        IN NUMBER,
  p_abs_drtn_days         IN NUMBER,
  p_abs_drtn_hrs          IN NUMBER,
  p_abs_start_blnc        IN NUMBER,
  p_abs_nstart_blnc       IN NUMBER,
  p_abs_ntfctn_start      IN NUMBER,
  p_abs_ntfctn_nstart     IN NUMBER,
  p_abs_category_code     IN VARCHAR2,
  p_abs_reason_code       IN VARCHAR2,
  p_abs_person_id         IN NUMBER) IS

BEGIN

  g_tab_index := g_tab_index + 1;
  g_tab_sup_person_id(g_tab_index) := p_sup_person_id;
  g_tab_effective_date(g_tab_index) := p_effective_date;
  g_tab_abs_sk_fk(g_tab_index) := p_abs_sk_fk;
  g_tab_sup_direct_ind(g_tab_index) := p_sup_direct_ind;
  g_tab_abs_drtn_days(g_tab_index) := p_abs_drtn_days;
  g_tab_abs_drtn_hrs(g_tab_index) := p_abs_drtn_hrs;
  g_tab_abs_start_blnc(g_tab_index) := p_abs_start_blnc;
  g_tab_abs_nstart_blnc(g_tab_index) := p_abs_nstart_blnc;
  g_tab_abs_ntfctn_start(g_tab_index) := p_abs_ntfctn_start;
  g_tab_abs_ntfctn_nstart(g_tab_index) := p_abs_ntfctn_nstart;
  g_tab_abs_category_code(g_tab_index) := p_abs_category_code;
  g_tab_abs_reason_code(g_tab_index) := p_abs_reason_code;
  g_tab_abs_person_id(g_tab_index) := p_abs_person_id;

END insert_row;

-- ----------------------------------------------------------------------------
-- Empties PL/SQL table into database table and commits
-- ----------------------------------------------------------------------------
PROCEDURE bulk_insert_rows IS

BEGIN

  g_user := fnd_global.user_id;
  g_sysdate := sysdate;

  -- Bulk insert rows if any exist
  IF (g_tab_index > 0) THEN

    FORALL i IN 1..g_tab_index
      INSERT INTO hri_mdp_sup_absnc_occ_ct
       (supervisor_person_id
       ,effective_date
       ,absence_sk_fk
       ,direct_ind
       ,abs_drtn_days
       ,abs_drtn_hrs
       ,abs_start_blnc
       ,abs_nstart_blnc
       ,abs_ntfctn_days_start_blnc
       ,abs_ntfctn_days_nstart_blnc
       ,absence_category_code
       ,absence_reason_code
       ,abs_person_id
       ,last_update_date
       ,last_updated_by
       ,last_update_login
       ,created_by
       ,creation_date)
       VALUES
        (g_tab_sup_person_id(i),
         g_tab_effective_date(i),
         g_tab_abs_sk_fk(i),
         g_tab_sup_direct_ind(i),
         g_tab_abs_drtn_days(i),
         g_tab_abs_drtn_hrs(i),
         g_tab_abs_start_blnc(i),
         g_tab_abs_nstart_blnc(i),
         g_tab_abs_ntfctn_start(i),
         g_tab_abs_ntfctn_nstart(i),
         g_tab_abs_category_code(i),
         g_tab_abs_reason_code(i),
         g_tab_abs_person_id(i),
         g_sysdate,
         g_user,
         g_user,
         g_user,
         g_sysdate);

    -- commit
    commit;

  END IF;

  g_tab_index := 0;

END bulk_insert_rows;

-- ----------------------------------------------------------------------------
-- Caches the supervisor chain for a person at a point in time
-- ----------------------------------------------------------------------------
PROCEDURE load_supervisor_chain
   (p_person_id       IN NUMBER,
    p_effective_date  IN DATE,
    p_supervisor_tab  OUT NOCOPY g_number_tab_type,
    p_directs_tab     OUT NOCOPY g_number_tab_type,
    p_valid_to_date   OUT NOCOPY DATE) IS

  CURSOR sup_chain_csr IS
  SELECT
   sup_person_id
  ,sub_relative_level
  ,DECODE(sub_relative_level, 1, 1, 0)  direct_ind
  ,effective_end_date
  FROM
   hri_cs_suph
  WHERE sub_person_id = p_person_id
  AND p_effective_date BETWEEN effective_start_date
                       AND effective_end_date;

  l_date_tab       g_date_tab_type;
  l_empty_tab      g_number_tab_type;

BEGIN

  -- Reset output variables
  p_supervisor_tab := l_empty_tab;
  p_directs_tab    := l_empty_tab;

  -- Loop through supervisor records
  FOR sup_rec IN sup_chain_csr LOOP

    -- Keep track of the minimum valid to date
    IF (p_valid_to_date IS NULL OR
        sup_rec.effective_end_date < p_valid_to_date) THEN
      p_valid_to_date := sup_rec.effective_end_date;
    END IF;

    -- Add to chain record
    IF (sup_rec.sub_relative_level > 0) THEN
      p_supervisor_tab(sup_rec.sub_relative_level) := sup_rec.sup_person_id;
      p_directs_tab(sup_rec.sub_relative_level) := sup_rec.direct_ind;
    END IF;

  END LOOP;

END load_supervisor_chain;

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
-- Pushing of suph into absence day occurs in PL/SQL to reduce buffer reads
-- -----------------------------------------------------------------------------
PROCEDURE process_set(p_person_id     IN NUMBER,
                      p_start_abs_id  IN NUMBER,
                      p_end_abs_id    IN NUMBER) IS

  -- Absence details per person
  CURSOR full_absence_csr IS
  SELECT
   abs_fct.effective_date
  ,abs_fct.absence_sk_fk
  ,abs_fct.abs_drtn_days
  ,abs_fct.abs_drtn_hrs
  ,abs_fct.abs_start_ind
  ,abs_fct.abs_ntfctn_days_blnc
  ,abs_dim.absence_category_code
  ,abs_dim.absence_reason_code
  ,abs_dim.abs_person_id
  FROM
   hri_mb_utl_absnc_ct  abs_fct
  ,hri_cs_absence_ct    abs_dim
  WHERE abs_dim.abs_person_id = p_person_id
  AND abs_dim.absence_sk_pk = abs_fct.absence_sk_fk
  ORDER BY abs_fct.effective_date;

  -- Absence details per range
  CURSOR incr_absence_csr IS
  SELECT
   abs_fct.effective_date
  ,abs_fct.absence_sk_fk
  ,abs_fct.abs_drtn_days
  ,abs_fct.abs_drtn_hrs
  ,abs_fct.abs_start_ind
  ,abs_fct.abs_ntfctn_days_blnc
  ,abs_dim.absence_category_code
  ,abs_dim.absence_reason_code
  ,abs_dim.abs_person_id
  FROM
   hri_mb_utl_absnc_ct  abs_fct
  ,hri_cs_absence_ct    abs_dim
  ,hri_eq_sup_absnc     eq
  WHERE abs_dim.absence_sk_pk = eq.source_id
  AND eq.source_type = 'ABSENCE'
  AND eq.source_id BETWEEN p_start_abs_id
                   AND p_end_abs_id
  AND abs_dim.absence_sk_pk = abs_fct.absence_sk_fk
  ORDER BY abs_person_id, abs_fct.effective_date;

  -- PL/SQL table for cursor fetch
  l_abs_effective_date      g_date_tab_type;
  l_abs_sk_fk               g_number_tab_type;
  l_abs_drtn_days           g_number_tab_type;
  l_abs_drtn_hrs            g_number_tab_type;
  l_abs_start_ind           g_number_tab_type;
  l_abs_ntfctn_days_blnc    g_number_tab_type;
  l_abs_category_code       g_varchar2_tab_type;
  l_abs_reason_code         g_varchar2_tab_type;
  l_abs_person_id           g_number_tab_type;

  -- New supervisor table
  l_new_sup_ids             g_varchar2_tab_type;
  l_empty_tab               g_varchar2_tab_type;

  -- Whether the absence is new for the supervisor
  l_new_sup                 BOOLEAN;
  l_sup_abs_start_ind       NUMBER;
  l_last_abs_sk_fk          NUMBER;

  -- Supervisor chain
  l_sup_ids                 g_number_tab_type;
  l_sup_direct_ind          g_number_tab_type;
  l_sup_valid_to            DATE;
  l_sup_valid_for           NUMBER;

BEGIN

  -- Split out full and incremental refresh
  IF (p_person_id IS NOT NULL) THEN

    -- Fetch records from full refresh cursor
    OPEN full_absence_csr;
    FETCH full_absence_csr BULK COLLECT INTO
      l_abs_effective_date,
      l_abs_sk_fk,
      l_abs_drtn_days,
      l_abs_drtn_hrs,
      l_abs_start_ind,
      l_abs_ntfctn_days_blnc,
      l_abs_category_code,
      l_abs_reason_code,
      l_abs_person_id;
    CLOSE full_absence_csr;

  ELSE

    -- Fetch records from incremental refresh cursor
    OPEN incr_absence_csr;
    FETCH incr_absence_csr BULK COLLECT INTO
      l_abs_effective_date,
      l_abs_sk_fk,
      l_abs_drtn_days,
      l_abs_drtn_hrs,
      l_abs_start_ind,
      l_abs_ntfctn_days_blnc,
      l_abs_category_code,
      l_abs_reason_code,
      l_abs_person_id;
    CLOSE incr_absence_csr;

  END IF;

  -- If any absences found then process them
  IF (l_abs_sk_fk.EXISTS(1)) THEN

    -- Initialize supervisor chain
    load_supervisor_chain
     (p_person_id      => l_abs_person_id(1),
      p_effective_date => l_abs_effective_date(1),
      p_supervisor_tab => l_sup_ids,
      p_directs_tab    => l_sup_direct_ind,
      p_valid_to_date  => l_sup_valid_to);
    l_sup_valid_for := l_abs_person_id(1);

    -- Loop through absences
    FOR i IN l_abs_sk_fk.FIRST..l_abs_sk_fk.LAST LOOP

      -- Reset supervisor cache if a new absence is encountered
      -- Bug 5049096
      IF (l_abs_sk_fk(i) <> l_last_abs_sk_fk) THEN
        l_new_sup_ids := l_empty_tab;
      END IF;

      -- Check if supervisor chain is still valid
      IF (l_sup_valid_to < l_abs_effective_date(i) OR
          l_sup_valid_for <> l_abs_person_id(i)) THEN
        load_supervisor_chain
         (p_person_id      => l_abs_person_id(i),
          p_effective_date => l_abs_effective_date(i),
          p_supervisor_tab => l_sup_ids,
          p_directs_tab    => l_sup_direct_ind,
          p_valid_to_date  => l_sup_valid_to);
        l_sup_valid_for := l_abs_person_id(i);
      END IF;

      -- Check supervisor chain exists
      IF (l_sup_ids.EXISTS(1)) THEN

        -- Insert absence details for each supervisor
        FOR j IN l_sup_ids.FIRST..l_sup_ids.LAST LOOP

          -- Determine whether the supervisor encountered is new
          -- for this absence occurrence
          IF (l_new_sup_ids.EXISTS(l_sup_ids(j))) THEN
            l_new_sup := FALSE;
          ELSE
            l_new_sup := TRUE;
            l_new_sup_ids(l_sup_ids(j)) := 'Y';
          END IF;

          -- Bug 4889166
          -- Determine whether to set absence start or nstart values
          -- The absence start balances should be set for the first day
          -- of the absence (derived from the fact indicator) or
          -- if there has been a supervisor change and it is the first
          -- day of the absence for a new supervisor
          IF (l_abs_start_ind(i) = 1 OR l_new_sup) THEN
            l_sup_abs_start_ind := 1;
          ELSE
            l_sup_abs_start_ind := 0;
          END IF;

          -- Call procedure to insert row
          insert_row
           (p_sup_person_id     => l_sup_ids(j),
            p_effective_date    => l_abs_effective_date(i),
            p_abs_sk_fk         => l_abs_sk_fk(i),
            p_sup_direct_ind    => l_sup_direct_ind(j),
            p_abs_drtn_days     => l_abs_drtn_days(i),
            p_abs_drtn_hrs      => l_abs_drtn_hrs(i),
            p_abs_start_blnc    => l_sup_abs_start_ind,
            p_abs_nstart_blnc   => 1 - l_sup_abs_start_ind,
            p_abs_ntfctn_start  => l_abs_ntfctn_days_blnc(i) * l_sup_abs_start_ind,
            p_abs_ntfctn_nstart => l_abs_ntfctn_days_blnc(i) * (1 - l_sup_abs_start_ind),
            p_abs_category_code => l_abs_category_code(i),
            p_abs_reason_code   => l_abs_reason_code(i),
            p_abs_person_id     => l_abs_person_id(i));
        END LOOP;

      END IF; -- supervisors exist

      -- Store absence key
      l_last_abs_sk_fk := l_abs_sk_fk(i);

    END LOOP; -- absences

  END IF; -- absences exist

  -- Bulk insert rows if limit is reached
  IF (g_tab_index > 2000) THEN
    bulk_insert_rows;
  END IF;

END process_set;

-- Truncates and repopulates the supervisor events helper table
PROCEDURE process_range_full(p_start_psn_id    IN NUMBER,
                             p_end_psn_id      IN NUMBER) IS

  -- Person in range
  CURSOR person_csr IS
  SELECT DISTINCT
   abs_person_id
  FROM hri_cs_absence_ct
  WHERE abs_person_id BETWEEN p_start_psn_id AND p_end_psn_id;

BEGIN

  -- Reset count
  g_tab_index := 0;

  -- Loop through people
  FOR person_rec IN person_csr LOOP

    -- Process people one at a time
    process_set
     (p_person_id    => person_rec.abs_person_id,
      p_start_abs_id => to_number(null),
      p_end_abs_id   => to_number(null));

  END LOOP;

  -- Insert any remaining rows for range
  bulk_insert_rows;

END process_range_full;

-- -----------------------------------------------------------------------------
-- Processes incremental range
-- -----------------------------------------------------------------------------
PROCEDURE process_range_incr(p_start_abs_id    IN NUMBER,
                             p_end_abs_id      IN NUMBER) IS

BEGIN

  -- Delete changed rows
  DELETE FROM hri_mdp_sup_absnc_occ_ct tab
  WHERE tab.absence_sk_fk IN
   (SELECT eq.source_id
    FROM hri_eq_sup_absnc  eq
    WHERE eq.source_id BETWEEN p_start_abs_id AND p_end_abs_id
    AND eq.source_type = 'ABSENCE');

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
-- Translates people whose supervisor chains have changed into absences
-- ----------------------------------------------------------------------------
PROCEDURE find_absences_for_supervisors IS

BEGIN

  -- Insert absences affected by supervisor changes
  INSERT INTO hri_eq_sup_absnc
   (source_id
   ,source_type)
  SELECT
   dim.absence_sk_pk  source_id
  ,'ABSENCE'          source_type
  FROM
   hri_cs_absence_ct  dim
  ,hri_eq_sup_absnc   eq
  WHERE eq.source_type = 'SUPERVISOR'
  AND eq.source_id = dim.abs_person_id
  AND dim.abs_end_date >= eq.erlst_evnt_effective_date
  AND NOT EXISTS
   (SELECT null
    FROM hri_eq_sup_absnc eq_abs
    WHERE eq_abs.source_id = dim.absence_sk_pk
    AND eq_abs.source_type = 'ABSENCE');

  commit;

END find_absences_for_supervisors;

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
  run_sql_stmt_noerr('ALTER TRIGGER HRI_MDP_SUP_ABSNC_OCC_CT_WHO DISABLE');

  -- ********************
  -- Full Refresh Section
  -- ********************
  IF (g_full_refresh = 'Y' OR
      g_mthd_action_array.foundation_hr_flag = 'Y') THEN

    -- Empty out absence dimension table
    l_sql_stmt := 'TRUNCATE TABLE ' || l_schema || '.HRI_MDP_SUP_ABSNC_OCC_CT';
    EXECUTE IMMEDIATE(l_sql_stmt);

    -- In shared HR mode do not return a SQL statement so that the
    -- process_range and post_process will not be executed
    IF (g_mthd_action_array.foundation_hr_flag = 'Y') THEN

      -- Call post processing API
      post_process
       (p_mthd_action_id => p_mthd_action_id);

    ELSE

      -- Drop all the indexes on the table
      hri_utl_ddl.log_and_drop_indexes
       (p_application_short_name => 'HRI',
        p_table_name             => 'HRI_MDP_SUP_ABSNC_OCC_CT',
        p_table_owner            => l_schema);

      -- Set the SQL statement for the entire range
      p_sqlstr :=
        'SELECT /*+ PARALLEL(asg, DEFAULT, DEFAULT) */ DISTINCT
           abs_person_id object_id
         FROM hri_cs_absence_ct
         ORDER BY abs_person_id';

    END IF;

  ELSE

    -- Process the event queue
    find_absences_for_supervisors;

    -- Set the SQL statement for the incremental range
      p_sqlstr :=
        'SELECT
           source_id object_id
         FROM hri_eq_sup_absnc
         WHERE source_type = ''ABSENCE''
         ORDER BY source_id';

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
    hri_bpl_conc_log.record_process_start('HRI_MDP_SUP_ABSNC_OCC_CT');
    hri_bpl_conc_log.log_process_end(
       p_status         => TRUE
      ,p_period_from    => TRUNC(g_refresh_start_date)
      ,p_period_to      => TRUNC(SYSDATE)
      ,p_attribute1     => g_full_refresh);

  END IF;

  -- Enable WHO trigger
  run_sql_stmt_noerr('ALTER TRIGGER HRI_MDP_SUP_ABSNC_OCC_CT_WHO ENABLE');

  -- Get HRI schema name - get_app_info populates l_schema
  IF fnd_installation.get_app_info('HRI',l_dummy1, l_dummy2, l_schema) THEN
    null;
  END IF;

  -- Recreate indexes
  IF (g_full_refresh = 'Y') THEN
    hri_utl_ddl.recreate_indexes
     (p_application_short_name => 'HRI',
      p_table_name             => 'HRI_MDP_SUP_ABSNC_OCC_CT',
      p_table_owner            => l_schema);
  END IF;

  -- Empty out absence summary event queue
  l_sql_stmt := 'TRUNCATE TABLE ' || l_schema || '.HRI_EQ_SUP_ABSNC';
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
  g_end_of_time               := hr_general.end_of_time;
  l_dummy := 'HRI';

-- Truncate table
  EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || l_dummy || '.hri_mdp_sup_absnc_occ_ct';

-- Process range
  IF (p_full_refresh_flag = 'Y') THEN
    process_range_full(0, l_end_psn_id);
  ELSE
    process_range_incr(0, l_end_abs_id);
  END IF;

-- Truncate table
  EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || l_dummy || '.hri_eq_sup_absnc';

END single_thread_process;

END hri_opl_sup_absnc;

/
