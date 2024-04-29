--------------------------------------------------------
--  DDL for Package Body HRI_OPL_SUP_WRKFC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OPL_SUP_WRKFC" AS
/* $Header: hriosuwf.pkb 120.3 2006/01/20 02:03:31 jtitmas noship $ */
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
g_redo_reduction         VARCHAR2(5);
g_worker_id              NUMBER;
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
PROCEDURE set_parameters(p_mthd_action_id   IN NUMBER
                        ,p_mthd_stage_code  IN VARCHAR2) IS

  l_dbi_collection_start_date    DATE;

BEGIN

  -- Called from test harness
  IF p_mthd_action_id IS NULL THEN
    g_refresh_start_date   := bis_common_parameters.get_global_start_date;
    g_refresh_end_date     := hr_general.end_of_time;
    g_full_refresh         := 'Y';
    g_concurrent_flag      := 'Y';
    g_debug_flag           := 'Y';
    g_redo_reduction       := NVL(fnd_profile.value('HRI_ENBL_REDO_REDUCTION'),'N');
    g_worker_id            := 1;

  -- If parameters haven't already been set, then set them
  ELSIF (g_refresh_start_date IS NULL) THEN

    l_dbi_collection_start_date := hri_oltp_conc_param.get_date_parameter_value
                                    (p_parameter_name     => 'FULL_REFRESH_FROM_DATE',
                                     p_process_table_name => 'HRI_MAP_SUP_WRKFC');

    -- If called for the first time set the defaulted parameters
    IF (p_mthd_stage_code = 'PRE_PROCESS') THEN

      g_full_refresh := hri_oltp_conc_param.get_parameter_value
                         (p_parameter_name     => 'FULL_REFRESH',
                          p_process_table_name => 'HRI_MAP_SUP_WRKFC');

      -- Log defaulted parameters so the slave processes pick up
      hri_opl_multi_thread.update_parameters
       (p_mthd_action_id    => p_mthd_action_id,
        p_full_refresh      => g_full_refresh,
        p_global_start_date => l_dbi_collection_start_date);

    END IF;

    g_mthd_action_array   := hri_opl_multi_thread.get_mthd_action_array
                              (p_mthd_action_id);
    --
    g_refresh_start_date   := g_mthd_action_array.collect_from_date;
    g_refresh_end_date     := hr_general.end_of_time;
    g_full_refresh         := g_mthd_action_array.full_refresh_flag;
    g_concurrent_flag      := 'Y';
    g_debug_flag           := g_mthd_action_array.debug_flag;
    g_redo_reduction       := NVL(fnd_profile.value('HRI_ENBL_REDO_REDUCTION'),'N');
    g_worker_id            := hri_opl_multi_thread.get_worker_id;
    --
    hri_bpl_conc_log.dbg('Full refresh:   ' || g_full_refresh);
    hri_bpl_conc_log.dbg('Collect from:   ' || to_char(g_refresh_start_date));
  --
  END IF;
--
END set_parameters;
--
-- ----------------------------------------------------------------------------
-- PRE_PROCESS
-- Processes actions and inserts data into summary table
-- This procedure is executed for every assignment in a chunk
-- ----------------------------------------------------------------------------
--
PROCEDURE process_range(p_start_object_id   IN NUMBER
                       ,p_end_object_id     IN NUMBER )
IS
  --
  -- Variables to populate WHO Columns
  --
  l_current_time       DATE;
  l_user_id            NUMBER;
  --
  -- Dynamic SQL
  --
  l_hint              VARCHAR2(100);
  l_partition_clause  VARCHAR2(100);
  l_partition_column  VARCHAR2(100);
  l_part_col_value    VARCHAR2(100);
  l_table_name        VARCHAR2(30);
  l_sql_stmt          VARCHAR2(32000);
  l_rtn               VARCHAR2(30) := '
';
  --
BEGIN
  --
  dbg('Inside process_range');
  dbg('range ='||p_start_object_id||' - '||p_end_object_id);
  --
  -- Set up dynamic sql for redo reduction
  --
  IF (g_redo_reduction = 'Y') THEN
    l_hint := '/*+ APPEND */ ';
    l_table_name := hri_utl_stage_table.get_staging_table_name
                     (p_master_table_name => 'HRI_MAP_SUP_WRKFC');
    l_partition_clause := 'PARTITION (p' || g_worker_id || ') ';
    l_partition_column := l_rtn || '  ,worker_id';
    l_part_col_value   := l_rtn || '  ,' || to_char(g_worker_id);
  ELSE
    l_table_name := 'HRI_MAP_SUP_WRKFC';
  END IF;
  --
  l_current_time       := SYSDATE;
  l_user_id            := fnd_global.user_id;
  --
  l_sql_stmt :=
'INSERT ' || l_hint || 'INTO ' || l_table_name || ' ' || l_partition_clause || '
  (supervisor_person_id
  ,effective_date
  ,geo_area_code
  ,geo_country_code
  ,geo_region_code
  ,geo_city_cid
  ,job_id
  ,job_fnctn_code
  ,job_fmly_code
  ,leaving_reason_code
  ,separation_category
  ,pow_band
  ,perf_band
  ,anl_slry_currency
  ,primary_job_role_code
  ,wkth_wktyp_code
  ,wkth_wktyp_sk_fk
  ,wkth_lvl1_sk_fk
  ,wkth_lvl2_sk_fk
  ,pow_band_sk_fk
  ,anl_slry_adjust
  ,headcount_adjust
  ,fte_adjust
  ,pow_start_date_adjust
  ,term_headcount
  ,hire_headcount
  ,dr_anl_slry_adjust
  ,dr_headcount_adjust
  ,dr_fte_adjust
  ,dr_pow_start_date_adjust
  ,dr_term_headcount
  ,dr_hire_headcount
  ,primary_asg_hdc_cnt_adjust
  ,dr_primary_asg_hdc_cnt_adjust
  ,prmy_hdc_pow_strt_dt_adjust
  ,dr_prmy_hdc_pow_strt_dt_adjust
  ,primary_asg_cnt_adjust
  ,dr_primary_asg_cnt_adjust
  ,primary_pow_strt_dt_adjust
  ,dr_primary_pow_strt_dt_adjust
  ,pow_extn_cnt_adjust
  ,primary_pow_extn_adjust
  ,dr_primary_pow_extn_adjust
  ,admin_row_count
  ,last_update_date
  ,last_update_login
  ,last_updated_by
  ,created_by
  ,creation_date' ||
  l_partition_column || ')
  SELECT /*+ INDEX(dlt) */
   dlt.supervisor_person_id      supervisor_person_id
  ,dlt.effective_date            effective_date
  ,dlt.geo_area_code             geo_area_code
  ,dlt.geo_country_code          geo_country_code
  ,dlt.geo_region_code           geo_region_code
  ,dlt.geo_city_cid              geo_city_cid
  ,dlt.job_id                    job_id
  ,dlt.job_fnctn_code            job_fnctn_code
  ,dlt.job_fmly_code             job_fmly_code
  ,dlt.leaving_reason_code       leaving_reason_code
  ,dlt.separation_category       separation_category
  ,NULL                          pow_band
  ,dlt.perf_band                 perf_band
  ,dlt.anl_slry_currency         anl_slry_currency
  ,dlt.primary_job_role_code     primary_job_role_code
  ,dlt.wkth_wktyp_code           wkth_wktyp_code
  ,dlt.wkth_wktyp_sk_fk          wkth_wktyp_sk_fk
  ,dlt.wkth_lvl1_sk_fk           wkth_lvl1_sk_fk
  ,dlt.wkth_lvl2_sk_fk           wkth_lvl2_sk_fk
  ,dlt.pow_band_sk_fk            pow_band_sk_fk
  ,SUM(dlt.anl_slry_value * dlt.metric_adjust_multiplier)
                                 anl_slry_adjust
  ,SUM(dlt.headcount_value * dlt.metric_adjust_multiplier)
                                 headcount_adjust
  ,SUM(dlt.fte_value * dlt.metric_adjust_multiplier)
                                 fte_adjust
  ,SUM(dlt.pow_value_days_julian * dlt.metric_adjust_multiplier*sign(dlt.headcount_value))
                                 pow_start_date_adjust
  ,SUM(dlt.headcount_value * dlt.worker_term_ind)
                                 term_headcount
  ,SUM(dlt.headcount_value * dlt.worker_hire_ind)
                                 hire_headcount
  ,SUM(dlt.anl_slry_value * dlt.metric_adjust_multiplier * dlt.direct_ind)
                                 dr_anl_slry_adjust
  ,SUM(dlt.headcount_value * dlt.metric_adjust_multiplier * dlt.direct_ind)
                                 dr_headcount_adjust
  ,SUM(dlt.fte_value * dlt.metric_adjust_multiplier * dlt.direct_ind)
                                 dr_fte_adjust
  ,SUM(dlt.pow_value_days_julian * dlt.metric_adjust_multiplier*dlt.direct_ind*sign(dlt.headcount_value))
                                 dr_pow_start_date_adjust
  ,SUM(dlt.headcount_value * dlt.worker_term_ind * dlt.direct_ind)
                                 dr_term_headcount
  ,SUM(dlt.headcount_value * dlt.worker_hire_ind * dlt.direct_ind)
                                 dr_hire_headcount
  ,SUM(dlt.primary_asg_with_hdc_ind*dlt.metric_adjust_multiplier)
                                 primary_asg_hdc_cnt_adjust
  ,SUM(dlt.primary_asg_with_hdc_ind*dlt.metric_adjust_multiplier*dlt.direct_ind)
                                 dr_primary_asg_hdc_cnt_adjust
  ,SUM(dlt.pow_value_days_julian * dlt.metric_adjust_multiplier*primary_asg_with_hdc_ind)
                                 prmy_hdc_pow_strt_dt_adjust
  ,SUM(dlt.pow_value_days_julian * dlt.metric_adjust_multiplier*dlt.direct_ind*primary_asg_with_hdc_ind)
                                 dr_prmy_hdc_pow_strt_dt_adjust
  ,SUM(dlt.primary_flag_ind * dlt.metric_adjust_multiplier)
                                 primary_asg_cnt_adjust
  ,SUM(dlt.primary_flag_ind * dlt.metric_adjust_multiplier * dlt.direct_ind)
                                 dr_primary_asg_cnt_adjust
  ,SUM(dlt.pow_value_days_julian * dlt.primary_flag_ind * dlt.metric_adjust_multiplier)
                                 primary_pow_strt_dt_adjust
  ,SUM(dlt.pow_value_days_julian * dlt.primary_flag_ind * dlt.metric_adjust_multiplier * dlt.direct_ind)
                                 dr_primary_pow_strt_dt_adjust
  ,SUM(sign(pow_extn_days_julian) * dlt.metric_adjust_multiplier) pow_extn_cnt_adjust
  ,SUM(dlt.pow_extn_days_julian * dlt.primary_flag_ind * dlt.metric_adjust_multiplier)
                                 primary_pow_extn_adjust
  ,SUM(dlt.pow_extn_days_julian * dlt.primary_flag_ind * dlt.metric_adjust_multiplier * dlt.direct_ind)
                                 dr_primary_pow_extn_adjust
  , count(*)  admin_row_count
  ,:l_current_time
  ,' || l_user_id || '
  ,' || l_user_id || '
  ,' || l_user_id || '
  ,:l_current_time' ||
   l_part_col_value || '
  FROM hri_map_sup_wrkfc_asg dlt
  WHERE dlt.supervisor_person_id BETWEEN :start_object_id AND :end_object_id
  GROUP BY
   dlt.supervisor_person_id
  ,dlt.effective_date
  ,dlt.geo_area_code
  ,dlt.geo_country_code
  ,dlt.geo_region_code
  ,dlt.geo_city_cid
  ,dlt.job_id
  ,dlt.job_fnctn_code
  ,dlt.job_fmly_code
  ,dlt.leaving_reason_code
  ,dlt.separation_category
  ,dlt.perf_band
  ,dlt.anl_slry_currency
  ,dlt.primary_job_role_code
  ,dlt.wkth_wktyp_code
  ,dlt.wkth_wktyp_sk_fk
  ,dlt.wkth_lvl1_sk_fk
  ,dlt.wkth_lvl2_sk_fk
  ,dlt.pow_band_sk_fk';
  --
  EXECUTE IMMEDIATE l_sql_stmt USING
   l_current_time, l_current_time, p_start_object_id, p_end_object_id;
  --
  dbg(SQL%ROWCOUNT||' records inserted into ' || l_table_name);
  dbg('Exiting process_range');
  --
EXCEPTION WHEN OTHERS THEN
    --
    output(sqlerrm);
    --
    --
    -- RAISE;
    --
--
END process_range;
--
-- ----------------------------------------------------------------------------
-- PROCESS_INCR_RANGE
-- This process refreshes the supervisor delta table incrementally. The table stores
-- aggregated values of adjust columns rquired for derving the various metrics (MV)
-- The MV log on assignment delta will all the changed records. Using this information
-- the sup delta table can be refreshed incrementally. As the table contains only
-- summarized columns the values of the table be restored by
--   + Adding to the column the values for newly inserted and updated record
--   - Subtracting from the column the values for deleted and old records (updated)
-- ----------------------------------------------------------------------------
--
PROCEDURE process_incr_range(p_start_object_id   IN NUMBER
                            ,p_end_object_id     IN NUMBER )
IS
  --
  -- Holds assignment from the cursor
  --
  l_assignment_id     NUMBER;
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
  dbg('Inside process_incr_range range ='||p_start_object_id||' - '||p_end_object_id);
  --
  l_current_time       := SYSDATE;
  l_user_id            := fnd_global.user_id;
  --
  -- Merge the record from the query into the existing table. This will either update
  -- the existing record in the table or insert the record in case it does not exist
  -- in the table
  --
  MERGE INTO hri_map_sup_wrkfc delta
  USING (SELECT   dlt.supervisor_person_id      supervisor_person_id
                  ,dlt.effective_date            effective_date
                  ,dlt.geo_area_code             geo_area_code
                  ,dlt.geo_country_code          geo_country_code
                  ,dlt.geo_region_code           geo_region_code
                  ,dlt.geo_city_cid              geo_city_cid
                  ,dlt.job_id                    job_id
                  ,dlt.job_fnctn_code            job_fnctn_code
                  ,dlt.job_fmly_code             job_fmly_code
                  ,dlt.leaving_reason_code       leaving_reason_code
                  ,dlt.separation_category       separation_category
                  ,dlt.perf_band                 perf_band
                  ,dlt.anl_slry_currency         anl_slry_currency
                  ,dlt.primary_job_role_code     primary_job_role_code
                  ,dlt.wkth_wktyp_code           wkth_wktyp_code
                  ,dlt.wkth_wktyp_sk_fk          wkth_wktyp_sk_fk
                  ,dlt.wkth_lvl1_sk_fk           wkth_lvl1_sk_fk
                  ,dlt.wkth_lvl2_sk_fk           wkth_lvl2_sk_fk
                  ,dlt.pow_band_sk_fk            pow_band_sk_fk
                  ,SUM(CASE WHEN OLD_NEW$$ = 'N' THEN
                           1
                      ELSE
                           -1
                   END ) admin_row_count
                  ,SUM(CASE WHEN OLD_NEW$$ = 'N' THEN
                            dlt.anl_slry_value * dlt.metric_adjust_multiplier
                       ELSE
                            (dlt.anl_slry_value * dlt.metric_adjust_multiplier) * -1
                       END) anl_slry_adjust
                  ,SUM(CASE WHEN OLD_NEW$$ = 'N' THEN
                            dlt.headcount_value * dlt.metric_adjust_multiplier
                       ELSE
                            (dlt.headcount_value * dlt.metric_adjust_multiplier) * -1
                       END) headcount_adjust
                  ,SUM(CASE WHEN OLD_NEW$$ = 'N' THEN
                            dlt.fte_value * dlt.metric_adjust_multiplier
                       ELSE
                            (dlt.fte_value * dlt.metric_adjust_multiplier) * -1
                       END) fte_adjust
                  ,SUM(CASE WHEN OLD_NEW$$ = 'N' THEN
                            dlt.pow_value_days_julian * dlt.metric_adjust_multiplier*sign(dlt.headcount_value)
                       ELSE
                            (dlt.pow_value_days_julian * dlt.metric_adjust_multiplier*sign(dlt.headcount_value)) * -1
                       END) pow_start_date_adjust
                  ,SUM(CASE WHEN OLD_NEW$$ = 'N' THEN
                            dlt.headcount_value * dlt.worker_term_ind
                       ELSE
                            (dlt.headcount_value * dlt.worker_term_ind) * -1
                       END) term_headcount
                  ,SUM(CASE WHEN OLD_NEW$$ = 'N' THEN
                            dlt.headcount_value * dlt.worker_hire_ind
                       ELSE
                            (dlt.headcount_value * dlt.worker_hire_ind) * -1
                       END) hire_headcount
                  ,SUM(CASE WHEN OLD_NEW$$ = 'N' THEN
                            dlt.anl_slry_value * dlt.metric_adjust_multiplier * dlt.direct_ind
                       ELSE
                            (dlt.anl_slry_value * dlt.metric_adjust_multiplier * dlt.direct_ind) * -1
                       END) dr_anl_slry_adjust
                  ,SUM(CASE WHEN OLD_NEW$$ = 'N' THEN
                            dlt.headcount_value * dlt.metric_adjust_multiplier * dlt.direct_ind
                       ELSE
                            (dlt.headcount_value * dlt.metric_adjust_multiplier * dlt.direct_ind) * -1
                       END) dr_headcount_adjust
                  ,SUM(CASE WHEN OLD_NEW$$ = 'N' THEN
                            dlt.fte_value * dlt.metric_adjust_multiplier * dlt.direct_ind
                       ELSE
                            (dlt.fte_value * dlt.metric_adjust_multiplier * dlt.direct_ind) * -1
                       END) dr_fte_adjust
                  ,SUM(CASE WHEN OLD_NEW$$ = 'N' THEN
                            dlt.pow_value_days_julian * dlt.metric_adjust_multiplier*dlt.direct_ind*sign(dlt.headcount_value)
                       ELSE
                            (dlt.pow_value_days_julian * dlt.metric_adjust_multiplier*dlt.direct_ind*sign(dlt.headcount_value)) * -1
                       END) dr_pow_start_date_adjust
                  ,SUM(CASE WHEN OLD_NEW$$ = 'N' THEN
                            dlt.headcount_value * dlt.worker_term_ind * dlt.direct_ind
                       ELSE
                            (dlt.headcount_value * dlt.worker_term_ind * dlt.direct_ind) * -1
                       END) dr_term_headcount
                  ,SUM(CASE WHEN OLD_NEW$$ = 'N' THEN
                            dlt.headcount_value * dlt.worker_hire_ind * dlt.direct_ind
                       ELSE
                            (dlt.headcount_value * dlt.worker_hire_ind * dlt.direct_ind) * -1
                       END) dr_hire_headcount
                  ,SUM(CASE WHEN OLD_NEW$$ = 'N' THEN
                            dlt.primary_asg_with_hdc_ind*dlt.metric_adjust_multiplier
                       ELSE
                            (dlt.primary_asg_with_hdc_ind*dlt.metric_adjust_multiplier) * -1
                       END) primary_asg_hdc_cnt_adjust
                  ,SUM(CASE WHEN OLD_NEW$$ = 'N' THEN
                            dlt.primary_asg_with_hdc_ind*dlt.metric_adjust_multiplier*dlt.direct_ind
                       ELSE
                            (dlt.primary_asg_with_hdc_ind*dlt.metric_adjust_multiplier*dlt.direct_ind) * -1
                       END) dr_primary_asg_hdc_cnt_adjust
                  ,SUM(CASE WHEN OLD_NEW$$ = 'N' THEN
                            dlt.pow_value_days_julian * dlt.metric_adjust_multiplier*primary_asg_with_hdc_ind
                       ELSE
                            (dlt.pow_value_days_julian * dlt.metric_adjust_multiplier*primary_asg_with_hdc_ind) * -1
                       END) prmy_hdc_pow_strt_dt_adjust
                  ,SUM(CASE WHEN OLD_NEW$$ = 'N' THEN
                            dlt.pow_value_days_julian * dlt.metric_adjust_multiplier*dlt.direct_ind*primary_asg_with_hdc_ind
                       ELSE
                            (dlt.pow_value_days_julian * dlt.metric_adjust_multiplier*dlt.direct_ind*primary_asg_with_hdc_ind) * -1
                       END) dr_prmy_hdc_pow_strt_dt_adjust
                  ,SUM(CASE WHEN OLD_NEW$$ = 'N' THEN
                            dlt.primary_flag_ind * dlt.metric_adjust_multiplier
                       ELSE
                            (dlt.primary_flag_ind * dlt.metric_adjust_multiplier) * -1
                       END) primary_asg_cnt_adjust
                  ,SUM(CASE WHEN OLD_NEW$$ = 'N' THEN
                            dlt.primary_flag_ind * dlt.metric_adjust_multiplier * dlt.direct_ind
                       ELSE
                            (dlt.primary_flag_ind * dlt.metric_adjust_multiplier * dlt.direct_ind) * -1
                       END) dr_primary_asg_cnt_adjust
                  ,SUM(CASE WHEN OLD_NEW$$ = 'N' THEN
                            dlt.pow_value_days_julian * dlt.primary_flag_ind * dlt.metric_adjust_multiplier
                       ELSE
                            (dlt.pow_value_days_julian * dlt.primary_flag_ind * dlt.metric_adjust_multiplier) * -1
                       END) primary_pow_strt_dt_adjust
                  ,SUM(CASE WHEN OLD_NEW$$ = 'N' THEN
                            dlt.pow_value_days_julian * dlt.primary_flag_ind * dlt.metric_adjust_multiplier * dlt.direct_ind
                       ELSE
                            (dlt.pow_value_days_julian * dlt.primary_flag_ind * dlt.metric_adjust_multiplier * dlt.direct_ind) * -1
                       END) dr_primary_pow_strt_dt_adjust
                   --
                   -- Extensions
                   --
                  ,SUM(CASE WHEN OLD_NEW$$ = 'N' THEN
                            sign(dlt.pow_extn_days_julian) * dlt.metric_adjust_multiplier
                       ELSE
                            (sign(dlt.pow_extn_days_julian) * dlt.metric_adjust_multiplier) * -1
                       END) pow_extn_cnt_adjust
                  ,SUM(CASE WHEN OLD_NEW$$ = 'N' THEN
                            dlt.pow_extn_days_julian * dlt.primary_flag_ind * dlt.metric_adjust_multiplier
                       ELSE
                            (dlt.pow_extn_days_julian * dlt.primary_flag_ind * dlt.metric_adjust_multiplier) * -1
                       END) primary_pow_extn_adjust
                  ,SUM(CASE WHEN OLD_NEW$$ = 'N' THEN
                            dlt.pow_extn_days_julian * dlt.primary_flag_ind * dlt.metric_adjust_multiplier * dlt.direct_ind
                       ELSE
                            (dlt.pow_extn_days_julian * dlt.primary_flag_ind * dlt.metric_adjust_multiplier * dlt.direct_ind) * -1
                       END) dr_primary_pow_extn_adjust
         FROM    mlog$_hri_map_sup_wrkfc_as dlt
         WHERE   dlt.supervisor_person_id between p_start_object_id and p_end_object_id
         GROUP BY    dlt.supervisor_person_id
                    ,dlt.effective_date
                    ,dlt.geo_area_code
                    ,dlt.geo_country_code
                    ,dlt.geo_region_code
                    ,dlt.geo_city_cid
                    ,dlt.job_id
                    ,dlt.job_fnctn_code
                    ,dlt.job_fmly_code
                    ,dlt.leaving_reason_code
                    ,dlt.separation_category
                    ,dlt.perf_band
                    ,dlt.anl_slry_currency
                    ,dlt.primary_job_role_code
                    ,dlt.wkth_wktyp_code
                    ,dlt.wkth_wktyp_sk_fk
                    ,dlt.wkth_lvl1_sk_fk
                    ,dlt.wkth_lvl2_sk_fk
                    ,dlt.pow_band_sk_fk
        ) aggr
  ON (  aggr.supervisor_person_id          = delta.supervisor_person_id
        AND  aggr.effective_date	   = delta.effective_date
        AND  aggr.geo_area_code            = delta.geo_area_code
        AND  aggr.geo_country_code	   = delta.geo_country_code
        AND  aggr.geo_region_code	   = delta.geo_region_code
        AND  aggr.geo_city_cid	           = delta.geo_city_cid
        AND  aggr.job_id		   = delta.job_id
        AND  aggr.job_fnctn_code	   = delta.job_fnctn_code
        AND  aggr.job_fmly_code	           = delta.job_fmly_code
        AND  aggr.leaving_reason_code	   = delta.leaving_reason_code
        AND  aggr.separation_category	   = delta.separation_category
        AND  aggr.perf_band		   = delta.perf_band
        AND  aggr.anl_slry_currency	   = delta.anl_slry_currency
        AND  aggr.primary_job_role_code    = delta.primary_job_role_code
        AND  aggr.wkth_wktyp_code	   = delta.wkth_wktyp_code
        AND  aggr.wkth_wktyp_sk_fk	   = delta.wkth_wktyp_sk_fk
        AND  aggr.wkth_lvl1_sk_fk	   = delta.wkth_lvl1_sk_fk
        AND  aggr.wkth_lvl2_sk_fk	   = delta.wkth_lvl2_sk_fk
        AND  aggr.pow_band_sk_fk	   = delta.pow_band_sk_fk)
  WHEN MATCHED THEN
    UPDATE SET
       delta.anl_slry_adjust		   = delta.anl_slry_adjust                + aggr.anl_slry_adjust
      ,delta.headcount_adjust		   = delta.headcount_adjust               + aggr.headcount_adjust
      ,delta.fte_adjust			   = delta.fte_adjust                     + aggr.fte_adjust
      ,delta.pow_start_date_adjust	   = delta.pow_start_date_adjust          + aggr.pow_start_date_adjust
      ,delta.term_headcount		   = delta.term_headcount                 + aggr.term_headcount
      ,delta.hire_headcount		   = delta.hire_headcount                 + aggr.hire_headcount
      ,delta.dr_anl_slry_adjust		   = delta.dr_anl_slry_adjust             + aggr.dr_anl_slry_adjust
      ,delta.dr_headcount_adjust           = delta.dr_headcount_adjust            + aggr.dr_headcount_adjust
      ,delta.dr_fte_adjust		   = delta.dr_fte_adjust                  + aggr.dr_fte_adjust
      ,delta.dr_pow_start_date_adjust	   = delta.dr_pow_start_date_adjust       + aggr.dr_pow_start_date_adjust
      ,delta.dr_term_headcount		   = delta.dr_term_headcount              + aggr.dr_term_headcount
      ,delta.dr_hire_headcount		   = delta.dr_hire_headcount              + aggr.dr_hire_headcount
      ,delta.primary_asg_hdc_cnt_adjust	   = delta.primary_asg_hdc_cnt_adjust     + aggr.primary_asg_hdc_cnt_adjust
      ,delta.dr_primary_asg_hdc_cnt_adjust = delta.dr_primary_asg_hdc_cnt_adjust  + aggr.dr_primary_asg_hdc_cnt_adjust
      ,delta.prmy_hdc_pow_strt_dt_adjust   = delta.prmy_hdc_pow_strt_dt_adjust    + aggr.prmy_hdc_pow_strt_dt_adjust
      ,delta.dr_prmy_hdc_pow_strt_dt_adjust= delta.dr_prmy_hdc_pow_strt_dt_adjust + aggr.dr_prmy_hdc_pow_strt_dt_adjust
      ,delta.primary_asg_cnt_adjust        = delta.primary_asg_cnt_adjust         + aggr.primary_asg_cnt_adjust
      ,delta.dr_primary_asg_cnt_adjust	   = delta.dr_primary_asg_cnt_adjust      + aggr.dr_primary_asg_cnt_adjust
      ,delta.primary_pow_strt_dt_adjust	   = delta.primary_pow_strt_dt_adjust     + aggr.primary_pow_strt_dt_adjust
      ,delta.dr_primary_pow_strt_dt_adjust = delta.dr_primary_pow_strt_dt_adjust  + aggr.dr_primary_pow_strt_dt_adjust
      ,delta.pow_extn_cnt_adjust	   = delta.pow_extn_cnt_adjust		  + aggr.pow_extn_cnt_adjust
      ,delta.primary_pow_extn_adjust	   = delta.primary_pow_extn_adjust	  + aggr.primary_pow_extn_adjust
      ,delta.dr_primary_pow_extn_adjust    = delta.dr_primary_pow_extn_adjust 	  + aggr.dr_primary_pow_extn_adjust
      --
      -- Count
      --
      ,delta.admin_row_count                = delta.admin_row_count + aggr.admin_row_count
      --
      -- WHO Columns
      --
      ,last_update_date                     = SYSDATE
      ,last_update_login                    = l_user_id
      ,last_updated_by                      = l_user_id
  WHEN NOT MATCHED THEN
   INSERT (
      --
      -- Supervisor id
      --
      delta.supervisor_person_id
      -- Effective date
      ,delta.effective_date
      --
      -- Dimensions
      --
      ,delta.geo_area_code
      ,delta.geo_country_code
      ,delta.geo_region_code
      ,delta.geo_city_cid
      ,delta.job_id
      ,delta.job_fnctn_code
      ,delta.job_fmly_code
      ,delta.leaving_reason_code
      ,delta.separation_category
      ,delta.perf_band
      ,delta.anl_slry_currency
      ,delta.primary_job_role_code
      ,delta.wkth_wktyp_code
      ,delta.wkth_wktyp_sk_fk
      ,delta.wkth_lvl1_sk_fk
      ,delta.wkth_lvl2_sk_fk
      ,delta.pow_band_sk_fk
      --
      -- Net changes on effective date for all subordinates
      --
      ,delta.anl_slry_adjust
      ,delta.headcount_adjust
      ,delta.fte_adjust
      ,delta.pow_start_date_adjust
      --
      -- Total termination,delta.hire on efective_date for all subordinates
      --
      ,delta.term_headcount
      ,delta.hire_headcount
      --
      -- Net changes on effective date for direct reports only
      --
      ,delta.dr_anl_slry_adjust
      ,delta.dr_headcount_adjust
      ,delta.dr_fte_adjust
      ,delta.dr_pow_start_date_adjust
      --
      -- Total termination,delta.hire on efective_date for direct reports only
      --
      ,delta.dr_term_headcount
      ,delta.dr_hire_headcount
      --
      -- 4013742
      --
      ,delta.primary_asg_hdc_cnt_adjust
      ,delta.dr_primary_asg_hdc_cnt_adjust
      ,delta.prmy_hdc_pow_strt_dt_adjust
      ,delta.dr_prmy_hdc_pow_strt_dt_adjust
      --
      -- Period of work to be calulated for all primary aasignments
      --
      ,delta.primary_asg_cnt_adjust
      ,delta.dr_primary_asg_cnt_adjust
      ,delta.primary_pow_strt_dt_adjust
      ,delta.dr_primary_pow_strt_dt_adjust
      --
      -- Extension Period
      --
      ,delta.pow_extn_cnt_adjust
      ,delta.primary_pow_extn_adjust
      ,delta.dr_primary_pow_extn_adjust
      --
      ,delta.admin_row_count
      --
      -- WHO Columns
      --
      ,delta.last_update_date
      ,delta.last_update_login
      ,delta.last_updated_by
      ,delta.created_by
      ,delta.creation_date
      )
      VALUES
      (
      --
      -- Supervisor id
      --
      aggr.supervisor_person_id
      -- Effective date
      ,aggr.effective_date
      --
      -- Dimensions
      --
      ,aggr.geo_area_code
      ,aggr.geo_country_code
      ,aggr.geo_region_code
      ,aggr.geo_city_cid
      ,aggr.job_id
      ,aggr.job_fnctn_code
      ,aggr.job_fmly_code
      ,aggr.leaving_reason_code
      ,aggr.separation_category
      ,aggr.perf_band
      ,aggr.anl_slry_currency
      ,aggr.primary_job_role_code
      ,aggr.wkth_wktyp_code
      ,aggr.wkth_wktyp_sk_fk
      ,aggr.wkth_lvl1_sk_fk
      ,aggr.wkth_lvl2_sk_fk
      ,aggr.pow_band_sk_fk
      --
      -- Net changes on effective date for all subordinates
      --
      ,aggr.anl_slry_adjust
      ,aggr.headcount_adjust
      ,aggr.fte_adjust
      ,aggr.pow_start_date_adjust
      --
      -- Total termination,aggr.hire on efective_date for all subordinates
      --
      ,aggr.term_headcount
      ,aggr.hire_headcount
      --
      -- Net changes on effective date for direct reports only
      --
      ,aggr.dr_anl_slry_adjust
      ,aggr.dr_headcount_adjust
      ,aggr.dr_fte_adjust
      ,aggr.dr_pow_start_date_adjust
      --
      -- Total termination,aggr.hire on efective_date for direct reports only
      --
      ,aggr.dr_term_headcount
      ,aggr.dr_hire_headcount
      --
      -- 4013742
      --
      ,aggr.primary_asg_hdc_cnt_adjust
      ,aggr.dr_primary_asg_hdc_cnt_adjust
      ,aggr.prmy_hdc_pow_strt_dt_adjust
      ,aggr.dr_prmy_hdc_pow_strt_dt_adjust
      --
      -- Period of work to be calulated for all primary aasignments
      --
      ,aggr.primary_asg_cnt_adjust
      ,aggr.dr_primary_asg_cnt_adjust
      ,aggr.primary_pow_strt_dt_adjust
      ,aggr.dr_primary_pow_strt_dt_adjust
      --
      -- Extension Period
      --
      ,aggr.pow_extn_cnt_adjust
      ,aggr.primary_pow_extn_adjust
      ,aggr.dr_primary_pow_extn_adjust
      --
      ,aggr.admin_row_count
      --
      -- WHO Columns
      --
      ,l_current_time
      ,l_user_id
      ,l_user_id
      ,l_user_id
      ,l_current_time
      );
  --
  COMMIT;
  --
  -- In case all records for a supervisor has been deleted from the asg delta table,
  -- the row_count for that record will be zero. Delete all such records from the table.
  --
  DELETE
  FROM   hri_map_sup_wrkfc
  WHERE  supervisor_person_id BETWEEN p_start_object_id and p_end_object_id
  AND    admin_row_count = 0;
  --
  COMMIT;
  --
  dbg('Exiting process_range');
  --
EXCEPTION
  WHEN OTHERS THEN
    --
    output(sqlerrm);
    --
--
END process_incr_range;
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
  set_parameters
   (p_mthd_action_id  => p_mthd_action_id,
    p_mthd_stage_code => 'PRE_PROCESS');
  --
  -- Disable the WHO trigger
  --
  run_sql_stmt_noerr('ALTER TRIGGER HRI_MAP_SUP_WRKFC_WHO DISABLE');
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
      -- Set up staging table for redo reduction
      --
      IF (g_redo_reduction = 'Y') THEN
        hri_utl_stage_table.set_up
         (p_owner => l_schema,
          p_master_table_name => 'HRI_MAP_SUP_WRKFC');
      END IF;
      --
      -- Disable the materilized view logs
      --
      -- manage_mview_logs(p_schema   => l_schema , ,p_enable_disable  => 'D');
      --
      -- Drop Indexes
      --
      hri_utl_ddl.log_and_drop_indexes(
                        p_application_short_name => 'HRI',
                        p_table_name    => 'HRI_MAP_SUP_WRKFC',
                        p_table_owner   => l_schema);
      --
      -- Truncate the table
      --
      EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || l_schema || '.HRI_MAP_SUP_WRKFC';
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
      -- Select all people  for whom events have occurred. The bind variable must
      -- be present for this sql to work when called by PYUGEN, else it will
      -- give error.
      --
      p_sqlstr :=
          'SELECT   /*+ parallel (EQ, default, default) */
                    DISTINCT supervisor_person_id object_id
           FROM     mlog$_hri_map_sup_wrkfc_as eq
           ORDER BY supervisor_person_id';
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
  set_parameters
   (p_mthd_action_id  => p_mthd_action_id,
    p_mthd_stage_code => 'PROCESS_RANGE');
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
    process_incr_range(p_start_object_id   => p_start_object_id
                      ,p_end_object_id     => p_end_object_id);
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
  set_parameters
   (p_mthd_action_id  => p_mthd_action_id,
    p_mthd_stage_code => 'POST_PROCESS');
  --
  hri_bpl_conc_log.record_process_start('HRI_OPL_SUP_WRKFC');
  --
  -- Collect stats for full refresh
  --
  IF (g_full_refresh = 'Y') THEN
    --
    IF (fnd_installation.get_app_info('HRI',l_dummy1, l_dummy2, l_schema)) THEN
      --
      -- Redo reduction: Move data to master table and purge staging table
      --
      IF (g_redo_reduction = 'Y') THEN
        hri_utl_stage_table.clean_up
         (p_owner => l_schema,
          p_master_table_name => 'HRI_MAP_SUP_WRKFC');
      END IF;
      --
      -- Enable the materialized view logs
      --
      --manage_mview_logs(p_schema         => l_schema,p_enable_disable => 'E');
      --
      --
      -- Create indexes
      --
      dbg('Full Refresh selected - Creating indexes');
      --
      hri_utl_ddl.recreate_indexes(
                        p_application_short_name => 'HRI',
                        p_table_name    => 'HRI_MAP_SUP_WRKFC',
                        p_table_owner   => l_schema);
      --
      -- Collect the statistics only when the process is NOT invoked by a concurrent manager
      --
      IF fnd_global.conc_request_id is null THEN
        --
        dbg('Full Refresh selected - gathering stats');
        fnd_stats.gather_table_stats(l_schema,'HRI_MAP_SUP_WRKFC');
        --
      END IF;
      --
    END IF;
  --
  ELSE
    --
    -- During incremental run the MV log on the asg delta table should be purged
    -- as the MV log is not used by any of the other MV
    --
    IF (fnd_installation.get_app_info('HRI',l_dummy1, l_dummy2, l_schema)) THEN
      --
      -- This procedure purges rows from the materialized view log.
      --
      dbms_mview.purge_log(master => l_schema || '.HRI_MAP_SUP_WRKFC_ASG',
                             num  => 99999);
      --
    END IF;
    --
  END IF;
  --
  -- Enable the WHO trigger on the events fact table
  --
  dbg('Enabling the who trigger');
  run_sql_stmt_noerr('ALTER TRIGGER HRI_MAP_SUP_WRKFC_WHO ENABLE');
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
          FROM    (SELECT   DISTINCT person_id object_id
                   FROM     hri_mb_asgn_events_ct
                   ORDER BY person_id)
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
END HRI_OPL_SUP_WRKFC;

/
