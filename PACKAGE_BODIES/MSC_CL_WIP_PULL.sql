--------------------------------------------------------
--  DDL for Package Body MSC_CL_WIP_PULL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_CL_WIP_PULL" AS -- body
/* $Header:*/



   v_union_sql              varchar2(32767);
   v_temp_tp_sql            VARCHAR2(100);
   v_sql_stmt                    VARCHAR2(32767);
   v_temp_sql                    VARCHAR2(32767);
   v_temp_sql1                   VARCHAR2(32767);
   v_temp_sql2                   VARCHAR2(32767);
   v_temp_sql3                   VARCHAR2(32767);
   v_temp_sql4                   VARCHAR2(32767);
   v_temp_sql5                   VARCHAR2(32767);
--   NULL_DBLINK                  CONSTANT VARCHAR2(1):= ' ';
--   NULL_DBLINK      CONSTANT  VARCHAR2(1) :=MSC_UTIL.NULL_DBLINK;

   v_once_per_org                varchar2(10) := 'NOTDONE';

-----OSFM---------

   PROCEDURE LOAD_OPER_NETWORKS IS
    v_get_apps_ver number;
   BEGIN

IF MSC_CL_PULL.BOM_ENABLED= MSC_UTIL.SYS_YES THEN

IF MSC_CL_PULL.v_apps_ver>= MSC_UTIL.G_APPS115 THEN


MSC_CL_PULL.v_table_name:= 'MSC_ST_OPER_NETWORKS';
MSC_CL_PULL.v_view_name := 'MRP_AD_OPER_NETWORKS_V';

if v_once_per_org <> 'DONE'
then


IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh

IF MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 THEN
   v_temp_sql := ' AND x.ORGANIZATION_ID '||MSC_UTIL.v_in_org_str;
ELSE
   v_temp_sql := NULL;
END IF;

v_sql_stmt:=
' INSERT INTO MSC_ST_OPERATION_NETWORKS'
||'( FROM_OP_SEQ_ID, '
||' TO_OP_SEQ_ID, '
||' DELETED_FLAG, '
||' REFRESH_ID, '
||' SR_INSTANCE_ID) '
||' SELECT '
||' x.FROM_OP_SEQ_ID,'
||' x.TO_OP_SEQ_ID, '
||'   1,'
||'   :v_refresh_id,'
||'   :v_instance_id'
||'  FROM MRP_AD_OPER_NETWORKS_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.RN>'||MSC_CL_PULL.v_lrn
|| v_temp_sql;

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

COMMIT;

END IF; /*  MSC_CL_PULL.v_lrnn<> -1 */

MSC_CL_PULL.v_table_name:= 'MSC_ST_OPERATION_NETWORKS';
MSC_CL_PULL.v_view_name := 'MRP_AP_OPER_NETWORKS_V';

v_sql_stmt:= ' insert into MSC_ST_OPERATION_NETWORKS'
||'( FROM_OP_SEQ_ID, '
||'TO_OP_SEQ_ID, '
||'ROUTING_SEQUENCE_ID, '
||'ORGANIZATION_ID, '
||'TRANSITION_TYPE, '
||'PLANNING_PCT, '
||'CUMMULATIVE_PCT, '
||'EFECTIVITY_DATE, '
||'DISABLE_DATE, '
||'PLAN_ID, '
||'DEPENDENCY_TYPE, '
||'CREATED_BY, '
||'CREATION_DATE, '
||'DELETED_FLAG, '
||'LAST_UPDATED_BY, '
||'LAST_UPDATE_DATE, '
||'LAST_UPDATE_LOGIN, '
||'ATTRIBUTE_CATEGORY, '
||'ATTRIBUTE1, '
||'ATTRIBUTE2, '
||'ATTRIBUTE3, '
||'ATTRIBUTE4, '
||'ATTRIBUTE5, '
||'ATTRIBUTE6, '
||'ATTRIBUTE7, '
||'ATTRIBUTE8, '
||'ATTRIBUTE9, '
||'ATTRIBUTE10, '
||'ATTRIBUTE11, '
||'ATTRIBUTE12, '
||'ATTRIBUTE13, '
||'ATTRIBUTE14, '
||'ATTRIBUTE15, '
||'FROM_OP_SEQ_NUM,'
||'TO_OP_SEQ_NUM,'
||'REFRESH_ID, '
||'SR_INSTANCE_ID) '
||' select '
||' x.FROM_OP_SEQ_ID, '
||' x.TO_OP_SEQ_ID, '
||' x.routing_sequence_id, '
||' x.ORGANIZATION_ID, '
||' x.TRANSITION_TYPE, '
||' x.PLANNING_PCT, '
||' x.CUMMULATIVE_PCT, '
||' x.EFFECTIVITY_DATE, '
||' x.DISABLE_DATE, '
||' -1, '
||' to_number(null), '    /* ds change: dependency_type = null=> prior-next */
||' x.CREATED_BY, '
||' x.CREATION_DATE, '
||' 2, '
||' x.LAST_UPDATED_BY, '
||' x.LAST_UPDATE_DATE, '
||' x.LAST_UPDATE_LOGIN, '
||' x.ATTRIBUTE_CATEGORY, '
||' x.ATTRIBUTE1, '
||' x.ATTRIBUTE2, '
||' x.ATTRIBUTE3, '
||' x.ATTRIBUTE4, '
||' x.ATTRIBUTE5, '
||' x.ATTRIBUTE6, '
||' x.ATTRIBUTE7, '
||' x.ATTRIBUTE8, '
||' x.ATTRIBUTE9, '
||' x.ATTRIBUTE10, '
||' x.ATTRIBUTE11, '
||' x.ATTRIBUTE12, '
||' x.ATTRIBUTE13, '
||' x.ATTRIBUTE14, '
||' x.ATTRIBUTE15, '
||' x.FROM_SEQ_NUM,'
||' x.TO_SEQ_NUM, '
||' :v_refresh_id,'
||' :v_instance_id '
||'  from MRP_AP_OPER_NETWORKS_V'||MSC_CL_PULL.v_dblink||' x'
||'   WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'   AND (x.RN1>'||MSC_CL_PULL.v_lrn
||'    OR x.RN2>'||MSC_CL_PULL.v_lrn
||'    OR x.RN3>'||MSC_CL_PULL.v_lrn
||'    OR x.RN4>'||MSC_CL_PULL.v_lrn
||'    OR x.RN5>'||MSC_CL_PULL.v_lrn
||'    OR x.RN6>'||MSC_CL_PULL.v_lrn||')' ;

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;

v_once_per_org := 'DONE';
  -- opm populates operation network in call to
  -- extract_effectivities

End if;  /* v_once_per_org */

End if;  /* MSC_UTIL.G_APPS115 */
END IF;  -- MSC_CL_PULL.BOM_ENABLED

   END LOAD_OPER_NETWORKS;



   PROCEDURE LOAD_WIP_DEMAND IS
   lv_cond_sql         VARCHAR2(100) := null;
   lv_op_seq_num       varchar2(100) := null;
   lv_lbj_details      NUMBER:=0;
   lv_new_view_name    varchar2(1000) := null;
    lv_new_org_string  varchar2(32767) := null;
    v_temp_sql_stmt    varchar2(32767) := null;
    v_temp_sql         varchar2(32767) := null;
    v_temp_sql_stmt2   varchar2(32767) := null;
    v_temp_sql2        varchar2(32767) := null;
   BEGIN

IF MSC_CL_PULL.WIP_ENABLED= MSC_UTIL.SYS_YES THEN

--=================== Net Change Mode: Delete ==================

lv_op_seq_num := 'x.OPERATION_SEQ_NUM, ';
IF MSC_CL_PULL.v_apps_ver>= MSC_UTIL.G_APPS115 THEN


	select LBJ_DETAILS into lv_lbj_details from msc_apps_instances
                where instance_id = MSC_CL_PULL.v_instance_id ;

	if lv_lbj_details = 1 Then
	lv_op_seq_num := ' x.COPY_OP_SEQ_NUM, ';
	else
	lv_cond_sql := ' AND x.OPERATION_SEQ_NUM <> -1 ';
	end if;

END IF;


IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh

  IF ((MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS120) AND (MSC_UTIL.G_COLLECT_SRP_DATA='Y')) THEN

   -- For Demands from non depo orgs

   MSC_CL_PULL.v_table_name:= 'MSC_ST_DEMANDS';
   MSC_CL_PULL.v_view_name := 'MRP_AD_NON_ERO_WIP_COMP_DEM_V';

   v_sql_stmt:=
     'insert into MSC_ST_DEMANDS'
     ||'  ( WIP_ENTITY_ID,'
     ||'    OPERATION_SEQ_NUM,'
     ||'    INVENTORY_ITEM_ID,'
     ||'    ORGANIZATION_ID,'
     ||'    ORIGINATION_TYPE,'
     ||'    DELETED_FLAG,'
     ||'    REFRESH_ID,'
     ||'    SR_INSTANCE_ID)'
     ||'  select'
     ||'    x.WIP_ENTITY_ID,'
     ||     lv_op_seq_num
     ||'    x.INVENTORY_ITEM_ID,'
     ||'    x.ORGANIZATION_ID,'
     ||'    x.ORIGINATION_TYPE,'
     ||'    1,'
     ||'    :v_refresh_id,'
     ||'    :v_instance_id'
     ||'  from MRP_AD_NON_ERO_WIP_COMP_DEM_V'||MSC_CL_PULL.v_dblink||' x'
     ||'  where ( DECODE( :v_mps_consume_profile_value,'
     ||'                  1, x.WJS_MPS_NET_QTY_FLAG,'
     ||'                  x.WJS_NET_QTY_FLAG)=1'
     ||'       OR x.MRP_NET_FLAG= 1'
     ||'       OR DECODE( :v_mps_consume_profile_value,'
     ||'                  1, x.MPS_FLAG,'
     ||'                  x.NMPS_FLAG)= 1 )'
     ||'    AND x.RN> :v_lrn '
     ||'    AND x.ORGANIZATION_ID  '||MSC_UTIL.v_non_depot_org_str ;

   -- For Demands from depot repair orgs

   MSC_CL_PULL.v_table_name:= 'MSC_ST_DEMANDS';
   MSC_CL_PULL.v_view_name := 'MRP_AD_NON_RO_WIP_COMP_DEM_V';

   v_temp_sql:=
     'insert into MSC_ST_DEMANDS'
     ||'  ( WIP_ENTITY_ID,'
     ||'    OPERATION_SEQ_NUM,'
     ||'    INVENTORY_ITEM_ID,'
     ||'    ORGANIZATION_ID,'
     ||'    ORIGINATION_TYPE,'
     ||'    DELETED_FLAG,'
     ||'    REFRESH_ID,'
     ||'    SR_INSTANCE_ID)'
     ||'  select'
     ||'    x.WIP_ENTITY_ID,'
     ||     lv_op_seq_num
     ||'    x.INVENTORY_ITEM_ID,'
     ||'    x.ORGANIZATION_ID,'
     ||'    x.ORIGINATION_TYPE,'
     ||'    1,'
     ||'    :v_refresh_id,'
     ||'    :v_instance_id'
     ||'  from MRP_AD_NON_RO_WIP_COMP_DEM_V'||MSC_CL_PULL.v_dblink||' x'
     ||'  where ( DECODE( :v_mps_consume_profile_value,'
     ||'                  1, x.WJS_MPS_NET_QTY_FLAG,'
     ||'                  x.WJS_NET_QTY_FLAG)=1'
     ||'       OR x.MRP_NET_FLAG= 1'
     ||'       OR DECODE( :v_mps_consume_profile_value,'
     ||'                  1, x.MPS_FLAG,'
     ||'                  x.NMPS_FLAG)= 1 )'
     ||'    AND x.RN> :v_lrn '
     ||'    AND x.ORGANIZATION_ID  '||MSC_UTIL.v_depot_org_str ;

   EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id,
                                   MSC_CL_PULL.v_instance_id,
                                   MSC_CL_PULL.v_mps_consume_profile_value,
                                   MSC_CL_PULL.v_mps_consume_profile_value,
                                   MSC_CL_PULL.v_lrn;

   EXECUTE IMMEDIATE v_temp_sql USING MSC_CL_PULL.v_refresh_id,
                                   MSC_CL_PULL.v_instance_id,
                                   MSC_CL_PULL.v_mps_consume_profile_value,
                                   MSC_CL_PULL.v_mps_consume_profile_value,
                                   MSC_CL_PULL.v_lrn;

   COMMIT;

 ELSE  -- If srp profile is No

   MSC_CL_PULL.v_table_name:= 'MSC_ST_DEMANDS';
   MSC_CL_PULL.v_view_name := 'MRP_AD_WIP_COMP_DEMANDS_V';

   IF MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 THEN
     v_temp_sql := ' AND x.ORGANIZATION_ID '||MSC_UTIL.v_in_org_str;
   ELSE
     v_temp_sql := NULL;
   END IF;

   v_sql_stmt:=
     'insert into MSC_ST_DEMANDS'
     ||'  ( WIP_ENTITY_ID,'
     ||'    OPERATION_SEQ_NUM,'
     ||'    INVENTORY_ITEM_ID,'
     ||'    ORGANIZATION_ID,'
     ||'    ORIGINATION_TYPE,'
     ||'    DELETED_FLAG,'
     ||'    REFRESH_ID,'
     ||'    SR_INSTANCE_ID)'
     ||'  select'
     ||'    x.WIP_ENTITY_ID,'
     ||     lv_op_seq_num
     ||'    x.INVENTORY_ITEM_ID,'
     ||'    x.ORGANIZATION_ID,'
     ||'    x.ORIGINATION_TYPE,'
     ||'    1,'
     ||'    :v_refresh_id,'
     ||'    :v_instance_id'
     ||'  from MRP_AD_WIP_COMP_DEMANDS_V'||MSC_CL_PULL.v_dblink||' x'
     ||'  where ( DECODE( :v_mps_consume_profile_value,'
     ||'                  1, x.WJS_MPS_NET_QTY_FLAG,'
     ||'                  x.WJS_NET_QTY_FLAG)=1'
     ||'       OR x.MRP_NET_FLAG= 1'
     ||'       OR DECODE( :v_mps_consume_profile_value,'
     ||'                  1, x.MPS_FLAG,'
     ||'                  x.NMPS_FLAG)= 1 )'
     ||'    AND x.RN> :v_lrn '
     || v_temp_sql;

   EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id,
                                   MSC_CL_PULL.v_instance_id,
                                   MSC_CL_PULL.v_mps_consume_profile_value,
                                   MSC_CL_PULL.v_mps_consume_profile_value,
                                   MSC_CL_PULL.v_lrn;

   COMMIT;
  END IF;
  END IF;


IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh

MSC_CL_PULL.v_table_name:= 'MSC_ST_DEMANDS';
MSC_CL_PULL.v_view_name := 'MRP_AD_WIP_FLOW_DEMANDS_V';

IF MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 THEN
   v_temp_sql := ' AND x.ORGANIZATION_ID '||MSC_UTIL.v_in_org_str;
ELSE
   v_temp_sql := NULL;
END IF;

v_sql_stmt:=
'insert into MSC_ST_DEMANDS'
||'  ( WIP_ENTITY_ID,'
||'    ORIGINATION_TYPE,'
||'    ORGANIZATION_ID,'
||'    DELETED_FLAG,'
||'    REFRESH_ID,'
||'    SR_INSTANCE_ID)'
||'  select distinct'
||'    x.WIP_ENTITY_ID,'
||'    x.ORIGINATION_TYPE,'
||'    x.ORGANIZATION_ID,'
||'    1,'
||'    :v_refresh_id,'
||'    :v_instance_id'
||'  from MRP_AD_WIP_FLOW_DEMANDS_V'||MSC_CL_PULL.v_dblink||' x'
||'  where x.RN> :v_lrn '
|| v_temp_sql;

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id,
                                   MSC_CL_PULL.v_instance_id,
                                   MSC_CL_PULL.v_lrn;

COMMIT;

END IF;

MSC_CL_PULL.v_table_name:= 'MSC_ST_DEMANDS';
MSC_CL_PULL.v_view_name := 'MRP_AP_WIP_COMP_DEMANDS_V';

IF MSC_CL_PULL.v_apps_ver>= MSC_UTIL.G_APPS115 THEN
  v_temp_sql := 'x.quantity_per_assembly,x.asset_item_id,x.asset_serial_number,x.basis_type,x.component_yield_factor, ';  /* ds change */

ELSE

  v_temp_sql := ' NULL, NULL, NULL, NULL, NULL, ';  /* ds change */
END IF;

IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh

-- BUG 3036681
-- No need to check on RN3 (on wip_discrete_jobs) as the
-- materialized view on wip_requirement_operations now has
-- the columns from wip_discrete_jobs too.

v_union_sql :=
'   AND ( x.RN1> :v_lrn)'  -- NCP: changed to RN2

/* NCP: don't need union below
||' UNION '
||'  select'
||'    x.INVENTORY_ITEM_ID,'
||'    x.ORGANIZATION_ID,'
||'    x.WIP_ENTITY_ID,'
||'    x.WIP_ENTITY_NAME,'
||'    x.STATUS_CODE,'
||'    x.WIP_SUPPLY_TYPE,'
||     lv_op_seq_num
||'    x.NEW_REQUIRED_QUANTITY,'    -- Bug fix
||'    x.QUANTITY_ISSUED,'
||'    x.JOB_REFERENCE_ITEM_ID,'
||'    x.DEMAND_TYPE,'
||'    x.PROJECT_ID,'
||'    x.TASK_ID,'
||'    x.PLANNING_GROUP,'
||'    x.END_ITEM_UNIT_NUMBER,'
--||'    DECODE( x.DEMAND_CLASS,NULL,NULL,:V_ICODE||x.DEMAND_CLASS),'
||'    x.DEMAND_CLASS,'
||'    x.ORIGINATION_TYPE,'
||'    x.DATE_REQUIRED- :v_dgmt,'
||'    x.MPS_DATE_REQUIRED- :v_dgmt,'
||'    2,'
||'    :v_refresh_id,'
||'    :v_instance_id'
||'  from MRP_AP_WIP_COMP_DEMANDS_V'||MSC_CL_PULL.v_dblink||' x'
||'  WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'   AND ( x.RN2>'||MSC_CL_PULL.v_lrn||')'
*/
||' UNION '
||'  select'
||'    x.INVENTORY_ITEM_ID,'
||'    x.INVENTORY_ITEM_ID,'
||'    x.ORGANIZATION_ID,'
||'    x.WIP_ENTITY_ID,'
||'    x.WIP_ENTITY_ID,'
||'    x.WIP_ENTITY_NAME, '
||'    x.STATUS_CODE,'
||'    x.WIP_SUPPLY_TYPE,'
||     lv_op_seq_num
||'    x.NEW_REQUIRED_QUANTITY,'    -- Bug fix
||'    x.QUANTITY_ISSUED,'
||'    x.JOB_REFERENCE_ITEM_ID,'
||'    x.DEMAND_TYPE,'
||'    x.PROJECT_ID,'
||'    x.TASK_ID,'
||'    x.PLANNING_GROUP,'
||'    x.END_ITEM_UNIT_NUMBER,'
--||'    DECODE( x.DEMAND_CLASS,NULL,NULL,:V_ICODE||x.DEMAND_CLASS),'
||'    x.DEMAND_CLASS,'
||'    x.ORIGINATION_TYPE,'
||'    x.DATE_REQUIRED- :v_dgmt,'
||'    x.MPS_DATE_REQUIRED- :v_dgmt,'
||'    2,'
||     v_temp_sql
||'    :v_refresh_id,'
||'    :v_instance_id'
||'  from MRP_AP_WIP_COMP_DEMANDS_V'||MSC_CL_PULL.v_dblink||' x'
||'  WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'   AND x.NEW_REQUIRED_QUANTITY > 0'
--||'   AND DECODE(:V_COLLECT_COMPLETED_JOBS,'
--||'       2 ,x.coll_completed_qty_ind,'
--||'       1) >0'
||'   AND DECODE(:v_collect_completed_jobs,'
||'       2,x.status_code,'
||'       1) <>4'    -- 5730031
||'   AND ( x.RN2> :v_lrn )'
||' UNION '
||'  select'
||'    x.INVENTORY_ITEM_ID,'
||'    x.INVENTORY_ITEM_ID,'
||'    x.ORGANIZATION_ID,'
||'    x.WIP_ENTITY_ID,'
||'    x.WIP_ENTITY_ID,'
||'    x.WIP_ENTITY_NAME, '
||'    x.STATUS_CODE,'
||'    x.WIP_SUPPLY_TYPE,'
||     lv_op_seq_num
||'    x.NEW_REQUIRED_QUANTITY,'    -- Bug fix
||'    x.QUANTITY_ISSUED,'
||'    x.JOB_REFERENCE_ITEM_ID,'
||'    x.DEMAND_TYPE,'
||'    x.PROJECT_ID,'
||'    x.TASK_ID,'
||'    x.PLANNING_GROUP,'
||'    x.END_ITEM_UNIT_NUMBER,'
--||'    DECODE( x.DEMAND_CLASS,NULL,NULL,:V_ICODE||x.DEMAND_CLASS),'
||'    x.DEMAND_CLASS,'
||'    x.ORIGINATION_TYPE,'
||'    x.DATE_REQUIRED- :v_dgmt,'
||'    x.MPS_DATE_REQUIRED- :v_dgmt,'
||'    2,'
||     v_temp_sql
||'    :v_refresh_id,'
||'    :v_instance_id'
||'  from MRP_AP_WIP_COMP_DEMANDS_V'||MSC_CL_PULL.v_dblink||' x'
||'  WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'   AND x.NEW_REQUIRED_QUANTITY > 0'
--||'   AND DECODE(:V_COLLECT_COMPLETED_JOBS,'
--||'       2 ,x.coll_completed_qty_ind,'
--||'       1) >0'
||'   AND DECODE(:v_collect_completed_jobs,'
||'       2,x.status_code,'
||'       1) <>4'    -- 5730031
||'   AND ( x.RN3> :v_lrn )';
ELSE
v_union_sql := '    ';
END IF;

v_sql_stmt:=
'insert into MSC_ST_DEMANDS'
||'  ( INVENTORY_ITEM_ID,'
||'    SOURCE_INVENTORY_ITEM_ID,'
||'    ORGANIZATION_ID,'
||'    WIP_ENTITY_ID,'
||'    SOURCE_WIP_ENTITY_ID,'
||'    ORDER_NUMBER,'                    -- changes
||'    WIP_STATUS_CODE,'
||'    WIP_SUPPLY_TYPE,'
||'    OPERATION_SEQ_NUM,'
||'    USING_REQUIREMENT_QUANTITY,'
||'    QUANTITY_ISSUED,'
||'    USING_ASSEMBLY_ITEM_ID,'
||'    DEMAND_TYPE,'
||'    PROJECT_ID,'
||'    TASK_ID,'
||'    PLANNING_GROUP,'
||'    END_ITEM_UNIT_NUMBER,'
||'    DEMAND_CLASS,'
||'    ORIGINATION_TYPE,'
||'    USING_ASSEMBLY_DEMAND_DATE,'
||'    MPS_DATE_REQUIRED,'
||'    DELETED_FLAG,'
||'    QUANTITY_PER_ASSEMBLY,'
||'    ASSET_ITEM_ID,'     /* ds change */
||'    ASSET_SERIAL_NUMBER,'  /* ds change */
||'    COMPONENT_SCALING_TYPE,'
||'    COMPONENT_YIELD_FACTOR,'
||'    REFRESH_ID,'
||'    SR_INSTANCE_ID)'
||'  select'
||'    x.INVENTORY_ITEM_ID,'
||'    x.INVENTORY_ITEM_ID,'
||'    x.ORGANIZATION_ID,'
||'    x.WIP_ENTITY_ID,'
||'    x.WIP_ENTITY_ID,'
||'    x.WIP_ENTITY_NAME, '
||'    x.STATUS_CODE,'
||'    x.WIP_SUPPLY_TYPE,'
||     lv_op_seq_num
||'    x.NEW_REQUIRED_QUANTITY,'    -- Bug fix
||'    x.QUANTITY_ISSUED,'
||'    x.JOB_REFERENCE_ITEM_ID,'
||'    x.DEMAND_TYPE,'
||'    x.PROJECT_ID,'
||'    x.TASK_ID,'
||'    x.PLANNING_GROUP,'
||'    x.END_ITEM_UNIT_NUMBER,'
--||'    DECODE( x.DEMAND_CLASS,NULL,NULL,:V_ICODE||x.DEMAND_CLASS),'
||'    x.DEMAND_CLASS,'
||'    x.ORIGINATION_TYPE,'
||'    x.DATE_REQUIRED- :v_dgmt,'
||'    x.MPS_DATE_REQUIRED- :v_dgmt,'
||'    2,'
||     v_temp_sql
||'    :v_refresh_id,'
||'    :v_instance_id'
||'  from  ';

v_temp_sql2  := v_sql_stmt;

v_temp_sql := '   AND DECODE(:v_collect_completed_jobs,'
||'       2,x.status_code,'
||'       1) <>4'    -- 5730031
--'    AND DECODE(:V_COLLECT_COMPLETED_JOBS,'
--||'       2,x.coll_completed_qty_ind,'
--||'       1) >0'
||   lv_cond_sql
||'   AND x.NEW_REQUIRED_QUANTITY > 0'
|| v_union_sql ;


 if (MSC_UTIL.G_COLLECT_SRP_DATA='N' or MSC_CL_PULL.v_lrnn<> -1 or MSC_CL_PULL.v_apps_ver < MSC_UTIL.G_APPS120) Then     /* Build v_sql_stmt based on the MSC_SRP_ENABLED profile Bug 5909379 */

    MSC_CL_PULL.v_table_name:= 'MSC_ST_DEMANDS';
    lv_new_view_name  := 'MRP_AP_WIP_COMP_DEMANDS_V';
    lv_new_org_string := MSC_UTIL.v_in_org_str;

    v_temp_sql_stmt := v_sql_stmt||'  MRP_AP_WIP_COMP_DEMANDS_V'||MSC_CL_PULL.v_dblink||'  x'
                      ||'  WHERE x.ORGANIZATION_ID  '||lv_new_org_string||v_temp_sql;
else              -- Profile MSC_UTIL.G_COLLECT_SRP_DATA = 'Y'


    MSC_CL_PULL.v_table_name:= 'MSC_ST_DEMANDS';
    lv_new_view_name  := 'MRP_AP_NON_ERO_WIP_DEMAND_V';
    lv_new_org_string := MSC_UTIL.v_non_depot_org_str;

    v_temp_sql_stmt := v_sql_stmt||'  MRP_AP_NON_ERO_WIP_DEMAND_V'||MSC_CL_PULL.v_dblink||'  x'
                      ||'  WHERE x.ORGANIZATION_ID  '||lv_new_org_string||v_temp_sql;
        ---- Code for SRP when Repair Orders Entity is/not selected . Building v_sql_stmt
end if;
IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh


EXECUTE IMMEDIATE v_temp_sql_stmt
            USING  MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id, MSC_CL_PULL.V_COLLECT_COMPLETED_JOBS, MSC_CL_PULL.v_lrn,
                   MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id, MSC_CL_PULL.V_COLLECT_COMPLETED_JOBS, MSC_CL_PULL.v_lrn,
                   MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id, MSC_CL_PULL.V_COLLECT_COMPLETED_JOBS, MSC_CL_PULL.v_lrn;

/* NCP:
                   MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id,
                   MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;
*/

ELSE

    if (MSC_UTIL.G_COLLECT_SRP_DATA='Y' AND MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS120) Then
            Begin

            EXECUTE IMMEDIATE v_temp_sql_stmt
            USING  MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id, MSC_CL_PULL.V_COLLECT_COMPLETED_JOBS;


                      v_temp_sql_stmt := NULL;
                      MSC_CL_PULL.v_table_name      := 'MSC_ST_DEMANDS';
                      lv_new_view_name  := 'MRP_AP_NON_RO_WIP_DEMAND_V';
                      lv_new_org_string :=  MSC_UTIL.v_depot_org_str;

                      v_temp_sql_stmt := v_sql_stmt||'  MRP_AP_NON_RO_WIP_DEMAND_V'||MSC_CL_PULL.v_dblink||'  x'
                      ||'  WHERE x.ORGANIZATION_ID  '||lv_new_org_string||v_temp_sql;


                     EXECUTE IMMEDIATE v_temp_sql_stmt
                      USING  MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id, MSC_CL_PULL.V_COLLECT_COMPLETED_JOBS;


            end;  /* Code for SRP To get the work orders not attached to repair orders:  bug 5909379  */
      ELSE
           EXECUTE IMMEDIATE v_temp_sql_stmt
            USING  MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id, MSC_CL_PULL.V_COLLECT_COMPLETED_JOBS;

      end if;  -- For SRP and  MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS120
END IF;

COMMIT;


--=================== REPT ITEM DEMAND        ==================
--=================== Net Change Mode: Delete ==================

IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh

MSC_CL_PULL.v_table_name:= 'MSC_ST_DEMANDS';
MSC_CL_PULL.v_view_name := 'MRP_AD_REPT_ITEM_DEMANDS_V';

IF MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 THEN
   v_temp_sql := ' AND x.ORGANIZATION_ID '||MSC_UTIL.v_in_org_str;
ELSE
   v_temp_sql := NULL;
END IF;

v_sql_stmt:=
' insert into MSC_ST_DEMANDS'
||'  ( INVENTORY_ITEM_ID,'
||'    WIP_ENTITY_ID,'
||'    OPERATION_SEQ_NUM,'
||'    REPETITIVE_SCHEDULE_ID,'
||'    ORGANIZATION_ID,'
||'    ORIGINATION_TYPE,'
||'    DELETED_FLAG,'
||'    REFRESH_ID,'
||'    SR_INSTANCE_ID)'
||'  select'
||'    x.INVENTORY_ITEM_ID,'
||'    x.WIP_ENTITY_ID,'
||'    x.OPERATION_SEQ_NUM,'
||'    x.REPETITIVE_SCHEDULE_ID,'
||'    x.ORGANIZATION_ID,'
||'    x.ORIGINATION_TYPE,'
||'    1,'
||'    :v_refresh_id,'
||'    :v_instance_id'
||'  from MRP_AD_REPT_ITEM_DEMANDS_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.RN> :v_lrn '
|| v_temp_sql;

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id, MSC_CL_PULL.v_lrn;

COMMIT;

END IF;


MSC_CL_PULL.v_table_name:= 'MSC_ST_DEMANDS';
MSC_CL_PULL.v_view_name := 'MRP_AP_REPT_ITEM_DEMANDS_V';

IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh

v_union_sql :=
'   AND ( x.RN1 > :v_lrn )'
||' UNION '
||'  select'
||'    x.INVENTORY_ITEM_ID,'
||'    x.ORGANIZATION_ID,'
||'    x.WIP_ENTITY_ID,'
||'    x.OPERATION_SEQ_NUM,'
||'    x.REPETITIVE_SCHEDULE_ID,'
||'    x.WIP_ENTITY_NAME, '
||'    x.REQUIRED_QUANTITY,'
||'    x.DATE_REQUIRED,'
||'    x.QUANTITY_ISSUED,'
||'    x.JOB_REFERENCE_ITEM_ID,'
||'    x.WIP_ENTITY_TYPE,'
||'    x.DEMAND_CLASS,'
||'    x.ORIGINATION_TYPE,'
||'    x.STATUS_CODE,'
||'    x.WIP_SUPPLY_TYPE,'
||'    2,'
||'  :v_refresh_id,'
||'    :v_instance_id'
||'  from MRP_AP_REPT_ITEM_DEMANDS_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'   AND ( x.RN2 > :v_lrn )'
||' UNION '
||'  select'
||'    x.INVENTORY_ITEM_ID,'
||'    x.ORGANIZATION_ID,'
||'    x.WIP_ENTITY_ID,'
||'    x.OPERATION_SEQ_NUM,'
||'    x.REPETITIVE_SCHEDULE_ID,'
||'    x.WIP_ENTITY_NAME, '
||'    x.REQUIRED_QUANTITY,'
||'    x.DATE_REQUIRED,'
||'    x.QUANTITY_ISSUED,'
||'    x.JOB_REFERENCE_ITEM_ID,'
||'    x.WIP_ENTITY_TYPE,'
||'    x.DEMAND_CLASS,'
||'    x.ORIGINATION_TYPE,'
||'    x.STATUS_CODE,'
||'    x.WIP_SUPPLY_TYPE,'
||'    2,'
||'  :v_refresh_id,'
||'    :v_instance_id'
||'  from MRP_AP_REPT_ITEM_DEMANDS_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'   AND ( x.RN3 > :v_lrn )'
||' UNION '
||'  select'
||'    x.INVENTORY_ITEM_ID,'
||'    x.ORGANIZATION_ID,'
||'    x.WIP_ENTITY_ID,'
||'    x.OPERATION_SEQ_NUM,'
||'    x.REPETITIVE_SCHEDULE_ID,'
||'    x.WIP_ENTITY_NAME, '
||'    x.REQUIRED_QUANTITY,'
||'    x.DATE_REQUIRED,'
||'    x.QUANTITY_ISSUED,'
||'    x.JOB_REFERENCE_ITEM_ID,'
||'    x.WIP_ENTITY_TYPE,'
||'    x.DEMAND_CLASS,'
||'    x.ORIGINATION_TYPE,'
||'    x.STATUS_CODE,'
||'    x.WIP_SUPPLY_TYPE,'
||'    2,'
||'  :v_refresh_id,'
||'    :v_instance_id'
||'  from MRP_AP_REPT_ITEM_DEMANDS_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'   AND ( x.RN4 > :v_lrn )'
||' UNION '
||'  select'
||'    x.INVENTORY_ITEM_ID,'
||'    x.ORGANIZATION_ID,'
||'    x.WIP_ENTITY_ID,'
||'    x.OPERATION_SEQ_NUM,'
||'    x.REPETITIVE_SCHEDULE_ID,'
||'    x.WIP_ENTITY_NAME, '
||'    x.REQUIRED_QUANTITY,'
||'    x.DATE_REQUIRED,'
||'    x.QUANTITY_ISSUED,'
||'    x.JOB_REFERENCE_ITEM_ID,'
||'    x.WIP_ENTITY_TYPE,'
||'    x.DEMAND_CLASS,'
||'    x.ORIGINATION_TYPE,'
||'    x.STATUS_CODE,'
||'    x.WIP_SUPPLY_TYPE,'
||'    2,'
||'  :v_refresh_id,'
||'    :v_instance_id'
||'  from MRP_AP_REPT_ITEM_DEMANDS_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'   AND ( x.RN5 > :v_lrn )';

ELSE

v_union_sql := '     ';

END IF;


v_sql_stmt:=
' insert into MSC_ST_DEMANDS'
||'  ( INVENTORY_ITEM_ID,'
||'    ORGANIZATION_ID,'
||'    WIP_ENTITY_ID,'
||'    OPERATION_SEQ_NUM,'
||'    REPETITIVE_SCHEDULE_ID,'
||'    ORDER_NUMBER,'
||'    USING_REQUIREMENT_QUANTITY,'
||'    USING_ASSEMBLY_DEMAND_DATE,'
||'    QUANTITY_ISSUED,'
||'    USING_ASSEMBLY_ITEM_ID,'
||'    DEMAND_TYPE,'
||'    DEMAND_CLASS,'
||'    ORIGINATION_TYPE,'
||'    WIP_STATUS_CODE,'
||'    WIP_SUPPLY_TYPE,'
||'    DELETED_FLAG,'
||'   REFRESH_ID,'
||'    SR_INSTANCE_ID)'
||'  select'
||'    x.INVENTORY_ITEM_ID,'
||'    x.ORGANIZATION_ID,'
||'    x.WIP_ENTITY_ID,'
||'    x.OPERATION_SEQ_NUM,'
||'    x.REPETITIVE_SCHEDULE_ID,'
||'    x.WIP_ENTITY_NAME, '
||'    x.REQUIRED_QUANTITY,'
||'    x.DATE_REQUIRED,'
||'    x.QUANTITY_ISSUED,'
||'    x.JOB_REFERENCE_ITEM_ID,'
||'    x.WIP_ENTITY_TYPE,'
--||'    DECODE( x.DEMAND_CLASS, NULL, NULL, :V_ICODE||x.DEMAND_CLASS),'
||'    x.DEMAND_CLASS,'
||'    x.ORIGINATION_TYPE,'
||'    x.STATUS_CODE,'
||'    x.WIP_SUPPLY_TYPE,'
||'    2,'
||'  :v_refresh_id,'
||'    :v_instance_id'
||'  from MRP_AP_REPT_ITEM_DEMANDS_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
|| v_union_sql;



IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh

EXECUTE IMMEDIATE v_sql_stmt
            USING  MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id, MSC_CL_PULL.v_lrn,
                   MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id, MSC_CL_PULL.v_lrn,
                   MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id, MSC_CL_PULL.v_lrn,
                   MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id, MSC_CL_PULL.v_lrn,
                   MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id, MSC_CL_PULL.v_lrn;

ELSE
EXECUTE IMMEDIATE v_sql_stmt
            USING  MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;
END IF;

COMMIT;
--=================== CMRO Work Order DEMAND        ==================
IF (MSC_UTIL.g_collect_cmro_data = 'Y' and
    MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS121) THEN


    IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh

       MSC_CL_PULL.v_table_name:= 'MSC_ST_DEMANDS';
       MSC_CL_PULL.v_view_name := 'MRP_AD_CMRO_WIP_COMP_DMD_V';

       -- Code AD View here -- PENDING --

    END IF;



    MSC_CL_PULL.v_table_name:= 'MSC_ST_DEMANDS';
    MSC_CL_PULL.v_view_name := 'MRP_AP_CMRO_WIP_COMP_DMD_V';

IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh

v_union_sql :=
'   AND ( x.RN1> :v_lrn)'
||' UNION '
||'  select'
||'    x.INVENTORY_ITEM_ID,'
||'    x.INVENTORY_ITEM_ID,'
||'    x.ORGANIZATION_ID,'
||'    x.WIP_ENTITY_ID,'
||'    x.WIP_ENTITY_ID,'
||'    x.WIP_ENTITY_NAME, '
||'    x.STATUS_CODE,'
||'    x.WIP_SUPPLY_TYPE,'
||'    x.COPY_OP_SEQ_NUM, '
||'    x.NEW_REQUIRED_QUANTITY,'
||'    x.QUANTITY_ISSUED,'
||'    x.JOB_REFERENCE_ITEM_ID,'
||'    x.DEMAND_TYPE,'
||'    x.PROJECT_ID,'
||'    x.TASK_ID,'
||'    x.PLANNING_GROUP,'
||'    x.END_ITEM_UNIT_NUMBER,'
||'    x.DEMAND_CLASS,'
||'    x.ORIGINATION_TYPE,'
||'    x.DATE_REQUIRED- :v_dgmt,'
||'    x.MPS_DATE_REQUIRED- :v_dgmt,'
||'    2,'
||'    X.QUANTITY_PER_ASSEMBLY,'
||'    X.ASSET_ITEM_ID,'
||'    X.ASSET_SERIAL_NUMBER,'
||'    X.BASIS_TYPE,'
||'    X.COMPONENT_YIELD_FACTOR,'
||'    :v_refresh_id,'
||'    :v_instance_id'
||'  from  MRP_AP_CMRO_WIP_COMP_DMD_V'||MSC_CL_PULL.v_dblink||'  X'
||'  WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'   AND ( x.RN2> :v_lrn )'
||' UNION '
||'  select'
||'    x.INVENTORY_ITEM_ID,'
||'    x.INVENTORY_ITEM_ID,'
||'    x.ORGANIZATION_ID,'
||'    x.WIP_ENTITY_ID,'
||'    x.WIP_ENTITY_ID,'
||'    x.WIP_ENTITY_NAME, '
||'    x.STATUS_CODE,'
||'    x.WIP_SUPPLY_TYPE,'
||'    x.COPY_OP_SEQ_NUM, '
||'    x.NEW_REQUIRED_QUANTITY,'
||'    x.QUANTITY_ISSUED,'
||'    x.JOB_REFERENCE_ITEM_ID,'
||'    x.DEMAND_TYPE,'
||'    x.PROJECT_ID,'
||'    x.TASK_ID,'
||'    x.PLANNING_GROUP,'
||'    x.END_ITEM_UNIT_NUMBER,'
||'    x.DEMAND_CLASS,'
||'    x.ORIGINATION_TYPE,'
||'    x.DATE_REQUIRED- :v_dgmt,'
||'    x.MPS_DATE_REQUIRED- :v_dgmt,'
||'    2,'
||'    X.QUANTITY_PER_ASSEMBLY,'
||'    X.ASSET_ITEM_ID,'
||'    X.ASSET_SERIAL_NUMBER,'
||'    X.BASIS_TYPE,'
||'    X.COMPONENT_YIELD_FACTOR,'
||'    :v_refresh_id,'
||'    :v_instance_id'
||'  from  MRP_AP_CMRO_WIP_COMP_DMD_V'||MSC_CL_PULL.v_dblink||'  X'
||'  WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'   AND ( x.RN3> :v_lrn )';
ELSE
v_union_sql := '    ';
END IF;

v_sql_stmt:=
'insert into MSC_ST_DEMANDS'
||'  ( INVENTORY_ITEM_ID,'
||'    SOURCE_INVENTORY_ITEM_ID,'
||'    ORGANIZATION_ID,'
||'    WIP_ENTITY_ID,'
||'    SOURCE_WIP_ENTITY_ID,'
||'    ORDER_NUMBER,'
||'    WIP_STATUS_CODE,'
||'    WIP_SUPPLY_TYPE,'
||'    OPERATION_SEQ_NUM,'
||'    USING_REQUIREMENT_QUANTITY,'
||'    QUANTITY_ISSUED,'
||'    USING_ASSEMBLY_ITEM_ID,'
||'    DEMAND_TYPE,'
||'    PROJECT_ID,'
||'    TASK_ID,'
||'    PLANNING_GROUP,'
||'    END_ITEM_UNIT_NUMBER,'
||'    DEMAND_CLASS,'
||'    ORIGINATION_TYPE,'
||'    USING_ASSEMBLY_DEMAND_DATE,'
||'    MPS_DATE_REQUIRED,'
||'    DELETED_FLAG,'
||'    QUANTITY_PER_ASSEMBLY,'
||'    ASSET_ITEM_ID,'
||'    ASSET_SERIAL_NUMBER,'
||'    COMPONENT_SCALING_TYPE,'
||'    COMPONENT_YIELD_FACTOR,'
||'    REFRESH_ID,'
||'    SR_INSTANCE_ID)'
||'  select'
||'    x.INVENTORY_ITEM_ID,'
||'    x.INVENTORY_ITEM_ID,'
||'    x.ORGANIZATION_ID,'
||'    x.WIP_ENTITY_ID,'
||'    x.WIP_ENTITY_ID,'
||'    x.WIP_ENTITY_NAME, '
||'    x.STATUS_CODE,'
||'    x.WIP_SUPPLY_TYPE,'
||'    x.COPY_OP_SEQ_NUM, '
||'    x.NEW_REQUIRED_QUANTITY,'
||'    x.QUANTITY_ISSUED,'
||'    x.JOB_REFERENCE_ITEM_ID,'
||'    x.DEMAND_TYPE,'
||'    x.PROJECT_ID,'
||'    x.TASK_ID,'
||'    x.PLANNING_GROUP,'
||'    x.END_ITEM_UNIT_NUMBER,'
||'    x.DEMAND_CLASS,'
||'    x.ORIGINATION_TYPE,'
||'    x.DATE_REQUIRED- :v_dgmt,'
||'    x.MPS_DATE_REQUIRED- :v_dgmt,'
||'    2,'
||'    X.QUANTITY_PER_ASSEMBLY,'
||'    X.ASSET_ITEM_ID,'
||'    X.ASSET_SERIAL_NUMBER,'
||'    X.BASIS_TYPE,'
||'    X.COMPONENT_YIELD_FACTOR,'
||'    :v_refresh_id,'
||'    :v_instance_id'
||'  from  MRP_AP_CMRO_WIP_COMP_DMD_V'||MSC_CL_PULL.v_dblink||'  X'
||'  WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
;


v_temp_sql := '   AND DECODE(:v_collect_completed_jobs,'
||'       2,x.status_code,'
||'       1) <>4'
||'   AND x.NEW_REQUIRED_QUANTITY > 0';


IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh


v_temp_sql_stmt := v_sql_stmt ||  v_union_sql;

EXECUTE IMMEDIATE v_temp_sql_stmt
            USING  MSC_CL_PULL.v_dgmt,
                   MSC_CL_PULL.v_dgmt,
                   MSC_CL_PULL.v_refresh_id,
                   MSC_CL_PULL.v_instance_id,
                   MSC_CL_PULL.v_lrn,
                   MSC_CL_PULL.v_dgmt,
                   MSC_CL_PULL.v_dgmt,
                   MSC_CL_PULL.v_refresh_id,
                   MSC_CL_PULL.v_instance_id,
                   MSC_CL_PULL.v_lrn,
                   MSC_CL_PULL.v_dgmt,
                   MSC_CL_PULL.v_dgmt,
                   MSC_CL_PULL.v_refresh_id,
                   MSC_CL_PULL.v_instance_id,
                   MSC_CL_PULL.v_lrn;


ELSE

v_temp_sql_stmt := v_sql_stmt || v_temp_sql;

EXECUTE IMMEDIATE v_temp_sql_stmt
            USING  MSC_CL_PULL.v_dgmt,
                   MSC_CL_PULL.v_dgmt,
                   MSC_CL_PULL.v_refresh_id,
                   MSC_CL_PULL.v_instance_id,
                   MSC_CL_PULL.V_COLLECT_COMPLETED_JOBS;


END IF;

COMMIT;


END IF; -- CMRO Work Order Demand

END IF;    -- MSC_CL_PULL.WIP_ENABLED

END LOAD_WIP_DEMAND;


--  ====================== Discrete Job/ Flow Schedule SUPPLY ==================

   PROCEDURE LOAD_WIP_SUPPLY IS
   lv_lbj_details      NUMBER:=0;
   lv_op_seq_num       VARCHAR2(100) := null;
   lv_cond_sql         VARCHAR2(100) := null;
   lv_qty_sql_temp     VARCHAR2(300) :=null;
   lv_new_view_name    VARCHAR2(300) :=null;
   lv_new_org_string   VARCHAR2(32767) :=null;
   v_temp_sql          VARCHAR2(32767) :=null;
   v_temp_sql_stmt     VARCHAR2(32767) :=null;
   v_temp_sql2         VARCHAR2(32767) :=null;
   v_temp_sql_stmt2    VARCHAR2(32767) :=null;

   BEGIN

IF MSC_CL_PULL.WIP_ENABLED= MSC_UTIL.SYS_YES THEN

IF MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 THEN

select LBJ_DETAILS into lv_lbj_details from msc_apps_instances
                where instance_id = MSC_CL_PULL.v_instance_id ;
END IF;

IF MSC_CL_PULL.v_lrnn<> -1 THEN
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
    ||'                x.net_quantity) > 0'
    ||'                AND x.status_code <> 4' ;
END IF;

--=================== Net Change Mode: Delete ==================

IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh

  -- =================== JOB/FLOW SCHEDULE =====================
  IF ((MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS120) AND (MSC_UTIL.G_COLLECT_SRP_DATA='Y')) THEN
                                            -- Changed for Bug 6081537
      -- Supplies from Non Depot orgs

   MSC_CL_PULL.v_table_name:= 'MSC_ST_SUPPLIES';
   MSC_CL_PULL.v_view_name := 'MRP_AD_NON_ERO_WIP_JOB_SUP_V';

   v_sql_stmt:=
     'insert into MSC_ST_SUPPLIES'
     ||'  ( DISPOSITION_ID,'
     ||'    ORDER_TYPE,'
     ||'    DELETED_FLAG,'
     ||'    REFRESH_ID,'
     ||'    SR_INSTANCE_ID)'
     ||'  select'
     ||'    x.WIP_ENTITY_ID,'
     ||'    x.ORDER_TYPE,'
     ||'    1,'
     ||'    :v_refresh_id,'
     ||'    :v_instance_id'
     ||'  from MRP_AD_NON_ERO_WIP_JOB_SUP_V'||MSC_CL_PULL.v_dblink||' x'
     ||'  where DECODE( x.wip_job_type,'
     ||'                1, DECODE( :v_mps_consume_profile_value,'
     ||'                                    1, x.WJS_MPS_NET_QTY_FLAG,'
     ||'                                    x.WJS_NET_QTY_FLAG),'
     ||'                x.WJS_NET_QTY_FLAG)=1'
     ||'  AND x.RN> :v_lrn '
     ||'  AND x.ORGANIZATION_ID  '||MSC_UTIL.v_non_depot_org_str;

    -- Supplies from Depot repair orgs
   MSC_CL_PULL.v_table_name:= 'MSC_ST_SUPPLIES';
   MSC_CL_PULL.v_view_name := 'MRP_AD_NON_RO_WIP_JOB_SUPP_V';

   v_temp_sql2:=
     'insert into MSC_ST_SUPPLIES'
     ||'  ( DISPOSITION_ID,'
     ||'    ORDER_TYPE,'
     ||'    DELETED_FLAG,'
     ||'    REFRESH_ID,'
     ||'    SR_INSTANCE_ID)'
     ||'  select'
     ||'    x.WIP_ENTITY_ID,'
     ||'    x.ORDER_TYPE,'
     ||'    1,'
     ||'    :v_refresh_id,'
     ||'    :v_instance_id'
     ||'  from MRP_AD_NON_ERO_WIP_JOB_SUP_V'||MSC_CL_PULL.v_dblink||' x'
     ||'  where DECODE( x.wip_job_type,'
     ||'                1, DECODE( :v_mps_consume_profile_value,'
     ||'                                    1, x.WJS_MPS_NET_QTY_FLAG,'
     ||'                                    x.WJS_NET_QTY_FLAG),'
     ||'                x.WJS_NET_QTY_FLAG)=1'
     ||'  AND x.RN> :v_lrn '
     ||'  AND x.ORGANIZATION_ID  '||MSC_UTIL.v_depot_org_str;


    EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id,
                                   MSC_CL_PULL.v_instance_id,
                                   MSC_CL_PULL.v_mps_consume_profile_value,
                                   MSC_CL_PULL.v_lrn;

    MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Number of deleted rows for MRP_AD_NON_ERO_WIP_JOB_SUP_V = '|| SQL%ROWCOUNT);
    COMMIT;

    EXECUTE IMMEDIATE v_temp_sql2 USING MSC_CL_PULL.v_refresh_id,
                                   MSC_CL_PULL.v_instance_id,
                                   MSC_CL_PULL.v_mps_consume_profile_value,
                                   MSC_CL_PULL.v_lrn;

    MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Number of deleted rows for MRP_AD_NON_ERO_WIP_JOB_SUP_V = '|| SQL%ROWCOUNT);
    COMMIT;

  ELSE  -- (SRP Profile is No)

   MSC_CL_PULL.v_table_name:= 'MSC_ST_SUPPLIES';
   MSC_CL_PULL.v_view_name := 'MRP_AD_WIP_JOB_SUPPLIES_V';

   IF MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 THEN
   v_temp_sql := ' AND x.ORGANIZATION_ID '||MSC_UTIL.v_in_org_str;
   ELSE
   v_temp_sql := NULL;
   END IF;

   v_sql_stmt:=
     'insert into MSC_ST_SUPPLIES'
     ||'  ( DISPOSITION_ID,'
     ||'    ORDER_TYPE,'
     ||'    DELETED_FLAG,'
     ||'    REFRESH_ID,'
     ||'    SR_INSTANCE_ID)'
     ||'  select'
     ||'    x.WIP_ENTITY_ID,'
     ||'    x.ORDER_TYPE,'
     ||'    1,'
     ||'    :v_refresh_id,'
     ||'    :v_instance_id'
     ||'  from MRP_AD_WIP_JOB_SUPPLIES_V'||MSC_CL_PULL.v_dblink||' x'
     ||'  where DECODE( x.wip_job_type,'
     ||'                1, DECODE( :v_mps_consume_profile_value,'
     ||'                                    1, x.WJS_MPS_NET_QTY_FLAG,'
     ||'                                    x.WJS_NET_QTY_FLAG),'
     ||'                x.WJS_NET_QTY_FLAG)=1'
     ||'  AND x.RN> :v_lrn '
     || v_temp_sql;

    EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id,
                                   MSC_CL_PULL.v_instance_id,
                                   MSC_CL_PULL.v_mps_consume_profile_value,
                                   MSC_CL_PULL.v_lrn;

    MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Number of deleted rows for MRP_AD_WIP_JOB_SUPPLIES_V = '|| SQL%ROWCOUNT);
    COMMIT;
  END IF;
  -- =================== JOB COMPONENTS =====================

MSC_CL_PULL.v_table_name:= 'MSC_ST_SUPPLIES';
MSC_CL_PULL.v_view_name := 'MRP_AD_WIP_COMP_SUPPLIES_V';

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
'insert into MSC_ST_SUPPLIES'
||'  ( DISPOSITION_ID,'
||'    OPERATION_SEQ_NUM,'
||'    INVENTORY_ITEM_ID,'
||'    ORDER_TYPE,'
||'    DELETED_FLAG,'
||'    REFRESH_ID,'
||'    SR_INSTANCE_ID)'
||'  select'
||'    x.WIP_ENTITY_ID,'
||     lv_op_seq_num
||'    x.INVENTORY_ITEM_ID,'
||'    x.ORDER_TYPE,'
||'    1,'
||'    :v_refresh_id,'
||'    :v_instance_id'
||'  from MRP_AD_WIP_COMP_SUPPLIES_V'||MSC_CL_PULL.v_dblink||' x'
||'  where ( DECODE( :v_mps_consume_profile_value,'
||'                  1, x.WJS_MPS_NET_QTY_FLAG,'
||'                  x.WJS_NET_QTY_FLAG)=1'
||'       OR x.MRP_NET_FLAG= 1'
||'       OR DECODE( :v_mps_consume_profile_value,'
||'                  1, x.MPS_FLAG,'
||'                  x.NMPS_FLAG)= 1 )'
||'    AND x.RN> :v_lrn '
|| v_temp_sql;

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id,
                                   MSC_CL_PULL.v_instance_id,
                                   MSC_CL_PULL.v_mps_consume_profile_value,
                                   MSC_CL_PULL.v_mps_consume_profile_value,
                                   MSC_CL_PULL.v_lrn;

COMMIT;

  -- =================== REPT ITEM =====================

MSC_CL_PULL.v_table_name:= 'MSC_ST_SUPPLIES';
MSC_CL_PULL.v_view_name := 'MRP_AD_REPT_ITEM_SUPPLIES_V';

IF MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 THEN
   v_temp_sql := ' AND x.ORGANIZATION_ID '||MSC_UTIL.v_in_org_str;
ELSE
   v_temp_sql := NULL;
END IF;

v_sql_stmt:=
' insert into MSC_ST_SUPPLIES'
||'   ( DISPOSITION_ID,'
||'     ORDER_TYPE,'
||'     ORGANIZATION_ID,'
||'     DELETED_FLAG,'
||'     REFRESH_ID,'
||'     SR_INSTANCE_ID)'
||'  select'
||'     x.REPETITIVE_SCHEDULE_ID,'
||'     x.ORDER_TYPE,'
||'     x.ORGANIZATION_ID,'
||'     1,'
||'     :v_refresh_id,'
||'     :v_instance_id'
||'  from MRP_AD_REPT_ITEM_SUPPLIES_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.RN> :v_lrn '
|| v_temp_sql;

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id, MSC_CL_PULL.v_lrn;

COMMIT;

END IF;

MSC_CL_PULL.v_table_name:= 'MSC_ST_SUPPLIES';
MSC_CL_PULL.v_view_name := 'MRP_AP_WIP_JOB_SUPPLIES_V';


Begin
if MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 Then
   if lv_lbj_details = 1 Then
   v_temp_sql := ' x.routing_reference_id,x.bom_reference_id,x.coproducts_supply,x.jd_operation_seq_num,'||
	 'x.JUMP_OP_SEQ_NUM,x.JOB_OP_SEQ_NUM,  '||
	'x.requested_start_date,x.requested_completion_date,x.schedule_priority,x.asset_item_id,x.asset_serial_number,' ||/* ds change */
	'x.ACTUAL_START_DATE,x.cfm_routing_flag, '; /* Discrete Mfg Enahancements Bug 4479276 */
   else
   v_temp_sql := ' x.routing_reference_id,x.bom_reference_id,x.coproducts_supply,x.operation_seq_num , NULL, NULL, '||
	'x.requested_start_date,x.requested_completion_date,x.schedule_priority,x.asset_item_id,x.asset_serial_number,' || /* ds change */
	'x.ACTUAL_START_DATE,x.cfm_routing_flag, '; /* Discrete Mfg Enahancements Bug 4479276 */
   end if;
else
   v_temp_sql := ' NULL, NULL, NULL, NULL, NULL, NULL, '||
	'NULL, NULL, NULL, NULL, NULL, NULL,NULL, ';
end if;
End;

Begin

--Bug#3419189
IF MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 THEN

v_temp_sql1 := ' x.wip_start_quantity,';

ELSE
        v_temp_sql1 := ' NULL,';
END IF;
IF MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS121
THEN
v_temp_sql5 := 'x.maintenance_object_source,x.description,';
ELSE
v_temp_sql5 := 'NULL,NULL,';
END IF;

/*Select decode(MSC_CL_PULL.v_apps_ver,MSC_UTIL.G_APPS115,
	      ' DECODE( x.wip_job_type, 1,
			    DECODE( :v_mps_consume_profile_value,
				        1, x.mps_wip_start_quantity,
					   x.wip_start_quantity),
                            x.wip_start_quantity ), ',
              ' decode(:v_mps_consume_profile_value,1,NULL,null) ,')
into v_temp_sql1
from dual;*/
End;


IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh

v_union_sql :=
'   AND ( x.RN1 > :v_lrn )'
||' UNION '
||'  select'
||'    x.INVENTORY_ITEM_ID,'
||'    x.ORGANIZATION_ID,'
||'    x.WIP_ENTITY_ID,'
||'    x.WIP_ENTITY_NAME, '
||'    DECODE( x.wip_job_type, '
||'            1, DECODE( :v_mps_consume_profile_value,'
||'                                  1, decode(:lv_lbj_details,1,x.jd_mps_job_quantity,x.mps_job_quantity),'
||'                                  decode(:lv_lbj_details,1,x.jd_job_quantity,x.job_quantity)),'
||'            decode(:lv_lbj_details,1,x.jd_job_quantity,x.job_quantity)),'
||'    DECODE( x.wip_job_type,'
||'            1, DECODE( :v_mps_consume_profile_value,'
||'                                  1, x.mps_scheduled_completion_date,'
||'                                  x.scheduled_completion_date),'
||'            x.scheduled_completion_date)- :v_dgmt,'
||'    DECODE( x.wip_job_type,'
||'            1, DECODE( :v_mps_consume_profile_value,'
||'                                  1, x.mps_expected_scrap_quantity,'
||'                                  x.expected_scrap_quantity),'
||'            x.expected_scrap_quantity),'
||'    x.quantity_scrapped,'
||'    x.quantity_completed,'
||'    x.FIRM_PLANNED_STATUS_TYPE,'
||'    x.START_DATE- :v_dgmt,'
||'    x.REVISION,'
||'    x.ORDER_TYPE,'
||'    x.PROJECT_ID,'
||'    x.TASK_ID,'
||'    x.PLANNING_GROUP,'
||'    x.SCHEDULE_GROUP_ID,'
||'    x.BUILD_SEQUENCE,'
||'    x.LINE_ID,'
||'    x.ALTERNATE_BOM_DESIGNATOR,'
||'    x.ALTERNATE_ROUTING_DESIGNATOR,'
||'    x.END_ITEM_UNIT_NUMBER,'
||'    x.STATUS_CODE,'
||'    x.SCHEDULE_GROUP_NAME,'
||'    x.DEMAND_CLASS,'
||'    2,'
||     v_temp_sql
||     v_temp_sql1
||     v_temp_sql5
||'  :v_refresh_id,'
||'    :v_instance_id'
||'  from MRP_AP_WIP_JOB_SUPPLIES_V'||MSC_CL_PULL.v_dblink||' x'
||'  where x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
/*Bug#4704457 ||'    AND DECODE( x.wip_job_type,'
               ||' 1, DECODE( :v_mps_consume_profile_value,'
                             ||' 1, x.mps_net_quantity,'
                             ||' x.net_quantity),'
               ||' x.net_quantity) > 0' */
|| lv_qty_sql_temp
||'  AND (( x.RN2 > :v_lrn ) OR '
||'       (x.ENTITY_TYPE = 5 '
||'       AND EXISTS '
||'       (SELECT NULL '
||'        FROM MRP_SN_WOPRS'||MSC_CL_PULL.v_dblink||' y '
||'        WHERE '
||'        x.WIP_ENTITY_ID = y.WIP_ENTITY_ID*2 '
||'        AND x.ORGANIZATION_ID = y.ORGANIZATION_ID '
||'        AND y.RN > :v_lrn )))';

ELSE

v_union_sql := '     ';

END IF;




v_sql_stmt:=
'insert into MSC_ST_SUPPLIES'
||'  ( INVENTORY_ITEM_ID,'
||'    ORGANIZATION_ID,'
||'    DISPOSITION_ID,'
||'    ORDER_NUMBER,'
||'    NEW_ORDER_QUANTITY,'
||'    NEW_SCHEDULE_DATE,'
||'    EXPECTED_SCRAP_QTY,'
||'    QTY_SCRAPPED,'
||'    QTY_COMPLETED,'
||'    FIRM_PLANNED_TYPE,'
||'    NEW_WIP_START_DATE,'
||'    REVISION,'
||'    ORDER_TYPE,'
||'    PROJECT_ID,'
||'    TASK_ID,'
||'    PLANNING_GROUP,'
||'    SCHEDULE_GROUP_ID,'
||'    BUILD_SEQUENCE,'
||'    LINE_ID,'
||'    ALTERNATE_BOM_DESIGNATOR,'
||'    ALTERNATE_ROUTING_DESIGNATOR,'
||'    UNIT_NUMBER,'
||'    WIP_STATUS_CODE,'
||'    SCHEDULE_GROUP_NAME,'
||'    DEMAND_CLASS,'
||'    DELETED_FLAG,'
||'    ROUTING_SEQUENCE_ID,'
||'    BILL_SEQUENCE_ID,'
||'    COPRODUCTS_SUPPLY,'
||'    OPERATION_SEQ_NUM,'
||'    JUMP_OP_SEQ_NUM,'
||'    JOB_OP_SEQ_NUM,'
||'    REQUESTED_START_DATE,'  /* ds change start */
||'    REQUESTED_COMPLETION_DATE,'
||'    SCHEDULE_PRIORITY,'
||'    ASSET_ITEM_ID,'
||'    ASSET_SERIAL_NUMBER,'   /* ds change start */
||'    ACTUAL_START_DATE,'   /* Discrete Mfg Enahancements Bug 4479276 */
||'    CFM_ROUTING_FLAG,'
||'    WIP_START_QUANTITY,'
||'    MAINTENANCE_OBJECT_SOURCE,'
||'    DESCRIPTION,'
||'    REFRESH_ID,'
||'    SR_INSTANCE_ID)'
||'  select'
||'    x.INVENTORY_ITEM_ID,'
||'    x.ORGANIZATION_ID,'
||'    x.WIP_ENTITY_ID,'
||'    x.WIP_ENTITY_NAME, '
||'    DECODE( x.wip_job_type, '
||'            1, DECODE( :v_mps_consume_profile_value,'
||'                                  1, decode(:lv_lbj_details,1,x.jd_mps_job_quantity,x.mps_job_quantity),'
||'                                  decode(:lv_lbj_details,1,x.jd_job_quantity,x.job_quantity)),'
||'            decode(:lv_lbj_details,1,x.jd_job_quantity,x.job_quantity)),'
||'    DECODE( x.wip_job_type,'
||'            1, DECODE( :v_mps_consume_profile_value,'
||'                                  1, x.mps_scheduled_completion_date,'
||'                                  x.scheduled_completion_date),'
||'            x.scheduled_completion_date)- :v_dgmt,'
||'    DECODE( x.wip_job_type,'
||'            1, DECODE( :v_mps_consume_profile_value,'
||'                                  1, x.mps_expected_scrap_quantity,'
||'                                  x.expected_scrap_quantity),'
||'            x.expected_scrap_quantity),'
||'    x.quantity_scrapped,'
||'    x.quantity_completed,'
||'    x.FIRM_PLANNED_STATUS_TYPE,'
||'    x.START_DATE- :v_dgmt,'
||'    x.REVISION,'
||'    x.ORDER_TYPE,'
||'    x.PROJECT_ID,'
||'    x.TASK_ID,'
||'    x.PLANNING_GROUP,'
||'    x.SCHEDULE_GROUP_ID,'
||'    x.BUILD_SEQUENCE,'
||'    x.LINE_ID,'
||'    x.ALTERNATE_BOM_DESIGNATOR,'
||'    x.ALTERNATE_ROUTING_DESIGNATOR,'
||'    x.END_ITEM_UNIT_NUMBER,'
||'    x.STATUS_CODE,'
||'    x.SCHEDULE_GROUP_NAME,'
--||'    DECODE( x.DEMAND_CLASS,NULL,NULL,:V_ICODE||x.DEMAND_CLASS),'
||'    x.DEMAND_CLASS,'
||'    2,'
||     v_temp_sql
||     v_temp_sql1
||     v_temp_sql5
||'    :v_refresh_id,'
||'    :v_instance_id'
||'  from  ';

v_temp_sql2:=  v_sql_stmt;  -- Added For Bug 5935273
v_temp_sql :=  lv_qty_sql_temp|| v_union_sql;

if (MSC_UTIL.G_COLLECT_SRP_DATA='N' or MSC_CL_PULL.v_lrnn<> -1 or MSC_CL_PULL.v_apps_ver < MSC_UTIL.G_APPS120) Then    /* Build v_sql_stmt based on the MSC_SRP_ENABLED profile Bug 5909379 */

    MSC_CL_PULL.v_table_name:= 'MSC_ST_SUPPLIES';
    lv_new_view_name  := 'MRP_AP_WIP_JOB_SUPPLIES_V';
    lv_new_org_string := MSC_UTIL.v_in_org_str;

   v_temp_sql_stmt := v_sql_stmt||'  MRP_AP_WIP_JOB_SUPPLIES_V'||MSC_CL_PULL.v_dblink||'  x'||
                  '  where x.ORGANIZATION_ID  '||lv_new_org_string||'  '||v_temp_sql ;
    /* Changes For Bug 5909379 SRP Enhancements */

else              -- Profile MSC_UTIL.G_COLLECT_SRP_DATA = 'Y'
                  -- Repair Order Entities are No

    MSC_CL_PULL.v_table_name:= 'MSC_ST_SUPPLIES';
    MSC_CL_PULL.v_view_name:= 'MRP_AP_NON_ERO_WIP_JOB_SUPP_V';

    lv_new_view_name  := 'MRP_AP_NON_ERO_WIP_JOB_SUPP_V';
    lv_new_org_string := MSC_UTIL.v_non_depot_org_str;

   v_temp_sql_stmt := v_sql_stmt||'  MRP_AP_NON_ERO_WIP_JOB_SUPP_V'||MSC_CL_PULL.v_dblink||'  x'||
                  '  where x.ORGANIZATION_ID  '||lv_new_org_string||'  '||v_temp_sql ;


        ---- Code for SRP when Repair Orders Entity is/not selected . Building v_sql_stmt


end if;            /* End Profile MSC_UTIL.G_COLLECT_SRP_DATA 5909379 */


IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh
--MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'to be removed: Ds debug:  wip supply incr = '||v_sql_stmt);
  EXECUTE IMMEDIATE v_temp_sql_stmt USING MSC_CL_PULL.v_mps_consume_profile_value, lv_lbj_details, lv_lbj_details, lv_lbj_details,
                                     MSC_CL_PULL.v_mps_consume_profile_value, MSC_CL_PULL.v_dgmt,
                                     MSC_CL_PULL.v_mps_consume_profile_value,
                                     MSC_CL_PULL.v_dgmt,
                                     MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id,
                                     --MSC_CL_PULL.v_mps_consume_profile_value,
                                     MSC_CL_PULL.v_lrn,
                                     MSC_CL_PULL.v_mps_consume_profile_value, lv_lbj_details, lv_lbj_details, lv_lbj_details,
                                     MSC_CL_PULL.v_mps_consume_profile_value, MSC_CL_PULL.v_dgmt,
                                     MSC_CL_PULL.v_mps_consume_profile_value,
                                     MSC_CL_PULL.v_dgmt,
                                     MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id,
                                     --MSC_CL_PULL.v_mps_consume_profile_value,
                                     MSC_CL_PULL.v_lrn,
                                     MSC_CL_PULL.v_lrn;

ELSE   -- For COmplete Refresh

--MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'to be removed: Ds debug:  wip supply complete  = '||v_sql_stmt);


IF (MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS120 AND MSC_UTIL.G_COLLECT_SRP_DATA = 'Y') THEN




  EXECUTE IMMEDIATE v_temp_sql_stmt USING MSC_CL_PULL.v_mps_consume_profile_value, lv_lbj_details, lv_lbj_details, lv_lbj_details,
                                 MSC_CL_PULL.v_mps_consume_profile_value, MSC_CL_PULL.v_dgmt,
                                 MSC_CL_PULL.v_mps_consume_profile_value,
                                 MSC_CL_PULL.v_dgmt,
                                 MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id,
                                MSC_CL_PULL.v_mps_consume_profile_value;

   v_temp_sql_stmt := NULL;

               begin
                      MSC_CL_PULL.v_table_name      := 'MSC_ST_SUPPLIES';
                      lv_new_view_name  := 'MRP_AP_NON_RO_WIP_JOB_SUPPLY_V';
                      lv_new_org_string :=  MSC_UTIL.v_depot_org_str;

                      v_temp_sql_stmt := v_sql_stmt||'  MRP_AP_NON_RO_WIP_JOB_SUPPLY_V'||MSC_CL_PULL.v_dblink||'  x'||
                                    '  where x.ORGANIZATION_ID  '||lv_new_org_string ||'  '||v_temp_sql;



                      EXECUTE IMMEDIATE v_temp_sql_stmt USING MSC_CL_PULL.v_mps_consume_profile_value, lv_lbj_details, lv_lbj_details, lv_lbj_details,
                                 MSC_CL_PULL.v_mps_consume_profile_value, MSC_CL_PULL.v_dgmt,
                                 MSC_CL_PULL.v_mps_consume_profile_value,
                                 MSC_CL_PULL.v_dgmt,
                                 MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id,
                                 MSC_CL_PULL.v_mps_consume_profile_value;
                      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Number of rows for MRP_AP_NON_RO_WIP_JOB_SUPPLY_V = '|| SQL%ROWCOUNT);


               end ; ---- Code for SRP To get the work orders not attached to repair orders:


               /*  Code to get the wip job  supply from depo org when SRP enabled */


  ELSE   -- Instance is < 12i or MSC_SRP_ENABLED Profile is 'No'


    EXECUTE IMMEDIATE v_temp_sql_stmt USING MSC_CL_PULL.v_mps_consume_profile_value, lv_lbj_details, lv_lbj_details, lv_lbj_details,
                                 MSC_CL_PULL.v_mps_consume_profile_value, MSC_CL_PULL.v_dgmt,
                                 MSC_CL_PULL.v_mps_consume_profile_value,
                                 MSC_CL_PULL.v_dgmt,
                                 MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id,
                                 MSC_CL_PULL.v_mps_consume_profile_value;
  END IF;
  END IF;
    MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Number of rows for MRP_AP_WIP_JOB_SUPPLIES_V = '|| SQL%ROWCOUNT);
COMMIT;

MSC_CL_PULL.v_table_name:= 'MSC_ST_SUPPLIES';
MSC_CL_PULL.v_view_name := 'MRP_AP_WIP_COMP_SUPPLIES_V';

lv_op_seq_num := ' x.OPERATION_SEQ_NUM, ';

IF MSC_CL_PULL.v_apps_ver>= MSC_UTIL.G_APPS115 THEN
  v_temp_sql := ' x.quantity_per_assembly,x.quantity_issued, x.ACTUAL_START_DATE, ';

  if lv_lbj_details = 1 Then
   lv_op_seq_num := ' x.COPY_OP_SEQ_NUM, ';
   else
   lv_cond_sql := ' AND x.OPERATION_SEQ_NUM <> -1  ';
   end if;

ELSE
  v_temp_sql := ' NULL, NULL, NULL, ';
END IF;


IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh

v_union_sql :=
'   AND ( x.RN1 > :v_lrn )'
||' UNION '
||'  select'
||'    x.INVENTORY_ITEM_ID,'
||'    x.ORGANIZATION_ID,'
||'    x.WIP_ENTITY_ID,'
||'    x.WIP_ENTITY_NAME, '
||     lv_op_seq_num
||'    x.BY_PROD_QUANTITY,'        -- Bug fix
||'    x.ORDER_TYPE,'
||'    x.PROJECT_ID,'
||'    x.TASK_ID,'
||'    x.PLANNING_GROUP,'
||'    x.END_ITEM_UNIT_NUMBER,'
||'    DECODE( x.job_type, '
||'            1, NVL(x.mps_date_required, x.scheduled_start_date),'
||'             NVL(x.date_required, x.scheduled_start_date))- :v_dgmt,'
||'    2,'
||'    x.STATUS_CODE,'
||'    x.WIP_SUPPLY_TYPE,'
||'    x.SCHEDULE_GROUP_NAME,'
--||'    DECODE( x.DEMAND_CLASS,NULL,NULL,:V_ICODE||x.DEMAND_CLASS),'
||'    x.DEMAND_CLASS,'
||'    x.JOB_REFERENCE_ITEM_ID,'
||     v_temp_sql
||'    2,'
||'  :v_refresh_id,'
||'    :v_instance_id'
||'  from MRP_AP_WIP_COMP_SUPPLIES_V'||MSC_CL_PULL.v_dblink||' x'
||'  WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'   AND  x.BY_PROD_QUANTITY <> 0'
||    lv_cond_sql
--||'   AND DECODE(:V_COLLECT_COMPLETED_JOBS,'
--||'       2,x.coll_completed_qty_ind,'
--||'       1) >0'
||'   AND DECODE(:v_collect_completed_jobs,'
||'       2,x.status_code,'
||'       1) <>4'    -- 5730031
||'   AND ( x.RN2 > :v_lrn )'
||' UNION '
||'  select'
||'    x.INVENTORY_ITEM_ID,'
||'    x.ORGANIZATION_ID,'
||'    x.WIP_ENTITY_ID,'
||'    x.WIP_ENTITY_NAME, '
||     lv_op_seq_num
||'    x.BY_PROD_QUANTITY,'        -- Bug fix
||'    x.ORDER_TYPE,'
||'    x.PROJECT_ID,'
||'    x.TASK_ID,'
||'    x.PLANNING_GROUP,'
||'    x.END_ITEM_UNIT_NUMBER,'
||'    DECODE( x.job_type, '
||'            1, NVL(x.mps_date_required, x.scheduled_start_date),'
||'             NVL(x.date_required, x.scheduled_start_date))- :v_dgmt,'
||'    2,'
||'    x.STATUS_CODE,'
||'    x.WIP_SUPPLY_TYPE,'
||'    x.SCHEDULE_GROUP_NAME,'
--||'    DECODE( x.DEMAND_CLASS,NULL,NULL,:V_ICODE||x.DEMAND_CLASS),'
||'    x.DEMAND_CLASS,'
||'    x.JOB_REFERENCE_ITEM_ID,'
||     v_temp_sql
||'    2,'
||'  :v_refresh_id,'
||'    :v_instance_id'
||'  from MRP_AP_WIP_COMP_SUPPLIES_V'||MSC_CL_PULL.v_dblink||' x'
||'  WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'   AND  x.BY_PROD_QUANTITY <> 0'
||    lv_cond_sql
--||'   AND DECODE(:V_COLLECT_COMPLETED_JOBS,'
--||'       2,x.coll_completed_qty_ind,'
--||'       1) >0'
||'   AND DECODE(:v_collect_completed_jobs,'
||'       2,x.status_code,'
||'       1) <>4'    -- 5730031
||'   AND ( x.RN3 > :v_lrn )';

ELSE

v_union_sql := '     ';

END IF;



v_sql_stmt:=
' insert into MSC_ST_SUPPLIES'
||'  ( INVENTORY_ITEM_ID,'
||'    ORGANIZATION_ID,'
||'    DISPOSITION_ID,'
||'    ORDER_NUMBER,'
||'    OPERATION_SEQ_NUM,'
||'    NEW_ORDER_QUANTITY,'
||'    ORDER_TYPE,'
||'    PROJECT_ID,'
||'    TASK_ID,'
||'    PLANNING_GROUP,'
||'    UNIT_NUMBER,'
||'    NEW_SCHEDULE_DATE,'
||'    FIRM_PLANNED_TYPE,'
||'    WIP_STATUS_CODE,'
||'    WIP_SUPPLY_TYPE,'
||'    SCHEDULE_GROUP_NAME,'
||'    DEMAND_CLASS,'
||'    BY_PRODUCT_USING_ASSY_ID,'
||'    QUANTITY_PER_ASSEMBLY,'
||'    QUANTITY_ISSUED,'
||'    ACTUAL_START_DATE,'  /* Discrete Mfg Enahancements Bug 4479276 */
||'    DELETED_FLAG,'
||'    REFRESH_ID,'
||'    SR_INSTANCE_ID)'
||'  select'
||'    x.INVENTORY_ITEM_ID,'
||'    x.ORGANIZATION_ID,'
||'    x.WIP_ENTITY_ID,'
||'    x.WIP_ENTITY_NAME, '
||     lv_op_seq_num
||'    x.BY_PROD_QUANTITY,'        -- Bug fix
||'    x.ORDER_TYPE,'
||'    x.PROJECT_ID,'
||'    x.TASK_ID,'
||'    x.PLANNING_GROUP,'
||'    x.END_ITEM_UNIT_NUMBER,'
||'    DECODE( x.job_type, '
||'            1, NVL(x.mps_date_required, x.scheduled_start_date),'
||'             NVL(x.date_required, x.scheduled_start_date))- :v_dgmt,'
||'    2,'
||'    x.STATUS_CODE,'
||'    x.WIP_SUPPLY_TYPE,'
||'    x.SCHEDULE_GROUP_NAME,'
--||'    DECODE( x.DEMAND_CLASS,NULL,NULL,:V_ICODE||x.DEMAND_CLASS),'
||'    x.DEMAND_CLASS,'
||'    x.JOB_REFERENCE_ITEM_ID,'
||     v_temp_sql
||'    2,'
||'  :v_refresh_id,'
||'    :v_instance_id'
||'  from MRP_AP_WIP_COMP_SUPPLIES_V'||MSC_CL_PULL.v_dblink||' x'
||'  WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'   AND  x.BY_PROD_QUANTITY <> 0'
||    lv_cond_sql
--||'   AND DECODE(:V_COLLECT_COMPLETED_JOBS,'
--||'       2,x.coll_completed_qty_ind,'
--||'       1) >0'
||'   AND DECODE(:v_collect_completed_jobs,'
||'       2,x.status_code,'
||'       1) <>4'    -- 5730031
|| v_union_sql;

IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh

  EXECUTE IMMEDIATE v_sql_stmt
              USING MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id, MSC_CL_PULL.V_COLLECT_COMPLETED_JOBS, MSC_CL_PULL.v_lrn,
                    MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id, MSC_CL_PULL.V_COLLECT_COMPLETED_JOBS, MSC_CL_PULL.v_lrn,
                    MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id, MSC_CL_PULL.V_COLLECT_COMPLETED_JOBS, MSC_CL_PULL.v_lrn;

ELSE

  EXECUTE IMMEDIATE v_sql_stmt
              USING MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id, MSC_CL_PULL.V_COLLECT_COMPLETED_JOBS;

END IF;



COMMIT;


-- ====================== 5. LOAD LOT JOB DETAILS =====================
BEGIN

--If lv_lbj_details = 1 Then

IF MSC_CL_PULL.v_lrn <> -1  then /*incremental refresh*/

IF MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 THEN
   v_temp_sql := ' AND x.ORGANIZATION_ID '||MSC_UTIL.v_in_org_str;
ELSE
   v_temp_sql := NULL;
END IF;

MSC_CL_PULL.v_table_name:= 'MSC_ST_JOB_OPERATION_NETWORKS';
MSC_CL_PULL.v_view_name := 'MRP_AD_JOB_OP_NETWORKS_V';

v_sql_stmt:=
'insert into MSC_ST_JOB_OPERATION_NETWORKS'
||'  ( WIP_ENTITY_ID,'
||'    FROM_OP_SEQ_NUM,'
||'    TO_OP_SEQ_NUM,'
||'    DELETED_FLAG,'
||'    REFRESH_ID,'
||'    SR_INSTANCE_ID)'
||'  select'
||'    x.WIP_ENTITY_ID,'
||'    x.FROM_OP_SEQ_NUM,'
||'    x.TO_OP_SEQ_NUM,'
||'    1,'
||'    :v_refresh_id,'
||'    :v_instance_id'
||'  from MRP_AD_JOB_OP_NETWORKS_V'||MSC_CL_PULL.v_dblink||' x'
||'  where x.RN> '||MSC_CL_PULL.v_lrn
||'   AND DECODE( x.from_op_seq_num,'
||'               NULL, DECODE( :v_mps_consume_profile_value,'
||'                                        1, x.WJS_MPS_NET_QTY_FLAG,'
||'                                        x.WJS_NET_QTY_FLAG), '
||'               1)= 1'
|| v_temp_sql;

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id,
                                   MSC_CL_PULL.v_instance_id,
                                   MSC_CL_PULL.v_mps_consume_profile_value;

    MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Number of rows deleted MRP_AD_JOB_OP_NETWORKS_V = '|| SQL%ROWCOUNT);
COMMIT;


IF (MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS120) THEN  --bug#5684183 (bcaru)
/* ds change start */
    MSC_CL_PULL.v_table_name:= 'MSC_ST_JOB_OPERATION_NETWORKS';
    MSC_CL_PULL.v_view_name := 'MRP_AD_WOPR_NETWORKS_V';

    v_sql_stmt:=
    'insert into MSC_ST_JOB_OPERATION_NETWORKS'
    ||'  ( WIP_ENTITY_ID,'
    ||'    FROM_OP_SEQ_NUM,'
    ||'    TO_OP_SEQ_NUM,'
    ||'    DELETED_FLAG,'
    ||'    REFRESH_ID,'
    ||'    SR_INSTANCE_ID)'
    ||'  select'
    ||'    x.WIP_ENTITY_ID,'
    ||'    x.FROM_OP_SEQ_NUM,'
    ||'    x.TO_OP_SEQ_NUM,'
    ||'    1,'
    ||'    :v_refresh_id,'
    ||'    :v_instance_id'
    ||'  from MRP_AD_WOPR_NETWORKS_V'||MSC_CL_PULL.v_dblink||' x'
    ||'  where x.RN> '||MSC_CL_PULL.v_lrn;

    --MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Ds debug:  ad job network  = '||v_sql_stmt);
    EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id,
                                       MSC_CL_PULL.v_instance_id;

        MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Number of rows deleted MRP_AD_WOPR_NETWORKS = '|| SQL%ROWCOUNT);
    COMMIT;

    MSC_CL_PULL.v_table_name:= 'MSC_ST_JOB_OPERATION_NETWORKS';
    MSC_CL_PULL.v_view_name := 'MRP_AD_EAM_WO_RELSHIPS_V';

    v_sql_stmt:=
    'insert into MSC_ST_JOB_OPERATION_NETWORKS'
    ||'  ( WIP_ENTITY_ID,'
    ||'    TO_WIP_ENTITY_ID,'
    --||'    RELATIONSHIP_TYPE,'
    ||'    DELETED_FLAG,'
    ||'    REFRESH_ID,'
    ||'    SR_INSTANCE_ID)'
    ||'  select'
    ||'    x.WIP_ENTITY_ID,'
    ||'    x.TO_WIP_ENTITY_ID,'
    --||'    x.RELATIONSHIP_TYPE,'
    ||'    1,'
    ||'    :v_refresh_id,'
    ||'    :v_instance_id'
    ||'  from MRP_AD_EAM_WO_RELSHIPS_V'||MSC_CL_PULL.v_dblink||' x'
    ||'  where x.RN> '||MSC_CL_PULL.v_lrn;

        --MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Ds debug: ad job network  = '||v_sql_stmt);
    EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id,
                                       MSC_CL_PULL.v_instance_id;

        MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Number of rows deleted MRP_AD_EAM_WO_RELSHIPS_V = '|| SQL%ROWCOUNT);
    -- opm populate job operation network in call
    -- to

    COMMIT;
/* ds change end */
END IF;  --v_apps_ver >= MSC_UTIL.G_APPS120


MSC_CL_PULL.v_table_name:= 'MSC_ST_JOB_OPERATIONS';
MSC_CL_PULL.v_view_name := 'MRP_AD_JOB_OPERATIONS_V';

v_sql_stmt:=
'insert into MSC_ST_JOB_OPERATIONS'
||'  ( WIP_ENTITY_ID,'
||'    OPERATION_SEQ_NUM,'
||'    DELETED_FLAG,'
||'    REFRESH_ID,'
||'    SR_INSTANCE_ID)'
||'  select'
||'    x.WIP_ENTITY_ID,'
||'    x.OPERATION_SEQ_NUM,'
||'    1,'
||'    :v_refresh_id,'
||'    :v_instance_id'
||'  from MRP_AD_JOB_OPERATIONS_V'||MSC_CL_PULL.v_dblink||' x'
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

    MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Number of rows deleted MRP_AD_JOB_OPERATIONS_V = '|| SQL%ROWCOUNT);
COMMIT;


MSC_CL_PULL.v_table_name:= 'MSC_ST_JOB_REQUIREMENT_OPS';
MSC_CL_PULL.v_view_name := 'MRP_AD_REQUIREMENT_OPS_V';

v_sql_stmt:=
'insert into MSC_ST_JOB_REQUIREMENT_OPS'
||'  ( WIP_ENTITY_ID,'
||'    OPERATION_SEQ_NUM,'
||'    COMPONENT_ITEM_ID,'
||'    PRIMARY_COMPONENT_ID,'
||'    SOURCE_PHANTOM_ID,'
||'    DELETED_FLAG,'
||'    REFRESH_ID,'
||'    SR_INSTANCE_ID)'
||'  select'
||'    x.WIP_ENTITY_ID,'
||'    x.OPERATION_SEQ_NUM,'
||'    x.COMPONENT_ITEM_ID,'
||'    x.PRIMARY_COMPONENT_ID,'
||'    x.SOURCE_PHANTOM_ID,'
||'    1,'
||'    :v_refresh_id,'
||'    :v_instance_id'
||'  from MRP_AD_REQUIREMENT_OPS_V'||MSC_CL_PULL.v_dblink||' x'
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

    MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Number of rows deleted MRP_AD_REQUIREMENT_OPS_V = '|| SQL%ROWCOUNT);
COMMIT;

MSC_CL_PULL.v_table_name:= 'MSC_ST_JOB_OP_RESOURCES';
MSC_CL_PULL.v_view_name := 'MRP_AD_JOB_OP_RESOURCES_V';

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
||'  from MRP_AD_JOB_OP_RESOURCES_V'||MSC_CL_PULL.v_dblink||' x'
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
MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Number of rows deleted MRP_AD_JOB_OP_RESOURCES_V = '|| SQL%ROWCOUNT);
COMMIT;

MSC_CL_PULL.v_table_name:= 'MSC_ST_JOB_OP_RESOURCES';
MSC_CL_PULL.v_view_name := 'MRP_AD_LJ_SUB_OP_RESOURCES_V';

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
||'  from MRP_AD_LJ_SUB_OP_RESOURCES_V'||MSC_CL_PULL.v_dblink||' x'
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

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Number of rows deleted MRP_AD_LJ_SUB_OP_RESOURCES_V = '|| SQL%ROWCOUNT);
COMMIT;

END IF; /*incremental refresh */

MSC_CL_PULL.v_table_name := 'MSC_ST_JOB_OPERATION_NETWORKS';
MSC_CL_PULL.v_view_name := 'MRP_AP_JOB_OP_NETWORKS_V';

v_sql_stmt:=
'insert into MSC_ST_JOB_OPERATION_NETWORKS'
||'   (WIP_ENTITY_ID,'
||'    SR_INSTANCE_ID,'
||'    ORGANIZATION_ID,'
||'    FROM_OP_SEQ_NUM,'
||'    TO_OP_SEQ_NUM,'
||'    FROM_OP_SEQ_ID,'
||'    TO_OP_SEQ_ID ,'
||'    RECOMMENDED,'
||'    TRANSITION_TYPE ,'
||'    PLANNING_PCT,'
||'    ROUTING_SEQUENCE_ID,'
||'    DEPENDENCY_TYPE,'     /* ds change start */
||'    TO_WIP_ENTITY_ID,'
||'    TOP_WIP_ENTITY_ID,'  /* ds change end */
||'    DELETED_FLAG,'
||'    REFRESH_ID )'
||'    select '
||'    x.WIP_ENTITY_ID,'
||'    :v_instnace_id,'
||'    x.ORGANIZATION_ID,'
||'    x.FROM_OP_SEQ_NUM,'
||'    x.TO_OP_SEQ_NUM,'
||'    x.FROM_OP_SEQ_ID,'
||'    x.TO_OP_SEQ_ID,'
||'    x.RECOMMENDED,'
||'    x.TRANSITION_TYPE,'
||'    x.PLANNING_PCT,'
||'    x.ROUTING_SEQUENCE_ID,'
||'    x.DEPENDENCY_TYPE,'   /* ds change start */
||'    x.TO_WIP_ENTITY_ID,'
||'    x.TOP_WIP_ENTITY_ID,'  /*ds change end */
||'    2,'
||'    :v_refresh_id'
||'    FROM MRP_AP_JOB_OP_NETWORKS_V '||MSC_CL_PULL.v_dblink||' x '
||'    WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'    AND (x.RN >' ||MSC_CL_PULL.v_lrn
||'    OR x.RN1 >' ||MSC_CL_PULL.v_lrn
||'    OR x.RN2>' ||MSC_CL_PULL.v_lrn ||' )';

    --MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Ds debug: ap job network  = '||v_sql_stmt);
EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_instance_id, MSC_CL_PULL.v_refresh_id;
MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Number of rows for MRP_AP_JOB_OP_NETWORKS_V = '|| SQL%ROWCOUNT);

COMMIT;

MSC_CL_PULL.v_table_name := 'MSC_ST_JOB_OPERATIONS';
MSC_CL_PULL.v_view_name := 'MRP_AP_JOB_OPERATIONS_V';

v_sql_stmt:=
'insert into MSC_ST_JOB_OPERATIONS'
||'   (WIP_ENTITY_ID,'
||'    SR_INSTANCE_ID,'
||'    ORGANIZATION_ID,'
||'    OPERATION_SEQ_NUM,'
||'    RECOMMENDED,'
||'    RECO_START_DATE,'
||'    RECO_COMPLETION_DATE,'
||'    OPERATION_SEQUENCE_ID,'
||'    STANDARD_OPERATION_CODE,'
||'    NETWORK_START_END,'
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
||'    DELETED_FLAG,'
||'    REFRESH_ID )'
||'    select '
||'    x.WIP_ENTITY_ID,'
||'    :v_instance_id,'
||'    x.ORGANIZATION_ID,'
||'    x.OPERATION_SEQ_NUM,'
||'    x.RECOMMENDED,'
||'    x.RECO_START_DATE - :v_dgmt,'
||'    x.RECO_COMPLETION_DATE - :v_dgmt,'
||'    x.OPERATION_SEQUENCE_ID,'
||'    x.STANDARD_OPERATION_CODE,'
||'    x.NETWORK_START_END,'
||'    x.DEPARTMENT_ID,'
||'    x.OPERATION_LEAD_TIME_PERCENT,'
||'    x.MINIMUM_TRANSFER_QUANTITY,'
||'    x.EFFECTIVITY_DATE - :v_dgmt,'
||'    x.DISABLE_DATE - :v_dgmt,'
||'    x.OPERATION_TYPE,'
||'    x.YIELD,'
||'    x.CUMULATIVE_YIELD,'
||'    x.REVERSE_CUMULATIVE_YIELD,'
||'    x.NET_PLANNING_PERCENT,'
||'    2,'
||'    :v_refresh_id'
||'    FROM MRP_AP_JOB_OPERATIONS_V'||MSC_CL_PULL.v_dblink||' x'
||'    WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'    AND (x.RN >' ||MSC_CL_PULL.v_lrn
||'    OR x.RN1 >' ||MSC_CL_PULL.v_lrn
||'    OR x.RN2>' ||MSC_CL_PULL.v_lrn ||' )';

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_instance_id, MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_refresh_id;
MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Number of rows for MRP_AP_JOB_OPERATIONS_V = '|| SQL%ROWCOUNT);

COMMIT;

MSC_CL_PULL.v_table_name := 'MSC_ST_JOB_REQUIREMENT_OPS';
MSC_CL_PULL.v_view_name := 'MRP_AP_JOB_REQUIREMENT_OPS_V';

IF MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115 THEN
   v_temp_sql1 := ' x.BASIS_TYPE, ';
ELSE
   v_temp_sql1 := ' NULL, ';
END IF;

v_sql_stmt:=
'insert into MSC_ST_JOB_REQUIREMENT_OPS'
||'   (WIP_ENTITY_ID,'
||'    SR_INSTANCE_ID,'
||'    ORGANIZATION_ID,'
||'    OPERATION_SEQ_NUM,'
||'    COMPONENT_ITEM_ID,'
||'    WIP_SUPPLY_TYPE,'
||'    PRIMARY_COMPONENT_ID,'
||'    SOURCE_PHANTOM_ID,'
||'    RECOMMENDED,'
||'    RECO_DATE_REQUIRED,'
||'    COMPONENT_SEQUENCE_ID,'
||'    COMPONENT_PRIORITY,'
||'    DEPARTMENT_ID,'
||'    QUANTITY_PER_ASSEMBLY,'
||'    COMPONENT_YIELD_FACTOR,'
||'    EFFECTIVITY_DATE,'
||'    DISABLE_DATE,'
||'    PLANNING_FACTOR,'
||'    LOW_QUANTITY,'
||'    HIGH_QUANTITY,'
||'    OPERATION_LEAD_TIME_PERCENT,'
||'    FROM_END_ITEM_UNIT_NUMBER,'
||'    TO_END_ITEM_UNIT_NUMBER,'
||'    COMPONENT_SCALING_TYPE,'
||'    DELETED_FLAG,'
||'    REFRESH_ID )'
||'    select '
||'    x.WIP_ENTITY_ID,'
||'    :v_instance_id,'
||'    x.ORGANIZATION_ID,'
||'    x.OPERATION_SEQ_NUM,'
||'    x.COMPONENT_ITEM_ID,'
||'    x.WIP_SUPPLY_TYPE,'
||'    x.PRIMARY_COMPONENT_ID,'
||'    x.SOURCE_PHANTOM_ID,'
||'    x.RECOMMENDED,'
||'    x.RECO_DATE_REQUIRED - :v_dgmt,'
||'    x.COMPONENT_SEQUENCE_ID,'
||'    x.COMPONENT_PRIORITY,'
||'    x.DEPARTMENT_ID,'
||'    x.QUANTITY_PER_ASSEMBLY,'
||'    x.COMPONENT_YIELD_FACTOR,'
||'    x.EFFECTIVITY_DATE - :v_dgmt,'
||'    x.DISABLE_DATE - :v_dgmt,'
||'    x.PLANNING_FACTOR,'
||'    x.LOW_QUANTITY,'
||'    x.HIGH_QUANTITY,'
||'    x.OPERATION_LEAD_TIME_PERCENT,'
||'    x.FROM_END_ITEM_UNIT_NUMBER,'
||'    x.TO_END_ITEM_UNIT_NUMBER,'
||     v_temp_sql1
||'    2,'
||'    :v_refresh_id'
||'    FROM MRP_AP_JOB_REQUIREMENT_OPS_V'||MSC_CL_PULL.v_dblink||' x'
||'    WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'    AND (x.RN >' ||MSC_CL_PULL.v_lrn
||'    OR x.RN1>' ||MSC_CL_PULL.v_lrn
||'    OR x.RN2>' ||MSC_CL_PULL.v_lrn || ' )';

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_instance_id, MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_refresh_id;
MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Number of rows for MRP_AP_JOB_REQUIREMENT_OPS_V = '|| SQL%ROWCOUNT);

COMMIT;


MSC_CL_PULL.v_table_name := 'MSC_ST_JOB_OP_RESOURCES';
MSC_CL_PULL.v_view_name := 'MRP_AP_JOB_OP_RESOURCES_V';

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
||'    GROUP_SEQUENCE_ID,'	 /* ds change start */
||'    GROUP_SEQUENCE_NUMBER,'
||'    BATCH_NUMBER,'
||'    FIRM_FLAG,'
||'    SETUP_ID,'
||'    PARENT_SEQ_NUM,'
||'    MAXIMUM_ASSIGNED_UNITS,'	 /* ds change end */
||'    DELETED_FLAG,'
||'    REFRESH_ID )'
||'    select '
||'    x.WIP_ENTITY_ID,'
||'    :v_instance_id,'
||'    x.ORGANIZATION_ID,'
||'    x.OPERATION_SEQ_NUM,'
||'    x.RESOURCE_SEQ_NUM,'
||'    x.ALTERNATE_NUM,'
||'    x.RECOMMENDED,'
||'    x.RECO_START_DATE - :v_dgmt,'
||'    x.RECO_COMPLETION_DATE - :v_dgmt,'
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
||'    x.GROUP_SEQUENCE_ID,'
||'    x.GROUP_SEQUENCE_NUMBER,'
||'    x.BATCH_NUMBER,'
||'    x.FIRM_FLAG,'
||'    x.SETUP_ID,'
||'    x.PARENT_RESOURCE_SEQ,'
||'    x.MAXIMUM_ASSIGNED_UNITS,'
||'    2,'
||'    :v_refresh_id'
||'    FROM MRP_AP_JOB_OP_RESOURCES_V'||MSC_CL_PULL.v_dblink||' x'
||'    WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'    AND (x.RN >' ||MSC_CL_PULL.v_lrn
||'    OR x.RN1>' ||MSC_CL_PULL.v_lrn
||'    OR x.RN2>' ||MSC_CL_PULL.v_lrn ||' )';

    --MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'to be removed: Ds debug: ap job op resources  = '||v_sql_stmt);
EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_instance_id, MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_refresh_id;
MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Number of rows for MRP_AP_JOB_OP_RESOURCES_V = '|| SQL%ROWCOUNT);

COMMIT;

MSC_CL_PULL.v_table_name := 'MSC_ST_JOB_OP_RESOURCES';
MSC_CL_PULL.v_view_name := 'MRP_AP_LJ_SUB_OP_RESOURCES_V';


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
||'    SETUP_ID,'    /* ds change */
||'    DELETED_FLAG,'
||'    REFRESH_ID )'
||'    select '
||'    x.WIP_ENTITY_ID,'
||'    :v_instance_id,'
||'    x.ORGANIZATION_ID,'
||'    x.copy_op_seq_num,'
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
||'    x.SETUP_ID,'	/* ds change */
||'    2,'
||'    :v_refresh_id'
||'    FROM MRP_AP_LJ_SUB_OP_RESOURCES_V'||MSC_CL_PULL.v_dblink||' x'
||'    WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'    AND (x.RN1>' || MSC_CL_PULL.v_lrn
||'    OR x.RN2>' ||MSC_CL_PULL.v_lrn
||'    OR x.RN3>' || MSC_CL_PULL.v_lrn || ' )';

EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_instance_id, MSC_CL_PULL.v_refresh_id;
MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Number of rows for MRP_AP_LJ_SUB_OP_RESOURCES_V = '|| SQL%ROWCOUNT);

COMMIT;


--END IF;

END;

--  ====================== 6: Repetitive Schedule ====================

MSC_CL_PULL.v_table_name:= 'MSC_ST_SUPPLIES';
MSC_CL_PULL.v_view_name := 'MRP_AP_REPT_ITEM_SUPPLIES_V';

IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh

v_union_sql :=
'   AND ( x.RN1 > :v_lrn )'
||' UNION '
||'  select'
||'     x.PRIMARY_ITEM_ID,'
||'     x.ORGANIZATION_ID,'
||'     x.REPETITIVE_SCHEDULE_ID,'
||'     x.WIP_ENTITY_NAME, '
||'     x.LINE_ID,'
||'     x.FIRST_UNIT_COMPLETION_DATE- :v_dgmt,'
||'     x.FIRST_UNIT_START_DATE- :v_dgmt,'
||'     x.FIRST_UNIT_COMPLETION_DATE- :v_dgmt,'
||'     x.LAST_UNIT_START_DATE- :v_dgmt,'
||'     x.LAST_UNIT_COMPLETION_DATE- :v_dgmt,'
||'     x.PROCESSING_WORK_DAYS,'
||'     x.DAILY_PRODUCTION_RATE,'
||'     x.DAILY_PRODUCTION_RATE,'
||'     x.STATUS_CODE,'
||'     x.FIRM_PLANNED_FLAG,'
||'     x.QUANTITY_COMPLETED,'
||'     x.QUANTITY_SCRAPPED,'
--||'     DECODE( x.DEMAND_CLASS,NULL,NULL,:V_ICODE||x.DEMAND_CLASS),'
||'    x.DEMAND_CLASS,'
||'     30,'
||'     2,'
||'     :v_refresh_id,'
||'     :v_instance_id'
||'  from MRP_AP_REPT_ITEM_SUPPLIES_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'   AND (x.RN2 > :v_lrn)'
||' UNION '
||'  select'
||'     x.PRIMARY_ITEM_ID,'
||'     x.ORGANIZATION_ID,'
||'     x.REPETITIVE_SCHEDULE_ID,'
||'    x.WIP_ENTITY_NAME, '
||'     x.LINE_ID,'
||'     x.FIRST_UNIT_COMPLETION_DATE- :v_dgmt,'
||'     x.FIRST_UNIT_START_DATE- :v_dgmt,'
||'     x.FIRST_UNIT_COMPLETION_DATE- :v_dgmt,'
||'     x.LAST_UNIT_START_DATE- :v_dgmt,'
||'     x.LAST_UNIT_COMPLETION_DATE- :v_dgmt,'
||'     x.PROCESSING_WORK_DAYS,'
||'     x.DAILY_PRODUCTION_RATE,'
||'     x.DAILY_PRODUCTION_RATE,'
||'     x.STATUS_CODE,'
||'     x.FIRM_PLANNED_FLAG,'
||'     x.QUANTITY_COMPLETED,'
||'     x.QUANTITY_SCRAPPED,'
--||'     DECODE( x.DEMAND_CLASS,NULL,NULL,:V_ICODE||x.DEMAND_CLASS),'
||'    x.DEMAND_CLASS,'
||'     30,'
||'     2,'
||'     :v_refresh_id,'
||'     :v_instance_id'
||'  from MRP_AP_REPT_ITEM_SUPPLIES_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'   AND (x.RN3 > :v_lrn)'
||' UNION '
||'  select'
||'     x.PRIMARY_ITEM_ID,'
||'     x.ORGANIZATION_ID,'
||'     x.REPETITIVE_SCHEDULE_ID,'
||'     x.WIP_ENTITY_NAME, '
||'     x.LINE_ID,'
||'     x.FIRST_UNIT_COMPLETION_DATE- :v_dgmt,'
||'     x.FIRST_UNIT_START_DATE- :v_dgmt,'
||'     x.FIRST_UNIT_COMPLETION_DATE- :v_dgmt,'
||'     x.LAST_UNIT_START_DATE- :v_dgmt,'
||'     x.LAST_UNIT_COMPLETION_DATE- :v_dgmt,'
||'     x.PROCESSING_WORK_DAYS,'
||'     x.DAILY_PRODUCTION_RATE,'
||'     x.DAILY_PRODUCTION_RATE,'
||'     x.STATUS_CODE,'
||'     x.FIRM_PLANNED_FLAG,'
||'     x.QUANTITY_COMPLETED,'
||'     x.QUANTITY_SCRAPPED,'
--||'     DECODE( x.DEMAND_CLASS,NULL,NULL,:V_ICODE||x.DEMAND_CLASS),'
||'    x.DEMAND_CLASS,'
||'     30,'
||'     2,'
||'     :v_refresh_id,'
||'     :v_instance_id'
||'  from MRP_AP_REPT_ITEM_SUPPLIES_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
||'   AND (x.RN4 > :v_lrn)';

ELSE

v_union_sql := '     ';

END IF;


v_sql_stmt:=
' insert into MSC_ST_SUPPLIES'
||'   ( INVENTORY_ITEM_ID,'
||'     ORGANIZATION_ID,'
||'     DISPOSITION_ID,'
||'     ORDER_NUMBER,'
||'     LINE_ID,'
||'     NEW_SCHEDULE_DATE,'
||'     FIRST_UNIT_START_DATE,'
||'     FIRST_UNIT_COMPLETION_DATE,'
||'     LAST_UNIT_START_DATE,'
||'     LAST_UNIT_COMPLETION_DATE,'
||'     NEW_PROCESSING_DAYS,'
||'     DAILY_RATE,'
||'     NEW_ORDER_QUANTITY,'
||'     WIP_STATUS_CODE,'
||'     FIRM_PLANNED_TYPE,'
||'     QTY_COMPLETED,'
||'     QTY_SCRAPPED,'
||'     DEMAND_CLASS,'
||'     ORDER_TYPE,'
||'     DELETED_FLAG,'
||'     REFRESH_ID,'
||'     SR_INSTANCE_ID)'
||'  select'
||'     x.PRIMARY_ITEM_ID,'
||'     x.ORGANIZATION_ID,'
||'     x.REPETITIVE_SCHEDULE_ID,'
||'     x.WIP_ENTITY_NAME, '
||'     x.LINE_ID,'
||'     x.FIRST_UNIT_COMPLETION_DATE- :v_dgmt,'
||'     x.FIRST_UNIT_START_DATE- :v_dgmt,'
||'     x.FIRST_UNIT_COMPLETION_DATE- :v_dgmt,'
||'     x.LAST_UNIT_START_DATE- :v_dgmt,'
||'     x.LAST_UNIT_COMPLETION_DATE- :v_dgmt,'
||'     x.PROCESSING_WORK_DAYS,'
||'     x.DAILY_PRODUCTION_RATE,'
||'     x.DAILY_PRODUCTION_RATE,'
||'     x.STATUS_CODE,'
||'     x.FIRM_PLANNED_FLAG,'
||'     x.QUANTITY_COMPLETED,'
||'     x.QUANTITY_SCRAPPED,'
--||'     DECODE( x.DEMAND_CLASS,NULL,NULL,:V_ICODE||x.DEMAND_CLASS),'
||'    x.DEMAND_CLASS,'
||'     30,'
||'     2,'
||'     :v_refresh_id,'
||'     :v_instance_id'
||'  from MRP_AP_REPT_ITEM_SUPPLIES_V'||MSC_CL_PULL.v_dblink||' x'
||' WHERE x.ORGANIZATION_ID'||MSC_UTIL.v_in_org_str
|| v_union_sql;

IF MSC_CL_PULL.v_lrnn<> -1 THEN     -- incremental refresh

 EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt,
                                    MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id, MSC_CL_PULL.v_lrn,
                                    MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt,
                                    MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id, MSC_CL_PULL.v_lrn,
                                    MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt,
                                    MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id, MSC_CL_PULL.v_lrn,
                                    MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt,
                                    MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id, MSC_CL_PULL.v_lrn;

ELSE

 EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt, MSC_CL_PULL.v_dgmt,
                                    MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id;
END IF;

COMMIT;

END IF;   -- MSC_CL_PULL.WIP_ENABLED;

END LOAD_WIP_SUPPLY;


END MSC_CL_WIP_PULL;

/
