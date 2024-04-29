--------------------------------------------------------
--  DDL for Package Body MSC_CL_WIP_ODS_LOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_CL_WIP_ODS_LOAD" AS -- specification
/* $Header: MSCLWIPB.pls 120.1.12010000.6 2010/03/25 01:15:18 harshsha ship $ */

  -- v_sub_str                     VARCHAR2(4000):=NULL;
--   c_count                       NUMBER:= 0;
--   v_warning_flag                NUMBER:= MSC_UTIL.SYS_NO;  --2 be changed

--   G_COLLECT_SRP_DATA       VARCHAR2(1) :=  NVL(FND_PROFILE.VALUE('MSC_SRP_ENABLED'),'N');
   -- To collect SRP Data when this profile is set to Yes   neds to be deleted
 --  v_is_cont_refresh             BOOLEAN;   -- 2 be changed
--   v_chr9                        VARCHAR2(1) := FND_GLOBAL.LOCAL_CHR(9);
--   v_chr10                       VARCHAR2(1) := FND_GLOBAL.LOCAL_CHR(10);
--   v_chr13                       VARCHAR2(1) := FND_GLOBAL.LOCAL_CHR(13);



--   PROCEDURE LOAD_JOB_DETAILS; --for job details
   PROCEDURE LOAD_JOB_OP_RES_INSTANCE;
   PROCEDURE LOAD_JOB_OP_NWK;
   PROCEDURE LOAD_JOB_OP;
   PROCEDURE LOAD_JOB_REQ_OP;
   PROCEDURE LOAD_JOB_OP_RES;

--   PROCEDURE LOAD_WIP_DEMAND; -- called by load_supply
--   PROCEDURE LOAD_RES_REQ;    -- called by load_supply


   PROCEDURE LOAD_JOB_DETAILS IS
   BEGIN
   LOAD_JOB_OP_NWK;
   LOAD_JOB_OP;
   LOAD_JOB_REQ_OP;
   LOAD_JOB_OP_RES;
   LOAD_JOB_OP_RES_INSTANCE;
   END LOAD_JOB_DETAILS;

--==============================================================

PROCEDURE LOAD_JOB_OP_RES_INSTANCE IS

  TYPE CurTyp IS REF CURSOR; -- define weak REF CURSOR type
   cgen              CurTyp;

   lv_tbl          VARCHAR2(30);
   lv_supplies_tbl VARCHAR2(30);

   lv_cursor_stmt VARCHAR2(5000);
   lv_sql_stmt    VARCHAR2(32767);

   lv_TRANSACTION_ID NUMBER;
   lv_OPERATION_SEQ_NUM NUMBER;
   lv_SR_INSTANCE_ID NUMBER;
   lv_RESOURCE_SEQ_NUM NUMBER;
   lv_RESOURCE_ID  NUMBER;
   lv_DEPARTMENT_ID    NUMBER;
   lv_ORGANIZATION_ID NUMBER;
   lv_RES_INSTANCE_ID                  NUMBER;
   lv_EQUIPMENT_ITEM_ID                NUMBER;
   lv_SERIAL_NUMBER                    VARCHAR2(30);
   lv_START_DATE		       DATE;
   lv_COMPLETION_DATE	      		DATE;
   --lv_RES_INSTANCE_HOURS		NUMBER;
   lv_BATCH_NUMBER			NUMBER;
    c_count         NUMBER:=0;
  total_count      NUMBER:=0;

  lv_errbuf			VARCHAR2(240);
  lv_retcode			NUMBER;

BEGIN

IF MSC_CL_COLLECTION.v_exchange_mode=MSC_UTIL.SYS_YES THEN
   lv_tbl:= 'JOB_OP_RES_INSTANCES_'||MSC_CL_COLLECTION.v_instance_code;
   lv_supplies_tbl:= 'SUPPLIES_'||MSC_CL_COLLECTION.v_instance_code;
ELSE
   lv_tbl:= 'MSC_JOB_OP_RES_INSTANCES';
   lv_supplies_tbl:= 'MSC_SUPPLIES';
END IF;

IF MSC_CL_COLLECTION.v_is_incremental_refresh THEN

   lv_cursor_stmt:=
	'SELECT'
	||'    ms.TRANSACTION_ID,'
	||'    resi.OPERATION_SEQ_NUM,'
	||'    resi.RESOURCE_SEQ_NUM,'
	||'    resi.RESOURCE_ID,'
	||'    resi.RES_INSTANCE_ID,'
	||'    resi.SERIAL_NUMBER,'
	||'    t1.inventory_item_id EQUIPMENT_ITEM_ID,'
	||'    resi.SR_INSTANCE_ID'
	||' FROM '||lv_supplies_tbl||' ms,'
	||'   MSC_ST_JOB_OP_RES_INSTANCES resi,'
	||'   MSC_ITEM_ID_LID t1 '
	||' WHERE resi.SR_INSTANCE_ID= '||MSC_CL_COLLECTION.v_instance_id
	||'  AND ms.PLAN_ID= -1'
	||'  AND ms.SR_INSTANCE_ID= resi.SR_INSTANCE_ID'
	||'  AND ms.DISPOSITION_ID= resi.WIP_ENTITY_ID'
	||'  AND ms.ORDER_TYPE IN ( 3, 7)'
	||'  AND resi.DELETED_FLAG= '||MSC_UTIL.SYS_YES
 	||'  AND t1.sr_inventory_item_id (+) = resi.equipment_item_id '
 	||'  AND t1.SR_INSTANCE_ID (+) = resi.SR_INSTANCE_ID ';


    OPEN cgen FOR lv_cursor_stmt;

    IF (cgen%ISOPEN) THEN

	LOOP

	   FETCH cgen INTO
                  lv_TRANSACTION_ID,
                  lv_OPERATION_SEQ_NUM,
                  lv_RESOURCE_SEQ_NUM,
                  lv_RESOURCE_ID,
                  lv_RES_INSTANCE_ID,
                  lv_SERIAL_NUMBER,
                  lv_EQUIPMENT_ITEM_ID,
                  lv_SR_INSTANCE_ID;

 	   EXIT WHEN cgen%NOTFOUND;

 	   DELETE MSC_JOB_OP_RES_INSTANCES
 	   WHERE PLAN_ID= -1
   	   AND TRANSACTION_ID = lv_TRANSACTION_ID
   	   AND SR_INSTANCE_ID = lv_SR_INSTANCE_ID
   	   AND OPERATION_SEQ_NUM = nvl(lv_OPERATION_SEQ_NUM,OPERATION_SEQ_NUM)
   	   AND RESOURCE_SEQ_NUM = nvl(lv_RESOURCE_SEQ_NUM,RESOURCE_SEQ_NUM)
   	   AND RESOURCE_ID = nvl(lv_RESOURCE_ID,RESOURCE_ID)
   	   AND RES_INSTANCE_ID = nvl(lv_RES_INSTANCE_ID,RES_INSTANCE_ID)
   	   AND SERIAL_NUMBER = nvl(lv_SERIAL_NUMBER,SERIAL_NUMBER);


	END LOOP;

    END IF; /* cgen%ISOPEN */

    COMMIT;

    CLOSE cgen;

END IF;  /*Incremental*/

    lv_cursor_stmt:=
     'SELECT'
     ||'   ms.TRANSACTION_ID,'
     ||'   resi.OPERATION_SEQ_NUM ,'
     ||'   resi.SR_INSTANCE_ID,'
     ||'   resi.RESOURCE_SEQ_NUM,'
     ||'   resi.ORGANIZATION_ID,'
     ||'   resi.RESOURCE_ID,'
     ||'   resi.RES_INSTANCE_ID,'
     ||'   resi.SERIAL_NUMBER,'
     ||'   t1.inventory_item_id EQUIPMENT_ITEM_ID,'
     ||'   resi.DEPARTMENT_ID,'
     ||'   resi.START_DATE,'
     ||'   resi.COMPLETION_DATE,'
     --||'   resi.RES_INSTANCE_HOURS,'
     ||'   resi.BATCH_NUMBER'
     ||' FROM '||lv_supplies_tbl||' ms,'
     ||'      MSC_ST_JOB_OP_RES_INSTANCES resi, '
     ||'   MSC_ITEM_ID_LID t1 '
     ||' WHERE resi.SR_INSTANCE_ID= '||MSC_CL_COLLECTION.v_instance_id
     ||'  AND ms.PLAN_ID= -1'
     ||'  AND ms.SR_INSTANCE_ID= resi.SR_INSTANCE_ID'
     ||'  AND ms.DISPOSITION_ID= resi.WIP_ENTITY_ID'
     ||'  AND ms.ORDER_TYPE IN ( 3, 7)'
     ||'  AND resi.DELETED_FLAG= '||MSC_UTIL.SYS_NO
     ||'  AND t1.sr_inventory_item_id (+) = resi.equipment_item_id '
     ||'  AND t1.SR_INSTANCE_ID (+) = resi.SR_INSTANCE_ID ';

     -- ========= Prepare SQL Statement for INSERT ==========
     lv_sql_stmt:=
     'insert into '||lv_tbl
     ||'  ( PLAN_ID,'
     ||'   TRANSACTION_ID,'
     ||'   OPERATION_SEQ_NUM,'
     ||'   RESOURCE_SEQ_NUM,'
     ||'   RESOURCE_ID,'
     ||'   RES_INSTANCE_ID,'
     ||'   SERIAL_NUMBER,'
     ||'   EQUIPMENT_ITEM_ID,'
     ||'   START_DATE,'
     ||'   COMPLETION_DATE,'
     ||'   BATCH_NUMBER,'
     ||'    SR_INSTANCE_ID,'
     ||'    REFRESH_NUMBER,'
     ||'    LAST_UPDATE_DATE,'
     ||'    LAST_UPDATED_BY,'
     ||'    CREATION_DATE,'
     ||'    CREATED_BY)'
     ||'VALUES'
     ||'(   -1,'
     ||'   :TRANSACTION_ID,'
     ||'   :OPERATION_SEQ_NUM,'
     ||'   :RESOURCE_SEQ_NUM,'
     ||'   :RESOURCE_ID,'
     ||'   :RES_INSTANCE_ID,'
     ||'   :SERIAL_NUMBER,'
     ||'   :EQUIPMENT_ITEM_ID,'
     ||'   :START_DATE,'
     ||'   :COMPLETION_DATE,'
     ||'   :BATCH_NUMBER,'
     ||'    :SR_INSTANCE_ID,'
     ||'    :REFRESH_NUMBER,'
     ||'    :v_current_date,'
     ||'    :v_current_user,'
     ||'    :v_current_date,'
     ||'    :v_current_user)';
     --log_debug(lv_cursor_stmt);
     --MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, lv_sql_stmt);
     OPEN cgen FOR lv_cursor_stmt;
     IF (cgen%ISOPEN) THEN

       LOOP
        FETCH cgen INTO
        lv_TRANSACTION_ID ,
        lv_OPERATION_SEQ_NUM ,
        lv_SR_INSTANCE_ID ,
        lv_RESOURCE_SEQ_NUM ,
        lv_ORGANIZATION_ID ,
        lv_RESOURCE_ID   ,
        lv_RES_INSTANCE_ID,
        lv_SERIAL_NUMBER ,
        lv_EQUIPMENT_ITEM_ID,
        lv_DEPARTMENT_ID  ,
        lv_START_DATE ,
        lv_COMPLETION_DATE ,
        --lv_RES_INSTANCE_HOURS,
        lv_BATCH_NUMBER ;

        EXIT WHEN cgen%NOTFOUND;

        BEGIN

        IF MSC_CL_COLLECTION.v_is_incremental_refresh THEN
        /* we can get rid of thsi update if we insert in ad table when instance is updated */
          UPDATE MSC_JOB_OP_RES_INSTANCES
          SET
           START_DATE =  lv_START_DATE,
           COMPLETION_DATE = lv_COMPLETION_DATE,
           BATCH_NUMBER   = lv_BATCH_NUMBER,
           REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
           LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
           LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
         WHERE PLAN_ID=   -1
          AND SR_INSTANCE_ID    =   lv_SR_INSTANCE_ID
          AND TRANSACTION_ID    =   lv_TRANSACTION_ID
          AND ORGANIZATION_ID   =   lv_ORGANIZATION_ID
          AND OPERATION_SEQ_NUM =  lv_OPERATION_SEQ_NUM
          AND RESOURCE_SEQ_NUM  = lv_RESOURCE_SEQ_NUM
          AND RES_INSTANCE_ID = lv_RES_INSTANCE_ID
	  AND SERIAL_NUMBER	= lv_SERIAL_NUMBER;

        END IF;

        IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) OR SQL%NOTFOUND THEN

          EXECUTE IMMEDIATE lv_sql_stmt
           USING
           lv_TRANSACTION_ID ,
           lv_OPERATION_SEQ_NUM ,
           lv_RESOURCE_SEQ_NUM ,
	   lv_RESOURCE_ID,
	   lv_RES_INSTANCE_ID,
	   lv_SERIAL_NUMBER,
	   lv_EQUIPMENT_ITEM_ID,
           lv_START_DATE,
           lv_COMPLETION_DATE,
           lv_ORGANIZATION_ID ,
           lv_BATCH_NUMBER,
           lv_SR_INSTANCE_ID,
            MSC_CL_COLLECTION.v_last_collection_id,
            MSC_CL_COLLECTION.v_current_date,
            MSC_CL_COLLECTION.v_current_user,
            MSC_CL_COLLECTION.v_current_date,
            MSC_CL_COLLECTION.v_current_user;
        END IF;
  	total_count := total_count + 1;
  	c_count:= c_count+1;

  	IF c_count> MSC_CL_COLLECTION.PBS THEN
     		IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) THEN COMMIT; END IF;
     			c_count:= 0;
  	END IF;

      EXCEPTION
         WHEN OTHERS THEN

          IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN

            MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
            FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_JOB_OP_RES_INSTANCE');
            FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_JOB_OP_RES_INSTANCES');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

            MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
            RAISE;

          ELSE

            MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

            MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
            FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
            FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_JOB_OP_RES_INSTANCE');
            FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_JOB_OP_RES_INSTANCES');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

            FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
            FND_MESSAGE.SET_TOKEN('COLUMN', 'ORGANIZATION_CODE');
            FND_MESSAGE.SET_TOKEN('VALUE',
                                  MSC_GET_NAME.ORG_CODE( lv_ORGANIZATION_ID,
                                                         MSC_CL_COLLECTION.v_instance_id));
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

            MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
          END IF;

      END;
    END LOOP;

    MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Total MSC_JOB_OP_RES_INSTANCES = '||  to_char(total_count));
  END IF; /* cgen%ISOPEN */

CLOSE cgen;

COMMIT;

BEGIN

   IF ((MSC_CL_COLLECTION.v_coll_prec.org_group_flag <> MSC_UTIL.G_ALL_ORGANIZATIONS ) AND (MSC_CL_COLLECTION.v_exchange_mode=MSC_UTIL.SYS_YES)) THEN

        lv_tbl:= 'JOB_OP_RES_INSTANCES_'||MSC_CL_COLLECTION.v_instance_code;

        lv_sql_stmt:=
         'INSERT INTO '||lv_tbl
          ||' SELECT * from MSC_JOB_OP_RES_INSTANCES'
          ||' WHERE sr_instance_id = '||MSC_CL_COLLECTION.v_instance_id
          ||' AND plan_id = -1 '
          ||' AND organization_id not '||MSC_UTIL.v_in_org_str;

         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'The sql statement is '||lv_sql_stmt);
         EXECUTE IMMEDIATE lv_sql_stmt;

         COMMIT;

   END IF;

 EXCEPTION
    WHEN OTHERS THEN

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RAISE;
END;

IF MSC_CL_COLLECTION.v_exchange_mode=MSC_UTIL.SYS_YES THEN
   MSC_CL_COLLECTION.alter_temp_table (lv_errbuf,
   	              lv_retcode,
                      'MSC_JOB_OP_RES_INSTANCES',
                      MSC_CL_COLLECTION.v_instance_code,
                      MSC_UTIL.G_WARNING
                     );

   IF lv_retcode = MSC_UTIL.G_ERROR THEN
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, lv_errbuf);
      RAISE MSC_CL_COLLECTION.ALTER_TEMP_TABLE_ERROR;
   ELSIF lv_retcode = MSC_UTIL.G_WARNING THEN
      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;
   END IF;

END IF;

EXCEPTION
   WHEN OTHERS THEN
      IF cgen%ISOPEN THEN
	CLOSE cgen;
      END IF;
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '<<LOAD_JOB_OP_RES_INSTANCE>>');
      IF lv_cursor_stmt IS NOT NULL THEN
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '<<CURSOR>>'||lv_cursor_stmt);
      END IF;
      IF lv_sql_stmt IS NOT NULL THEN
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '<<SQL>>'||lv_sql_stmt);
      END IF;
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  SQLERRM);
      RAISE;
END LOAD_JOB_OP_RES_INSTANCE;

--================================================================
PROCEDURE LOAD_JOB_OP IS

   TYPE CurTyp IS REF CURSOR; -- define weak REF CURSOR type

   cgen              CurTyp;

   lv_tbl          VARCHAR2(30);
   lv_supplies_tbl VARCHAR2(30);

   lv_cursor_stmt VARCHAR2(5000);
   lv_sql_stmt    VARCHAR2(32767);


   lv_TRANSACTION_ID NUMBER;
   lv_OPERATION_SEQ_NUM NUMBER;
   lv_SR_INSTANCE_ID NUMBER;
   lv_RECOMMENDED    VARCHAR2(1);
   lv_NETWORK_START_END   VARCHAR2(1);
   lv_RECO_START_DATE  DATE;
   lv_ORGANIZATION_ID   NUMBER;
   lv_RECO_COMPLETION_DATE DATE;
   lv_OPERATION_SEQUENCE_ID  NUMBER;
   lv_STANDARD_OPERATION_CODE  VARCHAR2(4);
   lv_DEPARTMENT_ID  NUMBER;
   lv_OP_LT_PERCENT  NUMBER;
   lv_MINIMUM_TRANSFER_QUANTITY   NUMBER;
   lv_EFFECTIVITY_DATE   DATE;
   lv_DISABLE_DATE   DATE;
   lv_OPERATION_TYPE  NUMBER;
   lv_YIELD   NUMBER;
   lv_CUMULATIVE_YIELD  NUMBER;
   lv_REVERSE_CUMULATIVE_YIELD  NUMBER;
   lv_NET_PLANNING_PERCENT  NUMBER;
   total_count  	    NUMBER := 0;

  lv_errbuf			VARCHAR2(240);
  lv_retcode			NUMBER;

BEGIN

IF MSC_CL_COLLECTION.v_exchange_mode=MSC_UTIL.SYS_YES THEN
   lv_tbl:= 'JOB_OPERATIONS_'||MSC_CL_COLLECTION.v_instance_code;
   lv_supplies_tbl:= 'SUPPLIES_'||MSC_CL_COLLECTION.v_instance_code;
ELSE
   lv_tbl:= 'MSC_JOB_OPERATIONS';
   lv_supplies_tbl:= 'MSC_SUPPLIES';
END IF;

IF MSC_CL_COLLECTION.v_is_incremental_refresh THEN

lv_cursor_stmt:=
'SELECT'
||'    ms.TRANSACTION_ID,'
||'    opr.OPERATION_SEQ_NUM,'
||'    opr.SR_INSTANCE_ID'
||' FROM '||lv_supplies_tbl||' ms,'
||'      MSC_ST_JOB_OPERATIONS opr'
||' WHERE opr.SR_INSTANCE_ID= '||MSC_CL_COLLECTION.v_instance_id
||'  AND ms.PLAN_ID= -1'
||'  AND ms.SR_INSTANCE_ID= opr.SR_INSTANCE_ID'
||'  AND ms.DISPOSITION_ID= opr.WIP_ENTITY_ID'
||'  AND ms.ORDER_TYPE IN ( 3, 7)'
||'  AND opr.DELETED_FLAG= '||MSC_UTIL.SYS_YES;

OPEN cgen FOR lv_cursor_stmt;

IF (cgen%ISOPEN) THEN

LOOP

FETCH cgen INTO
                  lv_TRANSACTION_ID,
                  lv_OPERATION_SEQ_NUM,
                  lv_SR_INSTANCE_ID;

EXIT WHEN cgen%NOTFOUND;

 DELETE MSC_JOB_OPERATIONS
 WHERE PLAN_ID= -1
   AND TRANSACTION_ID = lv_TRANSACTION_ID
   AND SR_INSTANCE_ID = lv_SR_INSTANCE_ID
   AND OPERATION_SEQ_NUM = nvl(lv_OPERATION_SEQ_NUM,OPERATION_SEQ_NUM);


END LOOP;

END IF;

COMMIT;

CLOSE cgen;

END IF;  /*Incremental*/

lv_cursor_stmt:=
'SELECT'
||'    ms.TRANSACTION_ID,'
||'    opr.OPERATION_SEQ_NUM,'
||'    opr.SR_INSTANCE_ID,'
||'    opr.ORGANIZATION_ID,'
||'    opr.RECOMMENDED,'
||'    opr.NETWORK_START_END,'
||'    opr.RECO_START_DATE,'
||'    opr.RECO_COMPLETION_DATE,'
||'    opr.OPERATION_SEQUENCE_ID,'
||'    opr.STANDARD_OPERATION_CODE,'
||'    opr.DEPARTMENT_ID,'
||'    opr.OPERATION_LEAD_TIME_PERCENT,'
||'    opr.MINIMUM_TRANSFER_QUANTITY,'
||'    opr.EFFECTIVITY_DATE,'
||'    opr.DISABLE_DATE,'
||'    opr.OPERATION_TYPE,'
||'    opr.YIELD,'
||'    opr.CUMULATIVE_YIELD,'
||'    opr.REVERSE_CUMULATIVE_YIELD,'
||'    opr.NET_PLANNING_PERCENT'
||' FROM '||lv_supplies_tbl||' ms,'
||'      MSC_ST_JOB_OPERATIONS opr'
||' WHERE opr.SR_INSTANCE_ID= '||MSC_CL_COLLECTION.v_instance_id
||'  AND ms.PLAN_ID= -1'
||'  AND ms.SR_INSTANCE_ID= opr.SR_INSTANCE_ID'
||'  AND ms.DISPOSITION_ID= opr.WIP_ENTITY_ID'
||'  AND ms.ORDER_TYPE IN ( 3, 7)'
||'  AND opr.DELETED_FLAG= '||MSC_UTIL.SYS_NO;


-- ========= Prepare SQL Statement for INSERT ==========
lv_sql_stmt:=
'insert into '||lv_tbl
||'  ( PLAN_ID,'
||'    TRANSACTION_ID,'
||'    OPERATION_SEQ_NUM,'
||'    ORGANIZATION_ID,'
||'    RECOMMENDED,'
||'    NETWORK_START_END,'
||'    RECO_START_DATE,'
||'    RECO_COMPLETION_DATE,'
||'    OPERATION_SEQUENCE_ID,'
||'    STANDARD_OPERATION_CODE,'
||'    DEPARTMENT_ID,'
||'    OPERATION_LEAD_TIME_PERCENT,'
||'    MINIMUM_TRANSFER_QUANTITY,'
||'    EFFECTIVITY_DATE,'
||'    DISABLE_DATE,'
||'    OPERATION_TYPE,'
||'    YIELD,'
||'    CUMULATIVE_YIELD,'
||'    REVERSE_CUMULATIVE_YIELD,'
||'    NET_PLANNING_PERCENT,'
||'    SR_INSTANCE_ID,'
||'    REFRESH_NUMBER,'
||'    LAST_UPDATE_DATE,'
||'    LAST_UPDATED_BY,'
||'    CREATION_DATE,'
||'    CREATED_BY)'
||'VALUES'
||'(   -1,'
||'    :TRANSACTION_ID,'
||'    :OPERATION_SEQ_NUM,'
||'    :ORGANIZATION_ID,'
||'    :RECOMMENDED,'
||'    :NETWORK_START_END,'
||'    :RECO_START_DATE,'
||'    :RECO_COMPLETION_DATE,'
||'    :OPERATION_SEQUENCE_ID,'
||'    :STANDARD_OPERATION_CODE,'
||'    :DEPARTMENT_ID,'
||'    :OPERATION_LEAD_TIME_PERCENT,'
||'    :MINIMUM_TRANSFER_QUANTITY,'
||'    :EFFECTIVITY_DATE,'
||'    :DISABLE_DATE,'
||'    :OPERATION_TYPE,'
||'    :YIELD,'
||'    :CUMULATIVE_YIELD,'
||'    :REVERSE_CUMULATIVE_YIELD,'
||'    :NET_PLANNING_PERCENT,'
||'    :SR_INSTANCE_ID,'
||'    :REFRESH_NUMBER,'
||'    :v_current_date,'
||'    :v_current_user,'
||'    :v_current_date,'
||'    :v_current_user)';

OPEN cgen FOR lv_cursor_stmt;

IF (cgen%ISOPEN) THEN

LOOP

FETCH cgen INTO
    lv_TRANSACTION_ID,
    lv_OPERATION_SEQ_NUM,
    lv_SR_INSTANCE_ID,
    lv_ORGANIZATION_ID,
    lv_RECOMMENDED,
    lv_NETWORK_START_END,
    lv_RECO_START_DATE,
    lv_RECO_COMPLETION_DATE,
    lv_OPERATION_SEQUENCE_ID,
    lv_STANDARD_OPERATION_CODE,
    lv_DEPARTMENT_ID,
    lv_OP_LT_PERCENT,
    lv_MINIMUM_TRANSFER_QUANTITY,
    lv_EFFECTIVITY_DATE,
    lv_DISABLE_DATE,
    lv_OPERATION_TYPE,
    lv_YIELD,
    lv_CUMULATIVE_YIELD,
    lv_REVERSE_CUMULATIVE_YIELD,
    lv_NET_PLANNING_PERCENT;

EXIT WHEN cgen%NOTFOUND;

BEGIN

IF MSC_CL_COLLECTION.v_is_incremental_refresh THEN

UPDATE MSC_JOB_OPERATIONS
SET
    RECOMMENDED = lv_RECOMMENDED,
    NETWORK_START_END = lv_NETWORK_START_END,
    RECO_START_DATE = lv_RECO_START_DATE,
    RECO_COMPLETION_DATE = lv_RECO_COMPLETION_DATE,
    OPERATION_SEQUENCE_ID = lv_OPERATION_SEQUENCE_ID,
    STANDARD_OPERATION_CODE = lv_STANDARD_OPERATION_CODE,
    DEPARTMENT_ID = lv_DEPARTMENT_ID,
    OPERATION_LEAD_TIME_PERCENT = lv_OP_LT_PERCENT,
    MINIMUM_TRANSFER_QUANTITY = lv_MINIMUM_TRANSFER_QUANTITY,
    EFFECTIVITY_DATE = lv_EFFECTIVITY_DATE,
    DISABLE_DATE = lv_DISABLE_DATE,
    OPERATION_TYPE = lv_OPERATION_TYPE,
    YIELD = lv_YIELD,
    CUMULATIVE_YIELD = lv_CUMULATIVE_YIELD,
    REVERSE_CUMULATIVE_YIELD = lv_REVERSE_CUMULATIVE_YIELD,
    NET_PLANNING_PERCENT =  lv_NET_PLANNING_PERCENT,
   REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
   LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
   LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
WHERE PLAN_ID=   -1
  AND SR_INSTANCE_ID=   lv_SR_INSTANCE_ID
  AND TRANSACTION_ID=   lv_TRANSACTION_ID
  AND ORGANIZATION_ID=   lv_ORGANIZATION_ID
  AND OPERATION_SEQ_NUM =  lv_OPERATION_SEQ_NUM;


END IF;

IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) OR SQL%NOTFOUND THEN

EXECUTE IMMEDIATE lv_sql_stmt
USING
    lv_TRANSACTION_ID,
    lv_OPERATION_SEQ_NUM,
    lv_ORGANIZATION_ID,
    lv_RECOMMENDED,
    lv_NETWORK_START_END,
    lv_RECO_START_DATE,
    lv_RECO_COMPLETION_DATE,
    lv_OPERATION_SEQUENCE_ID,
    lv_STANDARD_OPERATION_CODE,
    lv_DEPARTMENT_ID,
    lv_OP_LT_PERCENT,
    lv_MINIMUM_TRANSFER_QUANTITY,
    lv_EFFECTIVITY_DATE,
    lv_DISABLE_DATE,
    lv_OPERATION_TYPE,
    lv_YIELD,
    lv_CUMULATIVE_YIELD,
    lv_REVERSE_CUMULATIVE_YIELD,
    lv_NET_PLANNING_PERCENT,
    lv_SR_INSTANCE_ID,
    MSC_CL_COLLECTION.v_last_collection_id,
    MSC_CL_COLLECTION.v_current_date,
    MSC_CL_COLLECTION.v_current_user,
    MSC_CL_COLLECTION.v_current_date,
    MSC_CL_COLLECTION.v_current_user;
  total_count := total_count + 1;
END IF;


EXCEPTION
   WHEN OTHERS THEN

    IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_JOB_OP');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_JOB_OPERATIONS');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RAISE;

    ELSE

      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_JOB_OP');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_JOB_OPERATIONS');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'ORGANIZATION_CODE');
      FND_MESSAGE.SET_TOKEN('VALUE',
                            MSC_GET_NAME.ORG_CODE( lv_ORGANIZATION_ID,
                                                   MSC_CL_COLLECTION.v_instance_id));
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
    END IF;

END;

END LOOP;

   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Total MSC_JOB_OPERATIONS = '||  total_count);
END IF;

CLOSE cgen;

COMMIT;

BEGIN

IF ((MSC_CL_COLLECTION.v_coll_prec.org_group_flag <> MSC_UTIL.G_ALL_ORGANIZATIONS ) AND (MSC_CL_COLLECTION.v_exchange_mode=MSC_UTIL.SYS_YES)) THEN

lv_tbl:= 'JOB_OPERATIONS_'||MSC_CL_COLLECTION.v_instance_code;

lv_sql_stmt:=
         'INSERT INTO '||lv_tbl
          ||' SELECT * from MSC_JOB_OPERATIONS'
          ||' WHERE sr_instance_id = '||MSC_CL_COLLECTION.v_instance_id
          ||' AND plan_id = -1 '
          ||' AND organization_id not '||MSC_UTIL.v_in_org_str;

   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'The sql statement is '||lv_sql_stmt);
   EXECUTE IMMEDIATE lv_sql_stmt;

   COMMIT;

END IF;

EXCEPTION
  WHEN OTHERS THEN

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RAISE;
END;

IF MSC_CL_COLLECTION.v_exchange_mode=MSC_UTIL.SYS_YES THEN
   MSC_CL_COLLECTION.alter_temp_table (lv_errbuf,
   	              lv_retcode,
                      'MSC_JOB_OPERATIONS',
                      MSC_CL_COLLECTION.v_instance_code,
                      MSC_UTIL.G_WARNING
                     );

   IF lv_retcode = MSC_UTIL.G_ERROR THEN
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, lv_errbuf);
      RAISE MSC_CL_COLLECTION.ALTER_TEMP_TABLE_ERROR;
   ELSIF lv_retcode = MSC_UTIL.G_WARNING THEN
      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;
   END IF;

END IF;

EXCEPTION
   WHEN OTHERS THEN
      IF cgen%ISOPEN THEN CLOSE cgen; END IF;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '<<LOAD_JOB_OP>>');
      IF lv_cursor_stmt IS NOT NULL THEN
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '<<CURSOR>>'||lv_cursor_stmt);
      END IF;
      IF lv_sql_stmt IS NOT NULL THEN
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '<<SQL>>'||lv_sql_stmt);
      END IF;
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  SQLERRM);
      RAISE;
END LOAD_JOB_OP;

--===============================================================
PROCEDURE LOAD_JOB_OP_RES IS

   TYPE CurTyp IS REF CURSOR; -- define weak REF CURSOR type
   cgen              CurTyp;

   lv_tbl          VARCHAR2(30);
   lv_supplies_tbl VARCHAR2(30);

   lv_cursor_stmt VARCHAR2(5000);
   lv_sql_stmt    VARCHAR2(32767);

   lv_TRANSACTION_ID NUMBER;
   lv_OPERATION_SEQ_NUM NUMBER;
   lv_SR_INSTANCE_ID NUMBER;
   lv_RESOURCE_SEQ_NUM NUMBER;
   lv_ALTERNATE_NUM NUMBER;
   lv_RECOMMENDED   VARCHAR2(1);
   lv_RECO_START_DATE  DATE;
   lv_RECO_COMPLETION_DATE DATE;
   lv_RESOURCE_ID  NUMBER;
   lv_ASSIGNED_UNITS NUMBER;
   lv_USAGE_RATE_OR_AMOUNT NUMBER;
   lv_UOM_CODE VARCHAR2(3);
   lv_BASIS_TYPE NUMBER;
   lv_RESOURCE_OFFSET_PERCENT NUMBER;
   lv_SCHEDULE_SEQ_NUM NUMBER;
   lv_PRINCIPAL_FLAG NUMBER;
   lv_SCHEDULE_FLAG NUMBER;
   lv_DEPARTMENT_ID    NUMBER;
   lv_ORGANIZATION_ID NUMBER;
   lv_ACTIVITY_GROUP_ID NUMBER;
   lv_GROUP_SEQUENCE_NUMBER 	NUMBER;   	/* ds change change start */
   lv_GROUP_SEQUENCE_ID		NUMBER;
   lv_BATCH_NUMBER		NUMBER;
   lv_FIRM_FLAG		NUMBER;
   lv_SETUP_ID		NUMBER;
   lv_PARENT_SEQ_NUM NUMBER;
   lv_MAXIMUM_ASSIGNED_UNITS	NUMBER;     /* ds change change end */
   total_count NUMBER := 0;

  lv_errbuf			VARCHAR2(240);
  lv_retcode			NUMBER;

BEGIN

IF MSC_CL_COLLECTION.v_exchange_mode=MSC_UTIL.SYS_YES THEN
   lv_tbl:= 'JOB_OP_RESOURCES_'||MSC_CL_COLLECTION.v_instance_code;
   lv_supplies_tbl:= 'SUPPLIES_'||MSC_CL_COLLECTION.v_instance_code;
ELSE
   lv_tbl:= 'MSC_JOB_OP_RESOURCES';
   lv_supplies_tbl:= 'MSC_SUPPLIES';
END IF;

IF MSC_CL_COLLECTION.v_is_incremental_refresh THEN

lv_cursor_stmt:=
'SELECT'
||'    ms.TRANSACTION_ID,'
||'    res.OPERATION_SEQ_NUM,'
||'    res.RESOURCE_SEQ_NUM,'
||'    res.SR_INSTANCE_ID'
||' FROM '||lv_supplies_tbl||' ms,'
||'      MSC_ST_JOB_OP_RESOURCES res'
||' WHERE res.SR_INSTANCE_ID= '||MSC_CL_COLLECTION.v_instance_id
||'  AND ms.PLAN_ID= -1'
||'  AND ms.SR_INSTANCE_ID= res.SR_INSTANCE_ID'
||'  AND ms.DISPOSITION_ID= res.WIP_ENTITY_ID'
||'  AND ms.ORDER_TYPE IN ( 3, 7)'
||'  AND res.DELETED_FLAG= '||MSC_UTIL.SYS_YES;

OPEN cgen FOR lv_cursor_stmt;

IF (cgen%ISOPEN) THEN

LOOP

FETCH cgen INTO
                  lv_TRANSACTION_ID,
                  lv_OPERATION_SEQ_NUM,
                  lv_RESOURCE_SEQ_NUM,
		  lv_SR_INSTANCE_ID;

 EXIT WHEN cgen%NOTFOUND;

 DELETE MSC_JOB_OP_RESOURCES
 WHERE PLAN_ID= -1
   AND TRANSACTION_ID = lv_TRANSACTION_ID
   AND SR_INSTANCE_ID = lv_SR_INSTANCE_ID
   AND OPERATION_SEQ_NUM = nvl(lv_OPERATION_SEQ_NUM,OPERATION_SEQ_NUM)
   AND RESOURCE_SEQ_NUM = nvl(lv_RESOURCE_SEQ_NUM,RESOURCE_SEQ_NUM);


END LOOP;

END IF;

COMMIT;

CLOSE cgen;

END IF;  /*Incremental*/

lv_cursor_stmt:=
'SELECT'
||'   ms.TRANSACTION_ID,'
||'   res.OPERATION_SEQ_NUM ,'
||'   res.SR_INSTANCE_ID,'
||'   res.RESOURCE_SEQ_NUM,'
||'   res.ALTERNATE_NUM,'
||'   res.RECOMMENDED,'
||'   res.RECO_START_DATE,'
||'   res.ORGANIZATION_ID,'
||'   res.RECO_COMPLETION_DATE,'
||'   res.RESOURCE_ID,'
||'   res.ASSIGNED_UNITS,'
||'   res.USAGE_RATE_OR_AMOUNT,'
||'   res.UOM_CODE,'
||'   res.BASIS_TYPE,'
||'   res.RESOURCE_OFFSET_PERCENT,'
||'   res.SCHEDULE_SEQ_NUM,'
||'   res.PRINCIPAL_FLAG,'
||'   res.SCHEDULE_FLAG,'
||'   res.DEPARTMENT_ID,'
||'   res.ACTIVITY_GROUP_ID,'
||'   res.GROUP_SEQUENCE_NUMBER,'   	/* ds change change start */
||'   res.GROUP_SEQUENCE_ID,'
||'   res.BATCH_NUMBER,'
||'   res.FIRM_FLAG,'
||'   res.SETUP_ID,'
||'   res.PARENT_SEQ_NUM,'
||'   res.MAXIMUM_ASSIGNED_UNITS'     /* ds change change end */
||' FROM '||lv_supplies_tbl||' ms,'
||'      MSC_ST_JOB_OP_RESOURCES res'
||' WHERE res.SR_INSTANCE_ID= '||MSC_CL_COLLECTION.v_instance_id
||'  AND ms.PLAN_ID= -1'
||'  AND ms.SR_INSTANCE_ID= res.SR_INSTANCE_ID'
||'  AND ms.DISPOSITION_ID= res.WIP_ENTITY_ID'
||'  AND ms.ORDER_TYPE IN ( 3, 7)'
||'  AND res.DELETED_FLAG= '||MSC_UTIL.SYS_NO;


-- ========= Prepare SQL Statement for INSERT ==========
lv_sql_stmt:=
'insert into '||lv_tbl
||'  ( PLAN_ID,'
||'   TRANSACTION_ID,'
||'   OPERATION_SEQ_NUM,'
||'   RESOURCE_SEQ_NUM,'
||'   ALTERNATE_NUM,'
||'   RECOMMENDED,'
||'   RECO_START_DATE,'
||'   RECO_COMPLETION_DATE,'
||'   ORGANIZATION_ID,'
||'   RESOURCE_ID,'
||'   ASSIGNED_UNITS,'
||'   USAGE_RATE_OR_AMOUNT,'
||'   UOM_CODE,'
||'   BASIS_TYPE,'
||'   RESOURCE_OFFSET_PERCENT,'
||'   SCHEDULE_SEQ_NUM,'
||'   PRINCIPAL_FLAG,'
||'   SCHEDULE_FLAG,'
||'   DEPARTMENT_ID,'
||'   ACTIVITY_GROUP_ID,'
||'   GROUP_SEQUENCE_NUMBER,'   	/* ds change change start */
||'   GROUP_SEQUENCE_ID,'
||'   BATCH_NUMBER,'
||'   FIRM_FLAG,'
||'   SETUP_ID,'
||'   PARENT_SEQ_NUM,'
||'   MAXIMUM_ASSIGNED_UNITS,'     /* ds change change end */
||'    SR_INSTANCE_ID,'
||'    REFRESH_NUMBER,'
||'    LAST_UPDATE_DATE,'
||'    LAST_UPDATED_BY,'
||'    CREATION_DATE,'
||'    CREATED_BY)'
||'VALUES'
||'(   -1,'
||'   :TRANSACTION_ID,'
||'   :OPERATION_SEQ_NUM,'
||'   :RESOURCE_SEQ_NUM,'
||'   :ALTERNATE_NUM,'
||'   :RECOMMENDED,'
||'   :RECO_START_DATE,'
||'   :RECO_COMPLETION_DATE,'
||'   :ORGANIZATION_ID,'
||'   :RESOURCE_ID,'
||'   :ASSIGNED_UNITS,'
||'   :USAGE_RATE_OR_AMOUNT,'
||'   :UOM_CODE,'
||'   :BASIS_TYPE,'
||'   :RESOURCE_OFFSET_PERCENT,'
||'   :SCHEDULE_SEQ_NUM,'
||'   :PRINCIPAL_FLAG,'
||'   :SCHEDULE_FLAG,'
||'   :DEPARTMENT_ID,'
||'   :ACTIVITY_GROUP_ID,'
||'   :GROUP_SEQUENCE_NUMBER,'   	/* ds change change start */
||'   :GROUP_SEQUENCE_ID,'
||'   :BATCH_NUMBER,'
||'   :FIRM_FLAG,'
||'   :SETUP_ID,'
||'   :PARENT_SEQ_NUM,'
||'   :MAXIMUM_ASSIGNED_UNITS,'     /* ds change change end */
||'    :SR_INSTANCE_ID,'
||'    :REFRESH_NUMBER,'
||'    :v_current_date,'
||'    :v_current_user,'
||'    :v_current_date,'
||'    :v_current_user)';

--log_debug(lv_cursor_stmt);
--log_debug(lv_sql_stmt);
OPEN cgen FOR lv_cursor_stmt;

IF (cgen%ISOPEN) THEN

LOOP

FETCH cgen INTO
   lv_TRANSACTION_ID ,
   lv_OPERATION_SEQ_NUM ,
   lv_SR_INSTANCE_ID ,
   lv_RESOURCE_SEQ_NUM ,
   lv_ALTERNATE_NUM ,
   lv_RECOMMENDED   ,
   lv_RECO_START_DATE,
   lv_ORGANIZATION_ID ,
   lv_RECO_COMPLETION_DATE,
   lv_RESOURCE_ID  ,
   lv_ASSIGNED_UNITS ,
   lv_USAGE_RATE_OR_AMOUNT ,
   lv_UOM_CODE,
   lv_BASIS_TYPE ,
   lv_RESOURCE_OFFSET_PERCENT ,
   lv_SCHEDULE_SEQ_NUM ,
   lv_PRINCIPAL_FLAG ,
   lv_SCHEDULE_FLAG ,
   lv_DEPARTMENT_ID    ,
   lv_ACTIVITY_GROUP_ID,
   lv_GROUP_SEQUENCE_NUMBER,   	/* ds change change start */
   lv_GROUP_SEQUENCE_ID,
   lv_BATCH_NUMBER,
   lv_FIRM_FLAG,
   lv_SETUP_ID,
   lv_PARENT_SEQ_NUM,
   lv_MAXIMUM_ASSIGNED_UNITS;     /* ds change change end */

 EXIT WHEN cgen%NOTFOUND;

BEGIN

IF MSC_CL_COLLECTION.v_is_incremental_refresh THEN

UPDATE MSC_JOB_OP_RESOURCES
SET
   RECOMMENDED   =  lv_RECOMMENDED,
   RECO_START_DATE =  lv_RECO_START_DATE,
   RECO_COMPLETION_DATE = lv_RECO_COMPLETION_DATE,
   RESOURCE_ID  = lv_RESOURCE_ID,
   ASSIGNED_UNITS = lv_ASSIGNED_UNITS,
   USAGE_RATE_OR_AMOUNT = lv_USAGE_RATE_OR_AMOUNT,
   UOM_CODE = lv_UOM_CODE,
   BASIS_TYPE = lv_BASIS_TYPE,
   RESOURCE_OFFSET_PERCENT = lv_RESOURCE_OFFSET_PERCENT,
   SCHEDULE_SEQ_NUM = lv_SCHEDULE_SEQ_NUM,
   PRINCIPAL_FLAG = lv_PRINCIPAL_FLAG,
   SCHEDULE_FLAG = lv_SCHEDULE_FLAG,
   DEPARTMENT_ID    = lv_DEPARTMENT_ID,
   ACTIVITY_GROUP_ID = lv_ACTIVITY_GROUP_ID,
   GROUP_SEQUENCE_NUMBER   = lv_GROUP_SEQUENCE_NUMBER,   	/* ds change change start */
   GROUP_SEQUENCE_ID      = lv_GROUP_SEQUENCE_ID,
   BATCH_NUMBER   = lv_BATCH_NUMBER,
   FIRM_FLAG   = lv_FIRM_FLAG,
   SETUP_ID   = lv_SETUP_ID,
   PARENT_SEQ_NUM = lv_PARENT_SEQ_NUM,
   MAXIMUM_ASSIGNED_UNITS  = lv_MAXIMUM_ASSIGNED_UNITS,     /* ds change change end */
   REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
   LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
   LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
WHERE PLAN_ID=   -1
  AND SR_INSTANCE_ID=   lv_SR_INSTANCE_ID
  AND TRANSACTION_ID=   lv_TRANSACTION_ID
  AND ORGANIZATION_ID=   lv_ORGANIZATION_ID
  AND OPERATION_SEQ_NUM =  lv_OPERATION_SEQ_NUM
  AND RESOURCE_SEQ_NUM = lv_RESOURCE_SEQ_NUM
  AND ALTERNATE_NUM = lv_ALTERNATE_NUM;


END IF;

IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) OR SQL%NOTFOUND THEN

EXECUTE IMMEDIATE lv_sql_stmt
USING
   lv_TRANSACTION_ID ,
   lv_OPERATION_SEQ_NUM ,
   lv_RESOURCE_SEQ_NUM ,
   lv_ALTERNATE_NUM ,
   lv_RECOMMENDED   ,
   lv_RECO_START_DATE,
   lv_RECO_COMPLETION_DATE,
   lv_ORGANIZATION_ID ,
   lv_RESOURCE_ID  ,
   lv_ASSIGNED_UNITS ,
   lv_USAGE_RATE_OR_AMOUNT ,
   lv_UOM_CODE,
   lv_BASIS_TYPE ,
   lv_RESOURCE_OFFSET_PERCENT ,
   lv_SCHEDULE_SEQ_NUM ,
   lv_PRINCIPAL_FLAG ,
   lv_SCHEDULE_FLAG ,
   lv_DEPARTMENT_ID    ,
   lv_ACTIVITY_GROUP_ID,
   lv_GROUP_SEQUENCE_NUMBER,   	/* ds change change start */
   lv_GROUP_SEQUENCE_ID,
   lv_BATCH_NUMBER,
   lv_FIRM_FLAG,
   lv_SETUP_ID,
   lv_PARENT_SEQ_NUM,
   lv_MAXIMUM_ASSIGNED_UNITS,     /* ds change change end */
   lv_SR_INSTANCE_ID,
    MSC_CL_COLLECTION.v_last_collection_id,
    MSC_CL_COLLECTION.v_current_date,
    MSC_CL_COLLECTION.v_current_user,
    MSC_CL_COLLECTION.v_current_date,
    MSC_CL_COLLECTION.v_current_user;

 total_count := total_count +1;
END IF;

EXCEPTION
   WHEN OTHERS THEN

    IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_JOB_OP_RES');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_JOB_OP_RESOURCES');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RAISE;

    ELSE

      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_JOB_OP_RES');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_JOB_OP_RESOURCES');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'ORGANIZATION_CODE');
      FND_MESSAGE.SET_TOKEN('VALUE',
                            MSC_GET_NAME.ORG_CODE( lv_ORGANIZATION_ID,
                                                   MSC_CL_COLLECTION.v_instance_id));
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
    END IF;

END;
END LOOP;

   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Total MSC_JOB_OP_RESOURCES = '||  total_count);
END IF;

CLOSE cgen;

COMMIT;

BEGIN

IF ((MSC_CL_COLLECTION.v_coll_prec.org_group_flag <> MSC_UTIL.G_ALL_ORGANIZATIONS ) AND (MSC_CL_COLLECTION.v_exchange_mode=MSC_UTIL.SYS_YES)) THEN

lv_tbl:= 'JOB_OP_RESOURCES_'||MSC_CL_COLLECTION.v_instance_code;

lv_sql_stmt:=
         'INSERT INTO '||lv_tbl
          ||' SELECT * from MSC_JOB_OP_RESOURCES'
          ||' WHERE sr_instance_id = '||MSC_CL_COLLECTION.v_instance_id
          ||' AND plan_id = -1 '
          ||' AND organization_id not '||MSC_UTIL.v_in_org_str;

   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'The sql statement is '||lv_sql_stmt);
   EXECUTE IMMEDIATE lv_sql_stmt;

   COMMIT;

END IF;

EXCEPTION
  WHEN OTHERS THEN

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RAISE;
END;

IF MSC_CL_COLLECTION.v_exchange_mode=MSC_UTIL.SYS_YES THEN
   MSC_CL_COLLECTION.alter_temp_table (lv_errbuf,
   	              lv_retcode,
                      'MSC_JOB_OP_RESOURCES',
                      MSC_CL_COLLECTION.v_instance_code,
                      MSC_UTIL.G_WARNING
                     );

   IF lv_retcode = MSC_UTIL.G_ERROR THEN
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, lv_errbuf);
      RAISE MSC_CL_COLLECTION.ALTER_TEMP_TABLE_ERROR;
   ELSIF lv_retcode = MSC_UTIL.G_WARNING THEN
      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;
   END IF;

END IF;

EXCEPTION
   WHEN OTHERS THEN
      IF cgen%ISOPEN THEN CLOSE cgen; END IF;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '<<LOAD_JOB_OP_RES>>');
      IF lv_cursor_stmt IS NOT NULL THEN
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '<<CURSOR>>'||lv_cursor_stmt);
      END IF;
      IF lv_sql_stmt IS NOT NULL THEN
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '<<SQL>>'||lv_sql_stmt);
      END IF;
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  SQLERRM);
      RAISE;
END LOAD_JOB_OP_RES;

--=========================================================================
PROCEDURE LOAD_JOB_REQ_OP IS

   TYPE CurTyp IS REF CURSOR; -- define weak REF CURSOR type

   cgen              CurTyp;

   lv_tbl          VARCHAR2(30);
   lv_supplies_tbl VARCHAR2(30);

   lv_cursor_stmt VARCHAR2(5000);
   lv_sql_stmt    VARCHAR2(32767);


   lv_TRANSACTION_ID NUMBER;
   lv_OPERATION_SEQ_NUM NUMBER;
   lv_SR_INSTANCE_ID NUMBER;
   lv_COMPONENT_ITEM_ID NUMBER;
   lv_PRIMARY_COMPONENT_ID NUMBER;
   lv_SOURCE_PHANTOM_ID NUMBER;
   lv_COMPONENT_SEQUENCE_ID NUMBER;
   lv_RECOMMENDED   VARCHAR2(1);
   lv_RECO_DATE_REQUIRED  DATE;
   lv_ORGANIZATION_ID   NUMBER;
   lv_COMPONENT_PRIORITY  NUMBER;
   lv_DEPARTMENT_ID    NUMBER;
   lv_QUANTITY_PER_ASSEMBLY NUMBER;
   lv_COMPONENT_YIELD_FACTOR  NUMBER;
   lv_EFFECTIVITY_DATE  DATE;
   lv_DISABLE_DATE   DATE;
   lv_PLANNING_FACTOR NUMBER;
   lv_LOW_QUANTITY  NUMBER;
   lv_HIGH_QUANTITY NUMBER;
   lv_OP_LT_PERCENT NUMBER;
   lv_WIP_SUPPLY_TYPE   NUMBER;
   lv_FROM_END_ITEM_UNIT_NUMBER  VARCHAR2(30);
   lv_TO_END_ITEM_UNIT_NUMBER VARCHAR2(30);
   lv_COMPONENT_SCALING_TYPE NUMBER;  /* Discrete Mfg Enahancements Bug 4492736 */

   lv_count NUMBER;
   c_count NUMBER;
   total_count NUMBER := 0;

  lv_errbuf			VARCHAR2(240);
  lv_retcode			NUMBER;

BEGIN

IF MSC_CL_COLLECTION.v_exchange_mode=MSC_UTIL.SYS_YES THEN
   lv_tbl:= 'JOB_REQUIREMENT_OPS_'||MSC_CL_COLLECTION.v_instance_code;
   lv_supplies_tbl:= 'SUPPLIES_'||MSC_CL_COLLECTION.v_instance_code;
ELSE
   lv_tbl:= 'MSC_JOB_REQUIREMENT_OPS';
   lv_supplies_tbl:= 'MSC_SUPPLIES';
END IF;

IF MSC_CL_COLLECTION.v_is_incremental_refresh THEN

lv_cursor_stmt:=
'SELECT'
||'    ms.TRANSACTION_ID,'
||'    req.OPERATION_SEQ_NUM,'
||'    cmp_itm.INVENTORY_ITEM_ID  ,'
||'    pri_cmp.INVENTORY_ITEM_ID ,'
||'    src_ptm.INVENTORY_ITEM_ID ,'
||'    req.COMPONENT_SEQUENCE_ID,'
||'    req.SR_INSTANCE_ID'
||' FROM '||lv_supplies_tbl||' ms,'
||'      MSC_ST_JOB_REQUIREMENT_OPS req,'
||'      MSC_ITEM_ID_LID cmp_itm, '
||'      MSC_ITEM_ID_LID pri_cmp, '
||'      MSC_ITEM_ID_LID src_ptm '
||' WHERE req.SR_INSTANCE_ID= '||MSC_CL_COLLECTION.v_instance_id
||'  AND ms.PLAN_ID= -1'
||'  AND ms.SR_INSTANCE_ID= req.SR_INSTANCE_ID'
||'  AND ms.DISPOSITION_ID= req.WIP_ENTITY_ID'
||'  AND ms.ORDER_TYPE IN ( 3, 7)'
||'  AND req.DELETED_FLAG= '||MSC_UTIL.SYS_YES
||'  AND cmp_itm.SR_INVENTORY_ITEM_ID = req.COMPONENT_ITEM_ID'
||'  AND pri_cmp.SR_INVENTORY_ITEM_ID = req.PRIMARY_COMPONENT_ID'
||'  AND src_ptm.SR_INVENTORY_ITEM_ID(+) = req.SOURCE_PHANTOM_ID'
||'  AND cmp_itm.SR_INSTANCE_ID = req.SR_INSTANCE_ID'
||'  AND pri_cmp.SR_INSTANCE_ID = req.SR_INSTANCE_ID'
||'  AND src_ptm.SR_INSTANCE_ID(+) = req.SR_INSTANCE_ID';

OPEN cgen FOR lv_cursor_stmt;

IF (cgen%ISOPEN) THEN

LOOP

FETCH cgen INTO
                  lv_TRANSACTION_ID,
                  lv_OPERATION_SEQ_NUM,
                  lv_COMPONENT_ITEM_ID,
		  lv_PRIMARY_COMPONENT_ID,
		  lv_SOURCE_PHANTOM_ID,
		  lv_COMPONENT_SEQUENCE_ID,
                  lv_SR_INSTANCE_ID;

 EXIT WHEN cgen%NOTFOUND;

 DELETE MSC_JOB_REQUIREMENT_OPS
 WHERE PLAN_ID= -1
   AND TRANSACTION_ID = lv_TRANSACTION_ID
   AND SR_INSTANCE_ID = lv_SR_INSTANCE_ID
   AND OPERATION_SEQ_NUM = nvl(lv_OPERATION_SEQ_NUM,OPERATION_SEQ_NUM)
   AND COMPONENT_ITEM_ID = nvl(lv_COMPONENT_ITEM_ID,COMPONENT_ITEM_ID)
   AND PRIMARY_COMPONENT_ID = nvl(lv_PRIMARY_COMPONENT_ID,PRIMARY_COMPONENT_ID)
   AND ((SOURCE_PHANTOM_ID is NULL AND lv_SOURCE_PHANTOM_ID is NULL)OR (SOURCE_PHANTOM_ID = nvl(lv_SOURCE_PHANTOM_ID,SOURCE_PHANTOM_ID)))
   AND COMPONENT_SEQUENCE_ID = nvl(lv_COMPONENT_SEQUENCE_ID,COMPONENT_SEQUENCE_ID);


END LOOP;

END IF;

COMMIT;

CLOSE cgen;

END IF;  /*Incremental*/


lv_cursor_stmt:=
'SELECT'
||'   ms.TRANSACTION_ID,'
||'   req.OPERATION_SEQ_NUM ,'
||'   req.SR_INSTANCE_ID,'
||'   cmp_itm.INVENTORY_ITEM_ID  ,'
||'   pri_cmp.INVENTORY_ITEM_ID ,'
||'   src_ptm.INVENTORY_ITEM_ID ,'
||'   req.COMPONENT_SEQUENCE_ID,'
||'   req.RECOMMENDED,'
||'   req.RECO_DATE_REQUIRED,'
||'   req.ORGANIZATION_ID,'
||'   req.COMPONENT_PRIORITY,'
||'   req.DEPARTMENT_ID,'
||'   req.QUANTITY_PER_ASSEMBLY,'
||'   req.COMPONENT_YIELD_FACTOR,'
||'   req.EFFECTIVITY_DATE,'
||'   req.DISABLE_DATE,'
||'   req.PLANNING_FACTOR,'
||'   req.LOW_QUANTITY,'
||'   req.HIGH_QUANTITY,'
||'   req.OPERATION_LEAD_TIME_PERCENT,'
||'   req.WIP_SUPPLY_TYPE,'
||'   req.FROM_END_ITEM_UNIT_NUMBER,'
||'   req.TO_END_ITEM_UNIT_NUMBER,'
||'   req.COMPONENT_SCALING_TYPE'   /* Discrete Mfg Enahancements Bug 4492736 */
||' FROM '||lv_supplies_tbl||' ms,'
||'      MSC_ST_JOB_REQUIREMENT_OPS req,'
||'      MSC_ITEM_ID_LID cmp_itm, '
||'      MSC_ITEM_ID_LID pri_cmp, '
||'      MSC_ITEM_ID_LID src_ptm '
||' WHERE req.SR_INSTANCE_ID= '||MSC_CL_COLLECTION.v_instance_id
||'  AND ms.PLAN_ID= -1'
||'  AND ms.SR_INSTANCE_ID= req.SR_INSTANCE_ID'
||'  AND ms.DISPOSITION_ID= req.WIP_ENTITY_ID'
||'  AND ms.ORDER_TYPE IN ( 3, 7)'
||'  AND req.DELETED_FLAG= '||MSC_UTIL.SYS_NO
||'  AND cmp_itm.SR_INVENTORY_ITEM_ID = req.COMPONENT_ITEM_ID'
||'  AND pri_cmp.SR_INVENTORY_ITEM_ID = req.PRIMARY_COMPONENT_ID'
||'  AND src_ptm.SR_INVENTORY_ITEM_ID(+) = req.SOURCE_PHANTOM_ID'
||'  AND cmp_itm.SR_INSTANCE_ID = req.SR_INSTANCE_ID'
||'  AND pri_cmp.SR_INSTANCE_ID = req.SR_INSTANCE_ID'
||'  AND src_ptm.SR_INSTANCE_ID(+) = req.SR_INSTANCE_ID';


-- ========= Prepare SQL Statement for INSERT ==========
lv_sql_stmt:=
'insert into '||lv_tbl
||'  ( PLAN_ID,'
||'   TRANSACTION_ID,'
||'   OPERATION_SEQ_NUM,'
||'   COMPONENT_ITEM_ID,'
||'   PRIMARY_COMPONENT_ID,'
||'   SOURCE_PHANTOM_ID,'
||'   COMPONENT_SEQUENCE_ID,'
||'   RECOMMENDED,'
||'   RECO_DATE_REQUIRED,'
||'   ORGANIZATION_ID,'
||'   COMPONENT_PRIORITY,'
||'   DEPARTMENT_ID,'
||'   QUANTITY_PER_ASSEMBLY,'
||'   COMPONENT_YIELD_FACTOR,'
||'   EFFECTIVITY_DATE,'
||'   DISABLE_DATE,'
||'   PLANNING_FACTOR,'
||'   LOW_QUANTITY,'
||'   HIGH_QUANTITY,'
||'   OPERATION_LEAD_TIME_PERCENT,'
||'   WIP_SUPPLY_TYPE,'
||'   FROM_END_ITEM_UNIT_NUMBER,'
||'   TO_END_ITEM_UNIT_NUMBER,'
||'   COMPONENT_SCALING_TYPE,'
||'    SR_INSTANCE_ID,'
||'    REFRESH_NUMBER,'
||'    LAST_UPDATE_DATE,'
||'    LAST_UPDATED_BY,'
||'    CREATION_DATE,'
||'    CREATED_BY)'
||'VALUES'
||'(   -1,'
||'   :TRANSACTION_ID,'
||'   :OPERATION_SEQ_NUM,'
||'   :COMPONENT_ITEM_ID,'
||'   :PRIMARY_COMPONENT_ID,'
||'   :SOURCE_PHANTOM_ID,'
||'   :COMPONENT_SEQUENCE_ID,'
||'   :RECOMMENDED,'
||'   :RECO_DATE_REQUIRED,'
||'   :ORGANIZATION_ID,'
||'   :COMPONENT_PRIORITY,'
||'   :DEPARTMENT_ID,'
||'   :QUANTITY_PER_ASSEMBLY,'
||'   :COMPONENT_YIELD_FACTOR,'
||'   :EFFECTIVITY_DATE,'
||'   :DISABLE_DATE,'
||'   :PLANNING_FACTOR,'
||'   :LOW_QUANTITY,'
||'   :HIGH_QUANTITY,'
||'   :OPERATION_LEAD_TIME_PERCENT,'
||'   :WIP_SUPPLY_TYPE,'
||'   :FROM_END_ITEM_UNIT_NUMBER,'
||'   :TO_END_ITEM_UNIT_NUMBER,'
||'   :COMPONENT_SCALING_TYPE,'
||'    :SR_INSTANCE_ID,'
||'    :REFRESH_NUMBER,'
||'    :v_current_date,'
||'    :v_current_user,'
||'    :v_current_date,'
||'    :v_current_user)';


OPEN cgen FOR lv_cursor_stmt;

c_count := 0;

IF (cgen%ISOPEN) THEN

LOOP

FETCH cgen INTO
   lv_TRANSACTION_ID,
   lv_OPERATION_SEQ_NUM ,
   lv_SR_INSTANCE_ID,
   lv_COMPONENT_ITEM_ID,
   lv_PRIMARY_COMPONENT_ID,
   lv_SOURCE_PHANTOM_ID,
   lv_COMPONENT_SEQUENCE_ID,
   lv_RECOMMENDED,
   lv_RECO_DATE_REQUIRED,
   lv_ORGANIZATION_ID,
   lv_COMPONENT_PRIORITY,
   lv_DEPARTMENT_ID,
   lv_QUANTITY_PER_ASSEMBLY,
   lv_COMPONENT_YIELD_FACTOR,
   lv_EFFECTIVITY_DATE,
   lv_DISABLE_DATE,
   lv_PLANNING_FACTOR,
   lv_LOW_QUANTITY,
   lv_HIGH_QUANTITY,
   lv_OP_LT_PERCENT,
   lv_WIP_SUPPLY_TYPE,
   lv_FROM_END_ITEM_UNIT_NUMBER,
   lv_TO_END_ITEM_UNIT_NUMBER,
   lv_COMPONENT_SCALING_TYPE;

EXIT WHEN cgen%NOTFOUND;

BEGIN

IF MSC_CL_COLLECTION.v_is_incremental_refresh THEN

UPDATE MSC_JOB_REQUIREMENT_OPS
SET
   RECOMMENDED =  lv_RECOMMENDED,
   RECO_DATE_REQUIRED =   lv_RECO_DATE_REQUIRED,
   COMPONENT_PRIORITY =  lv_COMPONENT_PRIORITY,
   DEPARTMENT_ID = lv_DEPARTMENT_ID,
   QUANTITY_PER_ASSEMBLY =  lv_QUANTITY_PER_ASSEMBLY,
   COMPONENT_YIELD_FACTOR =   lv_COMPONENT_YIELD_FACTOR,
   EFFECTIVITY_DATE =   lv_EFFECTIVITY_DATE,
   DISABLE_DATE =  lv_DISABLE_DATE,
   PLANNING_FACTOR =  lv_PLANNING_FACTOR,
   LOW_QUANTITY =  lv_LOW_QUANTITY,
   HIGH_QUANTITY = lv_HIGH_QUANTITY,
   OPERATION_LEAD_TIME_PERCENT =  lv_OP_LT_PERCENT,
   WIP_SUPPLY_TYPE =  lv_WIP_SUPPLY_TYPE,
   FROM_END_ITEM_UNIT_NUMBER =  lv_FROM_END_ITEM_UNIT_NUMBER,
   TO_END_ITEM_UNIT_NUMBER = lv_TO_END_ITEM_UNIT_NUMBER,
   COMPONENT_SCALING_TYPE = lv_COMPONENT_SCALING_TYPE,
   REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
   LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
   LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
WHERE PLAN_ID=   -1
  AND SR_INSTANCE_ID=   lv_SR_INSTANCE_ID
  AND TRANSACTION_ID=   lv_TRANSACTION_ID
  AND ORGANIZATION_ID=   lv_ORGANIZATION_ID
  AND OPERATION_SEQ_NUM =  lv_OPERATION_SEQ_NUM
  AND COMPONENT_ITEM_ID = lv_COMPONENT_ITEM_ID
  AND PRIMARY_COMPONENT_ID = lv_PRIMARY_COMPONENT_ID
  AND ((SOURCE_PHANTOM_ID is null AND lv_SOURCE_PHANTOM_ID is null) OR (SOURCE_PHANTOM_ID = lv_SOURCE_PHANTOM_ID))
  AND COMPONENT_SEQUENCE_ID = lv_COMPONENT_SEQUENCE_ID;


END IF;

IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) OR SQL%NOTFOUND THEN

EXECUTE IMMEDIATE lv_sql_stmt
USING
   lv_TRANSACTION_ID,
   lv_OPERATION_SEQ_NUM ,
   lv_COMPONENT_ITEM_ID,
   lv_PRIMARY_COMPONENT_ID,
   lv_SOURCE_PHANTOM_ID,
   lv_COMPONENT_SEQUENCE_ID,
   lv_RECOMMENDED,
   lv_RECO_DATE_REQUIRED,
   lv_ORGANIZATION_ID,
   lv_COMPONENT_PRIORITY,
   lv_DEPARTMENT_ID,
   lv_QUANTITY_PER_ASSEMBLY,
   lv_COMPONENT_YIELD_FACTOR,
   lv_EFFECTIVITY_DATE,
   lv_DISABLE_DATE,
   lv_PLANNING_FACTOR,
   lv_LOW_QUANTITY,
   lv_HIGH_QUANTITY,
   lv_OP_LT_PERCENT,
   lv_WIP_SUPPLY_TYPE,
   lv_FROM_END_ITEM_UNIT_NUMBER,
   lv_TO_END_ITEM_UNIT_NUMBER,
   lv_COMPONENT_SCALING_TYPE,
   lv_SR_INSTANCE_ID,
    MSC_CL_COLLECTION.v_last_collection_id,
    MSC_CL_COLLECTION.v_current_date,
    MSC_CL_COLLECTION.v_current_user,
    MSC_CL_COLLECTION.v_current_date,
    MSC_CL_COLLECTION.v_current_user;
 total_count := total_count +1;
END IF;

EXCEPTION
   WHEN OTHERS THEN

    IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_JOB_REQ_OP');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_JOB_REQUIREMENT_OPS');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RAISE;

    ELSE

      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_JOB_REQ_OP');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_JOB_REQUIREMENT_OPS');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'ORGANIZATION_CODE');
      FND_MESSAGE.SET_TOKEN('VALUE',
                            MSC_GET_NAME.ORG_CODE( lv_ORGANIZATION_ID,
                                                   MSC_CL_COLLECTION.v_instance_id));
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
    END IF;

END;

END LOOP;

--   log_debug('Total MSC_JOB_REQUIREMENT_OPS = '||  total_count);
END IF;

CLOSE cgen;

COMMIT;

BEGIN

IF ((MSC_CL_COLLECTION.v_coll_prec.org_group_flag <> MSC_UTIL.G_ALL_ORGANIZATIONS ) AND (MSC_CL_COLLECTION.v_exchange_mode=MSC_UTIL.SYS_YES)) THEN

lv_tbl:= 'JOB_REQUIREMENT_OPS_'||MSC_CL_COLLECTION.v_instance_code;

lv_sql_stmt:=
         'INSERT INTO '||lv_tbl
          ||' SELECT * from MSC_JOB_REQUIREMENT_OPS'
          ||' WHERE sr_instance_id = '||MSC_CL_COLLECTION.v_instance_id
          ||' AND plan_id = -1 '
          ||' AND organization_id not '||MSC_UTIL.v_in_org_str;

   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'The sql statement is '||lv_sql_stmt);
   EXECUTE IMMEDIATE lv_sql_stmt;

   COMMIT;

END IF;

EXCEPTION
  WHEN OTHERS THEN

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RAISE;
END;

IF MSC_CL_COLLECTION.v_exchange_mode=MSC_UTIL.SYS_YES THEN
   MSC_CL_COLLECTION.alter_temp_table (lv_errbuf,
   	              lv_retcode,
                      'MSC_JOB_REQUIREMENT_OPS',
                      MSC_CL_COLLECTION.v_instance_code,
                      MSC_UTIL.G_WARNING
                     );

   IF lv_retcode = MSC_UTIL.G_ERROR THEN
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, lv_errbuf);
      RAISE MSC_CL_COLLECTION.ALTER_TEMP_TABLE_ERROR;
   ELSIF lv_retcode = MSC_UTIL.G_WARNING THEN
      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;
   END IF;

END IF;

EXCEPTION
   WHEN OTHERS THEN
      IF cgen%ISOPEN THEN CLOSE cgen; END IF;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '<<LOAD_JOB_REQ_OP>>');
      IF lv_cursor_stmt IS NOT NULL THEN
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '<<CURSOR>>'||lv_cursor_stmt);
      END IF;
      IF lv_sql_stmt IS NOT NULL THEN
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '<<SQL>>'||lv_sql_stmt);
      END IF;
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  SQLERRM);
      RAISE;
END LOAD_JOB_REQ_OP;
--=================================================================

PROCEDURE LOAD_JOB_OP_NWK IS

   TYPE CurTyp IS REF CURSOR; -- define weak REF CURSOR type

   cgen              CurTyp;

   lv_tbl          VARCHAR2(30);
   lv_supplies_tbl VARCHAR2(30);

   lv_cursor_stmt VARCHAR2(5000);
   lv_eam_pc_stmt VARCHAR2(5000);
   lv_sql_stmt    VARCHAR2(32767);

   lv_TRANSACTION_ID    NUMBER;
   lv_SR_INSTANCE_ID    NUMBER;
   lv_FROM_OP_SEQ_NUM   NUMBER;
   lv_TO_OP_SEQ_NUM     NUMBER;
   lv_FROM_OP_SEQ_ID    NUMBER;
   lv_TO_OP_SEQ_ID      NUMBER;
   lv_RECOMMENDED       VARCHAR2(1);
   lv_TRANSITION_TYPE   NUMBER;
   lv_PLANNING_PCT      NUMBER;
   lv_ORGANIZATION_ID   NUMBER;
   lv_TO_TRANSACTION_ID   	NUMBER;  /* ds change change start */
   lv_TOP_TRANSACTION_ID	NUMBER;
   lv_TRANSFER_QTY		NUMBER;
   lv_TRANSFER_PCT		NUMBER;
   lv_FROM_ITEM_ID		NUMBER;
   lv_APPLY_TO_CHARGES		NUMBER;
   lv_MINIMUM_TRANSFER_QTY	NUMBER;
   lv_MINIMUM_TIME_OFFSET	NUMBER;
   lv_MAXIMUM_TIME_OFFSET	NUMBER;
   lv_DEPENDENCY_TYPE		NUMBER;
   lv_TRANSFER_UOM		VARCHAR2(4);  /* ds change change start */
   total_count			NUMBER := 0;

  lv_errbuf			VARCHAR2(240);
  lv_retcode			NUMBER;

BEGIN

IF MSC_CL_COLLECTION.v_exchange_mode=MSC_UTIL.SYS_YES THEN
   lv_tbl:= 'JOB_OPERATION_NETWORKS_'||MSC_CL_COLLECTION.v_instance_code;
   lv_supplies_tbl:= 'SUPPLIES_'||MSC_CL_COLLECTION.v_instance_code;
ELSE
   lv_tbl:= 'MSC_JOB_OPERATION_NETWORKS';
   lv_supplies_tbl:= 'MSC_SUPPLIES';
END IF;

IF MSC_CL_COLLECTION.v_is_incremental_refresh THEN

     /* for eam work dependency  */
     lv_cursor_stmt:=
     'SELECT'
     ||'    ms.TRANSACTION_ID,'
     ||'    nwk.FROM_OP_SEQ_NUM,'
     ||'    nwk.TO_OP_SEQ_NUM,'
     ||'    nwk.SR_INSTANCE_ID'
     ||' FROM '||lv_supplies_tbl||' ms,'
     ||'      MSC_ST_JOB_OPERATION_NETWORKS nwk'
     ||' WHERE nwk.SR_INSTANCE_ID= '||MSC_CL_COLLECTION.v_instance_id
     ||'  AND ms.PLAN_ID= -1'
     ||'  AND ms.SR_INSTANCE_ID= nwk.SR_INSTANCE_ID'
     ||'  AND ms.DISPOSITION_ID= nwk.WIP_ENTITY_ID'
     ||'  AND ms.ORDER_TYPE IN ( 3, 7, 70)'		  /* ds change change: 70 eam supply */
     ||'  AND nwk.DELETED_FLAG= '||MSC_UTIL.SYS_YES
     ||'  AND nvl(nwk.DEPENDENCY_TYPE,4) <>  3 ';	 /* ds change change */

     /* for eam parent child dependencies */
     lv_eam_pc_stmt:=
     'SELECT'
     ||'    ms_from.TRANSACTION_ID,'
     ||'    ms_to.TRANSACTION_ID,'
     ||'    nwk.SR_INSTANCE_ID'
     ||' FROM '||lv_supplies_tbl||' ms_from,'
     ||        lv_supplies_tbl||' ms_to,'
     ||'      MSC_ST_JOB_OPERATION_NETWORKS nwk'
     ||' WHERE nwk.SR_INSTANCE_ID= '||MSC_CL_COLLECTION.v_instance_id
     ||'  AND ms_from.PLAN_ID= -1'
     ||'  AND ms_from.SR_INSTANCE_ID= nwk.SR_INSTANCE_ID'
     ||'  AND ms_from.DISPOSITION_ID= nwk.WIP_ENTITY_ID'
     ||'  AND ms_from.ORDER_TYPE  = 70 '
     ||'  AND ms_to.PLAN_ID= -1'
     ||'  AND ms_to.SR_INSTANCE_ID= nwk.SR_INSTANCE_ID'
     ||'  AND ms_to.DISPOSITION_ID= nwk.TO_WIP_ENTITY_ID'
     ||'  AND ms_to.ORDER_TYPE  = 70 '
     ||'  AND nwk.DELETED_FLAG= '||MSC_UTIL.SYS_YES;
     --||'  AND nwk.DEPENDENCY_TYPE = 3 ;

     OPEN cgen FOR lv_cursor_stmt;

     IF (cgen%ISOPEN) THEN

       LOOP

           FETCH cgen INTO
                       lv_TRANSACTION_ID,
                       lv_FROM_OP_SEQ_NUM,
                       lv_TO_OP_SEQ_NUM,
                       lv_SR_INSTANCE_ID;


           EXIT WHEN cgen%NOTFOUND;

           DELETE MSC_JOB_OPERATION_NETWORKS
           WHERE PLAN_ID= -1
           AND TRANSACTION_ID = lv_TRANSACTION_ID
           AND SR_INSTANCE_ID = lv_SR_INSTANCE_ID
           AND FROM_OP_SEQ_NUM = nvl(lv_FROM_OP_SEQ_NUM,FROM_OP_SEQ_NUM)
           AND TO_OP_SEQ_NUM = nvl(lv_TO_OP_SEQ_NUM,TO_OP_SEQ_NUM);

        END LOOP;

    END IF; /* cgen%ISOPEN) */

    COMMIT;

    CLOSE cgen;

     /* ds change change start */
    OPEN cgen FOR  lv_eam_pc_stmt;
    IF (cgen%ISOPEN) THEN
       LOOP
           FETCH cgen INTO
                       lv_TRANSACTION_ID,
                       lv_TO_TRANSACTION_ID,
                       lv_SR_INSTANCE_ID;


           EXIT WHEN cgen%NOTFOUND;

           DELETE MSC_JOB_OPERATION_NETWORKS
           WHERE PLAN_ID= -1
           AND TRANSACTION_ID = lv_TRANSACTION_ID
           AND SR_INSTANCE_ID = lv_SR_INSTANCE_ID
           AND TO_TRANSACTION_ID = lv_TO_TRANSACTION_ID ;
	   --AND DEPENDENCY_TYPE = 3;

        END LOOP;

    END IF; /* cgen%ISOPEN) */

    COMMIT;

    CLOSE cgen;
     /* ds change change end */


END IF;  /*Incremental*/

  lv_cursor_stmt:=
     'SELECT'
     ||'    ms.TRANSACTION_ID,'
     ||'    nwk.FROM_OP_SEQ_NUM,'
     ||'    nwk.TO_OP_SEQ_NUM,'
     ||'    nwk.SR_INSTANCE_ID,'
     ||'    nwk.ORGANIZATION_ID,'
     ||'    nwk.FROM_OP_SEQ_ID,'
     ||'    nwk.TO_OP_SEQ_ID,'
     ||'    nwk.RECOMMENDED,'
     ||'    nwk.TRANSITION_TYPE,'
     ||'    nwk.PLANNING_PCT,'
     ||'    ms1.TRANSACTION_ID,'      /* ds change change start */
     ||'    ms2.TRANSACTION_ID,'
     ||'    nwk.TRANSFER_QTY,'
     ||'    nwk.TRANSFER_UOM,'
     ||'    nwk.TRANSFER_PCT,'
     ||'    t1.INVENTORY_ITEM_ID,'        /*FROM_ITEM_ID,*/
     ||'    nwk.APPLY_TO_CHARGES,'
     ||'    nwk.MINIMUM_TRANSFER_QTY,'
     ||'    nwk.MINIMUM_TIME_OFFSET,'
     ||'    nwk.MAXIMUM_TIME_OFFSET,'
     ||'    nwk.DEPENDENCY_TYPE'	/* ds change change end */
     ||' FROM '||lv_supplies_tbl||' ms,'
     ||'  '||lv_supplies_tbl||' ms1,'
     ||'  '||lv_supplies_tbl||' ms2,'
     ||'      MSC_ST_JOB_OPERATION_NETWORKS nwk,'
     ||'      MSC_ITEM_ID_LID t1'
     ||' WHERE nwk.SR_INSTANCE_ID= '||MSC_CL_COLLECTION.v_instance_id
     ||'  AND ms.PLAN_ID= -1'
     ||'  AND ms.SR_INSTANCE_ID= nwk.SR_INSTANCE_ID'
     ||'  AND ms.DISPOSITION_ID= nwk.WIP_ENTITY_ID'
     ||'  AND ms1.PLAN_ID (+) = -1'				/*  ds change change */
     ||'  AND ms1.SR_INSTANCE_ID (+)= nwk.SR_INSTANCE_ID'
     ||'  AND ms1.DISPOSITION_ID(+)= nwk.TO_WIP_ENTITY_ID'
     ||'  AND ms.ORDER_TYPE IN ( 3, 7, 70)'
     ||'  AND ms1.ORDER_TYPE(+) = 70 '
     ||'  AND ms2.PLAN_ID (+) = -1'				/*  ds change change */
     ||'  AND ms2.SR_INSTANCE_ID (+)= nwk.SR_INSTANCE_ID'
     ||'  AND ms2.DISPOSITION_ID(+)= nwk.TOP_WIP_ENTITY_ID'
     ||'  AND ms2.ORDER_TYPE(+) = 70'
     ||'  AND nwk.DELETED_FLAG= '||MSC_UTIL.SYS_NO
     ||'  AND nwk.FROM_ITEM_ID =  t1.SR_INVENTORY_ITEM_ID(+)'	/* ds change change */
     ||'  AND nwk.sr_instance_id =  t1.sr_instance_id(+) ';	/* ds change change */


    -- ========= Prepare SQL Statement for INSERT ==========
    lv_sql_stmt:=
    'insert into '||lv_tbl
    ||'  ( PLAN_ID,'
    ||'    TRANSACTION_ID,'
    ||'    FROM_OP_SEQ_NUM,'
    ||'    TO_OP_SEQ_NUM,'
    ||'    ORGANIZATION_ID,'
    ||'    FROM_OP_SEQ_ID,'
    ||'    TO_OP_SEQ_ID,'
    ||'    RECOMMENDED,'
    ||'    TRANSITION_TYPE,'
    ||'    PLANNING_PCT,'
    ||'    TO_TRANSACTION_ID,'      /* ds change change start */
    ||'    TOP_TRANSACTION_ID,'
    ||'    TRANSFER_QTY,'
    ||'    TRANSFER_UOM,'
    ||'    TRANSFER_PCT,'
    ||'    FROM_ITEM_ID,'
    ||'    APPLY_TO_CHARGES,'
    ||'    MINIMUM_TRANSFER_QTY,'
    ||'    MINIMUM_TIME_OFFSET,'
    ||'    MAXIMUM_TIME_OFFSET,'
    ||'    DEPENDENCY_TYPE,'	/* ds change change end */
    ||'    SR_INSTANCE_ID,'
    ||'    REFRESH_NUMBER,'
    ||'    LAST_UPDATE_DATE,'
    ||'    LAST_UPDATED_BY,'
    ||'    CREATION_DATE,'
    ||'    CREATED_BY)'
    ||'VALUES'
    ||'(   -1,'
    ||'    :TRANSACTION_ID,'
    ||'    :FROM_OP_SEQ_NUM,'
    ||'    :TO_OP_SEQ_NUM,'
    ||'    :ORGANIZATION_ID,'
    ||'    :FROM_OP_SEQ_ID,'
    ||'    :TO_OP_SEQ_ID,'
    ||'    :RECOMMENDED,'
    ||'    :TRANSITION_TYPE,'
    ||'    :PLANNING_PCT,'
    ||'    :TO_TRANSACTION_ID,'      /* ds change change start */
    ||'    :TOP_TRANSACTION_ID,'
    ||'    :TRANSFER_QTY,'
    ||'    :TRANSFER_UOM,'
    ||'    :TRANSFER_PCT,'
    ||'    :FROM_ITEM_ID,'
    ||'    :APPLY_TO_CHARGES,'
    ||'    :MINIMUM_TRANSFER_QTY,'
    ||'    :MINIMUM_TIME_OFFSET,'
    ||'    :MAXIMUM_TIME_OFFSET,'
    ||'    :DEPENDENCY_TYPE,'	/* ds change change end */
    ||'    :SR_INSTANCE_ID,'
    ||'    :REFRESH_NUMBER,'
    ||'    :v_current_date,'
    ||'    :v_current_user,'
    ||'    :v_current_date,'
    ||'    :v_current_user)';


         --log_debug(lv_sql_stmt);
OPEN cgen FOR lv_cursor_stmt;

IF (cgen%ISOPEN) THEN
	total_count := 0;
    LOOP

       FETCH cgen INTO
           lv_TRANSACTION_ID,
           lv_FROM_OP_SEQ_NUM,
           lv_TO_OP_SEQ_NUM,
           lv_SR_INSTANCE_ID,
           lv_ORGANIZATION_ID,
           lv_FROM_OP_SEQ_ID,
           lv_TO_OP_SEQ_ID,
           lv_RECOMMENDED,
           lv_TRANSITION_TYPE,
           lv_PLANNING_PCT,
	   lv_TO_TRANSACTION_ID,	  /* ds change change start */
	   lv_TOP_TRANSACTION_ID,
	   lv_TRANSFER_QTY,
	   lv_TRANSFER_UOM,
	   lv_TRANSFER_PCT,
	   lv_FROM_ITEM_ID,
	   lv_APPLY_TO_CHARGES,
	   lv_MINIMUM_TRANSFER_QTY,
	   lv_MINIMUM_TIME_OFFSET,
	   lv_MAXIMUM_TIME_OFFSET,
	   lv_DEPENDENCY_TYPE;		/* ds change change end */

       if lv_TO_TRANSACTION_ID is not null then
          link_top_transaction_id_req := TRUE;
       end if;

       EXIT WHEN cgen%NOTFOUND;

      BEGIN

      IF MSC_CL_COLLECTION.v_is_incremental_refresh THEN
       /* opm is full collection. eam when there is change in
	 relationship, it is deleter then insert */

             UPDATE MSC_JOB_OPERATION_NETWORKS
             SET
   	   	FROM_OP_SEQ_ID=   lv_FROM_OP_SEQ_ID,
   	   	TO_OP_SEQ_ID=   lv_TO_OP_SEQ_ID,
   	   	RECOMMENDED=   lv_RECOMMENDED,
   	   	TRANSITION_TYPE=   lv_TRANSITION_TYPE,
   	   	PLANNING_PCT=   lv_PLANNING_PCT,
   	   	REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
   	   	LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
   	   	LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
	      WHERE PLAN_ID=   -1
  	 	AND SR_INSTANCE_ID=   lv_SR_INSTANCE_ID
  	 	AND TRANSACTION_ID=   lv_TRANSACTION_ID
  	 	AND ORGANIZATION_ID=  lv_ORGANIZATION_ID
  	 	AND FROM_OP_SEQ_NUM  = lv_FROM_OP_SEQ_NUM
  	 	AND TO_OP_SEQ_NUM    =  lv_TO_OP_SEQ_NUM;
      END IF;

      IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) OR SQL%NOTFOUND THEN
	  EXECUTE IMMEDIATE lv_sql_stmt
	  USING
    	   lv_TRANSACTION_ID,
    	   lv_FROM_OP_SEQ_NUM,
    	   lv_TO_OP_SEQ_NUM,
    	   lv_ORGANIZATION_ID,
    	   lv_FROM_OP_SEQ_ID,
    	   lv_TO_OP_SEQ_ID,
	   lv_RECOMMENDED,
    	   lv_TRANSITION_TYPE,
    	   lv_PLANNING_PCT,
	   lv_TO_TRANSACTION_ID,	  /* ds change change start */
	   lv_TOP_TRANSACTION_ID,
	   lv_TRANSFER_QTY,
	   lv_TRANSFER_UOM,
	   lv_TRANSFER_PCT,
	   lv_FROM_ITEM_ID,
	   lv_APPLY_TO_CHARGES,
	   lv_MINIMUM_TRANSFER_QTY,
	   lv_MINIMUM_TIME_OFFSET,
	   lv_MAXIMUM_TIME_OFFSET,
	   lv_DEPENDENCY_TYPE,		/* ds change change end */
	   lv_SR_INSTANCE_ID,
    	   MSC_CL_COLLECTION.v_last_collection_id,
    	   MSC_CL_COLLECTION.v_current_date,
    	   MSC_CL_COLLECTION.v_current_user,
    	   MSC_CL_COLLECTION.v_current_date,
    	   MSC_CL_COLLECTION.v_current_user;
	  total_count := total_count + 1;
      END IF;

     EXCEPTION
     WHEN OTHERS THEN

     	IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN

       		MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      		FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      		FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_JOB_OP_NWK');
      		FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_JOB_OPERATION_NETWORKS');
      		MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      		MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      		RAISE;

    	ELSE

      		MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

      		MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      		FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
		FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_JOB_OP_NWK');
      		FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_JOB_OPERATION_NETWORKS');
      		MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      		FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      		FND_MESSAGE.SET_TOKEN('COLUMN', 'ORGANIZATION_CODE');
      		FND_MESSAGE.SET_TOKEN('VALUE',
                            MSC_GET_NAME.ORG_CODE( lv_ORGANIZATION_ID,
                                                   MSC_CL_COLLECTION.v_instance_id));
      		MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      		MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
    	END IF;

      END;

    END LOOP;
   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Total MSC_JOB_OPERATION_NETWORKS = '||  total_count);
   END IF;

CLOSE cgen;

COMMIT;

BEGIN
   IF ((MSC_CL_COLLECTION.v_coll_prec.org_group_flag <> MSC_UTIL.G_ALL_ORGANIZATIONS ) AND (MSC_CL_COLLECTION.v_exchange_mode=MSC_UTIL.SYS_YES)) THEN

	lv_tbl:= 'JOB_OPERATION_NETWORKS_'||MSC_CL_COLLECTION.v_instance_code;

	lv_sql_stmt:=
         'INSERT INTO '||lv_tbl
          ||' SELECT * from MSC_JOB_OPERATION_NETWORKS'
          ||' WHERE sr_instance_id = '||MSC_CL_COLLECTION.v_instance_id
          ||' AND plan_id = -1 '
          ||' AND organization_id not '||MSC_UTIL.v_in_org_str;

   	MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'The sql statement is '||lv_sql_stmt);
   	EXECUTE IMMEDIATE lv_sql_stmt;

   	COMMIT;

   END IF;

 EXCEPTION
  WHEN OTHERS THEN

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RAISE;
 END;

IF MSC_CL_COLLECTION.v_exchange_mode=MSC_UTIL.SYS_YES THEN
   MSC_CL_COLLECTION.alter_temp_table (lv_errbuf,
   	              lv_retcode,
                      'MSC_JOB_OPERATION_NETWORKS',
                      MSC_CL_COLLECTION.v_instance_code,
                      MSC_UTIL.G_WARNING
                     );

   IF lv_retcode = MSC_UTIL.G_ERROR THEN
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, lv_errbuf);
      RAISE MSC_CL_COLLECTION.ALTER_TEMP_TABLE_ERROR;
   ELSIF lv_retcode = MSC_UTIL.G_WARNING THEN
      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;
   END IF;

END IF;

EXCEPTION
   WHEN OTHERS THEN
      IF cgen%ISOPEN THEN CLOSE cgen; END IF;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '<<LOAD_JOB_OP_NWK>>');
      IF lv_cursor_stmt IS NOT NULL THEN
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '<<CURSOR>>'||lv_cursor_stmt);
      END IF;
      IF lv_sql_stmt IS NOT NULL THEN
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '<<SQL>>'||lv_sql_stmt);
      END IF;
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  SQLERRM);
      RAISE;
END LOAD_JOB_OP_NWK;

--=========================================================================
-- =================== LOAD_RES_INST_REQ  ===============
PROCEDURE LOAD_RES_INST_REQ IS
   TYPE CurTyp IS REF CURSOR; -- define weak REF CURSOR type
   res_inst_req             CurTyp;

   c_count         NUMBER:=0;
  total_count      NUMBER:=0;
   lv_tbl          VARCHAR2(30);
   lv_supplies_tbl VARCHAR2(30);
   lv_sql_stmt     VARCHAR2(32767);
   lv_cursor_stmt  VARCHAR2(5000);

   CURSOR res_inst_req_d IS
    SELECT
    msrir.WIP_ENTITY_ID,
    msrir.OPERATION_SEQ_NUM,
    msrir.ORIG_RESOURCE_SEQ_NUM,
    msrir.SR_INSTANCE_ID,
    msrir.SERIAL_NUMBER,
    msrir.RES_INSTANCE_ID
    FROM MSC_ST_RESOURCE_INSTANCE_REQS msrir
    WHERE msrir.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
    AND  msrir.DELETED_FLAG= MSC_UTIL.SYS_YES;

    lv_DEPARTMENT_ID    		NUMBER;
    lv_RESOURCE_ID      		NUMBER;
    lv_ORGANIZATION_ID  		NUMBER;
    lv_SUPPLY_ID        		NUMBER;
    lv_WIP_ENTITY_ID    		NUMBER;
    lv_OPERATION_SEQ_NUM        	NUMBER;
    --lv_OPERATION_SEQUENCE_ID    	NUMBER;
    lv_RESOURCE_SEQ_NUM         	NUMBER;
    lv_START_DATE               	DATE;
    lv_END_DATE       			DATE;
    lv_OPERATION_HOURS_REQUIRED 	NUMBER;
    lv_DELETED_FLAG   			NUMBER;
    lv_SR_INSTANCE_ID 			NUMBER;
    lv_SETUP_ID           		NUMBER;
    lv_RES_INSTANCE_ID         		NUMBER;
    lv_EQUIPMENT_ITEM_ID       		NUMBER;
    lv_SERIAL_NUMBER           		VARCHAR2(30);
    lv_ORIG_RESOURCE_SEQ_NUM  		NUMBER;
    lv_BATCH_NUMBER		NUMBER;

  lv_errbuf			VARCHAR2(240);
  lv_retcode			NUMBER;
  lv_sql_ins  			VARCHAR2(6000);
  lb_refresh_failed 		BOOLEAN:= FALSE;

BEGIN


 IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) THEN
  COMMIT;
 END IF;

 c_count:= 0;
 total_count := 0;
 IF MSC_CL_COLLECTION.v_exchange_mode=MSC_UTIL.SYS_YES THEN
   lv_tbl:= 'RESOURCE_INSTANCE_REQS_'||MSC_CL_COLLECTION.v_instance_code;
   lv_supplies_tbl:= 'SUPPLIES_'||MSC_CL_COLLECTION.v_instance_code;
 ELSE
   lv_tbl:= 'MSC_RESOURCE_INSTANCE_REQS';
   lv_supplies_tbl:= 'MSC_SUPPLIES';
 END IF;

 lv_cursor_stmt:=
 'SELECT'
 ||'    NVL(ms.TRANSACTION_ID,-1)   SUPPLY_ID,'
 ||'    msrir.WIP_ENTITY_ID,'
 ||'    msrir.ORGANIZATION_ID,'
 ||'    msrir.DEPARTMENT_ID,'
 ||'    msrir.OPERATION_SEQ_NUM,'
 --||'    msrir.OPERATION_SEQUENCE_ID,'
 ||'    msrir.RESOURCE_SEQ_NUM,'
 ||'    msrir.START_DATE,'
 ||'    msrir.END_DATE,'
 ||'    msrir.RESOURCE_INSTANCE_HOURS,'
 ||'    msrir.DELETED_FLAG,'
 ||'    msrir.SR_INSTANCE_ID,'
 ||'    msrir.ORIG_RESOURCE_SEQ_NUM, '
 ||'    msrir.BATCH_NUMBER, '
 ||'    msrir.RES_INSTANCE_ID, '
 ||'    msrir.RESOURCE_ID, '
 ||'    msrir.SERIAL_NUMBER, '
 ||'    t1.INVENTORY_ITEM_ID equipment_item_id'
 ||' FROM '||lv_supplies_tbl||' ms,'
 ||'      MSC_ST_RESOURCE_INSTANCE_REQS msrir,'
 ||'      MSC_ITEM_ID_LID t1'
 ||' WHERE msrir.SR_INSTANCE_ID= '||MSC_CL_COLLECTION.v_instance_id
 ||'  AND ms.PLAN_ID= -1'
 ||'  AND ms.SR_INSTANCE_ID= msrir.SR_INSTANCE_ID'
 ||'  AND ms.DISPOSITION_ID= msrir.WIP_ENTITY_ID'
 ||'  AND ms.ORDER_TYPE IN ( 3, 7,70)'
 ||'  AND msrir.DELETED_FLAG= '||MSC_UTIL.SYS_NO
 ||'  AND t1.sr_inventory_item_id (+) = msrir.equipment_item_id '
 ||'  AND t1.SR_INSTANCE_ID (+) = msrir.SR_INSTANCE_ID ';


 -- ========= Prepare SQL Statement for INSERT ==========
 lv_sql_stmt:=
 'insert into '||lv_tbl
 ||'  ( PLAN_ID,'
 ||'    RES_INST_TRANSACTION_ID,'
 ||'    SR_INSTANCE_ID,'
 ||'    ORGANIZATION_ID,'
 ||'    DEPARTMENT_ID,'
 ||'    SUPPLY_ID,'
 ||'    WIP_ENTITY_ID,'
 ||'    OPERATION_SEQ_NUM,'
 ||'    RESOURCE_SEQ_NUM,'
 ||'    ORIG_RESOURCE_SEQ_NUM,'
 ||'    RESOURCE_ID,'
 ||'    RES_INSTANCE_ID,'
 ||'    SERIAL_NUMBER,'
 ||'    EQUIPMENT_ITEM_ID,'
 ||'    START_DATE,'
 ||'    END_DATE,'
 ||'    RESOURCE_INSTANCE_HOURS,'
 ||'    REFRESH_NUMBER,'
 ||'    BATCH_NUMBER, '
 ||'    LAST_UPDATE_DATE,'
 ||'    LAST_UPDATED_BY,'
 ||'    CREATION_DATE,'
 ||'    CREATED_BY)'
 ||'VALUES'
 ||'(   -1,'
 ||'    MSC_RESOURCE_INSTANCE_REQS_S.NEXTVAL,'
 ||'    :SR_INSTANCE_ID,'
 ||'    :ORGANIZATION_ID,'
 ||'    :DEPARTMENT_ID,'
 ||'    :SUPPLY_ID,'
 ||'    :WIP_ENTITY_ID,'
 ||'    :OPERATION_SEQ_NUM,'
 ||'    :RESOURCE_SEQ_NUM,'
 ||'    :ORIG_RESOURCE_SEQ_NUM,'
 ||'    :RESOURCE_ID,'
 ||'    :RES_INSTANCE_ID,'
 ||'    :SERIAL_NUMBER,'
 ||'    :EQUIPMENT_ITEM_ID,'
 ||'    :START_DATE,'
 ||'    :END_DATE,'
 ||'    :OPERATION_HOURS_REQUIRED,'
 ||'    :v_last_collection_id,'
 ||'    :BATCH_NUMBER, '
 ||'    :v_current_date,'
 ||'    :v_current_user,'
 ||'    :v_current_date,'
 ||'    :v_current_user)';

IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) AND MSC_CL_COLLECTION.v_exchange_mode=MSC_UTIL.SYS_YES THEN
  BEGIN
    lv_sql_ins:=
    'insert into '||lv_tbl
     ||'  ( PLAN_ID,'
     ||'    RES_INST_TRANSACTION_ID,'
     ||'    SR_INSTANCE_ID,'
     ||'    ORGANIZATION_ID,'
     ||'    DEPARTMENT_ID,'
     ||'    SUPPLY_ID,'
     ||'    WIP_ENTITY_ID,'
     ||'    OPERATION_SEQ_NUM,'
     ||'    RESOURCE_SEQ_NUM,'
     ||'    ORIG_RESOURCE_SEQ_NUM,'
     ||'    RESOURCE_ID,'
     ||'    RES_INSTANCE_ID,'
     ||'    SERIAL_NUMBER,'
     ||'    EQUIPMENT_ITEM_ID,'
     ||'    START_DATE,'
     ||'    END_DATE,'
     ||'    RESOURCE_INSTANCE_HOURS,'
     ||'    REFRESH_NUMBER,'
     ||'    BATCH_NUMBER, '
     ||'    LAST_UPDATE_DATE,'
     ||'    LAST_UPDATED_BY,'
     ||'    CREATION_DATE,'
     ||'    CREATED_BY)'
     ||' SELECT '
     ||'    -1,'
     ||'    MSC_RESOURCE_INSTANCE_REQS_S.NEXTVAL,'
     ||'    msrir.SR_INSTANCE_ID,'
     ||'    msrir.ORGANIZATION_ID,'
     ||'    msrir.DEPARTMENT_ID,'
     ||'    NVL(ms.TRANSACTION_ID,-1)   SUPPLY_ID,'
     ||'    msrir.WIP_ENTITY_ID,'
     ||'    msrir.OPERATION_SEQ_NUM,'
     ||'    msrir.RESOURCE_SEQ_NUM,'
     ||'    msrir.ORIG_RESOURCE_SEQ_NUM,'
     ||'    msrir.RESOURCE_ID,'
     ||'    msrir.RES_INSTANCE_ID,'
     ||'    msrir.SERIAL_NUMBER,'
     ||'    t1.INVENTORY_ITEM_ID,'
     ||'    msrir.START_DATE,'
     ||'    msrir.END_DATE,'
     ||'    msrir.RESOURCE_INSTANCE_HOURS,'
     ||'    :v_last_collection_id, '
     ||'    msrir.BATCH_NUMBER, '
     ||'    :v_current_date, '
     ||'    :v_current_user, '
     ||'    :v_current_date, '
     ||'    :v_current_user '
     ||' FROM '||lv_supplies_tbl||' ms, '
     ||'      MSC_ST_RESOURCE_INSTANCE_REQS msrir, '
     ||'      MSC_ITEM_ID_LID t1 '
     ||' WHERE msrir.SR_INSTANCE_ID= '||MSC_CL_COLLECTION.v_instance_id
     ||'  AND ms.PLAN_ID= -1 '
     ||'  AND ms.SR_INSTANCE_ID= msrir.SR_INSTANCE_ID '
     ||'  AND ms.DISPOSITION_ID= msrir.WIP_ENTITY_ID '
     ||'  AND ms.ORDER_TYPE IN ( 3, 7,70) '
     ||'  AND msrir.DELETED_FLAG= '||MSC_UTIL.SYS_NO
     ||'  AND t1.sr_inventory_item_id (+) = msrir.equipment_item_id '
     ||'  AND t1.SR_INSTANCE_ID (+) = msrir.SR_INSTANCE_ID ';

    EXECUTE IMMEDIATE lv_sql_ins
    USING   MSC_CL_COLLECTION.v_last_collection_id,MSC_CL_COLLECTION.v_current_date,MSC_CL_COLLECTION.v_current_user,MSC_CL_COLLECTION.v_current_date,MSC_CL_COLLECTION.v_current_user;

    COMMIT;
    MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'res instance req loaded');

  EXCEPTION
     WHEN OTHERS THEN
      IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN

        MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
        FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
        FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_RES_INST_REQ');
        FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_RESOURCE_INSTANCE_REQS');
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

        MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
        RAISE;

      ELSE
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
        FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
        FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_RES_INST_REQ');
        FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_RESOURCE_INSTANCE_REQS');
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

        MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);

        --If Direct path load results in warning then the processing has to be
        --switched back to row by row processing. This will help to identify the
        --erroneous record and will also help in processing the rest of the records.
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'bulk insert failed - res instance req');
        lb_refresh_failed := TRUE;
      END IF;
  END;

END IF;   -- MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh

IF MSC_CL_COLLECTION.v_is_incremental_refresh OR lb_refresh_failed THEN

  IF MSC_CL_COLLECTION.v_is_incremental_refresh THEN

    FOR c_rec IN res_inst_req_d LOOP
       DELETE MSC_RESOURCE_INSTANCE_REQS
       WHERE  PLAN_ID		 =   -1
         AND  SR_INSTANCE_ID	 = c_rec.SR_INSTANCE_ID
         AND  WIP_ENTITY_ID	 = c_rec.WIP_ENTITY_ID
         AND  OPERATION_SEQ_NUM	 = NVL( c_rec.OPERATION_SEQ_NUM, OPERATION_SEQ_NUM)
         AND  ORIG_RESOURCE_SEQ_NUM = NVL(c_rec.ORIG_RESOURCE_SEQ_NUM, ORIG_RESOURCE_SEQ_NUM)
         AND  RES_INSTANCE_ID    = nvl( c_rec.RES_INSTANCE_ID,RES_INSTANCE_ID)
	 AND  SERIAL_NUMBER	 = nvl(c_rec.SERIAL_NUMBER,SERIAL_NUMBER);
    END LOOP;

  END IF; /* MSC_CL_COLLECTION.v_is_incremental_refresh */

    --log_debug('insert lv_sql_stmt:='||lv_sql_stmt);
 OPEN res_inst_req FOR lv_cursor_stmt;

 LOOP

    FETCH res_inst_req INTO
    lv_SUPPLY_ID,
    lv_WIP_ENTITY_ID,
    lv_ORGANIZATION_ID,
    lv_DEPARTMENT_ID,
    lv_OPERATION_SEQ_NUM,
    --lv_OPERATION_SEQUENCE_ID,
    lv_RESOURCE_SEQ_NUM,
    lv_START_DATE,
    lv_END_DATE,
    lv_OPERATION_HOURS_REQUIRED,
    lv_DELETED_FLAG,
    lv_SR_INSTANCE_ID,
    lv_ORIG_RESOURCE_SEQ_NUM,
    lv_BATCH_NUMBER,
    lv_RES_INSTANCE_ID,
    lv_RESOURCE_ID,
    lv_SERIAL_NUMBER,
    lv_EQUIPMENT_ITEM_ID;

   -- log_debug('Res Ins Req: WIP_ENTITY_ID ='||to_char(lv_WIP_ENTITY_ID)||
	--	'res inst id = '||to_char(lv_RES_INSTANCE_ID));
     EXIT WHEN res_inst_req%NOTFOUND;


   BEGIN

   IF MSC_CL_COLLECTION.v_is_incremental_refresh THEN
    /* we can get rid of thsi update and just insert as we are puting
   record in ad table when instance is updated */
      UPDATE MSC_RESOURCE_INSTANCE_REQS mrir
      SET
   	START_DATE	=   lv_START_DATE,
   	RESOURCE_INSTANCE_HOURS=   lv_OPERATION_HOURS_REQUIRED ,
   	END_DATE	=   lv_END_DATE,
   	SUPPLY_ID	= lv_SUPPLY_ID,
   	REFRESH_NUMBER	= MSC_CL_COLLECTION.v_last_collection_id,
   	RESOURCE_SEQ_NUM = lv_RESOURCE_SEQ_NUM,
   	BATCH_NUMBER  = lv_BATCH_NUMBER,
   	LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
   	LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
      WHERE PLAN_ID=   -1
  	AND SR_INSTANCE_ID=   lv_SR_INSTANCE_ID
  	AND NVL(ORIG_RESOURCE_SEQ_NUM, RESOURCE_SEQ_NUM) =
			NVL(lv_ORIG_RESOURCE_SEQ_NUM, lv_RESOURCE_SEQ_NUM)
  	AND ORGANIZATION_ID=   lv_ORGANIZATION_ID
  	AND WIP_ENTITY_ID=   lv_WIP_ENTITY_ID
  	AND OPERATION_SEQ_NUM=   lv_OPERATION_SEQ_NUM
	AND RES_INSTANCE_ID = lv_RES_INSTANCE_ID
	AND SERIAL_NUMBER = lv_SERIAL_NUMBER;
 END IF;

 IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) OR SQL%NOTFOUND THEN

    EXECUTE IMMEDIATE lv_sql_stmt
     USING
    lv_SR_INSTANCE_ID,
    lv_ORGANIZATION_ID,
    lv_DEPARTMENT_ID,
    lv_SUPPLY_ID,
    lv_WIP_ENTITY_ID,
    lv_OPERATION_SEQ_NUM,
    lv_RESOURCE_SEQ_NUM,
    lv_ORIG_RESOURCE_SEQ_NUM,
    lv_RESOURCE_ID,
    lv_RES_INSTANCE_ID,
    lv_SERIAL_NUMBER,
    lv_EQUIPMENT_ITEM_ID,
    lv_START_DATE,
    lv_END_DATE,
    lv_OPERATION_HOURS_REQUIRED,
    MSC_CL_COLLECTION.v_last_collection_id,
    lv_BATCH_NUMBER,
    MSC_CL_COLLECTION.v_current_date,
    MSC_CL_COLLECTION.v_current_user,
    MSC_CL_COLLECTION.v_current_date,
    MSC_CL_COLLECTION.v_current_user;

  END IF;
  total_count := total_count + 1;
  c_count:= c_count+1;

  IF c_count> MSC_CL_COLLECTION.PBS THEN
     IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) THEN COMMIT; END IF;
     c_count:= 0;
  END IF;

 EXCEPTION
   WHEN OTHERS THEN

    IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_RES_INST_REQ');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_RESOURCE_INSTANCE_REQS');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RAISE;

    ELSE

      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_RES_INST_REQ');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_RESOURCE_INSTANCE_REQS');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');

      FND_MESSAGE.SET_TOKEN('COLUMN', 'ORGANIZATION_CODE');
      FND_MESSAGE.SET_TOKEN('VALUE',
                            MSC_GET_NAME.ORG_CODE( lv_ORGANIZATION_ID,
                                                   MSC_CL_COLLECTION.v_instance_id));
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'DEPARTMENT_ID');
      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(lv_DEPARTMENT_ID));
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'RESOURCE_ID');
      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(lv_RESOURCE_ID));
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'RES_INSTANCE_ID');
      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(lv_RES_INSTANCE_ID));
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
    END IF;

  END;

 END LOOP;

 END IF; -- MSC_CL_COLLECTION.v_is_incremental_refresh OR lb_refresh_failed

 IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) THEN
    COMMIT;
 END IF;

 BEGIN

   IF ((MSC_CL_COLLECTION.v_coll_prec.org_group_flag <> MSC_UTIL.G_ALL_ORGANIZATIONS ) AND (MSC_CL_COLLECTION.v_exchange_mode=MSC_UTIL.SYS_YES)) THEN

       lv_tbl:= 'RESOURCE_INSTANCE_REQS_'||MSC_CL_COLLECTION.v_instance_code;
       lv_sql_stmt:=
         'INSERT INTO '||lv_tbl
          ||' SELECT * from MSC_RESOURCE_INSTANCE_REQS'
          ||' WHERE sr_instance_id = '||MSC_CL_COLLECTION.v_instance_id
          ||' AND plan_id = -1 '
          ||' AND organization_id not '||MSC_UTIL.v_in_org_str;


      EXECUTE IMMEDIATE lv_sql_stmt;

      COMMIT;

  END IF;

 EXCEPTION
      WHEN OTHERS THEN

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RAISE;
 END;

IF MSC_CL_COLLECTION.v_exchange_mode=MSC_UTIL.SYS_YES THEN
   MSC_CL_COLLECTION.alter_temp_table (lv_errbuf,
   	              lv_retcode,
                      'MSC_RESOURCE_INSTANCE_REQS',
                      MSC_CL_COLLECTION.v_instance_code,
                      MSC_UTIL.G_WARNING
                     );

   IF lv_retcode = MSC_UTIL.G_ERROR THEN
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, lv_errbuf);
      RAISE MSC_CL_COLLECTION.ALTER_TEMP_TABLE_ERROR;
   ELSIF lv_retcode = MSC_UTIL.G_WARNING THEN
      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;
   END IF;

END IF;

 EXCEPTION
  WHEN OTHERS THEN
      IF res_inst_req%ISOPEN THEN CLOSE res_inst_req; END IF;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '<<LOAD_RES_INST_REQ>>');
      IF lv_cursor_stmt IS NOT NULL THEN
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '<<CURSOR>>'||lv_cursor_stmt);
      END IF;
      IF lv_sql_stmt IS NOT NULL THEN
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '<<SQL>>'||lv_sql_stmt);
      END IF;
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  SQLERRM);
      RAISE;
 END LOAD_RES_INST_REQ;

--===================================================================
-- =================== LOAD WIP DEMAND ===============
PROCEDURE LOAD_WIP_DEMAND IS

   TYPE CurTyp IS REF CURSOR; -- define weak REF CURSOR type
   c2              CurTyp;

   c_count         NUMBER:=0;
   lv_tbl          VARCHAR2(30);
   lv_supplies_tbl VARCHAR2(30);
   lv_sql_stmt     VARCHAR2(32767);
   lv_cursor_stmt  VARCHAR2(5000);
   v_srp_profile_vlaue  NUMBER;
  CURSOR c2_d IS
SELECT msd.WIP_ENTITY_ID,
       msd.REPETITIVE_SCHEDULE_ID,
       msd.OPERATION_SEQ_NUM,
       t1.INVENTORY_ITEM_ID,
       msd.ORIGINATION_TYPE,
       msd.SR_INSTANCE_ID,
       msd.ORGANIZATION_ID
  FROM MSC_ITEM_ID_LID t1,
       MSC_ST_DEMANDS msd
 WHERE msd.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
   AND msd.ORIGINATION_TYPE IN (2,3,4,25,50,70)   /* ds change change 50 eam demand */
   AND msd.DELETED_FLAG= MSC_UTIL.SYS_YES
   AND t1.SR_INVENTORY_ITEM_ID(+)= msd.inventory_item_id
   AND t1.sr_instance_id(+)= MSC_CL_COLLECTION.v_instance_id;

   lv_DISPOSITION_ID     NUMBER;
   lv_INVENTORY_ITEM_ID  NUMBER;
   lv_ORGANIZATION_ID    NUMBER;
   lv_USING_ASSEMBLY_ITEM_ID      NUMBER;
   lv_USING_ASSEMBLY_DEMAND_DATE  DATE;
   lv_USING_REQUIREMENT_QUANTITY  NUMBER;
   lv_QUANTITY_PER_ASSEMBLY       NUMBER;
   lv_QUANTITY_ISSUED             NUMBER;
   lv_ASSEMBLY_DEMAND_COMP_DATE   DATE;
   lv_DEMAND_TYPE             NUMBER;
   lv_ORIGINATION_TYPE        NUMBER;
   lv_SOURCE_ORGANIZATION_ID  NUMBER;
   lv_RESERVATION_ID          NUMBER;
   lv_OPERATION_SEQ_NUM       NUMBER;
   lv_DEMAND_CLASS            VARCHAR2(34);
   lv_REPETITIVE_SCHEDULE_ID  NUMBER;
   lv_ASSET_ITEM_ID	      NUMBER;		/* ds change change */
   lv_ASSET_SERIAL_NUMBER     VARCHAR2(30);	/* ds change change */
   lv_SR_INSTANCE_ID          NUMBER;
   lv_PROJECT_ID              NUMBER;
   lv_TASK_ID                 NUMBER;
   lv_PLANNING_GROUP          VARCHAR2(30);
   lv_END_ITEM_UNIT_NUMBER    VARCHAR2(30);
   lv_COMPONENT_SCALING_TYPE  NUMBER;  /* Discrete Mfg Enahancements Bug 4492736 */
   lv_COMPONENT_YIELD_FACTOR  NUMBER;  /* Discrete Mfg Enahancements Bug 4479743 */
   lv_ORDER_NUMBER     VARCHAR2(240);
   lv_WIP_ENTITY_ID    NUMBER;
   lv_WIP_STATUS_CODE  NUMBER;
   lv_WIP_SUPPLY_TYPE  NUMBER;
   lv_DELETED_FLAG     NUMBER;

BEGIN

--=========================  WIP DEMANDS ======================
-- link disposition_id to MSC_supplies.transaction_id

IF MSC_CL_COLLECTION.v_is_incremental_refresh THEN

FOR c_rec IN c2_d LOOP

IF c_rec.ORIGINATION_TYPE IN (2, 3, 50, 70) THEN   -- DISCRETE JOB COMPONENT /* ds change 50 eam demand */

UPDATE MSC_DEMANDS
   SET USING_REQUIREMENT_QUANTITY= 0,
       DAILY_DEMAND_RATE= 0,
       REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
       LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
       LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
 WHERE PLAN_ID=  -1
   AND SR_INSTANCE_ID=  c_rec.SR_INSTANCE_ID
   AND ORIGINATION_TYPE=  c_rec.ORIGINATION_TYPE
   AND WIP_ENTITY_ID=  c_rec.WIP_ENTITY_ID
   AND OP_SEQ_NUM=  NVL(c_rec.OPERATION_SEQ_NUM,OP_SEQ_NUM)
   AND ORGANIZATION_ID = c_rec.ORGANIZATION_ID
   AND INVENTORY_ITEM_ID=  NVL(c_rec.INVENTORY_ITEM_ID,INVENTORY_ITEM_ID);

ELSIF c_rec.ORIGINATION_TYPE= 4 THEN       -- REPT ITEM

UPDATE MSC_DEMANDS
   SET USING_REQUIREMENT_QUANTITY= 0,
       DAILY_DEMAND_RATE= 0,
       REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
       LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
       LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
WHERE PLAN_ID=  -1
  AND SR_INSTANCE_ID=         c_rec.SR_INSTANCE_ID
  AND ORIGINATION_TYPE=       c_rec.ORIGINATION_TYPE
  AND WIP_ENTITY_ID=          NVL(c_rec.WIP_ENTITY_ID,WIP_ENTITY_ID)
  AND OP_SEQ_NUM=             NVL(c_rec.OPERATION_SEQ_NUM,OP_SEQ_NUM)
  AND INVENTORY_ITEM_ID=      NVL(c_rec.INVENTORY_ITEM_ID,INVENTORY_ITEM_ID)
  AND REPETITIVE_SCHEDULE_ID= c_rec.REPETITIVE_SCHEDULE_ID
  AND ORGANIZATION_ID =       c_rec.ORGANIZATION_ID;

ELSIF c_rec.ORIGINATION_TYPE= 25 THEN       -- FLOW SCHEDULE

DELETE MSC_DEMANDS
WHERE PLAN_ID=  -1
  AND SR_INSTANCE_ID=    c_rec.SR_INSTANCE_ID
  AND ORIGINATION_TYPE=  c_rec.ORIGINATION_TYPE
  AND WIP_ENTITY_ID=     c_rec.WIP_ENTITY_ID
  AND ORGANIZATION_ID = c_rec.ORGANIZATION_ID;

END IF;  -- Origination_Type

END LOOP;

END IF;  -- refresh mode

IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) THEN COMMIT; END IF;

c_count:=0;

-- ========= Prepare the Cursor Statement ==========
IF MSC_CL_COLLECTION.v_exchange_mode=MSC_UTIL.SYS_YES THEN
   lv_tbl:= 'DEMANDS_'||MSC_CL_COLLECTION.v_instance_code;
   lv_supplies_tbl:= 'SUPPLIES_'||MSC_CL_COLLECTION.v_instance_code;
ELSE
   lv_tbl:= 'MSC_DEMANDS';
   lv_supplies_tbl:= 'MSC_SUPPLIES';
END IF;

   /** PREPLACE CHANGE START **/

   -- For Load_WIP_DEMAND Supplies are also loaded - WIP Parameter
   -- simultaneously hence no special logic is needed
   -- for determining which SUPPLY table to be used for pegging.

   /**  PREPLACE CHANGE END  **/
  /* 2201791 - select substr(order_number,1,62) since order_number is
   defined as varchar(62) in msc_demands table */


 IF (MSC_UTIL.G_COLLECT_SRP_DATA = 'Y') Then
 v_srp_profile_vlaue := 1;

 ELSE
 v_srp_profile_vlaue := 0;

 END IF;                -- For Bug 5909379

lv_cursor_stmt:=
'SELECT'
||'   -1, MSC_DEMANDS_S.nextval, '
||'   NVL(ms.TRANSACTION_ID,-1) DISPOSITION_ID,'
||'   t1.INVENTORY_ITEM_ID,'
||'   msd.ORGANIZATION_ID,'
||'   t2.INVENTORY_ITEM_ID USING_ASSEMBLY_ITEM_ID,'
||'   msd.USING_ASSEMBLY_DEMAND_DATE,'
||'   msd.USING_REQUIREMENT_QUANTITY,'
||'   msd.QUANTITY_PER_ASSEMBLY,'
||'   msd.QUANTITY_ISSUED,'
||'   msd.ASSEMBLY_DEMAND_COMP_DATE,'
||'   msd.DEMAND_TYPE,'
||'   msd.ORIGINATION_TYPE,'
||'   msd.SOURCE_ORGANIZATION_ID,'
||'   msd.RESERVATION_ID,'
||'   msd.OPERATION_SEQ_NUM,'
||'   msd.DEMAND_CLASS,'
||'   msd.REPETITIVE_SCHEDULE_ID,'
||'   msd.SR_INSTANCE_ID,'
||'   msd.PROJECT_ID,'
||'   msd.TASK_ID,'
||'   msd.PLANNING_GROUP,'
||'   msd.END_ITEM_UNIT_NUMBER, '
||'   REPLACE(REPLACE(substr(msd.ORDER_NUMBER,1,62),:v_chr10),:v_chr13) ORDER_NUMBER,'
||'   msd.WIP_ENTITY_ID,'
||'   msd.WIP_STATUS_CODE,'
||'   msd.WIP_SUPPLY_TYPE,'
||'   t3.inventory_item_id  ASSET_ITEM_ID,'   /* ds change change*/
||'   msd.ASSET_SERIAL_NUMBER,'  /* ds change change*/
||'   msd.COMPONENT_SCALING_TYPE,' /* Discrete Mfg Enahancements Bug 4492736 */
||'   msd.COMPONENT_YIELD_FACTOR,' /* Discrete Mfg Enahancements Bug 4479743 */
||'   DECODE (:v_srp_profile_vlaue,1,msd.ITEM_TYPE_ID,NULL), '
||'   DECODE (:v_srp_profile_vlaue,1,msd.ITEM_TYPE_VALUE,NULL),'   -- For bug 5909379
||'   :v_last_collection_id,'
||'   :v_current_date,'
||'   :v_current_user,'
||'   :v_current_date,'
||'   :v_current_user '
||' FROM MSC_ITEM_ID_LID t1,'
||'      MSC_ITEM_ID_LID t2,'
||'      MSC_ITEM_ID_LID t3,'
      || lv_supplies_tbl||' ms,'
||'      MSC_ST_DEMANDS msd'
||' WHERE msd.SR_INSTANCE_ID= '||MSC_CL_COLLECTION.v_instance_id
||'  AND msd.ORIGINATION_TYPE IN (2,3,4,25,50,70)'   /* 50 eam demand: ds change change*/
||'  AND msd.DELETED_FLAG= '||MSC_UTIL.SYS_NO
||'  AND t1.SR_INVENTORY_ITEM_ID= msd.inventory_item_id'
||'  AND t1.sr_instance_id= msd.SR_INSTANCE_ID'
||'  AND t2.SR_INVENTORY_ITEM_ID= msd.using_assembly_item_id'
||'  AND t2.sr_instance_id= msd.SR_INSTANCE_ID'
||'  AND t3.SR_INVENTORY_ITEM_ID (+)= msd.ASSET_ITEM_ID'
||'  AND t3.sr_instance_id (+) = msd.SR_INSTANCE_ID'
||'  AND ms.sr_instance_id(+)= msd.SR_INSTANCE_ID'
||'  AND ms.ORGANIZATION_ID(+)= msd.ORGANIZATION_ID'
||'  AND ms.DISPOSITION_ID(+)= DECODE( msd.ORIGINATION_TYPE,'
||'                                    4, msd.REPETITIVE_SCHEDULE_ID,'
||'                                    msd.WIP_ENTITY_ID)'
||'  AND ms.plan_id(+)=-1'
||'  AND ms.ORDER_TYPE(+)= DECODE( msd.ORIGINATION_TYPE, 2,7,3,3,4,4,25,27,50,70,70,70)'; /* ds change change*/

IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) THEN
lv_sql_stmt:=
'INSERT /*+ APPEND */  INTO '||lv_tbl
||'(  PLAN_ID,'
||'   DEMAND_ID,'
||'   DISPOSITION_ID,'
||'   INVENTORY_ITEM_ID,'
||'   ORGANIZATION_ID,'
||'   USING_ASSEMBLY_ITEM_ID,'
||'   USING_ASSEMBLY_DEMAND_DATE,'
||'   USING_REQUIREMENT_QUANTITY,'
||'   QUANTITY_PER_ASSEMBLY,'
||'   ISSUED_QUANTITY,'
||'   ASSEMBLY_DEMAND_COMP_DATE,'
||'   DEMAND_TYPE,'
||'   ORIGINATION_TYPE,'
||'   SOURCE_ORGANIZATION_ID,'
||'   RESERVATION_ID,'
||'   OP_SEQ_NUM,'
||'   DEMAND_CLASS,'
||'   REPETITIVE_SCHEDULE_ID,'
||'   SR_INSTANCE_ID,'
||'   PROJECT_ID,'
||'   TASK_ID,'
||'   PLANNING_GROUP,'
||'   UNIT_NUMBER,'
||'   ORDER_NUMBER,'
||'   WIP_ENTITY_ID,'
||'   WIP_STATUS_CODE,'
||'   WIP_SUPPLY_TYPE,'
||'   ASSET_ITEM_ID,'
||'   ASSET_SERIAL_NUMBER,'
||'   COMPONENT_SCALING_TYPE,'
||'   COMPONENT_YIELD_FACTOR,'
||'   ITEM_TYPE_ID,'
||'   ITEM_TYPE_VALUE,'   -- For bug 5909379
||'   REFRESH_NUMBER,'
||'   LAST_UPDATE_DATE,'
||'   LAST_UPDATED_BY,'
||'   CREATION_DATE,'
||'   CREATED_BY)'
|| lv_cursor_stmt;

BEGIN

   SAVEPOINT Load_wip_SP;
   EXECUTE IMMEDIATE lv_sql_stmt
	 USING
	 MSC_CL_COLLECTION.v_chr10,
	 MSC_CL_COLLECTION.v_chr13,
	 v_srp_profile_vlaue,
	 v_srp_profile_vlaue,
	 MSC_CL_COLLECTION.v_last_collection_id,
	 MSC_CL_COLLECTION.v_current_date,
	 MSC_CL_COLLECTION.v_current_user,
	 MSC_CL_COLLECTION.v_current_date,
	 MSC_CL_COLLECTION.v_current_user;

   COMMIT;
   RETURN;

   EXCEPTION
   WHEN OTHERS THEN

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '<<LOAD_WIP_DEMAND>>');
      IF lv_sql_stmt IS NOT NULL THEN
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '<<CURSOR>>'|| lv_sql_stmt);
      END IF;
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  SQLERRM);

	  ROLLBACK WORK TO SAVEPOINT Load_wip_SP;
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Switching to Row-By-Row processing.');

END;
END IF;

-- ========= Prepare SQL Statement for INSERT ==========
lv_sql_stmt:=
'INSERT INTO '||lv_tbl
||'(  PLAN_ID,'
||'   DEMAND_ID,'
||'   INVENTORY_ITEM_ID,'
||'   ORGANIZATION_ID,'
||'   USING_ASSEMBLY_ITEM_ID,'
||'   USING_ASSEMBLY_DEMAND_DATE,'
||'   USING_REQUIREMENT_QUANTITY,'
||'   QUANTITY_PER_ASSEMBLY,'
||'   ISSUED_QUANTITY,'
||'   ASSEMBLY_DEMAND_COMP_DATE,'
||'   DEMAND_TYPE,'
||'   ORIGINATION_TYPE,'
||'   SOURCE_ORGANIZATION_ID,'
||'   DISPOSITION_ID,'
||'   RESERVATION_ID,'
||'   OP_SEQ_NUM,'
||'   DEMAND_CLASS,'
||'   SR_INSTANCE_ID,'
||'   PROJECT_ID,'
||'   TASK_ID,'
||'   PLANNING_GROUP,'
||'   UNIT_NUMBER,'
||'   ORDER_NUMBER,'
||'   WIP_ENTITY_ID,'
||'   WIP_STATUS_CODE,'
||'   WIP_SUPPLY_TYPE,'
||'   REPETITIVE_SCHEDULE_ID,'
||'   ASSET_ITEM_ID,'    /* ds change change*/
||'   ASSET_SERIAL_NUMBER,'	/* ds change change*/
||'   COMPONENT_SCALING_TYPE,'  /* Discrete Mfg Enahancements Bug 4492736 */
||'   COMPONENT_YIELD_FACTOR,'  /* Discrete Mfg Enahancements Bug 4492743 */
||'   REFRESH_NUMBER,'
||'   LAST_UPDATE_DATE,'
||'   LAST_UPDATED_BY,'
||'   CREATION_DATE,'
||'   CREATED_BY)'
||'VALUES'
||'(  -1,'
||'   MSC_DEMANDS_S.nextval,'
||'   :INVENTORY_ITEM_ID,'
||'   :ORGANIZATION_ID,'
||'   :USING_ASSEMBLY_ITEM_ID,'
||'   :USING_ASSEMBLY_DEMAND_DATE,'
||'   :USING_REQUIREMENT_QUANTITY,'
||'   :QUANTITY_PER_ASSEMBLY,'
||'   :ISSUED_QUANTITY,'
||'   :ASSEMBLY_DEMAND_COMP_DATE,'
||'   :DEMAND_TYPE,'
||'   :ORIGINATION_TYPE,'
||'   :SOURCE_ORGANIZATION_ID,'
||'   :DISPOSITION_ID,'
||'   :RESERVATION_ID,'
||'   :OPERATION_SEQ_NUM,'
||'   :DEMAND_CLASS,'
||'   :SR_INSTANCE_ID,'
||'   :PROJECT_ID,'
||'   :TASK_ID,'
||'   :PLANNING_GROUP,'
||'   :END_ITEM_UNIT_NUMBER, '
||'   :ORDER_NUMBER,'
||'   :WIP_ENTITY_ID,'
||'   :WIP_STATUS_CODE,'
||'   :WIP_SUPPLY_TYPE,'
||'   :REPETITIVE_SCHEDULE_ID,'
||'   :ASSET_ITEM_ID,'		/* ds change change*/
||'   :ASSET_SERIAL_NUMBER,'    /* ds change change*/
||'   :COMPONENT_SCALING_TYPE,' /* Discrete Mfg Enahancements Bug 4492736 */
||'   :COMPONENT_YIELD_FACTOR,' /* Discrete Mfg Enahancements Bug 4492743 */
||'   :v_last_collection_id,'
||'   :v_current_date,'
||'   :v_current_user,'
||'   :v_current_date,'
||'   :v_current_user )';

/* Cursor statement below is used in case of net change.
   This cursor will also load data in target/complete mode,
   if the bulk insert above failed for whatever reason */

lv_cursor_stmt:=
'SELECT'
||'   NVL(ms.TRANSACTION_ID,-1) DISPOSITION_ID,'
||'   t1.INVENTORY_ITEM_ID,'
||'   msd.ORGANIZATION_ID,'
||'   t2.INVENTORY_ITEM_ID USING_ASSEMBLY_ITEM_ID,'
||'   msd.USING_ASSEMBLY_DEMAND_DATE,'
||'   msd.USING_REQUIREMENT_QUANTITY,'
||'   msd.QUANTITY_PER_ASSEMBLY,'
||'   msd.QUANTITY_ISSUED,'
||'   msd.ASSEMBLY_DEMAND_COMP_DATE,'
||'   msd.DEMAND_TYPE,'
||'   msd.ORIGINATION_TYPE,'
||'   msd.SOURCE_ORGANIZATION_ID,'
||'   msd.RESERVATION_ID,'
||'   msd.OPERATION_SEQ_NUM,'
||'   msd.DEMAND_CLASS,'
||'   msd.REPETITIVE_SCHEDULE_ID,'
||'   msd.SR_INSTANCE_ID,'
||'   msd.PROJECT_ID,'
||'   msd.TASK_ID,'
||'   msd.PLANNING_GROUP,'
||'   msd.END_ITEM_UNIT_NUMBER, '
||'   REPLACE(REPLACE(substr(msd.ORDER_NUMBER,1,62),:v_chr10),:v_chr13) ORDER_NUMBER,'
||'   msd.WIP_ENTITY_ID,'
||'   msd.WIP_STATUS_CODE,'
||'   msd.WIP_SUPPLY_TYPE,'
||'   msd.DELETED_FLAG,'
||'   t3.inventory_item_id  ASSET_ITEM_ID,'   /* ds change change*/
||'   msd.ASSET_SERIAL_NUMBER,'  /* ds change change*/
||'   msd.COMPONENT_SCALING_TYPE,' /* Discrete Mfg Enahancements Bug 4492736 */
||'   msd.COMPONENT_YIELD_FACTOR' /* Discrete Mfg Enahancements Bug 4492743 */
||' FROM MSC_ITEM_ID_LID t1,'
||'      MSC_ITEM_ID_LID t2,'
||'      MSC_ITEM_ID_LID t3,'
      || lv_supplies_tbl||' ms,'
||'      MSC_ST_DEMANDS msd'
||' WHERE msd.SR_INSTANCE_ID= '||MSC_CL_COLLECTION.v_instance_id
||'  AND msd.ORIGINATION_TYPE IN (2,3,4,25,50,70)'   /* 50 eam demand: ds change change*/
||'  AND msd.DELETED_FLAG= '||MSC_UTIL.SYS_NO
||'  AND t1.SR_INVENTORY_ITEM_ID= msd.inventory_item_id'
||'  AND t1.sr_instance_id= msd.SR_INSTANCE_ID'
||'  AND t2.SR_INVENTORY_ITEM_ID= msd.using_assembly_item_id'
||'  AND t2.sr_instance_id= msd.SR_INSTANCE_ID'
||'  AND t3.SR_INVENTORY_ITEM_ID (+)= msd.ASSET_ITEM_ID'
||'  AND t3.sr_instance_id (+) = msd.SR_INSTANCE_ID'
||'  AND ms.sr_instance_id(+)= msd.SR_INSTANCE_ID'
||'  AND ms.ORGANIZATION_ID(+)= msd.ORGANIZATION_ID'
||'  AND ms.DISPOSITION_ID(+)= DECODE( msd.ORIGINATION_TYPE,'
||'                                    4, msd.REPETITIVE_SCHEDULE_ID,'
||'                                    msd.WIP_ENTITY_ID)'
||'  AND ms.plan_id(+)=-1'
||'  AND ms.ORDER_TYPE(+)= DECODE( msd.ORIGINATION_TYPE, 2,7,3,3,4,4,25,27,50,70,70,70)' /* ds change change*/
||'  order by msd.SOURCE_WIP_ENTITY_ID, msd.SOURCE_INVENTORY_ITEM_ID,msd.SOURCE_ORGANIZATION_ID,msd.ORIGINATION_TYPE';

OPEN c2 FOR lv_cursor_stmt USING MSC_CL_COLLECTION.v_chr10, MSC_CL_COLLECTION.v_chr13;

LOOP

FETCH c2 INTO
   lv_DISPOSITION_ID,
   lv_INVENTORY_ITEM_ID,
   lv_ORGANIZATION_ID,
   lv_USING_ASSEMBLY_ITEM_ID,
   lv_USING_ASSEMBLY_DEMAND_DATE,
   lv_USING_REQUIREMENT_QUANTITY,
   lv_QUANTITY_PER_ASSEMBLY,
   lv_QUANTITY_ISSUED,
   lv_ASSEMBLY_DEMAND_COMP_DATE,
   lv_DEMAND_TYPE,
   lv_ORIGINATION_TYPE,
   lv_SOURCE_ORGANIZATION_ID,
   lv_RESERVATION_ID,
   lv_OPERATION_SEQ_NUM,
   lv_DEMAND_CLASS,
   lv_REPETITIVE_SCHEDULE_ID,
   lv_SR_INSTANCE_ID,
   lv_PROJECT_ID,
   lv_TASK_ID,
   lv_PLANNING_GROUP,
   lv_END_ITEM_UNIT_NUMBER,
   lv_ORDER_NUMBER,
   lv_WIP_ENTITY_ID,
   lv_WIP_STATUS_CODE,
   lv_WIP_SUPPLY_TYPE,
   lv_DELETED_FLAG,
   lv_ASSET_ITEM_ID,		/* ds change change */
   lv_ASSET_SERIAL_NUMBER,	/* ds change change */
   lv_COMPONENT_SCALING_TYPE,  /* Discrete Mfg Enahancements Bug 4492736 */
   lv_COMPONENT_YIELD_FACTOR; /* Discrete Mfg Enahancements Bug 4492743 */

EXIT WHEN c2%NOTFOUND;

BEGIN

IF MSC_CL_COLLECTION.v_is_incremental_refresh THEN

--================= wip discrete job components ==================
IF lv_ORIGINATION_TYPE IN (2, 3, 50,70) THEN    /* ds change 50 eam demand*/

/* ATP SUMMARY CHANGES Added the OLD_**** Columns */
UPDATE /*+ INDEX (MSC_DEMANDS MSC_DEMANDS_N5) */ MSC_DEMANDS
SET
  OLD_USING_REQUIREMENT_QUANTITY=  USING_REQUIREMENT_QUANTITY,
  OLD_USING_ASSEMBLY_DEMAND_DATE=  USING_ASSEMBLY_DEMAND_DATE,
  OLD_ASSEMBLY_DEMAND_COMP_DATE=  ASSEMBLY_DEMAND_COMP_DATE,
  USING_ASSEMBLY_ITEM_ID=  lv_USING_ASSEMBLY_ITEM_ID,
  USING_ASSEMBLY_DEMAND_DATE=  lv_USING_ASSEMBLY_DEMAND_DATE,
  USING_REQUIREMENT_QUANTITY=  lv_USING_REQUIREMENT_QUANTITY,
  QUANTITY_PER_ASSEMBLY= lv_QUANTITY_PER_ASSEMBLY,
  ISSUED_QUANTITY= lv_QUANTITY_ISSUED,
  ASSEMBLY_DEMAND_COMP_DATE=  lv_ASSEMBLY_DEMAND_COMP_DATE,
  DEMAND_TYPE=  lv_DEMAND_TYPE,
  SOURCE_ORGANIZATION_ID=  lv_SOURCE_ORGANIZATION_ID,
  RESERVATION_ID=  lv_RESERVATION_ID,
  DEMAND_CLASS=  lv_DEMAND_CLASS,
  PROJECT_ID=  lv_PROJECT_ID,
  TASK_ID=  lv_TASK_ID,
  PLANNING_GROUP=  lv_PLANNING_GROUP,
  UNIT_NUMBER=  lv_END_ITEM_UNIT_NUMBER,
  ORDER_NUMBER=  lv_ORDER_NUMBER,
  WIP_STATUS_CODE= lv_WIP_STATUS_CODE,
  WIP_SUPPLY_TYPE= lv_WIP_SUPPLY_TYPE,
  DISPOSITION_ID= lv_DISPOSITION_ID,
  ASSET_ITEM_ID= lv_ASSET_ITEM_ID,    /* ds change change */
  ASSET_SERIAL_NUMBER= lv_ASSET_SERIAL_NUMBER,	/* ds changechange */
  COMPONENT_SCALING_TYPE = lv_COMPONENT_SCALING_TYPE,  /* Discrete Mfg Enahancements Bug 4492736 */
  COMPONENT_YIELD_FACTOR = lv_COMPONENT_YIELD_FACTOR,  /* Discrete Mfg Enahancements Bug 4492743 */
  REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
  LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
  LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
WHERE PLAN_ID=  -1
  AND SR_INSTANCE_ID=  lv_SR_INSTANCE_ID
  AND ORIGINATION_TYPE=  lv_ORIGINATION_TYPE
  AND ORGANIZATION_ID=  lv_ORGANIZATION_ID
  AND WIP_ENTITY_ID=  lv_WIP_ENTITY_ID
  AND OP_SEQ_NUM=  lv_OPERATION_SEQ_NUM
  AND INVENTORY_ITEM_ID=  lv_INVENTORY_ITEM_ID;

--================= wip repetitive schedule ==================
ELSIF  lv_ORIGINATION_TYPE=4 THEN

/* ATP SUMMARY CHANGES Added the OLD_**** Columns */
UPDATE MSC_DEMANDS
SET
  OLD_USING_REQUIREMENT_QUANTITY=  USING_REQUIREMENT_QUANTITY,
  OLD_USING_ASSEMBLY_DEMAND_DATE=  USING_ASSEMBLY_DEMAND_DATE,
  OLD_ASSEMBLY_DEMAND_COMP_DATE=  ASSEMBLY_DEMAND_COMP_DATE,
  USING_ASSEMBLY_ITEM_ID=  lv_USING_ASSEMBLY_ITEM_ID,
  USING_ASSEMBLY_DEMAND_DATE=  lv_USING_ASSEMBLY_DEMAND_DATE,
  USING_REQUIREMENT_QUANTITY=  lv_USING_REQUIREMENT_QUANTITY,
  ASSEMBLY_DEMAND_COMP_DATE=  lv_ASSEMBLY_DEMAND_COMP_DATE,
  DEMAND_TYPE=  lv_DEMAND_TYPE,
  SOURCE_ORGANIZATION_ID=  lv_SOURCE_ORGANIZATION_ID,
  RESERVATION_ID=  lv_RESERVATION_ID,
  DEMAND_CLASS=  lv_DEMAND_CLASS,
  PROJECT_ID=  lv_PROJECT_ID,
  TASK_ID=  lv_TASK_ID,
  PLANNING_GROUP=  lv_PLANNING_GROUP,
  UNIT_NUMBER=  lv_END_ITEM_UNIT_NUMBER,
  ORDER_NUMBER=  lv_ORDER_NUMBER,
  WIP_STATUS_CODE= lv_WIP_STATUS_CODE,
  WIP_SUPPLY_TYPE= lv_WIP_SUPPLY_TYPE,
  DISPOSITION_ID= lv_DISPOSITION_ID,
  COMPONENT_SCALING_TYPE = lv_COMPONENT_SCALING_TYPE,  /* Discrete Mfg Enahancements Bug 4492736 */
  COMPONENT_YIELD_FACTOR = lv_COMPONENT_YIELD_FACTOR,  /* Discrete Mfg Enahancements Bug 4492743 */
  REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
  LAST_UPDATE_DATE=  MSC_CL_COLLECTION.v_current_date,
  LAST_UPDATED_BY=  MSC_CL_COLLECTION.v_current_user
WHERE PLAN_ID=  -1
  AND SR_INSTANCE_ID=  lv_SR_INSTANCE_ID
  AND ORIGINATION_TYPE=  lv_ORIGINATION_TYPE
  AND ORGANIZATION_ID=  lv_ORGANIZATION_ID
  AND WIP_ENTITY_ID=  lv_WIP_ENTITY_ID
  AND OP_SEQ_NUM=  lv_OPERATION_SEQ_NUM
  AND INVENTORY_ITEM_ID=  lv_INVENTORY_ITEM_ID
  AND REPETITIVE_SCHEDULE_ID= lv_REPETITIVE_SCHEDULE_ID;

END IF;  -- Origination_Type

END IF;  -- refresh mode

IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) OR
   ( lv_DELETED_FLAG<> MSC_UTIL.SYS_YES AND SQL%NOTFOUND) OR
   ( lv_ORIGINATION_TYPE= 25) THEN

EXECUTE IMMEDIATE lv_sql_stmt
USING
   lv_INVENTORY_ITEM_ID,
   lv_ORGANIZATION_ID,
   lv_USING_ASSEMBLY_ITEM_ID,
   lv_USING_ASSEMBLY_DEMAND_DATE,
   lv_USING_REQUIREMENT_QUANTITY,
   lv_QUANTITY_PER_ASSEMBLY,
   lv_QUANTITY_ISSUED,
   lv_ASSEMBLY_DEMAND_COMP_DATE,
   lv_DEMAND_TYPE,
   lv_ORIGINATION_TYPE,
   lv_SOURCE_ORGANIZATION_ID,
   lv_DISPOSITION_ID,
   lv_RESERVATION_ID,
   lv_OPERATION_SEQ_NUM,
   lv_DEMAND_CLASS,
   lv_SR_INSTANCE_ID,
   lv_PROJECT_ID,
   lv_TASK_ID,
   lv_PLANNING_GROUP,
   lv_END_ITEM_UNIT_NUMBER,
   lv_ORDER_NUMBER,
   lv_WIP_ENTITY_ID,
   lv_WIP_STATUS_CODE,
   lv_WIP_SUPPLY_TYPE,
   lv_REPETITIVE_SCHEDULE_ID,
   lv_ASSET_ITEM_ID,    /* ds change change */
   lv_ASSET_SERIAL_NUMBER,	/* ds changechange */
   lv_COMPONENT_SCALING_TYPE, /* Discrete Mfg Enahancements Bug 4492736 */
   lv_COMPONENT_YIELD_FACTOR, /* Discrete Mfg Enahancements Bug 4492743 */
   MSC_CL_COLLECTION.v_last_collection_id,
   MSC_CL_COLLECTION.v_current_date,
   MSC_CL_COLLECTION.v_current_user,
   MSC_CL_COLLECTION.v_current_date,
   MSC_CL_COLLECTION.v_current_user;

END IF;

EXCEPTION

   WHEN OTHERS THEN

    IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_SUPPLY');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_DEMANDS');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RAISE;

    ELSE
      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_SUPPLY');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_DEMANDS');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'WIP_ENTITY_ID');
      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(lv_WIP_ENTITY_ID));
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'ITEM_NAME');
      FND_MESSAGE.SET_TOKEN('VALUE', MSC_CL_ITEM_ODS_LOAD.ITEM_NAME( lv_INVENTORY_ITEM_ID));
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'ORGANIZATION_CODE');
      FND_MESSAGE.SET_TOKEN('VALUE',
                            MSC_GET_NAME.ORG_CODE( lv_ORGANIZATION_ID,
                                                   MSC_CL_COLLECTION.v_instance_id));
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'DEMAND_TYPE');
      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(lv_DEMAND_TYPE));
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'ORIGINATION_TYPE');
      FND_MESSAGE.SET_TOKEN('VALUE',
               MSC_GET_NAME.LOOKUP_MEANING('MRP_DEMAND_ORIGINATION',
                                           lv_ORIGINATION_TYPE));
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
    END IF;

END;

  c_count:= c_count+1;

  IF c_count> MSC_CL_COLLECTION.PBS THEN
     IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) THEN COMMIT; END IF;
     c_count:= 0;
  END IF;

END LOOP; -- cursor c2

CLOSE c2;

IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) THEN COMMIT; END IF;

EXCEPTION
   WHEN OTHERS THEN
      IF c2%ISOPEN THEN CLOSE c2; END IF;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '<<LOAD_WIP_DEMAND>>');
      IF lv_cursor_stmt IS NOT NULL THEN
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '<<CURSOR>>'||lv_cursor_stmt);
      END IF;
      IF lv_sql_stmt IS NOT NULL THEN
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '<<SQL>>'||lv_sql_stmt);
      END IF;
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  SQLERRM);
      RAISE;
END LOAD_WIP_DEMAND;

--============================================================================

-- =================== LOAD RESOURCE REQUIREMENTS ===============
PROCEDURE LOAD_RES_REQ IS

   TYPE CurTyp IS REF CURSOR; -- define weak REF CURSOR type
   c4              CurTyp;

   c_count         NUMBER:=0;
   lv_tbl          VARCHAR2(30);
   lv_supplies_tbl VARCHAR2(30);
   lv_sql_stmt     VARCHAR2(32767);
   lv_cursor_stmt  VARCHAR2(5000);

   CURSOR c4_d IS
SELECT
    msrr.WIP_ENTITY_ID,
    msrr.OPERATION_SEQ_NUM,
    msrr.ORIG_RESOURCE_SEQ_NUM,
    msrr.SR_INSTANCE_ID
FROM MSC_ST_RESOURCE_REQUIREMENTS msrr
WHERE msrr.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
  AND msrr.DELETED_FLAG= MSC_UTIL.SYS_YES;

    lv_DEPARTMENT_ID    NUMBER;
    lv_RESOURCE_ID      NUMBER;
    lv_ASSEMBLY_ITEM_ID NUMBER;
    lv_ORGANIZATION_ID  NUMBER;
    lv_SUPPLY_ID        NUMBER;
    lv_WIP_ENTITY_ID    NUMBER;
    lv_ROUTING_SEQUENCE_ID	NUMBER;
    lv_OPERATION_SEQ_NUM        NUMBER;
    lv_OPERATION_SEQUENCE_ID    NUMBER;
    lv_RESOURCE_SEQ_NUM         NUMBER;
    lv_START_DATE               DATE;
    lv_OPERATION_HOURS_REQUIRED NUMBER;
    lv_HOURS_EXPENDED           NUMBER;
    lv_QUANTITY_IN_QUEUE        NUMBER;
    lv_QUANTITY_RUNNING         NUMBER;
    lv_QUANTITY_WAITING_TO_MOVE NUMBER;
    lv_QUANTITY_COMPLETED       NUMBER;
    lv_YIELD                    NUMBER;
    lv_USAGE_RATE               NUMBER;
    lv_BASIS_TYPE               NUMBER;
    lv_ASSIGNED_UNITS           NUMBER;
    lv_GROUP_SEQUENCE_ID	NUMBER;  /* ds change chaneg start */
    lv_GROUP_SEQUENCE_NUMBER	NUMBER;
    lv_BATCH_NUMBER	NUMBER;
    lv_MAXIMUM_ASSIGNED_UNITS	NUMBER;
    lv_MAXIMUM_CAPACITY		NUMBER;
    lv_BREAKABLE_ACTIVITY_FLAG	NUMBER;
    lv_STEP_QUANTITY		NUMBER;  /* ds change change end */
    lv_STEP_QUANTITY_UOM	VARCHAR2(3);  /* ds change change end */
    lv_MINIMUM_CAPACITY		NUMBER;  /* ds change change end */
    lv_ACTUAL_START_DATE        DATE;    /* Discrete Mfg Enahancements Bug 4479276 */
    lv_END_DATE       DATE;
    lv_SUPPLY_TYPE    NUMBER;
    lv_STD_OP_CODE    VARCHAR2(4);
    lv_DELETED_FLAG   NUMBER;
    lv_minimum_transfer_quantity   NUMBER;
    lv_firm_flag   NUMBER;
    lv_schedule_flag   NUMBER;
    lv_SR_INSTANCE_ID NUMBER;
    lv_PARENT_SEQ_NUM     NUMBER;
    lv_SETUP_ID           NUMBER;
    lv_ACTIVITY_GROUP_ID  NUMBER;
    lv_ALTERNATE_NUMBER      NUMBER;
    lv_PRINCIPAL_FLAG     NUMBER;
    lv_ORIG_RESOURCE_SEQ_NUM  NUMBER;
    lv_UNADJUSTED_RESOURCE_HOURS NUMBER;
    lv_TOUCH_TIME NUMBER;
    lv_ACTIVITY_NAME VARCHAR2(20);
    lv_OPERATION_NAME VARCHAR2(20);
    lv_OPERATION_STATUS NUMBER;
    lv_legacy_refresh   NUMBER; /*bug 3768813 */

  lv_errbuf			VARCHAR2(240);
  lv_retcode			NUMBER;
  lv_sql_ins  			VARCHAR2(6000);
  lb_refresh_failed 		BOOLEAN:= FALSE;

BEGIN

-- link supply_id to MSC_supplies.transaction_id


IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) THEN
  COMMIT;
END IF;

c_count:= 0;

-- ========= Prepare the Cursor Statement ==========
IF MSC_CL_COLLECTION.v_exchange_mode=MSC_UTIL.SYS_YES THEN
   lv_tbl:= 'RESOURCE_REQUIREMENTS_'||MSC_CL_COLLECTION.v_instance_code;
   lv_supplies_tbl:= 'SUPPLIES_'||MSC_CL_COLLECTION.v_instance_code;
ELSE
   lv_tbl:= 'MSC_RESOURCE_REQUIREMENTS';
   lv_supplies_tbl:= 'MSC_SUPPLIES';
END IF;

   /** PREPLACE CHANGE START **/

   -- For Load_RES_REQ Supplies are also loaded - WIP Parameter
   -- simultaneously hence no special logic is needed
   -- for determining which SUPPLY table to be used for reference.

   /**  PREPLACE CHANGE END  **/

lv_cursor_stmt:=
'SELECT'
||'    msrr.DEPARTMENT_ID,'
||'    msrr.RESOURCE_ID,'
||'    NVL(miil.INVENTORY_ITEM_ID, ms.inventory_item_id),'   -- change for CMRO
||'    msrr.ORGANIZATION_ID,'
||'    NVL(ms.TRANSACTION_ID,-1)   SUPPLY_ID,'
||'    msrr.WIP_ENTITY_ID,'
||'    msrr.ROUTING_SEQUENCE_ID,'
||'    msrr.OPERATION_SEQ_NUM,'
||'    msrr.OPERATION_SEQUENCE_ID,'
||'    msrr.RESOURCE_SEQ_NUM,'
||'    msrr.START_DATE,'
||'    msrr.OPERATION_HOURS_REQUIRED,'
||'    msrr.HOURS_EXPENDED,'
||'    msrr.QUANTITY_IN_QUEUE,'
||'    msrr.QUANTITY_RUNNING,'
||'    msrr.QUANTITY_WAITING_TO_MOVE,'
||'    msrr.QUANTITY_COMPLETED,'
||'    msrr.YIELD,'
||'    msrr.USAGE_RATE,'
||'    msrr.BASIS_TYPE,'
||'    msrr.ASSIGNED_UNITS,'
||'    msrr.END_DATE,'
||'    msrr.SUPPLY_TYPE,'
||'    msrr.STD_OP_CODE,'
||'    msrr.DELETED_FLAG,'
||'    msrr.MINIMUM_TRANSFER_QUANTITY,'
||'    msrr.FIRM_FLAG,'
||'    msrr.SCHEDULE_FLAG,'
||'    msrr.PARENT_SEQ_NUM,'
||'    msrr.SETUP_ID,'
||'    msrr.ACTIVITY_GROUP_ID,'
||'    msrr.ALTERNATE_NUMBER,'
||'    msrr.PRINCIPAL_FLAG,'
||'    msrr.SR_INSTANCE_ID,'
||'    msrr.ORIG_RESOURCE_SEQ_NUM, '
||'    msrr.GROUP_SEQUENCE_ID, '	/*ds change change start */
||'    msrr.GROUP_SEQUENCE_NUMBER, '
||'    msrr.BATCH_NUMBER, '
||'    msrr.MAXIMUM_ASSIGNED_UNITS, '
||'    msrr.MAXIMUM_CAPACITY, '
||'    msrr.BREAKABLE_ACTIVITY_FLAG, '
||'    msrr.STEP_QUANTITY, '
||'    msrr.STEP_QUANTITY_UOM, '
||'    msrr.MINIMUM_CAPACITY, '	  /*ds change change end */
||'    msrr.OPERATION_STATUS, '
||'    msrr.ACTUAL_START_DATE, '    /* Discrete Mfg Enahancements Bug 4479276 */
||'    msrr.UNADJUSTED_RESOURCE_HOURS, '
||'    msrr.TOUCH_TIME, '
||'    msrr.ACTIVITY_NAME, '
||'    msrr.OPERATION_NAME '
||' FROM '||lv_supplies_tbl||' ms,'
||'      MSC_ST_RESOURCE_REQUIREMENTS msrr,'
||'      MSC_ITEM_ID_LID miil'
||' WHERE msrr.SR_INSTANCE_ID= '||MSC_CL_COLLECTION.v_instance_id
||'  AND ms.PLAN_ID= -1'
||'  AND ms.SR_INSTANCE_ID= msrr.SR_INSTANCE_ID'
||'  AND ms.DISPOSITION_ID= msrr.WIP_ENTITY_ID'
||'  AND ms.ORDER_TYPE IN ( 3, 7,70)'   /*  70 esm suply:ds change change */
||'  AND msrr.DELETED_FLAG= '||MSC_UTIL.SYS_NO
||'  AND miil.SR_INVENTORY_ITEM_ID(+)= msrr.INVENTORY_ITEM_ID'
||'  AND miil.SR_INSTANCE_ID(+)= msrr.SR_INSTANCE_ID';      --Outer join for CMRO

-- ========= Prepare SQL Statement for INSERT ==========
lv_sql_stmt:=
'insert into '||lv_tbl
||'  ( PLAN_ID,'
||'    TRANSACTION_ID,'
||'    DEPARTMENT_ID,'
||'    RESOURCE_ID,'
||'    ORGANIZATION_ID,'
||'    ASSEMBLY_ITEM_ID,'
||'    SUPPLY_ID,'
||'    WIP_ENTITY_ID,'
||'    ROUTING_SEQUENCE_ID,'
||'    SUPPLY_TYPE,'
||'    OPERATION_SEQ_NUM,'
||'    OPERATION_SEQUENCE_ID,'
||'    RESOURCE_SEQ_NUM,'
||'    START_DATE,'
||'    RESOURCE_HOURS,'
||'    HOURS_EXPENDED,'
||'    QUANTITY_IN_QUEUE,'
||'    QUANTITY_RUNNING,'
||'    QUANTITY_WAITING_TO_MOVE,'
||'    QUANTITY_COMPLETED,'
||'    YIELD,'
||'    USAGE_RATE,'
||'    BASIS_TYPE,'
||'    ASSIGNED_UNITS,'
||'    END_DATE,'
||'    STD_OP_CODE,'
||'    ACTIVITY_GROUP_ID,'
||'    ALTERNATE_NUM,'
||'    PRINCIPAL_FLAG,'
||'    SR_INSTANCE_ID,'
||'    REFRESH_NUMBER,'
||'    MINIMUM_TRANSFER_QUANTITY,'
||'    FIRM_FLAG,'
||'    SCHEDULE_FLAG,'
||'    PARENT_SEQ_NUM,'
||'    SETUP_ID,'
||'    ORIG_RESOURCE_SEQ_NUM,'
||'    GROUP_SEQUENCE_ID, '	/*ds change change start */
||'    GROUP_SEQUENCE_NUMBER, '
||'    BATCH_NUMBER, '
||'    MAXIMUM_ASSIGNED_UNITS, '
||'    MAXIMUM_CAPACITY, '
||'    BREAKABLE_ACTIVITY_FLAG, '
||'    STEP_QUANTITY, '
||'    STEP_QUANTITY_UOM, '
||'    MINIMUM_CAPACITY, '	  /*ds change change end */
||'    OPERATION_STATUS,'
||'    ACTUAL_START_DATE, '       /* Discrete Mfg Enahancements Bug 4479276 */
||'    TOTAL_RESOURCE_HOURS, '    /* Discrete Mfg Enahancements Bug 4479276 */
||'    UNADJUSTED_RESOURCE_HOURS, '
||'    TOUCH_TIME, '
||'    ACTIVITY_NAME, '
||'    OPERATION_NAME, '
||'    LAST_UPDATE_DATE,'
||'    LAST_UPDATED_BY,'
||'    CREATION_DATE,'
||'    CREATED_BY)'
||'VALUES'
||'(   -1,'
||'    MSC_RESOURCE_REQUIREMENTS_S.NEXTVAL,'
||'    :DEPARTMENT_ID,'
||'    :RESOURCE_ID,'
||'    :ORGANIZATION_ID,'
||'    :ASSEMBLY_ITEM_ID,'
||'    :SUPPLY_ID,'
||'    :WIP_ENTITY_ID,'
||'    :ROUTING_SEQUENCE_ID,'
||'    :SUPPLY_TYPE,'
||'    :OPERATION_SEQ_NUM,'
||'    :OPERATION_SEQUENCE_ID,'
||'    :RESOURCE_SEQ_NUM,'
||'    :START_DATE,'
||'    :OPERATION_HOURS_REQUIRED,'
||'    :HOURS_EXPENDED,'
||'    :QUANTITY_IN_QUEUE,'
||'    :QUANTITY_RUNNING,'
||'    :QUANTITY_WAITING_TO_MOVE,'
||'    :QUANTITY_COMPLETED,'
||'    :YIELD,'
||'    :USAGE_RATE,'
||'    :BASIS_TYPE,'
||'    :ASSIGNED_UNITS,'
||'    :END_DATE,'
||'    :STD_OP_CODE,'
||'    :ACTIVITY_GROUP_ID,'
||'    :ALTERNATE_NUMBER,'
||'    :PRINCIPAL_FLAG,'
||'    :SR_INSTANCE_ID,'
||'    :v_last_collection_id,'
||'    :MINIMUM_TRANSFER_QUANTITY,'
||'    :FIRM_FLAG,'
||'    :SCHEDULE_FLAG,'
||'    :PARENT_SEQ_NUM,'
||'    :SETUP_ID,'
||'    :ORIG_RESOURCE_SEQ_NUM,'
||'    :GROUP_SEQUENCE_ID, '	/*ds change change start */
||'    :GROUP_SEQUENCE_NUMBER, '
||'    :BATCH_NUMBER, '
||'    :MAXIMUM_ASSIGNED_UNITS, '
||'    :MAXIMUM_CAPACITY, '
||'    :BREAKABLE_ACTIVITY_FLAG, '
||'    :STEP_QUANTITY, '
||'    :STEP_QUANTITY_UOM, '
||'    :MINIMUM_CAPACITY, '	  /*ds change change end */
||'    :OPERATION_STATUS,'
||'    :ACTUAL_START_DATE, '      /* Discrete Mfg Enahancements Bug 4479276 */
||'    :TOTAL_RESOURCE_HOURS, '   /* Discrete Mfg Enahancements Bug 4479276 */
||'    :UNADJUSTED_RESOURCE_HOURS,'
||'    :TOUCH_TIME,'
||'    :ACTIVITY_NAME,'
||'    :OPERATION_NAME,'
||'    :v_current_date,'
||'    :v_current_user,'
||'    :v_current_date,'
||'    :v_current_user)';

IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) AND MSC_CL_COLLECTION.v_exchange_mode=MSC_UTIL.SYS_YES THEN
  BEGIN
  lv_sql_ins:=
  'insert into '||lv_tbl
  ||'  ( PLAN_ID,'
  ||'    TRANSACTION_ID,'
  ||'    DEPARTMENT_ID,'
  ||'    RESOURCE_ID,'
  ||'    ORGANIZATION_ID,'
  ||'    ASSEMBLY_ITEM_ID,'
  ||'    SUPPLY_ID,'
  ||'    WIP_ENTITY_ID,'
  ||'    ROUTING_SEQUENCE_ID,'
  ||'    SUPPLY_TYPE,'
  ||'    OPERATION_SEQ_NUM,'
  ||'    OPERATION_SEQUENCE_ID,'
  ||'    RESOURCE_SEQ_NUM,'
  ||'    START_DATE,'
  ||'    RESOURCE_HOURS,'
  ||'    HOURS_EXPENDED,'
  ||'    QUANTITY_IN_QUEUE,'
  ||'    QUANTITY_RUNNING,'
  ||'    QUANTITY_WAITING_TO_MOVE,'
  ||'    QUANTITY_COMPLETED,'
  ||'    YIELD,'
  ||'    USAGE_RATE,'
  ||'    BASIS_TYPE,'
  ||'    ASSIGNED_UNITS,'
  ||'    END_DATE,'
  ||'    STD_OP_CODE,'
  ||'    ACTIVITY_GROUP_ID,'
  ||'    ALTERNATE_NUM,'
  ||'    PRINCIPAL_FLAG,'
  ||'    SR_INSTANCE_ID,'
  ||'    REFRESH_NUMBER,'
  ||'    MINIMUM_TRANSFER_QUANTITY,'
  ||'    FIRM_FLAG,'
  ||'    SCHEDULE_FLAG,'
  ||'    PARENT_SEQ_NUM,'
  ||'    SETUP_ID,'
  ||'    ORIG_RESOURCE_SEQ_NUM,'
  ||'    GROUP_SEQUENCE_ID, '	/*ds change change start */
  ||'    GROUP_SEQUENCE_NUMBER, '
  ||'    BATCH_NUMBER, '
  ||'    MAXIMUM_ASSIGNED_UNITS, '
  ||'    MAXIMUM_CAPACITY, '
  ||'    BREAKABLE_ACTIVITY_FLAG, '
  ||'    STEP_QUANTITY, '
  ||'    STEP_QUANTITY_UOM, '
  ||'    MINIMUM_CAPACITY, '	  /*ds change change end */
  ||'    OPERATION_STATUS,'
  ||'    ACTUAL_START_DATE, '     /* Discrete Mfg Enahancements Bug 4479276 */
  ||'    TOTAL_RESOURCE_HOURS, '  /* Discrete Mfg Enahancements Bug 4479276 */
  ||'    UNADJUSTED_RESOURCE_HOURS, '
  ||'    TOUCH_TIME, '
  ||'    ACTIVITY_NAME, '
  ||'    OPERATION_NAME, '
  ||'    LAST_UPDATE_DATE,'
  ||'    LAST_UPDATED_BY,'
  ||'    CREATION_DATE,'
  ||'    CREATED_BY)'
  ||' SELECT'
  ||'    -1,'
  ||'    MSC_RESOURCE_REQUIREMENTS_S.NEXTVAL,'
  ||'    msrr.DEPARTMENT_ID,'
  ||'    msrr.RESOURCE_ID,'
  ||'    msrr.ORGANIZATION_ID,'
  ||'    NVL(miil.INVENTORY_ITEM_ID,ms.inventory_item_id),'
  ||'    NVL(ms.TRANSACTION_ID,-1),'
  ||'    msrr.WIP_ENTITY_ID,'
  ||'    msrr.ROUTING_SEQUENCE_ID,'
  ||'    msrr.SUPPLY_TYPE,'
  ||'    msrr.OPERATION_SEQ_NUM,'
  ||'    msrr.OPERATION_SEQUENCE_ID,'
  ||'    msrr.RESOURCE_SEQ_NUM,'
  ||'    msrr.START_DATE,'
  ||'    greatest((msrr.OPERATION_HOURS_REQUIRED - NVL(msrr.HOURS_EXPENDED,0)),0),'
  ||'    msrr.HOURS_EXPENDED,'
  ||'    msrr.QUANTITY_IN_QUEUE,'
  ||'    msrr.QUANTITY_RUNNING,'
  ||'    msrr.QUANTITY_WAITING_TO_MOVE,'
  ||'    msrr.QUANTITY_COMPLETED,'
  ||'    msrr.YIELD,'
  ||'    msrr.USAGE_RATE,'
  ||'    msrr.BASIS_TYPE,'
  ||'    msrr.ASSIGNED_UNITS,'
  ||'    msrr.END_DATE,'
  ||'    msrr.STD_OP_CODE,'
  ||'    msrr.ACTIVITY_GROUP_ID,'
  ||'    msrr.ALTERNATE_NUMBER,'
  ||'    msrr.PRINCIPAL_FLAG,'
  ||'    msrr.SR_INSTANCE_ID,'
  ||'    :v_last_collection_id,'
  ||'    msrr.MINIMUM_TRANSFER_QUANTITY,'
  ||'    msrr.FIRM_FLAG,'
  ||'    msrr.SCHEDULE_FLAG,'
  ||'    msrr.PARENT_SEQ_NUM,'
  ||'    msrr.SETUP_ID,'
  ||'    msrr.ORIG_RESOURCE_SEQ_NUM,'
  ||'    msrr.GROUP_SEQUENCE_ID, '      /*ds change change start */
  ||'    msrr.GROUP_SEQUENCE_NUMBER, '
  ||'    msrr.BATCH_NUMBER, '
  ||'    msrr.MAXIMUM_ASSIGNED_UNITS, '
  ||'    msrr.MAXIMUM_CAPACITY, '
  ||'    msrr.BREAKABLE_ACTIVITY_FLAG, '
  ||'    msrr.STEP_QUANTITY, '
  ||'    msrr.STEP_QUANTITY_UOM, '
  ||'    msrr.MINIMUM_CAPACITY, '	      /*ds change change end */
  ||'    msrr.OPERATION_STATUS, '
  ||'    msrr.ACTUAL_START_DATE, '      /* Discrete Mfg Enahancements Bug 4479276 */
  ||'    msrr.OPERATION_HOURS_REQUIRED, '   /* Discrete Mfg Enahancements Bug 4479276 */
  ||'    msrr.UNADJUSTED_RESOURCE_HOURS, '
  ||'    msrr.TOUCH_TIME, '
  ||'    msrr.ACTIVITY_NAME, '
  ||'    msrr.OPERATION_NAME, '
  ||'    :v_current_date, '
  ||'    :v_current_user, '
  ||'    :v_current_date, '
  ||'    :v_current_user '
  ||' FROM '||lv_supplies_tbl||' ms, '
  ||'      MSC_ST_RESOURCE_REQUIREMENTS msrr, '
  ||'      MSC_ITEM_ID_LID miil '
  ||' WHERE msrr.SR_INSTANCE_ID= '||MSC_CL_COLLECTION.v_instance_id
  ||'  AND ms.PLAN_ID= -1'
  ||'  AND ms.SR_INSTANCE_ID= msrr.SR_INSTANCE_ID'
  ||'  AND ms.DISPOSITION_ID= msrr.WIP_ENTITY_ID'
  ||'  AND ms.ORDER_TYPE IN ( 3, 7,70)'   /*  70 esm suply:ds change change */
  ||'  AND msrr.DELETED_FLAG= '||MSC_UTIL.SYS_NO
  ||'  AND miil.SR_INVENTORY_ITEM_ID(+)= msrr.INVENTORY_ITEM_ID'
  ||'  AND miil.SR_INSTANCE_ID(+)= msrr.SR_INSTANCE_ID';

  EXECUTE IMMEDIATE lv_sql_ins
  USING   MSC_CL_COLLECTION.v_last_collection_id,MSC_CL_COLLECTION.v_current_date,MSC_CL_COLLECTION.v_current_user,MSC_CL_COLLECTION.v_current_date,MSC_CL_COLLECTION.v_current_user;

  COMMIT;
  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'res req loaded');

  EXCEPTION
     WHEN OTHERS THEN
      IF SQLCODE IN (-01653,-01650,-01562,-01683) THEN

        MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
        FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
        FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_RES_REQ');
        FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_RESOURCE_REQUIREMENTS');
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

        MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
        RAISE;

      ELSE
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
        FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
        FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_RES_REQ');
        FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_RESOURCE_REQUIREMENTS');
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

        MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);

        --If Direct path load results in warning then the processing has to be
        --switched back to row by row processing. This will help to identify the
        --erroneous record and will also help in processing the rest of the records.
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'bulk insert failed - res req');
        lb_refresh_failed := TRUE;
      END IF;
  END;

END IF;   -- MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh


IF MSC_CL_COLLECTION.v_is_incremental_refresh OR lb_refresh_failed THEN

  IF MSC_CL_COLLECTION.v_is_incremental_refresh THEN

    FOR c_rec IN c4_d LOOP

   -- BUG 7521174
   -- Delete the past resource requirements as it is not required
   -- by GOP based on ODS data.

DELETE FROM   MSC_RESOURCE_REQUIREMENTS
 WHERE PLAN_ID=   -1
   AND SR_INSTANCE_ID= c_rec.SR_INSTANCE_ID
   AND WIP_ENTITY_ID= c_rec.WIP_ENTITY_ID
   AND OPERATION_SEQ_NUM= NVL( c_rec.OPERATION_SEQ_NUM, OPERATION_SEQ_NUM)
   AND ORIG_RESOURCE_SEQ_NUM= NVL(c_rec.ORIG_RESOURCE_SEQ_NUM, ORIG_RESOURCE_SEQ_NUM);

/*
     UPDATE MSC_RESOURCE_REQUIREMENTS
       SET RESOURCE_HOURS= 0,
           REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
           LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
           LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
     WHERE PLAN_ID=   -1
       AND SR_INSTANCE_ID= c_rec.SR_INSTANCE_ID
       AND WIP_ENTITY_ID= c_rec.WIP_ENTITY_ID
       AND OPERATION_SEQ_NUM= NVL( c_rec.OPERATION_SEQ_NUM, OPERATION_SEQ_NUM)
       AND ORIG_RESOURCE_SEQ_NUM= NVL(c_rec.ORIG_RESOURCE_SEQ_NUM, ORIG_RESOURCE_SEQ_NUM);
    */
    END LOOP;

  END IF; -- MSC_CL_COLLECTION.v_is_incremental_refresh

OPEN c4 FOR lv_cursor_stmt;

LOOP

FETCH c4 INTO
    lv_DEPARTMENT_ID,
    lv_RESOURCE_ID,
    lv_ASSEMBLY_ITEM_ID,
    lv_ORGANIZATION_ID,
    lv_SUPPLY_ID,
    lv_WIP_ENTITY_ID,
    lv_ROUTING_SEQUENCE_ID,
    lv_OPERATION_SEQ_NUM,
    lv_OPERATION_SEQUENCE_ID,
    lv_RESOURCE_SEQ_NUM,
    lv_START_DATE,
    lv_OPERATION_HOURS_REQUIRED,
    lv_HOURS_EXPENDED,
    lv_QUANTITY_IN_QUEUE,
    lv_QUANTITY_RUNNING,
    lv_QUANTITY_WAITING_TO_MOVE,
    lv_QUANTITY_COMPLETED,
    lv_YIELD,
    lv_USAGE_RATE,
    lv_BASIS_TYPE,
    lv_ASSIGNED_UNITS,
    lv_END_DATE,
    lv_SUPPLY_TYPE,
    lv_STD_OP_CODE,
    lv_DELETED_FLAG,
    lv_minimum_transfer_quantity,
    lv_firm_flag,
    lv_schedule_flag,
    lv_PARENT_SEQ_NUM,
    lv_SETUP_ID,
    lv_ACTIVITY_GROUP_ID,
    lv_ALTERNATE_NUMBER,
    lv_PRINCIPAL_FLAG,
    lv_SR_INSTANCE_ID,
    lv_ORIG_RESOURCE_SEQ_NUM,
    lv_GROUP_SEQUENCE_ID,           /* ds change change start */
    lv_GROUP_SEQUENCE_NUMBER,
    lv_BATCH_NUMBER,
    lv_MAXIMUM_ASSIGNED_UNITS,
    lv_MAXIMUM_CAPACITY,
    lv_BREAKABLE_ACTIVITY_FLAG,
    lv_STEP_QUANTITY,
    lv_STEP_QUANTITY_UOM,
    lv_MINIMUM_CAPACITY,	/* ds change change end */
    lv_OPERATION_STATUS,
    lv_ACTUAL_START_DATE,       /* Discrete Mfg Enahancements Bug 4479276 */
    lv_UNADJUSTED_RESOURCE_HOURS,
    lv_TOUCH_TIME,
    lv_ACTIVITY_NAME,
    lv_OPERATION_NAME;

EXIT WHEN c4%NOTFOUND;

BEGIN

IF MSC_CL_COLLECTION.v_is_legacy_refresh = TRUE THEN /* bug 3768813 */
  lv_legacy_refresh := 1;
ELSE
  lv_legacy_refresh := 2;
END IF;

IF MSC_CL_COLLECTION.v_is_incremental_refresh THEN

UPDATE MSC_RESOURCE_REQUIREMENTS
SET
   DEPARTMENT_ID=   lv_DEPARTMENT_ID,
   RESOURCE_ID=   lv_RESOURCE_ID,
   ASSEMBLY_ITEM_ID = lv_ASSEMBLY_ITEM_ID,
   ROUTING_SEQUENCE_ID = lv_ROUTING_SEQUENCE_ID,
   OPERATION_SEQUENCE_ID=   lv_OPERATION_SEQUENCE_ID,
   START_DATE=   lv_START_DATE,
   RESOURCE_HOURS=   greatest((lv_OPERATION_HOURS_REQUIRED - nvl(lv_HOURS_EXPENDED,0)),0),
   HOURS_EXPENDED= lv_HOURS_EXPENDED,
   QUANTITY_IN_QUEUE= lv_QUANTITY_IN_QUEUE,
   QUANTITY_RUNNING= lv_QUANTITY_RUNNING,
   QUANTITY_WAITING_TO_MOVE= lv_QUANTITY_WAITING_TO_MOVE,
   QUANTITY_COMPLETED= lv_QUANTITY_COMPLETED,
   YIELD= lv_YIELD,
   USAGE_RATE= lv_USAGE_RATE,
   BASIS_TYPE=   lv_BASIS_TYPE,
   ASSIGNED_UNITS=   lv_ASSIGNED_UNITS,
   END_DATE=   lv_END_DATE,
   SUPPLY_ID= lv_SUPPLY_ID,
   STD_OP_CODE= lv_STD_OP_CODE,
   REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
   minimum_transfer_quantity= lv_minimum_transfer_quantity,
   firm_flag = lv_firm_flag,
   SCHEDULE_FLAG = lv_schedule_flag,
   PARENT_SEQ_NUM=lv_PARENT_SEQ_NUM,
   SETUP_ID=lv_SETUP_ID,
   ACTIVITY_GROUP_ID=lv_ACTIVITY_GROUP_ID,
   ALTERNATE_NUM = lv_ALTERNATE_NUMBER,
   PRINCIPAL_FLAG = lv_PRINCIPAL_FLAG,
   RESOURCE_SEQ_NUM = lv_RESOURCE_SEQ_NUM,
   GROUP_SEQUENCE_ID      = lv_GROUP_SEQUENCE_ID,           /* ds change change start */
   GROUP_SEQUENCE_NUMBER  = lv_GROUP_SEQUENCE_NUMBER,
   BATCH_NUMBER  	  = lv_BATCH_NUMBER,
   MAXIMUM_ASSIGNED_UNITS = lv_MAXIMUM_ASSIGNED_UNITS,
   MAXIMUM_CAPACITY       = lv_MAXIMUM_CAPACITY,
   BREAKABLE_ACTIVITY_FLAG       = lv_BREAKABLE_ACTIVITY_FLAG,
   STEP_QUANTITY       = lv_STEP_QUANTITY,
   STEP_QUANTITY_UOM       = lv_STEP_QUANTITY_UOM,
   MINIMUM_CAPACITY       = lv_MINIMUM_CAPACITY,	  /* ds change change end */
   OPERATION_STATUS       = lv_OPERATION_STATUS,
   ACTUAL_START_DATE      = lv_ACTUAL_START_DATE,         /* Discrete Mfg Enahancements Bug 4479276 */
   TOTAL_RESOURCE_HOURS   = lv_OPERATION_HOURS_REQUIRED,  /* Discrete Mfg Enahancements Bug 4479276 */
   UNADJUSTED_RESOURCE_HOURS = lv_UNADJUSTED_RESOURCE_HOURS,
   TOUCH_TIME = lv_TOUCH_TIME,
   ACTIVITY_NAME=lv_ACTIVITY_NAME,
   OPERATION_NAME=lv_OPERATION_NAME,
   LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
   LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
WHERE PLAN_ID=   -1
  AND SR_INSTANCE_ID=   lv_SR_INSTANCE_ID
  AND NVL(ORIG_RESOURCE_SEQ_NUM, RESOURCE_SEQ_NUM) =   NVL(lv_ORIG_RESOURCE_SEQ_NUM, lv_RESOURCE_SEQ_NUM)
  AND ORGANIZATION_ID=   lv_ORGANIZATION_ID
  AND WIP_ENTITY_ID=   lv_WIP_ENTITY_ID
  AND OPERATION_SEQ_NUM=   lv_OPERATION_SEQ_NUM
  AND decode(lv_legacy_refresh,1,resource_id,-1) = decode(lv_legacy_refresh,1,lv_RESOURCE_ID, -1); /* bug 3768813 */

END IF;

IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) OR SQL%NOTFOUND THEN

EXECUTE IMMEDIATE lv_sql_stmt
USING
    lv_DEPARTMENT_ID,
    lv_RESOURCE_ID,
    lv_ORGANIZATION_ID,
    lv_ASSEMBLY_ITEM_ID,
    lv_SUPPLY_ID,
    lv_WIP_ENTITY_ID,
    lv_ROUTING_SEQUENCE_ID,
    lv_SUPPLY_TYPE,
    lv_OPERATION_SEQ_NUM,
    lv_OPERATION_SEQUENCE_ID,
    lv_RESOURCE_SEQ_NUM,
    lv_START_DATE,
    greatest((lv_OPERATION_HOURS_REQUIRED - NVL(lv_HOURS_EXPENDED,0)),0),
    lv_HOURS_EXPENDED,
    lv_QUANTITY_IN_QUEUE,
    lv_QUANTITY_RUNNING,
    lv_QUANTITY_WAITING_TO_MOVE,
    lv_QUANTITY_COMPLETED,
    lv_YIELD,
    lv_USAGE_RATE,
    lv_BASIS_TYPE,
    lv_ASSIGNED_UNITS,
    lv_END_DATE,
    lv_STD_OP_CODE,
    lv_ACTIVITY_GROUP_ID,
    lv_ALTERNATE_NUMBER,
    lv_PRINCIPAL_FLAG,
    lv_SR_INSTANCE_ID,
    MSC_CL_COLLECTION.v_last_collection_id,
    lv_minimum_transfer_quantity,
    lv_firm_flag,
    lv_schedule_flag,
    lv_PARENT_SEQ_NUM,
    lv_SETUP_ID,
    lv_ORIG_RESOURCE_SEQ_NUM,
    lv_GROUP_SEQUENCE_ID,           /* ds change change start */
    lv_GROUP_SEQUENCE_NUMBER,
    lv_BATCH_NUMBER,
    lv_MAXIMUM_ASSIGNED_UNITS,
    lv_MAXIMUM_CAPACITY,
    lv_BREAKABLE_ACTIVITY_FLAG,
    lv_STEP_QUANTITY,
    lv_STEP_QUANTITY_UOM,
    lv_MINIMUM_CAPACITY,	  /* ds change change end */
    lv_OPERATION_STATUS,
    lv_ACTUAL_START_DATE,         /* Discrete Mfg Enahancements Bug 4479276 */
    lv_OPERATION_HOURS_REQUIRED,  /* Discrete Mfg Enahancements Bug 4479276 */
    lv_UNADJUSTED_RESOURCE_HOURS,
    lv_TOUCH_TIME,
    lv_ACTIVITY_NAME,
    lv_OPERATION_NAME,
    MSC_CL_COLLECTION.v_current_date,
    MSC_CL_COLLECTION.v_current_user,
    MSC_CL_COLLECTION.v_current_date,
    MSC_CL_COLLECTION.v_current_user;

END IF;

  c_count:= c_count+1;

  IF c_count> MSC_CL_COLLECTION.PBS THEN
     IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) THEN COMMIT; END IF;
     c_count:= 0;
  END IF;

EXCEPTION
   WHEN OTHERS THEN

    IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_SUPPLY');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_RESOURCE_REQUIREMENTS');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RAISE;

    ELSE

      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_SUPPLY');
      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_RESOURCE_REQUIREMENTS');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'ORGANIZATION_CODE');
      FND_MESSAGE.SET_TOKEN('VALUE',
                            MSC_GET_NAME.ORG_CODE( lv_ORGANIZATION_ID,
                                                   MSC_CL_COLLECTION.v_instance_id));
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'DEPARTMENT_ID');
      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(lv_DEPARTMENT_ID));
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'RESOURCE_ID');
      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(lv_RESOURCE_ID));
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
    END IF;

END;

END LOOP;

END IF; -- MSC_CL_COLLECTION.v_is_incremental_refresh OR lb_refresh_failed

IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) THEN
    COMMIT;
END IF;

BEGIN

IF ((MSC_CL_COLLECTION.v_coll_prec.org_group_flag <> MSC_UTIL.G_ALL_ORGANIZATIONS ) AND (MSC_CL_COLLECTION.v_exchange_mode=MSC_UTIL.SYS_YES)) THEN

lv_tbl:= 'RESOURCE_REQUIREMENTS_'||MSC_CL_COLLECTION.v_instance_code;

lv_sql_stmt:=
         'INSERT INTO '||lv_tbl
          ||' SELECT * from MSC_RESOURCE_REQUIREMENTS'
          ||' WHERE sr_instance_id = '||MSC_CL_COLLECTION.v_instance_id
          ||' AND plan_id = -1 '
          ||' AND organization_id not '||MSC_UTIL.v_in_org_str;

   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'The sql statement is '||lv_sql_stmt);
   EXECUTE IMMEDIATE lv_sql_stmt;

   COMMIT;

END IF;

EXCEPTION
  WHEN OTHERS THEN

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
      RAISE;
END;

 MSC_CL_BOM_ODS_LOAD.LOAD_RESOURCE_CHARGES;   /* ds change */

IF MSC_CL_COLLECTION.v_exchange_mode=MSC_UTIL.SYS_YES THEN
   MSC_CL_COLLECTION.alter_temp_table (lv_errbuf,
   	              lv_retcode,
                      'MSC_RESOURCE_REQUIREMENTS',
                      MSC_CL_COLLECTION.v_instance_code,
                      MSC_UTIL.G_WARNING
                     );

   IF lv_retcode = MSC_UTIL.G_ERROR THEN
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, lv_errbuf);
      RAISE MSC_CL_COLLECTION.ALTER_TEMP_TABLE_ERROR;
   ELSIF lv_retcode = MSC_UTIL.G_WARNING THEN
      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;
   END IF;

END IF;

EXCEPTION
   WHEN OTHERS THEN
      IF c4%ISOPEN THEN CLOSE c4; END IF;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '<<LOAD_RES_REQ>>');
      IF lv_cursor_stmt IS NOT NULL THEN
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '<<CURSOR>>'||lv_cursor_stmt);
      END IF;
      IF lv_sql_stmt IS NOT NULL THEN
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '<<SQL>>'||lv_sql_stmt);
      END IF;
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  SQLERRM);
      RAISE;
END LOAD_RES_REQ;

--=============================================================================

END MSC_CL_WIP_ODS_LOAD;

/
