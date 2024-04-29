--------------------------------------------------------
--  DDL for Package Body BIL_DO_L1_BASE_GRP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIL_DO_L1_BASE_GRP_PKG" AS
/* $Header: bilgrl1b.pls 115.14 2002/01/29 13:55:58 pkm ship      $ */

  -- Global Variables and Constants
     -- G_Debug will be modified to TRUE programatically.
     -- when the parameter passed for P_debug is Y
     -- Once, this is set to TRUE, then the log file will be generated.
     -- Otherwise, log file will not be generated. Only the output file
     -- will be generated.
     G_Debug    VARCHAR2(1) := 'N';
     G_Trace    BOOLEAN := FALSE;
     G_Degree   NUMBER  := 4;

   -- Global variables for WHO variables and Concurrent program
     G_request_id    NUMBER;
     G_appl_id       NUMBER;
     G_program_id    NUMBER;
     G_user_id       NUMBER;
     G_login_id      NUMBER;

PROCEDURE Truncate_Table;

PROCEDURE Set_Table_Usages;

PROCEDURE Init_Globals;

PROCEDURE Insert_Parent_Data( ERRBUF           IN OUT VARCHAR2
                             ,RETCODE          IN OUT VARCHAR2
                             ,p_degree         IN     NUMBER);

PROCEDURE Insert_Hirarchial_Data( ERRBUF           IN OUT VARCHAR2
                                 ,RETCODE          IN OUT VARCHAR2
                                 ,p_group_id       IN     NUMBER
                                 ,p_level          IN     NUMBER
                                 ,p_degree         IN     NUMBER);

PROCEDURE Insert_From_Denorm(  ERRBUF           IN OUT VARCHAR2
                              ,RETCODE          IN OUT VARCHAR2
                              ,p_level          IN     NUMBER
                              ,p_degree         IN     NUMBER);

PROCEDURE Reset_Table_Usages;



/*******************************************************************
*Inserts data to the level equal to profile option value of
*BIL_DO_L1_GRP_AGGR_LVL.
*ERRBUFF:    error message returned by the proc
*RETCODE:    completion status of the procedure
*p_degree:   parallel degree
*p_debug:    debug mode (yes or no)
*p_trace:    trace mode (yes or no)
********************************************************************/
procedure collect_temp_data( ERRBUF        OUT VARCHAR2
                           , RETCODE       OUT VARCHAR2
                           , p_degree      IN  NUMBER   DEFAULT 4
                           , p_debug_mode  IN  VARCHAR2 DEFAULT 'N'
                           , p_trace_mode  IN  VARCHAR2 DEFAULT 'N'
                           ) is

  CURSOR lvl_cur(l_level number) is
    select child_sales_group_id, Hier_level
      from bil_do_l1_base_grp_temp
     where Hier_level = l_level;

 l_profile_option number := FND_PROFILE.VALUE('BIL_DO_L1_GRP_AGGR_LVL');
 /*Fetching the hirarchial level to which data need to be retrieved.*/
 l_counter number := 1;
BEGIN
   /*Initialize the globals*/
    RETCODE := 0;
    Init_Globals;
  -- Validate input parameters
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

    BIL_DO_UTIL_PKG.Write_Log(p_msg=>'Parameters for collect_temp_data - Debug: ' || p_debug_mode
          || '  Trace: ' || p_trace_mode
          || '  Parallel Degree: ' || TO_CHAR(G_Degree)
          || '  Profile Option: ' || TO_CHAR(l_profile_option), p_debug=>G_Debug);

/*Set table to nologging*/
Set_Table_Usages;
/*Truncate the table*/
BIL_DO_UTIL_PKG.Write_Log(p_msg=>'Truncating table', p_debug=>G_Debug);

Truncate_table;

/*insert all the parents*/
Insert_Parent_Data( ERRBUF    => ERRBUF
                   ,RETCODE   => RETCODE
                   ,p_degree  => p_degree);

 /*Loops till it equals the hirarchial level*/
 while(l_counter < l_profile_option)
  loop
   for j in lvl_cur(l_counter)/*fetches and loops sales groups at level l_counter*/
   loop
     Insert_Hirarchial_Data( ERRBUF      => ERRBUF
                            ,RETCODE     => RETCODE
                            ,p_group_id  => j.child_sales_group_id
                            ,p_level     => l_counter
                            ,p_degree    => p_degree); -- inserting values for level (l_Counter+1)
     if (lvl_cur%notfound)  then
       exit;
     end if;
   end loop;--for loop
   l_counter := l_counter + 1;
  end loop; --while loop

  /*Inserting the last level of data into the table*/
 insert_from_denorm(  ERRBUF      => ERRBUF
                     ,RETCODE     => RETCODE
                     ,p_level     => l_profile_option
                     ,p_degree    => p_degree);

 /*Analyze the table after insertion*/
 BIL_DO_UTIL_PKG.Write_Log('Analyze table BIL_DO_L1_BASE_GRP_TEMP',p_debug=>G_Debug);
 DBMS_STATS.gather_table_stats(ownname=>'BIL', tabName=>'BIL_DO_L1_BASE_GRP_TEMP', cascade=>TRUE,
                                  degree=>G_Degree, estimate_percent=>99, granularity=>'GLOBAL');


 IF G_Trace THEN
    EXECUTE IMMEDIATE 'ALTER SESSION SET SQL_TRACE=FALSE';
 END IF;
Reset_Table_usages;
EXCEPTION
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ERRBUF := ERRBUF||'Error in collect_temp_data:'||to_char(sqlcode)||sqlerrm;
          RETCODE := '2' ;
          BIL_DO_UTIL_PKG.Write_Log(
              p_msg => 'Error in Collect_Temp_Data:'||to_char(sqlcode)||sqlerrm
            , p_force => 'Y', p_debug => G_Debug);
          ROLLBACK;
          Reset_Table_Usages;


       WHEN OTHERS THEN
          ERRBUF := ERRBUF||'Error in Collect_Temp_Data:'||to_char(sqlcode)||sqlerrm;
          RETCODE := '2';
          BIL_DO_UTIL_PKG.Write_Log(
              p_msg => 'Error in Collect_Temp_Data:'||to_char(sqlcode)||sqlerrm
            , p_force => 'Y', p_debug => G_Debug);
          ROLLBACK;
          Reset_table_Usages;
END collect_temp_data;

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



 /**************************************************************
 * Insert_parent_data inserts all the top level
 *salesgroups(parents) as hier_level=1 in the table
 ***************************************************************/

 PROCEDURE Insert_Parent_Data( ERRBUF           IN OUT VARCHAR2
                             ,RETCODE          IN OUT VARCHAR2
                             ,p_degree         IN     NUMBER)IS
 l_sysdate DATE := sysdate;
 l_level NUMBER := 1;

 l_insert_statement VARCHAR2(1000);
 l_select_statement VARCHAR2(5000);
 l_quote            VARCHAR2(1) :=  FND_GLOBAL.LOCAL_CHR(39); -- single quote
 l_parent_group     VARCHAR2(50) := 'PARENT_GROUP';
 l_sales            VARCHAR2(20) := 'SALES';
 l_stime            DATE := sysdate;
 BEGIN
 l_insert_statement := 'INSERT INTO  /*+ APPEND PARALLEL(bgt,'||p_degree||') */ bil_do_l1_base_grp_temp bgt';
 l_insert_statement := l_insert_statement||'( child_sales_group_id,sales_group_id,Hier_level,creation_date,created_by';
 l_insert_statement := l_insert_statement||',last_update_date,last_updated_by,last_update_login,request_id';
 l_insert_statement := l_insert_statement||',program_application_id,program_id,program_update_date)   ';

 l_select_statement :=' (SELECT  group_id,group_id, :l_level, :l_sysdate, :G_user_id, :l_sysdate, :G_user_id, :G_login_id';
 l_select_statement :=l_select_statement||' , :G_request_id, :G_appl_id, :G_program_id, :l_sysdate  FROM  ';

 l_select_statement :=l_select_statement||' ( SELECT /*+ Parallel(REL,'||p_degree||') */  distinct REL.related_grouP_id group_id ';
 l_select_statement :=l_select_statement||'     FROM jtf_rs_grp_relations REL, jtf_rs_group_usages usg ';
 l_select_statement :=l_select_statement||'    WHERE relation_type = :l_parent_group AND related_group_id not in ';
 l_select_statement :=l_select_statement||'         (SELECT group_id FROM apps.jtf_rs_grp_relations) ';
 l_select_statement :=l_select_statement||'      AND (start_date_active <= :l_sysdate OR start_date_active IS NULL) ';
 l_select_statement :=l_select_statement||'      AND (end_date_active > :l_sysdate OR end_date_active IS NULL) ';
 l_select_statement :=l_select_statement||'      AND usg.group_id = REL.related_group_id    AND usg.Usage = :l_sales))';


 EXECUTE IMMEDIATE l_insert_statement||l_select_statement
 USING
    l_level
   ,l_sysdate
   ,G_user_id
   ,l_sysdate
   ,G_user_id
   ,G_login_id
   ,G_request_id
   ,G_appl_id
   ,G_program_id
   ,l_sysdate
   ,l_parent_group
   ,l_sysdate
   ,l_sysdate
   ,l_sales;

 COMMIT;
 IF (SQL%ROWCOUNT = 0) THEN
      BIL_DO_UTIL_PKG.Write_Log(p_msg=>'No Rows are inserted from Insert_parent_data',p_stime=>l_stime,p_etime=>SYSDATE, p_force=>'Y',p_debug=>G_Debug);
 END IF;
 BIL_DO_UTIL_PKG.Write_Log(p_msg=>'Rows Inserted from Insert_parent_data:'||SQL%ROWCOUNT,p_stime=>l_stime,p_etime=>SYSDATE, p_debug=>G_Debug);
 EXCEPTION
      WHEN OTHERS THEN
        ERRBUF := ERRBUF ||' Insert_Parent_Data:'||sqlcode||' '|| sqlerrm;
        RETCODE := '2';
         ROLLBACK;
        BIL_DO_UTIL_PKG.Write_Log(p_msg=>' Insert_Parent_Data:'||sqlcode||' '|| sqlerrm
           , p_force=> 'Y', p_debug => G_Debug);

END Insert_Parent_Data;

/**********************************************
*insert_hirarchial_data is used to insert hirarchial
*data up to the level specified in profile_option
*starting from top.
*@p_level - Determines which level of data is being inserted.
*@Group_id - Sales_group_id
***********************************************/
procedure Insert_Hirarchial_Data( ERRBUF           IN OUT VARCHAR2
                                 ,RETCODE          IN OUT VARCHAR2
                                 ,p_group_id       IN     NUMBER
                                 ,p_level          IN     NUMBER
                                 ,p_degree         IN     NUMBER) is
l_level NUMBER := 0;
l_sysdate DATE := sysdate;

l_insert_statement VARCHAR2(1000);
l_select_statement VARCHAR2(5000);
l_quote            VARCHAR2(1) :=  FND_GLOBAL.LOCAL_CHR(39); -- single quote
l_relation_type    VARCHAR2(20) := 'PARENT_GROUP';
l_delete_flag_y    VARCHAR2(1) := 'Y';
l_delete_flag_n    VARCHAR2(1) := 'N';
l_sales            VARCHAR2(20) := 'SALES';
l_stime            DATE := sysdate;
BEGIN
 /* inserting data for the given level */
l_level := p_level + 1;
l_insert_statement := 'INSERT INTO  /*+ APPEND PARALLEL(bgt,'||p_degree||') */ bil_do_l1_base_grp_temp bgt';
l_insert_statement := l_insert_statement||' ( child_sales_group_id, sales_group_id, Hier_level, creation_date';
l_insert_statement := l_insert_statement||', created_by, last_update_date, last_updated_by, last_update_login';
l_insert_statement := l_insert_statement||', request_id, program_application_id, program_id, program_update_date)';

l_select_statement := '(SELECT /*+ PARALLEL(REL,'||p_degree||') */ REL.group_id';
l_select_statement := l_select_statement||'       ,REL.group_id, :l_level, :l_sysdate, :G_user_id';
l_select_statement := l_select_statement||'       ,:l_sysdate,:G_user_id,:G_login_id,:G_request_id';
l_select_statement := l_select_statement||'       ,:G_appl_id,:G_program_id,:l_sysdate';
l_select_statement := l_select_statement||'   FROM jtf_rs_grp_relations REL, jtf_rs_group_usages usg ';
l_select_statement := l_select_statement||'  WHERE REL.relation_type = :l_relation_type';
l_select_statement := l_select_statement||'    AND (REL.start_date_active <= :l_sysdate OR REL.start_date_active is null)';
l_select_statement := l_select_statement||'    AND (REL.end_date_active >= :l_sysdate OR REL.end_date_active is null)';
l_select_statement := l_select_statement||'    AND NVL(rel.delete_flag, :l_delete_flag_n) <> :l_delete_flag_y';
l_select_statement := l_select_statement||'    AND rel.group_id <> :p_group_id AND rel.related_group_id = :p_group_id ';
l_select_statement := l_select_statement||'    AND rel.group_id = usg.group_id AND usg.usage = :l_sales) ';

EXECUTE IMMEDIATE l_insert_statement||l_select_statement
USING
     l_level
    ,l_sysdate
    ,G_user_id
    ,l_sysdate
    ,G_user_id
    ,G_login_id
    ,G_request_id
    ,G_appl_id
    ,G_program_id
    ,l_sysdate
    ,l_relation_type
    ,l_sysdate
    ,l_sysdate
    ,l_delete_flag_n
    ,l_delete_flag_y
    ,p_group_id
    ,p_group_id
    ,l_sales;

COMMIT;
 IF (SQL%ROWCOUNT = 0) THEN
      BIL_DO_UTIL_PKG.Write_Log(p_msg=>'No Rows are inserted from Insert_Hirarchial_Data',p_stime=>l_stime,p_etime=>SYSDATE, p_force=>'Y',p_debug=>G_Debug);
 END IF;

 BIL_DO_UTIL_PKG.Write_Log(p_msg=>'Rows Inserted from Insert_Hirarchial_Data:'||SQL%ROWCOUNT,p_stime=>l_stime,p_etime=>SYSDATE, p_debug=>G_Debug);

EXCEPTION
      WHEN OTHERS THEN
        ERRBUF := ERRBUF ||' Insert_Hirarchial_Data:'||sqlcode||' '|| sqlerrm;
         RETCODE := '2';
         ROLLBACK;
      BIL_DO_UTIL_PKG.Write_Log(p_msg=>' Insert_Hirarchial_Data:'||sqlcode||' '|| sqlerrm
           , p_force=> 'Y', p_debug => G_Debug);

end insert_hirarchial_data;

/*****************************************************************************************************
*
*insert_from_denorm is used insert data from jtf_rs_groups_denorm table from hirarchial level=p_level.
*@p_group_id - Group_id which needs to be inserted along with all its children.
*
******************************************************************************************************/
procedure Insert_From_Denorm(  ERRBUF           IN OUT VARCHAR2
                              ,RETCODE          IN OUT VARCHAR2
                              ,p_level          IN     NUMBER
                              ,p_degree         IN     NUMBER) is
l_level number := 0;
l_sysdate DATE := sysdate;

l_insert_statement VARCHAR2(1000);
l_select_statement VARCHAR2(5000);
l_quote            VARCHAR2(1) :=  FND_GLOBAL.LOCAL_CHR(39); -- single quote
l_sales            VARCHAR2(20) := 'SALES';
l_stime            DATE := sysdate;
BEGIN
l_level := p_level + 1;

l_insert_statement := 'INSERT INTO  /*+ APPEND PARALLEL(bgt,'||p_degree||') */ bil_do_l1_base_grp_temp bgt';
l_insert_statement := l_insert_statement||' ( child_sales_group_id, sales_group_id, Hier_level, creation_date';
l_insert_statement := l_insert_statement||', created_by, last_update_date, last_updated_by, last_update_login';
l_insert_statement := l_insert_statement||', request_id, program_application_id, program_id, program_update_date)';

l_select_statement :=' (select /*+ PARALLEL(den,'||p_degree||') */  distinct den.group_id';
l_select_statement :=l_select_statement||' , den.parent_group_id, :l_level, :l_sysdate, :G_user_id, :l_sysdate';
l_select_statement :=l_select_statement||' , :G_user_id, :G_login_id, :G_request_id, :G_appl_id';
l_select_statement :=l_select_statement||' , :G_program_id, :l_sysdate';
l_select_statement :=l_select_statement||' from jtf_rs_groups_denorm den, jtf_rs_group_usages usg ';
l_select_statement :=l_select_statement||' where den.parent_group_id in ';
l_select_statement :=l_select_statement||'     (select child_sales_group_id from bil_do_l1_base_grp_temp';
l_select_statement :=l_select_statement||'       where Hier_level = :p_level)';
l_select_statement :=l_select_statement||'  and (den.start_date_active <= :l_sysdate OR den.start_date_active is null)';
l_select_statement :=l_select_statement||'  and (den.end_date_active >= :l_sysdate OR den.End_date_active is null)';
l_select_statement :=l_select_statement||'  and den.parent_group_id <> den.group_id AND usg.group_id = den.group_id  AND usg.usage = :l_sales)';

EXECUTE IMMEDIATE l_insert_statement||l_select_statement
  USING
     l_level
    ,l_sysdate
    ,G_user_id
    ,l_sysdate
    ,G_user_id
    ,G_login_id
    ,G_request_id
    ,G_appl_id
    ,G_program_id
    ,l_sysdate
    ,p_level
    ,l_sysdate
    ,l_sysdate
    ,l_sales;

COMMIT;
 IF (SQL%ROWCOUNT = 0) THEN
      BIL_DO_UTIL_PKG.Write_Log(p_msg=>'No Rows are inserted from Insert_From_Denorm',p_stime=>l_stime,p_etime=>SYSDATE, p_force=>'Y',p_debug=>G_Debug);
 END IF;

 BIL_DO_UTIL_PKG.Write_Log(p_msg=>'Rows Inserted from Insert_From_Denorm:'||SQL%ROWCOUNT,p_stime=>l_stime,p_etime=>SYSDATE, p_debug=>G_Debug);
EXCEPTION
      WHEN OTHERS THEN
        ERRBUF := ERRBUF ||' Insert_From_Denorm:'||sqlcode||' '|| sqlerrm;
        RETCODE := '2';
         ROLLBACK;
        BIL_DO_UTIL_PKG.Write_Log(p_msg=>' Insert_From_Denorm:'||sqlcode||' '|| sqlerrm
           , p_force=> 'Y',p_debug => G_Debug);

END Insert_From_Denorm;

/*******************
*Truncate the table
*******************/
PROCEDURE Truncate_table is
BEGIN
  EXECUTE IMMEDIATE 'truncate table bil.bil_do_l1_base_grp_temp';
 BIL_DO_UTIL_PKG.Write_Log(p_msg=>'BIL Table bil_do_l1_base_grp_temp is truncated',p_debug=>G_Debug);
END;

/*************************
*Alter tables to logging
*************************/
PROCEDURE Reset_Table_Usages IS
BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE bil.bil_do_l1_base_grp_temp LOGGING';
    BIL_DO_UTIL_PKG.Write_Log(p_msg=>'BIL Table bil_do_l1_base_grp_temp altered to logging', p_debug=>G_Debug);
END Reset_Table_Usages;

  /***********************************************************
  *  Alter all the tables used to nologging, drop the indexes
  ***********************************************************/
  PROCEDURE Set_Table_Usages IS
  BEGIN

    EXECUTE IMMEDIATE 'ALTER TABLE bil.bil_do_l1_base_grp_temp NOLOGGING';

    BIL_DO_UTIL_PKG.Write_Log(p_msg=>'BIL Table bil_do_l1_base_grp_temp altered to nologging',p_debug=>G_Debug);

  END Set_Table_Usages;

END BIL_DO_L1_BASE_GRP_PKG;

/
