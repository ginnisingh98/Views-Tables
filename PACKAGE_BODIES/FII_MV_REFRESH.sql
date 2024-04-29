--------------------------------------------------------
--  DDL for Package Body FII_MV_REFRESH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_MV_REFRESH" AS
/*$Header: FIIMVRSB.pls 120.31 2006/06/15 17:44:07 juding ship $*/

g_phase         VARCHAR2(50);
g_debug_flag 	VARCHAR2(1) := NVL(FND_PROFILE.value('FII_DEBUG_MODE'), 'N');
g_retcode       VARCHAR2(20) := NULL;
g_apps_schema_name   VARCHAR2(120) := NVL(FII_UTIL.get_apps_schema_name, 'APPS');

----------------------------------------------------
-- PROCEDURE GL_REFRESH
----------------------------------------------------
PROCEDURE GL_REFRESH (Errbuf         IN OUT NOCOPY Varchar2,
                      Retcode        IN OUT NOCOPY Varchar2,
                      p_program_type IN            VARCHAR2) IS

   l_dir	       VARCHAR2(150) := NULL;
   l_parallel_degree   NUMBER := 0;
   index_exception     EXCEPTION;
   l_ret_val           BOOLEAN := FALSE;

BEGIN

   Errbuf  := NULL;
   Retcode := '0';

   ------------------------------------------------------
   -- Set default directory in case if the profile option
   -- BIS_DEBUG_LOG_DIRECTORY is not set up
   ------------------------------------------------------
   l_dir := FII_UTIL.get_utl_file_dir;

   ----------------------------------------------------------------
   -- fii_util.initialize will get profile options FII_DEBUG_MODE
   -- and BIS_DEBUG_LOG_DIRECTORY and set up the directory where
   -- the log files and output files are written to
   ---------------------------------------------------------------
   FII_UTIL.initialize('FII_GL_MV_REFRESH.log', 'FII_GL_MV_REFRESH.out',l_dir, 'FII_MV_REFRESH');

   l_parallel_degree :=  BIS_COMMON_PARAMETERS.GET_DEGREE_OF_PARALLELISM();
   IF  (l_parallel_degree =1) THEN
     l_parallel_degree := 0;
    END IF;

  --------------------------------------------------------
  -- Refreshing the MVs
  ----------------------------------------------------------

  ---------------------------------*****---
  --bug 3242732: refresh FII_GL_BASE_MV, this is a temporary fix
  IF (p_program_type = 'L')
  THEN
     -- bug 4115002 - changed from dbms_mview.refresh to bis_mv_refresh
     BIS_MV_REFRESH.refresh_wrapper  ( 'FII_GL_BASE_MV', 'C',l_parallel_degree );

    --(only) Analyze the MV LOG after full refresh
    fnd_stats.gather_table_stats (ownname=>g_apps_schema_name,
                                  tabname=>'MLOG$_FII_GL_BASE_MV');
  ELSE
     BIS_MV_REFRESH.refresh_wrapper  ( 'FII_GL_BASE_MV', '?',l_parallel_degree );
  END IF;

  ---------------------------------*****---

  -- Drop index for FII_GL_MGMT_CCC_MV in Initial Mode
  IF (p_program_type = 'L') THEN
    fii_index_util.drop_index('FII_GL_MGMT_CCC_MV', g_apps_schema_name, Retcode);
    IF Retcode <> '0' THEN
      RAISE index_exception;
    END IF;
  END IF;

  -- Refresh FII_GL_MGMT_CCC_MV
  IF g_debug_flag = 'Y' THEN
    FII_UTIL.start_timer();
  END IF;

------------------------------------------------------------------------------
--Bug 3155474: call BIS wrapper to handle force parallel on MVs
-----
-----  dbms_mview.refresh( list => 'FII_GL_MGMT_CCC_MV',
-----                      method => '?',
-----                      parallelism => l_parallel_degree );

  IF (p_program_type = 'L') THEN
    BIS_MV_REFRESH.refresh_wrapper ('FII_GL_MGMT_CCC_MV', 'C', l_parallel_degree);
  ELSE
    BIS_MV_REFRESH.refresh_wrapper ('FII_GL_MGMT_CCC_MV', '?', l_parallel_degree);
  END IF;
------------------------------------------------------------------------------

  IF g_debug_flag = 'Y' THEN
    FII_UTIL.stop_timer();
    FII_UTIL.put_line( 'FII_GL_MGMT_CCC_MV has been refreshed successfully' );
    FII_UTIL.print_timer();
  END IF;

  -- Re-create index for FII_GL_MGMT_CCC_MV in Initial Mode
  IF (p_program_type = 'L') THEN
    fii_index_util.create_index('FII_GL_MGMT_CCC_MV', g_apps_schema_name, Retcode );
    IF Retcode <> '0' THEN
      RAISE index_exception;
    END IF;
  END IF;

  -- Gather statistics for FII_GL_MGMT_CCC_MV
  g_phase := 'Calling FND_STATS API to gather table statstics';
  IF g_debug_flag = 'Y' THEN
    FII_UTIL.put_line(g_phase ||' for FII_GL_MGMT_CCC_MV' );
    FII_UTIL.put_line('');
  END IF;

  fnd_stats.gather_table_stats (ownname=>g_apps_schema_name,
                                tabname=>'FII_GL_MGMT_CCC_MV');

  --(only) Analyze the MV LOG after full refresh
  IF (p_program_type = 'L') THEN
    fnd_stats.gather_table_stats (ownname=>g_apps_schema_name,
                                  tabname=>'MLOG$_FII_GL_MGMT_CCC_MV');
  END IF;

  -- Drop index for FII_GL_MGMT_SUM_MV in Initial Mode
  IF (p_program_type = 'L') THEN
    fii_index_util.drop_index('FII_GL_MGMT_SUM_MV', g_apps_schema_name, Retcode);
    IF Retcode <> '0' THEN
      RAISE index_exception;
    END IF;
  END IF;

  -- Refresh FII_GL_MGMT_SUM_MV
  IF g_debug_flag = 'Y' THEN
    FII_UTIL.start_timer();
  END IF;

------------------------------------------------------------------------------
--Bug 3155474: call BIS wrapper to handle force parallel on MVs
--
-----  dbms_mview.refresh( list =>  'FII_GL_MGMT_SUM_MV',
-----                      method => '?',
-----                      parallelism => l_parallel_degree );

  IF (p_program_type = 'L') THEN
    BIS_MV_REFRESH.refresh_wrapper ('FII_GL_MGMT_SUM_MV', 'C', l_parallel_degree);
  ELSE
    BIS_MV_REFRESH.refresh_wrapper ('FII_GL_MGMT_SUM_MV', '?', l_parallel_degree);
  END IF;
------------------------------------------------------------------------------

  IF g_debug_flag = 'Y' THEN
    FII_UTIL.stop_timer();
    FII_UTIL.put_line( 'FII_GL_MGMT_SUM_MV has been refreshed successfully' );
    FII_UTIL.print_timer();
  END IF;

  -- Re-create index for FII_GL_MGMT_SUM_MV in Initial Mode
  IF (p_program_type = 'L') THEN
    fii_index_util.create_index('FII_GL_MGMT_SUM_MV', g_apps_schema_name, Retcode);
    IF Retcode <> '0' THEN
      RAISE index_exception;
    END IF;
  END IF;

EXCEPTION

  WHEN index_exception THEN
    Errbuf:= sqlerrm;
    Retcode:=sqlcode;
    IF g_debug_flag = 'Y' THEN
      FII_UTIL.put_line('Index Exception in index drop/create');
      FII_UTIL.put_line('-->'||Retcode||':'||Errbuf);
   END IF;
   l_ret_val := FND_CONCURRENT.Set_Completion_Status
                           (status  => 'ERROR', message => substr(errbuf,1,180));
   rollback;

  WHEN OTHERS THEN
    Errbuf:= sqlerrm;
    Retcode:=sqlcode;
    IF g_debug_flag = 'Y' THEN
      FII_UTIL.put_line('Other error in GL_REFRESH');
      FII_UTIL.put_line('-->'||Retcode||':'||Errbuf);
   END IF;
   l_ret_val := FND_CONCURRENT.Set_Completion_Status
                           (status  => 'ERROR', message => substr(errbuf,1,180));
   rollback;

END GL_REFRESH;


---------------------------------------------------------------
-- PROCEDURE AR_REFRESH
---------------------------------------------------------------
PROCEDURE AR_REFRESH(Errbuf        in out NOCOPY Varchar2,
                     Retcode       in out NOCOPY Varchar2) IS

	l_dir    VARCHAR2(150) := NULL;
        l_min              DATE;
        l_max              DATE;
        l_check_time_dim   BOOLEAN;
        l_parallel_degree   NUMBER := 0;
        l_count             NUMBER := 0;
        l_ret_val             BOOLEAN := FALSE;

BEGIN

   ------------------------------------------------------
   -- Set default directory in case if the profile option
   -- BIS_DEBUG_LOG_DIRECTORY is not set up
   ------------------------------------------------------
   l_dir:= FII_UTIL.get_utl_file_dir;

   ----------------------------------------------------------------
   -- fii_util.initialize will get profile options FII_DEBUG_MODE
   -- and BIS_DEBUG_LOG_DIRECTORY and set up the directory where
   -- the log files and output files are written to
   ----------------------------------------------------------------
   	FII_UTIL.initialize('FII_AR_MV_REFRESH.log', 'FII_AR_MV_REFRESH.out',l_dir, 'FII_MV_REFRESH');



	g_phase := 'Refreshing AR Revenue MV';
   if g_debug_flag = 'Y' then
   	FII_UTIL.put_line(g_phase);
   	FII_UTIL.put_line('');
   end if;

      -----------------------------------------------------------
      -- If there are no records in the base summary table,
      -- then give a message to run Load program and exit this program.
      --  If there are records in base summary table, proceed
      --  further and refresh the summary table.
      -----------------------------------------------------------

	g_phase := 'Checking base table for records';
   if g_debug_flag = 'Y' then
   	FII_UTIL.put_line(g_phase);
   	FII_UTIL.put_line('');
   end if;

   begin
       SELECT 1 INTO l_count FROM FII_AR_REVENUE_B
       WHERE ROWNUM = 1;
   exception
       when NO_DATA_FOUND then
         l_count := 0;
   end;

  IF  l_count = 0 THEN    -- no records in fii_ar_revenue_b

       FII_MESSAGE.write_log(msg_name => 'FII_AR_REV_NO_RECS', token_num   => 0);

       retcode := 1;

       RETURN;

  ELSE  -- there are records in fii_ar_revenue_b

      -----------------------------------------------------------
      -- If we find record in the base summary table which references
      -- time records which does not exist in FII_TIME_DAY
      -- table, then we will exit the program with warning
      -- status
      -----------------------------------------------------------
	g_phase := 'Checking time dimension';
   if g_debug_flag = 'Y' then
   	FII_UTIL.put_line(g_phase);
   	FII_UTIL.put_line('');
   end if;

      SELECT MIN(t.gl_date),Max(t.gl_date)
      INTO   l_min, l_max
      FROM   FII_AR_REVENUE_B t;

                FII_TIME_API.check_missing_date(l_min, l_max, l_check_time_dim);

      --------------------------------------
      -- If there are missing time records
      --------------------------------------
      IF (l_check_time_dim) THEN
      	if g_debug_flag = 'Y' then
                FII_UTIL.put_line('Time Dimension is not fully populated.  Please populate Time
  dimension to cover the date range you are refreshing');
        end if;
         retcode := 1;
         RETURN;

     END IF;

       FII_UTIL.start_timer;
     ------------------------------------------------
      --Begin call HRI_OPL_PER_ORGCC.Load to populate
     ------------------------------------------------
     HRI_OPL_PER_ORGCC.Load (errbuf,
                            retcode,
                            NULL,  --chunk_size
                            NULL,  --start_date
                            NULL,  --end_date
                            NULL); --full_refresh
     FII_UTIL.stop_timer;
     FII_UTIL.print_timer('Duration for populating table HRI_CS_PER_ORGCC_CT: ');

	g_phase := 'Refreshing MV table';
   if g_debug_flag = 'Y' then
   	FII_UTIL.put_line(g_phase);
   	FII_UTIL.put_line('');
   end if;

   l_parallel_degree :=  BIS_COMMON_PARAMETERS.GET_DEGREE_OF_PARALLELISM();
   IF  (l_parallel_degree =1) THEN
       l_parallel_degree := 0;
   END IF;

    dbms_mview.refresh( list =>  'FII_AR_REV_SUM_MV',
                        method => '?',
                        parallelism => l_parallel_degree );

	--------------------------------------------------------
  	-- Gather statistics for the use of cost-based optimizer
  	--------------------------------------------------------
   g_phase := 'Calling FND_STATS API to gather table statstics';
   if g_debug_flag = 'Y' then
   	FII_UTIL.put_line(g_phase);
   	FII_UTIL.put_line('');
   end if;

   fnd_stats.gather_table_stats (ownname=>g_apps_schema_name, tabname=>'FII_AR_REV_SUM_MV');

  END IF;   -- l_count

EXCEPTION
  WHEN OTHERS THEN
 	Errbuf:= sqlerrm;
 	Retcode:=sqlcode;
 	if g_debug_flag = 'Y' then
          FII_UTIL.put_line('Other error in AR_REFRESH');
	  FII_UTIL.put_line('-->'||Retcode||':'||Errbuf);
        END IF;
        l_ret_val := FND_CONCURRENT.Set_Completion_Status
                      (status  => 'ERROR', message => substr(errbuf,1,180));
        rollback;

END AR_REFRESH;

-----------------------------------------------------------------------------
-- PROCEDURE RSG_CALLOUT_API
-----------------------------------------------------------------------------
/* This API will be seeded for individual MVs and base summary tables and
   will be called by BIS with different input table values during the initial
   and incremental request sets.  This API peforms the following functions:
   1.  Before initial load, drop MV log on base summary table.
   2.  After initial load, recreate MV log on base summary table.
   3.  Before initial refresh, drop indexes on MVs.
   4.  After initial refresh, recreate indexes on MVs. */

PROCEDURE RSG_CALLOUT_API(p_param IN OUT NOCOPY BIS_BIA_RSG_PARAMETER_TBL) IS
     l_api_type   VARCHAR2(300);
     l_mode       VARCHAR2(300);
     l_obj_name   VARCHAR2(300);
     l_obj_type   VARCHAR2(300);

     l_retcode    VARCHAR2(50) := '0';
     l_index_exception EXCEPTION;
BEGIN

     BIS_BIA_RSG_CUSTOM_API_MGMNT.LOG('Retrieving Parameters');

     l_api_type := BIS_BIA_RSG_CUSTOM_API_MGMNT.GET_PARAM(p_param,
                          BIS_BIA_RSG_CUSTOM_API_MGMNT.PARA_API_TYPE);
     l_mode := BIS_BIA_RSG_CUSTOM_API_MGMNT.GET_PARAM(p_param,
                      BIS_BIA_RSG_CUSTOM_API_MGMNT.PARA_MODE);
     l_obj_name := BIS_BIA_RSG_CUSTOM_API_MGMNT.GET_PARAM(p_param,
                          BIS_BIA_RSG_CUSTOM_API_MGMNT.PARA_OBJECT_NAME);
     l_obj_type := BIS_BIA_RSG_CUSTOM_API_MGMNT.GET_PARAM(p_param,
                          BIS_BIA_RSG_CUSTOM_API_MGMNT.PARA_OBJECT_TYPE);


     IF l_api_type = BIS_BIA_RSG_CUSTOM_API_MGMNT.TYPE_MV_INDEX_MGT THEN
     BIS_BIA_RSG_CUSTOM_API_MGMNT.LOG('API Type is MV Index Management');
          IF l_mode = BIS_BIA_RSG_CUSTOM_API_MGMNT.MODE_BEFORE THEN
               BIS_BIA_RSG_CUSTOM_API_MGMNT.LOG('Dropping indexes on object ' || l_obj_name);
               FII_INDEX_UTIL.Drop_Index(l_obj_name, g_apps_schema_name, l_retcode);
               IF l_retcode <> '0' THEN
                  RAISE l_index_exception;
               END IF;
          ELSE --AFTER Mode
               BIS_BIA_RSG_CUSTOM_API_MGMNT.LOG('Recreating indexes on object ' || l_obj_name);
               FII_INDEX_UTIL.Create_Index(l_obj_name, g_apps_schema_name, l_retcode);
               IF l_retcode <> '0' THEN
                  RAISE l_index_exception;
               END IF;
          END IF;
     ELSIF l_api_type = BIS_BIA_RSG_CUSTOM_API_MGMNT.TYPE_MV_LOG_MGT THEN
     BIS_BIA_RSG_CUSTOM_API_MGMNT.LOG('API Type is MV Log Management');
          IF l_mode = BIS_BIA_RSG_CUSTOM_API_MGMNT.MODE_BEFORE THEN
               BIS_BIA_RSG_CUSTOM_API_MGMNT.LOG('Dropping MV Log on object ' || l_obj_name);
               BIS_BIA_RSG_LOG_MGMNT.base_sum_mlog_capture_and_drop(l_obj_name);
          ELSE --AFTER Mode
               BIS_BIA_RSG_CUSTOM_API_MGMNT.LOG('Recreating MV Log for object ' || l_obj_name);
               BIS_BIA_RSG_LOG_MGMNT.base_sum_mlog_recreate(l_obj_name);
          END IF;
     ELSE
     BIS_BIA_RSG_CUSTOM_API_MGMNT.LOG('API Type is NOT MV Index Management or MV Log Managment');
     END IF;

     BIS_BIA_RSG_CUSTOM_API_MGMNT.SET_PARAM(p_param,
            BIS_BIA_RSG_CUSTOM_API_MGMNT.PARA_COMPLETE_STATUS,
            BIS_BIA_RSG_CUSTOM_API_MGMNT.STATUS_SUCCESS);
     BIS_BIA_RSG_CUSTOM_API_MGMNT.SET_PARAM(p_param,
            BIS_BIA_RSG_CUSTOM_API_MGMNT.PARA_MESSAGE, 'Succeeded');

EXCEPTION
WHEN l_index_exception THEN
     BIS_BIA_RSG_CUSTOM_API_MGMNT.LOG('Index Exception in FII_MV_REFRESH.RSG_CALLOUT_API');
     BIS_BIA_RSG_CUSTOM_API_MGMNT.SET_PARAM(p_param,
            BIS_BIA_RSG_CUSTOM_API_MGMNT.PARA_COMPLETE_STATUS,
            BIS_BIA_RSG_CUSTOM_API_MGMNT.STATUS_FAILURE);
     BIS_BIA_RSG_CUSTOM_API_MGMNT.SET_PARAM(p_param,
            BIS_BIA_RSG_CUSTOM_API_MGMNT.PARA_MESSAGE, sqlerrm);
WHEN OTHERS THEN
     BIS_BIA_RSG_CUSTOM_API_MGMNT.SET_PARAM(p_param,
            BIS_BIA_RSG_CUSTOM_API_MGMNT.PARA_COMPLETE_STATUS,
            BIS_BIA_RSG_CUSTOM_API_MGMNT.STATUS_FAILURE);
     BIS_BIA_RSG_CUSTOM_API_MGMNT.SET_PARAM(p_param,
            BIS_BIA_RSG_CUSTOM_API_MGMNT.PARA_MESSAGE, sqlerrm);
END RSG_CALLOUT_API;


END FII_MV_REFRESH;

/
