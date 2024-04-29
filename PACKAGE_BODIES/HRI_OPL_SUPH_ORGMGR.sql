--------------------------------------------------------
--  DDL for Package Body HRI_OPL_SUPH_ORGMGR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OPL_SUPH_ORGMGR" AS
/* $Header: hriosomh.pkb 120.1 2005/06/29 07:02:47 ddutta noship $ */
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
  INSERT INTO HRI_CS_SUPH_ORGMGR_CT (
     sup_business_group_id
    ,sup_person_id
    ,sup_assignment_id
    ,sup_organization_id
    ,sup_level
    ,sub_business_group_id
    ,sub_person_id
    ,sub_assignment_id
    ,sub_organization_id
    ,sub_level
    ,sub_relative_level
    ,effective_start_date
    ,effective_end_date
    --
    -- WHO Columns
    --
    ,last_update_date
    ,last_update_login
    ,last_updated_by
    ,created_by
    ,creation_date)
   SELECT  SUP_BUSINESS_GROUP_ID
          ,SUP_PERSON_ID
          ,SUP_ASSIGNMENT_ID
          ,ORGANIZATION_ID SUP_ORGANIZATION_ID
          ,SUP_LEVEL
          ,SUB_BUSINESS_GROUP_ID
          ,SUB_PERSON_ID
          ,SUB_ASSIGNMENT_ID
          ,ORGANIZATION_ID SUB_ORGANIZATION_ID
          ,SUB_LEVEL
          ,SUB_RELATIVE_LEVEL
          ,EFFECTIVE_START_DATE
          ,EFFECTIVE_END_DATE
          ,SYSDATE
          ,l_user_id
          ,l_user_id
          ,l_user_id
          ,SYSDATE
     FROM hri_cs_suph ,
         (SELECT hoi.organization_id organization_id,
                 NVL(to_number(hoi.org_information2), -1) manager_person_id ,
                 NVL(fnd_date.canonical_to_date(hoi.org_information3), hr_general.start_of_time) start_date,
                 NVL(fnd_date.canonical_to_date(hoi.org_information4), hr_general.end_of_time)   end_date
            FROM hr_organization_information hoi
           WHERE hoi.org_information_context = 'Organization Name Alias'
             AND hoi.org_information2 IS NOT NULL
             AND EXISTS ( SELECT NULL
                            FROM hr_org_info_types_by_class oitbc,
                                 hr_organization_information org_info
                           WHERE org_info.organization_id         = hoi.organization_id
                             AND org_info.org_information_context = 'CLASS'
                             AND org_info.org_information2        = 'Y'
                             AND oitbc.org_classification         = org_info.org_information1
                             AND oitbc.org_information_type       = 'Organization Name Alias')) org_manager
     WHERE sub_person_id = manager_person_id;
      -- AND effective_start_date BETWEEN start_date AND end_date;
  --
  dbg(SQL%ROWCOUNT||' records inserted into HRI_CS_SUPH_ORGMGR_CT');
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
  dbg('Inside pre_process');
  --
  -- Set up the parameters
  --
  set_parameters;
  --
  -- Disable the WHO trigger
  --
  run_sql_stmt_noerr('ALTER TRIGGER HRI_CS_SUPH_ORGMGR_CT_WHO DISABLE');
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
                        p_table_name    => 'HRI_CS_SUPH_ORGMGR_CT',
                        p_table_owner   => l_schema);
      --
      -- Truncate the table
      --
      EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || l_schema || '.HRI_CS_SUPH_ORGMGR_CT';
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
  hri_bpl_conc_log.record_process_start('HRI_OPL_SUPH_ORGMGR');
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
                        p_table_name    => 'HRI_CS_SUPH_ORGMGR_CT',
                        p_table_owner   => l_schema);
      --
      -- Collect the statistics only when the process is NOT invoked by a concurrent manager
      --
      IF fnd_global.conc_request_id is null THEN
        --
        dbg('Full Refresh selected - gathering stats');
        fnd_stats.gather_table_stats(l_schema,'HRI_CS_SUPH_ORGMGR_CT');
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
  run_sql_stmt_noerr('ALTER TRIGGER HRI_CS_SUPH_ORGMGR_CT_WHO ENABLE');
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
END HRI_OPL_SUPH_ORGMGR;

/
