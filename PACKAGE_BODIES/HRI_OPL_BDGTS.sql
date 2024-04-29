--------------------------------------------------------
--  DDL for Package Body HRI_OPL_BDGTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OPL_BDGTS" AS
/* $Header: hriobdgt.pkb 120.1 2005/06/29 07:00:42 ddutta noship $ */
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
-- Function to retrieve the budget_measurement_type
-- ----------------------------------------------------------------------------
--
FUNCTION get_budget_measurement_type(p_unit_of_measure_id IN NUMBER )
RETURN VARCHAR2
IS
--
l_budget_measurement_type VARCHAR2(30);
--
 CURSOR csr_budget_measurement_type is
   SELECT system_type_cd
     FROM per_shared_types
    WHERE shared_type_id = p_unit_of_measure_id
      AND lookup_type = 'BUDGET_MEASUREMENT_TYPE';
BEGIN
    OPEN csr_budget_measurement_type;
   FETCH csr_budget_measurement_type INTO l_budget_measurement_type;
   CLOSE csr_budget_measurement_type;
   --
   RETURN l_budget_measurement_type;
   --
--
END get_budget_measurement_type;
--
-- ----------------------------------------------------------------------------
-- This procedure inserts headcount budgets
-- ----------------------------------------------------------------------------
--
PROCEDURE insert_headcount_budgets (p_budget_id               IN NUMBER
                                   ,p_business_group_id       IN NUMBER
		                       ,p_budgeted_entity_cd      IN VARCHAR2
                                   ,p_budget_measurement_type IN VARCHAR2
                                   ,p_currency_code           IN VARCHAR2
                                   ,p_budget_aggregate        IN VARCHAR2
                                   ,p_budget_start_date       IN DATE
                                   ,p_budget_end_date         IN DATE
                                   ,p_budget_version_id       IN NUMBER
                                   ,p_version_start_date      IN DATE
                                   ,p_version_end_date        IN DATE
                                   ,p_unit                    IN NUMBER)
IS
  --
  --
  -- Variables to populate WHO Columns
  --
  l_current_time       DATE;
  l_user_id            NUMBER;

BEGIN
  --
  --
  dbg('Inside insert_headcount_budgets');
  --
  l_current_time       := SYSDATE;
  l_user_id            := fnd_global.user_id;
  --
  --
  INSERT INTO HRI_MB_BDGTS_CT (
     HRI_MB_BDGTS_CT_ID
    ,BUDGET_ID
    ,BUSINESS_GROUP_ID
    ,BUDGETED_ENTITY_CD
    ,BUDGET_MEASUREMENT_TYPE
    ,BUDGET_CURRENCY_CODE
    ,BUDGET_AGGREGATE
    ,BUDGET_START_DATE
    ,BUDGET_END_DATE
    ,BUDGET_VERSION_ID
    ,VERSION_START_DATE
    ,VERSION_END_DATE
    ,BUDGET_DETAIL_ID
    ,ORGANIZATION_ID
    ,JOB_ID
    ,POSITION_ID
    ,GRADE_ID
    ,BUDGET_PERIOD_ID
    ,PERIOD_START_DATE
    ,PERIOD_END_DATE
    ,BUDGET_VALUE
    --
    -- WHO Columns
    --
    ,last_update_date
    ,last_update_login
    ,last_updated_by
    ,created_by
    ,creation_date)
   SELECT
       hri_mb_bdgts_ct_s.nextval
      ,p_budget_id
      ,p_business_group_id
      ,p_budgeted_entity_cd
      ,p_budget_measurement_type
      ,p_currency_code
      ,p_budget_aggregate
      ,p_budget_start_date
      ,p_budget_end_date
      ,p_budget_version_id
      ,p_version_start_date
      ,p_version_end_date
      ,det.budget_detail_id
	,nvl(det.organization_id, -1)
	,nvl(det.job_id, -1)
	,nvl(det.position_id, -1)
	,nvl(det.grade_id,-1)
	,prd.budget_period_id
	,ptps.start_date
	,ptpe.end_date
      ,CASE WHEN p_unit = 1 THEN prd.budget_unit1_value
            WHEN p_unit = 2 THEN prd.budget_unit2_value
       ELSE prd.budget_unit3_value
       END budget_value
      ,SYSDATE
      ,l_user_id
      ,l_user_id
      ,l_user_id
      ,SYSDATE
     FROM pqh_budget_details  det,
	    pqh_budget_periods  prd,
	    per_time_periods    ptps,
	    per_time_periods    ptpe
    WHERE det.budget_version_id      = p_budget_version_id
      AND det.budget_detail_id       = prd.budget_detail_id
      AND prd.start_time_period_id   = ptps.time_period_id
      AND prd.end_time_period_id     = ptpe.time_period_id ;
  --
  dbg(SQL%ROWCOUNT||' headcount records inserted into HRI_MB_BDGTS_CT');
  dbg('Exiting insert_headcount_budgets');
--
EXCEPTION
  WHEN OTHERS THEN
    --
    output(sqlerrm);
    --
    -- RAISE;
    --
--
END insert_headcount_budgets;
--
-- ----------------------------------------------------------------------------
-- This procedure inserts labor cost budgets
-- ----------------------------------------------------------------------------
--
PROCEDURE insert_laborcost_budgets (p_budget_id               IN NUMBER
                                   ,p_business_group_id       IN NUMBER
		                       ,p_budgeted_entity_cd      IN VARCHAR2
                                   ,p_budget_measurement_type IN VARCHAR2
                                   ,p_currency_code           IN VARCHAR2
                                   ,p_budget_aggregate        IN VARCHAR2
                                   ,p_budget_start_date       IN DATE
                                   ,p_budget_end_date         IN DATE
                                   ,p_budget_version_id       IN NUMBER
                                   ,p_version_start_date      IN DATE
                                   ,p_version_end_date        IN DATE
                                   ,p_unit                    IN NUMBER)
IS
  --
  --
  -- Variables to populate WHO Columns
  --
  l_current_time       DATE;
  l_user_id            NUMBER;

BEGIN
  --
  --
  dbg('Inside insert_laborcost_budgets');
  --
  l_current_time       := SYSDATE;
  l_user_id            := fnd_global.user_id;
  --
  --
  INSERT INTO HRI_MB_BDGTS_CT (
     HRI_MB_BDGTS_CT_ID
    ,BUDGET_ID
    ,BUSINESS_GROUP_ID
    ,BUDGETED_ENTITY_CD
    ,BUDGET_MEASUREMENT_TYPE
    ,BUDGET_CURRENCY_CODE
    ,BUDGET_AGGREGATE
    ,BUDGET_START_DATE
    ,BUDGET_END_DATE
    ,BUDGET_VERSION_ID
    ,VERSION_START_DATE
    ,VERSION_END_DATE
    ,BUDGET_DETAIL_ID
    ,ORGANIZATION_ID
    ,JOB_ID
    ,POSITION_ID
    ,GRADE_ID
    ,BUDGET_PERIOD_ID
    ,PERIOD_START_DATE
    ,PERIOD_END_DATE
    ,BUDGET_SET_ID
    ,BUDGET_ELEMENT_ID
    ,ELEMENT_TYPE_ID
    ,BUDGET_FUND_SRC_ID
    ,COST_ALLOCATION_KEYFLEX_ID
    ,BUDGET_VALUE
    --
    -- WHO Columns
    --
    ,last_update_date
    ,last_update_login
    ,last_updated_by
    ,created_by
    ,creation_date)
   SELECT
       hri_mb_bdgts_ct_s.nextval
      ,p_budget_id
      ,p_business_group_id
      ,p_budgeted_entity_cd
      ,p_budget_measurement_type
      ,p_currency_code
      ,p_budget_aggregate
      ,p_budget_start_date
      ,p_budget_end_date
      ,p_budget_version_id
      ,p_version_start_date
      ,p_version_end_date
      ,det.budget_detail_id
	,nvl(det.organization_id, -1)
	,nvl(det.job_id, -1)
	,nvl(det.position_id, -1)
	,nvl(det.grade_id,-1)
	,prd.budget_period_id
	,ptps.start_date
	,ptpe.end_date
	,bset.budget_set_id
	,ele.budget_element_id
	,ele.element_type_id
	,src.budget_fund_src_id
	,src.cost_allocation_keyflex_id
      ,CASE WHEN p_unit = 1 THEN
            (src.distribution_percentage * ( ele.distribution_percentage * bset.budget_unit1_value ) / 100 ) / 100
            WHEN p_unit = 2 THEN
            (src.distribution_percentage * ( ele.distribution_percentage * bset.budget_unit2_value ) / 100 ) / 100
       ELSE (src.distribution_percentage * ( ele.distribution_percentage * bset.budget_unit3_value ) / 100 ) / 100
       END budget_value
      ,SYSDATE
      ,l_user_id
      ,l_user_id
      ,l_user_id
      ,SYSDATE
     FROM pqh_budget_details  det,
	    pqh_budget_periods  prd,
	    per_time_periods    ptps,
	    per_time_periods    ptpe,
	    pqh_budget_sets     bset,
	    pqh_budget_elements ele,
	    pqh_budget_fund_srcs src
    WHERE det.budget_version_id      = p_budget_version_id
      AND det.budget_detail_id       = prd.budget_detail_id
      AND prd.budget_period_id       = bset.budget_period_id
      AND prd.start_time_period_id   = ptps.time_period_id
      AND prd.end_time_period_id     = ptpe.time_period_id
      AND bset.budget_set_id         = ele.budget_set_id
      AND ele.budget_element_id      = src.budget_element_id;
  --
  dbg(SQL%ROWCOUNT||' labor cost records inserted into HRI_MB_BDGTS_CT');
  dbg('Exiting insert_laborcost_budgets');
--
EXCEPTION
  WHEN OTHERS THEN
    --
    output(sqlerrm);
    --
    -- RAISE;
    --
--
END insert_laborcost_budgets;
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
  l_unit1_measure      VARCHAR2(30);
  l_unit2_measure      VARCHAR2(30);
  l_unit3_measure      VARCHAR2(30);
  --
  --
  CURSOR csr_budgets IS
    SELECT bdgt.budget_id,
           bdgt.budget_name,
           bdgt.business_group_id,
           bdgt.budgeted_entity_cd,
           NVL(bdgt.currency_code, pqh_budget.get_currency_cd(bdgt.budget_id)) CURRENCY_CODE,
           bdgt.budget_unit1_id,
           bdgt.budget_unit2_id,
           bdgt.budget_unit3_id,
	     bdgt.budget_unit1_aggregate,
	     bdgt.budget_unit2_aggregate,
	     bdgt.budget_unit3_aggregate,
	     bdgt.budget_start_date,
	     bdgt.budget_end_date,
	     ver.budget_version_id,
	     ver.date_from,
	     ver.date_to
      FROM pqh_budgets bdgt,
           pqh_budget_versions ver
     WHERE bdgt.position_control_flag = 'Y'
       AND bdgt.budgeted_entity_cd   IN ('ORGANIZATION','POSITION')
       AND bdgt.budget_id             = ver.budget_id
       AND (( bdgt.budget_start_date    BETWEEN g_refresh_start_date AND g_refresh_end_date )
        OR ( g_refresh_start_date BETWEEN bdgt.budget_start_date AND bdgt.budget_end_date ))
       AND ver.budget_version_id = ( SELECT max(budget_version_id)
                                       FROM pqh_budget_versions pbv
                                      WHERE pbv.budget_id = bdgt.budget_id );
BEGIN
  --
  dbg('Inside process');
  --
  l_current_time       := SYSDATE;
  l_user_id            := fnd_global.user_id;
  --
  --
  FOR csr_budget_rec IN csr_budgets LOOP
    --
      l_unit1_measure := get_budget_measurement_type(csr_budget_rec.budget_unit1_id);
      l_unit2_measure := get_budget_measurement_type(csr_budget_rec.budget_unit2_id);
      l_unit3_measure := get_budget_measurement_type(csr_budget_rec.budget_unit3_id);
      --
      IF l_unit1_measure = 'HEAD' THEN
         insert_headcount_budgets(p_budget_id               => csr_budget_rec.budget_id
                                 ,p_business_group_id       => csr_budget_rec.business_group_id
		                     ,p_budgeted_entity_cd      => csr_budget_rec.budgeted_entity_cd
                                 ,p_budget_measurement_type => l_unit1_measure
                                 ,p_currency_code           => csr_budget_rec.currency_code
                                 ,p_budget_aggregate        => csr_budget_rec.budget_unit1_aggregate
                                 ,p_budget_start_date       => csr_budget_rec.budget_start_date
                                 ,p_budget_end_date         => csr_budget_rec.budget_end_date
                                 ,p_budget_version_id       => csr_budget_rec.budget_version_id
                                 ,p_version_start_date      => csr_budget_rec.date_from
                                 ,p_version_end_date        => csr_budget_rec.date_to
                                 ,p_unit                    => 1 );
      ELSIF l_unit1_measure = 'MONEY' THEN
         insert_laborcost_budgets(p_budget_id               => csr_budget_rec.budget_id
                                 ,p_business_group_id       => csr_budget_rec.business_group_id
		                     ,p_budgeted_entity_cd      => csr_budget_rec.budgeted_entity_cd
                                 ,p_budget_measurement_type => l_unit1_measure
                                 ,p_currency_code           => csr_budget_rec.currency_code
                                 ,p_budget_aggregate        => csr_budget_rec.budget_unit1_aggregate
                                 ,p_budget_start_date       => csr_budget_rec.budget_start_date
                                 ,p_budget_end_date         => csr_budget_rec.budget_end_date
                                 ,p_budget_version_id       => csr_budget_rec.budget_version_id
                                 ,p_version_start_date      => csr_budget_rec.date_from
                                 ,p_version_end_date        => csr_budget_rec.date_to
                                 ,p_unit                    => 1 );

      END IF;

      IF l_unit2_measure = 'HEAD' THEN
         insert_headcount_budgets(p_budget_id               => csr_budget_rec.budget_id
                                 ,p_business_group_id       => csr_budget_rec.business_group_id
		                     ,p_budgeted_entity_cd      => csr_budget_rec.budgeted_entity_cd
                                 ,p_budget_measurement_type => l_unit2_measure
                                 ,p_currency_code           => csr_budget_rec.currency_code
                                 ,p_budget_aggregate        => csr_budget_rec.budget_unit2_aggregate
                                 ,p_budget_start_date       => csr_budget_rec.budget_start_date
                                 ,p_budget_end_date         => csr_budget_rec.budget_end_date
                                 ,p_budget_version_id       => csr_budget_rec.budget_version_id
                                 ,p_version_start_date      => csr_budget_rec.date_from
                                 ,p_version_end_date        => csr_budget_rec.date_to
                                 ,p_unit                    => 2 );
      ELSIF l_unit2_measure = 'MONEY' THEN
         insert_laborcost_budgets(p_budget_id               => csr_budget_rec.budget_id
                                 ,p_business_group_id       => csr_budget_rec.business_group_id
		                     ,p_budgeted_entity_cd      => csr_budget_rec.budgeted_entity_cd
                                 ,p_budget_measurement_type => l_unit2_measure
                                 ,p_currency_code           => csr_budget_rec.currency_code
                                 ,p_budget_aggregate        => csr_budget_rec.budget_unit2_aggregate
                                 ,p_budget_start_date       => csr_budget_rec.budget_start_date
                                 ,p_budget_end_date         => csr_budget_rec.budget_end_date
                                 ,p_budget_version_id       => csr_budget_rec.budget_version_id
                                 ,p_version_start_date      => csr_budget_rec.date_from
                                 ,p_version_end_date        => csr_budget_rec.date_to
                                 ,p_unit                    => 2 );

      END IF;
      --
      IF l_unit3_measure = 'HEAD' THEN
         insert_headcount_budgets(p_budget_id               => csr_budget_rec.budget_id
                                 ,p_business_group_id       => csr_budget_rec.business_group_id
		                     ,p_budgeted_entity_cd      => csr_budget_rec.budgeted_entity_cd
                                 ,p_budget_measurement_type => l_unit3_measure
                                 ,p_currency_code           => csr_budget_rec.currency_code
                                 ,p_budget_aggregate        => csr_budget_rec.budget_unit1_aggregate
                                 ,p_budget_start_date       => csr_budget_rec.budget_start_date
                                 ,p_budget_end_date         => csr_budget_rec.budget_end_date
                                 ,p_budget_version_id       => csr_budget_rec.budget_version_id
                                 ,p_version_start_date      => csr_budget_rec.date_from
                                 ,p_version_end_date        => csr_budget_rec.date_to
                                 ,p_unit                    => 3 );
      ELSIF l_unit3_measure = 'MONEY' THEN
         insert_laborcost_budgets(p_budget_id               => csr_budget_rec.budget_id
                                 ,p_business_group_id       => csr_budget_rec.business_group_id
		                     ,p_budgeted_entity_cd      => csr_budget_rec.budgeted_entity_cd
                                 ,p_budget_measurement_type => l_unit3_measure
                                 ,p_currency_code           => csr_budget_rec.currency_code
                                 ,p_budget_aggregate        => csr_budget_rec.budget_unit3_aggregate
                                 ,p_budget_start_date       => csr_budget_rec.budget_start_date
                                 ,p_budget_end_date         => csr_budget_rec.budget_end_date
                                 ,p_budget_version_id       => csr_budget_rec.budget_version_id
                                 ,p_version_start_date      => csr_budget_rec.date_from
                                 ,p_version_end_date        => csr_budget_rec.date_to
                                 ,p_unit                    => 3 );

      END IF;
      --
      COMMIT;
    --
  END LOOP;
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
  run_sql_stmt_noerr('ALTER TRIGGER HRI_MB_BDGTS_CT_WHO DISABLE');
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
                        p_table_name    => 'HRI_MB_BDGTS_CT',
                        p_table_owner   => l_schema);
      --
      -- Truncate the table
      --
      EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || l_schema || '.HRI_MB_BDGTS_CT';
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
  hri_bpl_conc_log.record_process_start('HRI_OPL_BDGTS');
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
                        p_table_name    => 'HRI_MB_BDGTS_CT',
                        p_table_owner   => l_schema);
      --
      -- Collect the statistics only when the process is NOT invoked by a concurrent manager
      --
      IF fnd_global.conc_request_id is null THEN
        --
        dbg('Full Refresh selected - gathering stats');
        fnd_stats.gather_table_stats(l_schema,'HRI_MB_BDGTS_CT');
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
  run_sql_stmt_noerr('ALTER TRIGGER HRI_MB_BDGTS_CT_WHO ENABLE');
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
END HRI_OPL_BDGTS;

/
