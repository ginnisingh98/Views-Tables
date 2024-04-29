--------------------------------------------------------
--  DDL for Package Body MSC_CL_ROUTING_PULL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_CL_ROUTING_PULL" AS -- body
/* $Header:*/



   v_union_sql              varchar2(32767);
   v_temp_tp_sql            VARCHAR2(100);
   v_sql_stmt                    VARCHAR2(32767);
   v_temp_sql                    VARCHAR2(15000);
   v_temp_sql1                   VARCHAR2(1000);
   v_temp_sql2                   VARCHAR2(1000);
   v_temp_sql3                   VARCHAR2(1000);
   v_temp_sql4                   VARCHAR2(1000);
   v_osfm_Sql                    varchar2(1000);

 --  NULL_DBLINK                  CONSTANT VARCHAR2(1):= ' ';
--     NULL_DBLINK      CONSTANT  VARCHAR2(1) :=MSC_UTIL.NULL_DBLINK;


  --===============================================


   PROCEDURE LOAD_ROUTING IS
    v_get_apps_ver number;
   BEGIN

IF MSC_CL_PULL.BOM_ENABLED= MSC_UTIL.SYS_YES THEN

--=================== Net Change Mode: Delete ==================
IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh

MSC_CL_PULL.v_table_name:= 'MSC_ST_ROUTINGS';
MSC_CL_PULL.v_view_name := 'MRP_AD_ROUTINGS_V';

IF MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 THEN
   v_temp_sql := ' AND x.ORGANIZATION_ID '||MSC_UTIL.v_in_org_str;
ELSE
   v_temp_sql := NULL;
END IF;

v_sql_stmt:=
' INSERT INTO MSC_ST_ROUTINGS'
||' ( ROUTING_SEQUENCE_ID,'
||'   DELETED_FLAG,'
||'   REFRESH_ID,'
||'   SR_INSTANCE_ID)'
||' SELECT '
||'   x.ROUTING_SEQUENCE_ID,'
||'   1,'
||'   :v_refresh_id,'
||'   :v_instance_id'
||'  FROM MRP_AD_ROUTINGS_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.RN>'||MSC_CL_PULL.v_lrn
|| v_temp_sql;

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

COMMIT;

END IF;

MSC_CL_PULL.v_table_name:= 'MSC_ST_ROUTINGS';
MSC_CL_PULL.v_view_name := 'MRP_AP_ROUTINGS_V';



IF MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 THEN
	v_osfm_sql:= 'x.first_op_seq_num,x.last_op_seq_num,';
ELSE
  v_osfm_sql:= 'null,null,';
END IF ;

IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh
v_union_sql :=
'   AND (x.RN1>'||MSC_CL_PULL.v_lrn||')'
||' UNION '
||' SELECT '
||'   x.ROUTING_SEQUENCE_ID,'
||'   x.ASSEMBLY_ITEM_ID,'
||'   x.ROUTING_TYPE,'
||    v_osfm_sql
||'   x.ROUTING_COMMENT,'
||'   x.PRIORITY,'
||'   x.ALTERNATE_ROUTING_DESIGNATOR,'
||'   x.PROJECT_ID,'
||'   x.TASK_ID, '
||'   x.LINE_ID,'
||'   x.COMPLETION_SUBINVENTORY,'
||'   x.COMPLETION_LOCATOR_ID,'
||'   x.COMMON_ROUTING_SEQUENCE_ID,'
||'   nvl(x.CFM_ROUTING_FLAG,2), '
||'   x.MIXED_MODEL_MAP_FLAG, '
||'   x.TOTAL_PRODUCT_CYCLE_TIME,'
||'   x.CTP_FLAG,'
||'   x.ORGANIZATION_ID,'
||'   2,'
||'  :v_refresh_id,'
||'   :v_instance_id'
||'  FROM MRP_AP_ROUTINGS_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'   AND (x.RN2>'||MSC_CL_PULL.v_lrn||')';
/* NCP
||' UNION '
||' SELECT '
||'   x.ROUTING_SEQUENCE_ID,'
||'   x.ASSEMBLY_ITEM_ID,'
||'   x.ROUTING_TYPE,'
||    v_osfm_sql
||'   x.ROUTING_COMMENT, '
||'   x.PRIORITY,'
||'   x.ALTERNATE_ROUTING_DESIGNATOR,'
||'   x.PROJECT_ID,'
||'   x.TASK_ID, '
||'   x.LINE_ID,'
||'   x.COMPLETION_SUBINVENTORY,'
||'   x.COMPLETION_LOCATOR_ID,'
||'   x.COMMON_ROUTING_SEQUENCE_ID,'
||'   nvl(x.CFM_ROUTING_FLAG,2), '
||'   x.MIXED_MODEL_MAP_FLAG, '
||'   x.TOTAL_PRODUCT_CYCLE_TIME,'
||'   x.CTP_FLAG,'
||'   x.ORGANIZATION_ID,'
||'   2,'
||'  :v_refresh_id,'
||'   :v_instance_id'
||'  FROM MRP_AP_ROUTINGS_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'   AND (x.RN3>'||MSC_CL_PULL.v_lrn||')' ;
*/
ELSE
v_union_sql :=
'   AND (x.RN1>'||MSC_CL_PULL.v_lrn
||'    OR x.RN2>'||MSC_CL_PULL.v_lrn
||'    OR x.RN3>'||MSC_CL_PULL.v_lrn||')';
END IF;

v_sql_stmt:=
' INSERT INTO MSC_ST_ROUTINGS'
||' ( ROUTING_SEQUENCE_ID,'
||'   ASSEMBLY_ITEM_ID,'
||'   ROUTING_TYPE,'
||'   FIRST_OP_SEQ_NUM,'
||'   LAST_OP_SEQ_NUM,'
||'   ROUTING_COMMENT,'
||'   PRIORITY,'
||'   ALTERNATE_ROUTING_DESIGNATOR,'
||'   PROJECT_ID,'
||'   TASK_ID, '
||'   LINE_ID,'
||'   COMPLETION_SUBINVENTORY,'
||'   COMPLETION_LOCATOR_ID,'
||'   COMMON_ROUTING_SEQUENCE_ID,'
||'   CFM_ROUTING_FLAG, '
||'   MIXED_MODEL_MAP_FLAG, '
||'   TOTAL_PRODUCT_CYCLE_TIME,'
||'   CTP_FLAG,'
||'   ORGANIZATION_ID,'
||'   DELETED_FLAG,'
||'   REFRESH_ID,'
||'   SR_INSTANCE_ID)'
||' SELECT '
||'   x.ROUTING_SEQUENCE_ID,'
||'   x.ASSEMBLY_ITEM_ID,'
||'   x.ROUTING_TYPE,'
||    v_osfm_sql
||'   x.ROUTING_COMMENT,'
||'   x.PRIORITY,'
||'   x.ALTERNATE_ROUTING_DESIGNATOR,'
||'   x.PROJECT_ID,'
||'   x.TASK_ID, '
||'   x.LINE_ID,'
||'   x.COMPLETION_SUBINVENTORY,'
||'   x.COMPLETION_LOCATOR_ID,'
||'   x.COMMON_ROUTING_SEQUENCE_ID,'
||'   nvl(x.CFM_ROUTING_FLAG,2), '
||'   x.MIXED_MODEL_MAP_FLAG, '
||'   x.TOTAL_PRODUCT_CYCLE_TIME,'
||'   x.CTP_FLAG,'
||'   x.ORGANIZATION_ID,'
||'   2,'
||'  :v_refresh_id,'
||'   :v_instance_id'
||'  FROM MRP_AP_ROUTINGS_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
|| v_union_sql ;

IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id,
                                   MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

/*                                   MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;
*/

ELSE


EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;


END IF;

COMMIT;


END IF;  -- MSC_CL_PULL.BOM_ENABLED

END LOAD_ROUTING;


   PROCEDURE LOAD_ROUTING_OPERATIONS IS
    v_get_apps_ver number;
   BEGIN

IF MSC_CL_PULL.BOM_ENABLED= MSC_UTIL.SYS_YES THEN
--=================== Net Change Mode: Delete ==================
IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh

MSC_CL_PULL.v_table_name:= 'MSC_ST_ROUTING_OPERATIONS';
MSC_CL_PULL.v_view_name := 'MRP_AD_ROUTING_OPERATIONS_V';

IF MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 THEN
   v_temp_sql := ' AND x.ORGANIZATION_ID '||MSC_UTIL.v_in_org_str;
ELSE
   v_temp_sql := NULL;
END IF;

v_sql_stmt:=
' INSERT INTO MSC_ST_ROUTING_OPERATIONS'
||' ( OPERATION_SEQUENCE_ID, '
||'   ROUTING_SEQUENCE_ID,  '
||'   DELETED_FLAG,'
||'   REFRESH_ID,'
||'   SR_INSTANCE_ID)'
||' SELECT '
||'   x.OPERATION_SEQUENCE_ID, '
||'   x.ROUTING_SEQUENCE_ID,  '
||'   1,'
||'   :v_refresh_id,'
||'   :v_instance_id'
||'  FROM MRP_AD_ROUTING_OPERATIONS_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.RN>'||MSC_CL_PULL.v_lrn
|| v_temp_sql;

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

COMMIT;

END IF;

MSC_CL_PULL.v_table_name:= 'MSC_ST_ROUTING_OPERATIONS';
MSC_CL_PULL.v_view_name := 'MRP_AP_ROUTING_OPERATIONS_V';
IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh
v_union_sql :=
'   AND ( x.RN1>'||MSC_CL_PULL.v_lrn||')'
||' UNION '
||' SELECT '
||'   x.OPERATION_SEQUENCE_ID, '
||'   x.ROUTING_SEQUENCE_ID,  '
||'   x.OPERATION_SEQ_NUM, '
||'   x.OPERATION_DESCRIPTION, '
||'   x.EFFECTIVITY_DATE- :v_dgmt,  '
||'   x.DISABLE_DATE- :v_dgmt,   '
||'   x.OPTION_DEPENDENT_FLAG, '
||'   x.OPERATION_TYPE, '
||'   x.MINIMUM_TRANSFER_QUANTITY, '
||'   x.YIELD, '
||'   x.DEPARTMENT_ID,    '
||'   x.OPERATION_LEAD_TIME_PERCENT, '
||'   x.CUMULATIVE_YIELD, '
||'   x.REVERSE_CUMULATIVE_YIELD,'
||'   x.NET_PLANNING_PERCENT,'
||'   x.ORGANIZATION_ID, '
||'   x.DEPARTMENT_CODE,'
||'   x.STANDARD_OPERATION_CODE,'
||'   2,'
||'  :v_refresh_id,'
||'   :v_instance_id'
||'  FROM MRP_AP_ROUTING_OPERATIONS_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'   AND ( x.RN2>'||MSC_CL_PULL.v_lrn||')'
||' UNION '
||' SELECT '
||'   x.OPERATION_SEQUENCE_ID, '
||'   x.ROUTING_SEQUENCE_ID,  '
||'   x.OPERATION_SEQ_NUM, '
||'   x.OPERATION_DESCRIPTION, '
||'   x.EFFECTIVITY_DATE- :v_dgmt,  '
||'   x.DISABLE_DATE- :v_dgmt,   '
||'   x.OPTION_DEPENDENT_FLAG, '
||'   x.OPERATION_TYPE, '
||'   x.MINIMUM_TRANSFER_QUANTITY, '
||'   x.YIELD, '
||'   x.DEPARTMENT_ID,    '
||'   x.OPERATION_LEAD_TIME_PERCENT, '
||'   x.CUMULATIVE_YIELD, '
||'   x.REVERSE_CUMULATIVE_YIELD,'
||'   x.NET_PLANNING_PERCENT,'
||'   x.ORGANIZATION_ID, '
||'   x.DEPARTMENT_CODE,'
||'   x.STANDARD_OPERATION_CODE,'
||'   2,'
||'  :v_refresh_id,'
||'   :v_instance_id'
||'  FROM MRP_AP_ROUTING_OPERATIONS_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ITEM_ORG'||MSC_UTIL.v_in_org_str
||'   AND ( x.RN3>'||MSC_CL_PULL.v_lrn||')';
/*
||' UNION '
||' SELECT '
||'   x.OPERATION_SEQUENCE_ID, '
||'   x.ROUTING_SEQUENCE_ID,  '
||'   x.OPERATION_SEQ_NUM, '
||'   x.OPERATION_DESCRIPTION, '
||'   x.EFFECTIVITY_DATE- :v_dgmt,  '
||'   x.DISABLE_DATE- :v_dgmt,   '
||'   x.OPTION_DEPENDENT_FLAG, '
||'   x.OPERATION_TYPE, '
||'   x.MINIMUM_TRANSFER_QUANTITY, '
||'   x.YIELD, '
||'   x.DEPARTMENT_ID,    '
||'   x.OPERATION_LEAD_TIME_PERCENT, '
||'   x.CUMULATIVE_YIELD, '
||'   x.REVERSE_CUMULATIVE_YIELD,'
||'   x.NET_PLANNING_PERCENT,'
||'   x.ORGANIZATION_ID, '
||'   x.DEPARTMENT_CODE,'
||'   x.STANDARD_OPERATION_CODE,'
||'   2,'
||'  :v_refresh_id,'
||'   :v_instance_id'
||'  FROM MRP_AP_ROUTING_OPERATIONS_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'   AND ( x.RN4>'||MSC_CL_PULL.v_lrn||')' ; */
ELSE
v_union_sql :=
'   AND (x.RN1>'||MSC_CL_PULL.v_lrn
||'    OR x.RN2>'||MSC_CL_PULL.v_lrn
||'    OR x.RN3>'||MSC_CL_PULL.v_lrn
||'    OR x.RN4>'||MSC_CL_PULL.v_lrn||')';
END IF;

v_sql_stmt:=
' INSERT INTO MSC_ST_ROUTING_OPERATIONS'
||' ( OPERATION_SEQUENCE_ID, '
||'   ROUTING_SEQUENCE_ID,  '
||'   OPERATION_SEQ_NUM, '
||'   OPERATION_DESCRIPTION,   '
||'   EFFECTIVITY_DATE,  '
||'   DISABLE_DATE,   '
||'   OPTION_DEPENDENT_FLAG, '
||'   OPERATION_TYPE, '
||'   MINIMUM_TRANSFER_QUANTITY, '
||'   YIELD, '
||'   DEPARTMENT_ID,    '
||'   OPERATION_LEAD_TIME_PERCENT, '
||'   CUMULATIVE_YIELD, '
||'   REVERSE_CUMULATIVE_YIELD,'
||'   NET_PLANNING_PERCENT,'
||'   ORGANIZATION_ID, '
||'   DEPARTMENT_CODE,'
||'   STANDARD_OPERATION_CODE,'
||'   DELETED_FLAG,'
||'   REFRESH_ID,'
||'   SR_INSTANCE_ID)'
||' SELECT '
||'   x.OPERATION_SEQUENCE_ID, '
||'   x.ROUTING_SEQUENCE_ID,  '
||'   x.OPERATION_SEQ_NUM, '
||'   x.OPERATION_DESCRIPTION, '
||'   x.EFFECTIVITY_DATE- :v_dgmt,  '
||'   x.DISABLE_DATE- :v_dgmt,   '
||'   x.OPTION_DEPENDENT_FLAG, '
||'   x.OPERATION_TYPE, '
||'   x.MINIMUM_TRANSFER_QUANTITY, '
||'   x.YIELD, '
||'   x.DEPARTMENT_ID,    '
||'   x.OPERATION_LEAD_TIME_PERCENT, '
||'   x.CUMULATIVE_YIELD, '
||'   x.REVERSE_CUMULATIVE_YIELD,'
||'   x.NET_PLANNING_PERCENT,'
||'   x.ORGANIZATION_ID, '
||'   x.DEPARTMENT_CODE,'
||'   x.STANDARD_OPERATION_CODE,'
||'   2,'
||'  :v_refresh_id,'
||'   :v_instance_id'
||'  FROM MRP_AP_ROUTING_OPERATIONS_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||  v_union_sql ;

IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id,
                                   MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id,
                                   MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;
/*
                                   MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;
*/

ELSE


EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;


END IF;

COMMIT;

END IF;  -- MSC_CL_PULL.BOM_ENABLED

   END LOAD_ROUTING_OPERATIONS;
   PROCEDURE LOAD_OPERATION_RES_SEQS IS
    v_get_apps_ver number;
   BEGIN

IF MSC_CL_PULL.BOM_ENABLED= MSC_UTIL.SYS_YES THEN
  BEGIN
      SELECT APPS_VER
      INTO v_get_apps_ver
      FROM MSC_APPS_INSTANCES
      WHERE INSTANCE_ID = MSC_CL_PULL.v_instance_id;
  END;
--=================== Net Change Mode: Delete ==================
IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh

MSC_CL_PULL.v_table_name:= 'MSC_ST_OPERATION_RESOURCE_SEQS';
MSC_CL_PULL.v_view_name := 'MRP_AD_OP_RESOURCE_SEQS_V';

IF MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 THEN
   v_temp_sql := ' AND x.ORGANIZATION_ID '||MSC_UTIL.v_in_org_str;
ELSE
   v_temp_sql := NULL;
END IF;

v_sql_stmt:=
' INSERT INTO MSC_ST_OPERATION_RESOURCE_SEQS'
||'  ( ROUTING_SEQUENCE_ID,'
||'    OPERATION_SEQUENCE_ID,'
||'    RESOURCE_SEQ_NUM,'
||'    DELETED_FLAG,'
||'    REFRESH_ID,'
||'    SR_INSTANCE_ID)'
||'  SELECT'
||'    x.ROUTING_SEQUENCE_ID,'
||'    x.OPERATION_SEQUENCE_ID,'
||'    x.RESOURCE_SEQ_NUM,'
||'    1,'
||'    :v_refresh_id,'
||'    :v_instance_id'
||'   FROM MRP_AD_OP_RESOURCE_SEQS_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.RN>'||MSC_CL_PULL.v_lrn
|| v_temp_sql;

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

COMMIT;

END IF;

MSC_CL_PULL.v_table_name:= 'MSC_ST_OPERATION_RESOURCE_SEQS';
MSC_CL_PULL.v_view_name := 'MRP_AP_OP_RESOURCE_SEQS_V';

Begin

IF MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 THEN
	v_temp_sql:= ' x.net_planning_percent,';
ELSE
  v_temp_sql:='NULL,' ;
END IF ;

End;

Begin


IF MSC_CL_PULL.v_apps_ver=MSC_UTIL.G_APPS107 THEN
	v_temp_sql1:= 'NULL , ' ;
ELSE
  v_temp_sql1:= ' x.activity_group_id, ';
END IF ;

End;

IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh
v_union_sql :=
'   AND (x.RN2>'||MSC_CL_PULL.v_lrn
||'    OR x.RN3>'||MSC_CL_PULL.v_lrn
||'    OR x.RN4>'||MSC_CL_PULL.v_lrn
||'    OR x.RN5>'||MSC_CL_PULL.v_lrn||')';
ELSE
v_union_sql :=
'   AND (x.RN1>'||MSC_CL_PULL.v_lrn
||'    OR x.RN2>'||MSC_CL_PULL.v_lrn
||'    OR x.RN3>'||MSC_CL_PULL.v_lrn
||'    OR x.RN4>'||MSC_CL_PULL.v_lrn
||'    OR x.RN5>'||MSC_CL_PULL.v_lrn||')';
END IF;

v_sql_stmt:=
' INSERT INTO MSC_ST_OPERATION_RESOURCE_SEQS'
||'  ( ROUTING_SEQUENCE_ID,'
||'    OPERATION_SEQUENCE_ID,'
||'    RESOURCE_SEQ_NUM,'
||'    CUMMULATIVE_PCT,'
||'    SCHEDULE_FLAG,'
||'    RESOURCE_OFFSET_PERCENT,'
||'    DEPARTMENT_ID,'
||'    ACTIVITY_GROUP_ID,'
||'    DELETED_FLAG,'
||'   REFRESH_ID,'
||'    SR_INSTANCE_ID,'
||'    ORGANIZATION_ID)'
||'  SELECT '         -- due to alternate resource...
||'    x.ROUTING_SEQUENCE_ID,'
||'    x.OPERATION_SEQUENCE_ID,'
||'    decode(:v_get_apps_ver,3,x.resource_seq_num,4,x.resource_seq_num, '
||'    NVL(TO_NUMBER(DECODE( :v_msc_simul_res_seq,'
||'            1, x.Attribute1,'
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
     ||'       15, x.Attribute15)),x.RESOURCE_SEQ_NUM)),'
||     v_temp_sql
||'    x.SCHEDULE_FLAG,'
||'    x.RESOURCE_OFFSET_PERCENT,'
||'    x.DEPARTMENT_ID,'
||     v_temp_sql1
||'    2,'
||'    :v_refresh_id,'
||'    :v_instance_id,'
||'    x.ORGANIZATION_ID'
||'   FROM MRP_AP_OP_RESOURCE_SEQS_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
|| v_union_sql ;

--IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh

EXECUTE IMMEDIATE v_sql_stmt
            USING v_get_apps_ver,
                  MSC_CL_PULL.v_msc_simul_res_seq,
                  MSC_CL_PULL.v_refresh_id,
                  MSC_CL_PULL.v_instance_id;


--ELSE



--END IF;

COMMIT;

END IF;  -- MSC_CL_PULL.BOM_ENABLED

   END LOAD_OPERATION_RES_SEQS;
PROCEDURE LOAD_OPERATION_RESOURCES IS
    v_get_apps_ver number;
BEGIN

  IF MSC_CL_PULL.BOM_ENABLED= MSC_UTIL.SYS_YES THEN
     BEGIN
         SELECT APPS_VER
         INTO V_GET_APPS_VER
         FROM MSC_APPS_INSTANCES
         WHERE INSTANCE_ID = MSC_CL_PULL.v_instance_id;
      END;
--=================== Net Change Mode: Delete ==================
    IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh

        MSC_CL_PULL.v_table_name:= 'MSC_ST_OPERATION_RESOURCES';
        MSC_CL_PULL.v_view_name := 'MRP_AD_OPERATION_RESOURCES_V';
        BEGIN
            SELECT APPS_VER
            INTO V_GET_APPS_VER
            FROM MSC_APPS_INSTANCES
            WHERE INSTANCE_ID = MSC_CL_PULL.v_instance_id;
        END;

         if v_get_apps_ver >= 3
          then
          v_sql_stmt:=
          ' INSERT INTO MSC_ST_OPERATION_RESOURCES'
          ||' ( ROUTING_SEQUENCE_ID,'
          ||'   OPERATION_SEQUENCE_ID,'
          ||'   RESOURCE_SEQ_NUM,'
          ||'   RESOURCE_ID,'
          ||'   ALTERNATE_NUMBER,'
          ||'   DELETED_FLAG,'
          ||'   REFRESH_ID,'
          ||'   SR_INSTANCE_ID)'
          ||' SELECT'
          ||'   x.ROUTING_SEQUENCE_ID,'
          ||'   x.OPERATION_SEQUENCE_ID,'
          ||'   x.RESOURCE_SEQ_NUM,'
          ||'   x.RESOURCE_ID,'
          ||'   x.ALTERNATE_NUMBER,'     -- **
          ||'   1,'
          ||'   :v_refresh_id,'
          ||'   :v_instance_id'
          ||'  FROM MRP_AD_OPERATION_RESOURCES_V'||MSC_CL_PULL.v_dblink||' x'
          ||' WHERE x.RN > '||MSC_CL_PULL.v_lrn
          ||' AND x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str;

          else


          v_sql_stmt:=
          ' INSERT INTO MSC_ST_OPERATION_RESOURCES'
          ||' ( ROUTING_SEQUENCE_ID,'
          ||'   OPERATION_SEQUENCE_ID,'
          ||'   RESOURCE_SEQ_NUM,'
          ||'   RESOURCE_ID,'
          ||'   ALTERNATE_NUMBER,'
          ||'   DELETED_FLAG,'
          ||'   REFRESH_ID,'
          ||'   SR_INSTANCE_ID)'
          ||' SELECT'
          ||'   x.ROUTING_SEQUENCE_ID,'
          ||'   x.OPERATION_SEQUENCE_ID,'
          ||'   x.RESOURCE_SEQ_NUM,'
          ||'   x.RESOURCE_ID,'
          ||'   x.ALTERNATE_NUMBER,'     -- **
          ||'   1,'
          ||'   :v_refresh_id,'
          ||'   :v_instance_id'
          ||'  FROM MRP_AD_OPERATION_RESOURCES_V'||MSC_CL_PULL.v_dblink||' x'
          ||' WHERE x.RN > '||MSC_CL_PULL.v_lrn;

          end if;

          EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

          COMMIT;


         BEGIN
            SELECT APPS_VER
            INTO V_GET_APPS_VER
            FROM MSC_APPS_INSTANCES
            WHERE INSTANCE_ID = MSC_CL_PULL.v_instance_id;
         END;

         if V_GET_APPS_VER >= 3
            then
            MSC_CL_PULL.v_table_name:= 'MSC_ST_OPERATION_RESOURCES';
            MSC_CL_PULL.v_view_name := 'MRP_AD_SUB_OPER_RESS_V';

            IF MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 THEN
               v_temp_sql := ' AND x.ORGANIZATION_ID '||MSC_UTIL.v_in_org_str;
            ELSE
               v_temp_sql := NULL;
            END IF;

            v_sql_stmt:=
            ' INSERT INTO MSC_ST_OPERATION_RESOURCES'
            ||' ( ROUTING_SEQUENCE_ID,'
            ||'   OPERATION_SEQUENCE_ID,'
            ||'   RESOURCE_SEQ_NUM,'
            ||'   RESOURCE_ID,'
            ||'   ALTERNATE_NUMBER,'
            ||'   DELETED_FLAG,'
            ||'   REFRESH_ID,'
            ||'   SR_INSTANCE_ID)'
            ||' SELECT'
            ||'   x.ROUTING_SEQUENCE_ID,'
            ||'   x.OPERATION_SEQUENCE_ID,'
            ||'   x.RESOURCE_SEQ_NUM,'
            ||'   x.RESOURCE_ID,'
            ||'   x.ALTERNATE_NUMBER,'     -- **
            ||'   1,'
            ||'   :v_refresh_id,'
            ||'   :v_instance_id'
            ||'  FROM MRP_AD_SUB_OPER_RESS_V'||MSC_CL_PULL.v_dblink||' x'
            ||' WHERE x.RN>'||MSC_CL_PULL.v_lrn
            || v_temp_sql;

            EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

            COMMIT;

         END IF;

      END IF;

      MSC_CL_PULL.v_table_name:= 'MSC_ST_OPERATION_RESOURCES';
      MSC_CL_PULL.v_view_name := 'MRP_AP_OPERATION_RESOURCES_V';

       BEGIN
          SELECT APPS_VER
          INTO V_GET_APPS_VER
          FROM MSC_APPS_INSTANCES
          WHERE INSTANCE_ID = MSC_CL_PULL.v_instance_id;
       END;

      if v_get_apps_ver >= 3
      then

          v_sql_stmt:=
          ' INSERT INTO MSC_ST_OPERATION_RESOURCES'
          ||' ( ROUTING_SEQUENCE_ID,'
          ||'   OPERATION_SEQUENCE_ID,'
          ||'   RESOURCE_SEQ_NUM,'
          ||'   RESOURCE_ID,'
          ||'   RESOURCE_USAGE,'
          ||'   BASIS_TYPE,'
          ||'   MAX_RESOURCE_UNITS,'
          ||'   RESOURCE_UNITS,'
          ||'   UOM_CODE,'
          ||'   RESOURCE_TYPE,'
          ||'   ALTERNATE_NUMBER,'
          ||'   PRINCIPAL_FLAG,'
          ||'   DELETED_FLAG,'
          ||'   REFRESH_ID,'
          ||'   SR_INSTANCE_ID,'
          ||'   ORGANIZATION_ID ,'
          ||'   SETUP_ID ,'
          ||'   orig_resource_seq_num )'
          ||' SELECT'
          ||'   x.ROUTING_SEQUENCE_ID,'
          ||'   x.OPERATION_SEQUENCE_ID,'
          ||'   decode(:v_get_apps_ver,3,x.schedule_seq_num,4,x.schedule_seq_num,5,x.schedule_seq_num,NVL(TO_NUMBER(DECODE( :v_msc_simul_res_seq,'
          ||'            1, x.Attribute1,'
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
               ||'       15, x.Attribute15)),x.RESOURCE_SEQ_NUM)),'
          ||'   x.RESOURCE_ID,'
          ||'   x.RESOURCE_USAGE,'
          ||'   x.BASIS_TYPE,'
          ||'   x.MAX_RESOURCE_UNITS,'
          ||'   x.RESOURCE_UNITS,'
          ||'   x.UOM_CODE,'
          ||'   x.RESOURCE_TYPE,'
          /* obsolete
          ||'   DECODE(DECODE( :v_msc_alt_op_res,'
          ||'            1, x.Attribute1,'
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
               ||'      ''alternate'',1,'
               ||'      ''aux1'',2,'
               ||'      ''aux2'',3,'
               ||'      ''machine'',4,'
               ||'      ''operators'',5 ),'  obsolete*/
          ||'   decode(:v_get_apps_ver,3,nvl(x.alternate_number,0),4,nvl(x.alternate_number,0),
                5,nvl(x.alternate_number,0),NVL(TO_NUMBER(DECODE( :v_msc_alt_res_priority,'
          ||'            1, x.Attribute1,'
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
               ||'       15, x.Attribute15)),0)),'
          ||'   x.PRINCIPAL_FLAG,'  -- **
          ||'   2,'
          ||'  :v_refresh_id,'
          ||'   :v_instance_id,'
          ||'   x.ORGANIZATION_ID,'
          ||'   x.SETUP_ID,'
          ||'   x.resource_seq_num'
          ||'  FROM MRP_AP_OPERATION_RESOURCES_V'||MSC_CL_PULL.v_dblink||' x'
          ||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
          ||'   AND (x.RN1>'||MSC_CL_PULL.v_lrn
          ||'    OR x.RN2>'||MSC_CL_PULL.v_lrn
          ||'    OR x.RN3>'||MSC_CL_PULL.v_lrn
          ||'    OR x.RN4>'||MSC_CL_PULL.v_lrn
          ||'    OR x.RN5>'||MSC_CL_PULL.v_lrn||')';


        else

            IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh
                v_union_sql :=
                '   AND ( x.RN2>'||MSC_CL_PULL.v_lrn||')'
                /*
                ||' UNION '
                ||' SELECT'
                ||'   x.ROUTING_SEQUENCE_ID,'
                ||'   x.OPERATION_SEQUENCE_ID,'
                ||'    NVL(TO_NUMBER(DECODE( :v_msc_simul_res_seq,'
                ||'            1, x.Attribute1,'
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
                     ||'       15, x.Attribute15)),x.RESOURCE_SEQ_NUM),'
                ||'   x.RESOURCE_ID,'
                ||'   x.RESOURCE_USAGE,'
                ||'   x.BASIS_TYPE,'
                ||'   x.MAX_RESOURCE_UNITS,'
                ||'   x.RESOURCE_UNITS,'
                ||'   x.UOM_CODE,'
                ||'   x.RESOURCE_TYPE,'
                ||'   NVL(TO_NUMBER(DECODE( :v_msc_alt_res_priority,'
                ||'            1, x.Attribute1,'
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
                ||'   x.PRINCIPAL_FLAG,'  -- **
                ||'   2,'
                ||'  :v_refresh_id,'
                ||'   :v_instance_id'
                ||'  FROM MRP_AP_OPERATION_RESOURCES_V'||MSC_CL_PULL.v_dblink||' x'
                ||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
                ||'   AND ( x.RN2>'||MSC_CL_PULL.v_lrn||')'
                */
                ||' UNION '
                ||' SELECT'
                ||'   x.ROUTING_SEQUENCE_ID,'
                ||'   x.OPERATION_SEQUENCE_ID,'
                ||'    NVL(TO_NUMBER(DECODE( :v_msc_simul_res_seq,'
                ||'            1, x.Attribute1,'
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
                     ||'       15, x.Attribute15)),x.RESOURCE_SEQ_NUM),'
                ||'   x.RESOURCE_ID,'
                ||'   x.RESOURCE_USAGE,'
                ||'   x.BASIS_TYPE,'
                ||'   x.MAX_RESOURCE_UNITS,'
                ||'   x.RESOURCE_UNITS,'
                ||'   x.UOM_CODE,'
                ||'   x.RESOURCE_TYPE,'
                ||'   NVL(TO_NUMBER(DECODE( :v_msc_alt_res_priority,'
                ||'            1, x.Attribute1,'
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
                ||'   x.PRINCIPAL_FLAG,'  -- **
                ||'   2,'
                ||'  :v_refresh_id,'
                ||'   :v_instance_id,'
                ||'   x.ORGANIZATION_ID,'
                ||'   x.SETUP_ID,'
                ||'   x.resource_seq_num'
                ||'  FROM MRP_AP_OPERATION_RESOURCES_V'||MSC_CL_PULL.v_dblink||' x'
                ||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
                ||'   AND ( x.RN3>'||MSC_CL_PULL.v_lrn||')'
                ||' UNION '
                ||' SELECT'
                ||'   x.ROUTING_SEQUENCE_ID,'
                ||'   x.OPERATION_SEQUENCE_ID,'
                ||'    NVL(TO_NUMBER(DECODE( :v_msc_simul_res_seq,'
                ||'            1, x.Attribute1,'
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
                     ||'       15, x.Attribute15)),x.RESOURCE_SEQ_NUM),'
                ||'   x.RESOURCE_ID,'
                ||'   x.RESOURCE_USAGE,'
                ||'   x.BASIS_TYPE,'
                ||'   x.MAX_RESOURCE_UNITS,'
                ||'   x.RESOURCE_UNITS,'
                ||'   x.UOM_CODE,'
                ||'   x.RESOURCE_TYPE,'
                ||'   NVL(TO_NUMBER(DECODE( :v_msc_alt_res_priority,'
                ||'            1, x.Attribute1,'
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
                ||'   x.PRINCIPAL_FLAG,'  -- **
                ||'   2,'
                ||'  :v_refresh_id,'
                ||'   :v_instance_id,'
                ||'   x.ORGANIZATION_ID,'
                ||'   x.SETUP_ID,'
                ||'   x.resource_seq_num'
                ||'  FROM MRP_AP_OPERATION_RESOURCES_V'||MSC_CL_PULL.v_dblink||' x'
                ||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
                ||'   AND ( x.RN4>'||MSC_CL_PULL.v_lrn||')';
                /*
                ||' UNION '
                ||' SELECT'
                ||'   x.ROUTING_SEQUENCE_ID,'
                ||'   x.OPERATION_SEQUENCE_ID,'
                ||'    NVL(TO_NUMBER(DECODE( :v_msc_simul_res_seq,'
                ||'            1, x.Attribute1,'
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
                     ||'       15, x.Attribute15)),x.RESOURCE_SEQ_NUM),'
                ||'   x.RESOURCE_ID,'
                ||'   x.RESOURCE_USAGE,'
                ||'   x.BASIS_TYPE,'
                ||'   x.MAX_RESOURCE_UNITS,'
                ||'   x.RESOURCE_UNITS,'
                ||'   x.UOM_CODE,'
                ||'   x.RESOURCE_TYPE,'
                ||'   NVL(TO_NUMBER(DECODE( :v_msc_alt_res_priority,'
                ||'            1, x.Attribute1,'
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
                ||'   x.PRINCIPAL_FLAG,'  -- **
                ||'   2,'
                ||'  :v_refresh_id,'
                ||'   :v_instance_id'
                ||'  FROM MRP_AP_OPERATION_RESOURCES_V'||MSC_CL_PULL.v_dblink||' x'
                ||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
                ||'   AND ( x.RN5>'||MSC_CL_PULL.v_lrn||')' ;
                */
              ELSE
                  v_union_sql :=
                  '   AND (x.RN1>'||MSC_CL_PULL.v_lrn
                  ||'    OR x.RN2>'||MSC_CL_PULL.v_lrn
                  ||'    OR x.RN3>'||MSC_CL_PULL.v_lrn
                  ||'    OR x.RN4>'||MSC_CL_PULL.v_lrn
                  ||'    OR x.RN5>'||MSC_CL_PULL.v_lrn||')';
               END IF;
              v_sql_stmt:=
              ' INSERT INTO MSC_ST_OPERATION_RESOURCES'
              ||' ( ROUTING_SEQUENCE_ID,'
              ||'   OPERATION_SEQUENCE_ID,'
              ||'   RESOURCE_SEQ_NUM,'
              ||'   RESOURCE_ID,'
              ||'   RESOURCE_USAGE,'
              ||'   BASIS_TYPE,'
              ||'   MAX_RESOURCE_UNITS,'
              ||'   RESOURCE_UNITS,'
              ||'   UOM_CODE,'
              ||'   RESOURCE_TYPE,'
              ||'   ALTERNATE_NUMBER,'
              ||'   PRINCIPAL_FLAG,'
              ||'   DELETED_FLAG,'
              ||'   REFRESH_ID,'
              ||'   SR_INSTANCE_ID,'
              ||'   ORGANIZATION_ID,'
              ||'   SETUP_ID,'
              ||'   orig_resource_seq_num)'
              ||' SELECT'
              ||'   x.ROUTING_SEQUENCE_ID,'
              ||'   x.OPERATION_SEQUENCE_ID,'
              ||'    NVL(TO_NUMBER(DECODE( :v_msc_simul_res_seq,'
              ||'            1, x.Attribute1,'
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
                   ||'       15, x.Attribute15)),x.RESOURCE_SEQ_NUM),'
              ||'   x.RESOURCE_ID,'
              ||'   x.RESOURCE_USAGE,'
              ||'   x.BASIS_TYPE,'
              ||'   x.MAX_RESOURCE_UNITS,'
              ||'   x.RESOURCE_UNITS,'
              ||'   x.UOM_CODE,'
              ||'   x.RESOURCE_TYPE,'
              ||'   NVL(TO_NUMBER(DECODE( :v_msc_alt_res_priority,'
              ||'            1, x.Attribute1,'
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
              ||'   x.PRINCIPAL_FLAG,'  -- **
              ||'   2,'
              ||'  :v_refresh_id,'
              ||'   :v_instance_id,'
              ||'  x.ORGANIZATION_ID,'
              ||'  x.SETUP_ID,'
              ||'  x.resource_seq_num'
              ||'  FROM MRP_AP_OPERATION_RESOURCES_V'||MSC_CL_PULL.v_dblink||' x'
              ||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
              || v_union_sql ;

            end if;

        if v_get_apps_ver >= 3
        then
               EXECUTE IMMEDIATE v_sql_stmt USING v_get_apps_ver,MSC_CL_PULL.v_msc_simul_res_seq,
                                           v_get_apps_ver,
                                           MSC_CL_PULL.v_msc_alt_res_priority,
                                           MSC_CL_PULL.v_refresh_id,
                                           MSC_CL_PULL.v_instance_id;

        else
        IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh

            EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_msc_simul_res_seq,
                                           MSC_CL_PULL.v_msc_alt_res_priority,
                                           MSC_CL_PULL.v_refresh_id,
                                           MSC_CL_PULL.v_instance_id,
                                           MSC_CL_PULL.v_msc_simul_res_seq,
                                           MSC_CL_PULL.v_msc_alt_res_priority,
                                           MSC_CL_PULL.v_refresh_id,
                                           MSC_CL_PULL.v_instance_id,
                                           MSC_CL_PULL.v_msc_simul_res_seq,
                                           MSC_CL_PULL.v_msc_alt_res_priority,
                                           MSC_CL_PULL.v_refresh_id,
                                           MSC_CL_PULL.v_instance_id;
        /*
                                           MSC_CL_PULL.v_msc_simul_res_seq,
                                           MSC_CL_PULL.v_msc_alt_res_priority,
                                           MSC_CL_PULL.v_refresh_id,
                                           MSC_CL_PULL.v_instance_id,
                                           MSC_CL_PULL.v_msc_simul_res_seq,
                                           MSC_CL_PULL.v_msc_alt_res_priority,
                                           MSC_CL_PULL.v_refresh_id,
                                           MSC_CL_PULL.v_instance_id;
        */

        ELSE


              EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_msc_simul_res_seq,
                                           MSC_CL_PULL.v_msc_alt_res_priority,
                                           MSC_CL_PULL.v_refresh_id,
                                           MSC_CL_PULL.v_instance_id;

        END IF;
    end if;
    COMMIT;

  END IF;  -- MSC_CL_PULL.BOM_ENABLED

END LOAD_OPERATION_RESOURCES;
   PROCEDURE LOAD_OPERATION_COMPONENTS IS
    v_get_apps_ver number;
   BEGIN

IF MSC_CL_PULL.BOM_ENABLED= MSC_UTIL.SYS_YES THEN
--=================== Net Change Mode: Delete ==================
IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh

MSC_CL_PULL.v_table_name:= 'MSC_ST_OPERATION_COMPONENTS';
MSC_CL_PULL.v_view_name := 'MRP_AD_OPERATION_COMPONENTS_V';

IF MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 THEN
   v_temp_sql := ' AND x.ORGANIZATION_ID '||MSC_UTIL.v_in_org_str;
ELSE
   v_temp_sql := NULL;
END IF;

v_sql_stmt:=
'INSERT INTO MSC_ST_OPERATION_COMPONENTS'
||'  ( COMPONENT_SEQUENCE_ID,'
||'    OPERATION_SEQUENCE_ID,'
||'    BILL_SEQUENCE_ID,'
||'    ROUTING_SEQUENCE_ID,'
||'    ORGANIZATION_ID,'
||'    DELETED_FLAG,'
||'    REFRESH_ID,'
||'    SR_INSTANCE_ID)'
||'  SELECT'
||'    x.COMPONENT_SEQUENCE_ID,'
||'    x.OPERATION_SEQUENCE_ID,'
||'    x.BILL_SEQUENCE_ID,'
||'    x.ROUTING_SEQUENCE_ID,'
||'    x.ORGANIZATION_ID,'
||'    1,'
||'    :v_refresh_id,'
||'    :v_instance_id'
||'  FROM MRP_AD_OPERATION_COMPONENTS_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.RN> :v_lrn '
|| v_temp_sql;

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id, MSC_CL_PULL.v_lrn;

COMMIT;

END IF;

MSC_CL_PULL.v_table_name:= 'MSC_ST_OPERATION_COMPONENTS';
MSC_CL_PULL.v_view_name := 'MRP_AP_OPERATION_COMPONENTS_V';
IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh
v_union_sql :=
'   AND (x.RN1> :v_lrn )'
||' UNION '
||'  SELECT'
||'    x.ORGANIZATION_ID,'
||'    x.COMPONENT_SEQUENCE_ID,'
||'    x.OPERATION_SEQUENCE_ID,'
||'    x.BILL_SEQUENCE_ID,'
||'    x.ROUTING_SEQUENCE_ID,'
||'    2,'
||'  :v_refresh_id,'
||'    :v_instance_id'
||'  FROM MRP_AP_OPERATION_COMPONENTS_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'   AND (x.RN2> :v_lrn )'
||' UNION '
||'  SELECT'
||'    x.ORGANIZATION_ID,'
||'    x.COMPONENT_SEQUENCE_ID,'
||'    x.OPERATION_SEQUENCE_ID,'
||'    x.BILL_SEQUENCE_ID,'
||'    x.ROUTING_SEQUENCE_ID,'
||'    2,'
||'  :v_refresh_id,'
||'    :v_instance_id'
||'  FROM MRP_AP_OPERATION_COMPONENTS_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'   AND (x.RN3> :v_lrn )'
||' UNION '
||'  SELECT'
||'    x.ORGANIZATION_ID,'
||'    x.COMPONENT_SEQUENCE_ID,'
||'    x.OPERATION_SEQUENCE_ID,'
||'    x.BILL_SEQUENCE_ID,'
||'    x.ROUTING_SEQUENCE_ID,'
||'    2,'
||'  :v_refresh_id,'
||'    :v_instance_id'
||'  FROM MRP_AP_OPERATION_COMPONENTS_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'   AND (x.RN4> :v_lrn )'
||' UNION '
||'  SELECT'
||'    x.ORGANIZATION_ID,'
||'    x.COMPONENT_SEQUENCE_ID,'
||'    x.OPERATION_SEQUENCE_ID,'
||'    x.BILL_SEQUENCE_ID,'
||'    x.ROUTING_SEQUENCE_ID,'
||'    2,'
||'  :v_refresh_id,'
||'    :v_instance_id'
||'  FROM MRP_AP_OPERATION_COMPONENTS_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'   AND (x.RN5> :v_lrn )'
||' UNION '
||'  SELECT'
||'    x.ORGANIZATION_ID,'
||'    x.COMPONENT_SEQUENCE_ID,'
||'    x.OPERATION_SEQUENCE_ID,'
||'    x.BILL_SEQUENCE_ID,'
||'    x.ROUTING_SEQUENCE_ID,'
||'    2,'
||'  :v_refresh_id,'
||'    :v_instance_id'
||'  FROM MRP_AP_OPERATION_COMPONENTS_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'   AND (x.RN6> :v_lrn )' ;
ELSE
v_union_sql := '     ';


END IF;

v_sql_stmt:=
'INSERT INTO MSC_ST_OPERATION_COMPONENTS'
||'  ( ORGANIZATION_ID,'
||'    COMPONENT_SEQUENCE_ID,'
||'    OPERATION_SEQUENCE_ID,'
||'    BILL_SEQUENCE_ID,'
||'    ROUTING_SEQUENCE_ID,'
||'    DELETED_FLAG,'
||'   REFRESH_ID,'
||'    SR_INSTANCE_ID)'
||'  SELECT'
||'    x.ORGANIZATION_ID,'
||'    x.COMPONENT_SEQUENCE_ID,'
||'    x.OPERATION_SEQUENCE_ID,'
||'    x.BILL_SEQUENCE_ID,'
||'    x.ROUTING_SEQUENCE_ID,'
||'    2,'
||'  :v_refresh_id,'
||'    :v_instance_id'
||'  FROM MRP_AP_OPERATION_COMPONENTS_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
|| v_union_sql ;

IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id, MSC_CL_PULL.v_lrn,
                                   MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id, MSC_CL_PULL.v_lrn,
                                   MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id, MSC_CL_PULL.v_lrn,
                                   MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id, MSC_CL_PULL.v_lrn,
                                   MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id, MSC_CL_PULL.v_lrn,
                                   MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id, MSC_CL_PULL.v_lrn;

ELSE

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

END IF;

COMMIT;

END IF;  -- MSC_CL_PULL.BOM_ENABLED

END LOAD_OPERATION_COMPONENTS;


END MSC_CL_ROUTING_PULL;

/
