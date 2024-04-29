--------------------------------------------------------
--  DDL for Package Body MSC_CL_RPO_PULL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_CL_RPO_PULL" AS -- body
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
--       NULL_DBLINK      CONSTANT  VARCHAR2(1) :=MSC_UTIL.NULL_DBLINK;

   v_item_type_id   NUMBER := MSC_UTIL.G_PARTCONDN_ITEMTYPEID;
   v_item_type_good NUMBER := MSC_UTIL.G_PARTCONDN_GOOD;
   v_item_type_bad  NUMBER := MSC_UTIL.G_PARTCONDN_BAD;


PROCEDURE LOAD_IRO  IS
BEGIN

  MSC_CL_PULL.v_table_name:= 'MSC_ST_SUPPLIES';
  MSC_CL_PULL.v_view_name := 'MRP_AP_REPAIR_ORDERS_V';

  IF  MSC_CL_PULL.v_lrnn<> -1 THEN  -- incremental refresh  for bug 6126698
    v_temp_sql1 := '  AND ((x.LAST_UPDATE_DATE > :g_last_succ_rio_time) OR (x.item_rn  > '||MSC_CL_PULL.v_lrnn ||'))';

  ELSE
    v_temp_sql1 := ' AND x.RO_STATUS_CODE <> '||'''C''';

  END IF;
    MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, ' MSC_CL_PULL.g_last_succ_iro_ref_time:'||to_char(MSC_CL_PULL.g_last_succ_iro_ref_time,'DD-MON-YYYY hh:mi:ss'));
v_sql_stmt := ' INSERT INTO MSC_ST_SUPPLIES '
         		  ||' ( DISPOSITION_ID,  '
		          ||'    ORDER_TYPE, '
		          ||' 	 ORDER_NUMBER, '
		          ||'    DELETED_FLAG,'
		          ||' 	 INVENTORY_ITEM_ID, '
		          ||'    ORGANIZATION_ID, '
		          ||' 	 PROMISED_DATE, '
		          ||' 	 NEW_ORDER_QUANTITY, '
		          ||' 	 UOM_CODE, '
		          ||' 	 CUSTOMER_PRODUCT_ID, '
		          ||' 	 SR_REPAIR_TYPE_ID, '
		          ||' 	 PROJECT_ID, '
		          ||' 	 TASK_ID, '
		          ||' 	 RO_STATUS_CODE, '
		          ||' 	 ASSET_SERIAL_NUMBER, '
		          ||' 	 REVISION, '
		          ||' 	 SR_REPAIR_GROUP_ID, '
		          ||' 	 SCHEDULE_PRIORITY, '
		          ||' 	 NEW_SCHEDULE_DATE,'
		          ||' 	 RO_CREATION_DATE,'
		          ||' 	 REPAIR_LEAD_TIME,'
		          ||'    FIRM_PLANNED_TYPE,'
		          ||'    ITEM_TYPE_ID, '
		          ||'    ITEM_TYPE_VALUE,'
		          ||'	   REFRESH_ID,  '
		          ||'    SR_INSTANCE_ID  )'
		          ||' select  '
		          ||' 	 x.REPAIR_LINE_ID, '
		          ||' 	 75, ' 	-- new order type for repair order supply
 	  	        ||' 	 x.REPAIR_NUMBER, '
		          ||' 	 decode(x.RO_STATUS_CODE,''C'' ,1,2), '
		          ||' 	 x.INVENTORY_ITEM_ID, '
		          ||' 	 x.ORGANIZATION_ID, '
		          ||' 	 x.PROMISE_DATE, '
		          ||' 	 x.START_QUANTITY, '
		          ||' 	 x.UNIT_OF_MEASURE, '
		          ||' 	 x.CUSTOMER_PRODUCT_ID, '
		          ||' 	 x.SR_REPAIR_TYPE_ID, '
		          ||' 	 x.PROJECT_ID, '
		          ||' 	 x.TASK_ID, '
		          ||' 	 x.RO_STATUS_CODE, '
		          ||' 	 x.SERIAL_NUMBER, '
		          ||' 	 x.REVISION, '
		          ||' 	 x.SR_REPAIR_GROUP_ID, '
		          ||' 	 x.SCHEDULE_PRIORITY, '
		          ||' 	 x.PROMISE_DATE,'
		          ||' 	 x.CREATION_DATE,'
		          ||' 	 x.REPAIR_LEADTIME,'
		          ||'    2,'
  		        ||'    :v_item_type_id ,'
  		        ||'    :v_item_type_good ,'
		          ||'    :v_refresh_id ,'
		          ||'    :v_instance_id'
		          ||' from  MRP_AP_REPAIR_ORDERS_V'||MSC_CL_PULL.v_dblink ||'  x'
		          ||'  where x.organization_id  '||MSC_UTIL.v_depot_org_str
		          ||  v_temp_sql1
;



IF (MSC_UTIL.G_COLLECT_SRP_DATA='Y' AND MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS120) THEN


       IF  MSC_CL_PULL.v_lrnn<> -1 THEN
          Execute Immediate v_sql_stmt using v_item_type_id,v_item_type_good,MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id ,MSC_CL_PULL.g_last_succ_iro_ref_time;
       ELSE
          Execute Immediate v_sql_stmt using v_item_type_id,v_item_type_good,MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id ;
       END IF;


END IF;
COMMIT;
END LOAD_IRO ;
/* End of Procedure Load_IRO To collect Repair order from Depo orgs. Bug 5909379 */

PROCEDURE LOAD_IRO_DEMAND    IS
BEGIN

  MSC_CL_PULL.v_table_name:= 'MSC_ST_DEMANDS';
  MSC_CL_PULL.v_view_name := 'MRP_AP_REPAIR_DEMAND_V';


  IF  ((MSC_CL_PULL.v_lrnn<> -1) AND (MSC_UTIL.G_COLLECT_SRP_DATA='Y')) THEN  -- incremental refresh  for bug 6126698

    v_temp_sql1:= ' AND ((x.date1>:g_last_succ_iro_ref_time) OR (x.date2> :g_last_succ_iro_ref_time) OR (x.RN1>'
                                      || MSC_CL_PULL.v_lrnn               ||
                 ') OR (x.RN2>'       || MSC_CL_PULL.v_lrnn               ||
	               ') OR (x.RN3>'       || MSC_CL_PULL.v_lrnn               ||
                 ')) ' ;

  ELSE
    v_temp_sql1 := ' AND x.RO_STATUS_CODE <> '||'''C''';

  END IF;

v_sql_stmt := ' INSERT INTO MSC_ST_DEMANDS '
           		          ||' ( '
           		          ||' repair_line_id,  '
           		          ||' using_assembly_item_id,  '
           		          ||' organization_id,  '
           		          ||' using_assembly_demand_date,  '
           		          ||' wip_entity_id ,'
           		          ||' inventory_item_id,  '
           		          ||' USING_REQUIREMENT_QUANTITY,  '
           		          ||' QUANTITY_ISSUED,  '
           		          ||' DEMAND_TYPE,  '
           		          ||' PROJECT_ID,  '
           		          ||' TASK_ID,  '
           		          ||' DEMAND_CLASS,  '
           		          ||' ORIGINATION_TYPE,  '
           		          ||' DELETED_FLAG, '
           		          ||' quantity_per_assembly,  '
                        ||' component_scaling_type, '
                        ||' component_yield_factor, '
                        ||' operation_seq_num, '
      			            ||' ITEM_TYPE_ID, '
		                    ||' ITEM_TYPE_VALUE,'
		                    ||' refresh_id ,'
		                    ||' sr_instance_id '
                        ||' ) '
		                    ||' select  '
           		          ||' repair_line_id,  '
           		          ||' ro_inventory_item_id,  '
           		          ||' repair_org_id,  '
           		          ||' using_assembly_demand_date,  '
           		          ||' wip_entity_id , '
           		          ||' inventory_item_id,  '
           		          ||' new_required_quantity,  '
           		          ||' quantity_issued,  '
           		          ||' demand_type,  '
           		          ||' task_id,  '
           		          ||' planning_group,  '
           		          ||' demand_class,  '
           		          ||' origination_type,  '
           		          ||' decode(x.RO_STATUS_CODE,''C'' ,1,2), '
                        ||' quantity_per_assembly,  '
                        ||' basis_type, '
                        ||' component_yield_factor, '
                        ||' operation_seq_num, '
     		                ||' :v_item_type_id, '
                        ||' :v_item_type_good,'
                        ||' :v_refresh_id ,'
                        ||' :v_instance_id'
		                    || ' from  MRP_AP_REPAIR_DEMAND_V'|| MSC_CL_PULL.v_dblink ||'  x'
		                    || ' where x.organization_id  '||MSC_UTIL.v_depot_org_str
		                    || v_temp_sql1
  	;

IF (MSC_UTIL.G_COLLECT_SRP_DATA='Y' AND MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS120) THEN


    IF  ((MSC_CL_PULL.v_lrnn<> -1) AND (MSC_UTIL.G_COLLECT_SRP_DATA='Y')) THEN
     Execute Immediate v_sql_stmt using v_item_type_id,v_item_type_good,MSC_CL_PULL.v_refresh_id,
          MSC_CL_PULL.v_instance_id,MSC_CL_PULL.g_last_succ_iro_ref_time,MSC_CL_PULL.g_last_succ_iro_ref_time ;
    ELSE
      Execute Immediate v_sql_stmt using v_item_type_id,v_item_type_good,MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id ;
    END IF;


END IF;

COMMIT;

  IF  ((MSC_CL_PULL.v_lrnn<> -1) AND (MSC_UTIL.G_COLLECT_SRP_DATA='Y'))  THEN  -- incremental refresh  for bug 6126698
  BEGIN
      v_temp_sql:=
      'insert into MSC_ST_DEMANDS'
      ||'  ( REPAIR_LINE_ID,'
      ||'    INVENTORY_ITEM_ID,'
      ||'    ORGANIZATION_ID,'
      ||'    WIP_ENTITY_ID,'
      ||'    DELETED_FLAG,'
      ||'    ORIGINATION_TYPE,'
      ||'    REFRESH_ID,'
      ||'    SR_INSTANCE_ID)'
      ||'  select'
      ||'    x.REPAIR_LINE_ID,'
      ||'    x.INVENTORY_ITEM_ID,'
      ||'    x.ORGANIZATION_ID,'
      ||'    x.WIP_ENTITY_ID,'
      ||'    1,'
      ||'    77,'
      ||'    :v_refresh_id,'
      ||'    :v_instance_id'
      ||'  from MRP_AD_RO_WIP_COMP_DEMANDS_V'||MSC_CL_PULL.v_dblink||'  x'
      ||'  Where x. date1 > :g_last_succ_iro_ref_time  or  x.date2 > :g_last_succ_iro_ref_time
                   or  x.RN1  > ' ||MSC_CL_PULL.v_lrnn ;


      Execute Immediate v_temp_sql using
                                         MSC_CL_PULL.v_refresh_id,
                                         MSC_CL_PULL.v_instance_id,
                                         MSC_CL_PULL.g_last_succ_iro_ref_time,
                                         MSC_CL_PULL.g_last_succ_iro_ref_time ;

      EXCEPTION
       WHEN OTHERS THEN
             MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, ' LOAD_IRO_DEMAND ');
             MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
             RAISE;
   END;
 END IF;  -- incremental refresh
COMMIT;


END LOAD_IRO_DEMAND;
/* -- End of Procedure LOAD_IRO_DEMAND To collect the demand for the wip job attached to repair order. Bug 5909379 */

PROCEDURE LOAD_ERO  IS
   lv_lbj_details      NUMBER:=0;
BEGIN

If  MSC_CL_PULL.v_lrnn<> -1 THEN  /*incremental refresh */
v_sql_stmt:=
     'insert into MSC_ST_SUPPLIES'
     ||'  ( DISPOSITION_ID,'
     ||'    ORDER_TYPE,'
     ||'    ORGANIZATION_ID,'
     ||'    DELETED_FLAG,'
     ||'    REFRESH_ID,'
     ||'    SR_INSTANCE_ID)'
     ||'  select'
     ||'    x.WIP_ENTITY_ID,'
     ||'    86,'
     ||'    x.organization_id,'
     ||'    1,'
     ||'    :v_refresh_id,'
     ||'    :v_instance_id'
     ||'  from MRP_AD_ERO_WIP_JOB_SUPP_V'||MSC_CL_PULL.v_dblink||' x'
     ||'  where x.RN> :v_lrn '
     ||' AND organization_id '||MSC_UTIL.v_non_depot_org_str;



   IF (MSC_UTIL.G_COLLECT_SRP_DATA='Y' AND MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS120) THEN

   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, v_sql_stmt);
   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, MSC_CL_PULL.v_instance_id);
   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, MSC_CL_PULL.v_lrnn);


    EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id,
                                  MSC_CL_PULL.v_lrnn;

   END IF;

END IF ; --  net change

select LBJ_DETAILS into lv_lbj_details from msc_apps_instances
                where instance_id = MSC_CL_PULL.v_instance_id ;


  MSC_CL_PULL.v_table_name:= 'MSC_ST_SUPPLIES';
  MSC_CL_PULL.v_view_name := 'MRP_AP_ERO_WIP_JOB_SUPPLY_V';

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
||'    REQUESTED_START_DATE,'
||'    REQUESTED_COMPLETION_DATE,'
||'    SCHEDULE_PRIORITY,'
||'    ASSET_ITEM_ID,'
||'    ASSET_SERIAL_NUMBER,'
||'    ACTUAL_START_DATE,'
||'    CFM_ROUTING_FLAG,'
||'    WIP_START_QUANTITY,'
||'    ITEM_TYPE_ID,'
||'    ITEM_TYPE_VALUE,'
||'    REFRESH_ID,'
||'    SR_INSTANCE_ID)'
||'  select'
||'    x.INVENTORY_ITEM_ID,'
||'    x.ORGANIZATION_ID,'
||'    x.WIP_ENTITY_ID,'
||'    x.WIP_ENTITY_NAME, '
||'    x.NEW_ORDER_QUANTITY ,'
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
||'    86,'
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
||'    x.routing_reference_id,x.bom_reference_id,x.coproducts_supply,x.jd_operation_seq_num,'
||'    x.JUMP_OP_SEQ_NUM,x.JOB_OP_SEQ_NUM,  '
||'    x.requested_start_date,x.requested_completion_date,x.schedule_priority,x.asset_item_id,x.asset_serial_number,'
||'    x.ACTUAL_START_DATE,x.cfm_routing_flag, '
||'    x.wip_start_quantity,'
||'    :v_item_type_id,'
||'    :v_item_type_good,'
||'    :v_refresh_id,'
||'    :v_instance_id'
||'    from  MRP_AP_ERO_WIP_JOB_SUPPLY_V'||MSC_CL_PULL.v_dblink ||'  x'
		          ||'  where x.organization_id  '||MSC_UTIL.v_non_depot_org_str
		          || ' AND (x.RN1 > :v_lrn or x.RN2 > :v_lrn or x.RN3 >:v_lrn)'
;




IF (MSC_UTIL.G_COLLECT_SRP_DATA='Y' AND MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS120) THEN
Execute Immediate v_sql_stmt
 using
  MSC_CL_PULL.v_mps_consume_profile_value,
  MSC_CL_PULL.v_dgmt,
  MSC_CL_PULL.v_mps_consume_profile_value,
  MSC_CL_PULL.v_dgmt,
  v_item_type_id,
  v_item_type_good,
  MSC_CL_PULL.v_refresh_id,
  MSC_CL_PULL.v_instance_id ,
  MSC_CL_PULL.v_lrnn,
  MSC_CL_PULL.v_lrnn,
  MSC_CL_PULL.v_lrnn;

END IF;


COMMIT;
END LOAD_ERO ;
/* End of Procedure Load_ERO To collect Repair order from Depo orgs. Bug 5935273 */

PROCEDURE LOAD_ERO_DEMAND    IS
BEGIN

If   MSC_CL_PULL.v_lrnn<> -1  then /*incremental refresh */
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
    ||'    x.WIP_ID,'
    ||'    x.OPERATION_SEQ_NUM,'
    ||'    x.INVENTORY_ITEM_ID,'
    ||'    x.ORGANIZATION_ID,'
    ||'    x.ORIGINATION_TYPE,'
    ||'    1,'
    ||'    :v_refresh_id,'
    ||'    :v_instance_id'
    ||'  from MRP_AD_ERO_WIP_COMP_DEM_V'||MSC_CL_PULL.v_dblink||' x'
    ||'  where x.RN> :v_lrn '
    ||' AND organization_id  '||MSC_UTIL.v_non_depot_org_str;

   IF (MSC_UTIL.G_COLLECT_SRP_DATA='Y' AND MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS120) THEN

    EXECUTE IMMEDIATE v_sql_stmt USING MSC_CL_PULL.v_refresh_id, MSC_CL_PULL.v_instance_id,
                                 MSC_CL_PULL.v_lrnn;
   END IF;

END IF;   -- Netchange

  MSC_CL_PULL.v_table_name:= 'MSC_ST_DEMANDS';
  MSC_CL_PULL.v_view_name := 'MRP_AP_ERO_WIP_DEMAND_V';

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
||'    ASSET_ITEM_ID,'
||'    ASSET_SERIAL_NUMBER,'
||'    COMPONENT_SCALING_TYPE,'
||'    COMPONENT_YIELD_FACTOR,'
||'    ITEM_TYPE_ID,'
||'    ITEM_TYPE_VALUE,'
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
||'    x.COPY_OP_SEQ_NUM,'
||'    x.NEW_REQUIRED_QUANTITY,'
||'    x.QUANTITY_ISSUED,'
||'    x.JOB_REFERENCE_ITEM_ID,'
||'    x.DEMAND_TYPE,'
||'    x.PROJECT_ID,'
||'    x.TASK_ID,'
||'    x.PLANNING_GROUP,'
||'    x.END_ITEM_UNIT_NUMBER,'
||'    x.DEMAND_CLASS,'
||'    77,'
||'    x.DATE_REQUIRED- :v_dgmt,'
||'    x.MPS_DATE_REQUIRED- :v_dgmt,'
||'    2,'
||'    x.quantity_per_assembly,x.asset_item_id,x.asset_serial_number,x.basis_type,x.component_yield_factor, '
||'    :v_item_type_id,'
||'    :v_item_type_good,'
||'    :v_refresh_id,'
||'    :v_instance_id'
|| '  from  MRP_AP_ERO_WIP_DEMAND_V'||MSC_CL_PULL.v_dblink ||'  x'
|| '  where x.organization_id  '||MSC_UTIL.v_non_depot_org_str
|| '  AND (x.RN1 > :v_lrn or x.RN2 > :v_lrn or x.RN3 >:v_lrn)'
;


IF (MSC_UTIL.G_COLLECT_SRP_DATA='Y' AND MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS120) THEN
Execute Immediate v_sql_stmt using
MSC_CL_PULL.v_dgmt,
MSC_CL_PULL.v_dgmt,
v_item_type_id,
v_item_type_good,
MSC_CL_PULL.v_refresh_id,
MSC_CL_PULL.v_instance_id,
MSC_CL_PULL.v_lrnn,
MSC_CL_PULL.v_lrnn,
MSC_CL_PULL.v_lrnn;

END IF;



COMMIT;
END LOAD_ERO_DEMAND;
/* -- End of Procedure LOAD_ERO_DEMAND To collect the demand for the wip job attached to repair order. Bug 5935273 */


END MSC_CL_RPO_PULL;

/
