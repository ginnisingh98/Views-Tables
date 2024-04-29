--------------------------------------------------------
--  DDL for Package Body BIL_DO_L1_LD_OPPTY_DLY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIL_DO_L1_LD_OPPTY_DLY_PKG" AS
/* $Header: billdl1b.pls 115.19 2002/01/29 13:56:05 pkm ship      $ */

  -- Global Variables and Constants
     -- G_Debug will be modified to 'Y' programatically.
     -- when the parameter passed for P_debug is Y
     -- Once, this is set to 'Y', then the log file will be generated.
     -- Otherwise, log file will not be generated. Only the output file
     -- will be generated.
     G_Debug    VARCHAR2(1) := 'N';
     G_Trace    VARCHAR2(1) := 'N';



   -- Global variables for WHO variables and Concurrent program
     G_request_id    NUMBER;
     G_appl_id       NUMBER;
     G_program_id    NUMBER;
     G_user_id       NUMBER;
     G_login_id      NUMBER;



PROCEDURE Delete_Data (
       ERRBUF            IN OUT VARCHAR2
      ,RETCODE           IN OUT VARCHAR2
      ,p_date IN DATE
    ) ;

 PROCEDURE Init_Globals;

 PROCEDURE Insert_Data (
       ERRBUF               IN OUT VARCHAR2
      ,RETCODE              IN OUT VARCHAR2
      ,p_date               IN DATE
      ,p_degree             IN NUMBER
    ) ;

  PROCEDURE Refresh_Data_Day
    (
        ERRBUF        IN OUT VARCHAR2
      , RETCODE       IN OUT VARCHAR2
      , p_date        IN  DATE
      , p_delete_flag IN  VARCHAR2 DEFAULT 'Y'
      , p_degree      IN  VARCHAR2   DEFAULT '4'
      , p_debug_mode  IN  VARCHAR2 DEFAULT 'N'
      , p_trace_mode  IN  VARCHAR2 DEFAULT 'N'
    ) ;

  PROCEDURE Reset_Table_Usages;

  PROCEDURE Set_Table_Usages;



      /*******Main procedure : initializes global variables, deletes and then inserts previous day's data
    ERRBUFF:    error message returned by the proc
    RETCODE:    completion status of the procedure
    p_degree:   parallel degree
    p_debug:    debug mode (yes or no)
    p_trace:    trace mode (yes or no)
  *******/
  PROCEDURE Refresh_Data
    (
        ERRBUF        OUT VARCHAR2
      , RETCODE       OUT VARCHAR2
      , p_degree      IN  VARCHAR2   DEFAULT '4'
      , p_debug_mode  IN  VARCHAR2 DEFAULT 'N'
      , p_trace_mode  IN  VARCHAR2 DEFAULT 'N'
    ) IS

    -- Local variables
    l_collect_for_date DATE     := TRUNC(SYSDATE-1); -- date for which data is collected; one day prior to collection date
    l_degree           NUMBER   := TO_NUMBER(p_degree); -- parallel degree
    l_collection_date_start DATE;
    l_collection_date_loop DATE;

    BEGIN
    RETCODE := 0;

      Init_Globals;

      -- Validate input parameters
      IF p_debug_mode = 'Y' THEN
         G_Debug := 'Y';
      END IF;

      IF p_trace_mode = 'Y' THEN
         G_Trace := 'Y';
         EXECUTE IMMEDIATE 'ALTER SESSION SET SQL_TRACE=TRUE';
      END IF;


     BIL_DO_UTIL_PKG.Write_Log(p_msg=>'Parameters for Refesh_Data - Debug: ' || p_debug_mode
         || '  Trace: ' || p_trace_mode
         || '  Parallel Degree: ' || p_degree, p_debug =>p_debug_mode);


     Set_table_Usages;

    SELECT MAX(collection_date)+1
    INTO l_collection_date_start
    FROM bil_do_l1_ld_oppty_dly;

     l_collection_date_loop  := l_collection_date_start;
     WHILE (l_collection_date_loop <=l_collect_for_date) LOOP
      Refresh_Data_Day
      (
          ERRBUF        => ERRBUF
        , RETCODE       => RETCODE
        , p_date        => l_collection_date_loop
        , p_delete_flag => 'Y'
        , p_degree      => p_degree
        , p_debug_mode  => p_debug_mode
        , p_trace_mode  => p_trace_mode
       );
       l_collection_date_loop := l_collection_date_loop+1;
    END LOOP;

      IF l_collection_date_start > l_collect_for_date THEN
      l_collection_date_start := l_collect_for_date;
      Refresh_Data_Day
      (
          ERRBUF        => ERRBUF
        , RETCODE       => RETCODE
        , p_date        => l_collection_date_start
        , p_delete_flag => 'Y'
        , p_degree      => p_degree
        , p_debug_mode  => p_debug_mode
        , p_trace_mode  => p_trace_mode
       );
     END IF;


    BIL_DO_UTIL_PKG.Write_Log(p_msg=>'Analyze table bil_do_l1_ld_oppty_dly', p_debug=> p_debug_mode);

    DBMS_STATS.gather_table_stats(ownname=>'BIL', tabName=>'BIL_DO_L1_LD_OPPTY_DLY', cascade=>TRUE,
                                  degree=>l_Degree, estimate_percent=>99, granularity=>'GLOBAL');



    IF G_Trace = 'Y' THEN
         EXECUTE IMMEDIATE 'ALTER SESSION SET SQL_TRACE=FALSE';
    END IF;

    BIL_DO_UTIL_PKG.Write_Log(p_msg=>'Alter bil_do_l1_ld_oppty_dly table to noparallel', p_debug=>p_debug_mode);
    Reset_Table_Usages;

    BIL_DO_UTIL_PKG.Write_Log(p_msg=>'End of Refresh Data  for Lead to Opportunity Bin', p_debug=>p_debug_mode);



    END Refresh_Data;


  /*******Initial load procedure: loads data for a date range
    ERRBUFF:            error message returned by the proc
    RETCODE:            completion status of the procedure
    p_start_date:       start date of the range
    p_end_date:         end date of the range
    p_degree:           parallel degree
    p_truncate_flag:    truncate flag (yes or no)
    p_debug_mode:       debug mode (yes or no)
    p_trace_mode:       trace mode (yes or no)
  *******/
  PROCEDURE Initial_Load
    (       ERRBUF          OUT VARCHAR2
           ,RETCODE         OUT VARCHAR2
           ,p_start_date    IN  VARCHAR2
           ,p_end_date      IN  VARCHAR2
           ,p_degree        IN  VARCHAR2 DEFAULT '4'
           ,p_truncate_flag IN  VARCHAR2 DEFAULT 'N'
           ,p_debug_mode    IN  VARCHAR2 DEFAULT 'N'
           ,p_trace_mode    IN  VARCHAR2 DEFAULT 'N'
    )   IS

    -- Local variables
    l_date_fmt  VARCHAR2(30) := 'YYYY-MM-DD HH24:MI:SS';
    l_start_date DATE := TO_DATE(p_start_date, l_date_fmt);
    l_end_date   DATE := TO_DATE(p_end_date, l_date_fmt);
    l_degree           NUMBER   := TO_NUMBER(p_degree); -- parallel degree

    BEGIN

      RETCODE := 0;

      Init_Globals;

      -- Validate input parameters
      IF p_debug_mode = 'Y' THEN
         G_Debug := 'Y';
      END IF;

      IF p_trace_mode = 'Y' THEN
         G_Trace := 'Y';
         EXECUTE IMMEDIATE 'ALTER SESSION SET SQL_TRACE=TRUE';
      END IF;


    BIL_DO_UTIL_PKG.Write_Log(p_msg=>'Parameters for Refesh_Data - Start Date : ' || p_start_date
    || ' End date: ' || p_end_date
    || ' Parallel Degree: ' || p_degree
    || ' Truncate flag: ' || p_truncate_flag
    || ' Debug: ' || p_debug_mode
    || ' Trace: ' || p_trace_mode
    , p_debug =>p_debug_mode);


    Set_table_Usages;

    IF p_truncate_flag = 'Y' THEN
        EXECUTE IMMEDIATE 'TRUNCATE TABLE BIL.BIL_DO_L1_LD_OPPTY_DLY';
        WHILE l_start_date <= l_end_date LOOP
            Refresh_Data_Day
            (
                ERRBUF        => ERRBUF
              , RETCODE       => RETCODE
              , p_date        => l_start_date
              , p_delete_flag => 'N'
              , p_degree      => p_degree
              , p_debug_mode  => p_debug_mode
             , p_trace_mode  => p_trace_mode
            );
            l_start_date := l_start_date + 1;
        END LOOP;

    ELSE
        WHILE l_start_date <= l_end_date LOOP
            Refresh_Data_Day
            (
                ERRBUF        => ERRBUF
              , RETCODE       => RETCODE
              , p_date        => l_start_date
              , p_delete_flag => 'Y'
              , p_degree      => p_degree
              , p_debug_mode  => p_debug_mode
             , p_trace_mode  => p_trace_mode
            );
            l_start_date := l_start_date + 1;
        END LOOP;
    END IF;

    BIL_DO_UTIL_PKG.Write_Log(p_msg=>'Analyze table bil_do_l1_ld_oppty_dly', p_debug=> p_debug_mode);

    DBMS_STATS.gather_table_stats(ownname=>'BIL', tabName=>'BIL_DO_L1_LD_OPPTY_DLY', cascade=>TRUE,
                                  degree=>l_Degree, estimate_percent=>99, granularity=>'GLOBAL');

    BIL_DO_UTIL_PKG.Write_Log(p_msg=>'End of initial load of bil_do_l1_ld_oppty_dly', p_debug=> p_debug_mode);

    IF G_Trace = 'Y' THEN
         EXECUTE IMMEDIATE 'ALTER SESSION SET SQL_TRACE=FALSE';
    END IF;

    BIL_DO_UTIL_PKG.Write_Log(p_msg=>'Alter bil_do_l1_ld_oppty_dly table to noparallel', p_debug=>p_debug_mode);
    Reset_Table_Usages;

    EXCEPTION
       WHEN OTHERS THEN
          ERRBUF := ERRBUF||'Error in Initial_Load: '||to_char(sqlcode)||sqlerrm;
          RETCODE := '2';
          BIL_DO_UTIL_PKG.Write_Log(
              p_msg => 'Error in Initial_Load: '||to_char(sqlcode)||sqlerrm
            , p_force => 'Y');
          ROLLBACK;
          Reset_table_Usages;

END INITIAL_LOAD;




  /*******
  Delete data for the specified date
  ERRBUFF:            error message returned by the proc
  RETCODE:            completion status of the procedure
  p_date:             date for which the data will be deleted
  *******/
  PROCEDURE Delete_Data (
              ERRBUF  IN OUT VARCHAR2
             ,RETCODE IN OUT VARCHAR2
             ,p_date  IN DATE
            ) IS

  BEGIN

    DELETE FROM bil_do_l1_ld_oppty_dly
      WHERE collection_date = p_date;

    COMMIT;

    EXCEPTION
	 WHEN NO_DATA_FOUND THEN
	  NULL;
      WHEN OTHERS THEN
        ERRBUF := ERRBUF ||' Delete_Data:'||sqlcode||' '|| sqlerrm;
        RETCODE := '1';
  END Delete_Data;


/******* Initialize Global variables for WHO variables and Concurrent program
*******/
 PROCEDURE Init_Globals IS

 BEGIN
     G_request_id    := FND_GLOBAL.CONC_REQUEST_ID();
     G_appl_id       := FND_GLOBAL.PROG_APPL_ID();
     G_program_id    := FND_GLOBAL.CONC_PROGRAM_ID();
     G_user_id       := FND_GLOBAL.USER_ID();
     G_login_id      := FND_GLOBAL.CONC_LOGIN_ID();
 END Init_Globals;


/******* Insert data for the specified day
    ERRBUFF:    error message returned by the proc
    RETCODE:    completion status of the procedure
    p_date:     date for which data will be inserted
    p_degree:   parallel degree
*******/
PROCEDURE Insert_Data (
              ERRBUF            IN OUT VARCHAR2
             ,RETCODE           IN OUT VARCHAR2
             ,p_date            IN DATE
             ,p_degree          IN NUMBER
            ) IS

 l_sysdate DATE := SYSDATE; -- to be used in insert
 l_stime   DATE := SYSDATE; -- time when insert started, to be used by Write_log
 l_insert_stmnt  VARCHAR2(20000);
 l_select_stmnt1 VARCHAR2(20000);
 l_select_stmnt2 VARCHAR2(20000);
 l_quote VARCHAR2(1) := FND_GLOBAL.LOCAL_CHR(39); -- single quote
 l_row_count  NUMBER;


  BEGIN

  l_insert_stmnt := 'INSERT INTO /*+ APPEND PARALLEL(bld, ' || p_degree || ') */ bil_do_l1_ld_oppty_dly bld';
  l_insert_stmnt := l_insert_stmnt || '(';
  l_insert_stmnt := l_insert_stmnt || ' collection_date';
  l_insert_stmnt := l_insert_stmnt || ', sales_group_id';
  l_insert_stmnt := l_insert_stmnt || ', total_leads_all';
  l_insert_stmnt := l_insert_stmnt || ', open_leads_all';
  l_insert_stmnt := l_insert_stmnt || ', open_leads_day';
  l_insert_stmnt := l_insert_stmnt || ', touched_leads_all';
  l_insert_stmnt := l_insert_stmnt || ', touched_leads_day';
  l_insert_stmnt := l_insert_stmnt || ', converted_leads_all';
  l_insert_stmnt := l_insert_stmnt || ', converted_leads_day';
  l_insert_stmnt := l_insert_stmnt || ', creation_date';
  l_insert_stmnt := l_insert_stmnt || ', created_by';
  l_insert_stmnt := l_insert_stmnt || ', last_update_date';
  l_insert_stmnt := l_insert_stmnt || ', last_updated_by';
  l_insert_stmnt := l_insert_stmnt || ', last_update_login';
  l_insert_stmnt := l_insert_stmnt || ', request_id';
  l_insert_stmnt := l_insert_stmnt || ', program_application_id';
  l_insert_stmnt := l_insert_stmnt || ', program_id';
  l_insert_stmnt := l_insert_stmnt || ', program_update_date';
  l_insert_stmnt := l_insert_stmnt || ')';
  l_select_stmnt1  := 'SELECT /*+ PARALLEL(v, ' || p_degree || ') */';
  l_select_stmnt1  := l_select_stmnt1 || ':p_date';
  l_select_stmnt1  := l_select_stmnt1 ||  '     , nvl(v.sales_group_id, -999) sales_group_id';
  l_select_stmnt1  := l_select_stmnt1 ||  '     , SUM(v.total_leads_all) total_leads_all';
  l_select_stmnt1  := l_select_stmnt1 ||  '     , SUM(v.open_leads_all) open_leads_all';
  l_select_stmnt1  := l_select_stmnt1 ||  '     , SUM(v.open_leads_day) open_leads_day';
  l_select_stmnt1  := l_select_stmnt1 ||  '     , SUM(v.touched_leads_all) touched_leads_all';
  l_select_stmnt1  := l_select_stmnt1 ||  '     , SUM(v.touched_leads_day) touched_leads_day';
  l_select_stmnt1  := l_select_stmnt1 ||  '     , SUM(v.converted_leads_all) converted_leads_all';
  l_select_stmnt1  := l_select_stmnt1 ||  '     , SUM(v.converted_leads_day) converted_leads_day';
  l_select_stmnt1  := l_select_stmnt1 ||  '     , SYSDATE';
  l_select_stmnt1  := l_select_stmnt1 ||  '     ,' || G_user_id;
  l_select_stmnt1  := l_select_stmnt1 ||  '     , SYSDATE';
  l_select_stmnt1  := l_select_stmnt1 ||  '     ,' || G_user_id;
  l_select_stmnt1  := l_select_stmnt1 ||  '     ,' || G_login_id;
  l_select_stmnt1  := l_select_stmnt1 ||  '     ,' || G_request_id;
  l_select_stmnt1  := l_select_stmnt1 ||  '     ,' || G_appl_id;
  l_select_stmnt1  := l_select_stmnt1 ||  '     ,' || G_program_id;
  l_select_stmnt1  := l_select_stmnt1 ||  '     , SYSDATE';
  l_select_stmnt2  := '   FROM ';
  l_select_stmnt2  := l_select_stmnt2 ||  '   (SELECT /*+ PARALLEL(sl, ' || p_degree ||') */';
  l_select_stmnt2  := l_select_stmnt2 ||  '     grp.sales_group_id sales_group_id ';
  l_select_stmnt2  := l_select_stmnt2 ||  '     , COUNT(sl.sales_lead_id) total_leads_all ';
  l_select_stmnt2  := l_select_stmnt2 ||  '    , DECODE(st.opp_open_status_flag, ' || l_quote ||'Y' || l_quote || ', COUNT(sl.sales_lead_id), 0) open_leads_all ';
  l_select_stmnt2  := l_select_stmnt2 ||  '   , DECODE(' || ':p_date' || ', TRUNC(sl.creation_date) , DECODE(st.opp_open_status_flag, ';
  l_select_stmnt2  := l_select_stmnt2 || l_quote || 'Y' || l_quote || ' , COUNT(sl.sales_lead_id), 0) ,0) open_leads_day ';
  l_select_stmnt2  := l_select_stmnt2 || '    , DECODE(st.opp_open_status_flag, '|| l_quote ||'Y' || l_quote ;
  l_select_stmnt2  := l_select_stmnt2 || '    , DECODE(sl.creation_date, sl.last_update_date, 0, COUNT(sl.sales_lead_id))';
  l_select_stmnt2  := l_select_stmnt2 || '       , 0) touched_leads_all ';
  l_select_stmnt2  := l_select_stmnt2 || '     , DECODE(' || ':p_date' || ', TRUNC(sl.last_update_date)';
  l_select_stmnt2  := l_select_stmnt2 || '       , DECODE(st.opp_open_status_flag, ' || l_quote ||'Y' || l_quote;
  l_select_stmnt2  := l_select_stmnt2 || '         , DECODE(sl.creation_date, sl.last_update_date, 0, COUNT(sl.sales_lead_id))';
  l_select_stmnt2  := l_select_stmnt2 || '       , 0) ,0) touched_leads_day ';
  l_select_stmnt2  := l_select_stmnt2 || '     , 0 converted_leads_all ';
  l_select_stmnt2  := l_select_stmnt2 || '     , 0 converted_leads_day ';
  l_select_stmnt2  := l_select_stmnt2 || '   FROM ';
  l_select_stmnt2  := l_select_stmnt2 || '       as_sales_leads sl ';
  l_select_stmnt2  := l_select_stmnt2 || '     , as_statuses_b  st ';
  l_select_stmnt2  := l_select_stmnt2 || '     , bil_do_l1_base_grp_temp grp ';
  l_select_stmnt2  := l_select_stmnt2 || '   WHERE ';
  l_select_stmnt2  := l_select_stmnt2 || '        sl.status_code = st.status_code ';
  l_select_stmnt2  := l_select_stmnt2 || '    AND st.lead_flag = ' || l_quote ||'Y' || l_quote;
  l_select_stmnt2  := l_select_stmnt2 || '    AND st.enabled_flag = ' || l_quote ||'Y' || l_quote;
  l_select_stmnt2  := l_select_stmnt2 || '    AND NVL(sl.deleted_flag, '|| l_quote || 'N' || l_quote || ') <> ' || l_quote ||'Y' || l_quote;
  l_select_stmnt2  := l_select_stmnt2 || '    AND grp.child_sales_group_id = sl.assign_sales_group_id ';
  l_select_stmnt2  := l_select_stmnt2 || '   GROUP BY ';
  l_select_stmnt2  := l_select_stmnt2 || '      grp.sales_group_id ';
  l_select_stmnt2  := l_select_stmnt2 || '    , st.opp_open_status_flag ';
  l_select_stmnt2  := l_select_stmnt2 || '    , sl.creation_date ';
  l_select_stmnt2  := l_select_stmnt2 || '    , sl.last_update_date ';
  l_select_stmnt2  := l_select_stmnt2 || ' UNION ALL ';
  l_select_stmnt2  := l_select_stmnt2 || '      SELECT /*+ PARALLEL(sl, ' || p_degree || ') */';
  l_select_stmnt2  := l_select_stmnt2 || '         grp.sales_group_id sales_group_id ';
  l_select_stmnt2  := l_select_stmnt2 || '       , 0 total_leads_all ';
  l_select_stmnt2  := l_select_stmnt2 || '       , 0 open_leads_all ';
  l_select_stmnt2  := l_select_stmnt2 || '       , 0 open_leads_day ';
  l_select_stmnt2  := l_select_stmnt2 || '       , 0 touched_leads_all ';
  l_select_stmnt2  := l_select_stmnt2 || '       , 0 touched_leads_day ';
  l_select_stmnt2  := l_select_stmnt2 || '       , 0 converted_leads_all ';
  l_select_stmnt2  := l_select_stmnt2 || '       , DECODE(' || ':p_date' || ', TRUNC(slop.creation_date) ';
  l_select_stmnt2  := l_select_stmnt2 || '          , COUNT(DISTINCT sl.sales_lead_id), 0) converted_leads_day ';
  l_select_stmnt2  := l_select_stmnt2 || '     FROM ';
  l_select_stmnt2  := l_select_stmnt2 || '        as_sales_leads sl ';
  l_select_stmnt2  := l_select_stmnt2 || '      , as_sales_lead_opportunity slop ';
  l_select_stmnt2  := l_select_stmnt2 || '     , bil_do_l1_base_grp_temp grp ';
  l_select_stmnt2  := l_select_stmnt2 || '     WHERE ';
  l_select_stmnt2  := l_select_stmnt2 || '        NVL(sl.deleted_flag, ' || l_quote ||'N' || l_quote ||') <> ' || l_quote ||'Y' || l_quote;
  l_select_stmnt2  := l_select_stmnt2 || '    AND sl.sales_lead_id = slop.sales_lead_id ';
  l_select_stmnt2  := l_select_stmnt2 || '    AND grp.child_sales_group_id = sl.assign_sales_group_id';
  l_select_stmnt2  := l_select_stmnt2 || '   AND NOT EXISTS (SELECT sales_lead_id FROM as_sales_lead_opportunity slo';
  l_select_stmnt2  := l_select_stmnt2 || '                     WHERE slo.sales_lead_id = slop.sales_lead_id';
  l_select_stmnt2  := l_select_stmnt2 || '                     AND slo.creation_date < :p_date)';
  l_select_stmnt2  := l_select_stmnt2 || '   GROUP BY grp.sales_group_id';
  l_select_stmnt2  := l_select_stmnt2 || '            , TRUNC(slop.creation_date)';

  l_select_stmnt2  := l_select_stmnt2 || ' UNION ALL ';
  l_select_stmnt2  := l_select_stmnt2 || '      SELECT /*+ PARALLEL(sl, ' || p_degree || ') */';
  l_select_stmnt2  := l_select_stmnt2 || '         grp.sales_group_id sales_group_id ';
  l_select_stmnt2  := l_select_stmnt2 || '       , 0 total_leads_all ';
  l_select_stmnt2  := l_select_stmnt2 || '       , 0 open_leads_all ';
  l_select_stmnt2  := l_select_stmnt2 || '       , 0 open_leads_day ';
  l_select_stmnt2  := l_select_stmnt2 || '       , 0 touched_leads_all ';
  l_select_stmnt2  := l_select_stmnt2 || '       , 0 touched_leads_day ';
  l_select_stmnt2  := l_select_stmnt2 || '       , COUNT(DISTINCT sl.sales_lead_id) converted_leads_all ';
  l_select_stmnt2  := l_select_stmnt2 || '       , 0 converted_leads_day ';
  l_select_stmnt2  := l_select_stmnt2 || '     FROM ';
  l_select_stmnt2  := l_select_stmnt2 || '        as_sales_leads sl ';
  l_select_stmnt2  := l_select_stmnt2 || '      , as_sales_lead_opportunity slop ';
  l_select_stmnt2  := l_select_stmnt2 || '     , bil_do_l1_base_grp_temp grp ';
  l_select_stmnt2  := l_select_stmnt2 || '     WHERE ';
  l_select_stmnt2  := l_select_stmnt2 || '        NVL(sl.deleted_flag, ' || l_quote ||'N' || l_quote ||') <> ' || l_quote ||'Y' || l_quote;
  l_select_stmnt2  := l_select_stmnt2 || '    AND sl.sales_lead_id = slop.sales_lead_id ';
  l_select_stmnt2  := l_select_stmnt2 || '    AND grp.child_sales_group_id = sl.assign_sales_group_id';
  l_select_stmnt2  := l_select_stmnt2 || '   GROUP BY grp.sales_group_id';
  l_select_stmnt2  := l_select_stmnt2 || '            , TRUNC(slop.creation_date)';
  l_select_stmnt2  := l_select_stmnt2 || '   ) V ';
  l_select_stmnt2  := l_select_stmnt2 || '   GROUP BY v.sales_group_id ';

/*dbms_output.put_line(substr(l_insert_stmnt,1,150));
dbms_output.put_line(substr(l_insert_stmnt,151,150));
dbms_output.put_line(substr(l_insert_stmnt,301,150));
dbms_output.put_line(substr(l_insert_stmnt,451,150));
dbms_output.put_line(substr(l_insert_stmnt,601,150));
dbms_output.put_line(substr(l_insert_stmnt,751,150));
dbms_output.put_line(substr(l_insert_stmnt,901,150));*/


/*dbms_output.put_line(substr(l_select_stmnt1,1,150));
dbms_output.put_line(substr(l_select_stmnt1,151,150));
dbms_output.put_line(substr(l_select_stmnt1,301,150));
dbms_output.put_line(substr(l_select_stmnt1,451,150));
dbms_output.put_line(substr(l_select_stmnt1,601,150));
dbms_output.put_line(substr(l_select_stmnt1,751,150));
dbms_output.put_line(substr(l_select_stmnt1,901,150)); */

/* dbms_output.put_line(substr(l_select_stmnt2,1,150));
dbms_output.put_line(substr(l_select_stmnt2,151,150));
dbms_output.put_line(substr(l_select_stmnt2,301,150));
dbms_output.put_line(substr(l_select_stmnt2,451,150));
dbms_output.put_line(substr(l_select_stmnt2,601,150));
dbms_output.put_line(substr(l_select_stmnt2,751,150));
dbms_output.put_line(substr(l_select_stmnt2,901,150));
dbms_output.put_line(substr(l_select_stmnt2,1051,150));
dbms_output.put_line(substr(l_select_stmnt2,1201,150));
dbms_output.put_line(substr(l_select_stmnt2,1351,150));
dbms_output.put_line(substr(l_select_stmnt2,1501,150));
dbms_output.put_line(substr(l_select_stmnt2,1651,150));
dbms_output.put_line(substr(l_select_stmnt2,1801,150));
dbms_output.put_line(substr(l_select_stmnt2,1951,150));
dbms_output.put_line(substr(l_select_stmnt2,2111,150));
dbms_output.put_line(substr(l_select_stmnt2,2261,150));
dbms_output.put_line(substr(l_select_stmnt2,2311,150));
dbms_output.put_line(substr(l_select_stmnt2,2461,150)); */

  EXECUTE IMMEDIATE l_insert_stmnt || l_select_stmnt1 || l_select_stmnt2
  USING
    p_date
  , p_date
  , p_date
  , p_date
  , p_date;


 COMMIT;

 l_row_count := SQL%ROWCOUNT;

 BIL_DO_UTIL_PKG.Write_Log(p_msg=>'     Rows Inserted: '|| l_row_count,p_stime=>l_stime,p_etime=>SYSDATE, p_debug=>G_Debug);

 IF l_row_count = 0 THEN
        BIL_DO_UTIL_PKG.Write_Log(p_msg=>'     No rows Inserted. ', p_force=>'Y');
 END IF;



 EXCEPTION
      WHEN OTHERS THEN
        ERRBUF := ERRBUF ||' Insert_Data: '||sqlcode||' '|| sqlerrm;
        RETCODE := '2';
        BIL_DO_UTIL_PKG.Write_Log(p_msg=>' Insert_Data: '||sqlcode||' '|| sqlerrm
           , p_force=> 'Y');
        ROLLBACK;
        --DBMS_OUTPUT.PUT_LINE('Error in Insert_Data: ' ||sqlcode||' '|| sqlerrm);

END Insert_Data;


 /******* deletes and then inserts specified day's data
    ERRBUFF:    error message returned by the proc
    RETCODE:    completion status of the procedure
    p_degree:   parallel degree
    p_date  :   date for which data is collected
    p_debug_mode:    debug mode (yes or no)
    p_trace_mode:    trace mode (yes or no)
  *******/

  PROCEDURE Refresh_Data_Day
    (
        ERRBUF        IN OUT VARCHAR2
      , RETCODE       IN OUT VARCHAR2
	  , p_date        IN  DATE
      , p_delete_flag IN  VARCHAR2 DEFAULT 'Y'
      , p_degree      IN  VARCHAR2 DEFAULT '4'
      , p_debug_mode  IN  VARCHAR2 DEFAULT 'N'
      , p_trace_mode  IN  VARCHAR2 DEFAULT 'N'
    ) IS

    -- Local variables
    l_collect_for_date DATE     := p_date; -- date for which data is collected
    l_degree           NUMBER   := TO_NUMBER(p_degree); -- parallel degree


    BEGIN

     IF p_delete_flag = 'Y' THEN
     BIL_DO_UTIL_PKG.Write_Log(p_msg=>'Delete Data for collection date: ' || TO_CHAR(l_collect_for_date, 'DD-MON-YYYY'), p_debug=>p_debug_mode);
        Delete_Data (
           ERRBUF       => ERRBUF
          ,RETCODE      => RETCODE
          ,p_date => l_collect_for_date
         );
     END IF;


     BIL_DO_UTIL_PKG.Write_Log('Insert Data for collection date: ' || TO_CHAR(l_collect_for_date, 'DD-MON-YYYY'), p_debug=>p_debug_mode);

     Insert_Data (
           ERRBUF           => ERRBUF
          ,RETCODE          => RETCODE
          ,p_date           => l_collect_for_date
          ,p_degree         => l_degree
         );

     EXCEPTION
       WHEN OTHERS THEN
          ERRBUF := ERRBUF||'Error in Refresh_Data_Day:'||to_char(sqlcode)||sqlerrm;
          RETCODE := '2';
          BIL_DO_UTIL_PKG.Write_Log(
              p_msg => 'Error in Refresh_Data_Day for collection date: ' || TO_CHAR(l_collect_for_date, 'DD-MON-YYYY') ||to_char(sqlcode)||sqlerrm
            , p_force => 'Y');
          ROLLBACK;



  END Refresh_Data_Day;





  /*******
    Alter tables to logging
  *******/
  PROCEDURE Reset_Table_Usages IS
  BEGIN


    EXECUTE IMMEDIATE 'ALTER TABLE bil.bil_do_l1_ld_oppty_dly LOGGING';

    BIL_DO_UTIL_PKG.Write_Log(p_msg=>'BIL Table bil_do_l1_ld_oppty_dly altered to logging', p_debug=>G_Debug);
  END Reset_Table_Usages;

  /*******
    Alter all the tables used to nologging, drop the indexes
  *******/
  PROCEDURE Set_Table_Usages IS
  BEGIN

    EXECUTE IMMEDIATE 'ALTER TABLE bil.bil_do_l1_ld_oppty_dly NOLOGGING';

    BIL_DO_UTIL_PKG.Write_Log(p_msg=>'BIL Table bil_do_l1_ld_oppty_dly altered to nologging', p_debug=>G_Debug);


  END Set_Table_Usages;

END BIL_DO_L1_LD_OPPTY_DLY_PKG;

/
