--------------------------------------------------------
--  DDL for Package Body PJI_FM_XBS_ACCUM_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_FM_XBS_ACCUM_UTILS" AS
/* $Header: PJIPUT1B.pls 120.41.12010000.3 2009/06/22 17:57:53 apaul ship $ */

g_package_name VARCHAR2(100) := 'PJI_FM_XBS_ACCUM_UTILS';
g_debug_mode varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N') ;

PROCEDURE PRINT_TIME(p_tag IN VARCHAR2);


-----------------------------------------------------------------
-- This API supports 3 kinds of data retrieval
--   1. Entered level data at task level by resource list member
--   2. Entered level data at project level by resource list member
--   3. Rollup data by task (no resource list member context)
-----------------------------------------------------------------
  /*Changed for workplan progress.  p_end_date              IN   DATE ,
     p_calendar_type IN VARCHAR2
     and added p_extraction_type IN VARCHAR2 := NULL,
     p_calling_context       IN   VARCHAR2 := NULL,
     */

/* added procedure for bug#3993830 */
PROCEDURE debug_accum
IS
BEGIN
INSERT INTO pji_fm_xbs_accum_tmp1_debug
 (
  PROJECT_ID                             ,
  STRUCT_VERSION_ID                      ,
  PROJECT_ELEMENT_ID                     ,
  CALENDAR_TYPE                          ,
  PERIOD_NAME                            ,
  PLAN_VERSION_ID                        ,
  RES_LIST_MEMBER_ID                     ,
  QUANTITY                               ,
  TXN_CURRENCY_CODE                      ,
  TXN_RAW_COST                           ,
  TXN_BRDN_COST                          ,
  TXN_REVENUE                            ,
  TXN_LABOR_RAW_COST                     ,
  TXN_LABOR_BRDN_COST                    ,
  TXN_EQUIP_RAW_COST                     ,
  TXN_EQUIP_BRDN_COST                    ,
  TXN_BASE_RAW_COST                      ,
  TXN_BASE_BRDN_COST                     ,
  TXN_BASE_LABOR_RAW_COST                ,
  TXN_BASE_LABOR_BRDN_COST               ,
  TXN_BASE_EQUIP_RAW_COST                ,
  TXN_BASE_EQUIP_BRDN_COST               ,
  PRJ_RAW_COST                           ,
  PRJ_BRDN_COST                          ,
  PRJ_REVENUE                            ,
  PRJ_LABOR_RAW_COST                     ,
  PRJ_LABOR_BRDN_COST                    ,
  PRJ_EQUIP_RAW_COST                     ,
  PRJ_EQUIP_BRDN_COST                    ,
  PRJ_BASE_RAW_COST                      ,
  PRJ_BASE_BRDN_COST                     ,
  PRJ_BASE_LABOR_RAW_COST                ,
  PRJ_BASE_LABOR_BRDN_COST               ,
  PRJ_BASE_EQUIP_RAW_COST                ,
  PRJ_BASE_EQUIP_BRDN_COST               ,
  POU_RAW_COST                           ,
  POU_BRDN_COST                          ,
  POU_REVENUE                            ,
  POU_LABOR_RAW_COST                     ,
  POU_LABOR_BRDN_COST                    ,
  POU_EQUIP_RAW_COST                     ,
  POU_EQUIP_BRDN_COST                    ,
  POU_BASE_RAW_COST                      ,
  POU_BASE_BRDN_COST                     ,
  POU_BASE_LABOR_RAW_COST                ,
  POU_BASE_LABOR_BRDN_COST               ,
  POU_BASE_EQUIP_RAW_COST                ,
  POU_BASE_EQUIP_BRDN_COST               ,
  LABOR_HOURS                            ,
  EQUIPMENT_HOURS                        ,
  BASE_LABOR_HOURS                       ,
  BASE_EQUIP_HOURS                       ,
  SOURCE_ID                              ,
  ACT_LABOR_HRS                          ,
  ACT_EQUIP_HRS                          ,
  ACT_TXN_LABOR_BRDN_COST                ,
  ACT_TXN_EQUIP_BRDN_COST                ,
  ACT_TXN_BRDN_COST                      ,
  ACT_PRJ_LABOR_BRDN_COST                ,
  ACT_PRJ_EQUIP_BRDN_COST                ,
  ACT_PRJ_BRDN_COST                      ,
  ACT_PFC_LABOR_BRDN_COST                ,
  ACT_PFC_EQUIP_BRDN_COST                ,
  ACT_PFC_BRDN_COST                      ,
  ETC_LABOR_HRS                          ,
  ETC_EQUIP_HRS                          ,
  ETC_TXNLABOR_BRDN_COST                 ,
  ETC_TXN_EQUIP_BRDN_COST                ,
  ETC_TXN_BRDN_COST                      ,
  ETC_PRJ_LABOR_BRDN_COST                ,
  ETC_PRJ_EQUIP_BRDN_COST                ,
  ETC_PRJ_BRDN_COST                      ,
  ETC_POU_LABOR_BRDN_COST                ,
  ETC_POU_EQUIP_BRDN_COST                ,
  ETC_POU_BRDN_COST                      ,
  ACT_TXN_RAW_COST                       ,
  ACT_PRJ_RAW_COST                       ,
  ACT_POU_RAW_COST                       ,
  ETC_TXN_RAW_COST                       ,
  ETC_PRJ_RAW_COST                       ,
  ETC_POU_RAW_COST                       ,
  ACT_TXN_LABOR_RAW_COST                 ,
  ACT_TXN_EQUIP_RAW_COST                 ,
  ACT_PRJ_LABOR_RAW_COST                 ,
  ACT_PRJ_EQUIP_RAW_COST                 ,
  ACT_POU_LABOR_RAW_COST                 ,
  ACT_POU_EQUIP_RAW_COST                 ,
  ETC_TXN_LABOR_RAW_COST                 ,
  ETC_TXN_EQUIP_RAW_COST                 ,
  ETC_PRJ_LABOR_RAW_COST                 ,
  ETC_PRJ_EQUIP_RAW_COST                 ,
  ETC_POU_LABOR_RAW_COST                 ,
  ETC_POU_EQUIP_RAW_COST                 ,
  ACT_POU_LABOR_BRDN_COST                ,
  ACT_POU_EQUIP_BRDN_COST                ,
  ACT_POU_BRDN_COST                      ,
  ETC_TXN_LABOR_BRDN_COST                ,
  TXN_LPB_RAW_COST                       ,
  TXN_LPB_BRDN_COST                      ,
  TXN_LPB_LABOR_RAW_COST                 ,
  TXN_LPB_LABOR_BRDN_COST                ,
  TXN_LPB_EQUIP_RAW_COST                 ,
  TXN_LPB_EQUIP_BRDN_COST                ,
  PRJ_LPB_RAW_COST                       ,
  PRJ_LPB_BRDN_COST                      ,
  PRJ_LPB_LABOR_RAW_COST                 ,
  PRJ_LPB_LABOR_BRDN_COST                ,
  PRJ_LPB_EQUIP_RAW_COST                 ,
  PRJ_LPB_EQUIP_BRDN_COST                ,
  POU_LPB_RAW_COST                       ,
  POU_LPB_BRDN_COST                      ,
  POU_LPB_LABOR_RAW_COST                 ,
  POU_LPB_LABOR_BRDN_COST                ,
  POU_LPB_EQUIP_RAW_COST                 ,
  POU_LPB_EQUIP_BRDN_COST                ,
  LPB_LABOR_HOURS                        ,
  LPB_EQUIP_HOURS                        ,
  PERIOD_FLAG                            ,
  CREATION_DATE
 )
SELECT
  PROJECT_ID                             ,
  STRUCT_VERSION_ID                      ,
  PROJECT_ELEMENT_ID                     ,
  CALENDAR_TYPE                          ,
  PERIOD_NAME                            ,
  PLAN_VERSION_ID                        ,
  RES_LIST_MEMBER_ID                     ,
  QUANTITY                               ,
  TXN_CURRENCY_CODE                      ,
  TXN_RAW_COST                           ,
  TXN_BRDN_COST                          ,
  TXN_REVENUE                            ,
  TXN_LABOR_RAW_COST                     ,
  TXN_LABOR_BRDN_COST                    ,
  TXN_EQUIP_RAW_COST                     ,
  TXN_EQUIP_BRDN_COST                    ,
  TXN_BASE_RAW_COST                      ,
  TXN_BASE_BRDN_COST                     ,
  TXN_BASE_LABOR_RAW_COST                ,
  TXN_BASE_LABOR_BRDN_COST               ,
  TXN_BASE_EQUIP_RAW_COST                ,
  TXN_BASE_EQUIP_BRDN_COST               ,
  PRJ_RAW_COST                           ,
  PRJ_BRDN_COST                          ,
  PRJ_REVENUE                            ,
  PRJ_LABOR_RAW_COST                     ,
  PRJ_LABOR_BRDN_COST                    ,
  PRJ_EQUIP_RAW_COST                     ,
  PRJ_EQUIP_BRDN_COST                    ,
  PRJ_BASE_RAW_COST                      ,
  PRJ_BASE_BRDN_COST                     ,
  PRJ_BASE_LABOR_RAW_COST                ,
  PRJ_BASE_LABOR_BRDN_COST               ,
  PRJ_BASE_EQUIP_RAW_COST                ,
  PRJ_BASE_EQUIP_BRDN_COST               ,
  POU_RAW_COST                           ,
  POU_BRDN_COST                          ,
  POU_REVENUE                            ,
  POU_LABOR_RAW_COST                     ,
  POU_LABOR_BRDN_COST                    ,
  POU_EQUIP_RAW_COST                     ,
  POU_EQUIP_BRDN_COST                    ,
  POU_BASE_RAW_COST                      ,
  POU_BASE_BRDN_COST                     ,
  POU_BASE_LABOR_RAW_COST                ,
  POU_BASE_LABOR_BRDN_COST               ,
  POU_BASE_EQUIP_RAW_COST                ,
  POU_BASE_EQUIP_BRDN_COST               ,
  LABOR_HOURS                            ,
  EQUIPMENT_HOURS                        ,
  BASE_LABOR_HOURS                       ,
  BASE_EQUIP_HOURS                       ,
  SOURCE_ID                              ,
  ACT_LABOR_HRS                          ,
  ACT_EQUIP_HRS                          ,
  ACT_TXN_LABOR_BRDN_COST                ,
  ACT_TXN_EQUIP_BRDN_COST                ,
  ACT_TXN_BRDN_COST                      ,
  ACT_PRJ_LABOR_BRDN_COST                ,
  ACT_PRJ_EQUIP_BRDN_COST                ,
  ACT_PRJ_BRDN_COST                      ,
  ACT_PFC_LABOR_BRDN_COST                ,
  ACT_PFC_EQUIP_BRDN_COST                ,
  ACT_PFC_BRDN_COST                      ,
  ETC_LABOR_HRS                          ,
  ETC_EQUIP_HRS                          ,
  ETC_TXNLABOR_BRDN_COST                 ,
  ETC_TXN_EQUIP_BRDN_COST                ,
  ETC_TXN_BRDN_COST                      ,
  ETC_PRJ_LABOR_BRDN_COST                ,
  ETC_PRJ_EQUIP_BRDN_COST                ,
  ETC_PRJ_BRDN_COST                      ,
  ETC_POU_LABOR_BRDN_COST                ,
  ETC_POU_EQUIP_BRDN_COST                ,
  ETC_POU_BRDN_COST                      ,
  ACT_TXN_RAW_COST                       ,
  ACT_PRJ_RAW_COST                       ,
  ACT_POU_RAW_COST                       ,
  ETC_TXN_RAW_COST                       ,
  ETC_PRJ_RAW_COST                       ,
  ETC_POU_RAW_COST                       ,
  ACT_TXN_LABOR_RAW_COST                 ,
  ACT_TXN_EQUIP_RAW_COST                 ,
  ACT_PRJ_LABOR_RAW_COST                 ,
  ACT_PRJ_EQUIP_RAW_COST                 ,
  ACT_POU_LABOR_RAW_COST                 ,
  ACT_POU_EQUIP_RAW_COST                 ,
  ETC_TXN_LABOR_RAW_COST                 ,
  ETC_TXN_EQUIP_RAW_COST                 ,
  ETC_PRJ_LABOR_RAW_COST                 ,
  ETC_PRJ_EQUIP_RAW_COST                 ,
  ETC_POU_LABOR_RAW_COST                 ,
  ETC_POU_EQUIP_RAW_COST                 ,
  ACT_POU_LABOR_BRDN_COST                ,
  ACT_POU_EQUIP_BRDN_COST                ,
  ACT_POU_BRDN_COST                      ,
  ETC_TXN_LABOR_BRDN_COST                ,
  TXN_LPB_RAW_COST                       ,
  TXN_LPB_BRDN_COST                      ,
  TXN_LPB_LABOR_RAW_COST                 ,
  TXN_LPB_LABOR_BRDN_COST                ,
  TXN_LPB_EQUIP_RAW_COST                 ,
  TXN_LPB_EQUIP_BRDN_COST                ,
  PRJ_LPB_RAW_COST                       ,
  PRJ_LPB_BRDN_COST                      ,
  PRJ_LPB_LABOR_RAW_COST                 ,
  PRJ_LPB_LABOR_BRDN_COST                ,
  PRJ_LPB_EQUIP_RAW_COST                 ,
  PRJ_LPB_EQUIP_BRDN_COST                ,
  POU_LPB_RAW_COST                       ,
  POU_LPB_BRDN_COST                      ,
  POU_LPB_LABOR_RAW_COST                 ,
  POU_LPB_LABOR_BRDN_COST                ,
  POU_LPB_EQUIP_RAW_COST                 ,
  POU_LPB_EQUIP_BRDN_COST                ,
  LPB_LABOR_HOURS                        ,
  LPB_EQUIP_HOURS                        ,
  PERIOD_FLAG                            ,
  SYSDATE
 FROM
  pji_fm_xbs_accum_tmp1 ;

END;
----------------------------------------------------------------------------
-- Created DEGUPTA
-- To delete fin8 table data from pa_progress_pub.get_summarized_actuals API
-- Removing the delete from this package API get_summarized_actuals
-- Bug No. 5349102
----------------------------------------------------------------------------
PROCEDURE DELETE_FIN8(
    p_project_id    IN   NUMBER,
    p_calendar_type IN   VARCHAR2 DEFAULT NULL,
    p_end_date      IN   DATE DEFAULT NULL,
    p_err_flag      IN NUMBER DEFAULT 0,
    p_err_msg       IN VARCHAR2 DEFAULT NULL
) IS

l_period_type_id NUMBER;
l_calendar_type VARCHAR2(1);
l_org_id NUMBER;
l_end_period_id NUMBER;
BEGIN

   pa_debug.log_message('DELETE_FIN8: p_project_id'||p_project_id||'p_err_flag'||p_err_flag||'p_err_msg '||p_err_msg , 3);
IF p_err_flag =1 THEN
   update pji_pjp_proj_batch_map set act_err_msg=p_err_msg
   where project_id=p_project_id;

else
      print_time ( ' Deleting pji_fm_aggr_fin8 0001 p_calendar_type ' || p_calendar_type ) ;
           IF (p_calendar_type = 'N') THEN
      print_time ( ' Deleting pji_fm_aggr_fin8 0001.1 ' ) ;
             l_calendar_type := 'A';
             l_period_type_id := 2048;
           ELSIF (p_calendar_type = 'P') THEN
      print_time ( ' Deleting pji_fm_aggr_fin8 0001.2 ' ) ;
             l_calendar_type := 'P';
             l_period_type_id := 32;
           ELSE
      print_time ( ' Deleting pji_fm_aggr_fin8 0001.3 ' ) ;
             l_calendar_type := 'G';
             l_period_type_id := 32;
           END IF;
      print_time ( ' get_summarized_data 0002 ' ) ;

      SELECT ORG_ID
          INTO   l_org_id
          FROM   pa_projects_all
          WHERE  project_id = p_project_id;

      IF l_calendar_type ='A' then
             l_end_period_id :=-1;
      ELSE
      BEGIN
        SELECT cal.CAL_PERIOD_ID
        INTO l_end_period_id
        FROM pji_time_cal_period_v cal,
             pji_org_extr_info    info
        WHERE TRUNC(p_end_date) BETWEEN
              TRUNC(cal.START_DATE) AND TRUNC(cal.END_DATE) AND
              info.ORG_ID  = l_org_id AND
              DECODE(l_calendar_type, 'P', info.PA_CALENDAR_ID,
              info.GL_CALENDAR_ID) = cal.CALENDAR_ID;
         EXCEPTION WHEN NO_DATA_FOUND THEN
          Pa_Debug.log_message('Project Id:' || p_project_id
                            || ' Org Id:' || l_org_id
                            || ' End Date:' || p_end_date);
                   print_time ('Project Id:' || p_project_id
                            || ' Org Id:' || l_org_id
                            || ' End Date:' || p_end_date);
      END;
      END IF;

      IF l_calendar_type  = 'A' THEN
         delete from pji_fm_aggr_fin8 fin where
         fin.PROJECT_ID           = p_project_id;
      ELSE
         delete from pji_fm_aggr_fin8 fin where
         fin.PROJECT_ID           = p_project_id
         AND  fin.RECVR_PERIOD_ID  <= l_end_period_id;
      END IF;
   END IF;

END;



PROCEDURE get_summarized_data (
    p_project_ids           IN   SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type(),
    p_resource_list_ids     IN   SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type(),
    p_struct_ver_ids        IN   SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type(),
    p_start_date            IN   DATE := NULL,
    p_end_date              IN   SYSTEM.pa_date_tbl_type := system.pa_date_tbl_type(),
    p_start_period_name     IN   VARCHAR2 := NULL,
    p_end_period_name       IN   VARCHAR2 := NULL,
    p_calendar_type         IN   SYSTEM.PA_VARCHAR2_1_TBL_TYPE := SYSTEM. PA_VARCHAR2_1_TBL_TYPE(),
    p_extraction_type       IN   VARCHAR2 := NULL,
    p_calling_context       IN   VARCHAR2 := NULL,
    p_record_type           IN   VARCHAR2,
    p_currency_type         IN   NUMBER,
    x_return_status         OUT NOCOPY  VARCHAR2,
    x_msg_code              OUT NOCOPY  VARCHAR2) IS

    /* Commented for workplan progress
    l_end_period_id        NUMBER;
    l_period_type_id       NUMBER;
    l_org_id               NUMBER;
     End of workplan progress */
    l_end_period_id        SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type(); /* Added for workplan progress */
    l_currency_mask        NUMBER;
    l_period_type_id       SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();/*Added for workplan progress */
    l_periodic_flag        VARCHAR2(1);
    l_planres_level_flag   VARCHAR2(1);
    l_task_level_flag      VARCHAR2(1);
    l_task_rollup_flag     VARCHAR2(1);
    l_proj_level_flag     VARCHAR2(1);
    l_summarized_flag      VARCHAR2(1);
    l_msg_count            NUMBER;
    l_calendar_type        SYSTEM.PA_VARCHAR2_1_TBL_TYPE := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
    l_org_id               SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();/*Added for workplan progress */
    l_map_resource_list    EXCEPTION;
    l_get_summarized_data varchar2(1) :='Y';
    l_summ_hasrun varchar2(1) :='N';


BEGIN

    PJI_PJP_FP_CURR_WRAP.INIT_ERR_STACK
    ( p_package_name   => g_package_name
    , x_return_status  => x_return_status );


    -- Cleanup tmp1 table for 3750147.
    DELETE FROM pji_fm_xbs_accum_tmp1;

    --DELETE FROM pa_res_list_map_tmp1;
    DELETE FROM pa_res_list_map_tmp2;  -- Bug#4726170


    /* Commented for workplan progress
    print_time ( ' get_summarized_data 0001 p_calendar_type ' || p_calendar_type ) ;

    --------------------------------------------------
    --Identifying the period type id and calendar type
    --------------------------------------------------
    --TODO: Need to add calendar type joins throughout
    IF (p_calendar_type = 'N') THEN                             print_time ( ' get_summarized_data 0001.1 ' ) ;
      l_calendar_type  := 'A';
      l_period_type_id := 2048;
    ELSIF (p_calendar_type = 'P') THEN                          print_time ( ' get_summarized_data 0001.2 ' ) ;
      l_calendar_type := 'P';
      l_period_type_id := 32;
    ELSE                                                        print_time ( ' get_summarized_data 0001.3 ' ) ;
      l_calendar_type := 'G';
      l_period_type_id := 32;
    END IF;                                                     print_time ( ' get_summarized_data 0002 ' ) ;

    End of workplan progress */

    ----------------------
    --Decoding record type
    ----------------------
    l_periodic_flag := SUBSTR( p_record_type, 1, 1);
    l_planres_level_flag  := SUBSTR( p_record_type, 2, 1);
    l_task_level_flag := SUBSTR( p_record_type, 3, 1);
    l_task_rollup_flag := NVL(SUBSTR( p_record_type, 4, 1), 'Y');

    -- If l_proj_level_flag is Y, then return task id as 0, else return project element id.
    IF (l_task_rollup_flag = 'N' AND l_task_level_flag = 'N') THEN -- BandF
      l_proj_level_flag := 'Y';
    ELSE  -- Used by progress: NY, YN. YY never used.
      l_proj_level_flag := 'N';
    END IF;

    /* Commented and moved down for workplan progress
     IF l_planres_level_flag = 'Y' THEN
      print_time ( ' get_summarized_data 0003 ' ) ; */

      /* Changed the logic. Existing loop is split into 2 for loops.
        Because to find the values of l_calendar_type, l_end_period_id, l_org_id
 which are used in the rollup */

      FOR i IN 1..p_project_ids.COUNT LOOP
          print_time ( ' get_summarized_data 0004 ' ) ;

/* Added here for workplan progress */

    l_calendar_type.extend;
    l_end_period_id.extend;
    l_period_type_id.extend;
    l_org_id.extend;

           print_time ( ' get_summarized_data 0001 p_calendar_type ' || p_calendar_type(i) ) ;
           IF (p_calendar_type(i) = 'N') THEN
      print_time ( ' get_summarized_data 0001.1 ' ) ;
             l_calendar_type(i) := 'A';
             l_period_type_id(i) := 2048;
           ELSIF (p_calendar_type(i) = 'P') THEN
      print_time ( ' get_summarized_data 0001.2 ' ) ;
             l_calendar_type(i) := 'P';
             l_period_type_id(i) := 32;
           ELSE
      print_time ( ' get_summarized_data 0001.3 ' ) ;
             l_calendar_type(i) := 'G';
             l_period_type_id(i) := 32;
           END IF;
    print_time ( ' get_summarized_data 0002 ' ) ;
 /* End for workplan progress */


          --Get org for the project
          SELECT ORG_ID
          INTO   l_org_id(i)
          FROM   pa_projects_all
          WHERE  project_id = p_project_ids(i);
          print_time ( ' get_summarized_data 0004.1 ' || l_org_id(i) || ' l_calendar_type ' || l_calendar_type(i) ) ;

          -------------------------------
          --Identifying the end period id
          -------------------------------
   /* Commented for workplan progress
          SELECT cal.CAL_PERIOD_ID
          INTO   l_end_period_id
          FROM   pji_time_cal_period_v cal,
  pji_org_extr_info    info
          WHERE  TRUNC(p_end_date) BETWEEN TRUNC(cal.START_DATE) AND TRUNC(cal.END_DATE) AND
                 info.ORG_ID                = l_org_id              AND
                  DECODE(l_calendar_type, 'P',
                    info.PA_CALENDAR_ID,
                    info.GL_CALENDAR_ID)      = cal.CALENDAR_ID;  */

          IF l_calendar_type(i) ='A' then
             l_end_period_id(i) :=-1;
   ELSE
                BEGIN
      SELECT cal.CAL_PERIOD_ID
                             INTO l_end_period_id(i)
                             FROM pji_time_cal_period_v cal,
                                  pji_org_extr_info    info
                             WHERE TRUNC(p_end_date(i)) BETWEEN
                                   TRUNC(cal.START_DATE) AND TRUNC(cal.END_DATE) AND
                                   info.ORG_ID  = l_org_id(i) AND
                                   DECODE(l_calendar_type(i), 'P', info.PA_CALENDAR_ID,
                                                                   info.GL_CALENDAR_ID) = cal.CALENDAR_ID;
         EXCEPTION
                    WHEN NO_DATA_FOUND THEN
  Pa_Debug.log_message('Project Id:' || p_project_ids(i)
               || ' Org Id:' || l_org_id(i)
 || ' End Date:' || p_end_date(i));
  print_time ('Project Id:' || p_project_ids(i)
               || ' Org Id:' || l_org_id(i)
 || ' End Date:' || p_end_date(i));
                END;
   END IF;

          print_time ( ' get_summarized_data 0004.2 ' ) ;

       END LOOP;

          ---------------------------------------------
          --ENTERED LEVEL DATA RETREIVAL
          --If planning resource level data is required
          --map to resource list and get data from
          --transaction accum
          ---------------------------------------------

    FOR i IN 1..p_project_ids.COUNT LOOP
        /*bug#4415960 added the summarization  check  in Publish mode */
    /*  commenting this as this is already handled,keeping the code for future requirement
        l_summ_hasrun:='N';
        l_get_summarized_data:='Y';
        IF  p_calling_context='P' THEN
	   begin
	      select 'Y'
              into   l_summ_hasrun
              from   dual
              where exists (select 1 from pji_fp_xbs_accum_f
                            where project_id=p_project_ids(i)
                            and plan_version_id=-1
                            and rownum=1);
           exception when no_data_found then
              l_summ_hasrun:='N';
           end;

           if l_summ_hasrun ='N' and p_calling_context='P' then
              l_get_summarized_data :='N';
           end if;
        END IF;
	*/
        IF l_planres_level_flag = 'Y'   THEN

             --DELETE FROM pa_res_list_map_tmp1;
             DELETE FROM pa_res_list_map_tmp2;  -- Bug#4726170

           print_time ( ' get_summarized_data 0004 ' ) ;

           INSERT INTO pa_res_list_map_tmp1 (
                    PERSON_ID,
                    JOB_ID,
                    ORGANIZATION_ID,
                    VENDOR_ID,
                    EXPENDITURE_TYPE,
                    EVENT_TYPE,
                    NON_LABOR_RESOURCE,
                    EXPENDITURE_CATEGORY,
                    REVENUE_CATEGORY,
                    EVENT_TYPE_CLASSIFICATION,
                    SYSTEM_LINKAGE_FUNCTION,
                    PROJECT_ROLE_ID,
                    RESOURCE_CLASS_ID,
                    RESOURCE_CLASS_CODE,
                    BOM_LABOR_RESOURCE_ID,
                    BOM_EQUIP_RESOURCE_ID,
                    INVENTORY_ITEM_ID,
                    ITEM_CATEGORY_ID,
                    PERSON_TYPE_CODE,
                    BOM_RESOURCE_ID,
                    NAMED_ROLE,
                    TXN_SOURCE_ID,
                    FC_RES_TYPE_CODE )  --bug#3804500
        SELECT      DISTINCT                    /* Added for bug 3729366*/
                    decode(head.PERSON_ID, -1, null, head.PERSON_ID),
                    decode(head.JOB_ID, -1, null, head.JOB_ID),
                    decode(head.EXPENDITURE_ORGANIZATION_ID, -1, null, head.EXPENDITURE_ORGANIZATION_ID),
                    decode(head.VENDOR_ID,-1, null, head.VENDOR_ID),
                    decode(head.EXPENDITURE_TYPE, 'PJI$NULL', null,head.EXPENDITURE_TYPE),
                    decode(head.EVENT_TYPE, 'PJI$NULL', null, head.EVENT_TYPE),
                    nlr.NON_LABOR_RESOURCE,
                    decode(head.EXPENDITURE_CATEGORY, 'PJI$NULL', null, head.EXPENDITURE_CATEGORY),
                    decode(head.REVENUE_CATEGORY,'PJI$NULL', null,head.REVENUE_CATEGORY),
                    decode(head.EVENT_TYPE_CLASSIFICATION,'PJI$NULL', null, head.EVENT_TYPE_CLASSIFICATION),
                    decode(head.SYSTEM_LINKAGE_FUNCTION,'PJI$NULL', null,head.SYSTEM_LINKAGE_FUNCTION),
                    decode(head.PROJECT_ROLE_ID,-1,null, head.PROJECT_ROLE_ID), /*For bug 4590810 */
                    head.RESOURCE_CLASS_ID,
                    cls.RESOURCE_CLASS_CODE,
                    decode(head.BOM_LABOR_RESOURCE_ID, -1, null, head.BOM_LABOR_RESOURCE_ID),
                    decode(head.BOM_EQUIPMENT_RESOURCE_ID, -1, null, head.BOM_EQUIPMENT_RESOURCE_ID),
                    decode(head.INVENTORY_ITEM_ID, -1, null, head.INVENTORY_ITEM_ID),
                    decode(head.ITEM_CATEGORY_ID, -1, null, head.ITEM_CATEGORY_ID),
                    decode(head.PERSON_TYPE,'PJI$NULL', null,head.PERSON_TYPE),
                    decode(head.BOM_LABOR_RESOURCE_ID, -1, decode(head.BOM_EQUIPMENT_RESOURCE_ID, -1, null, head.BOM_EQUIPMENT_RESOURCE_ID), head.BOM_LABOR_RESOURCE_ID),
                    decode(accum.NAMED_ROLE,'PJI$NULL',null,accum.NAMED_ROLE), /*For Bug 	5564306 and bug 4034467  */
                    head.TXN_ACCUM_HEADER_ID,
                    decode(head.EXPENDITURE_TYPE,'PJI$NULL',
                    decode(head.EVENT_TYPE,'PJI$NULL',
                    decode(head.EXPENDITURE_CATEGORY,'PJI$NULL',
                    decode(head.REVENUE_CATEGORY,'PJI$NULL',null,'REVENUE_CATEGORY'),'EXPENDITURE_CATEGORY'),'EVENT_TYPE'),'EXPENDITURE_TYPE')
        FROM
                   (
                   SELECT /*+ NO_MERGE */ DISTINCT txn_accum_header_id, project_id,named_role	-- Bug#5377911
                   FROM (
                      SELECT
                        txn_accum_header_id,
                        project_id,
			named_role		/*For bug 4590810 */
                      FROM
                        pji_fp_txn_accum
                      WHERE project_id = p_project_ids(i)
			AND recvr_period_type='GL'				--Bug#5356978
                      UNION ALL
                      SELECT
                        txn_accum_header_id,
                        project_id,
			named_role			/*For bug 4590810 */
                      FROM
                        pji_fm_aggr_fin7
                      WHERE project_id = p_project_ids(i)
			AND recvr_period_type='GL'				--Bug#5356978
                        )
                    ) accum,
                    pji_fp_txn_accum_header head,
                    pa_non_labor_resources nlr,
                    pa_resource_classes_b cls
                  WHERE
                    head.TXN_ACCUM_HEADER_ID  = accum.TXN_ACCUM_HEADER_ID      AND
                    accum.PROJECT_ID          = p_project_ids(i)               AND
                    nlr.NON_LABOR_RESOURCE_ID (+) = head.NON_LABOR_RESOURCE_ID AND
                    cls.RESOURCE_CLASS_ID     = head.RESOURCE_CLASS_ID     ;

                  print_time ( ' get_summarized_data 0004.3 ' ) ;



                /* Added for bug 3729366  - Start */

                INSERT INTO pa_res_list_map_tmp2
                        (TXN_SOURCE_ID,VENDOR_ID,PERSON_ID)
                SELECT  /* + index(hr, per_assignments_f_n12)     index(prd, pji_time_cal_period_u1) */
	        distinct T.TXN_SOURCE_ID,HR.VENDOR_ID,HR.PERSON_ID
                FROM    pa_res_list_map_tmp1 t,
	                        per_all_assignments_f hr,						--Bug#5356978
	                        pji_time_cal_period_v prd,
	        ( SELECT  txn_accum_header_id,max(recvr_period_id) recvr_period_id	-- Bug#5262851
			FROM
                           (
                                SELECT
                                txn_accum_header_id,recvr_period_id
                                FROM       pji_fp_txn_accum
                                WHERE      recvr_period_type = 'GL'
				and  project_id = p_project_ids(i)
                                UNION ALL
                                SELECT      /*+ index(pji_fm_aggr_fin7 pji_fm_aggr_fin7_n2) */
                                txn_accum_header_id,recvr_period_id
                                FROM       pji_fm_aggr_fin7
                                WHERE      recvr_period_type = 'GL'
				and  project_id = p_project_ids(i)
			  )
	         GROUP BY txn_accum_header_id										-- Bug#5262851
			  )
		        det
                WHERE
                        det.TXN_ACCUM_HEADER_ID          = t.TXN_SOURCE_ID AND
                        t.PERSON_TYPE_CODE               = 'CWK' AND
                        prd.CAL_PERIOD_ID                = det.RECVR_PERIOD_ID AND
                        (prd.START_DATE BETWEEN hr.EFFECTIVE_START_DATE AND hr.EFFECTIVE_END_DATE) AND
                        hr.PERSON_ID                     = t.PERSON_ID  AND
                        hr.PRIMARY_FLAG                  = 'Y'  AND
                        hr.ASSIGNMENT_TYPE               = 'C' AND
		        hr.VENDOR_ID is not null;



        print_time ( ' get_summarized_data 0004.4 ' ) ;

                UPDATE pa_res_list_map_tmp1 tmp
                SET VENDOR_ID =
                (
                SELECT t1.VENDOR_ID
                FROM    pa_res_list_map_tmp2 t1
                WHERE   t1.TXN_SOURCE_ID=tmp.TXN_SOURCE_ID
                        AND t1.PERSON_ID=tmp.PERSON_ID
                        AND tmp.PERSON_ID IS NOT NULL
                AND EXISTS
                        (
                        SELECT  NULL
                        FROM    pa_res_list_map_tmp2 t1
                        WHERE   t1.TXN_SOURCE_ID=tmp.TXN_SOURCE_ID
                                AND t1.PERSON_ID=tmp.PERSON_ID
                        )
                )
                WHERE VENDOR_ID IS NULL;

                /* Added for bug 3729366 -  End */
                  print_time ( ' get_summarized_data 0004.41 ' ) ;

pa_resource_mapping.g_called_process :='ACTUALS';

          pa_resource_mapping.map_resource_list (
              p_resource_list_id => p_resource_list_ids (i),
              p_project_id       =>  p_project_ids(i),
              x_return_status    => x_return_status,
              x_msg_count        => l_msg_count,
              x_msg_data         => x_msg_code );

         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN /* Bug No. 4461060 */
	      RAISE l_map_resource_list;
          END IF;


pa_resource_mapping.g_called_process :='PLAN';

          print_time ( ' get_summarized_data 0004.42 ' ) ;

 IF nvl(p_calling_context,'F')  in ('P','W')  THEN
       IF  p_extraction_type <>'INCREMENTAL' THEN

         INSERT INTO pji_fm_xbs_accum_tmp1
       (
        SOURCE_ID,              RES_LIST_MEMBER_ID,       PROJECT_ID,            STRUCT_VERSION_ID,
        PROJECT_ELEMENT_ID,     CALENDAR_TYPE,            PERIOD_NAME,           PLAN_VERSION_ID,
        TXN_CURRENCY_CODE,      TXN_RAW_COST,             TXN_BRDN_COST,         TXN_REVENUE,
        TXN_LABOR_RAW_COST,     TXN_LABOR_BRDN_COST,      TXN_EQUIP_RAW_COST,    TXN_EQUIP_BRDN_COST,
        QUANTITY,               PRJ_RAW_COST,             PRJ_BRDN_COST,         PRJ_REVENUE,
        PRJ_LABOR_RAW_COST,     PRJ_LABOR_BRDN_COST,      PRJ_EQUIP_RAW_COST,    PRJ_EQUIP_BRDN_COST,
        POU_RAW_COST,           POU_BRDN_COST,            POU_REVENUE,           POU_LABOR_RAW_COST,
        POU_LABOR_BRDN_COST,    POU_EQUIP_RAW_COST,       POU_EQUIP_BRDN_COST,   LABOR_HOURS,
        EQUIPMENT_HOURS,        PERIOD_FLAG,              BASE_LABOR_HOURS,      POU_LPB_RAW_COST,
        POU_LPB_BRDN_COST,      ACT_TXN_RAW_COST,         ACT_TXN_BRDN_COST,     ACT_TXN_LABOR_RAW_COST,
        ACT_TXN_LABOR_BRDN_COST,ACT_TXN_EQUIP_RAW_COST,   ACT_TXN_EQUIP_BRDN_COST,ACT_PRJ_RAW_COST,
        ACT_PRJ_BRDN_COST,      ACT_PRJ_LABOR_RAW_COST,   ACT_PRJ_LABOR_BRDN_COST,ACT_PRJ_EQUIP_RAW_COST,
        ACT_PRJ_EQUIP_BRDN_COST,ACT_POU_RAW_COST,         ACT_POU_BRDN_COST,      ACT_POU_LABOR_RAW_COST,
        ACT_POU_LABOR_BRDN_COST,ACT_POU_EQUIP_RAW_COST,   ACT_POU_EQUIP_BRDN_COST,ACT_LABOR_HRS,
        ACT_EQUIP_HRS,          MIN_START_DATE,           MAX_END_DATE
)
SELECT /*+ NO_MERGE */			--Bug#5356978
        SOURCE_ID,              RES_LIST_MEMBER_ID,     PROJECT_ID,             STRUCT_VERSION_ID,
        PROJECT_ELEMENT_ID,     CALENDAR_TYPE,          PERIOD_NAME,            PLAN_VERSION_ID,
        TXN_CURRENCY_CODE,      TXN_RAW_COST,           TXN_BRDN_COST,          TXN_REVENUE,
        TXN_LABOR_RAW_COST,     TXN_LABOR_BRDN_COST,    TXN_EQUIP_RAW_COST,     TXN_EQUIP_BRDN_COST,
        QUANTITY,               PRJ_RAW_COST,           PRJ_BRDN_COST,          PRJ_REVENUE,
        PRJ_LABOR_RAW_COST,     PRJ_LABOR_BRDN_COST,    PRJ_EQUIP_RAW_COST,     PRJ_EQUIP_BRDN_COST,
        POU_RAW_COST,           POU_BRDN_COST,          POU_REVENUE,            POU_LABOR_RAW_COST,
        POU_LABOR_BRDN_COST,    POU_EQUIP_RAW_COST,     POU_EQUIP_BRDN_COST,    LABOR_HOURS,
        EQUIPMENT_HOURS,        PERIOD_FLAG,            BASE_LABOR_HOURS,       POU_LPB_RAW_COST,
        POU_LPB_BRDN_COST,      TXN_RAW_COST,           TXN_BRDN_COST,          TXN_LABOR_RAW_COST,
        TXN_LABOR_BRDN_COST,    TXN_EQUIP_RAW_COST,     TXN_EQUIP_BRDN_COST,    PRJ_RAW_COST,
        PRJ_BRDN_COST,          PRJ_LABOR_RAW_COST,     PRJ_LABOR_BRDN_COST,    PRJ_EQUIP_RAW_COST,
        PRJ_EQUIP_BRDN_COST,    POU_RAW_COST,           POU_BRDN_COST,          POU_LABOR_RAW_COST,
        POU_LABOR_BRDN_COST,    POU_EQUIP_RAW_COST,     POU_EQUIP_BRDN_COST,    LABOR_HOURS,
        EQUIPMENT_HOURS,        MIN_START_DATE,         MAX_END_DATE
FROM
(

/* Below select statment is added for workplan progress (periodic data) from PJI_FP_TXN_ACCUM
To identify those records check for period_flag ='Y'. This is for FULL and PARTIAL
Retrieve Task / Project Level Data for PA/ GL Period
*/
SELECT
        /*tmp4.TXN_SOURCE_ID, Commented for workplan progress */
        min(null)                       SOURCE_ID,
        tmp4.RESOURCE_LIST_MEMBER_ID    RES_LIST_MEMBER_ID,
        accum.PROJECT_ID                PROJECT_ID,
        p_struct_ver_ids(i)             STRUCT_VERSION_ID,
        DECODE(l_proj_level_flag,'Y',0,accum.TASK_ID)    PROJECT_ELEMENT_ID,
        l_calendar_type(i)              CALENDAR_TYPE,
        time.NAME                       PERIOD_NAME,
        -1                              PLAN_VERSION_ID,
        accum.TXN_CURRENCY_CODE         TXN_CURRENCY_CODE,
        sum(accum.TXN_RAW_COST)         TXN_RAW_COST,
        sum(accum.TXN_BRDN_COST)        TXN_BRDN_COST,
        sum(accum.TXN_REVENUE)          TXN_REVENUE,
        sum(decode(tmp4.RESOURCE_CLASS_CODE,'PEOPLE',accum.TXN_RAW_COST,0))     TXN_LABOR_RAW_COST,
        sum(decode(tmp4.RESOURCE_CLASS_CODE,'PEOPLE',accum.TXN_BRDN_COST,0))    TXN_LABOR_BRDN_COST,
        sum(decode(tmp4.RESOURCE_CLASS_CODE,'EQUIPMENT',accum.TXN_RAW_COST,0))  TXN_EQUIP_RAW_COST,
        sum(decode(tmp4.RESOURCE_CLASS_CODE,'EQUIPMENT',accum.TXN_BRDN_COST,0)) TXN_EQUIP_BRDN_COST,
        sum(accum.QUANTITY)             QUANTITY,
        sum(accum.PRJ_RAW_COST)         PRJ_RAW_COST,
        sum(accum.PRJ_BRDN_COST)        PRJ_BRDN_COST,
        sum(accum.PRJ_REVENUE)          PRJ_REVENUE,
        sum(decode(tmp4.RESOURCE_CLASS_CODE,'PEOPLE',accum.PRJ_RAW_COST,0))     PRJ_LABOR_RAW_COST,
        sum(decode(tmp4.RESOURCE_CLASS_CODE,'PEOPLE',accum.PRJ_BRDN_COST,0))    PRJ_LABOR_BRDN_COST,
        sum(decode(tmp4.RESOURCE_CLASS_CODE,'EQUIPMENT',accum.PRJ_RAW_COST,0))  PRJ_EQUIP_RAW_COST,
        sum(decode(tmp4.RESOURCE_CLASS_CODE,'EQUIPMENT',accum.PRJ_BRDN_COST,0)) PRJ_EQUIP_BRDN_COST,
        sum(accum.POU_RAW_COST)         POU_RAW_COST,
        sum(accum.POU_BRDN_COST)        POU_BRDN_COST,
        sum(accum.POU_REVENUE)          POU_REVENUE,
        sum(decode(tmp4.RESOURCE_CLASS_CODE,'PEOPLE',accum.POU_RAW_COST,0))     POU_LABOR_RAW_COST,
        sum(decode(tmp4.RESOURCE_CLASS_CODE,'PEOPLE',accum.POU_BRDN_COST,0))    POU_LABOR_BRDN_COST,
        sum(decode(tmp4.RESOURCE_CLASS_CODE,'EQUIPMENT',accum.POU_RAW_COST,0))  POU_EQUIP_RAW_COST,
        sum(decode(tmp4.RESOURCE_CLASS_CODE,'EQUIPMENT',accum.POU_BRDN_COST,0)) POU_EQUIP_BRDN_COST,
        sum(decode(tmp4.RESOURCE_CLASS_CODE,'PEOPLE',accum.QUANTITY,0))         LABOR_HOURS,
        sum(decode(tmp4.RESOURCE_CLASS_CODE,'EQUIPMENT',accum.QUANTITY,0))      EQUIPMENT_HOURS,
        MIN('Y')                        PERIOD_FLAG,
        null                            BASE_LABOR_HOURS,
        null                            POU_LPB_RAW_COST,
        null                            POU_LPB_BRDN_COST,
        MIN(time.START_DATE)            MIN_START_DATE,
        MAX(time.END_DATE)              MAX_END_DATE
FROM
        pa_res_list_map_tmp4 tmp4,
        pji_fm_aggr_fin8 accum,
        pji_time_cal_period_v time,
        pji_org_extr_info info
WHERE
        tmp4.TXN_SOURCE_ID      = accum.TXN_ACCUM_HEADER_ID                     AND
        accum.PROJECT_ID        = p_project_ids(i)                              AND
        accum.NAMED_ROLE        = NVL(tmp4.NAMED_ROLE, 'PJI$NULL')              AND -- Bug 8294762
        accum.RECVR_PERIOD_ID   = time.CAL_PERIOD_ID                            AND
        /*Added 'G' in below decode for workplan progress */
        accum.RECVR_PERIOD_TYPE = decode(l_calendar_type(i) , 'P', 'PA', 'G','GL') AND
        time.CALENDAR_ID        = decode(l_calendar_type(i) , 'P', info.PA_CALENDAR_ID,
        'G',info.GL_CALENDAR_ID) AND
        info.ORG_ID             = l_org_id(i)                                   AND
        time.CAL_PERIOD_ID     <= l_end_period_id(i)                            AND
        p_calling_context       in ('P', 'W') /* added for workplan progress*/  AND
        p_extraction_type in ('FULL','PARTIAL')
GROUP BY
        /*tmp4.TXN_SOURCE_ID, Commented for workplan progress */
        tmp4.RESOURCE_LIST_MEMBER_ID,
        accum.PROJECT_ID,
        p_struct_ver_ids(i),
        DECODE(l_proj_level_flag, 'Y', 0, accum.TASK_ID) ,
        l_calendar_type(i),
        time.NAME,
        -1,
        accum.TXN_CURRENCY_CODE

-- Added the following Two union all caluses to populate
-- data for nontime phase: Bug : 4224314
UNION ALL
/* Below select statment is added for workplan progress (periodic data) from PJI_FP_TXN_ACCUM
To identify those records check for period_flag ='Y'. This is for FULL and PARTIAL
Retrieve Task / Project Level Data for Non Time Phased Period
*/
SELECT
        min(null)                       SOURCE_ID,
        tmp4.RESOURCE_LIST_MEMBER_ID    RES_LIST_MEMBER_ID,
        accum.PROJECT_ID                PROJECT_ID,
        p_struct_ver_ids(i)             STRUCT_VERSION_ID,
        DECODE(l_proj_level_flag,'Y',0,accum.TASK_ID)       PROJECT_ELEMENT_ID,
        l_calendar_type(i)              CALENDAR_TYPE,
        NULL                            PERIOD_NAME,
        -1                              PLAN_VERSION_ID,
        accum.TXN_CURRENCY_CODE         TXN_CURRENCY_CODE,
        sum(accum.TXN_RAW_COST)         TXN_RAW_COST,
        sum(accum.TXN_BRDN_COST)        TXN_BRDN_COST,
        sum(accum.TXN_REVENUE)          TXN_REVENUE,
        sum(decode(tmp4.RESOURCE_CLASS_CODE,'PEOPLE',accum.TXN_RAW_COST,0))             TXN_LABOR_RAW_COST,
        sum(decode(tmp4.RESOURCE_CLASS_CODE,'PEOPLE',accum.TXN_BRDN_COST,0))            TXN_LABOR_BRDN_COST,
        sum(decode(tmp4.RESOURCE_CLASS_CODE,'EQUIPMENT',accum.TXN_RAW_COST,0))          TXN_EQUIP_RAW_COST,
        sum(decode(tmp4.RESOURCE_CLASS_CODE,'EQUIPMENT',accum.TXN_BRDN_COST,0))         TXN_EQUIP_BRDN_COST,
        sum(accum.QUANTITY)             QUANTITY,
        sum(accum.PRJ_RAW_COST)         PRJ_RAW_COST,
        sum(accum.PRJ_BRDN_COST)        PRJ_BRDN_COST,
        sum(accum.PRJ_REVENUE)          PRJ_REVENUE,
        sum(decode(tmp4.RESOURCE_CLASS_CODE,'PEOPLE',accum.PRJ_RAW_COST,0))             PRJ_LABOR_RAW_COST,
        sum(decode(tmp4.RESOURCE_CLASS_CODE,'PEOPLE',accum.PRJ_BRDN_COST,0))            PRJ_LABOR_BRDN_COST,
        sum(decode(tmp4.RESOURCE_CLASS_CODE,'EQUIPMENT',accum.PRJ_RAW_COST,0))          PRJ_EQUIP_RAW_COST,
        sum(decode(tmp4.RESOURCE_CLASS_CODE,'EQUIPMENT',accum.PRJ_BRDN_COST,0))       PRJ_EQUIP_BRDN_COST,
        sum(accum.POU_RAW_COST)         POU_RAW_COST,
        sum(accum.POU_BRDN_COST)        POU_BRDN_COST,
        sum(accum.POU_REVENUE)          POU_REVENUE,
        sum(decode(tmp4.RESOURCE_CLASS_CODE,'PEOPLE',accum.POU_RAW_COST,0))             POU_LABOR_RAW_COST,
        sum(decode(tmp4.RESOURCE_CLASS_CODE,'PEOPLE',accum.POU_BRDN_COST,0))            POU_LABOR_BRDN_COST,
        sum(decode(tmp4.RESOURCE_CLASS_CODE,'EQUIPMENT',accum.POU_RAW_COST,0))          POU_EQUIP_RAW_COST,
        sum(decode(tmp4.RESOURCE_CLASS_CODE,'EQUIPMENT',accum.POU_BRDN_COST,0))         POU_EQUIP_BRDN_COST,
        sum(decode(tmp4.RESOURCE_CLASS_CODE,'PEOPLE',accum.QUANTITY,0))                 LABOR_HOURS,
        sum(decode(tmp4.RESOURCE_CLASS_CODE,'EQUIPMENT',accum.QUANTITY,0))              EQUIPMENT_HOURS,
        MIN('Y')        PERIOD_FLAG,
        null            BASE_LABOR_HOURS,
        null            POU_LPB_RAW_COST,
        null            POU_LPB_BRDN_COST,
        MIN(time.START_DATE)            MIN_START_DATE,
        MAX(time.END_DATE)              MAX_END_DATE
FROM
        pa_res_list_map_tmp4 tmp4,
        pji_fm_aggr_fin8 accum  ,
        pji_time_cal_period_v time --, pji_org_extr_info info
WHERE
        tmp4.TXN_SOURCE_ID      = accum.TXN_ACCUM_HEADER_ID                     AND
        accum.PROJECT_ID        = p_project_ids(i)                              AND
        accum.NAMED_ROLE        = NVL(tmp4.NAMED_ROLE, 'PJI$NULL')              AND -- Bug 8294762
        accum.RECVR_PERIOD_ID   = time.CAL_PERIOD_ID                            AND
        accum.RECVR_PERIOD_TYPE = 'GL'                                          AND
        l_calendar_type(i)      = 'A'                                           AND
        p_calling_context    in ('P', 'W')                                      AND
        p_extraction_type    in ('FULL','PARTIAL')
GROUP BY
        tmp4.RESOURCE_LIST_MEMBER_ID,
        accum.PROJECT_ID,
        p_struct_ver_ids(i),
        DECODE(l_proj_level_flag, 'Y', 0, accum.TASK_ID) ,
        l_calendar_type(i),
        -1 ,
        accum.TXN_CURRENCY_CODE
);

else  /* p_extraction_type ='INCREMENTAL*/

    INSERT INTO pji_fm_xbs_accum_tmp1
    (
        SOURCE_ID,              RES_LIST_MEMBER_ID,       PROJECT_ID,            STRUCT_VERSION_ID,
        PROJECT_ELEMENT_ID,     CALENDAR_TYPE,            PERIOD_NAME,           PLAN_VERSION_ID,
        TXN_CURRENCY_CODE,      TXN_RAW_COST,             TXN_BRDN_COST,         TXN_REVENUE,
        TXN_LABOR_RAW_COST,     TXN_LABOR_BRDN_COST,      TXN_EQUIP_RAW_COST,    TXN_EQUIP_BRDN_COST,
        QUANTITY,               PRJ_RAW_COST,             PRJ_BRDN_COST,         PRJ_REVENUE,
        PRJ_LABOR_RAW_COST,     PRJ_LABOR_BRDN_COST,      PRJ_EQUIP_RAW_COST,    PRJ_EQUIP_BRDN_COST,
        POU_RAW_COST,           POU_BRDN_COST,            POU_REVENUE,           POU_LABOR_RAW_COST,
        POU_LABOR_BRDN_COST,    POU_EQUIP_RAW_COST,       POU_EQUIP_BRDN_COST,   LABOR_HOURS,
        EQUIPMENT_HOURS,        PERIOD_FLAG,              BASE_LABOR_HOURS,      POU_LPB_RAW_COST,
        POU_LPB_BRDN_COST,      ACT_TXN_RAW_COST,         ACT_TXN_BRDN_COST,     ACT_TXN_LABOR_RAW_COST,
        ACT_TXN_LABOR_BRDN_COST,ACT_TXN_EQUIP_RAW_COST,   ACT_TXN_EQUIP_BRDN_COST,ACT_PRJ_RAW_COST,
        ACT_PRJ_BRDN_COST,      ACT_PRJ_LABOR_RAW_COST,   ACT_PRJ_LABOR_BRDN_COST,ACT_PRJ_EQUIP_RAW_COST,
        ACT_PRJ_EQUIP_BRDN_COST,ACT_POU_RAW_COST,         ACT_POU_BRDN_COST,      ACT_POU_LABOR_RAW_COST,
        ACT_POU_LABOR_BRDN_COST,ACT_POU_EQUIP_RAW_COST,   ACT_POU_EQUIP_BRDN_COST,ACT_LABOR_HRS,
        ACT_EQUIP_HRS,          MIN_START_DATE,           MAX_END_DATE
)
SELECT  /*+ NO_MERGE */			--Bug#5356978
        SOURCE_ID,              RES_LIST_MEMBER_ID,     PROJECT_ID,             STRUCT_VERSION_ID,
        PROJECT_ELEMENT_ID,     CALENDAR_TYPE,          PERIOD_NAME,            PLAN_VERSION_ID,
        TXN_CURRENCY_CODE,      TXN_RAW_COST,           TXN_BRDN_COST,          TXN_REVENUE,
        TXN_LABOR_RAW_COST,     TXN_LABOR_BRDN_COST,    TXN_EQUIP_RAW_COST,     TXN_EQUIP_BRDN_COST,
        QUANTITY,               PRJ_RAW_COST,           PRJ_BRDN_COST,          PRJ_REVENUE,
        PRJ_LABOR_RAW_COST,     PRJ_LABOR_BRDN_COST,    PRJ_EQUIP_RAW_COST,     PRJ_EQUIP_BRDN_COST,
        POU_RAW_COST,           POU_BRDN_COST,          POU_REVENUE,            POU_LABOR_RAW_COST,
        POU_LABOR_BRDN_COST,    POU_EQUIP_RAW_COST,     POU_EQUIP_BRDN_COST,    LABOR_HOURS,
        EQUIPMENT_HOURS,        PERIOD_FLAG,            BASE_LABOR_HOURS,       POU_LPB_RAW_COST,
        POU_LPB_BRDN_COST,      TXN_RAW_COST,           TXN_BRDN_COST,          TXN_LABOR_RAW_COST,
        TXN_LABOR_BRDN_COST,    TXN_EQUIP_RAW_COST,     TXN_EQUIP_BRDN_COST,    PRJ_RAW_COST,
        PRJ_BRDN_COST,          PRJ_LABOR_RAW_COST,     PRJ_LABOR_BRDN_COST,    PRJ_EQUIP_RAW_COST,
        PRJ_EQUIP_BRDN_COST,    POU_RAW_COST,           POU_BRDN_COST,          POU_LABOR_RAW_COST,
        POU_LABOR_BRDN_COST,    POU_EQUIP_RAW_COST,     POU_EQUIP_BRDN_COST,    LABOR_HOURS,
        EQUIPMENT_HOURS,        MIN_START_DATE,         MAX_END_DATE
FROM
(
/* Below select statment is added for workplan progress (periodic data) from PJI_FM_AGGR_FIN7
To identify those records check for period_flag ='Y'. This is for INCREMENTAL
Retrieve Task / Project Level Data for PA/ GL Period
*/
SELECT
        /* tmp4.TXN_SOURCE_ID, Commented for workplan progress */
        min(null)                       SOURCE_ID,
        tmp4.RESOURCE_LIST_MEMBER_ID    RES_LIST_MEMBER_ID,
        fin.PROJECT_ID                  PROJECT_ID,
        p_struct_ver_ids(i)             STRUCT_VERSION_ID,
        DECODE(l_proj_level_flag,'Y',0,fin.TASK_ID)      PROJECT_ELEMENT_ID,
        l_calendar_type(i)              CALENDAR_TYPE,
        time.NAME                       PERIOD_NAME,
        -1                              PLAN_VERSION_ID,
        fin.TXN_CURRENCY_CODE           TXN_CURRENCY_CODE,
        sum(fin.TXN_RAW_COST)           TXN_RAW_COST,
        sum(fin.TXN_BRDN_COST)          TXN_BRDN_COST,
        sum(fin.TXN_REVENUE)            TXN_REVENUE,
        sum(decode(tmp4.RESOURCE_CLASS_CODE,'PEOPLE',fin.TXN_RAW_COST,0))       TXN_LABOR_RAW_COST,
        sum(decode(tmp4.RESOURCE_CLASS_CODE,'PEOPLE',fin.TXN_BRDN_COST,0))      TXN_LABOR_BRDN_COST,
        sum(decode(tmp4.RESOURCE_CLASS_CODE,'EQUIPMENT',fin.TXN_RAW_COST,0))    TXN_EQUIP_RAW_COST,
        sum(decode(tmp4.RESOURCE_CLASS_CODE,'EQUIPMENT',fin.TXN_BRDN_COST,0))   TXN_EQUIP_BRDN_COST,
        sum(fin.QUANTITY)               QUANTITY,
        sum(fin.PRJ_RAW_COST)           PRJ_RAW_COST,
        sum(fin.PRJ_BRDN_COST)          PRJ_BRDN_COST,
        sum(fin.PRJ_REVENUE)            PRJ_REVENUE,
        sum(decode(tmp4.RESOURCE_CLASS_CODE,'PEOPLE',fin.PRJ_RAW_COST,0))      PRJ_LABOR_RAW_COST,
        sum(decode(tmp4.RESOURCE_CLASS_CODE,'PEOPLE',fin.PRJ_BRDN_COST,0))     PRJ_LABOR_BRDN_COST,
        sum(decode(tmp4.RESOURCE_CLASS_CODE,'EQUIPMENT',fin.PRJ_RAW_COST,0))   PRJ_EQUIP_RAW_COST,
        sum(decode(tmp4.RESOURCE_CLASS_CODE,'EQUIPMENT',fin.PRJ_BRDN_COST,0))  PRJ_EQUIP_BRDN_COST,
        sum(fin.POU_RAW_COST)           POU_RAW_COST,
        sum(fin.POU_BRDN_COST)          POU_BRDN_COST,
        sum(fin.POU_REVENUE)            POU_REVENUE,
        sum(decode(tmp4.RESOURCE_CLASS_CODE,'PEOPLE',fin.POU_RAW_COST,0))      POU_LABOR_RAW_COST,
        sum(decode(tmp4.RESOURCE_CLASS_CODE,'PEOPLE',fin.POU_BRDN_COST,0))     POU_LABOR_BRDN_COST,
        sum(decode(tmp4.RESOURCE_CLASS_CODE,'EQUIPMENT',fin.POU_RAW_COST,0))   POU_EQUIP_RAW_COST,
        sum(decode(tmp4.RESOURCE_CLASS_CODE,'EQUIPMENT',fin.POU_BRDN_COST,0))  POU_EQUIP_BRDN_COST,
        sum(decode(tmp4.RESOURCE_CLASS_CODE,'PEOPLE',fin.QUANTITY,0))           LABOR_HOURS,
        sum(decode(tmp4.RESOURCE_CLASS_CODE,'EQUIPMENT',fin.QUANTITY,0))        EQUIPMENT_HOURS,
        MIN('Y')                PERIOD_FLAG,
        null                    BASE_LABOR_HOURS,
        null                    POU_LPB_RAW_COST,
        null                    POU_LPB_BRDN_COST,
        MIN(time.START_DATE)    MIN_START_DATE,
        MAX(time.END_DATE)      MAX_END_DATE
FROM
        pa_res_list_map_tmp4 tmp4,
        pji_fm_aggr_fin8 fin,
        pji_time_cal_period_v time,
        pji_org_extr_info info
WHERE
        tmp4.TXN_SOURCE_ID      = fin.TXN_ACCUM_HEADER_ID                       AND
        fin.PROJECT_ID        = p_project_ids(i)                                AND
        fin.NAMED_ROLE        = NVL(tmp4.NAMED_ROLE, 'PJI$NULL')                AND -- Bug 8294762
        fin.RECVR_PERIOD_ID   = time.CAL_PERIOD_ID                              AND
        /*Added 'G' in below decode for workplan progress */
        fin.RECVR_PERIOD_TYPE = decode(l_calendar_type(i) , 'P', 'PA', 'G','GL') AND
        time.CALENDAR_ID        = decode(l_calendar_type(i) , 'P', info.PA_CALENDAR_ID,
        'G',info.GL_CALENDAR_ID) AND
        info.ORG_ID             = l_org_id(i)                                   AND
        time.CAL_PERIOD_ID     <= l_end_period_id(i)                            AND
        p_calling_context     in ('P', 'W') /* added for workplan progress*/    AND
        p_extraction_type       = 'INCREMENTAL'
GROUP BY
        /*tmp4.TXN_SOURCE_ID, Commented for workplan progress */
        tmp4.RESOURCE_LIST_MEMBER_ID,
        fin.PROJECT_ID,
        p_struct_ver_ids(i),
        DECODE(l_proj_level_flag, 'Y', 0, fin.TASK_ID),
        l_calendar_type(i),
        time.NAME,
        -1,
        fin.TXN_CURRENCY_CODE

-- Added the following Two union all caluses to populate
-- data for nontime phase: Bug : 4224314
UNION ALL
/* Below select statment is added for workplan progress (periodic data) from PJI_FP_TXN_ACCUM
To identify those records check for period_flag ='Y'. This is for FULL and PARTIAL
Retrieve Task / Project Level Data for Non Time Phased Period
*/
SELECT
        min(null)                       SOURCE_ID,
        tmp4.RESOURCE_LIST_MEMBER_ID    RES_LIST_MEMBER_ID,
        fin.PROJECT_ID                  PROJECT_ID,
        p_struct_ver_ids(i)             STRUCT_VERSION_ID,
        DECODE(l_proj_level_flag,'Y',0,fin.TASK_ID)       PROJECT_ELEMENT_ID,
        l_calendar_type(i)              CALENDAR_TYPE,
        NULL                            PERIOD_NAME,
        -1                              PLAN_VERSION_ID,
        fin.TXN_CURRENCY_CODE           TXN_CURRENCY_CODE,
        sum(fin.TXN_RAW_COST)           TXN_RAW_COST,
        sum(fin.TXN_BRDN_COST)          TXN_BRDN_COST,
        sum(fin.TXN_REVENUE)            TXN_REVENUE,
        sum(decode(tmp4.RESOURCE_CLASS_CODE,'PEOPLE',fin.TXN_RAW_COST,0))               TXN_LABOR_RAW_COST,
        sum(decode(tmp4.RESOURCE_CLASS_CODE,'PEOPLE',fin.TXN_BRDN_COST,0))              TXN_LABOR_BRDN_COST,
        sum(decode(tmp4.RESOURCE_CLASS_CODE,'EQUIPMENT',fin.TXN_RAW_COST,0))            TXN_EQUIP_RAW_COST,
        sum(decode(tmp4.RESOURCE_CLASS_CODE,'EQUIPMENT',fin.TXN_BRDN_COST,0))           TXN_EQUIP_BRDN_COST,
        sum(fin.QUANTITY)               QUANTITY,
        sum(fin.PRJ_RAW_COST)           PRJ_RAW_COST,
        sum(fin.PRJ_BRDN_COST)          PRJ_BRDN_COST,
        sum(fin.PRJ_REVENUE)            PRJ_REVENUE,
        sum(decode(tmp4.RESOURCE_CLASS_CODE,'PEOPLE',fin.PRJ_RAW_COST,0))               PRJ_LABOR_RAW_COST,
        sum(decode(tmp4.RESOURCE_CLASS_CODE,'PEOPLE',fin.PRJ_BRDN_COST,0))              PRJ_LABOR_BRDN_COST,
        sum(decode(tmp4.RESOURCE_CLASS_CODE,'EQUIPMENT',fin.PRJ_RAW_COST,0))            PRJ_EQUIP_RAW_COST,
        sum(decode(tmp4.RESOURCE_CLASS_CODE,'EQUIPMENT',fin.PRJ_BRDN_COST,0))           PRJ_EQUIP_BRDN_COST,
        sum(fin.POU_RAW_COST)           POU_RAW_COST,
        sum(fin.POU_BRDN_COST)          POU_BRDN_COST,
        sum(fin.POU_REVENUE)            POU_REVENUE,
        sum(decode(tmp4.RESOURCE_CLASS_CODE,'PEOPLE',fin.POU_RAW_COST,0))               POU_LABOR_RAW_COST,
        sum(decode(tmp4.RESOURCE_CLASS_CODE,'PEOPLE',fin.POU_BRDN_COST,0))              POU_LABOR_BRDN_COST,
        sum(decode(tmp4.RESOURCE_CLASS_CODE,'EQUIPMENT',fin.POU_RAW_COST,0))            POU_EQUIP_RAW_COST,
        sum(decode(tmp4.RESOURCE_CLASS_CODE,'EQUIPMENT',fin.POU_BRDN_COST,0))           POU_EQUIP_BRDN_COST,
        sum(decode(tmp4.RESOURCE_CLASS_CODE,'PEOPLE',fin.QUANTITY,0))                   LABOR_HOURS,
        sum(decode(tmp4.RESOURCE_CLASS_CODE,'EQUIPMENT',fin.QUANTITY,0))                EQUIPMENT_HOURS,
        MIN('Y')        PERIOD_FLAG,
        null            BASE_LABOR_HOURS,
        null            POU_LPB_RAW_COST,
        null            POU_LPB_BRDN_COST,
        MIN(time.START_DATE)            MIN_START_DATE,
        MAX(time.END_DATE)              MAX_END_DATE
FROM
        pa_res_list_map_tmp4 tmp4,
        pji_fm_aggr_fin8 fin  ,
        pji_time_cal_period_v time  --, pji_org_extr_info info
WHERE
        tmp4.TXN_SOURCE_ID      = fin.TXN_ACCUM_HEADER_ID                 AND
        fin.PROJECT_ID        = p_project_ids(i)                          AND
        fin.NAMED_ROLE        = NVL(tmp4.NAMED_ROLE, 'PJI$NULL')          AND -- Bug 8294762
        fin.RECVR_PERIOD_ID   = time.CAL_PERIOD_ID                        AND
        fin.RECVR_PERIOD_TYPE = 'GL' and
        l_calendar_type(i)    = 'A'   AND
        p_calling_context      in ('P', 'W')    AND
        p_extraction_type in ('INCREMENTAL')
GROUP BY
        tmp4.RESOURCE_LIST_MEMBER_ID,
        fin.PROJECT_ID,
        p_struct_ver_ids(i),
        DECODE(l_proj_level_flag, 'Y', 0, fin.TASK_ID),
        l_calendar_type(i),
        -1 ,
        fin.TXN_CURRENCY_CODE
       );
     END IF;/* IF  p_extraction_type <>'INCREMENTAL' THEN*/
ELSE  /* nvl(p_calling_context,'F') NOT IN ('P','W') */

    INSERT INTO pji_fm_xbs_accum_tmp1
    (
        SOURCE_ID,              RES_LIST_MEMBER_ID,       PROJECT_ID,            STRUCT_VERSION_ID,
        PROJECT_ELEMENT_ID,     CALENDAR_TYPE,            PERIOD_NAME,           PLAN_VERSION_ID,
        TXN_CURRENCY_CODE,      TXN_RAW_COST,             TXN_BRDN_COST,         TXN_REVENUE,
        TXN_LABOR_RAW_COST,     TXN_LABOR_BRDN_COST,      TXN_EQUIP_RAW_COST,    TXN_EQUIP_BRDN_COST,
        QUANTITY,               PRJ_RAW_COST,             PRJ_BRDN_COST,         PRJ_REVENUE,
        PRJ_LABOR_RAW_COST,     PRJ_LABOR_BRDN_COST,      PRJ_EQUIP_RAW_COST,    PRJ_EQUIP_BRDN_COST,
        POU_RAW_COST,           POU_BRDN_COST,            POU_REVENUE,           POU_LABOR_RAW_COST,
        POU_LABOR_BRDN_COST,    POU_EQUIP_RAW_COST,       POU_EQUIP_BRDN_COST,   LABOR_HOURS,
        EQUIPMENT_HOURS,        PERIOD_FLAG,              BASE_LABOR_HOURS,      POU_LPB_RAW_COST,
        POU_LPB_BRDN_COST,      ACT_TXN_RAW_COST,         ACT_TXN_BRDN_COST,     ACT_TXN_LABOR_RAW_COST,
        ACT_TXN_LABOR_BRDN_COST,ACT_TXN_EQUIP_RAW_COST,   ACT_TXN_EQUIP_BRDN_COST,ACT_PRJ_RAW_COST,
        ACT_PRJ_BRDN_COST,      ACT_PRJ_LABOR_RAW_COST,   ACT_PRJ_LABOR_BRDN_COST,ACT_PRJ_EQUIP_RAW_COST,
        ACT_PRJ_EQUIP_BRDN_COST,ACT_POU_RAW_COST,         ACT_POU_BRDN_COST,      ACT_POU_LABOR_RAW_COST,
        ACT_POU_LABOR_BRDN_COST,ACT_POU_EQUIP_RAW_COST,   ACT_POU_EQUIP_BRDN_COST,ACT_LABOR_HRS,
        ACT_EQUIP_HRS,          MIN_START_DATE,           MAX_END_DATE
    )
    SELECT
        SOURCE_ID,              RES_LIST_MEMBER_ID,     PROJECT_ID,             STRUCT_VERSION_ID,
        PROJECT_ELEMENT_ID,     CALENDAR_TYPE,          PERIOD_NAME,            PLAN_VERSION_ID,
        TXN_CURRENCY_CODE,      TXN_RAW_COST,           TXN_BRDN_COST,          TXN_REVENUE,
        TXN_LABOR_RAW_COST,     TXN_LABOR_BRDN_COST,    TXN_EQUIP_RAW_COST,     TXN_EQUIP_BRDN_COST,
        QUANTITY,               PRJ_RAW_COST,           PRJ_BRDN_COST,          PRJ_REVENUE,
        PRJ_LABOR_RAW_COST,     PRJ_LABOR_BRDN_COST,    PRJ_EQUIP_RAW_COST,     PRJ_EQUIP_BRDN_COST,
        POU_RAW_COST,           POU_BRDN_COST,          POU_REVENUE,            POU_LABOR_RAW_COST,
        POU_LABOR_BRDN_COST,    POU_EQUIP_RAW_COST,     POU_EQUIP_BRDN_COST,    LABOR_HOURS,
        EQUIPMENT_HOURS,        PERIOD_FLAG,            BASE_LABOR_HOURS,       POU_LPB_RAW_COST,
        POU_LPB_BRDN_COST,      TXN_RAW_COST,           TXN_BRDN_COST,          TXN_LABOR_RAW_COST,
        TXN_LABOR_BRDN_COST,    TXN_EQUIP_RAW_COST,     TXN_EQUIP_BRDN_COST,    PRJ_RAW_COST,
        PRJ_BRDN_COST,          PRJ_LABOR_RAW_COST,     PRJ_LABOR_BRDN_COST,    PRJ_EQUIP_RAW_COST,
        PRJ_EQUIP_BRDN_COST,    POU_RAW_COST,           POU_BRDN_COST,          POU_LABOR_RAW_COST,
        POU_LABOR_BRDN_COST,    POU_EQUIP_RAW_COST,     POU_EQUIP_BRDN_COST,    LABOR_HOURS,
        EQUIPMENT_HOURS,        MIN_START_DATE,         MAX_END_DATE
    FROM
    (
    SELECT
        MIN(SOURCE_ID)                  SOURCE_ID,
        RES_LIST_MEMBER_ID              RES_LIST_MEMBER_ID,
        PROJECT_ID                      PROJECT_ID,
        STRUCT_VERSION_ID               STRUCT_VERSION_ID,
        DECODE(l_proj_level_flag,'Y',0,PROJECT_ELEMENT_ID) PROJECT_ELEMENT_ID ,
        CALENDAR_TYPE                   CALENDAR_TYPE,
        PERIOD_NAME                     PERIOD_NAME,
        PLAN_VERSION_ID                 PLAN_VERSION_ID,
        TXN_CURRENCY_CODE               TXN_CURRENCY_CODE,
        SUM(TXN_RAW_COST)               TXN_RAW_COST,
        SUM(TXN_BRDN_COST)              TXN_BRDN_COST,
        SUM(TXN_REVENUE)                TXN_REVENUE,
        SUM(TXN_LABOR_RAW_COST)         TXN_LABOR_RAW_COST,
        SUM(TXN_LABOR_BRDN_COST)        TXN_LABOR_BRDN_COST,
        SUM(TXN_EQUIP_RAW_COST)         TXN_EQUIP_RAW_COST,
        SUM(TXN_EQUIP_BRDN_COST)        TXN_EQUIP_BRDN_COST,
        SUM(QUANTITY)                   QUANTITY,
        SUM(PRJ_RAW_COST)               PRJ_RAW_COST,
        SUM(PRJ_BRDN_COST)              PRJ_BRDN_COST,
        SUM(PRJ_REVENUE)                PRJ_REVENUE,
        SUM(PRJ_LABOR_RAW_COST)         PRJ_LABOR_RAW_COST,
        SUM(PRJ_LABOR_BRDN_COST)        PRJ_LABOR_BRDN_COST,
        SUM(PRJ_EQUIP_RAW_COST)         PRJ_EQUIP_RAW_COST,
        SUM(PRJ_EQUIP_BRDN_COST)        PRJ_EQUIP_BRDN_COST,
        SUM(POU_RAW_COST)               POU_RAW_COST,
        SUM(POU_BRDN_COST)              POU_BRDN_COST,
        SUM(POU_REVENUE)                POU_REVENUE,
        SUM(POU_LABOR_RAW_COST)         POU_LABOR_RAW_COST,
        SUM(POU_LABOR_BRDN_COST)        POU_LABOR_BRDN_COST,
        SUM(POU_EQUIP_RAW_COST)         POU_EQUIP_RAW_COST,
        SUM(POU_EQUIP_BRDN_COST)        POU_EQUIP_BRDN_COST,
        SUM(LABOR_HOURS)                LABOR_HOURS,
        SUM(EQUIP_HOURS)                EQUIPMENT_HOURS,
        MIN(PERIOD_FLAG)                PERIOD_FLAG,
        SUM(INCR_QUANTITY)              BASE_LABOR_HOURS,
        SUM(INCR_POU_RAW_COST)          POU_LPB_RAW_COST,
        SUM(INCR_POU_BRDN_COST)         POU_LPB_BRDN_COST,
        MIN(START_DATE)                 MIN_START_DATE,
        MAX(END_DATE)                   MAX_END_DATE
FROM
        (
        SELECT --Retreives actuals data by resource list as ITD amounts for TIME PHASED Calendar
                --from pji_fp_txn_Accum
                /*tmp4.TXN_SOURCE_ID, Commented for workplan progress */
                (null) SOURCE_ID,
                tmp4.RESOURCE_LIST_MEMBER_ID    RES_LIST_MEMBER_ID,
                accum.PROJECT_ID                PROJECT_ID,
                p_struct_ver_ids(i)             STRUCT_VERSION_ID,
                accum.TASK_ID                   PROJECT_ELEMENT_ID,
                l_calendar_type(i)              CALENDAR_TYPE,
                decode(l_periodic_flag,'Y',time.NAME,null) PERIOD_NAME, /* Added for workplan progress */
                -1                              PLAN_VERSION_ID,
                accum.TXN_CURRENCY_CODE         TXN_CURRENCY_CODE,
                accum.TXN_RAW_COST              TXN_RAW_COST,
                accum.TXN_BRDN_COST             TXN_BRDN_COST,
                accum.TXN_REVENUE               TXN_REVENUE,
                decode(tmp4.RESOURCE_CLASS_CODE, 'PEOPLE', accum.TXN_RAW_COST, 0)       TXN_LABOR_RAW_COST,
                decode(tmp4.RESOURCE_CLASS_CODE, 'PEOPLE', accum.TXN_BRDN_COST, 0)      TXN_LABOR_BRDN_COST,
                decode(tmp4.RESOURCE_CLASS_CODE, 'EQUIPMENT', accum.TXN_RAW_COST, 0)    TXN_EQUIP_RAW_COST,
                decode(tmp4.RESOURCE_CLASS_CODE, 'EQUIPMENT', accum.TXN_BRDN_COST, 0)   TXN_EQUIP_BRDN_COST,
                accum.QUANTITY                  QUANTITY,
                accum.PRJ_RAW_COST              PRJ_RAW_COST,
                accum.PRJ_BRDN_COST             PRJ_BRDN_COST,
                accum.PRJ_REVENUE               PRJ_REVENUE,
                decode(tmp4.RESOURCE_CLASS_CODE, 'PEOPLE', accum.PRJ_RAW_COST, 0)       PRJ_LABOR_RAW_COST,
                decode(tmp4.RESOURCE_CLASS_CODE, 'PEOPLE', accum.PRJ_BRDN_COST, 0)      PRJ_LABOR_BRDN_COST,
                decode(tmp4.RESOURCE_CLASS_CODE, 'EQUIPMENT', accum.PRJ_RAW_COST, 0)    PRJ_EQUIP_RAW_COST,
                decode(tmp4.RESOURCE_CLASS_CODE, 'EQUIPMENT', accum.PRJ_BRDN_COST, 0)   PRJ_EQUIP_BRDN_COST,
                accum.POU_RAW_COST              POU_RAW_COST,
                accum.POU_BRDN_COST             POU_BRDN_COST,
                accum.POU_REVENUE               POU_REVENUE,
                decode(tmp4.RESOURCE_CLASS_CODE, 'PEOPLE', accum.POU_RAW_COST, 0)       POU_LABOR_RAW_COST,
                decode(tmp4.RESOURCE_CLASS_CODE, 'PEOPLE', accum.POU_BRDN_COST, 0)      POU_LABOR_BRDN_COST,
                decode(tmp4.RESOURCE_CLASS_CODE, 'EQUIPMENT', accum.POU_RAW_COST, 0)    POU_EQUIP_RAW_COST,
                decode(tmp4.RESOURCE_CLASS_CODE, 'EQUIPMENT', accum.POU_BRDN_COST, 0)   POU_EQUIP_BRDN_COST,
                decode(tmp4.RESOURCE_CLASS_CODE, 'PEOPLE', accum.QUANTITY, 0)           LABOR_HOURS,
                decode(tmp4.RESOURCE_CLASS_CODE, 'EQUIPMENT', accum.QUANTITY, 0)        EQUIP_HOURS,
                null            PERIOD_FLAG,
                null            INCR_QUANTITY,
                null            INCR_POU_RAW_COST,
                null            INCR_POU_BRDN_COST,
                time.START_DATE,
                time.END_DATE
        FROM
                pa_res_list_map_tmp4 tmp4,
                pji_fp_txn_accum accum,
                pji_time_cal_period_v time,
                pji_org_extr_info info
        WHERE
                tmp4.TXN_SOURCE_ID      = accum.TXN_ACCUM_HEADER_ID                 AND
                accum.PROJECT_ID        = p_project_ids(i)                          AND
                accum.NAMED_ROLE        = NVL(tmp4.NAMED_ROLE, 'PJI$NULL')          AND -- Bug 	8294762
                accum.RECVR_PERIOD_ID   = time.CAL_PERIOD_ID                        AND
                /*Added 'G' in below decode for workplan progress */
                accum.RECVR_PERIOD_TYPE = decode(l_calendar_type(i), 'P', 'PA', 'G','GL') AND
                time.CALENDAR_ID        = decode(l_calendar_type(i) , 'P', info.PA_CALENDAR_ID,
                'G',info.GL_CALENDAR_ID)                                            AND
                info.ORG_ID             = l_org_id(i)                               AND
                time.CAL_PERIOD_ID     <= l_end_period_id(i)                        AND
                nvl(p_calling_context,'F')       not in ('P', 'W')
        )
GROUP BY
        RES_LIST_MEMBER_ID,
        PROJECT_ID,
        STRUCT_VERSION_ID,
        DECODE(l_proj_level_flag, 'Y', 0, PROJECT_ELEMENT_ID) ,
        CALENDAR_TYPE,
        PERIOD_NAME,
        PLAN_VERSION_ID,
        TXN_CURRENCY_CODE

UNION ALL

SELECT
        MIN(SOURCE_ID)                  SOURCE_ID,
        RES_LIST_MEMBER_ID              RES_LIST_MEMBER_ID,
        PROJECT_ID                      PROJECT_ID,
        STRUCT_VERSION_ID               STRUCT_VERSION_ID,
        DECODE(l_proj_level_flag,'Y',0,PROJECT_ELEMENT_ID) PROJECT_ELEMENT_ID,
        CALENDAR_TYPE                   CALENDAR_TYPE,
        PERIOD_NAME                     PERIOD_NAME,
        PLAN_VERSION_ID                 PLAN_VERSION_ID,
        TXN_CURRENCY_CODE               TXN_CURRENCY_CODE,
        SUM(TXN_RAW_COST)               TXN_RAW_COST,
        SUM(TXN_BRDN_COST)              TXN_BRDN_COST,
        SUM(TXN_REVENUE)                TXN_REVENUE,
        SUM(TXN_LABOR_RAW_COST)         TXN_LABOR_RAW_COST,
        SUM(TXN_LABOR_BRDN_COST)        TXN_LABOR_BRDN_COST,
        SUM(TXN_EQUIP_RAW_COST)         TXN_EQUIP_RAW_COST,
        SUM(TXN_EQUIP_BRDN_COST)        TXN_EQUIP_BRDN_COST,
        SUM(QUANTITY)                   QUANTITY,
        SUM(PRJ_RAW_COST)               PRJ_RAW_COST,
        SUM(PRJ_BRDN_COST)              PRJ_BRDN_COST,
        SUM(PRJ_REVENUE)                PRJ_REVENUE,
        SUM(PRJ_LABOR_RAW_COST)         PRJ_LABOR_RAW_COST,
        SUM(PRJ_LABOR_BRDN_COST)        PRJ_LABOR_BRDN_COST,
        SUM(PRJ_EQUIP_RAW_COST)         PRJ_EQUIP_RAW_COST,
        SUM(PRJ_EQUIP_BRDN_COST)        PRJ_EQUIP_BRDN_COST,
        SUM(POU_RAW_COST)               POU_RAW_COST,
        SUM(POU_BRDN_COST)              POU_BRDN_COST,
        SUM(POU_REVENUE)                POU_REVENUE,
        SUM(POU_LABOR_RAW_COST)         POU_LABOR_RAW_COST,
        SUM(POU_LABOR_BRDN_COST)        POU_LABOR_BRDN_COST,
        SUM(POU_EQUIP_RAW_COST)         POU_EQUIP_RAW_COST,
        SUM(POU_EQUIP_BRDN_COST)        POU_EQUIP_BRDN_COST,
        SUM(LABOR_HOURS)                LABOR_HOURS,
        SUM(EQUIP_HOURS)                EQUIPMENT_HOURS,
        MIN(PERIOD_FLAG)                PERIOD_FLAG,
        SUM(INCR_QUANTITY)              BASE_LABOR_HOURS,
        SUM(INCR_POU_RAW_COST)          POU_LPB_RAW_COST,
        SUM(INCR_POU_BRDN_COST)         POU_LPB_BRDN_COST,
        MIN(START_DATE)                 MIN_START_DATE,
        MAX(END_DATE)                   MAX_END_DATE
FROM
        (
        SELECT --Retreives actuals data by resource list as ITD amounts for NON-TIME PHASED Calendar
                --from pji_fp_txn_Accum
                /*tmp4.TXN_SOURCE_ID, Commented for workplan progress */
                (null)                          SOURCE_ID,
                tmp4.RESOURCE_LIST_MEMBER_ID    RES_LIST_MEMBER_ID,
                accum.PROJECT_ID                PROJECT_ID,
                p_struct_ver_ids(i)             STRUCT_VERSION_ID,
                accum.TASK_ID                   PROJECT_ELEMENT_ID,
                l_calendar_type(i)              CALENDAR_TYPE,
                NULL                            PERIOD_NAME, /* Added for workplan progress */
                -1                              PLAN_VERSION_ID,
                accum.TXN_CURRENCY_CODE         TXN_CURRENCY_CODE,
                accum.TXN_RAW_COST              TXN_RAW_COST,
                accum.TXN_BRDN_COST             TXN_BRDN_COST,
                accum.TXN_REVENUE               TXN_REVENUE,
                decode(tmp4.RESOURCE_CLASS_CODE, 'PEOPLE', accum.TXN_RAW_COST, 0)       TXN_LABOR_RAW_COST,
                decode(tmp4.RESOURCE_CLASS_CODE, 'PEOPLE', accum.TXN_BRDN_COST, 0)      TXN_LABOR_BRDN_COST,
                decode(tmp4.RESOURCE_CLASS_CODE, 'EQUIPMENT', accum.TXN_RAW_COST, 0)    TXN_EQUIP_RAW_COST,
                decode(tmp4.RESOURCE_CLASS_CODE, 'EQUIPMENT', accum.TXN_BRDN_COST, 0)   TXN_EQUIP_BRDN_COST,
                accum.QUANTITY                  QUANTITY,
                accum.PRJ_RAW_COST              PRJ_RAW_COST,
                accum.PRJ_BRDN_COST             PRJ_BRDN_COST,
                accum.PRJ_REVENUE               PRJ_REVENUE,
                decode(tmp4.RESOURCE_CLASS_CODE, 'PEOPLE', accum.PRJ_RAW_COST, 0)       PRJ_LABOR_RAW_COST,
                decode(tmp4.RESOURCE_CLASS_CODE, 'PEOPLE', accum.PRJ_BRDN_COST, 0)      PRJ_LABOR_BRDN_COST,
                decode(tmp4.RESOURCE_CLASS_CODE, 'EQUIPMENT', accum.PRJ_RAW_COST, 0)    PRJ_EQUIP_RAW_COST,
                decode(tmp4.RESOURCE_CLASS_CODE, 'EQUIPMENT', accum.PRJ_BRDN_COST, 0)   PRJ_EQUIP_BRDN_COST,
                accum.POU_RAW_COST              POU_RAW_COST,
                accum.POU_BRDN_COST             POU_BRDN_COST,
                accum.POU_REVENUE               POU_REVENUE,
                decode(tmp4.RESOURCE_CLASS_CODE, 'PEOPLE', accum.POU_RAW_COST, 0)       POU_LABOR_RAW_COST,
                decode(tmp4.RESOURCE_CLASS_CODE, 'PEOPLE', accum.POU_BRDN_COST, 0)      POU_LABOR_BRDN_COST,
                decode(tmp4.RESOURCE_CLASS_CODE, 'EQUIPMENT', accum.POU_RAW_COST, 0)    POU_EQUIP_RAW_COST,
                decode(tmp4.RESOURCE_CLASS_CODE, 'EQUIPMENT', accum.POU_BRDN_COST, 0)   POU_EQUIP_BRDN_COST,
                decode(tmp4.RESOURCE_CLASS_CODE, 'PEOPLE', accum.QUANTITY, 0)           LABOR_HOURS,
                decode(tmp4.RESOURCE_CLASS_CODE, 'EQUIPMENT', accum.QUANTITY, 0)        EQUIP_HOURS,
                null            PERIOD_FLAG,
                null            INCR_QUANTITY,
                null            INCR_POU_RAW_COST,
                null            INCR_POU_BRDN_COST,
                time.START_DATE,
                time.END_DATE
        FROM
                pa_res_list_map_tmp4 tmp4,
                pji_fp_txn_accum accum,
                pji_time_cal_period_v time
        WHERE
                tmp4.TXN_SOURCE_ID      = accum.TXN_ACCUM_HEADER_ID                 AND
                accum.PROJECT_ID        = p_project_ids(i)                          AND
                accum.NAMED_ROLE        = NVL(tmp4.NAMED_ROLE, 'PJI$NULL')          AND -- Bug 	8294762
                l_calendar_type(i)      = 'A'                                       AND
                accum.RECVR_PERIOD_ID   = time.CAL_PERIOD_ID                        AND
                accum.RECVR_PERIOD_TYPE = 'GL'                                      AND
                nvl(p_calling_context,'F')      not in ('P', 'W')
        )
GROUP BY
        RES_LIST_MEMBER_ID,
        PROJECT_ID,
        STRUCT_VERSION_ID,
        DECODE(l_proj_level_flag, 'Y', 0, PROJECT_ELEMENT_ID) ,
        CALENDAR_TYPE,
        PERIOD_NAME,
        PLAN_VERSION_ID,
        TXN_CURRENCY_CODE
  );
 END IF;/*p_calling_context*/

                print_time ( ' get_summarized_data 0004.4 ' ) ;

        delete from pa_res_list_map_tmp4;

                /* Added for populating periodic actuals till as_of_data parameter */
		/* Bug 	5349102 :shifted the code to delete_fin8
                        IF p_calling_context       in ('P', 'W')   THEN

                                IF l_calendar_type(i)       = 'A' THEN

                                        delete from pji_fm_aggr_fin8 fin where
                                        fin.PROJECT_ID           = p_project_ids(i);
                                ELSE

                                        delete from pji_fm_aggr_fin8 fin where
                                        fin.PROJECT_ID           = p_project_ids(i)
                                        AND  fin.RECVR_PERIOD_ID  <= l_end_period_id(i);
                                END IF;

                        END IF;      */
                /* Added for populating periodic actuals till as_of_data parameter */

   END IF;/* End of l_plan_ver_flag='Y' and  l_get_summarized_Data='Y' */
END LOOP;

    delete
    from  PJI_FM_XBS_ACCUM_TMP1
    where nvl(TXN_RAW_COST, 0)             = 0 and
          nvl(TXN_BRDN_COST, 0)            = 0 and
          nvl(TXN_LABOR_RAW_COST, 0)       = 0 and
          nvl(TXN_LABOR_BRDN_COST, 0)      = 0 and
          nvl(TXN_EQUIP_RAW_COST, 0)       = 0 and
          nvl(TXN_EQUIP_BRDN_COST, 0)      = 0 and
          nvl(TXN_BASE_RAW_COST, 0)        = 0 and
          nvl(TXN_BASE_BRDN_COST, 0)       = 0 and
          nvl(TXN_BASE_LABOR_RAW_COST, 0)  = 0 and
          nvl(TXN_BASE_LABOR_BRDN_COST, 0) = 0 and
          nvl(TXN_BASE_EQUIP_RAW_COST, 0)  = 0 and
          nvl(TXN_BASE_EQUIP_BRDN_COST, 0) = 0 and
          nvl(PRJ_RAW_COST, 0)             = 0 and
          nvl(PRJ_BRDN_COST, 0)            = 0 and
          nvl(PRJ_LABOR_RAW_COST, 0)       = 0 and
          nvl(PRJ_LABOR_BRDN_COST, 0)      = 0 and
          nvl(PRJ_EQUIP_RAW_COST, 0)       = 0 and
          nvl(PRJ_EQUIP_BRDN_COST, 0)      = 0 and
          nvl(PRJ_BASE_RAW_COST, 0)        = 0 and
          nvl(PRJ_BASE_BRDN_COST, 0)       = 0 and
          nvl(PRJ_BASE_LABOR_RAW_COST, 0)  = 0 and
          nvl(PRJ_BASE_LABOR_BRDN_COST, 0) = 0 and
          nvl(PRJ_BASE_EQUIP_RAW_COST, 0)  = 0 and
          nvl(PRJ_BASE_EQUIP_BRDN_COST, 0) = 0 and
          nvl(POU_RAW_COST, 0)             = 0 and
          nvl(POU_BRDN_COST, 0)            = 0 and
          nvl(POU_LABOR_RAW_COST, 0)       = 0 and
          nvl(POU_LABOR_BRDN_COST, 0)      = 0 and
          nvl(POU_EQUIP_RAW_COST, 0)       = 0 and
          nvl(POU_EQUIP_BRDN_COST, 0)      = 0 and
          nvl(POU_BASE_RAW_COST, 0)        = 0 and
          nvl(POU_BASE_BRDN_COST, 0)       = 0 and
          nvl(POU_BASE_LABOR_RAW_COST, 0)  = 0 and
          nvl(POU_BASE_LABOR_BRDN_COST, 0) = 0 and
          nvl(POU_BASE_EQUIP_RAW_COST, 0)  = 0 and
          nvl(POU_BASE_EQUIP_BRDN_COST, 0) = 0 and
          nvl(LABOR_HOURS, 0)              = 0 and
          nvl(EQUIPMENT_HOURS, 0)          = 0 and
          nvl(BASE_LABOR_HOURS, 0)         = 0 and
          nvl(BASE_EQUIP_HOURS, 0)         = 0 and
          nvl(SOURCE_ID, 0)                = 0 and
          nvl(ACT_LABOR_HRS, 0)            = 0 and
          nvl(ACT_EQUIP_HRS, 0)            = 0 and
          nvl(ACT_TXN_LABOR_BRDN_COST, 0)  = 0 and
          nvl(ACT_TXN_EQUIP_BRDN_COST, 0)  = 0 and
          nvl(ACT_TXN_BRDN_COST, 0)        = 0 and
          nvl(ACT_PRJ_LABOR_BRDN_COST, 0)  = 0 and
          nvl(ACT_PRJ_EQUIP_BRDN_COST, 0)  = 0 and
          nvl(ACT_PRJ_BRDN_COST, 0)        = 0 and
          nvl(ACT_PFC_LABOR_BRDN_COST, 0)  = 0 and
          nvl(ACT_PFC_EQUIP_BRDN_COST, 0)  = 0 and
          nvl(ACT_PFC_BRDN_COST, 0)        = 0 and
          nvl(ETC_LABOR_HRS, 0)            = 0 and
          nvl(ETC_EQUIP_HRS, 0)            = 0 and
          nvl(ETC_TXNLABOR_BRDN_COST, 0)   = 0 and
          nvl(ETC_TXN_EQUIP_BRDN_COST, 0)  = 0 and
          nvl(ETC_TXN_BRDN_COST, 0)        = 0 and
          nvl(ETC_PRJ_LABOR_BRDN_COST, 0)  = 0 and
          nvl(ETC_PRJ_EQUIP_BRDN_COST, 0)  = 0 and
          nvl(ETC_PRJ_BRDN_COST, 0)        = 0 and
          nvl(ETC_POU_LABOR_BRDN_COST, 0)  = 0 and
          nvl(ETC_POU_EQUIP_BRDN_COST, 0)  = 0 and
          nvl(ETC_POU_BRDN_COST, 0)        = 0 and
          nvl(ACT_TXN_RAW_COST, 0)         = 0 and
          nvl(ACT_PRJ_RAW_COST, 0)         = 0 and
          nvl(ACT_POU_RAW_COST, 0)         = 0 and
          nvl(ETC_TXN_RAW_COST, 0)         = 0 and
          nvl(ETC_PRJ_RAW_COST, 0)         = 0 and
          nvl(ETC_POU_RAW_COST, 0)         = 0 and
          nvl(ACT_TXN_LABOR_RAW_COST, 0)   = 0 and
          nvl(ACT_TXN_EQUIP_RAW_COST, 0)   = 0 and
          nvl(ACT_PRJ_LABOR_RAW_COST, 0)   = 0 and
          nvl(ACT_PRJ_EQUIP_RAW_COST, 0)   = 0 and
          nvl(ACT_POU_LABOR_RAW_COST, 0)   = 0 and
          nvl(ACT_POU_EQUIP_RAW_COST, 0)   = 0 and
          nvl(ETC_TXN_LABOR_RAW_COST, 0)   = 0 and
          nvl(ETC_TXN_EQUIP_RAW_COST, 0)   = 0 and
          nvl(ETC_PRJ_LABOR_RAW_COST, 0)   = 0 and
          nvl(ETC_PRJ_EQUIP_RAW_COST, 0)   = 0 and
          nvl(ETC_POU_LABOR_RAW_COST, 0)   = 0 and
          nvl(ETC_POU_EQUIP_RAW_COST, 0)   = 0 and
          nvl(ACT_POU_LABOR_BRDN_COST, 0)  = 0 and
          nvl(ACT_POU_EQUIP_BRDN_COST, 0)  = 0 and
          nvl(ACT_POU_BRDN_COST, 0)        = 0 and
          nvl(ETC_TXN_LABOR_BRDN_COST, 0)  = 0 and
          nvl(TXN_LPB_RAW_COST, 0)         = 0 and
          nvl(TXN_LPB_BRDN_COST, 0)        = 0 and
          nvl(TXN_LPB_LABOR_RAW_COST, 0)   = 0 and
          nvl(TXN_LPB_LABOR_BRDN_COST, 0)  = 0 and
          nvl(TXN_LPB_EQUIP_RAW_COST, 0)   = 0 and
          nvl(TXN_LPB_EQUIP_BRDN_COST, 0)  = 0 and
          nvl(PRJ_LPB_RAW_COST, 0)         = 0 and
          nvl(PRJ_LPB_BRDN_COST, 0)        = 0 and
          nvl(PRJ_LPB_LABOR_RAW_COST, 0)   = 0 and
          nvl(PRJ_LPB_LABOR_BRDN_COST, 0)  = 0 and
          nvl(PRJ_LPB_EQUIP_RAW_COST, 0)   = 0 and
          nvl(PRJ_LPB_EQUIP_BRDN_COST, 0)  = 0 and
          nvl(POU_LPB_RAW_COST, 0)         = 0 and
          nvl(POU_LPB_BRDN_COST, 0)        = 0 and
          nvl(POU_LPB_LABOR_RAW_COST, 0)   = 0 and
          nvl(POU_LPB_LABOR_BRDN_COST, 0)  = 0 and
          nvl(POU_LPB_EQUIP_RAW_COST, 0)   = 0 and
          nvl(POU_LPB_EQUIP_BRDN_COST, 0)  = 0 and
          nvl(LPB_LABOR_HOURS, 0)          = 0 and
          nvl(LPB_EQUIP_HOURS, 0)          = 0 and
          RES_LIST_MEMBER_ID               > 0 and
          p_calling_context                = 'W';

IF NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N') = 'Y' THEN
   debug_accum ; /* bug#3993830 */
END IF;

   print_time ( ' get_summarized_data 0010 ' ) ;

EXCEPTION
  WHEN l_map_resource_list THEN   /* Bug No. 4461060 */
    print_time('Error in pkg ' || g_package_name || 'Procedure GET_SUMMARIZED_DATA' || ' is: ' || 'Error is in pa_resource_mapping.map_resource_list' );
    x_return_status :='E' ;

  WHEN OTHERS THEN
    PJI_PJP_FP_CURR_WRAP.EXCP_HANDLER
    ( p_package_name   => g_package_name
    , p_procedure_name => 'GET_SUMMARIZED_DATA'
    , x_return_status =>  x_return_status ) ;

    RAISE;
END;



/*********************************************************
   This procedure populates  data in PJI_FM_XBS_ACCUM_TMP1
   for workplans.
   API supports both work plans and progress actuals
   The parameters that the API accepts can have one of the
   following combinations
   - p_struct_ver_id, p_base_struct_ver_id
   - p_plan_version_id
**********************************************************/

PROCEDURE populate_updatewbs_data (
    p_project_id            IN   NUMBER,
    p_struct_ver_id         IN   NUMBER   := NULL,
    p_base_struct_ver_id    IN   NUMBER   := NULL,
    p_plan_version_id       IN   NUMBER   := NULL,
    p_as_of_date            IN   DATE     := NULL,
    p_delete_flag           IN   VARCHAR2 := 'Y',
    p_project_element_id    IN   NUMBER   := NULL,
    p_level	      IN   NUMBER := 1,
    p_structure_flag   IN   VARCHAR2 := 'N',
    x_return_status OUT NOCOPY   VARCHAR2,
    x_msg_code      OUT NOCOPY   VARCHAR2 ) IS

  l_plan_ver_id      NUMBER;
  l_base_plan_ver_id NUMBER := 0;
  l_wking_struct_ver_id  NUMBER;
  l_prd_start_date   DATE;
  l_calendar_id      NUMBER;
  l_org_id           NUMBER;
  l_calendar_type    VARCHAR2(1);
 -- changes made for populate_workplan_data fix for bug : 4158221
  l_cal_type         VARCHAR2(1) :=  'A' ;
  l_prd_type_id      NUMBER      := 2048 ;
  l_end_period_id    NUMBER := -1 ; -- Added Defalut value of -1 if calander_type = 'A'

  l_lpb_plan_ver_id Number; /*Added for workplan progress */
  l_lpb_struct_ver_id Number; /* Added for workplan progress*/
  l_return_status       VARCHAR2(1);
  p_workplan_flag VARCHAR2(1) :='Y';
  p_program_rollup_flag VARCHAR2(1) :='N';

BEGIN

    PJI_PJP_FP_CURR_WRAP.INIT_ERR_STACK
    ( p_package_name   => g_package_name
    , x_return_status  => x_return_status );

    print_time (' p_project_id ' || p_project_id || ' p_struct_ver_id ' || p_struct_ver_id );
    print_time (' p_base_struct_ver_id ' || p_base_struct_ver_id || ' p_plan_version_id ' || p_plan_version_id );
    print_time ( ' p_as_of_date ' || p_as_of_date );
    print_time (' p_delete_flag ' || p_delete_flag || ' p_workplan_flag ' || p_workplan_flag );

    -- fnd_stats.set_table_stats('PJI','PJI_PLAN_EXTR_TMP',10,10,10);
    pji_pjp_fp_curr_wrap.set_table_stats('PJI','PJI_PLAN_EXTR_TMP',10,10,10);

        l_return_status := Fnd_Api.G_RET_STS_SUCCESS;
    /* Added for workplan progress */
    -- Get the Latest Published Version for the Project

                BEGIN
                        SELECT element_version_id
                                INTO l_lpb_struct_ver_id
                        FROM    pa_proj_elem_ver_structure ppevs,
                                pa_proj_structure_types ppst
                        WHERE   ppevs.project_id = p_project_id
                                AND latest_eff_published_flag = 'Y'
                                AND ppst.proj_element_id = ppevs.proj_element_id
                                AND ppst.structure_type_id = 1;
                EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                        l_lpb_struct_ver_id := null;
                END;


        IF l_lpb_struct_ver_id <>  -1 then -- To find out the latest published plan version Id

                BEGIN
                        SELECT budget_version_id
                                INTO l_lpb_plan_ver_id
                                FROM PA_BUDGET_VERSIONS
                        WHERE project_structure_Version_id = l_lpb_struct_ver_id
                                AND wp_version_flag ='Y'
                                AND project_id      = p_project_id;

                EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                                l_lpb_plan_ver_id := null;
                END;
        ELSE
                        l_lpb_struct_ver_id :=null;
                        l_lpb_plan_ver_id := null;
        END IF;


 /* End of workplan progress change */



        IF (p_plan_version_id IS NOT NULL) THEN

                l_plan_ver_id := p_plan_version_id;

                BEGIN

                print_time ( ' populate_updatewbs_data 0003.2 ' ) ;

                        SELECT WBS_VERSION_ID
                                INTO   l_wking_struct_ver_id
                        FROM   pji_pjp_wbs_header
                        WHERE  plan_version_id  = p_plan_version_id;

                EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                        print_time( 'PJI_FM_XBS_ACCUM_UTILS.POPULATE_WORKPLAN_DATA. Structure info does not exist for this plan version in WBS header table ' || NVL(p_plan_version_id, -99));
                END;

        ELSE

                print_time ( ' populate_updatewbs_data 0003.3 ' ) ;

                l_wking_struct_ver_id := p_struct_ver_id ;

                --Get the plan version for work plan

                BEGIN
                        print_time ( ' populate_updatewbs_data 0003.4 ' ) ;

                        SELECT head.PLAN_VERSION_ID
                        INTO l_plan_ver_id
                        FROM pji_pjp_wbs_header head,
                             pa_budget_versions bv
                        WHERE 1=1
                                AND head.plan_version_id = bv.budget_version_id
                                AND NVL(bv.wp_version_flag, 'N') = head.wp_flag
                                AND NVL(bv.wp_version_flag, 'N') = p_workplan_flag
                                AND head.WBS_VERSION_ID = p_struct_ver_id
                                AND head.PROJECT_ID     = p_project_id
                                AND DECODE(p_workplan_flag
                                , 'N'
                                , DECODE(bv.budget_status_code||bv.current_working_flag
                                , 'WY'
                                ,'X'
                                , 'Y')
                                , 'X') = 'X'
                                AND head.PLAN_VERSION_ID > 0;

                EXCEPTION
                        WHEN no_data_found THEN
                        print_time( 'PJI_FM_XBS_ACCUM_UTILS.POPULATE_WORKPLAN_DATA. Plan info does not exists for this project id ' || p_project_id || ' and this structure version id ' || p_struct_ver_id  || ' in WBS header table.');

                END;

                        print_time ( ' populate_updatewbs_data 0003.5 ' ) ;


                --Get the baselined plan version

                BEGIN

                        print_time ( ' populate_updatewbs_data 0003.6 ' ) ;

                        SELECT  head.PLAN_VERSION_ID
                        INTO    l_base_plan_ver_id
                        FROM    pji_pjp_wbs_header head,
                                 pa_budget_versions bv
                        WHERE   1=1
                                AND head.plan_version_id = bv.budget_version_id
                                AND NVL(bv.wp_version_flag, 'N') = head.wp_flag
                                AND NVL(bv.wp_version_flag, 'N') = p_workplan_flag
                                AND head.WBS_VERSION_ID = p_base_struct_ver_id
                                AND head.PROJECT_ID     = p_project_id
                                AND DECODE(p_workplan_flag
                                , 'N'
                                , DECODE(bv.budget_status_code||bv.current_flag
                                , 'BY','X'
                                , 'Y')
                                , 'X')
                                = 'X'
                                AND head.PLAN_VERSION_ID > 0;

                EXCEPTION
                        WHEN no_data_found THEN
                        print_time( 'PJI_FM_XBS_ACCUM_UTILS.POPULATE_WORKPLAN_DATA no current baselined plan version');
                END;

        END IF;


    print_time ( ' populate_updatewbs_data 0003.7 p_project_id' || p_project_id ) ;
    print_time ( ' l_base_plan_ver_id ' || l_base_plan_ver_id || ' plan_ver_id ' || l_plan_ver_id ) ;

-- Changes made for populate_work_plan_data chagnes : Fix for bug : 4158221
        If p_as_of_date IS NOT NULL then -- Fix for bug : 4196808
                BEGIN
                        SELECT calendar_type, DECODE(calendar_type, 'A', 2048, 32) PERIOD_TYPE_ID
                        INTO l_cal_type,  l_prd_type_id
                        FROM
                        (
                                SELECT
                                DECODE(NVL(NVL(cost_time_phased_code, revenue_time_phased_code), all_time_phased_code), 'G', 'G', 'P', 'P', 'A') calendar_type
                                FROM  pa_proj_fp_options
                                WHERE  fin_plan_option_level_code = 'PLAN_VERSION'
                                AND  fin_plan_version_id        =  l_plan_ver_id
                        ) ;
                EXCEPTION
                        when no_data_found then
                        print_time( 'PJI_FM_XBS_ACCUM_UTILS.POPULATE_WORKPLAN_DATA : No calendar_type');
                        when others then
                        print_time( 'PJI_FM_XBS_ACCUM_UTILS.POPULATE_WORKPLAN_DATA : No Calander_Type');
                END ;

                BEGIN
                        SELECT ORG_ID
                        INTO   l_org_id
                        FROM   pa_projects_all
                        WHERE  project_id = p_project_id ;

                        IF L_CAL_TYPE IN ('P', 'G') THEN -- retrieve CAL_PERIOD_ID only if calander_type is 'P' or 'G'
                                SELECT cal.CAL_PERIOD_ID
                                        INTO l_end_period_id
                                FROM pji_time_cal_period_v cal, pji_org_extr_info    info
                                WHERE TRUNC(p_as_of_date)
                                        BETWEEN TRUNC(cal.START_DATE) AND TRUNC(cal.END_DATE)
                                        AND info.ORG_ID  = l_org_id
                                        AND DECODE(l_cal_type, 'P', info.PA_CALENDAR_ID, info.GL_CALENDAR_ID) = cal.CALENDAR_ID;
                        END IF ;
                EXCEPTION
                        when no_data_found then
                                print_time( 'PJI_FM_XBS_ACCUM_UTILS.POPULATE_WORKPLAN_DATA : No Calander Period Id');
                        when others then
                                print_time( 'PJI_FM_XBS_ACCUM_UTILS.POPULATE_WORKPLAN_DATA : No Calander Period Id');
                END ;
        END IF ; -- end if for If p_as_of_date IS NOT NULL then



        DELETE FROM PJI_PLAN_EXTR_TMP;
        print_time ( ' # rows deleted from tmp = ' || SQL%ROWCOUNT ) ;


--Ensures that data is cleaned up for the Project / Program and the linked sub projects
        IF (p_delete_flag = 'Y') THEN

                print_time ( ' populate_updatewbs_data 0002 ' ) ;
                DELETE FROM pji_fm_xbs_accum_tmp1;
                print_time ( ' # rows deleted from tmp1 = ' || SQL%ROWCOUNT ) ;

        END IF;

print_time ( ' populate_updatewbs_data 0003 ' ) ;

 -- The Temp table is populated with the PROJECT_ID and the PROJECT_ELEMENT_ID

IF  p_structure_flag ='N'  THEN

		insert into PJI_PLAN_EXTR_TMP(project_id,plan_ver_id)
		select sup_project_id,sub_emt_id
		from   pji_xbs_Denorm
		where  sup_project_id=p_project_id
		and    struct_version_id = p_struct_ver_id
		and    sup_emt_id=p_project_element_id
		and    sup_level <> sub_level
		and    abs(sup_level - sub_level) <=p_level ;
ELSE
		insert into PJI_PLAN_EXTR_TMP(project_id,plan_ver_id)
		select sub.sup_project_id,sub.sub_emt_id
		from   pji_xbs_Denorm sup,pji_xbs_Denorm sub
		where  sup.sup_project_id=p_project_id
		and    sup.sup_project_id =sub.sup_project_id
		and    sup.sup_id = p_struct_ver_id
		and    sup.sub_id = sub.sup_id
		and    sub.struct_type<> 'XBS'
		and    sup.struct_type<> 'WBS'
		and    abs(sub.sup_level - sub.sub_level) <=p_level -1;
END IF;

    --
    -- Get task level data from reporting lines
    -- Data is rolled up by WBS hierarchy
    -- Data inserted is the Totals
    --

          INSERT INTO pji_fm_xbs_accum_tmp1 (
                PROJECT_ID,  STRUCT_VERSION_ID,       PROJECT_ELEMENT_ID,      CALENDAR_TYPE,
                PERIOD_NAME,      PLAN_VERSION_ID,        QUANTITY,         TXN_RAW_COST,
                TXN_BRDN_COST,        TXN_REVENUE,         TXN_LABOR_RAW_COST,      TXN_LABOR_BRDN_COST,
                TXN_EQUIP_RAW_COST,      TXN_EQUIP_BRDN_COST,     TXN_BASE_RAW_COST,       TXN_BASE_BRDN_COST,
                TXN_BASE_LABOR_RAW_COST, TXN_BASE_LABOR_BRDN_COST,TXN_BASE_EQUIP_RAW_COST, TXN_BASE_EQUIP_BRDN_COST,
                TXN_LPB_RAW_COST,        TXN_LPB_BRDN_COST,       TXN_LPB_LABOR_RAW_COST,  TXN_LPB_LABOR_BRDN_COST,
                TXN_LPB_EQUIP_RAW_COST,  TXN_LPB_EQUIP_BRDN_COST, PRJ_RAW_COST,          PRJ_BRDN_COST,
                PRJ_REVENUE,        PRJ_LABOR_RAW_COST,      PRJ_LABOR_BRDN_COST,     PRJ_EQUIP_RAW_COST,
                PRJ_EQUIP_BRDN_COST,  PRJ_BASE_RAW_COST,       PRJ_BASE_BRDN_COST,      PRJ_BASE_LABOR_RAW_COST,
                PRJ_BASE_LABOR_BRDN_COST,PRJ_BASE_EQUIP_RAW_COST, PRJ_BASE_EQUIP_BRDN_COST,PRJ_LPB_RAW_COST,
                PRJ_LPB_BRDN_COST,       PRJ_LPB_LABOR_RAW_COST,  PRJ_LPB_LABOR_BRDN_COST, PRJ_LPB_EQUIP_RAW_COST,
                PRJ_LPB_EQUIP_BRDN_COST, POU_RAW_COST,          POU_BRDN_COST,           POU_REVENUE,
                POU_LABOR_RAW_COST,      POU_LABOR_BRDN_COST,     POU_EQUIP_RAW_COST,      POU_EQUIP_BRDN_COST,
                POU_BASE_RAW_COST,       POU_BASE_BRDN_COST,      POU_BASE_LABOR_RAW_COST, POU_BASE_LABOR_BRDN_COST,
                POU_BASE_EQUIP_RAW_COST, POU_BASE_EQUIP_BRDN_COST,POU_LPB_RAW_COST,        POU_LPB_BRDN_COST,
                POU_LPB_LABOR_RAW_COST,  POU_LPB_LABOR_BRDN_COST, POU_LPB_EQUIP_RAW_COST,  POU_LPB_EQUIP_BRDN_COST,
                LABOR_HOURS,          EQUIPMENT_HOURS,         BASE_LABOR_HOURS,        BASE_EQUIP_HOURS,
                LPB_LABOR_HOURS,         LPB_EQUIP_HOURS,   ACT_LABOR_HRS,     ACT_EQUIP_HRS,
                ACT_TXN_LABOR_BRDN_COST, ACT_TXN_EQUIP_BRDN_COST, ACT_TXN_RAW_COST,     ACT_TXN_BRDN_COST,
                ACT_PRJ_LABOR_BRDN_COST, ACT_PRJ_EQUIP_BRDN_COST, ACT_PRJ_RAW_COST,     ACT_PRJ_BRDN_COST,
                ACT_POU_LABOR_BRDN_COST, ACT_POU_EQUIP_BRDN_COST, ACT_POU_RAW_COST,     ACT_POU_BRDN_COST,
                ETC_LABOR_HRS,           ETC_EQUIP_HRS,    ETC_TXN_LABOR_BRDN_COST, ETC_TXN_EQUIP_BRDN_COST,
                ETC_TXN_RAW_COST,   ETC_TXN_BRDN_COST,    ETC_PRJ_LABOR_BRDN_COST, ETC_PRJ_EQUIP_BRDN_COST,
                ETC_PRJ_RAW_COST,        ETC_PRJ_BRDN_COST,    ETC_POU_LABOR_BRDN_COST, ETC_POU_EQUIP_BRDN_COST,
                ETC_POU_RAW_COST,        ETC_POU_BRDN_COST,     ACT_TXN_LABOR_RAW_COST , ACT_PRJ_LABOR_RAW_COST,
                ACT_POU_LABOR_RAW_COST,  ACT_TXN_EQUIP_RAW_COST,  ACT_PRJ_EQUIP_RAW_COST,  ACT_POU_EQUIP_RAW_COST,
                ETC_TXN_LABOR_RAW_COST,  ETC_PRJ_LABOR_RAW_COST,  ETC_POU_LABOR_RAW_COST,  ETC_TXN_EQUIP_RAW_COST,
                ETC_PRJ_EQUIP_RAW_COST,  ETC_POU_EQUIP_RAW_COST,  P_RAW_COST,P_BRDN_COST,  P_REVENUE,
                P_LBR_RAW_COST,  P_LBR_BRDN_COST,   P_EQP_RAW_COST,    P_EQP_BRDN_COST,
                P_BASE_RAW_COST,  P_BASE_BRDN_COST,   P_BASE_LBR_RAW_COST,    P_BASE_LBR_BRDN_COST,
                P_BASE_EQP_RAW_COST,  P_BASE_EQP_BRDN_COST,   P_LPB_RAW_COST,    P_LPB_BRDN_COST,
                P_LPB_LBR_RAW_COST,  P_LPB_LBR_BRDN_COST,   P_LPB_EQP_RAW_COST,    P_LPB_EQP_BRDN_COST,
                P_LBR_HOURS,  P_EQP_HOURS,   P_BASE_LBR_HOURS,    P_BASE_EQP_HOURS,
                P_LPB_LBR_HOURS,  P_LPB_EQP_HOURS,   P_ACT_LBR_HOURS,    P_ACT_EQP_HOURS,
                P_ACT_LBR_BRDN_COST,  P_ACT_EQP_BRDN_COST,   P_ACT_RAW_COST,     P_ACT_BRDN_COST,
                P_ACT_LBR_RAW_COST,  P_ACT_EQP_RAW_COST,   P_ETC_EQP_HOURS,         P_ETC_LBR_HOURS,
                P_ETC_RAW_COST,  P_ETC_BRDN_COST,   P_ETC_LBR_BRDN_COST,     P_ETC_EQP_BRDN_COST,
                P_ETC_LBR_RAW_COST,P_ETC_EQP_RAW_COST
                )
        SELECT       /*+ LEADING(head) USE_NL(fact.fact) */
                      fact.PROJECT_ID,
                      l_wking_struct_ver_id  STRUCT_VERSION_ID,
                      fact.PROJECT_ELEMENT_ID  PROJECT_ELEMENT_ID,
                      'A',
                      null  PERIOD_NAME,
                      l_plan_ver_id  PLAN_VERSION_ID,
                      0  QUANTITY,
                      sum(case when fact.plan_version_id  = l_plan_ver_id then fact.raw_cost*TXN_MASK else 0 end)   TXN_RAW_COST,
                      sum(case when fact.plan_version_id  = l_plan_ver_id then fact.brdn_cost*TXN_MASK else 0 end)   TXN_BRDN_COST,
                      sum(case when fact.plan_version_id  = l_plan_ver_id then fact.revenue*TXN_MASK else 0 end)   TXN_REVENUE,
                      sum(case when fact.plan_version_id  = l_plan_ver_id then fact.labor_raw_cost*TXN_MASK else 0 end)  TXN_LABOR_RAW_COST,
                      sum(case when fact.plan_version_id  = l_plan_ver_id then fact.labor_brdn_cost*TXN_MASK else 0 end)   TXN_LABOR_BRDN_COST,
                      sum(case when fact.plan_version_id  = l_plan_ver_id then fact.equipment_raw_cost*TXN_MASK else 0 end)   TXN_EQUIP_RAW_COST,
                      sum(case when fact.plan_version_id  = l_plan_ver_id then fact.equipment_brdn_cost*TXN_MASK else 0 end)   TXN_EQUIP_BRDN_COST,

                      sum(case when fact.plan_version_id  = l_base_plan_ver_id then fact.raw_cost*TXN_MASK else 0 end)    TXN_BASE_RAW_COST,
                      sum(case when fact.plan_version_id  = l_base_plan_ver_id then fact.brdn_cost*TXN_MASK else 0 end)   TXN_BASE_BRDN_COST,
                      sum(case when fact.plan_version_id  = l_base_plan_ver_id then fact.labor_raw_cost*TXN_MASK else 0 end)   TXN_BASE_LABOR_RAW_COST,
                      sum(case when fact.plan_version_id  = l_base_plan_ver_id then fact.labor_brdn_cost*TXN_MASK else 0 end)    TXN_BASE_LABOR_BRDN_COST,
                      sum(case when fact.plan_version_id  = l_base_plan_ver_id then fact.equipment_raw_cost*TXN_MASK else 0 end)  TXN_BASE_EQUIP_RAW_COST,
                      sum(case when fact.plan_version_id  = l_base_plan_ver_id then fact.equipment_brdn_cost*TXN_MASK else 0 end)  TXN_BASE_EQUIP_BRDN_COST,

                      sum(case when fact.plan_version_id  = l_lpb_plan_ver_id then fact.raw_cost*TXN_MASK else 0 end)   TXN_LPB_RAW_COST,
                      sum(case when fact.plan_version_id  = l_lpb_plan_ver_id then fact.brdn_cost*TXN_MASK else 0 end)   TXN_LPB_BRDN_COST,
                      sum(case when fact.plan_version_id  = l_lpb_plan_ver_id then fact.labor_raw_cost*TXN_MASK else 0 end)   TXN_LPB_LABOR_RAW_COST,
                      sum(case when fact.plan_version_id  = l_lpb_plan_ver_id then fact.labor_brdn_cost*TXN_MASK else 0 end)   TXN_LPB_LABOR_BRDN_COST,
                      sum(case when fact.plan_version_id  = l_lpb_plan_ver_id then fact.equipment_raw_cost*TXN_MASK else 0 end) TXN_LPB_EQUIP_RAW_COST,
                      sum(case when fact.plan_version_id  = l_lpb_plan_ver_id then fact.equipment_brdn_cost*TXN_MASK else 0 end)  TXN_LPB_EQUIP_BRDN_COST,

                      sum(case when fact.plan_version_id  = l_plan_ver_id then fact.raw_cost*PRJ_MASK else 0 end)   PRJ_RAW_COST,
                      sum(case when fact.plan_version_id  = l_plan_ver_id then fact.brdn_cost*PRJ_MASK else 0 end)  PRJ_BRDN_COST,
                      sum(case when fact.plan_version_id  = l_plan_ver_id then fact.revenue*PRJ_MASK else 0 end)  PRJ_REVENUE,
                      sum(case when fact.plan_version_id  = l_plan_ver_id then fact.labor_raw_cost*PRJ_MASK else 0 end)   PRJ_LABOR_RAW_COST,
                      sum(case when fact.plan_version_id  = l_plan_ver_id then fact.labor_brdn_cost*PRJ_MASK else 0 end)   PRJ_LABOR_BRDN_COST,
                      sum(case when fact.plan_version_id  = l_plan_ver_id then fact.equipment_raw_cost*PRJ_MASK else 0 end)   PRJ_EQUIP_RAW_COST,
                      sum(case when fact.plan_version_id  = l_plan_ver_id then fact.equipment_brdn_cost*PRJ_MASK else 0 end)   PRJ_EQUIP_BRDN_COST,

                      sum(case when fact.plan_version_id  = l_base_plan_ver_id then fact.raw_cost*PRJ_MASK else 0 end)   PRJ_BASE_RAW_COST,
                      sum(case when fact.plan_version_id  = l_base_plan_ver_id then fact.brdn_cost*PRJ_MASK else 0 end)   PRJ_BASE_BRDN_COST,
                      sum(case when fact.plan_version_id  = l_base_plan_ver_id then fact.labor_raw_cost*PRJ_MASK else 0 end)   PRJ_BASE_LABOR_RAW_COST,
                      sum(case when fact.plan_version_id  = l_base_plan_ver_id then fact.labor_brdn_cost*PRJ_MASK else 0 end)   PRJ_BASE_LABOR_BRDN_COST,
                      sum(case when fact.plan_version_id  = l_base_plan_ver_id then fact.equipment_raw_cost*PRJ_MASK else 0 end) PRJ_BASE_EQUIP_RAW_COST,
                      sum(case when fact.plan_version_id  = l_base_plan_ver_id then fact.equipment_brdn_cost*PRJ_MASK else 0 end) PRJ_BASE_EQUIP_BRDN_COST,

                      sum(case when fact.plan_version_id  = l_lpb_plan_ver_id then fact.raw_cost*PRJ_MASK else 0 end)   PRJ_LPB_RAW_COST,
                      sum(case when fact.plan_version_id  = l_lpb_plan_ver_id then fact.brdn_cost*PRJ_MASK else 0 end)   PRJ_LPB_BRDN_COST,
                      sum(case when fact.plan_version_id  = l_lpb_plan_ver_id then fact.labor_raw_cost*PRJ_MASK else 0 end)   PRJ_LPB_LABOR_RAW_COST,
                      sum(case when fact.plan_version_id  = l_lpb_plan_ver_id then fact.labor_brdn_cost*PRJ_MASK else 0 end)  PRJ_LPB_LABOR_BRDN_COST,
                      sum(case when fact.plan_version_id  = l_lpb_plan_ver_id then fact.equipment_raw_cost*PRJ_MASK else 0 end) PRJ_LBP_EQUIP_RAW_COST,
                      sum(case when fact.plan_version_id  = l_lpb_plan_ver_id then fact.equipment_brdn_cost*PRJ_MASK else 0 end) PRJ_LBP_EQUIP_BRDN_COST,

                      sum(case when fact.plan_version_id  = l_plan_ver_id then fact.raw_cost*POU_MASK else 0 end)  POU_RAW_COST,
                      sum(case when fact.plan_version_id  = l_plan_ver_id then fact.brdn_cost*POU_MASK else 0 end)  POU_BRDN_COST,
                      sum(case when fact.plan_version_id  = l_plan_ver_id then fact.revenue*POU_MASK else 0 end)  POU_REVENUE,
                      sum(case when fact.plan_version_id  = l_plan_ver_id then fact.labor_raw_cost*POU_MASK else 0 end)  POU_LABOR_RAW_COST,
                      sum(case when fact.plan_version_id  = l_plan_ver_id then fact.labor_brdn_cost*POU_MASK else 0 end)   POU_LABOR_BRDN_COST,
                      sum(case when fact.plan_version_id  = l_plan_ver_id then fact.equipment_raw_cost*POU_MASK else 0 end)   POU_EQUIP_RAW_COST,
                      sum(case when fact.plan_version_id  = l_plan_ver_id then fact.equipment_brdn_cost*POU_MASK else 0 end)   POU_EQUIP_BRDN_COST,

                      sum(case when fact.plan_version_id  = l_base_plan_ver_id then fact.raw_cost*POU_MASK else 0 end)   POU_BASE_RAW_COST,
                      sum(case when fact.plan_version_id  = l_base_plan_ver_id then fact.brdn_cost*POU_MASK else 0 end)   POU_BASE_BRDN_COST,
                      sum(case when fact.plan_version_id  = l_base_plan_ver_id then fact.labor_raw_cost*POU_MASK else 0 end)   POU_BASE_LABOR_RAW_COST,
                      sum(case when fact.plan_version_id  = l_base_plan_ver_id then fact.labor_brdn_cost*POU_MASK else 0 end)   POU_BASE_LABOR_BRDN_COST,
                      sum(case when fact.plan_version_id  = l_base_plan_ver_id then fact.equipment_raw_cost*POU_MASK else 0 end) POU_BASE_EQUIP_RAW_COST,
                      sum(case when fact.plan_version_id  = l_base_plan_ver_id then fact.equipment_brdn_cost*POU_MASK else 0 end) POU_BASE_EQUIP_BRDN_COST,

                      sum(case when fact.plan_version_id  = l_lpb_plan_ver_id then fact.raw_cost*POU_MASK else 0 end)   POU_LPB_RAW_COST,
                      sum(case when fact.plan_version_id  = l_lpb_plan_ver_id then fact.brdn_cost*POU_MASK else 0 end)   POU_LPB_BRDN_COST,
                      sum(case when fact.plan_version_id  = l_lpb_plan_ver_id then fact.labor_raw_cost*POU_MASK else 0 end)  POU_LPB_LABOR_RAW_COST,
                      sum(case when fact.plan_version_id  = l_lpb_plan_ver_id then fact.labor_brdn_cost*POU_MASK else 0 end)   POU_LPB_LABOR_BRDN_COST,
                      sum(case when fact.plan_version_id  = l_lpb_plan_ver_id then fact.equipment_raw_cost*POU_MASK else 0 end) POU_LPB_EQUIP_RAW_COST,
                      sum(case when fact.plan_version_id  = l_lpb_plan_ver_id then fact.equipment_brdn_cost*POU_MASK else 0 end) POU_LPB_EQUIP_BRDN_COST,

                      sum(case when fact.plan_version_id  = l_plan_ver_id then fact.LABOR_HRS else 0 end)   LABOR_HOURS,
                      sum(case when fact.plan_version_id  = l_plan_ver_id then fact.EQUIPMENT_HOURS else 0 end)   EQUIPMENT_HOURS,
                      sum(case when fact.plan_version_id  = l_base_plan_ver_id then fact.LABOR_HRS else 0 end)   BASE_LABOR_HOURS,
                      sum(case when fact.plan_version_id  = l_base_plan_ver_id  then fact.EQUIPMENT_HOURS else 0 end)  BASE_EQUIP_HOURS,
                      sum(case when fact.plan_version_id  = l_lpb_plan_ver_id then fact.LABOR_HRS else 0 end)   LPB_LABOR_HOURS,
                      sum(case when fact.plan_version_id  = l_lpb_plan_ver_id  then fact.EQUIPMENT_HOURS else 0 end)   LPB_EQUIP_HOURS,

                      sum( case when  fact.time_id <= l_end_period_id
                           then
                           decode(fact.plan_version_id, l_plan_ver_id, fact.ACT_LABOR_HRS, 0)
                           else
                           NULL
                           end
                         ) ACT_LABOR_HRS,
                      sum( case when  fact.time_id <= l_end_period_id
                           then
                           decode(fact.plan_version_id, l_plan_ver_id, fact.ACT_EQUIP_HRS, 0)
                           else
                           NULL
                           end
                         ) ACT_EQUIP_HRS,
                      sum( case when  fact.time_id <= l_end_period_id
                           then
                           decode(fact.plan_version_id, l_plan_ver_id, TXN_MASK* fact.act_labor_brdn_cost, 0 )
                           else
                           NULL
                           end
                         ) ACT_TXN_LABOR_BRDN_COST,
                      sum( case when  fact.time_id <= l_end_period_id
                           then
                           decode(fact.plan_version_id, l_plan_ver_id, TXN_MASK* fact.act_equip_brdn_cost, 0 )
                           else
                           NULL
                           end
                         ) ACT_TXN_EQUIP_BRDN_COST,
                      sum( case when  fact.time_id <= l_end_period_id
                           then
                           decode(fact.plan_version_id, l_plan_ver_id, TXN_MASK* fact.act_raw_cost, 0 )
                           else
                           NULL
                           end
                         ) ACT_TXN_RAW_COST,
                      sum( case when  fact.time_id <= l_end_period_id
                           then
                           decode(fact.plan_version_id, l_plan_ver_id, TXN_MASK* fact.act_brdn_cost, 0 )
                           else
                           NULL
                           end
                         ) ACT_TXN_BRDN_COST,
                      sum( case when  fact.time_id <= l_end_period_id
                           then
                           decode(fact.plan_version_id, l_plan_ver_id, PRJ_MASK*  fact.act_labor_brdn_cost, 0)
                           else
                           NULL
                           end
                         ) ACT_PRJ_LABOR_BRDN_COST,
                      sum( case when  fact.time_id <= l_end_period_id
                           then
                           decode(fact.plan_version_id, l_plan_ver_id, PRJ_MASK*  fact.act_equip_brdn_cost, 0)
                           else
                           NULL
                           end
                         ) ACT_PRJ_EQUIP_BRDN_COST,
                      sum( case when  fact.time_id <= l_end_period_id
                           then
                           decode(fact.plan_version_id, l_plan_ver_id, PRJ_MASK*  fact.act_raw_cost, 0 )
                           else
                           NULL
                           end
                         ) ACT_PRJ_RAW_COST,
                      sum( case when  fact.time_id <= l_end_period_id
                           then
                           decode(fact.plan_version_id, l_plan_ver_id, PRJ_MASK*  fact.act_brdn_cost, 0 )
                           else
                           NULL
                           end
                         ) ACT_PRJ_BRDN_COST,
                      sum( case when  fact.time_id <= l_end_period_id
                           then
                           decode(fact.plan_version_id, l_plan_ver_id, POU_MASK*  fact.act_labor_brdn_cost, 0 )
                           else
                           NULL
                           end
                         ) ACT_POU_LABOR_BRDN_COST,
                      sum( case when  fact.time_id <= l_end_period_id
                           then
                           decode(fact.plan_version_id, l_plan_ver_id, POU_MASK*  fact.act_equip_brdn_cost, 0 )
                           else
                           NULL
                           end
                         ) ACT_POU_EQUIP_BRDN_COST,
                      sum( case when  fact.time_id <= l_end_period_id
                           then
                           decode(fact.plan_version_id, l_plan_ver_id, POU_MASK*  fact.act_raw_cost, 0 )
                           else
                           NULL
                           end
                         ) ACT_POU_RAW_COST,
                      sum( case when  fact.time_id <= l_end_period_id
                           then
                           decode(fact.plan_version_id, l_plan_ver_id, POU_MASK*  fact.act_brdn_cost, 0 )
                           else
                           NULL
                           end
                         ) ACT_POU_BRDN_COST,

                      sum(case when fact.plan_version_id      = l_plan_ver_id then fact.ETC_LABOR_HRS else 0 end)  ETC_LABOR_HRS,
                      sum(case when fact.plan_version_id      = l_plan_ver_id then fact.ETC_EQUIP_HRS else 0 end)  ETC_EQUIP_HRS,
                      sum(case when fact.plan_version_id  = l_plan_ver_id then fact.ETC_labor_brdn_cost*TXN_MASK else 0 end)  ETC_TXN_LABOR_BRDN_COST,
                      sum(case when fact.plan_version_id  = l_plan_ver_id then fact.ETC_equip_brdn_cost*TXN_MASK else 0 end)  ETC_TXN_EQUIP_BRDN_COST,
                      sum(case when fact.plan_version_id  = l_plan_ver_id then fact.ETC_raw_cost*TXN_MASK else 0 end)   ETC_TXN_RAW_COST,
                      sum(case when fact.plan_version_id  = l_plan_ver_id then fact.ETC_brdn_cost*TXN_MASK else 0 end)   ETC_TXN_BRDN_COST,
                      sum(case when fact.plan_version_id  = l_plan_ver_id then fact.ETC_labor_brdn_cost*PRJ_MASK else 0 end)  ETC_PRJ_LABOR_BRDN_COST,
                      sum(case when fact.plan_version_id  = l_plan_ver_id then fact.ETC_equip_brdn_cost*PRJ_MASK else 0 end)  ETC_PRJ_EQUIP_BRDN_COST,
                      sum(case when fact.plan_version_id  = l_plan_ver_id then fact.ETC_raw_cost*PRJ_MASK else 0 end)   ETC_PRJ_RAW_COST,
                      sum(case when fact.plan_version_id  = l_plan_ver_id then fact.ETC_brdn_cost*PRJ_MASK else 0 end)   ETC_PRJ_BRDN_COST,
                      sum(case when fact.plan_version_id  = l_plan_ver_id then fact.ETC_labor_brdn_cost*POU_MASK else 0 end)  ETC_POU_LABOR_BRDN_COST,
                      sum(case when fact.plan_version_id  = l_plan_ver_id then fact.ETC_equip_brdn_cost*POU_MASK else 0 end)  ETC_POU_EQUIP_BRDN_COST,
                      sum(case when fact.plan_version_id  = l_plan_ver_id then fact.ETC_raw_cost*POU_MASK else 0 end)   ETC_POU_RAW_COST,
                      sum(case when fact.plan_version_id  = l_plan_ver_id then fact.ETC_brdn_cost*POU_MASK else 0 end)   ETC_POU_BRDN_COST,
                      sum( case when  fact.time_id <= l_end_period_id
                           then
                           decode(fact.plan_version_id, l_plan_ver_id, TXN_MASK*fact.act_labor_raw_cost,0)
                           else
                           NULL
                           end
                         ) ACT_TXN_LABOR_RAW_COST,
                      sum( case when  fact.time_id <= l_end_period_id
                           then
                           decode(fact.plan_version_id, l_plan_ver_id, PRJ_MASK* fact.act_labor_raw_cost,0)
                           else
                           NULL
                           end
                         ) ACT_PRJ_LABOR_RAW_COST,
                      sum( case when  fact.time_id <= l_end_period_id
                           then
                           decode(fact.plan_version_id, l_plan_ver_id, POU_MASK* fact.act_labor_raw_cost,0)
                           else
                           NULL
                           end
                         ) ACT_POU_LABOR_RAW_COST,
                      sum( case when  fact.time_id <= l_end_period_id
                           then
                           decode(fact.plan_version_id, l_plan_ver_id, TXN_MASK*fact.act_equip_raw_cost,0)
                           else
                           NULL
                           end
                         ) ACT_TXN_EQUIP_RAW_COST,
                      sum( case when  fact.time_id <= l_end_period_id
                           then
                           decode(fact.plan_version_id, l_plan_ver_id, PRJ_MASK* fact.act_equip_raw_cost,0)
                           else
                           NULL
                           end
                         ) ACT_PRJ_EQUIP_RAW_COST,
                      sum( case when  fact.time_id <= l_end_period_id
                           then
                           decode(fact.plan_version_id, l_plan_ver_id, POU_MASK* fact.act_equip_raw_cost,0)
                           else
                           NULL
                           end
                         ) ACT_POU_EQUIP_RAW_COST,

                      sum(case when fact.plan_version_id  = l_plan_ver_id then fact.ETC_labor_raw_cost*TXN_MASK else 0 end)  ETC_TXN_LABOR_RAW_COST,
                      sum(case when fact.plan_version_id  = l_plan_ver_id then fact.ETC_labor_raw_cost*PRJ_MASK else 0 end)  ETC_PRJ_LABOR_RAW_COST,
                      sum(case when fact.plan_version_id  = l_plan_ver_id then fact.ETC_labor_raw_cost*POU_MASK else 0 end)  ETC_POU_LABOR_RAW_COST,
                      sum(case when fact.plan_version_id  = l_plan_ver_id then fact.ETC_equip_raw_cost*TXN_MASK else 0 end)  ETC_TXN_EQUIP_RAW_COST,
                      sum(case when fact.plan_version_id  = l_plan_ver_id then fact.ETC_equip_raw_cost*PRJ_MASK else 0 end)  ETC_PRJ_EQUIP_RAW_COST,
                      sum(case when fact.plan_version_id  = l_plan_ver_id then fact.ETC_equip_raw_cost*POU_MASK else 0 end)  ETC_POU_EQUIP_RAW_COST,
                        /* Retrival of Project Level Data Starts*/
                      sum(case when fact.plan_version_id  = l_plan_ver_id      then fact.raw_cost*PRJ_MASK*ROLLUP_MASK else 0 end)  P_RAW_COST,
                      sum(case when fact.plan_version_id  = l_plan_ver_id      then fact.brdn_cost*PRJ_MASK*ROLLUP_MASK else 0 end) P_BRDN_COST,
                      sum(case when fact.plan_version_id  = l_plan_ver_id      then fact.revenue*PRJ_MASK*ROLLUP_MASK else 0 end)  P_REVENUE,
                      sum(case when fact.plan_version_id  = l_plan_ver_id      then fact.labor_raw_cost*PRJ_MASK*ROLLUP_MASK else 0 end)  P_LBR_RAW_COST,
                      sum(case when fact.plan_version_id  = l_plan_ver_id      then fact.labor_brdn_cost*PRJ_MASK*ROLLUP_MASK else 0 end) P_LBR_BRDN_COST,
                      sum(case when fact.plan_version_id  = l_plan_ver_id      then fact.equipment_raw_cost*PRJ_MASK*ROLLUP_MASK else 0 end) P_EQP_RAW_COST,
                      sum(case when fact.plan_version_id  = l_plan_ver_id      then fact.equipment_brdn_cost*PRJ_MASK*ROLLUP_MASK else 0 end)  P_EQP_BRDN_COST,
                      sum(case when fact.plan_version_id  = l_base_plan_ver_id then fact.raw_cost*PRJ_MASK*ROLLUP_MASK else 0 end)  P_BASE_RAW_COST,
                      sum(case when fact.plan_version_id  = l_base_plan_ver_id then fact.brdn_cost*PRJ_MASK*ROLLUP_MASK else 0 end)  P_BASE_BRDN_COST,
                      sum(case when fact.plan_version_id  = l_base_plan_ver_id then fact.labor_raw_cost*PRJ_MASK*ROLLUP_MASK else 0 end)  P_BASE_LBR_RAW_COST,
                      sum(case when fact.plan_version_id  = l_base_plan_ver_id then fact.labor_brdn_cost*PRJ_MASK*ROLLUP_MASK else 0 end)  P_BASE_LBR_BRDN_COST,
                      sum(case when fact.plan_version_id  = l_base_plan_ver_id then fact.equipment_raw_cost*PRJ_MASK*ROLLUP_MASK else 0 end) P_BASE_EQP_RAW_COST,
                      sum(case when fact.plan_version_id  = l_base_plan_ver_id then fact.equipment_brdn_cost*PRJ_MASK*ROLLUP_MASK else 0 end) P_BASE_EQP_BRDN_COST,
                      sum(case when fact.plan_version_id  = l_lpb_plan_ver_id  then fact.raw_cost*PRJ_MASK*ROLLUP_MASK else 0 end)  P_LPB_RAW_COST,
                      sum(case when fact.plan_version_id  = l_lpb_plan_ver_id  then fact.brdn_cost*PRJ_MASK*ROLLUP_MASK else 0 end)  P_LPB_BRDN_COST,
                      sum(case when fact.plan_version_id  = l_lpb_plan_ver_id  then fact.labor_raw_cost*PRJ_MASK*ROLLUP_MASK else 0 end)  P_LPB_LBR_RAW_COST,
                      sum(case when fact.plan_version_id  = l_lpb_plan_ver_id  then fact.labor_brdn_cost*PRJ_MASK*ROLLUP_MASK else 0 end)  P_LPB_LBR_BRDN_COST,
                      sum(case when fact.plan_version_id  = l_lpb_plan_ver_id  then fact.equipment_raw_cost*PRJ_MASK*ROLLUP_MASK else 0 end)  P_LPB_EQP_RAW_COST,
                      sum(case when fact.plan_version_id  = l_lpb_plan_ver_id  then fact.equipment_brdn_cost*PRJ_MASK*ROLLUP_MASK else 0 end)  P_LPB_EQP_BRDN_COST,
                      sum(case when fact.plan_version_id  = l_plan_ver_id      then fact.LABOR_HRS*ROLLUP_MASK else 0 end) P_LBR_HOURS,
                      sum(case when fact.plan_version_id  = l_plan_ver_id      then fact.EQUIPMENT_HOURS*ROLLUP_MASK else 0 end) P_EQP_HOURS,
                      sum(case when fact.plan_version_id  = l_base_plan_ver_id then fact.LABOR_HRS*ROLLUP_MASK else 0 end) P_BASE_LBR_HOURS,
                      sum(case when fact.plan_version_id  = l_base_plan_ver_id then fact.EQUIPMENT_HOURS*ROLLUP_MASK else 0 end) P_BASE_EQP_HOURS,
                      sum(case when fact.plan_version_id  = l_lpb_plan_ver_id  then fact.LABOR_HRS*ROLLUP_MASK else 0 end) P_LPB_LBR_HOURS,
                      sum(case when fact.plan_version_id  = l_lpb_plan_ver_id  then fact.EQUIPMENT_HOURS*ROLLUP_MASK else 0 end) P_LPB_EQP_HOURS,


                      sum( case when  fact.time_id <= l_end_period_id
                           then
                           decode(fact.plan_version_id, l_plan_ver_id, ROLLUP_MASK*fact.ACT_LABOR_HRS, 0)
                           else
                           NULL
                           end
                         ) P_ACT_LBR_HOURS,
                      sum( case when  fact.time_id <= l_end_period_id
                           then
                           decode(fact.plan_version_id, l_plan_ver_id, ROLLUP_MASK*fact.ACT_EQUIP_HRS, 0)
                           else
                           NULL
                           end
                         ) P_ACT_EQP_HOURS,
                      sum( case when  fact.time_id <= l_end_period_id
                           then
                           decode(fact.plan_version_id, l_plan_ver_id, PRJ_MASK*ROLLUP_MASK* fact.act_labor_brdn_cost, 0)
                           else
                           NULL
                           end
                         ) P_ACT_LBR_BRDN_COST,
                      sum( case when  fact.time_id <= l_end_period_id
                           then
                           decode(fact.plan_version_id, l_plan_ver_id, PRJ_MASK*ROLLUP_MASK*  fact.act_equip_brdn_cost, 0)
                           else
                           NULL
                           end
                         ) P_ACT_EQP_BRDN_COST,
                      sum( case when  fact.time_id <= l_end_period_id
                           then
                           decode(fact.plan_version_id, l_plan_ver_id, PRJ_MASK*ROLLUP_MASK*  fact.act_raw_cost, 0 )
                           else
                           NULL
                           end
                         ) P_ACT_RAW_COST,
                      sum( case when  fact.time_id <= l_end_period_id
                           then
                           decode(fact.plan_version_id, l_plan_ver_id, PRJ_MASK*ROLLUP_MASK*  fact.act_brdn_cost, 0 )
                           else
                           NULL
                           end
                         ) P_ACT_BRDN_COST,
                      sum( case when  fact.time_id <= l_end_period_id
                           then
                           decode(fact.plan_version_id, l_plan_ver_id, PRJ_MASK*ROLLUP_MASK* fact.act_labor_raw_cost,0)
                           else
                           NULL
                           end
                         ) P_ACT_LBR_RAW_COST,
                      sum( case when  fact.time_id <= l_end_period_id
                           then
                           decode(fact.plan_version_id, l_plan_ver_id, PRJ_MASK*ROLLUP_MASK* fact.act_equip_raw_cost,0)
                           else
                           NULL
                           end
                         ) P_ACT_EQP_RAW_COST,

                      sum(case when fact.plan_version_id  = l_plan_ver_id      then fact.ETC_EQUIP_HRS*ROLLUP_MASK else 0 end) P_ETC_EQP_HOURS,
                      sum(case when fact.plan_version_id  = l_plan_ver_id      then fact.ETC_LABOR_HRS*ROLLUP_MASK else 0 end) P_ETC_LBR_HOURS,
                      sum(case when fact.plan_version_id  = l_plan_ver_id  then fact.ETC_raw_cost*PRJ_MASK*ROLLUP_MASK else 0 end) P_ETC_RAW_COST,
                      sum(case when fact.plan_version_id  = l_plan_ver_id  then fact.ETC_brdn_cost*PRJ_MASK*ROLLUP_MASK else 0 end) P_ETC_BRDN_COST,
                      sum(case when fact.plan_version_id  = l_plan_ver_id  then fact.ETC_labor_brdn_cost*PRJ_MASK*ROLLUP_MASK else 0 end) P_ETC_LBR_BRDN_COST,
                      sum(case when fact.plan_version_id  = l_plan_ver_id  then fact.ETC_equip_brdn_cost*PRJ_MASK*ROLLUP_MASK else 0 end) P_ETC_EQP_BRDN_COST,
                      sum(case when fact.plan_version_id  = l_plan_ver_id  then fact.ETC_labor_raw_cost*PRJ_MASK*ROLLUP_MASK else 0 end) P_ETC_LBR_RAW_COST,
                      sum(case when fact.plan_version_id  = l_plan_ver_id  then fact.ETC_equip_raw_cost*PRJ_MASK*ROLLUP_MASK else 0 end) P_ETC_EQP_RAW_COST
                      /* Retrival of Project Level Data Ends*/
        FROM
        (
                        SELECT
                                 PROJECT_ID                ,
                                 PROJECT_ORG_ID            ,
                                 PROJECT_ORGANIZATION_ID   ,
                                 PROJECT_ELEMENT_ID        ,
                                 TIME_ID                   ,
                                 PERIOD_TYPE_ID            ,
                                 CALENDAR_TYPE             ,
                                 RBS_AGGR_LEVEL            ,
                                 WBS_ROLLUP_FLAG           ,
                                 PRG_ROLLUP_FLAG           ,
                                 decode ( cc_src.curr_type, 'TXN', 16, 'PRJ', 8, 'POU', 4) CURR_RECORD_TYPE_ID       ,
                                 CURRENCY_CODE             ,
                                 RBS_ELEMENT_ID            ,
                                 RBS_VERSION_ID            ,
                                 PLAN_VERSION_ID           ,
                                 -- PLAN_TYPE_ID              ,
                                 RAW_COST                  ,
                                 BRDN_COST                 ,
                                 REVENUE                   ,
                                 BILL_RAW_COST             ,
                                 BILL_BRDN_COST            ,
                                 BILL_LABOR_RAW_COST       ,
                                 BILL_LABOR_BRDN_COST      ,
                                 decode ( cc_src.curr_type, 'PRJ', BILL_LABOR_HRS, 0) BILL_LABOR_HRS      ,
                                 EQUIPMENT_RAW_COST        ,
                                 EQUIPMENT_BRDN_COST       ,
                                 CAPITALIZABLE_RAW_COST    ,
                                 CAPITALIZABLE_BRDN_COST   ,
                                 LABOR_RAW_COST            ,
                                 LABOR_BRDN_COST           ,
                                 decode ( cc_src.curr_type, 'PRJ', LABOR_HRS, 0) LABOR_HRS      ,
                                 LABOR_REVENUE             ,
                                 decode ( cc_src.curr_type, 'PRJ', EQUIPMENT_HOURS, 0) EQUIPMENT_HOURS      ,
                                 decode ( cc_src.curr_type, 'PRJ', BILLABLE_EQUIPMENT_HOURS, 0) BILLABLE_EQUIPMENT_HOURS      ,
                                 SUP_INV_COMMITTED_COST    ,
                                 PO_COMMITTED_COST         ,
                                 PR_COMMITTED_COST         ,
                                 OTH_COMMITTED_COST        ,
                                 CUSTOM1                   ,
                                 CUSTOM2                   ,
                                 CUSTOM3                   ,
                                 CUSTOM4                   ,
                                 CUSTOM5                   ,
                                 CUSTOM6                   ,
                                 CUSTOM7                   ,
                                 CUSTOM8                   ,
                                 CUSTOM9                   ,
                                 CUSTOM10                  ,
                                 CUSTOM11                  ,
                                 CUSTOM12                  ,
                                 CUSTOM13                  ,
                                 CUSTOM14                  ,
                                 CUSTOM15                  ,
                                 decode ( cc_src.curr_type, 'PRJ', ACT_LABOR_HRS, 0) ACT_LABOR_HRS      ,
                                 decode ( cc_src.curr_type, 'PRJ', ACT_EQUIP_HRS, 0) ACT_EQUIP_HRS      ,
                                 ACT_LABOR_BRDN_COST       ,
                                 ACT_EQUIP_BRDN_COST       ,
                                 ACT_BRDN_COST             ,
                                 decode ( cc_src.curr_type, 'PRJ', ETC_LABOR_HRS, 0) ETC_LABOR_HRS      ,
                                 decode ( cc_src.curr_type, 'PRJ', ETC_EQUIP_HRS, 0) ETC_EQUIP_HRS      ,
                                 ETC_LABOR_BRDN_COST       ,
                                 ETC_EQUIP_BRDN_COST       ,
                                 ETC_BRDN_COST             ,
                                 ACT_RAW_COST              ,
                                 ACT_REVENUE               ,
                                 ETC_RAW_COST              ,
                                 ACT_LABOR_RAW_COST        ,
                                 ACT_EQUIP_RAW_COST        ,
                                 ETC_LABOR_RAW_COST        ,
                                 ETC_EQUIP_RAW_COST        ,
                                decode(fact.prg_rollup_flag,'N',1,0)  ROLLUP_MASK,
                                decode ( cc_src.curr_type, 'TXN',1,0)  TXN_MASK,
                                decode ( cc_src.curr_type, 'PRJ',1,0)  PRJ_MASK,
                                decode ( cc_src.curr_type, 'POU',1,0)  POU_MASK
                        from
                                pji_fp_xbs_accum_f fact,
                                  (
                                            SELECT 'TXN' curr_type FROM DUAL
                                            UNION ALL
                                            SELECT 'PRJ' curr_type FROM DUAL
                                            UNION ALL
                                            SELECT 'POU' curr_type FROM DUAL
                                  ) cc_src
                        where 1=1
                         and ( decode ( cc_src.curr_type, 'TXN', DECODE(BITAND(fact.curr_record_type_id, 16), 16, 'a'), 'b') = 'a'
                            or decode ( cc_src.curr_type, 'PRJ', DECODE(BITAND(fact.curr_record_type_id,  8),  8, 'a'), 'b') = 'a'
                            or decode ( cc_src.curr_type, 'POU', DECODE(BITAND(fact.curr_record_type_id,  4),  4, 'a'), 'b') = 'a' )
                       ) fact,
                         pji_plan_extr_tmp head
                        WHERE    1=1
                                and fact.PROJECT_ID   = head.PROJECT_ID
                                and fact.PLAN_VERSION_ID in (l_plan_ver_id,l_lpb_plan_ver_id,l_base_plan_ver_id)
                                and fact.PROJECT_ELEMENT_ID = head.plan_ver_id -- plan_version_id contains the project_element_id
                                and fact.CALENDAR_TYPE = l_cal_type
                                and fact.PERIOD_TYPE_ID = l_prd_type_id
                                and BITAND(fact.CURR_RECORD_TYPE_ID,28) <= 28
                                and BITAND(fact.CURR_RECORD_TYPE_ID,28) >= 4
                                and fact.RBS_AGGR_LEVEL = 'T'
                                and fact.prg_rollup_flag ='N'
                                and fact.rbs_version_id = -1 /* Bug 6930211 */
                      GROUP BY
                              fact.PROJECT_ID,
                              fact.PROJECT_ELEMENT_ID,
                              fact.CALENDAR_TYPE;

        IF NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N') = 'Y' THEN
              debug_accum ; /* bug#3993830 */
        END IF;
        DELETE FROM PJI_PLAN_EXTR_TMP;    --- Bug 5653800
        x_return_status := l_return_status;

        EXCEPTION
                  WHEN OTHERS THEN

                    PJI_PJP_FP_CURR_WRAP.EXCP_HANDLER
                    ( p_package_name   => g_package_name
                    , p_procedure_name => 'POPULATE_UPDATEWBS_DATA'
                    , x_return_status =>  x_return_status ) ;

                    RAISE;
        END;



/*********************************************************
   This procedure populates  data in PJI_FM_XBS_ACCUM_TMP1
   for workplans.
   API supports both work plans and progress actuals
   The parameters that the API accepts can have one of the
   following combinations
   - p_struct_ver_id, p_base_struct_ver_id
   - p_plan_version_id
**********************************************************/
PROCEDURE populate_workplan_data (
    p_populate_in_tbl       IN   populate_in_tbl_type  := populate_in_default_tbl,
    p_project_id            IN   NUMBER   := NULL,
    p_struct_ver_id         IN   NUMBER   := NULL,
    p_base_struct_ver_id    IN   NUMBER   := NULL,
    p_plan_version_id       IN   NUMBER   := NULL,
    p_progress_actuals_flag IN   VARCHAR2 := 'N',
    p_as_of_date            IN   DATE     := NULL,
    p_delete_flag           IN   VARCHAR2 := 'Y',
    p_workplan_flag         IN   VARCHAR2 := 'Y',
    p_project_element_id    IN   NUMBER   := NULL,
    p_calling_context       IN   VARCHAR2 := NULL,
    p_program_rollup_flag   IN   VARCHAR2 := 'N',
    x_return_status         OUT NOCOPY   VARCHAR2,
    x_msg_code              OUT NOCOPY   VARCHAR2 ) IS

    l_project_id_tbl             system.pa_num_tbl_type := system.pa_num_tbl_type ();
    l_wk_struct_ver_id_tbl             system.pa_num_tbl_type := system.pa_num_tbl_type();
    l_lpb_struct_ver_id_tbl             system.pa_num_tbl_type := system.pa_num_tbl_type();
    l_base_struct_ver_id_tbl         system.pa_num_tbl_type := system.pa_num_tbl_type();
    l_cal_type_tbl				  SYSTEM.pa_varchar2_15_tbl_type := SYSTEM.pa_varchar2_15_tbl_type();
    l_period_id_tbl				 system.pa_num_tbl_type := system.pa_num_tbl_type();
    l_end_period_id_tbl		 system.pa_num_tbl_type := system.pa_num_tbl_type();

    l_org_id           NUMBER;
    l_return_status       VARCHAR2(1);

BEGIN

    PJI_PJP_FP_CURR_WRAP.INIT_ERR_STACK
    ( p_package_name   => g_package_name
    , x_return_status  => x_return_status );

    pa_debug.log_message('populate_workplan_data:p_project_id_tbl'||p_populate_in_tbl.COUNT, 3);

    pji_pjp_fp_curr_wrap.set_table_stats('PJI','PJI_PLAN_EXTR_TMP',10,10,10);

    l_return_status := Fnd_Api.G_RET_STS_SUCCESS;

   PRINT_TIME (  ' populate_workplan_data 0003.1 ' ) ;

   IF p_project_id is not null then

     INSERT INTO pji_plan_extr_tmp
	    ( PROJECT_ID , PLAN_VER_ID , STRUCT_VER_ID , BASE_STRUCT_VER_ID , AS_OF_DATE , PROJ_ELEM_ID )
	    VALUES ( p_project_id,p_plan_version_id,p_struct_ver_id  , p_base_struct_ver_id,p_as_of_date,p_project_element_id );

	    print_time (' p_project_id ' || p_project_id || ' p_struct_ver_id ' || p_struct_ver_id );
	    print_time (' p_base_struct_ver_id ' || p_base_struct_ver_id || ' p_plan_version_id ' || p_plan_version_id );
	    print_time (' p_progress_actuals_flag ' || p_progress_actuals_flag || ' p_as_of_date ' || p_as_of_date );
	    print_time (' p_delete_flag ' || p_delete_flag || ' p_workplan_flag ' || p_workplan_flag );

  ELSE
      IF p_populate_in_tbl.COUNT >0 THEN
	 FOR i IN p_populate_in_tbl.FIRST .. p_populate_in_tbl.LAST
	 LOOP
	    INSERT INTO pji_plan_extr_tmp
		    ( PROJECT_ID , PLAN_VER_ID , STRUCT_VER_ID , BASE_STRUCT_VER_ID , AS_OF_DATE , PROJ_ELEM_ID )
	    VALUES ( p_populate_in_tbl(i).PROJECT_ID,p_populate_in_tbl(i).plan_version_id, p_populate_in_tbl(i).struct_ver_id,p_populate_in_tbl(i).base_struct_ver_id,
	            p_populate_in_tbl(i).as_of_date,p_populate_in_tbl(i).project_element_id );

	       PRINT_TIME ( ' p_project_id ' || p_populate_in_tbl(i).PROJECT_ID || ' p_struct_ver_id ' || p_populate_in_tbl(i).struct_ver_id );
	       PRINT_TIME ( ' p_base_struct_ver_id ' || p_populate_in_tbl(i).base_struct_ver_id || ' p_plan_version_id ' || p_populate_in_tbl(i).plan_version_id );
	       PRINT_TIME ( ' p_project_element_id ' || p_populate_in_tbl(i).project_element_id || ' p_as_of_date ' || p_populate_in_tbl(i).as_of_date );
	       PRINT_TIME ( ' p_delete_flag '|| p_delete_flag || ' p_calling_context ' || p_calling_context || ' p_workplan_flag ' || p_workplan_flag ||' p_program_rollup_flag ' || p_program_rollup_flag );

	END LOOP;
      ELSE
        PRINT_TIME ( ' InValid parameters Passed to populate_workplan_data' );
      END IF;
  end if;

  IF g_debug_mode='Y' THEN
    PRINT_TIME (  ' populate_workplan_data 0003.2 ' ) ;
  end if;

        /* Added for workplan progress */
    -- Get the Latest Published Version for the Project

IF p_workplan_flag ='Y' THEN			--bug#5554311

                UPDATE pji_plan_extr_tmp TMP
		SET (LPB_STRUCT_VER_ID,LPB_PLAN_VER_ID)=
		(
			SELECT element_version_id,bv.budget_version_id
			FROM    pa_proj_elem_ver_structure ppevs,
				        pa_proj_structure_types ppst,
					pa_budget_versions bv
			WHERE   1=1
				and latest_eff_published_flag = 'Y'
				and ppst.proj_element_id = ppevs.proj_element_id
				and ppst.structure_type_id = 1
				and element_version_id=bv.project_structure_Version_id
				and bv.wp_version_flag ='Y'
				and bv.project_id=ppevs.project_id
				and tmp.project_id=ppevs.project_id
                );




    PRINT_TIME (  ' populate_workplan_data 0003.3 ' ) ;

            UPDATE pji_plan_extr_tmp TMP
            SET      WK_STRUCT_VER_ID=
                (
                        SELECT WBS_VERSION_ID
                        FROM   pji_pjp_wbs_header wbs
                        WHERE        wbs.project_id=tmp.project_id    AND
                        plan_version_id  = tmp.plan_ver_id
                );

    PRINT_TIME (  ' populate_workplan_data 0003.4 ' ) ;

            UPDATE     pji_plan_extr_tmp TMP
            SET     WK_PLAN_VER_ID= (
                        SELECT     head.PLAN_VERSION_ID
                        FROM     pji_pjp_wbs_header head,
                                 pa_budget_versions bv
                        WHERE 1=1
                                AND head.plan_version_id = bv.budget_version_id
                                AND NVL(bv.wp_version_flag, 'N') = head.wp_flag
                                AND NVL(bv.wp_version_flag, 'N') = p_workplan_flag
                                AND head.WBS_VERSION_ID = tmp.struct_ver_id
                                AND head.PROJECT_ID     = tmp.project_id
                                AND DECODE(p_workplan_flag
                                , 'N'
                                , DECODE(bv.budget_status_code||bv.current_working_flag
                                , 'WY'
                                ,'X'
                                , 'Y')
                                , 'X') = 'X'
                                AND head.PLAN_VERSION_ID > 0);

    PRINT_TIME (  ' populate_workplan_data 0003.4.1 ' ) ;

	             UPDATE pji_plan_extr_tmp TMP
		     SET      WK_STRUCT_VER_ID = STRUCT_VER_ID
		     where WK_STRUCT_VER_ID is null;

    PRINT_TIME (  ' populate_workplan_data 0003.5 ' ) ;

                      UPDATE pji_plan_extr_tmp TMP
            SET BASE_PLAN_VER_ID= (
			SELECT  head.PLAN_VERSION_ID
                        FROM    pji_pjp_wbs_header head,
                                pa_budget_versions bv
                        WHERE   1=1
                                AND head.plan_version_id = bv.budget_version_id
                                AND NVL(bv.wp_version_flag, 'N') = head.wp_flag
                                AND NVL(bv.wp_version_flag , 'N') = p_workplan_flag
                                AND head.WBS_VERSION_ID = TMP.BASE_STRUCT_VER_ID
                                AND head.PROJECT_ID     = tmp.PROJECT_ID
                                AND DECODE(p_workplan_flag
                                , 'N'
                                , DECODE(bv.budget_status_code||bv.current_flag
                                , 'BY','X'
                                , 'Y')
                                , 'X')
                                = 'X'
                                AND head.PLAN_VERSION_ID > 0);

ELSE		---   when  p_workplan_flag ='N'		bug#5554311

    PRINT_TIME (  ' populate_workplan_data 0003.5.1 ' ) ;

                UPDATE pji_plan_extr_tmp TMP
		SET		(LPB_STRUCT_VER_ID,LPB_PLAN_VER_ID,BASE_STRUCT_VER_ID,BASE_PLAN_VER_ID,
				WK_STRUCT_VER_ID,WK_PLAN_VER_ID)=
		(SELECT p_struct_ver_id,p_plan_version_id,p_struct_ver_id,p_plan_version_id,p_struct_ver_id,p_plan_version_id from dual );

END IF;

    PRINT_TIME (  ' populate_workplan_data 0003.6 ' ) ;



                UPDATE pji_plan_extr_tmp TMP
            SET (CAL_TYPE,ORG_ID)=
            (
             SELECT  DECODE(NVL(NVL(fp.cost_time_phased_code, fp.revenue_time_phased_code ), fp.all_time_phased_code), 'G', 'G', 'P', 'P', 'A') calendar_type,
                     pa.ORG_ID
             FROM
                     pa_proj_fp_options fp,
                     pa_projects_all pa
             WHERE   1=1
                     and pa.project_id=fp.project_id
                     and pa.project_id=tmp.project_id
                     and fp.fin_plan_option_level_code = 'PLAN_VERSION'
                     and fp.fin_plan_version_id =tmp.WK_PLAN_VER_ID
                )
		WHERE  tmp.AS_OF_DATE is not null;

    PRINT_TIME (  ' populate_workplan_data 0003.7.1 ' ) ;

            UPDATE pji_plan_extr_tmp TMP
            SET (END_PERIOD_ID,PERIOD_ID)=
            (
            SELECT cal.CAL_PERIOD_ID  ,DECODE(tmp.cal_type, 'A', 2048, 32) PERIOD_TYPE_ID
                        FROM   pji_time_cal_period_v cal,
                   pji_org_extr_info    info
                        WHERE TRUNC(tmp.AS_OF_DATE)
                              BETWEEN TRUNC(cal.START_DATE) AND TRUNC(cal.END_DATE)
                              AND info.ORG_ID  = tmp.ORG_ID
                              AND DECODE(tmp.cal_type, 'P', info.PA_CALENDAR_ID , info.GL_CALENDAR_ID) = cal.CALENDAR_ID
                    )
		    WHERE  tmp.AS_OF_DATE is not null;

    PRINT_TIME (  ' populate_workplan_data 0003.8 ' ) ;

 -- The Temp table is populated with the Program and the Linked Projects and their corresponding plan versions


       SELECT
       project_id,WK_STRUCT_VER_ID,LPB_STRUCT_VER_ID,BASE_STRUCT_VER_ID,
       CAL_TYPE,PERIOD_ID,END_PERIOD_ID
       BULK COLLECT INTO
	       l_project_id_tbl,l_wk_struct_ver_id_tbl,l_lpb_struct_ver_id_tbl,l_base_struct_ver_id_tbl,
	       l_cal_type_tbl,l_period_id_tbl,    l_end_period_id_tbl
       FROM PJI_PLAN_EXTR_TMP;

    PRINT_TIME (  ' populate_workplan_data 0003.9 ' ) ;

IF p_program_rollup_flag='Y' and p_calling_context='SUMMARIZE'  and  p_workplan_flag ='Y'  THEN
                /* Populates Data for the given Project and all the projects above and a level below */
    PRINT_TIME (  ' populate_workplan_data 0003.9.1 ' ) ;

    FOR i IN 1 .. l_project_id_tbl.count
    LOOP
        INSERT into PJI_PLAN_EXTR_TMP
        (project_id,wk_plan_ver_id,lpb_plan_ver_id,base_plan_ver_id,struct_ver_id,cal_type,period_id,end_period_id)	--Bug#5660324
           SELECT
                        head.PROJECT_ID,
                        MAX(DECODE(SUBSTR(den.RECORD_TYPE,1,1), 'W', head.plan_version_id, NULL)) wk_plan_ver_id,
                        MAX(DECODE(SUBSTR( den.RECORD_TYPE,1,1), 'P', head.plan_version_id, NULL)) lpb_plan_ver_id ,
                        MAX(DECODE(SUBSTR(den.RECORD_TYPE,1,1), 'B', head.plan_version_id, NULL)) base_plan_ver_id,
                        MAX(DECODE(SUBSTR( den.RECORD_TYPE,1,1), 'W', den.wbs_version_id, NULL)) struct_ver_id,
			MAX(l_cal_type_tbl(i)),
			MAX(l_period_id_tbl(i)),
			MAX(l_end_period_id_tbl(i))
                FROM (
                        SELECT
                                DECODE(SUBSTR(record_type,2,1),'R',sub_id,'S',sup_id) wbs_version_id,record_type,
                                DECODE(NVL(sub_rollup_id,sup_emt_id),sup_emt_id,0,1) relationship
                        FROM
                                (
                   SELECT
                             sub_id,sup_id,sub_rollup_id,sup_emt_id,'WR'      record_type
                   FROM
                             pji_xbs_Denorm wrk
                   WHERE
                             wrk.STRUCT_TYPE              = 'PRG' AND
                             wrk.SUP_ID                    =  l_wk_struct_ver_id_tbl(i) AND
                             ( wrk.RELATIONSHIP_TYPE <>'LF' OR  wrk.RELATIONSHIP_TYPE IS NULL) AND
                             wrk.struct_version_id is null
                   UNION ALL
                   SELECT
                                sub_id,sup_id,sub_rollup_id,sup_emt_id,'PR'      record_type
                   FROM
                                pji_xbs_Denorm pub
                   WHERE
                             pub.STRUCT_TYPE              = 'PRG' AND
                             pub.SUP_ID                   =  l_lpb_struct_ver_id_tbl(i)   AND
                             ( pub.RELATIONSHIP_TYPE <>'LF' OR  pub.RELATIONSHIP_TYPE IS NULL) AND
                             pub.struct_version_id is null
                   UNION ALL
                   SELECT
                                sub_id,sup_id,sub_rollup_id,sup_emt_id,'BR'     record_type
                   FROM
                             pji_xbs_Denorm base
                   WHERE
                             base.STRUCT_TYPE             = 'PRG' AND
                             base.SUP_ID                   =  l_base_struct_ver_id_tbl(i) AND
                             ( base.RELATIONSHIP_TYPE <>'LF' OR  base.RELATIONSHIP_TYPE IS NULL) AND
                             base.struct_version_id is null
                   UNION ALL
                   SELECT  sub_id,sup_id,sub_rollup_id,sup_emt_id,'WS'   record_type
                   FROM
                           pji_xbs_Denorm wrk
                   WHERE
                           wrk.STRUCT_TYPE              = 'PRG' AND
                           wrk.SUB_ID                   =  l_wk_struct_ver_id_tbl(i) AND
                           ( wrk.RELATIONSHIP_TYPE <>'LF' OR  wrk.RELATIONSHIP_TYPE IS NULL) AND
                           wrk.struct_version_id is null
                   UNION ALL
                   SELECT  sub_id,sup_id,sub_rollup_id,sup_emt_id,'PS'   record_type
                   FROM
                           pji_xbs_Denorm pub
                   WHERE
                           pub.STRUCT_TYPE              = 'PRG' AND
                           pub.SUB_ID                   =  l_lpb_struct_ver_id_tbl(i)   AND
                           ( pub.RELATIONSHIP_TYPE <>'LF' OR  pub.RELATIONSHIP_TYPE IS NULL) AND
                           pub.struct_version_id is null
                   UNION ALL
                   SELECT  sub_id,sup_id,sub_rollup_id,sup_emt_id,'BS'  record_type
                   FROM
                           pji_xbs_Denorm base
                   WHERE
                           base.STRUCT_TYPE             = 'PRG' AND
                           base.SUB_ID                  =  l_base_struct_ver_id_tbl(i) AND
                           ( base.RELATIONSHIP_TYPE <>'LF' OR  base.RELATIONSHIP_TYPE IS NULL) AND
                           base.struct_version_id is null
                                )
                        )
                        den,
                        pa_proj_element_versions ver,
                        pji_pjp_wbs_header head
                WHERE
                        den.WBS_VERSION_ID = ver.element_version_id AND
                        den.record_type is not null                                AND
                        DECODE(SUBSTR(den.RECORD_TYPE,2,1),'S',1,'R',den.RELATIONSHIP) =1 AND
                        ver.project_id      = head.project_id        AND
                        den.WBS_VERSION_ID = head.wbs_version_id    AND
                        head.WP_FLAG       = 'Y'
                GROUP BY head.project_id;
END LOOP;



ELSIF p_program_rollup_flag='Y' and p_calling_context='ROLLUP'  and  p_workplan_flag ='Y'   THEN
/* Populates Data for the Project and all the projects below the given project */

    PRINT_TIME (  ' populate_workplan_data 0003.9.2 ' ) ;

    FOR i IN 1 .. l_project_id_tbl.count
    LOOP

        INSERT into PJI_PLAN_EXTR_TMP
        (project_id,wk_plan_ver_id,lpb_plan_ver_id,base_plan_ver_id,struct_ver_id,cal_type,period_id,end_period_id) --Bug#5660324
         SELECT
                  head.PROJECT_ID,
                  MAX(DECODE(den.RECORD_TYPE, 'W', head.plan_version_id, NULL)) wk_plan_ver_id,
                  MAX(DECODE(den.RECORD_TYPE, 'P', head.plan_version_id, NULL)) lpb_plan_ver_id ,
                  MAX(DECODE(den.RECORD_TYPE, 'B', head.plan_version_id, NULL)) base_plan_ver_id,
                  MAX(DECODE(den.RECORD_TYPE, 'W', den.wbs_version_id, NULL)) struct_ver_id,
                  MAX(l_cal_type_tbl(i)),
		  MAX(l_period_id_tbl(i)),
		  MAX(l_end_period_id_tbl(i))
        FROM
                (
                   SELECT
                             wrk.SUB_ID wbs_version_id,'W'      record_type
                   FROM
                             pji_xbs_Denorm wrk
                   WHERE
                             wrk.STRUCT_TYPE              = 'PRG' AND
                             wrk.SUP_ID                   =  l_wk_struct_ver_id_tbl(i) AND
                             ( wrk.RELATIONSHIP_TYPE <>'LF' OR  wrk.RELATIONSHIP_TYPE IS NULL) AND
                             wrk.struct_version_id is null
                   UNION ALL
                   SELECT
                     pub.SUB_ID wbs_version_id,'P'      record_type
                   FROM
                                pji_xbs_Denorm pub
                   WHERE
                             pub.STRUCT_TYPE              = 'PRG' AND
                             pub.SUP_ID                   =  l_lpb_struct_ver_id_tbl(i)   AND
                             ( pub.RELATIONSHIP_TYPE <>'LF' OR  pub.RELATIONSHIP_TYPE IS NULL) AND
                             pub.struct_version_id is null
                   UNION ALL
                   SELECT
                     base.SUB_ID wbs_version_id,'B'     record_type
                   FROM
                             pji_xbs_Denorm base
                   WHERE
                             base.STRUCT_TYPE              = 'PRG' AND
                             base.SUP_ID                  =  l_base_struct_ver_id_tbl(i) AND
                             ( base.RELATIONSHIP_TYPE <>'LF' OR  base.RELATIONSHIP_TYPE IS NULL) AND
                             base.struct_version_id is null
                  )
                  den,
                  pa_proj_element_versions ver,
                  pji_pjp_wbs_header head
        WHERE
                  den.wbs_version_id = ver.element_version_id AND
                  ver.project_id     = head.project_id        AND
                  den.wbs_version_id = head.wbs_version_id    AND
                  head.WP_FLAG       = 'Y'
        GROUP BY        head.project_id;

END LOOP;

END IF;

/* Start of changes for bug 5751250 */

IF p_calling_context = 'MSP' THEN

  UPDATE pji_plan_extr_tmp
  SET WK_PLAN_VER_ID = -1, BASE_PLAN_VER_ID = -1, LPB_PLAN_VER_ID = -1;

END IF;

/* End of changes for bug 5751250 */

  --Ensures that data is cleaned up for the Project / Program and the linked sub projects
   IF (p_delete_flag = 'Y') THEN

    PRINT_TIME (  ' populate_workplan_data 0003.10 ' ) ;

                DELETE FROM pji_fm_xbs_accum_tmp1
                WHERE rowid IN
                (
                        SELECT tmp.rowid
                        FROM pji_plan_extr_tmp head, pji_fm_xbs_accum_tmp1 tmp
                        WHERE head.project_id=tmp.project_id
                );

   END IF;

    PRINT_TIME (  ' populate_workplan_data 0003.10.1 ' ) ;

		DELETE FROM  PJI_PLAN_EXTR_TMP tmp1
			WHERE EXISTS
			( SELECT * FROM PJI_PLAN_EXTR_TMP tmp2
				 WHERE tmp1.PROJECT_ID=tmp2.PROJECT_ID
				AND tmp1.ROWID > tmp2.ROWID );

   IF g_debug_mode='Y' THEN
    PRINT_TIME (  ' populate_workplan_data 0003.11 ' ) ;
   END IF;



    --
    -- Get task level data from reporting lines
    -- Data is rolled up by WBS hierarchy
    -- Data inserted is the Totals
    --

INSERT INTO pji_fm_xbs_accum_tmp1 (
        PROJECT_ID,  STRUCT_VERSION_ID,       PROJECT_ELEMENT_ID,      CALENDAR_TYPE,
        PERIOD_NAME,      PLAN_VERSION_ID,        QUANTITY,         TXN_RAW_COST,
        TXN_BRDN_COST,        TXN_REVENUE,         TXN_LABOR_RAW_COST,      TXN_LABOR_BRDN_COST,
        TXN_EQUIP_RAW_COST,      TXN_EQUIP_BRDN_COST,     TXN_BASE_RAW_COST,       TXN_BASE_BRDN_COST,
        TXN_BASE_LABOR_RAW_COST, TXN_BASE_LABOR_BRDN_COST,TXN_BASE_EQUIP_RAW_COST, TXN_BASE_EQUIP_BRDN_COST,
        TXN_LPB_RAW_COST,        TXN_LPB_BRDN_COST,       TXN_LPB_LABOR_RAW_COST,  TXN_LPB_LABOR_BRDN_COST,
        TXN_LPB_EQUIP_RAW_COST,  TXN_LPB_EQUIP_BRDN_COST, PRJ_RAW_COST,          PRJ_BRDN_COST,
        PRJ_REVENUE,        PRJ_LABOR_RAW_COST,      PRJ_LABOR_BRDN_COST,     PRJ_EQUIP_RAW_COST,
        PRJ_EQUIP_BRDN_COST,  PRJ_BASE_RAW_COST,       PRJ_BASE_BRDN_COST,      PRJ_BASE_LABOR_RAW_COST,
        PRJ_BASE_LABOR_BRDN_COST,PRJ_BASE_EQUIP_RAW_COST, PRJ_BASE_EQUIP_BRDN_COST,PRJ_LPB_RAW_COST,
        PRJ_LPB_BRDN_COST,       PRJ_LPB_LABOR_RAW_COST,  PRJ_LPB_LABOR_BRDN_COST, PRJ_LPB_EQUIP_RAW_COST,
        PRJ_LPB_EQUIP_BRDN_COST, POU_RAW_COST,          POU_BRDN_COST,           POU_REVENUE,
        POU_LABOR_RAW_COST,      POU_LABOR_BRDN_COST,     POU_EQUIP_RAW_COST,      POU_EQUIP_BRDN_COST,
        POU_BASE_RAW_COST,       POU_BASE_BRDN_COST,      POU_BASE_LABOR_RAW_COST, POU_BASE_LABOR_BRDN_COST,
        POU_BASE_EQUIP_RAW_COST, POU_BASE_EQUIP_BRDN_COST,POU_LPB_RAW_COST,        POU_LPB_BRDN_COST,
        POU_LPB_LABOR_RAW_COST,  POU_LPB_LABOR_BRDN_COST, POU_LPB_EQUIP_RAW_COST,  POU_LPB_EQUIP_BRDN_COST,
        LABOR_HOURS,          EQUIPMENT_HOURS,         BASE_LABOR_HOURS,        BASE_EQUIP_HOURS,
        LPB_LABOR_HOURS,         LPB_EQUIP_HOURS,   ACT_LABOR_HRS,     ACT_EQUIP_HRS,
        ACT_TXN_LABOR_BRDN_COST, ACT_TXN_EQUIP_BRDN_COST, ACT_TXN_RAW_COST,     ACT_TXN_BRDN_COST,
        ACT_PRJ_LABOR_BRDN_COST, ACT_PRJ_EQUIP_BRDN_COST, ACT_PRJ_RAW_COST,     ACT_PRJ_BRDN_COST,
        ACT_POU_LABOR_BRDN_COST, ACT_POU_EQUIP_BRDN_COST, ACT_POU_RAW_COST,     ACT_POU_BRDN_COST,
        ETC_LABOR_HRS,           ETC_EQUIP_HRS,    ETC_TXN_LABOR_BRDN_COST, ETC_TXN_EQUIP_BRDN_COST,
        ETC_TXN_RAW_COST,   ETC_TXN_BRDN_COST,    ETC_PRJ_LABOR_BRDN_COST, ETC_PRJ_EQUIP_BRDN_COST,
        ETC_PRJ_RAW_COST,        ETC_PRJ_BRDN_COST,    ETC_POU_LABOR_BRDN_COST, ETC_POU_EQUIP_BRDN_COST,
        ETC_POU_RAW_COST,        ETC_POU_BRDN_COST,     ACT_TXN_LABOR_RAW_COST , ACT_PRJ_LABOR_RAW_COST,
        ACT_POU_LABOR_RAW_COST,  ACT_TXN_EQUIP_RAW_COST,  ACT_PRJ_EQUIP_RAW_COST,  ACT_POU_EQUIP_RAW_COST,
        ETC_TXN_LABOR_RAW_COST,  ETC_PRJ_LABOR_RAW_COST,  ETC_POU_LABOR_RAW_COST,  ETC_TXN_EQUIP_RAW_COST,
        ETC_PRJ_EQUIP_RAW_COST,  ETC_POU_EQUIP_RAW_COST,  P_RAW_COST,P_BRDN_COST,  P_REVENUE,
        P_LBR_RAW_COST,  P_LBR_BRDN_COST,   P_EQP_RAW_COST,    P_EQP_BRDN_COST,
        P_BASE_RAW_COST,  P_BASE_BRDN_COST,   P_BASE_LBR_RAW_COST,    P_BASE_LBR_BRDN_COST,
        P_BASE_EQP_RAW_COST,  P_BASE_EQP_BRDN_COST,   P_LPB_RAW_COST,    P_LPB_BRDN_COST,
        P_LPB_LBR_RAW_COST,  P_LPB_LBR_BRDN_COST,   P_LPB_EQP_RAW_COST,    P_LPB_EQP_BRDN_COST,
        P_LBR_HOURS,  P_EQP_HOURS,   P_BASE_LBR_HOURS,    P_BASE_EQP_HOURS,
        P_LPB_LBR_HOURS,  P_LPB_EQP_HOURS,   P_ACT_LBR_HOURS,    P_ACT_EQP_HOURS,
        P_ACT_LBR_BRDN_COST,  P_ACT_EQP_BRDN_COST,   P_ACT_RAW_COST,     P_ACT_BRDN_COST,
        P_ACT_LBR_RAW_COST,  P_ACT_EQP_RAW_COST,   P_ETC_EQP_HOURS,         P_ETC_LBR_HOURS,
        P_ETC_RAW_COST,  P_ETC_BRDN_COST,   P_ETC_LBR_BRDN_COST,     P_ETC_EQP_BRDN_COST,
        P_ETC_LBR_RAW_COST,P_ETC_EQP_RAW_COST
)
        SELECT          /*+ LEADING(head) USE_NL(fact.fact) */
                      fact.PROJECT_ID,
                      struct_ver_id  STRUCT_VERSION_ID,
                      fact.PROJECT_ELEMENT_ID   PROJECT_ELEMENT_ID,
                      'A',
                      null  PERIOD_NAME,
                      WK_PLAN_VER_ID  PLAN_VERSION_ID,
                      0  QUANTITY,
                      sum(case when fact.plan_version_id  = WK_PLAN_VER_ID then fact.raw_cost*TXN_MASK else 0 end)   TXN_RAW_COST,
                      sum(case when fact.plan_version_id  = WK_PLAN_VER_ID then fact.brdn_cost*TXN_MASK else 0 end)   TXN_BRDN_COST,
                      sum(case when fact.plan_version_id  = WK_PLAN_VER_ID then fact.revenue*TXN_MASK else 0 end)   TXN_REVENUE,
                      sum(case when fact.plan_version_id  = WK_PLAN_VER_ID then fact.labor_raw_cost*TXN_MASK else 0 end)  TXN_LABOR_RAW_COST,
                      sum(case when fact.plan_version_id  = WK_PLAN_VER_ID then fact.labor_brdn_cost*TXN_MASK else 0 end)   TXN_LABOR_BRDN_COST,
                      sum(case when fact.plan_version_id  = WK_PLAN_VER_ID then fact.equipment_raw_cost*TXN_MASK else 0 end)   TXN_EQUIP_RAW_COST,
                      sum(case when fact.plan_version_id  = WK_PLAN_VER_ID then fact.equipment_brdn_cost*TXN_MASK else 0 end)   TXN_EQUIP_BRDN_COST,
                      sum(case when fact.plan_version_id  = base_plan_ver_id then fact.raw_cost*TXN_MASK else 0 end)    TXN_BASE_RAW_COST,
                      sum(case when fact.plan_version_id   = base_plan_ver_id then fact.brdn_cost*TXN_MASK else 0 end)   TXN_BASE_BRDN_COST,
                      sum(case when fact.plan_version_id  = base_plan_ver_id then fact.labor_raw_cost*TXN_MASK else 0 end)   TXN_BASE_LABOR_RAW_COST,
                      sum(case when fact.plan_version_id  = base_plan_ver_id then fact.labor_brdn_cost*TXN_MASK else 0 end)    TXN_BASE_LABOR_BRDN_COST,
                      sum(case when fact.plan_version_id  = base_plan_ver_id then fact.equipment_raw_cost*TXN_MASK else 0 end)  TXN_BASE_EQUIP_RAW_COST,
                      sum(case when fact.plan_version_id  = base_plan_ver_id then fact.equipment_brdn_cost*TXN_MASK else 0 end)  TXN_BASE_EQUIP_BRDN_COST,
                      sum(case when fact.plan_version_id  = lpb_plan_ver_id then fact.raw_cost*TXN_MASK else 0 end)   TXN_LPB_RAW_COST,
                      sum(case when fact.plan_version_id  = lpb_plan_ver_id then fact.brdn_cost*TXN_MASK else 0 end)   TXN_LPB_BRDN_COST,
                      sum(case when fact.plan_version_id  = lpb_plan_ver_id then fact.labor_raw_cost*TXN_MASK else 0 end)   TXN_LPB_LABOR_RAW_COST,
                      sum(case when fact.plan_version_id  = lpb_plan_ver_id then fact.labor_brdn_cost*TXN_MASK else 0 end)   TXN_LPB_LABOR_BRDN_COST,
                      sum(case when fact.plan_version_id  = lpb_plan_ver_id then fact.equipment_raw_cost*TXN_MASK else 0 end) TXN_LPB_EQUIP_RAW_COST,
                      sum(case when fact.plan_version_id  = lpb_plan_ver_id then fact.equipment_brdn_cost*TXN_MASK else 0 end)  TXN_LPB_EQUIP_BRDN_COST,
                      sum(case when fact.plan_version_id  = WK_PLAN_VER_ID then fact.raw_cost*PRJ_MASK else 0 end)   PRJ_RAW_COST,
                      sum(case when fact.plan_version_id  = WK_PLAN_VER_ID then fact.brdn_cost*PRJ_MASK else 0 end)  PRJ_BRDN_COST,
                      sum(case when fact.plan_version_id  = WK_PLAN_VER_ID then fact.revenue*PRJ_MASK else 0 end)  PRJ_REVENUE,
                      sum(case when fact.plan_version_id  = WK_PLAN_VER_ID then fact.labor_raw_cost*PRJ_MASK else 0 end)   PRJ_LABOR_RAW_COST,
                      sum(case when fact.plan_version_id  = WK_PLAN_VER_ID then fact.labor_brdn_cost*PRJ_MASK else 0 end)   PRJ_LABOR_BRDN_COST,
                      sum(case when fact.plan_version_id  = WK_PLAN_VER_ID then fact.equipment_raw_cost*PRJ_MASK else 0 end)   PRJ_EQUIP_RAW_COST,
                      sum(case when fact.plan_version_id  = WK_PLAN_VER_ID then fact.equipment_brdn_cost*PRJ_MASK else 0 end)   PRJ_EQUIP_BRDN_COST,
                      sum(case when fact.plan_version_id  = base_plan_ver_id then fact.raw_cost*PRJ_MASK else 0 end)   PRJ_BASE_RAW_COST,
                      sum(case when fact.plan_version_id   = base_plan_ver_id then fact.brdn_cost*PRJ_MASK else 0 end)   PRJ_BASE_BRDN_COST,
                      sum(case when fact.plan_version_id  = base_plan_ver_id then fact.labor_raw_cost*PRJ_MASK else 0 end)   PRJ_BASE_LABOR_RAW_COST,
                      sum(case when fact.plan_version_id  = base_plan_ver_id then fact.labor_brdn_cost*PRJ_MASK else 0 end)   PRJ_BASE_LABOR_BRDN_COST,
                      sum(case when fact.plan_version_id  = base_plan_ver_id then fact.equipment_raw_cost*PRJ_MASK else 0 end) PRJ_BASE_EQUIP_RAW_COST,
                      sum(case when fact.plan_version_id  = base_plan_ver_id then fact.equipment_brdn_cost*PRJ_MASK else 0 end) PRJ_BASE_EQUIP_BRDN_COST,

                      sum(case when fact.plan_version_id  = lpb_plan_ver_id then fact.raw_cost*PRJ_MASK else 0 end)   PRJ_LPB_RAW_COST,
                      sum(case when fact.plan_version_id  = lpb_plan_ver_id then fact.brdn_cost*PRJ_MASK else 0 end)   PRJ_LPB_BRDN_COST,
                      sum(case when fact.plan_version_id  = lpb_plan_ver_id then fact.labor_raw_cost*PRJ_MASK else 0 end)   PRJ_LPB_LABOR_RAW_COST,
                      sum(case when fact.plan_version_id  = lpb_plan_ver_id then fact.labor_brdn_cost*PRJ_MASK else 0 end)  PRJ_LPB_LABOR_BRDN_COST,
                      sum(case when fact.plan_version_id  = lpb_plan_ver_id then fact.equipment_raw_cost*PRJ_MASK else 0 end) PRJ_LBP_EQUIP_RAW_COST,
                      sum(case when fact.plan_version_id  = lpb_plan_ver_id then fact.equipment_brdn_cost*PRJ_MASK else 0 end) PRJ_LBP_EQUIP_BRDN_COST,

                      sum(case when fact.plan_version_id  = WK_PLAN_VER_ID then fact.raw_cost*POU_MASK else 0 end)  POU_RAW_COST,
                      sum(case when fact.plan_version_id  = WK_PLAN_VER_ID then fact.brdn_cost*POU_MASK else 0 end)  POU_BRDN_COST,
                      sum(case when fact.plan_version_id  = WK_PLAN_VER_ID then fact.revenue*POU_MASK else 0 end)  POU_REVENUE,
                      sum(case when fact.plan_version_id  = WK_PLAN_VER_ID then fact.labor_raw_cost*POU_MASK else 0 end)  POU_LABOR_RAW_COST,
                      sum(case when fact.plan_version_id  = WK_PLAN_VER_ID then fact.labor_brdn_cost*POU_MASK else 0 end)   POU_LABOR_BRDN_COST,
                      sum(case when fact.plan_version_id  = WK_PLAN_VER_ID then fact.equipment_raw_cost*POU_MASK else 0 end)   POU_EQUIP_RAW_COST,
                      sum(case when fact.plan_version_id  = WK_PLAN_VER_ID then fact.equipment_brdn_cost*POU_MASK else 0 end)   POU_EQUIP_BRDN_COST,

                      sum(case when fact.plan_version_id  = base_plan_ver_id then fact.raw_cost*POU_MASK else 0 end)   POU_BASE_RAW_COST,
                      sum(case when fact.plan_version_id   = base_plan_ver_id then fact.brdn_cost*POU_MASK else 0 end)   POU_BASE_BRDN_COST,
                      sum(case when fact.plan_version_id  = base_plan_ver_id then fact.labor_raw_cost*POU_MASK else 0 end)   POU_BASE_LABOR_RAW_COST,
                      sum(case when fact.plan_version_id  = base_plan_ver_id then fact.labor_brdn_cost*POU_MASK else 0 end)   POU_BASE_LABOR_BRDN_COST,
                      sum(case when fact.plan_version_id  = base_plan_ver_id then fact.equipment_raw_cost*POU_MASK else 0 end) POU_BASE_EQUIP_RAW_COST,
                      sum(case when fact.plan_version_id  = base_plan_ver_id then fact.equipment_brdn_cost*POU_MASK else 0 end) POU_BASE_EQUIP_BRDN_COST,

                      sum(case when fact.plan_version_id  = lpb_plan_ver_id then fact.raw_cost*POU_MASK else 0 end)   POU_LPB_RAW_COST,
                      sum(case when fact.plan_version_id  = lpb_plan_ver_id then fact.brdn_cost*POU_MASK else 0 end)   POU_LPB_BRDN_COST,
                      sum(case when fact.plan_version_id  = lpb_plan_ver_id then fact.labor_raw_cost*POU_MASK else 0 end)  POU_LPB_LABOR_RAW_COST,
                      sum(case when fact.plan_version_id  = lpb_plan_ver_id then fact.labor_brdn_cost*POU_MASK else 0 end)   POU_LPB_LABOR_BRDN_COST,
                      sum(case when fact.plan_version_id  = lpb_plan_ver_id then fact.equipment_raw_cost*POU_MASK else 0 end) POU_LPB_EQUIP_RAW_COST,
                      sum(case when fact.plan_version_id  = lpb_plan_ver_id then fact.equipment_brdn_cost*POU_MASK else 0 end) POU_LPB_EQUIP_BRDN_COST,

                      sum(case when fact.plan_version_id  = WK_PLAN_VER_ID then fact.LABOR_HRS else 0 end)   LABOR_HOURS,
                      sum(case when fact.plan_version_id  = WK_PLAN_VER_ID then fact.EQUIPMENT_HOURS else 0 end)   EQUIPMENT_HOURS,
                      sum(case when fact.plan_version_id  = base_plan_ver_id then fact.LABOR_HRS else 0 end)   BASE_LABOR_HOURS,
                      sum(case when fact.plan_version_id  = base_plan_ver_id  then fact.EQUIPMENT_HOURS else 0 end)  BASE_EQUIP_HOURS,
                      sum(case when fact.plan_version_id  = lpb_plan_ver_id then fact.LABOR_HRS else 0 end)   LPB_LABOR_HOURS,
                      sum(case when fact.plan_version_id   = lpb_plan_ver_id  then fact.EQUIPMENT_HOURS else 0 end)   LPB_EQUIP_HOURS,

                      sum( case when  fact.time_id <= END_PERIOD_ID
                           then
                           decode( fact.plan_version_id, WK_PLAN_VER_ID, fact.ACT_LABOR_HRS, 0)
                           else
                           NULL
                           end
                         ) ACT_LABOR_HRS,
                      sum( case when  fact.time_id <= END_PERIOD_ID
                           then
                           decode(fact.plan_version_id, WK_PLAN_VER_ID, fact.ACT_EQUIP_HRS, 0)
                           else
                           NULL
                           end
                         ) ACT_EQUIP_HRS,
                      sum( case when  fact.time_id <= END_PERIOD_ID
                           then
                           decode( fact.plan_version_id, WK_PLAN_VER_ID, TXN_MASK* fact.act_labor_brdn_cost, 0 )
                           else
                           NULL
                           end
                         ) ACT_TXN_LABOR_BRDN_COST,
                      sum( case when  fact.time_id <= END_PERIOD_ID
                           then
                           decode(fact.plan_version_id, WK_PLAN_VER_ID, TXN_MASK* fact.act_equip_brdn_cost, 0 )
                           else
                           NULL
                           end
                         ) ACT_TXN_EQUIP_BRDN_COST,
                      sum( case when  fact.time_id <= END_PERIOD_ID
                           then
                           decode(fact.plan_version_id, WK_PLAN_VER_ID, TXN_MASK* fact.act_raw_cost, 0 )
                           else
                           NULL
                           end
                         ) ACT_TXN_RAW_COST,
                      sum( case when  fact.time_id <= END_PERIOD_ID
                           then
                           decode(fact.plan_version_id, WK_PLAN_VER_ID, TXN_MASK* fact.act_brdn_cost, 0 )
                           else
                           NULL
                           end
                         ) ACT_TXN_BRDN_COST,
                      sum( case when  fact.time_id <= END_PERIOD_ID
                           then
                           decode(fact.plan_version_id, WK_PLAN_VER_ID, PRJ_MASK*  fact.act_labor_brdn_cost, 0)
                           else
                           NULL
                           end
                         ) ACT_PRJ_LABOR_BRDN_COST,
                      sum( case when  fact.time_id <= END_PERIOD_ID
                           then
                           decode( fact.plan_version_id, WK_PLAN_VER_ID, PRJ_MASK*  fact.act_equip_brdn_cost, 0)
                           else
                           NULL
                           end
                         ) ACT_PRJ_EQUIP_BRDN_COST,
                      sum( case when  fact.time_id <= END_PERIOD_ID
                           then
                           decode(fact.plan_version_id, WK_PLAN_VER_ID, PRJ_MASK*  fact.act_raw_cost, 0 )
                           else
                           NULL
                           end
                         ) ACT_PRJ_RAW_COST,
                      sum( case when  fact.time_id <= END_PERIOD_ID
                           then
                           decode(fact.plan_version_id, WK_PLAN_VER_ID, PRJ_MASK*  fact.act_brdn_cost, 0 )
                           else
                           NULL
                           end
                         ) ACT_PRJ_BRDN_COST,
                      sum( case when  fact.time_id <= END_PERIOD_ID
                           then
                           decode(fact.plan_version_id, WK_PLAN_VER_ID, POU_MASK*  fact.act_labor_brdn_cost, 0 )
                           else
                           NULL
                           end
                         ) ACT_POU_LABOR_BRDN_COST,
                      sum( case when  fact.time_id <= END_PERIOD_ID
                           then
                           decode(fact.plan_version_id, WK_PLAN_VER_ID, POU_MASK*  fact.act_equip_brdn_cost, 0 )
                           else
                           NULL
                           end
                         ) ACT_POU_EQUIP_BRDN_COST,
                      sum( case when  fact.time_id <= END_PERIOD_ID
                           then
                           decode(fact.plan_version_id, WK_PLAN_VER_ID, POU_MASK*  fact.act_raw_cost, 0 )
                           else
                           NULL
                           end
                         ) ACT_POU_RAW_COST,
                      sum( case when  fact.time_id <= END_PERIOD_ID
                           then
                           decode(fact.plan_version_id, WK_PLAN_VER_ID, POU_MASK*  fact.act_brdn_cost, 0 )
                           else
                           NULL
                           end
                         ) ACT_POU_BRDN_COST,

                      sum(case when fact.plan_version_id      = WK_PLAN_VER_ID then fact.ETC_LABOR_HRS else 0 end)  ETC_LABOR_HRS,
                      sum(case when fact.plan_version_id      = WK_PLAN_VER_ID then fact.ETC_EQUIP_HRS else 0 end)  ETC_EQUIP_HRS,
                      sum(case when fact.plan_version_id   = WK_PLAN_VER_ID then fact.ETC_labor_brdn_cost*TXN_MASK else 0 end)  ETC_TXN_LABOR_BRDN_COST,
                      sum(case when fact.plan_version_id  = WK_PLAN_VER_ID then fact.ETC_equip_brdn_cost*TXN_MASK else 0 end)  ETC_TXN_EQUIP_BRDN_COST,
                      sum(case when fact.plan_version_id  = WK_PLAN_VER_ID then fact.ETC_raw_cost*TXN_MASK else 0 end)   ETC_TXN_RAW_COST,
                      sum(case when fact.plan_version_id  = WK_PLAN_VER_ID then fact.ETC_brdn_cost*TXN_MASK else 0 end)   ETC_TXN_BRDN_COST,
                      sum(case when fact.plan_version_id  = WK_PLAN_VER_ID then fact.ETC_labor_brdn_cost*PRJ_MASK else 0 end)  ETC_PRJ_LABOR_BRDN_COST,
                      sum(case when fact.plan_version_id  = WK_PLAN_VER_ID then fact.ETC_equip_brdn_cost*PRJ_MASK else 0 end)  ETC_PRJ_EQUIP_BRDN_COST,
                      sum(case when fact.plan_version_id  = WK_PLAN_VER_ID then fact.ETC_raw_cost*PRJ_MASK else 0 end)   ETC_PRJ_RAW_COST,
                      sum(case when fact.plan_version_id  = WK_PLAN_VER_ID then fact.ETC_brdn_cost*PRJ_MASK else 0 end)   ETC_PRJ_BRDN_COST,
                      sum(case when fact.plan_version_id   = WK_PLAN_VER_ID then fact.ETC_labor_brdn_cost*POU_MASK else 0 end)  ETC_POU_LABOR_BRDN_COST,
                      sum(case when fact.plan_version_id  = WK_PLAN_VER_ID then fact.ETC_equip_brdn_cost*POU_MASK else 0 end)  ETC_POU_EQUIP_BRDN_COST,
                      sum(case when fact.plan_version_id  = WK_PLAN_VER_ID then fact.ETC_raw_cost*POU_MASK else 0 end)   ETC_POU_RAW_COST,
                      sum(case when fact.plan_version_id  = WK_PLAN_VER_ID then fact.ETC_brdn_cost*POU_MASK else 0 end)   ETC_POU_BRDN_COST,
                      sum( case when  fact.time_id <= END_PERIOD_ID
                           then
                           decode(fact.plan_version_id , WK_PLAN_VER_ID, TXN_MASK*fact.act_labor_raw_cost,0)
                           else
                           NULL
                           end
                         ) ACT_TXN_LABOR_RAW_COST,
                      sum( case when  fact.time_id <= END_PERIOD_ID
                           then
                           decode(fact.plan_version_id, WK_PLAN_VER_ID, PRJ_MASK* fact.act_labor_raw_cost,0)
                           else
                           NULL
                           end
                         ) ACT_PRJ_LABOR_RAW_COST,
                      sum( case when  fact.time_id <= END_PERIOD_ID
                           then
                           decode( fact.plan_version_id, WK_PLAN_VER_ID, POU_MASK* fact.act_labor_raw_cost,0)
                           else
                           NULL
                           end
                         ) ACT_POU_LABOR_RAW_COST,
                      sum( case when  fact.time_id <= END_PERIOD_ID
                           then
                           decode(fact.plan_version_id, WK_PLAN_VER_ID, TXN_MASK*fact.act_equip_raw_cost,0)
                           else
                           NULL
                           end
                         ) ACT_TXN_EQUIP_RAW_COST,
                      sum( case when  fact.time_id <= END_PERIOD_ID
                           then
                           decode(fact.plan_version_id, WK_PLAN_VER_ID, PRJ_MASK* fact.act_equip_raw_cost,0)
                           else
                           NULL
                           end
                         ) ACT_PRJ_EQUIP_RAW_COST,
                      sum( case when  fact.time_id <= END_PERIOD_ID
                           then
                           decode( fact.plan_version_id, WK_PLAN_VER_ID, POU_MASK* fact.act_equip_raw_cost,0)
                           else
                           NULL
                           end
                         ) ACT_POU_EQUIP_RAW_COST,

                      sum(case when fact.plan_version_id  = WK_PLAN_VER_ID then fact.ETC_labor_raw_cost*TXN_MASK else 0 end)  ETC_TXN_LABOR_RAW_COST,
                      sum(case when fact.plan_version_id  = WK_PLAN_VER_ID then fact.ETC_labor_raw_cost*PRJ_MASK else 0 end)  ETC_PRJ_LABOR_RAW_COST,
                      sum(case when fact.plan_version_id  = WK_PLAN_VER_ID then fact.ETC_labor_raw_cost*POU_MASK else 0 end)  ETC_POU_LABOR_RAW_COST,
                      sum(case when fact.plan_version_id  = WK_PLAN_VER_ID then fact.ETC_equip_raw_cost*TXN_MASK else 0 end)  ETC_TXN_EQUIP_RAW_COST,
                      sum(case when fact.plan_version_id  = WK_PLAN_VER_ID then fact.ETC_equip_raw_cost*PRJ_MASK else 0 end)  ETC_PRJ_EQUIP_RAW_COST,
                      sum(case when fact.plan_version_id  = WK_PLAN_VER_ID then fact.ETC_equip_raw_cost*POU_MASK else 0 end)  ETC_POU_EQUIP_RAW_COST,
                        /* Retrival of Project Level Data Starts*/
                      sum(case when fact.plan_version_id  = WK_PLAN_VER_ID   then fact.raw_cost*PRJ_MASK*ROLLUP_MASK else 0 end)  P_RAW_COST,
                      sum(case when fact.plan_version_id  = WK_PLAN_VER_ID   then fact.brdn_cost*PRJ_MASK*ROLLUP_MASK else 0 end) P_BRDN_COST,
                      sum(case when fact.plan_version_id  = WK_PLAN_VER_ID   then fact.revenue*PRJ_MASK*ROLLUP_MASK else 0 end)  P_REVENUE,
                      sum(case when fact.plan_version_id  = WK_PLAN_VER_ID   then fact.labor_raw_cost*PRJ_MASK*ROLLUP_MASK else 0 end)  P_LBR_RAW_COST,
                      sum(case when fact.plan_version_id   = WK_PLAN_VER_ID   then fact.labor_brdn_cost*PRJ_MASK*ROLLUP_MASK else 0 end) P_LBR_BRDN_COST,
                      sum(case when fact.plan_version_id  = WK_PLAN_VER_ID   then fact.equipment_raw_cost*PRJ_MASK*ROLLUP_MASK else 0 end) P_EQP_RAW_COST,
                      sum(case when fact.plan_version_id  = WK_PLAN_VER_ID   then fact.equipment_brdn_cost*PRJ_MASK*ROLLUP_MASK else 0 end)  P_EQP_BRDN_COST,
                      sum(case when fact.plan_version_id  = base_plan_ver_id then fact.raw_cost*PRJ_MASK*ROLLUP_MASK else 0 end)  P_BASE_RAW_COST,
                      sum(case when fact.plan_version_id  = base_plan_ver_id then fact.brdn_cost*PRJ_MASK*ROLLUP_MASK else 0 end)  P_BASE_BRDN_COST,
                      sum(case when fact.plan_version_id  = base_plan_ver_id then fact.labor_raw_cost*PRJ_MASK*ROLLUP_MASK else 0 end)  P_BASE_LBR_RAW_COST,
                      sum(case when fact.plan_version_id  = base_plan_ver_id then fact.labor_brdn_cost*PRJ_MASK*ROLLUP_MASK else 0 end)  P_BASE_LBR_BRDN_COST,
                      sum(case when fact.plan_version_id  = base_plan_ver_id then fact.equipment_raw_cost*PRJ_MASK*ROLLUP_MASK else 0 end) P_BASE_EQP_RAW_COST,
                      sum(case when fact.plan_version_id  = base_plan_ver_id then fact.equipment_brdn_cost*PRJ_MASK*ROLLUP_MASK else 0 end) P_BASE_EQP_BRDN_COST,
                      sum(case when fact.plan_version_id  = lpb_plan_ver_id  then fact.raw_cost*PRJ_MASK*ROLLUP_MASK else 0 end)  P_LPB_RAW_COST,
                      sum(case when fact.plan_version_id  = lpb_plan_ver_id  then fact.brdn_cost*PRJ_MASK*ROLLUP_MASK else 0 end)  P_LPB_BRDN_COST,
                      sum(case when fact.plan_version_id  = lpb_plan_ver_id  then fact.labor_raw_cost*PRJ_MASK*ROLLUP_MASK else 0 end)  P_LPB_LBR_RAW_COST,
                      sum(case when fact.plan_version_id  = lpb_plan_ver_id  then fact.labor_brdn_cost*PRJ_MASK*ROLLUP_MASK else 0 end)  P_LPB_LBR_BRDN_COST,
                      sum(case when fact.plan_version_id  = lpb_plan_ver_id  then fact.equipment_raw_cost*PRJ_MASK*ROLLUP_MASK else 0 end)  P_LPB_EQP_RAW_COST,
                      sum(case when fact.plan_version_id  = lpb_plan_ver_id  then fact.equipment_brdn_cost*PRJ_MASK*ROLLUP_MASK else 0 end)  P_LPB_EQP_BRDN_COST,
                      sum(case when fact.plan_version_id  = WK_PLAN_VER_ID   then fact.LABOR_HRS*ROLLUP_MASK else 0 end) P_LBR_HOURS,
                      sum(case when fact.plan_version_id  = WK_PLAN_VER_ID   then fact.EQUIPMENT_HOURS*ROLLUP_MASK else 0 end) P_EQP_HOURS,
                      sum(case when fact.plan_version_id  = base_plan_ver_id then fact.LABOR_HRS*ROLLUP_MASK else 0 end) P_BASE_LBR_HOURS,
                      sum(case when fact.plan_version_id  = base_plan_ver_id then fact.EQUIPMENT_HOURS*ROLLUP_MASK else 0 end) P_BASE_EQP_HOURS,
                      sum(case when fact.plan_version_id  = lpb_plan_ver_id  then fact.LABOR_HRS*ROLLUP_MASK else 0 end) P_LPB_LBR_HOURS,
                      sum(case when fact.plan_version_id  = lpb_plan_ver_id  then fact.EQUIPMENT_HOURS*ROLLUP_MASK else 0 end) P_LPB_EQP_HOURS,


                      sum( case when  fact.time_id <= END_PERIOD_ID
                           then
                           decode(fact.plan_version_id, WK_PLAN_VER_ID, ROLLUP_MASK*fact.ACT_LABOR_HRS, 0)
                           else
                           NULL
                           end
                         ) P_ACT_LBR_HOURS,
                      sum( case when  fact.time_id <= END_PERIOD_ID
                           then
                           decode(fact.plan_version_id, WK_PLAN_VER_ID, ROLLUP_MASK*fact.ACT_EQUIP_HRS, 0)
                           else
                           NULL
                           end
                         ) P_ACT_EQP_HOURS,
                      sum( case when  fact.time_id <= END_PERIOD_ID
                           then
                           decode(fact.plan_version_id, WK_PLAN_VER_ID, PRJ_MASK*ROLLUP_MASK* fact.act_labor_brdn_cost, 0)
                           else
                           NULL
                           end
                         ) P_ACT_LBR_BRDN_COST,
                      sum( case when  fact.time_id <= END_PERIOD_ID
                           then
                           decode( fact.plan_version_id, WK_PLAN_VER_ID, PRJ_MASK*ROLLUP_MASK*  fact.act_equip_brdn_cost, 0)
                           else
                           NULL
                           end
                         ) P_ACT_EQP_BRDN_COST,
                      sum( case when  fact.time_id <= END_PERIOD_ID
                           then
                           decode(fact.plan_version_id, WK_PLAN_VER_ID, PRJ_MASK*ROLLUP_MASK*  fact.act_raw_cost , 0 )
                           else
                           NULL
                           end
                         ) P_ACT_RAW_COST,
                      sum( case when  fact.time_id <= END_PERIOD_ID
                           then
                           decode(fact.plan_version_id, WK_PLAN_VER_ID, PRJ_MASK*ROLLUP_MASK*  fact.act_brdn_cost, 0 )
                           else
                           NULL
                           end
                         ) P_ACT_BRDN_COST,
                       sum( case when  fact.time_id <= END_PERIOD_ID
                           then
                           decode( fact.plan_version_id, WK_PLAN_VER_ID, PRJ_MASK*ROLLUP_MASK* fact.act_labor_raw_cost,0)
                           else
                           NULL
                           end
                         ) P_ACT_LBR_RAW_COST,
                       sum( case when  fact.time_id <= END_PERIOD_ID
                           then
                           decode(fact.plan_version_id, WK_PLAN_VER_ID, PRJ_MASK*ROLLUP_MASK* fact.act_equip_raw_cost ,0)
                           else
                           NULL
                           end
                         ) P_ACT_EQP_RAW_COST,

                      sum(case when fact.plan_version_id   = WK_PLAN_VER_ID  then fact.ETC_EQUIP_HRS*ROLLUP_MASK else 0 end) P_ETC_EQP_HOURS,
                      sum(case when fact.plan_version_id  = WK_PLAN_VER_ID  then fact.ETC_LABOR_HRS*ROLLUP_MASK else 0 end) P_ETC_LBR_HOURS,
                      sum(case when fact.plan_version_id  = WK_PLAN_VER_ID  then fact.ETC_raw_cost*PRJ_MASK*ROLLUP_MASK else 0 end) P_ETC_RAW_COST,
                      sum(case when fact.plan_version_id  = WK_PLAN_VER_ID  then fact.ETC_brdn_cost*PRJ_MASK*ROLLUP_MASK else 0 end) P_ETC_BRDN_COST,
                      sum(case when fact.plan_version_id  = WK_PLAN_VER_ID  then fact.ETC_labor_brdn_cost*PRJ_MASK*ROLLUP_MASK else 0 end) P_ETC_LBR_BRDN_COST,
                      sum(case when fact.plan_version_id  = WK_PLAN_VER_ID  then fact.ETC_equip_brdn_cost*PRJ_MASK*ROLLUP_MASK else 0 end) P_ETC_EQP_BRDN_COST,
                      sum(case when fact.plan_version_id   = WK_PLAN_VER_ID  then fact.ETC_labor_raw_cost*PRJ_MASK*ROLLUP_MASK else 0 end) P_ETC_LBR_RAW_COST,
                      sum(case when fact.plan_version_id  = WK_PLAN_VER_ID  then fact.ETC_equip_raw_cost*PRJ_MASK*ROLLUP_MASK else 0 end) P_ETC_EQP_RAW_COST
                      /* Retrival of Project Level Data Ends*/
        FROM
        (
                        SELECT
                                 PROJECT_ID                ,
                                 PROJECT_ORG_ID            ,
                                 PROJECT_ORGANIZATION_ID   ,
                                 PROJECT_ELEMENT_ID        ,
                                 TIME_ID                   ,
                                 PERIOD_TYPE_ID            ,
                                 CALENDAR_TYPE             ,
                                 RBS_AGGR_LEVEL            ,
                                 WBS_ROLLUP_FLAG           ,
                                 PRG_ROLLUP_FLAG           ,
                                 decode ( cc_src.curr_type, 'TXN', 16, 'PRJ', 8, 'POU', 4) CURR_RECORD_TYPE_ID       ,
                                 CURRENCY_CODE             ,
                                 RBS_ELEMENT_ID            ,
                                 RBS_VERSION_ID            ,
                                 PLAN_VERSION_ID           ,
                                 -- PLAN_TYPE_ID              ,
                                 RAW_COST                  ,
                                 BRDN_COST                 ,
                                 REVENUE                   ,
                                 BILL_RAW_COST             ,
                                 BILL_BRDN_COST            ,
                                 BILL_LABOR_RAW_COST       ,
                                 BILL_LABOR_BRDN_COST      ,
                                 decode ( cc_src.curr_type, 'PRJ', BILL_LABOR_HRS, 0) BILL_LABOR_HRS      ,
                                 EQUIPMENT_RAW_COST        ,
                                 EQUIPMENT_BRDN_COST       ,
                                 CAPITALIZABLE_RAW_COST    ,
                                 CAPITALIZABLE_BRDN_COST   ,
                                 LABOR_RAW_COST            ,
                                 LABOR_BRDN_COST           ,
                                 decode ( cc_src.curr_type, 'PRJ', LABOR_HRS, 0) LABOR_HRS      ,
                                 LABOR_REVENUE             ,
                                 decode ( cc_src.curr_type, 'PRJ', EQUIPMENT_HOURS, 0) EQUIPMENT_HOURS      ,
                                 decode ( cc_src.curr_type, 'PRJ', BILLABLE_EQUIPMENT_HOURS, 0) BILLABLE_EQUIPMENT_HOURS      ,
                                 SUP_INV_COMMITTED_COST    ,
                                 PO_COMMITTED_COST         ,
                                 PR_COMMITTED_COST         ,
                                 OTH_COMMITTED_COST        ,
                                 CUSTOM1                   ,
                                 CUSTOM2                   ,
                                 CUSTOM3                   ,
                                 CUSTOM4                   ,
                                 CUSTOM5                   ,
                                 CUSTOM6                   ,
                                 CUSTOM7                   ,
                                 CUSTOM8                   ,
                                 CUSTOM9                   ,
                                 CUSTOM10                  ,
                                 CUSTOM11                  ,
                                 CUSTOM12                  ,
                                 CUSTOM13                  ,
                                 CUSTOM14                  ,
                                 CUSTOM15                  ,
                                 decode ( cc_src.curr_type, 'PRJ', ACT_LABOR_HRS, 0) ACT_LABOR_HRS      ,
                                 decode ( cc_src.curr_type, 'PRJ', ACT_EQUIP_HRS, 0) ACT_EQUIP_HRS      ,
                                 ACT_LABOR_BRDN_COST       ,
                                 ACT_EQUIP_BRDN_COST       ,
                                 ACT_BRDN_COST             ,
                                 decode ( cc_src.curr_type, 'PRJ', ETC_LABOR_HRS, 0) ETC_LABOR_HRS      ,
                                 decode ( cc_src.curr_type, 'PRJ', ETC_EQUIP_HRS, 0) ETC_EQUIP_HRS      ,
                                 ETC_LABOR_BRDN_COST       ,
                                 ETC_EQUIP_BRDN_COST       ,
                                 ETC_BRDN_COST             ,
                                 ACT_RAW_COST              ,
                                 ACT_REVENUE               ,
                                 ETC_RAW_COST              ,
                                 ACT_LABOR_RAW_COST        ,
                                 ACT_EQUIP_RAW_COST        ,
                                 ETC_LABOR_RAW_COST        ,
                                 ETC_EQUIP_RAW_COST        ,
                                 decode(fact.prg_rollup_flag,'N',1,0)  ROLLUP_MASK,
                                 decode ( cc_src.curr_type, 'TXN',1,0)  TXN_MASK,
                                 decode ( cc_src.curr_type, 'PRJ',1,0)  PRJ_MASK,
                                 decode ( cc_src.curr_type, 'POU',1,0)  POU_MASK
                        FROM
                                pji_fp_xbs_accum_f fact,
                                  (
                                            SELECT 'TXN' curr_type FROM DUAL
                                            UNION ALL
                                            SELECT 'PRJ' curr_type FROM DUAL
                                            UNION ALL
                                            SELECT 'POU' curr_type FROM DUAL
                                  ) cc_src
                       WHERE 1=1
                         and ( decode ( cc_src.curr_type, 'TXN', DECODE(BITAND(fact.curr_record_type_id, 16), 16, 'a'), 'b') = 'a'
                            or decode ( cc_src.curr_type, 'PRJ', DECODE(BITAND(fact.curr_record_type_id ,  8),  8, 'a'), 'b') = 'a'
                            or decode ( cc_src.curr_type, 'POU', DECODE(BITAND(fact.curr_record_type_id,  4),  4, 'a'), 'b') = 'a' )
               ) fact,
                 pji_plan_extr_tmp head
                WHERE    1=1
                        and fact.PROJECT_ID   = head.PROJECT_ID
                        and fact.PLAN_VERSION_ID in (head.WK_PLAN_VER_ID , head.BASE_PLAN_VER_ID,
                                                        head.LPB_PLAN_VER_ID )
                        and fact.PROJECT_ELEMENT_ID = nvl(head.PROJ_ELEM_ID, fact.PROJECT_ELEMENT_ID )
                        and fact.CALENDAR_TYPE = CAL_TYPE
                        and fact.PERIOD_TYPE_ID = PERIOD_ID
                        and BITAND(fact.CURR_RECORD_TYPE_ID,28) <= 28
                        and BITAND(fact.CURR_RECORD_TYPE_ID,28) >= 4
                        and fact.RBS_AGGR_LEVEL = 'T'
                        and fact.prg_rollup_flag in (p_program_rollup_flag,'N')
                        and fact.rbs_version_id = -1 /* Bug 6930211 */
              GROUP BY
                      fact.PROJECT_ID,
                      fact.PROJECT_ELEMENT_ID,
                      fact.CALENDAR_TYPE,
                      head.WK_PLAN_VER_ID,
                      head.STRUCT_VER_ID;

    PRINT_TIME (  ' populate_workplan_data 0003.12 '||SQL%ROWCOUNT ) ;

     IF g_debug_mode='Y' THEN
        debug_accum ; /* bug#3993830 */
     END IF;




    DELETE FROM PJI_PLAN_EXTR_TMP;

        x_return_status := l_return_status;

    PRINT_TIME (  ' populate_workplan_data 0003.13 ' ) ;

        EXCEPTION
                  WHEN OTHERS THEN

                    PJI_PJP_FP_CURR_WRAP.EXCP_HANDLER
                    ( p_package_name   => g_package_name
                    , p_procedure_name => 'POPULATE_WORKPLAN_DATA'
                    , x_return_status =>  x_return_status ) ;

                    RAISE;
        END;


PROCEDURE FPM_UPGRADE_INITIALIZE IS

  c_upgr_proc_name  VARCHAR2(30) := 'PJI_FPM_UPGRADE';
  l_worker_id       NUMBER;
  l_process         VARCHAR2(30);
  l_extr_start_date DATE;
  l_pa_period_flag  VARCHAR2(10);
  l_gl_period_flag  VARCHAR2(10);
  l_return_status   VARCHAR2(100);

BEGIN

    PJI_PJP_FP_CURR_WRAP.INIT_ERR_STACK
    ( p_package_name   => g_package_name
    , x_return_status  => l_return_status );

    l_worker_id       := 1;
    l_process         := PJI_PJP_SUM_MAIN.g_process || l_worker_id;
    l_extr_start_date := PJI_UTILS.GET_EXTRACTION_START_DATE;             PRINT_TIME ( ' FPM_UPGRADE_INITIALIZE  001 ' ) ;

    Pji_utils.set_parameter(c_upgr_proc_name, 'P');             -- table pji_system_parameters
    PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE', 'FULL');  -- table pji_system_parameters
    PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER(l_process, 'PROCESS_RUNNING', 'Y');     -- table pji_system_parameters
    PJI_PJP_EXTRACTION_UTILS.SET_WORKER_ID(l_worker_id);     -- Private global pkg var: PJI_PJP_EXTRACTION_UTILS.g_worker_id.

                                                              PRINT_TIME ( ' FPM_UPGRADE_INITIALIZE  002 ' ) ;


    insert into PJI_SYSTEM_CONFIG_HIST
    (
      REQUEST_ID,
      USER_NAME,
      PROCESS_NAME,
      RUN_TYPE,
      PARAMETERS,
      CONFIG_PROJ_PERF_FLAG,
      CONFIG_COST_FLAG,
      CONFIG_PROFIT_FLAG,
      CONFIG_UTIL_FLAG,
      START_DATE,
      END_DATE,
      COMPLETION_TEXT
    )
    select
      FND_GLOBAL.CONC_REQUEST_ID                         REQUEST_ID,
      substr(FND_GLOBAL.USER_NAME, 1, 10)                USER_NAME,
      l_process                                          PROCESS_NAME,
      'FPM_UPGRADE'                                      RUN_TYPE,
      null                                               PARAMETERS,
      null                                               CONFIG_PROJ_PERF_FLAG,
      null                                               CONFIG_COST_FLAG,
      null                                               CONFIG_PROFIT_FLAG,
      null                                               CONFIG_UTIL_FLAG,
      sysdate                                            START_DATE,
      null                                               END_DATE,
      null                                               COMPLETION_TEXT
    from
      dual;

    insert into PJI_PJP_PROJ_BATCH_MAP
    (
      WORKER_ID,
      PROJECT_ID,
      PJI_PROJECT_STATUS,
      EXTRACTION_TYPE,
      EXTRACTION_STATUS,
      PROJECT_TYPE,
      PROJECT_ORG_ID,
      PROJECT_ORGANIZATION_ID,
      PROJECT_TYPE_CLASS,
      PRJ_CURRENCY_CODE,
      PROJECT_ACTIVE_FLAG
    )
    select
      l_worker_id,
      prj.PROJECT_ID,
      null,
      null,
      'F',
      prj.PROJECT_TYPE,
      prj.ORG_ID,
      prj.CARRYING_OUT_ORGANIZATION_ID,
      decode(pt.PROJECT_TYPE_CLASS_CODE,
             'CAPITAL',  'C',
             'CONTRACT', 'B',
             'INDIRECT', 'I'),
      prj.PROJECT_CURRENCY_CODE,
      null
    from
      PA_PROJECTS_ALL prj,
      PA_PROJECT_TYPES_ALL pt
    where
      -- We cannot depend on extraction start date as it will not be
      -- set at the time of upgrade.
      nvl(prj.CLOSED_DATE, nvl(l_extr_start_date, to_date(1, 'J')))
        >= nvl(l_extr_start_date, to_date(1, 'J')) and
      prj.ORG_ID                               = pt.ORG_ID and
      prj.PROJECT_TYPE                         = pt.PROJECT_TYPE and
      prj.PROJECT_ID in (select ver.PROJECT_ID
                         from   PA_BUDGET_VERSIONS ver
                         where  ver.BUDGET_TYPE_CODE is null);

    PRINT_TIME ( ' FPM_UPGRADE_INITIALIZE  004 ' ) ;

    SELECT PJI_UTILS.GET_SETUP_PARAMETER('PA_PERIOD_FLAG') , PJI_UTILS.GET_SETUP_PARAMETER('GL_PERIOD_FLAG')
    INTO   l_pa_period_flag, l_gl_period_flag
    FROM   DUAL;

    if (l_pa_period_flag = 'N') then
      PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER(l_process,
                                             'PA_CALENDAR_FLAG',
                                             'N');
    else
      PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER(l_process,
                                             'PA_CALENDAR_FLAG',
                                              'Y');
    end if;

    if (l_gl_period_flag = 'N') then
      PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER(l_process,
                                             'GL_CALENDAR_FLAG',
                                             'N');
    else
      PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER(l_process,
                                             'GL_CALENDAR_FLAG',
                                             'Y');
    end if;                                                                PRINT_TIME ( ' FPM_UPGRADE_INITIALIZE  004 ' ) ;

    --
    -- 4682341
    -- Parameter 'EXTRACT_ETC_FULLLOAD' has been added to check whether
    --   etc (due to act or overridden) is not extracted twice after upgrade
    --   and initial load.
    -- Assumption: After fpm upgrade, an initial load is run for *All* projects
    --   before new actuals are entered in the system.
    -- Use: If the value of this param is 'Y', then etc from get plan res actuals will
    --   be extracted during FULL sumz.

    DELETE FROM pji_system_parameters
    WHERE  name = 'EXTRACT_ETC_FULLLOAD';

    INSERT INTO pji_system_parameters ( name, value )
    VALUES (  'EXTRACT_ETC_FULLLOAD' , 'N' );

    commit;

EXCEPTION
  WHEN OTHERS THEN

    PJI_PJP_FP_CURR_WRAP.EXCP_HANDLER
    ( p_package_name   => g_package_name
    , p_procedure_name => 'FPM_UPGRADE_INITIALIZE'
    , x_return_status =>  l_return_status ) ;

    RAISE;
END;


PROCEDURE FPM_UPGRADE_END IS

  l_worker_id       NUMBER;
  l_process         VARCHAR2(30);
  l_extr_start_date DATE;
  l_return_status   VARCHAR2(100);
  l_sqlerrm         VARCHAR2(240);

BEGIN

    PJI_PJP_FP_CURR_WRAP.INIT_ERR_STACK
    ( p_package_name   => g_package_name
    , x_return_status  => l_return_status );

  l_worker_id       := 1;
  l_process         := PJI_PJP_SUM_MAIN.g_process || l_worker_id;
  l_extr_start_date := PJI_UTILS.GET_EXTRACTION_START_DATE;

  PJI_PJP_SUM_ROLLUP.CLEANUP(l_worker_id);

  Pji_utils.set_parameter('PJI_FPM_UPGRADE', 'C');

  PJI_PROCESS_UTIL.WRAPUP_PROCESS(l_process);

    update PJI_SYSTEM_CONFIG_HIST
    set    END_DATE = sysdate,
           COMPLETION_TEXT = 'Normal completion'
    where  PROCESS_NAME = l_process and
           RUN_TYPE = 'FPM_UPGRADE' and
           END_DATE is null;

  PJI_UTILS.SET_PARAMETER('PJP_FPM_UPGRADE_DATE',
                          to_char(sysdate, PJI_PJP_SUM_MAIN.g_date_mask));

  DELETE FROM PJI_PJP_PROJ_BATCH_MAP WHERE WORKER_ID = l_worker_id;

  commit;

EXCEPTION
  WHEN OTHERS THEN

    rollback;

    PJI_PJP_FP_CURR_WRAP.EXCP_HANDLER
    ( p_package_name   => g_package_name
    , p_procedure_name => 'FPM_UPGRADE_END'
    , x_return_status =>  l_return_status ) ;

    l_sqlerrm := substr(sqlerrm, 1, 240);

    update PJI_SYSTEM_CONFIG_HIST
    set    END_DATE = sysdate,
           COMPLETION_TEXT = l_sqlerrm
    where  RUN_TYPE = 'FPM_UPGRADE' and
           END_DATE is null;

    commit;

    RAISE;
END;


PROCEDURE REMAP_RBS_TXN_ACCUM_HDRS (
     x_return_status                    OUT NOCOPY      VARCHAR2
    ,x_msg_data                         OUT NOCOPY      VARCHAR2
    ,x_msg_count                        OUT NOCOPY      NUMBER ) IS

  CURSOR c_current_rbs_versions IS
  SELECT prv.RBS_VERSION_ID
  FROM pa_rbs_versions_b prv
  WHERE 1=1
    AND prv.CURRENT_REPORTING_FLAG = 'Y'
    AND prv.STATUS_CODE            = 'FROZEN';
    --AND prv.RBS_VERSION_ID not in ( 10000, 10142, 10224, 10821);

  CURSOR c_plan_versions (l_rbs_version_id NUMBER) IS -- This can be combined with the previous cursor.
  SELECT bv.budget_version_id, bv.project_id
  FROM pa_budget_versions bv
     , pa_proj_fp_options fpo
  WHERE 1=1
    AND bv.budget_version_id = fpo.fin_plan_version_id
    AND bv.fin_plan_type_id = fpo.fin_plan_type_id
    AND fpo.project_id = bv.project_id
    AND bv.version_type is not NULL
    AND bv.fin_plan_type_id is not NULL
    AND fpo.fin_plan_option_level_code = 'PLAN_VERSION'
    AND bv.version_type IN ( 'ALL' , 'COST' , 'REVENUE')
    AND fpo.RBS_VERSION_ID = l_rbs_version_id;

   l_res_list_member_id_tbl       SYSTEM.pa_num_tbl_type         := SYSTEM.pa_num_tbl_type();
   l_txn_source_id_tbl            SYSTEM.pa_num_tbl_type         := SYSTEM.pa_num_tbl_type();
   l_rbs_element_id_tbl           SYSTEM.pa_num_tbl_type         := SYSTEM.pa_num_tbl_type();
   l_txn_accum_header_id_tbl  SYSTEM.pa_num_tbl_type             := SYSTEM.pa_num_tbl_type();

BEGIN

  x_msg_count := 0;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  pa_debug.reset_curr_function;

  UPDATE pa_resource_assignments
  SET    txn_accum_header_id = NULL;

  FOR l_curr_rbs_vers IN c_current_rbs_versions LOOP


    FOR l_plan_versions in c_plan_versions(l_curr_rbs_vers.RBS_VERSION_ID) LOOP

     BEGIN
      pa_rlmi_rbs_map_pub.Map_Rlmi_Rbs (
           p_budget_version_id  => l_plan_versions.budget_version_id
          ,p_project_id                   => l_plan_versions.project_id
          ,p_rbs_version_id => l_curr_rbs_vers.RBS_VERSION_ID
          ,p_calling_process => 'RBS_REFRESH'
          ,p_calling_context => 'SELF_SERVICE'
          ,p_process_code => 'RBS_MAP'
          ,p_calling_mode => 'BUDGET_VERSION'
          ,x_txn_source_id_tab => l_txn_source_id_tbl
          ,x_res_list_member_id_tab       => l_res_list_member_id_tbl
          ,x_rbs_element_id_tab           => l_rbs_element_id_tbl
          ,x_txn_accum_header_id_tab      => l_txn_accum_header_id_tbl
          ,x_return_status => x_return_status
          ,x_msg_count => x_msg_count
          ,x_msg_data => x_msg_data);


      FORALL i IN l_txn_source_id_tbl.FIRST..l_txn_source_id_tbl.LAST
        UPDATE pa_resource_assignments
        SET TXN_ACCUM_HEADER_ID = l_txn_accum_header_id_tbl(i),
            RBS_ELEMENT_ID      = l_rbs_element_id_tbl(i)
        WHERE
            RESOURCE_ASSIGNMENT_ID = l_txn_source_id_tbl(i);

   EXCEPTION
     WHEN OTHERS THEN
        null;
   END;

   COMMIT;

    END LOOP;
  END LOOP;

EXCEPTION

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_count     := 1;
    x_msg_data      := SQLERRM;
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'REMAP_RBS_TXN_ACCUM_HDRS');
    RAISE;
END;



----------
-- Print time API to measure time taken by each api. Also useful for debugging.
----------
PROCEDURE PRINT_TIME(p_tag IN VARCHAR2) IS
BEGIN
  PJI_PJP_FP_CURR_WRAP.print_time(p_tag);
EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'PRINT_TIME');
    RAISE;
END;

PROCEDURE get_msp_actuals_data(
       p_project_id IN NUMBER,
       p_calendar_type IN VARCHAR2,
       p_resource_list_id IN NUMBER DEFAULT NULL,
       p_task_res_flag IN VARCHAR2,
       p_end_date IN DATE,
       x_return_status OUT NOCOPY VARCHAR2,
       x_msg_code OUT NOCOPY VARCHAR2) IS

    l_struct_element_id NUMBER;
    l_project_id_tab    SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
    l_resource_list_id_tab     SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
    l_struct_ver_id_tab SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
    l_calendar_type_tab SYSTEM.pa_varchar2_1_tbl_type :=
SYSTEM.pa_varchar2_1_tbl_type();
    l_end_date_tab SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();

   l_populate_in_tbl	 populate_in_tbl_type ;
   l_populate_in_rec	populate_in_rec_type;

BEGIN

      SELECT wbs_version_id
      INTO l_struct_element_id
      FROM pji_pjp_wbs_header
      WHERE project_id = p_project_id AND plan_version_id=-1;

      l_populate_in_rec.project_id :=	p_project_id;
      l_populate_in_rec.struct_ver_id		:=	l_struct_element_id;
      l_populate_in_rec.base_struct_ver_id	:=  NULL;
      l_populate_in_rec.plan_version_id      := NULL;
      l_populate_in_rec.as_of_date               := p_end_date;
      l_populate_in_rec.project_element_id	:=	 NULL;
      l_populate_in_tbl(1) :=	l_populate_in_rec;


      l_project_id_tab.extend;
      l_resource_list_id_tab.extend;
      l_struct_ver_id_tab.extend;
      l_calendar_type_tab.extend;
      l_end_date_tab.extend;


      l_project_id_tab(1) := p_project_id;
      l_resource_list_id_tab(1) := p_resource_list_id;
      l_struct_ver_id_tab(1) := l_struct_element_id;
      l_calendar_type_tab(1) := p_calendar_type;
      l_end_date_tab(1) := p_end_date;

      IF(p_task_res_flag ='R') THEN
          get_summarized_data(
              p_project_ids => l_project_id_tab,
              p_resource_list_ids => l_resource_list_id_tab,
              p_struct_ver_ids => l_struct_ver_id_tab,
              p_end_date => l_end_date_tab,
              p_calendar_type => l_calendar_type_tab,
              p_extraction_type => 'FULL',
              p_record_type => 'NYYY',
              p_currency_type => 4,
              x_return_status => x_return_status,
              x_msg_code => x_msg_code);
       ELSE IF(p_task_res_flag='T') THEN
	    populate_workplan_data (
		    p_populate_in_tbl  =>	l_populate_in_tbl,
		    p_calling_context =>        'MSP',  -- added for bug 5751250
			x_return_status     => x_return_status,
			x_msg_code          => x_msg_code
			   );
          end if;
       END IF;
EXCEPTION
         WHEN OTHERS THEN
              PJI_PJP_FP_CURR_WRAP.EXCP_HANDLER
              (p_package_name   => g_package_name
              , p_procedure_name => 'GET_MSP_ACTUALS_DATA'
              , x_return_status =>  x_return_status ) ;
END;



END PJI_FM_XBS_ACCUM_UTILS;

/
