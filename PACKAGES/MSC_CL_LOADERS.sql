--------------------------------------------------------
--  DDL for Package MSC_CL_LOADERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_CL_LOADERS" AUTHID CURRENT_USER AS
/* $Header: MSCCLLDS.pls 120.4.12010000.3 2010/03/19 12:57:17 vsiyer ship $ */

  ----- ARRAY DATA TYPE --------------------------------------------------

   TYPE NumTblTyp IS TABLE OF NUMBER;
   TYPE VarcharTblTyp IS TABLE OF VARCHAR2(1000);

  ----- CONSTANTS --------------------------------------------------------

   SYS_YES                      CONSTANT NUMBER := 1;
   SYS_NO                       CONSTANT NUMBER := 2;

   G_SUCCESS                    CONSTANT NUMBER := 0;
   G_WARNING                    CONSTANT NUMBER := 1;
   G_ERROR                      CONSTANT NUMBER := 2;

   -- NULL VALUE USED IN THE WHERE CLAUSE

   NULL_DATE             CONSTANT DATE:=   SYSDATE-36500;
   NULL_VALUE            CONSTANT NUMBER:= -23453;   -- null value for positive number
   NULL_CHAR             CONSTANT VARCHAR2(6):= '-23453';

   -- ============ Task Control ================

   PIPE_TIME_OUT         CONSTANT NUMBER := 30;      -- 30 secs
   START_TIME            DATE;



   -- ================== Worker Status ===================

    OK                    		CONSTANT NUMBER := 1;
    FAIL                  		CONSTANT NUMBER := 0;

   --  ================= Procedures ====================
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
	      -- p_demand_flow_component     IN  VARCHAR2 DEFAULT NULL,
	         p_reservations              IN  VARCHAR2 DEFAULT NULL,
                 p_item_cst                  IN  VARCHAR2 DEFAULT NULL,
                 p_sce_supp_dem              IN  VARCHAR2 DEFAULT NULL,
                 p_sce_comp_users            IN  VARCHAR2 DEFAULT NULL,
                 p_item_substitute           IN  VARCHAR2 DEFAULT NULL, -- Product Item Substitue
                 p_planners                  IN  VARCHAR2 DEFAULT NULL,
                 p_operation_networks        IN  VARCHAR2 DEFAULT NULL,-- Operation Networks (OSFM)
                 p_co_products               IN  VARCHAR2 DEFAULT NULL,-- Co Products (OSFM)
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
                 p_WO_operation_rel          IN  VARCHAR2 DEFAULT NULL); --- CMRO Proj bug 9135694



END MSC_CL_LOADERS;

/
