--------------------------------------------------------
--  DDL for Package Body HRI_OPL_UTL_ABSNC_DIM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OPL_UTL_ABSNC_DIM" AS
/* $Header: hriouabd.pkb 120.7 2005/12/13 05:49:59 jtitmas noship $ */

  -- Simple table types
  TYPE g_date_tab_type IS TABLE OF DATE INDEX BY BINARY_INTEGER;
  TYPE g_number_tab_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE g_varchar2_tab_type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

  -- PL/SQL table representing database table
  g_abs_sk_pk                 g_number_tab_type;
  g_abs_attendance_id         g_number_tab_type;
  g_abs_start_date            g_date_tab_type;
  g_abs_end_date              g_date_tab_type;
  g_abs_notification_date     g_date_tab_type;
  g_abs_person_id             g_number_tab_type;
  g_abs_category_code         g_varchar2_tab_type;
  g_abs_reason_code           g_varchar2_tab_type;
  g_abs_status_code           g_varchar2_tab_type;
  g_abs_attendance_type_id    g_number_tab_type;
  g_abs_attendance_reason_id  g_number_tab_type;
  g_abs_drtn_days             g_number_tab_type;
  g_abs_drtn_hrs              g_number_tab_type;
  g_abs_index                 PLS_INTEGER;

  -- End of time
  g_end_of_time              DATE;

  -- Global HRI Multithreading Array
  g_mthd_action_array          HRI_ADM_MTHD_ACTIONS%rowtype;

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

    g_dbi_collection_start_date := hri_oltp_conc_param.get_date_parameter_value
                                    (p_parameter_name     => 'FULL_REFRESH_FROM_DATE',
                                     p_process_table_name => 'HRI_CS_ABSENCE_CT');

    -- If called for the first time set the defaulted parameters
    IF (p_mthd_stage_code = 'PRE_PROCESS') THEN

      g_full_refresh := hri_oltp_conc_param.get_parameter_value
                         (p_parameter_name     => 'FULL_REFRESH',
                          p_process_table_name => 'HRI_CS_ABSENCE_CT');

      -- Log defaulted parameters so the slave processes pick up
      hri_opl_multi_thread.update_parameters
       (p_mthd_action_id    => p_mthd_action_id,
        p_full_refresh      => g_full_refresh,
        p_global_start_date => g_dbi_collection_start_date);

    END IF;

    g_mthd_action_array := hri_opl_multi_thread.get_mthd_action_array
                            (p_mthd_action_id);
    g_refresh_start_date := g_mthd_action_array.collect_from_date;
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
-- Adds future absences that are now occurring/occurred
-- and occurring absences to the event queue
-- ----------------------------------------------------------------------------
PROCEDURE update_eq_with_status_changes IS

BEGIN

  INSERT INTO hri_eq_utl_absnc_dim
   (absence_attendance_id)
  SELECT
   dim.absence_attendance_id
  FROM
   hri_cs_absence_ct  dim
  WHERE dim.absence_status_code IN ('FUTURE','OCCURRING')
  AND dim.abs_start_date <= trunc(sysdate)
  AND NOT EXISTS
   (SELECT null
    FROM hri_eq_utl_absnc_dim eq
    WHERE eq.absence_attendance_id = dim.absence_attendance_id);

  commit;

END update_eq_with_status_changes;

-- ----------------------------------------------------------------------------
-- Populates parent event queues with the absence change events
-- ----------------------------------------------------------------------------
PROCEDURE populate_parent_eqs(p_event_type    IN VARCHAR2,
                              p_start_abs_id  IN NUMBER,
                              p_end_abs_id    IN NUMBER) IS

BEGIN

  -- Process according to event type
  IF (p_event_type = 'PURGES') THEN

    -- Update fact event queue with surrogate key of purged absences
    -- Bug 4648262
    INSERT INTO hri_eq_utl_absnc_fact
     (absence_sk_fk)
    SELECT
     dim.absence_sk_pk
    FROM
     hri_cs_absence_ct     dim
    ,hri_eq_utl_absnc_dim  eq
    WHERE dim.absence_attendance_id = eq.absence_attendance_id
    AND eq.absence_attendance_id BETWEEN p_start_abs_id AND p_end_abs_id
    AND NOT EXISTS
     (SELECT null
      FROM per_absence_attendances  tab
      WHERE tab.absence_attendance_id = eq.absence_attendance_id)
    AND NOT EXISTS
     (SELECT null
      FROM hri_eq_utl_absnc_fact eq2
      WHERE eq2.absence_sk_fk = dim.absence_sk_pk);

    -- Update summary event queue with surrogate key of purged absences
    -- Bug 4648262
    INSERT INTO hri_eq_sup_absnc
     (source_id
     ,source_type
     ,erlst_evnt_effective_date)
    SELECT
     dim.absence_sk_pk
    ,'ABSENCE'
    ,to_date(null)
    FROM
     hri_cs_absence_ct     dim
    ,hri_eq_utl_absnc_dim  eq
    WHERE dim.absence_attendance_id = eq.absence_attendance_id
    AND eq.absence_attendance_id BETWEEN p_start_abs_id AND p_end_abs_id
    AND NOT EXISTS
     (SELECT null
      FROM per_absence_attendances  tab
      WHERE tab.absence_attendance_id = eq.absence_attendance_id)
    AND NOT EXISTS
     (SELECT null
      FROM hri_eq_sup_absnc eq2
      WHERE eq2.source_id = dim.absence_sk_pk
      AND eq2.source_type = 'ABSENCE');

  ELSIF (p_event_type = 'UPDATES') THEN

    -- Update fact event queue with surrogate key
    INSERT INTO hri_eq_utl_absnc_fact
     (absence_sk_fk)
    SELECT
     dim.absence_sk_pk
    FROM
     hri_cs_absence_ct     dim
    ,hri_eq_utl_absnc_dim  eq
    WHERE dim.absence_attendance_id = eq.absence_attendance_id
    AND eq.absence_attendance_id BETWEEN p_start_abs_id AND p_end_abs_id
    AND NOT EXISTS
     (SELECT null
      FROM hri_eq_utl_absnc_fact eq2
      WHERE eq2.absence_sk_fk = dim.absence_sk_pk);

    -- Update summary event queue with surrogate key
    INSERT INTO hri_eq_sup_absnc
     (source_id
     ,source_type
     ,erlst_evnt_effective_date)
    SELECT
     dim.absence_sk_pk
    ,'ABSENCE'
    ,to_date(null)
    FROM
     hri_cs_absence_ct     dim
    ,hri_eq_utl_absnc_dim  eq
    WHERE dim.absence_attendance_id = eq.absence_attendance_id
    AND eq.absence_attendance_id BETWEEN p_start_abs_id AND p_end_abs_id
    AND NOT EXISTS
     (SELECT null
      FROM hri_eq_sup_absnc eq2
      WHERE eq2.source_id = dim.absence_sk_pk
      AND eq2.source_type = 'ABSENCE');

  END IF;

END populate_parent_eqs;

-- ----------------------------------------------------------------------------
-- Repopulates the supervisor events helper table incrementally
-- ----------------------------------------------------------------------------
PROCEDURE process_range_incr(p_start_abs_id    IN NUMBER,
                             p_end_abs_id      IN NUMBER) IS

BEGIN

  -- Update parent event queues with the surrogate key of any purges
  populate_parent_eqs
   (p_event_type   => 'PURGES',
    p_start_abs_id => p_start_abs_id,
    p_end_abs_id   => p_end_abs_id);

  -- Delete old records
  DELETE FROM hri_cs_absence_ct dim
  WHERE dim.absence_attendance_id IN
   (SELECT eq.absence_attendance_id
    FROM hri_eq_utl_absnc_dim  eq
    WHERE eq.absence_attendance_id BETWEEN p_start_abs_id AND p_end_abs_id);

  -- Insert new/changed records
  INSERT INTO hri_cs_absence_ct
   (absence_sk_pk
   ,absence_attendance_id
   ,abs_start_date
   ,abs_end_date
   ,abs_notification_date
   ,abs_person_id
   ,absence_category_code
   ,absence_reason_code
   ,absence_status_code
   ,absence_attendance_type_id
   ,abs_attendance_reason_id
   ,abs_drtn_days
   ,abs_drtn_hrs
   ,last_update_date
   ,last_updated_by
   ,last_update_login
   ,created_by
   ,creation_date)
  SELECT
   paa.absence_attendance_id              absence_sk_pk
  ,paa.absence_attendance_id              absence_attendance_id
  ,paa.date_start                         abs_start_date
  ,NVL(paa.date_end, g_end_of_time)       abs_end_date
  ,paa.date_notification                  abs_notification_date
  ,paa.person_id                          abs_person_id
  ,NVL(pat.absence_category, 'NA_EDW')    absence_category_code
  ,NVL(par.name, 'NA_EDW')                absence_reason_code
  ,CASE WHEN paa.date_start > TRUNC(SYSDATE)
        THEN 'FUTURE'
        WHEN (TRUNC(SYSDATE) BETWEEN paa.date_start
                             AND NVL(paa.date_end, g_end_of_time))
        THEN 'OCCURRING'
        ELSE 'OCCURRED'
   END                                    absence_status_code
  ,paa.absence_attendance_type_id
  ,NVL(paa.abs_attendance_reason_id, -1)  abs_attendance_reason_id
  ,SUM(hri_bpl_utilization.calculate_absence_duration
        (paa.absence_attendance_id
        ,'DAYS'
        ,paa.absence_hours
        ,paa.absence_days
        ,asg.assignment_id
        ,asg.business_group_id
        ,asg.primary_flag
        ,paa.date_start
        ,NVL(paa.date_end, trunc(sysdate))
        ,paa.time_start
        ,paa.time_end))                   abs_drtn_days
  ,SUM(hri_bpl_utilization.calculate_absence_duration
        (paa.absence_attendance_id
        ,'HOURS'
        ,paa.absence_hours
        ,paa.absence_days
        ,asg.assignment_id
        ,asg.business_group_id
        ,asg.primary_flag
        ,paa.date_start
        ,NVL(paa.date_end, trunc(sysdate))
        ,paa.time_start
        ,paa.time_end))                   abs_drtn_hrs
  ,g_sysdate
  ,g_user
  ,g_user
  ,g_user
  ,g_sysdate
  FROM
   per_absence_attendances       paa
  ,per_absence_attendance_types  pat
  ,per_abs_attendance_reasons    par
  ,per_all_assignments_f         asg
  ,hri_eq_utl_absnc_dim          eq
  WHERE eq.absence_attendance_id BETWEEN p_start_abs_id
                                 AND p_end_abs_id
  AND paa.absence_attendance_id = eq.absence_attendance_id
  AND paa.absence_attendance_type_id = pat.absence_attendance_type_id
  AND paa.abs_attendance_reason_id = par.abs_attendance_reason_id (+)
  AND paa.person_id = asg.person_id
  AND asg.assignment_type IN ('E','C')
  AND paa.date_start BETWEEN asg.effective_start_date
                     AND asg.effective_end_date
  AND paa.date_start IS NOT NULL
  AND NVL(paa.date_end, g_end_of_time) >= g_dbi_collection_start_date
  GROUP BY
   paa.absence_attendance_id
  ,paa.date_start
  ,paa.date_end
  ,paa.date_notification
  ,paa.person_id
  ,pat.absence_category
  ,par.name
  ,paa.absence_attendance_type_id
  ,paa.abs_attendance_reason_id
  ,paa.absence_days
  ,paa.absence_hours;

  -- Update parent event queues with the surrogate key of the updates
  populate_parent_eqs
   (p_event_type   => 'UPDATES',
    p_start_abs_id => p_start_abs_id,
    p_end_abs_id   => p_end_abs_id);

  -- Commit the processing for the range
  commit;

END process_range_incr;

-- ----------------------------------------------------------------------------
-- Bulk inserts from PL/SQL table to database
-- ----------------------------------------------------------------------------
PROCEDURE bulk_insert_rows IS

BEGIN

  g_user := fnd_global.user_id;
  g_sysdate := sysdate;

  -- Bulk insert rows if any exist
  IF (g_abs_index > 0) THEN

    FORALL i IN 1..g_abs_index
     INSERT INTO hri_cs_absence_ct
     (absence_sk_pk
     ,absence_attendance_id
     ,abs_start_date
     ,abs_end_date
     ,abs_notification_date
     ,abs_person_id
     ,absence_category_code
     ,absence_reason_code
     ,absence_status_code
     ,absence_attendance_type_id
     ,abs_attendance_reason_id
     ,abs_drtn_days
     ,abs_drtn_hrs
     ,last_update_date
     ,last_updated_by
     ,last_update_login
     ,created_by
     ,creation_date)
     VALUES
      (g_abs_sk_pk(i),
       g_abs_attendance_id(i),
       g_abs_start_date(i),
       g_abs_end_date(i),
       g_abs_notification_date(i),
       g_abs_person_id(i),
       g_abs_category_code(i),
       g_abs_reason_code(i),
       g_abs_status_code(i),
       g_abs_attendance_type_id(i),
       g_abs_attendance_reason_id(i),
       g_abs_drtn_days(i),
       g_abs_drtn_hrs(i),
       g_sysdate,
       g_user,
       g_user,
       g_user,
       g_sysdate);

    -- Commit
    commit;

  END IF;

  -- Reset index
  g_abs_index := 0;

END bulk_insert_rows;

-- ----------------------------------------------------------------------------
-- Inserts row into PL/SQL table
-- ----------------------------------------------------------------------------
PROCEDURE insert_row(
  p_abs_sk_pk                 IN NUMBER,
  p_abs_attendance_id         IN NUMBER,
  p_abs_start_date            IN DATE,
  p_abs_end_date              IN DATE,
  p_abs_notification_date     IN DATE,
  p_abs_person_id             IN NUMBER,
  p_abs_category_code         IN VARCHAR2,
  p_abs_reason_code           IN VARCHAR2,
  p_abs_status_code           IN VARCHAR2,
  p_abs_attendance_type_id    IN NUMBER,
  p_abs_attendance_reason_id  IN NUMBER,
  p_abs_drtn_days             IN NUMBER,
  p_abs_drtn_hrs              IN NUMBER) IS

BEGIN

  g_abs_index := g_abs_index + 1;
  g_abs_sk_pk(g_abs_index) := p_abs_sk_pk;
  g_abs_attendance_id(g_abs_index) := p_abs_attendance_id;
  g_abs_start_date(g_abs_index) := p_abs_start_date;
  g_abs_end_date(g_abs_index) := p_abs_end_date;
  g_abs_notification_date(g_abs_index) := p_abs_notification_date;
  g_abs_person_id(g_abs_index) := p_abs_person_id;
  g_abs_category_code(g_abs_index) := p_abs_category_code;
  g_abs_reason_code(g_abs_index) := p_abs_reason_code;
  g_abs_status_code(g_abs_index) := p_abs_status_code;
  g_abs_attendance_type_id(g_abs_index) := p_abs_attendance_type_id;
  g_abs_attendance_reason_id(g_abs_index) := p_abs_attendance_reason_id;
  g_abs_drtn_days(g_abs_index) := p_abs_drtn_days;
  g_abs_drtn_hrs(g_abs_index) := p_abs_drtn_hrs;

END insert_row;

-- ----------------------------------------------------------------------------
-- Processes a single person
-- ----------------------------------------------------------------------------
PROCEDURE process_person(p_person_id    IN NUMBER) IS

  CURSOR absence_csr IS
  SELECT
   paa.absence_attendance_id              absence_sk_pk
  ,paa.absence_attendance_id
  ,paa.date_start                         abs_start_date
  ,NVL(paa.date_end, g_end_of_time)       abs_end_date
  ,paa.date_notification                  abs_notification_date
  ,paa.person_id                          abs_person_id
  ,NVL(pat.absence_category, 'NA_EDW')    absence_category_code
  ,NVL(par.name, 'NA_EDW')                absence_reason_code
  ,CASE WHEN paa.date_start > TRUNC(SYSDATE)
        THEN 'FUTURE'
        WHEN (TRUNC(SYSDATE) BETWEEN paa.date_start
                             AND NVL(paa.date_end, g_end_of_time))
        THEN 'OCCURRING'
        ELSE 'OCCURRED'
   END                                    absence_status_code
  ,paa.absence_attendance_type_id
  ,NVL(paa.abs_attendance_reason_id, -1)  abs_attendance_reason_id
  ,SUM(hri_bpl_utilization.calculate_absence_duration
        (paa.absence_attendance_id
        ,'DAYS'
        ,paa.absence_hours
        ,paa.absence_days
        ,asg.assignment_id
        ,asg.business_group_id
        ,asg.primary_flag
        ,paa.date_start
        ,NVL(paa.date_end, trunc(sysdate))
        ,paa.time_start
        ,paa.time_end))                   abs_drtn_days
  ,SUM(hri_bpl_utilization.calculate_absence_duration
        (paa.absence_attendance_id
        ,'HOURS'
        ,paa.absence_hours
        ,paa.absence_days
        ,asg.assignment_id
        ,asg.business_group_id
        ,asg.primary_flag
        ,paa.date_start
        ,NVL(paa.date_end, trunc(sysdate))
        ,paa.time_start
        ,paa.time_end))                   abs_drtn_hrs
  FROM
   per_absence_attendances       paa
  ,per_absence_attendance_types  pat
  ,per_abs_attendance_reasons    par
  ,per_all_assignments_f         asg
  WHERE paa.person_id = p_person_id
  AND paa.absence_attendance_type_id = pat.absence_attendance_type_id
  AND paa.abs_attendance_reason_id = par.abs_attendance_reason_id (+)
  AND paa.person_id = asg.person_id
  AND asg.assignment_type IN ('E','C')
  AND paa.date_start BETWEEN asg.effective_start_date
                     AND asg.effective_end_date
  AND paa.date_start IS NOT NULL
  AND NVL(paa.date_end, g_end_of_time) >= g_dbi_collection_start_date
  GROUP BY
   paa.absence_attendance_id
  ,paa.date_start
  ,paa.date_end
  ,paa.date_notification
  ,paa.person_id
  ,pat.absence_category
  ,par.name
  ,paa.absence_attendance_type_id
  ,paa.abs_attendance_reason_id
  ,paa.absence_days
  ,paa.absence_hours;

  -- PL/SQL table for cursor fetch
  l_abs_sk_pk                  g_number_tab_type;
  l_abs_attendance_id          g_number_tab_type;
  l_abs_start_date             g_date_tab_type;
  l_abs_end_date               g_date_tab_type;
  l_abs_notification_date      g_date_tab_type;
  l_abs_person_id              g_number_tab_type;
  l_abs_category_code          g_varchar2_tab_type;
  l_abs_reason_code            g_varchar2_tab_type;
  l_abs_status_code            g_varchar2_tab_type;
  l_abs_attendance_type_id     g_number_tab_type;
  l_abs_attendance_reason_id   g_number_tab_type;
  l_abs_drtn_days              g_number_tab_type;
  l_abs_drtn_hrs               g_number_tab_type;

BEGIN

  -- Bulk fetch from cursor
  OPEN absence_csr;
  FETCH absence_csr BULK COLLECT INTO
    l_abs_sk_pk,
    l_abs_attendance_id,
    l_abs_start_date,
    l_abs_end_date,
    l_abs_notification_date,
    l_abs_person_id,
    l_abs_category_code,
    l_abs_reason_code,
    l_abs_status_code,
    l_abs_attendance_type_id,
    l_abs_attendance_reason_id,
    l_abs_drtn_days,
    l_abs_drtn_hrs;
  CLOSE absence_csr;

  -- If rows are returned then store them in PL/SQL table
  IF (l_abs_sk_pk.EXISTS(1)) THEN

    -- Loop through and insert rows to PL/SQL table
    FOR i IN l_abs_sk_pk.FIRST..l_abs_sk_pk.LAST LOOP
      insert_row
       (p_abs_sk_pk                => l_abs_sk_pk(i),
        p_abs_attendance_id        => l_abs_attendance_id(i),
        p_abs_start_date           => l_abs_start_date(i),
        p_abs_end_date             => l_abs_end_date(i),
        p_abs_notification_date    => l_abs_notification_date(i),
        p_abs_person_id            => l_abs_person_id(i),
        p_abs_category_code        => l_abs_category_code(i),
        p_abs_reason_code          => l_abs_reason_code(i),
        p_abs_status_code          => l_abs_status_code(i),
        p_abs_attendance_type_id   => l_abs_attendance_type_id(i),
        p_abs_attendance_reason_id => l_abs_attendance_reason_id(i),
        p_abs_drtn_days            => l_abs_drtn_days(i),
        p_abs_drtn_hrs             => l_abs_drtn_hrs(i));
    END LOOP;

  END IF;

  -- Insert rows if limit is reached
  IF (g_abs_index > 2000) THEN
    bulk_insert_rows;
  END IF;

END process_person;

-- ----------------------------------------------------------------------------
-- Full refresh of range
-- ----------------------------------------------------------------------------
PROCEDURE process_range_full(p_start_psn_id    IN NUMBER,
                             p_end_psn_id      IN NUMBER) IS

  -- Person in range
  CURSOR person_csr IS
  SELECT DISTINCT
   paa.person_id
  FROM per_absence_attendances  paa
  WHERE paa.person_id BETWEEN p_start_psn_id AND p_end_psn_id
  AND paa.date_start IS NOT NULL
  AND NVL(paa.date_end, sysdate) >= g_dbi_collection_start_date;

BEGIN

  -- Reset global index
  g_abs_index := 0;

  -- Loop through people in range
  FOR person_rec IN person_csr LOOP

    -- Process people one at a time
    process_person(person_rec.person_id);

  END LOOP;

  -- Insert any remaining rows for range
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
  run_sql_stmt_noerr('ALTER TRIGGER HRI_CS_ABSENCE_CT_WHO DISABLE');

  -- ********************
  -- Full Refresh Section
  -- ********************
  IF (g_full_refresh = 'Y' OR
      g_mthd_action_array.foundation_hr_flag = 'Y') THEN

    -- Empty out absence dimension table
    l_sql_stmt := 'TRUNCATE TABLE ' || l_schema || '.HRI_CS_ABSENCE_CT';
    EXECUTE IMMEDIATE(l_sql_stmt);

    -- In shared HR mode do not return a SQL statement so that
    -- process_range and post_process will not be executed
    IF (g_mthd_action_array.foundation_hr_flag = 'Y') THEN

      -- Call post processing API
      post_process
       (p_mthd_action_id => p_mthd_action_id);

    ELSE

      -- Drop all the indexes on the table
      hri_utl_ddl.log_and_drop_indexes
       (p_application_short_name => 'HRI',
        p_table_name             => 'HRI_CS_ABSENCE_CT',
        p_table_owner            => l_schema);


      -- Set the SQL statement for the entire range
      p_sqlstr :=
        'SELECT /*+ PARALLEL(paa, DEFAULT, DEFAULT) */ DISTINCT
           paa.person_id object_id
         FROM per_absence_attendances paa
         WHERE paa.date_start IS NOT NULL
         AND NVL(paa.date_end, sysdate) >= to_date(''' ||
                       to_char(g_dbi_collection_start_date, 'DD-MM-YYYY') ||
                       ''',''DD-MM-YYYY'')
         ORDER BY paa.person_id';

    END IF;

  ELSE

    -- Inserts future and occurring absences into the event queue
    update_eq_with_status_changes;

    -- Set the SQL statement for the incremental range
    p_sqlstr :=
      'SELECT /*+ PARALLEL(eq, DEFAULT, DEFAULT) */
         absence_attendance_id object_id
       FROM hri_eq_utl_absnc_dim eq
       ORDER BY absence_attendance_id';

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
    hri_bpl_conc_log.record_process_start('HRI_CS_ABSENCE_CT');
    hri_bpl_conc_log.log_process_end(
       p_status         => TRUE
      ,p_period_from    => TRUNC(g_refresh_start_date)
      ,p_period_to      => TRUNC(SYSDATE)
      ,p_attribute1     => g_full_refresh);

  END IF;

  -- Enable WHO trigger
  run_sql_stmt_noerr('ALTER TRIGGER HRI_CS_ABSENCE_CT_WHO ENABLE');

  -- Get HRI schema name - get_app_info populates l_schema
  IF fnd_installation.get_app_info('HRI',l_dummy1, l_dummy2, l_schema) THEN
    null;
  END IF;

  -- Recreate indexes
  IF (g_full_refresh = 'Y') THEN
    hri_utl_ddl.recreate_indexes
     (p_application_short_name => 'HRI',
      p_table_name             => 'HRI_CS_ABSENCE_CT',
      p_table_owner            => l_schema);
  END IF;

  -- Empty out absence dimension event queue
  l_sql_stmt := 'TRUNCATE TABLE ' || l_schema || '.HRI_EQ_UTL_ABSNC_DIM';
  EXECUTE IMMEDIATE(l_sql_stmt);

END post_process;

-- Populates table in a single thread
PROCEDURE single_thread_process(p_full_refresh_flag  IN VARCHAR2) IS

  l_end_abs_id  NUMBER;
  l_end_psn_id  NUMBER;
  l_dummy       VARCHAR2(32000);
  l_from_date   DATE := hri_bpl_parameter.get_bis_global_start_date;

BEGIN

-- get max ids
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

-- truncate table
  EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || l_dummy || '.hri_cs_absence_ct';

-- Process range
  IF (p_full_refresh_flag = 'Y') THEN
    process_range_full(0, l_end_psn_id);
  ELSE
    process_range_incr(0, l_end_abs_id);
  END IF;

-- truncate eq
  EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || l_dummy || '.hri_eq_utl_absnc_dim';

END single_thread_process;

END hri_opl_utl_absnc_dim;

/
