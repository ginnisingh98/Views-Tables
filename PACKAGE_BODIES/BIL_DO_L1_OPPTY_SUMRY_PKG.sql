--------------------------------------------------------
--  DDL for Package Body BIL_DO_L1_OPPTY_SUMRY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIL_DO_L1_OPPTY_SUMRY_PKG" AS
/* $Header: bilopl1b.pls 115.18 2002/01/29 23:03:50 pkm ship      $ */
     -- Global Variables and Constants
     -- G_Debug will be modified to TRUE programatically.
     -- when the parameter passed for P_debug is Y
     -- Once, this is set to TRUE, then the log file will be generated.
     -- Otherwise, log file will not be generated. Only the output file
     -- will be generated.
     G_Debug    VARCHAR2(1) := 'N';
     G_Trace    BOOLEAN := FALSE;
     G_Degree   NUMBER  := 4;
     G_Truncate VARCHAR2(1) := 'N';
   -- Global variables for WHO variables and Concurrent program
     G_request_id    NUMBER;
     G_appl_id       NUMBER;
     G_program_id    NUMBER;
     G_user_id       NUMBER;
     G_login_id      NUMBER;

PROCEDURE Delete_table( ERRBUF           IN OUT VARCHAR2
                       ,RETCODE          IN OUT VARCHAR2
                       ,p_date           IN     DATE);

PROCEDURE Truncate_Table;

PROCEDURE Set_Table_Usages;

PROCEDURE Init_Globals;

PROCEDURE Refresh_Data_Day( ERRBUF        OUT VARCHAR2
                           , RETCODE       OUT VARCHAR2
                           , p_collection_date IN VARCHAR2
                           , p_degree      IN  NUMBER   DEFAULT 4
                           , p_debug_mode  IN  VARCHAR2 DEFAULT 'N'
                           );

PROCEDURE Insert_Data( ERRBUF           IN OUT VARCHAR2
                      ,RETCODE          IN OUT VARCHAR2
                      ,p_degree         IN     NUMBER
                      ,p_collect_date   IN     DATE);

PROCEDURE Reset_Table_Usages;
PROCEDURE Refresh_Date_Range(ERRBUF      OUT  VARCHAR2
                            ,RETCODE      OUT  VARCHAR2
                            ,p_start_date IN DATE
                            ,p_end_date IN DATE
                            ,p_degree      IN  NUMBER   DEFAULT 4
                            ,p_truncate_flag IN VARCHAR2 DEFAULT 'N'
                            ,p_debug_mode  IN  VARCHAR2 DEFAULT 'N'
                            ,p_trace_mode  IN  VARCHAR2 DEFAULT 'N'
                           ) ;

PROCEDURE Refresh_Data( ERRBUF       OUT VARCHAR2
                      ,RETCODE       OUT VARCHAR2
                      ,p_degree      IN  NUMBER   DEFAULT 4
                      ,p_debug_mode  IN  VARCHAR2 DEFAULT 'N'
                      ,p_trace_mode  IN  VARCHAR2 DEFAULT 'N'
                      ) is

  l_collection_date_start date;
  l_collection_date_end date;
  l_day_count number;
  l_rec_count number;
BEGIN
  -- Start and end will be yesterday's date
  l_collection_date_end := trunc(sysdate-1);
  l_collection_date_start := l_collection_date_end;
  -- Look for first missing collection date in table;
  select max(collection_date)+1
    into l_collection_date_start
    from BIL_DO_L1_OPPTY_SUMRY;
  -- Just do for sysdate-1 if nothing exists or data already
  -- exists for sysdate
  if l_collection_date_start is null
      or l_collection_date_start > l_collection_date_end then
    l_collection_date_start := l_collection_date_end;
  end if;
    BIL_DO_UTIL_PKG.Write_Log(p_msg=>'Parameters for Refresh_Data - Debug: ' || p_debug_mode
          || '  Trace: ' || p_trace_mode
          || '  Parallel Degree: ' || TO_CHAR(p_Degree),p_debug => p_Debug_mode);

      Refresh_Date_Range( ERRBUF          => ERRBUF
                         ,RETCODE         => RETCODE
                         ,p_start_date    => l_collection_date_start
                         ,p_end_date    => l_collection_date_end
                         ,p_degree        => p_degree
                         ,p_truncate_flag => 'N'
                         ,p_debug_mode    => p_debug_mode
                         ,p_trace_mode    => p_trace_mode);
 EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ERRBUF := ERRBUF||'Error in Refresh_Data:'||to_char(sqlcode)||sqlerrm;
          RETCODE := '2' ;
          BIL_DO_UTIL_PKG.Write_Log(
              p_msg => 'Error in Refresh_Data:'||to_char(sqlcode)||sqlerrm
            , p_force => 'Y',p_debug =>G_Debug);
          ROLLBACK;
          Reset_Table_Usages;

       WHEN OTHERS THEN
          ERRBUF := ERRBUF||'Error in Refresh_Data:'||to_char(sqlcode)||sqlerrm;
          RETCODE := '2';
          BIL_DO_UTIL_PKG.Write_Log(
              p_msg => 'Error in Refresh_Data:'||to_char(sqlcode)||sqlerrm
            , p_force => 'Y',p_debug =>G_Debug);
          ROLLBACK;
          Reset_table_Usages;
END Refresh_Data;


PROCEDURE Refresh_Data_Range(ERRBUF      OUT  VARCHAR2
                            ,RETCODE      OUT  VARCHAR2
                            ,p_start_date IN VARCHAR2
                            ,p_end_date IN VARCHAR2
                            ,p_degree      IN  NUMBER   DEFAULT 4
                            ,p_truncate_flag IN VARCHAR2 DEFAULT 'N'
                            ,p_debug_mode  IN  VARCHAR2 DEFAULT 'N'
                            ,p_trace_mode  IN  VARCHAR2 DEFAULT 'N'
                           ) is
  l_collection_date_start date;
  l_date_format VARCHAR2(50) := 'YYYY-MM-DD HH24:MI:SS';
  l_collection_date_end date;
BEGIN
  l_collection_date_start := to_date(p_start_date, l_date_format);
  l_collection_date_end := to_date(p_end_date, l_date_format);

  Refresh_Date_Range( ERRBUF          => ERRBUF
                     ,RETCODE         => RETCODE
                     ,p_start_date    => l_collection_date_start
                     ,p_end_date      => l_collection_date_end
                     ,p_degree        => p_degree
                     ,p_truncate_flag => p_truncate_flag
                     ,p_debug_mode    => p_debug_mode
                     ,p_trace_mode    => p_trace_mode);

END Refresh_data_Range;

PROCEDURE Refresh_Date_Range(ERRBUF      OUT  VARCHAR2
                            ,RETCODE      OUT  VARCHAR2
                            ,p_start_date IN DATE
                            ,p_end_date IN DATE
                            ,p_degree      IN  NUMBER   DEFAULT 4
                            ,p_truncate_flag IN VARCHAR2 DEFAULT 'N'
                            ,p_debug_mode  IN  VARCHAR2 DEFAULT 'N'
                            ,p_trace_mode  IN  VARCHAR2 DEFAULT 'N'
                           ) is
  l_collection_date_start date;
  l_collection_date_end date;
  l_day_count number;
  l_rec_count0 number;
  l_rec_count number;

BEGIN
  l_collection_date_start := p_start_date;
  l_collection_date_end := p_end_date;
  l_day_count := l_collection_date_end-l_collection_date_start+1;

  /*Set table to nologging*/
  Set_Table_Usages;

  IF p_debug_mode = 'Y' THEN
     G_Debug := 'Y';
  END IF;

  IF (p_truncate_flag = 'Y') THEN
    G_Truncate := 'Y';
    Truncate_Table;
  END IF;
  --Initialize the global variables.
      Init_Globals;
      RETCODE := 0;
--Validate the input Parameters.
      IF p_debug_mode = 'Y' THEN
         G_Debug := 'Y';
      END IF;

      IF p_trace_mode = 'Y' THEN
         G_Trace := TRUE;
         EXECUTE IMMEDIATE 'ALTER SESSION SET SQL_TRACE=TRUE';
      END IF;

      IF NVL(p_degree,0) > 0 THEN
        G_Degree := p_degree;
      END IF;

  if l_day_count > 0 then
    for i in 1..l_day_count LOOP
       Refresh_Data_Day( ERRBUF            => ERRBUF
                        ,RETCODE           => RETCODE
                        ,p_collection_date => to_char(l_collection_date_start)
                        ,p_degree          => G_Degree
                        ,p_debug_mode      => G_Debug);
      l_collection_date_start := l_collection_date_start + 1;
    end loop;
  end if;

 /*Analyze the table after insertion*/
 BIL_DO_UTIL_PKG.Write_Log('Analyze table BIL_DO_L1_OPPTY_SUMRY',p_debug => p_debug_mode);
 DBMS_STATS.gather_table_stats(ownname=>'BIL', tabName=>'BIL_DO_L1_OPPTY_SUMRY', cascade=>TRUE,
                                  degree=>G_Degree, estimate_percent=>99, granularity=>'GLOBAL');


 IF G_Trace THEN
    EXECUTE IMMEDIATE 'ALTER SESSION SET SQL_TRACE=FALSE';
 END IF;
 Reset_Table_Usages;
 BIL_DO_UTIL_PKG.Write_Log(p_msg=>'Alter bil_do_l1_OPPTY_SUMRY table to noparallel', p_debug=>p_debug_mode);

 BIL_DO_UTIL_PKG.Write_Log(p_msg=>'End of Refresh_Date_Range  for Opportunity to Quote Bin', p_debug=>p_debug_mode);


EXCEPTION
    WHEN OTHERS THEN
     ERRBUF := ERRBUF||'Error in Refresh_Date_Range:'||to_char(sqlcode)||sqlerrm;
     RETCODE := '2';
     BIL_DO_UTIL_PKG.Write_Log(
           p_msg => 'Error in Refresh_Date_Range:'||to_char(sqlcode)||sqlerrm
          , p_force => 'Y',p_debug =>G_Debug);
     ROLLBACK;
END Refresh_date_Range;

/*******************************************************************
*ERRBUFF:    error message returned by the proc
*RETCODE:    completion status of the procedure
*p_degree:   parallel degree
*p_debug:    debug mode (yes or no)
*p_trace:    trace mode (yes or no)
********************************************************************/
PROCEDURE Refresh_Data_Day( ERRBUF        OUT VARCHAR2
                           , RETCODE       OUT VARCHAR2
                           , p_collection_date IN varchar2
                           , p_degree      IN  NUMBER   DEFAULT 4
                           , p_debug_mode  IN  VARCHAR2 DEFAULT 'N'
                           ) is
l_collection_date date;
BEGIN
l_collection_date := to_date(p_collection_date);

/*Delete the existing records for the same collect_date from the table*/
IF (G_Truncate = 'N') THEN
BIL_DO_UTIL_PKG.Write_Log(p_msg=>'Delete Data for collection date: ' || TO_CHAR(l_collection_date, 'DD-MON-YYYY'), p_debug=>p_debug_mode);
    Delete_table( ERRBUF      => ERRBUF
                 ,RETCODE     => RETCODE
                 ,p_date      => l_collection_date);
END IF;

BIL_DO_UTIL_PKG.Write_Log(p_msg=>'Insert Data for collection date: ' || TO_CHAR(l_collection_date, 'DD-MON-YYYY'), p_debug=>p_debug_mode);
 /*Calling the insert procedure for inserting data to the table.*/
Insert_Data( ERRBUF         => ERRBUF
            ,RETCODE        => RETCODE
            ,p_degree       => p_degree
            ,p_collect_date => l_collection_date);

 EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ERRBUF := ERRBUF||'Error in Refresh_Data_Day:'||to_char(sqlcode)||sqlerrm;
          RETCODE := '2' ;
          BIL_DO_UTIL_PKG.Write_Log(
              p_msg => 'Error in Refresh_Data:'||to_char(sqlcode)||sqlerrm
            , p_force => 'Y',p_debug =>G_Debug);
          ROLLBACK;
          Reset_Table_Usages;

       WHEN OTHERS THEN
          ERRBUF := ERRBUF||'Error in Refresh_Data_Day:'||to_char(sqlcode)||sqlerrm;
          RETCODE := '2';
          BIL_DO_UTIL_PKG.Write_Log(
              p_msg => 'Error in Refresh_Data_Day:'||to_char(sqlcode)||sqlerrm
            , p_force => 'Y',p_debug =>G_Debug);
          ROLLBACK;
          Reset_table_Usages;
END Refresh_Data_Day;

/********************************************************************
*Initialize Global variables for WHO variables and Concurrent program
*********************************************************************/
 PROCEDURE Init_Globals IS

 BEGIN
     G_request_id    := FND_GLOBAL.CONC_REQUEST_ID();
     G_appl_id       := FND_GLOBAL.PROG_APPL_ID();
     G_program_id    := FND_GLOBAL.CONC_PROGRAM_ID();
     G_user_id       := FND_GLOBAL.USER_ID();
     G_login_id      := FND_GLOBAL.CONC_LOGIN_ID();
 END Init_Globals;


/**********************************************
*Insert_Data
***********************************************/
PROCEDURE Insert_Data( ERRBUF           IN OUT VARCHAR2
                      ,RETCODE          IN OUT VARCHAR2
                      ,p_degree         IN     NUMBER
                      ,p_collect_date   IN     DATE) IS

/*Strings for Dynamic sql*/
l_insert_string VARCHAR2(1000) := '';
l_select_string VARCHAR2(5000) := '';
l_quote VARCHAR2(1) :=  FND_GLOBAL.LOCAL_CHR(39); -- single quote

/*Bind variables*/
l_collection_date DATE ;--:= trunc(sysdate-1);
l_period_type     VARCHAR2(50) := FND_PROFILE.VALUE('AS_FORECAST_CALENDAR');
l_credit_type     VARCHAR2(50) := FND_PROFILE.VALUE('ASF_DEFAULT_FORECAST_CREDIT_TYPE');
l_delete_flag     VARCHAR2(1)  := 'N';
l_enabled_flag    VARCHAR2(1)  := 'Y';
l_sysdate         DATE := sysdate;

l_stime DATE := sysdate;
BEGIN
 l_collection_date := p_collect_date;
 l_insert_string := 'INSERT INTO BIL_DO_L1_OPPTY_SUMRY( COLLECTION_DATE';
 l_insert_string :=  l_insert_string|| ', SALES_GROUP_ID, PERIOD_NAME, PERIOD_TYPE, WON_AMOUNT, OPEN_AMOUNT';
 l_insert_string :=  l_insert_string|| ', WEIGHTED_OPEN_AMOUNT, FORECAST_AMOUNT, LAST_UPDATE_DATE, LAST_UPDATED_BY';
 l_insert_string :=  l_insert_string|| ', CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN, REQUEST_ID';
 l_insert_string :=  l_insert_string||', PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE) ';

l_select_string := '(SELECT /*+  use_hash(bdlbgt den) Parallel(den,'|| p_degree||')*/ :l_collection_date, bdlbgt.sales_group_id, pd.period_name, pd.period_type';
l_select_string := l_select_string||',sum(decode(nvl(den.WIN_LOSS_INDICATOR,'||l_quote||'N'||l_quote||')';
l_select_string := l_select_string||'||nvl(den.OPP_OPEN_STATUS_FLAG,'||l_quote||'Y'||l_quote||'),';
l_select_string := l_select_string||l_quote||'WN'||l_quote||',den.c1_WON_AMOUNT,0))';
l_select_string := l_select_string||',sum(decode(nvl(den.WIN_LOSS_INDICATOR,'||l_quote||'N'||l_quote||')';

l_select_string := l_select_string||'||nvl(den.OPP_OPEN_STATUS_FLAG,'||l_quote||'Y'||l_quote||'),';
l_select_string := l_select_string||l_quote||'NY'||l_quote||',den.c1_SALES_CREDIT_AMOUNT, 0))';

l_select_string := l_select_string||',sum(decode(nvl(den.WIN_LOSS_INDICATOR,'||l_quote||'N'||l_quote||')';
l_select_string := l_select_string||'||nvl(den.OPP_OPEN_STATUS_FLAG,'||l_quote||'Y'||l_quote||'),';

l_select_string := l_select_string||l_quote||'NY'||l_quote||',den.c1_SALES_CREDIT_AMOUNT*den.WIN_PROBABILITY/100.00, 0))';
l_select_string := l_select_string||',null,:l_sysdate,:G_user_id,:l_sysdate,:G_user_id,:G_login_id,:G_request_id';
l_select_string := l_select_string||',:G_appl_id,:G_program_id,:l_sysdate';

l_select_string := l_select_string||' FROM  as_sales_credits_denorm den, bil_do_l1_base_grp_temp bdlbgt,as_period_days pd';

l_select_string := l_select_string||' WHERE pd.start_date <= den.decision_date  AND pd.end_date >= den.decision_date';
l_select_string := l_select_string||'   AND pd.period_set_name = :l_period_type AND den.sales_group_id = bdlbgt.child_sales_group_id';

l_select_string := l_select_string||'   AND pd.period_day = :l_collection_date ';

l_select_string := l_select_string||'   AND den.credit_type_id = :l_credit_type  AND den.OPP_DELETED_FLAG = :l_delete_flag';
l_select_string := l_select_string||'   AND den.status_code in (SELECT  STATUS_CODE FROM as_statuses_b ';
l_select_string := l_select_string||'       WHERE  enabled_flag = :l_enabled_flag and opp_flag = :l_enabled_flag) ';
l_select_string := l_select_string||'   AND den.sales_stage_id in (SELECT sales_stage_id FROM as_sales_stages_all_b ';
l_select_string := l_select_string||'       WHERE enabled_flag = :l_enabled_flag ';
l_select_string := l_select_string||'         AND sysdate between start_date_active and nvl(end_date_active,sysdate))';
l_select_string := l_select_string||'   AND den.interest_type_id in (SELECT interest_type_id FROM as_interest_types_b ';
l_select_string := l_select_string||'       WHERE enabled_flag = :l_enabled_flag AND expected_purchase_flag = :l_enabled_flag)';
l_select_string := l_select_string||' GROUP BY  bdlbgt.sales_group_id,pd.period_name,pd.period_type)';

 EXECUTE IMMEDIATE l_insert_string||l_select_string
 USING
     l_collection_date
    ,l_sysdate
    ,G_user_id
    ,l_sysdate
    ,G_user_id
    ,G_login_id
    ,G_request_id
    ,G_appl_id
    ,G_program_id
    ,l_sysdate
    ,l_period_type
    ,l_collection_date
    ,l_credit_type
    ,l_delete_flag
    ,l_enabled_flag
    ,l_enabled_flag
    ,l_enabled_flag
    ,l_enabled_flag
    ,l_enabled_flag;

COMMIT;
 IF (SQL%ROWCOUNT = 0) THEN
      BIL_DO_UTIL_PKG.Write_Log(p_msg=>'No Rows are inserted from Insert_data',p_stime=>l_stime,p_etime=>SYSDATE, p_force=>'Y',p_debug=>G_Debug);
      RETCODE := 1;
 END IF;

BIL_DO_UTIL_PKG.Write_Log(p_msg=>'     Rows Inserted:'||SQL%ROWCOUNT,p_stime=>l_stime,p_etime=>SYSDATE, p_debug=>G_Debug);

EXCEPTION
      WHEN OTHERS THEN
        ERRBUF := ERRBUF ||' Insert_Data:'||sqlcode||' '|| sqlerrm;
         RETCODE := '2';
      BIL_DO_UTIL_PKG.Write_Log(p_msg=>' Insert_Data:'||sqlcode||' '|| sqlerrm
           , p_force=> 'Y',p_debug=>G_Debug);
        Reset_Table_Usages;
end Insert_Data;

/*************************************************************
*Delete_table is used to Delete existing records
*from BIL Table BIL_DO_L1_OPPTY_SUMRY for the collection_date.
**************************************************************/
PROCEDURE Delete_table( ERRBUF           IN OUT VARCHAR2
                       ,RETCODE          IN OUT VARCHAR2
                       ,p_date           IN     DATE) IS
 l_date DATE := p_date;
BEGIN
 DELETE FROM BIL_DO_L1_OPPTY_SUMRY
  WHERE collection_date = l_date;
 BIL_DO_UTIL_PKG.Write_Log(p_msg=>'Deleted records from BIL Table BIL_DO_L1_OPPTY_SUMRY',p_debug=>G_Debug);
 EXCEPTION
  WHEN NO_DATA_FOUND THEN
    null;
  WHEN OTHERS THEN
    ERRBUF := ERRBUF ||' Delete_Data:'||sqlcode||' '|| sqlerrm;
    RETCODE := '1';
END;

/*******
*Alter tables to logging
*********/
PROCEDURE Reset_Table_Usages IS
BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE BIL.BIL_DO_L1_OPPTY_SUMRY LOGGING';
    BIL_DO_UTIL_PKG.Write_Log('BIL Table BIL_DO_L1_OPPTY_SUMRY altered to logging',p_debug=>G_Debug);
END Reset_Table_Usages;


/*******************
*Truncate the table
*******************/
PROCEDURE Truncate_table is
BEGIN
  EXECUTE IMMEDIATE 'truncate table bil.bil_do_l1_oppty_sumry';
 BIL_DO_UTIL_PKG.Write_Log(p_msg=>'BIL Table bil_do_l1_oppty_sumry is truncated',p_debug=>G_Debug);
END;


/*******
*Alter all the tables used to nologging
*******/
PROCEDURE Set_Table_Usages IS
BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE BIL.BIL_DO_L1_OPPTY_SUMRY NOLOGGING';
    BIL_DO_UTIL_PKG.Write_Log('BIL Table BIL_DO_L1_OPPTY_SUMRY altered to nologging',p_debug=>G_Debug);
END Set_Table_Usages;

END BIL_DO_L1_OPPTY_SUMRY_PKG;

/
