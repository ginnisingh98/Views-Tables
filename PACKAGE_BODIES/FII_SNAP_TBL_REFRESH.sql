--------------------------------------------------------
--  DDL for Package Body FII_SNAP_TBL_REFRESH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_SNAP_TBL_REFRESH" AS
/*$Header: FIISNPRB.pls 120.5 2006/06/02 00:17:15 hlchen noship $*/

   g_phase         VARCHAR2(80);
   g_debug_flag    VARCHAR2(1)  := NVL(FND_PROFILE.value('FII_DEBUG_MODE'), 'N');
   g_retcode       VARCHAR2(20) := NULL;
   g_fii_user_id   NUMBER;
   g_fii_login_id  NUMBER;
   g_fii_sysdate   DATE;
   g_schema_name   VARCHAR2(120) := 'FII';
   l_profile	   VARCHAR2(1);
   G_LOGIN_INFO_NOT_AVABLE EXCEPTION;

   --We use a un-shipped profile option FII_TEST_SYSDATE ("FII: Test Sysdate")
   --to reset different sysdate so that we can test for snapshot tables.
   g_test_sysdate  DATE := to_date(FND_PROFILE.value('FII_TEST_SYSDATE'), 'DD/MM/YYYY');

----------------------------------------------------
-- PROCEDURE Initialize  (private)
--
----------------------------------------------------

   PROCEDURE Initialize  IS

     l_count      NUMBER(15) := 0;
     l_dir        VARCHAR2(160);
     l_check      NUMBER;

   BEGIN

     g_phase := 'Do set up for log file';
     ----------------------------------------------
     -- Do set up for log file
     ----------------------------------------------

     l_dir := fnd_profile.value('BIS_DEBUG_LOG_DIRECTORY');
     ------------------------------------------------------
     -- Set default directory in CASE if the profile option
     -- BIS_DEBUG_LOG_DIRECTORY is not set up
     ------------------------------------------------------
     if l_dir is NULL THEN
       l_dir := FII_UTIL.get_utl_file_dir;
     end if;

     ----------------------------------------------------------------
     -- FII_UTIL.initialize will get profile options FII_DEBUG_MODE
     -- AND BIS_DEBUG_LOG_DIRECTORY AND set up the directory WHERE
     -- the log files AND output files are written to
     ----------------------------------------------------------------
     FII_UTIL.initialize('FII_SNAP_TBL_REFRESH.log',
                         'FII_SNAP_TBL_REFRESH.out',l_dir,
                         'FII_SNAP_TBL_REFRESH');

     g_phase := 'Obtain FII schema name AND other info';

     -- Obtain FII schema name
     g_schema_name := FII_UTIL.get_schema_name ('FII');

     -- Obtain user ID, login ID AND sysdate
     g_fii_user_id 	:= FND_GLOBAL.USER_ID;
     g_fii_login_id	:= FND_GLOBAL.LOGIN_ID;

     SELECT sysdate INTO g_fii_sysdate FROM dual;

     g_phase := 'Check FII schema name AND other info';
     -- If any of the above values is not set, error out
     IF (g_fii_user_id is NULL OR g_fii_login_id is NULL) THEN
       FII_UTIL.Write_Log ('>>> Failed Intialization (login info not available)');
       RAISE G_LOGIN_INFO_NOT_AVABLE;
     END IF;

     -- Determine if process will be run in debug mode
     IF g_debug_flag = 'Y' THEN
       FII_UTIL.Write_Log ('Debug On');
     ELSE
       FII_UTIL.Write_Log ('Debug Off');
     END IF;

     IF g_debug_flag = 'Y' THEN
       FII_UTIL.Write_Log ('Initialize: Now start processing... ');
     End If;

   Exception

     When others THEN
        FII_UTIL.Write_Log ('Unexpected error WHEN calling Initialize...');
        FII_UTIL.Write_Log ( 'G_PHASE: ' || G_PHASE);
	FII_UTIL.Write_Log ('Error Message: '|| substr(sqlerrm,1,180));
        RAISE;

   END Initialize;


----------------------------------------------------
-- PROCEDURE REFRESH_GL_SNAP_F  (private)
--
-- This procedure will (fully) refresh table FII_GL_SNAP_F
-- FROM FII_GL_BASE_MAP_MV
----------------------------------------------------
 PROCEDURE REFRESH_GL_SNAP_F IS

   l_this_date     DATE;
   l_pp_this_date  DATE;
   l_pq_this_date  DATE;
   l_ly_this_date  DATE;
   l_industry_pf   VARCHAR2(1);
   l_this_date_gov DATE;
   l_min_start_date DATE;

 BEGIN

  g_phase := 'Entering REFRESH_GL_SNAP_F';
  IF g_debug_flag = 'Y' THEN
    FII_UTIL.Write_Log ('> Entering REFRESH_GL_SNAP_F');
    FII_UTIL.start_timer();
  END IF;

  -- Find out if this is commercial or government install
  g_phase := 'Find out if this is commercial or government install';
  l_industry_pf := FND_PROFILE.value('INDUSTRY');

  g_phase := 'Populate l_this_date FROM BIS_SYSTEM_DATE';

  --We use a un-shipped profile option FII_TEST_SYSDATE ("FII: Test Sysdate")
  --to reset different sysdate so that we can test for snapshot tables.
  if g_test_sysdate is NULL THEN
    SELECT trunc(CURRENT_DATE_ID) INTO l_this_date
      FROM BIS_SYSTEM_DATE;
  ELSE
    l_this_date := g_test_sysdate;
  end if;

   SELECT MIN(start_date) INTO l_min_start_date
   FROM fii_time_ent_period;
  --------------------------------------------------

  g_phase := 'Populate l_pp_this_date, l_pq_this_date, l_ly_this_date, l_this_date_gov';

/* Commented out for bug 4899518 and replaced with select
  /*
  l_pp_this_date  := FII_TIME_API.ent_sd_pper_end(l_this_date);
   l_pq_this_date  := FII_TIME_API.ent_sd_pqtr_end(l_this_date);
   l_ly_this_date  := FII_TIME_API.ent_sd_lyr_end(l_this_date);
   l_this_date_gov := FII_TIME_API.ent_cper_end(l_this_date);
  */

SELECT	NVL(fii_time_api.ent_sd_pper_end(l_this_date),l_min_start_date),
	NVL(fii_time_api.ent_sd_pqtr_end(l_this_date),l_min_start_date),
	NVL(fii_time_api.ent_sd_lyr_end(l_this_date),l_min_start_date),
	NVL( fii_time_api.ent_cper_end(l_this_date),l_min_start_date)

INTO	l_pp_this_date,
	l_pq_this_date,
	l_ly_this_date,
	l_this_date_gov

FROM	DUAL;

  IF g_debug_flag = 'Y' THEN
     FII_UTIL.Write_Log ('>> l_this_date = '     || l_this_date);
     FII_UTIL.Write_Log ('>> l_pp_this_date = '  || l_pp_this_date);
     FII_UTIL.Write_Log ('>> l_pq_this_date = '  || l_pq_this_date);
     FII_UTIL.Write_Log ('>> l_ly_this_date = '  || l_ly_this_date);
     FII_UTIL.Write_Log ('>> l_this_date_gov = ' || l_this_date_gov);
     FII_UTIL.Write_Log ('>> l_industry_pf = '   || l_industry_pf);
     FII_UTIL.Write_Log (' ');
  END IF;

  --Always do a full refresh for snapshot tables
  g_phase := 'Truncate table FII_GL_SNAP_F';
  FII_UTIL.truncate_table ('FII_GL_SNAP_F', 'FII', g_retcode);

  g_phase := 'Starting to populate table FII_GL_SNAP_F';
  IF g_debug_flag = 'Y' THEN
     FII_UTIL.Write_Log ('>> Starting to populate table FII_GL_SNAP_F');
  END IF;


 --------------------------------------------------------------------------
 --Insert data FROM fii_gl_base_map_mv by joining to fii_time_structures.
 --Here we calculate XTD amounts for all four days at same time; the sql
 --query is similar to what we have for PMV reports (using bitand function)
 --------------------------------------------------------------------------

 insert /*+ append */ INTO FII_GL_SNAP_F
  ( COST_CENTER_DIM_ID,
    COMPANY_DIM_ID,
    FIN_CATEGORY_ID,
    USER_DIM1_ID,
    USER_DIM2_ID,
    LEDGER_ID,

    ACTUAL_B_CUR_MTD,
    ACTUAL_B_CUR_QTD,
    ACTUAL_B_CUR_YTD,
    ACTUAL_B_PRIOR_MTD,
    ACTUAL_B_PRIOR_QTD,
    ACTUAL_B_PRIOR_YTD,
    ACTUAL_B_LAST_YEAR_MTD,
    ACTUAL_B_LAST_YEAR_QTD,

    ACTUAL_PG_CUR_MTD,
    ACTUAL_PG_CUR_QTD,
    ACTUAL_PG_CUR_YTD,
    ACTUAL_PG_PRIOR_MTD,
    ACTUAL_PG_PRIOR_QTD,
    ACTUAL_PG_PRIOR_YTD,
    ACTUAL_PG_LAST_YEAR_MTD,
    ACTUAL_PG_LAST_YEAR_QTD,

    ACTUAL_SG_CUR_MTD,
    ACTUAL_SG_CUR_QTD,
    ACTUAL_SG_CUR_YTD,
    ACTUAL_SG_PRIOR_MTD,
    ACTUAL_SG_PRIOR_QTD,
    ACTUAL_SG_PRIOR_YTD,
    ACTUAL_SG_LAST_YEAR_MTD,
    ACTUAL_SG_LAST_YEAR_QTD,


    BUDGET_PG_CUR_MTD,
    BUDGET_PG_CUR_QTD,
    BUDGET_PG_CUR_YTD,
    BUDGET_PG_PRIOR_MTD,
    BUDGET_PG_PRIOR_QTD,
    BUDGET_PG_PRIOR_YTD,
    BUDGET_PG_LAST_YEAR_MTD,
    BUDGET_PG_LAST_YEAR_QTD,

    BUDGET_SG_CUR_MTD,
    BUDGET_SG_CUR_QTD,
    BUDGET_SG_CUR_YTD,
    BUDGET_SG_PRIOR_MTD,
    BUDGET_SG_PRIOR_QTD,
    BUDGET_SG_PRIOR_YTD,
    BUDGET_SG_LAST_YEAR_MTD,
    BUDGET_SG_LAST_YEAR_QTD,


    FORECAST_PG_CUR_MTD,
    FORECAST_PG_CUR_QTD,
    FORECAST_PG_CUR_YTD,
    FORECAST_PG_PRIOR_MTD,
    FORECAST_PG_PRIOR_QTD,
    FORECAST_PG_PRIOR_YTD,
    FORECAST_PG_LAST_YEAR_MTD,
    FORECAST_PG_LAST_YEAR_QTD,

    FORECAST_SG_CUR_MTD,
    FORECAST_SG_CUR_QTD,
    FORECAST_SG_CUR_YTD,
    FORECAST_SG_PRIOR_MTD,
    FORECAST_SG_PRIOR_QTD,
    FORECAST_SG_PRIOR_YTD,
    FORECAST_SG_LAST_YEAR_MTD,
    FORECAST_SG_LAST_YEAR_QTD,

       COMMITTED_AMT_PG_CUR_MTD,
       COMMITTED_AMT_PG_CUR_QTD,
       COMMITTED_AMT_PG_CUR_YTD,
       COMMITTED_AMT_PG_PRIOR_MTD,
       COMMITTED_AMT_PG_PRIOR_QTD,
       COMMITTED_AMT_PG_PRIOR_YTD,
       COMMITTED_AMT_PG_LAST_YEAR_MTD,
       COMMITTED_AMT_PG_LAST_YEAR_QTD,

       OBLIGATED_AMT_PG_CUR_MTD,
       OBLIGATED_AMT_PG_CUR_QTD,
       OBLIGATED_AMT_PG_CUR_YTD,
       OBLIGATED_AMT_PG_PRIOR_MTD,
       OBLIGATED_AMT_PG_PRIOR_QTD,
       OBLIGATED_AMT_PG_PRIOR_YTD,
       OBLIGATED_AMT_PG_LAST_YEAR_MTD,
       OBLIGATED_AMT_PG_LAST_YEAR_QTD,

       OTHER_AMT_PG_CUR_MTD,
       OTHER_AMT_PG_CUR_QTD,
       OTHER_AMT_PG_CUR_YTD,
       OTHER_AMT_PG_PRIOR_MTD,
       OTHER_AMT_PG_PRIOR_QTD,
       OTHER_AMT_PG_PRIOR_YTD,
       OTHER_AMT_PG_LAST_YEAR_MTD,
       OTHER_AMT_PG_LAST_YEAR_QTD,

       BASELINE_AMT_PG_CUR_MTD 	,
       BASELINE_AMT_PG_CUR_QTD,
       BASELINE_AMT_PG_CUR_YTD,
       BASELINE_AMT_PG_PRIOR_MTD,
       BASELINE_AMT_PG_PRIOR_QTD,
       BASELINE_AMT_PG_PRIOR_YTD,
       BASELINE_AMT_PG_LAST_YEAR_MTD,
       BASELINE_AMT_PG_LAST_YEAR_QTD,

   POSTED_DATE,

   LAST_UPDATE_DATE,
   LAST_UPDATED_BY,
   CREATION_DATE,
   CREATED_BY,
   LAST_UPDATE_LOGIN)
 SELECT
        cost_center_dim_id,
        company_dim_id,
        fin_category_id,
        user_dim1_id,
        user_dim2_id,
        ledger_id,

        SUM(CASE WHEN bitand(cal.record_type_id, 64) = 64
                  AND cal.report_date = l_this_date
                 THEN b.actual_b
                 ELSE NULL end) actual_b_cur_mtd,
        SUM(CASE WHEN bitand(cal.record_type_id, 128) = 128
                  AND cal.report_date = l_this_date
                 THEN b.actual_b
                 ELSE NULL end) actual_b_cur_qtd,
        SUM(CASE WHEN bitand(cal.record_type_id, 256) = 256
                  AND cal.report_date = l_this_date
                 THEN b.actual_b
                 ELSE NULL end) actual_b_cur_ytd,
        SUM(CASE WHEN bitand(cal.record_type_id, 64) = 64
                  AND cal.report_date = l_pp_this_date
                 THEN b.actual_b
                 ELSE NULL end) actual_b_prior_mtd,
        SUM(CASE WHEN bitand(cal.record_type_id, 128) = 128
                  AND cal.report_date = l_pq_this_date
                 THEN b.actual_b
                 ELSE NULL end) actual_b_prior_qtd,
        SUM(CASE WHEN bitand(cal.record_type_id, 256) = 256
                  AND cal.report_date = l_ly_this_date
                 THEN b.actual_b
                 ELSE NULL end) actual_b_prior_ytd,
        SUM(CASE WHEN bitand(cal.record_type_id, 64) = 64
                  AND cal.report_date = l_ly_this_date
                 THEN b.actual_b
                 ELSE NULL end) actual_b_last_year_mtd,
        SUM(CASE WHEN bitand(cal.record_type_id, 128) = 128
                  AND cal.report_date = l_ly_this_date
                 THEN b.actual_b
                 ELSE NULL end) actual_b_last_year_qtd,

        SUM(CASE WHEN bitand(cal.record_type_id, 64) = 64
                  AND cal.report_date = l_this_date
                 THEN b.prim_actual_g
                 ELSE NULL end) actual_pg_cur_mtd,
        SUM(CASE WHEN bitand(cal.record_type_id, 128) = 128
                  AND cal.report_date = l_this_date
                 THEN b.prim_actual_g
                 ELSE NULL end) actual_pg_cur_qtd,
        SUM(CASE WHEN bitand(cal.record_type_id, 256) = 256
                  AND cal.report_date = l_this_date
                 THEN b.prim_actual_g
                 ELSE NULL end) actual_pg_cur_ytd,
        SUM(CASE WHEN bitand(cal.record_type_id, 64) = 64
                  AND cal.report_date = l_pp_this_date
                 THEN b.prim_actual_g
                 ELSE NULL end) actual_pg_prior_mtd,
        SUM(CASE WHEN bitand(cal.record_type_id, 128) = 128
                  AND cal.report_date = l_pq_this_date
                 THEN b.prim_actual_g
                 ELSE NULL end) actual_pg_prior_qtd,
        SUM(CASE WHEN bitand(cal.record_type_id, 256) = 256
                  AND cal.report_date = l_ly_this_date
                 THEN b.prim_actual_g
                 ELSE NULL end) actual_pg_prior_ytd,
        SUM(CASE WHEN bitand(cal.record_type_id, 64) = 64
                  AND cal.report_date = l_ly_this_date
                 THEN b.prim_actual_g
                 ELSE NULL end) actual_pg_last_year_mtd,
        SUM(CASE WHEN bitand(cal.record_type_id, 128) = 128
                  AND cal.report_date = l_ly_this_date
                 THEN b.prim_actual_g
                 ELSE NULL end) actual_pg_last_year_qtd,

        SUM(CASE WHEN bitand(cal.record_type_id, 64) = 64
                  AND cal.report_date = l_this_date
                 THEN b.sec_actual_g
                 ELSE NULL end) actual_sg_cur_mtd,
        SUM(CASE WHEN bitand(cal.record_type_id, 128) = 128
                  AND cal.report_date = l_this_date
                 THEN b.sec_actual_g
                 ELSE NULL end) actual_sg_cur_qtd,
        SUM(CASE WHEN bitand(cal.record_type_id, 256) = 256
                  AND cal.report_date = l_this_date
                 THEN b.sec_actual_g
                 ELSE NULL end) actual_sg_cur_ytd,
        SUM(CASE WHEN bitand(cal.record_type_id, 64) = 64
                  AND cal.report_date = l_pp_this_date
                 THEN b.sec_actual_g
                 ELSE NULL end) actual_sg_prior_mtd,
        SUM(CASE WHEN bitand(cal.record_type_id, 128) = 128
                  AND cal.report_date = l_pq_this_date
                 THEN b.sec_actual_g
                 ELSE NULL end) actual_sg_prior_qtd,
        SUM(CASE WHEN bitand(cal.record_type_id, 256) = 256
                  AND cal.report_date = l_ly_this_date
                 THEN b.sec_actual_g
                 ELSE NULL end) actual_sg_prior_ytd,
        SUM(CASE WHEN bitand(cal.record_type_id, 64) = 64
                  AND cal.report_date = l_ly_this_date
                 THEN b.sec_actual_g
                 ELSE NULL end) actual_sg_last_year_mtd,
        SUM(CASE WHEN bitand(cal.record_type_id, 128) = 128
                  AND cal.report_date = l_ly_this_date
                 THEN b.sec_actual_g
                 ELSE NULL end) actual_sg_last_year_qtd,


        SUM(CASE WHEN bitand(cal.record_type_id, decode(l_industry_pf, 'G', 64, 4))
                      = decode(l_industry_pf, 'G', 64, 4)
                  AND cal.report_date = decode(l_industry_pf, 'G', l_this_date_gov, l_this_date)
                 THEN b.prim_budget_g
                 ELSE NULL end) budget_pg_cur_mtd,
        SUM(CASE WHEN bitand(cal.record_type_id, decode(l_industry_pf, 'G', 128, 8))
                      = decode(l_industry_pf, 'G', 128, 8)
                  AND cal.report_date = decode(l_industry_pf, 'G', l_this_date_gov, l_this_date)
                 THEN b.prim_budget_g
                 ELSE NULL end) budget_pg_cur_qtd,
        SUM(CASE WHEN bitand(cal.record_type_id, decode(l_industry_pf, 'G', 256, 16))
                      = decode(l_industry_pf, 'G', 256, 16)
                  AND cal.report_date = decode(l_industry_pf, 'G', l_this_date_gov, l_this_date)
                 THEN b.prim_budget_g
                 ELSE NULL end) budget_pg_cur_ytd,
        SUM(CASE WHEN bitand(cal.record_type_id, decode(l_industry_pf, 'G', 64, 4))
                      = decode(l_industry_pf, 'G', 64, 4)
                  AND cal.report_date = l_pp_this_date
                 THEN b.prim_budget_g
                 ELSE NULL end) budget_pg_prior_mtd,
        SUM(CASE WHEN bitand(cal.record_type_id, decode(l_industry_pf, 'G', 128, 8))
                      = decode(l_industry_pf, 'G', 128, 8)
                  AND cal.report_date = l_pq_this_date
                 THEN b.prim_budget_g
                 ELSE NULL end) budget_pg_prior_qtd,
        SUM(CASE WHEN bitand(cal.record_type_id, decode(l_industry_pf, 'G', 256, 16))
                      = decode(l_industry_pf, 'G', 256, 16)
                  AND cal.report_date = l_ly_this_date
                 THEN b.prim_budget_g
                 ELSE NULL end) budget_pg_prior_ytd,
        SUM(CASE WHEN bitand(cal.record_type_id, decode(l_industry_pf, 'G', 64, 4))
                      = decode(l_industry_pf, 'G', 64, 4)
                  AND cal.report_date = l_ly_this_date
                 THEN b.prim_budget_g
                 ELSE NULL end) budget_pg_last_year_mtd,
        SUM(CASE WHEN bitand(cal.record_type_id, decode(l_industry_pf, 'G', 128, 8))
                      = decode(l_industry_pf, 'G', 128, 8)
                  AND cal.report_date = l_ly_this_date
                 THEN b.prim_budget_g
                 ELSE NULL end) budget_pg_last_year_qtd,

        SUM(CASE WHEN bitand(cal.record_type_id, decode(l_industry_pf, 'G', 64, 4))
                      = decode(l_industry_pf, 'G', 64, 4)
                  AND cal.report_date = decode(l_industry_pf, 'G', l_this_date_gov, l_this_date)
                 THEN b.sec_budget_g
                 ELSE NULL end) budget_sg_cur_mtd,
        SUM(CASE WHEN bitand(cal.record_type_id, decode(l_industry_pf, 'G', 128, 8))
                      = decode(l_industry_pf, 'G', 128, 8)
                  AND cal.report_date = decode(l_industry_pf, 'G', l_this_date_gov, l_this_date)
                 THEN b.sec_budget_g
                 ELSE NULL end) budget_sg_cur_qtd,
        SUM(CASE WHEN bitand(cal.record_type_id, decode(l_industry_pf, 'G', 256, 16))
                      = decode(l_industry_pf, 'G', 256, 16)
                  AND cal.report_date = decode(l_industry_pf, 'G', l_this_date_gov, l_this_date)
                 THEN b.sec_budget_g
                 ELSE NULL end) budget_sg_cur_ytd,
        SUM(CASE WHEN bitand(cal.record_type_id, decode(l_industry_pf, 'G', 64, 4))
                      = decode(l_industry_pf, 'G', 64, 4)
                  AND cal.report_date = l_pp_this_date
                 THEN b.sec_budget_g
                 ELSE NULL end) budget_sg_prior_mtd,
        SUM(CASE WHEN bitand(cal.record_type_id, decode(l_industry_pf, 'G', 128, 8))
                      = decode(l_industry_pf, 'G', 128, 8)
                  AND cal.report_date = l_pq_this_date
                 THEN b.sec_budget_g
                 ELSE NULL end) budget_sg_prior_qtd,
        SUM(CASE WHEN bitand(cal.record_type_id, decode(l_industry_pf, 'G', 256, 16))
                      = decode(l_industry_pf, 'G', 256, 16)
                  AND cal.report_date = l_ly_this_date
                 THEN b.sec_budget_g
                 ELSE NULL end) budget_sg_prior_ytd,
        SUM(CASE WHEN bitand(cal.record_type_id, decode(l_industry_pf, 'G', 64, 4))
                      = decode(l_industry_pf, 'G', 64, 4)
                  AND cal.report_date = l_ly_this_date
                 THEN b.sec_budget_g
                 ELSE NULL end) budget_sg_last_year_mtd,
        SUM(CASE WHEN bitand(cal.record_type_id, decode(l_industry_pf, 'G', 128, 8))
                      = decode(l_industry_pf, 'G', 128, 8)
                  AND cal.report_date = l_ly_this_date
                 THEN b.sec_budget_g
                 ELSE NULL end) budget_sg_last_year_qtd,


        SUM(CASE WHEN bitand(cal.record_type_id, 4) = 4
                  AND cal.report_date = l_this_date
                 THEN b.prim_forecast_g
                 ELSE NULL end) forecast_pg_cur_mtd,
        SUM(CASE WHEN bitand(cal.record_type_id, 8) = 8
                  AND cal.report_date = l_this_date
                 THEN b.prim_forecast_g
                 ELSE NULL end) forecast_pg_cur_qtd,
        SUM(CASE WHEN bitand(cal.record_type_id, 16) = 16
                  AND cal.report_date = l_this_date
                 THEN b.prim_forecast_g
                 ELSE NULL end) forecast_pg_cur_ytd,
        SUM(CASE WHEN bitand(cal.record_type_id, 4) = 4
                  AND cal.report_date = l_pp_this_date
                 THEN b.prim_forecast_g
                 ELSE NULL end) forecast_pg_prior_mtd,
        SUM(CASE WHEN bitand(cal.record_type_id, 8) = 8
                  AND cal.report_date = l_pq_this_date
                 THEN b.prim_forecast_g
                 ELSE NULL end) forecast_pg_prior_qtd,
        SUM(CASE WHEN bitand(cal.record_type_id, 16) = 16
                  AND cal.report_date = l_ly_this_date
                 THEN b.prim_forecast_g
                 ELSE NULL end) forecast_pg_prior_ytd,
        SUM(CASE WHEN bitand(cal.record_type_id, 4) = 4
                  AND cal.report_date = l_ly_this_date
                 THEN b.prim_forecast_g
                 ELSE NULL end) forecast_pg_last_year_mtd,
        SUM(CASE WHEN bitand(cal.record_type_id, 8) = 8
                  AND cal.report_date = l_ly_this_date
                 THEN b.prim_forecast_g
                 ELSE NULL end) forecast_pg_last_year_qtd,

        SUM(CASE WHEN bitand(cal.record_type_id, 4) = 4
                  AND cal.report_date = l_this_date
                 THEN b.sec_forecast_g
                 ELSE NULL end) forecast_sg_cur_mtd,
        SUM(CASE WHEN bitand(cal.record_type_id, 8) = 8
                  AND cal.report_date = l_this_date
                 THEN b.sec_forecast_g
                 ELSE NULL end) forecast_sg_cur_qtd,
        SUM(CASE WHEN bitand(cal.record_type_id, 16) = 16
                  AND cal.report_date = l_this_date
                 THEN b.sec_forecast_g
                 ELSE NULL end) forecast_sg_cur_ytd,
        SUM(CASE WHEN bitand(cal.record_type_id, 4) = 4
                  AND cal.report_date = l_pp_this_date
                 THEN b.sec_forecast_g
                 ELSE NULL end) forecast_sg_prior_mtd,
        SUM(CASE WHEN bitand(cal.record_type_id, 8) = 8
                  AND cal.report_date = l_pq_this_date
                 THEN b.sec_forecast_g
                 ELSE NULL end) forecast_sg_prior_qtd,
        SUM(CASE WHEN bitand(cal.record_type_id, 16) = 16
                  AND cal.report_date = l_ly_this_date
                 THEN b.sec_forecast_g
                 ELSE NULL end) forecast_sg_prior_ytd,
        SUM(CASE WHEN bitand(cal.record_type_id, 4) = 4
                  AND cal.report_date = l_ly_this_date
                 THEN b.sec_forecast_g
                 ELSE NULL end) forecast_sg_last_year_mtd,
        SUM(CASE WHEN bitand(cal.record_type_id, 8) = 8
                  AND cal.report_date = l_ly_this_date
                 THEN b.sec_forecast_g
                 ELSE NULL end) forecast_sg_last_year_qtd,



        SUM(CASE WHEN bitand(cal.record_type_id, 64) = 64
                  AND cal.report_date = l_this_date_gov -- l_this_date
                 THEN b.committed_amount_prim
                 ELSE NULL end) committed_amt_pg_cur_mtd,
        SUM(CASE WHEN bitand(cal.record_type_id, 128) = 128
                  AND cal.report_date = l_this_date_gov -- l_this_date
                 THEN b.committed_amount_prim
                 ELSE NULL end) committed_amt_pg_cur_qtd,
        SUM(CASE WHEN bitand(cal.record_type_id, 256) = 256
                  AND cal.report_date = l_this_date_gov -- l_this_date
                 THEN b.committed_amount_prim
                 ELSE NULL end) committed_amt_pg_cur_ytd,
        SUM(CASE WHEN bitand(cal.record_type_id, 64) = 64
                  AND cal.report_date = l_pp_this_date
                 THEN b.committed_amount_prim
                 ELSE NULL end) committed_amt_pg_prior_mtd,
        SUM(CASE WHEN bitand(cal.record_type_id, 128) = 128
                  AND cal.report_date = l_pq_this_date
                 THEN b.committed_amount_prim
                 ELSE NULL end) committed_amt_pg_prior_qtd,
        SUM(CASE WHEN bitand(cal.record_type_id, 256) = 256
                  AND cal.report_date = l_ly_this_date
                 THEN b.committed_amount_prim
                 ELSE NULL end) committed_amt_pg_prior_ytd,
        SUM(CASE WHEN bitand(cal.record_type_id, 64) = 64
                  AND cal.report_date = l_ly_this_date
                 THEN b.committed_amount_prim
                 ELSE NULL end) committed_amt_pg_last_year_mtd,
        SUM(CASE WHEN bitand(cal.record_type_id, 128) = 128
                  AND cal.report_date = l_ly_this_date
                 THEN b.committed_amount_prim
                 ELSE NULL end) committed_amt_pg_last_year_qtd,

        SUM(CASE WHEN bitand(cal.record_type_id, 64) = 64
                  AND cal.report_date = l_this_date_gov -- l_this_date
                 THEN b.obligated_amount_prim
                 ELSE NULL end) obligated_amt_pg_cur_mtd,
        SUM(CASE WHEN bitand(cal.record_type_id, 128) = 128
                  AND cal.report_date = l_this_date_gov -- l_this_date
                 THEN b.obligated_amount_prim
                 ELSE NULL end) obligated_amt_pg_cur_qtd,
        SUM(CASE WHEN bitand(cal.record_type_id, 256) = 256
                  AND cal.report_date = l_this_date_gov -- l_this_date
                 THEN b.obligated_amount_prim
                 ELSE NULL end) obligated_amt_pg_cur_ytd,
        SUM(CASE WHEN bitand(cal.record_type_id, 64) = 64
                  AND cal.report_date = l_pp_this_date
                 THEN b.obligated_amount_prim
                 ELSE NULL end) obligated_amt_pg_prior_mtd,
        SUM(CASE WHEN bitand(cal.record_type_id, 128) = 128
                  AND cal.report_date = l_pq_this_date
                 THEN b.obligated_amount_prim
                 ELSE NULL end) obligated_amt_pg_prior_qtd,
        SUM(CASE WHEN bitand(cal.record_type_id, 256) = 256
                  AND cal.report_date = l_ly_this_date
                 THEN b.obligated_amount_prim
                 ELSE NULL end) obligated_amt_pg_prior_ytd,
        SUM(CASE WHEN bitand(cal.record_type_id, 64) = 64
                  AND cal.report_date = l_ly_this_date
                 THEN b.obligated_amount_prim
                 ELSE NULL end) obligated_amt_pg_last_year_mtd,
        SUM(CASE WHEN bitand(cal.record_type_id, 128) = 128
                  AND cal.report_date = l_ly_this_date
                 THEN b.obligated_amount_prim
                 ELSE NULL end) obligated_amt_pg_last_year_qtd,

        SUM(CASE WHEN bitand(cal.record_type_id, 64) = 64
                  AND cal.report_date = l_this_date_gov -- l_this_date
                 THEN b.other_amount_prim
                 ELSE NULL end) other_amt_pg_cur_mtd,
        SUM(CASE WHEN bitand(cal.record_type_id, 128) = 128
                  AND cal.report_date = l_this_date_gov -- l_this_date
                 THEN b.other_amount_prim
                 ELSE NULL end) other_amt_pg_cur_qtd,
        SUM(CASE WHEN bitand(cal.record_type_id, 256) = 256
                  AND cal.report_date = l_this_date_gov -- l_this_date
                 THEN b.other_amount_prim
                 ELSE NULL end) other_amt_pg_cur_ytd,
        SUM(CASE WHEN bitand(cal.record_type_id, 64) = 64
                  AND cal.report_date = l_pp_this_date
                 THEN b.other_amount_prim
                 ELSE NULL end) other_amt_pg_prior_mtd,
        SUM(CASE WHEN bitand(cal.record_type_id, 128) = 128
                  AND cal.report_date = l_pq_this_date
                 THEN b.other_amount_prim
                 ELSE NULL end) other_amt_pg_prior_qtd,
        SUM(CASE WHEN bitand(cal.record_type_id, 256) = 256
                  AND cal.report_date = l_ly_this_date
                 THEN b.other_amount_prim
                 ELSE NULL end) other_amt_pg_prior_ytd,
        SUM(CASE WHEN bitand(cal.record_type_id, 64) = 64
                  AND cal.report_date = l_ly_this_date
                 THEN b.other_amount_prim
                 ELSE NULL end) other_amt_pg_last_year_mtd,
        SUM(CASE WHEN bitand(cal.record_type_id, 128) = 128
                  AND cal.report_date = l_ly_this_date
                 THEN b.other_amount_prim
                 ELSE NULL end) other_amt_pg_last_year_qtd,

        SUM(CASE WHEN bitand(cal.record_type_id, 64) = 64
                  AND cal.report_date = l_this_date
                 THEN b.baseline_amount_prim
                 ELSE NULL end) baseline_amt_pg_cur_mtd,
        SUM(CASE WHEN bitand(cal.record_type_id, 128) = 128
                  AND cal.report_date = l_this_date
                 THEN b.baseline_amount_prim
                 ELSE NULL end) baseline_amt_pg_cur_qtd,
        SUM(CASE WHEN bitand(cal.record_type_id, 256) = 256
                  AND cal.report_date = l_this_date
                 THEN b.baseline_amount_prim
                 ELSE NULL end) baseline_amt_pg_cur_ytd,
        SUM(CASE WHEN bitand(cal.record_type_id, 64) = 64
                  AND cal.report_date = l_pp_this_date
                 THEN b.baseline_amount_prim
                 ELSE NULL end) baseline_amt_pg_prior_mtd,
        SUM(CASE WHEN bitand(cal.record_type_id, 128) = 128
                  AND cal.report_date = l_pq_this_date
                 THEN b.baseline_amount_prim
                 ELSE NULL end) baseline_amt_pg_prior_qtd,
        SUM(CASE WHEN bitand(cal.record_type_id, 256) = 256
                  AND cal.report_date = l_ly_this_date
                 THEN b.baseline_amount_prim
                 ELSE NULL end) baseline_amt_pg_prior_ytd,
        SUM(CASE WHEN bitand(cal.record_type_id, 64) = 64
                  AND cal.report_date = l_ly_this_date
                 THEN b.baseline_amount_prim
                 ELSE NULL end) baseline_amt_pg_last_year_mtd,
        SUM(CASE WHEN bitand(cal.record_type_id, 128) = 128
                  AND cal.report_date = l_ly_this_date
                 THEN b.baseline_amount_prim
                 ELSE NULL end) baseline_amt_pg_last_year_qtd,

	 b.POSTED_DATE,

	 g_fii_sysdate,
       g_fii_user_id,
       g_fii_sysdate,
       g_fii_user_id,
       g_fii_login_id

  FROM   fii_time_structures cal,
         fii_gl_base_map_mv  b
  WHERE cal.report_date in (l_this_date, l_pp_this_date,
                            l_pq_this_date, l_ly_this_date, l_this_date_gov)
    AND cal.time_id        = b.time_id
    AND cal.period_type_id = b.period_type_id
    AND (bitand(cal.record_type_id, 64)  = 64   OR
         bitand(cal.record_type_id, 128) = 128  OR
         bitand(cal.record_type_id, 256) = 256  OR
         bitand(cal.record_type_id, 4)   = 4    OR
         bitand(cal.record_type_id, 8)   = 8    OR
         bitand(cal.record_type_id, 16)  = 16)
  GROUP BY b.company_dim_id, b.cost_center_dim_id, b.fin_category_id,
           b.user_dim1_id, b.user_dim2_id, ledger_id, b.posted_date;

  IF g_debug_flag = 'Y' THEN
    FII_UTIL.stop_timer();
    FII_UTIL.Write_Log ('FII_GL_SNAP_F has been populated successfully');
    FII_UTIL.Write_Log ('Inserted ' || SQL%ROWCOUNT || ' rows');
    FII_UTIL.print_timer();
  END IF;

  g_phase := 'Gather table stats for FII_GL_SNAP_F';
  fnd_stats.gather_table_stats (ownname=>g_schema_name,
                                tabname=>'FII_GL_SNAP_F');

  g_phase := 'Commit the change';
  commit;

  IF g_debug_flag = 'Y' THEN
    FII_UTIL.Write_Log ('< Leaving REFRESH_GL_SNAP_F');
    FII_UTIL.Write_Log (' ');
  END IF;

 EXCEPTION
  -- Bug 4174859. Handled no data found exception.
  WHEN no_data_found THEN
    FII_MESSAGE.write_log(
			msg_name	=> 'FII_PERIOD_NOT_OPEN',
			token_num	=> 0);
    raise;

  WHEN OTHERS THEN
    FII_UTIL.Write_Log ('Other error in REFRESH_GL_SNAP_F ');
    FII_UTIL.Write_Log ( 'G_PHASE: ' || G_PHASE);
    FII_UTIL.Write_Log ('-->'|| sqlcode ||':'|| substr(sqlerrm,1,180));
    rollback;
    raise;

 END REFRESH_GL_SNAP_F;


----------------------------------------------------
-- PROCEDURE REFRESH_GL_SNAP_SUM_F  (private)
--
-- This procedure will (fully) refresh table FII_GL_SNAP_SUM_F
-- FROM FII_GL_SNAP_F.
-- It aggregates along Financial Category, Company, Cost Center.
-- AND User Defined 1 dimensions to the upper portions.
----------------------------------------------------
 PROCEDURE REFRESH_GL_SNAP_SUM_F IS

 BEGIN

  g_phase := 'Entering REFRESH_GL_SNAP_SUM_F';
  IF g_debug_flag = 'Y' THEN
    FII_UTIL.Write_Log ('> Entering REFRESH_GL_SNAP_SUM_F');
    FII_UTIL.start_timer();
  END IF;

  g_phase := 'Truncate table FII_GL_SNAP_SUM_F';
  FII_UTIL.truncate_table ('FII_GL_SNAP_SUM_F', 'FII', g_retcode);

  g_phase := 'Starting to populate table FII_GL_SNAP_SUM_F';
  IF g_debug_flag = 'Y' THEN
     FII_UTIL.Write_Log ('>> Starting to populate table FII_GL_SNAP_SUM_F');
  END IF;

 insert /*+ append */ INTO FII_GL_SNAP_SUM_F
  (
    COST_CENTER_DIM_ID,
    PARENT_COST_CENTER_DIM_ID,
    COMPANY_DIM_ID,
    PARENT_COMPANY_DIM_ID,
    FIN_CATEGORY_ID,
    PARENT_FIN_CATEGORY_ID,
    USER_DIM1_ID,
    PARENT_USER_DIM1_ID,
    USER_DIM2_ID,
    LEDGER_ID,

    ACTUAL_B_CUR_MTD,
    ACTUAL_B_CUR_QTD,
    ACTUAL_B_CUR_YTD,
    ACTUAL_B_PRIOR_MTD,
    ACTUAL_B_PRIOR_QTD,
    ACTUAL_B_PRIOR_YTD,
    ACTUAL_B_LAST_YEAR_MTD,
    ACTUAL_B_LAST_YEAR_QTD,

    ACTUAL_PG_CUR_MTD,
    ACTUAL_PG_CUR_QTD,
    ACTUAL_PG_CUR_YTD,
    ACTUAL_PG_PRIOR_MTD,
    ACTUAL_PG_PRIOR_QTD,
    ACTUAL_PG_PRIOR_YTD,
    ACTUAL_PG_LAST_YEAR_MTD,
    ACTUAL_PG_LAST_YEAR_QTD,

    ACTUAL_SG_CUR_MTD,
    ACTUAL_SG_CUR_QTD,
    ACTUAL_SG_CUR_YTD,
    ACTUAL_SG_PRIOR_MTD,
    ACTUAL_SG_PRIOR_QTD,
    ACTUAL_SG_PRIOR_YTD,
    ACTUAL_SG_LAST_YEAR_MTD,
    ACTUAL_SG_LAST_YEAR_QTD,


    BUDGET_PG_CUR_MTD,
    BUDGET_PG_CUR_QTD,
    BUDGET_PG_CUR_YTD,
    BUDGET_PG_PRIOR_MTD,
    BUDGET_PG_PRIOR_QTD,
    BUDGET_PG_PRIOR_YTD,
    BUDGET_PG_LAST_YEAR_MTD,
    BUDGET_PG_LAST_YEAR_QTD,

    BUDGET_SG_CUR_MTD,
    BUDGET_SG_CUR_QTD,
    BUDGET_SG_CUR_YTD,
    BUDGET_SG_PRIOR_MTD,
    BUDGET_SG_PRIOR_QTD,
    BUDGET_SG_PRIOR_YTD,
    BUDGET_SG_LAST_YEAR_MTD,
    BUDGET_SG_LAST_YEAR_QTD,


    FORECAST_PG_CUR_MTD,
    FORECAST_PG_CUR_QTD,
    FORECAST_PG_CUR_YTD,
    FORECAST_PG_PRIOR_MTD,
    FORECAST_PG_PRIOR_QTD,
    FORECAST_PG_PRIOR_YTD,
    FORECAST_PG_LAST_YEAR_MTD,
    FORECAST_PG_LAST_YEAR_QTD,

    FORECAST_SG_CUR_MTD,
    FORECAST_SG_CUR_QTD,
    FORECAST_SG_CUR_YTD,
    FORECAST_SG_PRIOR_MTD,
    FORECAST_SG_PRIOR_QTD,
    FORECAST_SG_PRIOR_YTD,
    FORECAST_SG_LAST_YEAR_MTD,
    FORECAST_SG_LAST_YEAR_QTD,


       COMMITTED_AMT_PG_CUR_MTD 	  ,
       COMMITTED_AMT_PG_CUR_QTD 	  ,
       COMMITTED_AMT_PG_CUR_YTD 	  ,
       COMMITTED_AMT_PG_PRIOR_MTD         ,
       COMMITTED_AMT_PG_PRIOR_QTD 	  ,
       COMMITTED_AMT_PG_PRIOR_YTD 	  ,
       COMMITTED_AMT_PG_LAST_YEAR_MTD  	  ,
       COMMITTED_AMT_PG_LAST_YEAR_QTD     ,
       OBLIGATED_AMT_PG_CUR_MTD 	  ,
       OBLIGATED_AMT_PG_CUR_QTD 	  ,
       OBLIGATED_AMT_PG_CUR_YTD           ,
       OBLIGATED_AMT_PG_PRIOR_MTD         ,
       OBLIGATED_AMT_PG_PRIOR_QTD 	  ,
       OBLIGATED_AMT_PG_PRIOR_YTD 	  ,
       OBLIGATED_AMT_PG_LAST_YEAR_MTD     ,
       OBLIGATED_AMT_PG_LAST_YEAR_QTD     ,
       OTHER_AMT_PG_CUR_MTD 		  ,
       OTHER_AMT_PG_CUR_QTD 		  ,
       OTHER_AMT_PG_CUR_YTD 		  ,
       OTHER_AMT_PG_PRIOR_MTD             ,
       OTHER_AMT_PG_PRIOR_QTD 	          ,
       OTHER_AMT_PG_PRIOR_YTD 	          ,
       OTHER_AMT_PG_LAST_YEAR_MTD   	  ,
       OTHER_AMT_PG_LAST_YEAR_QTD         ,
       BASELINE_AMT_PG_CUR_MTD 	          ,
       BASELINE_AMT_PG_CUR_QTD            ,
       BASELINE_AMT_PG_CUR_YTD            ,
       BASELINE_AMT_PG_PRIOR_MTD          ,
       BASELINE_AMT_PG_PRIOR_QTD          ,
       BASELINE_AMT_PG_PRIOR_YTD          ,
       BASELINE_AMT_PG_LAST_YEAR_MTD      ,
       BASELINE_AMT_PG_LAST_YEAR_QTD      ,

   POSTED_DATE,

   LAST_UPDATE_DATE,
   LAST_UPDATED_BY,
   CREATION_DATE,
   CREATED_BY,
   LAST_UPDATE_LOGIN)

 SELECT
         cc.NEXT_LEVEL_CC_ID          COST_CENTER_DIM_ID,
         cc.PARENT_CC_ID              PARENT_COST_CENTER_DIM_ID,
         com.NEXT_LEVEL_COMPANY_ID    COMPANY_DIM_ID,
         com.PARENT_COMPANY_ID        PARENT_COMPANY_DIM_ID,
         fin.NEXT_LEVEL_FIN_CAT_ID    FIN_CATEGORY_ID,
         fin.PARENT_FIN_CAT_ID        PARENT_FIN_CATEGORY_ID,
         ud1.NEXT_LEVEL_VALUE_ID      USER_DIM1_ID,
         ud1.PARENT_VALUE_ID          PARENT_USER_DIM1_ID,

        b.user_dim2_id,
        b.ledger_id,

        SUM(actual_b_cur_mtd),
        SUM(actual_b_cur_qtd),
        SUM(actual_b_cur_ytd),
        SUM(actual_b_prior_mtd),
        SUM(actual_b_prior_qtd),
        SUM(actual_b_prior_ytd),
        SUM(actual_b_last_year_mtd),
        SUM(actual_b_last_year_qtd),

        SUM(actual_pg_cur_mtd),
        SUM(actual_pg_cur_qtd),
        SUM(actual_pg_cur_ytd),
        SUM(actual_pg_prior_mtd),
        SUM(actual_pg_prior_qtd),
        SUM(actual_pg_prior_ytd),
        SUM(actual_pg_last_year_mtd),
        SUM(actual_pg_last_year_qtd),

        SUM(actual_sg_cur_mtd),
        SUM(actual_sg_cur_qtd),
        SUM(actual_sg_cur_ytd),
        SUM(actual_sg_prior_mtd),
        SUM(actual_sg_prior_qtd),
        SUM(actual_sg_prior_ytd),
        SUM(actual_sg_last_year_mtd),
        SUM(actual_sg_last_year_qtd),


        SUM(budget_pg_cur_mtd),
        SUM(budget_pg_cur_qtd),
        SUM(budget_pg_cur_ytd),
        SUM(budget_pg_prior_mtd),
        SUM(budget_pg_prior_qtd),
        SUM(budget_pg_prior_ytd),
        SUM(budget_pg_last_year_mtd),
        SUM(budget_pg_last_year_qtd),

        SUM(budget_sg_cur_mtd),
        SUM(budget_sg_cur_qtd),
        SUM(budget_sg_cur_ytd),
        SUM(budget_sg_prior_mtd),
        SUM(budget_sg_prior_qtd),
        SUM(budget_sg_prior_ytd),
        SUM(budget_sg_last_year_mtd),
        SUM(budget_sg_last_year_qtd),


        SUM(forecast_pg_cur_mtd),
        SUM(forecast_pg_cur_qtd),
        SUM(forecast_pg_cur_ytd),
        SUM(forecast_pg_prior_mtd),
        SUM(forecast_pg_prior_qtd),
        SUM(forecast_pg_prior_ytd),
        SUM(forecast_pg_last_year_mtd),
        SUM(forecast_pg_last_year_qtd),

        SUM(forecast_sg_cur_mtd),
        SUM(forecast_sg_cur_qtd),
        SUM(forecast_sg_cur_ytd),
        SUM(forecast_sg_prior_mtd),
        SUM(forecast_sg_prior_qtd),
        SUM(forecast_sg_prior_ytd),
        SUM(forecast_sg_last_year_mtd),
        SUM(forecast_sg_last_year_qtd),


       SUM(committed_amt_pg_cur_mtd) 	  ,
       SUM(committed_amt_pg_cur_qtd) 	  ,
       SUM(committed_amt_pg_cur_ytd) 	  ,
       SUM(committed_amt_pg_prior_mtd)    ,
       SUM(committed_amt_pg_prior_qtd) 	  ,
       SUM(committed_amt_pg_prior_ytd) 	  ,
       SUM(committed_amt_pg_last_year_mtd),
       SUM(committed_amt_pg_last_year_qtd),
       SUM(obligated_amt_pg_cur_mtd) 	  ,
       SUM(obligated_amt_pg_cur_qtd) 	  ,
       SUM(obligated_amt_pg_cur_ytd)      ,
       SUM(obligated_amt_pg_prior_mtd)    ,
       SUM(obligated_amt_pg_prior_qtd) 	  ,
       SUM(obligated_amt_pg_prior_ytd) 	  ,
       SUM(obligated_amt_pg_last_year_mtd),
       SUM(obligated_amt_pg_last_year_qtd),
       SUM(other_amt_pg_cur_mtd) 	  ,
       SUM(other_amt_pg_cur_qtd) 	  ,
       SUM(other_amt_pg_cur_ytd) 	  ,
       SUM(other_amt_pg_prior_mtd)        ,
       SUM(other_amt_pg_prior_qtd)        ,
       SUM(other_amt_pg_prior_ytd)        ,
       SUM(other_amt_pg_last_year_mtd)    ,
       SUM(other_amt_pg_last_year_qtd)    ,
       SUM(baseline_amt_pg_cur_mtd) 	  ,
       SUM(baseline_amt_pg_cur_qtd) 	  ,
       SUM(baseline_amt_pg_cur_ytd) 	  ,
       SUM(baseline_amt_pg_prior_mtd)     ,
       SUM(baseline_amt_pg_prior_qtd)     ,
       SUM(baseline_amt_pg_prior_ytd)     ,
       SUM(baseline_amt_pg_last_year_mtd) ,
       SUM(baseline_amt_pg_last_year_qtd) ,

	 b.POSTED_DATE,

       g_fii_sysdate,
       g_fii_user_id,
       g_fii_sysdate,
       g_fii_user_id,
       g_fii_login_id

  FROM   fii_gl_snap_f            b,
         fii_fin_item_leaf_hiers  fin,
         fii_company_hierarchies  com,
         fii_cost_ctr_hierarchies cc,
         fii_udd1_hierarchies     ud1
  WHERE b.fin_category_id     = fin.child_fin_cat_id
  AND   fin.is_leaf_flag              = 'N'
  AND   fin.aggregate_next_level_flag = 'Y'
  AND   b.company_dim_id      = com.child_company_id
  AND   com.is_leaf_flag              = 'N'
  AND   com.aggregate_next_level_flag = 'Y'
  AND   b.cost_center_dim_id  = cc.child_cc_id
  AND   cc.is_leaf_flag              = 'N'
  AND   cc.aggregate_next_level_flag = 'Y'
  AND   b.user_dim1_id    = ud1.child_value_id
  AND   ud1.is_leaf_flag              = 'N'
  AND   ud1.aggregate_next_level_flag = 'Y'
  GROUP BY
        b.LEDGER_ID,
        fin.PARENT_FIN_CAT_ID,
        fin.NEXT_LEVEL_FIN_CAT_ID,
        com.PARENT_COMPANY_ID,
        com.NEXT_LEVEL_COMPANY_ID,
        cc.PARENT_CC_ID,
        cc.NEXT_LEVEL_CC_ID,
        ud1.PARENT_VALUE_ID,
        ud1.NEXT_LEVEL_VALUE_ID,
        b.USER_DIM2_ID,
	  b.posted_date;

  IF g_debug_flag = 'Y' THEN
    FII_UTIL.stop_timer();
    FII_UTIL.Write_Log ( 'FII_GL_SNAP_SUM_F has been populated successfully' );
    FII_UTIL.Write_Log ('Inserted ' || SQL%ROWCOUNT || ' rows');
    FII_UTIL.print_timer();
  END IF;

  g_phase := 'Gather table stats for FII_GL_SNAP_SUM_F';
  fnd_stats.gather_table_stats (ownname=>g_schema_name,
                                tabname=>'FII_GL_SNAP_SUM_F');

  g_phase := 'Commit the change';
  commit;

  IF g_debug_flag = 'Y' THEN
    FII_UTIL.Write_Log ('< Leaving REFRESH_GL_SNAP_SUM_F');
    FII_UTIL.Write_Log (' ');
  END IF;

 EXCEPTION

  WHEN OTHERS THEN
    FII_UTIL.Write_Log ('Other error in REFRESH_GL_SNAP_SUM_F ');
    FII_UTIL.Write_Log ( 'G_PHASE: ' || G_PHASE);
    FII_UTIL.Write_Log ('-->'|| sqlcode ||':'|| substr(sqlerrm,1,180));
    rollback;
    raise;

 END REFRESH_GL_SNAP_SUM_F;


----------------------------------------------------
-- PROCEDURE REFRESH_GL_LOCAL_SNAP_F  (private)
--
-- This procedure will (fully) refresh table FII_GL_LOCAL_SNAP_F
-- FROM FII_GL_JE_SUMMARY_B.
-- It populates data FROM GL base summary by changing rows INTO columns
----------------------------------------------------
 PROCEDURE REFRESH_GL_LOCAL_SNAP_F IS

  l_this_date DATE;
  l_year_id   NUMBER(15);

 BEGIN

  g_phase := 'Entering REFRESH_GL_LOCAL_SNAP_F';
  IF g_debug_flag = 'Y' THEN
    FII_UTIL.Write_Log ('> Entering REFRESH_GL_LOCAL_SNAP_F');
    FII_UTIL.start_timer();
  END IF;

  g_phase := 'Populate l_this_date FROM BIS_SYSTEM_DATE';

  --We use a un-shipped profile option FII_TEST_SYSDATE ("FII: Test Sysdate")
  --to reset different sysdate so that we can test for snapshot tables.
  if g_test_sysdate is NULL THEN
    SELECT trunc(CURRENT_DATE_ID) INTO l_this_date
      FROM BIS_SYSTEM_DATE;
  ELSE
    l_this_date := g_test_sysdate;
  end if;
  ---------------------------------------------------------

  --l_year_id := to_char(l_this_date, 'yyyy');
  --Bug 4283723: Get the ent year for l_this_date
  SELECT ent_year_id INTO l_year_id
	FROM fii_time_ent_year
    WHERE l_this_date between start_date AND end_date;

  IF g_debug_flag = 'Y' THEN
     FII_UTIL.Write_Log ('>> l_this_date = '|| l_this_date);
     FII_UTIL.Write_Log ('>> l_year_id = '  || l_year_id);
     FII_UTIL.Write_Log (' ');
  END IF;

  g_phase := 'Truncate table FII_GL_LOCAL_SNAP_F';
  FII_UTIL.truncate_table ('FII_GL_LOCAL_SNAP_F', 'FII', g_retcode);

  g_phase := 'Starting to populate table FII_GL_LOCAL_SNAP_F';
  IF g_debug_flag = 'Y' THEN
     FII_UTIL.Write_Log ('>> Starting to populate table FII_GL_LOCAL_SNAP_F');
  END IF;

  l_profile := NVL(FND_PROFILE.VALUE('INDUSTRY'),'C');

/*  The code to populate different types of budgets should ONLY run when industry profile is set to Government. Consequently,
if profile set to Government, we execute IF part otherwise, we execute ELSE part */

/* Different amount_type_codes used in the code -
A - Actuals
E - Encumbrances (Enc data is stored as sum of normal encumbrances and carryfwd encumbrances)
B - Actual budgets
BB - Baseline budgets*/


 IF l_profile = 'G' THEN

insert /*+ append */ INTO FII_GL_LOCAL_SNAP_F
  ( YEAR_ID,
    COST_CENTER_ID,
    COMPANY_ID,
    FIN_CATEGORY_ID,
    USER_DIM1_ID,
    USER_DIM2_ID,
    LEDGER_ID,
    FIN_CAT_TYPE_CODE,
    PRIM_G_MONTH1,
    PRIM_G_MONTH2,
    PRIM_G_MONTH3,
    PRIM_G_MONTH4,
    PRIM_G_MONTH5,
    PRIM_G_MONTH6,
    PRIM_G_MONTH7,
    PRIM_G_MONTH8,
    PRIM_G_MONTH9,
    PRIM_G_MONTH10,
    PRIM_G_MONTH11,
    PRIM_G_MONTH12,
    PRIM_G_MONTH13,
    PRIM_G_QTR1,
    PRIM_G_QTR2,
    PRIM_G_QTR3,
    PRIM_G_QTR4,
    PRIM_G_YEAR,
    PRIM_G_MTD,
    PRIM_G_QTD,
    PRIM_G_YTD,
    SEC_G_MONTH1,
    SEC_G_MONTH2,
    SEC_G_MONTH3,
    SEC_G_MONTH4,
    SEC_G_MONTH5,
    SEC_G_MONTH6,
    SEC_G_MONTH7,
    SEC_G_MONTH8,
    SEC_G_MONTH9,
    SEC_G_MONTH10,
    SEC_G_MONTH11,
    SEC_G_MONTH12,
    SEC_G_MONTH13,
    SEC_G_QTR1,
    SEC_G_QTR2,
    SEC_G_QTR3,
    SEC_G_QTR4,
    SEC_G_YEAR,
    SEC_G_MTD,
    SEC_G_QTD,
    SEC_G_YTD,

  LAST_UPDATE_DATE,
  LAST_UPDATED_BY,
  CREATION_DATE,
  CREATED_BY,
  LAST_UPDATE_LOGIN,
  AMOUNT_TYPE_CODE)

  WITH summary_full AS (SELECT company_id, cost_center_id, fin_category_id,
		    user_dim1_id, user_dim2_id, ledger_id,
		    prim_amount_g, sec_amount_g, obligated_amount_prim,
		    other_amount_prim, committed_amount_prim,
		    b.time_id, b.period_type_id,
		    p.ent_year_id, p.sequence period_seq, q.sequence qtr_seq

	     FROM   fii_gl_je_summary_b b,
	            fii_time_ent_qtr    q,
		    fii_time_ent_period p

	     WHERE  b.period_type_id = 32
		    AND   b.time_id    = p.ent_period_id
		    AND   p.ent_qtr_id = q.ent_qtr_id),

       summary_xtd AS (SELECT company_id, cost_center_id, fin_category_id,
		    user_dim1_id, user_dim2_id, ledger_id,
		    prim_amount_g, sec_amount_g, obligated_amount_prim,
		    other_amount_prim, committed_amount_prim,
		    b.time_id, b.period_type_id, cal.record_type_id
	     FROM   fii_gl_je_summary_b b,
	            fii_time_structures cal

	     WHERE cal.report_date = l_this_date
		   AND cal.time_id        = b.time_id
	           AND cal.period_type_id = b.period_type_id
		   AND (bitand(cal.record_type_id, 64)  = 64  OR
	           bitand(cal.record_type_id, 128) = 128 OR
		   bitand(cal.record_type_id, 256) = 256)),

	budget_full AS (SELECT company_id, cost_center_id, fin_category_id,
		    user_dim1_id, user_dim2_id, ledger_id,
		    prim_amount_g, sec_amount_g, baseline_amount_prim,
		    b.time_id, b.period_type_id,
		    p.ent_year_id, p.sequence period_seq, q.sequence qtr_seq

	     FROM   fii_budget_base b,
	            fii_time_ent_qtr    q,
		    fii_time_ent_period p

	     WHERE  b.plan_type_code = 'B'
		    AND   b.period_type_id = 32
		    AND   b.time_id    = p.ent_period_id
		    AND   p.ent_qtr_id = q.ent_qtr_id),

	 budget_xtd AS (SELECT company_id, cost_center_id, fin_category_id,
		    user_dim1_id, user_dim2_id, ledger_id,
		    prim_amount_g, sec_amount_g, baseline_amount_prim,
		    b.time_id, b.period_type_id, cal.record_type_id

	     FROM   fii_budget_base b,
	            fii_time_structures cal

	     WHERE  cal.report_date = l_this_date
		    AND b.plan_type_code = 'B'
		    AND b.period_type_id = cal.period_type_id
		    AND b.time_id = cal.time_id
		    AND (bitand(cal.record_type_id, 64)  = 64  OR
	            bitand(cal.record_type_id, 128) = 128 OR
		    bitand(cal.record_type_id, 256) = 256)),

	carryfwd_full AS (SELECT company_id, cost_center_id, fin_category_id,
		    user_dim1_id, user_dim2_id, ledger_id,
		    obligated_amount_prim,
		    other_amount_prim, committed_amount_prim,
		    b.time_id, b.period_type_id,
		    p.ent_year_id, p.sequence period_seq, q.sequence qtr_seq
	     FROM   fii_gl_enc_carryfwd_f b,
	            fii_time_ent_qtr    q,
		    fii_time_ent_period p
	     WHERE  b.period_type_id = 32
		    AND   b.time_id    = p.ent_period_id
		    AND   p.ent_qtr_id = q.ent_qtr_id),

       carryfwd_xtd AS (SELECT company_id, cost_center_id, fin_category_id,
		    user_dim1_id, user_dim2_id, ledger_id,
		    obligated_amount_prim,
		    other_amount_prim, committed_amount_prim,
		    b.time_id, b.period_type_id, cal.record_type_id
	     FROM   fii_gl_enc_carryfwd_f b,
	            fii_time_structures cal

	     WHERE cal.report_date = l_this_date
		   AND cal.time_id        = b.time_id
	           AND cal.period_type_id = b.period_type_id
		   AND (bitand(cal.record_type_id, 64)  = 64  OR
	           bitand(cal.record_type_id, 128) = 128 OR
		   bitand(cal.record_type_id, 256) = 256))


 SELECT /*+ index(a fii_fin_cat_type_assgns_u1) */
        f.ent_year_id year_id,
        f.cost_center_id,
        f.company_id,
        f.fin_category_id,
        f.user_dim1_id,
        f.user_dim2_id,
        f.ledger_id,
        a.fin_cat_type_code,
	DECODE(amount_type_code, 'A',SUM(DECODE(period_seq, 1, prim_amt_g)) * DECODE(a.fin_cat_type_code, 'R', 1, -1),
	       'E',SUM(DECODE(period_seq, 1, prim_amt_g)) * DECODE(a.fin_cat_type_code, 'R', 1, -1),
			      SUM(DECODE(period_seq, 1, prim_amt_g))) prim_g_month1,
        DECODE(amount_type_code, 'A',SUM(DECODE(period_seq, 2, prim_amt_g)) * DECODE(a.fin_cat_type_code, 'R', 1, -1),
                'E',SUM(DECODE(period_seq, 2, prim_amt_g)) * DECODE(a.fin_cat_type_code, 'R', 1, -1),
				      SUM(DECODE(period_seq, 2, prim_amt_g))) prim_g_month2,
	DECODE(amount_type_code, 'A',SUM(DECODE(period_seq, 3, prim_amt_g)) * DECODE(a.fin_cat_type_code, 'R', 1, -1),
	        'E',SUM(DECODE(period_seq, 3, prim_amt_g)) * DECODE(a.fin_cat_type_code, 'R', 1, -1),
			      SUM(DECODE(period_seq, 3, prim_amt_g))) prim_g_month3,
        DECODE(amount_type_code, 'A',SUM(DECODE(period_seq, 4, prim_amt_g)) * DECODE(a.fin_cat_type_code, 'R', 1, -1),
		 'E',SUM(DECODE(period_seq, 4, prim_amt_g)) * DECODE(a.fin_cat_type_code, 'R', 1, -1),
			      SUM(DECODE(period_seq, 4, prim_amt_g))) prim_g_month4,
        DECODE(amount_type_code, 'A',SUM(DECODE(period_seq, 5, prim_amt_g)) * DECODE(a.fin_cat_type_code, 'R', 1, -1),
		 'E',SUM(DECODE(period_seq, 5, prim_amt_g)) * DECODE(a.fin_cat_type_code, 'R', 1, -1),
			      SUM(DECODE(period_seq, 5, prim_amt_g))) prim_g_month5,
        DECODE(amount_type_code, 'A',SUM(DECODE(period_seq, 6, prim_amt_g)) * DECODE(a.fin_cat_type_code, 'R', 1, -1),
		 'E',SUM(DECODE(period_seq, 6, prim_amt_g)) * DECODE(a.fin_cat_type_code, 'R', 1, -1),
			      SUM(DECODE(period_seq, 6, prim_amt_g))) prim_g_month6,
        DECODE(amount_type_code, 'A',SUM(DECODE(period_seq, 7, prim_amt_g)) * DECODE(a.fin_cat_type_code, 'R', 1, -1),
		 'E',SUM(DECODE(period_seq, 7, prim_amt_g)) * DECODE(a.fin_cat_type_code, 'R', 1, -1),
			      SUM(DECODE(period_seq, 7, prim_amt_g))) prim_g_month7,
	DECODE(amount_type_code, 'A',SUM(DECODE(period_seq, 8, prim_amt_g)) * DECODE(a.fin_cat_type_code, 'R', 1, -1),
		 'E',SUM(DECODE(period_seq, 8, prim_amt_g)) * DECODE(a.fin_cat_type_code, 'R', 1, -1),
			      SUM(DECODE(period_seq, 8, prim_amt_g))) prim_g_month8,
	DECODE(amount_type_code, 'A',SUM(DECODE(period_seq, 9, prim_amt_g)) * DECODE(a.fin_cat_type_code, 'R', 1, -1),
		 'E',SUM(DECODE(period_seq, 9, prim_amt_g)) * DECODE(a.fin_cat_type_code, 'R', 1, -1),
			      SUM(DECODE(period_seq, 9, prim_amt_g))) prim_g_month9,
        DECODE(amount_type_code, 'A',SUM(DECODE(period_seq, 10, prim_amt_g)) * DECODE(a.fin_cat_type_code, 'R', 1, -1),
		 'E',SUM(DECODE(period_seq, 10, prim_amt_g)) * DECODE(a.fin_cat_type_code, 'R', 1, -1),
			      SUM(DECODE(period_seq, 10, prim_amt_g))) prim_g_month10,
	DECODE(amount_type_code, 'A',SUM(DECODE(period_seq, 11, prim_amt_g)) * DECODE(a.fin_cat_type_code, 'R', 1, -1),
		 'E',SUM(DECODE(period_seq, 11, prim_amt_g)) * DECODE(a.fin_cat_type_code, 'R', 1, -1),
			      SUM(DECODE(period_seq, 11, prim_amt_g))) prim_g_month11,
	DECODE(amount_type_code, 'A',SUM(DECODE(period_seq, 12, prim_amt_g)) * DECODE(a.fin_cat_type_code, 'R', 1, -1),
		 'E',SUM(DECODE(period_seq, 12, prim_amt_g)) * DECODE(a.fin_cat_type_code, 'R', 1, -1),
			      SUM(DECODE(period_seq, 12, prim_amt_g))) prim_g_month12,
	DECODE(amount_type_code, 'A',SUM(DECODE(period_seq, 13, prim_amt_g)) * DECODE(a.fin_cat_type_code, 'R', 1, -1),
		 'E',SUM(DECODE(period_seq, 13, prim_amt_g)) * DECODE(a.fin_cat_type_code, 'R', 1, -1),
			      SUM(DECODE(period_seq, 13, prim_amt_g))) prim_g_month13,
        DECODE(amount_type_code, 'A',SUM(DECODE(qtr_seq, 1, prim_amt_g)) * DECODE(a.fin_cat_type_code, 'R', 1, -1),
		 'E',SUM(DECODE(qtr_seq, 1, prim_amt_g)) * DECODE(a.fin_cat_type_code, 'R', 1, -1),
			      SUM(DECODE(qtr_seq, 1, prim_amt_g))) prim_g_qtr1,
	DECODE(amount_type_code, 'A',SUM(DECODE(qtr_seq, 2, prim_amt_g)) * DECODE(a.fin_cat_type_code, 'R', 1, -1),
		'E',SUM(DECODE(qtr_seq, 2, prim_amt_g)) * DECODE(a.fin_cat_type_code, 'R', 1, -1),
			      SUM(DECODE(qtr_seq, 2, prim_amt_g))) prim_g_qtr2,
	DECODE(amount_type_code, 'A',SUM(DECODE(qtr_seq, 3, prim_amt_g)) * DECODE(a.fin_cat_type_code, 'R', 1, -1),
		'E',SUM(DECODE(qtr_seq, 3, prim_amt_g)) * DECODE(a.fin_cat_type_code, 'R', 1, -1),
			      SUM(DECODE(qtr_seq, 3, prim_amt_g))) prim_g_qtr3,
	DECODE(amount_type_code, 'A',SUM(DECODE(qtr_seq, 4, prim_amt_g)) * DECODE(a.fin_cat_type_code, 'R', 1, -1),
		'E',SUM(DECODE(qtr_seq, 4, prim_amt_g)) * DECODE(a.fin_cat_type_code, 'R', 1, -1),
			      SUM(DECODE(qtr_seq, 4, prim_amt_g))) prim_g_qtr4,
	DECODE(amount_type_code, 'A',SUM(NVL(DECODE(qtr_seq, 1, prim_amt_g),0) +
				  NVL(DECODE(qtr_seq, 2, prim_amt_g),0) +
				  NVL(DECODE(qtr_seq, 3, prim_amt_g),0) +
				  NVL(DECODE(qtr_seq, 4, prim_amt_g),0)) * DECODE(a.fin_cat_type_code, 'R', 1, -1),
		     'E',SUM(NVL(DECODE(qtr_seq, 1, prim_amt_g),0) +
				  NVL(DECODE(qtr_seq, 2, prim_amt_g),0) +
				  NVL(DECODE(qtr_seq, 3, prim_amt_g),0) +
				  NVL(DECODE(qtr_seq, 4, prim_amt_g),0)) * DECODE(a.fin_cat_type_code, 'R', 1, -1),
			      SUM(NVL(DECODE(qtr_seq, 1, prim_amt_g),0) +
				  NVL(DECODE(qtr_seq, 2, prim_amt_g),0) +
				  NVL(DECODE(qtr_seq, 3, prim_amt_g),0) +
				  NVL(DECODE(qtr_seq, 4, prim_amt_g),0))) prim_g_year,

	DECODE(amount_type_code, 'A',SUM(mtd_prim_amt_g) * DECODE(a.fin_cat_type_code, 'R', 1, -1),
		     'E',SUM(mtd_prim_amt_g) * DECODE(a.fin_cat_type_code, 'R', 1, -1),
			      SUM(mtd_prim_amt_g)) prim_g_mtd,
	DECODE(amount_type_code, 'A',SUM(qtd_prim_amt_g) * DECODE(a.fin_cat_type_code, 'R', 1, -1),
		     'E',SUM(qtd_prim_amt_g) * DECODE(a.fin_cat_type_code, 'R', 1, -1),
			      SUM(qtd_prim_amt_g)) prim_g_qtd,
	DECODE(amount_type_code, 'A',SUM(ytd_prim_amt_g) * DECODE(a.fin_cat_type_code, 'R', 1, -1),
		     'E',SUM(ytd_prim_amt_g) * DECODE(a.fin_cat_type_code, 'R', 1, -1),
			      SUM(ytd_prim_amt_g)) prim_g_ytd,
        SUM(DECODE(period_seq, 1, sec_amt_g))
                   * DECODE(a.fin_cat_type_code, 'R', 1, -1)  sec_g_month1,
        SUM(DECODE(period_seq, 2, sec_amt_g))
                   * DECODE(a.fin_cat_type_code, 'R', 1, -1)  sec_g_month2,
        SUM(DECODE(period_seq, 3, sec_amt_g))
                   * DECODE(a.fin_cat_type_code, 'R', 1, -1)  sec_g_month3,
        SUM(DECODE(period_seq, 4, sec_amt_g))
                   * DECODE(a.fin_cat_type_code, 'R', 1, -1)  sec_g_month4,
        SUM(DECODE(period_seq, 5, sec_amt_g))
                   * DECODE(a.fin_cat_type_code, 'R', 1, -1)  sec_g_month5,
        SUM(DECODE(period_seq, 6, sec_amt_g))
                   * DECODE(a.fin_cat_type_code, 'R', 1, -1)  sec_g_month6,
        SUM(DECODE(period_seq, 7, sec_amt_g))
                   * DECODE(a.fin_cat_type_code, 'R', 1, -1)  sec_g_month7,
        SUM(DECODE(period_seq, 8, sec_amt_g))
                   * DECODE(a.fin_cat_type_code, 'R', 1, -1)  sec_g_month8,
        SUM(DECODE(period_seq, 9, sec_amt_g))
                   * DECODE(a.fin_cat_type_code, 'R', 1, -1)  sec_g_month9,
        SUM(DECODE(period_seq, 10, sec_amt_g))
                   * DECODE(a.fin_cat_type_code, 'R', 1, -1)  sec_g_month10,
        SUM(DECODE(period_seq, 11, sec_amt_g))
                   * DECODE(a.fin_cat_type_code, 'R', 1, -1)  sec_g_month11,
        SUM(DECODE(period_seq, 12, sec_amt_g))
                   * DECODE(a.fin_cat_type_code, 'R', 1, -1)  sec_g_month12,
        SUM(DECODE(period_seq, 13, sec_amt_g))
                   * DECODE(a.fin_cat_type_code, 'R', 1, -1)  sec_g_month13,
        SUM(DECODE(qtr_seq, 1, sec_amt_g))
                   * DECODE(a.fin_cat_type_code, 'R', 1, -1)  sec_g_qtr1,
        SUM(DECODE(qtr_seq, 2, sec_amt_g))
                   * DECODE(a.fin_cat_type_code, 'R', 1, -1)  sec_g_qtr2,
        SUM(DECODE(qtr_seq, 3, sec_amt_g))
                   * DECODE(a.fin_cat_type_code, 'R', 1, -1)  sec_g_qtr3,
        SUM(DECODE(qtr_seq, 4, sec_amt_g))
                   * DECODE(a.fin_cat_type_code, 'R', 1, -1)  sec_g_qtr4,
         SUM(NVL(DECODE(qtr_seq, 1, sec_amt_g),0) +
		  NVL(DECODE(qtr_seq, 2, sec_amt_g),0) +
		  NVL(DECODE(qtr_seq, 3, sec_amt_g),0) +
		  NVL(DECODE(qtr_seq, 4, sec_amt_g),0))
                   * DECODE(a.fin_cat_type_code, 'R', 1, -1)  sec_g_year,
        SUM(mtd_sec_amt_g)
                   * DECODE(a.fin_cat_type_code, 'R', 1, -1)  sec_g_mtd,
        SUM(qtd_sec_amt_g)
                   * DECODE(a.fin_cat_type_code, 'R', 1, -1)  sec_g_qtd,
        SUM(ytd_sec_amt_g)
                   * DECODE(a.fin_cat_type_code, 'R', 1, -1)  sec_g_ytd,

       g_fii_sysdate,
       g_fii_user_id,
       g_fii_sysdate,
       g_fii_user_id,
       g_fii_login_id,
       amount_type_code

 FROM
  (SELECT b.ent_year_id, b.qtr_seq,  b.period_seq,
          b.company_id, b.cost_center_id, b.fin_category_id,
          b.user_dim1_id, b.user_dim2_id, ledger_id,
          SUM(b.prim_amount_g) prim_amt_g,
          SUM(b.sec_amount_g) sec_amt_g,
           NULL mtd_prim_amt_g, NULL qtd_prim_amt_g, NULL ytd_prim_amt_g,
          NULL mtd_sec_amt_g,  NULL qtd_sec_amt_g,  NULL ytd_sec_amt_g,
	  'A' amount_type_code

   FROM  summary_full b

   GROUP BY b.ent_year_id, b.qtr_seq,  b.period_seq,
            b.company_id, b.cost_center_id, b.fin_category_id,
            b.user_dim1_id, b.user_dim2_id, ledger_id, 'A'

   UNION ALL

   SELECT l_year_id ent_year_id, 0 qtr_seq,  0 period_seq,
          b1.company_id, b1.cost_center_id, b1.fin_category_id,
          b1.user_dim1_id, b1.user_dim2_id, b1.ledger_id,
          NULL prim_amt_g, NULL sec_amt_g,
          SUM(CASE WHEN bitand(b1.record_type_id, 64) = 64
                   THEN b1.prim_amount_g
                   ELSE NULL end)  mtd_prim_amt_g,
          SUM(CASE WHEN bitand(b1.record_type_id, 128) = 128
                   THEN b1.prim_amount_g
                   ELSE NULL end) qtd_prim_amt_g,
          SUM(CASE WHEN bitand(b1.record_type_id, 256) = 256
                   THEN b1.prim_amount_g
                   ELSE NULL end) ytd_prim_amt_g,
          SUM(CASE WHEN bitand(b1.record_type_id, 64) =  64
                   THEN b1.sec_amount_g
                   ELSE NULL end)  mtd_sec_amt_g,
          SUM(CASE WHEN bitand(b1.record_type_id, 128) = 128
                   THEN b1.sec_amount_g
                   ELSE NULL end) qtd_sec_amt_g,
          SUM(CASE WHEN bitand(b1.record_type_id, 256) = 256
                   THEN b1.sec_amount_g
                   ELSE NULL end) ytd_sec_amt_g,
	  'A' amount_type_code

   FROM  summary_xtd b1

   GROUP BY b1.company_id, b1.cost_center_id, b1.fin_category_id,
            b1.user_dim1_id, b1.user_dim2_id, b1.ledger_id, 'A'

	 UNION ALL

	 SELECT b.ent_year_id, b.qtr_seq,  b.period_seq,
          b.company_id, b.cost_center_id, b.fin_category_id,
          b.user_dim1_id, b.user_dim2_id, ledger_id,
          NVL(SUM(b.obligated_amount_prim),0) +
	  NVL(SUM(b.committed_amount_prim),0) +
	  NVL(SUM(b.other_amount_prim),0) prim_amt_g,
          NULL sec_amt_g,
          NULL mtd_prim_amt_g, NULL qtd_prim_amt_g, NULL ytd_prim_amt_g,
          NULL mtd_sec_amt_g,  NULL qtd_sec_amt_g,  NULL ytd_sec_amt_g,
	  'E' amount_type_code

   FROM  summary_full b

   GROUP BY b.ent_year_id, b.qtr_seq,  b.period_seq,
            b.company_id, b.cost_center_id, b.fin_category_id,
            b.user_dim1_id, b.user_dim2_id, ledger_id, 'E'

   UNION ALL

   SELECT l_year_id ent_year_id, 0 qtr_seq,  0 period_seq,
          b1.company_id, b1.cost_center_id, b1.fin_category_id,
          b1.user_dim1_id, b1.user_dim2_id, b1.ledger_id,
          NULL prim_amt_g, NULL sec_amt_g,
          SUM(CASE WHEN bitand(b1.record_type_id, 64) = 64
                   THEN  NVL(b1.obligated_amount_prim,0) +
			 NVL(b1.committed_amount_prim,0) +
			 NVL(b1.other_amount_prim,0)
                   ELSE NULL end)  mtd_prim_amt_g,
          SUM(CASE WHEN bitand(b1.record_type_id, 128) = 128
                   THEN NVL(b1.obligated_amount_prim,0) +
			 NVL(b1.committed_amount_prim,0) +
			 NVL(b1.other_amount_prim,0)
                   ELSE NULL end) qtd_prim_amt_g,
          SUM(CASE WHEN bitand(b1.record_type_id, 256) = 256
                   THEN NVL(b1.obligated_amount_prim,0) +
			 NVL(b1.committed_amount_prim,0) +
			 NVL(b1.other_amount_prim,0)
                   ELSE NULL end) ytd_prim_amt_g,
          NULL  mtd_sec_amt_g,
          NULL qtd_sec_amt_g,
          NULL ytd_sec_amt_g,
  	  'E' amount_type_code

   FROM  summary_xtd b1

   GROUP BY b1.company_id, b1.cost_center_id, b1.fin_category_id,
            b1.user_dim1_id, b1.user_dim2_id, b1.ledger_id, 'E'


   UNION ALL

	 SELECT b.ent_year_id, b.qtr_seq,  b.period_seq,
          b.company_id, b.cost_center_id, b.fin_category_id,
          b.user_dim1_id, b.user_dim2_id, ledger_id,
          NVL(SUM(b.obligated_amount_prim),0) +
	  NVL(SUM(b.committed_amount_prim),0) +
	  NVL(SUM(b.other_amount_prim),0) prim_amt_g,
          NULL sec_amt_g,
          NULL mtd_prim_amt_g, NULL qtd_prim_amt_g, NULL ytd_prim_amt_g,
          NULL mtd_sec_amt_g,  NULL qtd_sec_amt_g,  NULL ytd_sec_amt_g,
	  'E' amount_type_code

   FROM  carryfwd_full b

   GROUP BY b.ent_year_id, b.qtr_seq,  b.period_seq,
            b.company_id, b.cost_center_id, b.fin_category_id,
            b.user_dim1_id, b.user_dim2_id, ledger_id, 'E'

   UNION ALL

   SELECT l_year_id ent_year_id, 0 qtr_seq,  0 period_seq,
          b1.company_id, b1.cost_center_id, b1.fin_category_id,
          b1.user_dim1_id, b1.user_dim2_id, b1.ledger_id,
          NULL prim_amt_g, NULL sec_amt_g,
          SUM(CASE WHEN bitand(b1.record_type_id, 64) = 64
                   THEN  NVL(b1.obligated_amount_prim,0) +
			 NVL(b1.committed_amount_prim,0) +
			 NVL(b1.other_amount_prim,0)
                   ELSE NULL end)  mtd_prim_amt_g,
          SUM(CASE WHEN bitand(b1.record_type_id, 128) = 128
                   THEN NVL(b1.obligated_amount_prim,0) +
			 NVL(b1.committed_amount_prim,0) +
			 NVL(b1.other_amount_prim,0)
                   ELSE NULL end) qtd_prim_amt_g,
          SUM(CASE WHEN bitand(b1.record_type_id, 256) = 256
                   THEN NVL(b1.obligated_amount_prim,0) +
			 NVL(b1.committed_amount_prim,0) +
			 NVL(b1.other_amount_prim,0)
                   ELSE NULL end) ytd_prim_amt_g,
          NULL  mtd_sec_amt_g,
          NULL qtd_sec_amt_g,
          NULL ytd_sec_amt_g,
  	  'E' amount_type_code

   FROM  carryfwd_xtd b1

   GROUP BY b1.company_id, b1.cost_center_id, b1.fin_category_id,
            b1.user_dim1_id, b1.user_dim2_id, b1.ledger_id, 'E'

	    UNION ALL

	  SELECT c.ent_year_id, c.qtr_seq,  c.period_seq,
          c.company_id, c.cost_center_id, c.fin_category_id,
          c.user_dim1_id, c.user_dim2_id, c.ledger_id ledger_id,
          SUM(c.prim_amount_g) prim_amt_g,
          NULL sec_amt_g,
          NULL mtd_prim_amt_g, NULL qtd_prim_amt_g, NULL ytd_prim_amt_g,
          NULL mtd_sec_amt_g,  NULL qtd_sec_amt_g,  NULL ytd_sec_amt_g,
	  'B' amount_type_code


   FROM  budget_full c

   GROUP BY c.ent_year_id, c.qtr_seq, c.period_seq,
            c.company_id, c.cost_center_id, c.fin_category_id,
          c.user_dim1_id, c.user_dim2_id, c.ledger_id,'B'

   UNION ALL

   SELECT l_year_id ent_year_id, 0 qtr_seq,  0 period_seq,
          c1.company_id, c1.cost_center_id, c1.fin_category_id,
          c1.user_dim1_id, c1.user_dim2_id, c1.ledger_id ledger_id,
          NULL prim_amt_g, NULL sec_amt_g,
          SUM(CASE WHEN bitand(c1.record_type_id, 64) = 64
                   THEN c1.prim_amount_g
                   ELSE NULL end)  mtd_prim_amt_g,
          SUM(CASE WHEN bitand(c1.record_type_id, 128) = 128
                   THEN c1.prim_amount_g
                   ELSE NULL end) qtd_prim_amt_g,
          SUM(CASE WHEN bitand(c1.record_type_id, 256) = 256
                   THEN c1.prim_amount_g
                   ELSE NULL end) ytd_prim_amt_g,
          NULL  mtd_sec_amt_g,
          NULL  qtd_sec_amt_g,
          NULL  ytd_sec_amt_g,
	  'B' amount_type_code

   FROM  budget_xtd c1

   GROUP BY c1.company_id, c1.cost_center_id, c1.fin_category_id,
          c1.user_dim1_id, c1.user_dim2_id, c1.ledger_id, 'B'

	    UNION ALL

	  SELECT c.ent_year_id, c.qtr_seq, c.period_seq,
          c.company_id, c.cost_center_id, c.fin_category_id,
          c.user_dim1_id, c.user_dim2_id, c.ledger_id ledger_id,
          SUM(c.baseline_amount_prim) prim_amt_g,
          NULL sec_amt_g,
          NULL mtd_prim_amt_g, NULL qtd_prim_amt_g, NULL ytd_prim_amt_g,
          NULL mtd_sec_amt_g,  NULL qtd_sec_amt_g,  NULL ytd_sec_amt_g,
	  'BB' amount_type_code


   FROM  budget_full c

   GROUP BY c.ent_year_id, c.qtr_seq, c.period_seq,
            c.company_id, c.cost_center_id, c.fin_category_id,
          c.user_dim1_id, c.user_dim2_id, c.ledger_id, 'BB'

   UNION ALL

   SELECT l_year_id ent_year_id, 0 qtr_seq,  0 period_seq,
          c1.company_id, c1.cost_center_id, c1.fin_category_id,
          c1.user_dim1_id, c1.user_dim2_id, c1.ledger_id ledger_id,
          NULL prim_amt_g, NULL sec_amt_g,
          SUM(CASE WHEN bitand(c1.record_type_id, 64) = 64
                   THEN c1.baseline_amount_prim
                   ELSE NULL end)  mtd_prim_amt_g,
          SUM(CASE WHEN bitand(c1.record_type_id, 128) = 128
                   THEN c1.baseline_amount_prim
                   ELSE NULL end) qtd_prim_amt_g,
          SUM(CASE WHEN bitand(c1.record_type_id, 256) = 256
                   THEN c1.baseline_amount_prim
                   ELSE NULL end) ytd_prim_amt_g,
          NULL  mtd_sec_amt_g,
          NULL  qtd_sec_amt_g,
          NULL  ytd_sec_amt_g,
	  'BB' amount_type_code

   FROM  budget_xtd c1

   GROUP BY c1.company_id, c1.cost_center_id, c1.fin_category_id,
          c1.user_dim1_id, c1.user_dim2_id, c1.ledger_id, 'BB') f,

	fii_fin_cat_type_assgns  a,
	fii_com_cc_dim_maps m,
	fii_fin_cat_leaf_maps c,
	fii_udd1_mappings ud1,
	fii_udd2_mappings ud2

 WHERE f.fin_category_id = a.fin_category_id
   AND a.fin_cat_type_code in ('R', 'OE', 'TE', 'PE', 'CGS')
   AND f.user_dim1_id = ud1.child_user_dim1_id
   AND f.user_dim2_id = ud2.child_user_dim2_id
   AND f.company_id = m.child_company_id
   AND f.cost_center_id = m.child_cost_center_id
   AND f.fin_category_id = c.child_fin_cat_id

 GROUP BY f.ent_year_id, f.company_id,
          f.cost_center_id, f.fin_category_id,
          f.user_dim1_id,  f.user_dim2_id,
          f.ledger_id, a.fin_cat_type_code,amount_type_code;

ELSE

insert /*+ append */ INTO FII_GL_LOCAL_SNAP_F
  ( YEAR_ID,
    COST_CENTER_ID,
    COMPANY_ID,
    FIN_CATEGORY_ID,
    USER_DIM1_ID,
    USER_DIM2_ID,
    LEDGER_ID,
    FIN_CAT_TYPE_CODE,
    PRIM_G_MONTH1,
    PRIM_G_MONTH2,
    PRIM_G_MONTH3,
    PRIM_G_MONTH4,
    PRIM_G_MONTH5,
    PRIM_G_MONTH6,
    PRIM_G_MONTH7,
    PRIM_G_MONTH8,
    PRIM_G_MONTH9,
    PRIM_G_MONTH10,
    PRIM_G_MONTH11,
    PRIM_G_MONTH12,
    PRIM_G_MONTH13,
    PRIM_G_QTR1,
    PRIM_G_QTR2,
    PRIM_G_QTR3,
    PRIM_G_QTR4,
    PRIM_G_YEAR,
    PRIM_G_MTD,
    PRIM_G_QTD,
    PRIM_G_YTD,
    SEC_G_MONTH1,
    SEC_G_MONTH2,
    SEC_G_MONTH3,
    SEC_G_MONTH4,
    SEC_G_MONTH5,
    SEC_G_MONTH6,
    SEC_G_MONTH7,
    SEC_G_MONTH8,
    SEC_G_MONTH9,
    SEC_G_MONTH10,
    SEC_G_MONTH11,
    SEC_G_MONTH12,
    SEC_G_MONTH13,
    SEC_G_QTR1,
    SEC_G_QTR2,
    SEC_G_QTR3,
    SEC_G_QTR4,
    SEC_G_YEAR,
    SEC_G_MTD,
    SEC_G_QTD,
    SEC_G_YTD,

  LAST_UPDATE_DATE,
  LAST_UPDATED_BY,
  CREATION_DATE,
  CREATED_BY,
  LAST_UPDATE_LOGIN,
  AMOUNT_TYPE_CODE)

  WITH summary_full AS (SELECT company_id, cost_center_id, fin_category_id,
		    user_dim1_id, user_dim2_id, ledger_id,
		    prim_amount_g, sec_amount_g,
		    b.time_id, b.period_type_id,
		    p.ent_year_id, p.sequence period_seq, q.sequence qtr_seq

	     FROM   fii_gl_je_summary_b b,
	            fii_time_ent_qtr    q,
		    fii_time_ent_period p

	     WHERE  b.period_type_id = 32
		    AND   b.time_id    = p.ent_period_id
		    AND   p.ent_qtr_id = q.ent_qtr_id),

       summary_xtd AS (SELECT company_id, cost_center_id, fin_category_id,
		    user_dim1_id, user_dim2_id, ledger_id,
		    prim_amount_g, sec_amount_g,
		    b.time_id, b.period_type_id, cal.record_type_id

	     FROM   fii_gl_je_summary_b b,
	            fii_time_structures cal

	     WHERE cal.report_date = l_this_date
		   AND cal.time_id = b.time_id
	           AND cal.period_type_id = b.period_type_id
		   AND (bitand(cal.record_type_id, 64)  = 64  OR
	           bitand(cal.record_type_id, 128) = 128 OR
		   bitand(cal.record_type_id, 256) = 256))
 SELECT
        f.ent_year_id year_id,
        f.cost_center_id,
        f.company_id,
        f.fin_category_id,
        f.user_dim1_id,
        f.user_dim2_id,
        f.ledger_id,
        a.fin_cat_type_code,
	SUM(DECODE(period_seq, 1, prim_amt_g))
                   * DECODE(a.fin_cat_type_code, 'R', 1, -1)  prim_g_month1,
        SUM(DECODE(period_seq, 2, prim_amt_g))
                   * DECODE(a.fin_cat_type_code, 'R', 1, -1)  prim_g_month2,
        SUM(DECODE(period_seq, 3, prim_amt_g))
                   * DECODE(a.fin_cat_type_code, 'R', 1, -1)  prim_g_month3,
        SUM(DECODE(period_seq, 4, prim_amt_g))
                   * DECODE(a.fin_cat_type_code, 'R', 1, -1)  prim_g_month4,
        SUM(DECODE(period_seq, 5, prim_amt_g))
                   * DECODE(a.fin_cat_type_code, 'R', 1, -1)  prim_g_month5,
        SUM(DECODE(period_seq, 6, prim_amt_g))
                   * DECODE(a.fin_cat_type_code, 'R', 1, -1)  prim_g_month6,
        SUM(DECODE(period_seq, 7, prim_amt_g))
                   * DECODE(a.fin_cat_type_code, 'R', 1, -1)  prim_g_month7,
        SUM(DECODE(period_seq, 8, prim_amt_g))
                   * DECODE(a.fin_cat_type_code, 'R', 1, -1)  prim_g_month8,
        SUM(DECODE(period_seq, 9, prim_amt_g))
                   * DECODE(a.fin_cat_type_code, 'R', 1, -1)  prim_g_month9,
        SUM(DECODE(period_seq, 10, prim_amt_g))
                   * DECODE(a.fin_cat_type_code, 'R', 1, -1)  prim_g_month10,
        SUM(DECODE(period_seq, 11, prim_amt_g))
                   * DECODE(a.fin_cat_type_code, 'R', 1, -1)  prim_g_month11,
        SUM(DECODE(period_seq, 12, prim_amt_g))
                   * DECODE(a.fin_cat_type_code, 'R', 1, -1)  prim_g_month12,
        SUM(DECODE(period_seq, 13, prim_amt_g))
                   * DECODE(a.fin_cat_type_code, 'R', 1, -1)  prim_g_month13,
        SUM(DECODE(qtr_seq, 1, prim_amt_g))
                   * DECODE(a.fin_cat_type_code, 'R', 1, -1)  prim_g_qtr1,
        SUM(DECODE(qtr_seq, 2, prim_amt_g))
                   * DECODE(a.fin_cat_type_code, 'R', 1, -1)  prim_g_qtr2,
        SUM(DECODE(qtr_seq, 3, prim_amt_g))
                   * DECODE(a.fin_cat_type_code, 'R', 1, -1)  prim_g_qtr3,
        SUM(DECODE(qtr_seq, 4, prim_amt_g))
                   * DECODE(a.fin_cat_type_code, 'R', 1, -1)  prim_g_qtr4,
        SUM(NVL(DECODE(qtr_seq, 1, prim_amt_g),0) +
		  NVL(DECODE(qtr_seq, 2, prim_amt_g),0) +
		  NVL(DECODE(qtr_seq, 3, prim_amt_g),0) +
		  NVL(DECODE(qtr_seq, 4, prim_amt_g),0))
                   * DECODE(a.fin_cat_type_code, 'R', 1, -1)  prim_g_year,
        SUM(mtd_prim_amt_g)
                   * DECODE(a.fin_cat_type_code, 'R', 1, -1)  prim_g_mtd,
        SUM(qtd_prim_amt_g)
                   * DECODE(a.fin_cat_type_code, 'R', 1, -1)  prim_g_qtd,
        SUM(ytd_prim_amt_g)
                   * DECODE(a.fin_cat_type_code, 'R', 1, -1)  prim_g_ytd,

        SUM(DECODE(period_seq, 1, sec_amt_g))
                   * DECODE(a.fin_cat_type_code, 'R', 1, -1)  sec_g_month1,
        SUM(DECODE(period_seq, 2, sec_amt_g))
                   * DECODE(a.fin_cat_type_code, 'R', 1, -1)  sec_g_month2,
        SUM(DECODE(period_seq, 3, sec_amt_g))
                   * DECODE(a.fin_cat_type_code, 'R', 1, -1)  sec_g_month3,
        SUM(DECODE(period_seq, 4, sec_amt_g))
                   * DECODE(a.fin_cat_type_code, 'R', 1, -1)  sec_g_month4,
        SUM(DECODE(period_seq, 5, sec_amt_g))
                   * DECODE(a.fin_cat_type_code, 'R', 1, -1)  sec_g_month5,
        SUM(DECODE(period_seq, 6, sec_amt_g))
                   * DECODE(a.fin_cat_type_code, 'R', 1, -1)  sec_g_month6,
        SUM(DECODE(period_seq, 7, sec_amt_g))
                   * DECODE(a.fin_cat_type_code, 'R', 1, -1)  sec_g_month7,
        SUM(DECODE(period_seq, 8, sec_amt_g))
                   * DECODE(a.fin_cat_type_code, 'R', 1, -1)  sec_g_month8,
        SUM(DECODE(period_seq, 9, sec_amt_g))
                   * DECODE(a.fin_cat_type_code, 'R', 1, -1)  sec_g_month9,
        SUM(DECODE(period_seq, 10, sec_amt_g))
                   * DECODE(a.fin_cat_type_code, 'R', 1, -1)  sec_g_month10,
        SUM(DECODE(period_seq, 11, sec_amt_g))
                   * DECODE(a.fin_cat_type_code, 'R', 1, -1)  sec_g_month11,
        SUM(DECODE(period_seq, 12, sec_amt_g))
                   * DECODE(a.fin_cat_type_code, 'R', 1, -1)  sec_g_month12,
        SUM(DECODE(period_seq, 13, sec_amt_g))
                   * DECODE(a.fin_cat_type_code, 'R', 1, -1)  sec_g_month13,
        SUM(DECODE(qtr_seq, 1, sec_amt_g))
                   * DECODE(a.fin_cat_type_code, 'R', 1, -1)  sec_g_qtr1,
        SUM(DECODE(qtr_seq, 2, sec_amt_g))
                   * DECODE(a.fin_cat_type_code, 'R', 1, -1)  sec_g_qtr2,
        SUM(DECODE(qtr_seq, 3, sec_amt_g))
                   * DECODE(a.fin_cat_type_code, 'R', 1, -1)  sec_g_qtr3,
        SUM(DECODE(qtr_seq, 4, sec_amt_g))
                   * DECODE(a.fin_cat_type_code, 'R', 1, -1)  sec_g_qtr4,
        SUM(NVL(DECODE(qtr_seq, 1, sec_amt_g),0) +
		  NVL(DECODE(qtr_seq, 2, sec_amt_g),0) +
		  NVL(DECODE(qtr_seq, 3, sec_amt_g),0) +
		  NVL(DECODE(qtr_seq, 4, sec_amt_g),0))
                   * DECODE(a.fin_cat_type_code, 'R', 1, -1)  sec_g_year,
        SUM(mtd_sec_amt_g)
                   * DECODE(a.fin_cat_type_code, 'R', 1, -1)  sec_g_mtd,
        SUM(qtd_sec_amt_g)
                   * DECODE(a.fin_cat_type_code, 'R', 1, -1)  sec_g_qtd,
        SUM(ytd_sec_amt_g)
                   * DECODE(a.fin_cat_type_code, 'R', 1, -1)  sec_g_ytd,

       g_fii_sysdate,
       g_fii_user_id,
       g_fii_sysdate,
       g_fii_user_id,
       g_fii_login_id,
       amount_type_code

 FROM
  (SELECT b.ent_year_id, b.qtr_seq,  b.period_seq,
          b.company_id, b.cost_center_id, b.fin_category_id,
          b.user_dim1_id, b.user_dim2_id, ledger_id,
          SUM(b.prim_amount_g) prim_amt_g,
          SUM(b.sec_amount_g) sec_amt_g,
           NULL mtd_prim_amt_g, NULL qtd_prim_amt_g, NULL ytd_prim_amt_g,
          NULL mtd_sec_amt_g,  NULL qtd_sec_amt_g,  NULL ytd_sec_amt_g,
	  'A' amount_type_code

   FROM  summary_full b

   GROUP BY b.ent_year_id, b.qtr_seq,  b.period_seq,
            b.company_id, b.cost_center_id, b.fin_category_id,
            b.user_dim1_id, b.user_dim2_id, ledger_id, 'A'

   UNION ALL

   SELECT l_year_id ent_year_id, 0 qtr_seq,  0 period_seq,
          b1.company_id, b1.cost_center_id, b1.fin_category_id,
          b1.user_dim1_id, b1.user_dim2_id, b1.ledger_id,
          NULL prim_amt_g, NULL sec_amt_g,
          SUM(CASE WHEN bitand(b1.record_type_id, 64) = 64
                   THEN b1.prim_amount_g
                   ELSE NULL end)  mtd_prim_amt_g,
          SUM(CASE WHEN bitand(b1.record_type_id, 128) = 128
                   THEN b1.prim_amount_g
                   ELSE NULL end) qtd_prim_amt_g,
          SUM(CASE WHEN bitand(b1.record_type_id, 256) = 256
                   THEN b1.prim_amount_g
                   ELSE NULL end) ytd_prim_amt_g,
          SUM(CASE WHEN bitand(b1.record_type_id, 64) =  64
                   THEN b1.sec_amount_g
                   ELSE NULL end)  mtd_sec_amt_g,
          SUM(CASE WHEN bitand(b1.record_type_id, 128) = 128
                   THEN b1.sec_amount_g
                   ELSE NULL end) qtd_sec_amt_g,
          SUM(CASE WHEN bitand(b1.record_type_id, 256) = 256
                   THEN b1.sec_amount_g
                   ELSE NULL end) ytd_sec_amt_g,
	  'A' amount_type_code

   FROM  summary_xtd b1

   GROUP BY b1.company_id, b1.cost_center_id, b1.fin_category_id,
            b1.user_dim1_id, b1.user_dim2_id, b1.ledger_id, 'A') f,

	fii_fin_cat_type_assgns  a,
	fii_com_cc_dim_maps m,
	fii_fin_cat_leaf_maps c,
	fii_udd1_mappings ud1,
	fii_udd2_mappings ud2

 WHERE	f.fin_category_id = a.fin_category_id
	AND a.fin_cat_type_code in ('R', 'OE', 'TE', 'PE', 'CGS')
	AND f.user_dim1_id = ud1.child_user_dim1_id
	AND f.user_dim2_id = ud2.child_user_dim2_id
	AND f.company_id = m.child_company_id
	AND f.cost_center_id = m.child_cost_center_id
	AND f.fin_category_id = c.child_fin_cat_id

 GROUP BY f.ent_year_id, f.company_id,
          f.cost_center_id, f.fin_category_id,
          f.user_dim1_id,  f.user_dim2_id,
          f.ledger_id, a.fin_cat_type_code,amount_type_code;

END IF;


  IF g_debug_flag = 'Y' THEN
    FII_UTIL.stop_timer();
    FII_UTIL.Write_Log ( 'FII_GL_LOCAL_SNAP_F has been populated successfully' );
    FII_UTIL.Write_Log ('Inserted ' || SQL%ROWCOUNT || ' rows');
    FII_UTIL.print_timer();
  END IF;

  g_phase := 'Gather table stats for FII_GL_LOCAL_SNAP_F';
  fnd_stats.gather_table_stats (ownname=>g_schema_name,
                                tabname=>'FII_GL_LOCAL_SNAP_F');

  g_phase := 'Commit the change';
  commit;

  IF g_debug_flag = 'Y' THEN
    FII_UTIL.Write_Log ('< Leaving REFRESH_GL_LOCAL_SNAP_F');
    FII_UTIL.Write_Log (' ');
  END IF;

 EXCEPTION

  WHEN OTHERS THEN
    FII_UTIL.Write_Log ('Other error in REFRESH_GL_LOCAL_SNAP_F ');
    FII_UTIL.Write_Log ( 'G_PHASE: ' || G_PHASE);
    FII_UTIL.Write_Log ('-->'|| sqlcode ||':'|| substr(sqlerrm,1,180));
    rollback;
    raise;

 END REFRESH_GL_LOCAL_SNAP_F;


----------------------------------------------------------
-- PROCEDURE MAIN  (public)
--
-- This procedure will (fully) refresh all snapshot tables
----------------------------------------------------------
 PROCEDURE Main (errbuf                IN OUT NOCOPY VARCHAR2,
                 retcode               IN OUT NOCOPY VARCHAR2) IS

   ret_val             BOOLEAN := FALSE;

 Begin

     g_phase := 'Entering Main';
     IF g_debug_flag = 'Y' THEN
       FII_UTIL.Write_Log ('Entering Main');
     END IF;

     g_phase := 'Calling Initialize';
     IF g_debug_flag = 'Y' THEN
       FII_UTIL.Write_Log ('Calling Initialize');
     END IF;

   Initialize;

     g_phase := 'Populating FII_GL_LOCAL_SNAP_F';
     IF g_debug_flag = 'Y' THEN
       FII_UTIL.Write_Log ('Populating FII_GL_LOCAL_SNAP_F');
     END IF;

   REFRESH_GL_LOCAL_SNAP_F;

     g_phase := 'Populating FII_GL_SNAP_F';
     IF g_debug_flag = 'Y' THEN
       FII_UTIL.Write_Log ('Populating FII_GL_SNAP_F');
     END IF;

   REFRESH_GL_SNAP_F;

     g_phase := 'Populating FII_GL_SNAP_SUM_F';
     IF g_debug_flag = 'Y' THEN
       FII_UTIL.Write_Log ('Populating FII_GL_SNAP_SUM_F');
     END IF;

   REFRESH_GL_SNAP_SUM_F;

   g_phase := 'Exiting after successful completion';
   IF g_debug_flag = 'Y' THEN
     FII_UTIL.Write_Log ('Exiting after successful completion');
   END IF;


 EXCEPTION

  WHEN OTHERS THEN
    FII_UTIL.Write_Log ('Other error in Main ');
    FII_UTIL.Write_Log ( 'G_PHASE: ' || G_PHASE);
    FII_UTIL.Write_Log ('-->'|| sqlcode ||':'|| substr(sqlerrm,1,180));

    FND_CONCURRENT.Af_Rollback;
    retcode := sqlcode;
    errbuf  := sqlerrm;
    ret_val := FND_CONCURRENT.Set_Completion_Status
	           (status => 'ERROR', message => substr(errbuf,1,180));

 END Main;


END FII_SNAP_TBL_REFRESH;

/
