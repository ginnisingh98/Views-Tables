--------------------------------------------------------
--  DDL for Package Body MSC_CL_SUPPLY_PULL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_CL_SUPPLY_PULL" AS -- body
/* $Header:*/



   v_union_sql              varchar2(32767);
   v_temp_tp_sql            VARCHAR2(100);
   v_sql_stmt                    VARCHAR2(32767);
   v_temp_sql                    VARCHAR2(15000);
   v_temp_sql1                   VARCHAR2(1000);
   v_temp_sql2                   VARCHAR2(1000);
   v_temp_sql3                   VARCHAR2(1000);
   v_temp_sql4                   VARCHAR2(1000);


   --NULL_DBLINK                  CONSTANT VARCHAR2(1):= ' ';
--    NULL_DBLINK      CONSTANT  VARCHAR2(1) :=MSC_UTIL.NULL_DBLINK;

   v_item_type_id   NUMBER := MSC_UTIL.G_PARTCONDN_ITEMTYPEID;
   v_item_type_good NUMBER := MSC_UTIL.G_PARTCONDN_GOOD;
   v_item_type_bad  NUMBER := MSC_UTIL.G_PARTCONDN_BAD;
--==================================================================

   PROCEDURE LOAD_PO_SUPPLY IS

   lv_task_start_time    DATE;

   BEGIN

   lv_task_start_time := sysdate;

IF MSC_CL_PULL.PO_ENABLED= MSC_UTIL.SYS_YES THEN

-- =================== DELETED DATA ======================

--=================== Net Change Mode: Delete ==================

IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh

MSC_CL_PULL.v_table_name:= 'MSC_ST_SUPPLIES';
MSC_CL_PULL.v_view_name := 'MRP_AD_PO_SUPPLIES_V';

IF MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 THEN
   v_temp_sql := ' AND x.ORGANIZATION_ID '||MSC_UTIL.v_in_org_str;
ELSE
   v_temp_sql := NULL;
END IF;

v_sql_stmt:=
' insert into MSC_ST_SUPPLIES'
||'    ( SR_MTL_SUPPLY_ID,'
||'      ORDER_TYPE,'
||'      DELETED_FLAG,'
||'      REFRESH_ID,'
||'      SR_INSTANCE_ID)'
||' select'
||'      x.TRANSACTION_ID,'
||'      1,'                  -- using 1, such that the MSCCLBAB.LOAD_SUPPLY
||'      1,'                  -- can pick this PO record up for delete
||'      :v_refresh_id,'
||'      :v_instance_id'
||' from MRP_AD_PO_SUPPLIES_V'||MSC_CL_PULL.v_dblink||' x'
||' where x.RN>'||MSC_CL_PULL.v_lrn
|| v_temp_sql;

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

COMMIT;

END IF;


MSC_CL_PULL.v_table_name:= 'MSC_ST_SUPPLIES';
MSC_CL_PULL.v_view_name := 'MRP_AP_PO_SHIP_SUPPLY_V';


/* Added this code for VMI changes */
Begin

IF MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 THEN
   v_temp_sql := 'x.VMI_FLAG,x.VENDOR_ID,x.VENDOR_SITE_ID,x.POSTPROCESSING_LEAD_TIME,';
ELSE
   v_temp_sql := 'NULL,NULL,NULL,NULL,';
END IF;

End;

IF (MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 AND MSC_UTIL.G_COLLECT_SRP_DATA='Y') THEN
v_temp_sql1 := 'ITEM_TYPE_VALUE,';
v_temp_sql2 := 'DECODE(nvl(x.CONDITION_TYPE,''G''),''G'',1,''B'',2),';
ELSE
v_temp_sql1 :=NULL;
v_temp_sql2 :=NULL;
END IF;

v_sql_stmt:=
'insert into MSC_ST_SUPPLIES'
||'  (  SR_MTL_SUPPLY_ID,'
||'     INVENTORY_ITEM_ID,'
||'     ORGANIZATION_ID,'
||'     SUBINVENTORY_CODE,'
||      v_temp_sql1
||'     FROM_ORGANIZATION_ID,'
||'     SOURCE_ORGANIZATION_ID,'
||'     SOURCE_SR_INSTANCE_ID,'
||'     DISPOSITION_ID,'
||'     ORDER_TYPE,'
||'     NEW_SCHEDULE_DATE,'
||'     NEW_ORDER_QUANTITY,'
||'     QTY_SCRAPPED,'
||'     EXPECTED_SCRAP_QTY,'
||'     DELIVERY_PRICE,'
||'     PURCH_LINE_NUM,'
||'     PO_LINE_ID,'
||'     FIRM_PLANNED_TYPE,'
||'     NEW_DOCK_DATE,'
||'     ORDER_NUMBER,'
||'     REVISION,'
||'     PROJECT_ID,'
||'     TASK_ID,'
||'     PLANNING_GROUP,'
||'     UNIT_NUMBER,'
||'     VMI_FLAG ,'
||'     SUPPLIER_ID,'
||'     SUPPLIER_SITE_ID,'
||'     POSTPROCESSING_LEAD_TIME,'
||'     DELETED_FLAG,'
||'     PO_LINE_LOCATION_ID,'
||'     INTRANSIT_OWNING_ORG_ID,'
||'     REQ_LINE_ID,'
||'   REFRESH_ID,'
||'     SR_INSTANCE_ID)'
||'  SELECT '
||'       x.TRANSACTION_ID,'
||'       x.ITEM_ID,'
||'       x.TO_ORGANIZATION_ID,'
||'         DECODE( :v_mps_consume_profile_value, '
||'                 1, x.MRP_TO_SUBINVENTORY,'
||'                 x.TO_SUBINVENTORY),'
||        v_temp_sql2
||'       x.FROM_ORGANIZATION_ID,'
||'       x.FROM_ORGANIZATION_ID,'
||'       DECODE(x.FROM_ORGANIZATION_ID,NULL,NULL,:v_instance_id),'
||'       x.SHIPMENT_HEADER_ID,'
||'       11,'
||'       DECODE( :v_mps_consume_profile_value, '
||'               1, x.MRP_EXPECTED_DELIVERY_DATE,'
||'               x.EXPECTED_DELIVERY_DATE)- :v_dgmt,'
||'       DECODE( :v_mps_consume_profile_value, '
||'               1, x.MRP_PRIMARY_QUANTITY,'
||'               x.TO_ORG_PRIMARY_QUANTITY),'
||'       DECODE( :v_mps_consume_profile_value, '
||'               1, x.MRP_PRIMARY_QUANTITY,'
||'               x.TO_ORG_PRIMARY_QUANTITY)* '
||'               DECODE(SIGN(x.SHRINKAGE_RATE), -1, 0,(NVL(x.SHRINKAGE_RATE, 0))),'
||'       DECODE( :v_mps_consume_profile_value, '
||'               1, x.MRP_PRIMARY_QUANTITY,'
||'               x.TO_ORG_PRIMARY_QUANTITY)* '
||'               DECODE(SIGN(x.SHRINKAGE_RATE), -1, 0,(NVL(x.SHRINKAGE_RATE, 0))),'
||'       TO_NUMBER(NULL),'
||'       x.SHIPMENT_LINE_NUM,'
||'       x.SHIPMENT_LINE_ID,'
||'       2,'
||'       x.DOCK_DATE- :v_dgmt,'
||'       x.SHIPMENT_HEADER_NUM,'
||'       TO_CHAR(NULL),'
||'       x.PROJECT_ID,'
||'       x.TASK_ID,'
||'         mpp.PLANNING_GROUP,'
||'       x.END_ITEM_UNIT_NUMBER,'
||        v_temp_sql
||'       2,'
||'       x.LINE_LOCATION_ID,'
||'       x.INTRANSIT_OWNING_ORG_ID,'
||'       x.REQUISITION_LINE_ID,'
||'       :v_refresh_id,'
||'       :v_instance_id'
||'  from PJM_PROJECT_PARAMETERS'||MSC_CL_PULL.v_dblink||' mpp,'||'MRP_AP_PO_SHIP_SUPPLY_V'||MSC_CL_PULL.v_dblink||' x'
||'  where x.TO_ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'    AND mpp.project_id (+)= x.project_id'
||'    and mpp.organization_id (+)= DECODE( :v_mps_consume_profile_value,'
||'                                         1, x.MRP_TO_Organization_ID,'
||'                                         x.Organization_ID)'
||'    and DECODE( :v_mps_consume_profile_value,'
||'                1, x.MRP_DESTINATION_TYPE_CODE,'
||'                x.DESTINATION_TYPE_CODE)= ''INVENTORY'''
||'   AND (' -- x.RN1>'||MSC_CL_PULL.v_lrn
||'         x.RN2>'||MSC_CL_PULL.v_lrn
||'         OR x.RN3>'||MSC_CL_PULL.v_lrn||')';

v_temp_sql1 :=NULL;
v_temp_sql2 :=NULL;
EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_mps_consume_profile_value, MSC_CL_PULL.v_instance_id,
                                 MSC_CL_PULL.v_mps_consume_profile_value, MSC_CL_PULL.v_dgmt,
                                 MSC_CL_PULL.v_mps_consume_profile_value,
                                 MSC_CL_PULL.v_mps_consume_profile_value,
                                 MSC_CL_PULL.v_mps_consume_profile_value,
                                 MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id,
                                 MSC_CL_PULL.v_mps_consume_profile_value,
                                 MSC_CL_PULL.v_mps_consume_profile_value;

COMMIT;



MSC_CL_PULL.v_table_name:= 'MSC_ST_SUPPLIES';
MSC_CL_PULL.v_view_name := 'MRP_AP_PO_SHIP_RCV_SUPPLY_V';


/* Added this code for VMI changes */
IF MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 THEN
    v_temp_sql := 'x.VMI_FLAG,';
ELSE
    v_temp_sql := ' NULL, ';
END IF;

v_sql_stmt:=
' insert into MSC_ST_SUPPLIES'
||'  (  SR_MTL_SUPPLY_ID,'
||'     INVENTORY_ITEM_ID,'
||'     ORGANIZATION_ID,'
||'     SUBINVENTORY_CODE,'
||'     FROM_ORGANIZATION_ID,'
||'     SOURCE_ORGANIZATION_ID,'
||'     SOURCE_SR_INSTANCE_ID,'
||'     DISPOSITION_ID,'
||'     SUPPLIER_ID,'
||'     ORDER_TYPE,'
||'     NEW_SCHEDULE_DATE,'
||'     NEW_ORDER_QUANTITY,'
||'     QTY_SCRAPPED,'
||'     EXPECTED_SCRAP_QTY,'
||'     DELIVERY_PRICE,'
||'     PURCH_LINE_NUM,'
||'     PO_LINE_ID,'
||'     FIRM_PLANNED_TYPE,'
||'     NEW_DOCK_DATE,'
||'     ORDER_NUMBER,'
||'     REVISION,'
||'     PROJECT_ID,'
||'     TASK_ID,'
||'     PLANNING_GROUP,'
||'     UNIT_NUMBER,'
||'     VMI_FLAG,'
||'     DELETED_FLAG,'
||'   REFRESH_ID,'
||'     SR_INSTANCE_ID)'
||'  SELECT  '
||'        x.TRANSACTION_ID,'
||'        x.ITEM_ID,'
||'        x.TO_ORGANIZATION_ID,'
||'         DECODE( :v_mps_consume_profile_value, '
||'                 1, x.MRP_TO_SUBINVENTORY,'
||'                 x.TO_SUBINVENTORY),'
||'        x.FROM_ORGANIZATION_ID,'
||'        x.FROM_ORGANIZATION_ID,'
||'       DECODE(x.FROM_ORGANIZATION_ID,NULL,NULL,:v_instance_id),'
||'        x.SHIPMENT_HEADER_ID,'
||'        TO_NUMBER(NULL),'
||'        12,'
||'       DECODE( :v_mps_consume_profile_value, '
||'               1, x.MRP_EXPECTED_DELIVERY_DATE,'
||'               x.EXPECTED_DELIVERY_DATE)- :v_dgmt,'
||'       DECODE( :v_mps_consume_profile_value, '
||'               1, x.MRP_PRIMARY_QUANTITY,'
||'               x.TO_ORG_PRIMARY_QUANTITY),'
||'        TO_NUMBER(NULL),'
||'        TO_NUMBER(NULL),'
||'        TO_NUMBER(NULL),'
||'        x.SHIPMENT_LINE_NUM,'
||'        x.SHIPMENT_LINE_ID,'
||'        1,'
||'        x.DOCK_DATE- :v_dgmt,'
||'        x.SHIPMENT_NUM,'
||'        TO_CHAR(NULL),'
||'        x.PROJECT_ID,'
||'        x.TASK_ID,'
||'         mpp.PLANNING_GROUP,'
||'        x.END_ITEM_UNIT_NUMBER,'
||         v_temp_sql
||'        2,'
||'  :v_refresh_id,'
||'        :v_instance_id'
||'  from PJM_PROJECT_PARAMETERS'||MSC_CL_PULL.v_dblink||' mpp,'
||'       MRP_AP_PO_SHIP_RCV_SUPPLY_V'||MSC_CL_PULL.v_dblink||' x'
||'  where x.TO_ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'    AND mpp.project_id (+)= x.project_id'
||'    and mpp.organization_id (+)= DECODE( :v_mps_consume_profile_value,'
||'                                         1, x.MRP_TO_Organization_ID,'
||'                                         x.Organization_ID)'
||'    and DECODE( :v_mps_consume_profile_value,'
||'                1, x.MRP_DESTINATION_TYPE_CODE,'
||'                x.DESTINATION_TYPE_CODE)= ''INVENTORY'''
||'   AND (' -- x.RN1>'||MSC_CL_PULL.v_lrn
||'         x.RN2>'||MSC_CL_PULL.v_lrn
||'         OR x.RN3>'||MSC_CL_PULL.v_lrn||')';

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_mps_consume_profile_value, MSC_CL_PULL.v_instance_id,
                                 MSC_CL_PULL.v_mps_consume_profile_value, MSC_CL_PULL.v_dgmt,
                                 MSC_CL_PULL.v_mps_consume_profile_value,
                                 MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id,
                                 MSC_CL_PULL.v_mps_consume_profile_value,
                                 MSC_CL_PULL.v_mps_consume_profile_value;

COMMIT;

MSC_CL_PULL.v_table_name:= 'MSC_ST_SUPPLIES';
MSC_CL_PULL.v_view_name := 'MRP_AP_PO_RCV_SUPPLY_V';

/* Added this code for VMI changes */
-- bug#8426490 Add postprocessing LT for Supply-(PO in Receiving), Ord Type=8
IF MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 THEN
    v_temp_sql := 'x.VMI_FLAG,x.POSTPROCESSING_LEAD_TIME,';
ELSE
    v_temp_sql := ' NULL,NULL, ';
END IF;

v_sql_stmt:=
'  insert into MSC_ST_SUPPLIES'
||'    (  SR_MTL_SUPPLY_ID,'
||'       INVENTORY_ITEM_ID,'
||'       ORGANIZATION_ID,'
||'       SUBINVENTORY_CODE,'
||'       FROM_ORGANIZATION_ID,'
||'       SOURCE_ORGANIZATION_ID,'
||'       SOURCE_SR_INSTANCE_ID,'
||'       DISPOSITION_ID,'
||'       SUPPLIER_ID,'
||'       SUPPLIER_SITE_ID,'
||'       ORDER_TYPE,'
||'       NEW_SCHEDULE_DATE,'
||'       NEW_ORDER_QUANTITY,'
||'       QTY_SCRAPPED,'
||'       EXPECTED_SCRAP_QTY,'
||'       DELIVERY_PRICE,'
||'       PURCH_LINE_NUM,'
||'       PO_LINE_ID,'
||'       FIRM_PLANNED_TYPE,'
||'       NEW_DOCK_DATE,'
||'       ORDER_NUMBER,'
||'       REVISION,'
||'       PROJECT_ID,'
||'       TASK_ID,'
||'       PLANNING_GROUP,'
||'       UNIT_NUMBER,'
||'       VMI_FLAG,'
||'       POSTPROCESSING_LEAD_TIME,' --bug#8426490
||'       DELETED_FLAG,'
||'   REFRESH_ID,'
||'       SR_INSTANCE_ID)'
||'  select'
||'        x.TRANSACTION_ID,'
||'        x.ITEM_ID,'
||'        x.TO_ORGANIZATION_ID,'
||'         DECODE( :v_mps_consume_profile_value, '
||'                 1, x.MRP_TO_SUBINVENTORY,'
||'                 x.TO_SUBINVENTORY),'
||'        x.FROM_ORGANIZATION_ID,'
||'        x.FROM_ORGANIZATION_ID,'
||'       DECODE(x.FROM_ORGANIZATION_ID,NULL,NULL,:v_instance_id),'
||'        x.PO_HEADER_ID,'
||'        x.VENDOR_ID,'
||'        x.VENDOR_SITE_ID,'
||'        8,'
||'       DECODE( :v_mps_consume_profile_value, '
||'               1, x.MRP_EXPECTED_DELIVERY_DATE,'
||'               x.EXPECTED_DELIVERY_DATE)- :v_dgmt,'
||'       DECODE( :v_mps_consume_profile_value,'
||'               1, x.MRP_PRIMARY_QUANTITY,'
||'               x.TO_ORG_PRIMARY_QUANTITY),'
||'        TO_NUMBER(NULL),'
||'        TO_NUMBER(NULL),'
||'        x.UNIT_PRICE,'
||'        x.LINE_NUM,'
||'        x.PO_LINE_ID,'
||'        1,'
||'        x.DOCK_DATE- :v_dgmt,'
||'        x.PO_NUMBER,'
||'        x.ITEM_REVISION,'
||'        x.PROJECT_ID,'
||'        x.TASK_ID,'
||'         mpp.PLANNING_GROUP,'
||'        x.END_ITEM_UNIT_NUMBER,'
||         v_temp_sql
||'        2,'
||'  :v_refresh_id,'
||'        :v_instance_id'
||'  from PJM_PROJECT_PARAMETERS'||MSC_CL_PULL.v_dblink||' mpp,'
||'       MRP_AP_PO_RCV_SUPPLY_V'||MSC_CL_PULL.v_dblink||' x'
||'  where x.TO_ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'    AND mpp.project_id (+)= x.project_id'
||'    and mpp.organization_id (+)= DECODE( :v_mps_consume_profile_value,'
||'                                         1, x.MRP_TO_Organization_ID,'
||'                                         x.Organization_ID)'
||'    and DECODE( :v_mps_consume_profile_value,'
||'                1, x.MRP_DESTINATION_TYPE_CODE,'
||'                x.DESTINATION_TYPE_CODE)= ''INVENTORY'''
||'   AND (' /* x.RN1>'||MSC_CL_PULL.v_lrn */
||'         x.RN2>'||MSC_CL_PULL.v_lrn
||'         OR x.RN3>'||MSC_CL_PULL.v_lrn||')';

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_mps_consume_profile_value, MSC_CL_PULL.v_instance_id,
                                 MSC_CL_PULL.v_mps_consume_profile_value, MSC_CL_PULL.v_dgmt,
                                 MSC_CL_PULL.v_mps_consume_profile_value,
                                 MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id,
                                 MSC_CL_PULL.v_mps_consume_profile_value,
                                 MSC_CL_PULL.v_mps_consume_profile_value;

COMMIT;

MSC_CL_PULL.v_table_name:= 'MSC_ST_SUPPLIES';
MSC_CL_PULL.v_view_name := 'MRP_AP_INTRANSIT_SUPPLIES_V';

IF MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 THEN
   v_temp_sql := 'x.POSTPROCESSING_LEAD_TIME,';
ELSE
   v_temp_sql := 'NULL,';
END IF;

v_sql_stmt:=
' insert into MSC_ST_SUPPLIES'
||'  ( SR_MTL_SUPPLY_ID,'
||'    DISPOSITION_ID,'
||'    ORDER_NUMBER,'
||'    INVENTORY_ITEM_ID,'
||'    ORDER_TYPE,'
||'    PURCH_LINE_NUM,'
||'    PO_LINE_ID,'
||'    FIRM_PLANNED_TYPE,'
||'    NEW_ORDER_QUANTITY,'
||'    NEW_SCHEDULE_DATE,'
||'    ORGANIZATION_ID,'
||'    SUPPLIER_ID,'
||'    POSTPROCESSING_LEAD_TIME,'
||'    DELETED_FLAG,'
||'    REFRESH_ID,'
||'    SR_INSTANCE_ID)'
||'  select'
||'    -1,'
||'    x.HEADER_ID,'
||'    x.PO_NUMBER,'
||'    x.INVENTORY_ITEM_ID,'
||'    x.ORDER_TYPE,'
||'    x.PURCH_LINE_NUM,'
||'    x.LINE_ID,'
||'    x.FIRM_PLANNED_STATUS_TYPE,'
||'    x.NEW_ORDER_QUANTITY,'
||'    x.NEW_SCHEDULE_DATE- :v_dgmt,'
||'    x.ORGANIZATION_ID,'
||'    x.CUSTOMER_ID,'
||     v_temp_sql
||'    2,'
||'    :v_refresh_id,'
||'    :v_instance_id'
||'  from MRP_AP_INTRANSIT_SUPPLIES_V'||MSC_CL_PULL.v_dblink||' x'
||'  where x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'   AND (DECODE( :v_so_ship_arrive_value,'
||'                1, NVL(x.arrived_flag, 2), 2)= 2)'
||'   AND (x.RN2>'||MSC_CL_PULL.v_lrn||')';


EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id,
                                 MSC_CL_PULL.v_so_ship_arrive_value;

IF MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS120 THEN
     v_temp_sql := ' decode(x.PLANNING_ORGANIZATION_ID, -1, NULL, x.PLANNING_ORGANIZATION_ID),
                     decode(x.PLANNING_TP_TYPE, -1, NULL, x.PLANNING_TP_TYPE),
                     decode(x.OWNING_ORGANIZATION_ID, -1, NULL, x.OWNING_ORGANIZATION_ID),
                     decode(x.OWNING_TP_TYPE, -1, NULL, x.OWNING_TP_TYPE), ';

MSC_CL_PULL.v_table_name:= 'MSC_ST_SUPPLIES';
MSC_CL_PULL.v_view_name := 'MRP_AP_OH_PO_RCV_SUPPLY_V';

v_sql_stmt:=
'insert into MSC_ST_SUPPLIES'
||'  ( INVENTORY_ITEM_ID,'
||'    ORGANIZATION_ID,'
||'    SUBINVENTORY_CODE,'
||'    LOT_NUMBER,'
||'    NEW_ORDER_QUANTITY,'
||'    EXPIRATION_DATE,'
||'    PROJECT_ID,'
||'    TASK_ID,'
||'    PLANNING_GROUP,'
||'    UNIT_NUMBER,'
||'    PLANNING_PARTNER_SITE_ID,'
||'    PLANNING_TP_TYPE,'
||'    OWNING_PARTNER_SITE_ID,'
||'    OWNING_TP_TYPE,'
||'    ORDER_TYPE,'
||'    FIRM_PLANNED_TYPE,'
||'    NEW_SCHEDULE_DATE,'
||'    DELETED_FLAG,'
||'    REFRESH_ID,'
||'    SR_INSTANCE_ID)'
||'  select'
||'     x.INVENTORY_ITEM_ID,'
||'     x.ORGANIZATION_ID,'
||'     x.SUBINVENTORY_CODE,'
||'     x.LOT_NUMBER,'
||'     x.QUANTITY,'
||'     x.EXPIRATION_DATE,'
||'     x.PROJECT_ID,'
||'     x.TASK_ID,'
||'     x.PLANNING_GROUP,'
||'     x.END_ITEM_UNIT_NUMBER,'
||      v_temp_sql
||'     8,'
||'     2,'
||'     x.HOLD_DATE,'
||'     2,'
||'     :v_refresh_id,'
||'     :v_instance_id'
||'  from MRP_AP_OH_PO_RCV_SUPPLY_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str;

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

COMMIT;

END IF;  --MSC_CL_PULL.v_apps_ver >= G_APPS120
END IF; -- MSC_CL_PULL.PO_ENABLED


   END LOAD_PO_SUPPLY;


   PROCEDURE LOAD_OH_SUPPLY IS
   v_Decode varchar2(1000);
   BEGIN


--  ====================== 6: On Hand ====================

IF MSC_CL_PULL.OH_ENABLED= MSC_UTIL.SYS_YES THEN

--=================== Net Change Mode: Delete ==================

IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh

-- delete
IF MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 THEN
     v_temp_sql := ' x.QUANTITY, x.PROJECT_ID,x.TASK_ID,x.END_ITEM_UNIT_NUMBER,
                     decode(x.PLANNING_ORGANIZATION_ID, -1, NULL, x.PLANNING_ORGANIZATION_ID),
                     decode(x.PLANNING_TP_TYPE, -1, NULL, x.PLANNING_TP_TYPE),
                     decode(x.OWNING_ORGANIZATION_ID, -1, NULL, x.OWNING_ORGANIZATION_ID),
                     decode(x.OWNING_TP_TYPE, -1, NULL, x.OWNING_TP_TYPE), ';

ELSE
     v_temp_sql := ' NULL, NULL, NULL, NULL,
                     NULL,
                     NULL,
                     NULL,
                     NULL, ';
END IF;

MSC_CL_PULL.v_table_name:= 'MSC_ST_SUPPLIES';
MSC_CL_PULL.v_view_name := 'MRP_AD_ONHAND_SUPPLIES_V';

v_sql_stmt:=
'  insert into MSC_ST_SUPPLIES'
||'  ( INVENTORY_ITEM_ID,'
||'    ORGANIZATION_ID,'
||'    SUBINVENTORY_CODE,'
||'    LOT_NUMBER,'
||'    ORDER_TYPE,'
||'    DELETED_FLAG,'
||'    NEW_ORDER_QUANTITY,'
||'    PROJECT_ID,'
||'    TASK_ID,'
||'    UNIT_NUMBER,'
||'    PLANNING_PARTNER_SITE_ID,'
||'    PLANNING_TP_TYPE,'
||'    OWNING_PARTNER_SITE_ID,'
||'    OWNING_TP_TYPE,'
||'    REFRESH_ID,'
||'    SR_INSTANCE_ID)'
||'  select'
||'    x.INVENTORY_ITEM_ID,'
||'    x.ORGANIZATION_ID,'
||'    x.SUBINVENTORY_CODE,'
||'    x.LOT_NUMBER,'
||'    18,'
||'    1,'
||     v_temp_sql          --for 11i sources
||'    :v_refresh_id,'
||'    :v_instance_id'
||'  from MRP_AD_ONHAND_SUPPLIES_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'   AND x.RN>'||MSC_CL_PULL.v_lrn;

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

COMMIT;

-- insert/update

/* Added this code for VMI changes */
IF MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 THEN
     v_temp_sql := ' decode(x.PLANNING_ORGANIZATION_ID, -1, NULL, x.PLANNING_ORGANIZATION_ID),
                     decode(x.PLANNING_TP_TYPE, -1, NULL, x.PLANNING_TP_TYPE),
                     decode(x.OWNING_ORGANIZATION_ID, -1, NULL, x.OWNING_ORGANIZATION_ID),
                     decode(x.OWNING_TP_TYPE, -1, NULL, x.OWNING_TP_TYPE), ';

ELSE
     v_temp_sql := ' NULL, NULL, NULL, NULL, ';
END IF;

MSC_CL_PULL.v_table_name:= 'MSC_ST_SUPPLIES';


IF (MSC_UTIL.G_COLLECT_SRP_DATA='Y') THEN   -- SRP Changes Bug # 5684159
  IF (MSC_CL_PULL.v_apps_ver > MSC_UTIL.G_APPS115) THEN  -- bug 8819580
     MSC_CL_PULL.v_view_name := 'MRP_AP1_ONHAND_SUPPLIES_V';
  ELSIF (MSC_CL_PULL.v_apps_ver = MSC_UTIL.G_APPS115) THEN
     MSC_CL_PULL.v_view_name := 'MRP_AP_ONHAND_SUPPLIES_FLEX_V';
  END IF;

  v_Decode := ',DECODE(NVL(x.CONDITION_TYPE, '||''''||'G'||''''||'),'||''''||'G'||''''||', '||v_item_type_good||','||v_item_type_bad||'),';
  v_temp_sql :=  v_temp_sql ||'x.SR_CUSTOMER_ACCT_ID,'||v_item_type_id ||v_Decode;

ELSE
  MSC_CL_PULL.v_view_name := 'MRP_AP_ONHAND_SUPPLIES_V';
  v_temp_sql := v_temp_sql || ' NULL, NULL, NULL,';
end if;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'SRP VIew Onhand is- incr  ' ||  MSC_CL_PULL.v_view_name);


v_sql_stmt:=
'insert into MSC_ST_SUPPLIES'
||'  ( INVENTORY_ITEM_ID,'
||'    ORGANIZATION_ID,'
||'    SUBINVENTORY_CODE,'
||'    LOT_NUMBER,'
||'    NEW_ORDER_QUANTITY,'
||'    EXPIRATION_DATE,'
||'    PROJECT_ID,'
||'    TASK_ID,'
||'    PLANNING_GROUP,'
||'    UNIT_NUMBER,'
||'    ORDER_TYPE,'
||'    FIRM_PLANNED_TYPE,'
||'    NEW_SCHEDULE_DATE,'
||'    DELETED_FLAG,'
||'    PLANNING_PARTNER_SITE_ID,'
||'    PLANNING_TP_TYPE,'
||'    OWNING_PARTNER_SITE_ID,'
||'    OWNING_TP_TYPE,'
||'    SR_CUSTOMER_ACCT_ID,'
||'    ITEM_TYPE_ID,'
||'    ITEM_TYPE_VALUE,'
||'    REFRESH_ID,'
||'    SR_INSTANCE_ID)'
||'  select'
||'     x.INVENTORY_ITEM_ID,'
||'     x.ORGANIZATION_ID,'
||'     x.SUBINVENTORY_CODE,'
||'     x.LOT_NUMBER,'
||'     x.QUANTITY,'
||'     x.EXPIRATION_DATE,'
||'     x.PROJECT_ID,'
||'     x.TASK_ID,'
||'     x.PLANNING_GROUP,'
||'     x.END_ITEM_UNIT_NUMBER,'
||'     18,'
||'     2,'
||'     SYSDATE,'
||'     2,'
||      v_temp_sql
||'     :v_refresh_id,'
||'     :v_instance_id'
||' FROM  '||MSC_CL_PULL.v_view_name||MSC_CL_PULL.v_dblink||' x '
/*
   ||'  ( SELECT DISTINCT'
   ||'           inventory_item_id,'
   ||'           organization_id,'
   ||'           subinventory_code,'
   ||'           lot_number'
   ||'      FROM MRP_AN_ONHAND_SUPPLIES_V'||MSC_CL_PULL.v_dblink
   ||'     WHERE ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
   ||'       AND rn>'||MSC_CL_PULL.v_lrn||') a'
||' WHERE a.inventory_item_id= x.inventory_item_id'
||'   AND a.organization_id= x.organization_id'
||'   AND NVL(a.subinventory_code,'' '')= NVL( x.subinventory_code,'' '')'
||'   AND NVL(a.lot_number,'' '')= NVL( x.lot_number,'' '')';*/
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'   AND (x.RN1>'||MSC_CL_PULL.v_lrn
||'   OR x.RN2>'||MSC_CL_PULL.v_lrn||')';

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'SRP SQL stmt Onhand is  ' ||  v_sql_stmt);

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

COMMIT;

ELSE    -- complete refresh

MSC_CL_PULL.v_table_name:= 'MSC_ST_SUPPLIES';
MSC_CL_PULL.v_view_name := 'MRP_AP_ONHAND_SUPPLIES_V';

/* Added this code for VMI changes */
IF MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 THEN
     v_temp_sql := ' decode(x.PLANNING_ORGANIZATION_ID, -1, NULL, x.PLANNING_ORGANIZATION_ID),
                     decode(x.PLANNING_TP_TYPE, -1, NULL, x.PLANNING_TP_TYPE),
                     decode(x.OWNING_ORGANIZATION_ID, -1, NULL, x.OWNING_ORGANIZATION_ID),
                     decode(x.OWNING_TP_TYPE, -1, NULL, x.OWNING_TP_TYPE), ';

ELSE
     v_temp_sql := ' NULL, NULL, NULL, NULL, ';
END IF;


MSC_CL_PULL.v_table_name:= 'MSC_ST_SUPPLIES';

IF (MSC_UTIL.G_COLLECT_SRP_DATA='Y') THEN   -- SRP Changes Bug # 5684159

  IF (MSC_CL_PULL.v_apps_ver > MSC_UTIL.G_APPS115) THEN -- bug 8819580
     MSC_CL_PULL.v_view_name := 'MRP_AP1_ONHAND_SUPPLIES_V';
  ELSIF (MSC_CL_PULL.v_apps_ver = MSC_UTIL.G_APPS115) THEN
     MSC_CL_PULL.v_view_name := 'MRP_AP_ONHAND_SUPPLIES_FLEX_V';
  END IF;

  v_Decode := ',DECODE(NVL(x.CONDITION_TYPE, '||''''||'G'||''''||'),'||''''||'G'||''''||', '||v_item_type_good||','||v_item_type_bad||'),';
  v_temp_sql :=  v_temp_sql ||'x.SR_CUSTOMER_ACCT_ID,'||v_item_type_id ||v_Decode;

ELSE
  v_temp_sql := v_temp_sql || ' NULL, NULL, NULL,';
end if;
MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'SRP v_temp_sql ' ||  v_temp_sql);
MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'SRP VIew Onhand is targ/comp ' ||  MSC_CL_PULL.v_view_name);
v_sql_stmt:=
'insert into MSC_ST_SUPPLIES'
||'  ( INVENTORY_ITEM_ID,'
||'    ORGANIZATION_ID,'
||'    SUBINVENTORY_CODE,'
||'    LOT_NUMBER,'
||'    NEW_ORDER_QUANTITY,'
||'    EXPIRATION_DATE,'
||'    PROJECT_ID,'
||'    TASK_ID,'
||'    PLANNING_GROUP,'
||'    UNIT_NUMBER,'
||'    PLANNING_PARTNER_SITE_ID,'
||'    PLANNING_TP_TYPE,'
||'    OWNING_PARTNER_SITE_ID,'
||'    OWNING_TP_TYPE,'
||'    SR_CUSTOMER_ACCT_ID,'
||'    ITEM_TYPE_ID,'
||'    ITEM_TYPE_VALUE,'
||'    ORDER_TYPE,'
||'    FIRM_PLANNED_TYPE,'
||'    NEW_SCHEDULE_DATE,'
||'    DELETED_FLAG,'
||'    REFRESH_ID,'
||'    SR_INSTANCE_ID)'
||'  select'
||'     x.INVENTORY_ITEM_ID,'
||'     x.ORGANIZATION_ID,'
||'     x.SUBINVENTORY_CODE,'
||'     x.LOT_NUMBER,'
||'     x.QUANTITY,'
||'     x.EXPIRATION_DATE,'
||'     x.PROJECT_ID,'
||'     x.TASK_ID,'
||'     x.PLANNING_GROUP,'
||'     x.END_ITEM_UNIT_NUMBER,'
||      v_temp_sql
||'     18,'
||'     2,'
||'     SYSDATE,'
||'     2,'
||'     :v_refresh_id,'
||'     :v_instance_id'
||'  FROM  '||MSC_CL_PULL.v_view_name||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str;

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;
MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'SRP v_sql_stmt ' ||  v_sql_stmt);
COMMIT;

END IF;  -- incremental refresh

END IF;  -- MSC_CL_PULL.OH_ENABLED

END LOAD_OH_SUPPLY;



   PROCEDURE LOAD_MPS_SUPPLY IS
   BEGIN

--  ====================== 8: MPS ====================

IF MSC_CL_PULL.MPS_ENABLED= MSC_UTIL.SYS_YES THEN

IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh

MSC_CL_PULL.v_table_name:= 'MSC_ST_SUPPLIES';
MSC_CL_PULL.v_view_name := 'MRP_AD_MPS_SUPPLIES_V';

v_sql_stmt:=
'insert into MSC_ST_SUPPLIES'
||' (  DISPOSITION_ID,'
||'    INVENTORY_ITEM_ID,'
||'    ORGANIZATION_ID,'
||'    ORDER_TYPE,'
||'    DELETED_FLAG,'
||'    REFRESH_ID,'
||'    SR_INSTANCE_ID)'
||'  select'
||'    x.DISPOSITION_ID,'
||'    x.INVENTORY_ITEM_ID,'
||'    x.ORGANIZATION_ID,'
||'    x.ORDER_TYPE,'
||'    1,'
||'    :v_refresh_id,'
||'    :v_instance_id'
||'  from MRP_AD_MPS_SUPPLIES_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.RN>'||MSC_CL_PULL.v_lrn
||' AND x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str;

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

COMMIT;

END IF;

MSC_CL_PULL.v_table_name:= 'MSC_ST_SUPPLIES';
MSC_CL_PULL.v_view_name := 'MRP_AP_MPS_SUPPLIES_V';

v_sql_stmt:=
'insert into MSC_ST_SUPPLIES'
||'  ( DISPOSITION_ID,'
||'    INVENTORY_ITEM_ID,'
||'    ORGANIZATION_ID,'
||'    SCHEDULE_DESIGNATOR,'
||'    NEW_SCHEDULE_DATE,'
||'    LAST_UNIT_START_DATE,'
||'    NEW_ORDER_QUANTITY,'
||'    DAILY_RATE,'
||'    ORDER_TYPE,'
||'    SOURCE_ORGANIZATION_ID,'
||'    SOURCE_SR_INSTANCE_ID,'
||'    PROJECT_ID,'
||'    TASK_ID,'
||'    LINE_ID,'
||'    UNIT_NUMBER,'
||'    PLANNING_GROUP,'
||'    FIRM_PLANNED_TYPE,'
||'    DELETED_FLAG,'
||'   REFRESH_ID,'
||'    SR_INSTANCE_ID,'
||'    Schedule_origination_type'
||' )'
||'  select'
||'     x.DISPOSITION_ID,'
||'     x.INVENTORY_ITEM_ID,'
||'     x.ORGANIZATION_ID,'
||'     x.SCHEDULE_DESIGNATOR,'
||'     x.SCHEDULE_DATE- :v_dgmt,'
||'     x.RATE_END_DATE- :v_dgmt,'
||'     x.SCHEDULE_QUANTITY,'
||'     x.REPETITIVE_DAILY_RATE,'
||'     x.ORDER_TYPE,'
||'     x.SOURCE_ORGANIZATION_ID,'
||'     DECODE(x.SOURCE_ORGANIZATION_ID,NULL,NULL,:v_instance_id),'
||'     x.PROJECT_ID,'
||'     x.TASK_ID,'
||'     x.LINE_ID,'
||'     x.END_ITEM_UNIT_NUMBER,'
||'     x.PLANNING_GROUP,'
||'     x.FIRM_PLANNED_TYPE,'
||'     2,'
||'     :v_refresh_id,'
||'     :v_instance_id,'
||'     x.schedule_origination_type '
||'  from MRP_AP_MPS_SUPPLIES_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'   AND (' --x.RN1>'||MSC_CL_PULL.v_lrn
||'         x.RN2>'||MSC_CL_PULL.v_lrn
||'         OR x.RN3>'||MSC_CL_PULL.v_lrn||')';
--||'    OR x.RN4>'||MSC_CL_PULL.v_lrn||')';

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt,
                                 MSC_CL_PULL.v_instance_id, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

COMMIT;

END IF;    -- MSC_CL_PULL.MPS_ENABLED

  --VENDOR_ID, VENDOR_SITE_ID

   END LOAD_MPS_SUPPLY;


   PROCEDURE LOAD_USER_SUPPLY IS
   BEGIN

IF MSC_CL_PULL.v_apps_ver<> MSC_UTIL.G_APPS107 AND
   MSC_CL_PULL.v_apps_ver<> MSC_UTIL.G_APPS110 THEN

IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh

MSC_CL_PULL.v_table_name:= 'MSC_ST_SUPPLIES';
MSC_CL_PULL.v_view_name := 'MRP_AD_USER_SUPPLIES_V';

IF MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 THEN
   v_temp_sql := ' AND x.ORGANIZATION_ID '||MSC_UTIL.v_in_org_str;
ELSE
   v_temp_sql := NULL;
END IF;

v_sql_stmt:=
' INSERT INTO MSC_ST_SUPPLIES'
||'( DISPOSITION_ID,'
||'  ORDER_TYPE,'
||'  ORGANIZATION_ID,'
||'  DELETED_FLAG,'
||'  REFRESH_ID,'
||'  SR_INSTANCE_ID)'
||' SELECT'
||'  x.TRANSACTION_ID,'
||'  x.ORDER_TYPE,'
||'  x.ORGANIZATION_ID,'
||'  1,'
||'  :v_refresh_id,'
||'  :v_instance_id'
||' FROM MRP_AD_USER_SUPPLIES_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.RN>'||MSC_CL_PULL.v_lrn
|| v_temp_sql;

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

COMMIT;

END IF;

MSC_CL_PULL.v_table_name:= 'MSC_ST_SUPPLIES';
MSC_CL_PULL.v_view_name := 'MRP_AP_USER_SUPPLIES_V';

v_sql_stmt:=
' INSERT INTO MSC_ST_SUPPLIES'
||'( DISPOSITION_ID,'
||'  ORDER_TYPE,'
||'  INVENTORY_ITEM_ID,'
||'  ORGANIZATION_ID,'
||'  ORDER_NUMBER,'
||'  NEW_ORDER_QUANTITY,'
||'  NEW_SCHEDULE_DATE,'
||'  FIRM_PLANNED_TYPE,'
||'  DEMAND_CLASS,'
||'  DELETED_FLAG,'
||'  REFRESH_ID,'
||'  SR_INSTANCE_ID)'
||' SELECT'
||'  x.TRANSACTION_ID,'
||'  x.ORDER_TYPE,'
||'  x.INVENTORY_ITEM_ID,'
||'  x.ORGANIZATION_ID,'
||'  x.SOURCE_NAME,'
||'  x.PRIMARY_UOM_QUANTITY,'
||'  x.EXPECTED_DELIVERY_DATE,'
||'  1,'   -- firm planned type
--||'    DECODE( x.DEMAND_CLASS,NULL,NULL,:V_ICODE||x.DEMAND_CLASS),'
||'    x.DEMAND_CLASS,'
||'  2,'
||'  :v_refresh_id,'
||'  :v_instance_id'
||' FROM MRP_AP_USER_SUPPLIES_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'   AND (x.RN1>'||MSC_CL_PULL.v_lrn
||'   OR  x.RN2>'||MSC_CL_PULL.v_lrn||')';

--EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.V_ICODE, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;
EXECUTE IMMEDIATE v_sql_stmt USING  MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

COMMIT;

END IF;

  END LOAD_USER_SUPPLY;


  -- ========LOAD PURCHASE ORDER ==========
   PROCEDURE LOAD_PO_PO_SUPPLY IS

   	lv_task_start_time    DATE;
    v_view_name  VARCHAR2(1000);
    v_order_type varchar2(2000);

   BEGIN

  	 lv_task_start_time := sysdate;

			IF MSC_CL_PULL.PO_ENABLED= MSC_UTIL.SYS_YES THEN
				MSC_CL_PULL.v_table_name:= 'MSC_ST_SUPPLIES';
				MSC_CL_PULL.v_view_name := 'MRP_AP_PO_PO_SUPPLY_V';

				/* Added this code for VMI changes */
				IF MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 THEN
                    v_temp_sql := 'x.VMI_FLAG,x.PO_LINE_LOCATION_ID,x.PO_DISTRIBUTION_ID, ';
                ELSE
                    v_temp_sql := ' NULL,NULL,NULL, ';
                END IF;

				/* Added this code for SRP changes Bug 6324690 */
				IF (MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS120 AND MSC_UTIL.G_COLLECT_SRP_DATA='Y') THEN   -- SRP Changes Bug # 6324690
          v_view_name := 'MRP_AP_PO_CSP_SUPPLY_V';
          v_order_type := 'x.order_type,';
        ELSIF (MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 AND MSC_UTIL.G_COLLECT_SRP_DATA='Y')  THEN
           v_view_name := 'MRP_AP_PO_PO_SUPPLY_V';
			     v_order_type := ' decode(INSTR('''||MSC_UTIL.v_ext_repair_sup_id_str||''','',''||x.VENDOR_ID||'',''),'
					 || '0,decode(INSTR('''||MSC_UTIL.v_ext_repair_sup_id_str||''','',''||x.VENDOR_ID||'')''),'
           || '0,decode(INSTR('''||MSC_UTIL.v_ext_repair_sup_id_str||''',''(''||x.VENDOR_ID||'',''),'
           || '0,decode(INSTR('''||MSC_UTIL.v_ext_repair_sup_id_str||''',''(''||x.VENDOR_ID||'')''),'
					 || '0,1,74),74),74),74), ';
        ELSE
          v_view_name := 'MRP_AP_PO_PO_SUPPLY_V';
          v_order_type := '1,';
        END IF;

				v_sql_stmt:=
				' insert into MSC_ST_SUPPLIES'
				||'    (  SR_MTL_SUPPLY_ID,'
				||'       INVENTORY_ITEM_ID,'
				||'       ORGANIZATION_ID,'
				||'       SUBINVENTORY_CODE,'
				||'       FROM_ORGANIZATION_ID,'
				||'       SOURCE_ORGANIZATION_ID,'
				||'       SOURCE_SR_INSTANCE_ID,'
				||'       DISPOSITION_ID,'
				||'       SUPPLIER_ID,'
				||'       SUPPLIER_SITE_ID,'
				||'       ORDER_TYPE,'
				||'       NEW_SCHEDULE_DATE,'
				||'       NEW_ORDER_QUANTITY,'
				||'       QTY_SCRAPPED,'
				||'       EXPECTED_SCRAP_QTY,'
				||'       DELIVERY_PRICE,'
				||'       PURCH_LINE_NUM,'
				||'       PO_LINE_ID,'
				||'       FIRM_PLANNED_TYPE,'
				||'       NEW_DOCK_DATE,'
				||'       ORDER_NUMBER,'
				||'       REVISION,'
				||'       PROJECT_ID,'
				||'       TASK_ID,'
				||'       PLANNING_GROUP,'
				||'       UNIT_NUMBER,'
				||'       VMI_FLAG,'
				||'       PO_LINE_LOCATION_ID,'
				||'       PO_DISTRIBUTION_ID,'
				||'       DELETED_FLAG,'
				||'       REFRESH_ID,'
				/* CP change starts */
				||'       NEW_ORDER_PLACEMENT_DATE,'
				/* CP change stops */
				/* CP-ACK starts */
				||'       ORIGINAL_NEED_BY_DATE,'
				||'       ORIGINAL_QUANTITY,'
				||'       PROMISED_DATE,'
				||'       NEED_BY_DATE,'
				||'       ACCEPTANCE_REQUIRED_FLAG,'
				||'       POSTPROCESSING_LEAD_TIME,'
				/* CP-ACK ends */
				||'       SR_INSTANCE_ID)'
				||'  select'
				||'         x.TRANSACTION_ID,'
				||'         x.ITEM_ID,'
				||'         x.TO_ORGANIZATION_ID,'
				||'         DECODE( :v_mps_consume_profile_value, '
				||'                 1, x.MRP_TO_SUBINVENTORY,'
				||'                 x.TO_SUBINVENTORY),'
				||'         x.FROM_ORGANIZATION_ID,'
				||'         x.FROM_ORGANIZATION_ID,'
				||'         DECODE(x.FROM_ORGANIZATION_ID,NULL,NULL,:v_instance_id),'
				||'         x.PO_HEADER_ID,'
				||'         x.VENDOR_ID,'
				||'         x.VENDOR_SITE_ID,'
				||          v_order_type
				||'         DECODE( :v_mps_consume_profile_value,'
				||'                 1, x.MRP_EXPECTED_DELIVERY_DATE,'
				||'                 x.EXPECTED_DELIVERY_DATE)- :v_dgmt,'
				||'         DECODE( :v_mps_consume_profile_value, '
				||'                 1, x.MRP_PRIMARY_QUANTITY,'
				||'                 x.TO_ORG_PRIMARY_QUANTITY),'
				||'         DECODE( :v_mps_consume_profile_value,'
				||'                 1, x.MRP_PRIMARY_QUANTITY,'
				||'                 x.TO_ORG_PRIMARY_QUANTITY)*'
				||'                 DECODE(SIGN(x.SHRINKAGE_RATE), -1, 0,(NVL(x.SHRINKAGE_RATE, 0))),'
				||'         DECODE( :v_mps_consume_profile_value,'
				||'                 1, x.MRP_PRIMARY_QUANTITY,'
				||'                 x.TO_ORG_PRIMARY_QUANTITY)*'
				||'                 DECODE(SIGN(x.SHRINKAGE_RATE), -1, 0,(NVL(x.SHRINKAGE_RATE, 0))),'
				||'         x.UNIT_PRICE,'
				||'         x.LINE_NUM,'
				||'         x.PO_LINE_ID,'
				||'         DECODE( decode( decode( sign(nvl(x.ph_firm_date,sysdate+1)-sysdate),'
				                      ||'           1, x.ph_firm_status_lookup_code,'
				                      ||'           ''Y''),'
				                      ||'   ''N'',decode(sign(nvl(x.pll_firm_date,sysdate+1)-sysdate),'
				                      ||'              1, x.pll_firm_status_lookup_code,'
				                      ||'              ''Y''),'
				                      ||'   ''Y''),'
				               ||'  ''Y'',1,'
				               ||'  2),'
				||'         x.EXPECTED_DOCK_DATE- :v_dgmt,'
				||'         x.PO_NUMBER,'
				||'         x.ITEM_REVISION,'
				||'         x.PROJECT_ID,'
				||'         x.TASK_ID,'
				||'         mpp.PLANNING_GROUP,'
				||'         x.END_ITEM_UNIT_NUMBER,'
				||          v_temp_sql
				||'         2,'
				||'         :v_refresh_id,'
				/* CP change starts */
				||'         x.NEW_ORDER_PLACEMENT_DATE,'
				/* CP change ends */
				/* CP-ACK starts */
				||'       Decode (:G_MSC_CONFIGURATION,:G_CONF_APS,NULL, ORIGINAL_NEED_BY_DATE),'
        ||'       Decode (:G_MSC_CONFIGURATION,:G_CONF_APS,NULL, ORIGINAL_QUANTITY),'
				||'       x.PROMISED_DATE,'
				||'       x.NEED_BY_DATE,'
				||'       x.ACCEPTANCE_REQUIRED_FLAG,'
				||'       x.POSTPROCESSING_LEAD_TIME,'
				/* CP-ACK ends */
				||'         :v_instance_id'
				||'  from PJM_PROJECT_PARAMETERS'||MSC_CL_PULL.v_dblink||' mpp,'
				||v_view_name||MSC_CL_PULL.v_dblink||' x'
				||'  where x.TO_ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
				||'    AND mpp.project_id (+)= x.project_id'
				||'    and mpp.organization_id (+)= DECODE( :v_mps_consume_profile_value,'
				||'                                         1, x.MRP_TO_Organization_ID,'
				||'                                         x.Organization_ID)'
				||'    and DECODE( :v_mps_consume_profile_value,'
				||'                1, x.MRP_DESTINATION_TYPE_CODE,'
				||'                x.DESTINATION_TYPE_CODE)= ''INVENTORY'''
				||'   AND ('  -- x.RN1>'||MSC_CL_PULL.v_lrn
				||'         x.RN2>'||MSC_CL_PULL.v_lrn
				||'         OR x.RN3>'||MSC_CL_PULL.v_lrn||')';

				MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,'Test Sql  :'||v_sql_stmt);

				EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_mps_consume_profile_value, MSC_CL_PULL.v_instance_id,
				                                 MSC_CL_PULL.v_mps_consume_profile_value, MSC_CL_PULL.v_dgmt,
				                                 MSC_CL_PULL.v_mps_consume_profile_value,
				                                 MSC_CL_PULL.v_mps_consume_profile_value,
				                                 MSC_CL_PULL.v_mps_consume_profile_value,
				                                 MSC_CL_PULL.v_dgmt,
				                                 MSC_CL_PULL.v_refresh_id,
				                                 MSC_UTIL.G_MSC_CONFIGURATION, MSC_UTIL.G_CONF_APS,
				 																 MSC_UTIL.G_MSC_CONFIGURATION, MSC_UTIL.G_CONF_APS,
				                                 MSC_CL_PULL.v_instance_id,
				                                 MSC_CL_PULL.v_mps_consume_profile_value,
				                                 MSC_CL_PULL.v_mps_consume_profile_value;

				COMMIT;

			END IF ;
	END LOAD_PO_PO_SUPPLY;

-- ================= LOAD PURCHASE REQUISITIONS ================
   PROCEDURE LOAD_PO_REQ_SUPPLY IS

   lv_task_start_time    DATE;

   BEGIN

   lv_task_start_time := sysdate;

		IF MSC_CL_PULL.PO_ENABLED= MSC_UTIL.SYS_YES THEN
			MSC_CL_PULL.v_table_name:= 'MSC_ST_SUPPLIES';
			MSC_CL_PULL.v_view_name := 'MRP_AP_PO_REQ_SUPPLY_V';

			/* Added this code for VMI changes */
			/*Begin
			Select decode(MSC_CL_PULL.v_apps_ver,MSC_UTIL.G_APPS120,'x.VMI_FLAG,',MSC_UTIL.G_APPS115,'x.VMI_FLAG,',' NULL, ')
			into v_temp_sql
			from dual;
			End;*/

			IF MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 THEN
              v_temp_sql := ' x.VMI_FLAG, x.POSTPROCESSING_LEAD_TIME,  ';
            ELSE
              v_temp_sql := ' NULL, NULL, ';
            END IF;
			/* Changes For Bug 6331844 */
			/*  From the View :
          Order_type is 2.1   - Ireq attached to IRO With MOVE_IN        --- Cond Bad
          Order_type is 2.2   - Ireq attached to IRO With MOVE_OUT (73)  --- Cond Good
          Order_type is 2.3   - Preq attached to ERO    (87)             --- Cond Good
          Order_type is 2.4   - Normal Ireq From Good Sub inv            --- Cond Good
          Order_type is 2.5   - Normal Ireq From BAD Sub inv             --- Cond Bad
          Order_type is 2     - Normal Ireq without any Subinv attached  --- Cond N/A
      */
			IF (MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 AND MSC_UTIL.G_COLLECT_SRP_DATA='Y')  THEN -- condition MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS120 changed to MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 for 8819580
        v_temp_sql := v_temp_sql||' decode(x.order_type,2.2,73,2.3,87,2) , ';
        v_temp_sql := v_temp_sql ||' decode(x.order_type,
                         2.1,'||MSC_UTIL.G_PARTCONDN_ITEMTYPEID
                     ||',2.2,'||MSC_UTIL.G_PARTCONDN_ITEMTYPEID
                     ||',2.3,'||MSC_UTIL.G_PARTCONDN_ITEMTYPEID
                     ||',2.4,'||MSC_UTIL.G_PARTCONDN_ITEMTYPEID
                     ||',2.5,'||MSC_UTIL.G_PARTCONDN_ITEMTYPEID
                     ||') ,';
        v_temp_sql :=v_temp_sql ||' decode(x.order_type,
                         2.1,'||MSC_UTIL.G_PARTCONDN_BAD
                     ||',2.2,'||MSC_UTIL.G_PARTCONDN_GOOD
                     ||',2.3,'||MSC_UTIL.G_PARTCONDN_GOOD
                     ||',2.4,'||MSC_UTIL.G_PARTCONDN_GOOD
                     ||',2.5,'||MSC_UTIL.G_PARTCONDN_BAD
                     || '), ';
      /* ELSIF (MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 AND MSC_UTIL.G_COLLECT_SRP_DATA='Y')  THEN
			    v_temp_sql := v_temp_sql||' decode(INSTR('''||MSC_UTIL.v_depot_org_str||''','',''||x.FROM_ORGANIZATION_ID||'',''),'
					|| '0,decode(INSTR('''||MSC_UTIL.v_depot_org_str||''','',''||x.FROM_ORGANIZATION_ID||'')''), '
					|| '0,decode(INSTR('''||MSC_UTIL.v_depot_org_str||''',''(''||x.FROM_ORGANIZATION_ID||'',''), '
					|| '0,decode(INSTR('''||MSC_UTIL.v_depot_org_str||''',''(''||x.FROM_ORGANIZATION_ID||'')''), '
					|| '0,2,73),73),73),73) , NULL,NULL, '; */ --- commented for 8819580
       ELSE
        		v_temp_sql := v_temp_sql||' 2,NULL,NULL, ';
       END IF;

			v_sql_stmt:=
			'insert into MSC_ST_SUPPLIES'
			||'    (  SR_MTL_SUPPLY_ID,'
			||'       INVENTORY_ITEM_ID,'
			||'       ORGANIZATION_ID,'
			||'       SUBINVENTORY_CODE,'
			||'       FROM_ORGANIZATION_ID,'
			||'       SOURCE_ORGANIZATION_ID,'
			||'       SOURCE_SR_INSTANCE_ID,'
			||'       DISPOSITION_ID,'
			||'       SUPPLIER_ID,'
			||'       SUPPLIER_SITE_ID,'
--			||'       ORDER_TYPE,'
			||'       NEW_SCHEDULE_DATE,'
			||'       NEW_ORDER_QUANTITY,'
			||'       QTY_SCRAPPED,'
			||'       EXPECTED_SCRAP_QTY,'
			||'       DELIVERY_PRICE,'
			||'       PURCH_LINE_NUM,'
			||'       PO_LINE_ID,'
			||'       FIRM_PLANNED_TYPE,'
			||'       NEW_DOCK_DATE,'
			||'       ORDER_NUMBER,'
			||'       REVISION,'
			||'       PROJECT_ID,'
			||'       TASK_ID,'
			||'       PLANNING_GROUP,'
			||'       UNIT_NUMBER,'
			||'       VMI_FLAG,'
			||'       POSTPROCESSING_LEAD_TIME, '
			||'       ORDER_TYPE,'
      ||'       ITEM_TYPE_ID,'
      ||'       ITEM_TYPE_VALUE,'
			||'       DELETED_FLAG,'
			||'   REFRESH_ID,'
			/* CP change starts */
			||'       NEW_ORDER_PLACEMENT_DATE,'
			/* CP change ends */
			||'       SR_INSTANCE_ID)'
			||'  select'
			||'       x.TRANSACTION_ID,'
			||'       x.ITEM_ID,'
			||'       x.TO_ORGANIZATION_ID,'
			||'         DECODE( :v_mps_consume_profile_value, '
			||'                 1, x.MRP_TO_SUBINVENTORY,'
			||'                 x.TO_SUBINVENTORY),'
			||'       x.FROM_ORGANIZATION_ID,'
			||'       x.FROM_ORGANIZATION_ID,'
			||'       DECODE(x.FROM_ORGANIZATION_ID,NULL,NULL,:v_instance_id),'
			||'       x.REQUISITION_HEADER_ID,'
			||'       x.VENDOR_ID,'
			||'       x.VENDOR_SITE_ID,'
--			||'       2,'
			||'       DECODE( :v_mps_consume_profile_value, '
			||'               1, x.MRP_EXPECTED_DELIVERY_DATE,'
			||'               x.EXPECTED_DELIVERY_DATE)- :v_dgmt,'
			||'       DECODE( :v_mps_consume_profile_value, '
			||'               1, x.MRP_PRIMARY_QUANTITY,'
			||'               x.TO_ORG_PRIMARY_QUANTITY),'
			||'       DECODE( :v_mps_consume_profile_value,'
			||'               1, x.MRP_PRIMARY_QUANTITY,'
			||'               x.TO_ORG_PRIMARY_QUANTITY)*'
			||'            DECODE(SIGN(x.SHRINKAGE_RATE), -1, 0,(NVL(x.SHRINKAGE_RATE, 0))),'
			||'       DECODE( :v_mps_consume_profile_value,'
			||'               1, x.MRP_PRIMARY_QUANTITY,'
			||'               x.TO_ORG_PRIMARY_QUANTITY)*'
			||'            DECODE(SIGN(x.SHRINKAGE_RATE), -1, 0,(NVL(x.SHRINKAGE_RATE, 0))),'
			||'       x.UNIT_PRICE,'
			||'       x.LINE_NUM,'
			||'       x.REQ_LINE_ID,'
			||'       2,'
			||'       x.EXPECTED_DOCK_DATE- :v_dgmt,'
			||'       x.REQUISITION_NUMBER,'
			||'       TO_CHAR(NULL),'
			||'       x.PROJECT_ID,'
			||'       x.TASK_ID,'
			||'         mpp.PLANNING_GROUP,'
			||'       x.END_ITEM_UNIT_NUMBER,'
			||        v_temp_sql
			||'       2,'
			||'  :v_refresh_id,'
			/* CP change starts */
			||'       x.NEW_ORDER_PLACEMENT_DATE,'
			/* CP change starts */
			||'       :v_instance_id'
			||'  from PJM_PROJECT_PARAMETERS'||MSC_CL_PULL.v_dblink||' mpp,'
			||'       MRP_AP_PO_REQ_SUPPLY_V'||MSC_CL_PULL.v_dblink||' x'
			||'  where x.TO_ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
			||'    AND mpp.project_id (+)= x.project_id'
			||'    and mpp.organization_id (+)= DECODE( :v_mps_consume_profile_value,'
			||'                                         1, x.MRP_TO_Organization_ID,'
			||'                                         x.Organization_ID)'
			||'    and DECODE( :v_mps_consume_profile_value,'
			||'                1, x.MRP_DESTINATION_TYPE_CODE,'
			||'                x.DESTINATION_TYPE_CODE)= ''INVENTORY'''
			||'   AND (' --x.RN1>'||MSC_CL_PULL.v_lrn
			||'         x.RN2>'||MSC_CL_PULL.v_lrn
			||'         OR x.RN3>'||MSC_CL_PULL.v_lrn||')';
			MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,'Test Sql PO_REC INSERT :'||v_sql_stmt);
			EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_mps_consume_profile_value, MSC_CL_PULL.v_instance_id,
			                                 MSC_CL_PULL.v_mps_consume_profile_value, MSC_CL_PULL.v_dgmt,
			                                 MSC_CL_PULL.v_mps_consume_profile_value,
			                                 MSC_CL_PULL.v_mps_consume_profile_value,
			                                 MSC_CL_PULL.v_mps_consume_profile_value,
			                                 MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id,
			                                 MSC_CL_PULL.v_mps_consume_profile_value,
			                                 MSC_CL_PULL.v_mps_consume_profile_value;

			COMMIT;

		END IF ;
END LOAD_PO_REQ_SUPPLY;


END MSC_CL_SUPPLY_PULL;

/
