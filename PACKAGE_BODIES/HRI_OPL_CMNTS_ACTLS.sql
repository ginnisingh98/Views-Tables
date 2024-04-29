--------------------------------------------------------
--  DDL for Package Body HRI_OPL_CMNTS_ACTLS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OPL_CMNTS_ACTLS" AS
/* $Header: hriocact.pkb 120.4 2006/01/03 21:46:31 ddutta noship $ */
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
  IF (g_debug_flag = 'Y') THEN
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
PROCEDURE set_parameters IS
--
BEGIN
--
    g_refresh_start_date   := bis_common_parameters.get_global_start_date;
    g_refresh_end_date     := hr_general.end_of_time;
    g_full_refresh         := 'Y';
    g_concurrent_flag      := 'Y';
    g_debug_flag           := 'Y';
--
END set_parameters;
--
-- ----------------------------------------------------------------------------
-- PROCESS
-- Processes actions and inserts data into summary table
-- This procedure is executed for every person in a chunk
-- ----------------------------------------------------------------------------
--
PROCEDURE process(p_full_refresh_flag IN VARCHAR2)
IS
  --
  -- Variables to populate WHO Columns
  --
  l_current_time       DATE;
  l_user_id            NUMBER;
  --
BEGIN
  --
  dbg('Inside process');
  --
  l_current_time       := SYSDATE;
  l_user_id            := fnd_global.user_id;
  --
  INSERT INTO HRI_MD_CMNTS_ACTLS_CT (
     EFFECTIVE_START_DATE
    ,EFFECTIVE_END_DATE
    ,ASSIGNMENT_ID
    ,ORGANIZATION_ID
    ,JOB_ID
    ,POSITION_ID
    ,GRADE_ID
    ,ELEMENT_TYPE_ID
    ,INPUT_VALUE_ID
    ,COST_ALLOCATION_KEYFLEX_ID
    ,COMMITMENT_VALUE
    ,ACTUAL_VALUE
    ,CURRENCY_CODE
    --
    -- WHO Columns
    --
    ,last_update_date
    ,last_update_login
    ,last_updated_by
    ,created_by
    ,creation_date )
   SELECT /*+ parallel(cmnts) */
          cmnts.effective_start_date
         ,cmnts.effective_end_date
         ,cmnts.assignment_id
         ,nvl(cmnts.organization_id, -1) organization_id
         ,nvl(cmnts.job_id, -1)          job_id
         ,nvl(cmnts.position_id, -1)     position_id
         ,nvl(cmnts.grade_id, -1)        grade_id
         ,cmnts.element_type_id
         ,cmnts.input_value_id
         ,(SELECT distinct actl.cost_allocation_keyflex_id
             FROM hri_mb_actls_ct actl
            WHERE actl.assignment_id   = cmnts.assignment_id
              AND actl.element_type_id = cmnts.element_type_id
           -- AND actl.input_value_id  = cmnts.input_value_id
              AND actl.effective_date BETWEEN cmnts.effective_start_date AND cmnts.effective_end_date
              AND ROWNUM = 1) cost_allocation_keyflex_id
         ,cmnts.commitment_value
         ,(SELECT sum(actls.actual_value)
             FROM hri_mb_actls_ct actls
            WHERE actls.assignment_id   = cmnts.assignment_id
              AND actls.element_type_id = cmnts.element_type_id
              AND actls.input_value_id  = NVL(( SELECT input_value_id
                                                FROM pay_input_values_f
                                               WHERE element_type_id = actls.element_type_id
                                                 AND name = 'Pay Value'
                                                 AND actls.effective_date between effective_start_date and effective_end_date)
                                               ,cmnts.input_value_id )
              AND actls.effective_date BETWEEN cmnts.effective_start_date AND cmnts.effective_end_date) actual_value
         ,cmnts.currency_code
         ,SYSDATE
         ,l_user_id
         ,l_user_id
         ,l_user_id
         ,SYSDATE
     FROM hri_mb_cmnts_ct cmnts
    WHERE cmnts.effective_start_date BETWEEN g_refresh_start_date AND g_refresh_end_date;
  --
  dbg(SQL%ROWCOUNT||' commitment records inserted into HRI_MD_CMNTS_ACTLS_CT');
  --
  COMMIT;
  --
  dbg('Exiting process');
  --
EXCEPTION
  WHEN OTHERS THEN
    --
    output(sqlerrm);
    --
    -- RAISE;
    --
--
END process;
--
-- ----------------------------------------------------------------------------
-- PRE_PROCESS
-- ----------------------------------------------------------------------------
--
PROCEDURE PRE_PROCESS IS
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
  set_parameters;
  --
  -- Disable the WHO trigger
  --
  run_sql_stmt_noerr('ALTER TRIGGER HRI_MD_CMNTS_ACTLS_CT_WHO DISABLE');
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
                        p_table_name    => 'HRI_MD_CMNTS_ACTLS_CT',
                        p_table_owner   => l_schema);
      --
      -- Truncate the table
      --
      EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || l_schema || '.HRI_MD_CMNTS_ACTLS_CT';
    --
    END IF;
    --
  END IF;
  --
--
END PRE_PROCESS;
--
-- ----------------------------------------------------------------------------
-- POST_PROCESS
-- It finishes the processing by updating the BIS_REFRESH_LOG table
-- ----------------------------------------------------------------------------
--
PROCEDURE post_process IS
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
  hri_bpl_conc_log.record_process_start('HRI_OPL_CMNTS_ACTLS');
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
                        p_table_name    => 'HRI_MD_CMNTS_ACTLS_CT',
                        p_table_owner   => l_schema);
      --
      -- Collect the statistics only when the process is NOT invoked by a concurrent manager
      --
      IF fnd_global.conc_request_id is null THEN
        --
        dbg('Full Refresh selected - gathering stats');
        fnd_stats.gather_table_stats(l_schema,'HRI_MD_CMNTS_ACTLS_CT');
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
  run_sql_stmt_noerr('ALTER TRIGGER HRI_MD_CMNTS_ACTLS_CT_WHO ENABLE');
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
-- PROCESS
-- ----------------------------------------------------------------------------
--
PROCEDURE process(
   errbuf                          OUT NOCOPY VARCHAR2
  ,retcode                         OUT NOCOPY NUMBER
  ,p_full_refresh_flag              IN        VARCHAR2)
IS
  --
  l_error_step        NUMBER;
  --
BEGIN
  --
  -- Initialize the global variables
  --
  pre_process;
  --
  -- Depending on the refresh type call the corresponding refresh program
  --
  IF g_full_refresh = 'Y' THEN
    --
    process(p_full_refresh_flag   => g_full_refresh);
    --
  ELSE
    --
    -- Incremental Refresh will be supported later.
    --
    NULL;
    --
  END IF;
  --
  post_process;

  errbuf  := 'SUCCESS';
  retcode := 0;
EXCEPTION
  WHEN others THEN
   output('Error encountered while processing ...');
   output(sqlerrm);
   errbuf := SQLERRM;
   retcode := SQLCODE;
   --
   RAISE;
   --
END process;

--
-- ----------------------------------------------------------------------------
-- LOAD_TABLE
-- This procedure can be called from the Test harness to populate the table.
-- ----------------------------------------------------------------------------
--
PROCEDURE load_table
IS
  --
BEGIN
  --
  dbg('Inside load_table');
  --
  -- Call Pre Process
  --
  pre_process;
  --
  -- Call Process
  --
  process(p_full_refresh_flag => g_full_refresh);
  --
  -- Call Post Process
  --
  post_process;
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
END HRI_OPL_CMNTS_ACTLS;

/
