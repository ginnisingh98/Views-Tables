--------------------------------------------------------
--  DDL for Package Body HRI_OPL_SUPH_EVENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OPL_SUPH_EVENTS" AS
/* $Header: hrioshe.pkb 120.4 2005/11/11 03:06:42 jtitmas noship $ */

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
PROCEDURE set_parameters(p_mthd_action_id  IN NUMBER) IS

BEGIN

-- If parameters haven't already been set, then set them
  IF (g_refresh_start_date IS NULL) THEN
    g_mthd_action_array    := hri_opl_multi_thread.get_mthd_action_array
                               (p_mthd_action_id);
    g_refresh_start_date   := g_mthd_action_array.collect_from_date;
    g_full_refresh         := g_mthd_action_array.full_refresh_flag;
    g_sysdate              := sysdate;
    g_user                 := fnd_global.user_id;
  END IF;

END set_parameters;

-- Deletes and replaces the assignment records to be refreshed in
-- the supervisor hierarchy events helper table
PROCEDURE process_range_incr(p_start_asg_id       IN NUMBER,
                             p_end_asg_id         IN NUMBER) IS

  l_dummy1        VARCHAR2(2000);
  l_dummy2        VARCHAR2(2000);
  l_schema        VARCHAR2(400);

BEGIN

  -- Single thread insert
  INSERT INTO hri_cs_asgn_suph_events_ct
  (assignment_id
  ,effective_start_date
  ,effective_end_date
  ,person_id
  ,supervisor_person_id
  ,supervisor_assignment_id
  ,business_group_id
  ,assignment_type
  ,primary_flag
  ,assignment_status_type_id
  ,last_update_date
  ,last_updated_by
  ,last_update_login
  ,created_by
  ,creation_date)
  SELECT
   chg.assignment_id
  ,chg.effective_start_date
-- Day before date of next supervisor change or if no further changes
-- then the latest end date for the assignment
  ,NVL(LEAD(chg.effective_start_date, 1) OVER
         (PARTITION BY chg.assignment_id
          ORDER BY chg.effective_start_date) - 1
      ,chg.latest_end_date)
                      effective_end_date
  ,chg.person_id
  ,chg.supervisor_id  supervisor_person_id
  ,TO_NUMBER(NULL)    supervisor_assignment_id
  ,chg.business_group_id
  ,chg.assignment_type
  ,chg.primary_flag
  ,chg.assignment_status_type_id
  ,g_sysdate
  ,g_user
  ,g_user
  ,g_user
  ,g_sysdate
  FROM
   (SELECT
     prv.assignment_id
    ,prv.effective_start_date
-- Latest end date for an active assignment
    ,LAST_VALUE(prv.effective_end_date) OVER
           (PARTITION BY prv.assignment_id
            ORDER BY prv.effective_start_date
            ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING)
               latest_end_date
    ,prv.person_id
    ,prv.supervisor_id
    ,prv.business_group_id
    ,prv.assignment_type
    ,prv.primary_flag
    ,prv.assignment_status_type_id
-- Previous supervisor value - set first row so that it is always
-- picked up as a change
    ,NVL(LAG(prv.supervisor_id, 1) OVER
           (PARTITION BY prv.assignment_id
            ORDER BY prv.effective_start_date)
         ,-999)
                         supervisor_prv_id
    FROM
     (SELECT
       asg.assignment_id
      ,GREATEST(asg.effective_start_date, eq.erlst_evnt_effective_date)
                          effective_start_date
      ,asg.effective_end_date
      ,asg.person_id
      ,NVL(asg.supervisor_id, -1)  supervisor_id
      ,asg.primary_flag
      ,asg.assignment_status_type_id
      ,asg.assignment_type
      ,asg.business_group_id
      FROM
       hri_eq_sprvsr_hrchy_chgs     eq
      ,per_all_assignments_f        asg
      ,per_assignment_status_types  ast
      WHERE asg.assignment_type IN ('E', 'C')
      AND asg.primary_flag = 'Y'
      AND eq.assignment_id BETWEEN p_start_asg_id AND p_end_asg_id
      AND asg.effective_end_date >= eq.erlst_evnt_effective_date
      AND eq.assignment_id = asg.assignment_id
      AND ast.assignment_status_type_id = asg.assignment_status_type_id
      AND ast.per_system_status <> 'TERM_ASSIGN'
     )     prv
   ) chg
-- Filter out date-tracked records where no supervisor change has occurred
    WHERE chg.supervisor_id <> chg.supervisor_prv_id;

  COMMIT;

END process_range_incr;

-- Truncates and repopulates the supervisor events helper table
PROCEDURE process_range_full(p_start_asg_id       IN NUMBER,
                             p_end_asg_id         IN NUMBER) IS

BEGIN

  -- Single thread insert
  INSERT INTO hri_cs_asgn_suph_events_ct
  (assignment_id
  ,effective_start_date
  ,effective_end_date
  ,person_id
  ,supervisor_person_id
  ,supervisor_assignment_id
  ,business_group_id
  ,assignment_type
  ,primary_flag
  ,assignment_status_type_id
  ,last_update_date
  ,last_updated_by
  ,last_update_login
  ,created_by
  ,creation_date)
  SELECT
   chg.assignment_id
  ,chg.effective_start_date
-- Day before date of next supervisor change or if no further changes
-- then the latest end date for the assignment
  ,NVL(LEAD(chg.effective_start_date, 1) OVER
         (PARTITION BY chg.assignment_id
          ORDER BY chg.effective_start_date) - 1
      ,chg.latest_end_date)
                      effective_end_date
  ,chg.person_id
  ,chg.supervisor_id  supervisor_person_id
  ,TO_NUMBER(NULL)    supervisor_assignment_id
  ,chg.business_group_id
  ,chg.assignment_type
  ,chg.primary_flag
  ,chg.assignment_status_type_id
  ,g_sysdate
  ,g_user
  ,g_user
  ,g_user
  ,g_sysdate
  FROM
   (SELECT
     prv.assignment_id
    ,prv.effective_start_date
-- Latest end date for an active assignment
    ,LAST_VALUE(prv.effective_end_date) OVER
           (PARTITION BY prv.assignment_id
            ORDER BY prv.effective_start_date
            ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING)
               latest_end_date
    ,prv.person_id
    ,prv.supervisor_id
    ,prv.business_group_id
    ,prv.assignment_type
    ,prv.primary_flag
    ,prv.assignment_status_type_id
-- Previous supervisor value - set first row so that it is always
-- picked up as a change
    ,NVL(LAG(prv.supervisor_id, 1) OVER
           (PARTITION BY prv.assignment_id
            ORDER BY prv.effective_start_date)
         ,-999)
                         supervisor_prv_id
    FROM
     (SELECT
       asg.assignment_id
      ,GREATEST(asg.effective_start_date, g_refresh_start_date)
                          effective_start_date
      ,asg.effective_end_date
      ,asg.person_id
      ,NVL(asg.supervisor_id, -1)  supervisor_id
      ,asg.primary_flag
      ,asg.assignment_status_type_id
      ,asg.assignment_type
      ,asg.business_group_id
      FROM
       per_all_assignments_f        asg
      ,per_assignment_status_types  ast
      WHERE asg.assignment_type IN ('E', 'C')
      AND asg.primary_flag = 'Y'
      AND asg.assignment_id BETWEEN p_start_asg_id AND p_end_asg_id
      AND asg.effective_end_date >= g_refresh_start_date
      AND ast.assignment_status_type_id = asg.assignment_status_type_id
      AND ast.per_system_status <> 'TERM_ASSIGN'
     )     prv
   ) chg
-- Filter out date-tracked records where no supervisor change has occurred
    WHERE chg.supervisor_id <> chg.supervisor_prv_id;

  COMMIT;

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
  set_parameters(p_mthd_action_id);

-- Process range in corresponding refresh mode
  IF g_full_refresh = 'Y' THEN
    process_range_full
     (p_start_asg_id => p_start_object_id,
      p_end_asg_id   => p_end_object_id);
  ELSE
    process_range_incr
     (p_start_asg_id => p_start_object_id,
      p_end_asg_id   => p_end_object_id);
  END IF;

END process_range;

-- Populates the supervisor events helper table in shared hr mode
PROCEDURE single_thread_shared_hrms IS

BEGIN

  -- Enable native parallelism
  EXECUTE IMMEDIATE 'ALTER SESSION ENABLE PARALLEL DML';
  EXECUTE IMMEDIATE 'ALTER SESSION FORCE PARALLEL QUERY';

  -- Single thread insert
  INSERT /*+ APPEND */ INTO hri_cs_asgn_suph_events_ct
  (assignment_id
  ,effective_start_date
  ,effective_end_date
  ,person_id
  ,supervisor_person_id
  ,supervisor_assignment_id
  ,business_group_id
  ,assignment_type
  ,primary_flag
  ,assignment_status_type_id
  ,last_update_date
  ,last_updated_by
  ,last_update_login
  ,created_by
  ,creation_date)
  SELECT
   asg.assignment_id
  ,GREATEST(NVL(pos.date_start, ppp.date_start),
            TRUNC(SYSDATE))
                               effective_start_date
  ,NVL(pos.actual_termination_date,
       NVL(ppp.actual_termination_date, g_end_of_time))
                               effective_end_date
  ,asg.person_id
  ,NVL(asg.supervisor_id, -1)  supervisor_person_id
  ,to_number(null)             supervisor_assignment_id
  ,asg.business_group_id
  ,asg.assignment_type
  ,asg.primary_flag
  ,asg.assignment_status_type_id
  ,g_sysdate
  ,g_user
  ,g_user
  ,g_user
  ,g_sysdate
  FROM
   per_all_assignments_f        asg
  ,per_assignment_status_types  ast
  ,per_periods_of_service       pos
  ,per_periods_of_placement     ppp
  WHERE asg.assignment_type IN ('E', 'C')
  AND asg.primary_flag = 'Y'
  AND asg.effective_end_date >= g_refresh_start_date
  AND ast.assignment_status_type_id = asg.assignment_status_type_id
  AND ast.per_system_status <> 'TERM_ASSIGN'
  AND trunc(SYSDATE) BETWEEN asg.effective_start_date
                     AND asg.effective_end_date
  AND asg.period_of_service_id = pos.period_of_service_id (+)
  AND asg.person_id = ppp.person_id (+)
  AND asg.period_of_placement_date_start = ppp.date_start (+);

  COMMIT;

END single_thread_shared_hrms;

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
   (p_mthd_action_id => p_mthd_action_id);

  -- Get HRI schema name - get_app_info populates l_schema
  IF fnd_installation.get_app_info('HRI',l_dummy1, l_dummy2, l_schema) THEN
    null;
  END IF;

  -- Disable WHO trigger
  run_sql_stmt_noerr('ALTER TRIGGER HRI_CS_ASGN_SUPH_EVENTS_CT_WHO DISABLE');

  -- ********************
  -- Full Refresh Section
  -- ********************
  IF (g_full_refresh = 'Y' OR
      g_mthd_action_array.foundation_hr_flag = 'Y') THEN

    -- Empty out supervisor hierarchy events helper table
    l_sql_stmt := 'TRUNCATE TABLE ' || l_schema || '.HRI_CS_ASGN_SUPH_EVENTS_CT';
    EXECUTE IMMEDIATE(l_sql_stmt);

    -- In shared HR mode populate the table in a single direct insert
    -- Do not return a SQL statement so that the process_range and
    -- post_process will not be executed
    IF (g_mthd_action_array.foundation_hr_flag = 'Y') THEN

      -- Call API to insert rows
      single_thread_shared_hrms;

      -- Call post processing API
      post_process
       (p_mthd_action_id => p_mthd_action_id);

    ELSE

      -- Set the SQL statement for the entire range
      p_sqlstr :=
        'SELECT /*+ PARALLEL(asg, DEFAULT, DEFAULT) */
           DISTINCT assignment_id  object_id
         FROM per_all_assignments_f asg
         WHERE assignment_type IN (''E'', ''C'')
         AND primary_flag = ''Y''
         AND effective_end_date >= to_date(''' ||
                       to_char(g_refresh_start_date, 'DD-MM-YYYY') ||
                       ''',''DD-MM-YYYY'')
         ORDER BY assignment_id';

    END IF;

  ELSE

    -- Delete rows to be updated incrementally
      DELETE FROM hri_cs_asgn_suph_events_ct  ase
      WHERE ase.rowid IN
       (SELECT ase2.rowid
        FROM
         hri_cs_asgn_suph_events_ct  ase2
        ,hri_eq_sprvsr_hrchy_chgs    eq
        WHERE eq.assignment_id = ase2.assignment_id
        AND ase2.effective_start_date >= eq.erlst_evnt_effective_date);

    -- commit
      COMMIT;

    -- End date rows to be updated incrementally
      UPDATE hri_cs_asgn_suph_events_ct  ase
      SET effective_end_date =
        (SELECT (evt.erlst_evnt_effective_date - 1)
         FROM hri_eq_sprvsr_hrchy_chgs evt
         WHERE evt.assignment_id = ase.assignment_id)
      WHERE ase.rowid IN
       (SELECT ase2.rowid
        FROM
         hri_cs_asgn_suph_events_ct  ase2
        ,hri_eq_sprvsr_hrchy_chgs    eq
        WHERE eq.assignment_id = ase2.assignment_id
        AND ase2.effective_end_date >= eq.erlst_evnt_effective_date);

    -- commit
      COMMIT;

    -- Set the SQL statement for the incremental range
    p_sqlstr :=
      'SELECT /*+ PARALLEL(eq, DEFAULT, DEFAULT) */
        assignment_id  object_id
       FROM hri_eq_sprvsr_hrchy_chgs eq
       ORDER BY assignment_id';

  END IF;

  -- Enable WHO trigger
  run_sql_stmt_noerr('ALTER TRIGGER HRI_CS_ASGN_SUPH_EVENTS_CT_WHO ENABLE');

END pre_process;

-- ----------------------------------------------------------------------------
-- Post process entry point
-- ----------------------------------------------------------------------------
PROCEDURE post_process(p_mthd_action_id NUMBER) IS

  l_dummy1        VARCHAR2(2000);
  l_dummy2        VARCHAR2(2000);
  l_schema        VARCHAR2(400);

BEGIN

  -- Check parameters are set
  set_parameters(p_mthd_action_id);

  -- Get HRI schema name - get_app_info populates l_schema
  IF fnd_installation.get_app_info('HRI',l_dummy1, l_dummy2, l_schema) THEN
    null;
  END IF;

  -- Bug 4632040 - gather stats
  fnd_stats.gather_table_stats(l_schema, 'HRI_CS_ASGN_SUPH_EVENTS_CT');

  -- Log the process unless called from test harness
  IF (p_mthd_action_id > -1) THEN

    -- Log process end
    hri_bpl_conc_log.record_process_start('HRI_CS_ASGN_SUPH_EVENTS_CT');
    hri_bpl_conc_log.log_process_end(
       p_status         => TRUE
      ,p_period_from    => TRUNC(g_refresh_start_date)
      ,p_period_to      => TRUNC(SYSDATE)
      ,p_attribute1     => g_full_refresh);

  END IF;

END post_process;

-- Populates table in a single thread
PROCEDURE single_thread_process(p_full_refresh_flag  IN VARCHAR2) IS

  l_end_asg_id  NUMBER;
  l_dummy       VARCHAR2(32000);
  l_from_date   DATE := hri_bpl_parameter.get_bis_global_start_date;

BEGIN

-- get max assignment id
  SELECT max(assignment_id) INTO l_end_asg_id
  FROM per_all_assignments_f;

-- Set globals
  g_refresh_start_date := l_from_date;
  g_full_refresh := p_full_refresh_flag;

-- Pre process
  pre_process(-1, l_dummy);

-- Process range
  IF (p_full_refresh_flag = 'Y') THEN
    process_range_full(0, l_end_asg_id);
  ELSE
    process_range_incr(0, l_end_asg_id);
  END IF;

-- Post process
  post_process(-1);

END single_thread_process;

END hri_opl_suph_events;

/
