--------------------------------------------------------
--  DDL for Package Body ISC_DBI_MSC_OBJECTS_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_MSC_OBJECTS_C" AS
/* $Header: ISCSCF8B.pls 120.5.12000000.2 2007/01/23 20:36:28 achandak ship $ */

  g_errbuf		VARCHAR2(2000) 	:= NULL;
  g_retcode		VARCHAR2(200) 	:= '0';

  g_isc_schema   	VARCHAR2(30);
  g_status      	VARCHAR2(30);
  g_industry     	VARCHAR2(30);
  g_db_link		VARCHAR2(200)	:= NULL;
  g_batch_size		NUMBER;
  g_row_count		NUMBER;
  g_snapshot_date	DATE;
  g_global_currency	VARCHAR2(15);
  g_global_rate_type   	VARCHAR2(15);
  g_sec_global_currency	VARCHAR2(15);
  g_sec_global_rate_type VARCHAR2(15);
  g_rebuild_snapshot_index VARCHAR2(1)	:= 'N';

  TYPE 			TableList IS TABLE OF VARCHAR2(80);
  g_small_bases		TableList := TableList('ISC_DBI_PLAN_ORGANIZATIONS', 'ISC_DBI_PLAN_BUCKETS', 'ISC_DBI_PLANS');
  g_large_bases		TableList := TableList('ISC_DBI_SUPPLIES_F','ISC_DBI_INV_DETAIL_F','ISC_DBI_RES_SUMMARY_F',
				       	       'ISC_DBI_EXCEPTION_DETAILS_F','ISC_DBI_DEMANDS_F',
					       'ISC_DBI_FULL_PEGGING_F');

  g_small_snapshots	TableList := TableList('ISC_DBI_PLAN_ORG_SNAPSHOTS', 'ISC_DBI_PLAN_SNAPSHOTS');
  g_large_snapshots	TableList := TableList('ISC_DBI_SUPPLIES_SNAPSHOTS','ISC_DBI_INV_DETAIL_SNAPSHOTS',
					       'ISC_DBI_RES_SUM_SNAPSHOTS', 'ISC_DBI_SHORTFALL_SNAPSHOTS');

FUNCTION DROP_PLANS(p_plan_id NUMBER) RETURN NUMBER IS

  l_delete_stmt VARCHAR2(2000);
  l_drop_stmt	VARCHAR2(2000);
  no_partition EXCEPTION;
  PRAGMA EXCEPTION_INIT(no_partition, -02149);

BEGIN

  FOR j in 1..g_large_bases.last LOOP
     BEGIN
       l_drop_stmt := 'ALTER TABLE '|| g_isc_schema || '.' || g_large_bases(j) || ' DROP PARTITION plan_' || p_plan_id;
       EXECUTE IMMEDIATE l_drop_stmt;
     EXCEPTION
       WHEN no_partition THEN
        BIS_COLLECTION_UTILITIES.put_line('The partition plan_' || p_plan_id || ' of table '|| g_large_bases(j) ||' does not exist.');
     END;
  END LOOP;

  FOR i in 1..g_small_bases.last LOOP
       l_delete_stmt := 'DELETE FROM ' || g_small_bases(i) || ' WHERE plan_id = :1';
       EXECUTE IMMEDIATE l_delete_stmt USING p_plan_id;
  END LOOP;

  RETURN(1);

EXCEPTION
  WHEN OTHERS THEN
    g_errbuf  := 'Error in function DROP_PLANS : '||sqlerrm;
    RETURN(-1);
END;

FUNCTION DROP_SNAPSHOTS(p_snapshot_id NUMBER) RETURN NUMBER IS

  l_delete_stmt VARCHAR2(2000);
  l_drop_stmt	VARCHAR2(2000);
  no_partition EXCEPTION;
  PRAGMA EXCEPTION_INIT(no_partition, -02149);

BEGIN

  FOR j in 1..g_large_snapshots.last LOOP
     BEGIN

       l_drop_stmt := 'ALTER TABLE '|| g_isc_schema || '.' || g_large_snapshots(j) || ' DROP PARTITION s_' || p_snapshot_id;
       EXECUTE IMMEDIATE l_drop_stmt;

     EXCEPTION
       WHEN no_partition THEN
        BIS_COLLECTION_UTILITIES.put_line('The partition s_'||p_snapshot_id||' of table '||g_large_snapshots(j)||' does not exist.');
     END;
  END LOOP;

  g_rebuild_snapshot_index := 'Y';

  FOR i in 1..g_small_snapshots.last LOOP
       l_delete_stmt := 'DELETE FROM ' || g_small_snapshots(i) || ' WHERE snapshot_id = :1';
       EXECUTE IMMEDIATE l_delete_stmt USING p_snapshot_id;
  END LOOP;

  RETURN(1);

EXCEPTION
  WHEN OTHERS THEN
    g_errbuf  := 'Error in function DROP_SNAPSHOTS : '||sqlerrm;
    RETURN(-1);
END;


      -- -----------
      -- CHECK_SETUP
      -- -----------

FUNCTION CHECK_SETUP RETURN NUMBER IS

  l_trunc_stmt		VARCHAR2(500);
  l_instance_stmt	VARCHAR2(2000);
  l_stmt		VARCHAR2(2000);
  l_num_all_sources	NUMBER;
  l_num_sources		NUMBER;
  l_plan_id		NUMBER;
  l_drop		NUMBER;
  l_sec_curr_def  	VARCHAR2(1);

BEGIN

  BIS_COLLECTION_UTILITIES.Put_Line(' ');

  IF (NOT FND_INSTALLATION.GET_APP_INFO('ISC', g_status, g_industry, g_isc_schema)) THEN
     g_errbuf := 'Error while retrieving product information.';
     RETURN (-1);
  END IF;

  l_sec_curr_def := isc_dbi_currency_pkg.is_sec_curr_defined;
  IF (l_sec_curr_def = 'E') THEN
     g_errbuf  := 'Collection aborted because the set-up of the DBI Global Parameter "Secondary Global Currency" is incomplete. Please verify the proper set-up of the Global Currency Rate Type and the Global Currency Code.';
     return(-1);
  END IF;

  BIS_COLLECTION_UTILITIES.put_line('The schema name is '|| g_isc_schema);

  g_batch_size := bis_common_parameters.get_batch_size(bis_common_parameters.high);
  BIS_COLLECTION_UTILITIES.put_line('The batch size is ' || g_batch_size);

  g_global_currency := bis_common_parameters.get_currency_code;
  BIS_COLLECTION_UTILITIES.put_line('The global currency code is ' || g_global_currency);

  g_global_rate_type := bis_common_parameters.get_rate_type;
  BIS_COLLECTION_UTILITIES.put_line('The primary rate type is ' || g_global_rate_type);

 g_sec_global_currency := bis_common_parameters.get_secondary_currency_code;
 BIS_COLLECTION_UTILITIES.put_line('The secondary global currency code is ' || g_sec_global_currency);

 g_sec_global_rate_type := bis_common_parameters.get_secondary_rate_type;
 BIS_COLLECTION_UTILITIES.put_line('The secondary rate type is ' || g_sec_global_rate_type);

  -- To get the database link to APS instance
  -- If the db link is NULL,
  -- that means APS and ERP are sitting in the same instance

  -- The program will error out if there are more than one row in this table

 g_db_link := FND_PROFILE.VALUE('ISC_DBI_PLANNING_INSTANCE');

 IF (g_db_link is NULL) THEN
    BEGIN
       SELECT decode(ltrim(a2m_dblink, ' '), NULL, NULL, '@'||a2m_dblink)
         INTO g_db_link
         FROM mrp_ap_apps_instances_all;
    EXCEPTION
       WHEN TOO_MANY_ROWS THEN
          g_errbuf := 'There are multiple APS desitinations for this ERP instance. Only one APS instance is supported. Please set up the profile option (ISC: DBI Planning Instance) with the DBI planning instance.';
          RETURN(-1);
       WHEN NO_DATA_FOUND THEN
          g_errbuf := 'This ERP instance is not configured as a source of APS.';
          RETURN(-1);
    END;
 ELSIF (g_db_link = '@') THEN
    g_db_link := NULL;
 END IF;

  BIS_COLLECTION_UTILITIES.put_line('Retrieve the db link '|| g_db_link);

  l_stmt := 'SELECT count(*) FROM msc_apps_instances' || g_db_link ||
	    ' WHERE enable_flag = 1 AND apps_ver NOT IN (1,2)';

  EXECUTE IMMEDIATE l_stmt INTO l_num_all_sources;
  BIS_COLLECTION_UTILITIES.put_line('The number of ERP instances is '|| l_num_all_sources);

  IF (l_num_all_sources > 1) THEN
     g_errbuf := 'There are more than one ERP sources. DBI only supports one ERP source.';
     RETURN (-1);
  ELSIF (l_num_all_sources = 0) THEN
     g_errbuf := 'No ERP source has been set up.';
     RETURN (-1);
  END IF;

  l_trunc_stmt := 'truncate table ' || g_isc_schema ||'.isc_dbi_apps_instances';
  EXECUTE IMMEDIATE l_trunc_stmt;

  BIS_COLLECTION_UTILITIES.put_line('Begin to collect instance information');
  FII_UTIL.Start_Timer;

  l_stmt := 'INSERT INTO isc_dbi_apps_instances (' ||
		  ' instance_id, currency, instance_code, ' ||
		  ' m2a_dblink, a2m_dblink, created_by, creation_date, '||
		  ' last_updated_by, last_update_date, last_update_login)' ||
	    'SELECT msc_inst.instance_id, msc_inst.currency, msc_inst.instance_code, ' ||
		   'msc_inst.m2a_dblink, msc_inst.a2m_dblink, msc_inst.created_by, msc_inst.creation_date, '||
		   'msc_inst.last_updated_by, msc_inst.last_update_date, msc_inst.last_update_login ' ||
	      'FROM msc_apps_instances' || g_db_link || ' msc_inst ' ||
             'WHERE enable_flag = 1 AND apps_ver NOT IN (1,2)';
  EXECUTE IMMEDIATE l_stmt;
  l_num_sources := sql%rowcount;
  COMMIT;

  IF (l_num_sources = 0) THEN
     g_errbuf := 'No corresponding source instance defined in the APS instance.';
     RETURN (-1);
  END IF;

  FII_UTIL.Stop_Timer;
  FII_UTIL.Print_Timer('Collected instance information in');
  BIS_COLLECTION_UTILITIES.Put_Line(' ');

/* From DBI7.0, functional and DBI global currencies will be used. */

--  BIS_COLLECTION_UTILITIES.put_line('Begin to validate APS currency.');
--  FII_UTIL.Start_Timer;
--
--  SELECT count(*)
--    INTO l_currency
--    FROM isc_dbi_apps_instances i, fnd_currencies cur
--   WHERE i.currency = cur.currency_code;
--
--  IF (l_currency = 0) THEN
--    g_retcode := 1;
--    g_errbuf := 'The planning currency code is invalid.';
--    BIS_COLLECTION_UTILITIES.Put_Line('The planning currency code is invalid.');
--    BIS_COLLECTION_UTILITIES.Put_Line(' ');
--    BIS_COLLECTION_UTILITIES.Put_Line_Out(' ');
--    BIS_COLLECTION_UTILITIES.Put_Line_Out(fnd_message.get_string('ISC', 'ISC_DBI_INVALID_CURRENCY'));
--    BIS_COLLECTION_UTILITIES.Put_Line_Out(' ');
--  END IF;
--
--  FII_UTIL.Stop_Timer;
--  FII_UTIL.Print_Timer('Validated the planning currency in');
--  BIS_COLLECTION_UTILITIES.Put_Line(' ');


  RETURN(1);

EXCEPTION
  WHEN OTHERS THEN
    g_errbuf  := 'Error in function CHECK_SETUP : '||sqlerrm;
    RETURN(-1);

END check_setup;

      -- ------------------------------
      -- Identify Plans to be collected
      -- ------------------------------

FUNCTION IDENTIFY_PLANS RETURN NUMBER IS

  l_count 	NUMBER;
  l_trunc_stmt	VARCHAR2(500);
  l_stmt	VARCHAR2(2000);
  l_plan_id	NUMBER;

  CURSOR Obsolete_Plans IS
    SELECT tmp.plan_id
      FROM isc_dbi_tmp_plans tmp
     WHERE nvl(tmp.old_data_start_date, tmp.data_start_date-1) < tmp.data_start_date;

BEGIN

  l_count := 0;

      --  ------------------------------------------------------------
      --  Insert the plans need to be collected into ISC_DBI_TMP_PLANS
      --  ------------------------------------------------------------

  BIS_COLLECTION_UTILITIES.put_line('Truncating the temp table');
  FII_UTIL.Start_Timer;

  l_trunc_stmt := 'truncate table ' || g_isc_schema ||'.isc_dbi_tmp_plans';
  EXECUTE IMMEDIATE l_trunc_stmt;

  FII_UTIL.Stop_Timer;
  FII_UTIL.Print_Timer('Truncated the temp table in');
  BIS_COLLECTION_UTILITIES.Put_Line(' ');

  g_snapshot_date := sysdate;
  BIS_COLLECTION_UTILITIES.put_line('The snapshot date is '|| to_char(g_snapshot_date, 'MM/DD/YYYY HH24:MI:SS'));

  BIS_COLLECTION_UTILITIES.put_line('Begin to load into the temp table.');
  FII_UTIL.Start_Timer;

  l_stmt := 'INSERT INTO isc_dbi_tmp_plans (' ||
  		'PLAN_ID, PLAN_NAME, OLD_DATA_START_DATE, DATA_START_DATE, ' ||
  		'INSTANCE_ID, PLAN_USAGE) ' ||
  	    'SELECT setup.plan_id, setup.plan_name, p.data_start_date, setup.data_start_date, inst.instance_id, '||
         	   'sum(plan_usage) '||
    	      'FROM isc_dbi_plans p, isc_dbi_apps_instances inst, '||
         	    '(SELECT plan.plan_id, opi.plan_name, plan.data_start_date,1 PLAN_USAGE '||
	               'FROM opi_dbi_baseline_schedules sched, opi_dbi_baseline_plans opi, '||
	         	     'msc_plans' || g_db_link || ' plan '||
  	      	      'WHERE sched.baseline_id = opi.baseline_id '||
   	        	'AND sched.next_collection_date <= trunc(sysdate) '||
   	        	'AND sched.schedule_type = 1 '||
	        	'AND opi.plan_name = plan.compile_designator '||
	     	      'UNION ALL '||
	     	     'SELECT plan.plan_id, isc.plan_name, plan.data_start_date, '||
			    '(CASE WHEN isc.last_collected_date < plan.data_start_date THEN 2
				   WHEN isc.last_collected_date is null THEN 2 ELSE 4 END) PLAN_USAGE '||
  	       	       'FROM isc_dbi_plan_schedules isc, msc_plans' || g_db_link || ' plan ' ||
 	   	      'WHERE isc.next_collection_date <= trunc(sysdate)'||
	     		'AND isc.plan_name = plan.compile_designator) setup '||
	     'WHERE p.compile_designator(+) = setup.plan_name '||
--     	       'AND p.complete_flag(+) = ''Y'' '||
   	     'GROUP BY setup.plan_id, setup.plan_name, p.data_start_date, setup.data_start_date, inst.instance_id';
  EXECUTE IMMEDIATE l_stmt;
  l_count := SQL%ROWCOUNT;
  COMMIT;

  FII_UTIL.Stop_Timer;
  FII_UTIL.Print_Timer('Retrieved '|| l_count || ' plans from setup tables in');
  BIS_COLLECTION_UTILITIES.Put_Line(' ');

  BIS_COLLECTION_UTILITIES.Put_Line(' ');
  BIS_COLLECTION_UTILITIES.Put_Line('Analyzing table ISC_DBI_TMP_PLANS');
  FII_UTIL.Start_Timer;

  FND_STATS.GATHER_TABLE_STATS(OWNNAME => g_isc_schema,
		 	       TABNAME => 'ISC_DBI_TMP_PLANS');

  FII_UTIL.Stop_Timer;
  FII_UTIL.Print_Timer('Analyzed table ISC_DBI_TMP_PLANS in ');

  -- Clean up the obsolete planned data

  l_count := 0;
  OPEN Obsolete_Plans;
  FETCH Obsolete_Plans INTO l_plan_id;
  IF Obsolete_Plans%ROWCOUNT <> 0 THEN
    WHILE Obsolete_Plans%Found LOOP
      BIS_COLLECTION_UTILITIES.Put_Line('Dropping plan '||l_plan_id);
      IF (DROP_PLANS(l_plan_id) = -1) THEN RETURN(-1); END IF;
      l_count := l_count +1;
      FETCH Obsolete_Plans INTO l_plan_id;
    END LOOP;
  END IF;
  CLOSE Obsolete_Plans;

/*
  SELECT count(*)
    INTO l_count
    FROM isc_dbi_tmp_plans tmp
   WHERE nvl(tmp.old_data_start_date, tmp.data_start_date-1) < tmp.data_start_date;
*/

  BIS_COLLECTION_UTILITIES.Put_Line('Identified '|| l_count || ' plans need to be collected.');
  RETURN(l_count);

EXCEPTION
  WHEN OTHERS THEN
     g_errbuf  := 'Error in function Identify_Plans : '||sqlerrm;
     RETURN(-1);

END identify_plans;

FUNCTION PULL_DATA RETURN NUMBER IS

  l_insert_stmt	VARCHAR2(32767);
  l_sel_stmt1 	VARCHAR2(32767);
  l_sel_stmt2 	VARCHAR2(32767);
  l_count	NUMBER;
  l_add_stmt	VARCHAR2(2000);
  l_add_plan_id	NUMBER;
  l_trunc_stmt	VARCHAR2(500);
  l_in_length	NUMBER;
  l_sel_length1	NUMBER;
  l_sel_length2	NUMBER;

  partition_exists EXCEPTION;
  PRAGMA EXCEPTION_INIT(partition_exists, -14013);

  part_value_exists EXCEPTION;
  PRAGMA EXCEPTION_INIT(part_value_exists, -14312);

  CURSOR Plan_List IS
    SELECT plan_id FROM isc_dbi_tmp_plans tmp
     WHERE nvl(tmp.old_data_start_date, tmp.data_start_date-1) < tmp.data_start_date;

BEGIN

      --  --------------
      --  Add Partitions
      --  --------------

  OPEN Plan_List;
  FETCH Plan_List INTO l_add_plan_id;
  IF Plan_List%ROWCOUNT <> 0 THEN
    WHILE Plan_List%Found LOOP
      BIS_COLLECTION_UTILITIES.Put_Line('Adding partitions for plan '|| l_add_plan_id);
      FOR i in 1..g_large_bases.last LOOP
	BEGIN
          l_add_stmt := 'ALTER TABLE '||g_isc_schema||'.'||g_large_bases(i)||' ADD PARTITION plan_'|| l_add_plan_id ||' VALUES ('''||l_add_plan_id||''')';
          EXECUTE IMMEDIATE l_add_stmt;
        EXCEPTION
          WHEN partition_exists THEN
            BIS_COLLECTION_UTILITIES.put_line('The partition plan_'||l_add_plan_id||' of table '||g_large_bases(i)||' already exists.');
	      NULL;
          WHEN part_value_exists THEN
            BIS_COLLECTION_UTILITIES.put_line('The value '||l_add_plan_id||' already exists in another partition of table '||g_large_bases(i));
	      NULL;
       END;
      END LOOP;
      FETCH Plan_List INTO l_add_plan_id;
    END LOOP;
  END IF;
  l_count := Plan_List%ROWCOUNT;
  CLOSE Plan_List;

  l_trunc_stmt := 'truncate table ' || g_isc_schema ||'.isc_dbi_periods';
  EXECUTE IMMEDIATE l_trunc_stmt;
  BIS_COLLECTION_UTILITIES.put_line('Table isc_dbi_periods has been truncated.');

  BIS_COLLECTION_UTILITIES.put_line('Begin to load the base tables from APS instance.');
  FII_UTIL.Start_Timer;

l_insert_stmt := 'INSERT /*+ APPEND PARALLEL */ FIRST '||
	    'WHEN union_flag = 1 THEN '||
	      'INTO isc_dbi_plans ( ' ||
 	  	'PLAN_ID,ORGANIZATION_ID,COMPILE_DESIGNATOR,CONSTRAINED_FLAG,CURR_CUTOFF_DATE,'||
		'CURR_PLAN_TYPE,CURR_START_DATE,CUTOFF_DATE,DATA_START_DATE,DESCRIPTION,COMPLETE_FLAG,'||
		'CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN) '||
	      'VALUES(plan_id,organization_id,compile_designator,constrained_flag, curr_cutoff_date,'||
		     'curr_plan_type,curr_start_date,cutoff_date,data_start_date,description,complete_flag,'||
		     'created_by,creation_date,last_updated_by,last_update_date,last_update_login) '||
	    'WHEN union_flag = 2 THEN '||
	      'INTO isc_dbi_plan_organizations ( '||
		'PLAN_ID,ORGANIZATION_ID,CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN) '||
	      'VALUES(plan_id,organization_id,'||
		     'created_by,creation_date,last_updated_by,last_update_date,last_update_login) '||
	    'WHEN union_flag = 3 THEN '||
	      'INTO isc_dbi_plan_buckets ( '||
		'PLAN_ID,ORGANIZATION_ID,BKT_END_DATE,BKT_START_DATE,'||
		'BUCKET_INDEX,BUCKET_TYPE,CURR_FLAG,DAYS_IN_BKT,'||
		'CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN) '||
	      'VALUES(plan_id,organization_id,bkt_end_date,bkt_start_date,'||
		     'bucket_index,bucket_type,curr_flag,days_in_bkt,'||
		     'created_by,creation_date,last_updated_by,last_update_date,last_update_login) '||
	   'WHEN union_flag = 4 THEN '||
 	     'INTO isc_dbi_supplies_f ( '||
  		'PLAN_ID,TRANSACTION_ID,ORGANIZATION_ID,TIME_NEW_SCH_DATE_ID,SOURCE_ORGANIZATION_ID,'||
		'SOURCE_SR_INSTANCE_ID,SOURCE_SUPPLIER_ID,SOURCE_SUPPLIER_SITE_ID,SR_INSTANCE_ID,SR_INVENTORY_ITEM_ID,'||
	  	'SR_SUPPLIER_ID,SUPPLIER_ID,SUPPLIER_SITE_ID,BOM_ITEM_TYPE,DISPOSITION_STATUS_TYPE,'||
		'IN_SOURCE_PLAN,ITEM_PRICE,NEW_ORDER_QUANTITY,NEW_PROCESSING_DAYS,NEW_SCHEDULE_DATE,ORDER_TYPE,'||
		'PLANNING_MAKE_BUY_CODE,R_CFM_ROUTING_FLAG,STANDARD_COST,UOM_CODE,'||
		'CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN) '||
	      'VALUES(plan_id,transaction_id,organization_id,time_new_sch_date_id,source_organization_id,'||
		     'source_sr_instance_id,source_supplier_id,source_supplier_site_id,sr_instance_id,'||
		     'sr_inventory_item_id,sr_supplier_id,supplier_id,supplier_site_id,bom_item_type,'||
		     'disposition_status_type,in_source_plan,item_price,new_order_quantity,'||
		     'new_processing_days,new_schedule_date,order_type,planning_make_buy_code,r_cfm_routing_flag,'||
		     'standard_cost,uom_code,'||
		     'created_by,creation_date,last_updated_by,last_update_date,last_update_login ) '||
	   'WHEN union_flag = 5 THEN '||
   	    'INTO isc_dbi_inv_detail_f (PLAN_ID,ORGANIZATION_ID,'||
	         'SR_INVENTORY_ITEM_ID,TIME_DETAIL_DATE_ID,CARRYING_COST,DETAIL_DATE,INVENTORY_COST,'||
	         'MDS_COST,MDS_PRICE,MDS_QUANTITY,PRODUCTION_COST,PURCHASING_COST,UOM_CODE,'||
	         'CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN) '||
	    'VALUES(plan_id,organization_id,sr_inventory_item_id,time_detail_date_id,carrying_cost,detail_date,'||
		   'inventory_cost,mds_cost,mds_price,mds_quantity,production_cost,purchasing_cost,'||
		   'uom_code,created_by,creation_date,last_updated_by,last_update_date,last_update_login) '||
	   'WHEN union_flag = 6 THEN '||
  	     'INTO isc_dbi_res_summary_f ( '||
  		'PLAN_ID,ORGANIZATION_ID,DEPARTMENT_ID,RESOURCE_ID,TIME_RESOURCE_DATE_ID,'||
		'AVAILABLE_HOURS,ORGANIZATION_TYPE,REQUIRED_HOURS,RESOURCE_DATE,UTILIZATION,'||
		'CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN) '||
	     'VALUES(plan_id,organization_id,department_id,resource_id,time_resource_date_id,'||
		    'available_hours,organization_type,required_hours,resource_date,utilization,'||
		    'created_by,creation_date,last_updated_by,last_update_date,last_update_login) '||
	   'WHEN union_flag = 7 THEN '||
  	    'INTO isc_dbi_exception_details_f ('||
		 'PLAN_ID,ORGANIZATION_ID,SR_INVENTORY_ITEM_ID,ORGANIZATION_TYPE,'||
		 'DEPARTMENT_ID, RESOURCE_ID, SR_SUPPLIER_ID, '||
		 'EXCEPTION_DETAIL_ID,EXCEPTION_TYPE,NUMBER1,NUMBER2,SR_SUPPLIER_SITE_ID,'||
		 'CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN) '||
	    'VALUES(plan_id,organization_id,sr_inventory_item_id,organization_type,'||
		   'department_id, resource_id, sr_supplier_id, '||
		   'exception_detail_id,exception_type,number1,number2,sr_supplier_site_id, '||
		   'created_by,creation_date,last_updated_by,last_update_date,last_update_login) '||
	   'WHEN union_flag = 8 THEN '||
  	     'INTO isc_dbi_demands_f (PLAN_ID,ORGANIZATION_ID,SR_INVENTORY_ITEM_ID,'||
		'DEMAND_ID,TIME_AS_DMD_COMP_DATE,TIME_DMD_DATE_ID,TIME_USING_AS_DMD_DATE,ASSEMBLY_DEMAND_COMP_DATE,'||
		'ORIGINATION_TYPE,UOM_CODE,USING_ASSEMBLY_DEMAND_DATE,'||
		'AVERAGE_DISCOUNT,LIST_PRICE,SELLING_PRICE,STANDARD_COST,USING_REQUIREMENT_QUANTITY,'||
		'CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN) '||
	     'VALUES(plan_id,organization_id,sr_inventory_item_id,demand_id,'||
		    'time_as_dmd_comp_date,time_dmd_date_id,time_using_as_dmd_date,assembly_demand_comp_date,'||
		    'origination_type,uom_code,using_assembly_demand_date,'||
		    'average_discount,list_price,selling_price,standard_cost,using_requirement_quantity,'||
		    'created_by,creation_date,last_updated_by,last_update_date,last_update_login) '||
	    'WHEN union_flag = 9 THEN '||
		'INTO isc_dbi_periods (ORGANIZATION_ID,PERIOD_SET_NAME,PERIOD_NAME,'||
		'START_DATE,END_DATE,YEAR_START_DATE,QUARTER_START_DATE,'||
		'PERIOD_TYPE,PERIOD_YEAR,PERIOD_NUM,QUARTER_NUM,'||
		'ENTERED_PERIOD_NAME,ADJUSTMENT_PERIOD_FLAG,DESCRIPTION,'||
		'CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN) '||
	     'VALUES(organization_id,period_set_name,period_name,'||
		    'start_date,end_date,year_start_date,quarter_start_date,'||
		    'period_type,period_year,period_num,quarter_num,'||
		    'entered_period_name,adjustment_period_flag,description,'||
		    'created_by,creation_date,last_updated_by,last_update_date,last_update_login) '||
	    'WHEN union_flag = 10 THEN '||
		'INTO isc_dbi_full_pegging_f (PLAN_ID,PEGGING_ID,DEMAND_ID,END_PEGGING_ID,TRANSACTION_ID,'||
		'CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN) '||
	     'VALUES(plan_id,pegging_id,demand_id, end_pegging_id, transaction_id,'||
		    'created_by,creation_date,last_updated_by,last_update_date,last_update_login) ';

l_sel_stmt1 := 'SELECT /*+ DRIVING_SITE (p) */ p.plan_id,p.organization_id,null SR_INVENTORY_ITEM_ID,null UOM_CODE,'||
		 'p.compile_designator,'||
                 'DECODE(daily_material_constraints,1,1,'||
		        'DECODE(daily_resource_constraints,1,1,'||
			       'DECODE(weekly_material_constraints,1,1,'||
				      'DECODE(weekly_resource_constraints,1,1,'||
                 		             'DECODE(period_material_constraints, 1, 1,'||
                 			            'DECODE(period_resource_constraints, 1, 1, 2)))))) CONSTRAINED_FLAG,'||
		 'p.curr_cutoff_date,p.curr_plan_type,'||
		 'p.curr_start_date,p.cutoff_date,p.data_start_date,p.description,''N'' complete_flag,'||
		 'null BKT_END_DATE,null BKT_START_DATE,'||
		 'null BUCKET_INDEX,null BUCKET_TYPE,null CURR_FLAG,null DAYS_IN_BKT,'||
		 'null TRANSACTION_ID,null TIME_NEW_SCH_DATE_ID,null SOURCE_ORGANIZATION_ID,'||
		 'null SOURCE_SR_INSTANCE_ID,null SOURCE_SUPPLIER_ID,null SOURCE_SUPPLIER_SITE_ID,null SR_INSTANCE_ID,'||
		 'null SR_SUPPLIER_ID,null SUPPLIER_ID,null SUPPLIER_SITE_ID,null BOM_ITEM_TYPE,'||
		 'null DISPOSITION_STATUS_TYPE,null IN_SOURCE_PLAN,null ITEM_PRICE,'||
		 'null NEW_ORDER_QUANTITY,null NEW_PROCESSING_DAYS,null NEW_SCHEDULE_DATE,null ORDER_TYPE,'||
		 'null PLANNING_MAKE_BUY_CODE,null R_CFM_ROUTING_FLAG,null STANDARD_COST,'||
	 	 'null TIME_DETAIL_DATE_ID,null CARRYING_COST,'||
		 'null DETAIL_DATE,null INVENTORY_COST,null MDS_COST,null MDS_PRICE,null MDS_QUANTITY,'||
		'null PRODUCTION_COST,null PURCHASING_COST,'||
		'null RESOURCE_ID,null DEPARTMENT_ID,'||
		'null TIME_RESOURCE_DATE_ID,null AVAILABLE_HOURS,null ORGANIZATION_TYPE,null REQUIRED_HOURS,'||
		'null RESOURCE_DATE,null UTILIZATION,'||
		'null EXCEPTION_DETAIL_ID,null EXCEPTION_TYPE,null NUMBER1,null NUMBER2, null SR_SUPPLIER_SITE_ID,'||
		'null DEMAND_ID,null TIME_AS_DMD_COMP_DATE,null TIME_DMD_DATE_ID,null TIME_USING_AS_DMD_DATE,'||
		'null ASSEMBLY_DEMAND_COMP_DATE,null ORIGINATION_TYPE,null USING_ASSEMBLY_DEMAND_DATE,'||
		'null AVERAGE_DISCOUNT,null LIST_PRICE,null SELLING_PRICE,null USING_REQUIREMENT_QUANTITY,'||
	'null PERIOD_SET_NAME,null PERIOD_NAME,null START_DATE,null END_DATE,'||
	'null YEAR_START_DATE,null QUARTER_START_DATE,null PERIOD_TYPE,null PERIOD_YEAR,'||
	'null PERIOD_NUM,null QUARTER_NUM,null ENTERED_PERIOD_NAME,null ADJUSTMENT_PERIOD_FLAG,'||
	'null PEGGING_ID,null END_PEGGING_ID,'||
		 'p.created_by,p.creation_date,p.last_updated_by,p.last_update_date,p.last_update_login,1 union_flag '||
	   'FROM isc_dbi_tmp_plans tmp,msc_plans' || g_db_link || ' p '||
          'WHERE nvl(tmp.old_data_start_date,tmp.data_start_date-1) < tmp.data_start_date '||
            'AND tmp.plan_name = p.compile_designator '||
            'AND tmp.instance_id = p.sr_instance_id UNION ALL ' ||
 	  'SELECT /*+ DRIVING_SITE (po) */ po.plan_id,po.organization_id,null SR_INVENTORY_ITEM_ID,null UOM_CODE,'||
		 'null COMPILE_DESIGNATOR,null CONSTRAINED_FLAG,null CURR_CUTOFF_DATE,null CURR_PLAN_TYPE,'||
		 'null CURR_START_DATE,null CUTOFF_DATE,null DATA_START_DATE,null DESCRIPTION,''N'' COMPLETE_FLAG,'||
		 'null BKT_END_DATE,null BKT_START_DATE,'||
		 'null BUCKET_INDEX,null BUCKET_TYPE,null CURR_FLAG,null DAYS_IN_BKT,'||
		 'null TRANSACTION_ID,null TIME_NEW_SCH_DATE_ID,null SOURCE_ORGANIZATION_ID,'||
		 'null SOURCE_SR_INSTANCE_ID,null SOURCE_SUPPLIER_ID,null SOURCE_SUPPLIER_SITE_ID,null SR_INSTANCE_ID,'||
		 'null SR_SUPPLIER_ID,null SUPPLIER_ID,null SUPPLIER_SITE_ID,null BOM_ITEM_TYPE,'||
		 'null DISPOSITION_STATUS_TYPE,null IN_SOURCE_PLAN,null ITEM_PRICE,'||
		 'null NEW_ORDER_QUANTITY,null NEW_PROCESSING_DAYS,null NEW_SCHEDULE_DATE,null ORDER_TYPE,'||
		 'null PLANNING_MAKE_BUY_CODE,null R_CFM_ROUTING_FLAG,null STANDARD_COST,'||
	 	 'null TIME_DETAIL_DATE_ID,null CARRYING_COST,'||
		 'null DETAIL_DATE,null INVENTORY_COST,null MDS_COST,null MDS_PRICE,null MDS_QUANTITY,'||
		'null PRODUCTION_COST,null PURCHASING_COST,'||
		'null RESOURCE_ID,null DEPARTMENT_ID,'||
		'null TIME_RESOURCE_DATE_ID,null AVAILABLE_HOURS,null ORGANIZATION_TYPE,null REQUIRED_HOURS,'||
		'null RESOURCE_DATE,null UTILIZATION,'||
		'null EXCEPTION_DETAIL_ID,null EXCEPTION_TYPE,null NUMBER1,null NUMBER2, null SR_SUPPLIER_SITE_ID,'||
		'null DEMAND_ID,null TIME_AS_DMD_COMP_DATE,null TIME_DMD_DATE_ID,null TIME_USING_AS_DMD_DATE,'||
		'null ASSEMBLY_DEMAND_COMP_DATE,null ORIGINATION_TYPE,null USING_ASSEMBLY_DEMAND_DATE,'||
		'null AVERAGE_DISCOUNT,null LIST_PRICE,null SELLING_PRICE,null USING_REQUIREMENT_QUANTITY,'||
	'null PERIOD_SET_NAME,null PERIOD_NAME,null START_DATE,null END_DATE,'||
	'null YEAR_START_DATE,null QUARTER_START_DATE,null PERIOD_TYPE,null PERIOD_YEAR,'||
	'null PERIOD_NUM,null QUARTER_NUM,null ENTERED_PERIOD_NAME,null ADJUSTMENT_PERIOD_FLAG,'||
	'null PEGGING_ID,null END_PEGGING_ID,'||
		'po.created_by,po.creation_date,po.last_updated_by,po.last_update_date,po.last_update_login,2 union_flag '||
            'FROM isc_dbi_tmp_plans tmp,msc_plan_organizations' || g_db_link || ' po '||
	   'WHERE nvl(tmp.old_data_start_date,tmp.data_start_date-1) < tmp.data_start_date '||
	     'AND tmp.plan_id = po.plan_id '||
   	     'AND tmp.instance_id = po.sr_instance_id UNION ALL '||
  	  'SELECT /*+ DRIVING_SITE (pb) */ pb.plan_id,pb.organization_id,null SR_INVENTORY_ITEM_ID,null UOM_CODE,'||
		 'null COMPILE_DESIGNATOR,null CONSTRAINED_FLAG,null CURR_CUTOFF_DATE,null CURR_PLAN_TYPE,'||
		 'null CURR_START_DATE,null CUTOFF_DATE,null DATA_START_DATE,null DESCRIPTION,''N'' COMPLETE_FLAG,'||
		  'pb.bkt_end_date,pb.bkt_start_date,'||
		  'pb.bucket_index,pb.bucket_type,pb.curr_flag,pb.days_in_bkt,'||
		 'null TRANSACTION_ID,null TIME_NEW_SCH_DATE_ID,null SOURCE_ORGANIZATION_ID,'||
		 'null SOURCE_SR_INSTANCE_ID,null SOURCE_SUPPLIER_ID,null SOURCE_SUPPLIER_SITE_ID,null SR_INSTANCE_ID,'||
		 'null SR_SUPPLIER_ID,null SUPPLIER_ID,null SUPPLIER_SITE_ID,null BOM_ITEM_TYPE,'||
		 'null DISPOSITION_STATUS_TYPE,null IN_SOURCE_PLAN,null ITEM_PRICE,'||
		 'null NEW_ORDER_QUANTITY,null NEW_PROCESSING_DAYS,null NEW_SCHEDULE_DATE,null ORDER_TYPE,'||
		 'null PLANNING_MAKE_BUY_CODE,null R_CFM_ROUTING_FLAG,null STANDARD_COST,'||
	 	 'null TIME_DETAIL_DATE_ID,null CARRYING_COST,'||
		 'null DETAIL_DATE,null INVENTORY_COST,null MDS_COST,null MDS_PRICE,null MDS_QUANTITY,'||
		'null PRODUCTION_COST,null PURCHASING_COST,'||
		'null RESOURCE_ID,null DEPARTMENT_ID,'||
		'null TIME_RESOURCE_DATE_ID,null AVAILABLE_HOURS,null ORGANIZATION_TYPE,null REQUIRED_HOURS,'||
		'null RESOURCE_DATE,null UTILIZATION,'||
		'null EXCEPTION_DETAIL_ID,null EXCEPTION_TYPE,null NUMBER1,null NUMBER2, null SR_SUPPLIER_SITE_ID,'||
		'null DEMAND_ID,null TIME_AS_DMD_COMP_DATE,null TIME_DMD_DATE_ID,null TIME_USING_AS_DMD_DATE,'||
		'null ASSEMBLY_DEMAND_COMP_DATE,null ORIGINATION_TYPE,null USING_ASSEMBLY_DEMAND_DATE,'||
		'null AVERAGE_DISCOUNT,null LIST_PRICE,null SELLING_PRICE,null USING_REQUIREMENT_QUANTITY,'||
	'null PERIOD_SET_NAME,null PERIOD_NAME,null START_DATE,null END_DATE,'||
	'null YEAR_START_DATE,null QUARTER_START_DATE,null PERIOD_TYPE,null PERIOD_YEAR,'||
	'null PERIOD_NUM,null QUARTER_NUM,null ENTERED_PERIOD_NAME,null ADJUSTMENT_PERIOD_FLAG,'||
	'null PEGGING_ID,null END_PEGGING_ID,'||
		'pb.created_by,pb.creation_date,pb.last_updated_by,pb.last_update_date,pb.last_update_login,3 union_flag '||
	    'FROM isc_dbi_tmp_plans tmp,msc_plan_buckets' || g_db_link || ' pb '||
 	   'WHERE nvl(tmp.old_data_start_date,tmp.data_start_date-1) < tmp.data_start_date '||
	     'AND tmp.plan_id = pb.plan_id '||
   	     'AND tmp.instance_id = pb.sr_instance_id UNION ALL '||
	  'SELECT /*+ DRIVING_SITE (s) parallel(it) parallel(s) parallel(r1) parallel(its2) parallel(tp) */ s.plan_id,s.organization_id,it.sr_inventory_item_id,it.uom_code,'||
		 'null COMPILE_DESIGNATOR,null CONSTRAINED_FLAG,null CURR_CUTOFF_DATE,null CURR_PLAN_TYPE,'||
		 'null CURR_START_DATE,null CUTOFF_DATE,null DATA_START_DATE,null DESCRIPTION,''N'' COMPLETE_FLAG,'||
		 'null BKT_END_DATE,null BKT_START_DATE,'||
		 'null BUCKET_INDEX,null BUCKET_TYPE,null CURR_FLAG,null DAYS_IN_BKT,'||
		 's.transaction_id,trunc(s.new_schedule_date) TIME_NEW_SCH_DATE_ID,s.source_organization_id,'||
		 's.source_sr_instance_id,s.source_supplier_id,s.source_supplier_site_id,s.sr_instance_id,'||
		 'tp.sr_tp_id SR_SUPPLIER_ID,s.supplier_id,s.supplier_site_id,it.bom_item_type,'||
		 's.disposition_status_type,it.in_source_plan,its2.item_price,'||
		 's.new_order_quantity,s.new_processing_days,s.new_schedule_date,s.order_type,'||
		 'it.planning_make_buy_code,r1.cfm_routing_flag R_CFM_ROUTING_FLAG,it.standard_cost,'||
	 	 'null TIME_DETAIL_DATE_ID,null CARRYING_COST,'||
		 'null DETAIL_DATE,null INVENTORY_COST,null MDS_COST,null MDS_PRICE,null MDS_QUANTITY,'||
		'null PRODUCTION_COST,null PURCHASING_COST,'||
		'null RESOURCE_ID,null DEPARTMENT_ID,'||
		'null TIME_RESOURCE_DATE_ID,null AVAILABLE_HOURS,null ORGANIZATION_TYPE,null REQUIRED_HOURS,'||
		'null RESOURCE_DATE,null UTILIZATION,'||
		'null EXCEPTION_DETAIL_ID,null EXCEPTION_TYPE,null NUMBER1,null NUMBER2, null SR_SUPPLIER_SITE_ID,'||
		'null DEMAND_ID,null TIME_AS_DMD_COMP_DATE,null TIME_DMD_DATE_ID,null TIME_USING_AS_DMD_DATE,'||
		'null ASSEMBLY_DEMAND_COMP_DATE,null ORIGINATION_TYPE,null USING_ASSEMBLY_DEMAND_DATE,'||
		'null AVERAGE_DISCOUNT,null LIST_PRICE,null SELLING_PRICE,null USING_REQUIREMENT_QUANTITY,'||
	'null PERIOD_SET_NAME,null PERIOD_NAME,null START_DATE,null END_DATE,'||
	'null YEAR_START_DATE,null QUARTER_START_DATE,null PERIOD_TYPE,null PERIOD_YEAR,'||
	'null PERIOD_NUM,null QUARTER_NUM,null ENTERED_PERIOD_NAME,null ADJUSTMENT_PERIOD_FLAG,'||
	'null PEGGING_ID,null END_PEGGING_ID,'||
		 's.created_by,s.creation_date,s.last_updated_by,s.last_update_date,s.last_update_login,4 union_flag '||
           'FROM isc_dbi_tmp_plans tmp,msc_supplies'|| g_db_link || ' s,msc_system_items'|| g_db_link ||' it,'||
		'msc_routings' || g_db_link || ' r1,msc_item_suppliers' || g_db_link || ' its2,'||
		'msc_tp_id_lid' || g_db_link || ' tp '||
  	  'WHERE tmp.plan_id = s.plan_id AND nvl(tmp.old_data_start_date,tmp.data_start_date-1) < tmp.data_start_date '||
    	    'AND tmp.instance_id = s.sr_instance_id '||
    	    'AND s.organization_id = it.organization_id '||
    	    'AND s.plan_id = it.plan_id '||
    	    'AND s.inventory_item_id = it.inventory_item_id '||
	    'AND s.sr_instance_id = it.sr_instance_id '||
	    'AND s.plan_id = r1.plan_id(+) '||
	    'AND s.routing_sequence_id = r1.routing_sequence_id(+) '||
	    'AND s.sr_instance_id = r1.sr_instance_id(+) '||
	    'AND s.plan_id = its2.plan_id(+) '||
	    'AND s.organization_id = its2.organization_id(+) '||
	    'AND s.inventory_item_id = its2.inventory_item_id(+) '||
	    'AND s.supplier_id = its2.supplier_id(+) '||
	    'AND s.supplier_site_id = its2.supplier_site_id(+) '||
	    'AND s.sr_instance_id = its2.sr_instance_id(+) '||
	    'AND s.order_type not in (5,27) '||
	    'AND tp.partner_type(+) = 1 '||
	    'AND s.supplier_id = tp.tp_id(+) '||
	    'AND s.sr_instance_id = tp.sr_instance_id(+) UNION ALL '||
	 'SELECT /*+ DRIVING_SITE (s) parallel(it) parallel(s) parallel(r2) parallel(its1) parallel(process) parallel(tp) */ s.plan_id,s.organization_id,it.sr_inventory_item_id,it.uom_code,'||
		'null COMPILE_DESIGNATOR,null CONSTRAINED_FLAG,null CURR_CUTOFF_DATE,null CURR_PLAN_TYPE,'||
		'null CURR_START_DATE,null CUTOFF_DATE,null DATA_START_DATE,null DESCRIPTION,''N'' COMPLETE_FLAG,'||
		'null BKT_END_DATE,null BKT_START_DATE,'||
		'null BUCKET_INDEX,null BUCKET_TYPE,null CURR_FLAG,null DAYS_IN_BKT,'||
		's.transaction_id,trunc(s.new_schedule_date) TIME_NEW_SCH_DATE_ID,s.source_organization_id,'||
		's.source_sr_instance_id,s.source_supplier_id,s.source_supplier_site_id,s.sr_instance_id,'||
		'tp.sr_tp_id SR_SUPPLIER_ID,s.supplier_id,s.supplier_site_id,it.bom_item_type,'||
		's.disposition_status_type,it.in_source_plan,its1.item_price,'||
		's.new_order_quantity,s.new_processing_days,s.new_schedule_date,s.order_type,'||
		'it.planning_make_buy_code,r2.cfm_routing_flag R_CFM_ROUTING_FLAG,it.standard_cost,'||
	 	 'null TIME_DETAIL_DATE_ID,null CARRYING_COST,'||
		 'null DETAIL_DATE,null INVENTORY_COST,null MDS_COST,null MDS_PRICE,null MDS_QUANTITY,'||
		'null PRODUCTION_COST,null PURCHASING_COST,'||
		'null RESOURCE_ID,null DEPARTMENT_ID,'||
		'null TIME_RESOURCE_DATE_ID,null AVAILABLE_HOURS,null ORGANIZATION_TYPE,null REQUIRED_HOURS,'||
		'null RESOURCE_DATE,null UTILIZATION,'||
		'null EXCEPTION_DETAIL_ID,null EXCEPTION_TYPE,null NUMBER1,null NUMBER2, null SR_SUPPLIER_SITE_ID,'||
		'null DEMAND_ID,null TIME_AS_DMD_COMP_DATE,null TIME_DMD_DATE_ID,null TIME_USING_AS_DMD_DATE,'||
		'null ASSEMBLY_DEMAND_COMP_DATE,null ORIGINATION_TYPE,null USING_ASSEMBLY_DEMAND_DATE,'||
		'null AVERAGE_DISCOUNT,null LIST_PRICE,null SELLING_PRICE,null USING_REQUIREMENT_QUANTITY,'||
	'null PERIOD_SET_NAME,null PERIOD_NAME,null START_DATE,null END_DATE,'||
	'null YEAR_START_DATE,null QUARTER_START_DATE,null PERIOD_TYPE,null PERIOD_YEAR,'||
	'null PERIOD_NUM,null QUARTER_NUM,null ENTERED_PERIOD_NAME,null ADJUSTMENT_PERIOD_FLAG,'||
	'null PEGGING_ID,null END_PEGGING_ID,'||
		's.created_by,s.creation_date,s.last_updated_by,s.last_update_date,s.last_update_login,4 union_flag '||
	   'FROM isc_dbi_tmp_plans tmp,msc_supplies'|| g_db_link || ' s,msc_system_items'|| g_db_link || ' it,'||
		'msc_process_effectivity'|| g_db_link || ' process,msc_routings'|| g_db_link || ' r2,'||
		'msc_item_suppliers'|| g_db_link || ' its1,msc_tp_id_lid'|| g_db_link || ' tp '||
  	  'WHERE tmp.plan_id = s.plan_id AND nvl(tmp.old_data_start_date,tmp.data_start_date-1) < tmp.data_start_date '||
	    'AND tmp.instance_id = s.sr_instance_id '||
	    'AND s.organization_id = it.organization_id '||
	    'AND s.plan_id = it.plan_id '||
	    'AND s.inventory_item_id = it.inventory_item_id '||
	    'AND s.sr_instance_id = it.sr_instance_id '||
	    'AND s.plan_id = process.plan_id (+) '||
	    'AND s.process_seq_id = process.process_sequence_id(+) '||
	    'AND s.sr_instance_id = process.sr_instance_id(+) '||
	    'AND process.plan_id = r2.plan_id (+) '||
	    'AND process.routing_sequence_id = r2.routing_sequence_id(+) '||
	    'AND process.sr_instance_id = r2.sr_instance_id(+) '||
	    'AND s.plan_id = its1.plan_id(+) '||
	    'AND s.organization_id = its1.organization_id(+) '||
	    'AND s.inventory_item_id = its1.inventory_item_id(+) '||
	    'AND s.source_supplier_id = its1.supplier_id(+) '||
	    'AND s.source_supplier_site_id = its1.supplier_site_id(+) '||
	    'AND s.sr_instance_id = its1.sr_instance_id(+) '||
	    'AND s.order_type in (5,27) '||
	    'AND tp.partner_type(+) = 1 '||
	    'AND s.source_supplier_id = tp.tp_id(+) '||
	    'AND s.sr_instance_id = tp.sr_instance_id(+) UNION ALL '||
  'SELECT /*+ DRIVING_SITE (inv) parallel(it) parallel(inv) */ inv.plan_id,inv.organization_id,it.sr_inventory_item_id,it.uom_code,'||
		 'null COMPILE_DESIGNATOR,null CONSTRAINED_FLAG,null CURR_CUTOFF_DATE,null CURR_PLAN_TYPE,'||
		 'null CURR_START_DATE,null CUTOFF_DATE,null DATA_START_DATE,null DESCRIPTION,''N'' COMPLETE_FLAG,'||
		 'null BKT_END_DATE,null BKT_START_DATE,'||
		 'null BUCKET_INDEX,null BUCKET_TYPE,null CURR_FLAG,null DAYS_IN_BKT,'||
		 'null TRANSACTION_ID,null TIME_NEW_SCH_DATE_ID,null SOURCE_ORGANIZATION_ID,'||
		 'null SOURCE_SR_INSTANCE_ID,null SOURCE_SUPPLIER_ID,null SOURCE_SUPPLIER_SITE_ID,null SR_INSTANCE_ID,'||
		 'null SR_SUPPLIER_ID,null SUPPLIER_ID,null SUPPLIER_SITE_ID,null BOM_ITEM_TYPE,'||
		 'null DISPOSITION_STATUS_TYPE,null IN_SOURCE_PLAN,null ITEM_PRICE,'||
		 'null NEW_ORDER_QUANTITY,null NEW_PROCESSING_DAYS,null NEW_SCHEDULE_DATE,null ORDER_TYPE,'||
		 'null PLANNING_MAKE_BUY_CODE,null R_CFM_ROUTING_FLAG,null STANDARD_COST,'||
		'trunc(inv.detail_date) TIME_DETAIL_DATE_ID,inv.carrying_cost,'||
		'inv.detail_date,inv.inventory_cost,inv.mds_cost,inv.mds_price,inv.mds_quantity,'||
		'inv.production_cost,inv.purchasing_cost,'||
		'null RESOURCE_ID,null DEPARTMENT_ID,'||
		'null TIME_RESOURCE_DATE_ID,null AVAILABLE_HOURS,null ORGANIZATION_TYPE,null REQUIRED_HOURS,'||
		'null RESOURCE_DATE,null UTILIZATION,'||
		'null EXCEPTION_DETAIL_ID,null EXCEPTION_TYPE,null NUMBER1,null NUMBER2, null SR_SUPPLIER_SITE_ID,'||
		'null DEMAND_ID,null TIME_AS_DMD_COMP_DATE,null TIME_DMD_DATE_ID,null TIME_USING_AS_DMD_DATE,'||
		'null ASSEMBLY_DEMAND_COMP_DATE,null ORIGINATION_TYPE,null USING_ASSEMBLY_DEMAND_DATE,'||
		'null AVERAGE_DISCOUNT,null LIST_PRICE,null SELLING_PRICE,null USING_REQUIREMENT_QUANTITY,'||
	'null PERIOD_SET_NAME,null PERIOD_NAME,null START_DATE,null END_DATE,'||
	'null YEAR_START_DATE,null QUARTER_START_DATE,null PERIOD_TYPE,null PERIOD_YEAR,'||
	'null PERIOD_NUM,null QUARTER_NUM,null ENTERED_PERIOD_NAME,null ADJUSTMENT_PERIOD_FLAG,'||
	'null PEGGING_ID,null END_PEGGING_ID,'||
	 	'inv.created_by,inv.creation_date,inv.last_updated_by,inv.last_update_date,inv.last_update_login,5 union_flag '||
   	   'FROM isc_dbi_tmp_plans tmp,msc_bis_inv_detail' ||g_db_link|| ' inv,msc_system_items' ||g_db_link|| ' it '||
          'WHERE tmp.plan_id = inv.plan_id AND nvl(tmp.old_data_start_date,tmp.data_start_date-1) < tmp.data_start_date '||
	    'AND tmp.instance_id = inv.sr_instance_id AND nvl(inv.period_type,0)=0 '||
	    'AND inv.plan_id = it.plan_id '||
	    'AND inv.inventory_item_id = it.inventory_item_id '||
	    'AND inv.organization_id = it.organization_id '||
	    'AND inv.sr_instance_id = it.sr_instance_id UNION ALL ';

l_sel_stmt2 :=	 'SELECT /*+ DRIVING_SITE (res) parallel(res) parallel(org) */ res.plan_id,res.organization_id,null SR_INVENTORY_ITEM_ID,null UOM_CODE,'||
		 'null COMPILE_DESIGNATOR,null CONSTRAINED_FLAG,null CURR_CUTOFF_DATE,null CURR_PLAN_TYPE,'||
		 'null CURR_START_DATE,null CUTOFF_DATE,null DATA_START_DATE,null DESCRIPTION,''N'' COMPLETE_FLAG,'||
		 'null BKT_END_DATE,null BKT_START_DATE,'||
		 'null BUCKET_INDEX,null BUCKET_TYPE,null CURR_FLAG,null DAYS_IN_BKT,'||
		 'null TRANSACTION_ID,null TIME_NEW_SCH_DATE_ID,null SOURCE_ORGANIZATION_ID,'||
		 'null SOURCE_SR_INSTANCE_ID,null SOURCE_SUPPLIER_ID,null SOURCE_SUPPLIER_SITE_ID,null SR_INSTANCE_ID,'||
		 'null SR_SUPPLIER_ID,null SUPPLIER_ID,null SUPPLIER_SITE_ID,null BOM_ITEM_TYPE,'||
		 'null DISPOSITION_STATUS_TYPE,null IN_SOURCE_PLAN,null ITEM_PRICE,'||
		 'null NEW_ORDER_QUANTITY,null NEW_PROCESSING_DAYS,null NEW_SCHEDULE_DATE,null ORDER_TYPE,'||
		 'null PLANNING_MAKE_BUY_CODE,null R_CFM_ROUTING_FLAG,null STANDARD_COST,'||
	 	 'null TIME_DETAIL_DATE_ID,null CARRYING_COST,'||
		 'null DETAIL_DATE,null INVENTORY_COST,null MDS_COST,null MDS_PRICE,null MDS_QUANTITY,'||
		'null PRODUCTION_COST,null PURCHASING_COST,'||
	       'decode(org.organization_type,1,res.resource_id/2,2,(res.resource_id-1)/2) RESOURCE_ID,'||
		'decode(org.organization_type,1,res.department_id/2,2,null) DEPARTMENT_ID,'||
		'trunc(res.resource_date) TIME_RESOURCE_DATE_ID,res.available_hours,org.organization_type,res.required_hours,'||
		'res.resource_date,res.utilization,'||
		'null EXCEPTION_DETAIL_ID,null EXCEPTION_TYPE,null NUMBER1,null NUMBER2, null SR_SUPPLIER_SITE_ID,'||
		'null DEMAND_ID,null TIME_AS_DMD_COMP_DATE,null TIME_DMD_DATE_ID,null TIME_USING_AS_DMD_DATE,'||
		'null ASSEMBLY_DEMAND_COMP_DATE,null ORIGINATION_TYPE,null USING_ASSEMBLY_DEMAND_DATE,'||
		'null AVERAGE_DISCOUNT,null LIST_PRICE,null SELLING_PRICE,null USING_REQUIREMENT_QUANTITY,'||
	'null PERIOD_SET_NAME,null PERIOD_NAME,null START_DATE,null END_DATE,'||
	'null YEAR_START_DATE,null QUARTER_START_DATE,null PERIOD_TYPE,null PERIOD_YEAR,'||
	'null PERIOD_NUM,null QUARTER_NUM,null ENTERED_PERIOD_NAME,null ADJUSTMENT_PERIOD_FLAG,'||
	'null PEGGING_ID,null END_PEGGING_ID,'||
		'res.created_by,res.creation_date,res.last_updated_by,res.last_update_date,res.last_update_login,6 union_flag '||
   	   'FROM isc_dbi_tmp_plans tmp,msc_bis_res_summary' || g_db_link|| ' res,msc_trading_partners' || g_db_link||' org '||
	  'WHERE tmp.plan_id = res.plan_id AND nvl(tmp.old_data_start_date,tmp.data_start_date-1) < tmp.data_start_date '||
	    'AND tmp.instance_id = res.sr_instance_id '||
	    'AND res.organization_id = org.sr_tp_id '||
	    'AND org.partner_type = 3 '||
	    'AND res.sr_instance_id = org.sr_instance_id UNION ALL '||
  	 'SELECT /*+ DRIVING_SITE (ex) */ ex.plan_id,ex.organization_id,it.sr_inventory_item_id,null UOM_CODE,'||
		 'null COMPILE_DESIGNATOR,null CONSTRAINED_FLAG,null CURR_CUTOFF_DATE,null CURR_PLAN_TYPE,'||
		 'null CURR_START_DATE,null CUTOFF_DATE,null DATA_START_DATE,null DESCRIPTION,''N'' COMPLETE_FLAG,'||
		 'null BKT_END_DATE,null BKT_START_DATE,'||
		 'null BUCKET_INDEX,null BUCKET_TYPE,null CURR_FLAG,null DAYS_IN_BKT,'||
		 'null TRANSACTION_ID,null TIME_NEW_SCH_DATE_ID,null SOURCE_ORGANIZATION_ID,'||
		 'null SOURCE_SR_INSTANCE_ID,null SOURCE_SUPPLIER_ID,null SOURCE_SUPPLIER_SITE_ID,null SR_INSTANCE_ID,'||
		 'tp.sr_tp_id SR_SUPPLIER_ID,null SUPPLIER_ID,null SUPPLIER_SITE_ID,null BOM_ITEM_TYPE,'||
		 'null DISPOSITION_STATUS_TYPE,null IN_SOURCE_PLAN,null ITEM_PRICE,'||
		 'null NEW_ORDER_QUANTITY,null NEW_PROCESSING_DAYS,null NEW_SCHEDULE_DATE,null ORDER_TYPE,'||
		 'null PLANNING_MAKE_BUY_CODE,null R_CFM_ROUTING_FLAG,null STANDARD_COST,'||
	 	 'null TIME_DETAIL_DATE_ID,null CARRYING_COST,'||
		 'null DETAIL_DATE,null INVENTORY_COST,null MDS_COST,null MDS_PRICE,null MDS_QUANTITY,'||
		'null PRODUCTION_COST,null PURCHASING_COST,'||
 	        'decode(org.organization_type,1,ex.resource_id/2,2,(ex.resource_id-1)/2) RESOURCE_ID,'||
		'decode(org.organization_type,1,ex.department_id/2,2,null) DEPARTMENT_ID,'||
		'null TIME_RESOURCE_DATE_ID,null AVAILABLE_HOURS,org.organization_type ORGANIZATION_TYPE,null REQUIRED_HOURS,'||
		'null RESOURCE_DATE,null UTILIZATION,'||
		'ex.exception_detail_id,ex.exception_type,ex.number1,ex.number2,tp_site.sr_tp_site_id SR_SUPPLIER_SITE_ID,'||
		'null DEMAND_ID,null TIME_AS_DMD_COMP_DATE,null TIME_DMD_DATE_ID,null TIME_USING_AS_DMD_DATE,'||
		'null ASSEMBLY_DEMAND_COMP_DATE,null ORIGINATION_TYPE,null USING_ASSEMBLY_DEMAND_DATE,'||
		'null AVERAGE_DISCOUNT,null LIST_PRICE,null SELLING_PRICE,null USING_REQUIREMENT_QUANTITY,'||
	'null PERIOD_SET_NAME,null PERIOD_NAME,null START_DATE,null END_DATE,'||
	'null YEAR_START_DATE,null QUARTER_START_DATE,null PERIOD_TYPE,null PERIOD_YEAR,'||
	'null PERIOD_NUM,null QUARTER_NUM,null ENTERED_PERIOD_NAME,null ADJUSTMENT_PERIOD_FLAG,'||
	'null PEGGING_ID,null END_PEGGING_ID,'||
		'ex.created_by,ex.creation_date,ex.last_updated_by,ex.last_update_date,ex.last_update_login,7 union_flag '||
    	   'FROM isc_dbi_tmp_plans tmp,msc_exception_details'|| g_db_link||' ex,msc_system_items'||g_db_link||' it,'||
	        'MSC_TP_ID_LID'|| g_db_link||' tp,MSC_TP_SITE_ID_LID'|| g_db_link||' tp_site,MSC_TRADING_PARTNERS'|| g_db_link||' org '||
  	  'WHERE tmp.plan_id = ex.plan_id AND nvl(tmp.old_data_start_date,tmp.data_start_date-1) < tmp.data_start_date '||
	    'AND tmp.instance_id = ex.sr_instance_id '||
	    'AND ex.sr_instance_id = org.sr_instance_id '||
	    'AND ex.organization_id = org.sr_tp_id '||
	    'AND org.partner_type = 3 '||
	    'AND ex.supplier_id = tp.tp_id(+) '||
	    'AND tp.partner_type(+) = 1 '||
	    'AND ex.supplier_site_id = tp_site.tp_site_id(+) '||
	    'AND tp_site.partner_type(+) = 1 '||
	    'AND ex.plan_id = it.plan_id(+) '||
	    'AND ex.inventory_item_id = it.inventory_item_id(+) '||
	    'AND ex.organization_id = it.organization_id(+) '||
	    'AND ex.sr_instance_id = it.sr_instance_id(+) UNION ALL '||
  	 'SELECT /*+ DRIVING_SITE (d) */ d.plan_id,d.organization_id,it.sr_inventory_item_id,it.uom_code,'||
		 'null COMPILE_DESIGNATOR,null CONSTRAINED_FLAG,null CURR_CUTOFF_DATE,null CURR_PLAN_TYPE,'||
		 'null CURR_START_DATE,null CUTOFF_DATE,null DATA_START_DATE,null DESCRIPTION,''N'' COMPLETE_FLAG,'||
		 'null BKT_END_DATE,null BKT_START_DATE,'||
		 'null BUCKET_INDEX,null BUCKET_TYPE,null CURR_FLAG,null DAYS_IN_BKT,'||
		 'null TRANSACTION_ID,null TIME_NEW_SCH_DATE_ID,null SOURCE_ORGANIZATION_ID,'||
		 'null SOURCE_SR_INSTANCE_ID,null SOURCE_SUPPLIER_ID,null SOURCE_SUPPLIER_SITE_ID,null SR_INSTANCE_ID,'||
		 'null SR_SUPPLIER_ID,null SUPPLIER_ID,null SUPPLIER_SITE_ID,null BOM_ITEM_TYPE,'||
		 'null DISPOSITION_STATUS_TYPE,null IN_SOURCE_PLAN,null ITEM_PRICE,'||
		 'null NEW_ORDER_QUANTITY,null NEW_PROCESSING_DAYS,null NEW_SCHEDULE_DATE,null ORDER_TYPE,'||
		 'null PLANNING_MAKE_BUY_CODE,null R_CFM_ROUTING_FLAG,it.standard_cost STANDARD_COST,'||
	 	 'null TIME_DETAIL_DATE_ID,null CARRYING_COST,'||
		 'null DETAIL_DATE,null INVENTORY_COST,null MDS_COST,null MDS_PRICE,null MDS_QUANTITY,'||
		'null PRODUCTION_COST,null PURCHASING_COST,'||
		'null RESOURCE_ID,null DEPARTMENT_ID,'||
		'null TIME_RESOURCE_DATE_ID,null AVAILABLE_HOURS,null ORGANIZATION_TYPE,null REQUIRED_HOURS,'||
		'null RESOURCE_DATE,null UTILIZATION,'||
		'null EXCEPTION_DETAIL_ID,null EXCEPTION_TYPE,null NUMBER1,null NUMBER2,null SR_SUPPLIER_SITE_ID,'||
		'd.demand_id,trunc(d.assembly_demand_comp_date) TIME_AS_DMD_COMP_DATE,'||
		'trunc(nvl(assembly_demand_comp_date,using_assembly_demand_date)) TIME_DMD_DATE_ID,'||
		'trunc(d.using_assembly_demand_date) TIME_USING_AS_DMD_DATE,d.assembly_demand_comp_date,'||
        	'd.origination_type,d.using_assembly_demand_date,'||
		'it.average_discount,it.list_price,d.selling_price,d.using_requirement_quantity,'||
	'null PERIOD_SET_NAME,null PERIOD_NAME,null START_DATE,null END_DATE,'||
	'null YEAR_START_DATE,null QUARTER_START_DATE,null PERIOD_TYPE,null PERIOD_YEAR,'||
	'null PERIOD_NUM,null QUARTER_NUM,null ENTERED_PERIOD_NAME,null ADJUSTMENT_PERIOD_FLAG,'||
	'null PEGGING_ID,null END_PEGGING_ID,'||
		'd.created_by,d.creation_date,d.last_updated_by,d.last_update_date,d.last_update_login,8 union_flag '||
   	  'FROM isc_dbi_tmp_plans tmp,msc_demands' ||g_db_link|| ' d,msc_system_items'||g_db_link|| ' it '||
  	  'WHERE tmp.plan_id = d.plan_id AND nvl(tmp.old_data_start_date,tmp.data_start_date-1) < tmp.data_start_date '||
	    'AND tmp.instance_id = d.sr_instance_id '||
	    'AND d.plan_id = it.plan_id '||
	    'AND d.inventory_item_id = it.inventory_item_id '||
	    'AND d.organization_id = it.organization_id '||
	    'AND d.sr_instance_id = it.sr_instance_id UNION ALL '||
   	  'SELECT /*+ DRIVING_SITE (pr) */ null PLAN_ID,pr.organization_id,null SR_INVENTORY_ITEM_ID,null UOM_CODE,'||
		 'null COMPILE_DESIGNATOR,null CONSTRAINED_FLAG,null CURR_CUTOFF_DATE,null CURR_PLAN_TYPE,'||
		 'null CURR_START_DATE,null CUTOFF_DATE,null DATA_START_DATE,pr.description,''N'' COMPLETE_FLAG,'||
		 'null BKT_END_DATE,null BKT_START_DATE,'||
		 'null BUCKET_INDEX,null BUCKET_TYPE,null CURR_FLAG,null DAYS_IN_BKT,'||
		 'null TRANSACTION_ID,null TIME_NEW_SCH_DATE_ID,null SOURCE_ORGANIZATION_ID,'||
		 'null SOURCE_SR_INSTANCE_ID,null SOURCE_SUPPLIER_ID,null SOURCE_SUPPLIER_SITE_ID,null SR_INSTANCE_ID,'||
		 'null SR_SUPPLIER_ID,null SUPPLIER_ID,null SUPPLIER_SITE_ID,null BOM_ITEM_TYPE,'||
		 'null DISPOSITION_STATUS_TYPE,null IN_SOURCE_PLAN,null ITEM_PRICE,'||
		 'null NEW_ORDER_QUANTITY,null NEW_PROCESSING_DAYS,null NEW_SCHEDULE_DATE,null ORDER_TYPE,'||
		 'null PLANNING_MAKE_BUY_CODE,null R_CFM_ROUTING_FLAG,null STANDARD_COST,'||
	 	 'null TIME_DETAIL_DATE_ID,null CARRYING_COST,'||
		 'null DETAIL_DATE,null INVENTORY_COST,null MDS_COST,null MDS_PRICE,null MDS_QUANTITY,'||
		'null PRODUCTION_COST,null PURCHASING_COST,'||
		'null RESOURCE_ID,null DEPARTMENT_ID,'||
		'null TIME_RESOURCE_DATE_ID,null AVAILABLE_HOURS,null ORGANIZATION_TYPE,null REQUIRED_HOURS,'||
		'null RESOURCE_DATE,null UTILIZATION,'||
		'null EXCEPTION_DETAIL_ID,null EXCEPTION_TYPE,null NUMBER1,null NUMBER2,null SR_SUPPLIER_SITE_ID,'||
		'null DEMAND_ID,null TIME_AS_DMD_COMP_DATE,null TIME_DMD_DATE_ID,null TIME_USING_AS_DMD_DATE,'||
		'null ASSEMBLY_DEMAND_COMP_DATE,null ORIGINATION_TYPE,null USING_ASSEMBLY_DEMAND_DATE,'||
		'null AVERAGE_DISCOUNT,null LIST_PRICE,null SELLING_PRICE,null USING_REQUIREMENT_QUANTITY,'||
	'pr.period_set_name,pr.period_name,pr.start_date,pr.end_date,'||
	'pr.year_start_date,pr.quarter_start_date,pr.period_type,pr.period_year,'||
	'pr.period_num,pr.quarter_num,pr.entered_period_name,pr.adjustment_period_flag,'||
	'null PEGGING_ID,null END_PEGGING_ID,'||
	'pr.created_by,pr.creation_date,pr.last_updated_by,pr.last_update_date,pr.last_update_login,9 union_flag '||
	  'FROM msc_bis_periods' || g_db_link || ' pr,isc_dbi_apps_instances inst '||
	 'WHERE pr.sr_instance_id = inst.instance_id UNION ALL '||
 	 'SELECT /*+ DRIVING_SITE (pg) */ pg.plan_id,null ORGANIZATION_ID,null SR_INVENTORY_ITEM_ID,null UOM_CODE,'||
		 'null COMPILE_DESIGNATOR,null CONSTRAINED_FLAG,null CURR_CUTOFF_DATE,null CURR_PLAN_TYPE,'||
		 'null CURR_START_DATE,null CUTOFF_DATE,null DATA_START_DATE,null DESCRIPTION,''N'' COMPLETE_FLAG,'||
		 'null BKT_END_DATE,null BKT_START_DATE,'||
		 'null BUCKET_INDEX,null BUCKET_TYPE,null CURR_FLAG,null DAYS_IN_BKT,'||
		 'pg.transaction_id,null TIME_NEW_SCH_DATE_ID,null SOURCE_ORGANIZATION_ID,'||
		 'null SOURCE_SR_INSTANCE_ID,null SOURCE_SUPPLIER_ID,null SOURCE_SUPPLIER_SITE_ID,null SR_INSTANCE_ID,'||
		 'null SR_SUPPLIER_ID,null SUPPLIER_ID,null SUPPLIER_SITE_ID,null BOM_ITEM_TYPE,'||
		 'null DISPOSITION_STATUS_TYPE,null IN_SOURCE_PLAN,null ITEM_PRICE,'||
		 'null NEW_ORDER_QUANTITY,null NEW_PROCESSING_DAYS,null NEW_SCHEDULE_DATE,null ORDER_TYPE,'||
		 'null PLANNING_MAKE_BUY_CODE,null R_CFM_ROUTING_FLAG,null STANDARD_COST,'||
	 	 'null TIME_DETAIL_DATE_ID,null CARRYING_COST,'||
		 'null DETAIL_DATE,null INVENTORY_COST,null MDS_COST,null MDS_PRICE,null MDS_QUANTITY,'||
		'null PRODUCTION_COST,null PURCHASING_COST,'||
		'null RESOURCE_ID,null DEPARTMENT_ID,'||
		'null TIME_RESOURCE_DATE_ID,null AVAILABLE_HOURS,null ORGANIZATION_TYPE,null REQUIRED_HOURS,'||
		'null RESOURCE_DATE,null UTILIZATION,'||
		'null EXCEPTION_DETAIL_ID,null EXCEPTION_TYPE,null NUMBER1,null NUMBER2,null SR_SUPPLIER_SITE_ID,'||
		'pg.demand_id,null TIME_AS_DMD_COMP_DATE,null TIME_DMD_DATE_ID,null TIME_USING_AS_DMD_DATE,'||
		'null ASSEMBLY_DEMAND_COMP_DATE,null ORIGINATION_TYPE,null USING_ASSEMBLY_DEMAND_DATE,'||
		'null AVERAGE_DISCOUNT,null LIST_PRICE,null SELLING_PRICE,null USING_REQUIREMENT_QUANTITY,'||
	'null PERIOD_SET_NAME,null PERIOD_NAME,null START_DATE,null END_DATE,'||
	'null YEAR_START_DATE,null QUARTER_START_DATE,null PERIOD_TYPE,null PERIOD_YEAR,'||
	'null PERIOD_NUM,null QUARTER_NUM,null ENTERED_PERIOD_NAME,null ADJUSTMENT_PERIOD_FLAG,'||
	'pg.pegging_id,pg.end_pegging_id,'||
	'pg.created_by,pg.creation_date,pg.last_updated_by,pg.last_update_date,pg.last_update_login,10 union_flag '||
   	   'FROM isc_dbi_tmp_plans tmp,msc_full_pegging' ||g_db_link|| ' pg '||
  	  'WHERE tmp.plan_id = pg.plan_id '||
	    'AND nvl(tmp.old_data_start_date,tmp.data_start_date-1) < tmp.data_start_date '||
	    'AND tmp.instance_id = pg.sr_instance_id';

  l_in_length := length(l_insert_stmt);
  BIS_COLLECTION_UTILITIES.Put_Line('The length of the insert statement is '|| l_in_length);
  l_sel_length1 := length(l_sel_stmt1);
  BIS_COLLECTION_UTILITIES.Put_Line('The length of the select statement 1 is '|| l_sel_length1);
  l_sel_length2 := length(l_sel_stmt2);
  BIS_COLLECTION_UTILITIES.Put_Line('The length of the select statement 2 is '|| l_sel_length2);

  EXECUTE IMMEDIATE (l_insert_stmt || l_sel_stmt1 || l_sel_stmt2);
  l_count := l_count + sql%rowcount;
  COMMIT;

  FII_UTIL.Stop_Timer;
  FII_UTIL.Print_Timer('Loaded the base tables in');
  BIS_COLLECTION_UTILITIES.Put_Line(' ');

  UPDATE isc_dbi_tmp_plans tmp SET constrained_flag = (select constrained_flag from isc_dbi_plans p where p.plan_id = tmp.plan_id);
  COMMIT;

  FII_UTIL.Start_Timer;

  FOR i in 1..g_small_bases.last LOOP
      FND_STATS.GATHER_TABLE_STATS(OWNNAME => g_isc_schema, TABNAME => g_small_bases(i));
  END LOOP;

  FOR j in 1..g_large_bases.last LOOP
      FND_STATS.GATHER_TABLE_STATS(OWNNAME => g_isc_schema, TABNAME => g_large_bases(j));
  END LOOP;

  FND_STATS.GATHER_TABLE_STATS(OWNNAME => g_isc_schema,
		 	       TABNAME => 'ISC_DBI_PERIODS');

  FII_UTIL.Stop_Timer;
  FII_UTIL.Print_Timer('Analyzed the base tables in');

  l_trunc_stmt := 'truncate table ' || g_isc_schema ||'.isc_dbi_plan_curr_rates';
  EXECUTE IMMEDIATE l_trunc_stmt;
  BIS_COLLECTION_UTILITIES.put_line('Table isc_dbi_plan_curr_rates has been truncated.');

  BIS_COLLECTION_UTILITIES.put_line('Begin to retrieve the currency conversion rates.');
  FII_UTIL.Start_Timer;

  INSERT INTO isc_dbi_plan_curr_rates(
	ORGANIZATION_ID,
	FROM_CURRENCY,
	CONVERSION_DATE,
	RATE,
	RATE2)
  SELECT org.organization_id ORGANIZATION_ID,
       gsb.currency_code FROM_CURRENCY,
       g_snapshot_date CONVERSION_DATE,
       fii_currency.get_global_rate_primary(gsb.currency_code, g_snapshot_date)	RATE,
       fii_currency.get_global_rate_secondary(gsb.currency_code, g_snapshot_date) RATE2
    FROM (SELECT distinct organization_id
  	    FROM isc_dbi_plan_organizations ido,
	         isc_dbi_tmp_plans tmp
	   WHERE bitand(tmp.plan_usage, 2) = 2
	     AND ido.plan_id = tmp.plan_id) org,
         GL_SETS_OF_BOOKS gsb,
         HR_ORGANIZATION_INFORMATION hoi
   WHERE hoi.org_information_context ='Accounting Information'
     AND hoi.organization_id = org.organization_id
     AND hoi.org_information1 = to_char(gsb.set_of_books_id);

  FII_UTIL.Stop_Timer;
  FII_UTIL.Print_Timer('Retrieved '||sql%rowcount||' currency rates in');
  COMMIT;

  FII_UTIL.Start_Timer;

  FND_STATS.GATHER_TABLE_STATS(OWNNAME => g_isc_schema,
		 	       TABNAME => 'ISC_DBI_PLAN_CURR_RATES');

  FII_UTIL.Stop_Timer;
  FII_UTIL.Print_Timer('Analyzed ISC_DBI_PLAN_CURR_RATES in');

  RETURN(l_count);

EXCEPTION
  WHEN OTHERS THEN
    g_errbuf  := 'Error in Function PULL_DATA : '||sqlerrm;
    g_retcode := sqlcode;
    RETURN(-1);
END pull_data;

      -- ---------------------
      -- CHECK_TIME_CONTINUITY
      -- ---------------------

FUNCTION CHECK_TIME_CONTINUITY RETURN NUMBER IS

l_min			DATE;
l_max			DATE;
l_is_missing		BOOLEAN	:= TRUE;

 BEGIN

 FII_UTIL.Start_Timer;

 SELECT min(p.data_start_date),max(p.cutoff_date)
   INTO l_min, l_max
   FROM isc_dbi_plans p, isc_dbi_tmp_plans tmp
  WHERE p.plan_id = tmp.plan_id;

 FII_UTIL.Stop_Timer;
 FII_UTIL.Print_Timer('Retrieved the min and max date in ');

 FII_UTIL.Start_Timer;

 BIS_COLLECTION_UTILITIES.Put_Line_Out(' ');
 BIS_COLLECTION_UTILITIES.Put_Line_Out(' ');

 IF(l_min IS NOT NULL and l_max IS NOT NULL) THEN
   FII_TIME_API.check_missing_date(l_min, l_max, l_is_missing);

   IF (l_is_missing) THEN
     BIS_COLLECTION_UTILITIES.Put_Line('Collection failed because there are dangling keys for time dimension.');
     BIS_COLLECTION_UTILITIES.Put_Line('No records were loaded.');
     RETURN (-999);
   ELSE
     BIS_COLLECTION_UTILITIES.Put_Line(' ');
     BIS_COLLECTION_UTILITIES.Put_Line('           THERE IS NO DANGLING TIME ATTRIBUTES    ');
     BIS_COLLECTION_UTILITIES.Put_Line('+---------------------------------------------------------------------------+');
     BIS_COLLECTION_UTILITIES.Put_Line(' ');
   END IF;
 END IF;

 FII_UTIL.Stop_Timer;
 FII_UTIL.Print_Timer('Completed time continuity check in');

  RETURN(1);

  EXCEPTION
   WHEN OTHERS THEN
    g_errbuf  := 'Error in Function CHECK_TIME_CONTINUITY : '||sqlerrm;
    g_retcode := sqlcode;
    RETURN(-1);
 END;

      -- ----------------------------------------
      -- Identify Dangling Key for Item Dimension
      -- ----------------------------------------

FUNCTION IDENTIFY_DANGLING_ITEM RETURN NUMBER IS

CURSOR Dangling_Items IS
SELECT distinct s.sr_inventory_item_id, s.organization_id
  FROM isc_dbi_supplies_f s,
       isc_dbi_tmp_plans tmp,
       eni_oltp_item_star item
 WHERE s.plan_id = tmp.plan_id
   AND s.sr_inventory_item_id = item.inventory_item_id(+)
   AND s.organization_id = item.organization_id(+)
   AND item.inventory_item_id IS NULL
 UNION
SELECT distinct d.sr_inventory_item_id, d.organization_id
  FROM isc_dbi_demands_f d,
       isc_dbi_tmp_plans tmp,
       eni_oltp_item_star item
 WHERE d.plan_id = tmp.plan_id
   AND d.sr_inventory_item_id = item.inventory_item_id(+)
   AND d.organization_id = item.organization_id(+)
   AND item.inventory_item_id IS NULL
 UNION
SELECT distinct d.sr_inventory_item_id, d.organization_id
  FROM isc_dbi_inv_detail_f d,
       isc_dbi_tmp_plans tmp,
       eni_oltp_item_star item
 WHERE d.plan_id = tmp.plan_id
   AND d.sr_inventory_item_id = item.inventory_item_id(+)
   AND d.organization_id = item.organization_id(+)
   AND item.inventory_item_id IS NULL;

l_item	NUMBER;
l_org	NUMBER;
l_total	NUMBER;

BEGIN
  l_total := 0;
  OPEN Dangling_Items;
  FETCH Dangling_Items INTO l_item, l_org;

  IF Dangling_Items%ROWCOUNT <> 0 THEN
      BIS_COLLECTION_UTILITIES.Put_Line('Collection failed because there are dangling keys for item dimension.');
      BIS_COLLECTION_UTILITIES.Put_Line('No records were loaded');

      BIS_COLLECTION_UTILITIES.Put_Line_Out(' ');
      BIS_COLLECTION_UTILITIES.Put_Line_Out(' ');
      BIS_COLLECTION_UTILITIES.Put_Line_Out(fnd_message.get_string('ISC', 'ISC_DBI_ITEM_NO_LOAD'));
      BIS_COLLECTION_UTILITIES.Put_Line_Out(' ');
      BIS_COLLECTION_UTILITIES.Put_Line_Out(RPAD(fnd_message.get_string('ISC','ISC_DBI_INV_ITEM_ID'),23,' ')||' - '||RPAD(fnd_message.get_string('ISC','ISC_DBI_ORG_ID'),20,' '));
      BIS_COLLECTION_UTILITIES.Put_Line_Out('----------------------- - --------------------');

        WHILE Dangling_Items%FOUND LOOP
          BIS_COLLECTION_UTILITIES.Put_Line_Out(RPAD(l_item,18,' ')||' - '||RPAD(l_org,18,' '));
	  FETCH Dangling_Items INTO l_item, l_org;
	END LOOP;
      BIS_COLLECTION_UTILITIES.Put_Line_Out('+-------------------------------------+');
  ELSE
      BIS_COLLECTION_UTILITIES.Put_Line(' ');
      BIS_COLLECTION_UTILITIES.Put_Line('           THERE IS NO DANGLING ITEMS        ');
      BIS_COLLECTION_UTILITIES.Put_Line('+--------------------------------------------+');
      BIS_COLLECTION_UTILITIES.Put_Line(' ');
  END IF;
  l_total := Dangling_Items%ROWCOUNT;
  CLOSE Dangling_Items;

  RETURN(l_total);

  EXCEPTION
   WHEN OTHERS THEN
    g_errbuf  := 'Error in Function IDENTIFY_DANGLING_ITEM : '||sqlerrm;
    g_retcode := sqlcode;
    RETURN(-1);
 END;

      -- -----------------------------------
      -- Reporting of the missing currencies
      -- -----------------------------------

FUNCTION REPORT_MISSING_RATE RETURN NUMBER IS

l_sec_curr_def	VARCHAR2(1) := isc_dbi_currency_pkg.is_sec_curr_defined;

CURSOR Missing_Currency_Conversion IS
   SELECT distinct decode(rate, -3, to_date('01/01/1999','MM/DD/RRRR'), conversion_date) CURR_CONV_DATE,
	  from_currency FROM_CURRENCY,
 	  g_global_currency TO_CURRENCY,
	  g_global_rate_type RATE_TYPE,
 	  decode(rate, -1, 'RATE NOT AVAILABLE', -2, 'INVALID CURRENCY') STATUS
     FROM isc_dbi_plan_curr_rates tmp
    WHERE rate < 0
   UNION
   SELECT distinct decode(rate2, -3, to_date('01/01/1999','MM/DD/RRRR'), conversion_date) CURR_CONV_DATE,
	  from_currency FROM_CURRENCY,
 	  g_sec_global_currency TO_CURRENCY,
	  g_sec_global_rate_type RATE_TYPE,
 	  decode(rate2, -1, 'RATE NOT AVAILABLE', -2, 'INVALID CURRENCY') STATUS
     FROM isc_dbi_plan_curr_rates tmp
    WHERE rate2 < 0
      AND l_sec_curr_def = 'Y';

l_record				Missing_Currency_Conversion%ROWTYPE;
l_total					NUMBER := 0;

 BEGIN

  OPEN Missing_Currency_Conversion;
  FETCH Missing_Currency_Conversion INTO l_record;

  IF Missing_Currency_Conversion%ROWCOUNT <> 0
    THEN
      BIS_COLLECTION_UTILITIES.Put_Line('Collection failed because there are missing currency conversion rates.');
      BIS_COLLECTION_UTILITIES.Put_Line(fnd_message.get_string('BIS', 'BIS_DBI_CURR_NO_LOAD'));

      BIS_COLLECTION_UTILITIES.writeMissingRateHeader;
        WHILE Missing_Currency_Conversion%FOUND LOOP
          l_total := l_total + 1;
	  BIS_COLLECTION_UTILITIES.writeMissingRate(
        	l_record.rate_type,
        	l_record.from_currency,
        	l_record.to_currency,
        	l_record.curr_conv_date);
	  FETCH Missing_Currency_Conversion INTO l_record;
	END LOOP;
      BIS_COLLECTION_UTILITIES.Put_Line_Out(' ');
      BIS_COLLECTION_UTILITIES.Put_Line_Out(' ');

  ELSE -- Missing_Currency_Conversion%ROWCOUNT = 0
      BIS_COLLECTION_UTILITIES.Put_Line(' ');
      BIS_COLLECTION_UTILITIES.Put_Line('           THERE IS NO MISSING CURRENCY CONVERSION RATE        ');
      BIS_COLLECTION_UTILITIES.Put_Line('+---------------------------------------------------------------------------+');
      BIS_COLLECTION_UTILITIES.Put_Line(' ');
  END IF; -- Missing_Currency_Conversion%ROWCOUNT <> 0

  CLOSE Missing_Currency_Conversion;

  RETURN(l_total);

  EXCEPTION
   WHEN OTHERS THEN
    g_errbuf  := 'Error in Function REPORT_MISSING_RATE : '||sqlerrm;
    g_retcode := sqlcode;
    RETURN(-1);
 END;

      -- --------------
      -- DANGLING_CHECK
      -- --------------

FUNCTION DANGLING_CHECK RETURN NUMBER IS

l_time_danling	NUMBER := 0;
l_item_count	NUMBER := 0;
l_dangling	NUMBER := 0;
l_miss_conv	NUMBER := 0;

BEGIN

      -- ----------------------------------------------------------
      -- Identify Missing Currency Rate from ISC_DBI_PLAN_CURR_RATES
      -- When there is missing rate, exit the collection with error
      -- ----------------------------------------------------------

     BIS_COLLECTION_UTILITIES.put_line(' ');
     BIS_COLLECTION_UTILITIES.put_line('Identifying the missing currency conversion rates');
     FII_UTIL.Start_Timer;

     l_miss_conv := REPORT_MISSING_RATE;

     FII_UTIL.Stop_Timer;
     FII_UTIL.Print_Timer('Completed missing currency check in');

     IF (l_miss_conv = -1) THEN
        return(-1);
     ELSIF (l_miss_conv > 0) THEN
        g_errbuf  := g_errbuf || 'Collection aborted due to missing currency conversion rates. ';
        l_dangling := -999;
     END IF;

      -- ---------------------
      -- CHECK_TIME_CONTINUITY
      -- ---------------------

  BIS_COLLECTION_UTILITIES.Put_Line(' ');
  BIS_COLLECTION_UTILITIES.put_line('Checking Time Continuity');

  l_time_danling := check_time_continuity;

  IF (l_time_danling = -1) THEN
    return(-1);
  ELSIF (l_time_danling = -999) THEN
    g_errbuf  := g_errbuf || 'Collection aborted due to dangling keys for time dimension. ';
    l_dangling := -999;
  END IF;

      -- -------------------------------------
      -- Check Dangling Key for Item Dimension
      -- -------------------------------------

  BIS_COLLECTION_UTILITIES.put_line(' ');
  BIS_COLLECTION_UTILITIES.put_line('Identifying the dangling items');

  FII_UTIL.Start_Timer;

  l_item_count := IDENTIFY_DANGLING_ITEM;

  FII_UTIL.Stop_Timer;
  FII_UTIL.Print_Timer('Identified '||l_item_count||' dangling items in');

  IF (l_item_count = -1) THEN
    return(-1);
  ELSIF (l_item_count > 0) THEN
    g_errbuf  := g_errbuf || 'Collection aborted due to dangling items. ';
    l_dangling := -999;
  END IF;

  IF (l_dangling = -999) THEN
    return(-1);
  END IF;

  UPDATE isc_dbi_plans SET complete_flag = 'Y'
   WHERE plan_id IN (select plan_id from isc_dbi_tmp_plans tmp);
  COMMIT;

RETURN(1);

EXCEPTION
  WHEN OTHERS THEN
    g_errbuf  := 'Error in Function DANGLING_CHECK : '||sqlerrm;
    g_retcode	:= sqlcode;
    RETURN(-1);

END dangling_check;

      ------------------------------
      -- Function: LOAD_BASES_INIT
      ------------------------------

FUNCTION load_bases_init RETURN NUMBER IS

l_failure		EXCEPTION;

l_row_count		NUMBER;
l_trunc_stmt		VARCHAR2(500);

BEGIN

  IF (CHECK_SETUP = -1)
     THEN RAISE l_failure;
  END IF;

      --  ----------------------------------------------------
      --  Truncate all the base tables before the initial load
      --  ----------------------------------------------------

    BIS_COLLECTION_UTILITIES.put_line(' ');
    BIS_COLLECTION_UTILITIES.put_line('Begin to truncate all the base tables');

    FOR j in 1..g_large_bases.last LOOP
       l_trunc_stmt := 'truncate table ' || g_isc_schema ||'.'|| g_large_bases(j);
       EXECUTE IMMEDIATE l_trunc_stmt;
    END LOOP;

    FOR i in 1..g_small_bases.last LOOP
       l_trunc_stmt := 'truncate table ' || g_isc_schema ||'.'|| g_small_bases(i);
       EXECUTE IMMEDIATE l_trunc_stmt;
    END LOOP;

    FII_UTIL.Stop_Timer;
    FII_UTIL.Print_Timer('Truncate the base tables in');

      --  --------------------------------------------
      --  Clean Up the Last Collected Date
      --  --------------------------------------------

  UPDATE isc_dbi_plan_schedules
     SET last_collected_date = NULL;

    BIS_COLLECTION_UTILITIES.Put_Line('Cleaned up the last collected date.');

      --  --------------------------------------------
      --  Identify Plans to be collected
      --  --------------------------------------------

  l_row_count := IDENTIFY_PLANS;

  IF (l_row_count = -1)
    THEN RAISE l_failure;
  ELSIF (l_row_count = 0) THEN
    g_row_count := 0;
  ELSE

      --  --------------------------------------------
      --  Insert data into base tables
      --  --------------------------------------------

    g_row_count := PULL_DATA;

    IF (g_row_count = -1) THEN
      RAISE l_failure;
    END IF;
  END IF;

--  SELECT count(*) FROM isc_dbi_plans WHERE complete_flag = 'N';

  IF (DANGLING_CHECK = -1) THEN
     RAISE l_failure;
  END IF;

 RETURN(1);

 EXCEPTION

  WHEN L_FAILURE THEN
    ROLLBACK;
    BIS_COLLECTION_UTILITIES.put_line(' ');
    BIS_COLLECTION_UTILITIES.put_line(g_errbuf);
    RETURN(-1);

  WHEN OTHERS THEN
    ROLLBACK;
    g_errbuf := sqlerrm ||' - '||sqlcode;
    BIS_COLLECTION_UTILITIES.put_line(' ');
    BIS_COLLECTION_UTILITIES.put_line('Other errors : '|| g_errbuf);
    RETURN(-1);

END load_bases_init;

      ------------------------------
      -- Public Function: LOAD_BASES
      ------------------------------

FUNCTION load_bases RETURN NUMBER IS

l_failure		EXCEPTION;

l_row_count		NUMBER;

BEGIN

  IF (CHECK_SETUP = -1)
     THEN RAISE l_failure;
  END IF;

      --  --------------------------------------------
      --  Identify Plans to be collected
      --  --------------------------------------------

  l_row_count := IDENTIFY_PLANS;

  IF (l_row_count = -1)
    THEN RAISE l_failure;
  ELSIF (l_row_count = 0) THEN
    g_row_count := 0;
  ELSE

      --  --------------------------------------------
      --  Insert data into base tables
      --  --------------------------------------------

    g_row_count := PULL_DATA;

    IF (g_row_count = -1) THEN
      RAISE l_failure;
    END IF;
  END IF;

--  SELECT count(*) FROM isc_dbi_plans WHERE complete_flag = 'N';

  IF (DANGLING_CHECK = -1) THEN
     RAISE l_failure;
  END IF;

 RETURN(1);

 EXCEPTION

  WHEN L_FAILURE THEN
    ROLLBACK;
    BIS_COLLECTION_UTILITIES.put_line(' ');
    BIS_COLLECTION_UTILITIES.put_line(g_errbuf);
    RETURN(-1);

  WHEN OTHERS THEN
    ROLLBACK;
    g_errbuf := sqlerrm ||' - '||sqlcode;
    BIS_COLLECTION_UTILITIES.put_line(' ');
    BIS_COLLECTION_UTILITIES.put_line('Other errors : '|| g_errbuf);
    RETURN(-1);

END load_bases;

      -- --------------------
      -- Load Snapshots
      -- --------------------

FUNCTION LOAD_SNAPSHOTS RETURN NUMBER IS

  partition_exists EXCEPTION;
  PRAGMA EXCEPTION_INIT(partition_exists, -14013);

  part_value_exists EXCEPTION;
  PRAGMA EXCEPTION_INIT(part_value_exists, -14312);

-- item level, change to range partition

  CURSOR Delete_List IS
    SELECT p.snapshot_id
      FROM isc_dbi_tmp_plans tmp, isc_dbi_plan_snapshots p
     WHERE bitand(tmp.plan_usage, 2) = 2
       AND tmp.plan_id = p.plan_id
       AND trunc(tmp.data_start_date) = trunc(p.data_start_date);

  CURSOR Snapshot_List IS
    SELECT snapshot_id
      FROM isc_dbi_tmp_plans tmp
     WHERE bitand(plan_usage, 2) = 2
     ORDER BY snapshot_id;

  l_delete_id		NUMBER;
  l_add_snapshot_id	NUMBER;
  l_higher_bound	NUMBER;
  l_add_stmt		VARCHAR2(2000);
  l_count		NUMBER;
  l_rebuild_index_stmt VARCHAR2(2000);
  l_index_name	VARCHAR2(240);

  CURSOR Get_Index_Lists(p_table_name IN VARCHAR2, p_schema_name IN VARCHAR2) IS
    SELECT index_name
      FROM all_indexes
     WHERE table_name = p_table_name
       AND owner = p_schema_name;


BEGIN

  l_count := 0;
  FII_UTIL.Start_Timer;

  OPEN Delete_List;
  FETCH Delete_List INTO l_delete_id;
  IF Delete_List%ROWCOUNT <> 0 THEN
    WHILE Delete_List%Found LOOP
      BIS_COLLECTION_UTILITIES.Put_Line('Dropping snapshot '|| l_delete_id);
      IF (drop_snapshots(l_delete_id) = -1) THEN RETURN(-1); END IF;
      FETCH Delete_List INTO l_delete_id;
    END LOOP;
  END IF;

  FII_UTIL.Stop_Timer;
  FII_UTIL.Print_Timer('Dropped '|| Delete_List%ROWCOUNT ||' duplicate snapshots in');
  CLOSE Delete_List;

  IF (g_rebuild_snapshot_index = 'Y') THEN

     FOR j in 1..g_large_snapshots.last LOOP
       OPEN Get_Index_Lists(g_large_snapshots(j), g_isc_schema);
       FETCH Get_Index_Lists INTO l_index_name;
       IF Get_Index_Lists%ROWCOUNT <> 0 THEN
          WHILE Get_Index_Lists%Found LOOP
            FII_UTIL.Start_Timer;
            l_rebuild_index_stmt := 'ALTER INDEX '|| g_isc_schema || '.' || l_index_name || ' REBUILD';
            EXECUTE IMMEDIATE l_rebuild_index_stmt;
            FII_UTIL.Stop_Timer;
            FII_UTIL.Print_Timer('Rebuilt index '|| l_index_name || ' in');
            FETCH Get_Index_Lists INTO l_index_name;
          END LOOP;
       END IF;
       CLOSE Get_Index_Lists;
     END LOOP;

  END IF;

  UPDATE isc_dbi_tmp_plans SET snapshot_id = isc_dbi_msc_objects_s.nextval WHERE bitand(plan_usage, 2) = 2;
  l_count := SQL%ROWCOUNT;
  COMMIT;

  BIS_COLLECTION_UTILITIES.Put_Line(' ');
  BIS_COLLECTION_UTILITIES.Put_Line('Identified '|| l_count || ' snapshots to be collected.');

  IF (l_count > 0) THEN

      --  --------------
      --  Add Partitions
      --  --------------

    FII_UTIL.Start_Timer;

    OPEN Snapshot_List;
    FETCH Snapshot_List INTO l_add_snapshot_id;
    IF Snapshot_List%ROWCOUNT <> 0 THEN
      WHILE Snapshot_List%Found LOOP
        BIS_COLLECTION_UTILITIES.Put_Line('Adding snapshot '|| l_add_snapshot_id);
        FOR i in 1..g_large_snapshots.last LOOP
	  BEGIN
            l_add_stmt := 'ALTER TABLE '||g_isc_schema||'.'||g_large_snapshots(i)||' ADD PARTITION s_'|| l_add_snapshot_id ||' VALUES LESS THAN ('''|| to_char(l_add_snapshot_id+1) ||''')';
            EXECUTE IMMEDIATE l_add_stmt;
          EXCEPTION
          WHEN partition_exists THEN
            BIS_COLLECTION_UTILITIES.put_line('The partition s_'||l_add_snapshot_id||' of table '||g_large_snapshots(i)||' already exists.');
	      NULL;
          WHEN part_value_exists THEN
            BIS_COLLECTION_UTILITIES.put_line('The value '||l_add_snapshot_id||' already exists in another partition of table '||g_large_snapshots(i));
	      NULL;
          END;
        END LOOP;
        FETCH Snapshot_List INTO l_add_snapshot_id;
      END LOOP;
    END IF;
    FII_UTIL.Stop_Timer;
    FII_UTIL.Print_Timer('Added '|| Snapshot_List%ROWCOUNT ||' partitions in');
    CLOSE Snapshot_List;

      --  ----------------------------------
      --  Collect ISC_DBI_PLAN_SNAPSHOTS
      --  ----------------------------------

  BIS_COLLECTION_UTILITIES.put_line(' ');
  BIS_COLLECTION_UTILITIES.put_line('Begin to insert data into isc_dbi_plan_snapshots.');
  FII_UTIL.Start_Timer;

  INSERT
    INTO isc_dbi_plan_snapshots F(
	SNAPSHOT_ID,
	PLAN_ID,
	ORGANIZATION_ID,
	COMPILE_DESIGNATOR,
 	CONSTRAINED_FLAG,
	CURR_PLAN_TYPE,
	CUTOFF_DATE,
	DATA_START_DATE,
	DESCRIPTION,
	ORG_CNT,
	SNAPSHOT_DATE)
 SELECT tmp.snapshot_id, ip.plan_id, ip.organization_id, ip.compile_designator, ip.constrained_flag,
	ip.curr_plan_type, ip.cutoff_date, ip.data_start_date,
	ip.description, count(*), g_snapshot_date
   FROM isc_dbi_tmp_plans tmp,
        isc_dbi_plans ip,
	isc_dbi_plan_organizations ipo
  WHERE tmp.plan_id = ip.plan_id
    AND bitand(tmp.plan_usage, 2) = 2
    AND ip.plan_id = ipo.plan_id
  GROUP BY tmp.snapshot_id, ip.plan_id, ip.organization_id, ip.compile_designator, ip.constrained_flag, ip.curr_plan_type,
	   ip.cutoff_date, ip.data_start_date, ip.description;

  FII_UTIL.Stop_Timer;
  FII_UTIL.Print_Timer('Inserted '|| sql%rowcount ||' rows into isc_dbi_plan_snapshots in');
--  COMMIT;

      --  ----------------------------------
      --  Collect ISC_DBI_PLAN_ORG_SNAPSHOTS
      --  ----------------------------------

 BIS_COLLECTION_UTILITIES.put_line(' ');
 BIS_COLLECTION_UTILITIES.put_line('Begin to insert data into isc_dbi_plan_org_snapshots.');
 FII_UTIL.Start_Timer;

 INSERT
   INTO isc_dbi_plan_org_snapshots(
	SNAPSHOT_ID,
	ORGANIZATION_ID)
 SELECT tmp.snapshot_id, ipo.organization_id
   FROM isc_dbi_tmp_plans tmp,
	isc_dbi_plan_organizations ipo
  WHERE tmp.plan_id = ipo.plan_id
    AND bitand(tmp.plan_usage, 2) = 2;

  FII_UTIL.Stop_Timer;
  FII_UTIL.Print_Timer('Inserted '|| sql%rowcount ||' rows into isc_dbi_plan_organizations in');
--  COMMIT;

      --  ----------------------------------
      --  Collect ISC_DBI_SUPPLIES_SNAPSHOTS
      --  ----------------------------------

 BIS_COLLECTION_UTILITIES.put_line(' ');
 BIS_COLLECTION_UTILITIES.put_line('Begin to insert data into isc_dbi_supplies_snapshots.');
 FII_UTIL.Start_Timer;

-- item level only, move category to MV

INSERT INTO isc_dbi_supplies_snapshots F(
	SNAPSHOT_ID,
	ORGANIZATION_ID,
	SR_INVENTORY_ITEM_ID,
	START_DATE,
	PERIOD_TYPE_ID,
	SR_SUPPLIER_ID,
	PURCHASING_COST,
	PURCHASING_COST_G,
	PURCHASING_COST_G1,
	UOM_CODE)
SELECT /*+ parallel(ids) */ tmp.snapshot_id SNAPSHOT_ID,
       ids.organization_id ORGANIZATION_ID,
       ids.sr_inventory_item_id SR_INVENTORY_ITEM_ID,
       decode(grouping_id(ent_year_start_date, ent_qtr_start_date, ent_period_start_date),
	      6, ent_period_start_date, 5, ent_qtr_start_date, 3, ent_year_start_date) START_DATE,
       decode(grouping_id(ent_year_start_date, ent_qtr_start_date, ent_period_start_date),
	      6, 32, 5, 64, 3, 128) PERIOD_TYPE_ID,
       nvl(ids.sr_supplier_id, -1) SR_SUPPLIER_ID,
       sum(nvl(ids.new_order_quantity,0)*nvl(ids.item_price,nvl(ids.standard_cost,0))) PURCHASING_COST,
       sum(nvl(ids.new_order_quantity,0)*nvl(ids.item_price,nvl(ids.standard_cost,0))*curr.rate) PURCHASING_COST_G,
       sum(nvl(ids.new_order_quantity,0)*nvl(ids.item_price,nvl(ids.standard_cost,0))*curr.rate2) PURCHASING_COST_G1,
       ids.uom_code UOM_CODE
  FROM isc_dbi_tmp_plans tmp,
       isc_dbi_supplies_f ids,
       isc_dbi_plan_curr_rates curr,
       fii_time_day time
 WHERE tmp.plan_id = ids.plan_id
   AND bitand(tmp.plan_usage, 2) = 2
   AND ids.organization_id = curr.organization_id
   AND ids.time_new_sch_date_id = time.report_date
   AND ((ids.order_type = 5 AND ids. source_organization_id IS NULL)
	OR ids.order_type in (1, 2, 8))
   AND ids.disposition_status_type <> 2
 GROUP BY tmp.snapshot_id, ids.organization_id, nvl(ids.sr_supplier_id, -1), ids.sr_inventory_item_id, ids.uom_code,
	  grouping sets(ent_year_start_date, ent_qtr_start_date, ent_period_start_date);

 FII_UTIL.Stop_Timer;
 FII_UTIL.Print_Timer('Inserted '|| sql%rowcount ||' rows into isc_dbi_supplies_snapshots in');
-- COMMIT;


      --  ----------------------------------------
      --  Collect ISC_DBI_SHORTFALL_SNAPSHOTS
      --
      --  Reason Type: -1 - Unassigned
      --                0 - On-time Demands
      -- 		1 - Item Related
      -- 		2 - Resource Related
      -- 		3 - Transportation Related
      --  ----------------------------------------

 BIS_COLLECTION_UTILITIES.put_line(' ');
 BIS_COLLECTION_UTILITIES.put_line('Begin to insert data into isc_dbi_shortfall_snapshots for unconstrained plans.');
 FII_UTIL.Start_Timer;

INSERT
  INTO isc_dbi_shortfall_snapshots F(
	SNAPSHOT_ID,
	ORGANIZATION_ID,
	START_DATE,
	PERIOD_TYPE_ID,
	REASON_TYPE,
        DMD_ITEM_ID,
	ORGANIZATION_TYPE,
        R_ITEM_ID,
	R_SUPPLIER_ID,
	R_SUPPLIER_SITE_ID,
	R_RESOURCE_ID,
	R_ORG_ID,
	R_DEPARTMENT_ID,
	REV_TEMP,
	REV_TEMP_G,
	REV_TEMP_G1,
	COST_TEMP,
	COST_TEMP_G,
	COST_TEMP_G1,
	LATE_LINES_TEMP,
	TOTAL_LINES_TEMP,
	REV_SHORTFALL,
	REV_SHORTFALL_G,
	REV_SHORTFALL_G1,
	COST_SHORTFALL,
	COST_SHORTFALL_G,
	COST_SHORTFALL_G1,
	UOM_CODE)
SELECT /*+ parallel(f) use_hash(TIME,CURR) */ f.snapshot_id SNAPSHOT_ID, f.organization_id,
       decode(grouping_id(ent_year_start_date, ent_qtr_start_date, ent_period_start_date),
	      6, ent_period_start_date, 5, ent_qtr_start_date, 3, ent_year_start_date) START_DATE,
       decode(grouping_id(ent_year_start_date, ent_qtr_start_date, ent_period_start_date),
	      6, 32, 5, 64, 3, 128) PERIOD_TYPE_ID,
       f.reason_type, f.dmd_item_id, f.organization_type,
       f.r_item_id, f.r_supplier_id, f.r_supplier_site_id, f.r_resource_id, f.r_org_id, f.r_department_id,
       sum(revenue/cnt) REV_TEMP, sum(revenue*curr.rate/cnt) REV_TEMP_G, sum(revenue*curr.rate2/cnt) REV_TEMP_G1,
       sum(cost/cnt) COST_TEMP, sum(cost*curr.rate/cnt) COST_TEMP_G, sum(cost*curr.rate2/cnt) COST_TEMP_G1,
       sum(late_lines/cnt) LATE_LINES_TEMP, sum(1/cnt) TOTAL_LINES_TEMP,
       sum(decode(reason_cnt, 0, 0, revenue/reason_cnt)) REV_SHORTFALL,
       sum(decode(reason_cnt, 0, 0, revenue*curr.rate/reason_cnt)) REV_SHORTFALL_G,
       sum(decode(reason_cnt, 0, 0, revenue*curr.rate2/reason_cnt)) REV_SHORTFALL_G1,
       sum(decode(reason_cnt, 0, 0, cost/reason_cnt)) COST_SHORTFALL,
       sum(decode(reason_cnt, 0, 0, cost*curr.rate/reason_cnt)) COST_SHORTFALL_G,
       sum(decode(reason_cnt, 0, 0, cost*curr.rate2/reason_cnt)) COST_SHORTFALL_G1,
       f.uom_code
  FROM (
SELECT /*+ ordered no_merge use_hash(ID,REASON) parallel(ID) paralell(REASON)
                  pq_distribute(ID,hash,hash) pq_distribute(REASON,hash,hash) */ tmp.snapshot_id,
       id.demand_id,
       id.time_dmd_date_id,
       id.sr_inventory_item_id DMD_ITEM_ID,
       id.organization_id,
       reason.organization_type,
       reason.sr_inventory_item_id R_ITEM_ID,
       reason.sr_supplier_id R_SUPPLIER_ID,
       reason.sr_supplier_site_id R_SUPPLIER_SITE_ID,
       reason.organization_id R_ORG_ID,
       reason.resource_id R_RESOURCE_ID,
       reason.department_id R_DEPARTMENT_ID,
       nvl(reason.reason_type, 0) REASON_TYPE,
       avg(decode(id.origination_type,
              6, nvl(id.selling_price * id.using_requirement_quantity,0),
              30, nvl(id.selling_price * id.using_requirement_quantity,0),
              nvl((id.list_price * (100-id.average_discount)/100 * id.using_requirement_quantity),0))) REVENUE,
       avg(nvl(id.standard_cost * id.using_requirement_quantity,0)) COST,
       sum(1) over (partition by tmp.snapshot_id, id.demand_id) CNT,
       sum(decode(reason.reason_type, null, 0, 1)) over (partition by tmp.snapshot_id, id.demand_id) REASON_CNT,
       avg(decode(reason.reason_type, null, 0, 1)) LATE_LINES,
       id.uom_code
  FROM isc_dbi_tmp_plans tmp,
       isc_dbi_demands_f id,
       (SELECT /*+ ordered */ peg1.plan_id, peg1.demand_id,
	       r.organization_type, r.sr_inventory_item_id, r.sr_supplier_id, r.sr_supplier_site_id,
	       r.organization_id, r.resource_id, r.department_id,
	       decode(r.exception_type, 23, 2, 1) reason_type
 	  FROM isc_dbi_tmp_plans p, isc_dbi_exception_details_f r, isc_dbi_full_pegging_f peg1
	 WHERE bitand(p.plan_usage, 2) = 2
	   AND p.plan_id = r.plan_id
	   AND p.constrained_flag = 2
	   AND r.exception_type in (15, 16, 23, 42)
	   AND r.plan_id = peg1.plan_id
	   AND r.number2 = peg1.pegging_id) reason
 WHERE bitand(tmp.plan_usage, 2) = 2
   AND tmp.plan_id = id.plan_id
   AND tmp.constrained_flag = 2
   AND id.origination_type in (6,7,8,9,10,11,12,15,22,24,27,29,30)
   AND reason.plan_id(+) = id.plan_id
   AND reason.demand_id(+) = id.demand_id
 GROUP BY tmp.snapshot_id, id.organization_id, id.uom_code, id.demand_id, id.time_dmd_date_id, id.sr_inventory_item_id,
	  reason.organization_type, reason.sr_inventory_item_id, reason.sr_supplier_id, reason.sr_supplier_site_id,
	  reason.organization_id, reason.resource_id, reason.department_id, reason.reason_type) f,
       isc_dbi_plan_curr_rates curr,
       fii_time_day time
 WHERE f.time_dmd_date_id = time.report_date
   AND f.organization_id = curr.organization_id
 GROUP BY f.snapshot_id, f.organization_id, f.dmd_item_id, f.uom_code, f.organization_type, f.reason_type,
	  f.r_item_id, f.r_supplier_id, f.r_supplier_site_id, f.r_resource_id, f.r_org_id, f.r_department_id,
	  grouping sets(ent_year_start_date, ent_qtr_start_date, ent_period_start_date);

 FII_UTIL.Stop_Timer;
 FII_UTIL.Print_Timer('Inserted '|| sql%rowcount ||' rows into isc_dbi_shortfall_snapshots in');

 BIS_COLLECTION_UTILITIES.put_line(' ');
 BIS_COLLECTION_UTILITIES.put_line('Begin to insert data into isc_dbi_shortfall_snapshots for constrained plans.');
 FII_UTIL.Start_Timer;

INSERT
  INTO isc_dbi_shortfall_snapshots F(
	SNAPSHOT_ID,
	ORGANIZATION_ID,
	START_DATE,
	PERIOD_TYPE_ID,
	REASON_TYPE,
        DMD_ITEM_ID,
	ORGANIZATION_TYPE,
        R_ITEM_ID,
	R_SUPPLIER_ID,
	R_SUPPLIER_SITE_ID,
	R_RESOURCE_ID,
	R_ORG_ID,
	R_DEPARTMENT_ID,
	REV_TEMP,
	REV_TEMP_G,
	REV_TEMP_G1,
	COST_TEMP,
	COST_TEMP_G,
	COST_TEMP_G1,
	LATE_LINES_TEMP,
	TOTAL_LINES_TEMP,
	REV_SHORTFALL,
	REV_SHORTFALL_G,
	REV_SHORTFALL_G1,
	COST_SHORTFALL,
	COST_SHORTFALL_G,
	COST_SHORTFALL_G1,
	UOM_CODE)
SELECT /*+ parallel(f)  use_hash(TIME,CURR) */ f.snapshot_id SNAPSHOT_ID, f.organization_id,
       decode(grouping_id(ent_year_start_date, ent_qtr_start_date, ent_period_start_date),
	      6, ent_period_start_date, 5, ent_qtr_start_date, 3, ent_year_start_date) START_DATE,
       decode(grouping_id(ent_year_start_date, ent_qtr_start_date, ent_period_start_date),
	      6, 32, 5, 64, 3, 128) PERIOD_TYPE_ID,
       f.reason_type, f.dmd_item_id, f.organization_type,
       f.r_item_id, f.r_supplier_id, f.r_supplier_site_id, f.r_resource_id, f.r_org_id, f.r_department_id,
       sum(revenue/cnt) REV_TEMP, sum(revenue*curr.rate/cnt) REV_TEMP_G, sum(revenue*curr.rate2/cnt) REV_TEMP_G1,
       sum(cost/cnt) COST_TEMP, sum(cost*curr.rate/cnt) COST_TEMP_G, sum(cost*curr.rate2/cnt) COST_TEMP_G1,
       sum(late_lines/cnt) LATE_LINES_TEMP, sum(1/cnt) TOTAL_LINES_TEMP,
       sum(decode(reason_cnt, 0, 0, revenue/reason_cnt)) REV_SHORTFALL,
       sum(decode(reason_cnt, 0, 0, revenue*curr.rate/reason_cnt)) REV_SHORTFALL_G,
       sum(decode(reason_cnt, 0, 0, revenue*curr.rate2/reason_cnt)) REV_SHORTFALL_G1,
       sum(decode(reason_cnt, 0, 0, cost/reason_cnt)) COST_SHORTFALL,
       sum(decode(reason_cnt, 0, 0, cost*curr.rate/reason_cnt)) COST_SHORTFALL_G,
       sum(decode(reason_cnt, 0, 0, cost*curr.rate2/reason_cnt)) COST_SHORTFALL_G1,
       f.uom_code
  FROM (
SELECT /*+ ordered no_merge use_hash(ID,REASON) parallel(ID) paralell(REASON)
                  pq_distribute(ID,hash,hash) pq_distribute(REASON,hash,hash) */ tmp.snapshot_id,
       id.demand_id,
       id.time_dmd_date_id,
       id.sr_inventory_item_id DMD_ITEM_ID,
       id.organization_id,
       reason.organization_type,
       reason.sr_inventory_item_id R_ITEM_ID,
       reason.sr_supplier_id R_SUPPLIER_ID,
       reason.sr_supplier_site_id R_SUPPLIER_SITE_ID,
       reason.organization_id R_ORG_ID,
       reason.resource_id R_RESOURCE_ID,
       reason.department_id R_DEPARTMENT_ID,
       decode(iex.number1, null, 0, nvl(reason.reason_type, -1)) REASON_TYPE,
       avg(decode(id.origination_type,
              6, nvl(id.selling_price * id.using_requirement_quantity,0),
              30, nvl(id.selling_price * id.using_requirement_quantity,0),
              nvl((id.list_price * (100-id.average_discount)/100 * id.using_requirement_quantity),0))) REVENUE,
       avg(nvl(id.standard_cost * id.using_requirement_quantity,0)) COST,
       sum(1) over (partition by tmp.snapshot_id, id.demand_id) CNT,
       sum(decode(iex.number1, null, 0, 1)) over (partition by tmp.snapshot_id, id.demand_id) REASON_CNT,
       avg(CASE WHEN iex.late_lines >= 1 THEN 1 ELSE 0 END) LATE_LINES,
       id.uom_code
  FROM isc_dbi_tmp_plans tmp,
       isc_dbi_demands_f id,
       (SELECT plan_id, number1, sum(decode(exception_type, 13, 1, 14, 1, 24, 1, 26, 1, 0)) LATE_LINES
	  FROM isc_dbi_exception_details_f ex
	 WHERE ex.exception_type in (13, 14, 24, 26, 52) AND ex.number1 is not null
	 GROUP BY plan_id, number1) iex,
       (SELECT /*+ ordered */ peg1.plan_id, peg.demand_id,
	       r.organization_type, r.sr_inventory_item_id, r.sr_supplier_id, r.sr_supplier_site_id,
	       r.organization_id, r.resource_id, r.department_id,
	       decode(r.exception_type,36,2,53,2,58,2,60,2,63,2,40,3,55,3,56,3,61,3,1) reason_type
 	  FROM isc_dbi_tmp_plans p, isc_dbi_exception_details_f r, isc_dbi_full_pegging_f peg1, isc_dbi_full_pegging_f peg
	 WHERE bitand(p.plan_usage, 2) = 2
	   AND p.constrained_flag = 1
	   AND p.plan_id = r.plan_id
	   AND r.exception_type in (9, 36, 37, 40, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 66, 67)
	   AND r.plan_id = peg1.plan_id
	   AND r.number1 = peg1.transaction_id
	   AND peg.plan_id = peg1.plan_id
	   AND peg.pegging_id = peg1.end_pegging_id) reason
 WHERE tmp.plan_id = id.plan_id
   AND bitand(tmp.plan_usage, 2) = 2
   AND tmp.constrained_flag = 1
   AND id.demand_id = iex.number1(+)
   AND id.plan_id = iex.plan_id(+)
   AND id.origination_type in (6,7,8,9,10,11,12,15,22,24,27,29,30)
   AND reason.plan_id(+) = id.plan_id
   AND reason.demand_id(+) = id.demand_id
 GROUP BY tmp.snapshot_id, id.organization_id, id.uom_code, id.demand_id, id.time_dmd_date_id, id.sr_inventory_item_id,
	  iex.number1, reason.organization_type, reason.sr_inventory_item_id, reason.sr_supplier_id, reason.sr_supplier_site_id,
	  reason.organization_id, reason.resource_id, reason.department_id, reason.reason_type) f,
       isc_dbi_plan_curr_rates curr,
       fii_time_day time
 WHERE f.time_dmd_date_id = time.report_date
   AND f.organization_id = curr.organization_id
 GROUP BY f.snapshot_id, f.organization_id, f.dmd_item_id, f.uom_code, f.organization_type, f.reason_type,
	  f.r_item_id, f.r_supplier_id, f.r_supplier_site_id, f.r_resource_id, f.r_org_id, f.r_department_id,
	  grouping sets(ent_year_start_date, ent_qtr_start_date, ent_period_start_date);

 FII_UTIL.Stop_Timer;
 FII_UTIL.Print_Timer('Inserted '|| sql%rowcount ||' rows into isc_dbi_shortfall_snapshots in');
-- COMMIT;

      --  ------------------------------------
      --  Collect ISC_DBI_INV_DETAIL_SNAPSHOTS
      --  ------------------------------------

 BIS_COLLECTION_UTILITIES.put_line(' ');
 BIS_COLLECTION_UTILITIES.put_line('Begin to insert data into isc_dbi_inv_detail_snapshots.');
 FII_UTIL.Start_Timer;

-- item level only

INSERT /*+ APPEND PARALLEL(F) */
   INTO isc_dbi_inv_detail_snapshots f(
	SNAPSHOT_ID,
	ORGANIZATION_ID,
	SR_INVENTORY_ITEM_ID,
	START_DATE,
	PERIOD_TYPE_ID,
	UOM_CODE,
	CARRYING_COST,
	CARRYING_COST_G,
	CARRYING_COST_G1,
	COST_SHORTFALL,
	COST_SHORTFALL_G,
	COST_SHORTFALL_G1,
	INVENTORY_COST,
	INVENTORY_COST_G,
	INVENTORY_COST_G1,
	MDS_COST,
	MDS_COST_G,
	MDS_COST_G1,
	MDS_PRICE,
	MDS_PRICE_G,
	MDS_PRICE_G1,
	MDS_QUANTITY,
	PRODUCTION_COST,
	PRODUCTION_COST_G,
	PRODUCTION_COST_G1,
	PURCHASING_COST,
	PURCHASING_COST_G,
	PURCHASING_COST_G1,
	LATE_LINES,
	REV_SHORTFALL,
	REV_SHORTFALL_G,
	REV_SHORTFALL_G1,
	TOTAL_LINES,
	UNION1_FLAG,
	UNION2_FLAG)
SELECT snapshot_id, organization_id, sr_inventory_item_id, start_date, period_type_id, uom_code,
       sum(carrying_cost), sum(carrying_cost_g), sum(carrying_cost_g1), sum(cost_shortfall), sum(cost_shortfall_g), sum(cost_shortfall_g1), sum(inventory_cost), sum(inventory_cost_g), sum(inventory_cost_g1),
       sum(mds_cost), sum(mds_cost_g), sum(mds_cost_g1), sum(mds_price), sum(mds_price_g), sum(mds_price_g1), sum(mds_quantity),
       sum(production_cost), sum(production_cost_g), sum(production_cost_g1), sum(purchasing_cost), sum(purchasing_cost_g), sum(purchasing_cost_g1),
       sum(late_lines), sum(rev_shortfall), sum(rev_shortfall_g), sum(rev_shortfall_g1), sum(total_lines), sum(union1_flag), sum(union2_flag)
  FROM (SELECT fact.snapshot_id, fact.organization_id, fact.sr_inventory_item_id,
               decode(grouping_id(fact.ent_year_start_date, fact.ent_qtr_start_date, fact.ent_period_start_date),
       	 		6, fact.ent_period_start_date, 5, fact.ent_qtr_start_date, 3, fact.ent_year_start_date) START_DATE,
               decode(grouping_id(fact.ent_year_start_date, fact.ent_qtr_start_date, fact.ent_period_start_date),
       	       		6, 32, 5, 64, 3, 128) PERIOD_TYPE_ID, uom_code,
               sum(carrying_cost) CARRYING_COST, sum(carrying_cost*curr.rate) CARRYING_COST_G, sum(carrying_cost*curr.rate2) CARRYING_COST_G1,
	       sum(cost_shortfall) COST_SHORTFALL, sum(cost_shortfall*curr.rate) COST_SHORTFALL_G, sum(cost_shortfall*curr.rate2) COST_SHORTFALL_G1,
               sum(decode(report_date, ent_period_start_date,inventory_cost, 0)) INVENTORY_COST,
               sum(decode(report_date, ent_period_start_date,inventory_cost*curr.rate, 0)) INVENTORY_COST_G,
               sum(decode(report_date, ent_period_start_date,inventory_cost*curr.rate2, 0)) INVENTORY_COST_G1,
               sum(mds_cost) MDS_COST, sum(mds_cost*curr.rate) MDS_COST_G, sum(mds_cost*curr.rate2) MDS_COST_G1,
	       sum(mds_price) MDS_PRICE, sum(mds_price*curr.rate) MDS_PRICE_G, sum(mds_price*curr.rate2) MDS_PRICE_G1, sum(MDS_QUANTITY) MDS_QUANTITY,
               sum(production_cost) PRODUCTION_COST, sum(production_cost*curr.rate) PRODUCTION_COST_G, sum(production_cost*curr.rate2) PRODUCTION_COST_G1,
	       sum(purchasing_cost) PURCHASING_COST, sum(purchasing_cost*curr.rate) PURCHASING_COST_G, sum(purchasing_cost*curr.rate2) PURCHASING_COST_G1,
               sum(late_lines) LATE_LINES, sum(rev_shortfall) REV_SHORTFALL, sum(rev_shortfall*curr.rate) REV_SHORTFALL_G, sum(rev_shortfall*curr.rate2) REV_SHORTFALL_G1,
	       sum(total_lines) TOTAL_LINES, sum(union1_flag) UNION1_FLAG, sum(union2_flag) UNION2_FLAG
          FROM (SELECT /*+ parallel(iinv) */ tmp.snapshot_id, iinv.organization_id, iinv.sr_inventory_item_id,
		        iinv.uom_code UOM_CODE, time1.report_date,
			time1.ent_period_start_date, time1.ent_qtr_start_date, time1.ent_year_start_date,
			nvl(iinv.carrying_cost,0)/(per.end_date - per.start_date + 1) CARRYING_COST,
			0 COST_SHORTFALL,
 			nvl(iinv.inventory_cost,0) INVENTORY_COST,
 			0 MDS_COST,
			0 MDS_PRICE,
			nvl(iinv.mds_quantity,0)/(per.end_date - per.start_date + 1) MDS_QUANTITY,
			nvl(iinv.production_cost,0)/(per.end_date - per.start_date + 1) PRODUCTION_COST,
			0 PURCHASING_COST,
	        	0 LATE_LINES,
			0 REV_SHORTFALL,
			0 TOTAL_LINES,
			1 UNION1_FLAG,
			0 UNION2_FLAG
   		  FROM isc_dbi_tmp_plans tmp,
			isc_dbi_inv_detail_f iinv,
			isc_dbi_periods per,
			fii_time_day time1
	  	 WHERE tmp.plan_id = iinv.plan_id
	    	   AND bitand(tmp.plan_usage, 2) = 2
	   	   AND iinv.organization_id = per.organization_id
	   	   AND per.adjustment_period_flag = 'N'
		   AND iinv.detail_date = per.start_date
		   AND time1.report_date between per.start_date and per.end_date) fact,
	       isc_dbi_plan_curr_rates curr
         WHERE fact.organization_id = curr.organization_id
  	 GROUP BY fact.snapshot_id, fact.organization_id, fact.sr_inventory_item_id, fact.uom_code,
	  	  grouping sets(fact.ent_year_start_date, fact.ent_qtr_start_date, fact.ent_period_start_date)
 	UNION ALL
 	SELECT sup.snapshot_id, organization_id, sr_inventory_item_id, start_date, period_type_id, uom_code UOM_CODE,
        	0 CARRYING_COST, 0 CARRYING_COST_G, 0 CARRYING_COST_G1, 0 COST_SHORTFALL, 0 COST_SHORTFALL_G, 0 COST_SHORTFALL_G1, 0 INVENTORY_COST, 0 INVENTORY_COST_G, 0 INVENTORY_COST_G1,
		0 MDS_COST, 0 MDS_COST_G, 0 MDS_COST_G1, 0 MDS_PRICE, 0 MDS_PRICE_G, 0 MDS_PRICE_G1, 0 MDS_QUANTITY, 0 PRODUCTION_COST, 0 PRODUCTION_COST_G, 0 PRODUCTION_COST_G1,
		purchasing_cost PURCHASING_COST, purchasing_cost_g PURCHASING_COST_G, purchasing_cost_g1 PURCHASING_COST_G1,
		0 LATE_LINES, 0 REV_SHORTFALL, 0 REV_SHORTFALL_G, 0 REV_SHORTFALL_G1, 0 TOTAL_LINES, 1 UNION1_FLAG, 0 UNION2_FLAG
   	  FROM isc_dbi_tmp_plans tmp,
	       isc_dbi_supplies_snapshots sup
 	 WHERE tmp.snapshot_id = sup.snapshot_id
    	   AND bitand(tmp.plan_usage, 2) = 2
 	 UNION ALL
	SELECT sh.snapshot_id, sh.organization_id, sh.dmd_item_id, sh.start_date, sh.period_type_id, sh.uom_code,
        	0 CARRYING_COST, 0 CARRYING_COST_G, 0 CARRYING_COST_G1, sh.cost_shortfall COST_SHORTFALL, sh.cost_shortfall_g COST_SHORTFALL_G, sh.cost_shortfall_g1 COST_SHORTFALL_G1,
		0 INVENTORY_COST, 0 INVENTORY_COST_G, 0 INVENTORY_COST_G1, cost_temp MDS_COST, cost_temp_g MDS_COST_G, cost_temp_g1 MDS_COST_G1,
		rev_temp MDS_PRICE, rev_temp_g MDS_PRICE_G, rev_temp_g1 MDS_PRICE_G1, 0 MDS_QUANTITY,
        	0 PRODUCTION_COST, 0 PRODUCTION_COST_G, 0 PRODUCTION_COST_G1, 0 PURCHASING_COST, 0 PURCHASING_COST_G, 0 PURCHASING_COST_G1, late_lines_temp LATE_LINES,
		sh.rev_shortfall REV_SHORTFALL, sh.rev_shortfall_G REV_SHORTFALL_G, sh.rev_shortfall_G1 REV_SHORTFALL_G1, total_lines_temp TOTAL_LINES,
        	1 UNION1_FLAG, 1 UNION2_FLAG
   	  FROM isc_dbi_tmp_plans tmp,
	       isc_dbi_shortfall_snapshots sh
  	 WHERE tmp.snapshot_id = sh.snapshot_id
    	   AND bitand(tmp.plan_usage, 2) = 2)
  GROUP BY snapshot_id, organization_id, sr_inventory_item_id, start_date, period_type_id, uom_code;

 FII_UTIL.Stop_Timer;
 FII_UTIL.Print_Timer('Inserted '|| sql%rowcount ||' rows into isc_dbi_inv_detail_snapshots in');
-- COMMIT;

      --  ----------------------------------
      --  Collect ISC_DBI_RES_SUM_SNAPSHOTS
      --  ----------------------------------

 BIS_COLLECTION_UTILITIES.put_line(' ');
 BIS_COLLECTION_UTILITIES.put_line('Begin to insert data into isc_dbi_res_sum_snapshots.');
 FII_UTIL.Start_Timer;

 INSERT /*+ APPEND PARALLEL(F) */
   INTO isc_dbi_res_sum_snapshots F(
  	SNAPSHOT_ID,
  	ORGANIZATION_ID,
  	START_DATE,
  	PERIOD_TYPE_ID,
	DEPARTMENT_ID,
	ORGANIZATION_TYPE,
  	RESOURCE_ID,
  	REQUIRED_HOURS,
  	AVAILABLE_HOURS)
 SELECT /*+ parallel(ires) */ tmp.snapshot_id,
	ires.organization_id,
        decode(grouping_id(ent_year_start_date, ent_qtr_start_date, ent_period_start_date),
	       6, ent_period_start_date, 5, ent_qtr_start_date, 3, ent_year_start_date) START_DATE,
        decode(grouping_id(ent_year_start_date, ent_qtr_start_date, ent_period_start_date),
	      6, 32, 5, 64, 3, 128) PERIOD_TYPE_ID,
  	ires.department_id DEPARTMENT_ID,
	ires.organization_type ORGANIZATION_TYPE,
	ires.resource_id,
	sum(nvl(required_hours,0)/(per.end_date-per.start_date+1)) REQUIRED_HOURS,
	sum(nvl(available_hours,0)/(per.end_date-per.start_date+1)) AVAILABLE_HOURS
   FROM isc_dbi_tmp_plans tmp,
	isc_dbi_res_summary_f ires,
	isc_dbi_periods	per,
	fii_time_day time
  WHERE tmp.plan_id = ires.plan_id
    AND bitand(tmp.plan_usage, 2) = 2
    AND ires.organization_id = per.organization_id
    AND per.adjustment_period_flag = 'N'
    AND ires.resource_date = per.start_date
    AND time.report_date between per.start_date and per.end_date
--    AND ires.resource_id > 0
  GROUP BY snapshot_id, ires.organization_id, ires.resource_id, ires.organization_type, ires.department_id,
 	   grouping sets(ent_year_start_date, ent_qtr_start_date, ent_period_start_date);

 FII_UTIL.Stop_Timer;
 FII_UTIL.Print_Timer('Inserted '|| sql%rowcount ||' rows into isc_dbi_res_sum_snapshots in');
-- COMMIT;
END IF;

 RETURN(1);

EXCEPTION
  WHEN OTHERS THEN
    g_errbuf  := 'Error in Function LOAD_SNAPSHOTS : '||sqlerrm;
    g_retcode := sqlcode;
    RETURN(-1);
END load_snapshots;

Function purge_snapshots RETURN NUMBER IS

  l_stmt 		VARCHAR2(2000);
  l_snapshot_id   	NUMBER;
  l_total		NUMBER;

  CURSOR List_of_Snapshots IS
    SELECT snapshot_id
      FROM isc_dbi_plan_snapshots
     WHERE purge_flag = 'Y';

  no_partition EXCEPTION;
  PRAGMA EXCEPTION_INIT(no_partition, -02149);

BEGIN

  OPEN List_of_Snapshots;
  FETCH List_of_Snapshots INTO l_snapshot_id;

  IF List_of_Snapshots%ROWCOUNT <> 0 THEN
    WHILE List_of_Snapshots%FOUND LOOP
      BIS_COLLECTION_UTILITIES.Put_Line('Purging snapshot '|| l_snapshot_id);
      IF (drop_snapshots(l_snapshot_id) = -1) THEN RETURN(-1); END IF;
      FETCH List_of_Snapshots INTO l_snapshot_id;
    END LOOP;
  END IF;

  l_total := List_of_Snapshots%ROWCOUNT;
  CLOSE List_of_Snapshots;
  RETURN(l_total);

EXCEPTION
  WHEN OTHERS THEN
    g_errbuf  := 'Error in function purge_snapshots : '||sqlerrm;
    RETURN(-1);

END purge_snapshots;

Function WrapUp RETURN NUMBER IS

l_plan_name		VARCHAR2(30);
l_date			DATE;
l_total			NUMBER;

/*
CURSOR Plan_List IS
  SELECT plan_name
    FROM isc_dbi_tmp_plans tmp
   WHERE bitand(plan_usage, 2) = 2;
*/
CURSOR Plan_List IS
  SELECT tmp.plan_name
    FROM isc_dbi_tmp_plans tmp, isc_dbi_plan_schedules s
   WHERE (bitand(tmp.plan_usage, 2) = 2 or bitand(tmp.plan_usage, 4) = 4)
     AND tmp.plan_name = s.plan_name
     AND s.frequency <> 'ONCE';

BEGIN

      --  --------------------------------------------
      --  Update the last and next collection date
      --  --------------------------------------------

  BIS_COLLECTION_UTILITIES.Put_Line(' ');
  BIS_COLLECTION_UTILITIES.put_line('Begin to update the collection information.');
  FII_UTIL.Start_Timer;

  DELETE from isc_dbi_plan_schedules
   WHERE frequency = 'ONCE'
     AND next_collection_date <= g_snapshot_date
     AND plan_name IN (select plan_name from isc_dbi_tmp_plans tmp
                        WHERE (bitand(tmp.plan_usage, 2) = 2 or bitand(tmp.plan_usage, 4) = 4));

  UPDATE isc_dbi_plan_schedules
     SET last_collected_date = g_snapshot_date
   WHERE plan_name IN (select plan_name from isc_dbi_tmp_plans tmp
                        WHERE (bitand(tmp.plan_usage, 2) = 2 or bitand(tmp.plan_usage, 4) = 4));

  -- API to populate the next collection date

  OPEN Plan_List;
  FETCH Plan_List INTO l_plan_name;

  IF Plan_List%ROWCOUNT <> 0 THEN
    WHILE Plan_List%FOUND LOOP
      BEGIN
        BIS_COLLECTION_UTILITIES.Put_Line('Populating the next collection date for plan '|| l_plan_name);
        l_date := ISC_DBI_PLAN_SETUP_UTIL_PKG.get_next_collection_date(l_plan_name);
        UPDATE isc_dbi_plan_schedules
           SET next_collection_date = l_date
         WHERE plan_name = l_plan_name;
      EXCEPTION
      WHEN no_data_found THEN
        BIS_COLLECTION_UTILITIES.put_line('Plan ' || l_plan_name || ' has already been deleted from the setup form.');
      END;
      FETCH Plan_List INTO l_plan_name;
    END LOOP;
  END IF;

  l_total := Plan_List%ROWCOUNT;
  CLOSE Plan_List;

--  UPDATE isc_dbi_plan_schedules
--     SET next_collection_date = ISC_DBI_PLAN_SETUP_UTIL_PKG.get_next_collection_date(plan_name)
--   WHERE plan_name IN (select plan_name from isc_dbi_tmp_plans tmp WHERE bitand(tmp.plan_usage, 2) = 2);

  FII_UTIL.Stop_Timer;
  FII_UTIL.Print_Timer('Updated the setup tables in');
  BIS_COLLECTION_UTILITIES.Put_Line(' ');

/*
      -- ------------------------
      -- Delete ISC_DBI_TMP_PLANS
      -- ------------------------

  BIS_COLLECTION_UTILITIES.put_line(' ');
  BIS_COLLECTION_UTILITIES.put_line('Truncating the temp table');
  FII_UTIL.Start_Timer;

  l_trunc_stmt := 'truncate table ' || g_isc_schema ||'.isc_dbi_tmp_plans';
  EXECUTE IMMEDIATE l_trunc_stmt;

  FII_UTIL.Stop_Timer;
  FII_UTIL.Print_Timer('Truncated the temp table in');
*/
      -- ----------------------------------------------
      -- No exception raised so far.  Successful.  Call
      -- Wrapup to commit and insert messages into logs
      -- ----------------------------------------------
  COMMIT;

  BIS_COLLECTION_UTILITIES.WRAPUP(TRUE, 0, NULL, NULL, NULL);
  RETURN(1);

EXCEPTION
  WHEN OTHERS THEN
    g_errbuf  := 'Error in function wrapup : '||sqlerrm;
    RETURN(-1);

END wrapup;

      ---------------------
      -- Public Procedures
      ---------------------

Procedure load_facts(errbuf		IN OUT NOCOPY VARCHAR2,
                     retcode		IN OUT NOCOPY VARCHAR2) IS

l_failure		EXCEPTION;
l_no_aps_failure	EXCEPTION;
l_purge			NUMBER;
l_base			NUMBER;
l_trunc_stmt		VARCHAR2(500);

l_partition_name	VARCHAR2(80);
l_drop_stmt             VARCHAR2(2000);

CURSOR Get_Partitions(p_table_name IN VARCHAR2, p_schema_name IN VARCHAR2) IS
  SELECT partition_name
    FROM all_tab_partitions
   WHERE table_name = p_table_name
     AND table_owner = p_schema_name;

BEGIN
  errbuf  := NULL;
  retcode := '0';

  IF (NOT BIS_COLLECTION_UTILITIES.setup('ISC_DBI_PLAN_F')) THEN
     RAISE_APPLICATION_ERROR (-20000,'Error in SETUP: ' || errbuf);
     return;
  END IF;

  EXECUTE IMMEDIATE 'alter session set hash_area_size=104857600';
  EXECUTE IMMEDIATE 'alter session set sort_area_size=104857600';

      --  --------------------------------------------
      --  Load Base Tables
      --  --------------------------------------------

  l_base := LOAD_BASES_INIT;

  IF (l_base = -1)
    THEN RAISE l_no_aps_failure;
  END IF;

      --  --------------------------------------------------------
      --  Truncate all the snapshot tables before the initial load
      --  --------------------------------------------------------

  BIS_COLLECTION_UTILITIES.put_line(' ');
  BIS_COLLECTION_UTILITIES.put_line('Begin to truncate and drop all the snapshots');

--  Bug 4939001: Drop all partitions during initial load
--
--   FOR j in 1..g_large_snapshots.last LOOP
--      l_trunc_stmt := 'truncate table ' || g_isc_schema ||'.'|| g_large_snapshots(j);
--      EXECUTE IMMEDIATE l_trunc_stmt;
--   END LOOP;

   FOR j in 1..g_large_snapshots.last LOOP
       OPEN Get_Partitions(g_large_snapshots(j), g_isc_schema);
       FETCH Get_Partitions INTO l_partition_name;
       IF Get_Partitions%ROWCOUNT <> 0 THEN
          WHILE Get_Partitions%Found LOOP
            IF upper(l_partition_name) <> 'S_0' THEN
               l_drop_stmt := 'ALTER TABLE '|| g_isc_schema || '.' || g_large_snapshots(j) || ' DROP PARTITION ' || l_partition_name;
               EXECUTE IMMEDIATE l_drop_stmt;
            END IF;
            FETCH Get_Partitions INTO l_partition_name;
          END LOOP;
       END IF;
       CLOSE Get_Partitions;
   END LOOP;

  g_rebuild_snapshot_index := 'Y';

  FOR i in 1..g_small_snapshots.last LOOP
     l_trunc_stmt := 'truncate table ' || g_isc_schema ||'.'|| g_small_snapshots(i);
     EXECUTE IMMEDIATE l_trunc_stmt;
  END LOOP;

  FII_UTIL.Stop_Timer;
  FII_UTIL.Print_Timer('Truncated the snapshot tables in');
  BIS_COLLECTION_UTILITIES.Put_Line(' ');

      --  --------------------------------------------
      --  Insert data into the snapshot tables
      --  --------------------------------------------

  BIS_COLLECTION_UTILITIES.put_line(' ');
  BIS_COLLECTION_UTILITIES.put_line('Begin to load the snapshot tables');

  IF (load_snapshots = -1) THEN
    RAISE l_failure;
  END IF;

  IF (wrapup = -1) THEN
    RAISE l_failure;
  END IF;

  retcode := g_retcode;
  errbuf := g_errbuf;

EXCEPTION

  WHEN L_FAILURE THEN
    ROLLBACK;
    BIS_COLLECTION_UTILITIES.put_line(' ');
    BIS_COLLECTION_UTILITIES.put_line(g_errbuf);
    retcode := -1;
    errbuf := g_errbuf;

    BIS_COLLECTION_UTILITIES.WRAPUP(
    FALSE,
    g_row_count,
    g_errbuf,
    NULL,
    NULL
    );

  WHEN L_NO_APS_FAILURE THEN
    ROLLBACK;
    retcode := -1;
    errbuf := g_errbuf;

    BIS_COLLECTION_UTILITIES.WRAPUP(
    FALSE,
    g_row_count,
    g_errbuf,
    NULL,
    NULL
    );

  WHEN OTHERS THEN
    ROLLBACK;
    g_errbuf := sqlerrm ||' - '||sqlcode;
    BIS_COLLECTION_UTILITIES.put_line(' ');
    BIS_COLLECTION_UTILITIES.put_line('Other errors : '|| g_errbuf);
    retcode := -1;
    errbuf := g_errbuf;

    BIS_COLLECTION_UTILITIES.WRAPUP(
    FALSE,
    g_row_count,
    g_errbuf,
    NULL,
    NULL
    );

END load_facts;

Procedure update_facts(errbuf		IN OUT NOCOPY VARCHAR2,
                     retcode		IN OUT NOCOPY VARCHAR2) IS

l_failure		EXCEPTION;
l_no_aps_failure	EXCEPTION;
l_purge			NUMBER;
l_base			NUMBER;

BEGIN
  errbuf  := NULL;
  retcode := '0';

  IF (NOT BIS_COLLECTION_UTILITIES.setup('ISC_DBI_PLAN_F_INC')) THEN
     RAISE_APPLICATION_ERROR (-20000,'Error in SETUP: ' || errbuf);
     return;
  END IF;

  EXECUTE IMMEDIATE 'alter session set hash_area_size=104857600';
  EXECUTE IMMEDIATE 'alter session set sort_area_size=104857600';

      --  --------------------------------------------
      --  Load Base Tables
      --  --------------------------------------------

  l_base := LOAD_BASES;

  IF (l_base = -1)
    THEN RAISE l_no_aps_failure;
  END IF;

      --  --------------------------------------------
      --  Purge Snapshot Tables
      --  --------------------------------------------

  BIS_COLLECTION_UTILITIES.Put_Line(' ');
  BIS_COLLECTION_UTILITIES.put_line('Begin to purge the obsolete snapshots ');
  FII_UTIL.Start_Timer;

  l_purge := PURGE_SNAPSHOTS;

  IF (l_purge = -1) THEN
    RAISE l_failure;
  END IF;

  FII_UTIL.Stop_Timer;
  FII_UTIL.Print_Timer('Purged '|| l_purge ||' snapshots in');
  BIS_COLLECTION_UTILITIES.Put_Line(' ');

      --  --------------------------------------------
      --  Insert data into the snapshot tables
      --  --------------------------------------------

  BIS_COLLECTION_UTILITIES.put_line(' ');
  BIS_COLLECTION_UTILITIES.put_line('Begin to load the snapshot tables');

  IF (load_snapshots = -1) THEN
    RAISE l_failure;
  END IF;

  IF (wrapup = -1) THEN
    RAISE l_failure;
  END IF;

  retcode := g_retcode;
  errbuf := g_errbuf;

EXCEPTION

  WHEN L_FAILURE THEN
    ROLLBACK;
    BIS_COLLECTION_UTILITIES.put_line(' ');
    BIS_COLLECTION_UTILITIES.put_line(g_errbuf);
    retcode := -1;
    errbuf := g_errbuf;

    BIS_COLLECTION_UTILITIES.WRAPUP(
    FALSE,
    g_row_count,
    g_errbuf,
    NULL,
    NULL
    );

  WHEN L_NO_APS_FAILURE THEN
    ROLLBACK;
    retcode := -1;
    errbuf := g_errbuf;

    BIS_COLLECTION_UTILITIES.WRAPUP(
    FALSE,
    g_row_count,
    g_errbuf,
    NULL,
    NULL
    );

  WHEN OTHERS THEN
    ROLLBACK;
    g_errbuf := sqlerrm ||' - '||sqlcode;
    BIS_COLLECTION_UTILITIES.put_line(' ');
    BIS_COLLECTION_UTILITIES.put_line('Other errors : '|| g_errbuf);
    retcode := -1;
    errbuf := g_errbuf;

    BIS_COLLECTION_UTILITIES.WRAPUP(
    FALSE,
    g_row_count,
    g_errbuf,
    NULL,
    NULL
    );

END update_facts;

END ISC_DBI_MSC_OBJECTS_C;


/
