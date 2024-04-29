--------------------------------------------------------
--  DDL for Package Body MSC_CL_LOADERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_CL_LOADERS" AS -- body
/* $Header: MSCCLLDB.pls 120.4.12010000.3 2010/03/19 12:56:18 vsiyer ship $ */
  -- ========= Global Parameters ===========

   -- User Environment --
   v_current_date               DATE:= sysdate;
   v_current_user               NUMBER;
   v_applsys_schema             VARCHAR2(32);
   v_monitor_request_id         NUMBER;
   v_request_id                 NumTblTyp:= NumTblTyp(0);
   v_ctl_file                   VarcharTblTyp:= VarcharTblTyp(0);
   v_dat_file                   VarcharTblTyp:= VarcharTblTyp(0);
   v_bad_file                   VarcharTblTyp:= VarcharTblTyp(0);
   v_dis_file                   VarcharTblTyp:= VarcharTblTyp(0);
   v_dat_file_path              VARCHAR2(1000):='';
   v_path_seperator             VARCHAR2(5):= '/';
   v_ctl_file_path              VARCHAR2(1000):= '';

   v_task_pointer               NUMBER:= 0;

   v_debug                      boolean := FALSE;

  -- =========== Private Functions =============

   PROCEDURE LOG_MESSAGE( pBUFF  IN  VARCHAR2)
   IS
   BEGIN
     IF fnd_global.conc_request_id > 0  THEN
         FND_FILE.PUT_LINE( FND_FILE.LOG, pBUFF);
     ELSE
         null;
         --DBMS_OUTPUT.PUT_LINE( pBUFF);
     END IF;
   EXCEPTION
     WHEN OTHERS THEN
        RETURN;
   END LOG_MESSAGE;

-- =====Local Procedures =========

   PROCEDURE GET_FILE_NAMES(  pDataFileName   VARCHAR2, pCtlFileName VARCHAR2)
   IS
   lv_file_name_length            NUMBER:= 0;
   lv_bad_file_name               VARCHAR2(1000):= '';
   lv_dis_file_name               VARCHAR2(1000):= '';

   BEGIN
		v_ctl_file.EXTEND;
		v_dat_file.EXTEND;
		v_bad_file.EXTEND;
		v_dis_file.EXTEND;

            v_task_pointer:= v_task_pointer + 1;

        	lv_file_name_length:= instr(pDataFileName, '.', -1);

	  	IF lv_file_name_length = 0 then

	  		lv_bad_file_name:= pDataFileName ||'.bad';
	  		lv_dis_file_name:= pDataFileName ||'.dis';

	  	ELSE

	  		lv_bad_file_name:= substr(pDataFileName, 1, lv_file_name_length)||'bad';
	  		lv_dis_file_name:= substr(pDataFileName, 1, lv_file_name_length)||'dis';

	  	END IF;

	     	v_ctl_file(v_task_pointer):= v_ctl_file_path || pCtlFileName;
		v_dat_file(v_task_pointer):= v_dat_file_path || pDataFileName;
		v_bad_file(v_task_pointer):= v_dat_file_path || lv_bad_file_name;
		v_dis_file(v_task_pointer):= v_dat_file_path || lv_dis_file_name;

		IF v_debug THEN
			LOG_MESSAGE('v_ctl_file('||v_task_pointer||'): '||v_ctl_file(v_task_pointer));
			LOG_MESSAGE('v_dat_file('||v_task_pointer||'): '||v_dat_file(v_task_pointer));
			LOG_MESSAGE('v_bad_file('||v_task_pointer||'): '||v_bad_file(v_task_pointer));
			LOG_MESSAGE('v_dis_file('||v_task_pointer||'): '||v_dis_file(v_task_pointer));
		END IF;

   END GET_FILE_NAMES;

   FUNCTION is_request_status_running RETURN NUMBER
   IS
      l_call_status      boolean;
      l_phase            varchar2(80);
      l_status           varchar2(80);
      l_dev_phase        varchar2(80);
      l_dev_status       varchar2(80);
      l_message          varchar2(2048);

      l_request_id       NUMBER;

   BEGIN

	l_request_id:= FND_GLOBAL.CONC_REQUEST_ID;

      l_call_status:= FND_CONCURRENT.GET_REQUEST_STATUS
                              ( l_request_id,
                                NULL,
                                NULL,
                                l_phase,
                                l_status,
                                l_dev_phase,
                                l_dev_status,
                                l_message);

      IF l_call_status=FALSE THEN
         LOG_MESSAGE( l_message);
         RETURN SYS_NO;
      END IF;

      IF l_dev_phase='RUNNING' THEN
         RETURN SYS_YES;
      ELSE
         RETURN SYS_NO;
      END IF;

   END is_request_status_running;

   FUNCTION active_loaders RETURN NUMBER IS
      l_call_status      boolean;
      l_phase            varchar2(80);
      l_status           varchar2(80);
      l_dev_phase        varchar2(80);
      l_dev_status       varchar2(80);
      l_message          varchar2(2048);
      l_request_id       NUMBER;
	l_active_loaders	 NUMBER:= 0 ;

   BEGIN

      FOR lc_i IN 1..(v_request_id.COUNT) LOOP

          l_request_id:= v_request_id(lc_i);

          l_call_status:= FND_CONCURRENT.GET_REQUEST_STATUS
                              ( l_request_id,
                                NULL,
                                NULL,
                                l_phase,
                                l_status,
                                l_dev_phase,
                                l_dev_status,
                                l_message);

           IF l_call_status=FALSE THEN
              LOG_MESSAGE( l_message);
           END IF;

           IF l_dev_phase IN ( 'PENDING','RUNNING') THEN
              l_active_loaders:= l_active_loaders + 1;
           END IF;

       END LOOP;

       RETURN l_active_loaders;

   END active_loaders;

   FUNCTION LAUNCH_LOADER( ERRBUF                      OUT NOCOPY VARCHAR2,
	                     RETCODE	               OUT NOCOPY NUMBER)
   RETURN NUMBER IS

   lv_request_id		NUMBER;
   lv_parameters		VARCHAR2(2000):= '';

   BEGIN

        lv_request_id:=  FND_REQUEST.SUBMIT_REQUEST(
                             'MSC',
                             'MSCSLD', /* loader program called */
                             NULL,  -- description
                             NULL,  -- start date
                             FALSE, -- TRUE,
   				     v_ctl_file(v_task_pointer),
		                 v_dat_file(v_task_pointer),
				     v_dis_file(v_task_pointer),
				     v_bad_file(v_task_pointer),
				     null,
				     '10000000' ); -- NUM_OF_ERRORS
       COMMIT;

       IF lv_request_id = 0 THEN
          FND_MESSAGE.SET_NAME('MSC', 'MSC_PP_LAUNCH_LOADER_FAIL');
          ERRBUF:= FND_MESSAGE.GET;
          LOG_MESSAGE( ERRBUF);
          RETCODE:= G_ERROR;
	    RETURN -1;
       ELSE
         FND_MESSAGE.SET_NAME('MSC', 'MSC_PP_LOADER_REQUEST_ID');
         FND_MESSAGE.SET_TOKEN('REQUEST_ID', lv_request_id);
         LOG_MESSAGE(FND_MESSAGE.GET);
       END IF;

	RETURN lv_request_id;
   EXCEPTION
   WHEN OTHERS THEN
         LOG_MESSAGE( SQLERRM);
	   RETURN -1;
   END LAUNCH_LOADER;

-- ===============================================================

   PROCEDURE LAUNCH_MONITOR( ERRBUF          OUT NOCOPY VARCHAR2,
	         RETCODE                     OUT NOCOPY NUMBER,
	         p_timeout                   IN  NUMBER,
                 p_path_separator            IN  VARCHAR2 DEFAULT '/',
                 p_ctl_file_path             IN  VARCHAR2,
	         p_directory_path            IN  VARCHAR2,
	         p_total_worker_num          IN  NUMBER,
                 p_demand_class              IN  VARCHAR2 DEFAULT NULL,
	         p_bom_headers               IN  VARCHAR2 DEFAULT NULL,
	         p_bom_components            IN  VARCHAR2 DEFAULT NULL,
	         p_bom_comp_subs             IN  VARCHAR2 DEFAULT NULL,
	         p_items                     IN  VARCHAR2 DEFAULT NULL,
	         p_routing_headers           IN  VARCHAR2 DEFAULT NULL,
	         p_routing_ops               IN  VARCHAR2 DEFAULT NULL,
	         p_routing_op_resources      IN  VARCHAR2 DEFAULT NULL,
                 p_resource_groups           IN  VARCHAR2 DEFAULT NULL,
	         p_dept_resources            IN  VARCHAR2 DEFAULT NULL,
	         p_resource_changes          IN  VARCHAR2 DEFAULT NULL,
	         p_resource_shifts           IN  VARCHAR2 DEFAULT NULL,
	         p_project_tasks             IN  VARCHAR2 DEFAULT NULL,
	         p_uoms                      IN  VARCHAR2 DEFAULT NULL,
	         p_uom_class_convs           IN  VARCHAR2 DEFAULT NULL,
	         p_uom_convs                 IN  VARCHAR2 DEFAULT NULL,
	         p_category_sets             IN  VARCHAR2 DEFAULT NULL,
	         p_item_categories           IN  VARCHAR2 DEFAULT NULL,
	         p_item_sourcings            IN  VARCHAR2 DEFAULT NULL,
	         p_calendars                 IN  VARCHAR2 DEFAULT NULL,
	         p_workday_patterns          IN  VARCHAR2 DEFAULT NULL,
	         p_shift_times               IN  VARCHAR2 DEFAULT NULL,
	         p_calendar_exceptions       IN  VARCHAR2 DEFAULT NULL,
	         p_shift_exceptions          IN  VARCHAR2 DEFAULT NULL,
	         p_resource_requirements     IN  VARCHAR2 DEFAULT NULL,
	         p_item_suppliers            IN  VARCHAR2 DEFAULT NULL,
	         p_supplier_capacities       IN  VARCHAR2 DEFAULT NULL,
	         p_supplier_flexFences       IN  VARCHAR2 DEFAULT NULL,
                 p_safety_stocks             IN  VARCHAR2 DEFAULT NULL,
	         p_trading_partners          IN  VARCHAR2 DEFAULT NULL,
	         p_trading_partner_sites     IN  VARCHAR2 DEFAULT NULL,
	         p_loc_associations          IN  VARCHAR2 DEFAULT NULL,
	         p_sub_inventories           IN  VARCHAR2 DEFAULT NULL,
	         p_partner_contacts          IN  VARCHAR2 DEFAULT NULL,
                 p_ship_methods              IN  VARCHAR2 DEFAULT NULL,
	         p_supply_work_order         IN  VARCHAR2 DEFAULT NULL,
	         p_supply_requisitions       IN  VARCHAR2 DEFAULT NULL,
	         p_supply_onhand             IN  VARCHAR2 DEFAULT NULL,
	         p_supply_intransit          IN  VARCHAR2 DEFAULT NULL,
	         p_supply_PO                 IN  VARCHAR2 DEFAULT NULL,
	         p_planOrder_designators     IN  VARCHAR2 DEFAULT NULL,
	         p_supply_plan_orders        IN  VARCHAR2 DEFAULT NULL,
	         p_supply_ASN                IN  VARCHAR2 DEFAULT NULL,
	         p_demand_SO                 IN  VARCHAR2 DEFAULT NULL,
	         p_forecast_designators      IN  VARCHAR2 DEFAULT NULL,
	         p_demand_forecast           IN  VARCHAR2 DEFAULT NULL,
	         p_MDS_designators           IN  VARCHAR2 DEFAULT NULL,
	         p_demand_MDS                IN  VARCHAR2 DEFAULT NULL,
	         p_demand_WO_component       IN  VARCHAR2 DEFAULT NULL,
	   --    p_demand_flow_component     IN  VARCHAR2 DEFAULT NULL,
	         p_reservations              IN  VARCHAR2 DEFAULT NULL,
                 p_item_cst                  IN  VARCHAR2 DEFAULT NULL,
                 p_sce_supp_dem              IN  VARCHAR2 DEFAULT NULL,
                 p_sce_comp_users            IN  VARCHAR2 DEFAULT NULL,
                 p_item_substitute           IN  VARCHAR2 DEFAULT NULL,  -- Product Item Substitue
                 p_planners                  IN  VARCHAR2 DEFAULT NULL,  -- Planners
                 p_operation_networks        IN  VARCHAR2 DEFAULT NULL,  -- Operation Networks (OSFM)
                 p_co_products               IN  VARCHAR2 DEFAULT NULL,  -- Co Products (OSFM)
                 p_job_op_network            IN  VARCHAR2 DEFAULT NULL,  -- Lot based Job details (OSFM)
                 p_job_operations            IN  VARCHAR2 DEFAULT NULL,
                 p_job_req_ops               IN  VARCHAR2 DEFAULT NULL,
                 p_job_op_resources          IN  VARCHAR2 DEFAULT NULL,
                 p_profiles                  IN  VARCHAR2 DEFAULT NULL,  -- profiles
                 p_calendar_assignments      IN  VARCHAR2 DEFAULT NULL,  -- Calendar Assignment
                 p_regions                   IN  VARCHAR2 DEFAULT NULL,  -- Regions
                 p_zone_regions              IN  VARCHAR2 DEFAULT NULL,
                 p_region_locations          IN  VARCHAR2 DEFAULT NULL,
                 p_region_sites              IN  VARCHAR2 DEFAULT NULL,
                 p_iro_supplies              IN  VARCHAR2 DEFAULT NULL,
                 p_iro_demand                IN  VARCHAR2 DEFAULT NULL,
		 						 p_ero_supplies              IN  VARCHAR2 DEFAULT NULL,
		             p_ero_demand                IN  VARCHAR2 DEFAULT NULL,
		             p_sales_channel             IN  VARCHAR2 DEFAULT NULL,
                 p_fiscal_calendar           IN  VARCHAR2 DEFAULT NULL,
                 p_visits                    IN  VARCHAR2 DEFAULT NULL,
                 p_milestones                IN  VARCHAR2 DEFAULT NULL,
                 p_WBS                       IN  VARCHAR2 DEFAULT NULL,
                 p_WO_Attributes             IN  VARCHAR2 DEFAULT NULL,
                 p_WO_task_hierarchy         IN  VARCHAR2 DEFAULT NULL,
                 p_WO_operation_rel          IN  VARCHAR2 DEFAULT NULL) --- CMRO Proj bug 9135694

   IS

   lc_i                 PLS_INTEGER;
   lv_process_time      NUMBER:= 0;
   lv_check_point       NUMBER:= 0;
   lv_request_id        NUMBER:= -1;
   lv_start_time        DATE;

   lv_active_loaders    NUMBER:=0;

   EX_PROCESS_TIME_OUT EXCEPTION;

   BEGIN
-- ===== Switch on debug based on MRP: Debug Profile

        v_debug := FND_PROFILE.VALUE('MRP_DEBUG') = 'Y';

-- print the parameters coming in

   IF v_debug THEN
    LOG_MESSAGE('p_timeout: '||p_timeout);
    LOG_MESSAGE('p_path_separator: '||p_path_separator);
    LOG_MESSAGE('p_ctl_file_path: '||p_ctl_file_path);
    LOG_MESSAGE('p_directory_path: '||p_directory_path);
    LOG_MESSAGE('p_total_worker_num: '||p_total_worker_num);
    LOG_MESSAGE('p_demand_class: '||p_demand_class);
    LOG_MESSAGE('p_bom_headers: '||p_bom_headers);
    LOG_MESSAGE('p_bom_components: '||p_bom_components);
    LOG_MESSAGE('p_bom_comp_subs: '||p_bom_comp_subs);
    LOG_MESSAGE('p_items: '||p_items);
    LOG_MESSAGE('p_routing_headers: '||p_routing_headers);
    LOG_MESSAGE('p_routing_ops: '||p_routing_ops);
    LOG_MESSAGE('p_routing_op_resources: '||p_routing_op_resources);
    LOG_MESSAGE('p_resource_groups: '||p_resource_groups);
    LOG_MESSAGE('p_dept_resources: '||p_dept_resources);
    LOG_MESSAGE('p_resource_changes: '||p_resource_changes);
    LOG_MESSAGE('p_resource_shifts: '||p_resource_shifts);
    LOG_MESSAGE('p_project_tasks: '||p_project_tasks);
    LOG_MESSAGE('p_uoms: '||p_uoms);
    LOG_MESSAGE('p_uom_class_convs: '||p_uom_class_convs);
    LOG_MESSAGE('p_uom_convs: '||p_uom_convs);
    LOG_MESSAGE('p_category_sets: '||p_category_sets);
    LOG_MESSAGE('p_item_categories: '||p_item_categories);
    LOG_MESSAGE('p_item_sourcings: '||p_item_sourcings);
    LOG_MESSAGE('p_calendars: '||p_calendars);
    LOG_MESSAGE('p_workday_patterns: '||p_workday_patterns);
    LOG_MESSAGE('p_shift_times: '||p_shift_times);
    LOG_MESSAGE('p_calendar_exceptions: '||p_calendar_exceptions);
    LOG_MESSAGE('p_shift_exceptions: '||p_shift_exceptions);
    LOG_MESSAGE('p_resource_requirements: '||p_resource_requirements);
    LOG_MESSAGE('p_item_suppliers: '||p_item_suppliers);
    LOG_MESSAGE('p_supplier_capacities: '||p_supplier_capacities);
    LOG_MESSAGE('p_supplier_flexFences: '||p_supplier_flexFences);
    LOG_MESSAGE('p_safety_stocks: '||p_safety_stocks);
    LOG_MESSAGE('p_trading_partners: '||p_trading_partners);
    LOG_MESSAGE('p_trading_partner_sites: '||p_trading_partner_sites);
    LOG_MESSAGE('p_loc_associations: '||p_loc_associations);
    LOG_MESSAGE('p_sub_inventories: '||p_sub_inventories);
    LOG_MESSAGE('p_partner_contacts: '||p_partner_contacts);
    LOG_MESSAGE('p_ship_methods: '||p_ship_methods);
    LOG_MESSAGE('p_supply_work_order: '||p_supply_work_order);
    LOG_MESSAGE('p_supply_requisitions: '||p_supply_requisitions);
    LOG_MESSAGE('p_supply_onhand: '||p_supply_onhand);
    LOG_MESSAGE('p_supply_intransit: '||p_supply_intransit);
    LOG_MESSAGE('p_supply_PO: '||p_supply_PO);
    LOG_MESSAGE('p_planOrder_designators: '||p_planOrder_designators);
    LOG_MESSAGE('p_supply_plan_orders: '||p_supply_plan_orders);
    LOG_MESSAGE('p_supply_ASN: '||p_supply_ASN);
    LOG_MESSAGE('p_demand_SO: '||p_demand_SO);
    LOG_MESSAGE('p_forecast_designators: '||p_forecast_designators);
    LOG_MESSAGE('p_demand_forecast: '||p_demand_forecast);
    LOG_MESSAGE('p_MDS_designators: '||p_MDS_designators);
    LOG_MESSAGE('p_demand_MDS: '||p_demand_MDS);
    LOG_MESSAGE('p_demand_WO_component: '||p_demand_WO_component);
--  LOG_MESSAGE('p_demand_flow_component: '||p_demand_flow_component);
    LOG_MESSAGE('p_reservations: '||p_reservations);
    LOG_MESSAGE('p_item_cst: '||p_item_cst);
    LOG_MESSAGE('p_sce_supp_dem: '||p_sce_supp_dem);
    LOG_MESSAGE('p_item_substitute: '||p_item_substitute); -- Product Item Substitue
    LOG_MESSAGE('p_planners: '||p_planners); -- Planners
    LOG_MESSAGE('p_operation_networks: '||p_operation_networks); -- Operation Networks (OSFM)
    LOG_MESSAGE('p_co_products: '||p_co_products); -- Co Products (OSFM)
    LOG_MESSAGE('p_job_op_network: '||p_job_op_network);
    LOG_MESSAGE('p_job_operations: '||p_job_operations);
    LOG_MESSAGE('p_job_req_ops: '||p_job_req_ops);
    LOG_MESSAGE('p_job_op_resources: '||p_job_op_resources);
    LOG_MESSAGE('p_profiles: '|| p_profiles);
    LOG_MESSAGE('p_calendar_assignments: '||p_calendar_assignments); -- Calenadr Assignments
    LOG_MESSAGE('p_regions: ' || p_regions);
    LOG_MESSAGE('p_zone_regions: ' || p_zone_regions);
    LOG_MESSAGE('p_region_locations: ' || p_region_locations);
    LOG_MESSAGE('p_region_sites: ' ||    p_region_sites);
    LOG_MESSAGE('p_iro_supplies: ' || p_iro_supplies);
    LOG_MESSAGE('p_iro_demand: ' || p_iro_demand);
    LOG_MESSAGE('p_ero_supplies: ' || p_ero_supplies);
    LOG_MESSAGE('p_ero_demand: ' || p_ero_demand);
    LOG_MESSAGE('p_sales_channel: '||p_sales_channel);
    LOG_MESSAGE('p_fiscal_calendar: '||p_fiscal_calendar);
    LOG_MESSAGE('p_visits: '||p_visits); --- CMRO Proj bug 9135694
    LOG_MESSAGE('p_milestones: '||p_milestones); --- CMRO Proj bug 9135694
    LOG_MESSAGE('p_WBS: '||p_WBS); --- CMRO Proj bug 9135694
    LOG_MESSAGE('p_WO_Attributes: '||p_WO_Attributes); --- CMRO Proj bug 9135694
    LOG_MESSAGE('p_WO_task_hierarchy: '||p_WO_task_hierarchy);
    LOG_MESSAGE('p_WO_operation_rel: '||p_WO_operation_rel);


   END IF;

-- get the ctl file path. If last character is not path seperator add it

       v_path_seperator:= p_path_separator;

       v_ctl_file_path := p_ctl_file_path;

        IF v_ctl_file_path IS NOT NULL THEN
                IF SUBSTR(v_ctl_file_path,-1,1) = v_path_seperator then
                        v_ctl_file_path:= v_ctl_file_path;
                ELSE
                        v_ctl_file_path:= v_ctl_file_path || v_path_seperator;
                END IF;
        END IF;

-- ===== Assign the data file directory path to a global variable ===========

-- If last character is not path seperator, add it. User may specify the path in the
-- file name itself. Hence, if path is null, do not add seperator

	IF p_directory_path IS NOT NULL THEN
	  	IF SUBSTR(p_directory_path,-1,1) = v_path_seperator then
	      	v_dat_file_path:= p_directory_path;
	  	ELSE
			v_dat_file_path:= p_directory_path || v_path_seperator;
	  	END IF;
	END IF;

-- ===== create the Control, Data, Bad, Discard Files lists ==================
	IF p_demand_class IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_demand_class, pCtlFileName => 'MSC_ST_DEMAND_CLASSES.ctl');
	END IF;
	IF p_bom_headers IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_bom_headers, pCtlFileName => 'MSC_ST_BOMS.ctl');
	END IF;
	IF p_bom_components IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_bom_components, pCtlFileName => 'MSC_ST_BOM_COMPONENTS.ctl');
	END IF;
	IF p_bom_comp_subs IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_bom_comp_subs, pCtlFileName => 'MSC_ST_COMPONENT_SUBSTITUTES.ctl');
	END IF;
	IF p_items IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_items, pCtlFileName => 'MSC_ST_SYSTEM_ITEMS.ctl');
	END IF;
	IF p_routing_headers IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_routing_headers, pCtlFileName => 'MSC_ST_ROUTINGS.ctl');
	END IF;
	IF p_routing_ops IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_routing_ops, pCtlFileName => 'MSC_ST_ROUTING_OPERATIONS.ctl');
	END IF;
	IF p_routing_op_resources IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_routing_op_resources, pCtlFileName => 'MSC_ST_OPERATION_RESOURCES.ctl');
	END IF;
	IF p_resource_groups IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_resource_groups, pCtlFileName => 'MSC_ST_RESOURCE_GROUPS.ctl');
	END IF;
	IF p_dept_resources IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_dept_resources, pCtlFileName => 'MSC_ST_DEPARTMENT_RESOURCES.ctl');
	END IF;
	IF p_resource_changes IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_resource_changes, pCtlFileName => 'MSC_ST_RESOURCE_CHANGES.ctl');
	END IF;
	IF p_resource_shifts IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_resource_shifts, pCtlFileName => 'MSC_ST_RESOURCE_SHIFTS.ctl');
	END IF;
	IF p_project_tasks IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_project_tasks, pCtlFileName => 'MSC_ST_PROJECT_TASKS.ctl');
	END IF;
	IF p_uoms IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_uoms, pCtlFileName =>  'MSC_ST_UNITS_OF_MEASURE.ctl');
	END IF;
	IF p_uom_class_convs IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_uom_class_convs, pCtlFileName => 'MSC_ST_UOM_CLASS_CONVERSIONS.ctl');
	END IF;
	IF p_uom_convs IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_uom_convs, pCtlFileName => 'MSC_ST_UOM_CONVERSIONS.ctl');
	END IF;
	IF p_category_sets IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_category_sets, pCtlFileName => 'MSC_ST_CATEGORY_SETS.ctl');
	END IF;
	IF p_item_categories IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_item_categories, pCtlFileName => 'MSC_ST_ITEM_CATEGORIES.ctl');
	END IF;
	IF p_item_sourcings IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_item_sourcings, pCtlFileName => 'MSC_ST_ITEM_SOURCING.ctl');
	END IF;
	IF p_calendars IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_calendars, pCtlFileName => 'MSC_ST_CALENDARS.ctl');
	END IF;
	IF p_workday_patterns IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_workday_patterns, pCtlFileName => 'MSC_ST_WORKDAY_PATTERNS.ctl');
	END IF;
	IF p_shift_times IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_shift_times, pCtlFileName => 'MSC_ST_SHIFT_TIMES.ctl');
	END IF;
	IF p_calendar_exceptions IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_calendar_exceptions, pCtlFileName => 'MSC_ST_CALENDAR_EXCEPTIONS.ctl');
	END IF;
	IF p_shift_exceptions IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_shift_exceptions, pCtlFileName => 'MSC_ST_SHIFT_EXCEPTIONS.ctl');
	END IF;
	IF p_resource_requirements IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_resource_requirements, pCtlFileName => 'MSC_ST_RESOURCE_REQUIREMENTS.ctl');
	END IF;
	IF p_item_suppliers IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_item_suppliers, pCtlFileName => 'MSC_ST_ITEM_SUPPLIERS.ctl');
	END IF;
	IF p_supplier_capacities IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_supplier_capacities, pCtlFileName => 'MSC_ST_SUPPLIER_CAPACITIES.ctl');
	END IF;
	IF p_supplier_flexFences IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_supplier_flexFences, pCtlFileName => 'MSC_ST_SUPPLIER_FLEX_FENCES.ctl');
	END IF;
	IF p_safety_stocks IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_safety_stocks, pCtlFileName => 'MSC_ST_SAFETY_STOCKS.ctl');
	END IF;
	IF p_trading_partners IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_trading_partners, pCtlFileName => 'MSC_ST_TRADING_PARTNERS.ctl');
	END IF;
	IF p_trading_partner_sites IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_trading_partner_sites, pCtlFileName => 'MSC_ST_TRADING_PARTNER_SITES.ctl');
	END IF;
	IF p_loc_associations IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_loc_associations, pCtlFileName => 'MSC_ST_LOCATION_ASSOCIATIONS.ctl');
	END IF;
	IF p_sub_inventories IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_sub_inventories, pCtlFileName => 'MSC_ST_SUB_INVENTORIES.ctl');
	END IF;
	IF p_partner_contacts IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_partner_contacts, pCtlFileName => 'MSC_ST_PARTNER_CONTACTS.ctl');
	END IF;
      IF p_ship_methods IS NOT NULL THEN
                GET_FILE_NAMES( pDataFileName => p_ship_methods, pCtlFileName =>
 'MSC_ST_INTERORG_SHIP_METHODS.ctl');
        END IF;

	IF p_supply_work_order IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_supply_work_order, pCtlFileName => 'MSC_ST_SUPPLIES_WO.ctl');
	END IF;
	IF p_supply_requisitions IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_supply_requisitions, pCtlFileName =>  'MSC_ST_SUPPLIES_REQ.ctl');
	END IF;
	IF p_supply_onhand IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_supply_onhand, pCtlFileName => 'MSC_ST_SUPPLIES_ONHAND.ctl');
	END IF;
	IF p_supply_intransit IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_supply_intransit, pCtlFileName => 'MSC_ST_SUPPLIES_INTRANSIT.ctl');
	END IF;
	IF p_supply_PO IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_supply_PO, pCtlFileName => 'MSC_ST_SUPPLIES_PO.ctl');
	END IF;
	IF p_planOrder_designators IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_planOrder_designators, pCtlFileName =>'MSC_ST_DESIGNATORS_PLAN_ORDERS.ctl');
	END IF;
	IF p_supply_plan_orders IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_supply_plan_orders, pCtlFileName => 'MSC_ST_SUPPLIES_PLAN_ORDERS.ctl');
	END IF;
	IF p_supply_ASN IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_supply_ASN, pCtlFileName =>'MSC_ST_SUPPLIES_ASN.ctl'  );
	END IF;
	IF p_demand_SO IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_demand_SO, pCtlFileName => 'MSC_ST_SALES_ORDERS.ctl');
	END IF;
	IF p_forecast_designators IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_forecast_designators, pCtlFileName => 'MSC_ST_DESIGNATORS_FORECAST.ctl');
	END IF;
	IF p_demand_forecast IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_demand_forecast, pCtlFileName => 'MSC_ST_DEMANDS_FORECAST.ctl');
	END IF;
	IF p_MDS_designators IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_MDS_designators , pCtlFileName => 'MSC_ST_DESIGNATORS_MDS.ctl');
	END IF;
	IF p_demand_MDS IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_demand_MDS, pCtlFileName => 'MSC_ST_DEMANDS_MDS.ctl');
	END IF;
	IF p_demand_WO_component IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_demand_WO_component, pCtlFileName => 'MSC_ST_DEMANDS_WORK_ORDER.ctl');
	END IF;
/*	IF p_demand_flow_component IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_demand_flow_component, pCtlFileName => 'MSC_ST_DEMANDS_FLOW_SCHEDULE.ctl');
	END IF;*/
	IF p_reservations IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_reservations, pCtlFileName => 'MSC_ST_RESERVATIONS.ctl');
	END IF;
        IF p_item_cst IS NOT NULL THEN
                GET_FILE_NAMES( pDataFileName => p_item_cst, pCtlFileName => 'MSC_ST_ITEM_CUSTOMERS.ctl');
        END IF;
        IF p_sce_supp_dem IS NOT NULL THEN
                GET_FILE_NAMES( pDataFileName => p_sce_supp_dem, pCtlFileName => 'MSC_SUPDEM_LINES_INTERFACE.ctl');
        END IF;
        IF p_sce_comp_users IS NOT NULL THEN
                GET_FILE_NAMES( pDataFileName => p_sce_comp_users, pCtlFileName => 'MSC_ST_COMPANY_USERS.ctl');
        END IF;

      -- Product Substitution

        IF p_item_substitute IS NOT NULL THEN
                GET_FILE_NAMES( pDataFileName => p_item_substitute, pCtlFileName => 'MSC_ST_ITEM_SUBSTITUTES.ctl');
        END IF;

          -- Planners

        IF p_planners IS NOT NULL THEN
                GET_FILE_NAMES( pDataFileName => p_planners, pCtlFileName => 'MSC_ST_PLANNERS.ctl');
        END IF;
        -- Opeartion Networks (OSFM)
        IF p_operation_networks IS NOT NULL THEN
                GET_FILE_NAMES( pDataFileName => p_operation_networks, pCtlFileName => 'MSC_ST_OPERATION_NETWORKS.ctl');
        END IF;
        -- Co Products (OSFM)
        IF p_co_products IS NOT NULL THEN
                GET_FILE_NAMES( pDataFileName => p_co_products, pCtlFileName => 'MSC_ST_CO_PRODUCTS.ctl');
        END IF;

        -- Lot based Job details (OSFM)

        IF p_job_op_network IS NOT NULL THEN
                GET_FILE_NAMES( pDataFileName => p_job_op_network, pCtlFileName => 'MSC_ST_JOB_OPERATION_NETWORKS.ctl');
        END IF;

        IF p_job_operations IS NOT NULL THEN
                GET_FILE_NAMES( pDataFileName => p_job_operations, pCtlFileName => 'MSC_ST_JOB_OPERATIONS.ctl');
        END IF;

        IF p_job_req_ops IS NOT NULL THEN
                GET_FILE_NAMES( pDataFileName => p_job_req_ops, pCtlFileName => 'MSC_ST_JOB_REQUIREMENT_OPS.ctl');
        END IF;

        IF p_job_op_resources IS NOT NULL THEN
                GET_FILE_NAMES( pDataFileName => p_job_op_resources, pCtlFileName => 'MSC_ST_JOB_OP_RESOURCES.ctl');
        END IF;

        -- profiles

        IF p_profiles IS NOT NULL THEN
                GET_FILE_NAMES( pDataFileName => p_profiles, pCtlFileName => 'MSC_ST_APPS_INSTANCES.ctl');
        END IF;

         -- Calendar Assignments
        IF p_calendar_assignments IS NOT NULL THEN
                GET_FILE_NAMES( pDataFileName => p_calendar_assignments, pCtlFileName => 'MSC_ST_CALENDAR_ASSIGNMENTS.ctl');
        END IF;

        IF p_regions IS NOT NULL THEN
                GET_FILE_NAMES( pDataFileName => p_regions, pCtlFileName => 'MSC_ST_REGIONS.ctl');
        END IF;

        IF p_zone_regions IS NOT NULL THEN
                GET_FILE_NAMES( pDataFileName => p_zone_regions, pCtlFileName => 'MSC_ST_ZONE_REGIONS.ctl');
        END IF;

        IF p_region_locations IS NOT NULL THEN
                GET_FILE_NAMES( pDataFileName => p_region_locations, pCtlFileName => 'MSC_ST_REGION_LOCATIONS.ctl');
        END IF;

        IF p_region_sites IS NOT NULL THEN
                GET_FILE_NAMES( pDataFileName => p_region_sites, pCtlFileName => 'MSC_ST_REGION_SITES.ctl');
        END IF;

        IF p_iro_supplies IS NOT NULL THEN
                GET_FILE_NAMES( pDataFileName => p_iro_supplies, pCtlFileName => 'MSC_ST_SUPPLIES_IRO.ctl');
        END IF;

        IF p_iro_demand IS NOT NULL THEN
                GET_FILE_NAMES( pDataFileName => p_iro_demand, pCtlFileName => 'MSC_ST_DEMANDS_IRO_COMP.ctl');
        END IF;

        IF p_ero_supplies IS NOT NULL THEN
                GET_FILE_NAMES( pDataFileName => p_ero_supplies, pCtlFileName => 'MSC_ST_SUPPLIES_ERO.ctl');
        END IF;

        IF p_ero_demand IS NOT NULL THEN
                GET_FILE_NAMES( pDataFileName => p_ero_demand, pCtlFileName => 'MSC_ST_DEMANDS_ERO_COMP.ctl');
        END IF;

        IF p_sales_channel IS NOT NULL THEN
		            GET_FILE_NAMES( pDataFileName => p_sales_channel, pCtlFileName => 'MSC_ST_SALES_CHANNEL.ctl');
	      END IF;

        IF p_fiscal_calendar IS NOT NULL THEN
		            GET_FILE_NAMES( pDataFileName => p_fiscal_calendar, pCtlFileName => 'MSC_ST_CALENDAR_MONTHS.ctl');
	      END IF;
	      --- CMRO Proj bug 9135694
        IF p_visits IS NOT NULL THEN
		            GET_FILE_NAMES( pDataFileName => p_visits, pCtlFileName => 'MSC_ST_VISITS.ctl');
	      END IF;

        IF p_milestones IS NOT NULL THEN
		            GET_FILE_NAMES( pDataFileName => p_milestones, pCtlFileName => 'MSC_ST_WO_MILESTONES.ctl');
	      END IF;

        IF p_WBS IS NOT NULL THEN
		            GET_FILE_NAMES( pDataFileName => p_WBS, pCtlFileName => 'MSC_ST_WORK_BREAKDOWN_STRUCT.ctl');
	      END IF;

        IF p_WO_Attributes IS NOT NULL THEN
		            GET_FILE_NAMES( pDataFileName => p_WO_Attributes, pCtlFileName => 'MSC_ST_WO_ATTRIBUTES.ctl');
	      END IF;

        IF p_WO_task_hierarchy IS NOT NULL THEN
		            GET_FILE_NAMES( pDataFileName => p_WO_task_hierarchy, pCtlFileName => 'MSC_ST_WO_TASK_HIERARCHY.ctl');
	      END IF;

        IF p_WO_operation_rel IS NOT NULL THEN
		            GET_FILE_NAMES( pDataFileName => p_WO_operation_rel, pCtlFileName => 'MSC_ST_WO_OPERATION_REL.ctl');
	      END IF;

      v_request_id.EXTEND(v_task_pointer);

      v_task_pointer:= 0;





  -- ============ Lauch the Loaders here ===============

     LOOP

	IF active_loaders < p_total_worker_num THEN

            EXIT WHEN is_request_status_running <> SYS_YES;

		IF v_task_pointer < (v_ctl_file.LAST - 1)  THEN

		   v_task_pointer:= v_task_pointer + 1;

		   lv_request_id:= LAUNCH_LOADER (ERRBUF        => ERRBUF,
					       RETCODE       => RETCODE);

		   IF lv_request_id <> -1 THEN
			v_request_id(v_task_pointer):= lv_request_id;
		   END IF;

                ELSIF active_loaders = 0 THEN

                   EXIT;

               ELSE

                  select (SYSDATE- START_TIME) into lv_process_time from dual;

                  IF lv_process_time > p_timeout/1440.0 THEN Raise EX_PROCESS_TIME_OUT;  END IF;

                      DBMS_LOCK.SLEEP( 5);

                  END IF;

	ELSE
   -- ============= Check the execution time ==============

         select (SYSDATE- START_TIME) into lv_process_time from dual;

         IF lv_process_time > p_timeout/1440.0 THEN Raise EX_PROCESS_TIME_OUT;  END IF;

         DBMS_LOCK.SLEEP( 5);

	END IF;

      END LOOP;

     lv_check_point:= 3;

     IF RETCODE= G_ERROR THEN RETURN; END IF;

   EXCEPTION

      WHEN EX_PROCESS_TIME_OUT THEN

         ROLLBACK;

         FND_MESSAGE.SET_NAME('MSC', 'MSC_TIMEOUT');
         ERRBUF:= FND_MESSAGE.GET;
         RETCODE:= G_ERROR;
         LOG_MESSAGE( ERRBUF);

      WHEN others THEN

         ROLLBACK;

         ERRBUF := SQLERRM;
         RETCODE:= G_ERROR;
         LOG_MESSAGE( ERRBUF);

   END LAUNCH_MONITOR;

END MSC_CL_LOADERS;

/
