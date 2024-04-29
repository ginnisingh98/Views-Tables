--------------------------------------------------------
--  DDL for Package Body MSC_CL_BOM_PULL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_CL_BOM_PULL" AS -- body
/* $Header:*/



   v_union_sql              varchar2(32767);
   v_temp_tp_sql            VARCHAR2(100);
   v_sql_stmt                    VARCHAR2(32767);
   v_temp_sql                    VARCHAR2(15000);
   v_temp_sql1                   VARCHAR2(1000);
   v_temp_sql2                   VARCHAR2(1000);
   v_temp_sql3                   VARCHAR2(1000);
   v_temp_sql4                   VARCHAR2(1000);
   v_rounding_Sql                varchar2(1000);

   --NULL_DBLINK                  CONSTANT VARCHAR2(1):= ' ';
--   NULL_DBLINK      CONSTANT  VARCHAR2(1) :=MSC_UTIL.NULL_DBLINK;
-- ===============================================================

   PROCEDURE LOAD_BOM IS
   v_applsys_schema             VARCHAR2(32);
   lv_retval boolean;
    lv_dummy1 varchar2(32);
    lv_dummy2 varchar2(32);
     lv_icode varchar2(3);
   BEGIN
    lv_retval := FND_INSTALLATION.GET_APP_INFO (
                           'FND', lv_dummy1, lv_dummy2, v_applsys_schema);

IF MSC_CL_PULL.BOM_ENABLED= MSC_UTIL.SYS_YES THEN

IF MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 THEN
   v_temp_sql1 := ' x.BASIS_TYPE, x.Old_Component_Sequence_ID,';
ELSE
   v_temp_sql1 := ' NULL, NULL,';
END IF;

--=================== Net Change Mode: Delete ==================
IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh

MSC_CL_PULL.v_table_name:= 'MSC_ST_BOM_COMPONENTS';
MSC_CL_PULL.v_view_name := 'MRP_AD_BOM_COMPONENTS_V';

IF MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 THEN
   v_temp_sql := ' AND x.ORGANIZATION_ID '||MSC_UTIL.v_in_org_str;
ELSE
   v_temp_sql := NULL;
END IF;

v_sql_stmt:=
' insert into MSC_ST_BOM_COMPONENTS'
||'( COMPONENT_SEQUENCE_ID,'
||'  BILL_SEQUENCE_ID,'
||'  DELETED_FLAG,'
||'  REFRESH_ID,'
||'  SR_INSTANCE_ID)'
||' select '
||'  x.COMPONENT_SEQUENCE_ID,'
||'  x.BILL_SEQUENCE_ID,'
||'  1,'
||'  :v_refresh_id,'
||'  :v_instance_id'
||'  from MRP_AD_BOM_COMPONENTS_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.RN> :v_lrn '
|| v_temp_sql;


EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id, MSC_CL_PULL.v_lrn;

COMMIT;

END IF;

MSC_CL_PULL.v_table_name:= 'MSC_ST_BOM_COMPONENTS';



IF MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 THEN
	 v_rounding_sql := 'decode(x.rounding_direction,0,3,1,2,2,1,3),';
ELSE
    v_rounding_sql :='3,';
END IF ;

IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh

IF MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 THEN
 MSC_CL_PULL.v_view_name := 'MRP_AN_BOM_COMPONENTS_V';
ELSE
 MSC_CL_PULL.v_view_name := 'MRP_AP_BOM_COMPONENTS_V';
END IF;


v_union_sql :=
'   AND ( x.RN1> :v_lrn )'
||' UNION '
||' select '
||'  x.COMPONENT_SEQUENCE_ID,'
||'  x.INVENTORY_ITEM_ID,'
||'  x.BILL_SEQUENCE_ID,'
||'  x.OPERATION_SEQ_NUM,'
||'  x.USAGE_QUANTITY,'
||'  x.COMPONENT_YIELD_FACTOR,'
||'  x.EFFECTIVITY_DATE- :v_dgmt,'
||'  x.DISABLE_DATE- :v_dgmt,'
||'  x.OPERATION_OFFSET_PERCENT,'
||'  x.OPTIONAL_COMPONENT,'
||'  x.WIP_SUPPLY_TYPE,'
||'  x.PLANNING_FACTOR,'
||'  x.REVISED_ITEM_SEQUENCE_ID,'
||'  x.ATP_FLAG,'
||'  x.STATUS_TYPE,'
||'  x.USE_UP_CODE,'
||'  x.CHANGE_NOTICE,'
||'  x.ORGANIZATION_ID,'
||'  x.USING_ASSEMBLY_ID,'
||'  x.FROM_UNIT_NUMBER,'
||'  x.TO_UNIT_NUMBER,'
||'  x.DRIVING_ITEM_ID,'
||'  2,'
||   v_rounding_sql
||   v_temp_sql1
||'  :v_refresh_id,'
||'  :v_instance_id'
||'  from '||MSC_CL_PULL.v_view_name||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'   AND ( x.RN2> :v_lrn )'
/* NCP
||' UNION '
||' select '
||'  x.COMPONENT_SEQUENCE_ID,'
||'  x.INVENTORY_ITEM_ID,'
||'  x.BILL_SEQUENCE_ID,'
||'  x.USAGE_QUANTITY,'
||'  x.COMPONENT_YIELD_FACTOR,'
||'  x.EFFECTIVITY_DATE- :v_dgmt,'
||'  x.DISABLE_DATE- :v_dgmt,'
||'  x.OPERATION_OFFSET_PERCENT,'
||'  x.OPTIONAL_COMPONENT,'
||'  x.WIP_SUPPLY_TYPE,'
||'  x.PLANNING_FACTOR,'
||'  x.REVISED_ITEM_SEQUENCE_ID,'
||'  x.ATP_FLAG,'
||'  x.STATUS_TYPE,'
||'  x.USE_UP_CODE,'
||'  x.CHANGE_NOTICE,'
||'  x.ORGANIZATION_ID,'
||'  x.USING_ASSEMBLY_ID,'
||'  x.FROM_UNIT_NUMBER,'
||'  x.TO_UNIT_NUMBER,'
||'  x.DRIVING_ITEM_ID,'
||'  2,'
||   v_rounding_sql
||'  :v_refresh_id,'
||'  :v_instance_id'
||'  from '||MSC_CL_PULL.v_view_name||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'   AND ( x.RN3>'||MSC_CL_PULL.v_lrn||')'
*/

||' UNION '
||' select '
||'  x.COMPONENT_SEQUENCE_ID,'
||'  x.INVENTORY_ITEM_ID,'
||'  x.BILL_SEQUENCE_ID,'
||'  x.OPERATION_SEQ_NUM,'
||'  x.USAGE_QUANTITY,'
||'  x.COMPONENT_YIELD_FACTOR,'
||'  x.EFFECTIVITY_DATE- :v_dgmt,'
||'  x.DISABLE_DATE- :v_dgmt,'
||'  x.OPERATION_OFFSET_PERCENT,'
||'  x.OPTIONAL_COMPONENT,'
||'  x.WIP_SUPPLY_TYPE,'
||'  x.PLANNING_FACTOR,'
||'  x.REVISED_ITEM_SEQUENCE_ID,'
||'  x.ATP_FLAG,'
||'  x.STATUS_TYPE,'
||'  x.USE_UP_CODE,'
||'  x.CHANGE_NOTICE,'
||'  x.ORGANIZATION_ID,'
||'  x.USING_ASSEMBLY_ID,'
||'  x.FROM_UNIT_NUMBER,'
||'  x.TO_UNIT_NUMBER,'
||'  x.DRIVING_ITEM_ID,'
||'  2,'
||   v_rounding_sql
||   v_temp_sql1
||'  :v_refresh_id,'
||'  :v_instance_id'
||'  from '||MSC_CL_PULL.v_view_name||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'   AND ( x.RN3> :v_lrn )'
||' UNION '
||' select '
||'  x.COMPONENT_SEQUENCE_ID,'
||'  x.INVENTORY_ITEM_ID,'
||'  x.BILL_SEQUENCE_ID,'
||'  x.OPERATION_SEQ_NUM,'
||'  x.USAGE_QUANTITY,'
||'  x.COMPONENT_YIELD_FACTOR,'
||'  x.EFFECTIVITY_DATE- :v_dgmt,'
||'  x.DISABLE_DATE- :v_dgmt,'
||'  x.OPERATION_OFFSET_PERCENT,'
||'  x.OPTIONAL_COMPONENT,'
||'  x.WIP_SUPPLY_TYPE,'
||'  x.PLANNING_FACTOR,'
||'  x.REVISED_ITEM_SEQUENCE_ID,'
||'  x.ATP_FLAG,'
||'  x.STATUS_TYPE,'
||'  x.USE_UP_CODE,'
||'  x.CHANGE_NOTICE,'
||'  x.ORGANIZATION_ID,'
||'  x.USING_ASSEMBLY_ID,'
||'  x.FROM_UNIT_NUMBER,'
||'  x.TO_UNIT_NUMBER,'
||'  x.DRIVING_ITEM_ID,'
||'  2,'
||   v_rounding_sql
||   v_temp_sql1
||'  :v_refresh_id,'
||'  :v_instance_id'
||'  from '||MSC_CL_PULL.v_view_name||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'   AND ( x.RN4> :v_lrn )';
/*
||' UNION '
||' select '
||'  x.COMPONENT_SEQUENCE_ID,'
||'  x.INVENTORY_ITEM_ID,'
||'  x.BILL_SEQUENCE_ID,'
||'  x.USAGE_QUANTITY,'
||'  x.COMPONENT_YIELD_FACTOR,'
||'  x.EFFECTIVITY_DATE- :v_dgmt,'
||'  x.DISABLE_DATE- :v_dgmt,'
||'  x.OPERATION_OFFSET_PERCENT,'
||'  x.OPTIONAL_COMPONENT,'
||'  x.WIP_SUPPLY_TYPE,'
||'  x.PLANNING_FACTOR,'
||'  x.REVISED_ITEM_SEQUENCE_ID,'
||'  x.ATP_FLAG,'
||'  x.STATUS_TYPE,'
||'  x.USE_UP_CODE,'
||'  x.CHANGE_NOTICE,'
||'  x.ORGANIZATION_ID,'
||'  x.USING_ASSEMBLY_ID,'
||'  x.FROM_UNIT_NUMBER,'
||'  x.TO_UNIT_NUMBER,'
||'  x.DRIVING_ITEM_ID,'
||'  2,'
||   v_rounding_sql
||'  :v_refresh_id,'
||'  :v_instance_id'
||'  from '||MSC_CL_PULL.v_view_name||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'   AND ( x.RN6>'||MSC_CL_PULL.v_lrn||')' ;
*/

ELSE
MSC_CL_PULL.v_view_name := 'MRP_AP_BOM_COMPONENTS_V';
v_union_sql := '     ';

END IF;
v_sql_stmt:=
' insert into MSC_ST_BOM_COMPONENTS'
||'( COMPONENT_SEQUENCE_ID,'
||'  INVENTORY_ITEM_ID,'
||'  BILL_SEQUENCE_ID,'
||'  OPERATION_SEQ_NUM,'
||'  USAGE_QUANTITY,'
||'  COMPONENT_YIELD_FACTOR,'
||'  EFFECTIVITY_DATE,'
||'  DISABLE_DATE,'
||'  OPERATION_OFFSET_PERCENT,'
||'  OPTIONAL_COMPONENT,'
||'  WIP_SUPPLY_TYPE,'
||'  PLANNING_FACTOR,'
||'  REVISED_ITEM_SEQUENCE_ID,'
||'  ATP_FLAG,'
||'  STATUS_TYPE,'
||'  USE_UP_CODE,'
||'  CHANGE_NOTICE,'
||'  ORGANIZATION_ID,'
||'  USING_ASSEMBLY_ID,'
||'  FROM_UNIT_NUMBER,'
||'  TO_UNIT_NUMBER,'
||'  DRIVING_ITEM_ID,'
||'  DELETED_FLAG,'
||'  ROUNDING_DIRECTION,'
||'  SCALING_TYPE,'
||'  OLD_COMPONENT_SEQUENCE_ID,'
||'  REFRESH_ID,'
||'  SR_INSTANCE_ID)'
||' select '
||'  x.COMPONENT_SEQUENCE_ID,'
||'  x.INVENTORY_ITEM_ID,'
||'  x.BILL_SEQUENCE_ID,'
||'  x.OPERATION_SEQ_NUM,'
||'  x.USAGE_QUANTITY,'
||'  x.COMPONENT_YIELD_FACTOR,'
||'  x.EFFECTIVITY_DATE- :v_dgmt,'
||'  x.DISABLE_DATE- :v_dgmt,'
||'  x.OPERATION_OFFSET_PERCENT,'
||'  x.OPTIONAL_COMPONENT,'
||'  x.WIP_SUPPLY_TYPE,'
||'  x.PLANNING_FACTOR,'
||'  x.REVISED_ITEM_SEQUENCE_ID,'
||'  x.ATP_FLAG,'
||'  x.STATUS_TYPE,'
||'  x.USE_UP_CODE,'
||'  x.CHANGE_NOTICE,'
||'  x.ORGANIZATION_ID,'
||'  x.USING_ASSEMBLY_ID,'
||'  x.FROM_UNIT_NUMBER,'
||'  x.TO_UNIT_NUMBER,'
||'  x.DRIVING_ITEM_ID,'
||'  2,'
||   v_rounding_sql
||   v_temp_sql1
||'  :v_refresh_id,'
||'  :v_instance_id'
||'  from '||MSC_CL_PULL.v_view_name||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
|| v_union_sql ;

IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh

EXECUTE IMMEDIATE v_sql_stmt
            USING MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id, MSC_CL_PULL.v_lrn,
                  MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id, MSC_CL_PULL.v_lrn,
                  MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id, MSC_CL_PULL.v_lrn,
                  MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id, MSC_CL_PULL.v_lrn;
/*                  MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id,
                  MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;
*/

ELSE

EXECUTE IMMEDIATE v_sql_stmt
            USING MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;


END IF;

COMMIT;

--=================== Net Change Mode: Delete ==================
IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh

MSC_CL_PULL.v_table_name:= 'MSC_ST_BOMS';
MSC_CL_PULL.v_view_name := 'MRP_AD_BOMS_V';

IF MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 THEN
   v_temp_sql := ' AND x.ORGANIZATION_ID '||MSC_UTIL.v_in_org_str;
ELSE
   v_temp_sql := NULL;
END IF;

v_sql_stmt:=
' insert into MSC_ST_BOMS'
||' ( BILL_SEQUENCE_ID,'
||'   DELETED_FLAG,'
||'   REFRESH_ID,'
||'   SR_INSTANCE_ID)'
||' SELECT'
||'   x.BILL_SEQUENCE_ID,    '
||'   1,'
||'   :v_refresh_id,'
||'   :v_instance_id'
||'  FROM MRP_AD_BOMS_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.RN> :v_lrn '
|| v_temp_sql;

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id, MSC_CL_PULL.v_lrn;

COMMIT;

END IF;


MSC_CL_PULL.v_table_name:= 'MSC_ST_BOMS';
MSC_CL_PULL.v_view_name := 'MRP_AP_BOMS_V';

IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh

v_union_sql :=
'   AND ( x.RN1 > :v_lrn )'
||' UNION '
||' SELECT'
||'   x.BILL_SEQUENCE_ID,    '
||'   x.ORGANIZATION_ID,  '
||'   x.ASSEMBLY_ITEM_ID, '
||'   x.ASSEMBLY_TYPE,   '
||'   x.ALTERNATE_BOM_DESIGNATOR, '
||'   x.SPECIFIC_ASSEMBLY_COMMENT, '
||'   x.PENDING_FROM_ECN,    '
||'   x.COMMON_BILL_SEQUENCE_ID, '
||'   2,'
||'  :v_refresh_id,'
||'   :v_instance_id'
||'  FROM MRP_AP_BOMS_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'   AND (x.RN2 > :v_lrn)';

ELSE
v_union_sql := '     ';

END IF;


v_sql_stmt:=
' insert into MSC_ST_BOMS'
||' ( BILL_SEQUENCE_ID,'
||'   ORGANIZATION_ID,'
||'   ASSEMBLY_ITEM_ID,'
||'   ASSEMBLY_TYPE,'
||'   ALTERNATE_BOM_DESIGNATOR,'
||'   SPECIFIC_ASSEMBLY_COMMENT,'
||'   PENDING_FROM_ECN,'
||'   COMMON_BILL_SEQUENCE_ID,'
||'   DELETED_FLAG,'
||'   REFRESH_ID,'
||'   SR_INSTANCE_ID)'
||' SELECT'
||'   x.BILL_SEQUENCE_ID,    '
||'   x.ORGANIZATION_ID,  '
||'   x.ASSEMBLY_ITEM_ID, '
||'   x.ASSEMBLY_TYPE,   '
||'   x.ALTERNATE_BOM_DESIGNATOR, '
||'   x.SPECIFIC_ASSEMBLY_COMMENT, '
||'   x.PENDING_FROM_ECN,    '
||'   x.COMMON_BILL_SEQUENCE_ID, '
||'   2,'
||'  :v_refresh_id,'
||'   :v_instance_id'
||'  FROM MRP_AP_BOMS_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
|| v_union_sql;

IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh

  EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id, MSC_CL_PULL.v_lrn,
                                     MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id, MSC_CL_PULL.v_lrn;
ELSE

  EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

END IF;


COMMIT;

IF MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 THEN
--=================== Net Change Mode: Delete ==================
IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh

MSC_CL_PULL.v_table_name:= 'MSC_ST_COMPONENT_SUBSTITUTES';
MSC_CL_PULL.v_view_name := 'MRP_AD_SUB_COMPS_V';

v_sql_stmt:=
' insert into MSC_ST_COMPONENT_SUBSTITUTES'
||' ( BILL_SEQUENCE_ID,'
||'   COMPONENT_SEQUENCE_ID,'
||'   SUBSTITUTE_ITEM_ID,'
||'   DELETED_FLAG,'
||'   REFRESH_ID,'
||'   SR_INSTANCE_ID)'
||' SELECT'
||'   x.BILL_SEQUENCE_ID,'
||'   x.COMPONENT_SEQUENCE_ID,'
||'   x.SUBSTITUTE_ITEM_ID,'
||'   1,'
||'   :v_refresh_id,'
||'   :v_instance_id'
||'  FROM MRP_AD_SUB_COMPS_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID '||MSC_UTIL.v_in_org_str
||' AND x.RN > :v_lrn';

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id, MSC_CL_PULL.v_lrn;

COMMIT;

END IF;

END IF;


MSC_CL_PULL.v_table_name:= 'MSC_ST_COMPONENT_SUBSTITUTES';
MSC_CL_PULL.v_view_name := 'MRP_AP_COMPONENT_SUBSTITUTES_V';



IF MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 THEN
	 v_rounding_sql := 'decode(x.rounding_direction,0,3,1,2,2,1,3),';
    v_rounding_sql :='3,';
END IF ;



IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh

v_union_sql :=
'   AND ( x.RN1 > :v_lrn )'
||' UNION '
||' SELECT'
||'   x.BILL_SEQUENCE_ID,'
||'   x.COMPONENT_SEQUENCE_ID,'
||'   x.SUBSTITUTE_ITEM_ID,'
||'   x.USAGE_QUANTITY,'
||'   x.ORGANIZATION_ID,'
||'   NVL( TO_NUMBER(DECODE( :v_msc_bom_subst_priority,'
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
||'            15, x.Attribute15)),2),'
||'   2,'
||   v_rounding_sql
||'  :v_refresh_id,'
||'   :v_instance_id'
||'  FROM MRP_AP_COMPONENT_SUBSTITUTES_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'   AND (x.RN2 > :v_lrn)'
||' UNION '
||' SELECT'
||'   x.BILL_SEQUENCE_ID,'
||'   x.COMPONENT_SEQUENCE_ID,'
||'   x.SUBSTITUTE_ITEM_ID,'
||'   x.USAGE_QUANTITY,'
||'   x.ORGANIZATION_ID,'
||'   NVL( TO_NUMBER(DECODE( :v_msc_bom_subst_priority,'
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
||'            15, x.Attribute15)),2),'
||'   2,'
||   v_rounding_sql
||'  :v_refresh_id,'
||'   :v_instance_id'
||'  FROM MRP_AP_COMPONENT_SUBSTITUTES_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'   AND (x.RN3 > :v_lrn)'
||' UNION '
||' SELECT'
||'   x.BILL_SEQUENCE_ID,'
||'   x.COMPONENT_SEQUENCE_ID,'
||'   x.SUBSTITUTE_ITEM_ID,'
||'   x.USAGE_QUANTITY,'
||'   x.ORGANIZATION_ID,'
||'   NVL( TO_NUMBER(DECODE( :v_msc_bom_subst_priority,'
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
||'            15, x.Attribute15)),2),'
||'   2,'
||   v_rounding_sql
||'  :v_refresh_id,'
||'   :v_instance_id'
||'  FROM MRP_AP_COMPONENT_SUBSTITUTES_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'   AND (x.RN4 > :v_lrn)';

IF MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 THEN

v_union_sql :=
v_union_sql||' UNION '
||' SELECT'
||'   x.BILL_SEQUENCE_ID,'
||'   x.COMPONENT_SEQUENCE_ID,'
||'   x.SUBSTITUTE_ITEM_ID,'
||'   x.USAGE_QUANTITY,'
||'   x.ORGANIZATION_ID,'
||'   NVL( TO_NUMBER(DECODE( :v_msc_bom_subst_priority,'
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
||'            15, x.Attribute15)),2),'
||'   2,'
||   v_rounding_sql
||'  :v_refresh_id,'
||'   :v_instance_id'
||'  FROM MRP_AP_COMPONENT_SUBSTITUTES_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'   AND (x.RN5 > :v_lrn)';


END IF;

ELSE
v_union_sql := '     ';

END IF;

v_sql_stmt:=
' INSERT INTO MSC_ST_COMPONENT_SUBSTITUTES'
||' ( BILL_SEQUENCE_ID,'
||'   COMPONENT_SEQUENCE_ID,'
||'   SUBSTITUTE_ITEM_ID,'
||'   USAGE_QUANTITY,'
||'   ORGANIZATION_ID,'
||'   PRIORITY,'
||'   DELETED_FLAG,'
||'   ROUNDING_DIRECTION,'
||'   REFRESH_ID,'
||'   SR_INSTANCE_ID)'
||' SELECT'
||'   x.BILL_SEQUENCE_ID,'
||'   x.COMPONENT_SEQUENCE_ID,'
||'   x.SUBSTITUTE_ITEM_ID,'
||'   x.USAGE_QUANTITY,'
||'   x.ORGANIZATION_ID,'
||'   NVL( TO_NUMBER(DECODE( :v_msc_bom_subst_priority,'
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
||'            15, x.Attribute15)),2),'
||'   2,'
||   v_rounding_sql
||'  :v_refresh_id,'
||'   :v_instance_id'
||'  FROM MRP_AP_COMPONENT_SUBSTITUTES_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
|| v_union_sql;


IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh

IF MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 THEN

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_msc_bom_subst_priority,MSC_CL_PULL.v_refresh_id,MSC_CL_PULL.v_instance_id,MSC_CL_PULL.v_lrn,
				   MSC_CL_PULL.v_msc_bom_subst_priority,MSC_CL_PULL.v_refresh_id,MSC_CL_PULL.v_instance_id,MSC_CL_PULL.v_lrn,
                                   MSC_CL_PULL.v_msc_bom_subst_priority,MSC_CL_PULL.v_refresh_id,MSC_CL_PULL.v_instance_id,MSC_CL_PULL.v_lrn,
                                   MSC_CL_PULL.v_msc_bom_subst_priority,MSC_CL_PULL.v_refresh_id,MSC_CL_PULL.v_instance_id,MSC_CL_PULL.v_lrn,
                                   MSC_CL_PULL.v_msc_bom_subst_priority,MSC_CL_PULL.v_refresh_id,MSC_CL_PULL.v_instance_id,MSC_CL_PULL.v_lrn;
ELSE

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_msc_bom_subst_priority,MSC_CL_PULL.v_refresh_id,MSC_CL_PULL.v_instance_id,MSC_CL_PULL.v_lrn,
                                   MSC_CL_PULL.v_msc_bom_subst_priority,MSC_CL_PULL.v_refresh_id,MSC_CL_PULL.v_instance_id,MSC_CL_PULL.v_lrn,
                                   MSC_CL_PULL.v_msc_bom_subst_priority,MSC_CL_PULL.v_refresh_id,MSC_CL_PULL.v_instance_id,MSC_CL_PULL.v_lrn,
                                   MSC_CL_PULL.v_msc_bom_subst_priority,MSC_CL_PULL.v_refresh_id,MSC_CL_PULL.v_instance_id,MSC_CL_PULL.v_lrn;
END IF;

ELSE

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_msc_bom_subst_priority,MSC_CL_PULL.v_refresh_id,MSC_CL_PULL.v_instance_id;

END IF;


COMMIT;


if MSC_CL_PULL.v_apps_ver>= MSC_UTIL.G_APPS115 THEN  /*osfm change*/
select instance_code into lv_icode from msc_apps_instances where instance_id = MSC_CL_PULL.v_instance_id;
         BEGIN

            ad_ddl.do_ddl( applsys_schema => v_applsys_schema,
                           application_short_name => 'MSC',
                           statement_type => AD_DDL.CREATE_INDEX,
                           statement =>
                 'create index MSC_ST_BOM_COMPONENTS_'||lv_icode
              ||' ON MSC_ST_BOM_COMPONENTS (BILL_SEQUENCE_ID,SR_INSTANCE_ID) '
              ||' STORAGE (INITIAL 100K NEXT 1M PCTINCREASE 0) ',
                           object_name => 'MSC_ST_BOM_COMPONENTS_'||lv_icode);

         EXCEPTION
            WHEN OTHERS THEN
               MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);

         END;
         msc_analyse_tables_pk.analyse_table( 'MSC_ST_BOM_COMPONENTS');

         LOAD_CO_PRODUCT_BOMS;

         BEGIN
          ad_ddl.do_ddl( applsys_schema => v_applsys_schema,
                         application_short_name => 'MSC',
                         statement_type => AD_DDL.DROP_INDEX,
                         statement =>
                'drop index MSC_ST_BOM_COMPONENTS_'||lv_icode,
                         object_name => 'MSC_ST_BOM_COMPONENTS_'||lv_icode);
         EXCEPTION
            WHEN OTHERS THEN
               MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);

         END;

End If;


END IF;  -- MSC_CL_PULL.BOM_ENABLED

END LOAD_BOM;


   PROCEDURE LOAD_PROCESS_EFFECTIVITY IS
    v_get_apps_ver number;
   BEGIN

IF MSC_CL_PULL.BOM_ENABLED= MSC_UTIL.SYS_YES THEN
--=================== Net Change Mode: Delete ==================
IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh

MSC_CL_PULL.v_table_name:= 'MSC_ST_PROCESS_EFFECTIVITY';
MSC_CL_PULL.v_view_name := 'MRP_AD_PROCESS_EFFECTIVITY_V';

v_sql_stmt:=
' INSERT INTO MSC_ST_PROCESS_EFFECTIVITY'
||'  ( ITEM_ID,'
||'    ORGANIZATION_ID,'
||'    BILL_SEQUENCE_ID,'
||'    ROUTING_SEQUENCE_ID,'
||'    LINE_ID,'
||'    DELETED_FLAG,'
||'    REFRESH_ID,'
||'    SR_INSTANCE_ID)'
||'  SELECT'
||'    x.INVENTORY_ITEM_ID,'
||'    x.ORGANIZATION_ID,'
||'    x.BILL_SEQUENCE_ID,'
||'    x.ROUTING_SEQUENCE_ID,'
||'    x.LINE_ID,'
||'    1,'
||'    :v_refresh_id,'
||'    :v_instance_id'
||'  FROM MRP_AD_PROCESS_EFFECTIVITY_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.RN>'||MSC_CL_PULL.v_lrn
||' AND x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str;

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

COMMIT;

END IF;

MSC_CL_PULL.v_table_name:= 'MSC_ST_PROCESS_EFFECTIVITY';
MSC_CL_PULL.v_view_name := 'MRP_AP_PROCESS_EFFECTIVITY_V';
IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh
v_union_sql :=
'   AND ( x.RN2>'||MSC_CL_PULL.v_lrn||')'
/*
||' UNION '
||'  SELECT'
||'    x.INVENTORY_ITEM_ID,'
||'    x.ORGANIZATION_ID,'
||'    x.BILL_SEQUENCE_ID,'
||'    x.ROUTING_SEQUENCE_ID,'
||'    x.EFFECTIVITY_DATE,'
||'    x.LINE_ID,'
||'    x.PREFERENCE,'
||'    x.PRIMARY_LINE_FLAG,'
||'    x.PRODUCTION_LINE_RATE,'
||'    x.LOAD_DISTRIBUTION_PRIORITY,'
||'    NVL( TO_NUMBER(DECODE( :v_msc_alt_bom_cost,'
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
     ||'       15, x.Attribute15)),0),'
||'    2,'
||'  :v_refresh_id,'
||'    :v_instance_id'
||'  FROM MRP_AP_PROCESS_EFFECTIVITY_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'   AND ( x.RN1>'||MSC_CL_PULL.v_lrn||')'
*/

||' UNION '
||'  SELECT'
||'    x.INVENTORY_ITEM_ID,'
||'    x.ORGANIZATION_ID,'
||'    x.BILL_SEQUENCE_ID,'
||'    x.ROUTING_SEQUENCE_ID,'
||'    x.EFFECTIVITY_DATE,'
||'    x.LINE_ID,'
||'    x.PREFERENCE,'
||'    x.PRIMARY_LINE_FLAG,'
||'    x.PRODUCTION_LINE_RATE,'
||'    x.LOAD_DISTRIBUTION_PRIORITY,'
||'    NVL( TO_NUMBER(DECODE( :v_msc_alt_bom_cost,'
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
     ||'       15, x.Attribute15)),0),'
||'    2,'
||'  :v_refresh_id,'
||'    :v_instance_id'
||'  FROM MRP_AP_PROCESS_EFFECTIVITY_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'   AND ( x.RN3>'||MSC_CL_PULL.v_lrn||')'
||' UNION '
||'  SELECT'
||'    x.INVENTORY_ITEM_ID,'
||'    x.ORGANIZATION_ID,'
||'    x.BILL_SEQUENCE_ID,'
||'    x.ROUTING_SEQUENCE_ID,'
||'    x.EFFECTIVITY_DATE,'
||'    x.LINE_ID,'
||'    x.PREFERENCE,'
||'    x.PRIMARY_LINE_FLAG,'
||'    x.PRODUCTION_LINE_RATE,'
||'    x.LOAD_DISTRIBUTION_PRIORITY,'
||'    NVL( TO_NUMBER(DECODE( :v_msc_alt_bom_cost,'
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
     ||'       15, x.Attribute15)),0),'
||'    2,'
||'  :v_refresh_id,'
||'    :v_instance_id'
||'  FROM MRP_AP_PROCESS_EFFECTIVITY_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'   AND ( x.RN4>'||MSC_CL_PULL.v_lrn||')';
/*
||' UNION '
||'  SELECT'
||'    x.INVENTORY_ITEM_ID,'
||'    x.ORGANIZATION_ID,'
||'    x.BILL_SEQUENCE_ID,'
||'    x.ROUTING_SEQUENCE_ID,'
||'    x.EFFECTIVITY_DATE,'
||'    x.LINE_ID,'
||'    x.PREFERENCE,'
||'    x.PRIMARY_LINE_FLAG,'
||'    x.PRODUCTION_LINE_RATE,'
||'    x.LOAD_DISTRIBUTION_PRIORITY,'
||'    NVL( TO_NUMBER(DECODE( :v_msc_alt_bom_cost,'
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
     ||'       15, x.Attribute15)),0),'
||'    2,'
||'  :v_refresh_id,'
||'    :v_instance_id'
||'  FROM MRP_AP_PROCESS_EFFECTIVITY_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'   AND ( x.RN5>'||MSC_CL_PULL.v_lrn||')' ;
*/
ELSE
v_union_sql :=
'   AND (x.RN1>'||MSC_CL_PULL.v_lrn
||'    OR x.RN2>'||MSC_CL_PULL.v_lrn
||'    OR x.RN3>'||MSC_CL_PULL.v_lrn
||'    OR x.RN4>'||MSC_CL_PULL.v_lrn||')';

END IF;

v_sql_stmt:=
' INSERT INTO MSC_ST_PROCESS_EFFECTIVITY'
||'  ( ITEM_ID,'
||'    ORGANIZATION_ID,'
||'    BILL_SEQUENCE_ID,'
||'    ROUTING_SEQUENCE_ID,'
||'    EFFECTIVITY_DATE,'
||'    LINE_ID,'
||'    PREFERENCE,'
||'    PRIMARY_LINE_FLAG,'
||'    PRODUCTION_LINE_RATE,'
||'    LOAD_DISTRIBUTION_PRIORITY,'
||'    ITEM_PROCESS_COST,'
||'    DELETED_FLAG,'
||'    REFRESH_ID,'
||'    SR_INSTANCE_ID)'
||'  SELECT'
||'    x.INVENTORY_ITEM_ID,'
||'    x.ORGANIZATION_ID,'
||'    x.BILL_SEQUENCE_ID,'
||'    x.ROUTING_SEQUENCE_ID,'
||'    x.EFFECTIVITY_DATE,'
||'    x.LINE_ID,'
||'    x.PREFERENCE,'
||'    x.PRIMARY_LINE_FLAG,'
||'    x.PRODUCTION_LINE_RATE,'
||'    x.LOAD_DISTRIBUTION_PRIORITY,'
||'    NVL( TO_NUMBER(DECODE( :v_msc_alt_bom_cost,'
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
     ||'       15, x.Attribute15)),0),'
||'    2,'
||'  :v_refresh_id,'
||'    :v_instance_id'
||'  FROM MRP_AP_PROCESS_EFFECTIVITY_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
|| v_union_sql ;

IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_msc_alt_bom_cost,
                                   MSC_CL_PULL.v_refresh_id,
                                   MSC_CL_PULL.v_instance_id,
                                   MSC_CL_PULL.v_msc_alt_bom_cost,
                                   MSC_CL_PULL.v_refresh_id,
                                   MSC_CL_PULL.v_instance_id,
                                   MSC_CL_PULL.v_msc_alt_bom_cost,
                                   MSC_CL_PULL.v_refresh_id,
                                   MSC_CL_PULL.v_instance_id;

/*
                                   MSC_CL_PULL.v_msc_alt_bom_cost,
                                   MSC_CL_PULL.v_refresh_id,
                                   MSC_CL_PULL.v_instance_id,
                                   MSC_CL_PULL.v_msc_alt_bom_cost,
                                   MSC_CL_PULL.v_refresh_id,
                                   MSC_CL_PULL.v_instance_id;
*/

ELSE
EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_msc_alt_bom_cost,
                                   MSC_CL_PULL.v_refresh_id,
                                   MSC_CL_PULL.v_instance_id;
END IF;
COMMIT;

END IF;  -- MSC_CL_PULL.BOM_ENABLED

   END LOAD_PROCESS_EFFECTIVITY;


-- ===============================================================

   PROCEDURE LOAD_BOR IS
   BEGIN

MSC_CL_PULL.v_table_name:= 'MSC_ST_BILL_OF_RESOURCES';
MSC_CL_PULL.v_view_name := 'MRP_AP_BILL_OF_RESOURCES_V';

v_sql_stmt:=
' insert into MSC_ST_BILL_OF_RESOURCES'
||'  ( BILL_OF_RESOURCES,'
||'    ORGANIZATION_ID,'
||'    DESCRIPTION,'
||'    DISABLE_DATE,'
||'    ROLLUP_START_DATE,'
||'    ROLLUP_COMPLETION_DATE,'
||'    DELETED_FLAG,'
||'   REFRESH_ID,'
||'    SR_INSTANCE_ID)'
||'  select'
||'    x.BILL_OF_RESOURCES,'
||'    x.ORGANIZATION_ID,'
||'    x.DESCRIPTION,'
||'    x.DISABLE_DATE- :v_dgmt,'
||'    x.ROLLUP_START_DATE- :v_dgmt,'
||'    x.ROLLUP_COMPLETION_DATE- :v_dgmt,'
||'    2,'
||'  :v_refresh_id,'
||'    :v_instance_id'
||'  from MRP_AP_BILL_OF_RESOURCES_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'   AND (x.RN1>'||MSC_CL_PULL.v_lrn
||'    OR x.RN2>'||MSC_CL_PULL.v_lrn||')';

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

COMMIT;

MSC_CL_PULL.v_table_name:= 'MSC_ST_BOR_REQUIREMENTS';
MSC_CL_PULL.v_view_name := 'MRP_AP_CRP_RESOURCE_HOURS_V';

v_sql_stmt:=
' insert into MSC_ST_BOR_REQUIREMENTS'
||'  ( BILL_OF_RESOURCES,'
||'    ORGANIZATION_ID,'
||'    ASSEMBLY_ITEM_ID,'
||'    SOURCE_ITEM_ID,'
||'    RESOURCE_ID,'
||'    RESOURCE_DEPARTMENT_HOURS,'
||'    OPERATION_SEQUENCE_ID,'
||'    OPERATION_SEQ_NUM,'
||'    RESOURCE_SEQ_NUM,'
||'    SETBACK_DAYS,'
||'    DEPARTMENT_ID,'
||'    ASSEMBLY_USAGE,'
||'    ORIGINATION_TYPE,'
||'    RESOURCE_UNITS,'
||'    BASIS,'
||'    DELETED_FLAG,'
||'   REFRESH_ID,'
||'    SR_INSTANCE_ID)'
||'  select'
||'    x.BILL_OF_RESOURCES,'
||'    x.ORGANIZATION_ID,'
||'    x.ASSEMBLY_ITEM_ID,'
||'    x.SOURCE_ITEM_ID,'
||'    x.RESOURCE_ID,'
||'    x.RESOURCE_DEPARTMENT_HOURS,'
||'    x.OPERATION_SEQUENCE_ID,'
||'    x.OPERATION_SEQ_NUM,'
||'    x.RESOURCE_SEQ_NUM,'
||'    x.SETBACK_DAYS,'
||'    NVL(x.DEPARTMENT_ID, x.LINE_ID),'
||'    NVL(x.ASSEMBLY_USAGE,1),'
||'    x.ORIGINATION_TYPE,'
||'    NVL(x.RESOURCE_UNITS,1),'
||'    x.BASIS,'
||'    2,'
||'  :v_refresh_id,'
||'    :v_instance_id'
||'  from MRP_AP_CRP_RESOURCE_HOURS_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE DECODE( :WIP_ENABLED, 2, LINE_ID) IS NULL'
||'   AND x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'   AND ( x.RN1>'||MSC_CL_PULL.v_lrn
||'        OR x.RN2>'||MSC_CL_PULL.v_lrn
||'        OR x.RN3>'||MSC_CL_PULL.v_lrn||')';

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id, MSC_CL_PULL.WIP_ENABLED;

COMMIT;

   END LOAD_BOR;


--==================================================================

   PROCEDURE LOAD_RESOURCE IS

   -- for the fix 2490553 (WPS Integration)
   lv_inflate_wip   NUMBER;
   v_res_hrs_left   VARCHAR2(400);
   v_res_hrs_sql    VARCHAR2(300);
   v_temp_parent_seq VARCHAR2(500);
   v_temp_atp_rule_sql VARCHAR2(400);
   v_temp_atp_rule_sql1 VARCHAR2(400);
   lv_lbj_details NUMBER :=0;
   lv_cond_sql VARCHAR2(100) := null;
   lv_op_seq_num VARCHAR2(100) := null;
   lv_hint          VARCHAR2(300);
   v_touch_time     VARCHAR2(300);
   lv_qty_sql_temp  VARCHAR2(300);


   BEGIN

MSC_CL_PULL.v_table_name:= 'MSC_ST_DEPARTMENT_RESOURCES';
MSC_CL_PULL.v_view_name := 'MRP_AP_DEPARTMENT_RESOURCES_V';
IF MSC_CL_PULL.v_apps_ver>= MSC_UTIL.G_APPS115 THEN
  v_temp_atp_rule_sql := 'x.ATP_RULE_ID,x.SCHEDULE_TO_INSTANCE,x.BATCHING_PENALTY,x.SETUP_TIME_PERCENT,x.UTILIZATION_CHANGE_PERCENT,x.SETUP_TIME_TYPE,x.UTILIZATION_CHANGE_TYPE,x.IDLE_TIME_TOLERANCE,x.SDS_SCHEDULING_WINDOW,';
ELSE
  v_temp_atp_rule_sql := 'NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,';
END IF;
IF MSC_CL_PULL.v_apps_ver>= MSC_UTIL.G_APPS115 THEN
  v_temp_atp_rule_sql1 := 'x.ATP_RULE_ID,x.SETUP_TIME_PERCENT,x.UTILIZATION_CHANGE_PERCENT,x.SETUP_TIME_TYPE,x.UTILIZATION_CHANGE_TYPE,';
ELSE
  v_temp_atp_rule_sql1 := 'NULL,NULL,NULL,NULL,NULL,';
END IF;


/* The code is forked since the Resource Batching flexfields are replaced by the columns
   in Patchset - G for 11i source only
*/

IF (MSC_CL_PULL.v_apps_ver>= MSC_UTIL.G_APPS115) THEN
v_sql_stmt:=
' insert into MSC_ST_DEPARTMENT_RESOURCES'
||' ( RESOURCE_ID,'
||'   DEPARTMENT_ID,'
||'   LINE_FLAG,'
||'   OWNING_DEPARTMENT_ID,'
||'   CAPACITY_UNITS,'
||'   RESOURCE_GROUP_NAME,'
||'   ORGANIZATION_ID,'
||'   DEPARTMENT_CODE,'
||'   DEPARTMENT_CLASS,'
||'   DEPARTMENT_DESCRIPTION,'
||'   RESOURCE_CODE,'
||'   RESOURCE_DESCRIPTION,'
||'   OVER_UTILIZED_PERCENT,'
||'   UNDER_UTILIZED_PERCENT,'
||'   RESOURCE_SHORTAGE_TYPE,'
||'   RESOURCE_EXCESS_TYPE,'
||'   PLANNING_EXCEPTION_SET,'
||'   USER_TIME_FENCE,'
||'   AGGREGATED_RESOURCE_FLAG,'
||'   AGGREGATED_RESOURCE_ID,'
||'   RESOURCE_TYPE,'
||'   DISABLE_DATE,'
||'   AVAILABLE_24_HOURS_FLAG,'
||'   CTP_FLAG,'
||'   UTILIZATION,'
||'   EFFICIENCY,'
||'   BATCHABLE_FLAG,'
||'   BATCHING_WINDOW,'
||'   MIN_CAPACITY,'
||'   MAX_CAPACITY,'
||'   UNIT_OF_MEASURE,'
||'   RESOURCE_COST,'
||'   RESOURCE_OVER_UTIL_COST,'
||'   DEPT_OVERHEAD_COST,'
||'   DELETED_FLAG,'
||'   REFRESH_ID,'
||'   ATP_RULE_ID,'
||'   SCHEDULE_TO_INSTANCE,'  /* ds change */
||'   BATCHING_PENALTY,'
||'   SETUP_TIME_PERCENT,'
||'   UTILIZATION_CHANGE_PERCENT,'
||'   SETUP_TIME_TYPE,'
||'   UTILIZATION_CHANGE_TYPE,'
||'   IDLE_TIME_TOLERANCE,'
||'   SDS_SCHEDULING_WINDOW,' /* ds change */
||'   SR_INSTANCE_ID)'
||'  select'
||'    x.RESOURCE_ID,'
||'    x.DEPARTMENT_ID,'
||'    x.LINE_FLAG,'
||'    x.OWNING_DEPARTMENT_ID,'
||'    x.CAPACITY_UNITS,'
||'    x.RESOURCE_GROUP_NAME,'
||'    x.ORGANIZATION_ID,'
||'    x.DEPARTMENT_CODE,'
||'    x.DEPARTMENT_CLASS,'
||'    x.DEPARTMENT_DESCRIPTION,'
||'    x.RESOURCE_CODE,'
||'    x.RESOURCE_DESCRIPTION,'
||'    x.OVER_UTILIZED_PERCENT,'
||'    x.UNDER_UTILIZED_PERCENT,'
||'    x.RESOURCE_SHORTAGE_TYPE,'
||'    x.RESOURCE_EXCESS_TYPE,'
||'    x.PLANNING_EXCEPTION_SET,'
||'    x.USER_TIME_FENCE,'
||'    DECODE( TO_NUMBER(DECODE( :v_msc_aggreg_res_name,'
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
                  ||'            15, x.Attribute15)*2),'
||'            x.RESOURCE_ID, 1,'
||'            2),'
||'    TO_NUMBER(DECODE( :v_msc_aggreg_res_name,'
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
||'            15, x.Attribute15)*2),'
||'    x.RESOURCE_TYPE,'
||'    x.DISABLE_DATE- :v_dgmt,'
||'    x.AVAILABLE_24_HOURS_FLAG,'
||'    x.CTP_FLAG,'
||'    x.UTILIZATION,'
||'    x.EFFICIENCY,'
||'    x.BATCHABLE,'
||'    x.BATCH_WINDOW,'
||'    x.MIN_BATCH_CAPACITY,'
||'    x.MAX_BATCH_CAPACITY,'
||'    x.BATCH_CAPACITY_UOM,'
||'    x.RESOURCE_COST,'
||'    TO_NUMBER(DECODE( :v_mso_res_penalty,'
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
||'            15, x.Attribute15)),'
||'    x.DEPT_OVERHEAD_COST,'
||'    2,'
||'  :v_refresh_id,'
||   v_temp_atp_rule_sql
||'    :v_instance_id'
||'  from MRP_AP_DEPARTMENT_RESOURCES_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str;

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_msc_aggreg_res_name,
                                   MSC_CL_PULL.v_msc_aggreg_res_name,
                                   MSC_CL_PULL.v_dgmt,
                                   MSC_CL_PULL.v_mso_res_penalty,
                                   MSC_CL_PULL.v_refresh_id,
                                   MSC_CL_PULL.v_instance_id;
ELSE
v_sql_stmt:=
' insert into MSC_ST_DEPARTMENT_RESOURCES'
||' ( RESOURCE_ID,'
||'   DEPARTMENT_ID,'
||'   LINE_FLAG,'
||'   OWNING_DEPARTMENT_ID,'
||'   CAPACITY_UNITS,'
||'   RESOURCE_GROUP_NAME,'
||'   ORGANIZATION_ID,'
||'   DEPARTMENT_CODE,'
||'   DEPARTMENT_CLASS,'
||'   DEPARTMENT_DESCRIPTION,'
||'   RESOURCE_CODE,'
||'   RESOURCE_DESCRIPTION,'
||'   OVER_UTILIZED_PERCENT,'
||'   UNDER_UTILIZED_PERCENT,'
||'   RESOURCE_SHORTAGE_TYPE,'
||'   RESOURCE_EXCESS_TYPE,'
||'   PLANNING_EXCEPTION_SET,'
||'   USER_TIME_FENCE,'
||'   AGGREGATED_RESOURCE_FLAG,'
||'   AGGREGATED_RESOURCE_ID,'
||'   RESOURCE_TYPE,'
||'   DISABLE_DATE,'
||'   AVAILABLE_24_HOURS_FLAG,'
||'   CTP_FLAG,'
||'   UTILIZATION,'
||'   EFFICIENCY,'
||'   BATCHABLE_FLAG,'
||'   BATCHING_WINDOW,'
||'   MIN_CAPACITY,'
||'   MAX_CAPACITY,'
||'   UNIT_OF_MEASURE,'
||'   RESOURCE_COST,'
||'   RESOURCE_OVER_UTIL_COST,'
||'   DEPT_OVERHEAD_COST,'
||'   DELETED_FLAG,'
||'   REFRESH_ID,'
||'   ATP_RULE_ID,'
||'   SCHEDULE_TO_INSTANCE,' /* ds change */
||'   BATCHING_PENALTY,'
||'   SETUP_TIME_PERCENT,'
||'   UTILIZATION_CHANGE_PERCENT,'
||'   SETUP_TIME_TYPE,'
||'   UTILIZATION_CHANGE_TYPE,'
||'   IDLE_TIME_TOLERANCE,'
||'   SDS_SCHEDULING_WINDOW,' /* ds change */
||'   SR_INSTANCE_ID)'
||'  select'
||'    x.RESOURCE_ID,'
||'    x.DEPARTMENT_ID,'
||'    x.LINE_FLAG,'
||'    x.OWNING_DEPARTMENT_ID,'
||'    x.CAPACITY_UNITS,'
||'    x.RESOURCE_GROUP_NAME,'
||'    x.ORGANIZATION_ID,'
||'    x.DEPARTMENT_CODE,'
||'    x.DEPARTMENT_CLASS,'
||'    x.DEPARTMENT_DESCRIPTION,'
||'    x.RESOURCE_CODE,'
||'    x.RESOURCE_DESCRIPTION,'
||'    x.OVER_UTILIZED_PERCENT,'
||'    x.UNDER_UTILIZED_PERCENT,'
||'    x.RESOURCE_SHORTAGE_TYPE,'
||'    x.RESOURCE_EXCESS_TYPE,'
||'    x.PLANNING_EXCEPTION_SET,'
||'    x.USER_TIME_FENCE,'
||'    DECODE( TO_NUMBER(DECODE( :v_msc_aggreg_res_name,'
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
                  ||'            15, x.Attribute15)),'
||'            x.RESOURCE_ID, 1,'
||'            2),'
||'    TO_NUMBER(DECODE( :v_msc_aggreg_res_name,'
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
||'            15, x.Attribute15)),'
||'    x.RESOURCE_TYPE,'
||'    x.DISABLE_DATE- :v_dgmt,'
||'    x.AVAILABLE_24_HOURS_FLAG,'
||'    x.CTP_FLAG,'
||'    x.UTILIZATION,'
||'    x.EFFICIENCY,'
||'    TO_NUMBER(DECODE( :v_msc_batchable_flag,'
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
||'            15, x.Attribute15,Null)) ,'
||'    TO_NUMBER(DECODE( :v_msc_batching_window,'
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
||'            15, x.Attribute15,Null)) ,'
||'    TO_NUMBER(DECODE( :v_msc_min_capacity,'
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
||'            15, x.Attribute15,Null)) ,'
||'    TO_NUMBER(DECODE( :v_msc_max_capacity,'
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
||'            15, x.Attribute15,Null)) ,'
||'    DECODE( :v_msc_unit_of_measure,'
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
||'            15, x.Attribute15,Null) ,'
||'    x.RESOURCE_COST,'
||'    TO_NUMBER(DECODE( :v_mso_res_penalty,'
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
||'            15, x.Attribute15)),'
||'    x.DEPT_OVERHEAD_COST,'
||'    2,'
||'  :v_refresh_id,'
||   v_temp_atp_rule_sql
||'    :v_instance_id'
||'  FROM MRP_AP_DEPARTMENT_RESOURCES_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str;

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_msc_aggreg_res_name,
                                   MSC_CL_PULL.v_msc_aggreg_res_name,
                                   MSC_CL_PULL.v_dgmt,
                                   MSC_CL_PULL.v_msc_batchable_flag,
                                   MSC_CL_PULL.v_msc_batching_window,
                                   MSC_CL_PULL.v_msc_min_capacity,
                                   MSC_CL_PULL.v_msc_max_capacity,
                                   MSC_CL_PULL.v_msc_unit_of_measure,
                                   MSC_CL_PULL.v_mso_res_penalty,
                                   MSC_CL_PULL.v_refresh_id,
                                   MSC_CL_PULL.v_instance_id;

END IF;

COMMIT;

IF ((MSC_CL_PULL.WIP_ENABLED= MSC_UTIL.SYS_YES) OR (MSC_CL_PULL.BOM_ENABLED=MSC_UTIL.SYS_YES)) THEN

MSC_CL_PULL.v_table_name:= 'MSC_ST_DEPARTMENT_RESOURCES';
MSC_CL_PULL.v_view_name := 'MRP_AP_LINE_RESOURCES_V';

IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh

v_union_sql :=
'   AND ( x.RN1 > :v_lrn )';

ELSE

v_union_sql := '     ';

END IF;


v_sql_stmt:=
' insert into MSC_ST_DEPARTMENT_RESOURCES'
||' (  ORGANIZATION_ID,'
||'    RESOURCE_ID,'
||'    DEPARTMENT_ID,'
||'    DEPARTMENT_CODE,'
||'    LINE_FLAG,'
||'    MAX_RATE,'
||'    MIN_RATE,'
||'    START_TIME,'
||'    STOP_TIME,'
||'    DEPARTMENT_DESCRIPTION,'
||'    AGGREGATED_RESOURCE_FLAG,'
||'    OVER_UTILIZED_PERCENT,'
||'    UNDER_UTILIZED_PERCENT,'
||'    RESOURCE_SHORTAGE_TYPE,'
||'    RESOURCE_EXCESS_TYPE,'
||'    PLANNING_EXCEPTION_SET,'
||'    USER_TIME_FENCE,'
||'    AVAILABLE_24_HOURS_FLAG,'
||'    CAPACITY_UNITS,'
||'    DISABLE_DATE,'
||'    DELETED_FLAG,'
||'    REFRESH_ID,'
||'    ATP_RULE_ID,'
||'    SETUP_TIME_PERCENT,'
||'    UTILIZATION_CHANGE_PERCENT,'
||'    SETUP_TIME_TYPE,'
||'    UTILIZATION_CHANGE_TYPE,'
||'    SR_INSTANCE_ID)'
||'  select'
||'    x.ORGANIZATION_ID,'
||'    -1,'
||'    x.DEPARTMENT_ID,'
||'    x.DEPARTMENT_CODE,'
||'    x.LINE_FLAG,'
||'    x.MAX_RATE,'
||'    x.MIN_RATE,'
||'    x.START_TIME,'
||'    x.STOP_TIME,'
||'    x.DEPARTMENT_DESCRIPTION,'
||'    2,'
||'    x.OVER_UTILIZED_PERCENT,'
||'    x.UNDER_UTILIZED_PERCENT,'
||'    x.RESOURCE_SHORTAGE_TYPE,'
||'    x.RESOURCE_EXCESS_TYPE,'
||'    x.PLANNING_EXCEPTION_SET,'
||'    x.USER_TIME_FENCE,'
||'    x.AVAILABLE_24_HOURS_FLAG,'
||'    x.CAPACITY_UNITS,'
||'    x.LINE_DISABLE_DATE- :v_dgmt,'
||'    2,'
||'  :v_refresh_id,'
||   v_temp_atp_rule_sql1
||'    :v_instance_id'
||'  from MRP_AP_LINE_RESOURCES_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
|| v_union_sql;

IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh

EXECUTE IMMEDIATE v_sql_stmt
            USING  MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id, MSC_CL_PULL.v_lrn;

ELSE
EXECUTE IMMEDIATE v_sql_stmt
            USING  MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;
END IF;


COMMIT;

END IF;   -- MSC_CL_PULL.WIP_ENABLED


MSC_CL_PULL.v_table_name:= 'MSC_ST_SIMULATION_SETS';
MSC_CL_PULL.v_view_name := 'MRP_AP_SIMULATION_SETS_V';

v_sql_stmt:=
'insert into MSC_ST_SIMULATION_SETS'
||'   ( ORGANIZATION_ID,'
||'     SIMULATION_SET,'
||'     DESCRIPTION,'
||'     USE_IN_WIP_FLAG,'
||'     DELETED_FLAG,'
||'   REFRESH_ID,'
||'     SR_INSTANCE_ID)'
||'  select '
||'     x.ORGANIZATION_ID,'
||'     x.SIMULATION_SET,'
||'     x.DESCRIPTION,'
||'     x.USE_IN_WIP_FLAG,'
||'     2,'
||'     :v_refresh_id,'
||'     :v_instance_id'
||'  from MRP_AP_SIMULATION_SETS_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str;

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

COMMIT;

IF MSC_CL_PULL.v_lrnn= -1 THEN     -- complete refresh

MSC_CL_PULL.v_table_name:= 'MSC_ST_RESOURCE_GROUPS';
MSC_CL_PULL.v_view_name := 'MRP_AP_RESOURCE_GROUPS_V';

v_sql_stmt:=
'insert into MSC_ST_RESOURCE_GROUPS'
||'   ( GROUP_CODE,'
||'     MEANING,'
||'     DESCRIPTION,'
||'     FROM_DATE,'
||'     TO_DATE,'
||'     ENABLED_FLAG,'
||'     DELETED_FLAG,'
||'     REFRESH_ID,'
||'     SR_INSTANCE_ID)'
||'  select '
||'     x.GROUP_CODE,'
||'     x.MEANING,'
||'     x.DESCRIPTION,'
||'     x.FROM_DATE,'
||'     x.TO_DATE,'
||'     DECODE( x.ENABLED_FLAG, ''Y'', 1 , 2),'
||'     2,'
||'     :v_refresh_id,'
||'     :v_instance_id'
||'  from MRP_AP_RESOURCE_GROUPS_V'||MSC_CL_PULL.v_dblink||' x';

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

COMMIT;

END IF;

IF MSC_CL_PULL.WIP_ENABLED= MSC_UTIL.SYS_YES THEN

IF (nvl(fnd_profile.value('MSC_INFLATE_WIP') ,'N')= 'N') THEN
  lv_inflate_wip := 2 ;
ELSE
  lv_inflate_wip := 1 ;
END IF;

 -- if the profile MSC_INFLATE_WIP is set to YES then inflating the operation resource hours by
 -- efficiency and utilization. Not inflating the operation resource hours for SDS records.
 -- for bug fix 2877975. Lot based jobs should get inflated irrespective of the profile.
IF lv_inflate_wip = 1 AND MSC_CL_PULL.v_apps_ver>= MSC_UTIL.G_APPS115 THEN
  v_res_hrs_sql := '      decode(nvl(x.PARENT_SEQ_NUM,-1),-1,x.OPERATION_HOURS_REQUIRED * (1/x.utilization)* (1/x.efficiency),x.OPERATION_HOURS_REQUIRED) ,';
  v_res_hrs_left := ' AND  (x.ENTITY_TYPE <>5 or decode(nvl(x.PARENT_SEQ_NUM,-1),-1,x.OPERATION_HOURS_REQUIRED * (1/x.utilization)* (1/x.efficiency),x.OPERATION_HOURS_REQUIRED) - x.HOURS_EXPENDED >0) ';
  v_touch_time :=  '      decode(nvl(x.PARENT_SEQ_NUM,-1),-1,x.OPERATION_HOURS_REQUIRED * (1/x.efficiency),x.OPERATION_HOURS_REQUIRED) ,';
ELSIF MSC_CL_PULL.v_apps_ver>= MSC_UTIL.G_APPS115 THEN
  v_res_hrs_sql := '      decode(x.entity_type,5, (decode(nvl(x.PARENT_SEQ_NUM,-1),-1,x.OPERATION_HOURS_REQUIRED * (1/x.utilization)* (1/x.efficiency),x.OPERATION_HOURS_REQUIRED)),x.OPERATION_HOURS_REQUIRED),';
  v_res_hrs_left := '  AND   (x.ENTITY_TYPE <>5 or decode(nvl(x.PARENT_SEQ_NUM,-1),-1,x.OPERATION_HOURS_REQUIRED * (1/x.utilization)* (1/x.efficiency),x.OPERATION_HOURS_REQUIRED) - x.HOURS_EXPENDED > 0) ';
  v_touch_time :=   '     decode(x.entity_type,5, (decode(nvl(x.PARENT_SEQ_NUM,-1),-1,x.OPERATION_HOURS_REQUIRED * (1/x.efficiency),x.OPERATION_HOURS_REQUIRED)),x.OPERATION_HOURS_REQUIRED),';
ELSE
  v_res_hrs_sql := '     x.OPERATION_HOURS_REQUIRED ,';
  v_res_hrs_left := '  AND   (x.ENTITY_TYPE <>5 or  x.OPERATION_HOURS_REQUIRED - x.HOURS_EXPENDED > 0 ) ';
  v_touch_time := '     x.OPERATION_HOURS_REQUIRED ,';
END IF;

 -- Pulling parent_seq_num and SETUP_ID from MRP_AP_RESOURCE_REQUIREMENTS_V if MSC_CL_PULL.v_apps_ver is MSC_UTIL.G_APPS115
IF MSC_CL_PULL.v_apps_ver>= MSC_UTIL.G_APPS115 THEN
  v_temp_parent_seq := 'x.PARENT_SEQ_NUM,x.SETUP_ID, x.ORIG_RESOURCE_SEQ_NUM,GROUP_SEQUENCE_ID,GROUP_SEQUENCE_NUMBER,BATCH_NUMBER,MAXIMUM_ASSIGNED_UNITS, ';
ELSE
  v_temp_parent_seq := 'NULL,NULL,NULL,NULL,NULL,NULL,NULL,';
END IF;

If MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 Then
select LBJ_DETAILS into lv_lbj_details from msc_apps_instances
                where instance_id = MSC_CL_PULL.v_instance_id ;
end if;

--=================== Net Change Mode: Delete ==================
IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh

MSC_CL_PULL.v_table_name:= 'MSC_ST_RESOURCE_REQUIREMENTS';
--MSC_CL_PULL.v_view_name := 'MRP_AD_RESOURCE_REQUIREMENTS_V';
  -- bug5996354
  if MSC_UTIL.G_COLLECT_SRP_DATA = 'Y' and MSC_CL_PULL.v_apps_ver>= MSC_UTIL.G_APPS120 then
    MSC_CL_PULL.v_view_name := 'MRP_AD_NON_IRO_ERO_RES_REQ_V';
  else
    MSC_CL_PULL.v_view_name := 'MRP_AD_RESOURCE_REQUIREMENTS_V';
  end if;
  --

IF MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 THEN
     v_temp_sql1 := ' x.RESOURCE_SEQ_NUM, ';
ELSE
     v_temp_sql1 := ' NULL, ';
END IF;

lv_op_seq_num := 'x.OPERATION_SEQ_NUM, ';

IF MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 THEN
   v_temp_sql := ' AND x.ORGANIZATION_ID '||MSC_UTIL.v_in_org_str;

   if lv_lbj_details = 1 Then
   lv_op_seq_num := ' x.COPY_OP_SEQ_NUM, ';
   end if;

ELSE
   v_temp_sql := NULL;
END IF;

v_sql_stmt:=
'insert into MSC_ST_RESOURCE_REQUIREMENTS'
||'   ( WIP_ENTITY_ID,'
||'     OPERATION_SEQ_NUM,'
||'     ORIG_RESOURCE_SEQ_NUM,'
||'     DELETED_FLAG,'
||'     REFRESH_ID,'
||'     SR_INSTANCE_ID)'
||'  select'
||'     x.WIP_ENTITY_ID,'
||      lv_op_seq_num
||      v_temp_sql1
||'     1,'
||'     :v_refresh_id,'
||'     :v_instance_id'
||'  from '||MSC_CL_PULL.v_view_name||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.RN> :v_lrn '
||'   AND DECODE( x.operation_seq_num,'
||'               NULL, DECODE( x.wip_job_type,'
||'                             1, DECODE( :v_mps_consume_profile_value,'
||'                                        1, x.WJS_MPS_NET_QTY_FLAG,'
||'                                        x.WJS_NET_QTY_FLAG), '
||'                             x.WJS_MPS_NET_QTY_FLAG),'
||'               1)= 1'
|| v_temp_sql;


EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id,
                                   MSC_CL_PULL.v_instance_id,
                                   MSC_CL_PULL.v_lrn,
                                   MSC_CL_PULL.v_mps_consume_profile_value;

COMMIT;

IF MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 Then

MSC_CL_PULL.v_table_name:= 'MSC_ST_JOB_OP_RESOURCES';
MSC_CL_PULL.v_view_name := 'MRP_AD_DJOB_SUB_OP_RESOURCES_V';

v_sql_stmt:=
'insert into MSC_ST_JOB_OP_RESOURCES'
||'  ( WIP_ENTITY_ID,'
||'    OPERATION_SEQ_NUM,'
||'    RESOURCE_SEQ_NUM,'
||'    DELETED_FLAG,'
||'    REFRESH_ID,'
||'    SR_INSTANCE_ID)'
||'  select'
||'    x.WIP_ENTITY_ID,'
||'    x.OPERATION_SEQ_NUM,'
||'    x.RESOURCE_SEQ_NUM,'
||'    1,'
||'    :v_refresh_id,'
||'    :v_instance_id'
||'  from MRP_AD_DJOB_SUB_OP_RESOURCES_V'||MSC_CL_PULL.v_dblink||' x'
||'  where x.RN> '||MSC_CL_PULL.v_lrn
||'   AND DECODE( x.operation_seq_num,'
||'               NULL, DECODE( :v_mps_consume_profile_value,'
||'                                        1, x.WJS_MPS_NET_QTY_FLAG,'
||'                                        x.WJS_NET_QTY_FLAG), '
||'               1)= 1'
|| v_temp_sql;

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id,
                                   MSC_CL_PULL.v_instance_id,
                                   MSC_CL_PULL.v_mps_consume_profile_value;

COMMIT;

END IF;

END IF;

IF MSC_CL_PULL.v_lrnn <> -1 THEN
   -- BUG 7521174
   -- No Quantity filter for net change collection.
   -- Only Refresh Number

   lv_qty_sql_temp := NULL;

ELSIF MSC_CL_PULL.V_COLLECT_COMPLETED_JOBS = 1 THEN
  lv_qty_sql_temp := '  AND DECODE( x.wip_job_type, '
||'               1, DECODE( :v_mps_consume_profile_value, '
||'                          1, x.mps_net_quantity,'
||'                          x.net_quantity), '
||'                x.net_quantity) >= 0' ;
ELSE
  lv_qty_sql_temp := '  AND DECODE( x.wip_job_type, '
||'               1, DECODE( :v_mps_consume_profile_value, '
||'                          1, x.mps_net_quantity,'
||'                          x.net_quantity), '
||'                x.net_quantity) > 0' ;
END IF;

/* set the MTQ , Firm Flag, Scheduled flag */
IF MSC_CL_PULL.v_apps_ver>= MSC_UTIL.G_APPS115 THEN
  IF lv_lbj_details =1 Then
   v_temp_sql := 'x.minimum_transfer_quantity,x.firm_flag,x.scheduled_flag, x.QUANTITY_IN_QUEUE, x.QUANTITY_RUNNING, x.QUANTITY_WAITING_TO_MOVE, x.QUANTITY_COMPLETED,'
              ||'  decode(x.ENTITY_TYPE,5,x.COPY_YIELD, x.YIELD), x.USAGE_RATE, x.Copy_op_seq_num, decode(x.ENTITY_TYPE,5,copy_STANDARD_OPERATION_CODE,Standard_Operation_Code), x.ACTIVITY_GROUP_ID, x.ALTERNATE_NUM, x.PRINCIPLE_FLAG, '
              ||' x.ACTUAL_START_DATE, x.ROUTING_SEQUENCE_ID, ';
   ELSE
   	v_temp_sql := 'x.minimum_transfer_quantity,x.firm_flag,x.scheduled_flag, x.QUANTITY_IN_QUEUE, x.QUANTITY_RUNNING, x.QUANTITY_WAITING_TO_MOVE, x.QUANTITY_COMPLETED,'
                   ||' x.YIELD, x.USAGE_RATE, x.Operation_Seq_Num, x.Standard_Operation_Code, x.ACTIVITY_GROUP_ID, x.ALTERNATE_NUM, x.PRINCIPLE_FLAG, x.ACTUAL_START_DATE, x.ROUTING_SEQUENCE_ID, ';
   	lv_cond_sql := ' AND (x.ENTITY_TYPE <> 5 OR x.OPERATION_SEQUENCE_ID is not null) ';
   END IF;
   IF MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS121 THEN
           v_temp_sql := v_temp_sql||'x.description,';
   ELSE
           v_temp_sql := v_temp_sql||'NULL,';
   END IF;
ELSIF MSC_CL_PULL.v_apps_ver= MSC_UTIL.G_APPS110 THEN
  v_temp_sql := 'x.minimum_transfer_quantity,x.firm_flag,NULL,NULL,NULL,NULL,NULL,NULL,NULL, x.OPERATION_SEQ_NUM, x.Standard_Operation_Code, NULL, NULL, NULL, NULL, NULL,NULL, ';
ELSE
  v_temp_sql := ' NULL ,NULL ,NULL,NULL,NULL,NULL,NULL,NULL,NULL, x.OPERATION_SEQ_NUM, x.Standard_Operation_Code, NULL, NULL, NULL, NULL, NULL,NULL, ';
END IF;
  -- bug5996354
  if MSC_UTIL.G_COLLECT_SRP_DATA = 'Y' and MSC_CL_PULL.v_apps_ver>= MSC_UTIL.G_APPS120 then
    MSC_CL_PULL.v_view_name := 'MRP_AP_NON_IRO_ERO_RES_REQ_V';
  else
    MSC_CL_PULL.v_view_name := 'MRP_AP_RESOURCE_REQUIREMENTS_V';
  end if;
  --


MSC_CL_PULL.v_table_name:= 'MSC_ST_RESOURCE_REQUIREMENTS';
--MSC_CL_PULL.v_view_name := 'MRP_AP_RESOURCE_REQUIREMENTS_V';
IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh

-- BUG 3036681
-- No Need to check for RN2 (on wip_discrete_jobs) as
-- the materialized view on wip_operations now has the columns from
-- wip_discrete_jobs too.
  lv_hint := ' /*+ first_rows leading(x.msi) index(x.msi MTL_SYS_ITEMS_SN_N1) index(x.wor wip_wopr_ress_sn_n2) use_nl(x.msi. x.wo x.wor) */ ';

v_union_sql :=
'  AND ( x.RN1> :v_lrn )'
||' UNION '
||'  select /*+ first_rows  leading(x.wo) index(x.wo WIP_WOPRS_SN_N1) index(x.wor wip_wopr_ress_sn_n2) use_nl(x.wo x.wor x.wor1) */ '
||'     x.DEPARTMENT_ID,'
||'     x.RESOURCE_ID,'
||'     x.ORGANIZATION_ID,'
||'     x.INVENTORY_ITEM_ID,'
||'     x.WIP_ENTITY_ID,'
||'     x.WIP_ENTITY_ID,'
||'     x.WIP_JOB_TYPE,'
||'     x.OPERATION_SEQUENCE_ID,'
||'     x.RESOURCE_SEQ_NUM,'
||'     x.FIRST_UNIT_START_DATE- :v_dgmt,'
||      v_res_hrs_sql
||'     x.HOURS_EXPENDED,'
||'    x.DEMAND_CLASS,'
||'     x.BASIS_TYPE,'
||'     x.RESOURCE_UNITS,'
||'     x.COMPLETION_DATE- :v_dgmt,'
||'     x.WIP_JOB_TYPE,'
||'     x.SCHEDULED_COMPLETION_DATE- :v_dgmt,'
||'     x.SCHEDULED_QUANTITY,'
||'     2,'
||     v_temp_sql
||'  :v_refresh_id,'
||      v_temp_parent_seq
||'     x.OPERATION_HOURS_REQUIRED,'
||      v_touch_time
||'     :v_instance_id'
||'  from '||MSC_CL_PULL.v_view_name||MSC_CL_PULL.v_dblink||' x'
||'  where x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
/*Bug#4704457 ||'  AND DECODE( x.wip_job_type, '
||'               1, DECODE( :v_mps_consume_profile_value, '
||'                          1, x.mps_net_quantity,'
||'                          x.net_quantity), '
||'                x.net_quantity) > 0'*/
|| lv_qty_sql_temp
||'  AND nvl(x.uom_code,:v_hour_uom) = :v_hour_uom'
||   v_res_hrs_left
||   lv_cond_sql
||'  AND ( x.RN2> :v_lrn )'
||' UNION '
||'  select /*+ first_rows  leading(x.wo) index(x.wo WIP_WOPRS_SN_N1) index(x.wor wip_wopr_ress_sn_n2) use_nl(x.wo x.wor x.wor1) */ '
||'     x.DEPARTMENT_ID,'
||'     x.RESOURCE_ID,'
||'     x.ORGANIZATION_ID,'
||'     x.INVENTORY_ITEM_ID,'
||'     x.WIP_ENTITY_ID,'
||'     x.WIP_ENTITY_ID,'
||'     x.WIP_JOB_TYPE,'
||'     x.OPERATION_SEQUENCE_ID,'
||'     x.RESOURCE_SEQ_NUM,'
||'     x.FIRST_UNIT_START_DATE- :v_dgmt,'
||      v_res_hrs_sql
||'     x.HOURS_EXPENDED,'
||'    x.DEMAND_CLASS,'
||'     x.BASIS_TYPE,'
||'     x.RESOURCE_UNITS,'
||'     x.COMPLETION_DATE- :v_dgmt,'
||'     x.WIP_JOB_TYPE,'
||'     x.SCHEDULED_COMPLETION_DATE- :v_dgmt,'
||'     x.SCHEDULED_QUANTITY,'
||'     2,'
||     v_temp_sql
||'  :v_refresh_id,'
||      v_temp_parent_seq
||'     x.OPERATION_HOURS_REQUIRED,'
||      v_touch_time
||'     :v_instance_id'
||'  from '||MSC_CL_PULL.v_view_name||MSC_CL_PULL.v_dblink||' x'
||'  where x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
/*Bug#4704457 ||'  AND DECODE( x.wip_job_type, '
||'               1, DECODE( :v_mps_consume_profile_value, '
||'                          1, x.mps_net_quantity,'
||'                          x.net_quantity), '
||'                x.net_quantity) > 0' */
|| lv_qty_sql_temp
||'  AND nvl(x.uom_code,:v_hour_uom) = :v_hour_uom'
||   v_res_hrs_left
||   lv_cond_sql
||'  AND ( x.RN3> :v_lrn )';

ELSE

  lv_hint := ' /*+ leading(x.wo) use_hash(x.wo x.wor x.wor1) */ ';

  v_union_sql := '     ';

END IF;

v_sql_stmt:=
'insert into MSC_ST_RESOURCE_REQUIREMENTS'
||'   ( DEPARTMENT_ID,'
||'     RESOURCE_ID,'
||'     ORGANIZATION_ID,'
||'     INVENTORY_ITEM_ID,'
||'     SUPPLY_ID,'
||'     WIP_ENTITY_ID,'
||'     SUPPLY_TYPE,'
||'     OPERATION_SEQUENCE_ID,'
||'     RESOURCE_SEQ_NUM,'
||'     START_DATE,'
||'     OPERATION_HOURS_REQUIRED,'
||'     HOURS_EXPENDED,'
||'     DEMAND_CLASS,'
||'     BASIS_TYPE,'
||'     ASSIGNED_UNITS,'
||'     END_DATE,'
||'     WIP_JOB_TYPE,'
||'     SCHEDULED_COMPLETION_DATE,'
||'     SCHEDULED_QUANTITY,'
||'     DELETED_FLAG,'
||'     MINIMUM_TRANSFER_QUANTITY,'
||'     FIRM_FLAG,'
||'     SCHEDULE_FLAG,'
||'     QUANTITY_IN_QUEUE,'
||'     QUANTITY_RUNNING,'
||'     QUANTITY_WAITING_TO_MOVE,'
||'     QUANTITY_COMPLETED,'
||'     YIELD,'
||'     USAGE_RATE,'
||'     OPERATION_SEQ_NUM,'
||'     STD_OP_CODE,'
||'     ACTIVITY_GROUP_ID,'
||'     ALTERNATE_NUMBER,'
||'     PRINCIPAL_FLAG,'
||'     ACTUAL_START_DATE,'    /* Discrete Mfg Enahancements Bug 4479276 */
||'     ROUTING_SEQUENCE_ID,'
||'     OPERATION_NAME,'
||'   REFRESH_ID,'
||'     PARENT_SEQ_NUM,'
||'     SETUP_ID,'
||'     ORIG_RESOURCE_SEQ_NUM,'
||'     GROUP_SEQUENCE_ID,'
||'     GROUP_SEQUENCE_NUMBER,'
||'     BATCH_NUMBER,'
||'     MAXIMUM_ASSIGNED_UNITS,'
||'     UNADJUSTED_RESOURCE_HOURS,'
||'     TOUCH_TIME,'
||'     SR_INSTANCE_ID)'
||'  select '|| lv_hint
||'     x.DEPARTMENT_ID,'
||'     x.RESOURCE_ID,'
||'     x.ORGANIZATION_ID,'
||'     x.INVENTORY_ITEM_ID,'
||'     x.WIP_ENTITY_ID,'
||'     x.WIP_ENTITY_ID,'
||'     x.WIP_JOB_TYPE,'
||'     x.OPERATION_SEQUENCE_ID,'
||'     x.RESOURCE_SEQ_NUM,'
||'     x.FIRST_UNIT_START_DATE- :v_dgmt,'
||      v_res_hrs_sql
||'     x.HOURS_EXPENDED,'
||'    x.DEMAND_CLASS,'
||'     x.BASIS_TYPE,'
||'     x.RESOURCE_UNITS,'
||'     x.COMPLETION_DATE- :v_dgmt,'
||'     x.WIP_JOB_TYPE,'
||'     x.SCHEDULED_COMPLETION_DATE- :v_dgmt,'
||'     x.SCHEDULED_QUANTITY,'
||'     2,'
||     v_temp_sql
||'  :v_refresh_id,'
||      v_temp_parent_seq
||'     x.OPERATION_HOURS_REQUIRED,'
||      v_touch_time
||'     :v_instance_id'
||'  from '||MSC_CL_PULL.v_view_name||MSC_CL_PULL.v_dblink||' x'
||'  where x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
/*Bug#4704457 ||'  AND DECODE( x.wip_job_type, '
||'               1, DECODE( :v_mps_consume_profile_value, '
||'                          1, x.mps_net_quantity,'
||'                          x.net_quantity), '
||'                x.net_quantity) > 0' */
|| lv_qty_sql_temp
||'  AND nvl(x.uom_code,:v_hour_uom) = :v_hour_uom'
|| v_res_hrs_left
|| lv_cond_sql
|| v_union_sql ;


IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh

  EXECUTE IMMEDIATE v_sql_stmt USING
                                 MSC_CL_PULL.v_dgmt,
                                 MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id,
                                 --MSC_CL_PULL.v_mps_consume_profile_value,
                                 MSC_CL_PULL.v_hour_uom,
                                 MSC_CL_PULL.v_hour_uom,
                                 MSC_CL_PULL.v_lrn,
                                 MSC_CL_PULL.v_dgmt,
                                 MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id,
                                 --MSC_CL_PULL.v_mps_consume_profile_value,
                                 MSC_CL_PULL.v_hour_uom,
                                 MSC_CL_PULL.v_hour_uom,
                                 MSC_CL_PULL.v_lrn,
                                 MSC_CL_PULL.v_dgmt,
                                 MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id,
                                 --MSC_CL_PULL.v_mps_consume_profile_value,
                                 MSC_CL_PULL.v_hour_uom,
                                 MSC_CL_PULL.v_hour_uom,
                                 MSC_CL_PULL.v_lrn;

ELSE

  EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_dgmt,
                                 MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id,
                                 MSC_CL_PULL.v_mps_consume_profile_value,
                                 MSC_CL_PULL.v_hour_uom,
                                 MSC_CL_PULL.v_hour_uom;
END IF;
COMMIT;

IF MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 Then

MSC_CL_PULL.v_table_name := 'MSC_ST_JOB_OP_RESOURCES';
MSC_CL_PULL.v_view_name := 'MRP_AP_DJOB_SUB_OP_RESOURCES_V';


v_sql_stmt:=
'insert into MSC_ST_JOB_OP_RESOURCES'
||'   (WIP_ENTITY_ID,'
||'    SR_INSTANCE_ID,'
||'    ORGANIZATION_ID,'
||'    OPERATION_SEQ_NUM,'
||'    RESOURCE_SEQ_NUM,'
||'    ALTERNATE_NUM,'
||'    RECOMMENDED,'
||'    RECO_START_DATE,'
||'    RECO_COMPLETION_DATE,'
||'    RESOURCE_ID,'
||'    ASSIGNED_UNITS,'
||'    USAGE_RATE_OR_AMOUNT,'
||'    UOM_CODE,'
||'    BASIS_TYPE,'
||'    RESOURCE_OFFSET_PERCENT,'
||'    SCHEDULE_SEQ_NUM,'
||'    PRINCIPAL_FLAG,'
||'    DEPARTMENT_ID,'
||'    ACTIVITY_GROUP_ID,'
||'    SCHEDULE_FLAG,'
||'    SETUP_ID,'
||'    DELETED_FLAG,'
||'    REFRESH_ID )'
||'    select '
||'    x.WIP_ENTITY_ID,'
||'    :v_instance_id,'
||'    x.ORGANIZATION_ID,'
||'    x.OPERATION_SEQ_NUM,'
||'    x.RESOURCE_SEQ_NUM,'
||'    x.ALTERNATE_NUM,'
||'    ''Y'' ,'
||'    NULL,'
||'    NULL,'
||'    x.RESOURCE_ID,'
||'    x.ASSIGNED_UNITS,'
||'    x.USAGE_RATE_OR_AMOUNT,'
||'    x.UOM_CODE,'
||'    x.BASIS_TYPE,'
||'    x.RESOURCE_OFFSET_PERCENT,'
||'    x.SCHEDULE_SEQ_NUM,'
||'    x.PRINCIPLE_FLAG,'
||'    x.DEPARTMENT_ID,'
||'    x.ACTIVITY_GROUP_ID,'
||'    x.SCHEDULE_FLAG,'
||'    x.SETUP_ID,'
||'    2,'
||'    :v_refresh_id'
||'    FROM MRP_AP_DJOB_SUB_OP_RESOURCES_V'||MSC_CL_PULL.v_dblink||' x'
||'    WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'    AND (x.RN1>' || MSC_CL_PULL.v_lrn
||'    OR x.RN2>' || MSC_CL_PULL.v_lrn
||'    OR x.RN3>' || MSC_CL_PULL.v_lrn || ' )';

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_instance_id, MSC_CL_PULL.v_refresh_id;

COMMIT;

END IF; /* MSC_UTIL.G_APPS115 */


END IF;   -- MSC_CL_PULL.WIP_ENABLED

END LOAD_RESOURCE;

/* ds change start */
PROCEDURE LOAD_RESOURCE_INSTANCE IS

   lv_inflate_wip   		NUMBER;
   v_res_hrs_sql    		VARCHAR2(300);
   v_temp_parent_seq 		VARCHAR2(100);
   lv_lbj_details 		NUMBER :=0;
   lv_cond_sql 			VARCHAR2(100) := null;
   lv_op_seq_num 		VARCHAR2(100) := null;

   BEGIN

IF ( ((MSC_CL_PULL.WIP_ENABLED= MSC_UTIL.SYS_YES) OR (MSC_CL_PULL.BOM_ENABLED=MSC_UTIL.SYS_YES)) AND
	MSC_CL_PULL.v_apps_ver>= MSC_UTIL.G_APPS115)  THEN
  MSC_CL_PULL.v_table_name:= 'MSC_ST_DEPT_RES_INSTANCES';
  MSC_CL_PULL.v_view_name := 'MRP_AP_DEPT_RES_INSTANCES_V';

     v_sql_stmt:=
     ' insert into MSC_ST_DEPT_RES_INSTANCES'
     ||' ( RESOURCE_ID,'
     ||'   DEPARTMENT_ID,'
     ||'   RES_INSTANCE_ID,'
     ||'   SERIAL_NUMBER,'
     ||'   EQUIPMENT_ITEM_ID,'
     ||'   DEPARTMENT_CODE,'
     ||'   ORGANIZATION_ID,'
     ||'   RESOURCE_CODE,'
     ||'   LAST_KNOWN_SETUP,'
     ||'   DELETED_FLAG,'
     ||'   REFRESH_ID,'
     ||'   SR_INSTANCE_ID)'
     ||'  select'
     ||'    x.RESOURCE_ID,'
     ||'    x.DEPARTMENT_ID,'
     ||'    x.RES_INSTANCE_ID,'
     ||'    x.SERIAL_NUMBER,'
     ||'   x.EQUIPMENT_ITEM_ID,'
     ||'   x.DEPARTMENT_CODE,'
     ||'   x.ORGANIZATION_ID,'
     ||'   x.RESOURCE_CODE,'
     ||'   x.LAST_KNOWN_SETUP,'
     ||'    2,'
     ||'  :v_refresh_id,'
     ||'  :v_instance_id'
     ||'  from MRP_AP_DEPT_RES_INSTANCES_V'||MSC_CL_PULL.v_dblink||' x'
     ||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str;

    --MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'to be removed: Ds debug: dept_res_instance sql = '||v_sql_stmt);
     EXECUTE IMMEDIATE v_sql_stmt USING
                MSC_CL_PULL.v_refresh_id,
             MSC_CL_PULL.v_instance_id;


    COMMIT;

  END IF;


IF ( (MSC_CL_PULL.WIP_ENABLED= MSC_UTIL.SYS_YES)  AND
	(MSC_CL_PULL.v_apps_ver>= MSC_UTIL.G_APPS115) )  THEN

    IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh
      MSC_CL_PULL.v_table_name:= 'MSC_ST_RESOURCE_INSTANCE_REQS';
      MSC_CL_PULL.v_view_name := 'MRP_AD_RES_INSTANCE_REQS_V';
      v_temp_sql := ' AND x.ORGANIZATION_ID '||MSC_UTIL.v_in_org_str;

      v_sql_stmt:=
      'insert into MSC_ST_RESOURCE_INSTANCE_REQS'
      ||'   ( WIP_ENTITY_ID,'
      ||'     OPERATION_SEQ_NUM,'
      ||'     RESOURCE_SEQ_NUM,'
      ||'     RES_INSTANCE_ID,'
      ||'     SERIAL_NUMBER,'
      ||'     DELETED_FLAG,'
      ||'     REFRESH_ID,'
      ||'     SR_INSTANCE_ID)'
      ||'  select'
      ||'     x.WIP_ENTITY_ID,'
      ||'     x.OPERATION_SEQ_NUM,'
      ||'     x.RESOURCE_SEQ_NUM,'
      ||'     x.RES_INSTANCE_ID,'
      ||'     x.SERIAL_NUMBER,'
      ||'     1,'
      ||'     :v_refresh_id,'
      ||'     :v_instance_id'
      ||'  from MRP_AD_RES_INSTANCE_REQS_V'||MSC_CL_PULL.v_dblink||' x'
      ||' WHERE x.RN > :v_lrn '
      || v_temp_sql;


    --MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Ds debug: res_instance sql = '||v_sql_stmt);
     EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id,
                                       MSC_CL_PULL.v_instance_id,
                                       MSC_CL_PULL.v_lrn;


    COMMIT;

    MSC_CL_PULL.v_table_name := 'MSC_ST_JOB_OP_RES_INSTANCES';
    MSC_CL_PULL.v_view_name := 'MRP_AD_LJ_OPR_RES_INSTS_V';


      v_sql_stmt:=
      'insert into MSC_ST_JOB_OP_RES_INSTANCES'
      ||'   ( WIP_ENTITY_ID,'
      ||'     OPERATION_SEQ_NUM,'
      ||'     RESOURCE_SEQ_NUM,'
      ||'     RES_INSTANCE_ID,'
      ||'     SERIAL_NUMBER,'
      ||'     DELETED_FLAG,'
      ||'     REFRESH_ID,'
      ||'     SR_INSTANCE_ID)'
      ||'  select'
      ||'     x.WIP_ENTITY_ID,'
      ||'     x.OPERATION_SEQ_NUM,'
      ||'     x.RESOURCE_SEQ_NUM,'
      ||'     x.RES_INSTANCE_ID,'
      ||'     x.SERIAL_NUMBER,'
      ||'     1,'
      ||'     :v_refresh_id,'
      ||'     :v_instance_id'
      ||'  from MRP_AD_LJ_OPR_RES_INSTS_V'||MSC_CL_PULL.v_dblink||' x'
      ||' WHERE x.RN > :v_lrn '
      || v_temp_sql;

      --MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Ds debug: job res_instance sql = '||v_sql_stmt);
      EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id,
                                       MSC_CL_PULL.v_instance_id,
					MSC_CL_PULL.v_lrn;
    COMMIT;

    END IF;   /* incremental */


    MSC_CL_PULL.v_table_name:= 'MSC_ST_RESOURCE_INSTANCE_REQS';
    MSC_CL_PULL.v_view_name := 'MRP_AP_RES_INSTANCE_REQS_V';


    IF lv_lbj_details <> 1 THEN
       lv_cond_sql := ' AND (x.ENTITY_TYPE <> 5 OR x.OPERATION_SEQUENCE_ID is not null) ';
    END IF;

    IF MSC_CL_PULL.v_lrnn<> -1 THEN  /* incremental */

     v_union_sql :=
       '  AND ( x.RN1> :v_lrn )'
      ||' UNION '
      ||'  select   '
      ||'     x.DEPARTMENT_ID,'
      ||'     x.RESOURCE_ID,'
      ||'     x.RES_INSTANCE_ID,'
      ||'     x.ORGANIZATION_ID,'
      --||'     x.OPERATION_SEQUENCE_ID,'
      ||'     x.OPERATION_SEQ_NUM,'
      ||'     x.RESOURCE_SEQ_NUM,'
      ||'     x.ORIG_RESOURCE_SEQ_NUM,'
      ||'     x.SERIAL_NUMBER,'
      ||'     x.EQUIPMENT_ITEM_ID,'
      ||'     x.WIP_ENTITY_ID,'
      ||'     x.WIP_ENTITY_ID,'
      ||'     x.START_DATE - :v_dgmt,'
      ||'     x.COMPLETION_DATE - :v_dgmt,'
      ||'     2,'
      ||'     :v_refresh_id,'
      ||'     :v_instance_id'
      ||'  from MRP_AP_RES_INSTANCE_REQS_V'  ||MSC_CL_PULL.v_dblink  ||' x'
      ||'  where x.ORGANIZATION_ID'  ||MSC_UTIL.v_in_org_str
      ||   lv_cond_sql
      ||'  AND ( x.RN2> :v_lrn )'
      ||' UNION '
      ||'  select   '
      ||'     x.DEPARTMENT_ID,'
      ||'     x.RESOURCE_ID,'
      ||'     x.RES_INSTANCE_ID,'
      ||'     x.ORGANIZATION_ID,'
      --||'     x.OPERATION_SEQUENCE_ID,'
      ||'     x.OPERATION_SEQ_NUM,'
      ||'     x.RESOURCE_SEQ_NUM,'
      ||'     x.ORIG_RESOURCE_SEQ_NUM,'
      ||'     x.SERIAL_NUMBER,'
      ||'     x.EQUIPMENT_ITEM_ID,'
      ||'     x.WIP_ENTITY_ID,'
      ||'     x.WIP_ENTITY_ID,'
      ||'     x.START_DATE - :v_dgmt,'
      ||'     x.COMPLETION_DATE- :v_dgmt,'
      ||'     2,'
      ||'     :v_refresh_id,'
      ||'     :v_instance_id'
      ||'  from MRP_AP_RES_INSTANCE_REQS_V'  ||MSC_CL_PULL.v_dblink  ||' x'
      ||'  where x.ORGANIZATION_ID'  ||MSC_UTIL.v_in_org_str
      ||   lv_cond_sql
      ||'  AND ( x.RN3> :v_lrn )'
      ||' UNION '
      ||'  select   '
      ||'     x.DEPARTMENT_ID,'
      ||'     x.RESOURCE_ID,'
      ||'     x.RES_INSTANCE_ID,'
      ||'     x.ORGANIZATION_ID,'
      --||'     x.OPERATION_SEQUENCE_ID,'
      ||'     x.OPERATION_SEQ_NUM,'
      ||'     x.RESOURCE_SEQ_NUM,'
      ||'     x.ORIG_RESOURCE_SEQ_NUM,'
      ||'     x.SERIAL_NUMBER,'
      ||'     x.EQUIPMENT_ITEM_ID,'
      ||'     x.WIP_ENTITY_ID,'
      ||'     x.WIP_ENTITY_ID,'
      ||'     x.START_DATE - :v_dgmt,'
      ||'     x.COMPLETION_DATE - :v_dgmt,'
      ||'     2,'
      ||'     :v_refresh_id,'
      ||'     :v_instance_id'
      ||'  from MRP_AP_RES_INSTANCE_REQS_V'  ||MSC_CL_PULL.v_dblink  ||' x'
      ||'  where x.ORGANIZATION_ID'  ||MSC_UTIL.v_in_org_str
      ||   lv_cond_sql
      ||'  AND ( x.RN4> :v_lrn )';
     ELSE   -- full

         v_union_sql := '     ';

     END IF;   /*  MSC_CL_PULL.v_lrnn<> -1 */


    v_sql_stmt:=
      'insert into MSC_ST_RESOURCE_INSTANCE_REQS'
    ||'   ( DEPARTMENT_ID,'
    ||'     RESOURCE_ID,'
    ||'     RES_INSTANCE_ID,'
    ||'     ORGANIZATION_ID,'
    --||'     OPERATION_SEQUENCE_ID,'
    ||'     OPERATION_SEQ_NUM,'
    ||'     RESOURCE_SEQ_NUM,'
    ||'     ORIG_RESOURCE_SEQ_NUM,'
    ||'     SERIAL_NUMBER,'
    ||'     EQUIPMENT_ITEM_ID,'
    ||'     SUPPLY_ID,'
    ||'     WIP_ENTITY_ID,'
    ||'     START_DATE,'
    ||'     END_DATE,'
    ||'     DELETED_FLAG,'
    ||'     REFRESH_ID,'
    ||'     SR_INSTANCE_ID)'
    ||'  select '		/*	|| lv_hint */
    ||'     x.DEPARTMENT_ID,'
    ||'     x.RESOURCE_ID,'
    ||'     x.RES_INSTANCE_ID,'
    ||'     x.ORGANIZATION_ID,'
    --||'     x.OPERATION_SEQUENCE_ID,'
    ||'     x.OPERATION_SEQ_NUM,'
    ||'     x.RESOURCE_SEQ_NUM,'
    ||'     x.ORIG_RESOURCE_SEQ_NUM,'
    ||'     x.SERIAL_NUMBER,'
    ||'     x.EQUIPMENT_ITEM_ID,'
    ||'     x.WIP_ENTITY_ID,'
    ||'     x.WIP_ENTITY_ID,'
    ||'     x.START_DATE - :v_dgmt,'
    ||'     x.COMPLETION_DATE - :v_dgmt,'
    ||'     2,'
    ||'     :v_refresh_id,'
    ||'     :v_instance_id'
    ||'  from MRP_AP_RES_INSTANCE_REQS_V'||MSC_CL_PULL.v_dblink||' x'
    ||'  where x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
    || lv_cond_sql
    || v_union_sql ;


    --MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, ' Ds debug:  insert from MRP_AP_RES_INSTANCE_REQS_V  sql = '||v_sql_stmt);
     IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh

         EXECUTE IMMEDIATE v_sql_stmt USING
                                     MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id, MSC_CL_PULL.v_lrn,
                                     MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt,  MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id, MSC_CL_PULL.v_lrn,
                                     MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt,  MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id,MSC_CL_PULL.v_lrn,
                                     MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt,  MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id,MSC_CL_PULL.v_lrn;

    ELSE

          EXECUTE IMMEDIATE v_sql_stmt USING
                                     MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;
    END IF;

    MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Number of rows for Wip Job Res Instances='|| SQL%ROWCOUNT);
    COMMIT;

    MSC_CL_PULL.v_table_name := 'MSC_ST_JOB_OP_RES_INSTANCES';
    MSC_CL_PULL.v_view_name := 'MRP_AP_JOB_RES_INSTANCES_V';


    v_sql_stmt:=
    'insert into MSC_ST_JOB_OP_RES_INSTANCES'
    ||'   (WIP_ENTITY_ID,'
    ||'    SR_INSTANCE_ID,'
    ||'    ORGANIZATION_ID,'
    ||'    OPERATION_SEQ_NUM,'
    ||'    RESOURCE_SEQ_NUM,'
    ||'    RESOURCE_ID,'
    ||'    RES_INSTANCE_ID,'
    ||'    DEPARTMENT_ID,'
    ||'    SERIAL_NUMBER,'
    ||'    EQUIPMENT_ITEM_ID,'
    ||'    START_DATE,'
    ||'    COMPLETION_DATE,'
    ||'    BATCH_NUMBER,'
    ||'    DELETED_FLAG,'
    ||'    REFRESH_ID )'
    ||'    select '
    ||'    x.WIP_ENTITY_ID,'
    ||'    :v_instance_id,'
    ||'    x.ORGANIZATION_ID,'
    ||'    x.OPERATION_SEQ_NUM,'
    ||'    x.RESOURCE_SEQ_NUM,'
    ||'    x.RESOURCE_ID,'
    ||'    x.RES_INSTANCE_ID,'
    ||'    x.DEPARTMENT_ID,'
    ||'    x.SERIAL_NUMBER,'
    ||'    x.EQUIPMENT_ITEM_ID,'
    ||'    x.START_DATE - :v_dgmt,'
    ||'    x.COMPLETION_DATE - :v_dgmt,'
    ||'    x.BATCH_NUMBER,'
    ||'    2,'
    ||'    :v_refresh_id'
    ||'    FROM MRP_AP_JOB_RES_INSTANCES_V'||MSC_CL_PULL.v_dblink||' x'
    ||'    WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
    ||'    AND (x.RN1>' || MSC_CL_PULL.v_lrn
    ||'    OR x.RN2>' || MSC_CL_PULL.v_lrn
    ||'    OR x.RN3>' || MSC_CL_PULL.v_lrn || ' )';

    --MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Ds debug:  insert from MRP_AP_JOB_RES_INSTANCES_V job res_instance sql = '||v_sql_stmt);
    EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_instance_id, MSC_CL_PULL.v_refresh_id;
    MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Number of rows for lJob Res Instances= '||SQL%ROWCOUNT);

    COMMIT;


  END IF; /* WI__ENABLED and MSC_UTIL.G_APPS115 */

END LOAD_RESOURCE_INSTANCE;


   PROCEDURE LOAD_CO_PRODUCT_BOMS IS  /*osfm change*/

   l_co_prd_grp_id        Number;
   l_bill_sequence_id          Number;
   l_usage_rate           Number;
   l_rowid                rowid;
   l_total_count          NUMBER;
   l_common_bill_seq_id   Number;
   l_split                Number;
   l_primary_flag         Number;
   v_query_str            varchar2(3000);
   v_query_str1           varchar2(6000);
   v_query_str2           varchar2(6000);
   v_query_str4           varchar2(6000);
   type cur_type is ref cursor;
   cur cur_type;
   cur1 cur_type;
   cur3 cur_type;
   v_bill_sequence_id number;
   v_co_product_id number;
   v_split number;
   v_component_type number;
   v_org_id number;
   v_comp_seq_id number;
   v_assembly_id number;
   v_primary_flag number;

   v_wsm_split_table_qry   varchar2(6000);
   v_split_table_exist     PLS_INTEGER := 0;

   v_wsm_schema     VARCHAR2(32);
   lv_retval        boolean;
   lv_dummy1        varchar2(32);
   lv_dummy2        varchar2(32);
Begin

lv_retval := FND_INSTALLATION.GET_APP_INFO ('WSM', lv_dummy1, lv_dummy2,v_wsm_schema);
-- adding this piece of code to ensure that WSM_COPRODUCT_SPLIT_PERC is used only when it exists
v_wsm_split_table_qry := 'select count(*)  from all_tables'||MSC_CL_PULL.v_dblink||
                         ' where owner=:v_wsm_schema and table_name = ''WSM_COPRODUCT_SPLIT_PERC''';

EXECUTE IMMEDIATE v_wsm_split_table_qry into v_split_table_exist using v_wsm_schema;

IF nvl(v_split_table_exist,0) = 0 THEN

   -- old behaviour
   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'WSM_COPRODUCT_SPLIT_PERC does not exist. Using split from WSM_CO_PRODUCTS');

   v_query_str := 'Select bill_sequence_id*2,co_product_id,split,decode(nvl(primary_flag,''N''),''N'',2,1) primary_flag from wsm_co_products'||MSC_CL_PULL.v_dblink||
                 ' where bill_sequence_id <>:v_bill_seq_id and  bill_sequence_id is not null
                   and co_product_group_id = :v_co_prd_grp_id and split > 0';
   v_query_str1 := 'select wsc.co_product_group_id,
       wsc.bill_Sequence_id*2,
       co_product_id,
       bom.common_bill_Sequence_id,
       wsc.usage_rate,
       wsc.split,
       decode(nvl(wsc.primary_flag,''N''),''N'',2,1) primary_flag,
       bom.rowid
   from wsm_Co_products'||MSC_CL_PULL.v_dblink||' wsc,
     msc_st_boms bom
   where wsc.bill_sequence_id is not null
   and   wsc.split > 0    -- Added this for bug:2208074
   and   wsc.bill_Sequence_id*2 = bom.bill_Sequence_id';

ELSE
   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'WSM_COPRODUCT_SPLIT_PERC Exists');

   v_query_str := 'Select wsc.bill_sequence_id*2,
                   wsc.co_product_id,
                   perc.split,
                   decode(nvl(wsc.primary_flag,''N''),''N'',2,1) primary_flag
                   from wsm_co_products'||MSC_CL_PULL.v_dblink|| ' wsc,
                   wsm_coproduct_split_perc'||MSC_CL_PULL.v_dblink||' perc
                   where wsc.bill_sequence_id <>:v_bill_seq_id
                   and   wsc.bill_sequence_id is not null
                   and   wsc.co_product_group_id = :v_co_prd_grp_id
                   and   perc.co_product_group_id = wsc.co_product_group_id
                   and   perc.co_product_id = wsc.co_product_id
                   and   sysdate < nvl(perc.disable_date,sysdate + 1)
                   and   perc.split > 0';

   v_query_str1 := 'select wsc.co_product_group_id,
       wsc.bill_Sequence_id*2,
       wsc.co_product_id,
       bom.common_bill_Sequence_id,
       wsc.usage_rate,
       perc.split,
       decode(nvl(wsc.primary_flag,''N''),''N'',2,1) primary_flag,
       bom.rowid
       from wsm_Co_products'||MSC_CL_PULL.v_dblink||' wsc,
       wsm_coproduct_split_perc'||MSC_CL_PULL.v_dblink||' perc,
       msc_st_boms bom
       where wsc.bill_sequence_id is not null
       and   wsc.bill_Sequence_id*2 = bom.bill_Sequence_id
       and   perc.co_product_group_id = wsc.co_product_group_id
       and   perc.co_product_id = wsc.co_product_id
       and   sysdate < nvl(perc.disable_date,sysdate + 1)
       and   perc.split>0';

END IF;

OPEN cur FOR v_query_str1;

  LOOP

  FETCH cur INTO
l_co_prd_grp_id,l_bill_sequence_id,v_assembly_id,l_common_bill_seq_id,l_usage_rate,l_split,
l_primary_flag,l_rowid
;
        EXIT WHEN cur%NOTFOUND;


OPEN cur1 FOR v_query_str USING l_bill_sequence_id/2,l_co_prd_grp_id;


  LOOP


        FETCH cur1 INTO v_bill_sequence_id,v_co_product_id,v_split,v_primary_flag ;
        EXIT WHEN cur1%NOTFOUND;


    /* set the primary_flag for the actual component to "not a primary" */

    v_query_str4 :=

    'update MSC_ST_BOM_COMPONENTS x
    set x.primary_flag = 2
    WHERE x.bill_Sequence_id='||l_BILL_SEQuence_ID ||
    ' and x.primary_flag is null
      and nvl(x.component_type,0) != 10
      and x.usage_quantity > 0
      and x.inventory_item_id in
     (select wsm.component_id from wsm_co_products' ||MSC_CL_PULL.v_dblink||' wsm
                              where wsm.bill_sequence_id ='|| l_bill_sequence_id/2||')';

     EXECUTE IMMEDIATE v_query_str4;


    insert into MSC_ST_BOM_COMPONENTS
  ( COMPONENT_SEQUENCE_ID,
    INVENTORY_ITEM_ID,
    BILL_SEQUENCE_ID,
    OPERATION_SEQ_NUM,
    COMPONENT_TYPE,
    USAGE_QUANTITY,
    COMPONENT_YIELD_FACTOR,
    EFFECTIVITY_DATE,
    DISABLE_DATE,
    OPERATION_OFFSET_PERCENT,
    OPTIONAL_COMPONENT,
    WIP_SUPPLY_TYPE,
    PLANNING_FACTOR,
    REVISED_ITEM_SEQUENCE_ID,
    ATP_FLAG,
    STATUS_TYPE,
    USE_UP_CODE,
    CHANGE_NOTICE,
    ORGANIZATION_ID,
    USING_ASSEMBLY_ID,
    FROM_UNIT_NUMBER,
    TO_UNIT_NUMBER,
    DRIVING_ITEM_ID,
    DELETED_FLAG,
    REFRESH_ID,
    SR_INSTANCE_ID,
    PRIMARY_FLAG,
    ROUNDING_DIRECTION)
    select
    BOM_INVENTORY_COMPONENTS_S.NEXTVAL,
    v_co_product_id,
    l_BILL_SEQuence_ID,
    x.OPERATION_SEQ_NUM,
    10,
    -(v_split/100),
    x.COMPONENT_YIELD_FACTOR,
    x.EFFECTIVITY_DATE,
    x.DISABLE_DATE,
    x.OPERATION_OFFSET_PERCENT,
    x.OPTIONAL_COMPONENT,
    x.WIP_SUPPLY_TYPE,
    x.PLANNING_FACTOR,
    x.REVISED_ITEM_SEQUENCE_ID,
    x.ATP_FLAG,
    x.STATUS_TYPE,
    x.USE_UP_CODE,
    x.CHANGE_NOTICE,
    x.ORGANIZATION_ID,
    v_assembly_id,
    x.FROM_UNIT_NUMBER,
    x.TO_UNIT_NUMBER,
    x.DRIVING_ITEM_ID,
    2,
    refresh_id,
    sr_instance_id,
    v_primary_flag,
    3
    from MSC_ST_BOM_COMPONENTS x
    WHERE x.bill_Sequence_id = l_BILL_SEQuence_ID
    and   x.sr_instance_id = MSC_CL_PULL.v_instance_id
    and rownum = 1;

End loop;

    update msc_st_boms
    set assembly_quantity = (l_split/100)
    where rowid = l_rowid;

ENd loop;

    COMMIT;

   END LOAD_CO_PRODUCT_BOMS; /*osfm change */


--==================================================================
/* ds change start change */

PROCEDURE LOAD_RESOURCE_SETUP IS
 BEGIN

 IF (MSC_CL_PULL.BOM_ENABLED=MSC_UTIL.SYS_YES) THEN
   IF MSC_CL_PULL.v_apps_ver>= MSC_UTIL.G_APPS115 THEN

   MSC_CL_PULL.v_table_name:= 'MSC_ST_RESOURCE_SETUPS';
   MSC_CL_PULL.v_view_name := 'MRP_AP_RESOURCE_SETUPS_V';

    v_sql_stmt:=
	' insert into MSC_ST_RESOURCE_SETUPS'
	||' ( RESOURCE_ID,'
	||'   ORGANIZATION_ID,'
	--||'   DEPARTMENT_ID,'
	||'   SETUP_ID,'
	||'   SETUP_CODE,'
	||'   SETUP_DESCRIPTION,'
 	||'   DELETED_FLAG,'
 	||'   REFRESH_ID,'
 	||'   SR_INSTANCE_ID)'
 	||'  select'
 	||'    x.RESOURCE_ID,'
 	||'    x.ORGANIZATION_ID,'
 	--||'    x.DEPARTMENT_ID,'
 	||'    x.SETUP_ID,'
 	||'    x.SETUP_CODE,'
 	||'    x.SETUP_DESCRIPTION,'
 	||'    2,'
 	||'  :v_refresh_id,'
 	||'  :v_instance_id'
 	||'  from MRP_AP_RESOURCE_SETUPS_V'||MSC_CL_PULL.v_dblink||' x'
 	||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str;

    --MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'to be removed: Ds debug: ap resource setup  = '||v_sql_stmt);
    EXECUTE IMMEDIATE v_sql_stmt
            USING  MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;
MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Number of rows for MRP_AP_RESOURCE_SETUPS_V = '|| SQL%ROWCOUNT);

    COMMIT;

   MSC_CL_PULL.v_table_name:= 'MSC_ST_SETUP_TRANSITIONS';
   MSC_CL_PULL.v_view_name := 'MRP_AP_SETUP_TRANSITIONS_V';

    v_sql_stmt:=
        ' insert into MSC_ST_SETUP_TRANSITIONS'
        ||' ( RESOURCE_ID,'
        ||'   ORGANIZATION_ID,'
        ||'   FROM_SETUP_ID,'
        ||'   TO_SETUP_ID,'
        ||'   STANDARD_OPERATION_ID,'
        ||'   TRANSITION_TIME,'
        ||'   TRANSITION_UOM,'
        ||'   TRANSITION_PENALTY,'
        ||'   DELETED_FLAG,'
        ||'   REFRESH_ID,'
        ||'   SR_INSTANCE_ID)'
        ||'  select'
        ||'    x.RESOURCE_ID,'
        ||'    x.ORGANIZATION_ID,'
        ||'    x.FROM_SETUP_ID,'
        ||'    x.TO_SETUP_ID,'
        ||'    x.STANDARD_OPERATION_ID,'
        ||'    x.TRANSITION_TIME,'
        ||'    x.TRANSITION_UOM,'
        ||'    x.TRANSITION_PENALTY,'
        ||'    2,'
        ||'  :v_refresh_id,'
        ||'  :v_instance_id'
        ||'  from MRP_AP_SETUP_TRANSITIONS_V'||MSC_CL_PULL.v_dblink||' x'
        ||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str;

    --MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'to be removed: Ds debug: ap resource setup transition = '||v_sql_stmt);
    EXECUTE IMMEDIATE v_sql_stmt
            USING  MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;
MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Number of rows for MRP_AP_SETUP_TRANSITIONS_V = '|| SQL%ROWCOUNT);

    COMMIT;

    MSC_CL_PULL.v_table_name:= 'MSC_ST_STD_OP_RESOURCES';
    MSC_CL_PULL.v_view_name := 'MRP_AP_STD_OP_RESOURCES_V';

        v_sql_stmt:=
        ' insert into MSC_ST_STD_OP_RESOURCES'
        ||' ( STANDARD_OPERATION_ID,'
        ||'   RESOURCE_ID,'
        ||'   ORGANIZATION_ID,'
        ||'   DEPARTMENT_ID,'
        ||'   OPERATION_CODE,'
        ||'   RESOURCE_SEQ_NUM,'
        ||'   RESOURCE_USAGE,'
        ||'   BASIS_TYPE,'
        ||'   RESOURCE_UNITS,'
        ||'   SUBSTITUTE_GROUP_NUM,'
        ||'   UOM_CODE,'
        ||'   SCHEDULE_FLAG,'
        ||'   DELETED_FLAG,'
        ||'   REFRESH_ID,'
        ||'   SR_INSTANCE_ID)'
        ||'  select'
        ||'    x.STANDARD_OPERATION_ID,'
        ||'    x.RESOURCE_ID,'
        ||'    x.ORGANIZATION_ID,'
        ||'    x.DEPARTMENT_ID,'
        ||'    x.OPERATION_CODE,'
        ||'    x.RESOURCE_SEQ_NUM,'
        ||'    x.RESOURCE_USAGE,'
        ||'    x.BASIS_TYPE,'
        ||'    x.RESOURCE_UNITS,'
        ||'    x.SUBSTITUTE_GROUP_NUM,'
        ||'    x.UOM_CODE,'
        ||'    x.SCHEDULE_FLAG,'
        ||'    2,'
        ||'  :v_refresh_id,'
        ||'  :v_instance_id'
        ||'  from MRP_AP_STD_OP_RESOURCES_V'||MSC_CL_PULL.v_dblink||' x'
        ||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str;

    --MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'to be removed: Ds debug: ap std op resources = '||v_sql_stmt);
    EXECUTE IMMEDIATE v_sql_stmt
            USING  MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;
MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Number of rows for MRP_AP_STD_OP_RESOURCES_V = '|| SQL%ROWCOUNT);

    COMMIT;

    END IF; /* MSC_UTIL.G_APPS115 */

  END IF; /* MSC_CL_PULL.BOM_ENABLED */
 END LOAD_RESOURCE_SETUP;


END MSC_CL_BOM_PULL;

/
