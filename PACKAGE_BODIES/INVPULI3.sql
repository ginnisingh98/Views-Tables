--------------------------------------------------------
--  DDL for Package Body INVPULI3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INVPULI3" as
/* $Header: INVPUL3B.pls 120.5 2007/04/09 13:26:54 anmurali ship $ */

/* Used from R12 - FPC - Anmurali */

FUNCTION copy_item_attributes( org_id         IN            NUMBER
                              ,all_org        IN            NUMBER  := 2
                              ,prog_appid     IN            NUMBER  := -1
                              ,prog_id        IN            NUMBER  := -1
                              ,request_id     IN            NUMBER  := -1
                              ,user_id        IN            NUMBER  := -1
                              ,login_id       IN            NUMBER  := -1
                              ,xset_id        IN            NUMBER  := -999
                              ,err_text       IN OUT NOCOPY VARCHAR2 )
RETURN INTEGER IS

   CURSOR c_check_item_phase_status(cp_phase_id    NUMBER
                                   ,cp_status_code VARCHAR2)
   IS
      SELECT 'Y' FROM DUAL
      WHERE EXISTS (SELECT NULL
                      FROM ego_lcphase_item_status  status
                          ,pa_ego_phases_v phase
                     WHERE status.phase_code = phase.phase_code
                       AND proj_element_id   = cp_phase_id
                       AND status.item_status_code = cp_status_code);
   CURSOR c_default_status (Cp_phase_id NUMBER)
   IS
      SELECT status.item_status_code
        FROM ego_lcphase_item_status status
            ,pa_ego_phases_v phase
       WHERE status.phase_code = phase.phase_code
         AND proj_element_id   = Cp_phase_id
	 AND status.default_flag = 'Y';

   TYPE base_id_type IS TABLE OF mtl_system_items_interface.copy_item_id%TYPE
   INDEX BY BINARY_INTEGER;

   TYPE base_org_type IS TABLE OF mtl_system_items_interface.copy_organization_id%TYPE
   INDEX BY BINARY_INTEGER;

   TYPE base_number_type IS TABLE OF mtl_system_items_interface.copy_item_number%TYPE
   INDEX BY BINARY_INTEGER;

   TYPE base_org_code_type IS TABLE OF mtl_system_items_interface.copy_organization_code%TYPE
   INDEX BY BINARY_INTEGER;

   TYPE transaction_type IS TABLE OF mtl_system_items_interface.transaction_id%TYPE
   INDEX BY BINARY_INTEGER;

   base_item_table base_id_type;
   base_org_table base_org_type;
   base_item_num_table base_number_type;
   base_org_code_table base_org_code_type;
   transaction_table transaction_type;

   l_ext_count NUMBER;
   l_msi_count NUMBER ;
   l_msii_count NUMBER;
   l_inv_debug_level	NUMBER := INVPUTLI.get_debug_level;  --Bug: 4667452
   dumm_status NUMBER;
   l_phase_id NUMBER;
   l_status MTL_SYSTEM_ITEMS.inventory_item_status_code%TYPE;
   l_lifecycle_id NUMBER;
   l_valid_status VARCHAR2(1) := 'N';

BEGIN
   IF l_inv_debug_level IN(101, 102) THEN
      INVPUTLI.info('INVPULI3: inside copy_item_attributes');
   END IF;

     /* Resolving Copy Item Numbers if any to Item Ids */
   BEGIN
      SELECT DISTINCT msii.copy_item_number BULK COLLECT INTO base_item_num_table
        FROM mtl_system_items_interface msii, mtl_parameters mp
       WHERE msii.process_flag = 1
         AND msii.set_process_id = xset_id
         AND msii.transaction_type = 'CREATE'
         AND ((msii.organization_id = org_id) or (all_org = 1))
         AND msii.organization_id = mp.organization_id
         AND mp.organization_id = mp.master_organization_id
         AND ((msii.copy_item_id IS NULL) AND (msii.copy_item_number IS NOT NULL));
   EXCEPTION
     WHEN no_data_found THEN
       null;
   END;

   IF base_item_num_table.COUNT > 0 THEN
     FOR I IN base_item_num_table.FIRST .. base_item_num_table.LAST LOOP
       UPDATE mtl_system_items_interface msii
          SET msii.copy_item_id =
  	       ( SELECT mskfv.inventory_item_id
	           FROM mtl_system_items_b_kfv mskfv
	          WHERE mskfv.concatenated_segments = base_item_num_table(i)
	            AND rownum = 1 )
        WHERE msii.copy_item_number = base_item_num_table(i)
	  AND msii.set_process_id = xset_id
	  AND msii.process_flag = 1
	  AND msii.transaction_type = 'CREATE';
     END LOOP;
   END IF;

     /* Resolving Copy Org Codes if any to Org Ids */
   BEGIN
      SELECT DISTINCT msii.copy_organization_code BULK COLLECT INTO base_org_code_table
        FROM mtl_system_items_interface msii, mtl_parameters mp
       WHERE msii.process_flag = 1
         AND msii.set_process_id = xset_id
         AND msii.transaction_type = 'CREATE'
         AND ((msii.organization_id = org_id) or (all_org = 1))
         AND msii.organization_id = mp.organization_id
         AND mp.organization_id = mp.master_organization_id
         AND ((msii.copy_item_id IS NOT NULL) AND (msii.copy_organization_id IS NULL) AND (copy_organization_code IS NOT NULL));
   EXCEPTION
     WHEN no_data_found THEN
       null;
   END;

   IF base_org_code_table.COUNT > 0 THEN
     FOR I IN base_org_code_table.FIRST .. base_org_code_table.LAST LOOP
       UPDATE mtl_system_items_interface msii
          SET msii.copy_organization_id =
  	       ( SELECT mp.organization_id
	           FROM mtl_parameters mp
	          WHERE mp.organization_code = base_org_code_table(i))
        WHERE msii.copy_organization_code = base_org_code_table(i)
          AND msii.copy_item_id IS NOT NULL
	  AND msii.set_process_id = xset_id
	  AND msii.process_flag = 1
	  AND msii.transaction_type = 'CREATE';
     END LOOP;
   END IF;

   /* Mark records with Copy Item Id but no Copy Org Id to error */
   UPDATE mtl_system_items_interface
      SET process_flag = 3
    WHERE copy_item_id IS NOT NULL
      AND copy_organization_id IS NULL
      AND set_process_id = xset_id
      AND process_flag = 1
      AND transaction_type = 'CREATE'
   RETURNING transaction_id BULK COLLECT INTO transaction_table;

   IF transaction_table.COUNT > 0 THEN
     FOR j IN transaction_table.FIRST .. transaction_table.LAST LOOP
        dumm_status := INVPUOPI.mtl_log_interface_err(
                                      org_id,
                                      user_id,
                                      login_id,
                                      prog_appid,
                                      prog_id,
                                      request_id,
                                      transaction_table(j),
                                      err_text,
		                      'BASE_ITEM_ID',
                                      'MTL_SYSTEM_ITEMS_INTERFACE',
                                      'INV_ITEM_COPY_NO_EXIST' ,
                                      err_text);
     END LOOP;
   END IF;

   BEGIN
     SELECT DISTINCT msii.copy_item_id, msii.copy_organization_id
       BULK COLLECT INTO base_item_table, base_org_table
     FROM mtl_system_items_interface msii, mtl_parameters mp
     WHERE msii.process_flag = 1
       AND msii.set_process_id = xset_id
       AND msii.transaction_type = 'CREATE'
       AND ((msii.organization_id = org_id) or (all_org = 1))
       AND msii.organization_id = mp.organization_id
       AND mp.organization_id = mp.master_organization_id
       AND msii.copy_item_id IS NOT NULL
       AND msii.copy_organization_id IS NOT NULL;
   EXCEPTION
    WHEN no_data_found THEN
      null;
   END;

   IF base_item_table.COUNT > 0 THEN
      FOR I IN base_item_table.FIRST .. base_item_table.LAST LOOP
        BEGIN
	  SELECT lifecycle_id, inventory_item_status_code
	    INTO l_lifecycle_id, l_status
            FROM mtl_system_items
           WHERE inventory_item_id = base_item_table(i)
             AND organization_id = base_org_table(i);
	  l_msi_count := 1;
	EXCEPTION
          WHEN no_data_found THEN
	    l_msi_count := 0;
	    l_lifecycle_id := null;
            l_status := null;
	END;

        IF l_msi_count = 0 THEN
          UPDATE mtl_system_items_interface interface
             SET interface.process_flag = 3
           WHERE interface.process_flag = 1
             AND interface.set_process_id = xset_id
             AND interface.transaction_type = 'CREATE'
             AND interface.copy_organization_id = base_org_table(i)
 	     AND interface.copy_item_id = base_item_table(i)
	  RETURNING transaction_id BULK COLLECT INTO transaction_table;

	  IF transaction_table.COUNT > 0 THEN
             FOR j IN transaction_table.FIRST .. transaction_table.LAST LOOP
                 dumm_status := INVPUOPI.mtl_log_interface_err(
                                      base_org_table(i),
                                      user_id,
                                      login_id,
                                      prog_appid,
                                      prog_id,
                                      request_id,
                                      transaction_table(j),
                                      err_text,
		                      'BASE_ITEM_ID',
                                      'MTL_SYSTEM_ITEMS_INTERFACE',
                                      'INV_ITEM_COPY_NO_EXIST' ,
                                      err_text);
	     END LOOP;
  	  END IF;
	ELSE
	   /* Phase and status to be defaulted to first phase and default status of given lifestyle */
          IF l_lifecycle_id IS NOT NULL THEN
   	     l_phase_id := INV_EGO_REVISION_VALIDATE.Get_Initial_LifeCycle_Phase
	                                       (p_lifecycle_id => l_lifecycle_id);

             OPEN  c_check_item_phase_status ( cp_phase_id    => l_phase_id
	                                      ,cp_status_code => l_status );
	     FETCH c_check_item_phase_status INTO l_valid_status;
	     CLOSE c_check_item_phase_status;

	     IF NVL(l_valid_status,'N') = 'N' THEN
               OPEN  c_default_status(cp_phase_id => l_phase_id);
	       FETCH c_default_status INTO l_status;
	       CLOSE c_default_status;
	     END IF;
	  END IF;

	  UPDATE MTL_SYSTEM_ITEMS_INTERFACE i
	     SET (
                   i.ITEM_CATALOG_GROUP_ID,
                   i.CATALOG_STATUS_FLAG   ,
                   -- Main attributes
		   i.PRIMARY_UOM_CODE    ,
		   --PRIMARY_UNIT_OF_MEASURE,
		   i.ALLOWED_UNITS_LOOKUP_CODE,
		   i.INVENTORY_ITEM_STATUS_CODE,
		   i.DUAL_UOM_CONTROL          ,
		   i.SECONDARY_UOM_CODE        ,
		   i.DUAL_UOM_DEVIATION_HIGH   ,
		   i.DUAL_UOM_DEVIATION_LOW    ,
		   i.ITEM_TYPE                 ,
		   i.LIFECYCLE_ID              ,
		   i.CURRENT_PHASE_ID          ,
		   -- Inventory
		   i.INVENTORY_ITEM_FLAG       ,
		   i.STOCK_ENABLED_FLAG        ,
		   i.MTL_TRANSACTIONS_ENABLED_FLAG ,
		   i.REVISION_QTY_CONTROL_CODE     ,
		   i.LOT_CONTROL_CODE              ,
		   i.AUTO_LOT_ALPHA_PREFIX         ,
		   i.START_AUTO_LOT_NUMBER         ,
		   i.SERIAL_NUMBER_CONTROL_CODE    ,
		   i.AUTO_SERIAL_ALPHA_PREFIX      ,
		   i.START_AUTO_SERIAL_NUMBER      ,
		   i.SHELF_LIFE_CODE               ,
		   i.SHELF_LIFE_DAYS               ,
		   i.RESTRICT_SUBINVENTORIES_CODE  ,
		   i.LOCATION_CONTROL_CODE         ,
		   i.RESTRICT_LOCATORS_CODE        ,
		   i.RESERVABLE_TYPE               ,
		   i.CYCLE_COUNT_ENABLED_FLAG      ,
		   i.NEGATIVE_MEASUREMENT_ERROR    ,
		   i.POSITIVE_MEASUREMENT_ERROR    ,
		   i.CHECK_SHORTAGES_FLAG          ,
		   i.LOT_STATUS_ENABLED            ,
		   i.DEFAULT_LOT_STATUS_ID         ,
		   i.SERIAL_STATUS_ENABLED         ,
		   i.DEFAULT_SERIAL_STATUS_ID      ,
		   i.LOT_SPLIT_ENABLED             ,
		   i.LOT_MERGE_ENABLED             ,
		   i.LOT_TRANSLATE_ENABLED         ,
		   i.LOT_SUBSTITUTION_ENABLED      ,
		   i.BULK_PICKED_FLAG              ,
		   -- Bills of Material
		   i.BOM_ITEM_TYPE      ,
		   i.BOM_ENABLED_FLAG    ,
		   i.BASE_ITEM_ID         ,
		   i.ENG_ITEM_FLAG        ,
		   i.ENGINEERING_ITEM_ID  ,
		   i.ENGINEERING_ECN_CODE ,
		   i.ENGINEERING_DATE     ,
		   i.EFFECTIVITY_CONTROL  ,
		   i.CONFIG_MODEL_TYPE    ,
		   i.PRODUCT_FAMILY_ITEM_ID,
		   i.AUTO_CREATED_CONFIG_FLAG ,
		   -- Costing
		   i.COSTING_ENABLED_FLAG     ,
		   i.INVENTORY_ASSET_FLAG     ,
		   i.COST_OF_SALES_ACCOUNT    ,
		   i.DEFAULT_INCLUDE_IN_ROLLUP_FLAG,
		   i.STD_LOT_SIZE               ,
		   -- Enterprise Asset Management
		   i.EAM_ITEM_TYPE              ,
		   i.EAM_ACTIVITY_TYPE_CODE     ,
		   i.EAM_ACTIVITY_CAUSE_CODE    ,
		   i.EAM_ACTIVITY_SOURCE_CODE   ,
		   i.EAM_ACT_SHUTDOWN_STATUS    ,
		   i.EAM_ACT_NOTIFICATION_FLAG  ,
		   -- Purchasing
		   i.PURCHASING_ITEM_FLAG       ,
		   i.PURCHASING_ENABLED_FLAG    ,
		   i.BUYER_ID		         ,
		   i.MUST_USE_APPROVED_VENDOR_FLAG,
		   i.PURCHASING_TAX_CODE        ,
		   i.TAXABLE_FLAG               ,
		   i.RECEIVE_CLOSE_TOLERANCE    ,
		   i.ALLOW_ITEM_DESC_UPDATE_FLAG,
		   i.INSPECTION_REQUIRED_FLAG   ,
		   i.RECEIPT_REQUIRED_FLAG      ,
		   i.MARKET_PRICE               ,
		   i.UN_NUMBER_ID               ,
		   i.HAZARD_CLASS_ID            ,
		   i.RFQ_REQUIRED_FLAG          ,
		   i.LIST_PRICE_PER_UNIT        ,
		   i.PRICE_TOLERANCE_PERCENT    ,
		   i.ASSET_CATEGORY_ID         ,
		   i.ROUNDING_FACTOR          ,
		   i.UNIT_OF_ISSUE            ,
		   i.OUTSIDE_OPERATION_FLAG    ,
		   i.OUTSIDE_OPERATION_UOM_TYPE ,
		   i.INVOICE_CLOSE_TOLERANCE    ,
		   i.ENCUMBRANCE_ACCOUNT        ,
		   i.EXPENSE_ACCOUNT           ,
		   i.QTY_RCV_EXCEPTION_CODE     ,
		   i.RECEIVING_ROUTING_ID       ,
		   i.QTY_RCV_TOLERANCE          ,
		   i.ENFORCE_SHIP_TO_LOCATION_CODE  ,
		   i.ALLOW_SUBSTITUTE_RECEIPTS_FLAG ,
		   i.ALLOW_UNORDERED_RECEIPTS_FLAG ,
		   i.ALLOW_EXPRESS_DELIVERY_FLAG    ,
		   i.DAYS_EARLY_RECEIPT_ALLOWED ,
		   i.DAYS_LATE_RECEIPT_ALLOWED  ,
		   i.RECEIPT_DAYS_EXCEPTION_CODE,
		   -- Physical
		   i.WEIGHT_UOM_CODE       ,
		   i.UNIT_WEIGHT           ,
		   i.VOLUME_UOM_CODE       ,
		   i.UNIT_VOLUME           ,
		   i.CONTAINER_ITEM_FLAG   ,
		   i.VEHICLE_ITEM_FLAG     ,
		   i.MAXIMUM_LOAD_WEIGHT   ,
		   i.MINIMUM_FILL_PERCENT  ,
		   i.INTERNAL_VOLUME        ,
		   i.CONTAINER_TYPE_CODE     ,
		   i.COLLATERAL_FLAG         ,
		   i.EVENT_FLAG             ,
		   i.EQUIPMENT_TYPE         ,
		   i.ELECTRONIC_FLAG        ,
		   i.DOWNLOADABLE_FLAG      ,
		   i.INDIVISIBLE_FLAG       ,
		   i.DIMENSION_UOM_CODE     ,
		   i.UNIT_LENGTH            ,
		   i.UNIT_WIDTH             ,
		   i.UNIT_HEIGHT      ,
		   i.INVENTORY_PLANNING_CODE ,
		   i.PLANNER_CODE             ,
		   i.PLANNING_MAKE_BUY_CODE    ,
		   i.MIN_MINMAX_QUANTITY       ,
		   i.MAX_MINMAX_QUANTITY      ,
		   i.SAFETY_STOCK_BUCKET_DAYS  ,
		   i.CARRYING_COST              ,
		   i.ORDER_COST                 ,
		   i.MRP_SAFETY_STOCK_PERCENT  ,
		   i.MRP_SAFETY_STOCK_CODE      ,
		   i.FIXED_ORDER_QUANTITY      ,
		   i.FIXED_DAYS_SUPPLY        ,
		   i.MINIMUM_ORDER_QUANTITY    ,
		   i.MAXIMUM_ORDER_QUANTITY     ,
		   i.FIXED_LOT_MULTIPLIER       ,
		   i.SOURCE_TYPE               ,
		   i.SOURCE_ORGANIZATION_ID     ,
		   i.SOURCE_SUBINVENTORY       ,
		   i.MRP_PLANNING_CODE          ,
		   i.ATO_FORECAST_CONTROL       ,
		   i.PLANNING_EXCEPTION_SET     ,
		   i.SHRINKAGE_RATE             ,
		   i.END_ASSEMBLY_PEGGING_FLAG  ,
		   i.ROUNDING_CONTROL_TYPE      ,
		   i.PLANNED_INV_POINT_FLAG     ,
		   i.CREATE_SUPPLY_FLAG        ,
		   i.ACCEPTABLE_EARLY_DAYS     ,
		   i.MRP_CALCULATE_ATP_FLAG     ,
		   i.AUTO_REDUCE_MPS            ,
		   i.REPETITIVE_PLANNING_FLAG   ,
		   i.OVERRUN_PERCENTAGE         ,
		   i.ACCEPTABLE_RATE_DECREASE   ,
		   i.ACCEPTABLE_RATE_INCREASE  ,
		   i.PLANNING_TIME_FENCE_CODE   ,
		   i.PLANNING_TIME_FENCE_DAYS   ,
		   i.DEMAND_TIME_FENCE_CODE     ,
		   i.DEMAND_TIME_FENCE_DAYS     ,
		   i.RELEASE_TIME_FENCE_CODE    ,
		   i.RELEASE_TIME_FENCE_DAYS    ,
		   i.SUBSTITUTION_WINDOW_CODE   ,
		   i.SUBSTITUTION_WINDOW_DAYS   ,
		   -- Lead Times
		   i.PREPROCESSING_LEAD_TIME   ,
		   i.FULL_LEAD_TIME            ,
		   i.POSTPROCESSING_LEAD_TIME   ,
		   i.FIXED_LEAD_TIME            ,
		   i.VARIABLE_LEAD_TIME         ,
		   i.CUM_MANUFACTURING_LEAD_TIME,
		   i.CUMULATIVE_TOTAL_LEAD_TIME ,
		   i.LEAD_TIME_LOT_SIZE         ,
		   -- WIP
		   i.BUILD_IN_WIP_FLAG          ,
		   i.WIP_SUPPLY_TYPE            ,
		   i.WIP_SUPPLY_SUBINVENTORY    ,
		   i.WIP_SUPPLY_LOCATOR_ID      ,
		   i.OVERCOMPLETION_TOLERANCE_TYPE,
		   i.OVERCOMPLETION_TOLERANCE_VALUE,
		   i.INVENTORY_CARRY_PENALTY    ,
		   i.OPERATION_SLACK_PENALTY    ,
		   -- Order Management
		   i.CUSTOMER_ORDER_FLAG        ,
		   i.CUSTOMER_ORDER_ENABLED_FLAG,
		   i.INTERNAL_ORDER_FLAG        ,
		   i.INTERNAL_ORDER_ENABLED_FLAG,
		   i.SHIPPABLE_ITEM_FLAG        ,
		   i.SO_TRANSACTIONS_FLAG       ,
		   i.PICKING_RULE_ID            ,
		   i.PICK_COMPONENTS_FLAG       ,
		   i.REPLENISH_TO_ORDER_FLAG    ,
		   i.ATP_FLAG                   ,
		   i.ATP_COMPONENTS_FLAG        ,
		   i.ATP_RULE_ID                ,
		   i.SHIP_MODEL_COMPLETE_FLAG   ,
		   i.DEFAULT_SHIPPING_ORG       ,
		   i.DEFAULT_SO_SOURCE_TYPE     ,
		   i.RETURNABLE_FLAG            ,
		   i.RETURN_INSPECTION_REQUIREMENT ,
		   i.OVER_SHIPMENT_TOLERANCE    ,
		   i.UNDER_SHIPMENT_TOLERANCE   ,
		   i.OVER_RETURN_TOLERANCE      ,
		   i.UNDER_RETURN_TOLERANCE     ,
		   i.FINANCING_ALLOWED_FLAG     ,
		   i.VOL_DISCOUNT_EXEMPT_FLAG   ,
		   i.COUPON_EXEMPT_FLAG         ,
		   i.INVOICEABLE_ITEM_FLAG      ,
		   i.INVOICE_ENABLED_FLAG       ,
		   i.ACCOUNTING_RULE_ID         ,
		   i.INVOICING_RULE_ID          ,
		   i.TAX_CODE                 ,
		   i.SALES_ACCOUNT            ,
		   i.PAYMENT_TERMS_ID         ,
		   -- Service
		   i.CONTRACT_ITEM_TYPE_CODE   ,
		   i.SERVICE_DURATION_PERIOD_CODE ,
		   i.SERVICE_DURATION           ,
		   i.COVERAGE_SCHEDULE_ID       ,
		   i.SUBSCRIPTION_DEPEND_FLAG   ,
		   i.SERV_IMPORTANCE_LEVEL      ,
		   i.SERV_REQ_ENABLED_CODE      ,
		   i.COMMS_ACTIVATION_REQD_FLAG ,
		   i.SERVICEABLE_PRODUCT_FLAG   ,
		   i.MATERIAL_BILLABLE_FLAG     ,
		   i.SERV_BILLING_ENABLED_FLAG  ,
		   i.DEFECT_TRACKING_ON_FLAG    ,
		   i.RECOVERED_PART_DISP_CODE   ,
		   i.COMMS_NL_TRACKABLE_FLAG    ,
		   i.ASSET_CREATION_CODE        ,
		   i.IB_ITEM_INSTANCE_CLASS     ,
		   i.SERVICE_STARTING_DELAY     ,
		   -- Web Option
		   i.WEB_STATUS ,
		   i.ORDERABLE_ON_WEB_FLAG      ,
		   i.BACK_ORDERABLE_FLAG        ,
		   i.MINIMUM_LICENSE_QUANTITY   ,
		   --Start: 26 new attributes
		   i.TRACKING_QUANTITY_IND    ,
		   i.ONT_PRICING_QTY_SOURCE  ,
		   i.SECONDARY_DEFAULT_IND    ,
		   i.VMI_MINIMUM_UNITS         ,
		   i.VMI_MINIMUM_DAYS           ,
		   i.VMI_MAXIMUM_UNITS          ,
		   i.VMI_MAXIMUM_DAYS           ,
		   i.VMI_FIXED_ORDER_QUANTITY   ,
		   i.SO_AUTHORIZATION_FLAG      ,
		   i.CONSIGNED_FLAG            ,
		   i.ASN_AUTOEXPIRE_FLAG        ,
		   i.VMI_FORECAST_TYPE         ,
		   i.FORECAST_HORIZON           ,
		   i.EXCLUDE_FROM_BUDGET_FLAG   ,
		   i.DAYS_TGT_INV_SUPPLY       ,
		   i.DAYS_TGT_INV_WINDOW       ,
		   i.DAYS_MAX_INV_SUPPLY        ,
		   i.DAYS_MAX_INV_WINDOW       ,
		   i.DRP_PLANNED_FLAG          ,
		   i.CRITICAL_COMPONENT_FLAG    ,
		   i.CONTINOUS_TRANSFER         ,
		   i.CONVERGENCE                ,
		   i.DIVERGENCE                 ,
		   i.CONFIG_ORGS               ,
		   i.CONFIG_MATCH               ,
		   -- Descriptive flex
		   i.ATTRIBUTE_CATEGORY,
		   i.ATTRIBUTE1        ,
		   i.ATTRIBUTE2        ,
		   i.ATTRIBUTE3        ,
		   i.ATTRIBUTE4        ,
		   i.ATTRIBUTE5        ,
		   i.ATTRIBUTE6        ,
		   i.ATTRIBUTE7        ,
		   i.ATTRIBUTE8		,
		   i.ATTRIBUTE9        ,
		   i.ATTRIBUTE10       ,
		   i.ATTRIBUTE11       ,
		   i.ATTRIBUTE12       ,
		   i.ATTRIBUTE13       ,
		   i.ATTRIBUTE14       ,
		   i.ATTRIBUTE15       ,
		   i.ATTRIBUTE16       ,
		   i.ATTRIBUTE17       ,
		   i.ATTRIBUTE18       ,
		   i.ATTRIBUTE19       ,
		   i.ATTRIBUTE20       ,
		   i.ATTRIBUTE21       ,
		   i.ATTRIBUTE22       ,
		   i.ATTRIBUTE23       ,
		   i.ATTRIBUTE24       ,
		   i.ATTRIBUTE25      ,
		   i.ATTRIBUTE26      ,
		   i.ATTRIBUTE27      ,
		   i.ATTRIBUTE28      ,
		   i.ATTRIBUTE29      ,
		   i.ATTRIBUTE30      ,
		   -- Global Descriptive flex
		   i.GLOBAL_ATTRIBUTE_CATEGORY,
		   i.GLOBAL_ATTRIBUTE1        ,
		   i.GLOBAL_ATTRIBUTE2        ,
		   i.GLOBAL_ATTRIBUTE3        ,
		   i.GLOBAL_ATTRIBUTE4        ,
		   i.GLOBAL_ATTRIBUTE5        ,
		   i.GLOBAL_ATTRIBUTE6        ,
		   i.GLOBAL_ATTRIBUTE7         ,
		   i.GLOBAL_ATTRIBUTE8         ,
		   i.GLOBAL_ATTRIBUTE9         ,
		   i.GLOBAL_ATTRIBUTE10        ,
		      /* R12 Enhacement */
		   i.CAS_NUMBER                ,
		   i.CHILD_LOT_FLAG            ,
		   i.CHILD_LOT_PREFIX          ,
		   i.CHILD_LOT_STARTING_NUMBER ,
		   i.CHILD_LOT_VALIDATION_FLAG ,
		   i.COPY_LOT_ATTRIBUTE_FLAG    ,
		   i.DEFAULT_GRADE              ,
		   i.EXPIRATION_ACTION_CODE     ,
		   i.EXPIRATION_ACTION_INTERVAL ,
		   i.GRADE_CONTROL_FLAG         ,
		   i.HAZARDOUS_MATERIAL_FLAG    ,
		   i.HOLD_DAYS                  ,
		   i.LOT_DIVISIBLE_FLAG         ,
		   i.MATURITY_DAYS              ,
		   i.PARENT_CHILD_GENERATION_FLAG,
		   i.PROCESS_COSTING_ENABLED_FLAG ,
		   i.PROCESS_EXECUTION_ENABLED_FLAG,
		   i.PROCESS_QUALITY_ENABLED_FLAG   ,
		   i.PROCESS_SUPPLY_LOCATOR_ID       ,
		   i.PROCESS_SUPPLY_SUBINVENTORY     ,
		   i.PROCESS_YIELD_LOCATOR_ID        ,
		   i.PROCESS_YIELD_SUBINVENTORY      ,
		   i.RECIPE_ENABLED_FLAG             ,
		   i.RETEST_INTERVAL                 ,
		   i.CHARGE_PERIODICITY_CODE         ,
		   i.REPAIR_LEADTIME                 ,
		   i.REPAIR_YIELD                    ,
		   i.PREPOSITION_POINT               ,
		   i.REPAIR_PROGRAM                  ,
		   i.SUBCONTRACTING_COMPONENT        ,
		   i.OUTSOURCED_ASSEMBLY,
                   i.GDSN_OUTBOUND_ENABLED_FLAG,
                   i.TRADE_ITEM_DESCRIPTOR
	    )
          = ( SELECT
                   NVL(i.ITEM_CATALOG_GROUP_ID, m.ITEM_CATALOG_GROUP_ID),
                   NVL(i.CATALOG_STATUS_FLAG, m.CATALOG_STATUS_FLAG),
                   -- Main attributes
		   NVL(i.PRIMARY_UOM_CODE, m.PRIMARY_UOM_CODE ),
		   --PRIMARY_UNIT_OF_MEASURE,
		   NVL(i.ALLOWED_UNITS_LOOKUP_CODE, m.ALLOWED_UNITS_LOOKUP_CODE),
		   NVL(i.INVENTORY_ITEM_STATUS_CODE,l_status),
		   NVL(i.DUAL_UOM_CONTROL, m.DUAL_UOM_CONTROL),
		   NVL(i.SECONDARY_UOM_CODE, m.SECONDARY_UOM_CODE),
		   NVL(i.DUAL_UOM_DEVIATION_HIGH, m.DUAL_UOM_DEVIATION_HIGH),
		   NVL(i.DUAL_UOM_DEVIATION_LOW, m.DUAL_UOM_DEVIATION_LOW),
		   NVL(i.ITEM_TYPE, m.ITEM_TYPE),
		   NVL(i.LIFECYCLE_ID, l_lifecycle_id),
		   NVL(i.CURRENT_PHASE_ID,l_phase_id),
		   -- Inventory
		   NVL(i.INVENTORY_ITEM_FLAG, m.INVENTORY_ITEM_FLAG),
		   NVL(i.STOCK_ENABLED_FLAG, m.STOCK_ENABLED_FLAG),
		   NVL(i.MTL_TRANSACTIONS_ENABLED_FLAG, m.MTL_TRANSACTIONS_ENABLED_FLAG),
		   NVL(i.REVISION_QTY_CONTROL_CODE, m.REVISION_QTY_CONTROL_CODE),
		   NVL(i.LOT_CONTROL_CODE, m.LOT_CONTROL_CODE),
		   NVL(i.AUTO_LOT_ALPHA_PREFIX, m.AUTO_LOT_ALPHA_PREFIX),
		   NVL(i.START_AUTO_LOT_NUMBER, m.START_AUTO_LOT_NUMBER),
		   NVL(i.SERIAL_NUMBER_CONTROL_CODE, m.SERIAL_NUMBER_CONTROL_CODE),
		   NVL(i.AUTO_SERIAL_ALPHA_PREFIX, m.AUTO_SERIAL_ALPHA_PREFIX),
		   NVL(i.START_AUTO_SERIAL_NUMBER, m.START_AUTO_SERIAL_NUMBER),
		   NVL(i.SHELF_LIFE_CODE, m.SHELF_LIFE_CODE),
		   NVL(i.SHELF_LIFE_DAYS, m.SHELF_LIFE_DAYS),
		   NVL(i.RESTRICT_SUBINVENTORIES_CODE, m.RESTRICT_SUBINVENTORIES_CODE),
		   NVL(i.LOCATION_CONTROL_CODE, m.LOCATION_CONTROL_CODE),
		   NVL(i.RESTRICT_LOCATORS_CODE, m.RESTRICT_LOCATORS_CODE),
		   NVL(i.RESERVABLE_TYPE, m.RESERVABLE_TYPE),
		   NVL(i.CYCLE_COUNT_ENABLED_FLAG, m.CYCLE_COUNT_ENABLED_FLAG),
		   NVL(i.NEGATIVE_MEASUREMENT_ERROR, m.NEGATIVE_MEASUREMENT_ERROR),
		   NVL(i.POSITIVE_MEASUREMENT_ERROR, m.POSITIVE_MEASUREMENT_ERROR),
		   NVL(i.CHECK_SHORTAGES_FLAG, m.CHECK_SHORTAGES_FLAG),
		   NVL(i.LOT_STATUS_ENABLED, m.LOT_STATUS_ENABLED),
		   NVL(i.DEFAULT_LOT_STATUS_ID, m.DEFAULT_LOT_STATUS_ID),
		   NVL(i.SERIAL_STATUS_ENABLED , m.SERIAL_STATUS_ENABLED),
		   NVL(i.DEFAULT_SERIAL_STATUS_ID, m.DEFAULT_SERIAL_STATUS_ID),
		   NVL(i.LOT_SPLIT_ENABLED,m.LOT_SPLIT_ENABLED),
		   NVL(i.LOT_MERGE_ENABLED,m.LOT_MERGE_ENABLED),
		   NVL(i.LOT_TRANSLATE_ENABLED, m.LOT_TRANSLATE_ENABLED),
		   NVL(i.LOT_SUBSTITUTION_ENABLED, m.LOT_SUBSTITUTION_ENABLED),
		   NVL(i.BULK_PICKED_FLAG, m.BULK_PICKED_FLAG),
		   -- Bills of Material
		   NVL(i.BOM_ITEM_TYPE, m.BOM_ITEM_TYPE),
		   NVL(i.BOM_ENABLED_FLAG, m.BOM_ENABLED_FLAG),
		   NVL(i.BASE_ITEM_ID, m.BASE_ITEM_ID),
		   NVL(i.ENG_ITEM_FLAG, m.ENG_ITEM_FLAG),
		   NVL(i.ENGINEERING_ITEM_ID, m.ENGINEERING_ITEM_ID),
		   NVL(i.ENGINEERING_ECN_CODE, m.ENGINEERING_ECN_CODE) ,
		   NVL(i.ENGINEERING_DATE , m.ENGINEERING_DATE),
		   NVL(i.EFFECTIVITY_CONTROL , m.EFFECTIVITY_CONTROL),
		   NVL(i.CONFIG_MODEL_TYPE, m.CONFIG_MODEL_TYPE),
		   NVL(i.PRODUCT_FAMILY_ITEM_ID, m.PRODUCT_FAMILY_ITEM_ID),
		   NVL(i.AUTO_CREATED_CONFIG_FLAG , m.AUTO_CREATED_CONFIG_FLAG),
		   -- Costing
		   NVL(i.COSTING_ENABLED_FLAG, m.COSTING_ENABLED_FLAG),
		   NVL(i.INVENTORY_ASSET_FLAG, m.INVENTORY_ASSET_FLAG),
		   NVL(i.COST_OF_SALES_ACCOUNT , m.COST_OF_SALES_ACCOUNT),
		   NVL(i.DEFAULT_INCLUDE_IN_ROLLUP_FLAG, m.DEFAULT_INCLUDE_IN_ROLLUP_FLAG),
		   NVL(i.STD_LOT_SIZE, m.STD_LOT_SIZE),
		   -- Enterprise Asset Management
		   NVL(i.EAM_ITEM_TYPE, m.EAM_ITEM_TYPE),
		   NVL(i.EAM_ACTIVITY_TYPE_CODE , m.EAM_ACTIVITY_TYPE_CODE),
		   NVL(i.EAM_ACTIVITY_CAUSE_CODE , m.EAM_ACTIVITY_CAUSE_CODE),
		   NVL(i.EAM_ACTIVITY_SOURCE_CODE , m.EAM_ACTIVITY_SOURCE_CODE),
		   NVL(i.EAM_ACT_SHUTDOWN_STATUS, m.EAM_ACT_SHUTDOWN_STATUS),
		   NVL(i.EAM_ACT_NOTIFICATION_FLAG, m.EAM_ACT_NOTIFICATION_FLAG),
		   -- Purchasing
		   NVL(i.PURCHASING_ITEM_FLAG , m.PURCHASING_ITEM_FLAG ),
		   NVL(i.PURCHASING_ENABLED_FLAG , m.PURCHASING_ENABLED_FLAG ),
		   NVL(i.BUYER_ID , m.BUYER_ID),
		   NVL(i.MUST_USE_APPROVED_VENDOR_FLAG, m.MUST_USE_APPROVED_VENDOR_FLAG),
		   NVL(i.PURCHASING_TAX_CODE , m.PURCHASING_TAX_CODE),
		   NVL(i.TAXABLE_FLAG , m.TAXABLE_FLAG),
		   NVL(i.RECEIVE_CLOSE_TOLERANCE , m.RECEIVE_CLOSE_TOLERANCE),
		   NVL(i.ALLOW_ITEM_DESC_UPDATE_FLAG, m.ALLOW_ITEM_DESC_UPDATE_FLAG),
		   NVL(i.INSPECTION_REQUIRED_FLAG , m.INSPECTION_REQUIRED_FLAG),
		   NVL(i.RECEIPT_REQUIRED_FLAG , m.RECEIPT_REQUIRED_FLAG ),
		   NVL(i.MARKET_PRICE , m.MARKET_PRICE),
		   NVL(i.UN_NUMBER_ID , m.UN_NUMBER_ID),
		   NVL(i.HAZARD_CLASS_ID ,m.HAZARD_CLASS_ID ),
		   NVL(i.RFQ_REQUIRED_FLAG , m.RFQ_REQUIRED_FLAG ),
		   NVL(i.LIST_PRICE_PER_UNIT , m.LIST_PRICE_PER_UNIT ),
		   NVL(i.PRICE_TOLERANCE_PERCENT , m.PRICE_TOLERANCE_PERCENT),
		   NVL(i.ASSET_CATEGORY_ID , ASSET_CATEGORY_ID ),
		   NVL(i.ROUNDING_FACTOR , m.ROUNDING_FACTOR),
		   NVL(i.UNIT_OF_ISSUE, m.UNIT_OF_ISSUE),
		   NVL(i.OUTSIDE_OPERATION_FLAG, m.OUTSIDE_OPERATION_FLAG),
		   NVL(i.OUTSIDE_OPERATION_UOM_TYPE , m.OUTSIDE_OPERATION_UOM_TYPE ),
		   NVL(i.INVOICE_CLOSE_TOLERANCE , m.INVOICE_CLOSE_TOLERANCE ),
		   NVL(i.ENCUMBRANCE_ACCOUNT , m.ENCUMBRANCE_ACCOUNT ),
		   NVL(i.EXPENSE_ACCOUNT , m.EXPENSE_ACCOUNT ),
		   NVL(i.QTY_RCV_EXCEPTION_CODE , m.QTY_RCV_EXCEPTION_CODE ),
		   NVL(i.RECEIVING_ROUTING_ID , m.RECEIVING_ROUTING_ID ),
		   NVL(i.QTY_RCV_TOLERANCE , m.QTY_RCV_TOLERANCE),
		   NVL(i.ENFORCE_SHIP_TO_LOCATION_CODE , m.ENFORCE_SHIP_TO_LOCATION_CODE ) ,
		   NVL(i.ALLOW_SUBSTITUTE_RECEIPTS_FLAG , m.ALLOW_SUBSTITUTE_RECEIPTS_FLAG),
		   NVL(i.ALLOW_UNORDERED_RECEIPTS_FLAG , m.ALLOW_UNORDERED_RECEIPTS_FLAG),
		   NVL(i.ALLOW_EXPRESS_DELIVERY_FLAG , m.ALLOW_EXPRESS_DELIVERY_FLAG ),
		   NVL(i.DAYS_EARLY_RECEIPT_ALLOWED , m.DAYS_EARLY_RECEIPT_ALLOWED ),
		   NVL(i.DAYS_LATE_RECEIPT_ALLOWED  ,m.DAYS_LATE_RECEIPT_ALLOWED ) ,
		   NVL(i.RECEIPT_DAYS_EXCEPTION_CODE, m.RECEIPT_DAYS_EXCEPTION_CODE),
		   -- Physical
		   NVL(i.WEIGHT_UOM_CODE, m.WEIGHT_UOM_CODE ),
		   NVL(i.UNIT_WEIGHT, m.UNIT_WEIGHT ),
		   NVL(i.VOLUME_UOM_CODE , m.VOLUME_UOM_CODE ),
		   NVL(i.UNIT_VOLUME , m.UNIT_VOLUME ),
		   NVL(i.CONTAINER_ITEM_FLAG , m.CONTAINER_ITEM_FLAG ),
		   NVL(i.VEHICLE_ITEM_FLAG , m.VEHICLE_ITEM_FLAG ),
		   NVL(i.MAXIMUM_LOAD_WEIGHT , m.MAXIMUM_LOAD_WEIGHT ) ,
		   NVL(i.MINIMUM_FILL_PERCENT  , m.MINIMUM_FILL_PERCENT ),
		   NVL(i.INTERNAL_VOLUME , m.INTERNAL_VOLUME ),
		   NVL(i.CONTAINER_TYPE_CODE , m.CONTAINER_TYPE_CODE ),
		   NVL(i.COLLATERAL_FLAG , m.COLLATERAL_FLAG ),
		   NVL(i.EVENT_FLAG , m.EVENT_FLAG ),
		   NVL(i.EQUIPMENT_TYPE , m.EQUIPMENT_TYPE ),
		   NVL(i.ELECTRONIC_FLAG , m.ELECTRONIC_FLAG ),
		   NVL(i.DOWNLOADABLE_FLAG , m.DOWNLOADABLE_FLAG ),
		   NVL(i.INDIVISIBLE_FLAG , m.INDIVISIBLE_FLAG ),
		   NVL(i.DIMENSION_UOM_CODE , m.DIMENSION_UOM_CODE ),
		   NVL(i.UNIT_LENGTH , m.UNIT_LENGTH ),
		   NVL(i.UNIT_WIDTH  , m.UNIT_WIDTH ),
		   NVL(i.UNIT_HEIGHT , m.UNIT_HEIGHT ),
		   NVL(i.INVENTORY_PLANNING_CODE ,m.INVENTORY_PLANNING_CODE ),
		   NVL(i.PLANNER_CODE , m.PLANNER_CODE ),
		   NVL(i.PLANNING_MAKE_BUY_CODE , m.PLANNING_MAKE_BUY_CODE ),
		   NVL(i.MIN_MINMAX_QUANTITY , m.MIN_MINMAX_QUANTITY ),
		   NVL(i.MAX_MINMAX_QUANTITY , m.MAX_MINMAX_QUANTITY ),
		   NVL(i.SAFETY_STOCK_BUCKET_DAYS  , m.SAFETY_STOCK_BUCKET_DAYS ) ,
		   NVL(i.CARRYING_COST , m.CARRYING_COST ),
		   NVL(i.ORDER_COST , m.ORDER_COST ),
		   NVL(i.MRP_SAFETY_STOCK_PERCENT ,m.MRP_SAFETY_STOCK_PERCENT ) ,
		   NVL(i.MRP_SAFETY_STOCK_CODE , m.MRP_SAFETY_STOCK_CODE ),
		   NVL(i.FIXED_ORDER_QUANTITY  , m.FIXED_ORDER_QUANTITY ),
		   NVL(i.FIXED_DAYS_SUPPLY , m.FIXED_DAYS_SUPPLY ),
		   NVL(i.MINIMUM_ORDER_QUANTITY, m.MINIMUM_ORDER_QUANTITY ),
		   NVL(i.MAXIMUM_ORDER_QUANTITY , m.MAXIMUM_ORDER_QUANTITY ),
		   NVL(i.FIXED_LOT_MULTIPLIER , m.FIXED_LOT_MULTIPLIER ) ,
		   NVL(i.SOURCE_TYPE , m.SOURCE_TYPE ),
		   NVL(i.SOURCE_ORGANIZATION_ID , m.SOURCE_ORGANIZATION_ID ),
		   NVL(i.SOURCE_SUBINVENTORY , m.SOURCE_SUBINVENTORY ),
		   NVL(i.MRP_PLANNING_CODE , m.MRP_PLANNING_CODE ),
		   NVL(i.ATO_FORECAST_CONTROL , m.ATO_FORECAST_CONTROL ),
		   NVL(i.PLANNING_EXCEPTION_SET , m.PLANNING_EXCEPTION_SET ),
		   NVL(i.SHRINKAGE_RATE , m.SHRINKAGE_RATE ),
		   NVL(i.END_ASSEMBLY_PEGGING_FLAG , m.END_ASSEMBLY_PEGGING_FLAG ),
		   NVL(i.ROUNDING_CONTROL_TYPE , m.ROUNDING_CONTROL_TYPE ),
		   NVL(i.PLANNED_INV_POINT_FLAG , m.PLANNED_INV_POINT_FLAG ),
		   NVL(i.CREATE_SUPPLY_FLAG , m.CREATE_SUPPLY_FLAG ),
		   NVL(i.ACCEPTABLE_EARLY_DAYS , m.ACCEPTABLE_EARLY_DAYS ) ,
		   NVL(i.MRP_CALCULATE_ATP_FLAG , m.MRP_CALCULATE_ATP_FLAG ),
		   NVL(i.AUTO_REDUCE_MPS , m.AUTO_REDUCE_MPS ),
		   NVL(i.REPETITIVE_PLANNING_FLAG ,m.REPETITIVE_PLANNING_FLAG) ,
		   NVL(i.OVERRUN_PERCENTAGE , m.OVERRUN_PERCENTAGE ),
		   NVL(i.ACCEPTABLE_RATE_DECREASE , m.ACCEPTABLE_RATE_DECREASE ),
		   NVL(i.ACCEPTABLE_RATE_INCREASE  ,m.ACCEPTABLE_RATE_INCREASE ) ,
		   NVL(i.PLANNING_TIME_FENCE_CODE, m.PLANNING_TIME_FENCE_CODE )  ,
                   NVL(i.PLANNING_TIME_FENCE_DAYS, m.PLANNING_TIME_FENCE_DAYS )  ,
                   NVL(i.DEMAND_TIME_FENCE_CODE, m.DEMAND_TIME_FENCE_CODE )  ,
                   NVL(i.DEMAND_TIME_FENCE_DAYS, m.DEMAND_TIME_FENCE_DAYS )  ,
                   NVL(i.RELEASE_TIME_FENCE_CODE, m.RELEASE_TIME_FENCE_CODE )  ,
                   NVL(i.RELEASE_TIME_FENCE_DAYS, m.RELEASE_TIME_FENCE_DAYS )  ,
                   NVL(i.SUBSTITUTION_WINDOW_CODE, m.SUBSTITUTION_WINDOW_CODE )  ,
                   NVL(i.SUBSTITUTION_WINDOW_DAYS, m.SUBSTITUTION_WINDOW_DAYS )  ,
		   -- Lead Times
                   NVL(i.PREPROCESSING_LEAD_TIME, m.PREPROCESSING_LEAD_TIME )  ,
                   NVL(i.FULL_LEAD_TIME, m.FULL_LEAD_TIME )  ,
                   NVL(i.POSTPROCESSING_LEAD_TIME, m.POSTPROCESSING_LEAD_TIME )  ,
                   NVL(i.FIXED_LEAD_TIME, m.FIXED_LEAD_TIME )  ,
                   NVL(i.VARIABLE_LEAD_TIME, m.VARIABLE_LEAD_TIME )  ,
                   NVL(i.CUM_MANUFACTURING_LEAD_TIME, m.CUM_MANUFACTURING_LEAD_TIME )  ,
                   NVL(i.CUMULATIVE_TOTAL_LEAD_TIME, m.CUMULATIVE_TOTAL_LEAD_TIME )  ,
                   NVL(i.LEAD_TIME_LOT_SIZE, m.LEAD_TIME_LOT_SIZE )  ,
		   -- WIP
                   NVL(i.BUILD_IN_WIP_FLAG, m.BUILD_IN_WIP_FLAG )  ,
                   NVL(i.WIP_SUPPLY_TYPE, m.WIP_SUPPLY_TYPE )  ,
                   NVL(i.WIP_SUPPLY_SUBINVENTORY, m.WIP_SUPPLY_SUBINVENTORY )  ,
                   NVL(i.WIP_SUPPLY_LOCATOR_ID, m.WIP_SUPPLY_LOCATOR_ID )  ,
                   NVL(i.OVERCOMPLETION_TOLERANCE_TYPE, m.OVERCOMPLETION_TOLERANCE_TYPE )  ,
                   NVL(i.OVERCOMPLETION_TOLERANCE_VALUE, m.OVERCOMPLETION_TOLERANCE_VALUE )  ,
                   NVL(i.INVENTORY_CARRY_PENALTY, m.INVENTORY_CARRY_PENALTY )  ,
                   NVL(i.OPERATION_SLACK_PENALTY, m.OPERATION_SLACK_PENALTY )  ,
		   -- Order Management
                   NVL(i.CUSTOMER_ORDER_FLAG, m.CUSTOMER_ORDER_FLAG )  ,
                   NVL(i.CUSTOMER_ORDER_ENABLED_FLAG, m.CUSTOMER_ORDER_ENABLED_FLAG )  ,
                   NVL(i.INTERNAL_ORDER_FLAG, m.INTERNAL_ORDER_FLAG )  ,
                   NVL(i.INTERNAL_ORDER_ENABLED_FLAG, m.INTERNAL_ORDER_ENABLED_FLAG )  ,
                   NVL(i.SHIPPABLE_ITEM_FLAG, m.SHIPPABLE_ITEM_FLAG )  ,
                   NVL(i.SO_TRANSACTIONS_FLAG, m.SO_TRANSACTIONS_FLAG )  ,
                   NVL(i.PICKING_RULE_ID, m.PICKING_RULE_ID )  ,
                   NVL(i.PICK_COMPONENTS_FLAG, m.PICK_COMPONENTS_FLAG )  ,
                   NVL(i.REPLENISH_TO_ORDER_FLAG, m.REPLENISH_TO_ORDER_FLAG )  ,
                   NVL(i.ATP_FLAG, m.ATP_FLAG )  ,
                   NVL(i.ATP_COMPONENTS_FLAG, m.ATP_COMPONENTS_FLAG )  ,
                   NVL(i.ATP_RULE_ID, m.ATP_RULE_ID )  ,
                   NVL(i.SHIP_MODEL_COMPLETE_FLAG, m.SHIP_MODEL_COMPLETE_FLAG )  ,
                   NVL(i.DEFAULT_SHIPPING_ORG, m.DEFAULT_SHIPPING_ORG )  ,
                   NVL(i.DEFAULT_SO_SOURCE_TYPE, m.DEFAULT_SO_SOURCE_TYPE )  ,
                   NVL(i.RETURNABLE_FLAG, m.RETURNABLE_FLAG )  ,
                   NVL(i.RETURN_INSPECTION_REQUIREMENT, m.RETURN_INSPECTION_REQUIREMENT )  ,
                   NVL(i.OVER_SHIPMENT_TOLERANCE, m.OVER_SHIPMENT_TOLERANCE )  ,
                   NVL(i.UNDER_SHIPMENT_TOLERANCE, m.UNDER_SHIPMENT_TOLERANCE )  ,
                   NVL(i.OVER_RETURN_TOLERANCE, m.OVER_RETURN_TOLERANCE )  ,
                   NVL(i.UNDER_RETURN_TOLERANCE, m.UNDER_RETURN_TOLERANCE )  ,
                   NVL(i.FINANCING_ALLOWED_FLAG, m.FINANCING_ALLOWED_FLAG )  ,
                   NVL(i.VOL_DISCOUNT_EXEMPT_FLAG, m.VOL_DISCOUNT_EXEMPT_FLAG )  ,
                   NVL(i.COUPON_EXEMPT_FLAG, m.COUPON_EXEMPT_FLAG )  ,
                   NVL(i.INVOICEABLE_ITEM_FLAG, m.INVOICEABLE_ITEM_FLAG )  ,
                   NVL(i.INVOICE_ENABLED_FLAG, m.INVOICE_ENABLED_FLAG )  ,
                   NVL(i.ACCOUNTING_RULE_ID, m.ACCOUNTING_RULE_ID )  ,
                   NVL(i.INVOICING_RULE_ID, m.INVOICING_RULE_ID )  ,
                   NVL(i.TAX_CODE, m.TAX_CODE )  ,
                   NVL(i.SALES_ACCOUNT, m.SALES_ACCOUNT )  ,
                   NVL(i.PAYMENT_TERMS_ID, m.PAYMENT_TERMS_ID )  ,
		   -- Service
                   NVL(i.CONTRACT_ITEM_TYPE_CODE, m.CONTRACT_ITEM_TYPE_CODE )  ,
                   NVL(i.SERVICE_DURATION_PERIOD_CODE, m.SERVICE_DURATION_PERIOD_CODE )  ,
                   NVL(i.SERVICE_DURATION, m.SERVICE_DURATION )  ,
                   NVL(i.COVERAGE_SCHEDULE_ID, m.COVERAGE_SCHEDULE_ID )  ,
                   NVL(i.SUBSCRIPTION_DEPEND_FLAG, m.SUBSCRIPTION_DEPEND_FLAG )  ,
                   NVL(i.SERV_IMPORTANCE_LEVEL, m.SERV_IMPORTANCE_LEVEL )  ,
                   NVL(i.SERV_REQ_ENABLED_CODE, m.SERV_REQ_ENABLED_CODE )  ,
                   NVL(i.COMMS_ACTIVATION_REQD_FLAG, m.COMMS_ACTIVATION_REQD_FLAG )  ,
                   NVL(i.SERVICEABLE_PRODUCT_FLAG, m.SERVICEABLE_PRODUCT_FLAG )  ,
                   NVL(i.MATERIAL_BILLABLE_FLAG, m.MATERIAL_BILLABLE_FLAG )  ,
                   NVL(i.SERV_BILLING_ENABLED_FLAG, m.SERV_BILLING_ENABLED_FLAG )  ,
                   NVL(i.DEFECT_TRACKING_ON_FLAG, m.DEFECT_TRACKING_ON_FLAG )  ,
                   NVL(i.RECOVERED_PART_DISP_CODE, m.RECOVERED_PART_DISP_CODE )  ,
                   NVL(i.COMMS_NL_TRACKABLE_FLAG, m.COMMS_NL_TRACKABLE_FLAG )  ,
                   NVL(i.ASSET_CREATION_CODE, m.ASSET_CREATION_CODE )  ,
                   NVL(i.IB_ITEM_INSTANCE_CLASS, m.IB_ITEM_INSTANCE_CLASS )  ,
                   NVL(i.SERVICE_STARTING_DELAY, m.SERVICE_STARTING_DELAY )  ,
		   -- Web Option
                   NVL(i.WEB_STATUS, m.WEB_STATUS )  ,
                   NVL(i.ORDERABLE_ON_WEB_FLAG, m.ORDERABLE_ON_WEB_FLAG )  ,
                   NVL(i.BACK_ORDERABLE_FLAG, m.BACK_ORDERABLE_FLAG )  ,
                   NVL(i.MINIMUM_LICENSE_QUANTITY, m.MINIMUM_LICENSE_QUANTITY )  ,
		   --Start: 26 new attributes
                   NVL(i.TRACKING_QUANTITY_IND, m.TRACKING_QUANTITY_IND )  ,
                   NVL(i.ONT_PRICING_QTY_SOURCE, m.ONT_PRICING_QTY_SOURCE )  ,
                   NVL(i.SECONDARY_DEFAULT_IND, m.SECONDARY_DEFAULT_IND )  ,
                   NVL(i.VMI_MINIMUM_UNITS, m.VMI_MINIMUM_UNITS )  ,
                   NVL(i.VMI_MINIMUM_DAYS, m.VMI_MINIMUM_DAYS )  ,
                   NVL(i.VMI_MAXIMUM_UNITS, m.VMI_MAXIMUM_UNITS )  ,
                   NVL(i.VMI_MAXIMUM_DAYS, m.VMI_MAXIMUM_DAYS )  ,
                   NVL(i.VMI_FIXED_ORDER_QUANTITY, m.VMI_FIXED_ORDER_QUANTITY )  ,
                   NVL(i.SO_AUTHORIZATION_FLAG, m.SO_AUTHORIZATION_FLAG )  ,
                   NVL(i.CONSIGNED_FLAG, m.CONSIGNED_FLAG )  ,
                   NVL(i.ASN_AUTOEXPIRE_FLAG, m.ASN_AUTOEXPIRE_FLAG )  ,
                   NVL(i.VMI_FORECAST_TYPE, m.VMI_FORECAST_TYPE )  ,
                   NVL(i.FORECAST_HORIZON, m.FORECAST_HORIZON )  ,
                   NVL(i.EXCLUDE_FROM_BUDGET_FLAG, m.EXCLUDE_FROM_BUDGET_FLAG )  ,
                   NVL(i.DAYS_TGT_INV_SUPPLY, m.DAYS_TGT_INV_SUPPLY )  ,
                   NVL(i.DAYS_TGT_INV_WINDOW, m.DAYS_TGT_INV_WINDOW )  ,
                   NVL(i.DAYS_MAX_INV_SUPPLY, m.DAYS_MAX_INV_SUPPLY )  ,
                   NVL(i.DAYS_MAX_INV_WINDOW, m.DAYS_MAX_INV_WINDOW )  ,
                   NVL(i.DRP_PLANNED_FLAG, m.DRP_PLANNED_FLAG )  ,
                   NVL(i.CRITICAL_COMPONENT_FLAG, m.CRITICAL_COMPONENT_FLAG )  ,
                   NVL(i.CONTINOUS_TRANSFER, m.CONTINOUS_TRANSFER )  ,
                   NVL(i.CONVERGENCE, m.CONVERGENCE )  ,
                   NVL(i.DIVERGENCE, m.DIVERGENCE )  ,
                   NVL(i.CONFIG_ORGS, m.CONFIG_ORGS )  ,
                   NVL(i.CONFIG_MATCH, m.CONFIG_MATCH )  ,
                   -- Desc Flex
                   NVL(i.ATTRIBUTE_CATEGORY, m.ATTRIBUTE_CATEGORY )  ,
                   NVL(i.ATTRIBUTE1, m.ATTRIBUTE1 )  ,
                   NVL(i.ATTRIBUTE2, m.ATTRIBUTE2 )  ,
                   NVL(i.ATTRIBUTE3, m.ATTRIBUTE3 )  ,
                   NVL(i.ATTRIBUTE4, m.ATTRIBUTE4 )  ,
                   NVL(i.ATTRIBUTE5, m.ATTRIBUTE5 )  ,
                   NVL(i.ATTRIBUTE6, m.ATTRIBUTE6 )  ,
                   NVL(i.ATTRIBUTE7, m.ATTRIBUTE7 )  ,
                   NVL(i.ATTRIBUTE8, m.ATTRIBUTE8 )  ,
                   NVL(i.ATTRIBUTE9, m.ATTRIBUTE9 )  ,
                   NVL(i.ATTRIBUTE10, m.ATTRIBUTE10 )  ,
                   NVL(i.ATTRIBUTE11, m.ATTRIBUTE11 )  ,
                   NVL(i.ATTRIBUTE12, m.ATTRIBUTE12 )  ,
                   NVL(i.ATTRIBUTE13, m.ATTRIBUTE13 )  ,
                   NVL(i.ATTRIBUTE15, m.ATTRIBUTE14 )  ,
                   NVL(i.ATTRIBUTE15, m.ATTRIBUTE15 )  ,
                   NVL(i.ATTRIBUTE16, m.ATTRIBUTE16 )  ,
                   NVL(i.ATTRIBUTE17, m.ATTRIBUTE17 )  ,
                   NVL(i.ATTRIBUTE18, m.ATTRIBUTE18 )  ,
                   NVL(i.ATTRIBUTE19, m.ATTRIBUTE19 )  ,
                   NVL(i.ATTRIBUTE20, m.ATTRIBUTE20 )  ,
                   NVL(i.ATTRIBUTE21, m.ATTRIBUTE21 )  ,
                   NVL(i.ATTRIBUTE22, m.ATTRIBUTE22 )  ,
                   NVL(i.ATTRIBUTE23, m.ATTRIBUTE23 )  ,
                   NVL(i.ATTRIBUTE24, m.ATTRIBUTE24 )  ,
                   NVL(i.ATTRIBUTE25, m.ATTRIBUTE25 )  ,
                   NVL(i.ATTRIBUTE26, m.ATTRIBUTE26 )  ,
                   NVL(i.ATTRIBUTE27, m.ATTRIBUTE27 )  ,
                   NVL(i.ATTRIBUTE28, m.ATTRIBUTE28 )  ,
                   NVL(i.ATTRIBUTE29, m.ATTRIBUTE29 )  ,
                   NVL(i.ATTRIBUTE30, m.ATTRIBUTE30 )  ,
                   NVL(i.GLOBAL_ATTRIBUTE_CATEGORY, m.GLOBAL_ATTRIBUTE_CATEGORY )  ,
                   NVL(i.GLOBAL_ATTRIBUTE1, m.GLOBAL_ATTRIBUTE1 )  ,
                   NVL(i.GLOBAL_ATTRIBUTE2, m.GLOBAL_ATTRIBUTE2)  ,
                   NVL(i.GLOBAL_ATTRIBUTE3, m.GLOBAL_ATTRIBUTE3)  ,
                   NVL(i.GLOBAL_ATTRIBUTE4, m.GLOBAL_ATTRIBUTE4)  ,
                   NVL(i.GLOBAL_ATTRIBUTE5, m.GLOBAL_ATTRIBUTE5)  ,
                   NVL(i.GLOBAL_ATTRIBUTE6, m.GLOBAL_ATTRIBUTE6)  ,
                   NVL(i.GLOBAL_ATTRIBUTE7, m.GLOBAL_ATTRIBUTE7)  ,
                   NVL(i.GLOBAL_ATTRIBUTE8, m.GLOBAL_ATTRIBUTE8)  ,
                   NVL(i.GLOBAL_ATTRIBUTE9, m.GLOBAL_ATTRIBUTE9)  ,
                   NVL(i.GLOBAL_ATTRIBUTE10, m.GLOBAL_ATTRIBUTE10)  ,
		      /* R12 Enhacement */
                   NVL(i.CAS_NUMBER, m.CAS_NUMBER)  ,
                   NVL(i.CHILD_LOT_FLAG, m.CHILD_LOT_FLAG)  ,
                   NVL(i.CHILD_LOT_PREFIX, m.CHILD_LOT_PREFIX)  ,
                   NVL(i.CHILD_LOT_STARTING_NUMBER, m.CHILD_LOT_STARTING_NUMBER)  ,
                   NVL(i.CHILD_LOT_VALIDATION_FLAG, m.CHILD_LOT_VALIDATION_FLAG)  ,
                   NVL(i.COPY_LOT_ATTRIBUTE_FLAG, m.COPY_LOT_ATTRIBUTE_FLAG)  ,
                   NVL(i.DEFAULT_GRADE, m.DEFAULT_GRADE)  ,
                   NVL(i.EXPIRATION_ACTION_CODE, m.EXPIRATION_ACTION_CODE)  ,
                   NVL(i.EXPIRATION_ACTION_INTERVAL, m.EXPIRATION_ACTION_INTERVAL)  ,
                   NVL(i.GRADE_CONTROL_FLAG, m.GRADE_CONTROL_FLAG)  ,
                   NVL(i.HAZARDOUS_MATERIAL_FLAG, m.HAZARDOUS_MATERIAL_FLAG)  ,
                   NVL(i.HOLD_DAYS, m.HOLD_DAYS)  ,
                   NVL(i.LOT_DIVISIBLE_FLAG, m.LOT_DIVISIBLE_FLAG)  ,
                   NVL(i.MATURITY_DAYS, m.MATURITY_DAYS)  ,
                   NVL(i.PARENT_CHILD_GENERATION_FLAG, m.PARENT_CHILD_GENERATION_FLAG)  ,
                   NVL(i.PROCESS_COSTING_ENABLED_FLAG, m.PROCESS_COSTING_ENABLED_FLAG)  ,
                   NVL(i.PROCESS_EXECUTION_ENABLED_FLAG, m.PROCESS_EXECUTION_ENABLED_FLAG)  ,
                   NVL(i.PROCESS_QUALITY_ENABLED_FLAG, m.PROCESS_QUALITY_ENABLED_FLAG)  ,
                   NVL(i.PROCESS_SUPPLY_LOCATOR_ID, m.PROCESS_SUPPLY_LOCATOR_ID)  ,
                   NVL(i.PROCESS_SUPPLY_SUBINVENTORY, m.PROCESS_SUPPLY_SUBINVENTORY)  ,
                   NVL(i.PROCESS_YIELD_LOCATOR_ID, m.PROCESS_YIELD_LOCATOR_ID)  ,
                   NVL(i.PROCESS_YIELD_SUBINVENTORY, m.PROCESS_YIELD_SUBINVENTORY)  ,
                   NVL(i.RECIPE_ENABLED_FLAG, m.RECIPE_ENABLED_FLAG)  ,
                   NVL(i.RETEST_INTERVAL, m.RETEST_INTERVAL)  ,
                   NVL(i.CHARGE_PERIODICITY_CODE, m.CHARGE_PERIODICITY_CODE)  ,
                   NVL(i.REPAIR_LEADTIME, m.REPAIR_LEADTIME)  ,
                   NVL(i.REPAIR_YIELD, m.REPAIR_YIELD)  ,
                   NVL(i.PREPOSITION_POINT, m.PREPOSITION_POINT)  ,
                   NVL(i.REPAIR_PROGRAM, m.REPAIR_PROGRAM)  ,
                   NVL(i.SUBCONTRACTING_COMPONENT, m.SUBCONTRACTING_COMPONENT)  ,
                   NVL(i.OUTSOURCED_ASSEMBLY, m.OUTSOURCED_ASSEMBLY),
                      /* R12 C Enhancement */
                   NVL(i.GDSN_OUTBOUND_ENABLED_FLAG, m.GDSN_OUTBOUND_ENABLED_FLAG),
                   NVL(i.TRADE_ITEM_DESCRIPTOR, m.TRADE_ITEM_DESCRIPTOR)
               FROM MTL_SYSTEM_ITEMS m
	      WHERE m.inventory_item_id = base_item_table(i)
	        AND m.organization_id = base_org_table(i))
	   WHERE i.process_flag = 1
             AND i.set_process_id = xset_id
             AND i.transaction_type = 'CREATE'
             AND i.copy_organization_id = base_org_table(i)
	     AND i.copy_item_id = base_item_table(i);
        END IF;
      END LOOP;
    END IF;
    RETURN(0);
EXCEPTION
  WHEN others THEN
     err_text := substr('INVPULI3.copy_item_attributes ' || SQLERRM,1, 240);
     return(SQLCODE);
END copy_item_attributes;

end INVPULI3;

/
