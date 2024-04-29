--------------------------------------------------------
--  DDL for Package MSC_CL_PRE_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_CL_PRE_PROCESS" AUTHID CURRENT_USER AS
/* $Header: MSCCLPPS.pls 120.5.12010000.4 2010/03/19 12:59:28 vsiyer ship $ */

  ----- ARRAY DATA TYPE --------------------------------------------------

   TYPE NumTblTyp IS TABLE OF NUMBER;

   SYS_YES                                 CONSTANT NUMBER := 1;
   SYS_NO                                  CONSTANT NUMBER := 2;

  ----- GLobal Variable -------------------------------------------------
  v_batch_size        NUMBER ;
  v_debug             BOOLEAN;
  v_current_date      DATE ;
  v_current_user      NUMBER ;
  v_flag              NUMBER := SYS_NO;
  v_instance_code     VARCHAR2(3);
  v_refresh_id        NUMBER;
  v_instance_id       NUMBER;
  v_sql_stmt          VARCHAR2(4000);
  v_instance_type             	NUMBER;


  ----- CONSTANTS --------------------------------------------------------


   G_CONC_ERROR                            CONSTANT NUMBER := 3;
   G_SUCCESS                               CONSTANT NUMBER := 0;
   G_WARNING                               CONSTANT NUMBER := 1;
   G_ERROR                                 CONSTANT NUMBER := 2;
   G_SCE                                   CONSTANT NUMBER := 5;

   G_COLLECTION_PROGRAM                    CONSTANT NUMBER := 1;
   G_PULL_PROGRAM                          CONSTANT NUMBER := 2;

   G_APPS107                               CONSTANT NUMBER := 1;
   G_APPS110                               CONSTANT NUMBER := 2;
   G_APPS115                               CONSTANT NUMBER := 3;

   G_INS_DISCRETE                          CONSTANT NUMBER := 1;
   G_INS_PROCESS                           CONSTANT NUMBER := 2;
   G_INS_OTHER                             CONSTANT NUMBER := 3;
   G_INS_MIXED                             CONSTANT NUMBER := 4;

   G_ST_EMPTY                              CONSTANT NUMBER := 0;   -- no instance data exists;
   G_ST_PULLING                            CONSTANT NUMBER := 1;
   G_ST_READY                              CONSTANT NUMBER := 2;
   G_ST_COLLECTING                         CONSTANT NUMBER := 3;
   G_ST_PURGING                            CONSTANT NUMBER := 4;
   G_ST_PRE_PROCESSING                     CONSTANT NUMBER := 5;


   G_MFG_CAL                               CONSTANT NUMBER := 2;
   G_FISCAL_CAL                            CONSTANT NUMBER := 3;
   G_COMPOSITE_CAL                         CONSTANT NUMBER := 4;


   -- Calling Module
   G_APS                                   CONSTANT NUMBER := 1;
   G_DP                                    CONSTANT NUMBER := 2;


   -- NULL VALUE USED IN THE WHERE CLAUSE

   NULL_DATE                               CONSTANT DATE        :=   SYSDATE-36500;
   NULL_VALUE                              CONSTANT NUMBER      := -23453;   -- null value for positive number
   NULL_CHAR                               CONSTANT VARCHAR2(6) := '-23453';
   HOLD_DATE                               CONSTANT DATE       := SYSDATE +365000 ;

   -- ============ Task Control ================

   PIPE_TIME_OUT                           CONSTANT NUMBER := 30;      -- 30 secs
   START_TIME                              DATE;

   -- ================== Worker Status ===================

   OK                                      CONSTANT NUMBER := 1;
   FAIL                                    CONSTANT NUMBER := 0;

   -- ================== Process Flag ===================
   G_NEW                                   CONSTANT NUMBER := 1;
   G_IN_PROCESS                            CONSTANT NUMBER := 2;
   G_ERROR_FLG                             CONSTANT NUMBER := 3;
   G_PROPAGATION                           CONSTANT NUMBER := 4;
   G_VALID                                 CONSTANT NUMBER := 5;

   -- ================== Error Types ===================
   G_SEV_ERROR                             CONSTANT NUMBER := 1;
   G_SEV_WARNING                           CONSTANT NUMBER := 2;
   G_SEV3_ERROR                            CONSTANT NUMBER := 3;

   --  ================= Task Number ====================

   TASK_ITEM                               CONSTANT NUMBER :=  1;
   TASK_SUPPLIER_CAPACITY                  CONSTANT NUMBER :=  2;
   TASK_CATEGORIES_SOURCING                CONSTANT NUMBER :=  3;
   TASK_DEPT_RESOURCES                     CONSTANT NUMBER :=  4;
   TASK_MATERIAL_SUPPLY	                   CONSTANT NUMBER :=  5;
   TASK_MATERIAL_DEMAND                    CONSTANT NUMBER :=  6;
   TASK_SO_DEMAND                          CONSTANT NUMBER :=  7;
   TASK_BOM_ROUTING                        CONSTANT NUMBER :=  8;
   TASK_RESOURCE_DEMAND                    CONSTANT NUMBER :=  9;
   TASK_BIS_PERIODS                        CONSTANT NUMBER :=  10;
   TASK_UOM_CONV                           CONSTANT NUMBER :=  11;
   TASK_SAFETY_STOCK                       CONSTANT NUMBER :=  12;
   TASK_RESERVATION                        CONSTANT NUMBER :=  13;
   TASK_ITEM_CST                           CONSTANT NUMBER :=  14;
   TASK_ITEM_SUBSTITUTE                    CONSTANT NUMBER :=  15;  -- Product Item Substitute
   TASK_CAL_ASSIGNMENTS                    CONSTANT NUMBER :=  16;
   TASK_IRO                                CONSTANT NUMBER :=  17;
   TASK_ERO                                CONSTANT NUMBER :=  18;
   TASK_SALES_CHANNEL                      CONSTANT NUMBER :=  19;
   TASK_FISCAL_CALENDAR                    CONSTANT NUMBER :=  33;
   TASK_CMRO                               CONSTANT NUMBER :=  34;   --- CMRO Proj bug 9135694

   ---- =============Task Number for DP entities ===========
   TASK_LEVEL_VALUE                        CONSTANT NUMBER := 20 ;
   TASK_LEVEL_ASSOCIATION                  CONSTANT NUMBER := 21 ;
   TASK_BOOKING_DATA                       CONSTANT NUMBER := 22 ;
   TASK_SHIPMENT_DATA                      CONSTANT NUMBER := 23 ;
   TASK_MFG_FORECAST                       CONSTANT NUMBER := 24 ;
   TASK_PRICE_LIST                         CONSTANT NUMBER := 25 ;
   TASK_ITEM_LIST_PRICE                    CONSTANT NUMBER := 26 ;
   TASK_CS_DATA                            CONSTANT NUMBER := 27 ;
   TASK_CURR_CONV                          CONSTANT NUMBER := 28 ;
   TASK_DP_UOM_CONV                        CONSTANT NUMBER := 29 ;
   TASK_FISCAL_TIME                        CONSTANT NUMBER := 30 ;
   TASK_COMPANY_USERS                      CONSTANT NUMBER := 31 ;
   TASK_COMPOSITE_TIME                     CONSTANT NUMBER := 32 ;


   TASK_ALL_COMPLETED                      CONSTANT NUMBER := 99; -- to communicate the completion of all tasks

   UNRESOVLABLE_ERROR                      CONSTANT NUMBER := -9999999;

   -- ==================ITEM DEFAULTS =====================

   G_LOT_CONTROL_CODE              CONSTANT NUMBER := 2; --No
   G_ROUNDING_CONTROL_TYPE         CONSTANT NUMBER := 2; --No
   G_IN_SOURCE_PLAN                CONSTANT NUMBER := 2; --No
   G_MRP_PLANNING_CODE             CONSTANT NUMBER := 7; --MRP and DRP planned
   G_MRP_CALCULATE_ATP_FLAG        CONSTANT NUMBER := 2; --No
   G_BUILT_IN_WIP_FLAG             CONSTANT NUMBER := 1; --Yes
   G_PURCHASING_ENABLED_FLAG       CONSTANT NUMBER := 2; --No
   G_PLANNING_MAKE_BUY_CODE        CONSTANT NUMBER := 1; --Yes
   G_INVENTORY_PLANNING_CODE       CONSTANT NUMBER := 6;
   G_REPETITIVE_TYPE               CONSTANT NUMBER := 1; --Discrete bug#2399135
   G_ENGINEERING_ITEM_FLAG         CONSTANT NUMBER := 2; --No
   G_WIP_SUPPLY_TYPE               CONSTANT NUMBER := 1; --Push
   G_BOM_ITEM_TYPE                 CONSTANT NUMBER := 4; --Standard BOM
   G_ATO_FORECAST_CONTROL          CONSTANT NUMBER := 2; --No
   G_INVENTORY_ITEM_FLAG           CONSTANT NUMBER := 1; --Yes
   G_INVENTORY_TYPE                CONSTANT NUMBER := 1;
   G_SERIAL_NUMBER_CONTROL_CODE    CONSTANT NUMBER := 2; -- SERIAL_NUMBER_FLAG set to NO
   G_DRP_PLANNED                   CONSTANT NUMBER := 2; --No


   G_END_ASSEMBLY_PEGGING_FLAG     CONSTANT  VARCHAR2(1)  := 'N';
   G_ATP_COMPONENTS_FLAG           CONSTANT  VARCHAR2(1)  := 'N';--No
   G_ATP_FLAG                      CONSTANT  VARCHAR2(1)  := 'N';--No
   G_INVENTORY_ASSET_FLAG          CONSTANT  VARCHAR2(1)  := 'Y';

  -- ==================BOM DEFAULTS =====================

   G_ASSEMBLY_TYPE                 CONSTANT NUMBER:= 1 ;--Manufacturing Bill
   G_BOM_SCALING_TYPE              CONSTANT NUMBER:= NULL;
   G_ATP_FLAG_BOM                  CONSTANT NUMBER:= 1;
   G_ASSEMBLY_QUANTITY             CONSTANT NUMBER:= 1 ;
   G_USAGE_QUANTITY                CONSTANT NUMBER:= 1 ;
   G_COMPONENT_YEILD_FACTOR        CONSTANT NUMBER:= 1 ;
   G_USE_UP_CODE                   CONSTANT NUMBER:= NULL ;
   G_OPTIONAL_COMPONENT            CONSTANT NUMBER:= NULL ;
   G_COMPONENT_TYPE                CONSTANT NUMBER:= 1 ;
   G_OPERATION_SEQ_CODE            CONSTANT VARCHAR2(10) := '1' ;
   G_EFFECTIVITY_DATE              DATE := SYSDATE;
   G_PRIORITY                      CONSTANT NUMBER := 0;


   -- ==================DEPT/RESOURCE DEFAULTS =====================

   G_LINE_FLAG                     CONSTANT  VARCHAR2(1) := '2';
   G_AVAILABLE_24_HOURS_FLAG       CONSTANT NUMBER := 1;
   G_CTP_FLAG                      CONSTANT NUMBER := 2;
   G_RESOURCE_TYPE                 CONSTANT NUMBER := 1;--Machine
   G_RESOURCE_INCLUDE_FLAG         CONSTANT NUMBER := 1;
   G_AGGREGATED_RESOURCE_FLAG      CONSTANT NUMBER := 2;

  -- ==================PROJECT/TASK DEFAULTS =====================

   G_SEIBAN_NUMBER_FLAG            CONSTANT NUMBER := 2;

  -- ==================ROUTING DEFAULTS =====================

   G_ROUTING_TYPE                  CONSTANT  NUMBER := 1; --Mfg Routing
   G_OPTION_DEPENDENT_FLAG         CONSTANT  NUMBER := 1; --No
   G_BASIS_TYPE                    CONSTANT  NUMBER := 1;
   G_PRINCIPAL_FLAG                CONSTANT  NUMBER := 1;
   G_CFM_ROUTING_FLAG              CONSTANT  NUMBER := 2;
   G_RESOURCE_SEQ_CODE             CONSTANT  VARCHAR2(10):= '1';
   G_ALTERNATE_NUMBER              CONSTANT  NUMBER := 0;
   G_TRANSITION_TYPE               CONSTANT  NUMBER := 2; -- Added for OSFM Integration
  -- ================== DEFAULT for SALES ORDER =====================
   G_RESERVATION_TYPE              CONSTANT NUMBER := 1;
   G_SO_DEMAND_SOURCE_TYPE         CONSTANT NUMBER := 8;
   G_COMPLETED_QUANTITY            CONSTANT NUMBER := 0;
   G_CTO_FLAG                      CONSTANT NUMBER := 2;
   G_AVAILABLE_TO_MRP              CONSTANT VARCHAR2(1):= 'Y';
   G_FORECAST_VISIBLE              CONSTANT VARCHAR2(1):= 'Y';
   G_DEMAND_VISIBLE                CONSTANT VARCHAR2(1):= 'Y';


   -- ================== DEFAULT for DEMAND =====================

   G_DEMAND_TYPE                   CONSTANT NUMBER := 1;--Non repetitive for WIP comp demand
   G_WIP_STATUS_CODE               CONSTANT NUMBER := 1;--Unreleased
   G_BUCKET_TYPE                   CONSTANT NUMBER := 1;--Days
   G_DISPOSITION_TYPE              CONSTANT NUMBER := 1;


   -- ================== MISCELLANEOUS =====================

   G_NEW_REQUEST                   CONSTANT NUMBER := 0;--new request
   G_CAL_REQ_DATA                  CONSTANT NUMBER := 1;--Calendar sub-request
   G_DP_LV_REQ_DATA                CONSTANT NUMBER := 2;--DP Level Values sub-request
   G_DP_CS_REQ_DATA                CONSTANT NUMBER := 3;--DP custom stream sub-request
   G_ODS_REQ_DATA                  CONSTANT NUMBER := 4;--ODS Load sub-request
   G_DP_BOM_DATA                   CONSTANT NUMBER := 5;--DP BOM collection sub-request


   G_COMPANY_ID                    CONSTANT NUMBER := -1;
   G_USING_ORG_ID                  CONSTANT NUMBER := -1;
   G_CAL_EXCEP_SET_ID              CONSTANT NUMBER := -1;
   G_FOR_INV_ATP_FLAG              CONSTANT NUMBER :=  0;
   G_FOR_MPS_RELIEF                CONSTANT NUMBER :=  0;
   G_INV_ATP_FLAG                  CONSTANT NUMBER :=  2;
   G_MPS_RELIEF                    CONSTANT NUMBER :=  2;
   G_CONSUME_FORECAST              CONSTANT NUMBER :=  2;
   G_UPDATE_TYPE                   CONSTANT NUMBER :=  6;
   G_VENDOR                        CONSTANT NUMBER :=  1;
   G_CUSTOMER                      CONSTANT NUMBER :=  2;
   G_ORGANIZATION                  CONSTANT NUMBER :=  3;
   G_CARRIER                       CONSTANT NUMBER :=  4;
   G_FORECAST_DESIGNATOR           CONSTANT NUMBER :=  6;
   G_RELATIONSHIP_TYPE             CONSTANT NUMBER :=  2;  -- Product Item Substitute
   G_NO_PLAN_PERCENTAGE            CONSTANT NUMBER :=  1; -- Profile option choice 1 for profile MSD_PLANNING_PERCENTAGE.
   G_EXCLUDE_OPTION_CLASS          CONSTANT NUMBER :=  3; -- Profile option choice 3 for profile MSD_PLANNING_PERCENTAGE.

   -- ================ COMPANY USER ====================
   G_COMP_USR_YES                  CONSTANT NUMBER := 2;
   G_COMP_USR_NO                   CONSTANT NUMBER := 1;

   --  ================= Procedures ====================

   PROCEDURE LAUNCH_MONITOR( ERRBUF                OUT NOCOPY VARCHAR2,
                             RETCODE               OUT NOCOPY NUMBER,
                             p_instance_id         IN  NUMBER,
                             p_timeout             IN  NUMBER DEFAULT 60,
                             p_batch_size          IN  NUMBER DEFAULT 1000,
                             p_total_worker_num    IN  NUMBER DEFAULT 3,
                             p_cal_enabled         IN  NUMBER DEFAULT SYS_NO,
                             p_dmd_class_enabled   IN  NUMBER DEFAULT SYS_NO,
                             p_tp_enabled          IN  NUMBER DEFAULT SYS_NO,
                             p_ctg_enabled         IN  NUMBER DEFAULT SYS_NO,
                             p_item_cat_enabled    IN  NUMBER DEFAULT SYS_NO,
                             p_uom_enabled         IN  NUMBER DEFAULT SYS_NO,
                             p_uom_class_enabled   IN  NUMBER DEFAULT SYS_NO,
                             p_desig_enabled       IN  NUMBER DEFAULT SYS_NO,
                             p_project_enabled     IN  NUMBER DEFAULT SYS_NO,
                             p_item_enabled        IN  NUMBER DEFAULT SYS_NO,
                             p_sup_cap_enabled     IN  NUMBER DEFAULT SYS_NO,
                             p_safety_stk_enabled  IN  NUMBER DEFAULT SYS_NO,
                             p_ship_mthd_enabled   IN  NUMBER DEFAULT SYS_NO,
                             p_sourcing_enabled    IN  NUMBER DEFAULT SYS_NO,
                             p_bom_enabled         IN  NUMBER DEFAULT SYS_NO,
                             p_rtg_enabled         IN  NUMBER DEFAULT SYS_NO,
                             p_resources_enabled   IN  NUMBER DEFAULT SYS_NO,
                             p_mat_sup_enabled     IN  NUMBER DEFAULT SYS_NO,
                             p_mat_dmd_enabled     IN  NUMBER DEFAULT SYS_NO,
                             p_reserve_enabled     IN  NUMBER DEFAULT SYS_NO,
                             p_res_dmd_enabled     IN  NUMBER DEFAULT SYS_NO,
                             p_item_cst_enabled    IN  NUMBER DEFAULT SYS_NO,
                             p_parent_request_id   IN  NUMBER DEFAULT -1,
                             p_fiscal_cal_enabled  IN  NUMBER DEFAULT SYS_NO,
                             p_setup_enabled       IN  NUMBER DEFAULT SYS_NO,
                             p_link_dummy          IN  VARCHAR2 DEFAULT NULL,
                             p_item_rollup         IN  NUMBER DEFAULT SYS_YES,
                             p_level_value_enabled IN  NUMBER DEFAULT SYS_NO,
                             p_level_assoc_enabled IN  NUMBER DEFAULT SYS_NO,
                             p_booking_enabled     IN  NUMBER DEFAULT SYS_NO,
                             p_shipment_enabled    IN  NUMBER DEFAULT SYS_NO,
                             p_mfg_fct_enabled     IN  NUMBER DEFAULT SYS_NO,
                             p_list_price_enabled  IN  NUMBER DEFAULT SYS_NO,
                             p_cs_data_enabled     IN  NUMBER DEFAULT SYS_NO,
                             p_cs_dummy            IN  VARCHAR2 DEFAULT NULL,
                             p_cs_refresh          IN  NUMBER DEFAULT SYS_NO,
                             p_curr_conv_enabled   IN  NUMBER DEFAULT SYS_NO,
                             p_uom_conv_enabled    IN  NUMBER DEFAULT SYS_NO,
                             p_calling_module      IN  NUMBER DEFAULT G_APS,
                             p_comp_users_enabled  IN  NUMBER DEFAULT SYS_NO,
                             p_item_substitute_enabled IN  NUMBER DEFAULT SYS_NO,
                             p_planners_enabled    IN  NUMBER DEFAULT SYS_NO,
                             p_comp_cal_enabled    IN  NUMBER DEFAULT SYS_NO,
                             p_profile_enabled     IN  NUMBER DEFAULT SYS_NO,
			    									 p_cal_assignment_enabled  IN  NUMBER DEFAULT SYS_NO,
                             p_iro_enabled         IN  NUMBER DEFAULT SYS_NO,
                             p_ero_enabled         IN  NUMBER DEFAULT SYS_NO,
                             p_sales_channel_enabled IN NUMBER DEFAULT SYS_NO,  -- added for bug # 7704614
                             p_fiscal_calendar_enabled IN NUMBER DEFAULT SYS_NO,
                             p_CMRO_enabled  IN NUMBER DEFAULT SYS_NO); --- CMRO Proj bug 9135694




   PROCEDURE LAUNCH_WORKER(  ERRBUF                OUT NOCOPY VARCHAR2,
                             RETCODE               OUT NOCOPY NUMBER,
                             p_monitor_request_id  IN  NUMBER,
                             p_instance_id         IN  NUMBER,
                             p_lcid                IN  NUMBER,
                             p_timeout             IN  NUMBER,
                             p_batch_size          IN  NUMBER DEFAULT 1000,
                             p_uom_class_enabled   IN  NUMBER DEFAULT SYS_NO,
                             p_item_cat_enabled    IN  NUMBER DEFAULT SYS_NO,
                             p_item_enabled        IN  NUMBER DEFAULT SYS_NO,
                             p_sup_cap_enabled     IN  NUMBER DEFAULT SYS_NO,
                             p_safety_stk_enabled  IN  NUMBER DEFAULT SYS_NO,
                             p_ship_mthd_enabled   IN  NUMBER DEFAULT SYS_NO,
                             p_sourcing_enabled    IN  NUMBER DEFAULT SYS_NO,
                             p_bom_enabled         IN  NUMBER DEFAULT SYS_NO,
                             p_rtg_enabled         IN  NUMBER DEFAULT SYS_NO,
                             p_resources_enabled   IN  NUMBER DEFAULT SYS_NO,
                             p_mat_sup_enabled     IN  NUMBER DEFAULT SYS_NO,
                             p_mat_dmd_enabled     IN  NUMBER DEFAULT SYS_NO,
                             p_reserve_enabled     IN  NUMBER DEFAULT SYS_NO,
                             p_res_dmd_enabled     IN  NUMBER DEFAULT SYS_NO,
                             p_item_cst_enabled    IN  NUMBER DEFAULT SYS_NO,
                             p_fiscal_cal_enabled  IN  NUMBER DEFAULT SYS_NO,
                             p_comp_cal_enabled    IN  NUMBER DEFAULT SYS_NO,
                             p_setup_enabled       IN  NUMBER DEFAULT SYS_NO,
                             p_item_rollup         IN  NUMBER DEFAULT SYS_YES,
                             p_level_value_enabled IN  NUMBER DEFAULT SYS_NO,
                             p_level_assoc_enabled IN  NUMBER DEFAULT SYS_NO,
                             p_booking_enabled     IN  NUMBER DEFAULT SYS_NO,
                             p_shipment_enabled    IN  NUMBER DEFAULT SYS_NO,
                             p_mfg_fct_enabled     IN  NUMBER DEFAULT SYS_NO,
                             p_list_price_enabled  IN  NUMBER DEFAULT SYS_NO,
                             p_cs_data_enabled     IN  NUMBER DEFAULT SYS_NO,
                             p_curr_conv_enabled   IN  NUMBER DEFAULT SYS_NO,
                             p_uom_conv_enabled    IN  NUMBER DEFAULT SYS_NO,
                             p_comp_users_enabled  IN  NUMBER DEFAULT SYS_NO,
                             p_item_substitute_enabled IN  NUMBER DEFAULT SYS_NO,
			                       p_cal_assignment_enabled  IN  NUMBER DEFAULT SYS_NO,
			                       p_iro_enabled          IN  NUMBER DEFAULT SYS_NO,
			                       p_ero_enabled          IN  NUMBER DEFAULT SYS_NO,
			                       p_sales_channel_enabled IN NUMBER DEFAULT SYS_NO,  -- added for bug # 7704614
                             p_fiscal_calendar_enabled IN NUMBER DEFAULT SYS_NO,
                             p_CMRO_enabled  IN NUMBER DEFAULT SYS_NO, --- CMRO Proj bug 9135694
                             p_request_id          IN  NUMBER DEFAULT -1);


END MSC_CL_PRE_PROCESS;

/
