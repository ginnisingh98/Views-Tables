--------------------------------------------------------
--  DDL for Package Body HRI_OPL_WRKFC_ORGMGR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OPL_WRKFC_ORGMGR" AS
/* $Header: hriowfom.pkb 120.0 2005/06/24 07:33:46 appldev noship $ */
-- -----------------------------------------------------------------------------
--                         Multithreading Calls                               --
-- -----------------------------------------------------------------------------
-- This package uses the hri multithreading utility for processing.
-- The Multithreading Utility Provides the Framework for processing collection
-- using multiple threads. The sequence of operation performed by the utility are
--   a) Invoke the PRE_PROCESS procedure to initialize the global variables and
--      return a SQL based on which the processing ranges will be created.
--   b) Invoke the PROCESS_RANGE procedure to process the assignments in the range
--      This part is done by multiple threads. The utility passes the range_id along
--      with the starting and ending object_id for the range. This range is to be
--      by the procedure
--   c) Invoke the POST_PROCESS procedure to perform the post processing tasks
-- -----------------------------------------------------------------------------
--
--
-- Global Multi Threading Array
--
g_mthd_action_array      HRI_ADM_MTHD_ACTIONS%ROWTYPE;
--
-- Global variables representing parameters
--
g_refresh_start_date     DATE;
g_refresh_end_date       DATE;
g_full_refresh           VARCHAR2(5);
--
-- Global flag which determines whether debugging is turned on
--
g_debug_flag             VARCHAR2(5);
--
-- Whether called from a concurrent program
--
g_concurrent_flag         VARCHAR2(5);
-- ----------------------------------------------------------------------------
-- Inserts row into concurrent program log
--
--
PROCEDURE output(p_text  VARCHAR2) IS
BEGIN
  --
  IF (g_concurrent_flag = 'Y') THEN
    --
    -- Write to the concurrent request log
    --
    fnd_file.put_line(fnd_file.log, p_text);
    --
  ELSE
    --
    hr_utility.trace(p_text);
    --
  END IF;
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
  IF (g_debug_flag = 'Y' OR g_mthd_action_array.debug_flag = 'Y') THEN
    --
    -- Write to output
    --
    output(p_text);
    --
  END IF;
--
END dbg;
--
-- ----------------------------------------------------------------------------
-- Runs given sql statement dynamically without raising an exception
-- ----------------------------------------------------------------------------
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
  output('Could not run the following sql:');
  output(SUBSTR(p_sql_stmt,1,230));
  --
END run_sql_stmt_noerr;
--
-- ----------------------------------------------------------------------------
-- SET_PARAMETERS
-- sets up parameters required for the process.
-- ----------------------------------------------------------------------------
--
PROCEDURE set_parameters(p_mthd_action_id  IN NUMBER
                        ,p_mthd_range_id   IN NUMBER DEFAULT NULL) IS
  --
BEGIN
--
-- If parameters haven't already been set, then set them
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
    g_mthd_action_array   := hri_opl_multi_thread.get_mthd_action_array(p_mthd_action_id);
    g_refresh_start_date  := g_mthd_action_array.collect_from_date;
    g_refresh_end_date    := hr_general.end_of_time;
    g_full_refresh        := g_mthd_action_array.full_refresh_flag;
    g_concurrent_flag     := 'Y';
    g_debug_flag          := g_mthd_action_array.debug_flag;
    --
  --
  END IF;
--
END set_parameters;
--
PROCEDURE post_headcount_actuals(p_person_id IN NUMBER )
IS
  --
  -- Variables to populate WHO Columns
  --
  l_current_time       DATE;
  l_user_id            NUMBER;
  --
BEGIN
  --
  dbg('Inside process_headcount_actuals');
  --
  l_current_time       := SYSDATE;
  l_user_id            := fnd_global.user_id;
  --
  INSERT INTO HRI_MAP_WRKFC_ORGMGR_CT (
    --
    -- Organization Manager Id
    --
    orgmgr_id
    --
    -- Effective dates
    --
    ,effective_start_date
    ,effective_end_date
    --
    -- Dimensions
    --
    ,organization_id
    ,job_id
    ,position_id
    ,grade_id
    --
    -- Net changes on effective date for all subordinates
    --
    ,total_headcount
    --
    -- Net changes on effective date for direct reports only
    --
    ,dr_headcount
    --
    -- WHO Columns
    --
    ,last_update_date
    ,last_update_login
    ,last_updated_by
    ,created_by
    ,creation_date)
  SELECT
   dlt.supervisor_person_id      supervisor_person_id
  ,dlt.effective_start_date      effective_start_date
  ,nvl(dlt.effective_end_date,to_date('31-12-4712','DD-MM-YYYY')) effective_end_date
  ,dlt.organization_id           organization_id
  ,dlt.job_id                    job_id
  ,dlt.position_id               position_id
  ,dlt.grade_id                  grade_id
  ,SUM(dlt.headcount_value * dlt.metric_adjust_multiplier)
                                 headcount_adjust
  ,SUM(dlt.headcount_value * dlt.metric_adjust_multiplier * dlt.direct_ind)
                                 dr_headcount_adjust
  --
  -- WHO Columns
  --
  ,SYSDATE
  ,l_user_id
  ,l_user_id
  ,l_user_id
  ,SYSDATE
  FROM   (SELECT
           orgmgr.sup_person_id                         supervisor_person_id
          ,evts.supervisor_id                           direct_supervisor_person_id
          ,GREATEST(evts.effective_change_date,
                    orgmgr.effective_start_date)        effective_start_date
          ,LEAST(evts.effective_change_end_date,
                 orgmgr.effective_end_date )            effective_end_date
          ,evts.person_id                               person_id
          ,evts.assignment_id                           assignment_id
          ,evts.job_id                                  job_id
          ,evts.organization_id                         organization_id
          ,evts.position_id                             position_id
          ,evts.grade_id                                grade_id
          ,evts.headcount                               headcount_value
          ,evts.fte                                     fte_value
          ,DECODE(orgmgr.sub_relative_level, 0, 1, 0)   direct_ind
          ,1                                            metric_adjust_multiplier
         ,orgmgr.sup_level                              supervisor_level
         ,sub_assignment_id                             sub_assignment_id
         FROM
          hri_mb_asgn_events_ct  evts
         ,hri_cs_suph_orgmgr_ct  orgmgr
         WHERE orgmgr.sub_person_id = evts.supervisor_id
           AND (evts.effective_change_date BETWEEN orgmgr.effective_start_date AND orgmgr.effective_end_date
            OR orgmgr.effective_start_date BETWEEN evts.effective_change_date AND evts.effective_change_end_date)
           AND evts.pre_sprtn_asgn_end_ind = 0
           AND evts.worker_term_ind = 0
           AND orgmgr.sup_person_id = p_person_id
        UNION ALL
         SELECT
          orgmgr.sup_person_id                          supervisor_person_id
         ,evts.supervisor_id                            direct_supervisor_person_id
         ,LEAST(evts.effective_change_end_date, orgmgr.effective_end_date) + 1
                                                        effective_start_date
         ,null                                          effective_end_date
         ,evts.person_id                                person_id
         ,evts.assignment_id                            assignment_id
         ,evts.job_id                                   job_id
         ,evts.organization_id                          organization_id
         ,evts.position_id                              position_id
         ,evts.grade_id                                 grade_id
         ,evts.headcount                                headcount_value
         ,evts.fte                                      fte_value
         ,DECODE(orgmgr.sub_relative_level, 0, 1, 0)    direct_ind
         ,-1                                            metric_adjust_multiplier
         ,orgmgr.sup_level                              supervisor_level
         ,sub_assignment_id                             sub_assignment_id
        FROM
          hri_mb_asgn_events_ct  evts
         ,hri_cs_suph_orgmgr_ct  orgmgr
        WHERE orgmgr.sub_person_id = evts.supervisor_id
          AND (orgmgr.effective_end_date BETWEEN evts.effective_change_date AND evts.effective_change_end_date
           OR evts.effective_change_end_date BETWEEN orgmgr.effective_start_date AND orgmgr.effective_end_date)
          AND LEAST(orgmgr.effective_end_date, evts.effective_change_end_date) < to_date('31-12-4712','DD-MM-YYYY')
          AND evts.pre_sprtn_asgn_end_ind = 0
          AND evts.worker_term_ind = 0
          AND orgmgr.sup_person_id = p_person_id ) dlt
  GROUP BY
   dlt.supervisor_person_id
  ,dlt.effective_start_date
  ,dlt.effective_end_date
  ,dlt.organization_id
  ,dlt.job_id
  ,dlt.position_id
  ,dlt.grade_id;
  --
  dbg(SQL%ROWCOUNT||' records inserted into HRI_MAP_WRKFC_ORGMGR_CT');
  dbg('Exiting post_headcount_actuals');
  --

EXCEPTION
  WHEN OTHERS THEN
    --
    output(sqlerrm);
--
END post_headcount_actuals;
--
-- ----------------------------------------------------------------------------
-- PRE_PROCESS
-- Processes actions and inserts data into summary table
-- This procedure is executed for every person in a chunk
-- ----------------------------------------------------------------------------
--
PROCEDURE process_range(p_start_object_id   IN NUMBER
                       ,p_end_object_id     IN NUMBER )
IS
  --
  -- Declare the ref cursor
  --
  type person_to_process is ref cursor;
  --
  c_person_to_process    PERSON_TO_PROCESS;
  --
  -- Holds assignment from the cursor
  --
  l_person_id     NUMBER;
  l_change_date       DATE;
  l_error_step        NUMBER;
  --
  --
  -- Variables to populate WHO Columns
  --
  l_current_time       DATE;
  l_user_id            NUMBER;
  --
BEGIN
  --
  dbg('Inside process_range');
  dbg('range ='||p_start_object_id||' - '||p_end_object_id);
  --
  IF (g_full_refresh = 'Y') THEN
    --
    OPEN c_person_to_process FOR
      SELECT   DISTINCT sup_person_id
        FROM   hri_cs_suph_orgmgr_ct
       WHERE   sup_person_id BETWEEN p_start_object_id and p_end_object_id;
    --
  END IF;
  --
  -- Collect the assignment event details for every supervisor person in the
  -- multithreading range.
  --
  LOOP
    --
    FETCH c_person_to_process INTO l_person_id;
    EXIT WHEN c_person_to_process%NOTFOUND;
    --
    dbg('person = '||l_person_id);
    --
    BEGIN
      --
      -- Call the collect procedure which collects the assignments events
      -- records for the assignment
      --
      post_headcount_actuals(p_person_id => l_person_id);
    END;
    --
  END LOOP;
  --
  dbg('Done processing all persons in the range.');
  --
  -- Commit the data now
  COMMIT;
  --
  IF c_person_to_process%ISOPEN THEN
    --
    CLOSE c_person_to_process;
    --
  END IF;


  --
EXCEPTION
  WHEN OTHERS THEN
    --
    output(sqlerrm);
    --
    IF c_person_to_process%ISOPEN THEN
      --
      CLOSE c_person_to_process;
      --
    END IF;
--
END process_range;
--
-- ----------------------------------------------------------------------------
-- PRE_PROCESS
-- This procedure includes all the logic required for performing the pre_process
-- task of HRI multithreading utility. It drops the indexes and return the SQL
-- required for generating the ranges
-- ----------------------------------------------------------------------------
--
PROCEDURE PRE_PROCESS(
--
  p_mthd_action_id              IN             NUMBER,
  p_sqlstr                                 OUT NOCOPY VARCHAR2) IS
  --
  l_dummy1           VARCHAR2(2000);
  l_dummy2           VARCHAR2(2000);
  l_schema           VARCHAR2(400);
--
BEGIN
--
-- Record the process start
--
  --
  -- Set up the parameters
  --
  set_parameters( p_mthd_action_id => p_mthd_action_id );
  --
  -- Disable the WHO trigger
  --
  run_sql_stmt_noerr('ALTER TRIGGER HRI_MAP_WRKFC_ORGMGR_CT_WHO DISABLE');
  --
  -- ---------------------------------------------------------------------------
  --                       Full Refresh Section
  -- ---------------------------------------------------------------------------
  --
  IF (fnd_installation.get_app_info('HRI',l_dummy1, l_dummy2, l_schema)) THEN
    --
    -- If it's a full refresh
    --
    IF (g_full_refresh = 'Y') THEN
      --
      -- Drop Indexes
      --
      hri_utl_ddl.log_and_drop_indexes(
                        p_application_short_name => 'HRI',
                        p_table_name    => 'HRI_MAP_WRKFC_ORGMGR_CT',
                        p_table_owner   => l_schema);
      --
      -- Truncate the table
      --
      EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || l_schema || '.HRI_MAP_WRKFC_ORGMGR_CT';
      --
      -- Select all people with employee assignments in the collection range.
      -- The bind variable must be present for this sql to work when called
      -- by PYUGEN, else itwill give error.
      --
      p_sqlstr :=
          'SELECT   /*+ parallel (ASG_EVT, default, default) */
                    DISTINCT person_id object_id
           FROM     hri_mb_asgn_events_ct asg_evt
           ORDER BY person_id';
    --
    --                    End of Full Refresh Section
    -- -------------------------------------------------------------------------
    --
    -- -------------------------------------------------------------------------
    --                   Start of Incremental Refresh Section
    --
    ELSE
      --
      -- Incremental Refresh will be supported later.
      --
      NULL;
      --
    --
    --                 End of Incremental Refresh Section
    -- -------------------------------------------------------------------------
    --
    END IF;
    --
  END IF;
  --
--
END PRE_PROCESS;
--
-- ----------------------------------------------------------------------------
-- PROCESS_RANGE
-- This procedure is dynamically the HRI multithreading utility child threads
-- for processing the assignment ranges. The procedure invokes the overloaded
-- process_range procedure to process the range.
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
  l_error_step        NUMBER;
  --
BEGIN
  --
  -- Initialize the global variables
  --
  set_parameters(p_mthd_action_id   => p_mthd_action_id
                ,p_mthd_range_id    => p_mthd_range_id);
  --
  dbg('calling process_range for object range from '||p_start_object_id || ' to '|| p_end_object_id);
  --
  -- Depending on the refresh type call the corresponding refresh program
  --
  IF g_full_refresh = 'Y' THEN
    --
    process_range(p_start_object_id   => p_start_object_id
                 ,p_end_object_id     => p_end_object_id);
    --
  ELSE
    --
    -- Incremental Refresh will be supported later.
    --
    NULL;
    --
  END IF;
  --
  errbuf  := 'SUCCESS';
  retcode := 0;
EXCEPTION
  WHEN others THEN
   output('Error encountered while processing range ='||p_mthd_range_id );
   output(sqlerrm);
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
-- It finishes the processing by updating the BIS_REFRESH_LOG table
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
  set_parameters(p_mthd_action_id);
  --
  hri_bpl_conc_log.record_process_start('HRI_OPL_WRKFC_ORGMGR');
  --
  -- Collect stats for full refresh
  --
  IF (g_full_refresh = 'Y') THEN
    --
    IF (fnd_installation.get_app_info('HRI',l_dummy1, l_dummy2, l_schema)) THEN
      --
      -- Create indexes
      --
      dbg('Full Refresh selected - Creating indexes');
      --
      hri_utl_ddl.recreate_indexes(
                        p_application_short_name => 'HRI',
                        p_table_name    => 'HRI_MAP_WRKFC_ORGMGR_CT',
                        p_table_owner   => l_schema);
      --
      -- Collect the statistics only when the process is NOT invoked by a concurrent manager
      --
      IF fnd_global.conc_request_id is null THEN
        --
        dbg('Full Refresh selected - gathering stats');
        fnd_stats.gather_table_stats(l_schema,'HRI_MAP_WRKFC_ORGMGR_CT');
        --
      END IF;
      --
    END IF;
  --
  ELSE
    --
    -- Incremental Refresh will be supported later.
    --
    NULL;
    --
  END IF;
  --
  -- Enable the WHO trigger on the fact table
  --
  dbg('Enabling the who trigger');
  run_sql_stmt_noerr('ALTER TRIGGER HRI_MAP_WRKFC_ORGMGR_CT_WHO ENABLE');
  --
  hri_bpl_conc_log.log_process_end(
     p_status         => TRUE
    ,p_period_from    => TRUNC(g_refresh_start_date)
    ,p_period_to      => TRUNC(SYSDATE)
    ,p_attribute1     => g_full_refresh);
  --
  dbg('Exiting post_process');
  --
END post_process;
--
-- ----------------------------------------------------------------------------
-- LOAD_TABLE
-- This procedure can be called from the Test harness to populate the table.
-- ----------------------------------------------------------------------------
--
PROCEDURE load_table
IS
  --
  l_sqlstr     VARCHAR2(4000);
  --
  CURSOR c_range_cursor IS
  SELECT mthd_range_id,
         min(object_id) start_object_id,
         max(object_id) end_object_id
  FROM   (SELECT  hri_opl_multi_thread.get_next_mthd_range_id(rownum,200) mthd_range_id
                  ,object_id
          FROM    ( SELECT   DISTINCT sup_person_id object_id
                      FROM   hri_cs_suph_orgmgr_ct
                     ORDER BY sup_person_id)
          )
  GROUP BY mthd_range_id;
  --
BEGIN
  --
  dbg('Inside load_table');
  --
  -- Call Pre Process
  --
  pre_process(p_mthd_action_id             => null,
              p_sqlstr                     => l_sqlstr);
  --
  -- Call Process Range
  --
  FOR l_range IN c_range_cursor LOOP
    --
    dbg('range ='||l_range.start_object_id|| ' - '||l_range.end_object_id );
    process_range(p_start_object_id    => l_range.start_object_id
                 ,p_end_object_id      => l_range.end_object_id);
    --
    COMMIT;
    --
  END LOOP;
  --
  -- Call Post Process
  --
  post_process (p_mthd_action_id => null);
  --
  dbg('Exiting load_table');
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    output('Error in load_table = ');
    output(SQLERRM);
    RAISE;
    --
END load_table;
--
END HRI_OPL_WRKFC_ORGMGR;

/
