--------------------------------------------------------
--  DDL for Package Body MSC_CL_SUPPLY_ODS_LOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_CL_SUPPLY_ODS_LOAD" AS -- body
/*$Header: MSCLSUPB.pls 120.14.12010000.5 2010/03/24 23:10:32 harshsha ship $*/
--	 G_JOB_DONE                      NUMBER := MSC_CL_COLLECTION.G_JOB_DONE;
--   G_JOB_NOT_DONE                  NUMBER := MSC_CL_COLLECTION.G_JOB_NOT_DONE;
--   G_JOB_ERROR                     NUMBER := MSC_CL_COLLECTION.G_JOB_ERROR;
--   G_MRP_PO_ACK										 NUMBER := MSC_CL_COLLECTION.G_MRP_PO_ACK;
--   SYS_YES Number:=  MSC_CL_COLLECTION.SYS_YES ;
--   SYS_NO Number:=  MSC_CL_COLLECTION.SYS_NO ;
--   PROMISED_DATE_PREF     NUMBER := MSC_CL_COLLECTION.PROMISED_DATE_PREF;
--   NEED_BY_DATE_PREF       NUMBER := MSC_CL_COLLECTION.PROMISED_DATE_PREF;
--   G_ALL_ORGANIZATIONS    VARCHAR2(6):= MSC_CL_COLLECTION.G_ALL_ORGANIZATIONS;
--   SYS_INCR Number:=MSC_CL_COLLECTION.SYS_INCR;
--   SYS_TGT Number:=MSC_CL_COLLECTION.SYS_TGT;
--   NULL_VALUE            NUMBER:= MSC_UTIL.NULL_VALUE;
--   NULL_CHAR             VARCHAR2(6):=MSC_UTIL.NULL_CHAR;
--   G_CONF_APS_SCE		  NUMBER :=MSC_CL_COLLECTION.G_CONF_APS_SCE;
--   G_CONF_SCE		  NUMBER :=MSC_CL_COLLECTION.G_CONF_SCE;

		FUNCTION  IS_SUPPLIES_LOAD_DONE
		RETURN boolean
		IS
		lv_is_job_done   NUMBER;
		lv_process_time  NUMBER;
		BEGIN

		/* This function will return only when the Loading of Supplies is done or error out
		  so that  other procedures (Demand-WIP Demand - Sales orders - Resource Reqmnts) can start loading */

		    LOOP

		     select nvl(SUPPLIES_LOAD_FLAG,MSC_CL_COLLECTION.G_JOB_NOT_DONE)
			  into   lv_is_job_done
			  from   msc_apps_instances
			  where  instance_id = MSC_CL_COLLECTION.v_instance_id;

		           select (SYSDATE- MSC_CL_COLLECTION.START_TIME) into lv_process_time from dual;

		            IF lv_process_time > MSC_CL_COLLECTION.p_TIMEOUT/1440.0 THEN
								lv_is_job_done := MSC_CL_COLLECTION.G_JOB_ERROR;
		            END IF;

			     EXIT WHEN (lv_is_job_done = MSC_CL_COLLECTION.G_JOB_DONE) OR (lv_is_job_done= MSC_CL_COLLECTION.G_JOB_ERROR);
		    END LOOP;

		    IF (lv_is_job_done = MSC_CL_COLLECTION.G_JOB_DONE) THEN
			RETURN TRUE;
		    ELSIF  (lv_is_job_done = MSC_CL_COLLECTION.G_JOB_ERROR) THEN
			RETURN FALSE;
		    END IF;

		RETURN TRUE;

		EXCEPTION
		   WHEN OTHERS THEN
		     MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
		     MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Failure to get the Status of Supplies Load .');
		     RETURN FALSE;

		END  IS_SUPPLIES_LOAD_DONE;

		FUNCTION  create_supplies_tmp_ind
		RETURN  boolean
		IS
		    lv_retval boolean;
		    lv_dummy1 varchar2(32);
		    lv_dummy2 varchar2(32);

		BEGIN

		    lv_retval := FND_INSTALLATION.GET_APP_INFO ( 'FND', lv_dummy1, lv_dummy2, MSC_CL_COLLECTION.v_applsys_schema);

		               ad_ddl.do_ddl( applsys_schema => MSC_CL_COLLECTION.v_applsys_schema,
		                              application_short_name => 'MSC',
		                              statement_type => AD_DDL.CREATE_INDEX,
		                              statement =>
		                              'create index supplies_nx_'||MSC_CL_COLLECTION.v_instance_code
		                              ||' on '||'supplies_'||MSC_CL_COLLECTION.v_instance_code
		                              ||'(disposition_id, order_type) '
					      ||' PARALLEL  ' || MSC_CL_COLLECTION.G_DEG_PARALLEL
		                              ||' STORAGE (INITIAL 100K NEXT 1M PCTINCREASE 0) ',
		                              object_name => 'supplies_nx_'||MSC_CL_COLLECTION.v_instance_code);

		    MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, ' Index SUPPLIES_NX_'||MSC_CL_COLLECTION.v_instance_code||' created.');

		               ad_ddl.do_ddl( applsys_schema => MSC_CL_COLLECTION.v_applsys_schema,
		                              application_short_name => 'MSC',
		                              statement_type => AD_DDL.CREATE_INDEX,
		                              statement =>
		                              'create index supplies_nx1_'||MSC_CL_COLLECTION.v_instance_code
		                              ||' on '||'supplies_'||MSC_CL_COLLECTION.v_instance_code
		                              ||'(plan_id, sr_instance_id, order_number, purch_line_num) '
					      ||' PARALLEL  ' || MSC_CL_COLLECTION.G_DEG_PARALLEL
		                              ||' STORAGE (INITIAL 100K NEXT 1M PCTINCREASE 0) ',
		                              object_name => 'supplies_nx1_'||MSC_CL_COLLECTION.v_instance_code);

		    MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, ' Index SUPPLIES_NX1_'||MSC_CL_COLLECTION.v_instance_code||' created.');

		               ad_ddl.do_ddl( applsys_schema => MSC_CL_COLLECTION.v_applsys_schema,
		                              application_short_name => 'MSC',
		                              statement_type => AD_DDL.CREATE_INDEX,
		                              statement =>
		                              'create index supplies_nx2_'||MSC_CL_COLLECTION.v_instance_code
		                              ||' on '||'supplies_'||MSC_CL_COLLECTION.v_instance_code
		                              ||'(plan_id, sr_instance_id, disposition_id, po_line_id ) '
					      ||' PARALLEL  ' || MSC_CL_COLLECTION.G_DEG_PARALLEL
		                              ||' STORAGE (INITIAL 100K NEXT 1M PCTINCREASE 0) ',
		                              object_name => 'supplies_nx2_'||MSC_CL_COLLECTION.v_instance_code);
		    MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, ' Index SUPPLIES_NX2_'||MSC_CL_COLLECTION.v_instance_code||' created.');

		      RETURN TRUE;

		EXCEPTION
		   WHEN OTHERS THEN
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
			  update msc_apps_instances
			     set SUPPLIES_LOAD_FLAG = MSC_CL_COLLECTION.G_JOB_ERROR
			  where  instance_id = MSC_CL_COLLECTION.v_instance_id;
			  commit;
		      RETURN FALSE;
		END create_supplies_tmp_ind;

		FUNCTION  drop_supplies_tmp_ind
		RETURN boolean
		IS
		   lv_temp_sql_stmt   VARCHAR2(2000);
		   lv_ind_name        VARCHAR2(30);
		   lv_drop_index      NUMBER;

		   lv_retval boolean;
		   lv_dummy1 varchar2(32);
		   lv_dummy2 varchar2(32);

		   lv_msc_schema varchar2(32);

		BEGIN

		 lv_retval := FND_INSTALLATION.GET_APP_INFO('FND', lv_dummy1, lv_dummy2
					   , MSC_CL_COLLECTION.v_applsys_schema);

		 lv_retval := FND_INSTALLATION.GET_APP_INFO ('MSC', lv_dummy1, lv_dummy2,lv_msc_schema);

		      lv_temp_sql_stmt := ' SELECT 1  '
				        ||' from all_indexes '
				        ||'  where owner =  :p_schema '
				        ||'  and table_owner = :p_schema '
				        ||'  and index_name = upper(:ind_name) ' ;

		      lv_ind_name := 'SUPPLIES_NX_'||MSC_CL_COLLECTION.v_instance_code;

		      EXECUTE IMMEDIATE lv_temp_sql_stmt
				   INTO lv_drop_index
		                  USING  lv_msc_schema,lv_msc_schema,lv_ind_name;

		      IF (lv_drop_index = 1) THEN

		              MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Dropping the index :'||lv_ind_name);
		               ad_ddl.do_ddl( applsys_schema => MSC_CL_COLLECTION.v_applsys_schema,
		                              application_short_name => 'MSC',
		                              statement_type => AD_DDL.DROP_INDEX,
		                              statement =>
		                              'drop index supplies_nx_'||MSC_CL_COLLECTION.v_instance_code,
		                              object_name => 'supplies_nx_'||MSC_CL_COLLECTION.v_instance_code);
			       MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Dropped the index :'||lv_ind_name);

			      lv_drop_index := 2;
		      END IF;

		      lv_ind_name := 'SUPPLIES_NX1_'||MSC_CL_COLLECTION.v_instance_code;

		              EXECUTE IMMEDIATE lv_temp_sql_stmt
					   INTO lv_drop_index
		                  USING  lv_msc_schema,lv_msc_schema,lv_ind_name;

		      IF (lv_drop_index = 1) THEN
			       MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Dropping the index :'||lv_ind_name);
		               ad_ddl.do_ddl( applsys_schema => MSC_CL_COLLECTION.v_applsys_schema,
		                              application_short_name => 'MSC',
		                              statement_type => AD_DDL.DROP_INDEX,
		                              statement =>
		                              'drop index supplies_nx1_'||MSC_CL_COLLECTION.v_instance_code,
		                              object_name => 'supplies_nx1_'||MSC_CL_COLLECTION.v_instance_code);

			       MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Dropped the index :'||lv_ind_name);
			      lv_drop_index :=2 ;
		      END IF;

			       lv_ind_name := 'SUPPLIES_NX2_'||MSC_CL_COLLECTION.v_instance_code;

		              EXECUTE IMMEDIATE lv_temp_sql_stmt
					   INTO lv_drop_index
		                  USING  lv_msc_schema,lv_msc_schema,lv_ind_name;

		      IF (lv_drop_index = 1) THEN
			       MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Dropping the index :'||lv_ind_name);
		               ad_ddl.do_ddl( applsys_schema => MSC_CL_COLLECTION.v_applsys_schema,
		                              application_short_name => 'MSC',
		                              statement_type => AD_DDL.DROP_INDEX,
		                              statement =>
		                              'drop index supplies_nx2_'||MSC_CL_COLLECTION.v_instance_code,
		                              object_name => 'supplies_nx2_'||MSC_CL_COLLECTION.v_instance_code);
			       MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Dropped the index :'||lv_ind_name);
			      lv_drop_index := 2;
		      END IF;

		     RETURN true;
		  EXCEPTION
		       WHEN NO_DATA_FOUND THEN
		            RETURN true;

		       WHEN OTHERS THEN
		            MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
		            RETURN FALSE;
		END drop_supplies_tmp_ind;

--==================================================================

		PROCEDURE LOAD_SUPPLY IS

		   c_count        NUMBER:=0;
		   lv_tbl         VARCHAR2(30);
		   lv_sql_stmt    VARCHAR2(32767);
		   lv_sql_stmt1   VARCHAR2(32767);
		   lv_cal_code    VARCHAR2(30);
		   lv_cal_code_omc    VARCHAR2(30);
		   lv_dock_date   DATE;
		   lv_schedule_date DATE;
		   lv_org_id     NUMBER:=0;

		   TYPE NumTab  IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
		   TYPE RIDTab  IS TABLE OF ROWID  INDEX BY BINARY_INTEGER;

		   lv_transaction_id      NumTab;
		   lv_rowid               RIDTab;

		   /* CP-ACK starts */
		   lv_po_dock_date_ref NUMBER;
		   lv_time_component number ;
		   lv_ITEM_TYPE_VALUE            NUMBER;
		   lv_ITEM_TYPE_ID               NUMBER;


		   Cursor c1 IS
		SELECT
		  x.TRANSACTION_ID,
		  x.SR_MTL_SUPPLY_ID,
		  t1.INVENTORY_ITEM_ID,
		  x.ORGANIZATION_ID,
		  x.FROM_ORGANIZATION_ID,
		  x.SR_INSTANCE_ID,
		  x.REVISION,
		  x.UNIT_NUMBER,
		  -- bug 2773881 - Use either PROMISED_DATE or NEED_BY_DATE; always call date_offset
		  /*decode(x.ORDER_TYPE, 1,
		             nvl(MSC_CALENDAR.DATE_OFFSET(x.ORGANIZATION_ID,
		                                      x.SR_INSTANCE_ID,
		                                      TYPE_DAILY_BUCKET,
		                                      (MSC_CALENDAR.NEXT_WORK_DAY
		                                           (x.ORGANIZATION_ID,
		                                           x.SR_INSTANCE_ID,
		                                           1,
		                                           decode(lv_po_dock_date_ref,
		                                                      PROMISED_DATE_PREF, nvl(x.PROMISED_DATE, x.NEED_BY_DATE),
		                                                      NEED_BY_DATE_PREF , nvl(x.NEED_BY_DATE, x.PROMISED_DATE)))),
		                                       nvl(x.POSTPROCESSING_LEAD_TIME,0)
		                                       ), x.new_schedule_date),
		         x.NEW_SCHEDULE_DATE ) NEW_SCHEDULE_DATE ,*/
		/*
		  decode(x.ORDER_TYPE, 1,
		             decode(lv_po_dock_date_ref,
		                        PROMISED_DATE_PREF , x.NEW_SCHEDULE_DATE,
		                        NEED_BY_DATE_PREF, MSC_CALENDAR.DATE_OFFSET(x.ORGANIZATION_ID,
		                                                                    x.SR_INSTANCE_ID,
		                                                                    TYPE_DAILY_BUCKET,
		                                                                    (MSC_CALENDAR.NEXT_WORK_DAY
		                                                                         (x.ORGANIZATION_ID,
		                                                                         x.SR_INSTANCE_ID,
		                                                                         1,
		                                                                         nvl(x.NEED_BY_DATE,x.promised_date))),
		                                                                    nvl(x.POSTPROCESSING_LEAD_TIME,0)
		                                                                   )),
		         x.NEW_SCHEDULE_DATE ) NEW_SCHEDULE_DATE ,
		*/
		  x.NEW_SCHEDULE_DATE,
		  x.OLD_SCHEDULE_DATE,
		  x.NEW_WIP_START_DATE,
		  x.OLD_WIP_START_DATE,
		  x.FIRST_UNIT_COMPLETION_DATE,
		  x.LAST_UNIT_COMPLETION_DATE,
		  x.FIRST_UNIT_START_DATE,
		  x.LAST_UNIT_START_DATE,
		  x.DISPOSITION_ID,
		  x.DISPOSITION_STATUS_TYPE,
		  x.ORDER_TYPE,
		  x.NEW_ORDER_QUANTITY,
		  x.OLD_ORDER_QUANTITY,
		  x.QUANTITY_PER_ASSEMBLY,
		  x.QUANTITY_ISSUED,
		  x.DAILY_RATE,
		  x.NEW_ORDER_PLACEMENT_DATE,
		  x.OLD_ORDER_PLACEMENT_DATE,
		  x.RESCHEDULE_DAYS,
		  x.RESCHEDULE_FLAG,
		  x.SCHEDULE_COMPRESS_DAYS,
		  x.NEW_PROCESSING_DAYS,
		  x.PURCH_LINE_NUM,
		  x.PO_LINE_ID,
		  x.QUANTITY_IN_PROCESS,
		  x.IMPLEMENTED_QUANTITY,
		  x.FIRM_PLANNED_TYPE,
		  x.FIRM_QUANTITY,
		  x.FIRM_DATE,
		  x.RELEASE_STATUS,
		  x.LOAD_TYPE,
		  x.PROCESS_SEQ_ID,
		  x.bill_sequence_id,
		  x.routing_sequence_id,
		  x.SCO_SUPPLY_FLAG,
		  x.ALTERNATE_BOM_DESIGNATOR,
		  x.ALTERNATE_ROUTING_DESIGNATOR,
		  x.OPERATION_SEQ_NUM,
		  x.JUMP_OP_SEQ_NUM,
		  x.JOB_OP_SEQ_NUM,
		  x.WIP_START_QUANTITY,
		  t2.INVENTORY_ITEM_ID   BY_PRODUCT_USING_ASSY_ID,
		  x.SOURCE_ORGANIZATION_ID,
		  x.SOURCE_SR_INSTANCE_ID,
		  x.SOURCE_SUPPLIER_SITE_ID,
		  x.SOURCE_SUPPLIER_ID,
		  x.SHIP_METHOD,
		  x.WEIGHT_CAPACITY_USED,
		  x.VOLUME_CAPACITY_USED,
		  x.NEW_SHIP_DATE,
		  /* CP-ACK starts */
		  -- bug 2773881 - Use either PROMISED_DATE or NEED_BY_DATE
		  nvl(decode(lv_po_dock_date_ref,
					 MSC_CL_COLLECTION.PROMISED_DATE_PREF, nvl(x.PROMISED_DATE, x.NEED_BY_DATE),
					 MSC_CL_COLLECTION.NEED_BY_DATE_PREF , nvl(x.NEED_BY_DATE, x.PROMISED_DATE)
					 --PROMISED_DATE_PREF, x.NEW_DOCK_DATE,
					 --MSC_CL_COLLECTION.NEED_BY_DATE_PREF , nvl(x.NEED_BY_DATE, x.NEW_DOCK_DATE)
			    ),new_dock_date) NEW_DOCK_DATE,
		  /* CP-ACK ends */
		  x.LINE_ID,
		  x.PROJECT_ID,
		  x.TASK_ID,
		  x.PLANNING_GROUP,
		  x.NUMBER1,
		  x.SOURCE_ITEM_ID,
		  REPLACE(REPLACE(x.ORDER_NUMBER,MSC_CL_COLLECTION.v_chr10),MSC_CL_COLLECTION.v_chr13) ORDER_NUMBER,
		  x.SCHEDULE_GROUP_ID,
		  x.BUILD_SEQUENCE,
		  REPLACE(REPLACE(x.WIP_ENTITY_NAME,MSC_CL_COLLECTION.v_chr10),MSC_CL_COLLECTION.v_chr13) WIP_ENTITY_NAME,
		  x.IMPLEMENT_PROCESSING_DAYS,
		  x.DELIVERY_PRICE,
		  x.LATE_SUPPLY_DATE,
		  x.LATE_SUPPLY_QTY,
		  x.SUBINVENTORY_CODE,
		  tp.TP_ID       SUPPLIER_ID,
		  tps.TP_SITE_ID SUPPLIER_SITE_ID,
		  x.EXPECTED_SCRAP_QTY,
		  x.QTY_SCRAPPED,
		  x.QTY_COMPLETED,
		  x.WIP_STATUS_CODE,
		  x.WIP_SUPPLY_TYPE,
		  x.NON_NETTABLE_QTY,
		  x.SCHEDULE_GROUP_NAME,
		  x.LOT_NUMBER,
		  x.EXPIRATION_DATE,
		  md.DESIGNATOR_ID SCHEDULE_DESIGNATOR_ID,
		  x.DEMAND_CLASS,
		  x.DELETED_FLAG,
		  DECODE(x.PLANNING_TP_TYPE,1,tps1.TP_SITE_ID,x.PLANNING_PARTNER_SITE_ID) PLANNING_PARTNER_SITE_ID,
		  x.PLANNING_TP_TYPE,
		  DECODE(x.OWNING_TP_TYPE,1,tps2.TP_SITE_ID,x.OWNING_PARTNER_SITE_ID) OWNING_PARTNER_SITE_ID,
		  x.OWNING_TP_TYPE,
		  decode(x.VMI_FLAG,'Y',1,2) VMI_FLAG,
		  x.PO_LINE_LOCATION_ID,
		  x.PO_DISTRIBUTION_ID,
		    /* CP-ACK starts */
		  x.ORIGINAL_NEED_BY_DATE,
		  x.ORIGINAL_QUANTITY,
		  x.PROMISED_DATE,
		  x.NEED_BY_DATE,
		  x.ACCEPTANCE_REQUIRED_FLAG,
		  /* CP-ACK stops */
		  x.COPRODUCTS_SUPPLY,
		  x.POSTPROCESSING_LEAD_TIME,
		  x.REQUESTED_START_DATE, /* ds change start */
		  x.REQUESTED_COMPLETION_DATE,
		  x.SCHEDULE_PRIORITY,
		  x.ASSET_SERIAL_NUMBER,
		  t3.INVENTORY_ITEM_ID ASSET_ITEM_ID,   /*ds change end */
		  x.ACTUAL_START_DATE,   /* Discrete Mfg Enahancements Bug 4479276 */
		  x.CFM_ROUTING_FLAG,
		  x.SR_CUSTOMER_ACCT_ID,  --SRP Changes Bug # 5684159
		  x.ITEM_TYPE_ID,
		  x.ITEM_TYPE_VALUE,
		  x.customer_product_id,
		  x.sr_repair_type_id,             -- Added for Bug 5909379
		  x.SR_REPAIR_GROUP_ID,
		  x.RO_STATUS_CODE,
		  x.RO_CREATION_DATE,
		  x.REPAIR_LEAD_TIME,
		  x.schedule_origination_type,
		 -- x.PO_LINE_LOCATION_ID,
      x.INTRANSIT_OWNING_ORG_ID,
      x.REQ_LINE_ID,
      x.maintenance_object_source,
      x.description
		FROM MSC_DESIGNATORS md,
		     MSC_TP_SITE_ID_LID tps,
		     MSC_TP_SITE_ID_LID tps1,
		     MSC_TP_SITE_ID_LID tps2,
		     MSC_TP_ID_LID tp,
		     MSC_ITEM_ID_LID t1,
		     MSC_ITEM_ID_LID t2,
		     MSC_ITEM_ID_LID t3,
		     MSC_ST_SUPPLIES x
		WHERE t1.SR_INVENTORY_ITEM_ID= x.INVENTORY_ITEM_ID
		  AND t1.SR_INSTANCE_ID= x.SR_INSTANCE_ID
		  AND t2.SR_INVENTORY_ITEM_ID(+) = x.BY_PRODUCT_USING_ASSY_ID
		  AND t2.SR_INSTANCE_ID(+) = x.SR_INSTANCE_ID
		  AND t3.SR_INVENTORY_ITEM_ID(+) = x.ASSET_ITEM_ID
		  AND t3.SR_INSTANCE_ID(+) = x.SR_INSTANCE_ID
		  AND tp.SR_TP_ID(+)= x.SUPPLIER_ID
		  AND tp.SR_INSTANCE_ID(+)= x.SR_INSTANCE_ID
		  AND tp.PARTNER_TYPE(+)= DECODE( x.SR_MTL_SUPPLY_ID,-1,2,1)
		  AND tps.SR_TP_SITE_ID(+)= x.SUPPLIER_SITE_ID
		  AND tps.SR_INSTANCE_ID(+)= x.SR_INSTANCE_ID
		  AND tps.PARTNER_TYPE(+)= 1
		  AND tps1.SR_TP_SITE_ID(+)= x.PLANNING_PARTNER_SITE_ID
		  AND tps1.SR_INSTANCE_ID(+)= x.SR_INSTANCE_ID
		  AND tps1.PARTNER_TYPE(+)= 1
		  AND tps2.SR_TP_SITE_ID(+)= x.OWNING_PARTNER_SITE_ID
		  AND tps2.SR_INSTANCE_ID(+)= x.SR_INSTANCE_ID
		  AND tps2.PARTNER_TYPE(+)= 1
		  AND x.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
		  AND x.DELETED_FLAG= MSC_UTIL.SYS_NO
		  AND md.SR_INSTANCE_ID(+)= x.SR_INSTANCE_ID
		  AND md.DESIGNATOR(+)= x.SCHEDULE_DESIGNATOR
		  AND md.Organization_ID(+)= x.Organization_ID
		  AND md.Designator_Type(+)= 2  -- MPS
		  /* CP-ACK starts */
		  AND x.ORDER_TYPE NOT IN (MSC_CL_COLLECTION.G_MRP_PO_ACK)
		  /* CP-ACK ends */
		  order by x.Organization_ID;



		   CURSOR c1_d IS
		SELECT x.SR_MTL_SUPPLY_ID,
		       x.DISPOSITION_ID,
		       t1.INVENTORY_ITEM_ID,
		       x.ORGANIZATION_ID,
		       x.OPERATION_SEQ_NUM,
		       x.SUBINVENTORY_CODE,
		       x.NEW_ORDER_QUANTITY,
		       x.LOT_NUMBER,
		       x.PROJECT_ID,
		       x.TASK_ID,
		       x.UNIT_NUMBER,
		       x.ORDER_TYPE,
		       x.SR_INSTANCE_ID,
		       x.COPRODUCTS_SUPPLY,
		  DECODE(x.PLANNING_TP_TYPE,1,tps1.TP_SITE_ID,x.PLANNING_PARTNER_SITE_ID) PLANNING_PARTNER_SITE_ID,
		  x.PLANNING_TP_TYPE,
		  DECODE(x.OWNING_TP_TYPE,1,tps2.TP_SITE_ID,x.OWNING_PARTNER_SITE_ID) OWNING_PARTNER_SITE_ID,
		  x.OWNING_TP_TYPE,
          x.maintenance_object_source,
          x.description
		  FROM MSC_ITEM_ID_LID t1,
		       MSC_ST_SUPPLIES x,
		       MSC_TP_SITE_ID_LID tps1,
		       MSC_TP_SITE_ID_LID tps2
		 WHERE x.DELETED_FLAG= MSC_UTIL.SYS_YES
		   AND x.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
		   AND t1.SR_INVENTORY_ITEM_ID(+)= x.INVENTORY_ITEM_ID
		   AND t1.SR_INSTANCE_ID(+)= x.SR_INSTANCE_ID
		   AND tps1.SR_TP_SITE_ID(+)= x.PLANNING_PARTNER_SITE_ID
		   AND tps1.SR_INSTANCE_ID(+)= x.SR_INSTANCE_ID
		   AND tps1.PARTNER_TYPE(+)= 1
		   AND tps2.SR_TP_SITE_ID(+)= x.OWNING_PARTNER_SITE_ID
		   AND tps2.SR_INSTANCE_ID(+)= x.SR_INSTANCE_ID
		   AND tps2.PARTNER_TYPE(+)= 1;

		   Cursor C10_d IS   -- For Bug 6126698
         SELECT
           mshr.DISPOSITION_ID,
           t1.INVENTORY_ITEM_ID,
           mshr.ORGANIZATION_ID,
           mshr.ORDER_TYPE
           FROM MSC_ST_SUPPLIES mshr,
                MSC_ITEM_ID_LID t1
          WHERE mshr.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
            AND mshr.RO_STATUS_CODE= 'C'
            AND mshr.ORDER_TYPE=75
            AND t1.SR_INVENTORY_ITEM_ID(+)= mshr.inventory_item_id
            AND t1.sr_instance_id(+)= MSC_CL_COLLECTION.v_instance_id ;


		   BEGIN

		/* CP-ACK starts */
		lv_po_dock_date_ref := nvl(fnd_profile.value('MSC_PO_DOCK_DATE_CALC_PREF'), MSC_CL_COLLECTION.PROMISED_DATE_PREF);
		/* CP-ACk ends */

		IF MSC_CL_COLLECTION.v_exchange_mode=MSC_UTIL.SYS_YES THEN
		   lv_tbl:= 'SUPPLIES_'||MSC_CL_COLLECTION.v_instance_code;
		ELSE
		   lv_tbl:= 'MSC_SUPPLIES';
		END IF;

		lv_sql_stmt:=
		'INSERT INTO '||lv_tbl
		||'( PLAN_ID,'
		||'  TRANSACTION_ID,'
		||'  INVENTORY_ITEM_ID,'
		||'  ORGANIZATION_ID,'
		||'  FROM_ORGANIZATION_ID,'
		||'  SR_INSTANCE_ID,'
		||'  SCHEDULE_DESIGNATOR_ID,'
		||'  REVISION,'
		||'  UNIT_NUMBER,'
		||'  NEW_SCHEDULE_DATE,'
		||'  OLD_SCHEDULE_DATE,'
		||'  NEW_WIP_START_DATE,'
		||'  OLD_WIP_START_DATE,'
		||'  FIRST_UNIT_COMPLETION_DATE,'
		||'  LAST_UNIT_COMPLETION_DATE,'
		||'  FIRST_UNIT_START_DATE,'
		||'  LAST_UNIT_START_DATE,'
		||'  DISPOSITION_ID,'
		||'  DISPOSITION_STATUS_TYPE,'
		||'  ORDER_TYPE,'
		||'  NEW_ORDER_QUANTITY,'
		||'  OLD_ORDER_QUANTITY,'
		||'  QUANTITY_PER_ASSEMBLY,'
		||'  QUANTITY_ISSUED,'
		||'  DAILY_RATE,'
		||'  NEW_ORDER_PLACEMENT_DATE,'
		||'  OLD_ORDER_PLACEMENT_DATE,'
		||'  RESCHEDULE_DAYS,'
		||'  RESCHEDULE_FLAG,'
		||'  SCHEDULE_COMPRESS_DAYS,'
		||'  NEW_PROCESSING_DAYS,'
		||'  PURCH_LINE_NUM,'
		||'  PO_LINE_ID,'
		||'  QUANTITY_IN_PROCESS,'
		||'  IMPLEMENTED_QUANTITY,'
		||'  FIRM_PLANNED_TYPE,'
		||'  FIRM_QUANTITY,'
		||'  FIRM_DATE,'
		||'  RELEASE_STATUS,'
		||'  LOAD_TYPE,'
		||'  PROCESS_SEQ_ID,'
		||'  BILL_SEQUENCE_ID,'
		||'  ROUTING_SEQUENCE_ID,'
		||'  SCO_SUPPLY_FLAG,'
		||'  ALTERNATE_BOM_DESIGNATOR,'
		||'  ALTERNATE_ROUTING_DESIGNATOR,'
		||'  OPERATION_SEQ_NUM,'
		||'  JUMP_OP_SEQ_NUM,'
		||'  JOB_OP_SEQ_NUM,'
		||'  WIP_START_QUANTITY,'
		||'  BY_PRODUCT_USING_ASSY_ID,'
		||'  SOURCE_ORGANIZATION_ID,'
		||'  SOURCE_SR_INSTANCE_ID,'
		||'  SOURCE_SUPPLIER_SITE_ID,'
		||'  SOURCE_SUPPLIER_ID,'
		||'  SHIP_METHOD,'
		||'  WEIGHT_CAPACITY_USED,'
		||'  VOLUME_CAPACITY_USED,'
		||'  NEW_SHIP_DATE,'
		||'  NEW_DOCK_DATE,'
		||'  LINE_ID,'
		||'  PROJECT_ID,'
		||'  TASK_ID,'
		||'  PLANNING_GROUP,'
		||'  NUMBER1,'
		||'  SOURCE_ITEM_ID,'
		||'  ORDER_NUMBER,'
		||'  SCHEDULE_GROUP_ID,'
		||'  BUILD_SEQUENCE,'
		||'  WIP_ENTITY_NAME,'
		||'  IMPLEMENT_PROCESSING_DAYS,'
		||'  DELIVERY_PRICE,'
		||'  LATE_SUPPLY_DATE,'
		||'  LATE_SUPPLY_QTY,'
		||'  SUBINVENTORY_CODE,'
		||'  SUPPLIER_ID,'
		||'  SUPPLIER_SITE_ID,'
		||'  EXPECTED_SCRAP_QTY, '
		||'  QTY_SCRAPPED,'
		||'  QTY_COMPLETED,'
		||'  WIP_STATUS_CODE,'
		||'  WIP_SUPPLY_TYPE,'
		||'  NON_NETTABLE_QTY,'
		||'  SCHEDULE_GROUP_NAME,'
		||'  LOT_NUMBER,'
		||'  EXPIRATION_DATE,'
		||'  DEMAND_CLASS,'
		||'  PLANNING_PARTNER_SITE_ID,'
		||'  PLANNING_TP_TYPE,'
		||'  OWNING_PARTNER_SITE_ID,'
		||'  OWNING_TP_TYPE,'
		||'  VMI_FLAG,'
		||'  PO_LINE_LOCATION_ID,'
		||'  PO_DISTRIBUTION_ID,'
		||'  SR_MTL_SUPPLY_ID,'
		||'  REFRESH_NUMBER,'
		||'  LAST_UPDATE_DATE,'
		||'  LAST_UPDATED_BY,'
		||'  CREATION_DATE,'
		||'  CREATED_BY,'
		/* CP-ACK starts */
		||'  ORIGINAL_NEED_BY_DATE,'
		||'  ORIGINAL_QUANTITY,'
		||'  PROMISED_DATE,'
		||'  NEED_BY_DATE,'
		||'  ACCEPTANCE_REQUIRED_FLAG,'
		/* CP-ACK stops */
		||'  COPRODUCTS_SUPPLY,'
		/* ds change start */
		||'  REQUESTED_START_DATE,'
		||'  REQUESTED_COMPLETION_DATE,'
		||'  SCHEDULE_PRIORITY,'
		||'  ASSET_SERIAL_NUMBER,'
		||'  ASSET_ITEM_ID,'
		/* ds change end */
		||'  ACTUAL_START_DATE,'  /* Discrete Mfg Enahancements Bug 4479276 */
		||'  CFM_ROUTING_FLAG,'
		||'  SR_CUSTOMER_ACCT_ID,'
		||'  ITEM_TYPE_ID,'
		||'  ITEM_TYPE_VALUE,'
		||'  customer_product_id,'
		||'  sr_repair_type_id,'             -- Added for Bug 5909379
		||'  SR_REPAIR_GROUP_ID,'
		||'  RO_STATUS_CODE,'
		||'  RO_CREATION_DATE,'
    ||'  REPAIR_LEAD_TIME ,'
    ||'  SCHEDULE_ORIGINATION_TYPE,'
    --||'  PO_LINE_LOCATION_ID,'
    ||'  INTRANSIT_OWNING_ORG_ID,'
    ||'  REQ_LINE_ID,'
    ||'  MAINTENANCE_OBJECT_SOURCE,'
    ||'  DESCRIPTION'
    ||' )'
		||'VALUES'
		||'( -1,'
		||'  MSC_SUPPLIES_S.NEXTVAL,'
		||'  :INVENTORY_ITEM_ID,'
		||'  :ORGANIZATION_ID,'
		||'  :FROM_ORGANIZATION_ID,'
		||'  :SR_INSTANCE_ID,'
		||'  :SCHEDULE_DESIGNATOR_ID,'
		||'  :REVISION,'
		||'  :UNIT_NUMBER,'
		||'  :NEW_SCHEDULE_DATE,'
		||'  decode(:ORDER_TYPE, 1, :NEW_SCHEDULE_DATE, :OLD_SCHEDULE_DATE),'
		||'  :NEW_WIP_START_DATE,'
		||'  :OLD_WIP_START_DATE,'
		||'  :FIRST_UNIT_COMPLETION_DATE,'
		||'  :LAST_UNIT_COMPLETION_DATE,'
		||'  :FIRST_UNIT_START_DATE,'
		||'  :LAST_UNIT_START_DATE,'
		||'  :DISPOSITION_ID,'
		||'  :DISPOSITION_STATUS_TYPE,'
		||'  :ORDER_TYPE,'
		||'  :NEW_ORDER_QUANTITY,'
		||'  :OLD_ORDER_QUANTITY,'
		||'  :QUANTITY_PER_ASSEMBLY,'
		||'  :QUANTITY_ISSUED,'
		||'  :DAILY_RATE,'
		||'  :NEW_ORDER_PLACEMENT_DATE,'
		||'  :OLD_ORDER_PLACEMENT_DATE,'
		||'  :RESCHEDULE_DAYS,'
		||'  :RESCHEDULE_FLAG,'
		||'  :SCHEDULE_COMPRESS_DAYS,'
		||'  :NEW_PROCESSING_DAYS,'
		||'  :PURCH_LINE_NUM,'
		||'  :PO_LINE_ID,'
		||'  :QUANTITY_IN_PROCESS,'
		||'  :IMPLEMENTED_QUANTITY,'
		||'  :FIRM_PLANNED_TYPE,'
		||'  :FIRM_QUANTITY,'
		||'  :FIRM_DATE,'
		||'  :RELEASE_STATUS,'
		||'  :LOAD_TYPE,'
		||'  :PROCESS_SEQ_ID,'
		||'  :bill_sequence_id,'
		||'  :routing_sequence_id,'
		||'  :SCO_SUPPLY_FLAG,'
		||'  :ALTERNATE_BOM_DESIGNATOR,'
		||'  :ALTERNATE_ROUTING_DESIGNATOR,'
		||'  :OPERATION_SEQ_NUM,'
		||'  :JUMP_OP_SEQ_NUM,'
		||'  :JOB_OP_SEQ_NUM,'
		||'  :WIP_START_QUANTITY,'
		||'  :BY_PRODUCT_USING_ASSY_ID,'
		||'  :SOURCE_ORGANIZATION_ID,'
		||'  :SOURCE_SR_INSTANCE_ID,'
		||'  :SOURCE_SUPPLIER_SITE_ID,'
		||'  :SOURCE_SUPPLIER_ID,'
		||'  :SHIP_METHOD,'
		||'  :WEIGHT_CAPACITY_USED,'
		||'  :VOLUME_CAPACITY_USED,'
		||'  :NEW_SHIP_DATE,'
		||'  :NEW_DOCK_DATE,'
		||'  :LINE_ID,'
		||'  :PROJECT_ID,'
		||'  :TASK_ID,'
		||'  :PLANNING_GROUP,'
		||'  :NUMBER1,'
		||'  :SOURCE_ITEM_ID,'
		||'  :ORDER_NUMBER,'
		||'  :SCHEDULE_GROUP_ID,'
		||'  :BUILD_SEQUENCE,'
		||'  :WIP_ENTITY_NAME,'
		||'  :IMPLEMENT_PROCESSING_DAYS,'
		||'  :DELIVERY_PRICE,'
		||'  :LATE_SUPPLY_DATE,'
		||'  :LATE_SUPPLY_QTY,'
		||'  :SUBINVENTORY_CODE,'
		||'  :SUPPLIER_ID,'
		||'  :SUPPLIER_SITE_ID,'
		||'  :EXPECTED_SCRAP_QTY, '
		||'  :QTY_SCRAPPED,'
		||'  :QTY_COMPLETED,'
		||'  :WIP_STATUS_CODE,'
		||'  :WIP_SUPPLY_TYPE,'
		||'  :NON_NETTABLE_QTY,'
		||'  :SCHEDULE_GROUP_NAME,'
		||'  :LOT_NUMBER,'
		||'  :EXPIRATION_DATE,'
		||'  :DEMAND_CLASS,'
		||'  :PLANNING_PARTNER_SITE_ID,'
		||'  :PLANNING_TP_TYPE,'
		||'  :OWNING_PARTNER_SITE_ID,'
		||'  :OWNING_TP_TYPE,'
		||'  :VMI_FLAG,'
		||'  :PO_LINE_LOCATION_ID,'
		||'  :PO_DISTRIBUTION_ID,'
		||'  :SR_MTL_SUPPLY_ID,'
		||'  :v_last_collection_id,'
		||'  :v_current_date,'
		||'  :v_current_user,'
		||'  :v_current_date,'
		||'  :v_current_user,'
		/* CP-ACK starts */
		||'  :ORIGINAL_NEED_BY_DATE,'
		||'  :ORIGINAL_QUANTITY,'
		||'  :PROMISED_DATE,'
		||'  :NEED_BY_DATE,'
		||'  :ACCEPTANCE_REQUIRED_FLAG,'
		/* CP-ACK ends */
		||'  :COPRODUCTS_SUPPLY,'
		/* ds change start */
		||'  :REQUESTED_START_DATE,'
		||'  :REQUESTED_COMPLETION_DATE,'
		||'  :SCHEDULE_PRIORITY,'
		||'  :ASSET_SERIAL_NUMBER,'
		||'  :ASSET_ITEM_ID,'
		/* ds change end */
		||'  :ACTUAL_START_DATE,'  /* Discrete Mfg Enahancements Bug 4479276 */
		||'  :CFM_ROUTING_FLAG ,'
		||'  :SR_CUSTOMER_ACCT_ID,'
		||'  :ITEM_TYPE_ID,'
		||'  :ITEM_TYPE_VALUE,'
		||'  :customer_product_id,'
		||'  :sr_repair_type_id,'             -- Added for Bug 5909379
		||'  :SR_REPAIR_GROUP_ID,'
		||'  :RO_STATUS_CODE,'
		||'  :RO_CREATION_DATE,'
		||'  :REPAIR_LEAD_TIME,'
		||'  :SCHEDULE_ORIGINATION_TYPE, '
	--	||'  :PO_LINE_LOCATION_ID,'
    ||'  :INTRANSIT_OWNING_ORG_ID,'
    ||'  :REQ_LINE_ID,'
    ||'  :MAINTENANCE_OBJECT_SOURCE,'
    ||'  :DESCRIPTION'
    ||' )';



		MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'load_supply');

		IF MSC_CL_COLLECTION.v_is_complete_refresh AND MSC_CL_COLLECTION.v_exchange_mode=MSC_UTIL.SYS_NO THEN

		--MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_SUPPLIES', MSC_CL_COLLECTION.v_instance_id, -1);

		  IF MSC_CL_COLLECTION.v_coll_prec.org_group_flag = MSC_UTIL.G_ALL_ORGANIZATIONS THEN
		    MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_SUPPLIES', MSC_CL_COLLECTION.v_instance_id, -1);
		  ELSE
		    MSC_CL_COLLECTION.v_sub_str :=' AND ORGANIZATION_ID '||MSC_UTIL.v_in_org_str;
		    MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_SUPPLIES', MSC_CL_COLLECTION.v_instance_id, -1,MSC_CL_COLLECTION.v_sub_str);
		  END IF;

		END IF;

		--================= DELETE ==============
		--agmcont

		IF (MSC_CL_COLLECTION.v_is_incremental_refresh or MSC_CL_COLLECTION.v_is_cont_refresh) THEN

		  /* These intransit shipment supplies isn't supported for incremental
		     refresh.
		     In order to keep the transaction_id, set the quantitiy to zero
		     for delete. */

		/*UPDATE MSC_SUPPLIES
		   SET NEW_ORDER_QUANTITY= 0.0,
		       REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
		       LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
		       LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
		 WHERE PLAN_ID= -1
		   AND SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
		   AND ORDER_TYPE= 11
		   AND SR_MTL_SUPPLY_ID= -1;*/

		   lv_sql_stmt1 := ' UPDATE MSC_SUPPLIES '
		                  ||' SET   OLD_NEW_SCHEDULE_DATE = NEW_SCHEDULE_DATE, '
		                  ||'       OLD_NEW_ORDER_QUANTITY = NEW_ORDER_QUANTITY, '
				 							 ||'       NEW_ORDER_QUANTITY= 0.0, '
		                  ||'       REFRESH_NUMBER= :v_last_collection_id, '
		                  ||'       LAST_UPDATE_DATE= :v_current_date, '
		                  ||'       LAST_UPDATED_BY= :v_current_user '
		                  ||' WHERE  PLAN_ID= -1'
		                  ||' AND    SR_INSTANCE_ID= :v_instance_id '
		                  ||' AND    ORDER_TYPE= 11 '		--Intransit shipment
		                  ||' AND    SR_MTL_SUPPLY_ID= -1 ';

		  IF MSC_CL_COLLECTION.v_coll_prec.org_group_flag = MSC_UTIL.G_ALL_ORGANIZATIONS THEN
		    EXECUTE IMMEDIATE lv_sql_stmt1 USING MSC_CL_COLLECTION.v_last_collection_id,
		                                         MSC_CL_COLLECTION.v_current_date,
		                                         MSC_CL_COLLECTION.v_current_user,
		                                         MSC_CL_COLLECTION.v_instance_id;
		  ELSE
		    lv_sql_stmt1:=lv_sql_stmt1||' AND ORGANIZATION_ID '||MSC_UTIL.v_in_org_str;
		    EXECUTE IMMEDIATE lv_sql_stmt1 USING MSC_CL_COLLECTION.v_last_collection_id,
		                                         MSC_CL_COLLECTION.v_current_date,
		                                         MSC_CL_COLLECTION.v_current_user,
		                                         MSC_CL_COLLECTION.v_instance_id;

		  END IF;

		COMMIT;

		c_count:= 0;

		FOR c_rec IN c1_d LOOP
		--1 =PO, 2 = PO REQ, 8 = PO receiving, 12= Intrasit Receipt
		IF (MSC_CL_COLLECTION.v_is_incremental_refresh and c_rec.ORDER_TYPE IN (1,2,8,11,12,73,74,87)) or
		   (MSC_CL_COLLECTION.v_is_cont_refresh and (c_rec.ORDER_TYPE IN (1,2,8,11,12,73,74,87)) and
		    (MSC_CL_COLLECTION.v_coll_prec.po_sn_flag = MSC_UTIL.SYS_INCR)) THEN     -- PO

		--MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'load_supply: upd PO-0');


		UPDATE MSC_SUPPLIES ms
		   SET OLD_NEW_SCHEDULE_DATE = NEW_SCHEDULE_DATE,
		       OLD_NEW_ORDER_QUANTITY = NEW_ORDER_QUANTITY,
		       NEW_ORDER_QUANTITY= 0.0,
		       REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
		       LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
		       LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
		 WHERE PLAN_ID= -1
		   AND SR_INSTANCE_ID= c_rec.SR_INSTANCE_ID
		   AND ORDER_TYPE IN (1,2,8,11,12,73,74,87)
		   AND SR_MTL_SUPPLY_ID= c_rec.SR_MTL_SUPPLY_ID;

		/*3 Discret Job, 7 Non STandard Job, 27 Flow schedule, 70 Eam supply: ds change change,86 External Repair Order */
		ELSIF (MSC_CL_COLLECTION.v_is_incremental_refresh and c_rec.ORDER_TYPE IN (3,7,27, 70,86)) or
		      (MSC_CL_COLLECTION.v_is_cont_refresh and (c_rec.ORDER_TYPE IN (3,7,27,70)) and
		       (MSC_CL_COLLECTION.v_coll_prec.wip_sn_flag = MSC_UTIL.SYS_INCR)) THEN        -- WIP_JOB

		--MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'load_supply: upd WIP-0');
		    if c_rec.ORDER_TYPE = 70 then
		       MSC_CL_COLLECTION.link_top_transaction_id_req := TRUE;
		    end if;

		UPDATE MSC_SUPPLIES ms
		   SET OLD_NEW_SCHEDULE_DATE = NEW_SCHEDULE_DATE,
		       OLD_NEW_ORDER_QUANTITY = NEW_ORDER_QUANTITY,
		       NEW_ORDER_QUANTITY= 0.0,
		       REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
		       LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
		       LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
		 WHERE ms.PLAN_ID= -1
		   AND ms.SR_INSTANCE_ID= c_rec.SR_INSTANCE_ID
		   AND ms.ORDER_TYPE= c_rec.ORDER_TYPE
		   AND ms.DISPOSITION_ID= c_rec.DISPOSITION_ID;


		-- 14=discrete job co product, 15 non stanstard job co-product
		ELSIF (MSC_CL_COLLECTION.v_is_incremental_refresh and c_rec.ORDER_TYPE IN (14,15)) or
		      (MSC_CL_COLLECTION.v_is_cont_refresh and (c_rec.ORDER_TYPE IN (14,15)) and
		       (MSC_CL_COLLECTION.v_coll_prec.wip_sn_flag = MSC_UTIL.SYS_INCR)) THEN          -- DISCRETE JOB COMPONENT

		--MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'load_supply: upd WIP DSC JOB-0');


		UPDATE MSC_SUPPLIES ms
		   SET OLD_NEW_SCHEDULE_DATE = NEW_SCHEDULE_DATE,
		       OLD_NEW_ORDER_QUANTITY = NEW_ORDER_QUANTITY,
		       NEW_ORDER_QUANTITY= 0.0,
		       REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
		       LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
		       LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
		 WHERE PLAN_ID= -1
		   AND SR_INSTANCE_ID= c_rec.SR_INSTANCE_ID
		   AND ORDER_TYPE= c_rec.ORDER_TYPE
		   AND INVENTORY_ITEM_ID= NVL(c_rec.INVENTORY_ITEM_ID,INVENTORY_ITEM_ID)
		   AND DISPOSITION_ID= c_rec.DISPOSITION_ID
		   AND OPERATION_SEQ_NUM= NVL(c_rec.OPERATION_SEQ_NUM,OPERATION_SEQ_NUM);

		ELSIF (MSC_CL_COLLECTION.v_is_incremental_refresh and c_rec.ORDER_TYPE= 30) or
		      (MSC_CL_COLLECTION.v_is_cont_refresh and (c_rec.ORDER_TYPE = 30) and
		       (MSC_CL_COLLECTION.v_coll_prec.wip_sn_flag = MSC_UTIL.SYS_INCR)) THEN                  -- REPT ITEM

		--MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'load_supply: upd WIP REPT ITEM-0');


		UPDATE MSC_SUPPLIES
		  SET OLD_NEW_SCHEDULE_DATE = NEW_SCHEDULE_DATE,
		       OLD_NEW_ORDER_QUANTITY = NEW_ORDER_QUANTITY,
		       OLD_DAILY_RATE = DAILY_RATE,
		       OLD_FIRST_UNIT_START_DATE= FIRST_UNIT_START_DATE,
		       OLD_LAST_UNIT_COMPLETION_DATE= LAST_UNIT_COMPLETION_DATE,
		       NEW_ORDER_QUANTITY= 0.0,
		       DAILY_RATE = 0.0,
		       REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
		       LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
		       LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
		 WHERE PLAN_ID= -1
		   AND SR_INSTANCE_ID= c_rec.SR_INSTANCE_ID
		   AND ORDER_TYPE= c_rec.ORDER_TYPE
		   AND DISPOSITION_ID= c_rec.DISPOSITION_ID
		   AND ORGANIZATION_ID = c_rec.ORGANIZATION_ID;

		ELSIF (MSC_CL_COLLECTION.v_is_incremental_refresh and c_rec.ORDER_TYPE= 18) or
		      (MSC_CL_COLLECTION.v_is_cont_refresh and (c_rec.ORDER_TYPE = 18) and
		       (MSC_CL_COLLECTION.v_coll_prec.oh_sn_flag = MSC_UTIL.SYS_INCR)) THEN                  -- ONHAND

		--MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'load_supply: upd OH-0');


		UPDATE MSC_SUPPLIES
		   --SET NEW_ORDER_QUANTITY= 0.0,
		    SET OLD_NEW_SCHEDULE_DATE = NEW_SCHEDULE_DATE,
		       OLD_NEW_ORDER_QUANTITY = NEW_ORDER_QUANTITY,
		       NEW_ORDER_QUANTITY= NEW_ORDER_QUANTITY-c_rec.NEW_ORDER_QUANTITY, /*Bug: 2791310 */
		       REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
		       LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
		       LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
		 WHERE PLAN_ID= -1
		   AND SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
		   AND ORDER_TYPE= 18
		   AND INVENTORY_ITEM_ID= c_rec.INVENTORY_ITEM_ID
		   AND ORGANIZATION_ID= c_rec.ORGANIZATION_ID
		   AND NVL(SUBINVENTORY_CODE, MSC_UTIL.NULL_CHAR)= NVL( c_rec.SUBINVENTORY_CODE, MSC_UTIL.NULL_CHAR)
		   AND NVL(LOT_NUMBER, MSC_UTIL.NULL_CHAR)= NVL( c_rec.LOT_NUMBER, MSC_UTIL.NULL_CHAR)
		  AND NVL(PROJECT_ID, MSC_UTIL.NULL_VALUE)= NVL( c_rec.PROJECT_ID, MSC_UTIL.NULL_VALUE)
		  AND NVL(TASK_ID, MSC_UTIL.NULL_VALUE)= NVL( c_rec.TASK_ID, MSC_UTIL.NULL_VALUE)
		  AND NVL(UNIT_NUMBER, MSC_UTIL.NULL_CHAR)= NVL( c_rec.UNIT_NUMBER,MSC_UTIL.NULL_CHAR)
		  AND NVL(OWNING_PARTNER_SITE_ID,MSC_UTIL.NULL_VALUE)= NVL(c_rec.OWNING_PARTNER_SITE_ID,MSC_UTIL.NULL_VALUE)
		  AND NVL(OWNING_TP_TYPE,MSC_UTIL.NULL_VALUE)= NVL(c_rec.OWNING_TP_TYPE,MSC_UTIL.NULL_VALUE)
		  AND NVL(PLANNING_PARTNER_SITE_ID,MSC_UTIL.NULL_VALUE)= NVL(c_rec.PLANNING_PARTNER_SITE_ID,MSC_UTIL.NULL_VALUE)
		  AND NVL(PLANNING_TP_TYPE,MSC_UTIL.NULL_VALUE)= NVL(c_rec.PLANNING_TP_TYPE,MSC_UTIL.NULL_VALUE);

		/* planned order */
		ELSIF (MSC_CL_COLLECTION.v_is_incremental_refresh and c_rec.ORDER_TYPE= 5) or
		      (MSC_CL_COLLECTION.v_is_cont_refresh and (c_rec.ORDER_TYPE = 5) and
		       (MSC_CL_COLLECTION.v_coll_prec.mps_sn_flag = MSC_UTIL.SYS_INCR)) THEN                   -- MPS


		--MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'load_supply: upd MPS-0');


		UPDATE MSC_SUPPLIES
		    SET OLD_NEW_SCHEDULE_DATE = NEW_SCHEDULE_DATE,
		       OLD_NEW_ORDER_QUANTITY = NEW_ORDER_QUANTITY,
		       NEW_ORDER_QUANTITY= 0.0,
		       DAILY_RATE= 0.0,
		       REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
		       LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
		       LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
		 WHERE PLAN_ID= -1
		   AND SR_INSTANCE_ID= c_rec.SR_INSTANCE_ID
		   AND DISPOSITION_ID= c_rec.DISPOSITION_ID
		   AND ORDER_TYPE= c_rec.ORDER_TYPE
		   AND ORGANIZATION_ID = c_rec.ORGANIZATION_ID;

		ELSIF (MSC_CL_COLLECTION.v_is_incremental_refresh and c_rec.ORDER_TYPE= 41) or
		      (MSC_CL_COLLECTION.v_is_cont_refresh and (c_rec.ORDER_TYPE = 41) and
		       (MSC_CL_COLLECTION.v_coll_prec.usup_sn_flag = MSC_UTIL.SYS_INCR)) THEN                  -- USER DEFINED

		--MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'load_supply: upd USUP-0');


		UPDATE MSC_SUPPLIES
		    SET OLD_NEW_SCHEDULE_DATE = NEW_SCHEDULE_DATE,
		       OLD_NEW_ORDER_QUANTITY = NEW_ORDER_QUANTITY,
		       NEW_ORDER_QUANTITY= 0.0,
		       REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
		       LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
		       LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
		 WHERE PLAN_ID= -1
		   AND SR_INSTANCE_ID= c_rec.SR_INSTANCE_ID
		   AND DISPOSITION_ID= c_rec.DISPOSITION_ID
		   AND ORDER_TYPE= c_rec.ORDER_TYPE
		   AND ORGANIZATION_ID = c_rec.ORGANIZATION_ID;

		END IF;  -- ORDER_TYPE

		  c_count:= c_count+1;

		  IF c_count> MSC_CL_COLLECTION.PBS THEN
		     COMMIT;
		     c_count:= 0;
		  END IF;

		END LOOP;  -- c1_d

		-- For bug 6126698
		For c_rec in c10_d  LOOP

      	Delete from msc_supplies
      	Where DISPOSITION_ID  = c_rec.DISPOSITION_ID
      	And   organization_id = c_rec.organization_id
      	And   order_type      = c_rec.order_type
      	And   sr_instance_id  = MSC_CL_COLLECTION.v_instance_id
      	And   plan_id         = -1;

    END LOOP;  -- c10_d

		END IF;  -- refresh type

		IF MSC_CL_COLLECTION.v_is_complete_refresh THEN
		    COMMIT;
		END IF;


		--agmcont

		c_count:=0;

		FOR c_rec IN c1 LOOP

		BEGIN

			-- SRP enhancement
		IF MSC_UTIL.g_collect_srp_data = 'Y' THEN
		  IF   (c_rec.ORDER_TYPE = 1)
		    OR (c_rec.ORDER_TYPE = 5 AND c_rec.FIRM_PLANNED_TYPE = 1)
		    OR (c_rec.ORDER_TYPE = 75) OR (c_rec.ORDER_TYPE = 74)
		    OR (c_rec.ORDER_TYPE = 86) THEN
		     lv_ITEM_TYPE_ID     := MSC_UTIL.G_PARTCONDN_ITEMTYPEID;
		     lv_ITEM_TYPE_VALUE  :=  MSC_UTIL.G_PARTCONDN_GOOD;
		  ELSE
		       lv_ITEM_TYPE_ID := c_rec.ITEM_TYPE_ID;
		       lv_ITEM_TYPE_VALUE  :=  c_rec.ITEM_TYPE_VALUE;
		  END IF;
		END IF;
		--logic for calculating dock date and schedule date

		IF (c_rec.NEW_DOCK_DATE is not null) THEN

		     IF(lv_org_id <> c_rec.ORGANIZATION_ID or lv_org_id=0) THEN

		     --GET_CALENDAR_CODE to be called only once for the same org

			lv_cal_code:=msc_calendar.GET_CALENDAR_CODE(c_rec.SR_INSTANCE_ID, null, null, null, null, null, c_rec.ORGANIZATION_ID, null, MSC_CALENDAR.ORC);

			lv_cal_code_omc:=msc_calendar.GET_CALENDAR_CODE(c_rec.SR_INSTANCE_ID, null, null, null, null, null, c_rec.ORGANIZATION_ID, null, MSC_CALENDAR.OMC);

			lv_org_id:=c_rec.ORGANIZATION_ID;

		      END IF;

		      --finding the dock date by validating it from Org Rec. Calendar
		      lv_time_component:= c_rec.NEW_DOCK_DATE - trunc(c_rec.NEW_DOCK_DATE);
		      lv_dock_date :=MSC_CALENDAR.NEXT_WORK_DAY(lv_cal_code,c_rec.SR_INSTANCE_ID,c_rec.NEW_DOCK_DATE);
		      lv_dock_date:= lv_dock_date + lv_time_component;
		 ELSE
		      IF c_rec.ORDER_TYPE=11 THEN

		          IF(lv_org_id <> c_rec.ORGANIZATION_ID or lv_org_id=0) THEN
		              --GET_CALENDAR_CODE to be called only once for the same org

		              lv_cal_code:=msc_calendar.GET_CALENDAR_CODE(c_rec.SR_INSTANCE_ID, null, null, null, null, null, c_rec.ORGANIZATION_ID, null, MSC_CALENDAR.ORC);

		              lv_cal_code_omc:=msc_calendar.GET_CALENDAR_CODE(c_rec.SR_INSTANCE_ID, null, null, null, null, null, c_rec.ORGANIZATION_ID, null, MSC_CALENDAR.OMC);

		              lv_org_id:=c_rec.ORGANIZATION_ID;

		          END IF;
		          if (c_rec.NEW_SCHEDULE_DATE is not null ) then
		          	lv_time_component:= c_rec.NEW_SCHEDULE_DATE - trunc(c_rec.NEW_SCHEDULE_DATE);
		          END IF ;
		          lv_schedule_date  :=MSC_CALENDAR.DATE_OFFSET(lv_cal_code_omc,c_rec.SR_INSTANCE_ID,c_rec.NEW_SCHEDULE_DATE,nvl(c_rec.POSTPROCESSING_LEAD_TIME,0),1);
		          if (c_rec.NEW_SCHEDULE_DATE is not null ) then
		          	lv_schedule_date := lv_schedule_date + lv_time_component;
		          END IF ;

		      END IF;
		      lv_dock_date :=null;

		 END IF;


		 IF(c_rec.ORDER_TYPE in (1,2,8,73,74,87)) THEN -- bug#8426490 added Order Type PO_IN_RECEIVING (8)

			--offsetting the dock date to find the schedule date using OMC
		  IF (lv_dock_date is not null ) then
		  	lv_time_component:= lv_dock_date - trunc(lv_dock_date);
		  	lv_schedule_date  :=MSC_CALENDAR.DATE_OFFSET(lv_cal_code_omc,c_rec.SR_INSTANCE_ID,lv_dock_date,nvl(c_rec.POSTPROCESSING_LEAD_TIME,0),1);
		   	lv_schedule_date:= lv_schedule_date + lv_time_component;
		   ELSE
			   lv_schedule_date  :=c_rec.NEW_SCHEDULE_DATE;
			 END IF ;



		 ELSIF NOT(c_rec.ORDER_TYPE=11 and c_rec.NEW_DOCK_DATE is null) THEN
			lv_schedule_date  :=c_rec.NEW_SCHEDULE_DATE;

		END IF;
	  /* bug 5937871 */
	  IF MSC_UTIL.g_collect_srp_data = 'Y' THEN
  	  IF c_rec.ORDER_TYPE=75 THEN
		    if (c_rec.NEW_SCHEDULE_DATE is  null ) then
			    lv_cal_code_omc:=msc_calendar.GET_CALENDAR_CODE(c_rec.SR_INSTANCE_ID, null, null, null, null, null, c_rec.ORGANIZATION_ID, null, MSC_CALENDAR.OMC);
           lv_schedule_date  :=MSC_CALENDAR.DATE_OFFSET(lv_cal_code_omc,c_rec.SR_INSTANCE_ID,c_rec.RO_CREATION_DATE,nvl(c_rec.REPAIR_LEAD_TIME,0),1);
		    END IF ;
	     END IF ;
	  END IF ;
    /* end bug 5937871*/

		IF (MSC_CL_COLLECTION.v_is_incremental_refresh or MSC_CL_COLLECTION.v_is_cont_refresh) THEN

		--=================== PO SUPPLIES =====================

		IF (MSC_CL_COLLECTION.v_is_incremental_refresh and c_rec.ORDER_TYPE IN (1,2,8,11,12,73,74,87)) or
		   (MSC_CL_COLLECTION.v_is_cont_refresh and (c_rec.ORDER_TYPE IN (1,2,8,11,12,73,74,87)) and
		    (MSC_CL_COLLECTION.v_coll_prec.po_sn_flag = MSC_UTIL.SYS_INCR)) THEN     -- PO

		--MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'load_supply: upd PO');


		IF c_rec.SR_MTL_SUPPLY_ID<> -1 THEN

		/* ATP SUMMARY CHANGES Added the OLD_**** Columns */
		UPDATE MSC_SUPPLIES
		SET
		 OLD_DAILY_RATE= DAILY_RATE,
		 OLD_FIRST_UNIT_START_DATE= FIRST_UNIT_START_DATE,
		 OLD_LAST_UNIT_COMPLETION_DATE= LAST_UNIT_COMPLETION_DATE,
		 OLD_NEW_SCHEDULE_DATE= NEW_SCHEDULE_DATE,
		 OLD_QTY_COMPLETED= QTY_COMPLETED,
		 OLD_NEW_ORDER_QUANTITY= decode(REFRESH_NUMBER,MSC_CL_COLLECTION.v_last_collection_id,OLD_NEW_ORDER_QUANTITY,NEW_ORDER_QUANTITY),
		 OLD_FIRM_QUANTITY= FIRM_QUANTITY,
		 OLD_FIRM_DATE= FIRM_DATE,
		 INVENTORY_ITEM_ID= c_rec.INVENTORY_ITEM_ID,
		 ORGANIZATION_ID= c_rec.ORGANIZATION_ID,
		 FROM_ORGANIZATION_ID= c_rec.FROM_ORGANIZATION_ID,
		 REVISION= c_rec.REVISION,
		 UNIT_NUMBER= c_rec.UNIT_NUMBER,
		 NEW_SCHEDULE_DATE=lv_schedule_date ,
		 OLD_SCHEDULE_DATE= c_rec.OLD_SCHEDULE_DATE,
		 NEW_WIP_START_DATE= c_rec.NEW_WIP_START_DATE,
		 OLD_WIP_START_DATE= c_rec.OLD_WIP_START_DATE,
		 FIRST_UNIT_COMPLETION_DATE= c_rec.FIRST_UNIT_COMPLETION_DATE,
		 LAST_UNIT_COMPLETION_DATE= c_rec.LAST_UNIT_COMPLETION_DATE,
		 FIRST_UNIT_START_DATE= c_rec.FIRST_UNIT_START_DATE,
		 LAST_UNIT_START_DATE= c_rec.LAST_UNIT_START_DATE,
		 DISPOSITION_STATUS_TYPE= c_rec.DISPOSITION_STATUS_TYPE,
		 NEW_ORDER_QUANTITY= c_rec.NEW_ORDER_QUANTITY,
		 OLD_ORDER_QUANTITY= c_rec.OLD_ORDER_QUANTITY,
		 DAILY_RATE= c_rec.DAILY_RATE,
		 NEW_ORDER_PLACEMENT_DATE= c_rec.NEW_ORDER_PLACEMENT_DATE,
		 OLD_ORDER_PLACEMENT_DATE= c_rec.OLD_ORDER_PLACEMENT_DATE,
		 RESCHEDULE_DAYS= c_rec.RESCHEDULE_DAYS,
		 RESCHEDULE_FLAG= c_rec.RESCHEDULE_FLAG,
		 SCHEDULE_COMPRESS_DAYS= c_rec.SCHEDULE_COMPRESS_DAYS,
		 NEW_PROCESSING_DAYS= c_rec.NEW_PROCESSING_DAYS,
		 PURCH_LINE_NUM= c_rec.PURCH_LINE_NUM,
		 PO_LINE_ID= c_rec.PO_LINE_ID,
		 QUANTITY_IN_PROCESS= c_rec.QUANTITY_IN_PROCESS,
		 IMPLEMENTED_QUANTITY= c_rec.IMPLEMENTED_QUANTITY,
		 FIRM_PLANNED_TYPE= c_rec.FIRM_PLANNED_TYPE,
		 FIRM_QUANTITY= c_rec.FIRM_QUANTITY,
		 FIRM_DATE= c_rec.FIRM_DATE,
		 RELEASE_STATUS= c_rec.RELEASE_STATUS,
		 LOAD_TYPE= c_rec.LOAD_TYPE,
		 PROCESS_SEQ_ID= c_rec.PROCESS_SEQ_ID,
		 SCO_SUPPLY_FLAG= c_rec.SCO_SUPPLY_FLAG,
		 ALTERNATE_BOM_DESIGNATOR= c_rec.ALTERNATE_BOM_DESIGNATOR,
		 ALTERNATE_ROUTING_DESIGNATOR= c_rec.ALTERNATE_ROUTING_DESIGNATOR,
		 OPERATION_SEQ_NUM= c_rec.OPERATION_SEQ_NUM,
		 WIP_START_QUANTITY = c_rec.WIP_START_QUANTITY,
		 BY_PRODUCT_USING_ASSY_ID= c_rec.BY_PRODUCT_USING_ASSY_ID,
		 SOURCE_ORGANIZATION_ID= c_rec.SOURCE_ORGANIZATION_ID,
		 SOURCE_SR_INSTANCE_ID= c_rec.SOURCE_SR_INSTANCE_ID,
		 SOURCE_SUPPLIER_SITE_ID= c_rec.SOURCE_SUPPLIER_SITE_ID,
		 SOURCE_SUPPLIER_ID= c_rec.SOURCE_SUPPLIER_ID,
		 SHIP_METHOD= c_rec.SHIP_METHOD,
		 WEIGHT_CAPACITY_USED= c_rec.WEIGHT_CAPACITY_USED,
		 VOLUME_CAPACITY_USED= c_rec.VOLUME_CAPACITY_USED,
		 NEW_SHIP_DATE= c_rec.NEW_SHIP_DATE,
		 NEW_DOCK_DATE= lv_dock_date,
		 LINE_ID= c_rec.LINE_ID,
		 PROJECT_ID= c_rec.PROJECT_ID,
		 TASK_ID= c_rec.TASK_ID,
		 PLANNING_GROUP= c_rec.PLANNING_GROUP,
		 NUMBER1= c_rec.NUMBER1,
		 SOURCE_ITEM_ID= c_rec.SOURCE_ITEM_ID,
		 ORDER_NUMBER= c_rec.ORDER_NUMBER,
		 SCHEDULE_GROUP_ID= c_rec.SCHEDULE_GROUP_ID,
		 BUILD_SEQUENCE= c_rec.BUILD_SEQUENCE,
		 WIP_ENTITY_NAME= c_rec.WIP_ENTITY_NAME,
		 IMPLEMENT_PROCESSING_DAYS= c_rec.IMPLEMENT_PROCESSING_DAYS,
		 DELIVERY_PRICE= c_rec.DELIVERY_PRICE,
		 LATE_SUPPLY_DATE= c_rec.LATE_SUPPLY_DATE,
		 LATE_SUPPLY_QTY= c_rec.LATE_SUPPLY_QTY,
		 SUBINVENTORY_CODE= c_rec.SUBINVENTORY_CODE,
		 SUPPLIER_ID= c_rec.SUPPLIER_ID,
		 SUPPLIER_SITE_ID= c_rec.SUPPLIER_SITE_ID,
		 EXPECTED_SCRAP_QTY= c_rec.EXPECTED_SCRAP_QTY,
		 QTY_SCRAPPED= c_rec.QTY_SCRAPPED,
		 QTY_COMPLETED= c_rec.QTY_COMPLETED,
		 SCHEDULE_GROUP_NAME= c_rec.SCHEDULE_GROUP_NAME,
		 LOT_NUMBER= c_rec.LOT_NUMBER,
		 DEMAND_CLASS= c_rec.DEMAND_CLASS,
		 VMI_FLAG=c_rec.VMI_FLAG,
		 PO_LINE_LOCATION_ID = c_rec.PO_LINE_LOCATION_ID,
		 PO_DISTRIBUTION_ID = c_rec.PO_DISTRIBUTION_ID,
		 REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
		 LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
		 LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user,
		/* CP-ACK starts */
		 PROMISED_DATE = c_rec.PROMISED_DATE,
		 NEED_BY_DATE = c_rec.NEED_BY_DATE,
		 ACCEPTANCE_REQUIRED_FLAG = c_rec.ACCEPTANCE_REQUIRED_FLAG,
		/* CP-ACK ends */
		 COPRODUCTS_SUPPLY = c_rec.COPRODUCTS_SUPPLY,
		 ITEM_TYPE_ID = lv_ITEM_TYPE_ID,
		  ITEM_TYPE_VALUE = lv_ITEM_TYPE_VALUE,
		  RO_CREATION_DATE =c_rec.RO_CREATION_DATE,
		  REPAIR_LEAD_TIME= c_rec.REPAIR_LEAD_TIME,
		 -- PO_LINE_LOCATION_ID= c_rec.PO_LINE_LOCATION_ID,
      INTRANSIT_OWNING_ORG_ID= c_rec.INTRANSIT_OWNING_ORG_ID,
      REQ_LINE_ID= c_rec.REQ_LINE_ID
    WHERE PLAN_ID= -1
		  AND SR_INSTANCE_ID= c_rec.SR_INSTANCE_ID
		  AND ORDER_TYPE= c_rec.ORDER_TYPE
		  AND SR_MTL_SUPPLY_ID= c_rec.SR_MTL_SUPPLY_ID
		  AND ORGANIZATION_ID = c_rec.ORGANIZATION_ID;

		END IF;

		--=================== WIP JOB SUPPLIES =====================
		ELSIF (MSC_CL_COLLECTION.v_is_incremental_refresh and c_rec.ORDER_TYPE IN (3,7,27,70,75,86)) or  /* 70 eam supply*/
		      (MSC_CL_COLLECTION.v_is_cont_refresh and (c_rec.ORDER_TYPE IN (3,7,27,70)) and
		        (MSC_CL_COLLECTION.v_coll_prec.wip_sn_flag = MSC_UTIL.SYS_INCR)) THEN        -- WIP_JOB


		MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'load_supply: upd WIP JOB');


		/* ATP SUMMARY CHANGES Added the OLD_**** Columns */
		UPDATE MSC_SUPPLIES
		SET
		 OLD_DAILY_RATE= DAILY_RATE,
		 OLD_FIRST_UNIT_START_DATE= FIRST_UNIT_START_DATE,
		 OLD_LAST_UNIT_COMPLETION_DATE= LAST_UNIT_COMPLETION_DATE,
		 OLD_NEW_SCHEDULE_DATE= NEW_SCHEDULE_DATE,
		 OLD_QTY_COMPLETED= QTY_COMPLETED,
		 OLD_NEW_ORDER_QUANTITY= decode(REFRESH_NUMBER,MSC_CL_COLLECTION.v_last_collection_id,OLD_NEW_ORDER_QUANTITY,NEW_ORDER_QUANTITY),
		 OLD_FIRM_QUANTITY= FIRM_QUANTITY,
		 OLD_FIRM_DATE= FIRM_DATE,
		 INVENTORY_ITEM_ID= c_rec.INVENTORY_ITEM_ID,
		 ORGANIZATION_ID= c_rec.ORGANIZATION_ID,
		 REVISION= c_rec.REVISION,
		 UNIT_NUMBER= c_rec.UNIT_NUMBER,
		 NEW_SCHEDULE_DATE= lv_schedule_date,
		 OLD_SCHEDULE_DATE= c_rec.OLD_SCHEDULE_DATE,
		 NEW_WIP_START_DATE= c_rec.NEW_WIP_START_DATE,
		 OLD_WIP_START_DATE= c_rec.OLD_WIP_START_DATE,
		 FIRST_UNIT_COMPLETION_DATE= c_rec.FIRST_UNIT_COMPLETION_DATE,
		 LAST_UNIT_COMPLETION_DATE= c_rec.LAST_UNIT_COMPLETION_DATE,
		 FIRST_UNIT_START_DATE= c_rec.FIRST_UNIT_START_DATE,
		 LAST_UNIT_START_DATE= c_rec.LAST_UNIT_START_DATE,
		 DISPOSITION_ID= c_rec.DISPOSITION_ID,
		 DISPOSITION_STATUS_TYPE= c_rec.DISPOSITION_STATUS_TYPE,
		 NEW_ORDER_QUANTITY= c_rec.NEW_ORDER_QUANTITY,
		 OLD_ORDER_QUANTITY= c_rec.OLD_ORDER_QUANTITY,
		 DAILY_RATE= c_rec.DAILY_RATE,
		 NEW_ORDER_PLACEMENT_DATE= c_rec.NEW_ORDER_PLACEMENT_DATE,
		 OLD_ORDER_PLACEMENT_DATE= c_rec.OLD_ORDER_PLACEMENT_DATE,
		 RESCHEDULE_DAYS= c_rec.RESCHEDULE_DAYS,
		 RESCHEDULE_FLAG= c_rec.RESCHEDULE_FLAG,
		 SCHEDULE_COMPRESS_DAYS= c_rec.SCHEDULE_COMPRESS_DAYS,
		 NEW_PROCESSING_DAYS= c_rec.NEW_PROCESSING_DAYS,
		 PURCH_LINE_NUM= c_rec.PURCH_LINE_NUM,
		 PO_LINE_ID= c_rec.PO_LINE_ID,
		 QUANTITY_IN_PROCESS= c_rec.QUANTITY_IN_PROCESS,
		 IMPLEMENTED_QUANTITY= c_rec.IMPLEMENTED_QUANTITY,
		 FIRM_PLANNED_TYPE= c_rec.FIRM_PLANNED_TYPE,
		 FIRM_QUANTITY= c_rec.FIRM_QUANTITY,
		 FIRM_DATE= c_rec.FIRM_DATE,
		 RELEASE_STATUS= c_rec.RELEASE_STATUS,
		 LOAD_TYPE= c_rec.LOAD_TYPE,
		 PROCESS_SEQ_ID= c_rec.PROCESS_SEQ_ID,
		 SCO_SUPPLY_FLAG= c_rec.SCO_SUPPLY_FLAG,
		 ALTERNATE_BOM_DESIGNATOR= c_rec.ALTERNATE_BOM_DESIGNATOR,
		 ALTERNATE_ROUTING_DESIGNATOR= c_rec.ALTERNATE_ROUTING_DESIGNATOR,
		 OPERATION_SEQ_NUM= c_rec.OPERATION_SEQ_NUM,
		 JUMP_OP_SEQ_NUM = c_rec.JUMP_OP_SEQ_NUM,
		 JOB_OP_SEQ_NUM = c_rec.JOB_OP_SEQ_NUM,
		 WIP_START_QUANTITY = c_rec.WIP_START_QUANTITY,
		 BY_PRODUCT_USING_ASSY_ID= c_rec.BY_PRODUCT_USING_ASSY_ID,
		 SOURCE_ORGANIZATION_ID= c_rec.SOURCE_ORGANIZATION_ID,
		 SOURCE_SR_INSTANCE_ID= c_rec.SOURCE_SR_INSTANCE_ID,
		 SOURCE_SUPPLIER_SITE_ID= c_rec.SOURCE_SUPPLIER_SITE_ID,
		 SOURCE_SUPPLIER_ID= c_rec.SOURCE_SUPPLIER_ID,
		 SHIP_METHOD= c_rec.SHIP_METHOD,
		 WEIGHT_CAPACITY_USED= c_rec.WEIGHT_CAPACITY_USED,
		 VOLUME_CAPACITY_USED= c_rec.VOLUME_CAPACITY_USED,
		 NEW_SHIP_DATE= c_rec.NEW_SHIP_DATE,
		 NEW_DOCK_DATE= lv_dock_date,
		 LINE_ID= c_rec.LINE_ID,
		 PROJECT_ID= c_rec.PROJECT_ID,
		 TASK_ID= c_rec.TASK_ID,
		 PLANNING_GROUP= c_rec.PLANNING_GROUP,
		 NUMBER1= c_rec.NUMBER1,
		 SOURCE_ITEM_ID= c_rec.SOURCE_ITEM_ID,
		 ORDER_NUMBER= c_rec.ORDER_NUMBER,
		 SCHEDULE_GROUP_ID= c_rec.SCHEDULE_GROUP_ID,
		 BUILD_SEQUENCE= c_rec.BUILD_SEQUENCE,
		 WIP_ENTITY_NAME= c_rec.WIP_ENTITY_NAME,
		 IMPLEMENT_PROCESSING_DAYS= c_rec.IMPLEMENT_PROCESSING_DAYS,
		 DELIVERY_PRICE= c_rec.DELIVERY_PRICE,
		 LATE_SUPPLY_DATE= c_rec.LATE_SUPPLY_DATE,
		 LATE_SUPPLY_QTY= c_rec.LATE_SUPPLY_QTY,
		 SUBINVENTORY_CODE= c_rec.SUBINVENTORY_CODE,
		 SUPPLIER_ID= c_rec.SUPPLIER_ID,
		 SUPPLIER_SITE_ID= c_rec.SUPPLIER_SITE_ID,
		 EXPECTED_SCRAP_QTY= c_rec.EXPECTED_SCRAP_QTY,
		 QTY_SCRAPPED= c_rec.QTY_SCRAPPED,
		 QTY_COMPLETED= c_rec.QTY_COMPLETED,
		 SCHEDULE_GROUP_NAME= c_rec.SCHEDULE_GROUP_NAME,
		 WIP_STATUS_CODE= c_rec.WIP_STATUS_CODE,
		 WIP_SUPPLY_TYPE= c_rec.WIP_SUPPLY_TYPE,
		 NON_NETTABLE_QTY=c_rec.NON_NETTABLE_QTY,
		 LOT_NUMBER= c_rec.LOT_NUMBER,
		 DEMAND_CLASS= c_rec.DEMAND_CLASS,
		 REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
		 LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
		 LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user,
		 COPRODUCTS_SUPPLY = c_rec.COPRODUCTS_SUPPLY,
		 /* ds change start */
		 REQUESTED_START_DATE = c_rec.REQUESTED_START_DATE,
		 REQUESTED_COMPLETION_DATE = c_rec.REQUESTED_COMPLETION_DATE,
		 SCHEDULE_PRIORITY = c_rec.SCHEDULE_PRIORITY,
		 ASSET_SERIAL_NUMBER = c_rec.ASSET_SERIAL_NUMBER,
		 ASSET_ITEM_ID = c_rec.ASSET_ITEM_ID,
		/* ds change end */
		 ACTUAL_START_DATE = c_rec.ACTUAL_START_DATE,  /* Discrete Mfg Enahancements Bug 4479276 */
		 CFM_ROUTING_FLAG  = c_rec.CFM_ROUTING_FLAG,
		  RO_CREATION_DATE =c_rec.RO_CREATION_DATE,
		  REPAIR_LEAD_TIME= c_rec.REPAIR_LEAD_TIME,
          MAINTENANCE_OBJECT_SOURCE = c_rec.MAINTENANCE_OBJECT_SOURCE,
          DESCRIPTION = c_rec.DESCRIPTION
		WHERE PLAN_ID= -1
		  AND SR_INSTANCE_ID= c_rec.SR_INSTANCE_ID
		  AND ORDER_TYPE= c_rec.ORDER_TYPE
		  AND DISPOSITION_ID= c_rec.DISPOSITION_ID
		  AND ORGANIZATION_ID = c_rec.ORGANIZATION_ID;

		--=================== WIP DISCRETE JOB COMPONENT SUPPLIES =====================
		ELSIF (MSC_CL_COLLECTION.v_is_incremental_refresh and c_rec.ORDER_TYPE IN (14,15)) or
		      (MSC_CL_COLLECTION.v_is_cont_refresh and (c_rec.ORDER_TYPE IN (14,15)) and
		        (MSC_CL_COLLECTION.v_coll_prec.wip_sn_flag = MSC_UTIL.SYS_INCR)) THEN          -- DISCRETE JOB COMPONENT

		MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'load_supply: upd WIP DSC JOB');


		/* ATP SUMMARY CHANGES Added the OLD_**** Columns */
		UPDATE MSC_SUPPLIES
		SET
		 OLD_DAILY_RATE= DAILY_RATE,
		 OLD_FIRST_UNIT_START_DATE= FIRST_UNIT_START_DATE,
		 OLD_LAST_UNIT_COMPLETION_DATE= LAST_UNIT_COMPLETION_DATE,
		 OLD_NEW_SCHEDULE_DATE= NEW_SCHEDULE_DATE,
		 OLD_QTY_COMPLETED= QTY_COMPLETED,
		 OLD_NEW_ORDER_QUANTITY= decode(REFRESH_NUMBER,MSC_CL_COLLECTION.v_last_collection_id,OLD_NEW_ORDER_QUANTITY,NEW_ORDER_QUANTITY),
		 OLD_FIRM_QUANTITY= FIRM_QUANTITY,
		 OLD_FIRM_DATE= FIRM_DATE,
		 ORGANIZATION_ID= c_rec.ORGANIZATION_ID,
		 REVISION= c_rec.REVISION,
		 UNIT_NUMBER= c_rec.UNIT_NUMBER,
		 NEW_SCHEDULE_DATE=lv_schedule_date,
		 OLD_SCHEDULE_DATE= c_rec.OLD_SCHEDULE_DATE,
		 NEW_WIP_START_DATE= c_rec.NEW_WIP_START_DATE,
		 OLD_WIP_START_DATE= c_rec.OLD_WIP_START_DATE,
		 FIRST_UNIT_COMPLETION_DATE= c_rec.FIRST_UNIT_COMPLETION_DATE,
		 LAST_UNIT_COMPLETION_DATE= c_rec.LAST_UNIT_COMPLETION_DATE,
		 FIRST_UNIT_START_DATE= c_rec.FIRST_UNIT_START_DATE,
		 LAST_UNIT_START_DATE= c_rec.LAST_UNIT_START_DATE,
		 DISPOSITION_ID= c_rec.DISPOSITION_ID,
		 DISPOSITION_STATUS_TYPE= c_rec.DISPOSITION_STATUS_TYPE,
		 NEW_ORDER_QUANTITY= c_rec.NEW_ORDER_QUANTITY,
		 OLD_ORDER_QUANTITY= c_rec.OLD_ORDER_QUANTITY,
		 QUANTITY_PER_ASSEMBLY=c_rec.QUANTITY_PER_ASSEMBLY,
		 QUANTITY_ISSUED=c_rec.QUANTITY_ISSUED,
		 DAILY_RATE= c_rec.DAILY_RATE,
		 NEW_ORDER_PLACEMENT_DATE= c_rec.NEW_ORDER_PLACEMENT_DATE,
		 OLD_ORDER_PLACEMENT_DATE= c_rec.OLD_ORDER_PLACEMENT_DATE,
		 RESCHEDULE_DAYS= c_rec.RESCHEDULE_DAYS,
		 RESCHEDULE_FLAG= c_rec.RESCHEDULE_FLAG,
		 SCHEDULE_COMPRESS_DAYS= c_rec.SCHEDULE_COMPRESS_DAYS,
		 NEW_PROCESSING_DAYS= c_rec.NEW_PROCESSING_DAYS,
		 PURCH_LINE_NUM= c_rec.PURCH_LINE_NUM,
		 PO_LINE_ID= c_rec.PO_LINE_ID,
		 QUANTITY_IN_PROCESS= c_rec.QUANTITY_IN_PROCESS,
		 IMPLEMENTED_QUANTITY= c_rec.IMPLEMENTED_QUANTITY,
		 FIRM_PLANNED_TYPE= c_rec.FIRM_PLANNED_TYPE,
		 FIRM_QUANTITY= c_rec.FIRM_QUANTITY,
		 FIRM_DATE= c_rec.FIRM_DATE,
		 RELEASE_STATUS= c_rec.RELEASE_STATUS,
		 LOAD_TYPE= c_rec.LOAD_TYPE,
		 PROCESS_SEQ_ID= c_rec.PROCESS_SEQ_ID,
		 SCO_SUPPLY_FLAG= c_rec.SCO_SUPPLY_FLAG,
		 ALTERNATE_BOM_DESIGNATOR= c_rec.ALTERNATE_BOM_DESIGNATOR,
		 ALTERNATE_ROUTING_DESIGNATOR= c_rec.ALTERNATE_ROUTING_DESIGNATOR,
		 BY_PRODUCT_USING_ASSY_ID= c_rec.BY_PRODUCT_USING_ASSY_ID,
		 SOURCE_ORGANIZATION_ID= c_rec.SOURCE_ORGANIZATION_ID,
		 SOURCE_SR_INSTANCE_ID= c_rec.SOURCE_SR_INSTANCE_ID,
		 SOURCE_SUPPLIER_SITE_ID= c_rec.SOURCE_SUPPLIER_SITE_ID,
		 SOURCE_SUPPLIER_ID= c_rec.SOURCE_SUPPLIER_ID,
		 SHIP_METHOD= c_rec.SHIP_METHOD,
		 WEIGHT_CAPACITY_USED= c_rec.WEIGHT_CAPACITY_USED,
		 VOLUME_CAPACITY_USED= c_rec.VOLUME_CAPACITY_USED,
		 NEW_SHIP_DATE= c_rec.NEW_SHIP_DATE,
		 NEW_DOCK_DATE= lv_dock_date,
		 LINE_ID= c_rec.LINE_ID,
		 PROJECT_ID= c_rec.PROJECT_ID,
		 TASK_ID= c_rec.TASK_ID,
		 PLANNING_GROUP= c_rec.PLANNING_GROUP,
		 NUMBER1= c_rec.NUMBER1,
		 SOURCE_ITEM_ID= c_rec.SOURCE_ITEM_ID,
		 ORDER_NUMBER= c_rec.ORDER_NUMBER,
		 SCHEDULE_GROUP_ID= c_rec.SCHEDULE_GROUP_ID,
		 BUILD_SEQUENCE= c_rec.BUILD_SEQUENCE,
		 WIP_ENTITY_NAME= c_rec.WIP_ENTITY_NAME,
		 IMPLEMENT_PROCESSING_DAYS= c_rec.IMPLEMENT_PROCESSING_DAYS,
		 DELIVERY_PRICE= c_rec.DELIVERY_PRICE,
		 LATE_SUPPLY_DATE= c_rec.LATE_SUPPLY_DATE,
		 LATE_SUPPLY_QTY= c_rec.LATE_SUPPLY_QTY,
		 SUBINVENTORY_CODE= c_rec.SUBINVENTORY_CODE,
		 SUPPLIER_ID= c_rec.SUPPLIER_ID,
		 SUPPLIER_SITE_ID= c_rec.SUPPLIER_SITE_ID,
		 EXPECTED_SCRAP_QTY= c_rec.EXPECTED_SCRAP_QTY,
		 QTY_SCRAPPED= c_rec.QTY_SCRAPPED,
		 QTY_COMPLETED= c_rec.QTY_COMPLETED,
		 SCHEDULE_GROUP_NAME= c_rec.SCHEDULE_GROUP_NAME,
		 WIP_STATUS_CODE= c_rec.WIP_STATUS_CODE,
		 WIP_SUPPLY_TYPE= c_rec.WIP_SUPPLY_TYPE,
		 NON_NETTABLE_QTY=c_rec.NON_NETTABLE_QTY,
		 LOT_NUMBER= c_rec.LOT_NUMBER,
		 DEMAND_CLASS= c_rec.DEMAND_CLASS,
		 REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
		 LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
		 LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user,
		 COPRODUCTS_SUPPLY = c_rec.COPRODUCTS_SUPPLY,
		 /* ds change start */
		 REQUESTED_START_DATE = c_rec.REQUESTED_START_DATE,
		 REQUESTED_COMPLETION_DATE = c_rec.REQUESTED_COMPLETION_DATE,
		 SCHEDULE_PRIORITY = c_rec.SCHEDULE_PRIORITY,
		 ASSET_SERIAL_NUMBER = c_rec.ASSET_SERIAL_NUMBER,
		 ASSET_ITEM_ID = c_rec.ASSET_ITEM_ID,
		 /* ds change end */
		  RO_CREATION_DATE =c_rec.RO_CREATION_DATE,
		  REPAIR_LEAD_TIME= c_rec.REPAIR_LEAD_TIME

		WHERE PLAN_ID= -1
		  AND SR_INSTANCE_ID= c_rec.SR_INSTANCE_ID
		  AND ORDER_TYPE= c_rec.ORDER_TYPE
		  AND DISPOSITION_ID= c_rec.DISPOSITION_ID
		  AND INVENTORY_ITEM_ID= c_rec.INVENTORY_ITEM_ID
		  AND OPERATION_SEQ_NUM= c_rec.OPERATION_SEQ_NUM
		  AND ORGANIZATION_ID = c_rec.ORGANIZATION_ID;

		--=================== REPETITIVE ITEM SUPPLIES =====================
		ELSIF (MSC_CL_COLLECTION.v_is_incremental_refresh and c_rec.ORDER_TYPE= 30) or
		      (MSC_CL_COLLECTION.v_is_cont_refresh and (c_rec.ORDER_TYPE = 30) and
		        (MSC_CL_COLLECTION.v_coll_prec.wip_sn_flag = MSC_UTIL.SYS_INCR)) THEN                  -- REPT ITEM

		MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'load_supply: upd REPT ITEMS');

		/* ATP SUMMARY CHANGES Added the OLD_**** Columns */
		UPDATE MSC_SUPPLIES
		SET
		 OLD_DAILY_RATE= DAILY_RATE,
		 OLD_FIRST_UNIT_START_DATE= FIRST_UNIT_START_DATE,
		 OLD_LAST_UNIT_COMPLETION_DATE= LAST_UNIT_COMPLETION_DATE,
		 OLD_NEW_SCHEDULE_DATE= NEW_SCHEDULE_DATE,
		 OLD_QTY_COMPLETED= QTY_COMPLETED,
		 OLD_NEW_ORDER_QUANTITY= decode(REFRESH_NUMBER,MSC_CL_COLLECTION.v_last_collection_id,OLD_NEW_ORDER_QUANTITY,NEW_ORDER_QUANTITY),
		 OLD_FIRM_QUANTITY= FIRM_QUANTITY,
		 OLD_FIRM_DATE= FIRM_DATE,
		 INVENTORY_ITEM_ID= c_rec.INVENTORY_ITEM_ID,
		 ORGANIZATION_ID= c_rec.ORGANIZATION_ID,
		 REVISION= c_rec.REVISION,
		 UNIT_NUMBER= c_rec.UNIT_NUMBER,
		 NEW_SCHEDULE_DATE=lv_schedule_date,
		 OLD_SCHEDULE_DATE= c_rec.OLD_SCHEDULE_DATE,
		 NEW_WIP_START_DATE= c_rec.NEW_WIP_START_DATE,
		 OLD_WIP_START_DATE= c_rec.OLD_WIP_START_DATE,
		 FIRST_UNIT_COMPLETION_DATE= c_rec.FIRST_UNIT_COMPLETION_DATE,
		 LAST_UNIT_COMPLETION_DATE= c_rec.LAST_UNIT_COMPLETION_DATE,
		 FIRST_UNIT_START_DATE= c_rec.FIRST_UNIT_START_DATE,
		 LAST_UNIT_START_DATE= c_rec.LAST_UNIT_START_DATE,
		 DISPOSITION_STATUS_TYPE= c_rec.DISPOSITION_STATUS_TYPE,
		 NEW_ORDER_QUANTITY= c_rec.NEW_ORDER_QUANTITY,
		 OLD_ORDER_QUANTITY= c_rec.OLD_ORDER_QUANTITY,
		 DAILY_RATE= c_rec.DAILY_RATE,
		 NEW_ORDER_PLACEMENT_DATE= c_rec.NEW_ORDER_PLACEMENT_DATE,
		 OLD_ORDER_PLACEMENT_DATE= c_rec.OLD_ORDER_PLACEMENT_DATE,
		 RESCHEDULE_DAYS= c_rec.RESCHEDULE_DAYS,
		 RESCHEDULE_FLAG= c_rec.RESCHEDULE_FLAG,
		 SCHEDULE_COMPRESS_DAYS= c_rec.SCHEDULE_COMPRESS_DAYS,
		 NEW_PROCESSING_DAYS= c_rec.NEW_PROCESSING_DAYS,
		 PURCH_LINE_NUM= c_rec.PURCH_LINE_NUM,
		 PO_LINE_ID= c_rec.PO_LINE_ID,
		 QUANTITY_IN_PROCESS= c_rec.QUANTITY_IN_PROCESS,
		 IMPLEMENTED_QUANTITY= c_rec.IMPLEMENTED_QUANTITY,
		 FIRM_PLANNED_TYPE= c_rec.FIRM_PLANNED_TYPE,
		 FIRM_QUANTITY= c_rec.FIRM_QUANTITY,
		 FIRM_DATE= c_rec.FIRM_DATE,
		 RELEASE_STATUS= c_rec.RELEASE_STATUS,
		 LOAD_TYPE= c_rec.LOAD_TYPE,
		 PROCESS_SEQ_ID= c_rec.PROCESS_SEQ_ID,
		 SCO_SUPPLY_FLAG= c_rec.SCO_SUPPLY_FLAG,
		 ALTERNATE_BOM_DESIGNATOR= c_rec.ALTERNATE_BOM_DESIGNATOR,
		 ALTERNATE_ROUTING_DESIGNATOR= c_rec.ALTERNATE_ROUTING_DESIGNATOR,
		 BY_PRODUCT_USING_ASSY_ID= c_rec.BY_PRODUCT_USING_ASSY_ID,
		 SOURCE_ORGANIZATION_ID= c_rec.SOURCE_ORGANIZATION_ID,
		 SOURCE_SR_INSTANCE_ID= c_rec.SOURCE_SR_INSTANCE_ID,
		 SOURCE_SUPPLIER_SITE_ID= c_rec.SOURCE_SUPPLIER_SITE_ID,
		 SOURCE_SUPPLIER_ID= c_rec.SOURCE_SUPPLIER_ID,
		 SHIP_METHOD= c_rec.SHIP_METHOD,
		 WEIGHT_CAPACITY_USED= c_rec.WEIGHT_CAPACITY_USED,
		 VOLUME_CAPACITY_USED= c_rec.VOLUME_CAPACITY_USED,
		 NEW_SHIP_DATE= c_rec.NEW_SHIP_DATE,
		 NEW_DOCK_DATE= lv_dock_date,
		 LINE_ID= c_rec.LINE_ID,
		 PROJECT_ID= c_rec.PROJECT_ID,
		 TASK_ID= c_rec.TASK_ID,
		 PLANNING_GROUP= c_rec.PLANNING_GROUP,
		 NUMBER1= c_rec.NUMBER1,
		 SOURCE_ITEM_ID= c_rec.SOURCE_ITEM_ID,
		 ORDER_NUMBER= c_rec.ORDER_NUMBER,
		 SCHEDULE_GROUP_ID= c_rec.SCHEDULE_GROUP_ID,
		 BUILD_SEQUENCE= c_rec.BUILD_SEQUENCE,
		 WIP_ENTITY_NAME= c_rec.WIP_ENTITY_NAME,
		 IMPLEMENT_PROCESSING_DAYS= c_rec.IMPLEMENT_PROCESSING_DAYS,
		 DELIVERY_PRICE= c_rec.DELIVERY_PRICE,
		 LATE_SUPPLY_DATE= c_rec.LATE_SUPPLY_DATE,
		 LATE_SUPPLY_QTY= c_rec.LATE_SUPPLY_QTY,
		 SUBINVENTORY_CODE= c_rec.SUBINVENTORY_CODE,
		 SUPPLIER_ID= c_rec.SUPPLIER_ID,
		 SUPPLIER_SITE_ID= c_rec.SUPPLIER_SITE_ID,
		 EXPECTED_SCRAP_QTY= c_rec.EXPECTED_SCRAP_QTY,
		 QTY_SCRAPPED= c_rec.QTY_SCRAPPED,
		 QTY_COMPLETED= c_rec.QTY_COMPLETED,
		 SCHEDULE_GROUP_NAME= c_rec.SCHEDULE_GROUP_NAME,
		 WIP_STATUS_CODE= c_rec.WIP_STATUS_CODE,
		 WIP_SUPPLY_TYPE= c_rec.WIP_SUPPLY_TYPE,
		 LOT_NUMBER= c_rec.LOT_NUMBER,
		 DEMAND_CLASS= c_rec.DEMAND_CLASS,
		 REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
		 LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
		 LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user,
		 COPRODUCTS_SUPPLY = c_rec.COPRODUCTS_SUPPLY,
		 RO_CREATION_DATE =c_rec.RO_CREATION_DATE,
		  REPAIR_LEAD_TIME= c_rec.REPAIR_LEAD_TIME
		WHERE PLAN_ID= -1
		  AND SR_INSTANCE_ID= c_rec.SR_INSTANCE_ID
		  AND ORDER_TYPE= c_rec.ORDER_TYPE
		  AND DISPOSITION_ID= c_rec.DISPOSITION_ID
		  AND ORGANIZATION_ID = c_rec.ORGANIZATION_ID;

		--=================== ONHAND SUPPLIES =====================
		ELSIF (MSC_CL_COLLECTION.v_is_incremental_refresh and c_rec.ORDER_TYPE= 18) or
		      (MSC_CL_COLLECTION.v_is_cont_refresh and (c_rec.ORDER_TYPE = 18) and
		        (MSC_CL_COLLECTION.v_coll_prec.oh_sn_flag = MSC_UTIL.SYS_INCR)) THEN                  -- ONHAND


		MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'load_supply: upd OH');


		/* ATP SUMMARY CHANGES Added the OLD_**** Columns */
		UPDATE MSC_SUPPLIES
		SET
		 OLD_DAILY_RATE= DAILY_RATE,
		 OLD_FIRST_UNIT_START_DATE= FIRST_UNIT_START_DATE,
		 OLD_LAST_UNIT_COMPLETION_DATE= LAST_UNIT_COMPLETION_DATE,
		 OLD_NEW_SCHEDULE_DATE= NEW_SCHEDULE_DATE,
		 OLD_QTY_COMPLETED= QTY_COMPLETED,
		 OLD_NEW_ORDER_QUANTITY= decode(REFRESH_NUMBER,MSC_CL_COLLECTION.v_last_collection_id,OLD_NEW_ORDER_QUANTITY,NEW_ORDER_QUANTITY),
		 OLD_FIRM_QUANTITY= FIRM_QUANTITY,
		 OLD_FIRM_DATE= FIRM_DATE,
		 NEW_ORDER_QUANTITY= c_rec.NEW_ORDER_QUANTITY,
		 NEW_SCHEDULE_DATE=lv_schedule_date,
		 FIRM_PLANNED_TYPE= c_rec.FIRM_PLANNED_TYPE,
		 PLANNING_GROUP= c_rec.PLANNING_GROUP,
		 EXPIRATION_DATE= c_rec.EXPIRATION_DATE,
		 DEMAND_CLASS= c_rec.DEMAND_CLASS,
		 PLANNING_PARTNER_SITE_ID=c_rec.PLANNING_PARTNER_SITE_ID,
		 PLANNING_TP_TYPE=c_rec.PLANNING_TP_TYPE,
		 OWNING_PARTNER_SITE_ID=c_rec.OWNING_PARTNER_SITE_ID,
		 OWNING_TP_TYPE=c_rec.OWNING_TP_TYPE,
		 VMI_FLAG=c_rec.VMI_FLAG,
		 REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
		 LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
		 LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user,
		 COPRODUCTS_SUPPLY = c_rec.COPRODUCTS_SUPPLY,
		 SR_CUSTOMER_ACCT_ID=c_rec.SR_CUSTOMER_ACCT_ID,
		 ITEM_TYPE_VALUE=c_rec.ITEM_TYPE_VALUE,
		 ITEM_TYPE_ID=c_rec.ITEM_TYPE_ID,
		 RO_CREATION_DATE =c_rec.RO_CREATION_DATE,
		  REPAIR_LEAD_TIME= c_rec.REPAIR_LEAD_TIME
		WHERE PLAN_ID= -1
		  AND SR_INSTANCE_ID= c_rec.SR_INSTANCE_ID
		  AND ORDER_TYPE= c_rec.ORDER_TYPE
		  AND INVENTORY_ITEM_ID= c_rec.INVENTORY_ITEM_ID
		  AND ORGANIZATION_ID= c_rec.ORGANIZATION_ID
		  AND NVL(SUBINVENTORY_CODE, MSC_UTIL.NULL_CHAR)= NVL( c_rec.SUBINVENTORY_CODE, MSC_UTIL.NULL_CHAR)
		  AND NVL(LOT_NUMBER, MSC_UTIL.NULL_CHAR)= NVL( c_rec.LOT_NUMBER, MSC_UTIL.NULL_CHAR)
		  AND NVL(PROJECT_ID, MSC_UTIL.NULL_VALUE)= NVL( c_rec.PROJECT_ID, MSC_UTIL.NULL_VALUE)
		  AND NVL(TASK_ID, MSC_UTIL.NULL_VALUE)= NVL( c_rec.TASK_ID, MSC_UTIL.NULL_VALUE)
		  AND NVL(UNIT_NUMBER, MSC_UTIL.NULL_CHAR)= NVL( c_rec.UNIT_NUMBER,MSC_UTIL.NULL_CHAR)
		  AND NVL(OWNING_PARTNER_SITE_ID,MSC_UTIL.NULL_VALUE)= NVL(c_rec.OWNING_PARTNER_SITE_ID,MSC_UTIL.NULL_VALUE)
		  AND NVL(OWNING_TP_TYPE,MSC_UTIL.NULL_VALUE)= NVL(c_rec.OWNING_TP_TYPE,MSC_UTIL.NULL_VALUE)
		  AND NVL(PLANNING_PARTNER_SITE_ID,MSC_UTIL.NULL_VALUE)= NVL(c_rec.PLANNING_PARTNER_SITE_ID,MSC_UTIL.NULL_VALUE)
		  AND NVL(PLANNING_TP_TYPE,MSC_UTIL.NULL_VALUE)= NVL(c_rec.PLANNING_TP_TYPE,MSC_UTIL.NULL_VALUE);

		--=================== MPS SUPPLIES =====================
		ELSIF (MSC_CL_COLLECTION.v_is_incremental_refresh and c_rec.ORDER_TYPE= 5) or
		      (MSC_CL_COLLECTION.v_is_cont_refresh and (c_rec.ORDER_TYPE = 5) and
		        (MSC_CL_COLLECTION.v_coll_prec.mps_sn_flag = MSC_UTIL.SYS_INCR)) THEN                   -- MPS

		MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'load_supply: upd MPS');


		/* ATP SUMMARY CHANGES Added the OLD_**** Columns */
		UPDATE MSC_SUPPLIES
		SET
		 OLD_DAILY_RATE= DAILY_RATE,
		 OLD_FIRST_UNIT_START_DATE= FIRST_UNIT_START_DATE,
		 OLD_LAST_UNIT_COMPLETION_DATE= LAST_UNIT_COMPLETION_DATE,
		 OLD_NEW_SCHEDULE_DATE= NEW_SCHEDULE_DATE,
		 OLD_QTY_COMPLETED= QTY_COMPLETED,
		 OLD_NEW_ORDER_QUANTITY= decode(REFRESH_NUMBER,MSC_CL_COLLECTION.v_last_collection_id,OLD_NEW_ORDER_QUANTITY,NEW_ORDER_QUANTITY),
		 OLD_FIRM_QUANTITY= FIRM_QUANTITY,
		 OLD_FIRM_DATE= FIRM_DATE,
		 INVENTORY_ITEM_ID= c_rec.INVENTORY_ITEM_ID,
		 ORGANIZATION_ID= c_rec.ORGANIZATION_ID,
		 SCHEDULE_DESIGNATOR_ID= c_rec.SCHEDULE_DESIGNATOR_ID,
		 REVISION= c_rec.REVISION,
		 UNIT_NUMBER= c_rec.UNIT_NUMBER,
		 NEW_SCHEDULE_DATE=lv_schedule_date,
		 OLD_SCHEDULE_DATE= c_rec.OLD_SCHEDULE_DATE,
		 NEW_WIP_START_DATE= c_rec.NEW_WIP_START_DATE,
		 OLD_WIP_START_DATE= c_rec.OLD_WIP_START_DATE,
		 FIRST_UNIT_COMPLETION_DATE= c_rec.FIRST_UNIT_COMPLETION_DATE,
		 LAST_UNIT_COMPLETION_DATE= c_rec.LAST_UNIT_COMPLETION_DATE,
		 FIRST_UNIT_START_DATE= c_rec.FIRST_UNIT_START_DATE,
		 LAST_UNIT_START_DATE= c_rec.LAST_UNIT_START_DATE,
		 DISPOSITION_STATUS_TYPE= c_rec.DISPOSITION_STATUS_TYPE,
		 NEW_ORDER_QUANTITY= c_rec.NEW_ORDER_QUANTITY,
		 OLD_ORDER_QUANTITY= c_rec.OLD_ORDER_QUANTITY,
		 DAILY_RATE= c_rec.DAILY_RATE,
		 NEW_ORDER_PLACEMENT_DATE= c_rec.NEW_ORDER_PLACEMENT_DATE,
		 OLD_ORDER_PLACEMENT_DATE= c_rec.OLD_ORDER_PLACEMENT_DATE,
		 RESCHEDULE_DAYS= c_rec.RESCHEDULE_DAYS,
		 RESCHEDULE_FLAG= c_rec.RESCHEDULE_FLAG,
		 SCHEDULE_COMPRESS_DAYS= c_rec.SCHEDULE_COMPRESS_DAYS,
		 NEW_PROCESSING_DAYS= c_rec.NEW_PROCESSING_DAYS,
		 PURCH_LINE_NUM= c_rec.PURCH_LINE_NUM,
		 PO_LINE_ID= c_rec.PO_LINE_ID,
		 QUANTITY_IN_PROCESS= c_rec.QUANTITY_IN_PROCESS,
		 IMPLEMENTED_QUANTITY= c_rec.IMPLEMENTED_QUANTITY,
		 FIRM_PLANNED_TYPE= c_rec.FIRM_PLANNED_TYPE,
		 FIRM_QUANTITY= c_rec.FIRM_QUANTITY,
		 FIRM_DATE= c_rec.FIRM_DATE,
		 RELEASE_STATUS= c_rec.RELEASE_STATUS,
		 LOAD_TYPE= c_rec.LOAD_TYPE,
		 PROCESS_SEQ_ID= c_rec.PROCESS_SEQ_ID,
		 SCO_SUPPLY_FLAG= c_rec.SCO_SUPPLY_FLAG,
		 ALTERNATE_BOM_DESIGNATOR= c_rec.ALTERNATE_BOM_DESIGNATOR,
		 ALTERNATE_ROUTING_DESIGNATOR= c_rec.ALTERNATE_ROUTING_DESIGNATOR,
		 OPERATION_SEQ_NUM= c_rec.OPERATION_SEQ_NUM,
		 WIP_START_QUANTITY = c_rec.WIP_START_QUANTITY,
		 BY_PRODUCT_USING_ASSY_ID= c_rec.BY_PRODUCT_USING_ASSY_ID,
		 SOURCE_ORGANIZATION_ID= c_rec.SOURCE_ORGANIZATION_ID,
		 SOURCE_SR_INSTANCE_ID= c_rec.SOURCE_SR_INSTANCE_ID,
		 SOURCE_SUPPLIER_SITE_ID= c_rec.SOURCE_SUPPLIER_SITE_ID,
		 SOURCE_SUPPLIER_ID= c_rec.SOURCE_SUPPLIER_ID,
		 SHIP_METHOD= c_rec.SHIP_METHOD,
		 WEIGHT_CAPACITY_USED= c_rec.WEIGHT_CAPACITY_USED,
		 VOLUME_CAPACITY_USED= c_rec.VOLUME_CAPACITY_USED,
		 NEW_SHIP_DATE= c_rec.NEW_SHIP_DATE,
		 NEW_DOCK_DATE= lv_dock_date,
		 LINE_ID= c_rec.LINE_ID,
		 PROJECT_ID= c_rec.PROJECT_ID,
		 TASK_ID= c_rec.TASK_ID,
		 PLANNING_GROUP= c_rec.PLANNING_GROUP,
		 NUMBER1= c_rec.NUMBER1,
		 SOURCE_ITEM_ID= c_rec.SOURCE_ITEM_ID,
		 ORDER_NUMBER= c_rec.ORDER_NUMBER,
		 SCHEDULE_GROUP_ID= c_rec.SCHEDULE_GROUP_ID,
		 BUILD_SEQUENCE= c_rec.BUILD_SEQUENCE,
		 WIP_ENTITY_NAME= c_rec.WIP_ENTITY_NAME,
		 IMPLEMENT_PROCESSING_DAYS= c_rec.IMPLEMENT_PROCESSING_DAYS,
		 DELIVERY_PRICE= c_rec.DELIVERY_PRICE,
		 LATE_SUPPLY_DATE= c_rec.LATE_SUPPLY_DATE,
		 LATE_SUPPLY_QTY= c_rec.LATE_SUPPLY_QTY,
		 SUBINVENTORY_CODE= c_rec.SUBINVENTORY_CODE,
		 SUPPLIER_ID= c_rec.SUPPLIER_ID,
		 SUPPLIER_SITE_ID= c_rec.SUPPLIER_SITE_ID,
		 EXPECTED_SCRAP_QTY= c_rec.EXPECTED_SCRAP_QTY,
		 QTY_SCRAPPED= c_rec.QTY_SCRAPPED,
		 QTY_COMPLETED= c_rec.QTY_COMPLETED,
		 SCHEDULE_GROUP_NAME= c_rec.SCHEDULE_GROUP_NAME,
		 LOT_NUMBER= c_rec.LOT_NUMBER,
		 DEMAND_CLASS= c_rec.DEMAND_CLASS,
		 REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
		 LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
		 LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user,
		 COPRODUCTS_SUPPLY = c_rec.COPRODUCTS_SUPPLY,
		 /* ds change start */
		 REQUESTED_START_DATE = c_rec.REQUESTED_START_DATE,
		 REQUESTED_COMPLETION_DATE = c_rec.REQUESTED_COMPLETION_DATE,
		 SCHEDULE_PRIORITY = c_rec.SCHEDULE_PRIORITY,
		 ASSET_SERIAL_NUMBER = c_rec.ASSET_SERIAL_NUMBER,
		 ASSET_ITEM_ID = c_rec.ASSET_ITEM_ID,
		/* ds change end */
		 ITEM_TYPE_ID = lv_ITEM_TYPE_ID,
		 ITEM_TYPE_VALUE = lv_ITEM_TYPE_VALUE,
		 RO_CREATION_DATE =c_rec.RO_CREATION_DATE,
		REPAIR_LEAD_TIME= c_rec.REPAIR_LEAD_TIME ,
		SCHEDULE_ORIGINATION_TYPE= c_rec.SCHEDULE_ORIGINATION_TYPE
		WHERE PLAN_ID= -1
		  AND SR_INSTANCE_ID= c_rec.SR_INSTANCE_ID
		  AND DISPOSITION_ID= c_rec.DISPOSITION_ID
		  AND ORDER_TYPE= c_rec.ORDER_TYPE
		  AND ORGANIZATION_ID = c_rec.ORGANIZATION_ID;

		--=================== USER DEFINED SUPPLIES =====================
		ELSIF (MSC_CL_COLLECTION.v_is_incremental_refresh and c_rec.ORDER_TYPE= 41) or
		      (MSC_CL_COLLECTION.v_is_cont_refresh and (c_rec.ORDER_TYPE = 41) and
		        (MSC_CL_COLLECTION.v_coll_prec.usup_sn_flag = MSC_UTIL.SYS_INCR)) THEN                  -- USER DEFINED

		MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'load_supply: upd USUP');


		/* ATP SUMMARY CHANGES Added the OLD_**** Columns */
		UPDATE MSC_SUPPLIES
		SET
		 OLD_DAILY_RATE= DAILY_RATE,
		 OLD_FIRST_UNIT_START_DATE= FIRST_UNIT_START_DATE,
		 OLD_LAST_UNIT_COMPLETION_DATE= LAST_UNIT_COMPLETION_DATE,
		 OLD_NEW_SCHEDULE_DATE= NEW_SCHEDULE_DATE,
		 OLD_QTY_COMPLETED= QTY_COMPLETED,
		 OLD_NEW_ORDER_QUANTITY= decode(REFRESH_NUMBER,MSC_CL_COLLECTION.v_last_collection_id,OLD_NEW_ORDER_QUANTITY,NEW_ORDER_QUANTITY),
		 OLD_FIRM_QUANTITY= FIRM_QUANTITY,
		 OLD_FIRM_DATE= FIRM_DATE,
		 INVENTORY_ITEM_ID= c_rec.INVENTORY_ITEM_ID,
		 ORGANIZATION_ID= c_rec.ORGANIZATION_ID,
		 SCHEDULE_DESIGNATOR_ID= c_rec.SCHEDULE_DESIGNATOR_ID,
		 REVISION= c_rec.REVISION,
		 UNIT_NUMBER= c_rec.UNIT_NUMBER,
		 NEW_SCHEDULE_DATE=lv_schedule_date,
		 OLD_SCHEDULE_DATE= c_rec.OLD_SCHEDULE_DATE,
		 NEW_WIP_START_DATE= c_rec.NEW_WIP_START_DATE,
		 OLD_WIP_START_DATE= c_rec.OLD_WIP_START_DATE,
		 FIRST_UNIT_COMPLETION_DATE= c_rec.FIRST_UNIT_COMPLETION_DATE,
		 LAST_UNIT_COMPLETION_DATE= c_rec.LAST_UNIT_COMPLETION_DATE,
		 FIRST_UNIT_START_DATE= c_rec.FIRST_UNIT_START_DATE,
		 LAST_UNIT_START_DATE= c_rec.LAST_UNIT_START_DATE,
		 DISPOSITION_STATUS_TYPE= c_rec.DISPOSITION_STATUS_TYPE,
		 NEW_ORDER_QUANTITY= c_rec.NEW_ORDER_QUANTITY,
		 OLD_ORDER_QUANTITY= c_rec.OLD_ORDER_QUANTITY,
		 NEW_ORDER_PLACEMENT_DATE= c_rec.NEW_ORDER_PLACEMENT_DATE,
		 OLD_ORDER_PLACEMENT_DATE= c_rec.OLD_ORDER_PLACEMENT_DATE,
		 RESCHEDULE_DAYS= c_rec.RESCHEDULE_DAYS,
		 RESCHEDULE_FLAG= c_rec.RESCHEDULE_FLAG,
		 SCHEDULE_COMPRESS_DAYS= c_rec.SCHEDULE_COMPRESS_DAYS,
		 NEW_PROCESSING_DAYS= c_rec.NEW_PROCESSING_DAYS,
		 PURCH_LINE_NUM= c_rec.PURCH_LINE_NUM,
		 PO_LINE_ID= c_rec.PO_LINE_ID,
		 QUANTITY_IN_PROCESS= c_rec.QUANTITY_IN_PROCESS,
		 IMPLEMENTED_QUANTITY= c_rec.IMPLEMENTED_QUANTITY,
		 FIRM_PLANNED_TYPE= c_rec.FIRM_PLANNED_TYPE,
		 FIRM_QUANTITY= c_rec.FIRM_QUANTITY,
		 FIRM_DATE= c_rec.FIRM_DATE,
		 RELEASE_STATUS= c_rec.RELEASE_STATUS,
		 LOAD_TYPE= c_rec.LOAD_TYPE,
		 PROCESS_SEQ_ID= c_rec.PROCESS_SEQ_ID,
		 SCO_SUPPLY_FLAG= c_rec.SCO_SUPPLY_FLAG,
		 ALTERNATE_BOM_DESIGNATOR= c_rec.ALTERNATE_BOM_DESIGNATOR,
		 ALTERNATE_ROUTING_DESIGNATOR= c_rec.ALTERNATE_ROUTING_DESIGNATOR,
		 OPERATION_SEQ_NUM= c_rec.OPERATION_SEQ_NUM,
		 WIP_START_QUANTITY = c_rec.WIP_START_QUANTITY,
		 BY_PRODUCT_USING_ASSY_ID= c_rec.BY_PRODUCT_USING_ASSY_ID,
		 SOURCE_ORGANIZATION_ID= c_rec.SOURCE_ORGANIZATION_ID,
		 SOURCE_SR_INSTANCE_ID= c_rec.SOURCE_SR_INSTANCE_ID,
		 SOURCE_SUPPLIER_SITE_ID= c_rec.SOURCE_SUPPLIER_SITE_ID,
		 SOURCE_SUPPLIER_ID= c_rec.SOURCE_SUPPLIER_ID,
		 SHIP_METHOD= c_rec.SHIP_METHOD,
		 WEIGHT_CAPACITY_USED= c_rec.WEIGHT_CAPACITY_USED,
		 VOLUME_CAPACITY_USED= c_rec.VOLUME_CAPACITY_USED,
		 NEW_SHIP_DATE= c_rec.NEW_SHIP_DATE,
		 NEW_DOCK_DATE=lv_dock_date,
		 LINE_ID= c_rec.LINE_ID,
		 PROJECT_ID= c_rec.PROJECT_ID,
		 TASK_ID= c_rec.TASK_ID,
		 PLANNING_GROUP= c_rec.PLANNING_GROUP,
		 NUMBER1= c_rec.NUMBER1,
		 SOURCE_ITEM_ID= c_rec.SOURCE_ITEM_ID,
		 ORDER_NUMBER= c_rec.ORDER_NUMBER,
		 SCHEDULE_GROUP_ID= c_rec.SCHEDULE_GROUP_ID,
		 BUILD_SEQUENCE= c_rec.BUILD_SEQUENCE,
		 WIP_ENTITY_NAME= c_rec.WIP_ENTITY_NAME,
		 IMPLEMENT_PROCESSING_DAYS= c_rec.IMPLEMENT_PROCESSING_DAYS,
		 DELIVERY_PRICE= c_rec.DELIVERY_PRICE,
		 LATE_SUPPLY_DATE= c_rec.LATE_SUPPLY_DATE,
		 LATE_SUPPLY_QTY= c_rec.LATE_SUPPLY_QTY,
		 SUBINVENTORY_CODE= c_rec.SUBINVENTORY_CODE,
		 SUPPLIER_ID= c_rec.SUPPLIER_ID,
		 SUPPLIER_SITE_ID= c_rec.SUPPLIER_SITE_ID,
		 EXPECTED_SCRAP_QTY= c_rec.EXPECTED_SCRAP_QTY,
		 QTY_SCRAPPED= c_rec.QTY_SCRAPPED,
		 QTY_COMPLETED= c_rec.QTY_COMPLETED,
		 SCHEDULE_GROUP_NAME= c_rec.SCHEDULE_GROUP_NAME,
		 LOT_NUMBER= c_rec.LOT_NUMBER,
		 DEMAND_CLASS= c_rec.DEMAND_CLASS,
		 REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
		 LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
		 LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user,
		 COPRODUCTS_SUPPLY = c_rec.COPRODUCTS_SUPPLY,
		 RO_CREATION_DATE =c_rec.RO_CREATION_DATE,
		  REPAIR_LEAD_TIME= c_rec.REPAIR_LEAD_TIME
		WHERE PLAN_ID= -1
		  AND SR_INSTANCE_ID= c_rec.SR_INSTANCE_ID
		  AND DISPOSITION_ID= c_rec.DISPOSITION_ID
		  AND ORDER_TYPE= c_rec.ORDER_TYPE
		  AND ORGANIZATION_ID = c_rec.ORGANIZATION_ID;

		END IF;  -- ORDER_TYPE

		END IF;  -- refresh mode

		IF MSC_CL_COLLECTION.v_is_complete_refresh OR
		   SQL%NOTFOUND             OR
		   c_rec.SR_MTL_SUPPLY_ID= -1    THEN
		if(SQL%NOTFOUND) Then
		   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Load supply: not found:' || c_rec.SR_MTL_SUPPLY_ID);
		end if;

		EXECUTE IMMEDIATE lv_sql_stmt
		USING c_rec.INVENTORY_ITEM_ID,
		  c_rec.ORGANIZATION_ID,
		  c_rec.FROM_ORGANIZATION_ID,
		  c_rec.SR_INSTANCE_ID,
		  c_rec.SCHEDULE_DESIGNATOR_ID,
		  c_rec.REVISION,
		  c_rec.UNIT_NUMBER,
		  --c_rec.NEW_SCHEDULE_DATE,
		  lv_schedule_date,
		  /* CP-ACK starts */
		  c_rec.ORDER_TYPE,
		  --c_rec.NEW_SCHEDULE_DATE,
		  lv_schedule_date,
		  c_rec.OLD_SCHEDULE_DATE,
		  /* CP-ACK starts */
		  c_rec.NEW_WIP_START_DATE,
		  c_rec.OLD_WIP_START_DATE,
		  c_rec.FIRST_UNIT_COMPLETION_DATE,
		  c_rec.LAST_UNIT_COMPLETION_DATE,
		  c_rec.FIRST_UNIT_START_DATE,
		  c_rec.LAST_UNIT_START_DATE,
		  c_rec.DISPOSITION_ID,
		  c_rec.DISPOSITION_STATUS_TYPE,
		  c_rec.ORDER_TYPE,
		  c_rec.NEW_ORDER_QUANTITY,
		  c_rec.OLD_ORDER_QUANTITY,
		  c_rec.QUANTITY_PER_ASSEMBLY,
		  c_rec.QUANTITY_ISSUED,
		  c_rec.DAILY_RATE,
		  c_rec.NEW_ORDER_PLACEMENT_DATE,
		  c_rec.OLD_ORDER_PLACEMENT_DATE,
		  c_rec.RESCHEDULE_DAYS,
		  c_rec.RESCHEDULE_FLAG,
		  c_rec.SCHEDULE_COMPRESS_DAYS,
		  c_rec.NEW_PROCESSING_DAYS,
		  c_rec.PURCH_LINE_NUM,
		  c_rec.PO_LINE_ID,
		  c_rec.QUANTITY_IN_PROCESS,
		  c_rec.IMPLEMENTED_QUANTITY,
		  c_rec.FIRM_PLANNED_TYPE,
		  c_rec.FIRM_QUANTITY,
		  c_rec.FIRM_DATE,
		  c_rec.RELEASE_STATUS,
		  c_rec.LOAD_TYPE,
		  c_rec.PROCESS_SEQ_ID,
		  c_rec.bill_sequence_id,
		  c_rec.routing_sequence_id,
		  c_rec.SCO_SUPPLY_FLAG,
		  c_rec.ALTERNATE_BOM_DESIGNATOR,
		  c_rec.ALTERNATE_ROUTING_DESIGNATOR,
		  c_rec.OPERATION_SEQ_NUM,
		  c_rec.JUMP_OP_SEQ_NUM,
		  c_rec.JOB_OP_SEQ_NUM,
		  c_rec.WIP_START_QUANTITY,
		  c_rec.BY_PRODUCT_USING_ASSY_ID,
		  c_rec.SOURCE_ORGANIZATION_ID,
		  c_rec.SOURCE_SR_INSTANCE_ID,
		  c_rec.SOURCE_SUPPLIER_SITE_ID,
		  c_rec.SOURCE_SUPPLIER_ID,
		  c_rec.SHIP_METHOD,
		  c_rec.WEIGHT_CAPACITY_USED,
		  c_rec.VOLUME_CAPACITY_USED,
		  c_rec.NEW_SHIP_DATE,
		  --c_rec.NEW_DOCK_DATE,
		  lv_dock_date,
		  c_rec.LINE_ID,
		  c_rec.PROJECT_ID,
		  c_rec.TASK_ID,
		  c_rec.PLANNING_GROUP,
		  c_rec.NUMBER1,
		  c_rec.SOURCE_ITEM_ID,
		  c_rec.ORDER_NUMBER,
		  c_rec.SCHEDULE_GROUP_ID,
		  c_rec.BUILD_SEQUENCE,
		  c_rec.WIP_ENTITY_NAME,
		  c_rec.IMPLEMENT_PROCESSING_DAYS,
		  c_rec.DELIVERY_PRICE,
		  c_rec.LATE_SUPPLY_DATE,
		  c_rec.LATE_SUPPLY_QTY,
		  c_rec.SUBINVENTORY_CODE,
		  c_rec.SUPPLIER_ID,
		  c_rec.SUPPLIER_SITE_ID,
		  c_rec.EXPECTED_SCRAP_QTY,
		  c_rec.QTY_SCRAPPED,
		  c_rec.QTY_COMPLETED,
		  c_rec.WIP_STATUS_CODE,
		  c_rec.WIP_SUPPLY_TYPE,
		  c_rec.NON_NETTABLE_QTY,
		  c_rec.SCHEDULE_GROUP_NAME,
		  c_rec.LOT_NUMBER,
		  c_rec.EXPIRATION_DATE,
		  c_rec.DEMAND_CLASS,
		  c_rec.PLANNING_PARTNER_SITE_ID,
		  c_rec.PLANNING_TP_TYPE,
		  c_rec.OWNING_PARTNER_SITE_ID,
		  c_rec.OWNING_TP_TYPE,
		  c_rec.VMI_FLAG,
		  c_rec.PO_LINE_LOCATION_ID,
		  c_rec.PO_DISTRIBUTION_ID,
		  c_rec.SR_MTL_SUPPLY_ID,
		  MSC_CL_COLLECTION.v_last_collection_id,
		  MSC_CL_COLLECTION.v_current_date,
		  MSC_CL_COLLECTION.v_current_user,
		  MSC_CL_COLLECTION.v_current_date,
		  MSC_CL_COLLECTION.v_current_user,
		  /* CP-ACK starts */
		  c_rec.ORIGINAL_NEED_BY_DATE,
		  c_rec.ORIGINAL_QUANTITY,
		  c_rec.PROMISED_DATE,
		  c_rec.NEED_BY_DATE,
		  c_rec.ACCEPTANCE_REQUIRED_FLAG,
		  /* CP-ACK stops */
		  c_rec.COPRODUCTS_SUPPLY,
		  /* ds change start */
		  c_rec.REQUESTED_START_DATE,
		  c_rec.REQUESTED_COMPLETION_DATE,
		  c_rec.SCHEDULE_PRIORITY,
		  c_rec.ASSET_SERIAL_NUMBER,
		  c_rec.ASSET_ITEM_ID,
		/* ds change end */
		  c_rec.ACTUAL_START_DATE,  /* Discrete Mfg Enahancements Bug 4479276 */
		  c_rec.CFM_ROUTING_FLAG,
		  c_rec.SR_CUSTOMER_ACCT_ID,
		  lv_ITEM_TYPE_ID,
		  lv_ITEM_TYPE_VALUE,
		  c_rec.customer_product_id,
		  c_rec.sr_repair_type_id,             -- Added for Bug 5909379
		  c_rec.SR_REPAIR_GROUP_ID,
		  c_rec.RO_STATUS_CODE,
      c_rec.ro_creation_date,
      c_rec.repair_lead_time,
      c_rec.schedule_origination_type,
      --c_rec.PO_LINE_LOCATION_ID,
      c_rec.INTRANSIT_OWNING_ORG_ID,
      c_rec.REQ_LINE_ID,
      c_rec.MAINTENANCE_OBJECT_SOURCE,
      c_rec.DESCRIPTION;


		END IF;

		  c_count:= c_count+1;

		  IF c_count> MSC_CL_COLLECTION.PBS THEN
		     IF MSC_CL_COLLECTION.v_is_complete_refresh THEN COMMIT; END IF;
		     c_count:= 0;
		  END IF;
		    /* ds change */
		    if c_rec.ORDER_TYPE = 70 then /* 70 eam supply*/
		       MSC_CL_COLLECTION.link_top_transaction_id_req := TRUE;
		    end if;
		    /* ds change */

		EXCEPTION

		   WHEN OTHERS THEN

		    IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN

		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'SQLCODE========================================');
		      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
		      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_SUPPLY');
		      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_SUPPLIES');
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			  update msc_apps_instances
			     set SUPPLIES_LOAD_FLAG = MSC_CL_COLLECTION.G_JOB_ERROR
			  where  instance_id = MSC_CL_COLLECTION.v_instance_id;
			  commit;

		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
		      RAISE;

		    ELSE
		      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'OTHER========================================');
		      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
		      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_SUPPLY');
		      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_SUPPLIES');
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
		      FND_MESSAGE.SET_TOKEN('COLUMN', 'MSC_CL_ITEM_ODS_LOAD.ITEM_NAME');
		      FND_MESSAGE.SET_TOKEN('VALUE', MSC_CL_ITEM_ODS_LOAD.ITEM_NAME( c_rec.INVENTORY_ITEM_ID));
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
		      FND_MESSAGE.SET_TOKEN('COLUMN', 'ORGANIZATION_CODE');
		      FND_MESSAGE.SET_TOKEN('VALUE',
		                            MSC_GET_NAME.ORG_CODE( c_rec.ORGANIZATION_ID,
		                                                   MSC_CL_COLLECTION.v_instance_id));
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
		      FND_MESSAGE.SET_TOKEN('COLUMN', 'ORDER_TYPE');
		      FND_MESSAGE.SET_TOKEN('VALUE',
		              MSC_GET_NAME.LOOKUP_MEANING('MRP_ORDER_TYPE',c_rec.ORDER_TYPE));
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
		    END IF;

		END;

		END LOOP;



		   /* CP-AUTO starts */
		   /* Load the PO Acknowledgment Records if MSC:Configuration is set to
		      CP or APS + CP and Supplier Responses parameter is set to Yes in
		      collection parameters.*/

		      IF (MSC_UTIL.G_MSC_CONFIGURATION = MSC_UTIL.G_CONF_APS_SCE
		                      OR MSC_UTIL.G_MSC_CONFIGURATION = MSC_UTIL.G_CONF_SCE) THEN

		         IF (MSC_CL_COLLECTION.v_is_complete_refresh or MSC_CL_COLLECTION.v_is_incremental_refresh) THEN

		             MSC_CL_SUPPLIER_RESP.LOAD_SUPPLIER_RESPONSE
		                 ( MSC_CL_COLLECTION.v_instance_id,
		                   MSC_CL_COLLECTION.v_is_complete_refresh,
		                   MSC_CL_COLLECTION.v_is_partial_refresh,
		                   MSC_CL_COLLECTION.v_is_incremental_refresh,
		                   lv_tbl,
		                   MSC_CL_COLLECTION.v_current_user,
		                   MSC_CL_COLLECTION.v_last_collection_id);

		         ELSIF (MSC_CL_COLLECTION.v_is_cont_refresh)  THEN

		             IF (MSC_CL_COLLECTION.v_coll_prec.supplier_response_flag = MSC_UTIL.SYS_YES and MSC_CL_COLLECTION.v_coll_prec.suprep_sn_flag = MSC_UTIL.SYS_INCR) THEN

		                 MSC_CL_SUPPLIER_RESP.LOAD_SUPPLIER_RESPONSE
		                     ( MSC_CL_COLLECTION.v_instance_id,
		                       FALSE, --MSC_CL_COLLECTION.v_is_complete_refresh,
		                       FALSE, --MSC_CL_COLLECTION.v_is_partial_refresh,
		                       TRUE, --MSC_CL_COLLECTION.v_is_incremental_refresh,
		                       lv_tbl,
		                       MSC_CL_COLLECTION.v_current_user,
		                       MSC_CL_COLLECTION.v_last_collection_id);

		             END IF;

		         END IF; -- IF (v_is_complete_....

		      END IF; --IF (G_MSC_CONFIGURA....


		-- agmcont
		   if MSC_CL_COLLECTION.v_is_cont_refresh then return; end if;

		   IF MSC_CL_COLLECTION.v_is_complete_refresh THEN
		       COMMIT;
		   END IF;


		   /* analyze msc_supplies here */
		   IF MSC_CL_COLLECTION.v_is_complete_refresh THEN
		      IF MSC_CL_COLLECTION.v_exchange_mode= MSC_UTIL.SYS_YES THEN
		         /* create temporay index */
		                IF MSC_CL_SUPPLY_ODS_LOAD.create_supplies_tmp_ind  THEN
				     MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Index creation on Temp Supplies table successful.');
				ELSE
				     MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
				     MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Index creation on Temp Supplies table failed.');
		                     RAISE MSC_CL_COLLECTION.SUPPLIES_INDEX_FAIL;
				END IF;
		      END IF;
		      msc_analyse_tables_pk.analyse_table( lv_tbl, MSC_CL_COLLECTION.v_instance_id, -1);
		   END IF;

		EXCEPTION

		   WHEN MSC_CL_COLLECTION.SUPPLIES_INDEX_FAIL THEN

			  update msc_apps_instances
			     set SUPPLIES_LOAD_FLAG = MSC_CL_COLLECTION.G_JOB_ERROR
			  where  instance_id = MSC_CL_COLLECTION.v_instance_id;
			  commit;
			MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'MSC_CL_COLLECTION.SUPPLIES_INDEX_FAIL failed');
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
		      RAISE;

		   WHEN OTHERS THEN

			  update msc_apps_instances
			     set SUPPLIES_LOAD_FLAG = MSC_CL_COLLECTION.G_JOB_ERROR
			  where  instance_id = MSC_CL_COLLECTION.v_instance_id;
			  commit;

			MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'load supply other exception');
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
		      RAISE;
		END LOAD_SUPPLY;

		PROCEDURE LOAD_STAGING_SUPPLY  IS

		   lv_temp_supply_tbl       VARCHAR2(30);
		   lv_sql_stmt              VARCHAR2(32767);
		   lv_where_clause          VARCHAR2(2000);


		--agmcont:
		   lv_cur_sql_stmt           VARCHAR2(5000);

		   type cur_type is ref cursor;
		   cur cur_type;

		   lv_transaction_id              number;
		   lv_INVENTORY_ITEM_ID           number;
		   lv_ORGANIZATION_ID             number;
		   lv_FROM_ORGANIZATION_ID        number;
		   lv_SR_INSTANCE_ID              number;
		   lv_SCHEDULE_DESIGNATOR_ID      number;
		   lv_REVISION                    varchar2(10);
		   lv_UNIT_NUMBER                 varchar2(30);
		   lv_NEW_SCHEDULE_DATE           date;
		   lv_OLD_SCHEDULE_DATE           date;
		   lv_NEW_WIP_START_DATE          date;
		   lv_OLD_WIP_START_DATE          date;
		   lv_FIRST_UNIT_COMPLETION_DATE  date;
		   lv_LAST_UNIT_COMPLETION_DATE   date;
		   lv_FIRST_UNIT_START_DATE       date;
		   lv_LAST_UNIT_START_DATE        date;
		   lv_DISPOSITION_ID              number;
		   lv_DISPOSITION_STATUS_TYPE     number;
		   lv_ORDER_TYPE                  number;
		   lv_NEW_ORDER_QUANTITY          number;
		   lv_OLD_ORDER_QUANTITY          number;
		   lv_QUANTITY_PER_ASSEMBLY       number;
		   lv_QUANTITY_ISSUED             number;
		   lv_DAILY_RATE                  number;
		   lv_NEW_ORDER_PLACEMENT_DATE    date;
		   lv_OLD_ORDER_PLACEMENT_DATE    date;
		   lv_RESCHEDULE_DAYS             number;
		   lv_RESCHEDULE_FLAG             number;
		   lv_SCHEDULE_COMPRESS_DAYS      number;
		   lv_NEW_PROCESSING_DAYS         number;
		   lv_PURCH_LINE_NUM              number;
		   lv_PO_LINE_ID                  number;
		   lv_QUANTITY_IN_PROCESS         number;
		   lv_IMPLEMENTED_QUANTITY        number;
		   lv_FIRM_PLANNED_TYPE           number;
		   lv_FIRM_QUANTITY               number;
		   lv_FIRM_DATE                   date;
		   lv_RELEASE_STATUS              number;
		   lv_LOAD_TYPE                   number;
		   lv_PROCESS_SEQ_ID              number;
		   lv_bill_sequence_id            number;
		   lv_routing_sequence_id         number;
		   lv_SCO_SUPPLY_FLAG             number;
		   lv_ALTERNATE_BOM_DESIGNATOR    varchar2(10);
		   lv_ALT_ROUTING_DESIGNATOR      varchar2(10);
		   lv_OPERATION_SEQ_NUM           number;
		   lv_JUMP_OP_SEQ_NUM             number;
		   lv_JOB_OP_SEQ_NUM              number;
		   lv_WIP_START_QUANTITY          number;
		   lv_BY_PRODUCT_USING_ASSY_ID    number;
		   lv_SOURCE_ORGANIZATION_ID      number;
		   lv_SOURCE_SR_INSTANCE_ID       number;
		   lv_SOURCE_SUPPLIER_SITE_ID     number;
		   lv_SOURCE_SUPPLIER_ID          number;
		   lv_SHIP_METHOD                 varchar2(30);
		   lv_WEIGHT_CAPACITY_USED        number;
		   lv_VOLUME_CAPACITY_USED        number;
		   lv_NEW_SHIP_DATE               date;
		   lv_NEW_DOCK_DATE               date;
		   lv_LINE_ID                     number;
		   lv_PROJECT_ID                  number;
		   lv_TASK_ID                     number;
		   lv_PLANNING_GROUP              varchar2(30);
		   lv_NUMBER1                     number;
		   lv_SOURCE_ITEM_ID              number;
		   lv_ORDER_NUMBER                varchar2(240);
		   lv_SCHEDULE_GROUP_ID           number;
		   lv_BUILD_SEQUENCE              number;
		   lv_WIP_ENTITY_NAME             varchar2(240);
		   lv_IMPLEMENT_PROCESSING_DAYS   number;
		   lv_DELIVERY_PRICE              number;
		   lv_LATE_SUPPLY_DATE            date;
		   lv_LATE_SUPPLY_QTY             number;
		   lv_SUBINVENTORY_CODE           varchar2(10);
		   lv_SUPPLIER_ID                 number;
		   lv_SUPPLIER_SITE_ID            number;
		   lv_EXPECTED_SCRAP_QTY          number;
		   lv_QTY_SCRAPPED                number;
		   lv_QTY_COMPLETED               number;
		   lv_WIP_STATUS_CODE             number;
		   lv_WIP_SUPPLY_TYPE             number;
		   lv_NON_NETTABLE_QTY            number;
		   lv_SCHEDULE_GROUP_NAME         varchar2(30);
		   lv_LOT_NUMBER                  varchar2(80);
		   lv_EXPIRATION_DATE             date;
		   lv_DEMAND_CLASS                varchar2(34);
		   lv_PLANNING_PARTNER_SITE_ID    number;
		   lv_PLANNING_TP_TYPE            number;
		   lv_OWNING_PARTNER_SITE_ID      number;
		   lv_OWNING_TP_TYPE              number;
		   lv_VMI_FLAG                    number;
		   lv_PO_LINE_LOCATION_ID         number;
		   lv_PO_DISTRIBUTION_ID          number;
		   lv_SR_MTL_SUPPLY_ID            number;
		   /* CP-ACK starts */
		   lv_need_by_date	          DATE;
		   lv_original_need_by_date	  DATE;
		   lv_original_quantity	          NUMBER;
		   lv_acceptance_required_flag	  VARCHAR2(1);
		   lv_promised_date               DATE;
		   /* CP-ACK ends */
		   lv_COPRODUCTS_SUPPLY           number;
		   lv_deleted_flag                number;


		   /* CP-ACK starts */
		   lv_po_dock_date_ref            NUMBER;
		   /* CP-ACK ends */

		   lv_cal_code			  VARCHAR2(30);
		   lv_cal_code_omc		  VARCHAR2(30);
		   lv_dock_date			  DATE;
		   lv_schedule_date		  DATE;
		   lv_org_id			  NUMBER:=0;
		   lv_POSTPROCESSING_LEAD_TIME	  NUMBER;
		   lv_REQUESTED_START_DATE        DATE;
		   lv_REQUESTED_COMPLETION_DATE   DATE;
		   lv_SCHEDULE_PRIORITY           NUMBER;
		   lv_ASSET_SERIAL_NUMBER         VARCHAR2(30);
		   lv_ASSET_ITEM_ID               NUMBER;
		   lv_ACTUAL_START_DATE           DATE;
		   lv_time_component              NUMBER ;
		   lv_CFM_ROUTING_FLAG            NUMBER;

		--SRP Changes Bug # 5684159
		   lv_SR_CUSTOMER_ACCT_ID        NUMBER;
		   lv_ITEM_TYPE_VALUE            NUMBER;
		   lv_ITEM_TYPE_ID               NUMBER;
		   lv_customer_product_id        NUMBER;  -- Changes For Bug 5909379
		   lv_sr_repair_type_id          NUMBER;
		   lv_SR_REPAIR_GROUP_ID         NUMBER;
		   lv_RO_STATUS_CODE             VARCHAR2(240);
		   lv_RO_CREATION_DATE            DATE ;
		   lv_REPAIR_LEAD_TIME             NUMBER;
		   lv_schedule_origination_type    NUMBER;
		   lv_req_line_id                  NUMBER;
		   lv_intransit_owning_org_id      NUMBER;
	       lv_maintenance_object_source    NUMBER;
           lv_description                  NUMBER;
		/* Added code for VMI changes */
		   Cursor c1 IS
		    SELECT
		      x.TRANSACTION_ID,
		      x.SR_MTL_SUPPLY_ID,
		      t1.INVENTORY_ITEM_ID,
		      x.ORGANIZATION_ID,
		      x.FROM_ORGANIZATION_ID,
		      x.SR_INSTANCE_ID,
		      x.REVISION,
		      x.UNIT_NUMBER,
		     /* decode(x.ORDER_TYPE, 1,
		             decode(lv_po_dock_date_ref,
		                        PROMISED_DATE_PREF , x.NEW_SCHEDULE_DATE,
		                        MSC_CL_COLLECTION.NEED_BY_DATE_PREF, MSC_CALENDAR.DATE_OFFSET(x.ORGANIZATION_ID,
		                                                                    x.SR_INSTANCE_ID,
		                                                                    TYPE_DAILY_BUCKET,
		                                                                    (MSC_CALENDAR.NEXT_WORK_DAY
											(x.ORGANIZATION_ID,
		                                                                         x.SR_INSTANCE_ID,
		                                                                         1,
		                                                                         nvl(x.NEED_BY_DATE,x.promised_date))),
		                                                                    nvl(x.POSTPROCESSING_LEAD_TIME,0)
		                                                                   )),
		         x.NEW_SCHEDULE_DATE ) NEW_SCHEDULE_DATE ,*/
		      x.NEW_SCHEDULE_DATE,
		      x.OLD_SCHEDULE_DATE,
		      x.NEW_WIP_START_DATE,
		      x.OLD_WIP_START_DATE,
		      x.FIRST_UNIT_COMPLETION_DATE,
		      x.LAST_UNIT_COMPLETION_DATE,
		      x.FIRST_UNIT_START_DATE,
		      x.LAST_UNIT_START_DATE,
		      x.DISPOSITION_ID,
		      x.DISPOSITION_STATUS_TYPE,
		      x.ORDER_TYPE,
		      x.NEW_ORDER_QUANTITY,
		      x.OLD_ORDER_QUANTITY,
		      x.QUANTITY_PER_ASSEMBLY,
		      x.QUANTITY_ISSUED,
		      x.DAILY_RATE,
		      x.NEW_ORDER_PLACEMENT_DATE,
		      x.OLD_ORDER_PLACEMENT_DATE,
		      x.RESCHEDULE_DAYS,
		      x.RESCHEDULE_FLAG,
		      x.SCHEDULE_COMPRESS_DAYS,
		      x.NEW_PROCESSING_DAYS,
		      x.PURCH_LINE_NUM,
		      x.PO_LINE_ID,
		      x.QUANTITY_IN_PROCESS,
		      x.IMPLEMENTED_QUANTITY,
		      x.FIRM_PLANNED_TYPE,
		      x.FIRM_QUANTITY,
		      x.FIRM_DATE,
		      x.RELEASE_STATUS,
		      x.LOAD_TYPE,
		      x.PROCESS_SEQ_ID,
		      x.bill_sequence_id,
		      x.routing_sequence_id,
		      x.SCO_SUPPLY_FLAG,
		      x.ALTERNATE_BOM_DESIGNATOR,
		      x.ALTERNATE_ROUTING_DESIGNATOR,
		      x.OPERATION_SEQ_NUM,
		      x.JUMP_OP_SEQ_NUM,
		      x.JOB_OP_SEQ_NUM,
		      x.WIP_START_QUANTITY,
		      t2.INVENTORY_ITEM_ID   BY_PRODUCT_USING_ASSY_ID,
		      x.SOURCE_ORGANIZATION_ID,
		      x.SOURCE_SR_INSTANCE_ID,
		      x.SOURCE_SUPPLIER_SITE_ID,
		      x.SOURCE_SUPPLIER_ID,
		      x.SHIP_METHOD,
		      x.WEIGHT_CAPACITY_USED,
		      x.VOLUME_CAPACITY_USED,
		      x.NEW_SHIP_DATE,
		      /* CP-ACK starts */
		       nvl(decode(lv_po_dock_date_ref,
					 MSC_CL_COLLECTION.PROMISED_DATE_PREF, nvl(x.PROMISED_DATE, x.NEED_BY_DATE),
					 MSC_CL_COLLECTION.NEED_BY_DATE_PREF , nvl(x.NEED_BY_DATE, x.PROMISED_DATE)
				),new_dock_date) NEW_DOCK_DATE,
		      /* CP-ACK ends */
		      x.LINE_ID,
		      x.PROJECT_ID,
		      x.TASK_ID,
		      x.PLANNING_GROUP,
		      x.NUMBER1,
		      x.SOURCE_ITEM_ID,
		      REPLACE(REPLACE(x.ORDER_NUMBER,MSC_CL_COLLECTION.v_chr10),MSC_CL_COLLECTION.v_chr13) ORDER_NUMBER,
		      x.SCHEDULE_GROUP_ID,
		      x.BUILD_SEQUENCE,
		      REPLACE(REPLACE(x.WIP_ENTITY_NAME,MSC_CL_COLLECTION.v_chr10),MSC_CL_COLLECTION.v_chr13) WIP_ENTITY_NAME,
		      x.IMPLEMENT_PROCESSING_DAYS,
		      x.DELIVERY_PRICE,
		      x.LATE_SUPPLY_DATE,
		      x.LATE_SUPPLY_QTY,
		      x.SUBINVENTORY_CODE,
		      tp.TP_ID       SUPPLIER_ID,
		      tps.TP_SITE_ID SUPPLIER_SITE_ID,
		      x.EXPECTED_SCRAP_QTY,
		      x.QTY_SCRAPPED,
		      x.QTY_COMPLETED,
		      x.WIP_STATUS_CODE,
		      x.WIP_SUPPLY_TYPE,
		      x.NON_NETTABLE_QTY,
		      x.SCHEDULE_GROUP_NAME,
		      x.LOT_NUMBER,
		      x.EXPIRATION_DATE,
		      md.DESIGNATOR_ID SCHEDULE_DESIGNATOR_ID,
		      x.DEMAND_CLASS,
		      x.DELETED_FLAG,
		      DECODE(x.PLANNING_TP_TYPE,1,tps1.TP_SITE_ID,x.PLANNING_PARTNER_SITE_ID) PLANNING_PARTNER_SITE_ID,
		      x.PLANNING_TP_TYPE,
		      DECODE(x.OWNING_TP_TYPE,1,tps2.TP_SITE_ID,x.OWNING_PARTNER_SITE_ID) OWNING_PARTNER_SITE_ID,
		      x.OWNING_TP_TYPE,
		      decode(x.VMI_FLAG,'Y',1,2) VMI_FLAG,
		      x.PO_LINE_LOCATION_ID,
		      x.PO_DISTRIBUTION_ID,
		      /* CP-ACK starts */
		      x.need_by_date,
		      x.original_need_by_date,
		      x.original_quantity,
		      x.acceptance_required_flag,
		      x.promised_date,
		      /* CP-ACK ends */
		      x.COPRODUCTS_SUPPLY,
		      x.POSTPROCESSING_LEAD_TIME,
		      x.REQUESTED_START_DATE, /* ds change start */
		      x.REQUESTED_COMPLETION_DATE,
		      x.SCHEDULE_PRIORITY,
		      x.ASSET_SERIAL_NUMBER,
		      t3.INVENTORY_ITEM_ID ASSET_ITEM_ID,   /*ds change end */
		      x.ACTUAL_START_DATE,  /* Discrete Mfg Enahancements Bug 4479276 */
		      x.CFM_ROUTING_FLAG,
		      x.SR_CUSTOMER_ACCT_ID,  --SRP Changes Bug # 5684159
		      x.ITEM_TYPE_ID,
		      x.ITEM_TYPE_VALUE,
		      x.customer_product_id,
		      x.sr_repair_type_id,             -- Added for Bug 5909379
		      x.SR_REPAIR_GROUP_ID,
		      x.RO_STATUS_CODE,
		      x.RO_CREATION_DATE,
		      x.REPAIR_LEAD_TIME,
		      x.schedule_origination_type,
		      --x.PO_LINE_LOCATION_ID,
          x.INTRANSIT_OWNING_ORG_ID,
          x.REQ_LINE_ID,
          x.maintenance_object_source,
          x.description
		    FROM MSC_DESIGNATORS md,
		         MSC_TP_SITE_ID_LID tps,
		         MSC_TP_SITE_ID_LID tps1,
		         MSC_TP_SITE_ID_LID tps2,
		         MSC_TP_ID_LID tp,
		         MSC_ITEM_ID_LID t1,
		         MSC_ITEM_ID_LID t2,
		         MSC_ITEM_ID_LID t3,
		         MSC_ST_SUPPLIES x
		   WHERE t1.SR_INVENTORY_ITEM_ID= x.INVENTORY_ITEM_ID
		     AND t1.SR_INSTANCE_ID= x.SR_INSTANCE_ID
		     AND t2.SR_INVENTORY_ITEM_ID(+) = x.BY_PRODUCT_USING_ASSY_ID
		     AND t2.SR_INSTANCE_ID(+) = x.SR_INSTANCE_ID
		     AND t3.SR_INVENTORY_ITEM_ID(+) = x.ASSET_ITEM_ID
		     AND t3.SR_INSTANCE_ID(+) = x.SR_INSTANCE_ID
		     AND tp.SR_TP_ID(+)= x.SUPPLIER_ID
		     AND tp.SR_INSTANCE_ID(+)= x.SR_INSTANCE_ID
		     AND tp.PARTNER_TYPE(+)= DECODE( x.SR_MTL_SUPPLY_ID,-1,2,1)
		     AND tps.SR_TP_SITE_ID(+)= x.SUPPLIER_SITE_ID
		     AND tps.SR_INSTANCE_ID(+)= x.SR_INSTANCE_ID
		     AND tps.PARTNER_TYPE(+)= 1
		     AND tps1.SR_TP_SITE_ID(+)= x.PLANNING_PARTNER_SITE_ID
		     AND tps1.SR_INSTANCE_ID(+)= x.SR_INSTANCE_ID
		     AND tps1.PARTNER_TYPE(+)= 1
		     AND tps2.SR_TP_SITE_ID(+)= x.OWNING_PARTNER_SITE_ID
		     AND tps2.SR_INSTANCE_ID(+)= x.SR_INSTANCE_ID
		     AND tps2.PARTNER_TYPE(+)= 1
		     AND x.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
		     AND x.DELETED_FLAG= MSC_UTIL.SYS_NO
		     AND md.SR_INSTANCE_ID(+)= x.SR_INSTANCE_ID
		     AND md.DESIGNATOR(+)= x.SCHEDULE_DESIGNATOR
		     AND md.Organization_ID(+)= x.Organization_ID
		     AND md.Designator_Type(+)= 2  -- MPS
			 /* CP-ACK starts */
			 AND x.ORDER_TYPE NOT IN (MSC_CL_COLLECTION.G_MRP_PO_ACK)
			 /* CP-ACK ends */
		      order by x.Organization_ID;


		/* PREPLACE START */ -- Could this be performance intensive
		   CURSOR c2 IS
		       SELECT x.INVENTORY_ITEM_ID
		         FROM MSC_ST_SUPPLIES x
		        WHERE x.SR_INSTANCE_ID = MSC_CL_COLLECTION.v_instance_id
		      MINUS
		       SELECT SR_INVENTORY_ITEM_ID INVENTORY_ITEM_ID
		         FROM MSC_ITEM_ID_LID
		        WHERE SR_INSTANCE_ID = MSC_CL_COLLECTION.v_instance_id;

		   c_count           NUMBER;

		   BEGIN


		/* CP-ACK starts */
		lv_po_dock_date_ref := nvl(fnd_profile.value('MSC_PO_DOCK_DATE_CALC_PREF'), MSC_CL_COLLECTION.PROMISED_DATE_PREF);
		/* CP-ACk ends */

		MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'load_staging_supply');


		     lv_temp_supply_tbl := 'SUPPLIES_'||MSC_CL_COLLECTION.v_instance_code;
		     c_count := 0;

		     lv_sql_stmt  :=
		                  'INSERT INTO ' || lv_temp_supply_tbl
		                          ||' ( PLAN_ID,'
		                          ||'  TRANSACTION_ID,'
		                          ||'  INVENTORY_ITEM_ID,'
		                          ||'  ORGANIZATION_ID,'
		                          ||'  FROM_ORGANIZATION_ID,'
		                          ||'  SR_INSTANCE_ID,'
		                          ||'  SCHEDULE_DESIGNATOR_ID,'
		                          ||'  REVISION,'
		                          ||'  UNIT_NUMBER,'
		                          ||'  NEW_SCHEDULE_DATE,'
		                          ||'  OLD_SCHEDULE_DATE,'
		                          ||'  NEW_WIP_START_DATE,'
		                          ||'  OLD_WIP_START_DATE,'
		                          ||'  FIRST_UNIT_COMPLETION_DATE,'
		                          ||'  LAST_UNIT_COMPLETION_DATE,'
		                          ||'  FIRST_UNIT_START_DATE,'
		                          ||'  LAST_UNIT_START_DATE,'
		                          ||'  DISPOSITION_ID,'
		                          ||'  DISPOSITION_STATUS_TYPE,'
		                          ||'  ORDER_TYPE,'
		                          ||'  NEW_ORDER_QUANTITY,'
		                          ||'  OLD_ORDER_QUANTITY,'
		                          ||'  QUANTITY_PER_ASSEMBLY,'
		                          ||'  QUANTITY_ISSUED,'
		                          ||'  DAILY_RATE,'
		                          ||'  NEW_ORDER_PLACEMENT_DATE,'
		                          ||'  OLD_ORDER_PLACEMENT_DATE,'
		                          ||'  RESCHEDULE_DAYS,'
		                          ||'  RESCHEDULE_FLAG,'
		                          ||'  SCHEDULE_COMPRESS_DAYS,'
		                          ||'  NEW_PROCESSING_DAYS,'
		                          ||'  PURCH_LINE_NUM,'
		                          ||'  PO_LINE_ID,'
		                          ||'  QUANTITY_IN_PROCESS,'
		                          ||'  IMPLEMENTED_QUANTITY,'
		                          ||'  FIRM_PLANNED_TYPE,'
		                          ||'  FIRM_QUANTITY,'
		                          ||'  FIRM_DATE,'
		                          ||'  RELEASE_STATUS,'
		                          ||'  LOAD_TYPE, '
		                          ||'  PROCESS_SEQ_ID,'
		                          ||'  BILL_SEQUENCE_ID,'
		                          ||'  ROUTING_SEQUENCE_ID,'
		                          ||'  SCO_SUPPLY_FLAG,'
		                          ||'  ALTERNATE_BOM_DESIGNATOR,'
		                          ||'  ALTERNATE_ROUTING_DESIGNATOR,'
		                          ||'  OPERATION_SEQ_NUM,'
		                          ||'  JUMP_OP_SEQ_NUM,'
		                          ||'  JOB_OP_SEQ_NUM,'
					  ||'  WIP_START_QUANTITY,'
		                          ||'  BY_PRODUCT_USING_ASSY_ID,'
		                          ||'  SOURCE_ORGANIZATION_ID,'
		                          ||'  SOURCE_SR_INSTANCE_ID,'
		                          ||'  SOURCE_SUPPLIER_SITE_ID,'
		                          ||'  SOURCE_SUPPLIER_ID,'
		                          ||'  SHIP_METHOD,'
		                          ||'  WEIGHT_CAPACITY_USED,'
		                          ||'  VOLUME_CAPACITY_USED,'
		                          ||'  NEW_SHIP_DATE,'
		                          ||'  NEW_DOCK_DATE,'
		                          ||'  LINE_ID,'
		                          ||'  PROJECT_ID,'
		                          ||'  TASK_ID,'
		                          ||'  PLANNING_GROUP,'
		                          ||'  NUMBER1,'
		                          ||'  SOURCE_ITEM_ID,'
		                          ||'  ORDER_NUMBER,'
		                          ||'  SCHEDULE_GROUP_ID,'
		                          ||'  BUILD_SEQUENCE,'
		                          ||'  WIP_ENTITY_NAME,'
		                          ||'  IMPLEMENT_PROCESSING_DAYS,'
		                          ||'  DELIVERY_PRICE,'
		                          ||'  LATE_SUPPLY_DATE,'
		                          ||'  LATE_SUPPLY_QTY,'
		                          ||'  SUBINVENTORY_CODE,'
		                          ||'  SUPPLIER_ID,'
		                         ||'  SUPPLIER_SITE_ID,'
		                          ||'  EXPECTED_SCRAP_QTY, '
		                          ||'  QTY_SCRAPPED,'
		                          ||'  QTY_COMPLETED,'
		                          ||'  WIP_STATUS_CODE,'
		                          ||'  WIP_SUPPLY_TYPE,'
		                          ||'  NON_NETTABLE_QTY,'
		                          ||'  SCHEDULE_GROUP_NAME,'
		                          ||'  LOT_NUMBER,'
		                          ||'  EXPIRATION_DATE,'
		                          ||'  DEMAND_CLASS,'
		                          ||'  PLANNING_PARTNER_SITE_ID,'
		                          ||'  PLANNING_TP_TYPE,'
		                          ||'  OWNING_PARTNER_SITE_ID,'
		                          ||'  OWNING_TP_TYPE,'
		                          ||'  VMI_FLAG ,'
		                          ||'  PO_LINE_LOCATION_ID,'
		                          ||'  PO_DISTRIBUTION_ID,'
		                          ||'  SR_MTL_SUPPLY_ID,'
		                          ||'  REFRESH_NUMBER,'
		                          ||'  LAST_UPDATE_DATE,'
		                          ||'  LAST_UPDATED_BY,'
		                          ||'  CREATION_DATE,'
		                          ||'  CREATED_BY,'
		                          /* CP-ACK starts */
		                          ||'  ORIGINAL_NEED_BY_DATE,'
		                          ||'  ORIGINAL_QUANTITY,'
		                          ||'  PROMISED_DATE,'
		                          ||'  NEED_BY_DATE,'
		                          ||'  ACCEPTANCE_REQUIRED_FLAG,'
		                          /* CP-ACK stops */
		                          ||'  COPRODUCTS_SUPPLY,'
		                          ||'  REQUESTED_START_DATE,'
		                          ||'  REQUESTED_COMPLETION_DATE,'
		                          ||'  SCHEDULE_PRIORITY,'
		                          ||'  ASSET_SERIAL_NUMBER,'
		                          ||'  ASSET_ITEM_ID,'
		                          ||'  ACTUAL_START_DATE,'
		                          ||'  CFM_ROUTING_FLAG,'
		                          ||'  SR_CUSTOMER_ACCT_ID,'
		                          ||'  ITEM_TYPE_ID,'
		                          ||'  ITEM_TYPE_VALUE,'
		                          ||'  CUSTOMER_PRODUCT_ID,'
		                          ||'  SR_REPAIR_TYPE_ID,'
		                          ||'  SR_REPAIR_GROUP_ID,'  -- Changes For Bug 5909379
		                          ||'  RO_STATUS_CODE,'
		                          ||'  RO_CREATION_DATE,'
		                          ||'  REPAIR_LEAD_TIME, '
		                          ||'  SCHEDULE_ORIGINATION_TYPE,'
                              ||'  INTRANSIT_OWNING_ORG_ID,'
                              ||'  REQ_LINE_ID,'
							  ||'  MAINTENANCE_OBJECT_SOURCE,'
							  ||'  DESCRIPTION'
                              ||')'
        		                ||' VALUES '
		                          ||'( -1,'
		                          ||'  MSC_SUPPLIES_S.NEXTVAL,'
		                          ||'  :INVENTORY_ITEM_ID,'
		                          ||'  :ORGANIZATION_ID,'
		                          ||'  :FROM_ORGANIZATION_ID,'
		                          ||'  :SR_INSTANCE_ID,'
		                          ||'  :SCHEDULE_DESIGNATOR_ID,'
		                          ||'  :REVISION,'
		                          ||'  :UNIT_NUMBER,'
		                          ||'  :NEW_SCHEDULE_DATE,'
		                          ||'  decode(:ORDER_TYPE, 1, :NEW_SCHEDULE_DATE, :OLD_SCHEDULE_DATE),'
		                          ||'  :NEW_WIP_START_DATE,'
		                          ||'  :OLD_WIP_START_DATE,'
		                          ||'  :FIRST_UNIT_COMPLETION_DATE,'
		                          ||'  :LAST_UNIT_COMPLETION_DATE,'
		                          ||'  :FIRST_UNIT_START_DATE,'
		                          ||'  :LAST_UNIT_START_DATE,'
		                          ||'  :DISPOSITION_ID,'
		                          ||'  :DISPOSITION_STATUS_TYPE,'
		                          ||'  :ORDER_TYPE,'
		                          ||'  :NEW_ORDER_QUANTITY,'
		                          ||'  :OLD_ORDER_QUANTITY,'
		                          ||'  :QUANTITY_PER_ASSEMBLY,'
		                          ||'  :QUANTITY_ISSUED,'
		                          ||'  :DAILY_RATE,'
		                          ||'  :NEW_ORDER_PLACEMENT_DATE,'
		                          ||'  :OLD_ORDER_PLACEMENT_DATE,'
		                          ||'  :RESCHEDULE_DAYS,'
		                          ||'  :RESCHEDULE_FLAG,'
		                          ||'  :SCHEDULE_COMPRESS_DAYS,'
		                          ||'  :NEW_PROCESSING_DAYS,'
		                          ||'  :PURCH_LINE_NUM,'
		                          ||'  :PO_LINE_ID,'
		                          ||'  :QUANTITY_IN_PROCESS,'
		                          ||'  :IMPLEMENTED_QUANTITY,'
		                          ||'  :FIRM_PLANNED_TYPE,'
		                          ||'  :FIRM_QUANTITY,'
		                          ||'  :FIRM_DATE,'
		                          ||'  :RELEASE_STATUS,'
		                          ||'  :LOAD_TYPE,'
		                          ||'  :PROCESS_SEQ_ID,'
		                          ||'  :bill_sequence_id,'
		                          ||'  :routing_sequence_id,'
		                          ||'  :SCO_SUPPLY_FLAG,'
		                          ||'  :ALTERNATE_BOM_DESIGNATOR,'
		                          ||'  :ALTERNATE_ROUTING_DESIGNATOR,'
		                          ||'  :OPERATION_SEQ_NUM,'
		                          ||'  :JUMP_OP_SEQ_NUM,'
		                          ||'  :JOB_OP_SEQ_NUM,'
					  ||'  :WIP_START_QUANTITY,'
		                          ||'  :BY_PRODUCT_USING_ASSY_ID,'
		                          ||'  :SOURCE_ORGANIZATION_ID,'
		                          ||'  :SOURCE_SR_INSTANCE_ID,'
		                          ||'  :SOURCE_SUPPLIER_SITE_ID,'
		                          ||'  :SOURCE_SUPPLIER_ID,'
		                          ||'  :SHIP_METHOD,'
		                          ||'  :WEIGHT_CAPACITY_USED,'
		                          ||'  :VOLUME_CAPACITY_USED,'
		                          ||'  :NEW_SHIP_DATE,'
		                          ||'  :NEW_DOCK_DATE,'
		                          ||'  :LINE_ID,'
		                          ||'  :PROJECT_ID,'
		                          ||'  :TASK_ID,'
		                          ||'  :PLANNING_GROUP,'
		                          ||'  :NUMBER1,'
		                          ||'  :SOURCE_ITEM_ID,'
		                          ||'  :ORDER_NUMBER,'
		                          ||'  :SCHEDULE_GROUP_ID,'
		                          ||'  :BUILD_SEQUENCE,'
		                          ||'  :WIP_ENTITY_NAME,'
		                          ||'  :IMPLEMENT_PROCESSING_DAYS,'
		                          ||'  :DELIVERY_PRICE,'
		                          ||'  :LATE_SUPPLY_DATE,'
		                          ||'  :LATE_SUPPLY_QTY,'
		                          ||'  :SUBINVENTORY_CODE,'
		                          ||'  :SUPPLIER_ID,'
		                          ||'  :SUPPLIER_SITE_ID,'
		                          ||'  :EXPECTED_SCRAP_QTY, '
		                          ||'  :QTY_SCRAPPED,'
		                          ||'  :QTY_COMPLETED,'
		                          ||'  :WIP_STATUS_CODE,'
		                          ||'  :WIP_SUPPLY_TYPE,'
		                          ||'  :NON_NETTABLE_QTY,'
		                          ||'  :SCHEDULE_GROUP_NAME,'
		                          ||'  :LOT_NUMBER,'
		                          ||'  :EXPIRATION_DATE,'
		                          ||'  :DEMAND_CLASS,'
		                          ||'  :PLANNING_PARTNER_SITE_ID,'
		                          ||'  :PLANNING_TP_TYPE,'
		                          ||'  :OWNING_PARTNER_SITE_ID,'
		                          ||'  :OWNING_TP_TYPE,'
		                          ||'  :VMI_FLAG ,'
		                          ||'  :PO_LINE_LOCATION_ID,'
		                          ||'  :PO_DISTRIBUTION_ID,'
		                          ||'  :SR_MTL_SUPPLY_ID,'
		                          ||'  :v_last_collection_id,'
		                          ||'  :v_current_date,'
		                          ||'  :v_current_user,'
		                          ||'  :v_current_date,'
		                          ||'  :v_current_user,'
		                          /* CP-ACK starts */
		                          ||'  :ORIGINAL_NEED_BY_DATE,'
		                          ||'  :ORIGINAL_QUANTITY,'
		                          ||'  :PROMISED_DATE,'
		                          ||'  :NEED_BY_DATE,'
		                          ||'  :ACCEPTANCE_REQUIRED_FLAG,'
		                          /* CP-ACK ends */
		                          ||'  :COPRODUCTS_SUPPLY,'
		                          ||'  :REQUESTED_START_DATE,'
		                          ||'  :REQUESTED_COMPLETION_DATE,'
		                          ||'  :SCHEDULE_PRIORITY,'
		                          ||'  :ASSET_SERIAL_NUMBER,'
		                          ||'  :ASSET_ITEM_ID,'
		                          ||'  :ACTUAL_START_DATE,'  /* Discrete Mfg Enahancements Bug 4479276 */
		                          ||'  :CFM_ROUTING_FLAG ,'
		                          ||'  :SR_CUSTOMER_ACCT_ID,'
		                          ||'  :ITEM_TYPE_ID,'
		                          ||'  :ITEM_TYPE_VALUE,'
		                          ||'  :CUSTOMER_PRODUCT_ID,'
		                          ||'  :SR_REPAIR_TYPE_ID,'               -- Changes For Bug 5909379
		                          ||'  :SR_REPAIR_GROUP_ID,'
		                          ||'  :RO_STATUS_CODE,'
		                          ||'  :RO_CREATION_DATE,'
		                          ||'  :REPAIR_LEAD_TIME, '
		                          ||'  :SCHEDULE_ORIGINATION_TYPE,'
                              ||'  :INTRANSIT_OWNING_ORG_ID,'
                              ||'  :REQ_LINE_ID,'
							  ||'  :MAINTENANCE_OBJECT_SOURCE,'
                              ||'  :DESCRIPTION'
                              ||' )';


--		   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'The sql statement is '||lv_sql_stmt);

		--agmcont:
		 if (MSC_CL_COLLECTION.v_is_cont_refresh = FALSE) then

		   FOR c_rec IN c1 LOOP
		--	MSC_CL_COLLECTION.log_debug('in calendar loop ');

		     BEGIN

			--logic for calculating dock date and schedule date
			IF (c_rec.NEW_DOCK_DATE is not null) THEN

			     IF(lv_org_id <> c_rec.ORGANIZATION_ID or lv_org_id=0) THEN

			     --GET_CALENDAR_CODE to be called only once for the same org

			MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'debug2 c_rec.SR_INSTANCE_ID='||to_char(c_rec.SR_INSTANCE_ID));
			MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'debug2 org_id='||to_char(c_rec.ORGANIZATION_ID));
			MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'debug2 orc='||to_char(MSC_CALENDAR.ORC));
				lv_cal_code:=msc_calendar.GET_CALENDAR_CODE(c_rec.SR_INSTANCE_ID, null, null, null, null, null, c_rec.ORGANIZATION_ID, null, MSC_CALENDAR.ORC);

				lv_cal_code_omc:=msc_calendar.GET_CALENDAR_CODE(c_rec.SR_INSTANCE_ID, null, null, null, null, null, c_rec.ORGANIZATION_ID, null, MSC_CALENDAR.OMC);

				lv_org_id:=c_rec.ORGANIZATION_ID;

			      END IF;

				--finding the dock date by validating it from Org Rec. Calendar
		        lv_time_component :=  c_rec.NEW_DOCK_DATE - trunc(c_rec.NEW_DOCK_DATE);
			      lv_dock_date :=MSC_CALENDAR.NEXT_WORK_DAY(lv_cal_code,c_rec.SR_INSTANCE_ID,c_rec.NEW_DOCK_DATE);
			      lv_dock_date := lv_dock_date + lv_time_component;
			 ELSE
			      IF c_rec.ORDER_TYPE=11 THEN

		                  IF(lv_org_id <> c_rec.ORGANIZATION_ID or lv_org_id=0) THEN
		                      --GET_CALENDAR_CODE to be called only once for the same org

		                      lv_cal_code:=msc_calendar.GET_CALENDAR_CODE(c_rec.SR_INSTANCE_ID, null, null, null, null, null, c_rec.ORGANIZATION_ID, null, MSC_CALENDAR.ORC);

		                      lv_cal_code_omc:=msc_calendar.GET_CALENDAR_CODE(c_rec.SR_INSTANCE_ID, null, null, null, null, null, c_rec.ORGANIZATION_ID, null, MSC_CALENDAR.OMC);

		                      lv_org_id:=c_rec.ORGANIZATION_ID;

		                  END IF;
		                  if (c_rec.NEW_SCHEDULE_DATE is not null ) then
		                  	lv_time_component := c_rec.NEW_SCHEDULE_DATE - trunc(c_rec.NEW_SCHEDULE_DATE);
		                  END IF ;

		                  lv_schedule_date  :=MSC_CALENDAR.DATE_OFFSET(lv_cal_code_omc,c_rec.SR_INSTANCE_ID,c_rec.NEW_SCHEDULE_DATE,nvl(c_rec.POSTPROCESSING_LEAD_TIME,0),1);

		                  if (c_rec.NEW_SCHEDULE_DATE is not null ) then
		                  	lv_schedule_date := lv_schedule_date + lv_time_component ;
		                  END IF ;

		               END IF;

			      lv_dock_date :=null;

			 END IF;


			 IF(c_rec.ORDER_TYPE in (1,2,8,73,74,87)) THEN --bug#8995860 added Order Type PO_IN_RECEIVING

				--offsetting the dock date to find the schedule date
			If ( lv_dock_date is not null) then
				lv_time_component := lv_dock_date - trunc(lv_dock_date);
					lv_schedule_date  :=MSC_CALENDAR.DATE_OFFSET(lv_cal_code_omc,c_rec.SR_INSTANCE_ID,lv_dock_date,nvl(c_rec.POSTPROCESSING_LEAD_TIME,0),1);
					lv_schedule_date := lv_schedule_date + lv_time_component;
			ELSE
			   lv_schedule_date  :=c_rec.NEW_SCHEDULE_DATE;
			 END IF ;



			 ELSIF NOT(c_rec.ORDER_TYPE=11 and c_rec.NEW_DOCK_DATE is null) THEN
				lv_schedule_date  :=c_rec.NEW_SCHEDULE_DATE;

			END IF;
			-- SRP enhancement

		  /* bug 5937871 */
	  IF MSC_UTIL.g_collect_srp_data = 'Y' THEN
  	  IF c_rec.ORDER_TYPE=75 THEN
		    if (c_rec.NEW_SCHEDULE_DATE is  null ) then
			    lv_cal_code_omc:=msc_calendar.GET_CALENDAR_CODE(c_rec.SR_INSTANCE_ID, null, null, null, null, null, c_rec.ORGANIZATION_ID, null, MSC_CALENDAR.OMC);
           lv_schedule_date  :=MSC_CALENDAR.DATE_OFFSET(lv_cal_code_omc,c_rec.SR_INSTANCE_ID,c_rec.RO_CREATION_DATE,nvl(c_rec.REPAIR_LEAD_TIME,0),1);
		    END IF ;
	     END IF ;
	  END IF ;
    /* end bug 5937871*/

		IF MSC_UTIL.g_collect_srp_data = 'Y' THEN

		  IF   (c_rec.ORDER_TYPE = 1)
		    OR (c_rec.ORDER_TYPE = 5 AND c_rec.FIRM_PLANNED_TYPE = 1)
		    OR (c_rec.ORDER_TYPE = 75)  OR (c_rec.ORDER_TYPE = 74)
		     THEN         --  For Bug 5909379
		     lv_ITEM_TYPE_ID     := MSC_UTIL.G_PARTCONDN_ITEMTYPEID;
		     lv_ITEM_TYPE_VALUE  :=  MSC_UTIL.G_PARTCONDN_GOOD;
		  ELSE
		       lv_ITEM_TYPE_ID := c_rec.ITEM_TYPE_ID;
		       lv_ITEM_TYPE_VALUE  :=  c_rec.ITEM_TYPE_VALUE;

		  END IF;

		  IF (c_rec.ORDER_TYPE = 86) THEN
		     lv_ITEM_TYPE_ID     :=  MSC_UTIL.G_PARTCONDN_ITEMTYPEID;
		     lv_ITEM_TYPE_VALUE  :=  MSC_UTIL.G_PARTCONDN_GOOD;
		  END IF;

		END IF;       --IF ((c_rec.SR_MTL_SUPPLY_ID = -1) or
		       --    (    SQL%NOTFOUND           ))  THEN

		         -- Question are these the right filters?

		          EXECUTE IMMEDIATE lv_sql_stmt
		          USING c_rec.INVENTORY_ITEM_ID,
		            c_rec.ORGANIZATION_ID,
		            c_rec.FROM_ORGANIZATION_ID,
		            c_rec.SR_INSTANCE_ID,
		            c_rec.SCHEDULE_DESIGNATOR_ID,
		            c_rec.REVISION,
		            c_rec.UNIT_NUMBER,
		            --c_rec.NEW_SCHEDULE_DATE,
			    lv_schedule_date,
		            c_rec.ORDER_TYPE,
					--c_rec.NEW_SCHEDULE_DATE,
					lv_schedule_date,
					c_rec.OLD_SCHEDULE_DATE,
		            c_rec.NEW_WIP_START_DATE,
		            c_rec.OLD_WIP_START_DATE,
		            c_rec.FIRST_UNIT_COMPLETION_DATE,
		            c_rec.LAST_UNIT_COMPLETION_DATE,
		            c_rec.FIRST_UNIT_START_DATE,
		            c_rec.LAST_UNIT_START_DATE,
		            c_rec.DISPOSITION_ID,
		            c_rec.DISPOSITION_STATUS_TYPE,
		            c_rec.ORDER_TYPE,
		            c_rec.NEW_ORDER_QUANTITY,
		            c_rec.OLD_ORDER_QUANTITY,
		            c_rec.QUANTITY_PER_ASSEMBLY,
		            c_rec.QUANTITY_ISSUED,
		            c_rec.DAILY_RATE,
		            c_rec.NEW_ORDER_PLACEMENT_DATE,
		            c_rec.OLD_ORDER_PLACEMENT_DATE,
		            c_rec.RESCHEDULE_DAYS,
		            c_rec.RESCHEDULE_FLAG,
		            c_rec.SCHEDULE_COMPRESS_DAYS,
		            c_rec.NEW_PROCESSING_DAYS,
		            c_rec.PURCH_LINE_NUM,
		            c_rec.PO_LINE_ID,
		            c_rec.QUANTITY_IN_PROCESS,
		            c_rec.IMPLEMENTED_QUANTITY,
		            c_rec.FIRM_PLANNED_TYPE,
		            c_rec.FIRM_QUANTITY,
		            c_rec.FIRM_DATE,
		            c_rec.RELEASE_STATUS,
		            c_rec.LOAD_TYPE,
		            c_rec.PROCESS_SEQ_ID,
		            c_rec.bill_sequence_id,
		            c_rec.routing_sequence_id,
		            c_rec.SCO_SUPPLY_FLAG,
		            c_rec.ALTERNATE_BOM_DESIGNATOR,
		            c_rec.ALTERNATE_ROUTING_DESIGNATOR,
		            c_rec.OPERATION_SEQ_NUM,
		            c_rec.JUMP_OP_SEQ_NUM,
		            c_rec.JOB_OP_SEQ_NUM,
			    c_rec.WIP_START_QUANTITY,
		            c_rec.BY_PRODUCT_USING_ASSY_ID,
		            c_rec.SOURCE_ORGANIZATION_ID,
		            c_rec.SOURCE_SR_INSTANCE_ID,
		            c_rec.SOURCE_SUPPLIER_SITE_ID,
		            c_rec.SOURCE_SUPPLIER_ID,
		            c_rec.SHIP_METHOD,
		            c_rec.WEIGHT_CAPACITY_USED,
		            c_rec.VOLUME_CAPACITY_USED,
		            c_rec.NEW_SHIP_DATE,
		            --c_rec.NEW_DOCK_DATE,
			    lv_dock_date,
		            c_rec.LINE_ID,
		            c_rec.PROJECT_ID,
		            c_rec.TASK_ID,
		            c_rec.PLANNING_GROUP,
		            c_rec.NUMBER1,
		            c_rec.SOURCE_ITEM_ID,
		            c_rec.ORDER_NUMBER,
		            c_rec.SCHEDULE_GROUP_ID,
		            c_rec.BUILD_SEQUENCE,
		            c_rec.WIP_ENTITY_NAME,
		            c_rec.IMPLEMENT_PROCESSING_DAYS,
		            c_rec.DELIVERY_PRICE,
		            c_rec.LATE_SUPPLY_DATE,
		            c_rec.LATE_SUPPLY_QTY,
		            c_rec.SUBINVENTORY_CODE,
		            c_rec.SUPPLIER_ID,
		            c_rec.SUPPLIER_SITE_ID,
		            c_rec.EXPECTED_SCRAP_QTY,
		            c_rec.QTY_SCRAPPED,
		            c_rec.QTY_COMPLETED,
		            c_rec.WIP_STATUS_CODE,
		            c_rec.WIP_SUPPLY_TYPE,
		            c_rec.NON_NETTABLE_QTY,
		            c_rec.SCHEDULE_GROUP_NAME,
		            c_rec.LOT_NUMBER,
		            c_rec.EXPIRATION_DATE,
		            c_rec.DEMAND_CLASS,
		            c_rec.PLANNING_PARTNER_SITE_ID,
		            c_rec.PLANNING_TP_TYPE,
		            c_rec.OWNING_PARTNER_SITE_ID,
		            c_rec.OWNING_TP_TYPE,
		            c_rec.VMI_FLAG ,
		            c_rec.PO_LINE_LOCATION_ID,
		            c_rec.PO_DISTRIBUTION_ID,
		            c_rec.SR_MTL_SUPPLY_ID,
		            MSC_CL_COLLECTION.v_last_collection_id,
		            MSC_CL_COLLECTION.v_current_date,
		            MSC_CL_COLLECTION.v_current_user,
		            MSC_CL_COLLECTION.v_current_date,
		            MSC_CL_COLLECTION.v_current_user,
		            /* CP-ACK starts */
		            c_rec.ORIGINAL_NEED_BY_DATE,
		            c_rec.ORIGINAL_QUANTITY,
		            c_rec.PROMISED_DATE,
		            c_rec.NEED_BY_DATE,
		            c_rec.ACCEPTANCE_REQUIRED_FLAG,
		            /* CP-ACK ends */
		            c_rec.COPRODUCTS_SUPPLY,
		            c_rec.REQUESTED_START_DATE,
		            c_rec.REQUESTED_COMPLETION_DATE,
		            c_rec.SCHEDULE_PRIORITY,
		            c_rec.ASSET_SERIAL_NUMBER,
		            c_rec.ASSET_ITEM_ID,
		            c_rec.ACTUAL_START_DATE,  /* Discrete Mfg Enahancements Bug 4479276 */
		            c_rec.CFM_ROUTING_FLAG,
		            c_rec.SR_CUSTOMER_ACCT_ID,
		            lv_ITEM_TYPE_ID,
		            lv_ITEM_TYPE_VALUE,
		            c_rec.CUSTOMER_PRODUCT_ID,
		            c_rec.SR_REPAIR_TYPE_ID,                         -- Changes For Bug 5909379
		            c_rec.SR_REPAIR_GROUP_ID,
		            c_rec.RO_STATUS_CODE,
                c_rec.RO_CREATION_DATE,
                c_rec.REPAIR_LEAD_TIME,
                c_rec.schedule_origination_type,
              --  c_rec.PO_LINE_LOCATION_ID,
                c_rec.INTRANSIT_OWNING_ORG_ID,
                c_rec.REQ_LINE_ID,
                c_rec.MAINTENANCE_OBJECT_SOURCE,
                c_rec.DESCRIPTION;



		       --END IF;

		       c_count:= c_count+1;

		       IF c_count> MSC_CL_COLLECTION.PBS THEN
		          COMMIT;
		          MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'The total record count inserted is '||TO_CHAR(c_count));
		          c_count:= 0;
		       END IF;

		    EXCEPTION
		      WHEN OTHERS THEN

		       IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN

		         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'P========================================');
		         FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
		         FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_STAGING_SUPPLY');
		         FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_SUPPLIES');
		         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			  update msc_apps_instances
			     set SUPPLIES_LOAD_FLAG = MSC_CL_COLLECTION.G_JOB_ERROR
			  where  instance_id = MSC_CL_COLLECTION.v_instance_id;
			  commit;

		         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
		         RAISE;

		       ELSE
		         MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

		         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'E========================================');
		         FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
		         FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_STAGING_SUPPLY');
		         FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_SUPPLIES');
		         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		         FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
		         FND_MESSAGE.SET_TOKEN('COLUMN', 'MSC_CL_ITEM_ODS_LOAD.ITEM_NAME');
		         FND_MESSAGE.SET_TOKEN('VALUE', MSC_CL_ITEM_ODS_LOAD.ITEM_NAME( c_rec.INVENTORY_ITEM_ID));
		         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		         FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
		         FND_MESSAGE.SET_TOKEN('COLUMN', 'ORGANIZATION_CODE');
		         FND_MESSAGE.SET_TOKEN('VALUE',
		                            MSC_GET_NAME.ORG_CODE( c_rec.ORGANIZATION_ID,
		                                                   MSC_CL_COLLECTION.v_instance_id));
		         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		         FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
		         FND_MESSAGE.SET_TOKEN('COLUMN', 'ORDER_TYPE');
		         FND_MESSAGE.SET_TOKEN('VALUE',
		              MSC_GET_NAME.LOOKUP_MEANING('MRP_ORDER_TYPE',c_rec.ORDER_TYPE));
		         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
		       END IF;

		     END;

		   END LOOP;

		   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'The total record count inserted is '||TO_CHAR(c_count));

		   IF(MSC_CL_COLLECTION.v_coll_prec.wip_flag = MSC_UTIL.SYS_YES) THEN
           IF MSC_CL_COLLECTION.v_coll_prec.org_group_flag = MSC_UTIL.G_ALL_ORGANIZATIONS THEN
            	    MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_WO_ATTRIBUTES', MSC_CL_COLLECTION.v_instance_id,NULL);
                    MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_WO_OPERATION_REL',MSC_CL_COLLECTION.v_instance_id,NULL  );
                    MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_WO_TASK_HIERARCHY',MSC_CL_COLLECTION.v_instance_id, NULL );

					commit;
   				ELSE
                    MSC_CL_COLLECTION.v_sub_str :=' AND ORGANIZATION_ID '||MSC_UTIL.v_in_org_str;
  					MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_WO_ATTRIBUTES', MSC_CL_COLLECTION.v_instance_id, NULL ,MSC_CL_COLLECTION.v_sub_str);
                    MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_WO_OPERATION_REL',MSC_CL_COLLECTION.v_instance_id, NULL ,MSC_CL_COLLECTION.v_sub_str);
                    MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_WO_TASK_HIERARCHY', MSC_CL_COLLECTION.v_instance_id, NULL ,MSC_CL_COLLECTION.v_sub_str);
					commit;
                END IF;
		    END IF;

		   COMMIT;

		   FOR extra_rec in c2 LOOP

		     MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'DUE to PARTIAL REFRESH supplies not loaded related to '||
		                  ' ITEMS with IDs '|| TO_CHAR(extra_rec.inventory_item_id));

		   END LOOP;

		   /* CP-ACK starts */
		   --==============================================
		   -- Call the API to load PO Supplier responses in
		   -- msc_supplies. The same needs to be called in
		   -- "else" section these code lines if contineous
		   -- collections is enabled for this entity.
		   --==============================================
		       IF (    MSC_UTIL.G_MSC_CONFIGURATION = MSC_UTIL.G_CONF_APS_SCE
		            OR MSC_UTIL.G_MSC_CONFIGURATION = MSC_UTIL.G_CONF_SCE
		          ) THEN

		             IF (MSC_CL_COLLECTION.v_coll_prec.supplier_response_flag = MSC_UTIL.SYS_YES) THEN

					 MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Loading Supplier Responses from iSupplier Portal');

		                 MSC_CL_SUPPLIER_RESP.LOAD_SUPPLIER_RESPONSE
		                     ( MSC_CL_COLLECTION.v_instance_id,
		                       MSC_CL_COLLECTION.v_is_complete_refresh,
		                       MSC_CL_COLLECTION.v_is_partial_refresh,
		                       MSC_CL_COLLECTION.v_is_incremental_refresh,
		                       lv_temp_supply_tbl,
		                       MSC_CL_COLLECTION.v_current_user,
		                       MSC_CL_COLLECTION.v_last_collection_id);

		             END IF;

		       END IF;

		   /* CP-ACK ends */

		--agmcont:
		  else
		  -- For continuous refresh


		MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'load_staging_supply: cont');

		    /* CP-AUTO */
		    /* Following code lines will get executed if any of the Supply type of entity
		       is getting collected on targeted basis.
		       If within Supply entities, only Supplier Responses is being collected on
		       targeted basis then we need not to execute lv_cur_sql_stmt because there
		       is seperate API to take care of Supplier Responses. */


		    IF ((MSC_CL_COLLECTION.v_coll_prec.mps_flag = MSC_UTIL.SYS_YES and MSC_CL_COLLECTION.v_coll_prec.mps_sn_flag = MSC_UTIL.SYS_TGT) OR
		        (MSC_CL_COLLECTION.v_coll_prec.wip_flag = MSC_UTIL.SYS_YES and MSC_CL_COLLECTION.v_coll_prec.wip_sn_flag = MSC_UTIL.SYS_TGT) OR
		        (MSC_CL_COLLECTION.v_coll_prec.po_flag = MSC_UTIL.SYS_YES and MSC_CL_COLLECTION.v_coll_prec.po_sn_flag = MSC_UTIL.SYS_TGT) OR
		        (MSC_CL_COLLECTION.v_coll_prec.oh_flag = MSC_UTIL.SYS_YES and MSC_CL_COLLECTION.v_coll_prec.oh_sn_flag = MSC_UTIL.SYS_TGT) OR
		        (MSC_CL_COLLECTION.v_coll_prec.user_supply_demand_flag = MSC_UTIL.SYS_YES and MSC_CL_COLLECTION.v_coll_prec.usup_sn_flag = MSC_UTIL.SYS_TGT)
		       ) THEN

		    lv_cur_sql_stmt :=
		    'SELECT'
		    ||  ' x.TRANSACTION_ID,'
		    ||  ' x.SR_MTL_SUPPLY_ID,'
		    ||  ' t1.INVENTORY_ITEM_ID,'
		    ||  ' x.ORGANIZATION_ID,'
		    ||  ' x.FROM_ORGANIZATION_ID,'
		    ||  ' x.SR_INSTANCE_ID,'
		    ||  ' x.REVISION,'
		    ||  ' x.UNIT_NUMBER,'
		    /*||  ' decode(x.ORDER_TYPE, 1,'
		    ||  '         decode( '||lv_po_dock_date_ref|| ' ,'
		    ||                       PROMISED_DATE_PREF ||', x.NEW_SCHEDULE_DATE,'
		    ||                       MSC_CL_COLLECTION.NEED_BY_DATE_PREF  ||', MSC_CALENDAR.DATE_OFFSET(x.ORGANIZATION_ID,'
		    ||  '                                                                    x.SR_INSTANCE_ID,'
		    ||                                                                       TYPE_DAILY_BUCKET ||' ,'
		    ||  '                                                                    (MSC_CALENDAR.NEXT_WORK_DAY'
		    ||  '																		(x.ORGANIZATION_ID,'
		    ||  '                                                                        x.SR_INSTANCE_ID,'
		    ||  '                                                                        1,'
		    ||  '                                                                        nvl(x.NEED_BY_DATE,x.promised_date))),'
		    ||  '                                                                    nvl(x.POSTPROCESSING_LEAD_TIME,0)'
		    ||  '                                                               )),'
		    ||  '    x.NEW_SCHEDULE_DATE ) NEW_SCHEDULE_DATE ,'*/
		    ||  ' x.NEW_SCHEDULE_DATE,'
		    ||  ' x.OLD_SCHEDULE_DATE,'
		    ||  ' x.NEW_WIP_START_DATE,'
		    ||  ' x.OLD_WIP_START_DATE,'
		    ||  ' x.FIRST_UNIT_COMPLETION_DATE,'
		    ||  ' x.LAST_UNIT_COMPLETION_DATE,'
		    ||  ' x.FIRST_UNIT_START_DATE,'
		    ||  ' x.LAST_UNIT_START_DATE,'
		    ||  ' x.DISPOSITION_ID,'
		    ||  ' x.DISPOSITION_STATUS_TYPE,'
		    ||  ' x.ORDER_TYPE,'
		    ||  ' x.NEW_ORDER_QUANTITY,'
		    ||  ' x.OLD_ORDER_QUANTITY,'
		    ||  ' x.QUANTITY_PER_ASSEMBLY,'
		    ||  ' x.QUANTITY_ISSUED,'
		    ||  ' x.DAILY_RATE,'
		    ||  ' x.NEW_ORDER_PLACEMENT_DATE,'
		    ||  ' x.OLD_ORDER_PLACEMENT_DATE,'
		    ||  ' x.RESCHEDULE_DAYS,'
		    ||  ' x.RESCHEDULE_FLAG,'
		    ||  ' x.SCHEDULE_COMPRESS_DAYS,'
		    ||  ' x.NEW_PROCESSING_DAYS,'
		    ||  ' x.PURCH_LINE_NUM,'
		    ||  ' x.PO_LINE_ID,'
		    ||  ' x.QUANTITY_IN_PROCESS,'
		    ||  ' x.IMPLEMENTED_QUANTITY,'
		    ||  ' x.FIRM_PLANNED_TYPE,'
		    ||  ' x.FIRM_QUANTITY,'
		    ||  ' x.FIRM_DATE,'
		    ||  ' x.RELEASE_STATUS,'
		    ||  ' x.LOAD_TYPE,'
		    ||  ' x.PROCESS_SEQ_ID,'
		    ||  ' x.bill_sequence_id,'
		    ||  ' x.routing_sequence_id,'
		    ||  ' x.SCO_SUPPLY_FLAG,'
		    ||  ' x.ALTERNATE_BOM_DESIGNATOR,'
		    ||  ' x.ALTERNATE_ROUTING_DESIGNATOR,'
		    ||  ' x.OPERATION_SEQ_NUM,'
		    ||  ' x.JUMP_OP_SEQ_NUM,'
		    ||  ' x.JOB_OP_SEQ_NUM,'
		    ||  ' x.WIP_START_QUANTITY ,'
		    ||  ' t2.INVENTORY_ITEM_ID   BY_PRODUCT_USING_ASSY_ID,'
		    ||  ' x.SOURCE_ORGANIZATION_ID,'
		    ||  ' x.SOURCE_SR_INSTANCE_ID,'
		    ||  ' x.SOURCE_SUPPLIER_SITE_ID,'
		    ||  ' x.SOURCE_SUPPLIER_ID,'
		    ||  ' x.SHIP_METHOD,'
		    ||  ' x.WEIGHT_CAPACITY_USED,'
		    ||  ' x.VOLUME_CAPACITY_USED,'
		    ||  ' x.NEW_SHIP_DATE,'
		  /* CP-ACK starts */
		    ||  ' nvl(decode( '||lv_po_dock_date_ref ||', '
		    ||  			 MSC_CL_COLLECTION.PROMISED_DATE_PREF ||' , nvl(x.PROMISED_DATE, x.NEED_BY_DATE), '
		    ||  			 MSC_CL_COLLECTION.NEED_BY_DATE_PREF  ||' , nvl(x.NEED_BY_DATE, x.PROMISED_DATE) '
			||  '    ),new_dock_date) NEW_DOCK_DATE, '
		  /* CP-ACK ends */
		    -- ||  ' x.NEW_DOCK_DATE,'
		    ||  ' x.LINE_ID,'
		    ||  ' x.PROJECT_ID,'
		    ||  ' x.TASK_ID,'
		    ||  ' x.PLANNING_GROUP,'
		    ||  ' x.NUMBER1,'
		    ||  ' x.SOURCE_ITEM_ID,'
		    ||  ' REPLACE(REPLACE(x.ORDER_NUMBER,:v_chr10),:v_chr13) ORDER_NUMBER,'
		    ||  ' x.SCHEDULE_GROUP_ID,'
		    ||  ' x.BUILD_SEQUENCE,'
		    ||  ' REPLACE(REPLACE(x.WIP_ENTITY_NAME,:v_chr10),:v_chr13)WIP_ENTITY_NAME,'
		    ||  ' x.IMPLEMENT_PROCESSING_DAYS,'
		    ||  ' x.DELIVERY_PRICE,'
		    ||  ' x.LATE_SUPPLY_DATE,'
		    ||  ' x.LATE_SUPPLY_QTY,'
		    ||  ' x.SUBINVENTORY_CODE,'
		    ||  ' tp.TP_ID       SUPPLIER_ID,'
		    ||  ' tps.TP_SITE_ID SUPPLIER_SITE_ID,'
		    ||  ' x.EXPECTED_SCRAP_QTY,'
		    ||  ' x.QTY_SCRAPPED,'
		    ||  ' x.QTY_COMPLETED,'
		    ||  ' x.WIP_STATUS_CODE,'
		    ||  ' x.WIP_SUPPLY_TYPE,'
		    ||  ' x.NON_NETTABLE_QTY,'
		    ||  ' x.SCHEDULE_GROUP_NAME,'
		    ||  ' x.LOT_NUMBER,'
		    ||  ' x.EXPIRATION_DATE,'
		    ||  ' md.DESIGNATOR_ID SCHEDULE_DESIGNATOR_ID,'
		    ||  ' x.DEMAND_CLASS,'
		    ||  ' x.DELETED_FLAG,'
		    ||  ' DECODE(x.PLANNING_TP_TYPE,1,tps1.TP_SITE_ID,x.PLANNING_PARTNER_SITE_ID) PLANNING_PARTNER_SITE_ID,'
		    ||  ' x.PLANNING_TP_TYPE,'
		    ||  ' DECODE(x.OWNING_TP_TYPE,1,tps2.TP_SITE_ID,x.OWNING_PARTNER_SITE_ID) OWNING_PARTNER_SITE_ID,'
		    ||  ' x.OWNING_TP_TYPE,'
		    ||  ' decode(x.VMI_FLAG,''Y'',1,2) VMI_FLAG,'
		    ||  ' x.PO_LINE_LOCATION_ID,'
		    ||  ' x.PO_DISTRIBUTION_ID,'
		    /* CP-ACK starts */
		    ||  ' x.need_by_date,'
		    ||  ' x.original_need_by_date,'
		    ||  ' x.original_quantity,'
		    ||  ' x.acceptance_required_flag,'
		    ||  ' x.promised_date,'
		    /* CP-ACK ends */
		    ||  ' x.COPRODUCTS_SUPPLY,'
		    ||  '  x.POSTPROCESSING_LEAD_TIME,'
		    ||  '  x.REQUESTED_START_DATE,' /* ds change start */
		    ||  '  x.REQUESTED_COMPLETION_DATE,'
		    ||  '  x.SCHEDULE_PRIORITY,'
		    ||  '  x.ASSET_SERIAL_NUMBER,'
		    ||  '  t3.INVENTORY_ITEM_ID ASSET_ITEM_ID,'   /*ds change end */
		    ||  '  x.ACTUAL_START_DATE,'  /* Discrete Mfg Enahancements Bug 4479276 */
		    ||  '  x.CFM_ROUTING_FLAG,'
		    ||  '  x.SR_CUSTOMER_ACCT_ID,'
		    ||  '  x.ITEM_TYPE_ID, '
		    ||  '  x.ITEM_TYPE_VALUE ,'
		    ||  '  x.CUSTOMER_PRODUCT_ID,'
		    ||  '  x.sr_repair_type_id,'          -- Changes For Bug 5909379
		    ||  '  x.SR_REPAIR_GROUP_ID,'
		    ||  '  x.RO_STATUS_CODE, '
        ||  '  x.RO_CREATION_DATE, '
        ||  '  x.REPAIR_LEAD_TIME, '
        ||  '  x.schedule_origination_type,'
        ||  '  x.req_line_id,'
        ||  '  x.intransit_owning_org_id,'
        ||  '  x.maintenance_object_source,'
        ||  '  x.description'
		    ||  ' FROM MSC_DESIGNATORS md,'
		    ||  '   MSC_TP_SITE_ID_LID tps,'
		    ||  '   MSC_TP_SITE_ID_LID tps1,'
		    ||  '   MSC_TP_SITE_ID_LID tps2,'
		    ||  '   MSC_TP_ID_LID tp,'
		    ||  '   MSC_ITEM_ID_LID t1,'
		    ||  '   MSC_ITEM_ID_LID t2,'
		    ||  '   MSC_ITEM_ID_LID t3,'
		    ||  '   MSC_ST_SUPPLIES x'
		    ||  ' WHERE t1.SR_INVENTORY_ITEM_ID= x.INVENTORY_ITEM_ID'
		    ||  ' AND t1.SR_INSTANCE_ID= x.SR_INSTANCE_ID'
		    ||  ' AND t2.SR_INVENTORY_ITEM_ID(+) = x.BY_PRODUCT_USING_ASSY_ID'
		    ||  ' AND t2.SR_INSTANCE_ID(+) = x.SR_INSTANCE_ID'
		    ||  ' AND t3.SR_INVENTORY_ITEM_ID(+) = x.ASSET_ITEM_ID'
		    ||  ' AND t3.SR_INSTANCE_ID(+) = x.SR_INSTANCE_ID'
		    ||  ' AND tp.SR_TP_ID(+)= x.SUPPLIER_ID'
		    ||  ' AND tp.SR_INSTANCE_ID(+)= x.SR_INSTANCE_ID'
		    ||  ' AND tp.PARTNER_TYPE(+)= DECODE( x.SR_MTL_SUPPLY_ID,-1,2,1)'
		    ||  ' AND tps.SR_TP_SITE_ID(+)= x.SUPPLIER_SITE_ID'
		    ||  ' AND tps.SR_INSTANCE_ID(+)= x.SR_INSTANCE_ID'
		    ||  ' AND tps.PARTNER_TYPE(+)= 1'
		    ||  ' AND tps1.SR_TP_SITE_ID(+)= x.PLANNING_PARTNER_SITE_ID'
		    ||  ' AND tps1.SR_INSTANCE_ID(+)= x.SR_INSTANCE_ID'
		    ||  ' AND tps1.PARTNER_TYPE(+)= 1'
		    ||  ' AND tps2.SR_TP_SITE_ID(+)= x.OWNING_PARTNER_SITE_ID'
		    ||  ' AND tps2.SR_INSTANCE_ID(+)= x.SR_INSTANCE_ID'
		    ||  ' AND tps2.PARTNER_TYPE(+)= 1'
		    ||  ' AND x.SR_INSTANCE_ID=' || MSC_CL_COLLECTION.v_instance_id
		    ||  ' AND x.DELETED_FLAG=' || MSC_UTIL.SYS_NO
		    ||  ' AND md.SR_INSTANCE_ID(+)= x.SR_INSTANCE_ID'
		    ||  ' AND md.DESIGNATOR(+)= x.SCHEDULE_DESIGNATOR'
		    ||  ' AND md.Organization_ID(+)= x.Organization_ID'
		    ||  ' AND md.Designator_Type(+)= 2'
		    ||  ' AND x.order_type in (';



		MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'load_staging_supply: 5');

		    if (MSC_CL_COLLECTION.v_coll_prec.mps_flag = MSC_UTIL.SYS_YES) and
		       (MSC_CL_COLLECTION.v_coll_prec.mps_sn_flag = MSC_UTIL.SYS_TGT) then
		            lv_where_clause := '5';
		    end if;

		    if (MSC_CL_COLLECTION.v_coll_prec.wip_flag = MSC_UTIL.SYS_YES) and
		       (MSC_CL_COLLECTION.v_coll_prec.wip_sn_flag = MSC_UTIL.SYS_TGT) then
		       if (lv_where_clause is null) then
		          lv_where_clause := '3,7,14,15,16,27,30,70';
		       else
		          lv_where_clause := lv_where_clause||',3,7,14,15,16,27,30,70';
		       end if;
		    end if;

		    if (MSC_CL_COLLECTION.v_coll_prec.po_flag = MSC_UTIL.SYS_YES) and
		       (MSC_CL_COLLECTION.v_coll_prec.po_sn_flag = MSC_UTIL.SYS_TGT) then
		       if (lv_where_clause is null) then
		          lv_where_clause := '1,2,8,11,12,73,74,87';
		       else
		          lv_where_clause := lv_where_clause||',1,2,8,11,12,73,74,87';
		       end if;
		    end if;

		    if (MSC_CL_COLLECTION.v_coll_prec.oh_flag = MSC_UTIL.SYS_YES) and
		       (MSC_CL_COLLECTION.v_coll_prec.oh_sn_flag = MSC_UTIL.SYS_TGT) then
		       if (lv_where_clause is null) then
		          lv_where_clause := '18';
		       else
		          lv_where_clause := lv_where_clause||',18';
		       end if;
		    end if;

		    if (MSC_CL_COLLECTION.v_coll_prec.user_supply_demand_flag = MSC_UTIL.SYS_YES) and
		       (MSC_CL_COLLECTION.v_coll_prec.usup_sn_flag = MSC_UTIL.SYS_TGT) then
		       if (lv_where_clause is null) then
		          lv_where_clause := '41';
		       else
		          lv_where_clause := lv_where_clause||',41';
		       end if;
		    end if;

		   lv_cur_sql_stmt := lv_cur_sql_stmt||lv_where_clause ||' )';

		MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'load_staging_supply: 6');

		   lv_cur_sql_stmt:=lv_cur_sql_stmt|| ' order by x.ORGANIZATION_ID ';

		   --MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'lv_cur_sql_stmt=' || lv_cur_sql_stmt);

		   open cur for lv_cur_sql_stmt USING MSC_CL_COLLECTION.v_chr10, MSC_CL_COLLECTION.v_chr13, MSC_CL_COLLECTION.v_chr10, MSC_CL_COLLECTION.v_chr13;

		   LOOP

		     fetch cur into
		            lv_transaction_id,
		            lv_sr_mtl_supply_id,
		            lv_INVENTORY_ITEM_ID,
		            lv_ORGANIZATION_ID,
		            lv_FROM_ORGANIZATION_ID,
		            lv_SR_INSTANCE_ID,
		            lv_REVISION,
		            lv_UNIT_NUMBER,
		            lv_NEW_SCHEDULE_DATE,
		            lv_OLD_SCHEDULE_DATE,
		            lv_NEW_WIP_START_DATE,
		            lv_OLD_WIP_START_DATE,
		            lv_FIRST_UNIT_COMPLETION_DATE,
		            lv_LAST_UNIT_COMPLETION_DATE,
		            lv_FIRST_UNIT_START_DATE,
		            lv_LAST_UNIT_START_DATE,
		            lv_DISPOSITION_ID,
		            lv_DISPOSITION_STATUS_TYPE,
		            lv_ORDER_TYPE,
		            lv_NEW_ORDER_QUANTITY,
		            lv_OLD_ORDER_QUANTITY,
		            lv_QUANTITY_PER_ASSEMBLY,
		            lv_QUANTITY_ISSUED,
		            lv_DAILY_RATE,
		            lv_NEW_ORDER_PLACEMENT_DATE,
		            lv_OLD_ORDER_PLACEMENT_DATE,
		            lv_RESCHEDULE_DAYS,
		            lv_RESCHEDULE_FLAG,
		            lv_SCHEDULE_COMPRESS_DAYS,
		            lv_NEW_PROCESSING_DAYS,
		            lv_PURCH_LINE_NUM,
		            lv_PO_LINE_ID,
		            lv_QUANTITY_IN_PROCESS,
		            lv_IMPLEMENTED_QUANTITY,
		            lv_FIRM_PLANNED_TYPE,
		            lv_FIRM_QUANTITY,
		            lv_FIRM_DATE,
		            lv_RELEASE_STATUS,
		            lv_LOAD_TYPE,
		            lv_PROCESS_SEQ_ID,
		            lv_bill_sequence_id,
		            lv_routing_sequence_id,
		            lv_SCO_SUPPLY_FLAG,
		            lv_ALTERNATE_BOM_DESIGNATOR,
		            lv_ALT_ROUTING_DESIGNATOR,
		            lv_OPERATION_SEQ_NUM,
		            lv_JUMP_OP_SEQ_NUM,
		            lv_JOB_OP_SEQ_NUM,
			    lv_WIP_START_QUANTITY,
		            lv_BY_PRODUCT_USING_ASSY_ID,
		            lv_SOURCE_ORGANIZATION_ID,
		            lv_SOURCE_SR_INSTANCE_ID,
		            lv_SOURCE_SUPPLIER_SITE_ID,
		            lv_SOURCE_SUPPLIER_ID,
		            lv_SHIP_METHOD,
		            lv_WEIGHT_CAPACITY_USED,
		            lv_VOLUME_CAPACITY_USED,
		            lv_NEW_SHIP_DATE,
		            lv_NEW_DOCK_DATE,
		            lv_LINE_ID,
		            lv_PROJECT_ID,
		            lv_TASK_ID,
		            lv_PLANNING_GROUP,
		            lv_NUMBER1,
		            lv_SOURCE_ITEM_ID,
		            lv_ORDER_NUMBER,
		            lv_SCHEDULE_GROUP_ID,
		            lv_BUILD_SEQUENCE,
		            lv_WIP_ENTITY_NAME,
		            lv_IMPLEMENT_PROCESSING_DAYS,
		            lv_DELIVERY_PRICE,
		            lv_LATE_SUPPLY_DATE,
		            lv_LATE_SUPPLY_QTY,
		            lv_SUBINVENTORY_CODE,
		            lv_SUPPLIER_ID,
		            lv_SUPPLIER_SITE_ID,
		            lv_EXPECTED_SCRAP_QTY,
		            lv_QTY_SCRAPPED,
		            lv_QTY_COMPLETED,
		            lv_WIP_STATUS_CODE,
		            lv_WIP_SUPPLY_TYPE,
		            lv_NON_NETTABLE_QTY,
		            lv_SCHEDULE_GROUP_NAME,
		            lv_LOT_NUMBER,
		            lv_EXPIRATION_DATE,
		            lv_SCHEDULE_DESIGNATOR_ID,
		            lv_DEMAND_CLASS,
		            lv_deleted_flag,
		            lv_PLANNING_PARTNER_SITE_ID,
		            lv_PLANNING_TP_TYPE,
		            lv_OWNING_PARTNER_SITE_ID,
		            lv_OWNING_TP_TYPE,
		            lv_VMI_FLAG ,
		            lv_PO_LINE_LOCATION_ID,
		            lv_PO_DISTRIBUTION_ID,
		          /* CP-ACK starts */
		            lv_need_by_date,
		            lv_original_need_by_date,
		            lv_original_quantity,
		            lv_acceptance_required_flag,
		            lv_promised_date,
		          /* CP-ACK ends */
		            lv_COPRODUCTS_SUPPLY,
			    lv_POSTPROCESSING_LEAD_TIME,
			    lv_REQUESTED_START_DATE     ,
		            lv_REQUESTED_COMPLETION_DATE ,
		            lv_SCHEDULE_PRIORITY       ,
		            lv_ASSET_SERIAL_NUMBER ,
		            lv_ASSET_ITEM_ID,
		            lv_ACTUAL_START_DATE,  /* Discrete Mfg Enahancements Bug 4479276 */
		            lv_CFM_ROUTING_FLAG,
		            lv_SR_CUSTOMER_ACCT_ID,
		            lv_ITEM_TYPE_ID,
		            lv_ITEM_TYPE_VALUE,
		            lv_customer_product_id  ,  -- Changes For Bug 5909379
		            lv_sr_repair_type_id,
		            lv_SR_REPAIR_GROUP_ID,
		            lv_RO_STATUS_CODE,
                lv_RO_CREATION_DATE,
                lv_REPAIR_LEAD_TIME,
                lv_schedule_origination_type,
                lv_req_line_id,
		            lv_intransit_owning_org_id,
                    lv_maintenance_object_source,
                    lv_description;



			--logic for calculating dock date and schedule date
			 IF (lv_NEW_DOCK_DATE is not null) THEN

			     IF(lv_org_id <> lv_ORGANIZATION_ID or lv_org_id=0) THEN

			      --GET_CALENDAR_CODE to be called only once for the same org

				lv_cal_code:=msc_calendar.GET_CALENDAR_CODE(lv_SR_INSTANCE_ID, null, null, null, null, null, lv_ORGANIZATION_ID, null, MSC_CALENDAR.ORC);

				lv_cal_code_omc:=msc_calendar.GET_CALENDAR_CODE(lv_SR_INSTANCE_ID, null, null, null, null, null, lv_ORGANIZATION_ID, null, MSC_CALENDAR.OMC);

				lv_org_id:=lv_ORGANIZATION_ID;

			      END IF;

			      --finding the dock date by validating it from Org Rec. Calendar
		        lv_time_component:= lv_NEW_DOCK_DATE- trunc(lv_NEW_DOCK_DATE);
			      lv_NEW_DOCK_DATE :=MSC_CALENDAR.NEXT_WORK_DAY(lv_cal_code,lv_SR_INSTANCE_ID,lv_NEW_DOCK_DATE);
			      lv_NEW_DOCK_DATE := lv_NEW_DOCK_DATE + lv_time_component;
			 ELSE
			      lv_NEW_DOCK_DATE :=null;

			 END IF;


			 IF(lv_ORDER_TYPE=1) OR (lv_ORDER_TYPE=74) THEN

				--offsetting the dock date to find the schedule date
				If ( lv_NEW_DOCK_DATE is not null) then
					lv_time_component := lv_NEW_DOCK_DATE - trunc(lv_NEW_DOCK_DATE);
				END IF ;
				lv_NEW_SCHEDULE_DATE  :=MSC_CALENDAR.DATE_OFFSET(lv_cal_code_omc,lv_SR_INSTANCE_ID,lv_NEW_DOCK_DATE,nvl(lv_POSTPROCESSING_LEAD_TIME,0),1);

				If ( lv_NEW_DOCK_DATE is not null) then
					lv_NEW_SCHEDULE_DATE := lv_NEW_SCHEDULE_DATE +lv_time_component ;
				END IF ;

			 ELSE
				lv_NEW_SCHEDULE_DATE  :=lv_NEW_SCHEDULE_DATE;

			 END IF;




		     EXIT WHEN cur%NOTFOUND;


		     BEGIN

		       /* CP-ACK starts */
		       IF (lv_order_type = 1) OR (lv_order_type = 74) THEN
		           lv_OLD_SCHEDULE_DATE := lv_NEW_SCHEDULE_DATE;
		       END IF;
			-- SRP enhancement
		IF MSC_UTIL.g_collect_srp_data = 'Y' THEN
		  IF   (lv_order_type = 1)
		    OR (lv_order_type = 5 AND lv_FIRM_PLANNED_TYPE = 1)
		    OR (lv_order_type = 75) OR (lv_order_type = 74)
		    OR (lv_order_type = 86)   THEN
		     lv_ITEM_TYPE_ID     :=  MSC_UTIL.G_PARTCONDN_ITEMTYPEID;
		     lv_ITEM_TYPE_VALUE  :=  MSC_UTIL.G_PARTCONDN_GOOD;
		  END IF;
		END IF;

		       --IF ((c_rec.SR_MTL_SUPPLY_ID = -1) or
		       --    (    SQL%NOTFOUND           ))  THEN

		         -- Question are these the right filters?

		          EXECUTE IMMEDIATE lv_sql_stmt
		          USING lv_INVENTORY_ITEM_ID,
		            lv_ORGANIZATION_ID,
		            lv_FROM_ORGANIZATION_ID,
		            lv_SR_INSTANCE_ID,
		            lv_SCHEDULE_DESIGNATOR_ID,
		            lv_REVISION,
		            lv_UNIT_NUMBER,
					/* CP-ACK starts */
		            lv_NEW_SCHEDULE_DATE,
					lv_ORDER_TYPE,
					lv_NEW_SCHEDULE_DATE,
		            lv_OLD_SCHEDULE_DATE,
					/* CP-ACK ends */
		            lv_NEW_WIP_START_DATE,
		            lv_OLD_WIP_START_DATE,
		            lv_FIRST_UNIT_COMPLETION_DATE,
		            lv_LAST_UNIT_COMPLETION_DATE,
		            lv_FIRST_UNIT_START_DATE,
		            lv_LAST_UNIT_START_DATE,
		            lv_DISPOSITION_ID,
		            lv_DISPOSITION_STATUS_TYPE,
		            lv_ORDER_TYPE,
		            lv_NEW_ORDER_QUANTITY,
		            lv_OLD_ORDER_QUANTITY,
		            lv_QUANTITY_PER_ASSEMBLY,
		            lv_QUANTITY_ISSUED,
		            lv_DAILY_RATE,
		            lv_NEW_ORDER_PLACEMENT_DATE,
		            lv_OLD_ORDER_PLACEMENT_DATE,
		            lv_RESCHEDULE_DAYS,
		            lv_RESCHEDULE_FLAG,
		            lv_SCHEDULE_COMPRESS_DAYS,
		            lv_NEW_PROCESSING_DAYS,
		            lv_PURCH_LINE_NUM,
		            lv_PO_LINE_ID,
		            lv_QUANTITY_IN_PROCESS,
		            lv_IMPLEMENTED_QUANTITY,
		            lv_FIRM_PLANNED_TYPE,
		            lv_FIRM_QUANTITY,
		            lv_FIRM_DATE,
		            lv_RELEASE_STATUS,
		            lv_LOAD_TYPE,
		            lv_PROCESS_SEQ_ID,
		            lv_bill_sequence_id,
		            lv_routing_sequence_id,
		            lv_SCO_SUPPLY_FLAG,
		            lv_ALTERNATE_BOM_DESIGNATOR,
		            lv_ALT_ROUTING_DESIGNATOR,
		            lv_OPERATION_SEQ_NUM,
		            lv_JUMP_OP_SEQ_NUM,
		            lv_JOB_OP_SEQ_NUM,
			    lv_WIP_START_QUANTITY,
		            lv_BY_PRODUCT_USING_ASSY_ID,
		            lv_SOURCE_ORGANIZATION_ID,
		            lv_SOURCE_SR_INSTANCE_ID,
		            lv_SOURCE_SUPPLIER_SITE_ID,
		            lv_SOURCE_SUPPLIER_ID,
		            lv_SHIP_METHOD,
		            lv_WEIGHT_CAPACITY_USED,
		            lv_VOLUME_CAPACITY_USED,
		            lv_NEW_SHIP_DATE,
		            lv_NEW_DOCK_DATE,
		            lv_LINE_ID,
		            lv_PROJECT_ID,
		            lv_TASK_ID,
		            lv_PLANNING_GROUP,
		            lv_NUMBER1,
		            lv_SOURCE_ITEM_ID,
		            lv_ORDER_NUMBER,
		            lv_SCHEDULE_GROUP_ID,
		            lv_BUILD_SEQUENCE,
		            lv_WIP_ENTITY_NAME,
		            lv_IMPLEMENT_PROCESSING_DAYS,
		            lv_DELIVERY_PRICE,
		            lv_LATE_SUPPLY_DATE,
		            lv_LATE_SUPPLY_QTY,
		            lv_SUBINVENTORY_CODE,
		            lv_SUPPLIER_ID,
		            lv_SUPPLIER_SITE_ID,
		            lv_EXPECTED_SCRAP_QTY,
		            lv_QTY_SCRAPPED,
		            lv_QTY_COMPLETED,
		            lv_WIP_STATUS_CODE,
		            lv_WIP_SUPPLY_TYPE,
		            lv_NON_NETTABLE_QTY,
		            lv_SCHEDULE_GROUP_NAME,
		            lv_LOT_NUMBER,
		            lv_EXPIRATION_DATE,
		            lv_DEMAND_CLASS,
		            lv_PLANNING_PARTNER_SITE_ID,
		            lv_PLANNING_TP_TYPE,
		            lv_OWNING_PARTNER_SITE_ID,
		            lv_OWNING_TP_TYPE,
		            lv_VMI_FLAG ,
		            lv_PO_LINE_LOCATION_ID,
		            lv_PO_DISTRIBUTION_ID,
		            lv_SR_MTL_SUPPLY_ID,
		            MSC_CL_COLLECTION.v_last_collection_id,
		            MSC_CL_COLLECTION.v_current_date,
		            MSC_CL_COLLECTION.v_current_user,
		            MSC_CL_COLLECTION.v_current_date,
		            MSC_CL_COLLECTION.v_current_user,
		          /* CP-ACK starts */
		            lv_original_need_by_date,
		            lv_original_quantity,
		            lv_promised_date,
		            lv_need_by_date,
		            lv_acceptance_required_flag,
		          /* CP-ACK ends */
		            lv_COPRODUCTS_SUPPLY,
		            lv_REQUESTED_START_DATE,
		            lv_REQUESTED_COMPLETION_DATE,
		            lv_SCHEDULE_PRIORITY,
		            lv_ASSET_SERIAL_NUMBER,
		            lv_ASSET_ITEM_ID,
		            lv_ACTUAL_START_DATE,
		            lv_CFM_ROUTING_FLAG,
		            lv_SR_CUSTOMER_ACCT_ID,
		            lv_ITEM_TYPE_ID,
		            lv_ITEM_TYPE_VALUE,
		            lv_customer_product_id  ,  -- Changes For Bug 5909379
		            lv_sr_repair_type_id,
		            lv_SR_REPAIR_GROUP_ID,
		            lv_RO_STATUS_CODE,
                lv_RO_CREATION_DATE,
                lv_REPAIR_LEAD_TIME,
                lv_schedule_origination_type,
                lv_req_line_id,
		            lv_intransit_owning_org_id,
                    lv_maintenance_object_source,
                    lv_description;

		       --END IF;

		       c_count:= c_count+1;

		       IF c_count> MSC_CL_COLLECTION.PBS THEN
		          COMMIT;
		          MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'The total record count inserted is '||TO_CHAR(c_count));
		          c_count:= 0;
		       END IF;


		    EXCEPTION
		      WHEN OTHERS THEN

		       IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN

		         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
		         FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
		         FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_SUPPLY');
		         FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_SUPPLIES');
		         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			  update msc_apps_instances
			     set SUPPLIES_LOAD_FLAG = MSC_CL_COLLECTION.G_JOB_ERROR
			  where  instance_id = MSC_CL_COLLECTION.v_instance_id;
			  commit;

		         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
		         RAISE;

		       ELSE
		         MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

		         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
		         FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
		         FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_SUPPLY');
		         FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_SUPPLIES');
		         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		         FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
		         FND_MESSAGE.SET_TOKEN('COLUMN', 'MSC_CL_COLLECTION.ITEM_NAME');
		         FND_MESSAGE.SET_TOKEN('VALUE', MSC_CL_ITEM_ODS_LOAD.ITEM_NAME( lv_INVENTORY_ITEM_ID));
		         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		         FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
		         FND_MESSAGE.SET_TOKEN('COLUMN', 'ORGANIZATION_CODE');
		         FND_MESSAGE.SET_TOKEN('VALUE',
		                            MSC_GET_NAME.ORG_CODE( lv_ORGANIZATION_ID,
		                                                   MSC_CL_COLLECTION.v_instance_id));
		         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		         FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
		         FND_MESSAGE.SET_TOKEN('COLUMN', 'ORDER_TYPE');
		         FND_MESSAGE.SET_TOKEN('VALUE',
		              MSC_GET_NAME.LOOKUP_MEANING('MRP_ORDER_TYPE',lv_ORDER_TYPE));
		         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
		       END IF;

		     END;

		   END LOOP;

		   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'The total record count inserted is '||TO_CHAR(c_count));
		   COMMIT;

		/*
		   FOR extra_rec in c2 LOOP

		     MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'DUE to PARTIAL REFRESH supplies not loaded related to '||
		                  ' ITEMS with IDs '|| TO_CHAR(extra_rec.inventory_item_id));

		   END LOOP;
		*/

		   /* CP-AUTO */

		   END IF; -- IF ((MSC_CL_COLLECTION.v_coll_prec.mps_flag = SYS_YES and.....................
		   /* CP-AUTO starts */
		   --===================================================
		   -- Call the API to load PO Supplier responses in
		   -- msc_supplies. The same needs to be called in
		   -- "else" section these code lines if contineous
		   -- collections is enabled for this entity.

		   -- We will call this API only if "Supplier Responses"
		   -- entity needs to be collected as Targeted Refresh
		   --===================================================
		       IF (    MSC_UTIL.G_MSC_CONFIGURATION = MSC_UTIL.G_CONF_APS_SCE
		            OR MSC_UTIL.G_MSC_CONFIGURATION = MSC_UTIL.G_CONF_SCE
		          ) THEN

		             IF (MSC_CL_COLLECTION.v_coll_prec.supplier_response_flag = MSC_UTIL.SYS_YES and MSC_CL_COLLECTION.v_coll_prec.suprep_sn_flag = MSC_UTIL.SYS_TGT) THEN

		             MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Loading Supplier Responses from iSupplier Portal');

		                 MSC_CL_SUPPLIER_RESP.LOAD_SUPPLIER_RESPONSE
		                     ( MSC_CL_COLLECTION.v_instance_id,
		                       FALSE, --MSC_CL_COLLECTION.v_is_complete_refresh,
		                       TRUE, --MSC_CL_COLLECTION.v_is_partial_refresh,
		                       FALSE, --MSC_CL_COLLECTION.v_is_incremental_refresh,
		                       lv_temp_supply_tbl,
		                       MSC_CL_COLLECTION.v_current_user,
		                       MSC_CL_COLLECTION.v_last_collection_id);

		             END IF;

		       END IF;
		  end if;



		   END LOAD_STAGING_SUPPLY;

		   PROCEDURE LOAD_ODS_SUPPLY  IS

		   lv_temp_supply_tbl       VARCHAR2(30);
		   lv_sql_stmt              VARCHAR2(32767);
		   lv_sql_stmt1              VARCHAR2(32767);
		   lv_where_clause          VARCHAR2(2000);

		   BEGIN

		     lv_temp_supply_tbl := 'SUPPLIES_'||MSC_CL_COLLECTION.v_instance_code;
		     lv_sql_stmt:=
		         'INSERT INTO '||lv_temp_supply_tbl
		          ||' SELECT * from MSC_SUPPLIES '
		          ||'  WHERE sr_instance_id = '||MSC_CL_COLLECTION.v_instance_id
		          ||'    AND plan_id = -1 '
		          ||'    AND order_type NOT IN (';

		-- agmcont:

		   IF MSC_CL_COLLECTION.v_coll_prec.mps_flag = MSC_UTIL.SYS_YES THEN
		      if (MSC_CL_COLLECTION.v_is_cont_refresh) then
		         if (MSC_CL_COLLECTION.v_coll_prec.mps_sn_flag = MSC_UTIL.SYS_TGT) then
		            lv_where_clause := '5';
		         end if;
		      else
		         lv_where_clause := '5';
		      end if;
		   END IF;
   IF (MSC_CL_COLLECTION.v_coll_prec.payback_demand_supply_flag = MSC_UTIL.SYS_YES) THEN
            IF (lv_where_clause IS NULL)  THEN
               lv_where_clause :=  '29';
            ELSE
               lv_where_clause := lv_where_clause||', 29';
            END IF;
   END IF;
		   IF (MSC_CL_COLLECTION.v_coll_prec.wip_flag = MSC_UTIL.SYS_YES) THEN

		      if (MSC_CL_COLLECTION.v_is_cont_refresh) then
		         if (MSC_CL_COLLECTION.v_coll_prec.wip_sn_flag = MSC_UTIL.SYS_TGT) then
		            IF (lv_where_clause IS NULL)  THEN
		               lv_where_clause :=  '3,7,14,15,16,27,30,70';
		            ELSE
		               lv_where_clause := lv_where_clause||', 3,7,14,15,16,27,30,70';
		            END IF;
		         end if;
		      else
		         IF (lv_where_clause IS NULL)  THEN
		            lv_where_clause :=  '3,7,14,15,16,27,30,70';
		         ELSE
		            lv_where_clause := lv_where_clause||', 3,7,14,15,16,27,30,70';
		         END IF;
		      end if;
		   END IF;

		   -- Question what does REPT item - 16 represent?
		   -- It is assumed that it should be grouped with WIP flag.

		   IF (MSC_CL_COLLECTION.v_coll_prec.po_flag = MSC_UTIL.SYS_YES) THEN
		      if (MSC_CL_COLLECTION.v_is_cont_refresh) then
		         if (MSC_CL_COLLECTION.v_coll_prec.po_sn_flag = MSC_UTIL.SYS_TGT) then
		            IF (lv_where_clause IS NULL)  THEN
		               lv_where_clause :=  '1,2,8,11,12,73,74,87';
		            ELSE
		               lv_where_clause := lv_where_clause||', 1,2,8,11,12,73,74,87';
		            END IF;
		         end if;
		      else
		         IF (lv_where_clause IS NULL)  THEN
		            lv_where_clause :=  '1,2,8,11,12,73,74,87';
		         ELSE
		            lv_where_clause := lv_where_clause||', 1,2,8,11,12,73,74,87';
		         END IF;
		      end if;
		   END IF;

		   IF (MSC_CL_COLLECTION.v_coll_prec.oh_flag = MSC_UTIL.SYS_YES) THEN
		      if (MSC_CL_COLLECTION.v_is_cont_refresh) then
		         if (MSC_CL_COLLECTION.v_coll_prec.oh_sn_flag = MSC_UTIL.SYS_TGT) then
		            IF (lv_where_clause IS NULL)  THEN
		               lv_where_clause :=  '18';
		            ELSE
		               lv_where_clause := lv_where_clause||', 18';
		            END IF;
		         end if;
		      else
		         IF (lv_where_clause IS NULL)  THEN
		            lv_where_clause :=  '18';
		         ELSE
		            lv_where_clause := lv_where_clause||', 18';
		         END IF;
		      end if;
		   END IF;

		  IF (MSC_CL_COLLECTION.v_coll_prec.internal_repair_flag  = MSC_UTIL.SYS_YES) THEN
		      if (MSC_CL_COLLECTION.v_is_cont_refresh) then
		           NULL;
		      Else

		            IF (lv_where_clause IS NULL)  THEN
		               lv_where_clause :=  '75';
		            ELSE
		               lv_where_clause := lv_where_clause||', 75';
		            END IF;
		      end if;

		  END IF;                 -- Added for 5909379 SRP Additions

		  IF (MSC_CL_COLLECTION.v_coll_prec.external_repair_flag  = MSC_UTIL.SYS_YES) THEN
		      if (MSC_CL_COLLECTION.v_is_cont_refresh) then
		           NULL;
		      Else

		            IF (lv_where_clause IS NULL)  THEN
		               lv_where_clause :=  '86';
		            ELSE
		               lv_where_clause := lv_where_clause||', 86';
		            END IF;
		      end if;

		  END IF;                 -- Added for 5935273 SRP Additions


		   IF (MSC_CL_COLLECTION.v_coll_prec.user_supply_demand_flag = MSC_UTIL.SYS_YES) THEN
		      if (MSC_CL_COLLECTION.v_is_cont_refresh) then
		         if (MSC_CL_COLLECTION.v_coll_prec.usup_sn_flag = MSC_UTIL.SYS_TGT) then
		            IF (lv_where_clause IS NULL)  THEN
		               lv_where_clause :=  '41';
		            ELSE
		               lv_where_clause := lv_where_clause||', 41';
		            END IF;
		         end if;
		      else
		         IF (lv_where_clause IS NULL)  THEN
		            lv_where_clause :=  '41';
		         ELSE
		            lv_where_clause := lv_where_clause||', 41';
		         END IF;
		      end if;
		   END IF;

		   /* CP-ACK starts */

		   IF (MSC_CL_COLLECTION.v_coll_prec.supplier_response_flag = MSC_UTIL.SYS_YES) THEN

		      /* CP-AUTO */
		      IF (MSC_CL_COLLECTION.v_is_cont_refresh) then

		          IF (MSC_CL_COLLECTION.v_coll_prec.suprep_sn_flag = MSC_UTIL.SYS_TGT) THEN

		              IF (lv_where_clause IS NULL)  THEN
		                  lv_where_clause :=  MSC_CL_COLLECTION.G_MRP_PO_ACK;
		              ELSE
		                  lv_where_clause := lv_where_clause||', '||MSC_CL_COLLECTION.G_MRP_PO_ACK;
		              END IF;

		          END IF;

		      ELSE

		          IF (lv_where_clause IS NULL)  THEN
		              lv_where_clause :=  MSC_CL_COLLECTION.G_MRP_PO_ACK;
		          ELSE
		              lv_where_clause := lv_where_clause||', '||MSC_CL_COLLECTION.G_MRP_PO_ACK;
		          END IF;

		      END IF;

		   END IF;

		   /* CP-ACK ends */

		   -- User Defined supplies order_type 41 is not
		   -- loaded during partial replacement since
		   -- User Defined supply load is parameter independent.
		   -- For that purpose complete refresh needs to be run.

		   lv_sql_stmt := lv_sql_stmt||lv_where_clause ||' )';

		   IF MSC_CL_COLLECTION.v_coll_prec.org_group_flag = MSC_UTIL.G_ALL_ORGANIZATIONS THEN
		      null;
		   ELSE
		      lv_sql_stmt1:=  '  UNION ALL '
		                    ||'  SELECT * from MSC_SUPPLIES '
		                    ||'  WHERE sr_instance_id = '||MSC_CL_COLLECTION.v_instance_id
		                    ||'  AND plan_id = -1 '
		                    ||'  AND organization_id not '||MSC_UTIL.v_in_org_str
		                    ||'  AND order_type IN (';

		      lv_sql_stmt1 := lv_sql_stmt1||lv_where_clause ||' )';


		      if NOT (MSC_CL_COLLECTION.v_is_complete_refresh) then
		        lv_sql_stmt :=lv_sql_stmt||lv_sql_stmt1;
		      else
		        lv_sql_stmt := lv_sql_stmt||' AND organization_id NOT '||MSC_UTIL.v_in_org_str;

		        lv_sql_stmt :=lv_sql_stmt||lv_sql_stmt1;
		      end if;

		   END IF;


		   EXECUTE IMMEDIATE lv_sql_stmt;

		   COMMIT;

		   EXCEPTION
		     WHEN OTHERS THEN
			  update msc_apps_instances
			     set SUPPLIES_LOAD_FLAG = MSC_CL_COLLECTION.G_JOB_ERROR
			  where  instance_id = MSC_CL_COLLECTION.v_instance_id;
			  commit;

		         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
		         RAISE;

		   END LOAD_ODS_SUPPLY;

PROCEDURE LOAD_PAYBACK_SUPPLIES IS

  lv_supply_tbl VARCHAR2(1000);
  lv_sql_stmt VARCHAR2(32767);

BEGIN

	IF MSC_CL_COLLECTION.v_exchange_mode=MSC_UTIL.SYS_YES THEN
	       lv_supply_tbl:= 'SUPPLIES_'||MSC_CL_COLLECTION.v_instance_code;
	ELSE
	       lv_supply_tbl:= 'MSC_SUPPLIES';
	END IF;


lv_sql_stmt:=
'INSERT INTO '||lv_supply_tbl||
'(PLAN_ID,
TRANSACTION_ID,
NEW_ORDER_QUANTITY,
NEW_SCHEDULE_DATE,
FIRM_PLANNED_TYPE,
ORDER_TYPE,
ORGANIZATION_ID,
INVENTORY_ITEM_ID,
SR_INSTANCE_ID,
PROJECT_ID,
TASK_ID,
PLANNING_GROUP,
LAST_UPDATE_DATE,
LAST_UPDATED_BY,
CREATION_DATE,
CREATED_BY)
SELECT
 -1 PLAN_ID,
 MSC_SUPPLIES_S.NEXTVAL,
 MOP.QUANTITY,
 MOP.SCHEDULED_PAYBACK_DATE,
 1,               -- FIRM_PLANNED_TYPE
 29,    	   	-- order_type
 MOP.ORGANIZATION_ID,
 MIIL.INVENTORY_ITEM_ID,
 MOP.SR_INSTANCE_ID,
 MOP.LENDING_PROJECT_ID,
 MOP.LENDING_TASK_ID,
 MOP.LENDING_PROJ_PLANNING_GROUP,
:v_current_date ,
:v_current_user,
:v_current_date,
:v_current_user
FROM 	MSC_ST_OPEN_PAYBACKS MOP, MSC_ITEM_ID_LID MIIL
WHERE MIIL.SR_INVENTORY_ITEM_ID =  MOP.inventory_item_id
  AND MIIL.sr_instance_id       =  MOP.sr_instance_id
  AND MOP.sr_instance_id 	=    :v_instance_id';


EXECUTE IMMEDIATE lv_sql_stmt
USING MSC_CL_COLLECTION.v_current_date,
      MSC_CL_COLLECTION.v_current_user,
      MSC_CL_COLLECTION.v_current_date,
      MSC_CL_COLLECTION.v_current_user,
      MSC_CL_COLLECTION.v_instance_id;

		COMMIT;
END LOAD_PAYBACK_SUPPLIES;


END MSC_CL_SUPPLY_ODS_LOAD;

/
