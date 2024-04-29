--------------------------------------------------------
--  DDL for Package Body MSC_M2A_PUSH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_M2A_PUSH" AS -- body
/* $Header: MSCPUSHB.pls 120.7.12010000.4 2009/12/09 06:29:42 vsiyer ship $ */


 ----- PARAMETERS --------------------------------------------------------

   v_dblink                     VARCHAR2(128);
   v_cp_enabled                 NUMBER;
   v_distributed_config_flag    NUMBER;
   v_sql_stmt                   VARCHAR2(9000);
   v_warning_flag               NUMBER := SYS_NO;
   v_errbuf			varchar2(2048);
   v_retcode			number;
   v_buff			varchar2(5000);

-- For outbound XML (instance_type = 3)
   v_ins_type                   PLS_INTEGER;

--=====================Private Routines===================================

   PROCEDURE LOG_MESSAGE( pBUFF                     IN  VARCHAR2)
   IS
   BEGIN

         FND_FILE.PUT_LINE( FND_FILE.LOG, pBUFF);
         -- dbms_output.put_line(pBUFF);

   END LOG_MESSAGE;

--================Insert Plan Information==================================


   FUNCTION ins_mrp_plan    (pINSTANCE_ID IN NUMBER,
                             pDESIGNATOR  IN VARCHAR2,
                             pORGANIZATION_ID  IN NUMBER,
                             pPLANNER  IN VARCHAR2,
                             pCATEGORY_ID  IN NUMBER,
                             pITEM_ID  IN NUMBER,
                             pSUPPLIER_ID  IN NUMBER,
                             pSUPPLIER_SITE_ID  IN NUMBER,
                             pHORIZON_START_DATE  IN VARCHAR2,
                             pHORIZON_END_DATE  IN VARCHAR2)
   RETURN BOOLEAN
   IS
        lv_count 	number :=0;
        lv_sql_stmt     varchar2(9000):=NULL;
        lv_previous_plan_start_date DATE;
   CURSOR c1 IS
        select plan_id, organization_id, plan_start_date
        from   msc_plans
        where  sr_instance_id = pINSTANCE_ID
        and    compile_designator = pDESIGNATOR;

   BEGIN

   v_buff := 'Loading MRP Plans ..... ';
   LOG_MESSAGE(v_buff);
   For c_rec in c1 LOOP
      lv_sql_stmt :=
      ' SELECT  count(*)'
      ||' FROM    MRP_PLANS'||v_dblink
      ||' WHERE   COMPILE_DESIGNATOR = :pDESIGNATOR '
      ||' AND     ORGANIZATION_ID = :organization_id '	;

      EXECUTE IMMEDIATE lv_sql_stmt
              INTO lv_count
              USING pDESIGNATOR,
                    c_rec.organization_id;
      lv_sql_stmt := NULL;
      IF lv_count = 0 then

        lv_sql_stmt :=
        ' INSERT INTO MRP_PLANS'||v_dblink
        ||' ( ORGANIZATION_ID              , '
        ||' COMPILE_DESIGNATOR             , '
        ||' LAST_UPDATE_DATE               , '
        ||' LAST_UPDATED_BY                , '
        ||' CREATION_DATE                  , '
        ||' CREATED_BY                     , '
        ||' LAST_UPDATE_LOGIN              , '
        ||' CURR_SCHEDULE_DESIGNATOR       , '
        ||' CURR_OPERATION_SCHEDULE_TYPE   , '
        ||' CURR_PLAN_TYPE                 , '
        ||' CURR_OVERWRITE_OPTION          , '
        ||' CURR_APPEND_PLANNED_ORDERS     , '
        ||' CURR_SCHEDULE_TYPE             , '
        ||' CURR_CUTOFF_DATE               , '
        ||' CURR_PART_INCLUDE_TYPE         , '
        ||' CURR_PLANNING_TIME_FENCE_FLAG  , '
        ||' CURR_DEMAND_TIME_FENCE_FLAG    , '
        ||' CURR_CONSIDER_RESERVATIONS     , '
        ||' CURR_PLAN_SAFETY_STOCK         , '
        ||' CURR_CONSIDER_WIP              , '
        ||' CURR_CONSIDER_PO               , '
        ||' CURR_SNAPSHOT_LOCK             , '
        ||' COMPILE_DEFINITION_DATE        , '
        ||' SCHEDULE_DESIGNATOR            , '
        ||' OPERATION_SCHEDULE_TYPE        , '
        ||' PLAN_TYPE                      , '
        ||' OVERWRITE_OPTION               , '
        ||' APPEND_PLANNED_ORDERS          , '
        ||' SCHEDULE_TYPE                  , '
        ||' CUTOFF_DATE                    , '
        ||' PART_INCLUDE_TYPE              , '
        ||' PLANNING_TIME_FENCE_FLAG       , '
        ||' DEMAND_TIME_FENCE_FLAG         , '
        ||' CONSIDER_RESERVATIONS          , '
        ||' PLAN_SAFETY_STOCK              , '
        ||' CONSIDER_WIP                   , '
        ||' CONSIDER_PO                    , '
        ||' SNAPSHOT_LOCK                  , '
        ||' DATA_START_DATE                , '
        ||' DATA_COMPLETION_DATE           , '
        ||' EXPLOSION_COMPLETION_DATE           , '
        ||' PLAN_START_DATE                , '
        ||' PLAN_COMPLETION_DATE           , '
        ||' DESCRIPTION                    , '
        ||' REQUEST_ID                     , '
        ||' PROGRAM_APPLICATION_ID         , '
        ||' PROGRAM_ID                     , '
        ||' PROGRAM_UPDATE_DATE            , '
        ||' ATTRIBUTE_CATEGORY             , '
        ||' ATTRIBUTE1                     , '
        ||' ATTRIBUTE2                     , '
        ||' ATTRIBUTE3                     , '
        ||' ATTRIBUTE4                     , '
        ||' ATTRIBUTE5                     , '
        ||' ATTRIBUTE6                     , '
        ||' ATTRIBUTE7                     , '
        ||' ATTRIBUTE8                     , '
        ||' ATTRIBUTE9                     , '
        ||' ATTRIBUTE10                    , '
        ||' ATTRIBUTE11                    , '
        ||' ATTRIBUTE12                    , '
        ||' ATTRIBUTE13                    , '
        ||' ATTRIBUTE14                    , '
        ||' ATTRIBUTE15                    , '
        ||' ONLINE_PLANNER_START_DATE               , '
        ||' ONLINE_PLANNER_COMPLETION_DATE          , '
        ||' CURR_FULL_PEGGING                       , '
        ||' FULL_PEGGING                            , '
        ||' ASSIGNMENT_SET_ID                       , '
        ||' CURR_ASSIGNMENT_SET_ID                  , '
        ||' ORGANIZATION_SELECTION                  , '
        ||' CURR_RESERVATION_LEVEL                  , '
        ||' CURR_HARD_PEGGING_LEVEL                 , '
        ||' RESERVATION_LEVEL                       , '
        ||' HARD_PEGGING_LEVEL                      ) '
        ||' SELECT '
        ||' ORGANIZATION_ID,'
        ||' COMPILE_DESIGNATOR             , '
        ||' LAST_UPDATE_DATE               , '
        ||' LAST_UPDATED_BY                , '
        ||' CREATION_DATE                  , '
        ||' CREATED_BY                     , '
        ||' LAST_UPDATE_LOGIN                       , '
        ||' CURR_SCHEDULE_DESIGNATOR                , '
        ||' CURR_OPERATION_SCHEDULE_TYPE   , '
        ||' CURR_PLAN_TYPE                 , '
        ||' CURR_OVERWRITE_OPTION          , '
        ||' CURR_APPEND_PLANNED_ORDERS     , '
        ||' CURR_SCHEDULE_TYPE                      , '
        ||' CURR_CUTOFF_DATE               , '
        ||' CURR_PART_INCLUDE_TYPE         , '
        ||' CURR_PLANNING_TIME_FENCE_FLAG  , '
        ||' CURR_DEMAND_TIME_FENCE_FLAG    , '
        ||' 1,'
        ||' 1,'
        ||' 1, '
        ||' 1,'
        ||' 1,'
        ||' SYSDATE, '
        ||' SCHEDULE_DESIGNATOR                     , '
        ||' OPERATION_SCHEDULE_TYPE                 , '
        ||' PLAN_TYPE                               , '
        ||' OVERWRITE_OPTION                        , '
        ||' APPEND_PLANNED_ORDERS                   , '
        ||' SCHEDULE_TYPE                           , '
        ||' CUTOFF_DATE                             , '
        ||' PART_INCLUDE_TYPE                       , '
        ||' PLANNING_TIME_FENCE_FLAG                , '
        ||' DEMAND_TIME_FENCE_FLAG                  , '
        ||' CONSIDER_RESERVATIONS                   , '
        ||' PLAN_SAFETY_STOCK                       , '
        ||' CONSIDER_WIP                            , '
        ||' CONSIDER_PO                             , '
        ||' SNAPSHOT_LOCK                           , '
        ||' DATA_START_DATE                         , '
        ||' DATA_COMPLETION_DATE                    , '
        ||' DATA_COMPLETION_DATE                    , '
        ||' PLAN_START_DATE                         , '
        ||' PLAN_COMPLETION_DATE                    , '
        ||' DESCRIPTION                             , '
        ||' REQUEST_ID                              , '
        ||' PROGRAM_APPLICATION_ID                  , '
        ||' PROGRAM_ID                              , '
        ||' PROGRAM_UPDATE_DATE                     , '
        ||' ATTRIBUTE_CATEGORY                      , '
        ||' ATTRIBUTE1                              , '
        ||' ATTRIBUTE2                              , '
        ||' ATTRIBUTE3                              , '
        ||' ATTRIBUTE4                              , '
        ||' ATTRIBUTE5                              , '
        ||' ATTRIBUTE6                              , '
        ||' ATTRIBUTE7                              , '
        ||' ATTRIBUTE8                              , '
        ||' ATTRIBUTE9                              , '
        ||' ATTRIBUTE10                             , '
        ||' ATTRIBUTE11                             , '
        ||' ATTRIBUTE12                             , '
        ||' ATTRIBUTE13                             , '
        ||' ATTRIBUTE14                             , '
        ||' ATTRIBUTE15                             , '
        ||' ONLINE_PLANNER_START_DATE               , '
        ||' ONLINE_PLANNER_COMPLETION_DATE          , '
        ||' CURR_FULL_PEGGING                       , '
        ||' FULL_PEGGING                            , '
        ||' ASSIGNMENT_SET_ID                       , '
        ||' CURR_ASSIGNMENT_SET_ID                  , '
        ||' ORGANIZATION_SELECTION                  , '
        ||' CURR_RESERVATION_LEVEL                  , '
        ||' CURR_HARD_PEGGING_LEVEL                 , '
        ||' RESERVATION_LEVEL                       , '
        ||' HARD_PEGGING_LEVEL                       '
        ||' FROM MSC_PLANS '
        ||' WHERE plan_id  <> -1 '
        ||' AND   plan_id = :plan_id '
        ||' AND   sr_instance_id = :pINSTANCE_ID '
        ||' AND   organization_id = :organization_id ';

        EXECUTE IMMEDIATE lv_sql_stmt
                USING c_rec.plan_id, pINSTANCE_ID,
                      c_rec.organization_id ;


        v_buff := 'Number of MRP Plans loaded : '||SQL%ROWCOUNT;
        LOG_MESSAGE(v_buff);

  /* 2208398 - If the plan exists, update the plan completion date and
  data_completion_date */

      ELSIF lv_count = 1 then

          lv_sql_stmt := ' SELECT plan_start_date'
          ||' FROM mrp_plans'|| v_dblink
          ||' WHERE   COMPILE_DESIGNATOR = :pDESIGNATOR '
          ||' AND     ORGANIZATION_ID = :organization_id1 ';

          EXECUTE IMMEDIATE lv_sql_stmt INTO lv_previous_plan_start_date USING pDESIGNATOR, c_rec.organization_id;

            IF c_rec.plan_start_date > lv_previous_plan_start_date THEN

                IF (pORGANIZATION_ID IS NOT NULL) OR
                   (pPLANNER IS NOT NULL) OR
                   (pCATEGORY_ID IS NOT NULL) OR
                   (pITEM_ID IS NOT NULL) OR
                   (pSUPPLIER_ID IS NOT NULL) OR
                   (pSUPPLIER_SITE_ID IS NOT NULL) OR
                   (pHORIZON_START_DATE IS NOT NULL) OR
                   (pHORIZON_END_DATE IS NOT NULL) THEN

                  FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_INCONSISTENT_DATA');
                  FND_MESSAGE.SET_TOKEN('DESIGNATOR', pDESIGNATOR);
                  FND_MESSAGE.SET_TOKEN('PREVIOUS_PLAN_RUN_DATE', to_char(lv_previous_plan_start_date));
                  FND_MESSAGE.SET_TOKEN('CURRENT_PLAN_RUN_DATE', to_char(c_rec.plan_start_date));

                  v_retcode := G_WARNING;
                  LOG_MESSAGE('------------------------------------------------------------------------');
                  LOG_MESSAGE(FND_MESSAGE.GET);
                  LOG_MESSAGE('------------------------------------------------------------------------');

                END IF;

            END IF;

        lv_sql_stmt := 'update mrp_plans'|| v_dblink
                       ||' set (plan_start_date,plan_completion_date,data_completion_date) = '
                       ||' (select plan_start_date,plan_completion_date, data_completion_date '
                       ||' from msc_plans'
                       ||' where plan_id <> -1'
                       ||' and plan_id = :plan_id '
                       ||' AND   sr_instance_id = :pINSTANCE_ID '
                       ||' AND   organization_id = :organization_id) '
                       ||' WHERE   COMPILE_DESIGNATOR = :pDESIGNATOR '
                       ||' AND     ORGANIZATION_ID = :organization_id1 ';

        EXECUTE IMMEDIATE lv_sql_stmt
                USING c_rec.plan_id, pINSTANCE_ID,
                      c_rec.organization_id, pDESIGNATOR,
                    c_rec.organization_id;

        v_buff := 'Number of MRP Plans updated : '||SQL%ROWCOUNT;
        LOG_MESSAGE(v_buff);

      ELSE
        v_buff := ' More than one Plan : '||pDESIGNATOR||':'||c_rec.organization_id|| ' exists on source ';
        LOG_MESSAGE(v_buff);

      END IF;

      END LOOP;
      COMMIT;

      RETURN TRUE;

      EXCEPTION
        WHEN OTHERS THEN

          v_retcode := G_ERROR;
          v_errbuf := SQLERRM;
          LOG_MESSAGE(SQLERRM);
          RAISE;
          RETURN FALSE;

   END; --ins_mrp_plan
--====================Insert Plan Organizations===============================

   FUNCTION ins_mrp_plan_org(pINSTANCE_ID NUMBER,
                             pDESIGNATOR  VARCHAR2,
                             pORGANIZATION_ID NUMBER)
   RETURN BOOLEAN
   IS
        lv_count 	number :=0;
        lv_sql_stmt     varchar2(9000):=NULL;
        lv_planned_org 	number;
        lv_plan_level 	number ;
   CURSOR c1 IS
        select organization_id ,plan_id
        from   msc_plans
        where  sr_instance_id = pINSTANCE_ID
        and    compile_designator = pDESIGNATOR;
   CURSOR c2 (c_plan_id number)  IS
        select organization_id
        from   msc_plan_organizations
        where  sr_instance_id = pINSTANCE_ID
        and    organization_id = nvl(pORGANIZATION_ID,organization_id)
        and    plan_id = c_plan_id;

   BEGIN

      v_buff := 'Loading MRP Plan Organizations ..... ';
      LOG_MESSAGE(v_buff);

      FOR c_rec in c1 LOOP
       FOR c_rec1 in c2(c_rec.plan_id) LOOP
       lv_sql_stmt :=
       ' SELECT  count(*)'
       ||' FROM    MRP_PLAN_ORGANIZATIONS'||v_dblink
       ||' WHERE   COMPILE_DESIGNATOR = :pDESIGNATOR '
       ||' AND     ORGANIZATION_ID    = :organization_id'
       ||' AND     PLANNED_ORGANIZATION    = :organization_id1 '	;

      EXECUTE IMMEDIATE lv_sql_stmt
              INTO lv_count
              USING pDESIGNATOR,
                    c_rec.organization_id,
                    c_rec1.organization_id;

      lv_sql_stmt := NULL;
      IF lv_count = 0 then
        v_sql_stmt :=
           ' INSERT INTO MRP_PLAN_ORGANIZATIONS'||v_dblink
           ||' (ORGANIZATION_ID                ,'
           ||' COMPILE_DESIGNATOR              ,'
           ||' PLANNED_ORGANIZATION            ,'
           ||' PLAN_LEVEL                      ,'
           ||' LAST_UPDATED_BY                 ,'
           ||' LAST_UPDATE_DATE                ,'
           ||' CREATED_BY                      ,'
           ||' CREATION_DATE                   ,'
           ||' LAST_UPDATE_LOGIN                        ,'
           ||' NET_WIP                         ,'
           ||' NET_RESERVATIONS                ,'
           ||' NET_PURCHASING                  ,'
           ||' PLAN_SAFETY_STOCK               ,'
           ||' REQUEST_ID                               ,'
           ||' PROGRAM_APPLICATION_ID                   ,'
           ||' PROGRAM_ID                               ,'
           ||' PROGRAM_UPDATE_DATE                      ,'
           ||' ATTRIBUTE_CATEGORY                       ,'
           ||' ATTRIBUTE1                               ,'
           ||' ATTRIBUTE2                               ,'
           ||' ATTRIBUTE3                               ,'
           ||' ATTRIBUTE4                               ,'
           ||' ATTRIBUTE5                               ,'
           ||' ATTRIBUTE6                               ,'
           ||' ATTRIBUTE7                               ,'
           ||' ATTRIBUTE8                               ,'
           ||' ATTRIBUTE9                               ,'
           ||' ATTRIBUTE10                              ,'
           ||' ATTRIBUTE11                              ,'
           ||' ATTRIBUTE12                              ,'
           ||' ATTRIBUTE13                              ,'
           ||' ATTRIBUTE14                              ,'
           ||' ATTRIBUTE15                             ) '
           ||'SELECT '
           ||' :organization_id                 ,'
           ||' :pDESIGNATOR, '
           ||' ORGANIZATION_ID,'
           ||' PLAN_LEVEL                      ,'
           ||' LAST_UPDATED_BY                 ,'
           ||' LAST_UPDATE_DATE                ,'
           ||' CREATED_BY                      ,'
           ||' CREATION_DATE                   ,'
           ||' LAST_UPDATE_LOGIN                        ,'
           ||' NET_WIP                         ,'
           ||' NET_RESERVATIONS                ,'
           ||' NET_PURCHASING                  ,'
           ||' PLAN_SAFETY_STOCK               ,'
           ||' REQUEST_ID                               ,'
           ||' PROGRAM_APPLICATION_ID                   ,'
           ||' PROGRAM_ID                               ,'
           ||' PROGRAM_UPDATE_DATE                      ,'
           ||' ATTRIBUTE_CATEGORY                       ,'
           ||' ATTRIBUTE1                               ,'
           ||' ATTRIBUTE2                               ,'
           ||' ATTRIBUTE3                               ,'
           ||' ATTRIBUTE4                               ,'
           ||' ATTRIBUTE5                               ,'
           ||' ATTRIBUTE6                               ,'
           ||' ATTRIBUTE7                               ,'
           ||' ATTRIBUTE8                               ,'
           ||' ATTRIBUTE9                               ,'
           ||' ATTRIBUTE10                              ,'
           ||' ATTRIBUTE11                              ,'
           ||' ATTRIBUTE12                              ,'
           ||' ATTRIBUTE13                              ,'
           ||' ATTRIBUTE14                              ,'
           ||' ATTRIBUTE15                              '
           ||'FROM MSC_PLAN_ORGANIZATIONS '
           ||'WHERE plan_id = :plan_id '
           ||'AND   sr_instance_id = :pINSTANCE_ID '
           ||' AND   organization_id = :organization_id1 ';

          EXECUTE IMMEDIATE v_sql_stmt
                  USING c_rec.organization_id,
                        pDESIGNATOR,
                        c_rec.plan_id,
                        pINSTANCE_ID ,
                        c_rec1.organization_id;

       v_buff := ' Plan Organizations loaded : '||c_rec1.organization_id||': '||SQL%ROWCOUNT ;
       LOG_MESSAGE(v_buff);

       ELSE

        v_buff := ' Plan Organization: '||pDESIGNATOR||':'||c_rec1.organization_id|| ' already exists on source ';
        LOG_MESSAGE(v_buff);

       END IF; -- lv_count is 0
       END LOOP; -- crec1
      END LOOP; -- crec

      COMMIT;
      RETURN TRUE;

      EXCEPTION
        WHEN OTHERS THEN
          v_retcode := G_ERROR;
          v_errbuf := SQLERRM;
          LOG_MESSAGE(SQLERRM);
          RAISE;
          RETURN FALSE;

   END; --ins_mrp_plan_org

--===================Insert Designator Information=============================

   FUNCTION ins_mrp_designators    (pINSTANCE_ID NUMBER,
                                    pDESIGNATOR  VARCHAR2,
                                    pPLAN_TYPE   VARCHAR2)
   RETURN BOOLEAN
   IS
	lv_count 	number :=0;
        lv_sql_stmt 	varchar2(9000) :=NULL;
        lv_pplan_type   number :=0;
   CURSOR c1 IS
        select organization_id
        from   msc_plans
        where  sr_instance_id = pINSTANCE_ID
        and    compile_designator = pDESIGNATOR;
    CURSOR c2(c_org_id in number) is
         SELECT PRODUCTION , ORGANIZATION_ID, DESIGNATOR_TYPE,
                LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN
         FROM MSC_DESIGNATORS
         WHERE designator =  pDESIGNATOR
         AND   sr_instance_id = pINSTANCE_ID
         AND   organization_id = c_org_id
         AND   designator_type <> G_MPS_IND;
   CURSOR c3(c_org_id in number) is
         SELECT PRODUCTION , ORGANIZATION_ID, DESIGNATOR_TYPE,
                LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN
         FROM MSC_DESIGNATORS
         WHERE designator =  pDESIGNATOR
         AND   sr_instance_id = pINSTANCE_ID
         AND   organization_id = c_org_id
         AND   designator_type = G_MPS_IND;
   BEGIN
    lv_pplan_type := TO_NUMBER (pPLAN_TYPE);

    IF lv_pplan_type <> G_MPS_IND THEN
      v_buff := 'Loading Compile Designators..... ';
      LOG_MESSAGE(v_buff);
      FOR c_rec in c1 LOOP
      lv_sql_stmt :=
      ' SELECT  count(*)'
      ||' FROM    MRP_DESIGNATORS'||v_dblink
      ||' WHERE   COMPILE_DESIGNATOR = :pDESIGNATOR '
      ||' AND     ORGANIZATION_ID    = :organization_id	';


      EXECUTE IMMEDIATE lv_sql_stmt
              INTO  lv_count
              USING pDESIGNATOR,
                    c_rec.organization_id;
      v_buff := 'Loading Compile Designators2 ..... '||lv_count;
      LOG_MESSAGE(v_buff);
      lv_sql_stmt := NULL;

      IF lv_count = 0 then

        lv_sql_stmt :=
        ' INSERT INTO MRP_DESIGNATORS'||v_dblink
        ||' (COMPILE_DESIGNATOR             , '
        ||' ORGANIZATION_ID                , '
        ||' LAST_UPDATE_DATE               ,'
        ||' LAST_UPDATED_BY                , '
        ||' CREATION_DATE                  , '
        ||' CREATED_BY                     , '
        ||' LAST_UPDATE_LOGIN                       , '
        ||' DESCRIPTION                             , '
        ||' DISABLE_DATE                            , '
        ||' FEEDBACK_FLAG                  , '
        ||' REQUEST_ID                              , '
        ||' PROGRAM_APPLICATION_ID                  , '
        ||' PROGRAM_ID                              , '
        ||' PROGRAM_UPDATE_DATE                     , '
        ||' ATTRIBUTE_CATEGORY                      , '
        ||' ATTRIBUTE1                              , '
        ||' ATTRIBUTE2                              , '
        ||' ATTRIBUTE3                              , '
        ||' ATTRIBUTE4                              , '
        ||' ATTRIBUTE5                              , '
        ||' ATTRIBUTE6                              , '
        ||' ATTRIBUTE7                              , '
        ||' ATTRIBUTE8                              , '
        ||' ATTRIBUTE9                              , '
        ||' ATTRIBUTE10                             , '
        ||' ATTRIBUTE11                             , '
        ||' ATTRIBUTE12                             , '
        ||' ATTRIBUTE13                             , '
        ||' ATTRIBUTE14                             , '
        ||' ATTRIBUTE15                             , '
        ||' ORGANIZATION_SELECTION                  , '
        ||' DRP_PLAN				    , '
        ||' PRODUCTION                              )'
        ||'SELECT  '
        ||' DESIGNATOR             , '
        ||' ORGANIZATION_ID                , '
        ||' LAST_UPDATE_DATE               , '
        ||' LAST_UPDATED_BY                , '
        ||' CREATION_DATE                  , '
        ||' CREATED_BY                     , '
        ||' LAST_UPDATE_LOGIN                       , '
        ||' DESCRIPTION                             , '
        ||' DISABLE_DATE                            , '
        ||' 1, '
        ||' REQUEST_ID                              , '
        ||' PROGRAM_APPLICATION_ID                  , '
        ||' PROGRAM_ID                              , '
        ||' PROGRAM_UPDATE_DATE                     , '
        ||' ATTRIBUTE_CATEGORY                      , '
        ||' ATTRIBUTE1                              , '
        ||' ATTRIBUTE2                              , '
        ||' ATTRIBUTE3                              , '
        ||' ATTRIBUTE4                              , '
        ||' ATTRIBUTE5                              , '
        ||' ATTRIBUTE6                              , '
        ||' ATTRIBUTE7                              , '
        ||' ATTRIBUTE8                              , '
        ||' ATTRIBUTE9                              , '
        ||' ATTRIBUTE10                             , '
        ||' ATTRIBUTE11                             , '
        ||' ATTRIBUTE12                             , '
        ||' ATTRIBUTE13                             , '
        ||' ATTRIBUTE14                             , '
        ||' ATTRIBUTE15                             , '
        ||' ORGANIZATION_SELECTION                  , '
        ||' DECODE(DESIGNATOR_TYPE,4,1,2)           ,'
        ||' PRODUCTION                              '
        ||' FROM MSC_DESIGNATORS '
        ||' WHERE designator =  :pDESIGNATOR '
        ||' AND   sr_instance_id = :pINSTANCE_ID '
        ||' AND   organization_id = :organization_id '
        ||' AND   designator_type <> '|| G_MPS_IND;

      EXECUTE IMMEDIATE lv_sql_stmt
              USING pDESIGNATOR,
                    pINSTANCE_ID,
                    c_rec.organization_id;

        v_buff := 'Number of Compile Designators loaded : '||SQL%ROWCOUNT;
        LOG_MESSAGE(v_buff);

      ELSE
       FOR c_rec1 in c2 (c_rec.organization_id)
       LOOP
         lv_sql_stmt :=
         ' UPDATE MRP_DESIGNATORS'||v_dblink
         ||' SET PRODUCTION = :production '
         ||'     , DRP_PLAN = DECODE(:designator_type,4,1,2)'
         ||'     , LAST_UPDATE_DATE = :LAST_UPDATE_DATE'
         ||'     , LAST_UPDATED_BY = :LAST_UPDATED_BY'
         ||'     , LAST_UPDATE_LOGIN = :LAST_UPDATE_LOGIN'
         ||' WHERE COMPILE_DESIGNATOR = :pDESIGNATOR '
         ||' AND ORGANIZATION_ID = :organization_id ';

             EXECUTE IMMEDIATE lv_sql_stmt
              USING c_rec1.production,
                    c_rec1.designator_type,
                    c_rec1.LAST_UPDATE_DATE,
                    c_rec1.LAST_UPDATED_BY,
                    c_rec1.LAST_UPDATE_LOGIN,
                    pDESIGNATOR,
                    c_rec1.organization_id;

       END LOOP;
       v_buff := ' Compile Designator : '||pDESIGNATOR||':'||c_rec.organization_id|| ' already exists on source ';
       LOG_MESSAGE(v_buff);

      END IF;
      END LOOP;

      ELSE

      v_buff := 'Loading Schedule Designators..... ';
      LOG_MESSAGE(v_buff);
      FOR c_rec in c1 LOOP
      lv_sql_stmt :=
      ' SELECT  count(*)'
      ||' FROM    MRP_SCHEDULE_DESIGNATORS'||v_dblink
      ||' WHERE   SCHEDULE_DESIGNATOR = :pDESIGNATOR '
      ||' AND     ORGANIZATION_ID    = :organization_id	';


      EXECUTE IMMEDIATE lv_sql_stmt
              INTO  lv_count
              USING pDESIGNATOR,
                    c_rec.organization_id;
      v_buff := 'Loading Schedule Designators2 ..... '||lv_count;
      LOG_MESSAGE(v_buff);

      lv_sql_stmt := NULL;

      IF lv_count = 0 then

        lv_sql_stmt :=
        ' INSERT INTO MRP_SCHEDULE_DESIGNATORS'||v_dblink
        ||' (SCHEDULE_DESIGNATOR                    , '
        ||' ORGANIZATION_ID                         , '
        ||' LAST_UPDATE_DATE                        , '
        ||' LAST_UPDATED_BY                         , '
        ||' CREATION_DATE                           , '
        ||' CREATED_BY                              , '
        ||' LAST_UPDATE_LOGIN                       , '
        ||' DESCRIPTION                             , '
        ||' DISABLE_DATE                            , '
        ||' MPS_RELIEF                              , '
        ||' REQUEST_ID                              , '
        ||' PROGRAM_APPLICATION_ID                  , '
        ||' PROGRAM_ID                              , '
        ||' PROGRAM_UPDATE_DATE                     , '
        ||' ATTRIBUTE_CATEGORY                      , '
        ||' ATTRIBUTE1                              , '
        ||' ATTRIBUTE2                              , '
        ||' ATTRIBUTE3                              , '
        ||' ATTRIBUTE4                              , '
        ||' ATTRIBUTE5                              , '
        ||' ATTRIBUTE6                              , '
        ||' ATTRIBUTE7                              , '
        ||' ATTRIBUTE8                              , '
        ||' ATTRIBUTE9                              , '
        ||' ATTRIBUTE10                             , '
        ||' ATTRIBUTE11                             , '
        ||' ATTRIBUTE12                             , '
        ||' ATTRIBUTE13                             , '
        ||' ATTRIBUTE14                             , '
        ||' ATTRIBUTE15                             , '
        ||' ORGANIZATION_SELECTION                  , '
        ||' SCHEDULE_TYPE			    , '
        ||' INVENTORY_ATP_FLAG                      , '
        ||' DEMAND_CLASS                            , '
        ||' PRODUCTION                              )'
        ||'SELECT  '
        ||' DESIGNATOR                              , '
        ||' ORGANIZATION_ID                         , '
        ||' LAST_UPDATE_DATE                        , '
        ||' LAST_UPDATED_BY                         , '
        ||' CREATION_DATE                           , '
        ||' CREATED_BY                              , '
        ||' LAST_UPDATE_LOGIN                       , '
        ||' DESCRIPTION                             , '
        ||' DISABLE_DATE                            , '
        ||' MPS_RELIEF                              , '
        ||' REQUEST_ID                              , '
        ||' PROGRAM_APPLICATION_ID                  , '
        ||' PROGRAM_ID                              , '
        ||' PROGRAM_UPDATE_DATE                     , '
        ||' ATTRIBUTE_CATEGORY                      , '
        ||' ATTRIBUTE1                              , '
        ||' ATTRIBUTE2                              , '
        ||' ATTRIBUTE3                              , '
        ||' ATTRIBUTE4                              , '
        ||' ATTRIBUTE5                              , '
        ||' ATTRIBUTE6                              , '
        ||' ATTRIBUTE7                              , '
        ||' ATTRIBUTE8                              , '
        ||' ATTRIBUTE9                              , '
        ||' ATTRIBUTE10                             , '
        ||' ATTRIBUTE11                             , '
        ||' ATTRIBUTE12                             , '
        ||' ATTRIBUTE13                             , '
        ||' ATTRIBUTE14                             , '
        ||' ATTRIBUTE15                             , '
        ||' ORGANIZATION_SELECTION                  , '
        ||  G_MPS_IND                           ||' , '
        ||' INVENTORY_ATP_FLAG                      , '
        ||' DEMAND_CLASS                            , '
        ||' PRODUCTION                                '
        ||' FROM MSC_DESIGNATORS '
        ||' WHERE designator =  :pDESIGNATOR '
        ||' AND   sr_instance_id = :pINSTANCE_ID '
        ||' AND   organization_id = :organization_id '
        ||' AND   designator_type = ' || G_MPS_IND;

      EXECUTE IMMEDIATE lv_sql_stmt
              USING pDESIGNATOR,
                    pINSTANCE_ID,
                    c_rec.organization_id;

        v_buff := 'Number of Schedule Designators loaded : '||SQL%ROWCOUNT;
        LOG_MESSAGE(v_buff);

      ELSE
       FOR c_rec1 in c3(c_rec.organization_id)
       LOOP

         lv_sql_stmt :=
         ' UPDATE MRP_SCHEDULE_DESIGNATORS'||v_dblink
         ||' SET PRODUCTION = :production '
         ||'     , LAST_UPDATE_DATE = :LAST_UPDATE_DATE'
         ||'     , LAST_UPDATED_BY = :LAST_UPDATED_BY'
         ||'     , LAST_UPDATE_LOGIN = :LAST_UPDATE_LOGIN'
         ||' WHERE SCHEDULE_DESIGNATOR = :pDESIGNATOR '
         ||' AND   ORGANIZATION_ID = :organization_id '
         ||' AND   SCHEDULE_TYPE = ' || G_MPS_IND;
             EXECUTE IMMEDIATE lv_sql_stmt
              USING c_rec1.production,
                    c_rec1.LAST_UPDATE_DATE,
                    c_rec1.LAST_UPDATED_BY,
                    c_rec1.LAST_UPDATE_LOGIN,
                    pDESIGNATOR,
                    c_rec1.organization_id;

       END LOOP;
       v_buff := ' Schdule Designator : '||pDESIGNATOR||':'||c_rec.organization_id|| ' already exists on source ';
       LOG_MESSAGE(v_buff);

      END IF;
      END LOOP;
    END IF;


      COMMIT;
      RETURN TRUE;

      EXCEPTION
        WHEN OTHERS THEN
          v_retcode := G_ERROR;
          v_errbuf := SQLERRM;
          LOG_MESSAGE(SQLERRM);
          RAISE;
          RETURN FALSE;

   END; --ins_mrp_designators

--=====================End of Private Routines=============================

--=====================Public Routine===================================

   PROCEDURE PUSH_PLAN_INFO( ERRBUF		 	       OUT NOCOPY VARCHAR2,
 		             RETCODE			       OUT NOCOPY NUMBER,
                             pINSTANCE_ID                       IN  NUMBER,
			     pPLAN_TYPE                         IN  VARCHAR2, -- dummy arg
                             pDESIGNATOR                        IN  VARCHAR2,
                             pBUY_ORDERS_ONLY                   IN  NUMBER,
                             pDEMAND                            IN  NUMBER default 1, --for bug 3073566
                             pORGANIZATION_ID                   IN  NUMBER,
                             pPLANNER                           IN  VARCHAR2,
                             pCATEGORY_ID                       IN  NUMBER,
                             pITEM_ID                           IN  NUMBER,
                             pDUMMY2                            IN  NUMBER,
                             pSUPPLIER_ID                       IN  NUMBER,
                             pDUMMY3                            IN  NUMBER,
                             pSUPPLIER_SITE_ID                  IN  NUMBER,
                             pHORIZON_START_DATE                IN  VARCHAR2,
                             pHORIZON_END_DATE                  IN  VARCHAR2)
   IS

   lv_apps_ver                  NUMBER;
   lv_sql_stmt                  VARCHAR2(20000);
   lv_sql_stmt1                 VARCHAR2(20000);
   lv_items_stmt                VARCHAR2(5000);
   lv_is_supp_null              VARCHAR2(150):=NULL;
   lv_is_supp_not_null          VARCHAR2(150):=NULL;
   lv_buy_count                 NUMBER := 0;
   v_total_make_count           NUMBER := 0;
   v_total_buy_count            NUMBER := 0;
   v_total_buy_count1           NUMBER := 0;
   v_total_count                NUMBER := 0;
   v_total_mgr_count            NUMBER := 0;
   v_item_count                 NUMBER := 0;
   ignore                       NUMBER := 0;
   cursor1                      NUMBER := 0;
   lv_sr_tp_id                  NUMBER;
   lv_sr_tp_site_id             NUMBER;
   lv_start_date                DATE;
   lv_end_date                  DATE;
   lv_LANG                      VARCHAR2(20) :=USERENV('LANG');
   lv_organization_id           NUMBER;
   lv_user_id										NUMBER;
   CURSOR c1 IS
        select plan_id
        from   msc_plans
        where  sr_instance_id = pINSTANCE_ID
        and    compile_designator = pDESIGNATOR;
   CURSOR c2 (c_plan_id number)  IS
        select organization_id
        from   msc_plan_organizations
        where  sr_instance_id = pINSTANCE_ID
        and    organization_id = nvl(pORGANIZATION_ID,organization_id)
        and    plan_id = c_plan_id;
   CURSOR c3 (c_plan_id number) IS
        select count(*) from MSC_SUPPLIES  ms
        where ms.plan_id = c_plan_id
        and ms.sr_instance_id = pINSTANCE_ID
        and ms.order_type = 5
        AND nvl(ms.source_supplier_id,ms.supplier_id) is NOT NULL
        AND nvl(ms.source_supplier_site_id,ms.supplier_site_id) is NOT NULL;

   A2A_EXCEPTION                EXCEPTION;  -- for outbound XML

   BEGIN --Main

   LOG_MESSAGE('pINSTANCE_ID         : '||pINSTANCE_ID);
   LOG_MESSAGE('pPLAN_TYPE           : '||pPLAN_TYPE);
   LOG_MESSAGE('pDESIGNATOR          : '||pDESIGNATOR);
   LOG_MESSAGE('pBUY_ORDERS_ONLY     : '||pBUY_ORDERS_ONLY);
   LOG_MESSAGE('pDEMAND              : '||pDEMAND);
   LOG_MESSAGE('pORGANIZATION_ID     : '||pORGANIZATION_ID);
   LOG_MESSAGE('pPLANNER             : '||pPLANNER);
   LOG_MESSAGE('pCATEGORY_ID         : '||pCATEGORY_ID);
   LOG_MESSAGE('pITEM_ID             : '||pITEM_ID);
   LOG_MESSAGE('pSUPPLIER_ID         : '||pSUPPLIER_ID);
   LOG_MESSAGE('pSUPPLIER_SITE_ID    : '||pSUPPLIER_SITE_ID);
   LOG_MESSAGE('pHORIZON_START_DATE  : '||pHORIZON_START_DATE);
   LOG_MESSAGE('pHORIZON_END_DATE    : '||pHORIZON_END_DATE);
   LOG_MESSAGE('------------------------------------------------------------------------');

      lv_apps_ver :=-1;
      RETCODE := G_SUCCESS;
      ERRBUF := NULL;

      BEGIN
         SELECT DECODE( M2A_DBLINK,
                        NULL, NULL_DBLINK,
                        '@'||M2A_DBLINK),
                DECODE( M2A_DBLINK,
                        NULL, SYS_NO,
                        SYS_YES),
                APPS_VER,
                INSTANCE_TYPE  -- For outbound XML
           INTO v_dblink,
                v_distributed_config_flag,
                lv_apps_ver,
                v_ins_type  -- For outbound XML
           FROM MSC_APPS_INSTANCES
          WHERE INSTANCE_ID= pINSTANCE_ID;
      EXCEPTION

         WHEN NO_DATA_FOUND THEN

            RETCODE := G_ERROR;

            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_INVALID_INSTANCE_ID');
            FND_MESSAGE.SET_TOKEN('INSTANCE_ID', pINSTANCE_ID);
            ERRBUF:= FND_MESSAGE.GET;

            RETURN;

         WHEN OTHERS THEN
            RAISE;

      END;

   IF pHORIZON_START_DATE IS NULL THEN
        lv_start_date := TRUNC(to_date(1, 'j')) ;
   ELSE
       lv_start_date := fnd_date.canonical_to_date(pHORIZON_START_DATE);
   END IF;

   IF pHORIZON_END_DATE IS NULL THEN
        lv_end_date := TRUNC(to_date(3442447, 'j')) ;
   ELSE
       lv_end_date := fnd_date.canonical_to_date(pHORIZON_END_DATE);
   END IF;


  IF pSUPPLIER_ID IS NOT NULL THEN
         select sr_tp_id into lv_sr_tp_id
         from msc_trading_partners
         where sr_instance_id = pINSTANCE_ID
         and partner_id = pSUPPLIER_ID;
  END IF;

  IF pSUPPLIER_SITE_ID IS NOT NULL THEN
     select sr_tp_site_id into lv_sr_tp_site_id
     from msc_trading_partner_sites
     where partner_id = pSUPPLIER_ID
     and partner_site_id = pSUPPLIER_SITE_ID
     and sr_instance_id = pINSTANCE_ID;
  END IF;

-- For Outbound XML
     IF v_ins_type in (3,5) THEN
/*
            IF pBUY_ORDERS_ONLY <> SYS_YES  THEN

            lv_sql_stmt:=
            ' BEGIN'
          ||' MSC_A2A_XML_WF.PUSH_PLAN_OUTPUT(p_map_code      => ''MSC_PLANSCHDO_OAG71_OUT'',
                                         p_compile_designator => :pDESIGNATOR ,
                                         p_instance_id        => :pINSTANCE_ID ,
                                         p_buy_items_only     => :pBUY_ORDERS_ONLY );'
          ||' END;';

            EXECUTE IMMEDIATE lv_sql_stmt USING pDESIGNATOR,pINSTANCE_ID, pBUY_ORDERS_ONLY;

            RAISE A2A_EXCEPTION;
*/

         FOR c_rec in c1 LOOP
            lv_buy_count := 0;

            IF pBUY_ORDERS_ONLY = SYS_YES THEN -- send xml only if supplier/ site exists for PO
              OPEN C3 (c_rec.plan_id);
              FETCH C3 into lv_buy_count;
              CLOSE C3;

            ELSE
              lv_buy_count := 1; -- always send xml
            END IF;

            IF lv_buy_count > 0 THEN
               lv_sql_stmt:=
                  ' BEGIN'
                ||' MSC_A2A_XML_WF.PUSH_PLAN_OUTPUT(p_map_code      => ''MSC_PLANSCHDO_OAG71_OUT'',
                                         p_compile_designator => :pDESIGNATOR ,
                                         p_instance_id        => :pINSTANCE_ID ,
                                         p_buy_items_only     => :pBUY_ORDERS_ONLY );'
                ||' END;';

                EXECUTE IMMEDIATE lv_sql_stmt USING pDESIGNATOR,pINSTANCE_ID, pBUY_ORDERS_ONLY;

            ELSE
               fnd_message.set_name ('MSC', 'MSC_BUYORDER_NOT_FOUND');
               fnd_message.set_token ('PLAN_NAME', pDESIGNATOR);
               LOG_MESSAGE(fnd_message.get);
            END IF;
         END LOOP;

         RAISE A2A_EXCEPTION;

     END IF;



      IF ins_mrp_plan(pINSTANCE_ID, pDESIGNATOR, pORGANIZATION_ID, pPLANNER, pCATEGORY_ID, pITEM_ID, pSUPPLIER_ID,
                      pSUPPLIER_SITE_ID, pHORIZON_START_DATE, pHORIZON_END_DATE) AND
         ins_mrp_plan_org (pINSTANCE_ID, pDESIGNATOR, pORGANIZATION_ID) AND
         --3771736 Added AND ins_mrp_designators one more parameter pPLAN_TYPE
         ins_mrp_designators(pINSTANCE_ID, pDESIGNATOR, pPLAN_TYPE)  THEN
         --3771736

         RETCODE := v_retcode;

         v_buff := 'Deleting Recommendations and Items and Gross Requirements..... ';
         LOG_MESSAGE(v_buff);

BEGIN
/* Begin Delete Recommendations */

       lv_sql_stmt :=
           'DELETE FROM MRP_RECOMMENDATIONS'||v_dblink||' MRO'
           ||' WHERE MRO.COMPILE_DESIGNATOR = :pDESIGNATOR '
           ||' AND MRO.ORGANIZATION_ID IN (SELECT MPOV.PLANNED_ORGANIZATION'
           ||' FROM MSC_PLAN_ORGANIZATIONS_V MPOV'
           ||' WHERE MPOV.SR_INSTANCE_ID = :pINSTANCE_ID'
           ||' AND MPOV.COMPILE_DESIGNATOR = :pDESIGNATOR)';

       IF pORGANIZATION_ID IS NOT NULL THEN
          lv_sql_stmt := lv_sql_stmt || ' AND MRO.ORGANIZATION_ID = :pORGANIZATION_ID';
       END IF;

       IF pPLANNER IS NOT NULL THEN

          lv_items_stmt :=
                         ' AND EXISTS (SELECT 1 FROM MTL_SYSTEM_ITEMS'||v_dblink||' MSI'
           ||' WHERE MSI.INVENTORY_ITEM_ID = MRO.INVENTORY_ITEM_ID'
           ||' AND MSI.ORGANIZATION_ID = MRO.ORGANIZATION_ID'
           ||' AND MSI.PLANNER_CODE = :pPLANNER)';

       END IF;


       IF pITEM_ID IS NOT NULL THEN

          IF pPLANNER IS NOT NULL THEN
             lv_items_stmt := SUBSTR(lv_items_stmt,1,LENGTH(lv_items_stmt)-1) || ' AND MSI.INVENTORY_ITEM_ID = :pITEM_ID)';
          ELSE
             lv_items_stmt := ' AND MRO.INVENTORY_ITEM_ID = :pITEM_ID';
          END IF;

       END IF;

       lv_sql_stmt := lv_sql_stmt || lv_items_stmt;

       IF pCATEGORY_ID IS NOT NULL THEN
          lv_sql_stmt := lv_sql_stmt
                         ||' AND EXISTS (SELECT 1 FROM MRP_AP_ITEM_CATEGORIES_V'||v_dblink||' MAICV, MRP_AP_CATEGORY_SETS_V'||v_dblink||' MACSV'
                         ||'  WHERE MAICV.INVENTORY_ITEM_ID = MRO.INVENTORY_ITEM_ID AND MAICV.ORGANIZATION_ID ='
                         ||'  MRO.ORGANIZATION_ID AND MAICV.CATEGORY_ID = :pCATEGORY_ID'
                         ||'  AND MAICV.CATEGORY_SET_ID = MACSV.CATEGORY_SET_ID'
                         ||'  AND MAICV.LANGUAGE = MACSV.LANGUAGE'
                         ||'  AND MACSV.LANGUAGE = :pLANG'
                         ||'  AND MACSV.DEFAULT_FLAG = 1)';
       END IF;

       IF pSUPPLIER_ID IS NOT NULL THEN
          lv_sql_stmt := lv_sql_stmt || ' AND MRO.SOURCE_VENDOR_ID = :pSUPPLIER_ID';
       END IF;

       IF pSUPPLIER_SITE_ID IS NOT NULL THEN
          lv_sql_stmt := lv_sql_stmt || ' AND MRO.SOURCE_VENDOR_SITE_ID IN '||
          '(SELECT SR_TP_SITE_ID ' ||
          'FROM MSC_TP_SITE_ID_LID ' ||
          'WHERE SR_INSTANCE_ID = :pINSTANCE_ID '||
          'AND PARTNER_TYPE = 1  '||
          'AND   TP_SITE_ID = :pSUPPLIER_SITE_ID)';
       END IF;

       lv_sql_stmt := lv_sql_stmt || ' AND trunc(MRO.NEW_SCHEDULE_DATE) BETWEEN (:pHORIZON_START_DATE) and (:pHORIZON_END_DATE)';



           cursor1 := dbms_sql.open_cursor;
           dbms_sql.parse(cursor1, lv_sql_stmt, dbms_sql.v7);

           dbms_sql.bind_variable(cursor1, ':pDESIGNATOR', pDESIGNATOR);
           dbms_sql.bind_variable(cursor1, ':pINSTANCE_ID', pINSTANCE_ID);
           dbms_sql.bind_variable(cursor1, ':pDESIGNATOR', pDESIGNATOR);

           IF pORGANIZATION_ID IS NOT NULL THEN
              dbms_sql.bind_variable(cursor1, ':pORGANIZATION_ID', pORGANIZATION_ID);
           END IF;

           IF pPLANNER IS NOT NULL THEN
              dbms_sql.bind_variable(cursor1, ':pPLANNER', pPLANNER);
           END IF;

           IF pCATEGORY_ID IS NOT NULL THEN
              dbms_sql.bind_variable(cursor1, ':pCATEGORY_ID', pCATEGORY_ID);
              dbms_sql.bind_variable(cursor1, ':pLANG', lv_LANG);
           END IF;

           IF pITEM_ID IS NOT NULL THEN
              dbms_sql.bind_variable(cursor1, ':pITEM_ID', pITEM_ID);
           END IF;

           IF pSUPPLIER_ID IS NOT NULL THEN
              dbms_sql.bind_variable(cursor1, ':pSUPPLIER_ID', lv_sr_tp_id);
           END IF;

           IF pSUPPLIER_SITE_ID IS NOT NULL THEN
              dbms_sql.bind_variable(cursor1, ':pSUPPLIER_SITE_ID', pSUPPLIER_SITE_ID);
              dbms_sql.bind_variable(cursor1, ':pINSTANCE_ID', pINSTANCE_ID);
           END IF;

           dbms_sql.bind_variable(cursor1, ':pHORIZON_START_DATE', lv_start_date);
           dbms_sql.bind_variable(cursor1, ':pHORIZON_END_DATE', lv_end_date);

           ignore := dbms_sql.execute(cursor1);
           dbms_sql.close_cursor(cursor1);

/* End Delete Recommendations */

/* Begin Delete Items */

      lv_sql_stmt := 'DELETE FROM MRP_SYSTEM_ITEMS'||v_dblink||' MSI'
           ||' WHERE MSI.COMPILE_DESIGNATOR = :pDESIGNATOR '
           ||' AND MSI.ORGANIZATION_ID IN (SELECT MPOV.PLANNED_ORGANIZATION'
           ||' FROM MSC_PLAN_ORGANIZATIONS_V MPOV'
           ||' WHERE MPOV.SR_INSTANCE_ID = :pINSTANCE_ID'
           ||' AND MPOV.COMPILE_DESIGNATOR = :pDESIGNATOR)';


       IF pORGANIZATION_ID IS NOT NULL THEN
          lv_sql_stmt := lv_sql_stmt || ' AND MSI.ORGANIZATION_ID = :pORGANIZATION_ID';
       END IF;

       IF pPLANNER IS NOT NULL THEN

          lv_items_stmt :=
                         ' AND EXISTS (SELECT 1 FROM MTL_SYSTEM_ITEMS'||v_dblink||' MSI2'
           ||' WHERE MSI2.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID'
           ||' AND MSI2.ORGANIZATION_ID = MSI.ORGANIZATION_ID'
           ||' AND MSI2.PLANNER_CODE = :pPLANNER)';

       END IF;

       IF pITEM_ID IS NOT NULL THEN

          IF pPLANNER IS NOT NULL THEN
             lv_items_stmt := SUBSTR(lv_items_stmt,1,LENGTH(lv_items_stmt)-1) || ' AND MSI2.INVENTORY_ITEM_ID = :pITEM_ID)';
          ELSE
             lv_items_stmt := ' AND MSI.INVENTORY_ITEM_ID = :pITEM_ID';
          END IF;

       END IF;

       lv_sql_stmt := lv_sql_stmt || lv_items_stmt;

       IF pCATEGORY_ID IS NOT NULL THEN
           lv_sql_stmt := lv_sql_stmt
                         ||' AND EXISTS (SELECT 1 FROM MRP_AP_ITEM_CATEGORIES_V'||v_dblink||' MAICV, MRP_AP_CATEGORY_SETS_V'||v_dblink||' MACSV'
                         ||'  WHERE MAICV.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID AND MAICV.ORGANIZATION_ID ='
                         ||'  MSI.ORGANIZATION_ID AND MAICV.CATEGORY_ID = :pCATEGORY_ID'
                         ||'  AND MAICV.CATEGORY_SET_ID = MACSV.CATEGORY_SET_ID'
                         ||'  AND MAICV.LANGUAGE = MACSV.LANGUAGE'
                         ||'  AND MACSV.LANGUAGE = :pLANG'
                         ||'  AND MACSV.DEFAULT_FLAG = 1)';
       END IF;


           cursor1 := dbms_sql.open_cursor;
           dbms_sql.parse(cursor1, lv_sql_stmt, dbms_sql.v7);

           dbms_sql.bind_variable(cursor1, ':pDESIGNATOR', pDESIGNATOR);
           dbms_sql.bind_variable(cursor1, ':pINSTANCE_ID', pINSTANCE_ID);
           dbms_sql.bind_variable(cursor1, ':pDESIGNATOR', pDESIGNATOR);

           IF pORGANIZATION_ID IS NOT NULL THEN
              dbms_sql.bind_variable(cursor1, ':pORGANIZATION_ID', pORGANIZATION_ID);
           END IF;

           IF pPLANNER IS NOT NULL THEN
              dbms_sql.bind_variable(cursor1, ':pPLANNER', pPLANNER);
           END IF;

           IF pCATEGORY_ID IS NOT NULL THEN
              dbms_sql.bind_variable(cursor1, ':pCATEGORY_ID', pCATEGORY_ID);
              dbms_sql.bind_variable(cursor1, ':pLANG', lv_LANG);
           END IF;

           IF pITEM_ID IS NOT NULL THEN
              dbms_sql.bind_variable(cursor1, ':pITEM_ID', pITEM_ID);
           END IF;

           ignore := dbms_sql.execute(cursor1);
           dbms_sql.close_cursor(cursor1);

/* End Delete Items */

IF pDEMAND = 1 THEN

/* Begin Delete Gross Requirements */

       lv_sql_stmt := 'DELETE FROM MRP_GROSS_REQUIREMENTS'||v_dblink||' MGR'
           ||' WHERE MGR.COMPILE_DESIGNATOR = :pDESIGNATOR '
           ||' AND MGR.ORGANIZATION_ID IN (SELECT MPOV.PLANNED_ORGANIZATION'
           ||' FROM MSC_PLAN_ORGANIZATIONS_V MPOV'
           ||' WHERE MPOV.SR_INSTANCE_ID = :pINSTANCE_ID'
           ||' AND MPOV.COMPILE_DESIGNATOR = :pDESIGNATOR)';


       IF pORGANIZATION_ID IS NOT NULL THEN
          lv_sql_stmt := lv_sql_stmt || ' AND MGR.ORGANIZATION_ID = :pORGANIZATION_ID';
       END IF;

       IF pPLANNER IS NOT NULL THEN

          lv_items_stmt :=
                         ' AND EXISTS (SELECT 1 FROM MTL_SYSTEM_ITEMS'||v_dblink||' MSI'
           ||' WHERE MSI.INVENTORY_ITEM_ID = MGR.INVENTORY_ITEM_ID'
           ||' AND MSI.ORGANIZATION_ID = MGR.ORGANIZATION_ID'
           ||' AND MSI.PLANNER_CODE = :pPLANNER)';

       END IF;

       IF pITEM_ID IS NOT NULL THEN

          IF pPLANNER IS NOT NULL THEN
             lv_items_stmt := SUBSTR(lv_items_stmt,1,LENGTH(lv_items_stmt)-1) || ' AND MSI.INVENTORY_ITEM_ID = :pITEM_ID)';
          ELSE
             lv_items_stmt := ' AND MGR.INVENTORY_ITEM_ID = :pITEM_ID';
          END IF;
       END IF;

       lv_sql_stmt := lv_sql_stmt || lv_items_stmt;

       IF pCATEGORY_ID IS NOT NULL THEN
           lv_sql_stmt := lv_sql_stmt
                         ||' AND EXISTS (SELECT 1 FROM MRP_AP_ITEM_CATEGORIES_V'||v_dblink||' MAICV, MRP_AP_CATEGORY_SETS_V'||v_dblink||' MACSV'
                         ||'  WHERE MAICV.INVENTORY_ITEM_ID = MGR.INVENTORY_ITEM_ID AND MAICV.ORGANIZATION_ID ='
                         ||'  MGR.ORGANIZATION_ID AND MAICV.CATEGORY_ID = :pCATEGORY_ID'
                         ||'  AND MAICV.CATEGORY_SET_ID = MACSV.CATEGORY_SET_ID'
                         ||'  AND MAICV.LANGUAGE = MACSV.LANGUAGE'
                         ||'  AND MACSV.LANGUAGE = :pLANG'
                         ||'  AND MACSV.DEFAULT_FLAG = 1)';
       END IF;


       lv_sql_stmt := lv_sql_stmt ||' AND trunc(MGR.USING_ASSEMBLY_DEMAND_DATE) BETWEEN (:pHORIZON_START_DATE) and (:pHORIZON_END_DATE)';


           cursor1 := dbms_sql.open_cursor;
           dbms_sql.parse(cursor1, lv_sql_stmt, dbms_sql.v7);

           dbms_sql.bind_variable(cursor1, ':pDESIGNATOR', pDESIGNATOR);
           dbms_sql.bind_variable(cursor1, ':pINSTANCE_ID', pINSTANCE_ID);
           dbms_sql.bind_variable(cursor1, ':pDESIGNATOR', pDESIGNATOR);

           IF pORGANIZATION_ID IS NOT NULL THEN
              dbms_sql.bind_variable(cursor1, ':pORGANIZATION_ID', pORGANIZATION_ID);
           END IF;

           IF pPLANNER IS NOT NULL THEN
              dbms_sql.bind_variable(cursor1, ':pPLANNER', pPLANNER);
           END IF;

           IF pCATEGORY_ID IS NOT NULL THEN
              dbms_sql.bind_variable(cursor1, ':pCATEGORY_ID', pCATEGORY_ID);
              dbms_sql.bind_variable(cursor1, ':pLANG', lv_LANG);
           END IF;

           IF pITEM_ID IS NOT NULL THEN
              dbms_sql.bind_variable(cursor1, ':pITEM_ID', pITEM_ID);
           END IF;

           dbms_sql.bind_variable(cursor1, ':pHORIZON_START_DATE', lv_start_date);
           dbms_sql.bind_variable(cursor1, ':pHORIZON_END_DATE', lv_end_date);

           ignore := dbms_sql.execute(cursor1);
           dbms_sql.close_cursor(cursor1);


/* End Delete Gross requirements */

END IF; --for bug 3073566

EXCEPTION
         WHEN OTHERS THEN
         ERRBUF := SQLERRM;
         RETCODE := G_WARNING;
         LOG_MESSAGE(SQLERRM);
         RETURN;
END ;

         FOR c_rec in c1 LOOP
         BEGIN
         --   If the input parameter is Buy Orders only then supplier/
         --   supplier site is not null

         v_buff := 'Loading Recommendations..... ';
         LOG_MESSAGE(v_buff);

              ----------------------------------------------------------------------------------------------
              --Supplier Site criteria was initially added for performance reasons and it is removed
              --for resolving the bug#3396519. Retaining supplier exists condition will not take care of the
              --scenario where a sourcing rule is not attached to the plan(supplier will not exist for this
              --condition). This check is retained for performace considerations and this has to be removed
              --if any customer complains about it.
              ----------------------------------------------------------------------------------------------

              lv_is_supp_not_null := ' AND nvl(ms.source_supplier_id,ms.supplier_id) is NOT NULL ';
              lv_is_supp_null := ' AND nvl(ms.source_supplier_id,ms.supplier_id) is NULL ';


           /*This is for Buy Orders, Will always be executed */
	   /* Bug # 2271832 (new bug for 2101174),
	      replacing the view mrp_ap_organizations_v with the
              table msc_trading_partner_sites. */

           lv_sql_stmt:=
           'INSERT INTO MRP_RECOMMENDATIONS'||v_dblink
           ||'( TRANSACTION_ID		, '
           ||' LAST_UPDATE_DATE               , '
           ||' LAST_UPDATED_BY                , '
           ||' CREATION_DATE                  , '
           ||' CREATED_BY                     , '
           ||' LAST_UPDATE_LOGIN             , '
           ||' INVENTORY_ITEM_ID              , '
           ||' ORGANIZATION_ID                , '
           ||' COMPILE_DESIGNATOR,'
           ||' NEW_SCHEDULE_DATE              , '
           ||' OLD_SCHEDULE_DATE             , '
           ||' NEW_WIP_START_DATE            , '
           ||' OLD_WIP_START_DATE            , '
           ||' DISPOSITION_ID                , '
           ||' DISPOSITION_STATUS_TYPE        , '
           ||' ORDER_TYPE                     , '
           ||' VENDOR_ID                               , '
           ||' VENDOR_SITE_ID                          , '
           ||' NEW_ORDER_QUANTITY             , '
           ||' OLD_ORDER_QUANTITY                      , '
           ||' NEW_ORDER_PLACEMENT_DATE                , '
           ||' OLD_ORDER_PLACEMENT_DATE                , '
           ||' FIRM_PLANNED_TYPE              , '
           ||' NEW_PROCESSING_DAYS                     , '
           ||' IMPLEMENTED_QUANTITY                    , '
           ||' PURCH_LINE_NUM                          , '
           ||' REVISION                                , '
           ||' LAST_UNIT_COMPLETION_DATE               , '
           ||' FIRST_UNIT_START_DATE                   , '
           ||' LAST_UNIT_START_DATE                    , '
           ||' DAILY_RATE                              , '
           ||' OLD_DOCK_DATE                           , '
           ||' NEW_DOCK_DATE                           , '
           ||' RESCHEDULE_DAYS                         , '
           ||' REQUEST_ID                              , '
           ||' PROGRAM_APPLICATION_ID                  , '
           ||' PROGRAM_ID                              , '
           ||' PROGRAM_UPDATE_DATE                     , '
           ||' QUANTITY_IN_PROCESS                     , '
           ||' FIRM_QUANTITY                           , '
           ||' FIRM_DATE                               , '
           ||' UPDATED                                 , '
           ||' STATUS                                  , '
           ||' APPLIED                                 , '
           ||' IMPLEMENT_DEMAND_CLASS                  , '
           ||' IMPLEMENT_DATE                          , '
           ||' IMPLEMENT_QUANTITY                      , '
           ||' IMPLEMENT_FIRM                          , '
           ||' IMPLEMENT_WIP_CLASS_CODE                , '
           ||' IMPLEMENT_JOB_NAME                      , '
           ||' IMPLEMENT_DOCK_DATE                     , '
           ||' IMPLEMENT_STATUS_CODE                   , '
           ||' IMPLEMENT_EMPLOYEE_ID                   , '
           ||' IMPLEMENT_UOM_CODE                      , '
           ||' IMPLEMENT_LOCATION_ID                   , '
           ||' RELEASE_STATUS                          , '
           ||' LOAD_TYPE                               , '
           ||' IMPLEMENT_AS                            , '
           ||' DEMAND_CLASS                            , '
           ||' ALTERNATE_BOM_DESIGNATOR                , '
           ||' ALTERNATE_ROUTING_DESIGNATOR            , '
           ||' LINE_ID                                 , '
           ||' BY_PRODUCT_USING_ASSY_ID                , '
           ||' IMPLEMENT_SOURCE_ORG_ID                 , '
           ||' IMPLEMENT_VENDOR_ID                     , '
           ||' IMPLEMENT_VENDOR_SITE_ID                , '
           ||' SOURCE_ORGANIZATION_ID                  , '
           ||' SOURCE_VENDOR_SITE_ID                   , '
           ||' SOURCE_VENDOR_ID                        , '
           ||' NEW_SHIP_DATE                           , '
           ||' PROJECT_ID                              , '
           ||' TASK_ID                                 , '
           ||' PLANNING_GROUP                          , '
           ||' IMPLEMENT_PROJECT_ID                    , '
           ||' IMPLEMENT_TASK_ID                       , '
           ||' IMPLEMENT_SCHEDULE_GROUP_ID             , '
           ||' IMPLEMENT_BUILD_SEQUENCE                , '
           ||' RELEASE_ERRORS                     , '
	   ||' SCHEDULE_COMPRESSION_DAYS           , '
           ||' NUMBER1                                 '
           ||')'
           ||'SELECT /*+ index(ms msc_supplies_n8) leading(ms) */ '
           ||' MRP_SCHEDULE_DATES_S.nextval'||v_dblink||' , '
           ||' ms.LAST_UPDATE_DATE               , '
           ||' ms.LAST_UPDATED_BY                , '
           ||' ms.CREATION_DATE                  , '
           ||' ms.CREATED_BY                     , '
           ||' ms.LAST_UPDATE_LOGIN                       , '
           ||' msi.SR_INVENTORY_ITEM_ID              , '
           ||' ms.ORGANIZATION_ID                , '
           ||' :p_DESIGNATOR,'
           ||' NEW_SCHEDULE_DATE              , '
           ||' OLD_SCHEDULE_DATE                       , '
           ||' NEW_WIP_START_DATE                      , '
           ||' OLD_WIP_START_DATE                      , '
           ||' MRP_SCHEDULE_DATES_S.currval'||v_dblink||' , '
           ||' DISPOSITION_STATUS_TYPE        , '
           ||' ORDER_TYPE                     , '
           ||' mtil.sr_tp_id,'
            ||' mtsil.sr_tp_site_id,'
           ||' NEW_ORDER_QUANTITY             , '
           ||' OLD_ORDER_QUANTITY                      , '
           ||' NEW_ORDER_PLACEMENT_DATE                , '
           ||' OLD_ORDER_PLACEMENT_DATE                , '
           ||' FIRM_PLANNED_TYPE              , '
           ||' NEW_PROCESSING_DAYS                     , '
           ||' IMPLEMENTED_QUANTITY                    , '
           ||' PURCH_LINE_NUM                          , '
           ||' ms.REVISION                                , '
           ||' LAST_UNIT_COMPLETION_DATE               , '
           ||' FIRST_UNIT_START_DATE                   , '
           ||' LAST_UNIT_START_DATE                    , '
           ||' DAILY_RATE                              , '
           ||' OLD_DOCK_DATE                           , '
           ||' NEW_DOCK_DATE                           , '
           ||' RESCHEDULE_DAYS                         , '
           ||' ms.REQUEST_ID                              , '
           ||' ms.PROGRAM_APPLICATION_ID                  , '
           ||' ms.PROGRAM_ID                              , '
           ||' ms.PROGRAM_UPDATE_DATE                     , '
           ||' ms.QUANTITY_IN_PROCESS                     , '
           ||' ms.FIRM_QUANTITY                           , '
           ||' ms.FIRM_DATE                               , '
           ||' UPDATED                                 , '
           ||' ms.STATUS                                  , '
           ||' ms.APPLIED                                 , ' --9189942
           ||' IMPLEMENT_DEMAND_CLASS                  , '
           ||' IMPLEMENT_DATE                          , '
           ||' IMPLEMENT_QUANTITY                      , '
           ||' IMPLEMENT_FIRM                          , '
           ||' IMPLEMENT_WIP_CLASS_CODE                , '
           ||' IMPLEMENT_JOB_NAME                      , '
           ||' IMPLEMENT_DOCK_DATE                     , '
           ||' IMPLEMENT_STATUS_CODE                   , '
           ||' IMPLEMENT_EMPLOYEE_ID                   , '
           ||' IMPLEMENT_UOM_CODE                      , '
           ||' IMPLEMENT_LOCATION_ID                   , '
           ||' RELEASE_STATUS                          , '
           ||' LOAD_TYPE                               , '
           ||' IMPLEMENT_AS                            , '
           ||' DEMAND_CLASS                            , '
           ||' ALTERNATE_BOM_DESIGNATOR                , '
           ||' ALTERNATE_ROUTING_DESIGNATOR            , '
           ||' LINE_ID                                 , '
           ||' BY_PRODUCT_USING_ASSY_ID                , '
           ||' IMPLEMENT_SOURCE_ORG_ID                 , '
           ||' mtil.sr_tp_id,'
           ||' mtsil.sr_tp_site_id,'
           ||' SOURCE_ORGANIZATION_ID                  , '
           ||' mtsil.sr_tp_site_id,'
           ||' mtil.sr_tp_id,'
           ||' NEW_SHIP_DATE                           , '
           ||' PROJECT_ID                              , '
           ||' TASK_ID                                 , '
           ||' PLANNING_GROUP                          , '
           ||' IMPLEMENT_PROJECT_ID                    , '
           ||' IMPLEMENT_TASK_ID                       , '
           ||' IMPLEMENT_SCHEDULE_GROUP_ID             , '
           ||' IMPLEMENT_BUILD_SEQUENCE                , '
           ||' RELEASE_ERRORS           , '
	   ||' SCHEDULE_COMPRESS_DAYS , '
           ||' NUMBER1                       '
           ||' FROM  MSC_SUPPLIES ms,'
           ||'       MSC_TP_ID_LID mtil,'
           ||'       MSC_TP_SITE_ID_LID mtsil ,'
           ||'       msc_trading_partners ORG ,'
           ||'       MSC_SYSTEM_ITEMS msi'
           ||' WHERE ms.plan_id = :PLAN_ID'
           ||' AND   ms.sr_instance_id = :pINSTANCE_ID'
           ||' AND   msi.organization_id = ms.organization_id'
           ||' AND   msi.inventory_item_id = ms.inventory_item_id'
           ||' AND   msi.sr_instance_id = ms.sr_instance_id'
           ||' AND   msi.plan_id = ms.plan_id'
           ||' and   trunc(ms.NEW_SCHEDULE_DATE) BETWEEN (:pHORIZON_START_DATE) and (:pHORIZON_END_DATE)'
           ||' AND   mtil.tp_id = nvl(ms.source_supplier_id,ms.supplier_id)'
           ||' AND   mtil.partner_type = 1'
	   ||' AND   ORG.SR_TP_ID = ms.organization_id '
	   ||' AND   ORG.partner_type =  3'
	   ||' AND   ORG.sr_instance_id = ms.sr_instance_id'
           ||' AND   nvl(mtsil.operating_unit, -1) = nvl(ORG.OPERATING_UNIT, -1) '
           ||' AND   mtil.sr_instance_id  = ms.sr_instance_id'
           ||' AND   mtsil.tp_site_id     = nvl(source_supplier_site_id,ms.supplier_site_id)'
           ||' AND   mtsil.partner_type   = 1'
           ||' AND   mtsil.sr_instance_id = ms.sr_instance_id'
           ||' AND   nvl(source_supplier_site_id,ms.supplier_site_id) IS NOT NULL'
           ||' AND   NOT EXISTS (select 1 from msc_system_items msi1 , msc_trading_partners mtp'
           ||'        where msi1.inventory_item_id = ms.inventory_item_id   '
           ||'        and   msi1.organization_id = ms.organization_id '
           ||'        and   msi1.plan_id = ms.plan_id '
           ||'        AND   msi1.sr_instance_id = ms.sr_instance_id '
           ||'        and   nvl(msi1.release_time_fence_code,-1) = 7 '
           ||'        and   mtp.sr_tp_id = msi1.organization_id '
           ||'        and   mtp.sr_instance_id = msi1.sr_instance_id '
           ||'        and   mtp.partner_type=3 '
           ||'        and   (mtp.modeled_supplier_id is not null OR mtp.modeled_supplier_site_id is not null))'
           ||' AND   ms.order_type        = 5 '|| lv_is_supp_not_null;

           IF pORGANIZATION_ID IS NOT NULL THEN
              lv_sql_stmt := lv_sql_stmt || ' AND   ORG.SR_TP_ID = :pORGANIZATION_ID';
           END IF;

           IF pPLANNER IS NOT NULL THEN
              lv_sql_stmt := lv_sql_stmt || ' AND   msi.planner_code = :pPLANNER';
           END IF;

           IF pCATEGORY_ID IS NOT NULL THEN
              lv_sql_stmt := lv_sql_stmt || ' and exists  (select 1 from msc_item_categories mic, msc_category_sets mcs'
                                         ||'  where mic.inventory_item_id = msi.inventory_item_id'
                                         ||'  and  mic.organization_id = msi.organization_id'
                                         ||'  and  mic.sr_instance_id = msi.sr_instance_id'
                                         ||'  and  mic.SR_CATEGORY_ID = :pCATEGORY_ID'
                                         ||'  and mic.category_set_id = mcs.category_set_id'
                                         ||'  and mcs.sr_instance_id = mic.sr_instance_id'
                                         ||'  and mcs.DEFAULT_FLAG = 1)';
           END IF;

           IF pITEM_ID IS NOT NULL THEN
              lv_sql_stmt := lv_sql_stmt || ' AND   msi.sr_inventory_item_id = :pITEM_ID';
           END IF;

           IF pSUPPLIER_ID IS NOT NULL THEN
              lv_sql_stmt := lv_sql_stmt || ' AND   nvl(ms.source_supplier_id,ms.supplier_id) = :pSUPPLIER_ID';
           END IF;

           IF pSUPPLIER_SITE_ID IS NOT NULL THEN
              lv_sql_stmt := lv_sql_stmt || ' AND   nvl(source_supplier_site_id,ms.supplier_site_id) = :pSUPPLIER_SITE_ID';
           END IF;



           cursor1 := dbms_sql.open_cursor;
           dbms_sql.parse(cursor1, lv_sql_stmt, dbms_sql.v7);

           dbms_sql.bind_variable(cursor1, ':p_DESIGNATOR', pDESIGNATOR);
           dbms_sql.bind_variable(cursor1, ':PLAN_ID', c_rec.plan_id);
           dbms_sql.bind_variable(cursor1, ':pINSTANCE_ID', pINSTANCE_ID);
           dbms_sql.bind_variable(cursor1, ':pHORIZON_START_DATE', lv_start_date);
           dbms_sql.bind_variable(cursor1, ':pHORIZON_END_DATE', lv_end_date);

           IF pORGANIZATION_ID IS NOT NULL THEN
              dbms_sql.bind_variable(cursor1, ':pORGANIZATION_ID', pORGANIZATION_ID);
           END IF;

           IF pPLANNER IS NOT NULL THEN
              dbms_sql.bind_variable(cursor1, ':pPLANNER', pPLANNER);
           END IF;

           IF pCATEGORY_ID IS NOT NULL THEN
              dbms_sql.bind_variable(cursor1, ':pCATEGORY_ID', pCATEGORY_ID);
           END IF;

           IF pITEM_ID IS NOT NULL THEN
              dbms_sql.bind_variable(cursor1, ':pITEM_ID', pITEM_ID);
           END IF;

           IF pSUPPLIER_ID IS NOT NULL THEN
              dbms_sql.bind_variable(cursor1, ':pSUPPLIER_ID', pSUPPLIER_ID);
           END IF;

           IF pSUPPLIER_SITE_ID IS NOT NULL THEN
              dbms_sql.bind_variable(cursor1, ':pSUPPLIER_SITE_ID', pSUPPLIER_SITE_ID);
           END IF;

           v_total_buy_count := dbms_sql.execute(cursor1);
           dbms_sql.close_cursor(cursor1);

           v_buff := 'Number of Buy Recommendations with Supplier and Site loaded : '||v_total_buy_count;
           LOG_MESSAGE(v_buff);

           lv_sql_stmt:=
           'INSERT INTO MRP_RECOMMENDATIONS'||v_dblink
           ||'( TRANSACTION_ID		, '
           ||' LAST_UPDATE_DATE               , '
           ||' LAST_UPDATED_BY                , '
           ||' CREATION_DATE                  , '
           ||' CREATED_BY                     , '
           ||' LAST_UPDATE_LOGIN             , '
           ||' INVENTORY_ITEM_ID              , '
           ||' ORGANIZATION_ID                , '
           ||' COMPILE_DESIGNATOR,'
           ||' NEW_SCHEDULE_DATE              , '
           ||' OLD_SCHEDULE_DATE             , '
           ||' NEW_WIP_START_DATE            , '
           ||' OLD_WIP_START_DATE            , '
           ||' DISPOSITION_ID                , '
           ||' DISPOSITION_STATUS_TYPE        , '
           ||' ORDER_TYPE                     , '
           ||' VENDOR_ID                               , '
           ||' NEW_ORDER_QUANTITY             , '
           ||' OLD_ORDER_QUANTITY                      , '
           ||' NEW_ORDER_PLACEMENT_DATE                , '
           ||' OLD_ORDER_PLACEMENT_DATE                , '
           ||' FIRM_PLANNED_TYPE              , '
           ||' NEW_PROCESSING_DAYS                     , '
           ||' IMPLEMENTED_QUANTITY                    , '
           ||' PURCH_LINE_NUM                          , '
           ||' REVISION                                , '
           ||' LAST_UNIT_COMPLETION_DATE               , '
           ||' FIRST_UNIT_START_DATE                   , '
           ||' LAST_UNIT_START_DATE                    , '
           ||' DAILY_RATE                              , '
           ||' OLD_DOCK_DATE                           , '
           ||' NEW_DOCK_DATE                           , '
           ||' RESCHEDULE_DAYS                         , '
           ||' REQUEST_ID                              , '
           ||' PROGRAM_APPLICATION_ID                  , '
           ||' PROGRAM_ID                              , '
           ||' PROGRAM_UPDATE_DATE                     , '
           ||' QUANTITY_IN_PROCESS                     , '
           ||' FIRM_QUANTITY                           , '
           ||' FIRM_DATE                               , '
           ||' UPDATED                                 , '
           ||' STATUS                                  , '
           ||' APPLIED                                 , '
           ||' IMPLEMENT_DEMAND_CLASS                  , '
           ||' IMPLEMENT_DATE                          , '
           ||' IMPLEMENT_QUANTITY                      , '
           ||' IMPLEMENT_FIRM                          , '
           ||' IMPLEMENT_WIP_CLASS_CODE                , '
           ||' IMPLEMENT_JOB_NAME                      , '
           ||' IMPLEMENT_DOCK_DATE                     , '
           ||' IMPLEMENT_STATUS_CODE                   , '
           ||' IMPLEMENT_EMPLOYEE_ID                   , '
           ||' IMPLEMENT_UOM_CODE                      , '
           ||' IMPLEMENT_LOCATION_ID                   , '
           ||' RELEASE_STATUS                          , '
           ||' LOAD_TYPE                               , '
           ||' IMPLEMENT_AS                            , '
           ||' DEMAND_CLASS                            , '
           ||' ALTERNATE_BOM_DESIGNATOR                , '
           ||' ALTERNATE_ROUTING_DESIGNATOR            , '
           ||' LINE_ID                                 , '
           ||' BY_PRODUCT_USING_ASSY_ID                , '
           ||' IMPLEMENT_SOURCE_ORG_ID                 , '
           ||' IMPLEMENT_VENDOR_ID                     , '
           ||' IMPLEMENT_VENDOR_SITE_ID                , '
           ||' SOURCE_ORGANIZATION_ID                  , '
           ||' SOURCE_VENDOR_SITE_ID                   , '
           ||' SOURCE_VENDOR_ID                        , '
           ||' NEW_SHIP_DATE                           , '
           ||' PROJECT_ID                              , '
           ||' TASK_ID                                 , '
           ||' PLANNING_GROUP                          , '
           ||' IMPLEMENT_PROJECT_ID                    , '
           ||' IMPLEMENT_TASK_ID                       , '
           ||' IMPLEMENT_SCHEDULE_GROUP_ID             , '
           ||' IMPLEMENT_BUILD_SEQUENCE                , '
           ||' RELEASE_ERRORS                     , '
	   ||' SCHEDULE_COMPRESSION_DAYS           , '
           ||' NUMBER1                                 '
           ||')'
           ||'SELECT /*+ index(ms msc_supplies_n8) leading(ms) */'
           ||' MRP_SCHEDULE_DATES_S.nextval'||v_dblink||' , '
           ||' ms.LAST_UPDATE_DATE               , '
           ||' ms.LAST_UPDATED_BY                , '
           ||' ms.CREATION_DATE                  , '
           ||' ms.CREATED_BY                     , '
           ||' ms.LAST_UPDATE_LOGIN                       , '
           ||' msi.SR_INVENTORY_ITEM_ID              , '
           ||' ms.ORGANIZATION_ID                , '
           ||' :p_DESIGNATOR,'
           ||' NEW_SCHEDULE_DATE              , '
           ||' OLD_SCHEDULE_DATE                       , '
           ||' NEW_WIP_START_DATE                      , '
           ||' OLD_WIP_START_DATE                      , '
           ||' MRP_SCHEDULE_DATES_S.currval'||v_dblink||' , '
           ||' DISPOSITION_STATUS_TYPE        , '
           ||' ORDER_TYPE                     , '
           ||' mtil.sr_tp_id,'
           ||' NEW_ORDER_QUANTITY             , '
           ||' OLD_ORDER_QUANTITY                      , '
           ||' NEW_ORDER_PLACEMENT_DATE                , '
           ||' OLD_ORDER_PLACEMENT_DATE                , '
           ||' FIRM_PLANNED_TYPE              , '
           ||' NEW_PROCESSING_DAYS                     , '
           ||' IMPLEMENTED_QUANTITY                    , '
           ||' PURCH_LINE_NUM                          , '
           ||' ms.REVISION                                , '
           ||' LAST_UNIT_COMPLETION_DATE               , '
           ||' FIRST_UNIT_START_DATE                   , '
           ||' LAST_UNIT_START_DATE                    , '
           ||' DAILY_RATE                              , '
           ||' OLD_DOCK_DATE                           , '
           ||' NEW_DOCK_DATE                           , '
           ||' RESCHEDULE_DAYS                         , '
           ||' ms.REQUEST_ID                              , '
           ||' ms.PROGRAM_APPLICATION_ID                  , '
           ||' ms.PROGRAM_ID                              , '
           ||' ms.PROGRAM_UPDATE_DATE                     , '
           ||' ms.QUANTITY_IN_PROCESS                     , '
           ||' ms.FIRM_QUANTITY                           , '
           ||' ms.FIRM_DATE                               , '
           ||' UPDATED                                 , '
           ||' ms.STATUS                                  , '
           ||' ms.APPLIED                                 , ' --9189942
           ||' IMPLEMENT_DEMAND_CLASS                  , '
           ||' IMPLEMENT_DATE                          , '
           ||' IMPLEMENT_QUANTITY                      , '
           ||' IMPLEMENT_FIRM                          , '
           ||' IMPLEMENT_WIP_CLASS_CODE                , '
           ||' IMPLEMENT_JOB_NAME                      , '
           ||' IMPLEMENT_DOCK_DATE                     , '
           ||' IMPLEMENT_STATUS_CODE                   , '
           ||' IMPLEMENT_EMPLOYEE_ID                   , '
           ||' IMPLEMENT_UOM_CODE                      , '
           ||' IMPLEMENT_LOCATION_ID                   , '
           ||' RELEASE_STATUS                          , '
           ||' LOAD_TYPE                               , '
           ||' IMPLEMENT_AS                            , '
           ||' DEMAND_CLASS                            , '
           ||' ALTERNATE_BOM_DESIGNATOR                , '
           ||' ALTERNATE_ROUTING_DESIGNATOR            , '
           ||' LINE_ID                                 , '
           ||' BY_PRODUCT_USING_ASSY_ID                , '
           ||' IMPLEMENT_SOURCE_ORG_ID                 , '
           ||' mtil.sr_tp_id,'
           ||' null,'
           ||' SOURCE_ORGANIZATION_ID                  , '
           ||' null,'
           ||' mtil.sr_tp_id,'
           ||' NEW_SHIP_DATE                           , '
           ||' PROJECT_ID                              , '
           ||' TASK_ID                                 , '
           ||' PLANNING_GROUP                          , '
           ||' IMPLEMENT_PROJECT_ID                    , '
           ||' IMPLEMENT_TASK_ID                       , '
           ||' IMPLEMENT_SCHEDULE_GROUP_ID             , '
           ||' IMPLEMENT_BUILD_SEQUENCE                , '
           ||' RELEASE_ERRORS           , '
	   ||' SCHEDULE_COMPRESS_DAYS , '
           ||' NUMBER1                       '
           ||' FROM  MSC_SUPPLIES ms,'
           ||'       MSC_TP_ID_LID mtil,'
           ||'       MSC_SYSTEM_ITEMS msi'
           ||' WHERE ms.plan_id = :PLAN_ID'
           ||' AND   ms.sr_instance_id = :pINSTANCE_ID'
           ||' AND   msi.organization_id = ms.organization_id'
           ||' AND   msi.inventory_item_id = ms.inventory_item_id'
           ||' AND   msi.sr_instance_id = ms.sr_instance_id'
           ||' AND   msi.plan_id = ms.plan_id'
           ||' and   trunc(ms.NEW_SCHEDULE_DATE) BETWEEN (:pHORIZON_START_DATE) and (:pHORIZON_END_DATE)'
           ||' AND   mtil.tp_id = nvl(ms.source_supplier_id,ms.supplier_id)'
           ||' AND   mtil.partner_type = 1'
           ||' AND   mtil.sr_instance_id = ms.sr_instance_id'
           ||' AND   nvl(source_supplier_site_id,ms.supplier_site_id) IS NULL '
           ||' AND   NOT EXISTS (select 1 from msc_system_items msi1 , msc_trading_partners mtp'
           ||'        where msi1.inventory_item_id = ms.inventory_item_id   '
           ||'        and   msi1.organization_id = ms.organization_id '
           ||'        and   msi1.plan_id = ms.plan_id '
           ||'        AND   msi1.sr_instance_id = ms.sr_instance_id '
           ||'        and   nvl(msi1.release_time_fence_code,-1) = 7 '
           ||'        and   mtp.sr_tp_id = msi1.organization_id '
           ||'        and   mtp.sr_instance_id = msi1.sr_instance_id '
           ||'        and   mtp.partner_type=3 '
           ||'        and   (mtp.modeled_supplier_id is not null OR mtp.modeled_supplier_site_id is not null))'
           ||' AND   ms.order_type = 5 '|| lv_is_supp_not_null;

           IF pORGANIZATION_ID IS NOT NULL THEN
              lv_sql_stmt := lv_sql_stmt || ' AND   ms.organization_id = :pORGANIZATION_ID';
           END IF;

           IF pPLANNER IS NOT NULL THEN
              lv_sql_stmt := lv_sql_stmt || ' AND   msi.planner_code = :pPLANNER';
           END IF;

           IF pCATEGORY_ID IS NOT NULL THEN
              lv_sql_stmt := lv_sql_stmt || ' and exists  (select 1 from msc_item_categories mic, msc_category_sets mcs'
                                         ||'  where mic.inventory_item_id = msi.inventory_item_id'
                                         ||'  and  mic.organization_id = msi.organization_id'
                                         ||'  and  mic.sr_instance_id = msi.sr_instance_id'
                                         ||'  and  mic.SR_CATEGORY_ID = :pCATEGORY_ID'
                                         ||'  and mic.category_set_id = mcs.category_set_id'
                                         ||'  and mcs.sr_instance_id = mic.sr_instance_id'
                                         ||'  and mcs.DEFAULT_FLAG = 1)';
           END IF;

           IF pITEM_ID IS NOT NULL THEN
              lv_sql_stmt := lv_sql_stmt || ' AND   msi.sr_inventory_item_id = :pITEM_ID';
           END IF;

           IF pSUPPLIER_ID IS NOT NULL THEN
              lv_sql_stmt := lv_sql_stmt || ' AND   nvl(ms.source_supplier_id,ms.supplier_id) = :pSUPPLIER_ID';
           END IF;

           cursor1 := dbms_sql.open_cursor;
           dbms_sql.parse(cursor1, lv_sql_stmt, dbms_sql.v7);

           dbms_sql.bind_variable(cursor1, ':p_DESIGNATOR', pDESIGNATOR);
           dbms_sql.bind_variable(cursor1, ':PLAN_ID', c_rec.plan_id);
           dbms_sql.bind_variable(cursor1, ':pINSTANCE_ID', pINSTANCE_ID);
           dbms_sql.bind_variable(cursor1, ':pHORIZON_START_DATE', lv_start_date);
           dbms_sql.bind_variable(cursor1, ':pHORIZON_END_DATE', lv_end_date);

           IF pORGANIZATION_ID IS NOT NULL THEN
              dbms_sql.bind_variable(cursor1, ':pORGANIZATION_ID', pORGANIZATION_ID);
           END IF;

           IF pPLANNER IS NOT NULL THEN
              dbms_sql.bind_variable(cursor1, ':pPLANNER', pPLANNER);
           END IF;

           IF pCATEGORY_ID IS NOT NULL THEN
              dbms_sql.bind_variable(cursor1, ':pCATEGORY_ID', pCATEGORY_ID);
           END IF;

           IF pITEM_ID IS NOT NULL THEN
              dbms_sql.bind_variable(cursor1, ':pITEM_ID', pITEM_ID);
           END IF;

           IF pSUPPLIER_ID IS NOT NULL THEN
              dbms_sql.bind_variable(cursor1, ':pSUPPLIER_ID', pSUPPLIER_ID);
           END IF;

           v_total_buy_count1 := dbms_sql.execute(cursor1);
           dbms_sql.close_cursor(cursor1);

           v_buff := 'Number of Buy Recommendations with No Site loaded : '||v_total_buy_count1;
           LOG_MESSAGE(v_buff);

           v_total_buy_count := v_total_buy_count + v_total_buy_count1;

     /* Make Orders */


           /*This is for Make Orders, Will be executed only if the input program parameter
             (Which is a question to the user , "Buy Orders Only" ? is set to NO.
             In this case we are not even joining to MSC_TP_SITE_ID_LID and MSC_TP_SITE_ID
              and MSC_TP_SITE_ID_LID anymore. We are populating the vendor and vendor_site_id's as
              NULL */


         IF pBUY_ORDERS_ONLY <> SYS_YES  THEN

           lv_sql_stmt1:=
           'INSERT INTO MRP_RECOMMENDATIONS'||v_dblink
           ||'( TRANSACTION_ID		, '
           ||' LAST_UPDATE_DATE               , '
           ||' LAST_UPDATED_BY                , '
           ||' CREATION_DATE                  , '
           ||' CREATED_BY                     , '
           ||' LAST_UPDATE_LOGIN             , '
           ||' INVENTORY_ITEM_ID              , '
           ||' ORGANIZATION_ID                , '
           ||' COMPILE_DESIGNATOR,'
           ||' NEW_SCHEDULE_DATE              , '
           ||' OLD_SCHEDULE_DATE             , '
           ||' NEW_WIP_START_DATE            , '
           ||' OLD_WIP_START_DATE            , '
           ||' DISPOSITION_ID                , '
           ||' DISPOSITION_STATUS_TYPE        , '
           ||' ORDER_TYPE                     , '
           ||' VENDOR_ID                               , '
           ||' NEW_ORDER_QUANTITY             , '
           ||' OLD_ORDER_QUANTITY                      , '
           ||' NEW_ORDER_PLACEMENT_DATE                , '
           ||' OLD_ORDER_PLACEMENT_DATE                , '
           ||' FIRM_PLANNED_TYPE              , '
           ||' NEW_PROCESSING_DAYS                     , '
           ||' IMPLEMENTED_QUANTITY                    , '
           ||' PURCH_LINE_NUM                          , '
           ||' REVISION                                , '
           ||' LAST_UNIT_COMPLETION_DATE               , '
           ||' FIRST_UNIT_START_DATE                   , '
           ||' LAST_UNIT_START_DATE                    , '
           ||' DAILY_RATE                              , '
           ||' OLD_DOCK_DATE                           , '
           ||' NEW_DOCK_DATE                           , '
           ||' RESCHEDULE_DAYS                         , '
           ||' REQUEST_ID                              , '
           ||' PROGRAM_APPLICATION_ID                  , '
           ||' PROGRAM_ID                              , '
           ||' PROGRAM_UPDATE_DATE                     , '
           ||' QUANTITY_IN_PROCESS                     , '
           ||' FIRM_QUANTITY                           , '
           ||' FIRM_DATE                               , '
           ||' UPDATED                                 , '
           ||' STATUS                                  , '
           ||' APPLIED                                 , '
           ||' IMPLEMENT_DEMAND_CLASS                  , '
           ||' IMPLEMENT_DATE                          , '
           ||' IMPLEMENT_QUANTITY                      , '
           ||' IMPLEMENT_FIRM                          , '
           ||' IMPLEMENT_WIP_CLASS_CODE                , '
           ||' IMPLEMENT_JOB_NAME                      , '
           ||' IMPLEMENT_DOCK_DATE                     , '
           ||' IMPLEMENT_STATUS_CODE                   , '
           ||' IMPLEMENT_EMPLOYEE_ID                   , '
           ||' IMPLEMENT_UOM_CODE                      , '
           ||' IMPLEMENT_LOCATION_ID                   , '
           ||' RELEASE_STATUS                          , '
           ||' LOAD_TYPE                               , '
           ||' IMPLEMENT_AS                            , '
           ||' DEMAND_CLASS                            , '
           ||' ALTERNATE_BOM_DESIGNATOR                , '
           ||' ALTERNATE_ROUTING_DESIGNATOR            , '
           ||' LINE_ID                                 , '
           ||' BY_PRODUCT_USING_ASSY_ID                , '
           ||' IMPLEMENT_SOURCE_ORG_ID                 , '
           ||' IMPLEMENT_VENDOR_ID                     , '
           ||' IMPLEMENT_VENDOR_SITE_ID                , '
           ||' SOURCE_ORGANIZATION_ID                  , '
           ||' SOURCE_VENDOR_SITE_ID                   , '
           ||' SOURCE_VENDOR_ID                        , '
           ||' NEW_SHIP_DATE                           , '
           ||' PROJECT_ID                              , '
           ||' TASK_ID                                 , '
           ||' PLANNING_GROUP                          , '
           ||' IMPLEMENT_PROJECT_ID                    , '
           ||' IMPLEMENT_TASK_ID                       , '
           ||' IMPLEMENT_SCHEDULE_GROUP_ID             , '
           ||' IMPLEMENT_BUILD_SEQUENCE                , '
           ||' RELEASE_ERRORS                     , '
	   ||' SCHEDULE_COMPRESSION_DAYS           , '
           ||' NUMBER1                                 '
           ||')'
           ||'SELECT'
           ||' MRP_SCHEDULE_DATES_S.nextval'||v_dblink||' , '
           ||' ms.LAST_UPDATE_DATE               , '
           ||' ms.LAST_UPDATED_BY                , '
           ||' ms.CREATION_DATE                  , '
           ||' ms.CREATED_BY                     , '
           ||' ms.LAST_UPDATE_LOGIN                       , '
           ||' msi.SR_INVENTORY_ITEM_ID              , '
           ||' ms.ORGANIZATION_ID                , '
           ||' :p_DESIGNATOR,'
           ||' NEW_SCHEDULE_DATE              , '
           ||' OLD_SCHEDULE_DATE                       , '
           ||' NEW_WIP_START_DATE                      , '
           ||' OLD_WIP_START_DATE                      , '
           ||' MRP_SCHEDULE_DATES_S.currval'||v_dblink||' , '
           ||' DISPOSITION_STATUS_TYPE        , '
           ||' ORDER_TYPE                     , '
           ||' NULL,'
           ||' NEW_ORDER_QUANTITY             , '
           ||' OLD_ORDER_QUANTITY                      , '
           ||' NEW_ORDER_PLACEMENT_DATE                , '
           ||' OLD_ORDER_PLACEMENT_DATE                , '
           ||' FIRM_PLANNED_TYPE              , '
           ||' NEW_PROCESSING_DAYS                     , '
           ||' IMPLEMENTED_QUANTITY                    , '
           ||' PURCH_LINE_NUM                          , '
           ||' ms.REVISION                                , '
           ||' LAST_UNIT_COMPLETION_DATE               , '
           ||' FIRST_UNIT_START_DATE                   , '
           ||' LAST_UNIT_START_DATE                    , '
           ||' DAILY_RATE                              , '
           ||' OLD_DOCK_DATE                           , '
           ||' NEW_DOCK_DATE                           , '
           ||' RESCHEDULE_DAYS                         , '
           ||' ms.REQUEST_ID                              , '
           ||' ms.PROGRAM_APPLICATION_ID                  , '
           ||' ms.PROGRAM_ID                              , '
           ||' ms.PROGRAM_UPDATE_DATE                     , '
           ||' ms.QUANTITY_IN_PROCESS                     , '
           ||' ms.FIRM_QUANTITY                           , '
           ||' ms.FIRM_DATE                               , '
           ||' UPDATED                                 , '
           ||' STATUS                                  , '
           ||' ms.APPLIED                              , ' --9189942
           ||' IMPLEMENT_DEMAND_CLASS                  , '
           ||' IMPLEMENT_DATE                          , '
           ||' IMPLEMENT_QUANTITY                      , '
           ||' IMPLEMENT_FIRM                          , '
           ||' IMPLEMENT_WIP_CLASS_CODE                , '
           ||' IMPLEMENT_JOB_NAME                      , '
           ||' IMPLEMENT_DOCK_DATE                     , '
           ||' IMPLEMENT_STATUS_CODE                   , '
           ||' IMPLEMENT_EMPLOYEE_ID                   , '
           ||' IMPLEMENT_UOM_CODE                      , '
           ||' IMPLEMENT_LOCATION_ID                   , '
           ||' RELEASE_STATUS                          , '
           ||' LOAD_TYPE                               , '
           ||' IMPLEMENT_AS                            , '
           ||' DEMAND_CLASS                            , '
           ||' ALTERNATE_BOM_DESIGNATOR                , '
           ||' ALTERNATE_ROUTING_DESIGNATOR            , '
           ||' LINE_ID                                 , '
           ||' BY_PRODUCT_USING_ASSY_ID                , '
           ||' IMPLEMENT_SOURCE_ORG_ID                 , '
           ||' NULL,'
           ||' NULL,'
           ||' SOURCE_ORGANIZATION_ID                  , '
           ||' NULL,'
           ||' NULL,'
           ||' NEW_SHIP_DATE                           , '
           ||' PROJECT_ID                              , '
           ||' TASK_ID                                 , '
           ||' PLANNING_GROUP                          , '
           ||' IMPLEMENT_PROJECT_ID                    , '
           ||' IMPLEMENT_TASK_ID                       , '
           ||' IMPLEMENT_SCHEDULE_GROUP_ID             , '
           ||' IMPLEMENT_BUILD_SEQUENCE                , '
           ||' RELEASE_ERRORS           , '
	   ||' SCHEDULE_COMPRESS_DAYS , '
           ||' NUMBER1                       '
           ||' FROM  MSC_SUPPLIES ms,'
           ||'       MSC_SYSTEM_ITEMS msi'
           ||' WHERE ms.plan_id = :PLAN_ID'
           ||' AND   ms.sr_instance_id = :pINSTANCE_ID'
           ||' AND   msi.organization_id = ms.organization_id'
           ||' AND   msi.inventory_item_id = ms.inventory_item_id'
           ||' AND   msi.sr_instance_id = ms.sr_instance_id'
           ||' AND   msi.plan_id = ms.plan_id'
           ||' and   trunc(ms.NEW_SCHEDULE_DATE) BETWEEN (:pHORIZON_START_DATE) and (:pHORIZON_END_DATE)'
           ||' AND   NOT EXISTS (select 1 from msc_system_items msi1 , msc_trading_partners mtp'
           ||'        where msi1.inventory_item_id = ms.inventory_item_id   '
           ||'        and   msi1.organization_id = ms.organization_id '
           ||'        and   msi1.plan_id = ms.plan_id '
           ||'        AND   msi1.sr_instance_id = ms.sr_instance_id '
           ||'        and   nvl(msi1.release_time_fence_code,-1) = 7 '
           ||'        and   mtp.sr_tp_id = msi1.organization_id '
           ||'        and   mtp.sr_instance_id = msi1.sr_instance_id '
           ||'        and   mtp.partner_type=3 '
           ||'        and   (mtp.modeled_supplier_id is not null OR mtp.modeled_supplier_site_id is not null))'
           ||' AND   ms.order_type = 5 '|| lv_is_supp_null;

           IF pORGANIZATION_ID IS NOT NULL THEN
              lv_sql_stmt1 := lv_sql_stmt1 || ' AND   ms.organization_id = :pORGANIZATION_ID';
           END IF;

           IF pPLANNER IS NOT NULL THEN
              lv_sql_stmt1 := lv_sql_stmt1 || ' AND   msi.planner_code = :pPLANNER';
           END IF;

           IF pCATEGORY_ID IS NOT NULL THEN
              lv_sql_stmt1 := lv_sql_stmt1 || ' and exists  (select 1 from msc_item_categories mic, msc_category_sets mcs'
                                         ||'  where mic.inventory_item_id = msi.inventory_item_id'
                                         ||'  and  mic.organization_id = msi.organization_id'
                                         ||'  and  mic.sr_instance_id = msi.sr_instance_id'
                                         ||'  and  mic.SR_CATEGORY_ID = :pCATEGORY_ID'
                                         ||'  and mic.category_set_id = mcs.category_set_id'
                                         ||'  and mcs.sr_instance_id = mic.sr_instance_id'
                                         ||'  and mcs.DEFAULT_FLAG = 1)';
           END IF;

           IF pITEM_ID IS NOT NULL THEN
              lv_sql_stmt1 := lv_sql_stmt1 || ' AND   msi.sr_inventory_item_id = :pITEM_ID';
           END IF;


          cursor1 := dbms_sql.open_cursor;
           dbms_sql.parse(cursor1, lv_sql_stmt1, dbms_sql.v7);

           dbms_sql.bind_variable(cursor1, ':p_DESIGNATOR', pDESIGNATOR);
           dbms_sql.bind_variable(cursor1, ':PLAN_ID', c_rec.plan_id);
           dbms_sql.bind_variable(cursor1, ':pINSTANCE_ID', pINSTANCE_ID);
           dbms_sql.bind_variable(cursor1, ':pHORIZON_START_DATE', lv_start_date);
           dbms_sql.bind_variable(cursor1, ':pHORIZON_END_DATE', lv_end_date);

           IF pORGANIZATION_ID IS NOT NULL THEN
              dbms_sql.bind_variable(cursor1, ':pORGANIZATION_ID', pORGANIZATION_ID);
           END IF;

           IF pPLANNER IS NOT NULL THEN
              dbms_sql.bind_variable(cursor1, ':pPLANNER', pPLANNER);
           END IF;

           IF pCATEGORY_ID IS NOT NULL THEN
              dbms_sql.bind_variable(cursor1, ':pCATEGORY_ID', pCATEGORY_ID);
           END IF;

           IF pITEM_ID IS NOT NULL THEN
              dbms_sql.bind_variable(cursor1, ':pITEM_ID', pITEM_ID);
           END IF;

           v_total_make_count := dbms_sql.execute(cursor1);
           dbms_sql.close_cursor(cursor1);


         END IF;

            v_total_count := v_total_buy_count + v_total_make_Count ;

           v_buff := 'Total Number of Buy Recommendations loaded : '||v_total_buy_count;
           LOG_MESSAGE(v_buff);
           v_buff := 'Total Number of Make Recommendations loaded : '||v_total_make_Count;
           LOG_MESSAGE(v_buff);

           v_buff := 'Total Number of Recommendations loaded : '||v_total_count;
           LOG_MESSAGE(v_buff);

         END ;

      END LOOP;


         FOR c_rec in c1 LOOP
         BEGIN
         --   If the input parameter is Buy Orders only then supplier/
         --   supplier site is not null

         v_buff := 'Loading System Items ..... ';
         LOG_MESSAGE(v_buff);

           lv_sql_stmt:=

           ' INSERT INTO MRP_SYSTEM_ITEMS'||v_dblink
           ||' (INVENTORY_ITEM_ID               ,'
           ||' ORGANIZATION_ID                ,'
           ||' COMPILE_DESIGNATOR             ,'
           ||' LAST_UPDATE_DATE              ,'
           ||' LAST_UPDATED_BY              ,'
           ||' CREATION_DATE               ,'
           ||' CREATED_BY                 ,'
           ||' INVENTORY_TYPE            ,'
           ||' MRP_PLANNING_CODE        ,'
           ||' INVENTORY_PLANNING_CODE         ,'
           ||' LOW_LEVEL_CODE                 ,'
           ||' FULL_LEAD_TIME                ,'
           ||' UOM_CODE                     ,'
           ||' BUILD_IN_WIP_FLAG           ,'
           ||' PURCHASING_ENABLED_FLAG    ,'
           ||' PLANNING_MAKE_BUY_CODE    ,'
           ||' REPETITIVE_TYPE          ,'
           ||' LOT_CONTROL_CODE        ,'
           ||' ROUNDING_CONTROL_TYPE  ,'
           ||' CALCULATE_ATP                   ,'
           ||' END_ASSEMBLY_PEGGING           ,'
           ||' NETTABLE_INVENTORY_QUANTITY   ,'
           ||' NONNETTABLE_INVENTORY_QUANTITY  ,'
           ||' ENGINEERING_ITEM_FLAG          ,'
           ||' SAFETY_STOCK_CODE             ,'
           ||' PREPROCESSING_LEAD_TIME                  ,'
           ||' POSTPROCESSING_LEAD_TIME                ,'
           ||' CUMULATIVE_TOTAL_LEAD_TIME             ,'
           ||' CUM_MANUFACTURING_LEAD_TIME           ,'
           ||' LAST_UPDATE_LOGIN                    ,'
           ||' FIXED_LEAD_TIME                     ,'
           ||' VARIABLE_LEAD_TIME                 ,'
           ||' STANDARD_COST                     ,'
           ||' WIP_SUPPLY_TYPE                  ,'
           ||' OVERRUN_PERCENTAGE              ,'
           ||' ACCEPTABLE_RATE_INCREASE       ,'
           ||' ACCEPTABLE_RATE_DECREASE      ,'
           ||' SAFETY_STOCK_PERCENT         ,'
           ||' SAFETY_STOCK_BUCKET_DAYS    ,'
           ||' SAFETY_STOCK_QUANTITY      ,'
           ||' DESCRIPTION               ,'
           ||' CATEGORY_ID                              ,'
           ||' BUYER_ID                                 ,'
           ||' BUYER_NAME                               ,'
           ||' PLANNER_CODE                             ,'
           ||' ABC_CLASS                                ,'
           ||' REVISION                                 ,'
           ||' FIXED_DAYS_SUPPLY                        ,'
           ||' FIXED_ORDER_QUANTITY                     ,'
           ||' FIXED_LOT_MULTIPLIER                     ,'
           ||' MINIMUM_ORDER_QUANTITY                   ,'
           ||' MAXIMUM_ORDER_QUANTITY                   ,'
           ||' PLANNING_TIME_FENCE_DAYS                 ,'
--           ||' PLANNING_TIME_FENCE_DATE                 ,'
           ||' DEMAND_TIME_FENCE_DAYS                   ,'
           ||' INVENTORY_USE_UP_DATE                    ,'
           ||' ACCEPTABLE_EARLY_DELIVERY                ,'
           ||' PLANNER_STATUS_CODE                      ,'
           ||' SHRINKAGE_RATE                           ,'
           ||' EXCEPTION_SHORTAGE_DAYS                  ,'
           ||' EXCEPTION_EXCESS_DAYS                    ,'
           ||' EXCEPTION_REP_VARIANCE_DAYS              ,'
           ||' EXCEPTION_OVERPROMISED_DAYS              ,'
           ||' PLANNING_EXCEPTION_SET                   ,'
           ||' EXCESS_QUANTITY                          ,'
           ||' REPETITIVE_VARIANCE                      ,'
           ||' BASE_ITEM_ID                             ,'
           ||' ATO_FORECAST_CONTROL                     ,'
           ||' EXCEPTION_CODE                           ,'
           ||' PROGRAM_UPDATE_DATE                      ,'
           ||' REQUEST_ID                               ,'
           ||' PROGRAM_APPLICATION_ID                   ,'
           ||' PROGRAM_ID                               ,'
           ||' DEMAND_TIME_FENCE_DATE                   ,'
           ||' IN_SOURCE_PLAN                           ,'
           ||' BOM_ITEM_TYPE                           ,'
           ||' FULL_PEGGING,                  '
           ||' ORGANIZATION_CODE       )'
--           ||' EFFECTIVITY_CONTROL                      ) '
           ||'SELECT '
           ||' SR_INVENTORY_ITEM_ID             ,'
           ||' ORGANIZATION_ID                 ,'
           ||' :pdesignator,'
           ||' LAST_UPDATE_DATE                ,'
           ||' LAST_UPDATED_BY                 ,'
           ||' CREATION_DATE                   ,'
           ||' CREATED_BY                      ,'
           ||' 1,'
           ||' MRP_PLANNING_CODE               ,'
           ||' INVENTORY_PLANNING_CODE         ,'
           ||' decode(LOW_LEVEL_CODE,null,1,LOW_LEVEL_CODE),'
           ||' FULL_LEAD_TIME                  ,'
           ||' UOM_CODE                        ,'
           ||' BUILD_IN_WIP_FLAG               ,'
           ||' PURCHASING_ENABLED_FLAG         ,'
           ||' PLANNING_MAKE_BUY_CODE          ,'
           ||' REPETITIVE_TYPE                 ,'
           ||' LOT_CONTROL_CODE                ,'
           ||' ROUNDING_CONTROL_TYPE           ,'
           ||' CALCULATE_ATP                   ,'
           ||' decode(END_ASSEMBLY_PEGGING,null,1,END_ASSEMBLY_PEGGING)  ,'
           ||' decode(NETTABLE_INVENTORY_QUANTITY,null,0,NETTABLE_INVENTORY_QUANTITY )  ,'
           ||' decode(NONNETTABLE_INVENTORY_QUANTITY,NULL,0,NONNETTABLE_INVENTORY_QUANTITY ),'
           ||' ENGINEERING_ITEM_FLAG           ,'
           ||' SAFETY_STOCK_CODE               ,'
           ||' PREPROCESSING_LEAD_TIME                  ,'
           ||' POSTPROCESSING_LEAD_TIME                 ,'
           ||' CUMULATIVE_TOTAL_LEAD_TIME               ,'
           ||' CUM_MANUFACTURING_LEAD_TIME              ,'
           ||' LAST_UPDATE_LOGIN                        ,'
           ||' FIXED_LEAD_TIME                          ,'
           ||' VARIABLE_LEAD_TIME                       ,'
           ||' STANDARD_COST                            ,'
           ||' WIP_SUPPLY_TYPE                          ,'
           ||' OVERRUN_PERCENTAGE                       ,'
           ||' ACCEPTABLE_RATE_INCREASE                 ,'
           ||' ACCEPTABLE_RATE_DECREASE                 ,'
           ||' SAFETY_STOCK_PERCENT                     ,'
           ||' SAFETY_STOCK_BUCKET_DAYS                 ,'
           ||' FIXED_SAFETY_STOCK_QTY                   ,'
           ||' DESCRIPTION                              ,'
           ||' SR_CATEGORY_ID                           ,'
           ||' BUYER_ID                                 ,'
           ||' BUYER_NAME                               ,'
           ||' PLANNER_CODE                             ,'
           ||' ABC_CLASS                                ,'
           ||' REVISION                                 ,'
           ||' FIXED_DAYS_SUPPLY                        ,'
           ||' FIXED_ORDER_QUANTITY                     ,'
           ||' FIXED_LOT_MULTIPLIER                     ,'
           ||' MINIMUM_ORDER_QUANTITY                   ,'
           ||' MAXIMUM_ORDER_QUANTITY                   ,'
           ||' PLANNING_TIME_FENCE_DAYS                 ,'
--           ||' PLANNING_TIME_FENCE_DATE                 ,'
           ||' DEMAND_TIME_FENCE_DAYS                   ,'
           ||' INVENTORY_USE_UP_DATE                    ,'
           ||' ACCEPTABLE_EARLY_DELIVERY                ,'
           ||' PLANNER_STATUS_CODE                      ,'
           ||' SHRINKAGE_RATE                           ,'
           ||' EXCEPTION_SHORTAGE_DAYS                  ,'
           ||' EXCEPTION_EXCESS_DAYS                    ,'
           ||' EXCEPTION_REP_VARIANCE_DAYS              ,'
           ||' EXCEPTION_OVERPROMISED_DAYS              ,'
           ||' PLANNING_EXCEPTION_SET                   ,'
           ||' EXCESS_QUANTITY                          ,'
           ||' REPETITIVE_VARIANCE                      ,'
           ||' BASE_ITEM_ID                             ,'
           ||' ATO_FORECAST_CONTROL                     ,'
           ||' EXCEPTION_CODE                           ,'
           ||' PROGRAM_UPDATE_DATE                      ,'
           ||' REQUEST_ID                               ,'
           ||' PROGRAM_APPLICATION_ID                   ,'
           ||' PROGRAM_ID                               ,'
           ||' DEMAND_TIME_FENCE_DATE                   ,'
           ||' IN_SOURCE_PLAN                  ,'
           ||' BOM_ITEM_TYPE                           ,'
           ||' FULL_PEGGING,                     '
           ||' substr(ORGANIZATION_CODE,5,3)               '
--           ||' EFFECTIVITY_CONTROL   '
           ||' FROM  MSC_SYSTEM_ITEMS msi'
           ||' WHERE msi.plan_id = :PLAN_ID'
           ||' AND   msi.sr_instance_id = :pINSTANCE_ID'
           -- check orgs which are in the plan only bug#7016427 **hbinjola**
           ||' AND msi.ORGANIZATION_ID IN (SELECT MPOV.PLANNED_ORGANIZATION'
           ||' FROM MSC_PLAN_ORGANIZATIONS_V MPOV'
           ||' WHERE MPOV.SR_INSTANCE_ID = :pINSTANCE_ID'
           ||' AND MPOV.COMPILE_DESIGNATOR = :pDESIGNATOR)';


           IF pORGANIZATION_ID IS NOT NULL THEN
              lv_sql_stmt := lv_sql_stmt || ' AND   msi.organization_id = :pORGANIZATION_ID';
           END IF;

           IF pPLANNER IS NOT NULL THEN
              lv_sql_stmt := lv_sql_stmt || ' AND   msi.planner_code = :pPLANNER';
           END IF;

           IF pCATEGORY_ID IS NOT NULL THEN
              lv_sql_stmt := lv_sql_stmt || ' and exists  (select 1 from msc_item_categories mic, msc_category_sets mcs'
                                         ||'  where mic.inventory_item_id = msi.inventory_item_id'
                                         ||'  and  mic.organization_id = msi.organization_id'
                                         ||'  and  mic.sr_instance_id = msi.sr_instance_id'
                                         ||'  and  mic.SR_CATEGORY_ID = :pCATEGORY_ID'
                                         ||'  and mic.category_set_id = mcs.category_set_id'
                                         ||'  and mcs.sr_instance_id = mic.sr_instance_id'
                                         ||'  and mcs.DEFAULT_FLAG = 1)';
           END IF;

           IF pITEM_ID IS NOT NULL THEN
              lv_sql_stmt := lv_sql_stmt || ' AND   msi.sr_inventory_item_id = :pITEM_ID';
           END IF;

           cursor1 := dbms_sql.open_cursor;
           dbms_sql.parse(cursor1, lv_sql_stmt, dbms_sql.v7);

           dbms_sql.bind_variable(cursor1, ':pDESIGNATOR', pDESIGNATOR);
           dbms_sql.bind_variable(cursor1, ':PLAN_ID', c_rec.plan_id);
           dbms_sql.bind_variable(cursor1, ':pINSTANCE_ID', pINSTANCE_ID);
           --bug#7016427 **hbinjola**
           dbms_sql.bind_variable(cursor1, ':pINSTANCE_ID', pINSTANCE_ID);
           dbms_sql.bind_variable(cursor1, ':pDESIGNATOR', pDESIGNATOR);


           IF pORGANIZATION_ID IS NOT NULL THEN
              dbms_sql.bind_variable(cursor1, ':pORGANIZATION_ID', pORGANIZATION_ID);
           END IF;

           IF pPLANNER IS NOT NULL THEN
              dbms_sql.bind_variable(cursor1, ':pPLANNER', pPLANNER);
           END IF;

           IF pCATEGORY_ID IS NOT NULL THEN
              dbms_sql.bind_variable(cursor1, ':pCATEGORY_ID', pCATEGORY_ID);
           END IF;

           IF pITEM_ID IS NOT NULL THEN
              dbms_sql.bind_variable(cursor1, ':pITEM_ID', pITEM_ID);
           END IF;

           v_item_count := dbms_sql.execute(cursor1);
           dbms_sql.close_cursor(cursor1);


           v_buff := 'Number of System items loaded : '||v_item_count;
           LOG_MESSAGE(v_buff);

         END ;

      END LOOP;

         IF pDEMAND = 1 THEN  --for bug 3073566
         FOR c_rec in c1 LOOP
         BEGIN

         v_buff := 'Loading Gross Requirements ..... ';
         LOG_MESSAGE(v_buff);

           lv_sql_stmt:=

           ' INSERT INTO MRP_GROSS_REQUIREMENTS'||v_dblink
           ||' (DEMAND_ID                    ,'
           ||' LAST_UPDATE_DATE              ,'
           ||' LAST_UPDATED_BY               ,'
           ||' CREATION_DATE                 ,'
           ||' CREATED_BY                    ,'
           ||' LAST_UPDATE_LOGIN             ,'
	   ||' INVENTORY_ITEM_ID             ,'
           ||' ORGANIZATION_ID               ,'
           ||' COMPILE_DESIGNATOR            ,'
           ||' USING_ASSEMBLY_ITEM_ID        ,'
           ||' USING_ASSEMBLY_DEMAND_DATE    ,'
           ||' USING_REQUIREMENTS_QUANTITY   ,'
           ||' ASSEMBLY_DEMAND_COMP_DATE     ,'
           ||' DEMAND_TYPE                   ,'
           ||' ORIGINATION_TYPE              ,'
           ||' DISPOSITION_ID                ,'
           ||' DAILY_DEMAND_RATE             ,'
           ||' REQUEST_ID                    ,'
           ||' RESERVE_QUANTITY              ,'
           ||' SOURCE_ORGANIZATION_ID        ,'
           ||' UPDATED                       ,'
           ||' STATUS                        ,'
           ||' APPLIED                       ,'
           ||' DEMAND_CLASS                  ,'
           ||' FIRM_QUANTITY                 ,'
           ||' FIRM_DATE                     ,'
           ||' OLD_DEMAND_QUANTITY           ,'
           ||' DEMAND_SCHEDULE_NAME          ,'
           ||' OLD_DEMAND_DATE               ,'
           ||' PROJECT_ID                    ,'
           ||' TASK_ID                       ,'
           ||' PLANNING_GROUP                )'
           ||' SELECT                    '
           ||' MRP_GROSS_REQUIREMENTS_S.nextval'||v_dblink||' , '
           ||' md.LAST_UPDATE_DATE              ,'
           ||' md.LAST_UPDATED_BY               ,'
           ||' md.CREATION_DATE                 ,'
           ||' md.CREATED_BY                    ,'
           ||' md.LAST_UPDATED_BY               ,'
           ||' msi.SR_INVENTORY_ITEM_ID         ,'
           ||' md.ORGANIZATION_ID               ,'
           ||' :pdesignator                     ,'
           ||' mtil.SR_INVENTORY_ITEM_ID        ,'
           ||' trunc(md.USING_ASSEMBLY_DEMAND_DATE)    ,'
           ||' md.USING_REQUIREMENT_QUANTITY    ,'
           ||' trunc(md.ASSEMBLY_DEMAND_COMP_DATE)     ,'
           ||' md.DEMAND_TYPE                   ,'
           ||' decode(md.ORIGINATION_TYPE,29,7   '
	   ||'                           ,30,6, '
	   ||'                            md.ORIGINATION_TYPE) ,'
           ||' NULL                             ,'
           ||' md.DAILY_DEMAND_RATE             ,'
           ||' NULL                             ,'
           ||' md.RESERVED_QUANTITY             ,'
           ||' md.SOURCE_ORGANIZATION_ID        ,'
           ||' md.UPDATED                       ,'
           ||' md.STATUS                        ,'
           ||' md.APPLIED                       ,'
           ||' md.DEMAND_CLASS                  ,'
           ||' md.FIRM_QUANTITY                 ,'
           ||' md.FIRM_DATE                     ,'
           ||' md.OLD_DEMAND_QUANTITY           ,'
           ||' NULL                             ,'
           ||' md.OLD_DEMAND_DATE               ,'
           ||' md.PROJECT_ID                    ,'
           ||' md.TASK_ID                       ,'
           ||' md.PLANNING_GROUP                 '
           ||' FROM  MSC_DEMANDS md             ,'
           ||'       MSC_SYSTEM_ITEMS msi       ,'
           ||'       MSC_ITEM_ID_LID  mtil       '
           ||' WHERE md.plan_id = :PLAN_ID                        '
           ||' AND   md.sr_instance_id = :pINSTANCE_ID            '
           ||' and   md.USING_ASSEMBLY_DEMAND_DATE BETWEEN trunc(:pHORIZON_START_DATE) and trunc(:pHORIZON_END_DATE) + (1/86400)'
           ||' AND   msi.organization_id = md.organization_id     '
           ||' AND   msi.inventory_item_id = md.inventory_item_id '
           ||' AND   msi.sr_instance_id = md.sr_instance_id       '
           ||' AND   msi.plan_id = md.plan_id                     '
           ||' AND   mtil.sr_instance_id  = md.sr_instance_id     '
           ||' AND   mtil.inventory_item_id = md.USING_ASSEMBLY_ITEM_ID'
           ||' AND   NOT EXISTS (select 1 from msc_system_items msi1'
           ||'        where msi1.inventory_item_id = md.USING_ASSEMBLY_ITEM_ID   '
           ||'        and   msi1.organization_id = md.organization_id '
           ||'        and   msi1.plan_id = md.plan_id '
           ||'        AND   msi1.sr_instance_id = md.sr_instance_id '
           ||'        and   nvl(msi1.release_time_fence_code,-1) = 7)';

           IF pORGANIZATION_ID IS NOT NULL THEN
              lv_sql_stmt := lv_sql_stmt || ' AND   md.organization_id = :pORGANIZATION_ID';
           END IF;

           IF pPLANNER IS NOT NULL THEN
              lv_sql_stmt := lv_sql_stmt || ' AND   msi.planner_code = :pPLANNER';
           END IF;

           IF pCATEGORY_ID IS NOT NULL THEN
              lv_sql_stmt := lv_sql_stmt || ' and exists  (select 1 from msc_item_categories mic, msc_category_sets mcs'
                                         ||'  where mic.inventory_item_id = msi.inventory_item_id'
                                         ||'  and  mic.organization_id = msi.organization_id'
                                         ||'  and  mic.sr_instance_id = msi.sr_instance_id'
                                         ||'  and  mic.SR_CATEGORY_ID = :pCATEGORY_ID'
                                         ||'  and mic.category_set_id = mcs.category_set_id'
                                         ||'  and mcs.sr_instance_id = mic.sr_instance_id'
                                         ||'  and mcs.DEFAULT_FLAG = 1)';
           END IF;

           IF pITEM_ID IS NOT NULL THEN
              lv_sql_stmt := lv_sql_stmt || ' AND   msi.sr_inventory_item_id = :pITEM_ID';
           END IF;

           cursor1 := dbms_sql.open_cursor;
           dbms_sql.parse(cursor1, lv_sql_stmt, dbms_sql.v7);

           dbms_sql.bind_variable(cursor1, ':pDESIGNATOR', pDESIGNATOR);
           dbms_sql.bind_variable(cursor1, ':PLAN_ID', c_rec.plan_id);
           dbms_sql.bind_variable(cursor1, ':pINSTANCE_ID', pINSTANCE_ID);
           dbms_sql.bind_variable(cursor1, ':pHORIZON_START_DATE', lv_start_date);
           dbms_sql.bind_variable(cursor1, ':pHORIZON_END_DATE', lv_end_date);

           IF pORGANIZATION_ID IS NOT NULL THEN
              dbms_sql.bind_variable(cursor1, ':pORGANIZATION_ID', pORGANIZATION_ID);
           END IF;

           IF pPLANNER IS NOT NULL THEN
              dbms_sql.bind_variable(cursor1, ':pPLANNER', pPLANNER);
           END IF;

           IF pCATEGORY_ID IS NOT NULL THEN
              dbms_sql.bind_variable(cursor1, ':pCATEGORY_ID', pCATEGORY_ID);
           END IF;

           IF pITEM_ID IS NOT NULL THEN
              dbms_sql.bind_variable(cursor1, ':pITEM_ID', pITEM_ID);
           END IF;

           v_total_mgr_count := dbms_sql.execute(cursor1);
           dbms_sql.close_cursor(cursor1);


           v_buff := 'Number of Gross Requirements loaded : '||v_total_mgr_count;
           LOG_MESSAGE(v_buff);

         END ;

        END LOOP;
      END IF; --for bug 3073566
      IF to_number(pPLAN_TYPE) = 2 THEN

            select organization_id
              into   lv_organization_id
              from   msc_plans
              where  sr_instance_id = pINSTANCE_ID
              and    compile_designator = pDESIGNATOR;

           lv_sql_stmt :=
                 'DELETE FROM MRP_SCHEDULE_DATES'||v_dblink||' MSD'
                 ||' WHERE MSD.SCHEDULE_DESIGNATOR = :pDESIGNATOR '
                 ||' AND MSD.ORGANIZATION_ID IN (SELECT MPOV.PLANNED_ORGANIZATION'
                 ||' FROM MSC_PLAN_ORGANIZATIONS_V MPOV'
                 ||' WHERE MPOV.SR_INSTANCE_ID = :pINSTANCE_ID'
                 ||' AND MPOV.COMPILE_DESIGNATOR = :pDESIGNATOR)';

           Execute immediate lv_sql_stmt using pDESIGNATOR, pINSTANCE_ID, pDESIGNATOR;

           v_buff := 'Deleted MRP_SCHEDULE_DATES for Plan : '||pDESIGNATOR;
           LOG_MESSAGE(v_buff);

           lv_sql_stmt :=
                 'DELETE FROM MRP_SCHEDULE_ITEMS'||v_dblink||' MSI'
                 ||' WHERE MSI.SCHEDULE_DESIGNATOR = :pDESIGNATOR '
                 ||' AND MSI.ORGANIZATION_ID IN (SELECT MPOV.PLANNED_ORGANIZATION'
                 ||' FROM MSC_PLAN_ORGANIZATIONS_V MPOV'
                 ||' WHERE MPOV.SR_INSTANCE_ID = :pINSTANCE_ID'
                 ||' AND MPOV.COMPILE_DESIGNATOR = :pDESIGNATOR)';

           Execute immediate lv_sql_stmt using pDESIGNATOR, pINSTANCE_ID, pDESIGNATOR;

           v_buff := 'Deleted MRP_SCHEDULE_ITEMS for Plan : '||pDESIGNATOR;
           LOG_MESSAGE(v_buff);

           lv_sql_stmt:=
                  ' BEGIN'
                ||' mrp_planner_pk.create_new_planner_mps_entries'||v_dblink||
                                                               '(arg_compile_desig => :pDESIGNATOR ,
                                                                 arg_sched_desig   => to_char(null),
                                                                 arg_org_id        => :ORGANIZATION_ID );'
                 ||' END;';

            EXECUTE IMMEDIATE lv_sql_stmt USING pDESIGNATOR, lv_organization_id;

            v_buff := 'Loaded MRP_SCHEDULE_DATES for Plan : '||pDESIGNATOR;
            LOG_MESSAGE(v_buff);

            SELECT FND_GLOBAL.USER_ID
      			INTO lv_user_id
     				FROM dual;

              lv_sql_stmt:= ' INSERT INTO MRP_SCHEDULE_ITEMS'||v_dblink
                            ||'     (INVENTORY_ITEM_ID,'
                            ||'      ORGANIZATION_ID,'
                            ||'      SCHEDULE_DESIGNATOR,'
                            ||'      LAST_UPDATE_DATE,'
                            ||'      LAST_UPDATED_BY,'
                            ||'      creation_date,'
                            ||'      created_by,'
                            ||'      last_update_login,'
                            ||'      MPS_EXPLOSION_LEVEL)'
                          ||' SELECT DISTINCT dates.inventory_item_id,'
                            ||'      dates.organization_id,'
                            ||'      :compile_desig,'
                            ||'      SYSDATE,'
                            ||'      :user_id,'
                            ||'      SYSDATE,'
                            ||'      :user_id,'
                            ||'      -1,'
                            ||'      100 /* this has no meaning for an MRP part */'
                          ||' FROM    mrp_schedule_dates'||v_dblink||' dates,'
                            ||'      mrp_system_items'||v_dblink||' data,'
                            ||'      mrp_plan_organizations_v'||v_dblink||' mpo'
                          ||' WHERE   NOT EXISTS'
                            ||'     (SELECT inventory_item_id'
                            ||'      FROM    mrp_schedule_items'||v_dblink||' items'
                            ||'      WHERE   items.organization_id ='
                            ||'                          mpo.planned_organization'
                            ||'        AND   items.inventory_item_id ='
                            ||'                          dates.inventory_item_id'
                            ||'        AND   items.schedule_designator ='
                            ||'                          mpo.compile_designator)'
                            ||' AND   dates.organization_id = data.organization_id'
                            ||' AND   dates.schedule_designator = data.compile_designator'
                            ||' AND   dates.inventory_item_id = data.inventory_item_id'
                            ||' AND   data.mrp_planning_code IN'
                            ||'          (4, 8)'
                            ||' AND   data.organization_id = mpo.planned_organization'
                            ||' AND   data.compile_designator = mpo.compile_designator'
                            ||' AND   mpo.organization_id = :org_id'
                            ||' AND   mpo.compile_designator = :compile_desig';

            EXECUTE IMMEDIATE lv_sql_stmt USING pDESIGNATOR,lv_user_id,lv_user_id, lv_organization_id, pDESIGNATOR;

            v_buff := 'Loaded MRP_SCHEDULE_ITEMS for Plan : '||pDESIGNATOR;
            LOG_MESSAGE(v_buff);

      END IF;
      COMMIT;
      END IF;

      IF RETCODE = G_ERROR THEN
           ERRBUF := v_errbuf;
           RETCODE := v_retcode;
           RETURN;
      END IF;

      EXCEPTION

         WHEN A2A_EXCEPTION THEN
              null;        -- just to terminate the process

         WHEN OTHERS THEN

            RAISE;
            ERRBUF := SQLERRM;
            RETCODE := G_ERROR;

            LOG_MESSAGE(SQLERRM);

            RETURN;

   END PUSH_PLAN_INFO; --Main

--=========================================================================

END MSC_M2A_PUSH;

/
