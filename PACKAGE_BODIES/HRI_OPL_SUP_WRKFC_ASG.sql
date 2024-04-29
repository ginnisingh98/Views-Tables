--------------------------------------------------------
--  DDL for Package Body HRI_OPL_SUP_WRKFC_ASG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OPL_SUP_WRKFC_ASG" AS
/* $Header: hrioswka.pkb 120.7 2006/02/09 06:19:01 jtitmas noship $ */
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
--
-- Whether an MV Log exist on the table
--
g_mv_log_exists_flag      VARCHAR2(5);
--
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
-- -----------------------------------------------------------------------------
-- This procedure manages the operations done on the materialized view logs of
-- the master table HRI_MAP_SUP_WRKFC_ASG
-- -----------------------------------------------------------------------------
--
PROCEDURE manage_mview_logs(p_schema IN VARCHAR2
                           ,p_enable_disable IN VARCHAR2) IS
  --
  -- Cursor to check the presence of materialized view log
  --
  CURSOR mvlog_exist_csr IS
  SELECT 1
  FROM   dba_mview_logs
  WHERE  master = 'HRI_MAP_SUP_WRKFC_ASG'
  AND    log_owner = p_schema;
  --
  -- Variable to hold the number of materialized log existing
  --
  l_no_of_logs       PLS_INTEGER;
  --
BEGIN
  --
  -- Open the cursor for first time only
  -- The value of the global flag gets set to 'Y' if materialized view log exists
  -- Once its presence is determined, the cursor should not be opened again
  --
  IF g_mv_log_exists_flag IS NULL THEN
    --
    -- Open the cursor to check for the presence of materialized view log
    --
    OPEN mvlog_exist_csr;
    FETCH mvlog_exist_csr INTO l_no_of_logs;
      --
      -- If materialized view log(s) is present then set the flag to Yes, else
      -- set it to No
      --
      IF l_no_of_logs > 0 THEN
        --
        g_mv_log_exists_flag := 'Y';
        --
      ELSE
        --
        g_mv_log_exists_flag := 'N';
        --
      END IF;
      --
    CLOSE mvlog_exist_csr;
    --
  END IF;
  --
  -- If materialized view log(s) exists then process them
  --
  IF g_mv_log_exists_flag = 'Y' THEN
    --
    -- For enabling the materialized view logs
    --
    IF p_enable_disable = 'E' THEN
      --
      -- This procedure purges rows from the materialized view log.
      --
      dbms_mview.purge_log(master => p_schema || '.HRI_MAP_SUP_WRKFC_ASG'
                          ,num    => 99999);
      --
      -- This procedure ensures that the materialized view data for the master
      -- table is valid and that the master table is in the proper state. It
      -- must be called after a master table is reorganized
      --
      dbms_mview.end_table_reorganization(tabowner  => p_schema
                                         ,tabname => 'HRI_MAP_SUP_WRKFC_ASG');
      --
      -- This procedure purges rows from the materialized view log.
      --
      dbms_mview.purge_log(master => p_schema || '.HRI_MAP_SUP_WRKFC_ASG',
                             num  => 99999);
    --
    -- For disabling the materialized view logs
    --
    ELSE
      --
      -- This procedure performs a process to preserve materialized view data
      -- needed for refresh. It must be called before a master table is reorganized
      --
      dbms_mview.begin_table_reorganization(tabowner => p_schema,
                                            tabname  => 'HRI_MAP_SUP_WRKFC_ASG');
      --
    END IF;
    --
  END IF;
  --
EXCEPTION
  WHEN OTHERS THEN
    --
    -- Close the cursor if it is open
    --
    IF mvlog_exist_csr%ISOPEN THEN
      --
      CLOSE mvlog_exist_csr;
      --
    END IF;
    --
    RAISE;
    --
END manage_mview_logs;
--
-- ----------------------------------------------------------------------------
-- UPDATE_JOB_CHANGES
-- This procedure is used for incrementally refreshing the asg delta table
-- when the job family or job function dimesion levels are changed for a job
-- -------------------------------------------------------------------------
--
PROCEDURE update_job_changes(p_start_object_id   IN NUMBER
                            ,p_end_object_id     IN NUMBER )
IS
BEGIN
  --
  dbg('Inside update_job_changes');
  --
  -- Update all records for which the job family / function information
  --
  UPDATE hri_map_sup_wrkfc_asg asg_dlt
  SET    (asg_dlt.job_fmly_code , asg_dlt.job_fnctn_code) =
             (SELECT jobh.job_fmly_code ,
                     jobh.job_fnctn_code
              FROM   hri_cs_jobh_ct jobh
              WHERE  jobh.job_id = asg_dlt.job_id)
  WHERE  (assignment_id, evts_effective_end_date) in
         (SELECT asgn.assignment_id,
                 asgn.effective_change_end_date
          FROM   hri_mb_asgn_events_ct asgn,
                 hri_eq_asg_sup_wrfc eq
          WHERE  asgn.job_id = eq.source_id
          AND    eq.source_type = 'JOB'
          AND    eq.source_id  BETWEEN p_start_object_id AND p_end_object_id);
  --
  dbg(sql%rowcount || ' records update due to job changes');
  --
  COMMIT;
  --
END update_job_changes;
--
-- ----------------------------------------------------------------------------
-- UPDATE_PRMRY_JOB_ROLE_CHANGES
-- This procedure is used for incrementally refreshing the asg delta table
-- with job roles when the job family or job function dimesion levels are
-- changed for a job
-- -------------------------------------------------------------------------
--
PROCEDURE update_prmry_job_role_changes(p_start_object_id   IN NUMBER
                                       ,p_end_object_id     IN NUMBER )
IS
BEGIN
  --
  dbg('Inside update_prmry_job_role_changes');
  --
  -- Update all records for which the job family / function information
  -- have changed
  --
  UPDATE hri_map_sup_wrkfc_asg asg_dlt
  SET    asg_dlt.primary_job_role_code =
             (SELECT jbrl.job_role_code
              FROM   hri_cs_job_job_role_ct jbrl
              WHERE  jbrl.job_id = asg_dlt.job_id
              AND    jbrl.primary_role_for_job_flag = 'Y')
  WHERE  (assignment_id, evts_effective_end_date) IN
         (SELECT asgn.assignment_id,
                 asgn.effective_change_end_date
          FROM   hri_mb_asgn_events_ct asgn,
                 hri_eq_asg_sup_wrfc eq
          WHERE  asgn.job_id = eq.source_id
          AND    eq.source_type = 'PRIMARY_JOB_ROLE'
          AND    eq.source_id  BETWEEN p_start_object_id AND p_end_object_id);
  --
  dbg(sql%rowcount || ' records updated due to primary job role changes');
  --
  COMMIT;
  --
END update_prmry_job_role_changes;
--
-- ----------------------------------------------------------------------------
-- UPDATE_LOCATION_CHANGES
-- This procedure is used for incrementally refreshing the asg delta table
-- when the location related details are changed for a location
-- -------------------------------------------------------------------------
--
PROCEDURE update_location_changes(p_start_object_id   IN NUMBER
                                   ,p_end_object_id     IN NUMBER )
IS
BEGIN
  --
  dbg('Inside update_location_changes');
  --
  -- Update all records for which the location information has changed
  --
  UPDATE hri_map_sup_wrkfc_asg asg_dlt
  SET    (asg_dlt.geo_area_code,asg_dlt.geo_country_code,asg_dlt.geo_region_code,asg_dlt.geo_city_cid) =
             (SELECT geoh.area_code,
                     geoh.country_code,
                     geoh.region_code,
                     geoh.city_cid
              FROM   hri_cs_geo_lochr_ct geoh
              WHERE  geoh.location_id = asg_dlt.location_id)
  WHERE  (assignment_id, evts_effective_end_date) IN
         (SELECT asgn.assignment_id,
                 asgn.effective_change_end_date
          FROM   hri_mb_asgn_events_ct asgn,
                 hri_eq_asg_sup_wrfc eq
          WHERE  asgn.location_id = eq.source_id
          AND    eq.source_type = 'LOCATION'
          AND    eq.source_id  BETWEEN p_start_object_id AND p_end_object_id);
  --
  dbg(sql%rowcount || ' records updated due to location changes');
  --
  COMMIT;
  --
END update_location_changes;
--
-- ----------------------------------------------------------------------------
-- UPDATE_PERSON_TYPE_CHANGES
-- This procedure is used for incrementally refreshing the asg delta table
-- when the person type related details are changed
-- -------------------------------------------------------------------------
--
PROCEDURE update_person_type_changes(p_start_object_id   IN NUMBER
                                     ,p_end_object_id     IN NUMBER )
IS
BEGIN
  null;
  --
  dbg('Inside update_person_type_changes');
  --
  -- Update all records for which the person type information has changed
  --
  UPDATE hri_map_sup_wrkfc_asg asg_dlt
  SET    (asg_dlt.wkth_wktyp_sk_fk,asg_dlt.wkth_lvl1_sk_fk,asg_dlt.wkth_lvl2_sk_fk,asg_dlt.wkth_wktyp_code) =
             (SELECT prsn.wkth_wktyp_sk_fk,
                     prsn.wkth_lvl1_sk_fk,
                     prsn.wkth_lvl2_sk_fk,
                     prsn.wkth_wktyp_code
              FROM   hri_cs_prsntyp_ct prsn,
                     hri_mb_asgn_events_ct asgn
              WHERE  prsn.prsntyp_sk_pk = asgn.prsntyp_sk_fk
              AND    asgn.assignment_id = asg_dlt.assignment_id
              AND    ROWNUM < 2
              )
  WHERE  (assignment_id, evts_effective_end_date) IN
         (SELECT asgn.assignment_id,
                 asgn.effective_change_end_date
          FROM   hri_mb_asgn_events_ct asgn,
                 hri_eq_asg_sup_wrfc eq
          WHERE  asgn.prsntyp_sk_fk = eq.source_id
          AND    eq.source_type = 'PERSON_TYPE'
          AND    eq.source_id  BETWEEN p_start_object_id AND p_end_object_id);
  --
  dbg(sql%rowcount || ' records updated due to person type changes');
  --
  COMMIT;
  --
END update_person_type_changes;
--
-- ----------------------------------------------------------------------------
-- ASG_EVENT_CHANGES
-- This procedure is used for incrementally refreshing the asg delta table
-- when incremental changes happen to the asg events fact table.
-- The the details about the changes are stored in the asg delta event queue
-- -------------------------------------------------------------------------
--
PROCEDURE asg_event_changes(p_start_object_id   IN NUMBER
                           ,p_end_object_id     IN NUMBER )
IS
  --
  l_current_time       DATE;
  l_user_id            NUMBER;
  --
BEGIN
  --
  dbg('Inside asg_event_changes');
  --
  l_current_time       := SYSDATE;
  l_user_id            := fnd_global.user_id;
  --
  -- First remove the deleted asg event records
  --
  DELETE hri_map_sup_wrkfc_asg  asg_sph
  WHERE  asg_sph.assignment_id  in
                (select source_id
                 from   hri_eq_asg_sup_wrfc evt
                 where  evt.source_id  between p_start_object_id and p_end_object_id
                 and    evt.source_id  = asg_sph.assignment_id
                 AND    evt.source_type = 'ASG_EVENT')
  AND   asg_sph.evts_effective_end_date >=
                (select evt.erlst_evnt_effective_date - 1
                 from   hri_eq_asg_sup_wrfc evt
                 where  evt.source_id  = asg_sph.assignment_id
                 AND    evt.source_type = 'ASG_EVENT');
  --
  dbg(sql%rowcount || ' records deleted due to assignment event changes');
  --
  -- NOTE : If the underlying SQL is changed, you might have to make the
  -- similiar changes to the query in SUP_CHANGES procedure
  --
  INSERT INTO HRI_MAP_SUP_WRKFC_ASG (
    --
    -- Supervisor id's
    --
    supervisor_person_id
   ,direct_supervisor_person_id
    --
    -- Effective Dates
    --
    ,effective_date
    --
    -- 3986188 a end date column is required which should contain the least end date
    -- from events or supervisor hiearchy tables
    --
    ,effective_end_date
    ,evts_effective_end_date
    ,suph_effective_end_date
    --
    -- Period of work start date
    --
    ,pow_start_date
    --
    -- 4234485, Period of work start date in Julian days.
    --
    ,pow_value_days_julian
    ,pow_extn_days_julian
    --
    -- Unique key generated for the events fact
    --
    ,event_id
    --
    -- Assignment related FK id's
    --
    ,person_id
    ,assignment_id
    ,location_id
    ,job_id
    ,organization_id
    ,position_id
    ,grade_id
    --
    -- Workforce related FK id's
    --
    ,wkth_wktyp_sk_fk
    ,wkth_lvl1_sk_fk
    ,wkth_lvl2_sk_fk
    --
    -- Length of work related FK id
    --
    ,pow_band_sk_fk
    --
    -- Job codes
    --
    ,job_fmly_code
    ,job_fnctn_code
    --
    -- Priamry job role code
    --
    ,primary_job_role_code
    --
    --
    -- Location codes
    --
    ,geo_area_code
    ,geo_country_code
    ,geo_region_code
    ,geo_city_cid
    --
    -- Termination reason and category
    --
    ,leaving_reason_code
    ,separation_category
    --
    -- Performance band
    --
    ,perf_band
    --
    -- Workforce type code
    --
    ,wkth_wktyp_code
    --
    -- Salary currency and value
    --
    ,anl_slry_currency
    ,anl_slry_value
    --
    -- Headcount and FTE value
    --
    ,headcount_value
    ,fte_value
    --
    -- Indicators
    --
    ,worker_hire_ind
    ,post_hire_asgn_start_ind
    ,worker_term_ind
    ,term_voluntary_ind
    ,term_involuntary_ind
    ,pre_sprtn_asgn_end_ind
    ,transfer_in_ind
    ,transfer_out_ind
    --
    ,direct_ind
    ,primary_flag_ind
    ,primary_asg_with_hdc_ind
    --
    -- Indicators to decide summarization requirements
    --
    ,summarization_rqd_ind
    ,summarization_rqd_chng_ind
    --
    -- Indicates gain and loss events
    --
    ,metric_adjust_multiplier
    --
    -- Relative supervisor level
    --
    ,supervisor_level
    --
    -- Admin columns
    --
    ,admin_row_type
    ,admin_evts_rowid
    ,admin_suph_rowid
    ,admin_jobh_rowid
    ,admin_geoh_rowid
    --
    -- WHO Columns
    --
    ,last_update_date
    ,last_update_login
    ,last_updated_by
    ,created_by
    ,creation_date
    --
    -- Incremental changes
    --
    ,sub_assignment_id)
  SELECT /*+ ORDERED */
  suph.sup_person_id                          supervisor_person_id
  ,evts.supervisor_id                         direct_supervisor_person_id
  ,GREATEST(evts.effective_change_date,
            suph.effective_start_date)        effective_date
  --
  -- 3986188 a end date column is required which should contain the least end date
  -- from events or supervisor hiearchy tables
  --
  ,LEAST(evts.effective_change_end_date,
         suph.effective_end_date )            effective_end_date
  ,evts.effective_change_end_date             evts_effective_end_date
  ,suph.effective_end_date                    suph_effective_end_date
  ,evts.pow_start_date_adj                    pow_start_date
  ,to_char(evts.pow_start_date_adj,'J') * evts.summarization_rqd_ind
                                              pow_value_days_julian
  ,nvl(to_char(evts.pow_extn_strt_dt,'J') * evts.summarization_rqd_ind,0)
                                              pow_extn_days_julian
  ,evts.event_id                              event_id
  ,evts.person_id                             person_id
  ,evts.assignment_id                         assignment_id
  ,evts.location_id                           location_id
  ,evts.job_id                                job_id
  ,evts.organization_id                       organization_id
  ,evts.position_id                           position_id
  ,evts.grade_id                              grade_id
  ,prsn.wkth_wktyp_sk_fk                      wkth_wktyp_sk_fk
  ,prsn.wkth_lvl1_sk_fk                       wkth_lvl1_sk_fk
  ,prsn.wkth_lvl2_sk_fk                       wkth_lvl2_sk_fk
  ,evts.pow_band_sk_fk                        pow_band_sk_fk
  ,jobh.job_fmly_code                         job_fmly_code
  ,jobh.job_fnctn_code                        job_fnctn_code
  --
  -- Assign job role only for primary job roles
  --
  ,CASE
    WHEN rolj.primary_role_for_job_flag = 'Y' THEN
      rolj.job_role_code
    ELSE
      'NA_EDW'
  END                                          primary_job_role_code
  --
  ,geoh.area_code                              geo_area_code
  ,geoh.country_code                           geo_country_code
  ,geoh.region_code                            geo_region_code
  ,geoh.city_cid                               geo_city_cid
  ,evts.leaving_reason_code                    leaving_reason_code
  ,'NA_EDW'                                    separation_category
  ,evts.perf_band                              perf_band
  ,prsn.wkth_wktyp_code                        wkth_wktyp_code
  ,evts.anl_slry_currency                      anl_slry_currency
  --
  -- Set salary, headcount and fte to 0 when summarization is not
  -- required
  --
  ,evts.anl_slry * evts.summarization_rqd_ind  anl_slry_value
  ,evts.headcount * evts.summarization_rqd_ind headcount_value
  ,evts.fte * evts.summarization_rqd_ind       fte_value
  ,CASE WHEN evts.effective_change_date < suph.effective_start_date
       THEN 0
       ELSE evts.worker_hire_ind
  END                                          worker_hire_ind
  ,CASE WHEN evts.effective_change_date < suph.effective_start_date
       THEN 0
       ELSE evts.post_hire_asgn_start_ind
  END                                         post_hire_asgn_start_ind
  ,0                                          worker_term_ind
  ,0                                          term_voluntary_ind
  ,0                                          term_involuntary_ind
  ,0                                          pre_sprtn_asgn_end_ind
  ,CASE WHEN evts.effective_change_date < suph.effective_start_date
       THEN 1
       WHEN evts.effective_change_date > suph.effective_start_date
       THEN evts.supervisor_change_ind
       ELSE 1 - (evts.worker_hire_ind + evts.post_hire_asgn_start_ind)
  END                                         transfer_in_ind
  ,0                                          transfer_out_ind
  ,DECODE(suph.sub_relative_level, 0, 1, 0)   direct_ind
  --
  -- 4013742
  -- Set primary_flag_ind and primary_asg_with_hdc_ind to 0
  -- when summarization is not required
  --
  ,CASE WHEN evts.primary_flag = 'Y'
        THEN 1 * evts.summarization_rqd_ind ELSE 0 END
                                              primary_flag_ind
  ,CASE WHEN evts.primary_flag = 'Y' and evts.headcount > 0
        THEN 1 * evts.summarization_rqd_ind ELSE 0 END
                                              primary_asg_with_hdc_ind
  ,evts.summarization_rqd_ind                 summarization_rqd_ind
  ,CASE
     --
     -- Only set for assignment change events
     --
     WHEN evts.effective_change_date >= suph.effective_start_date THEN
       evts.summarization_rqd_chng_ind
     --
     -- For supervisor change events, set as 0
     --
     ELSE
       0
   END                                        summarization_rqd_chng_ind
  ,1                                          metric_adjust_multiplier
  ,suph.sup_level                             supervisor_level
  ,CASE WHEN evts.effective_change_date < suph.effective_start_date
       THEN 'GAIN SUP EVENT ONLY'
       WHEN evts.effective_change_date > suph.effective_start_date
       THEN 'GAIN ASG EVENT ONLY'
       ELSE 'GAIN ASG SUP EVENT'
  END                                         admin_row_type
  ,evts.rowid                                 admin_evts_rowid
  ,suph.rowid                                 admin_suph_rowid
  ,jobh.rowid                                 admin_jobh_rowid
  ,geoh.rowid                                 admin_geoh_rowid
  --
  -- WHO Columns
  --
  , SYSDATE
  ,l_user_id
  ,l_user_id
  ,l_user_id
  ,SYSDATE
  --
  -- Incremental Changes
  --
  ,sub_assignment_id                sub_assignment_id
  FROM
   hri_eq_asg_sup_wrfc       eq
  ,hri_mb_asgn_events_ct     evts
  ,hri_cs_jobh_ct            jobh
  ,hri_cs_geo_lochr_ct       geoh
  ,hri_cs_prsntyp_ct         prsn
  ,hri_cs_job_job_role_ct    rolj
  ,hri_cs_suph               suph
  WHERE suph.sub_person_id = evts.supervisor_id
  AND suph.sup_invalid_flag_code = 'N'
  AND (evts.effective_change_date BETWEEN suph.effective_start_date AND suph.effective_end_date
   OR suph.effective_start_date BETWEEN evts.effective_change_date AND evts.effective_change_end_date)
  AND evts.pre_sprtn_asgn_end_ind = 0
  AND evts.worker_term_ind = 0
  AND geoh.location_id = evts.location_id
  AND jobh.job_id = evts.job_id
  AND evts.prsntyp_sk_fk = prsn.prsntyp_sk_pk
  AND evts.job_id = rolj.job_id
  AND eq.source_id between p_start_object_id and p_end_object_id
  AND eq.source_type = 'ASG_EVENT'
  AND eq.source_id = evts.assignment_id
  AND eq.erlst_evnt_effective_date  -1 <= evts.effective_change_end_date
  UNION ALL
  SELECT /*+ ORDERED */
  suph.sup_person_id                          supervisor_person_id
  ,evts.supervisor_id                         direct_supervisor_person_id
  ,LEAST(evts.effective_change_end_date, suph.effective_end_date) + 1
                                              effective_date
  --
  -- 3986188 a end date column is required which should contain the least end date
  -- from events or supervisor hiearchy tables
  --
  ,null                                       effective_end_date
  ,evts.effective_change_end_date             evts_effective_end_date
  ,suph.effective_end_date                    suph_effective_end_date
  ,evts.pow_start_date_adj                    pow_start_date
  ,to_char(evts.pow_start_date_adj,'J') * evts.summarization_rqd_ind
                                              pow_value_days_julian
  ,nvl(to_char(evts.pow_extn_strt_dt,'J') * evts.summarization_rqd_ind,0)
                                              pow_extn_days_julian
  ,evts.event_id                              event_id
  ,evts.person_id                             person_id
  ,evts.assignment_id                         assignment_id
  ,evts.location_id                           location_id
  ,evts.job_id                                job_id
  ,evts.organization_id                       organization_id
  ,evts.position_id                           position_id
  ,evts.grade_id                              grade_id
  ,prsn.wkth_wktyp_sk_fk                      wkth_wktyp_sk_fk
  ,prsn.wkth_lvl1_sk_fk                       wkth_lvl1_sk_fk
  ,prsn.wkth_lvl2_sk_fk                       wkth_lvl2_sk_fk
  ,evts.pow_band_sk_fk                        pow_band_sk_fk
  ,jobh.job_fmly_code                         job_fmly_code
  ,jobh.job_fnctn_code                        job_fnctn_code
  ,CASE
     WHEN rolj.primary_role_for_job_flag = 'Y' THEN
       rolj.job_role_code
     ELSE
       'NA_EDW'
   END                                        primary_job_role_code
   --
  ,geoh.area_code                             geo_area_code
  ,geoh.country_code                          geo_country_code
  ,geoh.region_code                           geo_region_code
  ,geoh.city_cid                              geo_city_cid
  ,evts.leaving_reason_code                   leaving_reason_code
  ,CASE WHEN suph.effective_end_date < evts.effective_change_end_date
       THEN 'NA_EDW'
       ELSE evts.separation_category_nxt
  END                                          separation_category
  ,evts.perf_band                              perf_band
  ,prsn.wkth_wktyp_code                        wkth_wktyp_code
  ,evts.anl_slry_currency                      anl_slry_currency
  ,evts.anl_slry * evts.summarization_rqd_ind  anl_slry_value
  ,evts.headcount * evts.summarization_rqd_ind headcount_value
  ,evts.fte * evts.summarization_rqd_ind       fte_value
  ,0                                           worker_hire_ind
  ,0                                           post_hire_asgn_start_ind
  ,CASE WHEN suph.effective_end_date < evts.effective_change_end_date
       THEN 0
       ELSE evts.worker_term_nxt_ind
  END                                         worker_term_ind
  ,CASE WHEN suph.effective_end_date < evts.effective_change_end_date
       THEN 0
       ELSE evts.term_voluntary_nxt_ind
  END                                         term_voluntary_ind
  ,CASE WHEN suph.effective_end_date < evts.effective_change_end_date
       THEN 0
       ELSE evts.term_involuntary_nxt_ind
  END                                         term_involuntary_ind
  ,CASE WHEN suph.effective_end_date < evts.effective_change_end_date
       THEN 0
       ELSE evts.pre_sprtn_asgn_end_nxt_ind
  END                                         pre_sprtn_asgn_end_ind
  ,0                                          transfer_in_ind
  ,CASE WHEN suph.effective_end_date < evts.effective_change_end_date
       THEN 1
       WHEN suph.effective_end_date > evts.effective_change_end_date
       THEN evts.supervisor_change_nxt_ind
       ELSE 1 - (evts.worker_term_nxt_ind + evts.pre_sprtn_asgn_end_nxt_ind)
  END                                         transfer_out_ind
  ,DECODE(suph.sub_relative_level, 0, 1, 0)   direct_ind
  --
  -- 4013742
  -- Set primary_flag_ind and primary_asg_with_hdc_ind to 0
  -- when summarization is not required
  --
  ,CASE WHEN evts.primary_flag = 'Y'
        THEN 1 * evts.summarization_rqd_ind ELSE 0 END
                                              primary_flag_ind
  ,CASE WHEN evts.primary_flag = 'Y' and evts.headcount > 0
         THEN 1 * evts.summarization_rqd_ind ELSE 0 END
                                              primary_asg_with_hdc_ind
  ,evts.summarization_rqd_ind                 summarization_rqd_ind
  ,CASE
     WHEN suph.effective_end_date >= evts.effective_change_end_date THEN
       evts.summarization_rqd_chng_nxt_ind
     ELSE
       0
   END                                        summarization_rqd_chng_ind
  ,-1                                         metric_adjust_multiplier
  ,suph.sup_level                             supervisor_level
  ,CASE WHEN suph.effective_end_date < evts.effective_change_end_date
       THEN 'LOSS SUP EVENT ONLY'
       WHEN suph.effective_end_date > evts.effective_change_end_date
       THEN 'LOSS ASG EVENT ONLY'
       ELSE 'LOSS ASG SUP EVENT'
  END                                         admin_row_type
  ,evts.rowid                                 admin_evts_rowid
  ,suph.rowid                                 admin_suph_rowid
  ,jobh.rowid                                 admin_jobh_rowid
  ,geoh.rowid                                 admin_geoh_rowid
  --
  -- WHO Columns
  --
  ,SYSDATE
  ,l_user_id
  ,l_user_id
  ,l_user_id
  ,SYSDATE
  --
  -- Incremental Changes
  --
  ,sub_assignment_id                sub_assignment_id
  FROM
   hri_eq_asg_sup_wrfc       eq
  ,hri_mb_asgn_events_ct     evts
  ,hri_cs_jobh_ct            jobh
  ,hri_cs_geo_lochr_ct       geoh
  ,hri_cs_prsntyp_ct         prsn
  ,hri_cs_job_job_role_ct    rolj
  ,hri_cs_suph               suph
  WHERE suph.sub_person_id = evts.supervisor_id
  AND suph.sup_invalid_flag_code = 'N'
  AND (suph.effective_end_date BETWEEN evts.effective_change_date AND evts.effective_change_end_date
   OR evts.effective_change_end_date BETWEEN suph.effective_start_date AND suph.effective_end_date)
  AND LEAST(suph.effective_end_date, evts.effective_change_end_date) < to_date('31-12-4712','DD-MM-YYYY')
  AND evts.pre_sprtn_asgn_end_ind = 0
  AND evts.worker_term_ind = 0
  AND geoh.location_id = evts.location_id
  AND jobh.job_id = evts.job_id
  AND evts.prsntyp_sk_fk = prsn.prsntyp_sk_pk
  AND evts.job_id = rolj.job_id
  AND eq.source_id between p_start_object_id and p_end_object_id
  AND eq.source_id = evts.assignment_id
  AND eq.source_type = 'ASG_EVENT'
  AND eq.erlst_evnt_effective_date -1 <= evts.effective_change_end_date;
  --
  dbg(SQL%ROWCOUNT||' records inserted for asg events changes');
  --
  COMMIT;
  --
  dbg('Exiting asg_event_changes');
  --
END asg_event_changes;
--
-- ----------------------------------------------------------------------------
-- SUP_CHANGES
-- This procedure is used for incrementally refreshing the asg delta table
-- when incremental changes happen to the sup hierarchy table.
-- The details about the changes are stored in the asg delta event queue
-- -------------------------------------------------------------------------
--
PROCEDURE sup_changes(p_start_object_id   IN NUMBER
                     ,p_end_object_id     IN NUMBER )
IS
  --
  l_current_time       DATE;
  l_user_id            NUMBER;
  --
BEGIN
  --
  dbg('Inside sup_changes');
  --
  l_current_time       := SYSDATE;
  l_user_id            := fnd_global.user_id;
  --
  -- SUPERVISOR HIERARCHY CHANGES
  -- Delete all records from asg delta table which have been removed from the supervisor
  -- hierarchy table during incremental refresh. The variour metrics
  -- stored in asg delta are derived by joining the supervisor_id of asg event record
  -- with the sub_assignment_id of supervisor. The assignment event delta table stores
  -- the list of assignment_id for which the supervisor hierarchy records have been
  -- changed. The impacted asg delta records can be derived using the SUB_ASSIGNMENT_ID
  -- and SUPH_EFFECTIVE_END_DATE column in the table. However, there is no poin in
  -- deleting all records for the assignment, only records that have SUPH_EFFECTIVE_END_DATE
  -- less than (earliest event date stored - 1) (This is because the previous records in the
  -- hierarchy have also been end dated so those records cannot be ignored)
  --
  DELETE hri_map_sup_wrkfc_asg  asg_sph
  WHERE  asg_sph.sub_assignment_id  in
                (SELECT evt.source_id
                 FROM   hri_eq_asg_sup_wrfc evt
                 WHERE  evt.source_id  between p_start_object_id and p_end_object_id
                 AND    evt.source_id  = asg_sph.sub_assignment_id
                 AND    evt.source_type = 'SUPERVISOR')
  AND   asg_sph.suph_effective_end_date >=
                (SELECT evt.erlst_evnt_effective_date - 1
                 FROM   hri_eq_asg_sup_wrfc evt
                 WHERE  evt.source_id  = asg_sph.sub_assignment_id
                 AND    evt.source_type = 'SUPERVISOR');
  --
  dbg(sql%rowcount || ' records deleted due to sup eq');
  --
  -- Insert all the records for the sub_assignment_id that are
  --
  -- NOTE : If the underlying SQL is changed, you might have to make the
  -- similiar changes to the query in ASG_EVENT_CHANGES procedure
  --
  INSERT INTO HRI_MAP_SUP_WRKFC_ASG (
    --
    -- Supervisor id's
    --
    supervisor_person_id
   ,direct_supervisor_person_id
    --
    -- Effective Dates
    --
    ,effective_date
    --
    -- 3986188 a end date column is required which should contain the least end date
    -- from events or supervisor hiearchy tables
    --
    ,effective_end_date
    ,evts_effective_end_date
    ,suph_effective_end_date
    --
    -- Period of work start date
    --
    ,pow_start_date
    --
    -- 4234485, Period of work start date in Julian days.
    --
    ,pow_value_days_julian
    ,pow_extn_days_julian
    --
    -- Unique key generated for the events fact
    --
    ,event_id
    --
    -- Assignment related FK id's
    --
    ,person_id
    ,assignment_id
    ,location_id
    ,job_id
    ,organization_id
    ,position_id
    ,grade_id
    --
    -- Workforce related FK id's
    --
    ,wkth_wktyp_sk_fk
    ,wkth_lvl1_sk_fk
    ,wkth_lvl2_sk_fk
    --
    -- Length of work related FK id
    --
    ,pow_band_sk_fk
    --
    -- Job codes
    --
    ,job_fmly_code
    ,job_fnctn_code
    --
    -- Priamry job role code
    --
    ,primary_job_role_code
    --
    --
    -- Location codes
    --
    ,geo_area_code
    ,geo_country_code
    ,geo_region_code
    ,geo_city_cid
    --
    -- Termination reason and category
    --
    ,leaving_reason_code
    ,separation_category
    --
    -- Performance band
    --
    ,perf_band
    --
    -- Workforce type code
    --
    ,wkth_wktyp_code
    --
    -- Salary currency and value
    --
    ,anl_slry_currency
    ,anl_slry_value
    --
    -- Headcount and FTE value
    --
    ,headcount_value
    ,fte_value
    --
    -- Indicators
    --
    ,worker_hire_ind
    ,post_hire_asgn_start_ind
    ,worker_term_ind
    ,term_voluntary_ind
    ,term_involuntary_ind
    ,pre_sprtn_asgn_end_ind
    ,transfer_in_ind
    ,transfer_out_ind
    --
    ,direct_ind
    ,primary_flag_ind
    ,primary_asg_with_hdc_ind
    --
    -- Indicators to decide summarization requirements
    --
    ,summarization_rqd_ind
    ,summarization_rqd_chng_ind
    --
    -- Indicates gain and loss events
    --
    ,metric_adjust_multiplier
    --
    -- Relative supervisor level
    --
    ,supervisor_level
    --
    -- Admin columns
    --
    ,admin_row_type
    ,admin_evts_rowid
    ,admin_suph_rowid
    ,admin_jobh_rowid
    ,admin_geoh_rowid
    --
    -- WHO Columns
    --
    ,last_update_date
    ,last_update_login
    ,last_updated_by
    ,created_by
    ,creation_date
    --
    -- Incremental changes
    --
    ,sub_assignment_id)
  SELECT
  suph.sup_person_id                          supervisor_person_id
  ,evts.supervisor_id                         direct_supervisor_person_id
  ,GREATEST(evts.effective_change_date,
            suph.effective_start_date)        effective_date
  --
  -- 3986188 a end date column is required which should contain the least end date
  -- from events or supervisor hiearchy tables
  --
  ,LEAST(evts.effective_change_end_date,
         suph.effective_end_date )            effective_end_date
  ,evts.effective_change_end_date             evts_effective_end_date
  ,suph.effective_end_date                    suph_effective_end_date
  ,evts.pow_start_date_adj                    pow_start_date
  ,to_char(evts.pow_start_date_adj,'J') * evts.summarization_rqd_ind
                                              pow_value_days_julian
  ,nvl(to_char(evts.pow_extn_strt_dt,'J') * evts.summarization_rqd_ind,0)
                                              pow_extn_days_julian
  ,evts.event_id                              event_id
  ,evts.person_id                             person_id
  ,evts.assignment_id                         assignment_id
  ,evts.location_id                           location_id
  ,evts.job_id                                job_id
  ,evts.organization_id                       organization_id
  ,evts.position_id                           position_id
  ,evts.grade_id                              grade_id
  ,prsn.wkth_wktyp_sk_fk                      wkth_wktyp_sk_fk
  ,prsn.wkth_lvl1_sk_fk                       wkth_lvl1_sk_fk
  ,prsn.wkth_lvl2_sk_fk                       wkth_lvl2_sk_fk
  ,evts.pow_band_sk_fk                        pow_band_sk_fk
  ,jobh.job_fmly_code                         job_fmly_code
  ,jobh.job_fnctn_code                        job_fnctn_code
  --
  -- Assign job role only for primary job roles
  --
  ,CASE
    WHEN rolj.primary_role_for_job_flag = 'Y' THEN
      rolj.job_role_code
    ELSE
      'NA_EDW'
  END                                          primary_job_role_code
  --
  ,geoh.area_code                              geo_area_code
  ,geoh.country_code                           geo_country_code
  ,geoh.region_code                            geo_region_code
  ,geoh.city_cid                               geo_city_cid
  ,evts.leaving_reason_code                    leaving_reason_code
  ,'NA_EDW'                                    separation_category
  ,evts.perf_band                              perf_band
  ,prsn.wkth_wktyp_code                        wkth_wktyp_code
  ,evts.anl_slry_currency                      anl_slry_currency
  --
  -- Set salary, headcount and fte to 0 when summarization is not
  -- required
  --
  ,evts.anl_slry * evts.summarization_rqd_ind  anl_slry_value
  ,evts.headcount * evts.summarization_rqd_ind headcount_value
  ,evts.fte * evts.summarization_rqd_ind       fte_value
  ,CASE WHEN evts.effective_change_date < suph.effective_start_date
       THEN 0
       ELSE evts.worker_hire_ind
  END                                          worker_hire_ind
  ,CASE WHEN evts.effective_change_date < suph.effective_start_date
       THEN 0
       ELSE evts.post_hire_asgn_start_ind
  END                                         post_hire_asgn_start_ind
  ,0                                          worker_term_ind
  ,0                                          term_voluntary_ind
  ,0                                          term_involuntary_ind
  ,0                                          pre_sprtn_asgn_end_ind
  ,CASE WHEN evts.effective_change_date < suph.effective_start_date
       THEN 1
       WHEN evts.effective_change_date > suph.effective_start_date
       THEN evts.supervisor_change_ind
       ELSE 1 - (evts.worker_hire_ind + evts.post_hire_asgn_start_ind)
  END                                         transfer_in_ind
  ,0                                          transfer_out_ind
  ,DECODE(suph.sub_relative_level, 0, 1, 0)   direct_ind
  --
  -- 4013742
  -- Set primary_flag_ind and primary_asg_with_hdc_ind to 0
  -- when summarization is not required
  --
  ,CASE WHEN evts.primary_flag = 'Y'
        THEN 1 * evts.summarization_rqd_ind ELSE 0 END
                                              primary_flag_ind
  ,CASE WHEN evts.primary_flag = 'Y' and evts.headcount > 0
        THEN 1 * evts.summarization_rqd_ind ELSE 0 END
                                              primary_asg_with_hdc_ind
  ,evts.summarization_rqd_ind                 summarization_rqd_ind
  ,CASE
     --
     -- Only set for assignment change events
     --
     WHEN evts.effective_change_date >= suph.effective_start_date THEN
       evts.summarization_rqd_chng_ind
     --
     -- For supervisor change events, set as 0
     --
     ELSE
       0
   END                                        summarization_rqd_chng_ind
  ,1                                          metric_adjust_multiplier
  ,suph.sup_level                             supervisor_level
  ,CASE WHEN evts.effective_change_date < suph.effective_start_date
       THEN 'GAIN SUP EVENT ONLY'
       WHEN evts.effective_change_date > suph.effective_start_date
       THEN 'GAIN ASG EVENT ONLY'
       ELSE 'GAIN ASG SUP EVENT'
  END                                         admin_row_type
  ,evts.rowid                                 admin_evts_rowid
  ,suph.rowid                                 admin_suph_rowid
  ,jobh.rowid                                 admin_jobh_rowid
  ,geoh.rowid                                 admin_geoh_rowid
  --
  -- WHO Columns
  --
  , SYSDATE
  ,l_user_id
  ,l_user_id
  ,l_user_id
  ,SYSDATE
  --
  -- Incremental Changes
  --
  ,sub_assignment_id                sub_assignment_id
  FROM
   hri_mb_asgn_events_ct     evts
  ,hri_cs_jobh_ct            jobh
  ,hri_cs_geo_lochr_ct       geoh
  ,hri_cs_suph               suph
  ,hri_cs_prsntyp_ct         prsn
  ,hri_cs_job_job_role_ct    rolj
  ,hri_eq_asg_sup_wrfc       eq
  WHERE suph.sub_person_id = evts.supervisor_id
  AND suph.sup_invalid_flag_code = 'N'
  AND (evts.effective_change_date BETWEEN suph.effective_start_date AND suph.effective_end_date
   OR suph.effective_start_date BETWEEN evts.effective_change_date AND evts.effective_change_end_date)
  AND evts.pre_sprtn_asgn_end_ind = 0
  AND evts.worker_term_ind = 0
  AND geoh.location_id = evts.location_id
  AND jobh.job_id = evts.job_id
  AND evts.prsntyp_sk_fk = prsn.prsntyp_sk_pk
  AND evts.job_id = rolj.job_id
  AND eq.source_id between p_start_object_id and p_end_object_id
  AND eq.source_type = 'SUPERVISOR'
  AND eq.source_id = suph.sub_assignment_id
  AND eq.erlst_evnt_effective_date  - 1 <= suph.effective_end_date
  UNION ALL
  SELECT
  suph.sup_person_id                          supervisor_person_id
  ,evts.supervisor_id                         direct_supervisor_person_id
  ,LEAST(evts.effective_change_end_date, suph.effective_end_date) + 1
                                              effective_date
  --
  -- 3986188 a end date column is required which should contain the least end date
  -- from events or supervisor hiearchy tables
  --
  ,null                                       effective_end_date
  ,evts.effective_change_end_date             evts_effective_end_date
  ,suph.effective_end_date                    suph_effective_end_date
  ,evts.pow_start_date_adj                    pow_start_date
  ,to_char(evts.pow_start_date_adj,'J') * evts.summarization_rqd_ind
                                              pow_value_days_julian
  ,nvl(to_char(evts.pow_extn_strt_dt,'J') * evts.summarization_rqd_ind,0)
                                              pow_extn_days_julian
  ,evts.event_id                              event_id
  ,evts.person_id                             person_id
  ,evts.assignment_id                         assignment_id
  ,evts.location_id                           location_id
  ,evts.job_id                                job_id
  ,evts.organization_id                       organization_id
  ,evts.position_id                           position_id
  ,evts.grade_id                              grade_id
  ,prsn.wkth_wktyp_sk_fk                      wkth_wktyp_sk_fk
  ,prsn.wkth_lvl1_sk_fk                       wkth_lvl1_sk_fk
  ,prsn.wkth_lvl2_sk_fk                       wkth_lvl2_sk_fk
  ,evts.pow_band_sk_fk                        pow_band_sk_fk
  ,jobh.job_fmly_code                         job_fmly_code
  ,jobh.job_fnctn_code                        job_fnctn_code
  ,CASE
     WHEN rolj.primary_role_for_job_flag = 'Y' THEN
       rolj.job_role_code
     ELSE
       'NA_EDW'
   END                                        primary_job_role_code
   --
  ,geoh.area_code                             geo_area_code
  ,geoh.country_code                          geo_country_code
  ,geoh.region_code                           geo_region_code
  ,geoh.city_cid                              geo_city_cid
  ,evts.leaving_reason_code                   leaving_reason_code
  ,CASE WHEN suph.effective_end_date < evts.effective_change_end_date
       THEN 'NA_EDW'
       ELSE evts.separation_category_nxt
  END                                          separation_category
  ,evts.perf_band                              perf_band
  ,prsn.wkth_wktyp_code                        wkth_wktyp_code
  ,evts.anl_slry_currency                      anl_slry_currency
  ,evts.anl_slry * evts.summarization_rqd_ind  anl_slry_value
  ,evts.headcount * evts.summarization_rqd_ind headcount_value
  ,evts.fte * evts.summarization_rqd_ind       fte_value
  ,0                                           worker_hire_ind
  ,0                                           post_hire_asgn_start_ind
  ,CASE WHEN suph.effective_end_date < evts.effective_change_end_date
       THEN 0
       ELSE evts.worker_term_nxt_ind
  END                                         worker_term_ind
  ,CASE WHEN suph.effective_end_date < evts.effective_change_end_date
       THEN 0
       ELSE evts.term_voluntary_nxt_ind
  END                                         term_voluntary_ind
  ,CASE WHEN suph.effective_end_date < evts.effective_change_end_date
       THEN 0
       ELSE evts.term_involuntary_nxt_ind
  END                                         term_involuntary_ind
  ,CASE WHEN suph.effective_end_date < evts.effective_change_end_date
       THEN 0
       ELSE evts.pre_sprtn_asgn_end_nxt_ind
  END                                         pre_sprtn_asgn_end_ind
  ,0                                          transfer_in_ind
  ,CASE WHEN suph.effective_end_date < evts.effective_change_end_date
       THEN 1
       WHEN suph.effective_end_date > evts.effective_change_end_date
       THEN evts.supervisor_change_nxt_ind
       ELSE 1 - (evts.worker_term_nxt_ind + evts.pre_sprtn_asgn_end_nxt_ind)
  END                                         transfer_out_ind
  ,DECODE(suph.sub_relative_level, 0, 1, 0)   direct_ind
  --
  -- 4013742
  -- Set primary_flag_ind and primary_asg_with_hdc_ind to 0
  -- when summarization is not required
  --
  ,CASE WHEN evts.primary_flag = 'Y'
        THEN 1 * evts.summarization_rqd_ind ELSE 0 END
                                              primary_flag_ind
  ,CASE WHEN evts.primary_flag = 'Y' and evts.headcount > 0
         THEN 1 * evts.summarization_rqd_ind ELSE 0 END
                                              primary_asg_with_hdc_ind
  ,evts.summarization_rqd_ind                 summarization_rqd_ind
  ,CASE
     WHEN suph.effective_end_date >= evts.effective_change_end_date THEN
       evts.summarization_rqd_chng_nxt_ind
     ELSE
       0
   END                                        summarization_rqd_chng_ind
  ,-1                                         metric_adjust_multiplier
  ,suph.sup_level                             supervisor_level
  ,CASE WHEN suph.effective_end_date < evts.effective_change_end_date
       THEN 'LOSS SUP EVENT ONLY'
       WHEN suph.effective_end_date > evts.effective_change_end_date
       THEN 'LOSS ASG EVENT ONLY'
       ELSE 'LOSS ASG SUP EVENT'
  END                                         admin_row_type
  ,evts.rowid                                 admin_evts_rowid
  ,suph.rowid                                 admin_suph_rowid
  ,jobh.rowid                                 admin_jobh_rowid
  ,geoh.rowid                                 admin_geoh_rowid
  --
  -- WHO Columns
  --
  ,SYSDATE
  ,l_user_id
  ,l_user_id
  ,l_user_id
  ,SYSDATE
  --
  -- Incremental Changes
  --
  ,sub_assignment_id                sub_assignment_id
  FROM
   hri_mb_asgn_events_ct     evts
  ,hri_cs_jobh_ct            jobh
  ,hri_cs_geo_lochr_ct       geoh
  ,hri_cs_suph               suph
  ,hri_cs_prsntyp_ct         prsn
  ,hri_cs_job_job_role_ct    rolj
  ,hri_eq_asg_sup_wrfc       eq
  WHERE suph.sub_person_id = evts.supervisor_id
  AND suph.sup_invalid_flag_code = 'N'
  AND (suph.effective_end_date BETWEEN evts.effective_change_date AND evts.effective_change_end_date
   OR evts.effective_change_end_date BETWEEN suph.effective_start_date AND suph.effective_end_date)
  AND LEAST(suph.effective_end_date, evts.effective_change_end_date) < to_date('31-12-4712','DD-MM-YYYY')
  AND evts.pre_sprtn_asgn_end_ind = 0
  AND evts.worker_term_ind = 0
  AND geoh.location_id = evts.location_id
  AND jobh.job_id = evts.job_id
  AND evts.prsntyp_sk_fk = prsn.prsntyp_sk_pk
  AND evts.job_id = rolj.job_id
  AND eq.source_id between p_start_object_id and p_end_object_id
  AND eq.source_type = 'SUPERVISOR'
  AND eq.source_id = suph.sub_assignment_id
  AND eq.erlst_evnt_effective_date  -1 <= suph.effective_end_date;
  --
  dbg(SQL%ROWCOUNT||' records inserted into HRI_MAP_SUP_WRKFC_ASG due to sup eq');
  --
  COMMIT;
  --
  dbg('Exiting sup_changes');
  --
END sup_changes;
--
-- ----------------------------------------------------------------------------
-- Sets up global list of parameters
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
                                     p_process_table_name => 'HRI_MAP_SUP_WRKFC_ASG');

    -- If called for the first time set the defaulted parameters
    IF (p_mthd_stage_code = 'PRE_PROCESS') THEN

      g_full_refresh := hri_oltp_conc_param.get_parameter_value
                         (p_parameter_name     => 'FULL_REFRESH',
                          p_process_table_name => 'HRI_MAP_SUP_WRKFC_ASG');

      -- Log defaulted parameters so the slave processes pick up
      hri_opl_multi_thread.update_parameters
       (p_mthd_action_id    => p_mthd_action_id,
        p_full_refresh      => g_full_refresh,
        p_global_start_date => l_dbi_collection_start_date);

    END IF;
    --
    -- Populate the multithreading action array to populate the global parameters
    --
    g_mthd_action_array   := hri_opl_multi_thread.get_mthd_action_array(p_mthd_action_id);
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
-- -----------------------------------------------------------------------------
-- This procedure incrementally refreshes the assignment delta table. The procedure
-- is invoked by the process_range procedure which passes the start and end
-- object id of the multithreading range. The logic followed in the procedure is
--
-- There are four tables based on which the assignment delta is populated
-- Incremental refresh of each of these tables affect the assignment delta table
-- in a different manner
--
-- 1. Asg Events: All person related metrics are derived from this table.
--    During incremental refresh of asg events, all records for the asg that are
--    after the event date are deleted and new records are inserted. To refresh the asg
--    delta table incrementally all records for the asg on or after the event date
--    should be deleted and new records for the asg should be inserted. The list of
--    changed assignment with the earliest event date are populated in the asg delta
--    event queue (populated by asg event collection program)
--
-- 2. Supervisor Hierarchy: This table is used to rollup the asg event fact data with
--    the asg record and to derive the various metrics for the supervisor. The incre
--    sup hierarchy program deletes all records for the person on the event date and
--    reinsert the hierarchy for the him. For affecting these changes during incr
--    refresh of asg delta, all record for the affected supervisor should re-calculated
--
-- 3. Job Hierarchy: If the Job function and Job Family details of a job record are changed
--    all record for the job_id should be update with the changes. The list of
--    changed jobs are populated in the asg delta event queue (populated by job
--    collection program)
--
-- 4. Georgraphy: Currently only the country information is used in HRI reports.
--    The country details of a location record cannot be changed. Therefore there
--    is no impact of incremental changes to geography details on assignment delta
--
-- The Assignment Delta Event Queue (HRI_EQ_ASG_SUP_WRFC) stores the following
-- information
--
-- SOURCE_TYPE               = JOB, SUPERVISOR, ASG_EVENT (Depending on the change)
-- SOURCE_ID                 = Primary Key of the changed entity
--                             When SOURCE_TYPE = JOB then JOB_ID
--                             When SOURCE_TYPE = SUPERVISOR then SUB_ASSIGNMENT_ID
-- ERLST_EVNT_EFFECTIVE_DATE = Stores the earliest event date for the entity. It is
--                             Null for when SOURCE_TYPE = JOB
-- -----------------------------------------------------------------------------
--
PROCEDURE incremental_process(p_start_object_id   IN NUMBER
                             ,p_end_object_id     IN NUMBER )
IS
  --
  --
BEGIN
  --
  -- perform the incremental changes due to changes to job
  -- family and job function dimension level
  --
  update_job_changes(p_start_object_id  => p_start_object_id
                     ,p_end_object_id   => p_end_object_id);
  --
  --
  -- perform the incremental changes due to changes to job
  -- family and job function dimension level for primary job
  -- roles
  --
  update_prmry_job_role_changes(p_start_object_id  => p_start_object_id
                                ,p_end_object_id   => p_end_object_id);
  --
  --
  -- perform the incremental changes due to changes to location
  -- details
  --
  update_location_changes(p_start_object_id  => p_start_object_id
                          ,p_end_object_id   => p_end_object_id);
  --
  -- perform the incremental changes due to changes in person type
  -- details
  update_person_type_changes(p_start_object_id  => p_start_object_id
                             ,p_end_object_id   => p_end_object_id);

  --
  -- perform the incremental changes due to changes to
  -- assignment events fact table
  --
  asg_event_changes(p_start_object_id  => p_start_object_id
                   ,p_end_object_id    => p_end_object_id);
  --
  -- perform the incremental changes due to changes to
  -- supervisor hierarchy table
  --
  sup_changes(p_start_object_id  => p_start_object_id
             ,p_end_object_id    => p_end_object_id);
  --
EXCEPTION
  WHEN OTHERS THEN
    --
    output(sqlerrm);
    --
    RAISE;
    --
--
END incremental_process;
--
-- -----------------------------------------------------------------------------
-- This procedure inserts data in the table for every range which is being
-- processed.
-- -----------------------------------------------------------------------------
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
  --
  -- Set up dynamic sql for redo reduction
  --
  IF (g_redo_reduction = 'Y') THEN
    l_hint := '/*+ APPEND */ ';
    l_table_name := hri_utl_stage_table.get_staging_table_name
                     (p_master_table_name => 'HRI_MAP_SUP_WRKFC_ASG');
    l_partition_clause := 'PARTITION (p' || g_worker_id || ') ';
    l_partition_column := l_rtn || '  ,worker_id';
    l_part_col_value   := l_rtn || '  ,' || to_char(g_worker_id);
  ELSE
    l_table_name := 'HRI_MAP_SUP_WRKFC_ASG';
  END IF;
  --
  l_current_time       := SYSDATE;
  l_user_id            := fnd_global.user_id;
  --
  l_sql_stmt :=
'INSERT ' || l_hint || 'INTO ' || l_table_name || ' ' || l_partition_clause || '
  (supervisor_person_id
  ,direct_supervisor_person_id
  ,effective_date
  ,effective_end_date
  ,evts_effective_end_date
  ,suph_effective_end_date
  ,pow_start_date
  ,pow_value_days_julian
  ,pow_extn_days_julian
  ,event_id
  ,person_id
  ,assignment_id
  ,location_id
  ,job_id
  ,organization_id
  ,position_id
  ,grade_id
  ,wkth_wktyp_sk_fk
  ,wkth_lvl1_sk_fk
  ,wkth_lvl2_sk_fk
  ,pow_band_sk_fk
  ,job_fmly_code
  ,job_fnctn_code
  ,primary_job_role_code
  ,geo_area_code
  ,geo_country_code
  ,geo_region_code
  ,geo_city_cid
  ,leaving_reason_code
  ,separation_category
  ,perf_band
  ,wkth_wktyp_code
  ,anl_slry_currency
  ,anl_slry_value
  ,headcount_value
  ,fte_value
  ,worker_hire_ind
  ,post_hire_asgn_start_ind
  ,worker_term_ind
  ,term_voluntary_ind
  ,term_involuntary_ind
  ,pre_sprtn_asgn_end_ind
  ,transfer_in_ind
  ,transfer_out_ind
  ,direct_ind
  ,primary_flag_ind
  ,primary_asg_with_hdc_ind
  ,summarization_rqd_ind
  ,summarization_rqd_chng_ind
  ,metric_adjust_multiplier
  ,supervisor_level
  ,admin_row_type
  ,admin_evts_rowid
  ,admin_suph_rowid
  ,admin_jobh_rowid
  ,admin_geoh_rowid
  ,last_update_date
  ,last_update_login
  ,last_updated_by
  ,created_by
  ,creation_date
  ,sub_assignment_id' ||
  l_partition_column || ')
  SELECT /*+ ORDERED */
  suph.sup_person_id                          supervisor_person_id
  ,evts.supervisor_id                         direct_supervisor_person_id
  ,GREATEST(evts.effective_change_date,
            suph.effective_start_date)        effective_date
  ,LEAST(evts.effective_change_end_date,
         suph.effective_end_date )            effective_end_date
  ,evts.effective_change_end_date             evts_effective_end_date
  ,suph.effective_end_date                    suph_effective_end_date
  ,evts.pow_start_date_adj                    pow_start_date
  ,to_char(evts.pow_start_date_adj,''J'') * evts.summarization_rqd_ind
                                              pow_value_days_julian
  ,nvl(to_char(evts.pow_extn_strt_dt,''J'') * evts.summarization_rqd_ind,0)
                                              pow_extn_days_julian
  ,evts.event_id                              event_id
  ,evts.person_id                             person_id
  ,evts.assignment_id                         assignment_id
  ,evts.location_id                           location_id
  ,evts.job_id                                job_id
  ,evts.organization_id                       organization_id
  ,evts.position_id                           position_id
  ,evts.grade_id                              grade_id
  ,prsn.wkth_wktyp_sk_fk                      wkth_wktyp_sk_fk
  ,prsn.wkth_lvl1_sk_fk                       wkth_lvl1_sk_fk
  ,prsn.wkth_lvl2_sk_fk                       wkth_lvl2_sk_fk
  ,evts.pow_band_sk_fk                        pow_band_sk_fk
  ,jobh.job_fmly_code                         job_fmly_code
  ,jobh.job_fnctn_code                        job_fnctn_code
  ,CASE WHEN rolj.primary_role_for_job_flag = ''Y''
        THEN rolj.job_role_code
        ELSE ''NA_EDW''
   END                                         primary_job_role_code
  ,geoh.area_code                              geo_area_code
  ,geoh.country_code                           geo_country_code
  ,geoh.region_code                            geo_region_code
  ,geoh.city_cid                               geo_city_cid
  ,evts.leaving_reason_code                    leaving_reason_code
  ,''NA_EDW''                                    separation_category
  ,evts.perf_band                              perf_band
  ,prsn.wkth_wktyp_code                        wkth_wktyp_code
  ,evts.anl_slry_currency                      anl_slry_currency
  ,evts.anl_slry * evts.summarization_rqd_ind  anl_slry_value
  ,evts.headcount * evts.summarization_rqd_ind headcount_value
  ,evts.fte * evts.summarization_rqd_ind       fte_value
  ,CASE WHEN evts.effective_change_date < suph.effective_start_date
       THEN 0
       ELSE evts.worker_hire_ind
  END                                          worker_hire_ind
  ,CASE WHEN evts.effective_change_date < suph.effective_start_date
       THEN 0
       ELSE evts.post_hire_asgn_start_ind
  END                                         post_hire_asgn_start_ind
  ,0                                          worker_term_ind
  ,0                                          term_voluntary_ind
  ,0                                          term_involuntary_ind
  ,0                                          pre_sprtn_asgn_end_ind
  ,CASE WHEN evts.effective_change_date < suph.effective_start_date
       THEN 1
       WHEN evts.effective_change_date > suph.effective_start_date
       THEN evts.supervisor_change_ind
       ELSE 1 - (evts.worker_hire_ind + evts.post_hire_asgn_start_ind)
  END                                         transfer_in_ind
  ,0                                          transfer_out_ind
  ,DECODE(suph.sub_relative_level, 0, 1, 0)   direct_ind
  ,CASE WHEN evts.primary_flag = ''Y''
        THEN 1 * evts.summarization_rqd_ind ELSE 0 END
                                              primary_flag_ind
  ,CASE WHEN evts.primary_flag = ''Y'' and evts.headcount > 0
        THEN 1 * evts.summarization_rqd_ind ELSE 0 END
                                              primary_asg_with_hdc_ind
  ,evts.summarization_rqd_ind                 summarization_rqd_ind
  ,CASE WHEN evts.effective_change_date >= suph.effective_start_date
        THEN evts.summarization_rqd_chng_ind
        ELSE 0
   END                                        summarization_rqd_chng_ind
  ,1                                          metric_adjust_multiplier
  ,suph.sup_level                             supervisor_level
  ,CASE WHEN evts.effective_change_date < suph.effective_start_date
       THEN ''GAIN SUP EVENT ONLY''
       WHEN evts.effective_change_date > suph.effective_start_date
       THEN ''GAIN ASG EVENT ONLY''
       ELSE ''GAIN ASG SUP EVENT''
  END                                         admin_row_type
  ,evts.rowid                                 admin_evts_rowid
  ,suph.rowid                                 admin_suph_rowid
  ,jobh.rowid                                 admin_jobh_rowid
  ,geoh.rowid                                 admin_geoh_rowid
  ,:l_current_time
  ,' || l_user_id || '
  ,' || l_user_id || '
  ,' || l_user_id || '
  ,:l_current_time
  ,sub_assignment_id                sub_assignment_id' ||
   l_part_col_value || '
  FROM
   hri_mb_asgn_events_ct     evts
  ,hri_cs_jobh_ct            jobh
  ,hri_cs_geo_lochr_ct       geoh
  ,hri_cs_prsntyp_ct         prsn
  ,hri_cs_job_job_role_ct    rolj
  ,hri_cs_suph               suph
  WHERE suph.sub_person_id = evts.supervisor_id
  AND suph.sup_invalid_flag_code = ''N''
  AND (evts.effective_change_date BETWEEN suph.effective_start_date
                                  AND suph.effective_end_date
   OR suph.effective_start_date BETWEEN evts.effective_change_date
                                AND evts.effective_change_end_date)
  AND evts.pre_sprtn_asgn_end_ind = 0
  AND evts.worker_term_ind = 0
  AND geoh.location_id = evts.location_id
  AND jobh.job_id = evts.job_id
  AND evts.assignment_id between :start_object_id and :end_object_id
  AND evts.prsntyp_sk_fk = prsn.prsntyp_sk_pk
  AND evts.job_id = rolj.job_id
  UNION ALL
  SELECT /*+ ORDERED */
  suph.sup_person_id                          supervisor_person_id
  ,evts.supervisor_id                         direct_supervisor_person_id
  ,LEAST(evts.effective_change_end_date, suph.effective_end_date) + 1
                                              effective_date
  ,null                                       effective_end_date
  ,evts.effective_change_end_date             evts_effective_end_date
  ,suph.effective_end_date                    suph_effective_end_date
  ,evts.pow_start_date_adj                    pow_start_date
  ,to_char(evts.pow_start_date_adj,''J'') * evts.summarization_rqd_ind
                                              pow_value_days_julian
  ,nvl(to_char(evts.pow_extn_strt_dt,''J'') * evts.summarization_rqd_ind,0)
                                              pow_extn_days_julian
  ,evts.event_id                              event_id
  ,evts.person_id                             person_id
  ,evts.assignment_id                         assignment_id
  ,evts.location_id                           location_id
  ,evts.job_id                                job_id
  ,evts.organization_id                       organization_id
  ,evts.position_id                           position_id
  ,evts.grade_id                              grade_id
  ,prsn.wkth_wktyp_sk_fk                      wkth_wktyp_sk_fk
  ,prsn.wkth_lvl1_sk_fk                       wkth_lvl1_sk_fk
  ,prsn.wkth_lvl2_sk_fk                       wkth_lvl2_sk_fk
  ,evts.pow_band_sk_fk                        pow_band_sk_fk
  ,jobh.job_fmly_code                         job_fmly_code
  ,jobh.job_fnctn_code                        job_fnctn_code
  ,CASE WHEN rolj.primary_role_for_job_flag = ''Y''
        THEN rolj.job_role_code
        ELSE ''NA_EDW''
   END                                        primary_job_role_code
  ,geoh.area_code                             geo_area_code
  ,geoh.country_code                          geo_country_code
  ,geoh.region_code                           geo_region_code
  ,geoh.city_cid                              geo_city_cid
  ,evts.leaving_reason_code                   leaving_reason_code
  ,CASE WHEN suph.effective_end_date < evts.effective_change_end_date
        THEN ''NA_EDW''
        ELSE evts.separation_category_nxt
   END                                         separation_category
  ,evts.perf_band                              perf_band
  ,prsn.wkth_wktyp_code                        wkth_wktyp_code
  ,evts.anl_slry_currency                      anl_slry_currency
  ,evts.anl_slry * evts.summarization_rqd_ind  anl_slry_value
  ,evts.headcount * evts.summarization_rqd_ind headcount_value
  ,evts.fte * evts.summarization_rqd_ind       fte_value
  ,0                                           worker_hire_ind
  ,0                                           post_hire_asgn_start_ind
  ,CASE WHEN suph.effective_end_date < evts.effective_change_end_date
       THEN 0
       ELSE evts.worker_term_nxt_ind
  END                                         worker_term_ind
  ,CASE WHEN suph.effective_end_date < evts.effective_change_end_date
       THEN 0
       ELSE evts.term_voluntary_nxt_ind
  END                                         term_voluntary_ind
  ,CASE WHEN suph.effective_end_date < evts.effective_change_end_date
       THEN 0
       ELSE evts.term_involuntary_nxt_ind
  END                                         term_involuntary_ind
  ,CASE WHEN suph.effective_end_date < evts.effective_change_end_date
       THEN 0
       ELSE evts.pre_sprtn_asgn_end_nxt_ind
  END                                         pre_sprtn_asgn_end_ind
  ,0                                          transfer_in_ind
  ,CASE WHEN suph.effective_end_date < evts.effective_change_end_date
       THEN 1
       WHEN suph.effective_end_date > evts.effective_change_end_date
       THEN evts.supervisor_change_nxt_ind
       ELSE 1 - (evts.worker_term_nxt_ind + evts.pre_sprtn_asgn_end_nxt_ind)
  END                                         transfer_out_ind
  ,DECODE(suph.sub_relative_level, 0, 1, 0)   direct_ind
  --
  -- 4013742
  -- Set primary_flag_ind and primary_asg_with_hdc_ind to 0
  -- when summarization is not required
  --
  ,CASE WHEN evts.primary_flag = ''Y''
        THEN 1 * evts.summarization_rqd_ind ELSE 0 END
                                              primary_flag_ind
  ,CASE WHEN evts.primary_flag = ''Y'' and evts.headcount > 0
         THEN 1 * evts.summarization_rqd_ind ELSE 0 END
                                              primary_asg_with_hdc_ind
  ,evts.summarization_rqd_ind                 summarization_rqd_ind
  ,CASE
     WHEN suph.effective_end_date >= evts.effective_change_end_date THEN
       evts.summarization_rqd_chng_nxt_ind
     ELSE
       0
   END                                        summarization_rqd_chng_ind
  ,-1                                         metric_adjust_multiplier
  ,suph.sup_level                             supervisor_level
  ,CASE WHEN suph.effective_end_date < evts.effective_change_end_date
       THEN ''LOSS SUP EVENT ONLY''
       WHEN suph.effective_end_date > evts.effective_change_end_date
       THEN ''LOSS ASG EVENT ONLY''
       ELSE ''LOSS ASG SUP EVENT''
  END                                         admin_row_type
  ,evts.rowid                                 admin_evts_rowid
  ,suph.rowid                                 admin_suph_rowid
  ,jobh.rowid                                 admin_jobh_rowid
  ,geoh.rowid                                 admin_geoh_rowid
  ,:l_current_time
  ,' || l_user_id || '
  ,' || l_user_id || '
  ,' || l_user_id || '
  ,:l_current_time
  ,sub_assignment_id                sub_assignment_id' ||
   l_part_col_value || '
  FROM
   hri_mb_asgn_events_ct     evts
  ,hri_cs_jobh_ct            jobh
  ,hri_cs_geo_lochr_ct       geoh
  ,hri_cs_prsntyp_ct         prsn
  ,hri_cs_job_job_role_ct    rolj
  ,hri_cs_suph               suph
  WHERE suph.sub_person_id = evts.supervisor_id
  AND suph.sup_invalid_flag_code = ''N''
  AND (suph.effective_end_date BETWEEN evts.effective_change_date
                               AND evts.effective_change_end_date
   OR evts.effective_change_end_date BETWEEN suph.effective_start_date
                                     AND suph.effective_end_date)
  AND evts.pre_sprtn_asgn_end_ind = 0
  AND evts.worker_term_ind = 0
  AND geoh.location_id = evts.location_id
  AND jobh.job_id = evts.job_id
  AND evts.assignment_id between :start_object_id and :end_object_id
  AND LEAST(suph.effective_end_date,
            evts.effective_change_end_date) < :end_of_time
  AND evts.prsntyp_sk_fk = prsn.prsntyp_sk_pk
  AND evts.job_id = rolj.job_id';
  --
  EXECUTE IMMEDIATE l_sql_stmt USING
   l_current_time, l_current_time, p_start_object_id, p_end_object_id,
   l_current_time, l_current_time, p_start_object_id, p_end_object_id,
   hr_general.end_of_time;
  --
  dbg(SQL%ROWCOUNT||' records inserted into ' || l_table_name);
  --
  dbg('Exiting process_range');
  --
EXCEPTION WHEN OTHERS THEN
    --
    output(sqlerrm);
    --
    --
    RAISE;
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
  dbg('Inside pre_process');
  --
  -- Set up the parameters
  --
  set_parameters
   (p_mthd_action_id  => p_mthd_action_id,
    p_mthd_stage_code => 'PRE_PROCESS');
  --
  -- Disable the WHO trigger
  --
  run_sql_stmt_noerr('ALTER TRIGGER HRI_MAP_SUP_WRKFC_ASG_WHO DISABLE');
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
      dbg('Inside Full Refresh');
      --
      -- Set up staging table for redo reduction
      --
      IF (g_redo_reduction = 'Y') THEN
        hri_utl_stage_table.set_up
         (p_owner => l_schema,
          p_master_table_name => 'HRI_MAP_SUP_WRKFC_ASG');
      END IF;
      --
      -- Disable the materilized view logs
      --
      manage_mview_logs(p_schema   => l_schema ,
                        p_enable_disable  => 'D');
      --
      -- Truncate the table
      --
      EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || l_schema || '.HRI_MAP_SUP_WRKFC_ASG';
      --
      -- Drop Indexes
      --
      hri_utl_ddl.log_and_drop_indexes(
                        p_application_short_name => 'HRI',
                        p_table_name    => 'HRI_MAP_SUP_WRKFC_ASG',
                        p_table_owner   => l_schema);
      --
      -- Select all people with employee assignments in the collection range.
      -- The bind variable must be present for this sql to work when called
      -- by PYUGEN, else itwill give error.
      --
      p_sqlstr :=
          'SELECT   DISTINCT
                    assignment_id object_id
           FROM     hri_mb_asgn_events_ct
           ORDER BY assignment_id';
    --
    --                    End of Full Refresh Section
    -- -------------------------------------------------------------------------
    --
    -- -------------------------------------------------------------------------
    --                   Start of Incremental Refresh Section
    --
    ELSE
      dbg('Inside Incremental Refresh');
      --
      -- Select all people  for whom events have occurred. The bind variable must
      -- be present for this sql to work when called by PYUGEN, else it will
      -- give error.
      --
      p_sqlstr :=
          'SELECT /*+ parallel (EQ, default, default) */ DISTINCT source_id object_id
           FROM   hri_eq_asg_sup_wrfc  eq
           ORDER BY object_id';

    --
    --                 End of Incremental Refresh Section
    -- -------------------------------------------------------------------------
    --
    END IF;
    --
  END IF;
  --
  dbg('Exiting pre_process');
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
  --
  --
  set_parameters
   (p_mthd_action_id  => p_mthd_action_id,
    p_mthd_stage_code => 'PROCESS_RANGE');
  --
  dbg('calling process_range for object range from '||p_start_object_id || ' to '|| p_end_object_id);
  --
  -- Based on the refresh type call the corresponding procedure
  --
  IF g_full_refresh = 'Y' THEN
    --
    process_range(p_start_object_id   => p_start_object_id
                 ,p_end_object_id     => p_end_object_id);
    --
  ELSE
    --
    incremental_process(p_start_object_id   => p_start_object_id
                       ,p_end_object_id     => p_end_object_id);
    --
  END IF;
  --
  errbuf  := 'SUCCESS';
  retcode := 0;
EXCEPTION
  WHEN others THEN
   output('Error encountered while processing' );
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
  hri_bpl_conc_log.record_process_start('HRI_OPL_SUP_WRKFC_ASG');
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
          p_master_table_name => 'HRI_MAP_SUP_WRKFC_ASG');
      END IF;
      --
      -- Enable the materialized view logs
      --
      manage_mview_logs(p_schema         => l_schema,
                        p_enable_disable => 'E');
      --
      --
      -- Create indexes
      --
      dbg('Full Refresh selected - Creating indexes');
      --
      hri_utl_ddl.recreate_indexes(
                        p_application_short_name => 'HRI',
                        p_table_name    => 'HRI_MAP_SUP_WRKFC_ASG',
                        p_table_owner   => l_schema);
      --
      -- Collect the statistics only when the process is not called by a concurrent manager
      --
      IF fnd_global.conc_request_id is null THEN
        --
        dbg('Running from outside the request set - gathering stats');
        fnd_stats.gather_table_stats(l_schema,'HRI_MAP_SUP_WRKFC_ASG');
        --
      END IF;
      --
    END IF;
  --
  ELSE
  --
  -- Remove duplicates in incremental mode
  -- Bug 4404897
  --
    DELETE /*+ INDEX(dlt hri_map_sup_wrkfc_asg_n4) */
    FROM hri_map_sup_wrkfc_asg dlt
    WHERE assignment_id IN
     (SELECT source_id
      FROM hri_eq_asg_sup_wrfc evt
      WHERE evt.source_type = 'ASG_EVENT')
    AND EXISTS
     (SELECT /*+ INDEX(dlt2 hri_map_sup_wrkfc_asg_n4) */
       NULL
      FROM
       hri_map_sup_wrkfc_asg  dlt2
      WHERE dlt2.assignment_id = dlt.assignment_id
      AND dlt2.evts_effective_end_date = dlt.evts_effective_end_date
      AND dlt2.supervisor_person_id = dlt.supervisor_person_id
      AND dlt2.effective_date = dlt.effective_date
      AND dlt2.metric_adjust_multiplier = dlt.metric_adjust_multiplier
      AND dlt2.ROWID > dlt.ROWID);
  --
  END IF;
  --
  -- Truncate the assignment delta events queue
  --
  IF (fnd_installation.get_app_info('HRI',l_dummy1, l_dummy2, l_schema)) THEN
    --
    dbg('Truncating the assignment events equeue');
    --
    run_sql_stmt_noerr('TRUNCATE TABLE '||l_schema||'.HRI_EQ_ASG_SUP_WRFC');
    --
  END IF;
  --
  -- Enable the WHO trigger on the events fact table
  --
  run_sql_stmt_noerr('ALTER TRIGGER HRI_MAP_SUP_WRKFC_ASG_WHO ENABLE');
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
          FROM    (SELECT   DISTINCT assignment_id object_id
                   FROM     hri_mb_asgn_events_ct
                   ORDER BY assignment_id)
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
    dbg('Error in load_table = ');
    dbg(SQLERRM);
    RAISE;
    --
END load_table;
--
END HRI_OPL_SUP_WRKFC_ASG;

/
