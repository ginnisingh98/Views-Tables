--------------------------------------------------------
--  DDL for Package Body HRI_OPL_ACTLS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OPL_ACTLS" AS
/* $Header: hrioactl.pkb 120.3 2005/12/22 21:36:27 ddutta noship $ */
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
  TYPE assignment_actions_tab IS TABLE OF pay_assignment_actions.assignment_action_id%TYPE;
  l_assignment_actions  assignment_actions_tab;
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
  l_current_time       := SYSDATE;
  l_user_id            := fnd_global.user_id;

  IF (g_full_refresh = 'Y') THEN
    --
     SELECT assignment_action_id
             BULK COLLECT INTO l_assignment_actions
        FROM pay_assignment_actions paa,
             pay_payroll_actions    ppa
       WHERE paa.payroll_action_id = ppa.payroll_action_id
         AND ppa.action_type IN ('C', 'S')
         AND ppa.effective_date BETWEEN g_refresh_start_date AND g_refresh_end_date
         AND paa.assignment_id  BETWEEN p_start_object_id and p_end_object_id;
    --
  END IF;
  --
  --
  FORALL i IN l_assignment_actions.FIRST .. l_assignment_actions.LAST SAVE EXCEPTIONS
  --
   INSERT INTO HRI_MB_ACTLS_CT (
     hri_mb_actls_ct_id
    ,effective_date
    ,date_earned
    ,assignment_id
    ,organization_id
    ,job_id
    ,position_id
    ,grade_id
    ,element_type_id
    ,input_value_id
    ,cost_allocation_keyflex_id
    -- ,debit_or_credit
    ,actual_value
    ,currency_code
    --
    -- WHO Columns
    --
    ,last_update_date
    ,last_update_login
    ,last_updated_by
    ,created_by
    ,creation_date)
   SELECT
       hri_mb_actls_ct_s.nextval
      ,ppa2.effective_date
      ,ppa2.date_earned
      ,paaf.assignment_id
      ,paaf.organization_id
      ,paaf.job_id
      ,paaf.position_id
      ,paaf.grade_id
      ,pivf.element_type_id
      ,pc.input_value_id
      ,pc.cost_allocation_keyflex_id
       -- ,pc.debit_or_credit
      ,pc.costed_value
      ,petf.output_currency_code
      ,l_current_time
      ,l_user_id
      ,l_user_id
      ,l_user_id
      ,l_current_time
     FROM  per_all_assignments_f paaf,
           pay_assignment_actions paa2,
           pay_payroll_actions ppa2,
           pay_run_results     ppr,
           pay_costs pc,
           pay_input_values_f pivf,
           pay_element_types_f petf
    WHERE paaf.assignment_id        = paa2.assignment_id
      AND paa2.payroll_action_id    = ppa2.payroll_action_id
      AND paa2.assignment_action_id = ppr.assignment_action_id
      AND ppr.run_result_id         = pc.run_result_id
      --AND nvl(pc.distributed_input_value_id, pc.input_value_id) = pivf.input_value_id
      AND pc.input_value_id         = pivf.input_value_id
      AND pivf.element_type_id      = petf.element_type_id
      AND ppr.element_type_id       = petf.element_type_id
      AND pc.balance_or_cost        = 'C'
      AND pc.assignment_action_id   = l_assignment_actions(i)
      AND ppa2.effective_date BETWEEN paaf.effective_start_date AND paaf.effective_end_date
      AND ppa2.effective_date BETWEEN pivf.effective_start_date AND pivf.effective_end_date
      AND ppa2.effective_date BETWEEN petf.effective_start_date AND petf.effective_end_date
      AND ppa2.effective_date BETWEEN g_refresh_start_date AND g_refresh_end_date;
  --
  dbg(SQL%ROWCOUNT||' records inserted into HRI_MB_ACTLS_CT');
  dbg('Done processing all assignments in the range.');
  --
  -- Commit the data now
  COMMIT;
  --
--
EXCEPTION
  WHEN OTHERS THEN
    --
    output(sqlerrm);
    --
    -- RAISE;
    --
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
  run_sql_stmt_noerr('ALTER TRIGGER HRI_MB_ACTLS_CT_WHO DISABLE');
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
                        p_table_name    => 'HRI_MB_ACTLS_CT',
                        p_table_owner   => l_schema);
      --
      -- Truncate the table
      --
      EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || l_schema || '.HRI_MB_ACTLS_CT';
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
  hri_bpl_conc_log.record_process_start('HRI_OPL_ACTLS');
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
                        p_table_name    => 'HRI_MB_ACTLS_CT',
                        p_table_owner   => l_schema);
      --
      -- Collect the statistics only when the process is NOT invoked by a concurrent manager
      --
      IF fnd_global.conc_request_id is null THEN
        --
        dbg('Full Refresh selected - gathering stats');
        fnd_stats.gather_table_stats(l_schema,'HRI_MB_ACTLS_CT');
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
  run_sql_stmt_noerr('ALTER TRIGGER HRI_MB_ACTLS_CT_WHO ENABLE');
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
          FROM    (SELECT DISTINCT asgn.assignment_id object_id
                     FROM per_all_assignments_f   asgn
                    WHERE asgn.assignment_type in ('E','C')
                      AND asgn.effective_end_date >= g_refresh_start_date - 1
                    ORDER BY asgn.assignment_id)
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
END HRI_OPL_ACTLS;

/
