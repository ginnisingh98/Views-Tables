--------------------------------------------------------
--  DDL for Package Body INVPPROC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INVPPROC" AS
/* $Header: INVPPROB.pls 120.26.12010000.9 2010/07/29 14:06:55 ccsingh ship $ */
FUNCTION inproit_process_item
(
prg_appid  in   NUMBER,
prg_id     in   NUMBER,
req_id     in   NUMBER,
user_id    in   NUMBER,
login_id   in   NUMBER,
error_message  out   NOCOPY   VARCHAR2,
message_name   out   NOCOPY   VARCHAR2,
table_name     out   NOCOPY   VARCHAR2,
xset_id    IN   NUMBER  DEFAULT  -999,
 p_commit   IN   NUMBER DEFAULT 1       -- Added for bug 7237483
)
RETURN  INTEGER
IS

   CURSOR UOM_Process IS
      SELECT
         msii.inventory_item_id  INV_ITEM_ID
      ,  msii.primary_uom_code   PUOMCODE
      ,  muom.unit_of_measure    PUOM
      ,  muom.base_uom_flag
      ,  muom.uom_class          UOMCL
      FROM
         mtl_units_of_measure_vl     muom
      ,  mtl_system_items_interface  msii
      WHERE
             msii.process_flag = 4
         AND msii.allowed_units_lookup_code = 1
         AND msii.set_process_id = xset_id
         AND muom.uom_code = msii.primary_uom_code
         AND NOT EXISTS
             ( select 'x'
               from mtl_uom_conversions
               where inventory_item_id = msii.inventory_item_id
                 and uom_code = msii.primary_uom_code
             );

        return_code     number := 0;
        return_err      VARCHAR2(240);
        dumm_status     number := 0;
        COST_ERR        exception;
        conversion_rate_temp       number;
        status                     number;
        error_msg       varchar2(70);
        LOGGING_ERR     exception;
        l_sysdate          date := sysdate ;
        l_process_flag_4   number := 4 ;
        l_process_flag_7   number := 7 ;

   CURSOR Cat_Assign IS
        select
                mp.MASTER_ORGANIZATION_ID MORG,
                msi.organization_id       ORGID,
                msi.inventory_item_id     ITEMID,
                msi.inventory_item_flag   INVFLAG,
                msi.purchasing_item_flag  PURFLAG,
                msi.internal_order_flag   INTFLAG,
                msi.mrp_planning_code     MRPCODE,
                msi.serviceable_product_flag    SERVFLAG,
                msi.costing_enabled_flag  COSTFLAG,
                msi.eng_item_flag         ENGFLAG,
                msi.customer_order_flag   CUSTFLAG,
                msi.eam_item_type         EAMTYPE,
                msi.contract_item_type_code     CONTCODE,
                msi.gdsn_outbound_enabled_flag GDSNFLAG
        from    mtl_parameters mp,
                mtl_system_items_interface msi
        where   mp.MASTER_ORGANIZATION_ID <> msi.organization_id
        and     mp.organization_id  = msi.organization_id
        AND     msi.transaction_type = 'CREATE'
        AND     msi.process_flag = l_process_flag_4
        AND     msi.set_process_id = xset_id
	AND     msi.INVENTORY_ITEM_STATUS_CODE <> 'Pending';

   CURSOR Flex_Exists IS
        select  msi.item_number,msi.organization_id,msi.organization_code,
                msi.transaction_id,msi.process_flag
        from    mtl_system_items_b_kfv msk,
                mtl_system_items_interface msi
        where   msi.item_number = msk.concatenated_segments
        and     msk.organization_id  = msi.organization_id
        AND     msi.transaction_type = 'CREATE'
        AND     msi.process_flag = l_process_flag_4
        AND     msi.set_process_id = xset_id
        FOR UPDATE OF process_flag;

   CURSOR get_organization_code (cp_org_id VARCHAR2) IS
        SELECT name
          FROM hr_organization_units
         WHERE organization_id = cp_org_id;

   CURSOR c_ego_intf_rows IS
        SELECT msii.transaction_id,
               tl.language,
               tl.column_value,
               msii.inventory_item_id,
               msii.organization_id
          FROM mtl_system_items_interface msii,
               ego_interface_tl tl
         WHERE msii.process_flag = l_process_flag_4
           AND msii.set_process_id = xset_id
           AND msii.transaction_type = 'CREATE'
           AND tl.unique_id = msii.transaction_id
           AND tl.set_process_id = msii.set_process_id
		     AND UPPER(tl.table_name) = 'MTL_SYSTEM_ITEMS_INTERFACE'
		     AND UPPER(tl.column_name) = 'DESCRIPTION'
           AND tl.language IN (SELECT l.language_code FROM fnd_languages l
                                WHERE l.installed_flag IN ('I', 'B'));

   CURSOR is_gdsn_batch(cp_xset_id NUMBER) IS
       SELECT 1 FROM ego_import_option_sets
        WHERE batch_id = cp_xset_id
          AND enabled_for_data_pool = 'Y';

   CURSOR duplicate_recs IS
       SELECT inventory_item_id, organization_id, item_number
         FROM mtl_system_items_interface
        WHERE transaction_type = 'CREATE'
          AND process_flag = l_process_flag_4
          AND set_process_id = xset_id;

   l_transaction_type    VARCHAR2(10)  :=  'CREATE';

   --serial_tagging enh -- bug 9913552
   -- cursor for deleting serial Assignment for items which failed
    -- during validation phase but tagging assignemnt exists

  CURSOR serial_tag_del IS
      SELECT inventory_item_id, organization_id
      FROM
      MTL_SYSTEM_ITEMS_INTERFACE  I
      WHERE
           I.process_flag <> l_process_flag_4
      AND  I.set_process_id = xset_id
      AND  I.transaction_type = l_transaction_type;

  x_ret_sts VARCHAR(1);

   TYPE transaction_type IS TABLE OF mtl_system_items_interface.transaction_id%TYPE
   INDEX BY BINARY_INTEGER;

   transaction_table transaction_type;


   l_pending_flag     varchar2(1);
-- fix for 3409139
--   l_last_updated_by  number;
--   l_created_by       number;
   l_default_conversion_flag    VARCHAR2(1);

--   l_Primary_Unit_of_Measure    VARCHAR2(25);

   l_inv_debug_level	NUMBER := INVPUTLI.get_debug_level;  --Bug: 4667452
   l_item_id  NUMBER;
   l_item_count NUMBER;
   l_err_text VARCHAR2(1000);
   org_name   varchar2(240);
   l_is_gdsn_batch     NUMBER;
   ext_flag     NUMBER;

BEGIN

   IF l_inv_debug_level IN(101, 102) THEN
      INVPUTLI.info('INVPPROC.inproit_process_item: inserting into MSI_B with xset_id = '|| xset_id);
   END IF;
   --Bug 4767919 Anmurali
   IF (INSTR(INV_EGO_REVISION_VALIDATE.Get_Process_Control,'PLM_UI:Y') <> 0) THEN

     For ff in Flex_Exists Loop

         Open  get_organization_code(ff.organization_id);
         Fetch get_organization_code Into org_name;
         Close get_organization_code;
         org_name := NVL(org_name, ff.organization_code);

         FND_MESSAGE.SET_NAME ('INV', 'INV_IOI_DUPLICATE_ITEM_MSI');
         FND_MESSAGE.SET_TOKEN ('ITEM_NUMBER', ff.item_number);
         FND_MESSAGE.SET_TOKEN ('ORGANIZATION', org_name);
         error_msg := FND_MESSAGE.GET;

         dumm_status := INVPUOPI.mtl_log_interface_err(
                                  ff.organization_id,
                                  user_id,
                                  login_id,
                                  prg_appid,
                                  prg_id,
                                  req_id,
                                  ff.TRANSACTION_ID,
                                  error_msg,
                                 'INVENTORY_ITEM_ID',
                                 'MTL_SYSTEM_ITEMS_INTERFACE',
                                 'INV_IOI_ERR',
                                  l_err_text);
         IF dumm_status < 0 THEN
            raise LOGGING_ERR;
         END IF;

         UPDATE mtl_system_items_interface
            SET process_flag = 3
         WHERE CURRENT OF Flex_Exists;

     END LOOP;
   END IF;

            --Performing duplicate check validation for GDSN batches
   OPEN  is_gdsn_batch(xset_id);
   FETCH is_gdsn_batch INTO l_is_gdsn_batch;
   CLOSE is_gdsn_batch;

   IF l_is_gdsn_batch = 1 THEN
      FOR cr IN duplicate_recs LOOP
		   SELECT count(*) INTO ext_flag
           FROM MTL_SYSTEM_ITEMS_INTERFACE
          WHERE inventory_item_id = cr.inventory_item_id
            AND organization_id = cr.organization_id
            AND process_flag = 4
            AND set_process_id  = xset_id
            AND transaction_type = 'CREATE';

         IF ext_flag > 1 THEN
           UPDATE MTL_SYSTEM_ITEMS_INTERFACE
              SET process_flag = 3
            WHERE inventory_item_id = cr.inventory_item_id
              AND organization_id = cr.organization_id
              AND process_flag = l_process_flag_4
              AND set_process_id  = xset_id
              AND transaction_type = 'CREATE'
           RETURNING transaction_id BULK COLLECT INTO transaction_table;

		     OPEN  get_organization_code(cr.organization_id);
		     FETCH get_organization_code Into org_name;
		     CLOSE get_organization_code;

           FND_MESSAGE.SET_NAME  ('INV', 'INV_IOI_DUPLICATE_REC_MSII');
           FND_MESSAGE.SET_TOKEN ('ITEM_NUMBER', cr.item_number);
           FND_MESSAGE.SET_TOKEN ('ORGANIZATION', org_name);
           error_msg := FND_MESSAGE.GET;

           IF transaction_table.COUNT > 0 THEN
              FOR j IN transaction_table.FIRST .. transaction_table.LAST LOOP
                 dumm_status := INVPUOPI.mtl_log_interface_err(
                                      cr.organization_id,
                                      user_id,
                                      login_id,
                                      prg_appid,
                                      prg_id,
                                      req_id,
                                      transaction_table(j),
                                      error_msg,
	  	                                'INVENTORY_ITEM_ID',
                                      'MTL_SYSTEM_ITEMS_INTERFACE',
                                      'INV_IOI_ERR' ,
                                      l_err_text);
              END LOOP;
           END IF;
         END IF;
      END LOOP;
   END IF;
   -- serial_Tagging enh -- bug 9913552
   FOR I IN serial_tag_del LOOP
    inv_serial_number_pub.delete_serial_tag_assignments(
                                  p_inventory_item_id=> i.inventory_item_id,
                                  p_organization_id=>i.organization_id,
                                  x_return_status=>x_ret_sts);
   END LOOP;

   INSERT INTO MTL_SYSTEM_ITEMS_B
   (
      INVENTORY_ITEM_ID,
      ORGANIZATION_ID,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             CREATION_DATE,
             CREATED_BY,
             LAST_UPDATE_LOGIN,
             SUMMARY_FLAG,
             ENABLED_FLAG,
--             START_DATE_ACTIVE,    Commented for Bug: 4457440
--             END_DATE_ACTIVE,      Commented for Bug: 4457440
             DESCRIPTION,
             BUYER_ID,
             ACCOUNTING_RULE_ID,
             INVOICING_RULE_ID,
             SEGMENT1,
             SEGMENT2,
             SEGMENT3,
             SEGMENT4,
             SEGMENT5,
             SEGMENT6,
             SEGMENT7,
             SEGMENT8,
             SEGMENT9,
             SEGMENT10,
             SEGMENT11,
             SEGMENT12,
             SEGMENT13,
             SEGMENT14,
             SEGMENT15,
             SEGMENT16,
             SEGMENT17,
             SEGMENT18,
             SEGMENT19,
             SEGMENT20,
             ATTRIBUTE_CATEGORY,
             ATTRIBUTE1,
             ATTRIBUTE2,
             ATTRIBUTE3,
             ATTRIBUTE4,
             ATTRIBUTE5,
             ATTRIBUTE6,
             ATTRIBUTE7,
             ATTRIBUTE8,
             ATTRIBUTE9,
             ATTRIBUTE10,
             ATTRIBUTE11,
             ATTRIBUTE12,
             ATTRIBUTE13,
             ATTRIBUTE14,
             ATTRIBUTE15,
/* Start Bug 3713912 */
	     ATTRIBUTE16,
	     ATTRIBUTE17,
	     ATTRIBUTE18,
	     ATTRIBUTE19,
	     ATTRIBUTE20,
	     ATTRIBUTE21,
	     ATTRIBUTE22,
	     ATTRIBUTE23,
	     ATTRIBUTE24,
	     ATTRIBUTE25,
	     ATTRIBUTE26,
	     ATTRIBUTE27,
	     ATTRIBUTE28,
	     ATTRIBUTE29,
	     ATTRIBUTE30,
/* End Bug 3713912 */
             GLOBAL_ATTRIBUTE_CATEGORY,
             GLOBAL_ATTRIBUTE1,
             GLOBAL_ATTRIBUTE2,
             GLOBAL_ATTRIBUTE3,
             GLOBAL_ATTRIBUTE4,
             GLOBAL_ATTRIBUTE5,
             GLOBAL_ATTRIBUTE6,
             GLOBAL_ATTRIBUTE7,
             GLOBAL_ATTRIBUTE8,
             GLOBAL_ATTRIBUTE9,
             GLOBAL_ATTRIBUTE10,
             GLOBAL_ATTRIBUTE11,
             GLOBAL_ATTRIBUTE12,
             GLOBAL_ATTRIBUTE13,
             GLOBAL_ATTRIBUTE14,
             GLOBAL_ATTRIBUTE15,
             GLOBAL_ATTRIBUTE16,
             GLOBAL_ATTRIBUTE17,
             GLOBAL_ATTRIBUTE18,
             GLOBAL_ATTRIBUTE19,
             GLOBAL_ATTRIBUTE20,
             PURCHASING_ITEM_FLAG,
             SHIPPABLE_ITEM_FLAG,
             CUSTOMER_ORDER_FLAG,
             INTERNAL_ORDER_FLAG,
             INVENTORY_ITEM_FLAG,
             ENG_ITEM_FLAG,
             INVENTORY_ASSET_FLAG,
             PURCHASING_ENABLED_FLAG,
             CUSTOMER_ORDER_ENABLED_FLAG,
             INTERNAL_ORDER_ENABLED_FLAG,
             SO_TRANSACTIONS_FLAG,
             MTL_TRANSACTIONS_ENABLED_FLAG,
             STOCK_ENABLED_FLAG,
             BOM_ENABLED_FLAG,
             BUILD_IN_WIP_FLAG,
             REVISION_QTY_CONTROL_CODE,
             ITEM_CATALOG_GROUP_ID,
             CATALOG_STATUS_FLAG,
             RETURNABLE_FLAG,
             DEFAULT_SHIPPING_ORG,
             COLLATERAL_FLAG,
             TAXABLE_FLAG,
             PURCHASING_TAX_CODE,
             ALLOW_ITEM_DESC_UPDATE_FLAG,
             INSPECTION_REQUIRED_FLAG,
             RECEIPT_REQUIRED_FLAG,
             MARKET_PRICE,
             HAZARD_CLASS_ID,
             RFQ_REQUIRED_FLAG,
             QTY_RCV_TOLERANCE,
             LIST_PRICE_PER_UNIT,
             UN_NUMBER_ID,
             PRICE_TOLERANCE_PERCENT,
             ASSET_CATEGORY_ID,
             ROUNDING_FACTOR,
             UNIT_OF_ISSUE,
             ENFORCE_SHIP_TO_LOCATION_CODE,
             ALLOW_SUBSTITUTE_RECEIPTS_FLAG,
             ALLOW_UNORDERED_RECEIPTS_FLAG,
             ALLOW_EXPRESS_DELIVERY_FLAG,
             DAYS_EARLY_RECEIPT_ALLOWED,
             DAYS_LATE_RECEIPT_ALLOWED,
             RECEIPT_DAYS_EXCEPTION_CODE,
             RECEIVING_ROUTING_ID,
             INVOICE_CLOSE_TOLERANCE,
             RECEIVE_CLOSE_TOLERANCE,
             AUTO_LOT_ALPHA_PREFIX,
             START_AUTO_LOT_NUMBER,
             LOT_CONTROL_CODE,
             SHELF_LIFE_CODE,
             SHELF_LIFE_DAYS,
             SERIAL_NUMBER_CONTROL_CODE,
             START_AUTO_SERIAL_NUMBER,
             AUTO_SERIAL_ALPHA_PREFIX,
             SOURCE_TYPE,
             SOURCE_ORGANIZATION_ID,
             SOURCE_SUBINVENTORY,
             EXPENSE_ACCOUNT,
             ENCUMBRANCE_ACCOUNT,
             RESTRICT_SUBINVENTORIES_CODE,
             UNIT_WEIGHT,
             WEIGHT_UOM_CODE,
             VOLUME_UOM_CODE,
             UNIT_VOLUME,
             RESTRICT_LOCATORS_CODE,
             LOCATION_CONTROL_CODE,
             SHRINKAGE_RATE,
             ACCEPTABLE_EARLY_DAYS,
             PLANNING_TIME_FENCE_CODE,
             DEMAND_TIME_FENCE_CODE,
             LEAD_TIME_LOT_SIZE,
             STD_LOT_SIZE,
             CUM_MANUFACTURING_LEAD_TIME,
             OVERRUN_PERCENTAGE,
             ACCEPTABLE_RATE_INCREASE,
             ACCEPTABLE_RATE_DECREASE,
             CUMULATIVE_TOTAL_LEAD_TIME,
             PLANNING_TIME_FENCE_DAYS,
             DEMAND_TIME_FENCE_DAYS,
             END_ASSEMBLY_PEGGING_FLAG,
             PLANNING_EXCEPTION_SET,
             BOM_ITEM_TYPE,
             PICK_COMPONENTS_FLAG,
             REPLENISH_TO_ORDER_FLAG,
             BASE_ITEM_ID,
             ATP_COMPONENTS_FLAG,
             ATP_FLAG,
             FIXED_LEAD_TIME,
             VARIABLE_LEAD_TIME,
             WIP_SUPPLY_LOCATOR_ID,
             WIP_SUPPLY_TYPE,
             WIP_SUPPLY_SUBINVENTORY,
             PRIMARY_UOM_CODE,
             PRIMARY_UNIT_OF_MEASURE,
             ALLOWED_UNITS_LOOKUP_CODE,
             COST_OF_SALES_ACCOUNT,
             SALES_ACCOUNT,
             DEFAULT_INCLUDE_IN_ROLLUP_FLAG,
             INVENTORY_ITEM_STATUS_CODE,
             INVENTORY_PLANNING_CODE,
             PLANNER_CODE,
             PLANNING_MAKE_BUY_CODE,
             FIXED_LOT_MULTIPLIER,
             ROUNDING_CONTROL_TYPE,
             CARRYING_COST,
             POSTPROCESSING_LEAD_TIME,
             PREPROCESSING_LEAD_TIME,
             FULL_LEAD_TIME,
             ORDER_COST,
             MRP_SAFETY_STOCK_PERCENT,
             MRP_SAFETY_STOCK_CODE,
             MIN_MINMAX_QUANTITY,
             MAX_MINMAX_QUANTITY,
             MINIMUM_ORDER_QUANTITY,
             FIXED_ORDER_QUANTITY,
             FIXED_DAYS_SUPPLY,
             MAXIMUM_ORDER_QUANTITY,
             ATP_RULE_ID,
             PICKING_RULE_ID,
             RESERVABLE_TYPE,
             POSITIVE_MEASUREMENT_ERROR,
             NEGATIVE_MEASUREMENT_ERROR,
             ENGINEERING_ECN_CODE,
             ENGINEERING_ITEM_ID,
             ENGINEERING_DATE,
             SERVICE_STARTING_DELAY,
             SERVICEABLE_COMPONENT_FLAG,
             SERVICEABLE_PRODUCT_FLAG,
             BASE_WARRANTY_SERVICE_ID,
             PAYMENT_TERMS_ID,
             PREVENTIVE_MAINTENANCE_FLAG,
             PRIMARY_SPECIALIST_ID,
             SECONDARY_SPECIALIST_ID,
             SERVICEABLE_ITEM_CLASS_ID,
             TIME_BILLABLE_FLAG,
             MATERIAL_BILLABLE_FLAG,
             EXPENSE_BILLABLE_FLAG,
             PRORATE_SERVICE_FLAG,
             COVERAGE_SCHEDULE_ID,
             SERVICE_DURATION_PERIOD_CODE,
             SERVICE_DURATION,
             MAX_WARRANTY_AMOUNT,
             RESPONSE_TIME_PERIOD_CODE,
             RESPONSE_TIME_VALUE,
             NEW_REVISION_CODE,
             TAX_CODE,
             MUST_USE_APPROVED_VENDOR_FLAG,
             SAFETY_STOCK_BUCKET_DAYS,
             AUTO_REDUCE_MPS,
             COSTING_ENABLED_FLAG,
             INVOICEABLE_ITEM_FLAG,
             INVOICE_ENABLED_FLAG,
             OUTSIDE_OPERATION_FLAG,
             OUTSIDE_OPERATION_UOM_TYPE,
             AUTO_CREATED_CONFIG_FLAG,
             CYCLE_COUNT_ENABLED_FLAG,
             MODEL_CONFIG_CLAUSE_NAME,
             SHIP_MODEL_COMPLETE_FLAG,
             MRP_PLANNING_CODE,
             RETURN_INSPECTION_REQUIREMENT,
             REQUEST_ID,
             PROGRAM_APPLICATION_ID,
             PROGRAM_ID,
             PROGRAM_UPDATE_DATE,
             REPETITIVE_PLANNING_FLAG, /*NP 13SEP94 Added this column*/
             QTY_RCV_EXCEPTION_CODE,   /*NP 12OCT94 Added this column*/
             MRP_CALCULATE_ATP_FLAG,   /*NP 12OCT94 Added this column*/
             ITEM_TYPE,                /*NP 12OCT94 Added this column*/
             WARRANTY_VENDOR_ID,       /*NP 12OCT94 Added this column*/
             ATO_FORECAST_CONTROL,     /*NP 10OCT94 Added this column*/
             RELEASE_TIME_FENCE_CODE,  /*NP 19AUG96 Added these 8 columns*/
             RELEASE_TIME_FENCE_DAYS,
             CONTAINER_ITEM_FLAG,
             CONTAINER_TYPE_CODE,
             INTERNAL_VOLUME,
             MAXIMUM_LOAD_WEIGHT,
             MINIMUM_FILL_PERCENT,
             VEHICLE_ITEM_FLAG,
             CHECK_SHORTAGES_FLAG,     /*CK 21MAY98 Added column*/
             EFFECTIVITY_CONTROL
   ,          OVERCOMPLETION_TOLERANCE_TYPE
   ,          OVERCOMPLETION_TOLERANCE_VALUE
   ,          OVER_SHIPMENT_TOLERANCE
   ,          UNDER_SHIPMENT_TOLERANCE
   ,          OVER_RETURN_TOLERANCE
   ,          UNDER_RETURN_TOLERANCE
   ,          EQUIPMENT_TYPE
   ,          RECOVERED_PART_DISP_CODE
   ,          DEFECT_TRACKING_ON_FLAG
   ,          EVENT_FLAG
   ,          ELECTRONIC_FLAG
   ,          DOWNLOADABLE_FLAG
   ,          VOL_DISCOUNT_EXEMPT_FLAG
   ,          COUPON_EXEMPT_FLAG
   ,          COMMS_NL_TRACKABLE_FLAG
   ,          ASSET_CREATION_CODE
   ,          COMMS_ACTIVATION_REQD_FLAG
   ,          ORDERABLE_ON_WEB_FLAG
   ,          BACK_ORDERABLE_FLAG
   ,         WEB_STATUS
   ,         INDIVISIBLE_FLAG
   ,          DIMENSION_UOM_CODE
   ,          UNIT_LENGTH
   ,          UNIT_WIDTH
   ,          UNIT_HEIGHT
   ,          BULK_PICKED_FLAG
   ,          LOT_STATUS_ENABLED
   ,          DEFAULT_LOT_STATUS_ID
   ,          SERIAL_STATUS_ENABLED
   ,          DEFAULT_SERIAL_STATUS_ID
   ,          LOT_SPLIT_ENABLED
   ,          LOT_MERGE_ENABLED
   ,          INVENTORY_CARRY_PENALTY
   ,          OPERATION_SLACK_PENALTY
   ,          FINANCING_ALLOWED_FLAG
   ,  EAM_ITEM_TYPE
   ,  EAM_ACTIVITY_TYPE_CODE
   ,  EAM_ACTIVITY_CAUSE_CODE
   ,  EAM_ACT_NOTIFICATION_FLAG
   ,  EAM_ACT_SHUTDOWN_STATUS
   ,  DUAL_UOM_CONTROL
   ,  SECONDARY_UOM_CODE
   ,  DUAL_UOM_DEVIATION_HIGH
   ,  DUAL_UOM_DEVIATION_LOW
   --
   ,  SERVICE_ITEM_FLAG
   ,  VENDOR_WARRANTY_FLAG
   ,  USAGE_ITEM_FLAG
   --
   ,  CONTRACT_ITEM_TYPE_CODE
   ,  SUBSCRIPTION_DEPEND_FLAG
   --
   ,  SERV_REQ_ENABLED_CODE
   ,  SERV_BILLING_ENABLED_FLAG
   ,  SERV_IMPORTANCE_LEVEL
   ,  PLANNED_INV_POINT_FLAG
   ,  LOT_TRANSLATE_ENABLED
   ,  DEFAULT_SO_SOURCE_TYPE
   ,  CREATE_SUPPLY_FLAG
   ,  SUBSTITUTION_WINDOW_CODE
   ,  SUBSTITUTION_WINDOW_DAYS
--Added as part of 11.5.9
   ,  LOT_SUBSTITUTION_ENABLED
   ,  MINIMUM_LICENSE_QUANTITY
   ,  EAM_ACTIVITY_SOURCE_CODE
   ,  IB_ITEM_INSTANCE_CLASS
   ,  CONFIG_MODEL_TYPE
   --2740503: Lifecycle-phase introduced.
   ,  LIFECYCLE_ID
   ,  CURRENT_PHASE_ID
--Added as part of 11.5.10
   ,  TRACKING_QUANTITY_IND
   ,  ONT_PRICING_QTY_SOURCE
   ,  SECONDARY_DEFAULT_IND
   ,  CONFIG_ORGS
   ,  CONFIG_MATCH
   ,VMI_MINIMUM_UNITS
   ,VMI_MINIMUM_DAYS
   ,VMI_MAXIMUM_UNITS
   ,VMI_MAXIMUM_DAYS
   ,VMI_FIXED_ORDER_QUANTITY
   ,SO_AUTHORIZATION_FLAG
   ,CONSIGNED_FLAG
   ,ASN_AUTOEXPIRE_FLAG
   ,VMI_FORECAST_TYPE
   ,FORECAST_HORIZON
   ,EXCLUDE_FROM_BUDGET_FLAG
   ,DAYS_TGT_INV_SUPPLY
   ,DAYS_TGT_INV_WINDOW
   ,DAYS_MAX_INV_SUPPLY
   ,DAYS_MAX_INV_WINDOW
   ,DRP_PLANNED_FLAG
   ,CRITICAL_COMPONENT_FLAG
   ,CONTINOUS_TRANSFER
   ,CONVERGENCE
   ,DIVERGENCE
/* Start Bug 3713912 */
   ,LOT_DIVISIBLE_FLAG
   ,GRADE_CONTROL_FLAG
   ,DEFAULT_GRADE
   ,CHILD_LOT_FLAG
   ,PARENT_CHILD_GENERATION_FLAG
   ,CHILD_LOT_PREFIX
   ,CHILD_LOT_STARTING_NUMBER
   ,CHILD_LOT_VALIDATION_FLAG
   ,COPY_LOT_ATTRIBUTE_FLAG
   ,RECIPE_ENABLED_FLAG
   ,PROCESS_QUALITY_ENABLED_FLAG
   ,PROCESS_EXECUTION_ENABLED_FLAG
   ,PROCESS_COSTING_ENABLED_FLAG
   ,PROCESS_SUPPLY_SUBINVENTORY
   ,PROCESS_SUPPLY_LOCATOR_ID
   ,PROCESS_YIELD_SUBINVENTORY
   ,PROCESS_YIELD_LOCATOR_ID
   ,HAZARDOUS_MATERIAL_FLAG
   ,CAS_NUMBER
   ,RETEST_INTERVAL
   ,EXPIRATION_ACTION_INTERVAL
   ,EXPIRATION_ACTION_CODE
   ,MATURITY_DAYS
   ,HOLD_DAYS
/* End Bug 3713912 */
/*  Bug 4224512 Updating the object version number - Anmurali */
   ,OBJECT_VERSION_NUMBER
   ,CHARGE_PERIODICITY_CODE
   ,OUTSOURCED_ASSEMBLY
   ,SUBCONTRACTING_COMPONENT
   ,REPAIR_PROGRAM
   ,REPAIR_LEADTIME
   ,PREPOSITION_POINT
   ,REPAIR_YIELD
 /* New attrs for R12 FPC */
   ,GDSN_OUTBOUND_ENABLED_FLAG
   ,TRADE_ITEM_DESCRIPTOR
   ,STYLE_ITEM_FLAG
   ,STYLE_ITEM_ID
      -- Serial_Tagging Enh -- bug 9913552
   ,serial_tagging_flag

   )
   SELECT
      I.INVENTORY_ITEM_ID
   ,  I.ORGANIZATION_ID
   ,     NVL(I.LAST_UPDATE_DATE, l_sysdate),
         user_id,       /* last_updated_by */
         NVL(I.CREATION_DATE, l_sysdate),
         user_id,       /* created_by */
         login_id,      /* last_update_login */
             I.SUMMARY_FLAG,
             I.ENABLED_FLAG,
--             I.START_DATE_ACTIVE,          Commented for Bug: 4457440
--             I.END_DATE_ACTIVE,            Commented for Bug: 4457440
             I.DESCRIPTION,
             I.BUYER_ID,
             I.ACCOUNTING_RULE_ID,
             I.INVOICING_RULE_ID,
             I.SEGMENT1,
             I.SEGMENT2,
             I.SEGMENT3,
             I.SEGMENT4,
             I.SEGMENT5,
             I.SEGMENT6,
             I.SEGMENT7,
             I.SEGMENT8,
             I.SEGMENT9,
             I.SEGMENT10,
             I.SEGMENT11,
             I.SEGMENT12,
             I.SEGMENT13,
             I.SEGMENT14,
             I.SEGMENT15,
             I.SEGMENT16,
             I.SEGMENT17,
             I.SEGMENT18,
             I.SEGMENT19,
             I.SEGMENT20,
             I.ATTRIBUTE_CATEGORY,
             I.ATTRIBUTE1,
             I.ATTRIBUTE2,
             I.ATTRIBUTE3,
             I.ATTRIBUTE4,
             I.ATTRIBUTE5,
             I.ATTRIBUTE6,
             I.ATTRIBUTE7,
             I.ATTRIBUTE8,
             I.ATTRIBUTE9,
             I.ATTRIBUTE10,
             I.ATTRIBUTE11,
             I.ATTRIBUTE12,
             I.ATTRIBUTE13,
             I.ATTRIBUTE14,
             I.ATTRIBUTE15,
/* Start Bug 3713912 */
	     I.ATTRIBUTE16,
	     I.ATTRIBUTE17,
	     I.ATTRIBUTE18,
	     I.ATTRIBUTE19,
	     I.ATTRIBUTE20,
	     I.ATTRIBUTE21,
	     I.ATTRIBUTE22,
	     I.ATTRIBUTE23,
	     I.ATTRIBUTE24,
	     I.ATTRIBUTE25,
	     I.ATTRIBUTE26,
	     I.ATTRIBUTE27,
	     I.ATTRIBUTE28,
	     I.ATTRIBUTE29,
	     I.ATTRIBUTE30,
/* End Bug 3713912 */
             I.GLOBAL_ATTRIBUTE_CATEGORY,
             I.GLOBAL_ATTRIBUTE1,
             I.GLOBAL_ATTRIBUTE2,
             I.GLOBAL_ATTRIBUTE3,
             I.GLOBAL_ATTRIBUTE4,
             I.GLOBAL_ATTRIBUTE5,
             I.GLOBAL_ATTRIBUTE6,
             I.GLOBAL_ATTRIBUTE7,
             I.GLOBAL_ATTRIBUTE8,
             I.GLOBAL_ATTRIBUTE9,
             I.GLOBAL_ATTRIBUTE10,
             I.GLOBAL_ATTRIBUTE11,
             I.GLOBAL_ATTRIBUTE12,
             I.GLOBAL_ATTRIBUTE13,
             I.GLOBAL_ATTRIBUTE14,
             I.GLOBAL_ATTRIBUTE15,
             I.GLOBAL_ATTRIBUTE16,
             I.GLOBAL_ATTRIBUTE17,
             I.GLOBAL_ATTRIBUTE18,
             I.GLOBAL_ATTRIBUTE19,
             I.GLOBAL_ATTRIBUTE20,
             I.PURCHASING_ITEM_FLAG,
             I.SHIPPABLE_ITEM_FLAG,
             I.CUSTOMER_ORDER_FLAG,
             I.INTERNAL_ORDER_FLAG,
             I.INVENTORY_ITEM_FLAG,
             I.ENG_ITEM_FLAG,
             I.INVENTORY_ASSET_FLAG,
             I.PURCHASING_ENABLED_FLAG,
             I.CUSTOMER_ORDER_ENABLED_FLAG,
             I.INTERNAL_ORDER_ENABLED_FLAG,
             I.SO_TRANSACTIONS_FLAG,
             I.MTL_TRANSACTIONS_ENABLED_FLAG,
             I.STOCK_ENABLED_FLAG,
             I.BOM_ENABLED_FLAG,
             I.BUILD_IN_WIP_FLAG,
             I.REVISION_QTY_CONTROL_CODE,
             I.ITEM_CATALOG_GROUP_ID,
             I.CATALOG_STATUS_FLAG,
             I.RETURNABLE_FLAG,
             I.DEFAULT_SHIPPING_ORG,
             I.COLLATERAL_FLAG,
             I.TAXABLE_FLAG,
             I.PURCHASING_TAX_CODE,
             I.ALLOW_ITEM_DESC_UPDATE_FLAG,
             I.INSPECTION_REQUIRED_FLAG,
             I.RECEIPT_REQUIRED_FLAG,
             I.MARKET_PRICE,
             I.HAZARD_CLASS_ID,
             I.RFQ_REQUIRED_FLAG,
             I.QTY_RCV_TOLERANCE,
             I.LIST_PRICE_PER_UNIT,
             I.UN_NUMBER_ID,
             I.PRICE_TOLERANCE_PERCENT,
             I.ASSET_CATEGORY_ID,
             I.ROUNDING_FACTOR,
             I.UNIT_OF_ISSUE,
             I.ENFORCE_SHIP_TO_LOCATION_CODE,
             I.ALLOW_SUBSTITUTE_RECEIPTS_FLAG,
             I.ALLOW_UNORDERED_RECEIPTS_FLAG,
             I.ALLOW_EXPRESS_DELIVERY_FLAG,
             I.DAYS_EARLY_RECEIPT_ALLOWED,
             I.DAYS_LATE_RECEIPT_ALLOWED,
             I.RECEIPT_DAYS_EXCEPTION_CODE,
             I.RECEIVING_ROUTING_ID,
             I.INVOICE_CLOSE_TOLERANCE,
             I.RECEIVE_CLOSE_TOLERANCE,
             I.AUTO_LOT_ALPHA_PREFIX,
             I.START_AUTO_LOT_NUMBER,
             I.LOT_CONTROL_CODE,
             I.SHELF_LIFE_CODE,
             I.SHELF_LIFE_DAYS,
             I.SERIAL_NUMBER_CONTROL_CODE,
             I.START_AUTO_SERIAL_NUMBER,
             I.AUTO_SERIAL_ALPHA_PREFIX,
             I.SOURCE_TYPE,
             I.SOURCE_ORGANIZATION_ID,
             I.SOURCE_SUBINVENTORY,
             I.EXPENSE_ACCOUNT,
             I.ENCUMBRANCE_ACCOUNT,
             I.RESTRICT_SUBINVENTORIES_CODE,
             I.UNIT_WEIGHT,
             I.WEIGHT_UOM_CODE,
             I.VOLUME_UOM_CODE,
             I.UNIT_VOLUME,
             I.RESTRICT_LOCATORS_CODE,
             I.LOCATION_CONTROL_CODE,
             I.SHRINKAGE_RATE,
             I.ACCEPTABLE_EARLY_DAYS,
             I.PLANNING_TIME_FENCE_CODE,
             I.DEMAND_TIME_FENCE_CODE,
--Bug: 2473633
---          I.LEAD_TIME_LOT_SIZE,
             decode(I.LEAD_TIME_LOT_SIZE, NULL,decode(I.STD_LOT_SIZE,NULL,1,I.STD_LOT_SIZE), I.LEAD_TIME_LOT_SIZE),
--Bug: 2473633 ended.
             I.STD_LOT_SIZE,
             I.CUM_MANUFACTURING_LEAD_TIME,
             I.OVERRUN_PERCENTAGE,
             I.ACCEPTABLE_RATE_INCREASE,
             I.ACCEPTABLE_RATE_DECREASE,
             I.CUMULATIVE_TOTAL_LEAD_TIME,
             I.PLANNING_TIME_FENCE_DAYS,
             I.DEMAND_TIME_FENCE_DAYS,
             I.END_ASSEMBLY_PEGGING_FLAG,
             I.PLANNING_EXCEPTION_SET,
             I.BOM_ITEM_TYPE,
             I.PICK_COMPONENTS_FLAG,
             I.REPLENISH_TO_ORDER_FLAG,
             I.BASE_ITEM_ID,
             I.ATP_COMPONENTS_FLAG,
             I.ATP_FLAG,
             I.FIXED_LEAD_TIME,
             I.VARIABLE_LEAD_TIME,
             I.WIP_SUPPLY_LOCATOR_ID,
             I.WIP_SUPPLY_TYPE,
             I.WIP_SUPPLY_SUBINVENTORY,
             I.PRIMARY_UOM_CODE,
             I.PRIMARY_UNIT_OF_MEASURE,
             I.ALLOWED_UNITS_LOOKUP_CODE,
             I.COST_OF_SALES_ACCOUNT,
             I.SALES_ACCOUNT,
             I.DEFAULT_INCLUDE_IN_ROLLUP_FLAG,
             I.INVENTORY_ITEM_STATUS_CODE,
             I.INVENTORY_PLANNING_CODE,
             I.PLANNER_CODE,
             I.PLANNING_MAKE_BUY_CODE,
             I.FIXED_LOT_MULTIPLIER,
             I.ROUNDING_CONTROL_TYPE,
             I.CARRYING_COST,
             I.POSTPROCESSING_LEAD_TIME,
             I.PREPROCESSING_LEAD_TIME,
             I.FULL_LEAD_TIME,
             I.ORDER_COST,
             I.MRP_SAFETY_STOCK_PERCENT,
             I.MRP_SAFETY_STOCK_CODE,
             I.MIN_MINMAX_QUANTITY,
             I.MAX_MINMAX_QUANTITY,
             I.MINIMUM_ORDER_QUANTITY,
             I.FIXED_ORDER_QUANTITY,
             I.FIXED_DAYS_SUPPLY,
             I.MAXIMUM_ORDER_QUANTITY,
             I.ATP_RULE_ID,
             I.PICKING_RULE_ID,
             I.RESERVABLE_TYPE,
             I.POSITIVE_MEASUREMENT_ERROR,
             I.NEGATIVE_MEASUREMENT_ERROR,
             I.ENGINEERING_ECN_CODE,
             I.ENGINEERING_ITEM_ID,
             I.ENGINEERING_DATE,
             I.SERVICE_STARTING_DELAY,
             I.SERVICEABLE_COMPONENT_FLAG,
             I.SERVICEABLE_PRODUCT_FLAG,
             I.BASE_WARRANTY_SERVICE_ID,
             I.PAYMENT_TERMS_ID,
             I.PREVENTIVE_MAINTENANCE_FLAG,
             I.PRIMARY_SPECIALIST_ID,
             I.SECONDARY_SPECIALIST_ID,
             I.SERVICEABLE_ITEM_CLASS_ID,
             I.TIME_BILLABLE_FLAG,
             I.MATERIAL_BILLABLE_FLAG,
             I.EXPENSE_BILLABLE_FLAG,
             I.PRORATE_SERVICE_FLAG,
             I.COVERAGE_SCHEDULE_ID,
             I.SERVICE_DURATION_PERIOD_CODE,
             I.SERVICE_DURATION,
             I.MAX_WARRANTY_AMOUNT,
             I.RESPONSE_TIME_PERIOD_CODE,
             I.RESPONSE_TIME_VALUE,
             I.NEW_REVISION_CODE,
             I.TAX_CODE,
             I.MUST_USE_APPROVED_VENDOR_FLAG,
             I.SAFETY_STOCK_BUCKET_DAYS,
             I.AUTO_REDUCE_MPS,
             I.COSTING_ENABLED_FLAG,
             I.INVOICEABLE_ITEM_FLAG,
             I.INVOICE_ENABLED_FLAG,
             I.OUTSIDE_OPERATION_FLAG,
             I.OUTSIDE_OPERATION_UOM_TYPE,
             I.AUTO_CREATED_CONFIG_FLAG,
             I.CYCLE_COUNT_ENABLED_FLAG,
             I.MODEL_CONFIG_CLAUSE_NAME,
             I.SHIP_MODEL_COMPLETE_FLAG,
             I.MRP_PLANNING_CODE,
             I.RETURN_INSPECTION_REQUIREMENT,
   req_id,
   prg_appid,
   prg_id,
   l_sysdate,
             I.REPETITIVE_PLANNING_FLAG,
             I.QTY_RCV_EXCEPTION_CODE,   /*NP 12OCT94 Added this column*/
             I.MRP_CALCULATE_ATP_FLAG,   /*NP 12OCT94 Added this column*/
             I.ITEM_TYPE,                /*NP 12OCT94 Added this column*/
             I.WARRANTY_VENDOR_ID,       /*NP 12OCT94 Added this column*/
             I.ATO_FORECAST_CONTROL,
             I.RELEASE_TIME_FENCE_CODE,
             I.RELEASE_TIME_FENCE_DAYS,
             I.CONTAINER_ITEM_FLAG,
             I.CONTAINER_TYPE_CODE,
             I.INTERNAL_VOLUME,
             I.MAXIMUM_LOAD_WEIGHT,
             I.MINIMUM_FILL_PERCENT,
             I.VEHICLE_ITEM_FLAG,
             I.CHECK_SHORTAGES_FLAG,     /*CK 21MAY98 Added column*/
             I.EFFECTIVITY_CONTROL
   ,          I.OVERCOMPLETION_TOLERANCE_TYPE
   ,          I.OVERCOMPLETION_TOLERANCE_VALUE
   ,          I.OVER_SHIPMENT_TOLERANCE
   ,          I.UNDER_SHIPMENT_TOLERANCE
   ,          I.OVER_RETURN_TOLERANCE
   ,          I.UNDER_RETURN_TOLERANCE
   ,          I.EQUIPMENT_TYPE
   ,          I.RECOVERED_PART_DISP_CODE
   ,          I.DEFECT_TRACKING_ON_FLAG
   ,          I.EVENT_FLAG
   ,          I.ELECTRONIC_FLAG
   ,          I.DOWNLOADABLE_FLAG
   ,          I.VOL_DISCOUNT_EXEMPT_FLAG
   ,          I.COUPON_EXEMPT_FLAG
   ,          I.COMMS_NL_TRACKABLE_FLAG
   ,          I.ASSET_CREATION_CODE
   ,          I.COMMS_ACTIVATION_REQD_FLAG
   ,          I.ORDERABLE_ON_WEB_FLAG
   ,          I.BACK_ORDERABLE_FLAG
   ,         I.WEB_STATUS
   ,         I.INDIVISIBLE_FLAG
   ,          I.DIMENSION_UOM_CODE
   ,          I.UNIT_LENGTH
   ,          I.UNIT_WIDTH
   ,          I.UNIT_HEIGHT
   ,          I.BULK_PICKED_FLAG
   ,          I.LOT_STATUS_ENABLED
   ,          I.DEFAULT_LOT_STATUS_ID
   ,          I.SERIAL_STATUS_ENABLED
   ,          I.DEFAULT_SERIAL_STATUS_ID
   ,          I.LOT_SPLIT_ENABLED
   ,          I.LOT_MERGE_ENABLED
   ,          I.INVENTORY_CARRY_PENALTY
   ,          I.OPERATION_SLACK_PENALTY
   ,          I.FINANCING_ALLOWED_FLAG
   ,  I.EAM_ITEM_TYPE
   ,  I.EAM_ACTIVITY_TYPE_CODE
   ,  I.EAM_ACTIVITY_CAUSE_CODE
   ,  I.EAM_ACT_NOTIFICATION_FLAG
   ,  I.EAM_ACT_SHUTDOWN_STATUS
   ,  I.DUAL_UOM_CONTROL
   ,  I.SECONDARY_UOM_CODE
   ,  I.DUAL_UOM_DEVIATION_HIGH
   ,  I.DUAL_UOM_DEVIATION_LOW
   --
   -- Service Item, Warranty, Usage flag attributes are dependent on
   -- and derived from Contract Item Type; supported for view only.
   ,  DECODE( I.CONTRACT_ITEM_TYPE_CODE,
              'SERVICE'      , 'Y',
              'WARRANTY'     , 'Y', 'N' )
   ,  DECODE( I.CONTRACT_ITEM_TYPE_CODE, 'WARRANTY', 'Y', 'N' )
   ,  DECODE( I.CONTRACT_ITEM_TYPE_CODE, 'USAGE', 'Y', NULL )
   --
   ,  I.CONTRACT_ITEM_TYPE_CODE
   ,  I.SUBSCRIPTION_DEPEND_FLAG
   --
   ,  I.SERV_REQ_ENABLED_CODE
   ,  I.SERV_BILLING_ENABLED_FLAG
   ,  I.SERV_IMPORTANCE_LEVEL
   ,  I.PLANNED_INV_POINT_FLAG
   ,  I.LOT_TRANSLATE_ENABLED
   ,  I.DEFAULT_SO_SOURCE_TYPE
   ,  I.CREATE_SUPPLY_FLAG
   ,  I.SUBSTITUTION_WINDOW_CODE
   ,  I.SUBSTITUTION_WINDOW_DAYS
   --Added as part of 11.5.9
   ,  I.LOT_SUBSTITUTION_ENABLED
   ,  I.MINIMUM_LICENSE_QUANTITY
   ,  I.EAM_ACTIVITY_SOURCE_CODE
   ,  I.IB_ITEM_INSTANCE_CLASS
   ,  I.CONFIG_MODEL_TYPE
   --2740503: Lifecycle-phase introduced.
   ,  I.LIFECYCLE_ID
   ,  I.CURRENT_PHASE_ID
   --Added as part of 11.5.10
   ,  I.TRACKING_QUANTITY_IND
   ,  I.ONT_PRICING_QTY_SOURCE
   ,  I.SECONDARY_DEFAULT_IND
   ,  I.CONFIG_ORGS
   ,  I.CONFIG_MATCH
,       I.VMI_MINIMUM_UNITS
,       I.VMI_MINIMUM_DAYS
,       I.VMI_MAXIMUM_UNITS
,       I.VMI_MAXIMUM_DAYS
,       I.VMI_FIXED_ORDER_QUANTITY
,       I.SO_AUTHORIZATION_FLAG
,       I.CONSIGNED_FLAG
,       I.ASN_AUTOEXPIRE_FLAG
,       I.VMI_FORECAST_TYPE
,       I.FORECAST_HORIZON
,       I.EXCLUDE_FROM_BUDGET_FLAG
,       I.DAYS_TGT_INV_SUPPLY
,       I.DAYS_TGT_INV_WINDOW
,       I.DAYS_MAX_INV_SUPPLY
,       I.DAYS_MAX_INV_WINDOW
,       I.DRP_PLANNED_FLAG
,       I.CRITICAL_COMPONENT_FLAG
,       I.CONTINOUS_TRANSFER
,       I.CONVERGENCE
,       I.DIVERGENCE
/* Start Bug 3713912 */
, 	I.LOT_DIVISIBLE_FLAG
,	I.GRADE_CONTROL_FLAG
,	I.DEFAULT_GRADE
,	I.CHILD_LOT_FLAG
,	I.PARENT_CHILD_GENERATION_FLAG
,	I.CHILD_LOT_PREFIX
,	I.CHILD_LOT_STARTING_NUMBER
,	I.CHILD_LOT_VALIDATION_FLAG
,	I.COPY_LOT_ATTRIBUTE_FLAG
,	I.RECIPE_ENABLED_FLAG
,	I.PROCESS_QUALITY_ENABLED_FLAG
,	I.PROCESS_EXECUTION_ENABLED_FLAG
,	I.PROCESS_COSTING_ENABLED_FLAG
,	I.PROCESS_SUPPLY_SUBINVENTORY
,	I.PROCESS_SUPPLY_LOCATOR_ID
,	I.PROCESS_YIELD_SUBINVENTORY
,	I.PROCESS_YIELD_LOCATOR_ID
,	I.HAZARDOUS_MATERIAL_FLAG
,	I.CAS_NUMBER
,	I.RETEST_INTERVAL
,       I.EXPIRATION_ACTION_INTERVAL
,       I.EXPIRATION_ACTION_CODE
,       I.MATURITY_DAYS
,       I.HOLD_DAYS
/* End Bug 3713912 */
/*  Bug 4224512 Updating the object version number - Anmurali */
,       1
,       I.CHARGE_PERIODICITY_CODE
,       I.OUTSOURCED_ASSEMBLY
,       I.SUBCONTRACTING_COMPONENT
,       I.REPAIR_PROGRAM
,       I.REPAIR_LEADTIME
,       I.PREPOSITION_POINT
,       I.REPAIR_YIELD
,	I.GDSN_OUTBOUND_ENABLED_FLAG
,	I.TRADE_ITEM_DESCRIPTOR
,	I.STYLE_ITEM_FLAG
,	I.STYLE_ITEM_ID
--serial_tagging enh -- bug 9913552
, Decode (INV_SERIAL_NUMBER_PUB.is_serial_tagged(p_inventory_item_id => I.inventory_item_id,
                                                 p_organization_id => I.organization_id),2,'Y','N')
   FROM
      MTL_SYSTEM_ITEMS_INTERFACE  I
   WHERE
           I.process_flag = l_process_flag_4
      AND  I.set_process_id = xset_id
      AND  I.transaction_type = l_transaction_type;

   IF l_inv_debug_level IN(101, 102) THEN
      INVPUTLI.info('INVPPROC.inproit_process_item: inserting into MSI_TL with xset_id = '||xset_id);
   END IF;

   -- R11.5 MLS

   INSERT INTO MTL_SYSTEM_ITEMS_TL
   (
    INVENTORY_ITEM_ID,
    ORGANIZATION_ID,
    LANGUAGE,
    SOURCE_LANG,
    DESCRIPTION,
    LONG_DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN
   )
   SELECT
    I.INVENTORY_ITEM_ID,
    I.ORGANIZATION_ID,
    L.LANGUAGE_CODE,
    userenv('LANG'),
    I.DESCRIPTION,
    I.LONG_DESCRIPTION,
    NVL(I.LAST_UPDATE_DATE, l_sysdate),
    user_id,       /* last_updated_by */
    NVL(I.CREATION_DATE, l_sysdate),
    user_id,       /* created_by */
    login_id       /* last_update_login */
   from  MTL_SYSTEM_ITEMS_INTERFACE I
      ,  FND_LANGUAGES  L
      ,  mtl_parameters mp
   where  I.process_flag = l_process_flag_4
     and  I.set_process_id = xset_id
     and  I.transaction_type = l_transaction_type
     and  L.INSTALLED_FLAG in ('I', 'B')
     /*Bug 5398775 Restrict child org creates*/
     and  I.Organization_Id = mp.Master_Organization_Id
     /*Bug 6983581 Performance Changes */
--   and  mp.master_organization_id = mp.organization_id;
     and  I.Organization_Id = mp.organization_id;

/*Bug: 4667452 Commneting out the following condition
     and  not exists
          ( select NULL
            from  MTL_SYSTEM_ITEMS_TL  T
            where  T.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
              and  T.ORGANIZATION_ID = I.ORGANIZATION_ID
              and  T.LANGUAGE = L.LANGUAGE_CODE
          );
End comment  Bug: 4667452*/

/*Bug 5398775 Create for child org with translations*/
INSERT INTO MTL_SYSTEM_ITEMS_TL
   (
    INVENTORY_ITEM_ID,
    ORGANIZATION_ID,
    LANGUAGE,
    SOURCE_LANG,
    DESCRIPTION,
    LONG_DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN
   )
   SELECT /*+ leading(I, MSITL) USE_NL(MSITL) */  /* Fix for bug#9678667 */
    I.INVENTORY_ITEM_ID,
    I.ORGANIZATION_ID,
    L.LANGUAGE_CODE,
    Decode(L.LANGUAGE_CODE, userenv('LANG'), userenv('LANG'), msitl.source_lang) Source_Lang,
    Decode(L.LANGUAGE_CODE, userenv('LANG'), I.DESCRIPTION, msitl.description) Description,
    Decode(L.LANGUAGE_CODE, userenv('LANG'), I.LONG_DESCRIPTION, msitl.long_description) Long_Description,
    NVL(I.LAST_UPDATE_DATE, l_sysdate),
    user_id,       --* last_updated_by
    NVL(I.CREATION_DATE, l_sysdate),
    user_id,       --* created_by
    login_id       --* last_update_login
   from  MTL_SYSTEM_ITEMS_INTERFACE I
      ,  MTL_SYSTEM_ITEMS_TL msitl
      ,  FND_LANGUAGES  L
  where   I.process_flag = l_process_flag_4
    and   I.set_process_id = xset_id
    and   I.transaction_type = l_transaction_type
    and   L.INSTALLED_FLAG in ('I', 'B')
    and   msitl.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
    and   msitl.ORGANIZATION_ID = (SELECT Master_Organization_Id
	 			  FROM	 Mtl_Parameters
				  WHERE	 Organization_Id = I.Organization_id)
    and   msitl.Language = l.language_code
    and   I.ORGANIZATION_ID IN (SELECT  Organization_Id
			       FROM    Mtl_Parameters
			       WHERE   Master_Organization_Id <> Organization_Id);

FOR cr IN c_ego_intf_rows LOOP
  UPDATE MTL_SYSTEM_ITEMS_TL
     SET DESCRIPTION = NVL(cr.column_value, DESCRIPTION),
         LAST_UPDATE_DATE = l_sysdate,
         LAST_UPDATED_BY = user_id,
         LAST_UPDATE_LOGIN = login_id
   WHERE inventory_item_id = cr.inventory_item_id
     AND organization_id = cr.organization_id
     AND language = cr.language;
END LOOP;


   IF l_inv_debug_level IN(101, 102) THEN
      INVPUTLI.info('INVPPROC.inproit_process_item: deleting from MDEV with xset_id = '||xset_id);
   END IF;

      -- Bug #1068191 (1031733)
      --
      delete from mtl_descr_element_values
      where inventory_item_id in
            ( select  inventory_item_id
              from  mtl_parameters MP,
                    MTL_SYSTEM_ITEMS_INTERFACE I
              where  I.process_flag = l_process_flag_4
                and  I.set_process_id = xset_id
                and  I.transaction_type = l_transaction_type
                and  I.item_catalog_group_id is not null
                and  I.organization_id = MP.organization_id
                and  I.organization_id = MP.master_organization_id
            );

      IF l_inv_debug_level IN(101, 102) THEN
         INVPUTLI.info('INVPPROC.inproit_process_item: inserting into MDEV with xset_id = '|| xset_id);
      END IF;

      table_name := 'MTL_DESCR_ELEMENT_VALUES';

      insert into MTL_DESCR_ELEMENT_VALUES
                (inventory_item_id,
                 element_name,
                 default_element_flag,
                 last_update_date,
                 last_updated_by,
                 creation_date,
                 created_by,
                 last_update_login,
                 request_id,
                 program_application_id,
                 program_id,
                 program_update_date,
                 element_sequence)
       select
             I.INVENTORY_ITEM_ID,
             MDE.ELEMENT_NAME,
             MDE.default_element_flag,
             NVL(I.LAST_UPDATE_DATE,l_sysdate),
             user_id,       /* last_updated_by */
             NVL(I.CREATION_DATE,l_sysdate),
             user_id,       /* created_by */
             login_id,      /* last_update_login */
             req_id,
             prg_appid,
             prg_id,
             l_sysdate,
             MDE.ELEMENT_SEQUENCE
      from   mtl_descriptive_elements MDE,
             mtl_parameters MP,
             mtl_system_items_interface I
      where  I.process_flag = l_process_flag_4
      and    I.set_process_id = xset_id
      and    I.transaction_type = l_transaction_type
      and    I.organization_id = MP.master_organization_id
      and    I.organization_id = MP.organization_id
      and    MDE.item_catalog_group_id = nvl(I.item_catalog_group_id,-999) ;

/*
** COSTING WILL BE HANDLED BY NEW COSTING FUNCTION
** This code was obsoleted.  Now removed in version 50.12 of this file
*/

/*
**   Copy the item revisions into the item revisions table
**   This does not cover the master record created for orphans
**   NP 08SEP94 Comment There is no Orphan case allowed anymore
**   with the Two_pass design
*/

      IF l_inv_debug_level IN(101, 102) THEN
         INVPUTLI.info('INVPPROC.inproit_process_item: inserting into MIR from MIRI');
      END IF;

      table_name := 'MTL_ITEM_REVISIONS';

      INSERT into MTL_ITEM_REVISIONS_B
      (      INVENTORY_ITEM_ID,
             ORGANIZATION_ID,
             REVISION,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             CREATION_DATE,
             CREATED_BY,
             LAST_UPDATE_LOGIN,
             CHANGE_NOTICE,
             ECN_INITIATION_DATE,
             IMPLEMENTATION_DATE,
             IMPLEMENTED_SERIAL_NUMBER,
             EFFECTIVITY_DATE,
             ATTRIBUTE_CATEGORY,
             ATTRIBUTE1,
             ATTRIBUTE2,
             ATTRIBUTE3,
             ATTRIBUTE4,
             ATTRIBUTE5,
             ATTRIBUTE6,
             ATTRIBUTE7,
             ATTRIBUTE8,
             ATTRIBUTE9,
             ATTRIBUTE10,
             ATTRIBUTE11,
             ATTRIBUTE12,
             ATTRIBUTE13,
             ATTRIBUTE14,
             ATTRIBUTE15,
             REQUEST_ID,
             PROGRAM_APPLICATION_ID,
             PROGRAM_ID,
             PROGRAM_UPDATE_DATE,
             REVISED_ITEM_SEQUENCE_ID,
             DESCRIPTION,
             OBJECT_VERSION_NUMBER,
             LIFECYCLE_ID,
             CURRENT_PHASE_ID,
             REVISION_ID,
             REVISION_LABEL,
             REVISION_REASON)
      SELECT
             r.INVENTORY_ITEM_ID,
             r.ORGANIZATION_ID,
             r.REVISION,
             r.LAST_UPDATE_DATE,
             r.LAST_UPDATED_BY,
             r.CREATION_DATE,
             r.CREATED_BY,
             r.LAST_UPDATE_LOGIN,
             r.CHANGE_NOTICE,
             r.ECN_INITIATION_DATE,
             r.IMPLEMENTATION_DATE,
             r.IMPLEMENTED_SERIAL_NUMBER,
             r.EFFECTIVITY_DATE,
             r.ATTRIBUTE_CATEGORY,
             r.ATTRIBUTE1,
             r.ATTRIBUTE2,
             r.ATTRIBUTE3,
             r.ATTRIBUTE4,
             r.ATTRIBUTE5,
             r.ATTRIBUTE6,
             r.ATTRIBUTE7,
             r.ATTRIBUTE8,
             r.ATTRIBUTE9,
             r.ATTRIBUTE10,
             r.ATTRIBUTE11,
             r.ATTRIBUTE12,
             r.ATTRIBUTE13,
             r.ATTRIBUTE14,
             r.ATTRIBUTE15,
             req_id,
             prg_appid,
             prg_id,
             l_sysdate,
             r.REVISED_ITEM_SEQUENCE_ID,
             r.DESCRIPTION,
             1 OBJECT_VERSION_NUMBER,
             r.LIFECYCLE_ID,
             r.CURRENT_PHASE_ID,
             r.REVISION_ID,
             r.REVISION_LABEL,
             r.REVISION_REASON
      FROM   MTL_ITEM_REVISIONS_INTERFACE  R
      WHERE  r.process_flag = l_process_flag_4
      AND    r.set_process_id = xset_id
      AND    r.transaction_type = l_transaction_type;


      INSERT INTO MTL_ITEM_REVISIONS_TL (
        INVENTORY_ITEM_ID,
        ORGANIZATION_ID,
        REVISION_ID,
        DESCRIPTION,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        LANGUAGE,
        SOURCE_LANG)
      SELECT r.INVENTORY_ITEM_ID,
             r.ORGANIZATION_ID,
             r.REVISION_ID,
             r.DESCRIPTION,
             r.CREATION_DATE,
             r.CREATED_BY,
             r.LAST_UPDATE_DATE,
             r.LAST_UPDATED_BY,
             r.LAST_UPDATE_LOGIN,
             L.LANGUAGE_CODE,
             USERENV('LANG')
      FROM  MTL_ITEM_REVISIONS_INTERFACE  r,
            FND_LANGUAGES L
      WHERE  r.process_flag     = l_process_flag_4
      AND    r.set_process_id   = xset_id
      AND    r.transaction_type = l_transaction_type
      and    L.INSTALLED_FLAG in ('I', 'B');
/* Bug: 4667452 Removing the following condition
      AND NOT EXISTS (SELECT NULL
                     FROM MTL_ITEM_REVISIONS_TL T
                     WHERE T.INVENTORY_ITEM_ID = r.INVENTORY_ITEM_ID
                     AND T.ORGANIZATION_ID     = r.ORGANIZATION_ID
                     AND T.REVISION_ID         = r.REVISION_ID
                     AND T.LANGUAGE            = L.LANGUAGE_CODE);
      End Bug: 4667452 */


/*NP 22AUG94 Commenting out the code for the following functionality
** If a master record was inserted for an orphan child record,
** we need to create a default
** record in mtl_item_revisions_interface in the
** master org (which is stored in last_updated_by
** The TWO-PASS approach makes it irrelevant
** Note the use of the last_updated_by who column
** This is initialized in INVPUTLI and holds the master_org_id
**NP 26SEP95 Deleted the commented out code in version 50.12
** To see it refer to a prior version
**INVPUTLI.info('INVPPROC: Skipped the orphan ins code in MTL_ITEM_REVISIONS');
*/

   -- create child orgs category assignment

   For Cat_Assign_Rec in Cat_Assign
   Loop
          INSERT INTO mtl_item_categories
            (   inventory_item_id,
                category_set_id,
                category_id,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                program_application_id,
                program_id,
                program_update_date,
                request_id,
                organization_id
              )
          SELECT
                Cat_Assign_Rec.ITEMID,
                s.category_set_id,
                s.category_id,
                l_sysdate,
                user_id,       -- last_updated_by
                l_sysdate,
                user_id,       -- created_by
                login_id,      --  last_update_login
                prg_appid,     --  program_application_id
                prg_id,        --  program_id
                l_sysdate,     --  program_update_date
                req_id,        --  request_id
                Cat_Assign_Rec.ORGID
          FROM  mtl_item_categories s,
                mtl_category_sets_b   d
          WHERE s.inventory_item_id = Cat_Assign_Rec.ITEMID
          AND   s.category_set_id   = d.category_set_id
          AND   s.organization_id   = Cat_Assign_Rec.MORG
          AND   (d.control_level     = 1
                 OR EXISTS
                 ( SELECT 'x'
                   FROM  mtl_default_category_sets  d
                   WHERE
                      d.category_set_id = s.category_set_id
                   AND
                      (d.functional_area_id = DECODE( Cat_Assign_Rec.INVFLAG, 'Y', 1, 0 )
                   OR d.functional_area_id = DECODE( Cat_Assign_Rec.PURFLAG, 'Y', 2, 0 )
                   OR d.functional_area_id = DECODE( Cat_Assign_Rec.INTFLAG, 'Y', 2, 0 )
                   OR d.functional_area_id = DECODE( Cat_Assign_Rec.MRPCODE, 6, 0, 3 )
                   OR d.functional_area_id = DECODE( Cat_Assign_Rec.SERVFLAG, 'Y', 4, 0 )
                   OR d.functional_area_id = DECODE( Cat_Assign_Rec.COSTFLAG, 'Y', 5, 0 )
                   OR d.functional_area_id = DECODE( Cat_Assign_Rec.ENGFLAG, 'Y', 6, 0 )
                   OR d.functional_area_id = DECODE( Cat_Assign_Rec.CUSTFLAG, 'Y', 7, 0 )
		             -- Add default Category assignment for GDSN Syndicated Items
       		       OR d.functional_area_id = DECODE( Cat_Assign_Rec.GDSNFLAG, 'Y',12,0)
                   OR d.functional_area_id = DECODE( NVL(Cat_Assign_Rec.EAMTYPE, 0), 0, 0, 9 )
                   OR d.functional_area_id =
                                        DECODE( Cat_Assign_Rec.CONTCODE,
                                                'SERVICE'      , 10,
                                                'WARRANTY'     , 10,
                                                'SUBSCRIPTION' , 10,
                                                'USAGE'        , 10, 0 )
                   OR d.functional_area_id =
                                        DECODE( Cat_Assign_Rec.CONTCODE,
                                                'SERVICE'      , 4,
                                                'WARRANTY'     , 4, 0 )
                   OR d.functional_area_id = DECODE( Cat_Assign_Rec.CUSTFLAG, 'Y', 11, 0 )
                   OR d.functional_area_id = DECODE( Cat_Assign_Rec.INTFLAG, 'Y', 11, 0 ))            ))
          AND   NOT EXISTS
                (SELECT 'already_exists'
                 FROM mtl_item_categories mic
                 WHERE mic.inventory_item_id = Cat_Assign_Rec.ITEMID
                 AND mic.organization_id = Cat_Assign_Rec.ORGID
                 AND mic.category_set_id = s.category_set_id);

   End Loop;

   --------------------------------------------------------
   -- Insert item assignments to default categories of the
   -- mandatory category sets for all functional areas.
   --------------------------------------------------------
   IF l_inv_debug_level IN(101, 102) THEN
      INVPUTLI.info('INVPPROC.inproit_process_item: inserting into MIC from MCS/MSII');
   END IF;

/*
  SQL Modified to fix 4869915
  Cartesian Join eliminated.
*/
/*
  Bug: 5050604 Added distinct
*/

   INSERT INTO mtl_item_categories
   (
     inventory_item_id
    ,organization_id
    ,category_set_id
    ,category_id
    ,last_update_date
    ,last_updated_by
    ,creation_date
    ,created_by
    ,last_update_login
    ,program_application_id
    ,program_id
    ,program_update_date
    ,request_id
   )
   SELECT DISTINCT
     m.inventory_item_id
    ,m.organization_id
    ,d.category_set_id
    ,s.default_category_id
    ,l_sysdate
    ,user_id       -- last_updated_by
    ,l_sysdate
    ,user_id       -- created_by
    ,login_id      --  last_update_login
    ,prg_appid     --  program_application_id
    ,prg_id        --  program_id
    ,l_sysdate     --  program_update_date
    ,req_id        --  request_id
   FROM  mtl_system_items_interface m
	,mtl_default_category_sets d
	,mtl_category_sets_b s
   WHERE
	m.transaction_type    = 'CREATE'
	AND m.process_flag    = l_process_flag_4
	AND m.set_process_id  = xset_id
	AND m.INVENTORY_ITEM_STATUS_CODE <> 'Pending'
	AND d.category_set_id = s.category_set_id
	AND s.default_category_id IS NOT NULL
	AND
	( -- which all functional areas apply
	   d.functional_area_id    = DECODE( m.INVENTORY_ITEM_FLAG, 'Y', 1, 0 )
	OR d.functional_area_id = DECODE( m.PURCHASING_ITEM_FLAG, 'Y', 2, 0 )
	OR d.functional_area_id = DECODE( m.INTERNAL_ORDER_FLAG, 'Y', 2, 0 )
	OR d.functional_area_id = DECODE( m.MRP_PLANNING_CODE, 6, 0, 3 )
	OR d.functional_area_id = DECODE( m.SERVICEABLE_PRODUCT_FLAG, 'Y', 4, 0 )
	OR d.functional_area_id = DECODE( m.COSTING_ENABLED_FLAG, 'Y', 5, 0 )
	OR d.functional_area_id = DECODE( m.ENG_ITEM_FLAG, 'Y', 6, 0 )
	OR d.functional_area_id = DECODE( m.CUSTOMER_ORDER_FLAG, 'Y', 7, 0 )
        -- Add default Category assignment for GDSN Syndicated Items
	OR d.functional_area_id = DECODE( m.GDSN_OUTBOUND_ENABLED_FLAG, 'Y',12,0)
	OR d.functional_area_id = DECODE( NVL(m.EAM_ITEM_TYPE, 0), 0, 0, 9 )
	OR d.functional_area_id =
		 DECODE( m.CONTRACT_ITEM_TYPE_CODE,
			 'SERVICE'      , 10,
			 'WARRANTY'     , 10,
			 'SUBSCRIPTION' , 10,
			 'USAGE'        , 10, 0 )
	OR d.functional_area_id =
	       DECODE( m.CONTRACT_ITEM_TYPE_CODE,
			 'SERVICE'      , 4,
			 'WARRANTY'     , 4, 0 )
	OR d.functional_area_id = DECODE( m.INTERNAL_ORDER_FLAG, 'Y', 11, 0 )
	OR d.functional_area_id = DECODE( m.CUSTOMER_ORDER_FLAG, 'Y', 11, 0 )
	)
	AND NOT EXISTS
	(SELECT  'x'
	FROM  mtl_item_categories mic
	WHERE mic.inventory_item_id = m.inventory_item_id
	AND mic.organization_id   = m.organization_id
	AND mic.category_set_id   = d.category_set_id  );

   --Bug: 5344163 Added this query for upward propogation
   --     of functional area Product Reporting
   /*If either the CO or IO flags are set to Org control then the Category Set too should be set to
   Org level. In that case we do not need this insert statement. Bug 9833451*/
   /*INSERT INTO mtl_item_categories
   (
     inventory_item_id
    ,organization_id
    ,category_set_id
    ,category_id
    ,last_update_date
    ,last_updated_by
    ,creation_date
    ,created_by
    ,last_update_login
    ,program_application_id
    ,program_id
    ,program_update_date
    ,request_id
   )
   SELECT --DISTINCT
     msi.inventory_item_id
    ,mp.organization_id
    ,mdcs.category_set_id
    ,mcs.default_category_id
    ,l_sysdate
    ,user_id       -- last_updated_by
    ,l_sysdate
    ,user_id       -- created_by
    ,login_id      --  last_update_login
    ,prg_appid     --  program_application_id
    ,prg_id        --  program_id
    ,l_sysdate     --  program_update_date
    ,req_id        --  request_id
   FROM  mtl_system_items_interface msi
	,mtl_default_category_sets mdcs
	,mtl_category_sets_b mcs
	,mtl_parameters mp
   WHERE
        msi.transaction_type    = 'CREATE'
        AND msi.process_flag    = l_process_flag_4
	AND msi.set_process_id  = xset_id
	AND msi.INVENTORY_ITEM_STATUS_CODE <> 'Pending'
	AND mdcs.category_set_id = mcs.category_set_id
	AND mp.master_organization_id = (select master_organization_id
	                                FROM mtl_parameters m
					where m.organization_id = msi.organization_id)
	AND mcs.default_category_id IS NOT NULL
	AND
	( -- which all functional areas apply
     	mdcs.functional_area_id = DECODE( msi.INTERNAL_ORDER_FLAG, 'Y', 11, 0 )
	OR mdcs.functional_area_id = DECODE( msi.CUSTOMER_ORDER_FLAG, 'Y', 11, 0 )
	)
	AND NOT EXISTS
	(SELECT  'x'
	FROM  mtl_item_categories mic
	WHERE mic.inventory_item_id = msi.inventory_item_id
	AND mic.organization_id   = mp.organization_id
	AND mic.category_set_id   = mdcs.category_set_id  )
	AND EXISTS
        ( SELECT 'x'
          FROM  mtl_system_items_b  i
          WHERE
                 i.inventory_item_id = msi.inventory_item_id
             AND i.organization_id   = mp.organization_id
        );
	*/
   ---------------------------------------------
   -- Insert into MTL_PENDING_ITEM_STATUS table
   ---------------------------------------------
   IF l_inv_debug_level IN(101, 102) THEN
      INVPUTLI.info('INVPPROC.inproit_process_item: inserting into mtl_pending_item_status');
   END IF;

   l_pending_flag    := 'N';
--   l_last_updated_by :=  0;
--   l_created_by      :=  0;

   INSERT INTO mtl_pending_item_status
   (
      INVENTORY_ITEM_ID,
            ORGANIZATION_ID,
            STATUS_CODE,
            EFFECTIVE_DATE,
            PENDING_FLAG,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            CREATION_DATE,
            CREATED_BY,
            IMPLEMENTED_DATE,
            --2740503: Lifecycle-phase introduced.
            LIFECYCLE_ID,
            PHASE_ID
   )
   select
     I.INVENTORY_ITEM_ID,
            I.ORGANIZATION_ID,
            I.INVENTORY_ITEM_STATUS_CODE,
            l_sysdate,
            l_pending_flag,
            l_sysdate,
            user_id,
            l_sysdate,
            user_id,
            l_sysdate,
            --2740503: Lifecycle-phase introduced.
            I.LIFECYCLE_ID,
            I.CURRENT_PHASE_ID
    from MTL_SYSTEM_ITEMS_INTERFACE I
    where I.process_flag = l_process_flag_4
      and I.set_process_id = xset_id
      and I.transaction_type = l_transaction_type;

/*
** For child records that are NOT orphans,
** we must insert child category records in mtl_item_categories
** for each category that its master is in.
** Default categories are assigned earlier..but for child records we also
** need to assign the categories that
** the parent has..and also make sure that we do not assign duplicate values
** because the parent may also have
** the default value that was assigned to child earlier.
**
**NP 26AUG94 commenting out for now ..REOPEN later when testing categories..
**   also..optimize it Also check if msii.created_by in (1,2) is
**   valid anymore with TWO_PASS design
**      This stmt is a BIG resource hog..have to fix it
**NP 06MAY96 Note that IOI  does not support categories
**   assignment in 10.4, 10.5, 10.6 anyway.
**   Only default category assignment for mandatory catg set is done by IOI in INVPPROB.pls.
**
**              insert into MTL_ITEM_CATEGORIES
**              (       inventory_item_id,
**                      category_set_id,
**                      category_id,
**                      last_update_date,
**                      last_updated_by,
**                      creation_date,
**                      created_by,
**                      last_update_login,
**                      request_id,
**                      program_application_id,
**                      program_id,
**                      program_update_date,
**                      organization_id
**              )
**              select
**                        msii.inventory_item_id,
**                        mic.category_set_id,
**                        mic.category_id,
**                        sysdate,
**                        user_id,
**                        sysdate,
**                        user_id,
**                        login_id,
**                      req_id,
**                      prg_appid,
**                      prg_id,
**                      sysdate,
**                      msii.organization_id
**              from    mtl_system_items_interface msii,
**                        mtl_item_categories mic,
**                      MTL_PARAMETERS MP
**                where  msii.process_flag = 4
**              and    msii.transaction_type = 'CREATE'
**              and    msii.created_by in (1,2)
**              and    mic.organization_id = msii.last_updated_by
**              and    mic.inventory_item_id = msii.inventory_item_id
**              and    msii.inventory_item_id not in
**                       (select mic2.inventory_item_id
**                      from mtl_item_categories mic2
**                     where mic2.category_set_id = mic.category_set_id
**                       and mic2.category_id = category_id
**                       and mic2.organization_id = msii.organization_id
**                       and mic2.inventory_item_id = msii.inventory_item_id);
*/


/*
** Insert a record into mtl_uom_conversions for items with
** specific UOM (allowed_units_lookup_code = 1)
*/

FOR UOM_process_rec IN UOM_Process LOOP

   IF ( UOM_process_rec.base_uom_flag = 'Y' ) THEN
      conversion_rate_temp := 1;
   ELSE
      select conversion_rate
        into conversion_rate_temp
      from mtl_uom_conversions
      where inventory_item_id = 0
        and uom_code = UOM_process_rec.PUOMCODE;
   END IF;

 l_default_conversion_flag := 'N';

 INSERT INTO mtl_uom_conversions
 (
   unit_of_measure,
   uom_code,
   uom_class,
   inventory_item_id,
   conversion_rate,
   default_conversion_flag,
   last_update_date,
   last_updated_by,
   creation_date,
   created_by
 )
 VALUES
 (
    UOM_process_rec.PUOM,
    UOM_process_rec.PUOMCODE,
    UOM_process_rec.UOMCL,
    UOM_process_rec.INV_ITEM_ID,
    conversion_rate_temp,
    l_default_conversion_flag,
    l_sysdate,
    user_id,
    l_sysdate,
    user_id
 );

END LOOP;

    /** Need to put in error handling within the loop
     ** cannot just put in status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'CAT_ID',
                                'MTL_ITEM_CATEGORIES_INTERFACE',
                                'BOM_OP_VALIDATION_ERR',
                                err_text);

     To be explored as an option**/


/*  26SEP95 Explored the created_by strategy that
**   was used to enhance performance
**  26SEP95 Removed the following from the statement above
**  This is obsolete since the TWO_PASS design assumes that the master is in
**  Also added the where not exists clause
**  And of course, removed mtl_parameters mp from the FROM clause
**
**  and  ((msii.ORGANIZATION_ID = MP.ORGANIZATION_ID) OR
**          ((MP.ORGANIZATION_ID =
**             (select MASTER_ORGANIZATION_ID
**              from   MTL_PARAMETERS MP
**              where  msii.ORGANIZATION_ID = MP.ORGANIZATION_ID)) and
**            msii.created_by = 0))
**
**  Finally moved it all into a cursor UOM_process so that individual rows
**  can get the values of conversion_type as needed
**  So can't really batch process this insert as in other cases.
**  This is a major fix to the code.
*/

   IF l_inv_debug_level IN(101, 102) THEN
      INVPUTLI.info('INVPPROC: Finished inserting in mtl_uom_conversions');
   END IF;



/*
** call costing package to do costing
** NP 06MAY96 Added new parameter xset_id to call to CSTPIICP
*/

   IF l_inv_debug_level IN(101, 102) THEN
      INVPUTLI.info('INVPPROC: Calling Costing procedure CSTPIICP');
   END IF;

        INVPCOII.CSTPIICP(user_id,
                          login_id,
                          req_id,
                          prg_id,
                          prg_appid,
                          return_code,
                          return_err,
                          xset_id);

        if (return_code <> 0) then
           raise COST_ERR;
        end if;

--Bug: 3033702 Added for EGO grants on item
--Moved support of user attribs code to INVEGRVB
--INVPUTLI.info('INVPPROC: Calling Ego procedure Insert_Grants_And_UserAttr');
--INV_EGO_REVISION_VALIDATE.Insert_Grants_And_UserAttr(xset_id);
--Bug: 3033702 Ended
  INV_EGO_REVISION_VALIDATE.Create_New_Item_Request(xset_id);
     --Bug:3777954 added call to new processing for NIR required items (for EGO)

   --
   -- The last step: set process_flags to 7
   --

        table_name := 'MTL_SYSTEM_ITEMS_INTERFACE';

        update MTL_SYSTEM_ITEMS_INTERFACE
        set process_flag = l_process_flag_7,
          request_id = nvl(request_id,req_id),
          program_application_id = nvl(program_application_id,prg_appid),
          PROGRAM_ID = nvl(PROGRAM_ID,prg_id),
          PROGRAM_UPDATE_DATE = nvl(PROGRAM_UPDATE_DATE,sysdate),
          LAST_UPDATE_DATE = nvl(LAST_UPDATE_DATE,sysdate),
          LAST_UPDATED_BY = nvl(LAST_UPDATED_BY,user_id),
          CREATION_DATE = nvl(CREATION_DATE,sysdate),
          CREATED_BY = nvl(CREATED_BY,user_id),
          LAST_UPDATE_LOGIN = nvl(LAST_UPDATE_LOGIN,login_id)
        where process_flag = l_process_flag_4
        and   set_process_id = xset_id;

        table_name := 'MTL_ITEM_REVISIONS_INTERFACE';

        update MTL_ITEM_REVISIONS_INTERFACE
        set process_flag = l_process_flag_7,
          request_id = nvl(request_id,req_id),
          program_application_id = nvl(program_application_id,prg_appid),
          PROGRAM_ID = nvl(PROGRAM_ID,prg_id),
          PROGRAM_UPDATE_DATE = nvl(PROGRAM_UPDATE_DATE,sysdate),
          LAST_UPDATE_DATE = nvl(LAST_UPDATE_DATE,sysdate),
          LAST_UPDATED_BY = nvl(LAST_UPDATED_BY,user_id),
          CREATION_DATE = nvl(CREATION_DATE,sysdate),
          CREATED_BY = nvl(CREATED_BY,user_id),
          LAST_UPDATE_LOGIN = nvl(LAST_UPDATE_LOGIN,login_id)
        where process_flag = l_process_flag_4
        and   set_process_id = xset_id;

	--Bug 5435229 Call appy_default_uda_values
        INV_EGO_REVISION_VALIDATE.apply_default_uda_values(xset_id, p_commit => p_commit); /* Added to fix Bug#7422423*/

  RETURN (0);

EXCEPTION

     WHEN no_data_found THEN
        RETURN (0);

     WHEN cost_err THEN
        error_message := SUBSTR('INVPPROC.inproit_process_item: ' || return_err, 1,240);
        message_name := 'COST_ERROR';
        RETURN (1);

     WHEN LOGGING_ERR THEN
        error_message := SUBSTR('INVPPROC.inproit_process_item : Logging Error',1,240);
        message_name  := 'LOGGING_ERROR';
        RETURN (1);

     WHEN others THEN
        IF l_inv_debug_level IN(101, 102) THEN
           INVPUTLI.info('INVPPROC: Exception during INSERT '||FND_MESSAGE.GET);
        END IF;
        error_message := SUBSTR('INVPPROC.inproit_process_item ' || sqlerrm, 1,240);
        message_name := 'OTHER_INVPPROC_ERROR';
        RETURN (1);

END inproit_process_item;


END INVPPROC;

/
