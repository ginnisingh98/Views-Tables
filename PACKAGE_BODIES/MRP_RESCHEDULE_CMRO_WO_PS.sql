--------------------------------------------------------
--  DDL for Package Body MRP_RESCHEDULE_CMRO_WO_PS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_RESCHEDULE_CMRO_WO_PS" AS
/* $Header: MRPPSRELB.pls 120.6.12010000.6 2010/04/28 22:22:07 harshsha noship $ */
-- Global Variables

G_PKG_NAME VARCHAR2(30) := 'MRP_RESCHEDULE_CMRO_WO_PS';
G_group_id NUMBER;
g_dblink VARCHAR2(240);
var_buf			VARCHAR2(240);
var_proc 	VARCHAR2(240);
g_log_file_set BOOLEAN := FALSE;
g_log_file_name varchar2(240);
g_out_file_name varchar2(240);
g_output_dir VARCHAR2(240);
g_retcode number := 0;

PROCEDURE log_output( p_user_info IN VARCHAR2) IS
BEGIN
       FND_FILE.PUT_LINE(FND_FILE.OUTPUT, p_user_info);
EXCEPTION
   WHEN OTHERS THEN
   RAISE;
END log_output;


/****************************************************************************
   RESCHEDULE_CMRO_WO :
   This procedure accepts a group id and picks up all the work orders tobe
   processed and calls PROCESS_WO function for each work order
****************************************************************************/

PROCEDURE  RESCHEDULE_CMRO_WO(
              ERRBUF OUT NOCOPY VARCHAR2
              ,RETCODE OUT NOCOPY VARCHAR2
               ,P_DBLINK IN VARCHAR2
              ,P_GROUP_ID IN Number
              ,P_SR_INSTANCE_ID IN NUMBER)  IS
/*
    CURSOR WO_CUR (p_group_id IN NUMBER) IS
      SELECT DISTINCT WIP_ENTITY_ID ,ORGANIZATION_ID
      FROM MSC_WIP_JOB_SCHEDULE_INTERFACE
      WHERE group_id = p_group_id ;
*/
    WO_CUR_TBL  WO_ORG_TBL ;
    WO_CUR      CurTyp;
--    g_dblink VARCHAR2(28);
    lv_sql_stmt  VARCHAR2(2000) ;
    lv_update_stmt  VARCHAR2(2000) ;
    lv_wo_count number;
BEGIN

    var_proc :=  'RESCHEDULE_CMRO_WO' ;
    g_dblink := P_DBLINK;
    g_group_id := P_GROUP_ID;

    MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,
 '------------------- PS Release Log Start ------------------ ');

    MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,
                    'Updating msc_wip_job_schedule_interface to divide wip_entity_id /2');
    lv_update_stmt := 'UPDATE MSC_WIP_JOB_SCHEDULE_INTERFACE'||g_dblink||
                     ' SET WIP_ENTITY_ID = WIP_ENTITY_ID/2'||
                     ' WHERE GROUP_ID = '|| P_GROUP_ID;

    MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,
                     'lv_update_stmt is '||lv_update_stmt);
    EXECUTE IMMEDIATE lv_update_stmt;

    MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,
                    'Updating msc_wip_job_dtls_interface to divide wip_entity_id /2'||
                    'department_id/2 and resource_id_new/2');

    lv_update_stmt := 'UPDATE MSC_WIP_JOB_DTLS_INTERFACE'||g_dblink||
                     ' SET WIP_ENTITY_ID = WIP_ENTITY_ID/2,'||
                     ' DEPARTMENT_ID = DEPARTMENT_ID/2,'||
                     ' RESOURCE_ID_NEW = RESOURCE_ID_NEW/2'||
                     ' WHERE GROUP_ID = '||P_GROUP_ID;

    MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,
                     'lv_update_stmt is '||lv_update_stmt);
    EXECUTE IMMEDIATE lv_update_stmt;
    MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,
        'RESCHEDULE_CMRO_WO Called with Params  ' || ' DBLINK : '
         || P_DBLINK ||'   GROUP_ID: '||p_group_id );


    lv_sql_stmt :=  ' SELECT DISTINCT WIP_ENTITY_ID ,ORGANIZATION_ID '||
                    ' FROM MSC_WIP_JOB_SCHEDULE_INTERFACE'||g_dblink||
                    ' WHERE GROUP_ID = '||P_GROUP_ID;

    OPEN WO_CUR for lv_sql_stmt;

    FETCH WO_CUR  BULK COLLECT INTO WO_CUR_TBL ;
    lv_wo_count := WO_CUR%ROWCOUNT;
    MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'SQL rowcount of WO_CUR is '||lv_wo_count);
    MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'Number of records fetched into WO_CUR_TBL is '||WO_CUR_TBL.Count);
-- if count is > 0 Print report header and group_id
    IF (lv_wo_count > 0) THEN
      log_output(' Group ID: '||g_group_id);
      log_output('==================   ====================    ====================   =========== ');
      log_output('   CMRO Work Order    Start Date             Completion Date         Status     ');
      log_output('==================   ====================    ====================   =========== ');
    END IF;

    FOR y IN 1..WO_CUR_TBL.Count LOOP

         MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,
          ' Processing Job/Org : ' || WO_CUR_TBL(Y).WIP_ENTITY_ID ||'/'||
                                      WO_CUR_TBL(Y).ORGANIZATION_ID );
-- Print report header and group_id
        PROCESS_Single_WO(WO_CUR_TBL(Y).WIP_ENTITY_ID,
                          WO_CUR_TBL(Y).ORGANIZATION_ID);
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'After PROCESS_Single_WO and before Commit');
        COMMIT;
    END LOOP ;
    CLOSE WO_CUR;
--Set retcode to the value set by the process_single_wo requests
        RETCODE := g_retcode;
        IF (lv_wo_count > 0) THEN
            log_output('==================   ====================    ====================   =========== ');
        END IF;
--- for CMRO
        IF (NVL(fnd_profile.value('MSC_RETAIN_RELEASED_DATA'), 'N') ='N' )THEN

        lv_sql_stmt := 'DELETE msc_wip_job_schedule_interface'||g_dblink
                      ||' where sr_instance_id ='||  P_SR_INSTANCE_ID
                      ||' and nvl(group_id,-1) = nvl('||g_group_id||',-1)';
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1, lv_sql_stmt );

        EXECUTE IMMEDIATE lv_sql_stmt;
--using
--                           g_dblink,
--                           P_SR_INSTANCE_ID,
--                           g_group_id;

        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'After delete on msc_wip_job_schedule_interface'  );
        lv_sql_stmt := 'DELETE msc_wip_job_dtls_interface'||g_dblink
                      ||' where sr_instance_id =' || P_SR_INSTANCE_ID
                      ||' and nvl(group_id,-1) = nvl('||g_group_id||',-1)';
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1, lv_sql_stmt );

        EXECUTE IMMEDIATE lv_sql_stmt;
--using
--                           g_dblink,
--                           P_SR_INSTANCE_ID,
--                           g_group_id;

     END IF;

    MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,
 '------------------ PS Release Log End   ------------------- ');
  RETURN;

EXCEPTION
  WHEN OTHERS THEN
--    var_buf := var_proc||' 1: '||sqlerrm;
   --fnd_file.put_line(FND_FILE.LOG, var_buf);
    MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'Exception in Reschedule_CMRO_WO');
    ROLLBACK;
    RETCODE := 1;
    ERRBUF := var_buf;
    RETURN;

END RESCHEDULE_CMRO_WO;


/*****************************************************************************
   Process_Single_WO :
   This procedure accepts a wip entity id, and group id fetches the
   wo, op, res, material information
   into plsql tables and calls the eam api using these PL/SQL table of
   records
*****************************************************************************/
PROCEDURE  Process_Single_WO (
              V_WIP_ENTITY_ID IN NUMBER
             ,V_ORGANIZATION_ID IN NUMBER ) IS

    v_created_by number;
    v_updated_by number;

    -- WORK ORDERS TABLES
    L_EAM_WO_TBL EAM_PROCESS_WO_PUB.EAM_WO_TBL_TYPE /*:=
                                    EAM_PROCESS_WO_PUB.G_MISS_EAM_WO_TBL */;
    L_X_EAM_WO_TBL EAM_PROCESS_WO_PUB.EAM_WO_TBL_TYPE /*:=
                                    EAM_PROCESS_WO_PUB.G_MISS_EAM_WO_TBL */;

    -- OPERATIONS TABLES
    L_EAM_OP_TBL EAM_PROCESS_WO_PUB.EAM_OP_TBL_TYPE  /*:=
                                    EAM_PROCESS_WO_PUB.G_MISS_EAM_OP_TBL */;
    L_X_EAM_OP_TBL EAM_PROCESS_WO_PUB.EAM_OP_TBL_TYPE /*:=
                                    EAM_PROCESS_WO_PUB.G_MISS_EAM_OP_TBL  */;

    -- RESOURCE TABLES
    L_EAM_RES_TBL EAM_PROCESS_WO_PUB.EAM_RES_TBL_TYPE /*:=
                                    EAM_PROCESS_WO_PUB.G_MISS_EAM_RES_TBL */;
    L_X_EAM_RES_TBL EAM_PROCESS_WO_PUB.EAM_RES_TBL_TYPE /*:=
                                    EAM_PROCESS_WO_PUB.G_MISS_EAM_RES_TBL */;

    -- MATERIAL REQ TABLES
    L_EAM_MAT_TBL EAM_PROCESS_WO_PUB.EAM_MAT_REQ_TBL_TYPE /* :=
                                    EAM_PROCESS_WO_PUB.G_MISS_EAM_MAT_REQ_TBL*/;
    L_X_EAM_MAT_TBL EAM_PROCESS_WO_PUB.EAM_MAT_REQ_TBL_TYPE /*:=
                                    EAM_PROCESS_WO_PUB.G_MISS_EAM_MAT_REQ_TBL*/;


    -- OTHER TABLES
    L_EAM_WO_RELATIONS_TBL EAM_PROCESS_WO_PUB.EAM_WO_RELATIONS_TBL_TYPE /*:=
                              EAM_PROCESS_WO_PUB.G_MISS_EAM_WO_RELATIONS_TBL*/ ;
    L_EAM_OP_NETWORK_TBL EAM_PROCESS_WO_PUB.EAM_OP_NETWORK_TBL_TYPE /*:=
                               EAM_PROCESS_WO_PUB.G_MISS_EAM_OP_NETWORK_TBL */;
    L_EAM_RES_INST_TBL EAM_PROCESS_WO_PUB.EAM_RES_INST_TBL_TYPE /*:=
                               EAM_PROCESS_WO_PUB.G_MISS_EAM_RES_INST_TBL*/;
    L_EAM_RES_USAGE_TBL EAM_PROCESS_WO_PUB.EAM_RES_USAGE_TBL_TYPE;

    L_EAM_SUB_RES_TBL EAM_PROCESS_WO_PUB.EAM_SUB_RES_TBL_TYPE /*:=
                               EAM_PROCESS_WO_PUB.G_MISS_EAM_SUB_RES_TBL */;
    L_EAM_DIRECT_ITEMS_TBL EAM_PROCESS_WO_PUB.EAM_DIRECT_ITEMS_TBL_TYPE /*:=
                             EAM_PROCESS_WO_PUB.G_MISS_EAM_DIRECT_ITEMS_TBL */;
    L_X_EAM_WO_RELATIONS_TBL EAM_PROCESS_WO_PUB.EAM_WO_RELATIONS_TBL_TYPE /*:=
                               EAM_PROCESS_WO_PUB.G_MISS_EAM_WO_RELATIONS_TBL*/;
    L_X_EAM_OP_NETWORK_TBL EAM_PROCESS_WO_PUB.EAM_OP_NETWORK_TBL_TYPE /*:=
                               EAM_PROCESS_WO_PUB.G_MISS_EAM_OP_NETWORK_TBL*/;
    L_X_EAM_RES_INST_TBL EAM_PROCESS_WO_PUB.EAM_RES_INST_TBL_TYPE /*:=
                               EAM_PROCESS_WO_PUB.G_MISS_EAM_RES_INST_TBL*/ ;
    L_X_EAM_SUB_RES_TBL EAM_PROCESS_WO_PUB.EAM_SUB_RES_TBL_TYPE /*:=
                               EAM_PROCESS_WO_PUB.G_MISS_EAM_SUB_RES_TBL */;
    L_X_EAM_DIRECT_ITEMS_TBL EAM_PROCESS_WO_PUB.EAM_DIRECT_ITEMS_TBL_TYPE/* :=
                            EAM_PROCESS_WO_PUB.G_MISS_EAM_DIRECT_ITEMS_TBL */ ;
    L_X_EAM_RES_USAGE_TBL EAM_PROCESS_WO_PUB.EAM_RES_USAGE_TBL_TYPE ;
   --Extra variables for extended call to process_master_child_Wo
    L_EAM_WO_COMP_TBL EAM_PROCESS_WO_PUB.EAM_WO_COMP_TBL_TYPE;
    L_X_EAM_WO_COMP_TBL EAM_PROCESS_WO_PUB.EAM_WO_COMP_TBL_TYPE;
    L_EAM_WO_QUALITY_TBL EAM_PROCESS_WO_PUB.EAM_WO_QUALITY_TBL_TYPE;
    L_X_EAM_WO_QUALITY_TBL EAM_PROCESS_WO_PUB.EAM_WO_QUALITY_TBL_TYPE ;
    L_EAM_METER_READING_TBL EAM_PROCESS_WO_PUB.EAM_METER_READING_TBL_TYPE;
    L_X_EAM_METER_READING_TBL EAM_PROCESS_WO_PUB.EAM_METER_READING_TBL_TYPE;
    L_EAM_COUNTER_PROP_TBL EAM_PROCESS_WO_PUB.EAM_COUNTER_PROP_TBL_TYPE;
    L_X_EAM_COUNTER_PROP_TBL EAM_PROCESS_WO_PUB.EAM_COUNTER_PROP_TBL_TYPE;
    L_EAM_WO_COMP_REBUILD_TBL EAM_PROCESS_WO_PUB.EAM_WO_COMP_REBUILD_TBL_TYPE;
    L_X_EAM_WO_COMP_REBUILD_TBL EAM_PROCESS_WO_PUB.EAM_WO_COMP_REBUILD_TBL_TYPE;
    L_EAM_WO_COMP_MR_READ_TBL EAM_PROCESS_WO_PUB.EAM_WO_COMP_MR_READ_TBL_TYPE;
    L_X_EAM_WO_COMP_MR_READ_TBL EAM_PROCESS_WO_PUB.EAM_WO_COMP_MR_READ_TBL_TYPE;
    L_EAM_OP_COMP_TBL EAM_PROCESS_WO_PUB.EAM_OP_COMP_TBL_TYPE;
    L_X_EAM_OP_COMP_TBL EAM_PROCESS_WO_PUB.EAM_OP_COMP_TBL_TYPE;
    L_EAM_REQUEST_TBL EAM_PROCESS_WO_PUB.EAM_REQUEST_TBL_TYPE;
    L_X_EAM_REQUEST_TBL EAM_PROCESS_WO_PUB.EAM_REQUEST_TBL_TYPE;

    -- VARIABLES
    l_x_return_status VARCHAR2(30);
    l_x_msg_data VARCHAR2(1000);
    l_x_msg_count NUMBER;
    l_x_return_status_ahl VARCHAR2(30);
    l_x_msg_data_ahl VARCHAR2(1000);
    l_x_msg_count_ahl NUMBER;
    l_x_debug VARCHAR2(30);
    l_debug_filename VARCHAR2(30) ;
    l_debug_file_mode VARCHAR2(30) ;
    l_job_start_date date;
    x_msg_data VARCHAR2(1000);
    x_msg_data_ahl VARCHAR2(1000);
    l_msg_index_out NUMBER;
    lv_hdr_strg  VARCHAR2(20000);
    lv_brd_stmt  VARCHAR2(20000);
    lv_dbg_stmt  VARCHAR2(20000);
BEGIN

     var_proc :=  'Process_Single_WO' ;

     GET_WO_DETAIL (V_WIP_ENTITY_ID , V_ORGANIZATION_ID  , L_EAM_WO_TBL) ;

     l_job_start_date := L_EAM_WO_TBL(1).SCHEDULED_START_DATE;

     POPULATE_MISSING_DETAILS( V_WIP_ENTITY_ID
                               , V_ORGANIZATION_ID
                               , l_job_start_date );

   GET_OP_DETAIL (V_WIP_ENTITY_ID , V_ORGANIZATION_ID ,L_EAM_OP_TBL );
   GET_RES_INST_DETAIL(V_WIP_ENTITY_ID,V_ORGANIZATION_ID,L_EAM_RES_INST_TBL);
   GET_RES_DETAIL(V_WIP_ENTITY_ID, V_ORGANIZATION_ID,L_EAM_RES_TBL ) ;
   GET_MAT_DETAIL(V_WIP_ENTITY_ID , V_ORGANIZATION_ID ,L_EAM_MAT_TBL ) ;
   GET_RES_USAGE_DETAIL(V_WIP_ENTITY_ID ,V_ORGANIZATION_ID,L_EAM_RES_USAGE_TBL);

   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'  ' );
   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'Work Order Details :  ' );


     IF( L_EAM_WO_TBL.Count > 0 ) THEN
      lv_hdr_strg := '     '||'SOURCE_CODE'||
                     '     '||'SRC_LINE_ID'||
                     '     '||'ORG_ID'||
                     '     '||'STATUS_TYPE'||
                     '     '||'CLASS_CODE'||
                     '     '||RPAD('WIP_ENTITY_NAME',16)||
                     '     '||RPAD('SCHED_START_DATE',23)||
                     '     '||RPAD('SCHED_COMPLETION_DATE',23)||
                     '     '||RPAD('BOM_REV_DATE',23)||
                     '     '||RPAD('ROUTING_REV_DATE',23);

      lv_brd_stmt := '     '||'-----------'||
                     '     '||'-----------'||
                     '     '||'------'||
                     '     '||'-----------'||
                     '     '||'----------'||
                     '     '||'----------------'||
                     '     '||'-----------------------'||
                     '     '||'-----------------------'||
                     '     '||'-----------------------'||
                     '     '||'-----------------------';
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_hdr_strg);
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_brd_stmt);
      FOR X IN 1..L_EAM_WO_TBL.Count  LOOP
        lv_dbg_stmt := '     '||RPAD(Nvl(to_char(L_EAM_WO_TBL(x).SOURCE_CODE),' '),17)||
                       RPAD(NVL(to_char(L_EAM_WO_TBL(x).SOURCE_LINE_ID),' '),17)||
                       RPAD(NVL(to_char(L_EAM_WO_TBL(x).ORGANIZATION_ID),' '),12)||
                       RPAD(Nvl(to_char(L_EAM_WO_TBL(x).STATUS_TYPE),' '),17)||
                       RPAD(Nvl(to_char(L_EAM_WO_TBL(x).CLASS_CODE),' '),16)||
                       RPAD(NVL(to_char(L_EAM_WO_TBL(x).WIP_ENTITY_NAME),' '),19)||
                       RPAD(NVL(to_char(L_EAM_WO_TBL(x).SCHEDULED_START_DATE,'DD-MON-YYYY hh24:mi:ss'),' '),27)||
                       RPAD(NVL(to_char(L_EAM_WO_TBL(x).SCHEDULED_COMPLETION_DATE,'DD-MON-YYYY hh24:mi:ss'),' '),27)||
                       RPAD(NVL(to_char(L_EAM_WO_TBL(x).BOM_REVISION_DATE,'DD-MON-YYYY hh24:mi:ss'),' '),27)||
                       RPAD(NVL(to_char(L_EAM_WO_TBL(x).ROUTING_REVISION_DATE,'DD-MON-YYYY hh24:mi:ss'),' '),22);
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_dbg_stmt);
      END LOOP ;
    END IF ;

    MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'  ' );
    MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'Operation Details :  ' );

    IF( L_EAM_OP_TBL.Count > 0 ) THEN
       lv_hdr_strg := '     '||'WIP_ENTITY_ID'||
                      '     '|| 'ORG_ID'||
                      '     '|| 'OP_SEQ_NUM'||
                      '     '||'DEPT_ID'||
                      '     '||rpad('START_DATE',23)||
                      '     '||rpad('COMPLETION_DATE',23)||
                      '     '||rpad('DESCRIPTION (30 chars)',30)||
                      '     '||rpad('LONG DESCRIPTION (30)',25)||
                      '     '|| 'TRX_TYPE';

        lv_brd_stmt := '     '||'-------------'||'     '||'------'||'     '
                       ||'----------'||'     '||'-------'||'     '||'-----------------------'
                       ||'     '||'-----------------------'
                       ||'     '||'--------------------------'
                       ||'     '||'-----------------------------'
                       ||'     '||'--------' ;
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_hdr_strg);
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_brd_stmt);

     FOR X IN 1..L_EAM_OP_TBL.Count  LOOP
     lv_dbg_stmt := '     '||rpad(NVL(to_char(L_EAM_OP_TBL(x).WIP_ENTITY_ID),' '),19)||
                    rpad(NVL(to_char(L_EAM_OP_TBL(x).ORGANIZATION_ID),' '),12)||
                    rpad(NVL(to_char(L_EAM_OP_TBL(x).OPERATION_SEQ_NUM),' '),16)||
                    rpad(Nvl(to_char(L_EAM_OP_TBL(x).DEPARTMENT_ID),' '),12)||
                    rpad(NVL(to_char(L_EAM_OP_TBL(x).START_DATE,'DD-MON-YYYY hh24:mi:ss'),' '),27)||
                    rpad(NVL(to_char(L_EAM_OP_TBL(x).COMPLETION_DATE,'DD-MON-YYYY hh24:mi:ss'),' '),27)||
                    rpad(NVL(to_char(L_EAM_OP_TBL(x).DESCRIPTION),' '),30)||
                    rpad(NVL(to_char(L_EAM_OP_TBL(x).LONG_DESCRIPTION),' '),35)||
                    rpad(NVL(to_char(L_EAM_OP_TBL(x).TRANSACTION_TYPE),' '),9) ;

         MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_dbg_stmt);

     END LOOP ;
     ELSE
        lv_dbg_stmt :=  '     '||'No operations found on this job' ;
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_dbg_stmt);
     END IF ;

       MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'  ' );
       MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'Resource Details :  ' );

       IF( L_EAM_RES_TBL.Count > 0 ) THEN
      lv_hdr_strg :=  'HEADER_ID'
                    ||'     '||'BATCH_ID'
                    ||'     '||'WIP_ENTITY_ID'
                    ||'     '||'ORG_ID'
                    ||'     '||'OP_SEQ_NUM'
                    ||'     '||'RES_SEQ_NUM'
                    ||'     '||'RESOURCE_ID'
                    ||'     '||'BASIS_TYPE'
                    ||'     '||'USAGE_RATE'
                    ||'     '||'SCHEDULED_FLAG'
                    ||'     '||'ASSIGNED_UNITS'
                    ||'     '||'AUTOCHARGE_TYPE'
                    ||'     '||'START_DATE             '
                    ||'     '||'COMPLETION_DATE    '
                    ||'     '||'DEPT_ID'
                    ||'     '||'TRXN_TYPE'
                    ||'     '||'FIRM_FLAG' ;

      lv_brd_stmt := '---------'
                    ||'     '||'---------'
                    ||'     '||'-------------'
                    ||'     '||'------'
                    ||'     '||'----------'
                    ||'     '||'-----------'
                    ||'     '||'-----------'
                    ||'     '||'----------'
                    ||'     '||'----------'
                    ||'     '||'--------------'
                    ||'     '||'--------------'
                    ||'     '||'---------------'
                    ||'     '||'-----------------------'
                    ||'     '||'------------------'
                    ||'     '||'-------'
                    ||'     '||'---------'
                    ||'     '||'---------'
      ;
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_hdr_strg);
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_brd_stmt);

        FOR X IN 1..L_EAM_RES_TBL.Count  LOOP

         lv_dbg_stmt := RPAD(NVL(to_char(L_EAM_RES_TBL(X).HEADER_ID),' '),14)
				      ||RPAD(NVL(to_char(L_EAM_RES_TBL(X).BATCH_ID),' '),14)
					  ||RPAD(nvl(to_char(L_EAM_RES_TBL(X).WIP_ENTITY_ID),' '),18)
                      ||RPAD(nvl(to_char(L_EAM_RES_TBL(X).ORGANIZATION_ID),' '),11)
                      ||RPAD(nvl(to_char(L_EAM_RES_TBL(X).OPERATION_SEQ_NUM),' '),15)
                      ||RPAD(nvl(to_char(L_EAM_RES_TBL(X).RESOURCE_SEQ_NUM),' '),16)
                      ||RPAD(nvl(to_char(L_EAM_RES_TBL(X).RESOURCE_ID),' '),16)
                      ||RPAD(Nvl(to_char(L_EAM_RES_TBL(X).BASIS_TYPE),' '),17)
                      ||RPAD(nvl(to_char(L_EAM_RES_TBL(X).USAGE_RATE_OR_AMOUNT),' '),15)
                      ||RPAD(nvl(to_char(L_EAM_RES_TBL(X).SCHEDULED_FLAG),' '),19)
                      ||RPAD(Nvl(to_char(L_EAM_RES_TBL(X).ASSIGNED_UNITS),' '),19)
                      ||RPAD(Nvl(to_char(L_EAM_RES_TBL(X).AUTOCHARGE_TYPE),' '),18)
                      ||RPAD(NVL(to_char(L_EAM_RES_TBL(X).START_DATE,'DD-MON-YYYY hh24:mi:ss'),' '),27)
                      ||RPAD(NVL(to_char(L_EAM_RES_TBL(X).COMPLETION_DATE,'DD-MON-YYYY hh24:mi:ss'),' '),27)
                      ||RPAD(Nvl(to_char(L_EAM_RES_TBL(X).DEPARTMENT_ID),' '),17)
                      ||RPAD(NVL(to_char(L_EAM_RES_TBL(X).TRANSACTION_TYPE),' '),14)
                      ||RPAD(NVL(to_char(L_EAM_RES_TBL(X).FIRM_FLAG),' '),9) ;


         MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_dbg_stmt );
         END LOOP ;
        ELSE
        lv_dbg_stmt :=  '     '||'No Resources found on this job' ;
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_dbg_stmt);

       END IF ;

       MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'  ' );
       MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'Resource Instance Details :  ' );

      IF( L_EAM_RES_INST_TBL.Count > 0 ) THEN
             lv_hdr_strg := '     '||'HEADER_ID'
             ||'     '||'BATCH_ID'
             ||'     '||'WIP_ENTITY_ID'
             ||'     '||'ORG_ID'
             ||'     '||'OP_SEQ_NUM'
             ||'     '||'RES_SEQ_NUM'
             ||'     '||'INSTANCE_ID'
             ||'     '||'SERIAL_NUMBER'
             ||'     '||'START_DATE            '
             ||'     '||'COMPLETION_DATE       '
             ||'     '||'TRX_TYPE' ;

             lv_hdr_strg := '     '||'---------'
             ||'     '||'--------'
             ||'     '||'-------------'
             ||'     '||'-------'
             ||'     '||'----------'
             ||'     '||'-----------'
             ||'     '||'----------'
             ||'     '||'-------------'
             ||'     '||'-----------------------'
             ||'     '||'-----------------------'
             ||'     '||'--------' ;
             MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_hdr_strg);
             MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_brd_stmt);
            FOR X IN 1..L_EAM_RES_INST_TBL.Count  LOOP

             lv_dbg_stmt :=  rpad(NVL(to_char(L_EAM_RES_TBL(X).HEADER_ID),' '),14)
                      ||rpad(NVL(to_char(L_EAM_RES_INST_TBL(x).BATCH_ID),' '),13)
--check the next line
                      ||rpad(NVL(to_char(L_EAM_RES_INST_TBL(x).WIP_ENTITY_ID),' '),18)
                      ||rpad(NVL(to_char(L_EAM_RES_INST_TBL(x).ORGANIZATION_ID),' '),12)
                      ||rpad(NVL(to_char(L_EAM_RES_INST_TBL(x).OPERATION_SEQ_NUM),' '),15)
                      ||rpad(NVL(to_char(L_EAM_RES_INST_TBL(x).RESOURCE_SEQ_NUM),' '),16)
                      ||rpad(NVL(to_char(L_EAM_RES_INST_TBL(x).INSTANCE_ID),' '),16)
                      ||rpad(NVL(to_char(L_EAM_RES_INST_TBL(x).SERIAL_NUMBER),' '),18)
                      ||rpad(NVL(to_char(L_EAM_RES_INST_TBL(x).START_DATE,'DD-MON-YYYY hh24:mi:ss'),' '),27)
                      ||rpad(NVL(to_char(L_EAM_RES_INST_TBL(x).COMPLETION_DATE,'DD-MON-YYYY hh24:mi:ss'),' '),27)
                      ||rpad(NVL(to_char(L_EAM_RES_INST_TBL(x).TRANSACTION_TYPE),' '),13) ;
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_dbg_stmt );
         END LOOP ;
         ELSE
        lv_dbg_stmt :=  '     '||'No Resource instances found on this job' ;
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_dbg_stmt);

       END IF ;


      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'  ' );
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'Material Req Details :  ' );


      IF( L_EAM_MAT_TBL.Count > 0 ) THEN
              lv_hdr_strg := 'HEADER_ID'
             ||'     '||'BATCH_ID'
             ||'     '||'WIP_ENTITY_ID'
             ||'     '||'ORG_ID'
             ||'     '||'OP_SEQ_NUM'
             ||'     '||'INVENTORY_ITEM_ID'
             ||'     '||'DEPARTMENT_ID'
             ||'     '||'WIP_SUP_TYPE'
             ||'     '||'DATE_REQUIRED     '
             ||'     '||'REQUIRED_QTY'
             ||'     '||'TRX_TYPE' ;

             lv_brd_stmt := '---------'
             ||'     '||'--------'
             ||'     '||'-------------'
             ||'     '||'------'
             ||'     '||'----------'
             ||'     '||'-----------------'
             ||'     '||'-------------'
             ||'     '||'------------'
             ||'     '||'------------------'
             ||'     '||'------------'
             ||'     '||'--------' ;
             MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_hdr_strg);
             MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_brd_stmt);



         FOR X IN 1..L_EAM_MAT_TBL.Count  LOOP
              lv_dbg_stmt := rpad(NVL(to_char(L_EAM_RES_TBL(X).HEADER_ID),' '),14)
                      ||rpad(NVL(to_char(L_EAM_MAT_TBL(x).BATCH_ID),' '),13)
                      ||rpad(NVL(to_char(L_EAM_MAT_TBL(x).WIP_ENTITY_ID),' '),18)
                      ||rpad(NVL(to_char(L_EAM_MAT_TBL(x).ORGANIZATION_ID),' '),17)
                      ||rpad(NVL(to_char(L_EAM_MAT_TBL(x).OPERATION_SEQ_NUM),' '),15)
                      ||rpad(NVL(to_char(L_EAM_MAT_TBL(x).INVENTORY_ITEM_ID),' '),22)
                      ||rpad(NVL(to_char(L_EAM_MAT_TBL(x).DEPARTMENT_ID),' '),15)
                      ||rpad(NVL(to_char(L_EAM_MAT_TBL(x).WIP_SUPPLY_TYPE),' '),14)
                      ||RPAD(NVL(to_char(L_EAM_MAT_TBL(x).DATE_REQUIRED,'DD-MON-YYYY hh24:mi:ss'),' '),28)
                      ||rpad(NVL(to_char(L_EAM_MAT_TBL(x).REQUIRED_QUANTITY),' '),17)
                      ||rpad(NVL(to_char(L_EAM_MAT_TBL(x).TRANSACTION_TYPE),' '),13) ;

          MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_dbg_stmt);
--          MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'Printing Material Req Details :  ' );
         END LOOP ;

         MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'After Printing Material Req Details :  ' );
         ELSE
        lv_dbg_stmt :=  '     '||'No Material Req found on this job' ;
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_dbg_stmt);

       END IF ;

         MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'Resource usage Details :  ' );
           IF( L_EAM_RES_USAGE_TBL.Count > 0 ) THEN
            lv_hdr_strg :=  '     '||'HEADER_ID'
                    ||'     '||'BATCH_ID'
                    ||'     '||'WIP_ENTITY_ID'
                    ||'     '||'ORG_ID'
                    ||'     '||'OP_SEQ_NUM'
                    ||'     '||'RES_SEQ_NUM'
                    ||'     '||'START_DATE           '
                    ||'     '||'COMPLETION_DATE      '
                    ||'     '||'ASSIGNED_UNITS'
                    ||'     '||'SERIAL_NUMBER'
                    ||'     '||'INSTANCE_ID'
                    ||'     '||'TRX_TYPE' ;



           lv_brd_stmt := '     '||'---------'
                    ||'     '||'---------'
                    ||'     '||'-------------'
                    ||'     '||'------'
                    ||'     '||'----------'
                    ||'     '||'-----------'
                    ||'     '||'-----------------------'
                    ||'     '||'-----------------------'
                    ||'     '||'--------------'
                    ||'     '||'-------------'
                    ||'     '||'----------'
                    ||'     '||'--------' ;

        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_hdr_strg);
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_brd_stmt);

         FOR X IN 1..L_EAM_RES_USAGE_TBL.Count  LOOP
         lv_dbg_stmt := '     '|| rpad(L_EAM_RES_TBL(X).HEADER_ID,9)
             ||'     '|| rpad(L_EAM_RES_USAGE_TBL(x).BATCH_ID,8)
             ||'     '|| rpad(L_EAM_RES_USAGE_TBL(x).WIP_ENTITY_ID,13)
             ||'     '|| rpad(L_EAM_RES_USAGE_TBL(x).ORGANIZATION_ID,7)
             ||'     '|| rpad(L_EAM_RES_USAGE_TBL(x).OPERATION_SEQ_NUM,10)
             ||'     '|| rpad(L_EAM_RES_USAGE_TBL(x).RESOURCE_SEQ_NUM,11)
             ||'     '|| to_char(L_EAM_RES_USAGE_TBL(x).START_DATE,'DD-MON-YYYY hh24:mi:ss')
             ||'     '|| to_char(L_EAM_RES_USAGE_TBL(x).COMPLETION_DATE,'DD-MON-YYYY hh24:mi:ss')
             ||'     '|| rpad(L_EAM_RES_USAGE_TBL(x).ASSIGNED_UNITS,14)
             ||'     '|| rpad(L_EAM_RES_USAGE_TBL(x).SERIAL_NUMBER,13)
             ||'     '|| rpad(L_EAM_RES_USAGE_TBL(x).INSTANCE_ID,11)
             ||'     '|| rpad(L_EAM_RES_USAGE_TBL(x).TRANSACTION_TYPE,8) ;

          MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_dbg_stmt );

         END LOOP ;
         ELSE
        lv_dbg_stmt :=  '     '||'No Resource Usage found on this job' ;
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_dbg_stmt);

       END IF ;
-- PROPER INITIALIZATION OF APPS HERE
--      fnd_global.apps_initialize (l_user_id,l_responsibility_id,
--                                  l_responsibility_app_id);
--     V_CREATED_BY := FND_GLOBAL.USER_ID;
--     V_UPDATED_BY := FND_GLOBAL.USER_ID;
          IF(NOT g_log_file_set) THEN

           select ltrim(rtrim(value)) into g_output_dir
           from (select value from v$parameter2  where name='utl_file_dir'
                                               order by rownum desc)
           where rownum <2;

           fnd_file.get_names(g_log_file_name,g_out_file_name);
           g_log_file_set := TRUE;

         END IF;
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,
                  'EAM debug output dir is: '||g_output_dir);
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,
                  'EAM log file name is   : '||g_log_file_name);

         savepoint EAMCALL;

         MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,
                  'Calling API '||
                  'EAM_PROCESS_WO_PUB.PROCESS_MASTER_CHILD_WO ');
         FND_MSG_PUB.initialize;
         EAM_PROCESS_WO_PUB.PROCESS_MASTER_CHILD_WO (
               P_BO_IDENTIFIER => 'EAM'
             , P_API_VERSION_NUMBER => 1.0
             , P_INIT_MSG_LIST => FALSE   -- FND_API.G_FALSE , this is boolean
             , P_EAM_WO_RELATIONS_TBL => L_EAM_WO_RELATIONS_TBL
             , P_EAM_WO_TBL => L_EAM_WO_TBL
             , P_EAM_OP_TBL => L_EAM_OP_TBL
             , P_EAM_OP_NETWORK_TBL => L_EAM_OP_NETWORK_TBL
             , P_EAM_RES_TBL => L_EAM_RES_TBL
             , P_EAM_RES_INST_TBL => L_EAM_RES_INST_TBL
             , P_EAM_SUB_RES_TBL => L_EAM_SUB_RES_TBL
             , P_EAM_MAT_REQ_TBL => L_EAM_MAT_TBL
             , P_EAM_DIRECT_ITEMS_TBL => L_EAM_DIRECT_ITEMS_TBL
             , P_EAM_RES_USAGE_TBL => L_EAM_RES_USAGE_TBL
             , P_EAM_WO_COMP_TBL => L_EAM_WO_COMP_TBL
             , P_EAM_WO_QUALITY_TBL => L_EAM_WO_QUALITY_TBL
             , P_EAM_METER_READING_TBL => L_EAM_METER_READING_TBL
             , P_EAM_COUNTER_PROP_TBL => L_EAM_COUNTER_PROP_TBL
             , P_EAM_WO_COMP_REBUILD_TBL => L_EAM_WO_COMP_REBUILD_TBL
             , P_EAM_WO_COMP_MR_READ_TBL => L_EAM_WO_COMP_MR_READ_TBL
             , P_EAM_OP_COMP_TBL => L_EAM_OP_COMP_TBL
             , P_EAM_REQUEST_TBL => L_EAM_REQUEST_TBL
             , X_EAM_WO_TBL => L_X_EAM_WO_TBL
             , X_EAM_WO_RELATIONS_TBL => L_X_EAM_WO_RELATIONS_TBL
             , X_EAM_OP_TBL => L_X_EAM_OP_TBL
             , X_EAM_OP_NETWORK_TBL => L_X_EAM_OP_NETWORK_TBL
             , X_EAM_RES_TBL => L_X_EAM_RES_TBL
             , X_EAM_RES_INST_TBL => L_X_EAM_RES_INST_TBL
             , X_EAM_SUB_RES_TBL => L_X_EAM_SUB_RES_TBL
             , X_EAM_MAT_REQ_TBL => L_X_EAM_MAT_TBL
             , X_EAM_DIRECT_ITEMS_TBL => L_X_EAM_DIRECT_ITEMS_TBL
             , X_EAM_RES_USAGE_TBL => L_X_EAM_RES_USAGE_TBL
             , X_EAM_WO_COMP_TBL => L_X_EAM_WO_COMP_TBL
             , X_EAM_WO_QUALITY_TBL => L_X_EAM_WO_QUALITY_TBL
             , X_EAM_METER_READING_TBL => L_X_EAM_METER_READING_TBL
             , X_EAM_COUNTER_PROP_TBL => L_X_EAM_COUNTER_PROP_TBL
             , X_EAM_WO_COMP_REBUILD_TBL => L_X_EAM_WO_COMP_REBUILD_TBL
             , X_EAM_WO_COMP_MR_READ_TBL => L_X_EAM_WO_COMP_MR_READ_TBL
             , X_EAM_OP_COMP_TBL => L_X_EAM_OP_COMP_TBL
             , X_EAM_REQUEST_TBL => L_X_EAM_REQUEST_TBL
             , x_return_status => l_x_return_status
             , x_msg_count => l_x_msg_count
             , p_commit => 'N' --;FND_API.G_FALSE   -- this is varchar
             , p_debug => 'Y'
--             , p_output_dir => '/sqlcom/log/ma0dv220'
             , p_output_dir => g_output_dir
--             , p_debug_filename => 'EAM_WO_DEBUG.log'
             , p_debug_filename => g_log_file_name
             , p_debug_file_mode => 'a'
             );
     -- log api return details
     -- On Successful reschedule of the CMRO work order, we would need
     -- to call an CMRO API to update the table: AHL_Schedule_materials
     -- CMRO team will provicde a new API for this
     --Add code for cMRO API here

         MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'status returned by EAM API is '||l_x_return_status);
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'value of l_x_msg_count is'||l_x_msg_count);

         FOR i IN 1..l_x_msg_count LOOP
             FND_MSG_PUB.get (
                 p_msg_index      => i,
                 p_encoded        => FND_API.G_FALSE,
                 p_data           => x_msg_data,
                 p_msg_index_out  => l_msg_index_out );
             MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,
                              SubStr('x_msg_data = '||x_msg_data,1,255));
         END LOOP;


         IF(l_x_return_status = FND_API.G_RET_STS_SUCCESS)
         THEN

                  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,
                  'EAM_PROCESS_WO_PUB.PROCESS_MASTER_CHILD_WO '||
                  ' returns SUCCESS');
--                 fnd_file.put_line(FND_FILE.OUTPUT, var_buf);
                  var_buf := 'Group ID : '||g_group_id;

                  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,
                  'Calling API '||
                  ' AHL_LTP_MATERIALS_GRP.Update_mtl_resv_dates'||
                  'with wip_entity_id ='||V_WIP_ENTITY_ID);

              FND_MSG_PUB.initialize;
              AHL_LTP_MATERIALS_GRP.Update_mtl_resv_dates(
                    P_API_VERSION => 1.0
                  , p_init_msg_list => FND_API.G_FALSE
                  , p_commit => FND_API.G_FALSE
                  , p_validation_level => FND_API.G_VALID_LEVEL_FULL
                  , x_return_status => l_x_return_status_ahl
                  , x_msg_count => l_x_msg_count_ahl
                  , x_msg_data => l_x_msg_data_ahl
                  , p_wip_entity_id => V_WIP_ENTITY_ID);

				  IF(l_x_return_status_ahl = FND_API.G_RET_STS_SUCCESS)
                  THEN
                       MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,
                                 ' AHL_LTP_MATERIALS_GRP.Update_mtl_resv_dates'||
                                 ' returns SUCCESS ');
                       FOR i IN 1..l_x_msg_count_ahl LOOP
                       FND_MSG_PUB.get (
                             p_msg_index      => i,
                             p_encoded        => FND_API.G_FALSE,
                             p_data           => l_x_msg_data_ahl,
                             p_msg_index_out  => l_msg_index_out );
                       MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,
                              SubStr('x_msg_data = '||l_x_msg_data_ahl,1,255));
                       END LOOP;
                       log_output('   '||rpad(L_EAM_WO_TBL(1).WIP_ENTITY_NAME, 9)||'         '||
                                  to_char(L_EAM_WO_TBL(1).SCHEDULED_START_DATE, 'DD-MON-YYYY hh24:mi:ss') || '    '||
                                  to_char(L_EAM_WO_TBL(1).SCHEDULED_COMPLETION_DATE, 'DD-MON-YYYY hh24:mi:ss') || '  '||
                                  ' Success ');
                  ELSE

                       MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,
                                 ' AHL_LTP_MATERIALS_GRP.Update_mtl_resv_dates'||
                                 ' did not return success ');
                       FOR i IN 1..l_x_msg_count_ahl LOOP
                       FND_MSG_PUB.get (
                             p_msg_index      => i,
                             p_encoded        => FND_API.G_FALSE,
                             p_data           => l_x_msg_data_ahl,
                             p_msg_index_out  => l_msg_index_out );
                       MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,
                              SubStr('x_msg_data = '||l_x_msg_data_ahl,1,255));
                       END LOOP;

                       MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,
                                 'l_x_msg_count_ahl = '||l_x_msg_count_ahl);
                       g_retcode := MSC_UTIL.G_WARNING;
			      END IF;
         ELSE
              MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,
                  'EAM_PROCESS_WO_PUB.PROCESS_MASTER_CHILD_WO '||
                  'FAILED');
              g_retcode := MSC_UTIL.G_WARNING;
         END IF;

         IF((l_x_return_status <> FND_API.G_RET_STS_SUCCESS) OR (l_x_return_status_ahl <> FND_API.G_RET_STS_SUCCESS))
         THEN
             log_output('   '||rpad(L_EAM_WO_TBL(1).WIP_ENTITY_NAME, 9)||'         '||
                        to_char(L_EAM_WO_TBL(1).SCHEDULED_START_DATE, 'DD-MON-YYYY hh24:mi:ss') || '    '||
                        to_char(L_EAM_WO_TBL(1).SCHEDULED_COMPLETION_DATE, 'DD-MON-YYYY hh24:mi:ss') || '  '||
                        ' Error  ');
             ROLLBACK WORK TO SAVEPOINT EAMCALL;
         END IF;

RETURN;

EXCEPTION
  WHEN OTHERS THEN
    MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,
                     ' Error in procedure process_single_wo: '||sqlerrm);
    g_retcode := MSC_UTIL.G_WARNING;
    RETURN;


END PROCESS_Single_WO ;

 /************************************************************************
   Get_WO_Detail :
   This procedure accepts a wip entity id fetches the Job details
   into plsql table L_EAM_WO_TBL and
  ************************************************************************/


PROCEDURE GET_WO_DETAIL (V_WIP_ENTITY_ID IN NUMBER, V_ORGANIZATION_ID IN NUMBER,
                         L_EAM_WO_TBL OUT NOCOPY EAM_PROCESS_WO_PUB.EAM_WO_TBL_TYPE)
IS
    L_JOB_START_DATE  DATE ;
    L_JOB_STMT  VARCHAR2(2000);

    JOBS_CUR_TBL  JOBS_CUR_TBL_TYPE ;
    JOBS_CUR            CurTyp;
    lv_std_job_count    number;
BEGIN

  var_proc :=  'GET_WO_DETAIL' ;
  L_JOB_STMT := 'SELECT '
||'   ''MSC'' SOURCE_CODE '
||'   ,WJSI.SOURCE_LINE_ID '
||'   ,WJSI.ORGANIZATION_ID '
||'   ,WJSI.STATUS_TYPE '
||'   ,WJSI.FIRST_UNIT_START_DATE  '
--||'   ,WJSI.PRIMARY_ITEM_ID REBUILD_ITEM_ID '
||'   ,WJSI.BOM_REVISION_DATE '
||'   ,WJSI.ROUTING_REVISION_DATE '
||'   ,WJSI.CLASS_CODE '
||'   ,WJSI.JOB_NAME	  '
||'   ,WJSI.FIRM_PLANNED_FLAG '
||'   ,WJSI.ALTERNATE_ROUTING_DESIGNATOR '
||'   ,WJSI.ALTERNATE_BOM_DESIGNATOR '
||'   ,WJSI.START_QUANTITY  '
||'   ,WJSI.WIP_ENTITY_ID '
||'   ,WJSI.SCHEDULE_GROUP_ID '
||'   ,WJSI.PROJECT_ID '
||'   ,WJSI.TASK_ID '
--||'   ,WJSI.START_QUANTITY  '
||'   ,WJSI.END_ITEM_UNIT_NUMBER '
||'   ,WJSI.HEADER_ID '
||'   ,WJSI.LAST_UNIT_COMPLETION_DATE  '
||'   ,WDJ.ASSET_NUMBER '
||'   ,WDJ.ASSET_GROUP_ID '
||'   ,WDJ.MAINTENANCE_OBJECT_ID '
||'   ,WDJ.MAINTENANCE_OBJECT_TYPE '
||'   ,WDJ.MAINTENANCE_OBJECT_SOURCE '
||'   ,WDJ.DATE_RELEASED '
||'   ,WDJ.OWNING_DEPARTMENT '
||' FROM  WIP_DISCRETE_JOBS   WDJ , '
||'       MSC_WIP_JOB_SCHEDULE_INTERFACE'||g_dblink||' WJSI '
||' WHERE WJSI.WIP_ENTITY_ID =  :V_WIP_ENTITY_ID'
||' AND WJSI.ORGANIZATION_ID =  :V_ORGANIZATION_ID'
||' AND WJSI.WIP_ENTITY_ID =  WDJ.WIP_ENTITY_ID '
||' AND WJSI.ORGANIZATION_ID =  WDJ.ORGANIZATION_ID '
||' AND WJSI.GROUP_ID = :GROUP_ID' ;

     IF(L_EAM_WO_TBL.Count >0) THEN
           L_EAM_WO_TBL.delete(L_EAM_WO_TBL.FIRST,L_EAM_WO_TBL.last);
    END IF;


       MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEV, L_JOB_STMT );

    OPEN JOBS_CUR for L_JOB_STMT using
                      V_WIP_ENTITY_ID,V_ORGANIZATION_ID,G_GROUP_ID ;
    FETCH JOBS_CUR  BULK COLLECT INTO JOBS_CUR_TBL ;
    lv_std_job_count := JOBS_CUR%ROWCOUNT;
    MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'SQL rowcount of JOBS_CUR is '||lv_std_job_count);
    MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'Number of records fetched into JOBS_CUR_TBL is '||JOBS_CUR_TBL.Count);

    FOR y IN 1..JOBS_CUR_TBL.Count LOOP

      L_EAM_WO_TBL(y).SOURCE_CODE :=      JOBS_CUR_TBL(y).SOURCE_CODE    ;
      L_EAM_WO_TBL(y).SOURCE_LINE_ID :=   JOBS_CUR_TBL(y).SOURCE_LINE_ID ;
      L_EAM_WO_TBL(y).ORGANIZATION_ID :=  JOBS_CUR_TBL(y).ORGANIZATION_ID;
      L_EAM_WO_TBL(y).STATUS_TYPE	 :=     JOBS_CUR_TBL(y).STATUS_TYPE  ;
      L_EAM_WO_TBL(y).SCHEDULED_START_DATE :=
                                          JOBS_CUR_TBL(y).FIRST_UNIT_START_DATE;
      L_JOB_START_DATE    :=     JOBS_CUR_TBL(y).FIRST_UNIT_START_DATE;
     -- L_EAM_WO_TBL(y).REBUILD_ITEM_ID	 :=  JOBS_CUR_TBL(y).REBUILD_ITEM_ID;
      L_EAM_WO_TBL(y).BOM_REVISION_DATE	:= JOBS_CUR_TBL(y).BOM_REVISION_DATE;
      L_EAM_WO_TBL(y).ROUTING_REVISION_DATE :=
                                JOBS_CUR_TBL(y).ROUTING_REVISION_DATE;
      L_EAM_WO_TBL(y).CLASS_CODE         := JOBS_CUR_TBL(y).CLASS_CODE;
      L_EAM_WO_TBL(y).WIP_ENTITY_NAME    := JOBS_CUR_TBL(y).JOB_NAME ;
      L_EAM_WO_TBL(y).FIRM_PLANNED_FLAG	 := JOBS_CUR_TBL(y).FIRM_PLANNED_FLAG ;
      L_EAM_WO_TBL(y).ALTERNATE_ROUTING_DESIGNATOR:=
                                 JOBS_CUR_TBL(y).ALTERNATE_ROUTING_DESIGNATOR;
      L_EAM_WO_TBL(y).ALTERNATE_BOM_DESIGNATOR :=
                                 JOBS_CUR_TBL(y).ALTERNATE_BOM_DESIGNATOR ;
      L_EAM_WO_TBL(y).JOB_QUANTITY       :=  JOBS_CUR_TBL(y).START_QUANTITY;
      L_EAM_WO_TBL(y).WIP_ENTITY_ID	       := JOBS_CUR_TBL(y).WIP_ENTITY_ID ;
      L_EAM_WO_TBL(y).SCHEDULE_GROUP_ID	   := JOBS_CUR_TBL(y).SCHEDULE_GROUP_ID;
      L_EAM_WO_TBL(y).PROJECT_ID	         := JOBS_CUR_TBL(y).PROJECT_ID ;
      L_EAM_WO_TBL(y).TASK_ID	             := JOBS_CUR_TBL(y).TASK_ID    ;
      --L_EAM_WO_TBL(y).NET_QUANTITY        := JOBS_CUR_TBL(y).START_QUANTITY;
      L_EAM_WO_TBL(y).END_ITEM_UNIT_NUMBER :=
                                 JOBS_CUR_TBL(y).END_ITEM_UNIT_NUMBER ;
   --   L_EAM_WO_TBL(y).HEADER_ID	           := JOBS_CUR_TBL(y).HEADER_ID ;
      L_EAM_WO_TBL(y).HEADER_ID	           := 0;
      L_EAM_WO_TBL(y).SCHEDULED_COMPLETION_DATE   :=
                                 JOBS_CUR_TBL(y).LAST_UNIT_COMPLETION_DATE ;
      L_EAM_WO_TBL(y).ASSET_NUMBER      := JOBS_CUR_TBL(y).ASSET_NUMBER   ;
      L_EAM_WO_TBL(y).ASSET_GROUP_ID    := JOBS_CUR_TBL(y).ASSET_GROUP_ID ;
      L_EAM_WO_TBL(y).MAINTENANCE_OBJECT_ID  :=
                                 JOBS_CUR_TBL(y).MAINTENANCE_OBJECT_ID   ;
      L_EAM_WO_TBL(y).MAINTENANCE_OBJECT_TYPE :=
                                 JOBS_CUR_TBL(y).MAINTENANCE_OBJECT_TYPE ;
      L_EAM_WO_TBL(y).MAINTENANCE_OBJECT_SOURCE  :=
                                 JOBS_CUR_TBL(y).MAINTENANCE_OBJECT_SOURCE ;
      L_EAM_WO_TBL(y).DATE_RELEASED     := JOBS_CUR_TBL(y).DATE_RELEASED    ;
      L_EAM_WO_TBL(y).OWNING_DEPARTMENT := JOBS_CUR_TBL(y).OWNING_DEPARTMENT ;
      L_EAM_WO_TBL(y).TRANSACTION_TYPE  := EAM_PROCESS_WO_PVT.G_OPR_UPDATE ;
--      L_EAM_WO_TBL(y).BATCH_ID	        := JOBS_CUR_TBL(y).WIP_ENTITY_ID ;
      L_EAM_WO_TBL(y).BATCH_ID	        := 1 ;

    -- write these details into log when fineer details needed
    END LOOP ;
    CLOSE JOBS_CUR;
   RETURN ;

  EXCEPTION  WHEN OTHERS THEN
--    var_buf := var_proc||' 3: '||sqlerrm;
--    fnd_file.put_line(FND_FILE.LOG, var_buf);
    MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'Exception in procedure GET_WO_DETAIL');
    RETURN;

END GET_WO_DETAIL ;

/****************************************************************************
   GET_OP_DETAIL :
   This procedure accepts a wip entity id fetches the Job operation details
   into plsql table L_EAM_WO_TBL ,
  ***************************************************************************/

PROCEDURE GET_OP_DETAIL (V_WIP_ENTITY_ID IN NUMBER ,
                         V_ORGANIZATION_ID IN NUMBER ,
                         L_EAM_OP_TBL OUT NOCOPY EAM_PROCESS_WO_PUB.EAM_OP_TBL_TYPE
                        )
                        IS

  l_op_index                 NUMBER :=1;
  lv_stmt    VARCHAR2(2000) ;
  OP_CUR CurTyp;
  OP_CUR_TBL  OP_CUR_TBL_TYPE ;
  lv_op_count number;
BEGIN
      var_proc :=  'GET_OP_DETAIL' ;
lv_stmt := 'SELECT'
||'        WJDI.PARENT_HEADER_ID               '
||'      , WJDI.WIP_ENTITY_ID WIP_ENTITY_ID '
||'      ,WJDI.ORGANIZATION_ID'
||'      ,WJDI.OPERATION_SEQ_NUM'
||'      ,WJDI.DEPARTMENT_ID DEPARTMENT_ID'
||'      ,WJDI.DESCRIPTION'
||'      ,WJDI.MINIMUM_TRANSFER_QUANTITY'
||'      ,WJDI.COUNT_POINT_TYPE'
||'      ,WJDI.BACKFLUSH_FLAG'
||'      ,WJDI.FIRST_UNIT_START_DATE  START_DATE'
||'      ,WJDI.LAST_UNIT_COMPLETION_DATE COMPLETION_DATE'
||'       FROM MSC_WIP_JOB_DTLS_INTERFACE'||g_dblink ||' WJDI '
||'       WHERE'
||'       WJDI.WIP_ENTITY_ID = :V_WIP_ENTITY_ID'
||'       AND WJDI.ORGANIZATION_ID =  :V_ORGANIZATION_ID'
||'       AND WJDI.GROUP_ID = :G_GROUP_ID'
||'       AND WJDI.LOAD_TYPE = 3 ';

    IF(L_EAM_OP_TBL.Count >0) THEN
           L_EAM_OP_TBL.delete(L_EAM_OP_TBL.FIRST,L_EAM_OP_TBL.last);
    END IF;
  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEV, lv_stmt );

    OPEN OP_CUR for lv_stmt using V_WIP_ENTITY_ID,V_ORGANIZATION_ID,G_GROUP_ID;
    FETCH OP_CUR  BULK COLLECT INTO OP_CUR_TBL ;
    lv_op_count := OP_CUR%ROWCOUNT;
    MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'SQL rowcount of OP_CUR is '||lv_op_count);
    MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'Number of records fetched into OP_CUR_TBL is '||OP_CUR_TBL.Count);
    FOR y IN 1..OP_CUR_TBL.Count LOOP
       -- What is the index field in these two columns
       -- assign l_op_index to that col and increment it in loop

--        L_EAM_OP_TBL(y).HEADER_ID              := OP_CUR_TBL(y).PARENT_HEADER_ID        ;

        L_EAM_OP_TBL(y).HEADER_ID	           := 0;
        L_EAM_OP_TBL(y).BATCH_ID	           := 1;
       -- L_EAM_TBL(y).ROW_ID               l_op_index ;
       L_EAM_OP_TBL(y).WIP_ENTITY_ID       := OP_CUR_TBL(y).WIP_ENTITY_ID    ;
        L_EAM_OP_TBL(y).ORGANIZATION_ID     := OP_CUR_TBL(y).ORGANIZATION_ID  ;
        L_EAM_OP_TBL(y).OPERATION_SEQ_NUM   := OP_CUR_TBL(y).OPERATION_SEQ_NUM;
        L_EAM_OP_TBL(y).DEPARTMENT_ID       := OP_CUR_TBL(y).DEPARTMENT_ID    ;
        L_EAM_OP_TBL(y).START_DATE          := OP_CUR_TBL(y).START_DATE       ;
        L_EAM_OP_TBL(y).COMPLETION_DATE     := OP_CUR_TBL(y).COMPLETION_DATE  ;
        L_EAM_OP_TBL(y).DESCRIPTION         := OP_CUR_TBL(y).DESCRIPTION  ;
        L_EAM_OP_TBL(y).TRANSACTION_TYPE    := EAM_PROCESS_WO_PVT.G_OPR_UPDATE;

        select shutdown_type
           , attribute_category
           , ATTRIBUTE1
           , ATTRIBUTE2
           , ATTRIBUTE3
           , ATTRIBUTE4
           , ATTRIBUTE5
           , ATTRIBUTE6
           , ATTRIBUTE7
           , ATTRIBUTE8
           , ATTRIBUTE9
           , ATTRIBUTE10
           , ATTRIBUTE11
           , ATTRIBUTE12
           , ATTRIBUTE13
           , ATTRIBUTE14
           , ATTRIBUTE15
           , long_description
         INTO
            L_EAM_OP_TBL(y).shutdown_type
           ,L_EAM_OP_TBL(y).attribute_category
           ,L_EAM_OP_TBL(y).ATTRIBUTE1
           ,L_EAM_OP_TBL(y).ATTRIBUTE2
           ,L_EAM_OP_TBL(y).ATTRIBUTE3
           ,L_EAM_OP_TBL(y).ATTRIBUTE4
           ,L_EAM_OP_TBL(y).ATTRIBUTE5
           ,L_EAM_OP_TBL(y).ATTRIBUTE6
           ,L_EAM_OP_TBL(y).ATTRIBUTE7
           ,L_EAM_OP_TBL(y).ATTRIBUTE8
           ,L_EAM_OP_TBL(y).ATTRIBUTE9
           ,L_EAM_OP_TBL(y).ATTRIBUTE10
           ,L_EAM_OP_TBL(y).ATTRIBUTE11
           ,L_EAM_OP_TBL(y).ATTRIBUTE12
           ,L_EAM_OP_TBL(y).ATTRIBUTE13
           ,L_EAM_OP_TBL(y).ATTRIBUTE14
           ,L_EAM_OP_TBL(y).ATTRIBUTE15
           ,L_EAM_OP_TBL(y).long_description
         from wip_operations wo
         where
            wo.wip_entity_id            =  OP_CUR_TBL(y).WIP_ENTITY_ID
        and wo.OPERATION_SEQ_NUM        =  OP_CUR_TBL(y).OPERATION_SEQ_NUM
        and wo.organization_id          =  OP_CUR_TBL(y).ORGANIZATION_ID
        and wo.REPETITIVE_SCHEDULE_ID is NULL;


       l_op_index := l_op_index+1 ;


    END LOOP ;
    CLOSE OP_CUR;
    RETURN ;
   EXCEPTION   WHEN OTHERS THEN
--    var_buf := var_proc||' 4: '||sqlerrm;
--    fnd_file.put_line(FND_FILE.LOG, var_buf);
    MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'Exception in procedure GET_OP_DETAIL');
    RETURN;

END  GET_OP_DETAIL ;

 /****************************************************************************
   GET_RES_DETAIL :
   This procedure accepts a wip entity id fetches the Job operation resource
   details into plsql table L_EAM_RES_TBL

  ***************************************************************************/

PROCEDURE GET_RES_DETAIL(V_WIP_ENTITY_ID IN NUMBER ,
                         V_ORGANIZATION_ID IN NUMBER,
                  L_EAM_RES_TBL OUT NOCOPY EAM_PROCESS_WO_PUB.EAM_RES_TBL_TYPE )  IS

  l_res_index                NUMBER :=1;
  lv_stmt2    VARCHAR2(2000) ;
  RES_CUR CurTyp;
  RES_CUR_TBL  RES_CUR_TBL_TYPE ;
  lv_res_count number;

BEGIN
      var_proc :=  'GET_RES_DETAIL' ;

    lv_stmt2 := ' SELECT '
||'       WJDI.PARENT_HEADER_ID '
||'      ,WJDI.BATCH_ID '
||'      ,WJDI.WIP_ENTITY_ID WIP_ENTITY_ID '
||'      ,WJDI.ORGANIZATION_ID '
||'      ,WJDI.OPERATION_SEQ_NUM '
||'      ,WJDI.RESOURCE_SEQ_NUM  '
||'      ,WJDI.RESOURCE_ID_NEW RESOURCE_ID_NEW  '
||'      ,WJDI.BASIS_TYPE  '
||'      ,WJDI.USAGE_RATE_OR_AMOUNT '
||'      ,WJDI.SCHEDULED_FLAG '
||'      ,WJDI.ASSIGNED_UNITS '
||'      ,WJDI.AUTOCHARGE_TYPE '
||'      ,WJDI.START_DATE '
||'      ,WJDI.COMPLETION_DATE '
||'      ,WJDI.DEPARTMENT_ID DEPARTMENT_ID '
||'      ,WJDI.FIRM_FLAG '
||'       FROM MSC_WIP_JOB_DTLS_INTERFACE'||g_dblink||' WJDI '
||'       WHERE'
||'       WJDI.WIP_ENTITY_ID =  :V_WIP_ENTITY_ID '
||'       AND WJDI.ORGANIZATION_ID = :V_ORGANIZATION_ID '
||'       AND WJDI.GROUP_ID = :G_GROUP_ID'
||'       AND WJDI.LOAD_TYPE = 1 '   ;
     IF(L_EAM_RES_TBL.Count >0) THEN
           L_EAM_RES_TBL.delete(L_EAM_RES_TBL.FIRST,L_EAM_RES_TBL.last);
    END IF;
  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEV, lv_stmt2 );

    OPEN RES_CUR for lv_stmt2 using V_WIP_ENTITY_ID,V_ORGANIZATION_ID,G_GROUP_ID;
    FETCH RES_CUR  BULK COLLECT INTO RES_CUR_TBL ;
    lv_res_count := RES_CUR%ROWCOUNT;
    MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'SQL rowcount of RES_CUR is '||lv_res_count);
    MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'Number of records fetched into RES_CUR_TBL is '||RES_CUR_TBL.Count);
    FOR y IN 1..RES_CUR_TBL.Count LOOP
        -- Is header_id the indexing column for this ??
--        L_EAM_RES_TBL(y).HEADER_ID :=  RES_CUR_TBL(y).PARENT_HEADER_ID ;

        L_EAM_RES_TBL(y).HEADER_ID :=  0 ;
--        L_EAM_RES_TBL(y).BATCH_ID :=   RES_CUR_TBL(y).BATCH_ID; --RES_CUR_TBL(y).WIP_ENTITY_ID ;
        L_EAM_RES_TBL(y).BATCH_ID :=   1;
        L_EAM_RES_TBL(y).WIP_ENTITY_ID  :=  RES_CUR_TBL(y).WIP_ENTITY_ID;
        L_EAM_RES_TBL(y).ORGANIZATION_ID  :=  RES_CUR_TBL(y).ORGANIZATION_ID;
        L_EAM_RES_TBL(y).OPERATION_SEQ_NUM :=  RES_CUR_TBL(y).OPERATION_SEQ_NUM;
        L_EAM_RES_TBL(y).RESOURCE_SEQ_NUM :=  RES_CUR_TBL(y).RESOURCE_SEQ_NUM;
        L_EAM_RES_TBL(y).RESOURCE_ID :=  RES_CUR_TBL(y).RESOURCE_ID_NEW;
        L_EAM_RES_TBL(y).BASIS_TYPE  :=  RES_CUR_TBL(y).BASIS_TYPE;
        L_EAM_RES_TBL(y).USAGE_RATE_OR_AMOUNT :=
                                RES_CUR_TBL(y).USAGE_RATE_OR_AMOUNT;
        L_EAM_RES_TBL(y).SCHEDULED_FLAG :=  RES_CUR_TBL(y).SCHEDULED_FLAG;
        L_EAM_RES_TBL(y).ASSIGNED_UNITS :=  RES_CUR_TBL(y).ASSIGNED_UNITS;
        L_EAM_RES_TBL(y).AUTOCHARGE_TYPE :=  RES_CUR_TBL(y).AUTOCHARGE_TYPE;
        L_EAM_RES_TBL(y).START_DATE :=  RES_CUR_TBL(y).START_DATE;
        L_EAM_RES_TBL(y).COMPLETION_DATE :=  RES_CUR_TBL(y).COMPLETION_DATE;
        L_EAM_RES_TBL(y).DEPARTMENT_ID :=  RES_CUR_TBL(y).DEPARTMENT_ID;
        L_EAM_RES_TBL(y).TRANSACTION_TYPE  := EAM_PROCESS_WO_PVT.G_OPR_UPDATE;
        L_EAM_RES_TBL(y).FIRM_FLAG := RES_CUR_TBL(y).FIRM_FLAG;
        l_res_index := l_res_index+1 ;


    END LOOP ;
    CLOSE RES_CUR ;
       RETURN ;
   EXCEPTION
  WHEN OTHERS THEN
    MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'Exception in procedure GET_RES_DETAIL');
    RETURN;

END GET_RES_DETAIL;

 /****************************************************************************
   GET_mat_DETAIL :
   This procedure accepts a wip entity id,ORG_ID fetches the Component reqs
   details into plsql table L_EAM_MAT_TBL

  ***************************************************************************/

PROCEDURE GET_MAT_DETAIL(V_WIP_ENTITY_ID IN NUMBER ,V_ORGANIZATION_ID IN NUMBER,
          L_EAM_MAT_TBL OUT NOCOPY EAM_PROCESS_WO_PUB.EAM_MAT_REQ_TBL_TYPE )  IS

  l_mat_index                NUMBER :=1;
  lv_stmt2    VARCHAR2(2000) ;
  MAT_CUR CurTyp;
  MAT_CUR_TBL  MAT_CUR_TBL_TYPE ;
  lv_mat_count number;
BEGIN
      var_proc :=  'GET_MAT_DETAIL' ;

    lv_stmt2 := ' SELECT '
||'         WJDI.PARENT_HEADER_ID      '
||'        ,WJDI.BATCH_ID              '
||'        ,WJDI.WIP_ENTITY_ID WIP_ENTITY_ID '
||'        ,WJDI.ORGANIZATION_ID       '
||'        ,WJDI.OPERATION_SEQ_NUM     '
||'        ,WJDI.INVENTORY_ITEM_ID_NEW '
||'        ,WJDI.DEPARTMENT_ID DEPARTMENT_ID  '
||'        ,WJDI.WIP_SUPPLY_TYPE       '
||'        ,WJDI.DATE_REQUIRED         '
||'        ,WJDI.REQUIRED_QUANTITY     '
||'       FROM MSC_WIP_JOB_DTLS_INTERFACE'||g_dblink||' WJDI '
||'       WHERE'
||'       WJDI.WIP_ENTITY_ID = :V_WIP_ENTITY_ID '
||'       AND WJDI.ORGANIZATION_ID = :V_ORGANIZATION_ID '
||'       AND WJDI.GROUP_ID = :G_GROUP_ID'
||'       AND WJDI.LOAD_TYPE = 2 '   ;

     IF(L_EAM_MAT_TBL.Count >0) THEN
           L_EAM_MAT_TBL.delete(L_EAM_MAT_TBL.FIRST,L_EAM_MAT_TBL.last);
    END IF;
  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEV, lv_stmt2 );

    OPEN MAT_CUR for lv_stmt2 USING V_WIP_ENTITY_ID,V_ORGANIZATION_ID,G_GROUP_ID;
    FETCH MAT_CUR  BULK COLLECT INTO MAT_CUR_TBL ;
    lv_mat_count := MAT_CUR%ROWCOUNT;
    MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'SQL rowcount of MAT_CUR is '||lv_mat_count);
    MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'Number of records fetched into MAT_CUR_TBL is '||MAT_CUR_TBL.Count);
    FOR y IN 1..MAT_CUR_TBL.Count LOOP
        -- Is header_id the indexing column for this ??
--       L_EAM_MAT_TBL(y).HEADER_ID               := MAT_CUR_TBL(y).PARENT_HEADER_ID ;
       L_EAM_MAT_TBL(y).HEADER_ID               := 0 ;
--       L_EAM_MAT_TBL(y).BATCH_ID                := MAT_CUR_TBL(y).BATCH_ID;--MAT_CUR_TBL(y).WIP_ENTITY_ID;
       L_EAM_MAT_TBL(y).BATCH_ID                := 1;--MAT_CUR_TBL(y).WIP_ENTITY_ID;
       L_EAM_MAT_TBL(y).WIP_ENTITY_ID           := MAT_CUR_TBL(y).WIP_ENTITY_ID;
       L_EAM_MAT_TBL(y).ORGANIZATION_ID     := MAT_CUR_TBL(y).ORGANIZATION_ID ;
       L_EAM_MAT_TBL(y).OPERATION_SEQ_NUM  := MAT_CUR_TBL(y).OPERATION_SEQ_NUM ;
       L_EAM_MAT_TBL(y).INVENTORY_ITEM_ID   :=
                          MAT_CUR_TBL(y).INVENTORY_ITEM_ID_NEW;
       L_EAM_MAT_TBL(y).DEPARTMENT_ID    := MAT_CUR_TBL(y).DEPARTMENT_ID ;
       L_EAM_MAT_TBL(y).WIP_SUPPLY_TYPE  := MAT_CUR_TBL(y).WIP_SUPPLY_TYPE ;
       L_EAM_MAT_TBL(y).DATE_REQUIRED    := MAT_CUR_TBL(y).DATE_REQUIRED   ;
--       L_EAM_MAT_TBL(y).START_DATE    := MAT_CUR_TBL(y).DATE_REQUIRED   ;
--       L_EAM_MAT_TBL(y).END_DATE      := MAT_CUR_TBL(y).DATE_REQUIRED   ;
       L_EAM_MAT_TBL(y).REQUIRED_QUANTITY := MAT_CUR_TBL(y).REQUIRED_QUANTITY ;
       L_EAM_MAT_TBL(y).TRANSACTION_TYPE  := EAM_PROCESS_WO_PVT.G_OPR_UPDATE ;

      l_mat_index := l_mat_index+1 ;


    END LOOP ;
    CLOSE MAT_CUR ;
    RETURN ;
   EXCEPTION
  WHEN OTHERS THEN
--    var_buf := var_proc||' 6: '||sqlerrm;
--    fnd_file.put_line(FND_FILE.LOG, var_buf);
    MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'Exception in procedure GET_MAT_DETAIL');
    RETURN;

END GET_MAT_DETAIL;

 /****************************************************************************
   GET_RES_DETAIL :
   This procedure accepts a wip entity id and fetches the Job operation resource

  ***************************************************************************/

PROCEDURE GET_RES_INST_DETAIL(V_WIP_ENTITY_ID IN NUMBER ,
                         V_ORGANIZATION_ID IN NUMBER,
          L_EAM_RES_INST_TBL OUT NOCOPY EAM_PROCESS_WO_PUB.EAM_RES_INST_TBL_TYPE)  IS

  l_res_index                NUMBER :=1;
  lv_stmt2    VARCHAR2(2000) ;
  lv_res_inst_count number;
  RES_INST_CUR CurTyp;
  RES_INST_CUR_TBL  RES_INST_CUR_TBL_TYPE ;
BEGIN
      var_proc :=  'GET_RES_INST_DETAIL' ;

lv_stmt2 :=  'SELECT                  '
||'          WJDI.PARENT_HEADER_ID    '
||'         ,WJDI.BATCH_ID,           '
||'         WJDI.WIP_ENTITY_ID WIP_ENTITY_ID , '
||'         WJDI.ORGANIZATION_ID,     '
||'         WJDI.OPERATION_SEQ_NUM,   '
||'         WJDI.RESOURCE_SEQ_NUM,    '
||'         WJDI.RESOURCE_INSTANCE_ID, '   /*check if this is correct or not- this is prob not sr_instance_id */
||'         WJDI.SERIAL_NUMBER,       '
||'         WJDI.START_DATE,          '
||'         WJDI.COMPLETION_DATE      '
||'         FROM MSC_WIP_JOB_DTLS_INTERFACE'||g_dblink||' WJDI'
||'         WHERE '
||'       WJDI.WIP_ENTITY_ID = :V_WIP_ENTITY_ID '
||'       AND WJDI.ORGANIZATION_ID = :V_ORGANIZATION_ID '
||'       AND WJDI.GROUP_ID = :G_GROUP_ID'
||'       AND WJDI.LOAD_TYPE = 8';

MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEV, lv_stmt2 );

    OPEN RES_INST_CUR for lv_stmt2 using V_WIP_ENTITY_ID,V_ORGANIZATION_ID,G_GROUP_ID;
    FETCH RES_INST_CUR  BULK COLLECT INTO RES_INST_CUR_TBL ;
    lv_res_inst_count := RES_INST_CUR%ROWCOUNT;
    MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'SQL rowcount of RES_INST_CUR is '||lv_res_inst_count);
    MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'Number of records fetched into RES_INST_CUR_TBL is '||RES_INST_CUR_TBL.Count);
    FOR y in 1..RES_INST_CUR_TBL.Count LOOP

--         L_EAM_RES_INST_TBL(y).HEADER_ID := RES_INST_CUR_TBL(y).PARENT_HEADER_ID;
         L_EAM_RES_INST_TBL(y).HEADER_ID := 0;
--         L_EAM_RES_INST_TBL(y).BATCH_ID := RES_INST_CUR_TBL(y).BATCH_ID;--RES_INST_CUR_TBL(y).WIP_ENTITY_ID;
         L_EAM_RES_INST_TBL(y).BATCH_ID := 1;--RES_INST_CUR_TBL(y).WIP_ENTITY_ID;
         L_EAM_RES_INST_TBL(y).WIP_ENTITY_ID := RES_INST_CUR_TBL(y).WIP_ENTITY_ID;
         L_EAM_RES_INST_TBL(y).ORGANIZATION_ID := RES_INST_CUR_TBL(y).ORGANIZATION_ID  ;
         L_EAM_RES_INST_TBL(y).OPERATION_SEQ_NUM  := RES_INST_CUR_TBL(y).OPERATION_SEQ_NUM  ;
         L_EAM_RES_INST_TBL(y).RESOURCE_SEQ_NUM    := RES_INST_CUR_TBL(y).RESOURCE_SEQ_NUM  ;
         L_EAM_RES_INST_TBL(y).INSTANCE_ID   := RES_INST_CUR_TBL(y).RESOURCE_INSTANCE_ID  ;
         L_EAM_RES_INST_TBL(y).SERIAL_NUMBER  := RES_INST_CUR_TBL(y).SERIAL_NUMBER  ;
         L_EAM_RES_INST_TBL(y).START_DATE    := RES_INST_CUR_TBL(y).START_DATE  ;
         L_EAM_RES_INST_TBL(y).COMPLETION_DATE    := RES_INST_CUR_TBL(y).COMPLETION_DATE  ;
         L_EAM_RES_INST_TBL(y).TRANSACTION_TYPE  := EAM_PROCESS_WO_PVT.G_OPR_UPDATE ;
         l_res_index := l_res_index + 1;

    END LOOP;
    CLOSE RES_INST_CUR;
     RETURN ;
   EXCEPTION  WHEN OTHERS THEN
    MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'Exception in procedure GET_RES_INST_DETAIL');
    RETURN;

END GET_RES_INST_DETAIL;

PROCEDURE GET_RES_USAGE_DETAIL(V_WIP_ENTITY_ID IN NUMBER ,V_ORGANIZATION_ID IN NUMBER,
                  L_EAM_RES_USAGE_TBL OUT NOCOPY EAM_PROCESS_WO_PUB.EAM_RES_USAGE_TBL_TYPE)  IS
l_res_usage_index NUMBER :=1;
lv_stmt2 VARCHAR2(2000) ;
RES_USAGE_CUR CurTyp;
RES_USAGE_CUR_TBL  RES_USAGE_CUR_TBL_TYPE ;
BEGIN
      var_proc :=  'GET_RES_USAGE_DETAIL' ;

lv_stmt2 := 'SELECT          '
||'         WJDI.PARENT_HEADER_ID,    '
||'         WJDI.BATCH_ID,            '
||'         WJDI.WIP_ENTITY_ID WIP_ENTITY_ID ,  '
||'         WJDI.ORGANIZATION_ID,     '
||'         WJDI.OPERATION_SEQ_NUM,   '
||'         WJDI.RESOURCE_SEQ_NUM,    '
||'         WJDI.START_DATE,          '
||'         WJDI.COMPLETION_DATE,     '
||'         WJDI.ASSIGNED_UNITS,      '
||'         WJDI.RESOURCE_INSTANCE_ID,      '
||'         WJDI.SERIAL_NUMBER        '
||'         FROM MSC_WIP_JOB_DTLS_INTERFACE'||g_dblink||' WJDI'
||'         WHERE'
||'         WJDI.WIP_ENTITY_ID =  :V_WIP_ENTITY_ID '
||'         AND WJDI.ORGANIZATION_ID = :V_ORGANIZATION_ID '
||'         AND WJDI.GROUP_ID = :G_GROUP_ID'
||'         AND WJDI.LOAD_TYPE = 4';

          MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEV, lv_stmt2 );
          OPEN RES_USAGE_CUR for lv_stmt2 using V_WIP_ENTITY_ID,V_ORGANIZATION_ID,G_GROUP_ID;
          FETCH RES_USAGE_CUR BULK COLLECT INTO RES_USAGE_CUR_TBL;

          FOR y in 1..RES_USAGE_CUR_TBL.Count LOOP

--               L_EAM_RES_USAGE_TBL(y).HEADER_ID := RES_USAGE_CUR_TBL(y).PARENT_HEADER_ID;
               L_EAM_RES_USAGE_TBL(y).HEADER_ID := 0;
--               L_EAM_RES_USAGE_TBL(y).BATCH_ID := RES_USAGE_CUR_TBL(y).BATCH_ID;--RES_USAGE_CUR_TBL(y).WIP_ENTITY_ID;
               L_EAM_RES_USAGE_TBL(y).BATCH_ID := 1;--RES_USAGE_CUR_TBL(y).WIP_ENTITY_ID;
               L_EAM_RES_USAGE_TBL(y).WIP_ENTITY_ID := RES_USAGE_CUR_TBL(y).WIP_ENTITY_ID ;
               L_EAM_RES_USAGE_TBL(y).OPERATION_SEQ_NUM := RES_USAGE_CUR_TBL(y).OPERATION_SEQ_NUM ;
               L_EAM_RES_USAGE_TBL(y).RESOURCE_SEQ_NUM := RES_USAGE_CUR_TBL(y).RESOURCE_SEQ_NUM ;
               L_EAM_RES_USAGE_TBL(y).ORGANIZATION_ID := RES_USAGE_CUR_TBL(y).ORGANIZATION_ID ;
               L_EAM_RES_USAGE_TBL(y).START_DATE := RES_USAGE_CUR_TBL(y).START_DATE ;
               L_EAM_RES_USAGE_TBL(y).COMPLETION_DATE := RES_USAGE_CUR_TBL(y).COMPLETION_DATE ;
               L_EAM_RES_USAGE_TBL(y).ASSIGNED_UNITS := RES_USAGE_CUR_TBL(y).ASSIGNED_UNITS ;
               L_EAM_RES_USAGE_TBL(y).SERIAL_NUMBER := RES_USAGE_CUR_TBL(y).SERIAL_NUMBER ;
               L_EAM_RES_USAGE_TBL(y).INSTANCE_ID := RES_USAGE_CUR_TBL(y).RESOURCE_INSTANCE_ID ;
               L_EAM_RES_USAGE_TBL(y).TRANSACTION_TYPE  := EAM_PROCESS_WO_PVT.G_OPR_UPDATE ;
               l_res_usage_index := l_res_usage_index + 1;

          END LOOP;
          RETURN ;
   EXCEPTION  WHEN OTHERS THEN
    MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'Exception in procedure GET_RES_USAGE_DETAIL');
    RETURN;

END GET_RES_USAGE_DETAIL;

PROCEDURE  POPULATE_MISSING_DETAILS( V_WIP_ENTITY_ID IN NUMBER
                              ,V_ORGANIZATION_ID IN NUMBER
                              ,P_JOB_START_DATE IN DATE)
IS
lv_stmt2    VARCHAR2(32000) ;

BEGIN

      var_proc :=  'POPULATE_MISSING_DETAILS' ;
MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1, 'In   POPULATE_MISSING_DETAILS' );

lv_stmt2 :=  'INSERT INTO MSC_WIP_JOB_DTLS_INTERFACE'||g_dblink||'('
||'              GROUP_ID                           '
||'             ,OPERATION_SEQ_NUM                  '
||'             ,DEPARTMENT_ID                      '
||'             ,LAST_UPDATE_DATE                   '
||'             ,LAST_UPDATED_BY                    '
||'             ,CREATION_DATE                      '
||'             ,CREATED_BY                         '
||'             ,LAST_UPDATE_LOGIN                  '
||'             ,DESCRIPTION                        '
||'             ,STANDARD_OPERATION_ID              '
||'             ,FIRST_UNIT_START_DATE              '
||'             ,FIRST_UNIT_COMPLETION_DATE         '
||'             ,LAST_UNIT_START_DATE               '
||'             ,LAST_UNIT_COMPLETION_DATE          '
||'             ,COUNT_POINT_TYPE                   '
||'             ,BACKFLUSH_FLAG                     '
||'             ,MINIMUM_TRANSFER_QUANTITY          '
||'             ,WIP_ENTITY_ID                      '
||'             ,ORGANIZATION_ID                    '
||'             ,SCHEDULED_QUANTITY                 '
||'             ,LOAD_TYPE                          '
-- , Col to identify this insert
-- , FIND IF ANY OTHER REQUIRED COLUMN MISSING AND HOW TO DERIVE SUCH DATA
||'             )SELECT                             '
||'             :g_group_id                         '
||'             ,WO.OPERATION_SEQ_NUM               '
||'             ,WO.DEPARTMENT_ID                   '
||'             ,SYSDATE                            '
||'             ,-1                                 ' -- do we need to change this?
||'             ,SYSDATE                            '
||'             ,-1                                 '
||'             ,-1                                 '
||'             ,WO.DESCRIPTION                     '
||'             ,WO.STANDARD_OPERATION_ID           '
||'             ,:P_JOB_START_DATE                  '
||'             ,:P_JOB_START_DATE                  '
||'             ,:P_JOB_START_DATE                  '
||'             ,:P_JOB_START_DATE                  '
||'             ,WO.COUNT_POINT_TYPE                '
||'             ,WO.BACKFLUSH_FLAG                  '
||'             ,WO.MINIMUM_TRANSFER_QUANTITY       '
||'             ,WO.WIP_ENTITY_ID                   '
||'             ,WO.ORGANIZATION_ID                 '
||'             ,WO.SCHEDULED_QUANTITY              '
||'             ,3                                  '
||'              FROM WIP_OPERATIONS  WO            '
||'              WHERE  WO.WIP_ENTITY_ID = :V_WIP_ENTITY_ID'
||'              AND WO.ORGANIZATION_ID = :V_ORGANIZATION_ID'
||'              AND WO.OPERATION_SEQ_NUM NOT IN    '
||'              (select operation_seq_num           '
||'              from msc_wip_job_dtls_interface'||g_dblink||' mwjdi'
||'              where mwjdi.group_id = :g_group_id  '
||'              and mwjdi.wip_entity_id = :V_WIP_ENTITY_ID'
||'              and mwjdi.organization_id = :V_ORGANIZATION_ID'
||'              and mwjdi.load_type = 3)';

 -- MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1, lv_stmt2 );

EXECUTE IMMEDIATE lv_stmt2 using
                             g_group_id
                            ,P_JOB_START_DATE
                            ,P_JOB_START_DATE
                            ,P_JOB_START_DATE
                            ,P_JOB_START_DATE
                            ,V_WIP_ENTITY_ID
                            ,V_ORGANIZATION_ID
                            ,g_group_id
                            ,V_WIP_ENTITY_ID
                            ,V_ORGANIZATION_ID;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,
                 'Number of missing records fetched'||
                 ' from WIP_OPERATIONS is '||SQL%RowCount);
--missing resources load_type = 1

lv_stmt2 :=  'INSERT INTO MSC_WIP_JOB_DTLS_INTERFACE'||g_dblink||'('
||'            GROUP_ID                     '
||'           ,BATCH_ID                     '
||'           ,WIP_ENTITY_ID                '
||'           ,ORGANIZATION_ID              '
||'           ,OPERATION_SEQ_NUM            '
||'           ,RESOURCE_SEQ_NUM             '
||'           ,RESOURCE_ID_NEW              '
||'           ,BASIS_TYPE                   '
||'           ,USAGE_RATE_OR_AMOUNT         '
||'           ,SCHEDULED_FLAG               '
||'           ,ASSIGNED_UNITS               '
||'           ,AUTOCHARGE_TYPE              '
||'           ,START_DATE                   '
||'           ,COMPLETION_DATE              '
||'           ,DEPARTMENT_ID                '
||'           ,LOAD_TYPE                    '
||'           ,LAST_UPDATE_DATE             '
||'           ,LAST_UPDATED_BY              '
||'           ,CREATION_DATE                '
||'           ,CREATED_BY                   '
||'           ,LAST_UPDATE_LOGIN)           '
||'     SELECT                              '
||'              :g_group_id                '
||'             ,wor.BATCH_ID               '
||'             ,wor.WIP_ENTITY_ID          '
||'             ,wor.ORGANIZATION_ID        '
||'             ,wor.OPERATION_SEQ_NUM      '
||'             ,wor.RESOURCE_SEQ_NUM       '
||'             ,wor.RESOURCE_ID            '
||'             ,wor.BASIS_TYPE             '
||'             ,wor.USAGE_RATE_OR_AMOUNT   '
||'             ,wor.SCHEDULED_FLAG         '
||'             ,wor.ASSIGNED_UNITS         '
||'             ,wor.AUTOCHARGE_TYPE        '
||'             ,:P_JOB_START_DATE          '
||'             ,:P_JOB_START_DATE          '
||'             ,wor.DEPARTMENT_ID          '
||'             ,1                          '
||'             ,SYSDATE                    '
||'             ,-1                         '
||'             ,SYSDATE                    '
||'             ,-1                         '
||'             ,-1                         '
||'             FROM WIP_OPERATION_RESOURCES wor'
||'            where                        '
||'            wor.wip_entity_id = :V_WIP_ENTITY_ID '
||'            and wor.organization_id = :V_ORGANIZATION_ID'
||'            and (wor.operation_seq_num,wor.resource_seq_num) '
||'            not in                       '
||'            (select operation_seq_num,resource_seq_num  '
||'             from msc_wip_job_dtls_interface'||g_dblink||' mwjdi'
||'              where mwjdi.group_id = :g_group_id  '
||'              and mwjdi.wip_entity_id = :V_WIP_ENTITY_ID'
||'              and mwjdi.organization_id = :V_ORGANIZATION_ID'
||'              and mwjdi.load_type = 1)';
 --MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1, lv_stmt2 );

EXECUTE IMMEDIATE lv_stmt2 using
                             g_group_id
                            ,P_JOB_START_DATE
                            ,P_JOB_START_DATE
                            ,V_WIP_ENTITY_ID
                            ,V_ORGANIZATION_ID
                            ,g_group_id
                            ,V_WIP_ENTITY_ID
                            ,V_ORGANIZATION_ID;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,
                 'Number of missing records fetched'||
                 ' from WIP_OPERATION_RESOURCES is '||SQL%RowCount);
--missing requirement_operations, load_type = 2
lv_stmt2 :=  'INSERT INTO MSC_WIP_JOB_DTLS_INTERFACE'||g_dblink||'('
||'              GROUP_ID                         '
||'             ,BATCH_ID                         '
||'             ,WIP_ENTITY_ID                    '
||'             ,ORGANIZATION_ID                  '
||'             ,OPERATION_SEQ_NUM                '
||'             ,INVENTORY_ITEM_ID_NEW            '
||'             ,DEPARTMENT_ID                    '
||'             ,WIP_SUPPLY_TYPE                  '
||'             ,DATE_REQUIRED                    '
||'             ,REQUIRED_QUANTITY                '
||'             ,LOAD_TYPE                        '
||'             ,LAST_UPDATE_DATE                   '
||'             ,LAST_UPDATED_BY                    '
||'             ,CREATION_DATE                      '
||'             ,CREATED_BY                         '
||'             ,LAST_UPDATE_LOGIN)                 '
||'        SELECT                                   '
||'              :g_group_id                        '
||'             ,1                                  ' -- No col wro.BATCH_ID derive it
||'             ,wro.wip_entity_id                  '
||'             ,wro.ORGANIZATION_ID                '
||'             ,wro.operation_seq_num              '
||'             ,wro.inventory_item_id              '
||'             ,wro.department_id                  '
||'             ,wro.wip_supply_type                '
||'             ,:P_JOB_START_DATE                  '
||'             ,wro.required_quantity              '
||'             ,2                                  '
||'             ,SYSDATE                            '
||'             ,-1                                 '
||'             ,SYSDATE                            '
||'             ,-1                                 '
||'             ,-1                                 '
||'             FROM WIP_REQUIREMENT_OPERATIONS wro '
||'             where                               '
||'             wro.wip_entity_id = :V_WIP_ENTITY_ID '
||'             and wro.organization_id = :V_ORGANIZATION_ID'
||'             AND ( wro.OPERATION_SEQ_NUM,          '
||'             wro.inventory_item_id ) NOT IN        '
||'             (select operation_seq_num,          '
||'              inventory_item_id_new              '
||'             from msc_wip_job_dtls_interface'||g_dblink||' mwjdi'
||'             where mwjdi.group_id = :g_group_id  '
||'             and mwjdi.wip_entity_id = :V_WIP_ENTITY_ID'
||'             and mwjdi.organization_id = :V_ORGANIZATION_ID'
||'             and mwjdi.load_type = 2)';

--MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1, lv_stmt2 );

EXECUTE IMMEDIATE lv_stmt2 using
                             g_group_id
                            ,P_JOB_START_DATE
                            ,V_WIP_ENTITY_ID
                            ,V_ORGANIZATION_ID
                            ,g_group_id
                            ,V_WIP_ENTITY_ID
                            ,V_ORGANIZATION_ID;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,
                 'Number of missing records fetched'||
                 ' from WIP_REQUIREMENT_OPERATIONS is '||SQL%RowCount);
   RETURN ;
   EXCEPTION  WHEN OTHERS THEN
    MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,'Exception in procedure POPULATE_MISSING_DETAILS');
   RETURN;



END  POPULATE_MISSING_DETAILS ;



END MRP_RESCHEDULE_CMRO_WO_PS;

/
