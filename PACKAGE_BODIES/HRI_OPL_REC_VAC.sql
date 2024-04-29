--------------------------------------------------------
--  DDL for Package Body HRI_OPL_REC_VAC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OPL_REC_VAC" AS
/* $Header: hriprvac.pkb 120.5.12000000.2 2007/04/12 13:28:25 smohapat noship $ */
--
-- Types required to support tables of column values.
--
-- @@ Code specific to this view/table below
-- @@ INTRUCTION TO DEVELOPER:
-- @@ 1/ For each column in your 'source view' create a TYPE in the format
-- @@    g_<col_name>_type.  Each TYPE should be a table of 'target table.
-- @@    column'%TYPE indexed by binary_integer. i.e.:
-- @@
-- @@    TYPE g_<col_name>_type IS TABLE OF
-- @@      <target_table>%TYPE
-- @@      INDEX BY BINARY_INTEGER;
-- @@
--

TYPE g_pos_position_type IS TABLE OF
hri_mb_rec_vacancy_ct.pos_position_fk%TYPE
INDEX BY BINARY_INTEGER;

TYPE g_rvac_vacncy_type  IS TABLE OF
hri_mb_rec_vacancy_ct.rvac_vacncy_fk%TYPE
INDEX BY BINARY_INTEGER;

TYPE g_org_organztn_type IS TABLE OF
hri_mb_rec_vacancy_ct.org_organztn_fk%TYPE
INDEX BY BINARY_INTEGER;

TYPE g_org_organztn_mrgd_type IS TABLE OF
hri_mb_rec_vacancy_ct.org_organztn_mrgd_fk%TYPE
INDEX BY BINARY_INTEGER;

TYPE g_geo_location_type IS TABLE OF
hri_mb_rec_vacancy_ct.geo_location_fk%TYPE
INDEX BY BINARY_INTEGER;

TYPE g_job_job_type      IS TABLE OF
hri_mb_rec_vacancy_ct.job_job_fk%TYPE
INDEX BY BINARY_INTEGER;

TYPE g_grd_grade_type    IS TABLE OF
hri_mb_rec_vacancy_ct.grd_grade_fk%TYPE
INDEX BY BINARY_INTEGER;

TYPE g_time_day_vac_end_type IS TABLE OF
hri_mb_rec_vacancy_ct.time_day_vac_end_fk%TYPE
INDEX BY BINARY_INTEGER;

TYPE g_per_person_recr_type  IS TABLE OF
hri_mb_rec_vacancy_ct.per_person_recr_fk%TYPE
INDEX BY BINARY_INTEGER;

TYPE g_per_person_rmgr_type  IS TABLE OF
hri_mb_rec_vacancy_ct.per_person_rmgr_fk%TYPE
INDEX BY BINARY_INTEGER;

TYPE g_per_person_rsed_type  IS TABLE OF
hri_mb_rec_vacancy_ct.per_person_rsed_fk%TYPE
INDEX BY BINARY_INTEGER;

TYPE g_per_person_mrgd_type  IS TABLE OF
hri_mb_rec_vacancy_ct.per_person_mrgd_fk%TYPE
INDEX BY BINARY_INTEGER;

TYPE g_time_day_vac_strt_type IS TABLE OF
hri_mb_rec_vacancy_ct.time_day_vac_strt_fk%TYPE
INDEX BY BINARY_INTEGER;

TYPE g_number_of_openings_type     IS TABLE OF
hri_mb_rec_vacancy_ct.number_of_openings%TYPE
INDEX BY BINARY_INTEGER;

TYPE g_budget_measurement_val_type IS TABLE OF
hri_mb_rec_vacancy_ct.budget_measurement_value%TYPE
INDEX BY BINARY_INTEGER;

TYPE g_adt_business_grp_id_type    IS TABLE OF
hri_mb_rec_vacancy_ct.adt_business_group_id%TYPE
INDEX BY BINARY_INTEGER;

TYPE g_adt_vac_status_code_type    IS TABLE OF
hri_mb_rec_vacancy_ct.adt_vacancy_status_code%TYPE
INDEX BY BINARY_INTEGER;

TYPE g_adt_budget_type_code_type   IS TABLE OF
hri_mb_rec_vacancy_ct.adt_budget_type_code%TYPE
INDEX BY BINARY_INTEGER;

TYPE g_adt_vac_cat_code_type       IS TABLE OF
hri_mb_rec_vacancy_ct.adt_vacancy_category_code%TYPE
INDEX BY BINARY_INTEGER;

TYPE g_sysdate_type       IS TABLE OF
hri_mb_rec_vacancy_ct.CREATION_DATE %TYPE
INDEX BY BINARY_INTEGER;

TYPE g_user_id_type       IS TABLE OF
hri_mb_rec_vacancy_ct.LAST_UPDATED_BY %TYPE
INDEX BY BINARY_INTEGER;


--
-- @@ Code specific to this view/table below ENDS
--
--
-- PLSQL tables representing database table columns
--
g_pos_position_fk       	g_pos_position_type;
g_rvac_vacncy_fk        	g_rvac_vacncy_type ;
g_org_organztn_fk       	g_org_organztn_type;
g_org_organztn_mrgd_fk  	g_org_organztn_type;
g_geo_location_fk       	g_geo_location_type;
g_job_job_fk            	g_job_job_type;
g_grd_grade_fk          	g_grd_grade_type;
g_time_day_vac_end_fk   	g_time_day_vac_end_type;
g_per_person_recr_fk    	g_per_person_recr_type;
g_per_person_rmgr_fk    	g_per_person_rmgr_type;
g_per_person_rsed_fk    	g_per_person_rsed_type;
g_per_person_mrgd_fk    	g_per_person_rsed_type;
g_time_day_vac_strt_fk  	g_time_day_vac_strt_type;
g_number_of_openings    	g_number_of_openings_type;
g_budget_measurement_value      g_budget_measurement_val_type;
g_adt_business_group_id         g_adt_business_grp_id_type;
g_adt_vacancy_status_code       g_adt_vac_status_code_type;
g_adt_budget_type_code          g_adt_budget_type_code_type;
g_adt_vacancy_category_code     g_adt_vac_cat_code_type;
-- WHO Columns
g_sysdate                       g_sysdate_type;
g_user_id                       g_user_id_type;
--
-- Holds the range for which the collection is to be run.
--
g_start_date    DATE;
g_end_date      DATE;
g_end_of_time   DATE;
g_full_refresh  VARCHAR2(10);
--
-- The HRI schema
--
g_schema                  VARCHAR2(400);
--
-- Set to true to output to a concurrent log file
--
g_conc_request_flag       BOOLEAN := FALSE;
--
-- Number of rows bulk processed at a time
--
g_chunk_size              PLS_INTEGER;
--
-- End of time date
--
-- CONSTANTS
-- =========
--
-- @@ Code specific to this view/table below
-- @@ in the call to hri_bpl_conc_log.get_last_collect_to_date
-- @@ change param1/2 to be the concurrent program short name,
-- @@ and the target table name respectively.
--
g_target_table          VARCHAR2(30) DEFAULT 'HRI_MB_REC_VACANCY_CT';
g_cncrnt_prgrm_shrtnm   VARCHAR2(30) DEFAULT 'HRI_MB_REC_VACANCY_CT';
--
-- @@ Code specific to this view/table below ENDS
--
-- constants that hold the value that indicates to full refresh or not.
--
g_is_full_refresh    VARCHAR2(5) DEFAULT 'Y';
g_not_full_refresh   VARCHAR2(5) DEFAULT 'N';

--
-- ----------------------------------------------------------------------------
-- Runs given sql statement dynamically
-- ----------------------------------------------------------------------------
PROCEDURE run_sql_stmt_noerr(p_sql_stmt   VARCHAR2)
IS
BEGIN

  EXECUTE IMMEDIATE p_sql_stmt;

EXCEPTION WHEN OTHERS THEN

  null;

END run_sql_stmt_noerr;

-- -------------------------------------------------------------------------
--
--
-- Inserts row into concurrent program log when the g_conc_request_flag has
-- been set to TRUE, otherwise does nothing
--
PROCEDURE output(p_text  VARCHAR2)
  IS
  --
BEGIN
  --
  -- Write to the concurrent request log if called from a concurrent request
  --
  IF (g_conc_request_flag = TRUE) THEN
    --
    -- Put text to log file
    --
    fnd_file.put_line(FND_FILE.log, p_text);
    --
  END IF;
  --
END output;
--
-- -------------------------------------------------------------------------
--
-- Recovers rows to insert when an exception occurs
--
PROCEDURE recover_insert_rows(p_stored_rows_to_insert NUMBER) IS

BEGIN
  --
  -- loop through rows still to insert one at a time
  --
  FOR i IN 1..p_stored_rows_to_insert LOOP
    --
    -- Trap unique constraint errors
    --
    BEGIN
      --
      -- @@ Code specific to this view/table below
      -- @@ INTRUCTION TO DEVELOPER:
      -- @@ 1/ For each column in your view put a column in the insert
      -- @@ statement below.
      -- @@ 2/ Prefix each column in the VALUE clause with g_
      -- @@ 3/ make sure (i) is at the end of each column in the value clause
      --
      INSERT INTO hri_mb_rec_vacancy_ct
        (pos_position_fk
	,rvac_vacncy_fk
	,org_organztn_fk
	,org_organztn_mrgd_fk
	,geo_location_fk
	,job_job_fk
	,grd_grade_fk
	,time_day_vac_end_fk
	,per_person_recr_fk
	,per_person_rmgr_fk
	,per_person_rsed_fk
	,per_person_mrgd_fk
	,time_day_vac_strt_fk
        ,vac_strt_date
	,number_of_openings
	,budget_measurement_value
	,adt_business_group_id
	,adt_vacancy_status_code
	,adt_budget_type_code
        ,adt_vacancy_category_code
        ,creation_date
        ,created_by
        ,last_updated_by
        ,last_update_login
        ,last_update_date
        )
      VALUES
        (g_pos_position_fk(i)
        ,g_rvac_vacncy_fk(i)
        ,g_org_organztn_fk(i)
        ,g_org_organztn_mrgd_fk(i)
        ,g_geo_location_fk(i)
        ,g_job_job_fk(i)
        ,g_grd_grade_fk(i)
        ,g_time_day_vac_end_fk(i)
        ,g_per_person_recr_fk(i)
        ,g_per_person_rmgr_fk(i)
        ,g_per_person_rsed_fk(i)
        ,g_per_person_mrgd_fk(i)
        ,g_time_day_vac_strt_fk(i)
        ,g_time_day_vac_strt_fk(i) -- for vac_start_date
        ,g_number_of_openings(i)
        ,g_budget_measurement_value(i)
        ,g_adt_business_group_id(i)
        ,g_adt_vacancy_status_code(i)
        ,g_adt_budget_type_code(i)
        ,g_adt_vacancy_category_code(i)
        ,g_sysdate(i)
        ,g_user_id(i)
        ,g_user_id(i)
        ,g_user_id(i)
        ,g_sysdate(i)
        );
      --
      -- @@Code specific to this view/table below ENDS
      --
    EXCEPTION
      --
      WHEN OTHERS THEN
        --
        -- Probable overlap on date tracked assignment rows
        --
        output('Single insert error: ' || to_char(g_rvac_vacncy_fk(i)) ||
               ' - ' || to_char(g_pos_position_fk(i)));
        --
        output(sqlerrm);
        output(sqlcode);
        --
      --
    END;
    --
  END LOOP;
  --
  COMMIT;
  --
END recover_insert_rows;
--
-- -------------------------------------------------------------------------
--
-- Bulk inserts rows from global temporary table to database table
--
PROCEDURE bulk_insert_rows(p_stored_rows_to_insert NUMBER) IS
  --
BEGIN
  --
  -- insert chunk of rows
  --
  -- @@ Code specific to this view/table below
  -- @@ INTRUCTION TO DEVELOPER:
  -- @@ 1/ For each column in your view put a column in the insert statement
  --       below.
  -- @@ 2/ Prefix each column in the VALUE clause with g_
  -- @@ 3/ make sure (i) is at the end of each column in the value clause
  --
  FORALL i IN 1..p_stored_rows_to_insert
      INSERT INTO hri_mb_rec_vacancy_ct
        (pos_position_fk
	,rvac_vacncy_fk
	,org_organztn_fk
	,org_organztn_mrgd_fk
	,geo_location_fk
	,job_job_fk
	,grd_grade_fk
	,time_day_vac_end_fk
	,per_person_recr_fk
	,per_person_rmgr_fk
	,per_person_rsed_fk
	,per_person_mrgd_fk
	,time_day_vac_strt_fk
        ,vac_strt_date
	,number_of_openings
	,budget_measurement_value
	,adt_business_group_id
	,adt_vacancy_status_code
	,adt_budget_type_code
        ,adt_vacancy_category_code
        ,creation_date
        ,created_by
        ,last_updated_by
        ,last_update_login
        ,last_update_date
        )
      VALUES
        (g_pos_position_fk(i)
        ,g_rvac_vacncy_fk(i)
        ,g_org_organztn_fk(i)
        ,g_org_organztn_mrgd_fk(i)
        ,g_geo_location_fk(i)
        ,g_job_job_fk(i)
        ,g_grd_grade_fk(i)
        ,g_time_day_vac_end_fk(i)
        ,g_per_person_recr_fk(i)
        ,g_per_person_rmgr_fk(i)
        ,g_per_person_rsed_fk(i)
        ,g_per_person_mrgd_fk(i)
        ,g_time_day_vac_strt_fk(i)
        ,g_time_day_vac_strt_fk(i) -- for vac_start_date
        ,g_number_of_openings(i)
        ,g_budget_measurement_value(i)
        ,g_adt_business_group_id(i)
        ,g_adt_vacancy_status_code(i)
        ,g_adt_budget_type_code(i)
        ,g_adt_vacancy_category_code(i)
        ,g_sysdate(i)
        ,g_user_id(i)
        ,g_user_id(i)
        ,g_user_id(i)
        ,g_sysdate(i)
        );
  --
  -- @@Code specific to this view/table below ENDS
  --
  -- commit the chunk of rows
  --
  COMMIT;
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    -- Probable unique constraint error
    --
    ROLLBACK;
    --
    recover_insert_rows(p_stored_rows_to_insert);
    --
  --
END bulk_insert_rows;
--
-- -------------------------------------------------------------------------
--
-- Loops through table and collects into table structure.
--
PROCEDURE Incremental_Update IS
  --
BEGIN
  --
  -- @@ Code specific to this view/table below
  -- @@ INTRUCTION TO DEVELOPER:
  -- @@ 1/ Change the code below to reflect the columns in your view / table
  -- @@ 2/ Change the FROM, INSERT, DELETE statements to point at the relevant
  -- @@    source view / table
  --
  -- Insert completly new rows
  --
  -- log('Doing insert.');

      INSERT INTO hri_mb_rec_vacancy_ct
        (pos_position_fk
	,rvac_vacncy_fk
	,org_organztn_fk
	,org_organztn_mrgd_fk
	,geo_location_fk
	,job_job_fk
	,grd_grade_fk
	,time_day_vac_end_fk
	,per_person_recr_fk
	,per_person_rmgr_fk
	,per_person_rsed_fk
	,per_person_mrgd_fk
	,time_day_vac_strt_fk
        ,vac_strt_date
	,number_of_openings
	,budget_measurement_value
	,adt_business_group_id
	,adt_vacancy_status_code
	,adt_budget_type_code
        ,adt_vacancy_category_code
        ,creation_date
        ,created_by
        ,last_updated_by
        ,last_update_login
        ,last_update_date
        )
      SELECT
	  NVL(vac.position_id, -1)
	 ,vac.vacancy_id
	 ,NVL(vac.organization_id, -1)
	 ,NVL(vac.organization_id, vac.business_group_id)
	 ,NVL(vac.location_id, -1)
	 ,NVL(vac.job_id, -1)
	 ,NVL(vac.grade_id, -1)
	 ,NVL(vac.date_to, g_end_of_time)
	 ,NVL(vac.recruiter_id,-1)
	 ,NVL(vac.manager_id, -1)
         ,NVL(req.person_id, -1)
         ,hri_opl_rec_cand_pipln.get_merged_person_fk
           (NVL(vac.manager_id, -1)
           ,NVL(vac.recruiter_id, -1)
           ,NVL(req.person_id, -1)
           ,NVL(vac.organization_id, -1)
           ,vac.business_group_id)
	 ,vac.date_from
         ,vac.date_from          -- for vac_strt_date
	 ,vac.number_of_openings
	 ,vac.budget_measurement_value
	 ,vac.business_group_id
	 ,vac.status
	 ,vac.budget_measurement_type
	 ,vac.vacancy_category
         ,sysdate
         ,fnd_global.user_id
         ,fnd_global.user_id
         ,fnd_global.user_id
         ,sysdate
      FROM
       per_all_vacancies vac
      ,per_requisitions  req
      WHERE vac.last_update_date BETWEEN g_start_date AND g_end_date
      AND vac.requisition_id = req.requisition_id
      AND NOT EXISTS (SELECT 'x'
                      FROM   hri_mb_rec_vacancy_ct tbl
                      WHERE  vac.vacancy_id    = tbl.rvac_vacncy_fk);



  -- log('Insert >'||TO_CHAR(sql%rowcount));
  -- log('Doing update.');
  --

  UPDATE hri_mb_rec_vacancy_ct tbl
    SET (pos_position_fk
	,rvac_vacncy_fk
	,org_organztn_fk
	,org_organztn_mrgd_fk
	,geo_location_fk
	,job_job_fk
	,grd_grade_fk
	,time_day_vac_end_fk
	,per_person_recr_fk
	,per_person_rmgr_fk
	,per_person_rsed_fk
	,per_person_mrgd_fk
	,time_day_vac_strt_fk
        ,vac_strt_date
	,number_of_openings
	,budget_measurement_value
	,adt_business_group_id
	,adt_vacancy_status_code
	,adt_budget_type_code
        ,adt_vacancy_category_code
        ,creation_date
        ,created_by
        ,last_updated_by
        ,last_update_login
        ,last_update_date
        ) =
          (SELECT NVL(vac.position_id, -1)
                 ,vac.vacancy_id
                 ,NVL(vac.organization_id, -1)
	         ,NVL(vac.organization_id, vac.business_group_id)
                 ,NVL(vac.location_id, -1)
                 ,NVL(vac.job_id, -1)
                 ,NVL(vac.grade_id, -1)
                 ,NVL(vac.date_to, g_end_of_time)
                 ,NVL(vac.recruiter_id,-1)
                 ,NVL(vac.manager_id, -1)
                 ,NVL(req.person_id, -1)
                 ,hri_opl_rec_cand_pipln.get_merged_person_fk
                   (NVL(vac.manager_id, -1)
                   ,NVL(vac.recruiter_id, -1)
                   ,NVL(req.person_id, -1)
                   ,NVL(vac.organization_id, -1)
                   ,vac.business_group_id)
                 ,vac.date_from
                 ,vac.date_from
                 ,vac.number_of_openings
                 ,vac.budget_measurement_value
                 ,vac.business_group_id
                 ,vac.status
                 ,vac.budget_measurement_type
                 ,vac.vacancy_category
                 ,sysdate
                 ,fnd_global.user_id
                 ,fnd_global.user_id
                 ,fnd_global.user_id
                 ,sysdate
           FROM
            per_all_vacancies vac
           ,per_requisitions  req
           WHERE vac.last_update_date BETWEEN g_start_date
                                      AND     g_end_date
           AND req.requisition_id = vac.requisition_id
           AND vac.vacancy_id = tbl.rvac_vacncy_fk
           )
    WHERE (tbl.rvac_vacncy_fk)
          IN
          (SELECT vac.vacancy_id
           FROM   per_all_vacancies     vac
           WHERE  vac.last_update_date BETWEEN g_start_date
                                       AND     g_end_date);

  --
  -- log('Update >'||TO_CHAR(sql%rowcount));
  --
  -- Delete rows that no longer exist in the source view.
  --
  -- log('Doing delete.');

  DELETE
  FROM hri_mb_rec_vacancy_ct tbl
  WHERE tbl.rvac_vacncy_fk > 0
  AND NOT EXISTS
   (SELECT 'x'
    FROM  per_all_vacancies vac
    WHERE vac.vacancy_id      = tbl.rvac_vacncy_fk);


  -- log('Delete >'||TO_CHAR(sql%rowcount));
  --
  -- @@ Code specific to this view/table below ENDS
  --
  COMMIT ;
  -- log('Done incremental update.');
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    Output('Failure in incremental update process.');
    --
    RAISE;
    --
  --
END;
--
-- -------------------------------------------------------------------------
--
--
-- Loops through table and collects into table structure.
--
PROCEDURE Full_Refresh IS
  --
  -- Select all from the source view for materialization
  --
  -- @@ Code specific to this view/table below
  -- @@ INTRUCTION TO DEVELOPER:
  -- @@ 1/ Change the select beloe to select all the columns from your view
  -- @@ 2/ Change the FROM statement to point at the relevant source view
  --
  CURSOR source_view_csr IS
       SELECT     NVL(vac.position_id, -1)
                 ,vac.vacancy_id
                 ,NVL(vac.organization_id, -1)
                 ,NVL(vac.organization_id, vac.business_group_id)
                 ,NVL(vac.location_id, -1)
                 ,NVL(vac.job_id, -1)
                 ,NVL(vac.grade_id, -1)
                 ,NVL(vac.date_to, g_end_of_time)
                 ,NVL(vac.recruiter_id,-1)
                 ,NVL(vac.manager_id, -1)
                 ,NVL(req.person_id, -1)
                 ,hri_opl_rec_cand_pipln.get_merged_person_fk
                   (NVL(vac.manager_id, -1)
                   ,NVL(vac.recruiter_id, -1)
                   ,NVL(req.person_id, -1)
                   ,NVL(vac.organization_id, -1)
                   ,vac.business_group_id)
                 ,vac.date_from
                 ,vac.number_of_openings
                 ,vac.budget_measurement_value
                 ,vac.business_group_id
                 ,vac.status
                 ,vac.budget_measurement_type
                 ,vac.vacancy_category
                 ,sysdate
                 ,fnd_global.user_id
       FROM
        per_all_vacancies vac
       ,per_requisitions  req
       WHERE req.requisition_id = vac.requisition_id;

  --
  -- @@Code specific to this view/table below ENDS
  --
  l_exit_main_loop       BOOLEAN := FALSE;
  l_rows_fetched         PLS_INTEGER := g_chunk_size;
  l_sql_stmt             VARCHAR2(2000);
  --
BEGIN
  -- log('here ...');
  --
  -- Truncate the target table prior to full refresh.
  --
  l_sql_stmt := 'TRUNCATE TABLE ' || g_schema || '.'||g_target_table;
  -- log('>'||l_sql_stmt||'<');
  --
  EXECUTE IMMEDIATE(l_sql_stmt);
  -- log('truncateed ...');

  --Disable WHO TRIGGERS on table prior to full refresh

  run_sql_stmt_noerr('ALTER TRIGGER HRI_MB_REC_VACANCY_CT_WHO DISABLE');

  -- Drop all the INDEXES on the table
  hri_utl_ddl.log_and_drop_indexes
         (p_application_short_name => 'HRI',
          p_table_name             => 'HRI_MB_REC_VACANCY_CT',
          p_table_owner            =>  g_schema);


  --Disable INDEX on table prior to full refresh


  --
  -- Write timing information to log
  --
  output('Truncated the table:   '  ||
         to_char(sysdate,'HH24:MI:SS'));


  --
  -- Write timing information to log
  --
  output('Truncated the table:   '  ||
         to_char(sysdate,'HH24:MI:SS'));
  --
  -- open main cursor
  --
  -- log('open cursor ...');
  OPEN source_view_csr;
  --
  <<main_loop>>
  LOOP
    --
    -- bulk fetch rows limit the fetch to value of g_chunk_size
    --
    -- @@ Code specific to this view/table below
    -- @@ INTRUCTION TO DEVELOPER:
    -- @@ Change the bulk collect below to select all the columns from your
    -- @@ view
    --
    -- log('start fetch ...');
    -- log('>'||TO_CHAR(g_chunk_size)||'<');
    FETCH source_view_csr
    BULK COLLECT INTO
         g_pos_position_fk
        ,g_rvac_vacncy_fk
        ,g_org_organztn_fk
        ,g_org_organztn_mrgd_fk
        ,g_geo_location_fk
        ,g_job_job_fk
        ,g_grd_grade_fk
        ,g_time_day_vac_end_fk
        ,g_per_person_recr_fk
        ,g_per_person_rmgr_fk
        ,g_per_person_rsed_fk
        ,g_per_person_mrgd_fk
        ,g_time_day_vac_strt_fk
        ,g_number_of_openings
        ,g_budget_measurement_value
        ,g_adt_business_group_id
        ,g_adt_vacancy_status_code
        ,g_adt_budget_type_code
        ,g_adt_vacancy_category_code
        ,g_sysdate
        ,g_user_id
    LIMIT g_chunk_size;


    -- log('finish fetch ...');
    --
    -- @@Code specific to this view/table below ENDS
    --
    -- check to see if the last row has been fetched
    --
    IF source_view_csr%NOTFOUND THEN
      --
      -- last row fetched, set exit loop flag
      --
      l_exit_main_loop := TRUE;
      --
      -- do we have any rows to process?
      --
      l_rows_fetched := MOD(source_view_csr%ROWCOUNT,g_chunk_size);
      --
      -- note: if l_rows_fetched > 0 then more rows are required to be
      -- processed and the l_rows_fetched will contain the exact number of
      -- rows left to process
      --
      IF l_rows_fetched = 0 THEN
        --
        -- no more rows to process so exit loop
        --
        EXIT main_loop;
      END IF;
    END IF;
    --
    -- bulk insert rows processed so far
    --
    -- log('call bulk ...');
    bulk_insert_rows (l_rows_fetched);
    -- log('end bulk ...');
    --
    -- exit loop if required
    --
    IF l_exit_main_loop THEN
      --
      EXIT main_loop;
      --
    END IF;
    --
  END LOOP;
  --
  CLOSE source_view_csr;
  --
  -- Insert an Unassigned Row.
  --
  insert into hri_mb_rec_vacancy_ct
  ( time_day_vac_strt_fk
   ,vac_strt_date
   ,time_day_vac_end_fk
   ,per_person_recr_fk
   ,per_person_rmgr_fk
   ,per_person_rsed_fk
   ,per_person_mrgd_fk
   ,org_organztn_fk
   ,org_organztn_mrgd_fk
   ,geo_location_fk
   ,job_job_fk
   ,grd_grade_fk
   ,pos_position_fk
   ,rvac_vacncy_fk
   ,number_of_openings
   ,budget_measurement_value
   ,adt_business_group_id
   ,adt_vacancy_status_code
   ,adt_budget_type_code
   ,adt_vacancy_category_code
   ,creation_date
   ,created_by
   ,last_updated_by
   ,last_update_login
   ,last_update_date)
  values
  ( hr_general.start_of_time
   ,to_date(null)
   ,hr_general.end_of_time
   ,-1
   ,-1
   ,-1
   ,-1
   ,-1
   ,-1
   ,-1
   ,-1
   ,-1
   ,-1
   ,-1
   ,NULL
   ,NULL
   ,-1
   ,hri_oltp_view_message.get_unassigned_msg
   ,hri_oltp_view_message.get_unassigned_msg
   ,hri_oltp_view_message.get_unassigned_msg
   ,sysdate
   ,fnd_global.user_id
   ,fnd_global.user_id
   ,fnd_global.user_id
   ,sysdate
   );


  --Enable WHO TRIGGERS

    run_sql_stmt_noerr('ALTER TRIGGER HRI_MB_REC_VACANCY_CT_WHO ENABLE');

  --Enable INDEX

  hri_utl_ddl.recreate_indexes
       (p_application_short_name => 'HRI',
        p_table_name             => 'HRI_MB_REC_VACANCY_CT',
        p_table_owner            =>  g_schema);

  -- log('End ...');
EXCEPTION
  WHEN OTHERS THEN
    --
    -- unexpected error has occurred so close down
    -- main bulk cursor if it is open
    --
    IF source_view_csr%ISOPEN THEN
      --
      CLOSE source_view_csr;
      --
    END IF;
    --
    -- re-raise error
    RAISE;
    --
  --
END Full_Refresh;
--
-- -------------------------------------------------------------------------
-- Checks what mode you are running in, and if g_full_refresh =
-- g_is_full_refresh calls
-- Full_Refresh procedure, otherwise Incremental_Update is called.
--
PROCEDURE Collect IS
  --
BEGIN
  --
  -- If in full refresh mode chnage the dates so that the collection history
  -- is correctly maintained.
  --
  IF g_full_refresh = g_is_full_refresh THEN
    --
    g_start_date   := hr_general.start_of_time;
    g_end_date     := SYSDATE;
    --
    -- log('Doing full refresh.');
    Full_Refresh;
    --
  ELSE
    --
    -- log('Doing incremental update.');
    --
    -- If the passed in date range is NULL default it.
    --
    IF g_start_date IS NULL OR
       g_end_date   IS NULL
    THEN
    -- log('Input dates NULL.');
      --
      g_start_date   :=  fnd_date.displaydt_to_date(
                                  hri_bpl_conc_log.get_last_collect_to_date(
                                        g_cncrnt_prgrm_shrtnm
                                       ,g_target_table));
      --
      g_end_date     := SYSDATE;
      -- log('start >'||TO_CHAR(g_start_date));
      -- log('end >'||TO_CHAR(g_end_date));
      -- log('Defaulted input DATES.');
      --
    END IF;
    --
    -- log('Calling incremenatal update.');
    Incremental_Update;
    -- log('Called incremenatal update.');
    --
  END IF;
  --
END Collect;
--
-- -------------------------------------------------------------------------
-- Checks if the Target table is Empty
--
FUNCTION Target_table_is_Empty RETURN BOOLEAN IS
  --
  -- @@ Code specific to this view/table below
  -- @@ INTRUCTION TO DEVELOPER:
  -- @@ Change the table in the FROM clause below to be the same as  your
  -- @@ target table.
  --
  CURSOR csr_recs_exist IS
  SELECT 'x'
  FROM   hri_mb_rec_vacancy_ct;
  --
  -- @@ Code specific to this view/table ENDS
  --
  l_exists_chr    VARCHAR2(1);
  l_exists        BOOLEAN;
  --
BEGIN
  --
  OPEN csr_recs_exist;
  --
  FETCH csr_recs_exist INTO l_exists_chr;
  --
  IF (csr_recs_exist%NOTFOUND)
  THEN
    --
    l_exists := TRUE;
    -- log('no data in table');
    --
  ELSE
    --
    l_exists := FALSE;
    -- log('data is in table');
    --
  END IF;
  --
  CLOSE csr_recs_exist;
  --
  RETURN l_exists;
  --
EXCEPTION
  --
  WHEN OTHERS
  THEN
    --
    CLOSE csr_recs_exist;
    RAISE;
    --
  --
END Target_table_is_Empty;
--
-- -------------------------------------------------------------------------
--
-- Main entry point to load the table.
--
PROCEDURE Load(p_chunk_size    IN NUMBER,
               p_start_date    IN VARCHAR2,
               p_end_date      IN VARCHAR2,
               p_full_refresh  IN VARCHAR2) IS
  --
  -- Variables required for table truncation.
  --
  l_dummy1        VARCHAR2(2000);
  l_dummy2        VARCHAR2(2000);
  --
BEGIN
  --
  output('PL/SQL Start:   ' || to_char(sysdate,'HH24:MI:SS'));
  --
  -- Set globals
  --
  g_start_date := fnd_date.canonical_to_date(p_start_date);
  g_end_date   := fnd_date.canonical_to_date(p_end_date);
  --
  IF p_chunk_size IS NULL
  THEN
    --
    g_chunk_size := 1500;
    --
  ELSE
    --
    g_chunk_size   := p_chunk_size;
    --
  END IF;
  --
  IF p_full_refresh IS NULL
  THEN
    --
    g_full_refresh := g_not_full_refresh;
    --
  ELSE
    --
    g_full_refresh := p_full_refresh;
    --
  END IF;
  --
  -- If the target table is empty default to full refresh.
  --
  IF Target_table_is_Empty
  THEN
    --
    output('Target table '||g_target_table||
           ' is empty, so doing a full refresh.');
    -- log('Doing a full refresh....');
    --
    g_full_refresh := g_is_full_refresh;
    --
  END IF;
  --
  -- log('p_chunk_size>'||TO_CHAR(g_chunk_size)||'<');
  -- Find the schema we are running in.
  --
  IF NOT fnd_installation.get_app_info('HRI',l_dummy1, l_dummy2, g_schema)
  THEN
    --
    -- Could not find the schema raising exception.
    --
    output('Could not find schema to run in.');
    --
    -- log('Could not find schema.');
    RAISE NO_DATA_FOUND;
    --
  END IF;
  --
  -- Update information about collection
  --
  -- log('Record process start.');
  /* double check correct val passed in below */
  hri_bpl_conc_log.record_process_start(g_cncrnt_prgrm_shrtnm);
  --
  -- Time at start
  --
  -- log('collect.');
  --
  -- Get HRI schema name - get_app_info populates l_schema
  --
  -- Insert new records
  --
  collect;
  -- log('collectED.');
  --
  -- Write timing information to log
  --
  output('Finished changes to the table:  '  ||
         to_char(sysdate,'HH24:MI:SS'));
  --
  -- Gather index stats
  --
  -- log('gather stats.');
  fnd_stats.gather_table_stats(g_schema, g_target_table);
  --
  -- Write timing information to log
  --
  output('Gathered stats:   '  ||
         to_char(sysdate,'HH24:MI:SS'));
  --
  -- log('log end.');
  hri_bpl_conc_log.log_process_end(
        p_status         => TRUE,
        p_period_from    => TRUNC(g_start_date),
        p_period_to      => TRUNC(g_end_date),
        p_attribute1     => p_full_refresh,
        p_attribute2     => p_chunk_size);
  -- log('-END-');
  --
EXCEPTION
  --
  WHEN OTHERS
  THEN
    --
    ROLLBACK;
    RAISE;
    --
  --
END Load;
--
-- -------------------------------------------------------------------------
--
-- Entry point to be called from the concurrent manager
--
PROCEDURE Load(errbuf          OUT NOCOPY VARCHAR2,
               retcode         OUT NOCOPY VARCHAR2)
IS
  --
  l_full_refresh     VARCHAR2(30);
  l_start_date       VARCHAR2(40);
  --
BEGIN
  --
  -- Enable output to concurrent request log
  --
  g_conc_request_flag := TRUE;
  g_end_of_time       := hr_general.end_of_time;
  --
  -- Set parameters
  --
  l_full_refresh := hri_oltp_conc_param.get_parameter_value
                       (p_parameter_name     => 'FULL_REFRESH',
                        p_process_table_name => 'HRI_MB_REC_VACANCY_CT');
  --
  -- Set the refresh start date
  --
  IF (l_full_refresh = 'Y') THEN
    l_start_date := hri_oltp_conc_param.get_parameter_value
                     (p_parameter_name     => 'FULL_REFRESH_FROM_DATE',
                      p_process_table_name => 'HRI_MB_REC_VACANCY_CT');
  ELSE
    l_start_date := fnd_date.date_to_canonical
                     (fnd_date.displaydt_to_date
                       (hri_bpl_conc_log.get_last_collect_to_date
                         ('HRI_MB_REC_VACANCY_CT','HRI_MB_REC_VACANCY_CT')));
  END IF;

  load(p_chunk_size   => to_number(null),
       p_start_date   => l_start_date,
       p_end_date     => fnd_date.date_to_canonical(sysdate),
       p_full_refresh => l_full_refresh);
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    errbuf  := SQLERRM;
    retcode := SQLCODE;
    --
  --
END load;
--
END HRI_OPL_REC_VAC;

/
