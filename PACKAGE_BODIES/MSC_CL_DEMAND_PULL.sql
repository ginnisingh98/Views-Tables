--------------------------------------------------------
--  DDL for Package Body MSC_CL_DEMAND_PULL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_CL_DEMAND_PULL" AS -- body
/* $Header:*/



   v_union_sql              varchar2(32767);
   v_temp_tp_sql            VARCHAR2(100);
   v_sql_stmt                    VARCHAR2(32767);
   v_temp_sql                    VARCHAR2(15000);
   v_temp_sql1                   VARCHAR2(1000);
   v_temp_sql2                   VARCHAR2(1000);
   v_temp_sql3                   VARCHAR2(1000);
   v_temp_sql4                   VARCHAR2(1000);

  -- NULL_DBLINK                  CONSTANT VARCHAR2(1):= ' ';
--    NULL_DBLINK      CONSTANT  VARCHAR2(1) :=MSC_UTIL.NULL_DBLINK;

   v_msc_so_offset_days     NUMBER := NVL(FND_PROFILE.VALUE('MSC_SO_OFFSET_DAYS'),99999);
   v_msc_x_vmi_om_order_type varchar2(50) := FND_PROFILE.VALUE('MSC_X_VMI_OM_ORDER_TYPE');



PROCEDURE LOAD_FORECASTS IS

BEGIN

IF MSC_CL_PULL.FORECAST_ENABLED= MSC_UTIL.SYS_YES THEN

MSC_CL_PULL.v_table_name:= 'MSC_ST_DESIGNATORS';
MSC_CL_PULL.v_view_name := 'MRP_AP_FORECAST_DSGN_V';

v_sql_stmt :=
'insert into MSC_ST_DESIGNATORS'
||'  ( DESIGNATOR,'
||'    FORECAST_SET,'
||'    ORGANIZATION_ID,'
||'    MPS_RELIEF,'
||'    INVENTORY_ATP_FLAG,'
||'    DESCRIPTION,'
||'    DISABLE_DATE,'
||'    DEMAND_CLASS,'
||'    CONSUME_FORECAST,'
||'    UPDATE_TYPE,'
||'    FORWARD_UPDATE_TIME_FENCE,'
||'    BACKWARD_UPDATE_TIME_FENCE,'
||'    OUTLIER_UPDATE_PERCENTAGE,'
||'    CUSTOMER_ID,'
||'    SHIP_ID,'
||'    BILL_ID,'
||'    BUCKET_TYPE,'
||'    DESIGNATOR_TYPE,'
||'    DELETED_FLAG,'
||'    REFRESH_ID,'
||'    SR_INSTANCE_ID)'
||'  select '
||'  x.FORECAST_DESIGNATOR,'
||'  x.FORECAST_SET,'
||'  x.ORGANIZATION_ID,'
||'  x.MPS_RELIEF,'
||'  x.INVENTORY_ATP_FLAG,'
||'  x.DESCRIPTION,'
||'  x.DISABLE_DATE,'
||'  x.DEMAND_CLASS,'
||'  x.CONSUME_FORECAST,'
||'  x.UPDATE_TYPE,'
||'  x.FOREWARD_UPDATE_TIME_FENCE,'
||'  x.BACKWARD_UPDATE_TIME_FENCE,'
||'  x.OUTLIER_UPDATE_PERCENTAGE,'
||'  x.CUSTOMER_ID,'
||'  x.SHIP_ID,'
||'  x.BILL_ID,'
||'  x.BUCKET_TYPE,'
||'  x.DESIGNATOR_TYPE,'
||'  2,'
||'  :v_refresh_id,'
||'  :v_instance_id'
||'  from MRP_AP_FORECAST_DSGN_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'   AND x.RN1>'||MSC_CL_PULL.v_lrn;

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

COMMIT;

-- IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh

MSC_CL_PULL.v_table_name:= 'MSC_ST_DESIGNATORS';
MSC_CL_PULL.v_view_name := 'MRP_AD_FORECAST_DSGN_V';

v_sql_stmt :=
'insert into MSC_ST_DESIGNATORS'
||'  ( DESIGNATOR,'
||'    FORECAST_SET,'
||'    ORGANIZATION_ID,'
||'    DELETED_FLAG,'
||'    REFRESH_ID,'
||'    SR_INSTANCE_ID)'
||'  select '
||'  x.FORECAST_DESIGNATOR,'
||'  x.FORECAST_SET,'
||'  x.ORGANIZATION_ID,'
||'  1,'
||'  :v_refresh_id,'
||'  :v_instance_id'
||'  from MRP_AD_FORECAST_DSGN_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'   AND x.RN> '||MSC_CL_PULL.v_lrn
||' AND x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str;


EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

COMMIT;
-- END IF ; -- Incremental Refresh

END IF;

END LOAD_FORECASTS;


PROCEDURE LOAD_ITEM_FORECASTS IS
BEGIN

IF MSC_CL_PULL.FORECAST_ENABLED = MSC_UTIL.SYS_YES THEN

IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh

MSC_CL_PULL.v_table_name:= 'MSC_ST_DEMANDS';
MSC_CL_PULL.v_view_name := 'MRP_AD_FORECAST_DEMAND_V';

v_sql_stmt :=
'insert into MSC_ST_DEMANDS'
||' (  INVENTORY_ITEM_ID,'
||'    SALES_ORDER_LINE_ID,'
||'    ORIGINATION_TYPE,'
||'    ORGANIZATION_ID,'
||'    FORECAST_DESIGNATOR,'
||'    DELETED_FLAG,'
||'    REFRESH_ID,'
||'    SR_INSTANCE_ID)'
||'  select '
||'    x.INVENTORY_ITEM_ID,'
||'    x.TRANSACTION_ID,'
||'    29,'
||'    x.ORGANIZATION_ID,'
||'    x.forecast_designator,'
||'    1,'
||'    :v_refresh_id,'
||'    :v_instance_id'
||'  from MRP_AD_FORECAST_DEMAND_V'||MSC_CL_PULL.v_dblink||' x'
||'  WHERE x.ORGANIZATION_ID '||MSC_UTIL.v_in_org_str
||'   AND x.RN>'||MSC_CL_PULL.v_lrn;

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

COMMIT;
END IF; -- Incremental Refresh.

MSC_CL_PULL.v_table_name:= 'MSC_ST_DEMANDS';
MSC_CL_PULL.v_view_name := 'MRP_AP_FORECAST_DEMAND_V';

v_sql_stmt:=
'insert into MSC_ST_DEMANDS'
||' (  INVENTORY_ITEM_ID,'
||'    SALES_ORDER_LINE_ID,'
||'    ORGANIZATION_ID,'
||'    USING_ASSEMBLY_ITEM_ID,'
||'    USING_ASSEMBLY_DEMAND_DATE,'
||'    ASSEMBLY_DEMAND_COMP_DATE,'
||'    USING_REQUIREMENT_QUANTITY,'
||'    DEMAND_CLASS,'
||'    ORDER_PRIORITY,'
||'    FORECAST_MAD,'
||'    CONFIDENCE_PERCENTAGE,'
||'    BUCKET_TYPE,'
||'    SOURCE_ORGANIZATION_ID,'
||'    PROJECT_ID,'
||'    TASK_ID,'
||'    CUSTOMER_ID,'
||'    FORECAST_DESIGNATOR,'
||'    DELETED_FLAG,'
||'    ORIGINATION_TYPE,'
||'    DEMAND_TYPE,'
||'    REFRESH_ID,'
||'    PLANNING_GROUP,'
||'    SR_INSTANCE_ID,'
||'    SOURCE_SALES_ORDER_LINE_ID)'
||'  select '
||'    x.INVENTORY_ITEM_ID,'
||'    x.TRANSACTION_ID,'
||'    x.ORGANIZATION_ID,'
||'    x.USING_ASSEMBLY_ID,'
||'    x.FORECAST_DATE,'
||'    x.RATE_END_DATE,'
||'    x.ORIGINAL_FORECAST_QUANTITY,'
||'    x.DEMAND_CLASS,'
||'    TO_NUMBER(DECODE( :v_msc_fcst_priority_flex_num,'
||'            1, x.Attribute1,'
||'            2, x.Attribute2,'
||'            3, x.Attribute3,'
||'            4, x.Attribute4,'
||'            5, x.Attribute5,'
||'            6, x.Attribute6,'
||'            7, x.Attribute7,'
||'            8, x.Attribute8,'
||'            9, x.Attribute9,'
||'            10, x.Attribute10,'
||'            11, x.Attribute11,'
||'            12, x.Attribute12,'
||'            13, x.Attribute13,'
||'            14, x.Attribute14,'
||'            15, x.Attribute15,NULL)),'
||'    x.FORECAST_MAD,'
||'    x.CONFIDENCE_PERCENTAGE,'
||'    x.BUCKET_TYPE,'
||'    x.SOURCE_ORGANIZATION_ID,'
||'    x.PROJECT_ID,'
||'    x.TASK_ID,'
||'    x.CUSTOMER_ID,'
||'    x.FORECAST_DESIGNATOR,'
||'    2,'
||'    x.origination_type,'
||'    x.demand_type,'
||'  :v_refresh_id,'
||'    x.PLANNING_GROUP,'
||'    :v_instance_id,'
||'    x.TRANSACTION_ID '
||'  from MRP_AP_FORECAST_DEMAND_V'||MSC_CL_PULL.v_dblink||' x'
||'  WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'   AND x.RN1>'||MSC_CL_PULL.v_lrn;


EXECUTE IMMEDIATE v_sql_stmt
            USING MSC_CL_PULL.v_msc_fcst_priority_flex_num,
                  MSC_CL_PULL.v_refresh_id,
                  MSC_CL_PULL.v_instance_id;

COMMIT;

END IF;

END LOAD_ITEM_FORECASTS;

--==================================================================

   PROCEDURE LOAD_MDS_DEMAND IS
   BEGIN

IF MSC_CL_PULL.MDS_ENABLED= MSC_UTIL.SYS_YES THEN

--=================== Net Change Mode: Delete ==================

IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh

MSC_CL_PULL.v_table_name:= 'MSC_ST_DEMANDS';
MSC_CL_PULL.v_view_name := 'MRP_AD_MDS_DEMANDS_V';

v_sql_stmt:=
'insert into MSC_ST_DEMANDS'
||' (  DISPOSITION_ID,'
||'    INVENTORY_ITEM_ID,'
||'    ORGANIZATION_ID,'
||'    USING_ASSEMBLY_ITEM_ID,'
||'    ORIGINATION_TYPE,'
||'    DELETED_FLAG,'
||'    REFRESH_ID,'
||'    SR_INSTANCE_ID)'
||'  select'
||'    x.DISPOSITION_ID,'
||'    x.INVENTORY_ITEM_ID,'
||'    x.ORGANIZATION_ID,'
||'    x.USING_ASSEMBLY_ID,'
||'    x.ORIGINATION_TYPE,'
||'    1,'
||'    :v_refresh_id,'
||'    :v_instance_id'
||'  from MRP_AD_MDS_DEMANDS_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.RN>'||MSC_CL_PULL.v_lrn
||' AND x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str;

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

COMMIT;

END IF;

IF (MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115) THEN

	v_temp_sql := 'x.original_system_line_reference,x.original_system_reference,x.demand_source_type,x.demand_class,x.PROMISE_DATE,x.LINK_TO_LINE_ID,x.ORDER_DATE_TYPE_CODE,x.SCHEDULE_ARRIVAL_DATE,x.LATEST_ACCEPTABLE_DATE,x.SHIPPING_METHOD_CODE, ';


       v_temp_sql1 :=   '  TO_NUMBER(DECODE( x.Schedule_Origination_Type, '
				   ||'       2,DECODE(:v_mso_fcst_penalty,'
                                   ||'                1, x.Attribute1,'
                                   ||'                2, x.Attribute2,'
                                   ||'                3, x.Attribute3,'
                                   ||'                4, x.Attribute4,'
                                   ||'                5, x.Attribute5,'
                                   ||'                6, x.Attribute6,'
                                   ||'                7, x.Attribute7,'
                                   ||'                8, x.Attribute8,'
                                   ||'                9, x.Attribute9,'
                                   ||'                10, x.Attribute10,'
                                   ||'                11, x.Attribute11,'
                                   ||'                12, x.Attribute12,'
                                   ||'                13, x.Attribute13,'
                                   ||'                14, x.Attribute14,'
                                   ||'                15, x.Attribute15,NULL),'
                                   ||'       3,x.LATE_DEMAND_PENALTY_FACTOR) ), ';
   ELSE

	IF (MSC_CL_PULL.v_apps_ver = MSC_UTIL.G_APPS110) THEN
		v_temp_sql  :='x.original_system_line_reference ,x.original_system_reference,x.demand_source_type,NULL,x.PROMISE_DATE,NULL,';
	ELSE
		v_temp_sql  :=' NULL, NULL,NULL,NULL,NULL,NULL,NULL, NULL,NULL,NULL, ';
	END IF;

       v_temp_sql1 :=   '  TO_NUMBER(DECODE('
                                   ||'     DECODE(x.Schedule_Origination_Type,'
                                   ||'            2,:v_mso_fcst_penalty,'
                                   ||'            3,:v_mso_so_penalty),'
                                   ||'       1, x.Attribute1,'
                                   ||'       2, x.Attribute2,'
                                   ||'       3, x.Attribute3,'
                                   ||'       4, x.Attribute4,'
                                   ||'       5, x.Attribute5,'
                                   ||'       6, x.Attribute6,'
                                   ||'       7, x.Attribute7,'
                                   ||'       8, x.Attribute8,'
                                   ||'       9, x.Attribute9,'
                                   ||'       10, x.Attribute10,'
                                   ||'       11, x.Attribute11,'
                                   ||'       12, x.Attribute12,'
                                   ||'       13, x.Attribute13,'
                                   ||'       14, x.Attribute14,'
                                   ||'       15, x.Attribute15)),';
     END IF;

MSC_CL_PULL.v_table_name:= 'MSC_ST_DEMANDS';
MSC_CL_PULL.v_view_name := 'MRP_AP_MDS_DEMANDS_V';
IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh
v_union_sql :=
'   AND ( x.RN2>'||MSC_CL_PULL.v_lrn||')'   --NCP: changed to RN2
||' UNION '
||'  select'
||'    x.INVENTORY_ITEM_ID,'
||'    x.ORGANIZATION_ID,'
||'    x.USING_ASSEMBLY_ID,'
||'    x.SCHEDULE_WORKDATE- :v_dgmt,'
||'    x.USING_REQUIREMENTS_QUANTITY,'
||'    x.ASSEMBLY_DEMAND_COMP_DATE -:v_dgmt,'
||'    x.DEMAND_TYPE,'
||'    x.DAILY_DEMAND_RATE,'
||'    x.ORIGINATION_TYPE,'
||'    x.SOURCE_ORGANIZATION_ID,'
||'    x.DISPOSITION_ID,'
||'    x.DISPOSITION_ID,'
||'    x.RESERVATION_ID,'
||'    x.DEMAND_SCHEDULE_NAME,'
||'    x.SALES_ORDER_NUMBER,'
||'    x.PROJECT_ID,'
||'    x.TASK_ID,'
||'    x.PLANNING_GROUP,'
||'    x.END_ITEM_UNIT_NUMBER,'
||'    x.SCHEDULE_DATE- :v_dgmt,'
||'    x.LIST_PRICE,'
|| v_temp_sql1
||'    x.REQUEST_DATE,'
||'     TO_NUMBER(NVL(DECODE(:v_msc_dmd_priority_flex_num,'
                     ||'       1, x.Attribute21,'
                     ||'       2, x.Attribute22,'
                     ||'       3, x.Attribute23,'
                     ||'       4, x.Attribute24,'
                     ||'       5, x.Attribute25,'
                     ||'       6, x.Attribute26,'
                     ||'       7, x.Attribute27,'
                     ||'       8, x.Attribute28,'
                     ||'       9, x.Attribute29,'
                     ||'       10, x.Attribute30,'
                     ||'       11, x.Attribute31,'
                     ||'       12, x.Attribute32,'
                     ||'       13, x.Attribute33,'
                     ||'       14, x.Attribute34,'
                     ||'       15, x.Attribute35),'
                     ||' DECODE(x.Schedule_Origination_Type,'
                     ||' 2, DECODE(:v_msc_fcst_priority_flex_num,'
                     ||'       1, x.Attribute1,'
                     ||'       2, x.Attribute2,'
                     ||'       3, x.Attribute3,'
                     ||'       4, x.Attribute4,'
                     ||'       5, x.Attribute5,'
                     ||'       6, x.Attribute6,'
                     ||'       7, x.Attribute7,'
                     ||'       8, x.Attribute8,'
                     ||'       9, x.Attribute9,'
                     ||'       10, x.Attribute10,'
                     ||'       11, x.Attribute11,'
                     ||'       12, x.Attribute12,'
                     ||'       13, x.Attribute13,'
                     ||'       14, x.Attribute14,'
                     ||'       15, x.Attribute15),'
                     ||' 3, x.SALES_ORDER_PRIORITY))),'
||'    x.SALES_ORDER_LINE_ID,'
||'    x.CUSTOMER_ID,'
||'    x.SHIP_TO_SITE_ID,'
||'    2,'
||     v_temp_sql
||'  :v_refresh_id,'
||'    :v_instance_id'
||'  from MRP_AP_MDS_DEMANDS_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'   AND ( x.RN3>'||MSC_CL_PULL.v_lrn||')';   --NCP: changed to RN3

ELSE
v_union_sql :=
'   AND (x.RN1>'||MSC_CL_PULL.v_lrn
||'    OR x.RN2>'||MSC_CL_PULL.v_lrn
||'    OR x.RN3>'||MSC_CL_PULL.v_lrn
||'    OR x.RN4>'||MSC_CL_PULL.v_lrn||')';

END IF;

v_sql_stmt:=
'insert into MSC_ST_DEMANDS'
||' (  INVENTORY_ITEM_ID,'
||'    ORGANIZATION_ID,'
||'    USING_ASSEMBLY_ITEM_ID,'
||'    USING_ASSEMBLY_DEMAND_DATE,'
||'    USING_REQUIREMENT_QUANTITY,'
||'    ASSEMBLY_DEMAND_COMP_DATE,'
||'    DEMAND_TYPE,'
||'    DAILY_DEMAND_RATE,'
||'    ORIGINATION_TYPE,'
||'    SOURCE_ORGANIZATION_ID,'
||'    DISPOSITION_ID,'
||'    SOURCE_DISPOSITION_ID,'
||'    RESERVATION_ID,'
||'    DEMAND_SCHEDULE_NAME,'
||'    ORDER_NUMBER,'
||'    PROJECT_ID,'
||'    TASK_ID,'
||'    PLANNING_GROUP,'
||'    END_ITEM_UNIT_NUMBER,'
||'    SCHEDULE_DATE,'
||'    SELLING_PRICE,'
||'    DMD_LATENESS_COST,'
||'    REQUEST_DATE,'
||'    ORDER_PRIORITY,'
||'    SALES_ORDER_LINE_ID,'
||'    CUSTOMER_ID,'
||'    SHIP_TO_SITE_ID,'
||'    DELETED_FLAG,'
||'    ORIGINAL_SYSTEM_LINE_REFERENCE,'
||'    ORIGINAL_SYSTEM_REFERENCE,'
||'    DEMAND_SOURCE_TYPE,'
||'    DEMAND_CLASS,'
||'    PROMISE_DATE,'
||'    LINK_TO_LINE_ID,'
||'    ORDER_DATE_TYPE_CODE,'
||'    SCHEDULE_ARRIVAL_DATE,'
||'    LATEST_ACCEPTABLE_DATE,'
||'    SHIPPING_METHOD_CODE,'
||'    REFRESH_ID,'
||'    SR_INSTANCE_ID)'
||'  select'
||'    x.INVENTORY_ITEM_ID,'
||'    x.ORGANIZATION_ID,'
||'    x.USING_ASSEMBLY_ID,'
||'    x.SCHEDULE_WORKDATE- :v_dgmt,'
||'    x.USING_REQUIREMENTS_QUANTITY,'
||'    x.ASSEMBLY_DEMAND_COMP_DATE -:v_dgmt,'
||'    x.DEMAND_TYPE,'
||'    x.DAILY_DEMAND_RATE,'
||'    x.ORIGINATION_TYPE,'
||'    x.SOURCE_ORGANIZATION_ID,'
||'    x.DISPOSITION_ID,'
||'    x.DISPOSITION_ID,'
||'    x.RESERVATION_ID,'
||'    x.DEMAND_SCHEDULE_NAME,'
||'    x.SALES_ORDER_NUMBER,'
||'    x.PROJECT_ID,'
||'    x.TASK_ID,'
||'    x.PLANNING_GROUP,'
||'    x.END_ITEM_UNIT_NUMBER,'
||'    x.SCHEDULE_DATE- :v_dgmt,'
||'    x.LIST_PRICE,'
||    v_temp_sql1
||'    x.REQUEST_DATE,'
||'     TO_NUMBER(NVL(DECODE(:v_msc_dmd_priority_flex_num,'
                     ||'       1, x.Attribute21,'
                     ||'       2, x.Attribute22,'
                     ||'       3, x.Attribute23,'
                     ||'       4, x.Attribute24,'
                     ||'       5, x.Attribute25,'
                     ||'       6, x.Attribute26,'
                     ||'       7, x.Attribute27,'
                     ||'       8, x.Attribute28,'
                     ||'       9, x.Attribute29,'
                     ||'       10, x.Attribute30,'
                     ||'       11, x.Attribute31,'
                     ||'       12, x.Attribute32,'
                     ||'       13, x.Attribute33,'
                     ||'       14, x.Attribute34,'
                     ||'       15, x.Attribute35),'
                     ||' DECODE(x.Schedule_Origination_Type,'
                     ||' 2, DECODE(:v_msc_fcst_priority_flex_num,'
                     ||'       1, x.Attribute1,'
                     ||'       2, x.Attribute2,'
                     ||'       3, x.Attribute3,'
                     ||'       4, x.Attribute4,'
                     ||'       5, x.Attribute5,'
                     ||'       6, x.Attribute6,'
                     ||'       7, x.Attribute7,'
                     ||'       8, x.Attribute8,'
                     ||'       9, x.Attribute9,'
                     ||'       10, x.Attribute10,'
                     ||'       11, x.Attribute11,'
                     ||'       12, x.Attribute12,'
                     ||'       13, x.Attribute13,'
                     ||'       14, x.Attribute14,'
                     ||'       15, x.Attribute15),'
                     ||' 3, x.SALES_ORDER_PRIORITY))),'
||'    x.SALES_ORDER_LINE_ID,'
||'    x.CUSTOMER_ID,'
||'    x.SHIP_TO_SITE_ID,'
||'    2,'
||     v_temp_sql
||'  :v_refresh_id,'
||'    :v_instance_id'
||'  from MRP_AP_MDS_DEMANDS_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
|| v_union_sql ;

IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh
    IF (MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115) THEN
        EXECUTE IMMEDIATE v_sql_stmt
                    USING MSC_CL_PULL.v_dgmt,
                          MSC_CL_PULL.v_dgmt,
                          MSC_CL_PULL.v_dgmt,
                          MSC_CL_PULL.v_mso_fcst_penalty,
                          MSC_CL_PULL.v_msc_dmd_priority_flex_num,
                          MSC_CL_PULL.v_msc_fcst_priority_flex_num,
                          MSC_CL_PULL.v_refresh_id,
                          MSC_CL_PULL.v_instance_id,
                          MSC_CL_PULL.v_dgmt,
                          MSC_CL_PULL.v_dgmt,
                          MSC_CL_PULL.v_dgmt,
                          MSC_CL_PULL.v_mso_fcst_penalty,
                          MSC_CL_PULL.v_msc_dmd_priority_flex_num,
                          MSC_CL_PULL.v_msc_fcst_priority_flex_num,
                          MSC_CL_PULL.v_refresh_id,
                          MSC_CL_PULL.v_instance_id;
    ELSE
        EXECUTE IMMEDIATE v_sql_stmt
                    USING MSC_CL_PULL.v_dgmt,
                          MSC_CL_PULL.v_dgmt,
                          MSC_CL_PULL.v_dgmt,
                          MSC_CL_PULL.v_mso_fcst_penalty,
                          MSC_CL_PULL.v_mso_so_penalty,
                          MSC_CL_PULL.v_msc_dmd_priority_flex_num,
                          MSC_CL_PULL.v_msc_fcst_priority_flex_num,
                          MSC_CL_PULL.v_refresh_id,
                          MSC_CL_PULL.v_instance_id,
                          MSC_CL_PULL.v_dgmt,
                          MSC_CL_PULL.v_dgmt,
                          MSC_CL_PULL.v_dgmt,
                          MSC_CL_PULL.v_mso_fcst_penalty,
                          MSC_CL_PULL.v_mso_so_penalty,
                          MSC_CL_PULL.v_msc_dmd_priority_flex_num,
                          MSC_CL_PULL.v_msc_fcst_priority_flex_num,
                          MSC_CL_PULL.v_refresh_id,
                          MSC_CL_PULL.v_instance_id;
   END IF;

ELSE  -- Targeted - Complete Refresh collections
    IF (MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115) THEN
        EXECUTE IMMEDIATE v_sql_stmt
                    USING MSC_CL_PULL.v_dgmt,
                          MSC_CL_PULL.v_dgmt,
                          MSC_CL_PULL.v_dgmt,
                          MSC_CL_PULL.v_mso_fcst_penalty,
                          MSC_CL_PULL.v_msc_dmd_priority_flex_num,
                          MSC_CL_PULL.v_msc_fcst_priority_flex_num,
                          MSC_CL_PULL.v_refresh_id,
                          MSC_CL_PULL.v_instance_id;
    ELSE
        EXECUTE IMMEDIATE v_sql_stmt
                    USING MSC_CL_PULL.v_dgmt,
                          MSC_CL_PULL.v_dgmt,
                          MSC_CL_PULL.v_dgmt,
                          MSC_CL_PULL.v_mso_fcst_penalty,
                          MSC_CL_PULL.v_mso_so_penalty,
                          MSC_CL_PULL.v_msc_dmd_priority_flex_num,
                          MSC_CL_PULL.v_msc_fcst_priority_flex_num,
                          MSC_CL_PULL.v_refresh_id,
                          MSC_CL_PULL.v_instance_id;
    END IF;

END IF;

COMMIT;

END IF;   -- MSC_CL_PULL.MDS_ENABLED

END LOAD_MDS_DEMAND;


PROCEDURE LOAD_SALES_ORDER ( p_worker_num IN NUMBER ) IS
lv_temp_sql   VARCHAR2(1024);
v_select_sql varchar2(100);
BEGIN

v_union_sql := '  ';
v_temp_sql4 := NULL;

if(MSC_CL_PULL.v_apps_ver>= MSC_UTIL.G_APPS115) then
	v_temp_sql1:='x.SCHEDULE_ARRIVAL_DATE,x.LATEST_ACCEPTABLE_DATE,x.SHIPPING_METHOD_CODE,x.ATO_LINE_ID,x.ORDER_DATE_TYPE_CODE,x.DELIVERY_LEAD_TIME ';
else
	v_temp_sql1:='NULL,NULL,NULL,NULL,NULL,NULL ';
end if;


IF ( p_worker_num = 3) THEN

   IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh

        MSC_CL_PULL.v_table_name:= 'MSC_ST_SALES_ORDERS';
        MSC_CL_PULL.v_view_name := 'MRP_AD_SALES_ORDERS_V';

        Begin

        IF MSC_CL_PULL.v_apps_ver = MSC_UTIL.G_APPS107 THEN
        	v_temp_sql:= ' 2 ,';
        ELSE
          v_temp_sql:= ' x.CTO_FLAG,';
        END IF ;


        End;
        /*Added By raraghav */

        IF MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 THEN
           lv_temp_sql := ' AND x.ORGANIZATION_ID '||MSC_UTIL.v_in_org_str;
        ELSE
           lv_temp_sql := NULL;
        END IF;

        v_sql_stmt:=
        'insert into MSC_ST_SALES_ORDERS'
        ||'  ( DEMAND_ID,'
        ||'    ROW_TYPE,'
        ||'    PARENT_DEMAND_ID,'
        ||'    DELETED_FLAG,'
        ||'    RESERVATION_TYPE,'
        ||'    CTO_FLAG,'
        ||'    REFRESH_ID,'
        ||'    SR_INSTANCE_ID)'
        ||'  select'
        ||'    x.DEMAND_ID,'
        ||'    x.ROW_TYPE,' --row type
        ||'    x.PARENT_DEMAND_ID,'
        ||'    1,'
        ||'    2,'
        ||'    2,'
        ||'    :v_refresh_id,'
        ||'    :v_instance_id'
        ||'  from MRP_AD_HARD_RESERVATIONS_V'||MSC_CL_PULL.v_dblink||' x'
        ||'  where x.RN> :v_lrn '
        || lv_temp_sql;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,v_sql_stmt);
        EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id, MSC_CL_PULL.v_lrn;

        COMMIT;

        v_sql_stmt:=
        'insert into MSC_ST_SALES_ORDERS'
        ||'  ( DEMAND_ID,'
        ||'    ROW_TYPE,'
        ||'    PARENT_DEMAND_ID,'
        ||'    DELETED_FLAG,'
        ||'    RESERVATION_TYPE,'
        ||'    CTO_FLAG,'
        ||'    REFRESH_ID,'
        ||'    SR_INSTANCE_ID)'
        ||'  select'
        ||'    x.DEMAND_ID,'
        ||'    x.ROW_TYPE,'
        ||'    x.PARENT_DEMAND_ID,'
        ||'    1,'
        ||'    1,'
        ||     v_temp_sql
        ||'    :v_refresh_id,'
        ||'    :v_instance_id'
        ||'  from MRP_AD_SALES_ORDERS_V'||MSC_CL_PULL.v_dblink||' x'
        ||' WHERE x.RN> :v_lrn '
        || lv_temp_sql;
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,v_sql_stmt);
        EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id, MSC_CL_PULL.v_lrn;

        COMMIT;

    END IF;       --- MSC_CL_PULL.v_lrnn<> -1

  MSC_CL_PULL.v_table_name:= 'MSC_ST_SALES_ORDERS';

    IF MSC_CL_PULL.v_apps_ver < MSC_UTIL.G_APPS115 THEN        -- 107 or 110 source instance
            MSC_CL_PULL.v_view_name := 'MRP_AP_SALES_ORDERS_V';
            v_temp_sql3 := '   AND (x.RN1 > :v_lrn OR x.RN2> :v_lrn  OR x.RN3> :v_lrn )';

                            /* Changed for the fix 2521038,  */
            v_temp_sql2 := ' AND (x.PRIMARY_UOM_QUANTITY > x.COMPLETED_QUANTITY '
                         ||'      OR (x.PRIMARY_UOM_QUANTITY =  x.COMPLETED_QUANTITY '
                         ||' AND x.requirement_date >=  trunc(sysdate - (' || v_msc_so_offset_days ||' )))) ';

	    v_temp_sql := '  NULL, NULL, NULL,NULL, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL, ';

    ELSE     -- 11i source instance



            v_temp_sql  :=   ' x.END_ITEM_UNIT_NUMBER , x.ordered_item_id,x.ORIGINAL_INVENTORY_ITEM_ID, '
                          || ' x.LINK_TO_LINE_ID, x.cust_po_number,x.customer_line_number, x.MFG_LEAD_TIME, x.FIRM_DEMAND_FLAG, x.SHIP_SET_ID, x.ARRIVAL_SET_ID, x.SHIP_SET_NAME, x.ARRIVAL_SET_NAME, ';


           IF (MSC_CL_PULL.v_lrnn <> -1) THEN       -- incremental collections
               v_temp_sql2 :=   ' AND (x.ORIGINAL_ORDERED_QUANTITY >= x.ORIGINAL_COMPLETED_QUANTITY) ';
              MSC_CL_PULL.v_view_name := 'MRP_AN3_SALES_ORDERS_V';
              v_temp_sql3 := '   AND (x.RN1 > :v_lrn OR x.RN2> :v_lrn  )';

           ELSE                         --- complete/targeted collections
              v_temp_sql2 :=   ' AND (x.ORIGINAL_ORDERED_QUANTITY > x.ORIGINAL_COMPLETED_QUANTITY '
                           ||'   OR (x.ORIGINAL_ORDERED_QUANTITY =  x.ORIGINAL_COMPLETED_QUANTITY '
                           ||' AND x.requirement_date >=  trunc(sysdate - (' || v_msc_so_offset_days ||' )))) ';
              MSC_CL_PULL.v_view_name := 'MRP_AP3_SALES_ORDERS_V';
              v_temp_sql3 := '   ';
           END IF;
    END IF;


ELSIF ( p_worker_num in (1,2) ) THEN

     MSC_CL_PULL.v_table_name:= 'MSC_ST_SALES_ORDERS';

     IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh
         MSC_CL_PULL.v_view_name := 'MRP_AN'||p_worker_num||'_SALES_ORDERS_V';

       if p_worker_num <> 2  then
          if p_worker_num = 1 then
            v_temp_sql3 := '   AND (x.RN1 > :v_lrn OR x.RN2> :v_lrn  OR x.RN3> :v_lrn )';
/*          elsif p_worker_num = 3 then
            v_temp_sql3 := '   AND (x.RN1 > :v_lrn OR x.RN2> :v_lrn )'; */
          end if;


       elsif (p_worker_num = 2) then


  		  		v_temp_sql2 :=  '  ';

          v_union_sql :=
          ' UNION  '
          ||' SELECT  /*+ first_rows leading(x.msik) use_nl(x.msik x.ool) */ '
          ||'    x.INVENTORY_ITEM_ID,'
          ||'    x.INVENTORY_ITEM_ID,'
          ||'    x.ORGANIZATION_ID,'
          ||'    x.PRIMARY_UOM_QUANTITY,'
          ||'    x.RESERVATION_TYPE,'
          ||'    x.RESERVATION_QUANTITY,'
          ||'    x.DEMAND_SOURCE_TYPE,'
          ||'    x.DEMAND_SOURCE_HEADER_ID,'
          ||'    x.COMPLETED_QUANTITY,'
          ||'    x.SUBINVENTORY,'
          ||'    x.DEMAND_CLASS,'
          ||'    x.REQUIREMENT_DATE,'
          ||'    x.DEMAND_SOURCE_LINE,'
          ||'    x.DEMAND_SOURCE_LINE,'
          ||'    x.DEMAND_SOURCE_DELIVERY,'
          ||'    x.DEMAND_SOURCE_NAME,'
          ||'    x.DEMAND_ID,'
          ||'    x.ROW_TYPE,'
          ||'    x.DEMAND_ID,'
          ||'    x.PARENT_DEMAND_ID,'
          ||'    x.SALES_ORDER_NUMBER,'
          ||'    x.FORECAST_VISIBLE,'
          ||'    x.DEMAND_VISIBLE,'
          ||'    x.SALESREP_CONTACT,';

          if MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 then
             v_union_sql := v_union_sql ||'   x.SALESREP_ID,';
          else
             v_union_sql := v_union_sql ||'   NULL,';
          end if;

          v_union_sql := v_union_sql
          ||'    x.CUSTOMER_ID,'
          ||'    x.SHIP_TO_SITE_ID,'
          ||'    x.BILL_TO_SITE_ID,'
          ||'    x.REQUEST_DATE,'
          ||'    x.PROJECT_ID,'
          ||'    x.TASK_ID,'
          ||'    x.PLANNING_GROUP,'
          ||'    x.LIST_PRICE,'
    	  ||'    x.END_ITEM_UNIT_NUMBER , '
    	  ||'    x.ordered_item_id, '
    	  ||'    x.ORIGINAL_INVENTORY_ITEM_ID , '
          ||'    x.LINK_TO_LINE_ID ,'
          ||'    x.CUST_PO_NUMBER,'
          ||'    x.CUSTOMER_LINE_NUMBER,'
    	  ||'    x.MFG_LEAD_TIME,'
    	  ||'    x.FIRM_DEMAND_FLAG,'
    	  ||'    x.SHIP_SET_ID,'
    	  ||'    x.ARRIVAL_SET_ID,'
          ||'    x.SHIP_SET_NAME,'
          ||'    x.ARRIVAL_SET_NAME,'
          ||'    x.RN2,'
          ||'    2,'
    	  ||'    x.original_system_line_reference , '
    	  ||'    x.original_system_reference  ,'
          ||'    x.CTO_FLAG,'
          ||'    x.AVAILABLE_TO_MRP,'
          ||'    x.DEMAND_PRIORITY,'
          ||'    x.PROMISE_DATE,'
          ||'    :v_refresh_id,'
          ||'    :v_instance_id, '
    	  ||   v_temp_sql1
          ||' FROM  '||MSC_CL_PULL.v_view_name||MSC_CL_PULL.v_dblink||' x'
          ||' WHERE x.ORGANIZATION_ID '||MSC_UTIL.v_in_org_str
          ||  v_temp_sql2
          ||'  and ( x.rn2 > :v_lrn ) ' ;

            v_temp_sql3 := '   AND (x.RN1 > :v_lrn )  ';

       end if;

    ELSE
         MSC_CL_PULL.v_view_name := 'MRP_AP'||p_worker_num||'_SALES_ORDERS_V';
         v_temp_sql3 := '   ';

   END IF;

     v_temp_sql  := ' x.END_ITEM_UNIT_NUMBER , x.ordered_item_id,x.ORIGINAL_INVENTORY_ITEM_ID , '
                  ||' x.LINK_TO_LINE_ID, x.cust_po_number,x.customer_line_number,x.MFG_LEAD_TIME,x.FIRM_DEMAND_FLAG,x.SHIP_SET_ID,x.ARRIVAL_SET_ID,x.SHIP_SET_NAME,x.ARRIVAL_SET_NAME, ';

     IF (p_worker_num = 2 AND         -- Bug 4245915
         MSC_CL_PULL.v_apps_ver>= MSC_UTIL.G_APPS120) THEN --bug#5684183 (bcaru)
       v_temp_sql4 := ' AND ( x.visible_demand_flag = ''Y'' OR (x.visible_demand_flag = ''N'' AND x.order_type='''||v_msc_x_vmi_om_order_type||''')) ';
     END IF;

END IF;  --- (p_worker_num = 4 ) condition


IF (MSC_CL_PULL.v_apps_ver= MSC_UTIL.G_APPS110 OR
    MSC_CL_PULL.v_apps_ver>= MSC_UTIL.G_APPS115) THEN

/*   Changed for the fix 2521038, note the views MRP_AP_SALES_ORDERS_V and MRP_AN_SALES_ORDERS_V
     have also been changed for this. Only if the source is 115 the new columns ORIGINAL_ORDERED_QUANTITY,
     ORIGINAL_COMPLETED_QUANTITY are applicable.
*/

IF MSC_CL_PULL.v_apps_ver = MSC_UTIL.G_APPS110 THEN

     v_temp_sql2 := ' AND (x.PRIMARY_UOM_QUANTITY > x.COMPLETED_QUANTITY '
     ||'      OR (x.PRIMARY_UOM_QUANTITY =  x.COMPLETED_QUANTITY ';

     v_temp_sql2 := v_temp_sql2 ||' AND x.requirement_date >= trunc( sysdate - (' || v_msc_so_offset_days ||' )))) ';

END IF; /* MSC_UTIL.G_APPS110 */

IF MSC_CL_PULL.v_apps_ver>= MSC_UTIL.G_APPS115 AND (p_worker_num <> 2) THEN
    IF (MSC_CL_PULL.v_lrnn <> -1) THEN       -- incremental collections
			v_temp_sql2 :=   ' AND (x.ORIGINAL_ORDERED_QUANTITY >= x.ORIGINAL_COMPLETED_QUANTITY) ';

		ELSE
    v_temp_sql2 := 'AND (x.ORIGINAL_ORDERED_QUANTITY > x.ORIGINAL_COMPLETED_QUANTITY '
                   ||'      OR (x.ORIGINAL_ORDERED_QUANTITY =  x.ORIGINAL_COMPLETED_QUANTITY ';

    v_temp_sql2 := v_temp_sql2 ||' AND x.requirement_date >=  trunc(sysdate - (' || v_msc_so_offset_days ||' )))) ';

    END IF ;

END IF;

     IF (p_worker_num = 2) AND (v_msc_so_offset_days = 99999 ) THEN
	 /* This will handle AP2 and AN2 - first union */
		 v_temp_sql2 :=  '  ';
     END IF;

IF MSC_CL_PULL.v_view_name = 'MRP_AP2_SALES_ORDERS_V' THEN /* Bug 3019053 */
     v_temp_sql2 :=  '  ';
END IF;

IF MSC_CL_PULL.v_view_name = 'MRP_AN2_SALES_ORDERS_V' THEN
     v_select_sql := ' SELECT /*+ index( x.ool oe_odr_lines_sn_n1) */ ';
ELSE
     v_select_sql := ' SELECT ';
END IF;

	v_sql_stmt:=
	'INSERT INTO MSC_ST_SALES_ORDERS'
	||'  ( INVENTORY_ITEM_ID,'
	||'    SOURCE_INVENTORY_ITEM_ID,'
	||'    ORGANIZATION_ID,'
	||'    PRIMARY_UOM_QUANTITY,'
	||'    RESERVATION_TYPE,'
	||'    RESERVATION_QUANTITY,'
	||'    DEMAND_SOURCE_TYPE,'
	||'    DEMAND_SOURCE_HEADER_ID,'
	||'    COMPLETED_QUANTITY,'
	||'    SUBINVENTORY,'
	||'    DEMAND_CLASS,'
	||'    REQUIREMENT_DATE,'
	||'    DEMAND_SOURCE_LINE,'
	||'    SOURCE_DEMAND_SOURCE_LINE,'
	||'    DEMAND_SOURCE_DELIVERY,'
	||'    DEMAND_SOURCE_NAME,'
	||'    DEMAND_ID,'
	||'    ROW_TYPE,'
	||'    SOURCE_DEMAND_ID,'
	||'    PARENT_DEMAND_ID,'
	||'    SALES_ORDER_NUMBER,'
	||'    FORECAST_VISIBLE,'
	||'    DEMAND_VISIBLE,'
	||'    SALESREP_CONTACT,'
	||'    SALESREP_ID,'
	||'    CUSTOMER_ID,'
	||'    SHIP_TO_SITE_USE_ID,'
	||'    BILL_TO_SITE_USE_ID,'
	||'    REQUEST_DATE,'
	||'    PROJECT_ID,'
	||'    TASK_ID,'
	||'    PLANNING_GROUP,'
	||'    SELLING_PRICE,'
	||'    END_ITEM_UNIT_NUMBER,'
	||'    ORDERED_ITEM_ID,'
	||'    ORIGINAL_ITEM_ID,'
	||'    LINK_TO_LINE_ID ,'
	||'    CUST_PO_NUMBER,'
	||'    CUSTOMER_LINE_NUMBER,'
	||'    MFG_LEAD_TIME,'
	||'    ORG_FIRM_FLAG,'
	||'    SHIP_SET_ID,'
	||'    ARRIVAL_SET_ID,'
        ||'    SHIP_SET_NAME,'
        ||'    ARRIVAL_SET_NAME,'
	||'    ATP_REFRESH_NUMBER,'
	||'    DELETED_FLAG,'
	||'    ORIGINAL_SYSTEM_LINE_REFERENCE,'
	||'    ORIGINAL_SYSTEM_REFERENCE,'
	||'    CTO_FLAG,'
	||'    AVAILABLE_TO_MRP,'
	||'    DEMAND_PRIORITY,'
	||'    PROMISE_DATE,'
	||'    REFRESH_ID,'
	||'    SR_INSTANCE_ID,'
	||'    SCHEDULE_ARRIVAL_DATE,'
	||'    LATEST_ACCEPTABLE_DATE,'
	||'    SHIPPING_METHOD_CODE,'
	||'    ATO_LINE_ID,'
	||'    ORDER_DATE_TYPE_CODE,'
	||'    INTRANSIT_LEAD_TIME)'
	||v_select_sql
	||'    x.INVENTORY_ITEM_ID,'
	||'    x.INVENTORY_ITEM_ID,'
	||'    x.ORGANIZATION_ID,'
	||'    x.PRIMARY_UOM_QUANTITY,'
	||'    x.RESERVATION_TYPE,'
	||'    x.RESERVATION_QUANTITY,'
	||'    x.DEMAND_SOURCE_TYPE,'
	||'    x.DEMAND_SOURCE_HEADER_ID,'
	||'    x.COMPLETED_QUANTITY,'
	||'    x.SUBINVENTORY,'
	||'    x.DEMAND_CLASS,'
	||'    x.REQUIREMENT_DATE,'
	||'    x.DEMAND_SOURCE_LINE,'
	||'    x.DEMAND_SOURCE_LINE,'
	||'    x.DEMAND_SOURCE_DELIVERY,'
	||'    x.DEMAND_SOURCE_NAME,'
	||'    x.DEMAND_ID,'
	||'    x.ROW_TYPE,'
	||'    x.DEMAND_ID,'
	||'    x.PARENT_DEMAND_ID,'
||'    x.SALES_ORDER_NUMBER,'
||'    x.FORECAST_VISIBLE,'
||'    x.DEMAND_VISIBLE,'
||'    x.SALESREP_CONTACT,';

     if MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 then
        v_sql_stmt := v_sql_stmt ||'   x.SALESREP_ID,';
     else
        v_sql_stmt := v_sql_stmt ||'   NULL,';
     end if;

     v_sql_stmt := v_sql_stmt
||'    x.CUSTOMER_ID,'
||'    x.SHIP_TO_SITE_ID,'
||'    x.BILL_TO_SITE_ID,'
||'    x.REQUEST_DATE,'
||'    x.PROJECT_ID,'
||'    x.TASK_ID,'
||'    x.PLANNING_GROUP,'
||'    x.LIST_PRICE,'
||     v_temp_sql
||'    x.RN1,'
||'    2,'
||'    x.ORIGINAL_SYSTEM_LINE_REFERENCE,'
||'    x.ORIGINAL_SYSTEM_REFERENCE,'
||'    x.CTO_FLAG,'
||'    x.AVAILABLE_TO_MRP,'
||'    x.DEMAND_PRIORITY,'
||'    x.PROMISE_DATE,'
||'    :v_refresh_id,'
||'    :v_instance_id,'
||  v_temp_sql1
||' FROM  '||MSC_CL_PULL.v_view_name||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||  v_temp_sql2
||  v_temp_sql3
||  v_temp_sql4
||  v_union_sql ;

    IF MSC_CL_PULL.v_apps_ver < MSC_UTIL.G_APPS115 THEN
          MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,v_sql_stmt);
           EXECUTE IMMEDIATE v_sql_stmt
		       USING MSC_CL_PULL.v_refresh_id,
			     MSC_CL_PULL.v_instance_id,
			     MSC_CL_PULL.v_lrn,
			     MSC_CL_PULL.v_lrn,
			     MSC_CL_PULL.v_lrn;

    ELSE     -- 11i source instance

           IF (MSC_CL_PULL.v_lrnn <> -1) THEN       -- incremental collections
              if (p_worker_num = 2) then
                    MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_2,v_sql_stmt);
                 EXECUTE IMMEDIATE v_sql_stmt
			     USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id, MSC_CL_PULL.v_lrn,
				   MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id, MSC_CL_PULL.v_lrn;
              elsif (p_worker_num in (3)) then
                  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_2,v_sql_stmt);
                 EXECUTE IMMEDIATE v_sql_stmt USING
                        MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id
                                               ,MSC_CL_PULL.v_lrn,MSC_CL_PULL.v_lrn;

               else
                  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_2,v_sql_stmt);
                 EXECUTE IMMEDIATE v_sql_stmt
			     USING MSC_CL_PULL.v_refresh_id,
				   MSC_CL_PULL.v_instance_id,
				   MSC_CL_PULL.v_lrn,
				   MSC_CL_PULL.v_lrn,
				   MSC_CL_PULL.v_lrn;
              end if;

           ELSE                         --- complete/targeted collections
                MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_2,v_sql_stmt);
                EXECUTE IMMEDIATE v_sql_stmt
		            USING MSC_CL_PULL.v_refresh_id,
				  MSC_CL_PULL.v_instance_id;
           END IF;
    END IF;

ELSE  -- 107 source instance

v_sql_stmt:=
'INSERT INTO MSC_ST_SALES_ORDERS'
||'  ( INVENTORY_ITEM_ID,'
||'    ORGANIZATION_ID,'
||'    PRIMARY_UOM_QUANTITY,'
||'    RESERVATION_TYPE,'
||'    RESERVATION_QUANTITY,'
||'    DEMAND_SOURCE_TYPE,'
||'    DEMAND_SOURCE_HEADER_ID,'
||'    COMPLETED_QUANTITY,'
||'    SUBINVENTORY,'
||'    DEMAND_CLASS,'
||'    REQUIREMENT_DATE,'
||'    DEMAND_SOURCE_LINE,'
||'    DEMAND_SOURCE_DELIVERY,'
||'    DEMAND_SOURCE_NAME,'
||'    DEMAND_ID,'
||'    ROW_TYPE,'
||'    PARENT_DEMAND_ID,'
||'    SALES_ORDER_NUMBER,'
||'    SALESREP_CONTACT,'
||'    CUSTOMER_ID,'
||'    SHIP_TO_SITE_USE_ID,'
||'    BILL_TO_SITE_USE_ID,'
||'    ATP_REFRESH_NUMBER,'
||'    DELETED_FLAG,'
||'    REFRESH_ID,'
||'    PROJECT_ID,'
||'    TASK_ID,'
||'    PLANNING_GROUP,'
||'    SR_INSTANCE_ID)'
||' SELECT'
||'    x.INVENTORY_ITEM_ID,'
||'    x.ORGANIZATION_ID,'
||'    x.PRIMARY_UOM_QUANTITY,'
||'    x.RESERVATION_TYPE,'
||'    x.RESERVATION_QUANTITY,'
||'    x.DEMAND_SOURCE_TYPE,'
||'    x.DEMAND_SOURCE_HEADER_ID,'
||'    x.COMPLETED_QUANTITY,'
||'    x.SUBINVENTORY,'
||'    x.DEMAND_CLASS,'
||'    x.REQUIREMENT_DATE,'
||'    x.DEMAND_SOURCE_LINE,'
||'    x.DEMAND_SOURCE_DELIVERY,'
||'    x.DEMAND_SOURCE_NAME,'
||'    x.DEMAND_ID,'
||'    x.ROW_TYPE,'
||'    x.PARENT_DEMAND_ID,'
||'    x.SALES_ORDER_NUMBER,'
||'    x.SALESREP_CONTACT,'
||'    x.CUSTOMER_ID,'
||'    x.SHIP_TO_SITE_ID,'
||'    x.BILL_TO_SITE_ID,'
||'    x.RN1,'
||'    2,'
||'    :v_refresh_id,'
||'    x.PROJECT_ID,'
||'    x.TASK_ID,'
||'    x.PLANNING_GROUP,'
||'    :v_instance_id'
||' FROM MRP_AP_SALES_ORDERS_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'   AND (x.RN1>'||MSC_CL_PULL.v_lrn
||'    OR x.RN2>'||MSC_CL_PULL.v_lrn
||'    OR x.RN3>'||MSC_CL_PULL.v_lrn||')';

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_2,v_sql_stmt);
EXECUTE IMMEDIATE v_sql_stmt USING  MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

END IF;
COMMIT;
END LOAD_SALES_ORDER;


--==================================================================

PROCEDURE LOAD_HARD_RESERVATION IS
   BEGIN

IF MSC_CL_PULL.HARD_RESRVS_ENABLED= MSC_UTIL.SYS_YES THEN

    IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh

    MSC_CL_PULL.v_table_name:= 'MSC_ST_RESERVATIONS';
    MSC_CL_PULL.v_view_name := 'MRP_AD_HARD_RESERVATIONS_V';

        IF MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 THEN
           v_temp_sql := ' AND x.ORGANIZATION_ID '||MSC_UTIL.v_in_org_str;
        ELSE
           v_temp_sql := NULL;
        END IF;

        v_sql_stmt:=
        'insert into MSC_ST_RESERVATIONS'
        ||'  ( TRANSACTION_ID,'
        ||'    PARENT_DEMAND_ID,'
        ||'    DELETED_FLAG,'
        ||'    REFRESH_ID,'
        ||'    SR_INSTANCE_ID)'
        ||'  select'
        ||'    x.DEMAND_ID,'
        ||'    x.PARENT_DEMAND_ID,'
        ||'    1,'
        ||'    :v_refresh_id,'
        ||'    :v_instance_id'
        ||'  from MRP_AD_HARD_RESERVATIONS_V'||MSC_CL_PULL.v_dblink||' x'
        ||' WHERE x.RN>'||MSC_CL_PULL.v_lrn
        || v_temp_sql;

        EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

        COMMIT;
        /* Changes For Bug 6147734 */
         if (MSC_UTIL.G_COLLECT_SRP_DATA='Y' AND MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS120) Then
                  v_sql_stmt:=
                  'insert into MSC_ST_RESERVATIONS'
                    ||'  ( TRANSACTION_ID,'
                    ||'    SUPPLY_SOURCE_TYPE_ID,'
                    ||'    ORGANIZATION_ID,'
                    ||'    INVENTORY_ITEM_ID,'
                    ||'    DISPOSITION_TYPE,'
                    ||'    DISPOSITION_ID,'
                    ||'    ORDER2_ORGANIZATION_ID,'
                    ||'    ORDER2_INVENTORY_ITEM_ID,'
                    ||'    DELETED_FLAG,'
                    ||'    REFRESH_ID,'
                    ||'    SR_INSTANCE_ID)'
                    ||'  select'
                    ||'    x.TRANSACTION_ID,'
                    ||'    x.SUPPLY_SOURCE_TYPE_ID,'
                    ||'    x.ORGANIZATION_ID,'
                    ||'    x.INVENTORY_ITEM_ID,'
                    ||'    x.DISPOSITION_TYPE,'
                    ||'    x.DISPOSITION_ID,'
                    ||'    x.ORDER2_ORGANIZATION_ID,'
                    ||'    x.ORDER2_INVENTORY_ITEM_ID,'
                    ||'    1,'
                    ||'    :v_refresh_id,'
                    ||'    :v_instance_id'
                    ||'  from MRP_AD_REPAIR_RESERVATIONS_V'||MSC_CL_PULL.v_dblink||' x'
                    ||' WHERE x.RN>'||MSC_CL_PULL.v_lrn
                    ;


                    EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;
                    COMMIT;
            End If; -- Srp Profile Check
    END IF; -- Incremental Refresh

    IF MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 THEN
        v_temp_sql := ' AND x.GET_ORDERED_QUANTITY > x.GET_SHIPPED_QUANTITY ';
    ELSE
        v_temp_sql := ' ';
    END IF;

    IF MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 THEN
        v_temp_sql1 := ' AND x.RN1 > :v_lrn';
        /* ds change */
        v_temp_sql2 := ' SUPPLY_SOURCE_HEADER_ID,SUPPLY_SOURCE_TYPE_ID, ';
        v_temp_sql3 := ' x.SUPPLY_SOURCE_HEADER_ID,x.SUPPLY_SOURCE_TYPE_ID, ';
    ELSE
        v_temp_sql1 := ' AND (x.RN1 > :v_lrn or x.RN2 > :v_lrn or x.RN3 > :v_lrn or x.RN4 > :v_lrn or x.RN5 > :v_lrn or x.RN6 > :v_lrn)';
        v_temp_sql2 := ' NULL,NULL, ';
        v_temp_sql3 := ' NULL.NULL, ';
    END IF;

    MSC_CL_PULL.v_table_name:= 'MSC_ST_RESERVATIONS';
    MSC_CL_PULL.v_view_name := 'MRP_AP_HARD_RESERVATIONS_V';

    v_sql_stmt:=
    'insert into MSC_ST_RESERVATIONS'
    ||'  ( INVENTORY_ITEM_ID,'
    ||'    ORGANIZATION_ID,'
    ||'    TRANSACTION_ID,'
    ||'    PARENT_DEMAND_ID,'
    ||'    DISPOSITION_ID,'
    ||'    REQUIREMENT_DATE,'
    ||'    REVISION,'
    ||'    RESERVED_QUANTITY,'
    ||'    DISPOSITION_TYPE,'
    ||'    SUBINVENTORY,'
    ||'    RESERVATION_TYPE,'
    ||'    DEMAND_CLASS,'
    ||'    AVAILABLE_TO_MRP,'
    ||'    RESERVATION_FLAG,'
    ||'    PROJECT_ID,'
    ||'    TASK_ID,'
    ||'    PLANNING_GROUP,'
    ||     v_temp_sql2
    ||'    DELETED_FLAG,'
    ||'   REFRESH_ID,'
    ||'    SR_INSTANCE_ID)'
    ||'  select'
    ||'    x.INVENTORY_ITEM_ID,'
    ||'    x.ORGANIZATION_ID,'
    ||'    x.DEMAND_ID,'
    ||'    x.PARENT_DEMAND_ID,'
    ||'    x.DISPOSITION_ID,'
    ||'    x.REQUIREMENT_DATE- :v_dgmt,'
    ||'    x.REVISION,'
    ||'    x.RESERVED_QUANTITY,'
    ||'    x.DISPOSITION_TYPE,'
    ||'    x.SUBINVENTORY,'
    ||'    x.RESERVATION_TYPE,'
    --||'    DECODE( x.DEMAND_CLASS, NULL, NULL, :V_ICODE||x.DEMAND_CLASS),'
    ||'    x.DEMAND_CLASS,'
    ||'    x.AVAILABLE_TO_MRP,'
    ||'    2,'
    ||'    x.PROJECT_ID,'
    ||'    x.TASK_ID,'
    ||'    x.PLANNING_GROUP,'
    ||     v_temp_sql3
    ||'    2,'
    ||'  :v_refresh_id,'
    ||'    :v_instance_id'
    ||'  from MRP_AP_HARD_RESERVATIONS_V'||MSC_CL_PULL.v_dblink||' x'
    ||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str|| v_temp_sql || v_temp_sql1;

    /*||'   AND (' -- NCP: x.RN1>'||MSC_CL_PULL.v_lrn
    ||'         x.RN2>'||MSC_CL_PULL.v_lrn||')';

    ||'    OR x.RN3>'||MSC_CL_PULL.v_lrn
    ||'    OR x.RN4>'||MSC_CL_PULL.v_lrn
    ||'    OR x.RN5>'||MSC_CL_PULL.v_lrn
    ||'    OR x.RN6>'||MSC_CL_PULL.v_lrn||')'; */

    --EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_dgmt, MSC_CL_PULL.V_ICODE, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;
    -- EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

    IF MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 THEN
        EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id, MSC_CL_PULL.v_lrn;
    ELSE
        EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id, MSC_CL_PULL.v_lrn, MSC_CL_PULL.v_lrn, MSC_CL_PULL.v_lrn, MSC_CL_PULL.v_lrn, MSC_CL_PULL.v_lrn, MSC_CL_PULL.v_lrn;
    END IF;

    COMMIT;


      if (MSC_UTIL.G_COLLECT_SRP_DATA='Y' AND MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS120) Then -- SRP Changes For Bug 5988024

        IF MSC_CL_PULL.v_lrnn<> -1 THEN  -- incremental refresh
            v_temp_sql1 := ' OR x.date1 > :date1 OR x.date2 > :date2 ';
        ELSE
            v_temp_sql1 := NULL;
        END IF;

        v_sql_stmt:=
        'insert into MSC_ST_RESERVATIONS'
        ||'  ( INVENTORY_ITEM_ID,'
        ||'    ORGANIZATION_ID,'
        ||'    TRANSACTION_ID,'
        ||'    PARENT_DEMAND_ID,'
        ||'    DISPOSITION_ID,'
        ||'    REVISION,'
        ||'    RESERVED_QUANTITY,'
        ||'    DISPOSITION_TYPE,'
        ||'    RESERVATION_TYPE,'
        ||'    SUPPLY_SOURCE_TYPE_ID,'
        ||'    PROJECT_ID,'
        ||'    TASK_ID,'
        ||'    DELETED_FLAG,'
        ||'    REFRESH_ID,'
        ||'    SR_INSTANCE_ID)'
        ||'  select'
        ||'    x.INVENTORY_ITEM_ID,'
        ||'    x.ORGANIZATION_ID,'
        ||'    x.DEMAND_ID,'
        ||'    x.DISPOSITION_ID ,'
        ||'    x.DISPOSITION_ID,'
        ||'    x.REVISION,'
        ||'    x.RESERVED_QUANTITY,'
        ||'    x.DISPOSITION_TYPE,'
        ||'    x.RESERVATION_TYPE,'
        ||'    x.supply_source_type_id,'
        ||'    x.PROJECT_ID,'
        ||'    x.TASK_ID,'
        ||'    2,'
        ||'    :v_refresh_id,'
        ||'    :v_instance_id'
        ||'  from MRP_AP_REPAIR_TRANSFERS_RESV_V'||MSC_CL_PULL.v_dblink||'  x'
        ||' WHERE x.ORGANIZATION_ID '||MSC_UTIL.v_depot_org_str
        ||'   AND x.RN1 > :v_lrn'
        ||  v_temp_sql1;



        IF MSC_CL_PULL.v_lrnn<> -1 THEN  -- incremental refresh
            EXECUTE IMMEDIATE v_sql_stmt USING  MSC_CL_PULL.v_refresh_id,
                                                 MSC_CL_PULL.v_instance_id, MSC_CL_PULL.v_lrn,
                                                 MSC_CL_PULL.g_LAST_SUCC_RES_REF_TIME,MSC_CL_PULL.g_LAST_SUCC_RES_REF_TIME;
            /* For Bug 6144734 */
            v_sql_stmt:=
                        'Insert into MSC_ST_RESERVATIONS'
                          ||'  ( TRANSACTION_ID,'
                          ||'    SUPPLY_SOURCE_TYPE_ID,'
                          ||'    ORGANIZATION_ID,'
                          ||'    INVENTORY_ITEM_ID,'
                          ||'    DISPOSITION_TYPE,'
                          ||'    DISPOSITION_ID,'
                          ||'    ORDER2_ORGANIZATION_ID,'
                          ||'    ORDER2_INVENTORY_ITEM_ID,'
                          ||'    DELETED_FLAG,'
                          ||'    REFRESH_ID,'
                          ||'    SR_INSTANCE_ID)'
                          ||'  Select'
                          ||'    x.repair_line_id,'
                          ||'    200,'
                          ||'    ORGANIZATION_ID,'
                          ||'    INVENTORY_ITEM_ID,'
                          ||'    null,'
                          ||'    null,'
                          ||'    null,'
                          ||'    null,'
                          ||'    1,'
                          ||'    :v_refresh_id,'
                          ||'    :v_instance_id'
                          ||' from   MRP_AP_REPAIR_ORDERS_V'||MSC_CL_PULL.v_dblink ||'  x'
                           ||'  where x.organization_id  '||MSC_UTIL.v_depot_org_str
                          || ' AND x.RO_STATUS_CODE = '||'''C'''
                          ||'  AND x. LAST_UPDATE_DATE  > :date1' ;



                   EXECUTE IMMEDIATE v_sql_stmt USING  MSC_CL_PULL.v_refresh_id,
                                                 MSC_CL_PULL.v_instance_id,
                                                 MSC_CL_PULL.g_LAST_SUCC_RES_REF_TIME;

        ELSE
            EXECUTE IMMEDIATE v_sql_stmt USING  MSC_CL_PULL.v_refresh_id,
                                                 MSC_CL_PULL.v_instance_id, MSC_CL_PULL.v_lrn;
        END IF;


              commit;
        v_sql_stmt:=
        'insert into MSC_ST_RESERVATIONS'
        ||'  ( INVENTORY_ITEM_ID,'
        ||'    ORGANIZATION_ID,'
        ||'    TRANSACTION_ID,'
        ||'    PARENT_DEMAND_ID,'
        ||'    DISPOSITION_ID,'
        ||'    REVISION,'
        ||'    RESERVED_QUANTITY,'
        ||'    DISPOSITION_TYPE,'
        ||'    RESERVATION_TYPE,'
        ||'    REPAIR_PO_HEADER_ID,'
        ||'    SUPPLY_SOURCE_TYPE_ID,'
        ||'    PROJECT_ID,'
        ||'    TASK_ID,'
        ||'    DELETED_FLAG,'
        ||'    REFRESH_ID,'
        ||'    SR_INSTANCE_ID)'
        ||'  select'
        ||'    x.INVENTORY_ITEM_ID,'
        ||'    x.ORGANIZATION_ID,'
        ||'    x.DEMAND_ID,'
        ||'    x.DISPOSITION_ID ,'
        ||'    x.DISPOSITION_ID,'
         ||'    x.REVISION,'
        ||'    x.RESERVED_QUANTITY,'
        ||'    x.DISPOSITION_TYPE,'
        ||'    x.RESERVATION_TYPE,'
        ||'    X.REPAIR_PO_HEADER_ID,'
        ||'    x.SUPPLY_SOURCE_TYPE_ID,'
        ||'    x.PROJECT_ID,'
        ||'    x.TASK_ID,'
        ||'    2,'
        ||'    :v_refresh_id,'
        ||'    :v_instance_id'
        ||'  from MRP_AP_EXT_REP_RESERVATIONS_V'||MSC_CL_PULL.v_dblink||'  x'
        ||' WHERE x.ORGANIZATION_ID '||MSC_UTIL.v_in_org_str
        ||' AND ((x.RN > :v_lrn) OR (x.RN1 > :v_lrn) OR (x.RN2 > :v_lrn) OR (x.RN3 > :v_lrn)
            OR (x.RN4 > :v_lrn) OR (x.RN5 > :v_lrn) OR (x.RN6 > :v_lrn))'
        ;

        /* Changed For bug 6144734 */
         EXECUTE IMMEDIATE v_sql_stmt USING  MSC_CL_PULL.v_refresh_id,
                                            MSC_CL_PULL.v_instance_id,
                                            MSC_CL_PULL.v_lrn,
                                            MSC_CL_PULL.v_lrn,
                                            MSC_CL_PULL.v_lrn,
                                            MSC_CL_PULL.v_lrn,
                                            MSC_CL_PULL.v_lrn,
                                            MSC_CL_PULL.v_lrn,
                                            MSC_CL_PULL.v_lrn;

        commit;

    END IF;  -- SRP Changes For Bug 5988024

END IF;

END LOAD_HARD_RESERVATION;


   PROCEDURE LOAD_USER_DEMAND IS
   BEGIN

IF MSC_CL_PULL.v_apps_ver<> MSC_UTIL.G_APPS107 AND
   MSC_CL_PULL.v_apps_ver<> MSC_UTIL.G_APPS110 THEN

IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh

MSC_CL_PULL.v_table_name:= 'MSC_ST_DEMANDS';
MSC_CL_PULL.v_view_name := 'MRP_AD_USER_DEMANDS_V';

IF MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 THEN
   v_temp_sql := ' AND x.ORGANIZATION_ID '||MSC_UTIL.v_in_org_str;
ELSE
   v_temp_sql := NULL;
END IF;

v_sql_stmt:=
' INSERT INTO MSC_ST_DEMANDS'
||'( DISPOSITION_ID,'
||'  ORIGINATION_TYPE,'
||'  DELETED_FLAG,'
||'  ORGANIZATION_ID,'
||'  REFRESH_ID,'
||'  SR_INSTANCE_ID)'
||' SELECT'
||'  x.TRANSACTION_ID,'
||'  x.ORIGINATION_TYPE,'
||'  1,'
||'  x.ORGANIZATION_ID,'
||'  :v_refresh_id,'
||'  :v_instance_id'
||' FROM MRP_AD_USER_DEMANDS_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.RN>'||MSC_CL_PULL.v_lrn
|| v_temp_sql;

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

COMMIT;

END IF;

MSC_CL_PULL.v_table_name:= 'MSC_ST_DEMANDS';
MSC_CL_PULL.v_view_name := 'MRP_AP_USER_DEMANDS_V';

v_sql_stmt:=
' INSERT INTO MSC_ST_DEMANDS'
||'( DISPOSITION_ID,'
||'  ORIGINATION_TYPE,'
||'  INVENTORY_ITEM_ID,'
||'  ORGANIZATION_ID,'
||'  USING_ASSEMBLY_ITEM_ID,'
||'  ORDER_NUMBER,'
||'  USING_REQUIREMENT_QUANTITY,'
||'  USING_ASSEMBLY_DEMAND_DATE,'
||'  DEMAND_TYPE,'
||'  DEMAND_CLASS,'
||'  DELETED_FLAG,'
||'  REFRESH_ID,'
||'  SR_INSTANCE_ID)'
||' SELECT'
||'  x.TRANSACTION_ID,'
||'  x.ORIGINATION_TYPE,'
||'  x.INVENTORY_ITEM_ID,'
||'  x.ORGANIZATION_ID,'
||'  x.INVENTORY_ITEM_ID,'
||'  x.SOURCE_NAME,'
||'  x.PRIMARY_UOM_QUANTITY,'
||'  x.REQUIREMENT_DATE,'
||'  1,'   -- demand type
--||'  DECODE( x.DEMAND_CLASS,NULL,NULL,:V_ICODE||x.DEMAND_CLASS),'
||'    x.DEMAND_CLASS,'
||'  2,'
||'  :v_refresh_id,'
||'  :v_instance_id'
||' FROM MRP_AP_USER_DEMANDS_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'   AND (x.RN1>'||MSC_CL_PULL.v_lrn
||'   OR  x.RN2>'||MSC_CL_PULL.v_lrn||')';

--EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.V_ICODE, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;
EXECUTE IMMEDIATE v_sql_stmt USING  MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

COMMIT;

END IF;

  END LOAD_USER_DEMAND;


--==================================================================
/**************************************************************
*    LOAD AHL as Sales Orders for 11i.10 CMRO Integration
****************************************************************/

PROCEDURE LOAD_AHL IS
lv_temp_sql   VARCHAR2(1024);
BEGIN



--     Not needed, Clean it up once it is coded
--     MSC_CL_PULL.v_table_name:= 'MSC_ST_SALES_ORDERS';

     IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh
         MSC_CL_PULL.v_view_name := 'MRP_AN_AHL_MTL_REQS_V';
         v_temp_sql3 := '   AND (x.RN1 > :v_lrn OR x.RN2> :v_lrn  OR x.RN3> :v_lrn )';

    ELSE
         MSC_CL_PULL.v_view_name := 'MRP_AP_AHL_MTL_REQS_V';
         v_temp_sql3 := '   ';

    END IF;



    /* In AHL You do not have to worry about planning for the past due visits as they
       do not exist any further */
    /******************************************************************************************
     v_temp_sql2 :=   ' AND (x.ORIGINAL_ORDERED_QUANTITY > x.ORIGINAL_COMPLETED_QUANTITY '
                           ||'   OR (x.ORIGINAL_ORDERED_QUANTITY =  x.ORIGINAL_COMPLETED_QUANTITY ';
     v_temp_sql2 := v_temp_sql2 ||' AND x.requirement_date >  sysdate - (' || v_msc_so_offset_days ||' ))) ';
    ********************************************************************************************/
    -- Hence we directly subsitute v_temp_sql2 in the insert statement

   	 v_sql_stmt:=
    	'INSERT INTO MSC_ST_SALES_ORDERS'
        	||'  ( INVENTORY_ITEM_ID,'
        	||'    ORGANIZATION_ID,'
        	||'    PRIMARY_UOM_QUANTITY,'
        	||'    RESERVATION_TYPE,'
        	||'    RESERVATION_QUANTITY,'
        	||'    DEMAND_SOURCE_TYPE,'
        	||'    DEMAND_SOURCE_HEADER_ID,'
        	||'    COMPLETED_QUANTITY,'
        	||'    SUBINVENTORY,'
        	||'    DEMAND_CLASS,'
        	||'    REQUIREMENT_DATE,'
        	||'    DEMAND_SOURCE_LINE,'
        	||'    DEMAND_SOURCE_DELIVERY,'
        	||'    DEMAND_SOURCE_NAME,'
        	||'    DEMAND_ID,'
        	||'    ROW_TYPE,'
        	||'    PARENT_DEMAND_ID,'
        	||'    SALES_ORDER_NUMBER,'
        	||'    FORECAST_VISIBLE,'
        	||'    DEMAND_VISIBLE,'
        	||'    SALESREP_CONTACT,'
        	||'    CUSTOMER_ID,'
        	||'    SHIP_TO_SITE_USE_ID,'
        	||'    BILL_TO_SITE_USE_ID,'
        	||'    REQUEST_DATE,'
        	||'    PROJECT_ID,'
        	||'    TASK_ID,'
        	||'    PLANNING_GROUP,'
        	||'    SELLING_PRICE,'
        	||'    END_ITEM_UNIT_NUMBER,'
        	||'    ORDERED_ITEM_ID,'
        	||'    ORIGINAL_ITEM_ID,'
        	||'    LINK_TO_LINE_ID ,'
        	||'    CUST_PO_NUMBER,'
        	||'    CUSTOMER_LINE_NUMBER,'
        	||'    MFG_LEAD_TIME,'
        	||'    ORG_FIRM_FLAG,'
--        	||'    SHIP_SET_ID,'
--        	||'    ARRIVAL_SET_ID,'
        	||'    ATP_REFRESH_NUMBER,'
        	||'    DELETED_FLAG,'
        	||'    ORIGINAL_SYSTEM_LINE_REFERENCE,'
        	||'    ORIGINAL_SYSTEM_REFERENCE,'
        	||'    CTO_FLAG,'
        	||'    AVAILABLE_TO_MRP,'
        	||'    DEMAND_PRIORITY,'
        	||'    PROMISE_DATE,'
        	||'    REFRESH_ID,'
        	||'    SR_INSTANCE_ID) '
--        	||'    SCHEDULE_ARRIVAL_DATE,'
--        	||'    LATEST_ACCEPTABLE_DATE,'
--        	||'    SHIPPING_METHOD_CODE,'
--        	||'    ATO_LINE_ID,'
--        	||'    ORDER_DATE_TYPE_CODE)'
        	||' SELECT '
        	||'    x.INVENTORY_ITEM_ID,'
        	||'    x.ORGANIZATION_ID,'
        	||'    x.PRIMARY_UOM_QUANTITY,'
        	||'    x.RESERVATION_TYPE,'
        	||'    x.RESERVATION_QUANTITY,'
        	||'    x.DEMAND_SOURCE_TYPE,'
        	||'    x.DEMAND_SOURCE_HEADER_ID,'
        	||'    x.COMPLETED_QUANTITY,'
        	||'    x.SUBINVENTORY,'
        	||'    x.DEMAND_CLASS,'
        	||'    x.REQUIREMENT_DATE,'
        	||'    x.DEMAND_SOURCE_LINE,'
        	||'    x.DEMAND_SOURCE_DELIVERY,'
        	||'    x.DEMAND_SOURCE_NAME,'
        	||'    x.DEMAND_ID,'
        	||'    x.ROW_TYPE,'
        	||'    x.PARENT_DEMAND_ID,'
            ||'    x.SALES_ORDER_NUMBER,'
            ||'    x.FORECAST_VISIBLE,'
            ||'    x.DEMAND_VISIBLE,'
            ||'    x.SALESREP_CONTACT,'
            ||'    x.CUSTOMER_ID,'
            ||'    x.SHIP_TO_SITE_ID,'
            ||'    x.BILL_TO_SITE_ID,'
            ||'    x.REQUEST_DATE,'
            ||'    x.PROJECT_ID,'
            ||'    x.TASK_ID,'
            ||'    x.PLANNING_GROUP,'
            ||'    x.LIST_PRICE,'
            ||'    x.END_ITEM_UNIT_NUMBER ,'
            ||'    x.ordered_item_id,'
            ||'    x.ORIGINAL_INVENTORY_ITEM_ID , '
		    ||'    x.LINK_TO_LINE_ID,'
            ||'    x.cust_po_number,'
            ||'    x.customer_line_number,'
            ||'    x.MFG_LEAD_TIME,'
            ||'    1,'
--          ||'    x.SHIP_SET_ID,'
--          ||'    x.ARRIVAL_SET_ID,'
            ||'    x.RN1,'
            ||'    2,'
            ||'    x.ORIGINAL_SYSTEM_LINE_REFERENCE,'
            ||'    x.ORIGINAL_SYSTEM_REFERENCE,'
            ||'    x.CTO_FLAG,'
            ||'    x.AVAILABLE_TO_MRP,'
            ||'    x.DEMAND_PRIORITY,'
            ||'    x.PROMISE_DATE,'
            ||'    :v_refresh_id,'
            ||'    :v_instance_id '
--          ||'    x.SCHEDULE_ARRIVAL_DATE,'
--          ||'    x.LATEST_ACCEPTABLE_DATE,'
--          ||'    x.SHIPPING_METHOD_CODE,'
--          ||'    x.ATO_LINE_ID,'
--          ||'    x.ORDER_DATE_TYPE_CODE '
            ||' FROM  '||MSC_CL_PULL.v_view_name||MSC_CL_PULL.v_dblink||' x'
            ||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
            ||'  AND x.ORIGINAL_ORDERED_QUANTITY > x.ORIGINAL_COMPLETED_QUANTITY '
            ||  v_temp_sql3 ;


     IF (MSC_CL_PULL.v_lrnn <> -1) THEN       -- incremental collections

                 EXECUTE IMMEDIATE v_sql_stmt
			     USING MSC_CL_PULL.v_refresh_id,
				   MSC_CL_PULL.v_instance_id,
				   MSC_CL_PULL.v_lrn,
				   MSC_CL_PULL.v_lrn,
				   MSC_CL_PULL.v_lrn;

    ELSE                         --- complete/targeted collections
                EXECUTE IMMEDIATE v_sql_stmt
		            USING MSC_CL_PULL.v_refresh_id,
				    MSC_CL_PULL.v_instance_id;
    END IF;


COMMIT;
END LOAD_AHL;

PROCEDURE LOAD_OPEN_PAYBACKS IS
BEGIN

IF MSC_CL_PULL.v_lrn = -1 AND MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 THEN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'PROCEDURE  LOAD_OPEN_PAYBACKS');
    MSC_CL_PULL.v_table_name:= 'MSC_ST_OPEN_PAYBACKS';
    MSC_CL_PULL.v_view_name := 'MRP_AP_OPEN_PAYBACK_QTY_V';

v_sql_stmt:=
' INSERT INTO MSC_ST_OPEN_PAYBACKS(
SR_INSTANCE_ID,
INVENTORY_ITEM_ID,
ORGANIZATION_ID,
SCHEDULED_PAYBACK_DATE,
QUANTITY,
LENDING_PROJECT_ID,
LENDING_TASK_ID,
BORROW_PROJECT_ID,
BORROW_TASK_ID,
PLANNING_GROUP,
LENDING_PROJ_PLANNING_GROUP,
END_ITEM_UNIT_NUMBER)
 SELECT
:v_instance_id,
INVENTORY_ITEM_ID,
ORGANIZATION_ID,
SCHEDULED_PAYBACK_DATE,
QUANTITY,
LENDING_PROJECT_ID,
LENDING_TASK_ID,
BORROW_PROJECT_ID,
BORROW_TASK_ID,
PLANNING_GROUP,
LENDING_PROJ_PLANNING_GROUP,
END_ITEM_UNIT_NUMBER
 FROM MRP_AP_OPEN_PAYBACK_QTY_V'||MSC_CL_PULL.v_dblink||
 ' WHERE ORGANIZATION_ID  '|| MSC_UTIL.v_in_org_str;

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_instance_id;
COMMIT;

END IF;

END LOAD_OPEN_PAYBACKS;

END MSC_CL_DEMAND_PULL;

/
