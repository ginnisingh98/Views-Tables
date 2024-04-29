--------------------------------------------------------
--  DDL for Package Body MSC_CL_RPO_ODS_LOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_CL_RPO_ODS_LOAD" AS -- specification
/* $Header: MSCLRPOB.pls 120.12.12010000.3 2010/04/15 09:27:04 vsiyer ship $ */

   v_sql_stmt                    VARCHAR2(4000);
   lv_sql_stmt1                  VARCHAR2(4000);
   v_sub_str                     VARCHAR2(4000);
--   v_warning_flag                NUMBER:= MSC_UTIL.SYS_NO;  --2 be changed
--   v_is_cont_refresh             BOOLEAN;   -- 2 be changed
--   v_chr9                        VARCHAR2(1) := FND_GLOBAL.LOCAL_CHR(9);
--   v_chr10                       VARCHAR2(1) := FND_GLOBAL.LOCAL_CHR(10);
--   v_chr13                       VARCHAR2(1) := FND_GLOBAL.LOCAL_CHR(13);


-- PROCEDURE LOAD_IRO_DEMAND;   -- Changes for Bug 5909379 Srp Additions
-- PROCEDURE LOAD_ERO_DEMAND;   -- Changes for Bug 5935273 Srp Additions


 PROCEDURE LOAD_IRO_DEMAND IS

   TYPE CurTyp IS REF CURSOR; -- define weak REF CURSOR type
   c2              CurTyp;
   c10_d           CurTyp;
   c11_d           CurTyp;

   lv_sql_stmt     VARCHAR2(10240);
   lv_del_stmt2    VARCHAR2(10240);
   lv_del_stmt     VARCHAR2(10240);
   lv_cursor_stmt  VARCHAR2(10240);
   lv_insert_stmt  VARCHAR2(10240);
   c_count         NUMBER:=0;
   lv_tbl          VARCHAR2(30);
   lv_supplies_tbl VARCHAR2(30);
   lv_ITEM_TYPE_VALUE            NUMBER;
   lv_ITEM_TYPE_ID               NUMBER;
  -- lv_SR_INSTANCE_ID             NUMBER;
   lv_PLAN_ID                     NUMBER;
   lv_DEMAND_ID                   NUMBER;
   lv_DISPOSITION_ID              NUMBER;
   lv_INVENTORY_ITEM_ID           NUMBER;
   lv_ORGANIZATION_ID             NUMBER;
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
   lv_SR_INSTANCE_ID          NUMBER;
   lv_PROJECT_ID              NUMBER;
   lv_TASK_ID                 NUMBER;
   lv_PLANNING_GROUP          VARCHAR2(30);
   lv_END_ITEM_UNIT_NUMBER    VARCHAR2(30);
   lv_ORDER_NUMBER            VARCHAR2(240);
   lv_WIP_ENTITY_ID           NUMBER;
   lv_WIP_ENTITY_NAME         VARCHAR2(240);
   lv_WIP_STATUS_CODE         NUMBER;
   lv_WIP_SUPPLY_TYPE         NUMBER;
   lv_ASSET_ITEM_ID	          NUMBER;
   lv_ASSET_SERIAL_NUMBER     VARCHAR2(30);
   lv_COMPONENT_SCALING_TYPE  NUMBER;
   lv_COMPONENT_YIELD_FACTOR  NUMBER;
   lv_dummy1                  NUMBER;
   lv_dummy2                  NUMBER;
   lv_last_collection_id      NUMBER;
   lv_dummy_date              DATE;
   lv_dummy_user              NUMBER;
   lv_dummy3                  NUMBER;
   lv_REPAIR_LINE_ID          NUMBER;
   lv_sel_sql_stmt            VARCHAR2(1000);
   lv_data_sql_stmt           VARCHAR2(1000);

BEGIN
  NULL;
  c_count:=0;
-- ========= Prepare the Cursor Statement ==========
IF MSC_CL_COLLECTION.v_exchange_mode=MSC_UTIL.SYS_YES THEN
   lv_tbl:= 'DEMANDS_'||MSC_CL_COLLECTION.v_instance_code;
   lv_supplies_tbl:= 'SUPPLIES_'||MSC_CL_COLLECTION.v_instance_code;
ELSE
   lv_tbl:= 'MSC_DEMANDS';
   lv_supplies_tbl:= 'MSC_SUPPLIES';
END IF;

IF MSC_UTIL.G_COLLECT_SRP_DATA = 'Y' THEN
  IF MSC_CL_COLLECTION.v_is_legacy_refresh THEN
     lv_ITEM_TYPE_ID     := MSC_UTIL.G_PARTCONDN_ITEMTYPEID;
     lv_sel_sql_stmt     := 'ITEM_TYPE_ID,';
     lv_data_sql_stmt    := lv_ITEM_TYPE_ID||',';
  ELSE
     lv_ITEM_TYPE_ID     := MSC_UTIL.G_PARTCONDN_ITEMTYPEID;
     lv_ITEM_TYPE_VALUE  := MSC_UTIL.G_PARTCONDN_GOOD;
     lv_sel_sql_stmt     := 'ITEM_TYPE_ID,ITEM_TYPE_VALUE,';
     lv_data_sql_stmt    := lv_ITEM_TYPE_ID||','||lv_ITEM_TYPE_VALUE||',';
  END IF;
ELSE
     lv_ITEM_TYPE_ID     := NULL;
     lv_ITEM_TYPE_VALUE  := NULL;
     lv_sel_sql_stmt     := 'null,null,';
     lv_data_sql_stmt    := 'null,null,';
END IF;

   /** PREPLACE CHANGE START **/

   -- For Load_WIP_DEMAND Supplies are also loaded - WIP Parameter
   -- simultaneously hence no special logic is needed
   -- for determining which SUPPLY table to be used for pegging.

   /**  PREPLACE CHANGE END  **/
  /* 2201791 - select substr(order_number,1,62) since order_number is
   defined as varchar(62) in msc_demands table */

lv_del_stmt :=
              'Select  mshr.repair_line_id,
          	           T1.Inventory_item_id ,
          	           mshr.Organization_id ,
          	           mshr.Origination_type ,
                       mshr.SR_INSTANCE_ID
	            From     MSC_ST_DEMANDS mshr ,
                       msc_item_id_lid  t1
	              Where  mshr.sr_instance_id = '||MSC_CL_COLLECTION.v_instance_id
	                     ||' And  mshr.ro_status_code=''C''
	                     And  mshr.origination_type= 77
                       AND t1.SR_INVENTORY_ITEM_ID(+)= mshr.inventory_item_id
                       AND t1.sr_instance_id(+)= mshr.sr_instance_id ';

 if   MSC_CL_COLLECTION.v_is_legacy_refresh then
      lv_del_stmt := lv_del_stmt || ' And mshr.ENTITY=''IRO''' ;
 else
       lv_del_stmt :=  lv_del_stmt || ' And mshr.organization_id  '||MSC_UTIL.v_depot_org_str;
 end if ;

lv_del_stmt2 := 'SELECT
                   mshr.REPAIR_LINE_ID,
                   mshr.SR_INSTANCE_ID,
                   t1.INVENTORY_ITEM_ID,
                   mshr.ORGANIZATION_ID,
                   mshr.OPERATION_SEQ_NUM,
                   mshr.ORIGINATION_TYPE,
                   mshr.WIP_ENTITY_ID,
                   mshr.wip_entity_name
             FROM MSC_ST_DEMANDS mshr,
                  msc_item_id_lid  t1
            WHERE mshr.SR_INSTANCE_ID= '||MSC_CL_COLLECTION.v_instance_id
            ||' AND mshr.DELETED_FLAG= '||MSC_UTIL.SYS_YES
            ||' AND mshr.ORIGINATION_TYPE=77
                AND t1.SR_INVENTORY_ITEM_ID(+)= mshr.inventory_item_id
                AND t1.sr_instance_id(+)= mshr.sr_instance_id ';


if   MSC_CL_COLLECTION.v_is_legacy_refresh then
      lv_del_stmt2 := lv_del_stmt2 || ' And mshr.ENTITY=''IRO''' ;
 else
       lv_del_stmt2 := lv_del_stmt2 || 'And mshr.organization_id  '||MSC_UTIL.v_depot_org_str;
 end if ;

lv_cursor_stmt:=
'SELECT'
||'   -1, MSC_DEMANDS_S.nextval, '
||'   NVL(ms.TRANSACTION_ID,-1) DISPOSITION_ID,'
||'   t1.INVENTORY_ITEM_ID,'
||'   msd.ORGANIZATION_ID,'
||'   t2.INVENTORY_ITEM_ID USING_ASSEMBLY_ITEM_ID,'
||'   nvl(msd.USING_ASSEMBLY_DEMAND_DATE,ms.new_schedule_date),'
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
||'   REPAIR_LINE_ID ,'
||'   msd.WIP_ENTITY_ID,'
||'   msd.WIP_ENTITY_NAME,'
||'   msd.WIP_STATUS_CODE,'
||'   msd.WIP_SUPPLY_TYPE,'
||'   t3.inventory_item_id  ASSET_ITEM_ID,'   /* ds change change*/
||'   msd.ASSET_SERIAL_NUMBER,'  /* ds change change*/
||'   msd.COMPONENT_SCALING_TYPE,' /* Discrete Mfg Enahancements Bug 4492736 */
||'   msd.COMPONENT_YIELD_FACTOR,' /* Discrete Mfg Enahancements Bug 4479743 */
||    lv_data_sql_stmt
||'   msd.ITEM_TYPE_VALUE,'
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
||'  AND msd.ORIGINATION_TYPE = 77'   /* 50 eam demand: ds change change SRP Change 5909379*/
||'  AND msd.DELETED_FLAG= '||MSC_UTIL.SYS_NO
||'  AND t1.SR_INVENTORY_ITEM_ID= msd.inventory_item_id'
||'  AND t1.sr_instance_id= msd.SR_INSTANCE_ID'
||'  AND t2.SR_INVENTORY_ITEM_ID= msd.using_assembly_item_id'
||'  AND t2.sr_instance_id= msd.SR_INSTANCE_ID'
||'  AND t3.SR_INVENTORY_ITEM_ID (+)= msd.ASSET_ITEM_ID'
||'  AND t3.sr_instance_id (+) = msd.SR_INSTANCE_ID'
||'  AND ms.sr_instance_id= msd.SR_INSTANCE_ID'
||'  AND ms.ORGANIZATION_ID= msd.ORGANIZATION_ID'
||'  AND ms.DISPOSITION_ID= msd.repair_line_id '
||'  AND ms.plan_id=-1'
||'  AND ms.ORDER_TYPE= 75'; /* ds change change*/

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
||'   REPAIR_LINE_ID,'
||'   WIP_ENTITY_ID,'
||'   WIP_ENTITY_NAME,'
||'   WIP_STATUS_CODE,'
||'   WIP_SUPPLY_TYPE,'
||'   ASSET_ITEM_ID,'
||'   ASSET_SERIAL_NUMBER,'
||'   COMPONENT_SCALING_TYPE,'
||'   COMPONENT_YIELD_FACTOR,'
||    lv_sel_sql_stmt
||'   ITEM_TYPE_VALUE,'
||'   REFRESH_NUMBER,'
||'   LAST_UPDATE_DATE,'
||'   LAST_UPDATED_BY,'
||'   CREATION_DATE,'
||'   CREATED_BY)'
|| lv_cursor_stmt;


      IF MSC_CL_COLLECTION.v_is_incremental_refresh THEN  -- incremental Refresh



    --=================================================

      Open C10_d for lv_del_stmt;
      Loop


       FETCH C10_d INTO
           lv_REPAIR_LINE_ID     ,
           lv_INVENTORY_ITEM_ID  ,
           lv_ORGANIZATION_ID    ,
           lv_ORIGINATION_TYPE   ,
           lv_SR_INSTANCE_ID    ;



        EXIT WHEN C10_d%NOTFOUND;

       	Delete from msc_demands
      	 WHERE PLAN_ID=  -1
         	AND SR_INSTANCE_ID=    lv_SR_INSTANCE_ID
         	AND ORIGINATION_TYPE=  lv_ORIGINATION_TYPE
         	AND REPAIR_LINE_ID=    lv_REPAIR_LINE_ID
          AND ORGANIZATION_ID =  lv_ORGANIZATION_ID
         	AND INVENTORY_ITEM_ID=  NVL(lv_INVENTORY_ITEM_ID,INVENTORY_ITEM_ID);


      END LOOP;

      CLOSE C10_d;



--=======================================
     Open c11_d for lv_del_stmt2;
     LOOP



        FETCH C11_d INTO
           lv_REPAIR_LINE_ID     ,
           lv_SR_INSTANCE_ID     ,
           lv_INVENTORY_ITEM_ID  ,
           lv_ORGANIZATION_ID    ,
           lv_OPERATION_SEQ_NUM  ,
           lv_ORIGINATION_TYPE   ,
           lv_WIP_ENTITY_ID ,
           lv_WIP_ENTITY_NAME   ;


         EXIT WHEN C11_d%NOTFOUND;
       if MSC_CL_COLLECTION.v_is_legacy_refresh then
          Delete from msc_demands
      	  WHERE PLAN_ID=  -1
         	AND SR_INSTANCE_ID=    lv_SR_INSTANCE_ID
         	AND ORIGINATION_TYPE=  lv_ORIGINATION_TYPE
         	AND REPAIR_LINE_ID=    lv_REPAIR_LINE_ID
          AND OP_SEQ_NUM=        NVL(lv_OPERATION_SEQ_NUM,OP_SEQ_NUM)
          AND ORGANIZATION_ID =  lv_ORGANIZATION_ID
         	AND INVENTORY_ITEM_ID= NVL(lv_INVENTORY_ITEM_ID,INVENTORY_ITEM_ID)
          AND  WIP_ENTITY_NAME   = lv_WIP_ENTITY_NAME  ;
       else
      	 Delete from msc_demands
      	 WHERE PLAN_ID=  -1
         	AND SR_INSTANCE_ID=    lv_SR_INSTANCE_ID
         	AND ORIGINATION_TYPE=  lv_ORIGINATION_TYPE
         	AND REPAIR_LINE_ID=    lv_REPAIR_LINE_ID
          AND OP_SEQ_NUM=        NVL(lv_OPERATION_SEQ_NUM,OP_SEQ_NUM)
          AND ORGANIZATION_ID =  lv_ORGANIZATION_ID
         	AND INVENTORY_ITEM_ID= NVL(lv_INVENTORY_ITEM_ID,INVENTORY_ITEM_ID)
          AND  WIP_ENTITY_ID   = lv_WIP_ENTITY_ID  ;
       end if ;



      END LOOP;
      CLOSE C11_d;
   --=============================================

       /* Opening The cursor ... Perofrom Update ... If not found the n inser ... row operation  */


      OPEN c2 FOR lv_cursor_stmt USING MSC_CL_COLLECTION.v_chr10,
                                 MSC_CL_COLLECTION.v_chr13,
                                 MSC_CL_COLLECTION.v_last_collection_id,
                              	 MSC_CL_COLLECTION.v_current_date,
                              	 MSC_CL_COLLECTION.v_current_user,
                              	 MSC_CL_COLLECTION.v_current_date,
                              	 MSC_CL_COLLECTION.v_current_user;

      LOOP

        FETCH c2 INTO
           lv_PLAN_ID                     ,
           lv_DEMAND_ID                   ,
           lv_DISPOSITION_ID              ,
           lv_INVENTORY_ITEM_ID           ,
           lv_ORGANIZATION_ID             ,
           lv_USING_ASSEMBLY_ITEM_ID      ,
           lv_USING_ASSEMBLY_DEMAND_DATE  ,
           lv_USING_REQUIREMENT_QUANTITY  ,
           lv_QUANTITY_PER_ASSEMBLY       ,
           lv_QUANTITY_ISSUED             ,
           lv_ASSEMBLY_DEMAND_COMP_DATE   ,
           lv_DEMAND_TYPE             ,
           lv_ORIGINATION_TYPE        ,
           lv_SOURCE_ORGANIZATION_ID  ,
           lv_RESERVATION_ID          ,
           lv_OPERATION_SEQ_NUM       ,
           lv_DEMAND_CLASS            ,
           lv_REPETITIVE_SCHEDULE_ID  ,
           lv_SR_INSTANCE_ID          ,
           lv_PROJECT_ID              ,
           lv_TASK_ID                 ,
           lv_PLANNING_GROUP          ,
           lv_END_ITEM_UNIT_NUMBER    ,
           lv_ORDER_NUMBER            ,
           lv_REPAIR_LINE_ID          ,
           lv_WIP_ENTITY_ID           ,
           lv_WIP_ENTITY_NAME           ,
           lv_WIP_STATUS_CODE         ,
           lv_WIP_SUPPLY_TYPE         ,
           lv_ASSET_ITEM_ID	          ,
           lv_ASSET_SERIAL_NUMBER     ,
           lv_COMPONENT_SCALING_TYPE  ,
           lv_COMPONENT_YIELD_FACTOR  ,
           lv_dummy1                  ,
           lv_ITEM_TYPE_VALUE         ,
           lv_last_collection_id      ,
           lv_dummy_date              ,
           lv_dummy_user              ,
           lv_dummy_date              ,
           lv_dummy_user              ;


        EXIT WHEN c2%NOTFOUND;

      BEGIN
        if MSC_CL_COLLECTION.v_is_legacy_refresh then
           Update MSC_DEMANDS
            Set
              USING_ASSEMBLY_ITEM_ID     = lv_USING_ASSEMBLY_ITEM_ID      ,
              USING_ASSEMBLY_DEMAND_DATE = lv_USING_ASSEMBLY_DEMAND_DATE  ,
              USING_REQUIREMENT_QUANTITY = lv_USING_REQUIREMENT_QUANTITY  ,
              QUANTITY_PER_ASSEMBLY = lv_QUANTITY_PER_ASSEMBLY       ,
              ISSUED_QUANTITY       = lv_QUANTITY_ISSUED             ,
              ASSEMBLY_DEMAND_COMP_DATE = lv_ASSEMBLY_DEMAND_COMP_DATE   ,
              DEMAND_TYPE              = lv_DEMAND_TYPE             ,
              SOURCE_ORGANIZATION_ID   = lv_SOURCE_ORGANIZATION_ID  ,
              RESERVATION_ID           = lv_RESERVATION_ID          ,
              DEMAND_CLASS             = lv_DEMAND_CLASS            ,
              REPETITIVE_SCHEDULE_ID   = lv_REPETITIVE_SCHEDULE_ID  ,
              PROJECT_ID   = lv_PROJECT_ID              ,
              TASK_ID      = lv_TASK_ID                 ,
              PLANNING_GROUP    = lv_PLANNING_GROUP          ,
              ORDER_NUMBER      = lv_ORDER_NUMBER            ,
              WIP_STATUS_CODE   = lv_WIP_STATUS_CODE         ,
              WIP_SUPPLY_TYPE   = lv_WIP_SUPPLY_TYPE         ,
              ASSET_ITEM_ID          = lv_ASSET_ITEM_ID	          ,
              ASSET_SERIAL_NUMBER    = lv_ASSET_SERIAL_NUMBER     ,
              COMPONENT_SCALING_TYPE = lv_COMPONENT_SCALING_TYPE  ,
              COMPONENT_YIELD_FACTOR = lv_COMPONENT_YIELD_FACTOR
            WHERE PLAN_ID=  -1
               AND SR_INSTANCE_ID=    lv_SR_INSTANCE_ID
               AND ORIGINATION_TYPE=  lv_ORIGINATION_TYPE
               AND DISPOSITION_ID=    lv_DISPOSITION_ID
               AND OP_SEQ_NUM=        lv_OPERATION_SEQ_NUM
               AND ORGANIZATION_ID =  lv_ORGANIZATION_ID
               AND INVENTORY_ITEM_ID= lv_INVENTORY_ITEM_ID
            	 AND WIP_ENTITY_NAME   = lv_WIP_ENTITY_NAME
               AND ITEM_TYPE_VALUE   = lv_ITEM_TYPE_VALUE;
        ELSE
              Update MSC_DEMANDS
            Set
              USING_ASSEMBLY_ITEM_ID     = lv_USING_ASSEMBLY_ITEM_ID      ,
              USING_ASSEMBLY_DEMAND_DATE = lv_USING_ASSEMBLY_DEMAND_DATE  ,
              USING_REQUIREMENT_QUANTITY = lv_USING_REQUIREMENT_QUANTITY  ,
              QUANTITY_PER_ASSEMBLY = lv_QUANTITY_PER_ASSEMBLY       ,
              ISSUED_QUANTITY       = lv_QUANTITY_ISSUED             ,
              ASSEMBLY_DEMAND_COMP_DATE = lv_ASSEMBLY_DEMAND_COMP_DATE   ,
              DEMAND_TYPE              = lv_DEMAND_TYPE             ,
              SOURCE_ORGANIZATION_ID   = lv_SOURCE_ORGANIZATION_ID  ,
              RESERVATION_ID           = lv_RESERVATION_ID          ,
              DEMAND_CLASS             = lv_DEMAND_CLASS            ,
              REPETITIVE_SCHEDULE_ID   = lv_REPETITIVE_SCHEDULE_ID  ,
              PROJECT_ID   = lv_PROJECT_ID              ,
              TASK_ID      = lv_TASK_ID                 ,
              PLANNING_GROUP    = lv_PLANNING_GROUP          ,
              ORDER_NUMBER      = lv_ORDER_NUMBER            ,
              WIP_STATUS_CODE   = lv_WIP_STATUS_CODE         ,
              WIP_SUPPLY_TYPE   = lv_WIP_SUPPLY_TYPE         ,
              ASSET_ITEM_ID          = lv_ASSET_ITEM_ID	          ,
              ASSET_SERIAL_NUMBER    = lv_ASSET_SERIAL_NUMBER     ,
              COMPONENT_SCALING_TYPE = lv_COMPONENT_SCALING_TYPE  ,
              COMPONENT_YIELD_FACTOR = lv_COMPONENT_YIELD_FACTOR
            WHERE PLAN_ID=  -1
               AND SR_INSTANCE_ID=    lv_SR_INSTANCE_ID
               AND ORIGINATION_TYPE=  lv_ORIGINATION_TYPE
               AND DISPOSITION_ID=    lv_DISPOSITION_ID
               AND OP_SEQ_NUM=        lv_OPERATION_SEQ_NUM
               AND ORGANIZATION_ID =  lv_ORGANIZATION_ID
               AND INVENTORY_ITEM_ID= lv_INVENTORY_ITEM_ID
            	 AND  WIP_ENTITY_ID   = lv_WIP_ENTITY_ID  ;
         END IF ;
                IF SQL%NOTFOUND THEN

                       -- ========= Prepare SQL Statement for INSERT ==========
                      lv_insert_stmt:=
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
                      ||'   REPAIR_LINE_ID,'
                      ||'   WIP_ENTITY_ID,'
                      ||'   WIP_ENTITY_NAME,'
                      ||'   WIP_STATUS_CODE,'
                      ||'   WIP_SUPPLY_TYPE,'
                      ||'   REPETITIVE_SCHEDULE_ID,'
                      ||'   ASSET_ITEM_ID,'
                      ||'   ASSET_SERIAL_NUMBER,'
                      ||'   COMPONENT_SCALING_TYPE,'
                      ||'   COMPONENT_YIELD_FACTOR,'
                      ||'   ITEM_TYPE_ID,'
                      ||'   ITEM_TYPE_VALUE,'
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
                      ||'   :REPAIR_LINE_ID,'
                      ||'   :WIP_ENTITY_ID,'
                      ||'   :WIP_ENTITY_NAME,'
                      ||'   :WIP_STATUS_CODE,'
                      ||'   :WIP_SUPPLY_TYPE,'
                      ||'   :REPETITIVE_SCHEDULE_ID,'
                      ||'   :ASSET_ITEM_ID,'
                      ||'   :ASSET_SERIAL_NUMBER,'
                      ||'   :COMPONENT_SCALING_TYPE,'
                      ||'   :COMPONENT_YIELD_FACTOR,'
                      ||'   :ITEM_TYPE_ID,'
                      ||'   :ITEM_TYPE_VALUE,'
                      ||'   :v_last_collection_id,'
                      ||'   :v_current_date,'
                      ||'   :v_current_user,'
                      ||'   :v_current_date,'
                      ||'   :v_current_user )';

                      EXECUTE IMMEDIATE lv_insert_stmt
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
                           lv_REPAIR_LINE_ID,
                           lv_WIP_ENTITY_ID,
                           lv_WIP_ENTITY_NAME,
                           lv_WIP_STATUS_CODE,
                           lv_WIP_SUPPLY_TYPE,
                           lv_REPETITIVE_SCHEDULE_ID,
                           lv_ASSET_ITEM_ID,
                           lv_ASSET_SERIAL_NUMBER,
                           lv_COMPONENT_SCALING_TYPE,
                           lv_COMPONENT_YIELD_FACTOR,
                           lv_ITEM_TYPE_ID,
                           lv_ITEM_TYPE_VALUE,
                           MSC_CL_COLLECTION.v_last_collection_id,
                           MSC_CL_COLLECTION.v_current_date,
                           MSC_CL_COLLECTION.v_current_user,
                           MSC_CL_COLLECTION.v_current_date,
                           MSC_CL_COLLECTION.v_current_user;

                    END IF;
          EXCEPTION

             WHEN OTHERS THEN

              MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');

              FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
              FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_IRO_DEMAND');
              FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_DEMANDS');
              MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);
              MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
              RAISE;
      END;

    END LOOP;

   END IF; -- incremental Refresh

  IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) THEN

   BEGIN


   EXECUTE IMMEDIATE lv_sql_stmt
	 USING
	 MSC_CL_COLLECTION.v_chr10,
	 MSC_CL_COLLECTION.v_chr13,
	 MSC_CL_COLLECTION.v_last_collection_id,
	 MSC_CL_COLLECTION.v_current_date,
	 MSC_CL_COLLECTION.v_current_user,
	 MSC_CL_COLLECTION.v_current_date,
	 MSC_CL_COLLECTION.v_current_user;


   COMMIT;


   EXCEPTION
   WHEN OTHERS THEN

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '<<LOAD_IRO_DEMAND>>');
      IF lv_sql_stmt IS NOT NULL THEN
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '<<CURSOR>>'|| lv_sql_stmt);
      END IF;
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  SQLERRM);
   --   log_message ('Error Occured'||SQLERRM);


   END;
  END IF;  -- Comp Collection
END LOAD_IRO_DEMAND;

PROCEDURE LOAD_ERO_DEMAND IS
   lv_sql_stmt     VARCHAR2(10240);
   lv_cursor_stmt  VARCHAR2(10240);
   lv_del_stmt     VARCHAR2(10240);
   c_count         NUMBER:=0;
   lv_tbl          VARCHAR2(30);
   lv_supplies_tbl VARCHAR2(30);
   lv_ITEM_TYPE_VALUE            NUMBER;
   lv_ITEM_TYPE_ID               NUMBER;

   TYPE CurTyp IS REF CURSOR; -- define weak REF CURSOR type
   c2              CurTyp;
   c2_d            CurTyp;

  /* CURSOR c2_d IS
   SELECT msd.WIP_ENTITY_ID,
           msd.OPERATION_SEQ_NUM,
           t1.INVENTORY_ITEM_ID,
           msd.ORIGINATION_TYPE,
           msd.SR_INSTANCE_ID,
           msd.ORGANIZATION_ID
      FROM MSC_ITEM_ID_LID t1,
           MSC_ST_DEMANDS msd
     WHERE msd.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
       AND msd.ORIGINATION_TYPE = 77
       AND msd.DELETED_FLAG= MSC_UTIL.SYS_YES
       AND t1.SR_INVENTORY_ITEM_ID(+)= msd.inventory_item_id
       AND t1.sr_instance_id(+)= MSC_CL_COLLECTION.v_instance_id;*/

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
   lv_ASSET_ITEM_ID	      NUMBER;
   lv_ASSET_SERIAL_NUMBER     VARCHAR2(30);
   lv_SR_INSTANCE_ID          NUMBER;
   lv_PROJECT_ID              NUMBER;
   lv_TASK_ID                 NUMBER;
   lv_PLANNING_GROUP          VARCHAR2(30);
   lv_END_ITEM_UNIT_NUMBER    VARCHAR2(30);
   lv_COMPONENT_SCALING_TYPE  NUMBER;
   lv_COMPONENT_YIELD_FACTOR  NUMBER;
   lv_ORDER_NUMBER     VARCHAR2(240);
   lv_WIP_ENTITY_ID    NUMBER;
   lv_WIP_STATUS_CODE  NUMBER;
   lv_WIP_SUPPLY_TYPE  NUMBER;
   lv_DELETED_FLAG     NUMBER;
   lv_sel_sql_stmt     VARCHAR2(1000);
   lv_data_sql_stmt     VARCHAR2(1000);

BEGIN

 IF MSC_CL_COLLECTION.v_is_incremental_refresh THEN  -- incremental Refresh

 lv_del_stmt := 'SELECT msd1.WIP_ENTITY_ID,
                 msd1.OPERATION_SEQ_NUM,
                 t1.INVENTORY_ITEM_ID,
                 msd1.ORIGINATION_TYPE,
                 msd1.SR_INSTANCE_ID,
                 msd1.ORGANIZATION_ID
            FROM MSC_ITEM_ID_LID t1,
                 MSC_ST_DEMANDS msd1
           WHERE msd1.SR_INSTANCE_ID= '||MSC_CL_COLLECTION.v_instance_id
             ||' AND msd1.ORIGINATION_TYPE = 77
                 AND msd1.DELETED_FLAG= '|| MSC_UTIL.SYS_YES
             ||' AND t1.SR_INVENTORY_ITEM_ID(+)= msd1.inventory_item_id
                 AND t1.sr_instance_id(+)=  '||MSC_CL_COLLECTION.v_instance_id ;

    if   MSC_CL_COLLECTION.v_is_legacy_refresh then
     lv_del_stmt:=lv_del_stmt ||' AND msd1.ENTITY=''ERO''';
    else
     lv_del_stmt:=lv_del_stmt ||' AND msd1.ORGANIZATION_ID  '||MSC_UTIL.v_non_depot_org_str;
    end if ;


  OPEN c2_d for lv_del_stmt;
  LOOP

 -- FOR c_rec IN c2_d LOOP
  FETCH c2_d into
          lv_WIP_ENTITY_ID,
          lv_OPERATION_SEQ_NUM,
          lv_INVENTORY_ITEM_ID,
          lv_ORIGINATION_TYPE,
          lv_SR_INSTANCE_ID,
          lv_ORGANIZATION_ID;

   EXIT WHEN c2_d%NOTFOUND;

   UPDATE MSC_DEMANDS
       SET USING_REQUIREMENT_QUANTITY= 0,
           DAILY_DEMAND_RATE= 0,
           REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
           LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
           LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
     WHERE PLAN_ID=  -1
       AND SR_INSTANCE_ID=    lv_SR_INSTANCE_ID
       AND ORIGINATION_TYPE=  lv_ORIGINATION_TYPE
       AND WIP_ENTITY_ID=     lv_WIP_ENTITY_ID
       AND OP_SEQ_NUM=        NVL(lv_OPERATION_SEQ_NUM,OP_SEQ_NUM)
       AND ORGANIZATION_ID =  lv_ORGANIZATION_ID
       AND INVENTORY_ITEM_ID= NVL(lv_INVENTORY_ITEM_ID,INVENTORY_ITEM_ID);

  END LOOP;
  CLOSE c2_d;
 END IF;   -- Type of refresh

  c_count:=0;

-- ========= Prepare the Cursor Statement ==========
IF MSC_CL_COLLECTION.v_exchange_mode=MSC_UTIL.SYS_YES THEN
   lv_tbl:= 'DEMANDS_'||MSC_CL_COLLECTION.v_instance_code;
   lv_supplies_tbl:= 'SUPPLIES_'||MSC_CL_COLLECTION.v_instance_code;
ELSE
   lv_tbl:= 'MSC_DEMANDS';
   lv_supplies_tbl:= 'MSC_SUPPLIES';
END IF;


IF MSC_UTIL.G_COLLECT_SRP_DATA = 'Y' THEN
     lv_ITEM_TYPE_ID     :=  MSC_UTIL.G_PARTCONDN_ITEMTYPEID;
     lv_ITEM_TYPE_VALUE  :=  MSC_UTIL.G_PARTCONDN_BAD;
     lv_sel_sql_stmt     := 'ITEM_TYPE_ID,ITEM_TYPE_VALUE,';
     lv_data_sql_stmt    := lv_ITEM_TYPE_ID||','||lv_ITEM_TYPE_VALUE||',';
ELSE
     lv_ITEM_TYPE_ID     := NULL;
     lv_ITEM_TYPE_VALUE  := NULL;
     lv_sel_sql_stmt     := NULL;
     lv_data_sql_stmt    := NULL;
END IF;


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
||    lv_data_sql_stmt
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
||'  AND msd.ORIGINATION_TYPE = 77'   /* 50 eam demand: ds change change SRP Change 5909379*/
||'  AND msd.DELETED_FLAG= '||MSC_UTIL.SYS_NO
||'  AND t1.SR_INVENTORY_ITEM_ID= msd.inventory_item_id'
||'  AND t1.sr_instance_id= msd.SR_INSTANCE_ID'
||'  AND t2.SR_INVENTORY_ITEM_ID= msd.using_assembly_item_id'
||'  AND t2.sr_instance_id= msd.SR_INSTANCE_ID'
||'  AND t3.SR_INVENTORY_ITEM_ID (+)= msd.ASSET_ITEM_ID'
||'  AND t3.sr_instance_id (+) = msd.SR_INSTANCE_ID'
||'  AND ms.sr_instance_id= msd.SR_INSTANCE_ID'
||'  AND ms.ORGANIZATION_ID= msd.ORGANIZATION_ID'
||'  AND ms.DISPOSITION_ID= msd.wip_entity_id '
||'  AND ms.plan_id=-1'
||'  AND ms.ORDER_TYPE= 86'; /* ds change change*/

IF NOT MSC_CL_COLLECTION.v_is_incremental_refresh THEN
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
||    lv_sel_sql_stmt
||'   REFRESH_NUMBER,'
||'   LAST_UPDATE_DATE,'
||'   LAST_UPDATED_BY,'
||'   CREATION_DATE,'
||'   CREATED_BY)'
|| lv_cursor_stmt;



   BEGIN


     EXECUTE IMMEDIATE lv_sql_stmt
  	 USING
  	 MSC_CL_COLLECTION.v_chr10,
  	 MSC_CL_COLLECTION.v_chr13,
  	 MSC_CL_COLLECTION.v_last_collection_id,
  	 MSC_CL_COLLECTION.v_current_date,
  	 MSC_CL_COLLECTION.v_current_user,
  	 MSC_CL_COLLECTION.v_current_date,
  	 MSC_CL_COLLECTION.v_current_user;


   COMMIT;


   EXCEPTION
   WHEN OTHERS THEN

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '<<LOAD_ERO_DEMAND>>');
      IF lv_sql_stmt IS NOT NULL THEN
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '<<CURSOR>>'|| lv_sql_stmt);
      END IF;
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  SQLERRM);
--      log_message ('Error Occured'||SQLERRM);

   END;
END IF; --v_is_complete_refresh

   --==========================
IF MSC_CL_COLLECTION.v_is_incremental_refresh THEN  -- incremental Refresh
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
    ||'   ITEM_TYPE_ID,'
		||'   ITEM_TYPE_VALUE,'
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
    ||'   :ITEM_TYPE_ID,'
		||'   :ITEM_TYPE_VALUE,'
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
    ||'  AND msd.ORIGINATION_TYPE = 77'   /* 50 eam demand: ds change change*/
    ||'  AND msd.DELETED_FLAG= '||MSC_UTIL.SYS_NO
    ||'  AND t1.SR_INVENTORY_ITEM_ID= msd.inventory_item_id'
    ||'  AND t1.sr_instance_id= msd.SR_INSTANCE_ID'
    ||'  AND t2.SR_INVENTORY_ITEM_ID= msd.using_assembly_item_id'
    ||'  AND t2.sr_instance_id= msd.SR_INSTANCE_ID'
    ||'  AND t3.SR_INVENTORY_ITEM_ID (+)= msd.ASSET_ITEM_ID'
    ||'  AND t3.sr_instance_id (+) = msd.SR_INSTANCE_ID'
    ||'  AND ms.sr_instance_id= msd.SR_INSTANCE_ID'
    ||'  AND ms.ORGANIZATION_ID= msd.ORGANIZATION_ID'
    ||'  AND ms.DISPOSITION_ID= msd.WIP_ENTITY_ID'
    ||'  AND ms.plan_id=-1'
    ||'  AND ms.ORDER_TYPE= 86' /* ds change change*/
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


        IF lv_ORIGINATION_TYPE=77 THEN

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
          AND INVENTORY_ITEM_ID=  lv_INVENTORY_ITEM_ID ;

        END IF;  -- Origination_Type

        IF ( lv_DELETED_FLAG<> MSC_UTIL.SYS_YES ) AND ( lv_ORIGINATION_TYPE= 77)
        AND SQL%NOTFOUND THEN


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
           lv_item_type_id,
           lv_item_type_value,
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

        FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
        FND_MESSAGE.SET_TOKEN('COLUMN', 'WIP_ENTITY_ID');
        FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(lv_WIP_ENTITY_ID));
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
     c_count:= 0;
  END IF;
END LOOP; -- cursor c2

CLOSE c2;

END IF; -- MSC_CL_COLLECTION.v_is_incremental_refresh THEN  -- incremental Refresh
   --==========================
EXCEPTION
   WHEN OTHERS THEN
      IF c2%ISOPEN THEN CLOSE c2; END IF;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '<<LOAD_ERO_DEMAND>>');
      IF lv_cursor_stmt IS NOT NULL THEN
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '<<CURSOR>>'||lv_cursor_stmt);
      END IF;
      IF lv_sql_stmt IS NOT NULL THEN
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '<<SQL>>'||lv_sql_stmt);
      END IF;
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  SQLERRM);
      RAISE;
END LOAD_ERO_DEMAND;


END MSC_CL_RPO_ODS_LOAD;

/
