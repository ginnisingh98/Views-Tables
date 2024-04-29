--------------------------------------------------------
--  DDL for Package Body HRI_OPL_BDGTS_LBRCST_ORGMGR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OPL_BDGTS_LBRCST_ORGMGR" AS
/* $Header: hrioblom.pkb 120.1 2005/06/29 07:02:29 ddutta noship $ */
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
  INSERT INTO HRI_MDP_BDGTS_LBRCST_ORGMGR_CT (
     orgmgr_id
    ,effective_start_date
    ,effective_end_date
    ,organization_id
    ,job_id
    ,position_id
    ,grade_id
    ,element_type_id
    ,input_value_id
    ,cost_allocation_keyflex_id
    ,budget_value
    ,dr_budget_value
    ,currency_code
    --
    -- WHO Columns
    --
    ,last_update_date
    ,last_update_login
    ,last_updated_by
    ,created_by
    ,creation_date)
   SELECT orgmgr.sup_person_id                                        ORGMGR_ID
          ,GREATEST(period_start_date,orgmgr.effective_start_date)    EFFECTIVE_START_DATE
          ,LEAST(period_end_date,orgmgr.effective_end_date)           EFFECTIVE_END_DATE
          ,organization_id                                            ORGANIZATION_ID
          ,job_id                                                     JOB_ID
          ,position_id                                                POSITION_ID
          ,grade_id                                                   GRADE_ID
          ,element_type_id                                            ELEMENT_TYPE_ID
          ,null                                                       INPUT_VALUE_ID
          ,cost_allocation_keyflex_id                                 COST_ALLOCATION_KEYFLEX_ID
          ,budget_value                                               BUDGET_VALUE
          ,budget_value * DECODE(orgmgr.sub_relative_level, 0, 1, 0)  DR_BUDGET_VALUE
          ,budget_currency_code                                       CURRENCY_CODE
          ,SYSDATE
          ,l_user_id
          ,l_user_id
          ,l_user_id
          ,SYSDATE
    FROM  hri_mb_bdgts_ct bdgts
         ,hri_cs_suph_orgmgr_ct orgmgr
   WHERE bdgts.organization_id         = orgmgr.sub_organization_id
     AND bdgts.budget_measurement_type = 'MONEY';
  --
  dbg(SQL%ROWCOUNT||' records inserted into HRI_MDP_BDGTS_LBRCST_ORGMGR_CT');
  dbg('Exiting process');
  COMMIT;
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
  run_sql_stmt_noerr('ALTER TRIGGER HRI_MDP_BDGTS_LBRCST_ORGMGR_CT_WHO DISABLE');
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
                        p_table_name    => 'HRI_MDP_BDGTS_LBRCST_ORGMGR_CT',
                        p_table_owner   => l_schema);
      --
      -- Truncate the table
      --
      EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || l_schema || '.HRI_MDP_BDGTS_LBRCST_ORGMGR_CT';
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
  hri_bpl_conc_log.record_process_start('HRI_OPL_BDGTS_LBRCST_ORGMGR');
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
                        p_table_name    => 'HRI_MDP_BDGTS_LBRCST_ORGMGR_CT',
                        p_table_owner   => l_schema);
      --
      -- Collect the statistics only when the process is NOT invoked by a concurrent manager
      --
      IF fnd_global.conc_request_id is null THEN
        --
        dbg('Full Refresh selected - gathering stats');
        fnd_stats.gather_table_stats(l_schema,'HRI_MDP_BDGTS_LBRCST_ORGMGR_CT');
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
  run_sql_stmt_noerr('ALTER TRIGGER HRI_MDP_BDGTS_LBRCST_ORGMGR_CT_WHO ENABLE');
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
END HRI_OPL_BDGTS_LBRCST_ORGMGR;

/
